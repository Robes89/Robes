#INCLUDE 'totvs.ch'
#INCLUDE 'topconn.ch'

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} CN100SIT
@description Rotina responsavel pela geração do fluxo do WORKFLOW
@author Leonardo Pereira
@since 01/03/2020
@version 1.0
@return Nil
/*/
//----------------------------------------------------------------------------------------------
User Function CN100SIT()

	Local n1 := 0

	Local aAllUsers := { }
	Local aUsersList := { }

	Private cTipoDoc := 'CT'
	Private cProcHTML := ''
	Private cNivelSCR := ''
	Private cMailWF := ''
	Private cWFId := ''

	If ( ParamIXB[ 2 ] == '04' )
		/*/ Coleta informacoes do aprovador /*/
		SCR->( DbSetOrder( 1 ) )
		If SCR->( DbSeek( xFilial( 'SCR' ) + cTipoDoc + CN9->CN9_NUMERO + AllTrim( CN9->CN9_REVISA ) ) )
			cNivelSCR := SCR->CR_NIVEL
			While !SCR->( Eof() ) .And. ( xFilial('SCR') + cTipoDoc + CN9->CN9_NUMERO + AllTrim( CN9->CN9_REVISA ) == SCR->CR_FILIAL + SCR->CR_TIPO + AllTrim( SCR->CR_NUM ) ) .And. ( cNivelSCR == SCR->CR_NIVEL )
				SAK->( DbSetOrder( 1 ) )
				If SAK->( DbSeek( xFilial( 'SAK' ) + SCR->CR_APROV ) )
					aAdd( aUsersList, AllTrim( SAK->AK_USER ) )
				EndIf

				aAllUsers := FwsFAllUsers( IIf( Empty( aUsersList ), { '000000' }, aUsersList ) )
				For n1 := 1 To Len( aAllUsers )
					cMailWF += AllTrim( aAllUsers[ n1, 5] ) + ';'
				Next
				cMailWF := SubStr( cMailWF, 1, ( Len( cMailWF ) - 1 ) )

				/*/ Gera o formulário HTML para aprovação /*/
				xRet := U_WFGCT001(1,cTipoDoc)

				/*/ Realiza o envio da notificação de workflow com os links	/*/
				If xRet
					xRet := U_WFGCT002(1)
				EndIf

				/*/ Grava o numero do processo do workflow no registro de aprovação /*/
				RecLock( 'SCR', .F. )
				SCR->CR_WF := cWFId
				SCR->( MsUnLock() )
				SCR->( DbSkip() )
			End
		EndIf
	EndIf

Return
