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

//----------------------------------------------------------------
/*/{Protheus.doc} NXVTEX01
Ponto de entrada para disponnibilizar envio do tracking de pedido
de venda. (Invoice)
@type method
@author Nexperti
@since 13/05/2020
@version 1.0
/*/
//----------------------------------------------------------------

//*******************
// GET ESTQOUE
//*******************

WsRestFul GetEst Description "Metodo Responsavel por Retornar Consulta de Produtos"

WsData cCgcEmp		As String Optional

WsMethod Get Description "Consulta de estoque" WsSyntax "/GetEst"

End WsRestFul

WsMethod Get WsReceive cCgcEmp WsService GetEst

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
//Local nPosEmp	:= 0
//Local cCgcEmp   := IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")

Private cAlsQry   := CriaTrab(Nil,.F.)
Private cAlsRes   := CriaTrab(Nil,.F.)

	cQuery := " SELECT PR3.* FROM " + RetSqlName("PR3") + " PR3 "
	cQuery += " INNER JOIN " + RetSqlName("PR2") + " PR2 "
	cQuery += " ON PR3_FILIAL = PR2_FILIAL AND PR3_CODIGO = PR2_CODIGO "
	cQuery += " WHERE PR2_CODPZA = '000005' AND PR2.D_E_L_E_T_ = ' '  AND PR3.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	While !(cAlsQry)->(Eof())

		If nCount == 1
			cQryRes := " SELECT  "
			cQryRes += (cAlsQry)->PR3_CPODES  
		Else
			If (cAlsQry)->PR3_ISFUNC <> "S"
				cQryRes += " , " + (cAlsQry)->PR3_CPODES  
			EndIf
		EndIf

		AADD(aCpos, Alltrim((cAlsQry)->PR3_CPODES) )
		AADD(aCposCab, Alltrim((cAlsQry)->PR3_CPOORI))

		If (cAlsQry)->PR3_ISFUNC == "S"
			AADD(aCont, Alltrim( (cAlsQry)->PR3_CONTEU ))
		Else
			AADD(aCont, "")
		EndIf

		nCount++
		(cAlsQry)->(DbSkip())

	End

	If !Empty(cQryRes)

		cQryRes += " FROM " + RetSqlName("SB2") + " SB2 "
		cQryRes += " WHERE "
		cQryRes += " SB2.D_E_L_E_T_ = ' ' ORDER BY B2_COD"

		If Select(cAlsRes) > 0; (cAlsRes)->(dbCloseArea()); Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryRes),cAlsRes,.T.,.T.)

		If !(cAlsRes)->(Eof()) 

			nQtdReg := Contar(cAlsRes,"!Eof()")

			//Cria serviÃ¯Â¿Â½o no montitor
			aCriaServ := U_MonitRes("000005", 1, nQtdReg)   
			cIdPZB 	  := aCriaServ[2]

			cJson := '{'
			cJson += '"produtos":['

			(cAlsRes)->(DbGoTop())

		Else

			cJson += "{"
			cJson += '"produtos":['
			cJson += "{" 
			cJson += '"errorMessage":"Nao existe saldo de estoque.",'
			cJson += '"lret":false'
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

			cJson += '"lret' + cValTochar(nLine) + '":true'
			cJson += "},"

			cMenssagem  := "Get realizado com sucesso."
			U_MonitRes("000005", 2, , cIdPZB, cMenssagem, .T., "Get de Produtos", cJson, "", "", .F., .F.)

			nLine++

			(cAlsRes)->(DbSkip())

		End

		(cAlsRes)->(dbCloseArea())

		//Finaliza o processo na PZB
		U_MonitRes("000005", 3, , cIdPZB, , .T.)

	EndIf

	cJson := Substr(cJson, 1, Rat(",", cJson) -1)
	
	cJson += "]}"

	(cAlsQry)->(dbCloseArea())

	::SetContentType("application/json")
	::SetResponse( cJson )

Return(.T.)

//*******************
// GET PRICE
//*******************

WsRestFul GetPrice Description "Metodo Responsavel por Retornar Consulta de preÃ¯Â¿Â½os"

WsData cCgcEmp		As String Optional

WsMethod Get Description "Consulta de preÃ¯Â¿Â½os" WsSyntax "/GetPrice"

End WsRestFul

WsMethod Get WsReceive cCgcEmp WsService GetPrice

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
//Local nPosEmp	:= 0
//Local cCgcEmp   := IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")

Private cAlsQry   := CriaTrab(Nil,.F.)
Private cAlsRes   := CriaTrab(Nil,.F.)

	cQuery := " SELECT PR3.* FROM " + RetSqlName("PR3") + " PR3 "
	cQuery += " INNER JOIN " + RetSqlName("PR2") + " PR2 "
	cQuery += " ON PR3_FILIAL = PR2_FILIAL AND PR3_CODIGO = PR2_CODIGO "
	cQuery += " WHERE PR2_CODPZA = '000006' AND PR2.D_E_L_E_T_ = ' '  AND PR3.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	While !(cAlsQry)->(Eof())

		If nCount == 1
			cQryRes := " SELECT  "
			cQryRes += (cAlsQry)->PR3_CPODES  
		Else
			If (cAlsQry)->PR3_ISFUNC <> "S"
				cQryRes += " , " + (cAlsQry)->PR3_CPODES  
			EndIf
		EndIf

		AADD(aCpos, Alltrim((cAlsQry)->PR3_CPODES) )
		AADD(aCposCab, Alltrim((cAlsQry)->PR3_CPOORI))

		If (cAlsQry)->PR3_ISFUNC == "S"
			AADD(aCont, Alltrim( (cAlsQry)->PR3_CONTEU ))
		Else
			AADD(aCont, "")
		EndIf

		nCount++
		(cAlsQry)->(DbSkip())

	End

	If !Empty(cQryRes)

		cQryRes += " FROM " + RetSqlName("DA1") + " DA1 "
		cQryRes += " WHERE "
		cQryRes += " DA1.D_E_L_E_T_ = ' ' ORDER BY DA1_CODPRO "

		If Select(cAlsRes) > 0; (cAlsRes)->(dbCloseArea()); Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryRes),cAlsRes,.T.,.T.)

		If !(cAlsRes)->(Eof()) 

			nQtdReg := Contar(cAlsRes,"!Eof()")

			//Cria serviÃ¯Â¿Â½o no montitor
			aCriaServ := U_MonitRes("000006", 1, nQtdReg)   
			cIdPZB 	  := aCriaServ[2]

			cJson := '{'
			cJson += '"produtos":['

			(cAlsRes)->(DbGoTop())

		Else

			cJson += "{"
			cJson += '"produtos":['
			cJson += "{" 
			cJson += '"errorMessage":"Nao existe saldo de estoque.",'
			cJson += '"lret":false'
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

			cJson += '"lret' + cValTochar(nLine) + '":true'
			cJson += "},"

			cMenssagem  := "Get realizado com sucesso."
			U_MonitRes("000006", 2, , cIdPZB, cMenssagem, .T., "Get de Produtos", cJson, "", "", .F., .F.)

			nLine++

			(cAlsRes)->(DbSkip())

		End

		(cAlsRes)->(dbCloseArea())

		//Finaliza o processo na PZB
		U_MonitRes("000006", 3, , cIdPZB, , .T.)

	EndIf

	cJson := Substr(cJson, 1, Rat(",", cJson) -1)
	
	cJson += "]}"

	(cAlsQry)->(dbCloseArea())

	::SetContentType("application/json")
	::SetResponse( cJson )

Return(.T.)

//*************
// POST PEDIDO
//*************

WsRestFul PostPV Description "Metodo Responsavel por Cadastrar Pedidos de Venda"

WsData cCgcEmp		As String

WsMethod Post Description "Cadastro de Pedidos de Venda" WsSyntax "/PostPV"

End WsRestFul

WsMethod Post WsReceive cCgcEmp WsService PostPV

Local cBody     	:= ::GetContent()
Local cQuery    	:= ""
//Local oLoc			:= Nil
//Local cLoc			:= ""
Local cAlsQry   	:= CriaTrab(Nil,.F.)
Local nX
Local nY
Local cStrErro  	:= ""
//Local aDados    	:= {}
Local _aAux			:= {}
Local _aCab	    	:= {}
Local _aItens		:= {}
Local aCriaServ 	:= {}
Local nErro     	:= 0
Local cJson     	:= ""
//Local cCgcEmp   	:= IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")
//Local aEmpresas 	:= FwLoadSM0()
//Local aVld      	:= {}
Local aErros    	:= {}
//Local lVldCli   	:= .F.
//Local lVldProd  	:= .F.
//Local cCgcCli   	:= ""
//Local cEAN      	:= ""
//Local nQuant    	:= 0
//Local cTpInteg  	:= ""
//Local cTpOper   	:= ""  
Local cMenssagem	:= ""
Local cItem			:= "01"

Private oJsoAux   	:= Nil

/**************************************************
* forÃ¯Â¿Â½a a gravaÃ¯Â¿Â½Ã¯Â¿Â½o das informaÃ¯Â¿Â½Ã¯Â¿Â½es de erro em 	*
* array para manipulaÃ¯Â¿Â½Ã¯Â¿Â½o da gravaÃ¯Â¿Â½Ã¯Â¿Â½o ao invÃ¯Â¿Â½s 	*
* de gravar direto no arquivo temporÃ¯Â¿Â½rio		*
**************************************************/
Private lMsHelpAuto	:= .T.

/**************************************************
* forÃ¯Â¿Â½a a gravaÃ¯Â¿Â½Ã¯Â¿Â½o das informaÃ¯Â¿Â½Ã¯Â¿Â½es de erro em 	*
* array para manipulaÃ¯Â¿Â½Ã¯Â¿Â½o da gravaÃ¯Â¿Â½Ã¯Â¿Â½o ao invÃ¯Â¿Â½s 	*
* de gravar direto no arquivo temporÃ¯Â¿Â½rio 		*
**************************************************/
Private lAutoErrNoFile := .T.
Private lMsErroAuto := .F.

	FWJsonDeserialize(cBody, @oJsoAux)

	cQuery := " SELECT PR3.* FROM " + RetSqlName("PR3") + " PR3 "
	cQuery += " INNER JOIN " + RetSqlName("PR2") + " PR2 "
	cQuery += " ON PR3_FILIAL = PR2_FILIAL AND PR3_CODIGO = PR2_CODIGO "
	cQuery += " WHERE PR2_CODPZA = '000002' AND PR2.D_E_L_E_T_ = ' '  AND PR3.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	DbSelectArea("SA1")
	SA1->(DbSetOrder(3))

	//Cria serviÃ¯Â¿Â½o no montitor
	aCriaServ := U_MonitRes("000002", 1, 1 )   
	cIdPZB 	  := aCriaServ[2]

	cMenssagem  := "Post Pedidos"

	If !SA1->(MsSeek(xFilial("SA1") + oJsoAux:cgc))
		
		U_MonitRes("000002", 2, , cIdPZB, cMenssagem, .F., cStrErro, "", cBody, "", .F., .F.)

		//Finaliza o processo na PZB
		U_MonitRes("000002", 3, , cIdPZB, , .F.)
		
		cJson := "{" 
		cJson += '"errorMessage":"cliente nÃ¯Â¿Â½o cadastrado",'
		cJson += '"lret":false'
		cJson += "}"
		
		::SetResponse( cJson )
		Return(.T.)
		
	EndIf

	(cAlsQry)->(DbGoTop())

	_aCab      := {}

	aAdd(_aCab,   {"C5_FILIAL"	, xFilial("SC5")					 , nil})
	aAdd(_aCab,   {"C5_NUM"		, GetSXeNum("SC5","C5_NUM","C5_NUM") , nil})
	aAdd(_aCab,   {"C5_CLIENTE"	, SA1->A1_COD						 , nil})
	aAdd(_aCab,   {"C5_LOJACLI"	, SA1->A1_LOJA						 , nil})

	While !(cAlsQry)->(Eof())

		If SUBSTR(Alltrim((cAlsQry)->PR3_CPODES),1,2) == "C5"

			cCpo        := Alltrim((cAlsQry)->PR3_CPOORI)

			If (cAlsQry)->PR3_TPCONT == "1"
				cConteudo := &("oJsoAux:" + cCpo)  

				If Empty(cConteudo)
					(cAlsQry)->(DbSkip())
					Loop
				EndIf

			Else
				cConteudo := &((cAlsQry)->PR3_CONTEU)
			EndIf

			If TAMSX3(AllTrim((cAlsQry)->PR3_CPODES))[3] == "D"
				cConteudo := StoD(cConteudo)
			EndIf

			If ValType(cConteudo) == "N"
				If cConteudo < 0
					cConteudo := cConteudo * (-1)
				EndIf
			EndIf

			aAdd(_aCab, {Alltrim((cAlsQry)->PR3_CPODES), cConteudo, nil})

		EndIf

		(cAlsQry)->(DbSkip())
	End

	(cAlsQry)->(DBGoTop())

	For nY := 1 to len(oJsoAux:Itens)

		If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

		(cAlsQry)->(DBGoTop())

		While !(cAlsQry)->(Eof())

			If SUBSTR(Alltrim((cAlsQry)->PR3_CPODES),1,2) == "C6"

				cCpo        := Alltrim((cAlsQry)->PR3_CPOORI)

				If (cAlsQry)->PR3_TPCONT == "1"
					cConteudo := &("oJsoAux:Itens[" + cValTochar(nY) + "]:" + cCpo)  
				Else
					cConteudo := &((cAlsQry)->PR3_CONTEU)
				EndIf

				aAdd(_aAux, {Alltrim((cAlsQry)->PR3_CPODES), cConteudo, nil})

			EndIf

			(cAlsQry)->(DbSkip())
		End

		aAdd(_aAux, {"C6_ITEM", cItem, nil})

		cItem := Soma1(cItem)

		aAdd(_aItens,_aAux)
		_aAux := {}
	
	Next nY
	
	_aCab	:= FWVetByDic(_aCab,"SC5",.F.) //Organiza o array
	_aItens	:= FWVetByDic(_aItens,"SC6",.T.) //Organiza o array

	//Verifica se o pedido ja existe
	nPosPed := aScan(_aCab, 	{|x| Alltrim(x[1]) == "C5_XORDER" })
	nPosVen := aScan(_aItens[1],{|x| Alltrim(x[1]) == "C6_PRCVEN" })
	nPosTot := aScan(_aItens[1],{|x| Alltrim(x[1]) == "C6_TOTAL" })
	nPosUni := aScan(_aItens[1],{|x| Alltrim(x[1]) == "C6_PRUNIT" })
	nPosOpe := aScan(_aItens[1],{|x| Alltrim(x[1]) == "C6_OPER" })

	//Remonta o array para remover campos de valor caso seja operaÃ¯Â¿Â½Ã¯Â¿Â½o diferente de 1
	For nX := 1 to len(_aItens)

		If nPosVen > 0 
			If _aItens[nX][nPosVen][2] == 0
				_aItens[nX][nPosVen][2] := 0.01
			
			ElseIf _aItens[nX][nPosVen][2] >= 0.01 .And. _aItens[nX][nPosVen][2] <= 0.10
				_aItens[nX][nPosOpe][2] := "41"

			EndIf
		EndIf

		If nPosTot > 0 
			If _aItens[nX][nPosTot][2] == 0
				_aItens[nX][nPosTot][2] := 0.01
			
			ElseIf _aItens[nX][nPosTot][2] >= 0.01 .And. _aItens[nX][nPosTot][2] <= 0.10
				_aItens[nX][nPosOpe][2] := "41"

			EndIf
		EndIf

		If nPosUni > 0 
			If _aItens[nX][nPosUni][2] == 0
				_aItens[nX][nPosUni][2] := 0.01
			
			ElseIf _aItens[nX][nPosUni][2] >= 0.01 .And. _aItens[nX][nPosUni][2] <= 0.10
				_aItens[nX][nPosOpe][2] := "41"

			EndIf
		EndIf
	
	Next nX

	DbSelectArea("SC5")
	SC5->(DBOrderNickname("ORDERVTEX"))

	If SC5->(MsSeek(xFilial("SC5") + _aCab[nPosPed][2]))

		U_MonitRes("000002", 2, , cIdPZB, "Pedido ja existe.", .T., _aCab[nPosPed][2], "", cBody, "", .F., .F.)

		//Finaliza o processo na PZB
		U_MonitRes("000002", 3, , cIdPZB, , .T.)

		cJson := "{" 
		cJson += '"errorMessage":"Pedido ja existe",'
		cJson += '"lret":false,'
		cJson += '"pedido":"' + SC5->C5_NUM + '"'
		cJson += "}"

		RollBackSX8()
		
		::SetResponse( cJson )
		Return(.T.)

	EndIf

	MSExecAuto({|x,y,z| MATA410(x,y,z)},_aCab,_aItens,3)

	::SetContentType("application/json")

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

		Conout("Erro pedido: " + _aCab[nPosPed][2] + " " + cStrErro)

		RollBackSX8()

		U_MonitRes("000002", 2, , cIdPZB, cStrErro, .F., _aCab[nPosPed][2], "", cBody, "", .F., .F.)

		//Finaliza o processo na PZB
		U_MonitRes("000002", 3, , cIdPZB, , .F.)

		cJson := "{" 
		cJson += '"errorMessage":"' + cStrErro + '",'
		cJson += '"lret":false,'
		cJson += '"pedido":"' + SC5->C5_NUM + '"'
		cJson += "}"

	Else

		ConfirmSx8()

		U_MonitRes("000002", 2, , cIdPZB, "Pedido incluso com sucesso", .T., _aCab[nPosPed][2], "", cBody, "", .F., .F.)

		//Finaliza o processo na PZB
		U_MonitRes("000002", 3, , cIdPZB, , .T.)

		cJson := "{" 
		cJson += '"lret":true,'
		cJson += '"pedido":"' + SC5->C5_NUM + '"' //corrigido caio menezes - 28/01/2020
		cJson += "}"

	EndIf

	::SetResponse( cJson )

	(cAlsQry)->(dbCloseArea())

Return(.T.)

//******************
// POST CLIENTES
//******************

WsRestFul PostCli Description "Metodo Responsavel por Incluir Clientes"

WsData cCgcEmp		As String

WsMethod Post Description "Cadastro de Cond. Pagamento" WsSyntax "/PostCli"

End WsRestFul

WsMethod Post WsReceive cCgcEmp WsService PostCli

Local cBody     := ::GetContent()
Local cQuery    := ""
Local cAlsQry   := CriaTrab(Nil,.F.)
//Local nX
Local _nPCgc
Local _nPTipo
Local _npCod
Local _npLoj
Local cStrErro  := ""
Local aDados    := {}
Local cLogA1    := ""
Local aCriaServ := {}
Local nErro     := 0
Local cJson     := ""
//Local cCgcEmp   := IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")
//Local aEmpresas := FwLoadSM0()

Private oJsoAux   := Nil

/**************************************************
* forÃ¯Â¿Â½a a gravaÃ¯Â¿Â½Ã¯Â¿Â½o das informaÃ¯Â¿Â½Ã¯Â¿Â½es de erro em 	*
* array para manipulaÃ¯Â¿Â½Ã¯Â¿Â½o da gravaÃ¯Â¿Â½Ã¯Â¿Â½o ao invÃ¯Â¿Â½s 	*
* de gravar direto no arquivo temporÃ¯Â¿Â½rio		*
**************************************************/
Private lMsHelpAuto	:= .T.

