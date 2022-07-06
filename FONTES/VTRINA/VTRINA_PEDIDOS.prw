#include "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

WSRESTFUL pedidos DESCRIPTION "Pedidos de Venda"

WSDATA page AS INTEGER OPTIONAL
WSDATA limit AS INTEGER OPTIONAL
WSDATA orderId AS STRING OPTIONAL
WSDATA orderIdMarketplace AS STRING OPTIONAL
WSDATA orderIdCustom AS STRING OPTIONAL
WSDATA canal AS INTEGER OPTIONAL
WSDATA status AS STRING OPTIONAL
WSDATA integrado AS STRING OPTIONAL
WSDATA orderIds AS STRING OPTIONAL

WSMETHOD GET DESCRIPTION "Listagem de pedidos" WSSYNTAX "/pedidos"
WSMETHOD POST DESCRIPTION "Inserir novo pedido" WSSYNTAX "/pedidos"
WSMETHOD PUT DESCRIPTION "Atualizar pedido" WSSYNTAX "/pedidos/{id}"

END WSRESTFUL

WSMETHOD GET WSRECEIVE page, limit, orderId, orderIdMarketplace, orderIdCustom, status, integrado, orderIds, canal WSSERVICE pedidos

Local cAlias := GetNextAlias()
Local cWhere := "%"

If ::orderId != Nil
   cWhere += " AND SC5.C5_NUM = '"+ ::orderId + "'"
EndIf

If ::orderIdMarketplace != Nil
   cWhere += " AND SC5.C5_XMPPEDI = '"+ ::orderIdMarketplace + "'"
EndIf

If ::orderIdCustom != Nil
   cWhere += " AND SC5.C5_XMPPEDI = '"+ ::orderIdCustom + "'"
EndIf

If ::canal != Nil
   cWhere += " AND UPPER(SC5.C5_XMPNOME) = '"+ ConvMktplc(::canal) + "'"
EndIf

If ::status != Nil
	::SetResponse('[]')
	Return .T.
EndIf

If ::integrado != Nil
	::SetResponse('[]')
	Return .T.
EndIf

If ::orderIds != Nil

	cPedidos := STRTRAN(::orderIds,"[","(")
	cPedidos := STRTRAN(cPedidos,"]",")")
	cPedidos := STRTRAN(cPedidos,'"',"'")
		
	cPedidos := " AND SC5.C5_NUM IN " + cPedidos
	
	cWhere += cPedidos
EndIf

cWhere += "%"
 
// define o tipo de retorno do método
::SetContentType("application/json")
    
DEFAULT ::page := 1, ::limit := 50
  
// exemplo de retorno de uma lista de objetos JSON
::SetResponse('[')

nOffset := (::page * ::limit) - ::limit
nLimit := ::limit

BeginSQL alias cAlias
	SELECT 	SC5.C5_NUM, SC5.C5_XMPPEDI, SC5.C5_EMISSAO, SC5.C5_XMPNOME, SC5.C5_XMPLOJA,
			SC5.C5_NOTA, SC5.C5_LIBEROK, SC5.C5_STATUS, SC5.C5_RASTR,
			SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_EMISSAO, SF2.F2_HORA, SF2.F2_CHVNFE
			
	FROM %table:SC5% (NOLOCK) SC5
	
	LEFT JOIN %table:SF2% (NOLOCK) SF2 ON SF2.F2_FILIAL = SC5.C5_FILIAL
									  AND SF2.F2_DOC = SC5.C5_NOTA
									  AND SF2.F2_SERIE = SC5.C5_SERIE
									  AND SF2.%notDel%
		
	WHERE SC5.C5_FILIAL = %xfilial:SC5%
	%exp:cWhere%
	AND SC5.%notDel%
	
	ORDER BY SC5.C5_NUM
	
	OFFSET %exp:nOffset% ROWS FETCH NEXT %exp:nLimit% ROWS ONLY
EndSQL
//AND SC5.C5_NOTA <> 'XXXXXXXXX'	// 15.08.20 - Funaki - Retirado o filtro da eliminação de resíduos

(cAlias)->(dbGoTop())

lPrim := .T.

If (cAlias)->(!Eof())
	While (cAlias)->(!Eof())
		/* 09.09.2020 - Funaki - Incluído verificação para pedidos com eliminação de resíduos */
		if alltrim((cAlias)->C5_NOTA) == "XXXXXXXXX"
			// Verifica se existe pedido em aberto com o mesmo número
			if fVerPedido((cAlias)->C5_NUM, (cAlias)->C5_XMPPEDI, (cAlias)->C5_XMPNOME)
				// Se existir um pedido com o mesmo número em aberto no marketplace, ignora o registro
				(cAlias)->(dbSkip())
				loop
			endif
		endif
		/* 09.09.2020 - Funaki - Incluído verificação para pedidos com eliminação de resíduos */
	
		If !lPrim
			::SetResponse(',')
		EndIf
		
		cStatus    := ""
		cStatusLog := ""
		cRastro    := ""
		
		Do Case
			Case (cAlias)->C5_STATUS == "00"; cStatus := "Pendente"
			Case (cAlias)->C5_STATUS == "10" .And. Empty((cAlias)->C5_NOTA); cStatus := "Aprovado"
			Case (cAlias)->C5_STATUS == "30" .Or. (!Empty((cAlias)->C5_NOTA) .And. Alltrim((cAlias)->C5_NOTA) != "XXXXXXXXX" .And. !Empty((cAlias)->C5_RASTR))
				cStatus := cStatusLog := "Enviado"
				cRastro := ALLTRIM((cAlias)->C5_RASTR)
				
			Case (cAlias)->C5_STATUS == "90"; cStatus := "Cancelado"
			// Incluir a validação do C5_NOTA aqui com o status diferente de 90
		EndCase
		
		If Empty(cRastro)
			Do Case
				Case Empty((cAlias)->C5_LIBEROK) .And. Empty((cAlias)->C5_NOTA); cStatusLog := "Pendente"
				Case !Empty((cAlias)->C5_LIBEROK) .And. Empty((cAlias)->C5_NOTA); cStatusLog := "Em andamento"
				Case !Empty((cAlias)->C5_LIBEROK) .And. !Empty((cAlias)->C5_NOTA) .And. (cAlias)->C5_NOTA == "XXXXXXXXX"; cStatus := cStatusLog := "Cancelado"
				Case !Empty((cAlias)->C5_LIBEROK) .And. !Empty((cAlias)->C5_NOTA) .And. (cAlias)->C5_NOTA != "XXXXXXXXX"; cStatus := cStatusLog := "Faturado"
			EndCase
		EndIf
		
		cResposta := '{'
		
		cResposta += '"orderId": "' + ALLTRIM((cAlias)->C5_NUM) + '", '
		cResposta += '"orderIdMarketplace": "' + ALLTRIM((cAlias)->C5_XMPPEDI) + '", '
		cResposta += '"orderIdCustom": null, '
		cResposta += '"dataEmissao": "'+ALLTRIM(DTOC(STOD((cAlias)->C5_EMISSAO)))+'", '
		cResposta += '"status": "'+cStatus+'", '
		cResposta += '"statusLogistica": "' + cStatusLog + '", '
		cResposta += '"metodoEnvio": null, '
		If !Empty(cRastro)
			cResposta += '"rastro": "' + cRastro + '", '
		Else
			cResposta += '"rastro": null, '
		EndIf
		cResposta += '"itens": ['
		
		
		BeginSQL alias "ITEM"
			SELECT 	SC6.C6_ITEM, SC6.C6_PRODUTO, SC6.C6_DESCRI, SC6.C6_UM,
					SC6.C6_PRUNIT, SC6.C6_QTDVEN, SC6.C6_PRCVEN, SC6.C6_VALOR,
					SC6.C6_DESCONT, SB1.B1_CODBAR
			
			FROM %table:SC6% (NOLOCK) SC6
			
			LEFT JOIN %table:SB1% (NOLOCK) SB1 ON SB1.B1_FILIAL = %xfilial:SB1%
											  AND SB1.B1_COD = SC6.C6_PRODUTO
											  AND SB1.%notDel%
			
			WHERE SC6.C6_FILIAL = %xfilial:SC6%
			AND SC6.C6_NUM = %exp:(cAlias)->C5_NUM%
			AND SC6.%notDel%
			
			ORDER BY SC6.C6_ITEM
		EndSQL
		
		ITEM->(dbGoTop())
		
		While ITEM->(!Eof())
			
			cResposta += '{'
			cResposta += '"item": "'+ITEM->C6_ITEM+'", '
			cResposta += '"codbar": "'+ALLTRIM(ITEM->B1_CODBAR)+'", '
			cResposta += '"produto": "'+ALLTRIM(ITEM->C6_PRODUTO)+'", '
			cResposta += '"descricao": "'+ALLTRIM(ITEM->C6_DESCRI)+'", '
			cResposta += '"unidade": "'+ITEM->C6_UM+'", '
			cResposta += '"precoTabela": '+ALLTRIM(STR(ITEM->C6_PRUNIT))+', '
			cResposta += '"quantidade": '+ALLTRIM(STR(ITEM->C6_QTDVEN))+', '
			cResposta += '"preco": '+ALLTRIM(STR(ITEM->C6_PRCVEN))+', '
			cResposta += '"valor": '+ALLTRIM(STR(ITEM->C6_VALOR))+', '
			cResposta += '"desconto": '+ALLTRIM(STR(ITEM->C6_DESCONT))
			cResposta += '},'
			
			ITEM->(dbSkip())
		EndDo
		
		If SELECT("ITEM") > 0
			ITEM->(dbCloseArea())
		EndIf
		
		cResposta := SUBSTR(cResposta,1,Len(cResposta)-1)
		
		cResposta += '],'
		cResposta += '"notaFiscal": {'
		
		If ALLTRIM((cAlias)->F2_DOC) <> ''
			cResposta += '"numero": "' + ALLTRIM((cAlias)->F2_DOC) + '", '
		Else
			cResposta += '"numero": null, '
		EndIf
		
		If ALLTRIM((cAlias)->F2_SERIE) <> ''
			cResposta += '"serie": "' + ALLTRIM((cAlias)->F2_SERIE) + '", '
		Else
			cResposta += '"serie": null, '
		EndIf
		
		cEmissao := SUBSTR((cAlias)->F2_EMISSAO,1,4)+"-"+SUBSTR((cAlias)->F2_EMISSAO,5,2)+"-"+SUBSTR((cAlias)->F2_EMISSAO,7,2)
		cEmissao += "T" + ALLTRIM((cAlias)->F2_HORA)+":00.000Z"
		
		If ALLTRIM((cAlias)->F2_EMISSAO) <> ''
			cResposta += '"dataNf": "' + cEmissao + '", '
		Else
			cResposta += '"dataNf": null, '
		EndIf
		
		If ALLTRIM((cAlias)->F2_CHVNFE) <> ''
			cResposta += '"chaveAcesso": "' + ALLTRIM((cAlias)->F2_CHVNFE) + '" '

			/* 10.06.20 - Funaki - Implementado o envio do XML da NFe para a API */
			_cXML := fRecXML(ALLTRIM((cAlias)->F2_CHVNFE))
			
			If !Empty(_cXML)
				cResposta += ', '
				cResposta += '"xml": "' + Alltrim(EncodeUtf8(_cXML)) + '" '
			Endif
		Else
			cResposta += '"chaveAcesso": null, "xml": null '
		EndIf
		
		cResposta += '}'

		cResposta += '}'
		
		::SetResponse(cResposta)
		
		lPrim := .F.
		
		(cAlias)->(dbSkip())
	EndDo
