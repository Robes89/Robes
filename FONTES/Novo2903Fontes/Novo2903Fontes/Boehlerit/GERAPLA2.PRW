#INCLUDE "rwmake.ch"

// Rotina		: GERAPLAN
// Descrição	: Gera a planilha do Sr. Julio
// Data			: 19/01/05
// Autor        : Daniel Gondran

User Function GERAPLA2()

// mv_par01 = da data (ano corrente)
// mv_par02 = Ate a data (ano corrente)
// mv_par03 = do produto
// mv_par04 = ate o produto
// mv_par05 = pertence a lista de preços
// mv_par06 = da data (ano anterior)
// mv_par07 = ate a data (ano anterior)
// mv_par08 = produtos / produtos + movimentos
// mv_par09 = do cliente
// mv_par10 = ate cliente
// mv_par11 = da area
// mv_par12 = ate area
// mv_par13 = da regiao
// mv_par14 = ate regiao
// mv_par15 = pasta

//cPerg := "GERAPX"
Private cPerg    := PadR( 'GERAPX' , Len( SX1->X1_GRUPO ) )

AjustaSX1()

Pergunte(cPerg,.F.)

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Gerador de Planilhas"
@ 70,080 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
@ 70,118 BMPBUTTON TYPE 1 ACTION OkProc()
@ 70,156 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
@ 23,14 SAY "O objetivo desta rotina é gerar um arquivo" size 200,10
@ 33,14 SAY "que será lido pelo Excell com diversas    " size 200,10
@ 43,14 SAY "informações do MicroSiga "                  size 200,10
@ 8,10 TO 060,180
ACTIVATE DIALOG oDlg5 CENTERED
Return
// *******************************************************************************************************************
Static Function OkProc()
Close(oDlg5)
Processa({|| GeraMov() } , "Gerando Registros..." )
Return
// *******************************************************************************************************************
Static Function GeraMov()

//SAIDA
aStru := {}

aAdd(aStru,{"REGIAO"    ,"C",03,0})
aAdd(aStru,{"AREA"      ,"C",05,0})
aAdd(aStru,{"CLIENTE"   ,"C",20,0})
aAdd(aStru,{"NOME"      ,"C",40,0})
aAdd(aStru,{"CGC"       ,"C",14,0})
aAdd(aStru,{"VEND"      ,"C",06,0})
aAdd(aStru,{"NVEND"     ,"C",15,0})
aAdd(aStru,{"CODINT"    ,"C",15,0})
aAdd(aStru,{"DESCRI"    ,"C",30,0})
aAdd(aStru,{"DENOM"     ,"C",58,0})
aAdd(aStru,{"CODLMT"    ,"C",46,0})
aAdd(aStru,{"CODISO"    ,"C",30,0})
aAdd(aStru,{"CLASSE"    ,"C",10,0})
aAdd(aStru,{"CODFABRI"  ,"C",02,0})
aAdd(aStru,{"GRUPO"     ,"C",04,0})
aAdd(aStru,{"SUBGRUPO"  ,"C",30,0})
aAdd(aStru,{"ESTSTATBR" ,"C",10,0})
aAdd(aStru,{"ESTSTATFO" ,"C",10,0})
aAdd(aStru,{"PERTLP"    ,"C",01,0})
aAdd(aStru,{"LISTAFOR"  ,"N",14,4})
aAdd(aStru,{"DESCONTO"  ,"N",14,4})
aAdd(aStru,{"TRANSPR"   ,"N",14,4})
aAdd(aStru,{"LISTABR"   ,"N",14,4})
aAdd(aStru,{"ALIQICMS"  ,"N",06,2})
aAdd(aStru,{"ALIQIPI"   ,"N",06,2})
aAdd(aStru,{"ALIQIMP"   ,"N",06,2})
aAdd(aStru,{"ESTFIS"    ,"N",10,0})
aAdd(aStru,{"ESTDISP"   ,"N",10,0})
aAdd(aStru,{"PREVENT"   ,"N",10,0})
aAdd(aStru,{"FATQUANT"  ,"N",10,0})
aAdd(aStru,{"FATLIQ"    ,"N",14,4})
aAdd(aStru,{"FATBRUT"   ,"N",14,4})
aAdd(aStru,{"DEVOLIQ"   ,"N",14,4})
aAdd(aStru,{"CUSTO"     ,"N",14,4})
aAdd(aStru,{"MC"        ,"N",10,2})
aAdd(aStru,{"FAT2QUANT" ,"N",10,0})
aAdd(aStru,{"FAT2LIQ"   ,"N",14,4})
aAdd(aStru,{"FAT2BRUT"  ,"N",14,4})
aAdd(aStru,{"DEVO2LIQ"  ,"N",14,4})
aAdd(aStru,{"CUSTO04"   ,"N",14,4})
aAdd(aStru,{"MC2"       ,"N",10,2})
aAdd(aStru,{"DESGRUPO"  ,"C",30,0})
aAdd(aStru,{"ORDGRUPO"  ,"C",03,0})
aAdd(aStru,{"PER1"      ,"D",08,0})
aAdd(aStru,{"PER2"      ,"D",08,0})
aAdd(aStru,{"CFO"       ,"C",05,0})
aAdd(aStru,{"DESCO"     ,"N",14,2})
aAdd(aStru,{"IPI"       ,"N",14,2})
aAdd(aStru,{"ICM"       ,"N",14,2})
aAdd(aStru,{"PIS"       ,"N",14,2})
aAdd(aStru,{"COF"       ,"N",14,2})
aAdd(aStru,{"DOC"       ,"C",06,0})
aAdd(aStru,{"EMISSAO"   ,"D",08,0})
aAdd(aStru,{"CODCLI"    ,"C",08,0})
aAdd(aStru,{"TIPO"      ,"C",01,0})

