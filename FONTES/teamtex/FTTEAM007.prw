#INCLUDE 'TOTVS.CH'
#INCLUDE "TRYEXCEPTION.CH"

//----------------------------------------------------------------
/*/{Protheus.doc} FTTEAM07
@author TRIYO
@since 23/04/2021
@version 1.0
@type function
/*/
//----------------------------------------------------------------

User Function FTTEAM07(cID, lReprocess, lLote, cIdReg, cIdPZC, cEmpPrep, cFilPrep, oBill, oShip)

Local _cCGC		:= ""
Local _cCEP		:= ""
Local _cTel		:= ""
Local _cID     	:= ""
Local _cLoc		:= ""
Local _cEst		:= ""
Local _cNome	:= ""
Local _cMail	:= ""
Local _cPesoa	:= ""
Local cError	:= ""
Local cWKArea	:= ""
Local cSession	:= ""
Local cWarning	:= ""
Local _cAuxEnd	:= ""

Local _nX		:= 0
Local _nY	    := 0
Local _nOPC		:= 3
Local nQtdReg	:= 0

Local _aRet		:= {}
Local aTntic	:= {}
Local aSimple	:= {}
Local a1Venda   := ""
Local a1Envio   := ""
Local _aDados	:= {}
Local aComplex 	:= {}
Local cNum      := ""
Local Loja      := ""

Local _lRet		:= .T.

Local oLoc
Local oParse
Local oWSMgnt
Local oResult
Local cContent 	:= ""
Local nPos    := 0

Private aCrSrv 	  := {}
Private cIdPZB	  := ""
Private aDestinos := {}
Private lNewNum   := .F.

DEFAULT cIdReg		:= ""
DEFAULT cIdPZC		:= ""
DEFAULT cEmpPrep    := "01"
DEFAULT cFilPrep    := "02"
DEFAULT lLote		:= .F.
DEFAULT lReprocess	:= .F.

//RPCSETENV(cEmpPrep,cFilPrep)

aCrSrv 	:= U_MonitRes("000004", 1, 0)
cIdPZB	:= aCrSrv[2]

