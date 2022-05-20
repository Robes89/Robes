#INCLUDE 'TOTVS.CH'
#INCLUDE "TRYEXCEPTION.CH"

//----------------------------------------------------------------
/*/{Protheus.doc} FTTEAM05
Atualização de Precos MAgento
@author TRIYO
@since 23/04/2021
@version 1.0
@type function
/*/
//----------------------------------------------------------------

User Function FTTEAM05

Local _cQry		:= ""
Local _cSoap	:= ""
Local cError	:= ""
Local cWKArea	:= ""
Local cStrOut	:= '<categories SOAP-ENC:arrayType="xsd:string[]" xsi:type="SOAP-ENC:Array" />'	
Local cStrOut2	:= '<category_ids SOAP-ENC:arrayType="xsd:string[]" xsi:type="SOAP-ENC:Array" />'
Local cGrpMgnt	:= ""
Local cSession	:= ""
Local cWarning	:= ""

Local nQtdReg	:= 0

Local aTntic	:= {}
Local aSimple	:= {}
Local aComplex 	:= {}

Local lOK		:= .T.
Local lRet		:= .T.
Local nValor    := 0
Local nImposto  := 5
Local nTotal    := 0

Local xRet

Local oParse
Local oResult
Local oWSMgnt
Local nRecRef

Private aCrSrv 	:= ""
Private cIdPZB	:= ""

DEFAULT cIdReg		:= ""
DEFAULT cIdPZC		:= ""
DEFAULT cEmpPrep    := "01"
DEFAULT cFilPrep	:= "02"
DEFAULT lLote		:= .F.
DEFAULT lReprocess	:= .F.

RpcSetType(3)
RpcSetEnv(cEmpPrep,cFilPrep,,"FAT")

//aCrSrv 	:= U_MonitRes("000002", 1, 0)
//cIdPZB	:= aCrSrv[2]

TRYEXCEPTION

	cWKArea		:= GetNextAlias()
	aTntic		:= U_FTTEAM03()
	oWSMgnt		:= aTntic[1]
	cSession	:= aTntic[2]
	cGrpMgnt	:= GetMV('FT_TABMGNT',,'100')

	If Empty(cSession)
		aCrSrv 	:= U_MonitRes("000002", 1, 0)
		cIdPZB	:= aCrSrv[2]
		U_MonitRes("000002", 2, 0, cIdPZB, "Não foi possÍvel autenticar. Verifique Login e Senha nos parametros FT_MGNTUSR e FT_MGNTKEY. ", .F.,"", "", "", "", .F., .F., "", .F., .F., .F.)
		U_MonitRes("000002", 3, 0, cIdPZB, "", .F.)
		Return lRet
	EndIf

	_cQry := " SELECT TOP 1 PR1_RECNO, PR1_CHAVE, PR1_TIPREQ, R_E_C_N_O_ AS RECNOPR1 "
	_cQry += "	FROM " + RetSQLName("PR1")
	_cQry += "  WHERE PR1_FILIAL  = '" + xFilial("PR1") + "' "
	_cQry += "	 AND PR1_ALIAS = 'DA0' "
	_cQry += "	 AND PR1_STINT = 'P' "
	_cQry += "	 AND D_E_L_E_T_ = '' "
	_cQry += "	 ORDER BY R_E_C_N_O_ DESC"

	If Select(cWKArea) > 0
		(cWKArea)->(DBCloseArea())
	Endif
			
	_cQry := ChangeQuery(_cQry)
	DBUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),cWKArea,.T.,.T.)	

	nQtdReg := Contar(cWKArea,"!Eof()")

	If nQtdReg <= 0
		aCrSrv 	:= U_MonitRes("000002", 1, 0)
		cIdPZB	:= aCrSrv[2]
		U_MonitRes("000002", 2, 0, cIdPZB, "Não há registros a serem integrados.", .T.,"", "", "", "", .F., .F., "", .F., .F., .F.)
		U_MonitRes("000002", 3, 0, cIdPZB, "", .F.)
		Return lRet
	EndIf

	aCrSrv 	:= U_MonitRes("000002", 1, nQtdReg)
	cIdPZB	:= aCrSrv[2]

	DBSelectArea("DA0") //DA0_FILIAL+DA0_CODTAB 
	DA0->(DBSetOrder(1))

	DBSelectArea("DA1")
	DA1->(DBSetOrder(3)) //DA1_FILIAL+DA1_CODTAB+DA1_ITEM

	DBSelectArea("SB1") //B1_FILIAL+B1_COD 
	SB1->(DBSetOrder(1))

	(cWKArea)->(DBGoTop())

	While (cWKArea)->(!EOF())
		nRecRef := (cWKArea)->RECNOPR1
		If DA0->(DBSeek((cWKArea)->PR1_CHAVE))
			DA1->(DBSeek(xFilial("DA1")+DA0->DA0_CODTAB))
			
			While AllTrim(DA1->(DA1->DA1_FILIAL + DA1->DA1_CODTAB)) == AllTrim((cWKArea)->PR1_CHAVE) .And. DA1->(!EOF())
				
				SB1->(DBSeek(xFilial("SB1")+AllTrim(DA1->DA1_CODPRO)))
				
				If Empty(SB1->B1_XIDMGNT)
					lOK		:= .F.
					U_MonitRes("000002", 2, 0, cIdPZB, "Erro Item " +AllTrim(DA1->DA1_ITEM)+": Codigo do Magento nao informado." , .F., AllTrim(SB1->B1_COD), "", "", "", .F., .F., "", .F., .F., .F.)	
					DA1->(DBSkip())
					LOOP
				EndIf
				
				oWSMgnt:SetOperation("catalogProductUpdate")	
				aComplex    := oWSMgnt:NextComplex()
				
				While ValType( aComplex ) == "A"
				
					xRet := oWSMgnt:SetComplexOccurs( aComplex[1],0)
					
					If xRet == .F.