oTemptable := FWTemporaryTable():New( "TRB")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"CODINT + CLIENTE + DOC"} )
oTempTable:Create()

//cArq := CriaTrab(aStru,.T.)
////dbUseArea(.T.,,cArq,"TRB",.T.)
//cInd := CriaTrab(NIL,.F.)
//IndRegua("TRB",cArq,"CODINT + CLIENTE + DOC",,,"Aguarde...")
//dbSetIndex(cArq+OrdBagExt())

If mv_par05 == 1
	cmv_par05 := "S"
ElseIf mv_par05 == 2
	cmv_par05 := "N"
ElseIf mv_par05 == 3
	cmv_par05 := "A"
Else
	cmv_par05 := " "
Endif

Set SoftSeek On
dbSelectArea("SB1")
dbSetOrder(1)
dbSeek(xFilial("SB1") + mv_par03)
ProcRegua(LastRec())
do While !Eof() .and. B1_COD <= mv_par04
	IncProc( "Processando produto » " + SB1->B1_COD )
	If B1_PERTLP == cmv_par05 .or. cmv_par05 == " "
		//		IncProc()
		dbSelectArea("SB2")
		dbSetOrder(1)
		Set SoftSeek Off
		dbSeek(xFilial("SB2") + SB1->B1_COD)
		
		dbSelectArea("SBM")
		dbSetOrder(1)
		dbSeek(xFilial("SBM") + SB1->B1_GRUPO)
		DESGRSBM	:= alltrim(SBM->BM_DESC)
		ORDGRSBM    := SBM->BM_ORDEM
		
		if SB1->B1_SUPERGR <> space(3)
			dbSelectArea("SX5")
			dbSetOrder(1)
			dbSeek(xFilial("SX5")+"Z7"+SB1->B1_SUPERGR)
			DESGRSBM	:= alltrim(SX5->X5_DESCRI)
			ORDGRSBM    := SX5->X5_CHAVE
		endif
		
		dbSelectArea("DA1")
		dbSetOrder(1)
		dbSeek(xFilial("DA1") + "001" + SB1->B1_COD)
		
		Set SoftSeek On
		// Pedidos de Venda
		dbSelectArea("SC6")
		dbSetOrder(2)
		dbSeek(xFilial("SC6") + SB1->B1_COD)
		nPend := 0
		do While !Eof() .and. xFilial("SC6") == C6_FILIAL .and. C6_PRODUTO == SB1->B1_COD
			If C6_QTDENT < C6_QTDVEN .and. C6_BLQ <> "R "
				nPend += (C6_QTDVEN - C6_QTDENT)
			Endif
			dbSkip()
		Enddo
		//Pedidos de Compra
		dbSelectArea("SC7")
		dbSetOrder(4)
		dbSeek(xFilial("SC7") + SB1->B1_COD)
		nEntra := 0
		do While !Eof() .and. C7_FILIAL == xFilial() .and. C7_PRODUTO == SB1->B1_COD
			nSaldo := C7_QUANT - C7_QUJE
			If nSaldo > 0 .AND. C7_RESIDUO <> "S"
				nEntra += nSaldo
			Endif
			dbSelectArea("SC7")
			dbSkip()
		Enddo
		
		If mv_par08 == 2  // Movimentos
			// Faturamento
			dbSelectArea("SD2")
			dbSetOrder(1)
			dbSeek(xFilial("SD2") + SB1->B1_COD)
			nQuant := 0.00
			nLiq   := 0.00
			nBrut  := 0.00
			nDevo  := 0.00
			nCusto := 0.00
			nQuant2:= 0.00
			nLiq2  := 0.00
			nBrut2 := 0.00
			nDevo2 := 0.00
			nCusto2:= 0.00
			
			do While !Eof() .and. xFilial("SD2") == D2_FILIAL .and. D2_COD == SB1->B1_COD
				If D2_TIPO =="B" 
					dbSelectArea("SA2")
					dbSetOrder(1)
					dbSeek(xFilial("SA2") + SD2->D2_CLIENTE + SD2->D2_LOJA)
					xcA1NREDUZ 	:= A2_NREDUZ
					xcA1AREA	:= "AMZ5N"
					xcA1REGIAO	:= "SPZ"
					xcA1COD		:= A2_COD
					xcA1LOJA	:= A2_LOJA
					xcA1NOME	:= A2_NOME
					xcA1CGC		:= A2_CGC
					xcA1VEND	:= "999999"
				Else
					dbSelectArea("SA1")
					dbSetOrder(1)
					dbSeek(xFilial("SA1") + SD2->D2_CLIENTE + SD2->D2_LOJA)
					xcA1NREDUZ 	:= A1_NREDUZ
					xcA1AREA	:= A1_AREA
					xcA1REGIAO	:= A1_REGIAO
					xcA1COD		:= A1_COD
					xcA1LOJA	:= A1_LOJA
					xcA1NOME	:= A1_NOME
					xcA1CGC		:= A1_CGC
					xcA1VEND	:= A1_VEND
				Endif				
				dbSelectArea("SA3")
				dbSetOrder(1)
				dbSeek(xFilial("SA3") + xcA1VEND)
				dbSelectArea("SD2")
				If D2_CLIENTE < mv_par09 .or. D2_CLIENTE > mv_par10 .or.;
					xcA1AREA < mv_par11 .or. xcA1AREA > mv_par12 .or.;
					xcA1REGIAO < mv_par13 .or. xcA1REGIAO > mv_par14
					dbSkip()
					Loop
				Endif
				If Year(D2_EMISSAO)>2004
					dbSelectArea("SF4")
					dbSetOrder(1)
					dbSeek(xFilial("SF4") + SD2->D2_TES)
					If F4_DUPLIC == "N"  .or. SD2->D2_TIPO == "D" .OR. Substr(F4_CF,1,4)=="5551"
						dbSelectArea("SD2")
						dbSkip()
						Loop
					Endif
				Endif
				dbSelectArea("SD2")
				
				If Year(D2_EMISSAO)<=2004 .and. !(Substr(D2_CF,2,3) $ "111,112,108,102,101,110,109" )
					dbSkip()
					Loop
				Endif
				
				If D2_EMISSAO >= mv_par01 .and. D2_EMISSAO <= mv_par02
					nQuant := D2_QUANT
					nLiq   := SD2->D2_TOTAL - SD2->D2_VALICM - SD2->D2_VALIMP1 - SD2->D2_VALIMP2 - SD2->D2_VALIMP3 - SD2->D2_VALIMP4 - SD2->D2_VALIMP5 - SD2->D2_VALIMP6
					nBrut  := SD2->D2_TOTAL + IIF(SD2->D2_TIPO=="P", 0 , SD2->D2_VALIPI) + SD2->D2_VALFRE
					nCusto := SD2->D2_CUSTO1
				Else
					nQuant := 0
					nLiq   := 0
					nBrut  := 0
					nCusto := 0
				Endif
				
				If D2_EMISSAO >= mv_par06 .and. D2_EMISSAO <= mv_par07
					nQuant2:= D2_QUANT
					nLiq2  := SD2->D2_TOTAL - SD2->D2_VALICM - SD2->D2_VALIMP1 - SD2->D2_VALIMP2 - SD2->D2_VALIMP3 - SD2->D2_VALIMP4 - SD2->D2_VALIMP5 - SD2->D2_VALIMP6
					nBrut2 := SD2->D2_TOTAL + IIF(SD2->D2_TIPO=="P", 0 , SD2->D2_VALIPI) + SD2->D2_VALFRE
					nCusto2:= SD2->D2_CUSTO1
				Else
					nQuant2:= 0
					nLiq2  := 0
					nBrut2 := 0
					nCusto2:= 0
				Endif
				If Iif(SD2->D2_TIPO $ "C/P" , .T. , nQuant + nQuant2 <> 0 )
					dbSelectArea("TRB")
  //				lAchou := dbSeek(SB1->B1_COD + SA1->A1_NREDUZ + SD2->D2_DOC)
					RecLock("TRB",.T.)
					CODINT		:= SB1->B1_COD
					DESCRI  	:= SB1->B1_DESC
					DENOM   	:= SB1->B1_DENOM
					CODLMT  	:= SB1->B1_CODLMT
					CODISO  	:= SB1->B1_CODISO
					CLASSE  	:= SB1->B1_CLASSE
					CODFABRI	:= SB1->B1_FABRIC
					GRUPO   	:= SB1->B1_GRUPO
					SUBGRUPO	:= " "
					ESTSTATBR   := SB1->B1_STATUS
					ESTSTATFO   := " "
					PERTLP		:= SB1->B1_PERTLP
					LISTAFOR    := SB1->B1_PREURO
					DESCONTO    := SB1->B1_DESCONT
					TRANSPR     := SB1->B1_TRANSPR
					CUSTO       := nCusto
					CUSTO04		:= nCusto2
					LISTABR     := DA1->DA1_PRCVEN
					ALIQICMS    := SB1->B1_PICM
					ALIQIPI     := SB1->B1_IPI
					ALIQIMP     := 0
					ESTFIS      := SB2->B2_QATU
					ESTDISP     := SB2->B2_QATU - nPend
					PREVENT     := nEntra
					FATQUANT    := nQuant
					FATLIQ      := nLiq
					FATBRUT     := nBrut
					DEVOLIQ     := nDevo
					FAT2QUANT   := nQuant2
					FAT2LIQ     := nLiq2
					FAT2BRUT    := nBrut2
					DEVO2LIQ    := nDevo2
					PER1		:= mv_par01
					PER2		:= mv_par02
					CLIENTE	    := xcA1NREDUZ
					AREA		:= xcA1AREA
					REGIAO		:= xcA1REGIAO
