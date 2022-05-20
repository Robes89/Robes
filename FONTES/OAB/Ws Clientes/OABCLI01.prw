#Include "Totvs.Ch"
#Include "RESTFUL.Ch"
#INCLUDE "XMLXFUN.CH"

//\\Srv-app-ws\e$\TOTVS\Microsiga\Protheus12\HML\bin\WS_APPS_01
WsRestFul PostCli Description "Método responsavel pela inclusão/alteração de clientes"

WsData cCgcEmp		As String

WsMethod Post Description "Inclusão/alteração de clientes" WsSyntax "/PostCli"

End WsRestFul

WsMethod Post WsReceive cCgcEmp WsService PostCli

	Local cBody     := ::GetContent()
	Local oJsoAux   := Nil
	Local cQuery    := ""
	Local oLoc		:= Nil
	Local cLoc		:= ""
	Local cAlsQry   := GetNextAlias() //CriaTrab(Nil,.F.)
	Local nX
	Local cStrErro  := ""
	Local aDados    := {}
	Local aCriaServ := {}
	Local nErro     := 0
	Local cJson     := ""
	Local cCgcEmp   := IIf(::cCgcEmp <> Nil , ::cCgcEmp , "")
	Local aEmpresas := FwLoadSM0()
	Local cEnt		:= ''
	Local ntpExec   := 3
	Local cCgcCli     := ''
	Local cMensagem  := ''
	Local cMenssagem  := "Post clientes"
	//Local lRollback := .F.
	//Local cBackA1Id := ""
	//Local cBackA1Lj := ""
	//Local cBlocA1Id := ""
	//Local cBlocA1Lj := ""
	
	/**************************************************
	* for�a a grava��o das informa��es de erro em 	*
	* array para manipula��o da grava��o ao inv�s 	*
	* de gravar direto no arquivo tempor�rio		*
	**************************************************/
	Private lMsHelpAuto	:= .T.

	/**************************************************
	* for�a a grava��o das informa��es de erro em 	*
	* array para manipula��o da grava��o ao inv�s 	*
	* de gravar direto no arquivo tempor�rio 		*
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
	

		RpcSetEnv("01","01")
	EndIf

	FWJsonDeserialize(cBody, @oJsoAux)

	SM0->(DbSetOrder(1))

	cQuery := " SELECT PR3.* FROM " + RetSqlName("PR3") + " (NOLOCK) PR3 "
	cQuery += " INNER JOIN " + RetSqlName("PR2") + " (NOLOCK) PR2 "
	cQuery += " ON PR3_FILIAL = PR2_FILIAL AND PR3_CODIGO = PR2_CODIGO "
	cQuery += " WHERE PR2_CODPZA = '000001' AND PR2.D_E_L_E_T_ = ' '  AND PR3.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	If len(oJsoAux:Clientes) > 0

		cJson := "{"
		//Cria servi�o no montitor
		aCriaServ := U_MonitRes("000001", 1, Len(oJsoAux:Clientes) )   
		cIdPZB 	  := aCriaServ[2]

		For nX := 1 to len(oJsoAux:Clientes)
			cMensagem := ''
			(cAlsQry)->(DbGoTop())
			aDados      := {}
			cCgcCli := oJsoAux:Clientes[nX]:A1_CGC               
			DBSelectArea("SA1")
			SA1->(DBSetOrder(3))	
			SA1->(DbGoTop())
			If SA1->(DBSeek(xFilial("SA1") + cCgcCli))
					SA1->(DbSetOrder(1))
					SA1->(DbGoTop())
					if SA1->(DbSeek(xFilial('SA1')+Alltrim(oJsoAux:Clientes[nX]:A1_COD)+Alltrim(oJsoAux:Clientes[nX]:A1_LOJA)))
						ntpExec := 4
						if RecLock("SA1",.F.)
							SA1->A1_MSBLQL  := '2' // 1= SIM/ BSRANCO OU 2 =NAO
							SA1->A1_CGC     := oJsoAux:Clientes[nX]:A1_CGC
							SA1->(MsUnlock())
						Endif
						cMensagem := "Registro alterado " + SA1->A1_COD + '-'+SA1->A1_LOJA
					else
						ntpExec := 3
						cMensagem := "Registro incluido " + oJsoAux:Clientes[nX]:A1_COD + '-' + oJsoAux:Clientes[nX]:A1_LOJA
					Endif	
				/*If Alltrim(oJsoAux:Clientes[nX]:A1_LOJA) == "21" .And. Alltrim(SA1->A1_LOJA) != "21"
					lRollback := .T.
					cBackA1Id := SA1->A1_COD
					cBackA1Lj := SA1->A1_LOJA
					cBlocA1Id := oJsoAux:Clientes[nX]:A1_COD
					cBlocA1Lj := Alltrim(oJsoAux:Clientes[nX]:A1_LOJA)
					ntpExec := 3 // Inclusão
					cMensagem := "Registro " + SA1->A1_COD + '-'+SA1->A1_LOJA + " [Ativo]. Incluido novo registro " + oJsoAux:Clientes[nX]:A1_COD + '-' + oJsoAux:Clientes[nX]:A1_LOJA + " [Bloqueado]"
					if RecLock("SA1",.F.)
						SA1->A1_CGC := ''
						SA1->A1_MSBLQL  := '1' // 1= SIM/ BSRANCO OU 2 =NAO
						SA1->(MsUnlock())
					Endif
					SA1->(DbSetOrder(1))
					SA1->(DbGoTop())
					if SA1->(DbSeek(xFilial('SA1')+Alltrim(oJsoAux:Clientes[nX]:A1_COD)+Alltrim(oJsoAux:Clientes[nX]:A1_LOJA)))
						ntpExec := 4
						cMensagem := "Registro alterado " + SA1->A1_COD + '-'+SA1->A1_LOJA
					Endif	
				elseif Alltrim(oJsoAux:Clientes[nX]:A1_LOJA) != "21" .And. Alltrim(SA1->A1_LOJA) == "21"
					if RecLock("SA1",.F.)
						SA1->A1_CGC := ''
						SA1->A1_MSBLQL  := '1' // 1= SIM/ BSRANCO OU 2 =NAO
						SA1->A1_XCODOAB := oJsoAux:Clientes[nX]:A1_COD
						SA1->A1_XTPOAB  := oJsoAux:Clientes[nX]:A1_LOJA
						SA1->(MsUnlock())
					Endif					
					ntpExec := 3 // Inclusão
					cMensagem := "Registro antigo alterado " + SA1->A1_COD + '-'+SA1->A1_LOJA + " Incluido novo registro " + oJsoAux:Clientes[nX]:A1_COD + '-' + oJsoAux:Clientes[nX]:A1_LOJA	
					SA1->(DbSetOrder(1))
					SA1->(DbGoTop())
					if SA1->(DbSeek(xFilial('SA1')+Alltrim(oJsoAux:Clientes[nX]:A1_COD)+Alltrim(oJsoAux:Clientes[nX]:A1_LOJA)))
						ntpExec := 4
						cMensagem := "Registro antigo alterado " + SA1->A1_COD + '-'+SA1->A1_LOJA + " Incluido novo registro " + oJsoAux:Clientes[nX]:A1_COD + '-' + oJsoAux:Clientes[nX]:A1_LOJA				
					Endif									
				Else
					If Alltrim(oJsoAux:Clientes[nX]:A1_COD) == Alltrim(SA1->A1_COD) .AND. Alltrim(oJsoAux:Clientes[nX]:A1_LOJA) == Alltrim(SA1->A1_LOJA)//Alteração Normal
						ntpExec := 4
						cMensagem := "Registro antigo alterado " + SA1->A1_COD + '-'+SA1->A1_LOJA + " Incluido novo registro " + oJsoAux:Clientes[nX]:A1_COD + '-' + oJsoAux:Clientes[nX]:A1_LOJA
					Else
						//Altero o registro antigo
						if RecLock("SA1",.F.)
							SA1->A1_XATINAT := 'N'
							SA1->A1_CGC 	:= '' //Iif(SA1->A1_XATINAT == "S",SA1->A1_CGC,'')
							SA1->A1_MSBLQL  := '1' // 1= SIM/ BSRANCO OU 2 =NAO
							SA1->A1_XCODOAB := oJsoAux:Clientes[nX]:A1_COD
							SA1->A1_XTPOAB  := oJsoAux:Clientes[nX]:A1_LOJA
							//A1__ATINAT N
							MsUnlock()
						Endif
						// Inclusão do novo
						ntpExec := 3
						cMensagem := "Registro antigo alterado " + SA1->A1_COD + '-'+SA1->A1_LOJA + " Incluido novo registro " + oJsoAux:Clientes[nX]:A1_COD + '-' + oJsoAux:Clientes[nX]:A1_LOJA
						SA1->(DbSetOrder(1))
						SA1->(DbGoTop())
						if SA1->(DbSeek(xFilial('SA1')+Alltrim(oJsoAux:Clientes[nX]:A1_COD)+Alltrim(oJsoAux:Clientes[nX]:A1_LOJA)))
							if RecLock("SA1",.F.)
								SA1->A1_MSBLQL  := '2' // 1= SIM/ BSRANCO OU 2 =NAO
								SA1->A1_CGC     := oJsoAux:Clientes[nX]:A1_CGC
								SA1->(MsUnlock())
							Endif
							ntpExec := 4 // Alteracao
							cMensagem := 'Alteracao ' + oJsoAux:Clientes[nX]:A1_COD
							U_MonitRes("000001", 2, , cIdPZB, cMenssagem, .T., cMensagem, "", cBody, "", .F., .F.)
							//Finaliza o processo na PZB
							U_MonitRes("000001", 3, , cIdPZB, , .T.)
							cJson += '"clientes":['
							cJson += "{" 
							cJson += '"Mensagem' + '":"' + cMensagem + '",'
							cJson += '"lret' + cValTochar(nX) + '":true'
							cJson += "},"
							Loop			
						Endif
					Endif 
				Endif
				*/
			Else	
				ntpExec := 3 // Inclusão
				cMensagem := "Registro incluido " + oJsoAux:Clientes[nX]:A1_COD + '-' + oJsoAux:Clientes[nX]:A1_LOJA
				SA1->(DbSetOrder(1))
				SA1->(DbGoTop())
				if SA1->(DbSeek(xFilial('SA1')+Alltrim(oJsoAux:Clientes[nX]:A1_COD)+Alltrim(oJsoAux:Clientes[nX]:A1_LOJA)))
					if RecLock("SA1",.F.)
						SA1->A1_MSBLQL  := '2' // 1= SIM/ BSRANCO OU 2 =NAO
						SA1->A1_CGC     := oJsoAux:Clientes[nX]:A1_CGC
						SA1->(MsUnlock())
					Endif
					ntpExec := 4 // Alteracao
					cMensagem := "Registro alterado " + SA1->A1_COD + '-'+SA1->A1_LOJA
					U_MonitRes("000001", 2, , cIdPZB, cMenssagem, .T., cMensagem, "", cBody, "", .F., .F.)
					//Finaliza o processo na PZB
					U_MonitRes("000001", 3, , cIdPZB, , .T.)
					cJson += '"clientes":['
					cJson += "{" 
					cJson += '"Mensagem":"' + cMensagem + '",'
					cJson += '"lret' + cValTochar(nX) + '":true'
					cJson += "},"
					Loop			
				Endif
			EndIf

			While !(cAlsQry)->(Eof())
				cCpo        := Alltrim((cAlsQry)->PR3_CPOORI)
				If (cAlsQry)->PR3_TPCONT == "1"
					cConteudo := &("oJsoAux:Clientes[" + cValTochar(nX) + "]:" + cCpo)  
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
					FWJsonDeserialize(cBody, @oJsoAux)
				EndIf 
				If UPPER(AllTrim(cCpo)) == 'A1_XDTINSC' .oR.  UPPER(AllTrim(cCpo)) == 'A1_DTNASC'
						cConteudo := StoD(cConteudo)
				EndIf
				//If UPPER(AllTrim(cCpo)) == 'A1_COD' 
				//		cConteudo := StoD(cConteudo)
				//EndIf
				aAdd(aDados, {Alltrim((cAlsQry)->PR3_CPODES), cConteudo, nil})
				/*If UPPER(AllTrim(cCpo)) == 'A1_LOJA'
					if cConteudo == "21"
						aAdd(aDados, {"A1_MSBLQL", "2", nil})
					Endif
				Endif*/
				(cAlsQry)->(DbSkip())
			End

			//aDados := FWVetByDic(aDados,"SA1",.F.) //Organiza o array
			MSExecAuto({|x,y| Mata030(x,y)},aDados,ntpExec)
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
				U_MonitRes("000001", 2, , cIdPZB, cMenssagem, .F., cStrErro, "", cBody, "", .F., .F.)
				//Finaliza o processo na PZB
				U_MonitRes("000001", 3, , cIdPZB, , .F.)
				cJson += '"clientes":['
				cJson += "{" 
				cJson += '"Mensagem' + '":"' + cStrErro + '",'
				cJson += '"lret' + cValTochar(nX) + '":false'
				cJson += "},"
			Else
				ConfirmSx8()
				U_MonitRes("000001", 2, , cIdPZB, cMenssagem, .T., "Cliente incluso com sucesso", "", cBody, "", .F., .F.)
				//Finaliza o processo na PZB
				U_MonitRes("000001", 3, , cIdPZB, , .T.)
				cJson += '"clientes":['
				cJson += "{" 
				cJson += '"Mensagem' + '":"' + cMensagem + '",'
				cJson += '"lret' + cValTochar(nX) + '":true'
				cJson += "},"
			EndIf
			// Controle de Rollback Cadastral 
			/*
			If lRollback
				SA1->(DbSetOrder(1))
				// Bloqueia o registro Perfil - 21
				SA1->(DbGoTop())
				If SA1->(DbSeek(xFilial('SA1')+Alltrim(cBlocA1Id)+Alltrim(cBlocA1Lj)))
					if RecLock("SA1",.F.)
						SA1->A1_XATINAT := 'N'
						SA1->A1_CGC 	:= '' //Iif(SA1->A1_XATINAT == "S",SA1->A1_CGC,'')
						SA1->A1_MSBLQL  := '1' // 1= SIM/ BSRANCO OU 2 =NAO
						SA1->A1_XCODOAB := cBackA1Id
						SA1->A1_XTPOAB  := cBackA1Lj
						//A1__ATINAT N
						MsUnlock()
					Endif
				Endif
				// Retorna o registro Perfil - 01
				SA1->(DbGoTop())
				If SA1->(DbSeek(xFilial('SA1')+Alltrim(cBackA1Id)+Alltrim(cBackA1Lj)))
					if RecLock("SA1",.F.)
						SA1->A1_XATINAT := 'S'
						SA1->A1_CGC 	:= cCgcCli //Iif(SA1->A1_XATINAT == "S",SA1->A1_CGC,'')
						SA1->A1_MSBLQL  := '2' // 1= SIM/ BSRANCO OU 2 =NAO
						MsUnlock()
					Endif
				Endif
				lRollback := .F.
			Endif
			*/
		Next nX

		cJson := Left(cJson, Rat(",", cJson)-1)
		cJson += "]}"

		::SetResponse( cJson )

	EndIf

(cAlsQry)->(dbCloseArea())

Return(.T.)
