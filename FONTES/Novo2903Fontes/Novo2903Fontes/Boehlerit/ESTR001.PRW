#include "rwmake.ch"
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF

User Function ESTR001()

public nLi	:= 1
CbCont		:= 0
CbTXT		:= Space( 10 )
Tamanho  	:= "M"
titulo   	:= "Ficha de Inventário"
cDesc1   	:= "Emissão da ficha de inventário"
cDesc2   	:= ""
cDesc3   	:= ""
cString  	:= "SB2"
wnrel	 	:= "ESTR01"
aReturn		:= { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
nLastKey 	:= 0
cPerg		:= PadR( "FIVENT" , Len( SX1->X1_GRUPO ) )
NomeProg	:= "FIVENT"

VerPerg()

Pergunte( cPerg , .F. )
wnrel	:= SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,Tamanho)

If nLastKey = 27
	Set Filter to
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Set Filter to
	Return
Endif

Processa( {|lEnd| MontaArq() } , Titulo )

RptStatus({|lEnd| Imprime(@lEnd,wnRel,cString,tamanho,titulo)},titulo)

Return NIL

*-------------------------------------------------------------------------------------------------------------------
Static Function MontaArq()

If Select( "TRA" ) # 0
	TRA->( DbCloseArea() )
EndIf

cArqDBF		:= 'ARQ'
aFields		:= {}

aAdd( aFields , { "PRODUTO"		, "C" , 46 , 00 } )
aAdd( aFields , { "TIPO"		, "C" , 02 , 00 } )
aAdd( aFields , { "ALMOX"		, "C" , 02 , 00 } )
aAdd( aFields , { "DESCRICAO"	, "C" , 60 , 00 } )
aAdd( aFields , { "UM"			, "C" , 02 , 00 } )
aAdd( aFields , { "FICHA"		, "C" , 06 , 00 } )
aAdd( aFields , { "ENDE"		, "C" , 15 , 00 } )

oTemptable := FWTemporaryTable():New( "TRA")
oTemptable:SetFields( aFields )
oTempTable:AddIndex("index1", {"PRODUTO"} )
oTempTable:Create()

//DbCreate( cArqDbf , aFields )
//DbUseArea( .T. , , cArqDbf , "TRA" , .F. )

cArqNtx	:= 'PRODUTO'
cIndCond	:= "PRODUTO + TIPO + ALMOX"
IndRegua( "TRA" , cArqNtx , cIndCond , , , "Ordenando Registros..." )

If mv_par10 == 1							// Gera etiquetas de acordo com o cadastrado

	ProcRegua( SB1->( LastRec() ) )

	SB1->( DbSetOrder( 9 ) )
	SB1->( DbSeek( xFilial("SB1") + mv_par03,.T.))

	While !SB1->( Eof() ) .and.	SB1->B1_FILIAL	== xFilial( "SB1" ) .and. SB1->B1_CODLMT <= mv_par04

		IncProc( "Montando arquivo de trabalho..." )

		SB2->( DbSeek( xFilial( "SB2" ) + SB1->B1_COD + "01" ) )

//			SB1->B1_COD		>= mv_par03 .and. SB1->B1_COD <= mv_par04 .and. ;

		If	SB1->B1_LOCPAD	>= mv_par01 .and. SB1->B1_LOCPAD <= mv_par02 .and. ;
			SB1->B1_TIPO	>= mv_par05 .and. SB1->B1_TIPO <= mv_par06 .and. ;
 			( mv_par13 == 2 .or. ( mv_par13 == 1 .and. SB2->B2_QATU > 0 ) ) .and. ;
			Left( SB1->B1_COD , 2 )	>= mv_par14 .and. Left( SB1->B1_COD , 2 ) <= mv_par15
			RecLock( "TRA" , .t. )
			TRA->PRODUTO	:= SB1->B1_CODLMT
			TRA->TIPO		:= SB1->B1_TIPO
			TRA->ALMOX		:= SB1->B1_LOCPAD
			TRA->DESCRICAO	:= SB1->B1_DENOM
			TRA->UM			:= SB1->B1_UM
			TRA->ENDE		:= SB1->B1_ENDE
			TRA->( MsUnLock() )
		EndIf
	
		SB1->( DbSkip() )
	EndDo
    
