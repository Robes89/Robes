#INCLUDE 'TOTVS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FILEIO.CH'

/*/{Protheus.doc} CHKLOTE
Envio de tÃ­tulos para cartÃ³rio
@author Juliano Souza TRIYO
@since 24/03/2021
@revision Juliano Souza TRIYO
@date 25/05/2021
/*/
User Function CHKLOTE()	
	FWMsgRun(,{|| CHKLOTE()}, "Aguarde...", "Fila - Incluindo informações para proxima comunicação...")
Return

Static Function CHKLOTE()
	Local aArea     := GetArea()
	Local lOk       := .F.
	Local aPergs    := {}
	Local cNumBor 	:= Space(TamSX3("EA_NUMBOR")[1])
	Local cTitle    := "Confirmação de Borderô"

	//Adiciona os parametros para a pergunta
	aAdd(aPergs, {1, "Num. Borderô",   cNumBor, "", ".T.", "SEA", ".T.", 80, .T.})
		
	//Mostra uma pergunta com parambox para filtrar o subgrupo
	If ParamBox(aPergs, "Informe os parâmetros - " + cTitle, , , , , , , , , .F., .F.)
		lOk := .T.
		cNumBor := Alltrim(cValToChar(MV_PAR01))
	Endif

	if lOk
		RefreshE1("01",cNumBor)  // 01 - Lote Confirmado.
		ApMsgInfo("Processo finalizado com sucesso!")
	else
		Alert("Processo abortado...")
	endif

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} RefreshE1
Atualiza Status do Titulo fiannceiro.
@author Juliano Souza TRIYO
@since 06/04/2021
@date 28/05/2021
/*/
Static Function RefreshE1(cSts, cNumbor)
	Local cSql := ""
	
	cSql += "UPDATE " + RetSqlName("SE1")
	cSql += " SET E1_XSITC = '"+ cSts +"'"
	cSql += " WHERE D_E_L_E_T_ != '*'"
	cSql += " AND E1_FILIAL = '"+ xFilial("SE1") +"'"
	cSql += " AND E1_NUMBOR = '"+ cNumbor +"'"

	TcSqlExec(cSql)

Return
