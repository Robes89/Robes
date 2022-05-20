#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'APWEBSRV.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'FILEIO.CH'
#INCLUDE 'RWMAKE.CH'


User Function MT010EXC()

Local _cID		:= SB1->B1_IDMGNTO
Local _lRet		:= .T.
Local _aArea 	:= GetArea()

DBSelectArea("PR1")

PR1->(RECLOCK("PR1",.T.))	
	PR1->PR1_FILIAL := xFilial("PR1")
	PR1->PR1_ALIAS  := "SB1"
	PR1->PR1_RECNO  := SB1->(RECNO())
	PR1->PR1_TIPREQ := "3"
	PR1->PR1_STINT  := "P"
	PR1->PR1_CHAVE  := _cID
PR1->(MSUnlock())

RestArea(_aArea)
Return _lRet