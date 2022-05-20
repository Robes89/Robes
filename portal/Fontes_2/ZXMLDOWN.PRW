#Include "Protheus.ch"
#Include "ApWebSrv.ch"
#Include "TopConn.ch"
  
/*/{Protheus.doc}''
''
@author Ovio Consultoria
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/  

User Function zBrXML(cFolderBx)

Local  oTela   := Nil
Local  cTitulo := "Baixar XML Sefaz."

Local  bValid  := {|| .T.  } 
Local  oFont1  := TFont():New("Arial",12,16,,.T.,,,,.T.,.F.)

Private cChaveNFe := Space(50)

DEFINE MSDIALOG oTela FROM 0, 0 To 250,550 Title cTitulo  Of GetWndDefault() PIXEL STYLE DS_MODALFRAME STATUS 
		
oTPane1 := TPanel():New(0,0,"",oTela,NIL,.T.,.F.,NIL,NIL,0,20,.T.,.T.)
oTPane1:Align := CONTROL_ALIGN_TOP
															
@ 010 ,010 Say "Informar a Chave da NFE" Size 450,8  Of oTPane1 PIXEL COLOR CLR_BLUE FONT oFont1
				
oTPane2 := TPanel():New(0,0,"",oTela,NIL,.T.,.F.,NIL,NIL,0,0,.T.,.F.)
oTPane2:Align := CONTROL_ALIGN_ALLCLIENT

oChave :=  TGet():New( 010  ,005 ,{|u| If(PCount()>0,cChaveNFe:=u,cChaveNFe )},oTPane2,260 ,011    ,/*cPict*/,bValid /*bValid*/ ,0 /*nClrFore*/, /*nClrBack*/,  /*oFont*/ ,.F.          ,             ,.T.            ,             ,.F.          ,           ,.F.         ,.F.          , {||.T. }/*bChange*/ ,.F. /*lReadOnly*/, .F. ,  , "cChaveNFE" , /*uParam25*/ , /*uParam26*/, /*uParam27*/, /*lHasButton*/, /*lNoButton*/, /*uParam30*/ ,"Chave NFE: "    ,1  /*nLabelPos*/ ,   /*oLabelFont*/,/*nLabelColor*/ ,/*cPlaceHold*/ ,/*lPicturePriority*/ ,/*lFocSel*/ )
				
oTPane4:= TPanel():New(0, 0, "", oTela, NIL, .T., .F., NIL, NIL,0 , 25 , .T., .F. )
oTPane4:Align:= CONTROL_ALIGN_BOTTOM
				
Activate MsDialog oTela Centered On Init EnchoiceBar(oTela , { || IIF(!Empty(cChaveNFe), fProcBc(Alltrim(cChaveNFe),cFolderBx), Aviso("Aviso","Informe a chave eletrônica para download!",{"Ok"})), oTela:End() },{|| oTela:End() } ) 

