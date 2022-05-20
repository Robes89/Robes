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


User Function ResIntForn(aDados, lReprocess, lLote, cIdPZC)

Local aLogin    := {}
Local aCriaServ := {}
Local aHeader   := {}
Local aRequest  := {}
Local aRet      := {}
Local cIdPZB    := ""
Local cToken    := ""
Local cJson     := ""
Local cJsoRec   := ""
Local nX
Local nQtdReg
Local oRet
Local cAuthTime := Alltrim(GetMv("TI_AUTHRNW",, "00:05:00"))
Local cLastTime := ""

Default cIdPZC      := ""
Default lReprocess  := .F.
Default lLote       := .F.
Default aDados      := {}

    nQtdReg := Len(aDados)

    //Cria o log do servico no monitor
    If !lReprocess .Or. (lReprocess .And. lLote)
        
        aCriaServ := U_MonitRes("000022", 1, nQtdReg)

        cLastTime := Time()

        //Id gerado na criacao do servico
        cIdPZB := aCriaServ[2]

    EndIf
    
    If nQtdReg == 0
        U_MonitRes("000022", 3, , cIdPZB, , .F.)
        Return()
    EndIf
    
  
        
        
    AADD(aHeader, "ClientAPI_ID: 6951056a-bf4c-416e-8b80-366a2b97ac0e"  )
	ADD(aHeader, 'ClientAPI_Key: 1e8ec62d-7743-44ed-8558-a07477ea803e'  )
    AADD(aHeader, "Content-Type: application/json")

    
       
    For nX := 1 to len(aDados)

        cChave := aDados[nX][5]
        
        cJson := '{'
        If !Empty(aDados[nX][6]) //Se tiver preenchido o campo A2_XIDRESE, envia o ID para alteracao
            cJson += '"id":'     + Alltrim(EncodeUTF8(aDados[nX][6])) + ','
        EndIf
        cJson += '"nome":"'     + Alltrim(EncodeUTF8(aDados[nX][1])) + '",'
        cJson += '"cnpj":"'     + Alltrim(EncodeUTF8(aDados[nX][2])) + '",'
        cJson += '"agencia":"'  + Alltrim(EncodeUTF8(aDados[nX][3])) + '",'
        cJson += '"conta":"'    + Alltrim(EncodeUTF8(aDados[nX][4])) + '",'
        cJson += '"modelo":"FaturaEletronicaDeCartaoPCard",'
        cJson += '"tiposDeItem":[]'
        cJson += '}'

        aRequest := U_ResInteg("000022", cJson, aHeader,, .T.)

        If aRequest[1]
            
            oRet := aRequest[2]

            cMenssagem  := "Incluso com sucesso."
            cJsoRec     := aRequest[3]

            AADD(aRet, {aDados[nX][5], aDados[nX][1], aDados[nX][2], aDados[nX][3], aDados[nX][4], Alltrim(cValToChar(oRet:Id)) })

            DbSelectArea("SA2")
            SA2->(DbSetOrder(1))
            
            If SA2->(MsSeek(xFilial("SA2") + cChave)) .And. Empty(SA2->A2_XIDRESE)

                SA2->(RecLock("SA2"),.F.)

                    SA2->A2_XIDRESE := Alltrim(cValToChar(oRet:Id))

                SA2->(MsUnlock())

            EndIf
            
            U_MonitRes("000022", 2, , cIdPZB, cMenssagem, .T., cChave, cJson, cJsoRec, aDados[nX][1], lReprocess, lLote, cIdPZC)

        Else
            
            cMenssagem  := "Falha na inclusão."
            cJsoRec     := aRequest[3]

            U_MonitRes("000022", 2, , cIdPZB, cMenssagem, .F., cChave, cJson, cJsoRec, aDados[nX][1], lReprocess, lLote, cIdPZC)
        
        EndIf

    Next nX

    //Finaliza o processo na PZB
    U_MonitRes("000022", 3, , cIdPZB, , .T.)

Return(aRet)