//					DESGRUPO	:= SBM->BM_DESC
//					ORDGRUPO    := SBM->BM_ORDEM
					DESGRUPO	:= DESGRSBM
					ORDGRUPO    := ORDGRSBM
					CFO			:= SD2->D2_CF
					DESCO		:= SD2->D2_DESCON
					IPI			:= SD2->D2_VALIPI
					ICM			:= SD2->D2_VALICM
					PIS			:= SD2->D2_VALIMP5
					COF			:= SD2->D2_VALIMP6
					DOC			:= SD2->D2_DOC
					EMISSAO		:= SD2->D2_EMISSAO
					CODCLI		:= xcA1COD + xcA1LOJA
					TIPO		:= SD2->D2_TIPO
					NOME		:= xcA1NOME
					CGC			:= xcA1CGC
					VEND		:= xcA1VEND
					NVEND		:= SA3->A3_NREDUZ
					msUnlock()
					RecLock("TRB",.F.)
					MC			:= IIF(FATLIQ==0,0,((FATLIQ - CUSTO ) / FATLIQ ) * 100)
					MC2 		:= iif(FAT2LIQ==0,0,((FAT2LIQ - CUSTO04 ) / FAT2LIQ ) * 100)
					msUnlock()
				Endif
				
				dbSelectArea("SD2")
				dbSkip()
			Enddo
			
			// Devoluções
			dbSelectArea("SD1")
			dbSetOrder(2)
			dbSeek(xFilial("SD1") + SB1->B1_COD)
			do While !Eof() .and. xFilial("SD1") == D1_FILIAL .and. D1_COD == SB1->B1_COD
				dbSelectArea("SA1")
				dbSetOrder(1)
				dbSeek(xFilial("SA1") + SD1->D1_FORNECE + SD1->D1_LOJA)
				dbSelectArea("SA3")
				dbSetOrder(1)
				dbSeek(xFilial("SA3") + SA1->A1_VEND)
				dbSelectArea("SF4")
				dbSetOrder(1)
				dbSeek(xFilial("SF4") + SD1->D1_TES)
				dbSelectArea("SD1")
				If D1_FORNECE < mv_par09 .or. D1_FORNECE > mv_par10 .or.;
					SA1->A1_AREA < mv_par11 .or. SA1->A1_AREA > mv_par12 .or.;
					SA1->A1_REGIAO < mv_par13 .or. SA1->A1_REGIAO > mv_par14
					
					dbSkip()
					Loop
				Endif
				
				If (Trim(D1_CF) $ "1201,1202,2201,2202" .AND. Year(D1_DTDIGIT)==2004) .or.;
					(D1_TIPO == "D" .AND. Year(D1_DTDIGIT) > 2004 .and. SF4->F4_DUPLIC == "S")
					
					If D1_DTDIGIT >= mv_par01 .and. D1_DTDIGIT <= mv_par02
						nQuant := D1_QUANT * (-1)
						nLiq   := (D1_TOTAL-D1_VALDESC - D1_VALICM - SD1->D1_VALIMP1 - SD1->D1_VALIMP2 - SD1->D1_VALIMP3 - SD1->D1_VALIMP4 - D1_VALIMP5 - D1_VALIMP6) * (-1)
						nBrut  := (D1_TOTAL + D1_IPI + D1_VALFRE) * (-1)
						nDevo  := (D1_TOTAL-D1_VALDESC - D1_VALICM - SD1->D1_VALIMP1 - SD1->D1_VALIMP2 - SD1->D1_VALIMP3 - SD1->D1_VALIMP4 - D1_VALIMP5 - D1_VALIMP6)
						nCusto := D1_CUSTO * (-1)
					Else
						nQuant := 0
						nLiq   := 0
						nBrut  := 0
						nDevo  := 0
						nCusto := 0
					Endif
					If D1_DTDIGIT >= mv_par06 .and. D1_DTDIGIT <= mv_par07
						nQuant2:= D1_QUANT * (-1)
						nLiq2  := (D1_TOTAL-D1_VALDESC - D1_VALICM - SD1->D1_VALIMP1 - SD1->D1_VALIMP2 - SD1->D1_VALIMP3 - SD1->D1_VALIMP4 - D1_VALIMP5 - D1_VALIMP6) * (-1)
						nBrut2 := (D1_TOTAL + D1_IPI + D1_VALFRE) * (-1)
						nDevo2 := (D1_TOTAL-D1_VALDESC - D1_VALICM - SD1->D1_VALIMP1 - SD1->D1_VALIMP2 - SD1->D1_VALIMP3 - SD1->D1_VALIMP4 - D1_VALIMP5 - D1_VALIMP6)
						nCusto := D1_CUSTO * (-1)
					Else
						nQuant2 := 0
						nLiq2   := 0
						nBrut2  := 0
						nDevo2  := 0
						nCusto2 := 0
					Endif
					
					dbSelectArea("TRB")
