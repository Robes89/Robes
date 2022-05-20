#INCLUDE 'totvs.ch'

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TBGEFOWF
@description Rotina responsavel pela geração do formulário do WORKFLOW
@author Leonardo Pereira
@since 05/09/2019
@version 1.0
@return Nil
/*/
//----------------------------------------------------------------------------------------------
User Function TBGEFOWF()

   Local oProcess
   Local lRet := .F.

   Local cDirHTML := SuperGetMv( 'TB_HTMLDIR', .F., '\workflow\html\' )
   Local cFormHTML := SuperGetMv( 'TB_HTMFOR5', .F., '\workflow\modelos\tbformpedido.htm' )

   Local cTitulo := OEMToAnsi( 'Pedido de Compra' )

   Local aCond := { }
   Local aFrete := { }

   Local nSubTot := 0
   Local nTotDesc := 0
   Local nTotIpi := 0
   Local nTotFrete := 0
   Local nTotPed := 0

   Local cObsPed := ''

   Local aAreaSM0 := SM0->( GetArea() )
   Local aAreaSC7 := SC7->( GetArea() )
	/*/
   Realiza a geração do formulário.
	/*/
	/*/ Criação do Processo /*/
   oProcess := TWFProcess():New( 'WFCAD1', cTitulo )

	/*/ Informando o HTML e o código do processo que compõem este Processo /*/
   oProcess:NewTask( cTitulo, cFormHTML )

	/*/ Definindo o Assunto do E-mail (propriedade cSubject) /*/
   oProcess:cSubject := cTitulo

	/*/ Definindo o(s) Destinatário(s) do e-mail (propriedade cTo. Mais de um destinatário, separar por ;) /*/
   oProcess:cTo := 'HTML'

	/*/ Código do usuário no Protheus que receberá o e-mail./*/
   oProcess:UserSiga := '000000'

	/*/ Definindo a Função ADVPL de Retorno (propriedade bReturn)./*/
	/*/ Esta função será executada quando o Workflow receber o e-mail de resposta de um dos destinatários informados nas propriedades acima. /*/
   oProcess:bReturn := 'StaticCall( TBWFPED003, TBRETFORWF )'

   cWFId := ( oProcess:fProcessId + oProcess:fTaskId )
   cNumPed := SC7->C7_NUM

   SA2->( DbSetOrder( 1 ) )
   If SA2->( DbSeek( xFilial( 'SA2' ) + SC7->C7_FORNECE + SC7->C7_LOJA ) )
      oProcess:oHTML:ValByName( 'WFEMPRESA', cEmpAnt )
      oProcess:oHTML:ValByName( 'WFFILIAL', cFilAnt )

      oProcess:oHTML:ValByName( 'WFNIVEL', SCR->CR_NIVEL )
      oProcess:oHTML:ValByName( 'WFAPROVADOR', SCR->CR_APROV )
      oProcess:oHTML:ValByName( 'WFID', cWFId )

      oProcess:oHTML:ValByName( 'WFPEDIDO', SC7->C7_NUM )
      oProcess:oHTML:ValByName( 'WFFORNECEDOR', SC7->C7_FORNECE )
      oProcess:oHTML:ValByName( 'WFLOJA', SC7->C7_LOJA )
      oProcess:oHTML:ValByName( 'WFNOMEFOR', AllTrim( SA2->A2_NOME ) )
      oProcess:oHTML:ValByName( 'WFENDERECO', AllTrim( SA2->A2_END ) )
      oProcess:oHTML:ValByName( 'WFBAIRRO', AllTrim( SA2->A2_BAIRRO ) )
      oProcess:oHTML:ValByName( 'WFCIDADE', AllTrim( SA2->A2_MUN ) )
      oProcess:oHTML:ValByName( 'WFUF', AllTrim( SA2->A2_EST ) )
      oProcess:oHTML:ValByName( 'WFTELEFONE', AllTrim( SA2->A2_TEL ) )

      While !SC7->( Eof() ) .And. ( SC7->C7_NUM == cNumPed )
         aAdd( oProcess:oHtml:ValByName( 'IT.ITEM' ), SC7->C7_ITEM )
         aAdd( oProcess:oHtml:ValByName( 'IT.CODIGO' ), AllTrim( SC7->C7_PRODUTO ) )
         aAdd( oProcess:oHtml:ValByName( 'IT.DESC' ), AllTrim( SC7->C7_DESCRI ) )
         aAdd( oProcess:oHtml:ValByName( 'IT.QUANT' ), Transform( SC7->C7_QUANT, '@E 9,999,999.99' ) )
         aAdd( oProcess:oHtml:ValByName( 'IT.UM' ), SC7->C7_UM )
         aAdd( oProcess:oHtml:ValByName( 'IT.VLRUNIT' ), Transform( SC7->C7_PRECO, '@E 9,999,999.99' ) )
         aAdd( oProcess:oHtml:ValByName( 'IT.VLRTOT' ), Transform( SC7->C7_TOTAL, '@E 9,999,999.99' ) )
         aAdd( oProcess:oHtml:ValByName( 'IT.IPI' ), Transform( SC7->C7_IPI, '@E 99.99' ) )
         aAdd( oProcess:oHtml:ValByName( 'IT.CCUSTO' ), AllTrim( SC7->C7_CC ) )
         aAdd( oProcess:oHtml:ValByName( 'IT.ENTREGA' ), DtoC( SC7->C7_DATPRF ) )

         /*/ Agrega as observações dos produtos /*/
         cObsPed += AllTrim( SC7->C7_OBS ) + Chr( 13 ) + Chr( 10 )

         /*/ Totalizadores /*/
         nSubTot += SC7->C7_TOTAL
         nTotDesc += SC7->C7_VLDESC
         nTotIpi += SC7->C7_VALIPI
         nTotFrete += SC7->C7_VALFRE

         SC7->( DbSkip() )
      End
      RestArea( aAreaSC7 )

      nTotPed := ( ( nSubTot + nTotIpi + nTotFrete) - nTotDesc )

      oProcess:oHTML:ValByName( 'WFSUBTOT', Transform( nSubTot, '@E 9,999,999.99' ) )
      oProcess:oHTML:ValByName( 'WFTOTDESC', Transform( nTotDesc, '@E 9,999,999.99' ) )
      oProcess:oHTML:ValByName( 'WFTOTIPI', Transform( nTotIpi, '@E 9,999,999.99' ) )
      oProcess:oHTML:ValByName( 'WFTOTFRETE', Transform( nTotFrete, '@E 9,999,999.99' ) )
      oProcess:oHTML:ValByName( 'WFTOTPED', Transform( nTotPed, '@E 9,999,999.99' ) )

      // Lista as condições de pagamento
      DbSelectArea( 'SE4' )
      SE4->( DbSetOrder( 1 ) )
      If SE4->( DbSeek( xFilial( 'SE4' ) + SC7->C7_COND ) )
            aAdd( aCond, SE4->E4_CODIGO + ' - ' + AllTrim( SE4->E4_DESCRI ) )
      EndIf
      oProcess:oHtml:ValByName( 'WFCONDPAG', aCond )

      /*/ Lista as opções de tipo de frete /*/
      aAdd( aFrete, 'CIF' )
      aAdd( aFrete, 'FOB' )
      oProcess:oHtml:ValByName( 'WFTIPOFRETE', aFrete )

      SM0->( DbSetOrder( 1 ) )
      If SM0->( DbSeek( cEmpAnt + SC7->C7_FILENT ) )
         oProcess:oHtml:ValByName( 'WFENDENTREGA', AllTrim( SM0->M0_ENDENT ) )
         oProcess:oHtml:ValByName( 'WFBAIRRO', AllTrim( SM0->M0_BAIRENT ) )
         oProcess:oHtml:ValByName( 'WFCIDADE', AllTrim( SM0->M0_CIDENT ) )
         oProcess:oHtml:ValByName( 'WFUF', AllTrim( SM0->M0_ESTENT ) )
         oProcess:oHtml:ValByName( 'WFTELEFONE', AllTrim( SM0->M0_TEL ) )
      EndIf
      RestArea( aAreaSM0 )

      oProcess:oHtml:ValByName( 'WFOBS1', cObsPed )

      cProcHTML := oProcess:Start( cDirHTML )
      If !Empty( cProcHTML )
         lRet := .T.
      EndIf
   EndIf

Return( lRet )
