#INCLUDE 'totvs.ch'
#INCLUDE 'topconn.ch'
#INCLUDE 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} WFW120P
@description Ponto de entrada para enviar workflow de PEDIDO DE COMPRA
@author Leonardo Pereira
@since 21/02/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User Function WFW120P()

	Local lRet := .T.
	Local aAreaSC7 := SC7->( GetArea() )

	If INCLUI .Or. ALTERA
		MsgRun( 'WORKFLOW...',, { | u | WFW120PA() } )
	EndIf

	RestArea( aAreaSC7 )

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} WFW120PA
@description Ponto de entrada para enviar workflow de PEDIDO DE COMPRA
@author Leonardo Pereira
@since 21/02/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function WFW120PA( )

	/*/ Declaração de variaveis /*/
	Local lRet := .F.

	Local aAllUsers := { }
	LOcal aUsersList := { }

	Local n1 := 0
	Local cTipoDoc := 'IP'

	Private cProcHTML := ''
	Private cMailWF := ''
	Private cWFId := ''
	Private cNivelSCR := ''

	SC7->( DbSetOrder( 1 ) )
	If SC7->( DbSeek( ParamIXB ) )
		/*/ Coleta informacoes do aprovador /*/
		SCR->( DbSetOrder( 1 ) )
		If SCR->( DbSeek( xFilial( 'SCR' ) + cTipoDoc + SC7->C7_NUM ) )
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
				lRet := U_TBGEFOWF()

      		/*/ Realiza o envio da notificação de workflow com os links	/*/
				If lRet
					U_TBENVTWF()
				EndIf

				// Grava o numero do processo do workflow no registro de aprovação
				RecLock( 'SCR', .F. )
				SCR->CR_WF := cWFId
				SCR->( MsUnLock() )
				SCR->( DbSkip() )
			End
		EndIf
	EndIf

Return
