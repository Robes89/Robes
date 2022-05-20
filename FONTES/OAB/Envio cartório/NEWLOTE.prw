#Include 'Totvs.ch'

/*/{Protheus.doc} NEWLOTE
Envio de títulos para cartório
@author Juliano Souza TRIYO
@since 08/2021
@revision Juliano Souza TRIYO
/*/
User Function NEWLOTE()
	FWMsgRun(,{|| NEWLOTE()}, "Aguarde...", "Gerando Arquivo Bordero para Cartorio...")
Return 

Static Function NEWLOTE()
	Local cAlias 			:= GetNextAlias()
	Local lRet 	 			:= .T.
	Local aTit 				:= {}
	Local aBor 				:= {}
	Local cBanco 			:= '001'
	Local cAgencia 			:= '05905'
	Local cConta   			:= '0000310300'
	Local cSituaca 			:= 'H'
	Local cNumBor 			:= ''
	Local lMail   			:= .T.
	Local cArquivo 			:= ''
	Local aCriaServ			:= {}
	Local cIdTrab           := "000004"
	Local cIdPZB			:= ""
	Local cReferenc         := "Nao Executado!"
	Local cMenssagem        := ""
	Local nX				:= 0
	Local lOk				:= .F.
	Local nTotal			:= 0
	Local cAmbiente 		:= Nil
	Local cId				:= "0"
	Local dVencDe   		:= Nil 
	Local dVencAte  		:= Nil
	Local cPrfxDe   		:= Nil
	Local cPrfxAte  		:= Nil
	Local aPergs			:= {}
	Private lMsErroAuto 	:= .F.
	Private lMsHelpAuto 	:= .T.
	Private lAutoErrNoFile 	:= .T.

	********************************************************************************************************************************
	// Premissas:
	// 1 - Manutencoes no Cadastro de Cliente SA1 - White List (A1_XLIST) de Cobranca via Cartorio.
	// 2 - Manutencoes no Contas a Receber SE1 - Cobranca via Cartorio (E1_XCOB)

	// Resultado:
	// 1 - Cria Bordero Especifico para comuncacao via Cartorio.
	// 2 - Monta Arquivo .TXT delimitado, contendo os titulos em aberto, para analise do Financeiro confirmar Cobranca via Cartorio.
	// 3 - Envia Email para area Financeira.
	********************************************************************************************************************************
	If MsgNoYes("Esta rotina ira selecionar Titulos do Contas a Receber" + CRLF + "para envio ao Cartorio!" + CRLF + CRLF + "Confirmar processamento?","Atencao!")

		//Adiciona os parametros para a pergunta
		aAdd( aPergs, {9,"Comunica��o com Cart�rio:",150,7,.T.})
		aAdd( aPergs, {2, "Ambiente"    	, "SP" , {"SP","Outros"}, 60, "", .T.})

		aAdd( aPergs, {9, "Filtro de Trabalho.",150,7,.T.})
		aAdd( aPergs, {1, "Vencimento De:"  , dDATABASE, PesqPict("SE1", "E1_VENCREA"),'naovazio()',"" ,'.T.', 50, .T.})
		aAdd( aPergs, {1, "Vencimento Ate:" , dDATABASE, PesqPict("SE1", "E1_VENCREA"),'naovazio()',"" ,'.T.', 50, .T.}) 
		
		aAdd( aPergs, {1, "Prefixo De:"		, "ANU", "", ".T.", "", ".T.", 80, .T.})
		aAdd( aPergs, {1, "Prefixo Ate:"	, "ANU", "", "naovazio()", "", ".T.", 80, .T.})

		aAdd( aPergs, {9, "Configura��es do Border�.",150,7,.T.})
		aAdd( aPergs, {1, "Banco:"		, Padr(cBanco,TamSx3("A6_COD")[1])	, PesqPict("SA6", "A6_COD"), ".T.", "SA6", ".T.", 80, .T.})
		aAdd( aPergs, {1, "Agencia:"	, Padr(cAgencia,TamSx3("A6_AGENCIA")[1])	, PesqPict("SA6", "A6_AGENCIA"), ".T.", "", ".T.", 80, .T.})
		aAdd( aPergs, {1, "Conta:"		, Padr(cConta,TamSx3("A6_NUMCON")[1])	, PesqPict("SA6", "A6_NUMCON"), ".T.", "", ".T.", 80, .T.})
		
		//Mostra uma pergunta com parambox para filtrar o subgrupo
		If ParamBox(aPergs, "Informe os parametros", , , , , , , , , .F., .F.)
			lOk := .T.
			cAmbiente := MV_PAR02
			dVencDe   := MV_PAR04
			dVencAte  := MV_PAR05
			cPrfxDe   := MV_PAR06
			cPrfxAte  := MV_PAR07
			cBanco    := iif(Empty(MV_PAR09),cBanco,MV_PAR09)
			cAgencia  := iif(Empty(MV_PAR10),cAgencia,MV_PAR10)
			cConta    := iif(Empty(MV_PAR11),cConta,MV_PAR11)
		Endif

		if lOk
			// Seleciona Registros Aptos para Criar um Bordero de Comunicacao com Cartorio.
			If Select(cAlias) > 0
				(cAlias)->(DBCloseArea())
			Endif
			If cAmbiente == "SP"
				cId := "1"
				BeginSql Alias cAlias
					SELECT TOP 10
						E1_FILIAL, 
						E1_PREFIXO, 
						E1_NUM, 
						E1_PARCELA,
						E1_TIPO
					FROM %Table:SE1% (NOLOCK) SE1
					JOIN %Table:SA1% (NOLOCK) SA1 ON SA1.D_E_L_E_T_ != '*' AND SA1.A1_COD = SE1.E1_CLIENTE AND SA1.A1_LOJA = SE1.E1_LOJA AND SA1.A1_EST = %Exp:cAmbiente%
					WHERE SE1.D_E_L_E_T_ != '*'
					AND SE1.E1_NUMBOR = ''
					AND SE1.E1_VENCREA Between %Exp:DToS(dVencDe)% and %Exp:DToS(dVencAte)%
					AND SE1.E1_PREFIXO Between %Exp:cPrfxDe% and %Exp:cPrfxAte%
					AND SE1.E1_SALDO > 0
					AND YEAR(SE1.E1_EMISSAO) <= YEAR(GETDATE())
					AND SE1.E1_XCOB != '1'
					/*AND SE1.E1_XSITC = ''*/
					AND SA1.A1_XLIST != '1'
					ORDER BY E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
				EndSql
				nTotal := Contar(cAlias,"!Eof()")
			Endif
			// Gera Log com a Comunicacao.
			aCriaServ := U_MonitRes(cIdTrab, 1, nTotal )
			cIdPZB 	  := aCriaServ[2]
		Endif

		If nTotal == 0
			cReferenc := "Erro - Sem dados para processamento"
			U_MonitRes(cIdTrab, 2, , cIdPZB, cMenssagem, .F., "Seleção Titulos Bordero Cartorio", cReferenc, "Sem Registros para selecionar...", "", .F., .F.)
			//Finaliza o processo na PZB
			U_MonitRes(cIdTrab, 3, , cIdPZB, , .F.)		
			Alert(cReferenc)
			Return .T.
		Endif

		// Alimenta Array para MsExecAuto - Cirar Bordero
		DbSelectArea("SE1")
		(cAlias)->(DbGoTop())
		While (cAlias)->(!EOF())
			aAdd(aTit,{	{ "E1_FILIAL"  	, (cAlias)->E1_FILIAL 	},;
						{ "E1_PREFIXO" 	, (cAlias)->E1_PREFIXO 	},;
						{ "E1_NUM" 	  	, (cAlias)->E1_NUM 		},;
						{ "E1_PARCELA" 	, (cAlias)->E1_PARCELA 	},;
						{ "E1_TIPO" 	, (cAlias)->E1_TIPO 	}})
			(cAlias)->(dbSkip())
		EndDo
		DbSelectArea("SEA")
		SEA->(DBSetOrder(1))
		SEA->(DbGoTop())

		// Corrige e define numeração
		cNumBor := GETSX8NUM('SEA','EA_NUMBOR')
		While SEA->(DBSeek(xFilial("SEA")+cNumBor))
			ConfirmSx8()
			cNumBor := GETSX8NUM('SEA','EA_NUMBOR')
		End

		//Informacoes bacarias para o Bordero
		aAdd(aBor, { "AUTBANCO"   , PadR(cBanco   ,TamSX3("A6_COD")[1])		})
		aAdd(aBor, { "AUTAGENCIA" , PadR(cAgencia ,TamSX3("A6_AGENCIA")[1]) })
		aAdd(aBor, { "AUTCONTA"   , PadR(cConta   ,TamSX3("A6_NUMCON")[1]) 	})
		aAdd(aBor, { "AUTSITUACA" , PadR(cSituaca ,TamSX3("E1_SITUACA")[1]) })
		aAdd(aBor, { "AUTNUMBOR"  , PadR(cNumBor  ,TamSX3("E1_NUMBOR")[1]) 	}) // Caso não seja passado o número será obtido o próximo pelo padrão do sistema

		
		// Realizar a criacao do bordero para os titulos especificos.
		MSExecAuto({|a, b| FINA060(a, b)}, 3,{aBor,aTit})
		cMenssagem := "Selecao Titulos Bordero: " + cNumBor

		// Com Sucesso, envia email para Area Financeira realizar analises e envio para cartorio.
		If lMsErroAuto
			cStrErro := ""
			aErros 	 := GetAutoGRLog() // retorna o erro encontrado no execauto.
			cStrErro += "[MsExecAuto]" + CRLF
			aEval(aErros, {|l| cStrErro += l + CRLF})
			cStrErro += CRLF + "[Cabecalho]" + CRLF
			aEval(aBor, {|l| cStrErro += l[1] + " = " + cValToChar(l[2]) + CRLF})
			For nX := 1 To Len(aTit)
				cStrErro += CRLF + "[Detalhes-Item"+Alltrim(cValToChar(nX))+"]" + CRLF
				aEval(aTit[nX], {|l| cStrErro += l[1] + " = " + cValToChar(l[2]) + CRLF})
			Next nX
			RollBackSX8()
			cReferenc := "Erro - MsExecAuto"
			U_MonitRes(cIdTrab, 2, , cIdPZB, cMenssagem, .F., "Seleção Titulos Bordero: " + cNumBor, cReferenc, cStrErro, "", .F., .F.)
			//Finaliza o processo na PZB
			U_MonitRes(cIdTrab, 3, , cIdPZB, , .F.)
		Else
			*************************************************
			// Montar Arquivo .TXT com os Titulos do Bordero.
			cArquivo := Anexo(aTit)
			// Envia Email para Area Financeira.
			lMail := EMail(cArquivo, cNumBor, aTit)
			*************************************************
			ConfirmSx8()
			RefreshE1("00", cNumBor) // 00 - Lote Gerado.
			RefreshEA(cNumBor, cId)
			cReferenc := "Bordero Num = " + cNumBor
			U_MonitRes(cIdTrab, 2, , cIdPZB, cMenssagem, .T., "Seleção Titulos Bordero: " + cNumBor, cReferenc, "Sucesso", "", .F., .F.)
			//Finaliza o processo na PZB
			U_MonitRes(cIdTrab, 3, , cIdPZB, , .T.)
		EndIf

		SEA->(DBCloseArea())
		SE1->(DBCloseArea())
		(cAlias)->(DBCloseArea())
	Endif
	ApMsgInfo("Finalizado!" + CRLF + CRLF + cReferenc)
