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
#INCLUDE "TRYEXCEPTION.CH"
#INCLUDE "TRYEXCEPTION.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Francesinha
@author  Juliano Junio de Souza
@since   05/2021
@version version
/*/
//-------------------------------------------------------------------
WsRestFul Francesinha Description "Método responsavel pela Carga de Titulos para Baixa via JOB"
WsData cCgcEmp		As String
WsMethod Post Description "Carga de Dados - Baixa de Titulos" WsSyntax "/Francesinha"
End WsRestFul

//-------------------------------------------------------------------
/*/{Protheus.doc} Post
@author  Juliano Junio de Souza
@since   05/2021
@version version
/*/
//-------------------------------------------------------------------
WsMethod Post WsReceive cCgcEmp WsService Francesinha
	Local aCriaServ  := {}
	Local cCgcEmp    := IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")
	Local aEmpresas  := FwLoadSM0()    
    Local nX         := 0
    Local oJson    := Nil
    Local cBody      := ::GetContent()
    Local cChave     := ''
    Local cToken     := "aW50ZWdyYWNhb19mcm9udA==" //-- Encode64("integracao_front")
    Local cAuth      := ::GetHeader("Authorization")
    Local cStrRET   := ""
    Local cJson      := ""
    Local cMenssagem := ''
    Local nCodErro   := 200
    Local cIdTrab    := "000010"
    Local cIdPZB     := ""

    // Define interpolador de dados.
    ::SetContentType("application/json")

    // Valida Autenticação.
	If Empty(cAuth)
		nCodErro := 400
		cStrRET := u_STSHTTP(nCodErro)
		cStrRET += " - Falha Authorization."
		SetRestFault(nCodErro, cStrRET)
		Return .F.
	Else
		cAuth := Alltrim(cAuth)
	Endif
		
	If cAuth != cToken
		nCodErro := 400
		cStrRET := u_STSHTTP(nCodErro)
		cStrRET += " - Falha Token Autorizacao."
		SetRestFault(nCodErro, cStrRET)
		Return .F.	
	Endif

    // Valida envio de Conteudo.
	If Empty(cBody)
		cJson := '{"Mensagem": "Sem conteudo JSON.", "lret":false}'
		::SetResponse( cJson )
		Return .T.
	EndIf
    ***********************************************************************
	RpcClearEnv()
	RpcSetType(3)
	RpcSetEnv("01","01000101")
    SM0->(DbSetOrder(1))

    // Tentativa de Execução.
	//TRYEXCEPTION

        // Valida envio de Indetificação de Sistema Processador - SM0
		nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == cCgcEmp })
		If nPosEmp == 0
			cJson := '{"Mensagem":"Empresa nao cadastrada.", "lret":false}'
			::SetResponse( cJson )
			Return .T.
		EndIf

        // Converte e Valida o Conteudo no Forma JSON.
		FWJsonDeserialize(cBody, @oJson)

        if Valtype(oJson) == Nil
            cJson := '{"Mensagem": "Objeto JSON ADVPL invalido!", "lret":false}'
            ::SetResponse( cJson )
            Return .T.
        endif

        // Valida o envio do objeto principal de Controle.
        if AttisMemberOf(oJson,"Titulos") == Nil
            cJson := '{"Mensagem": "Objeto Principal Ausente, analise documentação!", "lret":false}'
            ::SetResponse( cJson )
            Return .T.
        endif
		
		DbSelectArea("PZD")
		PZD->(DbSetOrder(2))

		If Len(oJson:Titulos) > 0

			cJson := "{"

			//Cria servi�o no montitor
			aCriaServ := U_MonitRes(cIdTrab, 1, Len(oJson:Titulos) )   
			cIdPZB 	  := aCriaServ[2]

			For nX := 1 to len(oJson:Titulos)
				
				cChave := AVkEY(oJson:Titulos[nX]:E1_XNUMOAB,"E1_XNUMOAB")  
				cMenssagem  := "OABCARGAE8 - Post Carga SE8 = " + Alltrim(cValToChar(cChave))
				cStrRET := 'Registro Armazenado com seucesso! Tracker: ' + cIdPZB
				U_MonitRes(cIdTrab, 2, , cIdPZB, cMenssagem, .T., cStrRET, cBody, "Sucesso!", "", .F., .F.)
				U_MonitRes(cIdTrab, 3, , cIdPZB, , .T.)
				PZD->(DbGoTop())
				PZD->(DbSeek(xFilial("PZD")+cIdTrab+cIdPZB))
				If RecLock("PZD",.F.)
					PZD->PZD_STATUS := "P"
				Endif

				cJson += '"Titulos":['
				cJson += "{" 
				cJson += '"Mensagem' + '":"' + cStrRET + '",'
				cJson += '"E1_CLIENTE' + '":"' + AVkEY(oJson:Titulos[nX]:E1_CLIENTE,"E1_CLIENTE") + '",'
				cJson += '"E1_LOJA' + '":"' + AVkEY(oJson:Titulos[nX]:E1_LOJA,"E1_LOJA") + '",'
				cJson += '"E1_PREFIXO' + '":"' + AVkEY(oJson:Titulos[nX]:E1_PREFIXO,"E1_PREFIXO") + '",'
				cJson += '"E1_XNUMOAB' + '":"' + cChave + '",'
				cJson += '"E1_PARCELA' + '":"' + AVkEY(oJson:Titulos[nX]:E1_PARCELA,"E1_PARCELA") + '",'
				cJson += '"E1_TIPO' + '":"' + AVkEY(oJson:Titulos[nX]:E1_TIPO,"E1_TIPO") + '",'
				cJson += '"E1_BAIXA' + '":"' + AVkEY(oJson:Titulos[nX]:E1_BAIXA,"E1_BAIXA") + '",'
				cJson += '"lret' + cValTochar(nX) + '":true'
				cJson += "},"

			Next nX

			cJson := Left(cJson, Rat(",", cJson)-1)
			cJson += "]}"
			::SetResponse( cJson )

        Else
            cJson := '{"Mensagem": "Sem dados para processamento!", "lret":false}'
            ::SetResponse( cJson )
            Return .T.
		EndIf
/*
	CATCHEXCEPTION USING oException

		U_MonitRes(cIdTrab, 2, 0, cIdPZB, oException:Description, .F., "OABCARGAE8.PRW:LOG"+Time(), cBody, oException:Description, "Errorlog", .F., .F., "", .F., .F., .F.)
		//Finaliza o processo na PZB - Error
		U_MonitRes(cIdTrab, 3, 0, cIdPZB, "", .F.)

		cJson += '"Titulos":['
		cJson += "{" 
		cJson += '"Mensagem' + '":"' + "OABCARGAE8.PRW:LOG"+Time()+CRLF+oException:Description + '",'
		cJson += '"lret' + cValTochar(1) + '":false'
		cJson += "},"
        ::SetResponse( cJson )
        Return .T.

	ENDEXCEPTION
*/
Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} xfLOADE8
@author  Juliano Junio de Souza
@since   05/2021
@version version
/*/
//-------------------------------------------------------------------
User Function xfLOADE8 //u_xfLOADE8()
    Local dbTmp      := GetNextAlias()
	Local dbPr3      := GetNextAlias()
	Local cIdTrab    := "000010"
	Local cId_PR3    := "000003"
	Local oJson      := Nil
	Local aDados     := {}
	Local nX 		 := 0
	Local IdOAB    := ""
	Local cMenssagem := ""
	Local lIncOK     := .F.
	Local aTitulo    := {}
	Local cTitulo    := ""
	Local cCampo     := ""
	Local aErros     := {}
	Local cConteudo  := ""
	Local lBaixado   := .F.
	Private cErrorEA := ""
	Private lMsHelpAuto	:= .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto := .F.

    ***********************************************************************
	//ConOut(Replicate("*",50))
	//ConOut("-> Start - OABCARGAE8.PRW")

    RpcClearEnv()
	RpcSetEnv("01","01")

	// Tentativa de Execução.
	//TRYEXCEPTION
		
		// Estrutura De/Para
		BeginSql Alias dbPr3
			SELECT 
				PR3.*
			FROM %Table:PR3% PR3
			INNER JOIN %Table:PR2% (NOLOCK) PR2
				ON PR3_FILIAL = PR2_FILIAL 
				AND PR3_CODIGO = PR2_CODIGO
			WHERE PR2_CODPZA = %Exp:cId_PR3% 
			AND PR2.D_E_L_E_T_ != '*' 
			AND PR3.D_E_L_E_T_ != '*'
		EndSql

		// Fila de Processamento
		BeginSql Alias dbTmp
			SELECT
				TOP 100
				Cast(PZD_JSOENV As Varchar(2048)) As Request,
				PZD.R_E_C_N_O_ As Recno
			FROM %Table:PZD% (NOLOCK) PZD
			WHERE PZD.D_E_L_E_T_ != '*'
			And PZD.PZD_IDURL = %Exp:cIdTrab%
			And PZD.PZD_STATUS = 'P'
			//And Cast(PZD_JSOENV As Varchar(2048)) Not in (Select Cast(PZD_JSOENV As Varchar(2048)) From %Table:PZD% (NOLOCK) SUB WHERE SUB.D_E_L_E_T_ != '*' AND SUB.PZD_STATUS = 'S' And SUB.PZD_IDURL = %Exp:cIdTrab% And SUB.PZD_DESC = PZD.PZD_DESC)
		EndSql

		// Realiza Integração
		DBSelectArea("PZD")
		DBSelectArea("SE1")

		DbSelectArea(dbTmp)
		(dbTmp)->(DbGoTop())
		If (dbTmp)->(Eof())
			//ConOut("-> Sem Dados...")
		Endif
		(dbTmp)->(DbGoTop())
		while (dbTmp)->(!Eof())
			//ConOut("-> Validando Request...")
			aDados := Alltrim((dbTmp)->Request)
			cErrorEA := ""
			If !Empty(aDados)
				//ConOut("-> Obtendo Dados...")
				FWJsonDeserialize(aDados, @oJson)
				If Valtype(oJson) != "O"
					//ConOut("Error-OABCARGAE8-2")
					(dbTmp)->(DBSkip())
					Loop
				Endif
				If AttisMemberOf(oJson,"Titulos")
					aDados := oJson:Titulos
					For nX := 1 to Len(aDados)
						IdOAB := AVkEY(oJson:Titulos[nX]:E1_XNUMOAB,"E1_XNUMOAB") 
						//ConOut("-> Titulo = " + IdOAB)
						cMenssagem  := "OABCARGAE8 - Post Titulos " + IdOAB
						SE1->(dbSetOrder(29))
						SE1->(DbGoTop())
						If SE1->(DBSeek(xFilial("SE1") + IdOAB)) 
							lIncOK := .T. //Existe
							//ConOut("-> Preparando Baixa")
						Else	                                   
							lIncOK := .F. //Não existe, tenta incluir
							//ConOut("-> Incluindo Titulo")
							If oJson:Titulos[nX]:E1_TIPO == 'NDF'
								DbSelectArea("SA1")
								dbSetOrder(1)
								DbSeek(xFilial("SA1")+ oJson:Titulos[nX]:E1_CLIENTE + oJson:Titulos[nX]:E1_LOJA)
								DBSelectArea("SA2")
								DBSetOrder(3)
								IF !DbSeek(xFilial("SA2")+SA1->A1_CGC)
									oModel := FWLoadModel('MATA020')

									oModel:SetOperation(3)
									oModel:Activate()

									//Cabeçalho
									oModel:SetValue('SA2MASTER','A2_COD' ,GetSxeNum("SA2","A2_COD"))
									oModel:SetValue('SA2MASTER','A2_LOJA' ,"00")
									oModel:SetValue('SA2MASTER','A2_NOME' ,alltrim(SA1->A1_NOME))
									oModel:SetValue('SA2MASTER','A2_NREDUZ' ,Substr(alltrim(SA1->A1_NOME),1,20))
									oModel:SetValue('SA2MASTER','A2_END' ,alltrim(SA1->A1_END))
									oModel:SetValue('SA2MASTER','A2_BAIRRO' ,alltrim(SA1->A1_BAIRRO))
									oModel:SetValue('SA2MASTER','A2_EST' ,alltrim(SA1->A1_EST))
									oModel:SetValue('SA2MASTER','A2_CODMUN',alltrim(SA1->A1_CODMUN))
									oModel:SetValue('SA2MASTER','A2_MUN' ,alltrim(SA1->A1_MUN))
									oModel:SetValue('SA2MASTER','A2_TIPO' ,alltrim(SA1->A1_TIPO))
									oModel:SetValue('SA2MASTER','A2_CGC' ,alltrim(SA1->A1_CGC))
									oModel:SetValue('SA2MASTER','A2_CONTA' ,SA1->A1_CONTA)
									If oModel:VldData()
										oModel:CommitData()
										ConfirmSx8()
										cCod := oModel:GetValue( 'SA2MASTER', 'A2_COD' )
										cLoja := oModel:GetValue( 'SA2MASTER', 'A2_LOJA' )
									Else
										lMsErroAuto := .T.
										cErrorEA:= oModel:GetErrorMessage()[6]
									Endif
									oModel:DeActivate()

									oModel:Destroy()

								Else
									cCod := SA2->A2_COD
									cLoja := SA2->A2_LOJA
								Endif
								IF !empty(cCod) .and. !empty(cLoja)
									aArray:={}
									aArray := { { "E2_PREFIXO"  , "NDF"             , NIL },;
									{ "E2_NUM"      , oJson:Titulos[nX]:E1_NUM        , NIL },;
									{ "E2_TIPO"     , "NDF"              , NIL },;
									{ "E2_NATUREZ"  , "OUTROS    "             , NIL },;
									{ "E2_FORNECE"  , cCod           , NIL },;
									{ "E2_EMISSAO"  , Stod(oJson:Titulos[nX]:E1_EMISSAO), NIL },;
									{ "E2_VENCTO"   , Stod(oJson:Titulos[nX]:E1_VENCTO), NIL },;
									{ "E2_VENCREA"  , Stod(oJson:Titulos[nX]:E1_VENCREA), NIL },;
									{ "E2_VALOR"    ,   oJson:Titulos[nX]:E1_VALOR   , NIL },;
									{ "E2_DEBITO"    ,   SA1->A1_CONTA   , NIL },;
									{ "E2_ITEMD"    ,   '051401'   , NIL },;
									{ "E2_CCUSTO"    ,   "110104"     , NIL },;
									{ "E2_XNUMOAB"    ,   oJson:Titulos[nX]:E1_XNUMOAB   , NIL } }
									ConfirmSx8()
									MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 3)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão


									If lMsErroAuto
										aErros 	:= GetAutoGRLog() // retorna o erro encontrado no execauto.
										cErrorEA:= ''
										cErrorEA += "Erro Integração -> " + CRLF
										aEval(aErros,{|l| cErrorEA += Alltrim(l) + CRLF})
										cErrorEA += CRLF + "[ExecAuto]" + CRLF + CRLF
										aEval(aTitulo,{|l| cErrorEA += Alltrim(l[1]) + " = " + Alltrim(cValToChar(l[2])) + CRLF})
									Else
										conout("Sucesso Inclusao")
										
										lMsErroAuto :=  .F.
									Endif
								Endif	
							Else
								Inclui(oJson, @lIncOK, aDados)
							EndIf	
							//ConOut("-> Preparando Baixa")
						Endif
						// Processamento de Baixa
						If lIncOK
							SE1->(dbSetOrder(29))
							SE1->(DbGoTop())
							If SE1->(DBSeek(xFilial("SE1") + IdOAB))
								cTitulo := SE1->E1_NUM
								lBaixado := Empty(SE1->E1_BAIXA)
								If !lBaixado
									//ConOut("-> Titulo Baixado")
									If oJson:Titulos[nX]:E1_TIPO == 'NDF'
										DbSelectArea("SA1")
										dbSetOrder(1)
										DbSeek(xFilial("SA1")+ oJson:Titulos[nX]:E1_CLIENTE + oJson:Titulos[nX]:E1_LOJA)
										DBSelectArea("SA2")
										DBSetOrder(3)
										IF !DbSeek(xFilial("SA2")+SA1->A1_CGC)
											oModel := FWLoadModel('MATA020')

											oModel:SetOperation(3)
											oModel:Activate()

											//Cabeçalho
											oModel:SetValue('SA2MASTER','A2_COD' ,GetSxeNum("SA2","A2_COD"))
											oModel:SetValue('SA2MASTER','A2_LOJA' ,"00")
											oModel:SetValue('SA2MASTER','A2_NOME' ,alltrim(SA1->A1_NOME))
											oModel:SetValue('SA2MASTER','A2_NREDUZ' ,Substr(alltrim(SA1->A1_NOME),1,20))
											oModel:SetValue('SA2MASTER','A2_END' ,alltrim(SA1->A1_END))
											oModel:SetValue('SA2MASTER','A2_BAIRRO' ,alltrim(SA1->A1_BAIRRO))
											oModel:SetValue('SA2MASTER','A2_EST' ,alltrim(SA1->A1_EST))
											oModel:SetValue('SA2MASTER','A2_CODMUN',alltrim(SA1->A1_CODMUN))
											oModel:SetValue('SA2MASTER','A2_MUN' ,alltrim(SA1->A1_MUN))
											oModel:SetValue('SA2MASTER','A2_TIPO' ,alltrim(SA1->A1_TIPO))
											oModel:SetValue('SA2MASTER','A2_CGC' ,alltrim(SA1->A1_CGC))
											oModel:SetValue('SA2MASTER','A2_CONTA' ,SA1->A1_CONTA)
											If oModel:VldData()
												oModel:CommitData()
												ConfirmSx8()
												cCod := oModel:GetValue( 'SA2MASTER', 'A2_COD' )
												cLoja := oModel:GetValue( 'SA2MASTER', 'A2_LOJA' )
											Else
												lMsErroAuto := .T.
												cErrorEA:= oModel:GetErrorMessage()[6]
											Endif
											oModel:DeActivate()

											oModel:Destroy()

										Else
											cCod := SA2->A2_COD
											cLoja := SA2->A2_LOJA
										Endif
										IF !empty(cCod) .and. !empty(cLoja)
											aArray:={}
											aArray := { { "E2_PREFIXO"  , "NDF"             , NIL },;
											{ "E2_NUM"      , oJson:Titulos[nX]:E1_NUM           , NIL },;
											{ "E2_TIPO"     , "NDF"              , NIL },;
											{ "E2_NATUREZ"  , oJson:Titulos[nX]:E1_NATUREZ             , NIL },;
											{ "E2_FORNECE"  , cCod           , NIL },;
											{ "E2_EMISSAO"  , Stod(oJson:Titulos[nX]:E1_EMISSAO), NIL },;
											{ "E2_VENCTO"   , Stod(oJson:Titulos[nX]:E1_VENCTO), NIL },;
											{ "E2_VENCREA"  , Stod(oJson:Titulos[nX]:E1_VENCREA), NIL },;
											{ "E2_VALOR"    ,   oJson:Titulos[nX]:E1_VALOR   , NIL },;
											{ "E2_DEBITO"    ,   SA1->A1_CONTA   , NIL },;
											{ "E2_ITEMD"    ,   '051401'   , NIL },;
											{ "E2_CCUSTO"    ,   "110104"     , NIL },;
											{ "E2_XNUMOAB"    ,   oJson:Titulos[nX]:E1_XNUMOAB   , NIL } }
											ConfirmSx8()
											MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 3)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão


											If lMsErroAuto
												aErros 	:= GetAutoGRLog() // retorna o erro encontrado no execauto.
												cErrorEA:= ''
												cErrorEA += "Erro Integração -> " + CRLF
												aEval(aErros,{|l| cErrorEA += Alltrim(l) + CRLF})
												cErrorEA += CRLF + "[ExecAuto]" + CRLF + CRLF
												aEval(aTitulo,{|l| cErrorEA += Alltrim(l[1]) + " = " + Alltrim(cValToChar(l[2])) + CRLF})
											Else
												conout("Sucesso Inclusao")
												
											Endif
											  
										EndIf	
									EndIf
								Else
									If oJson:Titulos[nX]:E1_TIPO == 'NDF'
										DbSelectArea("SA1")
										dbSetOrder(1)
										DbSeek(xFilial("SA1")+ oJson:Titulos[nX]:E1_CLIENTE + oJson:Titulos[nX]:E1_LOJA)
										DBSelectArea("SA2")
										DBSetOrder(3)
										IF !DbSeek(xFilial("SA2")+SA1->A1_CGC)
											oModel := FWLoadModel('MATA020')

											oModel:SetOperation(3)
											oModel:Activate()

											//Cabeçalho
											oModel:SetValue('SA2MASTER','A2_COD' ,GetSxeNum("SA2","A2_COD"))
											oModel:SetValue('SA2MASTER','A2_LOJA' ,"00")
											oModel:SetValue('SA2MASTER','A2_NOME' ,alltrim(SA1->A1_NOME))
											oModel:SetValue('SA2MASTER','A2_NREDUZ' ,Substr(alltrim(SA1->A1_NOME),1,20))
											oModel:SetValue('SA2MASTER','A2_END' ,alltrim(SA1->A1_END))
											oModel:SetValue('SA2MASTER','A2_BAIRRO' ,alltrim(SA1->A1_BAIRRO))
											oModel:SetValue('SA2MASTER','A2_EST' ,alltrim(SA1->A1_EST))
											oModel:SetValue('SA2MASTER','A2_CODMUN',alltrim(SA1->A1_CODMUN))
											oModel:SetValue('SA2MASTER','A2_MUN' ,alltrim(SA1->A1_MUN))
											oModel:SetValue('SA2MASTER','A2_TIPO' ,alltrim(SA1->A1_TIPO))
											oModel:SetValue('SA2MASTER','A2_CGC' ,alltrim(SA1->A1_CGC))
											oModel:SetValue('SA2MASTER','A2_CONTA' ,SA1->A1_CONTA)
											If oModel:VldData()
												oModel:CommitData()
												ConfirmSx8()
												cCod := oModel:GetValue( 'SA2MASTER', 'A2_COD' )
												cLoja := oModel:GetValue( 'SA2MASTER', 'A2_LOJA' )
											Else
												lMsErroAuto := .T.
												cErrorEA:= oModel:GetErrorMessage()[6]
											Endif
											oModel:DeActivate()

											oModel:Destroy()

										Else
											cCod := SA2->A2_COD
											cLoja := SA2->A2_LOJA
										Endif
										IF !empty(cCod) .and. !empty(cLoja)
											aArray:={}
											aArray := { { "E2_PREFIXO"  , "NDF"             , NIL },;
											{ "E2_NUM"      , GetSxeNum("SE2","E2_NUM")           , NIL },;
											{ "E2_TIPO"     , "NDF"              , NIL },;
											{ "E2_NATUREZ"  , oJson:Titulos[nX]:E1_NATUREZ            , NIL },;
											{ "E2_FORNECE"  , cCod           , NIL },;
											{ "E2_EMISSAO"  , Stod(oJson:Titulos[nX]:E1_EMISSAO), NIL },;
											{ "E2_VENCTO"   , Stod(oJson:Titulos[nX]:E1_VENCTO), NIL },;
											{ "E2_VENCREA"  , Stod(oJson:Titulos[nX]:E1_VENCREA), NIL },;
											{ "E2_VALOR"    ,   oJson:Titulos[nX]:E1_VALOR   , NIL },;
											{ "E2_DEBITO"    ,   SA1->A1_CONTA   , NIL },;
											{ "E2_ITEMD"    ,   '051401'   , NIL },;
											{ "E2_CCUSTO"    ,   "110104"     , NIL },;
											{ "E2_XNUMOAB"    ,   oJson:Titulos[nX]:E1_XNUMOAB   , NIL } }
											ConfirmSx8()
											MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 3)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão


											If lMsErroAuto
												aErros 	:= GetAutoGRLog() // retorna o erro encontrado no execauto.
												cErrorEA:= ''
												cErrorEA += "Erro Integração -> " + CRLF
												aEval(aErros,{|l| cErrorEA += Alltrim(l) + CRLF})
												cErrorEA += CRLF + "[ExecAuto]" + CRLF + CRLF
												aEval(aTitulo,{|l| cErrorEA += Alltrim(l[1]) + " = " + Alltrim(cValToChar(l[2])) + CRLF})
											Else
												conout("Sucesso Inclusao")
												
											Endif
											  
										EndIf	
									Else
										DBSelectArea("SA1")
										SA1->(DbSetOrder(1))
										SA1->(DbGoTop())	
										if SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
											if SA1->A1_MSBLQL == "1" // Bloqueado.
												if RecLock("SA1",.F.)
													SA1->A1_MSBLQL := "2"
													SA1->(MsUnLock())
												endif
											endif
										Endif
										(dbPr3)->(DbGoTop())
										aTitulo      := {}
										While !(dbPr3)->(Eof())
											cCampo        := Alltrim((dbPr3)->PR3_CPOORI)
											If (dbPr3)->PR3_TPCONT == "1"
												if AttisMemberOf(oJson:Titulos[nX],cCampo)
													cConteudo := &("oJson:Titulos[" + cValTochar(nX) + "]:" + cCampo)  
												Else
													(dbPr3)->(DbSkip())
													Loop
												Endif
											Else
												cConteudo := &((dbPr3)->PR3_CONTEU)
											EndIf
											If UPPER(AllTrim(cCampo)) == 'E1_BAIXA' .oR. UPPER(AllTrim(cCampo)) == 'E1_MOVIMEN' 
													cConteudo := StoD(cConteudo)
											EndIf
											If UPPER(AllTrim(cCampo)) == "E1_PREFIXO"
												cConteudo := avKey(cConteudo,"E1_PREFIXO")
											Endif
											If UPPER(AllTrim(cCampo)) == "E1_NUM"
												cConteudo := avKey(cTitulo,"E1_NUM")
											Endif
											If UPPER(AllTrim(cCampo)) == "E1_PARCELA"
												cConteudo := avKey(cConteudo,"E1_PARCELA")
											Endif
											If UPPER(AllTrim(cCampo)) == "E1_TIPO"
												cConteudo := avKey(cConteudo,"E1_TIPO")
											Endif
											aAdd(aTitulo, {Alltrim((dbPr3)->PR3_CPODES), cConteudo, nil})
											(dbPr3)->(DbSkip())
										End
										// Realiza Integração Automatica - Financeiro + Contas a Receber + Baixar
										cErrorEA += "[ExecAuto - Baixa]" + CRLF
										lMsHelpAuto	:= .T.
										lAutoErrNoFile := .T.
										lMsErroAuto := .F.								
										MSExecAuto({|x,y,b,a| FINA070(x,y,b,a)},aTitulo,3,.F.,3)

										If lMsErroAuto
											//ConOut("-> Erro Baixa Titulo - " + IdOAB)
											aErros 	:= GetAutoGRLog() // retorna o erro encontrado no execauto.
											cErrorEA += "Erro Integração -> " + CRLF
											aEval(aErros,{|l| cErrorEA += Alltrim(l) + CRLF})
											cErrorEA += CRLF + "[ExecAuto]" + CRLF + CRLF
											aEval(aTitulo,{|l| cErrorEA += Alltrim(l[1]) + " = " + Alltrim(cValToChar(l[2])) + CRLF})
										Else
											//ConOut("-> Baixa de Titulo Realizada - " + IdOAB)
											cErrorEA += CRLF + "[ExecAuto]" + CRLF + CRLF
											aEval(aTitulo,{|l| cErrorEA += Alltrim(l[1]) + " = " + Alltrim(cValToChar(l[2])) + CRLF})
											cErrorEA += "Sucesso!" + CRLF
											ConfirmSx8()
										EndIf
									Endif
								Endif
							Endif	
							//ConOut("Error-OABCARGAE8-4")
						Endif
					Next nX
				Else
					//ConOut("Error-OABCARGAE8-3")
				Endif
			Else
				//ConOut("Error-OABCARGAE8-1")
			Endif
			PZD->(DbGoTo((dbTmp)->Recno))
			If Reclock("PZD",.F.)
				//ConOut("-> Atualizando Status")
				PZD_STATUS := Iif(lMsErroAuto,"E","S")
				PZD_JSOREC := cErrorEA
				PZD->(MsUnLock())
			Endif
			(dbTmp)->(DBSkip())
		End
		
		(dbTmp)->(DbCloseArea())
		//ConOut("-> LOG " + CRLF + CRLF + cErrorEA + CRLF )
		//ConOut("-> Fim - OABCARGAE8.PRW")
		//ConOut(Replicate("*",50))
	
	//CATCHEXCEPTION USING oException
		//ConOut("-> Error - OABCARGAE8 - "+Time()+CRLF+oException:Description)
		//ConOut("-> Fim - OABCARGAE8.PRW")
		//ConOut(Replicate("*",50))
		// Recursivo
		//u_xfLOADE8()
	//ENDEXCEPTION
	RpcClearEnv()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Inclui
@author  Juliano Junio de Souza
@since   08/2021
@version version
/*/
//-------------------------------------------------------------------
Static Function Inclui(oJsoAux, lIncOK, cBody)

	Local cQuery    := ""
	Local cAlsQry   := GetNextAlias()
	Local nX
	Local cStrRET  := ""
	Local aDados    := {}
	Local aCriaServ := {}
	Local nErro     := 0
	Local cJson     := ""
	Local cEnt		:= ''
	Local ntpExec   := 3
	Local cMensagem := ''
	Local cTit      := ''
	Local cLogExt   := ''
	Local cAliasE1  := GetNextAlias()
	Local cNumSeq   := ''

	Private lMsHelpAuto	:= .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto := .F.

	SM0->(DbSetOrder(1))

	cQuery := " SELECT PR3.* FROM " + RetSqlName("PR3") + " (NOLOCK) PR3 "
	cQuery += " INNER JOIN " + RetSqlName("PR2") + " (NOLOCK) PR2 "
	cQuery += " ON PR3_FILIAL = PR2_FILIAL AND PR3_CODIGO = PR2_CODIGO "
	cQuery += " WHERE PR2_CODPZA = '000002' AND PR2.D_E_L_E_T_ = ' '  AND PR3.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	If len(oJsoAux:Titulos) > 0

		cJson := "{"

		//Cria servi�o no montitor
		aCriaServ := U_MonitRes("000002", 1, Len(oJsoAux:Titulos) )   
		cIdPZB 	  := aCriaServ[2]

		For nX := 1 to len(oJsoAux:Titulos)
			
			cLogExt   := ''
			cMensagem := ''
			(cAlsQry)->(DbGoTop())
			aDados      := {}

			cTit := AVkEY(oJsoAux:Titulos[nX]:E1_XNUMOAB,"E1_XNUMOAB")           	
			//ConOut("-> Preparando Emissao - " + cTit)

			DBSelectArea("SE1")
			SE1->(dbSetOrder(29))	
			SE1->(DbGoTop())
			If SE1->(DBSeek(xFilial("SE1") + cTit))
				//Alteração
				ntpExec := 4
				cNumSeq := SE1->E1_NUM
				cMensagem := 'OABCARGAE8 - Alteração ' + oJsoAux:Titulos[nX]:E1_XNUMOAB
				DBSelectArea("SA1")
				SA1->(DbSetOrder(1))
				SA1->(DbGoTop())	
				if SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
					if SA1->A1_MSBLQL == "1" // Bloqueado.
						if RecLock("SA1",.F.)
							SA1->A1_MSBLQL := "2"
							SA1->(MsUnLock())
						endif
					endif
				Endif
			Else	
				cQuery := " SELECT MAX(E1_NUM) + 1 AS NUM FROM  " + RetSqlName("SE1") + " (NOLOCK) SE1 "
				cQuery += " WHERE SE1.D_E_L_E_T_ = ' '  "

				If Select(cAliasE1) > 0; (cAliasE1)->(dbCloseArea()); Endif
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasE1,.T.,.T.)

				cNumSeq :=  oJson:Titulos[nX]:E1_NUM
				ConfirmSX8()
				 
				ntpExec := 3//Inclusão
				cMensagem := 'OABCARGAE8 - Inclusao ' + oJsoAux:Titulos[nX]:E1_XNUMOAB
				DBSelectArea("SA1")
				SA1->(DbSetOrder(1))
				SA1->(DbGoTop())	
				if SA1->(DbSeek(xFilial("SA1")+oJsoAux:Titulos[nX]:E1_CLIENTE+oJsoAux:Titulos[nX]:E1_LOJA))
					if SA1->A1_MSBLQL == "1" // Bloqueado.
						if RecLock("SA1",.F.)
							SA1->A1_MSBLQL := "2"
							SA1->(MsUnLock())
						endif
					endif
				Endif
			EndIf

			While !(cAlsQry)->(Eof())

				cCpo        := Alltrim((cAlsQry)->PR3_CPOORI)

				If (cAlsQry)->PR3_TPCONT == "1"
					if AttisMemberOf(oJsoAux:Titulos[nX],cCpo)
						cConteudo := &("oJsoAux:Titulos[" + cValTochar(nX) + "]:" + cCpo)  
					Else
						(cAlsQry)->(DbSkip())
						Loop
					Endif 
				Else
					cConteudo := &((cAlsQry)->PR3_CONTEU)
				EndIf

				If UPPER(AllTrim(cCpo)) == 'E1_VENCREA' .oR. UPPER(AllTrim(cCpo)) == 'E1_VENCTO' .oR.  UPPER(AllTrim(cCpo)) == 'E1_EMISSAO' .oR. UPPER(AllTrim(cCpo)) == 'E1_BAIXA'
					cConteudo := StoD(cConteudo)
				EndIf
				
				If UPPER(AllTrim(cCpo)) == 'E1_NUM' 
					cConteudo := cNumSeq
				EndIf

				aAdd(aDados, {Alltrim((cAlsQry)->PR3_CPODES), cConteudo, nil})

				(cAlsQry)->(DbSkip())

			End

			
			cErrorEA += "[ExecAuto - Emissao]" + CRLF
			MSExecAuto({|x,y| FINA040(x,y)},aDados,ntpExec)

			If lMsErroAuto
				//ConOut("-> Erro Emissao Titulo - " + cTit)
				cStrRET := ""
				aErros 	:= GetAutoGRLog() // retorna o erro encontrado no execauto.
				cLogExt := ""
				aEval(aErros,{|l| cLogExt += Alltrim(l) + CRLF})
				cErrorEA += "Erro Integração -> " + StrTran(cLogExt, CRLF, " ") + " | "
				cLogExt += CRLF + "[ExecAuto]" + CRLF + CRLF
				aEval(aDados,{|l| cLogExt += Alltrim(l[1]) + " = " + Alltrim(cValToChar(l[2])) + CRLF})
				nErro   := Ascan(aErros, {|x| "INVALIDO" $ alltrim(Upper(x))  } )

				If nErro > 0
					cStrRET += aErros[ nErro ]
				Else
					For nErro := 1 To Len( aErros )
						cStrRET += ( aErros[ nErro ] + cEnt )
					Next nErro
				EndIf

				cStrRET := Alltrim(cStrRET)
				RollBackSX8()
				U_MonitRes("000002", 2, , cIdPZB, cMensagem, .F., cStrRET, cLogExt, "Erro OABCARGAE8", "", .F., .F.)
				//Finaliza o processo na PZB
				U_MonitRes("000002", 3, , cIdPZB, , .F.)

				lIncOK := .F.

			Else			
				//ConOut("-> Emissao Titulo Realizada - " + cTit)
				cLogExt += CRLF + "[ExecAuto]" + CRLF + CRLF
				aEval(aDados,{|l| cLogExt += Alltrim(l[1]) + " = " + Alltrim(cValToChar(l[2])) + CRLF})
				cLogExt += "Sucesso!" + CRLF
				ConfirmSx8()
				If ntpExec == 3
					U_MonitRes("000002", 2, , cIdPZB, cMensagem, .T., "Titulo incluso com sucesso", "", cLogExt, "", .F., .F.)
				Else
					U_MonitRes("000002", 2, , cIdPZB, cMensagem, .T., "Titulo Alterado com sucesso", "", cLogExt, "", .F., .F.)
				Endif 

				//Finaliza o processo na PZB
				U_MonitRes("000002", 3, , cIdPZB, , .T.)

				lIncOK := .T.
			EndIf
		Next nX
	EndIf