//					lAchou := dbSeek(SB1->B1_COD + SA1->A1_NREDUZ + SD2->D2_DOC)
					RecLock("TRB",.T.)
					CODINT		:= SB1->B1_COD
					DESCRI  	:= SB1->B1_DESC
					DENOM   	:= SB1->B1_DENOM
					CODLMT  	:= SB1->B1_CODLMT
					CODISO  	:= SB1->B1_CODISO
					CLASSE  	:= SB1->B1_CLASSE
					CODFABRI	:= SB1->B1_FABRIC
					GRUPO   	:= SB1->B1_GRUPO
					SUBGRUPO	:= " "
					ESTSTATBR   := SB1->B1_STATUS
					ESTSTATFO   := " "
					PERTLP		:= SB1->B1_PERTLP
					LISTAFOR    := SB1->B1_PREURO
					DESCONTO    := SB1->B1_DESCONT
					TRANSPR     := SB1->B1_TRANSPR
					CUSTO       := nCusto
					CUSTO04		:= nCusto2
					LISTABR     := DA1->DA1_PRCVEN
					ALIQICMS    := SB1->B1_PICM
					ALIQIPI     := SB1->B1_IPI
					ALIQIMP     := 0
					ESTFIS      := SB2->B2_QATU
					ESTDISP     := SB2->B2_QATU - nPend
					PREVENT     := nEntra
					FATQUANT    := nQuant
					FATLIQ      := nLiq
					FATBRUT     := nBrut
					DEVOLIQ     := nDevo
					FAT2QUANT   := nQuant2
					FAT2LIQ     := nLiq2
					FAT2BRUT    := nBrut2
					DEVO2LIQ    := nDevo2
					PER1		:= mv_par01
					PER2		:= mv_par02
					CLIENTE	    := SA1->A1_NREDUZ
					AREA		:= SA1->A1_AREA
					REGIAO		:= SA1->A1_REGIAO
