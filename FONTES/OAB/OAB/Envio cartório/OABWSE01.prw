#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'APWEBSRV.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'FILEIO.CH'
#INCLUDE 'RWMAKE.CH'

User Function OABWSE01(nOper)	

Local cError    := ""   
Local cWarning  := ""
Local cSession	:= ""
Local cUser		:= ""
Local cKey		:= ""
Local cNomeArq  := ''
Local cXml      := ''

Local aComplex  := {}
Local aSimple   := {}

Local oWS	
Local oResult
Local oPARSE

nOper := 1 ////
oWS := TWsdlManager():New()
oWS:lVerbose := .T.

oWS:ParseURL("http://homologcra.protesto.com.br/cra/webservice/protesto_v2.php?wsdl")
If nOper == 1
	oWS:SetOperation("Remessa")
Else
	oWS:SetOperation("ConsultarTitulo")
Endif 

//Informo o usu√°rio e senha via basic em base64 no header da requisi√ß√£o
oWS:AddHttpHeader("Authorization", "Basic " + Encode64("apbgoadm:testecra"))

oWS:bNoCheckPeerCert := .T.

aComplex    := oWS:NextComplex()
aSimple     := oWS:SimpleInput()


//B Constante ‚Äì Identifica tratar-se de arquivo gerado pelo portador.
//CCC C√≥digo de Compensa√ß√£o do Banco/Portador
//DD Dia do envio do Arquivo Remessa ao Cart√≥rio Distribuidor de T√≠tulos.
//MM M√™s do envio do Arquivo Remessa ao Cart√≥rio Distribuidor de T√≠tulos.
//AA Ano do envio do Arquivo Remessa ao Cart√≥rio Distribuidor de T√≠tulos.
//S N√∫mero Seq√ºencial da Remessa ‚Äì Identifica o n√∫mero da remessa que est√° sendo enviada

cNomeArq := 'B'
cNomeArq += '033'
cNomeArq += Alltrim(Str(Day(Date())))
cNomeArq += padl(Alltrim(Str(Month(Date()))),2,'0')
cNomeArq += "."
cNomeArq += Right(Str(Year(Date())),2)
cNomeArq += '1'

