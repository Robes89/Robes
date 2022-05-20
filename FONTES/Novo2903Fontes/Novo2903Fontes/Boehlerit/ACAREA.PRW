#INCLUDE "rwmake.ch"       

// Rotina		: ACAREA
// Descrição	: Acerta area de acordo com a região e vendedor cad. clientes
// Data			: 28/04/05
// Autor        : Daniel Gondran

User Function ACAREA()

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Acerta Area"
@ 70,118 BMPBUTTON TYPE 1 ACTION OkProc()
@ 70,156 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
@ 23,14 SAY " " size 200,10
@ 33,14 SAY " " size 200,10
@ 43,14 SAY " "
@ 8,10 TO 060,180
ACTIVATE DIALOG oDlg5 CENTERED
Return
*******************************************************************************************************************
Static Function OkProc()
Close(oDlg5)       
Processa({|| GeraMov() } , "Processando..." )
Return
*******************************************************************************************************************
Static Function GeraMov()
dbSelectArea("SA1")
dbSetOrder(1)
dbGotop()
do While !Eof()         
	C3:=A1_REGIAO	
	IF A1_VEND=="000016"
		C4 := "5"
	ElseIf A1_VEND =="000017"
		C4 := "6"
	ElseIf A1_VEND $ "000008/000011/000004/000001/000005/000003/000009/000006"
		C4 := "1"
	ElseIf A1_VEND $ "000018/000007"
		C4 := "2"
	ElseIf A1_VEND $ "000020/000014/000012/000013/000015"
		C4 := "4"
	Else
		C4 := "4"
	Endif
	lAchou := .F.
	dbSelectArea("SD2")
	dbSetOrder(9)
	dbSeek(xFilial("SD2") + SA1->A1_COD + SA1->A1_LOJA)
	do While !Eof() .and. SA1->A1_COD + SA1->A1_LOJA == SD2->D2_CLIENTE + SD2->D2_LOJA
		If Year(D2_EMISSAO) == 2004 .and. Substr(D2_CF,2,3) $ "111,112,108,102,101,949,110,109"
			lAchou := .T.
			Exit
		Endif
		dbSkip()
	Enddo
	If lAchou
		C5 := "X"
	Else
		C5 := "N"
	Endif
	cArea := C3+C4+C5
    dbSelectArea("SA1")
    RecLock("SA1",.F.)
    A1_AREA := cArea
    msUnlock()
    dbSkip()
Enddo

Return