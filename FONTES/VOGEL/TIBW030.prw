#INCLUDE 'PROTHEUS.CH'
#include "rptdef.ch"
#INCLUDE "FWPrintSetup.ch"

Static nRemType := GetRemoteType()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³TIBW030    ³Autor  ³V. RASPA                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³Funcao responsavel pelo montagem e envio do processo de     ³±±
±±³          ³workflow - Aprovacao de Pedidos de Compra                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function TIBW030(cAlias, nReg, nOpc, aStruct, cNumPC)
	Local cArq := ''

	If U_LibWFPC()

		If nRemType == 2 // REMOTE_LINUX
			cArq := '/WEB/TEMPLATE/WFA030.HTML'
		Else
			cArq := '\WEB\TEMPLATE\WFA030.HTML'
		Endif

		If File(cArq)
			If Aviso('Workflow', 'Deseja enviar o processo de workflow para o pedido de compra selecionado?', {'SIM', 'NAO'}, 2) == 1
				MsgRun('Montando processo de workflow', 'Aguarde...',;
					{|| U_TIBW030Send(cNumPC)})
			EndIf
		Else
			Help('', 1, 'TIBW030',, 'Não foi encontrado o arquivo de template para envio do processo de workflow!', 1, 0)
		EndIf

	Endif


Return

