#INCLUDE "rwmake.ch"

// Rotina		: VENDAL
// Descrição	: Venda Liquida
// Data			: 20/01/05
// Autor        : Daniel Gondran
//27/11/08 - Fernando  - Incluir BILZ

User Function VENDAL()
Private oProcess 

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
// mv_par13 - Abate ISS
//cPerg := "VENDAL"
cPerg    := PadR( 'VENDAL' , Len( SX1->X1_GRUPO ) )
AjustaSX1()
Pergunte(cPerg,.F.)

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Venda Liquida Anual"
@ 70,080 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg,.t.)
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
    oProcess := MsNewProcess():New( { ||  Runproc(@oProcess, @lEnd)  } , "Gerando Arquivo..." , "Aguarde..." , .F. )
    oProcess:Activate()	
     

Return

//*******************************************************************************( INICIO )
STATIC FUNCTION Runproc(oProcess, lEnd)
Local oTempTable
Local aStru		:= {}
Local aStru1	:= {}
Local cAlias1	:= "TRC"               
Local cAlias2	:= "TRB"
Local kkk
Local _nX

Local _oExcel   := Nil

Local _cPlan1   := ""
Local _cTab1    := _cPlan1

Local _cPlan2   := ""
Local _cTab2    := _cPlan2
Loca _nTotR1    :=  0

Local cDetal     := ""
Local cCabec     := ""

//-------------------
//Criação do objeto
//-------------------
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

oTemptable:SetFields( aStru )
oTempTable:AddIndex("indice1", {"VENDEMP"} )
//------------------
//Criação da tabela
//------------------
oTempTable:Create()
///////////////////////////////////////////////////////////////////////////////////////////////// Tabela 1

//-------------------
//Criação do objeto
//-------------------
oTempTable := FWTemporaryTable():New( cAlias2 )

aAdd(aStru1,{"PEDIDO"     ,"C",06,0})
aAdd(aStru1,{"ITEM"       ,"C",06,0})
aAdd(aStru1,{"CLIENTE"    ,"C",20,0})
aAdd(aStru1,{"STATPED"    ,"C",01,0})
aAdd(aStru1,{"EMISSAO"    ,"D",10,0})
aAdd(aStru1,{"VENDEDOR"   ,"C",20,0})
aAdd(aStru1,{"PRODUTO"    ,"C",15,0})
aAdd(aStru1,{"CODLMT"     ,"C",46,0})
aAdd(aStru1,{"EMPRESA"    ,"C",20,0})
aAdd(aStru1,{"QUANT"      ,"N",14,2})
aAdd(aStru1,{"VALOR"      ,"N",14,2})
aAdd(aStru1,{"REGIAO"     ,"C",03,0})
aAdd(aStru1,{"AREA"       ,"C",06,0})
aAdd(aStru1,{"RESIDUO"    ,"C",01,0})
aAdd(aStru1,{"TRANSPR"    ,"N",14,2})
aAdd(aStru1,{"GRUPO"      ,"C",04,0})
aAdd(aStru1,{"SUPERGRP"   ,"C",03,0})
aAdd(aStru1,{"CFOP"       ,"C",05,0})

oTemptable:SetFields( aStru1 )
//------------------
//Criação da tabela
//------------------
oTempTable:Create()

iData 	 := mv_par07 // ctod("01/01/"+mv_par04)
aEmps 	 := {"BO","FE","KI","NI","ON","BI","BR","MT","HO"}
aEmpresa := {"BOEHLERIT","FETTE","KIENINGER","NIPPON","ONSRUD","BILZ","FAB. BRASIL","MORRIS TOOLING","HORN"}
mtit1    := "Venda "+Iif(mv_par05==2,"bruta","liquida")+" por " + Iif(mv_par03==1,"empresa","vendedor") + " " + mv_par04

abateipi := IIF(mv_par09==1,.T.,.F.)
abateicm := IIF(mv_par10==1,.T.,.F.)
abatepis := IIF(mv_par11==1,.T.,.F.)
abatecof := IIF(mv_par12==1,.T.,.F.)
abateiss := IIF(mv_par13==1,.T.,.F.)

//Set SoftSeek On

