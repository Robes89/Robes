#INCLUDE "protheus.ch"
#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "prtopdef.ch"       
#include "TbiConn.ch"
#include "TbiCode.ch"

 /*/{Protheus.doc} nomeFunction
    (long_description)
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

User Function SENVP01(cEmPre,cFil)

Local dDataDe := dDataBase 
Local dDataAte := dDataBase + SuperGetMv("MV_XDIPESQ",,30)
Local cAlias:= ""
Local cAlias2 := getNextAlias()
Local aReltPen:={}
Local aRelTot := {} 
Local nJ:= 0 
Local oExcel := Fwmsexcel():new() 
Local nW :=0
Local lMailAuth	:= SuperGetMv("MV_RELAUTH",,.F.)
Local cDir := GetSrvProfString ("STARTPATH","")

If !Empty(cEmPre)
    RPCSetType(3) 
    PREPARE ENVIRONMENT EMPRESA cEmPre FILIAL cFil MODULO 'COM'   
    SetModulo( "SIGACOM" , "COM" )
EndIF    

BeginSql Alias cAlias2
    Select * From %Table:CTT% CTT
        
        Where CTT.%NotDel% and CTT.CTT_BLOQ = '2' and CTT_XMAILR != '' and CTT_FILIAL =  %exp:xFilial("CTT")% 
EndSql
While !(cAlias2)->(EOF()) 
    cAlias := getNextAlias()
    BeginSql Alias cAlias
        Select * From %Table:SE2% SE2
            
            Where SE2.%NotDel% and  SE2.E2_TIPO='PR' and E2_XPREPRO = 'CNT' and E2_FILIAL =  %exp:xFilial("SE2")% and E2_BAIXA = ''
            and SE2.E2_CCUSTO = %exp:(cAlias2)->CTT_CUSTO% and SE2.E2_VENCTO BETWEEN %exp:dDataDe% and  %exp:dDataAte% order by E2_CCUSTO
    EndSql
    IF   Empty((cAlias2)->CTT_XDTULT) .or. (dDataBase  + IIF(empty((cAlias2)->CTT_XDCOBR),0,(cAlias2)->CTT_XDCOBR  )) < stod((cAlias2)->CTT_XDTULT)  
        While !(cAlias)->(EOF())
            aAdd(aReltPen,{(cAlias)->E2_XTITPRO,(cAlias)->E2_FORNECE+(cAlias)->E2_LOJA,(cAlias)->E2_VALOR,(cAlias)->E2_VENCTO,(cAlias)->E2_CCUSTO,(cAlias)->E2_PARCELA})
            (cAlias)->(DbSkip())
        EnDdo
        (cAlias)->(DBCloseArea())
        IF !empty(aReltPen)
            Aadd(aRelTot,aReltPen)
        endif    
        aReltPen:={}
    EndIF    
    (cAlias2)->(DbSkip())
EnDdo    




For nJ := 1 To len(aRelTot)
    oExcel:AddworkSheet("RELATÓRIO")
    oExcel:AddTable("RELATÓRIO","Posição de Nf Pendentes")
    oExcel:AddColumn("RELATÓRIO","Posição de Nf Pendentes","Contrato",1,1)
    oExcel:AddColumn("RELATÓRIO","Posição de Nf Pendentes","Fornecedor",1,1)
    oExcel:AddColumn("RELATÓRIO","Posição de Nf Pendentes","Parcela",1,1)
    oExcel:AddColumn("RELATÓRIO","Posição de Nf Pendentes","Valor",1,1)
    oExcel:AddColumn("RELATÓRIO","Posição de Nf Pendentes","Vencimento",1,1)

    For nW := 1 to Len(aRelTot[nJ])
        oExcel:AddRow("RELATÓRIO","Posição de Nf Pendentes",{aRelTot[nJ][nW][1],Posicione("SA2",1,xFilial("SA2")+aRelTot[nJ][nW][2],"A2_NREDUZ"),aRelTot[nJ][nW][6],aRelTot[nJ][nW][3],Stod(aRelTot[nJ][nW][4])})
    Next
    oExcel:Activate()
    oExcel:GetXMLFile(aRelTot[nJ][1][5]+".xml")
    cMailConta := NIL
    cMailServer := NIL
    cMailSenha:= NIL
    cMailConta :=GETMV("MV_RELFROM")            //Conta utilizada para envio do email
	cMailServer:=GETMV("MV_RELSERV")
	//cMailServer:= Substr(cMailServer,1,len(cMailServer)-4)          //Servidor SMTP
	cMailSenha :=GETMV("MV_RELPSW")             //Senha da conta de e-mail utilizada para envio
   	oMessage:= TMailMessage():New()
	oMessage:Clear()
    oServer := tMailManager():New()
    oServer:SetUseTLS( .T. )
    //oServer:SetUseSSL( .T. )
    oServer:Init( "",cMailServer , cMailConta, cMailSenha, 0, 587 )

    oMessage:cDate	:= cValToChar( Date() )
	oMessage:cFrom 	:= cMailConta
	oMessage:cTo 	:= posicione("CTT",1,xFilial("CTT")+aRelTot[nJ][1][5],"CTT_XMAILR")//cEmail 
	oMessage:cSubject:= "Contratos | Vencimentos Futuros "//cAssunto
	oMessage:cBody 	:= BDEMP01()  
    oMessage:MsgBodyType( "text/html" )
    oMessage:AttachFile( cDir+aRelTot[nJ][1][5]+".xml" )
	 

    xRet := oServer:SMTPConnect()
	if xRet != 0
		alert("Não foi possível conectar ao servidor SMTP: " + oServer:GetErrorString( xRet ))
		return
	endif
    if lMailAuth
		//O método SMTPAuth ao tentar realizar a autenticação do 
		//usuário no servidor de e-mail, verifica a configuração 
		//da chave AuthSmtp, na seção [Mail], no arquivo de 
		//configuração (INI) do TOTVS Application Server, para determinar o valor.
		xRet := oServer:SmtpAuth( cMailConta, cMailSenha )
		if xRet != 0
			cMsg := "Could not authenticate on SMTP server: " + oServer:GetErrorString( xRet )
			alert( cMsg )
			oServer:SMTPDisconnect()
			return
		endif
   	Endif
    xRet := oMessage:Send( oServer )
	if xRet != 0
		alert("Não foi possível enviar mensagem: " + oServer:GetErrorString( xRet ))
	Else
        DBSelectArea("CTT")
        DBSetOrder(1)
        IF DBSeek(xFilial("CTT")+aRelTot[nJ][1][5])
            RecLock("CTT",.F.)
            CTT->CTT_XDTULT := date()
            msUnlock()
        EndIF
        CTT->(DBCloseArea())
    endif
   oExcel:DeActivate()
	xRet := oServer:SMTPDisconnect()
Next



Return 


/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function BDEMP01()

Local cMsg := ''


cMsg +=' <html> '
cMsg +='   <head>'
cMsg +='     <meta http-equiv="Content-Type" content="text/html; charset=utf-8">'
cMsg +='    </head>'
cMsg +='    <body lang=PT-BR link=blue vlink=purple>'
cMsg +='       <div class=WordSection1>'
 cMsg +='         <p class=MsoNormal>'
cMsg +='             <o:p>&nbsp;</o:p>'
cMsg +='          </p>'
cMsg +='          <div>'
cMsg +='             <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%" style="width:100.0%"> '
cMsg +='                <tr>'
cMsg +='                   <td style="padding:0cm 0cm 0cm 0cm">'
cMsg +='                      <h1>'
cMsg +='                         <img src="https://www.careplus.com.br/assets/svg/logo-careplus.svg" width=200 height=57 align="right"> '
cMsg +='                         <span style="color:#BFBFBF"> </span> '
cMsg +='                         <span style="color:#BFBFBF">  '                       
cMsg +='                        </span>'
cMsg +='                      </h1>'
cMsg +='                   </td>'
cMsg +='                   <td style="padding:0cm 0cm 0cm 0cm">'
cMsg +='                   </td>'
 cMsg +='               </tr>'
 cMsg +='            </table>'
 cMsg +='         </div>'
 cMsg +='         <div class=MsoNormal align=center style="text-align:center">'
 cMsg +='            <hr size=2 width="100%" align=center>'
 cMsg +='         </div>'
cMsg +=' <div style="padding: 20px; text-align: center; font-weight: bold; background-color:#006cb6; color:white; font-family:Verdana, Geneva, Tahoma, sans-serif; font-size: large">'
cMsg +='             Pré-notas pendentes de lançamento'
cMsg +=' </div>'
cMsg +='          <div>'
cMsg +='             <p>'
cMsg +=' 	          Prezado(a)  Gestor(a),  '       
cMsg +='             </p>'
cMsg +='             <p>'
cMsg +='Seguem pagamentos provisionados relacionados aos seus contratos que estão pendentes de lançamento de pré-nota.'
cMsg +='</div><div>'
cMsg +=' Por favor, providencie os lançamentos e encaminhe as solicitações de pagamento ao Financeiro.'
cMsg +='</div><div> <p></p> '
cMsg += ' <br>Obrigado,  '
cMsg +=' </p>'        
cMsg +='</p>'          
cMsg +='</div>'
cMsg +='</div><p></p> <p></p>'
cMsg +='<div style="padding: 10px 0px 10px 25px ; font-family:Verdana, Geneva, Tahoma, sans-serif; font-size: 14px">'
cMsg +='<br> Atenção!</br>Este e-mail foi enviado automaticamente e não deverá ser respondido!'
cMsg +='</div>'
cMsg +='<div style="padding: 10px; text-align: center; font-weight: bold; background-color:#006cb6; color:white; font-family:Verdana, Geneva, Tahoma, sans-serif; font-size: smaller">'
cMsg +='</div>'
cMsg +='</body> '

Return cMsg