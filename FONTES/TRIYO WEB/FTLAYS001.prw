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


#DEFINE cEnt Chr(10)+ Chr(13)

//#DEFINE cEnt Chr(BuscaXML) + Chr(13)


WsRestFul GetCli Description "Metodo Responsavel por Retornar as Cond. Pagto que Sofreram algum tipo de Movimentacao"

WsData cCgcCli		As String Optional
WsData cTpCli       AS String Optional
WsData cCgcEmp      As String Optional
WsData cCodCli      As String Optional
WsData cCodLoja     As String Optional

WsData nPage        As float Optional

WsMethod Get Description "Cadastro Clientes" WsSyntax "/GetCli"

End WsRestFul

WsMethod Get WsReceive cCgcCli, cTpCli, cCgcEmp, nPage WsService GetCli

	Local cJson     := ""
	Local cQuery    := ""   
	Local cIdPZB	:= "" 

	Local nX		:= 0
	Local nY		:= 0
	Local nDE		:= 0
	Local nPags		:= 0
	Local nLine     := 1
	Local nCount    := 1
	Local nPosEmp	:= 0
	Local nQtdPag	:= 0

	Local aCpos     := {}
	Local cPagsAux	:= ""
	Local aCposCab  := {}
	Local cConteudo := ""
	Local aCriaServ := {}
	Local aCont     := {}
	Local aEmpresas := FwLoadSM0()

	Local cTpCli    := IIf(::cTpCli <> Nil  , ::cTpCli  , "")
	Local cCgcCli   := IIf(::cCgcCli <> Nil , ::cCgcCli , "")
	Local cCgcEmp   := IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")
	Local nPage		:= IIf(::nPage <> Nil, ::nPage, 1)
	Local cCodCli   := IIf(::cCodCli <> Nil , ::cCodCli , "")
	Local cCodLoja  := IIf(::cCodLoja <> Nil , ::cCodLoja , "")
	Local cQryRes   := ""

	Private cAlsQry   := CriaTrab(Nil,.F.)
	Private cAlsRes   := CriaTrab(Nil,.F.)

	nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == cCgcEmp })

	If nPosEmp == 0
		cJson := '{"Erro":"Empresa nao cadastrada."}'
		::SetResponse( cJson )
		Return .T.
	Else
		RpcClearEnv()
		RpcSetEnv(aEmpresas[nPosEmp][1],aEmpresas[nPosEmp][2])
	EndIf   

	nPags	:= GetMV("FT_QTPAGIC",,10)

	cQuery 	:= " SELECT PR2.* FROM " + RetSqlName("PR2") + " (NOLOCK) PR2 "
	cQuery 	+= " INNER JOIN " + RetSqlName("PR1") + " (NOLOCK) PR1 "
	cQuery 	+= " ON PR2_FILIAL = PR1_FILIAL AND PR2_CODIGO = PR1_CODIGO "
	cQuery 	+= " WHERE PR1_CODPZA = '000001' AND PR1.D_E_L_E_T_ = ' '  AND PR2.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	While !(cAlsQry)->(Eof())

		If nCount == 1
			cQryRes := " SELECT  "
			cQryRes += (cAlsQry)->PR2_CPODES 

		Else
			cQryRes += " , " + (cAlsQry)->PR2_CPODES  

		EndIf

		AADD(aCpos, Alltrim((cAlsQry)->PR2_CPODES) )
		AADD(aCposCab, Alltrim((cAlsQry)->PR2_CPOORI))

		If (cAlsQry)->PR2_ISFUNC == "S"
			AADD(aCont, Alltrim( (cAlsQry)->PR2_CONTEU ))
		Else
			AADD(aCont, "")
		EndIf

		nCount++
		(cAlsQry)->(DbSkip())

	End

	If !Empty(cQryRes)

		cQryRes += " FROM " + RetSqlName("SA1") + " (NOLOCK) SA1 "
		cQryRes += " WHERE "

		//Codigo do cliente
		If !Empty(cCodCli)
			cQryRes += " A1_COD = '" + cCodCli + "' AND "
		EndIf

		//Loja do cliente
		If !Empty(cCodLoja)
			cQryRes += " A1_LOJA = '" + cCodLoja + "' AND "
		EndIf

		//Tipo de cliente
		If !Empty(cCgcCli)
			cQryRes += " A1_CGC = '" + cCgcCli + "' AND "
		EndIf

		//Tipo de cliente
		If !Empty(cTpCli)
			cQryRes += " A1_PESSOA = '" + cTpCli + "' AND "
		EndIf

		cQryRes += " SA1.D_E_L_E_T_ = ' ' "

		If Select(cAlsRes) > 0; (cAlsRes)->(dbCloseArea()); Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryRes),cAlsRes,.T.,.T.)

		If !(cAlsRes)->(Eof()) 

			nQtdReg		:= Contar(cAlsRes,"!Eof()")
			nQtdPag		:= (nQtdReg/nPags)
			cPagsAux	:= cValToChar(nQtdPag)

			If SUBSTR(cPagsAux,1,1) == "0"
				nQtdPag := 1    			
			ElseIf At(".",cPagsAux) <> 0 
				nQtdPag := Val(SUBSTR(cPagsAux,1,( At(".",cPagsAux)-1 )))
				nQtdPag++
			Else
				nQtdPag := Val(cPagsAux)
			EndIf		

			//Cria serviço no montitor
			aCriaServ := U_MonitRes("000001", 1, nQtdReg)   
			cIdPZB 	  := aCriaServ[2]

			cJson := '{'
			cJson += '"NumeroPaginas":"'+ cValToChar(nQtdPag) +'",'

			If nPage == nQtdPag
				cJson += '"IsLastPage":true,
			Else
				cJson += '"IsLastPage":false,
			EndIf

			cJson += '"clientes":['

			(cAlsRes)->(DbGoTop())

			If Empty(cCgcCli) .And. Empty(cCodCli)

				nDE := ((nPage*nPags) - nPags)

				For nY := 0 To nDE
					(cAlsRes)->(DBSkip())
				Next nY

			EndIf

		Else

			cJson += "{"
			cJson += '"clientes":['
			cJson += "{" 
			cJson += '"errorMessage' + cValTochar(1) + '":"Nao existem registros.",'
			cJson += '"lret' + cValTochar(1) + '":false'
			cJson += '}]}'

			::SetContentType("application/json")
			::SetResponse( cJson )

			Return(.T.)

		EndIf

		While !(cAlsRes)->(Eof()) 

			cJson += "{"

			For nX := 1 to Len(aCpos)

				If Empty(aCont[nX])    

					cConteudo := & ("(cAlsRes)->" + aCpos[nX])

					If ValType( cConteudo) == "N"
						cJson += '"' + aCposCab[nX] + '":'
						cJson += cValTochar(cConteudo)
					Else
						cConteudo   := Alltrim(cConteudo)
						cJson       += '"' + aCposCab[nX] + '":'
						cJson       += '"' + cConteudo + '"'
					EndIf

					cJson += ','

				Else

					cConteudo := &(aCont[nX])

					If ValType( cConteudo) == "N"
						cJson += '"' + aCposCab[nX] + '":'
						cJson += cValTochar(cConteudo)
					Else
						cConteudo   := Alltrim(cConteudo)
						cJson       += '"' + aCposCab[nX] + '":'
						cJson       += '"' + cConteudo + '"'
					EndIf

					cJson += ','

				EndIf

			Next nX

			cJson += '"lret' + cValTochar(nLine) + '":true'
			cJson += "},"

			cMenssagem  := "Get realizado com sucesso."
			U_MonitRes("000001", 2, , cIdPZB, cMenssagem, .T., "Get de clientes", cJson, "", "", .F., .F.)

			nLine++

			(cAlsRes)->(DbSkip())

			If !Empty(cCgcCli) .Or. !Empty(cCodCli)

				If (cAlsRes)->(Eof())
					cJson := Left(cJson, Rat(",", cJson)-1)
					Exit
				EndIf

			Else

				If nLine == (nPags + 1) .Or. (cAlsRes)->(Eof())
					cJson := Left(cJson, Rat(",", cJson)-1)
					Exit
				EndIf

			EndIf
		End

		(cAlsRes)->(dbCloseArea())

		If Empty(cJson) 

			cJson += "{"
			cJson += '"clientes":['
			cJson += "{" 
			cJson += '"errorMessage' + cValTochar(1) + '":"'+ "cliente nao encontrado" +'",'
			cJson += '"lret' + cValTochar(1) + '":false'
			cJson += "},"

		EndIf

		//Finaliza o processo na PZB
		U_MonitRes("000001", 3, , cIdPZB, , .T.)

	EndIf

cJson += "]}"

cJson := StrTran(cJson,chr(9),'')

(cAlsQry)->(dbCloseArea())

::SetContentType("application/json")
::SetResponse( cJson )

Return(.T.)

WsRestFul PostForn Description "Metodo Responsavel por Retornar as Cond. Pagto que Sofreram algum tipo de Movimentacao"

WsData cCgcEmp		As String

WsMethod Post Description "Cadastro de Cond. Pagamento" WsSyntax "/PostCli"

End WsRestFul

WsMethod Post WsReceive cCgcEmp WsService PostCli

	Local cBody     := ::GetContent()
	Local oJsoAux   := Nil
	Local cQuery    := ""
	Local oLoc		:= Nil
	Local cLoc		:= ""
	Local cAlsQry   := CriaTrab(Nil,.F.)
	Local nX
	Local cStrErro  := ""
	Local aDados    := {}
	Local aCriaServ := {}
	Local nErro     := 0
	Local cJson     := ""
	Local cCgcEmp   := IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")
	Local aEmpresas := FwLoadSM0()

	/**************************************************
	* força a gravação das informações de erro em 	*
	* array para manipulação da gravação ao invés 	*
	* de gravar direto no arquivo temporário		*
	**************************************************/
	Private lMsHelpAuto	:= .T.

	/**************************************************
	* força a gravação das informações de erro em 	*
	* array para manipulação da gravação ao invés 	*
	* de gravar direto no arquivo temporário 		*
	**************************************************/
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto := .F.

	nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == cCgcEmp })

	If nPosEmp == 0
		cJson := '{"Erro":"Empresa nao cadastrada."}'
		::SetResponse( cJson )
		Return .T.
	Else
		RpcClearEnv()
		RpcSetEnv(aEmpresas[nPosEmp][1],aEmpresas[nPosEmp][2])
	EndIf

	FWJsonDeserialize(cBody, @oJsoAux)

	SM0->(DbSetOrder(1))

	cQuery := " SELECT PR2.* FROM " + RetSqlName("PR2") + " (NOLOCK) PR2 "
	cQuery += " INNER JOIN " + RetSqlName("PR1") + " (NOLOCK) PR1 "
	cQuery += " ON PR2_FILIAL = PR1_FILIAL AND PR2_CODIGO = PR1_CODIGO "
	cQuery += " WHERE PR1_CODPZA = '000002' AND PR1.D_E_L_E_T_ = ' '  AND PR2.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	If len(oJsoAux:Clientes) > 0

		cJson := "{"

		//Cria serviço no montitor
		aCriaServ := U_MonitRes("000002", 1, Len(oJsoAux:Clientes) )   
		cIdPZB 	  := aCriaServ[2]

		For nX := 1 to len(oJsoAux:Clientes)

			(cAlsQry)->(DbGoTop())

			aDados      := {}

			aAdd(aDados, {"A1_COD"  , GetSXeNum("SA1","A1_COD","A1_COD")    , nil})
			aAdd(aDados, {"A1_LOJA" , "01"                                  , nil})


			While !(cAlsQry)->(Eof())

				cCpo        := Alltrim((cAlsQry)->PR2_CPOORI)

				If (cAlsQry)->PR2_TPCONT == "1"
					cConteudo := &("oJsoAux:Clientes[" + cValTochar(nX) + "]:" + cCpo)  
				Else
					cConteudo := &((cAlsQry)->PR2_CONTEU)
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

					FWJsonDeserialize(cBody, @oJsoAux)

				EndIf 

				aAdd(aDados, {Alltrim((cAlsQry)->PR2_CPODES), cConteudo, nil})

				(cAlsQry)->(DbSkip())

			End

			aDados := FWVetByDic(aDados,"SA1",.F.) //Organiza o array
			MSExecAuto({|x,y| Mata030(x,y)},aDados,3)

			::SetContentType("application/json")

			cMenssagem  := "Post clientes"

			If lMsErroAuto

				cStrErro := ""

				aErros 	:= GetAutoGRLog() // retorna o erro encontrado no execauto.
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

				U_MonitRes("000002", 2, , cIdPZB, cMenssagem, .F., cStrErro, "", cBody, "", .F., .F.)

				//Finaliza o processo na PZB
				U_MonitRes("000002", 3, , cIdPZB, , .F.)

				cJson += '"clientes":['
				cJson += "{" 
				cJson += '"errorMessage' + cValTochar(nX) + '":"' + cStrErro + '",'
				cJson += '"lret' + cValTochar(nX) + '":false'
				cJson += "},"

			Else

				ConfirmSx8()

				U_MonitRes("000002", 2, , cIdPZB, cMenssagem, .T., "Cliente incluso com sucesso", "", cBody, "", .F., .F.)

				//Finaliza o processo na PZB
				U_MonitRes("000002", 3, , cIdPZB, , .T.)

				cJson += '"clientes":['
				cJson += "{" 
				cJson += '"lret' + cValTochar(nX) + '":true'
				cJson += "},"

			EndIf

		Next nX

		cJson := Left(cJson, Rat(",", cJson)-1)
		cJson += "]}"

		::SetResponse( cJson )

	EndIf

(cAlsQry)->(dbCloseArea())

Return(.T.)

WsRestFul GetProd Description "Metodo Responsavel por Retornar Consulta de Produtos"

WsData cCgcEmp		As String Optional
WsData cCod			As String Optional
WsData cCodBar	    As String Optional
WsData cTipo        As String Optional
WsData cBloq        As String Optional
WsData nPage        As Integer Optional

WsMethod Get Description "Consulta de Produtos" WsSyntax "/GetProd"

End WsRestFul

WsMethod Get WsReceive cCgcEmp, cCod, nPage WsService GetProd

	Local cQuery    := ""    
	Local aCpos     := {}
	Local aCposCab  := {}
	Local aCont     := {}
	Local cJson     := ""
	Local cQryRes   := ""
	Local nCount    := 1
	Local nX
	Local cConteudo := ""
	Local cIdPZB	:= ""
	Local aCriaServ := {}
	Local nLine     := 1
	Local nPosEmp	:= 0
	Local cCod    	:= IIf(::cCod <> Nil  , ::cCod  , "")
	Local cCgcEmp   := IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")
	Local cCodBar   := IIf(::cCodBar <> Nil , ::cCodBar , "")
	Local nPage		:= IIf(::nPage <> Nil, ::nPage, 1)
	Local cTipo     := IIf(::cTipo <> Nil , ::cTipo , "")
	Local cBloq     := IIf(::cBloq <> Nil , ::cBloq , "")
	Local aEmpresas := FwLoadSM0()
	LOcal nY 
	Private cAlsQry   := CriaTrab(Nil,.F.)
	Private cAlsRes   := CriaTrab(Nil,.F.)

	nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == cCgcEmp })

	If nPosEmp == 0
		cJson := '{"Erro":"Empresa nao cadastrada."}'
		::SetResponse( cJson )
		Return .T.
	Else
		RpcClearEnv()
		RpcSetEnv(aEmpresas[nPosEmp][1],aEmpresas[nPosEmp][2])
	EndIf

	nPags	:= GetMV("FT_QTPAGIC",,10)

	cQuery := " SELECT PR2.* FROM " + RetSqlName("PR2") + " (NOLOCK) PR2 "
	cQuery += " INNER JOIN " + RetSqlName("PR1") + " (NOLOCK) PR1 "
	cQuery += " ON PR2_FILIAL = PR1_FILIAL AND PR2_CODIGO = PR1_CODIGO "
	cQuery += " WHERE PR1_CODPZA = '000003' AND PR1.D_E_L_E_T_ = ' '  AND PR2.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	While !(cAlsQry)->(Eof())

		If nCount == 1
			cQryRes := " SELECT  "
			cQryRes += (cAlsQry)->PR2_CPODES  
		Else
			If (cAlsQry)->PR2_ISFUNC <> "S"
				cQryRes += " , " + (cAlsQry)->PR2_CPODES  
			EndIf
		EndIf

		AADD(aCpos, Alltrim((cAlsQry)->PR2_CPODES) )
		AADD(aCposCab, Alltrim((cAlsQry)->PR2_CPOORI))

		If (cAlsQry)->PR2_ISFUNC == "S"
			AADD(aCont, Alltrim( (cAlsQry)->PR2_CONTEU ))
		Else
			AADD(aCont, "")
		EndIf

		nCount++
		(cAlsQry)->(DbSkip())

	End

	If !Empty(cQryRes)

		cQryRes += " FROM " + RetSqlName("SB1") + " (NOLOCK) SB1 "

		//Left Join com SB5 para complemento de produtos
		cQryRes += " LEFT JOIN " + RetSqlName("SB5") + " (NOLOCK) SB5 "
		cQryRes += " ON B5_FILIAL = B1_FILIAL AND "
		cQryRes += " B5_COD = B1_COD AND SB5.D_E_L_E_T_ = ' ' "

		cQryRes += " WHERE "

		//Codigo do produto
		If !Empty(cCod)
			cQryRes += " B1_COD = '" + cCod + "' AND "
		EndIf

		//Codigo debarras
		If !Empty(cCodBar)
			cQryRes += " B1_CODBAR = '" + cCodBar + "' AND "
		EndIf

		//Tipo
		If !Empty(cTipo)
			cQryRes += " B1_TIPO = '" + cTipo + "' AND "
		EndIf

		//Bloqueio
		If !Empty(cBloq)
			cQryRes += " B1_MSBLQL = '" + cBloq + "' AND "
		EndIf

		cQryRes += " SB1.D_E_L_E_T_ = ' ' ORDER BY B1_COD"

		If Select(cAlsRes) > 0; (cAlsRes)->(dbCloseArea()); Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryRes),cAlsRes,.T.,.T.)

		If !(cAlsRes)->(Eof()) 

			nQtdReg		:= Contar(cAlsRes,"!Eof()")
			nQtdPag		:= (nQtdReg/nPags)
			cPagsAux	:= cValToChar(nQtdPag)

			If SUBSTR(cPagsAux,1,1) == "0"
				nQtdPag := 1    			
			ElseIf At(".",cPagsAux) <> 0 
				nQtdPag := Val(SUBSTR(cPagsAux,1,( At(".",cPagsAux)-1 )))
				nQtdPag++
			Else
				nQtdPag := Val(cPagsAux)
			EndIf		

			//Cria serviço no montitor
			aCriaServ := U_MonitRes("000003", 1, nQtdReg)   
			cIdPZB 	  := aCriaServ[2]

			cJson := '{'
			cJson += '"NumeroPaginas":"'+ cValToChar(nQtdPag) +'",'

			If nPage == nQtdPag
				cJson += '"IsLastPage":true,
			Else
				cJson += '"IsLastPage":false,
			EndIf

			cJson += '"produtos":['

			(cAlsRes)->(DbGoTop())

			If Empty(cCod) .And. Empty(cCodBar)

				nDE := ((nPage*nPags) - nPags)

				For nY := 0 To nDE
					(cAlsRes)->(DBSkip())
				Next nY

			EndIf

		Else

			cJson += "{"
			cJson += '"produtos":['
			cJson += "{" 
			cJson += '"errorMessage' + cValTochar(1) + '":"'+ "produto nao encontrado" +'",'
			cJson += '"lret' + cValTochar(1) + '":false'
			cJson += "},"

			::SetContentType("application/json")
			::SetResponse( cJson )

			Return(.T.)

		EndIf

		While !(cAlsRes)->(Eof())

			cJson += "{"

			For nX := 1 to Len(aCpos)

				If Empty(aCont[nX])    

					cConteudo := & ("(cAlsRes)->" + aCpos[nX])

					If ValType( cConteudo) == "N"
						cJson += '"' + aCposCab[nX] + '":'
						cJson += cValTochar(cConteudo)
					Else
						cConteudo   := Alltrim(cConteudo)
						cJson       += '"' + aCposCab[nX] + '":'
						cJson       += '"' + cConteudo + '"'
					EndIf

				Else

					cConteudo := &(aCont[nX])

					If ValType( cConteudo) == "N"
						cJson += '"' + aCposCab[nX] + '":'
						cJson += cValTochar(cConteudo)
					Else
						cConteudo   := Alltrim(cConteudo)
						cJson       += '"' + aCposCab[nX] + '":'
						cJson       += '"' + cConteudo + '"'
					EndIf

				EndIf

				cJson += ','

			Next nX

			/*
			cConteudo := AllTrim(POSICIONE("SB1",1,xFilial("SB1")+AllTrim(cCod),"B1_PROC"))
			cConteudo += AllTrim(POSICIONE("SB1",1,xFilial("SB1")+AllTrim(cCod),"B1_LOJPROC"))      
			cConteudo := AllTrim(POSICIONE("SA2",1,xFilial("SA2")+cConteudo,"A2_NOME"))

			cJson       += '"NomeForn":'
			cJson       += '"' + AllTrim(cConteudo) + '"'
			*/

			cJson += '"lret' + cValTochar(nLine) + '":true'
			cJson += "},"

			cMenssagem  := "Get realizado com sucesso."
			U_MonitRes("000003", 2, , cIdPZB, cMenssagem, .T., "Get de Produtos", cJson, "", "", .F., .F.)

			nLine++

			(cAlsRes)->(DbSkip())

			If !Empty(cCod) .And. !Empty(cCodBar)

				If (cAlsRes)->(Eof())
					cJson := Left(cJson, Rat(",", cJson)-1)
					Exit
				EndIf

			Else

				If nLine == (nPags + 1) .Or. (cAlsRes)->(Eof())
					cJson := Left(cJson, Rat(",", cJson)-1)
					Exit
				EndIf

			EndIf

		End

		(cAlsRes)->(dbCloseArea())

		//Finaliza o processo na PZB
		U_MonitRes("000003", 3, , cIdPZB, , .T.)

	EndIf

cJson += "]}"

cJson	:= StrTran(cJson,chr(9),'')

(cAlsQry)->(dbCloseArea())

::SetContentType("application/json")
::SetResponse( cJson )

Return(.T.)

WsRestFul GetForn Description "Metodo Responsavel por Retornar Cadastro de Forncedores"

WsData cCgcForn		As String Optional
WsData cTpForn      AS String Optional
WsData cCgcEmp      As String Optional
WsData cCodFor      As String Optional
WsData cCodLoja     As String Optional

WsData nPage        As Integer Optional

WsMethod Get Description "Cadastro de Fornecedores" WsSyntax "/GetForn"

End WsRestFul

WsMethod Get WsReceive cCgcForn, cTpForn, cCgcEmp, nPage WsService GetForn

	Local cQuery    := ""    
	Local aCpos     := {}
	Local aCposCab  := {}
	Local cJson     := ""	
	Local cQryRes   := ""
	Local nCount    := 1
	Local nX
	Local cConteudo := ""
	Local aCriaServ := {}
	Local nLine     := 1
	Local cTpForn   := IIf(::cTpForn <> Nil  , ::cTpForn  , "")
	Local cCgcForn  := IIf(::cCgcForn <> Nil , ::cCgcForn , "")
	Local cCgcEmp   := IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")
	Local cCodFor   := IIf(::cCodFor <> Nil , ::cCodFor , "")
	Local cCodLoja  := IIf(::cCodLoja <> Nil , ::cCodLoja , "")
	Local nPage		:= IIf(::nPage <> Nil, ::nPage, 1)
	Local aEmpresas := FwLoadSM0()
	Local nY
	Private cAlsQry   := CriaTrab(Nil,.F.)
	Private cAlsRes   := CriaTrab(Nil,.F.)

	nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == cCgcEmp })

	If nPosEmp == 0
		cJson := '{"Erro":"Empresa nao cadastrada."}'
		::SetResponse( cJson )
		Return .T.
	Else
		RpcClearEnv()
		RpcSetEnv(aEmpresas[nPosEmp][1],aEmpresas[nPosEmp][2])
	EndIf

	nPags	:= GetMV("FT_QTPAGIC",,10)

	cQuery := " SELECT PR2.* FROM " + RetSqlName("PR2") + " (NOLOCK) PR2 "
	cQuery += " INNER JOIN " + RetSqlName("PR1") + " (NOLOCK) PR1 "
	cQuery += " ON PR2_FILIAL = PR1_FILIAL AND PR2_CODIGO = PR1_CODIGO "
	cQuery += " WHERE PR1_CODPZA = '000004' AND PR1.D_E_L_E_T_ = ' '  AND PR2.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	While !(cAlsQry)->(Eof())

		If nCount == 1
			cQryRes := " SELECT  "
			cQryRes += (cAlsQry)->PR2_CPODES 

		Else
			cQryRes += " , " + (cAlsQry)->PR2_CPODES  

		EndIf

		AADD(aCpos, Alltrim((cAlsQry)->PR2_CPODES) )
		AADD(aCposCab, Alltrim((cAlsQry)->PR2_CPOORI))

		nCount++
		(cAlsQry)->(DbSkip())

	End

	cQryRes += " FROM " + RetSqlName("SA2") + " (NOLOCK) SA2 "
	cQryRes += " WHERE "

	//Codigo do cliente
	If !Empty(cCodFor)
		cQryRes += " A2_COD = '" + cCodFor + "' AND "
	EndIf

	//Loja do cliente
	If !Empty(cCodLoja)
		cQryRes += " A2_LOJA = '" + cCodLoja + "' AND "
	EndIf

	//Tipo de fornecedor
	If !Empty(cCgcForn)
		cQryRes += " A2_CGC = '" + cCgcForn + "' AND "
	EndIf

	//Tipo de fornecedor
	If !Empty(cTpForn)
		cQryRes += " A2_TIPO = '" + cTpForn + "' AND "
	EndIf

	cQryRes += " SA2.D_E_L_E_T_ = ' ' "

	If !Empty(cQryRes)

		If Select(cAlsRes) > 0; (cAlsRes)->(dbCloseArea()); Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryRes),cAlsRes,.T.,.T.)

		If !(cAlsRes)->(Eof()) 

			nQtdReg		:= Contar(cAlsRes,"!Eof()")
			nQtdPag		:= (nQtdReg/nPags)
			cPagsAux	:= cValToChar(nQtdPag)

			If SUBSTR(cPagsAux,1,1) == "0"
				nQtdPag := 1    			
			ElseIf At(".",cPagsAux) <> 0 
				nQtdPag := Val(SUBSTR(cPagsAux,1,( At(".",cPagsAux)-1 )))
				nQtdPag++
			Else
				nQtdPag := Val(cPagsAux)
			EndIf		

			//Cria serviço no montitor
			aCriaServ := U_MonitRes("000004", 1, nQtdReg)   
			cIdPZB 	  := aCriaServ[2]

			cJson := '{'
			cJson += '"NumeroPaginas":"'+ cValToChar(nQtdPag) +'",'

			If nPage == nQtdPag
				cJson += '"IsLastPage":true,
			Else
				cJson += '"IsLastPage":false,
			EndIf

			cJson += '"fornecedores":['

			(cAlsRes)->(DbGoTop())

			If Empty(cCgcForn) .And. Empty(cCodFor)

				nDE := ((nPage*nPags) - nPags)

				For nY := 0 To nDE
					(cAlsRes)->(DBSkip())
				Next nY

			EndIf

		Else

			cJson += "{"
			cJson += '"fornecedores":['
			cJson += "{" 
			cJson += '"errorMessage' + cValTochar(1) + '":"Nao existem registros.",'
			cJson += '"lret' + cValTochar(1) + '":false'
			cJson += "}

			::SetContentType("application/json")
			::SetResponse( cJson )

			Return(.T.)

		EndIf

		While !(cAlsRes)->(Eof())

			cJson += "{"

			For nX := 1 to Len(aCpos)

				If nX < Len(aCpos)
					cConteudo := & ("(cAlsRes)->" + aCpos[nX])

					If ValType( cConteudo) == "N"
						cJson += '"' + aCposCab[nX] + '":'
						cJson += cValTochar(cConteudo)
					Else
						cConteudo   := Alltrim(cConteudo)
						cJson       += '"' + aCposCab[nX] + '":'
						cJson       += '"' + cConteudo + '"'
					EndIf

					cJson += ','
				Else
					cConteudo   := & ("(cAlsRes)->" + aCpos[nX])

					If ValType( cConteudo) == "N"
						cJson += '"' + aCposCab[nX] + '":'
						cJson += cValTochar(cConteudo)
					Else
						cConteudo   := Alltrim(cConteudo)
						cJson       += '"' + aCposCab[nX] + '":'
						cJson       += '"' + cConteudo + '"'
					EndIf

				EndIf

			Next nX

			cJson += ','
			cJson += '"lret' + cValTochar(nLine) + '":true'
			cJson += "},"

			cMenssagem  := "Get realizado com sucesso."
			U_MonitRes("000004", 2, , cIdPZB, cMenssagem, .T., "Get de Fornecedores", cJson, "", "", .F., .F.)

			nLine++

			(cAlsRes)->(DbSkip())

			If !Empty(cCgcForn) .Or. !Empty(cCodFor) 

				If (cAlsRes)->(Eof())
					cJson := Left(cJson, Rat(",", cJson)-1)
					Exit
				EndIf

			Else

				If nLine == (nPags + 1) .Or. (cAlsRes)->(Eof())
					cJson := Left(cJson, Rat(",", cJson)-1)
					Exit
				EndIf

			EndIf

		End

		(cAlsRes)->(dbCloseArea())

		//Finaliza o processo na PZB
		U_MonitRes("000004", 3, , cIdPZB, , .T.)

	EndIf

cJson += "]}"

cJson	:= StrTran(cJson,chr(9),'')

(cAlsQry)->(dbCloseArea())

::SetContentType("application/json")
::SetResponse( cJson )

Return(.T.)

WsRestFul GetTPrec Description "Metodo Responsavel por Retornar Tabela de Preços"

WsData cTPrec		As String Optional
WsData cProd        AS String Optional
WsData cCgcEmp      As String Optional
WsData cEst			As String Optional

WsData nPage        As Integer Optional

WsMethod Get Description "Tabela de Preços" WsSyntax "/GetTPrec"

End WsRestFul

WsMethod Get WsReceive cTPrec, cProd, cEst, cCgcEmp, nPage WsService GetTPrec

	Local cQuery    := ""    
	Local cIdPZB	:= ""
	Local aCpos     := {}
	Local aCposCab  := {}
	Local cJson     := ""
	Local cQryRes   := ""
	Local nCount    := 1
	Local nX
	Local nPosEmp	:= 0
	Local cConteudo := ""
	Local aCriaServ := {}
	Local aEmpresas := FwLoadSM0()
	Local nLine     := 1
	Local cTPrec    := IIf(::cTPrec <> Nil  , ::cTPrec  , "")
	Local cProd  	:= IIf(::cProd <> Nil , ::cProd , "")
	Local cEst		:= IIf(::cEst <> Nil , ::cEst , "")
	Local cCgcEmp   := IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")

	Private cAlsQry   := CriaTrab(Nil,.F.)
	Private cAlsRes   := CriaTrab(Nil,.F.)	

	nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == cCgcEmp })

	If nPosEmp == 0
		cJson := '{"Erro":"Empresa nao cadastrada."}'
		::SetResponse( cJson )
		Return .T.
	Else
		RpcClearEnv()
		RpcSetEnv(aEmpresas[nPosEmp][1],aEmpresas[nPosEmp][2])
	EndIf

	cQuery := " SELECT PR2.* FROM " + RetSqlName("PR2") + " (NOLOCK) PR2 "
	cQuery += " INNER JOIN " + RetSqlName("PR1") + " (NOLOCK) PR1 "
	cQuery += " ON PR2_FILIAL = PR1_FILIAL AND PR2_CODIGO = PR1_CODIGO "
	cQuery += " WHERE PR1_CODPZA = '000005' AND PR1.D_E_L_E_T_ = ' '  AND PR2.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	While !(cAlsQry)->(Eof())

		If nCount == 1
			cQryRes := " SELECT  "
			cQryRes += (cAlsQry)->PR2_CPODES 

		Else
			cQryRes += " , " + (cAlsQry)->PR2_CPODES  

		EndIf

		AADD(aCpos, Alltrim((cAlsQry)->PR2_CPODES) )
		AADD(aCposCab, Alltrim((cAlsQry)->PR2_CPOORI))

		nCount++
		(cAlsQry)->(DbSkip())

	End

	cQryRes += " FROM " + RetSqlName("DA1") + " (NOLOCK) DA1 "
	cQryRes += " WHERE "

	If !Empty(cTPrec)
		cQryRes += " DA1_CODTAB = '" + AllTrim(cTPrec) + "' AND "
	EndIf

	If !Empty(cProd)
		cQryRes += " DA1_CODPRO = '" + AllTrim(cProd) + "' AND "
	EndIf

	If !Empty(cEst)
		cQryRes += " DA1_ESTADO = '" + AllTrim(cEst) + "' AND "
	EndIf

	cQryRes += " DA1_ATIVO  = '1' AND "
	cQryRes += " DA1.D_E_L_E_T_ = ' ' "

	If !Empty(cQryRes)

		If Select(cAlsRes) > 0; (cAlsRes)->(dbCloseArea()); Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryRes),cAlsRes,.T.,.T.)

		While !(cAlsRes)->(Eof())

			If nLine == 1

				nQtdReg := Contar(cAlsRes,"!Eof()")
				(cAlsRes)->(DbGoTop())

				//Cria serviço no montitor
				aCriaServ := U_MonitRes("000005", 1, nQtdReg)   
				cIdPZB 	  := aCriaServ[2]

				cJson := '{"tabela_precos":['

			EndIf

			cJson += "{"

			For nX := 1 to Len(aCpos)

				If nX < Len(aCpos)
					cConteudo := & ("(cAlsRes)->" + aCpos[nX])

					If ValType( cConteudo) == "N"
						cJson +=  '"' + aCposCab[nX] + '":'
						cJson += cValTochar(cConteudo)
					Else
						cConteudo   := Alltrim(cConteudo)
						cJson       += '"' + aCposCab[nX] + '":'
						cJson       += '"' + cConteudo + '"'
					EndIf

					cJson += ','
				Else
					cConteudo   := & ("(cAlsRes)->" + aCpos[nX])

					If ValType( cConteudo) == "N"
						cJson +=  '"' + aCposCab[nX] + '":'
						cJson += cValTochar(cConteudo)
					Else
						cConteudo   := Alltrim(cConteudo)
						cJson       += '"' + aCposCab[nX] + '":'
						cJson       += '"' + cConteudo + '"'
					EndIf

				EndIf

			Next nX

			cJson += ','
			cJson += '"lret' + cValTochar(nLine) + '":true'
			cJson += "},"

			cMenssagem  := "Get realizado com sucesso."
			U_MonitRes("000005", 2, , cIdPZB, cMenssagem, .T., "Get de Tabela de Preços", cJson, "", "", .F., .F.)

			nLine++

			(cAlsRes)->(DbSkip())

			If nLine == 10 .Or. (cAlsRes)->(Eof())
				cJson := Left(cJson, Rat(",", cJson)-1)
				Exit
			EndIf

		End

		(cAlsRes)->(dbCloseArea())

		If Empty(cJson) 

			cJson += "{"
			cJson += '"tabela_precos":['
			cJson += "{" 
			cJson += '"errorMessage' + cValTochar(1) + '":"'+ "tabela nao encontrada" +'",'
			cJson += '"lret' + cValTochar(1) + '":false'
			cJson += "}"

		EndIf

		//Finaliza o processo na PZB
		U_MonitRes("000005", 3, , cIdPZB, , .T.)

	EndIf

