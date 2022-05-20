#INCLUDE "TOTVS.CH" 

User Function SF1100I
Local lFormPg  := GetMv("OV_ATVFMPG",,.T.)
Local aAreaSF1 := SF1->(GetArea())

If lFormPg
    u_CKGRVTIT()
Endif

RestArea(aAreaSF1)
Return
