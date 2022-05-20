#INCLUDE 'totvs.ch'
//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} TBENVTWF
@description Rotina responsavel pelo envio do email de notificação do workflow
@author Leonardo Pereira
@since 21/02/2020
@version 1.0
@return Nil
/*/
//---------------------------------------------------------------------------------------------
User Function TBENVTWF()

   Local cURL1       := SuperGetMV( 'TB_WFLINK1', .F., 'http://127.0.0.1:8070' )
   Local cURL2       := SuperGetMV( 'TB_WFLINK2', .F., 'http://127.0.0.1:8070' )
   Local cDirHTML    := SuperGetMV( 'TB_HTMFOR4', .F., '\workflow\modelos\tbnotaprovrejcot.htm' )
   Local cURLComp    := SuperGetMv( 'TB_URLDIR1', .F., '/html/')
   Local cEnvMailTest:= SuperGetMV( 'TB_ENVTEST', .F., '' )

   Local oProcess

   Local cProcLINK := ''
   Local cMailWF := ''

   Local cTitulo := OEMToAnsi( 'Cotação de Preço' )

	/*/ Criação do LINK /*/
   Local cLinkWF1 := ( cURL1 + StrTran( cURLComp, '\', '/') + AllTrim( cProcHTML ) + '.htm' )
   Local cLinkWF2 := ( cURL2 + StrTran( cURLComp, '\', '/') + AllTrim( cProcHTML ) + '.htm' )

	/*/ Criação do Processo /*/
   oProcess := TWFProcess():New( 'WFCAD2', cTitulo )

	/*/ Informando o HTML e o código do processo que compõem este Processo /*/
   oProcess:NewTask( cTitulo, cDirHTML )

	/*/ Definindo o Assunto do E-mail (propriedade cSubject) /*/
   oProcess:cSubject := cTitulo

   SA2->( DbSetOrder( 1 ) )
   If SA2->( DbSeek( xFilial( 'SA2' ) + TMPSC8->C8_FORNECE + TMPSC8->C8_LOJA ) )
      cMailWF := AllTrim( SA2->A2_EMAIL )
   EndIf


   //-- 
   If !Empty(cEnvMailTest)
      cMailWF := AllTrim(cEnvMailTest)
   EndIf 
	/*/ Definindo o(s) Destinatário(s) do E-mail (propriedade cTo. Mais de um destinatário, separar por ;) /*/
   oProcess:cTo := cMailWF

   oProcess:oHTML:ValByName( 'LINK1', cLinkWF1 )
   oProcess:oHTML:ValByName( 'LINK2', cLinkWF2 )
   oProcess:oHTML:ValByName( 'EMPRESA', Upper( AllTrim( FWEmpName( cEmpAnt ) ) ) )

	/*/ Envio do E-mail do LINK /*/
   cProcLINK := oProcess:Start()

Return