TRYEXCEPTION

	aTntic		:= U_FTTEAM03()
	cWKArea		:= GetNextAlias()
	oWSMgnt		:= aTntic[1]
	cSession	:= aTntic[2]

	If Empty(cSession)
		aCrSrv 	:= U_MonitRes("000004", 1, 0)
		cIdPZB	:= aCrSrv[2]
		U_MonitRes("000004", 2, 0, cIdPZB, "Não foi possível autenticar. Verifique Login e Senha nos parametros FT_MGNTUSR e FT_MGNTKEY. ", .F.,"", "", "", "", .F., .F., "", .F., .F., .F.)
		U_MonitRes("000004", 3, 0, cIdPZB, "", .F.)
		Return _lRet
	EndIf

	aCrSrv 	:= U_MonitRes("000004", 1, nQtdReg)
	cIdPZB	:= aCrSrv[2]

	oWSMgnt:SetOperation("customerCustomerInfo")	
	aComplex    := oWSMgnt:NextComplex()

	While ValType( aComplex ) == "A"
		xRet := oWSMgnt:SetComplexOccurs( aComplex[1],0)
		aComplex := oWSMgnt:NextComplex()
	EndDo

	aSimple := oWSMgnt:SimpleInput()

	oWSMgnt:SetValue( aSimple[1][1],cSession)
	oWSMgnt:SetValue( aSimple[2][1],cID)

	oWSMgnt:SetValue( aSimple[3][1],"taxvat") //CGC	
	oWSMgnt:GetSoapMsg()
	oWSMgnt:SendSoapMsg()
	oResult := oWSMgnt:GetSoapResponse()
	oParse	:= XmlParser( oResult, "_", @cError, @cWarning )
	_cCGC	:= AllTrim(UPPER(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERINFORESPONSE:_CUSTOMERINFO:_TAXVAT:TEXT))
	_cCGC	:= AllTrim(STRTRAN(_cCGC,".",""))
	_cCGC	:= AllTrim(STRTRAN(_cCGC,"-",""))

	SA1->(DbSetOrder(3))
	SA1->(DbGoTop())
	IF SA1->(DbSeek(xFilial("SA1")+_cCGC))
		cNum := SA1->A1_COD
		Loja := SA1->A1_LOJA
	Endif

	oWSMgnt:SetValue( aSimple[3][1],"group_id") //TIPO
	oWSMgnt:GetSoapMsg()
	oWSMgnt:SendSoapMsg()
	oResult := oWSMgnt:GetSoapResponse()
	oParse	:= XmlParser( oResult, "_", @cError, @cWarning )
	_cPesoa	:= AllTrim(UPPER(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERINFORESPONSE:_CUSTOMERINFO:_GROUP_ID:TEXT))

	oWSMgnt:SetValue( aSimple[3][1],"firstname") //NOME
	oWSMgnt:GetSoapMsg()
	oWSMgnt:SendSoapMsg()
	oResult := oWSMgnt:GetSoapResponse()
	oParse	:= XmlParser( oResult, "_", @cError, @cWarning )
	_cNome	:= AllTrim(UPPER(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERINFORESPONSE:_CUSTOMERINFO:_FIRSTNAME:TEXT))
		
	oWSMgnt:SetValue( aSimple[3][1],"lastname") //SOBRENOME
	oWSMgnt:GetSoapMsg()
	oWSMgnt:SendSoapMsg()
	oResult := oWSMgnt:GetSoapResponse()
	oParse	:= XmlParser( oResult, "_", @cError, @cWarning )
	_cNome	+= (" " + AllTrim(UPPER(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERINFORESPONSE:_CUSTOMERINFO:_LASTNAME:TEXT)))

	oWSMgnt:SetValue( aSimple[3][1],"email") //EMAIL	
	oWSMgnt:GetSoapMsg()
	oWSMgnt:SendSoapMsg()
	oResult := oWSMgnt:GetSoapResponse()
	oParse	:= XmlParser( oResult, "_", @cError, @cWarning )
	_cMail	:= AllTrim(UPPER(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERINFORESPONSE:_CUSTOMERINFO:_EMAIL:TEXT))

	oWSMgnt:SetOperation("customerAddressList")	
	aComplex    := oWSMgnt:NextComplex()

	While ValType( aComplex ) == "A"
		xRet := oWSMgnt:SetComplexOccurs( aComplex[1],0)
		aComplex := oWSMgnt:NextComplex()
	EndDo

	aSimple := oWSMgnt:SimpleInput()
	//ConOut( VarInfo('aSimple',aSimple) )
	oWSMgnt:SetValue( aSimple[1][1],cSession)
	oWSMgnt:SetValue( aSimple[2][1],cID)

	oWSMgnt:GetSoapMsg()
	oWSMgnt:SendSoapMsg()
	oResult := oWSMgnt:GetSoapResponse()
	cContent := oResult
	oParse	:= XmlParser( oResult, "_", @cError, @cWarning )

	If ValType(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERADDRESSLISTRESPONSE:_RESULT:_ITEM) == "A"
		For _nX := 1 To Len(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERADDRESSLISTRESPONSE:_RESULT:_ITEM)
			//If AllTrim(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERADDRESSLISTRESPONSE:_RESULT:_ITEM[_nX]:_IS_DEFAULT_SHIPPING:TEXT) == "true"
				_cID		:= AllTrim(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERADDRESSLISTRESPONSE:_RESULT:_ITEM[_nX]:_CUSTOMER_ADDRESS_ID:TEXT)	//ID UNICO
				_cTel 		:= AllTrim(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERADDRESSLISTRESPONSE:_RESULT:_ITEM[_nX]:_TELEPHONE:TEXT)	//TELEFONE
				_cCEP 		:= AllTrim(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERADDRESSLISTRESPONSE:_RESULT:_ITEM[_nX]:_POSTCODE:TEXT)	//CEP
				_cAuxEnd 	:= AllTrim(FwCutOff(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERADDRESSLISTRESPONSE:_RESULT:_ITEM[_nX]:_STREET:TEXT))
				aAdd(aDestinos,{_cID, _cTel, _cCEP, _cAuxEnd})
			//EndIf
		Next _nX
	Else
		_cID		:= AllTrim(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERADDRESSLISTRESPONSE:_RESULT:_ITEM:_CUSTOMER_ADDRESS_ID:TEXT)	//ID UNICO
		_cTel 		:= AllTrim(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERADDRESSLISTRESPONSE:_RESULT:_ITEM:_TELEPHONE:TEXT) //TELEFONE
		_cCEP 		:= AllTrim(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERADDRESSLISTRESPONSE:_RESULT:_ITEM:_POSTCODE:TEXT) //CEP
		_cAuxEnd 	:= AllTrim(FwCutOff(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERADDRESSLISTRESPONSE:_RESULT:_ITEM:_STREET:TEXT))
		aAdd(aDestinos,{_cID, _cTel, _cCEP, _cAuxEnd})
	EndIf
	
	If ValType(oBill) == "O"
		_cID := Alltrim(oBill:_ADDRESS_ID:TEXT)
		_cTel := Alltrim(oBill:_TELEPHONE:TEXT)
		_cCEP := Alltrim(oBill:_POSTCODE:TEXT)
		_cAuxEnd := Alltrim(FwCutOff(oBill:_STREET:TEXT))
		nPos := aScan(aDestinos,{|w| w[4] == _cAuxEnd })
		If nPos == 0
			aAdd(aDestinos,{_cID, _cTel, _cCEP, _cAuxEnd})
			a1Venda := _cID
		Else
			a1Venda := aDestinos[nPos, 1]
		Endif
	Endif
	
	If ValType(oShip) == "O"
		_cID := Alltrim(oShip:_ADDRESS_ID:TEXT)
		_cTel := Alltrim(oShip:_TELEPHONE:TEXT)
		_cCEP := Alltrim(oShip:_POSTCODE:TEXT)
		_cAuxEnd := Alltrim(FwCutOff(oShip:_STREET:TEXT))
		nPos := aScan(aDestinos,{|w| w[4] == _cAuxEnd })
		If nPos == 0
			aAdd(aDestinos,{_cID, _cTel, _cCEP, _cAuxEnd})
			a1Envio := _cID
		Else
			a1Envio := aDestinos[nPos, 1]
		Endif
	Endif

	//ConOut( VarInfo("aDestinos",aDestinos))

		DBSelectArea("SA1")

		SA1->(DbSetOrder(1))
		SA1->(DbGoTop())
		If Empty(cNum)
			lNewNum := .T.
			cNum := GETSXENUM("SA1","A1_COD","A1_COD")
			Loja := "0001"
			While SA1->(DbSeek(xFilial("SA1")+cNum))
				ConfirmSx8()
				cNum := GETSXENUM("SA1","A1_COD","A1_COD")
				Loja := "0001"
				SA1->(DbGoTop())
			End
		Endif

		SA1->(DBSetOrder(14))
		SA1->(DbGoTop())
		For _nX := 1 To Len(aDestinos)
			_aDados := {}
			SA1->(DbSetOrder(14))
			SA1->(DbGoTop())
			If SA1->(DBSeek(xFilial("SA1") + Alltrim(aDestinos[_nX,1]) ))
				ConOut("Localizado Cliente Id = " + Alltrim(aDestinos[_nX,1]))
				_nOPC := 4
				cNum := SA1->A1_COD
				Loja := SA1->A1_LOJA
			Else
				ConOut("Não Localizado Cliente Id = " + Alltrim(aDestinos[_nX,1]))
				_nOPC := 3
			EndIf

			BEGIN TRANSACTION
			
			If _nOPC == 4
				AADD(_aDados, {"A1_COD"  	, cNum    , NIL})
				AADD(_aDados, {"A1_LOJA" 	, Loja    , NIL})  
			Else
				AADD(_aDados, {"A1_COD"  	, cNum    , NIL})
				SA1->(DbSetOrder(1))
				SA1->(DbGoTop())
				While SA1->(DbSeek(xFilial("SA1")+cNum+Loja))
					_nY++
					Loja := StrZero(_nY, 4)
					SA1->(DbGoTop())
				End
				AADD(_aDados, {"A1_LOJA" 	, Loja    , NIL})
			EndIf 
			
			AADD(_aDados, {"A1_CGC"		,_cCGC									, NIL})
			AADD(_aDados, {"A1_XIDMGT"	,aDestinos[_nX,1]						, NIL})	
			AADD(_aDados, {"A1_NOME"	,Upper(_cNome)									, NIL})
			AADD(_aDados, {"A1_NREDUZ"	,Upper(Alltrim(SubStr(_cNome,1,At(" ",_cNome)))) , NIL})
			AADD(_aDados, {"A1_CONTATO"	,Upper(Alltrim(SubStr(_cNome,1,At(" ",_cNome))))									, NIL})
			AADD(_aDados, {"A1_EMAIL"	,Lower(_cMail)									, NIL})	
			AADD(_aDados, {"A1_TIPO"	,"F"									, NIL}) 
			AADD(_aDados, {"A1_PESSOA"	,IIF(_cPesoa == '5',"J","F")			, NIL})
			AADD(_aDados, {"A1_CEP"		,StrTran(aDestinos[_nX,3],"-","")						, NIL}) 
			AADD(_aDados, {"A1_DDD"		,"0"+SUBSTR(StrTran(StrTran(StrTran(StrTran(aDestinos[_nX,2]," ",""),"-",""),")",""),"(",""),1,2)			, NIL}) 
			AADD(_aDados, {"A1_TEL"		,SUBSTR(StrTran(StrTran(StrTran(StrTran(aDestinos[_nX,2]," ",""),"-",""),")",""),"(",""),3,10)				, NIL}) 
			AADD(_aDados, {"A1_INSCR"	,"ISENTO"								, NIL}) 
			AADD(_aDados, {"A1_PAIS"	,"105"									, NIL})
			AADD(_aDados, {"A1_NATUREZ"	,"1300"									, NIL})	
			AADD(_aDados, {"A1_VEND"	,"000003"								, NIL})
			AADD(_aDados, {"A1_CONTA"	,"51600100001"							, NIL})
			AADD(_aDados, {"A1_CODPAIS"	,"01058"								, NIL})
			AADD(_aDados, {"A1_GRPVEN"	,"000015"								, NIL})
			AADD(_aDados, {"A1_RISCO"	,"A"									, NIL})
			AADD(_aDados, {"A1_CONTRIB"	,"2"									, NIL})
			AADD(_aDados, {"A1_TABELA"	,GetMV('FT_TABMGNT',,'237')				, NIL})
			AADD(_aDados, {"A1_MSBLQL"	,"2"									, NIL})

			_cLoc	:= HttpGet("https://viacep.com.br/ws/" + StrTran(aDestinos[_nX,3],"-","") + "/json/")

			FWJsonDeserialize(_cLoc, @oLoc)       
			_cAuxEnd := ENDAUXLIA(aDestinos[_nX,4])
			If oLoc <> NIL
				_cEst 		:= AllTrim(UPPER(NOACENTO(DecodeUtf8(oLoc:uf))))
				_cEst 		:= AllTrim(POSICIONE("SX5",1,xFilial("SX5")+"12"+_cEst,"X5_DESCRI"))
				_cAuxEnd 	:= AllTrim(STRTRAN(AllTrim(UPPER(NOACENTO(DecodeUtf8(oLoc:logradouro)))),AllTrim(_cAuxEnd),"")) + ", " + AllTrim(_cAuxEnd)
				_cComplem   := SubStr(aDestinos[_nX,4],Len(_cAuxEnd)-1)
				If Len(_cComplem) <= 3
					_cComplem := ""
				Endif
				AADD(_aDados,{"A1_END"		,Upper(_cAuxEnd)        									,NIL})
				AADD(_aDados,{"A1_COMPLEM"	,Upper(COMPLEAUX(_cComplem))								,NIL})
				AADD(_aDados,{"A1_BAIRRO"	,AllTrim(UPPER(NOACENTO(DecodeUtf8(oLoc:bairro))))	,NIL})
				AADD(_aDados,{"A1_COD_MUN"	,SUBSTR(UPPER(NOACENTO(DecodeUtf8(oLoc:ibge))),3,5)	,NIL})
				AADD(_aDados,{"A1_MUN"		,UPPER(NOACENTO(DecodeUtf8(oLoc:localidade)))		,NIL})
				AADD(_aDados,{"A1_EST"		,AllTrim(UPPER(NOACENTO(DecodeUtf8(oLoc:uf))))		,NIL})
				AADD(_aDados,{"A1_ESTADO"	,_cEst												,NIL})
			EndIf

			_aRet := IncCli(_aDados, _nOPC, a1Venda, a1Envio)

			If _aRet[1]
				U_MonitRes("000004", 2, 0, cIdPZB, "Cliente integrado com sucesso" + "["+aDestinos[_nX,1]+"]", .T.,"", cValToChar(cContent), "Sucesso", "", .F., .F., "", .F., .F., .F.)
				U_MonitRes("000004", 3, 0, cIdPZB, "", .T.)
			Else
				U_MonitRes("000004", 2, 0, cIdPZB, "Erro na Integração do Cliente: " + AllTrim(_aRet[2]) + "["+aDestinos[_nX,1]+"]", .F.,"", cValToChar(cContent), _aRet[2], "", .F., .F., "", .F., .F., .F.)
				U_MonitRes("000004", 3, 0, cIdPZB, "", .F.)
			EndIf

			END TRANSACTION

		Next _nX

