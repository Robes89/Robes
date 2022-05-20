#include "rwmake.ch"

// Rotina		: IMPINV
// Descrição	: Importação dos arquivos para inventário
// Data			: 01/12/05
// Autor        : Daniel Gondran

User Function IMPINV()

	cPerg    := PadR( 'IMPINV' , Len( SX1->X1_GRUPO ) )
	//cPerg := "IMPINV"

	AjustaSX1()

	Pergunte(cPerg,.F.)

	@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Importação do inventário"
	@ 70,080 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
	@ 70,118 BMPBUTTON TYPE 1 ACTION OkProc()
	@ 70,156 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
	@ 23,14 SAY "Importação da planilha inventário para o microsiga" size 200,10
	@ 33,14 SAY "" size 200,10
	@ 43,14 SAY ""
	@ 8,10 TO 060,180
	ACTIVATE DIALOG oDlg5 CENTERED
Return

Static Function OkProc()
	Close(oDlg5)

	Processa( {|| Runproc() } , "Lendo Arquivo" )


Return

STATIC FUNCTION Runproc()
	aStru := {}
	aAdd(aStru,{"COD"     ,"C",15,0})
	aAdd(aStru,{"LOCAL"   ,"C",02,0})
	aAdd(aStru,{"TIPO"    ,"C",02,0})
	aAdd(aStru,{"DOC"     ,"C",06,2})
	aAdd(aStru,{"QUANT"   ,"N",14,4})
	aAdd(aStru,{"LOTECTL" ,"C",10,0})
	aAdd(aStru,{"LOCALIZ" ,"C",15,0})
	aAdd(aStru,{"CC"      ,"C",09,0})

	oTemptable := FWTemporaryTable():New( "TRB")
	oTemptable:SetFields( aStru )
	oTempTable:AddIndex("index1", {"DOC"} )
	oTempTable:Create()

	//cArq := CriaTrab(aStru,.T.)
	//dbUseArea(.T.,,cArq,"TRB",.T.)
	////cInd := CriaTrab(NIL,.F.)
	//IndRegua("TRB",cInd,"DOC",,,"Selecionando Registros...")

	cFile := "\RELATO\INVENTARIO\IMPORT\" + AllTrim(mv_par01) + ".DBF"

	If !File(cFile)
		Alert ("Arquivo "+Trim(mv_par01)+" nao encontrado na pasta \RELATO\INVENTARIO\IMPORT\! Verifique")
		TRB->(DBCLOSEAREA())
		Return
	Endif

	oTemptable := FWTemporaryTable():New( "TRC")
	oTemptable:SetFields( aStru )
	oTempTable:AddIndex("index1", {"COD"} )
	oTempTable:Create()

	//dbUseArea(.T.,"DBFCDX",cFile,"TRC",.T.,.F.)


	dbSelectArea("TRB")
	Append from TRC
	dbGotop()
	aachou := {}
	While !Eof()
		If !Empty(TRB->COD)
			dbSelectArea("SB7")
			dbSetOrder(1)
			dbSeek(xFilial("SB7") + DTOS(MV_PAR02) + TRB->COD + TRB->LOCAL + TRB->LOCALIZ,.F.)
			While !Eof() .and. SB7->B7_FILIAL == xFilial("SB7") .and. SB7->B7_COD + SB7->B7_LOCAL + SB7->B7_LOCALIZ == TRB->COD + TRB->LOCAL + TRB->LOCALIZ
				If SB7->B7_DOC == TRB->DOC
					aadd(aachou,TRB->COD + " / " + TRB->LOCAL + " / " + TRB->DOC)
					dbSelectArea("SB2")
					dbSetOrder(1)
					If dbSeek(xFilial("SB2") + TRB->COD + TRB->LOCAL) .and. MV_PAR02 <= SB2->B2_DINVENT .AND. !Empty(SB2->B2_DINVENT)
						Alert("Codigo / Local / Documento : " + TRB->COD + " / " + TRB->LOCAL + " / " + TRB->DOC + " já importado em " + dtoc(mv_par02) + " e Inventário já processado. Impossivel continuar. Favor excluir movimento de inventario para esse produto")
						TRB->(DBCLOSEAREA())
						TRC->(DBCLOSEAREA())
						Return
					Endif
					dbSelectArea("SB7")
				Endif
				SB7->(dbSkip())
			Enddo
		Endif
		dbSelectArea("TRB")
		TRB->(dbSkip())
	Enddo

	If Len(aachou) > 0
		For kkk := 1 to len(aachou)
			xOpc := Aviso("Importa inventário","Codigo / Local / Documento : " + aachou[kkk] + " já importado em " + dtoc(mv_par02) + ". Sobrescreve?",{"Sim","Nao"})
			If xOpc == 2
				TRB->(DBCLOSEAREA())
				TRC->(DBCLOSEAREA())
				Return
			Endif
		Next
	Endif

	dbSelectArea("TRB")
	dbGotop()
	While !Eof()
		If !Empty(TRB->COD)
			dbSelectArea("SB1")
			dbSetOrder(1)
			If !dbSeek(xFilial("SB1") + TRB->COD,.F.)
				Alert ("Codigo " + TRB->COD + " não encontrado - impossivel continuar")
				TRB->(DBCLOSEAREA())
				TRC->(DBCLOSEAREA())
				Return
			Endif
