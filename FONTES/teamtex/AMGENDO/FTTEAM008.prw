#INCLUDE 'TOTVS.CH'
#INCLUDE "TRYEXCEPTION.CH"

//----------------------------------------------------------------
/*/{Protheus.doc} FTTEAM08
Servico Impotaçao Pedidos Magento
@author TRIYO
@since 23/04/2021
@type function
@version 1.0
/*/
//----------------------------------------------------------------

User Function FTTEAM08(lReprocess, lLote, cIdReg, cIdPZC, cEmpPrep, cFilPrep)

Local _cID		:= ""
Local _cID2		:= ""
Local _cTES		:= "501"
Local _cClie	:= ""
Local _cProd	:= ""
Local cError	:= ""
Local cWKArea	:= ""
Local _cEmiss	:= ""
Local _cStatus	:= ""
Local _cQuotID	:= ""
Local cSession	:= ""
Local cSessio2	:= ""
Local cWarning	:= ""
Local _cValEntg := ""

Local _nX		:= 0
Local _nY		:= 0
Local _nW		:= 0
Local _nItem	:= 0
Local nQtdReg	:= 0

Local _aIDs		:= {}
Local _aRet		:= {}
Local _aCab		:= {}
Local _aAux		:= {}
Local aTntic	:= {}
Local _aItens	:= {}
Local aSimple	:= {}
Local aComplex 	:= {}
Local _aRetCli	:= {}

Local oParse
Local oWSMgnt
Local oWSIntl
Local oResult
Local cContent  := {}
Local oBilling := nil
Local oShipping := nil
//Local cBillA1 := ""
//Local cShippA1 := ""
Local cBillC5a := ""
Local cBillC5b := ""
Local cShippC5a := ""
Local cShippC5b := ""
Local nValor    := 0
Local nImposto  := 1.05
Local nTotal    := 0
Local nDiscount := 0
Local cTranport := ""
Local cPostagem := ""
Local cCodSA4 := ""

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

aCrSrv 	:= U_MonitRes("000005", 1, 0)
cIdPZB	:= aCrSrv[2]