Return
/*/{Protheus.doc}''
''
@author Sergio Celestino
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/
Static Function fProcBc(cChaveNFe,cFolderBx)
Processa( {|| zBxXML(Alltrim(cChaveNFe),cFolderBx)})
Return .T.

/*/{Protheus.doc}''
''
@author Ovio Consultoria
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/ 
Static Function zBxXML(cChaveNFe,cFolderBx)

    Local aArea     := GetArea()
    Local lRet      := .T.
    Local cURL      := "https://www1.nfe.fazenda.gov.br/NFeDistribuicaoDFe/NFeDistribuicaoDFe.asmx?WSDL"
    Local cMsg      := ""
    Local oWsdl     := Nil
    Local cMsgRet   := ""
    Local cError    := ""
    Local cWarning  := ""
    Local cXmlGZip  := ""
    Local cArqXML   := ""
    Local cUfAutor  := SuperGetMV("MV_XMLXUF",  .F., "35")
    Local cTpAmb    := SuperGetMV("MV_XMLXAMB", .F., "1")
    Local cCNPJEmp  := Alltrim(SM0->M0_CGC)//Alltrim(Alltrim(FWArrFilAtu(FWCodEmp(),FWCodFil())[18]))
    Local lContinua := .T.
    Local lVerbose  := GetMv("EV_VERBOSE",,.F.)

    Private oXmlDocZip
 
        oWsdl := TWsdlManager():New()
        oWsdl:cSSLCACertFile := Alltrim(SuperGetMV("MV_XMLXCA",  .F., "\certs\0202_ca.pem"))
        oWsdl:cSSLCertFile   := Alltrim(SuperGetMV("MV_XMLXCER", .F., "\certs\0202_cert.pem"))
        oWsdl:cSSLKeyFile    := Alltrim(SuperGetMV("MV_XMLXKEY", .F., "\certs\0202_key.pem"))
        oWsdl:cSSLKeyPwd     := Alltrim(SuperGetMV("MV_XMLXPSW", .F., "senha"))
        oWsdl:nSSLVersion    := Alltrim(SuperGetMV("MV_XMLXPRO", .F., "0"))
        oWsdl:lSSLInsecure   := SuperGetMV("MV_XMSSLIN", .F., .T.)
        oWsdl:nTimeout       := 120
        oWsdl:lVerbose       := lVerbose
        oWsdl:lProcResp      := .F.
    
        //Tenta fazer o Parse da URL
        lRet := oWsdl:ParseURL(cURL)
        If ! lRet 
            ConOut("[u_zBxXML] - Erro ParseURL: " + oWsdl:cError)
            lContinua := .F.
        EndIf
        
        //Se for continuar o processamento
        If lContinua
 
            //Tenta definir a operação
            lRet := oWsdl:SetOperation("nfeDistDFeInteresse")
            If ! lRet 
                ConOut("[u_zBxXML] - Erro SetOperation: " + oWsdl:cError)
                lContinua := .F.
            EndIf
        EndIf

        //Se for continuar
        If lContinua
            cMsg := '<soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope">'                        + CRLF
            cMsg += '    <soapenv:Header/>'                                                                             + CRLF
            cMsg += '    <soapenv:Body>'                                                                                + CRLF
            cMsg += '        <nfeDistDFeInteresse xmlns="http://www.portalfiscal.inf.br/nfe/wsdl/NFeDistribuicaoDFe">'  + CRLF
            cMsg += '            <nfeDadosMsg>'                                                                         + CRLF
            cMsg += '                <distDFeInt xmlns="http://www.portalfiscal.inf.br/nfe" versao="1.01">'             + CRLF
            cMsg += '                    <tpAmb>'+Alltrim(cTpAmb)+'</tpAmb>'                                            + CRLF
            cMsg += '                     <cUFAutor>'+Alltrim(cUfAutor)+'</cUFAutor>'                                   + CRLF
            cMsg += '                     <CNPJ>'+Alltrim(cCNPJEmp)+'</CNPJ>'                                           + CRLF
            cMsg += '                     <consChNFe>'                                                                  + CRLF
            cMsg += '                         <chNFe>'+alltrim(cChaveNFe)+'</chNFe>'                                    + CRLF
            cMsg += '                     </consChNFe>'                                                                 + CRLF
            cMsg += '                </distDFeInt>'                                                                     + CRLF
            cMsg += '            </nfeDadosMsg>'                                                                        + CRLF
            cMsg += '        </nfeDistDFeInteresse>'                                                                    + CRLF
            cMsg += '    </soapenv:Body>'                                                                               + CRLF
            cMsg += '</soapenv:Envelope>'                                                                               + CRLF

            //Envia uma mensagem SOAP personalizada ao servidor
            lRet := oWsdl:SendSoapMsg(cMsg)
            If !lRet 
                Aviso("Aviso","[u_zBxXML] - Erro SendSoapMsg: " + oWsdl:cError,{"Ok"},3)
                Aviso("Aviso","[u_zBxXML] - Erro SendSoapMsg FaultCode: " + oWsdl:cFaultCode,{"Ok"},3)
                cErr := oWsdl:GetSoapResponse()
                Alert(cErr)
                lContinua := .F.
            EndIf
        EndIf
    
        //Se for continuar
        If lContinua
            //Pega a resposta do SOAP
            cMsgRet := oWsdl:GetSoapResponse()
                                
            //Transforma a resposta em um objeto
            oXmlDocZip := XmlParser(cMsgRet, "_", @cError, @cWarning)
            
            //Se existir Warning, mostra no console.log
            If !Empty(cWarning)
                Aviso("Aviso","[u_zBxXML] - Alert cWarning: " + cWarning ,{"Ok"})
            EndIf
            
            //Se houve erro, não permitirá prosseguir
            If !Empty(cError)
                Aviso("Aviso","[u_zBxXML] - Erro cError: " + cError,{"Ok"})
                lContinua := .F.
            EndIf
        EndIf
    
        //Se for continuar
        If lContinua
            //Se a tag DocZip existir (for diferente de Undefinied)
            If (Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP") != "U")
    
                //Pega tag que contém XML em zip
                cXmlGZip := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:TEXT
                
                //Gera arquivo XML
                cArqXML := fGeraXML(cXmlGZip, cChaveNFe , cFolderBx )

                If !Empty(cArqXML)
                    Aviso("Arquivo gerado com sucesso",cArqXML,{"Ok"},3)
                Else
                    Aviso("Aviso","Arquivo não gerado ",{"Ok"})
                Endif    
            else
                Aviso("Aviso","[u_zBxXML] - DocZip inexistente na consulta Sefaz!",{"Ok"})
            endif
        EndIf
    
        RestArea(aArea)

Return .T.
  
/*-------------------------------------------------------------------------------*
 | Func:  fGeraXML                                                               |
 | Desc:  Função para gerar o arquivo XML em uma pasta                           |
 *-------------------------------------------------------------------------------*/
  
Static Function fGeraXML(cConteudo , cChave , cFolderBx )
    Local aArea        := getArea()
    Local lRet         := .T. 
    Local cArquivo     := cChave + ".xml"
    Local cDiretorio      := Alltrim(GetMv("MV_OVLOG",,"\xml\log\")) 
    Local nTamanho     := 0
    Local cUnXML       := ""
    Local cDecode64  := ""
    Local cArqFull   := ""
    Local lHouveErro := .F.
      
    //Se o último caracter do diretório não for \, será barra \
    If SubStr(cDiretorio, Len(cDiretorio), 1) != "\"
        cDiretorio += "\"
    EndIf
      
    //Define o caminho final do arquivo
    cArqFull := cDiretorio + cArquivo
      
    //Pega o tamanho e descriptografa o conteúdo
    nTamanho  := Len(cConteudo)
    cDecode64 := Decode64(cConteudo)
    lRet      := GzStrDecomp(cDecode64, nTamanho, @cUnXML)
       
    //Se deu certo
    If lRet
          
        //Se o diretório não existir, cria
        If ! ExistDir(cDiretorio)
            MakeDir(cDiretorio)
        EndIf
          
        //Cria o arquivo com o conteúdo
        If !Empty(cFolderBx)
            cPasta := cFolderBx
        Else
            cPasta := cDiretorio
        Endif    
        
        nLenUnXML := Len( cUnXML )
        nHandle   := FCreate( cPasta+"nfe"+cArquivo , 0 , , .T. ) 
        If nHandle = -1
            Aviso("Aviso","Erro ao criar arquivo "+cPasta+"nfe"+cArquivo+ " - fError " + Str(Ferror()),{"Ok"},3 )
        Else
            FWrite( nHandle, cUnXML, nLenUnXML )
            FClose( nHandle )   
        Endif

    Else
        Aviso("Aviso","Erro ao descompactar arquivo na pasta "+cPasta,{"Ok"})
        lHouveErro := .T.
    EndIf
  
    //Se houve erro, zera o nome do arquivo para retornar em branco
    If lHouveErro
        cArqFull := ""
    EndIf
  
    RestArea(aArea)
Return cPasta+"nfe"+cArquivo
