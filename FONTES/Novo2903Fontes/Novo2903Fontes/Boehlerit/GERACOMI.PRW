#INCLUDE "rwmake.ch"

// Rotina		: GERACOMI
// Descrição	: Gera arquivo de comissões
// Data			: 02/02/05
// Autor        : Daniel Gondran

User Function GERACOMI()

// mv_par01 - Do  Vendedor
// mv_par02 - Até Vendedor
// mv_par03 - Da data de emissao
// mv_par04 - Ate data de emissao
// mv_par05 - Da data da baixa
// mv_par06 - Até data da baixa
// mv_par07 - Ignora CFOPs

//cPerg := "GERACO"
 cPerg    := PadR( 'GERACO' , Len( SX1->X1_GRUPO ) )

AjustaSX1()

Pergunte(cPerg,.F.)

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Gera Arquivo de Comissões"
@ 70,080 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
@ 70,118 BMPBUTTON TYPE 1 ACTION OkProc()
@ 70,156 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
@ 23,14 SAY "O objetivo dessa rotina é gerar o arquivo com as comissões" size 200,10
@ 33,14 SAY "dos vendedores para posterior impressão" size 200,10
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

Public mVrTotal
Public nComis,cDoc,cSerie,dEmissao,cCliente,cLoja
Public mVrTotal 
Public aBase  
Public aPorc  
Public aComis 

Set SoftSeek On

dbselectarea("SF2")
cIndice2 := 'F2_FILIAL'
IndRegua("SF2",cIndice2,"F2_FILIAL+DTOS(F2_EMISSAO)",,,"Selecionando Registros")
cIndTrab := SubStr(cIndice2,1,7)+"A"
nIndex := RetIndex("SF2")
#IFNDEF TOP
	dbSetIndex(cIndice2+OrdBagExt())
#ENDIF
dbSetOrder(nIndex+1)

dbselectarea("SF1")
cIndice1 := 'F1_FILIAL'
IndRegua("SF1",cIndice1,"F1_FILIAL+DTOS(F1_DTDIGIT)",,,"Selecionando Registros")
cIndTrab := SubStr(cIndice1,1,7)+"A"
nIndex := RetIndex("SF1")
#IFNDEF TOP
	dbSetIndex(cIndice1+OrdBagExt())
#ENDIF
dbSetOrder(nIndex+1)
                      

// Comissao pela EMISSÃO

