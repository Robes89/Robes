#INCLUDE "rwmake.ch"

// Rotina		: RELPREV1
// Descrição	: Carteira de Pedidos
// Data			: 09/01/05
// Autor        : Daniel Gondran

User Function RELPREV1()

// mv_par01 - Do  Produto
// mv_par02 - Até Produto
// mv_par03 - Da data de entrega
// mv_par04 - Ate data de entrega
// mv_par05 - Do  Vendedor
// mv_par06 - Até Vendedor 
// mv_par07 - Do cliente
// mv_par08 - Ate cliente
// mv_par09 - Abate Impostos  (Sim / Nao / Merc ) 
// mv_par10 - Da data de emissao
// mv_par11 - Ate data de emissao
// mv_par12 - Status Pedido (SEDPICO)   
// mv_par13 - Fabricante

//cPerg := "RELPR1"
cPerg    := PadR( 'RELPR1' , Len( SX1->X1_GRUPO ) )
AjustaSX1()
Pergunte(cPerg,.F.)

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Carteira de Pedidos"
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

Processa( {|| Runproc() } , "Carteira de Pedidos" )

Return

//*******************************************************************************( INICIO )
STATIC FUNCTION Runproc()

aStru := {}
aAdd(aStru,{"VENDEDOR","C",15,0})
aAdd(aStru,{"PEDIDO"  ,"C",10,0})
aAdd(aStru,{"DTCADA"  ,"D",08,0})
aAdd(aStru,{"DTSOLIC" ,"D",08,0})
aAdd(aStru,{"DTENT"   ,"D",08,0})
aAdd(aStru,{"EMPRESA" ,"C",15,6})
aAdd(aStru,{"PEDCLIE" ,"C",20,6})
aAdd(aStru,{"PRODCLIE","C",30,6})
aAdd(aStru,{"CODLMT"  ,"C",42,6})       
aAdd(aStru,{"CODIGO"  ,"C",15,0})   //
aAdd(aStru,{"QTPEDIDO","N",10,0})
aAdd(aStru,{"QTPEND"  ,"N",10,0})
aAdd(aStru,{"VRUNIT"  ,"N",14,4})
aAdd(aStru,{"VRTOTAL" ,"N",14,4})
aAdd(aStru,{"VRLUNIT" ,"N",14,4})
aAdd(aStru,{"DENOM"   ,"C",58,0})
aAdd(aStru,{"IMPOSTOS","C",12,0})
aAdd(aStru,{"DATA1"   ,"D",08,0})
aAdd(aStru,{"DATA2"   ,"D",08,0})
aAdd(aStru,{"GRUPO"   ,"C",04,0})
aAdd(aStru,{"SUPERGRP","C",03,0})

oTemptable := FWTemporaryTable():New( "TRB")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"VENDEDOR + EMPRESA + PEDIDO"} )
oTempTable:Create()
/*
cArq := CriaTrab(aStru,.T.)
dbUseArea(.T.,,cArq,"TRB",.T.)
cInd := CriaTrab(NIL,.F.)
IndRegua("TRB",cInd,"VENDEDOR + EMPRESA + PEDIDO",,,"Selecionando Registros...")
        */           

Set SoftSeek On
cMoeda := "1"
dbselectarea("SC6")
dbSetOrder(3)
ProcRegua(LastRec())
dbSeek(xFilial("SC6")+dtos(mv_par03))
DO WHILE !EOF() .AND. C6_FILIAL == xFilial() .and. DTOS(C6_ENTREG) <= Dtos(mv_par04)
	IncProc( "Processando entrega dia » " + DtoC( SC6->C6_ENTREG ) )
	dbSelectArea("SC5")
	dbSetOrder(1)
	dbSeek(xFilial("SC5") + SC6->C6_NUM)
	If !(C5_STPAD $ mv_par12) 
		dbSelectArea("SC6")
		dbSkip()
		loop
	Endif
	If !Empty(mv_par13)
		If Left(SC6->C6_PRODUTO,2) <> mv_par13
			dbSelectArea("SC6")
			dbSkip()
			loop
		Endif
	Endif
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
	If C6_CODLMT >= mv_par01 .and. C6_CODLMT <= mv_par02 .and. ;
	   C6_CLI >= mv_par07 .and. C6_CLI <= mv_par08 .and. ;
	   SC5->C5_EMISSAO >= mv_par10 .and. SC5->C5_EMISSAO <= mv_par11 .and. ;
	   C6_QTDENT < C6_QTDVEN .and. C6_BLQ <> "R "
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1") + SC6->C6_PRODUTO)

