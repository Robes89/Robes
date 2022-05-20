#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'

User Function MT010ALT()

Local _lRet		:= .T.
Local _aArea 	:= GetArea()

DBSelectArea("PR1")
PR1->(DBSetOrder(1))

If PR1->(MsSeek(xFilial("PR1") + STR(SB1->(RECNO()),6,0)))
	PR1->(RECLOCK("PR1",.F.))
		If SB1->B1_MSBLQL == "1"
			PR1->PR1_TIPREQ := "3"
		Else 
			PR1->PR1_TIPREQ := "2"
		EndIf		
		PR1->PR1_STINT := "P"	
	PR1->(MSUnlock())
Else
	PR1->(RECLOCK("PR1",.T.))		
		PR1->PR1_FILIAL := xFilial("PR1")
		PR1->PR1_ALIAS  := "SB1"
		PR1->PR1_RECNO  := SB1->(RECNO())
		PR1->PR1_TIPREQ := "1"
		PR1->PR1_STINT  := "P"
		PR1->PR1_CHAVE  := SB1->B1_COD
	PR1->(MSUnlock())	
EndIf

RestArea(_aArea)

Return _lRet
