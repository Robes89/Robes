#Include "rwmake.ch"

// Ponto de entrada na rotina de movimentação bancária
// Wilson Santos
// Mai/2009

User Function F100TOK()
Local	lRetorno	:= .T.

If	!Empty( M->E5_DEBITO )
	If		!Left( M->E5_DEBITO , 1 ) $ "1/2" .and. Empty( M->E5_CCD )
		MsgBox( "Centro de custo a débito obrigatório!", "CCD obrigatório...", "STOP" )
		lRetorno	:= .F.
	ElseIf	Left( M->E5_DEBITO , 1 ) $ "1/2" .and. !Empty( M->E5_CCD )
		MsgBox( "Não é permitido informar centro de custo a débito para contas do Ativo/Passivo!", "CCD não permitido...", "STOP" )
		lRetorno	:= .F.
	EndIf
EndIf

If	!Empty( M->E5_CREDITO )
	If		!Left( M->E5_CREDITO , 1 ) $ "1/2" .and. Empty( M->E5_CCC )
		MsgBox( "Centro de custo a crédito obrigatório!", "CCC obrigatório...", "STOP" )
		lRetorno	:= .F.
	ElseIf	Left( M->E5_CREDITO , 1 ) $ "1/2" .and. !Empty( M->E5_CCC )
		MsgBox( "Não é permitido informar centro de custo a crédito para contas do Ativo/Passivo!", "CCC não permitido...", "STOP" )
		lRetorno	:= .F.
	EndIf
EndIf

Return( lRetorno )
