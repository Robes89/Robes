#INCLUDE "PROTHEUS.CH"
User Function DADOSTIT()
Local cOrigem := Paramixb[1]
if cOrigem == "MATA954"
    M->F6_NUMERO := GETSXENUM("SF6","F6_NUMERO")
    ConfirmSX8() 
endif
Return()