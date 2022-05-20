#INCLUDE "FWMVCDEF.CH"
#include 'protheus.ch'
#INCLUDE "TOPCONN.CH"

Static nRemType := GetRemoteType()


/*/{Protheus.doc} VOGWF03
Workflow de aprovação de Contratos
@type function
@author B. Vinicius 
@since 29/06/2020
@version 1.0
/*/

User Function VOGWF03()

    If Aviso('Workflow', 'Deseja enviar o processo de workflow para o contrato de compra selecionado?', {'SIM', 'NAO'}, 2) == 1
        MsgRun('Montando processo de workflow', 'Aguarde...',;
            {|| u_GWF03(CN9->CN9_NUMERO)})
    EndIf

Return

// Montagem do Workflow 
User Function GWF03(cNumCont)

    Local cAliasQry := GetNextAlias()
    Local aDoctos := {}
    Local nCount := 0
    Local oProcess := ""
    Local cMailApr := ""
    Local cHTTPSrv  := AllTrim(SuperGetMV('ES_HTTPSRV',, 'localhost:6067/'))
    Local cArq := ""
    Local cArqLink := ""
    Local cUrl := ""
    Local cUrlImg := ""
    Local cPastaHTM := ""
    Local cRevisa := ""
    Local nTotContrato := 0
    Local cUrlImg2 :=""
    Local nValLiq := 0

    Local lHabilita := AllTrim(SuperGetMV('ES_HABCTR',, '2'))  == "1"
    Local cLogoD := ""
    Local cGrupoAprov := ""
    Local cNumContQry := ''

