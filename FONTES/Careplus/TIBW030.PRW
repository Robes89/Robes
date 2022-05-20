#INCLUDE "RPTDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWPRINTSETUP.CH"

STATIC nRemType := GetRemoteType()

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���FUNCAO    �TIBW030    �Autor  �V. RASPA                                ���
�������������������������������������������������������������������������Ĵ��
���DESCRICAO �Funcao responsavel pelo montagem e envio do processo de     ���
���          �workflow - Aprovacao de Pedidos de Compra                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
		Help('', 1, 'TIBW030',, 'N�o foi encontrado o arquivo de template para envio do processo de workflow!', 1, 0)	
	EndIf

Endif

Return

/*/{Protheus.doc} LibWFPC
Libera ou nao o uso do workflow para uso do cliente
Reservado para templatiza��o da rotina

@author 	Giane
@since 		05/01/2016
@version 	1.0

/*/

User Function LibWFPC()

Local lRet 		 := .T.
Local aHardLock  := {}  //Lista de hardlocks liberados para uso
Local aCNPJLib   := {}  //Lista de cnpjs liberados para uso

// Valida autoriza��o de execu��o
/*
If aScan(aHardLock, LS_GetID()) <= 0  //Verifica o hardlock
	If aScan(aCNPJLib, SubStr(SM0->M0_CGC,1,8)) <= 0  //Verifica o cnpj
		lRet := .F.
		Help('', 1, 'HELP',, 'Processo de Workflow n�o est� liberado para uso na empresa corrente!', 1, 0)
	EndIf
EndIf
*/

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���FUNCAO    �TIBW030SEND    �Autor  �V. RASPA                            ���
�������������������������������������������������������������������������Ĵ��
���DESCRICAO �Funcao responsavel pelo montagem e envio do processo de     ���
���          �workflow - Aprovacao de Pedidos de Compra                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
Local nValTot   := 0
Local cObsPedido := ""

Local cAliasQry := ''
Local aDoctos   := {}
Local nCount    := 0
Local aAttach   := {}
Local dEmissao  := dDataBase
Local cCCRat    := ""

Local cHTTPSrv  := AllTrim(SuperGetMV('ES_HTTPSRV',, 'localhost:6067/'))

Local aArea     := GetArea()
Local aAreaSA2  := SA2->(GetArea())
Local aAreaSB1  := SB1->(GetArea())
Local aAreaSC7  := SC7->(GetArea())
Local cRootPath := GetPvProfString(GetEnvServer(), 'RootPath', 'ERROR', GetADV97())
Local lBcoAnex  := SuperGetMv("ES_ANEXBCO",,.F.)  
Local cArq 		:= '' 
Local cQry		:= ''  
Local cArqLink 	:= ''
Local nx 		:= 0
Local _aUsr		:= {}
Local cEndpoint := 'http://' + cHttpSrv + If(Right(cHttpSrv, 1) <> '/', '/', '')
Local cDirHTTP  := "\workflow\emp"+Alltrim(cEmpAnt)+"\process\"

Default cNumPC  := SC7->C7_NUM


	
If !File( cDirHTTP )
	FwMakeDir( cDirHTTP ) 
EndIf

