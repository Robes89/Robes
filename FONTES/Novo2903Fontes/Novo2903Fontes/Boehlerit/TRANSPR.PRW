#INCLUDE "rwmake.ch"       

// Rotina		: IMPCLAES
// Descrição	: Importa Transf Price

User Function TRANSPR()

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Atualiza o campo B1_TRANSPR"
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
aAdd(aStru,{"B1_COD"     ,"C",15,0})
aAdd(aStru,{"B1_LOJA"    ,"C",02,0})
aAdd(aStru,{"B1_TRANSPR" ,"N",16,4})

oTemptable := FWTemporaryTable():New( "TRC")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"B1_COD+B1_LOJA"} )
oTempTable:Create()

//cArq := CriaTrab(aStru,.T.)
//dbUseArea(.T.,,cArq,"TRC",.T.)
//cInd := CriaTrab(NIL,.F.)
//IndRegua("TRC",cArq,"B1_COD+B1_LOJA",,,"Aguarde...")
//dbSetIndex(cArq+OrdBagExt())



oTemptable := FWTemporaryTable():New( "TRB")
//oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"B1_COD+B1_LOJA"} )
oTempTable:Create()

//dbUseArea(.T.,"DBFCDX","\SIGAADV\TRANSPR.DBF","TRB",.T.,.F.)
//dbSelectArea("TRB")
//cTrb := CriaTrab(,.F.)                
//IndRegua("TRB",cTrb,"B1_COD+B1_LOJA",,,"Aguarde...")
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
	dbSelectArea("SB1")
	dbSetOrder(1)
	If dbSeek(xFilial("SB1") + TRC->B1_COD + TRC->B1_LOJA)
		RecLock("SB1",.F.)
		  SB1->B1_TRANSPR   := TRC->B1_TRANSPR
		msUnlock()
	Endif
	dbSelectArea("TRC")
	dbSkip()
Enddo


TRB->(DBCLOSEAREA())
TRC->(DBCLOSEAREA())
Return
