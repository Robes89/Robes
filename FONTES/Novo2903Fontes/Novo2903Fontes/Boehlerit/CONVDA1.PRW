#INCLUDE "rwmake.ch"       

// Rotina		: CONVDA1
// Descrição	: Conversor SB1 -> DA1
// Data			: 28/12/04
// Autor        : Daniel Gondran

User Function CONVDA1()
SET SOFTSEEK ON
//cPerg 	 := "CONDA1"
 cPerg    := PadR( 'CONDA1' , Len( SX1->X1_GRUPO ) )

AjustaSX1()
ccTabela := "001"

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Conversor DA1"
@ 70,080 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
@ 70,118 BMPBUTTON TYPE 1 ACTION OkProc()
@ 70,156 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
@ 23,14 SAY "O objetivo desta rotina é ler o cadastro de " size 200,10
@ 33,14 SAY "Produtos e gerar a tabela de preço  "         size 200,10
@ 43,14 SAY " "
@ 8,10 TO 060,180
ACTIVATE DIALOG oDlg5 CENTERED
Return
// *******************************************************************************************************************
Static Function OkProc()
Close(oDlg5)       
Processa({|| GeraMov() } , "Gerando Registros..." )
Return
// *******************************************************************************************************************
Static Function GeraMov()

/*
lContinua := .F.               
dbSelectArea("DA0")
dbSetOrder(1)
If dbSeek(xFilial("DA0") + mv_par01)
	If MsgBox("Tabela " + mv_par01 + " já existe! Sobrescreve?","Atenção","YESNO")
		lContinua := .T.
	Endif
Else
	lContinua := .T.
Endif
     
If lContinua
	dbSelectArea("DA0")
	RecLock("DA0",.T.)
	DA0_FILIAL  := xFilial("DA0")
	DA0_CODTAB  := mv_par01
	DA0_DESCRI  := "IMP SB1" + DTOC(dDataBase)
	DA0_DATDE   := dDataBase
	DA0_HORADE  := "00:00"
	DA0_DATATE  := mv_par02
	DA0_HORATE  := "23:59"
	DA0_TPHORA  := "1"
	DA0_ATIVO   := "1"
	msUnlock()
*/	
nItem := 0
dbSelectArea("DA1")
dbSetOrder(3)
dbSeek(xFilial("DA1") + ccTabela)
do While !Eof() .and. DA1_FILIAL == xFilial() .and. DA1_CODTAB == ccTabela
	nItem := Val(DA1_ITEM)
	dbSkip()
Enddo
nItem++
//Alert (StrZero(nItem,4))
  
dbSelectArea("SB1")
dbSetOrder(4)
dbSeek(xFilial("SB1") + mv_par03)
ProcRegua(LastRec())
do While !Eof() .and. xFilial()==B1_FILIAL .and. B1_GRUPO<=mv_par04
	IncProc(B1_GRUPO)
	cForn := Left(B1_COD,2)
	If B1_TRANSPR > 0 .and. B1_GRUPO >= mv_par03 .and. B1_GRUPO <= mv_par04 .and. cForn >= mv_par01 .and. cForn <= mv_par02
	 	RecLock("SB1",.F.)
	 	B1_PRV1 := B1_TRANSPR
	 	msUnlock()
		dbSelectArea("DA1")
		dbSetOrder(1)
		lAchou := dbSeek(xFilial("DA1") + ccTabela + SB1->B1_COD)
		RecLock("DA1",!lAchou)
		DA1_FILIAL := xFilial("DA1")
		If !lAchou
			DA1_ITEM   := StrZero(nItem,4)
			nItem++
		Endif
		DA1_CODTAB := "001"
		DA1_CODPRO := SB1->B1_COD
		DA1_CODLMT := SB1->B1_CODLMT
		DA1_PRCVEN := SB1->B1_TRANSPR 
		DA1_VLRDES := 0
		DA1_PERDES := 0
		DA1_ATIVO  := "1"
		DA1_FRETE  := 0
		DA1_TPOPER := "4"
		DA1_QTDLOT := 999999.99
		DA1_INDLOT := "000000000999999.99"
		DA1_MOEDA  := 1
		DA1_DATVIG := Ctod("31/12/05")
		msUnlock()
	Endif
	dbSelectArea("SB1")
	dbSkip()
Enddo        
dbSelectArea("SB1")
dbSetOrder(1)
SET SOFTSEEK OFF
Return

// *--------------------------------------------------------------------------------------

Static Function AjustaSX1()
aPerg    := {}
//cPerg    := "CONDA1"

Aadd( aPerg , { "Fornecedor De     ?" , "C" , 02 , 0}) //  6
Aadd( aPerg , { "Fornecedor Ate    ?" , "C" , 02 , 0}) //  7
Aadd( aPerg , { "Grupo De          ?" , "C" , 04 , 0}) //  8
Aadd( aPerg , { "Grupo Ate         ?" , "C" , 04 , 0}) //  9

For nXX := 1 to Len( aPerg )
	If !SX1->( DbSeek( cPerg + StrZero( nXX , 2 ) ) ) 
		RecLock( "SX1" , .T. )
		SX1->X1_GRUPO     := cPerg
		SX1->X1_ORDEM     := StrZero( nXX , 2 )
		SX1->X1_PERGUNT   := aPerg[nXX][1]
		SX1->X1_VARIAVL   := "mv_ch" + Str( nXX , 1 )
		SX1->X1_TIPO      := aPerg[nXX][2]
		SX1->X1_TAMANHO   := aPerg[nXX][3]
		SX1->X1_DECIMAL	  := aPerg[nXX][4]
		SX1->X1_PRESEL    := 1
		SX1->X1_GSC       := "G"
		SX1->X1_VAR01     := "mv_par" + StrZero( nXX , 2 )
		SX1->(MsUnlock())
	EndIf
Next nXX
Return Nil