//					DESGRUPO	:= SBM->BM_DESC
//					ORDGRUPO	:= SBM->BM_ORDEM
					DESGRUPO	:= DESGRSBM
					ORDGRUPO    := ORDGRSBM
					CFO			:= SD1->D1_CF
					DESCO		:= SD1->D1_DESC
					IPI			:= SD1->D1_VALIPI
					ICM			:= SD1->D1_VALICM
					PIS			:= SD1->D1_VALIMP5
					COF			:= SD1->D1_VALIMP6
					DOC			:= SD1->D1_DOC
					EMISSAO		:= SD1->D1_DTDIGIT
					CODCLI		:= SA1->A1_COD+SA1->A1_LOJA
					TIPO		:= SD1->D1_TIPO
					NOME		:= SA1->A1_NOME
					CGC			:= SA1->A1_CGC
					VEND		:= SA1->A1_VEND
					NVEND		:= SA3->A3_NREDUZ
					
					msUnlock()
					RecLock("TRB",.F.)
					MC			:= IIF(FATLIQ==0,0,((FATLIQ - CUSTO ) / FATLIQ ) * 100)
					MC2 		:= iif(FAT2LIQ==0,0,((FAT2LIQ - CUSTO04 ) / FAT2LIQ ) * 100)
					msUnlock()
					
				Endif
				dbSelectArea("SD1")
				dbSkip()
			Enddo
			
		Else  // Produtos
			
			dbSelectArea("TRB")
			RecLock("TRB",.T.)
			CODINT		:= SB1->B1_COD
			DESCRI  	:= SB1->B1_DESC
			DENOM   	:= SB1->B1_DENOM
			CODLMT  	:= SB1->B1_CODLMT
			CODISO  	:= SB1->B1_CODISO
			CLASSE  	:= SB1->B1_CLASSE
			CODFABRI	:= SB1->B1_FABRIC
			GRUPO   	:= SB1->B1_GRUPO
			SUBGRUPO	:= " "
			ESTSTATBR   := SB1->B1_STATUS
			ESTSTATFO   := " "
			PERTLP		:= SB1->B1_PERTLP
			LISTAFOR    := SB1->B1_PREURO
			DESCONTO    := SB1->B1_DESCONT
			TRANSPR     := SB1->B1_TRANSPR
			CUSTO       := nCusto
			CUSTO04		:= nCusto2
			LISTABR     := DA1->DA1_PRCVEN
			ALIQICMS    := SB1->B1_PICM
			ALIQIPI     := SB1->B1_IPI
			ALIQIMP     := 0
			ESTFIS      := SB2->B2_QATU
			ESTDISP     := SB2->B2_QATU - nPend
			PREVENT     := nEntra
			PER1		:= mv_par01
			PER2		:= mv_par02
