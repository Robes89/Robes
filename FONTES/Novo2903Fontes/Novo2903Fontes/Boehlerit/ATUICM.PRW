User Function ATUICM()
	dbSelectArea("SD2")
	dbGotop()
	do While !Eof()
		If D2_TES $ "509/518/519/526/541"
			If D2_VALICM == 0
				dbSelectArea("SF2")
				dbSetOrder(1)
				dbSeek(xFilial("SF2") + SD2->D2_DOC + SD2->D2_SERIE)
				dbSelectArea("SB1")
				dbSetOrder(1)
				dbSeek(xFilial("SB1") + SD2->D2_COD)
				dbSelectArea("SD2")
				cNorte := GetMV("MV_NORTE")
				If SF2->F2_EST $ cNorte
					nIcms := 7
				ElseIf SF2->F2_EST == "SP"
					If SB1->B1_PICM > 0
						nIcms := SB1->B1_PICM
					Else
						nIcms := 18
					Endif
				Else
					nIcms := 12
				Endif
				RecLock("SD2",.F.)
				Replace D2_VALICM With D2_TOTAL * (nIcms / 100)
				msUnlock()
			Endif
		Endif
		dbSelectArea("SD2")
		dbSkip()
	Enddo
Return