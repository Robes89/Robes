#INCLUDE "rwmake.ch"

// Rotina		: AJUSB6
// Descrição	: Acerta Custo do SB6 se estiver zerado

User Function AJUSB6()

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Atualiza SB6"
@ 70,118 BMPBUTTON TYPE 1 ACTION OkProc()
@ 70,156 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
@ 8,10 TO 060,180
ACTIVATE DIALOG oDlg5 CENTERED
Return
*******************************************************************************************************************
Static Function OkProc()
Close(oDlg5)
Processa({|| GeraMov() } , "Gerando Registros..." )
Return
*******************************************************************************************************************
Static Function GeraMov()
dbSelectArea("SB6")
DBSETORDER(1)
ProcRegua(LastRec())
dbGotop()
do While !Eof()
	IncProc()
	dbSelectArea("SB9")
	dbSetOrder(1)
	IF SB6->B6_CUSTO1 == 0 .AND. DTOS(SB6->B6_EMISSAO) >= "20050101"
		dbSeek(xFilial("SB9") + SB6->B6_PRODUTO + "01" + dtos(CTOD("01/" + STRZERO(MONTH(SB6->B6_EMISSAO),2) + "/05")),.T.)
		If !Eof() .AND. SB9->B9_QINI <> 0
			dbSelectArea("SB6")
			RecLock("SB6",.F.)
			SB6->B6_CUSTO1 := SB6->B6_QUANT * (SB9->B9_VINI1 / SB9->B9_QINI)
			msUnlock()
		Else
			dbSeek(xFilial("SB9") + SB6->B6_PRODUTO + "02" + dtos(CTOD("01/" + STRZERO(MONTH(SB6->B6_EMISSAO),2) + "/05")),.T.)
			If !Eof() .AND. SB9->B9_QINI <> 0
				dbSelectArea("SB6")
				RecLock("SB6",.F.)
				SB6->B6_CUSTO1 := SB6->B6_QUANT * (SB9->B9_VINI1 / SB9->B9_QINI)
				msUnlock()
			Else
				dbSeek(xFilial("SB9") + SB6->B6_PRODUTO + "01" + dtos(CTOD("01/" + STRZERO(MONTH(SB6->B6_EMISSAO),2) + "/05")),.T.)
				do While !Eof() .and. SB9->B9_COD == SB6->B6_PRODUTO .AND. SB9->B9_QINI == 0
					dbSkip()
				Enddo
				If SB9->B9_COD == SB6->B6_PRODUTO
					dbSelectArea("SB6")
					RecLock("SB6",.F.)
					SB6->B6_CUSTO1 := SB6->B6_QUANT * (SB9->B9_VINI1 / SB9->B9_QINI)
					msUnlock()
				Endif
			Endif
		Endif
	ENDIF
	dbSelectArea("SB6")
	dbSkip()
Enddo
Return