//			DESGRUPO	:= SBM->BM_DESC
//			ORDGRUPO    := SBM->BM_ORDEM
			DESGRUPO	:= DESGRSBM
			ORDGRUPO    := ORDGRSBM
			
			msUnlock()
		Endif
		
	Else           // Fora da lista de precos
		/*
		If MV_PAR08 > 2  // Com quebra
		// Faturamento
		//			IncProc()
		dbSelectArea("SD2")
		dbSetOrder(1)
		dbSeek(xFilial("SD2") + SB1->B1_COD)
		nQuant := 0.00
		nLiq   := 0.00
		nBrut  := 0.00
		nDevo  := 0.00
		nQuant2:= 0.00
		nLiq2  := 0.00
		nBrut2 := 0.00
		nDevo2 := 0.00
		
		do While !Eof() .and. xFilial("SD2") == D2_FILIAL .and. D2_COD == SB1->B1_COD
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1") + SD2->D2_CLIENTE + SD2->D2_LOJA)
		dbSelectArea("SA3")
		dbSetOrder(1)
		dbSeek(xFilial("SA3") + SA1->A1_VEND)
		dbSelectArea("SD2")
		If D2_CLIENTE < mv_par09 .or. D2_CLIENTE > mv_par10 .or.;
		SA1->A1_AREA < mv_par11 .or. SA1->A1_AREA > mv_par12 .or.;
		SA1->A1_REGIAO < mv_par13 .or. SA1->A1_REGIAO > mv_par14
		
		dbSkip()
		Loop
		Endif
		
		If Year(D2_EMISSAO)>2004
		dbSelectArea("SF4")
		dbSetOrder(1)
		dbSeek(xFilial("SF4") + SD2->D2_TES)
		If F4_DUPLIC == "N"  .or. SD2->D2_TIPO == "D"
		dbSelectArea("SD2")
		dbSkip()
		Loop
		Endif
		Endif
		dbSelectArea("SD2")
		
		If Substr(D2_CF,2,3) $ "111,112,108,102,101,110,109"
		If D2_EMISSAO >= mv_par01 .and. D2_EMISSAO <= mv_par02
		nQuant  := D2_QUANT
		nLiq    := SD2->D2_TOTAL - SD2->D2_VALICM - SD2->D2_VALIMP1 - SD2->D2_VALIMP2 - SD2->D2_VALIMP3 - SD2->D2_VALIMP4 - SD2->D2_VALIMP5 - SD2->D2_VALIMP6
		nBrut   := SD2->D2_TOTAL + SD2->D2_VALIPI + SD2->D2_VALFRE
		Else
		nQuant  := 0
		nLiq	:= 0
		nBrut   := 0
		Endif
		If D2_EMISSAO >= mv_par06 .and. D2_EMISSAO <= mv_par07
		nQuant2 := D2_QUANT
		nLiq2   := SD2->D2_TOTAL - SD2->D2_VALICM - SD2->D2_VALIMP1 - SD2->D2_VALIMP2 - SD2->D2_VALIMP3 - SD2->D2_VALIMP4 - SD2->D2_VALIMP5 - SD2->D2_VALIMP6
		nBrut2  := SD2->D2_TOTAL + SD2->D2_VALIPI + SD2->D2_VALFRE
		Else
		nQuant2 := 0
		nLiq2	:= 0
		nBrut2  := 0
		Endif
		
		dbSelectArea("TRB")
		lAchou := dbSeek(IIF(LEFT(SB1->B1_COD,2)=="BR","Z1             ","Z2             ")+"Varios              ")
		RecLock("TRB",!lAchou)
		CODINT		:= IIF(LEFT(SB1->B1_COD,2)=="BR","Z1","Z2")
		DESCRI  	:= IIF(LEFT(SB1->B1_COD,2)=="BR","NACIONAIS","OUTROS IMP")
		FATQUANT    += nQuant
		FATLIQ      += nLiq
		FATBRUT     += nBrut
		DEVOLIQ     += nDevo
		FAT2QUANT   += nQuant2
		FAT2LIQ     += nLiq2
		FAT2BRUT    += nBrut2
		DEVO2LIQ    += nDevo2
		PER1		:= mv_par01
		PER2		:= mv_par02
		CLIENTE	    := "Varios              " // SA1->A1_NREDUZ
		AREA		:= "Varias" // SA1->A1_AREA
		REGIAO		:= "Varias" // SA1->A1_REGIAO
		DESGRUPO	:= "Varios" // SBM->BM_DESC
		ORDGRUPO	:= "999"    // SBM->BM_ORDEM
		msUnlock()
		
		Endif
		dbSelectArea("SD2")
		dbSkip()
		Enddo
		
		//Devoluções
		dbSelectArea("SD1")
		dbSetOrder(2)
		dbSeek(xFilial("SD1") + SB1->B1_COD)
		do While !Eof() .and. xFilial("SD1") == D1_FILIAL .and. D1_COD == SB1->B1_COD
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1") + SD1->D1_FORNECE + SD1->D1_LOJA)
		dbSelectArea("SA3")
		dbSetOrder(1)
		dbSeek(xFilial("SA3") + SA1->A1_VEND)
		dbSelectArea("SD1")
		If D1_FORNECE < mv_par09 .or. D1_FORNECE > mv_par10 .or.;
		SA1->A1_AREA < mv_par11 .or. SA1->A1_AREA > mv_par12 .or.;
		SA1->A1_REGIAO < mv_par13 .or. SA1->A1_REGIAO > mv_par14
		
		dbSkip()
		Loop
		Endif
		
		If (Trim(D1_CF) $ "1201,1202,2201,2202" .AND. Year(D1_DTDIGIT)==2004) .or.;
		(D1_TIPO == "D" .AND. Year(D1_DTDIGIT) > 2004)
		
		If D1_DTDIGIT >= mv_par01 .and. D1_DTDIGIT <= mv_par02
		nQuant := D1_QUANT * (-1)
		nLiq   := (D1_TOTAL - D1_VALICM - SD1->D1_VALIMP1 - SD1->D1_VALIMP2 - SD1->D1_VALIMP3 - SD1->D1_VALIMP4 - D1_VALIMP5 - D1_VALIMP6) * (-1)
		nBrut  := (D1_TOTAL + D1_IPI + D1_VALFRE) * (-1)
		nDevo  := (D1_TOTAL - D1_VALICM - SD1->D1_VALIMP1 - SD1->D1_VALIMP2 - SD1->D1_VALIMP3 - SD1->D1_VALIMP4 - D1_VALIMP5 - D1_VALIMP6)
		Else
		nQuant := 0
		nLiq   := 0
		nBrut  := 0
		nDevo  := 0
		Endif
		If D1_DTDIGIT >= mv_par06 .and. D1_DTDIGIT <= mv_par07
		nQuant2:= D1_QUANT * (-1)
		nLiq2  := (D1_TOTAL - D1_VALICM - SD1->D1_VALIMP1 - SD1->D1_VALIMP2 - SD1->D1_VALIMP3 - SD1->D1_VALIMP4 - D1_VALIMP5 - D1_VALIMP6) * (-1)
		nBrut2 := (D1_TOTAL + D1_IPI + D1_VALFRE) * (-1)
		nDevo2 := (D1_TOTAL - D1_VALICM - SD1->D1_VALIMP1 - SD1->D1_VALIMP2 - SD1->D1_VALIMP3 - SD1->D1_VALIMP4 - D1_VALIMP5 - D1_VALIMP6)
		Else
		nQuant2:= 0
		nLiq2  := 0
		nBrut2 := 0
		nDevo2 := 0
		Endif
		
		
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1") + SD1->D1_FORNECE + SD1->D1_LOJA)
		dbSelectArea("SA3")
		dbSetOrder(1)
		dbSeek(xFilial("SA3") + SA1->A1_VEND)
		dbSelectArea("TRB")
		lAchou := dbSeek(IIF(LEFT(SB1->B1_COD,2)=="BR","Z1             ","Z2             ")+"Varios              ")
		RecLock("TRB",!lAchou)
		CODINT		:= IIF(LEFT(SB1->B1_COD,2)=="BR","Z1","Z2")
		DESCRI  	:= IIF(LEFT(SB1->B1_COD,2)=="BR","NACIONAIS","OUTROS IMP")
		FATQUANT    += nQuant
		FATLIQ      += nLiq
		FATBRUT     += nBrut
		DEVOLIQ     += nDevo
		FAT2QUANT   += nQuant2
		FAT2LIQ     += nLiq2
		FAT2BRUT    += nBrut2
		DEVO2LIQ    += nDevo2
		PER1		:= mv_par01
		PER2		:= mv_par02
		CLIENTE	    := "Varios              " // SA1->A1_NREDUZ
		AREA		:= "Varias" // SA1->A1_AREA
		REGIAO		:= "Varias" // SA1->A1_REGIAO
		DESGRUPO	:= "Varios" // SBM->BM_DESC
		ORDGRUPO	:= "999"    // SBM->BM_ORDEM
		msUnlock()
		
		Endif
		dbSelectArea("SD1")
		dbSkip()
		Enddo
		
		ELSE   // Sem quebra
		
		// Faturamento
		//			IncProc()
		dbSelectArea("SD2")
		dbSetOrder(1)
		dbSeek(xFilial("SD2") + SB1->B1_COD)
		nQuant := 0.00
		nLiq   := 0.00
		nBrut  := 0.00
		nDevo  := 0.00
		nQuant2:= 0.00
		nLiq2  := 0.00
		nBrut2 := 0.00
		nDevo2 := 0.00
		
		do While !Eof() .and. xFilial("SD2") == D2_FILIAL .and. D2_COD == SB1->B1_COD
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1") + SD2->D2_CLIENTE + SD2->D2_LOJA)
		dbSelectArea("SA3")
		dbSetOrder(1)
		dbSeek(xFilial("SA3") + SA1->A1_VEND)
		dbSelectArea("SD2")
		If D2_CLIENTE < mv_par09 .or. D2_CLIENTE > mv_par10 .or.;
		SA1->A1_AREA < mv_par11 .or. SA1->A1_AREA > mv_par12 .or.;
		SA1->A1_REGIAO < mv_par13 .or. SA1->A1_REGIAO > mv_par14
		
		dbSkip()
		Loop
		Endif
		dbSelectArea("SD2")
		If Year(D2_EMISSAO)>2004
		dbSelectArea("SF4")
		dbSetOrder(1)
		dbSeek(xFilial("SF4") + SD2->D2_TES)
		If F4_DUPLIC == "N"  .or. SD2->D2_TIPO == "D"
		dbSelectArea("SD2")
		dbSkip()
		Loop
		Endif
		Endif
		dbSelectArea("SD2")
		
		If Substr(D2_CF,2,3) $ "111,112,108,102,101,110,109"
		If D2_EMISSAO >= mv_par01 .and. D2_EMISSAO <= mv_par02
		nQuant  += D2_QUANT
		nLiq    += SD2->D2_TOTAL - SD2->D2_VALICM - SD2->D2_VALIMP1 - SD2->D2_VALIMP2 - SD2->D2_VALIMP3 - SD2->D2_VALIMP4 - SD2->D2_VALIMP5 - SD2->D2_VALIMP6
		nBrut   += SD2->D2_TOTAL + SD2->D2_VALIPI + SD2->D2_VALFRE
		Endif
		If D2_EMISSAO >= mv_par06 .and. D2_EMISSAO <= mv_par07
		nQuant2 += D2_QUANT
		nLiq2   += SD2->D2_TOTAL - SD2->D2_VALICM - SD2->D2_VALIMP1 - SD2->D2_VALIMP2 - SD2->D2_VALIMP3 - SD2->D2_VALIMP4 - SD2->D2_VALIMP5 - SD2->D2_VALIMP6
		nBrut2  += SD2->D2_TOTAL + SD2->D2_VALIPI + SD2->D2_VALFRE
		Endif
		Endif
		dbSelectArea("SD2")
		dbSkip()
		Enddo
		
		//Devoluções
		dbSelectArea("SD1")
		dbSetOrder(2)
		dbSeek(xFilial("SD1") + SB1->B1_COD)
		do While !Eof() .and. xFilial("SD1") == D1_FILIAL .and. D1_COD == SB1->B1_COD
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1") + SD1->D1_FORNECE + SD1->D1_LOJA)
		dbSelectArea("SA3")
		dbSetOrder(1)
		dbSeek(xFilial("SA3") + SA1->A1_VEND)
		dbSelectArea("SD1")
		If D1_FORNECE < mv_par09 .or. D1_FORNECE > mv_par10 .or.;
		SA1->A1_AREA < mv_par11 .or. SA1->A1_AREA > mv_par12 .or.;
		SA1->A1_REGIAO < mv_par13 .or. SA1->A1_REGIAO > mv_par14
		
		dbSkip()
		Loop
		Endif
		
		
		If (Trim(D1_CF) $ "1201,1202,2201,2202" .AND. Year(D1_DTDIGIT)==2004) .or.;
		(D1_TIPO == "D" .AND. Year(D1_DTDIGIT) > 2004)
		
		If D1_DTDIGIT >= mv_par01 .and. D1_DTDIGIT <= mv_par02
		nQuant += D1_QUANT * (-1)
		nLiq   += (D1_TOTAL - D1_VALICM - SD1->D1_VALIMP1 - SD1->D1_VALIMP2 - SD1->D1_VALIMP3 - SD1->D1_VALIMP4 - D1_VALIMP5 - D1_VALIMP6) * (-1)
		nBrut  += (D1_TOTAL + D1_IPI + D1_VALFRE) * (-1)
		nDevo  += (D1_TOTAL - D1_VALICM - SD1->D1_VALIMP1 - SD1->D1_VALIMP2 - SD1->D1_VALIMP3 - SD1->D1_VALIMP4 - D1_VALIMP5 - D1_VALIMP6)
		Endif
		If D1_DTDIGIT >= mv_par06 .and. D1_DTDIGIT <= mv_par07
		nQuant2+= D1_QUANT * (-1)
		nLiq2  += (D1_TOTAL - D1_VALICM - SD1->D1_VALIMP1 - SD1->D1_VALIMP2 - SD1->D1_VALIMP3 - SD1->D1_VALIMP4 - D1_VALIMP5 - D1_VALIMP6) * (-1)
		nBrut2 += (D1_TOTAL + D1_IPI + D1_VALFRE) * (-1)
		nDevo2 += (D1_TOTAL - D1_VALICM - SD1->D1_VALIMP1 - SD1->D1_VALIMP2 - SD1->D1_VALIMP3 - SD1->D1_VALIMP4 - D1_VALIMP5 - D1_VALIMP6)
		Endif
		
		Endif
		dbSelectArea("SD1")
		dbSkip()
		Enddo
		
		dbSelectArea("TRB")
		lAchou := dbSeek(IIF(LEFT(SB1->B1_COD,2)=="BR","Z1","Z2"))
		RecLock("TRB",!lAchou)
		CODINT		:= IIF(LEFT(SB1->B1_COD,2)=="BR","Z1","Z2")
		DESCRI  	:= IIF(LEFT(SB1->B1_COD,2)=="BR","NACIONAIS","OUTROS IMP")
		FATQUANT    += nQuant
		FATLIQ      += nLiq
		FATBRUT     += nBrut
		DEVOLIQ     += nDevo
		FAT2QUANT   += nQuant2
		FAT2LIQ     += nLiq2
		FAT2BRUT    += nBrut2
		DEVO2LIQ    += nDevo2
		PER1		:= mv_par01
		PER2		:= mv_par02
		msUnlock()
		Endif
		*/
	Endif
	dbSelectArea("SB1")
	dbSkip()