/*/{Protheus.doc} LibWFPC
Libera ou nao o uso do workflow para uso do cliente
@author Giane
@since 05/01/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function LibWFPC()
	Local lRet := .T.
	Local aHardLock  := {}  //Lista de hardlocks liberados para uso
	Local aCNPJLib   := {}  //Lista de cnpjs liberados para uso

//HardLocks liberados para utilizar a rotina
	aAdd(aHardLock, 2100013039)  //TotvsIbirapuera

//CNPJ's liberados para utilizar a rotina
	aAdd(aCNPJLib, "        ")  //Empresa 99-Teste
	aAdd(aCNPJLib, "44045565") //CGA
	aAdd(aCNPJLib, "17774501") //sices brasil
	aAdd(aCNPJLib, "13099243") //SMITHs
	aAdd(aCNPJLib, "48791685") //CBS
//PARTAGE INICIO
	aAdd(aCNPJLib, "01987230")
	aAdd(aCNPJLib, "03557614")
	aAdd(aCNPJLib, "04151732")
	aAdd(aCNPJLib, "05212761")
	aAdd(aCNPJLib, "07078019")
	aAdd(aCNPJLib, "07305697")
	aAdd(aCNPJLib, "08323866")
	aAdd(aCNPJLib, "09302560")
	aAdd(aCNPJLib, "09302615")
	aAdd(aCNPJLib, "09302624")
	aAdd(aCNPJLib, "09302634")
	aAdd(aCNPJLib, "09324208")
	aAdd(aCNPJLib, "09515348")
	aAdd(aCNPJLib, "09537145")
	aAdd(aCNPJLib, "09537422")
	aAdd(aCNPJLib, "09607519")
	aAdd(aCNPJLib, "10908921")
	aAdd(aCNPJLib, "11794996")
	aAdd(aCNPJLib, "12259957")
	aAdd(aCNPJLib, "12909302")
	aAdd(aCNPJLib, "13008381")
	aAdd(aCNPJLib, "13196583")
	aAdd(aCNPJLib, "13196641")
	aAdd(aCNPJLib, "13783299")
	aAdd(aCNPJLib, "13921046")
	aAdd(aCNPJLib, "16417174")
	aAdd(aCNPJLib, "16417318")
	aAdd(aCNPJLib, "16433025")
	aAdd(aCNPJLib, "16692397")
	aAdd(aCNPJLib, "16935381")
	aAdd(aCNPJLib, "16935384")
	aAdd(aCNPJLib, "16935452")
	aAdd(aCNPJLib, "16935523")
	aAdd(aCNPJLib, "17007260")
	aAdd(aCNPJLib, "17007273")
	aAdd(aCNPJLib, "17007284")
	aAdd(aCNPJLib, "21042647")
	aAdd(aCNPJLib, "23502221")
	aAdd(aCNPJLib, "23540312")
	aAdd(aCNPJLib, "23547040")
	aAdd(aCNPJLib, "23547056")
//PARTAGE FIM

	aAdd(aCNPJLib, "44045565") //SICES
	aAdd(aCNPJLib, "52493970") //Induspeças
	aAdd(aCNPJLib, "62025606") //FPF – Federação Paulista de Futebol
	aAdd(aCNPJLib, "13727162") // tawcoplast 0001-78
	aAdd(aCNPJLib, "00960272") //GP ELETRONICA
	aAdd(aCNPJLib, "00971855") //gpzinha
	aAdd(aCNPJLib, "04349636") //CTT
	aAdd(aCNPJLib, "62365697") //IPE CLUBE
	aAdd(aCNPJLib, "02505572") //OR BRASIL

	aAdd(aCNPJLib, "54437553") //Multijuntas
	aAdd(aCNPJLib, "02882381") //Multijuntas
	aAdd(aCNPJLib, "05676122") //Multijuntas
	aAdd(aCNPJLib, "03586087") //Multijuntas

	aAdd(aCNPJLib, "46553863") // Kyocera Componentes (Cliente no Sistema da Planaudi)

	aAdd(aCNPJLib, "66759887") //KOYO

	aAdd(aCNPJLib, "19464930") //Network1

	aAdd(aCNPJLib, "19902753") //Centennial
	aAdd(aCNPJLib, "26889233") //Polar

	aAdd(aCNPJLib, "05872814") //Voguel

//Valida autorização de execução
	If aScan(aHardLock, LS_GetID()) <= 0  //Verifica o hardlock
		If aScan(aCNPJLib, SubStr(SM0->M0_CGC,1,8)) <= 0  //Verifica o cnpj
			lRet := .F.
			Help('', 1, 'TIBW030',, 'Processo de Workflow não está liberado para uso na empresa corrente!', 1, 0)

		EndIf
	EndIf

Return lRet

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³FUNCAO    ³TIBW030SEND    ³Autor  ³V. RASPA                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³DESCRICAO ³Funcao responsavel pelo montagem e envio do processo de     ³±±
	±±³          ³workflow - Aprovacao de Pedidos de Compra                   ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function TIBW030Send(cNumPC)
	Local oProcess  := NIL
	Local cSimbMoed := SuperGetMV('MV_SIMB' + Alltrim(Str(SC7->C7_MOEDA)), .F., 'R$') + ' '
	Local cMailId   := ''
	Local cUrl      := ''
	Local cUrlImg   := ''
	Local cPastaHTM := ''
	Local cMailApr  := ''
	Local cDocto    := ''

	Local nValLiq   := 0
	Local nValIPI   := 0
	Local nValPed	:= 0
	Local nValDesc	:= 0
	Local nValTot   := 0
	Local nValFrete := 0

	Local cAliasQry := ''
	Local aDoctos   := {}
	Local nCount    := 0
	Local aAttach   := {}
	Local aFornece  := {}

	Local cBody 	 := "Olá, você está recebendo um pedido de compras para aprovação. Obrigado"
	Local dEmissao  := dDataBase

	Local cHTTPSrv  := AllTrim(SuperGetMV('ES_HTTPSRV',, 'localhost:6067/'))

	Local aArea     := GetArea()
	Local aAreaSA2  := SA2->(GetArea())
	Local aAreaSB1  := SB1->(GetArea())
	Local aAreaSC7  := SC7->(GetArea())
	Local cRootPath := GetPvProfString(GetEnvServer(), 'RootPath', 'ERROR', GetADV97())
	Local lBcoAnex  := SuperGetMv("ES_ANEXBCO",,.F.)
	Local cArq := ''
	Local cArqLink := ''
	Local nx := 0
	Local aProds := {}
	Local cLogoD := ""
	Local lObsItem	:= .F.
	Local cGrupoAprov := ""
	Local cObsAux := ""

	Default cNumPC  := SC7->C7_NUM

	If U_LibWFPC()


		cLogoD	:= GetSrvProfString("Startpath","") + "lgmid" + cEmpAnt + ".png"
		If !File(cLogoD)
			cLogoD := "logo.png"
		Else
			__CopyFile( cLogoD, '\WEB\TEMPLATE\' + "lgmid" + cEmpAnt + ".png" )
			__CopyFile( cLogoD, '\workflow\messenger\emp01\PROCESSOS\' + "lgmid" + cEmpAnt + ".png" )
			cLogoD := "lgmid" + cEmpAnt + ".png"
		EndIf

		If nRemType == 2 // REMOTE_LINUX
			cArq := '/WEB/TEMPLATE/WFA030.HTML'
			cArqLink := '/WEB/TEMPLATE/WFLink04.HTML'
		Else
			cArq := '\WEB\TEMPLATE\WFA030.HTML'
			cArqLink := '\WEB\TEMPLATE\WFLink04.HTML'
		Endif

		// -------------------------------------------
		// VALIDA A EXISTENCIA DO ARQUIVO DE TEMPLATE
		// -------------------------------------------
		If !File(cArq)
			Help('', 1, 'TIBW030',, 'Não foi encontrado o arquivo de template para envio do processo de workflow!', 1, 0)

		Else
			SC7->(DbSetOrder(1))
			If SC7->(DbSeek(xFilial('SC7')+cNumPC))

				cGrupoAprov := SC7->C7_APROV// BUSCANDO GRUPO DE APROVACAO

				// ----------------------------------------
				// Verifica as outras cotações
				//
				// ---------------------------------------
				cAliasQry := GetNextAlias()
				BeginSQl Alias cAliasQry
				SELECT 	SC8.C8_FORNOME, SC8.C8_FORNECE, SC8.C8_LOJA, SC8.C8_COND, SC8.C8_PRAZO,  SC8.C8_TOTAL , SC8.C8_PRODUTO , SB1.B1_DESC
				FROM 	%Table:SC8% SC8
				INNER JOIN 	%Table:SB1% SB1
				ON ( B1_COD = C8_PRODUTO )
				WHERE 	SC8.C8_FILIAL =  %xFilial:SC8% AND
						SC8.C8_NUM    =  %Exp:SC7->C7_NUMCOT% AND
						SC8.C8_NUMPED <> %Exp:SC7->C7_NUM% AND
						SC8.C8_FORNECE <> %Exp:SC7->C7_FORNECE% AND 
						SC8.%NotDel% AND 
						SB1.%NotDel%
				EndSQL

				(cAliasQry)->(DBEval({|| AAdd(aFornece, {C8_FORNOME, C8_COND, C8_PRAZO,;
					Posicione( 'SC8', 1, xFilial('SC8')+SC7->C7_NUMCOT+C8_FORNECE+C8_LOJA,'C8_OBSFOR'),;
					C8_TOTAL, C8_PRODUTO , B1_DESC})}))
				(cAliasQry)->(DbCloseArea())


				// ----------------------------------------
				// Verifica o controle de alcadas, somente
				// para Pedidos de Compra:
				// ---------------------------------------
				cAliasQry := GetNextAlias()
				BeginSQl Alias cAliasQry
				SELECT 	SCR.CR_STATUS, SCR.R_E_C_N_O_ nRecSCR
				FROM 	%Table:SCR% SCR
				WHERE 	SCR.CR_FILIAL =  %xFilial:SCR% AND
						SCR.CR_NUM    =  %Exp:SC7->C7_NUM% AND
						SCR.CR_TIPO   IN ('PC','IP') AND
						SCR.CR_WF     =  %Exp:Space(Len(SCR->CR_WF))% AND
						SCR.%NotDel%
				ORDER 
				BY 		SCR.CR_NUM, 
						SCR.CR_NIVEL, 
						SCR.R_E_C_N_O_
				EndSQL
				(cAliasQry)->(DBEval({|| If(CR_STATUS $ '02|04', AAdd(aDoctos, {CR_STATUS, nRecSCR}), NIL)},, {|| !Eof()}))
				(cAliasQry)->(DbCloseArea())


				For nCount := 1 To Len(aDoctos)
					SCR->(DbGoTo(aDoctos[nCount, 2]))
					cDocto := SCR->CR_NUM
					PswOrder(1)
					If PswSeek(SCR->CR_USER) .And. !Empty(PswRet()[1,14])
						cMailApr := AllTrim(PswRet()[1,14])
						//cMailApr := "marcelo.costa@triyo.com.br" //marcelo
						// ---------------------------------------------------------
						// Criacao do objeto TWFProcess, responsavel
						// pela inicializacao do processo de Workflow
						// ---------------------------------------------------------
						oProcess := TWFProcess():New('APR_PC', 'Criacao do Processo - Aprovacao de Pedidos')

						// ---------------------------------------------------------
						// Criacao de uma tarefa de workflow. Podem
						// existir varias tarefas. Para cada tarefa,
						// deve-se informar um nome e o HTML envolvido
						// ---------------------------------------------------------
						oProcess:NewTask('WFA010', cArq)

						// ---------------------------------------------------------
						// Determinacao da funcao que realiza o processamento
						// do retorno do workflow
						// ---------------------------------------------------------
						oProcess:bReturn := 'U_TIBW030Ret()'

						// ---------------------------------------------------------
						// Tratamento do timeout. Este tratamento tem o objetivo
						// de determinar o tempo maximo para processamento do retorno
						// ---------------------------------------------------------
						oProcess:bTimeOut := {{'TIBXTimeOut()', 0, 0, 5 }}

						// ---------------------------------------------------------
						// Realiza o preenchimento do HTML:
						// ---------------------------------------------------------
						SC7->(DbSetOrder(1))
						SC7->(DbSeek(xFilial('SC7')+cNumPC))

						SA2->(DbSetOrder(1))
						SA2->(DbSeek(xFilial('SA2')+SC7->(C7_FORNECE+C7_LOJA)))

						SE4->(DbSetOrder(1))
						SE4->(DbSeek(xFilial('SE4')+SC7->C7_COND))
                        
						NNR->(DbSetOrder(1))
						NNR->(DBSeek(xFilial('SC7')+SC7->C7_LOCAL))
						
						dEmissao := SC7->C7_EMISSAO

						//-- CABECALHO DO FORMULARIO
						oProcess:oHtml:ValByName('cNumPed'		, SC7->C7_NUM)
						oProcess:oHtml:ValByName('cFilial'      , SM0->M0_CODFIL + '-' + SM0->M0_CGC)
						oProcess:oHtml:ValByName('cLocal'		, SC7->C7_LOCAL + '-' + NNR->NNR_DESCRI)
						oProcess:oHtml:ValByName('dEmissao'		, SC7->C7_EMISSAO)
						oProcess:oHtml:ValByName('cCodFor'		, SC7->(C7_FORNECE + '/' + C7_LOJA))
						oProcess:oHtml:ValByName('cNomFor' 		, SA2->A2_NOME)
						oProcess:oHtml:ValByName('cComprador'	, UsrRetName(SC7->C7_USER))
						oProcess:oHtml:ValByName('cCondPagto'	, '(' + SC7->C7_COND + ') ' + SE4->E4_DESCRI)
						oProcess:oHtml:ValByName('cCodAprov'	, SCR->CR_USER)
						oProcess:oHtml:ValByName('cNumOi'	    ,  SC7->C7_XORDINV)

						//-- DADOS DO SOLICITANTE
						If !Empty(SC7->C7_NUMSC)
							SC1->(DbSetOrder(1))
							If SC1->(DbSeek(xFilial('SC1')+SC7->C7_NUMSC))
								oProcess:oHtml:ValByName('cSolicitante'	, UsrRetName(SC1->C1_USER))
								If PswSeek(SC1->C1_USER) .And. !Empty(PswRet()[1,14])
									oProcess:oHtml:ValByName('cEmailSolic'	, AllTrim(PswRet()[1,14]))
								EndIf
								oProcess:oHtml:ValByName('dDtSolic'	, DtoC(SC1->C1_EMISSAO))
								oProcess:oHtml:ValByName('cObs'	, Posicione( 'SC8', 1, xFilial('SC8')+SC7->C7_NUMCOT+SC7->C7_FORNECE+SC7->C7_LOJA,'C8_OBSFOR'))
							Else
								oProcess:oHtml:ValByName('cSolicitante'	, '-')
								oProcess:oHtml:ValByName('cEmailSolic'	, '-')
								oProcess:oHtml:ValByName('dDtSolic'	, '-')
								oProcess:oHtml:ValByName('cObs'	, '-')
							EndIf
						Else
							oProcess:oHtml:ValByName('cSolicitante'	, SC7->C7_USER)
							If PswSeek(SC7->C7_USER) .And. !Empty(PswRet()[1,14])
								oProcess:oHtml:ValByName('cEmailSolic'	, AllTrim(PswRet()[1,14]))
							EndIf
							oProcess:oHtml:ValByName('dDtSolic'	, Dtoc(SC7->C7_EMISSAO))
							oProcess:oHtml:ValByName('cObs'	, '-')
						EndIf

						//-- ITENS DO FORMULARIO
						nValLiq		:= 0
						nValIPI		:= 0
						nValPed		:= 0
						nValDesc	:= 0
						nValTot		:= 0
						lObsItem	:= .F.
						While !SC7->(Eof()) .And.;
								SC7->(C7_FILIAL+C7_NUM) == xFilial('SC7')+cNumPC

							SC1->(DbSetOrder(1))
							SC1->(DbSeek(xFilial('SC1')+SC7->C7_NUMSC+SC7->C7_ITEMSC))

							ZZ9->(dbSetOrder(1))
							
							If ZZ9->(dbSeek( FWxFilial("ZZ9") + SC7->C7_NUMCOT ))
								Reclock("SC7",.F.)
								C7_OBSM := Alltrim(ZZ9->ZZ9_CODOBS)
								SC7->(MsUnLock())
							Endif

							// ARRAY AUXILIAR PARA NAO EXIBIR PRODUTOS CONCORRENTES QUE NAO ESTAO NESSE PEDIDO
							aAdd( aProds , SC7->C7_PRODUTO )

							AAdd(oProcess:oHtml:ValByName('PED.cItem')		, SC7->C7_ITEM)
							AAdd(oProcess:oHtml:ValByName('PED.cCodPro')	, SC7->C7_PRODUTO)
							AAdd(oProcess:oHtml:ValByName('PED.cDesPro')	, SC7->C7_DESCRI)
							//AAdd(oProcess:oHtml:ValByName('PED.cDesObs')	, IIf(!Empty(NoAcento(AllTrim(SC1->C1_XOBSPRO))),NoAcento(AllTrim(SC1->C1_XOBSPRO)),NoAcento(AllTrim(SC7->C7_OBS))))
							AAdd(oProcess:oHtml:ValByName('PED.cCC')		, SC7->C7_CC)
							//AAdd(oProcess:oHtml:ValByName('PED.cDesCC')		, AllTrim(Posicione('CTT',1,FwXFilial('CTT')+SC7->C7_CC,'CTT_DESC01')))
							AAdd(oProcess:oHtml:ValByName('PED.nQtde')		, Transform(SC7->C7_QUANT, PesqPict('SC7', 'C7_TOTAL')))
							AAdd(oProcess:oHtml:ValByName('PED.nValUnit')	, cSimbMoed + Transform(SC7->C7_PRECO, PesqPict('SC7', 'C7_TOTAL')))
							AAdd(oProcess:oHtml:ValByName('PED.nValItem')	, cSimbMoed + Transform(SC7->C7_TOTAL, PesqPict('SC7', 'C7_TOTAL')))
							//AAdd(oProcess:oHtml:ValByName('PED.nValDesc')	, cSimbMoed + Transform(SC7->C7_VLDESC, PesqPict('SC7', 'C7_TOTAL')))
							AAdd(oProcess:oHtml:ValByName('PED.nValTot')	, cSimbMoed + Transform(SC7->C7_TOTAL - SC7->C7_VLDESC, PesqPict('SC7', 'C7_TOTAL')))
							AAdd(oProcess:oHtml:ValByName('PED.dDtEntr')	, SC7->C7_DATPRF)
							AAdd(oProcess:oHtml:ValByName('PED.dDtSolic')	, SC1->C1_DATPRF)
/*						AIB->(DbSetOrder(2))
							If AIB->(DbSeek(xFilial('AIB')+SC7->(C7_FORNECE+C7_LOJA+C7_CODTAB+C7_PRODUTO)))
							AAdd(oProcess:oHtml:ValByName('PED.nPrcTab')	, Transform(AIB->AIB_PRCCOM, PesqPict('AIB', 'AIB_PRCCOM')))
							Else
							AAdd(oProcess:oHtml:ValByName('PED.nPrcTab')	, Transform(0, PesqPict('AIB', 'AIB_PRCCOM')))
							EndIf
*/						
							//observacoes dos itens:

							If Empty( cObsAux )
								
								cObsAux := SC7->C7_OBSM
								oProcess:oHtml:ValByName('OBSCOMPRADOR'	,  cObsAux)

								lObsItem := .T.
							EndIf

							//--Totais
							nValLiq += SC7->C7_TOTAL
							nValIPI += SC7->C7_VALIPI
							nValPed += SC7->(C7_TOTAL + C7_VALIPI)
							nValDesc += SC7->C7_VLDESC
							nValTot += SC7->(C7_TOTAL + C7_VALIPI - C7_VLDESC)

							//-----------------------------------------------------
							// COMO O PEDIDO REPETE O FRETE, SOMA APENAS UMA VEZ
							//-----------------------------------------------------
							If nValFrete == 0
								nValFrete :=  SC7->C7_FRETE
							Endif

							SC7->(DbSkip())
						End

						nValTot += nValFrete

						// Preenche os campos de observações do item para evitar que apareça o código "%%OBS.cItem" no e-mail enviado
						If !lObsItem
						//	AAdd(oProcess:oHtml:ValByName('OBS.cItem')	 , "" )
						//	AAdd(oProcess:oHtml:ValByName('OBS.cObsItem'), "" )
							oProcess:oHtml:ValByName('OBSCOMPRADOR'	,  "")
						EndIf

						//-- TOTAIS
						oProcess:oHtml:ValByName('nValLiq', Transform(nValLiq, PesqPict('SC7', 'C7_TOTAL')))
						oProcess:oHtml:ValByName('nValIPI', Transform(nValIPI, PesqPict('SC7', 'C7_TOTAL')))
						oProcess:oHtml:ValByName('nValPed', Transform(nValPed, PesqPict('SC7', 'C7_TOTAL')))
						oProcess:oHtml:ValByName('nValDesc', Transform(nValDesc, PesqPict('SC7', 'C7_TOTAL')))
						oProcess:oHtml:ValByName('nValFrete', Transform(nValFrete, PesqPict('SC7', 'C7_TOTAL')))
						oProcess:oHtml:ValByName('nValTot', Transform(nValTot, PesqPict('SC7', 'C7_TOTAL')))

						//-- Outros fornecedores

						If Len(aFornece) < 1
							AAdd(oProcess:oHtml:ValByName('FOR.cNome')		, "")
							AAdd(oProcess:oHtml:ValByName('FOR.cProduto')		, "")
							AAdd(oProcess:oHtml:ValByName('FOR.nValor')		, "")
							AAdd(oProcess:oHtml:ValByName('FOR.cCondPg')	, "")
							AAdd(oProcess:oHtml:ValByName('FOR.cDtEntr')	, "")
							AAdd(oProcess:oHtml:ValByName('FOR.cObs')		, "")
						Else

							For nX := 1 to Len( aFornece )

								// ADICIONA APENAS PRODUTOS QUE FORAM APROVADOS PARA AQUELE PEDIDO
								If Ascan(aProds, aFornece[nX][6]) > 0

									AAdd(oProcess:oHtml:ValByName('FOR.cNome')		, aFornece[nX][1])
									AAdd(oProcess:oHtml:ValByName('FOR.cProduto')		, aFornece[nX][7])
									AAdd(oProcess:oHtml:ValByName('FOR.nValor')		, cSimbMoed + Transform(aFornece[nX][5], PesqPict('SC8', 'C8_TOTAL')))
									AAdd(oProcess:oHtml:ValByName('FOR.cCondPg')	, Posicione('SE4',1,xFilial('SE4')+aFornece[nX][2],'E4_DESCRI'))
									AAdd(oProcess:oHtml:ValByName('FOR.cDtEntr')	, AllTrim(Str(aFornece[nX][3],5,0)))
									AAdd(oProcess:oHtml:ValByName('FOR.cObs')		, AllTrim(aFornece[nX][4]))

								Endif

							Next nX
						EndIf

						//Exibindo alçadas de aprovacoes
						SCR->(DbSetOrder(1))
						If SCR->(dbSeek( FwXFilial("SCR") +  Padr("PC",TamSx3("CR_TIPO")[1]) + cNumPC ))
							While !SCR->(EOF()) .And. FWxFilial("SCR") + Padr("PC",TamSx3("CR_TIPO")[1]) + Padr(cNumPC,TamSx3("CR_NUM")[1]) == SCR->CR_FILIAL + SCR->CR_TIPO + SCR->CR_NUM

								AAdd(oProcess:oHtml:ValByName('APROV.cNivel')		, SCR->CR_NIVEL )
								AAdd(oProcess:oHtml:ValByName('APROV.cUsuario')		, UsrFullName(SCR->CR_USER) )
								AAdd(oProcess:oHtml:ValByName('APROV.cSituacao')		, RetSitSCR(SCR->CR_STATUS,cGrupoAprov,SCR->CR_LIBAPRO))
								AAdd(oProcess:oHtml:ValByName('APROV.cAprovado')	,  IIf(Empty(SCR->CR_USERLIB),"",UsrRetName(SCR->CR_USERLIB)))
								AAdd(oProcess:oHtml:ValByName('APROV.cDtAprov')	, Dtoc(SCR->CR_DATALIB))

								SCR->(dbSkip())

							EndDo

						Else

							AAdd(oProcess:oHtml:ValByName('APROV.cNivel')		, "")
							AAdd(oProcess:oHtml:ValByName('APROV.cUsuario')		, "")
							AAdd(oProcess:oHtml:ValByName('APROV.cSituacao')		, "")
							AAdd(oProcess:oHtml:ValByName('APROV.cAprovado')	, "")
							AAdd(oProcess:oHtml:ValByName('APROV.cDtAprov')	, "")

						Endif
						//-- OBSREVACOES DO APROVADOR