TRYEXCEPTION

	aTntic		:= U_FTTEAM03()
	cWKArea		:= GetNextAlias()
	oWSMgnt		:= aTntic[1]
	cSession	:= aTntic[2]

	If Empty(cSession)
		//aCrSrv 	:= U_MonitRes("000005", 1, 0)
		//cIdPZB	:= aCrSrv[2]
		U_MonitRes("000005", 2, 0, cIdPZB, "Não foi possível autenticar. Verifique Login e Senha nos parametros FT_MGNTUSR e FT_MGNTKEY. ", .F.,"", "", "", "", .F., .F., "", .F., .F., .F.)
		U_MonitRes("000005", 3, 0, cIdPZB, "", .F.)
		Return
	EndIf

	DBSelectArea("SC5")
	SC5->(DBSetOrder(11))

	oWSMgnt:SetOperation("salesOrderList")	
	aComplex    := oWSMgnt:NextComplex()

	While ValType( aComplex ) == "A"
		xRet := oWSMgnt:SetComplexOccurs( aComplex[1],0)
		/*
		If AllTrim(aComplex[2]) == "filter"
			xRet := oWSMgnt:SetComplexOccurs( aComplex[1],1)
		Else
			xRet := oWSMgnt:SetComplexOccurs( aComplex[1],0)
		EndIf	
		*/
		aComplex := oWSMgnt:NextComplex()

	EndDo

	aSimple := oWSMgnt:SimpleInput()

	oWSMgnt:SetValue( aSimple[1][1],cSession)

	oWSMgnt:GetSoapMsg()
	oWSMgnt:SendSoapMsg()

	oResult := oWSMgnt:GetSoapResponse()
	oParse	:= XmlParser( oResult, "_", @cError, @cWarning )

	If ValType(XmlChildEx(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY,"_SOAP_ENV_FAULT")) <> "O"
		For _nX := 1 To Len(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERLISTRESPONSE:_RESULT:_ITEM) 
			_cStatus := AllTrim(UPPER(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERLISTRESPONSE:_RESULT:_ITEM[_nX]:_STATUS:TEXT))
			If _cStatus == "PROCESSING" .AND. !SC5->(DBSeek(xFilial("SC5")+AllTrim(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERLISTRESPONSE:_RESULT:_ITEM[_nX]:_INCREMENT_ID:TEXT)))
				AADD( _aIDs, OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERLISTRESPONSE:_RESULT:_ITEM[_nX]:_INCREMENT_ID:TEXT)
				nQtdReg++
			EndIf
		Next _nX
	Else
		U_MonitRes("000005", 2, 0, cIdPZB, AllTrim(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_SOAP_ENV_FAULT:_FAULTSTRING:TEXT), .F., "", "", "", "", .F., .F., "", .F., .F., .F.)		
		Return
	EndIf

	If nQtdReg <= 0
		aCrSrv 	:= U_MonitRes("000005", 1, 0)
		cIdPZB	:= aCrSrv[2]
		U_MonitRes("000005", 2, 0, cIdPZB, "Não há registros a serem integrados.", .F.,"", "", "", "", .F., .F., "", .F., .F., .F.)
		U_MonitRes("000005", 3, 0, cIdPZB, "", .T.)
		Return 
	EndIf

	aCrSrv 	:= U_MonitRes("000005", 1, nQtdReg)
	cIdPZB	:= aCrSrv[2]

	DBSelectArea("SA1")
	DBSelectArea("SB1")
	SB1->(DBSetOrder(16))

	For _nY := 1 To Len(_aIDs)

		_cID := AllTrim(_aIDs[_nY])

		oWSMgnt:SetOperation("salesOrderInfo")	
		aComplex    := oWSMgnt:NextComplex()

		While ValType( aComplex ) == "A"
			xRet := oWSMgnt:SetComplexOccurs( aComplex[1],0)
			aComplex := oWSMgnt:NextComplex()
		EndDo

		aSimple := oWSMgnt:SimpleInput()
		//ConOut( VarInfo('aSimple',aSimple) )
		oWSMgnt:SetValue( aSimple[1][1],cSession)
		oWSMgnt:SetValue( aSimple[2][1],_cID)

		oWSMgnt:GetSoapMsg()
		oWSMgnt:SendSoapMsg()

		oResult := oWSMgnt:GetSoapResponse()
		cContent := oResult
		oParse	:= XmlParser( oResult, "_", @cError, @cWarning )
		_cID2	:= OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ORDER_ID:TEXT
		_cClie 	:= OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_CUSTOMER_ID:TEXT
		_cEmiss := SUBSTR(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_CREATED_AT:TEXT,1,10)
		_cEmiss := AllTrim(STRTRAN(_cEmiss,"-",""))
		// Tratamento Transportadora - SA4
		//cTranport := OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_SHIPPING_METHOD:TEXT
		cPostagem := OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_SHIPPING_DESCRIPTION:TEXT
		cTranport := SubStr(cPostagem,1,At("-",cPostagem)-1)

		oBilling := OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_BILLING_ADDRESS
		oShipping := OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_SHIPPING_ADDRESS
		//cBillA1 := OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_BILLING_ADDRESS_ID:TEXT
		//cShippA1 := OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_SHIPPING_ADDRESS_ID:TEXT		
		_aRetCli := U_FTTEAM07(_cClie,,,,,,, oBilling, oShipping)

		SA1->(DBSetOrder(14))
		SA1->(DbGoTop())
		if SA1->(DbSeek(xFilial("SA1")+_aRetCli[3]))
			cBillC5a := SA1->A1_COD
			cBillC5b := SA1->A1_LOJA
		Endif
		SA1->(DbGoTop())
		if SA1->(DbSeek(xFilial("SA1")+_aRetCli[4]))
			cShippC5a := SA1->A1_COD
			cShippC5b := SA1->A1_LOJA
		Endif

		If !_aRetCli[1]
			U_MonitRes("000005", 2, 0, cIdPZB, "Problemas ao cadastrar cliente: " + AllTrim(_aRetCli[2]), .T.,"", cValToChar(cContent), _aRetCli[2], "", .F., .F., "", .F., .F., .F.)
			U_MonitRes("000005", 3, 0, cIdPZB, "", .F.)
			Loop
		EndIf
		DBSelectArea("SE4")
		SE4->(DBSetOrder(1))
		SE4->(DbGoTop())
		SE4->(DbSeek(xFilial("SE4")+"001"))

		aAdd(_aCab,{"C5_FILIAL"	, xFilial("SC5")						, Nil})
		aAdd(_aCab,{"C5_EMISSAO"	, StoD(_cEmiss)						, Nil})
		aAdd(_aCab,{"C5_TIPO"   	, "N"                     			, Nil})
		aAdd(_aCab,{"C5_CLIENTE"	, cBillC5a               			, Nil})
		aAdd(_aCab,{"C5_LOJACLI"    , cBillC5b      					, Nil})
		aAdd(_aCab,{"C5_CLIENT"		, cShippC5a               			, Nil})
		aAdd(_aCab,{"C5_LOJAENT"	, cShippC5b      					, Nil})
		aAdd(_aCab,{"C5_TIPOCLI"	, SA1->A1_TIPO            			, Nil})
		aAdd(_aCab,{"C5_CONDPAG"	, SE4->E4_CODIGO           			, Nil})

		// Tratamento Transportadora
		ConOut("Localizando Transportadora = " + cTranport)
		cCodSA4 := RetSA4Cod(cTranport)
		aAdd(_aCab,{"C5_TRANSP" 	, cCodSA4    						, Nil})
		aAdd(_aCab,{"C5_TPFRETE" 	, "F"           					, Nil})
		
		aAdd(_aCab,{"C5_PARC1"  	, 100                     			, Nil})
		aAdd(_aCab,{"C5_DATA1"  	, StoD(_cEmiss)           			, Nil})
		aAdd(_aCab,{"C5_XIDMGT" 	, _cID           					, Nil})
		aAdd(_aCab,{"C5_XENTRG" 	, Alltrim(cPostagem)				, Nil})
		aAdd(_aCab,{"C5_TIPLIB" 	, "1"                     			, Nil}) 
		
		_nItem := 1
		
		If ValType(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM) == "O"
			
			_cProd 	:= AllTrim(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM:_PRODUCT_ID:TEXT) 
			_nQtd  	:= VAL(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM:_QTY_INVOICED:TEXT)
			_nVunit	:= VAL(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM:_PRICE:TEXT)
			nDiscount := VAL(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM:_DISCOUNT_AMOUNT:TEXT)
			If ValType(nDiscount) == "N"
				nValor    := _nVunit - (nDiscount / _nQtd)
			Else
				nValor    := _nVunit
			Endif
			nImposto  := 1.05
			nTotal    := Round(nValor / nImposto, 2)			
			
			SB1->(DBSetOrder(16))
			
			If SB1->(DBSeek(xFilial("SB1")+_cProd))

				_aAux := 	{{"C6_FILIAL", xFilial("SC6") 				, Nil},;
							{"C6_ITEM"   , STRZERO(_nItem,2)			, Nil},;
							{"C6_PRODUTO", SB1->B1_COD					, Nil},;
							{"C6_QTDVEN" , _nQtd						, Nil},;
							{"C6_PRCVEN" , nTotal						, Nil},;
							{"C6_PRUNIT" , nTotal						, Nil},;
							{"C6_VALOR"  , (nTotal * _nQtd)			, Nil},;
							{"C6_TES"    , _cTES	    				, Nil},;
							{"C6_REVISAO", "003"	    				, Nil},;
							{"C6_ENTREG" , StoD(_cEmiss)   				, Nil}} 
								
				AADD(_aItens,_aAux)
			Else
				U_MonitRes("000005", 2, 0, cIdPZB, "Produto não encontrado: " + _cProd, .F.,"ID Magento: " + _cID, "", "", "", .F., .F., "", .F., .F., .F.)
				U_MonitRes("000005", 3, 0, cIdPZB, "", .F.)
				_aItens := {}
			EndIf

		Else
			For _nW := 1 To Len(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM) 

				_cProd 	:= AllTrim(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM[_nW]:_PRODUCT_ID:TEXT) 
				_nQtd  	:= VAL(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM[_nW]:_QTY_INVOICED:TEXT)
				_nVunit	:= VAL(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM[_nW]:_PRICE:TEXT)
				nDiscount := VAL(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM[_nW]:_DISCOUNT_AMOUNT:TEXT)
				If ValType(nDiscount) == "N"
					nValor    := _nVunit - (nDiscount / _nQtd)
				Else
					nValor    := _nVunit
				Endif
				nImposto  := 1.05
				nTotal    := Round(nValor / nImposto, 2)

				SB1->(DBSetOrder(16))
				
				If SB1->(DBSeek(xFilial("SB1")+_cProd))

					_aAux := 	{{"C6_FILIAL", xFilial("SC6") 				, Nil},;
								{"C6_ITEM"   , STRZERO(_nItem,2)			, Nil},;
								{"C6_PRODUTO", SB1->B1_COD					, Nil},;
								{"C6_QTDVEN" , _nQtd						, Nil},;
								{"C6_PRCVEN" , nTotal						, Nil},;
								{"C6_PRUNIT" , nTotal						, Nil},;
								{"C6_VALOR"  , (nTotal * _nQtd)			, Nil},;
								{"C6_TES"    , _cTES	    				, Nil},;
								{"C6_REVISAO", "003"	    				, Nil},;
								{"C6_ENTREG" , StoD(_cEmiss)   				, Nil}} 
								
					AADD(_aItens,_aAux)
					_nItem++
					_aAux := {}

				Else
					U_MonitRes("000005", 2, 0, cIdPZB, "Produto não encontrado: " + _cProd, .F.,"ID Magento: " + _cID, "", "", "", .F., .F., "", .F., .F., .F.)
					U_MonitRes("000005", 3, 0, cIdPZB, "", .F.)
					_aItens := {}
					EXIT
				EndIf

			Next _nW

		EndIf
		
		If Len(_aItens) > 0
			oWSIntl := TWsdlManager():New()
			oWSIntl:nTimeout := 120
			oWSIntl:lVerbose := .T.

			oWSIntl:ParseURL("https://www.cadeiraparaauto.com.br/api/soap/?wsdl")
			oWSIntl:SetOperation("login")
			oWSIntl:bNoCheckPeerCert := .T.

			aComplex    := oWSIntl:NextComplex()
			aSimple     := oWSIntl:SimpleInput()

			oWSIntl:SetValue( aSimple[1][1],GetMV('FT_MGNTUSR',,'tryio'))
			oWSIntl:SetValue( aSimple[2][1],GetMV('FT_MGNTKEY',,'JBOfqoBwQ2Ex'))

			oWSIntl:GetSoapMsg()
			oWSIntl:SendSoapMsg()

			oResult := oWSIntl:GetSoapResponse()
			oPARSE := XmlParser( oResult, "_", @cError, @cWarning )	
			cSessio2 := OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_LOGINRESPONSE:_LOGINRETURN:TEXT

			_cSoapInt := '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="urn:Magento" xmlns:ns2="http://xml.apache.org/xml-soap" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">' + CRLF   
			_cSoapInt += 	'<SOAP-ENV:Body>' + CRLF   
			_cSoapInt += 		'<ns1:call>' + CRLF
			_cSoapInt += 			'<sessionId xsi:type="xsd:string">' 
			_cSoapInt += cSessio2
			_cSoapInt += 			'</sessionId>' + CRLF
			_cSoapInt += 			'<resourcePath xsi:type="xsd:string">ferramenta.getintelipostdata</resourcePath>' + CRLF
			_cSoapInt += 			'<args soap-enc:arraytype="ns2:Map[1]" xsi:type="SOAP-ENC:Array">' + CRLF
			_cSoapInt += 				'<item xsi:type="ns2:Map">' + CRLF
			_cSoapInt += 					'<item>' + CRLF
			_cSoapInt += 						'<key xsi:type="xsd:string">id</key>' + CRLF
			_cSoapInt += 						'<value xsi:type="xsd:int">'
			_cSoapInt += _cID2
			//_cSoapInt += '97'
			_cSoapInt += 						'</value>' + CRLF
			_cSoapInt += 					'</item>' + CRLF
			_cSoapInt += 				'</item>' + CRLF
			_cSoapInt += 			'</args>' + CRLF
			_cSoapInt += 		'</ns1:call>' + CRLF
			_cSoapInt += 	'</SOAP-ENV:Body>' + CRLF
			_cSoapInt += '</SOAP-ENV:Envelope>'

			oWSIntl:SetOperation("call")
			oWSIntl:SendSoapMsg(_cSoapInt)

			oResult := oWSIntl:GetSoapResponse()
			oPARSE := XmlParser( oResult, "_", @cError, @cWarning )	

			_cQuotID	:= OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CALLRESPONSE:_CALLRETURN:_ITEM:_ITEM[1]:_VALUE:TEXT
			_cValEntg	:= OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CALLRESPONSE:_CALLRETURN:_ITEM:_ITEM[4]:_VALUE:TEXT

			AADD(_aCab,{"C5_XQUTMGT",_cQuotID		,Nil})
			AADD(_aCab,{"C5_XVALETG",VAL(_cValEntg)	,Nil})
			BEGIN TRANSACTION
				If Len(_aItens) > 0
					_aRet := IncPed(_aCab,_aItens)
				EndIf
			END TRANSACTION
		EndIf
		
		_aItens := {}

		If _aRet[1]
			U_MonitRes("000005", 2, 0, cIdPZB, "ID: " + _cID + ". Integrado com sucesso.", .T.,"ID Magento: " + _cID, cValToChar(cContent), "", "", .F., .F., "", .F., .F., .F.)
			U_MonitRes("000005", 3, 0, cIdPZB, "", .T.)
		Else
			U_MonitRes("000005", 2, 0, cIdPZB, _aRet[2], .F.,"ID Magento: " + _cID, cValToChar(cContent), _aRet[2], "", .F., .F., "", .F., .F., .F.)	
			U_MonitRes("000005", 3, 0, cIdPZB, "", .F.)
		EndIf

	Next _nY

