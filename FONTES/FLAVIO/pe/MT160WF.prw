#INCLUDE 'totvs.ch'
#INCLUDE 'topconn.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} MT160WF
@description Ponto de entrada para enviar workflow de PEDIDO DE COMPRA
@author Leonardo Pereira
@since 21/02/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User Function MT160WF()

	Local lRet := .T.
	Local aAreaSC7 := SC7->( GetArea() )

	MsgRun( 'WORKFLOW...',, { | u | MT160WFA( paramIXB[ 1 ] ) } )

	RestArea( aAreaSC7 )

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} MT160WFA
@description Ponto de entrada para enviar workflow de PEDIDO DE COMPRA
@author Leonardo Pereira
@since 21/02/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MT160WFA( cNumCot )

	/*/ Declaração de variaveis /*/
	Local lRet := .F.
	Local aAllUsers := { }
	Local aUsersList := { }

	Local cQry := ''
	Local n1 := 0

	Local cTipoDoc := 'IP'

	Private cProcHTML := ''
	Private cMailWF := ''
	Private cWFId := ''
	Private cNivelSCR := ''

	If ( SELECT( 'TMPSC8' ) > 0 )
		TMPSC8->( DbCloseArea() )
	EndIf
	cQry := ' SELECT SC8.C8_NUM, SC8.C8_NUMPED '
	cQry += ' FROM ' + RetSQLName( 'SC8' ) + ' SC8 '
	cQry += " WHERE SC8.C8_FILIAL = '" + xFilial( 'SC8' ) + "' "
	cQry += " AND SC8.C8_NUM = '" + cNumCot + "' "
	cQry += " AND SC8.C8_NUMPED <> 'XXXXXX' "
	cQry += " AND SC8.D_E_L_E_T_ = '' "
	cQry += ' GROUP BY SC8.C8_NUM, SC8.C8_NUMPED '
	cQry += ' ORDER BY SC8.C8_NUM, SC8.C8_NUMPED '
	TcQuery cQry New ALIAS 'TMPSC8'

	TMPSC8->( DbGoTop() )
	While !TMPSC8->( Eof() )
		SC7->( DbSetOrder( 1 ) )
		If SC7->( DbSeek( xFilial( 'SC7' ) + TMPSC8->C8_NUMPED ) )
			/*/ Coleta informacoes do aprovador /*/
			SCR->( DbSetOrder( 1 ) )
			If SCR->( DbSeek( xFilial( 'SCR' ) + cTipoDoc + SC7->C7_NUM ) )
				cMailWF := ''
				cNivelSCR := SCR->CR_NIVEL
				While !SCR->( Eof() ) .And. ( xFilial('SCR') + cTipoDoc + SC7->C7_NUM == SCR->CR_FILIAL + SCR->CR_TIPO + AllTrim( SCR->CR_NUM ) ) .And. ( cNivelSCR == SCR->CR_NIVEL )
					SAK->( DbSetOrder( 1 ) )
					If SAK->( DbSeek( xFilial( 'SAK' ) + SCR->CR_APROV ) )
						aAdd( aUsersList, AllTrim( SAK->AK_USER ) )
					EndIf

					aAllUsers := FwsFAllUsers( IIf( Empty( aUsersList ), { '000000' }, aUsersList ) )
					For n1 := 1 To Len( aAllUsers )
						cMailWF += AllTrim( aAllUsers[ n1, 5] ) + ';'
					Next
					cMailWF := SubStr( cMailWF, 1, ( Len( cMailWF ) - 1 ) )

					/*/ Gera o formulário HTML /*/
					lRet := U_WFPED001()

      				/*/ Realiza o envio da notificação de workflow com os links	/*/
					If lRet
						lRet := U_WFPED002()
					EndIf

					/*/ Grava o numero do processo do workflow no registro de aprovação /*/
					RecLock( 'SCR', .F. )
					SCR->CR_WF := cWFId
					SCR->( MsUnLock() )

					SCR->( DbSkip() )
				End
			EndIf

			While !SC7->( Eof() ) .And. ( TMPSC8->C8_NUMPED == SC7->C7_NUM )
				RecLock( 'SC7', .F. )
				SC7->C7_CONAPRO := 'B'
				SC7->( MsUnLock() )
				SC7->( DbSkip() )
			End
		EndIf
		TMPSC8->( DbSkip() )
	End

Return
