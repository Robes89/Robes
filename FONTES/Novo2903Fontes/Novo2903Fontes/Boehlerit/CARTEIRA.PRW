#INCLUDE "rwmake.ch"

// Rotina		: CARTEIRA
// Descrição	: Carteira mensal
// Data			: 01/02/05
// Autor        : Daniel Gondran
//27/11/08 - Fernando  - Incluir BILZ

User Function CARTEIRA()

// mv_par01 - Do  Produto
// mv_par02 - Até Produto
// mv_par03 - Quebra (empresa / vendedor)
// mv_par04 - Ano
// mv_par05 - Abate Impostos
// mv_par06 - Status Pedido (SEDPICO)
// mv_par07 - Data Corte
// mv_par08 - Dados históricos (Sim/Nao)
// mv_par09 - Mes / Ano historico
// mv_par10 - Ignota residuo (Sim/Nao)
// mv_par11 - Só Pedidos Faturados (Sim/Nao)
// mv_par12 - Da  Emissão
// mv_par13 - Até Emissão
// mv_par14 - Da  Faturamento
// mv_par15 - Até Faturamento
// mv_par16 - Da  Dt Entrega
// mv_par17 - Até Dt Entrega

cPerg    := PadR( "CARTEI" , Len( SX1->X1_GRUPO ) )

AjustaSX1()

Pergunte(cPerg,.F.)

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Carteira Mensal"
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

aStru := {}
aAdd(aStru,{"AORDEM"     ,"C",01,0})
aAdd(aStru,{"VENDEMP"    ,"C",20,0})
aAdd(aStru,{"PREV00"     ,"N",14,2})
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
aAdd(aStru,{"PREV99"     ,"N",14,2})
aAdd(aStru,{"REAL00"     ,"N",14,2})
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
aAdd(aStru,{"REAL99"     ,"N",14,2})
aAdd(aStru,{"TITULO1"    ,"C",52,0})
aAdd(aStru,{"TITULO2"    ,"C",52,0})
aAdd(aStru,{"TITULO3"    ,"C",52,0})

oTemptable := FWTemporaryTable():New( "TRC")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"VENDEMP"} )
oTempTable:Create()
/*
cArq := CriaTrab(aStru,.T.)
dbUseArea(.T.,,cArq,"TRC",.T.)
cInd := CriaTrab(NIL,.F.)
IndRegua("TRC",cInd,"VENDEMP",,,"Selecionando Registros...")
*/
aStru := {}
aAdd(aStru,{"PEDIDO"     ,"C",06,0})
aAdd(aStru,{"ITEM"       ,"C",02,0})
aAdd(aStru,{"CLIENTE"    ,"C",20,0})
aAdd(aStru,{"STATPED"    ,"C",01,0})
aAdd(aStru,{"EMISSAO"    ,"D",08,0})
aAdd(aStru,{"ENTREGA"    ,"D",08,0})
aAdd(aStru,{"VENDEDOR"   ,"C",20,0})
aAdd(aStru,{"PRODUTO"    ,"C",15,0})
aAdd(aStru,{"CODLMT"     ,"C",46,0})
aAdd(aStru,{"EMPRESA"    ,"C",20,0})
aAdd(aStru,{"QTDADE"     ,"N",14,3})
aAdd(aStru,{"VALOR"      ,"N",14,2})
aAdd(aStru,{"MOEDA"      ,"C",01,0})
aAdd(aStru,{"RESIDUO"    ,"C",01,0})

oTemptable := FWTemporaryTable():New( "TRB")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"PEDIDO + ITEM"} )
oTempTable:Create()
/*
cArq := CriaTrab(aStru,.T.)
dbUseArea(.T.,,cArq,"TRB",.T.)
cInd := CriaTrab(NIL,.F.)
IndRegua("TRB",cInd,"PEDIDO + ITEM",,,"Selecionando Registros...")
*/
iData 	 := ctod("01/01/"+mv_par04)
aEmps 	 := {"BO","FE","KI","NI","ON","BI","BR","MT","HO"}
aEmpresa := {"BOEHLERIT","FETTE","KIENINGER","NIPPON","ONSRUD","BILZ","FAB. BRASIL","MORRIS TOOLING","HORN"}
If mv_par11 # 1
	mtit1    := "Carteira "+Iif(mv_par05==2,"bruta","liquida")+" por " + Iif(mv_par03==1,"empresa","vendedor") + " " + mv_par04
Else
	mtit1    := "Pedidos Faturados "+Iif(mv_par05==2,"bruto","liquido")+" por " + Iif(mv_par03==1,"empresa","vendedor") + " " + mv_par04
EndIf

cctit2 := ""
If "S" $  mv_par06
	ccTit2 += " Simples "
Endif
If "E" $  mv_par06
	ccTit2 += " Estimado "
Endif
If "P" $  mv_par06
	ccTit2 += " Programado "
Endif
If "D" $  mv_par06
	ccTit2 += " Demonstração "
Endif
If "I" $  mv_par06
	ccTit2 += " Industr. "
Endif
If "C" $  mv_par06
	ccTit2 += " Consig. "
Endif
If "O" $  mv_par06
	ccTit2 += " Outros "
Endif

If mv_par11 # 1
	Processa( {|| Runproc() } , "Gerando Arquivo" )
Else
	Processa( {|| FAT() } , "Gerando Arquivo" )