CATCHEXCEPTION USING oException

	ConOut("FTTEAM007.PRW:LOG"+Time()+CRLF+oException:Description)

	U_MonitRes("000004", 2, 0, cIdPZB, oException:Description, .F., "FTTEAM007.PRW:LOG"+Time(), "Error", oException:Description, "", .F., .F., "", .F., .F., .F.)
	//Finaliza o processo na PZB - Error
	U_MonitRes("000004", 3, , cIdPZB, , .F.)

ENDEXCEPTION

Return _aRet

//----------------------------------------------------------------
/*/{Protheus.doc} IncCli
@author TRIYO
@since 23/04/2021
@version 1.0
@type function
/*/
//----------------------------------------------------------------

Static Function IncCli(_aDados, _nOPC, a1Venda, a1Envio)

Local cStrErro	:= ""

Local nErro		:= 0

Local _aRet		:= {}
Local aErros	:= {}

Private lMsErroAuto := .F.
Private lMsHelpAuto	:= .T.
Private lAutoErrNoFile := .T.

_aDados := FWVetByDic(_aDados,"SA1",.F.) //Organiza o array
MSExecAuto({|x,y| MATA030(x,y)},_aDados,_nOPC)

If lMsErroAuto
	cStrErro 	:= ""
	aErros		:= GetAutoGRLog() // retorna o erro encontrado no execauto.
	nErro   	:= Ascan(aErros, {|x| "INVALIDO" $ alltrim(Upper(x))  } )

	If nErro > 0
		cStrErro += aErros[ nErro ]
	Else
		For nErro := 1 To Len( aErros )
			cStrErro += ( aErros[ nErro ] + CRLF )
		Next nErro
	EndIf

	cStrErro := Alltrim(cStrErro)
	If _nOPC = 3
		RollBackSX8()
	EndIf
	AADD(_aRet,.F.)
	AADD(_aRet,cStrErro)
	AADD(_aRet,a1Venda)
	AADD(_aRet,a1Envio)