(cAlsQry)->(dbCloseArea())
lMsErroAuto := .F.

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} xfBACKE8
@author  Juliano Junio de Souza
@since   05/2021
@version version
/*/
//-------------------------------------------------------------------
User Function xfBACKE8 //u_xfBACKE8()
    Local dbTmp      := GetNextAlias()
	Local dbPZD      := GetNextAlias()
	Local cIdTrab    := "000000"
	Local cId_PZD    := "000010"
	Local aDados     := {}
	Local nX 		 := 0
	Local IdOAB      := ""
	Local IdOABQRY   := ""
	Local aTitulo    := {}
	Local nTpMode    := 2
	Local lPrepEnv   := ( IsBlind() .or. ( Select( "SM0" ) == 0 ) )
	Private cErrorEA    	:= ""
	Private lMsHelpAuto		:= .T.
	Private lAutoErrNoFile  := .T.
	Private lMsErroAuto 	:= .F.

    ***********************************************************************
	//ConOut(Replicate("*",50))
	//ConOut("-> Start - OABCARGAE8.PRW [xfBACKE8]")

	BEGIN SEQUENCE
    IF ( lPrepEnv )
        RpcSetType( 1 )
    	PREPARE ENVIRONMENT EMPRESA( "01" ) FILIAL ( "01" ) MODULO ( "SIGAFIN" )
		InitPublic()
		SetsDefault()
		SetModulo( "SIGAESP2" , "ESP2" )

		If nTpMode == 1 // Reprocessamento de Baixa - Por referencia de Erro em Inclusao de Titulos = ID 000002 Status E (Mudar para P e executar)
			cIdTrab := "000002"
			// Fila de Processamento
			If Select(dbTmp) > 0
				(dbTmp)->(DbCloseArea())
			Endif
			BeginSql Alias dbTmp
				SELECT
					PZD.R_E_C_N_O_ As Recno
				FROM %Table:PZD% (NOLOCK) PZD
				WHERE PZD.D_E_L_E_T_ != '*'
				And PZD.PZD_IDURL = %Exp:cIdTrab%
				And PZD.PZD_DESC Like '%OABCARGAE8%'
				And PZD.PZD_STATUS = 'P'
			EndSql

			DbSelectArea(dbTmp)
			(dbTmp)->(DbGoTop())
			/*If (dbTmp)->(Eof())
				ConOut("-> Sem Dados...")
			Else
				ConOut("-> Processando...")
			Endif*/

			cErrorEA := ""
			(dbTmp)->(DbGoTop())
			while (dbTmp)->(!Eof())
				PZD->(DbGoTo((dbTmp)->Recno))
				aDados := StrTokArr(PZD->PZD_DESC," ")
				IdOAB := aDados[Len(aDados)]
				//ConOut("-> Titulo Encontrado = " + IdOAB)
				IdOABQRY := "%'%= "+Alltrim(IdOAB)+" %'%"
				If Select(dbPZD) > 0
					(dbPZD)->(DbCloseArea())
				Endif
				BeginSql Alias dbPZD
					SELECT
					Top 1
					PZD.R_E_C_N_O_ As Recno
					FROM %Table:PZD% (NOLOCK) PZD
					WHERE PZD.D_E_L_E_T_ != '*'
					And PZD.PZD_IDURL = %Exp:cId_PZD%
					And PZD.PZD_STATUS = 'S'
					And PZD.PZD_DESC Like %Exp:IdOABQRY%
				EndSql
				
				PZD->(DbGoTo((dbPZD)->Recno))
				If Reclock("PZD",.F.)
					//ConOut("-> Atualizando Status PZD = " + Alltrim(PZD->PZD_DESC))
					PZD_STATUS := "P"
					PZD->(MsUnLock())
				Endif
				PZD->(DbGoTo((dbTmp)->Recno))
				If Reclock("PZD",.F.)
					//ConOut("-> Atualizando Status")
					PZD_STATUS := "S"
					PZD->(MsUnLock())
				Endif
				(dbTmp)->(DBSkip())
			End		
		Else // Reprocessamento de Baixa por ID OAB - Incluir Id 000000 com lista de ID´s OAB com quebra de linhas... Limite de 150 por processamento.
			cIdTrab    := "000000"
			// Fila de Processamento
			If Select(dbTmp) > 0
				(dbTmp)->(DbCloseArea())
			Endif
			BeginSql Alias dbTmp
				SELECT
					Cast(PZD_JSOENV As Varchar(4096)) As Dados,
					PZD.R_E_C_N_O_ As Recno
				FROM %Table:PZD% (NOLOCK) PZD
				WHERE PZD.D_E_L_E_T_ != '*'
				And PZD.PZD_IDURL = %Exp:cIdTrab%
				And PZD.PZD_STATUS = 'P'
			EndSql

			// Realiza Integração
			DBSelectArea("PZD")
			DBSelectArea("SE1")

			DbSelectArea(dbTmp)
			(dbTmp)->(DbGoTop())
			/*If (dbTmp)->(Eof())
				ConOut("-> Sem Dados...")
			Else
				ConOut("-> Processando...")
			Endif*/

			cErrorEA := ""
			(dbTmp)->(DbGoTop())
			while (dbTmp)->(!Eof())
				aDados := StrTokArr(Alltrim((dbTmp)->Dados),CRLF)
				//ConOut("-> Dados Obtidos = " + cValToChar(Len(aDados)))
				cErrorEA := "-> Dados Obtidos = " + cValToChar(Len(aDados)) + CRLF + CRLF
				If Len(aDados) > 0
					For nX := 1 to Len(aDados)
						IdOAB := Alltrim(aDados[nX])
						IdOABQRY := "%'%= "+Alltrim(IdOAB)+" %'%"
						If Select(dbPZD) > 0
							(dbPZD)->(DbCloseArea())
						Endif
						BeginSql Alias dbPZD
							SELECT
								PZD.*
							FROM %Table:PZD% (NOLOCK) PZD
							WHERE PZD.D_E_L_E_T_ != '*'
							And PZD.PZD_IDURL = %Exp:cId_PZD%
							And PZD.PZD_STATUS = 'P'
							And PZD.PZD_DESC Like %Exp:IdOABQRY%
						EndSql

						If (dbPZD)->(Eof())
							SE1->(dbSetOrder(29))
							SE1->(DbGoTop())
							If SE1->(DBSeek(xFilial("SE1") + IdOAB))
								cErrorEA += "-> Excluir Titulo..." + CRLF
								// Rollback de dados
								//ConOut("-> Titulo Encontrado = " + IdOAB)
								cErrorEA += "-> Titulo Encontrado = " + IdOAB + CRLF
								aTitulo := {{"E1_PREFIXO" , SE1->E1_PREFIXO ,Nil },;
											{"E1_NUM" 	  , SE1->E1_NUM 	,Nil },;
											{"E1_TIPO" 	  , SE1->E1_TIPO 	,Nil },;
											{"E1_CLIENTE" , SE1->E1_CLIENTE ,Nil },;
											{"E1_LOJA" 	  , SE1->E1_LOJA 	,Nil },;
											{"E1_PARCELA" , SE1->E1_PARCELA ,Nil }}
								If !Empty(SE1->E1_BAIXA)
									// Realiza Integração Automatica - Financeiro + Contas a Receber + Baixar + Excluir
									lMsHelpAuto	:= .T.
									lAutoErrNoFile := .T.
									lMsErroAuto := .F.								
									MSExecAuto({|x,y,b,a| FINA070(x,y,b,a)},aTitulo,6,.F.,6)
									If lMsErroAuto
										//ConOut("[-] Erro ao Excluir Baixa Titulo - " + IdOAB)
										aErros 	:= GetAutoGRLog() // retorna o erro encontrado no execauto.
										cErrorEA += "Erro Integracao -> " + CRLF
										aEval(aErros,{|l| cErrorEA += Alltrim(l) + CRLF})
										cErrorEA += "[ExecAuto]" + CRLF
										aEval(aTitulo,{|l| cErrorEA += Alltrim(l[1]) + " = " + Alltrim(cValToChar(l[2])) + CRLF})
									Else
										//ConOut("[+] Baixa Excluida do Titulo com Sucesso - " + IdOAB)
										cErrorEA += "[ExecAuto]" + CRLF
										aEval(aTitulo,{|l| cErrorEA += "   " + Alltrim(l[1]) + " = " + Alltrim(cValToChar(l[2])) + CRLF})
									EndIf
								Else
									//ConOut("-> Titulo sem Baixa = " + IdOAB)
									cErrorEA += "[+] Titulo sem Baixa = " + IdOAB + CRLF						
								Endif
								// Realiza Exclusao do Titulo
								cErrorEA += "-> Excluir Titulo..." + CRLF
								lMsHelpAuto	:= .T.
								lAutoErrNoFile := .T.
								lMsErroAuto := .F.
								MSExecAuto({|x,y| FINA040(x,y)},aTitulo,5)
								If lMsErroAuto
									//ConOut("[-] Erro Excluir Titulo - " + IdOAB)
									aErros 	:= GetAutoGRLog() // retorna o erro encontrado no execauto.
									cErrorEA += "Erro Integracao -> " + CRLF
									aEval(aErros,{|l| cErrorEA += Alltrim(l) + CRLF})
									cErrorEA += "[ExecAuto]" + CRLF
									aEval(aTitulo,{|l| cErrorEA += Alltrim(l[1]) + " = " + Alltrim(cValToChar(l[2])) + CRLF})
								Else			
									//ConOut("[+] Exclusao do Titulo Realizada - " + IdOAB)
									cErrorEA += "[ExecAuto]" + CRLF
									aEval(aTitulo,{|l| cErrorEA += Alltrim(l[1]) + " = " + Alltrim(cValToChar(l[2])) + CRLF})
								EndIf

								// Atualiza PZD - Id 000010 - Reprocessamento de Carga pelo Job u_xfLOADE8()
								If !lMsErroAuto
									If Select(dbPZD) > 0
										(dbPZD)->(DbCloseArea())
									Endif
									BeginSql Alias dbPZD
										SELECT
											Top 1
											PZD.R_E_C_N_O_ As Recno
										FROM %Table:PZD% (NOLOCK) PZD
										WHERE PZD.D_E_L_E_T_ != '*'
										And PZD.PZD_IDURL = %Exp:cId_PZD%
										And PZD.PZD_STATUS = 'S'
										And PZD.PZD_DESC Like %Exp:IdOABQRY%
									EndSql
				
									PZD->(DbGoTo((dbPZD)->Recno))
									If Reclock("PZD",.F.)
										//ConOut("-> Atualizando Status PZD = " + Alltrim(PZD->PZD_DESC))
										PZD_STATUS := "P"
										PZD->(MsUnLock())
									Endif

								Endif
							Else
								If Select(dbPZD) > 0
									(dbPZD)->(DbCloseArea())
								Endif
								BeginSql Alias dbPZD
									SELECT
										Top 1
										PZD.R_E_C_N_O_ As Recno
									FROM %Table:PZD% (NOLOCK) PZD
									WHERE PZD.D_E_L_E_T_ != '*'
									And PZD.PZD_IDURL = %Exp:cId_PZD%
									And PZD.PZD_DESC Like %Exp:IdOABQRY%
								EndSql
								
								If (dbPZD)->(Eof())
									//ConOut("-> Titulo nao Encontrado/Sem Carga = " + IdOAB)
									cErrorEA += "-> Titulo nao Encontrado/Sem Carga = " + IdOAB + CRLF						
								Else
									PZD->(DbGoTo((dbPZD)->Recno))
									If Reclock("PZD",.F.)
										//ConOut("-> Atualizando Status PZD = " + Alltrim(PZD->PZD_DESC))
										PZD_STATUS := "P"
										PZD->(MsUnLock())
									Endif
								Endif
							Endif
						Else
							//ConOut("-> Registro ja preparado = " + IdOAB)
							cErrorEA += "-> Registro ja preparado = " + IdOAB + CRLF			
						Endif
					Next nX
				Else
					//ConOut("-> Erro ao obter Dados!")
					cErrorEA += "-> Erro ao obter Dados!" + CRLF
				Endif

				PZD->(DbGoTo((dbTmp)->Recno))
				If Reclock("PZD",.F.)
					//ConOut("-> Atualizando Status")
					PZD_STATUS := "S"
					PZD_JSOREC := cErrorEA
					PZD->(MsUnLock())
				Endif
				(dbTmp)->(DBSkip())
			End
		Endif
		(dbTmp)->(DbCloseArea())
		RESET ENVIRONMENT
	Else
		RESET ENVIRONMENT
	Endif
	//ConOut("-> Fim - OABCARGAE8.PRW")
	//ConOut(Replicate("*",50))
	END SEQUENCE
Return nil
