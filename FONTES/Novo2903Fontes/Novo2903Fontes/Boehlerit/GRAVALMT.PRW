User Function GravaLmt()

// Ponto de entrada para gravar o CODLMT no SB2

aSalva := GetArea()
nRec := Recno()
lRet := .T.

If	!SB1->( Eof() )

	dbSelectArea("SB2")
	If !dbSeek(xFilial("SB2") + SB1->B1_COD)
		RecLock("SB2",.T.)
		B2_FILIAL := xFilial()
		B2_COD    := SB1->B1_COD
		B2_CODLMT := SB1->B1_CODLMT
		MsUnlock()
	Else
		RecLock("SB2",.F.)
		B2_CODLMT := SB1->B1_CODLMT
		MsUnlock()
	Endif
	
EndIf
	
RestArea(aSalva)
dbGoto(nRec)  
Return(lRet)