//					cObsApr := Alltrim( SubStr( SC7->C7_OBSM, 1, Len( SC7->C7_OBSM ) - RAT(SC7->C7_OBSM, '</p>') - 1) )
//					cObsApr := SubStr( cObsApr, RAT(cObsApr, '>') + 1, Len( Alltrim( cObsApr ) ) - RAT(cObsApr, '>') + 1)
//					oProcess:oHtml:ValByName('cObsApr', cObsApr)

						// ---------------------------------------------------------
						// Realiza a gravacao do processo de workflow.
						// Este processo sera gravado no servidor para
						// que seja acessado posteriormente via link
						// enviado no e-mail de notificacao do processo
						// ---------------------------------------------------------
						cPastaHTM    := 'PROCESSOS'
						oProcess:cTo := cPastaHTM

						// ---------------------------------------------------------
						// Tratamento da rastreabilidade do workflow
						// 1o. passo: Envio do e-mail:
						// ---------------------------------------------------------
						RastreiaWF(oProcess:fProcessID + '.' + oProcess:fTaskID, oProcess:fProcCode, '30001')

						// ---------------------------------------------------------
						// Reposiciona o SC7 para gravacao do processo de
						// workflow no pedido de compras:
						// ---------------------------------------------------------
						SC7->(DbSeek(xFilial('SC7')+cNumPC))
						While !SC7->(Eof()) .And.;
								SC7->(C7_FILIAL+C7_NUM) == xFilial('SC7')+cNumPC

							RecLock('SC7', .F.)
							SC7->C7_WFID := oProcess:fProcessID
							SC7->(MsUnLock())

							SC7->(DbSkip())
						End

						// ---------------------------------------------------------
						// Inicia o processo de workflow e
						// guarda o Id do processo para montagem
						// do e-mail de link:
						// ---------------------------------------------------------
						cMailId := oProcess:Start()

						// ---------------------------------------------------------
						// Nova tarefa para envio do e-mail com
						// o link do processo:
						// ---------------------------------------------------------
						oProcess:NewTask('WFA011', cArqLink) //cArqLink
						oProcess:oHtml:ValByName('cTitle', 'Aprovacao de Pedido de Compras No. ' + cNumPC)
						oProcess:oHtml:ValByName('cBody', cBody )
						oProcess:oHtml:ValByName('cNumPed'		, cNumPC)
						// ---------------------------------------------------------
						// Atualiza os dados no HTML referente
						// a mensagem com o link:
						// ---------------------------------------------------------
						cUrl     := 'http://' + cHttpSrv + If(Right(cHttpSrv, 1) <> '/', '/', '') + 'messenger/emp' + cEmpAnt + '/' + cPastaHTM + '/' + cMailId + '.htm'
						cUrlImg  := 'http://' + cHttpSrv + If(Right(cHttpSrv, 1) <> '/', '/', '') + 'messenger/emp' + cEmpAnt + '/' + cPastaHTM + '/' + cLogoD
						cUrlImg2  := 'http://' + cHttpSrv + If(Right(cHttpSrv, 1) <> '/', '/', '') + 'messenger/emp' + cEmpAnt + '/' + cPastaHTM + '/' + "bolinhas.png"

						oProcess:oHtml:ValByName('cLink', cUrl)
						oProcess:oHtml:ValByName('cUrlImg', cUrlImg)
						oProcess:oHtml:ValByName('cUrlImg2', cUrlImg2)


						// ---------------------------------------------------------
						// Determina o destinatario do e-mail de
						// aprovacao:
						// ---------------------------------------------------------
						//oProcess:cTo := "bruno.pinto@totvs.com.br"
						oProcess:cTo := cMailApr

						// ---------------------------------------------------------
						// Titulo para o email:
						// ---------------------------------------------------------
						oProcess:cSubject := 'Aprovacao de Pedido de Compra No. ' + cNumPC

						//----------------------------------------
						// Verifica se existem arquivos no banco de conhecimento vinculados ao PC e
						// ADICIONA como ANEXOS:
						//----------------------------------------
						If lBcoAnex
							aAttach := ArqBco(cNumPc)

							//adiciona os anexos no e-mail:
							For nX := 1 To Len(aAttach)
								If File( cRootPath + aAttach[nX] )
									oProcess:AttachFile(aAttach[nX])
								Endif
							Next
						Endif

						// ---------------------------------------------------------
						// Envia o e-mail com link para aprovacao
						// ---------------------------------------------------------
						oProcess:Start()


						// ---------------------------------------------------------
						// Libera Objeto
						// ---------------------------------------------------------
						oProcess :Free()
						oProcess := NIL
					EndIf

				Next nCount
			Endif
		EndIf

		If !IsBlind()
			//MsgInfo('Pedido ' + cNumPC + ' Gerado.')
		Endif


	Endif

	RestArea(aArea)
	RestArea(aAreaSA2)
	RestArea(aAreaSB1)
	RestArea(aAreaSC7)