Else									// Gera etiquetas em branco

	ProcRegua( mv_par11 )

	For nXX := 1 to mv_par11

		IncProc( "Montando arquivo de trabalho..." )

		RecLock( "TRA" , .t. )
		TRA->PRODUTO	:= Replicate( "_" , Len( TRA->PRODUTO ) )
		TRA->TIPO		:= Replicate( "_" , Len( TRA->TIPO ) )
		TRA->ALMOX		:= Replicate( "_" , Len( TRA->ALMOX ) )
		TRA->DESCRICAO	:= Replicate( "_" , Len( TRA->DESCRICAO ) )
		TRA->UM			:= Replicate( "_" , Len( TRA->UM ) )
		TRA->ENDE		:= Replicate( "_" , Len( TRA->ENDE ) )
		TRA->( MsUnLock() )

	Next nXX

EndIf

Return( nil )

*-------------------------------------------------------------------------------------------------------------------
Static Function Imprime(lEnd,WnRel,cString,tamanho,titulo)

DbSelectArea( "TRA" )
TRA->( DbGoTop() )

SetRegua( TRA->( LastRec() ) , Titulo )

While !TRA->( Eof() )
	
	If Interrupcao( @lEnd )
		Exit
	EndIf

	IncRegua()

	// Dados da primeira ficha
//	c1Ficha		:= TRA->FICHA
	c1Ficha		:= StrZero( mv_par07++ , 6 )
	c1Produto	:= AllTrim( TRA->PRODUTO )
	c1Tipo		:= AllTrim( TRA->TIPO )
	c1Descricao	:= AllTrim( TRA->DESCRICAO )
	c1UM		:= AllTrim( TRA->UM )
	c1Almox		:= AllTrim( TRA->ALMOX )
	c1Ende		:= AllTrim( TRA->ENDE)

	TRA->( DbSkip() )
	
	// Dados da segunda ficha
//	c2Ficha		:= TRA->FICHA
	c2Ficha		:= StrZero( mv_par07++ , 6 )
	c2Produto	:= AllTrim( TRA->PRODUTO )
	c2Tipo		:= AllTrim( TRA->TIPO )
	c2Descricao	:= AllTrim( TRA->DESCRICAO )
	c2UM		:= AllTrim( TRA->UM )
	c2Almox		:= AllTrim( TRA->ALMOX )
	c2Ende		:= AllTrim( TRA->ENDE)	

	For nXX :=  3 to 1 STEP -1
		@ nLI , 005 PSAY Chr( 14 ) + "LMT"
		@ nLI , 012 PSAY "INVENTARIO FISICO" + Chr( 20 )
		If !Empty( c2Ficha )
			@ nLI , 049 PSAY Chr( 14 ) + "LMT"
			@ nLI , 054 PSAY "INVENTARIO FISICO" + Chr( 20 )
		EndIf
		nLI++
		@ nLI , 028 PSAY AllTrim( Upper( MesExtenso( Month( mv_par08 ) ) ) ) + "/" + Str( Year( mv_par08 ) , 4 )
		If !Empty( c2Ficha )
			@ nLI , 099 PSAY AllTrim( Upper( MesExtenso( Month( mv_par08 ) ) ) ) + "/" + Str( Year( mv_par08 ) , 4 )
		EndIf
		nLI	+= 2
		@ nLI , 005 PSAY "No. da FICHA: " + c1Ficha
		If !Empty( c2Ficha )
			@ nLI , 076 PSAY "No. da FICHA: " + c2Ficha
		EndIf
		nLI	+= 2
		@ nLI , 005 PSAY "CODIGO LMT: " + c1Produto
		If !Empty( c2Ficha )
			@ nLI , 076 PSAY "CODIGO LMT: " + c2Produto
		EndIf
		nLI	+= 2
		@ nLI , 005 PSAY "DESCRICAO: " + SubStr( c1Descricao, 1, 50 )
		If !Empty( c2Ficha )
			@ nLI , 076 PSAY "DESCRICAO: " + SubStr( c2Descricao, 1, 50 )
		EndIf
		If	mv_par10 == 1 .and. (!Empty( SubStr( c1Descricao, 51, 50 ) ) .or. !Empty( SubStr( c2Descricao, 51, 50 ) ))
			nLi++
			If	!Empty( SubStr( c1Descricao, 51, 50 ) )
				@ nLI , 016 PSAY SubStr( c1Descricao, 51, 50 )
			EndIf
			If	!Empty( SubStr( c2Descricao, 51, 50 ) )
				@ nLI , 087 PSAY SubStr( c2Descricao, 51, 50 )
			EndIf
			nLi++
		Else
			nLI	+= 2
		EndIf
		@ nLI , 005 PSAY     "U.M.: " + c1UM + " PESO:____________ ALMOX: " + c1Almox + " ENDE: " + c1Ende
		If !Empty( c2Ficha )
			@ nLI , 076 PSAY "U.M.: " + c2UM + " PESO:____________ ALMOX: " + c2Almox + " ENDE: " + c2Ende
		EndIf

		nLI	+= 2
		@ nLI , 005 PSAY "DATA DA " + Str( nXX , 1 ) + "a. CONTAGEM: _______/_______/_______"
		If !Empty( c2Ficha )
			@ nLI , 076 PSAY "DATA DA " + Str( nXX , 1 ) + "a. CONTAGEM: _______/_______/_______"
		EndIf
		nLI	+= 2
		@ nLI , 005 PSAY "QUANT. APURADA: _____________________"
		If !Empty( c2Ficha )
			@ nLI , 076 PSAY "QUANT. APURADA: _____________________"
		EndIf
		nLI	+= 2
		@ nLI , 005 PSAY "_____________________     ____________________"
		If !Empty( c2Ficha )
			@ nLI , 076 PSAY "_____________________     ____________________"
		EndIf
		nLI++
		@ nLI , 005 PSAY "  VISTO FUNCIONARIO         VISTO CONFERENTE  "
		If !Empty( c2Ficha )
			@ nLI , 076 PSAY "  VISTO FUNCIONARIO         VISTO CONFERENTE  "
		EndIf

		nLI	+= 6
	Next nXX

