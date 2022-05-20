#INCLUDE 'Protheus.ch'
/*
//-----------------------------------------------------------------------------------------------
//{Protheus.doc} U_TBGEFOWF
@description Rotina responsavel pela geração do formulário do WORKFLOW
@author Leonardo Pereira
@since 05/09/2019
@version 1.0
@return Nil
/
//---------------------------------------------------------------------------------------------- */
User Function TBGEFOWF()

   Local oProcess

   Local lRet := .F.

   Local cDirHTML    := SuperGetMv( 'TB_HTMLDIR', .F., '\workflow\html\' )
   Local cFormHTML   := SuperGetMv( 'TB_HTMFOR3', .F., '\workflow\modelos\tbformcotacao.htm' )

   Local cTitulo := OEMToAnsi( 'Cotacao de Precos' )

   Local aAreaSM0 := SM0->( GetArea() )
   Local aAreaSC8 := SC8->( GetArea() )
   Local aCond := { }
   Local aFrete := { }

   Local cChave := TMPSC8->C8_FILIAL + TMPSC8->C8_NUM + TMPSC8->C8_FORNECE + TMPSC8->C8_LOJA

	
   // Realiza a geração do formulário.
	// Criação do Processo 
   oProcess := TWFProcess():New( 'WFCAD1', cTitulo )

	// Informando o HTML e o código do processo que compõem este Processo 
   oProcess:NewTask( cTitulo, cFormHTML )

	//  Definindo o Assunto do E-mail (propriedade cSubject) 
   oProcess:cSubject := cTitulo

	//  Definindo o(s) Destinatário(s) do e-mail (propriedade cTo. Mais de um destinatário, separar por ;) 
   oProcess:cTo := 'HTML'

	//  Código do usuário no Protheus que receberá o e-mail.
   oProcess:UserSiga := '000000'

	// Definindo a Função ADVPL de Retorno (propriedade bReturn).
	// Esta função será executada quando o Workflow receber o e-mail de resposta de um dos destinatários informados nas propriedades acima.
   oProcess:bReturn := 'StaticCall( TBWFCOT003, TBRETFORWF )'

   oProcess:oHTML:ValByName( 'WFEMPRESA', cEmpAnt )
   oProcess:oHTML:ValByName( 'WFFILIAL', cFilAnt )

   // Posiciona no fornecedor
   SA2->( DbSetOrder( 1 ) )
   If SA2->( DbSeek( xFilial( 'SA2' ) + TMPSC8->C8_FORNECE + TMPSC8->C8_LOJA ) )
      SC8->( DbSetOrder( 1 ) )
      If SC8->( DbSeek( cChave) )
         oProcess:oHTML:ValByName( 'WFCOTACAO'     , SC8->C8_NUM )
         oProcess:oHTML:ValByName( 'WFVALID'       , DtoC( SC8->C8_VALIDA ) )
         oProcess:oHTML:ValByName( 'WFFORNECEDOR'  , SC8->C8_FORNECE )
         oProcess:oHTML:ValByName( 'WFLOJA'        , SC8->C8_LOJA )
         oProcess:oHTML:ValByName( 'WFNOMEFOR'     , AllTrim( SA2->A2_NOME ) )
         oProcess:oHTML:ValByName( 'WFENDERECO'    , AllTrim( SA2->A2_END ) )
         oProcess:oHTML:ValByName( 'WFBAIRRO'      , AllTrim( SA2->A2_BAIRRO ) )
         oProcess:oHTML:ValByName( 'WFCIDADE'      , AllTrim( SA2->A2_MUN ) )
         oProcess:oHTML:ValByName( 'WFUF'          , AllTrim( SA2->A2_EST ) )
         oProcess:oHTML:ValByName( 'WFTELEFONE'    , AllTrim( SA2->A2_TEL ) )

         While !SC8->( Eof() ) .And. ( cChave == SC8->C8_FILIAL + SC8->C8_NUM + SC8->C8_FORNECE + SC8->C8_LOJA )
            aAdd( oProcess:oHtml:ValByName( 'IT.ITEM' )     , SC8->C8_ITEM )
            aAdd( oProcess:oHtml:ValByName( 'IT.CODIGO')    , SC8->C8_PRODUTO )
            aAdd( oProcess:oHtml:ValByName( 'IT.DESC' )     , AllTrim( Posicione( 'SB1', 1, xFilial( 'SB1' ) + SC8->C8_PRODUTO, 'B1_DESC' ) ) )
            aAdd( oProcess:oHtml:ValByName( 'IT.QUANT')     , AllTrim( Transform( SC8->C8_QUANT, '9,999,999.99' ) ) )
            aAdd( oProcess:oHtml:ValByName( 'IT.UM')        , SC8->C8_UM )
            aAdd( oProcess:oHtml:ValByName( 'IT.VLRUNIT')   , AllTrim( Transform( 0, '9,999,999.99' ) ) )
            aAdd( oProcess:oHtml:ValByName( 'IT.VLRTOT')    , AllTrim( Transform( 0, '9,999,999.99' ) ) )
            aAdd( oProcess:oHtml:ValByName( 'IT.IPI')       , AllTrim( Transform( 0, '99.99' ) ) )
            aAdd( oProcess:oHtml:ValByName( 'IT.PRAZO')     , AllTrim( Transform( 0, '999' ) ) )
            aAdd( oProcess:oHtml:ValByName( 'IT.ENTREGA')   , DtoC( SC8->C8_DATPRF ) )

            SC8->( DbSkip() )
         End
         RestArea( aAreaSC8 )

         oProcess:oHtml:ValByName( 'WFSUBTOT'   , AllTrim( Transform( 0, '9,999,999.99' ) ) )
         oProcess:oHtml:ValByName( 'WFTOTDESC'  , AllTrim( Transform( 0, '9,999,999.99' ) ) )
         oProcess:oHtml:ValByName( 'WFTOTIPI'   , AllTrim( Transform( 0, '9,999,999.99' ) ) )
         oProcess:oHtml:ValByName( 'WFTOTFRETE' , AllTrim( Transform( 0, '9,999,999.99' ) ) )
         oProcess:oHtml:ValByName( 'WFTOTCOT'   , AllTrim( Transform( 0, '9,999,999.99' ) ) )

         // Lista as condições de pagamento
         DbSelectArea( 'SE4' )
         SE4->( DbSetOrder( 1 ) )
         If SE4->( DbSeek( xFilial( 'SE4' ) + SA2->A2_COND ) )
            If ( SE4->E4_TIPO != '9' )
               aAdd( aCond, SE4->E4_CODIGO + ' - ' + AllTrim( SE4->E4_DESCRI ) )
            EndIf
         EndIf

         SE4->( DbGoTop() )
         SE4->( DbSeek( xFilial( 'SE4' ) ) )
         While !SE4->( Eof() ) .And. ( SE4->E4_FILIAL == xFilial( 'SE4' ) )
            If ( SE4->E4_TIPO != '9' )
               aAdd( aCond, SE4->E4_CODIGO + ' - ' + AllTrim( SE4->E4_DESCRI ) )
            EndIf
            SE4->( DbSkip() )
         End
         oProcess:oHtml:ValByName( 'WFCONDPAG', aCond )

         // Lista as opções de tipo de frete
         aAdd( aFrete, 'CIF' )
         aAdd( aFrete, 'FOB' )
         oProcess:oHtml:ValByName( 'WFTIPOFRETE', aFrete )

         SM0->( DbSetOrder( 1 ) )
         If SM0->( DbSeek( cEmpAnt + SC8->C8_FILENT ) )
            oProcess:oHtml:ValByName( 'WFENDENTREGA', AllTrim( SM0->M0_ENDENT ) )
            oProcess:oHtml:ValByName( 'WFBAIRRO', AllTrim( SM0->M0_BAIRENT ) )
            oProcess:oHtml:ValByName( 'WFCIDADE', AllTrim( SM0->M0_CIDENT ) )
            oProcess:oHtml:ValByName( 'WFUF', AllTrim( SM0->M0_ESTENT ) )
            oProcess:oHtml:ValByName( 'WFTELEFONE', AllTrim( SM0->M0_TEL ) )
         EndIf
         RestArea( aAreaSM0 )

         cProcHTML := oProcess:Start( cDirHTML )
         If !Empty( cProcHTML )
            lRet := .T.
         EndIf
      EndIf
   EndIf

Return( lRet )