dbSelectArea("SA3")
dbSetOrder(1)
dbSeek(xFilial("SA3") + mv_par01)
ProcRegua(LastRec())
do While !Eof() .and. A3_FILIAL == xFilial("SA3") .and. A3_COD <= mv_par02
	IncProc(A3_COD)
	If A3_TIPO == "E"
		dbSkip()
		loop
	Endif
	nComis 	 := 0
	mVrTotal := 0
	aBase  := {0,0,0,0,0,0,0,0,0}
	aPorc  := {0,0,0,0,0,0,0,0,0}
	aComis := {0,0,0,0,0,0,0,0,0}
	cDoc 	:= StrZero(Year(mv_par04),4)+StrZero(Month(mv_par04),2) 	// F2_DOC
	cSerie  := " " 		// F2_SERIE
	dEmissao:= mv_par04	// F2_EMISSAO
	cCliente:= " "		// F2_CLIENTE
	cLoja	:= " "		// F2_LOJA
	cBaiEmi := "E"
	
	
	dbSelectArea("SF2")
	dbSeek(xFilial("SF2") + dtos(mv_par03))
	DO WHILE !EOF() .AND. F2_FILIAL == xFilial("SF2") .and. F2_EMISSAO <= mv_par04
		If F2_VEND1 <> SA3->A3_COD
			dbSkip()
			Loop
		Endif
				
		dbSelectArea("SD2")
		dbSetOrder(3)
		dbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE)
		do While !EOF() .AND. D2_DOC == SF2->F2_DOC .and. D2_SERIE == SF2->F2_SERIE
			dbSelectArea("SF4")
			dbSetOrder(1)
			dbSeek(xFilial("SF4") + SD2->D2_TES)
			If F4_DUPLIC == "N" .OR. F4_CF $ mv_par07
				dbSelectArea("SD2")
				dbSkip()
				Loop
			Endif
    	    dbSelectArea("SD2")
			mVRTOTAL	+= (D2_TOTAL - D2_VALICM - D2_VALIMP1 - D2_VALIMP2 - D2_VALIMP3 - D2_VALIMP4 - D2_VALIMP5 - D2_VALIMP6)
			dbSkip()
		Enddo
		dbSelectArea("SF2")
		dbSkip()
	Enddo

	dbSelectArea("SF1")
	dbSeek(xFilial("SF1") + dtos(mv_par03))
	DO WHILE !EOF() .AND. F1_FILIAL == xFilial("SF1") .and. F1_DTDIGIT <= mv_par04
	    /*
		nComis 	 := 0
		mVrTotal := 0
		aBase  := {0,0,0,0,0,0,0,0,0}
		aPorc  := {0,0,0,0,0,0,0,0,0}
		aComis := {0,0,0,0,0,0,0,0,0}
		cDoc 	:= F1_DOC
		cSerie  := F1_SERIE
		dEmissao:= F1_DTDIGIT
		cCliente:= F1_FORNECE
		cLoja	:= F1_LOJA
		cBaiEmi := "E"
		*/	
		dbSelectArea("SD1")
		dbSetOrder(1)
		dbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE)
		do While !EOF() .AND. D1_DOC == SF1->F1_DOC .and. D1_SERIE == SF1->F1_SERIE
			dbSelectArea("SD2")
			dbSetOrder(3)
			If dbSeek(xFilial("SD2") + SD1->D1_NFORI + SD1->D1_SERIORI)
				dbSelectArea("SC5")
				dbSetOrder(1)
				dbSeek(xFilial("SC5") + SD2->D2_PEDIDO + SD2->D2_ITEMPV)
				cCodVend := C5_VEND1
			Else
				dbSelectArea("SA1")
				dbSetOrder(1)
				dbSeek(xFilial("SA1") + SD1->D1_FORNECE + SD1->D1_LOJA)
				cCodVend := A1_VEND
			Endif

			If cCodVend <> SA3->A3_COD
				dbSelectArea("SD1")
				dbSkip()
				Loop
			Endif
			dbSelectArea("SF4")
			dbSetOrder(1)
			dbSeek(xFilial("SF4") + SD1->D1_TES)
			If F4_DUPLIC == "N" .OR. F4_CF $ mv_par07
				dbSelectArea("SD1")
				dbSkip()
				Loop
			Endif
    	    dbSelectArea("SD1")
//			mVRTOTAL	-= (D1_TOTAL - D1_VALICM - D1_VALIMP1 - D1_VALIMP2 - D1_VALIMP3 - D1_VALIMP4 - D1_VALIMP5 - D1_VALIMP6)
			mVRTOTAL	-= (D1_TOTAL - D1_VALDESC - D1_VALICM - D1_VALIMP1 - D1_VALIMP2 - D1_VALIMP3 - D1_VALIMP4 - D1_VALIMP5 - D1_VALIMP6)
			dbSkip()
		Enddo
		dbSelectArea("SF1")
		dbSkip()
	Enddo
	Grava()
	dbSelectArea("SA3")
	dbSkip()
Enddo

// Comissao pela BAIXA

