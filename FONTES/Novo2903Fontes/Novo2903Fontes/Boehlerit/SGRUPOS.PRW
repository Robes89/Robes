#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

// Rotina		: SGRUPOS
// Descrição	: Rel. por Super Grupos (Faturamento / Carteira / Estoque )
// Data			: 10/05/06
// Autor        : Daniel Gondran

User Function SGRUPOS()

// mv_par01 - Mes
// mv_par02 - Ano
// mv_par03 - Tipo de relatório : Faturamento / Carteira / Estoque

//cPerg := "SGRUPO"
 cPerg    := PadR( 'SGRUPO' , Len( SX1->X1_GRUPO ) )
AjustaSX1()
Pergunte(cPerg,.F.)

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Super Grupos"
@ 70,080 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
@ 70,118 BMPBUTTON TYPE 1 ACTION OkProc()
@ 70,156 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
@ 23,14 SAY "Imprime os relatórios por super grupos de faturamento, carteira e" size 200,10
@ 33,14 SAY "estoque" size 200,10
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

iData 	 := ctod("01/"+StrZero(mv_par01,2)+"/"+StrZero(mv_par02,4))
If mv_par01==12
	fData := ctod("31/12/"+StrZero(mv_par02,4))
Else
	fData := ctod("01/"+StrZero(mv_par01+1,2)+"/"+StrZero(mv_par02,4))
Endif


