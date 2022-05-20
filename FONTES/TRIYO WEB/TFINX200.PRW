#Include "Totvs.Ch"
#Include "topconn.Ch"
#Include "Restful.Ch"
#INCLUDE "FILEIO.CH"
#include "tfinx200.ch"
#Include "ApWebSrv.ch"
#Include 'ApWebex.ch'
#Include "Totvs.Ch"
#Include "RESTFUL.Ch"
#Include "FWMVCDef.Ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "RPTDEF.CH" 
#INCLUDE 'APWebSrv.ch'
#include 'Fileio.ch'  
#INCLUDE "TBICODE.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH" 
#INCLUDE "XMLXFUN.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "PRTOPDEF.CH"



Static aHdlLock  := {}
Static bFileLock := {|| MakeDir(GetMv("TI_VGMLOCK",,"\lockreserve\")), Alltrim(GetMv("TI_VGMLOCK",,"\lockreserve\")) + "SRV" + Alltrim(cIdServ) + ".LCK" }

//-------------------------------------------------------------------
/*/{Protheus.doc} GerAcessRes
Realiza autenticação no reserve, gerando token de acesso

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
Local cPassRC4  := GetMv("TI_RC4RES",,"abc123")
Local lCryptPwd := GetMv("TI_CRYRES",,.F.)

If lCryptPwd
    cPassword := fx200decrypt( cPassRC4 )
EndIf

// cRequest += '<Credenciais>'
// cRequest += '<IdLicenciado>' + cIdLicenc + '</IdLicenciado>'
// cRequest += '<Usuario>' + cLogin + '</Usuario>'
// cRequest += '<Senha>' + cPassword + '</Senha>'
// cRequest += '</Credenciais>'

//Adiciona o header
// Aadd( aHeader, 'Content-Type: application/xml' )

cRequest += '{'
cRequest += '  "IdLicenciado": "' + cIdLicenc + '",'
cRequest += '  "Usuario": "' + cLogin + '",'
cRequest += '  "Senha": "' + cPassword + '"'
cRequest += '}'

Aadd( aHeader, 'Content-Type: application/json' )

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
Realiza a requisição das empreas cadastradas no reserve.

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

//Consumo a função que gera o acesso com o reserve e retorna o token
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

                AADD(aFiliais, {SM0->M0_CGC, SM0->M0_CODFIL, SM0->M0_CODIGO})
                
                SM0->(DbSkip())

            EndDo

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
                    AADD(aEmpresas, { aDados[nX]:id, aDados[nX]:cnpj, aDados[nX]:razaoSocial, aFiliais[nPosCodFil][2], If(Type("aDados["+Alltrim(Str(nX))+"]:grupo:id")!="N", -1, aDados[nX]:grupo:id ), aFiliais[nPosCodFil][3]+aFiliais[nPosCodFil][2] } )
                ElseIf aDados[nX]:id == nEmpTerc
                    AADD(aEmpresas, { aDados[nX]:id, aDados[nX]:cnpj, aDados[nX]:razaoSocial, Nil                    , If(Type("aDados["+Alltrim(Str(nX))+"]:grupo:id")!="N", -1, aDados[nX]:grupo:id ), ""                                              } )
                EndIf

            Next nX

            //Ordena por Empresa+Filial do Protheus
            aEmpresas := aSort(aEmpresas,,,{|x,y| x[6] < y[6] })

            aRet[2] := aClone(aEmpresas)
            // REstauro SM0
            SM0->(RestArea(aAreaSm0))
            RestArea(aArea)

        EndIf

        // Libera memória
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
Processa a requisição via rest.

@author By Wise

@since 29/09/2018
/*/
//-------------------------------------------------------------------

User function ResInteg(cIdServ, cJson, aHeader, aParGet, lObjJson, cParamUrl, nOpcMet, cIdJobOrig,CidValue)

Local aRet          := {"","",""} //Posição 1 indica o sucesso da requisição, Posição 2 traz o retorno da requisição em objeto, 3 json de retorno em string
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
Local nTimeOut      := GetMv("TI_VGMTOUT",,4)  //Seta o tempo de timeout
Local nDelTimeout   := GetMv("TI_DELTOUT",,22) //Seta o tempo de timeout para operacoes de DELETE

Default aHeader     := {}
Default aParGet     := {}
Default cJson       := ''
Default lObjJson    := .F.
Default cParamUrl   := ""
Default nOpcMet     := 1
Default cIdJobOrig	:= ''
Default CidValue := ''
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

        //Case para realizar o tipo de requisição preenchido.
        Do case

            Case cTipMet == "1" //Get

                If Len(aParGet) > 0
                    cParam := fStrGet(aParGet)
                    CidValue:= fStrGet(aParGet)
                Else
                    cParam := cParamUrl
                EndIf
                
                //Monta objeto para consumo
                If empty(CidValue)
                    oRest := FWREST():New(cUrl + cMetodo)
                Else
                    oRest := FWREST():New(cUrl + cMetodo + CidValue  )
                EndIF
                //Seta parametros
                oRest:SetPath(cParam)
              
                lRet := oRest:Get(aHeader)
              

                //Verifico se existe conteudo de retorno
                If oRest:GetResult() == Nil
                    aRet[1] := .F.
                    aRet[2] := "Falha na conexão com a URL."
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
                 If empty(CidValue) 
                    oRest:SetPath(cMetodo+cParamUrl)
                Else
                    oRest:SetPath(CidValue+ cMetodo)
                EndIF

                //Seta o JSON como parametro
				If EncodeUtf8(cJson) <> Nil
                    cJson := EncodeUtf8(cJson)
                EndIf

                oRest:SetPostParams(cJson)
                
                //Aplica timeout reduzido na conferência de nota de débito.
                If AllTrim(cIdJobOrig) $ SuperGetMv("TI_200TPST", , "000029")
                //Controla o tempo de timeout do processamento do post
                	oRest:nTimeOut := nTimeOut
                ElseIf AllTrim(cIdServ) $ SuperGetMv("TI_200TDIV", , "000020")
                	//Aumenta o timeout de cadastramento da DBK para 300 segundos (5 minutos).
                	oRest:nTimeOut := GetMv("TI_200TTIM", , 300)//300 SEGUNDOS.
                EndIf
                        
                //Realizo o Post do JSON
                lRet := oRest:Post(aHeader)
 
                //Verifico se existe conteudo de retorno
                If oRest:GetResult() == Nil
                    aRet[1] := .F.
                    aRet[2] := "Falha na conexão com a URL."
                    cResult := oRest:GetLAstError()
                    cResult := DecodeUtf8(cResult)
                    FWJsonDeserialize( cResult ,@oJSon)
                Else
                    cResult := oRest:GetResult()
                    If Empty(cResult) 
                    	If Upper(oRest:getlasterror()) == "204 NOCONTENT" .Or. Upper(oRest:getlasterror()) == "200 OK" .Or. Upper(oRest:getlasterror()) == '201 CREATED'
                    		lRet := .T.
                    		cResult := '{"resultado": "OK"}'
                    	EndIf
                    Else
                        If GetMv("TF_200DELS", , .T.)//Remove a chave de string
                            If Left(cResult,8) == '<string>' .And. Right(cResult,9) == '</string>'
                                cResult := Substr(cResult, 9)
                                cResult := Substr(cResult, 1, len(cResult)-9)
                                cResult := '"'+cResult+'"' 
                            EndIf
                        EndIf
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
                    aRet[2] := "Falha na conexão com a URL."
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
                
                //Seta o timeout reduzido para operacoes de exclusao
                oRest:nTimeOut := nDelTimeout

                //Aplica timeout reduzido na deleção de usuários.
                If AllTrim(cIdServ) $ SuperGetMv("TI_200TDEL", , "000003")
                	//Controla o tempo de timeout do processamento do post
                	oRest:nTimeOut := nTimeOut
                EndIf
                
                lRet := oRest:Delete(aHeader)

                //Verifico se existe conteudo de retorno
                If oRest:GetResult() == Nil
                    aRet[1] := .F.
                    aRet[2] := "Falha na conexão com a URL."
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
                    
                    //O metodo em caso de falha retorna erros genericos, então pego o JSON do resultado mesmo para tratar o erro.
                    oJSon := TJSonParser():New()
                    oJSon:Json_Parser( cResult /*strJson*/,Len( cResult ) /*lenStrJson*/, @aJSonField /*@jsonfields*/, @nRetParser /*@nRetParser*/ )

                    aRet[1] := .F.
                    aRet[2] := aJSonField
					aRet[3] := cResult
                    
                EndIf


        EndCase
    
Else

        cMenssagem := "Id do serviço enviado não foi encontrado no cadastro de serviços."
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
Função de atualização do monitor de integração.

@param  cIdServ, string, recebe id de cadastro na tabela PZA
        nOpc, boolean, 1 = inclusão, 2 = alteração / atualização
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

If nPosLock == 0
    aAdd(aHdlLock,{cIdServ,-1})
    nPosLock := Len(aHdlLock)
EndIf

DbSelectArea("PZA")
PZA->(DbSetOrder(1))

If PZA->(MsSeek(xFilial("PZA") + cIdServ))

    //Inclusão
    If nOpc == 1

        If !File(cFileLock)
            aHdlLock[nPosLock][2] := FCreate(cFileLock)
        Else
            aHdlLock[nPosLock][2] := FOpen(cFileLock, FO_READWRITE + FO_EXCLUSIVE)
        Endif

        //Adquiri o próximo id de processamento para o serviço.
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

        //Geração da PZC
        If !lReprocess .Or. (lReprocess .And. lLote)

            //Gera próximo ID da PZC
            cIdPZC := fPZCId(cPZBId, cIdServ)
            
            If lExcec
                cStatusPZC  := "E"
            Else    
                cStatusPZC  := IIf(lSucess,"S","F")
            EndIf

            //Efetua a gravação da PZC
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

        //Efetua a gravação da PZD
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

        aRet[1] := .T.
        aRet[2] := cIdPZC

    ElseIf nOpc == 3 //Conclusão

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
                    PZB->PZB_MENSAG := IIf(lAutentic, "Falha no login com o Reserve.", "Processamento falhou.")
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
    aRet[2] := "Id de serviço informado não foi encontrado na tabela PZA."
EndIf
    
Return(aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} fGerIdPZB
Função para gerar próximo Id para a PZB para o serviço informado.

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
Função para gerar próximo Id para a PZC para o processo informado.

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
Função para gerar próximo Id para a PZD de acordo com o codigo de log
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
Função para tratar mensagem de observação.

@author By Wise
@since 30/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------

User function fNoAcento(cRetorno)

Local nX        := 0
Local aSubst    := {    {"á","a"},;
                        {"â","a"},;
                        {"ã","a"},;
                        {"à","a"},;
                        {"Á","a"},;
                        {"Â","a"},;
                        {"Ã","a"},;
                        {"À","a"},;
                        {"é","e"},;
                        {"ê","e"},;
                        {"è","e"},;
                        {"í","i"},;
                        {"î","i"},;
                        {"ì","i"},;
                        {"ó","o"},;
                        {"ô","o"},;
                        {"õ","o"},;
                        {"ò","o"},;
                        {"ú","u"},;
                        {"ù","u"},;
                        {"û","u"},;
                        {"ç","c"},;
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
Obtem o próximo número sequencial de um determinado campo, independente da filial.
@author Claudio Donizete
@since 10/11/2016
@version version
@return nil
@example
(examples)
/*/
User Function NumSeq(cAlias,cCampo,cWhere) 
Local cAliasTrb := GetNextAlias()
Local cRet      := ""
Local cExp      := "MAX("+cCampo+") " + cCampo
Local cTable    := RetSqlName(cAlias)
Local cQuery    := ""

Default cWhere := ""

cWhere := cWhere + If(!Empty(cWhere), " AND ", "") +  " D_E_L_E_T_ = ' ' "

cQuery := " SELECT " + cExp
cQuery += " FROM " + RetSqlName(cAlias)
cQuery += " WHERE " + cWhere

If Select(cAliasTrb) > 0; (cAliasTrb)->(dbCloseArea()); Endif  
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTrb,.T.,.T.)


cRet := SOMA1((cAliasTrb)->&cCampo)
(cAliasTrb)->(DbCloseArea())

Return cRet
/*/{Protheus.doc} ResConfPg
REaliza a integração da confirmação do pagamento com o Reserve
@author Claudio Donizete
@since 22/10/2018
@version version
@return nil
@example
(examples)
/*/
User Function ResConfPg(aRet, dDataRef, nIdPlano, nIdPgto, cReferencia, nTxMoeda,cBody, lBordero, lJaPgto)
Local aLogMnt    := {}
Local aLogReg    := {}
Local aLogin     := {}
Local aRetConfirm:= {}
Local aRetCambio := {}
Local aHeader    := {}
Local cURL       := ""
Local oJson      := JsonUtil():New()
Local aItems     := {}
Local oItems
Local cChaveM
Local lMoedIntPl := .F.
Local cPrefAdi
Local lConfPag   := .F.
Local cCodPZA    := "000005"
Local cIdPZB     := ""
Local cIdPZC     := ""
Local cParamCall := ""

Default cReferencia := SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
Default dDataRef    := IIf(Empty(SE2->E2_BAIXA),SE2->E2_VENCREA,SE2->E2_BAIXA)
Default nTxMoeda    := SE5->E5_TXMOEDA
Default cBody       := ""
Default lBordero    := .F.
Default lJaPgto     := .F.

cParamCall := "Parâmetros da chamada da função U_ResConfPg" + CRLF
cParamCall += "-------------------------------------------" + CRLF
cParamCall += "aRet.......: " + Varinfo("",aRet,Nil,.F.,.F.) + CRLF
cParamCall += "dDataRef...: " + AlltoChar(dDataRef) + CRLF
cParamCall += "nIdPlano...: " + AlltoChar(nIdPlano) + CRLF
cParamCall += "nIdPgto....: " + AlltoChar(nIdPgto) + CRLF
cParamCall += "cReferencia: " + AlltoChar(cReferencia) + CRLF
cParamCall += "nTxMoeda...: " + AlltoChar(nTxMoeda) + CRLF
cParamCall += "cBody......: " + AlltoChar(cBody) + CRLF
cParamCall += "lJaPgto....: " + AlltoChar(lJaPgto)


// If Empty(aRet) .Or. !aRet[1]
aLogin := U_GerAcessRes() // Obtem novo token de acesso
// EndIf

If aLogin[1]

    //Adiciona o header
    Aadd( aHeader, "SecurityToken:" + aLogin[2] )
    Aadd( aHeader, "Content-Type: application/json" )

    //Inicia o monitor
    aLogMnt := U_MonitRes(cCodPZA,1,0)
    cIdPZB := aLogMnt[2]

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
        cPrefDia := U_GetPrefixo("3",PZG->PZG_IDTPLN)[1] // Obtem os prefixos de Diária de todos os tipos de planos de viagem
        cPrefAdt := U_GetPrefixo("2",PZG->PZG_IDTPLN)[1] // Obtem os prefixos de Diária de todos os tipos de planos de viagem
        cPrefAdi := U_GetPrefixo("6")[1] // Obtem os prefixos de Reembolsos de todos os tipos de planos de viagem
        // Só atualiza o código externo, quando não for pagto de diária/adiantamento
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

    //Status OK (PZC)
    aLogReg := U_MonitRes(cCodPZA, 2, , cIdPZB, "Chamada do processo de agendamento/confirmação de pagamento", .T., cFilAnt + " " + cValToChar(nIdPlano) + " " + cValToChar(nIdPgto), cParamCall, , "Filial+ID do plano+ID do Pagamento", /*lReprocess*/ .F., /*lLote*/.F., , .F.)
    cIdPZC  := aLogReg[2]

    If SE2->E2_MOEDA > 1 .And. lJaPgto .And. !lMoedIntPl
        oJson := nil
        oJson := JsonUtil():New()
        //{ “Moeda”: “EUR”, "ValorCambioAtualizado": "1,02", "Items": [] } 
        oJson:PutVal("Moeda", u_Moeda2S(SE2->E2_MOEDA) )
        oJson:PutVal("ValorCambioAtualizado", Alltrim(Transform(nTxMoeda, "@E 999999.99999999")))
        //oJson:PutVal("ValorCambioAtualizado", Alltrim(Str(nTxMoeda)))
        oItems := JsonUtil():New()
        aadd(aItems, oItems )
        oJson:PutVal("Items", aItems)
        aRetCambio := U_ResInteg(cCodPZA, StrTran(oJson:ToJson(), "null", ""), aHeader,,.T.,"/"+Alltrim(Str(Val(SE2->E2_NUM)))+"/cambio")

        If aRetCambio[1]
            lConfPag := .T.

            //Status OK (PZC)
            U_MonitRes(cCodPZA, 2, , cIdPZB, "Câmbio atualizado", .T., cFilAnt + " " + cValToChar(nIdPlano) + " " + cValToChar(nIdPgto), StrTran(oJson:ToJson(), "null", ""), aRetCambio[3], "Filial+ID do plano+ID do Pagamento", /*lReprocess*/ .T., /*lLote*/.F., cIdPZC, .F.)
        
        Else

            //Status Erro (PZC)
            U_MonitRes(cCodPZA, 2, , cIdPZB, "Erro ao atualizar câmbio", .F., cFilAnt + " " + cValToChar(nIdPlano) + " " + cValToChar(nIdPgto), StrTran(oJson:ToJson(), "null", ""), aRetCambio[3], "Filial+ID do plano+ID do Pagamento", /*lReprocess*/ .T., /*lLote*/.F., cIdPZC, .F.)

        EndIf
    Else
        lConfPag := .T.
    EndIf

    // Só baixa o plano, caso tenha conseguido atualizar o câmbio
    If lConfPag
        aRetConfirm := U_ResInteg(cCodPZA, cBody, aHeader,,.T.,"/"+Alltrim(Str(nIdPlano))+"/pagamentos/"+Alltrim(Str(nIdPgto))+"/confirmacao")

        If aRetConfirm[1]
            //Status OK (PZC)
            U_MonitRes(cCodPZA, 2, , cIdPZB, IIf(lJaPgto,"Pagamento confirmado","Pagamento agendado"), .T., cFilAnt + " " + cValToChar(nIdPlano) + " " + cValToChar(nIdPgto), cBody, aRetConfirm[3], "Filial+ID do plano+ID do Pagamento", /*lReprocess*/ .T., /*lLote*/.F., cIdPZC, .F.)
        Else
            //Status Erro (PZC)
            U_MonitRes(cCodPZA, 2, , cIdPZB, IIf(lJaPgto,"Erro ao confirmar pagamento","Erro ao agendar pagamento"), .F., cFilAnt + " " + cValToChar(nIdPlano) + " " + cValToChar(nIdPgto), cBody, aRetConfirm[3], "Filial+ID do plano+ID do Pagamento", /*lReprocess*/ .T., /*lLote*/.F., cIdPZC, .F.)
        EndIf
    EndIf

    // finaliza o Monitor
    U_MonitRes(cCodPZA, 3, , cIdPZB, "Processamento concluido", .T.)
  
EndIf

FreeObj(oJson)
oJson := Nil
DelClassIntf()

// cURL := "/"+Alltrim(Str(nIdPlano))+"/pagamentos/"+Alltrim(Str(nIdPgto))+"/confirmacao"

// Conout(Varinfo("cBody->",cBody))
// Conout(Varinfo("cURL->", cURL))
// Conout(Varinfo("aRet->", aRet))

Return aClone(aRetConfirm)

//-------------------------------------------------------------------
/*/{Protheus.doc} GerAcessRes
Realiza autenticação no reserve, gerando token de acesso

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
Consulta atributos cadastrados para o reserve

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

DEFINE MSDIALOG oDlg TITLE "Atributos Reserve" From 000,000 TO 360,570 PIXEL
@ 020,000 MSPANEL oPanel2 SIZE 290,130 OF oDlg
@ 005, 004 GET cGetPesq   SIZE 239, 010	PICTURE "XXXX"	OF oDlg PIXEL
@ 005, 243 BUTTON 	oButPesq	PROMPT "Pesquisar"	SIZE 037, 012	ACTION (nPos := ItemPesq(), oLbx:nAt:=nPos, oLbx:Refresh()) OF oDlg PIXEL
@ 30,05 LISTBOX oLbx FIELDS HEADER "Codigo","Descricao","Atributo Reserve" SIZE 60, 30, 100 OF oPanel2 PIXEL   
@ 159, 206 BUTTON oButOK PROMPT "&OK"  SIZE 037, 012 ACTION (cRetIt :=  Alltrim(aCampos[oLbx:nAt,1]), oDlg:End() ) OF oDlg PIXEL
@ 159, 245 BUTTON oButClose PROMPT "&Cancel"  SIZE 037, 012 ACTION (cRetIt := "", oDlg:End() ) OF oDlg PIXEL 

oLbx:SetArray(aCampos)                                                
oLbx:bLine := {|| {aCampos[oLbx:nAt,1], aCampos[oLbx:nAt,2], aCampos[oLbx:nAt,3]}}   
oLbx:bLDblclick := {|| {cRetIt :=  Alltrim(aCampos[oLbx:nAt,1]),oDlg:End() }}
oLbx:align:= CONTROL_ALIGN_ALLCLIENT	
		         	
ACTIVATE MSDIALOG oDlg CENTERED

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ItemPesq
Localizar a linha do array de acordo com o que foi digitado pelo
usuário na caixa de pesquisa.

@author By Wise
@since 29/09/2018
/*/
//-------------------------------------------------------------------
Static function ItemPesq()
	
nPos := aScan(aCampos,{|x| Alltrim(x[1])==Alltrim(Upper(cGetPesq))})
	
If nPos == 0
		nPos := 1
EndIf	

Return(nPos)

//-------------------------------------------------------------------
/*/{Protheus.doc} RetAtb

Função necessária, para retornar a variavel para a tela.

@author By Wise
@since 29/09/2018
/*/
//-------------------------------------------------------------------
User function RetAtb()

Return cRetIt         	

//-------------------------------------------------------------------
/*/{Protheus.doc} DesAtbRes
Chama consulta padrão de acordo com atributo informado.

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
                    Help(" ",1, 'Help','TFINA203_CON',"Consulta padrao vinculada ao cadastro do atributo não encontrada." , 3, 0 )
            
            EndCase

        EndIf
    
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Moeda2S
Converte um código de moeda do Protheus para um simbolo do Reserve

@author By Wise
@since 17/11/2018
/*/
//-------------------------------------------------------------------
User Function Moeda2S(nMoeda)
Local aMoedas := Nil // GetDeParaM() // Obtem as moedas x simbolos
Local nAscan  := 0
Local cRet    := "USD" // Qualquer simbolo diferente do previsto será considerado US$ (moeda 2)

If aMoedas == Nil
    aMoedas := StrToKArr2(GetMv("TI_MOEDAS",,"1=BRL;2=USD;4=EUR"), ";")
EndIf

// Procura o simbolo na lista de moedas
nAscan := Ascan(aMoedas, {|e| Left(e,1) == Str(nMoeda,1) })

// Se encontrar, retorna o código da moeda referente ao simbolo
If nAscan > 0
    cRet := SubStr(aMoedas[nAscan],At("=",aMoedas[nAscan])+1)
EndIf

Return cRet

/*/{Protheus.doc} ResConfRec
REaliza a integração da confirmação do pagamento com o Reserve
@author Claudio Donizete
@since 22/10/2018
@version version
@return nil
@example
(examples)
/*/
User Function ResConfRec(aRet, dDataRef, nIdPlano, nIdPgto, cReferencia, cBody)
Local aLogMnt    := {}
Local aLogReg    := {}
Local aLogin     := {}
Local aRetConfirm:= {}
Local aRetCambio := {}
Local aHeader    := {}
Local oJson      := JsonUtil():New()
Local cBody      := ""
Local nTxMoeda   := 0
Local lConfDev   := .F.
Local cCodPZA    := "000005"
Local cIdPZB     := ""
Local cIdPZC     := ""
Local cParamCall := ""
Local lJaPgto    := .F.

Default cReferencia := SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)

Default dDataRef    := SE1->E1_VENCREA

cParamCall := "Parâmetros da chamada da função U_ResConfRec" + CRLF
cParamCall += "--------------------------------------------" + CRLF
cParamCall += "aRet.......: " + Varinfo("",aRet,Nil,.F.,.F.) + CRLF
cParamCall += "dDataRef...: " + AlltoChar(dDataRef) + CRLF
cParamCall += "nIdPlano...: " + AlltoChar(nIdPlano) + CRLF
cParamCall += "nIdPgto....: " + AlltoChar(nIdPgto) + CRLF
cParamCall += "cReferencia: " + AlltoChar(cReferencia) + CRLF
cParamCall += "cBody......: " + AlltoChar(cBody)

aLogin := U_GerAcessRes() // Obtem novo token de acesso

If aLogin[1]
    //Adiciona o header
    Aadd( aHeader, "SecurityToken:" + aLogin[2] )
    Aadd( aHeader, "Content-Type: application/json" )

    //Inicia o monitor
    aLogMnt := U_MonitRes(cCodPZA,1,0)
    cIdPZB := aLogMnt[2]

    //Status de pago somente se a rotina for a de baixas.
    If IsInCallStac("U_JRECTO")
        oJson:PutVal("Status", "Pago")
        oJson:PutVal("codigoExterno", cReferencia )
        lJaPgto := .T.
    EndIf

    oJson:PutVal("data", Transform(DTOS(dDataRef), "@R 9999-99-99")+ "T03:00:00.000Z" )
    oJson:PutVal("referencia", cReferencia)

    //cBody := '{ "data": "' + Transform(DTOS(dDataRef), "@R 9999-99-99") + 'T03:00:00.000Z", "referencia": "'+cReferencia+'" }'
    cBody := oJson:ToJson()

    //Status OK (PZC)
    aLogReg := U_MonitRes(cCodPZA, 2, , cIdPZB, "Chamada do processo de agendamento/confirmação de devolução", .T., cFilAnt + " " + cValToChar(nIdPlano) + " " + cValToChar(nIdPgto), cParamCall, , "Filial+ID do plano+ID da Devolução", /*lReprocess*/ .F., /*lLote*/.F., , .F.)
    cIdPZC  := aLogReg[2]
    
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
            aRetCambio := U_ResInteg(cCodPZA, StrTran(oJson:ToJson(), "null", ""), aHeader,,.T.,"/"+Alltrim(Str(Val(SE1->E1_NUM)))+"/cambio")

            If lConfDev := aRetCambio[1]
                //Status OK (PZC)
                U_MonitRes(cCodPZA, 2, , cIdPZB, "Câmbio atualizado", .T., cFilAnt + " " + cValToChar(nIdPlano) + " " + cValToChar(nIdPgto), StrTran(oJson:ToJson(), "null", ""), aRetCambio[3], "Filial+ID do plano+ID da Devolução", /*lReprocess*/ .T., /*lLote*/.F., cIdPZC, .F.)
            Else
                //Status Excecao (PZC)
                U_MonitRes(cCodPZA, 2, , cIdPZB, "Erro ao atualizar câmbio", .F., cFilAnt + " " + cValToChar(nIdPlano) + " " + cValToChar(nIdPgto), StrTran(oJson:ToJson(), "null", ""), aRetCambio[3], "Filial+ID do plano+ID da Devolução", /*lReprocess*/ .T., /*lLote*/.F., cIdPZC, .T.)
            EndIf
        Endif
    Else
        lConfDev := .T.
    EndIf
    
    //Confirma a devolução
    aRetConfirm := U_ResInteg(cCodPZA, cBody, aHeader,,.T.,"/"+Alltrim(Str(nIdPlano))+"/devolucoes/"+Alltrim(Str(nIdPgto))+"/confirmacao")

    If aRetConfirm[1]
        //Status OK (PZC)
        U_MonitRes(cCodPZA, 2, , cIdPZB, IIf(lJaPgto,"Devolução confirmada","Devolução agendada"), .T., cFilAnt + " " + cValToChar(nIdPlano) + " " + cValToChar(nIdPgto), cBody, aRetConfirm[3], "Filial+ID do plano+ID da Devolução", /*lReprocess*/ .T., /*lLote*/.F., cIdPZC, .F.)
    Else
        //Status Erro (PZC)
        U_MonitRes(cCodPZA, 2, , cIdPZB, IIf(lJaPgto,"Erro ao confirmar devolução","Erro ao agendar devolução"), .F., cFilAnt + " " + cValToChar(nIdPlano) + " " + cValToChar(nIdPgto), cBody, aRetConfirm[3], "Filial+ID do plano+ID da Devolução", /*lReprocess*/ .T., /*lLote*/.F., cIdPZC, .F.)
    EndIf

    // finaliza o Monitor
    U_MonitRes(cCodPZA, 3, , cIdPZB, "Processamento concluido", .T.)

EndIf

FreeObj(oJson)
oJson := Nil
//DelClassIntf()

Return aClone(aRetConfirm)


//-------------------------------------------------------------------
/*/{Protheus.doc} SXResXFun

Função generica para tratar iniciliazador padrão e 
validaçoes de campos.

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

//Validações
If lValid

        Do case

            Case cField == "RD0_XNCARG"
                
                //Se for interno e estiver vazio
                If M->RD0_TIPO == "1" .And. Vazio()
                    Help(" ",1, 'Help','OBRIG RESERV',"Para participantes interno é obrigatório informar o nível do cargo." , 3, 0 )    
                    xRet := .F.
                Else
                    xRet := .T.
                EndIf
            
            Case cField == "RD0_EMAIL"
                
                //Se o usuário ja estiver sido integrado com o reserve não permite alterar
                If ALTERA .And. Alltrim(M->RD0_EMAIL) <> Alltrim(RD0->RD0_EMAIL) .And. !Empty(RD0->RD0_IDRESE)
                    Help(" ",1, 'Help','OBRIG RESERV',"Não é permitido alterar email de participante que ja foi integrado com o Reserve." , 3, 0 )    
                    xRet := .F.
                Else
                    xRet := .T.
                EndIf

            Case cField == "RD0_XDCINT"

                If Empty(M->RD0_CIC) .And. Vazio()
                    Help(" ",1, 'Help','OBRIG RESERV',"Campo documento internacional é obrigatório caso o CPF não seja preenchido." , 3, 0 )    
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
                        Help(" ",1, 'Help','Valida Atributo',"Para inserção de politicas só é possível utilizar atributo grupos ou perfilPolitica." , 3, 0 )    
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

//-------------------------------------------------------------------
/*/{Protheus.doc} OBSPLANO
Rejeita um plano, criando uma TAG.

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

        //Requisição de acesso ao reserve. 
        aLogin := U_GerAcessRes()   // Obtem novo token de acesso
        If !aLogin[1]
            cMenssagem := "Erro no login do Reserve" 
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
                    cMenssagem := "Observação Incluida com Sucesso" 
                    U_MonitRes("000025", 2, , cIdPZB, cMenssagem, .T., cIdPlan, cJson,cJsoRec, cIdPlan, lReprocess, lLote, cIdPZC)        
                Else
                    cMenssagem := "Erro na Inclusão da Observação" 
                    U_MonitRes("000025", 2, , cIdPZB, cMenssagem, .F., cIdPlan, cJson,cJsoRec, cIdPlan, lReprocess, lLote, cIdPZC)        
                Endif   

            Else
                cMenssagem := "Erro na Inclusão da Observação" 
                U_MonitRes("000025", 2, , cIdPZB, cMenssagem, .F., cIdPlan, cJson,cJsoRec, cIdPlan, lReprocess, lLote, cIdPZC)        
            Endif     
        EndIf
  
ENDIF
Return aRequest

//-------------------------------------------------------------------
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
Atualiza plano antes da contabilização de prestação de contas
@author  By Wise
@since   29/01/2019
@version V12
/*/
//-------------------------------------------------------------------
User Function AtuPlan(dDtIni,dDtFin,lNacional)

Local cQuery    := ""
Local cAliasTrb := GetNextAlias()
Local aRet      := {}
Local aRetPlan  := {}
Local aHeader   := {}
Local lRet      := .T.
Local cIdPln    := ""
Local cTpPlnInt	:= GetMv("TI_PLNINT",,"3/9/10/16/19") //3,10,16,19
Local cTpPlnNac	:= GetMv("TI_PLNNAC",,"1/2/4/5/6/7/11/15/17/18") // 1,2,4,5,6,7,9,11,15,17,18
Local cMsgVld   := ""
Local aEntPlan  := {}

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
		
        aRetPlan := U_ResInteg("000004", , aHeader, ,.T.,"/"+ Alltrim(AlltoChar((cAliasTrb)->PZG_ID)) +"?$select=id,nome,favorecido,datainicio,datafim,datadefechamento,tipo,moeda,centrosdecusto,pagamentos,totalPlanejado,despesas,devolucoes,atividade,projeto,totalDeDespesas,dataAutorizacaoFinal,status,camposExtras")
	
			If aRetPlan[1]
                If u_ResVldCC(aRetPlan[2] , @cMsgVld, @aEntPlan)
				   // StaticCall(TFINA082, GeraDespesa, 1, { aRetPlan[2] }, Nil,.T., Nil, Nil, aEntPlan)
                EndIf
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

//-------------------------------------------------------------------
/*/{Protheus.doc} ResVldCC
Valida as entidades contabeis do plano de viagem
@author  By Wise
@since   01/07/2019
@version V12
@see
Estrutura do array aRetEntPlan[n][y]
Onde z = Indice das combinacoes contabeis encontradas no plano
Onde y =    1  - Tipo (PLAN, DESP ou DEFAULT para Plano, Despesa ou Valor Padrao do Plano respectivamente)
            2  - Id (Id do Plano ou da Despesa - 'oJson[n]:id' ou 'oJson[n]:despesas[y]:id')
            3  - Id Rateio (Id do rateio - 'oJson[n]:centrosDeCusto[y]:id' ou 'oJson[n]:despesas[y]:centrosDeCusto[z]:id')
            4  - Centro de Custo como está gravado no Reserve
            5  - CC do Projeto (retornado pelo CFP ou PSA) ou em branco para planos de centro de custo
            6  - Item contabil do plano
            7  - Classe de valor do plano
            8  - Centro de custo validado pela DBK
            9  - Item Contabil validado pela DBK
            10 - Classe de valor validado pela DBK
            11 - Indica se é projeto ou não (T/F)
/*/
//-------------------------------------------------------------------
User Function ResVldCC(oJsonPlan,cMsgValid,aRetEntPlan)

Local cCCPlan   := ""
Local cItPlan   := ""
Local cClPlan   := ""
Local cCCProj   := ""
Local cCCDesp   := ""
Local cCCDsPr   := ""
Local cCCVld    := ""
Local cItVld    := ""
Local cClVld    := ""
Local cQryPZI   := ""
Local cAliasQry := ""
Local aCCDesp   := {}
Local aRetAux   := {}
Local nDesp     := 0
Local nRat      := 0
Local lRet      := .T.
Local lPrjPlan  := .F.
Local lPrjDesp  := .F.
Local nIdPlano  := 0
Local nIdDesp   := 0
Local nIdRat    := 0
Local cIdsSemCC	:= GetMv("TI_F200SCC", , "31/106")

Default cMsgValid   := ""
Default aRetEntPlan := {}

nIdPlano    := oJsonPlan:id
cMsgValid   := ""

//TODO - A função não está prevendo que existirá rateio de centro de custo no nível de plano (utiliza o primeiro)
//Verificar se será necessária implementação posterior
//Estrutura do rateio de centro de custo no plano: oJsonPlan:centrosDeCusto[n]

//Centro de custo do plano
If AttIsMemberOf(oJsonPlan, "centrosDeCusto")
    If Len(oJsonPlan:centrosDeCusto) > 0
        cCCPlan := oJsonPlan:centrosDeCusto[1]:centroDeCusto:nome
        nIdRat  := oJsonPlan:centrosDeCusto[1]:id
    EndIf
EndIf

//Item contabil do plano
If AttIsMemberOf(oJsonPlan, "atividade")
    cItPlan   := oJsonPlan:atividade:nome
EndIf

//Classe de valor do plano
If AttIsMemberOf(oJsonPlan, "projeto")
    cClPlan   := oJsonPlan:projeto:nome
EndIf

//Verifica se todas as entidades estao preenchidas
If Empty(cCCPlan);
    .Or. Empty(cItPlan);
    .Or. Empty(cClPlan)
    
    lRet := .F.
    cMsgValid += "O plano não possui todas as entidades contábeis preenchidas: " + AlltoChar(nIdPlano)
EndIf

lPrjPlan := (Substr(Alltrim(cCCPlan),1,1) == "P")

// Converte o CC em caso de projetos
If lPrjPlan
    cCCProj := U_ConCCPrj(Alltrim(cCCPlan))
    If !(lRet := !Empty(cCCProj))
        cMsgValid += IIf(!Empty(cMsgValid),CRLF,"") + "Plano. Não foi possível recuperar o centro de custo do projeto: " + cCCPlan
    EndIf
EndIf

If lRet

    // Valida a combinação do plano
    cCCVld := IIf(lPrjPlan, cCCProj, cCCPlan)
    cItVld := cItPlan
    cClVld := cClPlan

    If !u_VLDCONT( @cCCVld, @cItVld, @cClVld,.F., .T.)
        lRet := .F.
        cMsgValid += IIf(!Empty(cMsgValid),CRLF,"") + "Plano. Combinação contábil inválida (VLDCONT): " + IIf(lPrjPlan, cCCProj, cCCPlan) + "/" + cItPlan +"/" + cClPlan
    EndIf

EndIf

aadd(aRetAux,"PLAN")    //1  - Tipo
aadd(aRetAux,nIdPlano)  //2  - Id
aadd(aRetAux,nIdRat)    //3  - Id Rateio
aadd(aRetAux,cCCPlan)   //4  - CC No Reserve
aadd(aRetAux,cCCProj)   //5  - Se Projeto - CC do Projeto (retornado pelo CFP ou PSA)
aadd(aRetAux,cItPlan)   //6  - Item do plano
aadd(aRetAux,cClPlan)   //7  - Classe de valor do plano
aadd(aRetAux,cCCVld)    //8  - Centro de custo validado pela DBK
aadd(aRetAux,cItVld)    //9  - Item Contabil validado pela DBK
aadd(aRetAux,cClVld)    //10 - Classe de valor validado pela DBK
aadd(aRetAux,lPrjPlan)  //11 - Indica se é projeto ou não

aadd(aRetEntPlan,aClone(aRetAux)) //Adiciona as informacoes do plano no retorno

//Valida as despesas
If AttIsMemberOf(oJsonPlan, "despesas")
    For nDesp := 1 To Len(oJsonPlan:despesas)

        lPrjDesp := .F.
        nIdDesp  := oJsonPlan:despesas[nDesp]:id

        For nRat := 1 To Len(oJsonPlan:despesas[nDesp]:centrosDeCusto)

            If AttIsMemberOf(oJsonPlan:despesas[nDesp], "centrosDeCusto") .And. Len(oJsonPlan:despesas[nDesp]:centrosDeCusto) > 0
                cCCDesp := oJsonPlan:despesas[nDesp]:centrosDeCusto[nRat]:centroDeCusto:nome
                cCCDsPr := ""

                nIdRat := oJsonPlan:despesas[nDesp]:centrosDeCusto[nRat]:id

                // Converte o CC em caso de projetos
                lPrjDesp := (Substr(Alltrim(cCCDesp),1,1) == "P")
                If lPrjDesp
                    cCCDsPr := U_ConCCPrj(Alltrim(cCCDesp))
                    If Empty(cCCDsPr)
                        lRet := .F.
                        cMsgValid += IIf(!Empty(cMsgValid),CRLF,"") + "Despesa " + Alltrim(AlltoChar(nDesp)) + ". Não foi possível recuperar o centro de custo do projeto: " + cCCDesp
                    EndIf
                EndIf

                If Empty(cCCDesp)
                    lRet := .F.
                    cMsgValid += IIf(!Empty(cMsgValid),CRLF,"") + "Despesa " + Alltrim(AlltoChar(nDesp)) + ". Centro de custo não informado."
                EndIf

                cCCVld := ""
                cItVld := ""
                cClVld := ""

                If !Empty(cCCDesp) .And. IIf(lPrjDesp, !Empty(cCCDsPr), .T.) .And. !Empty(cItPlan) .And. !Empty(cClPlan)

                    cCCVld := IIf(lPrjDesp, cCCDsPr, cCCDesp)
                    cItVld := cItPlan
                    cClVld := cClPlan

                    If !u_VLDCONT( @cCCVld, @cItVld, @cClVld, .F., .T.)
                        lRet := .F.
                        cMsgValid += IIf(!Empty(cMsgValid),CRLF,"") + "Despesa " + Alltrim(AlltoChar(nDesp)) + ". Combinação contábil inválida (VLDCONT): " + IIf(lPrjDesp, cCCProj, cCCPlan) + "/" + cItPlan +"/" + cClPlan
                    EndIf
                EndIf

                aRetAux := {}

                aadd(aRetAux,"DESP")    //1  - Tipo
                aadd(aRetAux,nIdDesp)   //2  - Id
                aadd(aRetAux,nIdRat)    //3  - Id Rateio
                aadd(aRetAux,cCCDesp)   //4  - CC No Reserve
                aadd(aRetAux,cCCDsPr)   //5  - Se Projeto - CC do Projeto (retornado pelo CFP ou PSA)
                aadd(aRetAux,cItPlan)   //6  - Item do plano
                aadd(aRetAux,cClPlan)   //7  - Classe de valor do plano
                aadd(aRetAux,cCCVld)    //8  - Centro de custo validado pela DBK
                aadd(aRetAux,cItVld)    //9  - Item Contabil validado pela DBK
                aadd(aRetAux,cClVld)    //10 - Classe de valor validado pela DBK
                aadd(aRetAux,lPrjDesp)  //11 - Indica se é projeto ou não

                aadd(aRetEntPlan,aClone(aRetAux)) //Adiciona as informacoes do plano no retorno

            Else
                //Ignora Ids de despesas sem centros de custos. Exemplo: número de nota de débito.
                If !(AllTrim(cValToChar(oJsonPlan:despesas[nDesp]:tipo:Id)) $ cIdsSemCC)
                    lRet := .F.
                    cMsgValid += IIf(!Empty(cMsgValid),CRLF,"") + "Despesa " + Alltrim(AlltoChar(nDesp)) + ". Estrutura de centros de custo não encontrada no JSON retornado pelo Reserve."
                EndIf
            EndIf
        Next nRat
    Next nDesp
EndIf

//Se for plano para centro de custo de projeto,
//verifica se o plano ja existe na base e tras o centro de custo "original"
//pois pode ter existido alteração do centro de custo no cadastro do projeto
If lPrjPlan
    cQryPZI += " select" + CRLF
    cQryPZI += "     PZI.PZI_CC," + CRLF
    cQryPZI += "     PZI.PZI_ITEMCT," + CRLF
    cQryPZI += "     PZI.PZI_CLVL," + CRLF
    cQryPZI += "     PZI.PZI_PRJPSA," + CRLF
    cQryPZI += "     PZI.PZI_CCORI," + CRLF
    cQryPZI += "     PZI.PZI_ITCTOR," + CRLF
    cQryPZI += "     PZI.PZI_CLVLOR" + CRLF
    cQryPZI += " from" + CRLF
    cQryPZI += "     " + RetSqlName("PZG") + " PZG" + CRLF
    cQryPZI += "         inner join " + RetSqlName("PZI") + " PZI" + CRLF
    cQryPZI += "          on PZG.PZG_FILIAL = PZI.PZI_FILIAL" + CRLF
    cQryPZI += "         and PZG.PZG_ID     = PZI.PZI_IDPLN" + CRLF
    cQryPZI += "         and PZI.D_E_L_E_T_ = ' '" + CRLF
    cQryPZI += " where" + CRLF
    cQryPZI += "     PZG.PZG_ID         = " + Alltrim(AlltoChar(nIdPlano)) + CRLF
    cQryPZI += "     and PZI.PZI_CC     <> ' '" + CRLF
    cQryPZI += "     and PZI.PZI_ITEMCT <> ' '" + CRLF
    cQryPZI += "     and PZI.PZI_CLVL   <> ' '" + CRLF
    cQryPZI += "     and PZI.PZI_PRJPSA <> ' '" + CRLF
    cQryPZI += "     and PZI.PZI_CCORI  <> ' '" + CRLF
    cQryPZI += "     and PZI.PZI_ITCTOR <> ' '" + CRLF
    cQryPZI += "     and PZI.PZI_CLVLOR <> ' '" + CRLF
    cQryPZI += "     and PZG.D_E_L_E_T_ = ' '" + CRLF
    cQryPZI += "     and ROWNUM = 1" + CRLF
    cQryPZI += " order by" + CRLF
    cQryPZI += "     PZI.PZI_IDPLN," + CRLF
    cQryPZI += "     PZI.PZI_IDITEM" + CRLF

    cAliasQry := GetNextAlias()

    If Select(cAliasQry) > 0
        (cAliasQry)->(dbCloseArea())
    Endif
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryPZI),cAliasQry,.T.,.T.)

    If !(cAliasQry)->(Eof())

        cCCVld := (cAliasQry)->PZI_CC
        cItVld := (cAliasQry)->PZI_ITEMCT
        cClVld := (cAliasQry)->PZI_CLVL

        u_VLDCONT( @cCCVld, @cItVld, @cClVld, .F., .T.)

        aRetAux := {}

        aadd(aRetAux,"DEFAULT")                 //1  - Tipo
        aadd(aRetAux,nIdPlano)                  //2  - Id
        aadd(aRetAux,nIdRat)                    //3  - Id Rateio
        aadd(aRetAux,cCCPlan)                   //4  - CC No Reserve
        aadd(aRetAux,(cAliasQry)->PZI_CCORI)    //5  - Se Projeto - CC do Projeto (retornado pelo CFP ou PSA)
        aadd(aRetAux,(cAliasQry)->PZI_ITCTOR)   //6  - Item do plano
        aadd(aRetAux,(cAliasQry)->PZI_CLVLOR)   //7  - Classe de valor do plano
        aadd(aRetAux,cCCVld)                    //8  - Centro de custo validado pela DBK
        aadd(aRetAux,cItVld)                    //9  - Item Contabil validado pela DBK
        aadd(aRetAux,cClVld)                    //10 - Classe de valor validado pela DBK
        aadd(aRetAux,lPrjPlan)                  //11 - Indica se é projeto ou não

        aadd(aRetEntPlan,aClone(aRetAux)) //Adiciona as informacoes do plano no retorno
    EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TResVldCC
Funcao para teste da rotina ResVldCC
@author  By Wise
@since   01/07/2019
@version V12
/*/
//-------------------------------------------------------------------
User Function TResVldCC()
Local aLogPZB       := {}
Local aLogin        := {}
Local aHeader       := {}
Local aRetPlan      := {}
Local aEntPlan      := {}
Local cToken        := ""
Local cMsgValid     := ""
Local cJsonRet      := ""
Local cResponse     := ""
Local nIdPlano      := 4114
Local nX
Local oJsonDePara

RpcSetType(3)
RpcSetEnv("00","00001000100")

aLogin := U_GerAcessRes()

If aLogin[1]
    cToken := aLogin[2]
    Aadd( aHeader, "SecurityToken:" + cToken )

    DbSelectArea("PZG")
    PZG->(DbSetOrder(1))

    If nIdPlano > 0

        If PZG->(DbSeek( xFilial("PZG") + Str(nIdPlano,10,0) ))

            //Faz o get do plano como está no reserve
            aRetPlan := U_ResInteg("000036", Nil, aHeader, Nil ,.T.,"/" + Alltrim(Alltochar( nIdPlano )), 1, Nil )

            If aRetPlan[1]
                oJsonPlan := aRetPlan[2]

                lValido := u_ResVldCC(oJsonPlan,cMsgValid,aEntPlan)

                VarInfo("[ResVldCC] aEntPlan: ", aEntPlan)

                If lValido
                    TGeraDesp(1, {oJsonPlan}, aEntPlan)
                EndIf

            EndIf

        EndIf
    EndIf

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TGeraDesp
Funcao para simular a GeraDespesa para o teste TResVldCC
@author  By Wise
@since   01/07/2019
@version V12
/*/
//-------------------------------------------------------------------
Static Function TGeraDesp(nX, oJson, aEntPlan)

Local cCCPlan   := ""
Local cItPlan   := ""
Local cClPlan   := ""
Local cCodPrj   := ""
Local cCC_DBK   := ""
Local cIt_DBK   := ""
Local cCl_DBK   := ""
Local nPosEnt   := 0
Local nPosDef   := 0
Local nDesp     := 0
Local nInd      := 0

For nDesp := 1 To Len(oJson[nX]:despesas)

    For nInd := 1 To Len(oJson[nX]:despesas[nDesp]:centrosdecusto)
        nPosEnt := aScan(aEntPlan, {|a| a[1]=="DESP" .And. a[2] == oJson[nX]:despesas[nDesp]:id .And. a[3] == oJson[nX]:despesas[nDesp]:centrosdecusto[nInd]:id })

        If Len(aEntPlan) > 0 .And. nPosEnt > 0

            cCCPlan := IIf( aEntPlan[nPosEnt][11], aEntPlan[nPosEnt][5], aEntPlan[nPosEnt][4] )
            cItPlan := aEntPlan[nPosEnt][6]
            cClPlan := aEntPlan[nPosEnt][7]
            cCodPrj := IIf( aEntPlan[nPosEnt][11], SubStr(aEntPlan[nPosEnt][4], 3,10) + SubStr(aEntPlan[nPosEnt][4], 14,3), "" )
            cCC_DBK := aEntPlan[nPosEnt][8]
            cIt_DBK := aEntPlan[nPosEnt][9]
            cCl_DBK := aEntPlan[nPosEnt][10]

            VarInfo("[TGeraDesp] cCCPlan: ", cCCPlan)
            VarInfo("[TGeraDesp] cItPlan: ", cItPlan)
            VarInfo("[TGeraDesp] cClPlan: ", cClPlan)
            VarInfo("[TGeraDesp] cCodPrj: ", cCodPrj)
            VarInfo("[TGeraDesp] cCC_DBK: ", cCC_DBK)
            VarInfo("[TGeraDesp] cIt_DBK: ", cIt_DBK)
            VarInfo("[TGeraDesp] cCl_DBK: ", cCl_DBK)

        EndIf
    Next nInd

Next nDesp

nPosDef := aScan(aEntPlan, {|a| a[1]=="DEFAULT" .And. a[2] == oJson[nX]:id })

If Len(aEntPlan) > 0 .And. nPosDef > 0

    cCCPlan := IIf( aEntPlan[nPosDef][11], aEntPlan[nPosDef][5], aEntPlan[nPosDef][4] )
    cItPlan := aEntPlan[nPosDef][6]
    cClPlan := aEntPlan[nPosDef][7]
    cCodPrj := IIf( aEntPlan[nPosDef][11], SubStr(aEntPlan[nPosDef][4], 3,10) + SubStr(aEntPlan[nPosDef][4], 14,3), "" )
    cCC_DBK := aEntPlan[nPosDef][8]
    cIt_DBK := aEntPlan[nPosDef][9]
    cCl_DBK := aEntPlan[nPosDef][10]

    VarInfo("[TGeraDesp] cCCPlan: ", cCCPlan)
    VarInfo("[TGeraDesp] cItPlan: ", cItPlan)
    VarInfo("[TGeraDesp] cClPlan: ", cClPlan)
    VarInfo("[TGeraDesp] cCodPrj: ", cCodPrj)
    VarInfo("[TGeraDesp] cCC_DBK: ", cCC_DBK)
    VarInfo("[TGeraDesp] cIt_DBK: ", cIt_DBK)
    VarInfo("[TGeraDesp] cCl_DBK: ", cCl_DBK)

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fx200crypt
Gera o token para armazenar a credencial do reserve
@author  By Wise
@since   10/08/2019
@version V12
/*/
//-------------------------------------------------------------------
User Function fx200crypt( cString )
Local cCrypt := ""

Default cString := ""

If !Empty(cString)
    cCrypt := rc4crypt(Alltrim(cString), STR0001, .T.)
    cCrypt := Encode64( cCrypt )
EndIf

Return cCrypt

//-------------------------------------------------------------------
/*/{Protheus.doc} fx200crypt
Recupera o token da credencial do reserve
@author  By Wise
@since   10/08/2019
@version V12
/*/
//-------------------------------------------------------------------
Static Function fx200decrypt( cString )
Local cAux     := ""
Local cHex     := ""
Local cDeCrypt := ""

Default cString := ""

If !Empty(cString)
    cAux := Decode64( Alltrim(cString) )

    While Len(cAux) > 0
        cHex += chr(CTON(Substring(cAux,1,2), 16))
        cAux := Substring( cAux, 3 ,Len(cAux) )
    EndDo

    cDeCrypt := rc4crypt(cHex, STR0001, .F.)

EndIf

Return cDeCrypt
