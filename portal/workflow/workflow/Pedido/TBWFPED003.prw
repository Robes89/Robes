#INCLUDE 'totvs.ch'
#INCLUDE 'protheus.ch'

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TBRETFORWF
@description Rotina responsavel pelo retorno do formulário do WORKFLOW
@author Leonardo Pereira
@since 05/09/2019
@version 1.0
@return Nil
/*/
//----------------------------------------------------------------------------------------------
Static Function TBRETFORWF( oProcess )

   /*/ Declaração de variaveis /*/
   Local aAreaSCR
   Local lRet := .F.

   Local aAllUsers := { }
   Local aUsersList := { }

   Local cNivelSCR := ''
   Local cTipoDoc := 'IP'
   Local cStrSCR := Space( Len(SCR->CR_NUM ) - Len( oProcess:oHtml:RetByName( 'WFPEDIDO' ) ) )

   Local n1 := 0
   Local nTotPed := Val( StrTran( StrTran( oProcess:oHtml:RetByName( 'WFTOTPED' ), '.' , '' ), ',', '.' ) )

   Private cProcHTML := ''
   Private cMailWF := ''
   Private cWFId := ''

   SCR->( DbSetOrder( 1 ) )
   If SCR->( DbSeek( oProcess:oHtml:RetByName( 'WFFILIAL' ) + cTipoDoc + oProcess:oHtml:RetByName( 'WFPEDIDO' ) + cStrSCR + oProcess:oHtml:RetByName( 'WFNIVEL' ) ) )
      aAreaSCR := SCR->( GetArea() )
      While !SCR->( Eof() ) .And. ( xFilial('SCR') + cTipoDoc + oProcess:oHtml:RetByName( 'WFPEDIDO' ) == SCR->CR_FILIAL + SCR->CR_TIPO + AllTrim( SCR->CR_NUM ) ) .And. ( oProcess:oHtml:RetByName( 'WFNIVEL' ) == SCR->CR_NIVEL )
         If ( oProcess:oHtml:RetByName( 'WFOPC' ) == 'S')
            MaAlcDoc( { oProcess:oHtml:RetByName( 'WFPEDIDO' ), cTipoDoc, nTotPed, SCR->CR_APROV, SCR->CR_USER, SCR->CR_GRUPO,, SCR->CR_MOEDA, SCR->CR_TXMOEDA, SCR->CR_EMISSAO }, dDataBase, 4 )
         ElseIf ( oProcess:oHtml:RetByName( 'WFOPC' ) == 'N')
            MaAlcDoc( { oProcess:oHtml:RetByName( 'WFPEDIDO' ), cTipoDoc, nTotPed, SCR->CR_APROV, SCR->CR_USER, SCR->CR_GRUPO,, SCR->CR_MOEDA, SCR->CR_TXMOEDA, SCR->CR_EMISSAO }, dDataBase, 7 )
         EndIf

         If !Empty( SCR->CR_DATALIB )
            RecLock( 'SCR', .F. )
            SCR->CR_OBS := oProcess:oHtml:RetByName( 'WFOBS2' )
            SCR->( MsUnLock() )
         EndIf
         SCR->( DbSkip() )
      End
      RestArea( aAreaSCR )
   EndIf

   If !Empty( SCR->CR_DATALIB )
      cNivelSCR := ''
      /*/ Verifica o proximo nivel para aprovação /*/
      SC7->( DbSetOrder( 1 ) )
      If SC7->( DbSeek( oProcess:oHtml:RetByName( 'WFFILIAL' )+ oProcess:oHtml:RetByName( 'WFPEDIDO' ) ) )
   		/*/ Coleta informacoes do aprovador /*/
         SCR->( DbSetOrder( 1 ) )
         If SCR->( DbSeek( xFilial( 'SCR' ) + cTipoDoc + SC7->C7_NUM ) )
            While !SCR->( Eof() ) .And. ( xFilial('SCR') + cTipoDoc + SC7->C7_NUM == SCR->CR_FILIAL + SCR->CR_TIPO + AllTrim( SCR->CR_NUM ) )
               If ( SCR->CR_STATUS == '01' ) .Or. ( SCR->CR_STATUS == '02' )
                  cNivelSCR := SCR->CR_NIVEL
                  Exit
               EndIf
               SCR->( DbSkip() )
            End
         EndIf
      EndIf
   EndIf

   If !Empty( cNivelSCR )
      SC7->( DbSetOrder( 1 ) )
      If SC7->( DbSeek( oProcess:oHtml:RetByName( 'WFFILIAL' )+ oProcess:oHtml:RetByName( 'WFPEDIDO' ) ) )
      	/*/ Coleta informacoes do aprovador /*/
         SCR->( DbSetOrder( 1 ) )
         If SCR->( DbSeek( xFilial( 'SCR' ) + cTipoDoc + SC7->C7_NUM ) )
            While !SCR->( Eof() ) .And. ( xFilial('SCR') + cTipoDoc + SC7->C7_NUM == SCR->CR_FILIAL + SCR->CR_TIPO + AllTrim( SCR->CR_NUM ) )
               If ( cNivelSCR == SCR->CR_NIVEL )
                  If ( SCR->CR_STATUS == '01' ) .Or. ( SCR->CR_STATUS == '02' )
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
                     lRet := U_TBENVTWF()

         		      /*/ Realiza o envio da notificação de workflow com os links	/*/
                     If lRet
                        U_TBENVTWF()
                     EndIf

                     // Grava o numero do processo do workflow no registro de aprovação
                     RecLock( 'SCR', .F. )
                     SCR->CR_WF := cWFId
                     SCR->CR_OBS := oProcess:oHtml:RetByName( 'WFOBS2' )
                     SCR->( MsUnLock() )
                  EndIf
               EndIf
               SCR->( DbSkip() )
            End
         EndIf
      EndIf
   Else
      If ( oProcess:oHtml:RetByName( 'WFOPC' ) == 'S')
         SC7->( DbSetOrder( 1 ) )
         If SC7->( DbSeek( oProcess:oHtml:RetByName( 'WFFILIAL' ) + oProcess:oHtml:RetByName( 'WFPEDIDO' ) ) )
            While !SC7->( Eof() ) .And. ( oProcess:oHtml:RetByName( 'WFFILIAL' ) + oProcess:oHtml:RetByName( 'WFPEDIDO' ) == SC7->C7_FILIAL + SC7->C7_NUM )
               RecLock( 'SC7', .F. )
               SC7->C7_CONAPRO := 'L'
               SC7->( MsUnLock() )
               SC7->( DbSkip() )
            End
         EndIf
      EndIf
   EndIf

Return