If MV_PAR03 == 1 // FATURAMENTO
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
	aAdd(aStru,{"VALORFAT"   ,"N",14,2})
	aAdd(aStru,{"VALORPED"   ,"N",14,2})
	aAdd(aStru,{"PEDIDO"     ,"C",06,0})
	
	//cArq := CriaTrab(aStru,.T.)
	//dbUseArea(.T.,,cArq,"TRB",.T.)
	//cInd := CriaTrab(NIL,.F.)
	oTemptable := FWTemporaryTable():New( "TRB")
	oTemptable:SetFields( aStru )
	oTempTable:AddIndex("index1", {"NOTA"} )
	oTempTable:Create()
	
	aEmps 	 := {"BO","FE","KI","NI","ON","BR","BI","MT"}
	aEmpresa := {"BOEHLERIT","FETTE","KIENINGER","NIPPON","ONSRUD","FAB. BRASIL","BILZ","MORRIS TOOLING"}
	mvrtotal2:= 0
	
	//Set SoftSeek On
	
	dbselectarea("SD2")
	dbSetOrder(5)
	ProcRegua(LastRec())
	dbSeek(xFilial("SD2")+dtos(idata),.t.)
	DO WHILE !EOF() .AND. D2_FILIAL == xFilial("SD2") .and. D2_EMISSAO <= fData
		IncProc( "Processando vendas dia » " + DtoC( SD2->D2_EMISSAO ) )
		
		If Year(D2_EMISSAO)>2004
			dbSelectArea("SF4")
			dbSetOrder(1)
			dbSeek(xFilial("SF4") + SD2->D2_TES)
			If F4_DUPLIC == "N" .OR. F4_CF $ "5551" .or. SD2->D2_TIPO == "D"
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
		
		// Tratamento para o 000009 - Paulo e o 000010 - Rogerio (70/30)
		lDoisV := .F.
		nPerc1 := 100
		nPerc2 := 100
		cVend2 := ""
		dbSelectArea("SD2")

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
		
		
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1") + SD2->D2_CLIENTE + SD2->D2_LOJA)
		
		dbSelectArea("SF4")
		dbSetOrder(1)
		dbSeek(xFilial("SF4") + SD2->D2_TES)
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
		
		mvar := 0
		mVRTOTAL	:= SD2->D2_TOTAL - SD2->D2_VALICM - SD2->D2_VALIMP1 - SD2->D2_VALIMP2 - SD2->D2_VALIMP3 - SD2->D2_VALIMP4 - SD2->D2_VALIMP5 - SD2->D2_VALIMP6
		mVRTOTAL2	:= mVRTOTAL
		
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1") + SD2->D2_CLIENTE + SD2->D2_LOJA)
		
		dbSelectArea("TRB")
		RecLock("TRB",.T.)
		NOTA	 := SD2->D2_DOC
		CLIENTE	 := SA1->A1_NREDUZ
		ITEM	 := SD2->D2_ITEM
		EMISSAO	 := SD2->D2_EMISSAO
		VEND1    := mcampo // cVend
		//	VEND2    := cVend2							//	wilson - 06/05/05
		PRODUTO  := SD2->D2_COD
		CODLMT	 := SD2->D2_CODLMT
		ESPECIF  := IF( Left( SD2->D2_COD , 2 ) == "KI" , Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DENOM") , "" )
		QTDADE	 := SD2->D2_QUANT * (nPerc1 / 100)
		VALORFAT := mVrtotal * (nPerc1 / 100)
		VALORPED := mVrtotal2* (nPerc1 / 100)
		PEDIDO	 := SD2->D2_PEDIDO
		//	MARCA    := mEmpresa
		
		//	TRB->TES		:= SD2->D2_TES
		//	TRB->CUSTO		:= SD2->D2_CUSTO1 * (nPerc1 / 100)
		
		msUnlock()
		
		dbSelectArea("SD2")
		dbSkip()
	Enddo
	
	dbselectarea("SD1")
	dbSetOrder(6)
	ProcRegua(LastRec())
	dbSeek(xFilial("SD1")+dtos(idata),.t.)
	DO WHILE !EOF() .AND. D1_FILIAL == xFilial("SD1") .and. D1_DTDIGIT <= fData
		IncProc( "Processando dev.vendas dia » " + DtoC( SD1->D1_DTDIGIT ) )
		
		If SD1->D1_TIPO <> "D"
			dbSkip()
			Loop
		Endif
		dbSelectArea("SF4")
		dbSetOrder(1)
		dbSeek(xFilial("SF4") + SD1->D1_TES)
		If F4_DUPLIC == "N" .OR. F4_CF $ "5551"
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
		// Tratamento para o 000009 - Paulo e o 000010 - Rogerio (70/30)
		lDoisV := .F.
		nPerc1 := 100
		nPerc2 := 100
		
		dbSelectArea("SD1")
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
		//	VEND2	 := cVend2						//	wilson - 06/05/05
		PRODUTO  := SD1->D1_COD
		CODLMT	 := SD1->D1_CODLMT
		ESPECIF  := IF( Left( SD1->D1_COD , 2 ) == "KI" , Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_DENOM") , "" )
		QTDADE	 := SD1->D1_QUANT * (nPerc1 / 100)
		VALORFAT := mVrtotal * (nPerc1 / 100)
		//	MARCA    := mEmpresa
		
		//	TRB->TES		:= SD1->D1_TES
		//	TRB->CUSTO		:= ( SD1->D1_CUSTO * (nPerc1 / 100) ) *-1
		
		msUnlock()
		
		dbSelectArea("SD1")
		dbSkip()
	Enddo
	
	ferase("\SIGAADV\SAIDAF.DBF")
	dbselectarea("TRB")
	dbgotop()
	//COPY TO "\SIGAADV\SAIDAF.DBF" VIA "DBFCDXADS"
	Processa({||CpyS2T("\SIGAADV\SAIDAF.DBF","C:\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
	ferase("\SIGAADV\SAIDAF.DBF")
	TRB->(DBCLOSEAREA())
Endif




If MV_PAR03 == 2 // VENDAS
	aStru := {}
	aAdd(aStru,{"PEDIDO"     ,"C",06,0})
	aAdd(aStru,{"CLIENTE"    ,"C",20,0})
	aAdd(aStru,{"STATPED"    ,"C",01,0})
	aAdd(aStru,{"EMISSAO"    ,"D",08,0})
	aAdd(aStru,{"VENDEDOR"   ,"C",20,0})
	aAdd(aStru,{"PRODUTO"    ,"C",15,0})
	aAdd(aStru,{"CODLMT"     ,"C",46,0})
	aAdd(aStru,{"EMPRESA"    ,"C",20,0})
	aAdd(aStru,{"QUANT"      ,"N",14,2})
	aAdd(aStru,{"VALOR"      ,"N",14,2})
	aAdd(aStru,{"REGIAO"     ,"C",03,0})
	aAdd(aStru,{"AREA"       ,"C",06,0})
	
	oTemptable := FWTemporaryTable():New( "TRB")
	oTemptable:SetFields( aStru )
	oTempTable:AddIndex("index1", {"PEDIDO"} )
	oTempTable:Create()

	//cArq := CriaTrab(aStru,.T.)
	//dbUseArea(.T.,,cArq,"TRB",.T.)
	//cInd := CriaTrab(NIL,.F.)
	
	aEmps 	 := {"BO","FE","KI","NI","ON","BR","BI","MT"}
	aEmpresa := {"BOEHLERIT","FETTE","KIENINGER","NIPPON","ONSRUD","FAB. BRASIL","BILZ","MORRIS TOOLING"}
	
	dbselectarea("SC5")
	dbSetOrder(2)
	ProcRegua(LastRec())
	dbSeek(xFilial("SC5")+dtos(idata),.t.)
	DO WHILE !EOF() .AND. C5_FILIAL == xFilial("SC5") .and. C5_EMISSAO <= fData
		IncProc("Processando dia » " + DtoC( SC5->C5_EMISSAO ) )
		If !(C5_STPAD $ "SP")
			dbSkip()
			loop
		Endif
		SA1->( dbSetOrder(1) )
		SA1->( dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI) )
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
		dbSelectArea("SC6")
		dbSetOrder(1)
		dbSeek(xFilial("SC6") + SC5->C5_NUM)
		do While !Eof() .and. C6_FILIAL == xFilial("SC6") .and. C6_NUM == SC5->C5_NUM
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
			nIndice := Ascan(aEmps,Left(SC6->C6_PRODUTO,2))
			If nIndice == 0
				mCampo := "OUTROS              "
				mOrdem := "7"
			Else
				mCampo := Padr(aEmpresa[nIndice],20)
				mOrdem := StrZero(nIndice,1)
			Endif

			dbSelectArea("SB1")
			dbSetOrder(1)
			dbSeek(xFIlial("SB1") + SC6->C6_PRODUTO)
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
			mVRTOTAL  := mVRUNIT * SC6->C6_QTDVEN
		
			nIndice   := Ascan(aEmps,Left(SC6->C6_PRODUTO,2))
			If nIndice == 0
				mEmpresa := "OUTROS              "
			Else
				mEmpresa := Padr(aEmpresa[nIndice],20)
			Endif
			
			dbSelectArea("TRB")
			RecLock("TRB",.T.)
			PEDIDO	 := SC5->C5_NUM
			CLIENTE	 := SA1->A1_NREDUZ			//SC5->C5_NOMECLI
			STATPED  := SC5->C5_STPAD
			EMISSAO	 := SC5->C5_EMISSAO
			VENDEDOR := SC5->C5_NOMEVEN
			PRODUTO  := SC6->C6_PRODUTO
			CODLMT	 := SC6->C6_CODLMT
			QUANT	 := SC6->C6_QTDVEN
			VALOR    := mVRTOTAL * nConv
			EMPRESA  := mEmpresa
			AREA	 := SA1->A1_AREA
			REGIAO	 := SA1->A1_REGIAO
			
			msUnlock()
			
			
			dbSelectArea("SC6")
			dbSkip()
		Enddo
		dbSelectArea("SC5")
		dbSkip()
	Enddo
	
	ferase("\SIGAADV\SAIDAV.DBF")
	dbselectarea("TRB")
	dbgotop()
	//COPY TO "\SIGAADV\SAIDAV.DBF" VIA "DBFCDXADS"
	Processa({||CpyS2T("\SIGAADV\SAIDAV.DBF","C:\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
	ferase("\SIGAADV\SAIDAV.DBF")
	TRB->(DBCLOSEAREA())
Endif

If MV_PAR03 == 3 // ESTOQUE
	dbSelectArea("SB9")
	dbSetORder(1)
	_cQuery := "SELECT SB9.B9_COD,SB9.B9_QINI,SB9.B9_VINI1 FROM SB9010 SB9"
	_cQuery += " WHERE B9_DATA = '" + DTOS(fData) + "'" 
	_cQuery += " AND SB9.D_E_L_E_T_ = ' '"	
	TCQUERY _cQuery NEW ALIAS "TRQ"     
	dbSelectArea("TRQ")
	dbgotop()
	If Eof()
		Alert ("Virada de Saldos ainda não processada para o mês " + StrZero(mv_par01) + ". Impossível continuar")
		TRQ->(DBCLOSEAREA())		
		Return
	Endif
	//COPY TO "\SIGAADV\SAIDAE.DBF" VIA "DBFCDXADS"
	Processa({||CpyS2T("\SIGAADV\SAIDAE.DBF","C:\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
	ferase("\SIGAADV\SAIDAE.DBF")
	TRQ->(DBCLOSEAREA())
Endif

Set SoftSeek Off
Return

// *----------------------------------------------------------------------------
Static Function AjustaSX1()
aPerg    := {}
//cPerg    := "SGRUPO"

Aadd( aPerg , { "Mes Referencia      ?" , "N" , 02 , "   "})
Aadd( aPerg , { "Ano Referencia      ?" , "N" , 04 , "   "})
Aadd( aPerg , { "Tipo de Relatório   ?" , "N" , 01 , "   "})

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
			SX1->X1_DEF01 := "Faturamento"
			SX1->X1_DEF02 := "Carteira"
			SX1->X1_DEF03 := "Estoque"
		Endif
		SX1->(MsUnLock())
	EndIf
Next nXX
Return Nil