cJson += "]}"

(cAlsQry)->(dbCloseArea())

::SetContentType("application/json")
::SetResponse( cJson )

Return(.T.)

WsRestFul PostProd Description "Metodo Responsavel por Cadastrar e Alterar Produto"

WsData cCgcEmp		As String
WsData nOPC			As Integer 

WsMethod Post Description "Cadastro de Produto" WsSyntax "/PostProd"

End WsRestFul

WsMethod Post WsReceive cCgcEmp, nOPC WsService PostProd

	Local cBody     := ::GetContent()
	Local oJsoAux   := Nil
	Local cQuery    := ""
	Local cAlsQry   := CriaTrab(Nil,.F.)
	Local nX
	Local cStrErro  := ""
	Local aDados    := {}
	Local aCriaServ := {}
	Local nErro     := 0
	Local cJson     := ""
	Local cCgcEmp   := IIf(::cCgcEmp <> Nil  , ::cCgcEmp  , "")
	Local nOPC		:= IIf(::nOPC <> Nil  , ::nOPC  , 0)
	Local cNOper	:= IIF(nOPC = 3,"Incluso","Alterado")
	Local aEmpresas := FwLoadSM0()

	/**************************************************
	* força a gravação das informações de erro em 	*
	* array para manipulação da gravação ao invés 	*
	* de gravar direto no arquivo temporário		*
	**************************************************/
	Private lMsHelpAuto	:= .T.

	/**************************************************
	* força a gravação das informações de erro em 	*
	* array para manipulação da gravação ao invés 	*
	* de gravar direto no arquivo temporário 		*
	**************************************************/
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto := .F.

	nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == cCgcEmp })

	If nPosEmp == 0
		cJson := '{"Erro":"Empresa nao cadastrada."}'
		::SetResponse( cJson )
	Else
		cEmpAnt := aEmpresas[nPosEmp][1]
		cFilAnt := aEmpresas[nPosEmp][2]
	EndIf

	FWJsonDeserialize(cBody, @oJsoAux)

	SM0->(DbSetOrder(1))

	cQuery := " SELECT PR2.* FROM " + RetSqlName("PR2") + " (NOLOCK) PR2 "
	cQuery += " INNER JOIN " + RetSqlName("PR1") + " (NOLOCK) PR1 "
	cQuery += " ON PR2_FILIAL = PR1_FILIAL AND PR2_CODIGO = PR1_CODIGO "
	cQuery += " WHERE PR1_CODPZA = '000006' AND PR1.D_E_L_E_T_ = ' '  AND PR2.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	If len(oJsoAux:Produtos) > 0

		cJson := "{"

		//Cria serviço no montitor
		aCriaServ := U_MonitRes("000006", 1, Len(oJsoAux:Produtos) )   
		cIdPZB 	  := aCriaServ[2]

		For nX := 1 to len(oJsoAux:Produtos)

			(cAlsQry)->(DbGoTop())

			aDados      := {}

			While !(cAlsQry)->(Eof())

				cCpo        := Alltrim((cAlsQry)->PR2_CPOORI)

				If (cAlsQry)->PR2_TPCONT == "1"
					cConteudo := &("oJsoAux:Produtos[" + cValTochar(nX) + "]:" +cCpo)
				Else
					cConteudo := &((cAlsQry)->PR2_CONTEU)
				EndIf

				aAdd(aDados, {Alltrim((cAlsQry)->PR2_CPODES), cConteudo, nil})

				(cAlsQry)->(DbSkip())

			End

			aDados := FWVetByDic(aDados,"SB1",.F.) //Organiza o array
			MSExecAuto({|x,y| Mata010(x,y)},aDados,nOPC)

			::SetContentType("application/json")

			cMenssagem  := "Post Produtos"

			If lMsErroAuto

				cStrErro := ""

				aErros 	:= GetAutoGRLog() // retorna o erro encontrado no execauto.
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

				U_MonitRes("000006", 2, , cIdPZB, cMenssagem, .F., cStrErro, "", cBody, "", .F., .F.)

				//Finaliza o processo na PZB
				U_MonitRes("000006", 3, , cIdPZB, , .F.)

				cJson += '"produto":['
				cJson += "{" 
				cJson += '"errorMessage' + cValTochar(nX) + '":"' + cStrErro + '",'
				cJson += '"lret' + cValTochar(nX) + '":false,'
				cJson += "},"

			Else

				U_MonitRes("000006", 2, , cIdPZB, cMenssagem, .T., "Produto " + cNOper + " com sucesso", "", cBody, "", .F., .F.)

				//Finaliza o processo na PZB
				U_MonitRes("000006", 3, , cIdPZB, , .T.)

				cJson += '"produto":['
				cJson += "{" 
				cJson += '"lret' + cValTochar(nX) + '":true,'
				cJson += "},"

			EndIf

		Next nX

		cJson := Left(cJson, Rat(",", cJson)-1)
		cJson += "]}"

		::SetResponse( cJson )

	EndIf

(cAlsQry)->(dbCloseArea())

Return(.T.)

/*
WsRestFul PostTPrec Description "Metodo Responsavel por Cadastrar e Alterar Tabela de Preço"

WsData cCgcEmp		As String
WsData nOPC			As String

WsMethod Post Description "Cadastro Tabela de Preco" WsSyntax "/PostTPrec"

End WsRestFul

WsMethod Post WsReceive cCgcEmp, nOPC WsService PostTPrec

Local cBody     := ::GetContent()
Local oJsoAux   := Nil
Local cQuery    := ""
Local cAlsQry   := CriaTrab(Nil,.F.)
Local nX
Local nY
Local cStrErro  := ""
Local aCab	    := {}
Local aItens    := {}
Local aCriaServ := {}
Local nErro     := 0
Local cJson     := ""
Local cCgcEmp   := IIf(::cCgcEmp <> Nil  , ::cCgcEmp  , "")
Local nOPC		:= IIf(::nOPC <> Nil  , ::nOPC  , "")
Local cNOper	:= IIF(nOPC == '3',"Incluso","Alterado")
Local aEmpresas := FwLoadSM0()

/**************************************************
* força a gravação das informações de erro em 	*
* array para manipulação da gravação ao invés 	*
* de gravar direto no arquivo temporário		*
**************************************************/
//Private lMsHelpAuto	:= .T.

/**************************************************
* força a gravação das informações de erro em 	*
* array para manipulação da gravação ao invés 	*
* de gravar direto no arquivo temporário 		*
**************************************************/
/*
Private lAutoErrNoFile := .T.
Private lMsErroAuto := .F.

nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == cCgcEmp })

If nPosEmp == 0
cJson := '{"Erro":"Empresa nao cadastrada."}'
::SetResponse( cJson )
Else
cEmpAnt := aEmpresas[nPosEmp][1]
cFilAnt := aEmpresas[nPosEmp][2]
EndIf

FWJsonDeserialize(cBody, @oJsoAux)

SM0->(DbSetOrder(1))

cQuery := " SELECT PR2.* FROM " + RetSqlName("PR2") + " PR2 "
cQuery += " INNER JOIN " + RetSqlName("PR1") + " PR1 "
cQuery += " ON PR2_FILIAL = PR1_FILIAL AND PR2_CODIGO = PR1_CODIGO "
cQuery += " WHERE PR1_CODPZA = '000007' AND PR1.D_E_L_E_T_ = ' '  AND PR2.D_E_L_E_T_ = ' ' "

If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

If len(oJsoAux:Tabela) > 0

cJson := "{"

//Cria serviço no montitor
aCriaServ := U_MonitRes("000007", 1, Len(oJsoAux:Tabela) )   
cIdPZB 	  := aCriaServ[2]

For nX := 1 to len(oJsoAux:Tabela:Cabecalho)

(cAlsQry)->(DbGoTop())

aCab      := {}

While !(cAlsQry)->(Eof())

cCpo        := Alltrim((cAlsQry)->PR2_CPOORI)

If (cAlsQry)->PR2_TPCONT == "1"
cConteudo := &("oJsoAux:Tabela:Cabecalho[" + cValTochar(nX) + "]:" +cCpo)
Else
cConteudo := &((cAlsQry)->PR2_CONTEU)
EndIf

aAdd(aCab, {Alltrim((cAlsQry)->PR2_CPODES), cConteudo, nil})

(cAlsQry)->(DbSkip())

End

(cAlsQry)->(DBGOTOP())
aItens := []

For nY := 1 To Len(oJsoAux:Tabela:Cabecalho:Itens)

While !(cAlsQry)->(Eof())

cCpo        := Alltrim((cAlsQry)->PR2_CPOORI)

If (cAlsQry)->PR2_TPCONT == "1"
cConteudo := &("oJsoAux:Tabela:Cabecalho:Itens[" + cValTochar(nX) + "]:" +cCpo)
Else
cConteudo := &((cAlsQry)->PR2_CONTEU)
EndIf

aAdd(aItens, {Alltrim((cAlsQry)->PR2_CPODES), cConteudo, nil})

(cAlsQry)->(DbSkip())

End

Next nY

aCab := FWVetByDic(aCab,"DA0",.F.) //Organiza o array
aItens := FWVetByDic(aItens,"DA1",.F.) //Organiza o array
MSExecAuto({|X,Y,Z| OMSA010(X,Y,Z)},aCab,aItens,nOPC)

::SetContentType("application/json")

cMenssagem  := "Post Tabela de Preco"

If lMsErroAuto

cStrErro := ""

aErros 	:= GetAutoGRLog() // retorna o erro encontrado no execauto.
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

U_MonitRes("000007", 2, , cIdPZB, cMenssagem, .F., cStrErro, "", cBody, "", .F., .F.)

//Finaliza o processo na PZB
U_MonitRes("000007", 3, , cIdPZB, , .F.)

cJson += '"tab_preco ' + cValTochar(nX) + '":"' + cStrErro + '",'

Else

ConfirmSx8()

U_MonitRes("000007", 2, , cIdPZB, cMenssagem, .T., "Tabela de Preco " + cNOper + " com sucesso", "", cBody, "", .F., .F.)

//Finaliza o processo na PZB
U_MonitRes("000007", 3, , cIdPZB, , .T.)

cJson += '" tab_preco ' + cValTochar(nX) + '":" ' + cNOper + ' com sucesso.",'

EndIf

Next nX

cJson := Left(cJson, Rat(",", cJson)-1)
cJson += "}"

::SetResponse( cJson )

EndIf

(cAlsQry)->(dbCloseArea())

Return(.T.)
*/

WsRestFul GetPed Description "Metodo Responsavel por Pedidos de Venda"

WsData dDataAte		As Date Optional
WsData dDataDe		As Date Optional 
WsData cTipo	    As String Optional
WsData cCgcCli      As String Optional
WsData cCgcEmp      As String Optional
WsData cCodPed      As String Optional
WsData nPage        As Float Optional
WsData nTpConsu		As Float Optional

WsMethod Get Description "Pedidos de Venda" WsSyntax "/GetPed"

End WsRestFul

WsMethod Get WsReceive cCgcEmp, cCgcCli, cTipo, dDataDe, dDataAte, nPage, nTpConsu WsService GetPed

	Local cCli		:= ""
	Local cLoja		:= ""
	Local cJson     := ""
	Local cQuery    := "" 
	Local cChave	:= ""  
	Local cIdPZB	:= "" 

	Local nX		:= 0
	Local nY		:= 0
	Local nDE		:= 0
	Local nPags		:= 0
	Local nLine     := 1
	Local nCount    := 1
	Local nPosEmp	:= 0
	Local nQtdPag	:= 0

	Local aCpos     := {}
	Local aCont     := {}
	Local cPagsAux	:= ""
	Local aCposCab  := {}
	Local cConteudo := ""
	Local aCriaServ := {}
	Local aEmpresas := FwLoadSM0()

	Local dDataAte	:= IIf(::dDataAte <> Nil , ::dDataAte , "")
	Local dDataDe	:= IIf(::dDataDe <> Nil , ::dDataDe , "")
	Local cTipo		:= IIf(::cTipo <> Nil , ::cTipo , "")
	Local cCgcCli	:= IIf(::cCgcCli <> Nil , ::cCgcCli , "")
	Local cCgcEmp   := IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")
	Local cCodPed   := IIf(::cCodPed <> Nil , ::cCodPed , "")
	Local nTpConsu	:= IIf(::nTpConsu <> Nil, ::nTpConsu, 0)
	Local nPage		:= IIf(::nPage <> Nil, ::nPage, 1)

	nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == cCgcEmp })

	Private cAlsQry   := CriaTrab(Nil,.F.)
	Private cAlsRes   := CriaTrab(Nil,.F.)
	Private cQryRes   := ""

	If nPosEmp == 0
		cJson := '{"Erro":"Empresa nao cadastrada."}'
		::SetResponse( cJson )
		Return .T.
	Else
		RpcClearEnv()
		RpcSetEnv(aEmpresas[nPosEmp][1],aEmpresas[nPosEmp][2])
	EndIf   

	If !Empty(cCgcCli)
		DBSelectArea("SA1")
		SA1->(DBSetOrder(3))	
		If SA1->(DBSeek(xFilial("SA1") + cCgcCli))
			cCli	:= SA1->A1_COD
			cLoja	:= SA1->A1_LOJA
		Else
			cJson := '{Cliente nao Encontrado.}'
			::SetResponse( cJson )
			Return .T.
		EndIf
	EndIf

	nPags	:= GetMV("FT_QTPAGIC",,30)

	cQuery 	:= " SELECT PR2.* FROM " + RetSqlName("PR2") + " (NOLOCK) PR2 "
	cQuery 	+= " INNER JOIN " + RetSqlName("PR1") + " (NOLOCK) PR1 "
	cQuery 	+= " ON PR2_FILIAL = PR1_FILIAL AND PR2_CODIGO = PR1_CODIGO "
	cQuery 	+= " WHERE PR1_CODPZA = '000007' AND PR1.D_E_L_E_T_ = ' '  AND PR2.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	While !(cAlsQry)->(Eof())

		If nCount == 1
			cQryRes := CRLF + " SELECT  C6_VALOR,"
			cQryRes += CRLF + (cAlsQry)->PR2_CPODES 

		Else
			cQryRes += CRLF + " , " + (cAlsQry)->PR2_CPODES  

		EndIf

		AADD(aCpos, Alltrim((cAlsQry)->PR2_CPODES) )
		AADD(aCposCab, Alltrim((cAlsQry)->PR2_CPOORI))

		If (cAlsQry)->PR2_ISFUNC == "S"
			AADD(aCont, Alltrim( (cAlsQry)->PR2_CONTEU ))
		Else
			AADD(aCont, "")
		EndIf

		nCount++
		(cAlsQry)->(DbSkip())

	End

	If !Empty(cQryRes)

		cQryRes += CRLF + " ,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(CAST(CAST(C5_XOBS AS VARBINARY(8000)) AS VARCHAR(8000)),''),CHAR(13), ' '),CHAR(10),''),CHAR(9),''), '  ',' '),'\','/'),'" + '"'+ "','') AS OBS"
		cQryRes += CRLF + " FROM " + RetSqlName("SC5") + " (NOLOCK) SC5 "
		cQryRes += CRLF + " INNER JOIN " + RetSqlName("SC6") + " (NOLOCK) SC6 "
		cQryRes += CRLF + " ON C6_FILIAL = C5_FILIAL "  
		cQryRes += CRLF + " AND C6_NUM = C5_NUM  "
		cQryRes += CRLF + " AND C6_CLI = C5_CLIENTE "
		cQryRes += CRLF + " AND C6_LOJA = C5_LOJACLI "
		cQryRes += CRLF + " INNER JOIN " +  RetSqlName("SF4") + " (NOLOCK) SF4 "
		cQryRes += CRLF + " ON F4_CODIGO = C6_TES "
		cQryRes += CRLF + " WHERE "

		//Numero do pedido
		If !Empty(cCodPed)
			cQryRes += CRLF + " C5_NUM = '" + cCodPed + "' AND "
		EndIf

		//CLIENTE
		If !Empty(cCgcCli)
			cQryRes += CRLF + " C5_CLIENTE = '" + cCli + "' AND "
			cQryRes += CRLF + " C5_LOJACLI = '" + cLoja + "' AND "
		EndIf

		//DATA
		If !Empty(dDataDe)
			cQryRes += CRLF + " C5_EMISSAO >= '" + DtoS(dDataDe) + "' AND "
		EndIf

		If !Empty(dDataAte)
			cQryRes += CRLF + " C5_EMISSAO <= '" + DtoS(dDataAte) + "' AND "
		EndIf

		If nTpConsu <> 1

			cQryRes += CRLF + " C5_XENVWMS <> '99' AND " 
			cQryRes += CRLF + " C5_APRNV1  IN ('2','4') AND "
			cQryRes += CRLF + " C5_APRNV2  IN ('2','4') AND "
			cQryRes += CRLF + " C5_APRNV3  IN ('2','4') AND "
			cQryRes += CRLF + " C5_NOTA = '' AND "
			cQryRes += CRLF + " F4_ESTOQUE = 'S' AND " 

		EndIf

		If !Empty(cTipo)
			cQryRes	+= CRLF + " C5_TIPO = '" + cTipo + "' AND "
		ENDIF

		cQryRes += CRLF + " C5_LIBEROK <> '' AND "
		cQryRes += CRLF + " C5_FILIAL = '" + xFilial("SC5") + "' AND "
		cQryRes += CRLF + " C5_BLQ	    = '' AND "
		cQryRes += CRLF + " C5_PEDMAN  IN ('2','4','') AND "
		cQryRes += CRLF + " SC5.D_E_L_E_T_ = ' ' AND "
		cQryRes += CRLF + " SC6.D_E_L_E_T_ = ' ' AND "
		cQryRes += CRLF + " SF4.D_E_L_E_T_ = ' ' "
		cQryRes += CRLF + " ORDER BY C5_NUM, C5_CLIENTE, C5_LOJACLI, C6_ITEM"

		If Select(cAlsRes) > 0; (cAlsRes)->(dbCloseArea()); Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryRes),cAlsRes,.T.,.T.)

		nQtdReg		:= Contar(cAlsRes,"!Eof()")
		nQtdPag		:= (nQtdReg/nPags)
		cPagsAux	:= cValToChar(nQtdPag)

		If SUBSTR(cPagsAux,1,1) == "0"
			nQtdPag := 1    			
		ElseIf At(".",cPagsAux) <> 0 
			nQtdPag := Val(SUBSTR(cPagsAux,1,( At(".",cPagsAux)-1 )))
			nQtdPag++
		Else
			nQtdPag := Val(cPagsAux)
		EndIf		

		If Empty(cCgcCli)

			(cAlsRes)->(DbGoTop())

			nDE := ((nPage*nPags) - nPags)

			cDocFor := (cAlsRes)->(C5_NUM)

			If nDE > 0 .Or. (nDE == 0 .And. nPage > 1)

				For nY := 1 To nDE
					If  (cAlsRes)->( ! eof())
						If nY > 1
							If cDocFor == (cAlsRes)->(C5_NUM)
								ny := nY - 1
							Else
								cDocFor := (cAlsRes)->(C5_NUM)
							Endif

						Endif 

						(cAlsRes)->(DBSkip())
					Else
						Exit 
					Endif 

				Next nY
			Endif

		Else
			(cAlsRes)->(DbGoTop())
		EndIf

		While !(cAlsRes)->(Eof()) 

			If nLine == 1

				//Cria serviço no montitor
				aCriaServ := U_MonitRes("000007", 1, nQtdReg)   
				cIdPZB 	  := aCriaServ[2]

				cJson := '{"pedidos":['

			EndIf

			cJson += "{"

			For nX := 1 to Len(aCpos)

				If SUBSTR(aCpos[nX],1,2) == "C5"   

					If Empty(aCont[nX])    

						cConteudo := & ("(cAlsRes)->" + aCpos[nX])

						If ValType( cConteudo) == "N"
							cJson += '"' + aCposCab[nX] + '":'
							cJson += cValTochar(cConteudo)
						Else
							cConteudo   := Alltrim(cConteudo)
							cJson       += '"' + aCposCab[nX] + '":'
							cJson       += '"' + cConteudo + '"'
						EndIf

						cJson += ','

					Else

						dbselectarea(cAlsRes)

						cConteudo := &(aCont[nX])

						If ValType( cConteudo) == "N"
							cJson += '"' + aCposCab[nX] + '":'
							cJson += cValTochar(cConteudo)
						Else
							cConteudo   := Alltrim(cConteudo)
							cJson       += '"' + aCposCab[nX] + '":'
							cJson       += '"' + cConteudo + '"'
						EndIf

						cJson += ','

					EndIf

				Endif

			Next nX

			cJson += '"NumeroPaginas":"'+ cValToChar(nQtdPag) +'",'
			cJson += '"ObsPed":"' + StrTran(Alltrim((cAlsRes)->OBS),Chr(13) + Chr(10), ' ' )  + '",'

			If nPage == nQtdPag
				cJson += '"IsLastPage":true,
			Else
				cJson += '"IsLastPage":false,
			EndIf

			cJson += '"lret' + cValTochar(nLine) + '":true,'

			cChave := (cAlsRes)->C5_NUM
			cChave += (cAlsRes)->C5_CLIENTE
			cChave += (cAlsRes)->C5_LOJACLI

			cTotPed := 0

			cJson += '"itens":['

			While cChave == ((cAlsRes)->C5_NUM + (cAlsRes)->C5_CLIENTE + (cAlsRes)->C5_LOJACLI)   
				cJson += "{" 
				For nY := 1 to Len(aCpos)

					If SUBSTR(aCpos[nY],1,2) == "C6"

						dbselectarea(cAlsRes)

						If nY < Len(aCpos)

							If Empty(aCont[nY])   

								cConteudo := & ("(cAlsRes)->" + aCpos[nY])

							Else

								cConteudo := &(aCont[nY])

							Endif

							If ValType( cConteudo) == "N"
								cJson += '"' + aCposCab[nY] + '":'
								cJson += cValTochar(cConteudo)
							Else
								cConteudo   := Alltrim(cConteudo)
								cJson       += '"' + aCposCab[nY] + '":'
								cJson       += '"' + cConteudo + '"'
							EndIf

							cJson += ','

						Else

							If Empty(aCont[nY])   
								cConteudo := & ("(cAlsRes)->" + aCpos[nY])
							Else
								cConteudo := &(aCont[nY])
							Endif

							If ValType( cConteudo) == "N"
								cJson += '"' + aCposCab[nY] + '":'
								cJson += cValTochar(cConteudo)
							Else
								cConteudo   := Alltrim(cConteudo)
								cJson       += '"' + aCposCab[nY] + '":'
								cJson       += '"' + cConteudo + '"'
							EndIf

						EndIf
					EndIf   
				Next nY

				cTotPed += (cAlsRes)->C6_VALOR

				cJson := Left(cJson, Rat(",", cJson)-1)
				cJson += "},"

				(cAlsRes)->(DbSkip())
				If cChave <> ((cAlsRes)->C5_NUM + (cAlsRes)->C5_CLIENTE + (cAlsRes)->C5_LOJACLI)  
					cJson := Left(cJson, Rat(",", cJson)-1)
				Endif  

			EndDo        
			// cJson := Left(cJson, Rat(",", cJson)-1)
			cJson += "],"
			cJson += '"TotalPed":' + CVALTOCHAR( cTotPed ) + ''
			cJson += "},"



			cMenssagem  := "Get realizado com sucesso."
			U_MonitRes("000007", 2, , cIdPZB, cMenssagem, .T., "Get de Pedidos", "", "", "", .F., .F.)

			nLine++

			If nPage = 0 .OR. !Empty(cCgcCli) 
				If (cAlsRes)->(Eof())
					cJson := Left(cJson, Rat(",", cJson)-1)
					Exit
				EndIf
			Else
				If nLine == (nPags + 1) .Or. (cAlsRes)->(Eof())
					cJson := Left(cJson, Rat(",", cJson)-1)
					Exit
				EndIf
			EndIf
		End

		(cAlsRes)->(dbCloseArea())

		If Empty(cJson) 

			cJson += "{"
			cJson += '"pedidos":['
			cJson += "{" 
			cJson += '"errorMessage' + cValTochar(1) + '":"'+ "pedidos nao encontrado" +'",'
			cJson += '"lret' + cValTochar(1) + '":false'
			cJson += "}"

		EndIf

		//Finaliza o processo na PZB
		U_MonitRes("000007", 3, , cIdPZB, , .T.)

	EndIf

cJson += "]}"

cJson	:= StrTran(cJson,chr(9),'')

(cAlsQry)->(dbCloseArea())

::SetContentType("application/json")
::SetResponse( cJson )

Return(.T.)


WsRestFul PostForn Description "Metodo Responsavel por Cadastrar Fornecedor"

WsData cCgcEmp		As String
WsData nOPC			As Integer

WsMethod Post Description "Cadastro de Forncedor" WsSyntax "/PostForn"

End WsRestFul

WsMethod Post WsReceive cCgcEmp, nOPC WsService PostForn

	Local cBody     := ::GetContent()
	Local oJsoAux   := Nil
	Local cQuery    := ""
	Local cAlsQry   := CriaTrab(Nil,.F.)
	Local nX
	Local cStrErro  := ""
	Local aDados    := {}
	Local aCriaServ := {}
	Local nErro     := 0
	Local cJson     := ""
	Local cCgcEmp   := IIf(::cCgcEmp <> Nil  , ::cCgcEmp  , "")
	Local nOPC		:= IIf(::nOPC <> Nil  , ::nOPC  , 0)
	Local cNOper	:= IIF(nOPC = 3,"Incluso","Alterado")
	Local aEmpresas := FwLoadSM0()

	/**************************************************
	* força a gravação das informações de erro em 	*
	* array para manipulação da gravação ao invés 	*
	* de gravar direto no arquivo temporário		*
	**************************************************/
	Private lMsHelpAuto	:= .T.

	/**************************************************
	* força a gravação das informações de erro em 	*
	* array para manipulação da gravação ao invés 	*
	* de gravar direto no arquivo temporário 		*
	**************************************************/
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto := .F.

	nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == cCgcEmp })

	If nPosEmp == 0
		cJson := '{"Erro":"Empresa nao cadastrada."}'
		::SetResponse( cJson )
	Else
		cEmpAnt := aEmpresas[nPosEmp][1]
		cFilAnt := aEmpresas[nPosEmp][2]
	EndIf

	FWJsonDeserialize(cBody, @oJsoAux)

	SM0->(DbSetOrder(1))

	cQuery := " SELECT PR2.* FROM " + RetSqlName("PR2") + " (NOLOCK) PR2 "
	cQuery += " INNER JOIN " + RetSqlName("PR1") + " (NOLOCK) PR1 "
	cQuery += " ON PR2_FILIAL = PR1_FILIAL AND PR2_CODIGO = PR1_CODIGO "
	cQuery += " WHERE PR1_CODPZA = '000008' AND PR1.D_E_L_E_T_ = ' '  AND PR2.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	If len(oJsoAux:Fornecedores) > 0

		cJson := "{"

		//Cria serviço no montitor
		aCriaServ := U_MonitRes("000008", 1, Len(oJsoAux:Fornecedores) )   
		cIdPZB 	  := aCriaServ[2]

		For nX := 1 to len(oJsoAux:Fornecedores)

			(cAlsQry)->(DbGoTop())

			aDados      := {}

			aAdd(aDados, {"A2_COD"  , GetSXeNum("SA2","A2_COD","A2_COD")    , nil})
			aAdd(aDados, {"A2_LOJA" , "01"                                  , nil})


			While !(cAlsQry)->(Eof())

				cCpo        := Alltrim((cAlsQry)->PR2_CPOORI)

				If (cAlsQry)->PR2_TPCONT == "1"
					cConteudo := &("oJsoAux:Fornecedores[" + cValTochar(nX) + "]:" +cCpo)
				Else
					cConteudo := &((cAlsQry)->PR2_CONTEU)
				EndIf

				aAdd(aDados, {Alltrim((cAlsQry)->PR2_CPODES), cConteudo, nil})

				(cAlsQry)->(DbSkip())

			End

			aDados := FWVetByDic(aDados,"SA2",.F.) //Organiza o array
			MSExecAuto({|x,y| Mata020(x,y)},aDados,nOPC)

			::SetContentType("application/json")

			cMenssagem  := "Post fornecedores"

			If lMsErroAuto

				cStrErro := ""

				aErros 	:= GetAutoGRLog() // retorna o erro encontrado no execauto.
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

				U_MonitRes("000008", 2, , cIdPZB, cMenssagem, .F., cStrErro, "", cBody, "", .F., .F.)

				//Finaliza o processo na PZB
				U_MonitRes("000008", 3, , cIdPZB, , .F.)

				cJson += '"fornecedor":['
				cJson += "{" 
				cJson += '"errorMessage' + cValTochar(nX) + '":"' + cStrErro + '",'
				cJson += '"lret' + cValTochar(nX) + '":false,'
				cJson += "},"

			Else

				ConfirmSx8()

				U_MonitRes("000008", 2, , cIdPZB, cMenssagem, .T., "Forncedor " + cNOper + " com sucesso", "", cBody, "", .F., .F.)

				//Finaliza o processo na PZB
				U_MonitRes("000008", 3, , cIdPZB, , .T.)

				cJson += '"fornecedor":['
				cJson += "{" 
				cJson += '"lret' + cValTochar(nX) + '":true,'
				cJson += "},"

			EndIf

		Next nX

		cJson := Left(cJson, Rat(",", cJson)-1)
		cJson += "]}"

		::SetResponse( cJson )

	EndIf

(cAlsQry)->(dbCloseArea())

Return(.T.)

WsRestFul GetCancFat Description "Metodo Responsavel por Retornar Cancelamentos de faturamentos"

WsData cCgcCli		As String Optional
WsData cCgcEmp      As String Optional

WsData nPage        As float Optional

WsMethod Get Description "Cancelamentos de faturamentos" WsSyntax "/GetCancFat"

End WsRestFul

