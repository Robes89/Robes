#INCLUDE "rwmake.ch"

// Rotina		: FRANSB6
// Descrição	: Gera comparativo entre (SB6 e SD1) e (SB6 e SD2)

User Function FRANSB6()

cPerg := PadR( "FRANBX" , Len( SX1->X1_GRUPO ) )

AjustaSX1()

Pergunte(cPerg,.F.)


@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Compara SB6"
@ 70,080 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
@ 70,118 BMPBUTTON TYPE 1 ACTION OkProc()
@ 70,156 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
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

aStru := {}
aAdd(aStru,{"DOC"    ,"C",06,0})
aAdd(aStru,{"SERIE"  ,"C",03,0})
aAdd(aStru,{"CLIFOR" ,"C",06,0})
aAdd(aStru,{"LOJA"   ,"C",02,0})
aAdd(aStru,{"PRODUTO","C",15,0})
aAdd(aStru,{"CODLMT" ,"C",46,0})
aAdd(aStru,{"IDENT"  ,"C",06,0})
aAdd(aStru,{"ENTSAI" ,"C",01,0})
aAdd(aStru,{"EMISSAO","D",08,0})
aAdd(aStru,{"QTDNOTA","N",14,2})
aAdd(aStru,{"QTDTERC","N",14,2})

oTemptable := FWTemporaryTable():New( "TRC")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"DOC+SERIE+CLIFOR+LOJA+PRODUTO+IDENT+ENTSAI"} )
oTempTable:Create()

//cArq := CriaTrab(aStru,.T.)
//dbUseArea(.T.,,cArq,"TRC",.T.)
//cTrb := CriaTrab(,.F.)                
//IndRegua("TRC",cTrb,"DOC+SERIE+CLIFOR+LOJA+PRODUTO+IDENT+ENTSAI",,,"Aguarde...")
//dbSetIndex(cTrb+OrdBagExt())


/*
dbSelectArea("SB6")
DBSETORDER(1)
ProcRegua(LastRec())
dbGotop()
do While !Eof()
	IncProc("SB6")
	IF SB6->B6_TES $ "038/039/040/045"
		dbSelectArea("SD1")
		dbSetOrder(1)
		If !dbSeek(xFilial("SD1") + SB6->B6_DOC + SB6->B6_SERIE + SB6->B6_CLIFOR + SB6->B6_LOJA + SB6->B6_PRODUTO,.F.)
			dbSelectArea("TRC")
			If !dbSeek(SB6->B6_DOC + SB6->B6_SERIE + SB6->B6_CLIFOR + SB6->B6_LOJA + SB6->B6_PRODUTO + "E",.F.)
				RecLock("TRC",.T.)
				DOC		:= SB6->B6_DOC
				SERIE	:= SB6->B6_SERIE
				CLIFOR	:= SB6->B6_CLIFOR
				LOJA	:= SB6->B6_LOJA
				PRODUTO	:= SB6->B6_PRODUTO
				ENTSAI  := "E"				
				msUnlock()
			Endif
		Endif
	Endif
				

	IF SB6->B6_TES $ "508/510/543"
		dbSelectArea("SD2")
		dbSetOrder(3)
		If !dbSeek(xFilial("SD2") + SB6->B6_DOC + SB6->B6_SERIE + SB6->B6_CLIFOR + SB6->B6_LOJA + SB6->B6_PRODUTO,.F.)
			dbSelectArea("TRC")
			If !dbSeek(SB6->B6_DOC + SB6->B6_SERIE + SB6->B6_CLIFOR + SB6->B6_LOJA + SB6->B6_PRODUTO + "S",.F.)
				RecLock("TRC",.T.)
				DOC		:= SB6->B6_DOC
				SERIE	:= SB6->B6_SERIE
				CLIFOR	:= SB6->B6_CLIFOR
				LOJA	:= SB6->B6_LOJA
				PRODUTO	:= SB6->B6_PRODUTO
				ENTSAI  := "S"
				msUnlock()
			Endif
		Endif
	Endif
	dbSelectArea("SB6")
	dbSkip()
Enddo
*/

dbSelectArea("SB6")
cIndex  := 'B6_DOC'
cKey    := "B6_DOC + B6_SERIE + B6_CLIFOR + B6_LOJA + B6_PRODUTO + B6_IDENT"
IndRegua("SB6",cIndex,cKey,,,"Criando indice")
nIndex := RetIndex("SB6")   
dbSetOrder(nIndex+1)         

