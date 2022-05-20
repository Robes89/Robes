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

//\\Srv-app-ws\e$\TOTVS\Microsiga\Protheus12\HML\bin\WS_APPS_01
WsRestFul PostBai Description "Método responsavel pela Baixa de Titulos"

WsData cCgcEmp		As String

WsMethod Post Description "Baixa de Titulos" WsSyntax "/PostBai"

End WsRestFul

WsMethod Post WsReceive cCgcEmp WsService PostBai

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
	Local cEnt		:= ''
	Local ntpExec   := 3
	Local cCgcCli   := ''
	Local cMensagem := ''
	Local cTit      := ''
	Local cAliasE1  := GetNextAlias()
	Local cNumSeq   := ''
	Local cTit      := ''
	Local lIncOK    := .F.
	Local cNumTit   := ""
	Local cLogExt   := ""
	Local cMenssagem  := ""
	Local cKeySE8 := ""

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
	Private cErrorEA := ""

	TRYEXCEPTION

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
		cQuery += " WHERE PR2_CODPZA = '000003' AND PR2.D_E_L_E_T_ = ' '  AND PR3.D_E_L_E_T_ = ' ' "

		If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

		If len(oJsoAux:Baixas) > 0

			cJson := "{"

			//Cria servi�o no montitor
			aCriaServ := U_MonitRes("000003", 1, Len(oJsoAux:Baixas) )   
			cIdPZB 	  := aCriaServ[2]

			For nX := 1 to len(oJsoAux:Baixas)

				/////////////////////Philip - Caso não exista o título, o mesmo deverá ser incluído
				cTit := AVkEY(oJsoAux:Baixas[nX]:E1_XNUMOAB,"E1_XNUMOAB")  
				cMenssagem  := "OABBAI01 - Post Baixas " + cTit
				DBSelectArea("SE1")
				SE1->(dbSetOrder(29))
				SE1->(DbGoTop())
				If SE1->(DBSeek(xFilial("SE1") + cTit)) //Existe, baixa direto
					lIncOK := .T.
					cNumTit := SE1->E1_NUM //PEGO O NÚMERO SEQUENCIAL DO TÍTULO PARA EFETUAR A BAIXA
					DBSelectArea("SA1")
					SA1->(DbSetOrder(1))
					SA1->(DbGoTop())
					if SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
						if SA1->A1_MSBLQL == "1" // Bloqueado.
							if RecLock("SA1",.F.)
								SA1->A1_MSBLQL := "2"
							endif
						Endif
					Endif
					/*cKeySE8 := SE1->E1_FILIAL + SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA + DToS(SE1->E1_BAIXA)
					DBSelectArea("SE8")
					SE8->(DbSetOrder(1))
					SE8->(DbGoTop())
					if SE8->(DbSeek(cKeySE8))
						if RecLock("SE8",.F.)
							SE8->(DBDelete())
							SE8->(MsUnLock())
						Endif
					Endif*/
				Else	//Não existe, tenta incluir
					lIncOK := .F.
					Inclui(oJsoAux, @lIncOK, cBody)
				Endif 
				///////////////////////

				If lIncOK //Caso tenha incluído com sucesso
					
					DBSelectArea("SE1")
					SE1->(dbSetOrder(29))	
					SE1->(DbGoTop())
					If SE1->(DBSeek(xFilial("SE1") + cTit))
						cNumTit := SE1->E1_NUM //PEGO O NÚMERO SEQUENCIAL DO TÍTULO PARA EFETUAR A BAIXA
						/*cKeySE8 := SE1->E1_FILIAL + SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA + DToS(SE1->E1_BAIXA)
						DBSelectArea("SE8")
						SE8->(DbSetOrder(1))
						SE8->(DbGoTop())
						if SE8->(DbSeek(cKeySE8))
							if RecLock("SE8",.F.)
								SE8->(DBDelete())
								SE8->(MsUnLock())
							Endif
						Endif*/
						if !Empty(SE1->E1_BAIXA)
							::SetContentType("application/json")
							cStrErro := 'Registro ja contem Baixa. Titulo: ' + cTit
							U_MonitRes("000003", 2, , cIdPZB, cMenssagem, .T., cStrErro, cBody, "Sucesso!", "", .F., .F.)
							U_MonitRes("000003", 3, , cIdPZB, , .T.)
							cJson += '"Baixas":['
							cJson += "{" 
							cJson += '"Mensagem' + '":"' + cStrErro + '",'
							cJson += '"lret' + cValTochar(nX) + '":true'
							cJson += "},"

							::SetResponse( cJson )
							Return .T.
						Endif
					Else //Caso retorne erro na inclusão, Finalizo o WS
						::SetContentType("application/json")
						cStrErro := 'Não foi possivel incluir o título. Baixa não efetuada. Titulo: ' + cTit
						U_MonitRes("000003", 2, , cIdPZB, cMenssagem, .F., cStrErro, cBody, "Erro no processamento!", "", .F., .F.)
						U_MonitRes("000003", 3, , cIdPZB, , .F.)
						cJson += '"Baixas":['
						cJson += "{" 
						cJson += '"Mensagem' + '":"' + cErrorEA + '",'
						cJson += '"lret' + cValTochar(nX) + '":false'
						cJson += "},"

						::SetResponse( cJson )
						Return .T.
					Endif 
				Else //Caso retorne erro na inclusão, Finalizo o WS
					::SetContentType("application/json")
					cStrErro := 'Não foi possivel incluir o título. Baixa não efetuada. Titulo: ' + cTit
					U_MonitRes("000003", 2, , cIdPZB, cMenssagem, .F., cStrErro, cBody, "Erro no processamento!", "", .F., .F.)
					U_MonitRes("000003", 3, , cIdPZB, , .F.)
					cJson += '"Baixas":['
					cJson += "{" 
					cJson += '"Mensagem' + '":"' + cErrorEA + '",'
					cJson += '"lret' + cValTochar(nX) + '":false'
					cJson += "},"
					::SetResponse( cJson )
					Return .T.
				Endif   

				cMensagem := ''
				(cAlsQry)->(DbGoTop())

				aDados      := {}

				While !(cAlsQry)->(Eof())

					cCpo        := Alltrim((cAlsQry)->PR3_CPOORI)

					If (cAlsQry)->PR3_TPCONT == "1"
						cConteudo := &("oJsoAux:Baixas[" + cValTochar(nX) + "]:" + cCpo)  
					Else
						cConteudo := &((cAlsQry)->PR3_CONTEU)
					EndIf

					

					If UPPER(AllTrim(cCpo)) == 'E1_BAIXA' .oR. UPPER(AllTrim(cCpo)) == 'E1_MOVIMEN' 
							cConteudo := StoD(cConteudo)
					EndIf

					If UPPER(AllTrim(cCpo)) == "E1_PREFIXO"
						cConteudo := avKey(cConteudo,"E1_PREFIXO")
					Endif

					If UPPER(AllTrim(cCpo)) == "E1_NUM"
						cConteudo := avKey(cNumTit,"E1_NUM")
					Endif

					If UPPER(AllTrim(cCpo)) == "E1_PARCELA"
						cConteudo := avKey(cConteudo,"E1_PARCELA")
					Endif

					If UPPER(AllTrim(cCpo)) == "E1_TIPO"
						cConteudo := avKey(cConteudo,"E1_TIPO")
					Endif

					aAdd(aDados, {Alltrim((cAlsQry)->PR3_CPODES), cConteudo, nil})

					(cAlsQry)->(DbSkip())

				End
				//conout(aDados)
				//aDados := FWVetByDic(aDados,"SE1",.T.) //Organiza o array
				MSExecAuto({|x,y,b,a| FINA070(x,y,b,a)},aDados,ntpExec,.F.,3)
				//MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3) 

				::SetContentType("application/json")

				If lMsErroAuto

					cStrErro := ""

					aErros 	:= GetAutoGRLog() // retorna o erro encontrado no execauto.
					cLogExt := ""
					aEval(aErros,{|l| cLogExt += Alltrim(l) + CRLF})
					cErrorEA += "Erro Integração Pedido -> " + StrTran(cLogExt, CRLF, " ")

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

					U_MonitRes("000003", 2, , cIdPZB, cMenssagem, .F., cStrErro, cBody, cLogExt, "", .F., .F.)

					//Finaliza o processo na PZB
					U_MonitRes("000003", 3, , cIdPZB, , .F.)

					cJson += '"Baixas":['
					cJson += "{" 
					cJson += '"Mensagem' + '":"' + cErrorEA + '",'
					cJson += '"lret' + cValTochar(nX) + '":false'
					cJson += "},"

				Else

					ConfirmSx8()

					If ntpExec == 3
						
						cMensagem := "Baixa efetuada com sucesso"
						U_MonitRes("000003", 2, , cIdPZB, cMenssagem, .T., "Titulo Baixado com sucesso", cBody, , "Sucesso!", .F., .F.)
					ElseIf ntpExec == 5
						
						cMensagem := "Baixa cancelada com sucesso"
						U_MonitRes("000003", 2, , cIdPZB, cMenssagem, .T., "Baixa Cancelada com sucesso", cBody, , "Sucesso!", .F., .F.)
					ElseIf ntpExec == 6
						
						cMensagem := "Baixa Excluída com sucesso"
						U_MonitRes("000003", 2, , cIdPZB, cMenssagem, .T., "Baixa Excluída com sucesso", cBody, "Sucesso!", "", .F., .F.)
					Endif 

					//Finaliza o processo na PZB
					U_MonitRes("000003", 3, , cIdPZB, , .T.)

					cJson += '"Baixas":['
					cJson += "{" 
					cJson += '"Mensagem' + '":"' + cMensagem + '",'
					cJson += '"lret' + cValTochar(nX) + '":true'
					cJson += "},"

				EndIf

			Next nX

			cJson := Left(cJson, Rat(",", cJson)-1)
			cJson += "]}"

			::SetResponse( cJson )

		EndIf

	CATCHEXCEPTION USING oException

		//ConOut("OABBAI01.PRW:LOG"+Time()+CRLF+oException:Description)

		U_MonitRes("000003", 2, 0, cIdPZB, oException:Description, .F., "OABBAI01.PRW:LOG"+Time(), cBody, oException:Description, "Errorlog", .F., .F., "", .F., .F., .F.)
		//Finaliza o processo na PZB - Error
		U_MonitRes("000003", 3, 0, cIdPZB, "", .F.)

		cJson += '"Baixas":['
		cJson += "{" 
		cJson += '"Mensagem' + '":"' + "OABBAI01.PRW:LOG"+Time()+CRLF+oException:Description + '",'
		cJson += '"lret' + cValTochar(0) + '":false'
		cJson += "},"

	ENDEXCEPTION

	(cAlsQry)->(dbCloseArea())

