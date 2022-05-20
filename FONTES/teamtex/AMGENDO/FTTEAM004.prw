#INCLUDE 'TOTVS.CH'
#INCLUDE "TRYEXCEPTION.CH"

//----------------------------------------------------------------
/*/{Protheus.doc} FTTEAM04
Carga de Preço Magento
@author TRIYO
@since 23/04/2021
@version 1.0
@type function
/*/
//----------------------------------------------------------------

User Function FTTEAM04(lReprocess, lLote, cIdReg, cIdPZC, cEmpPrep, cFilPrep)

Local cJson     := ""
Local cCFOP		:= ""
Local cQuery    := ""
Local cToken    := ""
Local cCreate	:= ""
Local cAlsQry   := ""
Local cQuery2   := ""
Local cJsoRec	:= ""
Local cAlsQry2  := ""

Local _nPeso	:= 0
Local _nLarg	:= 0
Local _nAltu	:= 0
Local _nComp	:= 0
Local nQtdReg	:= 0
Local _nQtdPrd	:= 0
Local _nValPrd	:= 0

Local aHeader   := {}
Local aRequest  := {}

Private aCrSrv 	:= {}
Private cIdPZB	:= ""

DEFAULT cIdReg		:= ""
DEFAULT cIdPZC		:= ""
DEFAULT cEmpPrep    := "01"
DEFAULT cFilPrep    := "02"

DEFAULT lLote		:= .F.
DEFAULT lReprocess	:= .F.

RpcSetType(3)
RpcSetEnv(cEmpPrep,cFilPrep,,"FAT")

//aCrSrv 	:= U_MonitRes("000001", 1, 0)
//cIdPZB	:= aCrSrv[2]

