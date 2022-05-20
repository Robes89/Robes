#Include "Totvs.Ch"
#Include "topconn.Ch"
#Include "Restful.Ch"
#INCLUDE "FILEIO.CH"

Static aHdlLock  := {}
//Static bFileLock := {|| MakeDir(GetMv("TI_VGMLOCK",,"\lockTRANSPOFRETE\")), Alltrim(GetMv("TI_VGMLOCK",,"\lockTRANSPOFRETE\")) + "SRV" + Alltrim(cIdServ) + ".LCK" }
Static bFileLock := {|| MakeDir("\lockTRANSPOFRETE\"), Alltrim("TI_VGMLOCK") + "SRV" + Alltrim(cIdServ) + ".LCK" }
//-------------------------------------------------------------------
/*/{Protheus.doc} GerAcessRes
Realiza autentica��o no TRANSPOFRETE, gerando token de acesso

@author By Wise

@since 29/09/2018
/*/
//-------------------------------------------------------------------

User function GerAcessRes()

Local cToken    := ""
Local oRest     := ""
Local aHeader   := {}
Local cRequest  := ""
Local aRet      := {}
Local cIdLicenc := GetMv("TI_LICRES",,"2271")
Local cLogin    := GetMv("TI_LOGRES",,"admin")
Local cPassword := GetMv("TI_PSWRES",,"abc123")

    cRequest += '<Credenciais>'
    cRequest += '<IdLicenciado>' + cIdLicenc + '</IdLicenciado>'
    cRequest += '<Usuario>' + cLogin + '</Usuario>'
    cRequest += '<Senha>' + cPassword + '</Senha>'
    cRequest += '</Credenciais>'

    //Adiciona o header
    Aadd( aHeader, 'Content-Type: application/xml' )

    aRet := U_ResInteg("000001", cRequest, aHeader)

    If aRet[1]
        aRet[2] := StrTran(aRet[2],'"','')
    Else
        If Empty(aRet[2])
            aRet[2] := "Falha na autenticacao."
        EndIf
    EndIf

Return(aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetEmpRes
Realiza a requisi��o das empreas cadastradas no TRANSPOFRETE.

@author By Wise

@since 29/09/2018
/*/
//-------------------------------------------------------------------

User function GetEmpRes()

Local aRet      := {}
Local aEmpresas := {}
Local aHeader   := {}
Local aFiliais  := {}
Local nX
Local cCnpj     := ""
Local cRazao    := ""
Local cIdReserv := ""
Local aArea     := {}
Local aAreaSm0  := {}
Local nEmpTerc  := 0

Private aDados    := {}

    //Consumo a fun��o que gera o acesso com o TRANSPOFRETE e retorna o token
    aRet := U_GerAcessRes()

    //Caso tenha realizado o acesso com sucesso.
    If aRet[1]
        
        //Adiciona o header
        Aadd( aHeader, "SecurityToken:" + aRet[2] )
        
        aRet := U_ResInteg("000002", , aHeader, , .T., "?$select=id,razaoSocial,cnpj,grupo")
        
        If aRet[1]
            aDados := aRet[2]
        
            aArea   := GetArea()
            aAreaSm0 := SM0->(GetArea())

            SM0->(DbSetOrder(1))
            SM0->(DbGoTop())

            While !SM0->(Eof())

                AADD(aFiliais, {SM0->M0_CGC, SM0->M0_CODFIL})
                
                SM0->(DbSkip())

            End

			//Empresa de terceiros.
            nEmpTerc    := GetMv("TI_EMPTERC",,50)

            For nX := 1 to len(aDados)

                cCnpj := Alltrim(aDados[nX]:Cnpj)
                
                cCnpj := StrTran(cCnpj, ".", "")
                cCnpj := StrTran(cCnpj, "/", "")
                cCnpj := StrTran(cCnpj, "-", "")

                nPosCodFil  := aScan(aFiliais       , {|x| Alltrim(x[1]) == cCnpj })

                If nPosCodFil > 0
                    //AADD(aEmpresas, { aDados[nX][2][nPosId][2], aDados[nX][2][nPosCnpj][2], aDados[nX][2][nPosRazao][2], aFiliais[nPosCodFil][2], If(nPosIdGrupo>0,aDados[nX][2][nPosGrupo+1][2][nPosIdGrupo,2],0)} )
                    AADD(aEmpresas, { aDados[nX]:id, aDados[nX]:cnpj, aDados[nX]:razaoSocial, aFiliais[nPosCodFil][2], If(Type("aDados["+Alltrim(Str(nX))+"]:grupo:id")!="N", -1, aDados[nX]:grupo:id)} )
			    ElseIf aDados[nX]:id == nEmpTerc
                    AADD(aEmpresas, { aDados[nX]:id, aDados[nX]:cnpj, aDados[nX]:razaoSocial, , If(Type("aDados["+Alltrim(Str(nX))+"]:grupo:id")!="N", -1, aDados[nX]:grupo:id)} )        
                EndIf

            Next nX

            aRet[2] := aClone(aEmpresas)
            // REstauro SM0
            SM0->(RestArea(aAreaSm0))
            RestArea(aArea)

        EndIf

        // Libera mem�ria
        aSize(aEmpresas,0) 
        aSize(aDados,0)
        aSize(aFiliais,0)
        aSize(aAreaSm0,0)
        aSize(aArea,0)
        aSize(aHeader,0)

    EndIf

Return(aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ResInteg
Processa a requisi��o via rest.

@author By Wise

@since 29/09/2018
/*/
//-------------------------------------------------------------------

User function ResInteg(cIdServ, cJson, aHeader, aParGet, lObjJson, cParamUrl, nOpcMet)

Local aRet          := {"","",""} //Posi��o 1 indica o sucesso da requisi��o, Posi��o 2 traz o retorno da requisi��o em objeto, 3 json de retorno em string
Local cUrl          := ""
Local cMetodo       := ""
Local oRest
Local cResult       := ""    
Local nRetParser    := 0
Local aJSonField    := {}
Local oJson
Local cParam        := ""
Local cTipMet       := ""
Local cHeaderRet    := ""
Local nTimeOut      := GetMv("TI_VGMTOUT",,8) //Seta o tempo de timeout

Default aHeader     := {}
Default aParGet     := {}
Default cJson       := {}
Default lObjJson    := .F.
Default cParamUrl   := ""
Default nOpcMet     := 1

    DbSelectArea("PZA")
    PZA->(DbSetOrder(1))

    If PZA->(MsSeek(xFilial("PZA") + cIdServ))

        cUrl    := Alltrim(PZA->PZA_URL)
        
        //Case para selecionar o metodo passado por parametro
        Do Case

            Case nOpcMet == 1
        		cMetodo := Alltrim(PZA->PZA_ENDPOI)
                cTipMet := PZA->PZA_TIPMET

            Case nOpcMet == 2
                cMetodo := Alltrim(PZA->PZA_SEGEND)
                cTipMet := PZA->PZA_SEGTIP
            
            Case nOpcMet == 3
                cMetodo := Alltrim(PZA->PZA_TEREND)
                cTipMet := PZA->PZA_TERTIP
            
            Case nOpcMet == 4
                cMetodo := Alltrim(PZA->PZA_QUAEND)
                cTipMet := PZA->PZA_QUATIP
            
            Case nOpcMet == 5
                cMetodo := Alltrim(PZA->PZA_QUIEND)
                cTipMet := PZA->PZA_QUITIP

        EndCase

        //Case para realizar o tipo de requisi��o preenchido.
        Do case

            Case cTipMet == "1" //Get

                If Len(aParGet) > 0
                    cParam := fStrGet(aParGet)
                Else
                    cParam := cParamUrl
                EndIf
                
                //Monta objeto para consumo
                oRest := FWREST():New(cUrl + cMetodo)
                
                //Seta parametros
                oRest:SetPath(cParam)
                
                lRet := oRest:Get(aHeader)

                //Verifico se existe conteudo de retorno
                If oRest:GetResult() == Nil
                    aRet[1] := .F.
                    aRet[2] := "Falha na conex�o com a URL."
                Else
                    cResult := oRest:GetResult()

					If DecodeUtf8(cResult) <> Nil
                    	cResult := DecodeUtf8(cResult)
	                EndIf
					
				EndIf

                //Caso tenha sucesso
                If lRet
                    If lObjJson
                        aJsonfields := {}
                        lRet := FWJsonDeserialize(cResult,@oJson)
                        If ! lRet
                            aRet[1] := .F.
                        Else
                            aRet[2] := oJson
                            aRet[1] := .T.
							aRet[3] := cResult
                        Endif 
                    Else
                        oJSon := TJSonParser():New()
                        oJSon:Json_Parser( cResult /*strJson*/,Len( cResult ) /*lenStrJson*/, @aJSonField /*@jsonfields*/, @nRetParser /*@nRetParser*/ )
                        aRet[2] := aJSonField
                        aRet[1] := .T.
						aRet[3] := cResult
                    EndIf 
               
                Else
                    aRet[1] := .F.
                    aRet[2] := oRest:GetLastError()
					aRet[3] := cResult
                EndIf

            Case cTipMet == "2" //Post

                //Monta objeto rest
                oRest := FWREST():New(cUrl)
                
                //Seta endpoint
                oRest:SetPath(cMetodo+cParamUrl)

                //Seta o JSON como parametro
				If EncodeUtf8(cJson) <> Nil
                    cJson := EncodeUtf8(cJson)
                EndIf

                oRest:SetPostParams(cJson)
                
                //Controla o tempo de timeout do processamento do post
                //oRest:nTimeOut := nTimeOut
                        
                //Realizo o Post do JSON
                lRet := oRest:Post(aHeader)
 
                //Verifico se existe conteudo de retorno
                If oRest:GetResult() == Nil
                    aRet[1] := .F.
                    aRet[2] := "Falha na conex�o com a URL."
                    cResult := oRest:GetLAstError()
                    cResult := DecodeUtf8(cResult)
                    FWJsonDeserialize( cResult ,@oJSon)
                Else
                    cResult := oRest:GetResult()
                    If Empty(cResult) 
                    	If Upper(oRest:getlasterror()) == "204 NOCONTENT" .Or. Upper(oRest:getlasterror()) == "200 OK"
                    		lRet := .T.
                    		cResult := '{"resultado": "OK"}'
                    	EndIf
                    Else
	                    If DecodeUtf8(cResult) <> Nil
	                        cResult := DecodeUtf8(cResult)
	                    EndIf
						FWJsonDeserialize( cResult ,@oJSon)
					EndIf
                EndIf

                //Caso tenha sucesso
                If lRet
                    aRet[1] := .T.
                    aRet[2] := oJSon
					aRet[3] := cResult	
                Else
                    aRet[1] := .F.
                    aRet[2] := oJSon
					aRet[3] := cResult
                EndIf

            Case cTipMet == "3" //Put
            
            	//Monta objeto rest
                oRest := FWREST():New(cUrl)
                
                //Seta endpoint
                oRest:SetPath(cMetodo+cParamUrl)

                //Seta o JSON como parametro
				If EncodeUtf8(cJson) <> Nil
                    cJson := EncodeUtf8(cJson)
                EndIf

                //oRest:SetPostParams(cJson)
                
                //Controla o tempo de timeout do processamento do post
                //oRest:nTimeOut := nTimeOut
                        
                //Realizo o Put do JSON
                aHdPut := aClone(aHeader)
                aadd(aHdPut,"Content-Type:application/json")
              
                lRet := oRest:Put(aHdPut,cJson)
 
                //Verifico se existe conteudo de retorno
                If oRest:GetResult() == Nil
                    aRet[1] := .F.
                    aRet[2] := "Falha na conex�o com a URL."
                    cResult := oRest:GetLAstError()
                    cResult := DecodeUtf8(cResult)
                    FWJsonDeserialize( cResult ,@oJSon)
                Else
                    cResult := oRest:GetResult()
                    If Empty(cResult) 
                    	If Upper(oRest:getlasterror()) == "204 NOCONTENT" .Or. Upper(oRest:getlasterror()) == "200 OK"
                    		lRet := .T.
                    		cResult := '{"resultado": "OK"}'
                    	EndIf
                    Else
	                    If DecodeUtf8(cResult) <> Nil
	                        cResult := DecodeUtf8(cResult)
	                    EndIf
						FWJsonDeserialize( cResult ,@oJSon)
					EndIf
                EndIf

                //Caso tenha sucesso
                If lRet
                    aRet[1] := .T.
                    aRet[2] := oJSon
					aRet[3] := cResult	
                Else
                    aRet[1] := .F.
                    aRet[2] := oJSon
					aRet[3] := cResult
                EndIf

            Case cTipMet == "4" //Path
                                // JULIO VIEIRA
                cRet := HTTPQuote ( cUrl+cMetodo+cParamUrl, "PATCH", ,cJson, 120, aHeader, @cHeaderRet ) 

                if !empty(cHeaderRet)
                    aResponse := strtokarr(cHeaderRet,CRLF)
                    if !( '204 No Content' $ aResponse[1] ) .and. !( '200 OK' $ aResponse[1] )
                        aRet[1] := .F.
                        aRet[2] := 'Error: ' + aResponse[1]
                        aRet[3] := cRet
                    else
                        cResult := DecodeUtf8(cRet)
                        FWJsonDeserialize( cResult ,@oJSon)
                         aRet[1] := .T.
                         aRet[2] := oJSon
					     aRet[3] := cHeaderRet
                    endif
                else
                    cRet := 'Error: Falha na requisicao, nao foi possivel obter o retorno.'
                      aRet[1] := .F.
                      aRet[2] := cRet
                      aRet[3] := cHeaderRet
                endif 
 
            Case cTipMet == "5" //Delete

                If Len(aParGet) > 0
                    cParam := fStrGet(aParGet)
                Else
                    cParam := cParamUrl
                EndIf

                //Monta objeto para consumo
                oRest := FWREST():New(cUrl + cMetodo)
                
                //Seta parametros
                oRest:SetPath(cParam)

                //Seta o JSON como parametro
                oRest:SetPostParams(cJson)
                
                lRet := oRest:Delete(aHeader)

                //Verifico se existe conteudo de retorno
                If oRest:GetResult() == Nil
                    aRet[1] := .F.
                    aRet[2] := "Falha na conex�o com a URL."
                Else
                    if oRest:getlasterror() == "204 NoContent" .Or. oRest:getlasterror() == "200 OK"
                       lRet := .T.
                       cResult := '{"resultado": "OK"}'
                    else
                        cResult := oRest:GetResult()
						                    
                    If DecodeUtf8(cResult) <> Nil
                        cResult := DecodeUtf8(cResult)
                    EndIf
                    
                    endif
                EndIf

                //Caso tenha sucesso
                If lRet
                    If lObjJson
                        aJsonfields := {}
                        lRet := FWJsonDeserialize(cResult,@oJson)
                        If ! lRet
                            aRet[1] := .F.
                        Else
                            aRet[2] := oJson
                            aRet[1] := .T.
							aRet[3] := cResult
                        Endif 
                    Else
                        oJSon := TJSonParser():New()
                        oJSon:Json_Parser( cResult /*strJson*/,Len( cResult ) /*lenStrJson*/, @aJSonField /*@jsonfields*/, @nRetParser /*@nRetParser*/ )
                        aRet[2] := aJSonField
                        aRet[1] := .T.
						aRet[3] := cResult
                    EndIf 
               
                Else
                    
                    //O metodo em caso de falha retorna erros genericos, ent�o pego o JSON do resultado mesmo para tratar o erro.
                    oJSon := TJSonParser():New()
                    oJSon:Json_Parser( cResult /*strJson*/,Len( cResult ) /*lenStrJson*/, @aJSonField /*@jsonfields*/, @nRetParser /*@nRetParser*/ )

                    aRet[1] := .F.
                    aRet[2] := aJSonField
					aRet[3] := cResult
                    
                EndIf


        EndCase
    
    Else

        cMenssagem := "Id do servi�o enviado n�o foi encontrado no cadastro de servi�os."
        aRet[1] := .F.

        If lObjJson
            If FWJsonDeserialize('{"message":"' + cMenssagem + '"}',@oJson)
                aRet[2] := oJson
            EndIf
        Else
            aRet[2] := {{"message",cMenssagem}}
        EndIf

        aRet[3] := cMenssagem
        
    EndIf

Return(aRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} MonitRes
Fun��o de atualiza��o do monitor de integra��o.

@param  cIdServ, string, recebe id de cadastro na tabela PZA
        nOpc, boolean, 1 = inclus�o, 2 = altera��o / atualiza��o
        aDados, array, contem os dados para os registros
        nQtdReg, boolean, contem a quantidade total de registros a processar.

@author By Wise

@since 29/09/2018
/*/
//------------------------------------------------------------------------------

User function MonitRes(cIdServ, nOpc, nQtdReg, cPZBId, cObserv, lSucess, cChave, cJsoEnv, cJsoRec, cDesChave, lReprocess, lLote, cPZCId, lExcec, lAutentic, lAjusCont)

Local aRet          := {"",""}
Local cFileLock     := Eval(bFileLock)
Local cIdPZB        := ""
Local cIdPZC        := ""
Local cIdPZD        := ""
Local cStatusPZC    := ""
Local cStatusPZD    := ""
Local cHoraFim      := ""
Local cTime         := ""
Local nSecIni       := 0
Local nSecFim       := 0
Local nHrIni        := 0
Local nHrFim        := 0
Local nMinIni       := 0
Local nMinFim       := 0
Local nPosLock      := 0
Local nTotHor       := 0
Local nTotMin       := 0
Local nTotSec       := 0

Default cIdServ     := ""
Default nOpc        := 0
Default nQtdReg     := 0
Default cPZBId      := ""
Default cObserv     := ""
Default lSucess     := .T.
Default cChave      := ""
Default cJsoEnv     := ""
Default cJsoRec     := ""
Default cDesChave   := ""
Default cPZCId      := ""
Default lLote       := .F.
Default lReprocess  := .F.
Default lExcec      := .F.
Default lAutentic   := .F.
Default lAjusCont   := .T.

nPosLock := aScan(aHdlLock,{|a| a[1] == cIdServ})

If cIdServ == "000020"
    Conout("===============================")
    Conout("Job........: 000020")
    ConOut("Fun��o.....: U_MonitRes")
    ConOut("Called from: " + ProcName(1))
    ConOut("Line.......: " + Alltrim(Alltochar(Procline(1))))
    Conout("===============================")
EndIf

If nPosLock == 0
    aAdd(aHdlLock,{cIdServ,-1})
    nPosLock := Len(aHdlLock)
EndIf

    DbSelectArea("PZA")
    PZA->(DbSetOrder(1))

    If PZA->(MsSeek(xFilial("PZA") + cIdServ))

        //Inclus�o
        If nOpc == 1

            If !File(cFileLock)
                aHdlLock[nPosLock][2] := FCreate(cFileLock)
            Else
                aHdlLock[nPosLock][2] := FOpen(cFileLock, FO_READWRITE + FO_EXCLUSIVE)
            Endif

            //Adquiri o pr�ximo id de processamento para o servi�o.
            cId := fGerIdPZB(cIdServ)

            RecLock("PZB",.T.)

                PZB->PZB_FILIAL := xFilial("PZB")
                PZB->PZB_IDURL  := cIdServ
                PZB->PZB_ID     := cId
                PZB->PZB_HORA   := Time()
                PZB->PZB_DATA   := dDataBase
                PZB->PZB_REGTOT := nQtdReg
                PZB->PZB_STATUS := "E" //Em andamento

            MsUnlock()

            aRet[1] := .T.
            aRet[2] := cId

        //Alimenta monitor
        ElseIf nOpc == 2

            DbSelectArea("PZB")
            PZB->(DbSetOrder(1))

            If PZB->(MsSeek(xFilial("PZB") + cIdServ + cPZBId ))

                PZB->(RecLock("PZB",.F.))

                    If !lReprocess .Or. (lReprocess .And. lLote)
                    	PZB->PZB_REGPRO := PZB->PZB_REGPRO + 1
                    EndIf
                    
                    If lExcec
                        PZB->PZB_REGEXC := PZB->PZB_REGEXC + 1
                    ElseIf !lSucess
                        PZB->PZB_REGERR := PZB->PZB_REGERR + 1
                    EndIf

                PZB->(MsUnlock())
                
            EndIf

            //Gera��o da PZC
            If !lReprocess .Or. (lReprocess .And. lLote)

                //Gera pr�ximo ID da PZC
                cIdPZC      := fPZCId(cPZBId, cIdServ)
                
                If lExcec
                    cStatusPZC  := "E"
                Else    
                    cStatusPZC  := IIf(lSucess,"S","F")
                EndIf

                //Efetua a grava��o da PZC
                RecLock("PZC", .T.)

                    PZC->PZC_FILIAL := xFilial("PZC")
                    PZC->PZC_IDPROC := cPZBId
                    PZC->PZC_ID     := cIdPZC
                    PZC->PZC_CHAVE  := cChave
                    PZC->PZC_STATUS := cStatusPZC
                    PZC->PZC_DESCHV := cDesChave
                    PZC->PZC_IDURL  := cIdServ

                MsUnlock()

            //Se for reprocessamento atualiza o status da PZC.
            Else

                cStatusPZC  := IIf(lExcec,"E", IIf(lSucess,"S","F"))
                cIdPZC := cPZCId
            
                DbSelectArea("PZC")
                PZC->(DbSetOrder(1))

                If PZC->(MsSeek(xFilial("PZC") + cPZBId + cIdPZC))

                    PZC->(RecLock("PZC",.F.))

                        PZC->PZC_STATUS := cStatusPZC

                    PZC->(MsUnlock())

                EndIf
            
            EndIf

            //Gera sequencial para a PZD
            cIdPZD      := fPZDId(cPZBId, cIdPZC, cIdServ)
            cStatusPZD  := IIf(lExcec,"E", IIf(lSucess,"S","F"))

            cObserv := U_fNoAcento(cObserv)

            //Efetua a grava��o da PZD
            RecLock("PZD", .T.)

                PZD->PZD_FILIAL := xFilial("PZD")
                PZD->PZD_IDPROC := cPZBId
                PZD->PZD_IDREG  := cIdPZC
                PZD->PZD_ID     := cIdPZD
                PZD->PZD_HORA   := Time()
                PZD->PZD_DESC   := cObserv
                PZD->PZD_JSOENV := cJsoEnv
                PZD->PZD_JSOREC := cJsoRec
                PZD->PZD_STATUS := cStatusPZD
                PZD->PZD_IDURL  := cIdServ

            MsUnlock()

        ElseIf nOpc == 3 //Conclus�o

            DbSelectArea("PZB")
            PZB->(DbSetOrder(1))

            If PZB->(MsSeek(xFilial("PZB") + cIdServ + cPZBId ))

                cHoraFim := Time()

                PZB->(RecLock("PZB",.F.))

                    //Se chegou a processar registros
                    If lSucess
                        PZB->PZB_STATUS := IIf(PZB->PZB_REGERR > 0, "F", "S")
                        PZB->PZB_MENSAG := "Processamento concluido."
                    Else
                        PZB->PZB_STATUS := "F"
                        PZB->PZB_MENSAG := IIf(lAutentic, "Falha no login com o TRANSPOFRETE.", "Processamento falhou.")
                    EndIf
                
                    //nHrFim  := Val(Left(cHoraFim,2))
                    //nHrIni  := Val(Left(PZB->PZB_HORA,2))

                    //nMinFim := Val(Substr(cHoraFim,4,2))
                    //nMinIni := Val(Substr(PZB->PZB_HORA,4,2))

                    //    nSecFim := Val(Right(cHoraFim,2))
                    //    nSecIni := Val(Right(PZB->PZB_HORA,2))
                        
                    //Monta totalizadores
                    //nTotHor := nHrFim - nHrIni
                    //nTotMin := nMinFim - nMinIni
                    //nTotSec := nSecFim - nSecIni

                    //Variavel da hora
                    //cTime := StrZero(nTotHor,2) + ":" + StrZero(nTotMin,2) + ":" + StrZero(nTotSec,2)

                    PZB->PZB_TEMPO := ElapTime(PZB->PZB_HORA,cHoraFim )// cTime
                	
                	// Realiza ajuste dos contadores de processamento
                	If lAjusCont
                		PZB->PZB_REGTOT := PZB->PZB_REGPRO
                	Endif	
                
                PZB->(MsUnlock())

            EndIf

            If File(cFileLock)
                If FClose(aHdlLock[nPosLock][2])
                    aHdlLock[nPosLock][2] := -1
                    FErase(cFileLock)
                EndIf
            Endif

        EndIf

    Else
        aRet[1] := .F.
        aRet[2] := "Id de servi�o informado n�o foi encontrado na tabela PZA."
    EndIf
    
Return(aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} fGerIdPZB
Fun��o para gerar pr�ximo Id para a PZB para o servi�o informado.

@author By Wise
@since  30/09/201
@version 1.0
/*/
//-------------------------------------------------------------------

Static function fGerIdPZB(cIdServ)

Local cSeque    := ""
Local cQuery    := ""
Local cAlsQry   := CriaTrab(Nil,.F.)

    cQuery := " SELECT MAX(PZB_ID) SEQUEN "
    cQuery += " FROM " + RetSqlName("PZB") + " PZB "
    cQuery += " WHERE PZB_FILIAL = '" + xFilial("PZB") + "' AND "
    cQuery += " PZB_IDURL = '" + cIdServ + "' AND PZB.D_E_L_E_T_ = ' ' "

    If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif  
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

    If (cAlsQry)->(Eof())
        cSeque := "000001"
    Else
        cSeque := Soma1( (cAlsQry)->SEQUEN )
    EndIf

    (cAlsQry)->(dbCloseArea())

Return(cSeque)

//-------------------------------------------------------------------
/*/{Protheus.doc} fPZCId
Fun��o para gerar pr�ximo Id para a PZC para o processo informado.

@author By Wise
@since 30/09/201
@version 1.0
/*/
//-------------------------------------------------------------------

Static function fPZCId(cIdPzb, cIdUrl)

Local cSeque    := ""
Local cQuery    := ""
Local cAlsQry   := CriaTrab(Nil,.F.)

    cQuery := " SELECT MAX(PZC_ID) SEQUEN "
    cQuery += " FROM " + RetSqlName("PZC") + " PZC "
    cQuery += " WHERE PZC_FILIAL = '" + xFilial("PZC") + "' AND "
    cQuery += " PZC_IDURL = '" + cIdUrl + "' AND PZC_IDPROC = '" + cIdPzb + "' AND PZC.D_E_L_E_T_ = ' ' "

    If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif  
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

    If (cAlsQry)->(Eof())
        cSeque := "000001"
    Else
        cSeque := Soma1( (cAlsQry)->SEQUEN )
    EndIf

    (cAlsQry)->(dbCloseArea())

Return(cSeque)

//-------------------------------------------------------------------
/*/{Protheus.doc} fPZDId
Fun��o para gerar pr�ximo Id para a PZD de acordo com o codigo de log
informado + codigo do registro.

@author By Wise
@since 30/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Static function fPZDId(cIdPZB, cIdPZC, cIdUrl)

Local cSeque    := ""
Local cQuery    := ""
Local cAlsQry   := CriaTrab(Nil,.F.)

    cQuery := " SELECT MAX(PZD_ID) SEQUEN "
    cQuery += " FROM " + RetSqlName("PZD") + " PZD "
    cQuery += " WHERE PZD_FILIAL = '" + xFilial("PZD") + "' AND "
    cQuery += " PZD_IDURL = '" + cIdUrl + "' AND PZD_IDPROC = '" + cIdPZB + "' AND PZD_IDREG = '" + cIdPZC + "' "
    cQuery += " AND PZD.D_E_L_E_T_ = ' ' "

    If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif  
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

    If (cAlsQry)->(Eof())
        cSeque := "000001"
    Else
        cSeque := Soma1( (cAlsQry)->SEQUEN )
    EndIf

    (cAlsQry)->(dbCloseArea())

Return(cSeque)

//-------------------------------------------------------------------
/*/{Protheus.doc} fNoAcento
Fun��o para tratar mensagem de observa��o.

@author By Wise
@since 30/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------

User function fNoAcento(cRetorno)

Local nX        := 0
Local aSubst    := {    {"�","a"},;
                        {"�","a"},;
                        {"�","a"},;
                        {"�","a"},;
                        {"�","a"},;
                        {"�","a"},;
                        {"�","a"},;
                        {"�","a"},;
                        {"�","e"},;
                        {"�","e"},;
                        {"�","e"},;
                        {"�","i"},;
                        {"�","i"},;
                        {"�","i"},;
                        {"�","o"},;
                        {"�","o"},;
                        {"�","o"},;
                        {"�","o"},;
                        {"�","u"},;
                        {"�","u"},;
                        {"�","u"},;
                        {"�","c"},;
                        {"{","" },;
                        {"}","" },;
                        {'"','' } }

    //Trata mensagem de retorno
    For nX := 1 to len(aSubst)

        cRetorno := StrTran(cRetorno, aSubst[nX][1], aSubst[nX][2])

    Next nX

    cRetorno := Alltrim(cRetorno)
           
Return(cRetorno)
/*/{Protheus.doc} NumSeq
Obtem o pr�ximo n�mero sequencial de um determinado campo, independente da filial.
@author Claudio Donizete
@since 10/11/2016
@version version
@return nil
@example
(examples)
/*/
User Function NumSeq(cAlias,cCampo,cWhere) 
Local cAliasTrb := GetNextAlias()
Local cRet
Local cExp := "%MAX("+cCampo+") " + cCampo + "%" 
Local cTable := "%" + RetSqlName(cAlias) + "%"

Default cWhere := ""

cWhere := cWhere + If(!Empty(cWhere), " AND ", "") +  " D_E_L_E_T_ = ' ' "

BeginSql Alias cAliasTrb
	SELECT %exp:cExp%
	  FROM %exp:cTable%
	 WHERE %exp:cWhere%
EndSql

cRet := SOMA1((cAliasTrb)->&cCampo)
(cAliasTrb)->(DbCloseArea())

Return cRet
/*/{Protheus.doc} ResConfPg
REaliza a integra��o da confirma��o do pagamento com o TRANSPOFRETE
@author Claudio Donizete
@since 22/10/2018
@version version
@return nil
@example
(examples)
/*/
User Function ResConfPg(aRet, dDataRef, nIdPlano, nIdPgto, cReferencia, nTxMoeda,cBody, lBordero, lJaPgto)
Local aHeader := {}
Local oJson   := JsonUtil():New()
Local aItems := {}
Local oItems
Local cChaveM
Local lMoedIntPl := .F.
Local cPrefAdi  

Default cReferencia := SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
Default dDataRef    := IIf(Empty(SE2->E2_BAIXA),SE2->E2_VENCREA,SE2->E2_BAIXA)
Default nTxMoeda    := SE5->E5_TXMOEDA
Default cBody       := ""
Default lBordero    := .F.
Default lJaPgto     := .F.

    If Empty(aRet) .Or. !aRet[1]
        aRet := U_GerAcessRes() // Obtem novo token de acesso
    EndIf

    If aRet[1]
        //Adiciona o header
        Aadd( aHeader, "SecurityToken:" + aRet[2] )
        Aadd( aHeader, "Content-Type: application/json" )

        cChaveM := xFilial("PZG") + Str(Val(SE2->E2_NUM),10) 
	    PZG->(dbSetOrder(1)) 
	    If PZG->(dbSeek(cChaveM))
	    	If PZG->PZG_MOEDA <> 1
	    		lMoedIntPl := .T.
	    	Endif	
	   	Endif

          //Status de pago somente se a rotina for a de baixas.
        If lBordero .And. lJaPgto
            oJson:PutVal("Status", "Pago")
            cPrefDia := U_GetPrefixo("3",PZG->PZG_IDTPLN)[1] // Obtem os prefixos de Di�ria de todos os tipos de planos de viagem
            cPrefAdt := U_GetPrefixo("2",PZG->PZG_IDTPLN)[1] // Obtem os prefixos de Di�ria de todos os tipos de planos de viagem
            cPrefAdi := U_GetPrefixo("6")[1] // Obtem os prefixos de Reembolsos de todos os tipos de planos de viagem
            // S� atualiza o c�digo externo, quando n�o for pagto de di�ria/adiantamento
            If !(cPrefDia$cReferencia .Or. cPrefAdt$cReferencia .Or. cPrefAdi$cReferencia)
                oJson:PutVal("codigoExterno", cReferencia )
            EndIf    
        EndIf
            
        oJson:PutVal("data"         , Transform(DTOS(dDataRef), "@R 9999-99-99")+ "T03:00:00.000Z" )
        
        If lBordero
            oJson:PutVal("referencia"   , cReferencia)
        EndIf

        If IsInCallStack("U_CANCPRES")
            //oJson:PutVal("valorReferencia", 9)
            oJson:PutVal("status", "Cancelado" )
        EndIf
        
        //cBody := '{ "data": "' + Transform(DTOS(dDataRef), "@R 9999-99-99") + 'T03:00:00.000Z", "referencia": "'+cReferencia+'" }'
        cBody := oJson:ToJson()

		

        If SE2->E2_MOEDA > 1 .And. lJaPgto .And. !lMoedIntPl
            oJson := nil
            oJson := JsonUtil():New()
            //{ �Moeda�: �EUR�, "ValorCambioAtualizado": "1,02", "Items": [] } 
            oJson:PutVal("Moeda", u_Moeda2S(SE2->E2_MOEDA) )
            oJson:PutVal("ValorCambioAtualizado", Alltrim(Transform(nTxMoeda, "@E 999999.99999999")))
            //oJson:PutVal("ValorCambioAtualizado", Alltrim(Str(nTxMoeda)))
            oItems := JsonUtil():New()
            aadd(aItems, oItems )
            oJson:PutVal("Items", aItems)
            aRet := U_ResInteg("000005", StrTran(oJson:ToJson(), "null", ""), aHeader,,.T.,"/"+Alltrim(Str(Val(SE2->E2_NUM)))+"/cambio")
        EndIf

        // S� baixa o plano, caso tenha conseguido atualizar o c�mbio  
	    If aRet[1]  
            aRet := U_ResInteg("000005", cBody, aHeader,,.T.,"/"+Alltrim(Str(nIdPlano))+"/pagamentos/"+Alltrim(Str(nIdPgto))+"/confirmacao")
        EndIf    
  
	End

    FreeObj(oJson)
    oJson := Nil
    DelClassIntf()

Return aClone(aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GerAcessRes
Realiza autentica��o no TRANSPOFRETE, gerando token de acesso

@author By Wise

@since 29/09/2018
/*/
//-------------------------------------------------------------------

Static Function fStrGet(aRest)

Local cRet  := ""
Local nC

    If Len( aRest ) > 0
		
        cRet := "?"
		For nC := 1 To Len( aRest )

			cRet += IIf(nC == 1 ,"" ,"&") + Alltrim( aRest[nC] )

		Next nC 

	EndIf

Return(cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} MaxIdRes
Busca o ID maximo da tabela informada.

@author By Wise

@since 29/09/2018
/*/
//-------------------------------------------------------------------

User Function MaxIdRes(cTabela, cCampo)

Local cQuery    := ""
Local cAlsId    := CriaTrab(Nil,.F.)
Local cMaxId    := ""

    cQuery := " SELECT MAX(" + cCampo + ") MAXID "
    cQuery += " FROM " + RetSqlname(cTabela) + " " + cTabela
    cQuery += " WHERE " + cTabela + ".D_E_L_E_T_ = ' ' "

    If Select(cAlsId) > 0; (cAlsId)->(dbCloseArea()); Endif  
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsId,.T.,.T.)

    If (cAlsId)->(Eof())
        cMaxId := "000001"
    Else
        cMaxId := Soma1( (cAlsId)->MAXID )
    EndIf

    (cAlsId)->(dbCloseArea())

Return(cMaxId)


//-------------------------------------------------------------------
/*/{Protheus.doc} ConAtbRes
Consulta atributos cadastrados para o TRANSPOFRETE

@author By Wise

@since 29/09/2018
/*/
//-------------------------------------------------------------------

User Function ConAtbRes()

Local cQuery    := ""
Local cAlsAtb   := CriaTrab(Nil,.F.)

Private	nPos		:= 0
Private aCampos 	:= {}
Private	cGetPesq	:= Space(4)

Static	cRetIt		:= ""

    cQuery := " SELECT PS3_CODIGO, PS3_NOME, PS3_RESATB "
    cQuery += " FROM " + RetSqlname("PS3") + " PS3 "
    cQuery += " WHERE PS3.D_E_L_E_T_ = ' ' "

    If Select(cAlsAtb) > 0; (cAlsAtb)->(dbCloseArea()); Endif  
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsAtb,.T.,.T.)
    
    //Conteudos a exibir no grid.
    While (cAlsAtb)->(!Eof())
		   
		AADD(aCampos,{(cAlsAtb)->PS3_CODIGO, (cAlsAtb)->PS3_NOME, (cAlsAtb)->PS3_RESATB})

		(cAlsAtb)->(Dbskip())            
         
	End

	DEFINE MSDIALOG oDlg TITLE "Atributos TRANSPOFRETE" From 000,000 TO 360,570 PIXEL
	@ 020,000 MSPANEL oPanel2 SIZE 290,130 OF oDlg
	@ 005, 004 GET cGetPesq   SIZE 239, 010	PICTURE "XXXX"	OF oDlg PIXEL
	@ 005, 243 BUTTON 	oButPesq	PROMPT "Pesquisar"	SIZE 037, 012	ACTION (nPos := ItemPesq(), oLbx:nAt:=nPos, oLbx:Refresh()) OF oDlg PIXEL
	@ 30,05 LISTBOX oLbx FIELDS HEADER "Codigo","Descricao","Atributo TRANSPOFRETE" SIZE 60, 30, 100 OF oPanel2 PIXEL   
	@ 159, 206 BUTTON oButOK PROMPT "&OK"  SIZE 037, 012 ACTION (cRetIt :=  Alltrim(aCampos[oLbx:nAt,1]), oDlg:End() ) OF oDlg PIXEL
	@ 159, 245 BUTTON oButClose PROMPT "&Cancel"  SIZE 037, 012 ACTION (cRetIt := "", oDlg:End() ) OF oDlg PIXEL 
  
	oLbx:SetArray(aCampos)                                                
	oLbx:bLine := {|| {aCampos[oLbx:nAt,1], aCampos[oLbx:nAt,2], aCampos[oLbx:nAt,3]}}   
	oLbx:bLDblclick := {|| {cRetIt :=  Alltrim(aCampos[oLbx:nAt,1]),oDlg:End() }}
	oLbx:align:= CONTROL_ALIGN_ALLCLIENT	
		         	
	ACTIVATE MSDIALOG oDlg CENTERED

Return .T.

//Localizar a linha do array de acordo com o que foi digitado pelo usu�rio na caixa de pesquisa.

Static function ItemPesq()
	
	nPos := aScan(aCampos,{|x| Alltrim(x[1])==Alltrim(Upper(cGetPesq))})
	
	If nPos == 0
		nPos := 1
	EndIf	

Return(nPos)

//Fun��o necess�ria, para retornar a variavel para a tela.

User function RetAtb()

Return cRetIt         	


//-------------------------------------------------------------------
/*/{Protheus.doc} DesAtbRes
Chama consulta padr�o de acordo com atributo informado.

@author By Wise

@since 29/09/2018
/*/
//-------------------------------------------------------------------

User Function DesAtbRes()

Local cAtributo := FwFldGet("PS1_ATRIBU")

Static cRetIt   := ""

    If Empty(cAtributo)
        Help(" ",1, 'Help','TFINA203_ATB',"Necessario preencher primeiro o campo codigo do atributo." , 3, 0 )
    Else

        DbSelectArea("PS3")
        PS3->(DbSetOrder(1))

        If PS3->(MsSeek(xFilial("PS3") + cAtributo))

            Do Case

                Case PS3->PS3_SXBX5 == "_U"   
                    ConPad1(,,,"GRPRES")
                    cRetIt := Alltrim(SX5->X5_CHAVE)
                
                Case PS3->PS3_SXBX5 == "_T"   
                    ConPad1(,,,"POLRES")
                    cRetIt := Alltrim(SX5->X5_CHAVE)
                
                Case PS3->PS3_SXBX5 == "_V"   
                    ConPad1(,,,"PERRES")
                    cRetIt := Alltrim(SX5->X5_CHAVE)

                Case PS3->PS3_SXBX5 == "_W"   
                    ConPad1(,,,"TIPVIP")
                    cRetIt := Alltrim(SX5->X5_CHAVE)

                Case PS3->PS3_SXBX5 == "_Y"   
                    ConPad1(,,,"PERFIS")
                    cRetIt := Alltrim(SX5->X5_CHAVE)
                
                OtherWise
                    Help(" ",1, 'Help','TFINA203_CON',"Consulta padrao vinculada ao cadastro do atributo n�o encontrada." , 3, 0 )
            
            EndCase

        EndIf
    
    EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Moeda2S
Converte um c�digo de moeda do Protheus para um simbolo do TRANSPOFRETE

@author By Wise

@since 17/11/2018
/*/
//-------------------------------------------------------------------
User Function Moeda2S(nMoeda)
Local aMoedas := Nil // GetDeParaM() // Obtem as moedas x simbolos
Local nAscan  := 0
Local cRet    := "USD" // Qualquer simbolo diferente do previsto ser� considerado US$ (moeda 2)

If aMoedas == Nil
    aMoedas := StrToKArr2(GetMv("TI_MOEDAS",,"1=BRL;2=USD;4=EUR"), ";")
EndIf

// Procura o simbolo na lista de moedas
nAscan := Ascan(aMoedas, {|e| Left(e,1) == Str(nMoeda,1) })

// Se encontrar, retorna o c�digo da moeda referente ao simbolo
If nAscan > 0
    cRet := SubStr(aMoedas[nAscan],At("=",aMoedas[nAscan])+1)
EndIf

Return cRet

/*/{Protheus.doc} ResConfRec
REaliza a integra��o da confirma��o do pagamento com o TRANSPOFRETE
@author Claudio Donizete
@since 22/10/2018
@version version
@return nil
@example
(examples)
/*/
User Function ResConfRec(aRet, dDataRef, nIdPlano, nIdPgto, cReferencia, cBody)
Local aHeader := {}
Local oJson   := JsonUtil():New()
Local cBody   := ""
Local nTxMoeda	:= 0

Default cReferencia := SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)

Default dDataRef    := SE1->E1_VENCREA

    If Empty(aRet)
        aRet := U_GerAcessRes() // Obtem novo token de acesso
    EndIf

    If aRet[1]
        //Adiciona o header
        Aadd( aHeader, "SecurityToken:" + aRet[2] )
        Aadd( aHeader, "Content-Type: application/json" )
                                    
          //Status de pago somente se a rotina for a de baixas.
        If IsInCallStac("U_JRECTO")
            oJson:PutVal("Status", "Pago")
            oJson:PutVal("codigoExterno", cReferencia )
        EndIf

        oJson:PutVal("data", Transform(DTOS(dDataRef), "@R 9999-99-99")+ "T03:00:00.000Z" )
        oJson:PutVal("referencia", cReferencia)

        //cBody := '{ "data": "' + Transform(DTOS(dDataRef), "@R 9999-99-99") + 'T03:00:00.000Z", "referencia": "'+cReferencia+'" }'
        cBody := oJson:ToJson()
        
    	// Caso seja VGR com moeda internacional, atualiza o cambio com a taxa da baixa do titulo    
		If SE1->E1_MOEDA > 1
			aItems := {} 
			nTxMoeda := U_TxAdiSe5(1)
            If nTxMoeda > 0
            	oJson := nil
	            oJson := JsonUtil():New()
	            oJson:PutVal("Moeda", u_Moeda2S(SE1->E1_MOEDA) )
	            oJson:PutVal("ValorCambioAtualizado", Alltrim(Transform(nTxMoeda, "@E 999999.99999999")))
	            oItems := JsonUtil():New()
	            aadd(aItems, oItems )
	            oJson:PutVal("Items", aItems)
	            aRet := U_ResInteg("000005", StrTran(oJson:ToJson(), "null", ""), aHeader,,.T.,"/"+Alltrim(Str(Val(SE1->E1_NUM)))+"/cambio")
	    	Endif
	    EndIf
        
         aRet := U_ResInteg("000005", cBody, aHeader,,.T.,"/"+Alltrim(Str(nIdPlano))+"/devolucoes/"+Alltrim(Str(nIdPgto))+"/confirmacao")

    EndIf        

    FreeObj(oJson)
    oJson := Nil
    //DelClassIntf()

Return aClone(aRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} Fun��o generica para tratar inciliazador padr�o e 
valida�oes de campos.

@author By Wise

@since 17/11/2018
/*/
//-------------------------------------------------------------------

User Function SXResXFun(cField, lValid, lIniPad, lGatilhos, lIniBrw)

Local xRet          

Default lValid      := .F.
Default lIniPad     := .F.
Default lGatilhos   := .F.
Default lIniBrw     := .F.

    //Valida��es
    If lValid

        Do case

            Case cField == "RD0_XNCARG"
                
                //Se for interno e estiver vazio
                If M->RD0_TIPO == "1" .And. Vazio()
                    Help(" ",1, 'Help','OBRIG RESERV',"Para participantes interno � obrigat�rio informar o n�vel do cargo." , 3, 0 )    
                    xRet := .F.
                Else
                    xRet := .T.
                EndIf
            
            Case cField == "RD0_EMAIL"
                
                //Se o usu�rio ja estiver sido integrado com o TRANSPOFRETE n�o permite alterar
                If ALTERA .And. Alltrim(M->RD0_EMAIL) <> Alltrim(RD0->RD0_EMAIL) .And. !Empty(RD0->RD0_IDRESE)
                    Help(" ",1, 'Help','OBRIG RESERV',"N�o � permitido alterar email de participante que ja foi integrado com o TRANSPOFRETE." , 3, 0 )    
                    xRet := .F.
                Else
                    xRet := .T.
                EndIf

            Case cField == "RD0_XDCINT"

                If Empty(M->RD0_CIC) .And. Vazio()
                    Help(" ",1, 'Help','OBRIG RESERV',"Campo documento internacional � obrigat�rio caso o CPF n�o seja preenchido." , 3, 0 )    
                    xRet := .F.
                Else
                    xRet := .T.
                EndIf
            
            Case cField == "RD0_CIC"

                If Empty(M->RD0_XDCINT) .And. Vazio()
                    Help(" ",1, 'Help','OBRIG RESERV',"Campo do CPF deve ser preenchido caso campo documento internacional esteja vazio." , 3, 0 )    
                    xRet := .F.
                Else
                    xRet := .T.
                EndIf
            
             Case cField == "PS4_ATRIBU"

 				xRet := .T.
               
                DbSelectArea("PS3")
                PS3->(DbSetOrder(1))

                If PS3->(MsSeek(xFilial("PS3") + FwFldGet("PS4_ATRIBU")))

                    If !UPPER(Alltrim(PS3->PS3_RESATB)) $ "GRUPOS/PERFILPOLITICA"
                        Help(" ",1, 'Help','Valida Atributo',"Para inser��o de politicas s� � poss�vel utilizar atributo grupos ou perfilPolitica." , 3, 0 )    
                        xRet := .F.
                    Else
                        xRet := .T.
                    EndIf
                
                EndIf

        EndCase
    
    //Inicializadores
    ElseIf lIniPad

        Do case

            Case cField == "PS1_DESCON"

                If INCLUI
                    xRet := ""
                Else
                
                    DbSelectArea("PS3")
                    PS3->(DbSetOrder(1))

                    If PS3->(MsSeek(xFilial("PS3") + FwFldGet("PS1_ATRIBU")))

                        xRet := Posicione("SX5",1,xFilial("SX5")+PS3->PS3_SXBX5+FwFldGet("PS1_CONATB"),"X5_DESCRI")
                    Else
                        xRet := ""
                    EndIf 
                
                EndIf

        EndCase

    //Gatilhos
    ElseIf lGatilhos

        Do case

            Case cField == "PS1_DESCON"

                DbSelectArea("PS3")
                PS3->(DbSetOrder(1))

                If PS3->(MsSeek(xFilial("PS3") + FwFldGet("PS1_ATRIBU")))

                    xRet := Posicione("SX5",1,xFilial("SX5")+PS3->PS3_SXBX5+FwFldGet("PS1_CONATB"),"X5_DESCRI")

                Else
                    xRet := ""
                EndIf 

        EndCase

    ElseIf lIniBrw

        Do case
        
            Case cField == "PS1_DESCON"
                
                DbSelectArea("PS3")
                PS3->(DbSetOrder(1))

                If PS3->(MsSeek(xFilial("PS3") + PS1->PS1_ATRIBU))

                    xRet := Posicione("SX5",1,xFilial("SX5")+PS3->PS3_SXBX5+PS1->PS1_CONATB,"X5_DESCRI")
                            
                Else
                    xRet := ""
                EndIf

        EndCase 

    EndIf


Return(xRet)


/*/{Protheus.doc} RejeitaPlano
Rejeita um plano, criando uma TAG

@author By Wise

@since 19/11/2018
/*/
//-------------------------------------------------------------------
User Function OBSPLANO(cObs, cIdPlan )
Local aRet    := {}
Local aHeader := {}
Local cJson
local cIdPZB        := ""
Local cMenssagem    := ""
Local nQtdReg       := 0
Local aCriaServ     := {}
Local oJson         := Nil

Default cObs        := ""
Default cIdPlan     := ""
Default lReprocess  := .F.
Default lLote       := .F.
Default cIdPZC      := ""
Default cRegistros  := ""
Default cIdReg      := ""

    if !Empty(cIdPlan) .AND. !Empty(cObs)
        nQtdReg := 1
        aCriaServ := U_MonitRes("000025", 1, nQtdReg)
        cIdPZB := aCriaServ[2]

        //Requisi��o de acesso ao TRANSPOFRETE. 
        aLogin := U_GerAcessRes()   // Obtem novo token de acesso
        If !aLogin[1]
            cMenssagem := "Erro no login do TRANSPOFRETE" 
            U_MonitRes("000025", 2, , cIdPZB, cMenssagem, .F.,cIdPlan )
        Else
            cToken := aLogin[2]
            Aadd( aHeader, "SecurityToken:" + aLogin[2] )
            Aadd( aHeader, "Content-Type: application/json" )
            cJson := ""
            cJson := '{'
            cJson += '"descricao":"'     + Alltrim(cObs)   + '"'
            cJson += '}'
            aRequest := U_ResInteg("000025", encodeutf8(cJson), aHeader,, .T.,"/" + Alltrim(cIdPlan) ,1)        
            oRet     := aRequest[2]
            cJsoRec  := aRequest[3]
            
            If aRequest[1] .AND. ATTISMEMBEROF(oRet,"descricao")
                cObs := ALLTRIM(oRet:descricao) + CRLF + " # " + Dtoc(dDatabase) + " " +  ALLTRIM(cObs)
                cJson := ""
                cJson := '{'
                cJson += '"descricao":"'     + Alltrim(cObs)   + '"'
                cJson += '}'
                
                aRequest := U_ResInteg("000025", encodeutf8(cJson), aHeader,, .T., "/" + Alltrim(cIdPlan) , 2)
                oRet     := aRequest[2]
                cJsoRec  := aRequest[3]

                If aRequest[1]         
                    cMenssagem := "Observa��o Incluida com Sucesso" 
                    U_MonitRes("000025", 2, , cIdPZB, cMenssagem, .T., cIdPlan, cJson,cJsoRec, cIdPlan, lReprocess, lLote, cIdPZC)        
                Else
                    cMenssagem := "Erro na Inclus�o da Observa��o" 
                    U_MonitRes("000025", 2, , cIdPZB, cMenssagem, .F., cIdPlan, cJson,cJsoRec, cIdPlan, lReprocess, lLote, cIdPZC)        
                Endif   

            Else
                cMenssagem := "Erro na Inclus�o da Observa��o" 
                U_MonitRes("000025", 2, , cIdPZB, cMenssagem, .F., cIdPlan, cJson,cJsoRec, cIdPlan, lReprocess, lLote, cIdPZC)        
            Endif     
        EndIf
  
    ENDIF
Return aRequest


/*/{Protheus.doc} PesqNDeb
Rejeita um plano, criando uma TAG

@author By Wise

@since 19/11/2018
/*/
//-------------------------------------------------------------------

User Function PesqNDeb(cFilND, cNunNDeb, cForNDeb)

Local aArea  	:= GetArea()
Local cAliasQry	:= GetNextAlias()
Local cQuery 	:= " "
Local lRet 		:= .F.
Local aRetorno  := {}

If !Empty(cNunNDeb) .And. !Empty(cForNDeb)
	If Select(cAliasQry) > 0
		(cAliasQry)->(DbCloseArea())
	EndIf
	
	cQuery := "SELECT E2_PREFIXO, E2_NUM " + CRLF
	cQuery += "  FROM " + RetSqlName("SE2") + " "+ CRLF
	cQuery += " WHERE " + CRLF //E2_FILIAL = '" + cFilND + "' " + CRLF
	cQuery += "   (E2_NUM = '" + cNunNDeb + "' " + CRLF
	cQuery += "   OR COALESCE(TO_NUMBER(REGEXP_SUBSTR(E2_NUM, '^\d+')), 0) = " + Alltrim(Str(Val(cNunNDeb))) + " " + CRLF
    cQuery += "   OR E2_NUM = '" + StrZero(Val(cNunNDeb),TamSX3("E2_NUM")[1]) + "') " + CRLF
	cQuery += "   AND E2_FORNECE = '" + cForNDeb + "' " + CRLF 
//	cQuery += "   AND E2_XRIDPAG > 0 " + CRLF
	cQuery += "   AND D_E_L_E_T_ = ' ' " + CRLF
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	(cAliasQry)->(DbGoTop())
	  
	If !(cAliasQry)->(Eof()) // retorna o registro
		aRetorno := { (cAliasQry)->E2_PREFIXO,(cAliasQry)->E2_NUM }
	EndIf
	
	If len(aRetorno) >= 1
		lRet := .T.
	EndIF
Endif

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} IsSrvLck
Verifica se o servico esta em processamento
@author  By Wise
@since   16/01/2019
@version V12
/*/
//-------------------------------------------------------------------
User Function IsSrvLck(cIdServ)
Local cFileLock := Eval(bFileLock)
Local nHdlLock  := 0
Local lLocked   := .T.

If File(cFileLock)
    nHdlLock := FOpen(cFileLock, FO_READWRITE + FO_EXCLUSIVE)
    If nHdlLock > 0
        lLocked := .F.
        FClose(nHdlLock)
    EndIf
Else
    lLocked := .F.
EndIf

Return lLocked

//-------------------------------------------------------------------
/*/{Protheus.doc} ResError
Tratamento de error.log no processamento por job
@author  By Wise
@since   19/01/2019
@version V12
/*/
//-------------------------------------------------------------------
User Function ResError( cParFil, cIdEmpresa, cIdPzb, oErro, cIdPZAcr, cFunErr )

Local cErro := oErro:ERRORSTACK

Conout("ResError - Executou o ErrorBlock")

StartJob( "U_ResErrJob()", GetEnvServer(), .F., "00" ,cParFil , cIdEmpresa, cIdPzb, cErro, cIdPZAcr, cFunErr )

BREAK( @oErro )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ResErrJob
Tratamento de error.log no processamento por job
@author  By Wise
@since   19/01/2019
@version V12
/*/
//-------------------------------------------------------------------
User Function ResErrJob( cCodEmp, cCodFil, cIdEmpresa, cIdPzb, cErro, cIdPZAcr, cFunErr, oJSon )

RpcSetType(3)        
RpcSetEnv(cCodEmp,cCodFil)

If ValType( oJson) <> "O"
    U_MonitRes(cIdPZAcr, 2, , cIdPZB,"[" + cFunErr + " falhou] - Erro no processamento da empresa " + cIdEmpresa, .F.,Nil,cErro)
Else
    U_MonitRes(cIdPZAcr, 2, , cIdPZB,"[" + cFunErr + " falhou] - Erro no processamento da empresa " + cIdEmpresa, .F.,cIdEmpresa + " " + cCodFil + " " + cValToChar(oJson:id),FwJsonSerialize(oJson,.F.,.T.),cErro,"ID Empresa+Filial+ID do plano",.F.,.F.)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuPlan
Atualiza plano antes da contabiliza��o de presta��o de contas
@author  By Wise
@since   29/01/2019
@version V12
/*/
//-------------------------------------------------------------------
User Function AtuPlan(dDtIni,dDtFin,lNacional)

Local cQuery    := ""
Local cAliasTrb := GetNextAlias()
Local aRet      := {}
Local aHeader   := {}
Local lRet      := .T.
Local cIdPln    := ""
Local cTpPlnInt	:= GetMv("TI_PLNINT",,"3/9/10/16/19") //3,10,16,19
Local cTpPlnNac	:= GetMv("TI_PLNNAC",,"1/2/4/5/6/7/11/15/17/18") // 1,2,4,5,6,7,9,11,15,17,18
Default lNacional := .T.

	If lNacional
		cIdPln := FormatIn(cTpPlnNac, "/")
	Else
		cIdPln := FormatIn(cTpPlnInt, "/")
	EndIf 

	cQuery := " select " + CRLF
	cQuery += "     PZG.PZG_FILIAL," + CRLF
	cQuery += "     PZG.PZG_ID" + CRLF
	cQuery += " from" + CRLF
	cQuery += "     " + RetSqlName("PZG") + " PZG" + CRLF
	cQuery += " where" + CRLF
	cQuery += "     PZG_FILIAL = '" + xFilial("PZG") + "'" + CRLF
	cQuery += "     and PZG.PZG_DAPVPC between '" + DTOS(dDtIni) + "' AND '" + DTOS(dDtFin) + "'" + CRLF
	cQuery += "     and PZG_IDTPLN in " + cIdPln + CRLF
	cQuery += "     and PZG.D_E_L_E_T_ = ' '" + CRLF
	
	If Select(cAliasTrb) > 0
		(cAliasTrb)->(dbCloseArea())
	Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTrb,.T.,.T.)	
	
	aRet := U_GerAcessRes()
	
	//Adiciona o header
	If aRet[1]
		Aadd( aHeader, "SecurityToken:" + aRet[2] )
		
		While !(cAliasTrb)->(Eof())
		
			aRet := U_ResInteg("000004", , aHeader, ,.T.,"/"+ Alltrim(AlltoChar((cAliasTrb)->PZG_ID)) +"?$select=id,nome,favorecido,datainicio,datafim,tipo,moeda,centrosdecusto,pagamentos,totalPlanejado,despesas,devolucoes,atividade,projeto,totalDeDespesas,dataAutorizacaoFinal,status")
	
			If aRet[1]
				StaticCall(TFINA082, GeraDespesa, 1, { aRet[2] },,.T.)
			Endif
				
			(cAliasTrb)->(DbSkip())
		EndDo
		
	Else
		lRet := .F.
	EndIf	
	
	If Select(cAliasTrb) > 0
		(cAliasTrb)->(dbCloseArea())
	Endif
	
Return lRet
