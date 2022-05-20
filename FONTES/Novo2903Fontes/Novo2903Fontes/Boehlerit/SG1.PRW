#INCLUDE "rwmake.ch"

// Rotina		: SUPER GRUPO
// Descrição	: Faturamento por super grupo
// Data			: __/12/05
// Autor        : Daniel Gondran

User Function SG1()

// mv_par01 - Da data
// mv_par02 - Ate data

//cPerg := "SG0001"
 cPerg    := PadR( 'SG0001' , Len( SX1->X1_GRUPO ) )
AjustaSX1()
Pergunte(cPerg,.F.)

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Faturamento Super Grupo"
@ 70,080 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
@ 70,118 BMPBUTTON TYPE 1 ACTION OkProc()
@ 70,156 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
@ 23,14 SAY " " size 200,10
@ 33,14 SAY "" size 200,10
@ 43,14 SAY ""
@ 8,10 TO 060,180
ACTIVATE DIALOG oDlg5 CENTERED

Return

Static Function OkProc()
Close(oDlg5)

Processa( {|| Runproc() } , "Gerando Arquivo" )

Return

//*******************************************************************************( INICIO )
STATIC FUNCTION Runproc()
icfops 	:= "5551"

aStru := {}
aAdd(aStru,{"NOTA"       ,"C",06,0})
aAdd(aStru,{"CLIENTE"    ,"C",20,0})
aAdd(aStru,{"ITEM"       ,"C",03,0})
aAdd(aStru,{"EMISSAO"    ,"D",08,0})
aAdd(aStru,{"VEND1"      ,"C",20,0})
aAdd(aStru,{"VEND2"      ,"C",20,0})
aAdd(aStru,{"PRODUTO"    ,"C",15,0})
aAdd(aStru,{"CODLMT"     ,"C",46,0})
aAdd(aStru,{"ESPECIF"    ,"C",60,0})
aAdd(aStru,{"MARCA"      ,"C",20,0})
aAdd(aStru,{"QTDADE"     ,"N",14,3})
aAdd(aStru,{"VALOR"      ,"N",14,2})


oTemptable := FWTemporaryTable():New( "TRB")
oTemptable:SetFields( aStru )
//oTempTable:AddIndex("index1", {"COD"} )
oTempTable:Create()
/*
cArq := CriaTrab(aStru,.T.)
dbUseArea(.T.,,cArq,"TRB",.T.)
cInd := CriaTrab(NIL,.F.)
*/

aStru := {}
aAdd(aStru,{"EMPRESA"    ,"C",20,0})
aAdd(aStru,{"SUPER"      ,"C",52,0})
aAdd(aStru,{"GRUPO"      ,"C",04,0})
aAdd(aStru,{"VALOR"      ,"N",14,2})


oTemptable := FWTemporaryTable():New( "TRC")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"EMPRESA+SUPER+GRUPO"} )
oTempTable:Create()
/*
cArq := CriaTrab(aStru,.T.)
dbUseArea(.T.,,cArq,"TRC",.T.)
cInd := CriaTrab(NIL,.F.)
IndRegua("TRC",cInd,"EMPRESA + SUPER + GRUPO",,,"Selecionando Registros...")
*/
iData 	 := MV_PAR01 
aEmps 	 := {"BO","FE","KI","NI","ON","BR","BI","MT"}
aEmpresa := {"BOEHLERIT","FETTE","KIENINGER","NIPPON","ONSRUD","FAB. BRASIL","BILZ","MORRIS TOOLING"}
mtit1    := "Faturamento liquido por empresa"

//Set SoftSeek On