/*
	// 2a. Contagem

	@ nLI , 005 PSAY Chr( 14 ) + "LMT"
	@ nLI , 012 PSAY "INVENTARIO FISICO" + Chr( 20 )
	If !Empty( c2Ficha )
		@ nLI , 048 PSAY Chr( 14 ) + "LMT"
		@ nLI , 053 PSAY "INVENTARIO FISICO" + Chr( 20 )
	EndIf
	nLI++
	@ nLI , 028 PSAY AllTrim( Upper( MesExtenso( Month( mv_par08 ) ) ) ) + "/" + Str( Year( mv_par08 ) , 4 )
	If !Empty( c2Ficha )
		@ nLI , 099 PSAY AllTrim( Upper( MesExtenso( Month( mv_par08 ) ) ) ) + "/" + Str( Year( mv_par08 ) , 4 )
	EndIf
	nLI	+= 2
	@ nLI , 005 PSAY "No. da FICHA: " + c1Ficha
	If !Empty( c2Ficha )
		@ nLI , 076 PSAY "No. da FICHA: " + c2Ficha
	EndIf
	nLI	+= 2
	@ nLI , 005 PSAY "CODIGO LMT  : " + c1Produto
//	@ nLI , 040 PSAY "TIPO : " + c1Tipo
	If !Empty( c2Ficha )
		@ nLI , 076 PSAY "CODIGO LMT  : " + c2Produto
//		@ nLI , 100 PSAY "TIPO : " + c2Tipo
	EndIf
	nLI	+= 2
	@ nLI , 005 PSAY "DESCRICAO   : " + c1Descricao
	If !Empty( c2Ficha )
		@ nLI , 076 PSAY "DESCRICAO   : " + c2Descricao
	EndIf
	nLI	+= 2
	@ nLI , 005 PSAY "UNID.MED.   : " + c1UM
	@ nLi , 022 PSAY "PESO:____________"
	@ nLI , 040 PSAY "ALMOX: " + c1Almox + " ENDE : " + c1Ende
	If !Empty( c2Ficha )
		@ nLI , 076 PSAY "UNID.MED.   : " + c2UM
		@ nLi , 093 PSAY "PESO:____________"		
		@ nLI , 111 PSAY "ALMOX: " + c2Almox + " ENDE : " + c2Ende
	EndIf
	nLI	+= 2
	@ nLI , 005 PSAY "DATA DA 2a. CONTAGEM: _______/_______/_______"
//	@ nLI , 005 PSAY "DATA DA 2a. CONTAGEM: " + TransForm( mv_par12 , "" )
	If !Empty( c2Ficha )
		@ nLI , 076 PSAY "DATA DA 2a. CONTAGEM: _______/_______/_______"
//		@ nLI , 076 PSAY "DATA DA 2a. CONTAGEM: " + TransForm( mv_par12 , "" )
	EndIf
	nLI	+= 2
	@ nLI , 005 PSAY "QUANT. APURADA: _____________________"
	If !Empty( c2Ficha )
		@ nLI , 076 PSAY "QUANT. APURADA: _____________________"
	EndIf
	nLI	+= 2
	@ nLI , 005 PSAY "_____________________     ____________________"
	If !Empty( c2Ficha )
		@ nLI , 076 PSAY "_____________________     ____________________"
	EndIf
	nLI++
	@ nLI , 005 PSAY "  VISTO FUNCIONARIO         VISTO CONFERENTE  "
	If !Empty( c2Ficha )
		@ nLI , 076 PSAY "  VISTO FUNCIONARIO         VISTO CONFERENTE  "
	EndIf

	nLI	+= 6

	// 1a. Contagem

	@ nLI , 005 PSAY Chr( 14 ) + "LMT"
	@ nLI , 012 PSAY "INVENTARIO FISICO" + Chr( 20 )
	If !Empty( c2Ficha )
		@ nLI , 048 PSAY Chr( 14 ) + "LMT"
		@ nLI , 053 PSAY "INVENTARIO FISICO" + Chr( 20 )
	EndIf
	nLI++
	@ nLI , 028 PSAY AllTrim( Upper( MesExtenso( Month( mv_par08 ) ) ) ) + "/" + Str( Year( mv_par08 ) , 4 )
	If !Empty( c2Ficha )
		@ nLI , 099 PSAY AllTrim( Upper( MesExtenso( Month( mv_par08 ) ) ) ) + "/" + Str( Year( mv_par08 ) , 4 )
	EndIf
	nLI	+= 2
	@ nLI , 005 PSAY "No. da FICHA: " + c1Ficha
	If !Empty( c2Ficha )
		@ nLI , 076 PSAY "No. da FICHA: " + c2Ficha
	EndIf
	nLI	+= 2
	@ nLI , 005 PSAY "CODIGO LMT  : " + c1Produto
//	@ nLI , 040 PSAY "TIPO : " + c1Tipo
	If !Empty( c2Ficha )
		@ nLI , 076 PSAY "CODIGO LMT  : " + c2Produto
//		@ nLI , 100 PSAY "TIPO : " + c2Tipo
	EndIf
	nLI	+= 2
	@ nLI , 005 PSAY "DESCRICAO   : " + c1Descricao
	If !Empty( c2Ficha )
		@ nLI , 076 PSAY "DESCRICAO   : " + c2Descricao
	EndIf
	nLI	+= 2
	@ nLI , 005 PSAY "UNID.MED.   : " + c1UM
	@ nLi , 022 PSAY "PESO:____________"
	@ nLI , 040 PSAY "ALMOX: " + c1Almox + " ENDE : " + c1Ende
	If !Empty( c2Ficha )
		@ nLI , 076 PSAY "UNID.MED.   : " + c2UM
		@ nLi , 093 PSAY "PESO:____________"				
		@ nLI , 111 PSAY "ALMOX: " + c2Almox + " ENDE : " + c2Ende
	EndIf
	nLI	+= 2
//	@ nLI , 005 PSAY "DATA DA 1a. CONTAGEM: _______/_______/_______"
	@ nLI , 005 PSAY "DATA DA 1a. CONTAGEM: " + TransForm( mv_par12 , "" )
	If !Empty( c2Ficha )
//		@ nLI , 076 PSAY "DATA DA 1a. CONTAGEM: _______/_______/_______"
		@ nLI , 076 PSAY "DATA DA 1a. CONTAGEM: " + TransForm( mv_par12 , "" )
	EndIf
	nLI	+= 2
	@ nLI , 005 PSAY "QUANT. APURADA: _____________________"
	If !Empty( c2Ficha )
		@ nLI , 076 PSAY "QUANT. APURADA: _____________________"
	EndIf
	nLI	+= 2
	@ nLI , 005 PSAY "_____________________     ____________________"
	If !Empty( c2Ficha )
		@ nLI , 076 PSAY "_____________________     ____________________"
	EndIf
	nLI++
	@ nLI , 005 PSAY "  VISTO FUNCIONARIO         VISTO CONFERENTE  "
	If !Empty( c2Ficha )
		@ nLI , 076 PSAY "  VISTO FUNCIONARIO         VISTO CONFERENTE  "
	EndIf

	nLI	+= 5
//	nLI	:= 1
*/
	TRA->( DbSkip() )
