#INCLUDE 'protheus.ch'
#include "TBICONN.CH"
//#INCLUDE "WFTEST.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} WFTEST

Fun��o que tem como objetivo testar o Workflow padr�o
@params
cWfhost = Host do workflow que est� configurado no ini
cTo = Remetente a ser enviado o  workflow.

@author Rodrigo G. Soares

@since 25/01/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User function wfTest(cWfhost, cTo) 
	Local aCompany     := {}
	Local oLayer       := FWLayer():New()
	Local oDialog      := Nil
	Local oTop         := Nil
	Local oList        := Nil
    Local lHasButton := .t. 

	Static lContinue   := .F.

    DEFAULT cWfhost := space(100)
    DEFAULT cTo := space(60)

	//-------------------------------------------------------------------
	// Lista empresas dispon�veis.
	//-------------------------------------------------------------------
	aCompany := BALoadComp()
	
	//-------------------------------------------------------------------
	// Monta tela de sele��o de empresas.
	//-------------------------------------------------------------------
	DEFINE DIALOG oDialog TITLE "TOTVS - Valida��o do workflow" FROM 050, 051 TO 505,720 PIXEL //""
		//-------------------------------------------------------------------
		// Monta as sess�es da tela. 
		//-------------------------------------------------------------------  
		oLayer:Init( oDialog )
		oLayer:addLine( "TOP", 80, .F.)
		oLayer:addCollumn( "TOP_ALL",100, .T. , "TOP")
		oLayer:addWindow( "TOP_ALL", "TOP_WINDOW", "Selecione uma empresa para o teste" , 60, .F., .T.,, "TOP"    ) //"Selecione uma empresa para o teste"

        oLayer:addWindow( "TOP_ALL", "TOP2_WINDOW", "Par�metros" , 40, .F., .T.,, "TOP"    ) //"Par�metros"

		oTop    := oLayer:getWinPanel( "TOP_ALL", "TOP_WINDOW", "TOP" )
        oParam  := oLayer:getWinPanel( "TOP_ALL", "TOP2_WINDOW", "TOP" ) 

         // Cria Fonte para visualiza��o
        oFont := TFont():New('Courier new',,-12,.T.)
  
        // Usando o m�todo New
        oSay1:= TSay():New(01,010,{|| "Host WF" + " -  Ex: http://localhost:80/wf" },oParam,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20) //'Host WF'
        oSay1:= TSay():New(25,010,{|| "Destinat�rio" },oParam,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20) //"Destinat�rio"

        oWfhost := TGet():New( 010, 010, bSETGET(cWfhost),oParam, ;
        310, 010, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cWfhost",,,,lHasButton  )

        oTo := TGet():New( 033, 010, bSETGET(cTo),oParam, ;
        310, 010, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cTo",,,,lHasButton  )

		//-------------------------------------------------------------------
		// Monta a lista de empresas. 
		//-------------------------------------------------------------------  	
      	@ 000, 000 LISTBOX oList;
		 	FIELDS HEADER "", "C�digo", "escri��o da Empresa" ; // "C�digo"###"Descri��o da Empresa"
		 	SIZE 320, 95 OF oTop PIXEL; 
		 	ON DBLCLICK (WFChangeComp(aCompany, oList)) 
			
			oList:SetArray( aCompany )
			oList:bLine := {|| { If(aCompany[oList:nAt, 1], LoadBitmap( GetResources(), "LBTIK" ), LoadBitmap( GetResources(), "LBNO" )), aCompany[oList:nAt, 2], aCompany[oList:nAt, 3] }}
		    oList:bHeaderClick := { |a, b| iif(b == 1 , MarkAll( aCompany, b ) ,), oList:Refresh() }

	ACTIVATE DIALOG oDialog CENTERED ON INIT EnchoiceBar( oDialog, { || iif( WFValidArr( aCompany, cWfhost, cTo ), { lContinue := .T., oDialog:End() } , MsgInfo( "Favor selecionar ao menos uma empresa para continuar.", "Aten��o" ) )  }, { || oDialog:End() }, .F., {},,,.F.,.F.,.F.,.T., .F. ) // #"Favor selecionar ao menos uma empresa para continuar." #"Aten��o"   

    //Caso as informa��es est�o preenchidas � rodado teste. 
    IF(lContinue)
        MsgRun("Executando teste",'WFTEST', {|| wfexecT(acompany, cwfhost, cto )}) //"Executando teste"
    ENDIF

    RPCClearEnv()

    IF(lContinue)
        MessageBox( "Foi conclu�do o processo de teste do WF. Em breve chegar� o e-mail para o destinat�rio para validar o retorno", "SUCESSO", 0) //"Foi conclu�do o processo de teste do WF. Em breve chegar� o e-mail para o destinat�rio para validar o retorno"###"SUCESSO"
    ELSE

        if MsgYesNo( "Deseja testar novamente?", "WFTEST") //"Deseja testar novamente?"
            U_wftest(cwfhost, cto)
        ENDIF
    ENDIF

RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} WFexect    
Fun��o que ir� executar todas as valida��es com base nos parametros
/*/
//-------------------------------------------------------------------  

Static function WFexect(acompany, cwfhost, cto)
    lContinue := .t.

    RPCSETENV(acompany[AScan(acompany, {|x| x[1] == .t.})][2])

    IF(alltrim(GETMV( 'MV_WFMLBOX')) == "")
        MessageBox("Conta n�o configurada nos parametros. Validar no Configurador em Parametros do Workflow", "ERRO", 0) //"Conta n�o configurada nos parametros. Validar no Configurador em Parametros do Workflow"###"ERRO"
        lContinue := .f.
        RETURN

    ELSE
        cMsg := WFValidMail()
             
        IF( len(cMsg) > 0)           
            ShowHelpDlg( "ERRO",{cMsg[1]},,{cMsg[2]} )
            lContinue := .f.
            
        ENDIF

        IF(gerarHtml().and. lContinue)
            __WFExemp(alltrim(cwfhost), alltrim(cTo))
            lContinue := .t.
        ELSE
            MessageBox( "Erro nos arquivos", "ERRO", 0) //"Erro nos arquivos"
            lContinue := .f.
            
        ENDIF
     ENDIF
RETURN lContinue

//-------------------------------------------------------------------
/*/{Protheus.doc} gerarHtml    
Fun��o que ir� criar os arquivos de formul�rio, caso n�o existam no Rootpath.
/*/
//-------------------------------------------------------------------  

Static function gerarHtml()

    local lreturn := .t.
    local nHandle 
    local cForm := ""

    if!(ExistDir("\workflow"))
        MakeDir("\workflow")
    ENDIF

    IF!(FILE("\workflow\__WFORM.html"))
        nHandle := FCREATE("\workflow\__WFORM.html")

        IF(FILE("\workflow\__WFORM.html"))
            
            cForm += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">'
            cForm += '<html>'
            cForm += '    <head>'
            cForm += '      <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
            cForm += '		<title>Workflow por Link</title>'
            cForm += '    </head>'
            cForm += '<body><form action="mailto:%WFMailTo%" method="POST" name="formulario">'
            cForm += '			Processo gerado �s !TEXT_TIME!'
            cForm += '			<br> Clique aqui para responder --> '
            cForm += '			<input type="submit" value="Enviar"/></form></body>'
            cForm += '</html>'                

            if nHandle = -1
                lreturn = .f.
            else            
                FWrite(nHandle, cForm)
                
                FClose(nHandle)
            endif
        ENDIF

    ENDIF

    IF!(FILE("\workflow\__wflink.html"))
        nHandle := FCREATE("\workflow\__wflink.html")

        IF(FILE("\workflow\__wflink.html"))
            
            cForm := ''
            cForm += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">'
            cForm += '<html>'
            cForm += '    <head>'
            cForm += '      <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
            cForm += '		<title>Workflow por Link</title>'
            cForm += '    </head>'
            cForm += "<body>	<form name='form1' method='post' action=''>"
            cForm += "		<p>Clique no <a href='!A_LINK!'>link</a> para responder.</p>"
            cForm += '</form></body>'
            cForm += '</html>'                

            if nHandle = -1
                lreturn = .f.
            else            
                FWrite(nHandle, cForm)
                
                FClose(nHandle)
            endif
        ENDIF

    ENDIF
RETURN lreturn

//-------------------------------------------------------------------
/*/{Protheus.doc} WFValidMail    
Fun��o que ir� validar as configura��es da conta setada no WF.
/*/
//-------------------------------------------------------------------  

Static function WFValidMail()
    local cMsg := {}

    dbSelectArea('WF7')
    DBSETORDER(1)

    if(DBSEEK( xFilial('WF7') + GETMV( 'MV_WFMLBOX') ))    

        oServer := TMailManager():New()

        IIF( alltrim(WF7->WF7_SMTPSE) == "SSL", oServer:SetUseSSL( .T. ),)
        IIF( alltrim(WF7->WF7_SMTPSE) == "TLS", oServer:SetUseTLS( .T. ),)

        nSendSec := 0
        cUser :=  alltrim(WF7->WF7_AUTUSU)
        cPass :=  alltrim(WF7->WF7_AUTSEN)
        
        nTimeout := WF7->WF7_TEMPO // define the timout to 60 seconds
        
        xRet := oServer:Init( "", alltrim(WF7->WF7_SMTPSR), cUser, cPass, ,WF7->WF7_SMTPPR )

        if xRet != 0
            aadd(cMsg, "N�o pode inicializar o servidor SMTP")// 
            aadd(cMsg, "Verificar as configura��es do Servi�o SMTP") //
            return cMsg
        endif
        
        // the method set the timout for the SMTP server
        xRet := oServer:SetSMTPTimeout( nTimeout )
        if xRet != 0
            aadd(cMsg, "Tempo excedido na conex�o com o servidor SMTP" )//
            aadd(cMsg, "Verificar a disponibilidade do Servi�o SMTP" ) // 
            return cMsg
        endif
        
        // estabilish the connection with the SMTP server
        xRet := oServer:SMTPConnect()
        if xRet <> 0
            aadd(cMsg, "N�o foi possivel conectar ao servidor SMTP") //
            aadd(cMsg, "Validar as configura��es de SMTP, como porta e servidor.") //")
            return cMsg
        endif
        
        // authenticate on the SMTP server (if needed)
        xRet := oServer:SmtpAuth( cUser, cPass )
        if xRet <> 0
            aadd(cMsg, "N�o foi possivel autenticar no servido SMTP") //
            aadd(cMsg, "Por favor validar configura��es de usuario e senha") //
            oServer:SMTPDisconnect()
            return cMsg
        endif

    ENDIF
return cMsg

//-------------------------------------------------------------------
/*/{Protheus.doc} WFValidArr    
Fun��o que ir� validar o preenchimento dos campos.
/*/
//-------------------------------------------------------------------  

Static Function WFValidArr( aArray, Chost, cTo )
Return (( ! aScan( aArray, {|x| x[1] == .T. } ) == 0 ) .and. !(empty(alltrim(chost))) .and. !(empty(alltrim(cTo))) )

Static Function WFChangeComp(aCompany, oList)
    LOCAL nCompany := 0

    WHILE (nCompany < len(acompany))
        nCompany++
        
        if(oList:nAt == nCompany)
            aCompany[oList:nAt, 1] := !aCompany[oList:nAt, 1]
        ELSE
            aCompany[nCompany, 1] := .f.
        ENDIF
    ENDDO
    oList:Refresh(.f.)
RETURN


//-------------------------------------------------------------------
/*/{Protheus.doc} wfExemplo    
Fun��o de exemplo de utiliza��o da classe TWFProcess. 
/*/
//-------------------------------------------------------------------  

Static Function __WFExemp(cHostWF, cto)

	Local oProcess 	:= Nil									//Objeto da classe TWFProcess.
	Local cMailId 	:= ""									//ID do processo gerado. 
	
	//-------------------------------------------------------------------
	// "FORMULARIO"
	//-------------------------------------------------------------------  	
    conout("inicio") //
	//-------------------------------------------------------------------
	// Instanciamos a classe TWFProcess informando o c�digo e nome do processo.  
	//-------------------------------------------------------------------  
	
	oProcess := TWFProcess():New("000001", "Treinamento")

	//-------------------------------------------------------------------
	// Criamos a tafefa principal que ser� respondida pelo usu�rio.  
	//-------------------------------------------------------------------  
	oProcess:NewTask("FORMULARIO", "\workflow\__WFORM.html")

	//-------------------------------------------------------------------
	// Atribu�mos valor a um dos campos do formul�rio.  
	//-------------------------------------------------------------------  	   
	oProcess:oHtml:ValByName("TEXT_TIME", Time() )

	//-------------------------------------------------------------------
	// Informamos em qual diret�rio ser� gerado o formul�rio.  
	//-------------------------------------------------------------------  	 
	oProcess:cTo 		:= "HTML"    

	//-------------------------------------------------------------------
	// Informamos qual fun��o ser� executada no evento de timeout.  
	//-------------------------------------------------------------------  	
	oProcess:bTimeOut 	:= {{"U_WFTimeout()", 0, 0, 5 }}

	//-------------------------------------------------------------------
	// Informamos qual fun��o ser� executada no evento de retorno.   
	//-------------------------------------------------------------------  	
	oProcess:bReturn 	:= "U_WFRetorno()"

	//-------------------------------------------------------------------
	// Iniciamos a tarefa e recuperamos o nome do arquivo gerado.   
	//-------------------------------------------------------------------  
	
	cMailID := oProcess:Start()     

    conout(cvaltochar(cMailID))
	//-------------------------------------------------------------------
	// "LINK"
	//------------------------------------------------------------------- 
    
	//-------------------------------------------------------------------
	// Criamos o ling para o arquivo que foi gerado na tarefa anterior.  
	//------------------------------------------------------------------- 	
	oProcess:NewTask("LINK", "\workflow\__wflink.html")
	
	//-------------------------------------------------------------------
	// Atribu�mos valor a um dos campos do formul�rio.  
	//------------------------------------------------------------------- 
	oProcess:oHtml:ValByName("A_LINK", cHostWF + "/messenger/emp" + cEmpAnt + "/html/" + cMailId + ".htm") 
	
	//-------------------------------------------------------------------
	// Informamos o destinat�rio do email contendo o link.  
	//------------------------------------------------------------------- 	
	oProcess:cTo 		:= cTo  
	//oProcess:cCC 		:= cCC   
	
	//-------------------------------------------------------------------
	// Informamos o assunto do email.  
	//------------------------------------------------------------------- 	
	oProcess:cSubject	:= "Workflow via link Protheus"

	oProcess:UserSiga := "000000"            

	//-------------------------------------------------------------------
	// Iniciamos a tarefa e enviamos o email ao destinat�rio.
	//------------------------------------------------------------------- 	
	oProcess:Start()
	
Return    

//-------------------------------------------------------------------
/*/{Protheus.doc} wfRetorno    
Fun��oo executada no retorno do processo. 
/*/
//-------------------------------------------------------------------       
User Function WFRetorno( poProcess )  
	Local cTime 		:= ""
	Local cProcesso 	:= ""  
	Local cTarefa		:= ""  
	Local cMailID		:= ""
	
	//-------------------------------------------------------------------
	// Recuperamos a hora do processo utilizando o m�todo RetByName.
	//------------------------------------------------------------------- 		
	cTime 		:= poProcess:oHtml:RetByName("TEXT_TIME") 
     
 	//-------------------------------------------------------------------
	// Recuperamos o identificador do email utilizando o m�todo RetByName.
	//------------------------------------------------------------------- 		
	cMailID		:= poProcess:oHtml:RetByName("WFMAILID") 
  
	//-------------------------------------------------------------------
	// Recuperamos o ID do processo atrav�s do atributo do processo.
	//------------------------------------------------------------------- 		
	cProcesso 	:= poProcess:FProcessID  
 
	//-------------------------------------------------------------------
	// Recuperamos o ID da tarefa atrav�s do atributo do processo.
	//------------------------------------------------------------------- 	 
	cTarefa		:= poProcess:FTaskID  

	//-------------------------------------------------------------------
	// Exibe mensagem com dados do processamento no console.
	//-------------------------------------------------------------------                  
	ConOut( I18N("Retorno do processo gerado �s #1 ,  n�mero #2,  #3  tarefa #4 executado com sucesso!", {cTime, cProcesso, poProcess:oHtml:RetByName("WFMAILID"), cTarefa })) //""                                                                                                                                                                                                                                                                                                                                                                                                                              
Return Nil    

//-------------------------------------------------------------------
/*/{Protheus.doc} wfTimeout    
Fun��o executada no timeout do processo. 
/*/
//-------------------------------------------------------------------
User Function wfTimeout( poProcess )  
	//-------------------------------------------------------------------
	// Exibe mensagem com dados do processamento no console.
	//-------------------------------------------------------------------               
	Conout("Timeout do processo" + poProcess:FProcessID) //""                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
Return Nil    


//-------------------------------------------------------------------
/*/{Protheus.doc} MarkAll
Marca todos os registros (chamada no Header Click).

@param aList, array, vetor com os registros apresentados no list
@param nPos, number, linha posicionada

@author  Marcia Junko
@since   25/06/2021
/*/
//-------------------------------------------------------------------
Static Function MarkAll( aList, nPos )
	Local lMark := .F.
	
	aEval( aList, { |x| iif( !x[ nPos ], lMark := .T., )  } )
	aEval( aList, { |x, i| aList[ i, nPos ] := lMark } )
Return .T.


Static Function BALoadComp()
	Local aCompany := {}
	
	SET DELET ON

    OpenSM0()

    aEval( FWAllGrpCompany(), {|oComp| AAdd(aCompany, { .F., oComp, FWEmpName(oComp) }) } )
     
Return aCompany