EndIf

If SELECT(cAlias) > 0
	(cAlias)->(dbCloseArea())
EndIf

::SetResponse(']')

Return .T.

WSMETHOD POST WSSERVICE pedidos

Local lPost  := .T.
Local cBody := ::GetContent()
Local oPedido
local cLocal := ""
local nX := 0
local _cDocMkt := ""
local _cCodA1U := ""
//local _oModelA1U := nil
local _cAlAux := getnextalias()
Local _ni := 1
Local cTabPrc := GetMv("MV_LJECOMQ")

ConOut("[PEDIDOS] - Integracao Pedido via Marketplace - Empresa/Filial: " +cEmpAnt+ "/" +cFilAnt+ " ("+Time()+") - POST")
conout(cBody)

//cBody := NoAcento(cBody)
FWJsonDeserialize(cBody,@oPedido)

//Tratativa de status do pedido
nStatus := oPedido:status
cStatus := "Pendente"

//Tratativa do marketplace
nMktplace := oPedido:marketplace
cMktplace := ConvMktPlc(nMktplace)

nSubMkt := oPedido:subChannel

//nVendMkt  := oPedido:marketplace
cVendMkt  := CVendMkt(nMktplace)

//Variáveis para inclusão do pedido
If oPedido:marketplace == 10 .And. oPedido:orderIdCustom != Nil
	cNumPed := oPedido:orderIdCustom
Else
	cNumPed := oPedido:orderIdMarketplace
EndIf

cDtCad      := STRTRAN(LEFT(oPedido:created,10),"-","")
//nValFret    := oPedido:shippingCost
nValFret    := 0
cTipoFret   := "C"
cMensagem   := ""
cObservacao := ""
dDataVenc   := DDATABASE//STOD(STRTRAN(LEFT(oPedido:updated,10),"-",""))
nValBrut    := oPedido:totalAmount
cShipment   := NoAcento(UPPER(oPedido:shipment:shippingName))


/*
If nStatus != 2
	SetRestFault(400, "Pedido nao sera integrado pois nao esta aprovado.")
	Return .F.
EndIf
*/

//Primeiro verifico se o pedido já não existe na base
cAliasPED := GetNextAlias()

BeginSQL alias cAliasPED
	SELECT SC5.C5_NUM, SC5.C5_STATUS, SC5.C5_XMPNOME, SC5.C5_XMPPEDI
	FROM %table:SC5% (NOLOCK) SC5
	WHERE SC5.C5_FILIAL = %xfilial:SC5%
	AND SC5.C5_XMPPEDI = %exp:cNumPed%
	AND UPPER(SC5.C5_XMPNOME) = %exp:cMktplace%
	AND SC5.C5_NOTA <> 'XXXXXXXXX'
	AND SC5.%notDel%
EndSQL

(cAliasPED)->(dbGoTop())

If (cAliasPED)->(!Eof())
	//se o pedido já existe, retorno o número do pedido
	::SetResponse('{')
	::SetResponse('"numero": "' + (cAliasPED)->C5_NUM + '", ')
	::SetResponse('"mensagem": "Pedido integrado com sucesso" ')
	::SetResponse('}')

	fGravaLog("pedidos", "POST", cBody, (cAliasPED)->C5_XMPNOME, (cAliasPED)->C5_NUM, (cAliasPED)->C5_XMPPEDI, (cAliasPED)->C5_STATUS, cvaltochar(nStatus), "200", "Pedido já existente")//LOG1

	(cAliasPED)->(dbCloseArea())
	
	Return .T.
EndIf

If SELECT(cAliasPED) > 0
	(cAliasPED)->(dbCloseArea())
EndIf

/* 06.11.20 - Funaki - Alterado para verificar se o cliente já existe com o mesmo endereço */
//Cria o cliente se ele não existe
//cAliasCli := GetNextAlias()

cDocumento := oPedido:billing:documentId


/*
BeginSQL alias cAliasCli
	SELECT SA1.R_E_C_N_O_ AS A1_RECNO
	FROM %table:SA1% (NOLOCK) SA1
	WHERE SA1.A1_FILIAL = %xfilial:SA1%
	AND SA1.A1_CGC = %exp:cDocumento%
	AND SA1.%notDel%
EndSQL

(cAliasCli)->(dbGoTop())
If (cAliasCli)->(!Eof())
	dbSelectArea("SA1")
	dbGoTo((cAliasCli)->A1_RECNO)
	lGrava := .F.
Else
	lGrava := .T.
EndIf

If SELECT(cAliasCli) > 0
	(cAliasCli)->(dbCloseArea())
EndIf
*/

_aInfoCli := {}
lGrava := fVerCli(cDocumento, oPedido:shipping:zipCode, alltrim(UPPER(oPedido:shipping:street)) + ", " + oPedido:shipping:streetNumber, @_aInfoCli)
/* 06.11.20 - Funaki - Alterado para verificar se o cliente já existe com o mesmo endereço */
	
cEst := UPPER(oPedido:billing:state)
cMun := UPPER(NoAcento(oPedido:billing:city))
cMun := STRTRAN(cMun,"'","''")

cAliasMun := GetNextAlias()

BeginSQL alias cAliasMun
	SELECT CC2.CC2_CODMUN
	FROM %table:CC2% (NOLOCK) CC2
	WHERE CC2.CC2_FILIAL = %xfilial:CC2%
	AND CC2.CC2_EST = %exp:cEst%
	AND RTRIM(CC2.CC2_MUN) = %exp:cMun%
	AND CC2.%notDel%
EndSQL

(cAliasMun)->(dbGoTop())
If (cAliasMun)->(!Eof())
	cCodMun := (cAliasMun)->CC2_CODMUN
Else
	fGravaLog("pedidos", "POST", cBody, cMktplace, "", cNumPed, "", cvaltochar(nStatus), "400", "Municipio nao localizado - " + cMun+"/"+cEst + "Query: " + GetLastQuery()[2])//LOG2
	SetRestFault(400, "Municipio nao localizado - " + cMun+"/"+cEst + "Query: " + GetLastQuery()[2])
	Return .F.
EndIf

If SELECT(cAliasMun) > 0
	(cAliasMun)->(dbCloseArea())
EndIf

/* Município de entrega - Campo obrigatório Grupo Gibraltar */

cEstEnt := UPPER(oPedido:shipping:state)
cMunEnt := UPPER(NoAcento(oPedido:shipping:city))
cMunEnt := STRTRAN(cMunEnt,"'","''")

cAliasMEnt := GetNextAlias()

BeginSQL alias cAliasMEnt
	SELECT CC2.CC2_CODMUN
	FROM %table:CC2% (NOLOCK) CC2
	WHERE CC2.CC2_FILIAL = %xfilial:CC2%
	AND CC2.CC2_EST = %exp:cEstEnt%
	AND RTRIM(CC2.CC2_MUN) = %exp:cMunEnt%
	AND CC2.%notDel%
EndSQL

(cAliasMEnt)->(dbGoTop())
If (cAliasMEnt)->(!Eof())
	cCodMunEnt := (cAliasMEnt)->CC2_CODMUN
Else
	fGravaLog("pedidos", "POST", cBody, cMktplace, "", cNumPed, "", cvaltochar(nStatus), "400", "Municipio de entrega não localizado - " + cMunEnt+"/"+cEstEnt + "Query: " + GetLastQuery()[2])//LOG3
	SetRestFault(400, "Municipio de entrega não localizado - " + cMunEnt+"/"+cEstEnt + "Query: " + GetLastQuery()[2])
	Return .F.
EndIf

If SELECT(cAliasMEnt) > 0
	(cAliasMEnt)->(dbCloseArea())
EndIf