If U_LibWFPC()

	If nRemType == 2 // REMOTE_LINUX
		cArq := '/WEB/TEMPLATE/WFA030.HTML'	 
		cArqLink := '/WEB/TEMPLATE/WFLink.HTML'	
	Else  
		cArq := '\WEB\TEMPLATE\WFA030.HTML' 
		cArqLink := '\WEB\TEMPLATE\WFLink.HTML'
	Endif
	
	// -------------------------------------------
	// VALIDA A EXISTENCIA DO ARQUIVO DE TEMPLATE
	// -------------------------------------------
	If !File(cArq)
		Help('', 1, 'TIBW030',, 'N�o foi encontrado o arquivo de template para envio do processo de workflow!', 1, 0)	
	
	Else
		SC7->(DbSetOrder(1))
		If SC7->(DbSeek(xFilial('SC7')+cNumPC))
			// ----------------------------------------
			// Verifica o controle de alcadas, somente
			// para Pedidos de Compra:
			// ---------------------------------------
			
			cAliasQry := CriaTrab(Nil,.F.)
			
			cQry := " SELECT	SCR.CR_STATUS,        		"
			cQry += " 			SCR.R_E_C_N_O_ NRECSCR 		"
			cQry += "   FROM	SCR010 SCR            		"
			cQry += "  WHERE  SCR.CR_FILIAL = '" + xFilial("SCR") + "'"
			cQry += "    AND 	SCR.CR_NUM = '" + cNumPC + "'"
			cQry += "    AND 	SCR.CR_TIPO IN ('PC','IP')	"
			cQry += "    AND 	SCR.CR_WF = ' '       		"
			cQry += "    AND 	SCR.D_E_L_E_T_= ' '   		"
			cQry += "  ORDER 	BY  SCR.CR_NUM,       		"
			cQry += " 			SCR.CR_NIVEL,         		"
			cQry += " 			SCR.R_E_C_N_O_        		"
			
			If Select(cAliasQry) > 0
				(cAliasQry)->(DBCloseArea()) 
			Endif
			
			DBUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasQry,.T.,.T.)
			
			(cAliasQry)->(DBEval({|| If(CR_STATUS $ '02|04', AAdd(aDoctos, {CR_STATUS, nRecSCR}), NIL)},, {|| !Eof()}))
			(cAliasQry)->(DBCloseArea())
	
			For nCount := 1 To Len(aDoctos)
				SCR->(DbGoTo(aDoctos[nCount, 2]))
				cDocto := SCR->CR_NUM
				PswOrder(1)
				If PswSeek(SCR->CR_USER) .And. !Empty(PswRet()[1,14])
					cMailApr := AllTrim(PswRet()[1,14])
	
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
					oProcess:bReturn := 'U_WFCPRET()'
	
					// ---------------------------------------------------------
					// Tratamento do timeout. Este tratamento tem o objetivo
					// de determinar o tempo maximo para processamento do retorno
					// ---------------------------------------------------------
					oProcess:bTimeOut := {{'TIBXTimeOut()', 0, 0, 5 }}
					oProcess:NewVersion(.T.)
	
					// ---------------------------------------------------------
					// Realiza o preenchimento do HTML:
					// ---------------------------------------------------------
					SC7->(DbSetOrder(1))
					SC7->(DbSeek(xFilial('SC7')+cNumPC))
	
					SA2->(DbSetOrder(1))
					SA2->(DbSeek(xFilial('SA2')+SC7->(C7_FORNECE+C7_LOJA)))
	
					SE4->(DbSetOrder(1))
					SE4->(DbSeek(xFilial('SE4')+SC7->C7_COND))
	
					dEmissao := SC7->C7_EMISSAO
	
					//-- CABECALHO DO FORMULARIO

					oProcess:oHtml:ValByName('cCodAprov', SCR->CR_USER)

					PswOrder(1)      
					If (PswSeek(AllTrim(SCR->CR_USER), .T.)) 
						_aUsr := Pswret(1)
						oProcess:oHtml:ValByName('cNomAprov', _aUsr[1][4])
					EndIf

					oProcess:oHtml:ValByName('cNumPed'		, SC7->C7_NUM)
					oProcess:oHtml:ValByName('dEmissao'		, SC7->C7_EMISSAO)
					oProcess:oHtml:ValByName('cCodFor'		, SC7->(C7_FORNECE + '/' + C7_LOJA))
					oProcess:oHtml:ValByName('cNomFor' 		, SA2->A2_NOME)
					If PswSeek(SCR->CR_USER) .And. !Empty(PswRet()[1,4])
						oProcess:oHtml:ValByName('cComprador'	,AllTrim(PswRet()[1,4]))
					Else
						oProcess:oHtml:ValByName('cComprador'	, 'N�o Encontrado')
					EndIf		
					oProcess:oHtml:ValByName('cCondPagto'	, '(' + SC7->C7_COND + ') ' + SE4->E4_DESCRI)
					
					// Caso haja Rateio por Centro de Custo para o Pedido de Compra, eles ser�o trazidos atrav�s da fun��o abaixo.
					cCCRat := GetRateios()					
					
					//-- DADOS DO SOLICITANTE
					If !Empty(SC7->C7_NUMSC)
						SC1->(DbSetOrder(1))
						If SC1->(DbSeek(xFilial('SC1')+SC7->C7_NUMSC))
							If PswSeek(SC1->C1_USER) .And. !Empty(PswRet()[1,14])
								oProcess:oHtml:ValByName('cEmailSolic'	, AllTrim(PswRet()[1,14]))
								If !Empty(PswRet()[1,4])
									oProcess:oHtml:ValByName('cSolicitante'	, AllTrim(PswRet()[1,4]))
								Else
									oProcess:oHtml:ValByName('cSolicitante'	, 'Nao Informado')
								EndIf
							EndIf
							oProcess:oHtml:ValByName('dDtSolic'	, DtoC(SC1->C1_EMISSAO))
						Else
							oProcess:oHtml:ValByName('cSolicitante'	, 'Nao Informado')
							oProcess:oHtml:ValByName('cEmailSolic'	, '-')
							oProcess:oHtml:ValByName('dDtSolic'		, '-')
						EndIf
					Else
						oProcess:oHtml:ValByName('cSolicitante'	, 'Nao Informado')
						oProcess:oHtml:ValByName('cEmailSolic'	, '-')
						oProcess:oHtml:ValByName('dDtSolic'		, '-')
					EndIf
	
					
					//-- ITENS DO FORMULARIO

					nValLiq 	:= 0
					nValIPI 	:= 0
					nValICM		:= 0
					nValTot 	:= 0
					cObsPedido 	:= ""

					While !SC7->(Eof()) .And. SC7->(C7_FILIAL+C7_NUM) == xFilial('SC7')+cNumPC
						
						// -- Item
						AAdd(oProcess:oHtml:ValByName('PED.cItem')		, SC7->C7_ITEM )
						
						// -- Produto
						AAdd(oProcess:oHtml:ValByName('PED.cCodPro')	, SC7->C7_PRODUTO )

						// -- Descrocap do Produto
						AAdd(oProcess:oHtml:ValByName('PED.cDesPro')	, SC7->C7_DESCRI )

						// -- Observa��o 
						AAdd(oProcess:oHtml:ValByName('PED.CObservacao'), SC7->C7_OBS )

						// -- C.Custo
						AAdd(oProcess:oHtml:ValByName('PED.cCCusto')	, SC7->C7_CC )

						// -- Unidade de Medida
						AAdd(oProcess:oHtml:ValByName('PED.cCUMedida')	, SC7->C7_UM )

						// -- Quantidade
						AAdd(oProcess:oHtml:ValByName('PED.nQtde')		, Transform(SC7->C7_QUANT, PesqPict('SC7', 'C7_QUANT')))

						// -- Pre�o Unit�rio
						AAdd(oProcess:oHtml:ValByName('PED.nValUnit')	, cSimbMoed + Transform(SC7->C7_PRECO, PesqPict('SC7', 'C7_PRECO')))

						// -- ICMS
						AAdd(oProcess:oHtml:ValByName('PED.nValDesc')	, cSimbMoed + Transform(SC7->C7_VLDESC, PesqPict('SC7', 'C7_TOTAL')))

						// -- Valor TOtal
						AAdd(oProcess:oHtml:ValByName('PED.nValTot')	, cSimbMoed + Transform(SC7->(C7_TOTAL - C7_VLDESC), PesqPict('SC7', 'C7_TOTAL')))

						// -- Data de Entrega
						AAdd(oProcess:oHtml:ValByName('PED.dDtEntr')	, DTOC(SC7->C7_DATPRF) )
	

						//--Totais
						nValLiq += SC7->C7_TOTAL
						nValIPI += SC7->C7_VALIPI				
						nValTot += SC7->(C7_TOTAL + C7_VALIPI - C7_VLDESC)
						
						If Empty(cObsPedido)
							cObsPedido := SC7->C7_OBSAPR
						EndIf
	
						SC7->(DbSkip()) 

					End
		
					//-- TOTAIS
					oProcess:oHtml:ValByName('nValLiq', Transform(nValLiq, PesqPict('SC7', 'C7_TOTAL')))
					oProcess:oHtml:ValByName('nValTot', Transform(nValTot, PesqPict('SC7', 'C7_TOTAL')))
	
					//-- OBSREVACOES DO APROVADOR
					oProcess:oHtml:ValByName('cObsApr', cObsPedido)
	
					// ---------------------------------------------------------
					// Realiza a gravacao do processo de workflow.
					// Este processo sera gravado no servidor para
					// que seja acessado posteriormente via link 
					// enviado no e-mail de notificacao do processo
					// ---------------------------------------------------------
					cPastaHTM    := 'process'
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
					While !SC7->(Eof()) .And. SC7->(C7_FILIAL+C7_NUM) == xFilial('SC7')+cNumPC
		
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
					cMailId := oProcess:Start(cDirHTTP)
	
					// ---------------------------------------------------------
				    // Nova tarefa para envio do e-mail com
				    // o link do processo:
					// ---------------------------------------------------------
					oProcess:NewTask('WFA011', cArqLink)
					oProcess:oHtml:ValByName('cTitle', 'Aprovacao de Pedido de Compras No. ' + cNumPC)
	
					// ---------------------------------------------------------
					// Atualiza os dados no HTML referente 
					// a mensagem com o link:
					// ---------------------------------------------------------
					cUrl     := cEndpoint + 'emp' + cEmpAnt + '/' + cPastaHTM + '/' + cMailId + '.htm'
					cUrlImg  := cEndpoint + 'emp' + cEmpAnt + '/' + cPastaHTM + '/' 
	
					oProcess:oHtml:ValByName('cLink', cUrl)
					oProcess:oHtml:ValByName('cUrlImg', cUrlImg)	
				
					// ---------------------------------------------------------
					// Determina o destinatario do e-mail de
					// aprovacao:
					// ---------------------------------------------------------
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

						//Adiciona os anexos no e-mail:
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
@param cNumPc, character, (Descri��o do par�metro)
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���FUNCAO    �TIBW030RET    �Autor  �V. RASPA                             ���
�������������������������������������������������������������������������Ĵ��
���DESCRICAO �Funcao responsavel pelo tratamento do retorno do processo de���
���          �workflow - Aprovacao de Pedidos de Compra                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function WFCPRET(oProcess)
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