dbSelectArea("SD2")
dbSetOrder(5)
dbSeek(xFilial("SD2") + dtos(mv_par01),.T.)
ProcRegua(LastRec())
do While !Eof() .and. D2_EMISSAO <= mv_par02
	IncProc("SD2")
	If D2_CLIENTE < mv_par03 .or. D2_CLIENTE > mv_par04
		dbSkip()
		Loop
	Endif
	If D2_TES $ "508/510/543"
		dbSelectArea("SB6")
		If !dbSeek(SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA + SD2->D2_COD + SD2->D2_IDENTB6) //.OR. SD2->D2_QUANT <> SB6->B6_QUANT
			dbSelectArea("TRC")
			If !dbSeek(SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA + SD2->D2_COD + SD2->D2_IDENTB6 + "S",.F.) //.OR. SD2->D2_QUANT <> SB6->B6_QUANT
				RecLock("TRC",.T.)
				DOC		:= SD2->D2_DOC
				SERIE	:= SD2->D2_SERIE
				CLIFOR	:= SD2->D2_CLIENTE
				LOJA	:= SD2->D2_LOJA
				PRODUTO	:= SD2->D2_COD
				CODLMT  := SD2->D2_CODLMT
				IDENT	:= SD2->D2_IDENTB6
				ENTSAI  := "S"
				EMISSAO	:= SD2->D2_EMISSAO
				QTDNOTA := SD2->D2_QUANT
				QTDTERC := SB6->B6_QUANT
				msUnlock()
			Endif
		Endif
	Endif
	dbSelectArea("SD2")
	dbSkip()
Enddo

dbSelectArea("SD1")
dbSetOrder(6)
dbSeek(xFilial("SD1") + dtos(mv_par01),.T.)
ProcRegua(LastRec())
do While !Eof() .and. D1_DTDIGIT <= mv_par02
	IncProc("SD1")
	If D1_FORNECE < mv_par03 .or. D1_FORNECE > mv_par04     
		dbSkip()
		Loop
	Endif
	If D1_TES $ "038/039/040/045"
		dbSelectArea("SB6")
		If !dbSeek(SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_COD + SD1->D1_IDENTB6) //.OR. SD1->D1_QUANT <> SB6->B6_QUANT
			dbSelectArea("TRC")
			If !dbSeek(SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE+ SD1->D1_LOJA + SD1->D1_COD + SD1->D1_IDENTB6 + "E",.F.) //.OR. SD1->D1_QUANT <> SB6->B6_QUANT
				RecLock("TRC",.T.)
				DOC		:= SD1->D1_DOC
				SERIE	:= SD1->D1_SERIE
				CLIFOR	:= SD1->D1_FORNECE
				LOJA	:= SD1->D1_LOJA
				PRODUTO	:= SD1->D1_COD
				CODLMT  := SD1->D1_CODLMT				
				IDENT	:= SD1->D1_IDENTB6
				ENTSAI  := "E"
				EMISSAO	:= SD1->D1_DTDIGIT
				QTDNOTA := SD1->D1_QUANT
				QTDTERC := SB6->B6_QUANT
				msUnlock()
			Endif
		Endif
	Endif
	dbSelectArea("SD1")
	dbSkip()
Enddo
	
dbSelectArea("TRC")
dbGotop()
ferase("\DADOSADV\difer.dbf")
//Copy to \dadosadv\difer.dbf FOR DOC<>"089988" .AND. DOC<>"090166" Via "DBFCDXADS" 
Processa({||CpyS2T("\DADOSADV\difer.dbf","C:\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
TRC->(dbCloseArea())
Return


// *----------------------------------------------------------------------------
Static Function AjustaSX1()
aPerg    := {}
cPerg    := PadR( "FRANBX" , Len( SX1->X1_GRUPO ) )

Aadd( aPerg , { "Data de             ?" , "D" , 08 , "   "})
Aadd( aPerg , { "Data ate            ?" , "D" , 08 , "   "})
Aadd( aPerg , { "Cliente de          ?" , "C" , 06 , "SA1"})
Aadd( aPerg , { "Cliente ate         ?" , "C" , 06 , "SA1"})

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