CATCHEXCEPTION USING oException

	ConOut("FTTEAM008.PRW:LOG"+Time()+CRLF+oException:Description)

	U_MonitRes("000005", 2, 0, cIdPZB, oException:Description, .F., "FTTEAM008.PRW:LOG"+Time(), "Error", oException:Description, "", .F., .F., "", .F., .F., .F.)
	//Finaliza o processo na PZB - Error
	U_MonitRes("000005", 3, 0, cIdPZB, "", .F.)

ENDEXCEPTION

RpcClearEnv()
Return

//----------------------------------------------------------------
/*/{Protheus.doc} IncPed
Inclusao do Pedido
@author TRIYO
@since 23/04/2021
@type function
@version 1.0
/*/
//----------------------------------------------------------------

Static Function IncPed(_aCab,_aItens)

Local cStrErro	:= ""

Local nErro		:= 0

Local _aRet		:= {}
Local aErros	:= {}

Private lMsHelpAuto		:= .T.
Private lMsErroAuto 	:= .F.
Private lAutoErrNoFile 	:= .T.

_aCab 	:= FWVetByDic(_aCab,"SC5",.F.) //Organiza o array
_aItens := FWVetByDic(_aItens,"SC6",.T.) //Organiza o array
//VarInfo('_aCab',_aCab)
//VarInfo('_aItens',_aItens)
MsExecAuto({|x, y, z| MATA410(x, y, z)}, _aCab, _aItens, 3)

