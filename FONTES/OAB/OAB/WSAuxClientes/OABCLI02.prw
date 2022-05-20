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
#INCLUDE "COLORS.CH"

#DEFINE cEnt Chr(10)+ Chr(13)


WsRestFul POSTLICENC Description "Altera Licenciamento"

WsData cCgcEmp		As String

WsMethod Post Description "Altera Licenciamento" WsSyntax "/POSTLICENC"

End WsRestFul

WsMethod Post WsReceive cCgcEmp WsService POSTLICENC

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
	Local oBkpJso   := Nil
	Local cSeek     := ''
	Local lOk       := .T.
	Local cRetMen   := ''
	Local cRetChave := ''
	Local cConteudo := ''
	Local cRetChave := ""
	Local cCodCli	:= ''
	Local cCodOco	:= ''
	Local cOcorr	:= ''
	Local cDataIn	:= ''
	Local cDataFim 	:= ''
	Local lInclui   := .T.

	//Efetuando conexùo de acordo com CGC enviado na entrada
	RpcSetEnv("01","01")

	//

	FWJsonDeserialize(cBody, @oJsoAux)

	SM0->(DbSetOrder(1))

	If len(oJsoAux:Licenciamento) > 0

		dbSelectArea("SA1")
		dbSetORder(1)

		dbSelectArea("SZB")
		dbSetORder(1)

		cJson := "{"

		//Cria serviùo no montitor
		aCriaServ := U_MonitRes("000002", 1, Len(oJsoAux:Licenciamento) )   
		cIdPZB 	  := aCriaServ[2]

		::SetContentType("application/json")
		cJson += '"Licenciamento":['

		For nX := 1 to len(oJsoAux:Licenciamento)

			cCodCli  := oJsoAux:Licenciamento[nX]:CodigoCli 
			cCodOco  := oJsoAux:Licenciamento[nX]:CodOcorrencia 
			cOcorr   := oJsoAux:Licenciamento[nX]:DescOcorrencia 
			cDataIn  := oJsoAux:Licenciamento[nX]:DataInicio 
			cDataFim := oJsoAux:Licenciamento[nX]:DataFim 
			lInclui  := .T.
			lAltera  := .F.

			If cCodOco == '000002' .Or. cCodOco == '000003'

				If SA1->(DBSeek(xFilial("SA1") + cCodCli))

					Do case
/* -------I----------*/Case Empty(cDataFim)//Inclusùo///////////////////////////////
						//Nùo encontrou 000002 nem 000003, inclui direto			
						If ! SZB->(DBSeek(xFilial("SZB") + cCodCli + '000002' )) .AND. ! SZB->(DBSeek(xFilial("SZB") + cCodCli + '000003' ))
							u_IncRegSZB(cCodOco, cOcorr, cCodCli, cDataIn)
							u_AltXlicenc(cCodCli, cCodOco)
							cRetMen := 'Ocorrùncia incluùda com Sucesso!'
							lOk := .T.
							lInclui := .F.//Jù incluiu. Para nùo incluir novamente marco .F.
						Else
							
							//verifico qualquer ocorrencia que possa estar em aberto 
							//Tanto com quanto sem benefùcios
							While SZB->ZB_CODCLI == cCodCli //busco algum registro com data final em aberto 
								If (SZB->ZB_CODIGO == '000002' .Or. SZB->ZB_CODIGO == '000003') .And. Empty(SZB->ZB_DTFIM)

									cRetMen := 'Erro 000003 - Cliente ja possui uma ocorrencia do tipo licenciamento em aberto '
									lOk := .F.
									lInclui := .F.
									Exit
								Endif 
								SZB->(dbSkip())
							End

						Endif

						If lInclui //sù serù verdadeira caso sù exista(m) licenciamento(s) ja finalizado(s)

							u_IncRegSZB(cCodOco, cOcorr, cCodCli, cDataIn)
							u_AltXlicenc(cCodCli, cCodOco)
							cRetMen := 'Ocorrencia incluida com Sucesso!'
							lOk := .T.
						Endif