Else
	If _nOPC = 3
		If lNewNum
			ConfirmSx8()
			lNewNum := .F.
		Endif
	EndIf
	AADD(_aRet,.T.)
	AADD(_aRet, "Sucesso")
	AADD(_aRet, a1Venda)
	AADD(_aRet, a1Envio)
EndIf

Return _aRet

//----------------------------------------------------------------
/*/{Protheus.doc} ENDAUXLIA
@author TRIYO
@since 23/04/2021
@version 1.0
@type function
/*/
//----------------------------------------------------------------
Static Function ENDAUXLIA(_cAuxEnd)
Local _cRet	:= ""
Local _nX 	:= 0
Local _nY 	:= 0
Local _lSai	:= .F.
For _nX := 1 To Len(_cAuxEnd)
	If SUBSTR(_cAuxEnd,_nX,1) $ '0123456789'
		_cRet += SUBSTR(_cAuxEnd,_nX,1)
	Else
		_nY++
		If _nY <> _nX
			_lSai := .T.
		EndIf
	EndIf
	If _lSai
		EXIT
	EndIf
Next _nX
Return _cRet

//----------------------------------------------------------------
/*/{Protheus.doc} COMPLEAUX
@author TRIYO
@since 23/04/2021
@version 1.0
@type function
/*/
//----------------------------------------------------------------
Static Function COMPLEAUX(_cComplem)
Local _cRet	:= ""
Local _nX 	:= 0
Local _nY 	:= Len(_cComplem)

For _nX := 1 To Len(_cComplem)
	If SUBSTR(_cComplem,_nX,1) $ '0123456789'
		_nY := _nX
	EndIf
Next _nX
If _nY != Len(_cComplem)
	_cRet := Capital(SubStr(_cComplem, 1, _nY)) + ", " + Capital(SubStr(_cComplem, _nY + 1))
Else
	_cRet := Capital(SubStr(_cComplem, 1, _nY))
Endif

Return _cRet