/* 05.04.21 - Funaki - Verifica se o sistema está atualizado para enviar o cnpj do canal */
if chkfile("A1U",.f.)
	// Verifica se foi enviado o cnpj do canal
	if oPedido:marketplaceDocumentId != NIL
		_cDocMkt := oPedido:marketplaceDocumentId

		// Recupera o código do canal
		beginsql alias _cAlAux
			SELECT A1U.A1U_CODIGO
			  FROM %table:A1U% A1U
			 WHERE A1U.A1U_FILIAL = %xfilial:A1U%
			   AND A1U.A1U_CGC = %exp:_cDocMkt%
			   AND A1U.%notdel%
		endsql

		if !(_cAlAux)->(eof())
			_cCodA1U := (_cAlAux)->A1U_CODIGO
		else
			// Se não existe, inclui um novo registro
			_cCodA1U := GetSXENum("A1U","A1U_CODIGO")
			confirmsx8()

			reclock("A1U", .t.)
			A1U->A1U_FILIAL := xfilial("A1U")
			A1U->A1U_CODIGO := _cCodA1U
			A1U->A1U_NOME := cMktplace
			A1U->A1U_CGC := _cDocMkt
			msunlock("A1U")
		endif
		(_cAlAux)->(dbclosearea())
	endif
endif
/* 05.04.21 - Funaki - Verifica se o sistema está atualizado para enviar o cnpj do canal */

If Len(cDocumento) == 11
	cPessoa  := "F" //Pessoa Fisica
	cTipoCli = "F" //Consumidor Final
Else
	cPessoa  := "J" //Pessoa Juridica
	cTipoCli := "F" //Consumidor Final
EndIf

cIE := ""
cDestIE := ""
cContrib := ""
cGrpTrib := ""
cSimples := ""

If Len(cDocumento) == 11
	cIE := "ISENTO"
	cContrib := "2" //Não contribuinte ICMS
	cGrpTrib := "201"
	cDestIE := "1"
Elseif Len(cDocumento) == 14 .And. cDocumento != "16517057000100" .And. oPedido:billing:stateRegistrationId != NIL //Não Validar se for pedido Vtrina e campos em branco
	cIE := ALLTRIM(oPedido:billing:stateRegistrationId)
	cContrib := "1" //contribuinte ICMS
	cGrpTrib := "202"
	cSimples := ""
	cDestIE := "2"
EndIf

dDtNasc := STOD("")
if oPedido:billing:dateOfBirth != NIL
	dDtNasc := STOD(STRTRAN(SUBSTR(oPedido:billing:dateOfBirth,1,10),"-",""))
endif

cDDD := ""
cTelefone := ""
If oPedido:billing:phone != NIL
	cTelefone := oPedido:billing:phone

	// 14.04.21 - Funaki - Ajuste para separar o DDD do número do telefone
	if substr(alltrim(cTelefone),1,2) == "55" .and. len(alltrim(cTelefone)) > 11
		cTelefone := substr(alltrim(cTelefone),3)
	endif
	cTelefone := strtran(alltrim(cTelefone)," ","")
	cTelefone := strtran(alltrim(cTelefone),"(","")
	cTelefone := strtran(alltrim(cTelefone),")","")
	cTelefone := strtran(alltrim(cTelefone),"-","")
	if substr(alltrim(cTelefone),1,1) == "0"
		cTelefone := substr(alltrim(cTelefone),2)
	endif

	cDDD := substr(alltrim(cTelefone),1,2)
	cTelefone := substr(alltrim(cTelefone),3)
EndIf

aCliente := {}

cMetodopgt := NoAcento(UPPER(oPedido:paymentMethods[_ni]:method))
cParcpgt   := cvaltochar(oPedido:paymentMethods[_ni]:installments)
					
cMPgt := ""

If SELECT("CPGT") > 0
	CPGT->(dbCloseArea())
EndIf

BeginSQL alias "CPGT"
	SELECT ZDR.ZDR_CONDP
	FROM %table:ZDR% (NOLOCK) ZDR
	WHERE ZDR.ZDR_FILIAL = %xfilial:ZDR%	
	AND ZDR.ZDR_CANAL = %exp:STRZERO(nMktplace,2)%
	AND RTRIM(ZDR.ZDR_CPVTR) = %exp:cMetodopgt%
	AND RTRIM(ZDR.ZDR_NPARC) = %exp:cParcpgt%
	AND ZDR.%notDel%
EndSQL

CPGT->(dbGoTop())

If CPGT->(!Eof())
	cMPgt := CPGT->ZDR_CONDP
Else
	cMPgt := "001"
EndIf

If SELECT("CPGT") > 0
	CPGT->(dbCloseArea())
EndIf

If lGrava	

	cLoja    := "01" //Primeiro cadastro do cliente
	// 06.11.20 - Funaki - Verifica se o cliente já existe mas é um novo endereço
	if len(_aInfoCli) > 0
		// Cliente totalmente novo
		/*If SELECT("SELLER") > 0
			SELLER->(dbCloseArea())
		EndIf
		
		BeginSQL alias "SELLER"
			SELECT MAX(SA1.A1_COD) AS CODIGO
			FROM %table:SA1% SA1
			WHERE SA1.A1_FILIAL = %xfilial:SA1%
			AND SA1.%notDel%
		EndSQL
		
		SELLER->(dbGoTop())*/
		
		//cCliente := SOMA1(SELLER->CODIGO)
		//cLoja    := "01"
	//else
		// Caso o cliente já exista mas é um novo endereço, utiliza o mesmo código e incrementa a loja
		cCliente := _aInfoCli[1]
		cLoja    := SOMA1(_aInfoCli[2])

		AADD(aCliente, {"A1_COD"     , cCliente , Nil })
		AADD(aCliente, {"A1_LOJA"    , cLoja , Nil })
	endif
	AADD(aCliente, {"A1_FILIAL"  , xFilial("SA1") , Nil })
	//AADD(aCliente, {"A1_COD"     , cCliente , Nil })
	AADD(aCliente, {"A1_LOJA"    , cLoja , Nil })
	AADD(aCliente, {"A1_PESSOA"  , cPessoa , Nil })
	AADD(aCliente, {"A1_NOME"    , PADR(strtran(UPPER(oPedido:billing:name),"'",""), TAMSX3("A1_NREDUZ")[1]) ,Nil})
	AADD(aCliente, {"A1_NREDUZ"  , PADR(strtran(UPPER(oPedido:billing:name),"'",""), TAMSX3("A1_NREDUZ")[1]) ,Nil})
	AADD(aCliente, {"A1_END"     , alltrim(strtran(UPPER(oPedido:billing:street),"'","")) + ", " + oPedido:billing:streetNumber ,Nil})
	AADD(aCliente, {"A1_COMPLEM" , PADR(strtran(UPPER(oPedido:billing:streetComplement),"'",""),TAMSX3("A1_COMPLEM")[1]) ,Nil})
	AADD(aCliente, {"A1_BAIRRO"  , PADR(strtran(UPPER(oPedido:billing:district),"'",""),TAMSX3("A1_BAIRRO")[1]) ,Nil})
	AADD(aCliente, {"A1_CEP"     , oPedido:billing:zipCode ,Nil})
	AADD(aCliente, {"A1_EST"     , ALLTRIM(UPPER(oPedido:billing:state)) ,Nil})
	AADD(aCliente, {"A1_COD_MUN" , cCodMun , Nil })
	AADD(aCliente, {"A1_DDD"     , cDDD ,Nil})
	AADD(aCliente, {"A1_MUN"     , UPPER(oPedido:billing:city) ,Nil})
	AADD(aCliente, {"A1_EMAIL"   , ALLTRIM(oPedido:billing:email) , Nil })
	AADD(aCliente, {"A1_DDI"     , "55" ,Nil})
	AADD(aCliente, {"A1_PAIS"    , "105" , Nil }) 
	AADD(aCliente, {"A1_TEL"     , cTelefone ,Nil})
	AADD(aCliente, {"A1_CONTATO" , PADR(strtran(UPPER(oPedido:billing:name),"'",""), TAMSX3("A1_CONTATO")[1]) ,Nil})
	AADD(aCliente, {"A1_TIPO"    , cTipoCli ,Nil})	
	AADD(aCliente, {"A1_CGC"     , cDocumento , Nil })
	AADD(aCliente, {"A1_INSCR"   , cIE , Nil })
	AADD(aCliente, {"A1_DTNASC"  , dDataBase ,Nil})
	AADD(aCliente, {"A1_VEND"    , cVendMkt ,Nil})
	AADD(aCliente, {"A1_NATUREZ" , "30101" , Nil })	
	AADD(aCliente, {"A1_ENDCOB"  , alltrim(strtran(UPPER(oPedido:billing:street),"'","")) + ", " + oPedido:billing:streetNumber ,Nil})
	AADD(aCliente, {"A1_BAIRROC" , PADR(strtran(UPPER(oPedido:billing:district),"'",""),TAMSX3("A1_BAIRROC")[1]) ,Nil})
	AADD(aCliente, {"A1_MUNC"    , UPPER(oPedido:billing:city) ,Nil})
	AADD(aCliente, {"A1_CEPC"    , oPedido:billing:zipCode ,Nil})
	AADD(aCliente, {"A1_ESTC"    , ALLTRIM(UPPER(oPedido:billing:state)) ,Nil})
	AADD(aCliente, {"A1_XCOB"    , "10" ,Nil}) //
	AADD(aCliente, {"A1_CODPAIS" , "01058" , Nil })	
	AADD(aCliente, {"A1_ENDENT"  , alltrim(UPPER(oPedido:shipping:street)) + ", " + oPedido:shipping:streetNumber ,Nil})
	AADD(aCliente, {"A1_BAIRROE" , PADR(strtran(UPPER(oPedido:shipping:district),"'",""),TAMSX3("A1_BAIRROE")[1]) ,Nil})
	AADD(aCliente, {"A1_MUNE"    , UPPER(oPedido:shipping:city) ,Nil})
	AADD(aCliente, {"A1_ESTE"    , ALLTRIM(UPPER(oPedido:shipping:state)) ,Nil})
	AADD(aCliente, {"A1_CEPE"    , oPedido:shipping:zipCode ,Nil})	
	AADD(aCliente, {"A1_COMPENT" , PADR(strtran(UPPER(oPedido:shipping:streetComplement),"'",""),TAMSX3("A1_COMPENT")[1]) ,Nil})
	AADD(aCliente, {"A1_GRPTRIB" , cGrpTrib , Nil })
	AADD(aCliente, {"A1_CONTRIB" , cContrib , Nil })
	AADD(aCliente, {"A1_SIMPNAC" , "2" , Nil })
	AADD(aCliente, {"A1_COND"    , cMPgt , Nil })
	AADD(aCliente, {"A1_RISCO"   , "A" ,Nil})
	AADD(aCliente, {"A1_VENCLC"  , dDataBase ,Nil})
	AADD(aCliente, {"A1_MOEDALC" ,  1 ,Nil})
	AADD(aCliente, {"A1_K_CANAL" , "6000 " , Nil })
	AADD(aCliente, {"A1_GRPVEN"  , "6011 " , Nil })
	//AADD(aCliente, {"A1_TABELA"  , cTabPrc , Nil })
	AADD(aCliente, {"A1_K_EMAIL" , ALLTRIM(oPedido:billing:email) , Nil })
	AADD(aCliente, {"A1_IENCONT" , 	cDestIE , Nil })
	
	
	dbSelectArea("SA1")

	If FieldPos("A1_DTCAD") > 0
		AADD(aCliente, {"A1_DTCAD"   , DDATABASE ,Nil})
	EndIf
	
	If FieldPos("A1_LOCPAD") > 0
		AADD(aCliente, {"A1_LOCPAD"  , "G1" , Nil })
	EndIf
	
	If FieldPos("A1_CLASSIF") > 0
		AADD(aCliente, {"A1_CLASSIF" , "7" , Nil })
	EndIf
	
	If FieldPos("A1_TPEND") > 0
		AADD(aCliente, {"A1_TPEND"   , "I" , Nil })
	EndIf
	
	If FieldPos("A1_REGUL") > 0
		AADD(aCliente, {"A1_REGUL"   , "S" , Nil })
	EndIf
	
	If FieldPos("A1_ESTOQUE") > 0
		AADD(aCliente, {"A1_ESTOQUE" , "S" , Nil })
	EndIf
	
	If FieldPos("A1_SIMPLES") > 0
		AADD(aCliente, {"A1_SIMPLES" , cSimples , Nil })	
	EndIf
	
	
	lMsErroAuto := .F.	
	lAutoErrNoFile := .T.
	//INCLUI := .T.
	MSExecAuto({|x,y| CRMA980(x,y)}, aCliente, 3)
	
	If lMsErroAuto
		RollbackSx8()
		cErro := ""
		aErro := GetAutoGRLog()
		
		For nX := 1 To Len(aErro)
			cErro += aErro[nX]
		Next nX

		fGravaLog("pedidos", "POST", cBody, cMktplace, "", cNumPed, "", cvaltochar(nStatus), "400", "Erro na atualizacao de cliente - " + NoAcento(cErro))//LOG4
		SetRestFault(400, "Erro na atualizacao de cliente - " + NoAcento(cErro))
		Return .F.
	else
            // Se criou o cliente, faz novo posicionamento porque a rotina nova vai para o final do arquivo
            dbselectarea("SA1")
            SA1->(dbsetorder(3))
            SA1->(dbgotop())
            SA1->(dbseek(xfilial("SA1")+cDocumento))	
	EndIf
