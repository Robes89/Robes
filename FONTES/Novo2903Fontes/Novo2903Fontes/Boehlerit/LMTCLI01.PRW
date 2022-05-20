#INCLUDE "RWMAKE.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LMTCLI01  ³ Autor ³ Ronaldo Fernandes       Data ³ 23/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao para o campo A1_CLIENTE, permitir que o pedido   ³±±
±±³          ³ de venda gere se o mesmo estiver revizado pelo responsavel.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Sigafat                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User function LMTCLI01()

Local	aAreaSA1	:= SA1->( GetArea() )
Local	cRetorno	:= M->C5_CLIENTE
//Local	lRetorno	:= .T.

//SA1->( DbSetOrder( 1 ) )
//SA1->( DbSeek( xFilial( "SA1" ) + M->C5_CLIENTE ) ) 
If Empty( SA1->A1_REVIZ ) .and. !(M->C5_TIPO $ "B/D")
	MsgBox( "Cliente " + SA1->A1_COD + "/" + SA1->A1_LOJA + " - " +;
	AllTrim( SA1->A1_NREDUZ ) + " não revizado." , "Atenção" , "ALERT" )
//	lRetorno	:= .F.
	cRetorno	:= Space( Len( cRetorno ) )
EndIf   

If !Empty(SA1->A1_SUFRAMA)
	MsgBox("Este cliente possui codigo Suframa","ATENÇÃO","INFO")
Endif

If !Empty(SA1->A1_OBSERV)
	MsgBox(SA1->A1_OBSERV,"ATENÇÃO","INFO")
Endif


If SA1->A1_ISENIPI == "S"
	MsgBox("Este cliente possui ISENÇÃO DE IPI" , "ATENÇÃO" , "INFO" )
Endif
     
If Empty( SA2->A2_REVIZ ) .and. (M->C5_TIPO $ "B/D")
	MsgBox( "Fornecedor " + SA2->A2_COD + "/" + SA2->A2_LOJA + " - " +;
	AllTrim( SA2->A2_NREDUZ ) + " não revizado." , "Atenção" , "ALERT" )
//	lRetorno	:= .F.
	cRetorno	:= Space( Len( cRetorno ) )
EndIf

RestArea( aAreaSA1 )

Return( cRetorno )
//Return( lRetorno )


/*
dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(xFilial("SA1")+M->C5_CLIENTE)

//_cQuery := "SELECT A1_REVIZ FROM SA1020 "
//_cQuery += "WHERE D_E_L_E_T_ <> '*' AND A1_COD = '" + M->C5_CLIENTE + "'"

//TCQUERY _cQuery NEW ALIAS "QUERY"


//If QUERY->(!Eof())
If SA1->(!Eof()) .AND. M->C5_TIPO == "N"

	//Verificar se cadastro já foi Revizado...
	//If Empty(QUERY->A1_REVIZ)
	If SA1->A1_ULTCOM == CTOD("  /  /    ") .Or. Empty(SA1->A1_ULTCOM) 
			lRetLocal := .T.
			If SA1->A1_REVIZ == CTOD("  /  /    ") .Or. Empty(SA1->A1_REVIZ)
				Alert("Cliente nao revizado, INFORME O RESPONSÁVEL !!!")
			lRetLocal := .F.
			Endif
	Endif
	If SA1->A1_ULTCOM > CTOD(GETMV("MV_ATVCLI"))  // Cliente Ativo - OK!!
		lRetLocal := .T.
	Endif
	If SA1->A1_ULTCOM < CTOD(GETMV("MV_ATVCLI")) .And. !SA1->A1_ULTCOM == CTOD("  /  /    ")  // Cliente Inativo !!!
		Alert("Cliente Inativo, INFORME O RESPONSÁVEL !!!")		
	  	dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+M->C5_CLIENTE)
	   	Reclock("SA1",.F.)
		SA1->A1_SITUACA := "N"
	 	Msunlock()
		lRetLocal := .F.
     Endif
EndIf
Return(lRetLocal)
*/                             