Enddo

mpasta := "\" + AllTrim(mv_par15) + "\GERAPLAN.DBF"
ferase(mpasta)
dbselectarea("TRB")
dbgotop()
//COPY TO &mpasta
Processa({||CpyS2T(mpasta,"C:\",.T.)},"Copiando Arquivo","Aguarde...",.F.)

TRB->(DBCLOSEAREA())
mTESTE := "1;0;1;GIS"  // "EM DISCO;ATUALIZA;1 COPIA;NOME REL."
If mv_par08 == 1
	CALLCRYS("GERAPLAN",,mTESTE)
Endif
If mv_par08 == 2
	CALLCRYS("GERAGRU",,mTESTE)
Endif
If mv_par08 == 3
	CALLCRYS("GERAARE",,mTESTE)
Endif
If mv_par08 == 4
	CALLCRYS("GERACLI",,mTESTE)
Endif

Set SoftSeek Off
Return

// ***************************************************************************************

Static Function AjustaSX1()
aPerg    := {}
//cPerg    := "GERAPX"

Aadd( aPerg , { "Da Data (ano corr)?" , "D" , 08 })
Aadd( aPerg , { "Ate Data(ano corr)?" , "D" , 08 })
Aadd( aPerg , { "Do Produto        ?" , "C" , 15 })
Aadd( aPerg , { "Ate Produto       ?" , "C" , 15 })
Aadd( aPerg , { "Pertence Lista Pre?" , "N" , 01 })
Aadd( aPerg , { "Da Data (ano ante)?" , "D" , 08 })
Aadd( aPerg , { "Ate Data(ano ante)?" , "D" , 08 })
Aadd( aPerg , { "Imprime           ?" , "N" , 01 })
Aadd( aPerg , { "Do Cliente        ?" , "C" , 06 })
Aadd( aPerg , { "Ate Cliente       ?" , "C" , 06 })
Aadd( aPerg , { "Da Area           ?" , "C" , 05 })
Aadd( aPerg , { "Ate Area          ?" , "C" , 05 })
Aadd( aPerg , { "Da Regiao         ?" , "C" , 05 })
Aadd( aPerg , { "Ate Regiao        ?" , "C" , 05 })
Aadd( aPerg , { "Pasta p/ gerar arq?" , "C" , 30 })

For nXX := 1 to Len( aPerg )
	If !SX1->( DbSeek( cPerg + StrZero( nXX , 2 ) ) )
		RecLock( "SX1" , .T. )
		SX1->X1_GRUPO     := cPerg
		SX1->X1_ORDEM     := StrZero( nXX , 2 )
		SX1->X1_PERGUNT   := aPerg[nXX][1]
		SX1->X1_VARIAVL   := "mv_ch" + Str( nXX , 1 )
		SX1->X1_TIPO      := aPerg[nXX][2]
		SX1->X1_TAMANHO   := aPerg[nXX][3]
		SX1->X1_PRESEL    := 1
		SX1->X1_GSC       := "G"
		SX1->X1_VAR01     := "mv_par" + StrZero( nXX , 2 )
		If nxx == 5
			SX1->X1_GSC   := "C"
			SX1->X1_DEF01 := "Sim"
			SX1->X1_DEF02 := "Nao"
			SX1->X1_DEF03 := "Analisado"
			SX1->X1_DEF03 := "Todos"
		EndIf
		If nxx == 8
			SX1->X1_GSC   := "C"
			SX1->X1_DEF01 := "Produtos"
			SX1->X1_DEF02 := "Produtos+Movimentos"
		EndIf
		SX1->(MsUnlock())
	EndIf
Next nXX
Return Nil

