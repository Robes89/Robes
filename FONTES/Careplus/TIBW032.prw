#INCLUDE "RPTDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWPRINTSETUP.CH"

User Function TIBW032()


Local _cQry		:= ""
Local _cWkArea	:= ""

RPCSETENV('01','0101')

DBSelectArea("SCR")

_cWkArea := CriaTrab(Nil,.F.)
			
_cQry := " SELECT	SCR.CR_NUM,        			"
_cQry += " 			SCR.CR_PRAZO,       		"
_cQry += " 			SCR.R_E_C_N_O_ AS RECSCR	"
_cQry += "   FROM   " + RetSQLName("SCR") + " SCR "
_cQry += "  WHERE  SCR.CR_FILIAL = '" + xFilial("SCR") + "'"
_cQry += "    AND 	SCR.CR_TIPO IN ('PC','IP')	"
_cQry += "    AND 	SCR.CR_WF <> ' '       		"
_cQry += "    AND 	SCR.CR_STATUS = '02'   		"
_cQry += "    AND 	SCR.CR_XREENV <> 'S'   		"
_cQry += "    AND 	SCR.CR_PRAZO < '" + DtoS(DATE()) + "' "
_cQry += "    AND 	SCR.D_E_L_E_T_= ' '   		"
_cQry += "  ORDER 	BY  SCR.CR_NUM      		"

			
If Select(_cWkArea) > 0
	(_cWkArea)->(DBCloseArea()) 
EndIf
			
DBUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cWkArea,.T.,.T.)
	
While (_cWkArea)->(!EOF())

	U_TIBW030Send((_cWkArea)->CR_NUM)
	
	SCR->(DBGoTo((_cWkArea)->RECSCR))
	RECLOCK("SCR",.F.)
		SCR->CR_XREENV := 'S'
	SCR->(MSUnlock())
	
	(_cWkArea)->(DBSkip())
	
EndDo
	
Return