Local aArea      	:= GetArea()
Local aAreaSC7 		:= SC7->(GetArea())
Local aAreaSCR   	:= SCR->(GetArea())

DBSelectArea("SAK")
SAK->( DbSetOrder(1) )

DBSelectArea("SC7")
SC7->( DbSetOrder(1) )

DBSelectArea("SCR")
SCR->(DbSetOrder(2)) //-- CR_FILIAL+CR_TIPO+CR_NUM+CR_USER

// -----------------------------------------------
// Obtem os dados do formulario HTML para
// tratamento do retorno:
// -----------------------------------------------
cNumPC     := PADR(oProcess:oHtml:RetByName('cNumPed'),TamSx3("C7_NUM")[1])
cNumSCR    := PADR(oProcess:oHtml:RetByName('cNumPed'),TamSx3("CR_NUM")[1])
cObserv    := oProcess:oHtml:RetByName('cObsApr')
cCodAprov  := PADR(oProcess:oHtml:RetByName('cCodAprov'),TamSx3("CR_USER")[1])
lAprovado  := oProcess:oHtml:RetByName('Aprovacao') == 'S'

// -----------------------------------------------
// Posiciona no Documento de Alcada
// -----------------------------------------------

CONOUT("Debug: " + xFilial('SCR') + 'PC' + cNumSCR + cCodAprov)
CONOUT("Debug: " + xFilial('SCR') + 'IP' + cNumSCR + cCodAprov)

