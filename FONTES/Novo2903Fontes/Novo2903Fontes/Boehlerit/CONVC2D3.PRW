User Function ConvC2D3

dbSelectArea("SC2")
dbSetOrder(1)
dbGotop()
do While !Eof()
	If Left(C2_NUM,1) == "K"
		dbSelectArea("SD3")
		dbSetOrder(1)
		If dbSeek(xFilial("SD3") + "0" + Substr(SC2->C2_NUM,2) + SC2->C2_ITEM + SC2->C2_SEQUEN+"  ",.F.)
			do WhILE !EOF() .AND.  "0" + Substr(SC2->C2_NUM,2) + SC2->C2_ITEM + SC2->C2_SEQUEN+"  " == D3_OP
				RecLock("SD3",.F.)
				D3_OP := "K" + SUBSTR(D3_OP,2)
				D3_DOC:= "K" + SUBSTR(D3_DOC,2)
				msUnlock()
				dbSkip()
			Enddo
		Endif
	Endif
	dbSelectArea("SC2")
	dbSkip()
Enddo
Alert("Concluido")
Return