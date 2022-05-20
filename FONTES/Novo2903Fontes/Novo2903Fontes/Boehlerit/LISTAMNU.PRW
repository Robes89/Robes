User Function LISTAMNU()

aMenus		:= {}
tamanho		:= "M"
titulo1		:= "Relação de Menus"
cDesc1		:= "Imprime a relação de menus utilizados"
cDesc2		:= ""
cDesc3		:= ""
cString		:= "SM0"
lEnd		:= .F.
aReturn		:= { "Zebrado", 1,"Administração", 1, 2, 1, "",1 }
nomeprog	:= "LISTAMNU"
nLastKey	:= 0
cbtxt		:= SPACE(10)
cbcont		:= 0
li			:= 80
m_pag		:= 1
wnrel		:= "LISTAMNU"
Cabec1		:= "OPCAO                  ROTINA         PESQUISA     VISUALIZA     INCLUI     ALTERA     EXCLUI          USUARIOS"
Cabec2		:= ""
cPerg		:= "LISMNU"

VerPerg()

Pergunte( cPerg , .F. )

wnrel		:= SetPrint(cString,wnrel,cPerg,@titulo1,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho)

If nLastKey == 27	;	Return	;	EndIf

SetDefault(aReturn,cString)

If nLastKey == 27	;	Return	;	EndIf

Processa( {|lEnd| GeraArq() } , Titulo1 )
RptStatus( {|lEnd| EmissaoMNU() } , Titulo1 )

Return

*******************************************************************************************************************
Static Function GeraArq()

If Select( "TRA" ) # 0	;	TRA->( DbCloseArea() )	;	EndIf
If Select( "TRB" ) # 0	;	TRB->( DbCloseArea() )	;	EndIf

// Arquivo de Trabalho de usuários

aStru		:= {}
aAdd( aStru , { "MENU"	, "C" , 12 , 00 } )
aAdd( aStru , { "LOGIN"	, "C" , 15 , 00 } )
aAdd( aStru , { "NOME"	, "C" , 30 , 00 } )

oTemptable := FWTemporaryTable():New( "TRA")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"MENU+LOGIN"} )
oTempTable:Create()

//cArq	:= CriaTrab(aStru, .T.)
//dbUseArea(.T.,,cArq,"TRA",.F.,.F.)
//IndRegua("TRA",cArq,"MENU+LOGIN",,,"Selecionando Registros...")



// Arquivo de Trabalho de menus
aStru		:= {}
aAdd( aStru , { "MENU"		, "C" , 12 , 00 } )
aAdd( aStru , { "NIVEL"		, "C" , 02 , 00 } )
aAdd( aStru , { "DESCRICAO"	, "C" , 18 , 00 } )
aAdd( aStru , { "ROTINA"	, "C" , 10 , 00 } )
aAdd( aStru , { "PESQUISA"	, "C" , 01 , 00 } )
aAdd( aStru , { "VISUALIZA"	, "C" , 01 , 00 } )
aAdd( aStru , { "INCLUI"	, "C" , 01 , 00 } )
aAdd( aStru , { "ALTERA"	, "C" , 01 , 00 } )
aAdd( aStru , { "EXCLUI"	, "C" , 01 , 00 } )
aAdd( aStru , { "USUARIO"	, "C" , 15 , 00 } )

oTemptable := FWTemporaryTable():New( "TRB")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"MENU+NIVE"} )
oTempTable:Create()

//cArq	:= CriaTrab(aStru, .T.)
//dbUseArea(.T.,,cArq,"TRB",.F.,.F.)
//IndRegua("TRB",cArq,"MENU+NIVEL",,,"Selecionando Registros...")

*******************************************************************************************************************
aUsers := ALLUSERS(.T.)

ProcRegua( Len( aUsers ) , Titulo1 )

