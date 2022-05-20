#INCLUDE "rwmake.ch"

// Rotina		: CARTEIRA
// Descrição	: Carteira mensal
// Data			: 01/02/05
// Autor        : Daniel Gondran

User Function CC()

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

//cPerg := "CCCCCC"
 cPerg    := PadR( 'CCCCCC' , Len( SX1->X1_GRUPO ) )
AjustaSX1()
Pergunte(cPerg,.F.)
cdata := dtoc(ddatabase)
cdata :=substr(cdata,4,2)+substr(cdata,1,2)+".DBF"

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

//cArq := CriaTrab(aStru,.T.)
//dbUseArea(.T.,,cArq,"TRC",.T.)
//cInd := CriaTrab(NIL,.F.)
//IndRegua("TRC",cInd,"VENDEMP",,,"Selecionando Registros...")

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

//cArq := CriaTrab(aStru,.T.)
//dbUseArea(.T.,,cArq,"TRB",.T.)
//cInd := CriaTrab(NIL,.F.)
//IndRegua("TRB",cInd,"PEDIDO + ITEM",,,"Selecionando Registros...")

iData 	 := ctod("01/01/"+mv_par04)
aEmps 	 := {"BO","FE","KI","NI","ON","BR","BI","MT"}
aEmpresa := {"BOEHLERIT","FETTE","KIENINGER","NIPPON","ONSRUD","FAB. BRASIL","BILZ","MORRIS TOOLING"}
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
	Processa( {|| Runproc() } , "Gerando Arquivo 1" )
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
//COPY TO "\BACKUP\CART\SAIDAC"+CDATA
TRB->(DBCLOSEAREA())