/**************************************************
* forÃ¯Â¿Â½a a gravaÃ¯Â¿Â½Ã¯Â¿Â½o das informaÃ¯Â¿Â½Ã¯Â¿Â½es de erro em 	*
* array para manipulaÃ¯Â¿Â½Ã¯Â¿Â½o da gravaÃ¯Â¿Â½Ã¯Â¿Â½o ao invÃ¯Â¿Â½s 	*
* de gravar direto no arquivo temporÃ¯Â¿Â½rio 		*
**************************************************/
Private lAutoErrNoFile := .T.
Private lMsErroAuto := .F.

	If Empty(cBody)
		cJson := '{Json invalido.}'

		cJson := encodeutf8(cJson)
		::SetContentType("application/json")
		::SetResponse( cJson )
		Return .T.
	EndIf

	FWJsonDeserialize(cBody, @oJsoAux)

	SM0->(DbSetOrder(1))

	cQuery := " SELECT PR3.* FROM " + RetSqlName("PR3") + " PR3 "
	cQuery += " INNER JOIN " + RetSqlName("PR2") + " PR2 "
	cQuery += " ON PR3_FILIAL = PR2_FILIAL AND PR3_CODIGO = PR2_CODIGO "
	cQuery += " WHERE PR2_CODPZA = '000001' AND PR2.D_E_L_E_T_ = ' '  AND PR3.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	//Cria serviÃ¯Â¿Â½o no montitor
	aCriaServ := U_MonitRes("000001", 1, 1 )   
	cIdPZB 	  := aCriaServ[2]

	aDados      := {}

	//aAdd(aDados, {"A1_COD"  , GetSXeNum("SA1","A1_COD","A1_COD")    , nil})
	aAdd(aDados, {"A1_LOJA" , "01"                                  , nil})


	While !(cAlsQry)->(Eof())

		cCpo := Alltrim((cAlsQry)->PR3_CPOORI)

		If (cAlsQry)->PR3_ISFUNC == "S"
				
			If (cAlsQry)->PR3_TPCONT == "1"
				cConteudo := &((cAlsQry)->PR3_CONTEU)
			Else
				cConteudo := ((cAlsQry)->PR3_CONTEU)
			EndIf
		
		ElseIf (cAlsQry)->PR3_TPCONT == "1"
		
			cConteudo := &("oJsoAux:" + cCpo) 

			If Empty(cConteudo)
				(cAlsQry)->(DbSkip())
				Loop
			EndIf
			
			If ValType(cConteudo) == "C" 
				
				If DecodeUtf8(cConteudo) <> Nil	
					cConteudo := DecodeUtf8(cConteudo) 
				EndIf

				If !Empty(cConteudo)
					cConteudo := Left(cConteudo, TamSX3((cAlsQry)->PR3_CPODES)[1])
				EndIf

				cConteudo := UPPER(NoAcento(cConteudo))

			EndIf

		Else
			cConteudo := &((cAlsQry)->PR3_CONTEU)
		EndIf

		aAdd(aDados, {Alltrim((cAlsQry)->PR3_CPODES), cConteudo, nil})

		(cAlsQry)->(DbSkip())

	End

	DbSelectArea("SA1")
	SA1->(DbSetOrder(3))

	cMenssagem  := "Post cliente"

	//Busca codigo apra verificar se produto existe na base
	_nPCgc		:= aScan(aDados, {|x| Alltrim(x[1]) == "A1_CGC"  	 })
	nPosNome	:= aScan(aDados, {|x| Alltrim(x[1]) == "A1_NOME" 	 })
	_npCod		:= aScan(aDados, {|x| Alltrim(x[1]) == "A1_COD" 	 })
	_npLoj		:= aScan(aDados, {|x| Alltrim(x[1]) == "A1_LOJA" 	 })
	_nPTipo     := aScan(aDados, {|x| Alltrim(x[1]) == "A1_XTIPO" 	 })
	//Valida se tem CNPJ em branco
	If aDados[_nPCgc][2] == Nil

		RollBackSX8()
		
		U_MonitRes("000001", 2, , cIdPZB, "CPF ou CNPJ nao informado", .F., "", "", aDados[nPosNome][2], "", .F., .F.)

		//Finaliza o processo na PZB
		U_MonitRes("000001", 3, , cIdPZB, , .F.)

		cJson := '{'
		cJson += '"errorMessage":"CPF ou CNPJ nao informado",'
		cJson += '"lret":false'
		cJson += '}'

		cJson := encodeutf8(cJson)
		::SetContentType("application/json")
		::SetResponse( cJson )

		(cAlsQry)->(dbCloseArea())

		Return(.T.)

	EndIf

	If SA1->(MsSeek(xFilial("SA1") + aDados[_nPCgc][2]))

		RollBackSX8()

		nOpc := 4

		aDados[_npCod][2] := SA1->A1_COD
		aDados[_npLoj][2] := SA1->A1_LOJA

	Else
		nOpc := 3
	EndIf

	if _nPTipo > 0
		if aDados[_nPTipo][2] == "07" // �rg�o P�blico Federal 
			aAdd(aDados, {"A1_ABATIMP", "2", nil})
			aAdd(aDados, {"A1_MINIRF", "1", nil})
		Else
			aAdd(aDados, {"A1_ABATIMP", "1", nil})
			aAdd(aDados, {"A1_MINIRF", "2", nil})
		Endif
	Else
		aAdd(aDados, {"A1_ABATIMP", "1", nil})
		aAdd(aDados, {"A1_MINIRF", "2", nil})
	Endif

	aDados := FWVetByDic(aDados,"SA1",.F.) //Organiza o array
	aEval(aDados,{|x| cLogA1 += x[1] + " - " + cValToChar(x[2]) + CRLF })
	MSExecAuto({|x,y| Mata030(x,y)},aDados,nOpc)

	::SetContentType("application/json")

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

		U_MonitRes("000001", 2, , cIdPZB, cStrErro, .F., aDados[_nPCgc][2], cBody, cLogA1,"", .F., .F.)

		//Finaliza o processo na PZB
		U_MonitRes("000001", 3, , cIdPZB, , .F.)

 		cStrErro := NoAcento(cStrErro)
		cStrErro := StrTran(cStrErro,".","")

		cJson := '{'
		cJson += '"errorMessage":"' + cStrErro + '",'
		cJson += '"lret":false'
		cJson += '}'

	Else

		If nOpc == 3
			ConfirmSx8()
		EndIf

		U_MonitRes("000001", 2, , cIdPZB, "Cliente " + IIf(nOpc == 3, "incluso", "alterado") + " com sucesso", .T., aDados[_nPCgc][2], cBody, cLogA1, aDados[nPosNome][2], .F., .F.)

		//Finaliza o processo na PZB
		U_MonitRes("000001", 3, , cIdPZB, , .T.)

		cJson := '{'
		cJson += '"IDSALES":"' + oJsoAux:IDSALES + '",' 
		cJson += '"lret":true'
		cJson += '}'

	EndIf
				
	cJson := encodeutf8(cJson)
	::SetResponse( cJson )

	(cAlsQry)->(dbCloseArea())

Return(.T.)

//*************
// POST PRODUTO
//*************

WsRestFul PostProd Description "Metodo Responsavel por Cadastrar Produtos"

WsData cCgcEmp		As String

WsMethod Post Description "Cadastro de Produtos" WsSyntax "/PostProd"

End WsRestFul

WsMethod Post WsReceive cCgcEmp WsService PostProd

Local cBody     := ::GetContent()
Local cQuery    := ""
Local cAlsQry   := CriaTrab(Nil,.F.)
//Local nX
Local cStrErro  := ""
Local aDados    := {}
Local aCriaServ := {}
Local nErro     := 0
Local cJson     := ""
Local nPosCod	:= 0

Private oJsoAux   := Nil

/**************************************************
* forÃ¯Â¿Â½a a gravaÃ¯Â¿Â½Ã¯Â¿Â½o das informaÃ¯Â¿Â½Ã¯Â¿Â½es de erro em 	*
* array para manipulaÃ¯Â¿Â½Ã¯Â¿Â½o da gravaÃ¯Â¿Â½Ã¯Â¿Â½o ao invÃ¯Â¿Â½s 	*
* de gravar direto no arquivo temporÃ¯Â¿Â½rio		*
**************************************************/
Private lMsHelpAuto	:= .T.

/**************************************************
* forÃ¯Â¿Â½a a gravaÃ¯Â¿Â½Ã¯Â¿Â½o das informaÃ¯Â¿Â½Ã¯Â¿Â½es de erro em 	*
* array para manipulaÃ¯Â¿Â½Ã¯Â¿Â½o da gravaÃ¯Â¿Â½Ã¯Â¿Â½o ao invÃ¯Â¿Â½s 	*
* de gravar direto no arquivo temporÃ¯Â¿Â½rio 		*
**************************************************/
Private lAutoErrNoFile := .T.
Private lMsErroAuto := .F.

	If Empty(cBody)
		cJson := '{Json invalido.}'
		::SetResponse( cJson )
		Return .T.
	EndIf

	FWJsonDeserialize(cBody, @oJsoAux)

	SM0->(DbSetOrder(1))

	cQuery := " SELECT PR3.* FROM " + RetSqlName("PR3") + " PR3 "
	cQuery += " INNER JOIN " + RetSqlName("PR2") + " PR2 "
	cQuery += " ON PR3_FILIAL = PR2_FILIAL AND PR3_CODIGO = PR2_CODIGO "
	cQuery += " WHERE PR2_CODPZA = '000003' AND PR2.D_E_L_E_T_ = ' '  AND PR3.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	//Cria serviÃ¯Â¿Â½o no montitor
	aCriaServ := U_MonitRes("000003", 1, 1 )   
	cIdPZB 	  := aCriaServ[2]

	aDados      := {}

	While !(cAlsQry)->(Eof())

		cCpo        := Alltrim((cAlsQry)->PR3_CPOORI)

		If (cAlsQry)->PR3_TPCONT == "1"
			cConteudo := &("oJsoAux:" + cCpo) 

			If Empty(cConteudo)
				(cAlsQry)->(DbSkip())
				Loop
			EndIf
			
			If ValType(cConteudo) == "C" 
				
				If DecodeUtf8(cConteudo) <> Nil	
					cConteudo := DecodeUtf8(cConteudo) 
				EndIf
				
				If !Empty(cConteudo)
					cConteudo := Left(cConteudo, TamSX3((cAlsQry)->PR3_CPODES)[1])
				EndIf

				cConteudo := NoAcento(cConteudo)

			EndIf

		Else
			cConteudo := &((cAlsQry)->PR3_CONTEU)
		EndIf

		aAdd(aDados, {Alltrim((cAlsQry)->PR3_CPODES), cConteudo, nil})

		(cAlsQry)->(DbSkip())

	End

	aDados := FWVetByDic(aDados,"SB1",.F.) //Organiza o array

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))

	cMenssagem  := "Post produto"

	//Busca codigo apra verificar se produto existe na base
	nPosCod := aScan(aDados, {|x| Alltrim(x[1]) == "B1_COD" })

	//Tratativa se nÃ¯Â¿Â½o vier refid
	If aDados[nPosCod][2] == Nil
		
		U_MonitRes("000003", 2, , cIdPZB, cMenssagem, .F., "Produto sem referencia preenchida na VTEX.", "", cBody, "", .F., .F.)

		//Finaliza o processo na PZB
		U_MonitRes("000003", 3, , cIdPZB, , .F.)

		cJson := '{'
		cJson += '"errorMessage":"Produto sem a referencia do produto preenchida na VTEX.",'
		cJson += '"lret":false'
		cJson += "}"

		::SetResponse( cJson )

		(cAlsQry)->(dbCloseArea())

		Return(.T.)

	EndIf

	If SB1->(MsSeek(xFilial("SB1") + aDados[nPosCod][2]))
		
		U_MonitRes("000003", 2, , cIdPZB, cMenssagem, .T., "Produto ja cadastrado.", "", cBody, "", .F., .F.)

		//Finaliza o processo na PZB
		U_MonitRes("000003", 3, , cIdPZB, , .T.)

		cJson := '{'
		cJson += '"errorMessage":"Produto ja cadastrado no Protheus.",'
		cJson += '"lret":true'
		cJson += "}"

		::SetResponse( cJson )

		(cAlsQry)->(dbCloseArea())

		Return(.T.)

	EndIf

	MSExecAuto({|x,y| Mata010(x,y)},aDados,3)

	::SetContentType("application/json")

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
		
		U_MonitRes("000003", 2, , cIdPZB, cMenssagem, .F., cStrErro, "", cBody, "", .F., .F.)

		//Finaliza o processo na PZB
		U_MonitRes("000003", 3, , cIdPZB, , .F.)

		cJson := '{'
		cJson += '"errorMessage":"' + cStrErro + '",'
		cJson += '"lret":false'
		cJson += "}"

	Else

		ConfirmSx8()

		U_MonitRes("000003", 2, , cIdPZB, cMenssagem, .T., "Produto incluso com sucesso", "", cBody, "", .F., .F.)

		//Finaliza o processo na PZB
		U_MonitRes("000003", 3, , cIdPZB, , .T.)

		cJson := '{'
		cJson += '"lret":true'
		cJson += "}"

	EndIf

	::SetResponse( cJson )

	(cAlsQry)->(dbCloseArea())

Return(.T.)

//*************
// PUT STATUS
//*************

WsRestFul PutStatus Description "Metodo Responsavel por atualiar o status de tracking"

WsData nRecno		As Integer

WsMethod Put Description "Atualiza status de tracking" WsSyntax "/PutStatus"

End WsRestFul

WsMethod Put WsReceive nRecno WsService PutStatus

Local nRecAtu := IIf(::nRecno <> Nil, ::nRecno, 0)

	If nRecAtu == 0

		cJson := "{"
		cJson += '"menssagem":"registro para confirmacao nao informado",'
		cJson += '"lret":false'
		cJson += "}"

		::SetContentType("application/json")
		::SetResponse( cJson )

		Return(.T.)

	EndIf

	DbSelectArea("PR1")

	PR1->(DbGoTo(nRecAtu))

	PR1->(RecLock("PR1",.F.))

		PR1->PR1_STINT := "I"
	
	PR1->(MsUnlock())

	cJson := "{"
	cJson += '"lret":true'
	cJson += "}"

	::SetContentType("application/json")
	::SetResponse( cJson )

Return(.T.)

//******************
// POST CONSTRATOS
//******************

WsRestFul PostCont Description "Metodo Responsavel por Incluir/Versionar conratos"

WsData cCgcEmp		As String

WsMethod Post Description "Cadastro de Cond. Pagamento" WsSyntax "/PostCont"

End WsRestFul

WsMethod Post WsReceive cCgcEmp WsService PostCont

Local cBody     	:= ::GetContent()
Local cQuery    	:= ""
Local cAlsQry   	:= CriaTrab(Nil,.F.)
Local nX			:= 0
Local nLineCNB		:= 0
Local aCriaServ 	:= {}
Local cJson     	:= ""
Local aDadCN9		:= {}
Local aDadCNA		:= {}
Local aDadCNB		:= {}
Local aDadCNC		:= {}
Local aDadAtiv		:= {}
Local aPlanilhas	:= {}
Local lIncl			:= .F.
Local lAltera		:= .F.
Local lCommit		:= .F.
Local cModeCN9      := "2" // Meses
Local oModCN9
Local oModCNA
Local oModCNB
Local oModCNC
Local nY
Local cMenssagem	:= ""
Local cTIPREV       := ""
Local cDTREV        := ""
Local lFirst		:= .T.
Local lContVoz		:= .F.
Local lTemValor		:= .F.
Local cRevisa		:= ""
Local nRecCN9		:= 0
Local nLine			:= 1
Local cNumero  		:= "000001"
Local Value        := nil
//Local aDadBundle	:= {}
Local dDtQry	

