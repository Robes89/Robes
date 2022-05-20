#INCLUDE "rwmake.ch"

// Rotina		: FATURV
// Descrição	: Faturamento por Vendedor
// Data			: 04/03/05
// Autor        : Daniel Gondran

//Alterado em 18_06 Fernando
//Incluir filtro vendedor

User Function FATURV()

// mv_par01 - Do  Produto
// mv_par02 - Até Produto
// mv_par03 - Da Data 
// mv_par04 - Ate Data    
// mv_par05 - Ignora CFOPs
// mv_par06 - Vendedor de
// mv_par07 - Vendedor ate

//cPerg := "FATURV"
 cPerg    := PadR( 'FATURV' , Len( SX1->X1_GRUPO ) )
AjustaSX1()
Pergunte(cPerg,.F.)

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Faturamento por Vendedor"
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

aStru := {}
aAdd(aStru,{"OGRUPO"     ,"C",01,0})
aAdd(aStru,{"GRUPO"      ,"C",20,0})
aAdd(aStru,{"NOTA"       ,"C",09,0})   
aAdd(aStru,{"PEDIDO"     ,"C",06,0})   
aAdd(aStru,{"PEDCLI"     ,"C",20,0})   
aAdd(aStru,{"CLIENTE"    ,"C",20,0})
aAdd(aStru,{"ITEM"       ,"C",03,0})
aAdd(aStru,{"EMISSAO"    ,"D",08,0})
aAdd(aStru,{"VEND1"      ,"C",20,0})
aAdd(aStru,{"VEND2"      ,"C",20,0})
aAdd(aStru,{"PRODUTO"    ,"C",80,0})
aAdd(aStru,{"VALOR"      ,"N",14,2})
aAdd(aStru,{"PRECOUN"    ,"N",14,4})
aAdd(aStru,{"QUANT"      ,"N",14,2})
aAdd(aStru,{"FRETE"      ,"N",14,2})
aAdd(aStru,{"VALIPI"     ,"N",14,2})
aAdd(aStru,{"VENDEMP"    ,"C",20,0})
aAdd(aStru,{"TITULO1"    ,"C",52,0})
aAdd(aStru,{"TITULO2"    ,"C",52,0})

//cArq := CriaTrab(aStru,.T.)
//dbUseArea(.T.,,cArq,"TRB",.T.)
//cInd := CriaTrab(NIL,.F.)

oTemptable := FWTemporaryTable():New( "TRB")
oTemptable:SetFields( aStru )
//oTempTable:AddIndex("index1", {"COD"} )
oTempTable:Create()

iData 	 := mv_par03
fData	 := mv_par04
aEmps 	 := {"BO","FE","KI","NI","ON","BR","BI","MT"}
aEmpresa := {"BOEHLERIT","FETTE","KIENINGER","NIPPON","ONSRUD","FAB. BRASIL","BILZ","MORRIS TOOLING"}
mtit1    := "Faturamento  por vendedor "

Set SoftSeek On
               
dbselectarea("SD2")
dbSetOrder(5)
ProcRegua(LastRec())
dbSeek(xFilial("SD2")+dtos(idata))
DO WHILE !EOF() .AND. D2_FILIAL == xFilial("SD2") .and. D2_EMISSAO <= fData
	dbSelectArea("SF4")
	dbSetOrder(1)
	dbSeek(xFilial("SF4") + SD2->D2_TES)
	If F4_DUPLIC == "N" .OR. F4_CF $ mv_par05 .or. SD2->D2_TIPO == "D"
		dbSelectArea("SD2")
		dbSkip()
		Loop
	Endif
	
	//Verifica se vendedor atende ao grupo de perguntas
	DBSelectArea("SF2")
	DBSetOrder(1)	//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL
	DBSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA)
	If(SF2->F2_VEND1 < MV_PAR06 .OR. SF2->F2_VEND1 > MV_PAR07)
		DBSelectArea("SD2")
		DBSkip()
		Loop
	EndIf
	
	dbSelectArea("SD2")
	IncProc(D2_DOC)
	dbSelectArea("SC5")
	dbSetOrder(1)
	dbSeek(xFilial("SC5") + SD2->D2_PEDIDO + SD2->D2_ITEMPV)
	cVend 	 := C5_NOMEVEN
	// Tratamento para o 000009 - Paulo e o 000010 - Rogerio (70/30)
	lDoisV := .F.
	nPerc1 := 100
	nPerc2 := 100
	cVend2 := ""
	If !Empty(C5_VEND2)
		lDoisV := .T.
		dbSelectArea("SA3")
		dbSetOrder(1)
		dbSeek(xFilial("SA3") + SC5->C5_VEND2)
		mCampo2 := A3_NREDUZ
		cVend2  := A3_NREDUZ
		dbSelectArea("SC5")
		If C5_VEND1 == "000009"
			nPerc1 := 70
		ElseIf C5_VEND1 $ "000010/000026"
			nPerc1 := 30
		ElseIf C5_VEND1 == "000016"
			nPerc1 := 70
		ElseIf C5_VEND1 $ "000005/000008"
			nPerc1 := 50
		Endif
		If C5_VEND2 == "000009"
			nPerc2 := 70
		ElseIf C5_VEND2 $ "000010/000026"
			nPerc2 := 30
		ElseIf C5_VEND2 == "000016"
			nPerc2 := 70
		ElseIf C5_VEND2 $ "000005/000008"
			nPerc2 := 50
		Endif
	Endif
	dbSelectArea("SD2")
	mCampo := cVend
	mOrdem := " "
	mVRTOTAL 	:= SD2->D2_TOTAL - SD2->D2_VALICM - SD2->D2_VALIMP1 - SD2->D2_VALIMP2 - SD2->D2_VALIMP3 - SD2->D2_VALIMP4 - SD2->D2_VALIMP5 - SD2->D2_VALIMP6 
	nQuant		:= SD2->D2_QUANT
	nFrete		:= SD2->D2_VALFRE
