#INCLUDE 'totvs.ch'
#INCLUDE 'topconn.ch'

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} MATA030
@description Rotina responsavel pela utilização dos pontos de entrada da rotina MATA030
@author Leonardo Pereira
@since 27/01/2020
@version 1.0
@return xRet,, dados para retorno dos pontos de entrada.
/*/
//---------------------------------------------------------------------------------------------
User Function MATA030()

   Local xRet := .T.

   Local lWFCad := SuperGetMv( 'TS_WFCAD', .F., .T. )
   Local cUsrSol := AllTrim( RetCodUsr() )
   Local cFunCad := AllTrim( Upper( FunName() ) )

   Local nTime := 1

   Private oObj
   Private oModel

   Private cIdPonto := ''
   Private cIdModel := ''
   Private cProcHTML := ''
   Private cNivel := ''
   Private cChaveHash := ''

   Private aCpoWhen := { }

   If ( PARAMIXB != Nil )
      oObj := PARAMIXB[ 1 ]
      cIdPonto := PARAMIXB[ 2 ]
      cIdModel := PARAMIXB[ 3 ]
      oModel := oObj:GetModel( cIdModel )

      If ( cIdPonto == 'MODELPRE' )
         xRet := .T.
      ElseIf ( cIdPonto == 'MODELPOS' )
         xRet := .T.
      ElseIf ( cIdPonto == 'FORMPRE' )
         xRet := .T.
      ElseIf ( cIdPonto == 'FORMPOS' )
         xRet := .T.

         If lWFCad
            If ( oModel:nOperation == 3 ) .Or. ( oModel:nOperation == 4 )
               /*/ Gera o fluxo de aprovações, baseado no grupo de aprovação do solicitante /*/
               xRet := U_TSWF06GERAPV()

               /*/ Gera o formulário HTML para aprovação /*/
               If xRet
                  xRet := U_TSWF07GERFOR( 1 )
               EndIf

               /*/ Realiza o envio da notificação de workflow com os links	/*/
               If xRet
                  xRet := U_TSWF08TSENVMSG( 1 )
               EndIf
            EndIf
         EndIf
      ElseIf ( cIdPonto == 'FORMLINEPRE' )
         xRet := .T.
      ElseIf ( cIdPonto == 'FORMLINEPOS' )
         xRet := .T.
      ElseIf ( cIdPonto == 'MODELCOMMITTTS' )
      ElseIf ( cIdPonto == 'MODELCOMMITNTTS' )
      ElseIf ( cIdPonto == 'FORMCOMMITTTSPRE' )
      ElseIf ( cIdPonto == 'FORMCOMMITTTSPOS' )
      ElseIf ( cIdPonto == 'FORMCANCEL' )
         xRet := .T.
      ElseIf ( cIdPonto == 'MODELVLDACTIVE' )
         xRet := .T.
      ElseIf ( cIdPonto == 'BUTTONBAR' )
         xRet := { { 'Reenviar Workflow', 'Reenviar Workflow', { | u | U_MyStaticCall( "TSWF10", "TSREENVWF" ) } } }

         If lWFCad
            DbSelectArea( 'PZ0' )
            PZ0->( DbSetOrder( 2 ) )
            If PZ0->( DbSeek( xFilial( 'PZ0' ) + cUsrSol ) )
               While !PZ0->( Eof() ) .And. ( PZ0->PZ0_CODUSR == cUsrSol )
                  DbSelectArea( 'PZ3' )
                  PZ3->( DbSetOrder( 1 ) )
                  If PZ3->( DbSeek( xFilial( 'PZ3' ) + PZ0->PZ0_CODROT ) )
                     If ( AllTrim( PZ3->PZ3_FUNCAO ) == cFunCad )
                        DbSelectArea( 'PZ8' )
                        PZ8->( DbSetOrder( 6 ) )
                        If PZ8->( DbSeek( xFilial( 'PZ8' ) + AllTrim( FWFldGet( AllTrim( PZ3->PZ3_CAMPO ) ) ) ) )
                           While !PZ8->( Eof() ) .And. ( AllTrim( PZ8->PZ8_CODCAD ) == AllTrim( FWFldGet( AllTrim( PZ3->PZ3_CAMPO ) ) ) )
                              If ( PZ8->PZ8_STATUS == '1' ) .Or. ( PZ8->PZ8_STATUS == '2' )
                                 lRet := .F.
                                 Exit
                              EndIf
                              PZ8->( DbSkip() )
                           End
                        EndIf
                     EndIf
                  EndIf
                  PZ0->( DbSkip() )
               End
            EndIf

            If !lRet
               cCampos := PZ8->PZ8_CAMPOS

            /*/ Dialog para digitacao da mensagem do comprador /*/
               oDlg1 := MsDialog():New( 000, 000, 310, 450, OEMToAnsi( 'CADASTRO EM APROVAÇÃO/REJEIÇÃO' ),,,,,,,,, .T. )

               oGrp1 := TGroup():New( 005, 002, 111, 225,' Dados ', oDlg1,,, .T. )
               oSay1 := TSay():New( 015, 006, { | u | 'Aprovador(a):' + PZ8->PZ8_CODAPV + ' - ' + AllTrim( UsrFullName( PZ8->PZ8_CODAPV ) ) }, oDlg1,,,,,, .T.,,, 200, 20)

               oTMG1 := TMultiget():New( 030, 006, { | u | IIf( ( PCount() > 0 ), cCampos := u, cCampos ) }, oGrp1, 215, 075,, .F., RGB( 000,000,000 ), RGB( 255,255,255 ),, .T.,,, { | u | },,, .F., { | u | },,, .F., .T. )

	         /*/ Botoes /*/
               SButton():New( 125, 195, 01, { | u | oDlg1:End() }, oDlg1, .T., 'Ok', )

            /*/ Barra de Status /*/
               oTMsgB1 := TMsgBar():New( oDlg1, 'TOTVS ' + StrZero( Year( dDataBase ), 4 ) + ' Série T',,,,, RGB( 255, 255, 255 ),,, .F., '' )

            /*/ Cria itens na barra de status /*/
               oTMsg1 := TMsgItem():New( oTMsgB1, Time(), 100,,,, .T., { | u | MsgAlert( 'Data: ' + DtoC( dDataBase ) + Chr( 13 ) + Chr( 10 ) + 'Hora: ' + Time(), 'A T E N Ç Ã O !' ), oTMsgB1:Refresh() } )

            /*/ Cria o relogio na barra de status da dialog /*/
               oTTim1 := TTimer():New( nTime,, oDlg1 )
               oTTim1:bAction := { | u | oTMsg1:SetText( Time() ) }
               oTTim1:lActive := .T.
               oTTim1:Activate()
               oDlg1:Activate( ,,, .T.,,, )
            EndIf
         EndIf
      EndIf
   EndIf

Return( xRet )
