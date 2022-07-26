#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"
#Include "TopConn.ch"

//Constantes
#Define STR_PULA		Chr(13)+Chr(10)


User Function CPREST01()	
Return


WSRESTFUL AUTHUSER DESCRIPTION "Servi�o REST para manipula��o de usuarios"
WSDATA USR As String //String que vamos receber via URL
WSDATA PWD As String //String que vamos receber via URL
 
WSMETHOD POST DESCRIPTION "Retorna o usu�rio autenticado na URL" WSSYNTAX "/AUTHUSER || /AUTHUSER/{USR}{PWD}" //Disponibilizamos um m�todo do tipo GET
 
END WSRESTFUL


WSMETHOD POST WSRECEIVE USR,PWD WSSERVICE AUTHUSER
//--> Recuperamos o usu�rio informado via URL 
//--> Podemos fazer dessa forma ou utilizando o atributo ::aUrlParms, que � um array com os par�metros recebidos via URL (QueryString)
Local cUsr 		:= Self:USR
Local cPwd 		:= Self:PWD
Local aArea			:= GetArea()
Local aDados := {}
Local cJson			:= ""
Local aArray := {}
Local oJsonPed      := JsonObject():New()

// define o tipo de retorno do m�todo
::SetContentType("application/json")
PswOrder(1)
If PswSeek( cUsr, .T. )
	//aArray := PSWRET()[1] // Retorna vetor com informa��es do usu�rio
	//cPwd := Decode64(cPwd)
	//cCodVen := bscCodVen(PSWRET()[1][1])
	If PSWNAME(cPwd) //.AND. !Empty(cCodVen)
	 	//aAdd(aArray, "OK")
		oJsonPed['RETORNO'] := "OK"
    elSE
		oJsonPed['RETORNO'] := "ERROR"
	EndIF	
elSE
	oJsonPed['RETORNO'] := "ERROR"
EndIf


// --> Transforma o objeto de produtos em uma string json
cJson := FWJsonSerialize(oJsonPed)
// --> Envia o JSON Gerado para a aplica��o Client
::SetResponse(cJson)
RestArea(aArea)
Return(.T.)
