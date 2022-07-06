#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"

WSRESTFUL preco DESCRIPTION "Integracao com Vtrina"

	WSDATA page AS INTEGER OPTIONAL
	WSDATA limit AS INTEGER OPTIONAL
	WSDATA marketplace AS STRING OPTIONAL
	WSDATA productId AS STRING OPTIONAL
	WSDATA variantId AS STRING OPTIONAL
	WSDATA codigo AS STRING OPTIONAL
	WSDATA codbar AS STRING OPTIONAL
	WSDATA dataAtu AS STRING OPTIONAL
	WSDATA horaAtu AS STRING OPTIONAL
	 
	WSMETHOD GET DESCRIPTION "Busca preco dos produtos" WSSYNTAX "/preco"
	WSMETHOD PUT DESCRIPTION "Atualiza preco dos produtos" WSSYNTAX "/preco/{id}"
END WSRESTFUL

WSMETHOD GET WSRECEIVE page, limit, marketplace, productId, variantId, codigo, codbar, dataAtu, horaAtu WSSERVICE preco

Local nX
Local cAlias    := GetNextAlias()
Local cWhere  := "%"
Local cRet      := ""

If ::codigo != NIL
   cWhere += " AND SB1.B1_COD = '"+ ::codigo + "'"
EndIf

If ::codbar != NIL
   cWhere += " AND SB1.B1_CODBAR = '"+ ::codbar + "'"
EndIf

If ::marketplace != NIL
   cWhere += " AND ZDD.ZDD_CODMKT = '"+ ::marketplace + "'"
EndIf

If ::dataAtu != NIL
   cWhere += " AND ZDD.ZDD_DATA >= '"+ ::dataAtu + "'"
EndIf

If ::horaAtu != NIL
   cWhere += " AND ZDD.ZDD_HORA >= '"+ ::horaAtu + "'"
EndIf
 

cWhere += "%"

conout("PRECO - Empresa/Filial: " +cEmpAnt+"/"+cFilAnt)

// define o tipo de retorno do método
::SetContentType("application/json")
    
DEFAULT ::page := 1, ::limit := 50
  
nOffset := (::page * ::limit) - ::limit
nLimit := ::limit

BeginSQL alias cAlias
	SELECT	SB1.B1_COD, SB1.B1_DESC, SB1.B1_CODBAR, ZDD.ZDD_VARID,
			COALESCE(SB2.B2_QATU,0) AS ESTOQUE,
			COALESCE(SB2.B2_RESERVA+SB2.B2_QEMP+SB2.B2_QACLASS,0) AS RESERVA,
			COALESCE(SB2.B2_QATU-SB2.B2_RESERVA-SB2.B2_QEMP-SB2.B2_QACLASS,0) AS DISPONIVEL,
			ZDD.ZDD_PRECO, ZDD.ZDD_PRCPRM, ZDD.ZDD_DATA, ZDD.ZDD_CODMKT, ZDD.ZDD_PRODUT,
			COALESCE(DA1.DA1_PRCVEN,0) AS DA1_PRCVEN,
			ZDD.ZDD_INIOFE, ZDD.ZDD_FIMOFE, ZDD.ZDD_STATUS,
			ZDD.R_E_C_N_O_ AS ZDD_RECNO
	
	FROM %table:ZDD% (NOLOCK) ZDD
	
	INNER JOIN %table:SB1% (NOLOCK) SB1 ON SB1.B1_FILIAL = %xfilial:SB1%
										AND SB1.B1_COD = ZDD.ZDD_PRODUT
										AND SB1.%notDel%
		
	LEFT JOIN %table:SB2% (NOLOCK) SB2 ON SB2.B2_FILIAL = %xfilial:SB2%
										AND SB2.B2_COD = SB1.B1_COD
										AND SB2.B2_LOCAL = ZDD.ZDD_LOCAL
										AND SB2.%notDel%
										
	LEFT JOIN %table:DA1% (NOLOCK) DA1 ON DA1.DA1_FILIAL = %xfilial:DA1%
									AND DA1.DA1_CODTAB = ZDD.ZDD_TABELA
									AND DA1.DA1_CODPRO = ZDD.ZDD_PRODUT
									AND DA1.%notDel%
	
	WHERE ZDD.ZDD_FILIAL = %xfilial:ZDD%
	AND ZDD.ZDD_ATUPRC = 'S'
	%exp:cWhere%
	AND ZDD.%notDel%
	
	ORDER BY SB1.B1_COD
	
	OFFSET %exp:nOffset% ROWS FETCH NEXT %exp:nLimit% ROWS ONLY
