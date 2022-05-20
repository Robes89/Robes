#INCLUDE 'totvs.ch'
#INCLUDE 'topconn.ch'

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} CN130PGRV
@description Rotina responsavel pela geração do fluxo do WORKFLOW
@author Leonardo Pereira
@since 01/03/2020
@version 1.0
@return Nil
/*/
//----------------------------------------------------------------------------------------------
User Function CN130PGRV()

	Local n1 := 0
	Local aAreaSCR := SCR->(GetArea())
	Local aAllUsers := { }
	Local aUsersList := { }

	Private cTipoDoc := 'MD'
	Private cProcHTML := ''
	Private cNivelSCR := ''
	Private cMailWF := ''
	Private cWFId := ''

	If INCLUI .Or. ALTERA .OR. IsInCallStack("CNTA121") 
		IF  !FwisIncallStack("CN121ENCERR")
			/*/ Coleta informacoes do aprovador /*/
			SCR->( DbSetOrder( 1 ) )
			If SCR->( DbSeek( xFilial( 'SCR' ) + cTipoDoc + CND->CND_NUMMED ) )
				cNivelSCR := SCR->CR_NIVEL
				While !SCR->( Eof() ) .And. ( xFilial('SCR') + cTipoDoc + CND->CND_NUMMED == SCR->CR_FILIAL + SCR->CR_TIPO + AllTrim( SCR->CR_NUM ) ) .And. ( cNivelSCR == SCR->CR_NIVEL )
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
					lRet := U_WFGCT001(3,cTipoDoc)

				/*/ Realiza o envio da notificação de workflow com os links	/*/
					If lRet
						U_WFGCT002(3)
					EndIf

					/*/ Grava o numero do processo do workflow no registro de aprovação /*/
					RecLock( 'SCR', .F. )
					SCR->CR_WF := cWFId
					SCR->( MsUnLock() )
					SCR->( DbSkip() )
				End
				If lRet
					RecLock( 'CND', .F. )
					CND->CND_ALCAPR := 'B'
					CND->CND_SITUAC := 'B'
					CND->( MsUnLock() )
				EndIf
			EndIf
		ENDIF	
	EndIf

RestArea(aAreaSCR)
Return