If 	SCR->(DbSeek(xFilial('SCR') + 'PC' + cNumSCR + cCodAprov)) .OR.;
	SCR->(DbSeek(xFilial('SCR') + 'IP' + cNumSCR + cCodAprov))
	CONOUT("Debug: " + cCodAprov + " TESTEIF")
	// -----------------------------------------------
	// Posiciona nas tabelas auxiliares
	// -----------------------------------------------
	SAK->( DbSeek(xFilial("SAK")+cCodAprov))

	If SC7->( DbSeek(xFilial("SC7")+cNumPC))
		CONOUT("Debug:  TESTEIF OBSERV")
		CONOUT("DEBUG: " + SC7->C7_NUM)
		CONOUT("DEBUG: " + SC7->C7_XCOPARC)
		cObsApr := SC7->C7_OBSAPR
		cObsApr += Chr(10)+Chr(13)
		cObsApr += '[OBSERVACOES REALIZADAS PELO APROVADOR: ' + UsrRetName(SCR->CR_USER) + ']' + Chr(10)+Chr(13)
		cObsApr += cObserv

		While !SC7->(Eof()) .And.; 
				SC7->(C7_FILIAL+C7_NUM) == xFilial("SC7")+cNumPC

			RecLock('SC7', .F.)
			SC7->C7_OBSAPR := cObsApr
			SC7->(MsUnLock())
			SC7->(DbSkip())

		End
		RestArea(aAreaSC7)
	EndIf	

	CONOUT("DEBUG: " + SC7->C7_NUM)
	
	SC7->( DbSeek(xFilial("SC7")+cNumPC))
	
	CONOUT("DEBUG: " + SC7->C7_NUM)
	
	SAL->( DbSetOrder(3) )
	SAL->( DbSeek(xFilial("SAL")+SC7->C7_APROV+SAK->AK_COD) )

	// -----------------------------------------------
	// Avalia o Status do Documento a ser liberado
	// -----------------------------------------------
	If lContinua .And. !Empty(SCR->CR_DATALIB) .And. SCR->CR_STATUS $ '03|05'
		CONOUT("Debug:  TESTEIF JALIBERADO")
		Conout('[PEDIDO: ' + cNumPC + ']Este pedido ja foi liberado anteriormente. Somente os pedidos que estao aguardando liberacao poderao ser liberados.')
		lContinua := .F.

	ElseIf lContinua .And. SCR->CR_STATUS $ '01'
		CONOUT("Debug:  TESTEIF BLOQUEADO NIVEIS")
		Conout('[PEDIDO: ' + cNumPC + ']Esta opera��o n�o poder� ser realizada pois este registro se encontra bloqueado pelo sistema (aguardando outros niveis)')
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
			CONOUT("Debug:  TESTEIF BLOQUEADO PCO")
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
				CONOUT("Debug:  TESTEIF BLOQUEADO SALDO APROVADOR")
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
				lLiberou := MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,SCR->CR_APROV,,SC7->C7_APROV,,,,,cObserv},dDataBase,IIF(lAprovado,4,6))
				
				If !lAprovado
					RECLOCK("SCR",.F.)
						SCR->CR_STATUS := "06"
					SCR->(MSUnlock())
				EndIf
							
				If Empty(SCR->CR_DATALIB) //-- Verifica se Aprovou se liberou o Documento
					CONOUT("Debug:  TESTEIF LIBEROU MAALCDOC")
					Conout('[PEDIDO ' + cNumPC + ']Nao foi possivel realizar a liberacao do Documento via WorkFlow. Tente realizar a liberacao manual.')
					lContinua := .F.
				EndIf

				/* Valida se todos os itens da SCR foram aprovados para determinar se Libera o Pedido 
				   Autor: Caio Cesar Henrique
				   Data: 29/08/2021 
				*/
				If CPVALSCR()
					lContinua := .T.
				Else 
					lContinua := .F.
				EndIf 

				If lContinua

					If lLiberou //-- Verifica se todos os niveis ja foram aprovados
						CONOUT("Debug:  TESTEIF LIBEROU TODOS NIVEIS")
						// ---------------------------------------------------------
						// Grava os lancamentos nas contas orcamentarias SIGAPCO
						// ---------------------------------------------------------
						PcoDetLan("000055","02","MATA097")
						
						CONOUT("DEBUG: " + SC7->C7_XCOPARC)
						
						// -- Libera o Pedido
						IF Empty(SC7->C7_XCOPARC) .or. SC7->C7_XCOPARC == 'N'
							CONOUT("DEBUG: " + SC7->C7_FILIAL+SC7->C7_NUM)
							CONOUT("DEBUG: " + xFilial("SC7")+cNumPC)
										
							While SC7->(!Eof()) .And. SC7->C7_FILIAL+SC7->C7_NUM == xFilial("SC7")+cNumPC
								CONOUT("Debug:  LIBERA PC ")
								Reclock("SC7",.F.)
								SC7->C7_CONAPRO := "L" //-- Atualiza o status (Liberado) no Pedido de Compra
								SC7->(MsUnlock())

								// ---------------------------------------------------------
								// Gravaos lancamentos nas contas orcamentarias SIGAPCO
								// ---------------------------------------------------------
								PcoDetLan("000055","01","MATA097")
								SC7->( dbSkip() )

							End

						Elseif SC7->C7_XCOPARC == 'S'

							// -- Libera o Contrato
							IF !EMPTY(SC7->C7_XNOCPAR)
								SC3->( DbSetOrder(1))
								SC3->( MsSeek( xFilial("SC3") + SC7->C7_XNOCPAR ) )
								While SC3->( !Eof() .And. SC3->C3_FILIAL+SC3->C3_NUM == xFilial("SC3") + SC7->C7_XNOCPAR ) 
									CONOUT("Debug:  TESTEIF SC3 ")
									Reclock("SC3",.F.)
									SC3->C3_CONAPRO := "L" //-- Atualiza o status (Liberado) no Pedido de Compra
									SC3->(MsUnlock())									
									SC3->( DbSkip() )
								End
							Endif

							// -- Anula o PC
							While SC7->(!Eof()) .And. SC7->C7_FILIAL+SC7->C7_NUM == xFilial("SC7")+PadR(SCR->CR_NUM,Len(SC7->C7_NUM))
								CONOUT("Debug:  TESTEIF LIMPA PC ")
								
								Reclock("SC7",.F.)
								SC7->C7_CONAPRO := "R"  
								//SC7->C7_RESIDUO	:= 'S'	
								SC7->(MsUnlock())
								SC7->( dbSkip() )
							End

						Endif

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
						cTitle   := 'Aprovacao de Pedido de Compra No. ' + cNumPC + ' - Aprovado'
						cMsg     := 'O Pedido de compra No. ' + cNumPC + ' foi aprovado com sucesso!'

						PswOrder(1)
						If PswSeek(SC7->C7_USER) .And. !Empty(PswRet()[1,14])
							cMailCompr := AllTrim(PswRet()[1,14])
						Endif

					Else

						If SCR->CR_STATUS == '06'	//-- Se Rejeitado

							Conout('[PEDIDO ' + cNumPC + ']O pedido em questao foi rejeitado!')

							// ---------------------------------------------------------
							// Envia e-mail ao comprador notificando a liberacao
							// do pedido de compra
							// ---------------------------------------------------------
							lSendMsg := .T.
							cTitle   := 'Aprovacao de Pedido de Compra No. ' + cNumPC + ' - Reprovado'
							cMsg     := 'O Pedido de compra No. ' + cNumPC + ' foi Reprovado.'

							//-- Obtem o e-mail do Comprador:
							SC7->(DbSetOrder(1))
							SC7->(DbSeek(xFilial("SC7")+cNumPC))

							// -- Anula o PC
							While SC7->(!Eof()) .And. SC7->C7_FILIAL+SC7->C7_NUM == xFilial("SC7")+PadR(SCR->CR_NUM,Len(SC7->C7_NUM))
								Reclock("SC7",.F.)
								SC7->C7_CONAPRO := "R"  
							//	SC7->C7_RESIDUO	:= 'S'	
								SC7->(MsUnlock())
								SC7->(dbSkip())
							End

							//-- Obtem o e-mail do Comprador:
							SC7->(DbSetOrder(1))
							SC7->(DbSeek(xFilial("SC7")+cNumPC))

							PswOrder(1)
							If PswSeek(SC7->C7_USER) .And. !Empty(PswRet()[1,14])
								cMailCompr := AllTrim(PswRet()[1,14])
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
		//�����������������������������������������������������������Ŀ
		//� Finaliza a gravacao dos lancamentos do SIGAPCO            �
		//�������������������������������������������������������������
		PcoFinLan("000055")

		If lSendMsg
			CONOUT("DEBUG")
			CONOUT("cTitle: " + cTitle)
			CONOUT("cMsg: " + cMsg)
			U_TIBW030Msg(cTitle, cMsg, GetMv('FT_MAILCOM',,'COMPRAS@CAREPLUS.COM.BR'), cNumPC, cObserv)
		EndIf

	EndIf