//	nValIPI		:= SD2->D2_TOTAL + SD2->D2_VALIPI
	nValIPI 	:= SD2->D2_TOTAL - SD2->D2_VALICM - SD2->D2_VALIMP1 - SD2->D2_VALIMP2 - SD2->D2_VALIMP3 - SD2->D2_VALIMP4 - SD2->D2_VALIMP5 - SD2->D2_VALIMP6 
	nPrecoUn    := nValIPI / SD2->D2_QUANT // SD2->D2_PRCVEN 
	
	dbSelectArea("SC6")
	dbSetOrder(2)
	dbSeek(xFilial("SC6") + SD2->D2_COD + SD2->D2_PEDIDO)
	cPedCli := C6_PEDCLI
	
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1") + SD2->D2_COD)
	cProduto := Trim(SB1->B1_CODLMT) + Iif(Left(SB1->B1_COD,2)=="KI", " " + Trim(SB1->B1_DESC)," ")

	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1") + SD2->D2_CLIENTE + SD2->D2_LOJA)
	
	dbSelectArea("TRB")
	RecLock("TRB",.T.)   
	OGRUPO   := "1"
	GRUPO    := "FATURAMENTO"
	VENDEMP	 := mCampo	
	NOTA	 := SD2->D2_DOC
	CLIENTE	 := SA1->A1_NREDUZ
	ITEM	 := SD2->D2_ITEM
	EMISSAO	 := SD2->D2_EMISSAO 
	PEDIDO   := SD2->D2_PEDIDO
	PEDCLI   := cPedcli
	VEND1    := cVend
	VEND2    := cVend2
	PRODUTO  := cProduto
	VALOR    := (mVrtotal + nfrete) * nPerc1 / 100
	TITULO1  := mTit1	
	QUANT	 := nQuant * nPerc1 / 100
	FRETE	 := nFrete * nPerc1 / 100
	VALIPI   := nValIPI * nPerc1 / 100
	PRECOUN	 := nPrecoUn * nPerc1 / 100
	TITULO1  := "De " + Dtoc(mv_par03) + " ate " + Dtoc(mv_par04)	
	msUnlock()
	If lDoisV
	dbSelectArea("TRB")
	RecLock("TRB",.T.)   
		OGRUPO   := "1"
		GRUPO    := "FATURAMENTO"
		VENDEMP	 := mCampo2
		NOTA	 := SD2->D2_DOC
		CLIENTE	 := SA1->A1_NREDUZ
		ITEM	 := SD2->D2_ITEM
		EMISSAO	 := SD2->D2_EMISSAO 
		PEDIDO   := SD2->D2_PEDIDO
		PEDCLI   := cPedcli
		VEND1    := cVend
		VEND2    := cVend2
		PRODUTO  := cProduto
		VALOR    := (mVrtotal + nfrete) * nPerc2  / 100
		TITULO1  := mTit1	
		QUANT	 := nQuant * nPerc2 / 100
		FRETE	 := nFrete * nPerc2 / 100
		VALIPI   := nValIPI * nPerc2 / 100
		PRECOUN	 := nPrecoUn * nPerc2 / 100
		TITULO1  := "De " + Dtoc(mv_par03) + " ate " + Dtoc(mv_par04)	
		msUnlock()
	Endif        
	dbSelectArea("SD2")
	dbSkip()
Enddo

