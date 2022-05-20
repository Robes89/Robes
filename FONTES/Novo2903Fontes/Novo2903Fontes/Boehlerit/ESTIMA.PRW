#INCLUDE "rwmake.ch"

// Rotina		: ESTIMA
// Descrição	: Relatório Pedidos estimados que viraram Simples
// Data			: 02/10/06
// Autor        : Daniel Gondran

User Function ESTIMA()

// mv_par01 - Data ini    
// mv_par02 - Data fim   

//cPerg := "ESTIMX"
 cPerg    := PadR( 'ESTIMX' , Len( SX1->X1_GRUPO ) )
AjustaSX1()
Pergunte(cPerg,.F.)

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Relatório Pedidos Estimados p/ Simples"
@ 70,080 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
@ 70,118 BMPBUTTON TYPE 1 ACTION OkProc()
@ 70,156 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
@ 23,14 SAY "Emite a relação dos pedidos Estimados que foram transformados " size 200,10
@ 33,14 SAY "em Simples" size 200,10
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
aAdd(aStru,{"PEDIDOS"    ,"C",06,0})
aAdd(aStru,{"PEDIDOE"    ,"C",06,0})
aAdd(aStru,{"ITEM"       ,"C",02,0})
aAdd(aStru,{"PRODUTO"    ,"C",15,0})
aAdd(aStru,{"CLIENTE"    ,"C",30,0})
aAdd(aStru,{"CODLMT"     ,"C",46,0})
aAdd(aStru,{"EMIORIG"    ,"D",08,0})
aAdd(aStru,{"ALTERA"     ,"D",08,0})
aAdd(aStru,{"QTDORIG"    ,"N",14,4})
aAdd(aStru,{"PRCORIG"    ,"N",14,4})
aAdd(aStru,{"TOTORIG"    ,"N",14,2})
aAdd(aStru,{"TITULO1"    ,"C",80,0})
aAdd(aStru,{"TITULO2"    ,"C",80,0})

oTemptable := FWTemporaryTable():New( "TRC")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"PEDIDOS+ITEM"} )
oTempTable:Create()

/*
cArq := CriaTrab(aStru,.T.)
dbUseArea(.T.,,cArq,"TRC",.T.)
cInd := CriaTrab(NIL,.F.)
IndRegua("TRC",cInd,"PEDIDOS+ITEM",,,"Selecionando Registros...")
*/
ar:={"A","A","A","A","A","A","R","A","A","A","A","A"}
aimpos := {0.690421,0,0.69633}
mtit1    := "Periodo : de " + dtoc(mv_par01) + " a " + dtoc(mv_par02)

dbselectarea("SC5")
dbGotop()
dbSetOrder(2)
dbSeek(xFilial("SC5") + dtos(mv_par01))
ProcRegua(500)

DO WHILE !EOF() .AND. C5_FILIAL == xFilial("SC5") .and. C5_EMISSAO <= mv_par02 
	IncProc()
	dAltera	:= SC5->C5_EMISSAO
	dbSelectArea("SC6")
	dbSetOrder(1)
	dbSeek(xFilial("SC6") + SC5->C5_NUM)
	do While !Eof() .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == SC5->C5_NUM
		If !Empty(SC6->C6_NUMPEDP)
			dbSelectArea("SC5")
			xrec5 := SC5->(RECNO())
			xrec6 := SC6->(RECNO())
			XITEM := SC6->C6_ITEMPE
			XPED  := SC6->C6_NUM
			dbSetOrder(1)
			dbSeek(xFilial("SC5") + SC6->C6_NUMPEDP)
			If SC5->C5_STPAD == "E"
				dbSelectArea("SA1")
				dbSetOrder(1)
				dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI)
				dbSelectArea("SB1")
				dbSetOrder(1)
				dbSeek(xFilial("SB1") + SC6->C6_PRODUTO)
				dbSelectArea("SC6")
				dbSetOrder(1)
				dbSeek(xFilial("SC6") + SC5->C5_NUM + XITEM)
								
				
				RecLock( "TRC" , .T.)
				PEDIDOE := SC5->C5_NUM
				PEDIDOS := XPED
				ITEM	:= SC6->C6_ITEM
				PRODUTO	:= SC6->C6_PRODUTO
				CLIENTE := SC6->C6_CLI + " - " + SA1->A1_NREDUZ
				CODLMT	:= SB1->B1_CODLMT
				EMIORIG	:= SC5->C5_EMISSAO
                ALTERA  := dAltera
				QTDORIG	:= SC6->C6_QTDVEN
				PRCORIG	:= SC6->C6_PRCVEN
				TOTORIG	:= SC6->C6_VALOR  // * aimpos[val(SC6->C6_ITEM)]
				TITULO1 := mTit1
				TRC->( MsUnLock() )
			Endif
			dbSelectArea("SC5")
			dbSetORder(2)
			dbGoto(xRec5)
			dbSelectArea("SC6")
			dbGoto(xRec6)
		Endif
		dbSelectArea("SC6")
		dbSkip()
	Enddo      
	dbSelectArea("SC5")
	dbSkip()
Enddo

ferase("\DADOSADV\_ESTIM.DBF")
dbselectarea("TRC")
dbgotop()
//COPY TO "\DADOSADV\_ESTIM.DBF"VIA "DBFCDXADS"
Processa({||CpyS2T("\DADOSADV\_ESTIM.DBF","C:\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
Processa({||CpyS2T("\DADOSADV\_ESTIM.DBF","C:\WINDOWS\TEMP\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
//Processa({||CpyS2T("\DADOSADV\_LOG.DBF","C:\INST\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
//ferase("\DADOSADV\_LOG.DBF")
TRC->(DBCLOSEAREA())
mTESTE := "1;0;1;GIS"  // "EM DISCO;ATUALIZA;1 COPIA;NOME REL."
CALLCRYS("ESTIMA",,mTESTE)

//Set SoftSeek Off
Return

// *----------------------------------------------------------------------------
Static Function AjustaSX1()
aPerg    := {}
//cPerg    := "ESTIMX"

Aadd( aPerg , { "Data Emissao Ini    ?" , "D" , 08 , "   "})
Aadd( aPerg , { "Data Emissao Fim    ?" , "D" , 08 , "   "})

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
		SX1->(MsUnlock())
	EndIf
Next nXX
Return Nil