EndIf

RestArea(aArea)
RestArea(aAreaSC7)
RestArea(aAreaSCR)
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ValidPcoLan                                                ���
�������������������������������������������������������������������������͹��
���Descri��o � Valida o lancamento no PCO.                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � TIBW030Msg                                                 ���
�������������������������������������������������������������������������͹��
���Descri��o � Envia mensagem de e-mail ao final do processo              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function TIBW030Msg(cTitle, cMsg, cMail, cNumPC, cObs)

Local cArqMsg	:= ''
Local cSimbMoed := SuperGetMV('MV_SIMB' + Alltrim(Str(SC7->C7_MOEDA)), .F., 'R$') + ' '

Local aArea		:= GetArea()

Local oPrcMsg 	:= NIL

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
oPrcMsg:oHtml:ValByName('cOBS'	, cObs)


DBSelectArea("SC7")
SC7->(DBSetOrder(1))
SC7->(DBSeek(xFilial("SC7")+cNumPC))

While !SC7->(Eof()) .And. SC7->(C7_FILIAL+C7_NUM) == xFilial('SC7')+cNumPC						
	// -- Item
	AAdd(oPrcMsg:oHtml:ValByName('PED.cItem')		, SC7->C7_ITEM )			
	// -- Produto
	AAdd(oPrcMsg:oHtml:ValByName('PED.cCodPro')	, SC7->C7_PRODUTO )
	// -- Descrocap do Produto
	AAdd(oPrcMsg:oHtml:ValByName('PED.cDesPro')	, SC7->C7_DESCRI )
	// -- Observa��o 
	AAdd(oPrcMsg:oHtml:ValByName('PED.CObservacao'), SC7->C7_OBS )
	// -- C.Custo
	AAdd(oPrcMsg:oHtml:ValByName('PED.cCCusto')	, SC7->C7_CC )
	// -- Unidade de Medida
	AAdd(oPrcMsg:oHtml:ValByName('PED.cCUMedida')	, SC7->C7_UM )
	// -- Quantidade
	AAdd(oPrcMsg:oHtml:ValByName('PED.nQtde')		, Transform(SC7->C7_QUANT, PesqPict('SC7', 'C7_QUANT')))
	// -- Pre�o Unit�rio
	AAdd(oPrcMsg:oHtml:ValByName('PED.nValUnit')	, cSimbMoed + Transform(SC7->C7_PRECO, PesqPict('SC7', 'C7_PRECO')))
	// -- ICMS
	AAdd(oPrcMsg:oHtml:ValByName('PED.nValDesc')	, cSimbMoed + Transform(SC7->C7_VLDESC, PesqPict('SC7', 'C7_TOTAL')))
	// -- Valor TOtal
	AAdd(oPrcMsg:oHtml:ValByName('PED.nValTot')	, cSimbMoed + Transform(SC7->(C7_TOTAL - C7_VLDESC), PesqPict('SC7', 'C7_TOTAL')))
	// -- Data de Entrega
	AAdd(oPrcMsg:oHtml:ValByName('PED.dDtEntr')	, DTOC(SC7->C7_DATPRF) )
	
	SC7->(DbSkip()) 

