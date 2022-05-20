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
User Function MT131WF(cNumCotacao)

	Local lRet := .T.
	Local aArea := GetArea()

	Default cNumCotacao := ParamIXB[ 1 ]

	FWMsgRun( , { | u | MT131WFA( cNumCotacao ) }, 'WORKFLOW', 'Gerando, enviando workflow...' )

	RestArea(aArea) 
	

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} MT131WFA
@description Ponto de entrada para enviar de cotacao de precos
@author LEonardo Pereira
@since 21/02/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MT131WFA( cNumCotacao )

	/*/ Declaração de variaveis /*/
	Local cQry := ''

	Private cProcHTML := ''

	If ( SELECT( 'TMPSC8' ) > 0 )
		TMPSC8->( DbCloseArea() )
	EndIf
	cQry := 'SELECT SC8.C8_FILIAL, SC8.C8_NUM, SC8.C8_FORNECE, SC8.C8_LOJA '
	cQry += ' FROM ' + RetSQLName( 'SC8' ) + ' SC8 '
	cQry += ' WHERE '
	cQry += " SC8.C8_FILIAL = '" + xFilial( 'SC8' ) + "' "
	cQry += " AND SC8.C8_NUM = '" + cNumCotacao + "' "
	cQry += " AND SC8.D_E_L_E_T_ = '' "
	cQry += ' GROUP BY SC8.C8_FILIAL, SC8.C8_NUM, SC8.C8_FORNECE, SC8.C8_LOJA '
	cQry += ' ORDER BY SC8.C8_FILIAL, SC8.C8_NUM, SC8.C8_FORNECE, SC8.C8_LOJA '
	TcQuery cQry New ALIAS 'TMPSC8'
	TMPSC8->( DbGoTop() )
	While !TMPSC8->( Eof() )
			/*/ Gera o formulário HTML /*/
		lRet := StaticCall( TBWFCOT001, TBGERFORWF )

      	/*/ Realiza o envio da notificação de workflow com os links	/*/
		If lRet
			lRet := StaticCall( TBWFCOT002, TBENVNOTWF )
		EndIf
		TMPSC8->( DbSkip() )
	End

Return
