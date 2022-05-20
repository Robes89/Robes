#INCLUDE "rwmake.ch"       

// Rotina		: REAJUSTE	
// Descrição	: Reajuste de precos
// Data			: 28/12/04
// Autor        : Daniel Gondran       

// MV_PAR01 = Fator Transf Price -> aplicado no B1_TRANSPR e no B1_PREURO
// MV_PAR02 = Fator Preco Venda  -> aplicado no B1_PRLISTA e no DA1_PRCVEN (B1_PRLISTA inibido em 14/06/05)
// MV_PAR03 = Fator Preco Minimo -> aplicado no B1_PRV1


User Function REAJUSTE()

//cPerg := "REAJUS"
 cPerg    := PadR( 'REAJUS' , Len( SX1->X1_GRUPO ) )

AjustaSX1()

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Reajuste de Precos"
@ 70,080 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
@ 70,118 BMPBUTTON TYPE 1 ACTION OkProc()
@ 70,156 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
@ 23,14 SAY "O objetivo desta rotina é efetuar o reajuste" size 200,10
@ 33,14 SAY "de Precos"         size 200,10
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
ccTabela := "001"
dbSelectArea("SB1")
dbSetOrder(4)

dbSeek(xFilial("SB1") + Left(mv_par06,4))
ProcRegua(LastRec())
nCont:=0
do While !Eof() .and. B1_FILIAL == xFilial("SB1") .and. B1_GRUPO <= Left(mv_par07,4)
	IncProc()
	cForn := Left(B1_COD,2)
	If cForn >= mv_par04 .and. cForn <= mv_par05 .and. Iif(Empty(mv_par08),.T.,B1_CLASSEP == mv_par08)
		nTP := B1_TRANSPR
		nEU := B1_PREURO
		RecLock("SB1",.F.)
		If mv_par01 > 0
			B1_TRANSPR := nTP * IIF(mv_par01>0,mv_par01,1) 
			B1_PREURO  := nEU * IIF(mv_par01>0,mv_par01,1) 
		Endif
		If mv_par01 <0
			B1_PREURO  := nTP / (1-(B1_DESCONT/100))
		Endif
		If mv_par03 > 0
			B1_PRV1    := nTP * IIF(mv_par01>0,mv_par01,1) * IIF(mv_par03>0,mv_par03,1)
		Endif
		msUnlock()
		dbSelectArea("DA1")
		dbSetOrder(1)
		If dbSeek(xFilial("DA1") + ccTabela + SB1->B1_COD) .AND. mv_par02 > 0
			RecLock("DA1",.F.) 
			DA1_PRCVEN := nTP * IIF(mv_par01>0,mv_par01,1) * IIF(mv_par02>0,mv_par02,1)
			msUnlock()
		Endif     
		/*
		dbSelectArea("SB1")
		RecLock("SB1",.F.) 
		B1_PRLISTA := DA1->DA1_PRCVEN
		msUnlock()
		*/
		nCont ++
    Endif 
    dbSelectArea("SB1")
	dbSkip()
Enddo
Alert ("Registros processados : " + Str(nCont,6))
Return
// *--------------------------------------------------------------------------------------
Static Function AjustaSX1()
aPerg    := {}
//cPerg    := "REAJUS"

Aadd( aPerg , { "Fator Transf Price?" , "N" , 11 , 6}) 
Aadd( aPerg , { "Fator Preco Venda ?" , "N" , 11 , 6}) 
Aadd( aPerg , { "Fator Preco Minimo?" , "N" , 11 , 6}) 
Aadd( aPerg , { "Fornecedor De     ?" , "C" , 02 , 0}) 
Aadd( aPerg , { "Fornecedor Ate    ?" , "C" , 02 , 0}) 
Aadd( aPerg , { "Grupo De          ?" , "C" , 04 , 0}) 
Aadd( aPerg , { "Grupo Ate         ?" , "C" , 04 , 0}) 
Aadd( aPerg , { "Classe Preco      ?" , "C" , 03 , 0}) 
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
		SX1->(MsUnLock())
	EndIf
Next nXX
Return Nil