/* -------A----------*/Case ! Empty(cDataFim)//Alteraùùo /////////////////////////////////////
						If SZB->(DBSeek(xFilial("SZB") + cCodCli + cCodOco ))

							While SZB->ZB_CODIGO == cCodOco .And. SZB->ZB_CODCLI == cCodCli

								If Empty(SZB->ZB_DTFIM)
									u_AltRegSZB(cCodOco, cOcorr, cCodCli, cDataIn, cDataFim)
									u_AltXlicenc(cCodCli, '1')
									lAltera := .T.
									lOk := .T.
									cRetMen := 'Ocorrencia alterada com sucesso'
								Endif 

								SZB->(dbSkip())
							End
							
							If !lAltera
								cRetMen := 'Erro 000004 - Nao foi encontrada a ocorrencia em aberto para o cliente '
								lOk := .F.
							Endif 
					
						Else

							cRetMen := 'Erro 000005 - Nao foi encontrada a ocorrencia para o cliente '
							lOk := .F.
							lAltera := .F.
						Endif 
					Endcase 



				Else
					cRetMen := 'Erro 000001 - Cliente nao encontrado '

					lOk := .F.
				Endif 
			Else
				cRetMen := 'Erro 000002 - Codigo da ocorrencia diferente de 000002 e 000003 '

				lOk := .F.
			Endif 

			//Fim Inclusùo




			If !lOk
				U_MonitRes("000002", 2, , cIdPZB, cRetMen, .F., cStrErro, "", cBody, "", .F., .F.)

				//Finaliza o processo na PZB
				U_MonitRes("000002", 3, , cIdPZB, , .F.)

				cJson += "{" 
				cJson += '"errorMessage' + cValTochar(nX) + '":"' + cRetMen + '",'
				cJson += '"Cliente": "' + cCodCli + '",'
				cJson += '"lret' + cValTochar(nX) + '":false'
				cJson += "},"

			Else
				U_MonitRes("000002", 2, , cIdPZB, cRetMen, .T., "Processo Finalizado", "", cBody, "", .F., .F.)

				//Finaliza o processo na PZB
				U_MonitRes("000002", 3, , cIdPZB, , .T.)

				cJson += "{"
				cJson += '"Cliente": ' +  cCodCli + ","
				cJson += '"Ocorrencia": "' + cOcorr + '",'
				cJson += '"lret' + cValTochar(nX) + '":true'
				cJson += "},"

			EndIf

		Next nX

		cJson := Left(cJson, Rat(",", cJson)-1)
		cJson += "]}"

		ConOut(cJson)

		::SetResponse( cJson )

	EndIf

	

Return(.T.)


///CANCELAMENTO


WsRestFul POSTCANCEL Description "Cancelamento"

WsData cCgcEmp		As String

WsMethod Post Description "Cancelamento" WsSyntax "/POSTCANCEL"

End WsRestFul

WsMethod Post WsReceive cCgcEmp WsService POSTCANCEL

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
	Local oBkpJso   := Nil
	Local cSeek     := ''
	Local lOk       := .T.
	Local cRetMen   := ''
	Local cRetChave := ''
	Local cConteudo := ''
	Local cRetChave := ""
	Local cCodCli	:= ''
	Local cCodOco	:= ''
	Local cOcorr	:= ''
	Local cDataIn	:= ''
	Local cDataFim 	:= ''
	Local lInclui   := .T.

	RpcSetEnv("01","01")

	//

	FWJsonDeserialize(cBody, @oJsoAux)

	SM0->(DbSetOrder(1))

	If len(oJsoAux:Cancelamento) > 0

		dbSelectArea("SA1")
		dbSetORder(1)

		dbSelectArea("SZB")
		dbSetORder(1)

		cJson := "{"

		//Cria serviùo no montitor
		aCriaServ := U_MonitRes("000003", 1, Len(oJsoAux:Cancelamento) )   
		cIdPZB 	  := aCriaServ[2]

		::SetContentType("application/json")
		cJson += '"Ocorrencia":['

		For nX := 1 to len(oJsoAux:Cancelamento)

			cCodCli  := oJsoAux:Cancelamento[nX]:CodigoCli 
			cCodOco  := oJsoAux:Cancelamento[nX]:CodOcorrencia 
			cOcorr   := oJsoAux:Cancelamento[nX]:DescOcorrencia 
			cDataIn  := oJsoAux:Cancelamento[nX]:DataInicio 
			cDataFim := oJsoAux:Cancelamento[nX]:DataFim 
			lInclui  := .T.
			lAltera  := .F.

			If cCodOco == '000001'

				If SA1->(DBSeek(xFilial("SA1") + cCodCli))

					Do case
