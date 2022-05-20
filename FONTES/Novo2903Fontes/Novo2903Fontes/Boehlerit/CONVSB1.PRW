#INCLUDE "rwmake.ch"       

// Rotina		: CONVSB1
// Descrição	: Conversor SB1 LMT
// Data			: 02/10/04
// Autor        : Daniel Gondran

User Function CONVSB1()

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Importa cadastro de produtos"
@ 70,118 BMPBUTTON TYPE 1 ACTION OkProc()
@ 70,156 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
@ 23,14 SAY "O objetivo desta rotina é ler o banco de dados " size 200,10
@ 33,14 SAY "LMT.DBF, originado do Excel e gravar no Cadastro" size 200,10
@ 43,14 SAY "de produtos do Microsiga (SB1)"
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
aAdd(aStru,{"B1_CODISO" ,"C",30,0})
aAdd(aStru,{"B1_CLASSE" ,"C",70,0})
aAdd(aStru,{"B1_EDP"    ,"C",10,6})
aAdd(aStru,{"B1_CODLMT" ,"C",46,0})
aAdd(aStru,{"B1_DESC"   ,"C",30,0})
aAdd(aStru,{"B1_DENOM"  ,"C",58,0})
aAdd(aStru,{"B1_GRUPO"  ,"C",04,0})
aAdd(aStru,{"B1_STATUS" ,"C",04,0})
aAdd(aStru,{"B1_GRUPDES","C",04,0})
aAdd(aStru,{"FORN"      ,"C",02,0})
aAdd(aStru,{"SE"        ,"C",01,0}) 
aAdd(aStru,{"B1_FILIAL" ,"C",02,0})
aAdd(aStru,{"B1_TIPO"   ,"C",02,0})
aAdd(aStru,{"B1_UM"     ,"C",02,0})
aAdd(aStru,{"B1_LOCPAD" ,"C",02,0})
aAdd(aStru,{"B1_ORIGEM" ,"C",01,0})
aAdd(aStru,{"B1_PREURO" ,"N",12,2})
aAdd(aStru,{"B1_GRFAB"  ,"C",04,0})
aAdd(aStru,{"B1_DESCONT","N",06,2})
aAdd(aStru,{"B1_TRANSPR","N",16,2})
aAdd(aStru,{"B1_IPI"    ,"N",05,2})                                   
aAdd(aStru,{"B1_PICM"   ,"N",05,2})                                   
aAdd(aStru,{"B1_CLASSEP","C",01,0})
aAdd(aStru,{"B1_POSIPI" ,"C",10,0})
aAdd(aStru,{"COD_KIN"   ,"C",10,0})               

oTemptable := FWTemporaryTable():New( "TRC")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"FORN+B1_GRUPO+SE"} )
oTempTable:Create()

//cArq := CriaTrab(aStru,.T.)
//dbUseArea(.T.,,cArq,"TRC",.T.)
//cInd := CriaTrab(NIL,.F.)
///IndRegua("TRC",cArq,"FORN+B1_GRUPO+SE",,,"Aguarde...")
//dbSetIndex(cArq+OrdBagExt())

//dbUseArea(.T.,"DBFCDX","\SIGAADV\LMT.DBF","TRB",.T.,.F.)
//dbSelectArea("TRB")
//cTrb := CriaTrab(,.F.)                
////IndRegua("TRB",cTrb,"FORN+B1_GRUPO+SE",,,"Aguarde...")
//dbSetIndex(cTrb+OrdBagExt())

dbSelectArea("TRC")
Append From TRB