Return



/*/{Protheus.doc} ArqBco
Procura arquivos no banco de conhecimento vinculados ao PC para enviar anexo no e-mail
@author Giane
@since 18/05/2015
@version 1.0
@param cNumPc, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ArqBco(cNumPc)
	Local aArea := GetArea()
	Local aRet := {}
	Local cAliasB := GetNextAlias()
	Local cRootPath := GetPvProfString(GetEnvServer(), 'RootPath', 'ERROR', GetADV97())
	Local cDirDoc := alltrim( SuperGetMV('MV_DIRDOC',,'') )
	Local cCarac := ''
	Local nSize := len(cFilAnt) + 1

	BeginSql Alias cAliasB
	SELECT ACB.ACB_OBJETO       
	FROM %table:AC9% AC9	 
	 JOIN %table:ACB% ACB ON
	    ACB.ACB_FILIAL = %xFilial:ACB% 
	    AND ACB.ACB_CODOBJ = AC9.AC9_CODOBJ
	    AND ACB.%NotDel%  	
	WHERE
	    AC9.AC9_FILIAL = %xFilial:AC9%
	    AND AC9.AC9_ENTIDA = 'SC7' AND AC9.AC9_FILENT = %xFilial:SC7%
	    AND SUBSTRING(AC9.AC9_CODENT,%Exp:nSize%,6) = %Exp:cNumPc%     
	    AND AC9.%NotDel% 		
	EndSql

	cCarac := Right(cDirDoc,1)

	If nRemType == 2 // REMOTE_LINUX
		cDirDoc += IIf(cCarac == '/', '', '/') + 'co' + FWCodEmp() + '/shared/'
	Else
		cDirDoc += IIf(cCarac == '\', '', '\') + 'co' + FWCodEmp() + '\shared\'
	Endif

	(cAliasB)->( DbEval({|x| AAdd(aRet, cDirDoc + alltrim((cAliasB)->ACB_OBJETO) ) }) )

	(cAliasB)->(DbCloseArea())
	RestArea(aArea)
Return aRet

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³FUNCAO    ³TIBW030RET    ³Autor  ³V. RASPA                             ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³DESCRICAO ³Funcao responsavel pelo tratamento do retorno do processo de³±±
	±±³          ³workflow - Aprovacao de Pedidos de Compra                   ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function TIBW030Ret(oProcess)
	Local cNumPC     := ''
	Local cNumSCR    := ''
	Local cCodAprov  := ''
	Local lAprovado  := .F.
	Local lContinua  := .T.
	Local aRetSaldo  := {}
	Local nTotal     := 0
	Local lLiberou   := .F.
	Local cTitle     := ''
	Local cMsg       := ''
	Local cMailCompr := ''
	Local lSendMsg   := .F.

	Local aArea      := GetArea()
	Local aAreaSC7   := {}
	Local aAreaSCR   := SCR->(GetArea())
	Local cCopyRet := SuperGetMV('ES_COPYRET',, '')
	Local cUrlImg2 := ""

	// -----------------------------------------------
	// Obtem os dados do formulario HTML para
	// tratamento do retorno:
	// -----------------------------------------------
	cNumPC     := oProcess:oHtml:RetByName('cNumPed')
	cNumSCR    := PadR(oProcess:oHtml:RetByName('cNumPed'),Len(SCR->CR_NUM))
	cObserv    := oProcess:oHtml:RetByName('cObsApr')
	cCodAprov  := oProcess:oHtml:RetByName('cCodAprov')
	lAprovado  := oProcess:oHtml:RetByName('Aprovacao') == 'S'

	conout(cObserv)

// -----------------------------------------------
// Posiciona no Documento de Alcada
// -----------------------------------------------
	SCR->(DbSetOrder(2)) //-- CR_FILIAL+CR_TIPO+CR_NUM+CR_USER
	If SCR->(DbSeek(xFilial('SCR') + 'PC' + cNumSCR + cCodAprov)) .Or. SCR->(DbSeek(xFilial('SCR') + 'IP' + cNumSCR + cCodAprov))

		// -----------------------------------------------
		// Posiciona nas tabelas auxiliares
		// -----------------------------------------------
		SAK->( DbSetOrder(1) )
		SAK->( DbSeek(xFilial("SAK")+cCodAprov))

		SC7->( DbSetOrder(1) )
		If SC7->( DbSeek(xFilial("SC7")+cNumPC))
			cObsApr := SC7->C7_OBSAPR
			cObsApr += Chr(10)+Chr(13)
			cObsApr += '[OBSERVACOES REALIZADAS PELO APROVADOR: ' + UsrRetName(SCR->CR_USER) + ']' + Chr(10)+Chr(13)
			cObsApr += cObserv

			aAreaSC7 := SC7->(GetArea())
			While !SC7->(Eof()) .And.;
					SC7->(C7_FILIAL+C7_NUM) == xFilial("SC7")+cNumPC

				RecLock('SC7', .F.)
				SC7->C7_OBSAPR := cObsApr
				SC7->(MsUnLock())
				SC7->(DbSkip())

			End
			RestArea(aAreaSC7)
		EndIf

		SAL->( DbSetOrder(3) )
		SAL->( DbSeek(xFilial("SAL")+SC7->C7_APROV+SAK->AK_COD) )

		// -----------------------------------------------
		// Avalia o Status do Documento a ser liberado
		// -----------------------------------------------
		If lContinua .And. !Empty(SCR->CR_DATALIB) .And. SCR->CR_STATUS $ '03|05'
			Conout('[PEDIDO: ' + cNumPC + ']Este pedido ja foi liberado anteriormente. Somente os pedidos que estao aguardando liberacao poderao ser liberados.')
			lContinua := .F.

		ElseIf lContinua .And. SCR->CR_STATUS $ '01'
			Conout('[PEDIDO: ' + cNumPC + ']Esta operação não poderá ser realizada pois este registro se encontra bloqueado pelo sistema (aguardando outros niveis)')
			lContinua := .F.

		EndIf

		If lContinua
			// ---------------------------------------------------------
			// Inicializa a gravacao dos lancamentos do SIGAPCO
			// ---------------------------------------------------------
			PcoIniLan("000055")

			// ---------------------------------------------------------
			// Avalia liberacao do DOcumento pelo PCO
			// ---------------------------------------------------------
			If !ValidPcoLan()
				Conout('[PEDIDO ' + cNumPC + ']Bloqueio de Liberacao pelo PCO.')
				lContinua := .F.
			EndIf

			// ---------------------------------------------------------
			// Analisa o Saldo do Aprovador
			// ---------------------------------------------------------
			If lContinua .And. SAL->AL_LIBAPR == 'A'
				aRetSaldo  := MaSalAlc(cCodAprov,dDataBase)
				nTotal     := xMoeda(SCR->CR_TOTAL,SCR->CR_MOEDA,aRetSaldo[2],SCR->CR_EMISSAO,,SCR->CR_TXMOEDA)
				If (aRetSaldo[1] - nTotal) < 0
					Conout('[PEDIDO ' + cNumPC + ']Saldo na data insuficiente para efetuar a liberacao do pedido. Verifique o saldo disponivel para aprovacao na data e o valor total do pedido.')
					lContinua := .F.
				EndIf
			EndIf

			If lContinua
				Begin Transaction
					// ---------------------------------------------------------
					// Executa a liberacao ou rejeicao
					// do Pedido de Compra.
					// --------------------------------------------------------
					lLiberou := MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,SCR->CR_APROV,,SC7->C7_APROV,,,,,cObserv},dDataBase,If(lAprovado,4,6))

					If Empty(SCR->CR_DATALIB) //-- Verifica se Aprovou se liberou o Documento
						Conout('[PEDIDO ' + cNumPC + ']Nao foi possivel realizar a liberacao do Documento via WorkFlow. Tente realizar a liberacao manual.')
						lContinua := .F.
					EndIf

					If lContinua
						If lLiberou //-- Verifica se todos os niveis ja foram aprovados
							// ---------------------------------------------------------
							// Grava os lancamentos nas contas orcamentarias SIGAPCO
							// ---------------------------------------------------------
							PcoDetLan("000055","02","MATA097")

							While SC7->(!Eof()) .And.;
									SC7->C7_FILIAL+SC7->C7_NUM == xFilial("SC7")+PadR(SCR->CR_NUM,Len(SC7->C7_NUM))

								Reclock("SC7",.F.)
								SC7->C7_CONAPRO := "L" //-- Atualiza o status (Liberado) no Pedido de Compra
								SC7->(MsUnlock())

								// ---------------------------------------------------------
								// Grava os lancamentos nas contas orcamentarias SIGAPCO
								// ---------------------------------------------------------
								PcoDetLan("000055","01","MATA097")
								SC7->( dbSkip() )
							End

							SC7->(DbSetOrder(1))
							SC7->(DbSeek(xFilial("SC7")+cNumPC))

							// ---------------------------------------------------------
							// Tratamento da rastreabilidade do workflow
							// 2o. passo: Processamento do retorno do workflow
							// ---------------------------------------------------------
							RastreiaWF(oProcess:fProcessID + '.' + oProcess:fTaskID, oProcess:fProcCode, '30002')

							// ---------------------------------------------------------
							// Envia e-mail ao comprador notificando a liberacao
							// do pedido de compra
							// ---------------------------------------------------------

							//-- Obtem o e-mail do Comprador:
							lSendMsg := .T.
							cTitle   := 'Aprovacao de Pedido de Compra - Aprovado'
							//cMsg     := 'O Pedido de compra No. ' + cNumPC + ' foi aprovado com sucesso!'
							cMsg     := 'Caro Comprador, <br>
							cMsg 	 +=  '<p>O pedido de compra n&#176;'+ cNumPC + ' foi aprovado com sucesso!


							PswOrder(1)
							If PswSeek(SC7->C7_USER) .And. !Empty(PswRet()[1,14])
								cMailCompr := AllTrim(PswRet()[1,14])
							Endif



						Else
							If SCR->CR_STATUS == '04'	//-- Se Rejeitado
								Conout('[PEDIDO ' + cNumPC + ']O pedido em questao foi rejeitado!')

								// ---------------------------------------------------------
								// Envia e-mail ao comprador notificando a liberacao
								// do pedido de compra
								// ---------------------------------------------------------
								lSendMsg := .T.



								cTitle   := 'Aprovacao de Pedido de Compra - Reprovado'
								cMsg     := '<p>Caro Comprador,<br>'
								cMsg     += '<p>O pedido de compra n&#176;' + cNumPC + ' foi reprovado!'

								//-- Obtem o e-mail do Comprador:
								SC7->(DbSetOrder(1))
								SC7->(DbSeek(xFilial("SC7")+cNumPC))

								While SC7->(!Eof()) .And.;
										SC7->C7_FILIAL+SC7->C7_NUM == xFilial("SC7")+PadR(SCR->CR_NUM,Len(SC7->C7_NUM))

									Reclock("SC7",.F.)
									SC7->C7_CONAPRO := "R" //-- Atualiza o status (Rejeitado) no Pedido de Compra
									SC7->(MsUnlock())

									SC7->( dbSkip() )
								End

								SC7->(DbSetOrder(1))
								SC7->(DbSeek(xFilial("SC7")+cNumPC))

								PswOrder(1)
								If PswSeek(SC7->C7_USER) .And. !Empty(PswRet()[1,14])
									cMailCompr := AllTrim(PswRet()[1,14])
									//cMailCompr := "marcelo.costa@tryio.com.br"
								Endif

							Else
								// ---------------------------------------------------------
								// Envia WorkFlow para aprovacao do proximo Nivel
								// ---------------------------------------------------------
								SC7->( DbSetOrder(1) )
								SC7->( DbSeek(xFilial("SC7")+cNumPC))
								U_TIBW030Send(cNumPC)

								// ---------------------------------------------------------
								// Tratamento da rastreabilidade do workflow
								// 2o. passo: Processamento do retorno do workflow
								// ---------------------------------------------------------
								RastreiaWF(oProcess:fProcessID + '.' + oProcess:fTaskID, oProcess:fProcCode, '30002')

							EndIf
						EndIf
					EndIf
				End Transaction
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza a gravacao dos lancamentos do SIGAPCO            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			PcoFinLan("000055")

			If lSendMsg
				U_TIBW030Msg(cTitle, cMsg, cMailCompr , cCopyRet , cNumPC)
			EndIf

		EndIf
	EndIf

	RestArea(aArea)
	RestArea(aAreaSC7)
	RestArea(aAreaSCR)
Return

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºPrograma  ³ ValidPcoLan                                                º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescri‡„o ³ Valida o lancamento no PCO.                                º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidPcoLan()
	Local lRet	   := .T.
	Local aArea    := GetArea()
	Local aAreaSC7 := SC7->(GetArea())

	DbSelectArea("SC7")
	DbSetOrder(1)
	DbSeek(xFilial("SC7")+Substr(SCR->CR_NUM,1,len(SC7->C7_NUM)))

	If lRet	:=	PcoVldLan('000055','02','MATA097')
		While lRet .And. !Eof() .And. SC7->C7_FILIAL+Substr(SC7->C7_NUM,1,len(SC7->C7_NUM)) == xFilial("SC7")+Substr(SCR->CR_NUM,1,len(SC7->C7_NUM))
			lRet	:=	PcoVldLan("000055","01","MATA097")
			dbSelectArea("SC7")
			dbSkip()
		EndDo
	Endif

	If !lRet
		PcoFreeBlq("000055")
	Endif

	RestArea(aAreaSC7)
	RestArea(aArea)
Return(lRet)


/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºPrograma  ³ TIBW030Msg                                                 º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescri‡„o ³ Envia mensagem de e-mail ao final do processo              º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function TIBW030Msg(cTitle, cMsg, cMail,cCopia,cNumPed)

	Local oPrcMsg := NIL
	Local cArqMsg := ''

	Default cCopia := ""

	If nRemType == 2 // REMOTE_LINUX
		cArqMsg :='/WEB/TEMPLATE/WFMsg.HTML'
	Else
		cArqMsg := '\WEB\TEMPLATE\WFMsg.HTML'
	Endif

// ---------------------------------------------------------
// Envia e-mail ao comprador notificando a liberacao
// do pedido de compra
// ---------------------------------------------------------
	oPrcMsg := TWFProcess():New('APR_PC', 'Criacao do Processo - Aprovacao de Pedidos')
	oPrcMsg:NewTask('WFA012', cArqMsg)

//-- Atualiza variaveis do formulario
	oPrcMsg:oHtml:ValByName('cTitle', cTitle)
	oPrcMsg:oHtml:ValByName('cMsg'	, cMsg)

//-- Determina o destinatario do e-mail                            	
	oPrcMsg:cTo := cMail

	// Envia para copia se tiver cadastrado no parametro ES_COPYRET
	If !Empty(cCopia)
		oPrcMsg:cCC  := cCopia
	Endif

	//-- Assunto do e-mail:
	oPrcMsg:cSubject := cTitle

	//-- Envia e-mail
	oPrcMsg:Start()

	//--Libera o objeto
	oPrcMsg :Free()
	oPrcMsg := NIL

	//EnvMail(cNumPed)

Return

/*/{Protheus.doc} SendWF030
acionar o processo de workflow apos a 
gravacao da liberacao de documentos, quando feito fora da  rotina de workflow    
@author Giane
@since 26/01/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function SendWF030(PARAMIXB)

	Local cWFPCAuto := SuperGetMV('ES_WFPCAUT',, '1')
	Local cNumPC    := PadR(PARAMIXB[1], Len(SC7->C7_NUM))
	Local cTipo     := PARAMIXB[2]
	Local nOpc      := PARAMIXB[3]
	Local cFilDoc   := PARAMIXB[4]
	Local aArea     := GetArea()
	Local aAreaSC7  := SC7->(GetArea())
	Local aAreaSC1  := SC1->(GetArea())
	Local lSendMsg	:= .F.
	Local cTitle	:= ''
	Local cMsg		:= ''
	Local cMailCompr:= ''
	Local cUsrSolc	:= ''
	Local nQtdReg	:= 0
	Local cAlias 	:= GetNextAlias()
	Local cCopyRet := SuperGetMV('ES_COPYRET',, '')
