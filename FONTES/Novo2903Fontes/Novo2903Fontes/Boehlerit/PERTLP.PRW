#INCLUDE "rwmake.ch"

User Function PERTLP()
Set SoftSeek Off
/*
dbUseArea(.T.,"DBFCDX","\SIGAADV\JULIO.DBF","TRB",.T.,.F.)
dbSelectArea("TRB")
cTrb := CriaTrab(,.F.)                
dbSelectArea("TRB")
DBGOTOP()
Do While !Eof()
	dbSelectArea("SB1")
	dbSetOrder(9)
	If dbSeek(xFilial("SB1") + Trim(TRB->CODLMT))
		RecLock("SB1",.F.)
		B1_PERTLP := "S"
		msUnlock()
	Endif
	dbSelectArea("TRB")
	dbSkip()
Enddo
TRB->(dbCloseArea())

dbUseArea(.T.,"DBFCDX","\SIGAADV\CODLMT.DBF","TRB",.T.,.F.)
dbSelectArea("TRB")
cTrb := CriaTrab(,.F.)                
dbSelectArea("TRB")
DBGOTOP()
Do While !Eof()
	dbSelectArea("SB1")
	dbSetOrder(9)
	If dbSeek(xFilial("SB1") + Trim(TRB->CODLMT))
		RecLock("SB1",.F.)
		B1_PERTLP := "A"
		msUnlock()
	Endif
	dbSelectArea("TRB")
	dbSkip()
Enddo
TRB->(dbCloseArea())


dbUseArea(.T.,"DBFCDX","\SIGAADV\STATUS.DBF","TRB",.T.,.F.)
dbSelectArea("TRB")
cTrb := CriaTrab(,.F.)                
dbSelectArea("TRB")
DBGOTOP()
Do While !Eof()
	dbSelectArea("SB1")
	dbSetOrder(9)
	If dbSeek(xFilial("SB1") + Trim(TRB->CODLMT))
		RecLock("SB1",.F.)
		B1_STATUS := TRB->CSTATUS
		msUnlock()
	Endif
	dbSelectArea("TRB")
	dbSkip()
Enddo
TRB->(dbCloseArea())


/*
dbUseArea(.T.,"DBFCDX","\SIGAADV\CLI.DBF","TRB",.T.,.F.)
dbSelectArea("TRB")
cTrb := CriaTrab(,.F.)                
dbSelectArea("TRB")
DBGOTOP()
Do While !Eof()
	dbSelectArea("SA1")
	dbSetOrder(1)
	If dbSeek(xFilial("SA1") + Trim(TRB->A1_COD) + Trim(TRB->A1_LOJA))
		RecLock("SA1",.F.)
		A1_REGIAO := TRB->A1_REGIAO
		msUnlock()
	Endif
	dbSelectArea("TRB")
	dbSkip()
Enddo
TRB->(dbCloseArea())
*/                  
/*
dbUseArea(.T.,"DBFCDX","\SIGAADVTST\SB19801.DBF","TRB",.T.,.F.)
dbSelectArea("TRB")
cTrb := CriaTrab(,.F.)                
dbSelectArea("TRB")

DBGOTOP()
Do While !Eof()
	dbSelectArea("SB1")
	dbSetOrder(1)
	If !dbSeek(xFilial("SB1") + Trim(TRB->B1_COD))
		aFields := Array(fCount())
		For kkk:=1 to len(afields)
			aFields[kkk] := TRB->(FieldGet(kkk))
		Next
		RecLock("SB1",.T.)
		For kkk:=1 to len(aFields)
			FieldPut(kkk,aFields[kkk])
		Next			
		msUnlock()
	Endif
	dbSelectArea("TRB")
	dbSkip()
Enddo
TRB->(dbCloseArea())
*/


// Importa Custo 31/12/04 KIN
/*
dbUseArea(.T.,"DBFCDX","\SIGAADV\CUSTO.DBF","TRB",.T.,.F.)
dbSelectArea("TRB")
cTrb := CriaTrab(,.F.)                
dbSelectArea("TRB")

DBGOTOP()
Do While !Eof()
	dbSelectArea("SB1")
	dbSetOrder(14)
	If dbSeek(xFilial("SB1") + STRZERO(TRB->KIN,7)) 
		If B1_CUSTO04 == 0
			RecLock("SB1",.F.)
			B1_CUSTO04 := TRB->VALOR
			msUnlock()
		Endif
	Endif
	dbSelectArea("TRB")
	dbSkip()
Enddo
TRB->(dbCloseArea())  
*/  

// Joga custo do B1 para o D2 e D1 2004
dbSelectArea("SD2")
DBGOTOP()
Do While !Eof()
	If Year(D2_EMISSAO) == 2004 .and. D2_SERIE <> "ZZZ"
		dbSelectArea("SB1")
		dbSeek(xFilial("SB1") + SD2->D2_COD)
		dbSelectArea("SD2")
		RecLock("SD2",.F.)
		SD2->D2_CUSTO1 := SB1->B1_CUSTO04 * SD2->D2_QUANT
		msUnlock()
	Endif
	dbSelectArea("SD2")
	dbSkip()
Enddo
Alert("SD1") 
dbSelectArea("SD1")
DBGOTOP()
Do While !Eof()
	If Year(D1_DTDIGIT) == 2004 
		dbSelectArea("SB1")
		dbSeek(xFilial("SB1") + SD1->D1_COD)
		dbSelectArea("SD1")
		RecLock("SD1",.F.)
		SD1->D1_CUSTO := SB1->B1_CUSTO04 * SD1->D1_QUANT
		msUnlock()
	Endif
	dbSelectArea("SD1")
	dbSkip()
Enddo


Return