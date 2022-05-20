#INCLUDE "rwmake.ch"       

// Rotina		: LETRA
// Descrição	: Pega a letra da Classe de Preco
// Data			: 04/01/05
// Autor        : Daniel Gondran

User Function LETRA()

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Converte Letra"
@ 70,118 BMPBUTTON TYPE 1 ACTION OkProc()
@ 70,156 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
@ 23,14 SAY "O objetivo desta rotina é ler a planilha de     " size 200,10
@ 33,14 SAY "Precos e colocar a letra (Alloy Surcharge Class)" size 200,10
@ 43,14 SAY "na Classe de Precos do cad. de produtos"          size 200,10
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
aAdd(aStru,{"EDP"       ,"C",07,0})
aAdd(aStru,{"PRECO"     ,"N",14,2})
aAdd(aStru,{"GRUPDES"   ,"C",03,0})
aAdd(aStru,{"DESC"      ,"N",06,2})
aAdd(aStru,{"LETRA"     ,"C",03,0})
aAdd(aStru,{"CODIGOK"   ,"C",01,0})

oTemptable := FWTemporaryTable():New( "TRC")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"EDP"} )
oTempTable:Create()

//cArq := CriaTrab(aStru,.T.)
//dbUseArea(.T.,,cArq,"TRC",.T.)
//cInd := CriaTrab(NIL,.F.)
IndRegua("TRC",cArq,"EDP",,,"Aguarde...")
//dbSetIndex(cArq+OrdBagExt())

oTemptable := FWTemporaryTable():New( "TRB")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"EDP"} )
oTempTable:Create()

oTemptable := FWTemporaryTable():New( "TRB")
oTempTable:Create()
//dbUseArea(.T.,"DBFCDX","\SIGAADV\LETRA.DBF","TRB",.T.,.F.)
dbSelectArea("TRB")
cTrb := 'TaB'              
IndRegua("TRB",cTrb,"EDP",,,"Aguarde...")
dbSetIndex(cTrb+OrdBagExt())

dbSelectArea("TRC")
Append From TRB
set softseek off
dbGotop()
chave := ""
dbSelectArea("SB1")
ProcRegua(LastRec())
do While !Eof()
	IncProc()
	dbSelectArea("TRC")
//  If dbSeek(SB1->B1_CODLMT + space(39-Len(SB1->B1_CODLMT)))
	If dbSeek(Left(SB1->B1_CODLMT,7))
		RecLock("TRC",.F.)
		CODIGOK := "S"
		msUnlock()	
		dbSelectArea("SB1")
		RecLock("SB1",.F.)
        B1_PREURO  := TRC->PRECO
		B1_CLASSEP := TRC->LETRA
		B1_DESCONT := TRC->DESC
		B1_GRUPDES := TRC->GRUPDES     
		
		B1_TRANSPR := IIF( TRC->DESC == 0 , TRC->PRECO , TRC->PRECO - (TRC->PRECO * (TRC->DESC / 100)) )
		msUnlock()
	Endif
	dbSelectArea("SB1")
	dbSkip()
Enddo
	       
dbSelectArea("TRC")
//copy to \SIGAADV\LETRAOK.DBF Via "DBFCDXADS" 	
	
TRB->(DBCLOSEAREA())
TRC->(DBCLOSEAREA())
Return