Else
	// 06.11.20 - Funaki - Caso tenha sido localizado o cliente com o mesmo endereço, posiciona na SA1 para atualização
	SA1->(dbsetorder(1))
	SA1->(dbgotop())
	SA1->(dbseek(xfilial("SA1")+_aInfoCli[1]+_aInfoCli[2]))

	Reclock("SA1",.F.)
	
		SA1->A1_PESSOA     := cPessoa 
		SA1->A1_NOME       := PADR(strtran(UPPER(oPedido:billing:name),"'",""), TAMSX3("A1_NREDUZ")[1]) 
		SA1->A1_NREDUZ     := PADR(strtran(UPPER(oPedido:billing:name),"'",""), TAMSX3("A1_NREDUZ")[1]) 
		SA1->A1_END        := alltrim(strtran(UPPER(oPedido:billing:street),"'","")) + ", " + oPedido:billing:streetNumber 
		SA1->A1_COMPLEM    := PADR(strtran(UPPER(oPedido:billing:streetComplement),"'",""),TAMSX3("A1_COMPLEM")[1]) 
		SA1->A1_BAIRRO     := PADR(strtran(UPPER(oPedido:billing:district),"'",""),TAMSX3("A1_BAIRRO")[1]) 
		SA1->A1_CEP        := oPedido:billing:zipCode 
		SA1->A1_EST        := ALLTRIM(UPPER(oPedido:billing:state)) 
		SA1->A1_COD_MUN    := cCodMun 
		SA1->A1_DDD        := cDDD 
		SA1->A1_MUN        := UPPER(oPedido:billing:city) 
		SA1->A1_EMAIL      := ALLTRIM(oPedido:billing:email) 
		SA1->A1_DDI        := cDDD 
		SA1->A1_PAIS       := "105"  
		SA1->A1_TEL        := cTelefone 
		SA1->A1_CONTATO    := PADR(strtran(UPPER(oPedido:billing:name),"'",""), TAMSX3("A1_CONTATO")[1])
		SA1->A1_TIPO       := cTipoCli 	
		SA1->A1_CGC        := cDocumento 
		SA1->A1_INSCR      := cIE 
		SA1->A1_DTNASC     := dDataBase 
		SA1->A1_VEND       := cVendMkt 
		SA1->A1_NATUREZ    := "30101" 	
		SA1->A1_ENDCOB     := alltrim(strtran(UPPER(oPedido:billing:street),"'","")) + ", " + oPedido:billing:streetNumber 
		SA1->A1_BAIRROC    := PADR(strtran(UPPER(oPedido:billing:district),"'",""),TAMSX3("A1_BAIRROC")[1]) 
		SA1->A1_MUNC       := UPPER(oPedido:billing:city) 
		SA1->A1_CEPC       := oPedido:billing:zipCode 
		SA1->A1_ESTC       := ALLTRIM(UPPER(oPedido:billing:state)) 
		SA1->A1_XCOB       := "10"  
		SA1->A1_CODPAIS    := "01058" 	
		SA1->A1_ENDENT     := alltrim(UPPER(oPedido:shipping:street)) + ", " + oPedido:shipping:streetNumber 
		SA1->A1_BAIRROE    := PADR(strtran(UPPER(oPedido:shipping:district),"'",""),TAMSX3("A1_BAIRROE")[1]) 
		SA1->A1_MUNE       := UPPER(oPedido:shipping:city) 
		SA1->A1_ESTE       := ALLTRIM(UPPER(oPedido:shipping:state)) 
		SA1->A1_CEPE       := oPedido:shipping:zipCode 	
		SA1->A1_COMPENT    := PADR(strtran(UPPER(oPedido:shipping:streetComplement),"'",""),TAMSX3("A1_COMPENT")[1]) 
		SA1->A1_GRPTRIB    := cGrpTrib 
		SA1->A1_CONTRIB    := cContrib 
		SA1->A1_SIMPNAC    := "2" 
		SA1->A1_COND       := cMPgt 
		SA1->A1_RISCO      := "A" 
		SA1->A1_VENCLC     := dDataBase 
		SA1->A1_MOEDALC    := 1 
		SA1->A1_K_CANAL    := "6000" 
		SA1->A1_GRPVEN     := "6011"
		//SA1->A1_TABELA     := cTabPrc
		SA1->A1_K_EMAIL    := ALLTRIM(oPedido:billing:email)
		SA1->A1_IENCONT    := cDestIE 
	
	dbSelectArea("SA1")
	
	If FieldPos("A1_LOCPAD") > 0
		SA1->A1_LOCPAD := "G1"
	EndIf
	
	If FieldPos("A1_CLASSIF") > 0
		SA1->A1_CLASSIF := "7"
	EndIf
	
	If FieldPos("A1_TPEND") > 0
		SA1->A1_TPEND := "I"
	EndIf
	
	If FieldPos("A1_REGUL") > 0
		SA1->A1_REGUL := "S"
	EndIf
	
	If FieldPos("A1_ESTOQUE") > 0
		SA1->A1_ESTOQUE := "S"
	EndIf
	
	If FieldPos("A1_SIMPLES") > 0
		SA1->A1_SIMPLES := "2"	
	EndIf
	
	If FieldPos("A1_DTCAD") > 0
		SA1->A1_DTCAD := DDATABASE
	EndIf
	SA1->(MsUnlock())
EndIf

Do Case
	Case nStatus == 1; cStatus := "00" //Pendente
	Case nStatus == 2; cStatus := "10" //Aprovado
	Case nStatus == 6; cStatus := "90" //Cancelado
	Otherwise
		cStatus := "00"
End Case

//Tratativa do marketplace
//nMktplace := oPedido:marketplace
//cMktplace := ConvMktPlc(nMktplace)

//cVend := "000003" //vtrina

If (AllTrim(SA1->A1_END) != AllTrim(SA1->A1_ENDENT))
	cObservacao	:= "ENTREGAR NO ENDERECO: " + AllTrim(SA1->A1_ENDENT) + " | BAIRRO: " + AllTrim(SA1->A1_BAIRROE) + " | CIDADE: " + AllTrim(SA1->A1_MUNE) + "/" + AllTrim(SA1->A1_ESTE) + " | CEP: " + AllTrim(SA1->A1_CEPE)
	//cObservacao	+= " | " + NoAcento(UPPER(oPedido:observation))							
	cMensagem	:= "PEDIDO: " + cNumPed + " - "+cMktPlace+" | " + cObservacao
EndIf

cTipoFret	:= "C"

cTransp := ""

If SELECT("TRANSP") > 0
	TRANSP->(dbCloseArea())
EndIf