dbselectarea("SC5")
dbSetOrder(2)
ProcRegua(LastRec())
dbSeek(xFilial("SC5")+dtos(idata),.t.)
DO WHILE !EOF() .AND. C5_FILIAL == xFilial("SC5") .and. C5_EMISSAO <= mv_par08 // Year(C5_EMISSAO) == Year(idata)
	IncProc("Processando dia » " + DtoC( SC5->C5_EMISSAO ) )
/*
	If !SC6->C6_NUM $ ('117030,117031,117032,117033')
		dbSelectArea("SC5")
		SC5->(dbSkip()) 
		Loop
	Endif
*/                

	If !(SC5->C5_STPAD $ mv_par06)
		dbSelectArea("SC5")
		SC5->(dbSkip()) 
		loop
	Endif
	SA1->( dbSetOrder(1) )
	SA1->( dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI) )
	cVend 	 := SC5->C5_NOMEVEN
	nMoeda   := SC5->C5_MOEDA
	If nMoeda <> 1
		cMoeda := "M2_MOEDA" + StrZero(nMoeda,1)
		dbSelectArea("SM2")
		If dbSeek(DTOS(SC5->C5_EMISSAO),.f.)
			nConv  := &(cMoeda)
		Else
			nConv := 0
		EndIf
		If nConv == 0
			Alert ("Atenção: Cadastrar Moeda " + StrZero(nMoeda,1) + " no dia " + Dtoc(SC5->C5_EMISSAO))
		Endif
		
	Else
		nConv := 1
	Endif

	cMes     := "REAL" + StrZero(Month(SC5->C5_EMISSAO),2)
	nQTot := 0

	dbSelectArea("SC6")
	dbSetOrder(1)
	dbSeek(xFilial("SC6") + SC5->C5_NUM)

	do While !Eof() .and. C6_FILIAL == xFilial("SC6") .and. C6_NUM == SC5->C5_NUM
		nQTot += SC6->C6_VALOR
		dbSkip()
	Enddo
	
	dbSelectArea("SC6")
	dbSetOrder(1)
	dbSeek(xFilial("SC6") + SC5->C5_NUM)
	do While !Eof() .and. C6_FILIAL == xFilial("SC6") .and. C6_NUM == SC5->C5_NUM
		If SC6->C6_BLQ == "R "
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
				mOrdem := "10"
			Else
				mCampo := Padr(aEmpresa[nIndice],20)
				mOrdem := StrZero(nIndice,1)
			Endif
		Endif
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFIlial("SB1") + SC6->C6_PRODUTO)
		nIpi      := SB1->B1_IPI
		nIss      := SB1->B1_ALIQISS
		If !abateiss  
		   nIss := 0
		Endif
		If mv_par05 == 2
			nValIss := (SC6->C6_PRCVEN * (IIF(abateiss,nIss,0))/100)
			mVRUNIT   := SC6->C6_PRCVEN + IIF(abateipi,0,Iif(lcalipi,(SC6->C6_PRCVEN * nIpi / 100),0))
			mVRTOTAL  := (mVRUNIT-nValIss) * (SC6->C6_QTDVEN - IIF(SC6->C6_BLQ=="R ".AND. SC5->C5_EMISSAO >= CTOD("01/08/06"),SC6->C6_QTDENT,0))
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
				If Substr(SC6->C6_CLASFIS,1,1)$"1|2|3|4|5|6" .and. Substr(SC6->C6_CLASFIS,2,2)$"00|10|20|70|90" .and. SF4->F4_CONSUMO="N" .and. !Empty(SA1->A1_INSCR)
					nIcms := 4
				EndIf
			ElseIf SA1->A1_EST == "SP"
				If SB1->B1_PICM > 0
					nIcms := SB1->B1_PICM
				Else
					nIcms := 18
				Endif
			Else
				nIcms := 12
				If Substr(SC6->C6_CLASFIS,1,1)$"1|2|3|4|5|6" .and. Substr(SC6->C6_CLASFIS,2,2)$"00|10|20|70|90" .and. SF4->F4_CONSUMO="N" .and. !Empty(SA1->A1_INSCR)
					nIcms := 4
				EndIf
			Endif  
			If !lcalicm     
			   nIcms := 0
			Endif
			nCof := GetMV("MV_TXCOFIN")
			nPis := GetMV("MV_TXPIS")
			If !lcalpis 
			   nPis := 0
			Endif
			If !lcalcof 
               nCof := 0
            Endif
			BASE1:=0
			If Month(SC5->C5_EMISSAO) >= 1
				IF ABATEICM
					BASE1 := SC6->C6_PRCVEN + SC5->C5_FRETE * (SC6->C6_PRCVEN / nQTot)
					BASE := BASE1 * Iif(SF4->F4_INCIDE $ "F/S",(1 + (nIpi / 100)),1)
					nnicms := BASE * nIcms/100
				ELSE
					nnicms := 0
				Endif
				mVRUNIT   := SC6->C6_PRCVEN - NNICMS - BASE1 * (IIF(abatepis,Iif(lCalPis,nPis,0),0) + ;
				IIF(abatecof,Iif(lcalcof,nCof,0),0))/100
			Else
				mVRUNIT   := SC6->C6_PRCVEN - IIF(abateicm,;
				Iif(lCalIcm,(SC6->C6_PRCVEN + 0) * ;
				1 * nIcms/100,0),0) - ;
				SC6->C6_PRCVEN * (IIF(abatepis,Iif(lCalPis,nPis,0),0) + ;
				IIF(abatecof,Iif(lcalcof,nCof,0),0))/100  
			Endif           
			nValIss := (SC6->C6_PRCVEN * (IIF(abateiss,nIss,0))/100)
			mVRTOTAL  := (mVRUNIT-nValIss) * (SC6->C6_QTDVEN - IIF(SC6->C6_BLQ=="R ".AND. SC5->C5_EMISSAO >= CTOD("01/08/06"),SC6->C6_QTDENT,0))
		Endif
		
		nIndice   := Ascan(aEmps,Left(SC6->C6_PRODUTO,2))
		If nIndice == 0
			mEmpresa := "OUTROS              "
		Else
			mEmpresa := Padr(aEmpresa[nIndice],20)
		Endif
		
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1") + SC6->C6_PRODUTO)
		
		dbSelectArea("SBM")
		dbSetOrder(1)
		dbSeek(xFilial("SB1") + SB1->B1_GRUPO )
		
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
		PEDIDO	 := SC5->C5_NUM
		ITEM	 := SC6->C6_ITEM
		CLIENTE	 := SA1->A1_NREDUZ			//SC5->C5_NOMECLI
		STATPED  := SC5->C5_STPAD
		EMISSAO	 := SC5->C5_EMISSAO
		//		VENDEDOR := SC5->C5_NOMEVEN
		VENDEDOR := Posicione( "SA3" , 1 , xFilial( "SA3" ) + SC5->C5_VEND1 , "A3_NREDUZ" )
		PRODUTO  := SC6->C6_PRODUTO
		CODLMT	 := SC6->C6_CODLMT
		QUANT	 := ( SC6->C6_QTDVEN - IIF(SC6->C6_BLQ=="R ".AND. SC5->C5_EMISSAO >= CTOD("01/08/06"),SC6->C6_QTDENT,0) ) * nPerc1
		VALOR    := ( mVRTOTAL * nConv * nPerc1 )
		EMPRESA  := mEmpresa
		AREA	 := SA1->A1_AREA
		REGIAO	 := SA1->A1_REGIAO
		RESIDUO	 := IIF(SC6->C6_BLQ=="R ","R"," ")
		TRANSPR	 := SB1->B1_TRANSPR
		GRUPO	 := SB1->B1_GRUPO
		if SB1->B1_SUPERGR <> SPACE(3)
			SUPERGRP := SB1->B1_SUPERGR
		else
			SUPERGRP := SBM->BM_ORDEM
		endif
		CFOP     := SC6->C6_CF
		msUnlock()
		
		If	lDoisV
			dbSelectArea("TRB")
			RecLock("TRB",.T.)
			PEDIDO	 := SC5->C5_NUM
			ITEM	 := SC6->C6_ITEM
			CLIENTE	 := SA1->A1_NREDUZ			//SC5->C5_NOMECLI
			STATPED  := SC5->C5_STPAD
			EMISSAO	 := SC5->C5_EMISSAO
			//			VENDEDOR := SC5->C5_NOMEVEN
			VENDEDOR := Posicione( "SA3" , 1 , xFilial( "SA3" ) + SC5->C5_VEND2 , "A3_NREDUZ" )
			PRODUTO  := SC6->C6_PRODUTO
			CODLMT	 := SC6->C6_CODLMT
			QUANT	 := ( SC6->C6_QTDVEN - IIF(SC6->C6_BLQ=="R ".AND. SC5->C5_EMISSAO >= CTOD("01/08/06"),SC6->C6_QTDENT,0) ) * nPerc2
			VALOR    := ( mVRTOTAL * nConv * nPerc2 )
			EMPRESA  := mEmpresa
			AREA	 := SA1->A1_AREA
			REGIAO	 := SA1->A1_REGIAO
			RESIDUO	 := IIF(SC6->C6_BLQ=="R ","R"," ")
			TRANSPR	 := SB1->B1_TRANSPR
			GRUPO	 := SB1->B1_GRUPO
			//    		SUPERGRP := SBM->BM_ORDEM
			if SB1->B1_SUPERGR <> SPACE(3)
				SUPERGRP := SB1->B1_SUPERGR
			else
				SUPERGRP := SBM->BM_ORDEM
			endif
			CFOP     := SC6->C6_CF
			msUnlock()
		EndIf
		
		If	mv_par03 # 2
			dbSelectArea("TRC")
			lAchou := dbSeek(mCampo)
			RecLock( "TRC" , !lAchou)
			VENDEMP		:= mCampo
			AORDEM  	:= mOrdem
			&(cMes)		+= mVRTOTAL * nConv
			TITULO1     := mTit1
			TRC->( MsUnLock() )
		Else
			mCampo	:= Left( Posicione( "SA3" , 1 , xFilial( "SA3" ) + SC5->C5_VEND1 , "A3_NREDUZ" ) , 20 )
			dbSelectArea("TRC")
			lAchou := dbSeek(mCampo)
			RecLock( "TRC" , !lAchou)
			VENDEMP		:= mCampo
			AORDEM  	:= mOrdem
			&(cMes)		+= ( mVRTOTAL * nConv * nPerc1 )
			TITULO1     := mTit1
			TRC->( MsUnLock() )
			
			If	lDoisV
				mCampo	:= Left( Posicione( "SA3" , 1 , xFilial( "SA3" ) + SC5->C5_VEND2 , "A3_NREDUZ" ) , 20 )
				dbSelectArea("TRC")
				lAchou := dbSeek(mCampo)
				RecLock( "TRC" , !lAchou)
				VENDEMP		:= mCampo
				AORDEM  	:= mOrdem
				&(cMes)		+= ( mVRTOTAL * nConv * nPerc2 )
				TITULO1     := mTit1
				TRC->( MsUnLock() )
			EndIf
			
		EndIf
		
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
			//			VENDEDOR := SC5->C5_NOMEVEN
			VENDEDOR := Posicione( "SA3" , 1 , xFilial( "SA3" ) + SC5->C5_VEND1 , "A3_NREDUZ" )
			PRODUTO  := SC6->C6_PRODUTO
			CODLMT	 := SC6->C6_CODLMT
			QUANT	 := ( SC6->C6_QTDENT * nPerc1 )
			VALOR    := ( mVRTOTAL * nConv * nPerc1 )
			EMPRESA  := mEmpresa
			AREA	 := SA1->A1_AREA
			REGIAO	 := SA1->A1_REGIAO
			RESIDUO	 := " "
			GRUPO	 := SB1->B1_GRUPO
			//    		SUPERGRP := SBM->BM_ORDEM
			if SB1->B1_SUPERGR <> SPACE(3)
				SUPERGRP := SB1->B1_SUPERGR
			else
				SUPERGRP := SBM->BM_ORDEM
			endif
			CFOP     := SC6->C6_CF
			msUnlock()
			
			If lDoisV
				dbSelectArea("TRB")
				RecLock("TRB",.T.)
				PEDIDO	 := SC5->C5_NUM
				ITEM	 := SC6->C6_ITEM
				CLIENTE	 := SA1->A1_NREDUZ			//SC5->C5_NOMECLI
				STATPED  := SC5->C5_STPAD
				EMISSAO	 := SC5->C5_EMISSAO
				//				VENDEDOR := SC5->C5_NOMEVEN
				VENDEDOR := Posicione( "SA3" , 1 , xFilial( "SA3" ) + SC5->C5_VEND2 , "A3_NREDUZ" )
				PRODUTO  := SC6->C6_PRODUTO
				CODLMT	 := SC6->C6_CODLMT
				QUANT	 := ( SC6->C6_QTDENT * nPerc2 )
				VALOR    := ( mVRTOTAL * nConv * nPerc2 )
				EMPRESA  := mEmpresa
				AREA	 := SA1->A1_AREA
				REGIAO	 := SA1->A1_REGIAO
				RESIDUO	 := " "
				GRUPO	 := SB1->B1_GRUPO
				//        		SUPERGRP := SBM->BM_ORDEM
				if SB1->B1_SUPERGR <> SPACE(3)
					SUPERGRP := SB1->B1_SUPERGR
				else
					SUPERGRP := SBM->BM_ORDEM
				endif
				CFOP     := SC6->C6_CF
				msUnlock()
			EndIf
			
			If	mv_par03 # 2
				dbSelectArea("TRC")
				lAchou := dbSeek(mCampo)
				RecLock( "TRC" , !lAchou)
				VENDEMP		:= mCampo
				AORDEM  	:= mOrdem
				&(cMes)		+= mVRTOTAL * nConv
				TITULO1     := mTit1
				TRC->( MsUnLock() )
			Else
				mCampo	:= Left( Posicione( "SA3" , 1 , xFilial( "SA3" ) + SC5->C5_VEND1 , "A3_NREDUZ" ) , 20 )
				dbSelectArea("TRC")
				lAchou := dbSeek(mCampo)
				RecLock( "TRC" , !lAchou)
				VENDEMP		:= mCampo
				AORDEM  	:= mOrdem
				&(cMes)		+= ( mVRTOTAL * nConv * nPerc1 )
				TITULO1     := mTit1
				TRC->( MsUnLock() )
				
				If lDoisV
					mCampo	:= Left( Posicione( "SA3" , 1 , xFilial( "SA3" ) + SC5->C5_VEND2 , "A3_NREDUZ" ) , 20 )
					dbSelectArea("TRC")
					lAchou := dbSeek(mCampo)
					RecLock( "TRC" , !lAchou)
					VENDEMP		:= mCampo
					AORDEM  	:= mOrdem
					&(cMes)		+= ( mVRTOTAL * nConv * nPerc2 )
					TITULO1     := mTit1
					TRC->( MsUnLock() )
				EndIf
			EndIf
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
		cMarcax := AllTrim(cMarcax)
		If Str( SZ5->Z5_ANO , 4 ) = mv_par04 //.and. !TRC->( DbSeek( cMarcax ) )
			
			nIndice := Ascan(aEmps,SZ5->Z5_MARCA)
			If nIndice == 0
				mCampo := "OUTROS              "
				mOrdem := "10"
			Else
				mCampo := Padr(aEmpresa[nIndice],20)
				mOrdem := StrZero(nIndice,1)
			Endif
			dbSelectArea("TRC")
            TRC->(dbGoTop())