For _nUsers := 1 TO Len( aUsers )

	If Interrupcao( @lEnd )	;	Exit	;	EndIf
	
	IncProc( "Lendo dados do Usuário : " + Alltrim(aUsers[_nUsers][1][2]) )

	If aUsers[_nUsers][1][1] == "000000"					// ID do usuário Administrador
		Loop
	EndIf

	For nCount := 1 TO Len(aUsers[_nUsers][3])

		If	Left(aUsers[_nUsers][3][nCount],2) $ "01/02/03/04/05/06/09/10" .and. ;
			UPPER(Substr(aUsers[_nUsers][3][nCount],3,1)) <> "X"

			_nBarra	:= RAT( "\" , Substr(aUsers[_nUsers][3][nCount] , 4 , 50 ) )
			cMenu	:= Upper( SubStr( Substr( aUsers[_nUsers][3][nCount] , 4 , 50 ) ,_nBarra + 1 ) )
//			cMenu	:= Upper( Left( cMenu , AT( "." , cMenu ) - 1 ) )

			If	AllTrim( Upper( cMenu ) ) >= AllTrim( Upper( mv_par01 ) ) .and. ;
				AllTrim( Upper( cMenu ) ) <= AllTrim( Upper( mv_par02 ) )

				If Ascan( aMenus , cMenu ) == 0	;	aAdd( aMenus , cMenu )	;	EndIf

				RecLock( "TRA" , .T. )
				TRA->MENU	:= cMenu
				TRA->LOGIN	:= aUsers[_nUsers][1][2]
				TRA->NOME	:= aUsers[_nUsers][1][4]
				TRA->( MsUnLock() )
			EndIf

		EndIf

	Next nCount

	TRA->( MsUnLock() )

Next _nUsers

aSort( aMenus )

ProcRegua( Len( aMenus ) , Titulo1 )

For nMenu := 1 to Len( aMenus )

	IncProc( "Lendo menu » " + aMenus[ nMenu ] )

	cMenu	:= CurDir() + AllTrim( aMenus[ nMenu ] )

	If !Empty( aMenus[ nMenu ] ) .and. File( cMenu )

		cTexto  := Memoread( cMenu )
		nLinhas := Mlcount( cTexto , 134)

		For nLin := 1 TO nLinhas
			cLinha := Memoline( cTexto , 134 , nLin )

			If Substr( cLinha , 31 , 1 ) $ "F/T"

				RecLock( "TRB" , .T. )
				TRB->MENU		:= aMenus[ nMenu ]
				TRB->NIVEL		:= SubStr( cLinha , 1 , 2 )
				TRB->DESCRICAO  := IIF( Substr( cLinha , 31 , 1 ) == "T" .or. ( Asc( SubStr( cLinha , 3 , 1 ) ) >= 65 .and. Asc( SubStr( cLinha , 3 , 1 ) ) <= 90 ) , SubStr( cLinha , 3 , 18 ) , "" )
				TRB->ROTINA		:= SubStr( cLinha , 21 , 10 )
				TRB->PESQUISA	:= IIF( Substr( cLinha , 31 , 1 ) == "T" .and. !Empty( SubStr( cLinha , 122 , 1 ) ) , "X" , "" )
				TRB->VISUALIZA	:= IIF( Substr( cLinha , 31 , 1 ) == "T" .and. !Empty( SubStr( cLinha , 123 , 1 ) ) , "X" , "" )
				TRB->INCLUI		:= IIF( Substr( cLinha , 31 , 1 ) == "T" .and. !Empty( SubStr( cLinha , 124 , 1 ) ) , "X" , "" )
				TRB->ALTERA		:= IIF( Substr( cLinha , 31 , 1 ) == "T" .and. !Empty( SubStr( cLinha , 125 , 1 ) ) , "X" , "" )
				TRB->EXCLUI		:= IIF( Substr( cLinha , 31 , 1 ) == "T" .and. !Empty( SubStr( cLinha , 126 , 1 ) ) , "X" , "" )
				TRB->( MsUnLock() )
			EndIf

		Next nLin

	EndIf

Next nMenu

DbSelectArea( "TRA" )
TRA->( DbGoTop() )

ProcRegua( TRA->( LastRec() ) , Titulo1 )

While !TRA->( Eof() )

	IncProc( "Atualizando menus com usuários..." )

	lGravou	:= .F.
	TRB->( DbSeek( TRA->MENU ) )
	While !TRB->( Eof() ) .and. TRB->MENU == TRA->MENU
		If Empty( TRB->USUARIO )
			lGravou	:= .T.
			RecLock( "TRB" , .F. )
			TRB->USUARIO	:= TRA->LOGIN
			TRB->( MsUnLock() )
			Exit
		EndIf
		TRB->( DbSkip() )
	EndDo

	If !lGravou
		RecLock( "TRB" , .T. )
		TRB->MENU		:= TRA->MENU
		TRB->NIVEL		:= "99"
		TRB->USUARIO	:= TRA->LOGIN
		TRB->( MsUnLock() )
	EndIf

	TRA->( DbSkip() )

EndDo

Return

*******************************************************************************************************************
Static Function EmissaoMNU()

/*
1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
OPCAO                  ROTINA         PESQUISA     VISUALIZA     INCLUI     ALTERA     EXCLUI          USUARIOS"
xxxxxxxxxxxxxxxxxx     1234567890     X            X             X          X          X               xxxxxxxxxxxxxxxx
*/

DbSelectArea( "TRB" )
TRB->( DbGoTop() )

SetRegua( TRB->( LastRec() ) , Titulo1 )

While !TRB->( Eof() )

	If Interrupcao( @lEnd )	;	Exit	;	EndIf

	LI		:= 80
	cTitulo	:= "LISTAGEM DO MENU : " + TRB->MENU
	cMenu	:= TRB->MENU

	Cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,15)

	While !TRB->( Eof() ) .and. TRB->MENU == cMenu

		IncRegua()

		If Interrupcao( @lEnd )	;	Exit	;	EndIf
	
		If li > 60	; Cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,15)	;	EndIf

		@ LI , 000 PSAY TRB->DESCRICAO
		@ LI , 023 PSAY TRB->ROTINA
		@ LI , 038 PSAY TRB->PESQUISA
		@ LI , 051 PSAY TRB->VISUALIZA
		@ LI , 065 PSAY TRB->INCLUI
		@ LI , 076 PSAY TRB->ALTERA
		@ LI , 087 PSAY TRB->EXCLUI
		@ LI , 103 PSAY TRB->USUARIO
		LI++

		TRB->( DbSkip() )

	EndDo

EndDo

Set Device To Screen
SetPgEject(.F.)
If aReturn[5] == 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
EndIf

MS_FLUSH()
Return

*******************************************************************************************************************
Static Function VerPerg()
nXX      := 0
aPerg    := {}

aAdd( aPerg , { "Do  Menu           ?" , "C" , 12 , 00 , "G" , "" , "" , "" , "" , "" } )
aAdd( aPerg , { "Até Menu           ?" , "C" , 12 , 00 , "G" , "" , "" , "" , "" , "" } )

For nXX := 1 to Len( aPerg )
	If !SX1->( DbSeek( cPerg + StrZero( nXX , 2 ) ) )
		RecLock( "SX1" , .T. )
		SX1->X1_GRUPO     := "LISMNU"
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
		SX1->( MsUnlock() )
	EndIf
Next nXX

Return