BeginSQL alias "TRANSP"
	SELECT ZDO.ZDO_TRANSP
	FROM %table:ZDO% (NOLOCK) ZDO
	WHERE ZDO.ZDO_FILIAL = %xfilial:ZDO%
	AND ZDO.ZDO_CODMKT = '001'
	AND ZDO.ZDO_CANAL = %exp:STRZERO(nMktplace,2)%
	AND RTRIM(ZDO.ZDO_CHAVE) = %exp:cShipment%
	AND ZDO.%notDel%
EndSQL

TRANSP->(dbGoTop())

If TRANSP->(!Eof())
	cTransp := TRANSP->ZDO_TRANSP
Else
	fGravaLog("pedidos", "POST", cBody, cMktplace, "", cNumPed, "", cvaltochar(nStatus), "400", "Transportadora Vtrina nao associado ao Protheus. Tabela ZDO - " + cShipment + "   -> Query: " + GetLastQuery()[2])//LOG5
	SetRestFault(400, "Transportadora n&atilde;o associada. Tabela ZDO - " + cShipment + "   -> Query: " + GetLastQuery()[2])
	Return .F.
EndIf

If SELECT("TRANSP") > 0
	TRANSP->(dbCloseArea())
EndIf

//for _ni := 1 to len(oPedido:paymentMethods)

cMetodopgto := NoAcento(UPPER(oPedido:paymentMethods[_ni]:method))
cParcpgto   := cvaltochar(oPedido:paymentMethods[_ni]:installments)
cAutpgto    := oPedido:paymentMethods[_ni]:authorization
cAutCod     := oPedido:paymentMethods[_ni]:authorizationCode
				
//next _ni

cMPgto := ""

If SELECT("CPGTO") > 0
	CPGTO->(dbCloseArea())
EndIf

BeginSQL alias "CPGTO"
	SELECT ZDR.ZDR_CONDP
	FROM %table:ZDR% (NOLOCK) ZDR
	WHERE ZDR.ZDR_FILIAL = %xfilial:ZDR%	
	AND ZDR.ZDR_CANAL = %exp:STRZERO(nMktplace,2)%
	AND RTRIM(ZDR.ZDR_CPVTR) = %exp:cMetodopgto%
	AND RTRIM(ZDR.ZDR_NPARC) = %exp:cParcpgto%
	AND ZDR.%notDel%
EndSQL

CPGTO->(dbGoTop())


If CPGTO->(!Eof())
	cMPgto := CPGTO->ZDR_CONDP
Else
	fGravaLog("pedidos", "POST", cBody, cMktplace, "", cNumPed, "", cvaltochar(nStatus), "400", "Metodo de pagamento Vtrina nao associado ao Protheus. Tabela ZDR - Metodo: " + cMetodopgto+" Qtde parcelas: "+cParcpgto + "   -> Query: " + GetLastQuery()[2])//LOG6
	SetRestFault(400, "M&eacute;todo de pagamento Vtrina n&atilde;o associado ao Protheus. Tabela ZDR - M&eacute;todo: " + cMetodopgto+" Qtde parcelas: "+cParcpgto+ "   -> Query: " + GetLastQuery()[2])
	Return .F.
EndIf

If SELECT("CPGTO") > 0
	CPGTO->(dbCloseArea())
EndIf

// 02.02.2021 - Funaki - Se passou por todas as condições, verifica se possui um pedido temporário para cancelar
_nRecSA1 := SA1->(recno())
_nRecSC5 := SC5->(recno())

if select(cAliasPED) > 0
	(cAliasPED)->(dbclosearea())
endif

_cPedTemp := "*"+alltrim(cNumPed)

beginsql alias cAliasPED
	SELECT SC5.R_E_C_N_O_ RECNUM
	  FROM %table:SC5% (NOLOCK) SC5
	 WHERE SC5.C5_FILIAL = %xfilial:SC5%
	   AND SC5.C5_XMPPEDI = %exp:_cPedTemp%
	   AND UPPER(SC5.C5_XMPNOME) = %exp:cMktplace%
	   AND SC5.C5_NOTA <> 'XXXXXXXXX'
	   AND SC5.%notDel%
endsql

(cAliasPED)->(dbgotop())

if (cAliasPED)->(!eof())
	dbselectarea("SC5")
	SC5->(dbgoto((cAliasPED)->RECNUM))

	CancelaPed(.t.)
	//06-05-22
	fGravaLog("pedidos", "PUT", cBody, cMktplace, (cAliasPED)->C5_NUM, _cPedTemp, (cAliasPED)->C5_STATUS, cvaltochar(nStatus), "200", "Cancelamento pedido temporário -  Pedido temporário cancelado com sucesso")//LOG7
else	
	//06-05-22
	fGravaLog("pedidos", "PUT", cBody, cMktplace, "NPED", _cPedTemp, "", cvaltochar(nStatus), "400", "Cancelamento pedido temporário - Não existe pedido temporário a ser cancelado")//LOG8
	/*
	ZDP->ZDP_FILIAL := xfilial("ZDP")
	ZDP->ZDP_DATA := Date()
	ZDP->ZDP_HORA := substr(alltrim(time()),1,5)
	ZDP->ZDP_SERVIC := _pServ  - pedido
	ZDP->ZDP_METODO := _pMetodo - PUT
	ZDP->ZDP_JSON := _pJson - cBody
	ZDP->ZDP_CANAL := _pCanal - cMktplace
	ZDP->ZDP_PEDERP := _pNumPed 
	ZDP->ZDP_PEDMKT := _pPedMkt
	ZDP->ZDP_STAERP := _pStaPed
	ZDP->ZDP_STAMKT := _pStaMkt
	ZDP->ZDP_CODRET := _pCodRet
	ZDP->ZDP_RETORN := _pRetorno
	*/
EndIf
(cAliasPED)->(dbclosearea())

SA1->(dbgoto(_nRecSA1))
SC5->(dbgoto(_nRecSC5))
// 02.02.2021 - Funaki - Se passou por todas as condições, verifica se possui um pedido temporário para cancelar


dbSelectArea("SC5")

aCabec := {}
AADD(aCabec, {"C5_TIPO"		, "N"							,	Nil})
AADD(aCabec, {"C5_CLIENTE"	, SA1->A1_COD					,	Nil})
AADD(aCabec, {"C5_LOJACLI"	, SA1->A1_LOJA					,	Nil})
AADD(aCabec, {"C5_NOMECLI"	, SA1->A1_NOME					,	Nil})
AADD(aCabec, {"C5_CLIENT"	, SA1->A1_COD					,	Nil})
AADD(aCabec, {"C5_LOJAENT"	, SA1->A1_LOJA					,	Nil})
AADD(aCabec, {"C5_TRANSP"	, cTransp					    ,	Nil})
AADD(aCabec, {"C5_TPFRETE"	, cTipoFret						,	Nil})
AADD(aCabec, {"C5_K_TPCL"	, "3130"						,	Nil})
AADD(aCabec, {"C5_TIPOCLI"	, SA1->A1_TIPO                  ,	Nil})
AADD(aCabec, {"C5_CONDPAG"	, cMPgto						,	Nil})
AADD(aCabec, {"C5_EMISSAO"	, dDataBase						,	Nil})
AADD(aCabec, {"C5_DESPESA"	, oPedido:interest				,	Nil})
AADD(aCabec, {"C5_MOEDA"	, 1								,	Nil})
AADD(aCabec, {"C5_FRETE"	, nValFret						,	Nil})//Frete retirado a pedido do cliente - Anderson 06/07/22
AADD(aCabec, {"C5_MENNOTA"	, cMensagem						,	Nil})										
AADD(aCabec, {"C5_STATUS"	, cStatus						,	Nil})
AADD(aCabec, {"C5_XMPNOME"	, AllTrim(cMktPlace)			,	Nil})
AADD(aCabec, {"C5_XMPPEDI"	, AllTrim(cNumPed)				,	Nil})
AADD(aCabec, {"C5_XMPLOJA"	, nSubMkt  	     	            ,	Nil})
AADD(aCabec, {"C5_VEND1"	, cVendMkt					    ,	Nil})
//AADD(aCabec, {"C5_FECENT"	, STOD(STRTRAN(LEFT(oPedido:estimatedDeliveredAt,10),"-","")),	Nil})
AADD(aCabec, {"C5_XMPMPG"	, cMetodopgto				    ,	Nil})
AADD(aCabec, {"C5_XMPPARC"	, cParcpgto					    ,	Nil})
AADD(aCabec, {"C5_XMPAUT"	, cAutpgto					    ,	Nil})
AADD(aCabec, {"C5_XMPTRID"	, cAutCod					    ,	Nil})
AADD(aCabec, {"C5_K_OPER"	, "01"						    ,	Nil})


/* 05.04.21 - Funaki - Verifica se o sistema está atualizado para enviar o cnpj do canal */
if fieldpos("C5_INDPRES") > 0
	AADD(aCabec, {"C5_INDPRES"	, "2"					    ,	Nil})
endif

if fieldpos("C5_CODA1U") > 0
	AADD(aCabec, {"C5_CODA1U"	, _cCodA1U					    ,	Nil})
endif

aItens := {}
cItem  := "01"
nTotal := 0
cLocal := GetMv("MV_LJECLPE",,"")


