#INCLUDE 'TOTVS.CH'
#INCLUDE "TRYEXCEPTION.CH"

//----------------------------------------------------------------
/*/{Protheus.doc} FTTEAM06
@author TRIYO
@since 23/04/2021
@version 1.0
/*/
//----------------------------------------------------------------

User Function FTTEAM06()
	
Local _cQry		:= ""
Local cAmzMgt	:= ""
Local cWKArea	:= ""
Local cSession	:= ""

Local aTntic	:= {}

Local oWSMgnt

Private aCrSrv 	:= {}
Private cIdPZB	:= ""

DEFAULT cIdReg		:= ""
DEFAULT cIdPZC		:= ""
DEFAULT cEmpPrep    := "01" 
DEFAULT cFilPrep    := "01"
DEFAULT lLote		:= .F.
DEFAULT lReprocess	:= .F.

RPCSETENV(cEmpPrep,cFilPrep)

aCrSrv 	:= U_MonitRes("000003", 1, 0)
cIdPZB	:= aCrSrv[2]

TRYEXCEPTION

	aTntic		:= U_FTTEAM03()
	cWKArea		:= GetNextAlias()
	oWSMgnt		:= aTntic[1]
	cSession	:= aTntic[2]
	cAmzMgt		:= GetMv('FT_ARMZMGT',,'00')

	_cQry := " SELECT	B8_PRODUTO,   			" 
	_cQry += " 			SUM(B8_SALDO) AS QTD 	" 
	_cQry += "	 FROM   " + RetSQLName("SB8")
	_cQry += "	WHERE B8_FILIAL = '" + xFilial("SB8") + "' "
	_cQry += "	  AND B8_LOCAL = '" + cAmzMgt + "' " 
	_cQry += "	  AND D_E_L_E_T_= ' ' " 
	_cQry += "	GROUP BY B8_PRODUTO "

	If Select(cWKArea)> 0
		(cWKArea)->(DBCloseArea())
	Endif

	_cQry := ChangeQuery(_cQry)
	DBUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),cWKArea,.T.,.T.)

	DBSelectArea("SB1")
	SB1->(DBSetOrder(1))


	While (cWKArea)->(!EOF())
		
		If SB1->(DBSeek(xFilial("SB1") + AllTrim((cWKArea)->B8_PRODUTO)))
			
			oWSMgnt:oWScatalogProductUpdateproductData:OWSSTOCK_DATA		:= oWSMgnt:OWSSTOCK_DATA
			oWSMgnt:oWScatalogProductUpdateproductData:OWSSTOCK_DATA:CQTY	:= (cWKArea)->QTD
			
			oWSMgnt:catalogProductUpdate(cSession, AllTrim(SB1->B1_IDMGNTO), oWSMgnt:oWScatalogProductUpdateproductData,"","")
			
		EndIf
		
	EndDo	

CATCHEXCEPTION USING oException

	ConOut("FTTEAM006.PRW:LOG"+Time()+CRLF+oException:Description)

	U_MonitRes("000003", 2, 0, cIdPZB, oException:Description, .F., "FTTEAM006.PRW:LOG"+Time(), "Error", oException:Description, "", .F., .F., "", .F., .F., .F.)
	//Finaliza o processo na PZB - Error
	U_MonitRes("000003", 3, , cIdPZB, , .F.)

ENDEXCEPTION

Return 

//----------------------------------------------------------------
/*/{Protheus.doc} FTTEAMA6
@author TRIYO
@since 23/04/2021
@version 1.0
/*/
//----------------------------------------------------------------

User Function FTTEAMA6()

Local _cQry		:= ""
Local _cSoap	:= ""
Local cError	:= ""
Local cStrOut	:= '<categories SOAP-ENC:arrayType="xsd:string[]" xsi:type="SOAP-ENC:Array" />'	
Local cStrOut2	:= '<category_ids SOAP-ENC:arrayType="xsd:string[]" xsi:type="SOAP-ENC:Array" />'
Local _cAmzMgt	:= ""
Local cWarning	:= ""
Local _cWKArea2	:= ""
Local cSession	:= ""
Local cResult := ""

Local nQtdReg	:= 0

Local aSimple	:= {}
Local _aTntic	:= {}
Local aComplex	:= {}

Local xRet

Local oParse
Local oResult
Local oWSMgnt

DEFAULT cIdReg		:= ""
DEFAULT cIdPZC		:= ""
DEFAULT cEmpPrep    := "01"
DEFAULT cFilPrep    := "02"
DEFAULT lLote		:= .F.
DEFAULT lReprocess	:= .F.