// --------------------------------------------------------------------
// cDocto == Numero do Documento
// cTipo  == Tipo do Documento "PC" | "AE" | "CP"

// Quando o ponto eh acionado pela rotina de Liberação e Superior:
// nOpc == 1 --> Cancela
// nOpc == 2 --> Libera
// nOpc == 3 --> Bloqueia

// Quando o ponto eh acionado pela rotina de Transf. Superior
// nOpc == 1 --> Transfere
// nOpc == 2 --> Cancela
// --------------------------------------------------------------------

	If Type("l_xEnviou") == "U" .OR. ! l_xEnviou
		l_xEnviou := .T.
		If U_LibWFPC()


			If AllTrim(cTipo) == 'PC'
				If ((IsInCallStack('A097LIBERA') .Or. IsInCallStack('A097SUPERI')) .And. nOpc == 2) .Or.;
						(IsInCallStack('A097TRANSF') .And. nOpc == 1)
					SC7->(DbSetOrder(1))
					If SC7->(DbSeek(cFildoc+cNumPC))
						If cWFPCAuto == '1' //--Pergunta antes de enviar
							If Aviso('ATENÇÃO', 'Envia processo de Workflow para este pedido?', {'SIM', 'NÃO'}, 2) == 1
								MsgRun('Montando processo de workflow', 'Aguarde...',{|| U_TIBW030Send(cNumPC)})
							EndIf
						ElseIf cWFPCAuto == '2' //--Envia o processo sem perguntar
							MsgRun('Montando processo de workflow', 'Aguarde...',{|| U_TIBW030Send(cNumPC)})
						EndIf

						SC1->(DbSetOrder(1))//C1_FILIAL+C1_NUM+C1_ITEM
						If SC1->(DbSeek(xFilial('SC1')+SC7->C7_NUMSC))
							cUsrSolc := SC1->C1_USER
						EndIf

						// Verifica se todos os niveis foram liberados
						BeginSQL Alias cAlias
					SELECT COUNT(*) as nQtdReg
					FROM %Table:SCR% SCR
					WHERE SCR.CR_FILIAL = %XFilial:SCR%
					AND CR_NUM = %Exp:cNumPC%
					AND SCR.CR_STATUS<>'4'
					AND SCR.CR_DATALIB=''
					AND SCR.%NotDel%
						EndSql

						If (cAlias)->nQtdReg == 0

							SC7->(DbSetOrder(1))
							SC7->(DbSeek(xFilial("SC7")+cNumPC))

							// ---------------------------------------------------------
							// Envia e-mail ao comprador notificando a liberacao
							// do pedido de compra
							// ---------------------------------------------------------

							//-- Obtem o e-mail do Comprador:
							lSendMsg := .T.
							cTitle   := 'Aprovacao de Pedido de Compra - Aprovado'
							cMsg     := 'O Pedido de compra No. ' + cNumPC + ' foi aprovado com sucesso!'

							PswOrder(1)
							If PswSeek(SC7->C7_USER) .And. !Empty(PswRet()[1,14])
								  cMailCompr := AllTrim(PswRet()[1,14])
								  //cMailCompr := "marcelo.costa@tryio.com.br"
							Endif

							If !Empty(cUsrSolc)
								PswOrder(1)
								If PswSeek(cUsrSolc) .And. !Empty(PswRet()[1,14])
									cMailCompr += ";"+AllTrim(PswRet()[1,14])
									//cMailCompr := "marcelo.costa@tryio.com.br"
								Endif
							EndIf

						EndIf
					EndIf
				ElseIf ((IsInCallStack('A097LIBERA') .Or. IsInCallStack('A097SUPERI')) .And. nOpc == 3) .Or.;
						(IsInCallStack('A097TRANSF') .And. nOpc == 2)

					SC7->(DbSetOrder(1))
					If SC7->(DbSeek(cFildoc+cNumPC))

						SC1->(DbSetOrder(1))//C1_FILIAL+C1_NUM+C1_ITEM
						If SC1->(DbSeek(xFilial('SC1')+SC7->C7_NUMSC))
							cUsrSolc := SC1->C1_USER
						EndIf

						If SCR->CR_STATUS=='04'

							// ---------------------------------------------------------
							// Envia e-mail ao comprador notificando a liberacao
							// do pedido de compra
							// ---------------------------------------------------------
							lSendMsg := .T.
							cTitle   := 'Aprovacao de Pedido de Compra - Reprovado'
							cMsg     := 'O Pedido de compra No. ' + cNumPC + ' foi Reprovado.'

							//-- Obtem o e-mail do Comprador:
							PswOrder(1)
							If PswSeek(SC7->C7_USER) .And. !Empty(PswRet()[1,14])
								cMailCompr := AllTrim(PswRet()[1,14])
							Endif

							If !Empty(cUsrSolc)
								PswOrder(1)
								If PswSeek(cUsrSolc) .And. !Empty(PswRet()[1,14])
									cMailCompr += ";"+AllTrim(PswRet()[1,14])
								Endif
							EndIf

						EndIf
					EndIf
				EndIf

				//----------------------------------//
				// Envia E-mail de Status do Pedido //
				//----------------------------------//
				If lSendMsg
					U_TIBW030Msg(cTitle, cMsg, cMailCompr,cCopyRet,cNumPC)
				EndIf
			EndIf

		Endif

	Endif
