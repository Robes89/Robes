#INCLUDE "rwmake.ch"

// Rotina		: VENDAV
// Descrição	: Vendas por Vendedor
// Data			: 04/03/05
// Autor        : Daniel Gondran

User Function VENDAV()

// mv_par01 - Do  Produto
// mv_par02 - Até Produto
// mv_par03 - Da Data
// mv_par04 - Ate Data
// mv_par05 - Ignora CFOPs
// mv_par06 - Status Pedido (SEDPICO)

//cPerg := "VENDAV"
cPerg    := PadR( 'VENDAV' , Len( SX1->X1_GRUPO ) )
AjustaSX1()
Pergunte(cPerg,.F.)

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Venda por Vendedor"
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
aAdd(aStru,{"NOTA"       ,"C",06,0})
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

oTemptable := FWTemporaryTable():New( "TRB")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"OGRUPO"} )
oTempTable:Create()

//cArq := CriaTrab(aStru,.T.)
//dbUseArea(.T.,,cArq,"TRB",.T.)
//cInd := CriaTrab(NIL,.F.)

iData 	 := mv_par03
fData	 := mv_par04
aEmps 	 := {"BO","FE","KI","NI","ON","BR","BI","MT"}
aEmpresa := {"BOEHLERIT","FETTE","KIENINGER","NIPPON","ONSRUD","FAB. BRASIL","BILZ","MORRIS TOOLING"}
mtit1    := "Faturamento  por vendedor "

Set SoftSeek On

dbselectarea("SC5")
dbSetOrder(2)
ProcRegua(LastRec())
dbSeek(xFilial("SC5")+dtos(idata))
DO WHILE !EOF() .AND. C5_FILIAL == xFilial("SC5") .and. C5_EMISSAO <= fdata
	IncProc(C5_NUM)
	If !(C5_STPAD $ mv_par06)
		dbSkip()
		loop
	Endif
	
	If	(C5_VEND1 < MV_PAR07 .or. C5_VEND1 > MV_PAR08) .or. ;
		(!Empty( C5_VEND2 ) .and. (C5_VEND2 < MV_PAR07 .or. C5_VEND2 > MV_PAR08))
		dbSkip()
		loop
	Endif
	