For nX:=1 to Len(oPedido:orderItems)
	
	cCodigo := oPedido:orderItems[nX]:sku
	
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbGoTop()
	If dbSeek(xFilial("SB1")+cCodigo)

		cTpO   := GetMv("MV_LJECOMV",,"")
		cTes	:= MaTesInt(2,cTpO,SA1->A1_COD,SA1->A1_LOJA,"C",SB1->B1_COD)

		aItem := {}
		AADD(aItem, {"C6_ITEM"   , cItem ,Nil})
		AADD(aItem, {"C6_PRODUTO", SB1->B1_COD,Nil})
		AADD(aItem, {"C6_QTDVEN" , oPedido:orderItems[nX]:quantity,Nil})		
		AADD(aItem, {"C6_PRCVEN" , oPedido:orderItems[nX]:price,Nil})
		AADD(aItem, {"C6_PRUNIT" , oPedido:orderItems[nX]:originalPrice,Nil})
		
		if !empty(cLocal)
			AADD(aItem, {"C6_LOCAL", cLocal ,Nil})
		endif

		// 01.10.20 - Funaki - Alterado para liberar o pedido somente se já estiver com o status de aprovado - Kapazi não pode usar esta liberação - Usar apenas o PUT
		/*if alltrim(cStatus) == "10"
			AADD(aItem, {"C6_QTDLIB" , oPedido:orderItems[nX]:quantity ,Nil})
		endif*/

		AADD(aItem, {"C6_OPER", cTpO                    ,Nil})
		AADD(aItem, {"C6_TES", cTes                     ,Nil})
		//AADD(aItem, {"C6_PRORIG" , oPedido:orderItems[nX]:originalPrice    ,Nil})

		AADD(aItens, aItem)
		
		nTotal += (oPedido:orderItems[nX]:quantity * oPedido:orderItems[nX]:price)
	Else
		fGravaLog("pedidos", "POST", cBody, cMktplace, "", cNumPed, "", cvaltochar(nStatus), "400", "Sku nao encontrado - " + cCodigo)//LOG9
		SetRestFault(400, "Sku nao encontrado - " + cCodigo)
		Return .F.
	EndIf
	
	cItem := SOMA1(cItem)
Next nX

If Len(aCabec) > 0 .And. Len(aItens) > 0

	//CLI->(dbCloseArea())
	//Faço a inclusão do pedido no Protheus
	lMsErroAuto := .F.		//Indica retorno da MsExecAuto()
	lAutoErrNoFile := .T.	//Usada dentro da MsExecAuto()                  
	MSExecAuto({|x,y,z| MATA410(x,y,z)}, aCabec, aItens,3)
	
	If !lMsErroAuto		
		//se a inclusão deu certo, retorno o número do pedido
		::SetResponse('{')
		::SetResponse('"numero": "' + SC5->C5_NUM + '", ')
		::SetResponse('"mensagem": "Pedido integrado com sucesso" ')
		::SetResponse('}')

		fGravaLog("pedidos", "POST", cBody, cMktplace, SC5->C5_NUM, cNumPed, SC5->C5_STATUS, cvaltochar(nStatus), "200", "Pedido integrado com sucesso")//LOG10
	Else //Erro
		RollbackSx8()
		cErro := ""
		aErro := GetAutoGRLog()
		
		For nX := 1 To Len(aErro)
			cErro += aErro[nX]
		Next nX

		fGravaLog("pedidos", "POST", cBody, cMktplace, "", cNumPed, "", cvaltochar(nStatus), "400", "Erro na inclusao do pedido - " + NoAcento(cErro))//LOG11
		SetRestFault(400, "Erro na inclusao do pedido - " + NoAcento(cErro))
		Return .F.		
	EndIf
EndIf

ConOut("[PEDIDOS] - Pedido integrado com sucesso ("+Time()+")")

Return lPost

WSMETHOD PUT WSSERVICE pedidos

Local lPut := .T.

Local oPedido

local lLiberOk := .T.
local lLiber := .F.
local lTransf := .F.
local _nK := 0

// Exemplo de retorno de erro
If Len(::aURLParms) == 0
	SetRestFault(400, "É obrigatório informar o número do pedido")
	lPut := .F.
Else
	cPedido := ::aUrlParms[1]
	cBody := ::GetContent()

	ConOut("[PEDIDOS] - Alteracao Pedido via Marketplace - Empresa/Filial: " +cEmpAnt+ "/" +cFilAnt+ " ("+Time()+") - PUT")
	conout("Ped: " + alltrim(cPedido) + " - JSON: " + cBody)

	If !Empty(cBody)
		FWJsonDeserialize(cBody,@oPedido)

		dbSelectArea("SC5")
		SC5->(dbSetOrder(1))
		SC5->(dbGoTop())
		If dbSeek(xFilial("SC5")+cPedido)
			//Tratativa de status do pedido
			nStatus := oPedido:status

			//Tratativa do marketplace
			nMktplace := oPedido:marketplace
			cMktplace := ConvMktPlc(nMktplace)

			//Tratativa do número do pedido no marketplace
			If oPedido:marketplace == 10 .And. oPedido:orderIdCustom != Nil
				cNumPed := oPedido:orderIdCustom
			Else
				cNumPed := oPedido:orderIdMarketplace
			EndIf

			//fGravaLog("pedidos", "PUT", cBody, cMktplace, cPedido, cNumPed, SC5->C5_STATUS, cvaltochar(nStatus), "200", "Pedido atualizado com sucesso")//LOG12

			cStatus := ConvStatus(oPedido:status)

			If cStatus == "90"
				_lAtuPed := .t.
				for _nK := 1 to len(oPedido:statusUpdateDate)
					if oPedido:statusUpdateDate[_nK]:status == 6
						_lAtuPed := .f.
					endif
				next _nK

				// 02.02.2021 - Funaki - Ajustado para cancelar o pedido somente se for um cancelamento efetivo
				if !_lAtuPed
					CancelaPed(_lAtuPed)
					//06-05-22
					fGravaLog("pedidos", "PUT", cBody, cMktplace, cPedido, cNumPed, SC5->C5_STATUS, cvaltochar(nStatus), "200", "Cancelamento normal - pedido cancelado com sucesso")//LOG13
				else
					// Se estiver cancelando o pedido temporário, marca o idOrder do marketplace para cancelar na entrada do pedido efetivo
					reclock("SC5",.f.)
					SC5->C5_XMPPEDI := "*" + alltrim(SC5->C5_XMPPEDI)
					msunlock("SC5")
					//06-05-22
					fGravaLog("pedidos", "PUT", cBody, cMktplace, cPedido, SC5->C5_XMPPEDI, SC5->C5_STATUS, cvaltochar(nStatus), "400", "Cancelamento temporário - pedido marcado para deletar após aprovação pedido normal")//LOG14
				endif
			ElseIf (alltrim(cStatus) == "10")
				// Faz a liberação do pedido
				Pergunte("MTA440",.F.)
				lLiber := MV_PAR02 == 1
				lTransf:= MV_PAR01 == 1

				dbselectarea("SC6")
				SC6->(dbsetorder(1))
				SC6->(dbgotop())
				SC6->(dbseek(xfilial("SC6")+SC5->C5_NUM))
				while !SC6->(eof()) .and. alltrim(SC6->C6_FILIAL+SC6->C6_NUM) == alltrim(xfilial("SC6")+SC5->C5_NUM)
					reclock("SC6",.f.)
					SC6->C6_QTDLIB := SC6->C6_QTDVEN
					msunlock("SC6")
					//06-05-22
					fGravaLog("pedidos", "PUT", cBody, cMktplace, cPedido, cNumPed, SC5->C5_STATUS, cvaltochar(nStatus), "200", "C6_QTDLIB preenchido")//LOG15

					SC6->(dbskip())
				enddo

				begin transaction
					MaAvLibPed(SC5->C5_NUM,lLiber,lTransf,@lLiberOk)

					if lLiberOk
						dbselectarea("SC6")
						SC6->(dbsetorder(1))
						SC6->(dbgotop())
						SC6->(dbseek(xfilial("SC6")+SC5->C5_NUM))
						SC6->(MaLiberOk({SC5->C5_NUM},.f.))
						//06-05-22
						fGravaLog("pedidos", "PUT", cBody, cMktplace, cPedido, cNumPed, SC5->C5_STATUS, cvaltochar(nStatus), "200", "Pedido liberado para faturamento com sucesso")//LOG16
					else
						//06-05-22
						fGravaLog("pedidos", "PUT", cBody, cMktplace, cPedido, cNumPed, SC5->C5_STATUS, cvaltochar(nStatus), "400", "ERRO - Pedido não foi  liberado para faturamento")//LOG17

					endif
					
					
				end transaction

				Reclock("SC5",.F.)
				SC5->C5_STATUS := "10"
				SC5->(MsUnLock())
				//06-05-22
				fGravaLog("pedidos", "PUT", cBody, cMktplace, cPedido, cNumPed, SC5->C5_STATUS, cvaltochar(nStatus), "200", "C5_STATUS Atualizado para aprovado com sucesso")//LOG18
			EndIf
			
			::SetResponse('{"O pedido foi atualizado com sucesso"}')
		Else
			//06-05-22
			fGravaLog("pedidos", "PUT", cBody, cMktplace, "", cNumPed, "" , cvaltochar(nStatus), "400", "Pedido não foi localizado no sistema para atualizar para aprovado ou cancelado")//LOG19
			SetRestFault(400, "O pedido " + cPedido + " não foi localizado no sistema.")
			lPut := .F.
		EndIf
	Else
		SetRestFault(400, "Arquivo de integração JSON mal formatado. Acione o administrador")
		lPut := .F.	
	EndIf
EndIf

Return lPut

/*
/============================================================================\
|Nome              : CancelaPed                                              |
|============================================================================|
|Descricao         : Efetua o cancelamento do pedido                         |
|============================================================================|
|Autor             : PAULO AFONSO ERZINGER JUNIOR                            |
|============================================================================|
|Data de Criacao   : 09/01/2019                                              |
\============================================================================/
*/
Static Function CancelaPed(_pAtuPed)

Private aRotina := {}
Private lBloqueados := .F.

