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
/*/{Protheus.doc} Clientes
@author  Juliano Junio de Souza
@since   08/2021
@version version
/*/
//-------------------------------------------------------------------
WsRestFul Clientes Description "Método responsavel pela Carga de Clientes para Cadastro via JOB"
WsData cCgcEmp		As String
WsMethod Post Description "Carga de Dados - Cadastro de Clientes" WsSyntax "/Clientes"
End WsRestFul

//-------------------------------------------------------------------
/*/{Protheus.doc} Post
@author  Juliano Junio de Souza
@since   05/2021
@version version
/*/
//-------------------------------------------------------------------
WsMethod Post WsReceive cCgcEmp WsService Clientes
	Local aCriaServ  := {}
	Local cCgcEmp    := IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")
	Local aEmpresas  := FwLoadSM0()    
    Local nX         := 0
    Local oJson    := Nil
    Local cBody      := ::GetContent()
    Local cChave     := ''
    Local cToken     := "aW50ZWdyYWNhb19mcm9udA==" //-- Encode64("integracao_front")
    Local cAuth      := ::GetHeader("Authorization")
    Local cStrErro   := ""
    Local cJson      := ""
    Local cMenssagem := ''
    Local nCodErro   := 200
    Local cIdTrab    := "000011"
    Local cIdPZB     := ""

    // Define interpolador de dados.
    ::SetContentType("application/json")

    // Valida Autenticação.
	If Empty(cAuth)
		nCodErro := 400
		cStrErro := u_STSHTTP(nCodErro)
		cStrErro += " - Falha Authorization."
		SetRestFault(nCodErro, cStrErro)
		Return .F.
	Else
		cAuth := Alltrim(cAuth)
	Endif
		
	If cAuth != cToken
		nCodErro := 400
		cStrErro := u_STSHTTP(nCodErro)
		cStrErro += " - Falha Token Autorizacao."
		SetRestFault(nCodErro, cStrErro)
		Return .F.	
	Endif

    // Valida envio de Conteudo.
	If Empty(cBody)
		cJson := '{"Mensagem": "Sem conteudo JSON.", "lret":false}'
		::SetResponse( cJson )
		Return .T.
	EndIf

	RpcClearEnv()
	RpcSetType(3)
	RpcSetEnv("01","01000101")
    SM0->(DbSetOrder(1))

    ***********************************************************************
    // Tentativa de Execução.
//	TRYEXCEPTION

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
        if AttisMemberOf(oJson,"Clientes") == Nil
            cJson := '{"Mensagem": "Objeto Principal Ausente, analise documentação!", "lret":false}'
            ::SetResponse( cJson )
            Return .T.
        endif

		DbSelectArea("PZD")
		PZD->(DbSetOrder(2))

		If Len(oJson:Clientes) > 0

			cJson := "{"

			//Cria servi�o no montitor
			aCriaServ := U_MonitRes(cIdTrab, 1, Len(oJson:Clientes) )   
			cIdPZB 	  := aCriaServ[2]

			For nX := 1 to len(oJson:Clientes)
				
				cChave := AVkEY(oJson:Clientes[nX]:A1_COD,"A1_COD") +"/"+ AVkEY(oJson:Clientes[nX]:A1_LOJA,"A1_LOJA")
				cMenssagem  := "OABCARGAA1 - Post Carga SA1 = " + Alltrim(cValToChar(cChave))
				cStrErro := 'Registro Armazenado com seucesso! Tracker: ' + cIdPZB
				U_MonitRes(cIdTrab, 2, , cIdPZB, cMenssagem, .T., cStrErro, cBody, "Sucesso!", "", .F., .F.)
				U_MonitRes(cIdTrab, 3, , cIdPZB, , .T.)
				PZD->(DbGoTop())
				PZD->(DbSeek(xFilial("PZD")+cIdTrab+cIdPZB))
				If RecLock("PZD",.F.)
					PZD->PZD_STATUS := "P"
				Endif

				cJson += '"Clientes":['
				cJson += "{" 
				cJson += '"Mensagem' + '":"' + cStrErro + '",'
				cJson += '"A1_COD' + '":"' + AVkEY(oJson:Clientes[nX]:A1_COD,"A1_COD") + '",'
				cJson += '"A1_LOJA' + '":"' + AVkEY(oJson:Clientes[nX]:A1_LOJA,"A1_LOJA") + '",'
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

		U_MonitRes(cIdTrab, 2, 0, cIdPZB, oException:Description, .F., "OABCARGAA1.PRW:LOG"+Time(), cBody, oException:Description, "Errorlog", .F., .F., "", .F., .F., .F.)
		//Finaliza o processo na PZB - Error
		U_MonitRes(cIdTrab, 3, 0, cIdPZB, "", .F.)

		cJson += '"Clientes":['
		cJson += "{" 
		cJson += '"Mensagem' + '":"' + "OABCARGAA1.PRW:LOG"+Time()+CRLF+oException:Description + '",'
		cJson += '"lret' + cValTochar(1) + '":false'
		cJson += "},"

	ENDEXCEPTION