//	cVend 	 := C5_NOMEVEN
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
	dbSelectArea("SA1")
	dbSetORder(1)
	dbSeek(xFilial("SA1") + SC5->C5_CLIENTE)
	dbSelectArea("SC6")
	dbSetOrder(1)
	dbSeek(xFilial("SC6") + SC5->C5_NUM)
	nQTot := 0
	do While !Eof() .and. C6_FILIAL == xFilial("SC6") .and. C6_NUM == SC5->C5_NUM
		nQTot += SC6->C6_VALOR
		dbSkip()
	Enddo
	dbSeek(xFilial("SC6") + SC5->C5_NUM)

	do While !Eof() .and. C6_FILIAL == xFilial("SC6") .and. C6_NUM == SC5->C5_NUM
		If C6_BLQ == "R "
			cGrupo := "Vendas Canceladas"
			mGrupo := "2"
		Else
			cGrupo := "Vendas"
			mGrupo := "1"
		Endif
		cPedCli := C6_PEDCLI
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
//		mCampo := cVend
		mOrdem := " "
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFIlial("SB1") + SC6->C6_PRODUTO)
		cProduto := Trim(SB1->B1_CODLMT) + Iif(Left(SB1->B1_COD,2)=="KI", " " + Trim(SB1->B1_DESC)," ")
		nIpi      := SB1->B1_IPI
		nValIPI   := Iif(lcalipi,(SC6->C6_PRCVEN * nIpi / 100),0)
		mVRUNIT   := SC6->C6_PRCVEN + Iif(lcalipi,(SC6->C6_PRCVEN * nIpi / 100),0)
		mVRTOTAL  := mVRUNIT * (SC6->C6_QTDVEN - IIF(SC6->C6_BLQ=="R ",SC6->C6_QTDENT,0))
		nQuant    := SC6->C6_QTDVEN - IIF(SC6->C6_BLQ=="R ",SC6->C6_QTDENT,0)
		
		
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
//		mVRUNIT   := SC6->C6_PRCVEN - Iif(lCalIcm,(SC6->C6_PRCVEN + (SC5->C5_FRETE * (SC6->C6_VALOR / nQTot) / 100 )) * Iif(SF4->F4_INCIDE=="F",(1 + (nIpi / 100)),1) * nIcms/100,0) - (SC6->C6_PRCVEN + (SC5->C5_FRETE * (SC6->C6_VALOR / nQTot) / 100 )) * (Iif(lCalPis,nPis,0)+Iif(lcalcof,nCof,0))/100
					BASE1 := SC6->C6_PRCVEN + SC5->C5_FRETE * (SC6->C6_PRCVEN / nQTot)
					BASE := BASE1 * Iif(SF4->F4_INCIDE $ "F/S",(1 + (nIpi / 100)),1)
					nnicms := BASE * nIcms/100
					mVRUNIT   := SC6->C6_PRCVEN - NNICMS - ;
			             BASE1 * (IIF(.t.,Iif(lCalPis,nPis,0),0) + ;
			             IIF(.t.,Iif(lcalcof,nCof,0),0))/100

		mVRTOTAL  := mVRUNIT * (SC6->C6_QTDVEN - IIF(SC6->C6_BLQ=="R ",SC6->C6_QTDENT,0)) // * Iif(mGrupo == "2",(-1),1)

		lDoisV	:= .F.
		nPerc1	:= 100
		nPerc2	:= 100
		
		If	!Empty( SC5->C5_VEND2 )
			lDoisV	:= .T.

			If SC5->C5_VEND1 == "000009"
				nPerc1 := 70
			ElseIf SC5->C5_VEND1 $ "000010/000026"
				nPerc1 := 30
			ElseIf SC5->C5_VEND1 == "000016"
				nPerc1 := 70
			ElseIf SC5->C5_VEND1 $ "000005/000008"
				nPerc1 := 50                           
			Endif
			If SC5->C5_VEND2 == "000009"
				nPerc2 := 70
			ElseIf SC5->C5_VEND2 $ "000010/000026"
				nPerc2 := 30
			ElseIf SC5->C5_VEND2 == "000016"
				nPerc2 := 70
			ElseIf SC5->C5_VEND2 $ "000005/000008"
				nPerc2 := 50                           
			Endif

		EndIf

		nPerc1	:= nPerc1 / 100
		nPerc2	:= nPerc2 / 100

		dbSelectArea("TRB")
		RecLock("TRB",.T.)
		OGRUPO   := mGrupo
		GRUPO    := cGrupo
//		VENDEMP	 := mCampo
		VENDEMP	 := Posicione( "SA3" , 1 , xFilial( "SA3" ) + SC5->C5_VEND1 , "A3_NREDUZ" )
		CLIENTE	 := SA1->A1_NREDUZ
		EMISSAO	 := SC5->C5_EMISSAO
		PEDIDO   := SC5->C5_NUM
		PEDCLI   := cPedcli
//		VEND1    := cVend
		VEND1    := Posicione( "SA3" , 1 , xFilial( "SA3" ) + SC5->C5_VEND1 , "A3_NREDUZ" )
//		VEND2    := cVend2
		PRODUTO  := cProduto
		VALOR    := ( mVrtotal * nconv * nPerc1 )
		QUANT	 := ( nQuant * nPerc1 )
//		FRETE	 := ( nFrete * nPerc1 )
		VALIPI   := ( nValIPI * nPerc1 )
		PRECOUN	 := mVRUNIT
		TITULO1  := "De " + Dtoc(mv_par03) + " ate " + Dtoc(mv_par04)
		msUnlock()

		If lDoisV
			dbSelectArea("TRB")
			RecLock("TRB",.T.)
			OGRUPO   := mGrupo
			GRUPO    := cGrupo
//			VENDEMP	 := mCampo
			VENDEMP	 := Posicione( "SA3" , 1 , xFilial( "SA3" ) + SC5->C5_VEND2 , "A3_NREDUZ" )
			CLIENTE	 := SA1->A1_NREDUZ
			EMISSAO	 := SC5->C5_EMISSAO
			PEDIDO   := SC5->C5_NUM
			PEDCLI   := cPedcli
//			VEND1    := cVend
			VEND1    := Posicione( "SA3" , 1 , xFilial( "SA3" ) + SC5->C5_VEND2 , "A3_NREDUZ" )
//			VEND2    := cVend2
			PRODUTO  := cProduto
			VALOR    := ( mVrtotal * nconv * nPerc2 )
			QUANT	 := ( nQuant * nPerc2 )
