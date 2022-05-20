#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'

User Function MA030TOK()

Local aDados	:= {}
Local lRet 		:= .T.

DBSelectArea("PR1")
PR1->(DBSetOrder(1))
	
If !PR1->(MsSeek(xFilial("PR1") + "SA1" + STR(DA0->(RECNO()),16)))
	RECLOCK("PR1",.T.)		
		PR1->PR1_FILIAL := xFilial("PR1")
		PR1->PR1_ALIAS  := "SA1"
		PR1->PR1_RECNO  := SA1->(RECNO())
		PR1->PR1_TIPREQ := "1"
		PR1->PR1_STINT  := "P"
		PR1->PR1_CHAVE  := (xFilial("SA1") + SA1->A1_cOD)
	PR1->(MSUnlock())	
Else
	RECLOCK("PR1",.F.)
		PR1->PR1_TIPREQ := 2		
		PR1->PR1_STINT := "P"	
	PR1->(MSUnlock())	
EndIf 

Return lRet