//		dbSelectArea("SBM")
//		dbSetOrder(1)
//		dbSeek(xFilial("SBM") + SB1->B1_GRUPO )

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
		
		cDenom := SB1->B1_DENOM
	
		dbSelectArea("SA1")     
		dbSetOrder(1)
		dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI)
	
		If SC5->C5_VEND1 >= mv_par05 .and. SC5->C5_VEND1 <= mv_par06
			cVend 	 := SC5->C5_NOMEVEN
			cEmp  	 := SC5->C5_NOMECLI
			dEmissao := SC5->C5_EMISSAO
		Else
			dbSelectArea("SC6")
			dbSkip()
			Loop
		Endif
	
		dbSelectArea("SC6")
		RecLock( "TRB" , .T. )					
		VENDEDOR	:= cVend
		PEDIDO		:= SC6->C6_NUM + "-" + SC6->C6_ITEM
		DTCADA		:= dEmissao
		DTSOLIC		:= SC6->C6_PROMET
		DTENT		:= SC6->C6_ENTREG
		EMPRESA     := cEmp
		PEDCLIE		:= SC6->C6_PEDCLI
		PRODCLIE	:= SC6->C6_CODCLI
		CODLMT		:= SC6->C6_CODLMT
		CODIGO		:= SC6->C6_PRODUTO
		QTPEDIDO    := SC6->C6_QTDVEN
		QTPEND		:= SC6->C6_QTDVEN - SC6->C6_QTDENT
		VRTOTAL		:= SC6->C6_VALOR
		DATA1		:= mv_par03
		DATA2		:= mv_par04
		GRUPO		:= SB1->B1_GRUPO
//		SUPERGRP	:= SBM->BM_ORDEM
		SUPERGRP := ORDGRSBM

		If mv_par09 == 2
			nIpi      := SB1->B1_IPI
			mVRUNIT   := SC6->C6_PRCVEN + (SC6->C6_PRCVEN * nIpi / 100)
			mVRTOTAL  := mVRUNIT * (SC6->C6_QTDVEN - SC6->C6_QTDENT)	
			VRUNIT    := mVRUNIT * nConv
			VRTOTAL   := mVRTOTAL * nConv
			IMPOSTOS    := "Com impostos"
		ElseIf mv_par09 == 1
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
			nCof := GetMV("MV_TXCOFIN")
			nPis := GetMV("MV_TXPIS")
			mVRUNIT   := SC6->C6_PRCVEN - ( (SC6->C6_PRCVEN * nIcms/100) - (SC6->C6_PRCVEN * (nPis+nCof)/100) )
			mVRTOTAL  := mVRUNIT * (SC6->C6_QTDVEN - SC6->C6_QTDENT)	
			VRUNIT    := mVRUNIT * nConv
			VRTOTAL   := mVRTOTAL * nConv
			IMPOSTOS := "Sem impostos"
		Else
			nIpi      := SB1->B1_IPI
			mVRUNIT   := SC6->C6_PRCVEN
			mVRTOTAL  := mVRUNIT * (SC6->C6_QTDVEN - SC6->C6_QTDENT)	
			VRUNIT    := mVRUNIT * nConv
			VRTOTAL   := mVRTOTAL * nConv
			IMPOSTOS  := "Mercadoria"
		Endif
		DENOM		:= cDenom
		TRB->( MsUnLock() )
	Endif
	dbSelectArea("SC6")
	dbSkip()
Enddo

ferase("C:\RP01.DBF")	
ferase("\DADOSADV\RP01.DBF")
dbselectarea("TRB")
//COPY TO "\SIGAADV\0PEDLMT.DBF" VIA "DBFCDXADS"
//COPY TO "\DADOSADV\RP01.DBF"
Processa({||CpyS2T("\DADOSADV\RP01.DBF","C:\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
ferase("\DADOSADV\RP01.DBF")

TRB->(DBCLOSEAREA())

mTESTE := "1;0;1;GIS"  // "EM DISCO;ATUALIZA;1 COPIA;NOME REL."

//CALLCRYS("RELPREV1",,mTESTE)
CALLCRYS("RELPV1",,mTESTE)

Set SoftSeek Off
Return

// *----------------------------------------------------------------------------
Static Function AjustaSX1()
aPerg    := {}
cPerg    := PadR( 'RELPR1' , Len( SX1->X1_GRUPO ) )

Aadd( aPerg , { "Do Cod Lmt          ?" , "C" , TamSX3( "B1_CODLMT" )[1] , "SB1LMT"})
Aadd( aPerg , { "Ate Cod Lmt         ?" , "C" , TamSX3( "B1_CODLMT" )[1] , "SB1LMT"})
Aadd( aPerg , { "Da Data Entrega     ?" , "D" , 08 , "   "})
Aadd( aPerg , { "Ate Data Entrega    ?" , "D" , 08 , "   "})  
Aadd( aPerg , { "Do Vendedor         ?" , "C" , 06 , "SA3"})
Aadd( aPerg , { "Ate Vendedor        ?" , "C" , 06 , "SA3"})
Aadd( aPerg , { "Do Cliente          ?" , "C" , 06 , "SA1"})
Aadd( aPerg , { "Ate Cliente         ?" , "C" , 06 , "SA1"})
Aadd( aPerg , { "Abate impostos      ?" , "N" , 01 , "   "})
Aadd( aPerg , { "Da Data Emissao     ?" , "D" , 08 , "   "})
Aadd( aPerg , { "Ate Data Emissao    ?" , "D" , 08 , "   "})  
Aadd( aPerg , { "Status Ped (SEPDICO)?" , "C" , 07 , "   "})
Aadd( aPerg , { "Fabricante          ?" , "C" , 02 , "   "})

//Aadd( aPerg , { "Tipo Produto      ?" , "N" , 01 })

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
		If nxx == 9
			SX1->X1_GSC   := "C"
			SX1->X1_DEF01 := "Sim"
			SX1->X1_DEF02 := "Nao"
		Endif
		SX1->(MsUnLock())
	EndIf
Next nXX
Return Nil
