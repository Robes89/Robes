#INCLUDE "rwmake.ch"

// Rotina		: RELPREV2
// Descrição	: BackLog
// Data			: 09/01/05
// Autor        : Daniel Gondran

User Function RELPREV2()

// mv_par01 - Do  Produto
// mv_par02 - Até Produto
// mv_par03 - Da data de entrega
// mv_par04 - Ate data de entrega
// mv_par05 - Do  Vendedor
// mv_par06 - Até Vendedor

//cPerg := "RELPR2"
 cPerg    := PadR( 'RELPR2' , Len( SX1->X1_GRUPO ) )
AjustaSX1()
Pergunte(cPerg,.F.)

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "BackLog"
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
aAdd(aStru,{"CODLMT"  ,"C",42,0})
aAdd(aStru,{"CLASSE"  ,"C",10,0})
aAdd(aStru,{"DENOM"   ,"C",58,0})
aAdd(aStru,{"FORN"    ,"C",02,0})
aAdd(aStru,{"QTDTOT"  ,"N",10,0})
aAdd(aStru,{"QTD3"    ,"N",10,0})
aAdd(aStru,{"ESTATU"  ,"N",10,0})
aAdd(aStru,{"ESTLIV"  ,"N",10,0})
aAdd(aStru,{"PCOP"    ,"C",10,0})
aAdd(aStru,{"PRAZO"   ,"D",08,0})
aAdd(aStru,{"QTPED"   ,"N",10,0})
aAdd(aStru,{"PREVENT" ,"D",08,0})
aAdd(aStru,{"DIASBACK","C",08,0})
aAdd(aStru,{"IGUAL"   ,"C",01,0})

oTemptable := FWTemporaryTable():New( "TRB")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"CODLMT"} )
oTempTable:Create()

/*
cArq := CriaTrab(aStru,.T.)
dbUseArea(.T.,,cArq,"TRB",.T.)
cInd := CriaTrab(NIL,.F.)
IndRegua("TRB",cInd,"CODLMT",,,"Selecionando Registros...")
                   */

