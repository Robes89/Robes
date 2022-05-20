#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'APWEBSRV.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'FILEIO.CH'
#INCLUDE 'RWMAKE.CH'

User Function OS010GRV()

Local _cOPC		:= AllTrim(STR(PARAMIXB[2]))
Local _cGrpMgnt	:= GetMV('FT_TABMGNT',,'')

Local _aArea 	:= GetArea()

Local _lRet	:= .T.

If DA0->DA0_CODTAB $ _cGrpMgnt

	DBSelectArea("PR1")
	PR1->(DBSetOrder(1))
	
	If !PR1->(MsSeek(xFilial("PR1") + "DA0" + STR(DA0->(RECNO()),16)))
		RECLOCK("PR1",.T.)		
			PR1->PR1_FILIAL := xFilial("PR1")
			PR1->PR1_ALIAS  := "DA0"
			PR1->PR1_RECNO  := DA0->(RECNO())
			PR1->PR1_TIPREQ := "1"
			PR1->PR1_STINT  := "P"
			PR1->PR1_CHAVE  := (xFilial("DA0") + DA0->DA0_CODTAB)
		PR1->(MSUnlock())	
	Else
		RECLOCK("PR1",.F.)
			PR1->PR1_TIPREQ := IIF(_cOPC == '4', "2", "3")		
			PR1->PR1_STINT := "P"	
		PR1->(MSUnlock())	
	EndIf 
	
	RestArea(_aArea)

EndIf
	
Return _lRet
