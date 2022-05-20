#INCLUDE "rwmake.ch"       

// Rotina		: CONVSB2
// Descrição	: Importa codigo KIM
// Data			: 14/03/05
// Autor        : Daniel Gondran

User Function CONVSB2()

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Atualiza SB1"
@ 70,118 BMPBUTTON TYPE 1 ACTION OkProc()
@ 70,156 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
@ 23,14 SAY "Le dados do arquivo \SIGAADV\SIGA12.DBF e atualiza" size 200,10
@ 33,14 SAY "na tabela Cadastro de Produtos do Microsiga" size 200,10
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
aAdd(aStru,{"B1_COD"    ,"C",15,0})
aAdd(aStru,{"B1_DESC"   ,"C",30,0})
aAdd(aStru,{"B1_DENOM"  ,"C",58,0})
aAdd(aStru,{"B1_CODLMT" ,"C",46,0})
aAdd(aStru,{"B1_CODISO" ,"C",30,0})
aAdd(aStru,{"B1_CODKIN" ,"C",11,0})
aAdd(aStru,{"B1_FABRIC" ,"C",20,0})
aAdd(aStru,{"B1_POSIPI" ,"C",10,0})
aAdd(aStru,{"B1_CLASSE" ,"C",10,0})
aAdd(aStru,{"B1_TIPO"   ,"C",02,0})
aAdd(aStru,{"B1_UM"     ,"C",02,0})
aAdd(aStru,{"B1_IPI"    ,"N",05,2})
aAdd(aStru,{"B1_CONTA"  ,"C",20,0})
aAdd(aStru,{"B1_TRANSPR","N",16,4})                                   
aAdd(aStru,{"B1_PREURO" ,"N",16,4})                                   
aAdd(aStru,{"B1_DESCONT","N",08,2})                                   
aAdd(aStru,{"B1_GRUPDES","C",04,0})
aAdd(aStru,{"B1_CLASSEP","C",03,0})
aAdd(aStru,{"B1_GRFAB"  ,"C",04,0})
aAdd(aStru,{"B1_PICM"   ,"N",05,2})
aAdd(aStru,{"B1_LOCPAD" ,"C",02,0})
aAdd(aStru,{"B1_ORIGEM" ,"C",02,0})
aAdd(aStru,{"B1_EDP"    ,"C",10,0})
aAdd(aStru,{"B1_PERTLP" ,"C",01,0})
aAdd(aStru,{"B1_STATUS" ,"C",04,0})
aAdd(aStru,{"B1_PRLISTA","N",16,4})                                   

oTemptable := FWTemporaryTable():New( "TRC")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"B1_COD"} )
oTempTable:Create()


//cArq := CriaTrab(aStru,.T.)
//dbUseArea(.T.,,cArq,"TRC",.T.)
//cInd := CriaTrab(NIL,.F.)
//IndRegua("TRC",cArq,"B1_COD",,,"Aguarde...")
//dbSetIndex(cArq+OrdBagExt())


//dbUseArea(.T.,"DBFCDX","\SIGAADV\SIGA12.DBF","TRB",.T.,.F.)
dbSelectArea("TRB")
//cTrb := CriaTrab(,.F.)                
IndRegua("TRB",cTrb,"B1_COD",,,"Aguarde...")
dbSetIndex(cTrb+OrdBagExt())


dbSelectArea("TRC")
Append From TRB
/*
do While !Eof()
	RecLock("TRC",.F.)
	B1_CODKIN := STRZERO(Val(B1_CODKIN),7)
	msUNlock()
	dbSkip()
Enddo
*/
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
	If dbSeek(xFilial("SB1") + TRC->B1_COD)
		RecLock("SB1",.F.)
		IF !EMPTY(TRC->B1_CODISO)
			B1_CODISO   := TRC->B1_CODISO
		Endif
		IF !EMPTY(TRC->B1_CLASSE)
			B1_CLASSE   := TRC->B1_CLASSE
		Endif
		IF !EMPTY(TRC->B1_EDP)
			B1_EDP      := TRC->B1_EDP
		Endif                         
		IF !EMPTY(TRC->B1_GRUPDES)
			B1_GRUPDES  := TRC->B1_GRUPDES
		Endif                         
		IF !EMPTY(TRC->B1_PREURO)
			B1_PREURO   := TRC->B1_PREURO
		Endif
		IF !EMPTY(TRC->B1_DESCONT)
			B1_DESCONT	:= TRC->B1_DESCONT
		Endif
		IF !EMPTY(TRC->B1_TRANSPR)
			B1_TRANSPR	:= TRC->B1_TRANSPR
		Endif
		IF !EMPTY(TRC->B1_CLASSEP)
			B1_CLASSEP  := AllTrim(TRC->B1_CLASSEP)
		Endif
		IF !EMPTY(TRC->B1_DESC)
			B1_DESC     := TRC->B1_DESC
		Endif
		IF !EMPTY(TRC->B1_DENOM)
			B1_DENOM    := TRC->B1_DENOM
		Endif
		IF !EMPTY(TRC->B1_TIPO)
			B1_TIPO     := TRC->B1_TIPO
		Endif
		IF !EMPTY(TRC->B1_UM)
			B1_UM       := TRC->B1_UM
		Endif
		IF !EMPTY(TRC->B1_LOCPAD)
			B1_LOCPAD   := TRC->B1_LOCPAD
		Endif
		IF !EMPTY(TRC->B1_ORIGEM)
			B1_ORIGEM   := TRC->B1_ORIGEM
		Endif
		IF !EMPTY(TRC->B1_GRFAB)
			B1_GRFAB	:= AllTrim(TRC->B1_GRFAB)
		Endif
		IF !EMPTY(TRC->B1_IPI)
			B1_IPI		:= TRC->B1_IPI
		Endif
		IF !EMPTY(TRC->B1_PICM)
			B1_PICM	    := TRC->B1_PICM
		Endif
		IF !EMPTY(TRC->B1_POSIPI)
			B1_POSIPI   := AllTrim(TRC->B1_POSIPI)
		Endif
		IF !EMPTY(TRC->B1_CODKIN)
			B1_CODKIN   := StrZero(Val(TRC->B1_CODKIN),7)
		Endif	
		IF !EMPTY(TRC->B1_CONTA)
			B1_CONTA   := TRC->B1_CONTA
		Endif	
		IF !EMPTY(TRC->B1_PERTLP)
			B1_PERTLP   := TRC->B1_PERTLP
		Endif	
		IF !EMPTY(TRC->B1_STATUS)
			B1_STATUS   := TRC->B1_STATUS
		Endif	
		IF !EMPTY(TRC->B1_PRLISTA)
			B1_PRLISTA   := TRC->B1_PRLISTA
		Endif	
		
		//		B1_PREURO   := IIF(TRC->B1_DESCONT == 0 , TRC->B1_TRANSPR , TRC->B1_TRANSPR / ((100-TRC->B1_DESCONT)/100))		
		
		msUnlock()
	Endif
	dbSelectArea("TRC")
	dbSkip()
Enddo


TRB->(DBCLOSEAREA())
TRC->(DBCLOSEAREA())
Return