WsMethod Get WsReceive cCgcCli,  cCgcEmp, nPage WsService GetCancFat

	Local cJson     := ""
	Local cQuery    := ""   
	Local cIdPZB	:= "" 
	Local cQryRes   := ""

	Local nX		:= 0
	Local nY		:= 0
	Local nDE		:= 0
	Local nPags		:= 0
	Local nLine     := 1
	Local nCount    := 1
	Local nPosEmp	:= 0
	Local nQtdPag	:= 0

	Local aCpos     := {}
	Local cPagsAux	:= ""
	Local aCposCab  := {}
	Local cConteudo := ""
	Local aCriaServ := {}
	Local aEmpresas := FwLoadSM0()
	Local cCodCli   := ''

	Local cCgcCli   := IIf(::cCgcCli <> Nil , ::cCgcCli , "")
	Local cCgcEmp   := IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")
	Local nPage		:= IIf(::nPage <> Nil, ::nPage, 1)

	Private cAlsQry   := CriaTrab(Nil,.F.)
	Private cAlsRes   := CriaTrab(Nil,.F.)

	nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == cCgcEmp })

	If nPosEmp == 0
		cJson := '{"Erro":"Empresa nao cadastrada."}'
		::SetResponse( cJson )
		Return .T.
	Else
		RpcClearEnv()
		RpcSetEnv(aEmpresas[nPosEmp][1],aEmpresas[nPosEmp][2])
	EndIf   

	nPags	:= GetMV("FT_QTPAGIC",,10)

	cQuery 	:= " SELECT PR2.* FROM " + RetSqlName("PR2") + " (NOLOCK) PR2 "
	cQuery 	+= " INNER JOIN " + RetSqlName("PR1") + " (NOLOCK) PR1 "
	cQuery 	+= " ON PR2_FILIAL = PR1_FILIAL AND PR2_CODIGO = PR1_CODIGO "
	cQuery 	+= " WHERE PR1_CODPZA = '000009' AND PR1.D_E_L_E_T_ = ' '  AND PR2.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	cCodCli := F

	While !(cAlsQry)->(Eof())

		If nCount == 1
			cQryRes := " SELECT  "
			cQryRes += (cAlsQry)->PR2_CPODES 

		Else
			cQryRes += " , " + (cAlsQry)->PR2_CPODES  

		EndIf

		AADD(aCpos, Alltrim((cAlsQry)->PR2_CPODES) )
		AADD(aCposCab, Alltrim((cAlsQry)->PR2_CPOORI))

		nCount++
		(cAlsQry)->(DbSkip())

	End

	If !Empty(cQryRes)

		cQryRes += " FROM " + RetSqlName("SFT") + " (NOLOCK) SFT "
		cQryRes += " WHERE "

		//Tipo de cliente
		If !Empty(cCgcCli)
			cQryRes += " FT_CLIEFOR = '" + cCodCli + "' AND "
		EndIf

		cQryRes += " FT_DTCANC <> '' AND  "

		cQryRes += " SFT.D_E_L_E_T_ = ' ' "

		If Select(cAlsRes) > 0; (cAlsRes)->(dbCloseArea()); Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryRes),cAlsRes,.T.,.T.)

		nQtdReg		:= Contar(cAlsRes,"!Eof()")
		nQtdPag		:= (nQtdReg/nPags)
		cPagsAux	:= cValToChar(nQtdPag)

		If SUBSTR(cPagsAux,1,1) == "0"
			nQtdPag := 1    			
		ElseIf At(".",cPagsAux) <> 0 
			nQtdPag := Val(SUBSTR(cPagsAux,1,( At(".",cPagsAux)-1 )))
			nQtdPag++
		Else
			nQtdPag := Val(cPagsAux)
		EndIf		

		If Empty(cCgcCli)

			(cAlsRes)->(DbGoTop())

			nDE := ((nPage*nPags) - nPags)

			For nY := 0 To nDE
				(cAlsRes)->(DBSkip())
			Next nY

		Else
			(cAlsRes)->(DbGoTop())
		EndIf

		While !(cAlsRes)->(Eof()) 

			If nLine == 1

				//Cria serviço no montitor
				aCriaServ := U_MonitRes("000009", 1, nQtdReg)   
				cIdPZB 	  := aCriaServ[2]

				cJson := '{"CancelFat":['

			EndIf

			cJson += "{"

			For nX := 1 to Len(aCpos)

				If nX < Len(aCpos)
					cConteudo := & ("(cAlsRes)->" + aCpos[nX])

					If ValType( cConteudo) == "N"
						cJson += '"' + aCposCab[nX] + '":'
						cJson += cValTochar(cConteudo)
					Else
						cConteudo   := Alltrim(cConteudo)
						cJson       += '"' + aCposCab[nX] + '":'
						cJson       += '"' + cConteudo + '"'
					EndIf

					cJson += ','
				Else
					cConteudo   := & ("(cAlsRes)->" + aCpos[nX])

					If ValType( cConteudo) == "N"
						cJson += '"' + aCposCab[nX] + '":'
						cJson += cValTochar(cConteudo)
					Else
						cConteudo   := Alltrim(cConteudo)
						cJson       += '"' + aCposCab[nX] + '":'
						cJson       += '"' + cConteudo + '"'
					EndIf

				EndIf

			Next nX

			cJson += ','
			cJson += '"NumeroPaginas":"'+ cValToChar(nQtdPag) +'",'

			If nPage == nQtdPag
				cJson += '"IsLastPage":true,
			Else
				cJson += '"IsLastPage":false,
			EndIf

			cJson += '"lret' + cValTochar(nLine) + '":true'
			cJson += "},"

			cMenssagem  := "Get realizado com sucesso."
			U_MonitRes("000009", 2, , cIdPZB, cMenssagem, .T., "Get de Cancelamento de Faturamento", cJson, "", "", .F., .F.)

			nLine++

			(cAlsRes)->(DbSkip())

			If nPage = 0 .OR. !Empty(cCgcCli) 
				If (cAlsRes)->(Eof())
					cJson := Left(cJson, Rat(",", cJson)-1)
					Exit
				EndIf
			Else
				If nLine == (nPags + 1) .Or. (cAlsRes)->(Eof())
					cJson := Left(cJson, Rat(",", cJson)-1)
					Exit
				EndIf
			EndIf
		End

		(cAlsRes)->(dbCloseArea())

		If Empty(cJson) 

			cJson += "{"
			cJson += '"CancelFat":['
			cJson += "{" 
			cJson += '"errorMessage' + cValTochar(1) + '":"'+ " nao encontrado" +'",'
			cJson += '"lret' + cValTochar(1) + '":false'
			cJson += "},"

		EndIf

		//Finaliza o processo na PZB
		U_MonitRes("000009", 3, , cIdPZB, , .T.)

	EndIf

cJson += "]}"

(cAlsQry)->(dbCloseArea())

::SetContentType("application/json")
::SetResponse( cJson )

Return(.T.)


WsRestFul GetEnt Description "Metodo Responsavel por Doumento de Entrada"

WsData dDataAte		As Date Optional
WsData dDataDe		As Date Optional 
WsData cCgcForn     As String Optional
WsData cCgcEmp      As String Optional
WsData nPage        As Float Optional

WsMethod Get Description "Doumento de Entrada" WsSyntax "/GetEnt"

End WsRestFul

WsMethod Get WsReceive cCgcEmp, cCgcForn, dDataDe, dDataAte, nPage WsService GetEnt

	Local cForn		:= ""
	Local cLoja		:= ""
	Local cJson     := ""
	Local cQuery    := "" 
	Local cChave	:= ""  
	Local cIdPZB	:= "" 
	Local cQryRes   := ""

	Local nX		:= 0
	Local nY		:= 0
	Local nDE		:= 0
	Local nPags		:= 0
	Local nLine     := 1
	Local nCount    := 1
	Local nPosEmp	:= 0
	Local nQtdPag	:= 0

	Local aCpos     := {}
	Local aCont     := {}
	Local cPagsAux	:= ""
	Local aCposCab  := {}
	Local cConteudo := ""
	Local aCriaServ := {}
	Local aEmpresas := FwLoadSM0()
	Local aCposD1   := {}

	Local dDataAte	:= IIf(::dDataAte <> Nil , ::dDataAte , "")
	Local dDataDe	:= IIf(::dDataDe <> Nil , ::dDataDe , "")
	Local cCgcForn	:= IIf(::cCgcForn <> Nil , ::cCgcForn , "")
	Local cCgcEmp   := IIf(AllTrim(::cCgcEmp) <> Nil , AllTrim(::cCgcEmp) , "")
	Local nPage		:= IIf(::nPage <> Nil, ::nPage, 1)

	Private cAlsQry   := CriaTrab(Nil,.F.)
	Private cAlsRes   := CriaTrab(Nil,.F.)

	nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == cCgcEmp })

	If nPosEmp == 0
		cJson := '{"Erro":"Empresa nao cadastrada."}'
		::SetResponse( cJson )
		Return .T.
	Else
		RpcClearEnv()
		RpcSetEnv(aEmpresas[nPosEmp][1],aEmpresas[nPosEmp][2])
	EndIf   

	If !Empty(cCgcForn)
		DBSelectArea("SA2")
		SA2->(DBSetOrder(3))	
		If SA2->(DBSeek(xFilial("SA2") + cCgcForn))
			cForn	:= SA2->A2_COD
			cLoja	:= SA2->A2_LOJA
		Else
			cJson := '{"Erro":"Fornecedor nao Encontrado."}'
			::SetResponse( cJson )
			Return .T.
		EndIf
	EndIf

	nPags	:= GetMV("FT_QTPAGIC",,10)

	cQuery 	:= " SELECT PR2.* FROM " + RetSqlName("PR2") + " (NOLOCK) PR2 "
	cQuery 	+= " INNER JOIN " + RetSqlName("PR1") + " (NOLOCK) PR1 "
	cQuery 	+= " ON PR2_FILIAL = PR1_FILIAL AND PR2_CODIGO = PR1_CODIGO "
	cQuery 	+= " WHERE PR1_CODPZA = '000010' AND PR1.D_E_L_E_T_ = ' '  AND PR2.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	While !(cAlsQry)->(Eof())

		If nCount == 1
			cQryRes := " SELECT  "
			cQryRes += (cAlsQry)->PR2_CPODES 

		Else
			cQryRes += " , " + (cAlsQry)->PR2_CPODES  

		EndIf

		AADD(aCpos, Alltrim((cAlsQry)->PR2_CPODES) )
		AADD(aCposCab, Alltrim((cAlsQry)->PR2_CPOORI))

		If (cAlsQry)->PR2_ISFUNC == "S"
			AADD(aCont, Alltrim( (cAlsQry)->PR2_CONTEU ))
		Else
			AADD(aCont, "")
		EndIf

		nCount++
		(cAlsQry)->(DbSkip())

	End

	If !Empty(cQryRes)

		cQryRes += " FROM " + RetSqlName("SF1") + " (NOLOCK) SF1 "
		cQryRes += " INNER JOIN " + RetSqlName("SD1") + " (NOLOCK) SD1 "
		cQryRes += " ON D1_FILIAL = '" + xFilial("SD1") + "' "  
		cQryRes += " AND D1_DOC = F1_DOC "
		cQryRes += " AND D1_SERIE = F1_SERIE "
		cQryRes += " AND D1_FORNECE = F1_FORNECE "
		cQryRes += " AND D1_LOJA = F1_LOJA "
		cQryRes += " INNER JOIN " + RetSqlName("SB1") + " (NOLOCK) SB1 "
		cQryRes += " ON B1_FILIAL = '" + xFilial("SB1") + "' " 
		cQryRes += " AND D1_COD = B1_COD"
		cQryRes += " WHERE "

		//FORNECEDOR
		If !Empty(cCgcForn)
			cQryRes += " F1_FORNECE = '" + cForn + "' AND "
			cQryRes += " F1_LOJA = '" + cLoja + "' AND "
		EndIf


		//DATA
		If !Empty(dDataDe)
			cQryRes += " F1_EMISSAO >= '" + DtoS(dDataDe) + "' AND "
		EndIf

		If !Empty(dDataAte)
			cQryRes += " F1_EMISSAO <= '" + DtoS(dDataAte) + "' AND "
		EndIf

		cQryRes += " B1_TIPO = 'ME' AND "
		cQryRes += " F1_XENVWMS <> '99' AND "
		cQryRes += " SB1.D_E_L_E_T_ = ' ' AND "
		cQryRes += " SF1.D_E_L_E_T_ = ' ' AND "
		cQryRes += " SD1.D_E_L_E_T_ = ' ' "
		cQryRes += " ORDER BY F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, D1_ITEM"

		If Select(cAlsRes) > 0; (cAlsRes)->(dbCloseArea()); Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryRes),cAlsRes,.T.,.T.)

		nQtdReg		:= Contar(cAlsRes,"!Eof()")
		nQtdPag		:= (nQtdReg/nPags)
		cPagsAux	:= cValToChar(nQtdPag)

		If SUBSTR(cPagsAux,1,1) == "0"
			nQtdPag := 1    			
		ElseIf At(".",cPagsAux) <> 0 
			nQtdPag := Val(SUBSTR(cPagsAux,1,( At(".",cPagsAux)-1 )))
			nQtdPag++
		Else
			nQtdPag := Val(cPagsAux)
		EndIf		

		If Empty(cCgcForn)

			(cAlsRes)->(DbGoTop())

			nDE := ((nPage*nPags) - nPags)

			//ANTES: For nY := 0 To nDE
			//
			If nDE > 0 .Or. (nDE == 0 .And. nPage > 1)

				cDocFor := (cAlsRes)->(F1_DOC)


				For nY := 1 To nDE

					If  (cAlsRes)->( ! eof())
						If nY > 1
							If cDocFor == (cAlsRes)->(F1_DOC)
								ny := nY - 1
							Else
								cDocFor := (cAlsRes)->(F1_DOC)
							Endif

						Endif 

						(cAlsRes)->(DBSkip())
					Else
						Exit
					Endif

				Next nY
			Endif

		Else
			(cAlsRes)->(DbGoTop())
		EndIf

		While !(cAlsRes)->(Eof()) 

			If nLine == 1

				//Cria serviço no montitor
				aCriaServ := U_MonitRes("000010", 1, nQtdReg)   
				cIdPZB 	  := aCriaServ[2]

				cJson := '{"entradas":['

			EndIf

			cJson += "{"

			For nX := 1 to Len(aCpos)

				If SUBSTR(aCpos[nX],1,2) == "F1"    

					If Empty(aCont[nX])    

						cConteudo := & ("(cAlsRes)->" + aCpos[nX])

						If ValType( cConteudo) == "N"
							cJson += '"' + aCposCab[nX] + '":'
							cJson += cValTochar(cConteudo)
						Else
							cConteudo   := Alltrim(cConteudo)
							cJson       += '"' + aCposCab[nX] + '":'
							cJson       += '"' + cConteudo + '"'
						EndIf

						cJson += ','

					Else

						cConteudo := &(aCont[nX])

						If ValType( cConteudo) == "N"
							cJson += '"' + aCposCab[nX] + '":'
							cJson += cValTochar(cConteudo)
						Else
							cConteudo   := Alltrim(cConteudo)
							cJson       += '"' + aCposCab[nX] + '":'
							cJson       += '"' + cConteudo + '"'
						EndIf

						cJson += ','

					EndIf

				endif

			Next nX

			cJson += '"NumeroPaginas":"'+ cValToChar(nQtdPag) +'",'

			If nPage == nQtdPag
				cJson += '"IsLastPage":true,
			Else
				cJson += '"IsLastPage":false,
			EndIf

			cJson += '"lret' + cValTochar(nLine) + '":true,'

			cChave := (cAlsRes)->F1_DOC
			cChave += (cAlsRes)->F1_FORNECE
			cChave += (cAlsRes)->F1_LOJA 

			cJson += '"itens":['



			While cChave == ((cAlsRes)->F1_DOC + (cAlsRes)->F1_FORNECE + (cAlsRes)->F1_LOJA) 
				cJson += "{"         
				For nX := 1 to Len(aCpos)

					If SUBSTR(aCpos[nX],1,2) == "D1"    
						dbselectarea(cAlsRes)
						If nX < Len(aCpos)

							If Empty(aCont[nX])   

								cConteudo := & ("(cAlsRes)->" + aCpos[nX])

							Else

								cConteudo := &(aCont[nX])

							Endif

							If ValType( cConteudo) == "N"
								cJson += '"' + aCposCab[nX] + '":'
								cJson += cValTochar(cConteudo)
							Else
								cConteudo   := Alltrim(cConteudo)
								cJson       += '"' + aCposCab[nX] + '":'
								cJson       += '"' + cConteudo + '"'
							EndIf


							cJson += ','


						Else

							If Empty(aCont[nX])   

								cConteudo := & ("(cAlsRes)->" + aCpos[nX])

							Else

								cConteudo := &(aCont[nX])

							Endif

							If ValType( cConteudo) == "N"
								cJson += '"' + aCposCab[nX] + '":'
								cJson += cValTochar(cConteudo)
							Else
								cConteudo   := Alltrim(cConteudo)
								cJson       += '"' + aCposCab[nX] + '":'
								cJson       += '"' + cConteudo + '"'
							EndIf

						EndIf
					EndIf


				Next nX

				cJson := Left(cJson, Rat(",", cJson)-1)
				cJson += "},"

				(cAlsRes)->(DbSkip())
				If cChave <> ((cAlsRes)->F1_DOC + (cAlsRes)->F1_FORNECE + (cAlsRes)->F1_LOJA)
					cJson := Left(cJson, Rat(",", cJson)-1)
				Endif  
			EndDo



			cJson += "]"
			cJson += "},"

			cMenssagem  := "Get realizado com sucesso."
			U_MonitRes("000010", 2, , cIdPZB, cMenssagem, .T., "Get de Entradas", cJson, "", "", .F., .F.)

			nLine++

			If nPage = 0 .OR. !Empty(cCgcForn) 
				If (cAlsRes)->(Eof())
					cJson := Left(cJson, Rat(",", cJson)-1)
					Exit
				EndIf
			Else
				If nLine == (nPags + 1) .Or. (cAlsRes)->(Eof())
					cJson := Left(cJson, Rat(",", cJson)-1)
					Exit
				EndIf
			EndIf
		End

		(cAlsRes)->(dbCloseArea())

		If Empty(cJson) 

			cJson += "{"
			cJson += '"entradas":['
			cJson += "{" 
			cJson += '"errorMessage' + cValTochar(1) + '":"'+ "entradas nao encontrado" +'",'
			cJson += '"lret' + cValTochar(1) + '":false'
			cJson += "}"

		EndIf

		//Finaliza o processo na PZB
		U_MonitRes("000010", 3, , cIdPZB, , .T.)

	EndIf

cJson += "]}"

(cAlsQry)->(dbCloseArea())

cJson	:= StrTran(StrTran(cJson,chr(9),''),'\','')

::SetContentType("application/json")
::SetResponse( cJson )

Return(.T.)

WsRestFul PostConfEntr Description "Post de Confirmação de Entradas"

WsData cCgcEmp		As String
WsData cTipo		As String

WsMethod Post Description "Confirmação de Entradas" WsSyntax "/PostConfEntr"

End WsRestFul

WsMethod Post WsReceive cCgcEmp,cTipo WsService PostConfEntr

	Local cBody     := ::GetContent()
	Local oJsoAux   := Nil
	Local cQuery    := ""
	Local cAlsQry   := CriaTrab(Nil,.F.)
	Local nX
	Local cStrErro  := ""
	Local aDados    := {}
	Local aCriaServ := {}
	Local cJson     := ""
	Local cCgcEmp   := IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")
	Local ctipo   	:= IIf(::cTipo <> Nil , ::cTipo , "")
	Local aEmpresas := FwLoadSM0()
	Local LOK       := .T.

	nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == cCgcEmp })

	If nPosEmp == 0
		cJson := '{"Erro":"Empresa nao cadastrada."}'
		::SetResponse( cJson )
		Return .T.
	Else
		RpcClearEnv()
		RpcSetEnv(aEmpresas[nPosEmp][1],aEmpresas[nPosEmp][2])
	EndIf

	FWJsonDeserialize(cBody, @oJsoAux)

	SM0->(DbSetOrder(1))

	cQuery := " SELECT PR2.* FROM " + RetSqlName("PR2") + " (NOLOCK) PR2 "
	cQuery += " INNER JOIN " + RetSqlName("PR1") + " (NOLOCK) PR1 "
	cQuery += " ON PR2_FILIAL = PR1_FILIAL AND PR2_CODIGO = PR1_CODIGO "
	cQuery += " WHERE PR1_CODPZA = '000011' AND PR1.D_E_L_E_T_ = ' '  AND PR2.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	If len(oJsoAux:Entradas) > 0

		cJson := "{"

		//Cria serviço no montitor
		aCriaServ := U_MonitRes("000011", 1, Len(oJsoAux:Entradas) )   
		cIdPZB 	  := aCriaServ[2]

		cJson += '"Entradas":['

		For nX := 1 to len(oJsoAux:Entradas)

			(cAlsQry)->(DbGoTop())


			While !(cAlsQry)->(Eof())

				cCpo        := Alltrim((cAlsQry)->PR2_CPOORI)

				If (cAlsQry)->PR2_TPCONT == "1"
					cConteudo := &("oJsoAux:Entradas[" + cValTochar(nX) + "]:" + cCpo)  
				Else
					cConteudo := &((cAlsQry)->PR2_CONTEU)
				EndIf

				aAdd(aDados, {Alltrim((cAlsQry)->PR2_CPODES), cConteudo, nil})

				(cAlsQry)->(DbSkip())

			End

			DBSelectArea("SA2")
			SA2->(DBSetOrder(3))

			nPos := Ascan(aDados,{|x| Alltrim(AllTrim(x[1]))=="F1_FORNECE"})

			If SA2->(DBSeek(xFilial("SA2") + AllTrim(aDados[nPos][2])))
				cFornc	:= SA2->A2_COD
				cLoja	:= SA2->A2_LOJA
			Else
				cJson += '"Entradas":['
				cJson += "{" 
				cJson += '"errorMessage":"Fornecedor não Encontrado",'
				cJson += '"lret":false'
				cJson += "},"
				Loop
			EndIf

			DBSelectArea("SF1")
			SF1->(DBSetOrder(1))

			nPos 	:= Ascan(aDados,{|x| Alltrim(AllTrim(x[1]))=="F1_DOC"})
			cChave 	:= PADR(AllTrim(aDados[nPos][2]),TamSx3("F1_DOC")[1])
			nPos 	:= Ascan(aDados,{|x| Alltrim(AllTrim(x[1]))=="F1_SERIE"})
			cChave 	+= PADR(AllTrim(aDados[nPos][2]),TamSx3("F1_SERIE")[1])
			cChave	+= cFornc
			cChave	+= cLoja

			//nPos 	:= Ascan(aDados,{|x| Alltrim(AllTrim(x[1]))=="F1_XENVWMS"})
			LOK		:= .T.

			cMenssagem  := "Post Entradas"

			If !SF1->(DBSeek(xFilial("SF1") + cChave))

				U_MonitRes("000011", 2, , cIdPZB, cMenssagem, .F., cStrErro, "", cBody, "", .F., .F.)

				//Finaliza o processo na PZB
				U_MonitRes("000011", 3, , cIdPZB, , .F.)

				cJson += "{" 
				cJson += '"errorMessage":"Documeto nao Encontrado",'
				cJson += '"lret":false'
				cJson += "},"

			Else

				If !Empty(cTipo)
					RECLOCK("SF1",.F.)
					SF1->F1_XENVWMS := "99"
					SF1->(MSUnlock())
				Else
					RECLOCK("SF1",.F.)
					SF1->F1_XENVWMS := "99"
					SF1->F1_XCONFWM := "99"
					SF1->(MSUnlock())
				EndIf

				U_MonitRes("000011", 2, , cIdPZB, cMenssagem, .T., "Entradas inclusas com sucesso", "", cBody, "", .F., .F.)

				//Finaliza o processo na PZB
				U_MonitRes("000011", 3, , cIdPZB, , .T.)

				cJson += "{" 
				cJson += '"cNota":"' + SF1->F1_DOC + '",'
				cJson += '"cSerie":"' + SF1->F1_SERIE + '",'
				cJson += '"lret":true'
				cJson += "},"

			EndIf

		Next nX

		cJson := Left(cJson, Rat(",", cJson)-1)
		cJson += "]}"

		::SetResponse( cJson )

	EndIf

(cAlsQry)->(dbCloseArea())

Return(.T.)

WsRestFul PostConfFat Description "Confirmação de Faturamento"

WsData cCgcEmp		As String

WsMethod Post Description "Confirmação de Faturamento" WsSyntax "/PostConfFat"

End WsRestFul

WsMethod Post WsReceive cCgcEmp WsService PostConfFat

	Local cBody     := ::GetContent()
	Local oJsoAux   := Nil
	Local cQuery    := ""
	Local oLoc		:= Nil
	Local cLoc		:= ""
	Local cAlsQry   := CriaTrab(Nil,.F.)
	Local nX
	Local cStrErro  := ""
	Local cEstado	:= ""
	Local aDados    := {}
	Local aCriaServ := {}
	Local nErro     := 0
	Local cJson     := ""
	Local cCgcEmp   := IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")
	Local aEmpresas := FwLoadSM0()
	Local oBkpJso   := Nil
	Local cSeek     := ''
	Local lOk       := .T.
	Local cRetMen   := ''
	Local cAlsF2	:= CriaTrab(Nil,.F.)
	Local cRetChave := ''
	Local cConteudo := ''
	Local cRetChave := ""

	nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == cCgcEmp })

	If nPosEmp == 0
		cJson := '{"Erro":"Empresa nao cadastrada."}'
		::SetResponse( cJson )
		Return .T.
	Else
		RpcClearEnv()
		RpcSetEnv(aEmpresas[nPosEmp][1],aEmpresas[nPosEmp][2])
	EndIf

	FWJsonDeserialize(cBody, @oJsoAux)

	SM0->(DbSetOrder(1))

	cQuery := " SELECT PR2.* FROM " + RetSqlName("PR2") + " (NOLOCK) PR2 "
	cQuery += " INNER JOIN " + RetSqlName("PR1") + " (NOLOCK) PR1 "
	cQuery += " ON PR2_FILIAL = PR1_FILIAL AND PR2_CODIGO = PR1_CODIGO "
	cQuery += " WHERE PR1_CODPZA = '000012' AND PR1.D_E_L_E_T_ = ' '  AND PR2.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	If len(oJsoAux:Pedidos) > 0

		cJson := "{"

		//Cria serviço no montitor
		aCriaServ := U_MonitRes("000012", 1, Len(oJsoAux:Pedidos) )   
		cIdPZB 	  := aCriaServ[2]

		::SetContentType("application/json")
		cJson += '"Pedidos":['

		For nX := 1 to len(oJsoAux:Pedidos)

			(cAlsQry)->(DbGoTop())

			While !(cAlsQry)->(Eof())

				cCpo        := Alltrim((cAlsQry)->PR2_CPODES)

				cConteudo += &("oJsoAux:Pedidos[1]:" + Alltrim((cAlsQry)->PR2_CPOORI)  )  


				(cAlsQry)->(DbSkip())

			End
			dbSelectArea("SC5")
			dbSetORder(1)

			cSeek := oJsoAux:Pedidos[nX]:Numero

			If SC5->(DBSeek(xFilial("SC5") + cSeek))

				cQuery :=  " SELECT F2_CHVNFE, C5_XPWMS,C5_NUM FROM " + RetSqlName("SF2") + " SF2 "
				cQuery +=  " JOIN " + RetSqlName("SC5") + " (NOLOCK) SC5 ON C5_NOTA = F2_DOC AND C5_CLIENTE = F2_CLIENTE AND C5_FILIAL = F2_FILIAL "
				cQuery +=  " WHERE F2_DOC = '" + SC5->C5_NOTA +"' AND SC5.D_E_L_E_T_ = '' AND SF2.D_E_L_E_T_ = '' "

				If Select(cAlsF2) > 0
					(cAlsF2)->(dbCloseArea())
				Endif

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsF2,.T.,.T.) 

				(cAlsF2)->(DbGoTop())

				If (cAlsF2)->(Eof())

					cRetMen  := "Nota ainda nao faturada - Sem chave"

					lOk := .F.

				Else

					If (cAlsF2)->C5_XPWMS <> 'F'

						cRetChave := (cAlsF2)->(F2_CHVNFE)

						RecLock("SC5",.F.)
						SC5->C5_XPWMS  := 'F'
						SC5->(MsUnlock())

						cRetMen := 'Processo Executado com Sucesso'


					Else
						cRetMen := 'Nota ja faturada e confirmada'

						lOk := .F.
					Endif 

				Endif 

			Else
				cRetMen := 'Registro nao encotrado na tabela SC5'

				lOk := .F.
			Endif 



			If !lOk
				U_MonitRes("000012", 2, , cIdPZB, cRetMen, .F., cStrErro, "", cBody, "", .F., .F.)

				//Finaliza o processo na PZB
				U_MonitRes("000012", 3, , cIdPZB, , .F.)

				cJson += "{" 
				cJson += '"errorMessage' + cValTochar(nX) + '":"' + cRetMen + '",'
				cJson += '"pedido": "' + (cAlsF2)->C5_NUM + '",'
				cJson += '"lret' + cValTochar(nX) + '":false'
				cJson += "},"

			Else
				U_MonitRes("000012", 2, , cIdPZB, cRetMen, .T., "Processo Finalizado", "", cBody, "", .F., .F.)

				//Finaliza o processo na PZB
				U_MonitRes("000012", 3, , cIdPZB, , .T.)

				cJson += "{"
				cJson += '"chave": ' +  cRetChave + ","
				cJson += '"pedido": "' + (cAlsF2)->C5_NUM + '",'
				cJson += '"lret' + cValTochar(nX) + '":true'
				cJson += "},"

			EndIf

		Next nX

		cJson := Left(cJson, Rat(",", cJson)-1)
		cJson += "]}"

		ConOut(cJson)

		::SetResponse( cJson )

	EndIf

(cAlsQry)->(dbCloseArea())

Return(.T.)

WsRestFul PostLibPV Description "Post de Liberação de Pedido de Venda"

WsData cCgcEmp		As String
WsData cTpLib		As String

WsMethod Post Description "Liberação de Pedido de Venda" WsSyntax "/PostLibPV"

End WsRestFul

WsMethod Post WsReceive cCgcEmp,cTpLib WsService PostLibPV

	Local cBody     := ::GetContent()
	Local cCli		:= ""
	Local cLoja		:= ""
	Local oJsoAux   := Nil
	Local cQuery    := ""
	Local oLoc		:= Nil
	Local cLoc		:= ""
	Local cAlsQry   := CriaTrab(Nil,.F.)
	Local nX
	Local nV
	Local cStrErro  := ""
	Local cEstado	:= ""
	Local aDados    := {}
	Local aCriaServ := {}
	Local nErro     := 0
	Local cJson     := ""
	Local cCgcEmp   := IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")
	Local cTpLib	:= IIF(::cTpLib <> NIL, ::cTpLib , "")
	Local aEmpresas := FwLoadSM0()
	Local oBkpJso   := Nil

	nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == cCgcEmp })

	If nPosEmp == 0
		cJson := '{"Erro":"Empresa nao cadastrada."}'
		::SetResponse( cJson )
		Return .T.
	Else
		RpcClearEnv()
		RpcSetEnv(aEmpresas[nPosEmp][1],aEmpresas[nPosEmp][2])
	EndIf

	FWJsonDeserialize(cBody, @oJsoAux)

	SM0->(DbSetOrder(1))

	cQuery := " SELECT PR2.* FROM " + RetSqlName("PR2") + " (NOLOCK) PR2 "
	cQuery += " INNER JOIN " + RetSqlName("PR1") + " (NOLOCK) PR1 "
	cQuery += " ON PR2_FILIAL = PR1_FILIAL AND PR2_CODIGO = PR1_CODIGO "
	cQuery += " WHERE PR1_CODPZA = '000013' AND PR1.D_E_L_E_T_ = ' '  AND PR2.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	If len(oJsoAux:Pedidos) > 0

		cJson := "{"

		//Cria serviço no montitor
		aCriaServ := U_MonitRes("000013", 1, Len(oJsoAux:Pedidos) )   
		cIdPZB 	  := aCriaServ[2]

		cJson += '"Pedidos":[

		For nX := 1 to len(oJsoAux:Pedidos)

			(cAlsQry)->(DbGoTop())


			While !(cAlsQry)->(Eof())

				cCpo        := Alltrim((cAlsQry)->PR2_CPOORI)

				If (cAlsQry)->PR2_TPCONT == "1"
					cConteudo := &("oJsoAux:Pedidos[" + cValTochar(nX) + "]:" + cCpo)  
				Else
					cConteudo := &((cAlsQry)->PR2_CONTEU)
				EndIf

				aAdd(aDados, {Alltrim((cAlsQry)->PR2_CPODES), cConteudo, nil})

				(cAlsQry)->(DbSkip())

			End

			DBSelectArea("SA1")
			SA1->(DBSetOrder(3))

			nPos := Ascan(aDados,{|x| Alltrim(AllTrim(x[1]))=="C5_CLIENTE"})

			If SA1->(DBSeek(xFilial("SA1") + AllTrim(aDados[nPos][2])))
				cCli	:= SA1->A1_COD
				cLoja	:= SA1->A1_LOJA
			Else
				//cJson += '"Pedidos":['
				cJson += "{" 
				cJson += '"errorMessage":"Cliente não Encontrado",'
				cJson += '"lret":false'
				cJson += "},"
				Loop
			EndIf

			DBSelectArea("SC5")
			SC5->(DBSetOrder(1))

			//cChave 	:= cCli + cLoja
			nPos 	:= Ascan(aDados,{|x| Alltrim(AllTrim(x[1]))=="C5_NUM"})
			cChave 	:= PADR(AllTrim(aDados[nPos][2]),TamSx3("C5_NUM")[1])

			cMenssagem  := "Post Pedidos"

			If !SC5->(DBSeek(xFilial("SC5") + cChave))

				U_MonitRes("000013", 2, , cIdPZB, cMenssagem, .F., cStrErro, "", cBody, "", .F., .F.)

				//Finaliza o processo na PZB
				U_MonitRes("000013", 3, , cIdPZB, , .F.)

				//cJson += '"Pedidos":['
				cJson += "{" 
				cJson += '"errorMessage":"Pedido nao Encontrado",'
				cJson += '"lret":false,'
				cJson += '"Pedido":'+Right(cChave,6)
				cJson += "},"

			Else

				If cTpLib == "P"
					RECLOCK("SC5",.F.)
					SC5->C5_XENVWMS := "99"
					SC5->(MSUnlock())
				Else
					SA4->(DbSetOrder(3))
					XS5->(DbSetOrder(3))

					If !("Transportadora" $ cBody)
						cTransp := cCgcEmp
					ElseIf SA4->(MsSeek(xFilial("SA4")+Alltrim(oJsoAux:Pedidos[nX]:Transportadora)))
						cTransp := SA4->A4_COD
					Else
						cTransp := ""
					Endif

					RECLOCK("SC5",.F.)
					SC5->C5_XLIBWMS := "L"
					SC5->C5_XCONFPD	:= "S"
					SC5->C5_XEXPEDI	:= "S"           
					SC5->C5_TRANSP  := cTransp
					SC5->(MSUnlock())

					SZJ->(DbSetOrder(1))
					If !SZJ->(MsSeek(xFilial("SZJ")+SC5->(C5_FILIAL+C5_NUM+C5_CLIENTE+C5_LOJACLI)))

						For nV := 1 to len(oJsoAux:Pedidos[nX]:Volumes)

							RecLock("SZJ",.T.)
							SZJ->ZJ_FILIAL  := xFilial("SZJ") 
							SZJ->ZJ_PEDIDO  := SC5->(C5_FILIAL+C5_NUM+C5_CLIENTE+C5_LOJACLI)
							SZJ->ZJ_VOLUME  := StrZero(nV,6)
							SZJ->ZJ_2PESO   := Val(oJsoAux:Pedidos[nX]:Volumes[nV]:Peso)
							SZJ->ZJ_DIMENSA := oJsoAux:Pedidos[nX]:Volumes[nV]:Dimensao
							SZJ->ZJ_TEMPERA := oJsoAux:Pedidos[nX]:Volumes[nV]:Temperatura
							SZJ->ZJ_DATA    := Date()
							SZJ->ZJ_HORA    := Time()
							SZJ->ZJ_TRANSP  := cTransp

							If !("Agente" $ cBody )
								cAgente := cCgcEmp
							Else
								cAgente := oJsoAux:Pedidos[nX]:Agente
							EndIf
							If XS5->(MsSeek(xFilial("XS5")+Alltrim(cAgente)))
								SZJ->ZJ_AGENTE  := XS5->XS5_CODIGO
							Endif

							SZJ->(MsUnLock())

						Next nV
					Endif

				ENDIF

				U_MonitRes("000013", 2, , cIdPZB, cMenssagem, .T., "Pedido Liberado com sucesso", "", cBody, "", .F., .F.)

				//Finaliza o processo na PZB
				U_MonitRes("000013", 3, , cIdPZB, , .T.)

				'
				cJson += "{" 
				cJson += '"lret":true,'
				cJson += '"Pedido":'+ '"' + SC5->C5_NUM + '"'
				cJson += "},"

			EndIf

			aDados := {}

		Next nX

		cJson := Left(cJson, Rat(",", cJson)-1)
		cJson += "]}"

		::SetResponse( cJson )

	EndIf