Private oJsoAux  	:= Nil

	cCodUsr := "000000"

	If Empty(cBody)
		cJson := '{Json invalido.}'

		cJson := encodeutf8(cJson)
		::SetContentType("application/json")
		::SetResponse( cJson )
		Return .T.
	EndIf

	FWJsonDeserialize(cBody, @oJsoAux)

	SM0->(DbSetOrder(1))

	cQuery := " SELECT PR3.* FROM " + RetSqlName("PR3") + " PR3 "
	cQuery += " INNER JOIN " + RetSqlName("PR2") + " PR2 "
	cQuery += " ON PR3_FILIAL = PR2_FILIAL AND PR3_CODIGO = PR2_CODIGO "
	cQuery += " WHERE PR2_CODPZA = '000009' AND PR2.D_E_L_E_T_ != '*'  AND PR3.D_E_L_E_T_ != '*' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	//Cria serviÃ¯Â¿Â½o no montitor
	aCriaServ := U_MonitRes("000009", 1, 1 )   
	cIdPZB 	  := aCriaServ[2]

	While !(cAlsQry)->(Eof())

		cCpo := Alltrim((cAlsQry)->PR3_CPOORI)

		If (cAlsQry)->PR3_TPCONT == "1"
			cConteudo := &("oJsoAux:" + cCpo) 

			If Empty(cConteudo)
				(cAlsQry)->(DbSkip())
				Loop
			EndIf
			
			If ValType(cConteudo) == "C" 
				
				If DecodeUtf8(cConteudo) <> Nil	
					cConteudo := DecodeUtf8(cConteudo) 
				EndIf

				If !Empty(cConteudo)
					
					If "-" $ cConteudo .And. Alltrim((cAlsQry)->PR3_CPODES) == "CN9_DTINIC"
						cConteudo := StrTran(cConteudo,"-","")
						cConteudo := STOD(cConteudo)
					ElseIf Alltrim((cAlsQry)->PR3_CPODES) != "tipo"
						cConteudo := NoAcento(cConteudo)
					EndIf

				EndIf

			EndIf

		Else
			cConteudo := &((cAlsQry)->PR3_CONTEU)
		EndIf

		//Verifica tabela de preenchimento
		Do case
		
			Case Left(Alltrim((cAlsQry)->PR3_CPODES),3) == "CN9"
				aAdd(aDadCN9, {Alltrim((cAlsQry)->PR3_CPODES), cConteudo})
			
			Case Left(Alltrim((cAlsQry)->PR3_CPODES),3) == "CNA"
				aAdd(aDadCNA, {Alltrim((cAlsQry)->PR3_CPODES), cConteudo})

			Case Left(Alltrim((cAlsQry)->PR3_CPODES),3) == "CNB"
				
				If ValType(cConteudo) == "A"
					
					For nX := 1 to len(cConteudo)

						aAux := {}
						
						If !lFirst
							aAdd(aDadCNB[nX], {Alltrim((cAlsQry)->PR3_CPODES), cConteudo[nX]})	
						Else
							aAdd(aAux, {Alltrim((cAlsQry)->PR3_CPODES), cConteudo[nX]})	
							
							aAdd(aDadCNB, aClone(aAux))

						EndIf

					Next nX

					lFirst := .F.
				
				Else
					aAdd(aDadCNB, {Alltrim((cAlsQry)->PR3_CPODES), cConteudo})	
				EndIf

			Case Left(Alltrim((cAlsQry)->PR3_CPODES),3) == "CNC"
				aAdd(aDadCNC, {Alltrim((cAlsQry)->PR3_CPODES), cConteudo, nil})

		EndCase

		(cAlsQry)->(DbSkip())

	End

	If ValType(aDadCNB) == "A"
		If ValType(aDadCNB[1]) == "A"
			If ValType(aDadCNB[1][1]) == "A"
				For nX := 1 to len(aDadCNB)
					For nY := 1 to len(aDadCNB[nX])
						If aDadCNB[nX][nY][1] == "CNB_VLUNIT"
							If aDadCNB[nX][nY][2] > 0
								lTemValor := .T.
							EndIf
						EndIf
					next nY
				Next nX
			Else
				For nX := 1 to len(aDadCNB)
					If aDadCNB[nX][1] == "CNB_VLUNIT"
						If aDadCNB[nX][2] > 0
							lTemValor := .T.
						EndIf
					EndIf
				Next nX
			Endif
		Endif
	Endif
	
	//Se n�o tiver nenhum item com valor zera a CNB.
	If !lTemValor
		aDadCNB := {}
	EndIf

	If Len(aDadCNB) > 0
		//Se veio sÃ³ um item para recorrente trata tambÃ©m
		If !ValType(aDadCNB[1][1]) == "A"
			aAux 	:= aDadCNB
			aDadCNB := {}
			aAdd(aDadCNB, aClone(aAux))
		EndIf
	EndIf
	
	//Monta valores de ativaÃ§Ã£o
	If ValType(oJsoAux:VLATIVACAO) == "A"
		
		//Monta CNB para valores de ativaÃ§Ã£o
		For nX := 1 to len (oJsoAux:VLATIVACAO)

			If oJsoAux:VLATIVACAO[nX] > 0

				aAux := {}

				AADD(aAux, {"CNB_PRODUT", "SERVR0005"})
				AADD(aAux, {"CNB_QUANT", 1})
				AADD(aAux, {"CNB_VLUNIT", oJsoAux:VLATIVACAO[nX]})

				aAdd(aDadAtiv, aClone(aAux))

			EndIf
		
		Next nX

	ElseIf oJsoAux:VLATIVACAO > 0

		aAux := {}

		AADD(aAux, {"CNB_PRODUT", "SERVR0005"})
		AADD(aAux, {"CNB_QUANT", 1})
		AADD(aAux, {"CNB_VLUNIT", oJsoAux:VLATIVACAO})

		aAdd(aDadAtiv, aClone(aAux))
	
	EndIf

	If len(aDadCNB) == 0 .And. len(aDadAtiv) == 0
		lContVoz := .T.
	EndIf

	DbSelectArea("CN9")
	CN9->(DbSetOrder(1)) //CN9_FILIAL + CN9_NUMERO + CN9_REVISA

	nPosCon 	:= aScan(aDadCN9, {|x| Alltrim(x[1]) == "CN9_NUMERO" })
	nPosFil 	:= aScan(aDadCN9, {|x| Alltrim(x[1]) == "CN9_FILIAL" })
	nPosCond	:= aScan(aDadCN9, {|x| Alltrim(x[1]) == "CN9_CONDPG" })
	nPosCli 	:= aScan(aDadCNC, {|x| Alltrim(x[1]) == "CNC_CLIENT" })
	nPosCar 	:= aScan(aDadCNA, {|x| Alltrim(x[1]) == "CNA_XMSCAR" })
	nPosIse 	:= aScan(aDadCNA, {|x| Alltrim(x[1]) == "CNA_XMSISE" })

	//Verifica se o status � ativo em reten��o para gravar somente a data
	If DecodeUtf8(oJsoAux:status_sales) == "Ativo em Reten��o"
	
		If CN9->(DbSeek(aDadCN9[nPosFil][2] + aDadCN9[nPosCon][2] ))

			lAchou := .F.
			
			While aDadCN9[nPosFil][2] + aDadCN9[nPosCon][2] == Alltrim(CN9->(CN9_FILIAL + CN9_NUMERO))

				If CN9->CN9_SITUAC == "05"

					dDataAviso := STOD(StrTran(oJsoAux:Data_Aviso, "-", ""))

					CN9->(RecLock("CN9",.F.))

						//CN9->CN9_SITUAC := "99"
						CN9->CN9_XDTAVP	:= dDataAviso
						CN9->CN9_XDTSOL	:= STOD(StrTran(oJsoAux:CN9_XDTSOL, "-", ""))

					CN9->(MsUnlock())

					//Grava mensagem de sucesso no monitor
					U_MonitRes("000009", 2, , cIdPZB, "Contrato " + "Data de aviso previo preenchida com sucesso", .T., aDadCN9[nPosCon][2], "", cBody, aDadCN9[nPosCon][2], .F., .F.)

					//Finaliza o processo na PZB
					U_MonitRes("000009", 3, , cIdPZB, , .T.)

					cJson := "{" 
					cJson += '"lret":true'
					cJson += '}'

					cJson := encodeutf8(cJson)
					::SetContentType("application/json")
					::SetResponse( cJson )

					(cAlsQry)->(dbCloseArea())

					Return(.T.)
				
				EndIf

				CN9->(DbSkip())

			End

			If !lAchou

				U_MonitRes("000009", 2, , cIdPZB, "N�o foi encontrado contrato com status de vigente. " + aDadCN9[nPosCon][2], .F., "", "", cBody, "", .F., .F.)

				//Finaliza o processo na PZB
				U_MonitRes("000009", 3, , cIdPZB, , .F.)

				cJson := '{'
				cJson += '"errorMessage":"N�o foi encontrado contrato com status de vigente.",'
				cJson += '"lret":false'
				cJson += '}'

				cJson := encodeutf8(cJson)
				::SetContentType("application/json")
				::SetResponse( cJson )

				(cAlsQry)->(dbCloseArea())

				Return(.T.)

			EndIf					
			
		Else

			U_MonitRes("000009", 2, , cIdPZB, "Contrato n�o existe na base: " + aDadCN9[nPosCon][2], .F., "", "", cBody, "", .F., .F.)

			//Finaliza o processo na PZB
			U_MonitRes("000009", 3, , cIdPZB, , .F.)

			cJson := '{'
			cJson += '"errorMessage":"Contrato n�o existe na base.",'
			cJson += '"lret":false'
			cJson += '}'

			cJson := encodeutf8(cJson)
			::SetContentType("application/json")
			::SetResponse( cJson )

			(cAlsQry)->(dbCloseArea())

			Return(.T.)

		EndIf

	EndIf
	If DecodeUtf8(oJsoAux:status_sales) == "Migra��o Algar"

		If CN9->(DbSeek(aDadCN9[nPosFil][2] + aDadCN9[nPosCon][2] ))

				lAchou := .F.
				
				While aDadCN9[nPosFil][2] + aDadCN9[nPosCon][2] == Alltrim(CN9->(CN9_FILIAL + CN9_NUMERO))

					If CN9->CN9_SITUAC == "05"
						conout("ENTROU")
						//dDataAviso := STOD(StrTran(oJsoAux:Data_Aviso, "-", ""))
						conout(Alltrim(CN9->(CN9_FILIAL + CN9_NUMERO)))
						CN9->(RecLock("CN9",.F.))

							CN9->CN9_SITUAC := "06"
							//CN9->CN9_XDTAVP	:= dDataAviso
							//CN9->CN9_XDTSOL	:= STOD(StrTran(oJsoAux:CN9_XDTSOL, "-", ""))

						CN9->(MsUnlock())
						U_MonitRes("000009", 2, , cIdPZB, "Contrato " + "Data de aviso previo preenchida com sucesso", .T., aDadCN9[nPosCon][2], "", cBody, aDadCN9[nPosCon][2], .F., .F.)

						//Finaliza o processo na PZB
						U_MonitRes("000009", 3, , cIdPZB, , .T.)

						cJson := "{" 
						cJson += '"lret":true'
						cJson += '}'

						cJson := encodeutf8(cJson)
						::SetContentType("application/json")
						::SetResponse( cJson )

						(cAlsQry)->(dbCloseArea())

						Return(.T.)
					
					EndIf

					CN9->(DbSkip())
				Enddo	
		ENDIF
	EndIF
	//Troca filial logada
	If aDadCN9[nPosFil][2] <> cFilAnt
		cFilAnt := aDadCN9[nPosFil][2]
	EndIf

	If Len(aDadCN9[nPosCond][2]) == 2
		aDadCN9[nPosCond][2] := "N" + aDadCN9[nPosCond][2]
	EndIf

	If nPosCon == 0

		U_MonitRes("000009", 2, , cIdPZB, "Numero do contrato nao informado.", .F., "", "", cBody, "", .F., .F.)

		//Finaliza o processo na PZB
		U_MonitRes("000009", 3, , cIdPZB, , .F.)

		cJson := '{'
		cJson += '"errorMessage":"Numero do contrato nao informado.",'
		cJson += '"lret":false'
		cJson += '}'

		cJson := encodeutf8(cJson)
		::SetContentType("application/json")
		::SetResponse( cJson )

		(cAlsQry)->(dbCloseArea())

		Return(.T.)

	EndIf

	//Tabelas necessÃ¡rias
	DbSelectArea("ZZ3")
	ZZ3->(DbSetOrder(1))

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))

	cAlsCN9 := CriaTrab(Nil,.F.)

	cQuery := " SELECT MAX(CN9_REVISA) REVISA, MAX(R_E_C_N_O_) R_E_C_N_O_, MAX(CN9_DTINIC) CN9_DTINIC, MAX(CN9_XDTAVP) DATAUX"
	cQuery += " FROM " + RetSqlName("CN9") + " CN9"
	cQuery += " WHERE CN9.CN9_NUMERO = '" + aDadCN9[nPosCon][2] + "' AND CN9.D_E_L_E_T_ != '*' "
	
	If Select(cAlsCN9) > 0; (cAlsCN9)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsCN9,.T.,.T.)

	If (cAlsCN9)->R_E_C_N_O_ > 0
		
		lAltera := .T.
		cRevisa := Soma1( (cAlsCN9)->REVISA )
		nRecCN9	:= (cAlsCN9)->R_E_C_N_O_
		dDtQry	:= (cAlsCN9)->DATAUX
		cTIPREV := "001"
		cDTREV  := dDatabase

		nPosInic := aScan(aDadCN9, {|x| Alltrim(x[1]) == "CN9_DTINIC" })

		If 	DTOS(aDadCN9[nPosInic][2]) < (cAlsCN9)->CN9_DTINIC
			aDadCN9[nPosInic][2] := STOD((cAlsCN9)->CN9_DTINIC)
		EndIf

	Else
		lIncl := .T.
	EndIf

	(cAlsCN9)->(dbCloseArea())

	oModel := FWLoadModel("CNTA300")

	oModel:SetOperation(MODEL_OPERATION_INSERT)
	
	oModCN9 := oModel:GetModel("CN9MASTER")
	oModCNA := oModel:GetModel("CNADETAIL")
	oModCNB := oModel:GetModel("CNBDETAIL")
	oModCNC := oModel:GetModel("CNCDETAIL")
	oModCNH := oModel:GetModel("CNHDETAIL")

	//Tira obrigatoriedade do cnc 
	oModCNC:GetStruct():SetProperty("CNC_CODIGO",MODEL_FIELD_OBRIGAT,.F.)
	oModCNC:GetStruct():SetProperty("CNC_CODIGO",MODEL_FIELD_VALID,{|| .T. })
	oModCNC:GetStruct():SetProperty("CNC_LOJA",MODEL_FIELD_OBRIGAT,.F.)
	oModCNC:GetStruct():SetProperty("CNC_LOJA",MODEL_FIELD_VALID,{|| .T. })

	If lAltera
		oModCN9:GetStruct():SetProperty("CN9_NUMERO",MODEL_FIELD_VALID,{|| .T. })
		oModCNA:GetStruct():SetProperty("CNA_REVISA",MODEL_FIELD_VALID,{|| .T. })
	EndIf

	oModel:Activate()

	//Se for altera��o mas o tipo tier como novo � porque caiu a conex�o, ent�o s� confirma no sales.
	If lAltera .And. oJsoAux:tipo == "Novo" .And. Empty(dDtQry) .And. oJsoAux:Status_Sales != "Cancelado"

		cJson := "{" 
		cJson += '"errorMessage":"Contrato ja existe.",'
		cJson += '"lret":false'
		cJson += '}'

		cJson := encodeutf8(cJson)
		::SetContentType("application/json")
		::SetResponse( cJson )

		(cAlsQry)->(dbCloseArea())

		Return(.T.)
	
	EndIf

	//CabeÃ¯Â¿Â½alho
	For nX := 1 to len(aDadCN9)

		If aDadCN9[nX][1] == "CN9_FILIAL"
			Loop
		EndIf

		lCommit := oModCN9:SetValue(aDadCN9[nX][1], aDadCN9[nX][2])
		
		If !lCommit
			
			cMenssagem := aDadCN9[nX][1] + "-[A]-" + oModel:GetErrorMessage()[6]
			cMenssagem := NoAcento(cMenssagem)
			cMenssagem := StrTran(cMenssagem,".","")

			U_MonitRes("000009", 2, , cIdPZB, cMenssagem, .F., aDadCN9[nPosCon][2], "", cBody, "", .F., .F.)

			//Finaliza o processo na PZB
			U_MonitRes("000009", 3, , cIdPZB, , .F.)

			cJson := '{'
			cJson += '"errorMessage":"' + cMenssagem + '",'
			cJson += '"lret":false'
			cJson += '}'

			cJson := encodeutf8(cJson)
			::SetContentType("application/json")
			::SetResponse( cJson )

			(cAlsQry)->(dbCloseArea())

			Return(.T.)

		EndIf

	Next nX

	//Se for versionamento
	If lAltera

		lCommit := oModCN9:SetValue("CN9_REVISA", cRevisa)
		oModCN9:LoadValue("CN9_JUSTIF", "Revisado via integra��o com Salesforce.")
		oModCN9:LoadValue("CN9_TIPREV", cTIPREV)
		oModCN9:LoadValue("CN9_DTREV", cDTREV)

		If !lCommit
			
			cMenssagem := aDadCN9[nX][1] + "-[B]-" + oModel:GetErrorMessage()[6]
			cMenssagem := NoAcento(cMenssagem)
			cMenssagem := StrTran(cMenssagem,".","")

			U_MonitRes("000009", 2, , cIdPZB, cMenssagem, .F., aDadCN9[nPosCon][2], "", cBody, "", .F., .F.)

			//Finaliza o processo na PZB
			U_MonitRes("000009", 3, , cIdPZB, , .F.)

			cJson := '{'
			cJson += '"errorMessage":"' + cMenssagem + '",'
			cJson += '"lret":false'
			cJson += '}'

			cJson := encodeutf8(cJson)
			::SetContentType("application/json")
			::SetResponse( cJson )

			(cAlsQry)->(dbCloseArea())

			Return(.T.)

		EndIf

	EndIf

	If lAltera
		oModCNC:SetValue("CNC_REVISA", cRevisa)
	EndIf
	
	//Clientes
	For nX := 1 to len(aDadCNC)

		lCommit := oModCNC:SetValue(aDadCNC[nX][1], aDadCNC[nX][2])
					
		If !lCommit
			
			cMenssagem := aDadCNC[nX][1] + "-[C]-" + oModel:GetErrorMessage()[6]
			cMenssagem := NoAcento(cMenssagem)
			cMenssagem := StrTran(cMenssagem,".","")

			U_MonitRes("000009", 2, , cIdPZB, cMenssagem, .F., aDadCN9[nPosCon][2], "", cBody, "", .F., .F.)

			//Finaliza o processo na PZB
			U_MonitRes("000009", 3, , cIdPZB, , .F.)

			cJson := '{'
			cJson += '"errorMessage":"' + cMenssagem + '",'
			cJson += '"lret":false'
			cJson += '}'

			cJson := encodeutf8(cJson)
			::SetContentType("application/json")
			::SetResponse( cJson )

			(cAlsQry)->(dbCloseArea())

			Return(.T.)

		EndIf

	Next nX
	
	//Se tiver dado de bundle ou for cancelamento � somente medi��o livre.
	If lContVoz .Or. oJsoAux:status_sales == "Cancelado"

		//Altera��o preenche a revisão
		If lAltera
			oModCNA:SetValue("CNA_REVISA", cRevisa)
		EndIf
		
		//Insere planilha para medi��o livre
		For nX := 1 to len(aDadCNA)
			oModCNA:GoLine(1)
			//Pula isen��o e carencia
			If aDadCNA[nX][1] $ "CNA_XMSCAR/CNA_XMSISE/CNA_XINISE" 
				Loop
			EndIf
			
			If aDadCNA[nX][1] == "CNA_TIPPLA"
				lCommit := oModCNA:SetValue(aDadCNA[nX][1], "601")
				Value := "601"
			ElseIf aDadCNA[nX][1] == "CNA_NUMERO"
				If Empty(oModCNA:GetValue(aDadCNA[nX][1]))
					lCommit := oModCNA:LoadValue(aDadCNA[nX][1], cNumero)
				else
					lCommit := .T.
				Endif
				Value := cNumero
			Else
				lCommit := oModCNA:SetValue(aDadCNA[nX][1], aDadCNA[nX][2])
				Value := cValToChar(aDadCNA[nX][2])
			EndIf

			If !lCommit
				
				cMenssagem := cValToChar(aDadCNA[nX][2]) + "-[D]-"+Value+"=" + oModel:GetErrorMessage()[6]
				cMenssagem := NoAcento(cMenssagem)
				cMenssagem := StrTran(cMenssagem,".","")

				U_MonitRes("000009", 2, , cIdPZB, cMenssagem, .F., aDadCN9[nPosCon][2], "", cBody, "", .F., .F.)

				//Finaliza o processo na PZB
				U_MonitRes("000009", 3, , cIdPZB, , .F.)

				cJson := '{'
				cJson += '"errorMessage":"' + cMenssagem + '",'
				cJson += '"lret":false'
				cJson += '}'

				cJson := encodeutf8(cJson)
				::SetContentType("application/json")
				::SetResponse( cJson )

				(cAlsQry)->(dbCloseArea())

				Return(.T.)

			EndIf

		Next nX

		AADD(aPlanilhas, "601")
	
	Else
		
		//Posiciona o cliente
		SA1->(DbSeek(xFilial("SA1") + aDadCNC[nPosCli][2]))

		//Alteração preenche a revisão
		If lAltera
			oModCNA:SetValue("CNA_REVISA", cRevisa)
		EndIf
		
		//S� adicona a planilha 600 se tiver produto mensal
		If Len(aDadCNB) > 0
		
			//Planilhas
			For nX := 1 to len(aDadCNA)

				If aDadCNA[nX][1] == "CNA_NUMERO"
					lCommit := oModCNA:SetValue(aDadCNA[nX][1], "000001")
					if !lCommit
						lCommit := oModCNA:LoadValue(aDadCNA[nX][1], "000001")
					endif
				Else
					If aDadCNA[nX][1] != "CNA_DTINI"
						lCommit := oModCNA:SetValue(aDadCNA[nX][1], aDadCNA[nX][2])
					Endif
				EndIf
							
				If !lCommit
					
					cMenssagem := cValToChar(aDadCNA[nX][2]) + "-[E]-" + oModel:GetErrorMessage()[6]
					cMenssagem := NoAcento(cMenssagem)
					cMenssagem := StrTran(cMenssagem,".","")

					U_MonitRes("000009", 2, , cIdPZB, cMenssagem, .F., aDadCN9[nPosCon][2], "", cBody, "", .F., .F.)

					//Finaliza o processo na PZB
					U_MonitRes("000009", 3, , cIdPZB, , .F.)

					cJson := '{'
					cJson += '"errorMessage":"' + cMenssagem + '",'
					cJson += '"lret":false'
					cJson += '}'

					cJson := encodeutf8(cJson)
					::SetContentType("application/json")
					::SetResponse( cJson )

					(cAlsQry)->(dbCloseArea())

					Return(.T.)

				EndIf

			Next nX

			//Se existir carencia ou isen��o cria a CNH
			If nPosCar > 0 .Or. nPosIse > 0

				lCommit := oModCNH:LoadValue("CNH_CODIGO", "00002")

			EndIf

			If !lCommit
						
				cMenssagem := aDadCNB[nX][nY][1] + "-[F]-" + oModel:GetErrorMessage()[6]
				cMenssagem := NoAcento(cMenssagem)
				cMenssagem := StrTran(cMenssagem,".","")

				U_MonitRes("000009", 2, , cIdPZB, cMenssagem, .F., aDadCN9[nPosCon][2], "", cBody, "", .F., .F.)

				//Finaliza o processo na PZB
				U_MonitRes("000009", 3, , cIdPZB, , .F.)

				cJson := '{'
				cJson += '"errorMessage":"' + cMenssagem + '",'
				cJson += '"lret":false'
				cJson += '}'

				cJson := encodeutf8(cJson)
				::SetContentType("application/json")
				::SetResponse( cJson )

				(cAlsQry)->(dbCloseArea())

				Return(.T.)
				
			EndIf

			AADD(aPlanilhas, "600")

			cItem := "01"
			
			//Itens do contrato recorrente
			For nX := 1 to len(aDadCNB)

				//Verifica se possui valor unitário, se não pula
				nPosVl := aScan(aDadCNB[nX], {|x| Alltrim(x[1]) == "CNB_VLUNIT" })

				If aDadCNB[nX][nPosVl][2] == 0
					Loop
				EndIF

				//Adiciona nova linha, se tem produto preenchido no modelo ja � porque a linha anterior ja foi consumida.
				If nX <= len(aDadCNB) .And. !Empty(oModCnb:GetValue("CNB_PRODUT")) .And. nX > 1
				
					If ( nNewLine := oModCNB:AddLine() ) == nLineCNB
						cErro := "Erro ao adicionar linha"
						lCommit := .F.
						Exit
					Else
						nLineCNB++
						oModCNB:GoLine(nNewLine)
						cItem := Soma1(cItem)
					EndIf

				EndIf

				If !lCommit
					
					cMenssagem := oModel:GetErrorMessage()[6]
					cMenssagem := NoAcento(cMenssagem)
					cMenssagem := StrTran(cMenssagem,".","")

					U_MonitRes("000009", 2, , cIdPZB, cMenssagem, .F., aDadCN9[nPosCon][2], "", cBody, "", .F., .F.)

					//Finaliza o processo na PZB
					U_MonitRes("000009", 3, , cIdPZB, , .F.)

					cJson := '{'
					cJson += '"errorMessage":"[G] - ' + cMenssagem + '",'
					cJson += '"lret":false'
					cJson += '}'

					cJson := encodeutf8(cJson)
					::SetContentType("application/json")
					::SetResponse( cJson )

					(cAlsQry)->(dbCloseArea())

					Return(.T.)
					
				EndIf

				If lAltera
					oModCNB:SetValue("CNB_REVISA", cRevisa)
				EndIf

				oModCNB:SetValue("CNB_ITEM", cItem)
				oModCNB:LoadValue("CNB_NUMERO", "000001")

				//Quantidade fixa de acordo com as parcelas
				If oModCN9:GetValue("CN9_UNVIGE") == "1"
					oModCNB:SetValue("CNB_QUANT", 1)
				Else
					oModCNB:SetValue("CNB_QUANT", oModCN9:GetValue("CN9_VIGE"))
				Endif

				For nY := 1 to len(aDadCNB[nX])
					
					lCommit := oModCNB:SetValue(aDadCNB[nX][nY][1], aDadCNB[nX][nY][2])

					//Chegou no produto ja posiciona as tabelas para preenchimento da TES
					If aDadCNB[nX][nY][1] == "CNB_PRODUT" .And. lCommit

						If SB1->(DbSeek(xFilial("SB1") + aDadCNB[nX][nY][2]))

							//Posiciona ZZ3
							If ZZ3->(DbSeek(xFilial("ZZ3") + SB1->B1_XTIPO + SA1->A1_XTIPO))

								//Seta TES
								lCommit := oModCNB:SetValue("CNB_TS", ZZ3->ZZ3_TES)

							EndIf
						
						EndIf

					EndIf
								
					If !lCommit
						
						cMenssagem := aDadCNB[nX][nY][1] + "-[G]-" + oModel:GetErrorMessage()[6]
						cMenssagem := NoAcento(cMenssagem)
						cMenssagem := StrTran(cMenssagem,".","")

						U_MonitRes("000009", 2, , cIdPZB, cMenssagem, .F., aDadCN9[nPosCon][2], "", cBody, "", .F., .F.)

						//Finaliza o processo na PZB
						U_MonitRes("000009", 3, , cIdPZB, , .F.)

						cJson := '{'
						cJson += '"errorMessage":"[H] - ' + cMenssagem + '",'
						cJson += '"lret":false'
						cJson += '}'

						cJson := encodeutf8(cJson)
						::SetContentType("application/json")
						::SetResponse( cJson )

						(cAlsQry)->(dbCloseArea())

						Return(.T.)
						
					EndIf

				Next nY

			
				If !lCommit
					
					cMenssagem := oModel:GetErrorMessage()[6]
					cMenssagem := NoAcento(cMenssagem)
					cMenssagem := StrTran(cMenssagem,".","")

					U_MonitRes("000009", 2, , cIdPZB, cMenssagem, .F., aDadCN9[nPosCon][2], "", cBody, "", .F., .F.)

					//Finaliza o processo na PZB
					U_MonitRes("000009", 3, , cIdPZB, , .F.)

					cJson := '{'
					cJson += '"errorMessage":"[I] - ' + cMenssagem + '",'
					cJson += '"lret":false'
					cJson += '}'

					cJson := encodeutf8(cJson)
					::SetContentType("application/json")
					::SetResponse( cJson )

					(cAlsQry)->(dbCloseArea())

					Return(.T.)
					
				EndIf

			Next nX

		EndIf

		//Se tiver item de ativação
		If Len(aDadAtiv) > 0

			If Len(aDadCNB) > 0

				cNumero := Soma1(cNumero)

				//Adiciona planilha fixa 
				If ( nNewLine := oModCNA:AddLine() ) == nLine
					
					cMenssagem := oModel:GetErrorMessage()[6]
					cMenssagem := NoAcento(cMenssagem)
					cMenssagem := StrTran(cMenssagem,".","")

					U_MonitRes("000009", 2, , cIdPZB, cMenssagem, .F., aDadCN9[nPosCon][2], "", cBody, "", .F., .F.)

					//Finaliza o processo na PZB
					U_MonitRes("000009", 3, , cIdPZB, , .F.)

					cJson := '{'
					cJson += '"errorMessage":"[J] - ' + cMenssagem + '",'
					cJson += '"lret":false'
					cJson += '}'

					cJson := encodeutf8(cJson)
					::SetContentType("application/json")
					::SetResponse( cJson )

					(cAlsQry)->(dbCloseArea())

					Return(.T.)

				EndIf

				nLine++

			EndIf

			//Alteração preenche a revisão
			If lAltera
				oModCNA:SetValue("CNA_REVISA", cRevisa)
			EndIf
			
			For nX := 1 to len(aDadCNA)
				
				//Pula isen��o e carencia
				If aDadCNA[nX][1] $ "CNA_XMSCAR/CNA_XMSISE/CNA_XINISE" 
					Loop
				EndIf
				
				If aDadCNA[nX][1] == "CNA_TIPPLA"
					lCommit := oModCNA:SetValue(aDadCNA[nX][1], "602")
				ElseIf aDadCNA[nX][1] == "CNA_NUMERO"
					lCommit := oModCNA:SetValue(aDadCNA[nX][1], cNumero)
					If !lCommit
						lCommit := oModCNA:LoadValue(aDadCNA[nX][1], cNumero)
					Endif
				Else
					If aDadCNA[nX][1] != "CNA_DTINI"
						lCommit := oModCNA:SetValue(aDadCNA[nX][1], aDadCNA[nX][2])
					endif
				EndIf

				If !lCommit
					
					cMenssagem := cValToChar(aDadCNA[nX][2]) + "-[H]-" + oModel:GetErrorMessage()[6]
					cMenssagem := NoAcento(cMenssagem)
					cMenssagem := StrTran(cMenssagem,".","")

					U_MonitRes("000009", 2, , cIdPZB, cMenssagem, .F., aDadCN9[nPosCon][2], "", cBody, "", .F., .F.)

					//Finaliza o processo na PZB
					U_MonitRes("000009", 3, , cIdPZB, , .F.)

					cJson := '{'
					cJson += '"errorMessage":"' + cMenssagem + '",'
					cJson += '"lret":false'
					cJson += '}'

					cJson := encodeutf8(cJson)
					::SetContentType("application/json")
					::SetResponse( cJson )

					(cAlsQry)->(dbCloseArea())

					Return(.T.)

				EndIf

			Next nX

			AADD(aPlanilhas, "602")

			//Itens da planilha fixa
			cItem 		:= "01"
			nLineCNB 	:= 0

			oModCNA:GoLine(nLine)
			
			//Itens do contrato fixo
			For nX := 1 to len(aDadAtiv)

				oModCNB:SetValue("CNB_ITEM", cItem)
				oModCNB:LoadValue("CNB_NUMERO", "000002")

				If lAltera
					oModCNB:SetValue("CNB_REVISA", cRevisa)
				EndIf

				For nY := 1 to len(aDadAtiv[nX])
					
					lCommit := oModCNB:SetValue(aDadAtiv[nX][nY][1], aDadAtiv[nX][nY][2])

					//Chegou no produto ja posiciona as tabelas para preenchimento da TES
					If aDadAtiv[nX][nY][1] == "CNB_PRODUT" .And. lCommit

						If SB1->(DbSeek(xFilial("SB1") + aDadAtiv[nX][nY][2]))

							//Posiciona ZZ3
							If ZZ3->(DbSeek(xFilial("ZZ3") + SB1->B1_XTIPO + SA1->A1_XTIPO))

								//Seta TES
								lCommit := oModCNB:SetValue("CNB_TS", ZZ3->ZZ3_TES)

							EndIf
						
						EndIf

					EndIf
								
					If !lCommit
						
						cMenssagem := aDadAtiv[nX][1] + "-[I]-" + oModel:GetErrorMessage()[6]
						cMenssagem := NoAcento(cMenssagem)
						cMenssagem := StrTran(cMenssagem,".","")

						U_MonitRes("000009", 2, , cIdPZB, cMenssagem, .F., aDadCN9[nPosCon][2], "", cBody, "", .F., .F.)

						//Finaliza o processo na PZB
						U_MonitRes("000009", 3, , cIdPZB, , .F.)

						cJson := '{'
						cJson += '"errorMessage":"[L] - ' + cMenssagem + '",'
						cJson += '"lret":false'
						cJson += '}'

						cJson := encodeutf8(cJson)
						::SetContentType("application/json")
						::SetResponse( cJson )

						(cAlsQry)->(dbCloseArea())

						Return(.T.)
						
					EndIf

				Next nY

				//Adiciona nova linha
				If nX < len(aDadAtiv)
				
					If ( nNewLine := oModCNB:AddLine() ) == nLineCNB
						cErro := "Erro ao adicionar linha"
						lCommit := .F.
						Exit
					Else
						nLineCNB++
						oModCNB:GoLine(nNewLine)
						cItem := Soma1(cItem)
					EndIf

				EndIf

				If !lCommit
					
					cMenssagem := oModel:GetErrorMessage()[6]
					cMenssagem := NoAcento(cMenssagem)
					cMenssagem := StrTran(cMenssagem,".","")

					U_MonitRes("000009", 2, , cIdPZB, cMenssagem, .F., aDadCN9[nPosCon][2], "", cBody, "", .F., .F.)

					//Finaliza o processo na PZB
					U_MonitRes("000009", 3, , cIdPZB, , .F.)

					cJson := '{'
					cJson += '"errorMessage":"[M] - ' + cMenssagem + '",'
					cJson += '"lret":false'
					cJson += '}'

					cJson := encodeutf8(cJson)
					::SetContentType("application/json")
					::SetResponse( cJson )

					(cAlsQry)->(dbCloseArea())

					Return(.T.)
					
				EndIf

			Next nX

		EndIf
		
		//Adiciona planilha fixa 
		If ( nNewLine := oModCNA:AddLine() ) == nLine
			
			cMenssagem := oModel:GetErrorMessage()[6]
			cMenssagem := NoAcento(cMenssagem)
			cMenssagem := StrTran(cMenssagem,".","")

			U_MonitRes("000009", 2, , cIdPZB, cMenssagem, .F., aDadCN9[nPosCon][2], "", cBody, "", .F., .F.)

			//Finaliza o processo na PZB
			U_MonitRes("000009", 3, , cIdPZB, , .F.)

			cJson := '{'
			cJson += '"errorMessage":"[N] - ' + cMenssagem + '",'
			cJson += '"lret":false'
			cJson += '}'

			cJson := encodeutf8(cJson)
			::SetContentType("application/json")
			::SetResponse( cJson )

			(cAlsQry)->(dbCloseArea())

			Return(.T.)
			
		EndIf
		
		cNumero := Soma1(cNumero)
		
		//Altera��o preenche a revisão
		If lAltera
			oModCNA:SetValue("CNA_REVISA", cRevisa)
		EndIf
		
		//Insere planilha para medi��o livre
		For nX := 1 to len(aDadCNA)

			//Pula isen��o e carencia
			If aDadCNA[nX][1] $ "CNA_XMSCAR/CNA_XMSISE/CNA_XINISE" 
				Loop
			EndIf
			
			If aDadCNA[nX][1] == "CNA_TIPPLA"
				lCommit := oModCNA:SetValue(aDadCNA[nX][1], "601")
			ElseIf aDadCNA[nX][1] == "CNA_NUMERO"
				lCommit := oModCNA:SetValue(aDadCNA[nX][1], cNumero)
			Else
				if aDadCNA[nX][1] != "CNA_DTINI"
					lCommit := oModCNA:SetValue(aDadCNA[nX][1], aDadCNA[nX][2])
				endif
			EndIf

			If !lCommit
				
				cMenssagem := cValToChar(aDadCNA[nX][2]) + "-[J]-" + oModel:GetErrorMessage()[6]
				cMenssagem := NoAcento(cMenssagem)
				cMenssagem := StrTran(cMenssagem,".","")

				U_MonitRes("000009", 2, , cIdPZB, cMenssagem, .F., aDadCN9[nPosCon][2], "", cBody, "", .F., .F.)

				//Finaliza o processo na PZB
				U_MonitRes("000009", 3, , cIdPZB, , .F.)

				cJson := '{'
				cJson += '"errorMessage":"' + cMenssagem + '",'
				cJson += '"lret":false'
				cJson += '}'

				cJson := encodeutf8(cJson)
				::SetContentType("application/json")
				::SetResponse( cJson )

				(cAlsQry)->(dbCloseArea())

				Return(.T.)

			EndIf


		Next nX

		AADD(aPlanilhas, "601")

	EndIf

	//Se nÃ¯Â¿Â½o tiver dado erro na ediÃ¯Â¿Â½Ã¯Â¿Â½o dos campos, forÃ¯Â¿Â½o a validaÃ¯Â¿Â½Ã¯Â¿Â½o total do modelo para ver se nÃ¯Â¿Â½o ficou nenhum campo obrigatÃ¯Â¿Â½rio vazio.
	If !lCommit

		cMenssagem := oModel:GetErrorMessage()[6]
		cMenssagem := NoAcento(cMenssagem)
		cMenssagem := StrTran(cMenssagem,".","")

		U_MonitRes("000009", 2, , cIdPZB, cMenssagem, .F., aDadCN9[nPosCon][2], "", cBody, "", .F., .F.)

		//Finaliza o processo na PZB
		U_MonitRes("000009", 3, , cIdPZB, , .F.)

		cJson := '{'
		cJson += '"errorMessage":"[K] - ' + cMenssagem + '",'
		cJson += '"lret":false'
		cJson += '}'

		cJson := encodeutf8(cJson)
		::SetContentType("application/json")
		::SetResponse( cJson )

		(cAlsQry)->(dbCloseArea())

		Return(.T.)	

	Else
		
		//Posiciona a primeira planilha que Ã© a 600
		oModCNA:GoLine(1)

		//ForÃ§a preenchimento de campos que o gatilho nÃ£o pega.
		oModCNA:SetValue("CNA_DTFIM", oModCN9:GetValue("CN9_DTFIM"))
		
		cModeCN9 := oModCN9:Getvalue("CN9_UNVIGE")
		//if cModeCN9 == "1"
		//	oModCN9:Setvalue("CN9_VIGE",1)
		//endif

		cDtAux	:= DTOS(oModCN9:GetValue("CN9_DTINIC"))
		cComp 	:= Substr(cDtAux,5,2) + "/" + Left(cDtAux,4)
		
		//Parametros cronograma financeiro
		aPergunte := {}

		If Right(cDtAux,2) == "01"
			cCondPg := "D" + Right(oModCN9:GetValue("CN9_CONDPG"),2)
		Else
			cCondPg := oModCN9:GetValue("CN9_CONDPG")
		EndIf
		
		cDtIni 	:= DTOC(oModCN9:GetValue("CN9_DTINIC"))
		cDtIni	:= CTOD("01" + Right(cDtIni,6))
		
		If Left(oModCN9:GetValue("CN9_CONDPG"),1) <> 'N'

			dDtComp := CTOD("01/"+cComp)
			dDtComp	:= MonthSum(dDtComp,1)
			dDtComp	:= DTOS(dDtComp)
			
			cComp := Substr(dDtComp, 5,2) + "/" + Left(dDtComp,4)
			if cModeCN9 != "1"
				cDtIni := DTOC(MonthSum(oModCN9:GetValue("CN9_DTINIC"), 1))
				cDtIni	:= CTOD("01" + Right(cDtIni,6))
			Endif
		EndIf
		if cModeCN9 == "1"
			AADD(aPergunte, 3) //Periodicidade
			AADD(aPergunte, 1) //Dias
			AADD(aPergunte, .F.) //Ultimo dia do mÃªs
			AADD(aPergunte, cComp) //Competencia
			AADD(aPergunte, cDtIni) //Data prevista primeira mediÃ§Ã£o		
			AADD(aPergunte, 1) //Quantidade de parcelas
			AADD(aPergunte, "" ) //CondiÃ§Ã£o de pagamento
			AADD(aPergunte, .F.) //Ultimo dia
		Else
			AADD(aPergunte, 4) //Periodicidade
			AADD(aPergunte, 0) //Dias
			AADD(aPergunte, .F.) //Ultimo dia do mÃªs
			AADD(aPergunte, cComp) //Competencia
			AADD(aPergunte, cDtIni) //Data prevista primeira mediÃ§Ã£o
			AADD(aPergunte, oModCN9:GetValue("CN9_VIGE")) //Quantidade de parcelas
			AADD(aPergunte, cCondPg ) //CondiÃ§Ã£o de pagamento
			AADD(aPergunte, .F.) //Ultimo dia
		Endif
		
		//Gera cronograma financeiro
		If !lContVoz .And. len(aDadCNB) > 0 .And. oJsoAux:status_sales != "Cancelado"
			lCommit := CN300AddCrg(aPergunte)
		EndIf

		//Gera cronograma para a planilha 602
		If lCommit

			If len(aDadCNB) == 0 .And. len(aPlanilhas) == 2

				//Posiciona a primeira planilha que Ã© a 600
				oModCNA:GoLine(1)

				//Sempre dentro do mes
				aPergunte[7] := "D" + Right(oModCN9:GetValue("CN9_CONDPG"),2) 

				//Unica parcela para pontual
				aPergunte[6] := 1

				//ForÃ§a preenchimento de campos que o gatilho nÃ£o pega.
				oModCNA:SetValue("CNA_DTFIM", oModCN9:GetValue("CN9_DTFIM"))
				
				If !lContVoz
					lCommit := CN300AddCrg(aPergunte)
				EndIf
			
			//Só faz o cronograma da segunda planilhas se tivermos 3.
			ElseIf len(aPlanilhas) == 3
			
				//Posiciona a primeira planilha que Ã© a 600
				oModCNA:GoLine(2)

				//Sempre dentro do mes
				aPergunte[7] := "D" + Right(oModCN9:GetValue("CN9_CONDPG"),2) 

				//Unica parcela para pontual
				aPergunte[6] := 1

				//ForÃ§a preenchimento de campos que o gatilho nÃ£o pega.
				oModCNA:SetValue("CNA_DTFIM", oModCN9:GetValue("CN9_DTFIM"))
				
				If !lContVoz
					lCommit := CN300AddCrg(aPergunte)
				EndIf

			EndIf

		Else

			cMenssagem := oModel:GetErrorMessage()[6]
			cMenssagem := NoAcento(cMenssagem)
			cMenssagem := StrTran(cMenssagem,".","")

			U_MonitRes("000009", 2, , cIdPZB, cMenssagem, .F., aDadCN9[nPosCon][2], "", cBody, "", .F., .F.)

			//Finaliza o processo na PZB
			U_MonitRes("000009", 3, , cIdPZB, , .F.)

			cJson := '{'
			cJson += '"errorMessage":"[P] - ' + cMenssagem + '",'
			cJson += '"lret":false'
			cJson += '}'

		EndIf
			

		If lCommit

			lRet := oModel:VldData()

			If lRet

				//Se for alteração exclui CPD para não dar erro de unituqe
				If lAltera

					cQuery := " UPDATE " + RetSQLName("CPD")
					cQuery += " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
					cQuery += " WHERE CPD_CONTRA = '" + oModCN9:GetValue("CN9_NUMERO") + "' AND "
					cQuery += " D_E_L_E_T_=  ' ' "

					TcSqlExec(cQuery)
					
				EndIf

				lRet := oModel:CommitData()

			EndIf
			
			//Grava situaÃ§Ã£o de vigente
			If lRet

				If oJsoAux:status_sales == "Cancelado"

					dDataCanc:= STOD(StrTran(oJsoAux:Data_Cancelamento, "-", ""))

					CN9->(RecLock("CN9",.F.))

						CN9->CN9_XDTCAN	:= dDataCanc
						CN9->CN9_XDTSOL	:= STOD(StrTran(oJsoAux:CN9_XDTSOL, "-", ""))

					CN9->(MsUnlock())

				EndIf

				CN9->(RecLock("CN9",.F.))

					CN9->CN9_SITUAC := "05"

				CN9->(MsUnlock())

				//Grava no contrato anterior a revisão atual
				If lAltera
					
					CN9->(DbGoTo(nRecCN9))

					CN9->(RecLock("CN9",.F.))

						CN9->CN9_SITUAC := "10"
						CN9->CN9_REVATU	:= cRevisa

					CN9->(MsUnlock())
				
				EndIf

				DbSelectArea("CNN")
				CNN->(DbSetOrder(1))
				
				If !CNN->(DbSeek(xFilial("CNN") + "000000" + CN9->CN9_NUMERO))
				
					//Grava CNN como o job não possui usuário logado
					RecLock("CNN",.T.)

						CNN->CNN_FILIAL := xFilial("CNN")
						CNN->CNN_CONTRA := CN9->CN9_NUMERO
						CNN->CNN_USRCOD := "000000"
						CNN->CNN_TRACOD := "001"

					MsUnlock()

				EndIf

				//Grava mensagem de sucesso no monitor
				U_MonitRes("000009", 2, , cIdPZB, "Contrato " + IIf(lIncl, "incluso", "versionado") + " com sucesso", .T., aDadCN9[nPosCon][2], "", cBody, aDadCN9[nPosCon][2], .F., .F.)

				//Finaliza o processo na PZB
				U_MonitRes("000009", 3, , cIdPZB, , .T.)

				cJson := "{" 
				cJson += '"lret":true'
				cJson += '}'

			Else

				cMenssagem := oModel:GetErrorMessage()[6]
				cMenssagem := NoAcento(cMenssagem)
				cMenssagem := StrTran(cMenssagem,".","")

				U_MonitRes("000009", 2, , cIdPZB, cMenssagem, .F., aDadCN9[nPosCon][2], "", cBody, "", .F., .F.)

				//Finaliza o processo na PZB
				U_MonitRes("000009", 3, , cIdPZB, , .F.)

				cJson := '{'
				cJson += '"errorMessage":"[Q] - ' + cMenssagem + '",'
				cJson += '"lret":false'
				cJson += '}'

			EndIf

		Else

			cMenssagem := oModel:GetErrorMessage()[6]
			cMenssagem := NoAcento(cMenssagem)
			cMenssagem := StrTran(cMenssagem,".","")

			U_MonitRes("000009", 2, , cIdPZB, cMenssagem, .F., aDadCN9[nPosCon][2], "", cBody, "", .F., .F.)

			//Finaliza o processo na PZB
			U_MonitRes("000009", 3, , cIdPZB, , .F.)

			cJson := '{'
			cJson += '"errorMessage":"[R] - ' + cMenssagem + '",'
			cJson += '"lret":false'
			cJson += '}'

		EndIf

	EndIf
	
	cJson := encodeutf8(cJson)
	
	::SetContentType("application/json")
	::SetResponse( cJson )

	(cAlsQry)->(dbCloseArea())

