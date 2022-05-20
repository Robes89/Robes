#INCLUDE "rwmake.ch"       

// Rotina		: ESTOQUE
// Descrição	: Le o inventário
// Data			: 14/01/05
// Autor        : Daniel Gondran

User Function ESTOQUE()

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Estoque"
@ 70,118 BMPBUTTON TYPE 1 ACTION OkProc()
@ 70,156 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
@ 23,14 SAY "O objetivo desta rotina é ler a planilha de " size 200,10
@ 33,14 SAY "Inventário e gravar na tabela de Saldos" size 200,10
@ 43,14 SAY "Iniciais (SB9) "  size 200,10
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
aAdd(aStru,{"CODKIN"    ,"N",06,0})
aAdd(aStru,{"COD"       ,"C",15,0})
aAdd(aStru,{"CODLMT"    ,"C",46,0})
aAdd(aStru,{"ESTOQUE"   ,"N",14,3})
aAdd(aStru,{"TOTAL"     ,"N",14,2})
aAdd(aStru,{"CODIGOK"   ,"C",01,0})

oTemptable := FWTemporaryTable():New( "TRC")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"COD"} )
oTempTable:Create()

//cArq := CriaTrab(aStru,.T.)
//dbUseArea(.T.,,cArq,"TRC",.T.)
//cInd := CriaTrab(NIL,.F.)
IndRegua("TRC",cArq,"COD",,,"Aguarde...")
//dbSetIndex(cArq+OrdBagExt())


oTemptable := FWTemporaryTable():New( "TRB")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"COD"} )
oTempTable:Create()

//dbUseArea(.T.,"DBFCDX","\SIGAADV\ESTOQUE.DBF","TRB",.T.,.F.)
dbSelectArea("TRB")
cTrb := 'ALIAS'               
IndRegua("TRB",cTrb,"COD",,,"Aguarde...")
//dbSetIndex(cTrb+OrdBagExt())

dbSelectArea("TRC")
Append From TRB
set softseek off
dbGotop()
ProcRegua(LastRec())
do While !Eof()
	IncProc()
	dbSelectArea("SB1")
	dbSetOrder(1)
	If Left(TRC->COD,2) == "ZZ"
	    If dbSeek(xFilial("SB1") + Left(TRC->COD,15))
			RecLock("SB1",.F.)
			B1_CODKIN := StrZero(TRC->CODKIN,7)
			B1_TIPO   := "PA"
			B1_UM	  := "PC"
			B1_LOCPAD := "01"
			B1_MCUSTD := "1"
			B1_UREV   := Ctod ("31/12/04")
			B1_DATREF := Ctod ("31/12/04")
			msUnlock()	
		
			dbSelectArea("SB9")
			RecLock("SB9",.T.)
        	B9_FILIAL  := xFilial("SB9")
    	    B9_COD	   := TRC->COD
	       	B9_LOCAL   := "01"					//"02"
    	    B9_DATA    := CTOD("31/12/2004")
	        B9_QINI    := TRC->ESTOQUE
        	B9_VINI1   := TRC->TOTAL // /100
    	    B9_MCUSTD  := "1"
	        B9_CODLMT  := SB1->B1_CODLMT
			msUnlock()
		
		Else
			RecLock("SB1",.T.)
			B1_FILIAL := "01"
			B1_COD 	  := TRC->COD
			B1_CODLMT := TRC->CODLMT
			B1_CODKIN := StrZero(TRC->CODKIN,7)
			B1_TIPO   := "PA"
			B1_UM	  := "PC"
			B1_LOCPAD := "01"
			B1_MCUSTD := "1"
			B1_UREV   := Ctod ("31/12/04")
			B1_DATREF := Ctod ("31/12/04")
			msUnlock()	
		
			dbSelectArea("SB9")
			RecLock("SB9",.T.)
        	B9_FILIAL  := xFilial("SB9")
    	    B9_COD	   := TRC->COD
	       	B9_LOCAL   := "01"					//"02"
    	    B9_DATA    := CTOD("31/12/2004")
	        B9_QINI    := TRC->ESTOQUE
        	B9_VINI1   := TRC->TOTAL  // /100
    	    B9_MCUSTD  := "1"
	        B9_CODLMT  := SB1->B1_CODLMT
			msUnlock()		
		Endif	
	Else	
	    If dbSeek(xFilial("SB1") + Left(TRC->COD,15))
			RecLock("SB1",.F.)
			B1_CODKIN := StrZero(TRC->CODKIN,7)
			msUnlock()	
		
			dbSelectArea("SB9")
			RecLock("SB9",.T.)
	        B9_FILIAL  := xFilial("SB9")
    	    B9_COD	   := TRC->COD
        	B9_LOCAL   := "01"					//"02"
	        B9_DATA    := CTOD("31/12/2004")
    	    B9_QINI    := TRC->ESTOQUE
        	B9_VINI1   := TRC->TOTAL   //   /100
	        B9_MCUSTD  := "1"
    	    B9_CODLMT  := SB1->B1_CODLMT
			msUnlock()
		Else
			dbSelectArea("TRC")
			RecLock("TRC",.F.)
			CODIGOK := "N"
			msUnlock()
		Endif
	Endif
	dbSelectArea("TRC")
	dbSkip()
Enddo    

dbSelectArea("TRC")
//copy to \SIGAADV\ESTOK.DBF Via "DBFCDXADS" 	
	
TRB->(DBCLOSEAREA())
TRC->(DBCLOSEAREA())
Return
