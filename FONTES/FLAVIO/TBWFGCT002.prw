#INCLUDE 'totvs.ch'

/*/{Protheus.doc} WFGCT002
	(Função para executar a função static call TBENVNOTWF. Essa função foi feita por conta da descontinuação da staticcall)

	@type Class
	@author Vitor Ribeiro - vitor.ribeiro@wikitec.com.br (Consultoria Wikitec)
	@since 21/01/2022
	/*/
User Function WFGCT002(n_Opc)
Return TBENVNOTWF(n_Opc)

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} TBENVNOTWF
@description Rotina responsavel pelo envio do email de notificação do workflow
@author Leonardo Pereira
@since 21/02/2020
@version 1.0
@return Nil
/*/
//---------------------------------------------------------------------------------------------
Static Function TBENVNOTWF( nOpc )
Local cURL1       := SuperGetMV( 'TB_WFLINK1', .F., 'http://127.0.0.1:8070' )
Local cURL2       := SuperGetMV( 'TB_WFLINK2', .F., 'http://127.0.0.1:8070' )
Local cURLDir     := SuperGetMv( 'TB_HTMLDIR', .F., '\workflow\html\' )
Local cDirHTML    := SuperGetMV( 'TB_HTMFOR4', .F., '\workflow\modelos\TBNotAprovRejGCT.htm' )
Local cFornec     := ""
Local oProcess
Local cProcLINK   := ''
Local cWFTipo     := ''
Local cTitulo     := OEMToAnsi( 'Contrato - '+CN9->CN9_NUMERO)
Local aAreaCNC    := CNC->(GetArea())

/*/ Criação do LINK /*/
Local cLinkWF1 := ( cURL1 + StrTran( cURLDir, '\', '/') + AllTrim( cProcHTML ) + '.htm' )
Local cLinkWF2 := ( cURL2 + StrTran( cURLDir, '\', '/') + AllTrim( cProcHTML ) + '.htm' )

   //Ajusta o titulo da Medição
   If nOpc == 3
      cTitulo := OEMToAnsi("Medição - "+AllTrim(CND->CND_NUMMED)+" - Contrato - "+CN9->CN9_NUMERO)
   ElseIf nOpc == 2
      cTitulo := OEMToAnsi("Revisao Contrato "+CN9->CN9_NUMERO)
   ElseIf nOpc == 1
      cTitulo := OEMToAnsi("Contrato "+CN9->CN9_NUMERO)
   EndIf

   //Pega os dados do Fornecedor
   DbSelectArea("SA2")
   SA2->( DbSetOrder( 1 ) )

   DbSelectArea("CNC")
   CNC->(DbSelectArea(1))//CNC_FILIAL, CNC_NUMERO, CNC_REVISA, CNC_CODIGO, CNC_LOJA

   If CNC->(DbSeek(CN9->(CN9_FILIAL+CN9_NUMERO+CN9_REVISA)))
      If SA2->( DbSeek( xFilial( 'SA2' ) + CNC->(CNC_CODIGO+CNC_LOJA) ) )
         cTitulo := cTitulo+OEMToAnsi(" - "+SA2->A2_NOME)
         cFornec := SA2->(A2_COD+"/"+A2_LOJA+" - "+A2_NOME)
      EndIf
   EndIf

	/*/ Criação do Processo /*/
   oProcess := TWFProcess():New( 'WFCAD2', OEMToAnsi( cTitulo ) )

	/*/ Informando o HTML e o código do processo que compõem este Processo /*/
   oProcess:NewTask( cTitulo, cDirHTML )

	/*/ Definindo o Assunto do E-mail (propriedade cSubject) /*/
   oProcess:cSubject := cTitulo

	/*/ Definindo o(s) Destinatário(s) do E-mail (propriedade cTo. Mais de um destinatário, separar por ;) /*/
   oProcess:cTo := cMailWF

   If ( nOpc == 1 )
      cWFTipo := OEMToAnsi( 'inclusão' )
   ElseIf ( nOpc == 2 )
      cWFTipo := OEMToAnsi( 'revisão' )
   ElseIf ( nOpc == 3 )
      cWFTipo := OEMToAnsi( 'medição' )
   EndIf

   oProcess:oHTML:ValByName( 'WFTIPO', cWFTipo )
   oProcess:oHTML:ValByName( 'FORNEC', cFornec)

   // Condição de pagamento
   DbSelectArea( 'SE4' )
   SE4->( DbSetOrder( 1 ) )
   If SE4->( DbSeek( xFilial( 'SE4' ) + CN9->CN9_CONDPG ) )
         oProcess:oHTML:ValByName( 'CONDPG'  , SE4->E4_CODIGO + ' - ' + AllTrim( SE4->E4_DESCRI )) 
   EndIf

   if nOpc == 1 .OR. nOpc == 2
      oProcess:oHTML:ValByName( 'TPWF', "DO CONTRATO") 
      oProcess:oHTML:ValByName( 'TOTCT', TotPrev(CN9->CN9_NUMERO, CN9->CN9_REVISA)) 
   elseif NoPC == 3
      oProcess:oHTML:ValByName( 'TPWF', "DA MEDIÇÃO") 
      oProcess:oHTML:ValByName( 'TOTCT', TotMed(CND->CND_NUMMED)) 
   endif

   oProcess:oHTML:ValByName( 'LINK1', cLinkWF1 )
   oProcess:oHTML:ValByName( 'LINK2', cLinkWF2 )
   oProcess:oHTML:ValByName( 'EMPRESA', Upper( AllTrim( FWEmpName( cEmpAnt ) ) ) )

	/*/ Envio do E-mail do LINK /*/
   cProcLINK := oProcess:Start()

RestArea(aAreaCNC)
Return

/*/{Protheus.doc} TotPrev(CN9->CN9_NUMERO)
   (long_description)
   @type  Static Function
   @author user
   @since 27/10/2020
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
   /*/
Static Function TotPrev(cNumCtr, cRevisa)
Local aAreaCNF := CNF->(GetArea())
Local nVlr     := 0

DbSelectArea("CNF") //Cronograma financeiro
CNF->(DbSetOrder(2))//CNF_FILIAL, CNF_CONTRA, CNF_REVISA, CNF_NUMERO, CNF_COMPET

//Localiza o cronograma financeiro
If CNF->(DbSeek(xFilial("CNF")+cNumCtr+cRevisa))
   While CNF->(!Eof() .AND. xFilial("CNF")+cNumCtr+cRevisa == CNF_FILIAL+CNF_CONTRA+CNF_REVISA)
      nVlr += CNF->CNF_VLPREV
      CNF->(DbSkip())
   end
EndIf

RestArea(aAreaCNF)
Return "R$"+Transform(nVlr, "@E 999,999,999.99")

/*/{Protheus.doc} TotMed
   (long_description)
   @type  Static Function
   @author user
   @since 27/10/2020
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
   /*/
Static Function TotMed(cNumMed)
Local aAreaCND := CND->(GetArea())
Local nVlr     := 0

DbSelectArea("CND") //Cronograma financeiro
CND->(DbSetOrder(4))//CND_FILIAL, CND_NUMMED

//Localiza o cronograma financeiro
If CND->(DbSeek(xFilial("CND")+cNumMed))
      nVlr += CND->CND_VLTOT
      CND->(DbSkip())
EndIf

RestArea(aAreaCND)
Return "R$"+Transform(nVlr, "@E 999,999,999.99")