dbselectarea("SD2")
dbSetOrder(5)
ProcRegua(LastRec())
dbSeek(xFilial("SD2")+dtos(idata),.t.)
DO WHILE !EOF() .AND. D2_FILIAL == xFilial("SD2") .and. D2_EMISSAO <= MV_PAR02 // Year(D2_EMISSAO) == Year(idata) 
	IncProc( "Processando vendas dia » " + DtoC( SD2->D2_EMISSAO ) )

	If Year(D2_EMISSAO)>2004
		dbSelectArea("SF4")
		dbSetOrder(1)
		dbSeek(xFilial("SF4") + SD2->D2_TES)
		If F4_DUPLIC == "N" .OR. F4_CF $ icfops .or. SD2->D2_TIPO == "D"
			dbSelectArea("SD2")
			dbSkip()
			Loop
		Endif
	Else
		If !Substr(D2_CF,2,3) $ "111,112,108,102,101,949,110,109"
			dbSelectArea("SD2")
			dbSkip()
			Loop
		Endif
	Endif

	dbSelectArea("SC5")
	dbSetOrder(1)
	dbSeek(xFilial("SC5") + SD2->D2_PEDIDO + SD2->D2_ITEMPV)
	cVend		:= C5_NOMEVEN
	cCodVend1	:= C5_VEND1

	nPerc1 := 100
	nPerc2 := 100
	cVend2 := ""
	dbSelectArea("SD2")
	cMes     := "REAL" + StrZero(Month(SD2->D2_EMISSAO),2)
		nIndice := Ascan(aEmps,Left(D2_COD,2))
		if nindice==6
			xxx :=1
		Endif
		If nIndice == 0
			mCampo := "OUTROS              "
			mOrdem := "7"
		Else
			mCampo := Padr(aEmpresa[nIndice],20)
			mOrdem := StrZero(nIndice,1)
		Endif

		mVRTOTAL	:= SD2->D2_TOTAL - SD2->D2_VALICM - SD2->D2_VALIMP1 - SD2->D2_VALIMP2 - SD2->D2_VALIMP3 - SD2->D2_VALIMP4 - SD2->D2_VALIMP5 - SD2->D2_VALIMP6


	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1") + SD2->D2_CLIENTE + SD2->D2_LOJA)

	dbSelectArea("TRB")
	RecLock("TRB",.T.)
	NOTA	 := SD2->D2_DOC
	CLIENTE	 := SA1->A1_NREDUZ
	ITEM	 := SD2->D2_ITEM
	EMISSAO	 := SD2->D2_EMISSAO
	VEND1    := mcampo 
	PRODUTO  := SD2->D2_COD
	CODLMT	 := SD2->D2_CODLMT
	ESPECIF  := IF( Left( SD2->D2_COD , 2 ) == "KI" , Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DENOM") , "" )
	QTDADE	 := SD2->D2_QUANT * (nPerc1 / 100)
	VALOR    := mVrtotal * (nPerc1 / 100)

	msUnlock()

	If SC5->C5_VEND1 == "000016" .or. SC5->C5_VEND2 == "000016"
		xxx:=1
	Endif
	dbSelectArea("SD2")
	dbSkip()
Enddo

dbselectarea("SD1")
dbSetOrder(6)
ProcRegua(LastRec())
dbSeek(xFilial("SD1")+dtos(idata),.t.)
DO WHILE !EOF() .AND. D1_FILIAL == xFilial("SD1") .and. D1_DTDIGIT <= mv_par02 
	IncProc( "Processando dev.vendas dia » " + DtoC( SD1->D1_DTDIGIT ) )

	If SD1->D1_TIPO <> "D"
		dbSkip()
		Loop
	Endif
	dbSelectArea("SF4")
	dbSetOrder(1)
	dbSeek(xFilial("SF4") + SD1->D1_TES)
	If F4_DUPLIC == "N" .OR. F4_CF $ icfops
		dbSelectArea("SD1")
		dbSkip()
		Loop
	Endif
	dbSelectArea("SD2")
	dbSetOrder(3)
	If dbSeek(xFilial("SD2") + SD1->D1_NFORI + SD1->D1_SERIORI)
		dbSelectArea("SC5")
		dbSetOrder(1)
		dbSeek(xFilial("SC5") + SD2->D2_PEDIDO + SD2->D2_ITEMPV)
		cVend 	 := C5_NOMEVEN
		cPEDOUCLI := "P"
	Else
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1") + SD1->D1_FORNECE + SD1->D1_LOJA)
		dbSelectArea("SA3")
		dbSetOrder(1)
		dbSeek(xFilial("SA3") + SA1->A1_VEND)
		cVend 	:= A3_NREDUZ
		cPEDOUCLI := "C"
	Endif

	nPerc1 := 100
	nPerc2 := 100

	dbSelectArea("SD1")
	cMes     := "REAL" + StrZero(Month(D1_DTDIGIT),2)
		nIndice := Ascan(aEmps,Left(D1_COD,2))
		If nIndice == 0
			mCampo := "OUTROS              "
			mOrdem := "7"
		Else
			mCampo := Padr(aEmpresa[nIndice],20)
			mOrdem := StrZero(nIndice,1)
		Endif

		mVRTOTAL	:= (SD1->D1_TOTAL-SD1->D1_VALDESC - SD1->D1_VALICM - SD1->D1_VALIMP1 - SD1->D1_VALIMP2 - SD1->D1_VALIMP3 - SD1->D1_VALIMP4 - SD1->D1_VALIMP5 - SD1->D1_VALIMP6) * (-1)


	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1") + SD1->D1_FORNECE + SD1->D1_LOJA)

	dbSelectArea("TRB")
	RecLock("TRB",.T.)
	NOTA	 := SD1->D1_DOC
	CLIENTE	 := SA1->A1_NREDUZ
	ITEM	 := SD1->D1_ITEM
	EMISSAO	 := SD1->D1_DTDIGIT
	VEND1    := mCampo
	PRODUTO  := SD1->D1_COD
	CODLMT	 := SD1->D1_CODLMT
	ESPECIF  := IF( Left( SD1->D1_COD , 2 ) == "KI" , Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_DENOM") , "" )
	QTDADE	 := SD1->D1_QUANT * (nPerc1 / 100)
	VALOR    := mVrtotal * (nPerc1 / 100)

	msUnlock()



	dbSelectArea("SD1")
	dbSkip()
Enddo


ferase("\SIGAADV\SG1.DBF")
dbselectarea("TRB")
dbgotop()
//COPY TO "\SIGAADV\SG1.DBF" VIA "DBFCDXADS"
Processa({||CpyS2T("\SIGAADV\SG1.DBF","C:\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
ferase("\SIGAADV\SG1.DBF")

dbGotop()
do While !Eof()
	cEmpresa := TRB->VEND1
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1") + TRB->PRODUTO)
	cGrupo := SB1->B1_GRUPO

//	dbSelectArea("SBM")
//	dbSetOrder(1)
//	dbSeek(xFilial("SBM") + SB1->B1_GRUPO)

	dbSelectArea("SBM")
	dbSetOrder(1)
	dbSeek(xFilial("SBM") + SB1->B1_GRUPO )
	cSuper := PADR(Tabela("Z7",SBM->BM_ORDEM),52)
//		ORDGRSBM    := SBM->BM_ORDEM		

	if SB1->B1_SUPERGR <> space(3)
		dbSelectArea("SX5")
		dbSetOrder(1)
		dbSeek(xFilial("SX5")+"Z7"+SB1->B1_SUPERGR)
		cSuper := PADR(Tabela("Z7",B1->B1_SUPERGR),52)
//		ORDGRSBM    := SB1->B1_SUPERGR
	endif
		
	nValor := TRB->VALOR
	
	dbSelectArea("TRC")
	lAchou := dbSeek(cEmpresa + cSuper + cGrupo)
	RecLock("TRC",!lAChou)
	EMPRESA := cEmpresa
	SUPER	:= cSuper
	GRUPO	:= cGrupo
	VALOR	+= nValor
	msUnlock()
	
	dbSelectArea("TRB")
	dbSkip()
Enddo

dbSelectArea("TRC")
//COPY TO "\SIGAADV\SG11.DBF" VIA "DBFCDXADS"
	


TRB->(DBCLOSEAREA())

//mTESTE := "1;0;1;GIS"  // "EM DISCO;ATUALIZA;1 COPIA;NOME REL."
//CALLCRYS("VEND2",,mTESTE)

//Set SoftSeek Off

TRC->(DBCLOSEAREA())

Return

// *----------------------------------------------------------------------------
Static Function AjustaSX1()
aPerg    := {}
//cPerg    := "SG0001"

Aadd( aPerg , { "Da Data           ?" , "D" , 08 , "   "})
Aadd( aPerg , { "Ate Data          ?" , "D" , 08 , "   "})


For nXX := 1 to Len( aPerg )
	If !SX1->( DbSeek( cPerg + StrZero( nXX , 2 ) ) )
		RecLock( "SX1" , .T. )
		SX1->X1_GRUPO   := cPerg
		SX1->X1_ORDEM   := StrZero( nXX , 2 )
		SX1->X1_PERGUNT := aPerg[nXX][1]
		SX1->X1_VARIAVL := "mv_ch" + Str( nXX , 1 )
		SX1->X1_TIPO    := aPerg[nXX][2]
		SX1->X1_TAMANHO := aPerg[nXX][3]
		SX1->X1_PRESEL  := 1
		SX1->X1_GSC     := "G"
		SX1->X1_VAR01   := "mv_par" + StrZero( nXX , 2 )
		SX1->X1_F3		:= aPerg[nxx][4]
		SX1->(MsUnLock())
	EndIf
Next nXX
Return Nil
