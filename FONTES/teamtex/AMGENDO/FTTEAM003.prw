#INCLUDE 'TOTVS.CH'
#INCLUDE "TRYEXCEPTION.CH"

//----------------------------------------------------------------
/*/{Protheus.doc} FTTEAM03
Classe padrao de comunicação
@author TRIYO
@since 23/04/2021
@version 1.0
@type function
/*/
//----------------------------------------------------------------

User Function FTTEAM03()

Local cError    := ""   
Local cWarning  := ""
Local cSession	:= ""
Local cUser		:= ""
Local cKey		:= ""

Local aComplex  := {}
Local aSimple   := {}

Local oWS	
Local oResult
lOCAL oPARSE

//TRYEXCEPTION

    oWS := TWsdlManager():New()
    oWS:nTimeout := 120
    oWS:lVerbose := .T.

    oWS:ParseURL("https://www.cadeiraparaauto.com.br/api/v2_soap?wsdl")
    oWS:SetOperation("login")
    oWS:bNoCheckPeerCert := .T.

    aComplex    := oWS:NextComplex()
    aSimple     := oWS:SimpleInput()
    cUser	    := GetMV('FT_MGNTUSR',,'tryio')
    cKey		:= GetMV('FT_MGNTKEY',,'JBOfqoBwQ2Ex')
    If ValType( aSimple ) == "A"
        oWS:SetValue( aSimple[1][1],cUser)
        oWS:SetValue( aSimple[2][1],cKey)

        oWS:GetSoapMsg()
        oWS:SendSoapMsg()

        oResult := oWS:GetSoapResponse()
        oPARSE := XmlParser( oResult, "_", @cError, @cWarning )	
        If ValType(oPARSE) == "O"
            If AttisMemberOf(oPARSE,"_SOAP_ENV_ENVELOPE")
                If AttisMemberOf(OPARSE:_SOAP_ENV_ENVELOPE,"_SOAP_ENV_BODY")
                    If AttisMemberOf(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY,"_NS1_LOGINRESPONSE")
                        If AttisMemberOf(OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_LOGINRESPONSE,"_LOGINRETURN")
                            cSession := OPARSE:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_LOGINRESPONSE:_LOGINRETURN:TEXT
                        Endif
                    Endif
                Endif
            Endif
        Endif
    Endif
/*
CATCHEXCEPTION USING oException

	ConOut("FTTEAM003.PRW:LOG"+Time()+CRLF+oException:Description)

ENDEXCEPTION
*/
Return ({oWS,cSession})
