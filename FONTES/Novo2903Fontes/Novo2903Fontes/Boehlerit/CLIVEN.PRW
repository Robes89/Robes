#INCLUDE "rwmake.ch"

// Rotina		: CLIVEN
// Descrição	: Relatório Clientes por Vendedor
// Data			: 06/06/06
// Autor        : Daniel Gondran

User Function CLIVEN()

// mv_par01 - Cliente Inicial
// mv_par02 - Cliente Final
// mv_par03 - Vendedor Inicial
// mv_par04 - Vendedor Final
// mv_par05 - Sintetico / Analitico

//cPerg := "CLIVEN"
 cPerg    := PadR( 'CLIVEN' , Len( SX1->X1_GRUPO ) )
AjustaSX1()
Pergunte(cPerg,.F.)

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Relatório Clientes por Vendedor"
@ 70,080 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
@ 70,118 BMPBUTTON TYPE 1 ACTION OkProc()
@ 70,156 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
@ 23,14 SAY " " size 200,10
@ 33,14 SAY "" size 200,10
@ 43,14 SAY ""
@ 8,10 TO 060,180
ACTIVATE DIALOG oDlg5 CENTERED

Return

Static Function OkProc()
Close(oDlg5)

Processa( {|| Runproc() } , "Gerando Arquivo" )

Return

//*******************************************************************************( INICIO )
STATIC FUNCTION Runproc()

aStru := {}
aAdd(aStru,{"CODVEN"     ,"C",06,0})
aAdd(aStru,{"NOMEVEN"    ,"C",30,0})
aAdd(aStru,{"CODCLI"     ,"C",06,0})
aAdd(aStru,{"LOJA"       ,"C",02,0})
aAdd(aStru,{"NOMECLI"    ,"C",20,0})
aAdd(aStru,{"RAZAO"      ,"C",40,0})
aAdd(aStru,{"CONTATO"    ,"C",25,0})
aAdd(aStru,{"FONE"       ,"C",15,0})
aAdd(aStru,{"FAX"        ,"C",15,0})
aAdd(aStru,{"ENDERECO"   ,"C",99,0})
aAdd(aStru,{"CIDADE"     ,"C",30,0})
aAdd(aStru,{"UF"		 ,"C",02,0})
aAdd(aStru,{"CGC"        ,"C",18,0})
aAdd(aStru,{"TITULO1"    ,"C",20,0})
aAdd(aStru,{"TITULO2"    ,"C",20,0})

oTemptable := FWTemporaryTable():New( "TRC")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"CODVEN+CODCLI+LOJA"} )
oTempTable:Create()

//cArq := CriaTrab(aStru,.T.)
//dbUseArea(.T.,,cArq,"TRC",.T.)
//cInd := CriaTrab(NIL,.F.)
//IndRegua("TRC",cInd,"CODVEN+CODCLI+LOJA",,,"Selecionando Registros...")

dbSelectArea("SA1")
dbSetOrder(1)
dbSelectArea("SA3")
dbSetOrder(1)

dbselectarea("SA1")
dbSeek(xFilial("SA1") + mv_par01,.T.)
ProcRegua(LastRec())
DO WHILE !EOF() .AND. SA1->A1_FILIAL == xFilial("SA1") .and. SA1->A1_COD <= mv_par02 
	IncProc()
	dbSelectArea("SA3")
	dbSeek(xFilial("SA3") + SA1->A1_VEND)
	IF SA3->A3_COD >= mv_par03 .and. SA3->A3_COD <= mv_par04
		dbSelectArea("TRC")
		RecLock( "TRC" , .T.)
		CODVEN	:= SA3->A3_COD
		NOMEVEN := SA3->A3_NREDUZ
		CODCLI	:= SA1->A1_COD
		LOJA	:= SA1->A1_LOJA
		NOMECLI := SA1->A1_NREDUZ
		RAZAO	:= SA1->A1_NOME
		CONTATO	:= SA1->A1_CONTATO
		FONE	:= SA1->A1_TEL
		FAX		:= SA1->A1_FAX
		If	mv_par05 == 1				// analitico
			ENDERECO:= Trim(SA1->A1_END) + " - " + TRIM(SA1->A1_BAIRRO) + " - " + Trim(SA1->A1_MUN) + " - " + SA1->A1_EST + " - " + Left(SA1->A1_CEP,5) + "-" + Right(SA1->A1_CEP,3)
		Else
			ENDERECO:= SA1->A1_END
			CIDADE	:= SA1->A1_MUN
			UF		:= SA1->A1_EST
		EndIf
		CGC		:= Transform(SA1->A1_CGC,PesqPict( "SA1" , "A1_CGC" ))
		TRC->( MsUnLock() )
	Endif
	dbSelectArea("SA1")
	dbSkip()
Enddo

ferase("\DADOSADV\CLIV.DBF")
dbselectarea("TRC")
dbgotop()
//COPY TO "\DADOSADV\CLIV.DBF" VIA "DBFCDXADS"
Processa({||CpyS2T("\DADOSADV\CLIV.DBF","C:\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
ferase("\DADOSADV\CLIV.DBF")
TRC->(DBCLOSEAREA())
mTESTE := "1;0;1;GIS"  // "EM DISCO;ATUALIZA;1 COPIA;NOME REL."
If mv_par05 == 1
	CALLCRYS("CLIVA",,mTESTE)
Else
	CALLCRYS("CLIVS",,mTESTE)
Endif	
Return

// *----------------------------------------------------------------------------
Static Function AjustaSX1()
aPerg    := {}
//cPerg    := "CLIVEN"

Aadd( aPerg , { "Cliente Inicial     ?" , "C" , 06 , "SA1"})
Aadd( aPerg , { "Cliente Final       ?" , "C" , 06 , "SA1"})
Aadd( aPerg , { "Vendedor Inicial    ?" , "C" , 06 , "SA3"})
Aadd( aPerg , { "Vendedor Final      ?" , "C" , 06 , "SA3"})
Aadd( aPerg , { "Analitico/Sintetico ?" , "N" , 01 , "   "})

For nXX := 1 to Len( aPerg )
	If !SX1->( DbSeek( cPerg + StrZero( nXX , 2 ) ) )
		RecLock( "SX1" , .T. )
		SX1->X1_GRUPO   := cPerg
		SX1->X1_ORDEM   := StrZero( nXX , 2 )
		SX1->X1_PERGUNT := aPerg[nXX][1]
		SX1->X1_VARIAVL := "mv_ch" + Str( nXX , 1 )
		SX1->X1_TIPO    := aPerg[nXX][2]
		SX1->X1_TAMANHO := aPerg[nXX][3]
		SX1->X1_PRESEL  := 1
		SX1->X1_GSC     := "G"
		SX1->X1_VAR01   := "mv_par" + StrZero( nXX , 2 )
		SX1->X1_F3		:= aPerg[nxx][4]
		If nxx == 5 .OR. nxx >= 9
			SX1->X1_GSC   := "C"
			SX1->X1_DEF01 := "Analitico"
			SX1->X1_DEF02 := "Sintetico"
		Endif
		SX1->(msUnlock())
	EndIf		
Next nXX
Return Nil