Return(.T.)

//*******************
// GET PRODUTO
//*******************

WsRestFul GetProd Description "Metodo Responsavel por Retornar Consulta de Produtos"

WsData cCgcEmp		As String Optional

WsMethod Get Description "Consulta de estoque" WsSyntax "/GetProd"

End WsRestFul

WsMethod Get WsReceive cCgcEmp WsService GetProd

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
//Local nPosEmp	:= 0
//Local cCgcEmp   := IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")

Private cAlsQry   := CriaTrab(Nil,.F.)
Private cAlsRes   := CriaTrab(Nil,.F.)

	cQuery := " SELECT PR3.* FROM " + RetSqlName("PR3") + " PR3 "
	cQuery += " INNER JOIN " + RetSqlName("PR2") + " PR2 "
	cQuery += " ON PR3_FILIAL = PR2_FILIAL AND PR3_CODIGO = PR2_CODIGO "
	cQuery += " WHERE PR2_CODPZA = '000007' AND PR2.D_E_L_E_T_ = ' '  AND PR3.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	While !(cAlsQry)->(Eof())

		If nCount == 1
			cQryRes := " SELECT  "
			cQryRes += (cAlsQry)->PR3_CPODES  
		Else
			If (cAlsQry)->PR3_ISFUNC <> "S" 
				cQryRes += " , " + (cAlsQry)->PR3_CPODES  
			EndIf
		EndIf

		AADD(aCpos, Alltrim((cAlsQry)->PR3_CPODES) )
		AADD(aCposCab, Alltrim((cAlsQry)->PR3_CPOORI))

		If (cAlsQry)->PR3_ISFUNC == "S" 
			AADD(aCont, {Alltrim((cAlsQry)->PR3_CONTEU),(cAlsQry)->PR3_TPCONT})
		Else
			AADD(aCont, {"",""})
		EndIf

		nCount++
		(cAlsQry)->(DbSkip())

	End

	If !Empty(cQryRes)
		cQryRes += " , PR1.R_E_C_N_O_ RECNOPR1"
		cQryRes += " FROM " + RetSqlName("SB1") + " SB1 "
		cQryRes += " INNER JOIN " + RetSqlName("PR1") + " PR1 "
		cQryRes += " ON PR1_FILIAL = '" + xFilial("PR1") + "' "
		cQryRes += " AND SB1.R_E_C_N_O_ = PR1_RECNO "
		cQryRes += " WHERE PR1_STINT = 'P' "
		cQryRes += " AND PR1_ALIAS = 'SB1' "
		cQryRes += " AND SB1.D_E_L_E_T_ = ' ' ORDER BY B1_COD "

		If Select(cAlsRes) > 0; (cAlsRes)->(dbCloseArea()); Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryRes),cAlsRes,.T.,.T.)

		If !(cAlsRes)->(Eof()) 

			nQtdReg := Contar(cAlsRes,"!Eof()")

			//Cria serviÃ¯Â¿Â½o no montitor
			aCriaServ := U_MonitRes("000007", 1, nQtdReg)   
			cIdPZB 	  := aCriaServ[2]

			cJson := '{'
			cJson += '"produtos":['

			(cAlsRes)->(DbGoTop())

		Else

			cJson += "{" 
			cJson += '"errorMessage":"Nao existem produtos pendentes de integraÃƒÂ§ÃƒÂ£o.",'
			cJson += '"lret":false'
			cJson += "}"

			::SetContentType("application/json")
			::SetResponse( cJson )

			Return(.T.)

		EndIf

		While !(cAlsRes)->(Eof())

			cJson += "{"

			For nX := 1 to Len(aCpos)

				If Empty(aCont[nX][1])    

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
				
					If aCont[nX][2] == "1"
						cConteudo := &(aCont[nX][1])
					Else
						cConteudo := (aCont[nX][1])
					EndIf

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

			cJson += '"lret":true'
			cJson += "},"

			cMenssagem  := "Get realizado com sucesso."
			U_MonitRes("000007", 2, , cIdPZB, cMenssagem, .T., "Get de Produtos", cJson, "", "", .F., .F.)

			nLine++

			(cAlsRes)->(DbSkip())

		End

		(cAlsRes)->(dbCloseArea())

		//Finaliza o processo na PZB
		U_MonitRes("000007", 3, , cIdPZB, , .T.)

	EndIf

	cJson := Substr(cJson, 1, Rat(",", cJson) -1)
	
	cJson += "]}"

	(cAlsQry)->(dbCloseArea())

	::SetContentType("application/json")
	::SetResponse( cJson )

