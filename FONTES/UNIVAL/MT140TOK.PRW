
User Function MT140TOK
Local lRetorno := PARAMIXB[1]  
Local lRet:=.T.
local nU := 0 
Local nPOs := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_COD"})
Local nPos2 := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_LOTECTL"})
DbSelectArea("SB1")
DbSetOrder(1)
For nU := 1  to len(acols)

IF SB1->(Dbseek(Xfilial("SB1")+acols[nu,nPos]))
    If SB1->B1_RASTRO  == 'L' .and. Empty(acols[nu,nPos2])
        acols[nu,nPos2]:= NextLote()
    Endif
EndIF
NEXT

return lRet