/* -----I-------------*/Case Empty(cDataFim)//Inclusùo///////////////////////////////
									
						If ! SZB->(DBSeek(xFilial("SZB") + cCodCli + '000001' )) 
							u_IncRegSZB(cCodOco, cOcorr, cCodCli, cDataIn)
							U_AltXCanc(cCodCli, '1') //ALTERO FLAG PARA CANCELADO
							cRetMen := 'Ocorrencia de Cancelamento incluida com Sucesso!'
							lOk := .T.
							lInclui := .F.//Jù incluiu. Para nùo incluir novamente marco .F.
						Else
							
							//verifico qualquer cancelamento que possa estar em aberto
							While SZB->ZB_CODCLI == cCodCli //busco algum registro com data final em aberto 
								If (SZB->ZB_CODIGO == '000001') .And. Empty(SZB->ZB_DTFIM)

									cRetMen := 'Erro 000003 - Cliente ja possui uma ocorrencia do tipo cancelamento em aberto '
									lOk := .F.
									lInclui := .F.
									Exit
								Endif 
								SZB->(dbSkip())
							End

						Endif

						If lInclui //sù serù verdadeira caso sù exista cancelamentos ja finalizados

							u_IncRegSZB(cCodOco, cOcorr, cCodCli, cDataIn)
							U_AltXCanc(cCodCli, '1') //ALTERO FLAG PARA CANCELADO
							cRetMen := 'Ocorrencia incluida com Sucesso!'
							lOk := .T.
						Endif


/* -----A------------*/Case ! Empty(cDataFim)//Alteraùùo /////////////////////////////////////
						If SZB->(DBSeek(xFilial("SZB") + cCodCli + cCodOco ))

							While SZB->ZB_CODIGO == cCodOco .And. SZB->ZB_CODCLI == cCodCli

								If Empty(SZB->ZB_DTFIM)
									u_AltRegSZB(cCodOco, cOcorr, cCodCli, cDataIn, cDataFim)
									U_AltXCanc(cCodCli, '2') //ALTERO FLAG PARA NaO CANCELADO
									lAltera := .T.
									lOk := .T.
									cRetMen := 'Ocorrencia alterada com sucesso'
								Endif 

								SZB->(dbSkip())
							End
							
							If !lAltera
								cRetMen := 'Erro 000004 - Nao foi encontrada a ocorrencia de cancelamento em aberto para o cliente '
								lOk := .F.
							Endif 
					
						Else

							cRetMen := 'Erro 000005 - Nao foi encontrada a ocorrencia para o cliente '
							lOk := .F.
							lAltera := .F.
						Endif 
					Endcase 



				Else
					cRetMen := 'Erro 000001 - Cliente nao encontrado '

					lOk := .F.
				Endif 
			Else
				cRetMen := 'Erro 000002 - Codigo da ocorrencia diferente de 000001 '

				lOk := .F.
			Endif 

			//Fim Inclusùo

			If !lOk
				U_MonitRes("000003", 2, , cIdPZB, cRetMen, .F., cStrErro, "", cBody, "", .F., .F.)

				//Finaliza o processo na PZB
				U_MonitRes("000003", 3, , cIdPZB, , .F.)

				cJson += "{" 
				cJson += '"errorMessage' + cValTochar(nX) + '":"' + cRetMen + '",'
				cJson += '"Cliente": "' + cCodCli + '",'
				cJson += '"lret' + cValTochar(nX) + '":false'
				cJson += "},"

			Else
				U_MonitRes("000003", 2, , cIdPZB, cRetMen, .T., "Processo Finalizado", "", cBody, "", .F., .F.)

				//Finaliza o processo na PZB
				U_MonitRes("000003", 3, , cIdPZB, , .T.)

				cJson += "{"
				cJson += '"Cliente": ' +  cCodCli + ","
				cJson += '"Ocorrencia": "' + cOcorr + '",'
				cJson += '"lret' + cValTochar(nX) + '":true'
				cJson += "},"

			EndIf

		Next nX

		cJson := Left(cJson, Rat(",", cJson)-1)
		cJson += "]}"

		ConOut(cJson)

		::SetResponse( cJson )

	EndIf


Return(.T.)