EndDo

//-- Determina o destinatario do e-mail
oPrcMsg:cTo := cMail

//-- Assunto do e-mail:
oPrcMsg:cSubject := cTitle

//-- Envia e-mail
oPrcMsg:Start()

//--Libera o objeto
oPrcMsg :Free()
oPrcMsg := NIL

RestArea(aArea)

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

// --------------------------------------------------------------------
// cDocto == Numero do Documento
// cTipo  == Tipo do Documento "PC" | "AE" | "CP"

// Quando o ponto eh acionado pela rotina de Libera��o e Superior:
// nOpc == 1 --> Cancela
// nOpc == 2 --> Libera
// nOpc == 3 --> Bloqueia

// Quando o ponto eh acionado pela rotina de Transf. Superior
// nOpc == 1 --> Transfere
// nOpc == 2 --> Cancela
// --------------------------------------------------------------------

If U_LibWFPC()


	If AllTrim(cTipo) == 'PC'
		If ((IsInCallStack('A097LIBERA') .Or. IsInCallStack('A097SUPERI')) .And. nOpc == 2) .Or.;
				(IsInCallStack('A097TRANSF') .And. nOpc == 1)
			SC7->(DbSetOrder(1))
			If SC7->(DbSeek(cFildoc+cNumPC))
				If cWFPCAuto == '1' //--Pergunta antes de enviar
					If Aviso('ATEN��O', 'Envia processo de Workflow para este pedido?', {'SIM', 'N�O'}, 2) == 1
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
					cTitle   := 'Aprovacao de Pedido de Compra ' + cNumPC + ' - Aprovado'
					cMsg     := 'O Pedido de compra No. ' + cNumPC + ' foi aprovado com sucesso!'
					
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
					cTitle   := 'Aprovacao de Pedido de Compra ' + cNumPC + ' - Reprovado'
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
			U_TIBW030Msg(cTitle, cMsg, cMailCompr)
		EndIf
	EndIf

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