dbselectarea("SD1")
dbSetOrder(6)
ProcRegua(LastRec())
dbSeek(xFilial("SD1")+dtos(idata))
DO WHILE !EOF() .AND. D1_FILIAL == xFilial("SD1") .and. D1_DTDIGIT <= fData
	If SD1->D1_TIPO <> "D"
		dbSkip()
		Loop
	Endif	
	dbSelectArea("SF4")
	dbSetOrder(1)
	dbSeek(xFilial("SF4") + SD1->D1_TES)
	If F4_DUPLIC == "N" .OR. F4_CF $ mv_par05
		dbSelectArea("SD1")
		dbSkip()
		Loop
	Endif
	
	cCodVen := ""
	
	dbSelectArea("SD1")
	IncProc(D1_DOC)
	dbSelectArea("SD2")
	dbSetOrder(3)
	If dbSeek(xFilial("SD2") + SD1->D1_NFORI + SD1->D1_SERIORI)
		dbSelectArea("SF2")
		dbSetOrder(1)
		If dbSeek(xFilial("SF2") + SD1->D1_NFORI + SD1->D1_SERIORI)
			cCodVen := SF2->F2_VEND1
		EndIf
		dbSelectArea("SC5")
		dbSetOrder(1)
		dbSeek(xFilial("SC5") + SD2->D2_PEDIDO + SD2->D2_ITEMPV)
		cVend 	 := C5_NOMEVEN
		cPEDOUCLI := "P"
		dbSelectArea("SC6")
		dbSetOrder(2)
		dbSeek(xFilial("SC6") + SD1->D1_COD + SC5->C5_NUM)
		cPedido := C6_NUM
		cPedCli := C6_PEDCLI
	Else
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1") + SD1->D1_FORNECE + SD1->D1_LOJA)
		cCodVen := SA1->A1_VEND
		dbSelectArea("SA3")
		dbSetOrder(1)
		dbSeek(xFilial("SA3") + SA1->A1_VEND)
		cVend 	:= A3_NREDUZ
		cPEDOUCLI := "C"
	Endif
	
	//Verifica se vendedor atende ao grupo de perguntas
	If(cCodVen < MV_PAR06 .OR. cCodVen > MV_PAR07)
		DBSelectArea("SD1")
		DBSkip()
		Loop
	EndIf
	
	// Tratamento para o 000009 - Paulo e o 000010 - Rogerio (70/30)
	lDoisV := .F.
	nPerc1 := 100
	nPerc2 := 100
	If !Empty(IIF(cPEDOUCLI == "P",SC5->C5_VEND2,SA1->A1_VEND2))
		lDoisV := .T.
		dbSelectArea("SA3")
		dbSetOrder(1)
		dbSeek(xFilial("SA3") + IIF(cPEDOUCLI == "P",SC5->C5_VEND2,SA1->A1_VEND2))
		mCampo2 := A3_NREDUZ
		cVend2  := A3_NREDUZ
		dbSelectArea("SC5")
		If IIF(cPEDOUCLI == "P",SC5->C5_VEND1,SA1->A1_VEND) == "000009"
			nPerc1 := 70
		ElseIf IIF(cPEDOUCLI == "P",SC5->C5_VEND1,SA1->A1_VEND) $ "000010/000026"
			nPerc1 := 30
		ElseIf IIF(cPEDOUCLI == "P",SC5->C5_VEND1,SA1->A1_VEND) == "000016"
			nPerc1 := 70
		ElseIf IIF(cPEDOUCLI == "P",SC5->C5_VEND1,SA1->A1_VEND) $ "000005/000008"
			nPerc1 := 50
		Endif
		If IIF(cPEDOUCLI == "P",SC5->C5_VEND2,SA1->A1_VEND2) == "000009"
			nPerc2 := 70
		ElseIf IIF(cPEDOUCLI == "P",SC5->C5_VEND2,SA1->A1_VEND2) $ "000010/000026"
			nPerc2 := 30
		ElseIf IIF(cPEDOUCLI == "P",SC5->C5_VEND2,SA1->A1_VEND2) == "000016"
			nPerc2 := 70
		ElseIf IIF(cPEDOUCLI == "P",SC5->C5_VEND2,SA1->A1_VEND2) $ "000005/000008"
			nPerc2 := 50
		Endif

	Endif

	dbSelectArea("SD1")
	mCampo := cVend
	mOrdem := " "
	mVRTOTAL 	:= (SD1->D1_TOTAL-SD1->D1_VALDESC - SD1->D1_VALICM - SD1->D1_VALIMP1 - SD1->D1_VALIMP2 - SD1->D1_VALIMP3 - SD1->D1_VALIMP4 - SD1->D1_VALIMP5 - SD1->D1_VALIMP6) * (-1)
	nQuant		:= SD1->D1_QUANT
	nFrete		:= SD1->D1_VALFRE * (-1)
	nValIPI		:= (SD1->D1_TOTAL -SD1->D1_VALDESC - SD1->D1_VALICM - SD1->D1_VALIMP1 - SD1->D1_VALIMP2 - SD1->D1_VALIMP3 - SD1->D1_VALIMP4 - SD1->D1_VALIMP5 - SD1->D1_VALIMP6) * (-1)
	nPrecoUn    := mVRTOTAL / SD1->D1_QUANT * (-1) 
	
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1") + SD1->D1_COD)
	cProduto := Trim(SB1->B1_CODLMT) + Iif(Left(SB1->B1_COD,2)=="KI", " " + Trim(SB1->B1_DESC)," ")
	
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1") + SD1->D1_FORNECE + SD1->D1_LOJA)
	
	dbSelectArea("TRB")
	RecLock("TRB",.T.)
	OGRUPO   := "2"
	GRUPO    := "DEVOLUCOES"
	VENDEMP	 := mCampo	
	NOTA	 := SD1->D1_DOC
	CLIENTE	 := SA1->A1_NREDUZ
	ITEM	 := SD1->D1_ITEM
	EMISSAO	 := SD1->D1_DTDIGIT
