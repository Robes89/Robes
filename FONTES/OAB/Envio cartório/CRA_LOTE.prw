#INCLUDE 'TOTVS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FILEIO.CH'

/*/{Protheus.doc} CRALOTE
Envio de tÃ­tulos para cartÃ³rio
@author Juliano Souza TRIYO
@since 24/03/2021
@revision Juliano Souza TRIYO
@date 25/05/2021
/*/
User Function CRALOTE(lAuto, nOperation, aRefs)
	Local lOk       := .T.
	Local cError    := ""   
	Local cWarning  := ""
	Local cSession	:= ""
	Local cUser		:= "apbgoadm"
	Local cKey		:= "testecra"
	Local cNomeArq  := ''
	Local cXml      := ''
	Local cSeq 	    := 0
	Local cValTot   := 0
	Local cAlias1 	:= GetNextAlias()
	Local cAlias2 	:= GetNextAlias()
	Local aComplex  := {}
	Local aSimple   := {}
	Local oWS	    := nil
	Local oResult   := nil
	Local oPARSE    := nil
	Local lResp     := .F.
	Local cIdTrab   := "000004"
	Local cCodUF    := "SP"
	Local cCodEst   := iif(cCodUF=="SP","35","")
	Local cCodMun   := "" //"50308"
	Local cComarca  := "" //cCodEst + cCodMun
	Local cMenssagem := ""
	Local nHandle2		:= 0 
	Local cIdPZB    := ""
	Local aCriaServ := {}
	Local cUrl 		:= "https://homologcra.protesto.com.br/cra/webservice/protesto_v2.php?wsdl"
	Local cFileArq  := "Bordero_Cartorio"
	Local cLocal    := "E:\TOTVS_HML\protheus12\protheus_data\" //"E:\TOTVS\Microsiga\Protheus12\HML\" //GetSrvProfString( "StartPath","" )
	Local cPath     := "Cartorio\"
	Local cCaminho  := cLocal + cPath
	Local cAlisDev := GetNextAlias()
	Local nHandle   := nil	
	Local cRequest  := ""
	Local Arqv      := ""
	Local cSeqCart  := nil
	Local oMyRef    := nil
	Local lRet 		:= .T.
	Local cCodMun	:= ''
	Local cGrava := 'C:\temp\teste.txt'
	lOCAL lFIRST := .T.
	Default lAuto		:= .F.
	Default nOperation  := 0
	Default aRefs   	:= {} 

	if lAuto
		RpcClearEnv()
		RpcSetType(3)
		RpcSetEnv("01","01000101")
	Endif

	cSeqCart  := Val(GetMV("MV_OABCART"))

	if lOk		
		
	
		
		oWS := TWsdlManager():New()
		oWS:lVerbose := .T.
		oWS:ParseURL(cUrl)
		oWS:SetOperation("Remessa")

		//Informo o usuario e senha via basic em base64 no header da requisicao
		oWS:AddHttpHeader("Authorization", "Basic " + Encode64(cUser+":"+cKey))
		oWS:bNoCheckPeerCert := .T.

		aComplex    := oWS:NextComplex()
		aSimple     := oWS:SimpleInput()

		// Seleciona Registros do Bordero para Envio ao Cartorio.
		If Select(cAlias2) > 0
			(cAlias2)->(DBCloseArea())
		Endif

		BeginSql Alias cAlias2
			SELECT 	SE1.*, 
					SA1.*,
					SEA.*,
					CC2.*,
					SE1.R_E_C_N_O_ As RECNOE1
			FROM %Table:SE1% SE1
				JOIN %Table:SA1% SA1 ON SA1.D_E_L_E_T_ != '*' AND SA1.A1_XLIST <> '1' AND SA1.A1_COD = SE1.E1_CLIENTE AND SA1.A1_LOJA = SE1.E1_LOJA AND SA1.A1_EST = %Exp:cCodUF%
				JOIN %Table:SEA% SEA ON SEA.D_E_L_E_T_ != '*' AND SEA.EA_NUMBOR = SE1.E1_NUMBOR AND SEA.EA_PREFIXO = SE1.E1_PREFIXO AND SEA.EA_NUM = SE1.E1_NUM AND SEA.EA_PARCELA = SE1.E1_PARCELA
				JOIN %Table:CC2% CC2 ON CC2.D_E_L_E_T_ != '*' AND CC2.CC2_EST = SA1.A1_EST and CC2.CC2_CODMUN = SA1.A1_COD_MUN
			WHERE SE1.D_E_L_E_T_ != '*'				
				AND SE1.E1_NUMBOR != ''
				AND SE1.E1_XSITC = '01' // Lotes Somente Titulos Confirmado
			ORDER BY SA1.A1_COD_MUN
		EndSql

		BeginSql Alias cAlisDev
			SELECT 	COUNT(SA1.A1_COD_MUN) CODMUN
			FROM %Table:SE1% SE1
				JOIN %Table:SA1% SA1 ON SA1.D_E_L_E_T_ != '*' AND SA1.A1_XLIST <> '1' AND SA1.A1_COD = SE1.E1_CLIENTE AND SA1.A1_LOJA = SE1.E1_LOJA AND SA1.A1_EST = %Exp:cCodUF%
			WHERE SE1.D_E_L_E_T_ != '*'				
				AND SE1.E1_NUMBOR != ''
				AND SE1.E1_XSITC = '01' // Lotes Somente Titulos Confirmado
			GrOUP BY SA1.A1_COD_MUN	
			ORDER BY SA1.A1_COD_MUN
		EndSql
		nTot := Contar(cAlias2,"!Eof()")
		If nTot == 0
			Return .F.
		Endif
		
	
		
		// Gera Log com a Comunicacao.
		aCriaServ := U_MonitRes(cIdTrab, 1, nTot )
		cIdPZB 	  := aCriaServ[2]		

		cSeq++

		cData := Alltrim(Str(Day(Date())))+padl(Alltrim(Str(Month(Date()))),2,'0')+Alltrim(Str(Year(Date())))
		
		//Montagem do campo 'Arquivo' - UTF-8
		cXml := '&lt;?xml version=&quot;1.0&quot; encoding=&quot;ISO-8859-1&quot; standalone=&quot;no&quot;?&gt;' + CRLF
		***********************************************************************************************
		If nOperation == 1 // Remessa
			(cAlias2)->(DbGoTop())
			(cAlisDev)->(DbGoTop())

			cNumBor := (cAlias2)->E1_NUMBOR
			cSeqCart := alltrim((cAlias2)->CC2_CODANP)
			While (cAlias2)->(!Eof())
				
				IF cCodMun <> (cAlias2)->A1_COD_MUN
					IF lFIRST
					cNomeArq := 'B'
					cNomeArq += 'BGO'
					cNomeArq += padl(Alltrim(Str(Day(Date()))),2,'0')
					cNomeArq += padl(Alltrim(Str(Month(Date()))),2,'0')
					cNomeArq += "."
					cNomeArq += Right(Str(Year(Date())),2)
					cNomeArq += '1'
					lFIRST := .F.
					cXml += '&lt;remessa&gt;' + CRLF
					Else
						 cSeq++
						cXml += '&lt;tl '  
						cXml += '	t01=&quot;' + '9' + '&quot; ' 														// Identificar o registro trailler no arquivo. Constante 9.
						cXml += '	t02=&quot;' + 'BGO' + '&quot; ' 													// Identificar o cÃ³digo do banco/portador
						cXml += '	t03=&quot;' + 'ORDEM DOS ADVOGADOS DO BRASIL  SECCAO DE SAO PAULO.' + '&quot; '  	// Preencher com o nome do portador (â€œRazÃ£o Socialâ€� ). 
						cXml += '	t04=&quot;' + cData + '&quot; '  													// Identificar a data de envio do arquivo de Remessa ao ServiÃ§o de DistribuiÃ§Ã£o, no
						cXml += '	t05=&quot;' + Alltrim(Str(cSeq)) + '&quot; '  										// Informar o somatÃ³rio dos registros. Conforme regra estabelecida para os campos do
						cXml += '	t06=&quot;' + Alltrim(Transform(cValTot,"999999.99")) + '&quot; '  					// Informar o somatÃ³rio dos Saldos dos TÃ­tulos
						cXml += '	t07=&quot;' + '' + '&quot; '  														// BRANCOS
						cXml += '	t08=&quot;' + Padl(Alltrim(Transform(cSeq,"9999")),4,'0') + '&quot; '  				// Informar o nÃºmero seqÃ¼encial do registro, limitado a 2.300, por disquete, pois para 
						cXml += ' /&gt;' + CRLF
						cXml += '	&lt;/comarca&gt;' + CRLF
						cValtot := 0 
						cSeq := 1
						cSeqCart := alltrim((cAlias2)->CC2_CODANP)
					endif
					***********************************************************************************************
				
					//Header
				
					cXml += 	'&lt;comarca ' 
					cXml += 		'CodMun=&quot;35'+(cAlias2)->A1_COD_MUN+'&quot;&gt;' + CRLF
					cSeqCart := Soma1(cSeqCart)
					cXml += 		'&lt;hd ' 
					cXml += 		'h01=&quot;' + '0' + '&quot; '  												// Identificar o registro header no arquivo.Constante 0
					cXml += 		'h02=&quot;' + 'BGO' + '&quot; ' 												// Identificar o cÃ³digo do banco/portador
					cXml += 		'h03=&quot;' + 'ORDEM DOS ADVOGADOS DO BRASIL SECCAO DE SAO PAULO' + '&quot; '  // Preencher com o nome do portador (â€œRazÃ£o Socialâ€� ). 
					cXml += 		'h04=&quot;' + cData + '&quot; '  												// Identificar a data de envio do arquivo de Remessa
					cXml += 		'h05=&quot;' + 'BFO' + '&quot; '  												// Preencher com a sigla do remetente do arquivo: BFO â€“ Banco, InstituiÃ§Ã£o Financeira
					cXml += 		'h06=&quot;' + 'SDT' + '&quot; ' 												// Preencher com a sigla do destinatÃ¡rio do arquivo: SDT â€“ ServiÃ§o de DistribuiÃ§Ã£o de
					cXml += 		'h07=&quot;' + 'TPR' + '&quot; '  												// Preencher com a sigla de identificaÃ§Ã£o da transaÃ§Ã£o: TPR â€“ Remessa de tÃ­tulos para
					cXml += 		'h08=&quot;' + Alltrim(cValToChar(cSeqCart)) + '&quot; '  						// Controlar o seqÃ¼encial de remessas, que deverÃ¡ ser contÃ­nuo. 
					cXml += 		'h09=&quot;' + Alltrim(cValToChar((cAlisDev)->CODMUN)) + '&quot; '  							// Preencher com o somatÃ³rio da quantidade de registros constantes no registro de
					cXml += 		'h10=&quot;' + '1' + '&quot; '  												// Preencher com o somatÃ³rio da quantidade de Registros constantes no arquivo
					cXml += 		'h11=&quot;' + '' + '&quot; ' 													// Preencher com o somatÃ³rio da quantidade de tÃ­tulos do tipo â€œDMIâ€� ,â€œDRIâ€� e â€œCBIâ€�
					cXml += 		'h12=&quot;' + '1' + '&quot; ' 													// Preencher com o somatÃ³rio da quantidade dos demais tÃ­tulos
					cXml += 		'h13=&quot;' + '' + '&quot; '  													// Identificar a AgÃªncia Centralizadora - Uso do Banco. 
					cXml += 		'h14=&quot;' + '43' + '&quot; ' 						 						// IdentificaÃ§Ã£o da versÃ£o vigente do layout. Esta refere-se Ã  043. Este campo nÃ£o
					cXml += 		'h15=&quot;' + '35'+(cAlias2)->A1_COD_MUN+ '&quot; '  											// Preencher 2 dÃ­gitos para o CÃ³digo da Unidade da FederaÃ§Ã£o e 5 para o CÃ³digo doMunicÃ­pio
					cXml += 		'h16=&quot;' + ' ' + '&quot; ' 													// Ajustar o tamanho do registro header com o tamanho do registro de transaÃ§Ã£o. preencher com brancos
					cXml += 		'h17=&quot;' + Padl(Alltrim(Transform(cSeq,"9999")),4,'0') + '&quot; '  		// Constante 0001. Sempre reiniciar a contagem do lote de registro para as praÃ§asimplantadas no processo de centralizaÃ§Ã£o. 
					cXml += ' 		/&gt;' + CRLF
					cCodMun := (cAlias2)->A1_COD_MUN
					(cAlisDev)->(dbSkip())
					DBSelectArea("CC2")
					DBSetOrder(1)
					if DBSeek((cAlias2)->CC2_FILIAL +(cAlias2)->CC2_EST +(cAlias2)->CC2_CODMUN  )
						Reclock("CC2",.F.)
							CC2->CC2_CODANP := cSeqCart
						CC2->(Msunlock())
					EndIf
				Endif
			
				If cSeq  > 0 	
					cMenssagem := "Cartorio Titulos Bordero: " + (cAlias2)->E1_NUMBOR
					Arqv := cCaminho + cFileArq + "_" + (cAlias2)->E1_NUMBOR + "_" + FWTimeStamp(1) + ".txt"
					//nHandle := FCREATE(Arqv)
					IF nHandle2 <= 0 
						nHandle2 := FCREATE(cGrava) 
					EndIf	
				endif	
				cSeq++
				// Obtem documento Impresso convertido em Base64.
				cCertCred := u_Certcred((cAlias2)->E1_FILIAL + (cAlias2)->E1_PREFIXO + (cAlias2)->E1_NUM + (cAlias2)->E1_PARCELA + (cAlias2)->E1_TIPO )
				//TransaÃ§Ãµes
				cXml += '&lt;tr ' 
				cXml += 	't01=&quot;' + '1' + '&quot; ' 													 // Identificar o Registro TransaÃ§Ã£o no arquivo. Constante 1
				cXml += 	't02=&quot;' + 'BGO' + '&quot; '  												 // dentificar o cÃ³digo do banco/portador. 
				cXml += 	't03=&quot;' + '00319' + '&quot; '  											 // AgÃªncia / CÃ³digo do Cedente
				cXml += 	't04=&quot;' + 'ORDEM DOS ADVOGADOS DO BRASIL  SECCAO DE SAO PAULO' + '&quot; '  // Nome do Cedente/Favorecido
				cXml += 	't05=&quot;' + 'ORDEM DOS ADVOGADOS DO BRASIL  SECCAO DE SAO PAULO' + '&quot; '  // Identificar o Sacador/Vendedor. 
				cXml += 	't06=&quot;' + '43419613000170' + '&quot; '  									 // Documento do Sacador 
				cXml += 	't07=&quot;' + 'PRACA DA SE, 385 - SE, SAO PAULO' + '&quot; ' 					 // Identificar o endereÃ§o do Sacador/Vendedor. 
				cXml += 	't08=&quot;' + '01001902' + '&quot; '  											 // Identificar o CEP do Sacador/Vendedor. 
				cXml += 	't09=&quot;' + 'SAO PAULO' + '&quot; ' 											 // Identificar a cidade do Sacador/Vendedor. 
				cXml += 	't10=&quot;' + 'SP' + '&quot; ' 												 // Identificar a Unidade da FederaÃ§Ã£o do Sacador/Vendedor. 
				cXml += 	't11=&quot;' + Alltrim((cAlias2)->E1_NUMBOR) + '&quot; ' // E1_NUM?				 // Identificar o tÃ­tulo do cedente 
				cXml += 	't12=&quot;' + 'CCO' + '&quot; ' 												 // ESPECIE TO TITULO(??????)
				cXml += 	't13=&quot;' + Alltrim((cAlias2)->E1_NUM) + '&quot; ' 							 // NÃšMERO DO TÃ�TULO
				cXml += 	't14=&quot;' + Padl(Alltrim(Str(Day(Stod((cAlias2)->E1_EMISSAO)))),2,'0') +padl(Alltrim(Str(Month(Stod((cAlias2)->E1_EMISSAO)))),2,'0')+Alltrim(Str(Year(Stod((cAlias2)->E1_EMISSAO)))) + '&quot; ' //EMISSÃƒO
				cXml += 	't15=&quot;' + Padl(Alltrim(Str(Day(Stod((cAlias2)->E1_VENCREA)))),2,'0')+padl(Alltrim(Str(Month(Stod((cAlias2)->E1_VENCREA)))),2,'0')+Alltrim(Str(Year(Stod((cAlias2)->E1_VENCREA)))) + '&quot; '  //VENCIMENTO
				cXml += 	't16=&quot;' + '001' + '&quot; '  												 // Identificar o tipo de moeda corrente - 001 â€“ Real
				cXml += 	't17=&quot;' + Alltrim(Transform((cAlias2)->E1_SALDO,"999999.99")) + '&quot; '    // VALOR DO TÃ�TULO
				cXml += 	't18=&quot;' + Alltrim(Transform((cAlias2)->E1_SALDO,"999999.99")) + '&quot; '    // SALDO
				cXml += 	't19=&quot;' +  (cAlias2)->CC2_MUN + '&quot; ' 										 // Informar a praÃ§a que o tÃ­tulo deverÃ¡ ser protestado
				cXml += 	't20=&quot;' + '' + '&quot; ' 													 // Identificar o tipo de endosso do tÃ­tulo:
				cXml += 	't21=&quot;' + '' + '&quot; ' 													 // Informar ao CartÃ³rio se o tÃ­tulo foi aceito pelo devedor:
				cXml += 	't22=&quot;' + '1' + '&quot; ' 													 // dentificar a quantidade de devedor(es) ou endereÃ§os(s) complementar(es) do tÃ­tulo. 
				cXml += 	't23=&quot;' + NoAcento(Alltrim((cAlias2)->A1_NOME)) + '&quot; ' 				 // Identificar o nome do devedor 
				cXml += 	't24=&quot;' + Alltrim(Iif((cAlias2)->A1_PESSOA =='J','001','002')) + '&quot; '   // Identificar o tipo de documento do devedor: 001 â€“ CNPJ 002 â€“ CPF ou Zeros
				cXml += 	't25=&quot;' + Alltrim((cAlias2)->A1_CGC) + '&quot; ' 							 // Identificar o nÃºmero do documento do devedor. 
				cXml += 	't26=&quot;' + Alltrim((cAlias2)->A1_PFISICA) + '&quot; ' 						 // Identificar o nÃºmero do documento do devedor.  RG
				cXml += 	't27=&quot;' + NoAcento(Alltrim(SA1->A1_END))  + '&quot; ' 						 // Identificar o endereÃ§o do devedor 
				cXml += 	't28=&quot;' + Alltrim((cAlias2)->A1_CEP) + '&quot; ' 							 // Identificar o CEP do devedor 
				cXml += 	't29=&quot;' + NoAcento(Alltrim(SA1->A1_MUN)) + '&quot; ' 						 // Identificar a cidade do devedor 
				cXml += 	't30=&quot;' + Alltrim((cAlias2)->A1_EST) + '&quot; ' 							 // dentificar a UF do devedor
				cXml += 	't31=&quot;' + '0' + '&quot; ' 													 // Uso restrito do ServiÃ§o de DistribuiÃ§Ã£o. Preencher com zeros. 
				cXml += 	't32=&quot;' + ' ' + '&quot; ' 													 // Uso restrito do ServiÃ§o de DistribuiÃ§Ã£o. Preencher com brancos. 
				cXml += 	't33=&quot;' + ' ' + '&quot; ' 													 // Uso restrito do ServiÃ§o de DistribuiÃ§Ã£o. Preencher com brancos.
				cXml += 	't34=&quot;' + '0' + '&quot; ' 													 // Uso restrito do ServiÃ§o de DistribuiÃ§Ã£o. Preencher com zeros
				cXml += 	't35=&quot;' + '0' + '&quot; ' 													 // Uso restrito do ServiÃ§o de DistribuiÃ§Ã£o. Preencher com zeros. 
				cXml += 	't36=&quot;' + 'I' + '&quot; ' 													 // DeclaraÃ§Ã£o do Portador  (??????)
				cXml += 	't37=&quot;' + '0' + '&quot; ' 													 // Uso restrito do ServiÃ§o de DistribuiÃ§Ã£o. Preencher com zeros. 
				cXml += 	't38=&quot;' + '0' + '&quot; ' 													 // Uso restrito do ServiÃ§o de DistribuiÃ§Ã£o. Preencher com zeros. 
				cXml += 	't39=&quot;' + NoAcento(Alltrim((cAlias2)->A1_BAIRRO)) + '&quot; ' 				 // Identificar a bairro do devedor 
				cXml += 	't40=&quot;' + '0' + '&quot; '  												 // Uso restrito do ServiÃ§o de DistribuiÃ§Ã£o. Preencher com zeros 
				cXml += 	't41=&quot;' + '0' + '&quot; ' 													 // Uso restrito do 7Âº OfÃ­cio do Rio de Janeiro. Preencher com zeros 
				cXml += 	't42=&quot;' + '0' + '&quot; ' 													 // Uso restrito da Centralizadora de Remessa de Arquivos (CRA). Preencher com 
				cXml += 	't43=&quot;' + '0' + '&quot; ' 													 // Identificar o nÃºmero da operaÃ§Ã£o â€“ exclusivo para protesto de letra de cÃ¢mbio. O
				cXml += 	't44=&quot;' + '0' + '&quot; ' 													 // 0
				cXml += 	't45=&quot;' + '0' + '&quot; ' 													 // 0
				cXml += 	't46=&quot;' + '' + '&quot; ' 													 // BRANCOS
				cXml += 	't47=&quot;' + ' ' + '&quot; '                                                   // BRANCOS
				cXml += 	't48=&quot;' + ' ' + '&quot; '  												 // BRANCOS
				cXml += 	't49=&quot;' + '' + '&quot; ' 													 // BRANCOS
				cXml += 	't50=&quot;' + '0' + '&quot; ' 													 // 0
				cXml += 	't51=&quot;' + cCertCred + '&quot; '											 // Remessa Impressa
				cXml += 	't52=&quot;' + Padl(Alltrim(Transform(cSeq,"9999")),4,'0') + '&quot;' 		 	 // NÃºmero seqÃ¼encial do registro no arquivo, independentemente da quantidade de
				cXml += ' /&gt;' + CRLF

				cValtot += (cAlias2)->E1_SALDO

				(cAlias2)->(DbSkip())
			EndDo

			//Trailer
			cSeq++
			cXml += '&lt;tl '  
			cXml += '	t01=&quot;' + '9' + '&quot; ' 														// Identificar o registro trailler no arquivo. Constante 9.
			cXml += '	t02=&quot;' + 'BGO' + '&quot; ' 													// Identificar o cÃ³digo do banco/portador
			cXml += '	t03=&quot;' + 'ORDEM DOS ADVOGADOS DO BRASIL  SECCAO DE SAO PAULO.' + '&quot; '  	// Preencher com o nome do portador (â€œRazÃ£o Socialâ€� ). 
			cXml += '	t04=&quot;' + cData + '&quot; '  													// Identificar a data de envio do arquivo de Remessa ao ServiÃ§o de DistribuiÃ§Ã£o, no
			cXml += '	t05=&quot;' + Alltrim(Str(cSeq)) + '&quot; '  										// Informar o somatÃ³rio dos registros. Conforme regra estabelecida para os campos do
			cXml += '	t06=&quot;' + Alltrim(Transform(cValTot,"999999.99")) + '&quot; '  					// Informar o somatÃ³rio dos Saldos dos TÃ­tulos
			cXml += '	t07=&quot;' + '' + '&quot; '  														// BRANCOS
			cXml += '	t08=&quot;' + Padl(Alltrim(Transform(cSeq,"9999")),4,'0') + '&quot; '  				// Informar o nÃºmero seqÃ¼encial do registro, limitado a 2.300, por disquete, pois para 
			cXml += ' /&gt;' + CRLF

			//Fechamento comarca
			cXml += '	&lt;/comarca&gt;' + CRLF
			//Fechamento pacote
			cXml += '&lt;/remessa&gt;'
			***********************************************************************************************
		ElseIf nOperation == 3 // Cancelamento
			// DP  = Constante â€“ Identifica tratar-se de arquivo gerado pelo portador.
			// CCC = CÃ³digo de CompensaÃ§Ã£o do Banco/Portador
			// DD  = Dia do envio do Arquivo SustaÃ§Ã£o / Cancelamento ao CartÃ³rio Distribuidor de TÃ­tulos.
			// MM  = MÃªs do envio do Arquivo SustaÃ§Ã£o / Cancelamento ao CartÃ³rio Distribuidor de TÃ­tulos.
			// AA  = Ano do envio do Arquivo SustaÃ§Ã£o / Cancelamento ao CartÃ³rio Distribuidor de TÃ­tulos.
			// S   = NÃºmero SeqÃ¼encial da SustaÃ§Ã£o / Cancelamento â€“ Identifica o nÃºmero da SustaÃ§Ã£o / Cancelamento que estÃ¡ sendo enviada. 

			cNomeArq := 'DP'
			cNomeArq += 'BGO'
			cNomeArq += padl(Alltrim(Str(Day(Date()))),2,'0')
			cNomeArq += padl(Alltrim(Str(Month(Date()))),2,'0')
			cNomeArq += "."
			cNomeArq += Right(Str(Year(Date())),2)
			cNomeArq += '1'
			***********************************************************************************************
			cXml += '&lt;sustacao&gt;' + CRLF
			cXml += 	'&lt;comarca ' 
			cXml += 		'CodMun=&quot;'+cComarca+'&quot;&gt;' + CRLF

			//Header do Apresentante
			cXml += 		'&lt;hdb ' 
			cXml += 		'h01=&quot;' + '0' + '&quot; '  												// IdentificaÃ§Ã£o do Registro (constante 0)
			cXml += 		'h02=&quot;' + 'BGO' + '&quot; ' 												// CÃ³digo do Apresentante
			cXml += 		'h03=&quot;' + 'ORDEM DOS ADVOGADOS DO BRASIL SECCAO DE SAO PAULO' + '&quot; '  // Nome do Apresentante  
			cXml += 		'h04=&quot;' + cData + '&quot; '  												// Data do Movimento
			cXml += 		'h05=&quot;' + Alltrim(cValToChar(nTot)) + '&quot; '  							// Quantidade de DesistÃªncias / Cancelamentos
			cXml += 		'h06=&quot;' + Alltrim(cValToChar(nTot)) + '&quot; ' 							// Quantidade de Registros Tipo 2 
			cXml += 		'h07=&quot;' + 'TPR' + '&quot; '  												// Reservado 
			cXml += 		'h08=&quot;' + Padl(Alltrim(Transform(cSeq,"99999")),5,'0') + '&quot; '  	    // Controle - SequÃªncia do Registro  (constante 00001)
			cXml += ' 		/&gt;' + CRLF	

			//Header do Cartorio
			cSeq++
			cXml += 		'&lt;hdc ' 
			cXml += 		'h01=&quot;' + '1' + '&quot; '  												// IdentificaÃ§Ã£o do Registro (constante 1)
			cXml += 		'h02=&quot;' + 'BGO' + '&quot; ' 												// CÃ³digo do CartÃ³rio
			cXml += 		'h03=&quot;' + Alltrim(cValToChar(nTot)) + '&quot; '  							// Quantidade de DesistÃªncias / Cancelamentos 
			cXml += 		'h04=&quot;' + Alltrim(SA1->A1_COD_MUN) + '&quot; '  							// CÃ³digo do Municipio 
			cXml += 		'h05=&quot;' + '' + '&quot; '  													// Reservado 
			cXml += 		'h06=&quot;' + Padl(Alltrim(Transform(cSeq,"99999")),5,'0') + '&quot; '  	    // Controle - SequÃªncia do Registro 
			cXml += ' 		/&gt;' + CRLF	

			// Registros dos Pedidos de DesistÃªncia de Protesto
			(cAlias2)->(DbGoTop())
			While (cAlias2)->(!Eof())
				cSeq++
				//TransaÃ§Ãµes
				cXml += '&lt;tr ' 
				cXml += 	't01=&quot;' + '2' + '&quot; ' 													 // Identificar o Registro TransaÃ§Ã£o no arquivo. (constante 2)
				cXml += 	't02=&quot;' + '' + '&quot; '  												 	 // NÃºmero do Protocolo 
				cXml += 	't03=&quot;' + '' + '&quot; '  											 		 // Data de Protocolagem
				cXml += 	't04=&quot;' + Alltrim((cAlias2)->E1_NUM) + '&quot; '  							 // NÃºmero do TÃ­tulo
				cXml += 	't05=&quot;' + NoAcento(Alltrim((cAlias2)->A1_NOME)) + '&quot; '  				 // Nome do Primeiro Devedor 
				cXml += 	't06=&quot;' + Alltrim(Transform((cAlias2)->E1_SALDO,"999999.99")) + '&quot; '  	 // Valor do TÃ­tulo 
				cXml += 	't07=&quot;' + 'C' + '&quot; ' 													 // solicitaÃ§Ã£o de sustaÃ§Ã£o/cancelamento - SolicitaÃ§Ã£o de Cancelamento de OperaÃ§Ã£o do Banco(C) ou - SolicitaÃ§Ã£o de Cancelamento de TÃ­tulos de Terceiros (T) 
				cXml += 	't08=&quot;' + '00319' + '&quot; '  											 // agÃªncia/conta. 
				cXml += 	't09=&quot;' + Alltrim((cAlias2)->E1_NUMBOR) + '&quot; ' 						 // carteira/nosso nÃºmero 
				cXml += 	't10=&quot;' + '' + '&quot; ' 												 	 // Reservado
				cXml += 	't11=&quot;' + '' + '&quot; ' 													 // NÃºmero de Controle de Recebimento (nÃ£o utilizar)
				cXml += 	't12=&quot;' + Padl(Alltrim(Transform(cSeq,"99999")),5,'0') + '&quot;' 		     // NÃºmero seqÃ¼encial do registro no arquivo, independentemente da quantidade de
				cXml += ' /&gt;' + CRLF
				cValtot += (cAlias2)->E1_SALDO
				(cAlias2)->(DbSkip())
			End

			//Trailer do Cartorio
			cSeq++
			cXml += '&lt;tlc '  
			cXml += '	t01=&quot;' + '8' + '&quot; ' 														// Identificar o registro trailler no arquivo. (Constante 8)
			cXml += '	t02=&quot;' + '' + '&quot; '  														// NÃºmero do CartÃ³rio 
			cXml += '	t03=&quot;' + Alltrim(Str(cSeq)) + '&quot; '  										// Informar o somatÃ³rio das linhas
			cXml += '	t04=&quot;' + '' + '&quot; '  														// Reservado
			cXml += '	t05=&quot;' + Padl(Alltrim(Transform(cSeq,"99999")),5,'0') + '&quot; '  			// Informar o nÃºmero seqÃ¼encial do registro, limitado a 2.300, por disquete, pois para 
			cXml += ' /&gt;' + CRLF

			//Trailer do Apresentante
			cSeq++
			cXml += '&lt;tlb '  
			cXml += '	t01=&quot;' + '9' + '&quot; ' 														// Identificar o registro trailler no arquivo. (Constante 9)
			cXml += '	t02=&quot;' + 'BGO' + '&quot; ' 													// CÃ³digo do Apresentante 
			cXml += '	t03=&quot;' + 'ORDEM DOS ADVOGADOS DO BRASIL  SECCAO DE SAO PAULO.' + '&quot; '  	// Nome do Apresentante 
			cXml += '	t04=&quot;' + cData + '&quot; '  													// Data do Movimento
			cXml += '	t05=&quot;' + Alltrim(Str(cSeq)) + '&quot; '  										// Informar o somatÃ³rio dos registros. Conforme regra estabelecida para os campos do
			cXml += '	t06=&quot;' + Alltrim(Transform(cValTot,"999999.99")) + '&quot; '  					// Informar o somatÃ³rio dos Saldos dos TÃ­tulos
			cXml += '	t07=&quot;' + '' + '&quot; '  														// Reservado
			cXml += '	t08=&quot;' + Padl(Alltrim(Transform(cSeq,"99999")),5,'0') + '&quot; '  				// Informar o nÃºmero seqÃ¼encial do registro, limitado a 2.300, por disquete, pois para 
			cXml += ' /&gt;' + CRLF

			//Fechamento comarca
			cXml += '	&lt;/comarca&gt;' + CRLF
			//Fechamento Pacote
			cXml += '&lt;/sustacao&gt;'
			***********************************************************************************************
		Endif
		***********************************************************************************************

		oWS:SetValue( aSimple[1][1],"SP") //UF
		oWS:SetValue( aSimple[2][1],cNomeARq) //Nome ARq
		oWS:SetValue( aSimple[3][1],cXml) //Arquivo

		cRequest := oWS:GetSoapMsg()
		//FWrite(nHandle, cRequest)
		//FClose(nHandle)

		FWrite(nHandle2, cXml)
		FClose(nHandle2)
		
		oWS:SendSoapMsg()

		oResult := oWS:GetSoapResponse()
		oPARSE := XmlParser( oResult, "_", @cError, @cWarning )	
		If Valtype(OPARSE) == "O"
			oMyRef := oParse:_Soap_Env_Envelope:_Soap_Env_Body
			
			// Verifica se ha Erro na estrutura da RequisiÃ§Ã£o
			If AttisMemberOf(oMyRef,"_SOAP_ENV_FAULT")
				lResp := .F.
				Alert("Erro API Externo!")
				cMenssagem := cMenssagem + " - Erro API Externo"
				cSession := oMyRef:_SOAP_ENV_FAULT:_FAULTSTRING:Text
				ApMsgInfo(cSession)
				U_MonitRes(cIdTrab, 2, , cIdPZB, cMenssagem, lResp, "Cartorio Titulos Bordero: " + cNumBor, "Arquivo SOAP-REQUEST = " + Arqv, cSession, "", .F., .F.)
				//Finaliza o processo na PZB
				U_MonitRes(cIdTrab, 3, , cIdPZB, , lResp)
				return
			Endif
			
			//Tratar o retorno
			If nOperation == 1 // Remessa
				cSession := oMyRef:_NS1_RemessaResponse:_Resposta:Text
				lResp := "<codigo>0000</codigo>"$cSession
				cReferenc := "Cartorio = " + iif(lResp,"Sucesso!","Erro!")
				ApMsgInfo(cReferenc)
				cMenssagem := cMenssagem + " - Remessa"
				U_MonitRes(cIdTrab, 2, , cIdPZB, cMenssagem, lResp, "Cartorio Titulos Bordero: " + cNumBor, "Arquivo SOAP-REQUEST = " + Arqv, cSession, "", .F., .F.)
				//Finaliza o processo na PZB
				U_MonitRes(cIdTrab, 3, , cIdPZB, , lResp)
				lRet := .T.
				If lResp
					PutMv("MV_OABCART",Alltrim(cValToChar(cSeqCart)))
					RefreshE1("02",cNumBor) // 02 - Remessa Gerada
					RefreshEA(cNumbor,cNomeARq)
				Endif
			Else
				cSession := oMyRef:_NS1_CancelamentoResponse:_Resposta:Text
				cReferenc := "Tratar Retorno"
				lResp := .F.
				ApMsgInfo(cReferenc)
				cMenssagem := cMenssagem + " - Cancelamento"
				U_MonitRes(cIdTrab, 2, , cIdPZB, cMenssagem, lResp, "Cancelamento Titulos Bordero: " + cNumBor, "Arquivo SOAP-REQUEST = " + Arqv, cSession, "", .F., .F.)
				//Finaliza o processo na PZB
				U_MonitRes(cIdTrab, 3, , cIdPZB, , lResp)			
			Endif
		Else
			Alert("Erro ao obter retorno do ServiÃ§o.")
			cReferenc := "Cartorio = " + iif(lResp,"Sucesso!","Erro!")
			U_MonitRes(cIdTrab, 2, , cIdPZB, cMenssagem, lResp, "Cartorio Titulos Bordero: " + cNumBor, cXml, "Erro ao obter retorno do ServiÃ§o.", "", .F., .F.)
			//Finaliza o processo na PZB
			U_MonitRes(cIdTrab, 3, , cIdPZB, , lResp)
		Endif

		// Libera Memoria
		FreeObj(oWS)
		FreeObj(oResult)
		FreeObj(oPARSE)
		(cAlias2)->(DBCloseArea())
		SE1->(DBCloseArea())
	Else
		Alert("Rotina Abortada!")
		lRet := .F. 
	EndIf

Return lRet

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
Static Function RefreshEA(cNumbor,cNomeARq)
	Local cSql := ""
	
	cSql += "UPDATE " + RetSqlName("SEA")
	cSql += " SET E1_XREFERE = '"+ cNomeARq +"'"
	cSql += " WHERE D_E_L_E_T_ != '*'"
	cSql += " AND EA_FILIAL = '"+ xFilial("SEA") +"'"
	cSql += " AND EA_NUMBOR = '"+ cNumbor +"'"

	TcSqlExec(cSql)
Return
