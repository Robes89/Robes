#include "rwmake.ch"

User Function ATU1()

Local	aAreaOLD	:= GetArea()
Private	cPerg		:= "TROPRO"

ChkSX1( cPerg )
Pergunte( cPerg , .F. )

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Transferência de Movimentos"
@ 8,10 TO 060,180
@ 70,090 BMPBUTTON TYPE 5 ACTION Pergunte( cPerg )
@ 70,118 BMPBUTTON TYPE 1 ACTION OkProc()
@ 70,146 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
@ 23,14 SAY "O objetivo desta rotina é a transferência de movimentos de"
@ 33,14 SAY "um código de produto para outro produto."
@ 43,14 SAY ""
ACTIVATE DIALOG oDlg5 CENTERED

RestArea( aAreaOLD )
Return

****************************************************************************************
Static Function OkProc()
Close(oDlg5)

mv_par01	:= Upper( mv_par01 )
mv_par02	:= Upper( mv_par02 )

If		Empty( mv_par01 )
	MsgBox( "Transferência impossível, não informado código origem !" )
ElseIf	Empty( mv_par02 )
	MsgBox( "Transferência impossível, não informado código destino !" )
ElseIf AllTrim( mv_par01 ) == AllTrim( mv_par02 )
	MsgBox( "Transferência impossível, código iguais !" )
Else
	Processa( {|| RunProc() } , "Transferência de Movimentos" )
EndIf

Return

****************************************************************************************
Static Function RunProc()

Local	nTab, cAlias, nOrdem, cCampoPro, cCampoFil, cMensagem
Local	aTabelas	:= {	{ "SB6" , 1 , "B6_PRODUTO" },;
							{ "SC2"	, 2 , "C2_PRODUTO" },;
							{ "SC6"	, 2 , "C6_PRODUTO" },;
							{ "SC7"	, 2 , "C7_PRODUTO" },;
							{ "SC9"	, 7 , "C9_PRODUTO" },;
							{ "SD1"	, 2 , "D1_COD" },;
							{ "SD2"	, 1 , "D2_COD" },;
							{ "SD3"	, 3 , "D3_COD" },;
							{ "SD4"	, 1 , "D4_COD" } }

SB1->( DbSetOrder( 1 ) )
SX3->( DbSetOrder( 2 ) )

For nTab := 1 to Len( aTabelas )

	cCampoPro	:= aTabelas[ nTab , 1 ] + "->" + aTabelas[ nTab , 3 ]
	cCampoLMT1	:= Left( aTabelas[ nTab , 3 ] , 3 ) + "CODLMT"
	cCampoLMT2	:= aTabelas[ nTab , 1 ] + "->" + Left( aTabelas[ nTab , 3 ] , 3 ) + "CODLMT"
	cMensagem	:= "Transferindo movimentos no » " + aTabelas[ nTab , 1 ]

	cSeek		:=	xFilial( aTabelas[ nTab , 1 ] ) + mv_par01
	cWhile		:=	aTabelas[ nTab , 1 ] + "->( !Eof() ) .and. " +;
					aTabelas[ nTab , 1 ] + "->" + SubStr( aTabelas[ nTab , 1 ] , 2 , 2 ) +;
					"_FILIAL == '" + xFilial( aTabelas[ nTab , 1 ] ) + "' .and. " +;
					aTabelas[ nTab , 1 ] + "->" + aTabelas[ nTab , 3 ] + " == '" + mv_par01 + "'"

	DbSelectArea( aTabelas[ nTab , 1 ] )
	DbSetOrder( aTabelas[ nTab , 2 ] )
	DbSeek( cSeek )
	ProcRegua( LastRec() )

	While &(cWhile)

		IncProc( cMensagem )

		RecLock( aTabelas[ nTab , 1 ] , .F. )
		&(cCampoPro)	:= mv_par02
		MsUnLock()

		If SX3->( DbSeek( cCampoLMT1 ) )

			SB1->( DbSeek( xFilial( "SB1" ) + mv_par02 ) )

			RecLock( aTabelas[ nTab , 1 ] , .F. )
			&(cCampoLMT2)	:= SB1->B1_CODLMT
			MsUnLock()
		EndIf

		DbSeek( cSeek )
	EndDo

	RetIndex()

Next nTab

Return

********************************************************************************************************************
Static Function ChkSX1()

Local	nXX      := 0
Local	aPerg    := {}

Aadd( aPerg , { "Do   Produto                 ?" , "C" , 15 , 00 , "G" , "" , "" , "" , "" , "" , "SB1" , 'EXISTCPO("SB1")' } )
Aadd( aPerg , { "Para Produto                 ?" , "C" , 15 , 00 , "G" , "" , "" , "" , "" , "" , "SB1" , 'EXISTCPO("SB1")' } )

For nXX := 1 to Len( aPerg )
	If !SX1->( DbSeek( cPerg + StrZero( nXX , 2 ) ) )
		RecLock( "SX1" , .T. )
		SX1->X1_GRUPO     := cPerg
		SX1->X1_ORDEM     := StrZero( nXX , 2 )
		SX1->X1_VARIAVL   := "mv_ch"  + Chr( nXX + 96 )
		SX1->X1_VAR01     := "mv_par" + Strzero( nXX , 2 )
		SX1->X1_PRESEL    := 1
		SX1->X1_PERGUNT   := aPerg[ nXX , 01 ]
		SX1->X1_TIPO      := aPerg[ nXX , 02 ]
		SX1->X1_TAMANHO   := aPerg[ nXX , 03 ]
		SX1->X1_DECIMAL   := aPerg[ nXX , 04 ]
		SX1->X1_GSC       := aPerg[ nXX , 05 ]
		SX1->X1_DEF01     := aPerg[ nXX , 06 ]
		SX1->X1_DEF02     := aPerg[ nXX , 07 ]
		SX1->X1_DEF03     := aPerg[ nXX , 08 ]
		SX1->X1_DEF04     := aPerg[ nXX , 09 ]
		SX1->X1_DEF05     := aPerg[ nXX , 10 ]
		SX1->X1_F3		  := aPerg[ nXX , 11 ]
		SX1->X1_VALID	  := aPerg[ nXX , 12 ]
		SX1->( MsUnlock() )
	EndIf
Next nXX

Return