//TRYEXCEPTION

	cAlsQry	 := GetNextAlias()
	cAlsQry2 := GetNextAlias()

	cQuery := " SELECT PR1_RECNO AS RECNOSF2, PR1_CHAVE, PR1_TIPREQ, R_E_C_N_O_ AS RECNOPR1 "
	cQuery += "	FROM " + RetSQLName("PR1")
	cQuery += "  WHERE PR1_FILIAL  = '" + xFilial("PR1") + "' "
	cQuery += "	 AND PR1_ALIAS = 'SF2' "
	cQuery += "	 AND PR1_STINT = 'P' "
	cQuery += "	 AND D_E_L_E_T_ = '' "

	If Select(cAlsQry) > 0
		(cAlsQry)->(DBCloseArea())
	Endif
		
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)	

	nQtdReg := Contar(cAlsQry,"!EOF()")

	If nQtdReg <= 0
		aCrSrv 	:= U_MonitRes("000001", 1, 0)
		cIdPZB	:= aCrSrv[2]
		U_MonitRes("000001", 2, 0, cIdPZB, "Não há registros a serem integrados.", .F.,"", "", "", "", .F., .F., "", .F., .F., .F.)
		U_MonitRes("000001", 3, 0, cIdPZB, "", .F.)
		Return
	EndIf

	aCrSrv 	:= U_MonitRes("000001", 1, nQtdReg)
	cIdPZB	:= aCrSrv[2]

	cToken	:= GETMV('FT_TKINTPL',,'885aeab62ca32b0cdc294765767ef3834d89ad46d30da3651accbcf30912793a')
	//Adiciona dados ao Header
	AADD(aHeader, "plugin:" + "intelipost-plugin" )
	AADD(aHeader, "api-key:" + cToken )
	AADD(aHeader, "platform:" + "intelipost-docs" )
	AADD(aHeader, "Content-Type:" + "application/json" )
	AADD(aHeader, "plugin-version:" + "v2.0.0" )
	AADD(aHeader, "platform-version:" + "v1.0.0" )

	(cAlsQry)->(DBGoTop())
	DBSelectArea("SF2")

	DBSelectArea("SC5")
	SC5->(DBSetOrder(10))

	DBSelectArea("SA1")
	SA1->(DBSetOrder(1))

	While (cAlsQry)->(!EOF())
		_nPeso		:= 0
		_nLarg		:= 0
		_nAltu		:= 0
		_nComp		:= 0
		_nQtdPrd 	:= 0
		_nValPrd	:= 0
		SF2->(DBGoTo((cAlsQry)->RECNOSF2))

		If Empty(SF2->F2_CHVNFE) 
			(cAlsQry)->(DBSkip())
			Loop
		EndIf

		SC5->(DBSeek(xFilial("SC5")+SF2->F2_DOC+SF2->F2_CLIENTE))
		SA1->(DBSeek(xFilial("SA1")+SF2->F2_CLIENT+SF2->F2_LOJENT))

		cQuery2 := " SELECT B5_XPESCUB, B5_XLARMAS, B5_XALTMAS, B5_XECCOME, C6_QTDVEN, C6_CF, C6_VALOR, B1_PESBRU "
		cQuery2 += "   FROM " + RetSQLName("SC6") + " SC6 "
		cQuery2 += "  INNER JOIN " + RetSQLName("SB5") + " SB5 "
		cQuery2 += "	 ON B5_COD = C6_PRODUTO "
		cQuery2 += "  INNER JOIN " + RetSQLName("SB1") + " SB1 "
		cQuery2 += "	 ON B1_COD = C6_PRODUTO "
		cQuery2 += "  WHERE C6_FILIAL = '" + SF2->F2_FILIAL + "' "
		cQuery2 += "    AND C6_NOTA = '" + SF2->F2_DOC + "' "
		cQuery2 += "    AND C6_SERIE = '" + SF2->F2_SERIE + "' "
		cQuery2 += "    AND C6_CLI = '" + SF2->F2_CLIENTE + "' "
		cQuery2 += "    AND C6_LOJA = '" + SF2->F2_LOJA + "' "
		cQuery2 += "    AND B5_FILIAL = '" + xFilial("SB5") + "' "
		cQuery2 += "    AND SC6.D_E_L_E_T_ = ' ' "
		cQuery2 += "    AND SB5.D_E_L_E_T_ = ' ' "
		cQuery2 += "    AND SB1.D_E_L_E_T_ = ' ' "

		If Select(cAlsQry2) > 0
			(cAlsQry2)->(DBCloseArea())
		Endif
		
		cQuery2 := ChangeQuery(cQuery2)
		DBUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery2),cAlsQry2,.T.,.T.)

		cCFOP := (cAlsQry2)->C6_CF

		While (cAlsQry2)->(!EOF())
			_nPeso		:= ((cAlsQry2)->B1_PESBRU + _nPeso)
			_nLarg		:= ((cAlsQry2)->B5_XLARMAS + _nLarg)
			_nAltu		:= ((cAlsQry2)->B5_XALTMAS + _nAltu)
			_nComp		:= ((cAlsQry2)->B5_XECCOME + _nComp)
			_nQtdPrd 	:= ((cAlsQry2)->C6_QTDVEN + _nQtdPrd)
			_nValPrd	:= ((cAlsQry2)->C6_VALOR + _nValPrd)
			(cAlsQry2)->(DBSkip())
		EndDo

		(cAlsQry2)->(DBCloseArea())

		cCreate := SUBSTR(DtoS(SC5->C5_EMISSAO),1,4) + "-" + SUBSTR(DtoS(SC5->C5_EMISSAO),5,2) + "-" + SUBSTR(DtoS(SC5->C5_EMISSAO),7,2)
		cCreate += "T" + AllTrim(TIME())

		cJson := "{"
			cJson += '"order_number":"' + AllTrim(SC5->C5_XIDMGT) + '",'
			cJson += '"customer_shipping_costs":' + cValToChar(SF2->F2_FRETE) + ','
			cJson += '"sales_channel": "Marketplace",'	
			cJson += '"scheduled":"false",'
			cJson += '"created":"' + cCreate + '",'
			cJson += '"shipment_order_type": "NORMAL",'
			cJson += '"delivery_method_id":' + cValToChar(51) + ','
			cJson += '"delivery_method_external_id":' + cValToChar(1) + ','
			cJson += '"end_customer":' 
			cJson += "{"
				cJson += '"first_name":"' + AllTrim(SA1->A1_NOME) + '",'
				cJson += '"last_name":".",'
				cJson += '"email":"' + AllTrim(SA1->A1_EMAIL) + '",'
				cJson += '"phone":"' +AllTrim(STRTRAN(STRTRAN(SA1->A1_TEL,")",""),"-","")) + '",'	
				cJson += '"cellphone":"' + AllTrim(STRTRAN(STRTRAN(SA1->A1_TEL,")",""),"-","")) + '",'
				cJson += '"is_company":' + IIF(SA1->A1_PESSOA == "J","true","false") + ','	
				cJson += '"federal_tax_payer_id":"' + AllTrim(SA1->A1_CGC) + '",'
				cJson += '"shipping_country":"' + POSICIONE("CCH",1,xFilial("CCH")+SA1->A1_CODPAIS,"CCH_PAIS") + '",'
				cJson += '"shipping_state":"' + AllTrim(SA1->A1_EST) + '",'	
				cJson += '"shipping_city":"' + AllTrim(SA1->A1_MUN) + '",'
				cJson += '"shipping_address":"' + AllTrim(SUBSTR(SA1->A1_END,1,AT(",",SA1->A1_END)-1)) + '",'
				cJson += '"shipping_number":"' + AllTrim(SUBSTR(SA1->A1_END,AT(",",SA1->A1_END)+1)) + '",'
				cJson += '"shipping_quarter":"' + AllTrim(SA1->A1_BAIRRO) + '",'
				cJson += '"shipping_zip_code":"' + AllTrim(SA1->A1_CEP) + '"'
			cJson += "},"
			cJson += '"shipment_order_volume_array":'
			cJson += "[{"
				cJson += '"shipment_order_volume_number":' + cValToChar(1) + ','
				cJson += '"volume_type_code": "box",'
				cJson += '"weight":' + Alltrim(StrTran(Transform(_nPeso,"@E 9999.999"),",",".")) + ','
				cJson += '"width":' + Alltrim(StrTran(Transform(_nLarg*100,"@E 9999.999"),",",".")) + ','
				cJson += '"height":' + Alltrim(StrTran(Transform(_nAltu*100,"@E 9999.999"),",",".")) + ','
				cJson += '"length":' + Alltrim(StrTran(Transform(_nComp*100,"@E 9999.999"),",",".")) + ','
				cJson += '"products_nature": "produtos",'
				cJson += '"products_quantity":' + cValToChar(_nQtdPrd) + ','
				cJson += '"is_icms_exempt":' + cValToChar(1) + ','
				cJson += '"tracking_code": " ",'
				cJson += '"shipment_order_volume_invoice":'
				cJson += "{"
					cJson += '"invoice_series":"' + AllTrim(SF2->F2_SERIE) + '",'
					cJson += '"invoice_number":"' + AllTrim(SF2->F2_DOC) + '",'
					cJson += '"invoice_key":"' + AllTrim(SF2->F2_CHVNFE) + '",'
					cJson += '"invoice_date":"' + SUBSTR(DtoS(SF2->F2_EMISSAO),1,4) + "-" + SUBSTR(DtoS(SF2->F2_EMISSAO),5,2) + "-" + SUBSTR(DtoS(SF2->F2_EMISSAO),7,2) + '",'
					cJson += '"invoice_total_value":"' + Alltrim(StrTran(Transform(SF2->F2_VALBRUT,"@E 999999999.99"),",",".")) + '",'
					cJson += '"invoice_products_value":"' + Alltrim(StrTran(Transform(_nValPrd,"@E 999999999.99"),",",".")) + '",'
					cJson += '"invoice_cfop":"' + AllTrim(cCFOP) + '"'
				cJson += "}"
			cJson +="}],"
			cJson += '"quote_id":"' + AllTrim(SC5->C5_XQUTMGT) + '"'
		cJson += "}"

		//Envia pedido ao Intelipost
		aRequest := U_ResInteg("000001", cJson, aHeader,, .T., "/shipment_order")
		
		//JSON retornado pelo INTELIPOST
		cJsoRec := aRequest[3] 

		//Se requisição efetuada com sucesso
		If aRequest[1]
			//Loga mensagem de sucesso no monitor de integrações
			U_MonitRes("000001", 2, , cIdPZB, "Registro atualizado com sucesso.", .T., AllTrim((cAlsQry)->RECNOSF2), cJson, cJsoRec, "Pedido Intelipost", lReprocess, lLote, cIdPZC)
			U_MonitRes("000001", 3, , cIdPZB, , .T.)

			PR1->(DbGoTo((cAlsQry)->RECNOPR1))
			PR1->(RecLock("PR1",.F.))
				PR1->PR1_STINT := "I"
			PR1->(MsUnlock())
		Else
			//Loga mensagem de Erro no monitor de integrações
			U_MonitRes("000001", 2, , cIdPZB, "Registro com Erro.", .F., AllTrim((cAlsQry)->RECNOSF2), cJson, cJsoRec, "Pedido Intelipost", lReprocess, lLote, cIdPZC)
			U_MonitRes("000001", 3, , cIdPZB, , .T.)

			PR1->(DbGoTo((cAlsQry)->RECNOPR1))
			PR1->(RecLock("PR1",.F.))
				PR1->PR1_STINT := "E"
			PR1->(MsUnlock())
		EndIf
		
		(cAlsQry)->(DBSkip())

	EndDO
/*
CATCHEXCEPTION USING oException

	ConOut("FTTEAM004.PRW:LOG"+Time()+CRLF+oException:Description)
	aCrSrv 	:= U_MonitRes("000001", 1, 0)
	cIdPZB	:= aCrSrv[2]
	U_MonitRes("000001", 2, 0, cIdPZB, oException:Description, .F., "FTTEAM004.PRW:LOG"+Time(), "Error", oException:Description, "", .F., .F., "", .F., .F., .F.)
	//Finaliza o processo na PZB - Error
	U_MonitRes("000001", 3, , cIdPZB, , .F.)

ENDEXCEPTION
*/
RpcClearEnv()
Return(.T.)
