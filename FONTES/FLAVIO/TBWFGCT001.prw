#Include "Totvs.ch"

/*/{Protheus.doc} WFGCT001
	(Função para executar a função static call TBGERFORWF. Essa função foi feita por conta da descontinuação da staticcall)

	@type Class
	@author Vitor Ribeiro - vitor.ribeiro@wikitec.com.br (Consultoria Wikitec)
	@since 21/01/2022
	/*/
User Function WFGCT001(n_Opc,c_TpDoc)
Return TBGERFORWF(n_Opc,c_TpDoc)

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TBGERFORWF
@description Rotina responsavel pela geração do formulário do WORKFLOW
@author Leonardo Pereira
@since 05/09/2019
@version 1.0
@return Nil
/*/
//----------------------------------------------------------------------------------------------
Static Function TBGERFORWF( nOpc, cTpDoc )

	Local oProcess

	Local lRet := .F.

	Local cFormHTML := ''
	Local cMemoCto := ''

	Local cDirHTML := SuperGetMv( 'TB_HTMLDIR', .F., '\workflow\html\' )

	Local cTitulo := OEMToAnsi( 'Contratos' )

	Local nSubTot := 0
	Local nTotDesc := 0

	If ( nOpc ==  1 )
		cFormHTML := SuperGetMv( 'TB_HTMFOR7', .F., '\workflow\modelos\TBFormContrato.htm' )
	ElseIf ( nOpc == 2 )
		cFormHTML := SuperGetMv( 'TB_HTMFOR8', .F., '\workflow\modelos\TBFormRevisao.htm' )
	ElseIf ( nOpc == 3 )
		cFormHTML := SuperGetMv( 'TB_HTMFOR9', .F., '\workflow\modelos\TBFormMedicao.htm' )
	EndIf

	//E-Mail que será copiado em todos os WFs
	cMailWF += Iif(!Empty(cMailWF),";", "")+SuperGetMV("MV_XWFMAIL",,"erika.monteiro@tecnobank.com.br")

	/*/
	Realiza a geração do formulário.
	/*/
	/*/ Criação do Processo /*/
	oProcess := TWFProcess():New( 'WFCAD1', Iif(nOpc == 2, "Revisao", cTitulo) )

	/*/ Informando o HTML e o código do processo que compõem este Processo /*/
	oProcess:NewTask( cTitulo, cFormHTML )

	/*/ Definindo o Assunto do E-mail (propriedade cSubject) /*/
	oProcess:cSubject := Iif(nOpc == 2, "Revisao Contrato "+CN9->CN9_NUMERO, Iif(nOpc == 1, "Contrato "+CN9->CN9_NUMERO, cTitulo) )

	/*/ Definindo o(s) Destinatário(s) do e-mail (propriedade cTo. Mais de um destinatário, separar por ;) /*/
	oProcess:cTo := 'HTML'

	/*/ Código do usuário no Protheus que receberá o e-mail./*/
	oProcess:UserSiga := '000000'

	/*/ Definindo a Função ADVPL de Retorno (propriedade bReturn)./*/
	/*/ Esta função será executada quando o Workflow receber o e-mail de resposta de um dos destinatários informados nas propriedades acima. /*/
	oProcess:bReturn := 'U_TBRETGCTFORWF()'

	cWFId := ( oProcess:fProcessId + oProcess:fTaskId )

	oProcess:oHTML:ValByName( 'WFEMPRESA', cEmpAnt )
	oProcess:oHTML:ValByName( 'WFFILIAL', cFilAnt )
	oProcess:oHTML:ValByName( 'WFNOPC', StrZero( nOpc, 1 ) )
	oProcess:oHTML:ValByName( 'WFTIPODOC', cTpDoc )
	oProcess:oHTML:ValByName( 'WFNIVEL', SCR->CR_NIVEL )

	oProcess:oHTML:ValByName( 'WFCONTRATO', CN9->CN9_NUMERO )
	oProcess:oHTML:ValByName( 'WFREVISAO', CN9->CN9_REVISA )

	If ( nOpc == 1 ) .Or. ( nOpc == 2 )
		oProcess:oHTML:ValByName( 'WFVLRATUAL', AllTrim( Transform( CN9->CN9_VLATU, '999,999,999.99' ) ) )
		oProcess:oHTML:ValByName( 'WFDTINI', DtoC( CN9->CN9_DTINIC ) )
		oProcess:oHTML:ValByName( 'WFDTFIM', DtoC( CN9->CN9_DTFIM ) )
		oProcess:oHTML:ValByName( 'CN9_TPCTO' , Posicione( 'CN1', 1, xFilial( 'CN1' ) + CN9->CN9_TPCTO, 'CN1_DESCRI' ) )
		oProcess:oHTML:ValByName( 'QTDE_PARCELAS', AllToChar(PegaQtdPar(CN9->CN9_FILIAL, CN9->CN9_NUMERO, CN9->CN9_REVISA)[1]) )
		oProcess:oHTML:ValByName( 'VALOR_PARCELA', AllTrim( Transform( PegaQtdPar(CN9->CN9_FILIAL, CN9->CN9_NUMERO, CN9->CN9_REVISA)[2], '999,999,999.99' ) )  )

	If nOpc == 2
		oProcess:oHTML:ValByName( 'CN9_VLADIT'  , AllTrim( Transform( CN9->CN9_VLADIT, '999,999,999.99' ) ) )
	EndIf

	ElseIf ( nOpc == 3 )
		oProcess:oHTML:ValByName( 'WFNUMMED'  , CND->CND_NUMMED )
		oProcess:oHTML:ValByName( 'WFVLRMED'  , AllTrim( Transform( CND->CND_VLTOT, '999,999,999.99' ) ) )
		oProcess:oHTML:ValByName( 'CND_COMPET', CND->CND_COMPET )
		oProcess:oHTML:ValByName( 'CN9_TPCTO' , Posicione( 'CN1', 1, xFilial( 'CN1' ) + CN9->CN9_TPCTO, 'CN1_DESCRI' ) )

		DbSelectArea("CNA")
		CNA->(DbSetOrder(3))//CNA_FILIAL+CNA_CONTRA+CNA_REVISA

		If CNA->(DbSeek(CN9->(CN9_FILIAL+CN9_NUMERO+CN9_REVISA)))
			oProcess:oHTML:ValByName( 'CNA_VLTOT' , AllTrim( Transform(CNA->CNA_VLTOT, '999,999,999.99' ) )  )
			oProcess:oHTML:ValByName( 'CNA_SALDO' , AllTrim( Transform(CNA->CNA_SALDO, '999,999,999.99' ) )  )
		EndIf

		oProcess:oHTML:ValByName( 'CN9_DTINIC', CN9->CN9_DTINIC )
		oProcess:oHTML:ValByName( 'CN9_DTFIM' , Iif(CN9->CN9_UNVIGE <> "4" ,CN9->CN9_DTFIM, "INDETERMINADO")  )

		DbSelectArea( 'SYP' )
		If ( DbSeek( xFilial( 'SYP' ) + CN9->CN9_CODOBJ ) )
			While !SYP->( Eof() ) .And. ( SYP->YP_CHAVE == CN9->CN9_CODOBJ )
				cMemoCto += AllTrim(SYP->YP_TEXTO ) + Chr( 13 ) + Chr( 10 )
				SYP->( DbSkip() )
			End
		EndIf
			
		oProcess:oHTML:ValByName( 'CN9_OBJCTO', RemovCarEsp(cMemoCto) )
	EndIf

	/*/ Coleta dados do fornecedor /*/
	CNC->( DbSetOrder( 1 ) )
	If CNC->( DbSeek( xFilial( 'CNC' ) + CN9->CN9_NUMERO + CN9->CN9_REVISA ) )
		While !CNC->( Eof() ) .And. ( CNC->CNC_FILIAL + CNC->CNC_NUMERO + CNC->CNC_REVISA == CN9->CN9_FILIAL + CN9->CN9_NUMERO + CN9->CN9_REVISA )
			SA2->( DbSetOrder( 1 ) )
			If SA2->( DbSeek( xFilial( 'SA2' ) + CNC->CNC_CODIGO + CNC->CNC_LOJA ) )
				aAdd( oProcess:oHtml:ValByName( 'FOR.CODIGO' ), SA2->A2_COD + '/' + SA2->A2_LOJA )
				aAdd( oProcess:oHtml:ValByName( 'FOR.NOME' ), AllTrim( SA2->A2_NOME ) )
			EndIf
			CNC->( DbSkip() )
		End
	EndIf

	If ( nOpc == 1 ) .Or. ( nOpc == 2 )
		/*/ Coleta dados dos itens do contrato /*/
		CNB->( DbSetOrder( 1 ) )
		If CNB->( DbSeek( xFilial( 'CNB' ) + CN9->CN9_NUMERO + CN9->CN9_REVISA ) )
			While !CNB->( Eof() ) .And. ( CNB->CNB_FILIAL + CNB->CNB_CONTRA + CNB->CNB_REVISA == CN9->CN9_FILIAL + CN9->CN9_NUMERO + CN9->CN9_REVISA )
				aAdd( oProcess:oHtml:ValByName( 'IT.ITEM' ), CNB->CNB_ITEM )
				aAdd( oProcess:oHtml:ValByName( 'IT.CODIGO' ), CNB->CNB_PRODUT )
				aAdd( oProcess:oHtml:ValByName( 'IT.DESCRI' ), AllTrim( CNB->CNB_DESCRI ) )
				aAdd( oProcess:oHtml:ValByName( 'IT.QUANT' ), AllTrim( Transform( CNB->CNB_QUANT, '999,999,999.99' ) ) )
				aAdd( oProcess:oHtml:ValByName( 'IT.UM' ), CNB->CNB_UM )
				aAdd( oProcess:oHtml:ValByName( 'IT.VLRUNIT' ), AllTrim( Transform( CNB->CNB_VLUNIT, '999,999,999.99' ) ) )

				/*
				If nOpc == 2
					aAdd( oProcess:oHtml:ValByName( 'IT.DESC' ), AllTrim( Transform( CNB->CNB_DESC, '99.99' ) ) )
				EndIf
				*/

				aAdd( oProcess:oHtml:ValByName( 'IT.VLRTOT' ), AllTrim( Transform( CNB->CNB_VLTOT, '999,999,999.99' ) ) )

				nSubTot += CNB->CNB_VLTOT
				nTotDesc += CNB->CNB_VLDESC

				CNB->( DbSkip() )
			End
		EndIf
	ElseIf ( nOpc == 3 )
		/*/ Coleta dados dos itens da medição /*/
		CNE->( DbSetOrder( 5 ) )
		If CNE->( DbSeek( xFilial( 'CNB' ) + CN9->CN9_NUMERO + CN9->CN9_REVISA + CND->CND_NUMMED ) )
			While !CNE->( Eof() ) .And. ( CNE->CNE_FILIAL + CNE->CNE_CONTRA + CNE->CNE_REVISA + CNE->CNE_NUMMED == CN9->CN9_FILIAL + CN9->CN9_NUMERO + CN9->CN9_REVISA + CND->CND_NUMMED )
				aAdd( oProcess:oHtml:ValByName( 'IT.ITEM' ), CNE->CNE_ITEM )
				aAdd( oProcess:oHtml:ValByName( 'IT.CODIGO' ), CNE->CNE_PRODUT )
				aAdd( oProcess:oHtml:ValByName( 'IT.DESCRI' ), AllTrim( Posicione( 'SB1', 1, xFilial( 'SB1' ) + CNE->CNE_PRODUT, 'B1_DESC' ) ) )
				aAdd( oProcess:oHtml:ValByName( 'IT.QUANT' ), AllTrim( Transform( CNE->CNE_QUANT, '999,999,999.99' ) ) )
				aAdd( oProcess:oHtml:ValByName( 'IT.UM' ), AllTrim( Posicione( 'SB1', 1, xFilial( 'SB1' ) + CNE->CNE_PRODUT, 'B1_UM' ) ) )
				aAdd( oProcess:oHtml:ValByName( 'IT.VLRUNIT' ), AllTrim( Transform( CNE->CNE_VLUNIT, '999,999,999.99' ) ) )
				//aAdd( oProcess:oHtml:ValByName( 'IT.DESC' ), AllTrim( Transform( CNE->CNE_PDESC, '99.99' ) ) )
				aAdd( oProcess:oHtml:ValByName( 'IT.VLRTOT' ), AllTrim( Transform( CNE->CNE_VLTOT, '999,999,999.99' ) ) )

				nSubTot += CNE->CNE_VLTOT
				nTotDesc += CNE->CNE_VLDESC

				CNE->( DbSkip() )
			End
		EndIf
	EndIf

	oProcess:oHtml:ValByName( 'WFSUBTOT', AllTrim( Transform( nSubTot, '999,999,999.99' ) ) )

	/*
	If ( nOpc == 2 )
		oProcess:oHtml:ValByName( 'WFTOTDESC', AllTrim( Transform( nTotDesc, '999,999,999.99' ) ) )
	EndIf
	*/

	oProcess:oHtml:ValByName( 'WFTOTGCT', AllTrim( Transform( ( nSubTot - nTotDesc ), '999,999,999.99' ) ) )

	If ( nOpc == 1 )
		If ( FunName() == 'CNTA300' )
			DbSelectArea( 'SYP' )
			If ( DbSeek( xFilial( 'SYP' ) + CN9->CN9_CODOBJ ) )
				While !SYP->( Eof() ) .And. ( SYP->YP_CHAVE == CN9->CN9_CODOBJ )
					cMemoCto += AllTrim( SYP->YP_TEXTO ) + Chr( 13 ) + Chr( 10 )
					SYP->( DbSkip() )
				End
			EndIf
			oProcess:oHtml:ValByName( 'WFOBS1', OEMToAnsi( RemovCarEsp(cMemoCto) ) )
		Else
			oProcess:oHtml:ValByName( 'WFOBS1', OEMToAnsi( RemovCarEsp(cWFObs1) ) )
		EndIf
	ElseIf ( nOpc == 2 )
		//Justificativa da Revisão
		DbSelectArea( 'SYP' )
		If ( DbSeek( xFilial( 'SYP' ) + CN9->CN9_CODJUS ) )
			While !SYP->( Eof() ) .And. ( SYP->YP_CHAVE == CN9->CN9_CODJUS )
				cMemoCto += AllTrim( SYP->YP_TEXTO ) + Chr( 13 ) + Chr( 10 )
				SYP->( DbSkip() )
			End
		EndIf

		oProcess:oHtml:ValByName( 'WFOBS1', OEMToAnsi( RemovCarEsp(cMemoCto) ) )

		//Objeto do Contrato
		cMemoCto := ""
		
		DbSelectArea( 'SYP' )
		If ( DbSeek( xFilial( 'SYP' ) + CN9->CN9_CODOBJ ) )
			While !SYP->( Eof() ) .And. ( SYP->YP_CHAVE == CN9->CN9_CODOBJ )
				cMemoCto += AllTrim( SYP->YP_TEXTO ) + Chr( 13 ) + Chr( 10 )
				SYP->( DbSkip() )
			End
		EndIf
		
		oProcess:oHtml:ValByName( 'WFOBJCTR', OEMToAnsi( RemovCarEsp(cMemoCto) ) )


	ElseIf ( nOpc == 3 )
		oProcess:oHtml:ValByName( 'WFOBS1', OEMToAnsi( RemovCarEsp(CND->CND_OBS) ) )
	EndIf

	cProcHTML := oProcess:Start( cDirHTML )
	If !Empty( cProcHTML )
		lRet := .T.
	EndIf