ferase("\DADOSADV\_VEND.DBF")
dbselectarea("TRC")
dbgotop()
//COPY TO "\DADOSADV\_VEND.DBF"
Processa({||CpyS2T("\DADOSADV\_VEND.DBF","C:\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
ferase("\DADOSADV\_VEND.DBF")
TRC->(DBCLOSEAREA())
mTESTE := "1;0;1;GIS"  // "EM DISCO;ATUALIZA;1 COPIA;NOME REL."


// PEDIDOS

// mv_par01 - Do  Produto
// mv_par02 - Até Produto
// mv_par03 - Quebra (empresa / vendedor)
// mv_par04 - Ano
// mv_par05 - Abate Impostos
// mv_par06 - Status Pedido (SEDPICO)
// mv_par07 - Da data
// mv_par08 - Ate data
// mv_par09 - Abate IPI
// mv_par10 - Abate ICM
// mv_par11 - Abate PIS
// mv_par12 - Abate COF

MV_PAR07 := MV_PAR12
MV_PAR08 := MV_PAR13
MV_PAR09 := 1
MV_PAR10 := 1
MV_PAR11 := 1
MV_PAR12 := 1

Processa( {|| Runproc3() } , "Gerando Arquivo 2" )


// FATURAMENTO

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

MV_PAR06 := "5551"
MV_PAR07 := MV_PAR14
MV_PAR08 := MV_PAR15
MV_PAR09 := 1
MV_PAR10 := 1
MV_PAR11 := 1
MV_PAR12 := 1
MV_PAR13 := 1

Processa( {|| Runproc2() } , "Gerando Arquivo 3" )

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
	
	oTemptable := FWTemporaryTable():New( "TR5")
	//oTemptable:SetFields( aStru )
	oTempTable:AddIndex("index1", {"C5_FILIAL+C5_NUM"} )
	oTempTable:Create()

	//dbUseArea(.T.,"DBFCDX","S5"+Substr(mv_par09,4,4)+Substr(mv_par09,1,2)+".DBF","TR5",.T.,.F.)
	//dbSelectArea("TR5")
	//cTrbTR5 := CriaTrab(,.F.)
	//IndRegua("TR5",cTrbTR5,"C5_FILIAL+C5_NUM",,,"SC5...")
	
	oTemptable := FWTemporaryTable():New( "TR5")
	//oTemptable:SetFields( aStru )
	oTempTable:AddIndex("index1", {"C6_FILIAL+DTOS(C6_ENTREG)+C6_NUM+C6_ITEM"} )
	oTempTable:Create()

	//dbUseArea(.T.,"DBFCDX","S6"+Substr(mv_par09,4,4)+Substr(mv_par09,1,2)+".DBF","TR6",.T.,.F.)
	//dbSelectArea("TR6")
	//cTrbTR6 := CriaTrab(,.F.)
	//IndRegua("TR6",cTrbTR6,"C6_FILIAL+DTOS(C6_ENTREG)+C6_NUM+C6_ITEM",,,"SC6...")
	
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
				mOrdem := "7"
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
				mOrdem := "7"
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


TR5->(DBCLOSEAREA())	
TR6->(DBCLOSEAREA())		

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
			mOrdem := "7"
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



//*******************************************************************************( INICIO )
STATIC FUNCTION Runproc3()

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
aAdd(aStru,{"RESI01"     ,"N",14,2})
aAdd(aStru,{"RESI02"     ,"N",14,2})
aAdd(aStru,{"RESI03"     ,"N",14,2})
aAdd(aStru,{"RESI04"     ,"N",14,2})
aAdd(aStru,{"RESI05"     ,"N",14,2})
aAdd(aStru,{"RESI06"     ,"N",14,2})
aAdd(aStru,{"RESI07"     ,"N",14,2})
aAdd(aStru,{"RESI08"     ,"N",14,2})
aAdd(aStru,{"RESI09"     ,"N",14,2})
aAdd(aStru,{"RESI10"     ,"N",14,2})
aAdd(aStru,{"RESI11"     ,"N",14,2})
aAdd(aStru,{"RESI12"     ,"N",14,2})
aAdd(aStru,{"RESI13"     ,"N",14,2})
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
aAdd(aStru,{"ITEM"       ,"C",06,0})
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
aAdd(aStru,{"RESIDUO"    ,"C",01,0})

oTemptable := FWTemporaryTable():New( "TRB")
oTemptable:SetFields( aStru )
//oTempTable:AddIndex("index1", {"COD"} )
oTempTable:Create()

//cArq := CriaTrab(aStru,.T.)
//dbUseArea(.T.,,cArq,"TRB",.T.)
//cInd := CriaTrab(NIL,.F.)

iData 	 := mv_par07 // ctod("01/01/"+mv_par04)
aEmps 	 := {"BO","FE","KI","NI","ON","BR","BI","MT"}
aEmpresa := {"BOEHLERIT","FETTE","KIENINGER","NIPPON","ONSRUD","FAB. BRASIL","BILZ","MORRIS TOOLING"}
mtit1    := "Venda "+Iif(mv_par05==2,"bruta","liquida")+" por " + Iif(mv_par03==1,"empresa","vendedor") + " " + mv_par04

abateipi := IIF(mv_par09==1,.T.,.F.)
abateicm := IIF(mv_par10==1,.T.,.F.)
abatepis := IIF(mv_par11==1,.T.,.F.)
abatecof := IIF(mv_par12==1,.T.,.F.)


//Set SoftSeek On

dbselectarea("SC5")
dbSetOrder(2)
ProcRegua(LastRec())
dbSeek(xFilial("SC5")+dtos(idata),.t.)
DO WHILE !EOF() .AND. C5_FILIAL == xFilial("SC5") .and. C5_EMISSAO <= mv_par08 // Year(C5_EMISSAO) == Year(idata) 
	IncProc("Processando dia » " + DtoC( SC5->C5_EMISSAO ) )
	If !(C5_STPAD $ mv_par06)
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
	cMes     := "REAL" + StrZero(Month(SC5->C5_EMISSAO),2)
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
//			dbSkip()
//			Loop
			cMes := "RESI" + StrZero(Month(SC5->C5_EMISSAO),2)
		Else
			cMes := "REAL" + StrZero(Month(SC5->C5_EMISSAO),2)
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
		nIpi      := SB1->B1_IPI
		If mv_par05 == 2
			mVRUNIT   := SC6->C6_PRCVEN + IIF(abateipi,0,Iif(lcalipi,(SC6->C6_PRCVEN * nIpi / 100),0))
			mVRTOTAL  := mVRUNIT * (SC6->C6_QTDVEN - IIF(SC6->C6_BLQ=="R ".AND. SC5->C5_EMISSAO >= CTOD("01/08/06"),SC6->C6_QTDENT,0))
			nIndice   := Ascan(aEmps,Left(SC6->C6_PRODUTO,2))
			If nIndice == 0
				mEmpresa := "OUTROS              "
			Else
				mEmpresa := Padr(aEmpresa[nIndice],20)
			Endif
		Else
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
			If Month(SC5->C5_EMISSAO) >= 6
				mVRUNIT   := SC6->C6_PRCVEN - IIF(abateicm,;
			             Iif(lCalIcm,(SC6->C6_PRCVEN + (SC5->C5_FRETE * (SC6->C6_VALOR / nQTot) / 100 )) * Iif(SF4->F4_INCIDE=="F",(1 + (nIpi / 100)),1) * nIcms/100,0),0) - ;
			             SC6->C6_PRCVEN * (IIF(abatepis,Iif(lCalPis,nPis,0),0) + ;
			             IIF(abatecof,Iif(lcalcof,nCof,0),0))/100
			Else
				mVRUNIT   := SC6->C6_PRCVEN - IIF(abateicm,;
			             Iif(lCalIcm,(SC6->C6_PRCVEN + 0) * ;
			             1 * nIcms/100,0),0) - ;
			             SC6->C6_PRCVEN * (IIF(abatepis,Iif(lCalPis,nPis,0),0) + ;
			             IIF(abatecof,Iif(lcalcof,nCof,0),0))/100
			
			Endif 
			mVRTOTAL  := mVRUNIT * (SC6->C6_QTDVEN - IIF(SC6->C6_BLQ=="R ".AND. SC5->C5_EMISSAO >= CTOD("01/08/06"),SC6->C6_QTDENT,0))
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
		ITEM	 := SC6->C6_ITEM
		CLIENTE	 := SA1->A1_NREDUZ			//SC5->C5_NOMECLI
		STATPED  := SC5->C5_STPAD
		EMISSAO	 := SC5->C5_EMISSAO
		VENDEDOR := SC5->C5_NOMEVEN
		PRODUTO  := SC6->C6_PRODUTO
		CODLMT	 := SC6->C6_CODLMT
		QUANT	 := SC6->C6_QTDVEN - IIF(SC6->C6_BLQ=="R ".AND. SC5->C5_EMISSAO >= CTOD("01/08/06"),SC6->C6_QTDENT,0)
		VALOR    := mVRTOTAL * nConv
		EMPRESA  := mEmpresa
		AREA	 := SA1->A1_AREA
		REGIAO	 := SA1->A1_REGIAO
		RESIDUO	 := IIF(SC6->C6_BLQ=="R ","R"," ")
		
		msUnlock()

		dbSelectArea("TRC")
		lAchou := dbSeek(mCampo)
		RecLock( "TRC" , !lAchou)
		VENDEMP		:= mCampo
		AORDEM  	:= mOrdem
		&(cMes)		+= mVRTOTAL * nConv
		TITULO1     := mTit1
		TRC->( MsUnLock() )
		
		If SC6->C6_BLQ == "R " .AND. SC6->C6_QTDENT > 0 .AND. SC5->C5_EMISSAO >= CTOD("01/08/06")
			cMes := "REAL" + StrZero(Month(SC5->C5_EMISSAO),2)

			mVRTOTAL  := mVRUNIT * SC6->C6_QTDENT

			dbSelectArea("TRB")
			RecLock("TRB",.T.)
			PEDIDO	 := SC5->C5_NUM
			ITEM	 := SC6->C6_ITEM
			CLIENTE	 := SA1->A1_NREDUZ			//SC5->C5_NOMECLI
			STATPED  := SC5->C5_STPAD
			EMISSAO	 := SC5->C5_EMISSAO
			VENDEDOR := SC5->C5_NOMEVEN
			PRODUTO  := SC6->C6_PRODUTO
			CODLMT	 := SC6->C6_CODLMT
			QUANT	 := SC6->C6_QTDENT
			VALOR    := mVRTOTAL * nConv
			EMPRESA  := mEmpresa
			AREA	 := SA1->A1_AREA
			REGIAO	 := SA1->A1_REGIAO
			RESIDUO	 := " "
			msUnlock()

			dbSelectArea("TRC")
			lAchou := dbSeek(mCampo)
			RecLock( "TRC" , !lAchou)
			VENDEMP		:= mCampo
			AORDEM  	:= mOrdem
			&(cMes)		+= mVRTOTAL * nConv
			TITULO1     := mTit1
			TRC->( MsUnLock() )
		Endif		

		dbSelectArea("SC6")
		dbSkip()
	Enddo
	dbSelectArea("SC5")
	dbSkip()
Enddo

If mv_par03 == 1

	SZ5->( DbSetOrder( 1 ) )                           
	SZ5->( DbSeek( xFilial( "SZ5" ) + "A" ) )

	While !SZ5->( Eof() ) .and. SZ5->Z5_FILIAL == xFilial( "SZ5" ) .and. SZ5->Z5_TIPO == "A"
		cMarcax	:= IF( SZ5->Z5_MARCA == "BR" , "FA" , SZ5->Z5_MARCA )

		If Str( SZ5->Z5_ANO , 4 ) = mv_par04 //.and. !TRC->( DbSeek( cMarcax ) )

			nIndice := Ascan(aEmps,SZ5->Z5_MARCA)
			If nIndice == 0
				mCampo := "OUTROS              "
				mOrdem := "7"
			Else
				mCampo := Padr(aEmpresa[nIndice],20)
				mOrdem := StrZero(nIndice,1)
			Endif
			lAchou := TRC->( DbSeek( cMarcax ) )
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

Else

	SZ5->( DbSetOrder( 2 ) )
	SA3->( DbSetOrder( 1 ) )
	SA3->( DbSeek( xFilial( "SA3" ) ) )
	
	While !SA3->( Eof() ) .and. SA3->A3_FILIAL == xFilial( "SA3" )

		SZ5->( DbSeek( xFilial( "SZ5" ) + "B" + SA3->A3_COD ) )
	
		While !SZ5->( Eof() ) .and. SZ5->Z5_FILIAL == xFilial( "SZ5" ) .and. SZ5->Z5_TIPO == "B" .and. ;
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

EndIf

dbSelectArea("TRC")
dbGotop()
do While !EOF()
	RecLock("TRC",.F.)
	PREV13:=PREV01+PREV02+PREV03+PREV04+PREV05+PREV06+PREV07+PREV08+PREV09+PREV10+PREV11+PREV12
	REAL13:=REAL01+REAL02+REAL03+REAL04+REAL05+REAL06+REAL07+REAL08+REAL09+REAL10+REAL11+REAL12
	RESI13:=RESI01+RESI02+RESI03+RESI04+RESI05+RESI06+RESI07+RESI08+RESI09+RESI10+RESI11+RESI12
	msUnlock()
	dbSkip()
Enddo
ferase("\SIGAADV\SAIDAV.DBF")
dbselectarea("TRB")
dbgotop()
//COPY TO "\BACKUP\CART\SAIDAV"+CDATA
TRB->(DBCLOSEAREA())

ferase("\DADOSADV\_VEND.DBF")
dbselectarea("TRC")
dbgotop()
//COPY TO "\DADOSADV\_VEND.DBF"
Processa({||CpyS2T("\DADOSADV\_VEND.DBF","C:\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
ferase("\DADOSADV\_VEND.DBF")
TRC->(DBCLOSEAREA())
mTESTE := "1;0;1;GIS"  // "EM DISCO;ATUALIZA;1 COPIA;NOME REL."

//Set SoftSeek Off
Return



Return

//*******************************************************************************( INICIO )
STATIC FUNCTION Runproc2()

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

oTemptable := FWTemporaryTable():New( "TRC")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"VENDEMP"} )
oTempTable:Create()

//cArq := CriaTrab(aStru,.T.)
//dbUseArea(.T.,,cArq,"TRC",.T.)
//cInd := CriaTrab(NIL,.F.)
//IndRegua("TRC",cInd,"VENDEMP",,,"Selecionando Registros...")

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
aAdd(aStru,{"ITEMPV"     ,"C",02,0})
aAdd(aStru,{"REGIAO"     ,"C",03,0})
aAdd(aStru,{"AREA"       ,"C",06,0})

//aAdd(aStru,{"TES"        ,"C",03,0})
//aAdd(aStru,{"CUSTO"      ,"N",14,3})

oTemptable := FWTemporaryTable():New( "TRB")
oTemptable:SetFields( aStru )
//oTempTable:AddIndex("index1", {"COD"} )
oTempTable:Create()

//cArq := CriaTrab(aStru,.T.)
//dbUseArea(.T.,,cArq,"TRB",.T.)
//cInd := CriaTrab(NIL,.F.)


iData 	 := MV_PAR07 // ctod("01/01/"+mv_par04)
aEmps 	 := {"BO","FE","KI","NI","ON","BR","BI","MT"}
aEmpresa := {"BOEHLERIT","FETTE","KIENINGER","NIPPON","ONSRUD","FAB. BRASIL","BILZ","MORRINS TOOLING"}
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
	
	If Year(D2_EMISSAO)>2004
		dbSelectArea("SF4")
		dbSetOrder(1)
		dbSeek(xFilial("SF4") + SD2->D2_TES)
		If F4_DUPLIC == "N" .OR. F4_CF $ mv_par06 .or. SD2->D2_TIPO == "D"
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
	If !Empty(C5_VEND2) .and. mv_par03==2
		cCodVend2	:= C5_VEND2
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
	cMes     := "REAL"  + StrZero(Month(SD2->D2_EMISSAO),2)
	cMes2    := "REAL2" + StrZero(Month(SD2->D2_EMISSAO),2)
	cMes3	 := "VAR"	+ StrZero(Month(SD2->D2_EMISSAO),2)
	If mv_par03 == 2
		mCampo := cVend
		mOrdem := " "
	Else
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
	If mv_par05 == 2
		mVRTOTAL 	:= SD2->D2_TOTAL + IIF(SD2->D2_TIPO=="P", 0 , SD2->D2_VALIPI) + SD2->D2_VALFRE
		mVRTOTAL2	:= mVRTOTAL
		If mv_par09 == 1
			dbSelectArea("SB1")
			dbSetOrder(1)
			dbSeek(xFilial("SB1") + SD2->D2_COD)
			dbSelectArea("SC5")
			dbSetORder(1)
			dbSeek(xFIlial("SC6") + SD2->D2_PEDIDO)
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
				mVRTOTAL2 := mVRUNIT * SD2->D2_QUANT * nConv
				mvar	  := iif(mvrtotal2>0,mVRTOTAL - mVRTOTAL2,0)
			Endif
		Endif
	Else
		mVRTOTAL	:= SD2->D2_TOTAL + iif(abateipi,0,IIF(SD2->D2_TIPO=="P", 0 , SD2->D2_VALIPI))- iif(abateicm,SD2->D2_VALICM,0) - SD2->D2_VALIMP1 - SD2->D2_VALIMP2 - SD2->D2_VALIMP3 - SD2->D2_VALIMP4 - iif(abatepis,SD2->D2_VALIMP5,0) - iif(abatecof,SD2->D2_VALIMP6,0)
		mVRTOTAL2	:= mVRTOTAL
		If mv_par09 == 1
			dbSelectArea("SB1")
			dbSetORder(1)
			dbSeek(xFilial("SB1") + SD2->D2_COD)
			dbSelectArea("SC5")
			dbSetORder(1)
			dbSeek(xFIlial("SC6") + SD2->D2_PEDIDO)
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
				mVRTOTAL2 := mVRUNIT * SD2->D2_QUANT * nConv
				mvar	  := iif(mvrtotal2>0,mVRTOTAL - mVRTOTAL2,0)
			Endif
		Endif
	Endif
	
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
	ITEMPV	 := SD2->D2_ITEMPV
	AREA	 := SA1->A1_AREA
	REGIAO	 := SA1->A1_REGIAO
	//	MARCA    := mEmpresa
	
	//	TRB->TES		:= SD2->D2_TES
	//	TRB->CUSTO		:= SD2->D2_CUSTO1 * (nPerc1 / 100)
	
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
		CODLMT	 := SD2->D2_CODLMT
		ESPECIF  := IF( Left( SD2->D2_COD , 2 ) == "KI" , Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DENOM") , "" )
		QTDADE	 := SD2->D2_QUANT * (nPerc2 / 100)
		VALORFAT := mVrtotal * (nPerc2 / 100)
		VALORPED := mVrtotal2* (nPerc2 / 100)
		PEDIDO	 := SD2->D2_PEDIDO
		AREA	 := SA1->A1_AREA
		REGIAO	 := SA1->A1_REGIAO
		
		//		MARCA    := mEmpresa
		
		//		TRB->TES		:= SD2->D2_TES
		//		TRB->CUSTO		:= SD2->D2_CUSTO1 * (nPerc2 / 100)
		
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
	
	If SD1->D1_TIPO <> "D"
		dbSkip()
		Loop
	Endif
	dbSelectArea("SF4")
	dbSetOrder(1)
	dbSeek(xFilial("SF4") + SD1->D1_TES)
	If F4_DUPLIC == "N" .OR. F4_CF $ mv_par06
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
			mOrdem := "7"
		Else
			mCampo := Padr(aEmpresa[nIndice],20)
			mOrdem := StrZero(nIndice,1)
		Endif
	Endif
	If mv_par05 == 2
		mVRTOTAL 	:= (SD1->D1_TOTAL-SD1->D1_VALDESC + iif(abateipi,0,SD1->D1_VALIPI) + SD1->D1_VALFRE) * (-1)
	Else
		mVRTOTAL	:= (SD1->D1_TOTAL-SD1->D1_VALDESC - iif(abateicm,SD1->D1_VALICM,0) - SD1->D1_VALIMP1 - SD1->D1_VALIMP2 - SD1->D1_VALIMP3 - SD1->D1_VALIMP4 - iif(abatepis,SD1->D1_VALIMP5,0) - iif(abatecof,SD1->D1_VALIMP6,0)) * (-1)
	Endif
	
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
	AREA	 := SA1->A1_AREA
	REGIAO	 := SA1->A1_REGIAO
	
	//	MARCA    := mEmpresa
	
	//	TRB->TES		:= SD1->D1_TES
	//	TRB->CUSTO		:= ( SD1->D1_CUSTO * (nPerc1 / 100) ) *-1
	
	msUnlock()
	
	********** WILSON - INICIO - 06/05/04
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
		CODLMT	 := SD1->D1_CODLMT
		ESPECIF  := IF( Left( SD1->D1_COD , 2 ) == "KI" , Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_DENOM") , "" )
		QTDADE	 := SD1->D1_QUANT * (nPerc2 / 100)
		VALORFAT := mVrtotal * (nPerc2 / 100)
		AREA	 := SA1->A1_AREA
		REGIAO	 := SA1->A1_REGIAO
		
		//		MARCA    := mEmpresa
		
		//		TRB->TES		:= SD1->D1_TES
		//		TRB->CUSTO		:= ( SD1->D1_CUSTO * (nPerc2 / 100) ) * -1
		
		msUnlock()
	EndIf
	********** WILSON - FINAL  - 06/05/04
	
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
	
	SZ5->( DbSetOrder( 1 ) )
	SZ5->( DbSeek( xFilial( "SZ5" ) + "M" ) )
	
	While !SZ5->( Eof() ) .and. SZ5->Z5_FILIAL == xFilial( "SZ5" ) .and. SZ5->Z5_TIPO == "M"
		cMarcax	:= IF( SZ5->Z5_MARCA == "BR" , "FA" , SZ5->Z5_MARCA )
		
		If Str( SZ5->Z5_ANO , 4 ) = mv_par04 //.and. !TRC->( DbSeek( cMarcax ) )
			
			nIndice := Ascan(aEmps,SZ5->Z5_MARCA)
			If nIndice == 0
				mCampo := "OUTROS              "
				mOrdem := "7"
			Else
				mCampo := Padr(aEmpresa[nIndice],20)
				mOrdem := StrZero(nIndice,1)
			Endif
			lAchou := TRC->( DbSeek( cMarcax ) )
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
	
Else
	
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

ferase("\SIGAADV\SAIDAF.DBF")
dbselectarea("TRB")
dbgotop()
//COPY TO "\BACKUP\CART\SAIDAF"+CDATA
TRB->(DBCLOSEAREA())

ferase("\DADOSADV\_VEND.DBF")
dbselectarea("TRC")
dbgotop()
//COPY TO "\DADOSADV\_VEND.DBF"
Processa({||CpyS2T("\DADOSADV\_VEND.DBF","C:\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
ferase("\DADOSADV\_VEND.DBF")
TRC->(DBCLOSEAREA())

mTESTE := "1;0;1;GIS"  // "EM DISCO;ATUALIZA;1 COPIA;NOME REL."

//Set SoftSeek Off

Return


















// *----------------------------------------------------------------------------
Static Function AjustaSX1()
aPerg    := {}
//cPerg    := "CCCCCC"

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