(cAlsQry)->(dbCloseArea())

Return(.T.)

WsRestFul GetConRec Description "Metodo Responsavel por Contas a receber"

WsData dDataAte		As Date Optional
WsData dDataDe		As Date Optional 
WsData cCgcCli      As String Optional
WsData cCgcEmp      As String Optional
WsData nPage        As Float Optional

WsMethod Get Description "Contas a Receber" WsSyntax "/GetConRec"

End WsRestFul

WsMethod Get WsReceive cCgcEmp, cCgcCli, dDataDe, dDataAte, nPage WsService GetConRec

	Local cCli		:= ""
	Local cLoja		:= ""
	Local cJson     := ""
	Local cQuery    := ""   
	Local cIdPZB	:= "" 
	Local cQryRes   := ""

	Local nX		:= 0
	Local nY		:= 0
	Local nDE		:= 0
	Local nPags		:= 0
	Local nLine     := 1
	Local nCount    := 1
	Local nPosEmp	:= 0
	Local nQtdPag	:= 0

	Local aCpos     := {}
	Local cPagsAux	:= ""
	Local aCposCab  := {}
	Local cConteudo := ""
	Local aCriaServ := {}
	Local aEmpresas := FwLoadSM0()

	Local dDataAte	:= IIf(::dDataAte <> Nil , ::dDataAte , "")
	Local dDataDe	:= IIf(::dDataDe <> Nil , ::dDataDe , "")
	Local cCgcCli	:= IIf(::cCgcCli <> Nil , ::cCgcCli , "")
	Local cCgcEmp   := IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")
	Local nPage		:= IIf(::nPage <> Nil, ::nPage, 1)

	Private cAlsQry   := CriaTrab(Nil,.F.)
	Private cAlsRes   := CriaTrab(Nil,.F.)

	nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == Alltrim(cCgcEmp) })

	If nPosEmp == 0
		cJson := '{"Erro":"Empresa nao cadastrada."}'
		::SetResponse( cJson )
		Return .T.
	Else
		RpcClearEnv()
		RpcSetEnv(aEmpresas[nPosEmp][1],aEmpresas[nPosEmp][2])
	EndIf   

	If !Empty(cCgcCli)

		DBSelectArea("SA1")
		SA1->(DBSetOrder(3))	

		If SA1->(DBSeek(xFilial("SA1") + cCgcCli))
			cCli	:= SA1->A1_COD
			cLoja	:= SA1->A1_LOJA
		Else
			cJson := '{Cliente nao Encontrado.}'
			::SetResponse( cJson )
			Return .T.
		EndIf
	EndIf

	nPags	:= GetMV("FT_QTPAGIC",,10)

	cQuery 	:= " SELECT PR2.* FROM " + RetSqlName("PR2") + " (NOLOCK) PR2 "
	cQuery 	+= " INNER JOIN " + RetSqlName("PR1") + " (NOLOCK) PR1 "
	cQuery 	+= " ON PR2_FILIAL = PR1_FILIAL AND PR2_CODIGO = PR1_CODIGO "
	cQuery 	+= " WHERE PR1_CODPZA = '000014' AND PR1.D_E_L_E_T_ = ' '  AND PR2.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	While !(cAlsQry)->(Eof())

		If nCount == 1
			cQryRes := " SELECT  "
			cQryRes += (cAlsQry)->PR2_CPODES 

		Else
			cQryRes += " , " + (cAlsQry)->PR2_CPODES  

		EndIf

		AADD(aCpos, Alltrim((cAlsQry)->PR2_CPODES) )
		AADD(aCposCab, Alltrim((cAlsQry)->PR2_CPOORI))

		nCount++
		(cAlsQry)->(DbSkip())

	End

	If !Empty(cQryRes)

		cQryRes += " FROM " + RetSqlName("SE2") + " (NOLOCK) SE2 "
		cQryRes += " WHERE "

		//CLIENTE
		If !Empty(cCgcCli)
			cQryRes += " E1_CLIENTE = '" + cCli + "' AND "
			cQryRes += " E1_LOJA = '" + cLoja + "' AND "
		EndIf

		//DATA
		If !Empty(dDataDe)
			cQryRes += " E1_EMISSAO >= '" + DtoS(dDataDe) + "' AND "
		EndIf

		If !Empty(dDataAte)
			cQryRes += " E1_EMISSAO <= '" + DtoS(dDataAte) + "' AND "
		EndIf

		cQryRes += " SE2.D_E_L_E_T_ = ' ' "

		If Select(cAlsRes) > 0; (cAlsRes)->(dbCloseArea()); Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryRes),cAlsRes,.T.,.T.)

		nQtdReg		:= Contar(cAlsRes,"!Eof()")
		nQtdPag		:= (nQtdReg/nPags)
		cPagsAux	:= cValToChar(nQtdPag)

		If SUBSTR(cPagsAux,1,1) == "0"
			nQtdPag := 1    			
		ElseIf At(".",cPagsAux) <> 0 
			nQtdPag := Val(SUBSTR(cPagsAux,1,( At(".",cPagsAux)-1 )))
			nQtdPag++
		Else
			nQtdPag := Val(cPagsAux)
		EndIf		

		If Empty(cCgcCli)

			(cAlsRes)->(DbGoTop())

			nDE := ((nPage*nPags) - nPags)

			For nY := 0 To nDE
				(cAlsRes)->(DBSkip())
			Next nY

		Else
			(cAlsRes)->(DbGoTop())
		EndIf

		While !(cAlsRes)->(Eof()) 

			If nLine == 1

				//Cria serviço no montitor
				aCriaServ := U_MonitRes("000014", 1, nQtdReg)   
				cIdPZB 	  := aCriaServ[2]

				cJson := '{"ContasReceber":['

			EndIf

			cJson += "{"

			For nX := 1 to Len(aCpos)

				If nX < Len(aCpos)
					cConteudo := & ("(cAlsRes)->" + aCpos[nX])

					If ValType( cConteudo) == "N"
						cJson += '"' + aCposCab[nX] + '":'
						cJson += cValTochar(cConteudo)
					Else
						cConteudo   := Alltrim(cConteudo)
						cJson       += '"' + aCposCab[nX] + '":'
						cJson       += '"' + cConteudo + '"'
					EndIf

					cJson += ','
				Else
					cConteudo   := & ("(cAlsRes)->" + aCpos[nX])

					If ValType( cConteudo) == "N"
						cJson += '"' + aCposCab[nX] + '":'
						cJson += cValTochar(cConteudo)
					Else
						cConteudo   := Alltrim(cConteudo)
						cJson       += '"' + aCposCab[nX] + '":'
						cJson       += '"' + cConteudo + '"'
					EndIf

				EndIf

			Next nX

			cJson += ','
			cJson += '"NumeroPaginas":"'+ cValToChar(nQtdPag) +'",'

			If nPage == nQtdPag
				cJson += '"IsLastPage":true,
			Else
				cJson += '"IsLastPage":false,
			EndIf

			cJson += '"lret' + cValTochar(nLine) + '":true'
			cJson += "},"

			cMenssagem  := "Get realizado com sucesso."
			U_MonitRes("000014", 2, , cIdPZB, cMenssagem, .T., "Get Contas Receber", cJson, "", "", .F., .F.)

			nLine++

			(cAlsRes)->(DbSkip())

			If nPage = 0 .OR. !Empty(cCgcCli) 
				If (cAlsRes)->(Eof())
					cJson := Left(cJson, Rat(",", cJson)-1)
					Exit
				EndIf
			Else
				If nLine == (nPags + 1) .Or. (cAlsRes)->(Eof())
					cJson := Left(cJson, Rat(",", cJson)-1)
					Exit
				EndIf
			EndIf
		End

		(cAlsRes)->(dbCloseArea())

		If Empty(cJson) 

			cJson += "{"
			cJson += '"ContasReceber":['
			cJson += "{" 
			cJson += '"errorMessage' + cValTochar(1) + '":"'+ "Contas a receber nao encontrado" +'",'
			cJson += '"lret' + cValTochar(1) + '":false'
			cJson += "},"

		EndIf

		//Finaliza o processo na PZB
		U_MonitRes("000014", 3, , cIdPZB, , .T.)

	EndIf

cJson += "]}"

(cAlsQry)->(dbCloseArea())

::SetContentType("application/json")
::SetResponse( cJson )

Return(.T.)

WsRestFul GetConPag Description "Metodo Responsavel por Contas a Pagar"

WsData dDataAte		As Date Optional
WsData dDataDe		As Date Optional 
WsData cCgcFor      As String Optional
WsData cCgcEmp      As String Optional
WsData nPage        As Float Optional

WsMethod Get Description "Contas a Pagar" WsSyntax "/GetConPag"

End WsRestFul

WsMethod Get WsReceive cCgcEmp, cCgcFor, dDataDe, dDataAte, nPage WsService GetConPag

	Local cFor		:= ""
	Local cLoja		:= ""
	Local cJson     := ""
	Local cQuery    := ""   
	Local cIdPZB	:= "" 
	Local cQryRes   := ""

	Local nX		:= 0
	Local nY		:= 0
	Local nDE		:= 0
	Local nPags		:= 0
	Local nLine     := 1
	Local nCount    := 1
	Local nPosEmp	:= 0
	Local nQtdPag	:= 0

	Local aCpos     := {}
	Local cPagsAux	:= ""
	Local aCposCab  := {}
	Local cConteudo := ""
	Local aCriaServ := {}
	Local aEmpresas := FwLoadSM0()

	Local dDataAte	:= IIf(::dDataAte <> Nil , ::dDataAte , "")
	Local dDataDe	:= IIf(::dDataDe <> Nil , ::dDataDe , "")
	Local cCgcFor	:= IIf(::cCgcFor <> Nil , ::cCgcFor , "")
	Local cCgcEmp   := IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")
	Local nPage		:= IIf(::nPage <> Nil, ::nPage, 1)

	Private cAlsQry   := CriaTrab(Nil,.F.)
	Private cAlsRes   := CriaTrab(Nil,.F.)

	nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == Alltrim(cCgcEmp) })

	If nPosEmp == 0
		cJson := '{"Erro":"Empresa nao cadastrada."}'
		::SetResponse( cJson )
		Return .T.
	Else
		RpcClearEnv()
		RpcSetEnv(aEmpresas[nPosEmp][1],aEmpresas[nPosEmp][2])
	EndIf   

	If !Empty(cCgcFor)

		DBSelectArea("SA2")
		SA2->(DBSetOrder(3))	

		If SA2->(DBSeek(xFilial("SA2") + cCgcFor))
			cFor	:= SA2->A2_COD
			cLoja	:= SA2->A2_LOJA
		Else
			cJson := '{Fornecedor nao Encontrado.}'
			::SetResponse( cJson )
			Return .T.
		EndIf
	EndIf

	nPags	:= GetMV("FT_QTPAGIC",,10)

	cQuery 	:= " SELECT PR2.* FROM " + RetSqlName("PR2") + " (NOLOCK) PR2 "
	cQuery 	+= " INNER JOIN " + RetSqlName("PR1") + " (NOLOCK) PR1 "
	cQuery 	+= " ON PR2_FILIAL = PR1_FILIAL AND PR2_CODIGO = PR1_CODIGO "
	cQuery 	+= " WHERE PR1_CODPZA = '000015' AND PR1.D_E_L_E_T_ = ' '  AND PR2.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	While !(cAlsQry)->(Eof())

		If nCount == 1
			cQryRes := " SELECT  "
			cQryRes += (cAlsQry)->PR2_CPODES 

		Else
			cQryRes += " , " + (cAlsQry)->PR2_CPODES  

		EndIf

		AADD(aCpos, Alltrim((cAlsQry)->PR2_CPODES) )
		AADD(aCposCab, Alltrim((cAlsQry)->PR2_CPOORI))

		nCount++
		(cAlsQry)->(DbSkip())

	End

	If !Empty(cQryRes)

		cQryRes += " FROM " + RetSqlName("SE2") + " (NOLOCK) SE2 "
		cQryRes += " WHERE "

		//ForENTE
		If !Empty(cCgcFor)
			cQryRes += " E2_FORNECE = '" + cFor + "' AND "
			cQryRes += " E2_LOJA = '" + cLoja + "' AND "
		EndIf

		//DATA
		If !Empty(dDataDe)
			cQryRes += " E2_EMISSAO >= '" + DtoS(dDataDe) + "' AND "
		EndIf

		If !Empty(dDataAte)
			cQryRes += " E2_EMISSAO <= '" + DtoS(dDataAte) + "' AND "
		EndIf

		cQryRes += " SE2.D_E_L_E_T_ = ' ' "

		If Select(cAlsRes) > 0; (cAlsRes)->(dbCloseArea()); Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryRes),cAlsRes,.T.,.T.)

		nQtdReg		:= Contar(cAlsRes,"!Eof()")
		nQtdPag		:= (nQtdReg/nPags)
		cPagsAux	:= cValToChar(nQtdPag)

		If SUBSTR(cPagsAux,1,1) == "0"
			nQtdPag := 1    			
		ElseIf At(".",cPagsAux) <> 0 
			nQtdPag := Val(SUBSTR(cPagsAux,1,( At(".",cPagsAux)-1 )))
			nQtdPag++
		Else
			nQtdPag := Val(cPagsAux)
		EndIf		

		If Empty(cCgcFor)

			(cAlsRes)->(DbGoTop())

			nDE := ((nPage*nPags) - nPags)

			For nY := 0 To nDE
				(cAlsRes)->(DBSkip())
			Next nY

		Else
			(cAlsRes)->(DbGoTop())
		EndIf

		While !(cAlsRes)->(Eof()) 

			If nLine == 1

				//Cria serviço no montitor
				aCriaServ := U_MonitRes("000015", 1, nQtdReg)   
				cIdPZB 	  := aCriaServ[2]

				cJson := '{"ContasPagar":['

			EndIf

			cJson += "{"

			For nX := 1 to Len(aCpos)

				If nX < Len(aCpos)
					cConteudo := & ("(cAlsRes)->" + aCpos[nX])

					If ValType( cConteudo) == "N"
						cJson += '"' + aCposCab[nX] + '":'
						cJson += cValTochar(cConteudo)
					Else
						cConteudo   := Alltrim(cConteudo)
						cJson       += '"' + aCposCab[nX] + '":'
						cJson       += '"' + cConteudo + '"'
					EndIf

					cJson += ','
				Else
					cConteudo   := & ("(cAlsRes)->" + aCpos[nX])

					If ValType( cConteudo) == "N"
						cJson += '"' + aCposCab[nX] + '":'
						cJson += cValTochar(cConteudo)
					Else
						cConteudo   := Alltrim(cConteudo)
						cJson       += '"' + aCposCab[nX] + '":'
						cJson       += '"' + cConteudo + '"'
					EndIf

				EndIf

			Next nX

			cJson += ','
			cJson += '"NumeroPaginas":"'+ cValToChar(nQtdPag) +'",'

			If nPage == nQtdPag
				cJson += '"IsLastPage":true,
			Else
				cJson += '"IsLastPage":false,
			EndIf

			cJson += '"lret' + cValTochar(nLine) + '":true'
			cJson += "},"

			cMenssagem  := "Get realizado com sucesso."
			U_MonitRes("000015", 2, , cIdPZB, cMenssagem, .T., "Get Contas Pagar", cJson, "", "", .F., .F.)

			nLine++

			(cAlsRes)->(DbSkip())

			If nPage = 0 .OR. !Empty(cCgcFor) 
				If (cAlsRes)->(Eof())
					cJson := Left(cJson, Rat(",", cJson)-1)
					Exit
				EndIf
			Else
				If nLine == (nPags + 1) .Or. (cAlsRes)->(Eof())
					cJson := Left(cJson, Rat(",", cJson)-1)
					Exit
				EndIf
			EndIf
		End

		(cAlsRes)->(dbCloseArea())

		If Empty(cJson) 

			cJson += "{"
			cJson += '"ContasPagar":['
			cJson += "{" 
			cJson += '"errorMessage' + cValTochar(1) + '":"'+ "Contas a Pagar nao encontrado" +'",'
			cJson += '"lret' + cValTochar(1) + '":false'
			cJson += "},"

		EndIf

		//Finaliza o processo na PZB
		U_MonitRes("000015", 3, , cIdPZB, , .T.)

	EndIf

cJson += "]}"

(cAlsQry)->(dbCloseArea())

::SetContentType("application/json")
::SetResponse( cJson )

Return(.T.)


WsRestFul PostPV Description "Metodo Responsavel por Cadastrar Pedidos de Venda"

WsData cCgcEmp		As String

WsMethod Post Description "Cadastro de Pedidos de Venda" WsSyntax "/PostPV"

End WsRestFul

WsMethod Post WsReceive cCgcEmp WsService PostPV

	Local cBody     := ::GetContent()
	Local oJsoAux   := Nil
	Local cQuery    := ""
	Local oLoc		:= Nil
	Local cLoc		:= ""
	Local cAlsQry   := CriaTrab(Nil,.F.)
	Local nX
	Local nY
	Local cStrErro  := ""
	Local cEstado	:= ""
	Local aDados    := {}
	Local _aAux		:= {}
	Local _aCab	    := {}
	Local _aItens	:= {}
	Local aCriaServ := {}
	Local nErro     := 0
	Local cJson     := ""
	Local cCgcEmp   := IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")
	Local aEmpresas := FwLoadSM0()
	Local oBkpJso   := Nil
	Local aVld      := {}
	Local aErros    := {}
	Local lVldCli   := .F.
	Local lVldProd  := .F.
	Local cCgcCli   := ""
	Local cEAN      := ""
	Local nQuant    := 0
	Local cTpInteg  := ""
	Local cTpOper   := ""  

	/**************************************************
	* força a gravação das informações de erro em 	*
	* array para manipulação da gravação ao invés 	*
	* de gravar direto no arquivo temporário		*
	**************************************************/
	Private lMsHelpAuto	:= .T.

	/**************************************************
	* força a gravação das informações de erro em 	*
	* array para manipulação da gravação ao invés 	*
	* de gravar direto no arquivo temporário 		*
	**************************************************/
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto := .F.

	nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == cCgcEmp })

	If nPosEmp == 0
		cJson := '{"Erro":"Empresa nao cadastrada."}'
		::SetResponse( cJson )
		Return .T.
	Else
		RpcClearEnv()
		RpcSetEnv(aEmpresas[nPosEmp][1],aEmpresas[nPosEmp][2])
	EndIf

	FWJsonDeserialize(cBody, @oJsoAux)

	SM0->(DbSetOrder(1))

	cQuery := " SELECT PR2.* FROM " + RetSqlName("PR2") + " (NOLOCK) PR2 "
	cQuery += " INNER JOIN " + RetSqlName("PR1") + " (NOLOCK) PR1 "
	cQuery += " ON PR2_FILIAL = PR1_FILIAL AND PR2_CODIGO = PR1_CODIGO "
	cQuery += " WHERE PR1_CODPZA = '000016' AND PR1.D_E_L_E_T_ = ' '  AND PR2.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	If len(oJsoAux:Pedidos) > 0

		cJson := "{"

		//Cria serviço no montitor
		aCriaServ := U_MonitRes("000016", 1, Len(oJsoAux:Pedidos) )   
		cIdPZB 	  := aCriaServ[2]

		For nX := 1 to len(oJsoAux:Pedidos)

			(cAlsQry)->(DbGoTop())

			_aCab      := {}

			aAdd(_aCab,   {"C5_FILIAL", xFilial("SC5"), nil})
			aAdd(_aCab,   {"C5_NUM", GetSXeNum("SC5","C5_NUM","C5_NUM"), nil})

			While !(cAlsQry)->(Eof())

				If SUBSTR(Alltrim((cAlsQry)->PR2_CPODES),1,2) == "C5"

					cCpo        := Alltrim((cAlsQry)->PR2_CPOORI)

					If (cAlsQry)->PR2_TPCONT == "1"
						cConteudo := &("oJsoAux:Pedidos[" + cValTochar(nX) + "]:" + cCpo)  
					Else
						cConteudo := &((cAlsQry)->PR2_CONTEU)
					EndIf

					If TAMSX3(AllTrim((cAlsQry)->PR2_CPODES))[3] == "D"
						cConteudo := StoD(cConteudo)
					EndIf

					aAdd(_aCab, {Alltrim((cAlsQry)->PR2_CPODES), cConteudo, nil})

				EndIf

				(cAlsQry)->(DbSkip())
			End

			(cAlsQry)->(DBGoTop())

			cCgcCli   := AllTrim(POSICIONE("SA1", 1, xFilial("SA1") + oJsoAux:Pedidos[nX]:CLIENTE + oJsoAux:Pedidos[nX]:LOJA  , "A1_CGC"))
			cTpInteg  := AllTrim(oJsoAux:Pedidos[nX]:TPINTEG)

			// --Valida cliente
			aVld := U_FATP013("Cli", cEmpAnt+cFilAnt, cCgcCli, "", "", .T., "", "")

			If aVld[1][1]
				lVldCli := .T.
			Else
				For nJ := 1 To Len(aVld[1][2])
					aAdd(aErros, {aVld[1][2][nJ]})
				Next nJ
			Endif

			For nY := 1 To Len(oJsoAux:Pedidos[nX]:Itens)

				cEAN      := AllTrim(POSICIONE("SB1", 1, xFilial("SB1") + oJsoAux:Pedidos[nX]:Itens[nY]:PRODUTO, "B1_CODBAR"))
				nQuant    := oJsoAux:Pedidos[nX]:Itens[nY]:QUANTIDADE
				cTpOper   := AllTrim(oJsoAux:Pedidos[nX]:Itens[nY]:TPOPER)

				//-- Valida produto
				aVld := U_FATP013("Prod", cEmpAnt+cFilAnt, cCgcCli, cEAN, nQuant, .T., cTpInteg, cTpOper)

				If aVld[1][1]
					lVldProd := .T.
				Else
					For nJ := 1 To Len(aVld[1][2])
						aAdd(aErros, {aVld[1][2][nJ]})
					Next nJ
				Endif

				If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

				(cAlsQry)->(DBGoTop())

				While !(cAlsQry)->(Eof())

					If SUBSTR(Alltrim((cAlsQry)->PR2_CPODES),1,2) == "C6"

						cCpo        := Alltrim((cAlsQry)->PR2_CPOORI)

						If (cAlsQry)->PR2_TPCONT == "1"
							cConteudo := &("oJsoAux:Pedidos[" + cValTochar(nX) + "]:Itens[" + cValTochar(nY) + "]:" + cCpo)  
						Else
							cConteudo := &((cAlsQry)->PR2_CONTEU)
						EndIf

						aAdd(_aAux, {Alltrim((cAlsQry)->PR2_CPODES), cConteudo, nil})

					EndIf

					(cAlsQry)->(DbSkip())
				End

				aAdd(_aItens,_aAux)
				_aAux := {}
				(cAlsQry)->(DBGoTop())

			Next nY

			If lVldCli .AND. lVldProd

				_aCab	:= FWVetByDic(_aCab,"SC5",.F.) //Organiza o array
				_aItens	:= FWVetByDic(_aItens,"SC6",.T.) //Organiza o array

				MSExecAuto({|x,y,z| MATA410(x,y,z)},_aCab,_aItens,3)

				::SetContentType("application/json")

				cMenssagem  := "Post Pedidos"

				If lMsErroAuto

					cStrErro := ""

					aErros 	:= GetAutoGRLog() // retorna o erro encontrado no execauto.
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

					U_MonitRes("000016", 2, , cIdPZB, cMenssagem, .F., cStrErro, "", cBody, "", .F., .F.)

					//Finaliza o processo na PZB
					U_MonitRes("000016", 3, , cIdPZB, , .F.)

					cJson += '"pedidos":['
					cJson += "{" 
					cJson += '"result' + cValTochar(nX) + '":"' + cStrErro + '",'
					cJson += '"lret' + cValTochar(nX) + '":false,'
					cJson += '"pedido":"' + SC5->C5_NUM + '"'
					cJson += "},"

				Else

					ConfirmSx8()

					U_MonitRes("000016", 2, , cIdPZB, cMenssagem, .T., "Pedido incluso com sucesso", "", cBody, "", .F., .F.)

					//Finaliza o processo na PZB
					U_MonitRes("000016", 3, , cIdPZB, , .T.)

					cJson += '"pedidos":['
					cJson += "{" 
					cJson += '"lret' + cValTochar(nX) + '":true,'
					cJson += '"pedido":"' + SC5->C5_NUM + '"' //corrigido caio menezes - 28/01/2020
					cJson += "},"

				EndIf

				cJson := Left(cJson, Rat(",", cJson)-1)
				cJson += "]}"

			Else

				cMenssagem  := "Post Pedidos"

				U_MonitRes("000016", 2, , cIdPZB, cMenssagem, .F., "", "", cBody, "", .F., .F.)

				//Finaliza o processo na PZB
				U_MonitRes("000016", 3, , cIdPZB, , .F.)

				cJson += '"pedidos":['
				cJson += "{" 
				cJson += '"lret1": false,'
				cJson += '"result" : "Nao foi possivel gerar o pedido",'
				cJson += '"motivos": ['
				cJson += "{"

				For nK = 1 To Len(aErros)
					If nK == Len(aErros)
						cJson += '"motivo' + cValTochar(nK) + '":"' + aErros[nK][1][1] + '"'
					Else
						cJson += '"motivo' + cValTochar(nK) + '":"' + aErros[nK][1][1] + '",'
					Endif
				Next

				cJson += "}"
				cJson += "]"
				cJson += "}"
				cJson += "]"
				cJson += "}"

			EndIf

			::SetResponse( cJson )

		Next nX

	EndIf

//(cAlsQry)->(dbCloseArea())

Return(.T.)

WsRestFul GetVend Description "Metodo Responsavel por Retornar Cadastro de Vendedor"

WsData cCgcVen		As String Optional
WsData cCgcEmp      As String Optional

WsData nPage        As float Optional

WsMethod Get Description "Cadastro de Vendedor" WsSyntax "/GetVend"

End WsRestFul

WsMethod Get WsReceive cCgcVen, cCgcEmp, nPage WsService GetVend

	Local cJson     := ""
	Local cQuery    := ""   
	Local cIdPZB	:= "" 
	Local cQryRes   := ""

	Local nX		:= 0
	Local nY		:= 0
	Local nDE		:= 0
	Local nPags		:= 0
	Local nLine     := 1
	Local nCount    := 1
	Local nPosEmp	:= 0
	Local nQtdPag	:= 0

	Local aCpos     := {}
	Local cPagsAux	:= ""
	Local aCposCab  := {}
	Local cConteudo := ""
	Local aCriaServ := {}
	Local aEmpresas := FwLoadSM0()

	Local cCgcVen   := IIf(::cCgcVen <> Nil , ::cCgcVen , "")
	Local cCgcEmp   := IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")
	Local nPage		:= IIf(::nPage <> Nil, ::nPage, 1)

	Private cAlsQry   := CriaTrab(Nil,.F.)
	Private cAlsRes   := CriaTrab(Nil,.F.)

	nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == cCgcEmp })

	If nPosEmp == 0
		cJson := '{"Erro":"Empresa nao cadastrada."}'
		::SetResponse( cJson )
		Return .T.
	Else
		RpcClearEnv()
		RpcSetEnv(aEmpresas[nPosEmp][1],aEmpresas[nPosEmp][2])
	EndIf   

	nPags	:= GetMV("FT_QTPAGIC",,10)

	cQuery 	:= " SELECT PR2.* FROM " + RetSqlName("PR2") + " (NOLOCK) PR2 "
	cQuery 	+= " INNER JOIN " + RetSqlName("PR1") + " (NOLOCK) PR1 "
	cQuery 	+= " ON PR2_FILIAL = PR1_FILIAL AND PR2_CODIGO = PR1_CODIGO "
	cQuery 	+= " WHERE PR1_CODPZA = '000017' AND PR1.D_E_L_E_T_ = ' '  AND PR2.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	While !(cAlsQry)->(Eof())

		If nCount == 1
			cQryRes := " SELECT  "
			cQryRes += (cAlsQry)->PR2_CPODES 

		Else
			cQryRes += " , " + (cAlsQry)->PR2_CPODES  

		EndIf

		AADD(aCpos, Alltrim((cAlsQry)->PR2_CPODES) )
		AADD(aCposCab, Alltrim((cAlsQry)->PR2_CPOORI))

		nCount++
		(cAlsQry)->(DbSkip())

	End

	If !Empty(cQryRes)

		cQryRes += " FROM " + RetSqlName("SA3") + " (NOLOCK) SA3 "
		cQryRes += " WHERE "

		If !Empty(cCgcVen)
			cQryRes += " A3_CGC = '" + cCgcVen + "' AND "
		EndIf

		cQryRes += " SA3.D_E_L_E_T_ = ' ' "

		If Select(cAlsRes) > 0; (cAlsRes)->(dbCloseArea()); Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryRes),cAlsRes,.T.,.T.)

		nQtdReg		:= Contar(cAlsRes,"!Eof()")
		nQtdPag		:= (nQtdReg/nPags)
		cPagsAux	:= cValToChar(nQtdPag)

		If SUBSTR(cPagsAux,1,1) == "0"
			nQtdPag := 1    			
		ElseIf At(".",cPagsAux) <> 0 
			nQtdPag := Val(SUBSTR(cPagsAux,1,( At(".",cPagsAux)-1 )))
			nQtdPag++
		Else
			nQtdPag := Val(cPagsAux)
		EndIf		

		If Empty(cCgcVen)

			(cAlsRes)->(DbGoTop())

			nDE := ((nPage*nPags) - nPags)

			For nY := 0 To nDE
				(cAlsRes)->(DBSkip())
			Next nY

		Else
			(cAlsRes)->(DbGoTop())
		EndIf

		While !(cAlsRes)->(Eof()) 

			If nLine == 1

				//Cria serviço no montitor
				aCriaServ := U_MonitRes("000017", 1, nQtdReg)   
				cIdPZB 	  := aCriaServ[2]

				cJson := '{"vendedores":['

			EndIf

			cJson += "{"

			For nX := 1 to Len(aCpos)

				If nX < Len(aCpos)
					cConteudo := & ("(cAlsRes)->" + aCpos[nX])

					If ValType( cConteudo) == "N"
						cJson += '"' + aCposCab[nX] + '":'
						cJson += cValTochar(cConteudo)
					Else
						cConteudo   := Alltrim(cConteudo)
						cJson       += '"' + aCposCab[nX] + '":'
						cJson       += '"' + cConteudo + '"'
					EndIf

					cJson += ','
				Else
					cConteudo   := & ("(cAlsRes)->" + aCpos[nX])

					If ValType( cConteudo) == "N"
						cJson += '"' + aCposCab[nX] + '":'
						cJson += cValTochar(cConteudo)
					Else
						cConteudo   := Alltrim(cConteudo)
						cJson       += '"' + aCposCab[nX] + '":'
						cJson       += '"' + cConteudo + '"'
					EndIf

				EndIf

			Next nX

			cJson += ','
			cJson += '"NumeroPaginas":"'+ cValToChar(nQtdPag) +'",'

			If nPage == nQtdPag
				cJson += '"IsLastPage":true,
			Else
				cJson += '"IsLastPage":false,
			EndIf

			cJson += '"lret' + cValTochar(nLine) + '":true'
			cJson += "},"

			cMenssagem  := "Get realizado com sucesso."
			U_MonitRes("000017", 2, , cIdPZB, cMenssagem, .T., "Get de vendedores", cJson, "", "", .F., .F.)

			nLine++

			(cAlsRes)->(DbSkip())

			If nPage = 0 .OR. !Empty(cCgcVen) 
				If (cAlsRes)->(Eof())
					cJson := Left(cJson, Rat(",", cJson)-1)
					Exit
				EndIf
			Else
				If nLine == (nPags + 1) .Or. (cAlsRes)->(Eof())
					cJson := Left(cJson, Rat(",", cJson)-1)
					Exit
				EndIf
			EndIf
		End

		(cAlsRes)->(dbCloseArea())

		If Empty(cJson) 

			cJson += "{"
			cJson += '"vendedores":['
			cJson += "{" 
			cJson += '"errorMessage' + cValTochar(1) + '":"'+ "vendedores nao encontrado" +'",'
			cJson += '"lret' + cValTochar(1) + '":false'
			cJson += "},"

		EndIf

		//Finaliza o processo na PZB
		U_MonitRes("000017", 3, , cIdPZB, , .T.)

	EndIf

