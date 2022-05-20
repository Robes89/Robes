#INCLUDE "rwmake.ch"       

// Rotina		: CONVSA12
// Descrição	: Importa area

User Function CONVSA1()

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Atualiza SA1"
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
aStru := {}
aAdd(aStru,{"A1_COD"    ,"C",06,0})
aAdd(aStru,{"A1_LOJA"   ,"C",02,0})
aAdd(aStru,{"A1_AREA"   ,"C",06,0})

oTemptable := FWTemporaryTable():New( "TRC")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"A1_COD+A1_LOJA"} )
oTempTable:Create()

/*
cArq := CriaTrab(aStru,.T.)
dbUseArea(.T.,,cArq,"TRC",.T.)
cInd := CriaTrab(NIL,.F.)
IndRegua("TRC",cArq,"A1_COD+A1_LOJA",,,"Aguarde...")
dbSetIndex(cArq+OrdBagExt())
*/

//dbUseArea(.T.,"DBFCDX","\SIGAADV\SA1.DBF","TRB",.T.,.F.)
//dbSelectArea("TRB")
//cTrb := CriaTrab(,.F.)                
//IndRegua("TRB",cTrb,"A1_COD+A1_LOJA",,,"Aguarde...")
//dbSetIndex(cTrb+OrdBagExt())


dbSelectArea("TRC")
Append From TRB
Set SoftSeek Off

dbGotop()
chave := ""
ProcRegua(LastRec())     
kkk:=1
do While !Eof() 
	kkk++
	IncProc()
	dbSelectArea("SA1")
	dbSetOrder(1)
	If dbSeek(xFilial("SA1") + TRC->A1_COD + TRC->A1_LOJA)
		RecLock("SA1",.F.)
		IF !EMPTY(TRC->A1_AREA)
			A1_AREA   := TRC->A1_AREA
		Endif
		msUnlock()
	Endif
	dbSelectArea("TRC")
	dbSkip()
Enddo


TRB->(DBCLOSEAREA())
TRC->(DBCLOSEAREA())
Return
