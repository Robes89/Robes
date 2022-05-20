#INCLUDE "rwmake.ch"

// Rotina		: CARTCONG
// Descrição	: Carteira Congelada
// Data			: 11/04/05
// Autor        : Daniel Gondran

User Function CARTD()

// mv_par01 - Mes
// mv_par02 - Ano

//cPerg := "CARTC2"
cPerg    := PadR( 'CARTC2' , Len( SX1->X1_GRUPO ) )

AjustaSX1()

Pergunte(cPerg,.F.)

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Carteira Congelada"
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

mesano := MV_PAR02 + MV_PAR01

If mesano <= GetMv("MV_CARTCONG")
	Alert("Mes / Ano já congelado - Não pode congelar novamente")
	Return
Endif
PutMV( "MV_CARTCONG" , mesano )        

dbselectarea("SC5")                       
DBGOTOP()
//x5 := "\SIGAADV\S5"+mv_par02+mv_par01+".DBF"
//copy to x5
x5 := "S5"+mv_par02+mv_par01+".DBF"
//copy to &(x5)
//COPY TO &(x5) VIA "DBFCDXADS"

dbselectarea("SC6")
DBGOTOP()
//x6 := "\SIGAADV\S6"+mv_par02+mv_par01+".DBF"
//copy to x6
x6 := "S6"+mv_par02+mv_par01+".DBF"
//copy to x6
//COPY TO &(x6) VIA "DBFCDXADS"

oTemptable := FWTemporaryTable():New( "TR5")
oTempTable:Create()

//dbUseArea(.T.,"DBFCDX","S5"+mv_par02+mv_par01+".DBF","TR5",.T.,.F.)
dbSelectArea("TR5")
//cTrbTR5 := CriaTrab(,.F.)
//IndRegua("TR5",cTrbTR5,"C5_FILIAL+C5_NUM",,,"SC5...")


oTemptable := FWTemporaryTable():New( "TR6")
oTempTable:Create()

//dbUseArea(.T.,"DBFCDX","S6"+MV_PAR02+MV_PAR01+".DBF","TR6",.T.,.F.)
dbSelectArea("TR6")
//cTrbTR6 := CriaTrab(,.F.)
//IndRegua("TR6",cTrbTR6,"C6_FILIAL+C6_NUM+C6_ITEM",,,"SC6...")

dbSelectArea("TR5")
ProcRegua(LastRec())
dbGotop()
Do While !Eof()
	IncProc()
	
	dbSelectArea("TR6")
	dbSeek(xFilial("SC6") + TR5->C5_NUM)
	lGravou := .F.
	do While !Eof() .and. C6_FILIAL == xFilial("SC6") .and. C6_NUM == TR5->C5_NUM
		If C6_QTDENT < C6_QTDVEN
			lGravou := .T.
			dbSelectArea("SZ6")
			dbSetOrder(2)
			lAchou := dbSeek(xFilial("SZ6") + mesano + Dtos(TR6->C6_ENTREG) + TR6->C6_NUM + TR6->C6_ITEM)
			RecLock("SZ6",!lAchou)
			Z6_FILIAL 	:= TR6->C6_FILIAL
			Z6_MESANO 	:= mesano
			Z6_PRODUTO	:= TR6->C6_PRODUTO
			Z6_CODLMT	:= TR6->C6_CODLMT
			Z6_NUM		:= TR6->C6_NUM
			Z6_ITEM		:= TR6->C6_ITEM
			Z6_CLI		:= TR6->C6_CLI
			Z6_LOJA		:= TR6->C6_LOJA
			Z6_QTDVEN	:= TR6->C6_QTDVEN
			Z6_QTDENT	:= TR6->C6_QTDENT
			Z6_PRCVEN	:= TR6->C6_PRCVEN
			Z6_BLQ		:= TR6->C6_BLQ
			Z6_ENTREG	:= TR6->C6_ENTREG
			Z6_TES		:= TR6->C6_TES
			msUnlock()
		Endif
		dbselectArea("TR6")
		dbSkip()
	Enddo
	If lGravou
		dbSelectArea("SZ7")
		dbSetOrder(2)
		lAchou := dbSeek(xFilial("SZ7") + mesano + TR5->C5_NUM)
		RecLock("SZ7",!lAchou)
		Z7_FILIAL 	:= TR5->C5_FILIAL
		Z7_MESANO 	:= mesano
		Z7_STPAD	:= TR5->C5_STPAD
		Z7_NUM		:= TR5->C5_NUM
		Z7_EMISSAO	:= TR5->C5_EMISSAO
		Z7_NOMEVEN	:= TR5->C5_NOMEVEN
		Z7_NOMECLI	:= TR5->C5_NOMECLI
		Z7_MOEDA	:= TR5->C5_MOEDA
		msUnlock()
	Endif
	dbSelectArea("TR5")
	dbSkip()
Enddo

// *----------------------------------------------------------------------------
Static Function AjustaSX1()
aPerg    := {}
cPerg    := PadR( 'CARTC2' , Len( SX1->X1_GRUPO ) )

Aadd( aPerg , { "Mes Referência      ?" , "C" , 02 , "   "})
Aadd( aPerg , { "Ano Referencia      ?" , "C" , 04 , "   "})

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