cJson += "]}"

(cAlsQry)->(dbCloseArea())

::SetContentType("application/json")
::SetResponse( cJson )

Return(.T.)


WsRestFul GetTab Description "Metodo Responsavel por Consulta de Tabela de Preços"

WsData dVigAte		As Date Optional
WsData dVigDe		As Date Optional 
WsData cCodTab      As String Optional
WsData cCgcEmp		As String Optional
WsData cCodProd     As String Optional
WsData nPage        As Float Optional

WsMethod Get Description "Tabela de Preços" WsSyntax "/GetTab"

End WsRestFul

WsMethod Get WsReceive cCgcEmp, cCodProd, cCodTab, dDataDe, dDataAte, nPage WsService GetTab

	Local cForn		:= ""
	Local cLoja		:= ""
	Local cJson     := ""
	Local cQuery    := "" 
	Local cChave	:= ""  
	Local cIdPZB	:= "" 
	Local cQryRes   := ""

	Local nX		:= 0
	Local nY		:= 0
	Local nDE		:= 0
	Local nPags		:= 0
	Local nLine     := 1
	Local nCount    := 1
	Local nPosEmp	:= 0
	Local nQtdPag	:= 0

	Local aCpos     := {}
	Local cPagsAux	:= ""
	Local aCposCab  := {}
	Local cConteudo := ""
	Local aCriaServ := {}
	Local aEmpresas := FwLoadSM0()

	Local dVigAte	:= IIf(::dVigAte <> Nil , ::dVigAte , "")
	Local dVigDe	:= IIf(::dVigDe <> Nil , ::dVigDe , "")
	Local cCodProd	:= IIf(::cCodProd <> Nil , ::cCodProd , "")
	Local cCodTab	:= IIf(::cCodTab <> Nil , ::cCodTab , "")
	Local cCgcEmp   := IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")
	Local nPage		:= IIf(::nPage <> Nil, ::nPage, 1)

	Private cAlsQry   := CriaTrab(Nil,.F.)
	Private cAlsRes   := CriaTrab(Nil,.F.)

	nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == cCgcEmp })

	If nPosEmp == 0
		cJson := '{"Erro":"Empresa nao cadastrada."}'
		::SetResponse( cJson )
		Return .T.
	Else
		RpcClearEnv()
		RpcSetEnv(aEmpresas[nPosEmp][1],aEmpresas[nPosEmp][2])
	EndIf   


	nPags	:= GetMV("FT_QTPAGIC",,10)

	cQuery 	:= " SELECT PR2.* FROM " + RetSqlName("PR2") + " (NOLOCK) PR2 "
	cQuery 	+= " INNER JOIN " + RetSqlName("PR1") + " (NOLOCK) PR1 "
	cQuery 	+= " ON PR2_FILIAL = PR1_FILIAL AND PR2_CODIGO = PR1_CODIGO "
	cQuery 	+= " WHERE PR1_CODPZA = '000018' AND PR1.D_E_L_E_T_ = ' '  AND PR2.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	While !(cAlsQry)->(Eof())

		If nCount == 1
			cQryRes := " SELECT  "
			cQryRes += (cAlsQry)->PR2_CPODES 

		Else
			cQryRes += " , " + (cAlsQry)->PR2_CPODES  

		EndIf

		AADD(aCpos, Alltrim((cAlsQry)->PR2_CPODES) )
		AADD(aCposCab, Alltrim((cAlsQry)->PR2_CPOORI))

		nCount++
		(cAlsQry)->(DbSkip())

	End

	If !Empty(cQryRes)

		cQryRes += " FROM " + RetSqlName("DA0") + " (NOLOCK) DA0 "
		cQryRes += " INNER JOIN " + RetSqlName("DA1") + " (NOLOCK) DA1 "
		cQryRes += " ON DA1_FILIAL = '" + xFilial("DA1") + "' "  
		cQryRes += " AND DA0_CODTAB = DA1_CODTAB "
		cQryRes += " WHERE "

		//TABELA
		If !Empty(cCodTab)
			cQryRes += " DA0_CODTAB = '" + AllTrim(cCodTab) + "' AND "
		EndIf 

		//DATA
		If !Empty(dVigDe)
			cQryRes += " DA0_DATDE >= '" + DtoS(dDataDe) + "' AND "
		EndIf

		If !Empty(dVigAte)
			cQryRes += " DA0_DATATE <= '" + DtoS(dDataAte) + "' AND "
		EndIf

		//PRODUTO
		If !Empty(cCodProd)
			cQryRes += " DA1_CODPRO = '" + AllTrim(cCodProd) + "' AND "
		EndIf

		cQryRes += " DA0.D_E_L_E_T_ = ' ' AND "
		cQryRes += " DA1.D_E_L_E_T_ = ' ' "
		cQryRes += " ORDER BY DA0_FILIAL, DA0_CODTAB "

		If Select(cAlsRes) > 0; (cAlsRes)->(dbCloseArea()); Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryRes),cAlsRes,.T.,.T.)

		nQtdReg		:= Contar(cAlsRes,"!Eof()")
		nQtdPag		:= (nQtdReg/nPags)
		cPagsAux	:= cValToChar(nQtdPag)

		If SUBSTR(cPagsAux,1,1) == "0"
			nQtdPag := 1    			
		ElseIf At(".",cPagsAux) <> 0 
			nQtdPag := Val(SUBSTR(cPagsAux,1,( At(".",cPagsAux)-1 )))
			nQtdPag++
		Else
			nQtdPag := Val(cPagsAux)
		EndIf		

		If Empty(cCodTab)

			(cAlsRes)->(DbGoTop())

			nDE := ((nPage*nPags) - nPags)

			For nY := 0 To nDE
				(cAlsRes)->(DBSkip())
			Next nY

		Else
			(cAlsRes)->(DbGoTop())
		EndIf

		While !(cAlsRes)->(Eof()) 

			If nLine == 1

				//Cria serviço no montitor
				aCriaServ := U_MonitRes("000018", 1, nQtdReg)   
				cIdPZB 	  := aCriaServ[2]

				cJson := '{"tabelas":['

			EndIf

			cJson += "{"

			For nX := 1 to Len(aCpos)

				If SUBSTR(aCpos[nX],1,3) <> "DA1"   
					If nX < Len(aCpos)
						cConteudo := & ("(cAlsRes)->" + aCpos[nX])

						If ValType( cConteudo) == "N"
							cJson += '"' + aCposCab[nX] + '":'
							cJson += cValTochar(cConteudo)
						Else
							cConteudo   := Alltrim(cConteudo)
							cJson       += '"' + aCposCab[nX] + '":'
							cJson       += '"' + cConteudo + '"'
						EndIf

						cJson += ','
					Else
						cConteudo   := & ("(cAlsRes)->" + aCpos[nX])

						If ValType( cConteudo) == "N"
							cJson += '"' + aCposCab[nX] + '":'
							cJson += cValTochar(cConteudo)
						Else
							cConteudo   := Alltrim(cConteudo)
							cJson       += '"' + aCposCab[nX] + '":'
							cJson       += '"' + cConteudo + '"'
						EndIf

					EndIf
				EndIf        
			Next nX

			cJson += '"NumeroPaginas":"'+ cValToChar(nQtdPag) +'",'

			If nPage == nQtdPag
				cJson += '"IsLastPage":true,
			Else
				cJson += '"IsLastPage":false,
			EndIf

			cJson += '"lret' + cValTochar(nLine) + '":true,'

			cChave := (cAlsRes)->DA1_CODTAB
			cChave += (cAlsRes)->DA1_FILIAL

			cJson += '"itens":['

			While cChave == ((cAlsRes)->DA1_CODTAB + (cAlsRes)->DA1_FILIAL) 
				cJson += "{"         
				For nX := 1 to Len(aCpos)

					If SUBSTR(aCpos[nX],1,3) == "DA1"    
						If nX < Len(aCpos)
							cConteudo := & ("(cAlsRes)->" + aCpos[nX])

							If ValType( cConteudo) == "N"
								cJson += '"' + aCposCab[nX] + '":'
								cJson += cValTochar(cConteudo)
							Else
								cConteudo   := Alltrim(cConteudo)
								cJson       += '"' + aCposCab[nX] + '":'
								cJson       += '"' + cConteudo + '"'
							EndIf

							cJson += ','
						Else
							cConteudo   := & ("(cAlsRes)->" + aCpos[nX])

							If ValType( cConteudo) == "N"
								cJson += '"' + aCposCab[nX] + '":'
								cJson += cValTochar(cConteudo)
							Else
								cConteudo   := Alltrim(cConteudo)
								cJson       += '"' + aCposCab[nX] + '":'
								cJson       += '"' + cConteudo + '"'
							EndIf

						EndIf
					EndIf    
				Next nX
				cJson += "},"
				(cAlsRes)->(DbSkip())
			EndDo

			cJson := Left(cJson, Rat(",", cJson)-1)
			cJson += "]"
			cJson += "},"

			cMenssagem  := "Get realizado com sucesso."
			U_MonitRes("000018", 2, , cIdPZB, cMenssagem, .T., "Get de Tabela", "", "", "", .F., .F.)

			nLine++

			If nPage = 0 .OR. !Empty(cCodTab) 
				If (cAlsRes)->(Eof())
					cJson := Left(cJson, Rat(",", cJson)-1)
					Exit
				EndIf
			Else
				If nLine == (nPags + 1) .Or. (cAlsRes)->(Eof())
					cJson := Left(cJson, Rat(",", cJson)-1)
					Exit
				EndIf
			EndIf
		End

		(cAlsRes)->(dbCloseArea())

		If Empty(cJson) 

			cJson += "{"
			cJson += '"tabelas":['
			cJson += "{" 
			cJson += '"errorMessage' + cValTochar(1) + '":"'+ "entradas nao encontrado" +'",'
			cJson += '"lret' + cValTochar(1) + '":false'
			cJson += "},"

		EndIf

		//Finaliza o processo na PZB
		U_MonitRes("000018", 3, , cIdPZB, , .T.)

	EndIf

cJson += "]}"

(cAlsQry)->(dbCloseArea())

::SetContentType("application/json")
::SetResponse( cJson )

Return(.T.)


WsRestFul PostPC Description "Metodo Responsavel por Cadastrar Pedidos de Compra"

WsData cCgcEmp		As String

WsMethod Post Description "Cadastro de Pedidos de Compra" WsSyntax "/PostPC"

End WsRestFul

WsMethod Post WsReceive cCgcEmp WsService PostPC

	Local cBody     := ::GetContent()
	Local oJsoAux   := Nil
	Local cQuery    := ""
	Local oLoc		:= Nil
	Local cLoc		:= ""
	Local cAlsQry   := CriaTrab(Nil,.F.)
	Local nX
	Local nY
	Local cStrErro  := ""
	Local cEstado	:= ""
	Local aDados    := {}
	Local _aAux		:= {}
	Local _aCab	    := {}
	Local _aItens	:= {}
	Local aCriaServ := {}
	Local nErro     := 0
	Local cJson     := ""
	Local cCgcEmp   := IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")
	Local aEmpresas := FwLoadSM0()
	Local oBkpJso   := Nil

	/**************************************************
	* força a gravação das informações de erro em 	*
	* array para manipulação da gravação ao invés 	*
	* de gravar direto no arquivo temporário		*
	**************************************************/
	Private lMsHelpAuto	:= .T.

	/**************************************************
	* força a gravação das informações de erro em 	*
	* array para manipulação da gravação ao invés 	*
	* de gravar direto no arquivo temporário 		*
	**************************************************/
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto := .F.

	nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == cCgcEmp })

	If nPosEmp == 0
		cJson := '{"Erro":"Empresa nao cadastrada."}'
		::SetResponse( cJson )
		Return .T.
	Else
		RpcClearEnv()
		RpcSetEnv(aEmpresas[nPosEmp][1],aEmpresas[nPosEmp][2])
	EndIf

	FWJsonDeserialize(cBody, @oJsoAux)

	SM0->(DbSetOrder(1))

	cQuery := " SELECT PR2.* FROM " + RetSqlName("PR2") + " (NOLOCK) PR2 "
	cQuery += " INNER JOIN " + RetSqlName("PR1") + " (NOLOCK) PR1 "
	cQuery += " ON PR2_FILIAL = PR1_FILIAL AND PR2_CODIGO = PR1_CODIGO "
	cQuery += " WHERE PR1_CODPZA = '000019' AND PR1.D_E_L_E_T_ = ' '  AND PR2.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	If len(oJsoAux:Pedidos) > 0

		cJson := "{"

		//Cria serviço no montitor
		aCriaServ := U_MonitRes("000019", 1, Len(oJsoAux:Pedidos) )   
		cIdPZB 	  := aCriaServ[2]

		For nX := 1 to len(oJsoAux:Pedidos)

			(cAlsQry)->(DbGoTop())

			_aCab      := {}

			aAdd(_aCab,   {"C7_FILIAL", xFilial("SC7"), nil})
			aAdd(_aCab,   {"C7_NUM", GetSXeNum("SC7","C7_NUM","C7_NUM"), nil})

			While !(cAlsQry)->(Eof())

				If (cAlsQry)->PR2_STRUTU == "1"

					cCpo        := Alltrim((cAlsQry)->PR2_CPOORI)

					If (cAlsQry)->PR2_TPCONT == "1"
						cConteudo := &("oJsoAux:Pedidos[" + cValTochar(nX) + "]:" + cCpo)  
					Else
						cConteudo := &((cAlsQry)->PR2_CONTEU)
					EndIf

					aAdd(_aCab, {Alltrim((cAlsQry)->PR2_CPODES), cConteudo, nil})

				EndIf

				(cAlsQry)->(DbSkip())
			End

			(cAlsQry)->(DBGoTop())

			For nY := 1 To Len(oJsoAux:Pedidos[nX]:Itens)

				While !(cAlsQry)->(Eof())

					If (cAlsQry)->PR2_STRUTU == "2"

						cCpo        := Alltrim((cAlsQry)->PR2_CPOORI)

						If (cAlsQry)->PR2_TPCONT == "1"
							cConteudo := &("oJsoAux:Pedidos[" + cValTochar(nX) + "]:Itens[" + cValTochar(nY) + "]:" + cCpo)  
						Else
							cConteudo := &((cAlsQry)->PR2_CONTEU)
						EndIf

						aAdd(_aAux, {Alltrim((cAlsQry)->PR2_CPODES), cConteudo, nil})

					EndIf

					(cAlsQry)->(DbSkip())
				End

				aAdd(_aItens,_aAux)
				_aAux := {}
				(cAlsQry)->(DBGoTop())

			Next nY

			_aCab	:= FWVetByDic(aDados,"SC7",.F.) //Organiza o array
			_aItens	:= FWVetByDic(aDados,"SC7",.F.) //Organiza o array

			MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,_aCab,_aItens,3)

			::SetContentType("application/json")

			cMenssagem  := "Post Pedidos"

			If lMsErroAuto

				cStrErro := ""

				aErros 	:= GetAutoGRLog() // retorna o erro encontrado no execauto.
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

				U_MonitRes("000019", 2, , cIdPZB, cMenssagem, .F., cStrErro, "", cBody, "", .F., .F.)

				//Finaliza o processo na PZB
				U_MonitRes("000019", 3, , cIdPZB, , .F.)

				cJson += '"pedidos":['
				cJson += "{" 
				cJson += '"errorMessage' + cValTochar(nX) + '":"' + cStrErro + '",'
				cJson += '"lret' + cValTochar(nX) + '":false'
				cJson += "},"

			Else

				ConfirmSx8()

				U_MonitRes("000019", 2, , cIdPZB, cMenssagem, .T., "Pedido incluso com sucesso", "", cBody, "", .F., .F.)

				//Finaliza o processo na PZB
				U_MonitRes("000019", 3, , cIdPZB, , .T.)

				cJson += '"pedidos":['
				cJson += "{" 
				cJson += '"lret' + cValTochar(nX) + '":true'
				cJson += "},"

			EndIf

		Next nX

		cJson := Left(cJson, Rat(",", cJson)-1)
		cJson += "]}"

		::SetResponse( cJson )

	EndIf

(cAlsQry)->(dbCloseArea())

Return(.T.)






WsRestFul GetPrePed Description "Metodo Responsavel por Pre Pedidos"

WsData cCgcEmp      As String Optional
WsData cPrePed      As String Optional
WsData nPage        As Float Optional
WsData cCgcCli		As String Optional

WsMethod Get Description "Pre Pedidos" WsSyntax "/GetPrePed"

End WsRestFul

WsMethod Get WsReceive cCgcEmp, cPrePed WsService GetPrePed

	Local cCli		:= ""
	Local cLoja		:= ""
	Local cJson     := ""
	Local cQuery    := ""   
	Local cIdPZB	:= "" 
	Local cQryRes   := ""

	Local nX		:= 0
	Local nY		:= 0
	Local nDE		:= 0
	Local nPags		:= 0
	Local nLine     := 1
	Local nCount    := 1
	Local nPosEmp	:= 0
	Local nQtdPag	:= 0

	Local aCpos     := {}
	Local cPagsAux	:= ""
	Local aCposCab  := {}
	Local cConteudo := ""
	Local aCriaServ := {}
	Local aEmpresas := FwLoadSM0()



	Local cPrePed	:= IIf(::cPrePed <> Nil , ::cPrePed , "")
	Local cCgcEmp   := IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")
	Local nPage		:= IIf(::nPage <> Nil, ::nPage, 1)
	Local cCgcCli   := IIf(::cCgcCli <> Nil , ::cCgcCli , "")

	Private cAlsQry   := CriaTrab(Nil,.F.)
	Private cAlsRes   := CriaTrab(Nil,.F.)

	nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == Alltrim(cCgcEmp) })

	If nPosEmp == 0
		cJson := '{"Erro":"Empresa nao cadastrada."}'
		::SetResponse( cJson )
		Return .T.
	Else
		RpcClearEnv()
		RpcSetEnv(aEmpresas[nPosEmp][1],aEmpresas[nPosEmp][2])
	EndIf   


	If !Empty(cCgcCli)
		DBSelectArea("SA1")
		SA1->(DBSetOrder(3))	
		If SA1->(DBSeek(xFilial("SA1") + cCgcCli))
			cCli	:= SA1->A1_COD

		Else
			cJson := '{Cliente nao Encontrado.}'
			::SetResponse( cJson )
			Return .T.
		EndIf
	EndIf

	nPags	:= GetMV("FT_QTPAGIC",,10)

	cQuery 	:= " SELECT PR2.* FROM " + RetSqlName("PR2") + " (NOLOCK) PR2 "
	cQuery 	+= " INNER JOIN " + RetSqlName("PR1") + " (NOLOCK) PR1 "
	cQuery 	+= " ON PR2_FILIAL = PR1_FILIAL AND PR2_CODIGO = PR1_CODIGO "
	cQuery 	+= " WHERE PR1_CODPZA = '000020' AND PR1.D_E_L_E_T_ = ' '  AND PR2.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	While !(cAlsQry)->(Eof())

		If nCount == 1
			cQryRes := " SELECT  "
			cQryRes += (cAlsQry)->PR2_CPODES 

		Else
			cQryRes += " , " + (cAlsQry)->PR2_CPODES  

		EndIf

		AADD(aCpos, Alltrim((cAlsQry)->PR2_CPODES) )
		AADD(aCposCab, Alltrim((cAlsQry)->PR2_CPOORI))

		nCount++
		(cAlsQry)->(DbSkip())

	End

	If !Empty(cQryRes)

		cQryRes += " FROM ZR9980 (NOLOCK) ZR9 "
		cQryRes += " WHERE ZR9_NUMERO = '" + AvKey(cPrePed,"ZR9_NUMERO") + "'"
		cQryRes += " AND ZR9.D_E_L_E_T_ = ' ' "

		If !Empty(cCgcCli)
			cQryRes += " AND ZR9_CLIENT = '" + cCli + "' "
		EndIf

		If Select(cAlsRes) > 0; (cAlsRes)->(dbCloseArea()); Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryRes),cAlsRes,.T.,.T.)

		nQtdReg		:= Contar(cAlsRes,"!Eof()")
		nQtdPag		:= (nQtdReg/nPags)
		cPagsAux	:= cValToChar(nQtdPag)

		If SUBSTR(cPagsAux,1,1) == "0"
			nQtdPag := 1    			
		ElseIf At(".",cPagsAux) <> 0 
			nQtdPag := Val(SUBSTR(cPagsAux,1,( At(".",cPagsAux)-1 )))
			nQtdPag++
		Else
			nQtdPag := Val(cPagsAux)
		EndIf		

		(cAlsRes)->(dbGoTop()) 

		While !(cAlsRes)->(Eof()) 

			If nLine == 1

				//Cria serviço no montitor
				aCriaServ := U_MonitRes("000020", 1, nQtdReg)   
				cIdPZB 	  := aCriaServ[2]

				cJson := '{"PrePedido":['

			EndIf

			cJson += "{"

			For nX := 1 to Len(aCpos)

				If nX < Len(aCpos)
					cConteudo := & ("(cAlsRes)->" + aCpos[nX])

					If ValType( cConteudo) == "N"
						cJson += '"' + aCposCab[nX] + '":'
						cJson += cValTochar(cConteudo)
					Else
						cConteudo   := Alltrim(cConteudo)
						cJson       += '"' + aCposCab[nX] + '":'
						cJson       += '"' + cConteudo + '"'
					EndIf

					cJson += ','
				Else
					cConteudo   := & ("(cAlsRes)->" + aCpos[nX])

					If ValType( cConteudo) == "N"
						cJson += '"' + aCposCab[nX] + '":'
						cJson += cValTochar(cConteudo)
					Else
						cConteudo   := Alltrim(cConteudo)
						cJson       += '"' + aCposCab[nX] + '":'
						cJson       += '"' + cConteudo + '"'
					EndIf

				EndIf

			Next nX

			cJson += ','
			cJson += '"NumeroPaginas":"'+ cValToChar(nQtdPag) +'",'

			If nPage == nQtdPag
				cJson += '"IsLastPage":true,
			Else
				cJson += '"IsLastPage":false,
			EndIf

			cJson += '"lret' + cValTochar(nLine) + '":true'
			cJson += "},"

			cMenssagem  := "Get realizado com sucesso."
			U_MonitRes("000020", 2, , cIdPZB, cMenssagem, .T., "Get Pre Pedidos", cJson, "", "", .F., .F.)

			nLine++

			(cAlsRes)->(DbSkip())

			If nPage = 0 .OR. !Empty(cCgcCli) 
				If (cAlsRes)->(Eof())
					cJson := Left(cJson, Rat(",", cJson)-1)
					Exit
				EndIf
			Else
				If nLine == (nPags + 1) .Or. (cAlsRes)->(Eof())
					cJson := Left(cJson, Rat(",", cJson)-1)
					Exit
				EndIf
			EndIf
		End

		(cAlsRes)->(dbCloseArea())

		If Empty(cJson) 

			cJson += "{"
			cJson += '"PrePedidos":['
			cJson += "{" 
			cJson += '"errorMessage' + cValTochar(1) + '":"'+ "pre-pedido não existe" +'",'
			cJson += '"lret' + cValTochar(1) + '":false'
			cJson += "},"

		EndIf

		//Finaliza o processo na PZB
		U_MonitRes("000020", 3, , cIdPZB, , .T.)

	EndIf

cJson += "]}"

(cAlsQry)->(dbCloseArea())

::SetContentType("application/json")
::SetResponse( cJson )

Return(.T.)

WsRestFul GetStruct Description "Metodo Responsavel por Obter Estrutura de Cadastro"

WsData cIdStruct    As String 

WsMethod Get Description "Estrutura de Cadastro" WsSyntax "/GetStruct"

End WsRestFul

WsMethod Get WsReceive cIdStruct WsService GetStruct

	Local cJson		:= ""
	Local cQuery	:= ""
	Local cAlsQry	:= CriaTrab(NIL,.F.)

	Local cIdStruct   := IIF(::cIdStruct <> Nil, ::cIdStruct, "")

	RPCClearEnv()
	RPCSetEnv("02","01")

	cQuery 	:= " SELECT PR2.* FROM " + RetSqlName("PR2") + " (NOLOCK) PR2 "
	cQuery 	+= " INNER JOIN " + RetSqlName("PR1") + " (NOLOCK) PR1 "
	cQuery 	+= " ON PR2_FILIAL = PR1_FILIAL AND PR2_CODIGO = PR1_CODIGO "
	cQuery 	+= " WHERE PR1_CODPZA = '" + AllTrim(cIdStruct) + "' AND PR1.D_E_L_E_T_ = ' '  AND PR2.D_E_L_E_T_ = ' ' "

	If SELECT(cAlsQry) > 0
		(cAlsQry)->(DBCloseArea()) 
	Endif

	DBUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	If (cAlsQry)->(EOF())

		cJson += "{" 
		cJson += '"cErrorMessage":"ID de Estrutura Incorreto.",'
		cJson += '"lSucess":false'
		cJson += "}"

		Return( .T. )

	Else
		cJson := "{" 	
	EndIf

	While (cAlsQry)->(!EOF())

		cJson += '"' + AllTrim((cAlsQry)->PR2_CPOORI) + '":"' + AllTrim((cAlsQry)->PR2_CPODES) + '",'

		(cAlsQry)->(DBSkip())

	EndDo

cJson := Left(cJson, Rat(",", cJson)-1)
cJson += "}"

(cAlsQry)->(dbCloseArea())

::SetContentType("application/json")
::SetResponse( cJson )

Return( .T. )

WsRestFul PostProdDG Description "Metodo Responsavel por Cadastrar e Alterar Produto"

WsData cCgcEmp		As String

WsMethod Post Description "Cadastro de Produto" WsSyntax "/PostProdDG"

End WsRestFul

WsMethod Post WsReceive cCgcEmp WsService PostProdDG

	Local cBody     := ::GetContent()
	Local cQuery	:= ""
	Local cAlsQry	:= CriaTrab(NIL,.F.)
	Local cConteudo	:= ""

	Local nX		:= 0
	Local nPosEmp	:= 0

	Local aDados	:= {}
	Local aEmpresas := FwLoadSM0()

	Local oJsoAux	:= NIL

	Local cCgcEmp   := IIF(::cCgcEmp <> Nil, ::cCgcEmp, "")

	nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == Alltrim(cCgcEmp) })

	If nPosEmp == 0

		cJson := '{'
		cJson += '"cErrorMessage":""Erro":"Empresa nao cadastrada.""'
		cJson += '}'

		::SetResponse( cJson )
		Return ( .T. )
	Else
		RpcClearEnv()
		RpcSetEnv(aEmpresas[nPosEmp][1],aEmpresas[nPosEmp][2])

	EndIf 

	cQuery 	:= " SELECT PR2.* FROM " + RetSqlName("PR2") + " (NOLOCK) PR2 "
	cQuery 	+= " INNER JOIN " + RetSqlName("PR1") + " (NOLOCK) PR1 "
	cQuery 	+= " ON PR2_FILIAL = PR1_FILIAL AND PR2_CODIGO = PR1_CODIGO "
	cQuery 	+= " WHERE PR1_CODPZA = '000006' AND PR1.D_E_L_E_T_ = ' '  AND PR2.D_E_L_E_T_ = ' ' "

	If SELECT(cAlsQry) > 0
		(cAlsQry)->(DBCloseArea()) 
	EndIf

	DBUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	FWJsonDeserialize(cBody, @oJsoAux)

	If Len(oJsoAux:TAB) > 0

		For nX := 1 To Len(oJsoAux:TAB)

			While (cAlsQry)->(!EOF())

				If AttIsMemberOf(oJsoAux:TAB[nX],AllTrim((cAlsQry)->PR2_CPODES))

					cConteudo := &("oJsoAux:TAB[" + cValTochar(nX) + "]:" + AllTrim((cAlsQry)->PR2_CPODES))
					AADD(aDados, {Alltrim((cAlsQry)->PR2_CPODES), cConteudo, NIL})

				EndIf

				(cAlsQry)->(DBSkip())

			EndDo

			aDados := FWVetByDic(aDados,"SB1",.F.) //Organiza o array
			MSExecAuto({|x,y| MATA010(x,y)},aDados,3)

			aDados := {}
			(cAlsQry)->(DBGoTop())

		Next nX

	EndIf

	cJson := '{'
	cJson += '"lSucess":true'
	cJson += '}'

	::SetContentType("application/json")
	::SetResponse( cJson )

Return ( .T. )



//--- Metodo construido para Retornar os 10 produtos mais comprados por um cliente
//--- Carlos E. Chigres  /  28/01/2020
WsRestFul GetMais Description "Metodo Responsavel por Retornar os dez produtos mais comprados por um cliente"

WsData cCgcCli		As String Optional
//WsData cCgcEmp     As String Optional

WsData nPage       As float Optional

WsMethod Get Description "Dez produtos mais comprados" WsSyntax "/GetMais"

End WsRestFul

