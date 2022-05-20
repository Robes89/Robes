#INCLUDE "rwmake.ch"

// Rotina		: VENDAL
// Descrição	: Venda Liquida
// Data			: 20/01/05
// Autor        : Daniel Gondran

User Function VENDAL2()

// mv_par01 - Do  Produto
// mv_par02 - Até Produto
// mv_par03 - Quebra (empresa / vendedor)
// mv_par04 - Ano    
// mv_par05 - Abate Impostos
// mv_par06 - Status Pedido (SEDPICO)

//cPerg := "VENDAL"
 cPerg    := PadR( 'VENDAL' , Len( SX1->X1_GRUPO ) )
AjustaSX1()
Pergunte(cPerg,.F.)

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Venda Liquida Anual"
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
aAdd(aStru,{"AORDEM"     ,"C",01,0})
aAdd(aStru,{"VENDEMP"    ,"C",20,0})
aAdd(aStru,{"PREV01"     ,"N",14,2})
aAdd(aStru,{"PREV02"     ,"N",14,2})
aAdd(aStru,{"PREV03"     ,"N",14,2})
aAdd(aStru,{"PREV04"     ,"N",14,2})
aAdd(aStru,{"PREV05"     ,"N",14,2})
aAdd(aStru,{"PREV06"     ,"N",14,2})
aAdd(aStru,{"PREV07"     ,"N",14,2})
aAdd(aStru,{"PREV08"     ,"N",14,2})
aAdd(aStru,{"PREV09"     ,"N",14,2})
aAdd(aStru,{"PREV10"     ,"N",14,2})
aAdd(aStru,{"PREV11"     ,"N",14,2})
aAdd(aStru,{"PREV12"     ,"N",14,2})
aAdd(aStru,{"PREV13"     ,"N",14,2})
aAdd(aStru,{"REAL01"     ,"N",14,2})
aAdd(aStru,{"REAL02"     ,"N",14,2})
aAdd(aStru,{"REAL03"     ,"N",14,2})
aAdd(aStru,{"REAL04"     ,"N",14,2})
aAdd(aStru,{"REAL05"     ,"N",14,2})
aAdd(aStru,{"REAL06"     ,"N",14,2})
aAdd(aStru,{"REAL07"     ,"N",14,2})
aAdd(aStru,{"REAL08"     ,"N",14,2})
aAdd(aStru,{"REAL09"     ,"N",14,2})
aAdd(aStru,{"REAL10"     ,"N",14,2})
aAdd(aStru,{"REAL11"     ,"N",14,2})
aAdd(aStru,{"REAL12"     ,"N",14,2})
aAdd(aStru,{"REAL13"     ,"N",14,2})
aAdd(aStru,{"TITULO1"    ,"C",52,0})
aAdd(aStru,{"TITULO2"    ,"C",52,0})

oTemptable := FWTemporaryTable():New( "TRC")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"VENDEMP"} )
oTempTable:Create()

//cArq := CriaTrab(aStru,.T.)
//dbUseArea(.T.,,cArq,"TRC",.T.)
//cInd := CriaTrab(NIL,.F.)
//IndRegua("TRC",cInd,"VENDEMP",,,"Selecionando Registros...")

aStru := {}
aAdd(aStru,{"PEDIDO"     ,"C",06,0})
aAdd(aStru,{"CLIENTE"    ,"C",20,0})
aAdd(aStru,{"STATPED"    ,"C",01,0})
aAdd(aStru,{"EMISSAO"    ,"D",08,0})
aAdd(aStru,{"VENDEDOR"   ,"C",20,0})
aAdd(aStru,{"PRODUTO"    ,"C",15,0})
aAdd(aStru,{"CODLMT"     ,"C",46,0})
aAdd(aStru,{"EMPRESA"    ,"C",20,0})
aAdd(aStru,{"VALOR"      ,"N",14,2})

oTemptable := FWTemporaryTable():New( "TRB")
oTemptable:SetFields( aStru )
//oTempTable:AddIndex("index1", {"COD"} )
oTempTable:Create()

//cArq := CriaTrab(aStru,.T.)
//dbUseArea(.T.,,cArq,"TRB",.T.)
//cInd := CriaTrab(NIL,.F.)