//-- Restaura ambiente:
	RestArea(aArea)
	RestArea(aAreaSC7)
	RestArea(aAreaSC1)

Return

/*/{Protheus.doc} IniWF030
acionar o processo de workflow apos a gravacao do pedido de compras 
@author Giane
@since 26/01/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function IniWF030(PARAMIXB)
	Local cWFPCAuto := SuperGetMV('ES_WFPCAUT',, '1')
	Local cNumPC    := PARAMIXB[1]
	Local lInclui   := PARAMIXB[2]
	Local lAltera   := PARAMIXB[3]
	Local lExclui   := PARAMIXB[4]
	Local lContinua :=  ! FwIsInCallStack("CNTA120") .AND. ! FwIsInCallStack("CNTA121") //Rotina nao habilitada para pedidos gerados por contratos

	If lContinua

		If IsInCallStack("EICPO400")
			//se pedido veio do EIC(PO) entao envia automaticamente o workflow, sem perguntar
			cWFPCAuto := '2'
		Endif

		If (lInclui .Or. lAltera) .And. !lExclui
			If cWFPCAuto == '1' .and. !IsInCallStack("EICPO400") //--Pergunta antes de enviar, mas se é execauto do EIC nao pergunta pq da erro
				If Aviso('ATENÇÃO', 'Envia processo de Workflow para este pedido?', {'SIM', 'NÃO'}, 2) == 1

					MsgRun('Montando processo de workflow', 'Aguarde...',;
						{|| U_TIBW030Send(cNumPC)})

				EndIf

			ElseIf cWFPCAuto == '2' //--Envia o processo sem perguntar

				MsgRun('Montando processo de workflow', 'Aguarde...',;
					{|| U_TIBW030Send(cNumPC)})

			EndIf
		EndIf

	Endif

Return

/*/{Protheus.doc} SendWF160
realizacao do envio do workflow para a aprovacao. 
@author Giane
@since 26/01/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function SendWF160()

	Local aArea		:= GetArea()
	Local aAreaSC7	:= SC7->(GetArea())
	Local cWFPCAuto	:= SuperGetMV('ES_WFPCAUT',, '1')
	Local cCotacao	:= PARAMIXB[1]
	Local cAliasQry	:= GetNextAlias()
	Local lContinua	:= .F.