Return lRet

/*/{Protheus.doc} Anexo
Atualiza Status do Titulo fiannceiro.
@author Juliano Souza TRIYO
@since 06/04/2021
@date 28/05/2021
/*/
Static Function Anexo(aDados)

	Local cNomeArq  := "ArqBordero" + Alltrim(Str(YEAR(DATE()))) + Alltrim(Str(MONTH(DATE()))) + Padl(Alltrim(Str(Day(DATE()))),2,"0") + Substr(Time(),1,2) + Substr(Time(),4,2) + Substr(Time(),7,2) + ".XML"
	//Local cLinha    := ''
	Local cPrefixo  := ''
	Local cNum      := ''
	Local cParcela  := ''
	Local cTipo     := ''
	Local oExcel    := FWMSEXCEL():New()
	Local cLocal    := "E:\TOTVS_HML\protheus12\protheus_data\" //"E:\TOTVS\Microsiga\Protheus12\HML\" //GetSrvProfString( "StartPath","" )
	Local cPath     := "Cartorio\"
	Local cCaminho  := cLocal + cPath
	//Local nHandle   := FCREATE(cCaminho + cNomeArq + ".txt")
	Local nX		:= 0
	
	oExcel:AddworkSheet("OABExCar")
	oExcel:AddTable ("OABExCar","Titulos para Cartorio")

	//Cabecalho

	oExcel:AddColumn("OABExCar","Titulos para Cartorio","PREFIXO",1,1)
	oExcel:AddColumn("OABExCar","Titulos para Cartorio","TITULO",1,1)
	oExcel:AddColumn("OABExCar","Titulos para Cartorio","PARCELA",1,2)
	oExcel:AddColumn("OABExCar","Titulos para Cartorio","TIPO",1,2)
	oExcel:AddColumn("OABExCar","Titulos para Cartorio","CLIENTE",1,2)

	//cLinha := "PREFIXO|TITULO|PARCELA|TIPO|CLIENTE"
	//FWrite(nHandle, cLinha + CRLF)

	dbSelectArea("SE1")
	SE1->(dbSetOrder(1))

	For nX := 1 to Len(aDados)

		cPrefixo  := aDados[nX][2][2]
		cNum      := aDados[nX][3][2]
		cParcela  := aDados[nX][4][2]
		cTipo     := aDados[nX][5][2]

		If SE1->(dbSeek(xFilial("SE1")+ AvKey(cPrefixo,"E1_PREFIXO") + AvKey(cNum,"E1_NUM" )+AvKey(cParcela,"E1_PARCELA")))

			cCliente := AllTrim(POSICIONE("SA1",1,xFilial("SA1")+SE1->E1_CLIENTE,"A1_COD"))
			cCliente += " - " + AllTrim(POSICIONE("SA1",1,xFilial("SA1")+SE1->E1_CLIENTE,"A1_NOME"))

			oExcel:AddRow("OABExCar","Titulos para Cartorio", { cPrefixo,;
																cNum ,; 
																cParcela ,; 
																cTipo ,;  
																cCliente})

			//cLinha := cPrefixo + "|" + cNum + "|" + cParcela + "|" + cTipo + "|" + cCliente
			//FWrite(nHandle, cLinha + CRLF)
		Endif 
	Next
	
	//FClose(nHandle)
	
	If !Empty(oExcel:aWorkSheet)

		oExcel:Activate()
		oExcel:GetXMLFile(cNomeArq)

		If ApOleClient( 'MsExcel' ) 
			oExcelApp := MsExcel():New()
			oExcelApp:WorkBooks:Open( cPath + cNomeArq )
			oExcelApp:SetVisible(.T.)
		EndIf
 
		CpyS2T("\SYSTEM\"+cNomeArq, cCaminho)

	EndIf

Return cCaminho + cNomeArq
/*/{Protheus.doc} EMail
Atualiza Status do Titulo fiannceiro.
@author Juliano Souza TRIYO
@since 06/04/2021
@date 28/05/2021
/*/
Static Function EMail(cArq, _cNumBor, _aDados)
   Local lBody     := .T. // Apresenta dados do Array no Corpo do Email?
   Local cBody     := ""
   Local cServer   := GetMV( "MV_RELSERV",,'' )
   Local cAccount  := GetMV( "MV_RELACNT",,'' )
   Local cPassword := GetMV( "MV_RELAPSW",,'' )
   Local cFrom 	 := GetMV( "MV_RELACNT",,'' )
   Local nTimeout  := 240
   Local lAuth     := GetMV( "MV_RELAUTH",,'' )
   Local cTarget   := ""
   Local cProtocol := ""
   Local xRet      := nil
   Local nX        := 0
   Local cProcesso := 'Títulos em Borderô para envio ao Cartório: ' + _cNumBor
   Local cNum      := ''
   Local cPrefixo  := ''
   Local cTipo     := ''
   Local cParcela  := ''
   Local cCliente  := ''
   Local nTotal    := 0
   Local nValor    := 0
   Private oMailManager

   cNome        := "Administrador"
   cTarget      := 'ronaldo.robes@gmail.com' //waiub@oabsp.org.br

   ************************************
   // Monta Corpo do email HTML com os dados do Array.
   If lBody
      cBody := ''

      // HTML
      cBody += '<!DOCTYPE html>' + CRLF
      cBody += '<html>' + CRLF
      cBody += '<head>' + CRLF
      cBody += '<meta charset="utf-8">' + CRLF
      cBody += '<meta name="viewport" content="width=device-width, initial-scale=1">' + CRLF

      // CSS
      cBody += '<style>' + CRLF
      cBody += 'table.paleBlueRows {' + CRLF
      cBody += '  font-family: "Times New Roman", Times, serif;' + CRLF
      cBody += '  border: 1px solid #FFFFFF;' + CRLF
      cBody += '  width: 100%;' + CRLF
      cBody += '  height: auto;' + CRLF
      cBody += '  text-align: center;' + CRLF
      cBody += '  border-collapse: collapse;' + CRLF
      cBody += '}' + CRLF
      cBody += 'table.paleBlueRows td, table.paleBlueRows th {' + CRLF
      cBody += '  border: 0px solid #FFFFFF;' + CRLF
      cBody += '  padding: 3px 2px;' + CRLF
      cBody += '}' + CRLF
      cBody += 'table.paleBlueRows tbody td {' + CRLF
      cBody += '  font-size: 13px;' + CRLF
      cBody += '}' + CRLF
      cBody += 'table.paleBlueRows tr:nth-child(even) {' + CRLF
      cBody += '  background: #D0E4F5;' + CRLF
      cBody += '}' + CRLF
      cBody += 'table.paleBlueRows thead {' + CRLF
      cBody += '  background: #0B6FA4;' + CRLF
      cBody += '  border-bottom: 5px solid #FFFFFF;' + CRLF
      cBody += '}' + CRLF
      cBody += 'table.paleBlueRows thead th {' + CRLF
      cBody += '  font-size: 17px;' + CRLF
      cBody += '  font-weight: bold;' + CRLF
      cBody += '  color: #FFFFFF;' + CRLF
      cBody += '  text-align: center;' + CRLF
      cBody += '  border-left: 2px solid #FFFFFF;' + CRLF
      cBody += '}' + CRLF
      cBody += 'table.paleBlueRows thead th:first-child {' + CRLF
      cBody += '  border-left: none;' + CRLF
      cBody += '}' + CRLF
      cBody += 'table.paleBlueRows tfoot {' + CRLF
      cBody += '  font-size: 14px;' + CRLF
      cBody += '  font-weight: bold;' + CRLF
      cBody += '  color: #333333;' + CRLF
      cBody += '  background: #D0E4F5;' + CRLF
      cBody += '  border-top: 3px solid #444444;' + CRLF
      cBody += '}' + CRLF
      cBody += 'table.paleBlueRows tfoot td {' + CRLF
      cBody += '  font-size: 14px;' + CRLF
      cBody += '}' + CRLF    
      cBody += '</style>' + CRLF
      cBody += '</head>' + CRLF
      cBody += '<body>' + CRLF
      cBody += '<table class="paleBlueRows">' + CRLF
      cBody += '   <thead>' + CRLF
      cBody += '      <tr>' + CRLF
      cBody += '         <th>PREFIXO</th>' + CRLF
      cBody += '         <th>TITULO</th>' + CRLF
      cBody += '         <th>PARCELA</th>' + CRLF
      cBody += '         <th>SALDO</th>' + CRLF
      cBody += '         <th>TIPO</th>' + CRLF
      cBody += '         <th>CLIENTE</th>' + CRLF
      cBody += '         <th>COMARCA</th>' + CRLF
      cBody += '      </tr>' + CRLF
      cBody += '   </thead>' + CRLF
      cBody += '   <tbody>' + CRLF
      For nX := 1 To Len(_aDados)
         cPrefixo  := _aDados[nX][2][2]
         cNum      := _aDados[nX][3][2]
         cParcela  := _aDados[nX][4][2]
         cTipo     := _aDados[nX][5][2]      
         If SE1->(dbSeek(xFilial("SE1")+ AvKey(cPrefixo,"E1_PREFIXO") + AvKey(cNum,"E1_NUM" )+AvKey(cParcela,"E1_PARCELA")))
            cCliente := AllTrim(POSICIONE("SA1",1,xFilial("SA1")+SE1->E1_CLIENTE,"A1_COD"))
            cCliente += " - " + AllTrim(POSICIONE("SA1",1,xFilial("SA1")+SE1->E1_CLIENTE,"A1_NOME"))
            nValor := SE1->E1_SALDO
            nTotal += nValor
            cBody += '      <tr>' + CRLF
            cBody += '         <td>'+cValToChar(cPrefixo)+'</td>' + CRLF
            cBody += '         <td>'+cValToChar(cNum)+'</td>' + CRLF
            cBody += '         <td>'+cValToChar(cParcela)+'</td>' + CRLF
            cBody += '         <td style="text-align: right;">'+Alltrim(Transform(nValor,"@E 999,999,999.99"))+'</td>' + CRLF
            cBody += '         <td>'+cValToChar(cTipo)+'</td>' + CRLF
            cBody += '         <td style="text-align: left;">'+cValToChar(cCliente)+'</td>' + CRLF
            cBody += '         <td style="text-align: left;">'+AllTrim(POSICIONE("SA1",1,xFilial("SA1")+SE1->E1_CLIENTE,"A1_COD_MUN"))+'</td>' + CRLF
            cBody += '      </tr>' + CRLF
         Endif
      Next nX
      cBody += '   </tbody>' + CRLF
      cBody += '   <tfoot>' + CRLF
      cBody += '      <tr>' + CRLF
      cBody += '         <td>Qtd.</td>' + CRLF
      cBody += '         <td>'+cValToChar(Len(_aDados))+'</td>' + CRLF
      cBody += '         <td>&nbsp;</td>' + CRLF
      cBody += '         <td>&nbsp;</td>' + CRLF
      cBody += '         <td>R$:</td>' + CRLF
      cBody += '         <td style="text-align: left;">'+Alltrim(Transform(nTotal,"@E 999,999,999.99"))+'</td>' + CRLF
      cBody += '         <td>&nbsp;</td>' + CRLF
      cBody += '      </tr>' + CRLF
      cBody += '   </tfoot>' + CRLF
      cBody += '</table>' + CRLF
      cBody += '</body>' + CRLF
      cBody += '</html>' + CRLF
   Endif

   ************************************
   // Cria uma Mensagem na Classe TMail
   oMessage := TMailMessage():New()
   oMessage:Clear()
   oMessage:cDate    := cValToChar( Date() )
   oMessage:cFrom    := cAccount
   oMessage:cTo      := cTarGet
   oMessage:cSubject := cProcesso
   oMessage:cBody    := cBody
   oMessage:AddCustomHeader( "Content-Type", 'text/html' )
   oMessage:MsgBodyType( "text/html" )
   oMessage:AttachFile(cArq)
   
   // Tenta anexar Arquivo a Mensagem de Email
   //if xRet < 0
   //   cMsg := "Erro ao anexar arquivo " + CRLF + cArq
   //   MsgStop( cMsg )
   //   return
   //endif
   ************************************
   // Realizar comunicação SMTP/POP para Envio do Email.
   oServer := tMailManager():New()
   oServer:SetUseTLS( .F. )
   cServer := Substr(cServer,1,18)   

   // Valida Inicio do Servidor de Disparos.
   xRet := oServer:Init( "", cServer, cFrom, cPassword, 0, 25 )
   If xRet != 0
      MsgStop("Nao foi possivel iniciar Servidor SMTP: " + CRLF + oServer:GetErrorString( xRet ))
      Return   
   endif

   // Valida Timeout de Comunicação.   
   xRet := oServer:SetSMTPTimeout( nTimeout )
   if xRet != 0
      MsgStop("Nao configurado " + cProtocol + " timeout: " + cValToChar( nTimeout ))
      Return   
   endif

   // Valida Conexão do Servidor de Disparo.
   xRet := oServer:SMTPConnect()
   if xRet != 0
      MsgStop("Nao foi possivel connectar em Servidor SMTP: " + CRLF + oServer:GetErrorString( xRet ))
      Return   
   endif

   // Realiza Autenticação no Servidor de Dispardo
   If lAuth   
      xRet := oServer:SmtpAuth( cFrom, cPassword )
      if xRet != 0
         MsgStop("Nao foi possivel autenticar Servidor SMTP: " + CRLF + oServer:GetErrorString( xRet ))
         oServer:SMTPDisconnect()
         Return   
      endif
   EndIf

   // Realiza o Envio da Mensgem utilizando o Servidor de Disparo Conectado.
   xRet := oMessage:Send( oServer )
   if xRet != 0
      cMsg := "Could not send message: " + oServer:GetErrorString( xRet )
      MsgStop("Não foi possível enviar mensagem: " + CRLF + oServer:GetErrorString( xRet ))
   endif

   // Disconecta do Servidor de Disparo.
   Ret := oServer:SMTPDisconnect()

Return(.T.)

/*/{Protheus.doc} RefreshE1
Atualiza Status do Titulo fiannceiro.
@author Juliano Souza TRIYO
@since 06/04/2021
@date 28/05/2021
/*/
Static Function RefreshE1(cSts, cNumbor)
	Local cSql := ""
	
	cSql += "UPDATE " + RetSqlName("SE1")
	cSql += " SET E1_XSITC = '"+ cSts +"'"
	cSql += " WHERE D_E_L_E_T_ != '*'"
	cSql += " AND E1_FILIAL = '"+ xFilial("SE1") +"'"
	cSql += " AND E1_NUMBOR = '"+ cNumbor +"'"

	TcSqlExec(cSql)
Return

/*/{Protheus.doc} RefreshEA
Atualiza Status do Titulo fiannceiro.
@author Juliano Souza TRIYO
@since 06/04/2021
@date 28/05/2021
/*/
Static Function RefreshEA(cNumbor,cId)
	Local cSql := ""
	
	cSql += "UPDATE " + RetSqlName("SEA")
	cSql += " SET E1_XCARTID = '"+ cId +"'"
	cSql += " WHERE D_E_L_E_T_ != '*'"
	cSql += " AND EA_FILIAL = '"+ xFilial("SEA") +"'"
	cSql += " AND EA_NUMBOR = '"+ cNumbor +"'"

	TcSqlExec(cSql)
Return
