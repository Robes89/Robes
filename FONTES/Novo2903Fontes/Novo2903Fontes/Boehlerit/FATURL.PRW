#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

// Rotina		: FATURL
// Descrição	: Faturamento Liquido
// Data			: 20/01/05
// Autor        : Daniel Gondran

//Alterado em 03_09_07 Fernando
//Incluir C6_CODCLI no arquivo SAIDAF.DBF
//27/11/08 - Fernando  - Incluir BILZ

User Function FATURL()
	PRIVATE cArq 
	PRIVATE cArq2
	Private c_DirDocs    := GetTempPath()
	Private c_Extensao   := ".csv"
    Private oProcess 


	// mv_par01 - Do  Produto
	// mv_par02 - Até Produto
	// mv_par03 - Quebra (empresa / vendedor)
	// mv_par04 - Ano
	// mv_par05 - Abate Impostos
	// mv_par06 - Ignora CFOPs
	// mv_par07 - Da data
	// mv_par08 - Ate data
	// mv_par09 - Imprime var. cambial (sim / nao)
	// mv_par10 - Abate IPI
	// mv_par11 - Abate ICM
	// mv_par12 - Abate PIS
	// mv_par13 - Abate COF

	cPerg := PadR( "FATURL" , Len( SX1->X1_GRUPO ) )

	//AjustaSX1()
	Pergunte(cPerg,.F.)

	@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Faturamento Liquido Anual"
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

	////Processa( {|| Runproc() } , "Gerando Arquivo" )
     oProcess := MsNewProcess():New( { ||  Runproc(@oProcess, @lEnd)  } ,  "Gerando Arquivo..." , "Aguarde..." , .F. )
     oProcess:Activate()	
     
Return

