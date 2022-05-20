#INCLUDE "rwmake.ch"       

User Function BBH()

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Confere Preços Boehlerit"
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
Processa({|| GeraMov() } , "Gerando Registros..." )
Return
*******************************************************************************************************************
Static Function GeraMov()
aStru := {}
aAdd(aStru,{"CODLMT"    ,"C",46,0})
aAdd(aStru,{"PREURO"    ,"N",14,2})
aAdd(aStru,{"DESCONT"  ,"N",14,2})
aAdd(aStru,{"TRANSPR"   ,"N",14,2})


oTemptable := FWTemporaryTable():New( "TRC")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"CODLMT"} )
oTempTable:Create()
/*
cArq := CriaTrab(aStru,.T.)
dbUseArea(.T.,,cArq,"TRC",.T.)
cInd := CriaTrab(NIL,.F.)
IndRegua("TRC",cArq,"CODLMT",,,"Aguarde...")
dbSetIndex(cArq+OrdBagExt())
*/

oTemptable := FWTemporaryTable():New( "TRB")
oTempTable:Create()
/*
dbUseArea(.T.,"DBFCDX","\SIGAADV\BBH.DBF","TRB",.T.,.F.)
dbSelectArea("TRB")
cTrb := CriaTrab(,.F.)                
IndRegua("TRB",cTrb,"CODLMT",,,"Aguarde...")
dbSetIndex(cTrb+OrdBagExt())
*/
dbSelectArea("TRC")
Append From TRB
set softseek off
dbSelectArea("SB1")
dbGotop()
chave := ""
ProcRegua(LastRec())
do While !Eof()
	IncProc()
	dbSelectArea("TRC")
	dbSeek(Trim(StrTran(StrTran(SB1->B1_CODLMT," ",""),"-","")))
	If Found() 
		//Alert (B1_CODLMT)
		RecLock("SB1",.F.)
		B1_PREURO  := TRC->PREURO
		B1_DESCONT := TRC->DESCONT
		B1_TRANSPR := TRC->TRANSPR
		msUnlock()
	Endif
	dbSelectArea("SB1")
	dbSkip()
Enddo
set softseek off	
TRB->(DBCLOSEAREA())
TRC->(DBCLOSEAREA())
Return