WsMethod Get WsReceive cCgcCli, cCgcEmp, nPage WsService GetMais

	Local cJson     := ""
	Local cQuery    := ""   
	Local cQryRes   := ""
	Local cIdPZB	:= ""  
	Local cAlsQry   := CriaTrab(Nil,.F.)

	Local nX		:= 0
	Local nPags		:= 0
	Local nLine     := 1
	Local nCount    := 1
	Local nPosEmp	:= 0
	Local nQtdPag	:= 0

	Local aCpos     := {}
	Local cPagsAux	:= ""
	Local aCposCab  := {}
	Local aDados    := {}
	Local cConteudo := ""
	Local aCriaServ := {}
	Local aCont     := {}
	Local aEmp      := {}
	Local aEmpresas := FwLoadSM0()
	Local cEmpA1    := ''
	Local cFilEnt   := SuperGetMV("EF_PRCEMPS",.F., "07#10#11#12")

	Local cCgcCli   := IIf(::cCgcCli <> Nil , ::cCgcCli , "")
	//Local cCgcEmp   := IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")
	Local nPage		:= IIf(::nPage <> Nil, ::nPage, 1)

	Local cCodCli   := ""
	Local cCodLoja  := ""

	RpcClearEnv()
	RpcSetEnv('98','01')

	nPags := GetMV("FT_QTPAGIC",,10)


	For n := 1 to Len(aEmpresas)

		If  n> 1
			If aEmpresas[n-1][1] == aEmpresas[n][1]
				Loop
			Endif
		Endif

		If aEmpresas[n][1] $ cFilEnt 
			aAdd(aEmp,{aEmpresas[n][1],aEmpresas[n][2]})
		Else
			Loop
		Endif 
	Next

	//----------------------------------------------------------------
	//--- Select sobre as Tabelas de Integracao - novo codigo = 000022
	//----------------------------------------------------------------

	cQuery := " SELECT PR2.* FROM " + RetSqlName("PR2") + " (NOLOCK) PR2 "
	cQuery += " INNER JOIN " + RetSqlName("PR1") + " (NOLOCK) PR1 "
	cQuery += " ON PR2_FILIAL = PR1_FILIAL AND PR2_CODIGO = PR1_CODIGO "
	cQuery += " WHERE PR1_CODPZA = '000022' AND PR1.D_E_L_E_T_ = ' '  AND PR2.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	While !(cAlsQry)->(Eof())

		If nCount == 1

			cQryRes := " SELECT  "
			cQryRes += (cAlsQry)->PR2_CPODES 

		Else

			cQryRes += " , " + (cAlsQry)->PR2_CPODES  

		EndIf

		AADD( aCpos   , Alltrim( (cAlsQry)->PR2_CPODES ))
		AADD( aCposCab, Alltrim( (cAlsQry)->PR2_CPOORI ))

		If (cAlsQry)->PR2_ISFUNC == "S"
			AADD(aCont, Alltrim( (cAlsQry)->PR2_CONTEU ))
		Else
			AADD(aCont, "")
		EndIf

		nCount++
		(cAlsQry)->(DbSkip())

	Enddo
	// Close Select 
	(cAlsQry)->( dbCloseArea() )

	//------------------------------------------------------------------
	// Importante: D2_COD precisa fazer parte do conjunto de Campos
	//           : Eh Chave para (quase) todos os outros
	//------------------------------------------------------------------
	If aScan( aCpos, { |x| x == "D2_COD" } ) == 0
		Aadd( aCpos   , "D2_COD" )
		Aadd( aCposCab, AllTrim( GetTitu( "D2_COD" ) ) )
		Aadd( aCont, "" )
	EndIf

	//------------------------------------------------------------------
	// Select partindo de SD2, vinculado a SF2, com GROUP BY por D2_COD
	//------------------------------------------------------------------

	cQuery := ''

	For nXx := 1 to Len(aEmp)

		If aEmp[nXx][1] == '02'
			cEmpA1 := '02'
		Else
			cEmpA1 := '98'
		Endif 

		cQuery 	+= " SELECT  "
		cQuery 	+= " TOP(10) D2_COD, "
		cQuery 	+= " Sum(D2_QUANT) AS TOTAL " 
		cQuery 	+= " FROM  "
		cQuery 	+= " SD2" + aEmp[nXx][1] + "0  SD2 (NOLOCK) " 
		cQuery 	+= " INNER JOIN SA1" + cEmpA1 + "0 SA1 (NOLOCK) ON A1_COD = D2_CLIENTE " 
		cQuery 	+= " AND A1_LOJA = D2_LOJA  "
		cQuery 	+= " AND SA1.d_e_l_e_t_ = ' ' " 
		cQuery 	+= " LEFT OUTER JOIN ZAR980 (NOLOCK) AS ZAR ON ( "
		cQuery 	+= " ZAR_CFOP = D2_CF  "
		cQuery 	+= " AND ZAR.d_e_l_e_t_ = '' "
		cQuery 	+= " ) "
		cQuery 	+= " WHERE "
		cQuery 	+= " SD2.d_e_l_e_t_ = ' '" 
		cQuery 	+= " AND A1_CGC = '" + cCgcCli + "'"
		cQuery 	+= " AND D2_TIPO = 'N'"
		cQuery 	+= " AND ZAR_IMS = 'S' "
		cQuery 	+= " AND D2_EMISSAO > YEAR(GETDATE()) - 1"
		cQuery 	+= " GROUP BY "
		cQuery 	+= " D2_COD "
		cQuery  += " ORDER BY  Sum(D2_QUANT) DESC   "

		If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

		While !(cAlsQry)->(Eof())
			AADD( aDados, { (cAlsQry)->D2_COD, ' ' } )
			(cAlsQry)->( dbSkip() )		
		Enddo

		If Len(aDados) == 10
			Exit
		Endif

		/* 
		If  nXx < Len(aEmp)
		cQuery += ' UNION '
		Else
		cQuery += " ORDER BY  Sum(D2_QUANT) DESC   "
		Endif 
		*/

	Next nXx

	//If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif

	//dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	/*
	While !(cAlsQry)->(Eof())

	AADD( aDados, { (cAlsQry)->D2_COD, ' ' } )

	(cAlsQry)->( dbSkip() )

	Enddo
	*/

	//--- Page Managing
	nQtdReg		:= Len( aDados )    // No maximo 10
	nQtdPag		:= (nQtdReg/nPags)
	cPagsAux	:= cValToChar(nQtdPag)

	If SUBSTR(cPagsAux,1,1) == "0"
		nQtdPag := 1    			
	ElseIf At(".",cPagsAux) <> 0 
		nQtdPag := Val(SUBSTR(cPagsAux,1,( At(".",cPagsAux)-1 )))
		nQtdPag++
	Else
		nQtdPag := Val(cPagsAux)
	EndIf		
	//--- Fim do Page Managing

	If nQtdReg > 0

		//Cria serviço no montitor
		aCriaServ := U_MonitRes("000022", 1, nQtdReg)   
		cIdPZB 	 := aCriaServ[2]  

		cJson := '{'
		cJson += '"NumeroPaginas":"'+ cValToChar(nQtdPag) +'",'

		If nPage == nQtdPag
			cJson += '"IsLastPage":true,
		Else
			cJson += '"IsLastPage":false,
		EndIf

		cJson += '"produtos":['

	Else

		cJson += "{"
		cJson += '"produtos":['
		cJson += "{" 
		cJson += '"errorMessage' + cValTochar(1) + '":"Nao existem registros.",'
		cJson += '"lret' + cValTochar(1) + '":false'
		cJson += '}]}'

		::SetContentType("application/json")
		::SetResponse( cJson )

		Return(.T.)

	EndIf

	//-----------------------           
	//--- Transfer Data 
	//-----------------------           
	(cAlsQry)->( dbGoTop() )

	While !(cAlsQry)->(Eof())

		cJson += "{"

		For nX := 1 To Len( aCpos )

			If Empty( aCont[ nX ] )    

				cConteudo := & ("(cAlsQry)->" + aCpos[ nX ] )

				If ValType( cConteudo) == "N"
					cJson += '"' + aCposCab[ nX ] + '":'
					cJson += cValTochar(cConteudo)
				Else
					cConteudo   := Alltrim(cConteudo)
					cJson       += '"' + aCposCab[ nX ] + '":'
					cJson       += '"' + cConteudo + '"'
				EndIf

				cJson += ','  

			Else

				cConteudo := &( aCont[nX] )

				If ValType( cConteudo) == "N"
					cJson += '"' + aCposCab[nX] + '":'
					cJson += cValTochar(cConteudo)
				Else
					cConteudo   := Alltrim(cConteudo)
					cJson       += '"' + aCposCab[nX] + '":'
					cJson       += '"' + cConteudo + '"'
				EndIf

				cJson += ','

			EndIf

		Next nX

		cJson += '"lret' + cValTochar(nLine) + '":true'
		cJson += "},"

		cMenssagem  := "Get realizado com sucesso."
		U_MonitRes("000022", 2, , cIdPZB, cMenssagem, .T., "Get de produtos", cJson, "", "", .F., .F.)

		nLine++
		//--- Page Limit 
		If nLine == (nPags + 1)
			Exit
		EndIf

		(cAlsQry)->( dbSkip() )

	Enddo
	// Close Select 
	(cAlsQry)->( dbCloseArea() )

	cJson := Left(cJson, Rat(",", cJson)-1)

	If Empty(cJson) 

		cJson += "{"
		cJson += '"clientes":['
		cJson += "{" 
		cJson += '"errorMessage' + cValTochar(1) + '":"'+ "cliente nao encontrado" +'",'
		cJson += '"lret' + cValTochar(1) + '":false'
		cJson += "},"

	EndIf

	//Finaliza o processo na PZB
	U_MonitRes("000022", 3, , cIdPZB, , .T.)

	cJson += "]}"

	::SetContentType("application/json")
	::SetResponse( cJson )

Return(.T.)

//--- Funcao construida para Retornar o Ultimo Preco de Venda
//--- Praticado pelo produto cCodProd, para o cliente cCodCli
//--- Carlos E. Chigres  /  28/01/2020


WsRestFul GetNfPed Description "NF do Pedido"

WsData cPedido		As String Optional
WsData cCgcEmp      As String Optional

WsData nPage        As float Optional


WsMethod Get Description "NF do Pedido" WsSyntax "/GetNfPed"

End WsRestFul


WsMethod Get WsReceive cCgcEmp, cPedido, nPage WsService GetNfPed

	Local cJson     := ""
	Local cQuery    := ""   
	Local cIdPZB	:= "" 

	Local nX		:= 0
	Local nY		:= 0
	Local nDE		:= 0
	Local nPags		:= 0
	Local nLine     := 1
	Local nCount    := 1
	Local nPosEmp	:= 0
	Local nQtdPag	:= 0

	Local aCpos     := {}
	Local cPagsAux	:= ""
	Local aCposCab  := {}
	Local cConteudo := ""
	Local aCriaServ := {}
	Local aCont     := {}
	Local aEmpresas := FwLoadSM0()
	Local nQtdReg		:= 0
	Local lItens    := .F.

	Local cQryRes   := ""
	Local cCgcEmp	:= IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")
	Local cPedido	:= IIf(::cPedido <> Nil , ::cPedido , "")
	Local nPage		:=  IIf(::nPage <> Nil, ::nPage, 1)

	Private cAlsQry   := CriaTrab(Nil,.F.)
	Private cAlsRes   := CriaTrab(Nil,.F.)



	nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == cCgcEmp })

	If nPosEmp == 0
		cJson := '{"Erro":"Empresa nao cadastrada."}'
		::SetResponse( cJson )
		Return .T.
	Else
		RpcClearEnv()
		RpcSetEnv(aEmpresas[nPosEmp][1],aEmpresas[nPosEmp][2])
	EndIf   

	nPags	:= GetMV("FT_QTPAGIC",,10)

	cQuery 	:= " SELECT PR2.* FROM " + RetSqlName("PR2") + " (NOLOCK) PR2 "
	cQuery 	+= " INNER JOIN " + RetSqlName("PR1") + " (NOLOCK) PR1 "
	cQuery 	+= " ON PR2_FILIAL = PR1_FILIAL AND PR2_CODIGO = PR1_CODIGO "
	cQuery 	+= " WHERE PR1_CODPZA = '000023' AND PR1.D_E_L_E_T_ = ' '  AND PR2.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	While !(cAlsQry)->(Eof())

		If nCount == 1
			cQryRes := " SELECT  "
			cQryRes += (cAlsQry)->PR2_CPODES 

		Else
			cQryRes += " , " + (cAlsQry)->PR2_CPODES  

		EndIf

		AADD(aCpos, Alltrim((cAlsQry)->PR2_CPODES) )
		AADD(aCposCab, Alltrim((cAlsQry)->PR2_CPOORI))

		If (cAlsQry)->PR2_ISFUNC == "S"
			AADD(aCont, Alltrim( (cAlsQry)->PR2_CONTEU ))
		Else
			AADD(aCont, "")
		EndIf

		nCount++
		(cAlsQry)->(DbSkip())

	End

	If !Empty(cQryRes)

		cQryRes += CRLF + " , F2_FILIAL FROM " + RetSqlName("SC5") + " (NOLOCK) SC5 "
		cQryRes += CRLF + " JOIN " + RetSqlName("SF2") + " (NOLOCK) SF2 ON C5_NOTA = F2_DOC AND C5_CLIENTE = F2_CLIENTE AND C5_FILIAL = F2_FILIAL "
		cQryRes += CRLF + " INNER JOIN " + RetSqlName("SD2") + " (NOLOCK) SD2 "
		cQryRes += CRLF + " ON D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_FILIAL = F2_FILIAL"  
		cQryRes += CRLF + " WHERE C5_FILIAL = '" + aEmpresas[nPosEmp][2]+"' "

		//Numero do pedido
		If !Empty(cPedido)
			cQryRes += CRLF + " AND C5_NUM = '" + cPedido + "'  "
		EndIf

		If Select(cAlsRes) > 0; (cAlsRes)->(dbCloseArea()); Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryRes),cAlsRes,.T.,.T.)

		If SUBSTR(cPagsAux,1,1) == "0"
			nQtdPag := 1    			
		ElseIf At(".",cPagsAux) <> 0 
			nQtdPag := Val(SUBSTR(cPagsAux,1,( At(".",cPagsAux)-1 )))
			nQtdPag++
		Else
			nQtdPag := Val(cPagsAux)
		EndIf		


		If !(cAlsRes)->(Eof()) 
			nQtdReg		:= Contar(cAlsRes,"!Eof()")

			(cAlsRes)->(dbGoTop())
		Endif 

		While !(cAlsRes)->(Eof()) 

			If nLine == 1

				//Cria serviço no montitor
				aCriaServ := U_MonitRes("000023", 1, nQtdReg)   
				cIdPZB 	  := aCriaServ[2]

				cJson := '{"NFs":['

			EndIf

			cJson += "{"

			For nX := 1 to Len(aCpos)

				If SUBSTR(aCpos[nX],1,2) == "F2"   

					If Empty(aCont[nX])    

						cConteudo := & ("(cAlsRes)->" + aCpos[nX])

						If ValType( cConteudo) == "N"
							cJson += '"' + aCposCab[nX] + '":'
							cJson += cValTochar(cConteudo)
						Else
							cConteudo   := Alltrim(cConteudo)
							cJson       += '"' + aCposCab[nX] + '":'
							cJson       += '"' + cConteudo + '"'
						EndIf

						cJson += ','

					Else

						dbselectarea(cAlsRes)

						cConteudo := &(aCont[nX])

						If ValType( cConteudo) == "N"
							cJson += '"' + aCposCab[nX] + '":'
							cJson += cValTochar(cConteudo)
						Else
							cConteudo   := Alltrim(cConteudo)
							cJson       += '"' + aCposCab[nX] + '":'
							cJson       += '"' + cConteudo + '"'
						EndIf

						cJson += ','

					EndIf

				Endif

			Next nX

			cJson += '"NumeroPaginas":"'+ cValToChar(nQtdPag) +'",'

			If nPage == nQtdPag
				cJson += '"IsLastPage":true,
			Else
				cJson += '"IsLastPage":false,
			EndIf

			cJson += '"lret' + cValTochar(nLine) + '":true,'

			cChave := (cAlsRes)->F2_DOC
			cChave += (cAlsRes)->F2_SERIE
			cChave += (cAlsRes)->F2_FILIAL

			For nWW := 1 to Len(aCpos)
				If SUBSTR(aCpos[nWW],1,2) == "D2"
					lItens := .T.
					Exit
				Endif 
			Next nWW

			If lItens // CAso não exista campo de itens, não imprimo a tag de itens
				//Itens
				cJson += '"itens":['
				//itens
				While cChave == ((cAlsRes)->F2_DOC + (cAlsRes)->F2_SERIE + (cAlsRes)->F2_FILIAL)   
					cJson += "{" 
					For nX := 1 to Len(aCpos)

						If SUBSTR(aCpos[nX],1,2) == "D2"

							dbselectarea(cAlsRes)

							If nX < Len(aCpos)

								If Empty(aCont[nX])   

									cConteudo := & ("(cAlsRes)->" + aCpos[nX])

								Else

									cConteudo := &(aCont[nX])

								Endif

								If ValType( cConteudo) == "N"
									cJson += '"' + aCposCab[nX] + '":'
									cJson += cValTochar(cConteudo)
								Else
									cConteudo   := Alltrim(cConteudo)
									cJson       += '"' + aCposCab[nX] + '":'
									cJson       += '"' + cConteudo + '"'
								EndIf

								cJson += ','

							Else

								If Empty(aCont[nX])   

									cConteudo := & ("(cAlsRes)->" + aCpos[nX])

								Else

									cConteudo := &(aCont[nX])

								Endif

								If ValType( cConteudo) == "N"
									cJson += '"' + aCposCab[nX] + '":'
									cJson += cValTochar(cConteudo)
								Else
									cConteudo   := Alltrim(cConteudo)
									cJson       += '"' + aCposCab[nX] + '":'
									cJson       += '"' + cConteudo + '"'
								EndIf

							EndIf
						EndIf   
					Next nX

					//Fecha Itens
					cJson += "},"
					//Fecha Itens
					//Endif 


					(cAlsRes)->(DbSkip())
				EndDo 


			Endif  

			If ! lItens
				cJson := Left(cJson, Rat(",", cJson)-1)
				// cJson += "}"
				// cJson += "]"
				cJson += "},"
			Else

				cJson := Left(cJson, Rat(",", cJson)-1)
				cJson += "]"
				cJson += "},"
			Endif 

			cMenssagem  := "Get realizado com sucesso."
			U_MonitRes("000023", 2, , cIdPZB, cMenssagem, .T., "Get de NFs -  NFPED", cJson, "", "", .F., .F.)

			nLine++

			(cAlsRes)->(DbSkip())

			If (cAlsRes)->(Eof())
				cJson := Left(cJson, Rat(",", cJson)-1)
			Endif 
		End

		(cAlsRes)->(dbCloseArea())

		If Empty(cJson) 

			cJson += "{"
			cJson += '"NF":['
			cJson += "{" 
			cJson += '"errorMessage' + cValTochar(1) + '":"'+ "NF nao encontrada" +'",'
			cJson += '"lret' + cValTochar(1) + '":false'
			cJson += "}"

		EndIf

		//Finaliza o processo na PZB
		U_MonitRes("000023", 3, , cIdPZB, , .T.)

	EndIf

cJson += "]}"

(cAlsQry)->(dbCloseArea())

::SetContentType("application/json")
::SetResponse( cJson )

Return(.T.)

WsRestFul PostEntregNF Description "Metodo Responsavel por Atualizar Entrega da Nota"

WsData cNumNF		As String
WsData cSerNF		As String
WsData cCgcEmp		As String
WsData cCgcCli		As String

WsMethod Post Description "Atualizar Entrega da Nota" WsSyntax "/PostEntregNF"

End WsRestFul

WsMethod Post WsReceive cCgcEmp, cNumNF, cSerNF, cCgcCli WsService PostEntregNF

	Local cCpo		:= ""
	Local cBody     := ::GetContent()
	Local cQuery	:= ""
	Local cAlsQry	:= CriaTrab(NIL,.F.)
	Local cConteudo	:= ""

	Local nX		:= 0
	Local nPosEmp	:= 0

	Local aDados	:= {}
	Local aEmpresas := FwLoadSM0()

	Local oJsoAux	:= NIL

	Local cNumNF	:= IIF(::cNumNF <> Nil, PADR(::cNumNF,TamSx3("F2_DOC")[1]), "")
	Local cSerNF	:= IIF(::cSerNF <> Nil, PADR(::cSerNF,TamSx3("F2_SERIE")[1]), "")
	Local cCgcEmp	:= IIF(::cCgcEmp <> Nil, ::cCgcEmp, "")
	Local cCgcCli	:= IIF(::cCgcCli <> Nil, ::cCgcCli, "")

	nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == Alltrim(cCgcEmp) })

	If nPosEmp == 0

		cJson := '{'
		cJson += '"cErrorMessage":""Erro":"Empresa nao cadastrada.""'
		cJson += '}'

		::SetResponse( cJson )
		Return ( .T. )

	Else
		RpcClearEnv()
		RpcSetEnv(aEmpresas[nPosEmp][1],aEmpresas[nPosEmp][2])

	EndIf 

	DBSelectArea("SA1")
	SA1->(DBSetOrder(3))

	If !SA1->(DBSeek(xFilial("SA1")+AllTrim(cCgcCli)))

		cJson := '{'
		cJson += '"cErrorMessage":"Cliente nao cadastrado."'
		cJson += '}'

		::SetResponse( cJson )
		Return ( .T. )

	EndIf

	If !SF2->(DBSeek(xFilial("SF2") + cNumNF + cSerNF + SA1->(A1_COD+A1_LOJA)))

		cJson := '{'
		cJson += '"cErrorMessage":"Nota Fisca nao encontrada."'
		cJson += '}'

		::SetResponse( cJson )
		Return ( .T. )

	EndIf

	cQuery 	:= " SELECT PR2.* FROM " + RetSqlName("PR2") + " (NOLOCK) PR2 "
	cQuery 	+= " INNER JOIN " + RetSqlName("PR1") + " (NOLOCK) PR1 "
	cQuery 	+= " ON PR2_FILIAL = PR1_FILIAL AND PR2_CODIGO = PR1_CODIGO "
	cQuery 	+= " WHERE PR1_CODPZA = '000024' AND PR1.D_E_L_E_T_ = ' '  AND PR2.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0
		(cAlsQry)->(DBCloseArea()) 
	EndIf

	DBUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	FWJsonDeserialize(cBody, @oJsoAux)

	If Len(oJsoAux:Notas) > 0

		For nX := 1 To Len(oJsoAux:Notas)

			SF2->(RECLOCK("SF2",.F.))

			While (cAlsQry)->(!EOF())

				If AttIsMemberOf(oJsoAux:Notas[nX],AllTrim((cAlsQry)->PR2_CPOORI))			 
					cConteudo := &("oJsoAux:Notas[" + cValTochar(nX) + "]:" + AllTrim((cAlsQry)->PR2_CPOORI))			
				EndIf

				cCpo := AllTrim((cAlsQry)->PR2_CPODES)

				If TamSX3(cCpo)[3] == "D"
					cConteudo := StoD(cConteudo)
				EndIf

				(&("SF2->"+cCpo)) := cConteudo 

				(cAlsQry)->(DBSkip())

			EndDo

			SF2->(MSUnlock())

			(cAlsQry)->(DBGoTop())

		Next nX

	EndIf

cJson := '{'
cJson += '"lSucess":true'
cJson += '}'

::SetContentType("application/json")
::SetResponse( cJson )

Return ( .T. )

WsRestFul GetStatNF Description "Metodo Responsavel por Consultar Status da Nota Fiscal Saída "

WsData dDataAte		As Date Optional
WsData dDataDe		As Date Optional 
WsData cNota        As String Optional
WsData cSerie       As String Optional
WsData nPage        As Float Optional
WsData nTpConsu		As Float Optional
WsData cCgcEmp		As String Optional
WsData cCgcCli		As String Optional
WsData cChaveNF		As String Optional

WsMethod Get Description "Pedidos de Venda" WsSyntax "/GetStatNF"

End WsRestFul

