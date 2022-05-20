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
//\\Srv-app-ws\e$\TOTVS\Microsiga\Protheus12\HML\bin\WS_APPS_01
WsRestFul PostFin Description "Método responsavel pela inclusão/alteração de Titulos"

WsData cCgcEmp		As String

WsMethod Post Description "Inclusão/alteração de Titulos" WsSyntax "/PostFin"

End WsRestFul

WsMethod Post WsReceive cCgcEmp WsService PostFin

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
	cQuery += " WHERE PR2_CODPZA = '000002' AND PR2.D_E_L_E_T_ = ' '  AND PR3.D_E_L_E_T_ = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	If len(oJsoAux:Titulos) > 0

		cJson := "{"

		//Cria servi�o no montitor
		aCriaServ := U_MonitRes("000002", 1, Len(oJsoAux:Titulos) )   
		cIdPZB 	  := aCriaServ[2]

		For nX := 1 to len(oJsoAux:Titulos)

			

			cMensagem := ''
			(cAlsQry)->(DbGoTop())

			aDados      := {}

			cTit := AVkEY(oJsoAux:Titulos[nX]:E1_XNUMOAB,"E1_XNUMOAB")           
			
			DBSelectArea("SE1")
			SE1->(dbSetOrder(29))	

			
			If SE1->(DBSeek(xFilial("SE1") + cTit))
				//Alteração
				ntpExec := 4
				cNumSeq := SE1->E1_NUM
				cMensagem := 'Alteração ' + oJsoAux:Titulos[nX]:E1_XNUMOAB

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
					cMensagem := 'Inclusao ' + oJsoAux:Titulos[nX]:E1_XNUMOAB
			EndIf
	


			While !(cAlsQry)->(Eof())

				cCpo        := Alltrim((cAlsQry)->PR3_CPOORI)

				If (cAlsQry)->PR3_TPCONT == "1"
					cConteudo := &("oJsoAux:Titulos[" + cValTochar(nX) + "]:" + cCpo)  
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
			conout(aDados)
			//aDados := FWVetByDic(aDados,"SE1",.F.) //Organiza o array
			MSExecAuto({|x,y| FINA040(x,y)},aDados,ntpExec)

			::SetContentType("application/json")

			cMenssagem  := "Post Titulos"

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

				cJson += '"Titulos":['
				cJson += "{" 
				cJson += '"Mensagem' + '":"' + cStrErro + '",'
				cJson += '"lret' + cValTochar(nX) + '":false'
				cJson += "},"

			Else

				ConfirmSx8()

				If ntpExec == 3
					U_MonitRes("000002", 2, , cIdPZB, cMenssagem, .T., "Titulo incluso com sucesso", "", cBody, "", .F., .F.)
				Else
					U_MonitRes("000002", 2, , cIdPZB, cMenssagem, .T., "Titulo Alterado com sucesso", "", cBody, "", .F., .F.)
				Endif 

				//Finaliza o processo na PZB
				U_MonitRes("000002", 3, , cIdPZB, , .T.)

				cJson += '"Titulos":['
				cJson += "{" 
				cJson += '"Mensagem' + '":"' + cMensagem + '",'
				cJson += '"
				
				' + cValTochar(nX) + '":true'
				cJson += "},"

			EndIf

		Next nX

		cJson := Left(cJson, Rat(",", cJson)-1)
		cJson += "]}"

		::SetResponse( cJson )

	EndIf

(cAlsQry)->(dbCloseArea())

Return(.T.)