Return( lRet )

/*/{Protheus.doc} RemovCarEsp
cText)
   @type  Static Function
   
   
         //Remove caracteres especiais para HTML
      cMemoCto := Replace(cMemoCto, 'Ç', 'C')
      cMemoCto := Replace(cMemoCto, 'Õ', 'O')
      cMemoCto := Replace(cMemoCto, 'Ó', 'O')
      cMemoCto := Replace(cMemoCto, 'Ã', 'A')
      cMemoCto := Replace(cMemoCto, 'Á', 'A')
      cMemoCto := Replace(cMemoCto, 'É', 'E')
      cMemoCto := Replace(cMemoCto, 'Ê', 'E')
      cMemoCto := Replace(cMemoCto, 'Í', 'I')uthor user
   @since 27/05/2021
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
   /*/
Static Function RemovCarEsp(cText)

	//Remove caracteres especiais para HTML
	
	cText := Replace(cText, 'Ç', 'C')
	cText := Replace(cText, 'Õ', 'O')
	cText := Replace(cText, 'Ó', 'O')
	cText := Replace(cText, 'Ã', 'A')
	cText := Replace(cText, 'Á', 'A')
	cText := Replace(cText, 'É', 'E')
	cText := Replace(cText, 'Ê', 'E')
	cText := Replace(cText, 'Í', 'I')

	cText := Replace(cText, 'ç', 'c')
	cText := Replace(cText, 'õ', 'o')
	cText := Replace(cText, 'ó', 'o')
	cText := Replace(cText, 'ã', 'a')
	cText := Replace(cText, 'á', 'a')
	cText := Replace(cText, 'é', 'e')
	cText := Replace(cText, 'ê', 'e')
	cText := Replace(cText, 'í', 'i')

Return cText

/*/{Protheus.doc} PegaQtdPar
   (Função que pega no cronograma financeiro a quantidade de parcelas)
   @type  Static Function
   @author Pirolo
   @since 10/06/2021
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   /*/
Static Function PegaQtdPar(cFilCtr, cNumCtr, cRevis)
Local nNumPar  := 0
Local nVlUltPa := 0
Local aAreaCNF := CNF->(GetArea())

DbSelectArea("CNF")
CNF->(DbSetOrder(3))//CNF_FILIAL, CNF_CONTRA, CNF_REVISA, CNF_NUMERO, CNF_PARCEL

If CNF->(DbSeek(cFilCtr+cNumCtr+cRevis))
	While CNF->(!Eof()) .AND. CNF->(CNF_FILIAL+CNF_CONTRA+CNF_REVISA) == cFilCtr+cNumCtr+cRevis
		If Val(CNF->CNF_PARCEL) > nNumPar
			nNumPar  := Val(CNF->CNF_PARCEL)
			nVlUltPa := CNF->CNF_VLPREV
		EndIf

		CNF->(DbSkip())
	EndDo
EndIf

RestArea(aAreaCNF)
Return {nNumPar, nVlUltPa}