Return(.T.)

//*************
// POST PEDIDO
//*************

WsRestFul PostPR1 Description "Metodo Responsavel por Confirmar integraÃƒÂ§ÃƒÂ£o na PR1"

WsData cCgcEmp		As String

WsMethod Post Description "Confirma integraÃƒÂ§ÃƒÂ£o na PR1" WsSyntax "/PostPR1"

End WsRestFul

WsMethod Post WsReceive cCgcEmp WsService PostPR1

Local cJson     	:= ""
Local cBody     	:= ::GetContent()
Local cQuery    	:= ""
Local cAlsQry   	:= CriaTrab(Nil,.F.)
Local cCgcEmp   	:= IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")
Local cAllias		:= ""

Local nPosEmp		:= 0

Local aEmpresas 	:= FwLoadSM0()

Private oJsoAux   	:= Nil

FWJsonDeserialize(cBody, @oJsoAux)

nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == cCgcEmp })

If nPosEmp == 0
	cJson := '{Empresa nao cadastrada.}'
	::SetContentType("application/json")
	::SetResponse( cJson )
	Return .T.
Else
	RpcClearEnv()
	RpcSetEnv(aEmpresas[nPosEmp][1],aEmpresas[nPosEmp][2])
EndIf

cAllias := AllTrim(oJsoAux:Tabela)

cQuery := " SELECT R_E_C_N_O_ AS RECPR1 "
cQuery += "	  FROM " + RETSQLNAME("PR1") + " PR1 "
cQuery += "	 WHERE PR1_FILIAL = '" + xFilial("PR1") + "' "
cQuery += "	   AND PR1_ALIAS = '" + cAllias + "' "
cQuery += "	   AND PR1_CHAVE = '" + oJsoAux:Chave + "' "
cQuery += "	   AND PR1_STINT = 'P' "
cQuery += "	   AND D_E_L_E_T_ = ' ' "

If Select(cAlsQry) > 0
	 (cAlsQry)->(DBCloseArea())
Endif

DBUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

If (cAlsQry)->(!EOF())

	PR1->(DBGoTo((cAlsQry)->RECPR1))
	RECLOCK("PR1",.F.)
		PR1->PR1_STINT := "I"
	PR1->(MSUnlock())

	cJson += "{" 
	cJson += '"lret":true'
	cJson += "}"

Else
	cJson += "{" 
	cJson += '"errorMessage":"Chave de Resgistro nÃƒÂ£o encontrada.",'
	cJson += '"lret":false'
	cJson += "}"

EndIf

::SetResponse( cJson )
::SetContentType("application/json")

Return(.T.)

//*************q
// GET TRACKING
//*************

WsRestFul GetTrackn Description "Metodo Responsavel por verificar status de nota"

WsData cTabela		As String
WsData cCgcEmp		As String

WsMethod Get Description "Verificar Status de Nota" WsSyntax "/GetTrackn"

End WsRestFul

WsMethod Get WsReceive cCgcEmp WsService GetTrackn

Local cJson     	:= ""
Local cQuery    	:= ""
Local cIdPZB		:= ""
Local cQuery2    	:= ""
Local cQuery3    	:= ""
Local cQuery4   	:= ""
Local cAlsQry   	:= CriaTrab(Nil,.F.)
Local cCgcEmp   	:= IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")
Local cAlsQry2   	:= ""
Local cAlsQry3   	:= CriaTrab(Nil,.F.)
Local cAlsQry4  	:= CriaTrab(Nil,.F.)
Local cAlsQry5  	:= CriaTrab(Nil,.F.)
Local cConteudo		:= ""

Local _nX			:= 0
Local nQtdReg		:= 0
Local nPosEmp		:= 0

Local aNFDPara		:= {}
Local aTitDPara		:= {}
Local aCriaServ		:= {}
Local aEmpresas 	:= FwLoadSM0()

Private oJsoAux   	:= Nil

nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == cCgcEmp })

If nPosEmp == 0
	cJson := '{"Erro":"Empresa nao cadastrada."}'
	::SetContentType("application/json")
	::SetResponse( cJson )
	Return .T.
Else
	RpcClearEnv()
	RpcSetEnv(aEmpresas[nPosEmp][1],aEmpresas[nPosEmp][2])
EndIf
**********************************************************************************************************
//Movimenta��es - Notas Fiscais
cQuery := " SELECT TOP 100 R_E_C_N_O_ AS RECPR1, PR1_RECNO AS RECREG, PR1_ALIAS, PR1_CHAVE, PR1_TIPREQ "
cQuery += "	  FROM " + RETSQLNAME("PR1") + " PR1 "
cQuery += "	 WHERE PR1_FILIAL = '" + xFilial("PR1") + "' "
cQuery += "	   AND PR1_ALIAS IN ('SF2') "
cQuery += "	   AND PR1_STINT = 'P' AND PR1_TIPREQ = '2' "
cQuery += "	   AND D_E_L_E_T_ = ' ' "

If Select(cAlsQry) > 0
	 (cAlsQry)->(DBCloseArea())
Endif

DBUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