// Verifica se a cotação gerou mais de um pedido de compra
	BeginSQl Alias cAliasQry
	SELECT 	DISTINCT SC7.C7_NUM C7_NUM
	FROM 	%Table:SC7% SC7
	WHERE 	SC7.C7_FILIAL =  %xFilial:SC7% AND
			SC7.C7_NUMCOT =  %Exp:cCotacao% AND
			SC7.%NotDel%
	EndSQL

	If cWFPCAuto == '1' //--Pergunta antes de enviar
		If Aviso('ATENÇÃO', 'Envia processo de Workflow para o pedido de compra gerado pela analise da cotação?', {'SIM', 'NÃO'}, 2) == 1
			lContinua := .T.
		EndIf
	ElseIf cWFPCAuto == '2' //--Envia o processo sem perguntar
		lContinua := .T.
	EndIf

// Se envia o workflow, envia para todos os pedidos de compra gerados pela cotação
	If lContinua
		(cAliasQry)->(DbGoTop())

		While !(cAliasQry)->(EOF())
			MsgRun('Montando processo de workflow', 'Aguarde...',;
				{|| U_TIBW030Send((cAliasQry)->C7_NUM)})

			(cAliasQry)->(DbSkip())
		End
	EndIf

	(cAliasQry)->(DbCloseArea())

	RestArea(aAreaSC7)
	RestArea(aArea)

