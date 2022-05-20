#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

User Function MT103FIM() 

Local _cQry		:= ""
Local _cAmzMgt	:= AllTrim(GetMv('FT_ARMZMGT',,'00'))
Local _cWKArea	:= GetNextAlias()

Local _nOPC		:= PARAMIXB[1]   // Op��o Escolhida pelo usuario no aRotina 
Local _nCnfm 	:= PARAMIXB[2]   // Se o usuario confirmou a opera��o de grava��o da NFECODIGO DE APLICA��O DO USUARIO

Local _aArea	:= GetArea()

If _nOPC = 3 .And. _nCnfm = 1     

	DBSelectArea("PR1")
	PR1->(DBSetOrder(1))
		
	_cQry := " SELECT D1_COD, SB1.R_E_C_N_O_ AS RECNO "
	_cQry += " FROM " + RetSQLName("SD1") + " SD1 "
	_cQry += " INNER JOIN " + RetSQLName("SB1") + " SB1 "
	_cQry += " ON B1_FILIAL = '" + xFilial("SB1") + "' "
	_cQry += " AND B1_COD = D1_COD "
	_cQry += " WHERE D1_FILIAL '" + xFilial("SD1") + "' " 
	_cQry += " AND D1_DOC = '" + SF1->F1_DOC + "' "
	_cQry += " AND D1_SERIE = '" + SF1->F1_SERIE + "'"
	_cQry += " AND D1_FORNECE = '" + SF1->F1_FORNECE + "'"
	_cQry += " AND D1_LOJA = '" + SF1->F1_LOJA + "'"
	_cQry += " AND D1_LOCAL = '" + _cAmzMgt + "' "
	_cQry += " AND SD1.D_E_L_E_T_ = ' ' "
	_cQry += " AND SB1.D_E_L_E_T_ = ' ' "
	_cQry += " ORDER BY D1_COD "
	_cQry += " GROUP BY D1_COD, SB1.R_E_C_N_O_ "
	
	If Select(_cWKArea) > 0
		(_cWKArea)->(DBCloseArea())
	Endif

	_cQry := ChangeQuery(_cQry)
	DBUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cWKArea,.T.,.T.)

	While (_cWKArea)->(!EOF())
	
		If !PR1->(MsSeek(xFilial("PR1") + "SB1" + STR((_cWKArea)->RECNO,16)))
		
			RecLock("PR1",.T.)
		
			PR1->PR1_FILIAL := xFilial("PR1")
			PR1->PR1_ALIAS  := "EST"
			PR1->PR1_RECNO  := (_cWKArea)->RECNO
			PR1->PR1_TIPREQ := "1"
			PR1->PR1_STINT  := "P"
			PR1->PR1_CHAVE  := (xFilial("SB1") + (_cWKArea)->D1_COD)
		
			PR1->(MSUnlock())
			
		EndIf 
		(_cWKArea)->(DBSkip()) 
	EndDo
EndIf

RestArea(_aArea)
Return Nil