If !(cAlsQry)->(Eof())

	nQtdReg := Contar(cAlsQry,"!EOF()")
	(cAlsQry)->(DBGoTop())

	//Cria serviÃ¯Â¿Â½o no montitor
	aCriaServ := U_MonitRes("000008", 1, nQtdReg)   
	cIdPZB 	  := aCriaServ[2]
	
	DBSelectArea("SF2")
	SF2->(DBSetOrder(1))
	
	DBSelectArea("SE5")
	SE5->(DBSetOrder(1))

	DBSelectArea("SC5")
	SC5->(DBSetOrder(1))

	DBSelectArea("SE1")
	SE1->(DBSetOrder(1))

	cAlsQry2 := CriaTrab(Nil,.F.)

	cQuery2 := " SELECT PR3.* FROM " + RetSqlName("PR3") + " PR3 "
	cQuery2 += " INNER JOIN " + RetSqlName("PR2") + " PR2 "
	cQuery2 += " ON PR3_FILIAL = PR2_FILIAL AND PR3_CODIGO = PR2_CODIGO "
	cQuery2 += " WHERE PR2_CODPZA = '000008' AND PR2.D_E_L_E_T_ = ' '  AND PR3.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry2) > 0
		(cAlsQry2)->(DBCloseArea())
	Endif

	DBUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery2),cAlsQry2,.T.,.T.)

	While (cAlsQry2)->(!EOF())
		
		If	(SUBSTR(AllTrim((cAlsQry2)->PR3_CPOORI),1,2) == "F2" .OR.;
			SUBSTR(AllTrim((cAlsQry2)->PR3_CPOORI),1,2) == "C5")

			AADD(aNFDPara,{AllTrim((cAlsQry2)->PR3_TPCONT),;
						   AllTrim((cAlsQry2)->PR3_CPODES),;
						   AllTrim((cAlsQry2)->PR3_CPOORI),;
						   AllTrim((cAlsQry2)->PR3_CONTEU)}) 

		ElseIf SUBSTR(AllTrim((cAlsQry2)->PR3_CPOORI),1,2) == "E5"

			AADD(aTitDPara,{AllTrim((cAlsQry2)->PR3_TPCONT),;
						    AllTrim((cAlsQry2)->PR3_CPODES),;
						   	AllTrim((cAlsQry2)->PR3_CPOORI),;
						   	AllTrim((cAlsQry2)->PR3_CONTEU)}) 
			
		EndIf

		(cAlsQry2)->(DBSkip())

	EndDO
	
	(cAlsQry2)->(DBCloseArea())

	cJson := "{"
	cJson += '"Registros":['

	While (cAlsQry)->(!EOF())
		 
		If AllTrim((cAlsQry)->PR1_ALIAS) == 'SF2'

			//Busca vencimento por numero de nota
			cQuery := " SELECT DISTINCT E1_VENCREA FROM " + RetSQLName("SE1") + " SE1 "
			cQuery += " WHERE E1_FILIAL = '" + xFilial("SE1") + "' AND "
			cQuery += " E1_XID = '" + Alltrim((cAlsQry)->PR1_CHAVE) + "' AND "
			cQuery += " SE1.D_E_L_E_T_ = ' ' "
			
			//Busca AGL
			cQuery += " UNION ALL "
			cQuery += " SELECT DISTINCT E1_VENCREA FROM " + RetSQLName("SE1") + " SE1 "
			cQuery += " WHERE E1_FILIAL = '" + xFilial("SE1") + "' AND "
			cQuery += " E1_PREFIXO = 'AGL' AND "
			cQuery += " E1_NUM = '" + Alltrim((cAlsQry)->PR1_CHAVE) + "' AND "
			cQuery += " SE1.D_E_L_E_T_ = ' ' "

			If Select(cAlsQry5) > 0; (cAlsQry5)->(dbCloseArea()); Endif
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry5,.T.,.T.)

			If !(cAlsQry5)->(Eof())
				cDtVenc := Left((cAlsQry5)->E1_VENCREA, 4) + "-" + Substr( (cAlsQry5)->E1_VENCREA,5,2) + "-" + Right((cAlsQry5)->E1_VENCREA, 2)
			EndIf


			cQuery3 := " SELECT F2_FILIAL, F2_CLIENTE, F2_EMISSAO, D2_PEDIDO, SF2.R_E_C_N_O_ F2RECNO "
			cQuery3 += "   FROM " + RetSQLName("SF2") + " SF2 "
			cQuery3 += " INNER JOIN " + RetSqlName("SD2") + " SD2 "
			cQuery3 += " ON D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE "
 			cQuery3 += "  WHERE F2_XID    		= '" + Alltrim((cAlsQry)->PR1_CHAVE) + "' "
   			
			If (cAlsQry)->PR1_TIPREQ <> "3"
				cQuery3 += "    AND SF2.D_E_L_E_T_	= ' ' AND SD2.D_E_L_E_T_ = ' ' "
			EndIf
			
			If Select(cAlsQry3) > 0
	 			(cAlsQry3)->(DBCloseArea())
			Endif

			DBUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery3),cAlsQry3,.T.,.T.)

			//Posiciona SF2
			SF2->(DbGoTo( (cAlsQry3)->F2RECNO ))

			//Posiciona SC5
			SC5->(DbSeek( (cAlsQry3)->(F2_FILIAL + D2_PEDIDO) ))

			//Seta o CNPJ da empresa de acordo com a nota
			nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[1]) + Alltrim(x[2]) == cEmpAnt + (cAlsQry3)->F2_FILIAL })

			If nPosEmp == 0
				
				Conout("Erro:" + cEmpAnt + (cAlsQry3)->F2_FILIAL + SF2->F2_XID)

				(cAlsQry)->(DBSkip())

				Loop

			EndIf

			cCgcEmp := aEmpresas[nPosEmp][18]

			cJson 	+= "{"
			cJson	+= '"AccountId__r":'
			cJson 	+= "{"
			cJson	+= '"CID__c":'
			cJson	+= '"' + (cAlsQry3)->F2_CLIENTE + '"'
			cJson 	+= "},"
			cJson	+= '"CNPJ_Vogel__c":'
			cJson	+= '"' + AllTrim(cCgcEmp) + '"'
			cJson 	+= ','
			cJson	+= '"Emissao__c":'
			cJson	+= '"' + (SUBSTR((cAlsQry3)->F2_EMISSAO,1,4) + "-" + SUBSTR((cAlsQry3)->F2_EMISSAO,5,2) + "-" + SUBSTR((cAlsQry3)->F2_EMISSAO,7,2)) + '"'
			cJson 	+= ',
			cJson	+= '"Vencimento__c":'
			cJson	+= '"' + cDtVenc + '",'
			cJson	+= '"Valor__c":'

			cQuery4 := " SELECT SUM(F2_VALBRUT) AS VALTOT
			cQuery4 += "   FROM " + RetSQLName("SF2") + " SF2 "
			cQuery4 += "  WHERE F2_XID    		= '" + Alltrim((cAlsQry)->PR1_CHAVE) + "' "
			cQuery4 += "    AND SF2.D_E_L_E_T_	= ' ' "
			
			If Select(cAlsQry4) > 0
				(cAlsQry4)->(DBCloseArea())
			Endif

			DBUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery4),cAlsQry4,.T.,.T.)

			cJson	+= cValToChar((cAlsQry4)->VALTOT)
			cJson 	+= ','
			
			For _nX := 1 To Len(aNFDPara)

				If aNFDPara[_nX][1] == "1"
					
					If (SUBSTR(aNFDPara[_nX][3],1,2) == "F2")
						cConteudo := & ("SF2->" + aNFDPara[_nX][3])
					Else
						cConteudo := & ("SC5->" + aNFDPara[_nX][3])
					EndIf

					If ValType(cConteudo) == "N"
						cJson += '"' + aNFDPara[_nX][2] + '":'
						cJson += cValTochar(cConteudo)
					Else
						cConteudo   := Alltrim(cConteudo)
						cJson       += '"' +aNFDPara[_nX][2] + '":'
						cJson       += '"' + cConteudo + '"'
					EndIf
				
				ElseIf aNFDPara[_nX][1] == "2"

					cConteudo := aNFDPara[_nX][4]

					If ValType(cConteudo) == "N"
						cJson += '"' + aNFDPara[_nX][2] + '":'
						cJson += cValTochar(cConteudo)
					Else
						cConteudo   := Alltrim(cConteudo)
						cJson       += '"' +aNFDPara[_nX][2] + '":'
						cJson       += '"' + cConteudo + '"'
					EndIf
				
				EndIf

				cJson += ','

			Next _nX

			cJson	+= '"Alias":'
			cJson	+= '"SF2"'
			cJson 	+= "},"
			
			U_MonitRes("000008", 2, , cIdPZB, "Registro enviado.", .T., "TRACKING", cJson, "", "", .F., .F.)

			(cAlsQry3)->(DBCloseArea())

		ElseIf AllTrim((cAlsQry)->PR1_ALIAS) == 'SE5'

			SE5->(DBGoTo((cAlsQry)->RECREG))

			SE1->(DBSeek(xFilial("SE1")+SE5->E5_PREFIXO+;
			SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO))

			cJson 	+= "{"
			cJson	+= '"Aglutinado__c:"'
			cJson	+= '"false"'
			cJson 	+= ','
			cJson	+= '"Bloqueado__c:"'
			cJson	+= '"false"'
			cJson 	+= ','
			cJson	+= '"CID_do_Cliente__c:"'
			cJson	+= '"' + (SE5->E5_CLIFOR + SE5->E5_LOJA) + '"'
			cJson 	+= ','
			cJson	+= '"Codigo_de_Barras__c:"'
			cJson	+= '"' + SE1->E1_CODBAR + '"'
			cJson 	+= ','
			cJson	+= '"Data_de_Emissao__c:"'
			cJson	+= '"' + DTOS(SE1->E1_EMISSAO) + '"'
			cJson 	+= ','
			cJson	+= '"Data_de_Vencimento__c:"'
			cJson	+= '"' + DTOS(SE1->E1_VENCTO) + '"'
			cJson 	+= ','
			cJson	+= '"Desconto__c:"'
			cJson	+= '"' + cValToChar(SE1->E1_DESCON1) + '"'
			cJson 	+= ','
			cJson	+= '"Filial_Protheus__c:"'
			cJson	+= '"' + SE1->E1_FILIAL + '"'
			cJson 	+= ','
			cJson	+= '"Juros__c:"'
			cJson	+= '"' + cValToChar(SE1->E1_JUROS) + '"'
			cJson 	+= ','
			cJson	+= '"Loja__c:"'
			cJson	+= '"' + SE1->E1_LOJA + '"'
			cJson 	+= ','
			cJson	+= '"Name:"'
			cJson	+= '"' + AllTrim(SE1->E1_NOMCLI) + '"'
			cJson 	+= ','
			cJson	+= '"Observacao_Geral__c:"'
			cJson	+= '"' + AllTrim(SE1->E1_HIST) + '"'
			cJson 	+= ','
			cJson	+= '"Parcela__c:"'
			cJson	+= '"' + SE5->E5_PARCELA + '"'
			cJson 	+= ','
			cJson	+= '"Pedido_Vogel__c:"'
			cJson	+= '"' + SE5->E5_NUMERO + '"'
			cJson 	+= ','
			cJson	+= '"Prefixo__c:"'
			cJson	+= '"' + SE5->E5_PREFIXO + '"'
			cJson 	+= ','
			cJson	+= '"Saldo_erm_Aberto__c:"'
			cJson	+= '"' + cValToChar(SE1->E1_SALDO) + '"'
			cJson 	+= ','
			cJson	+= '"Status_Titulo__c:"'
			cJson	+= '"' + SE1->E1_STATUS + '"'
			cJson 	+= ','
			cJson	+= '"Status__c:"'
			cJson	+= '"' + SE1->E1_STATUS + '"'
			cJson 	+= ','
			cJson	+= '"Tipo__c:"'
			cJson	+= '"' + SE5->E5_TIPO + '"'
			cJson 	+= ','
			cJson	+= '"Valor__c:"'
			cJson	+= '"' + cValToChar(SE5->E5_VALOR) + '"'
			cJson 	+= ','
			cJson	+= '"Vencimento_Real__c:"'
			cJson	+= '"' + DTOS(SE1->E1_VENCREA) + '"'
			cJson 	+= ','
			cJson	+= '"Alias:"'
			cJson	+= '"SE5"'
			cJson 	+= "},"

		EndIf

		(cAlsQry)->(DBSkip())

	EndDo

	cJson := Substr(cJson, 1, Rat(",", cJson) -1)	
	cJson += "]}"

	(cAlsQry)->(DBCloseArea())

	U_MonitRes("000008", 3, , cIdPZB, , .T.)

	::SetResponse( cJson )
	::SetContentType("application/json")

EndIf
*****************************************************************************
//Movimenta��o de Titulos - Parcial
cQuery := " SELECT TOP 100 R_E_C_N_O_ AS RECPR1, PR1_RECNO AS RECREG, PR1_ALIAS, PR1_CHAVE, PR1_TIPREQ "
cQuery += "	  FROM " + RETSQLNAME("PR1") + " PR1 "
cQuery += "	 WHERE PR1_FILIAL = '" + xFilial("PR1") + "' "
cQuery += "	   AND PR1_ALIAS IN ('SE1') "
cQuery += "	   AND PR1_STINT = 'P' AND PR1_TIPREQ = '1' "
cQuery += "	   AND D_E_L_E_T_ = ' ' "
cQuery += "	ORDER BY R_E_C_N_O_"

If Select(cAlsQry) > 0
	 (cAlsQry)->(DBCloseArea())
Endif

DBUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

If !(cAlsQry)->(EOF())

	nQtdReg := Contar(cAlsQry,"!EOF()")
	(cAlsQry)->(DBGoTop())

	cJson := "{"
	cJson += '"Registros":['

	While (cAlsQry)->(!EOF())

		cJson += '{'
		cJson += '"allOrNone":false,'
		cJson += '"records":['
		cJson += '{'
		cJson += '"attributes":{'
		cJson += '"type":"PedidoFaturamento__c"'
		cJson += '},'
		cJson += '"ReferenciaId__c":"' + Alltrim((cAlsQry)->PR1_CHAVE) + '",'
		cJson += '"Status_Protheus__c": "Baixado Parcialmente"'
		cJson += '}'
		cJson += ']'
		cJson += '},'

		(cAlsQry)->(DbSkip())

	End

	cJson := Substr(cJson, 1, Rat(",", cJson) -1)	
	cJson += "]}"

	(cAlsQry)->(DBCloseArea())

	U_MonitRes("000010", 3, , cIdPZB, , .T.)

	::SetResponse( cJson )
	::SetContentType("application/json")

	Return(.T.)

EndIf
*****************************************************************************
//Movimenta��o de Titulos - Total
cQuery := " SELECT TOP 100 R_E_C_N_O_ AS RECPR1, PR1_RECNO AS RECREG, PR1_ALIAS, PR1_CHAVE, PR1_TIPREQ "
cQuery += "	  FROM " + RETSQLNAME("PR1") + " PR1 "
cQuery += "	 WHERE PR1_FILIAL = '" + xFilial("PR1") + "' "
cQuery += "	   AND PR1_ALIAS IN ('SE1') "
cQuery += "	   AND PR1_STINT = 'P' AND PR1_TIPREQ = '2' "
cQuery += "	   AND D_E_L_E_T_ = ' ' "
cQuery += "	ORDER BY R_E_C_N_O_"

If Select(cAlsQry) > 0
	 (cAlsQry)->(DBCloseArea())
Endif

DBUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

If !(cAlsQry)->(EOF())

	nQtdReg := Contar(cAlsQry,"!EOF()")
	(cAlsQry)->(DBGoTop())
		
	cJson := "{"
	cJson += '"Registros":['

	While (cAlsQry)->(!EOF())

		cJson += '{'
		cJson += '"allOrNone":false,'
		cJson += '"records":['
		cJson += '{'
		cJson += '"attributes":{'
		cJson += '"type":"PedidoFaturamento__c"'
		cJson += '},'
		cJson += '"ReferenciaId__c":"' + Alltrim((cAlsQry)->PR1_CHAVE) + '",'
		cJson += '"Status_Protheus__c": "Baixado"'
		cJson += '}'
		cJson += ']'
		cJson += '},'

		(cAlsQry)->(DbSkip())

	End

	cJson := Substr(cJson, 1, Rat(",", cJson) -1)	
	cJson += "]}"

	(cAlsQry)->(DBCloseArea())

	U_MonitRes("000010", 3, , cIdPZB, , .T.)

	::SetResponse( cJson )
	::SetContentType("application/json")

	Return(.T.)

EndIf
*****************************************************************************
//Movimenta��o de Titulos - Cancelamentos de Baixa/Concilia��o etc.
cQuery := " SELECT TOP 100 R_E_C_N_O_ AS RECPR1, PR1_RECNO AS RECREG, PR1_ALIAS, PR1_CHAVE, PR1_TIPREQ "
cQuery += "	  FROM " + RETSQLNAME("PR1") + " PR1 "
cQuery += "	 WHERE PR1_FILIAL = '" + xFilial("PR1") + "' "
cQuery += "	   AND PR1_ALIAS IN ('SE1') "
cQuery += "	   AND PR1_STINT = 'P' AND PR1_TIPREQ = '3' "
cQuery += "	   AND D_E_L_E_T_ = ' ' "
cQuery += "	ORDER BY R_E_C_N_O_"

If Select(cAlsQry) > 0
	 (cAlsQry)->(DBCloseArea())
Endif

DBUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

If !(cAlsQry)->(EOF())

	nQtdReg := Contar(cAlsQry,"!EOF()")
	(cAlsQry)->(DBGoTop())
		
	cJson := "{"
	cJson += '"Registros":['

	While (cAlsQry)->(!EOF())

		cJson += '{'
		cJson += '"allOrNone":false,'
		cJson += '"records":['
		cJson += '{'
		cJson += '"attributes":{'
		cJson += '"type":"PedidoFaturamento__c"'
		cJson += '},'
		cJson += '"ReferenciaId__c":"' + Alltrim((cAlsQry)->PR1_CHAVE) + '",'
		cJson += '"Status_Protheus__c": "Em Aberto"'
		cJson += '}'
		cJson += ']'
		cJson += '},'

		(cAlsQry)->(DbSkip())

	End

	cJson := Substr(cJson, 1, Rat(",", cJson) -1)	
	cJson += "]}"

	(cAlsQry)->(DBCloseArea())

	U_MonitRes("000010", 3, , cIdPZB, , .T.)

	::SetResponse( cJson )
	::SetContentType("application/json")

	Return(.T.)

EndIf
*****************************************************************************
//Cancelamento
cQuery := " SELECT TOP 100 R_E_C_N_O_ AS RECPR1, PR1_RECNO AS RECREG, PR1_ALIAS, PR1_CHAVE, PR1_TIPREQ "
cQuery += "	  FROM " + RETSQLNAME("PR1") + " PR1 "
cQuery += "	 WHERE PR1_FILIAL = '" + xFilial("PR1") + "' "
cQuery += "	   AND PR1_ALIAS IN ('SF2') "
cQuery += "	   AND PR1_STINT = 'P' AND PR1_TIPREQ = '3' "
cQuery += "	   AND D_E_L_E_T_ = ' ' "
cQuery += "	ORDER BY R_E_C_N_O_"

If Select(cAlsQry) > 0
	 (cAlsQry)->(DBCloseArea())
Endif

DBUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

If (cAlsQry)->(EOF())

	cJson := "{" 
	cJson += '"errorMessage":"N�o existem registros.",'
	cJson += '"lret":false'
	cJson += "}"

	aCriaServ := U_MonitRes("000008", 1, nQtdReg)   
	cIdPZB 	  := aCriaServ[2]

	U_MonitRes("000008", 2, , cIdPZB, "Chave de Resgistro n�o encontrada.", .T., "TRACKING", cJson, "", "", .F., .F.)
	U_MonitRes("000008", 3, , cIdPZB, , .T.)

	::SetContentType("application/json")
	::SetResponse( cJson )

	Return .T.

Else
	
	cJson := "{"
	cJson += '"Registros":['

	While (cAlsQry)->(!EOF())

		cJson += '{'
		cJson += '"allOrNone":false,'
		cJson += '"records":['
		cJson += '{'
		cJson += '"attributes":{'
		cJson += '"type":"PedidoFaturamento__c"'
		cJson += '},'
		cJson += '"ReferenciaId__c":"' + Alltrim((cAlsQry)->PR1_CHAVE) + '",'
		cJson += '"Status_Protheus__c": "Cancelado"'
		cJson += '}'
		cJson += ']'
		cJson += '},'

		(cAlsQry)->(DbSkip())

	End

	cJson := Substr(cJson, 1, Rat(",", cJson) -1)	
	cJson += "]}"

	(cAlsQry)->(DBCloseArea())

	U_MonitRes("000008", 3, , cIdPZB, , .T.)

	::SetResponse( cJson )
	::SetContentType("application/json")

	Return(.T.)

EndIf

Return(.T.)