//*******************************************************************************( INICIO )
STATIC FUNCTION Runproc(oProcess, lEnd)
	Local oTempTable
	Local aStru		:= {}
	Local aStru1	:= {}
	Local cAlias1	:= "TRC"               
	Local cAlias2	:= "TRB"
	Local _nX
	Local kkk

	Local _oExcel   := Nil

	Local _cPlan1   := ""
	Local _cTab1    := _cPlan1

	Local _cPlan2   := ""
	Local _cTab2    := _cPlan2
	Loca _nTotR1   :=  0
	
	oTempTable := FWTemporaryTable():New( cAlias1 )

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

	aAdd(aStru,{"REAL201"     ,"N",14,2})
	aAdd(aStru,{"REAL202"     ,"N",14,2})
	aAdd(aStru,{"REAL203"     ,"N",14,2})
	aAdd(aStru,{"REAL204"     ,"N",14,2})
	aAdd(aStru,{"REAL205"     ,"N",14,2})
	aAdd(aStru,{"REAL206"     ,"N",14,2})
	aAdd(aStru,{"REAL207"     ,"N",14,2})
	aAdd(aStru,{"REAL208"     ,"N",14,2})
	aAdd(aStru,{"REAL209"     ,"N",14,2})
	aAdd(aStru,{"REAL210"     ,"N",14,2})
	aAdd(aStru,{"REAL211"     ,"N",14,2})
	aAdd(aStru,{"REAL212"     ,"N",14,2})
	aAdd(aStru,{"REAL213"     ,"N",14,2})

	aAdd(aStru,{"VAR01"     ,"N",14,2})
	aAdd(aStru,{"VAR02"     ,"N",14,2})
	aAdd(aStru,{"VAR03"     ,"N",14,2})
	aAdd(aStru,{"VAR04"     ,"N",14,2})
	aAdd(aStru,{"VAR05"     ,"N",14,2})
	aAdd(aStru,{"VAR06"     ,"N",14,2})
	aAdd(aStru,{"VAR07"     ,"N",14,2})
	aAdd(aStru,{"VAR08"     ,"N",14,2})
	aAdd(aStru,{"VAR09"     ,"N",14,2})
	aAdd(aStru,{"VAR10"     ,"N",14,2})
	aAdd(aStru,{"VAR11"     ,"N",14,2})
	aAdd(aStru,{"VAR12"     ,"N",14,2})
	aAdd(aStru,{"VAR13"     ,"N",14,2})

	aAdd(aStru,{"TITULO1"    ,"C",52,0})

	oTemptable:SetFields( aStru )
	oTempTable:AddIndex("indice1", {"VENDEMP"} )
	//------------------
	//Criação da tabela
	//------------------
	oTempTable:Create()

	/*
	cArq := CriaTrab(aStru,.T.)
	dbUseArea(.T.,,cArq,"TRC",.T.)
	cInd := CriaTrab(NIL,.F.)
	IndRegua("TRC",cInd,"VENDEMP",,,"Selecionando Registros...")
	*/

	oTempTable := FWTemporaryTable():New( cAlias2 )

	aAdd(aStru1,{"NOTA"       ,"C",09,0})
	aAdd(aStru1,{"CLIENTE"    ,"C",20,0})
	aAdd(aStru1,{"ITEM"       ,"C",03,0})
	aAdd(aStru1,{"EMISSAO"    ,"D",10,0})
	aAdd(aStru1,{"VEND1"      ,"C",20,0})
	aAdd(aStru1,{"VEND2"      ,"C",20,0})
	aAdd(aStru1,{"PRODUTO"    ,"C",15,0})
	aAdd(aStru1,{"CODLMT"     ,"C",46,0})
	aAdd(aStru1,{"ESPECIF"    ,"C",60,0})
	aAdd(aStru1,{"CODCLI"	 ,"C",30,0})
	aAdd(aStru1,{"MARCA"      ,"C",20,0})
	aAdd(aStru1,{"QTDADE"     ,"N",14,3})
	aAdd(aStru1,{"VALORBRUT" ,"N",14,2})
	aAdd(aStru1,{"VALORLIQ"   ,"N",14,2})
	aAdd(aStru1,{"VALORPED"   ,"N",14,2})
	aAdd(aStru1,{"ICMS"    ,"N",14,2})
	aAdd(aStru1,{"IPI"     ,"N",14,2})
	aAdd(aStru1,{"ICMSRET" ,"N",14,2})
	aAdd(aStru1,{"PIS"     ,"N",14,2})
	aAdd(aStru1,{"COFINS"  ,"N",14,2})
	aAdd(aStru1,{"DIFAL"   ,"N",14,2})
	aAdd(aStru1,{"ICMSCOM" ,"N",14,2})
	aAdd(aStru1,{"PEDIDO"     ,"C",06,0})
	aAdd(aStru1,{"ITEMPV"     ,"C",02,0})
	aAdd(aStru1,{"REGIAO"     ,"C",03,0})
	aAdd(aStru1,{"AREA"       ,"C",06,0})
	aAdd(aStru1,{"TES"    ,"C",03,0})
	aAdd(aStru1,{"CFOP"   ,"C",05,0})
	aAdd(aStru1,{"SEGMENTO1"   ,"C",50,0})
	aAdd(aStru1,{"SEGMENTO2"   ,"C",50,0})
	aAdd(aStru1,{"CLASSIF"    ,"C",50,0})
	aAdd(aStru1,{"PEDCLI"    ,"C",15,0})
	aAdd(aStru1,{"GRUPO"    ,"C",04,0})
	aAdd(aStru1,{"SUPERGRP" ,"C",03,0})
	aAdd(aStru1,{"CLIECOD"  ,"C",06,0})
	aAdd(aStru1,{"LOJACLI" ,"C",02,0})
	aAdd(aStru1,{"NOMFANT" ,"C",20,0})
	aAdd(aStru1,{"CNPJ"    ,"C",15,0})   

	oTemptable:SetFields( aStru1 )
	//------------------
	//Criação da tabela
	//------------------
	oTempTable:Create()

	/*
	cArq2 := CriaTrab(aStru,.T.)
	dbUseArea(.T.,,cArq2,"TRB",.T.)
	cInd := CriaTrab(NIL,.F.)
	*/

	iData 	 := MV_PAR07 // ctod("01/01/"+mv_par04)
	aEmps 	 := {"BO","FE","KI","NI","ON","BI","BR","MT","HO"}
	aEmpresa := {"BOEHLERIT","FETTE","KIENINGER","NIPPON","ONSRUD","BILZ","FAB. BRASIL","MORRIS TOOLING","HORN"}
	mtit1    := "Faturamento "+Iif(mv_par05==2,"bruto","liquido")+" por " + Iif(mv_par03==1,"empresa","vendedor") + " " + mv_par04

	mvrtotal2:= 0

	abateipi := IIF(mv_par10==1,.T.,.F.)
	abateicm := IIF(mv_par11==1,.T.,.F.)
	abatepis := IIF(mv_par12==1,.T.,.F.)
	abatecof := IIF(mv_par13==1,.T.,.F.)

	//Set SoftSeek On

	dbselectarea("SD2")
	dbSetOrder(5)
	ProcRegua(LastRec())
	dbSeek(xFilial("SD2")+dtos(idata),.t.)
	DO WHILE !EOF() .AND. D2_FILIAL == xFilial("SD2") .and. D2_EMISSAO <= MV_PAR08 // Year(D2_EMISSAO) == Year(idata)
		IncProc( "Processando faturamento dia » " + DtoC( SD2->D2_EMISSAO ) )

		IF ALLTRIM( SD2->D2_COD ) == "FETTEALSV000001" .OR. ALLTRIM( SD2->D2_COD ) == "FETTEALSV000004"
			I:=0
		ENDIF     

		If Year(D2_EMISSAO)>2004
			dbSelectArea("SF4")
			dbSetOrder(1)
			dbSeek(xFilial("SF4") + SD2->D2_TES)
			//		If F4_DUPLIC == "N" .OR. F4_CF $ mv_par06 .or. SD2->D2_TIPO == "D"			// WILSON - 26/12/07
			If F4_DUPLIC == "N" .OR. AllTrim( SD2->D2_CF ) $ mv_par06 .or. SD2->D2_TIPO == "D"
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

		dbSelectArea("SF2")
		dbSetOrder(1)
		dbSeek(xFilial("SF2") + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA)

		dbSelectArea("SA3")
		dbSetOrder(1)
		dbSeek(xFilial("SA3") + SF2->F2_VEND1)

		cVend		:= SA3->A3_NREDUZ
		cCodVend1	:= SA3->A3_COD

		// Tratamento para o 000009 - Paulo e o 000010 - Rogerio (70/30)
		lDoisV := .F.
		nPerc1 := 100
		nPerc2 := 100
		cVend2 := ""               

		cPedCli := ""
		cGrupo  := ""

		If !Empty(SF2->F2_VEND2) .and. mv_par03==2
			cCodVend2	:= SF2->F2_VEND2
			lDoisV := .T.
			dbSelectArea("SA3")
			dbSetOrder(1)
			dbSeek(xFilial("SA3") + SF2->F2_VEND2)
			mCampo2 := A3_NREDUZ
			cVend2  := A3_NREDUZ
			dbSelectArea("SF2")
			If F2_VEND1 == "000009"
				nPerc1 := 70
			ElseIf F2_VEND1 $ "000010/000026"
				nPerc1 := 30
			ElseIf F2_VEND1 == "000016"
				nPerc1 := 70
			ElseIf F2_VEND1 $ "000005/000008"
				nPerc1 := 50                           
			Endif
			If F2_VEND2 == "000009"
				nPerc2 := 70
			ElseIf F2_VEND2 $ "000010/000026"
				nPerc2 := 30
			ElseIf F2_VEND2 == "000016"
				nPerc2 := 70
			ElseIf F2_VEND2 $ "000005/000008"
				nPerc2 := 50                           
			Endif

		Endif
		dbSelectArea("SD2")
		cMes     := "REAL"  + StrZero(Month(SD2->D2_EMISSAO),2)
		cMes2    := "REAL2" + StrZero(Month(SD2->D2_EMISSAO),2)
		cMes3	 := "VAR"	+ StrZero(Month(SD2->D2_EMISSAO),2)
		If mv_par03 == 2
			mCampo := cVend
			mOrdem := " "
		Else
			nIndice := Ascan(aEmps,Left(D2_COD,2))
			if nindice==7
				xxx :=1
			Endif
			If nIndice == 0
				mCampo := "OUTROS              "
				mOrdem := "8"		//ALTERADO
			Else
				mCampo := Padr(aEmpresa[nIndice],20)
				mOrdem := StrZero(nIndice,1)
			Endif
		Endif

		// wilson - 08/12/08
		// conforme Fran sempre gravar a marca
		If	( nPos	:= Ascan(aEmps,Left(D2_COD,2)) ) == 0
			mEmpresa := "OUTROS              "
		Else
			mEmpresa := Padr(aEmpresa[nPos],20)
		EndIf
		//

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
		If mv_par05 == 2
			mVRTOTAL 	:= SD2->D2_TOTAL + IIF(SD2->D2_TIPO=="P", 0 , SD2->D2_VALIPI) + SD2->D2_VALFRE
			mVRTOTAL2	:= mVRTOTAL
			If mv_par09 == 1
				dbSelectArea("SB1")
				dbSetOrder(1)
				dbSeek(xFilial("SB1") + SD2->D2_COD)

				dbSelectArea("SBM")
				dbSetOrder(1)
				dbSeek(xFilial("SBM") + SB1->B1_GRUPO )
				ORDGRSBM    := SBM->BM_ORDEM		

				if SB1->B1_SUPERGR <> space(3)
					dbSelectArea("SX5")
					dbSetOrder(1)
					dbSeek(xFilial("SX5")+"Z7"+SB1->B1_SUPERGR)
					ORDGRSBM    := SX5->X5_CHAVE
				endif

				dbSelectArea("SC5")
				dbSetORder(1)
				dbSeek(xFIlial("SC6") + SD2->D2_PEDIDO)
				//				cPedCli := SC6->C6_PEDCLI
				If SC5->C5_MOEDA <> 1
					cMoeda := "SM2->M2_MOEDA" + StrZero(SC5->C5_MOEDA,1)
					dbSelectArea("SM2")
					dbSeek(SC5->C5_EMISSAO)
					nConv  := &(cMoeda)
					If nConv == 0
						Alert ("Atenção: Cadastrar Moeda " + StrZero(SC5->C5_MOEDA,1) + " no dia " + Dtoc(SC5->C5_EMISSAO))
					Endif

					dbSelectArea("SC6")
					dbSetOrder(1)
					dbSeek(xFilial("SC6") + SD2->D2_PEDIDO + SD2->D2_ITEMPV + SD2->D2_COD)
					nIpi      := SB1->B1_IPI
					mVRUNIT   := SC6->C6_PRCVEN + Iif(lcalipi,(SC6->C6_PRCVEN * nIpi / 100),0)
					mVRTOTAL2 := ((mVRUNIT * SD2->D2_QUANT) + SD2->D2_VALFRE) * nConv   //ALTERADO REGINA
					mvar	  := iif(mvrtotal2>0,mVRTOTAL - mVRTOTAL2,0)
					cPedCli := SC6->C6_PEDCLI
				Endif
			Endif
		Else
			mVRTOTAL	:= SD2->D2_TOTAL + SD2->D2_VALFRE + iif(abateipi,0,IIF(SD2->D2_TIPO=="P", 0 , SD2->D2_VALIPI))- iif(abateicm,SD2->D2_VALICM,0) - SD2->D2_VALIMP1 - SD2->D2_VALIMP2 - SD2->D2_VALIMP3 - SD2->D2_VALIMP4 - iif(abatepis,SD2->D2_VALIMP5,0) - iif(abatecof,SD2->D2_VALIMP6,0)- iif(abateicm,SD2->D2_DIFAL,0) - iif(abateicm,SD2->D2_ICMSCOM,0)  //Alterado Regina 08/08/17
			mVRTOTAL2	:= mVRTOTAL
			If mv_par09 == 1
				dbSelectArea("SB1")
				dbSetORder(1)
				dbSeek(xFilial("SB1") + SD2->D2_COD)

				//			dbSelectArea("SBM")
				//			dbSetOrder(1)
				//			dbSeek(xFilial("SBM") + SB1->B1_GRUPO )

				dbSelectArea("SBM")
				dbSetOrder(1)
				dbSeek(xFilial("SBM") + SB1->B1_GRUPO )
				ORDGRSBM    := SBM->BM_ORDEM		

				if SB1->B1_SUPERGR <> space(3)
					dbSelectArea("SX5")
					dbSetOrder(1)
					dbSeek(xFilial("SX5")+"Z7"+SB1->B1_SUPERGR)
					ORDGRSBM    := SX5->X5_CHAVE
				endif

				dbSelectArea("SC5")
				dbSetORder(1)
				dbSeek(xFIlial("SC6") + SD2->D2_PEDIDO)
				//				cPedCli := SC6->C6_PEDCLI
				If SC5->C5_MOEDA > 1 
					cMoeda := "SM2->M2_MOEDA" + StrZero(SC5->C5_MOEDA,1)
					dbSelectArea("SM2")
					dbSeek(SC5->C5_EMISSAO)
					nConv  := &(cMoeda)
					If nConv == 0
						Alert ("Atenção: Cadastrar Moeda " + StrZero(SC5->C5_MOEDA,1) + " no dia " + Dtoc(SC5->C5_EMISSAO))
					Endif

					dbSelectArea("SC6")
					dbSetOrder(1)
					dbSeek(xFilial("SC6") + SD2->D2_PEDIDO + SD2->D2_ITEMPV + SD2->D2_COD)
					cPedCli := SC6->C6_PEDCLI
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
					nIpi := SB1->B1_IPI
					nCof := GetMV("MV_TXCOFIN")
					nPis := GetMV("MV_TXPIS")
					nPrecoIpi := SC6->C6_PRCVEN * (1 + nIpi / 100)
					mVRUNIT   := SC6->C6_PRCVEN - Iif(lCalIcm,nPrecoIpi * nIcms/100,0) - SC6->C6_PRCVEN * (Iif(lCalPis,nPis,0)+Iif(lcalcof,nCof,0))/100
					mVRTOTAL2 := ((mVRUNIT * SD2->D2_QUANT) + SD2->D2_VALFRE) * nConv
					mvar	  := iif(mvrtotal2>0,mVRTOTAL - mVRTOTAL2,0)
					cPedCli   := SC6->C6_PEDCLI
				Endif
			Endif
		Endif

		dbSelectArea("SC6")
		dbSetOrder(1)
		dbSeek(xFilial("SC6") + SD2->D2_PEDIDO + SD2->D2_ITEMPV + SD2->D2_COD)
		cPedCli := SC6->C6_PEDCLI
		cGrupov := SB1->B1_GRUPO

		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1") + SD2->D2_COD)

		//	dbSelectArea("SBM")
		//	dbSetOrder(1)
		//	dbSeek(xFilial("SBM") + SB1->B1_GRUPO )

		dbSelectArea("SBM")
		dbSetOrder(1)
		dbSeek(xFilial("SBM") + SB1->B1_GRUPO )
		ORDGRSBM    := SBM->BM_ORDEM		

		if SB1->B1_SUPERGR <> space(3)
			dbSelectArea("SX5")
			dbSetOrder(1)
			dbSeek(xFilial("SX5")+"Z7"+SB1->B1_SUPERGR)
			ORDGRSBM    := SX5->X5_CHAVE
		endif

		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1") + SD2->D2_CLIENTE + SD2->D2_LOJA)
		_cNomFant := SA1->A1_NREDUZ
		_cCnpj  := SA1->A1_CGC

		dbSelectArea("TRB")
		RecLock("TRB",.T.)
		TRB->NOTA	 := SD2->D2_DOC
		TRB->CLIENTE	 := SA1->A1_NREDUZ
		TRB->ITEM	 := SD2->D2_ITEM
		TRB->EMISSAO	 := SD2->D2_EMISSAO
		//	VEND1    := mcampo // cVend
		TRB->VEND1    := cVend
		//	VEND2    := cVend2							//	wilson - 06/05/05
		TRB->PRODUTO  := SD2->D2_COD
		IF LEFT( cNumEmp, 2 ) == "01"
			TRB->CODLMT	 := SD2->D2_CODLMT   
		ENDIF
		TRB->ESPECIF  := IF( Left( SD2->D2_COD , 2 ) == "KI" , Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DENOM") , "" )
		IF LEFT( cNumEmp, 2 ) == "01"
			TRB->CODCLI	 := Posicione("SC6",1,xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV,"C6_CODCLI")
		ENDIF
		TRB->QTDADE	 := SD2->D2_QUANT * (nPerc1 / 100)
		TRB->VALORBRUT := SD2->D2_VALBRUT
		TRB->VALORLIQ := mVrtotal * (nPerc1 / 100)
		TRB->VALORPED := mVrtotal2* (nPerc1 / 100)
		TRB->PEDIDO	 := SD2->D2_PEDIDO
		TRB->ITEMPV	 := SD2->D2_ITEMPV
		TRB->ICMS     := SD2->D2_VALICM * (nPerc1 / 100)
		TRB->IPI      := SD2->D2_VALIPI * (nPerc1 / 100)
		TRB->ICMSRET  := SD2->D2_ICMSRET
		TRB->PIS      := SD2->D2_VALIMP5
		TRB->COFINS   := SD2->D2_VALIMP6
		TRB->DIFAL    := SD2->D2_DIFAL
		TRB->ICMSCOM  := SD2->D2_ICMSCOM

		IF LEFT( cNumEmp, 2 ) == "01"
			TRB->AREA	 := SA1->A1_AREA
		ENDIF
		TRB->REGIAO	 := SA1->A1_REGIAO
		TRB->MARCA    := mEmpresa

		TRB->TES  := SD2->D2_TES
		TRB->CFOP := SD2->D2_CF
		//	TRB->CUSTO		:= SD2->D2_CUSTO1 * (nPerc1 / 100)
		IF LEFT( cNumEmp, 2 ) == "01"
			TRB->SEGMENTO1	:= Posicione( "SZG" , 1 , xFilial( "SZG" ) + SA1->A1_SEGVEN1 , "ZG_DESCRIC" )
			TRB->SEGMENTO2	:= Posicione( "SZG" , 1 , xFilial( "SZG" ) + SA1->A1_SEGVEN2 , "ZG_DESCRIC" )
			TRB->CLASSIF	:= Posicione( "SZF" , 1 , xFilial( "SZF" ) + SB1->B1_CLAEST , "ZF_DESCRIC" )
		ENDIF
		TRB->PEDCLI := cPedCli
		TRB->GRUPO  := SB1->B1_GRUPO
		//	TRB->SUPERGRP := SBM->BM_ORDEM		
		TRB->SUPERGRP := ORDGRSBM
		TRB->CLIECOD   := SD2->D2_CLIENTE
		TRB->LOJACLI  := SD2->D2_LOJA
		TRB->NOMFANT  := _cNomFant
		TRB->CNPJ     := _cCNPJ

		msUnlock()

		// ********** WILSON - INICIO - 06/05/04
		If lDoisV .and. mv_par03 == 2
			dbSelectArea("TRB")
			RecLock("TRB",.T.)
			NOTA	 := SD2->D2_DOC
			CLIENTE	 := SA1->A1_NREDUZ
			ITEM	 := SD2->D2_ITEM
			EMISSAO	 := SD2->D2_EMISSAO
			//		VEND1    := mcampo // cVend
			VEND1    := cVend2
			VEND2    := "X" //cVend2
			PRODUTO  := SD2->D2_COD
			IF LEFT( cNumEmp, 2 ) == "01"
				CODLMT	 := SD2->D2_CODLMT
			ENDIF
			ESPECIF  := IF( Left( SD2->D2_COD , 2 ) == "KI" , Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DENOM") , "" )
			IF LEFT( cNumEmp, 2 ) == "01"
				CODCLI	 := Posicione("SC6",1,xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV,"C6_CODCLI")
			ENDIF
			QTDADE	 := SD2->D2_QUANT * (nPerc2 / 100)
			VALORBRUT := SD2->D2_VALBRUT
			VALORLIQ := mVrtotal * (nPerc2 / 100)
			VALORPED := mVrtotal2* (nPerc2 / 100)
			PEDIDO	 := SD2->D2_PEDIDO
			IF LEFT( cNumEmp, 2 ) == "01"
				AREA	 := SA1->A1_AREA
			ENDIF
			REGIAO	 := SA1->A1_REGIAO
			MARCA    := mEmpresa

			//		TRB->TES		:= SD2->D2_TES
			//		TRB->CUSTO		:= SD2->D2_CUSTO1 * (nPerc2 / 100)

			TRB->TES  := SD2->D2_TES
			TRB->CFOP := SD2->D2_CF
			IF LEFT( cNumEmp, 2 ) == "01"
				TRB->SEGMENTO1	:= Posicione( "SZG" , 1 , xFilial( "SZG" ) + SA1->A1_SEGVEN1 , "ZG_DESCRIC" )
				TRB->SEGMENTO2	:= Posicione( "SZG" , 1 , xFilial( "SZG" ) + SA1->A1_SEGVEN2 , "ZG_DESCRIC" )
				TRB->CLASSIF	:= Posicione( "SZF" , 1 , xFilial( "SZF" ) + SB1->B1_CLAEST , "ZF_DESCRIC" )
			ENDIF
			TRB->PEDCLI := cPedCli
			TRB->GRUPO  := cGrupo
			//    	TRB->SUPERGRP := SBM->BM_ORDEM		
			TRB->SUPERGRP := ORDGRSBM

			msUnlock()
		EndIf
		// ********** WILSON - FINAL  - 06/05/04

		dbSelectArea("TRC")
		lAChou := dbSeek(mCampo)
		RecLock( "TRC" , !lAchou)
		VENDEMP		:= mCampo
		AORDEM  	:= mOrdem
		&(cMes)		+= mVRTOTAL  * (nPerc1 / 100)
		&(cMes2)	+= mVRTOTAL2 * (nPerc1 / 100)
		&(cMes3)    += mVar
		TITULO1     := mTit1
		If SC5->C5_VEND1 == "000016" .or. SC5->C5_VEND2 == "000016"
			xxx:=1
		Endif
		/*
		If mv_par03 == 1
		SZ5->( DbSetOrder( 1 ) )

		If SZ5->( DbSeek( xFilial( "SZ5" ) + "M" + Upper( Left( SD2->D2_COD , 2 ) ) + StrZero( Year( SD2->D2_EMISSAO ) , 4 ) ) )
		cPrev1		:= "PREV" + StrZero(Month(SD2->D2_EMISSAO),2)
		cPrev2		:= "SZ5->Z5_VALOR" + StrZero(Month(SD2->D2_EMISSAO),2)
		&(cPrev1)	:= &(cPrev2)
		EndIf

		Else
		SZ5->( DbSetOrder( 2 ) )

		If SZ5->( DbSeek( xFilial( "SZ5" ) + "V" + cCodVend1 + StrZero( Year( SD2->D2_EMISSAO ) , 4 ) ) )
		cPrev1		:= "PREV" + StrZero(Month(SD2->D2_EMISSAO),2)
		cPrev2		:= "SZ5->Z5_VALOR" + StrZero(Month(SD2->D2_EMISSAO),2)
		&(cPrev1)	:= &(cPrev2)
		EndIf

		EndIf
		TRC->( MsUnLock() )
		*/
		If lDoisV .and. mv_par03 == 2
			lAChou := dbSeek(mCampo2)
			RecLock( "TRC" , !lAchou)
			VENDEMP		:= mCampo2
			AORDEM  	:= mOrdem
			&(cMes)		+= mVRTOTAL * (nPerc2 / 100)
			TITULO1     := mTit1
			If SC5->C5_VEND1 == "000016" .or. SC5->C5_VEND2 == "000016"
				xxx:=1
			Endif

			If mv_par03 == 1
				SZ5->( DbSetOrder( 1 ) )

				If SZ5->( DbSeek( xFilial( "SZ5" ) + "M" + Upper( Left( SD2->D2_COD , 2 ) ) + StrZero( Year( SD2->D2_EMISSAO ) , 4 ) ) )
					cPrev1		:= "PREV" + StrZero(Month(SD2->D2_EMISSAO),2)
					cPrev2		:= "SZ5->Z5_VALOR" + StrZero(Month(SD2->D2_EMISSAO),2)
					&(cPrev1)	:= &(cPrev2)
				EndIf

			Else
				SZ5->( DbSetOrder( 2 ) )

				If SZ5->( DbSeek( xFilial( "SZ5" ) + "V" + cCodVend2 + StrZero( Year( SD2->D2_EMISSAO ) , 4 ) ) )
					cPrev1		:= "PREV" + StrZero(Month(SD2->D2_EMISSAO),2)
					cPrev2		:= "SZ5->Z5_VALOR" + StrZero(Month(SD2->D2_EMISSAO),2)
					&(cPrev1)	:= &(cPrev2)
				EndIf

			EndIf
			TRC->( MsUnLock() )

		Endif
		dbSelectArea("SD2")
		dbSkip()
	Enddo

	dbselectarea("SD1")
	dbSetOrder(6)
	ProcRegua(LastRec())
	dbSeek(xFilial("SD1")+dtos(idata),.t.)
	DO WHILE !EOF() .AND. D1_FILIAL == xFilial("SD1") .and. D1_DTDIGIT <= mv_par08 // Year(D1_DTDIGIT) == Year(idata)
		IncProc( "Processando dev. vendas dia » " + DtoC( SD1->D1_DTDIGIT ) )

		IF ALLTRIM( SD1->D1_COD ) == "FETTEALSV000001" .OR. ALLTRIM( SD1->D1_COD ) == "FETTEALSV000004"
			I:=0
		ENDIF

		If SD1->D1_TIPO <> "D"
			dbSkip()
			Loop
		Endif
		dbSelectArea("SF4")
		dbSetOrder(1)
		dbSeek(xFilial("SF4") + SD1->D1_TES)
		//	If F4_DUPLIC == "N" .OR. F4_CF $ mv_par06					// WILSON - 26/12/07
		If F4_DUPLIC == "N" .OR. AllTrim( SD1->D1_CF ) $ mv_par06
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
			IF LEFT( cNumEmp, 2 ) == "01"
				cVend 	 := C5_NOMEVEN
			ELSE
				cVend := ""
			ENDIF   
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
		If !Empty(IIF(cPEDOUCLI == "P",SC5->C5_VEND2,SA1->A1_VEND2)) .and. mv_par03==2
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
		cMes     := "REAL" + StrZero(Month(D1_DTDIGIT),2)
		If mv_par03 == 2
			mCampo := cVend
			mOrdem := " "
		Else
			nIndice := Ascan(aEmps,Left(D1_COD,2))
			If nIndice == 0
				mCampo := "OUTROS              "
				mOrdem := "8"	//ALTERADO
			Else
				mCampo := Padr(aEmpresa[nIndice],20)
				mOrdem := StrZero(nIndice,1)
			Endif
		Endif

		// wilson - 08/12/08
		// conforme Fran sempre gravar a marca
		If	( nPos	:= Ascan(aEmps,Left(D1_COD,2)) ) == 0
			mEmpresa := "OUTROS              "
		Else
			mEmpresa := Padr(aEmpresa[nPos],20)
		EndIf
		//

		If mv_par05 == 2
			//		mVRTOTAL 	:= (SD1->D1_TOTAL + iif(abateipi,0,SD1->D1_VALIPI) + SD1->D1_VALFRE) * (-1)
			mVRTOTAL 	:= (SD1->(D1_TOTAL-D1_VALDESC) + iif(abateipi,0,SD1->D1_VALIPI) + SD1->D1_VALFRE) * (-1)
			ICMS        := SD1->D1_VALICM * (-1)
			IPI         := SD1->D1_VALIPI * (-1)
			ICMSRET     := SD1->D1_ICMSRET * (-1)
			PIS         := SD1->D1_VALIMP5 * (-1)
			COFINS      := SD1->D1_VALIMP6 * (-1)

		Else
			//		mVRTOTAL	:= (SD1->D1_TOTAL - iif(abateicm,SD1->D1_VALICM,0) - SD1->D1_VALIMP1 - SD1->D1_VALIMP2 - SD1->D1_VALIMP3 - SD1->D1_VALIMP4 - iif(abatepis,SD1->D1_VALIMP5,0) - iif(abatecof,SD1->D1_VALIMP6,0)) * (-1)
			mVRTOTAL	:= (SD1->(D1_TOTAL-D1_VALDESC) - iif(abateicm,SD1->D1_VALICM,0) - SD1->D1_VALIMP1 - SD1->D1_VALIMP2 - SD1->D1_VALIMP3 - SD1->D1_VALIMP4 - iif(abatepis,SD1->D1_VALIMP5,0) - iif(abatecof,SD1->D1_VALIMP6,0)) * (-1)
			ICMS        := SD1->D1_VALICM * (-1)
			IPI         := SD1->D1_VALIPI * (-1)
			ICMSRET     := SD1->D1_ICMSRET * (-1)
			PIS         := SD1->D1_VALIMP5 * (-1)
			COFINS      := SD1->D1_VALIMP6 * (-1)

		Endif

		dbSelectArea("SC6")
		dbSetOrder(1)
		dbSeek(xFilial("SC6") + SD1->D1_PEDIDO + SD1->D1_ITEMPC )
		cPedCli := SC6->C6_PEDCLI

		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1") + SD1->D1_COD)
		//////////////////
		//	dbSelectArea("SBM")
		//	dbSetOrder(1)
		//	dbSeek(xFilial("SBM") + SB1->B1_GRUPO )

		dbSelectArea("SBM")
		dbSetOrder(1)
		dbSeek(xFilial("SBM") + SB1->B1_GRUPO )
		ORDGRSBM    := SBM->BM_ORDEM		

		if SB1->B1_SUPERGR <> space(3)
			dbSelectArea("SX5")
			dbSetOrder(1)
			dbSeek(xFilial("SX5")+"Z7"+SB1->B1_SUPERGR)
			ORDGRSBM    := SX5->X5_CHAVE
		endif

		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1") + SD1->D1_FORNECE + SD1->D1_LOJA)
		_cNomFant := SA1->A1_NREDUZ
		_cCnpj  := SA1->A1_CGC

		dbSelectArea("TRB")
		RecLock("TRB",.T.)
		TRB->NOTA	 := SD1->D1_DOC
		TRB->CLIENTE	 := SA1->A1_NREDUZ
		TRB->ITEM	 := SD1->D1_ITEM
		TRB->EMISSAO	 := SD1->D1_DTDIGIT
		//	VEND1    := mCampo
		TRB->VEND1    := cVend
		//	VEND2	 := cVend2						//	wilson - 06/05/05
		TRB->PRODUTO  := SD1->D1_COD
		IF LEFT( cNumEmp, 2 ) == "01"
			TRB->CODLMT	 := SD1->D1_CODLMT
		ENDIF   
		TRB->ESPECIF  := IF( Left( SD1->D1_COD , 2 ) == "KI" , Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_DENOM") , "" )
		IF LEFT( cNumEmp, 2 ) == "01"
			TRB->CODCLI	 := Posicione("SC6",1,xFilial("SC6")+SD1->D1_PEDIDO+SD1->D1_ITEMPV,"C6_CODCLI")
		ENDIF
		TRB->QTDADE	 := (SD1->D1_QUANT * (nPerc1 / 100)) * -1		//Fernando 28/03/08 -- Inserir -1
		TRB->VALORBRUT := SD1->D1_TOTAL + SD1->D1_VALIPI + SD1->D1_ICMSRET + SD1->D1_VALFRE + SD1->D1_SEGURO + SD1->D1_DESPESA  * (-1)
		TRB->VALORLIQ := mVrtotal * (nPerc1 / 100)
		TRB->ICMS        := SD1->D1_VALICM * (-1)
		TRB->IPI         := SD1->D1_VALIPI * (-1)
		TRB->ICMSRET     := SD1->D1_ICMSRET * (-1)
		TRB->PIS         := SD1->D1_VALIMP5 * (-1)
		TRB->COFINS      := SD1->D1_VALIMP6 * (-1)


		IF LEFT( cNumEmp, 2 ) == "01"
			TRB->AREA	 := SA1->A1_AREA
		ENDIF
		TRB->REGIAO	 := SA1->A1_REGIAO
		TRB->MARCA    := mEmpresa

		//	TRB->TES		:= SD1->D1_TES
		//	TRB->CUSTO		:= ( SD1->D1_CUSTO * (nPerc1 / 100) ) *-1

		TRB->TES  := SD1->D1_TES
		TRB->CFOP := SD1->D1_CF
		IF LEFT( cNumEmp, 2 ) == "01"
			TRB->SEGMENTO1	:= Posicione( "SZG" , 1 , xFilial( "SZG" ) + SA1->A1_SEGVEN1 , "ZG_DESCRIC" )
			TRB->SEGMENTO2	:= Posicione( "SZG" , 1 , xFilial( "SZG" ) + SA1->A1_SEGVEN2 , "ZG_DESCRIC" )
			TRB->CLASSIF	:= Posicione( "SZF" , 1 , xFilial( "SZF" ) + SB1->B1_CLAEST , "ZF_DESCRIC" )
		ENDIF                            
		TRB->PEDCLI := cPedCli
		TRB->GRUPO  := SB1->B1_GRUPO
		//	TRB->SUPERGRP := SBM->BM_ORDEM		
		TRB->SUPERGRP := ORDGRSBM
		TRB->CLIECOD   := SD1->D1_FORNECE
		TRB->LOJACLI  := SD1->D1_LOJA
		TRB->NOMFANT  := _cNomFant
		TRB->CNPJ     := _cCNPJ

		msUnlock()

		// ********** WILSON - INICIO - 06/05/04
		If lDoisV .and. mv_par03 == 2
			dbSelectArea("TRB")
			RecLock("TRB",.T.)
			NOTA	 := SD1->D1_DOC
			CLIENTE	 := SA1->A1_NREDUZ
			ITEM	 := SD1->D1_ITEM
			EMISSAO	 := SD1->D1_DTDIGIT
			//		VEND1    := cVend
			VEND1    := cVend2
			VEND2	 := "X" //cVend2
			PRODUTO  := SD1->D1_COD
			IF LEFT( cNumEmp, 2 ) == "01"
				CODLMT	 := SD1->D1_CODLMT
			ENDIF   
			ESPECIF  := IF( Left( SD1->D1_COD , 2 ) == "KI" , Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_DENOM") , "" )
			IF LEFT( cNumEmp, 2 ) == "01"
				CODCLI	 := Posicione("SC6",1,xFilial("SC6")+SD1->D1_PEDIDO+SD1->D1_ITEMPV,"C6_CODCLI")
			ENDIF
			QTDADE	 := (SD1->D1_QUANT * (nPerc2 / 100)) * -1		//Fernando 28/03/08 -- Inserir -1
			VALORBRUT := SD1->D1_TOTAL + SD1->D1_VALIPI +SD1->D1_ICMSRET + SD1->D1_VALFRE + SD1->D1_SEGURO + SD1->D1_DESPESA  * (-1) 
			VALORLIQ := mVrtotal * (nPerc2 / 100)
			ICMS        := SD1->D1_VALICM * (-1)
			IPI         := SD1->D1_VALIPI * (-1)
			ICMSRET     := SD1->D1_ICMSRET * (-1)
			PIS         := SD1->D1_VALIMP5 * (-1)
			COFINS      := SD1->D1_VALIMP6 * (-1)

			IF LEFT( cNumEmp, 2 ) == "01"
				AREA	 := SA1->A1_AREA
			ENDIF
			REGIAO	 := SA1->A1_REGIAO
			MARCA    := mEmpresa

			//		TRB->TES		:= SD1->D1_TES
			//		TRB->CUSTO		:= ( SD1->D1_CUSTO * (nPerc2 / 100) ) * -1

			TRB->TES  := SD1->D1_TES
			TRB->CFOP := SD1->D1_CF
			IF LEFT( cNumEmp, 2 ) == "01"
				TRB->SEGMENTO1	:= Posicione( "SZG" , 1 , xFilial( "SZG" ) + SA1->A1_SEGVEN1 , "ZG_DESCRIC" )
				TRB->SEGMENTO2	:= Posicione( "SZG" , 1 , xFilial( "SZG" ) + SA1->A1_SEGVEN2 , "ZG_DESCRIC" )
				TRB->CLASSIF	:= Posicione( "SZF" , 1 , xFilial( "SZF" ) + SB1->B1_CLAEST , "ZF_DESCRIC" )
			ENDIF
			TRB->PEDCLI := cPedCli
			TRB->GRUPO  := SB1->B1_GRUPO
			//    	TRB->SUPERGRP := SBM->BM_ORDEM		
			TRB->SUPERGRP := ORDGRSBM
			msUnlock()

		EndIf
		// ********** WILSON - FINAL  - 06/05/04

		dbSelectArea("TRC")
		lAChou := dbSeek(mCampo)
		RecLock( "TRC" , !lAchou)
		VENDEMP		:= mCampo
		AORDEM  	:= mOrdem
		&(cMes)		+= mVRTOTAL * (nPerc1 / 100)
		TITULO1     := mTit1
		TRC->( MsUnLock() )
		If lDoisV .and. mv_par03 == 2
			lAChou := dbSeek(mCampo2)
			RecLock( "TRC" , !lAchou)
			VENDEMP		:= mCampo2
			AORDEM  	:= mOrdem
			&(cMes)		+= mVRTOTAL * (nPerc2 / 100)
			TITULO1     := mTit1
			TRC->( MsUnLock() )
		Endif

		dbSelectArea("SD1")
		dbSkip()
	Enddo

	If mv_par03 == 1 
		IF LEFT( cNumEmp, 2 ) == "01"


			SZ5->( DbSetOrder( 1 ) )
			SZ5->( DbSeek( xFilial( "SZ5" ) + "M" ) )

			While !SZ5->( Eof() ) .and. SZ5->Z5_FILIAL == xFilial( "SZ5" ) .and. SZ5->Z5_TIPO == "M"
				cMarcax	:= IF( SZ5->Z5_MARCA == "BR" , "FA" , SZ5->Z5_MARCA )

				If Str( SZ5->Z5_ANO , 4 ) = mv_par04 //.and. !TRC->( DbSeek( cMarcax ) )

					nIndice := Ascan(aEmps,SZ5->Z5_MARCA)
					If nIndice == 0
						mCampo := "OUTROS              "
						mOrdem := "8"		//ALTERADO
					Else
						mCampo := Padr(aEmpresa[nIndice],20)
						mOrdem := StrZero(nIndice,1)
					Endif

					dbSelectArea("TRC")
					//			lAchou := TRC->( DbSeek( cMarcax ) )
					lAChou := dbSeek(mCampo)
					RecLock( "TRC" , !lAchou)
					VENDEMP	:= mCampo
					AORDEM  := mOrdem
					TITULO1	:= mTit1

					For kkk := 1 to 12
						cPrev1	:= "PREV" + StrZero(kkk,2)
						cPrev2	:= "SZ5->Z5_VALOR" + StrZero(kkk,2)
						&(cPrev1)	:= &(cPrev2)
					Next
					TRC->( MsUnLock() )
				EndIf

				SZ5->( DbSkip() )
			EndDO
		ENDIF	
	Else
		IF LEFT( cNumEmp, 2 ) == "01"

			SZ5->( DbSetOrder( 2 ) )
			SA3->( DbSetOrder( 1 ) )
			SA3->( DbSeek( xFilial( "SA3" ) ) )

			While !SA3->( Eof() ) .and. SA3->A3_FILIAL == xFilial( "SA3" )

				SZ5->( DbSeek( xFilial( "SZ5" ) + "V" + SA3->A3_COD ) )

				While !SZ5->( Eof() ) .and. SZ5->Z5_FILIAL == xFilial( "SZ5" ) .and. SZ5->Z5_TIPO == "V" .and. ;
				SZ5->Z5_VEND == SA3->A3_COD

					If Str( SZ5->Z5_ANO , 4 ) = mv_par04 // .and. !TRC->( DbSeek( AllTrim( SA3->A3_NREDUZ ) ) )
						lAchou := TRC->( DbSeek( AllTrim( SA3->A3_NREDUZ ) ) )
						RecLock( "TRC" , !lAchou)
						VENDEMP	:= SA3->A3_NREDUZ
						AORDEM  := " "
						TITULO1	:= mTit1
						For kkk := 1 to 12
							cPrev1	:= "PREV" + StrZero(kkk,2)
							cPrev2	:= "SZ5->Z5_VALOR" + StrZero(kkk,2)
							&(cPrev1)	:= &(cPrev2)
						Next
						TRC->( MsUnLock() )
					EndIf

					SZ5->( DbSkip() )
				EndDo

				SA3->( DbSkip() )
			EndDo
		ENDIF	
	EndIf

	dbSelectArea("TRC")
	dbGotop()
	do While !EOF()
		RecLock("TRC",.F.)
		PREV13:=PREV01+PREV02+PREV03+PREV04+PREV05+PREV06+PREV07+PREV08+PREV09+PREV10+PREV11+PREV12
		REAL13:=REAL01+REAL02+REAL03+REAL04+REAL05+REAL06+REAL07+REAL08+REAL09+REAL10+REAL11+REAL12
		REAL213:=REAL201+REAL202+REAL203+REAL204+REAL205+REAL206+REAL207+REAL208+REAL209+REAL210+REAL211+REAL212
		/*
		VAR01:=IIF(REAL201==0,0,REAL01-REAL201)
		VAR02:=IIF(REAL202==0,0,REAL02-REAL202)
		VAR03:=IIF(REAL203==0,0,REAL03-REAL203)
		VAR04:=IIF(REAL204==0,0,REAL04-REAL204)
		VAR05:=IIF(REAL205==0,0,REAL05-REAL205)
		VAR06:=IIF(REAL206==0,0,REAL06-REAL206)
		VAR07:=IIF(REAL207==0,0,REAL07-REAL207)
		VAR08:=IIF(REAL208==0,0,REAL08-REAL208)
		VAR09:=IIF(REAL209==0,0,REAL09-REAL209)
		VAR00:=IIF(REAL210==0,0,REAL10-REAL210)
		VAR11:=IIF(REAL211==0,0,REAL11-REAL211)
		VAR12:=IIF(REAL212==0,0,REAL12-REAL212)
		*/
		msUnlock()
		dbSkip()
	Enddo

	cPATH:= 'C:\TEMP\'
	cFileName   := "SAIDAF"+"_"+DTOS(DATE())+"_"+SUBSTR(TIME(),1,2)+"_"+SUBSTR(TIME(),4,2)+"_"+SUBSTR(TIME(),7,2)+".csv"
	cDestino	:= PADR(cPATH+cFileName, 100)

	dbselectarea("TRB")
	dbgotop()         

	cCabec:=""
	//Monta Cabeçalho Relatório
	For _nX:=1 To Len(aStru1)
		cCabec+= aStru1[_nX,1]+";" 
	Next _nX

	cCabec:=SubStr(cCabec,1,Len(cCabec)-1)
	u_ArqLog(cCabec,cDestino,"")

    TRB->( dbEVal( { || ++_nTotR1 } , {||!EOF()} ) )
    TRB->(dbgotop()) 
    
    oProcess:SetRegua1( _nTotR1 )
    oProcess:SetRegua2( _nTotR1 ) 

	While TRB->(!EOF())
	
		sleep(100)	
	 	
	 	If lEnd	//houve cancelamento do processo		
	 		Exit	
	 	EndIf
	   	   
	   oProcess:IncRegua1('Processando...  '       )
	   oProcess:IncRegua2('Nota Fiscal...  '  + Alltrim(TRB->NOTA)   ) 
	 	
		cDetal:= ""                       
		cDetal+= cValToChar(TRB->NOTA     )  + ";"
		cDetal+= cValToChar(TRB->CLIENTE  )  + ";"
		cDetal+= cValToChar(TRB->ITEM     )  + ";"
		cDetal+= cValToChar(TRB->EMISSAO  )  + ";"
		cDetal+= cValToChar(TRB->VEND1    )  + ";"
		cDetal+= cValToChar(TRB->VEND2    )  + ";"
		cDetal+= cValToChar(TRB->PRODUTO  )  + ";"
		cDetal+= cValToChar(TRB->CODLMT   )  + ";"
		cDetal+= cValToChar(TRB->ESPECIF  )  + ";"
		cDetal+= cValToChar(TRB->CODCLI	  )	 + ";"
		cDetal+= cValToChar(TRB->MARCA    )  + ";"
		cDetal+= StrTran(cValToChar(TRB->QTDADE   ),".", ",")  + ";"
		cDetal+= StrTran(cValToChar(TRB->VALORBRUT),".", ",")  + ";"
		cDetal+= StrTran(cValToChar(TRB->VALORLIQ ),".", ",")  + ";"
		cDetal+= StrTran(cValToChar(TRB->VALORPED ),".", ",")  + ";"
		cDetal+= StrTran(cValToChar(TRB->ICMS     ),".", ",")  + ";"
		cDetal+= StrTran(cValToChar(TRB->IPI      ),".", ",")  + ";"
		cDetal+= StrTran(cValToChar(TRB->ICMSRET  ),".", ",")  + ";"
		cDetal+= StrTran(cValToChar(TRB->PIS      ),".", ",")  + ";"
		cDetal+= StrTran(cValToChar(TRB->COFINS   ),".", ",")  + ";"
		cDetal+= StrTran(cValToChar(TRB->DIFAL    ),".", ",")  + ";"
		cDetal+= StrTran(cValToChar(TRB->ICMSCOM  ),".", ",")  + ";"
		cDetal+= cValToChar(TRB->PEDIDO   )  + ";"
		cDetal+= cValToChar(TRB->ITEMPV   )  + ";"
		cDetal+= cValToChar(TRB->REGIAO   )  + ";"
		cDetal+= cValToChar(TRB->AREA     )  + ";"
		cDetal+= cValToChar(TRB->TES      )  + ";"
		cDetal+= cValToChar(TRB->CFOP     )  + ";"
		cDetal+= cValToChar(TRB->SEGMENTO1)  + ";"
		cDetal+= cValToChar(TRB->SEGMENTO2)  + ";"
		cDetal+= cValToChar(TRB->CLASSIF  )  + ";"
		cDetal+= cValToChar(TRB->PEDCLI   )  + ";"
		cDetal+= cValToChar(TRB->GRUPO    )  + ";"
		cDetal+= cValToChar(TRB->SUPERGRP )  + ";"
		cDetal+= cValToChar(TRB->CLIECOD  )  + ";"
		cDetal+= cValToChar(TRB->LOJACLI  )  + ";"
		cDetal+= cValToChar(TRB->NOMFANT  )  + ";"
		cDetal+= cValToChar(TRB->CNPJ     )
		
		u_ArqLog(cDetal,cDestino,"")
		TRB->(dbSkip())
	EndDo
	
	

   If ApOleClient("MsExcel")  
       oExcelApp:= MsExcel():New()
	   oExcelApp:WorkBooks:Open(cDestino)
	   oExcelApp:SetVisible(.T.)
   Endif

	If Select("TRB") > 0
		TRB->(DbCloseArea())
	EndIf

	cFileName := "_VEND"+"_"+DTOS(DATE())+"_"+SUBSTR(TIME(),1,2)+"_"+SUBSTR(TIME(),4,2)+"_"+SUBSTR(TIME(),7,2)+".csv"     

	cCabec:=""
	//Monta Cabeçalho Relatório
	For _nX:=1 To Len(aStru)
		cCabec+= aStru[_nX,1]+";" 
	Next _nX

	cCabec:=SubStr(cCabec,1,Len(cCabec)-1)
	u_ArqLog(cCabec,cDestino,"")

	dbselectarea("TRC")
	dbgotop()                       
	While TRC->(!EOF())
		
		cDetal:= ""
		cDetal+= cValToChar(TRC->AORDEM )  	+ ";"
		cDetal+= cValToChar(TRC->VENDEMP)  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->PREV01 ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->PREV02 ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->PREV03 ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->PREV04 ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->PREV05 ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->PREV06 ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->PREV07 ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->PREV08 ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->PREV09 ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->PREV10 ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->PREV11 ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->PREV12 ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->PREV13 ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->REAL01 ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->REAL02 ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->REAL03 ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->REAL04 ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->REAL05 ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->REAL06 ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->REAL07 ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->REAL08 ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->REAL09 ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->REAL10 ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->REAL11 ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->REAL12 ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->REAL13 ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->REAL201),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->REAL202),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->REAL203),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->REAL204),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->REAL205),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->REAL206),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->REAL207),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->REAL208),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->REAL209),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->REAL210),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->REAL211),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->REAL212),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->REAL213),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->VAR01  ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->VAR02  ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->VAR03  ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->VAR04  ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->VAR05  ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->VAR06  ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->VAR07  ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->VAR08  ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->VAR09  ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->VAR10  ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->VAR11  ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->VAR12  ),".", ",")  	+ ";"
		cDetal+= StrTran(cValToChar(TRC->VAR13  ),".", ",")  	+ ";"
		cDetal+= cValToChar(TRC->TITULO1)			
		
		u_ArqLog(cDetal,cDestino,"")
		TRC->(dbSkip())
	EndDo

	If ApOleClient("MsExcel")  
		oExcelApp:= MsExcel():New()
		oExcelApp:WorkBooks:Open(cPATH+cFileName)
		oExcelApp:SetVisible(.T.)		
	Endif

	TRC->(DBCLOSEAREA())
  
    
   	MsgInfo("Processamento finalizado e relatório gerado com sucesso!" )
   	