//			lAchou := TRC->(DbSeek(cMarcax))
			lAchou := dbSeek(mCampo)
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
				lAchou := TRC->( DbSeek( Left( SA3->A3_NREDUZ , 20 ) ) )
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

_cPathJob:= 'C:\TEMP\'
_cArq    := "SAIDAV"+"_"+DTOS(DATE())+"_"+SUBSTR(TIME(),1,2)+"_"+SUBSTR(TIME(),4,2)+"_"+SUBSTR(TIME(),7,2)+".CSV"
cDestino := PADR(_cPathJob+_cArq, 100)

cCabec:=""
//Monta Cabeçalho Relatório
For _nX:=1 To Len(aStru1)
	cCabec+= aStru1[_nX,1]+";" 
Next _nX

cCabec:=SubStr(cCabec,1,Len(cCabec)-1)
u_ArqLog(cCabec,cDestino,"")

cDetal:=""

dbselectarea("TRB")
dbgotop() 


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
	oProcess:IncRegua2('Pedido de Venda...  '  + Alltrim(TRB->PEDIDO)   ) 
 	
    cDetal:=""
	cDetal+= TRB->PEDIDO+";"+TRB->ITEM+";"+TRB->CLIENTE+";"+TRB->STATPED+";"
	cDetal+= cValToChar(TRB->EMISSAO)+";"+TRB->VENDEDOR+";"+TRB->PRODUTO+";"+TRB->CODLMT+";"+TRB->EMPRESA+";"
	cDetal+= cValToChar(TRB->QUANT)+";"+StrTran(cValToChar(TRB->VALOR),".", ",")+";"+TRB->REGIAO+";"+TRB->AREA+";"+TRB->RESIDUO+";"+StrTran(cValToChar(TRB->TRANSPR),".", ",")+";"+TRB->GRUPO+";"+TRB->SUPERGRP+";"+TRB->CFOP

	u_ArqLog(cDetal,cDestino,"")
									
	TRB->(DbSkip())
