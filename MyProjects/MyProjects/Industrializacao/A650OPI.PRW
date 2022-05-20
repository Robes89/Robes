User Function A650OPI()
Local nLin := PARAMIXB
Local lRet := .T.
Local cProduto := ""
Local aArea:= GETAREA()

cProduto := aCols[nLin][1]

aAreaSB1 := GetArea("SB1")

DbSelectArea("SB1")
SB1->(DbSetOrder(1))
If SB1->(DbSeek(xFilial("SB1")+cProduto))
    If SB1->B1_MKEST = '2' .And. SB1->B1_TIPO='PI'
        lRet := .F.
    EndIF
EndIf
SB1->(DbCloseArea())

RestArea(aAreaSB1)

Return lRet