RPCSETENV(cEmpPrep,cFilPrep)

//TRYEXCEPTION

	_aTntic		:= U_FTTEAM03()
	oWSMgnt		:= _aTntic[1]
	cSession	:= _aTntic[2]
	_cAmzMgt	:= GetMv('FT_ARMZMGT',,'02')

	If Empty(cSession)
		U_MonitRes("000003", 2, 0, cIdPZB, "Não foi possível autenticar. Verifique Login e Senha nos parametros FT_MGNTUSR e FT_MGNTKEY. ", .F.,"", "", "", "", .F., .F., "", .F., .F., .F.)
		U_MonitRes("000003", 3, 0, cIdPZB, "", .F.)
		Return _lRet
	EndIf	

	DBSelectArea("SB1")
	SB1->(DBSetOrder(1))

	_cWKArea2 := GetNextAlias()

	_cQry := " SELECT	B2_COD,   			" 
	_cQry += " 			B1_XIDMGNT, 				"
	_cQry += " 			SUM(B2_QATU) AS QTD 	" 
	_cQry += "	 FROM   " + RetSQLName("SB2") + " SB2 "
	_cQry += "  INNER JOIN " + RetSQLName("SB1") + " SB1 "
	_cQry += "	   ON B2_COD = B1_XSTQMGT "
	_cQry += "	WHERE B2_FILIAL = '" + xFilial("SB2") + "' "
	_cQry += "	  AND B1_FILIAL = '" + xFilial("SB1") + "' "
	_cQry += "	  AND B2_LOCAL = '" + _cAmzMgt + "' " 
	_cQry += "	  AND B1_XIDMGNT <> '' "
	_cQry += "	  AND SB2.D_E_L_E_T_= ' ' " 
	_cQry += "	  AND SB1.D_E_L_E_T_= ' ' "
	_cQry += "	GROUP BY B2_COD, B1_XIDMGNT "

	If Select(_cWKArea2) > 0
		(_cWKArea2)->(DBCloseArea())
	Endif
		
	_cQry := ChangeQuery(_cQry)
	DBUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cWKArea2,.T.,.T.)

	nQtdReg := Contar(_cWKArea2,"!Eof()")

	If nQtdReg <= 0
		U_MonitRes("000003", 2, 0, cIdPZB, "Não há Atualizações de Estoque disponiveis. ", .T.,"", "", "", "", .F., .F., "", .F., .F., .F.)
		U_MonitRes("000003", 3, 0, cIdPZB, "", .F.)
		Return _lRet
	Else
		aCrSrv 	:= U_MonitRes("000003", 1, nQtdReg)
		cIdPZB	:= aCrSrv[2]
	EndIf

	(_cWKArea2)->(DBGoTop())

	While (_cWKArea2)->(!EOF())

		if oWSMgnt:SetOperation("catalogProductUpdate")	
			aComplex    := oWSMgnt:NextComplex()

			While ValType( aComplex ) == "A"
				If AllTrim(aComplex[2]) == "stock_data" 
					xRet := oWSMgnt:SetComplexOccurs( aComplex[1],1)
				Else
					xRet := oWSMgnt:SetComplexOccurs( aComplex[1],0)
				EndIf	
				If xRet == .F.
				//	CONOUT( "Erro ao definir elemento ")
					Return
				EndIf
				aComplex := oWSMgnt:NextComplex()
			EndDo
					
			aSimple := oWSMgnt:SimpleInput()
			If ValType( aSimple ) == "A"
				If len(aSimple) > 0
					If Len(aSimple[1]) > 0
						oWSMgnt:SetValue( aSimple[1][1],cSession)
					else
						aAdd(aSimple[1],"")
						oWSMgnt:SetValue( aSimple[1][1],cSession)
					Endif
					If Len(aSimple[2]) > 0
						oWSMgnt:SetValue( aSimple[2][1],AllTrim((_cWKArea2)->B1_XIDMGNT))
					else
						aAdd(aSimple[2],"")
						oWSMgnt:SetValue( aSimple[2][1],AllTrim((_cWKArea2)->B1_XIDMGNT))
					Endif
							
					If Len(aSimple[24]) > 0
						oWSMgnt:SetValue( aSimple[24][1],cValToChar((_cWKArea2)->QTD))
					else
						aAdd(aSimple[24],"")
						oWSMgnt:SetValue( aSimple[24][1],cValToChar((_cWKArea2)->QTD))
					Endif
							
					If Len(aSimple[25]) > 0
						oWSMgnt:SetValue( aSimple[25][1],cValToChar((_cWKArea2)->QTD))
					else
						aAdd(aSimple[25],0)
						oWSMgnt:SetValue( aSimple[25][1],cValToChar((_cWKArea2)->QTD))
					Endif
							
					If Len(aSimple[39]) > 0
						oWSMgnt:SetValue( aSimple[39][1],"1")
					else
						aAdd(aSimple[39],"")
						oWSMgnt:SetValue( aSimple[39][1],"1")
					Endif

					If Len(aSimple[40]) > 0
						oWSMgnt:SetValue( aSimple[40][1],"1")
					else
						aAdd(aSimple[40],"")
						oWSMgnt:SetValue( aSimple[40][1],"1")
					Endif
				endif

				_cSoap := oWSMgnt:GetSoapMsg()
				_cSoap := STRTRAN(_cSoap,cStrOut,"")
				_cSoap := STRTRAN(_cSoap,cStrOut2,"")
				oWSMgnt:SendSoapMsg(_cSoap)
					
				oResult := oWSMgnt:GetSoapResponse()
				cResult := oResult
				oParse	:= XmlParser( oResult, "_", @cError, @cWarning )
				If ValType(oParse) == "O"
					If AttIsMemberOf(oParse,"_SOAP_ENV_ENVELOPE")
						if AttIsMemberOf(oParse:_SOAP_ENV_ENVELOPE,"_SOAP_ENV_BODY")
							If ValType(XmlChildEx(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY,"_SOAP_ENV_FAULT")) <> "O"
								U_MonitRes("000003", 2, 0, cIdPZB, "a) Produto " + AllTrim((_cWKArea2)->B2_COD) + "atualizado no Magento.", .T., AllTrim((_cWKArea2)->B2_COD) + ": " + cValToChar((_cWKArea2)->QTD), cResult, "", "", .F., .F., "", .F., .F., .F.)
							Else
								U_MonitRes("000003", 2, 0, cIdPZB, "b) Produto " + AllTrim((_cWKArea2)->B2_COD)+": " + AllTrim(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_SOAP_ENV_FAULT:_FAULTSTRING:TEXT), .F., AllTrim((_cWKArea2)->B2_COD), cResult, "", "", .F., .F., "", .F., .F., .F.)
							EndIf
						Else
							U_MonitRes("000003", 2, 0, cIdPZB, "c) Erro ao Obter Objeto", .F., "FTTEAM006.PRW:LOG"+Time(), cResult, "ErrorLog-Except1", "", .F., .F., "", .F., .F., .F.)
						Endif
					Else
						U_MonitRes("000003", 2, 0, cIdPZB, "d) Erro ao Obter Objeto", .F., "FTTEAM006.PRW:LOG"+Time(), cResult, "ErrorLog-Except2", "", .F., .F., "", .F., .F., .F.)
					Endif
				else
					U_MonitRes("000003", 2, 0, cIdPZB, "e) Erro ao Obter Objeto", .F., "FTTEAM006.PRW:LOG"+Time(), cResult, "ErrorLog-Except3", "", .F., .F., "", .F., .F., .F.)
				endif
			Else
				U_MonitRes("000003", 2, 0, cIdPZB, "f) Produto " + AllTrim((_cWKArea2)->B2_COD)+": " + AllTrim(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_SOAP_ENV_FAULT:_FAULTSTRING:TEXT), .F., AllTrim((_cWKArea2)->B2_COD), cResult, "Sem estrutura correta!", "", .F., .F., "", .F., .F., .F.)		
			Endif
		Else
			U_MonitRes("000003", 2, 0, cIdPZB, "g) Produto " + AllTrim((_cWKArea2)->B2_COD)+": " + AllTrim(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_SOAP_ENV_FAULT:_FAULTSTRING:TEXT), .F., AllTrim((_cWKArea2)->B2_COD), cResult, "Sem estrutura correta!", "", .F., .F., "", .F., .F., .F.)		
		Endif
		(_cWKArea2)->(DBSkip())
	EndDo

	(_cWKArea2)->(DBCloseArea())
	U_MonitRes("000003", 3, 0, cIdPZB, "", .F.)
/*
CATCHEXCEPTION USING oException

	ConOut("FTTEAM006.PRW:LOG"+Time()+CRLF+oException:Description)

	U_MonitRes("000003", 2, 0, cIdPZB, oException:Description, .F., "FTTEAM006.PRW:LOG"+Time(), "Error", oException:Description, "", .F., .F., "", .F., .F., .F.)
	//Finaliza o processo na PZB - Error
	U_MonitRes("000003", 3, , cIdPZB, , .F.)

ENDEXCEPTION
*/
Return 