End

//Carrega EXCEL
If valType(_oExcel) == "O" .and. !Empty(_oExcel:aWorkSheet)
	_oExcel:Activate()
	_oExcel:GetXMLFile(_cPathJob+_cArq)
	
Else
////	Alert("Não existem registros para impressao.")
EndIf

MsgBox("Foi gerado o arquivo SAIDAV na pasta: "+CHR(10)+cDestino,"Atenção","ALERT")

//If !U_MLSCpyFile(cFileName,cDestino)
//	MsgStop("Nao foi possivel gerar o arquivo."+CHR(13)+CHR(10)+cDestino+CHR(13)+CHR(10)+" Verifique se está sendo utilizado.")
//ELSE
//	MsgBox("Foi gerado o arquivo SAIDAV na pasta: "+CHR(13)+CHR(10)+cDestino,"Atenção","ALERT")

//mgp

	If ApOleClient("MsExcel")  
	oExcelApp:= MsExcel():New()
		oExcelApp:WorkBooks:Open(cDestino)
		oExcelApp:SetVisible(.T.)
	EndIf

//EndIf

TRB->(DBCLOSEAREA())

_cPathJob:= 'C:\TEMP\'
//_cArq    := "_VEND.CSV"
_cArq    := "VEND"+"_"+DTOS(DATE())+"_"+SUBSTR(TIME(),1,2)+"_"+SUBSTR(TIME(),4,2)+"_"+SUBSTR(TIME(),7,2)+".CSV"
cDestino := PADR(_cPathJob+_cArq, 100)