dbSelectArea("SA3")
dbSetOrder(1)
dbSeek(xFilial("SA3") + mv_par01)
ProcRegua(LastRec())
do While !Eof() .and. A3_FILIAL == xFilial("SA3") .and. A3_COD <= mv_par02
	IncProc(A3_COD)
	If A3_TIPO == "I"
		dbSkip()
		loop
	Endif
	nComis 	 := 0
	mVrTotal := 0
	aBase  := {0,0,0,0,0,0,0,0,0}
	aPorc  := {0,0,0,0,0,0,0,0,0}
	aComis := {0,0,0,0,0,0,0,0,0}
	cDoc 	:= StrZero(Year(mv_par04),4)+StrZero(Month(mv_par04),2) 	// F2_DOC
	cSerie  := " " 		// F2_SERIE
	dEmissao:= mv_par04	// F2_EMISSAO
	cCliente:= " "		// F2_CLIENTE
	cLoja	:= " "		// F2_LOJA
	cBaiEmi := "B"
	
	
	dbSelectArea("SE1")
	dbSetOrder(7)
	dbSeek(xFilial("SE1") + dtos(mv_par05))
	DO WHILE !EOF() .AND. E1_FILIAL == xFilial("SE1") .and. E1_VENCREA <= mv_par06
		If E1_VEND1 <> SA3->A3_COD
			dbSkip()
			Loop
		Endif
				
		mVRTOTAL	+= (E1_VALOR - E1_SALDO)
		dbSkip()
	Enddo

	Grava()
	dbSelectArea("SA3")
	dbSkip()
Enddo

RetIndex("SF2")
IF File(cIndice2+OrdBagExt())
	Ferase(cIndice2+OrdBagExt())
Endif

RetIndex("SF1")
IF File(cIndice1+OrdBagExt())
	Ferase(cIndice1+OrdBagExt())
Endif
	
Return

// *----------------------------------------------------------------------------
Static Function AjustaSX1()
aPerg    := {}
//cPerg    := "GERACO"

Aadd( aPerg , { "Do Vendedor         ?" , "C" , 06 , "SA3"})
Aadd( aPerg , { "Ate Vendedor        ?" , "C" , 06 , "SA3"})
Aadd( aPerg , { "Da Data Emissao     ?" , "D" , 08 , "   "})
Aadd( aPerg , { "Ate Data Emissao    ?" , "D" , 08 , "   "})  
Aadd( aPerg , { "Da Data Baixa       ?" , "D" , 08 , "   "})
Aadd( aPerg , { "Ate Data Baixa      ?" , "D" , 08 , "   "})  
Aadd( aPerg , { "Ignora CFOPs        :" , "C" , 40 , "   "})

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

Static Function Grava()
	dbSelectArea("SZ1")
	dbGotop()
	nCont := 1
	do While !Eof()
		nComisf := 0
		If mVRTOTAL >= Z1_FINI .and. mVRTOTAL <= Z1_FFIM
			nComisf := mVRTOTAL * Z1_PCOMIS / 100
			aBase[nCont] := mVRTOTAL
			aPorc[nCont] := Z1_PCOMIS
			mVRTOTAL := 0			
		Endif
		If mVRTOTAL > Z1_FFIM
			nComisf := Z1_FFIM * Z1_PCOMIS / 100
			aBase[nCont] := Z1_FFIM
			aPorc[nCont] := Z1_PCOMIS
			mVRTOTAL -= Z1_FFIM			
		Endif
		aComis[nCont] := nComisf
		dbSkip()
		nCont++
	Enddo


	dbSelectArea("SZ2")
	dbSetOrder(1)
	For kkk := 1 to 9
		If aComis[kkk] <> 0
			lAchou := dbSeek(xFilial("SZ2") + cDoc + StrZero(kkk,2) + SA3->A3_COD)
			RecLock("SZ2",!lAchou)
			Z2_FILIAL 	:= xFilial("SZ2")
			Z2_VEND		:= SA3->A3_COD
			Z2_NUM		:= cDoc
			Z2_FAIXA	:= StrZero(kkk,2)
			Z2_SERIE	:= cSerie
			Z2_EMISSAO	:= dEmissao
			Z2_CODCLI	:= cCliente
			Z2_LOJA		:= cLoja      
			Z2_BASE		:= aBase[kkk]
			Z2_PORC		:= aPorc[kkk]
			Z2_COMIS	:= aComis[kkk]
			Z2_DATA		:= dDatabase
			Z2_BAIEMI   := cBaiEmi
			msUnlock()
		Endif
	Next
Return
