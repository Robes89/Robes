USER FUNCTION MT410CPY()

Local aArea := GetArea()
Local lRet := .T.
Local nx := 0 

M->C5_MENNOTA := ""
M->C5_MENNOTA := "Pedido: "+M->C5_NUM+SPACE(240)

RestArea(aArea)	
RETURN lRet