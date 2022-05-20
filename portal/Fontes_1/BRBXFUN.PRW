#Include "Totvs.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "RWMAKE.ch"
#INCLUDE "topconn.ch"
#Include "Xmlxfun.ch"
#INCLUDE "ap5mail.ch"
#INCLUDE "shell.ch"


/*
    Disparo de E-mails
*/


User Function fEnvMail(cMensagem,cPara,cAssunto,aArquivos,lAuto,cMailConta,cMailServer,cMailSenha,cUsrAUth,lMailAuth,nPorta,lUseTLS,lUseSSL,cMailCpy,cHideMail)
	
	Local cMsg := ""
	LOCAL nArq := 1
	Local xRet
	Local oServer, oMessage
	
	Default lMailAuth   := Nil
	Default nPorta      := Nil
	Default lUseTLS     := Nil
	Default lUseSSL     := Nil
	Default cMailCpy    := Nil
	Default cMailConta	:= Nil
	Default cMailServer	:= Nil
	Default cMailSenha	:= Nil
	Default cUsrAUth    := Nil
	Default cHideMail   := ""
	Default cMailCpy    := ""
	Default aArquivos   := {}

	If !Empty(cMailCpy) .And. Substr(cMailCpy,1,1)<>";"
		cMailCpy := ";"+cMailCpy
	Endif	
 
	cMailConta :=  If( cMailConta  == NIL , GETMV("BR_RELACNT" , , "") , cMailConta  )              //Alias utilizada para envio do email
	cMailServer:=  If( cMailServer == NIL , GETMV("BR_RELSERV" , , "") , cMailServer )              //Servidor SMTP
	cMailSenha :=  If( cMailSenha  == NIL , GETMV("BR_RELPSW"  , , "") , cMailSenha  )              //Senha da conta de e-mail utilizada para envio
	cUsrAUth   :=  If( cUsrAUth    == NIL , GETMV("BR_USRAUTH" , , "") , cUsrAUth    )              //Usuario utilizado para autenticação no smtp


	lMailAuth	:= If( lMailAuth == NIL , SuperGetMv("BR_RELAUTH",, .T.) ,	lMailAuth	)				    //Autentica no Smtp .T. = Sim, .F. = Nao
	nPorta      := If( nPorta    == NIL , SuperGetMv("BR_PORTA"  ,, 587) ,	nPorta   	)					//Numero da pota SMTP de conexao
	lUseTLS     := If( lUseTLS   == NIL , SuperGetMv("BR_USETLS" ,, .F.) ,	lUseTLS  	)					//Utiliza TLS na conexao 
	lUseSSL     := If( lUseSSL   == NIL , SuperGetMv("BR_USESSL" ,, .F.) ,	lUseSSL  	)					//Utiliza SSL na conexao 
	cMailCpy    := If( cMailCpy  == NIL , SuperGetMv("BR_MAILCPY",, "")  ,  cMailCpy    )
		
	oMessage:= TMailMessage():New()
	oMessage:Clear()
	
	oMessage:cDate	 := cValToChar( Date() )
	oMessage:cFrom 	 := Alltrim(cMailConta)
	oMessage:cTo 	 := cPara
	oMessage:cCC	 := cMailCpy
	oMessage:cBCC    := cHideMail
	oMessage:cSubject:= cAssunto
	oMessage:cBody 	 := cMensagem
		
	If Len(aArquivos) > 0
		For nArq := 1 To Len(aArquivos)
			xRet := oMessage:AttachFile( aArquivos[nArq] )
			If xRet < 0
				cMsg := "O arquivo " + aArquivos[nArq] + " não foi anexado!"
				If !lAuto
					FWAlertError( cMsg )
				Else
					FwLogMsg("ERROR",, "FENVMAIL", "BRBXFUN" , "", "01", cMsg , 0, 0, {}) 
				Endif	
				Return .F.
			Endif
		Next
	EndIf		
		
	/*Envio via SSL
	[MAIL]
	×	SSLVersion=2
	×	AuthLOGIN=1
	×	AuthNTLM=1
	×	AuthPLAIN=1
	*/
	
	oServer := tMailManager():New()
	oServer:SetUseTLS( lUseTLS )
	oServer:SetUseSSL( lUseSSL )

	xRet := oServer:Init( "", Alltrim(cMailServer) , Alltrim(cMailConta), Alltrim(cMailSenha), 0, nPorta ) //inicilizar o servidor
	if xRet != 0
		If !lAuto
			FWAlertError("O servidor SMTP não foi inicializado: " + oServer:GetErrorString( xRet ) )
		Else
			FwLogMsg("ERROR",, "FENVMAIL", "BRBXFUN" , "", "01", oServer:GetErrorString( xRet ) , 0, 0, {}) 
		Endif	
		Return .F.
	endif

	xRet := oServer:SetSMTPTimeout( 60 ) //Indica o tempo de espera em segundos.
	If xRet != 0
		If !lAuto
			cMsg := "Não foi possível definir tempo limite para " + cValToChar( nTimeout )
			FWAlertError(cMsg)
		Else
			FwLogMsg("ERROR",, "FENVMAIL", "BRBXFUN" , "", "01", cMsg , 0, 0, {}) 
		Endif
		Return .F.	
	Endif

	xRet := oServer:SMTPConnect()
	If xRet <> 0
		If !lAuto
			cMsg := "Não foi possível conectar ao servidor SMTP: " + oServer:GetErrorString( xRet )
			FWAlertError(cMsg)
		Else
			FwLogMsg("ERROR",, "FENVMAIL", "BRBXFUN" , "", "01", cMsg , 0, 0, {}) 
		Endif	
		Return .F.
	Endif

	If lMailAuth
		
		xRet := oServer:SmtpAuth( Alltrim(cUsrAUth), Alltrim(cMailSenha) )
		
		If xRet <> 0
		
			cMsg := "Could not authenticate on SMTP server: " + oServer:GetErrorString( xRet )
		
			If !lAuto
				FWAlertError( cMsg )
			Else
				FwLogMsg("ERROR",, "FENVMAIL", "BRBXFUN" , "", "01", cMsg , 0, 0, {}) 
			Endif	
		
			oServer:SMTPDisconnect()
			Return .F.
		
		Endif
	Endif

	xRet := oMessage:Send( oServer )
	
	If xRet <> 0
		If !lAuto
			FWAlertError("Não foi possível enviar mensagem: " + oServer:GetErrorString( xRet ))
		Else
			FwLogMsg("ERROR",, "FENVMAIL", "BRBXFUN" , "", "01", oServer:GetErrorString( xRet ) , 0, 0, {}) 
		Endif	
		Return .F.
	Endif

	xRet := oServer:SMTPDisconnect()
	If xRet <> 0
		If !lAuto
			FWAlertError("Não foi possível desconectar o servidor SMTP: " + oServer:GetErrorString( xRet ))
		Else
			FwLogMsg("ERROR",, "FENVMAIL", "BRBXFUN" , "", "01", oServer:GetErrorString( xRet ) , 0, 0, {}) 
		Endif	
	Endif

Return .T.