If (lInclui .Or. lAltera) .And. !lExclui
	If cWFPCAuto == '1' //--Pergunta antes de enviar
		If Aviso('ATEN��O', 'Envia processo de Workflow para este pedido?', {'SIM', 'N�O'}, 2) == 1
		
			MsgRun('Montando processo de workflow', 'Aguarde...',;
					{|| U_TIBW030Send(cNumPC)})

		EndIf

	ElseIf cWFPCAuto == '2' //--Envia o processo sem perguntar
		
		MsgRun('Montando processo de workflow', 'Aguarde...',;
				{|| U_TIBW030Send(cNumPC)})
		
	EndIf
EndIf

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

Local cWFPCAuto := SuperGetMV('ES_WFPCAUT',, '1')

If cWFPCAuto == '1' //--Pergunta antes de enviar
	If Aviso('ATEN��O', 'Envia processo de Workflow para o pedido de compra gerado pela analise da cota��o?', {'SIM', 'N�O'}, 2) == 1
		MsgRun('Montando processo de workflow', 'Aguarde...',;
				{|| U_TIBW030Send()})
	EndIf
ElseIf cWFPCAuto == '2' //--Envia o processo sem perguntar
	MsgRun('Montando processo de workflow', 'Aguarde...',;
			{|| U_TIBW030Send()})