EndDo

Set Device to Screen

If aReturn[ 5 ] == 1
	Set Printer To
	OurSpool(wnrel)
EndIf

SetPgEject(.F.)

MS_FLUSH()

TRA->( DbCloseArea() )

Return

*-------------------------------------------------------------------------------------------------------------------
Static Function VerPerg()
nXX      := 0
aPerg    := {}

aAdd( aPerg , { "Do  Almoxarifado   ?" , "C" , 02 , 00 , "G" , "" , "" , "" , "" , "" , "" } )
aAdd( aPerg , { "Até Almoxarifado   ?" , "C" , 02 , 00 , "G" , "" , "" , "" , "" , "" , "" } )
Aadd( aPerg , { "Do Cod Lmt         ?" , "C" , TamSX3( "B1_CODLMT" )[1] , 00 , "G" , "" , "" , "" , "" , "" , "SB1LMT" } )
Aadd( aPerg , { "Ate Cod Lmt        ?" , "C" , TamSX3( "B1_CODLMT" )[1] , 00 , "G" , "" , "" , "" , "" , "" , "SB1LMT" } )
aAdd( aPerg , { "Do  Tipo           ?" , "C" , 02 , 00 , "G" , "" , "" , "" , "" , "" , "02" } )
aAdd( aPerg , { "Até Tipo           ?" , "C" , 02 , 00 , "G" , "" , "" , "" , "" , "" , "02" } )
aAdd( aPerg , { "Nº da Ficha Inicial?" , "N" , 06 , 00 , "G" , "" , "" , "" , "" , "" , "" } )
aAdd( aPerg , { "Data do Inventário ?" , "D" , 08 , 00 , "G" , "" , "" , "" , "" , "" , "" } )
aAdd( aPerg , { "Tipo de Inventário ?" , "N" , 01 , 00 , "C" , "Estoque" , "Poder de Terceiros", "" , "" , "" , "" } )
aAdd( aPerg , { "Gera Etiq.em Branco?" , "N" , 01 , 00 , "C" , "Não" , "Sim", "" , "" , "" , "" } )
aAdd( aPerg , { "Qtde Etiq.em Branco?" , "N" , 03 , 00 , "G" , "" , "" , "" , "" , "" , "" } )
aAdd( aPerg , { "Data da Contagem   ?" , "D" , 08 , 00 , "G" , "" , "" , "" , "" , "" , "" } )
aAdd( aPerg , { "Lista só c/Estoque ?" , "N" , 01 , 00 , "C" , "Sim" , "Não", "" , "" , "" , "" } )
aAdd( aPerg , { "Da  Marca          ?" , "C" , 02 , 00 , "G" , "" , "" , "" , "" , "" , "" } )
aAdd( aPerg , { "Até Marca          ?" , "C" , 02 , 00 , "G" , "" , "" , "" , "" , "" , "" } )

