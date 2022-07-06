#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#DEFINE CRLF Chr(13)+Chr(10)

WSRESTFUL produtos DESCRIPTION "Integração com Vtrina"

WSDATA page AS INTEGER OPTIONAL
WSDATA limit AS INTEGER OPTIONAL
WSDATA marketplace AS STRING OPTIONAL
WSDATA productId AS STRING OPTIONAL
WSDATA variantId AS STRING OPTIONAL
WSDATA codigo AS STRING OPTIONAL
WSDATA codbar AS STRING OPTIONAL
WSDATA atualizado AS STRING OPTIONAL

WSMETHOD GET DESCRIPTION "Listagem de produtos" WSSYNTAX "/produtos"
WSMETHOD PUT DESCRIPTION "Atualiza produto" WSSYNTAX "/produtos/{marketplace}/{id}"

END WSRESTFUL

WSMETHOD GET WSRECEIVE page, limit, marketplace, productId, variantId, codigo, codbar, atualizado WSSERVICE produtos

//Local nX
Local cAlias    := GetNextAlias()
Local cWhere  := "%"
//Local cRet      := ""

If ::marketplace != NIL
	cWhere += " AND ZDD.ZDD_CODMKT = '"+ ::marketplace + "'"
EndIf

If ::productId != NIL
   cWhere += " AND ZDD.ZDD_PROID = '"+ ::productId + "'"
EndIf

If ::variantId != NIL
   cWhere += " AND ZDD.ZDD_VARID = '"+ ::variantId + "'"
EndIf

If ::codigo != NIL
   cWhere += " AND SB1.B1_COD = '"+ ::codigo + "'"
EndIf

If ::codbar != NIL
   cWhere += " AND SB1.B1_CODBAR = '"+ ::codbar + "'"
EndIf
 
If ::atualizado != NIL
   cWhere += " AND ZDD.ZDD_ATUPRO = '"+ ::atualizado + "'"
EndIf

cWhere += "%"
 
conout("PRODUTOS - Empresa/Filial: " +cEmpAnt+"/"+cFilAnt)

// define o tipo de retorno do método
::SetContentType("application/json")
    
DEFAULT ::page := 1, ::limit := 50
  
nOffset := (::page * ::limit) - ::limit
nLimit := ::limit

BeginSQL alias cAlias
	SELECT	ZDD.ZDD_PROID, ZDD.ZDD_VARID, ZDD.ZDD_PRODUT,
			ZDD.ZDD_NOMPRO, ZDD.R_E_C_N_O_ AS ZDD_RECNO,
			SB1.B1_UM, SB1.B1_XMARCA, ZDD.ZDD_CODMKT, ZDD.ZDD_SKU, SB1.B1_CODBAR,
			COALESCE(SB2.B2_QATU-SB2.B2_RESERVA-SB2.B2_QEMP-SB2.B2_QACLASS,0) AS ESTOQUE,
			ZDD.ZDD_PRECO, ZDD.ZDD_PRCPRM, ZDD.ZDD_INIOFE, ZDD.ZDD_FIMOFE,
			ZDD.ZDD_PESO, ZDD.ZDD_LARG, ZDD.ZDD_ALT, ZDD.ZDD_COMP, ZDD.ZDD_M3,
			ZDD.ZDD_STATUS, ZDD.ZDD_QUANT
	
	FROM %table:ZDD% (NOLOCK) ZDD 
	
	INNER JOIN %table:SB1% (NOLOCK) SB1 ON SB1.B1_FILIAL = %xfilial:SB1%
								  AND SB1.B1_COD = ZDD.ZDD_PRODUT
								  AND SB1.%notDel%
	
	LEFT JOIN %table:SB2% (NOLOCK) SB2 ON SB2.B2_FILIAL = %xfilial:SB2%
								 AND SB2.B2_COD = ZDD.ZDD_PRODUT
								 AND SB2.B2_LOCAL = ZDD.ZDD_LOCAL
								 AND SB2.%notDel%
	
	WHERE ZDD.ZDD_FILIAL = %xfilial:ZDD%
	%exp:cWhere%	
	AND ZDD.%notDel%
	
	ORDER BY ZDD.ZDD_PROID, ZDD.ZDD_VARID
	
	OFFSET %exp:nOffset% ROWS FETCH NEXT %exp:nLimit% ROWS ONLY
EndSQL

// exemplo de retorno de uma lista de objetos JSON
::SetResponse('[')

dbSelectArea(cAlias)
(cAlias)->(dbGoTop())

lPrim := .T.

