#Include "Totvs.ch"
#Include "ApWebSrv.ch"
#Include "TopConn.ch"
#Include "Xmlxfun.ch"
#INCLUDE "ap5mail.ch"
#INCLUDE "shell.ch"
#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "TbiConn.ch"

/*/{Protheus.doc}'Integrar XMLS Sefaz'
'Realizar o Downloas de Notas Fiscais Eletronicas e CTE'
@author Ovio Consultoria
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/  
User Function XMLINTEG(aParams)
    
    Private cFolderBx := ""
    Private aHDR   := {}
    Private aLog   := {}
    Private lWhenA := .T.
    Private lWhenB := .T.
    Private lWhenC := .T.
    Private lCheckA:= .F.
    Private lCheckB:= .F.
    Private lCheckC:= .F.
    Private lCheckD:= .F.
    Private lSair  := .F.
    Private aDownNfe :={}
    Private aDownCte := {}
 
    Private cDirBx      := ""
    Private aLogFor     := {}
    Private aCadFor     := {}
    Private cThread		:= AllTrim(Str(ThreadID()))
    Private oXmlfim     := Nil
    Private nOpc        := 2

    Private aEmps       := {}
    Private cEmp        := ""
    Private cFil        := ""
    Private lSChedule	:= IsInCallStack("WFLAUNCHER")

    If (!lSChedule)

        fSelBrowse()

        if ( lSair .Or. (!lCheckA .And. !lCheckB .And. !lCheckC) )
            Return
        Endif

        If lCheckD .Or. lCheckC
            cFolderBx := XMLSELARQ()
        Endif

        If lCheckC
            If !Empty(cFolderBx)
                fMoveArq(cFolderBx)
            Else
                Return
            Endif
        Elseif lCheckB
            u_zBrXML(cFolderBx)
        Endif

        fProclog()

        If !lCheckB
            Processa({|| DownNfe(cFolderBx) })
            Processa({|| DownCte(cFolderBx) })
        Endif

        fBrowLog()

    Else

        cEmp := aParams[1]
		cFil := aParams[2]
    
        aLogFor  := {}
        aCadFor  := {}

        RPCSetType(3)
        RpcSetEnv(Alltrim(cEmp),Alltrim(cFil),Nil,Nil,"COM")

        Conout("["+cThread+"] - Sincronizado - Empresa: " + cEmp + " Filial: " + Alltrim(cFil) + " Inicio:" + Time() )

        cEmpAnt := Alltrim(cEmp)
        cFilAnt := Alltrim(cFil)
            
        aAreaSM0 := SM0->(GetArea())
        SM0->(dbSeek(cemp+cfil))

        Conout("["+cThread+"] - Ambiente preparado - Empresa: " + Alltrim(cEmpAnt) + " Filial: " + Alltrim(cFilAnt) + " Inicio:" + Time() )

        fProclog()
        DownNfe(cFolderBx)
        DownCte(cFolderBx)

        Conout("["+cThread+"] - sincronizacao com a Sefaz finalizada - Fim:"+Time())
        RestArea(aAreaSM0)

        RpcClearEnv()
    Endif

Return

/*/{Protheus.doc}'DownNfe'
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
Static Function DownNfe(cFolderBx)

    Local aArea     := GetArea()
    Local aRejeicao := FWGetSX5 ("XM",,)
    Local lRet      := .T.
    Local nPos      := 0
    Local cURLSef   := Alltrim(SuperGetMv("MV_XMLXWSD",.F.,"https://www1.nfe.fazenda.gov.br/NFeDistribuicaoDFe/NFeDistribuicaoDFe.asmx?WSDL"))
    Local cMsg      := ""
    Local cMsgRet   := ""
    Local cError    := ""
    Local cWarning  := ""
    Local cXmlGZip  := ""
    Local cArqXML   := ""
    Local cHoraCon  := ""
    Local cAmbiente := ""
    Local lContinua := .T.
    Local NIL       := 1
    Local oWsdl     := Nil
    Local nI        := 1
    Local nIni      := 1
    Local nRetroNsu := GetMv("EV_RETRNSU",,70)
    Local nLidos    := 0
    Local lErro     := .F.
    Local lVerbose  := GetMv("EV_VERBOSE",,.F.)

    Private nTimeToDwn := GetMv("OV_TIMEDWN",,8000)
    Private cUfAutor   := Alltrim(SuperGetMV("MV_XMLXUF",  .F., "35"))
    Private cTpAmb     := Alltrim(SuperGetMV("MV_XMLXAMB", .F., "1"))
    Private cXmlNSU    := ""
    Private cNumNSU    := Alltrim(GetMv("OV_NSUNUM",,"000000000000000"))
    Private cMaxNSU    := Soma1(cNumNSU,15)
    Private cChaveNFe  := ""
    Private nArqXml    := 0

    Private cDirBx      := ""
    Private cDir        := Alltrim(GetMv("MV_OVINN",,"\xml\inn\"))
    Private cDirRes     := Alltrim(GetMv("MV_OVRES",,"\xml\res\"))
    Private cDirLog     := Alltrim(GetMv("MV_OVLOG",,"\xml\log\"))
    Private cDirErr     := Alltrim(GetMv("MV_OVERR",,"\xml\err\"))
    Private cDirMan     := Alltrim(GetMv("MV_OVMAN",,"\xml\manifesto\"))

    Private cCNPJEmp   := Alltrim(SM0->M0_CGC) //Alltrim(Alltrim(FWArrFilAtu(FWCodEmp(),FWCodFil())[18]))
    Private oXmlDocZip := Nil
    Private cININSU    := ""

    If (lSChedule)
        Conout("[xmlinteg] Empresa: "+cEmp+" Filial: "+cFil +" - DownNFE - Time: " + Time() )
    Endif

    if Val(cNumNSU)>=nRetroNsu
        cNumNSU := StrZero(Val(cNumNSU)-nRetroNsu,15)
    Else
        cNumNSU := StrZero(Val(cNumNSU)-Val(cNumNSU),15)
    Endif

    oWsdl := Nil
    oWsdl := TWsdlManager():New()
    oWsdl:cSSLCACertFile := Alltrim(SuperGetMV("MV_XMLXCA",  .F., "\certs\000001_ca.pem"))
    oWsdl:cSSLCertFile   := Alltrim(SuperGetMV("MV_XMLXCER", .F., "\certs\000001_cert.pem"))
    oWsdl:cSSLKeyFile    := Alltrim(SuperGetMV("MV_XMLXKEY", .F., "\certs\000001_key.pem"))
    oWsdl:cSSLKeyPwd     := Alltrim(SuperGetMV("MV_XMLXPSW", .F., "1234"))
    oWsdl:nSSLVersion    := Alltrim(SuperGetMV("MV_XMLXPRO", .F., "0"))
    oWsdl:lSSLInsecure   := SuperGetMV("MV_XMSSLIN", .F., .T.)
    oWsdl:nTimeout       := 120
    oWsdl:lVerbose       := lVerbose
    oWsdl:lProcResp      := .F.

    lRet := oWsdl:ParseURL(cURLSef)
    If !lRet
        lErro := .T.
        If (!lSChedule)
            Aviso("Aviso","[IXMLINTEG] - Erro ParseURL: " + oWsdl:cError,{"Ok"})
        Else
            ConOut("[XMLINTEG] - Erro ParseURL: " + oWsdl:cError)
        Endif
        lContinua := .F.
    EndIf

    Conout("["+cThread+"] - Conexao com WSDL Sefaz realizada - " + Time() )
    If lContinua
        lRet := oWsdl:SetOperation("nfeDistDFeInteresse")
        If !lRet
            lErro := .T.
            If (!lSChedule)
                Aviso("Aviso","[XMLINTEG] - Erro SetOperation: " + oWsdl:cError,{"Ok"})
            Else
                ConOut("[XMLINTEG] - Erro SetOperation: " + oWsdl:cError)
            Endif
            lContinua := .F.
        EndIf
    EndIf

    Conout("["+cThread+"] - Operacao nfeDistDFeInteresse Definida - " + Time() )

    If lContinua
        cMsg := '<soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope">'                        + CRLF
        cMsg += '    <soapenv:Header/>'                                                                             + CRLF
        cMsg += '    <soapenv:Body>'                                                                                + CRLF
        cMsg += '        <nfeDistDFeInteresse xmlns="http://www.portalfiscal.inf.br/nfe/wsdl/NFeDistribuicaoDFe">'  + CRLF
        cMsg += '            <nfeDadosMsg>'                                                                         + CRLF
        cMsg += '                <distDFeInt xmlns="http://www.portalfiscal.inf.br/nfe" versao="1.01">'             + CRLF
        cMsg += '                    <tpAmb>'+cTpAmb+'</tpAmb>'                                                     + CRLF
        cMsg += '                    <cUFAutor>'+cUfAutor+'</cUFAutor>'                                             + CRLF
        cMsg += '                    <CNPJ>'+cCNPJEmp+'</CNPJ>'                                                     + CRLF
        cMsg += '                    <distNSU>'                                                                     + CRLF
        cMsg += '                        <ultNSU>'+cNumNSU+'</ultNSU>'                                              + CRLF
        cMsg += '                    </distNSU>'                                                                    + CRLF
        cMsg += '                </distDFeInt>'                                                                     + CRLF
        cMsg += '            </nfeDadosMsg>'                                                                        + CRLF
        cMsg += '        </nfeDistDFeInteresse>'                                                                    + CRLF
        cMsg += '     </soapenv:Body>'                                                                              + CRLF
        cMsg += '</soapenv:Envelope>'                                                                               + CRLF

        lRet := oWsdl:SendSoapMsg(cMsg)
        If !lRet
            lErro := .T.
            If (!lSChedule)
                Aviso("Aviso","[XMLINTEG] - Erro SendSoapMsg: " + oWsdl:cError,{"Ok"})
                cErr := oWsdl:GetSoapResponse()
                Alert(cErr)
            else
                ConOut("[XMLINTEG] - Erro SendSoapMsg: " + oWsdl:cError)
            Endif
            lContinua := .F.
        Endif
        Conout("["+cThread+"] - SOAP nfeDistDFeInteresse Realizado  - NSU: " + cNumNSU )
    EndIf

    If lContinua

        cMsgRet := oWsdl:GetSoapResponse()

        oXmlDocZip := XmlParser(cMsgRet, "_", @cError, @cWarning)

        If !Empty(cWarning)
            lErro := .T.
            If (!lSChedule)
                Aviso("Aviso", "cWarning: " + cWarning , {"Ok"} )
            Else
                ConOut("[XMLINTEG] - cWarning: " + cWarning)
            Endif
            lContinua := .F.
        EndIf

        If !Empty(cError)
            lErro := .T.
            If (!lSChedule)
                Aviso("Aviso", "Erro cError:" + cError , {"Ok"} )
            Else
                ConOut("[XMLINTEG] - Erro cError: " + cError)
            Endif
            lContinua := .F.
        EndIf

        Conout("["+cThread+"] - Resposta Sefaz Obtida com sucesso  - " + Time() )

        If ( Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_CSTAT:TEXT") != "U"  )
            cStat := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_CSTAT:TEXT
            nPos  := aScan(aRejeicao,{ |x| Alltrim(aRejeicao[3]) == Alltrim(cStat)  } )
            If nPos>0
                lErro := .T.
                If (!lSChedule)
                    Aviso("Aviso - Rejeicao ", aRejeicao[nPos][3] + '-' + aRejeicao[nPos][4] , {"Ok"} )
                Else
                    ConOut("[XMLINTEG] - Rejeicao Filial: " + aRejeicao[nPos][1] + '-'+ aRejeicao[nPos][3] + '-' +aRejeicao[nPos][4] )
                Endif
                lContinua := .F.
            Endif
            Conout("["+cThread+"] - Lote retornado sem rejeicao - CSTAT: " + cStat + " - " + Time() )
        Endif
    EndIf

    If lContinua
        If ( Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_DHRESP:TEXT") != "U"  )
            cHoraCon := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_DHRESP:TEXT
        Endif
        If ( Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_MAXNSU:TEXT")  != "U"  )
            cMaxNSU := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_MAXNSU:TEXT
        Endif
        If ( Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_TPAMB:TEXT")  != "U"  )
            cAmbiente := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_TPAMB:TEXT
        Endif
        if ( Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_ULTNSU:TEXT")  != "U"  )
            cUltNSU := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_ULTNSU:TEXT
        endif

        If (Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP") != "U")
            If (Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP") == "A")

                nFim   := Val(cMaxNSU)
                lFirst := .T.

                If (!lSChedule)
                    Procregua(nFim)
                Endif

                For nIni := Val(cNumNSU) To nFim Step 50

                    lContinua := .T.

                    If !lFirst

                        FreeObj(oXmlDocZip)

                        If lContinua
                            lRet := oWsdl:SetOperation("nfeDistDFeInteresse")
                            If !lRet
                                If Substr(oWsdl:cError,1,33)=="Unknown element WSCorIDSOAPHeader" //( Sefaz mudou header e esta retornando erro mesmo getsoapresponse funcionando - chamado na Totvs)
                                    lRet := .T.
                                Else
                                    lErro := .T.
                                    If (!lSChedule)
                                        Aviso("Aviso","[XMLINTEG] - Erro SetOperation: " + oWsdl:cError,{"Ok"})
                                    Else
                                        ConOut("[XMLINTEG] - Erro SetOperation: " + oWsdl:cError)
                                    Endif
                                    lContinua := .F.
                                Endif
                            Else
                                Conout("["+cThread+"] - Operacao nfeDistDFeInteresse Definida - " + Time() )
                            EndIf
                        EndIf

                        cXmlNSU := Soma1(cXmlNSU)

                        cMsg := '<soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope">'                        + CRLF
                        cMsg += '    <soapenv:Header/>'                                                                             + CRLF
                        cMsg += '    <soapenv:Body>'                                                                                + CRLF
                        cMsg += '        <nfeDistDFeInteresse xmlns="http://www.portalfiscal.inf.br/nfe/wsdl/NFeDistribuicaoDFe">'  + CRLF
                        cMsg += '            <nfeDadosMsg>'                                                                         + CRLF
                        cMsg += '                <distDFeInt xmlns="http://www.portalfiscal.inf.br/nfe" versao="1.01">'             + CRLF
                        cMsg += '                    <tpAmb>'+cTpAmb+'</tpAmb>'                                                     + CRLF
                        cMsg += '                    <cUFAutor>'+cUfAutor+'</cUFAutor>'                                             + CRLF
                        cMsg += '                    <CNPJ>'+cCNPJEmp+'</CNPJ>'                                                     + CRLF
                        cMsg += '                    <distNSU>'                                                                     + CRLF
                        cMsg += '                        <ultNSU>'+cXmlNSU+'</ultNSU>'                                              + CRLF
                        cMsg += '                    </distNSU>'                                                                    + CRLF
                        cMsg += '                </distDFeInt>'                                                                     + CRLF
                        cMsg += '            </nfeDadosMsg>'                                                                        + CRLF
                        cMsg += '        </nfeDistDFeInteresse>'                                                                    + CRLF
                        cMsg += '     </soapenv:Body>'                                                                              + CRLF
                        cMsg += '</soapenv:Envelope>'                                                                               + CRLF

                        lRet := oWsdl:SendSoapMsg(cMsg)
                        If !lRet
                            If Substr(oWsdl:cError,1,33)=="Unknown element WSCorIDSOAPHeader"
                                lRet := .T.
                            Else
                                lErro := .T.
                                If (!lSChedule)
                                    Aviso("Aviso","[XMLINTEG] - Erro SendSoapMsg: " + oWsdl:cError,{"Ok"})
                                    cErr := oWsdl:GetSoapResponse()
                                    Alert(cErr)
                                    lContinua := .F.
                                    Exit
                                Else
                                    ConOut("[XMLINTEG] - Erro SendSoapMsg: " + oWsdl:cError)
                                    lContinua := .F.
                                    Exit
                                EndIf
                            Endif
                        Endif

                        Conout("["+cThread+"] - SOAP nfeDistDFeInteresse Realizado  - NSU: " + cNumNSU )

                        If lContinua

                            cMsgRet := oWsdl:GetSoapResponse()

                            oXmlDocZip := XmlParser(cMsgRet, "_", @cError, @cWarning)

                            If !Empty(cWarning)
                                lErro := .T.
                                If (!lSChedule)
                                    Aviso("Aviso", "cWarning: " + cWarning , {"Ok"} )
                                Else
                                    ConOut("[XMLINTEG] - cWarning: " + cWarning)
                                Endif
                                lContinua := .F.
                                Exit
                            EndIf

                            If !Empty(cError)
                                lErro := .T.
                                If (!lSChedule)
                                    Aviso("Aviso", "Erro cError:" + cError , {"Ok"} )
                                Else
                                    ConOut("[XMLINTEG] - Erro cError: " + cError)
                                Endif
                                lContinua := .F.
                                Exit
                            EndIf

                            If (Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP") == "U")
                                lContinua := .F.
                            Endif
                        Endif
                    EndIf

                    If lContinua
                        For nI := 1 To Len(oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP)

                            lFirst := .F.

                            Conout("["+cThread+"] - Processando XML: "+Alltrim(Str(nI)) + " - " + Time() )

                            cChaveNFe := ""
                            cXmlGZip  := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP[nI]:TEXT
                            cXmlNSU   := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP[nI]:_NSU:TEXT

                            If (!lSChedule)
                                IncProc("Download do NSU: "+cXmlNSU+" até o NSU: "+cMaxNSU+".")
                            Endif

                            Aadd(aLog,{;
                                        cFilAnt,;   //Filial
                                        cNumNSU,;   //Nsu Inicial
                                        cXmlNSU,;   //Nsu Processado
                                        cMaxNSU,;   //Nsu Final
                                        "",;        //Chave da Nota
                                        "",;        //Xml Tipo
                                        "",;        //Observacao
                                        "",;        //B=BAIXADO E N=NAO BAIXADO
                                        nI,;        //Item do lote retornado
                                        "DownNfe" })

                            lContinua := fGrXmlNfe(cXmlGZip, cXmlNSU , cHoraCon , cMaxNSU , cAmbiente , cUltNSU , cFolderBx )

                            nLidos++
                        Next
                    Endif
                Next

                If Len(aDownNfe)>0
                    If (!lSChedule)
                        FWMsgRun(, {|| Sleep(nTimeToDwn),fBxChvNfe(aDownNfe) }, "Aguarde", "Aguarde" + "baixas dos Xml manifestados")
                    Else
                        conout("Sleep nTimeToDwn")
                        Sleep(nTimeToDwn)
                        conout("baixas xmls manifestados")
                        fBxChvNfe(aDownNfe)
                    Endif
                Endif
            Else
                If (!lSChedule)
                    Procregua(LastRec())
                Endif

                If Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:TEXT")!="U"
                    cChaveNFe := ""
                    cXmlGZip  := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:TEXT
                    cXmlNSU   := iif(Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:_NSU:TEXT") != "U",oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:_NSU:TEXT,"0")

                    Aadd(aLog,{;
                        cFilAnt,;//Filial
                    cNumNSU,;//Nsu Inicial
                    cXmlNSU,;//Nsu Processado
                    cMaxNSU,;//Nsu Final
                    "",;//Chave da Nota
                    "",;//Xml Tipo
                    "",;//Observacao
                    "",;//B=BAIXADO E N=NAO BAIXADO
                    nI,;//Item do lote retornado
                    "DownNfe" })

                    lContinua := fGrXmlNfe(cXmlGZip, cXmlNSU , cHoraCon , cMaxNSU , cAmbiente , cUltNSU , cFolderBx )

                    nLidos++
                Endif
            Endif
        Else
            If (!lSChedule)
                Aviso("Aviso", "[IXMLINTEG] - sem arquivos para download com o NSU "+cNumNSU +" , verifique!" , {"Ok"} )
            Else
                conout("[IXMLINTEG] - sem arquivo para download com o nsu "+cNumNSU)
            Endif
        Endif
    EndIf

    if Val(cXmlNSU)<=Val(cMaxNSU) .And. Val(cXmlNSU)>=Val(cNumNSU) .And. !lErro
        PutMv("OV_NSUNUM", Soma1(cXmlNSU) )
    Endif

    Conout("["+cThread+"] - Atualizando NSU OV_NSUNUM " + Soma1(cXmlNSU) )

    if Len(aCadFor)>0
        Conout("["+cThread+"] - Enviando E-Mail de fornecedores cadastrados ")
        CadMailEnv()
    endif
    If Len(aLogFor)>0
        Conout("["+cThread+"] - Enviando E-Mail de LOG para fornecedores incompleto. ")
        fNotifCad()
    Endif

    If (!lSChedule)

        cTextFim := "Foram lidos " + Alltrim(Str(nLidos)) +" e "+Alltrim(Str(nArqXml))+" arquivos baixados." + chr(13)+chr(10)
        cTextFim += "NSU INICIAL : " + cNumNSU + chr(13) + chr(10)
        cTextFim += "NSU FINAL   : " + cMaxNSU + chr(13) + chr(10)
        cTextFim += "PROXIMO NSU : " + Getmv("OV_NSUNUM") +chr(13) + chr(10)

        Alert(cTextFim)
    Else
        conout("[IXMLINTEG] - Empresa: "+cEmp+" Filial: "+cFil+" Foi realizado o download de "+Alltrim(Str(nArqXml))+" arquivos.")
    Endif

    RestArea(aArea)

    If (lSChedule)
        Conout("[xmlinteg ] Empresa: "+cEmp+" Filial: "+cFil +" - DownNFE FIM - Time: " + Time() )
    Endif

Return cArqXML


/*/{Protheus.doc}'DownCte' 
'Consumir WS para baixar XML de CTE'
@author Sergio Celestino
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/ 
Static Function DownCte(cFolderBx)

    Local aArea     := GetArea()
    Local aRejeicao := FWGetSX5 ("XM",,)
    Local lRet      := .T.
    Local nPos      := 0
    Local cURLSef   := Alltrim(SuperGetMv("MV_CTEXWSD",.F.,"https://www1.cte.fazenda.gov.br/CTeDistribuicaoDFe/CTeDistribuicaoDFe.asmx?WSDL"))
    Local cMsg      := ""
    Local cMsgRet   := ""
    Local cError    := ""
    Local cWarning  := ""
    Local cXmlGZip  := ""
    Local cArqXML   := ""
    Local cHoraCon  := ""
    Local cAmbiente := ""

    Local lContinua := .T.
    Local NIL       := 1
    Local oWsdl     := Nil
    Local nRetroNsu := GetMv("EV_RETRNSU",,70)
    Local nLidos    := 0
    Local lErro     := .F.
    Local nI        := 1
    Local nIni      := 1
    Local lVerbose  := GetMv("EV_VERBOSE",,.F.)

    Private nTimeToDwn := GetMv("OV_TIMEDWN",,8000)
    Private cUfAutor   := Alltrim(SuperGetMV("MV_XMLXUF",  .F., "35"))
    Private cTpAmb     := Alltrim(SuperGetMV("MV_XMLXAMB", .F., "1"))
    Private cXmlNSU    := ""
    Private cCTENSU    := Alltrim(GetMv("OV_NSUCTE",,"000000000000000"))
    Private cMaxCTE    := Soma1(cCTENSU)
    Private cChaveNFe  := ""
    Private nArqXml    := 0
    Private cCNPJEmp   := Alltrim(SM0->M0_CGC)
    Private oXmlDocZip := Nil

    Private cDirBx      := ""
    Private cDir        := Alltrim(GetMv("MV_OVINN",,"\xml\inn\"))
    Private cDirRes     := Alltrim(GetMv("MV_OVRES",,"\xml\res\"))
    Private cDirLog     := Alltrim(GetMv("MV_OVLOG",,"\xml\log\"))
    Private cDirErr     := Alltrim(GetMv("MV_OVERR",,"\xml\err\"))
    Private cDirMan     := Alltrim(GetMv("MV_OVMAN",,"\xml\manifesto\"))

    If (lSChedule)
        Conout("[xmlinteg] Empresa: "+cEmp+" Filial: "+cFil +" - DownCTE - Time: " + Time() )
    Endif

    if Val(cCTENSU)>=nRetroNsu
        cCTENSU := StrZero(Val(cCTENSU)-nRetroNsu,15)
    Else
        cCTENSU := StrZero(Val(cCTENSU)-Val(cCTENSU),15)
    Endif

    cMaxNSU := Soma1(cCTENSU,15)

    oWsdl := TWsdlManager():New()
    oWsdl:cSSLCACertFile := Alltrim(SuperGetMV("MV_XMLXCA",  .F., "\certs\000001_ca.pem"))
    oWsdl:cSSLCertFile   := Alltrim(SuperGetMV("MV_XMLXCER", .F., "\certs\000001_cert.pem"))
    oWsdl:cSSLKeyFile    := Alltrim(SuperGetMV("MV_XMLXKEY", .F., "\certs\000001_key.pem"))
    oWsdl:cSSLKeyPwd     := Alltrim(SuperGetMV("MV_XMLXPSW", .F., "1234"))
    oWsdl:nSSLVersion    := Alltrim(SuperGetMV("MV_XMLXPRO", .F., "0"))
    oWsdl:lSSLInsecure   := SuperGetMV("MV_XMSSLIN", .F., .T.)
    oWsdl:nTimeout       := 120
    oWsdl:lVerbose       := lVerbose
    oWsdl:lProcResp      := .F.

    lRet := oWsdl:ParseURL(cURLSef)
    If !lRet
        lErro := .T.
        If (!lSChedule)
            Aviso("Aviso","[IXMLINTEG] - Erro ParseURL: " + oWsdl:cError,{"Ok"})
        Else
            ConOut("[XMLINTEG] - Erro ParseURL: " + oWsdl:cError)
        Endif
        lContinua := .F.
    EndIf

    Conout("["+cThread+"] - Conexao com WSDL Sefaz realizada - " + Time() )

    If lContinua
        lRet := oWsdl:SetOperation("cteDistDFeInteresse")
        If !lRet
            lErro := .T.
            If (!lSChedule)
                Aviso("Aviso","[XMLINTEG] - Erro SetOperation: " + oWsdl:cError,{"Ok"})
            Else
                ConOut("[XMLINTEG] - Erro SetOperation: " + oWsdl:cError)
            Endif
            lContinua := .F.
        Endif
    EndIf

    Conout("["+cThread+"] - Operacao cteDistDFeInteresse Definida - " + Time() )

    If lContinua

        cMsg := '<?xml version="1.0" encoding="UTF-8"?>'                                                                    + CRLF
        cMsg += '<soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope">'                                + CRLF
        cMsg += '    <soapenv:Header/>'                                                                                     + CRLF
        cMsg += '    <soapenv:Body>'                                                                                        + CRLF
        cMsg += '    <ns1:cteDistDFeInteresse xmlns:ns1="http://www.portalfiscal.inf.br/cte/wsdl/CTeDistribuicaoDFe">'      + CRLF
        cMsg += '    <ns1:cteDadosMsg>'                                                                                     + CRLF
        cMsg += '        <distDFeInt xmlns="http://www.portalfiscal.inf.br/cte" versao="1.00">'                             + CRLF
        cMsg += '            <tpAmb>'+cTpAmb+'</tpAmb>'                                                                     + CRLF
        cMsg += '            <cUFAutor>'+cUfAutor+'</cUFAutor>'                                                             + CRLF
        cMsg += '            <CNPJ>'+cCNPJEmp+'</CNPJ>'                                                                     + CRLF
        cMsg += '            <distNSU>'                                                                                     + CRLF
        cMsg += '                <ultNSU>'+cCTENSU+'</ultNSU>'                                                              + CRLF
        cMsg += '            </distNSU>'                                                                                    + CRLF
        cMsg += '        </distDFeInt>'                                                                                     + CRLF
        cMsg += '    </ns1:cteDadosMsg>'                                                                                    + CRLF
        cMsg += '    </ns1:cteDistDFeInteresse>'                                                                            + CRLF
        cMsg += '    </soapenv:Body>'                                                                                       + CRLF
        cMsg += '</soapenv:Envelope>'                                                                                       + CRLF

        lRet := oWsdl:SendSoapMsg(cMsg)
        If !lRet
            lErro := .T.
            If (!lSChedule)
                Aviso("Aviso","[XMLINTEG] - Erro SendSoapMsg: " + oWsdl:cError,{"Ok"})
                cErr := oWsdl:GetSoapResponse()
                Alert(cErr)
            else
                ConOut("[XMLINTEG] - Erro SendSoapMsg: " + oWsdl:cError)
            Endif
            lContinua := .F.
        Endif
        Conout("["+cThread+"] - SOAP cteDistDFeInteresse Realizado  - NSU: " + cCTENSU )
    EndIf

    If lContinua

        lRet := oWsdl:SetOperation("cteDistDFeInteresse")
        If !lRet
            lErro := .T.
            If (!lSChedule)
                Aviso("Aviso","[IXMLINTEG] - Erro SetOperation: " + oWsdl:cError,{"Ok"})
            Else
                ConOut("[XMLINTEG] - Erro SetOperation: " + oWsdl:cError)
            Endif
            lContinua := .F.
        EndIf

        cMsgRet := oWsdl:GetSoapResponse()

        oXmlDocZip := XmlParser(cMsgRet, "_", @cError, @cWarning)

        If !Empty(cWarning)
            lErro := .T.
            If (!lSChedule)
                Aviso("Aviso", "cWarning: " + cWarning , {"Ok"} )
                aLog[Len(aLog)][7] := "cWarning ao fazer parser do arquivo enviado pela sefaz: "+cWarning
                aLog[Len(aLog)][8] := "N"
            Else
                ConOut("[XMLINTEG] - cWarning: " + cWarning)
                aLog[Len(aLog)][7] := "cWarning ao fazer parser do arquivo enviado pela sefaz: "+cWarning
                aLog[Len(aLog)][8] := "N"
            Endif
        EndIf

        If !Empty(cError)
            lErro := .T.
            If (!lSChedule)
                Aviso("Aviso", "Erro cError:" + cError , {"Ok"} )
                aLog[Len(aLog)][7] := "cError ao fazer parser do arquivo enviado pela sefaz: "+cError
                aLog[Len(aLog)][8] := "N"
            Else
                ConOut("[XMLINTEG] - Erro cError: " + cError)
                aLog[Len(aLog)][7] := "cError ao fazer parser do arquivo enviado pela sefaz: "+cError
                aLog[Len(aLog)][8] := "N"
            Endif
            lContinua := .F.
        EndIf

        Conout("["+cThread+"] - Resposta Sefaz Obtida com sucesso  - " + Time() )

        If ( Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_CSTAT:TEXT") != "U"  )
            cStat := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_CSTAT:TEXT
            nPos  := aScan(aRejeicao,{ |x| Alltrim(aRejeicao[3]) == Alltrim(cStat)  } )
            If nPos>0
                lErro := .T.
                If (!lSChedule)
                    Aviso("Aviso - Rejeicao ", aRejeicao[nPos][3] + '-' + aRejeicao[nPos][4] , {"Ok"} )
                Else
                    ConOut("[XMLINTEG] - Rejeicao Filial: " + aRejeicao[nPos][1] + '-'+ aRejeicao[nPos][3] + '-' +aRejeicao[nPos][4] )
                Endif
                lContinua := .F.
            Endif
            Conout("["+cThread+"] - Lote retornado sem rejeicao - CSTAT: " + cStat + " - " + Time() )
        Endif
    EndIf

    If lContinua
        If ( Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_DHRESP:TEXT") != "U"  )
            cHoraCon := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_DHRESP:TEXT
        Endif
        If ( Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_MAXNSU:TEXT")  != "U"  )
            cMaxCTE := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_MAXNSU:TEXT
        Endif
        If ( Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_TPAMB:TEXT")  != "U"  )
            cAmbiente := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_TPAMB:TEXT
        Endif
        if ( Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_ULTNSU:TEXT")  != "U"  )
            cUltNSU := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_ULTNSU:TEXT
        endif

        If (Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP") != "U")
            If (Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP") == "A")

                nFim   := Val(cMaxCTE)
                lFirst := .T.

                If (!lSChedule)
                    Procregua(nFim)
                Endif

                For nIni := Val(cCTENSU) To nFim Step 50

                    lContinua := .T.

                    If !lFirst

                        FreeObj(oXmlDocZip)

                        If lContinua
                            lRet := oWsdl:SetOperation("cteDistDFeInteresse")
                            If !lRet
                                If Substr(oWsdl:cError,1,33)=="Unknown element WSCorIDSOAPHeader" //( Sefaz mudou header e esta retornando erro mesmo getsoapresponse funcionando - chamado na Totvs)
                                    lRet := .T.
                                Else
                                    lErro := .T.
                                    If (!lSChedule)
                                        Aviso("Aviso","[XMLINTEG] - Erro SetOperation: " + oWsdl:cError,{"Ok"})
                                    Else
                                        ConOut("[XMLINTEG] - Erro SetOperation: " + oWsdl:cError)
                                    Endif
                                    lContinua := .F.
                                Endif
                            EndIf
                        EndIf

                        cXmlNSU := Soma1(cXmlNSU)

                        cMsg := '<?xml version="1.0" encoding="UTF-8"?>'                                                                    + CRLF
                        cMsg += '<soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope">'                                + CRLF
                        cMsg += '    <soapenv:Header/>'                                                                                     + CRLF
                        cMsg += '    <soapenv:Body>'                                                                                        + CRLF
                        cMsg += '    <ns1:cteDistDFeInteresse xmlns:ns1="http://www.portalfiscal.inf.br/cte/wsdl/CTeDistribuicaoDFe">'      + CRLF
                        cMsg += '    <ns1:cteDadosMsg>'                                                                                     + CRLF
                        cMsg += '        <distDFeInt xmlns="http://www.portalfiscal.inf.br/cte" versao="1.00">'                             + CRLF
                        cMsg += '            <tpAmb>'+cTpAmb+'</tpAmb>'                                                                     + CRLF
                        cMsg += '            <cUFAutor>'+cUfAutor+'</cUFAutor>'                                                             + CRLF
                        cMsg += '            <CNPJ>'+cCNPJEmp+'</CNPJ>'                                                                     + CRLF
                        cMsg += '            <distNSU>'                                                                                     + CRLF
                        cMsg += '                <ultNSU>'+cXmlNSU+'</ultNSU>'                                                              + CRLF
                        cMsg += '            </distNSU>'                                                                                    + CRLF
                        cMsg += '        </distDFeInt>'                                                                                     + CRLF
                        cMsg += '    </ns1:cteDadosMsg>'                                                                                    + CRLF
                        cMsg += '    </ns1:cteDistDFeInteresse>'                                                                            + CRLF
                        cMsg += '    </soapenv:Body>'                                                                                       + CRLF
                        cMsg += '</soapenv:Envelope>'                                                                                       + CRLF

                        lRet := oWsdl:SendSoapMsg(cMsg)
                        If !lRet
                            If Substr(oWsdl:cError,1,33)=="Unknown element WSCorIDSOAPHeader"
                                lRet := .T.
                            Else
                                lErro := .T.
                                If (!lSChedule)
                                    Aviso("Aviso","[XMLINTEG] - Erro SendSoapMsg: " + oWsdl:cError,{"Ok"})
                                    cErr := oWsdl:GetSoapResponse()
                                    Alert(cErr)
                                else
                                    ConOut("[XMLINTEG] - Erro SendSoapMsg: " + oWsdl:cError)
                                Endif
                                lContinua := .F.
                            Endif
                        EndIf

                        Conout("["+cThread+"] - SOAP cteDistDFeInteresse Realizado  - NSU: " + cXmlNSU )

                        If lContinua

                            cMsgRet := oWsdl:GetSoapResponse()

                            oXmlDocZip := XmlParser(cMsgRet, "_", @cError, @cWarning)

                            If !Empty(cWarning)
                                lErro := .T.
                                If (!lSChedule)
                                    Aviso("Aviso", "cWarning: " + cWarning , {"Ok"} )
                                    aLog[Len(aLog)][7] := "cWarning ao fazer parser do arquivo enviado pela sefaz: "+cWarning
                                    aLog[Len(aLog)][8] := "N"
                                Else
                                    ConOut("[XMLINTEG] - cWarning: " + cWarning)
                                    aLog[Len(aLog)][7] := "cWarning ao fazer parser do arquivo enviado pela sefaz: "+cWarning
                                    aLog[Len(aLog)][8] := "N"
                                Endif
                            EndIf

                            If !Empty(cError)
                                lErro := .T.
                                If (!lSChedule)
                                    Aviso("Aviso", "Erro cError:" + cError , {"Ok"} )
                                    aLog[Len(aLog)][7] := "cError ao fazer parser do arquivo enviado pela sefaz: "+cError
                                    aLog[Len(aLog)][8] := "N"
                                Else
                                    ConOut("[XMLINTEG] - Erro cError: " + cError)
                                    aLog[Len(aLog)][7] := "cError ao fazer parser do arquivo enviado pela sefaz: "+cError
                                    aLog[Len(aLog)][8] := "N"
                                Endif
                                lContinua := .F.
                            EndIf

                            Conout("["+cThread+"] - Resposta Sefaz Obtida com sucesso  - " + Time() )

                            If (Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP") == "U")
                                lContinua := .F.
                            Endif
                        Endif
                    EndIf

                    If lContinua
                        For nI := 1 To Len(oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP)

                            lFirst := .F.

                            If (!lSChedule)
                                IncProc("Download do NSU: "+cXmlNSU+" até o NSU: "+cMaxCTE+".")
                            Endif

                            Conout("["+cThread+"] - Processando XML: "+Alltrim(Str(nI)) + " - " + Time() )

                            cChaveNFe := ""
                            cXmlGZip  := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP[nI]:TEXT
                            cXmlNSU   := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP[nI]:_NSU:TEXT

                            Aadd(aLog,{;
                                cFilAnt,;//Filial
                            cCTENSU,;//Nsu Inicial
                            cXmlNSU,;//Nsu Processado
                            cMaxCTE,;//Nsu Final
                            "",;//Chave da Nota
                            "",;//Xml Tipo
                            "",;//Observacao
                            "",;//B=BAIXADO E N=NAO BAIXADO
                            nI,;//Item do lote retornado
                            "DownCte" })

                            lContinua := fGrXmlCte(cXmlGZip, cXmlNSU , cHoraCon , cMaxCTE , cAmbiente , cUltNSU , cFolderBx )

                            nLidos++
                        Next
                    Endif
                Next
                //If Len(aDownCte)>0
                //    fBxChvCte(aDownCte)
                //Endif
            Else
                If (!lSChedule)
                    Procregua(LastRec())
                Endif

                If Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:TEXT")!="U"
                    cChaveNFe := ""
                    cXmlGZip  := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:TEXT
                    cXmlNSU   := iif(Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:_NSU:TEXT") != "U",oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:_NSU:TEXT,"0")

                    Aadd(aLog,{;
                        cFilAnt,;//Filial
                    cCTENSU,;//Nsu Inicial
                    cXmlNSU,;//Nsu Processado
                    cMaxCTE,;//Nsu Final
                    "",;//Chave da Nota
                    "",;//Xml Tipo
                    "",;//Observacao
                    "",;//B=BAIXADO E N=NAO BAIXADO
                    nI,;//Item do lote retornado
                    "DownCte" })

                    lContinua := fGrXmlCte(cXmlGZip, cXmlNSU , cHoraCon , cMaxCTE , cAmbiente , cUltNSU , cFolderBx )

                    nLidos++
                Endif
            Endif
        Else
            If (!lSChedule)
                Aviso("Aviso", "[IXMLINTEG] - sem arquivos para download de CTE com o NSU "+cCTENSU +"." , {"Ok"} )
            Else
                conout("[IXMLINTEG] - sem arquivo para download de CTE com o NSU "+cCTENSU)
            Endif
        Endif
    Endif

    if Val(cXmlNSU)<=Val(cMaxCTE) .And. Val(cXmlNSU)>=Val(cCTENSU) .And. !lErro
        PutMv("OV_NSUCTE", Soma1(cXmlNSU) )
    Endif

    Conout("["+cThread+"] - Atualizando NSU OV_NSUCTE " + Soma1(cXmlNSU) )

    if Len(aCadFor)>0
        Conout("["+cThread+"] - Enviando E-Mail de fornecedores cadastrados ")
        CadMailEnv()
    endif
    If Len(aLogFor)>0
        Conout("["+cThread+"] - Enviando E-Mail de LOG para fornecedores incompleto. ")
        fNotifCad()
    Endif

    If (!lSChedule)

        cTextFim := "Foram lidos " + Alltrim(Str(nLidos)) +" e "+Alltrim(Str(nArqXml))+" arquivos baixados." + chr(13)+chr(10)
        cTextFim += "NSU INICIAL : " + cCTENSU + chr(13) + chr(10)
        cTextFim += "NSU FINAL   : " + cMaxCTE + chr(13) + chr(10)
        cTextFim += "PROXIMO NSU : " + GetMv("OV_NSUCTE") +chr(13) + chr(10)

        alert(cTextFim)

    Else
        conout("[IXMLINTEG] - Foi realizado o download de "+Alltrim(Str(nArqXml))+" arquivos.")
    Endif

    If (lSChedule)
        Conout("[xmlinteg] Empresa: "+cEmp+" Filial: "+cFil +" - DownCTE FIM - Time: " + Time() )
    Endif

    RestArea(aArea)

Return cArqXML

/*/{Protheus.doc}'fGrXmlNfe'
'Download XML'
@author Sergio Celestino
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/
Static Function fGrXmlNfe(cConteudo, cXmlNSU , cHoraCon , cMaxNSU , cAmbiente , cUltNSU , cFolderBx )
    Local aArea         := getArea()
    Local lRet          := .T.
    Local nTamanho      := 0
    Local cUnXML        := ""
    Local cDecode64     := ""
    Local cError        := ""
    Local cWarning      := ""
    Local cURLSef       := Alltrim(SuperGetMv("MV_XMLXWS1",.F.,"https://www1.nfe.fazenda.gov.br/NFeDistribuicaoDFe/NFeDistribuicaoDFe.asmx?WSDL"))
    Local lContinua     := .T.
    Local oWsdlRe       := Nil
    Local lDownRes      := GetMv("OV_DOWNRES",,.T.)
    Local cUfAutor      := Alltrim(SuperGetMV("MV_XMLXUF",  .F., "35"))
    Local cTpAmb        := Alltrim(SuperGetMV("MV_XMLXAMB", .F., "1"))
    Local cAmbiente		:= ""
    Local cXml			:= ""
    Local cTpEvento		:= "210210"
    Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
    Local lUsaColab		:= UsaColaboracao("4")
    Local cIdEnt		:= RetIdEnti(lUsaColab)
    Local lRetOk		:= .T.
    Local aRet          := {}
    Local cCnpjRem      := ""
    Local cEmissao      := ""
    Local dEmissao      := ""
    Local cIERem        := ""
    Local cValor        := ""
    Local cNome         := ""
    Local nValor        := 0
    Local lResEvento    := .F.
    Local lCTE          := .F.
    Local nZ            := 1

    Private cDirBx      := ""
    Private cDir        := Alltrim(GetMv("MV_OVINN",,"\xml\inn\"))
    Private cDirRes     := Alltrim(GetMv("MV_OVRES",,"\xml\res\"))
    Private cDirLog     := Alltrim(GetMv("MV_OVLOG",,"\xml\log\"))
    Private cDirErr     := Alltrim(GetMv("MV_OVERR",,"\xml\err\"))
    Private cDirMan     := Alltrim(GetMv("MV_OVMAN",,"\xml\manifesto\"))

    If (lSChedule)
        Conout("[xmlinteg] Empresa: "+cEmp+" Filial: "+cFil +" - fGrXmlNfe - Time: " + Time() )
    Endif

    if Substr(cDir,Len(cDir),1)<>"\"
        cDir := cDir+"\"
    Endif

    if Substr(cDirRes,Len(cDirRes),1)<>"\"
        cDirRes := cDirRes+"\"
    Endif

    if Substr(cDirLog,Len(cDirLog),1)<>"\"
        cDirLog := cDirLog+"\"
    Endif

    if Substr(cDirErr,Len(cDirErr),1)<>"\"
        cDirErr := cDirErr+"\"
    Endif

    //Pega o tamanho e descriptografa o conteudo
    nTamanho  := Len(cConteudo)
    cDecode64 := Decode64(cConteudo)
    lRet      := GzStrDecomp(cDecode64, nTamanho, @cUnXML)

    If lRet
  
        cUnXML  := MemoRead(cFileCTE) 
        oXmlfim := XmlParser(cUnXML, "_", @cError, @cWarning)

        If !Empty(cWarning)
            If (!lSChedule)
                Aviso("Aviso", "cWarning: " + cWarning , {"Ok"} )
            Else
                ConOut("[IXMLINTEG] - Alert cWarning: " + cWarning)
            Endif
            lContinua := .F.
            aLog[Len(aLog)][7] := "cWarning ao fazer parser do arquivo enviado pela sefaz: "+cWarning
            aLog[Len(aLog)][8] := "N"
        EndIf

        If !Empty(cError)
            If (!lSChedule)
                Aviso("Aviso", "Erro cError:" + cError , {"Ok"} )
            Else
                ConOut("[IXMLINTEG] - Erro cError: " + cError)
            Endif
            lContinua := .F.
            aLog[Len(aLog)][7] := "cError ao fazer parser do arquivo enviado pela sefaz: "+cWarning
            aLog[Len(aLog)][8] := "N"
        EndIf

        If lContinua
            If XmlChildEx( oXmlfim , "_RESEVENTO" ) != Nil

                lResEvento:= .T.

                If (Type("oXmlfim:_RESEVENTO:_CHNFE:TEXT") != "U" )
                    cChaveNFE := oXmlfim:_RESEVENTO:_CHNFE:TEXT
                Endif

                If (Type("oXmlfim:_RESEVENTO:_CNPJ:TEXT") != "U"  )
                    cCnpjRem := oXmlfim:_RESEVENTO:_CNPJ:TEXT
                Endif
                If (Type("oXmlfim:_RESEVENTO:_DHRECBTO:TEXT") != "U"  )
                    cEmissao := Substr(oXmlfim:_RESEVENTO:_DHRECBTO:TEXT,1,10)
                    dEmissao := StoD(StrTran(cEmissao,"-",""))
                Endif

                aLog[Len(aLog)][5] := cChaveNFE
                aLog[Len(aLog)][6] := "_RESEVENTO"


            Elseif  XmlChildEx( oXmlfim , "_RESNFE" ) != Nil

                lResEvento:= .T.

                If (Type("oXmlfim:_RESNFE:_CHNFE:TEXT") != "U"  )
                    cChaveNFE := oXmlfim:_RESNFE:_CHNFE:TEXT
                Endif

                If (Type("oXmlfim:_RESNFE:_CNPJ:TEXT") != "U"  )
                    cCnpjRem := oXmlfim:_RESNFE:_CNPJ:TEXT
                Endif
                If (Type("oXmlfim:_RESNFE:_DHEMI:TEXT") != "U"  )
                    cEmissao := Substr(oXmlfim:_RESNFE:_DHEMI:TEXT,1,10)
                    dEmissao := StoD(StrTran(cEmissao,"-",""))
                Endif
                If (Type("oXmlfim:_RESNFE:_IE:TEXT") != "U"  )
                    cIERem := oXmlfim:_RESNFE:_IE:TEXT
                Endif
                If (Type("oXmlfim:_RESNFE:_VNF:TEXT") != "U"  )
                    cValor := oXmlfim:_RESNFE:_VNF:TEXT
                    nValor := Val(cValor)
                Endif
                If (Type("oXmlfim:_RESNFE:_XNOME:TEXT") != "U"  )
                    cNome := oXmlfim:_RESNFE:_XNOME:TEXT
                Endif

                aLog[Len(aLog)][5] := cChaveNFE
                aLog[Len(aLog)][6] := "_RESNFE"

            Elseif XmlChildEx( oXmlfim , "_NFEPROC" ) != Nil

                lResEvento := .F.
                lcontinua  := .F.

                cChaveNFE  :=	iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_ID:TEXT")!="U",ALLTRIM(SUBSTR(oXmlfim:_NFEPROC:_NFE:_INFNFE:_ID:TEXT,4,200)),"nokey")

                if !empty(cFolderBx)
                    cDirBx := cFolderBx
                Else
                    cDirBx := cDir
                Endif

                dbSelectArea("SDS")
                dbSetOrder(2)//DS_FILIAL+DS_CHAVENF
                If !dbSeek(xFilial("SDS") + Padr(cChaveNFE,TamSx3("DS_CHAVENF")[1] ) )
                    If !File(cDirBx+"nfe"+cChaveNFE+".xml")
                        nLenUnXML := Len( cUnXML )
                        nHandle := FCreate( cDirBx+"nfe"+cChaveNFE+".xml" , 0 , , .T. )
                        if nHandle = -1
                            aLog[Len(aLog)][5] := cChaveNFE
                            aLog[Len(aLog)][6] := "_NFEPROC"
                            aLog[Len(aLog)][7] := "Erro ao tentar gravar xml NFE na pasta|"
                            aLog[Len(aLog)][8] := "N"
                            If (!lSChedule)
                                Aviso("Aviso","Erro ao criar arquivo "+cDirBx+"nfe"+cChaveNFE+".xml"+ " - fError " + Str(Ferror()))
                            Else
                                conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
                            Endif
                        else
                            FWrite( nHandle, cUnXML, nLenUnXML )
                            FClose( nHandle )
                            aLog[Len(aLog)][5] := cChaveNFE
                            aLog[Len(aLog)][6] := "_NFEPROC"
                            aLog[Len(aLog)][7] := "Arquivo XML NFE baixado com sucesso na pasta "+cDirBx
                            aLog[Len(aLog)][8] := "B"

                            dbSelectArea("C00")
                            dbSetOrder(1) //FILIAL + CHAVE
                            If dbSeek( xFilial("C00") + Padr(cChaveNFE,TamSX3("C00_CHVNFE")[1]) )
                                Reclock("C00",.F.)
                                C00->C00_XDOWN := 'S'
                                C00->C00_XNSU  := cXmlNSU
                                MsUnlock()
                            Endif
                            nArqXml++
                            if cDirBx<>cDir
                                CpyT2S( cDirBx+"nfe"+cChaveNFE+".xml" , cDir , .F. )
                            endif
                        Endif
                    Else
                        aLog[Len(aLog)][5] := cChaveNFE
                        aLog[Len(aLog)][6] := "_NFEPROC"
                        aLog[Len(aLog)][7] := "XML NFE encontrado na pasta "+cDirBx+"|"
                        aLog[Len(aLog)][8] := "N"
                    Endif

                    fTrataFor(.F.)
                Else
                    aLog[Len(aLog)][5] := cChaveNFE
                    aLog[Len(aLog)][6] := "_NFEPROC"
                    aLog[Len(aLog)][7] := "Chave NFE encontrada na tabela SDS|"
                    aLog[Len(aLog)][8] := "N"
                Endif

            ElseIf XmlChildEx( oXmlfim , "_CTEPROC" ) != Nil

                lResEvento := .F.
                lContinua  := .F.

                cChaveNFE:= iif(Type("oXmlfim:_cteproc:_cte:_infcte:_id:text")  != "U",alltrim(SUBSTR(oXmlfim:_cteproc:_cte:_infcte:_id:text,4,200)),"")

                //Descobrir quem é o Tomador
                cTomador :=  iif(Type("oXmlfim:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA3:_TOMA:TEXT")  != "U",oXmlfim:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA3:_TOMA:TEXT,"")
                cCnpjCTE := ""
                If Empty(cTomador)
                    cTomador :=  iif(Type("oXmlfim:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_TOMA:TEXT")  != "U",oXmlfim:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_TOMA:TEXT,"")
                    If cTomador=="4"
                        cCnpjCTE := iif(Type("oxmlFim:_CTEProc:_Cte:_InfCte:_Ide:_toma4:_Cnpj:Text")  != "U",oxmlFim:_CTEProc:_Cte:_InfCte:_Ide:_toma4:_Cnpj:Text,"")
                    Endif
                Else
                
                    Do Case
                        Case cTomador == "0"//0-Remetente
                            cCnpjCTE := iif(Type("oXmlfim:_CTEPROC:_CTE:_INFCTE:_REM:_CNPJ:TEXT")  != "U",oXmlfim:_CTEPROC:_CTE:_INFCTE:_REM:_CNPJ:TEXT,"")
                        Case cTomador == "1"//1-Expedidor
                        Case cTomador == "2"//2-Recebedor
                            cCnpjCTE := iif(Type("oXmlfim:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT")  != "U",oXmlfim:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT,"")
                        Case cTomador == "3"//3-Destinatário
                            cCnpjCTE := iif(Type("oXmlfim:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT")  != "U",oXmlfim:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT,"")
                    EndCase

                Endif

                if !empty(cFolderBx)
                    cDirBx := cFolderBx
                Else
                    cDirBx := cDir
                Endif

                dbSelectArea("SDS")
                dbSetOrder(2)//DS_FILIAL+DS_CHAVENF
                If !dbSeek(xFilial("SDS") + Padr(cChaveNFE,TamSx3("DS_CHAVENF")[1] ) )
                    If !File(cDirBx+"cte"+cChaveNFE+".xml")
                        If cCnpjCTE==SM0->M0_CGC
                            nLenUnXML := Len( cUnXML )
                            nHandle := FCreate( cDirBx+"cte"+cChaveNFE+".xml" , 0 , , .T. )
                            if nHandle = -1
                                aLog[Len(aLog)][5] := cChaveNFE
                                aLog[Len(aLog)][6] := "_CTEPROC"
                                aLog[Len(aLog)][7] := "Erro ao tentar gravar xml CTE na pasta|"
                                aLog[Len(aLog)][8] := "N"
                                If (!lSChedule)
                                    Aviso("Aviso","Erro ao criar arquivo "+cDirBx+"cte"+cChaveNFE+".xml"+ " - fError " + Str(Ferror()))
                                Else
                                    conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
                                Endif
                            else
                                FWrite( nHandle, cUnXML, nLenUnXML )
                                FClose( nHandle )

                                aLog[Len(aLog)][5] := cChaveNFE
                                aLog[Len(aLog)][6] := "_CTEPROC"
                                aLog[Len(aLog)][7] := "Arquivo XML CTE baixado com sucesso na pasta "+cDirBx
                                aLog[Len(aLog)][8] := "B"

                                dbSelectArea("C00")
                                dbSetOrder(1) //FILIAL + CHAVE
                                If dbSeek( xFilial("C00") + Padr(cChaveNFE,TamSX3("C00_CHVNFE")[1]) )
                                    Reclock("C00",.F.)
                                    C00->C00_XDOWN := 'S'
                                    C00->C00_XNSU  := cXmlNSU
                                    MsUnlock()
                                Endif

                                nArqXml++
                                if cDirBx<>cDir
                                    CpyT2S( cDirBx+"cte"+cChaveNFE+".xml" , cDir , .F. )
                                endif
                            Endif

                            fTrataFor(.T.)
                        Else
                            aLog[Len(aLog)][5] := cChaveNFE
                            aLog[Len(aLog)][6] := "_CTEPROC"
                            aLog[Len(aLog)][7] := "CNPJ Remetente CTE difere da empresa logada|"
                            aLog[Len(aLog)][8] := "N"
                        Endif
                    Else
                        aLog[Len(aLog)][5] := cChaveNFE
                        aLog[Len(aLog)][6] := "_CTEPROC"
                        aLog[Len(aLog)][7] := "XML CTE encontrado na pasta "+cDirBx+"|"
                        aLog[Len(aLog)][8] := "N"
                    Endif
                Else
                    aLog[Len(aLog)][5] := cChaveNFE
                    aLog[Len(aLog)][6] := "_CTEPROC"
                    aLog[Len(aLog)][7] := "Chave CTE encontrada na tabela SDS|"
                    aLog[Len(aLog)][8] := "N"
                Endif

            Elseif XmlChildEx( oXmlfim , "_PROCEVENTONFE" ) != Nil

                If (Type("oXmlfim:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_DESCEVENTO:TEXT") != "U"  )
                    cEvento := oXmlfim:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_DESCEVENTO:TEXT
                Endif

                if cEvento == "Carta de Correcao"
                    Conout("["+cThread+"] - XML de carta de correcao nao sera baixado - " + Time() )
                endif

                If (!lSChedule)
                    LjWriteLog(cDirErr+cXmlNSU+".log", "PROCEVENTONFE: "+cUnXML )
                Else
                    LjWriteLog(cDirErr+cXmlNSU+".log", "PROCEVENTONFE: "+cUnXML )
                Endif
                lContinua := .F.
                lResEvento:= .F.

                aLog[Len(aLog)][5] := cChaveNFE
                aLog[Len(aLog)][6] := "_PROCEVENTONFE"
                aLog[Len(aLog)][7] := "Evento de NFE : "+cEvento+" ,verifique xml na pasta "+cDirErr
                aLog[Len(aLog)][8] := "N"

            Elseif XmlChildEx( oXmlfim , "PROCNFE" ) != Nil

                If (!lSChedule)
                    LjWriteLog(cDirErr+cXmlNSU+".log","PROCNFE: "+ cUnXML )
                Else
                    LjWriteLog(cDirErr+cXmlNSU+".log","PROCNFE: "+ cUnXML )
                Endif
                lContinua := .F.
                lResEvento:= .f.

                aLog[Len(aLog)][5] := cChaveNFE
                aLog[Len(aLog)][6] := "PROCNFE"
                aLog[Len(aLog)][7] := "Evento de NFE : "+cEvento+" ,verifique xml na pasta "+cDirErr
                aLog[Len(aLog)][8] := "N"
            Else
                If (!lSChedule)
                    LjWriteLog(cDirErr+cXmlNSU+".log","SEMEVENTO: "+ cUnXML )
                Else
                    LjWriteLog(cDirErr+cXmlNSU+".log","SEMEVENTO: "+ cUnXML )
                Endif
                lContinua := .F.
                lResEvento:= .f.

                aLog[Len(aLog)][5] := cChaveNFE
                aLog[Len(aLog)][6] := "SEMEVENTO"
                aLog[Len(aLog)][7] := "SEMEVENTO,verifique xml na pasta "+cDirErr
                aLog[Len(aLog)][8] := "N"
            Endif
        Endif


        If lContinua .And. lResEvento

            dbSelectArea("SDS")
            dbSetOrder(2)//DS_FILIAL+DS_CHAVENF
            If dbSeek(xFilial("SDS") + Padr(cChaveNFE,TamSx3("DS_CHAVENF")[1] ) )
                lContinua := .F.

                aLog[Len(aLog)][5] := cChaveNFE
                aLog[Len(aLog)][7] := aLog[Len(aLog)][7] + "Existente SDS|"
                aLog[Len(aLog)][8] := "N"
            Else
                lContinua := .T.
            Endif

            If lContinua
                If lDownRes
                    if !empty(cFolderBx)
                        cDirBx := cFolderBx
                    Else
                        cDirBx := cDirRes
                    Endif
                    dbSelectArea("SDS")
                    dbSetOrder(2)//DS_FILIAL+DS_CHAVENF
                    If !dbSeek(xFilial("SDS") + Padr(cChaveNFE,TamSx3("DS_CHAVENF")[1] ) )
                        If !File(cDirBx+"res"+cChaveNFE+".xml")
                            nLenUnXML := Len( cUnXML )
                            nHandle := FCreate( cDirBx+"res"+cChaveNFE+".xml" , 0 , , .T. )
                            if nHandle = -1
                                If (!lSChedule)
                                    Aviso("Aviso","Erro ao criar arquivo "+cDirBx+"res"+cChaveNFE+".xml"+ " - fError " + Str(Ferror()))
                                Else
                                    conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
                                Endif
                            else
                                FWrite( nHandle, cUnXML, nLenUnXML )
                                FClose( nHandle )
                                nArqXml++
                                if cDirBx<>cDirRes
                                    CpyT2S( cDirBx+"res"+cChaveNFE+".xml" , cDir , .F. )
                                endif
                            endif
                        Endif
                    Endif
                Endif

                Conout("["+cThread+"] - XML de Resumo consultado com sucesso - " + Time() )

                dData := CtoD("01/"+Substr(cChaveNFE,5,2)+"/"+Substr(cChaveNFE,3,2))

                dbSelectArea("C00")
                dbSetOrder(1) //FILIAL + CHAVE
                If !dbSeek( xFilial("C00") + Padr(cChaveNFE,TamSX3("C00_CHVNFE")[1]) )
                    RecLock("C00",.T.)
                    C00->C00_FILIAL     := xFilial("C00")
                    C00->C00_STATUS     := "0"
                    C00->C00_CHVNFE		:= cChaveNFE
                    C00->C00_ANONFE		:= Strzero(Year(dData),4)
                    C00->C00_MESNFE		:= Strzero(Month(dData),2)
                    C00->C00_SERNFE		:= Substr(cChaveNFE,23,3)
                    C00->C00_NUMNFE		:= Substr(cChaveNFE,26,9)
                    C00->C00_CODEVE		:= "1"
                    C00->C00_VLDOC      := nValor
                    C00->C00_CNPJEM     := cCnpjRem
                    C00->C00_NOEMIT     := cNome
                    C00->C00_IEEMIT     := cIERem
                    C00->C00_DTEMI      := iif(Valtype(dEmissao)<>"D",ddatabase,dEmissao)
                    C00->C00_DTREC      := iif(Valtype(dEmissao)<>"D",ddatabase,dEmissao)
                    C00->C00_CODRET     := "138"
                    C00->C00_SITDOC     := "1"
                    C00->C00_DESRES     := "Documento(s) localizado(s)"
                    C00->C00_XNSU       := cXmlNSU
                    C00->( MsUnLock() )

                    Conout("["+cThread+"] - Manifesto do Destinatario gravado com sucesso - " + Time() )

                    aLog[Len(aLog)][5] := cChaveNFE
                    aLog[Len(aLog)][7] := aLog[Len(aLog)][7] + "Gravado C00|"


                    lRetOk     := .F.
                    cChavesMsg := ""
                    aRet       := {}
                    cXml       := ""

                    oWs :=WSMANIFESTACAODESTINATARIO():New()
                    oWs:cUserToken   := "TOTVS"
                    oWs:cIDENT	     := cIdEnt
                    oWs:cAMBIENTE	 := ""
                    oWs:cVERSAO      := ""
                    oWs:_URL         := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw"

                    If oWs:CONFIGURARPARAMETROS()
                        cAmbiente		 := oWs:OWSCONFIGURARPARAMETROSRESULT:CAMBIENTE

                        cXml+='<envEvento>'
                        cXml+='<eventos>'
                        cXml+='<detEvento>'
                        cXml+='<tpEvento>'+cTpEvento+'</tpEvento>'
                        cXml+='<chNFe>'+Alltrim(cChaveNFE)+'</chNFe>'
                        cXml+='<ambiente>'+cAmbiente+'</ambiente>'
                        cXml+='</detEvento>'
                        cXml+='</eventos>'
                        cXml+='</envEvento>'

                        lRetOk:=EnvioManif(cXml,cIdEnt,cUrl,@aRet)

                        If lRetOk .And. Len(aRet) > 0
                            For nZ:=1 to Len(aRet)
                                aRet[nZ]:= Substr(aRet[nZ],9,44)
                                cChavesMsg += aRet[nZ] + Chr(10) + Chr(13)
                            Next
                            cMsgManif := "Transmissão da Manifestação concluída com sucesso!" + Chr(10) + Chr(13)
                            cMsgManif += cTpEvento + Chr(10) + Chr(13)
                            cMsgManif += "Chave(s): "+ Chr(10) + Chr(13)
                            cMsgManif += cChavesMsg
                            cRetorno  := Alltrim(cMsgManif)

                            LjWriteLog(cDirMan+cChaveNFE+".log", cRetorno )

                            AtuStatus(aRet,cTpEvento)

                            aAdd(aDownNfe,{"nfe",cChaveNFE,aLog[Len(aLog)][3]})

                            aLog[Len(aLog)][5] := cChaveNFE
                            aLog[Len(aLog)][7] := aLog[Len(aLog)][7] + "Manifesto Transmitido|"

                            Conout("["+cThread+"] - Ciencia da Operacao Enviada com sucesso - " + Time() )

                        EndIf
                    Endif
                Else
                    lRetOk := .F.
                    aLog[Len(aLog)][5] := cChaveNFE
                    aLog[Len(aLog)][7] := aLog[Len(aLog)][7] + "ja Encontrado na C00|"
                Endif
            Endif
        Endif
    Else
        aLog[Len(aLog)][7] := "Erro ao descompactar arquivo enviado pela sefaz"

        If (!lSChedule)
            Aviso("Aviso" , "[XMLINTEG][fGrXmlNfe] - Houve algum erro na descompactando o arquivo!",{"Ok"})
        Else
            ConOut("[XMLINTEG][fGrXmlNfe] - Houve algum erro na descompactando o arquivo!")
        Endif
    EndIf

    If (lSChedule)
        Conout("[xmlinteg] Empresa: "+cEmp+" Filial: "+cFil +" - fGrXmlNfe FIM - Time: " + Time() )
    Endif

    RestArea(aArea)

Return lContinua
    
    /*/{Protheus.doc}'fGrXmlCte'
    'Download XML'
    @author Sergio Celestino
    @since ''
    @version ''
    @type function
    @see ''
    @obs ''
    @param ''
    @return ''
/*/
Static Function fGrXmlCte(cConteudo, cXmlNSU , cHoraCon , cMaxNSU , cAmbiente , cUltNSU , cFolderBx )
    Local aArea         := getArea()
    Local lRet          := .T.
    Local nTamanho      := 0
    Local cUnXML        := ""
    Local cDecode64     := ""
    Local cError        := ""
    Local cWarning      := ""
    Local cURLSefRS     := Alltrim(SuperGetMv("MV_CTXEVE1",.F.,"https://cte.svrs.rs.gov.br/ws/cteconsulta/CteConsulta.asmx?WSDL"))
    Local cURLSefSP     := Alltrim(SuperGetMv("MV_CTXEVE2",.F.,"https://nfe.fazenda.sp.gov.br/cteWEB/services/CteConsulta.asmx?WSDL"))
    Local lContinua     := .F.
    Local oWsdlRe       := Nil
    Local lDownRes      := GetMv("OV_DOWNRES",,.T.)
    Local cUfAutor      := Alltrim(SuperGetMV("MV_XMLXUF",  .F., "35"))
    Local cTpAmb        := Alltrim(SuperGetMV("MV_XMLXAMB", .F., "1"))
    Local cAmbiente		:= ""
    Local cXml			:= ""
    Local cTpEvento		:= "210210"
    Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
    Local lUsaColab		:= UsaColaboracao("4")
    Local cIdEnt		:= RetIdEnti(lUsaColab)
    Local lRetOk		:= .F.
    Local aRet          := {}
    Local cCnpjRem      := ""
    Local cEmissao      := ""
    Local dEmissao      := ""
    Local cIERem        := ""
    Local cValor        := ""
    Local cNome         := ""
    Local nValor        := 0
    Local lResEvento    := .F.
    Local lCTE          := .F.
    Local aDownCte      := {}
    Local cVersaoCte    := Alltrim(GetMv("OV_VERCTE",,"3.00"))
    Local nZ:=1

    Private cDirBx      := ""
    Private cDir        := Alltrim(GetMv("MV_OVINN",,"\xml\inn\"))
    Private cDirRes     := Alltrim(GetMv("MV_OVRES",,"\xml\res\"))
    Private cDirLog     := Alltrim(GetMv("MV_OVLOG",,"\xml\log\"))
    Private cDirErr     := Alltrim(GetMv("MV_OVERR",,"\xml\err\"))
    Private cDirMan     := Alltrim(GetMv("MV_OVMAN",,"\xml\manifesto\"))

    If (lSChedule)
        Conout("[xmlinteg] Empresa: "+cEmp+" Filial: "+cFil +" - fGrXmlCte - Time: " + Time() )
    Endif

    if Substr(cDir,Len(cDir),1)<>"\"
        cDir := cDir+"\"
    Endif

    if Substr(cDirRes,Len(cDirRes),1)<>"\"
        cDirRes := cDirRes+"\"
    Endif

    if Substr(cDirLog,Len(cDirLog),1)<>"\"
        cDirLog := cDirLog+"\"
    Endif

    if Substr(cDirErr,Len(cDirErr),1)<>"\"
        cDirErr := cDirErr+"\"
    Endif

    //Pega o tamanho e descriptografa o conteudo
    nTamanho  := Len(cConteudo)
    cDecode64 := Decode64(cConteudo)
    lRet      := GzStrDecomp(cDecode64, nTamanho, @cUnXML)

    If lRet

        oXmlfim := XmlParser(cUnXML, "_", @cError, @cWarning)

        If !Empty(cWarning)
            If (!lSChedule)
                Aviso("Aviso", "cWarning: " + cWarning , {"Ok"} )
            Else
                ConOut("[IXMLINTEG] - Alert cWarning: " + cWarning)
            Endif
            lContinua := .F.
            aLog[Len(aLog)][7] := "cWarning CTE arquivo não sera processado."
            aLog[Len(aLog)][8] := "N"
        EndIf

        If ! Empty(cError)
            If (!lSChedule)
                Aviso("Aviso", "Erro cError:" + cError , {"Ok"} )
            Else
                ConOut("[IXMLINTEG] - Erro cError: " + cError)
            Endif
            lContinua := .F.
            aLog[Len(aLog)][7] := "cError CTE arquivo não sera processado."
            aLog[Len(aLog)][8] := "N"
        EndIf

        If XmlChildEx( oXmlfim , "_CTEPROC" ) != Nil

            cChaveNFE:= iif(Type("oXmlfim:_cteproc:_cte:_infcte:_id:text")  != "U",alltrim(SUBSTR(oXmlfim:_cteproc:_cte:_infcte:_id:text,4,200)),"")

            //Descobrir quem é o Tomador
            cTomador :=  iif(Type("oXmlfim:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA3:_TOMA:TEXT")  != "U",oXmlfim:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA3:_TOMA:TEXT,"")
            cCnpjCTE := ""
            If Empty(cTomador)
                cTomador :=  iif(Type("oXmlfim:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_TOMA:TEXT")  != "U",oXmlfim:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_TOMA:TEXT,"")
                If cTomador=="4"
                    cCnpjCTE := iif(Type("oxmlFim:_CTEProc:_Cte:_InfCte:_Ide:_toma4:_Cnpj:Text")  != "U",oxmlFim:_CTEProc:_Cte:_InfCte:_Ide:_toma4:_Cnpj:Text,"")
                Endif
            Else
                Do Case
                    Case cTomador == "0"//0-Remetente
                        cCnpjCTE := iif(Type("oXmlfim:_CTEPROC:_CTE:_INFCTE:_REM:_CNPJ:TEXT")  != "U",oXmlfim:_CTEPROC:_CTE:_INFCTE:_REM:_CNPJ:TEXT,"")
                    Case cTomador == "1"//1-Expedidor
                    Case cTomador == "2"//2-Recebedor
                        cCnpjCTE := iif(Type("oXmlfim:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT")  != "U",oXmlfim:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT,"")
                    Case cTomador == "3"//3-Destinatário
                        cCnpjCTE := iif(Type("oXmlfim:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT")  != "U",oXmlfim:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT,"")
                EndCase
            Endif
            
            if !empty(cFolderBx)
                cDirBx := cFolderBx
            Else
                cDirBx := cDir
            Endif

            dbSelectArea("SDS")
            dbSetOrder(2)//DS_FILIAL+DS_CHAVENF
            If !dbSeek(xFilial("SDS") + Padr(Alltrim(cChaveNFE),TamSx3("DS_CHAVENF")[1] ) )
                If !File(cDirBx+"cte"+cChaveNFE+".xml")

                    If cCnpjCTE==SM0->M0_CGC

                        lContinua := .F.
                        lResEvento:= .F.

                        nLenUnXML := Len( cUnXML )
                        nHandle := FCreate( cDirBx+"cte"+cChaveNFE+".xml" , 0 , , .T. )
                        if nHandle = -1

                            aLog[Len(aLog)][5] := cChaveNFE
                            aLog[Len(aLog)][6] := "_CTEPROC"
                            aLog[Len(aLog)][7] := "Erro ao criar Xml CTE na pasta"+cDirBx+"|"
                            aLog[Len(aLog)][8] := "N"

                            If (!lSChedule)
                                Aviso("Aviso","Erro ao criar arquivo "+cDirBx+"cte"+cChaveNFE+".xml"+ " - fError " + Str(Ferror()))
                            Else
                                conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
                            Endif
                        else

                            FWrite( nHandle, cUnXML, nLenUnXML )
                            FClose( nHandle )

                            aLog[Len(aLog)][5] := cChaveNFE
                            aLog[Len(aLog)][6] := "_CTEPROC"
                            aLog[Len(aLog)][7] := "Xml CTE baixaado com sucesso na pasta"+cDirBx+"|"
                            aLog[Len(aLog)][8] := "B"

                            nArqXml++
                            if cDirBx<>cDir
                                CpyT2S( cDirBx+"cte"+cChaveNFE+".xml" , cDir , .F. )
                            endif
                        Endif

                        fTrataFor(.T.)
                    Else
                        aLog[Len(aLog)][5] := cChaveNFE
                        aLog[Len(aLog)][6] := "_CTEPROC"
                        aLog[Len(aLog)][7] := "CNPJ do Remetente do CTE difere da empresa logada|"
                        aLog[Len(aLog)][8] := "N"
                    Endif
                Else
                    aLog[Len(aLog)][5] := cChaveNFE
                    aLog[Len(aLog)][6] := "_CTEPROC"
                    aLog[Len(aLog)][7] := "Xml CTE localizado na pasta "+cDirBx+" não sera baixado|"
                    aLog[Len(aLog)][8] := "N"
                Endif
            Else
                aLog[Len(aLog)][5] := cChaveNFE
                aLog[Len(aLog)][6] := "_CTEPROC"
                aLog[Len(aLog)][7] := "Xml CTE localizado na tablea SDS|"
                aLog[Len(aLog)][8] := "N"
            Endif

        Elseif XmlChildEx( oXmlfim , "_PROCEVENTOCTE" ) != Nil

            lcontinua := .T.
            lResEvento:= .T.

            cChaveNFE:= iif(Type("oXmlfim:_proceventocte:_eventocte:_infevento:_chcte:text")  != "U",alltrim(oXmlfim:_proceventocte:_eventocte:_infevento:_chcte:text),"")
            cNome    := iif(Type("oXmlfim:_proceventocte:_eventocte:_infevento:_detevento:_evcteautorizadomdfe:_emit:_xnome:text") != "U",oXmlfim:_proceventocte:_eventocte:_infevento:_detevento:_evcteautorizadomdfe:_emit:_xnome:text,"")

            If (Type("oXmlfim:_proceventocte:_eventocte:_infevento:_detevento:_evcteautorizadomdfe:_emit:_cnpj:text") != "U"  )
                cCnpjRem := oXmlfim:_proceventocte:_eventocte:_infevento:_detevento:_evcteautorizadomdfe:_emit:_cnpj:text
            Endif

            If (Type("oXmlfim:_proceventocte:_eventocte:_infevento:_detevento:_evcteautorizadomdfe:_mdfe:_dhemi:text") != "U"  )
                cEmissao := Substr(oXmlfim:_proceventocte:_eventocte:_infevento:_detevento:_evcteautorizadomdfe:_mdfe:_dhemi:text,1,10)
                dEmissao := StoD(StrTran(StrTran(cEmissao,"-",""),"/",""))
            Endif

            aLog[Len(aLog)][5] := cChaveNFE
            aLog[Len(aLog)][6] := "_PROCEVENTOCTE"
            aLog[Len(aLog)][7] := "Xml CTE de Evento |"
            aLog[Len(aLog)][8] := "N"

        Else
            If (!lSChedule)
                LjWriteLog(cDirErr+cXmlNSU+".log","SEMEVENTO: "+ cUnXML )
            Else
                LjWriteLog(cDirErr+cXmlNSU+".log","SEMEVENTO: "+ cUnXML )
            Endif
            lContinua := .F.
            aLog[Len(aLog)][5] := cChaveNFE
            aLog[Len(aLog)][6] := "SEMEVENTO"
            aLog[Len(aLog)][7] := "Xml CTE SEMEVENTO |"
            aLog[Len(aLog)][8] := "N"
        Endif

        dbSelectArea("SDS")
        dbSetOrder(2)//DS_FILIAL+DS_CHAVENF
        If dbSeek(xFilial("SDS") + Padr(cChaveNFE,TamSx3("DS_CHAVENF")[1] ) )
            lContinua := .F.
            aLog[Len(aLog)][5] := cChaveNFE
            aLog[Len(aLog)][7] := aLog[Len(aLog)][7] + "Xml CTE localizado na tabela SDS |"
            aLog[Len(aLog)][8] := "N"
        Endif

        If lContinua .And. lResEvento
            If lDownRes
                if !empty(cFolderBx)
                    cDirBx := cFolderBx
                Else
                    cDirBx := cDirRes
                Endif
                dbSelectArea("SDS")
                dbSetOrder(2)//DS_FILIAL+DS_CHAVENF
                If !dbSeek(xFilial("SDS") + Padr(cChaveNFE,TamSx3("DS_CHAVENF")[1] ) )
                    If !File(cDirBx+"RES"+cChaveNFE+".xml")
                        nLenUnXML := Len( cUnXML )
                        nHandle := FCreate( cDirBx+"RES"+cChaveNFE+".xml" , 0 , , .T. )
                        if nHandle = -1
                            If (!lSChedule)
                                Aviso("Aviso","Erro ao criar arquivo "+cDirBx+"RES"+cChaveNFE+".xml"+ " - fError " + Str(Ferror()))
                            Else
                                conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
                            Endif
                        else
                            FWrite( nHandle, cUnXML, nLenUnXML )
                            FClose( nHandle )
                            nArqXml++
                            if cDirBx<>cDirRes
                                CpyT2S( cDirBx+"RES"+cChaveNFE+".xml" , cDir , .F. )
                            endif
                        endif
                    Endif
                Endif
            Endif

            Conout("["+cThread+"] - XML de Resumo consultado com sucesso - " + Time() )

            dData := CtoD("01/"+Substr(cChaveNFE,5,2)+"/"+Substr(cChaveNFE,3,2))

            dbSelectArea("C00")
            dbSetOrder(1) //FILIAL + CHAVE
            If !dbSeek( xFilial("C00") + Padr(cChaveNFE,TamSX3("C00_CHVNFE")[1]) )
                RecLock("C00",.T.)
                C00->C00_FILIAL     := xFilial("C00")
                C00->C00_STATUS     := "0"
                C00->C00_CHVNFE		:= cChaveNFE
                C00->C00_ANONFE		:= Strzero(Year(dData),4)
                C00->C00_MESNFE		:= Strzero(Month(dData),2)
                C00->C00_SERNFE		:= Substr(cChaveNFE,23,3)
                C00->C00_NUMNFE		:= Substr(cChaveNFE,26,9)
                C00->C00_CODEVE		:= "1"
                C00->C00_VLDOC      := nValor
                C00->C00_CNPJEM     := cCnpjRem
                C00->C00_NOEMIT     := cNome
                C00->C00_IEEMIT     := cIERem
                C00->C00_DTEMI      := iif(Valtype(dEmissao)<>"D",ddatabase,dEmissao)
                C00->C00_DTREC      := iif(Valtype(dEmissao)<>"D",ddatabase,dEmissao)
                C00->C00_CODRET     := "138"
                C00->C00_SITDOC     := "1"
                C00->C00_DESRES     := "Documento(s) localizado(s)"
                C00->C00_XNSU       := cXmlNSU
                C00->( MsUnLock() )

                Conout("["+cThread+"] - Manifesto do Destinatario gravado com sucesso - " + Time() )

                lRetOk     := .F.
                cChavesMsg := ""
                aRet       := {}
                cXml       := ""

                aLog[Len(aLog)][5] := cChaveNFE
                aLog[Len(aLog)][7] := aLog[Len(aLog)][7] + "Xml CTE gravado na tabela C00|"

                oWs :=WSMANIFESTACAODESTINATARIO():New()
                oWs:cUserToken   := "TOTVS"
                oWs:cIDENT	     := cIdEnt
                oWs:cAMBIENTE	 := ""
                oWs:cVERSAO      := ""
                oWs:_URL         := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw"

                If oWs:CONFIGURARPARAMETROS()
                    cAmbiente		 := oWs:OWSCONFIGURARPARAMETROSRESULT:CAMBIENTE

                    cXml+='<envEvento>'
                    cXml+='<eventos>'
                    cXml+='<detEvento>'
                    cXml+='<tpEvento>'+cTpEvento+'</tpEvento>'
                    cXml+='<chNFe>'+Alltrim(cChaveNFE)+'</chNFe>'
                    cXml+='<ambiente>'+cAmbiente+'</ambiente>'
                    cXml+='</detEvento>'
                    cXml+='</eventos>'
                    cXml+='</envEvento>'

                    lRetOk:=EnvioManif(cXml,cIdEnt,cUrl,@aRet)

                    If lRetOk .And. Len(aRet) > 0

                        For nZ:=1 to Len(aRet)
                            aRet[nZ]:= Substr(aRet[nZ],9,44)
                            cChavesMsg += aRet[nZ] + Chr(10) + Chr(13)
                        Next
                        cMsgManif := "Transmissão da Manifestação concluída com sucesso!" + Chr(10) + Chr(13)
                        cMsgManif += cTpEvento + Chr(10) + Chr(13)
                        cMsgManif += "Chave(s): "+ Chr(10) + Chr(13)
                        cMsgManif += cChavesMsg
                        cRetorno  := Alltrim(cMsgManif)

                        LjWriteLog(cDirMan+cChaveNFE+".log", cRetorno )

                        AtuStatus(aRet,cTpEvento)

                        aAdd(aDownCte,{"cte",cChaveNFE,aLog[Len(aLog)][3]})

                        aLog[Len(aLog)][5] := cChaveNFE
                        aLog[Len(aLog)][7] := aLog[Len(aLog)][7] + "Xml CTE Manifestação transmitida|"

                        Conout("["+cThread+"] - Ciencia da Operacao Enviada com sucesso - " + Time() )

                    EndIf
                Endif
            Else
                lRetOk := .F.
                aLog[Len(aLog)][5] := cChaveNFE
                aLog[Len(aLog)][7] := aLog[Len(aLog)][7] + "Xml CTE ja gravado na C00, não foi manifestado|"
            Endif
        Endif
    Else
        aLog[Len(aLog)][7] := "Erro na descompactação do arquivo CTE"
        aLog[Len(aLog)][8] := "N"
        If (!lSChedule)
            Aviso("Aviso" , "[XMLINTEG][fGrXmlNfe] - Houve algum erro na descompactando o arquivo!",{"Ok"})
        Else
            ConOut("[XMLINTEG][fGrXmlNfe] - Houve algum erro na descompactando o arquivo!")
        Endif
    EndIf

    If (lSChedule)
        Conout("[xmlinteg] Empresa: "+cEmp+" Filial: "+cFil +" - fGrXmlCte FIM - Time: " + Time() )
    Endif

    RestArea(aArea)

Return lContinua

/*/{Protheus.doc}'
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
Static Function EnvioManif(cXmlReceb,cIdEnt,cUrl,aRetorno,cModel)

    Local lRetOk		:= .T.

    Default cURL		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
    Default cIdEnt		:= RetIdEnti(lUsaColab)
    Default aRetorno	:= {}
    Default cModel		:= ""

    If (lSChedule)
        Conout("[xmlinteg] Empresa: "+cEmp+" Filial: "+cFil +" - EnvioManif - Time: " + Time() )
    Endif

    If ReadyTSS()
        oWs:= WsNFeSBra():New()
        oWs:cUserToken	:= "TOTVS"
        oWs:cID_ENT		:= cIdEnt
        oWs:cXML_LOTE	:= cXmlReceb
        oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
        If !Empty(cModel)
            oWS:cModelo := cModel
        EndIf

        If oWs:RemessaEvento()
            If Type("oWS:oWsRemessaEventoResult:cString") <> "U"
                If Type("oWS:oWsRemessaEventoResult:cString") <> "A"
                    aRetorno:={oWS:oWsRemessaEventoResult:cString}
                Else
                    aRetorno:=oWS:oWsRemessaEventoResult:cString
                EndIf
            EndIf
        Else
            lRetOk := .F.
            If (!lSChedule)
                Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
            Else
                ConOut("[XMLINTEG][fGrXmlNfe] - "+IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)))
            Endif
        Endif
    Else
        If (!lSChedule)
            Aviso("SPED","Execute o modulo de configuraÃ§Ã£o do serviÃ§o, antes de utilizar esta opÃ§Ã£o!!!",{"Ok"},3)
        Else
            ConOut("[XMLINTEG][fGrXmlNfe] - "+"Execute o mÃ³dulo de configuraÃ§Ã£o do serviÃ§o, antes de utilizar esta opÃ§Ã£o!!!")
        Endif
    EndIf

    If (lSChedule)
        Conout("[xmlinteg] Empresa: "+cEmp+" Filial: "+cFil +" - EnvioManif FIM - Time: " + Time() )
    Endif

Return lRetOk


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
Static Function ReadyTSS(cURL,nTipo,lHelp)
    Local lUsaColab := UsaColaboracao("4")

    If (lSChedule)
        Conout("[xmlinteg] Empresa: "+cEmp+" Filial: "+cFil +" - ReadyTSS - Time: " + Time() )
    Endif

Return (CTIsReady(cURL,nTipo,lHelp,lUsaColab))


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
Static Function fGetCodA2()
    Local cQryA2 := ""

    If (lSChedule)
        Conout("[xmlinteg] Empresa: "+cEmp+" Filial: "+cFil +" - fGetCodA2 - Time: " + Time() )
    Endif

    cQryA2 := "SELECT MAX(A2_COD) AS A2_COD FROM "+RetSqlName("SA2")+" WHERE A2_CGC <> ' ' AND D_E_L_E_T_= ' ' "

    If Select("TRB")>0
        dbSelectArea("TRB")
        dbCloseArea()
    Endif

    TcQuery  cQryA2 New Alias "TRB"

    TRB->(dbGotop())

Return Soma1(TRB->A2_COD,TamSX3("A2_COD")[1])

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
Static Function fbuscaMun(cEstado,cCodMun)
    Local cQryCC2 := ""

    If (lSChedule)
        Conout("[xmlinteg] Empresa: "+cEmp+" Filial: "+cFil +" - fbuscaMun - Time: " + Time() )
    Endif

    cQryCC2 += " SELECT DISTINCT CC2.CC2_MUN  AS CC2_MUN
    cQryCC2 += " FROM " + RetSqlName("CC2") + " CC2 "
    cQryCC2 += " WHERE
    cQryCC2 += " CC2.CC2_FILIAL = '" + xFilial("CC2") + "' AND "
    cQryCC2 += " CC2.CC2_EST = '" + cEstado + "' AND "
    cQryCC2 += " CC2.CC2_CODMUN = '" + cCodMun + "' AND "
    cQryCC2 += " CC2.D_E_L_E_T_ = ' ' "

    If Select("TRB")>0
        dbSelectArea("TRB")
        dbCloseArea()
    Endif

    TcQuery cQryCC2 New Alias "TRB"

    TRB->(dbGotop())

Return Alltrim(TRB->CC2_MUN)

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
Static function fTrataFor(lCTE)

    Local lRet    := .T.
    Local aFedera := {}
    Local cNome   := ""
    Local cIE     := ""
    Local cCep    := ""
    Local cMun    := ""
    Local cPais   := ""
    Local cFone   := ""
    Local cNumero := ""
    Local cUF     := ""
    Local cBairro := ""
    Local cLgr    := ""
    Local nTipo   := 0
    Local lCodCNPJ:= GetMv("MV_XCODCGC",,.F.)//Caso verdadeiro utiliza código de acordo com CNPJ caso falso utiliza sequencial

    If (lSChedule)
        Conout("[xmlinteg] Empresa: "+cEmp+" Filial: "+cFil +" - fTrataFor - Time: " + Time() )
    Endif


    If type("oXmlfim")=="O"

        If !lCTE
            If ALLTRIM(TYPE("oXmlfim:_NFE:_INFNFE"))=="O"
                nTipo:=1
            Endif
            If ALLTRIM(TYPE("oXmlfim:_NFEPROC:_NFE:_INFNFE"))=="O"
                nTipo:=2
            Endif
            If nTipo==1
                cChaveNFE:= iif(Type("oXmlfim:_NFE:_INFNFE:_ID:TEXT")          != "U"      ,alltrim(SUBSTR(oXmlfim:_NFE:_INFNFE:_ID:TEXT,4,200)),"")
                cCNPJ   := iif(Type("oXmlfim:_nfe:_infnfe:_emit:_cnpj:text")  != "U"             ,alltrim(oXmlfim:_nfe:_infnfe:_emit:_cnpj:text),"")
                cNome   := iif(Type("oXmlfim:_NFE:_INFNFE:_EMIT:_XNOME:TEXT") != "U"             ,alltrim(oXmlfim:_NFE:_INFNFE:_EMIT:_XNOME:TEXT),"")
                cIE     := iif(Type("oXmlfim:_NFE:_INFNFE:_EMIT:_IE:TEXT")    != "U"             ,alltrim(oXmlfim:_NFE:_INFNFE:_EMIT:_IE:TEXT),"")
                cCep    := iif(Type("oXmlfim:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_CEP:TEXT")     != "U",alltrim(oXmlfim:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_CEP:TEXT),"")
                cMun    := iif(Type("oXmlfim:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_CMUN:TEXT")    != "U",alltrim(oXmlfim:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_CMUN:TEXT),"")
                cPais   := iif(Type("oXmlfim:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_CPAIS:TEXT")   != "U",alltrim(oXmlfim:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_CPAIS:TEXT),"")
                cFone   := iif(Type("oXmlfim:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_FONE:TEXT")    != "U",alltrim(oXmlfim:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_FONE:TEXT),"")
                cNumero := iif(Type("oXmlfim:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_NRO:TEXT")     != "U",alltrim(oXmlfim:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_NRO:TEXT),"")
                cUF     := iif(Type("oXmlfim:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_UF:TEXT")      != "U",alltrim(oXmlfim:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_UF:TEXT),"")
                cBairro := iif(Type("oXmlfim:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XBAIRRO:TEXT") != "U",alltrim(oXmlfim:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XBAIRRO:TEXT),"")
                cLgr    := iif(Type("oXmlfim:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XLGR:TEXT")    != "U",alltrim(oXmlfim:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XLGR:TEXT),"")
            Else
                cChaveNFE:= iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_ID:TEXT")          != "U"              ,alltrim(SUBSTR(oXmlfim:_NFEPROC:_NFE:_INFNFE:_ID:TEXT,4,200)),"")
                cCNPJ   := iif(Type("oXmlfim:_nfeproc:_nfe:_infnfe:_emit:_cnpj:text")  != "U"              ,alltrim(oXmlfim:_nfeproc:_nfe:_infnfe:_emit:_cnpj:text),"")
                cNome   := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_EMIT:_XNOME:TEXT") != "U"              ,alltrim(oXmlfim:_NFEPROC:_NFE:_INFNFE:_EMIT:_XNOME:TEXT),"")
                cIE     := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_EMIT:_IE:TEXT")    != "U"              ,alltrim(oXmlfim:_NFEPROC:_NFE:_INFNFE:_EMIT:_IE:TEXT),"")
                cCep    := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_CEP:TEXT")     != "U",alltrim(oXmlfim:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_CEP:TEXT),"")
                cMun    := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_CMUN:TEXT")    != "U",alltrim(oXmlfim:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_CMUN:TEXT),"")
                cPais   := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_CPAIS:TEXT")   != "U",alltrim(oXmlfim:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_CPAIS:TEXT),"")
                cFone   := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_FONE:TEXT")    != "U",alltrim(oXmlfim:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_FONE:TEXT),"")
                cNumero := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_NRO:TEXT")     != "U",alltrim(oXmlfim:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_NRO:TEXT),"")
                cUF     := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_UF:TEXT")      != "U",alltrim(oXmlfim:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_UF:TEXT),"")
                cBairro := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XBAIRRO:TEXT") != "U",alltrim(oXmlfim:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XBAIRRO:TEXT),"")
                cLgr    := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XLGR:TEXT")    != "U",alltrim(oXmlfim:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XLGR:TEXT),"")
            Endif
        Else
            If XmlChildEx( oXmlfim , "_PROCEVENTOCTE" ) != Nil
                cChaveNFE:= iif(Type("oXmlfim:_proceventocte:_eventocte:_infcte:_chcte:text")          != "U"             ,alltrim(SUBSTR(oXmlfim:_cteproc:_cte:_infcte:_id:text,4,200)),"")
                cCNPJ   := iif(Type("oXmlfim:_proceventocte:_eventocte:_infcte:_emit:_cnpj:text")  != "U"             ,alltrim(oXmlfim:_cteproc:_cte:_infcte:_emit:_cnpj:text),"")
                cNome   := iif(Type("oXmlfim:_proceventocte:_eventocte:_infcte:_emit:_XNOME:TEXT") != "U"             ,alltrim(oXmlfim:_cteproc:_cte:_infcte:_emit:_XNOME:TEXT),"")
                cIE     := iif(Type("oXmlfim:_proceventocte:_eventocte:_infcte:_emit:_IE:TEXT")    != "U"             ,alltrim(oXmlfim:_cteproc:_cte:_infcte:_emit:_IE:TEXT),"")
                cCep    := iif(Type("oXmlfim:_proceventocte:_eventocte:_infcte:_emit:_ENDEREMIT:_CEP:TEXT")     != "U",alltrim(oXmlfim:_cteproc:_cte:_infcte:_emit:_ENDEREMIT:_CEP:TEXT),"")
                cMun    := iif(Type("oXmlfim:_proceventocte:_eventocte:_infcte:_emit:_ENDEREMIT:_CMUN:TEXT")    != "U",alltrim(oXmlfim:_cteproc:_cte:_infcte:_emit:_ENDEREMIT:_CMUN:TEXT),"")
                cPais   := iif(Type("oXmlfim:_proceventocte:_eventocte:_infcte:_emit:_ENDEREMIT:_CPAIS:TEXT")   != "U",alltrim(oXmlfim:_cteproc:_cte:_infcte:_emit:_ENDEREMIT:_CPAIS:TEXT),"")
                cFone   := iif(Type("oXmlfim:_proceventocte:_eventocte:_infcte:_emit:_ENDEREMIT:_FONE:TEXT")    != "U",alltrim(oXmlfim:_cteproc:_cte:_infcte:_emit:_ENDEREMIT:_FONE:TEXT),"")
                cNumero := iif(Type("oXmlfim:_proceventocte:_eventocte:_infcte:_emit:_ENDEREMIT:_NRO:TEXT")     != "U",alltrim(oXmlfim:_cteproc:_cte:_infcte:_emit:_ENDEREMIT:_NRO:TEXT),"")
                cUF     := iif(Type("oXmlfim:_proceventocte:_eventocte:_infcte:_emit:_ENDEREMIT:_UF:TEXT")      != "U",alltrim(oXmlfim:_cteproc:_cte:_infcte:_emit:_ENDEREMIT:_UF:TEXT),"")
                cBairro := iif(Type("oXmlfim:_proceventocte:_eventocte:_infcte:_emit:_ENDEREMIT:_XBAIRRO:TEXT") != "U",alltrim(oXmlfim:_cteproc:_cte:_infcte:_emit:_ENDEREMIT:_XBAIRRO:TEXT),"")
                cLgr    := iif(Type("oXmlfim:_proceventocte:_eventocte:_infcte:_emit:_ENDEREMIT:_XLGR:TEXT")    != "U",alltrim(oXmlfim:_cteproc:_cte:_infcte:_emit:_ENDEREMIT:_XLGR:TEXT),"")

            Else
                cChaveNFE:= iif(Type("oXmlfim:_cteproc:_cte:_infcte:_id:text")          != "U"             ,alltrim(SUBSTR(oXmlfim:_cteproc:_cte:_infcte:_id:text,4,200)),"")
                cCNPJ   := iif(Type("oXmlfim:_cteproc:_cte:_infcte:_emit:_cnpj:text")  != "U"             ,alltrim(oXmlfim:_cteproc:_cte:_infcte:_emit:_cnpj:text),"")
                cNome   := iif(Type("oXmlfim:_cteproc:_cte:_infcte:_emit:_XNOME:TEXT") != "U"             ,alltrim(oXmlfim:_cteproc:_cte:_infcte:_emit:_XNOME:TEXT),"")
                cIE     := iif(Type("oXmlfim:_cteproc:_cte:_infcte:_emit:_IE:TEXT")    != "U"             ,alltrim(oXmlfim:_cteproc:_cte:_infcte:_emit:_IE:TEXT),"")
                cCep    := iif(Type("oXmlfim:_cteproc:_cte:_infcte:_emit:_ENDEREMIT:_CEP:TEXT")     != "U",alltrim(oXmlfim:_cteproc:_cte:_infcte:_emit:_ENDEREMIT:_CEP:TEXT),"")
                cMun    := iif(Type("oXmlfim:_cteproc:_cte:_infcte:_emit:_ENDEREMIT:_CMUN:TEXT")    != "U",alltrim(oXmlfim:_cteproc:_cte:_infcte:_emit:_ENDEREMIT:_CMUN:TEXT),"")
                cPais   := iif(Type("oXmlfim:_cteproc:_cte:_infcte:_emit:_ENDEREMIT:_CPAIS:TEXT")   != "U",alltrim(oXmlfim:_cteproc:_cte:_infcte:_emit:_ENDEREMIT:_CPAIS:TEXT),"")
                cFone   := iif(Type("oXmlfim:_cteproc:_cte:_infcte:_emit:_ENDEREMIT:_FONE:TEXT")    != "U",alltrim(oXmlfim:_cteproc:_cte:_infcte:_emit:_ENDEREMIT:_FONE:TEXT),"")
                cNumero := iif(Type("oXmlfim:_cteproc:_cte:_infcte:_emit:_ENDEREMIT:_NRO:TEXT")     != "U",alltrim(oXmlfim:_cteproc:_cte:_infcte:_emit:_ENDEREMIT:_NRO:TEXT),"")
                cUF     := iif(Type("oXmlfim:_cteproc:_cte:_infcte:_emit:_ENDEREMIT:_UF:TEXT")      != "U",alltrim(oXmlfim:_cteproc:_cte:_infcte:_emit:_ENDEREMIT:_UF:TEXT),"")
                cBairro := iif(Type("oXmlfim:_cteproc:_cte:_infcte:_emit:_ENDEREMIT:_XBAIRRO:TEXT") != "U",alltrim(oXmlfim:_cteproc:_cte:_infcte:_emit:_ENDEREMIT:_XBAIRRO:TEXT),"")
                cLgr    := iif(Type("oXmlfim:_cteproc:_cte:_infcte:_emit:_ENDEREMIT:_XLGR:TEXT")    != "U",alltrim(oXmlfim:_cteproc:_cte:_infcte:_emit:_ENDEREMIT:_XLGR:TEXT),"")
            Endif
        Endif

        aFedera := FWGetSX5 ( "12" , cUF , "pt-br")
        cFederacao := ""
        If Len(aFedera)>0
            cFederacao :=aFedera[1][4]
        Endif
        dbSelectArea("SA2")
        dbSetOrder(3) //Filial + CGC
        If !dbSeek( xfilial("SA2") + Padr( Alltrim(cCNPJ) , TamSX3("A2_CGC")[1] ) )
            If lCodCNPJ
                cCodSA2 := Substr(cCNPJ,1,8)
                cLojaSa2:= Substr(cCNPJ,9,4)
            Else
                cCodSA2 := fGetCodA2()
                cLojaSa2:= "01"
            Endif

            dbSelectArea("SA2")
            dbSetOrder(1)
            While (dbSeek(xFilial("SA2")+Padr(cCodSA2,6)))
                cCodSA2:=Soma1(cCodSA2,6)
            End

            ConOut("[XMLINTEG][fTrataFor] - "+"Fornecedor "+cCodSA2+"-"+cNome+" incluido com sucesso.")

            If Empty(cNome)
                cNome := "CTE"
            ENdif
            
            RegToMemory( "SA2", .T. ,.T. ,.T. ,)
            
            oModel := Nil
            oModel := FWLoadModel('MATA020')
            oModel:SetOperation(3)
            oModel:Activate()

            oModel:SetValue('SA2MASTER','A2_COD'     , cCodSA2)
            oModel:SetValue('SA2MASTER','A2_LOJA'    , cLojaSa2)
            oModel:SetValue('SA2MASTER','A2_NOME'    , Upper(Substr(Alltrim(cNome),1,TamSX3("A2_NOME")[1]))  )
            oModel:SetValue('SA2MASTER','A2_NREDUZ'  , Upper(Substr( cNome , 1 , TamSx3("A2_NREDUZ")[1] )) )
            oModel:SetValue('SA2MASTER','A2_END'     , Alltrim(Upper(cLgr)) )
            oModel:SetValue('SA2MASTER','A2_NR_END'  , cNumero )
            oModel:SetValue('SA2MASTER','A2_BAIRRO'  , Alltrim(Upper(cBairro)) )
            oModel:SetValue('SA2MASTER','A2_EST'     , cUF )
            oModel:SetValue('SA2MASTER','A2_COD_MUN' ,Substr(cMun,3,5) )
            oModel:SetValue('SA2MASTER','A2_MUN'     , fbuscaMun(cUF,Substr(cMun,3,5)) )
            oModel:SetValue('SA2MASTER','A2_ESTADO'  , cFederacao )
            oModel:SetValue('SA2MASTER','A2_CEP'     , cCep )
            oModel:SetValue('SA2MASTER','A2_TIPO'    , iif(Len(Alltrim(cCNPJ))>=14,"J","F")  )
            oModel:SetValue('SA2MASTER','A2_CGC'     , StrTran(Strtran(cCNPJ,"-",""),"/","") )
            oModel:SetValue('SA2MASTER','A2_DDD'     , Substr(cFone,1,2)  )
            oModel:SetValue('SA2MASTER','A2_TEL'     , Substr(cFone,3,LEN(cFone)) )
            oModel:SetValue('SA2MASTER','A2_INSCR'   , iif(Empty(cIE),"ISENTO",cIE) )
            oModel:SetValue('SA2MASTER','A2_CODPAIS' , StrZero(Val(cPais),TamSX3("A2_CODPAIS")[1]) )
            oModel:SetValue('SA2MASTER','A2_CONTRIB' , iif(Empty(cIE),"2","1") )
            oModel:SetValue('SA2MASTER','A2_XUNICO'  , iif(lCTE,"N",M->A2_XUNICO ) )
            oModel:SetValue('SA2MASTER','A2_XESTOQU' , iif(lCTE,"N",M->A2_XESTOQU) )
            oModel:SetValue('SA2MASTER','A2_TIPAWB'  , M->A2_TIPAWB )
            oModel:SetValue('SA2MASTER','A2_DTPAWB'  , M->A2_DTPAWB )
            oModel:SetValue('SA2MASTER','A2_NOMFAV'  , M->A2_NOMFAV )

            If oModel:VldData()
                oModel:CommitData()
                ConfirmSX8()

                aAdd(aCadFor , { cCodSA2  , cLojaSa2 , Alltrim(Upper(cNome)) , Transform( StrTran(Strtran(cCNPJ,"-",""),"/","") , "@R 99.999.999/9999-99") , cChaveNFE } )
            Else
                If (!lSChedule)
                    Aviso("Erro",oModel:GetErrorMessage()[6],{"Ok"})
                Else
                    ConOut("[XMLINTEG] - Erro " + oModel:GetErrorMessage()[6] )
                Endif
            Endif
            oModel:DeActivate()
            oModel:Destroy()
        Else
            If !Empty(SA2->A2_XESTOQU) .And. SA2->A2_XESTOQU<>"I"
                fTrataPrd( SA2->A2_COD , SA2->A2_LOJA , SA2->A2_XESTOQU , '', lCTE )
            Else
                nPos := aScan(aLogFor,{ |x| Alltrim(x[1]) + Alltrim(x[2]) == Alltrim(SA2->A2_COD) + Alltrim(SA2->A2_LOJA) })
                if nPos==0
                    aAdd(aLogFor , { SA2->A2_COD  , SA2->A2_LOJA , SA2->A2_NOME , Transform(SA2->A2_CGC, "@R 99.999.999/9999-99") , cChaveNFE } )
                Endif
                If cDirBx<>cDirLog
                    If file(cDirBx+iif(lCTE,"cte","nfe")+cChaveNFE+".xml")
                        lCpy := __COPYFILE( cDirBx+iif(lCTE,"cte","nfe")+cChaveNFE+".xml" , cDirLog+iif(lCTE,"cte","nfe")+cChaveNFE+".xml" ,,,.F.)
                        if lCpy
                            nErase := fErase(cDirBx+iif(lCTE,"cte","nfe")+cChaveNFE+".xml")
                            if nErase = -1
                                If (!lSChedule)
                                    Aviso("Aviso","Erro ao excluir arquivo "+cDirBx+iif(lCTE,"cte","nfe")+cChaveNFE+".xml"+ " - fError " + Str(Ferror()))
                                Else
                                    conout("Erro ao excluir arquivo - ferror " + Str(Ferror()))
                                Endif
                            Endif
                        Else
                            If (!lSChedule)
                                Aviso("Aviso","Erro ao copiar arquivo "+cDirBx+iif(lCTE,"cte","nfe")+cChaveNFE+".xml"+ " para pasta de log - fError " + Str(Ferror()))
                            Else
                                conout("Erro ao copiar arquivo para pasta - ferror " + Str(Ferror()))
                            Endif
                        Endif
                    Endif
                Endif
                If (!lSChedule)
                    Aviso("Aviso","O fornecedor "+ SA2->A2_COD + "-"+ SA2->A2_LOJA + " sem definicao, preencha o campo Merc.Estoque para este fornecedor, xml movido para pasta "+cDirLog, {"Continuar"} )
                Else
                    Conout("["+cThread+"] - O fornecedor " + SA2->A2_COD + "-" + SA2->A2_LOJA +" sem definicao, preencha o campo Merc.Estoque para este fornecedor, xml movido para pasta "+cDirLog )
                Endif
            Endif
        Endif
    Endif

Return lRet

/*/{Protheus.doc}'FProcLog'
'FunÃ§Ã£o responsavel em processar os arquivos da pasta de log dos xmls'
@author Sergio Celestino
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/
Static Function fProclog()
    Local nPos    := 0
    Local nFiles  := 0
    Local nOption := 0
    Local cError  := ""
    Local cWarning:= ""
    Local cCNPJ   := ""
    Local aFiles  := {}
    Local lCTE    := .F.

    Private cDir        := Alltrim(GetMv("MV_OVINN",,"\xml\inn\"))
    Private cDirRes     := Alltrim(GetMv("MV_OVRES",,"\xml\res\"))
    Private cDirLog     := Alltrim(GetMv("MV_OVLOG",,"\xml\log\"))
    Private cDirErr     := Alltrim(GetMv("MV_OVERR",,"\xml\err\"))
    Private cDirMan     := Alltrim(GetMv("MV_OVMAN",,"\xml\manifesto\"))

    if Substr(cDir,Len(cDir),1)<>"\"
        cDir := cDir+"\"
    Endif

    if Substr(cDirRes,Len(cDirRes),1)<>"\"
        cDirRes := cDirRes+"\"
    Endif

    if Substr(cDirLog,Len(cDirLog),1)<>"\"
        cDirLog := cDirLog+"\"
    Endif

    if Substr(cDirErr,Len(cDirErr),1)<>"\"
        cDirErr := cDirErr+"\"
    Endif

    aFiles  := Directory(cDirLog+"*.xml", "D" , , .F. , 2 )

    If (lSChedule)
        Conout("["+cThread+"] - Empresa: "+cEmp+" Filial: "+cFil+" Processando xmls da pasta log : "+cDirLog )
    Endif


    If Len(aFiles)>0
        For nFiles := 1 To Len(aFiles)

            lCTE    := .F.

            Conout("["+cThread+"] - Empresa: "+cEmp+ " Filial: " + cFil + " Processando " + Alltrim(Str(nFiles)) +" de : "+Alltrim(Str(Len(aFiles))) +" arquivos da pasta log." )

            cCNPJ   :=""
            oXmlfim := XmlParserFile( cDirLog+aFiles[nFiles][1], "_", @cError, @cWarning )
            cChaveNFE:= iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_ID:TEXT")         != "U",alltrim(SUBSTR(oXmlfim:_NFEPROC:_NFE:_INFNFE:_ID:TEXT,4,200)),"")
            cCNPJ   := iif(Type("oXmlfim:_nfeproc:_nfe:_infnfe:_emit:_cnpj:text") != "U",alltrim(oXmlfim:_nfeproc:_nfe:_infnfe:_emit:_cnpj:text),"")

            If Empty(cCNPJ) .And. XmlChildEx( oXmlfim , "_CTEPROC" ) != Nil
                cChaveNFE:= iif(Type("oXmlfim:_cteproc:_cte:_infcte:_id:text")         != "U",alltrim(SUBSTR(oXmlfim:_cteproc:_cte:_infcte:_id:text,4,200)),"")
                cCNPJ   := iif(Type("oXmlfim:_cteproc:_cte:_infcte:_emit:_cnpj:text") != "U",alltrim(oXmlfim:_cteproc:_cte:_infcte:_emit:_cnpj:text),"")
                lCTE    := .T.
            Endif

            If !Empty(cCNPJ)
                dbSelectArea("SA2")
                dbSetOrder(3) //Filial + CGC
                If dbSeek( xfilial("SA2") + Padr( Alltrim(cCNPJ) , TamSX3("A2_CGC")[1] ) )
                    if !Empty(SA2->A2_XESTOQU) .And. SA2->A2_XESTOQU<>"I"
                        fTrataPrd( SA2->A2_COD , SA2->A2_LOJA , SA2->A2_XESTOQU , cDirLog+aFiles[nFiles][1] , lCTE)
                    Else
                        nPos := aScan(aLogFor,{ |x| Alltrim(x[1]) + Alltrim(x[2]) == Alltrim(SA2->A2_COD) + Alltrim(SA2->A2_LOJA) })
                        if nPos==0
                            aAdd( aLogFor , { SA2->A2_COD  , SA2->A2_LOJA , SA2->A2_NOME , Transform(SA2->A2_CGC, "@R 99.999.999/9999-99") , cChaveNFE } )
                        Endif
                    Endif
                Else
                    fTrataFor(lCTE)
                Endif
            Endif
        Next
        if nOpc==3
            if Len(aCadFor)>0
                Conout("["+cThread+"] - Empresa: " + cEmp + " Filial: " + cFil + " Enviando E-Mail de fornecedores cadastrados ")
                CadMailEnv()
            endif
            If Len(aLogFor)>0
                Conout("["+cThread+"] - Empresa "  + cEmp +"  Filial: " + cFil + " Enviando E-Mail de LOG para fornecedores incompleto. ")
                fNotifCad()
            Endif
        Endif
    Endif


Return
/*/{Protheus.doc}'fTrataPrd'
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
Static Function fTrataPrd(cCodFor,cLojFor,cForEst,cfile,lCTE)

    Local cPrdGen     := Alltrim(GetMv("OV_PRODGEN",,"GEN001"))
    Local nTipo       := 0
    Local aCols       := {}
    Local aCadB1      := {}
    Local cUM		  := ""
    Local cCodbar     := ""
    Local cProdFor    := ""
    Local nQuant	  := ""
    Local xDesc	      := ""
    Local xDesF       := ""
    Local cNCM	      := ""
    Local cCEST	      := ""
    Local cLocPad     := "CD"
    Local cTipo       := "MR"
    Local nAliqIPI    := 0
    Local nAliqICM00  := 0
    Local nAliqICM10  := 0
    Local nAliqICM60  := 0
    Local nAliqICM90  := 0
    Local nAliqICMST  := 0
    Local cOrigemPrd  := ""
    Local i

    If (lSChedule)
        Conout("["+cThread+"] - Empresa: "+cEmp+" Filial: "+cFil+" fTrataPrd - Time : "+Time() )
    Endif

    if Type("oxmlfim")=="O"

        If Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET")!="U"
            nTipo := 2
            aCols := aClone(oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET)
        Elseif Type("oXmlfim:_NFE:_INFNFE:_DET")!="U"
            nTipo := 1
            aCols := aClone(oXmlfim:_NFE:_INFNFE:_DET)
        Endif

        If aCols==NIL
            nItens:=1
        Else
            nItens := Len(aCols)
        Endif

        cChaveNFE	:=	iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_ID:TEXT")!="U",ALLTRIM(SUBSTR(oXmlfim:_NFEPROC:_NFE:_INFNFE:_ID:TEXT,4,200)),"nokey")

        For i:=1 to nItens;

            cOrigemPrd:=""

            If nTipo==2
                If nItens>1
                    cUM		   := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_PROD:_UCOM:TEXT")  !="U" ,Upper(oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_UCOM:TEXT),"")
                    cCodbar    := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_PROD:_CEAN:TEXT")  !="U" ,oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_CEAN:TEXT  ,"")
                    cProdFor   := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_PROD:_CPROD:TEXT") !="U" ,oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_CPROD:TEXT ,"")
                    nQuant	   := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_PROD:_QCOM:TEXT")  !="U" ,Val(oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_QCOM:TEXT),0)
                    xDesc	   := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_PROD:_XPROD:TEXT") !="U" ,oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_XPROD:TEXT , "")
                    cNCM	   := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_PROD:_NCM:TEXT")   !="U" ,oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_NCM:TEXT   , "")
                    cCEST	   := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_PROD:_CEST:TEXT")  !="U" ,oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_CEST:TEXT  , "")
                    nAliqIPI   := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT")   !="U" , Val(oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET[I]:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT) , 0 )
                    nAliqICM00 := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_IMPOSTO:_ICMS:_ICMS00:_PICMS:TEXT")  !="U" , Val(oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET[I]:_IMPOSTO:_ICMS:_ICMS00:_PICMS:TEXT) , 0 )
                    nAliqICM10 := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_IMPOSTO:_ICMS:_ICMS10:_PICMS:TEXT")  !="U" , Val(oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET[I]:_IMPOSTO:_ICMS:_ICMS10:_PICMS:TEXT) , 0 )
                    nAliqICM60 := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_IMPOSTO:_ICMS:_ICMS60:_PICMS:TEXT")  !="U" , Val(oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET[I]:_IMPOSTO:_ICMS:_ICMS60:_PICMS:TEXT) , 0 )
                    nAliqICM90 := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_IMPOSTO:_ICMS:_ICMS90:_PICMS:TEXT")  !="U" , Val(oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET[I]:_IMPOSTO:_ICMS:_ICMS90:_PICMS:TEXT) , 0 )
                    nAliqICMST := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_IMPOSTO:_ICMS:_ICMS10:_PICMSST:TEXT")!="U" , Val(oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET[I]:_IMPOSTO:_ICMS:_ICMS10:_PICMSST:TEXT) , 0 )

                    if Empty(cOrigemPrd)
                        cOrigemPrd := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_IMPOSTO:_ICMS:_ICMSSN500:_ORIG:TEXT")!="U" , oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET[I]:_IMPOSTO:_ICMS:_ICMSSN500:_ORIG:TEXT , "" )
                    Endif

                    If Empty(cOrigemPrd)
                        cOrigemPrd := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_IMPOSTO:_ICMS:_ICMS00:_ORIG:TEXT")!="U" , oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET[I]:_IMPOSTO:_ICMS:_ICMS00:_ORIG:TEXT , "" )
                    endif

                    If Empty(cOrigemPrd)
                        cOrigemPrd := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_IMPOSTO:_ICMS:_ICMS10:_ORIG:TEXT")!="U" , oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET[I]:_IMPOSTO:_ICMS:_ICMS10:_ORIG:TEXT , "" )
                    endif

                    If Empty(cOrigemPrd)
                        cOrigemPrd := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_IMPOSTO:_ICMS:_ICMS40:_ORIG:TEXT")!="U" , oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET[I]:_IMPOSTO:_ICMS:_ICMS40:_ORIG:TEXT , "" )
                    endif

                    If Empty(cOrigemPrd)
                        cOrigemPrd := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_IMPOSTO:_ICMS:_ICMS60:_ORIG:TEXT")!="U" , oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET[I]:_IMPOSTO:_ICMS:_ICMS60:_ORIG:TEXT , "" )
                    endif

                    If Empty(cOrigemPrd)
                        cOrigemPrd := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_IMPOSTO:_ICMS:_ICMS90:_ORIG:TEXT")!="U" , oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET[I]:_IMPOSTO:_ICMS:_ICMS90:_ORIG:TEXT , "" )
                    endif


                Else

                    cUM		   := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_UCOM:TEXT")  !="U" ,Upper(oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_UCOM:TEXT),"")
                    cCodbar    := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CEAN:TEXT")  !="U" ,oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CEAN:TEXT  ,"")
                    cProdFor   := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CPROD:TEXT") !="U" ,oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CPROD:TEXT ,"")
                    nQuant	   := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_QCOM:TEXT")  !="U" ,Val(oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_QCOM:TEXT),0)
                    xDesc	   := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_XPROD:TEXT") !="U" ,oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_XPROD:TEXT , "")
                    cNCM	   := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_NCM:TEXT")   !="U" ,oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_NCM:TEXT   , "")
                    cCEST	   := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CEST:TEXT")  !="U" ,oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CEST:TEXT  , "")
                    nAliqIPI   := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT")   !="U" , Val(oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT )  , 0 )
                    nAliqICM00 := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_PICMS:TEXT")  !="U" , Val(oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_PICMS:TEXT)  , 0 )
                    nAliqICM10 := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS10:_PICMS:TEXT")  !="U" , Val(oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS10:_PICMS:TEXT)  , 0 )
                    nAliqICM40 := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS40:_PICMS:TEXT")  !="U" , Val(oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS40:_PICMS:TEXT)  , 0 )
                    nAliqICM60 := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS60:_PICMS:TEXT")  !="U" , Val(oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS60:_PICMS:TEXT)  , 0 )
                    nAliqICM90 := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS90:_PICMS:TEXT")  !="U" , Val(oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS90:_PICMS:TEXT)  , 0 )
                    nAliqICMST := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS10:_PICMSST:TEXT")!="U" , Val(oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS10:_PICMSST:TEXT), 0 )

                    If Empty(cOrigemPrd)
                        cOrigemPrd := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMSSN500:_ORIG:TEXT")!="U" , oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMSSN500:_ORIG:TEXT , "" )
                    endif

                    If Empty(cOrigemPrd)
                        cOrigemPrd := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_ORIG:TEXT")!="U" , oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_ORIG:TEXT , "" )
                    endif

                    If Empty(cOrigemPrd)
                        cOrigemPrd := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS10:_ORIG:TEXT")!="U" , oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS10:_ORIG:TEXT , "" )
                    endif

                    If Empty(cOrigemPrd)
                        cOrigemPrd := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS40:_ORIG:TEXT")!="U" , oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS40:_ORIG:TEXT , "" )
                    endif

                    If Empty(cOrigemPrd)
                        cOrigemPrd := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS60:_ORIG:TEXT")!="U" , oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS60:_ORIG:TEXT , "" )
                    endif

                    If Empty(cOrigemPrd)
                        cOrigemPrd := iif(Type("oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS90:_ORIG:TEXT")!="U" , oXmlfim:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS90:_ORIG:TEXT , "" )
                    endif
                Endif
            Else

                If nItens>1
                    cUM        := iif(Type("oXmlfim:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_PROD:_UCOM:TEXT")  !="U", Upper(oXmlfim:_NFE:_INFNFE:_DET[i]:_PROD:_UCOM:TEXT) ,"")
                    cCodbar    := iif(Type("oXmlfim:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_PROD:_CEAN:TEXT")  !="U", oXmlfim:_NFE:_INFNFE:_DET[i]:_PROD:_CEAN:TEXT ,"")
                    cProdFor   := iif(Type("oXmlfim:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_PROD:_CPROD:TEXT") !="U", oXmlfim:_NFE:_INFNFE:_DET[i]:_PROD:_CPROD:TEXT,"")
                    nQuant	   := iif(Type("oXmlfim:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_PROD:_QCOM:TEXT")  !="U", val(oXmlfim:_NFE:_INFNFE:_DET[i]:_PROD:_QCOM:TEXT),0)
                    xDesc	   := iif(Type("oXmlfim:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_PROD:_XPROD:TEXT") !="U", oXmlfim:_NFE:_INFNFE:_DET[i]:_PROD:_XPROD:TEXT,"")
                    cNCM       := iif(Type("oXmlfim:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_PROD:_NCM:TEXT")   !="U", oXmlfim:_NFE:_INFNFE:_DET[i]:_PROD:_NCM:TEXT  ,"")
                    cCEST      := iif(Type("oXmlfim:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_PROD:_CEST:TEXT")  !="U", oXmlfim:_NFE:_INFNFE:_DET[i]:_PROD:_CEST:TEXT ,"")
                    nAliqIPI   := iif(Type("oXmlfim:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT")  !="U", Val(oXmlfim:_NFE:_INFNFE:_DET[I]:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT)  ,0)
                    nAliqICM00 := iif(Type("oXmlfim:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_IMPOSTO:_ICMS:_ICMS00:_PICMS:TEXT") !="U", Val(oXmlfim:_NFE:_INFNFE:_DET[I]:_IMPOSTO:_ICMS:_ICMS00:_PICMS:TEXT) ,0)
                    nAliqICM10 := iif(Type("oXmlfim:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_IMPOSTO:_ICMS:_ICMS10:_PICMS:TEXT") !="U", Val(oXmlfim:_NFE:_INFNFE:_DET[I]:_IMPOSTO:_ICMS:_ICMS10:_PICMS:TEXT) ,0)
                    nAliqICM60 := iif(Type("oXmlfim:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_IMPOSTO:_ICMS:_ICMS60:_PICMS:TEXT") !="U", Val(oXmlfim:_NFE:_INFNFE:_DET[I]:_IMPOSTO:_ICMS:_ICMS60:_PICMS:TEXT) ,0)
                    nAliqICM90 := iif(Type("oXmlfim:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_IMPOSTO:_ICMS:_ICMS90:_PICMS:TEXT") !="U", Val(oXmlfim:_NFE:_INFNFE:_DET[I]:_IMPOSTO:_ICMS:_ICMS90:_PICMS:TEXT) ,0)

                    if Empty(cOrigemPrd)
                        cOrigemPrd := iif(Type("oXmlfim:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_IMPOSTO:_ICMS:_ICMSSN500:_ORIG:TEXT")!="U" , oXmlfim:_NFE:_INFNFE:_DET[I]:_IMPOSTO:_ICMS:_ICMSSN500:_ORIG:TEXT , "" )
                    Endif

                    If Empty(cOrigemPrd)
                        cOrigemPrd := iif(Type("oXmlfim:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_IMPOSTO:_ICMS:_ICMS00:_ORIG:TEXT")!="U" , oXmlfim:_NFE:_INFNFE:_DET[I]:_IMPOSTO:_ICMS:_ICMS00:_ORIG:TEXT , "" )
                    endif

                    If Empty(cOrigemPrd)
                        cOrigemPrd := iif(Type("oXmlfim:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_IMPOSTO:_ICMS:_ICMS10:_ORIG:TEXT")!="U" , oXmlfim:_NFE:_INFNFE:_DET[I]:_IMPOSTO:_ICMS:_ICMS10:_ORIG:TEXT , "" )
                    endif

                    If Empty(cOrigemPrd)
                        cOrigemPrd := iif(Type("oXmlfim:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_IMPOSTO:_ICMS:_ICMS40:_ORIG:TEXT")!="U" , oXmlfim:_NFE:_INFNFE:_DET[I]:_IMPOSTO:_ICMS:_ICMS40:_ORIG:TEXT , "" )
                    endif

                    If Empty(cOrigemPrd)
                        cOrigemPrd := iif(Type("oXmlfim:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_IMPOSTO:_ICMS:_ICMS60:_ORIG:TEXT")!="U" , oXmlfim:_NFE:_INFNFE:_DET[I]:_IMPOSTO:_ICMS:_ICMS60:_ORIG:TEXT , "" )
                    endif

                    If Empty(cOrigemPrd)
                        cOrigemPrd := iif(Type("oXmlfim:_NFE:_INFNFE:_DET["+Alltrim(Str(i))+"]:_IMPOSTO:_ICMS:_ICMS90:_ORIG:TEXT")!="U" , oXmlfim:_NFE:_INFNFE:_DET[I]:_IMPOSTO:_ICMS:_ICMS60:_ORIG:TEXT , "" )
                    endif

                Else
                    cUM        := iif(Type("oXmlfim:_NFE:_INFNFE:_DET:_PROD:_UCOM:TEXT")  !="U", Upper(oXmlfim:_NFE:_INFNFE:_DET:_PROD:_UCOM:TEXT) ,"")
                    cCodbar    := iif(Type("oXmlfim:_NFE:_INFNFE:_DET:_PROD:_CEAN:TEXT")  !="U", oXmlfim:_NFE:_INFNFE:_DET:_PROD:_CEAN:TEXT ,"")
                    cProdFor   := iif(Type("oXmlfim:_NFE:_INFNFE:_DET:_PROD:_CPROD:TEXT") !="U", oXmlfim:_NFE:_INFNFE:_DET:_PROD:_CPROD:TEXT,"")
                    nQuant	   := iif(Type("oXmlfim:_NFE:_INFNFE:_DET:_PROD:_QCOM:TEXT")  !="U", val(oXmlfim:_NFE:_INFNFE:_DET:_PROD:_QCOM:TEXT),0)
                    xDesc	   := iif(Type("oXmlfim:_NFE:_INFNFE:_DET:_PROD:_XPROD:TEXT") !="U", oXmlfim:_NFE:_INFNFE:_DET:_PROD:_XPROD:TEXT,"")
                    cNCM       := iif(Type("oXmlfim:_NFE:_INFNFE:_DET:_PROD:_NCM:TEXT")   !="U", oXmlfim:_NFE:_INFNFE:_DET:_PROD:_NCM:TEXT  ,"")
                    cCEST      := iif(Type("oXmlfim:_NFE:_INFNFE:_DET:_PROD:_CEST:TEXT")  !="U", oXmlfim:_NFE:_INFNFE:_DET:_PROD:_CEST:TEXT ,"")
                    nAliqIPI   := iif(Type("oXmlfim:_NFE:_INFNFE:_DET:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT")  !="U", Val(oXmlfim:_NFE:_INFNFE:_DET:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT)  ,0)
                    nAliqICM00 := iif(Type("oXmlfim:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_PICMS:TEXT") !="U", Val(oXmlfim:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_PICMS:TEXT) ,0)
                    nAliqICM10 := iif(Type("oXmlfim:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS10:_PICMS:TEXT") !="U", Val(oXmlfim:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS10:_PICMS:TEXT) ,0)
                    nAliqICM60 := iif(Type("oXmlfim:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS60:_PICMS:TEXT") !="U", Val(oXmlfim:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS60:_PICMS:TEXT) ,0)
                    nAliqICM90 := iif(Type("oXmlfim:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS90:_PICMS:TEXT") !="U", Val(oXmlfim:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS90:_PICMS:TEXT) ,0)

                    if Empty(cOrigemPrd)
                        cOrigemPrd := iif(Type("oXmlfim:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMSSN500:_ORIG:TEXT")!="U" , oXmlfim:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMSSN500:_ORIG:TEXT , "" )
                    Endif

                    If Empty(cOrigemPrd)
                        cOrigemPrd := iif(Type("oXmlfim:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_ORIG:TEXT")!="U" , oXmlfim:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_ORIG:TEXT , "" )
                    endif

                    If Empty(cOrigemPrd)
                        cOrigemPrd := iif(Type("oXmlfim:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS10:_ORIG:TEXT")!="U" , oXmlfim:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS10:_ORIG:TEXT , "" )
                    endif

                    If Empty(cOrigemPrd)
                        cOrigemPrd := iif(Type("oXmlfim:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS40:_ORIG:TEXT")!="U" , oXmlfim:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS40:_ORIG:TEXT , "" )
                    endif

                    If Empty(cOrigemPrd)
                        cOrigemPrd := iif(Type("oXmlfim:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS60:_ORIG:TEXT")!="U" , oXmlfim:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS60:_ORIG:TEXT , "" )
                    endif

                    If Empty(cOrigemPrd)
                        cOrigemPrd := iif(Type("oXmlfim:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS90:_ORIG:TEXT")!="U" , oXmlfim:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS60:_ORIG:TEXT , "" )
                    endif

                Endif
            Endif

            If cForEst=="S" // se fornecedor de estoque

                cLocPad := "CD"
                cTipo   := "MR"

                DbSelectarea("SA5")
                DbSetorder(14) // A5_FILIAL+A5_FORNECE+A5_LOJA+A5_CODPRF ( UNICO - A5_FILIAL+A5_FORNECE+A5_LOJA+A5_PRODUTO+A5_FABR+A5_FALOJA+A5_REFGRD)
                Dbgotop()
                if !Dbseek( xFilial("SA5") + cCodFor + cLojFor + Padr( cProdFor , TamSx3("A5_CODPRF")[1]) )
                    Conout("["+cThread+"] - Cadastrando Produto pelo codigo generico, fornecedor de mercadoria definido como estoque")
                    Reclock("SA5",.T.)
                    SA5->A5_FILIAL   := xFilial("SA5")
                    SA5->A5_FORNECE  := cCodFor
                    SA5->A5_LOJA     := cLojFor
                    SA5->A5_NOMEFOR  := SA2->A2_NOME
                    SA5->A5_PRODUTO  := cPrdGen
                    SA5->A5_NOMPROD  := xDesc
                    SA5->A5_CODPRF   := cProdFor
                    SA5->A5_DESCPRF  := xDesc
                    MsUnlock()
                Endif

            Elseif cForEst=="N"
                xDesF   := xDesc
                cLocPad := "01"
                cTipo   := "MC"

                dbSelectArea("SYD")
                dbSetOrder(1)
                If dbSeek(xFilial("SYD") + Padr( Alltrim(cNCM) , TamSX3("YD_TEC")[1] ) )
                    xDesF := xDesc
                    xDesc := Alltrim(SYD->YD_DESC_P)
                Else
                    RECLOCK("SYD",.T.)
                    SYD->YD_FILIAL := xFilial("SYD")
                    SYD->YD_TEC    := cNCM
                    MsUnlock()
                Endif

                dbSelectArea("SAH")
                dbSetOrder(1)
                if !dbSeek(xFilial("SAH") + Padr( Alltrim(cUM) , TamSx3("AH_UNIMED")[1] ) )
                    lSeek := .F.
                    While SAH->(!Eof())
                       If Alltrim(cUM) $ Alltrim(SAH->AH_DESCPO)
                           cUM := SAH->AH_UNIMED
                           lSeek := .T.
                       Endif
                       SAH->(dbSkip())
                    End
                    If !lSeek
                       cUM := "UN"    
                    Endif    
                Endif

                If Empty(cUM)
                    cUM := "UN"
                Endif

                if Empty(cNCM)
                    cNCM  := "00000000"
                    xDesc := "MATERIAL OU OPERACAO NAO CLASSIFICADOS"
                endif

                if Empty(cTipo)
                    cTipo := "ME"
                Endif

                If Empty(xDesc)
                    xDesc := "Revisar descricao"
                Endif

                dbSelectArea("SB1")
                dbSetOrder(1)
                If !dbseek(xFilial("SB1") + Padr(cNCM,TamSx3("B1_COD")[1]) )

                    Conout("["+cThread+"] - Cadastrando Produto pelo NCM, fornecedor de mercadoria definido como nao estoque")

                    oModel  := Nil
                    oModel  := FwLoadModel("MATA010")
                    oModel:SetOperation(3)
                    oModel:Activate()

                    oModel:SetValue("SB1MASTER" , "B1_FILIAL"       ,xFilial("SB1") )
                    oModel:SetValue("SB1MASTER" , "B1_COD"          ,cNCM           )
                    oModel:SetValue("SB1MASTER" , "B1_DESC"         ,Substr(xDesc , 1 , TamSx3("B1_DESC")[1]  ) )
                    oModel:SetValue("SB1MASTER" , "B1_TIPO"         ,cTipo          )
                    oModel:SetValue("SB1MASTER" , "B1_UM"           ,cUM            )
                    oModel:SetValue("SB1MASTER" , "B1_LOCPAD"       ,cLocPad        )
                    oModel:SetValue("SB1MASTER" , "B1_POSIPI"       ,cNCM           )
                    oModel:SetValue("SB1MASTER" , "B1_PICM"         ,nAliqICM00     )
                    oModel:SetValue("SB1MASTER" , "B1_IPI"          ,nAliqIPI       )
                    oModel:SetValue("SB1MASTER" , "B1_CODBAR"       ,cCodbar        )
                    oModel:SetValue("SB1MASTER" , "B1_CEST"         ,cCEST          )
                    oModel:SetValue("SB1MASTER" , "B1_ORIGEM"       ,cOrigemPrd     )
                    oModel:SetValue("SB1MASTER" , "B1_GARANT"       ,"2"            )

                    If oModel:VldData()
                        oModel:CommitData()
                        ConfirmSX8()
                    Else
                        If (!lSChedule)
                            Aviso("Erro",oModel:GetErrorMessage()[6],{"Ok"})
                        Else
                            ConOut("[XMLINTEG] - Erro " + oModel:GetErrorMessage()[6] )
                        Endif
                    EndIf

                    oModel:DeActivate()
                    oModel:Destroy()
                Endif

                DbSelectarea("SA5")
                DbSetorder(14) // A5_FILIAL+A5_FORNECE+A5_LOJA+A5_CODPRF ( UNICO - A5_FILIAL+A5_FORNECE+A5_LOJA+A5_PRODUTO+A5_FABR+A5_FALOJA+A5_REFGRD)
                Dbgotop()
                if !Dbseek( xFilial("SA5") + cCodFor + cLojFor + Padr( cProdFor , TamSx3("A5_CODPRF")[1]) )
                    Conout("["+cThread+"] - Cadastrando Produto x fornecedor pelo NCM, fornecedor de mercadoria definido como nao estoque")
                    Reclock("SA5",.T.)
                    SA5->A5_FILIAL   := xFilial("SA5")
                    SA5->A5_FORNECE  := cCodFor
                    SA5->A5_LOJA     := cLojFor
                    SA5->A5_NOMEFOR  := SA2->A2_NOME
                    SA5->A5_PRODUTO  := cNCM
                    SA5->A5_NOMPROD  := xDesc
                    SA5->A5_CODPRF   := cProdFor
                    SA5->A5_DESCPRF  := xDesF
                    MsUnlock()
                Endif
            Endif
        Next
        if !Empty(cfile)
            cConfFile := iif(lCTE,"cte","nfe")+cfile
        Else
            cConfFile := cDirLog+iif(lCTE,"cte","nfe")+cChaveNFE+".xml"
        Endif

        If file(cConfFile)
            lCpy := __COPYFILE( cConfFile , cDir+iif(lCTE,"cte","nfe")+cChaveNFE+".xml" ,,,.F.)
            if lCpy
                nErase := fErase(cConfFile)
                if nErase = -1
                    If (!lSChedule)
                        Aviso("Aviso","Erro ao excluir arquivo "+cConfFile+ " - fError " + Str(Ferror()))
                    Else
                        conout("Erro ao excluir arquivo na pasta de log - ferror " + Str(Ferror()))
                    Endif
                Endif
            Else
                If (!lSChedule)
                    Aviso("Aviso","Erro ao copiar arquivo "+cConfFile+ " para pasta "+cDir+" - fError " + Str(Ferror()))
                Else
                    conout("Erro ao copiar arquivo da pasta log para a pasta "+cDir+"- ferror " + Str(Ferror()))
                Endif
            Endif
        Endif
    Endif

    If (lSChedule)
        Conout("["+cThread+"] - Empresa: "+cEmp+" Filial: "+cFil+" fTrataPrd FIM - Time : "+Time() )
    Endif

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
Static Function XMLSELARQ()

    Local _aFiles 	:= {}
    Local aStruct	:= {}
    Local nK		:= 1
    Local cFolder	:= ""

    cFolder := cGetFile( '*.xml|*.xml' , 'Escolha a Pasta' , 1 ,  , .T. , nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY ,GETF_NETWORKDRIVE , GETF_RETDIRECTORY ) , .F.)

Return cFolder

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
Static Function CadMailEnv()

    Local ni        := 0
    Local cTipo     := ""
    Local _cBody    := ''
    Local cEmail	:= Alltrim(GetMv("OV_CADMAIL"))
    Local cSubject  := "Integrador Sefaz - Cadastramento de Fornecedor"


    _cBody := ''
    _cBody += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'
    _cBody += '<html>'
    _cBody += '<head>'
    _cBody += '  <meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
    _cBody += '  <meta name="GENERATOR" content="Microsoft FrontPage 6.0">'
    _cBody += '  <meta name="ProgId" content="FrontPage.Editor.Document">'
    _cBody += '  <title>Integrador Sefaz - Cadastramento de Fornecedor</title>'
    _cBody += '</head>'
    _cBody += '<body>'
    _cBody += ' <table bordercolorlight="#FFFFFF" bordercolordark="#FFFFFF" border="3" bordercolor="#ff9d02" height="79" width="98%">'
    _cBody += '  <tbody>'
    _cBody += '    <tr>'
    _cBody += '     <td width="76%" height="40" align="center" bordercolor="#ff9d02" bgcolor="#FFFFFF">'
    _cBody += '      <p><b><font face="Tahoma" size="5">Integrador Sefaz - Cadastramento de Fornecedores</font></b></p>      </td>'
    _cBody += '    <td rowspan="2" align="center" bgcolor="#FFFFFF" height="69" width="23%">'
    _cBody += '      <p> <img width="140" height="32" src="https://www.portalsolar.com.br/wp-content/themes/portalsolar-bootstrap-based/assets/images/logo.png"> </p></td>'
    _cBody += '  </tr>'
    _cBody += '  <tr>'
    _cBody += '    <td width="77%" height="25" bordercolor="#ff9d02" bgcolor="#FFFFFF">'
    _cBody += '      <p align="left">'
    _cBody += '      <font face="Tahoma"><b>Data do Evento:</b><font face="Arial" size="3">'+DtoC(dDataBase) + " - " + Time()+'</font><font face="Arial" size="4"> </font></font></p>      </td>'
    _cBody += '  </tr>'
    _cBody += '<tr>'
    _cBody += '      <td width="77%" height="25" bordercolor="#ff9d02" bgcolor="#FFFFFF">'
    _cBody += '      <p align="left">'
    _cBody += '      <font face="Tahoma"><b>Tipo de Operação : </b><font face="Arial" size="3">Inclusão</font><font face="Arial" size="4"> </font></font></p></td>'
    _cBody += '</tr>'
    _cBody += '  </tbody>'
    _cBody += '</table>'
    _cBody += '<hr>'
    _cBody += '<table bordercolorlight="#FFFFFF" bordercolordark="#FFFFFF" border="3" bordercolor="#ff9d02" width="100%">'
    _cBody += '  <form method="post" action="mailto:%WFMailTo%" name="FrontPage_Form1"></form>'
    _cBody += '   <tbody>'
    _cBody += '    <tr>'
    _cBody += '       <td width="100%" bordercolor="#ff9d02">'
    _cBody += '           <input name="CHAVE" value="%CHAVE%" type="hidden">'
    _cBody += '				<input value="%CFILANT%" name="CFILANT" type="hidden">'
    _cBody += '				<input value="%WF%" name="WF" type="hidden">'
    _cBody += '	  <input value="%WFID%" name="WFID" type="hidden"></td>'
    _cBody += '   </tr>'
    _cBody += '  </tbody>'
    _cBody += '</table>'
    _cBody += '<hr>'
    _cBody += '<table bgcolor="#FFFFFF" border="0" cellspacing="1" width="100%">'
    _cBody += '  <tbody>'
    _cBody += '    <tr>'
    _cBody += '    <td width="100%" align="center" bordercolor="#ff9d02"><b><font color="#666666" size="2" face="Tahoma">Fornecedores Cadastrados</font></b></td>'
    _cBody += '  </tr>'
    _cBody += '  </tbody>'
    _cBody += '</table>'
    _cBody += '<table bgcolor="#FFFFFF" border="1" bordercolor="#ff9d02" cellspacing="1" width="100%">'
    _cBody += '  <tbody>'
    _cBody += '  <tr bordercolor="#ff9d02">'
    _cBody += '    <td width="20%" align="center"><b><font color="#666666" size="1" face="Tahoma">Código</font></b></td>'
    _cBody += '    <td width="20%" align="center"><b><font color="#666666" size="1" face="Tahoma">Loja</font></b></td>'
    _cBody += '    <td width="20%" align="center"><b><font color="#666666" size="1" face="Tahoma">Nome</font></b></td>'
    _cBody += '	   <td width="20%" align="center"><b><font color="#666666" size="1" face="Tahoma">CNPJ/CPF</font></b></td>'
    _cBody += '	   <td width="20%" align="center"><b><font color="#666666" size="1" face="Tahoma">Chave NFE</font></b></td>'
    _cBody += '    </tr>'
    _cBody += '  </tbody><tbody>'
    For ni := 1 To Len(aCadFor)
        _cBody += '  <tr bordercolor="#ff9d02">'
        _cBody += '    <td style="text-align: center;" bgcolor="#FFFFFF" width="20%"><font face="Tahoma" size="1">'+aCadFor[ni][1]+'</font></td>'
        _cBody += '    <td style="text-align: center;" bgcolor="#FFFFFF" width="20%"><font face="Tahoma" size="1">'+aCadFor[ni][2]+'</font></td>'
        _cBody += '    <td style="text-align: center;" bgcolor="#FFFFFF" width="20%"><font face="Tahoma" size="1">'+aCadFor[ni][3]+'</font></td>'
        _cBody += '    <td style="text-align: center;" bgcolor="#FFFFFF" width="20%"><font face="Tahoma" size="1">'+aCadFor[ni][4]+'</font></td>'
        _cBody += '    <td style="text-align: center;" bgcolor="#FFFFFF" width="20%"><font face="Tahoma" size="1">'+aCadFor[ni][5]+'</font></td>'
        _cBody += '  </tr>'
    Next
    _cBody += '  </tbody>'
    _cBody += '</table>'
    _cBody += '<hr>'
    _cBody += '<hr>'
    _cBody += '<table border="0" width="100%">'
    _cBody += '  <tbody>'
    _cBody += '    <tr>'
    _cBody += '      <td bordercolor="#ff9d02">'
    _cBody += '      <p align="right"><font face="Tahoma" size="1">WorkFlow @ Protheus 12</font></p></td>'
    _cBody += '   </tr>'
    _cBody += '  </tbody>'
    _cBody += '</table>'
    _cBody += '</body>'
    _cBody += '</html>'

//  memoWrite("d:\"+Strtran(time(),":","")+".htm",_cBody)  

    ATEnvMail(_cBody,cEmail,cSubject , {} )

/*/{Protheus.doc}'fNotifCad'
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
Static Function fNotifCad(aCadFor)
    Local ni        := 0
    Local cTipo     := ""
    Local _cBody    := ''
    Local cEmail	:= Alltrim(GetMv("OV_CADMAIL",,"emailsedu@gmail.com;luiz.daibert@ovio.com.br"))
    Local cSubject  := "Integrador Sefaz - Cadastro de Fornecedor Incompleto"

    _cBody := ''
    _cBody += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'
    _cBody += '<html>'
    _cBody += '<head>'
    _cBody += '  <meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
    _cBody += '  <meta name="GENERATOR" content="Microsoft FrontPage 6.0">'
    _cBody += '  <meta name="ProgId" content="FrontPage.Editor.Document">'
    _cBody += '  <title>Integrador Sefaz - Cadastro de Fornecedor Incompleto</title>'
    _cBody += '</head>'
    _cBody += '<body>'
    _cBody += ' <table bordercolorlight="#FFFFFF" bordercolordark="#FFFFFF" border="3" bordercolor="#ff9d02" height="79" width="98%">'
    _cBody += '  <tbody>'
    _cBody += '    <tr>'
    _cBody += '     <td width="76%" height="40" align="center" bordercolor="#ff9d02" bgcolor="#FFFFFF">'
    _cBody += '      <p><b><font face="Tahoma" size="5">Integrador Sefaz - Cadastro de Fornecedor Incompleto</font></b></p>      </td>'
    _cBody += '    <td rowspan="2" align="center" bgcolor="#FFFFFF" height="69" width="23%">'
    _cBody += '      <p> <img width="140" height="32" src="https://www.portalsolar.com.br/wp-content/themes/portalsolar-bootstrap-based/assets/images/logo.png"> </p></td>'
    _cBody += '  </tr>'
    _cBody += '  <tr>'
    _cBody += '    <td width="77%" height="25" bordercolor="#ff9d02" bgcolor="#FFFFFF">'
    _cBody += '      <p align="left">'
    _cBody += '      <font face="Tahoma"><b>Ambiente / Data do Evento:</b><font face="Arial" size="3">' + GetEnvServer() + " / " + DtoC(dDataBase) + " - " + Time()+'</font><font face="Arial" size="4"> </font></font></p>      </td>'
    _cBody += '  </tr>'
    _cBody += '<tr>'
    _cBody += '      <td width="77%" height="25" bordercolor="#ff9d02" bgcolor="#FFFFFF">'
    _cBody += '      <p align="left">'
    _cBody += '      <font face="Tahoma"><b>Tipo de Operação:</b><font face="Arial" size="3">Aviso</font><font face="Arial" size="4"> </font></font></p></td>'
    _cBody += '</tr>'
    _cBody += '  </tbody>'
    _cBody += '</table>'
    _cBody += '<hr>'
    _cBody += '<table bordercolorlight="#FFFFFF" bordercolordark="#FFFFFF" border="3" bordercolor="#ff9d02" width="100%">'
    _cBody += '  <form method="post" action="mailto:%WFMailTo%" name="FrontPage_Form1"></form>'
    _cBody += '   <tbody>'
    _cBody += '    <tr>'
    _cBody += '       <td width="100%" bordercolor="#ff9d02">'
    _cBody += '           <input name="CHAVE" value="%CHAVE%" type="hidden">'
    _cBody += '				<input value="%CFILANT%" name="CFILANT" type="hidden">'
    _cBody += '				<input value="%WF%" name="WF" type="hidden">'
    _cBody += '	  <input value="%WFID%" name="WFID" type="hidden"></td>'
    _cBody += '   </tr>'
    _cBody += '  </tbody>'
    _cBody += '</table>'
    _cBody += '<hr>'
    _cBody += '<table bgcolor="#FFFFFF" border="0" cellspacing="1" width="100%">'
    _cBody += '  <tbody>'
    _cBody += '    <tr>'
    _cBody += '    <td width="100%" align="center" bordercolor="#ff9d02"><b><font color="#666666" size="2" face="Tahoma">Fornecedores com cadastro Incompleto</font></b></td>'
    _cBody += '  </tr>'
    _cBody += '  </tbody>'
    _cBody += '</table>'
    _cBody += '<table bgcolor="#FFFFFF" border="1" bordercolor="#ff9d02" cellspacing="1" width="100%">'
    _cBody += '  <tbody>'
    _cBody += '  <tr bordercolor="#ff9d02">'
    _cBody += '    <td width="20%" align="center"><b><font color="#666666" size="1" face="Tahoma">Código</font></b></td>'
    _cBody += '    <td width="20%" align="center"><b><font color="#666666" size="1" face="Tahoma">Loja</font></b></td>'
    _cBody += '    <td width="20%" align="center"><b><font color="#666666" size="1" face="Tahoma">Nome</font></b></td>'
    _cBody += '	   <td width="20%" align="center"><b><font color="#666666" size="1" face="Tahoma">CNPJ/CPF</font></b></td>'
    _cBody += '	   <td width="20%" align="center"><b><font color="#666666" size="1" face="Tahoma">Chave NFE</font></b></td>'
    _cBody += '    </tr>'
    _cBody += '  </tbody><tbody>'
    For ni := 1 To Len(aLogFor)
        _cBody += '  <tr bordercolor="#ff9d02">'
        _cBody += '    <td style="text-align: center;" bgcolor="#FFFFFF" width="20%"><font face="Tahoma" size="1">'+aLogFor[ni][1]+'</font></td>'
        _cBody += '    <td style="text-align: center;" bgcolor="#FFFFFF" width="20%"><font face="Tahoma" size="1">'+aLogFor[ni][2]+'</font></td>'
        _cBody += '    <td style="text-align: center;" bgcolor="#FFFFFF" width="20%"><font face="Tahoma" size="1">'+aLogFor[ni][3]+'</font></td>'
        _cBody += '    <td style="text-align: center;" bgcolor="#FFFFFF" width="20%"><font face="Tahoma" size="1">'+aLogFor[ni][4]+'</font></td>'
        _cBody += '    <td style="text-align: center;" bgcolor="#FFFFFF" width="20%"><font face="Tahoma" size="1">'+aLogFor[ni][5]+'</font></td>'
        _cBody += '  </tr>'
    Next
    _cBody += '  </tbody>'
    _cBody += '</table>'
    _cBody += '<hr>'
    _cBody += '<hr>'
    _cBody += '<table border="0" width="100%">'
    _cBody += '  <tbody>'
    _cBody += '    <tr>'
    _cBody += '      <td bordercolor="#ff9d02">'
    _cBody += '      <p align="right"><font face="Tahoma" size="1">WorkFlow @ Protheus 12</font></p></td>'
    _cBody += '   </tr>'
    _cBody += '  </tbody>'
    _cBody += '</table>'
    _cBody += '</body>'
    _cBody += '</html>'

    //memoWrite("d:\"+Strtran(time(),":","")+".htm",_cBody)

    ATEnvMail(_cBody,cEmail,cSubject , {} )

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
Static Function ATEnvMail(cHtml,cEmail,cSubject,aAnexos)
    Local nI:=1
    Local lResult    	:= .T.
    Local cError     	:= ""
    Local cTo      		:= ""
    Local lAuth    		:= GetMv("OV_RELAUTH",,.T.)
    Local nTimeout		:= 240
    Local cMailConta	:= Alltrim(GetMv("OV_RELACNT",,"erp.portalsolar@gmail.com"))
    Local cMailServer	:= Alltrim(GetMv("OV_RELSERV",,"smtp.gmail.com:587"))
    Local cMailSenha 	:= Alltrim(GetMv("OV_RELPSW",,"PortalSolar2021"))
    Local cUser		   	:= Left(cMailConta, At("@", cMailConta)-1)
    Local cFileSrv      := "\pedidos"
    Local cAnexos		:= ""

    Default aAnexos     := {}

    cTo	:= RTrim(cEmail)

    If !Empty(cMailServer) .And. !Empty(cMailConta) .And. !Empty(cMailSenha)

        CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lResult

        If lResult
            If lAuth
                lResult := MailAuth(cMailConta,cMailSenha)
            EndIf
            If lResult
                If Len(aAnexos)>0
                    cAnexos:=''
                    For nI:=1 to Len(aAnexos)
                        CpyT2S( aAnexos[nI][1] , cFileSrv , .F. )
                        cAnexos += If(!Empty(cAnexos),",","")+aAnexos[nI][2]
                    Next
                Endif

                SEND MAIL  				;
                    FROM       cMailConta	;
                    TO		   cTo			;
                    SUBJECT	   cSubject		;
                    BODY	   cHtml		;
                    ATTACHMENT cAnexos      ;
                    RESULT	   lResult
                If !lResult
                    GET MAIL ERROR cError
                    cError := cError+".Falha no Envio do e-mail."
                    If (!lSChedule)
                        ALERT(cError)
                    Else
                        Conout(cError)
                    Endif
                EndIf
            Else
                //Erro na autenticacao da conta
                GET MAIL ERROR cError
                cError := cError+".Falha no Envio do e-mail."
                If (!lSChedule)
                    ALERT(cError)
                Else
                    Conout(cError)
                Endif
            Endif
        Else
            GET MAIL ERROR cError
            cError := cError+".Falha no Envio do e-mail."
            If (!lSChedule)
                ALERT(cError)
            Else
                Conout(cError)
            Endif
        Endif
    Endif

Return()

/*/{Protheus.doc}'fMoveArq'
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
Static Function fMoveArq(cFolderBx)

    Local aFiles  := Directory(cFolderBx+"*.xml", "D" , , .F. , 2 )
    Local nFiles  := 0

    Private cDir        := Alltrim(GetMv("MV_OVINN",,"\xml\inn\"))
    Private cDirRes     := Alltrim(GetMv("MV_OVRES",,"\xml\res\"))
    Private cDirLog     := Alltrim(GetMv("MV_OVLOG",,"\xml\log\"))
    Private cDirErr     := Alltrim(GetMv("MV_OVERR",,"\xml\err\"))
    Private cDirMan     := Alltrim(GetMv("MV_OVMAN",,"\xml\manifesto\"))

    If (lSChedule)
        Conout("["+cThread+"] - Empresa: "+cEmp+" Filial: "+cFil+" fMoveArq - Time : "+Time() )
    Endif


    if Substr(cDir,Len(cDir),1)<>"\"
        cDir := cDir+"\"
    Endif

    if Substr(cDirRes,Len(cDirRes),1)<>"\"
        cDirRes := cDirRes+"\"
    Endif

    if Substr(cDirLog,Len(cDirLog),1)<>"\"
        cDirLog := cDirLog+"\"
    Endif

    if Substr(cDirErr,Len(cDirErr),1)<>"\"
        cDirErr := cDirErr+"\"
    Endif

    cDirBx      := cDirLog

    Conout("["+cThread+"] - Movendo xmls da pasta : "+cFolderBx +" para a pasta "+ cDirLog )

    If Len(aFiles)>0
        For nFiles := 1 To Len(aFiles)
            If !file(cDirLog+aFiles[nFiles][1])
                lCpy := CpyT2S( cFolderBx+aFiles[nFiles][1] , cDirLog , .F. )
                If !lCpy
                    If (!lSChedule)
                        Aviso("Aviso","Erro ao copiar arquivo "+cFolderBx+aFiles[nFiles][1]+ " para pasta " + cDirLog + " - fError " + Str(Ferror()))
                    Else
                        conout("Erro ao copiar arquivo para pasta - ferror " + Str(Ferror()))
                    Endif
                Endif
            Endif
        Next
    else
        Aviso("Atenção","Não foram encontrados arquivos para importação na pasta informada.",{"Ok"})
    Endif

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
Static Function AtuStatus(aRet,cTpEvento)

    Local aAreas	:= {}

    Local cStat		:= "0"
    Local nX		:= 0

    If (lSChedule)
        Conout("["+cThread+"] - Empresa: "+cEmp+" Filial: "+cFil+" AtuStatus - Time : "+Time() )
    Endif

    If cTpEvento $ '210200'
        cStat:= "1"  //Confirmada operação
    ElseIf cTpEvento $ '210220'
        cStat:= "2"  //Desconhecimento da Operação
    ElseIf cTpEvento $ '210240'
        cStat:= "3"  //Operação não Realizada
    ElseIf cTpEvento $ '210210'
        cStat:= "4"  //Ciência da operação
    EndIf

    If Len(aRet) > 0
        aAreas := GetArea()
        For nX:=1 to Len(aRet)
            C00->(DbSetOrder(1))
            If C00->(DBSEEK(xFilial("C00")+aRet[nX]))
                RecLock("C00")
                C00->C00_STATUS := cStat
                C00->C00_CODEVE := "2"
                MsUnlock()
            EndIf
        Next
        RestArea(aAreas)
    EndIf

Return

/*/{Protheus.doc}'fSelBrowse'
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
Static Function fSelBrowse()

    Local cTitulo := "Integrador Xmls"

    Private oTela

    oFontA := TFont():New( ,, -16, .T., .T.,,,,, )
    oFontB := TFont():New( ,, -12, .T., .T.,,,,, )

    DEFINE MSDIALOG oTela FROM 0, 0 To 350,500 Title cTitulo  Of GetWndDefault() PIXEL

    oTPane1 := TPanel():New(0,0,"",oTela,NIL,.T.,.F.,NIL,NIL,0,25,.T.,.T.)
    oTPane1:Align := CONTROL_ALIGN_TOP

    @ 010 ,005 Say "Selecione uma opção para proseguir." Size 450,12  Of oTPane1 PIXEL COLOR CLR_BLUE FONT oFontA

    oTPane2 := TPanel():New(0,0,"",oTela,NIL,.T.,.F.,NIL,NIL,0,0,.T.,.F.)
    oTPane2:Align := CONTROL_ALIGN_ALLCLIENT

    oCheckA  := TCheckBox():New( 021, 025, "Efetuar download Xmls disponiveis na Sefaz"     , bSetGet( lCheckA ), oTPane2, 160, 350,, { |v,w,x| SelecA( oCheckA, oCheckD ) }, oFontB,,,,, .T.,,, { || lWhenA } )
    oCheckB  := TCheckBox():New( 041, 025, "Efetuar download Xml pela chave Eletronica"     , bSetGet( lCheckB ), oTPane2, 160, 350,, { |v,w,x| SelecB( oCheckB, oCheckD ) }, oFontB,,,,, .T.,,, { || lWhenB } )
    oCheckC  := TCheckBox():New( 061, 025, "Enviar Xml(s) selecionado(s) para processamento", bSetGet( lCheckC ), oTPane2, 160, 350,, { |v,w,x| SelecC( oCheckC, oCheckD ) }, oFontB,,,,, .T.,,, { || lWhenC } )

    oTPane4:= TPanel():New(0, 0, "", oTela, NIL, .T., .F., NIL, NIL,0 , 25 , .T., .F. )
    oTPane4:Align:= CONTROL_ALIGN_BOTTOM


    oCheckD := TCheckBox():New(010,005,'Informar local para download',bSetGet( lCheckD ) , oTPane4 ,250,100 ,,,oFontB,,,,,.T.,,,)

    Activate MsDialog oTela Centered On Init EnchoiceBar(oTela , { || iif(!lCheckA .And. !lCheckB .And. !lCheckC,Aviso("Atenção","Selecione uma opção!",{"Ok"}),oTela:End()) },{|| lSair := .T. , oTela:End() } )

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
Static Function SelecA( oCheck As Object, oCheckD As Object )

    If lCheckA
        lCheckB := .F.
        lCheckC := .F.
    EndIf

    oCheckA:CtrlRefresh()
    oCheckB:CtrlRefresh()
    oCheckC:CtrlRefresh()

    oCheckA:SetFocus()
    oCheckB:SetFocus()
    oCheckC:SetFocus()

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
Static Function SelecB( oCheck As Object, oCheckD As Object )

    if lCheckB
        lCheckA := .F.
        lCheckC := .F.
    EndIf

    oCheckA:CtrlRefresh()
    oCheckB:CtrlRefresh()
    oCheckC:CtrlRefresh()

    oCheckA:SetFocus()
    oCheckB:SetFocus()
    oCheckC:SetFocus()

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
Static Function SelecC( oCheck As Object, oCheckD As Object )

    if lCheckC
        lCheckA := .F.
        lCheckB := .F.
    EndIf

    oCheckA:CtrlRefresh()
    oCheckB:CtrlRefresh()
    oCheckC:CtrlRefresh()

    oCheckA:SetFocus()
    oCheckB:SetFocus()
    oCheckC:SetFocus()

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
Static Function fBrowLog( oPanel As Object )

    Local nX as Numeric
    Local aSize  	:= MsAdvSize()

    n1  := 1
    n2  := n1+1
    n3  := n2+1
    n4  := n3+1
    n5  := n4+1
    n6  := n5+1
    n7  := n6+1
    n8  := n7+1
    n9  := n8+1
    n10 := n9+1

    aAdd(aHdr,{"Filial","LOG_FILIAL","",2,0,;
        "                                                                                                                                ",;
        "x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ",;
        "C","      "," "})

    aAdd(aHdr,{"NSU INICIAL","LOG_NSUINI","",15,0,;
        "                                                                                                                                ",;
        "x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ",;
        "C","      "," "})

    aAdd(aHdr,{"NSU PROCESSADO","LOG_NSUPRC","",15,0,;
        "                                                                                                                                ",;
        "x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ",;
        "C","      "," "})

    aAdd(aHdr,{"NSU FINAL","LOG_NSUFIM","",15,0,;
        "                                                                                                                                ",;
        "x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ",;
        "C","      "," "})

    aAdd(aHdr,{"CHAVE NFE","LOG_CHAVE","", 44 , 0,;
        "                                                                                                                                ",;
        "x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ",;
        "C","      "," "})

    aAdd(aHdr,{"XML TIPO","LOG_TIPO","",15,0,;
        "                                                                                                                                ",;
        "x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ",;
        "C","      "," "})

    aAdd(aHdr,{"OBSERVAÇÃO","LOG_OBS","",250,0,;
        "                                                                                                                                ",;
        "x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ",;
        "C","      "," "})


    aAdd(aHdr,{"STATUS","LOG_STATUS","",1,0,;
        "                                                                                                                                ",;
        "x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ",;
        "C","      "," "})

    aAdd(aHdr,{"ITEM DO LOTE","LOG_ITEM","@E 9,999,999",12,0,;
        "                                                                                                                                ",;
        "x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ",;
        "N","      "," "})

    aAdd(aHdr,{"Rotina","LOG_ROTINA","",20,0,;
        "                                                                                                                                ",;
        "x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ",;
        "C","      "," "})


    cTitulo := "Log de Processamento"
    oLog    := Nil

    DEFINE MSDIALOG oLog FROM 0, 0 To aSize[6],aSize[5] Title cTitulo  Of GetWndDefault() PIXEL

    oPnLog := TPanel():New(0,0,"",oLog,NIL,.T.,.F.,NIL,NIL,0,0,.T.,.F.)
    oPnLog:Align := CONTROL_ALIGN_ALLCLIENT

    oPnLog2:= TPanel():New(0, 0, "", oLog, NIL, .T., .F., NIL, NIL,0 , 10 , .T., .F. )
    oPnLog2:Align:= CONTROL_ALIGN_BOTTOM


    oBrowse:=FWBrowse():New()
    oBrowse:SetOwner(oPnLog)
    oBrowse:SetDataArray()
    oBrowse:SetArray(aLog)

    oBrowse:AddLegend('oBrowse:odata:aarray[oBrowse:At()][aScan(aHdr, {|x| Alltrim(x[2]) == "LOG_STATUS"})] == "B"', "GREEN"  , "XML Baixado")
    oBrowse:AddLegend('oBrowse:odata:aarray[oBrowse:At()][aScan(aHdr, {|x| Alltrim(x[2]) == "LOG_STATUS"})] <> "B"', "RED"	  , "XML Não Baixado")

    For nX := 1 to Len(aHdr)
        If nX <= n9 .And. !(Alltrim(aHdr[nX][2]) $ "LOG_STATUS")
            oColBrwLog := FWBrwColumn():New()
            &("oColBrwLog:SetData({|| aLog[oBrowse:At(), n"+Alltrim(Str(nX))+" ]})")
            &("oColBrwLog:SetTitle( (aHdr[n"+Alltrim(Str(nX))+"][1]) )")
            oBrowse:SetColumns({oColBrwLog})
        EndIf
    Next nX

    oBrowse:Activate()

    Activate MsDialog oLog Centered

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
Static Function fBxChvCte(aDownCte)

    Local lContinua As Logical
    Local cUrlink   As String
    Local nPosNSU   As Numeric
    Local nFiles    As Numeric
    Local lVerbose  As Logical

    Private oXmlInn   As Object
    Private oWsdlXml  As Object

    lVerbose  := GetMv("EV_VERBOSE",,.F.)

    cUrlink   := Alltrim(SuperGetMv("MV_CTEXWSD",.F.,"https://www1.cte.fazenda.gov.br/CTeDistribuicaoDFe/CTeDistribuicaoDFe.asmx?WSDL"))

    For nFiles := 1 To Len(aDownCte)

        lContinua := .T.
        cChaveNFE := Alltrim(aDownCte[nFiles][2])
        cProcNSU  := Alltrim(aDownCte[nFiles][3])

        nPosNSU   := aScan(aLog,{|x|  Alltrim(x[3])==Alltrim(cProcNSU)})

        If nPosNSU>0
            FreeObj(oWsdlXml)

            oWsdlXml := TWsdlManager():New()
            oWsdlXml:cSSLCACertFile := Alltrim(SuperGetMV("MV_XMLXCA",  .F., "\certs\000001_ca.pem"))
            oWsdlXml:cSSLCertFile   := Alltrim(SuperGetMV("MV_XMLXCER", .F., "\certs\000001_cert.pem"))
            oWsdlXml:cSSLKeyFile    := Alltrim(SuperGetMV("MV_XMLXKEY", .F., "\certs\000001_key.pem"))
            oWsdlXml:cSSLKeyPwd     := Alltrim(SuperGetMV("MV_XMLXPSW", .F., "1234"))
            oWsdlXml:nSSLVersion    := Alltrim(SuperGetMV("MV_XMLXPRO", .F., "0"))
            oWsdlXml:lSSLInsecure   := SuperGetMV("MV_XMSSLIN", .F., .T.)
            oWsdlXml:nTimeout       := 120
            oWsdlXml:lVerbose       := lVerbose
            oWsdlXml:lProcResp      := .F.

            lRet := oWsdlXml:ParseURL(cUrlink)
            If !lRet
                If (!lSChedule)
                    Aviso("Aviso","[IXMLINTEG] - Erro ParseURL: " + oWsdlXml:cError,{"Ok"})
                    aLog[nPosNSU][5] := cChaveNFE
                    aLog[nPosNSU][7] := aLog[Len(aLog)][7] + "Xml CTE erro parser|"
                    aLog[nPosNSU][8] := "N"
                Else
                    ConOut("[XMLINTEG] - Erro ParseURL: " + oWsdlXml:cError)
                Endif
                lContinua := .F.
            EndIf

            Conout("["+cThread+"] - Conexao com Sefaz realizada para download do XML completo - " + Time() )

            If lContinua

                lRet := oWsdlXml:SetOperation("cteConsultaCT")
                If !lRet
                    If (!lSChedule)
                        Aviso("Aviso","[XMLINTEG] - Erro SetOperation: " + oWsdlXml:cError,{"Ok"})
                    Else
                        ConOut("[IXMLINTEG] - Erro SetOperation: " + oWsdlXml:cError)
                    Endif
                    lContinua := .F.
                Endif
            Endif

            Conout("["+cThread+"] - Manifestacao de Interesse realizada para download do XML completo - " + Time() )

            If lContinua

                cMsg := '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:ctec="http://www.portalfiscal.inf.br/cte/wsdl/CteConsulta">' + CRLF
                cMsg += '<soap:Header>'                                                                                                               + CRLF
                cMsg += '    <ctec:cteCabecMsg>'                                                                                                      + CRLF
                cMsg += '        <ctec:cUF>'+cUfAutor+'</ctec:cUF>'                                                                                   + CRLF
                cMsg += '        <ctec:versaoDados>'+cVersaoCte+'</ctec:versaoDados>'                                                                 + CRLF
                cMsg += '    </ctec:cteCabecMsg>'                                                                                                     + CRLF
                cMsg += '</soap:Header>'                                                                                                              + CRLF
                cMsg += '<soap:Body>'                                                                                                                 + CRLF
                cMsg += '    <ctec:cteDadosMsg>'                                                                                                      + CRLF
                cMsg += '        <consSitCTe xmlns="http://www.portalfiscal.inf.br/cte versao=3.00">'                                                 + CRLF
                cMsg += '            <tpAmb>'+cTpAmb+'</tpAmb>'                                                                                       + CRLF
                cMsg += '            <xServ>CONSULTAR</xServ>'                                                                                        + CRLF
                cMsg += '            <chCTe>'+cChaveNFE+'</chCTe>'                                                                                    + CRLF
                cMsg += '        </consSitCTe>'                                                                                                       + CRLF
                cMsg += '    </ctec:cteDadosMsg>'                                                                                                     + CRLF
                cMsg += '</soap:Body>'                                                                                                                + CRLF
                cMsg += '</soap:Envelope>'                                                                                                            + CRLF


                lRet := oWsdlXml:SendSoapMsg(cMsg)
                If !lRet
                    If (!lSChedule)
                        Aviso("Aviso","[XMLINTEG] - Erro SendSoapMsg: " + oWsdlXml:cError,{"Ok"})
                        cErr := oWsdlXml:GetSoapResponse()
                        Alert(cErr)
                    Else
                        ConOut("[XMLINTEG] - Erro SendSoapMsg: " + oWsdlXml:cError)
                        ConOut("[XMLINTEG] - Erro SendSoapMsg FaultCode: " + oWsdlXml:cFaultCode)
                    Endif
                    lContinua := .F.
                EndIf

                If lContinua
                    cMsgRet := oWsdlXml:GetSoapResponse()

                    FreeObj(oXmlInn)

                    oXmlInn := XmlParser(cMsgRet, "_", @cError, @cWarning)

                    Conout("["+cThread+"] - Obtendo XML completo para download - " + Time() )

                    If (Type("oXmlInn:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP") != "U")
                        If (Type("oXmlInn:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:TEXT") == "C")

                            cXmlGZip := oXmlInn:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:TEXT

                            cUnXML    := ""
                            nTamanho  := Len(cXmlGZip)
                            cDecode64 := Decode64(cXmlGZip)
                            lRet      := GzStrDecomp(cDecode64, nTamanho, @cUnXML)

                            If lRet
                                if !empty(cFolderBx)
                                    cDirBx := cFolderBx
                                Else
                                    cDirBx := cDir
                                Endif
                                dbSelectArea("SDS")
                                dbSetOrder(2)//DS_FILIAL+DS_CHAVENF
                                If !dbSeek(xFilial("SDS") + Padr(cChaveNFE,TamSx3("DS_CHAVENF")[1] ) )
                                    If !File(cDirBx+"cte"+cChaveNFE+".xml")
                                        nLenUnXML := Len( cUnXML )
                                        nHandle := FCreate( cDirBx+"cte"+cChaveNFE+".xml" , 0 , , .T. )
                                        if nHandle = -1
                                            If (!lSChedule)
                                                Aviso("Aviso","Erro ao criar arquivo "+cDirBx+"cte"+cChaveNFE+".xml"+ " - fError " + Str(Ferror()))
                                            Else
                                                conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
                                            Endif
                                        else
                                            FWrite( nHandle, cUnXML, nLenUnXML )
                                            FClose( nHandle )
                                            nArqXml++
                                            if cDirBx<>cDir
                                                CpyT2S( cDirBx+"cte"+cChaveNFE+".xml" , cDir , .F. )
                                            endif
                                        endif
                                    Endif
                                Endif

                                Conout("["+cThread+"] - Download do XML completo realizado - " + Time() )

                                oXmlFim := XmlParser(cUnXML, "_", @cError, @cWarning)

                                If ! Empty(cWarning)
                                    If (!lSChedule)
                                        Aviso("Aviso", "cWarningr: " + cWarning , {"Ok"} )
                                    Else
                                        ConOut("[IXMLINTEG] - Alert cWarning: " + cWarning)
                                    Endif
                                    lContinua := .F.
                                EndIf

                                If ! Empty(cError)
                                    If (!lSChedule)
                                        Aviso("Aviso", "Erro cError:" + cError , {"Ok"} )
                                    Else
                                        ConOut("[XMLINTEG] - Erro cError: " + cError)
                                    Endif
                                    lContinua := .F.
                                EndIf

                                If lContinua
                                    Conout("["+cThread+"] - Ciencia da Operacao gravada no Manifesto do Destinaria - " + Time() )
                                    If XmlChildEx( oXmlfim , "_CTEPROC" ) != Nil
                                        fTrataFor(.T.)
                                    Else
                                        fTrataFor(.F.)
                                    Endif
                                Endif
                            Endif
                        Endif
                    Else
                        If (Type("oXmlInn:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_cStat:TEXT") != "U")
                            Conout("["+cThread+"] - Xml " + cChaveNFE + " nao sera processado, status : " + oXmlInn:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_cStat:TEXT  )
                            LjWriteLog(cDirErr+cXmlNSU+".log", "Chave : "+cChaveNFE+" CSTAT: "+oXmlInn:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_cStat:TEXT )
                        Endif
                    EndIf
                Endif
            Endif
        Endif
    Next

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
Static Function fBxChvNfe(aDownNfe)

    Local lContinua As Logical
    Local cUrlink   As String
    Local nPosNSU   As Numeric
    Local nFiles    As Numeric
    Local lVerbose  As Logical

    Private oXmlInn   As Object
    Private oWsdlXml  As Object

    lVerbose  := GetMv("EV_VERBOSE",,.F.)

    cUrlink   := Alltrim(SuperGetMv("MV_XMLXWS1",.F.,"https://www1.nfe.fazenda.gov.br/NFeDistribuicaoDFe/NFeDistribuicaoDFe.asmx?WSDL"))

    For nFiles := 1 To Len(aDownNfe)

        lContinua := .T.
        cChaveNFE := Alltrim(aDownNfe[nFiles][2])
        cProcNSU  := Alltrim(aDownNfe[nFiles][3])

        nPosNSU   := aScan(aLog,{|x|  Alltrim(x[3])==Alltrim(cProcNSU)})

        If nPosNSU>0

            FreeObj(oWsdlXml)

            oWsdlXml := TWsdlManager():New()
            oWsdlXml:cSSLCACertFile := Alltrim(SuperGetMV("MV_XMLXCA",  .F., "\certs\000001_ca.pem"))
            oWsdlXml:cSSLCertFile   := Alltrim(SuperGetMV("MV_XMLXCER", .F., "\certs\000001_cert.pem"))
            oWsdlXml:cSSLKeyFile    := Alltrim(SuperGetMV("MV_XMLXKEY", .F., "\certs\000001_key.pem"))
            oWsdlXml:cSSLKeyPwd     := Alltrim(SuperGetMV("MV_XMLXPSW", .F., "1234"))
            oWsdlXml:nSSLVersion    := Alltrim(SuperGetMV("MV_XMLXPRO", .F., "0"))
            oWsdlXml:lSSLInsecure   := SuperGetMV("MV_XMSSLIN", .F., .T.)
            oWsdlXml:nTimeout       := 120
            oWsdlXml:lVerbose       := lVerbose
            oWsdlXml:lProcResp      := .F.

            lRet := oWsdlXml:ParseURL(cUrlink)
            If !lRet
                If (!lSChedule)
                    Aviso("Aviso","[IXMLINTEG] - Erro ParseURL: " + oWsdlXml:cError,{"Ok"})
                Else
                    ConOut("[XMLINTEG] - Erro ParseURL: " + oWsdlXml:cError)
                Endif
                aLog[nPosNSU][5] := cChaveNFE
                aLog[nPosNSU][7] := aLog[Len(aLog)][7] + "Erro ao conectar Sefaz Bx pela Chave|"
                aLog[nPosNSU][8] := "N"
                lContinua := .F.
            EndIf

            Conout("["+cThread+"] - Conexao com Sefaz realizada para download do XML completo - " + Time() )

            If lContinua

                lRet := oWsdlXml:SetOperation("nfeDistDFeInteresse")
                If !lRet
                    If (!lSChedule)
                        Aviso("Aviso","[XMLINTEG] - Erro SetOperation: " + oWsdlXml:cError,{"Ok"})
                    Else
                        ConOut("[IXMLINTEG] - Erro SetOperation: " + oWsdlXml:cError)
                    Endif
                    aLog[nPosNSU][5] := cChaveNFE
                    aLog[nPosNSU][7] := aLog[Len(aLog)][7] + "Erro ao conectar Sefaz Bx pela Chave|"
                    aLog[nPosNSU][8] := "N"
                    lContinua := .F.
                EndIf

                Conout("["+cThread+"] - Manifestacao de Interesse realizada para download do XML completo - " + Time() )

                If lContinua
                    cMsg := '<soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope">'                        + CRLF
                    cMsg += '    <soapenv:Header/>'                                                                             + CRLF
                    cMsg += '    <soapenv:Body>'                                                                                + CRLF
                    cMsg += '        <nfeDistDFeInteresse xmlns="http://www.portalfiscal.inf.br/nfe/wsdl/NFeDistribuicaoDFe">'  + CRLF
                    cMsg += '            <nfeDadosMsg>'                                                                         + CRLF
                    cMsg += '                <distDFeInt xmlns="http://www.portalfiscal.inf.br/nfe" versao="1.01">'             + CRLF
                    cMsg += '                    <tpAmb>'+cTpAmb+'</tpAmb>'                                                     + CRLF
                    cMsg += '                     <cUFAutor>'+cUfAutor+'</cUFAutor>'                                            + CRLF
                    cMsg += '                     <CNPJ>'+cCNPJEmp+'</CNPJ>'                                                    + CRLF
                    cMsg += '                     <consChNFe>'                                                                  + CRLF
                    cMsg += '                         <chNFe>'+cChaveNFE+'</chNFe>'                                             + CRLF
                    cMsg += '                     </consChNFe>'                                                                 + CRLF
                    cMsg += '                </distDFeInt>'                                                                     + CRLF
                    cMsg += '            </nfeDadosMsg>'                                                                        + CRLF
                    cMsg += '        </nfeDistDFeInteresse>'                                                                    + CRLF
                    cMsg += '    </soapenv:Body>'                                                                               + CRLF
                    cMsg += '</soapenv:Envelope>'                                                                               + CRLF

                    lRet := oWsdlXml:SendSoapMsg(cMsg)
                    If !lRet
                        If (!lSChedule)
                            Aviso("Aviso","[XMLINTEG] - Erro SendSoapMsg: " + oWsdlXml:cError,{"Ok"})
                            cErr := oWsdlXml:GetSoapResponse()
                            Alert(cErr)
                        Else
                            ConOut("[XMLINTEG] - Erro SendSoapMsg: " + oWsdlXml:cError)
                            ConOut("[XMLINTEG] - Erro SendSoapMsg FaultCode: " + oWsdlXml:cFaultCode)
                        Endif
                        lContinua := .F.
                        aLog[nPosNSU][5] := cChaveNFE
                        aLog[nPosNSU][7] := aLog[Len(aLog)][7] + "Erro ao conectar Sefaz Bx pela Chave|"
                        aLog[nPosNSU][8] := "N"
                    EndIf

                    cError   :=""
                    cWarning := ""

                    If lContinua

                        cMsgRet := oWsdlXml:GetSoapResponse()

                        FreeObj(oXmlInn)

                        oXmlInn := XmlParser(cMsgRet, "_", @cError, @cWarning)

                        If !Empty(cWarning)
                            If (!lSChedule)
                                Aviso("Aviso", "cWarning: " + cWarning , {"Ok"} )
                            Else
                                ConOut("[XMLINTEG] - cWarning: " + cWarning)
                            Endif
                            lContinua := .F.
                            aLog[nPosNSU][5] := cChaveNFE
                            aLog[nPosNSU][7] := aLog[Len(aLog)][7] + "Erro no parser Sefaz Bx pela Chave|"
                            aLog[nPosNSU][8] := "N"
                        EndIf

                        If !Empty(cError)
                            If (!lSChedule)
                                Aviso("Aviso", "Erro cError:" + cError , {"Ok"} )
                            Else
                                ConOut("[XMLINTEG] - Erro cError: " + cError)
                            Endif
                            lContinua := .F.
                            aLog[nPosNSU][5] := cChaveNFE
                            aLog[nPosNSU][7] := aLog[Len(aLog)][7] + "Erro no parser Sefaz Bx pela Chave|"
                            aLog[nPosNSU][8] := "N"
                        EndIf
                    Endif

                    If lContinua

                        Conout("["+cThread+"] - Obtendo XML completo para download - " + Time() )

                        If (Type("oXmlInn:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP") != "U")
                            If (Type("oXmlInn:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:TEXT") == "C")

                                cXmlGZip := oXmlInn:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:TEXT

                                cUnXML    := ""
                                nTamanho  := Len(cXmlGZip)
                                cDecode64 := Decode64(cXmlGZip)
                                lRet      := GzStrDecomp(cDecode64, nTamanho, @cUnXML)

                                If lRet
                                    if !empty(cFolderBx)
                                        cDirBx := cFolderBx
                                    Else
                                        cDirBx := cDir
                                    Endif

                                    dbSelectArea("SDS")
                                    dbSetOrder(2)//DS_FILIAL+DS_CHAVENF
                                    If !dbSeek(xFilial("SDS") + Padr(cChaveNFE,TamSx3("DS_CHAVENF")[1] ) )
                                        If !File(cDirBx+"nfe"+cChaveNFE+".xml")
                                            If lContinua

                                                Conout("["+cThread+"] - Download do XML completo realizado - " + Time() )

                                                FreeObj(oXmlFim)

                                                oXmlFim := XmlParser(cUnXML, "_", @cError, @cWarning)

                                                If ! Empty(cWarning)
                                                    If (!lSChedule)
                                                        Aviso("Aviso", "cWarningr: " + cWarning , {"Ok"} )
                                                    Else
                                                        ConOut("[IXMLINTEG] - Alert cWarning: " + cWarning)
                                                    Endif
                                                    lContinua := .F.
                                                EndIf

                                                If ! Empty(cError)
                                                    If (!lSChedule)
                                                        Aviso("Aviso", "Erro cError:" + cError , {"Ok"} )
                                                    Else
                                                        ConOut("[XMLINTEG] - Erro cError: " + cError)
                                                    Endif
                                                    lContinua := .F.
                                                EndIf

                                                If lContinua
                                                    If XmlChildEx( oXmlfim , "_RESEVENTO" ) != Nil .Or.;
                                                            XmlChildEx( oXmlfim , "_RESNFE" ) != Nil .Or.;
                                                            XmlChildEx( oXmlfim , "_PROCEVENTONFE" ) != Nil .Or.;
                                                            XmlChildEx( oXmlfim , "PROCNFE" ) != Nil

                                                        lContinua := .F.
                                                    Endif
                                                Endif
                                            Endif

                                            If lContinua
                                                nLenUnXML := Len( cUnXML )
                                                nHandle := FCreate( cDirBx+"nfe"+cChaveNFE+".xml" , 0 , , .T. )
                                                if nHandle = -1
                                                    lContinua := .F.
                                                    aLog[nPosNSU][5] := cChaveNFE
                                                    aLog[nPosNSU][7] := aLog[Len(aLog)][7] + "Erro ao tentar gravar Xml na pasta|"
                                                    aLog[nPosNSU][8] := "N"
                                                    If (!lSChedule)
                                                        Aviso("Aviso","Erro ao criar arquivo "+cDirBx+"nfe"+cChaveNFE+".xml"+ " - fError " + Str(Ferror()))
                                                    Else
                                                        conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
                                                    Endif
                                                else
                                                    FWrite( nHandle, cUnXML, nLenUnXML )
                                                    FClose( nHandle )

                                                    aLog[nPosNSU][5] := cChaveNFE
                                                    aLog[nPosNSU][7] := aLog[Len(aLog)][7] + "Xml gravado com sucesso na pasta"+cDirBx+"|"
                                                    aLog[nPosNSU][8] := "B"

                                                    dbSelectArea("C00")
                                                    dbSetOrder(1) //FILIAL + CHAVE
                                                    If dbSeek( xFilial("C00") + Padr(cChaveNFE,TamSX3("C00_CHVNFE")[1]) )
                                                        Reclock("C00",.F.)
                                                        C00->C00_XDOWN := 'S'
                                                        MsUnlock()
                                                    Endif
                                                    nArqXml++
                                                    if cDirBx<>cDir
                                                        CpyT2S( cDirBx+"nfe"+cChaveNFE+".xml" , cDir , .F. )
                                                    endif
                                                    If XmlChildEx( oXmlfim , "_CTEPROC" ) != Nil
                                                        fTrataFor(.T.)
                                                    Else
                                                        fTrataFor(.F.)
                                                    Endif
                                                endif
                                            Endif

                                        Else
                                            aLog[nPosNSU][5] := cChaveNFE
                                            aLog[nPosNSU][7] := aLog[Len(aLog)][7] + "Xml existente na pasta "+cDirBx+"|"
                                            aLog[nPosNSU][8] := "N"
                                            lContinua := .F.
                                        Endif
                                    Else
                                        aLog[nPosNSU][5] := cChaveNFE
                                        aLog[nPosNSU][7] := aLog[Len(aLog)][7] + "Chave existente na SDS|"
                                        aLog[nPosNSU][8] := "N"
                                        lContinua := .F.
                                    Endif
                                Else
                                    aLog[nPosNSU][5] := cChaveNFE
                                    aLog[nPosNSU][7] := aLog[Len(aLog)][7] + "Erro ao descompactar arquivo enviado pela sefaz|"
                                    aLog[nPosNSU][8] := "N"
                                Endif
                            Else
                                aLog[nPosNSU][5] := cChaveNFE
                                aLog[nPosNSU][7] := aLog[Len(aLog)][7] + "Não enviado DocZip Sefaz, bx pela chave|"
                                aLog[nPosNSU][8] := "N"
                            Endif
                        Else
                            aLog[nPosNSU][5] := cChaveNFE
                            aLog[nPosNSU][7] := aLog[Len(aLog)][7] + "Não enviado DocZip Sefaz, bx pela chave|"
                            aLog[nPosNSU][8] := "N"
                        EndIf
                    Endif
                Endif
            Endif
        Endif
    Next

Return