//Henrique
/*
Static Function CN300AddCrg(aPergunte)
Local aArea		:= GetArea()
Local oView		:= FWViewActive()
Local oModel	:= FWModelActive()
Local oModelCN9	:= oModel:GetModel("CN9MASTER")
Local oModelCNA := oModel:GetModel("CNADETAIL")
Local oModelCNF := oModel:GetModel("CNFDETAIL")

Local cAutom 	:= oModelCN9:GetValue("CN9_AUTO") //- 0: Default; 1: Vindo da AutomaÃ§Ã£o (RobÃ´)
Local cComp		:= ""
Local cCondPg	:= ""

Local nParcelas	:= 0
Local nPeriod	:= 0
Local nDias		:= 0
Local nCount	:= 0
Local nQuant	:= 0

Local lUltDia		:= .F.
Local lAgrupador:= .F.
Local lOk		:= .T.
Local lFisico	:= Cn300RetSt("FISICO")
Local lServico	:= Cn300RetSt("SERVIÃ‡O")
Local dDtPrev		:= CToD("")

Default aPergunte := {}

MtBCMod(oModel,{{'CNFDETAIL',{'CNF_VLPREV'}}},{||.T.},'2')
MtBCMod(oModel,{{'CNSDETAIL',{'CNS_PRVQTD'}}},{||.T.},'2')

lAgrupador := Cn300RetSt("SEMIAGRUP",0,oModelCNA:GETVALUE("CNA_NUMERO"))

If Cn300RetSt("SEMIAGRUP",0,oModelCNA:GETVALUE("CNA_NUMERO"))
	Aviso("STR0090","STR0221",{"STR0222"}) //- "OpÃ§Ã£o nÃ£o disponivel para o contrato ou planilha selecionada."
	lOk := .F.
EndIf

If Cn300RetSt("MEDEVE",0,oModelCNA:GETVALUE("CNA_NUMERO"))
	Aviso("STR0090","STR0087",{"STR0222"}) //-- Esta opÃ§Ã£o nÃ£o estÃ¡ disponÃ­vel para contratos de mediÃ§Ã£o eventual.
	lOk := .F.
EndIf

If Cn300RetSt("RECORRENTE",0,oModelCNA:GETVALUE("CNA_NUMERO"))
	Aviso("STR0090","STR0221",{"STR0222"}) //- "OpÃ§Ã£o nÃ£o disponivel para o contrato ou planilha selecionada."
	lOk := .F.
EndIf

If lOk .And. ((oModelCN9:GetValue("CN9_ESPCTR") == "1" .And. Empty(oModelCNA:GetValue("CNA_FORNEC"))) .Or.;
				(oModelCN9:GetValue("CN9_ESPCTR") == "2" .And. Empty(oModelCNA:GetValue("CNA_CLIENT"))))
	Aviso("STR0090","STR0050",{"STR0222"})	//-- Preencha os campos do cabeÃ§alho da planilha.
	lOk := .F.
EndIf

If lOk .And. oModelCNA:IsDeleted()
	Aviso("STR0090","STR0067",{"STR0222"})	//-- O cronograma nÃ£o pode ser incluÃ­do pois a planilha estÃ¡ deletada.
	lOk := .F.
EndIf

If lOk .And. (oModelCNA:GetValue("CNA_VLTOT") == 0 .And. !lServico)
	Help(" ",1,"CNTA300PLA")  //-- Insira um item na planilha
	lOk := .F.
EndIf

//-- Verifica se existe cronograma para a planilha
If lOk
	For nCount := 1 to oModelCNF:Length()
		oModelCNF:GoLine(nCount)

		If !oModelCNF:IsDeleted() .And. !Empty(oModelCNF:GetValue("CNF_COMPET"))
    		Aviso("STR0090","STR0068",{"STR0222"})	//-- Esta planilha jÃ¡ contÃ©m um cronograma associado.
    		lOk := .F.
	  		Exit
	  	EndIf
	Next nCount
EndIf

If lOK
	While lOk
		If !Empty(aPergunte) //Rotina Automatica
			nPeriod	  := aPergunte[1]
			nDias	  := aPergunte[2]
			lUltDia	  := aPergunte[3]
			cComp	  := aPergunte[4]
			dDtPrev	  := aPergunte[5]
			nParcelas := aPergunte[6]
			cCondPg	  := aPergunte[7]
		    lUltDiaSmp	:= aPergunte[1] == 1 .And. aPergunte[3]
		Else
			If (lOk := Iif( cAutom=="0", Pergunte("CN300CRG",.T.), Pergunte("CN300CRG",.F.) ))
				//-- Carrega as variaveis informadas no pergunte
				nPeriod		:= MV_PAR01
				nDias		:= MV_PAR02
				lUltDia		:= MV_PAR03 <> 2
				cComp		:= MV_PAR04
				dDtPrev		:= MV_PAR05
				nParcelas	:= MV_PAR06
				cCondPg		:= MV_PAR07
				lUltDiaSmp	:= MV_PAR01 == 1 .And. MV_PAR03 == 3
			EndIf
		EndIf

		If lOk .And. (lOK := CN300VldPar(nPeriod,nDias,lUltDia,cComp,@dDtPrev,nParcelas,cCondPg,lFisico,lUltDiaSmp))
			Exit
		EndIf
	EndDo

	//-- Inicio do processo de inserÃ§Ã£o de cronogramas
	If lOk
	   	If lServico
			If nPeriod == 4 
				If nParcelas > 0
					nQuant := nParcelas * Len(Condicao(1,cCondPg,dDtPrev))
				Else
					nQuant := Len(Condicao(1,cCondPg,dDtPrev))
				EndIf
			Else
				nQuant := nParcelas
			EndIf
			CN300ItSrv(1,nQuant)
		EndIf
		
		If !IsBlind()
			MsgRun("STR0083","STR0084",{|| CursorWait(), lOk := CN300MkCrg(oModel,nPeriod,nDias,lUltDia,cComp,dDtPrev,nParcelas,cCondPg,lFisico,lUltDiaSmp, lServico), CursorArrow()})
		Else
			lOk := CN300MkCrg(oModel,nPeriod,nDias,lUltDia,cComp,dDtPrev,nParcelas,cCondPg,lFisico,lUltDiaSmp, lServico)
		EndIf
		lDelCrg := .F.

		If lServico
			MtBCMod(oModel,{{'CNFDETAIL',{'CNF_VLPREV'}}},{||.T.},'2')
			MtBCMod(oModel,{{'CNSDETAIL',{'CNS_PRVQTD'}}},{||.F.},'2')
		EndIf
	EndIf
EndIf

Pergunte("CNT100",.F.) //-- Retorna pergunte
oModelCNF:GoLine(1)

If !(FunName() $ "TECA850|TECA870|TECA745|CRMA801") .And. Type('oView') == "O" .And. oView:IsActive() .And. cAutom == "0" //Foi necessÃ¡rio validaÃ§Ã£o para GestÃ£o de ServiÃ§os.
	oView:Refresh()
EndIf

RestArea(aArea)
Return lOk




Static Function CN300MkCrg(oModel,nPeriod,nDias,lUltDia,cComp,dDtPrev,nParcelas,cCondPg,lFisico,lUltDiaSmp,lServico)
Local aArea	   	:= GetArea()
Local oModelCN9	:= oModel:GetModel("CN9MASTER")
Local oModelCNA	:= oModel:GetModel("CNADETAIL")
Local oModelCNF	:= oModel:GetModel("CNFDETAIL")
Local oModelCNS	:= oModel:GetModel("CNSDETAIL")
Local oModelCCNF:= oModel:GetModel("CALC_CNF")

Local lCNAUpd	:= oModelCNA:CanUpdateLine()
Local lUpdCNF	:= .F.
Local lAjFim	:= .F.
Local lAjFev    := .F.
Local lAjFimC	:= .F.
Local lAjFevC   := .F.

Local aItens	:= CN300GetPIt()
Local aItCrgFis	:= CN300GetPIt()
Local aParcel  	:= {}
Local aCrgFis	:= {}
Local aParFis	:= {}
Local aCondComp	:= {}
Local aCondicao	:= {}
Local aRestCNS	:= {}
Local aDifCrg	:= {}

Local nMaxTip9	:= SuperGetMV("MV_NUMPARC",.F.,4)
Local nDiaIni   := If(lUltDiaSmp,31,Day(dDtPrev))
Local nVlrPlan	:= oModelCNA:GetValue("CNA_VLTOT")
Local nTamParc 	:= TamSx3("CNF_PARCEL")[1]
Local nTamPRVQTD:= TamSX3("CNS_PRVQTD")[2]
Local nDifDat	:= 0
Local nVlrParc	:= 0
Local nQtdePv	:= 0
Local nQtdPvR	:= 0
Local nNewLine	:= 0
Local nCount	:= 0
Local nFor		:= 0
Local nVlrReal	:= 0
Local nVlrSld	:= 0
Local nAvanco	:= 0
Local nX		:= 0
Local nI		:= 0
Local nPosComp	:= 0

Local cTipCondCt:= POSICIONE('SE4',1,xFilial('SE4')+oModelCN9:GetValue('CN9_CONDPG'),'E4_TIPO')
Local cNumCrg	:= GetSX8Num("CNF","CNF_NUMERO")
Local cNumParc	:= Replicate("0",nTamParc)
Local cRefer	:= ""
Local cCompet	:= ""
Local cMoeda	:= ""
Local cLog 		:= ""
Local cErrMoed	:= ""

Local dVencto	:= dDtPrev
Local dCompet	:= CToD("")

//ValidaÃ§Ã£o das parcelas
Local lVldVige 	:= GetNewPar("MV_CNFVIGE","N") == "N"
Local llRet		:= .T.
Local dData		:= CtoD("")
Local dInicio	:= CtoD("")
Local dFim		:= CtoD("")

//--Tratamento para tamanho de campo DescriÃ§Ã£o
Local nB1Des	:= TamSX3("B1_DESC")[1]
Local nCnsDes	:= TamSX3("CNS_DESCRI")[1]
Local cDescr	:= ''

//-- Verifica se utiliza ultimo dia do mes
If lUltDia
	lAjFim := .T.
	lAjFev := .T.
	lAjFimC:= .T.
	lAjFevC:= .T.
EndIf

//-- Verifica se utiliza condicao de pagamento 
If nPeriod == 4 .And. !Empty(cCondPg)
	//-- Verifica se a qtde de parcelas foi informada
	If nParcelas > 0
		nVlCompet	:= nVlrPlan / nParcelas
		dCompet		:= CtoD(Str(Day(dDtPrev))+"/"+cComp)
		nPosComp 	:= 3

		//-- Calcula a quantidade de parcelas
		For nCount := 1 to nParcelas
			aCondComp := Condicao(nVlCompet,cCondPg,,dCompet)

			For nFor := 1 to len(aCondComp)
				aAdd(aCondicao,{aCondComp[nFor,1],aCondComp[nFor,2],dCompet})
				
			Next nFor
				nAvanco	:= CalcAvanco(dCompet,.F.,.F.,nDiaIni)
				dCompet	+= nAvanco
			aCondComp 	:= {}
		Next nCount
	Else // senÃ£o a qtde de parcelas serÃ¡ de acordo com a condiÃ§Ã£o de pagamento
		nPosComp	:= 1
		aCondicao := Condicao(nVlrPlan,cCondPg,,dDtPrev)
	EndIf
	nParcelas := Len(aCondicao)
	If nTamParc == 1 .And. nParcelas > 35
		Help(" ",1,"CNTA300NPA")	//-- O tamanho do campo CNF_PARCEL nÃ£o permite a configuraÃ§Ã£o da quantidade de parcelas inserida.
		llRet := .F.
	ElseIf AllTrim(cTipCondCt) == '9' .And. nParcelas > nMaxTip9
		Help("",1,'CN300MAXPA',,"STR0279"+Str(nMaxTip9)+"STR0279" ,4,1) //-"A condiÃ§Ã£o de pagamento do contrato somente permite cronogramas com atÃ© ### parcela(s).
		llRet := .F.
	EndIf
EndIf

If llRet
	//-- Cria array de parcelas
	For nCount := 1 to nParcelas
		cNumParc := Soma1(cNumParc)
	
		//-- Divide valor total pelas parcelas
		If !Empty(aCondicao)
			dVencto	:= aCondicao[nCount,1]
			dCompet	:= aCondicao[nCount,nPosComp]
			nVlrParc:= aCondicao[nCount,2]
		ElseIf (nCount == 1)
			nVlrParc	:= NoRound(nVlrPlan,TAMSX3('CNA_VLTOT')[2])/nParcelas
			dCompet	:= CalcDiaCom(dDtPrev,cComp)
		Else
			//-- Calcula proxima data de vencto
			If nDias == 30 .And. nPeriod # 3
				nAvanco := CalcAvanco(dVencto,@lAjFim,@lAjFev,nDiaIni)
			Else
			    nAvanco := nDias
			EndIf
	
			dVencto += nAvanco
	
			//-- Calcula competencia
			dCompet := dVencto
		EndIf
	
		//-- Verifica referencia da parcela
		cRefer := StrZero(Month(dCompet),2)+"/"+str(Year(dCompet),4)
	
		//-- VerificaÃ§Ã£o do cronograma referenciando parcelas anteriores
		If Len(aParcel) .And. Empty(aCondicao)
			//-- Se Competencia igual competÃªncia anterior
			If aParcel[Len(aParcel),2] == cRefer
				If SubStr(cRefer,0,2) == "12" .And. Day(dCompet) <= Day(aParcel[Len(aParcel),4])
					cRefer := StrZero(Val(SubStr(cRefer,0,2))-11,2)+"/"+StrZero(Val(SubStr(cRefer,4))+1,4)
				EndIf
	
			//-- Se Competencia pulou mÃªs
			Else
				cCompet := SubStr(aParcel[Len(aParcel),2],0,2)
				cCompet := Iif(cCompet == "12","01",Soma1(cCompet))
				If cCompet != SubStr(cRefer,0,2)
					If SubStr(cRefer,0,2) == "01"
						nDifDat := 12-Val(cCompet)
						cRefer := StrZero(12-nDifDat,2) +"/"+ StrZero(Val(SubStr(cRefer,4))-1,4)
					ElseIf nDifDat > 0
						cRefer := cCompet+"/"+StrZero(Val(SubStr(cRefer,4))-1,4)
						nDifDat--
					Else
						cRefer := cCompet+"/"+SubStr(cRefer,4)
					EndIf
				EndIf
			EndIf
		EndIf
	
		//-- Calcula valor real da parcela e verifica o arrendondamento
		If !lFisico
			nVlrReal := Round(nVlrParc,TamSx3("CNF_VLPREV")[2])
		EndIf
	
		//-- Obtem moeda
		cMoeda := RecMoeda(dVencto,oModelCN9:GetValue("CN9_MOEDA") )
	
		If Empty(cMoeda)
			If Empty(cErrMoed)
				cErrMoed := "STR0140"+ Alltrim(Str(oModelCN9:GetValue("CN9_MOEDA"), TamSX3("CN9_MOEDA")[1]))+"."+chr(13)+chr(10)
				cErrMoed += "STR0141"+ Alltrim(Str(oModelCN9:GetValue("CN9_MOEDA"), TamSX3("CN9_MOEDA")[1]))+"STR0142"+chr(13)+chr(10)
				cErrMoed += DtoC(dVencto)
			Else
				cErrMoed += ", " + DtoC(dVencto)
			EndIf
		EndIf
	
		//-- Verifica se utiliza cronograma fisico
		//-- Adiciona parcela para todos os itens da planilha
		If lFisico
			For nFor := 1 to Len(aItCrgFis)
				If nFor > Len(aDifCrg)
					aAdd(aDifCrg,0)
				EndIf
				//Â³Verifica a quantidade prevista e desconto do item Â³
				nQtdePv := If(nCount < nParcelas,NoRound(aItens[nFor,3]/nParcelas,nTamPRVQTD),aItCrgFis[nFor,3])
				nQtdPvR	:= aItens[nFor,3]/nParcelas
				nDescon := NoRound(aItens[nFor,8]/nParcelas,nTamPRVQTD)
	
				//-- Atualiza valor da parcela de acordo com o cronograma fisico
				//-- (Valor unitario * qtde.) - desconto
				nVlrReal += Round((aItCrgFis[nFor,7] * nQtdePv) - nDescon,TamSx3("CNF_VLPREV")[2])
	
				//-- Atualiza a quantidade no array de itens
				aDifCrg[nFor] += nQtdPvR - nQtdePv
				If aDifCrg[nFor] > 1/10^nTamPRVQTD
					nQtdePv += NoRound(aDifCrg[nFor],nTamPRVQTD)
					aDifCrg[nFor] -= NoRound(aDifCrg[nFor],nTamPRVQTD)
				EndIf
				aItCrgFis[nFor,3] -= nQtdePv
	
				//-- Adiciona item no array de cronograma fisico
				aAdd(aParFis,{nQtdePv,aItens[nFor,3],aItens[nFor,2],aItens[nFor,1]})
			Next nFor
		EndIf
	
		//-- Adiciona informacoes no array de parcelas
		aAdd(aParcel,{cNumParc,cRefer,nVlrReal,dVencto,cMoeda})
	
		//-- Tratamento no resto do valor da parcela
		nVlrSld 	+= nVlrParc - nVlrReal
		nVlrReal	:= 0
	
		//-- Adiciona informacoes no array de parcelas
		If lFisico .And. !Empty(aParFis)
			aAdd(aCrgFis,aClone(aParFis))
			aParFis := {}
		EndIf
	Next nCount
EndIf

If !Empty(cErrMoed)
	cErrMoed += "."
	Aviso("STR0090", cErrMoed,{"STR0222"},3)
	llRet := .F.
EndIf

If llRet
	//-- Adiciona o saldo do arredondamento
	If !lFisico .And. nVlrSld # 0
	aParcel[Len(aParcel),3] += Round(nVlrSld,TAMSX3('CNF_VLPREV')[2])
	ElseIf lFisico
		//-- Ajusta parcelas do cronograma fisico
		CN300AjFis(@aParcel,@aCrgFis,aItCrgFis,nVlrPlan,nParcelas)
	EndIf

	If lServico
		oModelCNF:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,{||.T.})
		oModelCNF:SetNoUpdateLine(.F.)
	EndIf

	//-- Rotina para guardar o Recno dos registros deletados e deleta-los nos Commit do modelo, pois o Delete FÃ­sico nÃ£o deleta os
	//-- registros do banco.
	oModelCNF:GoLine(1)
	If oModelCNF:Length() > 0 .And. !Empty(oModelCNF:GetValue("CNF_PARCEL"))
		For nI := 1 To oModelCNF:Length()
			oModelCNF:GoLine(nI)
			If oModelCNF:IsDeleted()
				If oModelCNF:GetDataId() <> 0 .And. Ascan(aDelsCNF, oModelCNF:GetDataId()) == 0
					Aadd(aDelsCNF, oModelCNF:GetDataId())
				EndIf
			EndIf
			For nX := 1 To oModelCNS:Length()
				oModelCNS:GoLine(nX)
				If oModelCNS:IsDeleted()
					If oModelCNS:GetDataId() <> 0 .And. Ascan(aDelsCNS, oModelCNS:GetDataId()) == 0
						Aadd(aDelsCNS, oModelCNS:GetDataId())
					EndIf
				EndIf
			Next nX
		Next nI
	EndIf

	//ValidaÃ§ao das parcelas
	For nCount := 1 to len(aParcel)
		dInicio	:= oModelCN9:GetValue('CN9_DTINIC')
		dData	:= aParcel[nCount,4]
		dFim	:= oModelCN9:GetValue('CN9_DTFIM')

		If (dData < dInicio) .And. lVldVige
			Aviso("STR0090", "STR0132",{"STR0222"}) //"AtenÃ§Ã£o"##"O vencimento estÃ¡ menor do que a data inicial do contrato."
			llRet := .F.
			Exit
		EndIf

		If llRet .And. (dData > dFim) .And. lVldVige
			Aviso("STR0090", "STR0133",{"STR0222"}) //"AtenÃ§Ã£o"##"O vencimento estÃ¡ maior do que a data final do contrato."
			llRet := .F.
			Exit
		EndIf
	Next
EndIf

If llRet
	//-- Inclui as parcelas do cronograma financeiro
	If !oModelCNF:CanUpdateLine()
		oModelCNF:SetNoUpdateLine(.F.)
	EndIf

	For nCount := 1 to Len(aParcel)
		//-- Caso a linha nao esteja em branco, adiciona uma linha
		If !Empty(oModelCNF:GetValue("CNF_PARCEL"))
			oModelCNF:SetNoInsertLine(.F.)
			nNewLine := oModelCNF:AddLine()
			oModelCNF:GoLine( nNewLine )
			oModelCNF:SetNoInsertLine(.T.)
		EndIf

		//Libera CNF para carregar os valores
		lUpdCNF := oModelCNF:CanUpdateLine()

		If !lUpdCNF
			oModelCNF:SetNoUpdateLine(.F.)
		EndIf

		oModelCNF:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,{||.T.})

		oModelCNF:LoadValue("CNF_NUMERO",cNumCrg)
		oModelCNF:LoadValue("CNF_PARCEL",aParcel[nCount,1])
		oModelCNF:LoadValue("CNF_COMPET",aParcel[nCount,2])
		oModelCNF:SetValue("CNF_VLPREV",aParcel[nCount,3])
		oModelCNF:SetValue("CNF_VLREAL",0)
		oModelCNF:SetValue("CNF_SALDO",aParcel[nCount,3])
		oModelCNF:SetValue("CNF_DTVENC",aParcel[nCount,4])
		oModelCNF:SetValue("CNF_PRUMED",aParcel[nCount,4])
		oModelCNF:SetValue("CNF_TXMOED",aParcel[nCount,5])
		oModelCNF:SetValue("CNF_MAXPAR",nParcelas)
		If !( nPeriod == 4 )
			oModelCNF:SetValue("CNF_PERIOD",CValToChar(nPeriod))
			oModelCNF:SetValue("CNF_DIAPAR",nDias)
		Else
			oModelCNF:SetValue("CNF_CONDPG",cCondPg)
		EndIf

		//Devolve a CNF ao estado anterior
		oModelCNF:SetNoUpdateLine(!lUpdCNF)

		//-- Tratamento para remover da grid as linha deletadas
		If oModelCNF:GetLine() # nCount
			nFor := oModelCNF:GetLine()
			oModelCNF:LineShift(nCount,nFor)
			oModelCNF:GoLine(nFor)
			oModelCCNF:LoadValue('CNF_CALC',oModelCNF:GetValue('CNF_VLPREV'))
			oModelCNF:DeleteLine(.T.,.T.)
			oModelCNF:GoLine(nCount)
		EndIf

		If !Empty(oModel:GetErrorMessage()[6])
			llRet := .F.
		    cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
		    cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
		    cLog += cValToChar(oModel:GetErrorMessage()[6])
		    Help( ,,"ERRO",,cLog, 1, 0 )
		EndIf

		//-- Inclui as parcelas do cronograma fisico
		If lFisico .And. !Empty(aCrgFis)
			oModel:GetModel("CALC_CNS"):LoadValue("TCNS_PARC",aParcel[nCount,1])

			For nFor := 1 to Len(aCrgFis[nCount])
				//-- Caso a linha nao esteja em branco, adiciona uma linha
				If !Empty(oModelCNS:GetValue("CNS_ITEM"))
					oModelCNS:SetNoInsertLine(.F.)
					nNewLine := oModelCNS:AddLine()
					oModelCNS:GoLine( nNewLine )
					oModelCNS:SetNoInsertLine(.T.)
				EndIf

				//-- Tratamento para tamanho de campo descricao divergente
				cDescr := IIF (nB1Des > nCnsDes,Substr(Posicione("SB1",1,xFilial("SB1")+aCrgFis[nCount,nFor,3],"B1_DESC"),1,25),;
					            Posicione("SB1",1,xFilial("SB1")+aCrgFis[nCount,nFor,3],"B1_DESC"))
				aRestCNS := GetPropMdl(oModelCNS)
				Cnta300BlMd(oModelCNS,.F.)
				oModelCNS:SetValue("CNS_PARCEL",aParcel[nCount,1])
				oModelCNS:LoadValue("CNS_ITEM",aCrgFis[nCount,nFor,4])
				oModelCNS:SetValue("CNS_PRODUT",aCrgFis[nCount,nFor,3])
				oModelCNS:SetValue("CNS_DESCRI",cDescr)
				oModelCNS:SetValue("CNS_DISTSL",aCrgFis[nCount,nFor,1])
				oModelCNS:SetValue("CNS_PRVQTD",aCrgFis[nCount,nFor,1])
				oModelCNS:SetValue("CNS_RLZQTD",0)
				oModelCNS:LoadValue("CNS_SLDQTD",aCrgFis[nCount,nFor,1])
				oModelCNS:SetValue("CNS_TOTQTD",aCrgFis[nCount,nFor,2])
				oModelCNS:SetValue("CNS_ITOR","")
				RstPropMdl(oModelCNS,aRestCNS)
			Next nFor
		EndIf
	Next nCount

	oModelCNF:GetStruct():SetProperty('*',MVC_VIEW_CANCHANGE,.F.)
	oModelCNF:GetStruct():SetProperty('CNF_VLPREV',MODEL_FIELD_WHEN,{||!lFisico})
	oModelCNF:GetStruct():SetProperty('CNF_COMPET',MVC_VIEW_CANCHANGE,.T.)
	oModelCNF:GetStruct():SetProperty('CNF_DTVENC',MVC_VIEW_CANCHANGE,.T.)
	oModelCNF:GetStruct():SetProperty('CNF_PRUMED',MVC_VIEW_CANCHANGE,.T.)
	oModelCNF:GetStruct():SetProperty('CNF_TXMOED',MVC_VIEW_CANCHANGE,.T.)

EndIf

//-- Tratamento para remover linhas deletadas da tela
If llRet
	oModelCNF:SetNoDeleteLine(.F.)
	While oModelCNF:IsDeleted(oModelCNF:Length())
		oModelCNF:GoLine(oModelCNF:Length())
		oModelCCNF:LoadValue('CNF_CALC',oModelCNF:GetValue('CNF_VLPREV'))
		oModelCNF:DeleteLine(.T.,.T.)
	End
	oModelCNF:SetNoDeleteLine(.T.)

	//-- Atualiza a planilha com o cronograma
	oModelCNA:SetNoUpdateLine(.F.)
	oModelCNA:SetValue("CNA_CRONOG"	,oModelCNF:GetValue("CNF_NUMERO"))
	oModelCNA:SetNoUpdateLine(!lCNAUpd)
EndIf
RestArea(aArea)
Return llRet



Static Function CN300GetPIt()
Local aArea		:= GetArea()
Local aItens		:= {}
Local nFor			:= 0
Local oModel		:= FWModelActive()
Local oModelCNB 	:= oModel:GetModel("CNBDETAIL")
Local oModelCXM 	:= oModel:GetModel("CXMDETAIL")
Local lAgrupador  := Cn300RetSt("SEMIAGRUP")
Local aSaveLines	:= FWSaveRows()

//-- Verifica se a planilha contem itens
if lAgrupador
	For nFor := 1 To oModelCXM:Length()
		oModelCXM:GoLine(nFor)
		If !Empty(oModelCXM:GetValue("CXM_ITEMID")) .And. !(oModelCXM:IsDeleted())
			//-- Adiciona itens no array de retorno.
			aAdd(aItens,{ oModelCXM:GetValue("CXM_ITEMID"),;				// 1. Item do Agrupador
						  Iif(!Empty(oModelCXM:GetValue("CXM_AGRTIP")),;	// 2. cÃ³digo do agrupador (verificar qual dos campos estÃ¡ preenchido:
								oModelCXM:GetValue("CXM_AGRTIP"),;      	// Tipo,Grupo ou Categoria de Produto)
						  Iif(!Empty(oModelCXM:GetValue("CXM_AGRGRP")),;
							oModelCXM:GetValue("CXM_AGRGRP"),;
							oModelCXM:GetValue("CXM_AGRCAT"))),;
							0	,;											// 3. Manter zero, pois, nÃ£o existirÃ¡ Cronog. FÃ­sico, logo nÃ£o tem qtde
							''	,;											// 4. Manter vazio, nÃ£o exisitirÃ¡ SC
							''	,;											// 5. Manter vazio, nÃ£o exisitirÃ¡ SC
							oModelCXM:nLine						,;			// 6. Num. da linha do item
							oModelCXM:GetValue("CXM_VLMAX")	,;				// 7. Valor MÃ¡ximo
							0	} )											// 8. Manter zero, nÃ£o haverÃ¡ campo desconto na Entidade
		EndIf
	Next nFor
Else
For nFor := 1 To oModelCNB:Length()
	oModelCNB:GoLine(nFor)
	If !Empty(oModelCNB:GetValue("CNB_PRODUT")) .And. !(oModelCNB:IsDeleted())
		//-- Adiciona itens no array de retorno.
		aAdd(aItens,{ oModelCNB:GetValue("CNB_ITEM")		,;		// 1. Item da planilha
						oModelCNB:GetValue("CNB_PRODUT")	,;		// 2. Cod. Produto
						oModelCNB:GetValue("CNB_QUANT")		,;		// 3. Quantidade
						oModelCNB:GetValue("CNB_NUMSC")		,;		// 4. Num. Solic. Compra
						oModelCNB:GetValue("CNB_ITEMSC")	,;		// 5. Item Solic. Compra
						oModelCNB:nLine						,;		// 6. Num. da linha do item
						oModelCNB:GetValue("CNB_VLUNIT")	,;		// 7. Valor unitario
						oModelCNB:GetValue("CNB_VLDESC")	,;		// 8. Valor do desconto
						oModelCNB:GetValue("CNB_ATIVO")	} )			// 9. Item de contrato recorrente ativo/inativo
	EndIf
Next nFor
EndIf

FWRestRows(aSaveLines)
RestArea(aArea)
Return aItens




Static Function CN300VldPar(nPeriod,nDias,lUltDia,cComp,dDtPrev,nParcelas,cCondPg,lFisico,lUltDiaSmp)
Local oModel		:= FWModelActive()

Local oModelCNA		:= oModel:GetModel("CNADETAIL")

Local lVldVige   	:= GetNewPar("MV_CNFVIGE","N") == "N"
Local lRet	  		:= .T.

Local dFimCrono		:= CtoD("")

Local nMaxTip9		:= SuperGetMV("MV_NUMPARC",.F.,4)
Local nTamParc 		:= TamSx3("CNF_PARCEL")[1]
Local nCount		:= 0
Local nDiaIni    	:= 0
Local nAvanco		:= 0
Local nMes			:= 0
Local nDia			:= 0

Local cTipCondCt	:= POSICIONE('SE4',1,xFilial('SE4')+oModel:GetValue('CN9MASTER','CN9_CONDPG'),'E4_TIPO')

// Ajusta data prevista para o ultimo dia do mÃªs
If lRet .And. lUltDiaSmp
	nDia	:= day(dDtPrev)
	nMes	:= month(dDtPrev)
	dDtPrev += If(nDia<28, 28-nDia, 0)
	While nMes == month(dDtPrev)
		dDtPrev++
	End
	dDtPrev--
EndIf

//-- Valida campos nao preenchidos

If Alltrim(cComp) == "/"
	Help(" ",1,"CNTA300COMP",,"STR0131",5,0) //Preencha o inicio da competencia
	lRet := .F.
EndIf

If !(nPeriod == 4)
	lVazio := Empty(nDias) .Or.	Empty(cComp) .Or. Empty(dDtPrev) .Or. Empty(nParcelas)
Else
	lVazio := Empty(cCondPg)
EndIf

If lVazio
	Help(" ",1,"CNTA300CAM") //-- Preencha todos os campos.
	lRet := .F.
EndIf

If lRet .And. dDtPrev < CToD("01/"+cComp)
	Help(" ",1,"CNTA300PRE") //-- A data de previsÃ£o deve ser maior que a competÃªncia de inÃ­cio.
	lRet := .F.
EndIf

//-- Validacao para condicao de pagamento
If lRet .And. (nPeriod == 4) .And. Posicione("SE4",1,xFilial("SE4")+AllTrim(cCondPg),"E4_TIPO") == "9"
	Help(" ",1,"CN300CDPG") //-- Tipo da condiÃ§Ã£o de pagamento invÃ¡lido.
	lRet := .F.
EndIf

//-- Valida numero de parcelas
If lRet 
	If (nTamParc == 1 .And. nParcelas > 35)
		Help(" ",1,"CNTA300NPA")	//-- O tamanho do campo CNF_PARCEL nÃ£o permite a configuraÃ§Ã£o da quantidade de parcelas inserida.
		lRet := .F.
	Else
		If AllTrim(cTipCondCt) == '9' .And. nParcelas > nMaxTip9
			lRet := .F.
			Help("",1,'CN300MAXPA',,"STR0279"+Str(nMaxTip9)+"STR0279" ,4,1) //-"A condiÃ§Ã£o de pagamento do contrato somente permite cronogramas com atÃ© ### parcela(s).
		EndIf
	EndIf
EndIf

//-- Valida data prevista
If lRet .And. lVldVige .And. (dDtPrev < oModelCNA:GetValue("CNA_DTINI") .Or. dDtPrev > oModelCNA:GetValue("CNA_DTFIM"))
	Help(" ",1,"CNTA300DAT") //-- Data da primeira mediÃ§Ã£o invÃ¡lida.
	lRet := .F.
EndIf

//-- Calcula data final do cronograma
If lRet
	nDiaIni := If(lUltDiaSmp,31,Day(dDtPrev))
	dFimCrono := dDtPrev

	For nCount := 1 to (nParcelas-1)
		If nDias == 30 .And. nPeriod # 3
			nAvanco := CalcAvanco(dFimCrono,lUltDia,.F.,nDiaIni)
		Else
			nAvanco := nDias
		EndIf
		dFimCrono += nAvanco
	Next nCount

	//-- Verifica data final do cronograma x data final da planilha
	If lVldVige .And. dFimCrono > oModelCNA:GetValue("CNA_DTFIM")
		Help(" ",1,"CNTA300ULT") //-- A quantidade de parcelas Ã© invÃ¡lida pois ultrapassou a data final do contrato
		lRet := .F.
	EndIf
EndIf

Return lRet
*/

