#include "totvs.ch"

user Function PE01NFESEFAZ()

Local aRet := PARAMIXB
Local aProdRet := aRet[1] //aProd
Local cNFOri	:= ""
Local cSerieOri := ""
Local aInfItRet	:= aRet[6] //aInfoItem

Local aAreaSD2 := SD2->(GetArea())

// Tratativa para limpar tag do codigo de barras do produto que nao é EAN
For i:= 1 To Len(aProdRet)                                
	aProdRet[i,3] := ""
	// Mensagem do lote - Tag InfAdProd - aProd[25]
	If aProdRet[i,19] <> "" // Se o produto controla lote
		If Empty(aProdRet[i,25])
			aProdRet[i,25] := "Lote: " + aProdRet[i,19]
		Else
			aProdRet[i,25] += " | Lote: " + aProdRet[i,19]
		Endif
	Endif
	
	// Informacao da NF de origem no item
	cNFOri := Alltrim(Posicione("SD2",8,xFilial("SD2")+aInfItRet[i,1]+aInfItRet[i,2],"D2_NFORI"))
	cSerieOri := Alltrim(SD2->D2_SERIORI)
	
	If Empty(aProdRet[i,25])
		aProdRet[i,25] := "NF Ori: " + cSerieOri + "/" + cNFOri
	Else
		aProdRet[i,25] += " | NF Ori: " + cSerieOri + "/" + cNFOri
	Endif
Next

aRet[1] := aProdRet

RestArea(aAreaSD2)

Return aRet