Return(.T.)

Static Function Inclui(oJsoAux, lIncOK, cBody)

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
	Local cEnt		:= ''
	Local ntpExec   := 3
	Local cCgcCli   := ''
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

	If len(oJsoAux:Baixas) > 0


		cJson := "{"

		//Cria servi�o no montitor
		aCriaServ := U_MonitRes("000002", 1, Len(oJsoAux:Baixas) )   
		cIdPZB 	  := aCriaServ[2]

		For nX := 1 to len(oJsoAux:Baixas)
			cLogExt   := ''
			cMensagem := ''
			(cAlsQry)->(DbGoTop())

			aDados      := {}

			cTit := AVkEY(oJsoAux:Baixas[nX]:E1_XNUMOAB,"E1_XNUMOAB")           
			
			DBSelectArea("SE1")
			SE1->(dbSetOrder(29))	
			SE1->(DbGoTop())
			
			If SE1->(DBSeek(xFilial("SE1") + cTit))
				//Alteração
				ntpExec := 4
				cNumSeq := SE1->E1_NUM
				cMensagem := 'OABBAI01 - Alteração ' + oJsoAux:Baixas[nX]:E1_XNUMOAB
				DBSelectArea("SA1")
				SA1->(DbSetOrder(1))
				SA1->(DbGoTop())	
				if SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
					if SA1->A1_MSBLQL == "1" // Bloqueado.
						if RecLock("SA1",.F.)
							SA1->A1_MSBLQL := "2"
						endif
					endif
				Endif
			Else	
				cQuery := " SELECT MAX(E1_NUM) + 1 AS NUM FROM  " + RetSqlName("SE1") + " (NOLOCK) SE1 "
				cQuery += " WHERE SE1.D_E_L_E_T_ = ' '  "

				If Select(cAliasE1) > 0; (cAliasE1)->(dbCloseArea()); Endif
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasE1,.T.,.T.)

				If (cAliasE1)->NUM == 0
					cNumSeq :=  PADL('1',9,"0")
				Else
					cNumSeq :=  PADL((cAliasE1)->NUM,9,"0")
				Endif 
				ntpExec := 3//Inclusão
				cMensagem := 'OABBAI01 - Inclusao ' + oJsoAux:Baixas[nX]:E1_XNUMOAB
				DBSelectArea("SA1")
				SA1->(DbSetOrder(1))
				SA1->(DbGoTop())	
				if SA1->(DbSeek(xFilial("SA1")+oJsoAux:Baixas[nX]:E1_CLIENTE+oJsoAux:Baixas[nX]:E1_LOJA))
					if SA1->A1_MSBLQL == "1" // Bloqueado.
						if RecLock("SA1",.F.)
							SA1->A1_MSBLQL := "2"
						endif
					endif
				Endif
			EndIf
	


			While !(cAlsQry)->(Eof())

				cCpo        := Alltrim((cAlsQry)->PR3_CPOORI)

				If (cAlsQry)->PR3_TPCONT == "1"
					cConteudo := &("oJsoAux:Baixas[" + cValTochar(nX) + "]:" + cCpo)  
				Else
					cConteudo := &((cAlsQry)->PR3_CONTEU)
				EndIf

				If UPPER(AllTrim(cCpo)) == 'E1_VENCREA' .oR. UPPER(AllTrim(cCpo)) == 'E1_VENCTO' .oR.  UPPER(AllTrim(cCpo)) == 'E1_EMISSAO' .oR. UPPER(AllTrim(cCpo)) == 'E1_BAIXA'
					cConteudo := StoD(cConteudo)
				EndIf
				
				If UPPER(AllTrim(cCpo)) == 'E1_NUM' 
					cConteudo := cNumSeq
				EndIf

				//If UPPER(AllTrim(cCpo)) == 'A1_COD' 
				//		cConteudo := StoD(cConteudo)
				//EndIf

				aAdd(aDados, {Alltrim((cAlsQry)->PR3_CPODES), cConteudo, nil})

				(cAlsQry)->(DbSkip())

			End
			//conout(aDados)
			//aDados := FWVetByDic(aDados,"SE1",.F.) //Organiza o array
			MSExecAuto({|x,y| FINA040(x,y)},aDados,ntpExec)

			If lMsErroAuto

				cStrErro := ""

				aErros 	:= GetAutoGRLog() // retorna o erro encontrado no execauto.
				cLogExt := ""
				aEval(aErros,{|l| cLogExt += Alltrim(l) + CRLF})
				cErrorEA += "Erro Integração Cliente -> " + StrTran(cLogExt, CRLF, " ") + " | "
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

				U_MonitRes("000002", 2, , cIdPZB, cMensagem, .F., cStrErro, cLogExt, "Erro OABBAI01", "", .F., .F.)

				//Finaliza o processo na PZB
				U_MonitRes("000002", 3, , cIdPZB, , .F.)

				lIncOK := .F.

			Else

				ConfirmSx8()

				If ntpExec == 3
					U_MonitRes("000002", 2, , cIdPZB, cMensagem, .T., "Titulo incluso com sucesso", "", cBody, "", .F., .F.)
				Else
					U_MonitRes("000002", 2, , cIdPZB, cMensagem, .T., "Titulo Alterado com sucesso", "", cBody, "", .F., .F.)
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
