User Function Impcsv()
local cCod:=''
local cloja:=''
local ndtime:=0

dBSelectArea('CZZ')
dbsetorder(1)
While !Eof()
     
    cCOD:=Substr(CZZ_CDAC,1,6)  
    cloja:=Substr(CZZ_CDAC,8,4)
    ndtime:=Val(alltrim(Substr(CZZ_CDAC,13,4)))

    dbSelectarea("SA1")
    dbsetorder(1)
    dbseek(xFilial("SA1") + cCOD + cLoja )
    Reclock('SA1',.f.)
        SA1->A1_XPVPC:=ndtime
    Msunlock()
    dbselectarea("CZZ")  
	dbskip()
	
End
Return()