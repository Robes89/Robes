#INCLUDE 'totvs.ch'
#INCLUDE 'topconn.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} MT131WF
@description Ponto de entrada para enviar de cotacao de precos
@author LEonardo Pereira
@since 21/02/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User Function MT131WF()

	Local lRet := .T.
	Local aArea := GetArea()
	
	If MsgYesNo("Enviar o workflow para o fornecedor?", "Workflow")
		FWMsgRun( , { | u | MT131WFA() }, 'WORKFLOW', 'Gerando, enviando workflow...' )
		MsgInfo("Workflow reenviado com sucesso.", "Workflow")
		RestArea(aArea)
	EndIf
	
Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} MT131WFA
@description Rotina que efetua o envio do WF ao Fornecedor.
@author LEonardo Pereira
@since 21/02/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MT131WFA()

	/*/ Declaração de variaveis /*/
	Local cQry := ''

	Private cProcHTML := ''

	If ( SELECT( 'TMPSC8' ) > 0 )
		TMPSC8->( DbCloseArea() )
	EndIf
	
	cQry := 'SELECT SC8.C8_FILIAL, SC8.C8_NUM, SC8.C8_FORNECE, SC8.C8_LOJA '+CRLF
	cQry += ' FROM ' + RetSQLName( 'SC8' ) + ' SC8 '+CRLF
	cQry += ' WHERE '
	cQry += " SC8.C8_FILIAL = '" + xFilial( 'SC8' ) + "' "+CRLF
	cQry += " AND SC8.C8_NUM = '" + ParamIXB[ 1 ] + "' "+CRLF
	cQry += " AND SC8.D_E_L_E_T_ = '' "+CRLF
	cQry += ' GROUP BY SC8.C8_FILIAL, SC8.C8_NUM, SC8.C8_FORNECE, SC8.C8_LOJA '+CRLF
	cQry += ' ORDER BY SC8.C8_FILIAL, SC8.C8_NUM, SC8.C8_FORNECE, SC8.C8_LOJA '+CRLF
	TcQuery cQry New ALIAS 'TMPSC8'
	
	TMPSC8->( DbGoTop() )
	
	While !TMPSC8->( Eof() )
		/*/ Gera o formulário HTML /*/
		lRet := U_WFCOT001()

		/*/ Realiza o envio da notificação de workflow com os links	/*/
		If lRet
			lRet := U_WFCOT002()
		EndIf
		
		TMPSC8->( DbSkip() )
	EndDo

Return
