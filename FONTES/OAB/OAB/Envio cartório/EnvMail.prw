#INCLUDE "TOTVS.ch"
#INCLUDE "RPTDEF.ch"
#INCLUDE "TBICONN.ch"
#INCLUDE "TOPCONN.ch"
#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "rwmake.ch"
#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"                    
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} OABExCae
(long_description) Montagem de arquivo borderos para cartório
@type  Static Function
@author Philip Pellegrini
@since date 03/21
@version version 12.1.25
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/

User Function EnvMail(cArq)

	Local _cSmtpSrv 	:= ""
	Local _cAccount 	:= ""
	Local _cPassSmtp	:= ""
	Local _lOk			:= .F.
	Local _lAuth		:= .T.
	Local _lReturn		:= .T.
	Local lRet   	    := .T.
	Local _cAttach		:= cArq
	Local _cMensagem 	:= ' '
	Local cCopia        := 'financeiro.sp@grupoinpress.com.br'//'dro.alves@gmail.com'//'philip.pellegrini@hotmail.com'//'financeiro.sp@grupoinpress.com.br '

	ConOut('Preparando Email')

	_cSmtpSrv 	:= "mail.grupoinpress.net.br:25 "// Alltrim(WF7->WF7_SMTPSR) + ":" + Alltrim(Str(WF7->WF7_SMTPPR))
	_cAccount 	:= "rh@grupoinpress.net.br"//Alltrim(WF7->WF7_AUTUSU)
	_cPassSmtp	:= "rh@1npr3s5!" // Alltrim(WF7->WF7_AUTSEN)

	_cFrom		:=  "financeiro.sp@grupoinpress.com.br" //"rh@grupoinpress.net.br"//Alltrim(WF7->WF7_ENDERE)
	_cSubject   := 'Títulos  - ' + Alltrim(cDoc) + " - " + Alltrim(cRazao)
	_cTitulo 	:= _cSubject
	_cMensagem	:= ''
	_cSmtpError	:= ""

	conout(_cSmtpSrv, _cAccount, _cPassSmtp, _cFrom)

	_lAuth	:= .T.

	CONNECT SMTP SERVER _cSmtpSrv ACCOUNT _cAccount PASSWORD _cPassSmtp RESULT _lOk
	ConOut('Conectando com o Servidor SMTP')

	If _lOk

		If _lAuth	// Autenticacao da conta de e-mail
			lResult := MailAuth("rh@grupoinpress.net.br", _cPassSmtp)
			If !lResult
				GET MAIL ERROR _cSmtpError
				ConOut(_cSmtpError)
				ConOut("Nao foi possivel autenticar a conta - " + _cAccount)
				Return()
			EndIf
		EndIf

		_cMensagem := 'Prezados, ' + CRLF + CRLF
		_cMensagem += 'Corpo email '

		
		SEND MAIL FROM _cFrom TO _cTo CC cCopia SUBJECT _cTitulo BODY _cMensagem ATTACHMENT _cAttach RESULT _lOk

		If !_lOk
			GET MAIL ERROR _cSmtpError
			ConOut(_cSmtpError)
			_lReturn := .F.
		EndIf

		DISCONNECT SMTP SERVER
		ConOut('Desconectando do Servidor')
	Else
		GET MAIL ERROR _cSmtpError
		ConOut(_cSmtpError)
		_lReturn := .F.
	EndIf

Return(_lReturn)