Local cCNAVLTOT  := 0 
   //Trava para habilitar o parametro
    If lHabilita

        cGrupoAprov := CN9->CN9_APROV

        //-----------------------------------------------------------------------------
        // SELECIONANDO LOGO DO WORKFLOW
        //-----------------------------------------------------------------------------
        cLogoD	:= GetSrvProfString("Startpath","") + "lgmid" + cEmpAnt + ".png"
        If !File(cLogoD)
            cLogoD := "logo.png"
        Else
            __CopyFile( cLogoD, '\WEB\TEMPLATE\' + "lgmid" + cEmpAnt + ".png" )
            __CopyFile( cLogoD, '\workflow\messenger\emp01\PROCESSOS\' + "lgmid" + cEmpAnt + ".png" )
            cLogoD := "lgmid" + cEmpAnt + ".png"
        EndIf

        If nRemType == 2 // REMOTE_LINUX
            cArq := '/WEB/TEMPLATE/VOGWF03.HTML'
            cArqLink := '/WEB/TEMPLATE/WFLink03.HTML'
        Else
            cArq := '\WEB\TEMPLATE\VOGWF03.HTML'
            cArqLink := '\WEB\TEMPLATE\WFLink03.HTML'
        Endif
        cNumContQry := cNumCont+'%'

        BeginSQl Alias cAliasQry
				SELECT 	SCR.CR_STATUS, SCR.R_E_C_N_O_ nRecSCR,CR_NUM,CR_TIPO
				FROM 	%Table:SCR% SCR
				WHERE 	SCR.CR_FILIAL =  %xFilial:SCR% AND
						SCR.CR_NUM    LIKE  %Exp:cNumContQry% AND
						SCR.CR_TIPO   IN ('CT','RV')  AND
                        SCR.CR_DATALIB = ''  and 
						SCR.CR_WF     =  %Exp:Space(Len(SCR->CR_WF))% AND
						SCR.%NotDel%
				ORDER 
				BY 		SCR.CR_NUM, 
						SCR.CR_NIVEL, 
						SCR.R_E_C_N_O_
        EndSQL

        (cAliasQry)->(DBEval({|| If(CR_STATUS $ '02|04', AAdd(aDoctos, {CR_STATUS, nRecSCR,CR_NUM,CR_TIPO}), NIL)},, {|| !Eof()}))
        (cAliasQry)->(DbCloseArea())

        For nCount := 1 To Len(aDoctos)

            SCR->(DbGoTo(aDoctos[nCount, 2]))
            cDocto := SCR->CR_NUM
            PswOrder(1)

            If PswSeek(SCR->CR_USER) .And. !Empty(PswRet()[1,14])

                cMailApr := AllTrim(PswRet()[1,14])
                 //cMailApr := "bruno.pinto@totvs.com.br"

                // ---------------------------------------------------------
                // Criacao do objeto TWFProcess, responsavel
                // pela inicializacao do processo de Workflow
                // ---------------------------------------------------------
                oProcess := TWFProcess():New('APR_CT', 'Criacao do Processo - Aprovacao de Contratos')

                // Criacao de uma tarefa de workflow. Podem
                // existir varias tarefas. Para cada tarefa,
                // deve-se informar um nome e o HTML envolvido
                // ---------------------------------------------------------
                oProcess:NewTask('VOGWF03', cArq)


                // ---------------------------------------------------------
                // Determinacao da funcao que realiza o processamento
                // do retorno do workflow
                // ---------------------------------------------------------
                oProcess:bReturn := 'U_VOG040Ret()'

                // CONTRATO
                CN9->(DbSetOrder(1))
                CN9->(dbSeek( FWxFilial("CN9") + Substr( aDoctos[nCount, 3],1,tamSx3("CNB_CONTRA")[1] ) + Substr( aDoctos[nCount, 3],tamSx3("CNB_CONTRA")[1]+1,3 ) ))
                cRevisa := CN9->CN9_REVISA
                cNumCont := CN9->CN9_NUMERO

                //CONDICAO DE PAGAMENTO
                SE4->(DbSetOrder(1))
                SE4->(DbSeek(xFilial('SE4')+CN9->CN9_CONDPG))

                //FORNECEDOR
                CNC->(DbSetOrder(1))
                CNC->(dbSeek( FWxFilial("CNC") + Substr( aDoctos[nCount, 3],1,tamSx3("CNB_CONTRA")[1] ) + Substr( aDoctos[nCount, 3],tamSx3("CNB_CONTRA")[1]+1,3 )  ))

                SA2->(DbSetOrder(1))
                SA2->(DbSeek(xFilial('SA2')+CNC->(CNC_CODIGO + CNC_LOJA )))

                // ---------------------------------------------------------
                // Realiza o preenchimento do HTML:
                // ---------------------------------------------------------

                //-- CABECALHO DO FORMULARIO
                oProcess:oHtml:ValByName('cNumCont'		, aDoctos[nCount, 3])
                oProcess:oHtml:ValByName('dEmissao'		, CN9->CN9_DTINIC)
                oProcess:oHtml:ValByName('cFilial'      , SM0->M0_CODFIL + '-' + SM0->M0_CGC)
                oProcess:oHtml:ValByName('cCodFor'		, CNC->(CNC_CODIGO + '/' + CNC_LOJA ))
                oProcess:oHtml:ValByName('cNomFor' 		, SA2->A2_NOME)
                oProcess:oHtml:ValByName('cCodAprov'	, SCR->CR_USER + ' ' +  AllTrim(PswRet()[1,14]) )
                oProcess:oHtml:ValByName('cSolicitante'	, FWLeUserlg("CN9_USERGI", 1)  )
                oProcess:oHtml:ValByName('dDtSolic'	    , Dtoc(date()) )
                oProcess:oHtml:ValByName('cCondPagto'	, POSICIONE("SE4",1,FWxFilial("SE4")+CN9->CN9_CONDPG,"E4_DESCRI"))
                oProcess:oHtml:ValByName('cObsCont'	    , U_ConvHTML(Alltrim(CN9->CN9_XOBS)))
                oProcess:oHtml:ValByName('cNumOI'    	, CN9->CN9_XORDIN )
                oProcess:oHtml:ValByName('cVlrTCont'	, Alltrim(Transform(CN9->CN9_VLATU,PesqPict("CNB","CNB_VLUNIT"))) )

                PswOrder(2) //Ordena pelo nome do usuario a busca
                If PswSeek(FWLeUserlg("CN9_USERGI", 1)) .And. !Empty(PswRet()[1,14])
                    oProcess:oHtml:ValByName('cEmailSolic'	, AllTrim(PswRet()[1,14]) )
                Endif

                // SELECIONANDO ITENS
                CNB->(dbSetOrder(1))
                If CNB->(dbSeek( FWxFilial("CNB") + Substr( aDoctos[nCount, 3],1,tamSx3("CNB_CONTRA")[1] ) + Substr( aDoctos[nCount, 3],tamSx3("CNB_CONTRA")[1]+1,3 )  ))

                    nValLiq := 0

                    While CNB->CNB_CONTRA == cNumCont .And. CNB->CNB_REVISA == cRevisa .And. !CNB->(EOF())
                        
                        cnVlrt := CNB->CNB_VLTOT
                        cnQtde := CNB->CNB_QUANT
                        
                        DbSelectArea("CNA")       ///Triyo - 19/11/2020
	                    DbSetOrder(1)
	                    If dbSeek(xFilial("CNA")+CNB->(CNB_CONTRA+CNB_REVISA+CNB_NUMERO))  
	                       cCNAVLTOT := CNA->CNA_VLTOT
	                    EndIf  
                        /*
                        If cnVlrt == 0 .and. cnQtde == 0
                           DbSelectArea("CN9")
                           DbSetOrder(1)
                           If dbSeek(xFilial("CN9")+CNB->(CNB_CONTRA+CNB_REVISA))
                              cnVlrt :=  CN9->CN9_VLATU
                              cnQtde :=  CN9->CN9_VLATU
                           Else
                               cnVlrt := CNB->CNB_VLTOT
                               cnQtde := CNB->CNB_QUANT
                           Endif
                        Endif
                        */
                        AAdd(oProcess:oHtml:ValByName('CONT.cItem')		,  CNB->CNB_ITEM )
                        AAdd(oProcess:oHtml:ValByName('CONT.cCodPro')	,  CNB->CNB_PRODUT )
                        AAdd(oProcess:oHtml:ValByName('CONT.cDesPro')	,  CNB->CNB_DESCRI )
                        AAdd(oProcess:oHtml:ValByName('CONT.cCC')		,  CNB->CNB_CC )
                        AAdd(oProcess:oHtml:ValByName('CONT.nQtde')		,  Alltrim(Transform(CNB->CNB_QUANT,PesqPict("CNB","CNB_QUANT"))) )
                        AAdd(oProcess:oHtml:ValByName('CONT.nValUnit')	,  Alltrim(Transform(CNB->CNB_VLUNIT,PesqPict("CNB","CNB_VLUNIT"))) )
                        //AAdd(oProcess:oHtml:ValByName('CONT.nValDesc')	,  Alltrim(Transform(CNB->CNB_VLDESC,PesqPict("CNB","CNB_VLDESC"))) )
                        AAdd(oProcess:oHtml:ValByName('CONT.nValTot')	,  Alltrim(Transform(CNB->CNB_VLTOT, PesqPict("CNB","CNB_VLTOT"))) )

                        //nTotContrato += CNB->CNB_VLTOT
                        If Empty(cCNAVLTOT)
                            nValLiq := cnVlrt
                        Else
                            nValLiq += cnVlrt
                        EndIf 


                        AC9->(DbSetOrder(2))
                        AC9->(DbSeek(xFilial('AC9')+'CN9'+cFilAnt+CN9->CN9_NUMERO))

                        Do While Rtrim( AC9->(AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT) ) == Rtrim((xFilial('AC9')+'CN9'+cFilAnt+CN9->CN9_NUMERO))
                            ACB->(DbSetOrder(1))
                            If ACB->(DbSeek(xFilial('ACB')+AC9->AC9_CODOBJ))
                                oProcess:AttachFile('/dirdoc/co'+cEmpAnt+'/shared/'+ACB->ACB_OBJETO)
                            EndIf
                            AC9->(DbSkip())
                        Enddo

                        CNB->(dbSkip())

                    EndDo

                Endif

                oProcess:oHtml:ValByName('nValLiq' 		, Alltrim(Transform(nValLiq, PesqPict("CNB","CNB_VLTOT")))  )

                	//Exibindo alçadas de aprovacoes
						SCR->(DbSetOrder(1))
						If SCR->(dbSeek( FwXFilial("SCR") +  Padr(aDoctos[nCount, 4],TamSx3("CR_TIPO")[1]) +aDoctos[nCount, 3] ))
							While !SCR->(EOF()) .And. FWxFilial("SCR") + Padr(aDoctos[nCount, 4],TamSx3("CR_TIPO")[1]) + Padr(aDoctos[nCount, 3],TamSx3("CR_NUM")[1]) == SCR->CR_FILIAL + SCR->CR_TIPO + SCR->CR_NUM

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

                cPastaHTM    := 'PROCESSOS'
                oProcess:cTo := cPastaHTM
\
                // ---------------------------------------------------------
                // Tratamento da rastreabilidade do workflow
                // 1o. passo: Envio do e-mail:
                // ---------------------------------------------------------
                // RastreiaWF(oProcess:fProcessID + '.' + oProcess:fTaskID, oProcess:fProcCode, '30001')

                // ---------------------------------------------------------
                // Reposiciona o SC7 para gravacao do processo de
                // workflow no pedido de compras:
                // ---------------------------------------------------------
          /*  SC7->(DbSeek(xFilial('SC7')+cNumCont))
                While !SC7->(Eof()) .And.;
                    SC7->(C7_FILIAL+C7_NUM) == xFilial('SC7')+cNumCont

                RecLock('SC7', .F.)
                SC7->C7_WFID := oProcess:fProcessID
                SC7->(MsUnLock())

                SC7->(DbSkip())
                    End*/

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
            oProcess:NewTask('WFA011', cArqLink)
            oProcess:oHtml:ValByName('cTitle', 'Aprovacao de Contratos No. ' + cNumCont )
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
           // oProcess:cTo := "bruno.pinto@totvs.com.br"
             oProcess:cTo := cMailApr

            // ---------------------------------------------------------
            // Titulo para o email:
            // ---------------------------------------------------------
            oProcess:cSubject := 'Aprovacao de Contrato de Compra No. ' + cNumCont

            //Verificando se existem anexos
            AC9->(DbSetOrder(2))
			AC9->(DbSeek(xFilial('AC9') + 'CN9' + cFilAnt + cNumCont))

                Do While  AC9->(AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+Alltrim(AC9_CODENT))  ==  FWxFilial('AC9') + 'CN9' + cFilAnt + Alltrim(cNumCont)
				ACB->(DbSetOrder(1))
                    If ACB->(DbSeek(xFilial('ACB')+AC9->AC9_CODOBJ))
						oProcess:AttachFile('/dirdoc/co'+cEmpAnt+'/shared/'+ACB->ACB_OBJETO)
                    EndIf
				AC9->(DbSkip())
                Enddo

            // ---------------------------------------------------------
            // Envia o e-mail com link para aprovacao
            // ---------------------------------------------------------
            oProcess:Start()


            // ---------------------------------------------------------
            // Libera Objeto
            // ---------------------------------------------------------
            oProcess :Free()
            oProcess := NIL
            Endif
        Next

    Endif

Return


//Retorno do Workflow
User Function VOG040Ret(oProcess)

    Local cNumCont     := oProcess:oHtml:RetByName('cNumCont')
    Local cNumSCR := Padr(oProcess:oHtml:RetByName('cNumCont'),TamSx3("CR_NUM")[1]) 
    Local cCodAprov  := oProcess:oHtml:RetByName('cCodAprov')//"000050"//oProcess:oHtml:RetByName('cCodAprov')
	Local lAprovado  :=  oProcess:oHtml:RetByName('Aprovacao') == 'S'
    Local lContinua := .T.
    Local aRetSaldo := {}
    Local nTotal := 0
    Local cMailCompr := ""
    Local oModelCT := FWLoadModel("MATA094")
    Local lAprovou := .T.
    Local cMailCont := ""
    Local cUserCont := ""
    Local cMsg := ""
    Local cObserv    := oProcess:oHtml:RetByName('cObsApr')
    Local lReprovou := .F.
    Local lAprovou := .F.
    Local nRecSCR := 0

    // -----------------------------------------------
    // Posiciona no Documento de Alcada
    // -----------------------------------------------
	SCR->(DbSetOrder(2)) //-- CR_FILIAL+CR_TIPO+CR_NUM+CR_USER
    If SCR->(DbSeek(xFilial('SCR') + 'CT' + cNumSCR + cCodAprov)) .OR. SCR->(DbSeek(xFilial('SCR') + 'RV' + cNumSCR + cCodAprov))

        nRecSCR :=  SCR->(RECNO()) 
        // -----------------------------------------------
		// Posiciona nas tabelas auxiliares
		// -----------------------------------------------
		SAK->( DbSetOrder(2) )
		SAK->( DbSeek(xFilial("SAK")+cCodAprov))

        SAL->( DbSetOrder(3) )
		SAL->( DbSeek(xFilial("SAL")+SCR->CR_GRUPO+SAK->AK_COD) )

        If lContinua .And. !Empty(SCR->CR_DATALIB) .And. SCR->CR_STATUS $ '03|05'
			Conout('[Contrato: ' + cNumCont + ']Este contrato ja foi liberado anteriormente. Somente os pedidos que estao aguardando liberacao poderao ser liberados.')
			lContinua := .F.

        ElseIf lContinua .And. SCR->CR_STATUS $ '01'
			Conout('[Contrato: ' + cNumCont + ']Esta operação não poderá ser realizada pois este registro se encontra bloqueado pelo sistema (aguardando outros niveis)')
			lContinua := .F.
        EndIf

        
        If lContinua
			
			
			// ---------------------------------------------------------
			// Analisa o Saldo do Aprovador
			// ---------------------------------------------------------
            If lContinua .And. SAL->AL_LIBAPR == 'A'
			/*	aRetSaldo  := MaSalAlc(cCodAprov,dDataBase)
				nTotal     := xMoeda(SCR->CR_TOTAL,SCR->CR_MOEDA,aRetSaldo[2],SCR->CR_EMISSAO,,SCR->CR_TXMOEDA)
                If (aRetSaldo[1] - nTotal) < 0
					Conout('[PEDIDO ' + cNumCont + ']Saldo na data insuficiente para efetuar a liberacao do pedido. Verifique o saldo disponivel para aprovacao na data e o valor total do pedido.')
					lContinua := .F.
                EndIf */
            EndIf



If lContinua
    Begin Transaction

        // Chama a rotina padrao de aprovacao
        If lAprovado
            lAprovou := GCTAlcEnt(oModelCT,MODEL_OPERATION_UPDATE,IIf(lAprovado,4,5),SCR->CR_TIPO,SCR->CR_NUM,,)
        Else
            lReprovou  := CnRejDoc(SCR->CR_TIPO)
        Endif

        SCR->(dbGoTo(nRecSCR))

        If Empty(SCR->CR_DATALIB) //-- Verifica se Aprovou se liberou o Documento
            Conout('[contrato ' + cNumCont + ']Nao foi possivel realizar a liberacao do Documento via WorkFlow. Tente realizar a liberacao manual.')
            lContinua := .F.
        EndIf

        If lContinua
                        If lAprovou //-- Verifica se todos os niveis ja foram aprovados

                            //Busca o usuario da inclusao do contrato
                            CN9->(dbSetOrder(1))
                            CN9->(dbSeek( FWxFilial("CN9") + cNumCont))
                            cUserCont := FWLeUserlg("CN9_USERGI", 1)  

                            // Se o usuario tiver email cadastrado, envia email de aviso com sucesos na aprovação
                            PswOrder(2) //Ordena pelo nome do usuario a busca
                            If PswSeek(cUserCont) .And. !Empty(PswRet()[1,14])
                                cMailCont := AllTrim(PswRet()[1,14])        
                                cMsg := 'Prezado Participante, o contrato No ' + cNumCont + ' foi aprovado com sucesso.'
                                U_WF03Msg('Aprovação de Contrato', cMsg, cMailCont)                  
                            Endif

                        Else
                            If SCR->CR_STATUS $ '04|06'	//-- Se Rejeitado
                                
                                //Busca o usuario da inclusao do contrato
                                CN9->(dbSetOrder(1))
                                CN9->(dbSeek( FWxFilial("CN9") + cNumCont))
                                cUserCont := FWLeUserlg("CN9_USERGI", 1)  
                            
                                // Se o usuario tiver email cadastrado, envia email de aviso com falha na aprovação
                                PswOrder(2) //Ordena pelo nome do usuario a busca
                                If PswSeek(cUserCont) .And. !Empty(PswRet()[1,14])
                                    cMailCont := AllTrim(PswRet()[1,14])        
                                    cMsg := 'Prezado Participante, o contrato No ' + cNumCont + ' foi reprovado com a justificativa: ' + cObserv 
                                    U_WF03Msg('Rejeição de Contrato', cMsg, cMailCont)                  
                                Endif
                            
                            Else
                                // Envia o Workflow para o proximo nivel
                                U_GWF03(cNumCont)
                            Endif

                        EndIf

                    EndIf

                End Transaction

            Endif

        Endif
    
    EndIf
    
Return 

// Envia status com contrato aprovado reprovado
User Function WF03Msg(cTitle, cMsg, cMail)

	Local oPrcMsg := NIL
	Local cArqMsg := ''
    Local cCopia := Alltrim(SuperGetMV('ES_WF03COP',, ''))


    If nRemType == 2 // REMOTE_LINUX
		cArqMsg :='/WEB/TEMPLATE/WFMsg.HTML'
    Else
		cArqMsg := '\WEB\TEMPLATE\WFMsg.HTML'
    Endif

// ---------------------------------------------------------
// Envia e-mail ao comprador notificando a liberacao
// do pedido de compra
// ---------------------------------------------------------
	oPrcMsg := TWFProcess():New('APR_ct', 'Criacao do Processo - Aprovacao de Contratos')
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