EndIf

dbSelectArea("TRC")
dbGotop()
do While !EOF()
	RecLock("TRC",.F.)
	PREV13:=PREV01+PREV02+PREV03+PREV04+PREV05+PREV06+PREV07+PREV08+PREV09+PREV10+PREV11+PREV12+PREV00+PREV99
	REAL13:=REAL01+REAL02+REAL03+REAL04+REAL05+REAL06+REAL07+REAL08+REAL09+REAL10+REAL11+REAL12+REAL00+REAL99
	msUnlock()
	dbSkip()
Enddo

If LastRec() == 0
	RecLock("TRC",.T.)
	TITULO1     := mTit1
	TITULO2 	:= cctit2
	TITULO3		:= "Ref : " + mv_par09
	msUnlock()
Endif

ferase("\SIGAADV\SAIDA.DBF")
dbselectarea("TRB")
dbgotop()
//COPY TO "\SIGAADV\SAIDAC.DBF" Via "DBFCDXADS" 
Processa({||CpyS2T("\SIGAADV\SAIDAC.DBF","C:\TEMP",.T.)},"Copiando Arquivo","Aguarde...",.F.)
ferase("\SIGAADV\SAIDAC.DBF")
TRB->(DBCLOSEAREA())

ferase("\DADOSADV\_VEND.DBF")
dbselectarea("TRC")
dbgotop()
//COPY TO "\DADOSADV\_VEND.DBF" Via "DBFCDXADS" 
Processa({||CpyS2T("\DADOSADV\_VEND.DBF","C:\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
ferase("\DADOSADV\_VEND.DBF")
TRC->(DBCLOSEAREA())
mTESTE := "1;0;1;GIS"  // "EM DISCO;ATUALIZA;1 COPIA;NOME REL."
CALLCRYS("VENDC",,mTESTE)

Return

//*******************************************************************************( INICIO )
STATIC FUNCTION Runproc()

aa5:="SC5"
aa6:="SC6"
If mv_par08 == 1 // Dados historicos
	aa5 := "TR5" // "SZ7" // "TR5"
	aa6 := "TR6" // "SZ6" // "TR6"
	If !File ("S5"+Substr(mv_par09,4,4)+Substr(mv_par09,1,2)+".DBF")
		Alert("Mes/ano não congelado")
		Return
	Endif
	//dbUseArea(.T.,"DBFCDX","S5"+Substr(mv_par09,4,4)+Substr(mv_par09,1,2)+".DBF","TR5",.T.,.F.)
	oTemptable := FWTemporaryTable():New( "TR5")
	oTempTable:Create()
	dbSelectArea("TR5")
	//cTrbTR5 := CriaTrab(,.F.)
	IndRegua("TR5",cTrbTR5,"C5_FILIAL+C5_NUM",,,"SC5...")
	
	oTemptable := FWTemporaryTable():New( "TR6")
	oTempTable:Create()

	//dbUseArea(.T.,"DBFCDX","S6"+Substr(mv_par09,4,4)+Substr(mv_par09,1,2)+".DBF","TR6",.T.,.F.)
	dbSelectArea("TR6")
	//cTrbTR6 := CriaTrab(,.F.)
	IndRegua("TR6",cTrbTR6,"C6_FILIAL+DTOS(C6_ENTREG)+C6_NUM+C6_ITEM",,,"SC6...")
	
Endif

dbselectarea(aa6)
dbSetOrder(1)
ProcRegua(LastRec())
//dbSeek(xFilial("SC6")+dtos(idata))

If .F. // If mv_par08 == 1 // Dados historicos
	dbSelectArea(aa6)
//	dbSetOrder(2)
	dbSeek(xFilial("SC6") + dtos(mv_Par16),.t.) // mv_par04+Substr(mv_par09,1,2))
	DO WHILE !EOF() .AND. C6_FILIAL == xFilial("SC6") .and. C6_ENTREG <= mv_par17 //.and. Year(C6_ENTREG) == Year(idata) // C6_MESANO == MV_PAR04+MV_PAR09//
		IncProc(C6_NUM)
		If C6_QTDENT >= C6_QTDVEN  // .or. C6_BLQ == "R "
			dbSkip()
			loop
		Endif
		ifator := 1
		If "E" $ mv_par06 .and. "S" $ mv_par06 .and. !Empty(C6_NUMPEDP) 
			ifator := 0
		Endif

		dbSelectArea(aa5)		
		dbSeek(xFilial("SC5") + (aa6)->C6_NUM)
		
		xrec := (aa6)->(Recno())
		dbSelectArea(aa6)
		dbSetOrder(1)
		dbSeek(xFilial("SC6") + (aa5)->C5_NUM)
		nQTot := 0
		do While !Eof() .and. C6_FILIAL == xFilial("SC6") .and. C6_NUM == (aa5)->C5_NUM
			nQTot += (aa6)->C6_VALOR
			dbSkip()
		Enddo
		(aa6)->(dbGoto(xrec))

		dbSelectArea(aa5)		
		dbSeek(xFilial("SC5") + (aa6)->C6_NUM)

		lTesta := .T.
		If "E" $ mv_par06 .and. !("S" $ mv_par06) .AND. !Empty((aa6)->C6_NUMPEDP) 
			lTesta := .F.
			ifator := -1
		Endif

    
		If iif(ltesta,!(C5_STPAD $ mv_par06),.f.) .or. C5_EMISSAO > mv_par07
			dbSelectArea(aa6)
			dbSkip()
			loop
		Endif
	
		dbSelectArea(aa5)		
/*
		If C5_EMISSAO < mv_par12 .or. C5_EMISSAO > mv_par13
			dbSelectArea(aa6)
			dbSkip()
			loop
		Endif
*/
		cVend 	 := C5_NOMEVEN
		nMoeda   := C5_MOEDA
		If nMoeda <> 1
			cMoeda := "M2_MOEDA" + StrZero(nMoeda,1)
			dbSelectArea("SM2")
			dbSeek((aa5)->C5_EMISSAO)
			nConv  := &(cMoeda)
			If nConv == 0
				Alert ("Atenção: Cadastrar Moeda " + StrZero(nMoeda,1) + " no dia " + Dtoc((aa5)->C5_EMISSAO))
			Endif
		Else
			nConv := 1
		Endif
		/*
		If SC6->C6_ENTREG <= Ctod("31/01/2005")
		If SC6->C6_BLQ == "R "
		cMes     := "PREV01"
		Else
		cMes  	 := "REAL01"
		Endif
		Endif
		*/
		
		If (aa6)->C6_BLQ == "R "
			dbSelectArea("SZ8")
			dbSetOrder(1)
			dbSeek(xFilial("SZ8") + (aa6)->C6_NUM + (aa6)->C6_ITEM)
			If Year(SZ8->Z8_EMINOVO) == Val(mv_par04)
				cMes     := "PREV" + StrZero(Month(SZ8->Z8_EMINOVO),2)			
			ElseIf Year(SZ8->Z8_EMINOVO) < Val(mv_par04)
				cMes	:= "PREV00"
			ElseIf Year(SZ8->Z8_EMINOVO) > Val(mv_par04)
				cMes	:= "PREV99"
			Endif
		Else
			If Year((aa6)->C6_ENTREG)==Val(mv_par04)
				cMes     := "REAL" + StrZero(Month((aa6)->C6_ENTREG),2)
			ElseIf Year((aa6)->C6_ENTREG) < Val(mv_par04)
				cMes     := "REAL00"
			ElseIf Year((aa6)->C6_ENTREG) > Val(mv_par04)
				cMes     := "REAL99"
			Endif
		Endif
		
		dbSelectArea("SF4")
		dbSetOrder(1)
		dbSeek(xFilial("SF4") + (aa6)->C6_TES)
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
			nIndice := Ascan(aEmps,Left((aa6)->C6_PRODUTO,2))
			If nIndice == 0
				mCampo := "OUTROS              "
				mOrdem := "8"
			Else
				mCampo := Padr(aEmpresa[nIndice],20)
				mOrdem := StrZero(nIndice,1)
			Endif
		Endif
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFIlial("SB1") + (aa6)->C6_PRODUTO)
		nIpi      := SB1->B1_IPI		
		If mv_par05 == 2
			mVRUNIT   := (aa6)->C6_PRCVEN + Iif(lcalipi,((aa6)->C6_PRCVEN * nIpi / 100),0)
			mVRTOTAL  := mVRUNIT * ((aa6)->C6_QTDVEN - (aa6)->C6_QTDENT)
			nIndice   := Ascan(aEmps,Left((aa6)->C6_PRODUTO,2))
			If nIndice == 0
				mEmpresa := "OUTROS              "
			Else
				mEmpresa := Padr(aEmpresa[nIndice],20)
			Endif
		Else
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(xFilial("SA1") + (aa6)->C6_CLI + (aa6)->C6_LOJA)
			dbSelectArea(aa6)
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
//			mVRUNIT   := (aa6)->C6_PRCVEN - Iif(lcalicm,(aa6)->C6_PRCVEN * nIcms/100,0) - (aa6)->C6_PRCVEN * (Iif(lcalpis,nPis,0)+Iif(lcalcof,nCof,0))/100
			mVRUNIT   := (aa6)->C6_PRCVEN - IIF(.t.,;
			             Iif(lCalIcm,((aa6)->C6_PRCVEN + ((aa5)->C5_FRETE * ((aa6)->C6_VALOR / nQTot) / 100 )) * ;
			             Iif(SF4->F4_INCIDE=="F",(1 + (nIpi / 100)),1) * nIcms/100,0),0) - ;
			             (aa6)->C6_PRCVEN * (Iif(lCalPis,nPis,0) + Iif(lcalcof,nCof,0))/100
				
			mVRTOTAL  := mVRUNIT * ((aa6)->C6_QTDVEN - (aa6)->C6_QTDENT)
			
		Endif
		
		nIndice   := Ascan(aEmps,Left((aa6)->C6_PRODUTO,2))
		If nIndice == 0
			mEmpresa := "OUTROS              "
		Else
			mEmpresa := Padr(aEmpresa[nIndice],20)
		Endif
		
		dbSelectArea("TRB")
		RecLock("TRB",.T.)
		PEDIDO	 := (aa5)->C5_NUM
		ITEM	 := (aa6)->C6_ITEM
		CLIENTE	 := (aa5)->C5_NOMECLI
		STATPED  := (aa5)->C5_STPAD
		EMISSAO	 := (aa5)->C5_EMISSAO
		ENTREGA  := (aa6)->C6_ENTREG
		VENDEDOR := (aa5)->C5_NOMEVEN
		PRODUTO  := (aa6)->C6_PRODUTO
		CODLMT   := (aa6)->C6_CODLMT
		QTDADE   := ((aa6)->C6_QTDVEN - (aa6)->C6_QTDENT) * ifator
		VALOR    := mVRTOTAL * nConv * ifator
		EMPRESA  := mEmpresa
		MOEDA    := StrZero((aa5)->C5_MOEDA,1)
		RESIDUO	 := IIF((aa6)->C6_BLQ=="R ","R"," ")
		msUnlock()
		
		dbSelectArea("TRC")
		lAchou := dbSeek(mCampo)
		RecLock( "TRC" , !lAchou)
		VENDEMP		:= mCampo
		AORDEM  	:= mOrdem
		If cMes <> "XXX"
			&(cMes)		+= mVRTOTAL * nConv  * ifator
		Endif
		TITULO1     := mTit1
		TITULO2 	:= cctit2
		TITULO3		:= "Ref : " + mv_par09		
		TRC->( MsUnLock() )
		dbSelectArea(aa6)
		dbSkip()
	Enddo

	// Tratamento SZ8
	/*
	dbSelectArea("SZ8")
	dbGotop()
	do While !Eof()
		If StrZero(month(Z8_EMINOVO),2) + "/" + StrZero(Year(Z8_EMINOVO),4) == mv_par09

			dbSelectArea("SC6")
			dbSetOrder(1)
			dbSeek(SZ8->Z8_FILIAL + SZ8->Z8_NUM + SZ8->Z8_ITEM)
		
			dbSelectArea("SC5")
			dbSetOrder(1)
			dbSeek(SZ8->Z8_FILIAL + SZ8->Z8_NUM)
		
			dbSelectArea("SB1")
			dbSetOrder(1)
			dbSeek(SZ8->Z8_FILIAL + SZ8->Z8_PRODUTO)
		
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(XFILIAL("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI)
		
			dbSelectArea("SA3")
			dbSetOrder(1)
			dbSeek(xFilial("SA3") + SC5->C5_VEND1)
		
			dbSelectArea("SE4")
			dbSetOrder(1)
			dbSeek(xFilial("SE4") + SC5->C5_CONDPAG)
		
			dbSelectArea("SBM")
			dbSetOrder(1)
			dbSeek(xFilial("SBM") + SB1->B1_GRUPO)
			
			
			ifator := 1
			If "E" $ mv_par06 .and. "S" $ mv_par06 .and. !Empty(SC6->C6_NUMPEDP) 
				ifator := 0
			Endif                               

			lTesta := .T.
			If "E" $ mv_par06 .and. !("S" $ mv_par06) .AND. !Empty(SC6->C6_NUMPEDP) 
				lTesta := .F.
				ifator := -1
			Endif

			If iif(ltesta,!(SC5->C5_STPAD $ mv_par06),.F.) .or. SC5->C5_EMISSAO > mv_par07
				dbSelectArea("SZ8")
				dbSkip()
				loop
			Endif
	
			dbSelectArea("SZ8")
			dbSetOrder(1)
			nNewQ := Z8_QTDNOVA
			nNewV := Z8_VALNOVO
			nNewP := Z8_PRCNOVO
			nOldQ := Z8_QTDORIG
			nOldV := Z8_VALORIG
			nOldP := Z8_PRCORIG
		
			cVend 	 := SC5->C5_NOMEVEN
			nMoeda   := SC5->C5_MOEDA
			If nMoeda <> 1 .AND. nmoeda<> 0
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
            



	        // ORIG (-)

			nInd := Month(SZ8->Z8_ENTREG)      
			If nInd == 0 .or. SZ8->Z8_STATUS == "R" // <<<VERIFICAR >>>
				dbSelectArea("SZ8")
				dbSkip()
				Loop
			Endif

			If Year(SZ8->Z8_ENTREG)==Val(mv_par04)
				If SZ8->Z8_STATUS == "R"
					cMes     := "PREV" + StrZero(Month(SZ8->Z8_ENTREG),2)
				Else
					cMes     := "REAL" + StrZero(Month(SZ8->Z8_ENTREG),2)
				Endif
			ElseIf Year(SZ8->Z8_ENTREG) < Val(mv_par04)
				If SZ8->Z8_STATUS == "R"
					cMes     := "PREV00"
				Else
					cMes     := "REAL00"
				Endif
			ElseIf Year(SZ8->Z8_ENTREG) > Val(mv_par04)
				If SZ8->Z8_STATUS == "R"
					cMes     := "PREV99"
				Else
					cMes     := "REAL99"
				Endif
			Else
				Alert(SZ8->Z8_NUM)
				cMes := "XXX"
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
				nIndice := Ascan(aEmps,Left(SZ8->Z8_PRODUTO,2))
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
			dbSeek(xFIlial("SB1") + SZ8->Z8_PRODUTO)
			nIpi      := SB1->B1_IPI
			If mv_par05 == 2
				mVRUNIT   := SZ8->Z8_PRCORIG + Iif(lcalipi,(SZ8->Z8_PRCORIG * nIpi / 100),0)
				mVRTOTAL  := mVRUNIT * SZ8->Z8_QTDORIG 
				nIndice   := Ascan(aEmps,Left(SZ8->Z8_PRODUTO,2))
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
				mVRUNIT   := SZ8->Z8_PRCORIG - Iif(lcalicm,SZ8->Z8_PRCORIG * Iif(SF4->F4_INCIDE=="F",(1 + (nIpi / 100)),1) * nIcms/100,0) - SZ8->Z8_PRCORIG * (Iif(lcalpis,nPis,0)+Iif(lcalcof,nCof,0))/100
				mVRTOTAL  := mVRUNIT * SZ8->Z8_QTDORIG
			Endif
		
			nIndice   := Ascan(aEmps,Left(SZ8->Z8_PRODUTO,2))
			If nIndice == 0
				mEmpresa := "OUTROS              "
			Else
				mEmpresa := Padr(aEmpresa[nIndice],20)
			Endif
		
			dbSelectArea("TRB")
			lAchou := dbSeek(SZ8->Z8_NUM + SZ8->Z8_ITEM)
			RecLock("TRB",!lachou)
			PEDIDO	 := SZ8->Z8_NUM
			ITEM	 := SZ8->Z8_ITEM
			CLIENTE	 := SC5->C5_NOMECLI
			STATPED  := SC5->C5_STPAD
			EMISSAO	 := SZ8->Z8_EMISSAO
			ENTREGA  := SZ8->Z8_ENTREG
			VENDEDOR := SC5->C5_NOMEVEN
			PRODUTO  := SZ8->Z8_PRODUTO
			CODLMT   := SC6->C6_CODLMT
			QTDADE   -= SZ8->Z8_QTDORIG * ifator
			VALOR    -= mVRTOTAL * nConv * ifator
			EMPRESA  := mEmpresa
			MOEDA    := StrZero(SC5->C5_MOEDA,1)
			RESIDUO	 := IIF(SZ8->Z8_STATUS == "R","R"," ")
			msUnlock()
		
			dbSelectArea("TRC")
			lAchou := dbSeek(mCampo)
			RecLock( "TRC" , !lAchou)
			VENDEMP		:= mCampo
			AORDEM  	:= mOrdem
			If cMes <> "XXX"
				&(cMes)		-= mVRTOTAL * nConv  * ifator
			Endif
			TITULO1     := mTit1
			TITULO2 	:= cctit2
			TITULO3		:= "Ref : " + mv_par09		
			TRC->( MsUnLock() )
			
		
		
			// NOVO (+)

			nInd := Month(SZ8->Z8_ENTNOVO)
			If nInd == 0
				dbSelectArea("SZ8")
				dbSkip()
				Loop
			Endif
		

			If Year(SZ8->Z8_ENTNOVO)==Val(mv_par04)
				If SZ8->Z8_STATUS == "R"
					cMes     := "PREV" + StrZero(Month(SZ8->Z8_ENTNOVO),2)
				Else
					cMes     := "REAL" + StrZero(Month(SZ8->Z8_ENTNOVO),2)
				Endif
			ElseIf Year(SZ8->Z8_ENTREG) < Val(mv_par04)
				If SZ8->Z8_STATUS == "R"
					cMes     := "PREV00"
				Else
					cMes     := "REAL00"
				Endif
			ElseIf Year(SZ8->Z8_ENTREG) > Val(mv_par04)
				If SZ8->Z8_STATUS == "R"
					cMes     := "PREV99"
				Else
					cMes     := "REAL99"
				Endif
			Else
				Alert(SZ8->Z8_NUM)
				cMes := "XXX"
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
				nIndice := Ascan(aEmps,Left(SZ8->Z8_PRODUTO,2))
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
			dbSeek(xFIlial("SB1") + SZ8->Z8_PRODUTO)
			nIpi      := SB1->B1_IPI			
			If mv_par05 == 2
				mVRUNIT   := SZ8->Z8_PRCNOVO + Iif(lcalipi,(SZ8->Z8_PRCNOVO * nIpi / 100),0)
				mVRTOTAL  := mVRUNIT * SZ8->Z8_QTDNOVA
				nIndice   := Ascan(aEmps,Left(SZ8->Z8_PRODUTO,2))
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
				mVRUNIT   := SZ8->Z8_PRCNOVO - Iif(lcalicm,SZ8->Z8_PRCNOVO * Iif(SF4->F4_INCIDE=="F",(1 + (nIpi / 100)),1) * nIcms/100,0) - SZ8->Z8_PRCNOVO * (Iif(lcalpis,nPis,0)+Iif(lcalcof,nCof,0))/100
				mVRTOTAL  := mVRUNIT * SZ8->Z8_QTDNOVA
			Endif
		
			nIndice   := Ascan(aEmps,Left(SZ8->Z8_PRODUTO,2))
			If nIndice == 0
				mEmpresa := "OUTROS              "
			Else
				mEmpresa := Padr(aEmpresa[nIndice],20)
			Endif
		
			dbSelectArea("TRB")
			lAchou := dbSeek(SZ8->Z8_NUM + SZ8->Z8_ITEM)
			RecLock("TRB",!lachou)
			PEDIDO	 := SZ8->Z8_NUM
			ITEM	 := SZ8->Z8_ITEM
			CLIENTE	 := SC5->C5_NOMECLI
			STATPED  := SC5->C5_STPAD
			EMISSAO	 := SZ8->Z8_EMISSAO
			ENTREGA  := SZ8->Z8_ENTNOVO
			VENDEDOR := SC5->C5_NOMEVEN
			PRODUTO  := SZ8->Z8_PRODUTO
			CODLMT   := SC6->C6_CODLMT
			QTDADE   += SZ8->Z8_QTDNOVA * ifator
			VALOR    += mVRTOTAL * nConv * ifator
			EMPRESA  := mEmpresa
			MOEDA    := StrZero(SC5->C5_MOEDA,1)
			RESIDUO	 := IIF(SZ8->Z8_STATUS == "R","R"," ")
			msUnlock()
		
			dbSelectArea("TRC")
			lAchou := dbSeek(mCampo)
			RecLock( "TRC" , !lAchou)
			VENDEMP		:= mCampo
			AORDEM  	:= mOrdem
			If cMes <> "XXX"
				&(cMes)		+= mVRTOTAL * nConv  * ifator
			Endif
			TITULO1     := mTit1
			TITULO2 	:= cctit2
			TITULO3		:= "Ref : " + mv_par09		
			TRC->( MsUnLock() )
		
		
		Endif
		dbSelectArea("SZ8")
		dbSkip()
	Enddo
    */
else // Dados do mes
    If mv_par08 == 2
		dbSetOrder(3)   	
	Endif
	dbSeek(xFilial("SC6") + DTOS(MV_PAR16),.t.)
	DO WHILE !EOF() .AND. C6_FILIAL == xFilial("SC6") .AND. C6_ENTREG <= MV_PAR17 //.and. Year(C6_ENTREG) == Year(idata)
		IncProc(C6_NUM)
		If C6_QTDENT >= C6_QTDVEN // .or. C6_BLQ == "R "
			dbSkip()
			loop
		Endif
		dbSelectArea(aa5)
		If mv_par08==2
			dbSetOrder(1)
		Endif
		dbSeek(xFilial("SC5") + (aa6)->C6_NUM)
		If !(C5_STPAD $ mv_par06) .or. C5_EMISSAO > mv_par07
			dbSelectArea(aa6)
			dbSkip()
			loop
		Endif
		cVend 	 := C5_NOMEVEN
		nMoeda   := C5_MOEDA
		If nMoeda <> 1
			cMoeda := "M2_MOEDA" + StrZero(nMoeda,1)
			dbSelectArea("SM2")
			dbSeek((aa5)->C5_EMISSAO)
			nConv  := &(cMoeda)
			If nConv == 0
				Alert ("Atenção: Cadastrar Moeda " + StrZero(nMoeda,1) + " no dia " + Dtoc((aa5)->C5_EMISSAO))
			Endif
		Else
			nConv := 1
		Endif
		
		dbSelectArea(aa5)		
		dbSeek(xFilial("SC5") + (aa6)->C6_NUM)
		
		xrec := (aa6)->(Recno())
		dbSelectArea(aa6)
		If mv_par08==2
			dbSetOrder(1)
		Endif
		dbSeek(xFilial("SC6") + (aa5)->C5_NUM)
		nQTot := 0
		do While !Eof() .and. C6_FILIAL == xFilial("SC6") .and. C6_NUM == (aa5)->C5_NUM
			nQTot += (aa6)->C6_VALOR
			dbSkip()
		Enddo
		(aa6)->(dbGoto(xrec))

		dbSelectArea(aa5)		
		dbSeek(xFilial("SC5") + (aa6)->C6_NUM)
		
		
		If (aa6)->C6_BLQ == "R " .AND. MV_PAR10 == 1
		ELSE
		If (aa6)->C6_BLQ == "R "
			dbSelectArea("SZ8")
			dbSetOrder(1)
			dbSeek(xFilial("SZ8") + (aa6)->C6_NUM + (aa6)->C6_ITEM)
			If Year(SZ8->Z8_EMINOVO) == Val(mv_par04)
				cMes     := "PREV" + StrZero(Month(SZ8->Z8_EMINOVO),2)			
			ElseIf Year(SZ8->Z8_EMINOVO) < Val(mv_par04)
				cMes	:= "PREV00"
			ElseIf Year(SZ8->Z8_EMINOVO) > Val(mv_par04)
				cMes	:= "PREV99"
			Endif
		Else
			If Year((aa6)->C6_ENTREG)==Val(mv_par04)
				cMes     := "REAL" + StrZero(Month((aa6)->C6_ENTREG),2)
			ElseIf Year((aa6)->C6_ENTREG) < Val(mv_par04)
				cMes     := "REAL00"
			ElseIf Year((aa6)->C6_ENTREG) > Val(mv_par04)
				cMes     := "REAL99"
			Endif
		Endif
		ENDIF
		dbSelectArea("SF4")
		dbSetOrder(1)
		dbSeek(xFilial("SF4") + (aa6)->C6_TES)
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
			nIndice := Ascan(aEmps,Left((aa6)->C6_PRODUTO,2))
			If nIndice == 0
				mCampo := "OUTROS              "
				mOrdem := "8"
			Else
				mCampo := Padr(aEmpresa[nIndice],20)
				mOrdem := StrZero(nIndice,1)
			Endif
		Endif
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFIlial("SB1") + (aa6)->C6_PRODUTO)
		nIpi      := SB1->B1_IPI
		If mv_par05 == 2
			mVRUNIT   := (aa6)->C6_PRCVEN + Iif(lcalipi,((aa6)->C6_PRCVEN * nIpi / 100),0)
			mVRTOTAL  := mVRUNIT * ((aa6)->C6_QTDVEN - (aa6)->C6_QTDENT)
			nIndice   := Ascan(aEmps,Left((aa6)->C6_PRODUTO,2))
			If nIndice == 0
				mEmpresa := "OUTROS              "
			Else
				mEmpresa := Padr(aEmpresa[nIndice],20)
			Endif
		Else
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(xFilial("SA1") + (aa6)->C6_CLI + (aa6)->C6_LOJA)
			dbSelectArea(aa6)
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
//			mVRUNIT   := (aa6)->C6_PRCVEN - Iif(lcalicm,(aa6)->C6_PRCVEN * nIcms/100,0) - (aa6)->C6_PRCVEN * (Iif(lcalpis,nPis,0)+Iif(lcalcof,nCof,0))/100
			mVRUNIT   := (aa6)->C6_PRCVEN - IIF(.t.,;
			             Iif(lCalIcm,((aa6)->C6_PRCVEN + ((aa5)->C5_FRETE * ((aa6)->C6_VALOR / nQTot) / 100 )) * ;
			             Iif(SF4->F4_INCIDE=="F",(1 + (nIpi / 100)),1) * nIcms/100,0),0) - ;
			             (aa6)->C6_PRCVEN * (Iif(lCalPis,nPis,0) + ;
			             Iif(lcalcof,nCof,0))/100

			mVRTOTAL  := mVRUNIT * ((aa6)->C6_QTDVEN - (aa6)->C6_QTDENT)
		Endif
		
		nIndice   := Ascan(aEmps,Left((aa6)->C6_PRODUTO,2))
		If nIndice == 0
			mEmpresa := "OUTROS              "
		Else
			mEmpresa := Padr(aEmpresa[nIndice],20)
		Endif
		If (aa6)->C6_BLQ == "R " .AND. MV_PAR10 == 1
		ELSE
			dbSelectArea("TRB")
			RecLock("TRB",.T.)
			PEDIDO	 := (aa5)->C5_NUM
			ITEM	 := (aa6)->C6_ITEM
			CLIENTE	 := (aa5)->C5_NOMECLI
			STATPED  := (aa5)->C5_STPAD
			EMISSAO	 := (aa5)->C5_EMISSAO
			ENTREGA  := (aa6)->C6_ENTREG
			VENDEDOR := (aa5)->C5_NOMEVEN
			PRODUTO  := (aa6)->C6_PRODUTO
			CODLMT   := (aa6)->C6_CODLMT
			QTDADE   := ((aa6)->C6_QTDVEN - (aa6)->C6_QTDENT)
			VALOR    := mVRTOTAL * nConv
			EMPRESA  := mEmpresa
			MOEDA    := StrZero((aa5)->C5_MOEDA,1)
			RESIDUO	 := IIF((aa6)->C6_BLQ=="R ","R"," ")
			msUnlock()

			dbSelectArea("TRC")
			lAchou := dbSeek(mCampo)
			RecLock( "TRC" , !lAchou)
			VENDEMP		:= mCampo
			AORDEM  	:= mOrdem
			If cMes <> "XXX"
				&(cMes)		+= mVRTOTAL * nConv
			Endif
			TITULO1     := mTit1
			TITULO2 	:= cctit2
			TITULO3		:= "Ref : " + mv_par09		
			TRC->( MsUnLock() )
		ENDIF
		dbSelectArea(aa6)
		If mv_par08==2
			dbSetOrder(3)
		Endif
		dbSkip()
	Enddo
Endif

dbSelectArea("TRC")
dbgotop()
do While !Eof()
	If mv_par09 == "05/2006" .and. aordem=="1" .AND. "S"$MV_PAR06
		RecLock("TRC",.F.)
		REAL99 := REAL99 - 18000
		MSUNLOCK()
	ENDIF
	DBSKIP()
Enddo

If mv_par08 == 1
	TR5->(DBCLOSEAREA())	
	TR6->(DBCLOSEAREA())		
Endif

Return

// *----------------------------------------------------------------------------
Static Function FAT()

SC5->( DbSetOrder( 1 ) )
SC6->( DbSetOrder( 1 ) )
SF4->( DbSetOrder( 1 ) )

DbSelectArea( "SD2" )
SD2->( DbSetOrder( 5 ) )
SD2->( DbSeek( xFilial( "SD2" ) + DtoS( mv_par14 ) , .t. ) )

ProcRegua( SD2->( LastRec() ) )

While !SD2->( Eof() ) .and.	SD2->D2_FILIAL	== xFilial( "SD2" ) .and. ;
							SD2->D2_EMISSAO	<= mv_par15

	IncProc( "Processando vendas dia » " + DtoC( SD2->D2_EMISSAO ) )

	SC6->( DbSeek( xFilial( "SC6" ) + SD2->( D2_PEDIDO + D2_ITEMPV ) ) )

	If !SC5->( DbSeek( xFilial( "SC5" ) + SD2->D2_PEDIDO ) ) .or. ;
		( SC5->C5_EMISSAO < mv_par12 .or. SC5->C5_EMISSAO > mv_par13 ) .or. ;
		!SC5->C5_STPAD $ mv_par06 .or. !SF4->( DbSeek( xFilial( "SF4" ) + SD2->D2_TES ) ) .or. ;
		( SC6->C6_ENTREG < mv_par16 .or. SC6->C6_ENTREG > mv_par17 ) .or. ;
		SF4->F4_DUPLIC # "S"
		SD2->( DbSkip() )
		Loop
	EndIf

	cVend	:= SC5->C5_NOMEVEN
	nMoeda	:= SC5->C5_MOEDA
	If nMoeda <> 1
		cMoeda := "SM2->M2_MOEDA" + StrZero(nMoeda,1)
		SM2->( dbSeek( SC5->C5_EMISSAO ) )
		nConv  := &(cMoeda)
		If nConv == 0
			Alert ("Atenção: Cadastrar Moeda " + StrZero(nMoeda,1) + " no dia " + Dtoc( SC5->C5_EMISSAO ) )
		Endif
	Else
		nConv := 1
	Endif

	cMes	:= "REAL" + StrZero( Month( SD2->D2_EMISSAO ) , 2 )
	If mv_par03 == 2
		mCampo := cVend
		mOrdem := " "
	Else
		nIndice := Ascan(aEmps,Left(SD2->D2_COD,2))
		If nIndice == 0
			mCampo := "OUTROS              "
			mOrdem := "8"
		Else
			mCampo := Padr(aEmpresa[nIndice],20)
			mOrdem := StrZero(nIndice,1)
		Endif
	Endif

	If mv_par05 == 2
		mVRTOTAL	:= SD2->( D2_TOTAL + D2_VALIPI )
	Else
		mVRTOTAL	:= SD2->( D2_TOTAL - D2_VALICM - D2_VALIMP5 - D2_VALIMP6 )
	Endif
		
	nIndice   := Ascan(aEmps,Left(SD2->D2_COD,2))
	If nIndice == 0
		mEmpresa := "OUTROS              "
	Else
		mEmpresa := Padr(aEmpresa[nIndice],20)
	Endif

	RecLock("TRB",.T.)
	PEDIDO	 := SD2->D2_PEDIDO
	ITEM	 := SD2->D2_ITEMPV
	CLIENTE	 := SD2->D2_CLIENTE
	STATPED  := SC5->C5_STPAD
	EMISSAO	 := SC5->C5_EMISSAO
	ENTREGA  := SC6->C6_ENTREG
	VENDEDOR := SC5->C5_NOMEVEN
	PRODUTO  := SD2->D2_COD
	CODLMT   := SD2->D2_CODLMT
	QTDADE   := SD2->D2_QUANT
	VALOR    := mVRTOTAL * nConv
	EMPRESA  := mEmpresa
	MOEDA    := StrZero(SC5->C5_MOEDA,1)
	MsUnLock( "TRB" )

	dbSelectArea("TRC")
	lAchou := dbSeek(mCampo)
	RecLock( "TRC" , !lAchou)
	VENDEMP		:= mCampo
	AORDEM  	:= mOrdem
	If cMes <> "XXX"
		&(cMes)		+= mVRTOTAL * nConv
	Endif
	TITULO1     := mTit1
	TITULO2 	:= cctit2
	TITULO3		:= "Ref : " + mv_par09	
	TRC->( MsUnLock() )

	SD2->( DbSkip() )
Enddo
Return

// *----------------------------------------------------------------------------
Static Function AjustaSX1()
aPerg    := {}
//cPerg    := "CARTEI"

Aadd( aPerg , { "Do Produto          ?" , "C" , 15 , "SB1"})
Aadd( aPerg , { "Ate Produto         ?" , "C" , 15 , "SB1"})
Aadd( aPerg , { "Empresa/Vendedor    ?" , "N" , 01 , "   "})
Aadd( aPerg , { "Ano Referencia      ?" , "C" , 04 , "   "})
Aadd( aPerg , { "Abate impostos      ?" , "N" , 01 , "   "})
Aadd( aPerg , { "Status Ped (SEPDICO)?" , "C" , 07 , "   "})
Aadd( aPerg , { "Data de Corte       ?" , "D" , 08 , "   "})
Aadd( aPerg , { "Dados Historicos    ?" , "N" , 01 , "   "})
Aadd( aPerg , { "Mes Historico       ?" , "C" , 07 , "   "})
Aadd( aPerg , { "Ignora Residuo      ?" , "N" , 01 , "   "})
Aadd( aPerg , { "Só Pedidos Faturados?" , "N" , 01 , "   "})
Aadd( aPerg , { "Da  Emissão         ?" , "D" , 08 , "   "})
Aadd( aPerg , { "Até Emissão         ?" , "D" , 08 , "   "})
Aadd( aPerg , { "Do  Faturamento     ?" , "D" , 08 , "   "})
Aadd( aPerg , { "Até Faturamento     ?" , "D" , 08 , "   "})
Aadd( aPerg , { "Da  Dt Entrega      ?" , "D" , 08 , "   "})
Aadd( aPerg , { "Até Dt Entrega      ?" , "D" , 08 , "   "})

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
		If nxx == 5 .or. nxx == 8 .OR. nxx == 10 .OR. nxx == 11
			SX1->X1_GSC   := "C"
			SX1->X1_DEF01 := "Sim"
			SX1->X1_DEF02 := "Nao"
		Endif
		SX1->(MsUnlock())
	EndIf
Next nXX
Return Nil
