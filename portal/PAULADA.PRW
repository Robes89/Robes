
#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#Include 'TBICONN.CH'
#include 'AP5MAIL.CH'

USER FUNCTION PAULADA()


cServer		:= AllTrim( GetMV('MV_RELSERV',.F.,'')	)
	cUser		:= AllTrim( GetMV('MV_RELACNT',.F.,'')	)
	cPass		:= AllTrim( GetMV('MV_RELPSW' ,.F.,'')	)
	cFrom		:= AllTrim( GetMV('MV_RELFROM',.F.,'')	)
	cSubject	:= AllTrim( GetMV('MV_RELBODY',.F.,'fdddddddddddd')	)
	cUsrAut		:= AllTrim( GetMV('MV_RELAUSR',.F.,'')	)
	cPswAut		:= AllTrim( GetMV('MV_RELAPSW',.F.,'')	)
	lAutentica	:= GetMV('MV_RELAUTH',.F.,.F.)
lEnvio:= .T. 
cTo:= "RONALDO.ROBES@triyo.com.br"

    	Connect Smtp Server cServer ACCOUNT cUser PASSWORD cPass RESULT lConexao

			//Efetua autenticação do servidor de e-mail
			If lAutentica
				lAuth := MailAuth(cUsrAut,cPswAut)
			EndIf
            cHtml:= 'fdsafsdfsdf'
			//Processa o envio do e-mail conforme parâmetros definidos
			Send Mail From cFrom to cTo SubJect cSubject BODY cHtml RESULT lEnvio

			If lAuth
				If lConexao
					If lEnvio
						
						aAdd(aStatus,{cProcStatus,"1",cCodCarta})
					Else
						GET MAIL ERROR cError
					
						aAdd(aStatus,{cProcStatus,"4",cCodCarta})
					EndIf
				Else
					GET MAIL ERROR cError
					
					aAdd(aStatus,{cProcStatus,"3",cCodCarta})
				EndIf
			Else
				GET MAIL ERROR cError
				
				aAdd(aStatus,{cProcStatus,"5",cCodCarta})
			EndIf

			DisConnect Smtp Server


  RETURN          
