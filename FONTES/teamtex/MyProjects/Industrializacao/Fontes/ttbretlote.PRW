#include "Protheus.ch"
User Function ttbretlote()
local clote:=''
local cLetra:=''
local cAno:=Substr(dtos(ddatabase),1,2)
local cAno1:=Substr(dtos(ddatabase),3,2)
local cmeslote:=Substr(dtos(ddatabase),5,2)
LOCAL cdia:= Substr(dtos(ddatabase),7,2)
local cProxlot:=SOMA1(Getmv("MV_PRXLOTE"))
//local cProxlot:=NextLote()
local cmesdta:={'01A','02B','03C','04D','05E','06F','07G','08H','09I','10J','11L','12M'}

For i:=1 to Len(cmesdta)
     If Month(ddatabase)=Val(Substr(cmesdta[i],1,2))
        cletra:=Substr(cmesdta[i],3,1)    
     Endif
Next 
PutMv("MV_PRXLOTE", SOMA1(Getmv("MV_PRXLOTE")))
clote:= cAno + cdia + cletra+ cAno1 + cProxlot

Return(clote)