If (cAlias)->(!Eof())
	While (cAlias)->(!Eof())
	
		If !lPrim
			::SetResponse(',')
		EndIf
		
		cStatus := "Ativo"
		
		Do Case
			Case (cAlias)->ZDD_STATUS == "A"; cStatus := "Ativo"
			Case (cAlias)->ZDD_STATUS == "I"; cStatus := "Inativo"
			Case (cAlias)->ZDD_STATUS == "B"; cStatus := "Bloqueado"
		EndCase

		dbSelectArea("ZDD")
		dbGoTo((cAlias)->ZDD_RECNO)

		::SetResponse('{')
		::SetResponse('"productId": "' + ALLTRIM((cAlias)->ZDD_PROID) + '", ')
		::SetResponse('"variantId": "' + ALLTRIM((cAlias)->ZDD_VARID) + '", ')
		::SetResponse('"codigo": "' + ALLTRIM((cAlias)->ZDD_PRODUT) + '", ')
		::SetResponse('"descricao": "' + FwCutOff(EncodeUtf8(ALLTRIM((cAlias)->ZDD_NOMPRO))) + '", ')
		::SetResponse('"descricao_completa": "' + STRTRAN(EncodeUtf8(ZDD->ZDD_DESPRO),CRLF,"<br>") + '", ')
		::SetResponse('"unidade": "' + ALLTRIM((cAlias)->B1_UM) + '", ')
		::SetResponse('"marca": "' + FwCutOff(ALLTRIM((cAlias)->B1_XMARCA)) + '", ')
		::SetResponse('"marketplace": "' + ALLTRIM((cAlias)->ZDD_CODMKT) + '", ')
		::SetResponse('"sku": "' + ALLTRIM((cAlias)->ZDD_VARID) + '", ')
		::SetResponse('"codbar": "' + ALLTRIM((cAlias)->B1_CODBAR) + '", ')
		//::SetResponse('"estoque": ' + ALLTRIM(STR((cAlias)->ESTOQUE)) + ', ')	// 19.10.20 - Funaki - Alterado para utilizar o campo ZDD_QUANT
		::SetResponse('"estoque": ' + ALLTRIM(STR((cAlias)->ZDD_QUANT)) + ', ')
		::SetResponse('"preco": ' + ALLTRIM(STR((cAlias)->ZDD_PRECO)) + ', ')
		::SetResponse('"preco_promocional": ' + ALLTRIM(STR((cAlias)->ZDD_PRCPRM)) + ', ')
		::SetResponse('"preco_tabela": ' + ALLTRIM(STR((cAlias)->ZDD_PRECO)) + ', ')
		::SetResponse('"preco_oferta": ' + ALLTRIM(STR((cAlias)->ZDD_PRCPRM)) + ', ')
	 	::SetResponse('"inicio_oferta": "'+DTOC(STOD((cAlias)->ZDD_INIOFE))+'", ')
	 	::SetResponse('"fim_oferta": "'+DTOC(STOD((cAlias)->ZDD_FIMOFE))+'", ')
		::SetResponse('"peso": ' + ALLTRIM(STR((cAlias)->ZDD_PESO)) + ', ')
		::SetResponse('"largura": ' + ALLTRIM(STR((cAlias)->ZDD_LARG)) + ', ')
		::SetResponse('"altura": ' + ALLTRIM(STR((cAlias)->ZDD_ALT)) + ', ')
		::SetResponse('"comprimento": ' + ALLTRIM(STR((cAlias)->ZDD_COMP)) + ', ')
		::SetResponse('"linha": "", ')
		::SetResponse('"cor": "", ')
		::SetResponse('"tamanho": "", ')
		::SetResponse('"m3": ' + ALLTRIM(STR((cAlias)->ZDD_M3)) +', ')
		::SetResponse('"status": "' + cStatus +'", ')
		::SetResponse('"marketplaces": [] ')
		::SetResponse('}')
		
		lPrim := .F.
		
		(cAlias)->(dbSkip())
	EndDo
EndIf

If SELECT(cAlias) > 0
	(cAlias)->(dbCloseArea())
EndIf

::SetResponse(']')

Return .T.

WSMETHOD PUT WSSERVICE produtos

Local lPut := .T.
//Local oProduto

If Len(::aURLParms) == 0
	SetRestFault(400, "E obrigatório informar o codigo do marketplace e o sku")
	lPut := .F.
Else
	cCodMkt := "" 
	cCodMkt := ::aUrlParms[1]
	cVarId  := PADR(::aUrlParms[2],TAMSX3("ZDD_VARID")[1])
	
	ConOut("[PRODUTOS] - Alteracao Produto via API - Empresa/Filial: " +cEmpAnt+ "/" +cFilAnt+ " ("+Time()+")")
	
	dbSelectArea("ZDD")
	dbSetOrder(5)
	dbGoTop()
	If dbSeek(xFilial("ZDD")+cCodMkt+cVarId)
		
		Reclock("ZDD",.F.)
		ZDD->ZDD_ATUPRO := ''
		ZDD->(MsUnLock())
		
		::SetResponse('{"O produto foi atualizado com sucesso"}')
	Else
		SetRestFault(400, "O produto " + cVarId + " nao foi localizado no sistema.")
		lPut := .F.
	EndIf
EndIf

Return lPut