dbselectarea("TRC")
dbgotop()

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
	cDetal+= TRC->AORDEM   + ";"
	cDetal+= TRC->VENDEMP  + ";"
	cDetal+= StrTran(cValToChar(TRC->PREV01),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->PREV02),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->PREV03),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->PREV04),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->PREV05),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->PREV06),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->PREV07),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->PREV08),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->PREV09),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->PREV10),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->PREV11),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->PREV12),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->PREV13),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->REAL01),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->REAL02),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->REAL03),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->REAL04),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->REAL05),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->REAL06),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->REAL07),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->REAL08),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->REAL09),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->REAL10),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->REAL11),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->REAL12),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->REAL13),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->RESI01),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->RESI02),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->RESI03),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->RESI04),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->RESI05),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->RESI06),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->RESI07),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->RESI08),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->RESI09),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->RESI10),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->RESI11),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->RESI12),".", ",")   + ";"
	cDetal+= StrTran(cValToChar(TRC->RESI13),".", ",")   + ";"
	cDetal+= cValToChar(TRC->TITULO1)  + ";"
	cDetal+= cValToChar(TRC->TITULO2)  
	
	u_ArqLog(cDetal,cDestino,"")
	TRC->(DbSkip())
EndDo
//Criando o objeto que irá gerar o conteúdo do Excel
//_oExcel := FWMsExcelEx():New()