iData 	 := ctod("01/01/"+mv_par04)
aEmps 	 := {"BO","FE","KI","NI","ON","BR","BI","MT"}
aEmpresa := {"BOEHLERIT","FETTE","KIENINGER","NIPPON","ONSRUD","FAB. BRASIL","BILZ","MORRIS TOOLING"}
mtit1    := "Venda "+Iif(mv_par05==2,"bruta","liquida")+" por " + Iif(mv_par03==1,"empresa","vendedor") + " " + mv_par04
               
Set SoftSeek On
               
dbselectarea("SC5")
dbSetOrder(2)
ProcRegua(LastRec())
dbSeek(xFilial("SC5")+dtos(idata))
DO WHILE !EOF() .AND. C5_FILIAL == xFilial("SC5") .and. Year(C5_EMISSAO) == Year(idata)
	IncProc(C5_NUM)
	If !(C5_STPAD $ mv_par06)
		dbSkip()
		loop
	Endif
	cVend 	 := C5_NOMEVEN
	nMoeda   := C5_MOEDA
	If nMoeda <> 1
		cMoeda := "M2_MOEDA" + StrZero(nMoeda,1)
		dbSelectArea("SM2")
		dbSeek(SC5->C5_EMISSAO)
		nConv  := &(cMoeda)
		If nConv == 0
			Alert ("Atenção: Cadastrar Moeda " + StrZero(nMoeda,1) + " no dia " + Dtoc(SC5->C5_EMISSAO))
		Endif			
	Else
		nConv := 1
	Endif
	cMes     := "REAL" + StrZero(Month(SC5->C5_EMISSAO),2)
	dbSelectArea("SC6")    
	dbSetOrder(1)
	dbSeek(xFilial("SC6") + SC5->C5_NUM)
	do While !Eof() .and. C6_FILIAL == xFilial("SC6") .and. C6_NUM == SC5->C5_NUM 
		If C6_BLQ == "R "
//			dbSkip()
//			Loop  
			cMes := "PREV" + StrZero(Month(SC5->C5_EMISSAO),2)
		Endif
		dbSelectArea("SF4")
		dbSetOrder(1)
		dbSeek(xFilial("SF4") + SC6->C6_TES) 
		IF F4_ICM == "S"
			lcalicm := .T.
		Else
			lcalicm := .F.
		Endif
		If F4_IPI == "S"
			lcalipi := .T.
		Else
			lcalipi := .F.
		Endif
		If F4_PISCOF == "1"
			lcalpis := .T.
			lcalcof := .F.
		ElseIf F4_PISCOF == "2"
			lcalpis := .F.
			lcalcof := .T.
		ElseIf F4_PISCOF == "3"
			lcalpis := .T.
			lcalcof := .T.
		Else
			lcalpis := .F.
			lcalcof := .F.
		Endif
		If mv_par03 == 2
			mCampo := cVend
			mOrdem := " "
		Else
			nIndice := Ascan(aEmps,Left(SC6->C6_PRODUTO,2))
			If nIndice == 0
				mCampo := "OUTROS              "
				mOrdem := "7"
			Else
				mCampo := Padr(aEmpresa[nIndice],20)
				mOrdem := StrZero(nIndice,1)
			Endif
		Endif
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFIlial("SB1") + SC6->C6_PRODUTO)
		If mv_par05 == 2
			nIpi      := SB1->B1_IPI
			mVRUNIT   := SC6->C6_PRCVEN + Iif(lcalipi,(SC6->C6_PRCVEN * nIpi / 100),0)
			mVRTOTAL  := mVRUNIT * (SC6->C6_QTDVEN - IIF(SC5->C5_STPAD=="E",SC6->C6_QTDENT,0))
			nIndice   := Ascan(aEmps,Left(SC6->C6_PRODUTO,2))
			If nIndice == 0
				mEmpresa := "OUTROS              "
			Else
				mEmpresa := Padr(aEmpresa[nIndice],20)
			Endif
		Else      
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(xFilial("SA1") + SC6->C6_CLI + SC6->C6_LOJA)
			dbSelectArea("SC6")
			cNorte := GetMV("MV_NORTE")
			If SA1->A1_EST $ cNorte
				nIcms := 7
			ElseIf SA1->A1_EST == "SP"
				If SB1->B1_PICM > 0
					nIcms := SB1->B1_PICM
				Else
					nIcms := 18
				Endif
			Else
				nIcms := 12
			Endif
			nCof := GetMV("MV_TXCOFIN")
			nPis := GetMV("MV_TXPIS")
			mVRUNIT   := SC6->C6_PRCVEN - Iif(lCalIcm,SC6->C6_PRCVEN * nIcms/100,0) - SC6->C6_PRCVEN * (Iif(lCalPis,nPis,0)+Iif(lcalcof,nCof,0))/100
			mVRTOTAL  := mVRUNIT * (SC6->C6_QTDVEN - IIF(SC5->C5_STPAD=="E",SC6->C6_QTDENT,0))
		Endif
		
		nIndice   := Ascan(aEmps,Left(SC6->C6_PRODUTO,2))
		If nIndice == 0
			mEmpresa := "OUTROS              "
		Else
			mEmpresa := Padr(aEmpresa[nIndice],20)
		Endif                   
		
		dbSelectArea("TRB")
		RecLock("TRB",.T.)
		PEDIDO	 := SC5->C5_NUM
		CLIENTE	 := SC5->C5_NOMECLI
		STATPED  := SC5->C5_STPAD
		EMISSAO	 := SC5->C5_EMISSAO
		VENDEDOR := SC5->C5_NOMEVEN
		PRODUTO  := SC6->C6_PRODUTO
		CODLMT	 := SC6->C6_CODLMT
		VALOR    := mVRTOTAL * nConv
		EMPRESA  := mEmpresa
		msUnlock()
        
		dbSelectArea("TRC")
		lAchou := dbSeek(mCampo)
		RecLock( "TRC" , !lAchou)					
		VENDEMP		:= mCampo
		AORDEM  	:= mOrdem		
		&(cMes)		+= mVRTOTAL * nConv
		TITULO1     := mTit1
		TRC->( MsUnLock() )
		dbSelectArea("SC6")
		dbSkip()
	Enddo
	dbSelectArea("SC5")
	dbSkip()
