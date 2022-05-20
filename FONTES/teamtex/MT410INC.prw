#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

User Function MT410INC() 

Local _cQry		:= ""
Local _cAmzMgt	:= AllTrim(GetMv('FT_ARMZMGT',,'00'))
Local _cWKArea	:= GetNextAlias()

Local _aArea	:= GetArea()

DBSelectArea("PR1")
PR1->(DBSetOrder(1))

_cQry := " SELECT C6_PRODUTO, SB1.R_E_C_N_O_ AS RECNO "
_cQry += " FROM " + RetSQLName("SC6") + " SC6 "
_cQry += " INNER JOIN " + RetSQLName("SB1") + " SB1 "
_cQry += " ON B1_FILIAL = '" + xFilial("SB1") + "' "
_cQry += " AND B1_COD = C6_PRODUTO "
_cQry += " WHERE C6_FILIAL = '" + xFilial("SC6") + "' " 
_cQry += " AND C6_NUM = '" + SC5->C5_NUM + "' "
_cQry += " AND C6_CLI = '" + SC5->C5_CLIENTE + "'"
_cQry += " AND C6_LOJA = '" + SC5->C5_LOJACLI + "'"
_cQry += " AND C6_LOCAL = '" + _cAmzMgt + "' "
_cQry += " AND SC6.D_E_L_E_T_ = ' ' "
_cQry += " AND SB1.D_E_L_E_T_ = ' ' "
_cQry += " GROUP BY C6_PRODUTO, SB1.R_E_C_N_O_ "
_cQry += " ORDER BY C6_PRODUTO "

If Select(_cWKArea) > 0
	(_cWKArea)->(DBCloseArea())
Endif

_cQry := ChangeQuery(_cQry)
DBUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cWKArea,.T.,.T.)

While (_cWKArea)->(!EOF())
			
	If !PR1->(MsSeek(xFilial("PR1") + "SB1" + STR((_cWKArea)->RECNO,16)))
		
		RECLOCK("PR1",.T.)
		
		PR1->PR1_FILIAL := xFilial("PR1")
		PR1->PR1_ALIAS  := "EST"
		PR1->PR1_RECNO  := (_cWKArea)->RECNO
		PR1->PR1_TIPREQ := "1"
		PR1->PR1_STINT  := "P"
		PR1->PR1_CHAVE  := (xFilial("SB1") + (_cWKArea)->C6_PRODUTO)
		
		PR1->(MSUnlock())
			
	EndIf 
	(_cWKArea)->(DBSkip())
EndDo

(_cWKArea)->(DBCLOSEAREA())
RestArea(_aArea)	
Return Nil