//Busco os itens e faço as eliminações
dbSelectArea("SC6")
dbSetOrder(1)
dbGoTop()
If dbSeek(SC5->C5_FILIAL+SC5->C5_NUM)
	While SC6->(!Eof()) .And. SC6->C6_FILIAL == SC5->C5_FILIAL;
						.And. SC6->C6_NUM == SC5->C5_NUM

		//Tento estornar as liberações do item
		MaAvalSC6("SC6",4,"SC5",Nil,Nil,Nil,Nil,Nil,Nil)
		   
		//Verifico se o estorno deu certo e elimino o resíduo
		If SC6->C6_QTDEMP <= 0
			//Log estornou pedido 06-05-22
			fGravaLog("pedidos", "EST", "", SC5->C5_XMPNOME, SC6->C6_NUM, SC5->C5_XMPPEDI, SC5->C5_STATUS, "", "200", "Estorno realizado com sucesso")//LOG20

			MaResDoFat()			
			
			Reclock("SC6",.F.)
			SC6->C6_BLQ := "R"
			SC6->(MsUnLock())

			//Log Eliminação de resíduo 06-05-22
			If SC5->C5_NOTA == "XXXXXXXXX"
				fGravaLog("pedidos", "RES", "", SC5->C5_XMPNOME, SC6->C6_NUM, SC5->C5_XMPPEDI, SC5->C5_STATUS, "", "200", "Pedido eliminado por resíduo com sucesso")//LOG21
			Else
				fGravaLog("pedidos", "RES", "", SC5->C5_XMPNOME, SC6->C6_NUM, SC5->C5_XMPPEDI, SC5->C5_STATUS, "", "400", "Pedido não foi eliminado por resíduo")//LOG22
			EndIf

		Endif 	
	
		SC6->(dbSkip())
	EndDo
EndIf
/*
ZDP->ZDP_FILIAL := xfilial("ZDP")
ZDP->ZDP_DATA := Date()
ZDP->ZDP_HORA := substr(alltrim(time()),1,5)
ZDP->ZDP_SERVIC := _pServ PEDIDOS
ZDP->ZDP_METODO := _pMetodo RES
ZDP->ZDP_JSON := _pJson ""
ZDP->ZDP_CANAL := _pCanal XMPNOME
ZDP->ZDP_PEDERP := _pNumPed NUM
ZDP->ZDP_PEDMKT := _pPedMkt XMPPED
ZDP->ZDP_STAERP := _pStaPed STATUS
ZDP->ZDP_STAMKT := _pStaMkt ""
ZDP->ZDP_CODRET := _pCodRet 200-400
ZDP->ZDP_RETORN := _pRetorno - MENSAGEM
*/

Reclock("SC5",.F.)
SC5->C5_STATUS := "90"
// Se estiver cancelando o pedido temporário, apaga o idOrder do marketplace
if _pAtuPed
	SC5->C5_XMPPEDI := criavar("C5_XMPPEDI",.f.)
	//Log limpou o pedido do canal 06-05-22
	fGravaLog("pedidos", "EXC", cBody, cMktplace, cPedido, SC5->C5_XMPPEDI, SC5->C5_STATUS, cvaltochar(nStatus), "200", "Limpou o numero do pedido canal C5_XMPPEDI")//LOG23
endif
SC5->(MsUnLock())

Return

//Converte o status do pedido
Static Function ConvStatus(nStatus)
 	Local cStatus := ""
 	
	Do Case
	 	Case nStatus <= 1; cStatus := "00" //Pendente
		Case nStatus == 2; cStatus := "10" //Aprovado
		Case nStatus == 6; cStatus := "90" //Cancelado
		Otherwise; cStatus := "00"
	End Case
	
Return cStatus


Static Function ConvMktplc(nMktplace)
	Local cMktPlace := ""
	
	Do Case
		Case nMktplace == 1;  cMktPlace := "AMAZON"
		Case nMktplace == 2;  cMktPlace := "VIA MARKETPLACE"
		Case nMktplace == 3;  cMktPlace := "WALMART"
		Case nMktplace == 4;  cMktPlace := "MAGAZINE LUIZA"
		Case nMktplace == 5;  cMktPlace := "NETSHOES"
		Case nMktplace == 6;  cMktPlace := "AMERICANAS MARKETPLACE"
		Case nMktplace == 7;  cMktPlace := "MERCADO LIVRE"
		Case nMktplace == 8;  cMktPlace := "CARREFOUR"
		Case nMktplace == 9;  cMktPlace := "MADEIRA MADEIRA"
		Case nMktplace == 10; cMktPlace := "DAFITI"
		Case nMktplace == 11; cMktPlace := "MAGENTO 1"
		Case nMktplace == 12; cMktPlace := "HAVAN"
		Case nMktplace == 13; cMktPlace := "SHOPFÁCIL"
		Case nMktplace == 14; cMktPlace := "MULTIPLUS"
		Case nMktplace == 15; cMktPlace := "FASTSHOP"
		Case nMktplace == 16; cMktPlace := "LOJAS COLOMBO"
		Case nMktplace == 17; cMktPlace := "CLIMBA COMMERCE"
		Case nMktplace == 18; cMktPlace := "IGUATEMI 365"
		Case nMktplace == 19; cMktPlace := "CENTAURO"
		Case nMktplace == 20; cMktPlace := "LEROY MERLIN"
		Case nMktplace == 21; cMktPlace := "RICARDO ELETRO"
		Case nMktplace == 22; cMktPlace := "RAPPI"
		Case nMktplace == 23; cMktPlace := "WOOCOMMERCE"
		Case nMktplace == 24; cMktPlace := "VTEX"
		Case nMktplace == 25; cMktPlace := "TRAY CORP"
		Case nMktplace == 26; cMktPlace := "SHOPEE"
		Case nMktplace == 27; cMktPlace := "C&A"
		Case nMktplace == 28; cMktPlace := "RD MARKETPLACE"
		Case nMktplace == 31; cMktPlace := "LOJA INTEGRADA"
		Case nMktplace == 33; cMktPlace := "RENNER/CAMICADO"
		Case nMktplace == 34; cMktPlace := "RIACHUELO"
		Case nMktplace == 35; cMktPlace := "SUPERCAMPO"
		Case nMktplace == 36; cMktPlace := "OLIST"
		Case nMktplace == 37; cMktPlace := "CASSOL"
		Case nMktplace == 38; cMktPlace := "TRAY COMMERCE"
		
	EndCase

Return cMktPlace


Static Function CVendMkt(nMktplace)
	Local cVendMkt := "000001"
	
	Do Case
		//Case nMktplace == 1;  cVendMkt := "513" /* "AMAZON" */
		//Casen nMktplace == 2;  cVendMkt := "515"/* "VIA MARKETPLACE" */		
		//Case nMktplace == 4;  cVendMkt := "502"/* "MAGAZINE LUIZA" */		
		//Casen nMktplace == 6;  cVendMkt := "516"/* "AMERICANAS MARKETPLACE" */
		Case nMktplace == 7;  cVendMkt := "000889" /* "MERCADO LIVRE" */
		//Case nMktplace == 8;  cVendMkt := ""/* "CARREFOUR" */
		//Case nMktplace == 9;  cVendMkt := "514"/* "MADEIRA MADEIRA" */
		//Case nMktplace == 11; cVendMkt := ""/* "MAGENTO 1" */
		//Case nMktplace == 16; cVendMkt := "" /* "LOJAS COLOMBO" */
		//Case nMktplace == 20; cVendMkt := "506"/* "LEROY MERLIN" */	
		//Case nMktplace == 24; cVendMkt := ""/* "VTEX" */
		//Case nMktplace == 25; cVendMkt := ""/* "TRAY CORP" */
		//Case nMktplace == 26; cVendMkt := ""/* "SHOPEE" */
		//Case nMktplace == 31; cVendMkt := ""/* "LOJA INTEGRADA" */		
		//Case nMktplace == 36; cVendMkt := "501" /* "OLIST" */
		//Case nMktplace == ; cVendMkt := ""/* "CASSOL" */
		//Case nMktplace == 38; cVendMkt := "510" /* "TRAY COMMERCE" */
	EndCase

Return cVendMkt


//Retira os acentos das mensagens 
Static Function NoAcento(cString)
Local cChar  := ""
Local nX     := 0 
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
Local cCircu := "âêîôû"+"ÂÊÎÔÛ"
Local cTrema := "äëïöü"+"ÄËÏÖÜ"
Local cCrase := "àèìòù"+"ÀÈÌÒÙ" 
Local cTio   := "ãõÃÕ"
Local cCecid := "çÇ"
Local cMaior := "&lt;"
Local cMenor := "&gt;"

For nX:= 1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
		nY:= At(cChar,cAgudo)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf		
		nY:= At(cChar,cTio)
		If nY > 0          
			cString := StrTran(cString,cChar,SubStr("aoAO",nY,1))
		EndIf		
		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf
	Endif
Next

If cMaior$ cString 
	cString := strTran( cString, cMaior, "" ) 
EndIf
If cMenor$ cString 
	cString := strTran( cString, cMenor, "" )
EndIf

cString := StrTran( cString, CRLF, " " )

Return cString