dbGotop()
chave := ""
ProcRegua(LastRec())
do While !Eof()
	IncProc()
	If FORN + B1_GRUPO + SE <> chave
		chave := FORN + B1_GRUPO + SE
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1") + chave + "9",.T.)
		dbSkip(-1)
		If Left(B1_COD,7) == chave
			nSeq := Val(Substr(B1_COD,8))
		Else
			nSeq := 1
		Endif
	Endif

	cCodigo := TRC->FORN + TRC->B1_GRUPO + TRC->SE + StrZero(nSeq,8)
	dbSelectArea("SB1")
	do while dbSeek(xFilial("SB1") + cCodigo,.F.)
		nSeq++
		cCodigo := TRC->FORN + TRC->B1_GRUPO + TRC->SE + StrZero(nSeq,8)
	Enddo
	dbSelectArea("TRC")
	RecLock("TRC",.F.)
	B1_COD := cCodigo
	msUnlock()
	nSeq++
	dbSkip()
Enddo

dbSelectArea("TRC") 
dbGotop()
ProcRegua(LastRec())
do While !Eof()
	If !Empty(B1_CODLMT)
		IncProc()
		dbSelectArea("SB1")
		dbSetOrder(1)
		lAchou := dbSeek(xFilial("SB1") + TRC->B1_COD)
		If lAchou
			Alert("Atencao : COD " + TRC->B1_COD + " <- " + TRC->B1_CODLMT + " ja existente. Nao foi importado")
			dbselectArea("TRC")	
			dbskip()
			loop
		Endif
		dbSetOrder(9)
		lAchou := dbSeek(xFilial("SB1") + TRC->B1_CODLMT)
		If lAchou
			Alert("Atencao : COD " + TRC->B1_COD + " -> " + TRC->B1_CODLMT + " ja existente. Nao foi importado")
			dbselectArea("TRC")	
			dbskip()
			loop
		Endif
		RecLock("SB1",!lAchou)
		B1_COD 		:= TRC->B1_COD 
		B1_CODISO   := TRC->B1_CODISO
		B1_CLASSE   := TRC->B1_CLASSE
		B1_EDP      := TRC->B1_EDP
		B1_CODLMT   := TRC->B1_CODLMT
		B1_DESC     := TRC->B1_DESC
		B1_DENOM    := TRC->B1_DENOM
		B1_GRUPO    := TRC->B1_GRUPO
		B1_STATUS   := TRC->B1_STATUS
		B1_GRUPDES  := TRC->B1_GRUPDES
		B1_FILIAL   := xFilial("SB1")
		B1_TIPO     := TRC->B1_TIPO
		B1_UM       := TRC->B1_UM 
		B1_LOCPAD   := TRC->B1_LOCPAD 
		B1_ORIGEM   := TRC->B1_ORIGEM
//		B1_PREURO   := IIF(TRC->B1_DESCONT == 0 , TRC->B1_TRANSPR , TRC->B1_TRANSPR / ((100-TRC->B1_DESCONT)/100))
		B1_PREURO   := TRC->B1_PREURO 
        B1_GRFAB	:= TRC->B1_GRFAB
        B1_TRANSPR	:= TRC->B1_PREURO - (TRC->B1_PREURO * TRC->B1_DESCONT /100)
        B1_DESCONT	:= TRC->B1_DESCONT
        B1_IPI		:= TRC->B1_IPI
        B1_PICM	    := TRC->B1_PICM
        B1_POSIPI   := AllTrim(TRC->B1_POSIPI)
        B1_CLASSEP  := AllTrim(TRC->B1_CLASSEP)
        B1_CODKIN   := StrZero(Val(TRC->COD_KIN),7)
                
		IF substr(B1_cod,1,2)=="BO"
			B1_FABRIC   := "BOHLERIT"
	 	ElseIf substr(B1_cod,1,2)=="BR"
			B1_FABRIC   := "LMT - BRASIL"
	 	ElseIf substr(B1_cod,1,2)=="FE"
			B1_FABRIC   := "FETTE" 
	 	ElseIf substr(B1_cod,1,2)=="KI"
			B1_FABRIC   := "KIENINGER"
		Endif
		
		msUnlock()
		dbSelectArea("TRC")
		RecLock("TRC",.F.)
		MIGR := "S"
		msUnlock()
	Endif
	dbSkip()
Enddo
	
TRB->(DBCLOSEAREA())
TRC->(DBCLOSEAREA())
Return