//Aba 01 - Teste
//_oExcel:AddWorkSheet("Plan_1")
//Criando a Tabela
//_oExcel:AddTable("Plan_1","Titulo Tabela")

//Monta Cabeçalho Relatório
/*For _nX:=1 To Len(aStru)
	_oExcel:AddColumn(_cPlan1,_cTab1,aStru[_nX,1] ,IIF(ValType(aStru[_nX,2])=="N",3,1),IIF(ValType(aStru[_nX,2])=="N",3,1),.F.) //0U1
Next _nX*/

/*_oExcel:SetHeaderBold(.T.)
_oExcel:SetFrColorHeader("#363636")
_oExcel:SetBgColorHeader("#EE9572")
_oExcel:SetLineFrColor("#000000")
_oExcel:Set2LineFrColor("#000000")
_oExcel:SetLineBgColor("#FFFFFF")
_oExcel:Set2LineBgColor("#FFFFFF")

_oExcel:AddWorkSheet(_cPlan1)
_oExcel:AddTable(_cPlan1,_cTab1)

//Monta Cabeçalho Relatório
For _nX:=1 To Len(aStru)
	_oExcel:AddColumn(_cPlan1,_cTab1,aStru[_nX,1] ,IIF(ValType(aStru[_nX,2])=="N",3,1),IIF(ValType(aStru[_nX,2])=="N",3,1),.F.) //0U1
Next _nX
*/
//dbselectarea("TRC")
//dbgotop()                       
//While TRC->(!EOF())
    
	/*_oExcel:AddRow("Plan_1","Titulo Tabela",{ TRC->AORDEM,;
									TRC->VENDEMP,;
									TRC->PREV01,;
									TRC->PREV02,;
									TRC->PREV03,;
									TRC->PREV04,;
									TRC->PREV05,;
									TRC->PREV06,;
									TRC->PREV07,;
									TRC->PREV08,;
									TRC->PREV09,;
									TRC->PREV10,;
									TRC->PREV11,;
									TRC->PREV12,;
									TRC->PREV13,;
									TRC->REAL01,;
									TRC->REAL02,;
									TRC->REAL03,;
									TRC->REAL04,;
									TRC->REAL05,;
									TRC->REAL06,;
									TRC->REAL07,;
									TRC->REAL08,;
									TRC->REAL09,;
									TRC->REAL10,;
									TRC->REAL11,;
									TRC->REAL12,;
									TRC->REAL13,;
									TRC->RESI01,;
									TRC->RESI02,;
									TRC->RESI03,;
									TRC->RESI04,;
									TRC->RESI05,;
									TRC->RESI06,;
									TRC->RESI07,;
									TRC->RESI08,;
									TRC->RESI09,;
									TRC->RESI10,;
									TRC->RESI11,;
									TRC->RESI12,;
									TRC->RESI13,;
									TRC->TITULO1,;
									TRC->TITULO2})
	TRC->(DbSkip())*/