If lMsErroAuto
	cStrErro 	:= ""
	aErros		:= GetAutoGRLog() // retorna o erro encontrado no execauto.
	//nErro   	:= Ascan(aErros, {|x| "INVALIDO" $ alltrim(Upper(x))  } )

	//If nErro > 0
	//	cStrErro += aErros[ nErro ]
	//Else
		cStrErro += "[Error]"  + CRLF 
		For nErro := 1 To Len( aErros )
			cStrErro += ( aErros[ nErro ] + CRLF )
		Next nErro
		cStrErro += CRLF + "[ExecAuto]-Cabeçalho" + CRLF
		aEval(_aCab,{|z| cStrErro += z[1]+ " = " + cValToChar(z[2]) + CRLF})
		cStrErro += CRLF + "[ExecAuto]-Item 1" + CRLF
		aEval(_aItens[1],{|z| cStrErro += z[1]+ " = " + cValToChar(z[2]) + CRLF})
	//EndIf

	cStrErro := Alltrim(cStrErro)
	RollBackSX8()
	
	AADD(_aRet,.F.)
	AADD(_aRet,cStrErro)
Else
	ConfirmSx8()
	AADD(_aRet,.T.)
	
EndIf

Return _aRet

Static Function RetSA4Cod(cTransp)
Local cCod := ""
Local cTemp := GetNextAlias()
Local _cQry := ""
Default cTransp := ""

	_cQry := " SELECT A4_COD "
	_cQry += "	FROM " + RetSQLName("SA4")
	_cQry += "  WHERE A4_FILIAL  = '" + xFilial("SA4") + "' "
	_cQry += "	 AND A4_XCODMGT = '"+Alltrim(cTransp)+"' "
	_cQry += "	 AND D_E_L_E_T_ != '*' "

	If Select(cTemp) > 0
		(cTemp)->(DBCloseArea())
	Endif
			
	_cQry := ChangeQuery(_cQry)
	DBUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),cTemp,.T.,.T.)	
	DbSelectArea(cTemp)
	(cTemp)->(DbGoTop())
	While (cTemp)->(!Eof())
		cCod := (cTemp)->A4_COD
		(cTemp)->(DbSkip())
	End
	(cTemp)->(DBCloseArea())
Return cCod