WsMethod Get WsReceive cCgcEmp, dDataDe, dDataAte, nPage, nTpConsu, cNota, cCgcEmp, cCgcCli, cSerie, cChaveNF WsService GetStatNF

	Local cCli		:= ""
	Local cLoja		:= ""
	Local cJson     := ""
	Local cQuery    := "" 
	Local cChave	:= ""  
	Local cIdPZB	:= "" 

	Local nX		:= 0
	Local nY		:= 0
	Local nDE		:= 0
	Local nPags		:= 0
	Local nLine     := 1
	Local nCount    := 1
	Local nPosEmp	:= 0
	Local nQtdPag	:= 0

	Local aCpos     := {}
	Local aCont     := {}
	Local cPagsAux	:= ""
	Local aCposCab  := {}
	Local cConteudo := ""
	Local aCriaServ := {}
	Local aEmpresas := FwLoadSM0()
	Local dData     := SuperGetMV("EF_DTNFCPR",.F., "20191101")

	//Local l

	Local dDataAte	:= IIf(::dDataAte <> Nil , ::dDataAte , "")
	Local dDataDe	:= IIf(::dDataDe <> Nil , ::dDataDe , "")
	Local cCgcEmp   := IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")
	Local cNota   	:= IIf(::cNota <> Nil , ::cNota , "")
	Local nTpConsu	:= IIf(::nTpConsu <> Nil, ::nTpConsu, 0)
	Local nPage		:= IIf(::nPage <> Nil, ::nPage, 1)
	Local cCgcCli   := IIf(::cCgcCli <> Nil , ::cCgcCli , "")
	Local cSerie    := IIf(::cSerie <> Nil , ::cSerie , "")
	Local cChaveNF  := IIf(::cChaveNF <> Nil , ::cChaveNF , "")

	nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == cCgcEmp })

	Private cAlsQry   := CriaTrab(Nil,.F.)
	Private cAlsRes   := CriaTrab(Nil,.F.)
	Private cQryRes   := ""

	If nPosEmp == 0
		cJson := '{"Erro":"Empresa nao cadastrada."}'
		::SetResponse( cJson )
		Return .T.
	Else
		RpcClearEnv()
		RpcSetEnv(aEmpresas[nPosEmp][1],aEmpresas[nPosEmp][2])
	EndIf   

	nPags	:= GetMV("FT_QTPAGIC",,10)

	If nTpConsu <> 1

		cQuery 	:= " SELECT PR2.* FROM " + RetSqlName("PR2") + " (NOLOCK) PR2 "
		cQuery 	+= " INNER JOIN " + RetSqlName("PR1") + " (NOLOCK) PR1 "
		cQuery 	+= " ON PR2_FILIAL = PR1_FILIAL AND PR2_CODIGO = PR1_CODIGO "
		cQuery 	+= " WHERE PR1_CODPZA = '000025' AND PR1.D_E_L_E_T_ = ' '  AND PR2.D_E_L_E_T_ = ' ' "

		If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

		While !(cAlsQry)->(Eof())

			If nCount == 1
				cQryRes := CRLF + " SELECT  F2_DOC, F2_SERIE,"
				cQryRes += CRLF + (cAlsQry)->PR2_CPODES 

			Else
				cQryRes += CRLF + " , " + (cAlsQry)->PR2_CPODES  

			EndIf

			AADD(aCpos, Alltrim((cAlsQry)->PR2_CPODES) )
			AADD(aCposCab, Alltrim((cAlsQry)->PR2_CPOORI))

			If (cAlsQry)->PR2_ISFUNC == "S"
				AADD(aCont, Alltrim( (cAlsQry)->PR2_CONTEU ))
			Else
				AADD(aCont, "")
			EndIf

			nCount++
			(cAlsQry)->(DbSkip())
		End
	Else
		//AADD(aCpos, 'F2_COD_VOLUME')
		//AADD(aCpos, 'F2_BAR_CODE')
		AADD(aCpos, 'F2_ESPECIE')
		AADD(aCpos, 'F2_TIPO_PARADA')
		AADD(aCpos, 'F2_NFISCAL')
		AADD(aCpos, 'F2_VALOR_BRUTO')
		AADD(aCpos, 'F2_SERIE')	  	
		AADD(aCpos, 'F2_EMISSAO')
		AADD(aCpos, 'F2_CHAVE')
		AADD(aCpos, 'F2_CNPJ_TRANSPORTADORA')
		AADD(aCpos, 'F2_CNPJ_EMISSOR')
		AADD(aCpos, 'F2_PEDIDO')
		AADD(aCpos, 'D2_PESO_LIQUIDO')
		AADD(aCpos, 'D2_PESO_BRUTO')
		AADD(aCpos, 'F2_TOTAL_PESO_LIQUIDO')
		AADD(aCpos, 'F2_TOTAL_PESO_BRUTO')
		//AADD(aCpos, 'D2_PESO_VOLUME')
		AADD(aCpos, 'F2_VOLUME')
		AADD(aCpos, 'F2_CNPJ_CLIENTE')
		AADD(aCpos, 'F2_CODIGO')
		AADD(aCpos, 'F2_CONTATO')
		AADD(aCpos, 'F2_TELEFONE')
		AADD(aCpos, 'F2_EMAIL')
		AADD(aCpos, 'F2_NOME')
		AADD(aCpos, 'F2_TIPOCLIENTE')
		AADD(aCpos, 'F2_ENDERECO')
		AADD(aCpos, 'F2_BAIRRO')
		AADD(aCpos, 'F2_MUNICIPIO')
		AADD(aCpos, 'F2_UF')
		AADD(aCpos, 'F2_PAIS')
		AADD(aCpos, 'F2_CEP')
		AADD(aCpos, 'D2_QUANTIDADE')
		AADD(aCpos, 'D2_CODPROD')
		AADD(aCpos, 'D2_DESCRICAO')
		AADD(aCpos, 'D2_UM')
		AADD(aCpos, 'D2_EAN')
		AADD(aCpos, 'D2_CNPJ_FABRICANTE')
		AADD(aCpos, 'D2_COD_FABRICANTE')
		AADD(aCpos, 'D2_NOME_FABRICANTE')
		AADD(aCpos, 'D2_VALIDADE')
		AADD(aCpos, 'D2_COD_ANVISA')
		AADD(aCpos, 'D2_LOTE')

		//AADD(aCposCab, 'Cod_Volume')
		//AADD(aCposCab, 'Bar_Code')
		AADD(aCposCab, 'Especie')
		AADD(aCposCab, 'Tipo_Parada')
		AADD(aCposCab, 'NFiscal')
		AADD(aCposCab, 'Valor_Bruto')
		AADD(aCposCab, 'Serie')	  	
		AADD(aCposCab, 'Emissao')
		AADD(aCposCab, 'Chave')
		AADD(aCposCab, 'Cnpj_Transportadora')
		AADD(aCposCab, 'Cnpj_Emissor,')
		AADD(aCposCab, 'Pedido')
		AADD(aCposCab, 'Peso_Liquido')
		AADD(aCposCab, 'Peso_Bruto')
		AADD(aCposCab, 'Total_Peso_Liquido')
		AADD(aCposCab, 'Total_Peso_Bruto')
		//AADD(aCposCab, 'Peso_Volume')
		AADD(aCposCab, 'Volume')
		AADD(aCposCab, 'Cnpj_Cliente')
		AADD(aCposCab, 'Codigo')
		AADD(aCposCab, 'Contato')
		AADD(aCposCab, 'Telefone')
		AADD(aCposCab, 'Email')
		AADD(aCposCab, 'Nome_Cliente')
		AADD(aCposCab, 'Tipo_Cliente')
		AADD(aCposCab, 'Endereco')
		AADD(aCposCab, 'Bairro')
		AADD(aCposCab, 'Municipio')
		AADD(aCposCab, 'UF')
		AADD(aCposCab, 'Pais')
		AADD(aCposCab, 'CEP')
		AADD(aCposCab, 'Quantidade')
		AADD(aCposCab, 'Codigo_Produto')
		AADD(aCposCab, 'Nome_Produto')
		AADD(aCposCab, 'Unidade')
		AADD(aCposCab, 'EAN')
		AADD(aCposCab, 'Cnpj_Fabricante')
		AADD(aCposCab, 'Codigo_Fabricante')
		AADD(aCposCab, 'Nome_Fabricante')
		AADD(aCposCab, 'Validade')
		AADD(aCposCab, 'Codigo_Anvisa')
		AADD(aCposCab, 'Lote')

		For nXy := 1 to len(aCposCab)
			AADD(aCont, '')
		Next nXy

	Endif 

	If !Empty(cCgcCli)
		DBSelectArea("SA1")
		SA1->(DBSetOrder(3))	
		If SA1->(DBSeek(xFilial("SA1") + cCgcCli))
			cCli	:= SA1->A1_COD
			cLoja	:= SA1->A1_LOJA
		Endif 
	EndIf

	If ! Empty(cQryRes)

		cQryRes += CRLF + " FROM " + RetSqlName("SF2") + " (NOLOCK) SF2 "
		cQryRes += CRLF + " INNER JOIN  " + RetSqlName("SD2") + " (NOLOCK) SD2 ON (D2_FILIAL = F2_FILIAL
		cQryRes += CRLF + "                           AND D2_DOC = F2_DOC
		cQryRes += CRLF + "                           AND D2_SERIE = F2_SERIE
		cQryRes += CRLF + "                           AND D2_CLIENTE = F2_CLIENTE
		cQryRes += CRLF + "                           AND D2_LOJA = F2_LOJA
		cQryRes += CRLF + "                           AND SD2.D_E_L_E_T_ = '')

		cQryRes += CRLF + " WHERE SF2.D_E_L_E_T_ = '' "

		If !Empty(cNota)
			cQryRes += CRLF + " AND F2_DOC = '" + cNota + "'  "
		EndIf

		//DATA
		If !Empty(dDataDe)
			cQryRes += CRLF + " AND F2_EMISSAO >= '" + DtoS(dDataDe) + "'  "
		EndIf

		If !Empty(dDataAte)
			cQryRes += CRLF + " AND F2_EMISSAO <= '" + DtoS(dDataAte) + "'  "
		EndIf

		//CLIENTE
		If !Empty(cCgcCli)
			cQryRes += " AND F2_CLIENTE = '" + cCli + "'  "
		EndIf

		// Série
		If !Empty(cSerie)
			cQryRes += " AND F2_SERIE = '" + cSerie + "'  "
		EndIf

		If !Empty(cChaveNF)
			cQryRes += " AND F2_CHVNFE = '" + cChaveNF + "'  "
		EndIf


	Else

		cQryRes += CRLF + "    SELECT F2_DOC, F2_ESPECIE AS F2_ESPECIE,  "
		//cQryRes += CRLF + "    RTRIM(D2_FILIAL) + RTRIM(D2_PEDIDO) + RTRIM(D2_CLIENTE) + RTRIM(D2_LOJA) AS  F2_COD_VOLUME, "
		//cQryRes += CRLF + "    RTRIM(A1_NOME) + RTRIM(F2_DOC) + RTRIM(ESTADOCOB) + RTRIM(CONVERT(VARCHAR, CAST(F2_XPRZENT AS DATE), 3)) + RTRIM(F2_SERIE)+ '" + Alltrim(cEmpAnt) + "' + RTRIM(F2_FILIAL) AS F2_BAR_CODE, "																																							 "
		cQryRes += CRLF + "    CASE                                                   																																		 "
		cQryRes += CRLF + "        WHEN F2_REDESP <> '' THEN 'T' 																																							 "
		cQryRes += CRLF + "        ELSE 'E' 																																												 "
		cQryRes += CRLF + "     END F2_TIPO_PARADA, "
		cQryRes += CRLF + "   F2_DOC AS F2_NFISCAL, "
		cQryRes += CRLF + "   F2_VALBRUT AS F2_VALOR_BRUTO, "
		cQryRes += CRLF + "   F2_SERIE AS 'F2_SERIE', "
		cQryRes += CRLF + "   F2_EMISSAO AS F2_EMISSAO, "
		cQryRes += CRLF + "   F2_CHVNFE AS F2_CHAVE, "
		cQryRes += CRLF + "   A4_CGC AS F2_CNPJ_TRANSPORTADORA, "
		cQryRes += CRLF + "   EMPRESA.CNPJ AS F2_CNPJ_EMISSOR, "
		cQryRes += CRLF + "   D2_PEDIDO AS F2_PEDIDO,"
		cQryRes += CRLF + "   B1_PESO AS D2_PESO_LIQUIDO, "
		cQryRes += CRLF + "   B1_PESBRU AS D2_PESO_BRUTO, "
		cQryRes += CRLF + "   F2_PLIQUI AS F2_TOTAL_PESO_LIQUIDO, "
		cQryRes += CRLF + "   F2_PBRUTO AS F2_TOTAL_PESO_BRUTO, "
		//cQryRes += CRLF + "   F2_PBRUTO AS D2_PESO_VOLUME, "
		//cQryRes += CRLF + "   SUM(ZJ_2PESO) AS D2_PESO_VOLUME, "
		cQryRes += CRLF + "   F2_VOLUME1 AS F2_VOLUME, "
		cQryRes += CRLF + "   A1_CGC AS F2_CNPJ_CLIENTE, "
		cQryRes += CRLF + "   A1_COD AS F2_CODIGO, "
		cQryRes += CRLF + "   A1_CONTATO AS F2_CONTATO, "
		cQryRes += CRLF + "   A1_TEL AS F2_TELEFONE, "
		cQryRes += CRLF + "   A1_EMAIL AS F2_EMAIL, "
		cQryRes += CRLF + "   A1_NOME AS F2_NOME, "
		cQryRes += CRLF + "   A1_PESSOA AS F2_TIPOCLIENTE, "
		cQryRes += CRLF + "   A1_END AS F2_ENDERECO, "
		cQryRes += CRLF + "   A1_BAIRRO AS F2_BAIRRO, "
		cQryRes += CRLF + "   A1_MUN AS F2_MUNICIPIO, "
		cQryRes += CRLF + "   A1_EST AS F2_UF, "
		cQryRes += CRLF + "  'BRA' AS F2_PAIS, "
		cQryRes += CRLF + "   A1_CEP AS F2_CEP, "
		cQryRes += CRLF + "   D2_QUANT AS D2_QUANTIDADE, "
		cQryRes += CRLF + "   B1_COD AS D2_CODPROD,
		cQryRes += CRLF + "   B1_DESC AS D2_DESCRICAO,
		cQryRes += CRLF + "   D2_UM AS D2_UM,
		cQryRes += CRLF + "   B1_CODBAR AS D2_EAN,
		cQryRes += CRLF + "   A2_CGC AS D2_CNPJ_FABRICANTE,
		cQryRes += CRLF + "   A2_COD AS D2_COD_FABRICANTE,
		cQryRes += CRLF + "   A2_NOME AS D2_NOME_FABRICANTE,
		cQryRes += CRLF + "   D2_DTVALID AS D2_VALIDADE,
		cQryRes += CRLF + "   B1_XREGMS AS D2_COD_ANVISA,
		cQryRes += CRLF + "   D2_LOTECTL AS D2_LOTE
		cQryRes += CRLF + "   FROM  " + RetSqlName("SF2") + " SF2 (NOLOCK)
		cQryRes += CRLF + "   INNER JOIN  " + RetSqlName("SD2") + " (NOLOCK) SD2 ON (D2_FILIAL = F2_FILIAL
		cQryRes += CRLF + "                           AND D2_DOC = F2_DOC
		cQryRes += CRLF + "                           AND D2_SERIE = F2_SERIE
		cQryRes += CRLF + "                           AND D2_CLIENTE = F2_CLIENTE
		cQryRes += CRLF + "                           AND D2_LOJA = F2_LOJA
		cQryRes += CRLF + "                           AND SD2.D_E_L_E_T_ = '')
		cQryRes += CRLF + "  INNER JOIN SB1980 SB1 (NOLOCK) ON (B1_COD = D2_COD
		cQryRes += CRLF + "                           AND SB1.D_E_L_E_T_ = '')
		cQryRes += CRLF + "  INNER JOIN SA1980 SA1 (NOLOCK) ON (A1_COD = F2_CLIENTE
		cQryRes += CRLF + "                           AND A1_LOJA = F2_LOJA
		cQryRes += CRLF + "                           AND SA1.D_E_L_E_T_ = '')
		cQryRes += CRLF + "  LEFT OUTER JOIN SA2070 SA2 (NOLOCK) ON (A2_COD = B1_PROC
		cQryRes += CRLF + "                               AND A2_LOJA = B1_LOJPROC
		cQryRes += CRLF + "                               AND SA2.D_E_L_E_T_ = '')
		cQryRes += CRLF + "  LEFT OUTER JOIN SA4010 SA4 (NOLOCK) ON (A4_COD = F2_TRANSP
		cQryRes += CRLF + "                                AND SA4.D_E_L_E_T_ = '')
		cQryRes += CRLF + "  INNER JOIN EMPRESA (NOLOCK) ON (EMPRESA = '" + Alltrim(cEmpAnt) + "'"
		cQryRes += CRLF + "                        AND FILIAL = F2_FILIAL
		cQryRes += CRLF + "                        AND A1_CGC <> CNPJ)

		// cQryRes += CRLF + "  INNER JOIN  " + RetSqlName("SZJ") + " ZJ (NOLOCK) ON (ZJ_FILIAL = D2_FILIAL
		// cQryRes += CRLF + "                         AND ZJ_PEDIDO = D2_FILIAL+D2_PEDIDO+D2_CLIENTE+D2_LOJA
		// cQryRes += CRLF + "                          AND ZJ.D_E_L_E_T_ = '')

		cQryRes += CRLF + " INNER JOIN  " + RetSqlName("SF4") + " F4 (NOLOCK) ON (F4_CODIGO = D2_TES
		cQryRes += CRLF + "                          AND F4_ESTOQUE = 'S'
		cQryRes += CRLF + "                          AND F4.D_E_L_E_T_ = '')
		cQryRes += CRLF + " WHERE SF2.D_E_L_E_T_ = ''  " //AND F2_FILIAL = '"+ cFilAnt + "'

		cQryRes += CRLF + " AND F2_EMISSAO >= '" + dData + "'  "

		If !Empty(cNota)
			cQryRes += CRLF + " AND F2_DOC = '" + cCodPed + "'  "
		EndIf

		cQryRes += CRLF + "        AND F2_FIMP = 'S'
		cQryRes += CRLF + "        AND F2_XDTENT = ''
		cQryRes += CRLF + "        AND F2_XHRENT = ''
		cQryRes += CRLF + "        GROUP BY D2_FILIAL,
		cQryRes += CRLF + "        D2_PEDIDO,
		cQryRes += CRLF + "        D2_CLIENTE,
		cQryRes += CRLF + "        D2_LOJA,
		cQryRes += CRLF + "        A1_NOME,
		cQryRes += CRLF + "        F2_DOC,
		cQryRes += CRLF + "        ESTADOCOB,
		cQryRes += CRLF + "        F2_XPRZENT,
		cQryRes += CRLF + "        F2_SERIE,
		cQryRes += CRLF + "        F2_ESPECIE,
		cQryRes += CRLF + "        F2_REDESP,
		cQryRes += CRLF + "        F2_VALBRUT,
		cQryRes += CRLF + "        F2_EMISSAO,
		cQryRes += CRLF + "        F2_CHVNFE,
		cQryRes += CRLF + "        A4_CGC,
		cQryRes += CRLF + "        CNPJ,
		cQryRes += CRLF + "        B1_PESO,
		cQryRes += CRLF + "        B1_PESBRU,
		// cQryRes += CRLF + "        ZJ_2PESO,
		cQryRes += CRLF + "        F2_VOLUME1,
		cQryRes += CRLF + "        A1_CGC,
		cQryRes += CRLF + "        A1_COD,
		cQryRes += CRLF + "        A1_CONTATO,
		cQryRes += CRLF + "        A1_TEL,
		cQryRes += CRLF + "        A1_EMAIL,
		cQryRes += CRLF + "        A1_NOME,
		cQryRes += CRLF + "        A1_PESSOA,
		cQryRes += CRLF + "        A1_END,
		cQryRes += CRLF + "        A1_BAIRRO,
		cQryRes += CRLF + "        A1_MUN,
		cQryRes += CRLF + "        A1_EST,
		cQryRes += CRLF + "        A1_CEP,
		cQryRes += CRLF + "        D2_QUANT,
		cQryRes += CRLF + "        B1_COD,
		cQryRes += CRLF + "        B1_DESC,
		cQryRes += CRLF + "        D2_UM,
		cQryRes += CRLF + "        B1_CODBAR,
		cQryRes += CRLF + "        A2_CGC,
		cQryRes += CRLF + "        A2_COD,
		cQryRes += CRLF + "        A2_NOME,
		cQryRes += CRLF + "        D2_DTVALID,
		cQryRes += CRLF + "        B1_XREGMS,
		cQryRes += CRLF + "        D2_LOTECTL,
		cQryRes += CRLF + "        F2_FILIAL,
		cQryRes += CRLF + "        F2_PLIQUI,
		cQryRes += CRLF + "        F2_PBRUTO
		cQryRes += CRLF + "        ORDER BY F2_FILIAL , F2_DOC

	Endif 

	If Select(cAlsRes) > 0; (cAlsRes)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryRes),cAlsRes,.T.,.T.)

	nQtdReg		:= Contar(cAlsRes,"!Eof()")
	nQtdPag		:= (nQtdReg/nPags)
	cPagsAux	:= cValToChar(nQtdPag)

	If SUBSTR(cPagsAux,1,1) == "0"
		nQtdPag := 1    			
	ElseIf At(".",cPagsAux) <> 0 
		nQtdPag := Val(SUBSTR(cPagsAux,1,( At(".",cPagsAux)-1 )))
		nQtdPag++
	Else
		nQtdPag := Val(cPagsAux)
	EndIf		

	(cAlsRes)->(DbGoTop())

	If !(cAlsRes)->(Eof()) 

		If SUBSTR(cPagsAux,1,1) == "0"
			nQtdPag := 1    			
		ElseIf At(".",cPagsAux) <> 0 
			nQtdPag := Val(SUBSTR(cPagsAux,1,( At(".",cPagsAux)-1 )))
			nQtdPag++
		Else
			nQtdPag := Val(cPagsAux)
		EndIf		

		//Cria serviço no montitor

		cJson := '{'
		cJson += '"NumeroPaginas":"'+ cValToChar(nQtdPag) +'",'

		If nPage == nQtdPag
			cJson += '"IsLastPage":true,
		Else
			cJson += '"IsLastPage":false,
		EndIf

		(cAlsRes)->(DbGoTop())

		If Empty(cChaveNF)
			If nPage <> 0 .Or. ! Empty(nPage)

				nDE := ((nPage*nPags) - nPags)
				If nDe > 0
					For nY := 0 To nDE
						(cAlsRes)->(DBSkip())
					Next nY
				Endif
			EndIf
		Endif 

	Endif

	While !(cAlsRes)->(Eof()) 

		If nLine == 1

			//Cria serviço no montitor
			aCriaServ := U_MonitRes("000025", 1, nQtdReg)   
			cIdPZB 	  := aCriaServ[2]

			cJson += '"NFs":['

		EndIf

		cJson += "{"

		For nX := 1 to Len(aCpos)

			If SUBSTR(aCpos[nX],1,2) == "F2"   

				If Empty(aCont[nX])    

					cConteudo := & ("(cAlsRes)->" + aCpos[nX])

					If ValType( cConteudo) == "N"
						cJson += '"' + aCposCab[nX] + '":'
						cJson += cValTochar(cConteudo)
					Else
						cConteudo   := Alltrim(cConteudo)
						cJson       += '"' + aCposCab[nX] + '":'
						cJson       += '"' + cConteudo + '"'
					EndIf

					cJson += ','

				Else

					dbselectarea(cAlsRes)

					cConteudo := &(aCont[nX])

					If ValType( cConteudo) == "N"
						cJson += '"' + aCposCab[nX] + '":'
						cJson += cValTochar(cConteudo)
					Else
						cConteudo   := Alltrim(cConteudo)
						cJson       += '"' + aCposCab[nX] + '":'
						cJson       += '"' + cConteudo + '"'
					EndIf

					cJson += ','

				EndIf

			Endif

		Next nX

		//cJson += '"NumeroPaginas":"'+ cValToChar(nQtdPag) +'",'

		//If nPage == nQtdPag
		//cJson += '"IsLastPage":true,
		//Else
		//cJson += '"IsLastPage":false,
		//EndIf

		cJson += '"lret' + cValTochar(nLine) + '":true,'

		cChave := (cAlsRes)->F2_DOC
		cChave += (cAlsRes)->F2_SERIE

		cJson += '"itens":['

		While cChave == ((cAlsRes)->F2_DOC + (cAlsRes)->F2_SERIE )   
			cJson += "{" 
			For nX := 1 to Len(aCpos)

				If SUBSTR(aCpos[nX],1,2) == "D2"

					dbselectarea(cAlsRes)

					If nX < Len(aCpos)

						If Empty(aCont[nX])   

							cConteudo := & ("(cAlsRes)->" + aCpos[nX])

						Else
							cConteudo := &(aCont[nX])
						Endif

						If ValType( cConteudo) == "N"
							cJson += '"' + aCposCab[nX] + '":'
							cJson += cValTochar(cConteudo)
						Else
							cConteudo   := Alltrim(cConteudo)
							cJson       += '"' + aCposCab[nX] + '":'
							cJson       += '"' + cConteudo + '"'
						EndIf

						cJson += ','

					Else

						If Empty(aCont[nX])   
							cConteudo := & ("(cAlsRes)->" + aCpos[nX])
						Else
							cConteudo := &(aCont[nX])
						Endif

						If ValType( cConteudo) == "N"
							cJson += '"' + aCposCab[nX] + '":'
							cJson += cValTochar(cConteudo)
						Else
							cConteudo   := Alltrim(cConteudo)
							cJson       += '"' + aCposCab[nX] + '":'
							cJson       += '"' + cConteudo + '"'
						EndIf
						cJson += ','///
					EndIf
				EndIf   
			Next nX

			cJson := Left(cJson, Rat(",", cJson)-1)
			cJson += "},"

			(cAlsRes)->(DbSkip())
			If cChave <> ((cAlsRes)->F2_DOC + (cAlsRes)->F2_SERIE)  
				cJson := Left(cJson, Rat(",", cJson)-1)
			Endif  

		EndDo        
		// cJson := Left(cJson, Rat(",", cJson)-1)
		cJson += "]"
		cJson += "},"

		cMenssagem  := "Get realizado com sucesso."
		U_MonitRes("000025", 2, , cIdPZB, cMenssagem, .T., "Get de Consulta NF", "", "", "", .F., .F.)

		nLine++

		If nPage = 0 //.OR. !Empty(cCgcCli) 
			If (cAlsRes)->(Eof())
				cJson := Left(cJson, Rat(",", cJson)-1)
				Exit
			EndIf
		Else
			If nLine == (nPags + 1) .Or. (cAlsRes)->(Eof())
				cJson := Left(cJson, Rat(",", cJson)-1)
				Exit
			EndIf
		EndIf
	End

	(cAlsRes)->(dbCloseArea())

	If Empty(cJson) 

		cJson += "{"
		cJson += '"NFs":['
		cJson += "{" 
		cJson += '"errorMessage' + cValTochar(1) + '":"'+ "NF nao encontrada" +'",'
		cJson += '"lret' + cValTochar(1) + '":false'
		cJson += "},"

	EndIf

//Finaliza o processo na PZB
U_MonitRes("000025", 3, , cIdPZB, , .T.)

cJson += "]}"

::SetContentType("application/json")
::SetResponse( cJson )

Return(.T.) 


WsRestFul GetXML Description "Nota Fiscal Saída - Geração XML - GET"

WsData cCgcEmp		As String 
WsData cNota		As String 
WsData cSerie	    As String 
WsData cCliente     As String Optional

WsMethod Get Description "Consulta de XML NF" WsSyntax "/GetXML"

End WsRestFul

WsMethod Get WsReceive cCgcEmp, cNota, cSErie, cCliente WsService GetXML

	Local cQuery    := ""    
	Local aCpos     := {}
	Local aCposCab  := {}
	Local aCont     := {}
	Local cJson     := ""
	Local cQryRes   := ""
	Local nCount    := 1
	Local nX
	Local cConteudo := ""
	Local cIdPZB	:= ""
	Local aCriaServ := {}
	Local nLine     := 1
	Local nPosEmp	:= 0
	Local cXml      := ''
	Local cNota    	:= IIf(::cNota <> Nil  , ::cNota  , "")
	Local cCgcEmp   := IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")
	Local cSerie   := IIf(::cSErie <> Nil , ::cSErie , "")
	Local cCliente     := IIf(::cCliente <> Nil , ::cCliente , "")
	Local lErrou    := .F.

	Local aEmpresas := FwLoadSM0()
	Local cTabQry   := GetNExtAlias()
	Local dEmissao  := ''
	Local cLoja 	:= ''
	Private cAlsQry   := CriaTrab(Nil,.F.)
	Private cAlsRes   := CriaTrab(Nil,.F.)

	nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == cCgcEmp })

	If nPosEmp == 0
		cJson := '{"Erro":"Empresa nao cadastrada."}'
		::SetResponse( cJson )
		Return .T.
	Else
		RpcClearEnv()
		RpcSetEnv(aEmpresas[nPosEmp][1],aEmpresas[nPosEmp][2])
	EndIf

	//Query
	cQuery := "SELECT F2_DOC,F2_SERIE,F2_CLIENTE,F2_LOJA,F2_EMISSAO FROM " + RetSQLNAME("SF2") + " F2 "
	cQuery += "WHERE F2.D_E_L_E_T_ <> '*' "

	If !Empty(cCliente)
		cQuery += "AND F2_CLIENTE = '" + cCliente + "' "
	EndIf

	If !Empty(cNota)
		cQuery += "AND F2_DOC = '" + Alltrim(cNota) + "' "
	EndIf

	If !Empty(cSerie)
		cQuery += "AND F2_SERIE = '" + cSerie + "' "
	EndIf

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTabQry, .F., .T.)
	(cTabQry)->(dbGoTop())

	If (cTabQry)->(!EOF())

		cLoja := (cTabQry)->F2_LOJA
		dEmissao := StoD((cTabQry)->F2_EMISSAO)
		cCliente := (cTabQry)->F2_CLIENTE
		cSerie   := (cTabQry)->F2_SERIE

		cXml := BuscaXML(cNota, cSerie, cCliente, cLoja, dEmissao)

	Endif 

	nPags	:= GetMV("FT_QTPAGIC",,10)

	If ! Empty(cXml)

		nQtdReg		:= 1
		nQtdPag		:= 1
		cPagsAux	:= cValToChar(nQtdPag)

		//Cria serviço no montitor
		aCriaServ := U_MonitRes("000026", 1, nQtdReg)   
		cIdPZB 	  := aCriaServ[2]

		cJson := '{'
		cJson += '"NumeroPaginas":"'+ cValToChar(nQtdPag) +'",'

		//If nPage == nQtdPag
		cJson += '"IsLastPage":true,
		//Else
		//cJson += '"IsLastPage":false,
		//EndIf

		cJson += '"XML":['

	Else

		cJson += "{"
		cJson += '"XML":['
		cJson += "{" 
		cJson += '"errorMessage' + cValTochar(1) + '":"'+ "Nota Fiscal nao encontrada" +'",'
		cJson += '"lret' + cValTochar(1) + '":false'
		cJson += "}"
		cJson += "]"
		cJson += "}"

		::SetContentType("application/json")
		::SetResponse( cJson )

		Return(.T.)

	EndIf

	If ! Empty(cXml)

		cJson += "{"

		cConteudo := 'XML'//&(aCont[nX])

		cConteudo   := Alltrim(cConteudo)
		cJson       += '"' + 'XML' + '":'
		cJson       += '"' + Encode64(cXml) + '"'
		cJson += ','

		cJson += '"lret' + cValTochar(nLine) + '":true'
		cJson += "},"

		cMenssagem  := "Get realizado com sucesso."
		U_MonitRes("000026", 2, , cIdPZB, cMenssagem, .T., "Get de XML", cJson, "", "", .F., .F.)

		nLine++

		//(cAlsRes)->(DbSkip())

		If !Empty(cXml) //.And. !Empty(cCodBar)

			//If (cAlsRes)->(Eof())
			cJson := Left(cJson, Rat(",", cJson)-1)

			//EndIf

		Else

			//If nLine == (nPags + 1) .Or. (cAlsRes)->(Eof())
			//cJson := Left(cJson, Rat(",", cJson)-1)

			//	EndIf

		EndIf

	EndIf

	//Finaliza o processo na PZB
	U_MonitRes("000026", 3, , cIdPZB, , .T.)

	cJson += "]}"

	::SetContentType("application/json")
	::SetResponse( cJson )

Return(.T.)




WsRestFul GetEntNF Description "Entrega NF"

WsData cNota		As String Optional
WsData cSerie		As String Optional
WsData cCliente		As String Optional
WsData cChaveNF		As String Optional
WsData cCgcEmp      As String Optional

WsMethod Get Description "Entregas NF" WsSyntax "/GetEntNF"

End WsRestFul


WsMethod Get WsReceive cCgcEmp, cNota, cSerie, cChaveNF, cCliente WsService GetEntNF


	Local cJson     := ""
	Local cQuery    := ""   
	Local cIdPZB	:= "" 

	Local nX		:= 0
	Local nY		:= 0
	Local nDE		:= 0
	Local nPags		:= 0
	Local nLine     := 1
	Local nCount    := 1
	Local nPosEmp	:= 0
	Local nQtdPag	:= 0

	Local aCpos     := {}
	Local cPagsAux	:= ""
	Local aCposCab  := {}
	Local cConteudo := ""
	Local aCriaServ := {}
	Local aCont     := {}
	Local aEmpresas := FwLoadSM0()
	Local nQtdReg		:= 0
	Local lItens    := .F.

	Local cQryRes   := ""
	Local cCgcEmp	:= IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")
	Local cNota		:= IIf(::cNota <> Nil , ::cNota , "")
	Local cSerie	:= IIf(::cSerie <> Nil , ::cSerie , "")
	Local cCliente	:= IIf(::cCLiente <> Nil , ::cCliente , "")
	Local cChaveNF	:= IIf(::cChaveNF <> Nil , ::cChaveNF , "")
	Local nPage		:= 1

	Private cAlsQry   := CriaTrab(Nil,.F.)
	Private cAlsRes   := CriaTrab(Nil,.F.)

	nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == cCgcEmp })

	If nPosEmp == 0
		cJson := '{"Erro":"Empresa nao cadastrada."}'
		::SetResponse( cJson )
		Return .T.
	Else
		RpcClearEnv()
		RpcSetEnv(aEmpresas[nPosEmp][1],aEmpresas[nPosEmp][2])
	EndIf   

	nPags	:= GetMV("FT_QTPAGIC",,10)

	cQuery 	:= " SELECT PR2.* FROM " + RetSqlName("PR2") + " (NOLOCK) PR2 "
	cQuery 	+= " INNER JOIN " + RetSqlName("PR1") + " (NOLOCK) PR1 "
	cQuery 	+= " ON PR2_FILIAL = PR1_FILIAL AND PR2_CODIGO = PR1_CODIGO "
	cQuery 	+= " WHERE PR1_CODPZA = '000027' AND PR1.D_E_L_E_T_ = ' '  AND PR2.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	While !(cAlsQry)->(Eof())

		If nCount == 1
			cQryRes := " SELECT  "
			cQryRes += (cAlsQry)->PR2_CPODES 

		Else
			cQryRes += " , " + (cAlsQry)->PR2_CPODES  

		EndIf

		AADD(aCpos, Alltrim((cAlsQry)->PR2_CPODES) )
		AADD(aCposCab, Alltrim((cAlsQry)->PR2_CPOORI))

		If (cAlsQry)->PR2_ISFUNC == "S"
			AADD(aCont, Alltrim( (cAlsQry)->PR2_CONTEU ))
		Else
			AADD(aCont, "")
		EndIf

		nCount++
		(cAlsQry)->(DbSkip())

	End

	If !Empty(cQryRes)

		cQryRes += CRLF + " ,F2_SERIE, F2_FILIAL FROM "  + RetSqlName("SF2") + " (NOLOCK) SF2 
		//cQryRes += CRLF + " INNER JOIN " + RetSqlName("SD2") + " SD2 "
		//cQryRes += CRLF + " ON D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_FILIAL = F2_FILIAL"  
		cQryRes += CRLF + " WHERE SF2.D_E_L_E_T_ = '' AND F2_XHRENT <> '' AND F2_XDTENT <> '' "

		//Numero do pedido
		If !Empty(cNota)
			cQryRes += CRLF + " AND F2_DOC = '" + cNota + "'  "
		EndIf

		If !Empty(cNota)
			cQryRes += CRLF + " AND F2_SERIE = '" + cSerie + "'  "
		EndIf

		If !Empty(cCliente)
			cQryRes += CRLF + " AND F2_CLIENTE = '" + cCliente + "'  "
		EndIf

		If !Empty(cChaveNF)
			cQryRes += CRLF + " AND F2_CHVNFE = '" + cChaveNF + "'  "
		EndIf

		If Select(cAlsRes) > 0; (cAlsRes)->(dbCloseArea()); Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryRes),cAlsRes,.T.,.T.)

		If SUBSTR(cPagsAux,1,1) == "0"
			nQtdPag := 1    			
		ElseIf At(".",cPagsAux) <> 0 
			nQtdPag := Val(SUBSTR(cPagsAux,1,( At(".",cPagsAux)-1 )))
			nQtdPag++
		Else
			nQtdPag := Val(cPagsAux)
		EndIf		

		If !(cAlsRes)->(Eof()) 
			nQtdReg		:= Contar(cAlsRes,"!Eof()")

			(cAlsRes)->(dbGoTop())
		Endif 

		While !(cAlsRes)->(Eof()) 

			If nLine == 1

				//Cria serviço no montitor
				aCriaServ := U_MonitRes("000027", 1, nQtdReg)   
				cIdPZB 	  := aCriaServ[2]

				cJson := '{"NFs":['

			EndIf

			cJson += "{"

			For nX := 1 to Len(aCpos)

				If SUBSTR(aCpos[nX],1,2) == "F2"   

					If Empty(aCont[nX])    

						cConteudo := & ("(cAlsRes)->" + aCpos[nX])

						If ValType( cConteudo) == "N"
							cJson += '"' + aCposCab[nX] + '":'
							cJson += cValTochar(cConteudo)
						Else
							cConteudo   := Alltrim(cConteudo)
							cJson       += '"' + aCposCab[nX] + '":'
							cJson       += '"' + cConteudo + '"'
						EndIf

						cJson += ','

					Else

						dbselectarea(cAlsRes)

						cConteudo := &(aCont[nX])

						If ValType( cConteudo) == "N"
							cJson += '"' + aCposCab[nX] + '":'
							cJson += cValTochar(cConteudo)
						Else
							cConteudo   := Alltrim(cConteudo)
							cJson       += '"' + aCposCab[nX] + '":'
							cJson       += '"' + cConteudo + '"'
						EndIf

						cJson += ','

					EndIf

				Endif

			Next nX

			cJson += '"NumeroPaginas":"'+ cValToChar(nQtdPag) +'",'

			If nPage == nQtdPag
				cJson += '"IsLastPage":true,
			Else
				cJson += '"IsLastPage":false,
			EndIf

			cJson += '"lret' + cValTochar(nLine) + '":true,'

			cChave := (cAlsRes)->F2_DOC
			cChave += (cAlsRes)->F2_SERIE
			cChave += (cAlsRes)->F2_FILIAL

			For nWW := 1 to Len(aCpos)
				If SUBSTR(aCpos[nWW],1,2) == "D2"
					lItens := .T.
					Exit
				Endif 
			Next nWW


			If lItens // CAso não exista campo de itens, não imprimo a tag de itens
				//Itens
				cJson += '"itens":['
				//itens
				While cChave == ((cAlsRes)->F2_DOC + (cAlsRes)->F2_SERIE + (cAlsRes)->F2_FILIAL)   
					cJson += "{" 
					For nX := 1 to Len(aCpos)

						If SUBSTR(aCpos[nX],1,2) == "D2"

							dbselectarea(cAlsRes)

							If nX < Len(aCpos)

								If Empty(aCont[nX])   

									cConteudo := & ("(cAlsRes)->" + aCpos[nX])

								Else

									cConteudo := &(aCont[nX])

								Endif

								If ValType( cConteudo) == "N"
									cJson += '"' + aCposCab[nX] + '":'
									cJson += cValTochar(cConteudo)
								Else
									cConteudo   := Alltrim(cConteudo)
									cJson       += '"' + aCposCab[nX] + '":'
									cJson       += '"' + cConteudo + '"'
								EndIf

								cJson += ','

							Else

								If Empty(aCont[nX])   

									cConteudo := & ("(cAlsRes)->" + aCpos[nX])

								Else

									cConteudo := &(aCont[nX])

								Endif

								If ValType( cConteudo) == "N"
									cJson += '"' + aCposCab[nX] + '":'
									cJson += cValTochar(cConteudo)
								Else
									cConteudo   := Alltrim(cConteudo)
									cJson       += '"' + aCposCab[nX] + '":'
									cJson       += '"' + cConteudo + '"'
								EndIf

							EndIf
						EndIf   
					Next nX

					//Fecha Itens
					cJson += "},"
					//Fecha Itens
					//Endif 


					(cAlsRes)->(DbSkip())
				EndDo 


			Endif  

			If ! lItens
				cJson := Left(cJson, Rat(",", cJson)-1)
				// cJson += "}"
				// cJson += "]"
				cJson += "},"
			Else

				cJson := Left(cJson, Rat(",", cJson)-1)
				cJson += "]"
				cJson += "},"
			Endif 

			cMenssagem  := "Get realizado com sucesso."
			U_MonitRes("000027", 2, , cIdPZB, cMenssagem, .T., "Get de NFs -  Get Entrega NF", cJson, "", "", .F., .F.)

			nLine++

			(cAlsRes)->(DbSkip())

			If (cAlsRes)->(Eof()) .AND. (! lItens)
				cJson := Left(cJson, Rat(",", cJson)-1)
			Endif 
		End

		(cAlsRes)->(dbCloseArea())





		If Empty(cJson) 

			cJson += "{"
			cJson += '"NF":['
			cJson += "{" 
			cJson += '"errorMessage' + cValTochar(1) + '":"'+ "NF nao encontrada ou nao entregue" +'",'
			cJson += '"lret' + cValTochar(1) + '":false'
			cJson += "},"

		EndIf

		//Finaliza o processo na PZB
		U_MonitRes("000027", 3, , cIdPZB, , .T.)

	EndIf

cJson += "]}"

(cAlsQry)->(dbCloseArea())

::SetContentType("application/json")
::SetResponse( cJson )

Return(.T.)


WsRestFul GetDanfe Description "Geração de DANFE"

WsData cCgcEmp		As String 
WsData cDoc			As String 
WsData cSerie	    As String
WsData cPrefixo	    As String  
WsData cTipo	    As String  
WsData cParcela	    As String  Optional
WsData cCliente     As String Optional


WsMethod Get Description "Consulta de DANFE" WsSyntax "/GetDanfe"

End WsRestFul