// Função para recueprar o XML da NFe para enviar na API
Static Function fRecXML(_pChave)
	Local _aArea := GetArea()
	Local _cRet := ""
	Local _nHndERP := AdvConnection()
	Local _cDBTSS := "NFE1101"	//Alltrim(GETMV("MV_VTTSS",,"")) Banco TSS
	Local _cSrvTSS := "192.168.103.210" //IP TSS
	Local _nHndTSS := -1
	Local _cAlAux := nil
	Local _cIdent := "000002"	//retIdEnti()
	Local _nTamXML := 0

	//conout(_cDBTSS)

	If Empty(Alltrim(_cDBTSS))
		ConOut("[PEDIDOS] - Parametro MV_VTTSS não preenchido. - Empresa/Filial: " +cEmpAnt+ "/" +cFilAnt+ " ("+Time()+")")
		Return(_cRet)
	Endif

	_cDBTSS := "MSSQL/" + Alltrim(_cDBTSS)

	// Faz a conexão no banco do TSS
	_nHndTSS := TcLink(_cDBTSS, _cSrvTSS, 7890)
	If _nHndTSS < 0
		ConOut("[PEDIDOS] - Falha ao conectar ao TSS. - Empresa/Filial: " +cEmpAnt+ "/" +cFilAnt+ " ("+Time()+")")
	Else
		ConOut("[PEDIDOS] - Conectado ao TSS. - Empresa/Filial: " +cEmpAnt+ "/" +cFilAnt+ " ("+Time()+")")

		// Se fez a conexão, recupera o XML
		_cAlAux := GetNextAlias()

		// Primeiro recupera o tamanho do XML
		_cQuery := " SELECT DATALENGTH(XML_SIG) AS TAMANHO "
		_cQuery += " FROM SPED050 "
		_cQuery += " WHERE ID_ENT = '" + _cIdent + "' "
		_cQuery += "   AND DOC_CHV = '" + Alltrim(_pChave) + "' "
		TCQUERY _cQuery NEW ALIAS (_cAlAux)

		ConOut("[PEDIDOS] - Tentativa 1. - Empresa/Filial: " +cEmpAnt+ "/" +cFilAnt+ " ("+Time()+")")

		If !(_cAlAux)->(EOF())
			_nTamXML := (_cAlAux)->TAMANHO
		Endif
		(_cAlAux)->(dbCloseArea())

		If _nTamXML == 0
			ConOut("[PEDIDOS] - Tentativa 2. - Empresa/Filial: " +cEmpAnt+ "/" +cFilAnt+ " ("+Time()+")")
			TCQUERY _cQuery NEW ALIAS (_cAlAux)

			If !(_cAlAux)->(EOF())
				_nTamXML := (_cAlAux)->TAMANHO
			Endif
			(_cAlAux)->(dbCloseArea())
		Endif

		If _nTamXML == 0
			ConOut("[PEDIDOS] - Tentativa 3. - Empresa/Filial: " +cEmpAnt+ "/" +cFilAnt+ " ("+Time()+")")
			TCQUERY _cQuery NEW ALIAS (_cAlAux)

			If !(_cAlAux)->(EOF())
				_nTamXML := (_cAlAux)->TAMANHO
			Endif
			(_cAlAux)->(dbCloseArea())
		Endif

		If _nTamXML == 0
			ConOut("[PEDIDOS] - Tentativa 4. - Empresa/Filial: " +cEmpAnt+ "/" +cFilAnt+ " ("+Time()+")")
			TCQUERY _cQuery NEW ALIAS (_cAlAux)

			If !(_cAlAux)->(EOF())
				_nTamXML := (_cAlAux)->TAMANHO
			Endif
			(_cAlAux)->(dbCloseArea())
		Endif

		If _nTamXML == 0
			ConOut("[PEDIDOS] - Tentativa 5. - Empresa/Filial: " +cEmpAnt+ "/" +cFilAnt+ " ("+Time()+")")
			TCQUERY _cQuery NEW ALIAS (_cAlAux)

			If !(_cAlAux)->(EOF())
				_nTamXML := (_cAlAux)->TAMANHO
			Endif
			(_cAlAux)->(dbCloseArea())
		Endif

		ConOut("[PEDIDOS] - Tamanho XML: " + CVALTOCHAR(_nTamXML) + ". - Empresa/Filial: " +cEmpAnt+ "/" +cFilAnt+ " ("+Time()+")")

		If _nTamXML > 0
			// Recupera o conteúdo do campo XML
			_nAux := 1
			While _nAux <= _nTamXML
				If SELECT(_cAlAux) > 0
					(_cAlAux)->(dbCloseArea())
				Endif

				_cQuery := " SELECT CONVERT(varchar(8000),CONVERT(BINARY(8000), SUBSTRING(XML_SIG," + cValToChar(_nAux) + ",8000))) as XML_SIG "
				_cQuery += " FROM SPED050 "
				_cQuery += " WHERE ID_ENT = '" + _cIdent + "'
				_cQuery += "   AND DOC_CHV = '" + Alltrim(_pChave) + "' "
				TCQUERY _cQuery NEW ALIAS (_cAlAux)

				If !(_cAlAux)->(EOF())
					_cRet += Alltrim((_cAlAux)->XML_SIG)
				Endif
				(_cAlAux)->(dbCloseArea())
				_nAux += 8000
			EndDo

			If !Empty(_cRet)
				// Recupera o protocolo para anexar ao XML
				_cQuery := " SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), XML_PROT)) AS XML_PROT "
				_cQuery += " FROM SPED054 "
				_cQuery += " WHERE ID_ENT = '" + _cIdent + "' "
				_cQuery += "   AND NFE_CHV = '" + Alltrim(_pChave) + "' "
				TCQUERY _cQuery NEW ALIAS (_cAlAux)

				If !(_cAlAux)->(EOF())
					_cRet += Alltrim((_cAlAux)->XML_PROT)
				Endif
				(_cAlAux)->(dbCloseArea())
			Endif

			// Concatena as informações do XML com o protocolo de autorização
			If !Empty(_cRet)
				_cRet := '<?xml version="1.0" encoding="UTF-8"?><nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="4.00">' + _cRet + "</nfeProc>"
				_cRet := STRTRAN(_cRet,'"','\"')
			Endif
		Endif
	Endif

	// Retorna o link para o ERP
	tcSetConn(_nHndERP)

	// Fecha a conexão com o TSS
	TcUnlink(_nHndTSS)

	ConOut("[PEDIDOS] - Conexao com TSS fechada. - Empresa/Filial: " +cEmpAnt+ "/" +cFilAnt+ " ("+Time()+")")

	RestArea(_aArea)
Return(_cRet)

// Função para verificar se existe um pedido em aberto
static function fVerPedido(_pNum, _pPedido, _pMktPlace)
	local _aArea := getarea()
	local _cAlAux := getnextalias()
	local _lRet := .f.

	beginsql alias _cAlAux
		SELECT COUNT(*) NREGS
		  FROM %table:SC5% (NOLOCK) SC5
		 WHERE SC5.C5_FILIAL = %xfilial:SC5%
		   AND SC5.C5_NUM <> %Exp:_pNum%
		   AND SC5.C5_XMPPEDI = %exp:_pPedido%
		   AND UPPER(SC5.C5_XMPNOME) = %exp:_pMktPlace%
		   AND SC5.C5_NOTA <> 'XXXXXXXXX'
		   AND SC5.%notDel%
	endsql

	while !(_cAlAux)->(eof())
		if (_cAlAux)->NREGS > 0
			_lRet := .t.
			exit
		endif

		(_cAlAux)->(dbskip())
	enddo
	(_cAlAux)->(dbclosearea())

	restarea(_aArea)
return(_lRet)

// 06.11.20 - Funaki - Função para verificar se o cliente já existe com o endereço indicado
static function fVerCli(_pDoc, _pCep, _pEndereco, _pInfo)
	local _aArea := getarea()
	local _lRet := .t.
	local _cAlAux := getnextalias()

	dbselectarea("SA1")
	SA1->(dbsetorder(1))

	beginsql alias _cAlAux
		SELECT SA1.A1_COD, SA1.A1_LOJA, SA1.A1_CEPE, SA1.A1_ENDENT
		  FROM %table:SA1% SA1
		 WHERE SA1.A1_FILIAL = %xfilial:SA1%
		   AND SA1.A1_CGC = %exp:_pDoc%
		   AND SA1.%notdel%
		 ORDER BY SA1.A1_COD, SA1.A1_LOJA
	endsql

	// Se existe, verifica se possui o endereço cadastrado
	while !(_cAlAux)->(eof())
		if alltrim((_cAlAux)->A1_CEPE) == alltrim(_pCep) .and. alltrim((_cAlAux)->A1_ENDENT) == alltrim(_pEndereco)
			// Se encontrou o endereço informado, não grava novo e retorna o código+loja
			_lRet := .f.
			_pInfo := {(_cAlAux)->A1_COD, (_cAlAux)->A1_LOJA}
			exit
		endif

		// Vai atualizando as informações de código+loja para caso não seja encontrado o endereço
		_pInfo := {(_cAlAux)->A1_COD, (_cAlAux)->A1_LOJA}

		(_cAlAux)->(dbskip())
	enddo
	(_cAlAux)->(dbclosearea())

	restarea(_aArea)
return(_lRet)

static function fGravaLog(_pServ, _pMetodo, _pJson, _pCanal, _pNumPed, _pPedMkt, _pStaPed, _pStaMkt, _pCodRet, _pRetorno)
	
	if chkfile("ZDP",.f.)

		dbSelectArea("ZDP")

		ConOut("[LOG] - Iniciado gravação de LOG - Tabela ZDP" +cEmpAnt+ "/" +cFilAnt+ " ("+Time()+") - LOG")
		reclock("ZDP",.t.)
		ZDP->ZDP_FILIAL := xfilial("ZDP")
		ZDP->ZDP_DATA := Date()
		ZDP->ZDP_HORA := substr(alltrim(time()),1,5)
		ZDP->ZDP_SERVIC := _pServ
		ZDP->ZDP_METODO := _pMetodo
		ZDP->ZDP_JSON := _pJson
		ZDP->ZDP_CANAL := _pCanal
		ZDP->ZDP_PEDERP := _pNumPed
		ZDP->ZDP_PEDMKT := _pPedMkt
		ZDP->ZDP_STAERP := _pStaPed
		ZDP->ZDP_STAMKT := _pStaMkt
		ZDP->ZDP_CODRET := _pCodRet
		ZDP->ZDP_RETORN := _pRetorno
		msunlock("ZDP")

		ZDP->(DbCloseArea())
		ConOut("[LOG] - Finalizado gravação de LOG - Tabela ZDP" +cEmpAnt+ "/" +cFilAnt+ " ("+Time()+") - LOG")

	Else
		ConOut("[LOG] - Tabela de LOG ZDP não encontrada" +cEmpAnt+ "/" +cFilAnt+ " ("+Time()+") - LOG")
	endif
return