For nXX := 1 to Len( aPerg )
	If !SX1->( DbSeek( cPerg + StrZero( nXX , 2 ) ) )
		RecLock( "SX1" , .T. )
		SX1->X1_GRUPO	:= cPerg
		SX1->X1_ORDEM	:= StrZero( nXX , 2 )
		SX1->X1_VARIAVL	:= "mv_ch"  + Chr( nXX + 96 )
		SX1->X1_VAR01	:= "mv_par" + Strzero( nXX , 2 )
		SX1->X1_PRESEL	:= 1
		SX1->X1_PERGUNT	:= aPerg[ nXX , 01 ]
		SX1->X1_TIPO	:= aPerg[ nXX , 02 ]
		SX1->X1_TAMANHO	:= aPerg[ nXX , 03 ]
		SX1->X1_DECIMAL	:= aPerg[ nXX , 04 ]
		SX1->X1_GSC		:= aPerg[ nXX , 05 ]
		SX1->X1_DEF01	:= aPerg[ nXX , 06 ]
		SX1->X1_DEF02	:= aPerg[ nXX , 07 ]
		SX1->X1_DEF03	:= aPerg[ nXX , 08 ]
		SX1->X1_DEF04	:= aPerg[ nXX , 09 ]
		SX1->X1_DEF05	:= aPerg[ nXX , 10 ]
		SX1->X1_F3		:= aPerg[ nXX , 11 ]
		SX1->( MsUnlock() )
	EndIf
Next nXX

Return