Return

// *----------------------------------------------------------------------------
Static Function AjustaSX1()
	Local nXX
	aPerg    := {}
	cPerg := PadR( "FATURL" , Len( SX1->X1_GRUPO ) )

	Aadd( aPerg , { "Do Produto        ?" , "C" , 15 , "SB1"})
	Aadd( aPerg , { "Ate Produto       ?" , "C" , 15 , "SB1"})
	Aadd( aPerg , { "Empresa/Vendedor  ?" , "N" , 01 , "   "})
	Aadd( aPerg , { "Ano Referencia    ?" , "C" , 04 , "   "})
	Aadd( aPerg , { "Abate impostos    ?" , "N" , 01 , "   "})
	Aadd( aPerg , { "Ignora CFOPs      :" , "C" , 40 , "   "})
	Aadd( aPerg , { "Da Data           ?" , "D" , 08 , "   "})
	Aadd( aPerg , { "Ate Data          ?" , "D" , 08 , "   "})
	Aadd( aPerg , { "Impr. Var. Cambial?" , "N" , 01 , "   "})
	Aadd( aPerg , { "Abate IPI         ?" , "N" , 01 , "   "})
	Aadd( aPerg , { "Abate ICMS        ?" , "N" , 01 , "   "})
	Aadd( aPerg , { "Abate PIS         ?" , "N" , 01 , "   "})
	Aadd( aPerg , { "Abate COFINS      ?" , "N" , 01 , "   "})

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
			If nxx == 5 .OR. nxx >= 9
				SX1->X1_GSC   := "C"
				SX1->X1_DEF01 := "Sim"
				SX1->X1_DEF02 := "Nao"
			Endif
			SX1->(MsUnlock())
		EndIf
	Next nXX
Return Nil