//			dbSelectArea("SBE")
//			dbSetOrder(1)
//			If !dbSeek(xFilial("SBE") + TRB->LOCAL + TRB->LOCALIZ)
//				Alert ("Local / Localização " + TRB->LOCAL + " / " + TRB->LOCALIZ + " não encontrado - impossivel continuar")
//				TRB->(DBCLOSEAREA())
//				TRC->(DBCLOSEAREA())
//				Return
//			Endif
			dbSelectArea("SI3")
			dbSetOrder(1)
			If !dbSeek(xFilial("SI3") + Trim(TRB->CC))
				Alert ("Centro de Custo " + TRB->CC + " não encontrado - impossivel continuar")
				TRB->(DBCLOSEAREA())
				TRC->(DBCLOSEAREA())
				Return
			Endif
			dbSelectArea("SB7")
			dbSetOrder(1)
			dbSeek(xFilial("SB7") + DTOS(MV_PAR02) + TRB->COD + TRB->LOCAL + TRB->LOCALIZ,.F.)
			lAchou := .F.
			While !Eof() .and. SB7->B7_FILIAL == xFilial("SB7") .and. SB7->B7_COD + SB7->B7_LOCAL + SB7->B7_LOCALIZ == TRB->COD + TRB->LOCAL + TRB->LOCALIZ
				If SB7->B7_DOC == TRB->DOC
					lAchou 		:= .T.
					RecLock("SB7",.F.)
					B7_QUANT	:= TRB->QUANT
					B7_LOTECTL	:= TRB->LOTECTL
					SB7->(msUnlock())
					Exit
				Endif
				TRB->(dbSkip())
			Enddo
			If !lAchou
				dbSelectArea("SB1")
				dbSetOrder(1)
				dbSeek(xFilial("SB1") + TRB->COD)
				dbSelectArea("SB7")
				RecLock("SB7",.T.)
				B7_FILIAL	:= xFilial("SB7")
				B7_COD		:= TRB->COD
				B7_LOCAL	:= TRB->LOCAL
				B7_TIPO		:= TRB->TIPO
				B7_DOC		:= TRB->DOC
				B7_QUANT	:= TRB->QUANT
				B7_LOTECTL	:= TRB->LOTECTL
				B7_LOCALIZ	:= TRB->LOCALIZ
				B7_CC		:= TRB->CC
				B7_DATA		:= MV_PAR02
				B7_DTVALID	:= DDATABASE
				B7_DESC		:= SB1->B1_DESC + " - " + SB1->B1_UM
				SB7->(msUnlock())
			Endif
		Endif
		dbSelectArea("TRB")
		dbSkip()
	Enddo

	Alert ("Importação concluída com sucesso!")

	TRB->(DBCLOSEAREA())
	TRC->(DBCLOSEAREA())
Return

// *----------------------------------------------------------------------------

Static Function AjustaSX1()
	aPerg    := {}
	//cPerg    := "IMPINV"

	Aadd( aPerg , { "Nome Arquivo      ?" , "C" , 20 })
	Aadd( aPerg , { "Data              ?" , "D" , 08 })

	For nXX := 1 to Len( aPerg )
		If !SX1->( DbSeek( cPerg + StrZero( nXX , 2 ) ) )
			RecLock( "SX1" , .T. )
			SX1->X1_GRUPO     := cPerg
			SX1->X1_ORDEM     := StrZero( nXX , 2 )
			SX1->X1_PERGUNT   := aPerg[nXX][1]
			SX1->X1_VARIAVL   := "mv_ch" + Iif(nXX<10,Str( nXX , 1 ),Chr(87+nXX))
			SX1->X1_TIPO      := aPerg[nXX][2]
			SX1->X1_TAMANHO   := aPerg[nXX][3]
			SX1->X1_PRESEL    := 1
			SX1->X1_GSC       := IF(aPerg[nXX][3]==1,"C","G")
			SX1->X1_VAR01     := "mv_par" + StrZero( nXX , 2 )
			SX1->(MsUnlock())
		Endif
	Next nXX
Return Nil
