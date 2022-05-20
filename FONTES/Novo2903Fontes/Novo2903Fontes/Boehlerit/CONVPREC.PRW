#INCLUDE "rwmake.ch"       

// Rotina		: CONVPREC
// Descrição	: Importa precos
// Data			: 14/06/05
// Autor        : Daniel Gondran

User Function CONVPREC()

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Alteração de Precos"
@ 70,118 BMPBUTTON TYPE 1 ACTION OkProc()
@ 70,156 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
@ 23,14 SAY "Le dados do arquivo \SIGAADV\SIGA12.DBF e atualiza a  " size 200,10
@ 33,14 SAY "tabela de Precos e o Cadastro de Produtos do Microsiga" size 200,10
@ 43,14 SAY "ATENCAO : o nome do campo de preco é B1_PRV1 "
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
aAdd(aStru,{"B1_PRV1"   ,"N",16,4})                                   


oTemptable := FWTemporaryTable():New( "TRC")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"B1_COD"} )
oTempTable:Create()

/*
cArq := CriaTrab(aStru,.T.)
dbUseArea(.T.,,cArq,"TRC",.T.)
cInd := CriaTrab(NIL,.F.)
IndRegua("TRC",cArq,"B1_COD",,,"Aguarde...")
dbSetIndex(cArq+OrdBagExt())
*/


oTemptable := FWTemporaryTable():New( "TRB")
//oTemptable:SetFields( aStru )
//oTempTable:AddIndex("index1", {"COD"} )
oTempTable:Create()

/*
dbUseArea(.T.,"DBFCDX","\SIGAADV\SIGA12.DBF","TRB",.T.,.F.)
dbSelectArea("TRB")
cTrb := CriaTrab(,.F.)                
IndRegua("TRB",cTrb,"B1_COD",,,"Aguarde...")
dbSetIndex(cTrb+OrdBagExt())
*/

dbSelectArea("TRC")
Append From TRB
Set SoftSeek Off

dbGotop()
chave := ""
cTabela := "001"
ProcRegua(LastRec())     
kkk:=1
do While !Eof() 
	kkk++
	IncProc()
	dbSelectArea("SB1")
	dbSetOrder(1)
	If dbSeek(xFilial("SB1") + TRC->B1_COD)
		RecLock("SB1",.F.)
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
		IF !EMPTY(TRC->B1_PRV1)
			B1_PRV1     := TRC->B1_PRV1
		Endif	
		msUnlock()
		dbSelectArea("DA1")
		dbSetOrder(1)
		dbSeek(xFilial("DA1") + cTabela + SB1->B1_COD)
		If !EMPTY(TRC->B1_PRV1)
			RecLock("DA1",.F.)
			DA1_PRCVEN  := TRC->B1_PRV1
			msUnlock()
		Endif	
	Endif
	dbSelectArea("TRC")
	dbSkip()
Enddo


TRB->(DBCLOSEAREA())
TRC->(DBCLOSEAREA())
Return