//	PEDIDO   := cPedido
//	PEDCLI   := cPedcli
	VEND1    := cVend
	VEND2	 := cVend2
	PRODUTO  := cProduto
	VALOR    := (mVrtotal + nfrete ) * nPerc1 / 100
	TITULO1  := mTit1
	QUANT	 := nQuant * nPerc1 / 100
	FRETE	 := nFrete * nPerc1 / 100
	VALIPI   := nValIPI * nPerc1 / 100
	PRECOUN	 := nPrecoUn * nPerc1 / 100
	TITULO1  := "De " + Dtoc(mv_par03) + " ate " + Dtoc(mv_par04)
	msUnlock()
	If lDoisV
		dbSelectArea("TRB")
		RecLock("TRB",.T.)
		OGRUPO   := "2"
		GRUPO    := "DEVOLUCOES"
		VENDEMP	 := mCampo	
		NOTA	 := SD1->D1_DOC
		CLIENTE	 := SA1->A1_NREDUZ
		ITEM	 := SD1->D1_ITEM
		EMISSAO	 := SD1->D1_DTDIGIT
//		PEDIDO   := cPedido
//		PEDCLI   := cPedcli
		VEND1    := cVend
		VEND2	 := cVend2
		PRODUTO  := cProduto
		VALOR    := (mVrtotal + nfrete) * nPerc2 / 100
		TITULO1  := mTit1
		QUANT	 := nQuant * nPerc2 / 100
		FRETE	 := nFrete * nPerc2 /100
		VALIPI   := nValIPI * nPerc2 / 100
		PRECOUN	 := nPrecoUn * nPerc2 / 100
		TITULO1  := "De " + Dtoc(mv_par03) + " ate " + Dtoc(mv_par04)
		msUnlock()
	Endif        
	dbSelectArea("SD1")
	dbSkip()
Enddo



ferase("\SIGAADV\FATVEN.DBF")
dbselectarea("TRB")
dbgotop()
//COPY TO "\SIGAADV\FATVEN.DBF" VIA "DBFCDXADS"
Processa({||CpyS2T("\SIGAADV\FATVEN.DBF","C:\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
ferase("\SIGAADV\FATVEN.DBF")
TRB->(DBCLOSEAREA())

mTESTE := "1;0;1;GIS"  // "EM DISCO;ATUALIZA;1 COPIA;NOME REL."
CALLCRYS("FATVEN",,mTESTE)

Set SoftSeek Off
Return

// *----------------------------------------------------------------------------
Static Function AjustaSX1()
aPerg    := {}
//cPerg    := "FATURV"

Aadd( aPerg , { "Do Produto        ?" , "C" , 15 , "SB1"})
Aadd( aPerg , { "Ate Produto       ?" , "C" , 15 , "SB1"})
Aadd( aPerg , { "Da Data           ?" , "D" , 08 , "   "})
Aadd( aPerg , { "Ate Data          ?" , "D" , 08 , "   "})
Aadd( aPerg , { "Ignora CFOPs      :" , "C" , 40 , "   "})
Aadd( aPerg , { "Vendedor de       :" , "C" , 06 , "SA3"})
Aadd( aPerg , { "Vendedor ate      :" , "C" , 06 , "SA3"})

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
		SX1->(MsUnlock())
	EndIf
Next nXX
Return Nil