Enddo

dbSelectArea("TRC")
dbGotop()
do While !EOF()
	RecLock("TRC",.F.)
	PREV13:=PREV01+PREV02+PREV03+PREV04+PREV05+PREV06+PREV07+PREV08+PREV09+PREV10+PREV11+PREV12
	REAL13:=REAL01+REAL02+REAL03+REAL04+REAL05+REAL06+REAL07+REAL08+REAL09+REAL10+REAL11+REAL12	
	msUnlock()
	dbSkip()
Enddo	
ferase("\SIGAADV\SAIDAV.DBF")
dbselectarea("TRB")
dbgotop()
//COPY TO "\SIGAADV\SAIDAV.DBF" VIA "DBFCDXADS"
Processa({||CpyS2T("\SIGAADV\SAIDAV.DBF","C:\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
ferase("\SIGAADV\SAIDAV.DBF")
TRB->(DBCLOSEAREA())

ferase("\DADOSADV\VEND.DBF")
dbselectarea("TRC")
dbgotop()
//COPY TO "\DADOSADV\VEND.DBF" VIA "DBFCDXADS"
Processa({||CpyS2T("\DADOSADV\VEND.DBF","C:\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
ferase("\DADOSADV\VEND.DBF")
TRC->(DBCLOSEAREA())
mTESTE := "1;0;1;GIS"  // "EM DISCO;ATUALIZA;1 COPIA;NOME REL."
CALLCRYS("VEND",,mTESTE)

Set SoftSeek Off
Return

// *----------------------------------------------------------------------------
Static Function AjustaSX1()
aPerg    := {}
//cPerg    := "VENDAL"

Aadd( aPerg , { "Do Produto          ?" , "C" , 15 , "SB1"})
Aadd( aPerg , { "Ate Produto         ?" , "C" , 15 , "SB1"})
Aadd( aPerg , { "Empresa/Vendedor    ?" , "N" , 01 , "   "})
Aadd( aPerg , { "Ano Referencia      ?" , "C" , 04 , "   "})
Aadd( aPerg , { "Abate impostos      ?" , "N" , 01 , "   "})
Aadd( aPerg , { "Status Ped (SEPDICO)?" , "C" , 07 , "   "})

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
		If nxx == 3
			SX1->X1_GSC   := "C"
			SX1->X1_DEF01 := "Empresa"
			SX1->X1_DEF02 := "Vendedor"
		Endif
		If nxx == 5
			SX1->X1_GSC   := "C"
			SX1->X1_DEF01 := "Sim"
			SX1->X1_DEF02 := "Nao"
		Endif
		SX1->(MsUnLock())
	EndIf
Next nXX
Return Nil