EndIf

Return

/*/{Protheus.doc} GetRateios
Retorna os Centros de Custos utilizados e seus percentuais em caso de rateio do pedido de compra por Centro de Custo.

@author Leandro F. Dourado
@since 09/03/2016
@version 1.0
/*/
Static Function GetRateios()
Local aArea  := GetArea()
Local cRet   := ""
Local cChave := FwxFilial("SCH")+SC7->(C7_NUM+C7_FORNECE+C7_LOJA)

DbSelectArea("SCH")
SCH->(DbSetOrder())

If SCH->(DbSeek(cChave))
	While SCH->(!EOF()) .AND. cChave == SCH->(CH_FILIAL+CH_PEDIDO+CH_FORNECE+CH_LOJA)
		If !Empty(cRet)
			cRet += ";"
		EndIf
		cRet += Transform(SCH->CH_PERC, PesqPict('SCH', 'CH_PERC'))+"% para "+SCH->CH_CC
		SCH->(DbSkip())
	EndDo
EndIf

RestArea( aArea )

Return cRet

/* Valida se todos os itens da SCR foram aprovados para determinar se Libera o Pedido 
	Autor: Caio Cesar Henrique
	Data: 29/08/2021 
*/

Static Function CPVALSCR()

	Local aArea := GetArea()
	Local cAlias := GetNextAlias()
	Local cPedido := SCR->CR_NUM
	Local lRet := .T.

	BeginSQL Alias cAlias 

		SELECT COUNT(*) [TOTAL] 
		FROM %Table:SCR% SCR
			WHERE CR_NUM = %Exp:cPedido%
			AND CR_FILIAL = %xFilial:SCR%
			AND CR_DATALIB = ' '  
			AND SCR.%NotDel%

	EndSQL 

	If (cAlias)->TOTAL > 0
		lRet := .F.
	EndIf 

	(cAlias)->(dbCloseArea())

	RestArea(aArea)

Return ( lRet )