//Montagem do campo 'Arquivo'
cXml := '<?xml version="1.0" encoding="ISO-8859-1" standalone="no"?>' + CRLF
cXml += '<remessa>' + CRLF
cXml += '<comarca' + CRLF
cXml += 'CodMun="3550308"' + CRLF
//HEader
 cXml += '<hd
 cXml += 'h01="' + '0' + '"' + CRLF 							//Identificar o registro header no arquivo.Constante 0
 cXml += 'h02="' + '341' + '"' + CRLF 							//Identificar o cÛdigo do banco/portador
 cXml += 'h03="' + 'ORDEM DOS ADVOGADOS DO BRASIL - SECCAO DE SAO PAULO' + '"' + CRLF //Preencher com o nome do portador (ìRaz„o Socialî ). 
 cXml += 'h04="' + DATE() + '"' + CRLF 							//Identificar a data de envio do arquivo de Remessa
 cXml += 'h05="' + 'BFO' + '"' + CRLF 								//Preencher com a sigla do remetente do arquivo: BFO ñ Banco, InstituiÁ„o Financeira
 cXml += 'h06="' + 'SDT' + '"' + CRLF						//Preencher com a sigla do destinat·rio do arquivo: SDT ñ ServiÁo de DistribuiÁ„o de
 cXml += 'h07="' + 'TPR' + '"' + CRLF 						//Preencher com a sigla de identificaÁ„o da transaÁ„o: TPR ñ Remessa de tÌtulos para
 cXml += 'h08="' + '1' + '"' + CRLF 					//Controlar o seq¸encial de remessas, que dever· ser contÌnuo. 
 cXml += 'h09="' + '1' + '"' + CRLF 							//Preencher com o somatÛrio da quantidade de registros constantes no registro de
 cXml += 'h10="' + '1' + '"' + CRLF 							//Preencher com o somatÛrio da quantidade de Registros constantes no arquivo
 cXml += 'h11="' + '' + '"' + CRLF 							//a Preencher com o somatÛrio da quantidade de tÌtulos do tipo ìDMIî ,ìDRIî e ìCBIî
 cXml += 'h12="' + '1' + '"' + CRLF 								//Preencher com o somatÛrio da quantidade dos demais tÌtulos
 cXml += 'h13="' + '' + '"' + CRLF 							//Identificar a AgÍncia Centralizadora - Uso do Banco. 
 cXml += 'h14="' + '43' + '"' + CRLF						 //IdentificaÁ„o da vers„o vigente do layout. Esta refere-se ‡ 043. Este campo n„o
 cXml += 'h15="' + '353550308' + '"' + CRLF 							//Preencher 2 dÌgitos para o CÛdigo da Unidade da FederaÁ„o e 5 para o CÛdigo doMunicÌpio
 cXml += 'h16="' + ' ' + '"' + CRLF 						//Ajustar o tamanho do registro header com o tamanho do registro de transaÁ„o. preencher com brancos
 cXml += 'h17="' + '0001' + '"' + CRLF 			//Constante 0001. Sempre reiniciar a contagem do lote de registro para as praÁasimplantadas no processo de centralizaÁ„o. 
 cXml += '/>' + CRLF

 //TransaÁ„o
 cXml += '<tr
 cXml += 't01="' + '1' + '"' + CRLF //Identificar o Registro TransaÁ„o no arquivo. Constante 1
 cXml += 't02="' + '033' + '"' + CRLF //dentificar o cÛdigo do banco/portador. 
 cXml += 't03="' + '00319' + '"' + CRLF //AgÍncia / CÛdigo do Cedente
 cXml += 't04="' + 'ORDEM DOS ADVOGADOS DO BRASIL - SECCAO DE SAO PAULO' + '"' + CRLF //Nome do Cedente/Favorecido
 cXml += 't05="' + 'ORDEM DOS ADVOGADOS DO BRASIL - SECCAO DE SAO PAULO' + '"' + CRLF //Identificar o Sacador/Vendedor. 
 cXml += 't06="' + '43419613000170' + '"' + CRLF //Documento do Sacador 
 cXml += 't07="' + ' PraÁa da SÈ, 385 - SÈ, S„o Paulo' + '"' + CRLF //Identificar o endereÁo do Sacador/Vendedor. 
 cXml += 't08="' + '01001-902' + '"' + CRLF //Identificar o CEP do Sacador/Vendedor. 
 cXml += 't09="' + 'S√O PAULO' + '"' + CRLF //Identificar a cidade do Sacador/Vendedor. 
 cXml += 't10="' + 'SP' + '"' + CRLF //Identificar a Unidade da FederaÁ„o do Sacador/Vendedor. 
 cXml += 't11="' + SE1->E1_NUM + '"' + CRLF //Identificar o tÌtulo do cedente 
 cXml += 't12="' + 'CPS' + '"' + CRLF //ESPECIE TO TITULO(??????)
 cXml += 't13="' + SE1->E1_NUM + '"' + CRLF //N⁄MERO DO TÕTULO
 cXml += 't14="' + SE1->E1_EMISSAO + '"' + CRLF //EMISS√O
 cXml += 't15="' + SE1->E1_VENCREA + '"' + CRLF //VENCIMENTO
 cXml += 't16="' + '001' + '"' + CRLF //Identificar o tipo de moeda corrente - 001 ñ Real
 cXml += 't17="' + SE1->E1_VALOR + '"' + CRLF //VALOR DO TÕTULO
 cXml += 't18="' + SE1->E1_SALDO + '"' + CRLF //SALDO
 cXml += 't19="' + 'S√O PAULO' + '"' + CRLF //Informar a praÁa que o tÌtulo dever· ser protestado
 cXml += 't20="' + '' + '"' + CRLF //Identificar o tipo de endosso do tÌtulo:
 cXml += 't21="' + 'A' + '"' + CRLF //Informar ao CartÛrio se o tÌtulo foi aceito pelo devedor:
 cXml += 't22="' + '1' + '"' + CRLF //dentificar a quantidade de devedor(es) ou endereÁos(s) complementar(es) do tÌtulo. 
 cXml += 't23="' + POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_NOME") + '"' + CRLF //Identificar o nome do devedor 
 cXml += 't24="' + Iif(POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_PESSOA")=='J','001','002') + '"' + CRLF //Identificar o tipo de documento do devedor: 001 ñ CNPJ 002 ñ CPF ou Zeros
 cXml += 't25="' + POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_CGC") + '"' + CRLF //Identificar o n˙mero do documento do devedor. 
 cXml += 't26="' + POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_PFISICA") + '"' + CRLF //Identificar o n˙mero do documento do devedor.  RG
 cXml += 't27="' + POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_END") + '"' + CRLF //Identificar o endereÁo do devedor 
 cXml += 't28="' + POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_CEP") + '"' + CRLF //Identificar o CEP do devedor 
 cXml += 't29="' + POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_MUN") + '"' + CRLF //Identificar a cidade do devedor 
 cXml += 't30="' + POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_EST") + '"' + CRLF //dentificar a UF do devedor
 cXml += 't31="' + '0' + '"' + CRLF //Uso restrito do ServiÁo de DistribuiÁ„o. Preencher com zeros. 
 cXml += 't32="' + ' ' + '"' + CRLF //Uso restrito do ServiÁo de DistribuiÁ„o. Preencher com brancos. 
 cXml += 't33="' + ' ' + '"' + CRLF //Uso restrito do ServiÁo de DistribuiÁ„o. Preencher com brancos.
 cXml += 't34="' + '0' + '"' + CRLF //Uso restrito do ServiÁo de DistribuiÁ„o. Preencher com zeros
 cXml += 't35="' + '0' + '"' + CRLF //Uso restrito do ServiÁo de DistribuiÁ„o. Preencher com zeros. 
 cXml += 't36="' + 'P' + '"' + CRLF //DeclaraÁ„o do Portador  (??????)
 cXml += 't37="' + '0' + '"' + CRLF //Uso restrito do ServiÁo de DistribuiÁ„o. Preencher com zeros. 
 cXml += 't38="' + '0' + '"' + CRLF //Uso restrito do ServiÁo de DistribuiÁ„o. Preencher com zeros. 
 cXml += 't39="' + POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_BAIRRO") + '"' + CRLF //Identificar a bairro do devedor 
 cXml += 't40="' + '0' + '"' + CRLF //Uso restrito do ServiÁo de DistribuiÁ„o. Preencher com zeros 
 cXml += 't41="' + '0' + '"' + CRLF //Uso restrito do 7∫ OfÌcio do Rio de Janeiro. Preencher com zeros 
 cXml += 't42="' + '0' + '"' + CRLF //Uso restrito da Centralizadora de Remessa de Arquivos (CRA). Preencher com 
 cXml += 't43="' + '0' + '"' + CRLF //Identificar o n˙mero da operaÁ„o ñ exclusivo para protesto de letra de c‚mbio. O
 cXml += 't44="' + '0' + '"' + CRLF //0
 cXml += 't45="' + '0' + '"' + CRLF //0
 cXml += 't46="' + '' + '"' + CRLF //BRANCOS
 cXml += 't47="' + ' ' + '"' + CRLF V
 cXml += 't48="' + ' ' + '"' + CRLF V
 cXml += 't49="' + '' + '"' + CRLF
 cXml += 't50="' + '0' + '"' + CRLF //0
 cXml += 't51="' + ' ' + '"' + CRLF
 cXml += 't52="' + '1' + '"' + CRLF //N˙mero seq¸encial do registro no arquivo, independentemente da quantidade de
 cXml += '/>' + CRLF

 //Trailer
 cXml += '<tl
 cXml += 't01="' + '9' + '"' + CRLF //Identificar o registro trailler no arquivo. Constante 9.
 cXml += 't02="' + '033' + '"' + CRLF //Identificar o cÛdigo do banco/portador
 cXml += 't03="' + 'Banco Santander do Brasil' + '"' + CRLF //Preencher com o nome do portador (ìRaz„o Socialî ). 
 cXml += 't04="' + DATE() + '"' + CRLF //Identificar a data de envio do arquivo de Remessa ao ServiÁo de DistribuiÁ„o, no
 cXml += 't05="' + '1' + '"' + CRLF //Informar o somatÛrio dos registros. Conforme regra estabelecida para os campos do
 cXml += 't06="' + SE1->E1_VALOR + '"' + CRLF //Informar o somatÛrio dos Saldos dos TÌtulos
 cXml += 't07="' + '' + '"' + CRLF //BRANCOS
 cXml += 't08="' + '1' + '"' + CRLF //Informar o n˙mero seq¸encial do registro, limitado a 2.300, por disquete, pois para 
 cXml += '/>' + CRLF

//Fechamento comarca
 cXml += '</comarca>' + CRLF
 //Fechamento remessa
 cXml += '</remessa>'

oWS:SetValue( aSimple[1][1],"SP") //UF
oWS:SetValue( aSimple[2][1],cNomeARq) //Nome ARq
oWS:SetValue( aSimple[3][1],cXml) //Arquivo

oWS:GetSoapMsg()
oWS:SendSoapMsg()

oResult := oWS:GetSoapResponse()
oPARSE := XmlParser( oResult, "_", @cError, @cWarning )	

cSession := OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_LOGINRESPONSE:_LOGINRETURN:TEXT
/*
oWS:SetValue( aSimple[1][1],"9f1cc81b-2ae9-450e-9539-9acda577e650-6f6a8650-5c91-41da-af6c-b0d18535 2ec7-a66c060d-6287-45f4-bc62-22ebcc17d3cf") //token
oWS:SetValue( aSimple[2][1],'N') //Alterara√ß√£o
oWS:SetValue( aSimple[3][1],SE1->E1_CLIENTE) //C√≥digo
//cedente
oWS:SetValue( aSimple[4][1],POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_NOME")) //NOME
oWS:SetValue( aSimple[5][1],SE1->E1_TIPO) //DOCUMENTO 
oWS:SetValue( aSimple[6][1],SE1->E1_NUM) //DOCUMENTO 
oWS:SetValue( aSimple[7][1],POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_ENDERECO")) //ENDERECO
oWS:SetValue( aSimple[8][1],POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_NUMERO")) //NUMERO
oWS:SetValue( aSimple[9][1],POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_COMPL")) //COMPLEMENTO
oWS:SetValue( aSimple[10][1],POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_CEP")) //CEP
oWS:SetValue( aSimple[11][1],POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_BAIRRO")) //BAIRRO
oWS:SetValue( aSimple[12][1],POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_MUN")) //MUNICIPIO
oWS:SetValue( aSimple[13][1],POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_UF")) //UF
//Sacador
oWS:SetValue( aSimple[14][1],POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_NOME")) //NOME
oWS:SetValue( aSimple[15][1],SE1->E1_TIPO) //DOCUMENTO TIPO
oWS:SetValue( aSimple[16][1],SE1->E1_NUM) //DOCUMENTO TIPO
oWS:SetValue( aSimple[17][1],POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_ENDERECO")) //ENDERECO
oWS:SetValue( aSimple[18][1],POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_NUMERO")) //NUMERO
oWS:SetValue( aSimple[19][1],POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_COMPL")) //COMPLEMENTO
oWS:SetValue( aSimple[20][1],POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_CEP")) //CEP
oWS:SetValue( aSimple[21][1],POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_BAIRRO")) //BAIRRO
oWS:SetValue( aSimple[22][1],POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_MUN")) //MUNICIPIO
oWS:SetValue( aSimple[23][1],POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_UF")) //UF

//SACADOR
oWS:SetValue( aSimple[24][1],'eMPRESA'  ) //EMPRESA
oWS:SetValue( aSimple[25][1],'filial'  ) //EMPRESA
oWS:SetValue( aSimple[26][1],POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_NOME")) //NOME
oWS:SetValue( aSimple[27][1],SE1->E1_TIPO) //DOCUMENTO TIPO
oWS:SetValue( aSimple[28][1],SE1->E1_NUM) //DOCUMENTO TIPO
oWS:SetValue( aSimple[29][1],POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_ENDERECO")) //ENDERECO
oWS:SetValue( aSimple[30][1],POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_NUMERO")) //NUMERO
oWS:SetValue( aSimple[31][1],POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_COMPL")) //COMPLEMENTO
oWS:SetValue( aSimple[32][1],POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_CEP")) //CEP
oWS:SetValue( aSimple[33][1],POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_BAIRRO")) //BAIRRO
oWS:SetValue( aSimple[34][1],POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_MUN")) //MUNICIPIO
oWS:SetValue( aSimple[35][1],POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  , "A1_UF")) //UF

oWS:SetValue( aSimple[36][1],'principal' ) //principal
oWS:SetValue( aSimple[37][1],'especie'  ) //principal
oWS:SetValue( aSimple[38][1],'numero'  ) //principal
oWS:SetValue( aSimple[39][1],'nosso numero') //principal
oWS:SetValue( aSimple[40][1],SE1->E1_VALOR ) //principal
oWS:SetValue( aSimple[41][1],SE1->E1_SALDO ) //principal
oWS:SetValue( aSimple[42][1],'' ) //tIPO ENDOSSO
oWS:SetValue( aSimple[43][1],'' ) //ACEITE

oWS:SetValue( aSimple[44][1],'' ) //finsFalimentares
oWS:SetValue( aSimple[45][1],'' ) //declaracaoPortador
oWS:SetValue( aSimple[46][1],SE1->E1_EMISSAO ) //emissao
oWS:SetValue( aSimple[47][1],SE1->E1_VENCREA ) //vencimento
oWS:SetValue( aSimple[48][1],'' ) //extensao
oWS:SetValue( aSimple[49][1],'' ) //documentoBase64
oWS:SetValue( aSimple[50][1],'' ) //juros
oWS:SetValue( aSimple[51][1],'' ) //multa
oWS:SetValue( aSimple[52][1],'' ) //mora
oWS:SetValue( aSimple[53][1],'' ) //parcela
oWS:SetValue( aSimple[54][1],'' ) //vencimento
oWS:SetValue( aSimple[55][1],'' ) //valor
oWS:SetValue( aSimple[56][1],'' ) //saldo
oWS:SetValue( aSimple[57][1],'' ) //juros
oWS:SetValue( aSimple[58][1],'' ) //multa
oWS:SetValue( aSimple[59][1],'' ) //mora
oWS:SetValue( aSimple[60][1],'' ) //observacao
oWS:SetValue( aSimple[61][1],'' ) //pracaManual
oWS:SetValue( aSimple[62][1],'' ) //anotacao
*/


Return ({oWS,cSession})