Set SoftSeek On
dbSelectArea("SB1")
dbSetOrder(9)
ProcRegua(LastRec())
dbSeek(xFilial("SB1") + mv_par01)
do While !Eof() .and. B1_FILIAL == xFilial() .and. B1_CODLMT <= mv_par02
	IncProc()
	cClasse	 := B1_CLASSE
	cDenom	 := B1_DENOM		
	cForn	 := Left(B1_COD,2)
	
	dbSelectArea("SB2")
	dbSetOrder(1)
	dbSeek(xFilial("SB2") + SB1->B1_COD + "01")
	nAtu	:= B2_QATU
	nQtPed  := 0
	nPend   := 0
	nPend30 := 0

	dbselectarea("SC6")
	dbSetOrder(10)

	If dbSeek(xFilial("SC6")+SB1->B1_CODLMT)
		DO WHILE !EOF() .AND. C6_FILIAL == xFilial() .and. Trim(C6_CODLMT) == Trim(SB1->B1_CODLMT)
			If C6_ENTREG >= mv_par03 .and. C6_ENTREG <= mv_par04
				If C6_QTDENT < C6_QTDVEN
					nPend += (C6_QTDVEN - C6_QTDENT)
				Endif
			Endif
			
			If C6_ENTREG >= ddatabase .and. C6_ENTREG <= ddatabase+mv_par05
				If C6_QTDENT < C6_QTDVEN
					nPend30 += (C6_QTDVEN - C6_QTDENT)
				Endif
			Endif
			dbSkip()
		Enddo
    Endif
	If nPend > 0 .or. nPend30 > 0	    	
		lPrim := .T.
		RecLock( "TRB" , .T. )					
		CODLMT		:= SB1->B1_CODLMT
		CLASSE		:= cClasse
		DENOM		:= cDenom
		FORN  		:= cForn   
		QTDTOT 		:= nPend
		QTD3  		:= nPend30
		ESTATU      := nAtu
		ESTLIV		:= nAtu - nPend
		DIASBACK    := Str(mv_par05,3) + " Dias"
		TRB->( MsUnLock() )

   
		dbselectarea("SC7")
		dbSetOrder(17)
		If dbSeek(xFilial("SC7")+SB1->B1_CODLMT)
			nQtPed :=0
			DO WHILE !EOF() .AND. C7_FILIAL == xFilial() .and. Trim(C7_CODLMT) == Trim(SB1->B1_CODLMT)
				If C7_DATPRF >= mv_par03 .and. C7_DATPRF <= mv_par04 .and. C7_QUANT > C7_QUJE
					nQtPed = C7_QUANT - C7_QUJE
	                If lprim
						RecLock( "TRB" , .F. )					
						lPrim := .F.
					Else
						RecLock("TRB" , .T.)
						IGUAL := "S"
					Endif
					CODLMT		:= SB1->B1_CODLMT
					CLASSE		:= cClasse
					DENOM		:= cDenom
					FORN  		:= cForn   
					QTDTOT 		:= nPend
					QTD3  		:= nPend30
					ESTATU      := nAtu
					ESTLIV		:= nAtu - nPend
					PCOP		:= "PC: " + SC7->C7_NUM
					PRAZO		:= SC7->C7_DATPRF
					QTPED		:= nQtPed
					PREVENT     := SC7->C7_PRVENT
					DIASBACK    := Str(mv_par05,3) + " Dias"
					TRB->( MsUnLock() )
				Endif
				dbSelectArea("SC7")		
				dbSkip()
			Enddo
    	Endif
    
    
	    dbselectarea("SC2")
		dbSetOrder(10)
		If dbSeek(xFilial("SC2")+SB1->B1_CODLMT)
			nQtPed :=0
			DO WHILE !EOF() .AND. C2_FILIAL == xFilial() .and. Trim(C2_CODLMT) == Trim(SB1->B1_CODLMT)
				If C2_DATPRF >= mv_par03 .and. C2_DATPRF <= mv_par04 .and. C2_QUANT > C2_QUJE
					nQtPed := C2_QUANT - C2_QUJE
	                If lprim
						RecLock( "TRB" , .F. )					
						lPrim := .F.
					Else
						RecLock("TRB" , .T.)
						IGUAL := "S"						
					Endif
					CODLMT		:= SB1->B1_CODLMT
					CLASSE		:= cClasse
					DENOM		:= cDenom
					FORN  		:= cForn   
					QTDTOT 		:= nPend
					QTD3  		:= nPend30
					ESTATU      := nAtu
					ESTLIV		:= nAtu - nPend
					PCOP		:= "OP: " + SC2->C2_NUM
					PRAZO		:= SC2->C2_DATPRF
					QTPED		:= nQtPed
					PREVENT     := SC2->C2_DATPRF
					DIASBACK    := Str(mv_par05,3) + " Dias"
					TRB->( MsUnLock() )
				Endif
				dbSelectArea("SC2")		
				dbSkip()
			Enddo
    	Endif
    Endif
    
	dbSelectArea("SB1")
	dbSkip()
Enddo
	
ferase("\DADOSADV\RP02.DBF")
dbselectarea("TRB")
dbgotop()
//COPY TO "\DADOSADV\RP02.DBF" VIA "DBFCDXADS"
Processa({||CpyS2T("\DADOSADV\RP02.DBF","C:\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
ferase("\DADOSADV\RP02.DBF")

TRB->(DBCLOSEAREA())

mTESTE := "1;0;1;GIS"  // "EM DISCO;ATUALIZA;1 COPIA;NOME REL."

//CALLCRYS("RELPREV2",,mTESTE)
CALLCRYS("RELPV2",,mTESTE)

Set SoftSeek Off
Return

// *----------------------------------------------------------------------------
Static Function AjustaSX1()
aPerg    := {}
//cPerg    := "RELPR2"

Aadd( aPerg , { "Do Produto        ?" , "C" , 15 , "SB1"})  // 01
Aadd( aPerg , { "Ate Produto       ?" , "C" , 15 , "SB1"})  // 02
Aadd( aPerg , { "Da Data Entrega   ?" , "D" , 08 , " "})    // 03
Aadd( aPerg , { "Ate Data Entrega  ?" , "D" , 08 , " "})    // 04
Aadd( aPerg , { "Dias de backlog   ?" , "N" , 03 , " "})    // 05                                                        

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
		SX1->(MsUnLock())
	EndIf
Next nXX
Return Nil