User Function CN300VldFor(cAction,cField,xValue,xOldValue)
Local cCodigo	:= ""
Local cLoja		:= ""
Local lRet	   	:= .T.
Local nPlan		:= 0
Local oModel	:= FWModelActive()
Local oModelCN9	:= oModel:GetModel("CN9MASTER")
Local oModelCNA := oModel:GetModel("CNADETAIL")
Local oModelCNC	:= oModel:GetModel("CNCDETAIL")
Local oModelCN8	:= oModel:GetModel("CN8DETAIL")
Local aSaveLines:= FWSaveRows()
Local cCpoCodi	:= If(oModelCN9:GetValue("CN9_ESPCTR")=="1","CNA_FORNEC","CNA_CLIENT")
Local cCpoLoja	:= If(oModelCN9:GetValue("CN9_ESPCTR")=="1","CNA_LJFORN","CNA_LOJACL")
Local cCpoCodCNC:= If(oModelCN9:GetValue("CN9_ESPCTR")=="1","CNC_CODIGO","CNC_CLIENT")
Local cCpoLojCNC:= If(oModelCN9:GetValue("CN9_ESPCTR")=="1","CNC_LOJA","CNC_LOJACL")
Local cCpoCodCN8:= If(oModelCN9:GetValue("CN9_ESPCTR")=="1","CN8_FORNEC","CN8_CLIENT")
Local cCpoLojCN8:= If(oModelCN9:GetValue("CN9_ESPCTR")=="1","CN8_LOJA","CN8_LOJACL")
Local cCodValue	:= IIF(cField == cCpoCodCNC,xOldValue,oModelCNC:GetValue(cCpoCodCNC))
Local cLojValue	:= IIF(cField == cCpoLojCNC,xOldValue,oModelCNC:GetValue(cCpoLojCNC))

If cAction == "DELETE"
	cCodigo := oModelCNC:GetValue(If(oModelCN9:GetValue("CN9_ESPCTR") == "1","CNC_CODIGO","CNC_CLIENT"))
	cLoja := oModelCNC:GetValue(If(oModelCN9:GetValue("CN9_ESPCTR") == "1","CNC_LOJA","CNC_LOJACL"))

	//-- Verifica se pode deletar o fornecedor
	If !Empty(cCodigo) .And. ! Empty(cLoja)
		For nPlan := 1 to oModelCNA:Length()
			oModelCNA:GoLine(nPlan)
			If MTFindMVC(oModelCNA,{{cCpoCodi,cCodigo},{cCpoLoja,cLoja}}) > 0 .And.; //-- Usado em planilha
			 			MTFindMVC(oModelCNC,{{cCpoCodCNC,cCodigo},{cCpoLojCNC,cLoja}}) == oModelCNC:GetLine()
	   			Help(" ",1,If(oModelCN9:GetValue("CN9_ESPCTR")=="1","CNTA300FRN","CNTA300CLI")) //-- O # nao pode ser deletado pois pertence a uma planilha.
		   		lRet := .F.
		   		Exit
			EndIf
		Next nPlan
		For nPlan := 1 to oModelCN8:Length()
			oModelCN8:GoLine(nPlan)
			If MTFindMVC(oModelCN8,{{cCpoCodCN8,cCodigo},{cCpoLojCN8,cLoja}}) > 0 // Usado na cau��o
		   		Help(" ",1,"CNTA300CAU") //-- "O Fornecedor/Cliente n�o pode ser alterado, pois, existe uma cau��o relacionada. Realize as corre��es no Cadastro de Cau��es"
		   		lRet := .F.
		   		Exit
			EndIf
		Next nPlan
	EndIf
EndIf

//Verifica se existe cau��o para o fornecedor e n�o permite a troca
If cAction == 'SETVALUE' .And. !Empty(xOldValue) .And. cField == cCpoCodCNC .Or. cField == cCpoLojCNC
	If MTFindMVC(oModelCN8,{{cCpoCodCN8,cCodValue},{cCpoLojCN8,cLojValue}}) > 0
		Help(" ",1,"CNTA300CAU") //-- "O Fornecedor/Cliente n�o pode ser alterado, pois, existe uma cau��o relacionada. Realize as corre��es no Cadastro de Cau��es"
	   	lRet := .F.
	EndIf
EndIf

If cAction == 'CANSETVALUE' .And. !Empty(xOldValue) .And. (cField == cCpoCodCNC .Or. cField == cCpoLojCNC)
	If cField == cCpoCodCNC
		cCodigo := xOldValue
		cLoja := oModelCNC:GetValue(If(oModelCN9:GetValue("CN9_ESPCTR") == "1","CNC_LOJA","CNC_LOJACL"))
	Else
		cCodigo := oModelCNC:GetValue(If(oModelCN9:GetValue("CN9_ESPCTR") == "1","CNC_CODIGO","CNC_CLIENT"))
		cLoja	:= xOldValue
	EndIf

	//-- Verifica se pode alterar o fornecedor/cliente
	For nPlan := 1 to oModelCNA:Length()
		oModelCNA:GoLine(nPlan)
		If 	MTFindMVC(oModelCNA,{{cCpoCodi,cCodigo},{cCpoLoja,cLoja}}) > 0 .And.;
			MTFindMVC(oModelCNC,{{cCpoCodCNC,cCodigo},{cCpoLojCNC,cLoja}}) == oModelCNC:GetLine()
			If oModelCN9:GetValue("CN9_ESPCTR") == "1"
				Alert("STR0137"+"STR0139")
			Else
				Alert("STR0138"+"STR0139")
			EndIf
		   	lRet := .F.
		   	Exit
		EndIf
	Next nPlan
EndIf

FWRestRows(aSaveLines)
Return lRet