//			FRETE	 := ( nFrete * nPerc2 )
			VALIPI   := ( nValIPI * nPerc2 )
			PRECOUN	 := mVRUNIT
			TITULO1  := "De " + Dtoc(mv_par03) + " ate " + Dtoc(mv_par04)
			msUnlock()
		EndIf
		
		If SC6->C6_BLQ == "R " .AND. SC6->C6_QTDENT > 0
			cGrupo := "Vendas"
			mGrupo := "1"		
			mVRTOTAL  := mVRUNIT * SC6->C6_QTDENT

			dbSelectArea("TRB")
			RecLock("TRB",.T.)
			OGRUPO   := mGrupo
			GRUPO    := cGrupo
//			VENDEMP	 := mCampo
			VENDEMP	 := Posicione( "SA3" , 1 , xFilial( "SA3" ) + SC5->C5_VEND1 , "A3_NREDUZ" )
			CLIENTE	 := SA1->A1_NREDUZ
			EMISSAO	 := SC5->C5_EMISSAO
			PEDIDO   := SC5->C5_NUM
			PEDCLI   := cPedcli
//			VEND1    := cVend
			VEND1    := Posicione( "SA3" , 1 , xFilial( "SA3" ) + SC5->C5_VEND1 , "A3_NREDUZ" )
//			VEND2    := cVend2
			PRODUTO  := cProduto
			VALOR    := ( mVrtotal * nconv * nPerc1 )
			QUANT	 := ( nQuant * nPerc1 )
//			FRETE	 := ( nFrete * nPerc1 )
			VALIPI   := ( nValIPI * nPerc1 )
			PRECOUN	 := mVRUNIT
			TITULO1  := "De " + Dtoc(mv_par03) + " ate " + Dtoc(mv_par04)
			msUnlock()

			If lDoisV
				dbSelectArea("TRB")
				RecLock("TRB",.T.)
				OGRUPO   := mGrupo
				GRUPO    := cGrupo
//				VENDEMP	 := mCampo
				VENDEMP	 := Posicione( "SA3" , 1 , xFilial( "SA3" ) + SC5->C5_VEND2 , "A3_NREDUZ" )
				CLIENTE	 := SA1->A1_NREDUZ
				EMISSAO	 := SC5->C5_EMISSAO
				PEDIDO   := SC5->C5_NUM
				PEDCLI   := cPedcli
//				VEND1    := cVend
				VEND1    := Posicione( "SA3" , 1 , xFilial( "SA3" ) + SC5->C5_VEND2 , "A3_NREDUZ" )
//				VEND2    := cVend2
				PRODUTO  := cProduto
				VALOR    := ( mVrtotal * nconv * nPerc2 )
				QUANT	 := ( nQuant * nPerc2 )
//				FRETE	 := ( nFrete * nPerc2 )
				VALIPI   := ( nValIPI * nPerc2 )
				PRECOUN	 := mVRUNIT
				TITULO1  := "De " + Dtoc(mv_par03) + " ate " + Dtoc(mv_par04)
				msUnlock()
			EndIf

		Endif				
		
		dbSelectArea("SC6")
		dbSkip()
	Enddo
	dbSelectArea("SC5")
	dbSkip()
Enddo




ferase("\SIGAADV\DATVEN.DBF")
dbselectarea("TRB")
dbgotop()
//COPY TO "\SIGAADV\FATVEN.DBF"
Processa({||CpyS2T("\SIGAADV\FATVEN.DBF","C:\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
ferase("\SIGAADV\FATVEN.DBF")
TRB->(DBCLOSEAREA())

mTESTE := "1;0;1;GIS"  // "EM DISCO;ATUALIZA;1 COPIA;NOME REL."
CALLCRYS("VENDAVX",,mTESTE)

Set SoftSeek Off
Return

// *----------------------------------------------------------------------------
Static Function AjustaSX1()
aPerg    := {}
cPerg    := PadR( 'VENDAV' , Len( SX1->X1_GRUPO ) )

Aadd( aPerg , { "Do Produto          ?" , "C" , 15 , "SB1"})
Aadd( aPerg , { "Ate Produto         ?" , "C" , 15 , "SB1"})
Aadd( aPerg , { "Da Data             ?" , "D" , 08 , "   "})
Aadd( aPerg , { "Ate Data            ?" , "D" , 08 , "   "})
Aadd( aPerg , { "Ignora CFOPs        :" , "C" , 40 , "   "})
Aadd( aPerg , { "Status Ped (SEPDICO)?" , "C" , 07 , "   "})
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
		SX1->(MsUnLock())
	EndIf
Next nXX
Return Nil