//EndDo

//Carrega EXCEL
/*If !Empty(_oExcel:aWorkSheet)
	_oExcel:Activate()
	_oExcel:GetXMLFile(_cPathJob+_cArq)
Else
////	Alert("Não existem registros para impressao.")
EndIf*/

TRC->(DBCLOSEAREA())

Return

// *----------------------------------------------------------------------------
Static Function AjustaSX1()
Local nXX

aPerg    := {}
cPerg    := PadR( 'VENDAL' , Len( SX1->X1_GRUPO ) )

Aadd( aPerg , { "Do Produto          ?" , "C" , 15 , "SB1"})
Aadd( aPerg , { "Ate Produto         ?" , "C" , 15 , "SB1"})
Aadd( aPerg , { "Empresa/Vendedor    ?" , "N" , 01 , "   "})
Aadd( aPerg , { "Ano Referencia      ?" , "C" , 04 , "   "})
Aadd( aPerg , { "Abate impostos      ?" , "N" , 01 , "   "})
Aadd( aPerg , { "Status Ped (SEPDICO)?" , "C" , 07 , "   "})
Aadd( aPerg , { "Da Data             ?" , "D" , 08 , "   "})
Aadd( aPerg , { "Ate Data            ?" , "D" , 08 , "   "})
Aadd( aPerg , { "Abate IPI           ?" , "N" , 01 , "   "})
Aadd( aPerg , { "Abate ICMS          ?" , "N" , 01 , "   "})
Aadd( aPerg , { "Abate PIS           ?" , "N" , 01 , "   "})
Aadd( aPerg , { "Abate COFINS        ?" , "N" , 01 , "   "})

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
		SX1->(MsUnLock())
	EndIf
Next nXX
Return Nil


/*/
//-----------------------------------------------------------------------
{Protheus.doc} LogRFontes
Cria Arquivo CSV

 @author TI Totvs
 @since  23/09/2016
 @return NIL
 @version P11
//-----------------------------------------------------------------------  
/*/
User Function ArqLog(cMsg,cArqLog,cText1)
Local cFileLog := cArqLog
Local nCr
If ! File(cFileLog)
  nCr = fCreate(cFileLog)  
Else
  nCr = fOpen(cFileLog,2)
  FSeek(nCr,0,2)
Endif
FWrite(nCr,cMsg+Chr(13)+Chr(10) )
FClose(nCr)
Return .t.
///////////////////////