EndSQL

// exemplo de retorno de uma lista de objetos JSON
::SetResponse('[')

(cAlias)->(dbGoTop())

lPrim := .T.

If (cAlias)->(!Eof())
	While (cAlias)->(!Eof())
	
		If !lPrim
			::SetResponse(',')
		EndIf
		
		Do Case
			Case (cAlias)->ZDD_STATUS == "A"; cStatus := "Ativo"
			Case (cAlias)->ZDD_STATUS == "I"; cStatus := "Inativo"
			Case (cAlias)->ZDD_STATUS == "B"; cStatus := "Bloqueado"
		EndCase
		
		If (cAlias)->ZDD_PRECO <= 0
			cStatus := "Inativo"
		EndIf
		
		::SetResponse('{')
		::SetResponse('"id": ' + ALLTRIM(STR((cAlias)->ZDD_RECNO)) + ', ')
		::SetResponse('"sku": "' + ALLTRIM((cAlias)->ZDD_VARID) + '", ')
		::SetResponse('"descricao": "' + ALLTRIM(STRTRAN((cAlias)->B1_DESC,'"','')) + '", ')
		::SetResponse('"codbar": "' + ALLTRIM((cAlias)->B1_CODBAR) + '", ')
		::SetResponse('"status": "' + cStatus + '", ')
		::SetResponse('"preco": ' + ALLTRIM(STR((cAlias)->ZDD_PRECO)) + ', ')
		::SetResponse('"preco_promocional": ' + ALLTRIM(STR((cAlias)->ZDD_PRCPRM)) + ', ')
		
		If (cAlias)->ZDD_PRCPRM > 0
			::SetResponse('"inicio_oferta": "' + (cAlias)->ZDD_INIOFE + '", ')
			::SetResponse('"fim_oferta": "' + (cAlias)->ZDD_FIMOFE + '", ')	
		EndIf
		
		::SetResponse('"preco_tabela": ' + ALLTRIM(STR((cAlias)->DA1_PRCVEN)) + ', ')
		::SetResponse('"preco_oferta": ' + ALLTRIM(STR((cAlias)->ZDD_PRCPRM)) + ', ')
		::SetResponse('"preco_custo": ' + ALLTRIM(STR((cAlias)->DA1_PRCVEN)) + ', ')
		::SetResponse('"preco_data": "' + DTOC(STOD((cAlias)->ZDD_DATA)) + '", ')
		::SetResponse('"estoqueTotal": ' + ALLTRIM(STR((cAlias)->ESTOQUE)) + ', ')
		::SetResponse('"reserva": ' + ALLTRIM(STR((cAlias)->RESERVA)) + ', ')
		::SetResponse('"estoqueDisponivel": ' + ALLTRIM(STR((cAlias)->DISPONIVEL)) + ', ')
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

WSMETHOD PUT WSSERVICE preco

Local lPut := .T.

// Exemplo de retorno de erro
If Len(::aURLParms) == 0
	SetRestFault(400, "É obrigatório informar o id do preco")
	lPut := .F.
Else
	nRecno := VAL(::aUrlParms[1])

	ConOut("[PRECO] - Confirmacao de preco recebido no Vtrina - Empresa/Filial: " +cEmpAnt+ "/" +cFilAnt+ " ("+Time()+")")
	
	dbSelectArea("ZDD")
	dbGoTo(nRecno)
	
	Reclock("ZDD",.F.)
	ZDD->ZDD_ATUPRC := ''
	ZDD->(MsUnlock())
		
	::SetResponse('"Preco atualizado"')
EndIf

Return lPut
