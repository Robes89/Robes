//--------------------------------------------------------------------------
// Pto Entrada : SF2460I
// Descricao   : Cabecalho Nota Fiscal Saida
//--------------------------------------------------------------------------

User Function MT100GE2()                        

_aSvAlias       := {Alias(),IndexOrd(),Recno()}
oldInd := SB6->(IndexOrd())
oldRec := SB6->(Recno())

dbSelectArea("SD1")
dbSetOrder(1)
dbSeek(xFilial("SD1") + SF1->F1_DOC)
do While !Eof() .and. D1_FILIAL == xFilial("SD1") .and. D1_DOC == SF1->F1_DOC
	dbSelectArea("SB6")
	dbSetOrder(4)
	If dbSeek(xFilial("SB6") + SD1->D1_IDENTB6 + SD1->D1_COD)
		Do While !Eof() .and. xFilial("SB6") == B6_FILIAL .and. B6_IDENTB6 == SD1->D1_IDENTB6 .AND. B6_PRODUTO == SD1->D1_COD
			dbSelectArea("SB1")
			dbSetOrder(9)
			If dbSeek(xFilial("SB1") + SD2->D2_COD)
				dbSelectArea("SB6")
				RecLock("SB6",.F.)
				B6_CODLMT := SB1->B1_CODLMT
				msUnlock()
			Endif
			dbSelectArea("SB6")
			dbSkip()
		Enddo
	Endif
	dbSelectArea("SD1")
	dbSkip()
Enddo

// Retorna Area de Trabalho
SB6->(dbSetOrder(oldInd))
SB6->(dbGoto(oldRec))

DbSelectArea(_aSvAlias[1])
DbSetOrder(_aSvAlias[2])
DbGoTo(_aSvAlias[3])

Return