Return

// Envia e-mail para o fornecedor aprovado - Aron - 11/10/2019
User Function EnvMail(cNumPed)

	Local cRelPed := u_TIBR010(cNumPed)
	Local cTexto    := MemoRead( "\workflow\messenger\images\Aprovado.html" )
	Local cHTTPSrv  := 'http://' + AllTrim(SuperGetMV('ES_HTTPSRV',, 'localhost:6067/')) + 'messenger\images'
	Local cLogoD    := ''
	Local cMailForn := ''
	Local oProcess := ''
	Local cCopia := SuperGetMV('ES_COPYRET',, '')
	Local codobj := ' '

	SC7->(DbSetOrder(1))
	SC7->(dbSeek( FwXFilial("SC7") + cNumPed ))

	cLogoD	:= "lgmid" + cEmpAnt + ".png"
	If !File('\workflow\messenger\images\' + cLogoD)
		cLogoD := "logo.png"
	EndIf

	cHTTPSrv := StrTran( cHTTPSrv, '\', '/' )

	cMailForn := Posicione('SA2',1,xFilial('SA2')+SC7->C7_FORNECE+SC7->C7_LOJA, 'A2_EMAIL')

	oProcess := TWFProcess():New('ENV_PO', 'Envio de Pedido de Compras')
	oProcess:NewTask('Pedido de Compra', "\workflow\messenger\images\Aprovado.html" )
	oProcess:cSubject := "Pedido de Compra VOGUEL - " + SC7->C7_NUM
	oProcess:USerSiga := "000000"

	oProcess:oHtml:ValByName('cLogo'		, cLogoD)
	oProcess:oHtml:ValByName('cImagem'		, cHTTPSrv)
	oProcess:oHtml:ValByName('nPedido'		, SC7->C7_NUM)

	// Enviando Relatoiro de Anexo
	If !Empty(cRelPed)
		oProcess:AttachFile(cRelPed)

		// função para gravar base de conhecimento


		DbSelectArea("ACB")

		RecLock("ACB", .T.)
		codobj := GetSxeNum("ACB","ACB_CODOBJ")
		ACB->ACB_CODOBJ := codobj
		ACB->ACB_OBJETO := ALLTRIM(Substr(cRelPed,RAT("\",cRelPed)+1))
		ACB->ACB_DESCRI := ALLTRIM(Substr(cRelPed,RAT("\",cRelPed)+1))


		MsUnLock()

		DbSelectArea("AC9")

		RecLock("AC9", .T.)


		AC9->AC9_FILENT := cFilAnt
		AC9->AC9_ENTIDA := "SC7"
		AC9->AC9_CODENT := cfilAnt + cNumPed + "0001"
		AC9->AC9_CODOBJ := codobj


		MsUnLock()

		ConfirmSX8()
	Endif

	oProcess:cTo := cMailForn

	If !Empty(cCopia)
		oProcess:cCC  := cCopia
	Endif


	oProcess:Start()
	oProcess :Free()
	oProcess := NIL

Return


//Retorna situacao da  aprovacao na alcada Alcada
Static Function RetSitSCR(cSituacao,cGpAprov,cAprovador)

	Local aArea := GetArea()
	Local cRet := ""

	SAL->(DbSetOrder(1))
	SAL->( DbSeek(xFilial('SAL') + cGpAprov + cAprovador ) )

	Do Case
	Case cSituacao == "01"
		cRet := 'Aguardando'
	Case cSituacao == "02"
		cRet := 'Em Aprovacao'
	Case cSituacao == "03"
		If SAL->AL_LIBAPR == 'V'
			cRet := 'Vistado'
		Else
			cRet := 'Aprovado'
		EndIf
	Case cSituacao == "04"
		cRet := 'Bloqueado'
	Case cSituacao == "05"
		cRet := 'Nivel Liberado'
	EndCase

	RestArea(aArea)

Return cRet
