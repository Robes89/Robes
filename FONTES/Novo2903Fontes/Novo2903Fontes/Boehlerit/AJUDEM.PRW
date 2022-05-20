#INCLUDE "rwmake.ch"       

// Rotina		: AJUDEM
// Descrição	: Importa custo

User Function AJUDEM()

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
aStru := {}
aAdd(aStru,{"COD"    ,"C",15,0})
aAdd(aStru,{"CUSTO"  ,"N",10,2})




oTemptable := FWTemporaryTable():New( "TRC")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"COD"} )
oTempTable:Create()

            
IndRegua("TRC",cTrb,"COD",,,"Aguarde...")
dbSetIndex(cTrb+OrdBagExt())


oTemptableB := FWTemporaryTable():New( "TRD")
oTemptableB:SetFields( aStru )
oTempTableB:AddIndex("index1", {"COD"} )
oTempTableB:Create()
            
IndRegua("TRD",cTrb,"COD",,,"Aguarde...")
dbSetIndex(cTrb+OrdBagExt())


//dbUseArea(.T.,"DBFCDX","\SIGAADV\CUSDEM.DBF","TRB",.T.,.F.)

dbSelectArea("TRB")


dbSelectArea("TRC")
Append From TRB
Set SoftSeek Off

dbSelectArea("SB6")  
DBSETORDER(1)
ProcRegua(LastRec())
dbGotop()
do While !Eof()
	IncProc()
	If B6_SERIE == "XXX"
		dbSelectArea("TRC")
		If dbSeek(SB6->B6_PRODUTO)
			dbSelectArea("SB6")
			RecLock("SB6",.F.)
			SB6->B6_CUSTO1 := TRC->CUSTO
			msUnlock()
		Else
			dbSelectArea("TRD")
			If !dbSeek(SB6->B6_PRODUTO)
				RecLock("TRD",.T.)
				TRD->COD := SB6->B6_PRODUTO
				msUnlock()
			Endif
		Endif
	Endif
	dbSelectArea("SB6")
	dbSkip()
Enddo
		
dbSelectArea("TRD")
//Copy to \sigaadv\SEMDEM.DBF Via "DBFCDXADS" 		
		

TRB->(DBCLOSEAREA())
TRC->(DBCLOSEAREA())
TRD->(DBCLOSEAREA())
Return
