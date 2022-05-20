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


User Function Teste_Triyo

	Vai('000001', '000002')

Return 


Static Function vai(cCodCLi, cCodOco)
dbselectArea("SZB")
dbSetOrder(1)
		

			cCodCli  := cCodCli
			cCodOco  := cCodOco
			cOcorr   := 'teste'
			cDataIn  := date()
			cDataFim := date()+30
			lInclui  := .T.
			lAltera  := .F.
dbselectArea("SZB")
dbSetOrder(1)
			If cCodOco == '000002' .Or. cCodOco == '000003'

				If SA1->(DBSeek(xFilial("SA1") + cCodCli))

					Do case
/* -------I----------*/Case Empty(cDataFim)//Inclus�o///////////////////////////////
						//N�o encontrou 000002 nem 000003, inclui direto			
						If ! SZB->(DBSeek(xFilial("SZB") + cCodCli + '000002' )) .AND. ! SZB->(DBSeek(xFilial("SZB") + cCodCli + '000003' ))
							u_IncRegSZB(cCodOco, cOcorr, cCodCli, cDataIn)
							u_AltXlicenc(cCodCli, cCodOco)
							cRetMen := 'Ocorr�ncia inclu�da com Sucesso!'
							lOk := .T.
							lInclui := .F.//J� incluiu. Para n�o incluir novamente marco .F.
						Else
							
							//verifico qualquer ocorrencia que possa estar em aberto 
							//Tanto com quanto sem benef�cios
							While SZB->ZB_CODCLI == cCodCli //busco algum registro com data final em aberto 
								If (SZB->ZB_CODIGO == '000002' .Or. SZB->ZB_CODIGO == '000003') .And. Empty(SZB->ZB_DTFIM)

									cRetMen := 'Erro 000003 - Cliente j� possui uma ocorr�ncia do tipo licenciamento em aberto '
									lOk := .F.
									lInclui := .F.
									Exit
								Endif 
								SZB->(dbSkip())
							End

						Endif

						If lInclui //s� ser� verdadeira caso s� exista(m) licenciamento(s) ja finalizado(s)

							u_IncRegSZB(cCodOco, cOcorr, cCodCli, cDataIn)
							u_AltXlicenc(cCodCli, cCodOco)
							cRetMen := 'Ocorr�ncia inclu�da com Sucesso!'
							lOk := .T.
						Endif


/* -------A----------*/Case ! Empty(cDataFim)//Altera��o /////////////////////////////////////
						If SZB->(DBSeek(xFilial("SZB") + cCodCli + cCodOco ))

							While SZB->ZB_CODIGO == cCodOco .And. ZB_CODCLI == cCodCli

								If Empty(SZB->ZB_DTFIM)
									u_AltRegSZB(cCodOco, cOcorr, cCodCli, cDataIn, cDataFim)
									u_AltXlicenc(cCodCli, '1')
									lAltera := .T.
									lOk := .T.
									cRetMen := 'Ocorr�ncia alterada com sucesso'
								Endif 

								SZB->(dbSkip())
							End
							
							If !Altera
								cRetMen := 'Erro 000004 - Não foi encontrada a ocorrencia em aberto para o cliente '
								lOk := .F.
							Endif 
					
						Else

							cRetMen := 'Erro 000005 - Não foi encontrada a ocorrencia para o cliente '
							lOk := .F.
							lAltera := .F.
						Endif 
					Endcase 



				Else
					cRetMen := 'Erro 000001 - Cliente n�o encontrado '

					lOk := .F.
				Endif 
			Else
				cRetMen := 'Erro 000002 - C�digo da ocorr�ncia diferente de 000002 e 000003 '

				lOk := .F.
			Endif 

			//Fim Inclus�o




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

		

		cJson := Left(cJson, Rat(",", cJson)-1)
		cJson += "]}"

		ConOut(cJson)

		::SetResponse( cJson )

	//EndIf

	(cAlsQry)->(dbCloseArea())

Return(.T.)


///CANCELAMENTO
