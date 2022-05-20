#include "totvs.ch"
#include "topconn.ch"

User Function SB6GRAVA

Local aAreaAtu	:= GetArea()
Local aAreaSD1	:= SD1->(GetArea())
Local aAreaSD2	:= SD2->(GetArea())
Local cQuery	:= ""
Local cAlias	:= Iif(SB6->B6_TES < "500", "SD1", "SD2")
Local cCampo	:= Substr(cAlias,2,2)
Local cChave	:= Iif(SB6->B6_PODER3 == "R", cCampo + "_NUMSEQ", cCampo + "_IDENTB6" )

cQuery := "SELECT " + cCampo +"_LOTECTL LOTE, "+ cCampo + "_DTVALID VLD"
cQuery += " FROM " + RetSqlName(cAlias) + " (NOLOCK) AS " + cAlias
cQuery += " WHERE " + cAlias + ".D_E_L_E_T_=' '"
cQuery += " AND " + cCampo + "_FILIAL = '" + xFilial(cAlias) + "'"
cQuery += " AND " + cChave + " = '" + SB6->B6_IDENT + "'"

tcQuery cQuery New Alias "QSB6"

If QSB6->(!eof())
	SB6->B6_LOTECTL := QSB6->LOTE
	SB6->B6_DTVALID := StoD(QSB6->VLD)
Endif

QSB6->(dbCloseArea())
                                                        
RestArea(aAreaSD1)
RestArea(aAreaSD2)
RestArea(aAreaAtu)

Return                                 