WsMethod Get WsReceive cCgcEmp, cDoc, cSErie, cCliente, cPrefixo, cTipo, cPArcela WsService GetDanfe

	Local cQuery    := ""    
	Local aCpos     := {}
	Local aCposCab  := {}
	Local aCont     := {}
	Local cJson     := ""
	Local cQryRes   := ""
	Local nCount    := 1
	Local nX
	Local cConteudo := ""
	Local cIdPZB	:= ""
	Local aCriaServ := {}
	Local nLine     := 1
	Local nPosEmp	:= 0
	Local cDANFE      := ''
	Local cDoc    	:= IIf(::cDoc <> Nil  , ::cDoc  , "")
	Local cCgcEmp   := IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")
	Local cSerie    := IIf(::cSErie <> Nil , ::cSErie , "")
	Local cCliente  := IIf(::cCliente <> Nil , ::cCliente , "")
	Local cPrefixo  := IIf(::cPrefixo <> Nil , ::cPrefixo , "")
	Local cTipo    	:= IIf(::cTipo <> Nil  , ::cTipo  , "")
	Local cPArcela  := IIf(::cParcela <> Nil  , ::cParcela  , "")
	Local aAux      := {}

	Local aEmpresas := FwLoadSM0()
	Local cTabQry   := GetNExtAlias()
	Local dEmissao  := ''
	Local cLoja 	:= ''
	Private cAlsQry   := CriaTrab(Nil,.F.)
	Private cAlsRes   := CriaTrab(Nil,.F.)

	Private oDanfe
	Private MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05
	Private lPreview := .F.                      
	Private nConsNeg := 0.4 // Constante para concertar o cálculo retornado pelo GetTextWidth para fontes em negrito.
	Private nConsTex := 0.5 // Constante para concertar o cálculo retornado pelo GetTextWidth.
	Private cArquivo := ""    
	Private PixelX 
	Private PixelY 

	nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == cCgcEmp })

	If nPosEmp == 0
		cJson := '{"Erro":"Empresa nao cadastrada."}'
		::SetResponse( cJson )
		Return .T.
	Else
		RpcClearEnv()
		RpcSetEnv(aEmpresas[nPosEmp][1],aEmpresas[nPosEmp][2])
	EndIf


	//GetDanfe

	cFilREg := cFIlant 

	cQuery:= " SELECT E1_SERIE, E1_FILORIG, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE,"
	cQuery+= " E1_LOJA, E1_NOMCLI, E1_EMISSAO, E1_VENCREA, E1_VALOR,E1_SALDO, E1_XINDSEE, E1_XENVMAI "
	cQuery+= " FROM " + RetSqlName("SE1") + " (NOLOCK) SE1 "      
	cQuery+= " WHERE E1_FILIAL  = '"+ aEmpresas[nPosEmp][2] +     "'"
	cQuery+= " AND   E1_NUM     = '"+ cDoc +  "'" 
	cQuery+= " AND   E1_PREFIXO = '"+ cPrefixo + "'"
	cQuery+= " AND   E1_TIPO = '"+ cTipo + "'"

	If ! EMpty(cParcela)
		cQuery+= " AND   E1_PARCELA = '"+ cParcela + "'"
	Endif 

	If ! EMpty(cCliente)
		cQuery+= " AND   E1_CLIENTE = '"+ cCliente + "'"
	Endif 

	cQuery+= " AND   SE1.D_E_L_E_T_ <> '*'        "   

	If Select(cTabQry) > 0
		(cTabQry)->(DbCloseArea())
	Endif	

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTabQry, .F., .T.)  

	nTot := Contar(cTabQry,"!Eof()") 

	(cTabQry)->(DbGoTop())	


	IF (cTabQry)->(eOF())	

		cJson += "{"
		cJson += '"DANFE":['
		cJson += "{" 
		cJson += '"errorMessage' + cValTochar(1) + '":"'+ "Nota Fiscal nao encontrada" +'",'
		cJson += '"lret' + cValTochar(1) + '":false'
		cJson += "}"
		cJson += "]"
		cJson += "}"

		::SetContentType("application/json")
		::SetResponse( cJson )

		Return(.T.)
	Else	
		cSerie := AVKEY((cTabQry)->(E1_SERIE),"F2_SERIE")	
		lExistNfe:= .F.
		lEnvio 	 := .F.

		cArqDest := ""
		cDirDest := ""

		dEmissao:= dDatabase
		cIdEnt := RetIdEnti()
		cAviso := ""
		cErro  := ""     
		cModalidade :=""
		aNota := {}

		nTamNota  := TamSX3('F2_DOC')[1]
		nTamSerie := TamSX3('F2_SERIE')[1]

		Pergunte("NFSIGW",.F.)
		MV_PAR01 := PadR(cDoc,  nTamNota)
		MV_PAR02 := PadR(cDoc,  nTamNota)
		MV_PAR03 := PadR(cSerie, nTamSerie) 
		MV_PAR04 := 2
		MV_PAR05 := 2

		//conout("nome arquivo")
		cNomeArq 		:= "danfe_"+cEmpant+"_"+cFilant+"_"+alltrim(cSerie)+"_"+alltrim(cDoc)
		lAdjustToLegacy := .F.                                
		oDanfe    		:= FWMSPrinter():New(cNomeArq, IMP_PDF, lAdjustToLegacy,, .F. , /*[ lTReport]*/, /*[ @oPrintSetup]*/, /*[ cPrinter]*/, /*[ lServer]*/, , /*[ lRaw]*/, .F. )

		PixelX := odanfe:nLogPixelX()
		PixelY := odanfe:nLogPixelY()

		oDanfe:lInJob 	:= .T. //Seta Processamento em JOB	 

		//sfDanpdf(cIdEnt,MV_PAR01,MV_PAR01,oDanfe,cNomeArq,.t.)

		oDanfe:SetResolution(78) //Tamanho estipulado para a Danfe
		oDanfe:SetPortrait()
		oDanfe:SetPaperSize(DMPAPER_A4)
		oDanfe:SetMargin(60,60,60,60)
		oDanfe:nDevice := IMP_PDF   
		oDanfe:lInJob  := .T.
		oDanfe:lServer := .T.

		//StaticCall(DanfeII,DanfeProc,@oDanfe,.F.,cIdEnt,MV_PAR01,MV_PAR01,@lExistNfe) 
		//StaticCall(DanfeII,DanfeProc,@oDanfe,.F.,cIdEnt,MV_PAR01,MV_PAR03,@lExistNfe) 

		//StaticCall(DANFEII, DanfeProc, @oDanfe, .F., cIdent, , , @lExistNfe)

		If lExistNfe        
			oDanfe:cPathPdf := '\notas_wsportal\'
			conout("Antes do print novo")
			oDanfe:Print()
		Else
			If !lExistNfe       
				cJson += "{"
				cJson += '"DANFE":['
				cJson += "{" 
				cJson += '"errorMessage' + cValTochar(1) + '":"'+ "Nota Fiscal nao encontrada" +'",'
				cJson += '"lret' + cValTochar(1) + '":false'
				cJson += "}"
				cJson += "]"
				cJson += "}"

				::SetContentType("application/json")
				::SetResponse( cJson )

				Return(.T.)
			Endif

		EndIf
		FreeObj(oDanfe)
		oDanfe := Nil                                      

		lArqRel :=  .F.

		For nI := 1 to 10
			IF !FILE( "\notas_wsportal\"+cNomeArq+".pd_")  
				lArqRel := .T.
				Exit
			Else
				//--Aguarda
				Sleep( 2000 )
			EndiF	
		Next nI

		IF !lArqRel

			cJson += "{"
			cJson += '"DANFE":['
			cJson += "{" 
			cJson += '"errorMessage' + cValTochar(1) + '":"'+ "PDF Não gerado" +'",'
			cJson += '"lret' + cValTochar(1) + '":false'
			cJson += "}"
			cJson += "]"
			cJson += "}"

			::SetContentType("application/json")
			::SetResponse( cJson )

			Return(.T.)

		Else
			cArq :=  FOPEN( "\notas_wsportal\"+cNomeArq+".pdf") 
			conout(cArq)
			Conout("abriu arquivo")                            	
			If cArq <> -1
				nLen := fSeek(cArq,0,2)  
				Conout(nLen)
				fSeek(cArq,0,0)
				cBuffer  := ""
				nBtLidos  := FREAD(cArq, @cBuffer, nLen)
				cArqInf  := @cBuffer  		
				fclose(cArq)		
				Conout(cArqInf)

				cDANFE := Encode64(cArqInf)      

				If FERASE("\notas_wsportal\"+cNomeArq+".pdf") == -1
					cJson := '{Falha na deleçao do arquivo}'
					::SetResponse( cJson )
					Return .T.
				Else
					conout('Arquivo deletado com sucesso.')
				Endif   

				aAdd(aAux, .T.) 
				aAdd(aAux, "Arquivo gerado com Sucesso.")
				aAdd(aAux,cArqInf) 

			Else
				cJson += "{"
				cJson += '"DANFE":['
				cJson += "{" 
				cJson += '"errorMessage' + cValTochar(1) + '":"'+ "Não gerou PDF" +'",'
				cJson += '"lret' + cValTochar(1) + '":false'
				cJson += "}"
				cJson += "]"
				cJson += "}"

				::SetContentType("application/json")
				::SetResponse( cJson )

				Return(.T.)

			EndIF 
		eNDif		
	EndIF   

	//GetDanfe
	//

	//cDAnfe := 
	nPags	:= GetMV("FT_QTPAGIC",,10)


	If ! Empty(cDANFE)

		nQtdReg		:= 1
		nQtdPag		:= 1
		cPagsAux	:= cValToChar(nQtdPag)

		//Cria serviço no montitor
		aCriaServ := U_MonitRes("000028", 1, nQtdReg)   
		cIdPZB 	  := aCriaServ[2]

		cJson := '{'
		cJson += '"NumeroPaginas":"'+ cValToChar(nQtdPag) +'",'

		//If nPage == nQtdPag
		cJson += '"IsLastPage":true,
		//Else
		//cJson += '"IsLastPage":false,
		//EndIf

		cJson += '"DANFE":['

	Else

		cJson += "{"
		cJson += '"DANFE":['
		cJson += "{" 
		cJson += '"errorMessage' + cValTochar(1) + '":"'+ "Nota Fiscal nao encontrada" +'",'
		cJson += '"lret' + cValTochar(1) + '":false'
		cJson += "}"
		cJson += "]"
		cJson += "}"

		::SetContentType("application/json")
		::SetResponse( cJson )

		Return(.T.)

	EndIf

	If ! Empty(cDANFE)

		cJson += "{"

		cConteudo := 'DANFE'//&(aCont[nX])

		cConteudo   := Alltrim(cConteudo)
		cJson       += '"' + 'DANFE' + '":'
		cJson       += '"' + cDANFE + '"'
		cJson += ','

		cJson += '"lret' + cValTochar(nLine) + '":true'
		cJson += "},"

		cMenssagem  := "Get realizado com sucesso."
		U_MonitRes("000028", 2, , cIdPZB, cMenssagem, .T., "Get de DANFE", cJson, "", "", .F., .F.)

		nLine++

		//(cAlsRes)->(DbSkip())

		If !Empty(cDANFE) //.And. !Empty(cCodBar)


			cJson := Left(cJson, Rat(",", cJson)-1)

			//EndIf

		Else


		EndIf

	EndIf

//Finaliza o processo na PZB
U_MonitRes("000028", 3, , cIdPZB, , .T.)

cJson += "]}"

::SetContentType("application/json")
::SetResponse( cJson )

Return(.T.)



WsRestFul GetBoleto Description "Geração de Boleto"

WsData cCgcEmp		As String 
WsData cDoc			As String 
WsData cPrefixo	    As String 
WsData cParcela     As String Optional


WsMethod Get Description "Consulta de Boleto " WsSyntax "/GetBoleto"

End WsRestFul

WsMethod Get WsReceive cCgcEmp, cDoc, cPrefixo, cParcela WsService GetBoleto

	Local lRet    := .T.
	Local cTab    := ""
	Local cQuery1 := ""
	Local cQuery2 := ""
	Local cEmp    := ""
	Local aEmp    := {}
	Local cArq    := "\boletos_email\"
	Local cTabQry := GetNextAlias()  
	Local cTabQry2:= GetNextAlias()
	Local cBanco  := ""
	Local cAg     := ""
	Local cConta  := ""
	Local cSubCta := ""
	Local cDoc   := IIf(::cDoc <> Nil  , ::cDoc  , "")
	Local cCgcEmp   := IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")
	Local cPrefixo    := IIf(::cPrefixo <> Nil , ::cPrefixo , "")
	Local cParcela  := IIf(::cParcela <> Nil , ::cParcela , "")
	Local aAux      := {}
	Local cBoleto   := ''
	Local aEmpresas := FwLoadSM0()
	Local cTabQry   := GetNExtAlias()
	Local dEmissao  := ''
	Local cLoja 	:= ''
	Local cJson     := ''
	Local nX		:= 0
	Local nY		:= 0
	Local nDE		:= 0
	Local nPags		:= 0
	Local nLine     := 1
	Local nCount    := 1
	Local nPosEmp	:= 0
	Local nQtdPag	:= 0
	Local cError    := ''
	Local aRetBol   := .F.
	Private cAlsQry   := CriaTrab(Nil,.F.)
	Private cAlsRes   := CriaTrab(Nil,.F.)


	nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == cCgcEmp })

	If nPosEmp == 0
		cJson := '{"Erro":"Empresa nao cadastrada."}'
		::SetResponse( cJson )
		Return .T.
	Else
		RpcClearEnv()
		RpcSetEnv(aEmpresas[nPosEmp][1],aEmpresas[nPosEmp][2])
	EndIf

	//GetBoleto
	cQuery:= " SELECT E1_FILORIG, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE,"
	cQuery+= " E1_LOJA, E1_NOMCLI, E1_EMISSAO, E1_VENCREA, E1_VALOR,E1_SALDO, E1_XINDSEE, E1_XENVMAI "
	cQuery+= " FROM " + RetSqlName("SE1") + " (NOLOCK) SE1 "    
	//
	cQuery+= " INNER JOIN  " + RetSqlName("SEA") + "  SEA WITH(NOLOCK) ON  (SEA.D_E_L_E_T_= '' AND EA_FILORIG  = E1_FILIAL
    cQuery+= " AND EA_PREFIXO = E1_PREFIXO AND EA_NUM = E1_NUM AND EA_PARCELA = E1_PARCELA AND EA_TIPO = E1_TIPO AND EA_NUMBOR = E1_NUMBOR)
	//  
	cQuery+= " WHERE E1_FILIAL  = '"+ aEmpresas[nPosEmp][2] +     "'"
	cQuery+= " AND   E1_NUM     = '"+ cDoc +  "'" 
	cQuery+= " AND   E1_PREFIXO = '"+ cPrefixo + "'"
	cQuery+= " AND   E1_PARCELA = '"+ cParcela + "'"
	cQuery+= " AND   SE1.D_E_L_E_T_ <> '*'        "   

	If Select(cTabQry) > 0
		(cTabQry)->(DbCloseArea())
	Endif	

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTabQry, .F., .T.)  

	nTot := Contar(cTabQry,"!Eof()") 

	(cTabQry)->(DbGoTop())

	If nTot > 0

		If Empty((cTabQry)->E1_XINDSEE)

			cQuery2 := " SELECT EE_CODIGO AS BANCO, EE_AGENCIA AS AG, EE_CONTA AS CONTA, EE_SUBCTA AS SUBCTA FROM " + RetSqlName("SEE") + " SEE "   
			cQuery2 += " WHERE SEE.D_E_L_E_T_ <> '*'  AND EE_RETAUT IN('1','3') "
			cQuery2 += " AND EE_FILIAL  = '" + aEmpresas[nPosEmp][2] + "' "

			If Select(cTabQry2) > 0
				(cTabQry2)->(DbCloseArea())
			Endif	

			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery2), cTabQry2, .F., .T.)  

			nTot2 := Contar(cTabQry2,"!Eof()") 

			(cTabQry2)->(DbGoTop())

			If nTot2 > 0
				Conout("Encontrou Parâmetros de banco: "+(cTabQry2)->BANCO+"/"+(cTabQry2)->AG+"/"+(cTabQry2)->CONTA+"/"+(cTabQry2)->SUBCTA)
				cBanco  := (cTabQry2)->BANCO
				cAg     := (cTabQry2)->AG
				cConta  := (cTabQry2)->CONTA
				cSubCta := (cTabQry2)->SUBCTA
			Endif

			(cTabQry2)->(DbCloseArea())

		Else

			cBanco  := Substr((cTabQry)->E1_XINDSEE,3,3)
			cAg     := Substr((cTabQry)->E1_XINDSEE,6,5)
			cConta  := Substr((cTabQry)->E1_XINDSEE,11,10)
			cSubCta := Substr((cTabQry)->E1_XINDSEE,21,3)

		Endif	

		 aRetBol := U_BOLMAIL2(cBanco,cAg,cConta,cSubCta,(cTabQry)->E1_PREFIXO,(cTabQry)->E1_NUM,(cTabQry)->E1_PARCELA,.T.)
		 
		 If (cTabQry)->E1_SALDO = 0
		 	aRetBol[1][1] := .F.
		 	aRetBol[1][2] := "Boleto já liquidado"
		 Endif 
		 
		 If aRetBol[1][1]
			Sleep(1000)
			File2Printer("Boleto_"+ aEmpresas[nPosEmp][1] + aEmpresas[nPosEmp][2] + Alltrim((cTabQry)->E1_PREFIXO) + Alltrim((cTabQry)->E1_NUM)+".REL", "PDF")
			//File2Printer(oPrint:cPathPDF+cArquivo+".REL", "PDF")

			cArq += "Boleto_"+ aEmpresas[nPosEmp][1] + aEmpresas[nPosEmp][2] + Alltrim((cTabQry)->E1_PREFIXO) + Alltrim((cTabQry)->E1_NUM)+".PDF"

			if File(cArq)
				Sleep(1000)
				nH := fOpen(cArq)
				Sleep(1000)
				nTAmanho := fSeek(nH,0,2) 
				conout("abriu arquivo" + str(nH))
				if nH == -1
					cJson += "{"
					cJson += '"DANFE":['
					cJson += "{" 
					cJson += '"errorMessage' + cValTochar(1) + '":"'+ "Falha na abertura do arquivo" +'",'
					cJson += '"lret' + cValTochar(1) + '":false'
					cJson += "}"
					cJson += "]"
					cJson += "}"

					::SetContentType("application/json")
					::SetResponse( cJson )

					Return(.T.)
				else


					nTAmanho := fSeek(nH,0,2) 



					conout("Tamanho" + str(nTAmanho))
					If nTAmanho <= 745000



						//nTamanho := fSeek(nH, 0, 2)
						cRead := space(nTamanho)

						conout("cRead" + cRead)
						Sleep(1000)
						fSeek(nH,0,0)
						Sleep(1000)
						fRead(nH,@cRead,nTamanho)
						conout(cRead)
						cBoleto := Encode64(cRead) 

						If Empty(cRead)
							For nN = 1 to 15
								Conout(cREad + "vazio" + Str(nN) + "tamanho" + str(nTamanho) )
								fRead(nH,@cRead,nTamanho)
								If !Empty(cRead)
									cBoleto := Encode64(cRead) 
									Exit
								Endif 
							Next
						Endif  

						If Empty(cBoleto)
							cBoleto := Encode64(cRead) 
						Endif

						fclose(nH)		





						Conout("Boleto Gerado com Sucesso!")
					else
						cJson := '{'+ "Tamanho do arquivo " + cArq + " ultrapassa limite suportado pelo WebService " + '}'
						::SetResponse( cJson )
						Return .T.

					endif

					//cBoleto      := Encode64(cRead)		

				endif
				fClose(nH)
			else
				cJson += "{"
				cJson += '"BOLETO":['
				cJson += "{" 
				cJson += '"errorMessage' + cValTochar(1) + '":"'+ "Titulo nao encontrado" +'",'
				cJson += '"lret' + cValTochar(1) + '":false'
				cJson += "}"
				cJson += "]"
				cJson += "}"

				::SetContentType("application/json")
				::SetResponse( cJson )

				Return(.T.)
			endif
		Else
		cErro := aRetBol[1][2]
		Endif

		(cTabQry)->(DbCloseArea())

		// Get Boleto

		nPags	:= GetMV("FT_QTPAGIC",,10)
	Endif 
	
	If ! Empty(cBoleto)

		nQtdReg		:= 1
		nQtdPag		:= 1
		cPagsAux	:= cValToChar(nQtdPag)

		//Cria serviço no montitor       
		aCriaServ := U_MonitRes("000029", 1, nQtdReg)   
		cIdPZB 	  := aCriaServ[2]

		cJson := '{'
		cJson += '"NumeroPaginas":"'+ cValToChar(nQtdPag) +'",'

		cJson += '"IsLastPage":true,
		cJson += '"Boleto":['

	Else
		
		If Empty(cErro)
			cErro := "Titulo nao encontrado"
		Endif 
		
		cJson += "{"
		cJson += '"Boleto":['
		cJson += "{" 
		cJson += '"errorMessage' + cValTochar(1) + '":"'+ cErro +'",'
		cJson += '"lret' + cValTochar(1) + '":false'
		cJson += "}"
		cJson += "]"
		cJson += "}"

		::SetContentType("application/json")
		::SetResponse( cJson )

		Return(.T.)

	EndIf

	If ! Empty(cBoleto)

		cJson += "{"

		cConteudo := 'Boleto'

		cConteudo   := Alltrim(cConteudo)
		cJson       += '"' + 'Boleto' + '":'
		cJson       += '"' + cBoleto + '"'
		cJson += ','

		cJson += '"lret' + cValTochar(nLine) + '":true'
		cJson += "},"

		cMenssagem  := "Get realizado com sucesso."
		U_MonitRes("000029", 2, , cIdPZB, cMenssagem, .T., "Get de Boleto", cJson, "", "", .F., .F.)

		nLine++

		If !Empty(cBoleto)

			cJson := Left(cJson, Rat(",", cJson)-1)

		Else

		EndIf

	EndIf

//Finaliza o processo na PZB
U_MonitRes("000029", 3, , cIdPZB, , .T.)

cJson += "]}"

::SetContentType("application/json")
::SetResponse( cJson )

Return(.T.)


//Philip

WsRestFul PostOrc Description "Metodo Responsavel por Cadastrar Pedidos de Venda"

WsData cCgcEmp		As String

WsMethod Post Description "Cadastro de Pedidos de Venda" WsSyntax "/PostOrc"

End WsRestFul

WsMethod Post WsReceive cCgcEmp WsService PostOrc

	Local cBody     := ::GetContent()
	Local oJsoAux   := Nil
	Local cQuery    := ""
	Local oLoc		:= Nil
	Local cLoc		:= ""
	Local cAlsQry   := CriaTrab(Nil,.F.)
	Local nX
	Local nY
	Local cStrErro  := ""
	Local cEstado	:= ""
	Local aDados    := {}
	Local _aAux		:= {}
	Local _aCab	    := {}
	Local _aItens	:= {}
	Local _aParcelas := {}
	Local aCriaServ := {}
	Local nErro     := 0
	Local cJson     := ""
	Local cCgcEmp   := IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")
	Local aEmpresas := FwLoadSM0()
	Local oBkpJso   := Nil
	Local lAUTRESERVA  := .F.
	Local nTamTabela


	Private lMsHelpAuto := .T. //Variavel de controle interno do ExecAuto
	Private lMsErroAuto := .F. //Variavel que informa a ocorrência de erros no ExecAuto
	Private INCLUI := .T. //Variavel necessária para o ExecAuto identificar que se trata de uma inclusão
	Private ALTERA := .F. //Variavel necessária para o ExecAuto identificar que se trata de uma inclusão
	Private lAutoErrNoFile := .T.


	nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == cCgcEmp })

	nTamTabela := TamSX3("LR_TABELA")[1]

	If nPosEmp == 0
		cJson := '{"Erro":"Empresa nao cadastrada."}'
		::SetResponse( cJson )
		Return .T.
	Else
		RpcClearEnv()
		RpcSetEnv(aEmpresas[nPosEmp][1],aEmpresas[nPosEmp][2])
	EndIf

	FWJsonDeserialize(cBody, @oJsoAux)

	SM0->(DbSetOrder(1))

	cQuery := " SELECT PR2.* FROM " + RetSqlName("PR2") + " (NOLOCK) PR2 "
	cQuery += " INNER JOIN " + RetSqlName("PR1") + " (NOLOCK) PR1 "
	cQuery += " ON PR2_FILIAL = PR1_FILIAL AND PR2_CODIGO = PR1_CODIGO "
	cQuery += " WHERE PR1_CODPZA = '000030' AND PR1.D_E_L_E_T_ = ' '  AND PR2.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	If len(oJsoAux:Orcamentos) > 0

		cJson := "{"

		//Cria serviço no montitor
		aCriaServ := U_MonitRes("000030", 1, Len(oJsoAux:Orcamentos) )   
		cIdPZB 	  := aCriaServ[2]

		For nX := 1 to len(oJsoAux:Orcamentos)

			(cAlsQry)->(DbGoTop())

			_aCab      := {}

			//aAdd(_aCab,   {"C5_FILIAL", xFilial("SC5"), nil})
			//aAdd(_aCab,   {"C5_NUM", GetSXeNum("SC5","C5_NUM","C5_NUM"), nil})

			While !(cAlsQry)->(Eof())

				If SUBSTR(Alltrim((cAlsQry)->PR2_CPODES),1,2) == "LQ"

					cCpo        := Alltrim((cAlsQry)->PR2_CPOORI)

					If (cAlsQry)->PR2_TPCONT == "1"
						cConteudo := &("oJsoAux:Orcamentos[" + cValTochar(nX) + "]:" + cCpo)  
					Else
						cConteudo := &((cAlsQry)->PR2_CONTEU)
					EndIf

					If TAMSX3(AllTrim((cAlsQry)->PR2_CPODES))[3] == "D"
						cConteudo := StoD(cConteudo)
					EndIf

					aAdd(_aCab, {Alltrim((cAlsQry)->PR2_CPODES), cConteudo, nil})

				EndIf

				(cAlsQry)->(DbSkip())
			End

			(cAlsQry)->(DBGoTop())

			For nY := 1 To Len(oJsoAux:Orcamentos[nX]:Itens)

				While !(cAlsQry)->(Eof())

					If SUBSTR(Alltrim((cAlsQry)->PR2_CPODES),1,2) == "LR"

						cCpo        := Alltrim((cAlsQry)->PR2_CPOORI)
						/*
						If Alltrim((cAlsQry)->PR2_CPOORI) == 'LR_ENTREGA''
						If &((cAlsQry)->PR2_CONTEU) == '3'
						lAUTRESERVA := .T.
						Endif 
						Endif 
						*/

						If (cAlsQry)->PR2_TPCONT == "1"
							cConteudo := &("oJsoAux:Orcamentos[" + cValTochar(nX) + "]:Itens[" + cValTochar(nY) + "]:" + cCpo)  
						Else
							cConteudo := &((cAlsQry)->PR2_CONTEU)
						EndIf

						aAdd(_aAux, {Alltrim((cAlsQry)->PR2_CPODES), cConteudo, nil})

					EndIf

					(cAlsQry)->(DbSkip())
				End

				aAdd(_aItens,_aAux)
				_aAux := {}
				(cAlsQry)->(DBGoTop())

			Next nY


			If lAUTRESERVA

			Endif 

			aAdd( _aParcelas, {} )
			aAdd( _aParcelas[Len(_aParcelas)], {"L4_DATA" , dDatabase , NIL} )
			aAdd( _aParcelas[Len(_aParcelas)], {"L4_VALOR" , 20 , NIL} )
			aAdd( _aParcelas[Len(_aParcelas)], {"L4_FORMA" , "R$ " , NIL} )
			aAdd( _aParcelas[Len(_aParcelas)], {"L4_ADMINIS" , " " , NIL} )
			aAdd( _aParcelas[Len(_aParcelas)], {"L4_NUMCART" , " " , NIL} )
			aAdd( _aParcelas[Len(_aParcelas)], {"L4_FORMAID" , " " , NIL} )
			aAdd( _aParcelas[Len(_aParcelas)], {"L4_MOEDA" , 0 , NIL} )




			_aCab	   := FWVetByDic(_aCab,"SLQ",.F.) //Organiza o array
			_aItens	   := FWVetByDic(_aItens,"SLR",.T.) //Organiza o array
			_aParcelas := FWVetByDic(_aItens,"SL4",.T.) //Organiza o array

			SetFunName("LOJA701")

			MSExecAuto({|a,b,c,d,e,f,g,h| Loja701(a,b,c,d,e,f,g,h)},.F.,3,"","",{},_aCab,_aItens ,_aParcelas)

			::SetContentType("application/json")

			cMenssagem  := "Post Orcamentos"

			If lMsErroAuto

				cStrErro := ""

				aErros 	:= GetAutoGRLog() // retorna o erro encontrado no execauto.
				nErro   := Ascan(aErros, {|x| "INVALIDO" $ alltrim(Upper(x))  } )

				If nErro > 0
					cStrErro += aErros[ nErro ]
				Else
					For nErro := 1 To Len( aErros )

						cStrErro += ( aErros[ nErro ] + cEnt )

					Next nErro

				EndIf

				cStrErro := Alltrim(cStrErro)

				//RollBackSX8()



				U_MonitRes("000030", 2, , cIdPZB, cMenssagem, .F., cStrErro, "", cBody, "", .F., .F.)

				//Finaliza o processo na PZB
				U_MonitRes("000030", 3, , cIdPZB, , .F.)

				cJson += '"Orcamentos":['
				cJson += "{" 
				cJson += '"errorMessage' + cValTochar(nX) + '":"' + cStrErro + '",'
				cJson += '"lret' + cValTochar(nX) + '":false,'
				cJson += '"Orcamento":"' + SC5->C5_NUM + '"'
				cJson += "},"

			Else

				ConfirmSx8()

				U_MonitRes("000030", 2, , cIdPZB, cMenssagem, .T., "Orcamento incluso com sucesso", "", cBody, "", .F., .F.)

				//Finaliza o processo na PZB
				U_MonitRes("000030", 3, , cIdPZB, , .T.)

				cJson += '"Orcamentos":['
				cJson += "{" 
				cJson += '"lret' + cValTochar(nX) + '":true,'
				cJson += '"Orcamento":"' + SC5->C5_NUM + '"' //corrigido caio menezes - 28/01/2020
				cJson += "},"

			EndIf

		Next nX

		cJson := Left(cJson, Rat(",", cJson)-1)
		cJson += "]}"

		::SetResponse( cJson )

	EndIf

//(cAlsQry)->(dbCloseArea())

Return(.T.)





WSRESTFUL GetEstoques DESCRIPTION "Serviço para capturar o estoque de uma empresa"

WSDATA cCgcEmp AS String
WSDATA cCgcFor AS String

WSMETHOD GET DESCRIPTION "Serviço de validação de pedido de venda" WSSYNTAX "/GetEstoques"

END WSRESTFUL

WSMETHOD Get WSRECEIVE cCgcEmp,cCgcFor WSSERVICE GetEstoques


	Local cJson     := ""
	Local cCgcEmp   := IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")
	Local cCgcFor   := IIf(::cCgcFor <> Nil , ::cCgcFor , "")
	Local aEmpresas := FwLoadSM0()
	Local nCount    := 1
	Local aCpos		:= {}
	Local aCposCab	:= {}
	Local aCont		:= {}

	Private cAlsQry   := CriaTrab(Nil,.F.)
	Private cAlsRes   := CriaTrab(Nil,.F.)

	nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == cCgcEmp })

	If nPosEmp == 0
		cJson := '{"Erro":"Empresa nao cadastrada."}'
		::SetResponse( cJson )
		Return .T.
	Else
		RpcClearEnv()
		RpcSetEnv(aEmpresas[nPosEmp][1],aEmpresas[nPosEmp][2])
	EndIf

	//Cria serviço no montitor

	cIdPZB 	  := "000024"

	nPags	:= GetMV("FT_QTPAGIC",,10)

	cQuery := " SELECT PR2.* FROM " + RetSqlName("PR2") + " (NOLOCK) PR2 "
	cQuery += " INNER JOIN " + RetSqlName("PR1") + " (NOLOCK) PR1 "
	cQuery += " ON PR2_FILIAL = PR1_FILIAL AND PR2_CODIGO = PR1_CODIGO "
	cQuery += " WHERE PR1_CODPZA = '000024' AND PR1.D_E_L_E_T_ = ' '  AND PR2.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	While !(cAlsQry)->(Eof())

		If nCount == 1
			cQryRes := " SELECT  "
			cQryRes += (cAlsQry)->PR2_CPODES
			cCampos	:= (cAlsQry)->PR2_CPODES
		Else
			If (cAlsQry)->PR2_ISFUNC <> "S"
				cQryRes += " , " + (cAlsQry)->PR2_CPODES
				cCampos	+= " , " + (cAlsQry)->PR2_CPODES
			EndIf
		EndIf

		AADD(aCpos, Alltrim((cAlsQry)->PR2_CPODES) )
		AADD(aCposCab, Alltrim((cAlsQry)->PR2_CPOORI))

		If (cAlsQry)->PR2_ISFUNC == "S"
			AADD(aCont, Alltrim( (cAlsQry)->PR2_CONTEU ))
		Else
			AADD(aCont, "")
		EndIf

		nCount++
		(cAlsQry)->(DbSkip())

	End

	If !Empty(cQryRes)
		cQryRes +=  " , SUM(B2_QATU) SALDO FROM " + RETSQLNAME("SB2") + " SB2 "
		cQryRes +=  " INNER JOIN " + RETSQLNAME("SB1") + " SB1  ON B1_COD = B2_COD"
		cQryRes +=  " WHERE B2_FILIAL = '" + xFilial("SB2") +"' "
		cQryRes +=  " AND B2_QATU > 0 "
		cQryRes +=  " AND SB2.D_E_L_E_T_ <> '*' "
		cQryRes +=  " AND SB1.D_E_L_E_T_ <> '*' "
		if !Empty(cCGCFor)
			cCodFor := POSICIONE("SA2",3,xFilial("SA2") + cCgcFor,"A2_COD")
			cQryRes +=  " AND B1_PROC = '" + cCodFor + "' "
		endif
		cQryRes +=  " GROUP BY " + cCampos
	EndIf

	If Select(cAlsRes) > 0; (cAlsRes)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryRes),cAlsRes,.T.,.T.)

	(cAlsRes)->(DbGoTop())
	cJson	:=	'{"produtos":['
	While (cAlsRes)->(!EOF())
		cJson += "{"

		For nX := 1 to Len(aCpos)

			If Empty(aCont[nX])    

				cConteudo := & ("(cAlsRes)->" + aCpos[nX])

				If ValType( cConteudo) == "N"
					cJson += '"' + aCposCab[nX] + '":'
					cJson += cValTochar(cConteudo)
				Else
					cConteudo   := Alltrim(cConteudo)
					cJson       += '"' + aCposCab[nX] + '":'
					cJson       += '"' + cConteudo + '"'
				EndIf

			Else

				cConteudo := &(aCont[nX])

				If ValType( cConteudo) == "N"
					cJson += '"' + aCposCab[nX] + '":'
					cJson += cValTochar(cConteudo)
				Else
					cConteudo   := Alltrim(cConteudo)
					cJson       += '"' + aCposCab[nX] + '":'
					cJson       += '"' + cConteudo + '"'
				EndIf

			EndIf

			cJson += ','

		Next nX

		cJson += '"Saldo":' + Str((cAlsRes)->SALDO )
		cJson += "},"

		cMenssagem  := "Get realizado com sucesso."
		U_MonitRes("000024", 2, , cIdPZB, cMenssagem, .T., "Get de Saldos", cJson, "", "", .F., .F.)

		(cAlsRes)->(DbSkip())
	ENDDO

	cJson := Left(cJson, Rat(",", cJson)-1)
	cJson += "]}"

	::SetContentType("application/json")
	::SetResponse( cJson )

Return .T.
