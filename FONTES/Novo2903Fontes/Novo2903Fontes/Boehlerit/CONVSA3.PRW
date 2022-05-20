#INCLUDE "rwmake.ch"       

// Rotina		: CONVSA3
// Descrição	: Cadastra o vendedor no SA1
// Data			: 16/12/04
// Autor        : Daniel Gondran

User Function CONVSA3()

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Conversor Vendedor"
@ 70,118 BMPBUTTON TYPE 1 ACTION OkProc()
@ 70,156 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
@ 23,14 SAY "O objetivo desta rotina é ler o banco de dados  " size 200,10
@ 33,14 SAY "do sistema KIM e jogar o vendedor no cadastor de" size 200,10
@ 43,14 SAY "Clientes do Microsiga (SA1)"
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
aAdd(aStru,{"VEND"      ,"C",06,0})
aAdd(aStru,{"FANTASIA"  ,"C",30,0})
aAdd(aStru,{"RAZAO"     ,"C",70,0})

oTemptable := FWTemporaryTable():New( "TRC")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"FANTASIA"} )
oTempTable:Create()

//cArq := CriaTrab(aStru,.T.)
//dbUseArea(.T.,,cArq,"TRC",.T.)
//cInd := CriaTrab(NIL,.F.)
//IndRegua("TRC",cArq,"FANTASIA",,,"Aguarde...")
//dbSetIndex(cArq+OrdBagExt())

//dbUseArea(.T.,"DBFCDX","\SIGAADV\VEND.DBF","TRB",.T.,.F.)
//dbSelectArea("TRB")
////cTrb := CriaTrab(,.F.)                
//IndRegua("TRB",cTrb,"FANTASIA",,,"Aguarde...")
//dbSetIndex(cTrb+OrdBagExt())

dbSelectArea("TRC")
Append From TRB
set softseek on
dbGotop()
chave := ""
ProcRegua(LastRec())
do While !Eof()
	IncProc()
	dbSelectArea("SA1")
	dbSetOrder(5)
	dbSeek(xFilial("SA1") + Trim(TRC->FANTASIA) )
	RecLock("SA1",.F.)
	A1_VEND := TRC->VEND
	msUnlock()
	dbSelectArea("TRC")
	dbSkip()
Enddo
set softseek off	
TRB->(DBCLOSEAREA())
TRC->(DBCLOSEAREA())
Return