*/
Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} xfLOADA1
@author  Juliano Junio de Souza
@since   08/2021
@version version
/*/
//-------------------------------------------------------------------
User Function xfLOADA1 //u_xfLOADA1()
    Local dbTmp      := GetNextAlias()
	Local dbPr3      := GetNextAlias()
	Local cIdTrab    := "000011"
	Local cId_PR3    := "000001"
	Local oJson      := Nil
	Local aDados     := {}
	Local nX 		 := 0
	Local IdOAB    := ""
	Local cMenssagem := ""
	Local lIncOK     := .F.
	Private cErrorEA := ""
	Private lMsHelpAuto	:= .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto := .F.

    ***********************************************************************
	//ConOut(Replicate("*",50))
	//ConOut("-> Start - OABCARGAA1.PRW")

	RpcClearEnv()
	RpcSetEnv("01","01")
	SM0->(DbSetOrder(1))
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
		DBSelectArea("SA1")

		DbSelectArea(dbTmp)
		(dbTmp)->(DbGoTop())
		while (dbTmp)->(!Eof())
			//ConOut("-> Validando Request...")
			aDados := Alltrim((dbTmp)->Request)
			cErrorEA := ""
			If !Empty(aDados)
				//ConOut("-> Obtendo Dados...")
				FWJsonDeserialize(aDados, @oJson)
				If Valtype(oJson) != "O"
					//ConOut("Error-OABCARGAA1-2")
					(dbTmp)->(DBSkip())
					Loop
				Endif
				If AttisMemberOf(oJson,"Clientes")
					aDados := oJson:Clientes
					For nX := 1 to Len(aDados)
						IdOAB := AVkEY(aDados[nX]:A1_COD,"A1_COD") + AVkEY(aDados[nX]:A1_LOJA,"A1_LOJA")
						//ConOut("-> Cliente = " + IdOAB)
						cMenssagem  := "OABCARGAA1 - Post Clientes " + IdOAB
						SA1->(dbSetOrder(1))
						SA1->(DbGoTop())
						If SA1->(DBSeek(xFilial("SA1") + IdOAB)) 
							Cadastro(oJson, @lIncOK, aDados[nX], 4, AVkEY(aDados[nX]:A1_COD,"A1_COD") +"/"+ AVkEY(aDados[nX]:A1_LOJA,"A1_LOJA"))
						Else	                                   
							Cadastro(oJson, @lIncOK, aDados[nX], 3, AVkEY(aDados[nX]:A1_COD,"A1_COD") +"/"+ AVkEY(aDados[nX]:A1_LOJA,"A1_LOJA"))
						Endif
					Next nX
				//Else
					//ConOut("Error-OABCARGAA1-3")
				Endif
			//Else
				//ConOut("Error-OABCARGAA1-1")
			Endif
			PZD->(DbGoTo((dbTmp)->Recno))
			If Reclock("PZD",.F.)
				//ConOut("-> Atualizando Status")
				PZD_STATUS := Iif(!lIncOK,"E","S")
				PZD_JSOREC := cErrorEA
				PZD->(MsUnLock())
			Endif
			(dbTmp)->(DBSkip())
		End
		
		(dbTmp)->(DbCloseArea())
		//ConOut("-> LOG " + CRLF + CRLF + cErrorEA + CRLF )
		//ConOut("-> Fim - OABCARGAA1.PRW")
		//ConOut(Replicate("*",50))
	/*
	CATCHEXCEPTION USING oException
		//ConOut("-> Error - OABCARGAA1 - "+Time()+CRLF+oException:Description)
		//ConOut("-> Fim - OABCARGAA1.PRW")
		//ConOut(Replicate("*",50))
		// Recursivo
		u_xfLOADA1()
	ENDEXCEPTION*/
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} Cadastro
@author  Juliano Junio de Souza
@since   08/2021
@version version
/*/
//-------------------------------------------------------------------
Static Function Cadastro(JsOri, lIncOK, oJsoAux, nOpt, IdOAB)

	Local cQuery    := ""
	Local cAlsQry   := GetNextAlias() //CriaTrab(Nil,.F.)
	Local cStrErro  := ""
	Local aDados    := {}
	Local nErro     := 0
	Local cEnt		:= ''
	Local ntpExec   := nOpt
	Local cMensagem := ''
	Local cLogExt   := ''
	Local cIdPZB    := "000001"

	Private lMsHelpAuto	:= .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto := .F.

	cQuery := " SELECT PR3.* FROM " + RetSqlName("PR3") + " (NOLOCK) PR3 "
	cQuery += " INNER JOIN " + RetSqlName("PR2") + " (NOLOCK) PR2 "
	cQuery += " ON PR3_FILIAL = PR2_FILIAL AND PR3_CODIGO = PR2_CODIGO "
	cQuery += " WHERE PR2_CODPZA = '000001' AND PR2.D_E_L_E_T_ = ' '  AND PR3.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	cMensagem := Iif(nOpt==3, "Incluir", "Alterar") + " " + IdOAB
	(cAlsQry)->(DbGoTop())
	
	aDados      := {}
	cCgcCli := oJsoAux:A1_CGC               

	While !(cAlsQry)->(Eof())
		cCpo        := Alltrim((cAlsQry)->PR3_CPOORI)
		If (cAlsQry)->PR3_TPCONT == "1"
			cConteudo := &("oJsoAux:" + cCpo)  
		Else
			cConteudo := &((cAlsQry)->PR3_CONTEU)
		EndIf
		If UPPER(AllTrim(cCpo)) == "CEP"
			cLoc	:= HttpGet("https://viacep.com.br/ws/" + AllTrim(cConteudo) + "/json/")
			FWJsonDeserialize(cLoc, @oLoc)       
			If oLoc <> NIL
				//aAdd(aDados,{"A1_END"		,AllTrim(UPPER(NOACENTO(DecodeUtf8(oLoc:logradouro))))		,NIL})
				//aAdd(aDados,{"A1_BAIRRO"	,AllTrim(UPPER(NOACENTO(DecodeUtf8(oLoc:bairro))))			,NIL})
				aAdd(aDados,{"A1_COD_MUN"	,SUBSTR(UPPER(NOACENTO(DecodeUtf8(oLoc:ibge))),3,5)			,NIL})
				//aAdd(aDados,{"A1_MUN"		,UPPER(NOACENTO(DecodeUtf8(oLoc:localidade)))				,NIL})
				//aAdd(aDados,{"A1_EST"		,AllTrim(UPPER(NOACENTO(DecodeUtf8(oLoc:uf))))				,NIL})
				//cEstado := AllTrim(UPPER(NOACENTO(DecodeUtf8(oLoc:uf))))
				//cEstado := AllTrim(POSICIONE("SX5",1,xFilial("SX5")+"12"+cEstado,"X5_DESCRI"))
				// aAdd(aDados,{"A1_ESTADO",cEstado,NIL})
			EndIf
		EndIf 
		If UPPER(AllTrim(cCpo)) == 'A1_XDTINSC' .oR.  UPPER(AllTrim(cCpo)) == 'A1_DTNASC'
				cConteudo := StoD(cConteudo)
		EndIf
		aAdd(aDados, {Alltrim((cAlsQry)->PR3_CPODES), cConteudo, nil})
		(cAlsQry)->(DbSkip())
	End

	cErrorEA += "[ExecAuto - Cadastro]" + CRLF
	MSExecAuto({|x,y| Mata030(x,y)},aDados,nOpt)

	If lMsErroAuto
		//ConOut("-> Erro Emissao Cliente - " + cTit)
		cStrErro := ""
		aErros 	:= GetAutoGRLog() // retorna o erro encontrado no execauto.
		cLogExt := ""
		aEval(aErros,{|l| cLogExt += Alltrim(l) + CRLF})
		cErrorEA += "Erro Integração -> " + StrTran(cLogExt, CRLF, " ") + " | "
		cLogExt += CRLF + "[ExecAuto]" + CRLF + CRLF
		aEval(aDados,{|l| cLogExt += Alltrim(l[1]) + " = " + Alltrim(cValToChar(l[2])) + CRLF})
		nErro   := Ascan(aErros, {|x| "INVALIDO" $ alltrim(Upper(x))  } )

		If nErro > 0
			cStrErro += aErros[ nErro ]
		Else
			For nErro := 1 To Len( aErros )
				cStrErro += ( aErros[ nErro ] + cEnt )
			Next nErro
		EndIf

		cStrErro := Alltrim(cStrErro)
		RollBackSX8()
		U_MonitRes("000001", 2, , cIdPZB, cMensagem, .F., cStrErro, cLogExt, "Erro OABCARGAA1", "", .F., .F.)
		//Finaliza o processo na PZB
		U_MonitRes("000001", 3, , cIdPZB, , .F.)

		lIncOK := .F.

	Else			

		//ConOut("-> Emissao Cliente Realizada - " + cTit)
		cLogExt += CRLF + "[ExecAuto]" + CRLF + CRLF
		aEval(aDados,{|l| cLogExt += Alltrim(l[1]) + " = " + Alltrim(cValToChar(l[2])) + CRLF})
		cLogExt += "Sucesso!" + CRLF
		ConfirmSx8()
		If ntpExec == 3
			U_MonitRes("000001", 2, , cIdPZB, cMensagem, .T., "Cliente incluso com sucesso", "", cLogExt, "", .F., .F.)
		Else
			U_MonitRes("000001", 2, , cIdPZB, cMensagem, .T., "Cliente Alterado com sucesso", "", cLogExt, "", .F., .F.)
		Endif 

		//Finaliza o processo na PZB
		U_MonitRes("000001", 3, , cIdPZB, , .T.)

		lIncOK := .T.
	EndIf


	(cAlsQry)->(dbCloseArea())

	lMsErroAuto := .F.

Return 