//						CONOUT( "Erro ao definir elemento ")
						Return
					EndIf
	
					aComplex := oWSMgnt:NextComplex()

				EndDo
				
				aSimple := oWSMgnt:SimpleInput()
				If ValType( aSimple ) == "A"
					//ConOut( VarInfo('aSimple',aSimple) )
					oWSMgnt:SetValue( aSimple[1][1],cSession)
					oWSMgnt:SetValue( aSimple[2][1],AllTrim(SB1->B1_XIDMGNT))
					nValor    := DA1->DA1_PRCVEN
					nImposto  := 0
					nTotal    := nValor + ((nValor * nImposto) / 100)
					oWSMgnt:SetValue( aSimple[13][1],cValToChar(nTotal))
					oWSMgnt:SetValue( aSimple[24][1],"1")
					oWSMgnt:SetValue( aSimple[25][1],"1")

					_cSoap := oWSMgnt:GetSoapMsg()
					_cSoap := STRTRAN(_cSoap,cStrOut,"")
					_cSoap := STRTRAN(_cSoap,cStrOut2,"")
					
					oWSMgnt:SendSoapMsg(_cSoap)

					oResult := oWSMgnt:GetSoapResponse()
					oParse	:= XmlParser( oResult, "_", @cError, @cWarning )
					if AttisMemberOf(OPARSE,"_SOAP_ENV_ENVELOPE")
						if AttisMemberOf(OPARSE:_SOAP_ENV_ENVELOPE,"_SOAP_ENV_BODY")
							if AttisMemberOf(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY,"_SOAP_ENV_FAULT")
								If ValType(XmlChildEx(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY,"_SOAP_ENV_FAULT")) <> "O"
									U_MonitRes("000002", 2, 0, cIdPZB, "Produto " + AllTrim(DA1->DA1_CODPRO) + "atualizado no Magento.", .T., AllTrim(DA1->DA1_CODPRO) + AllTrim(DA1->DA1_ITEM), "", "", "", .F., .F., "", .F., .F., .F.)
								Else
									lOK		:= .F.
									U_MonitRes("000002", 2, 0, cIdPZB, "Erro Item " +AllTrim(DA1->DA1_ITEM)+": " + AllTrim(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_SOAP_ENV_FAULT:_FAULTSTRING:TEXT), .F., AllTrim(SB1->B1_COD), "", "", "", .F., .F., "", .F., .F., .F.)		
								EndIf
							Endif
						Endif
					Endif
				Else
					U_MonitRes("000002", 2, 0, cIdPZB, "Erro Item " + AllTrim(DA1->DA1_ITEM)+": " + AllTrim(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_SOAP_ENV_FAULT:_FAULTSTRING:TEXT), .F., AllTrim(SB1->B1_COD), VarInfo("aSimple",aSimple), "Sem estrutura correta!", "", .F., .F., "", .F., .F., .F.)		
				Endif

				DA1->(DBSkip())			
			EndDO
			PR1->(DbGoTo(nRecRef))
			If PR1->(RECLOCK("PR1",.F.))
				PR1->PR1_STINT := "I"
				PR1->(MsUnlock())
			Endif			
		Else
			U_MonitRes("000002", 2, 0, cIdPZB, "Tabela: " + AllTrim((cWKArea)->PR1_CHAVE) + " não encontrada. ", .F.,"", "", "", "", .F., .F., "", .F., .F., .F.)	
		EndIf

		(cWKArea)->(DBSkip())
		
	EndDo	

	U_MonitRes("000002", 3, 0, cIdPZB, "", .T.)

CATCHEXCEPTION USING oException

	ConOut("FTTEAM005.PRW:LOG"+Time()+CRLF+oException:Description)
	aCrSrv 	:= U_MonitRes("000002", 1, 0)
	cIdPZB	:= aCrSrv[2]
	U_MonitRes("000002", 2, 0, cIdPZB, oException:Description, .F., "FTTEAM005.PRW:LOG"+Time(), "Error", oException:Description, "", .F., .F., "", .F., .F., .F.)
	//Finaliza o processo na PZB - Error
	U_MonitRes("000002", 3, , cIdPZB, , .F.)

ENDEXCEPTION

RpcClearEnv()
Return lRet
