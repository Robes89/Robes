#INCLUDE "Protheus.ch"

// Rotina		: ATUSB1
// Descrição	: Atualiza SB1 campos: B1_PRV1, B1_PREURO, B1_TRANSPR com dados CADKI
// Data			: 28/05/07
// Autor        : Ana Maria Izidoro Dias

User Function ATUPRE()

Processa({|| fTela() } , "Atualizando Registros..." )

Return Nil

**********************************************************************************
Static Function fTela()
//Variaveis
nOpca	:= .F.
cArqSB1 := Space(8)
cArqDA1 := Space(8)


DEFINE MSDIALOG oDlg TITLE OemToAnsi("ATUALIZAR PRECO")  FROM 9,0 To 25,68 OF oMainWnd 
@ 1.0, 2 	Say OemToAnsi("ATUALIZAR CADASTRO DE PRODUTOS - ARQUIVO:")
@ 1.0, 18.5	MSGET cArqSB1  Picture "@!" SIZE 70,10 Of oDlg
@ 2.0, 2 	Say OemToAnsi("ATUALIZAR TABELA DE PRECOS - ARQUIVO:") 
@ 2.0, 18.5	MSGET cArqDA1   Picture "@!" SIZE 70,10 Of oDlg
	
DEFINE SBUTTON FROM 052,087.3 TYPE 1 ACTION (nOpca := .T.,oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM 052,114.4 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTERED

If(nOpca)
	//Atualiza cadastro de produtos
	SB1->( DbSetOrder( 1 ) )
	
	oTemptable := FWTemporaryTable():New( "TRB")
	//oTemptable:SetFields( aStru )
	//oTempTable:AddIndex("index1", {"B1_COD"} )
	oTempTable:Create()

	//dbUseArea(.T.,"DBFCDX","\SIGAADV\"+Alltrim(cArqSB1)+".DBF","TRB",.T.,.F.)
	//dbSelectArea("TRB")
	//cTrb := CriaTrab(,.F.)
	//IndRegua("TRB",cTrb,"B1_COD",,,"Aguarde...")
	//dbSetIndex(cTrb+OrdBagExt())
	
	dbSelectArea("TRB")
	dbGotop()
	ProcRegua(LastRec())     
	do While !Eof() 
	    IncProc( "SB1 - Processando produto » " + TRB->B1_COD )
	    dbSelectArea("SB1")
		dbSetOrder(1)
		If dbSeek(xFilial("SB1") + TRB->B1_COD)
			RecLock("SB1",.F.)
			B1_PRV1     := TRB->B1_PRV1
			B1_PREURO   := TRB->B1_PREURO
			B1_TRANSPR	:= TRB->B1_TRANSPR
			msUnlock()
		Endif
		dbSelectArea("TRB")
		dbSkip()
	Enddo
	
	TRB->(DBCLOSEAREA())
	
	
	//Atualiza tabela de precos
	DA1->(DbSetOrder(2))
	
//	dbUseArea(.T.,"DBFCDX","\SIGAADV\"+Alltrim(cArqDA1)+".DBF","TRB",.T.,.F.)
	//dbSelectArea("TRB")
	//cTrb := CriaTrab(,.F.)
	//IndRegua("TRB",cTrb,"DA1_CODPRO",,,"Aguarde...")
	//dbSetIndex(cTrb+OrdBagExt())
	oTemptable := FWTemporaryTable():New( "TRB")
	//oTemptable:SetFields( aStru )
	//oTempTable:AddIndex("index1", {"COD"} )
	oTempTable:Create()
	
	dbSelectArea("TRB")
	dbGotop()
	ProcRegua(LastRec())     
	do While !Eof() 
	    IncProc("DA1 - Processando produto » " + TRB->DA1_CODPRO)
	    dbSelectArea("DA1")
		dbSetOrder(2)
		If dbSeek(xFilial("DA1") + Alltrim(TRB->DA1_CODPRO))
			Do while(DA1_CODPRO == Alltrim(TRB->DA1_CODPRO) .And. !EoF())
				RecLock("DA1",.F.)
				DA1_PRCVEN    := TRB->DA1_PRCVEN
				msUnlock()
				
				DBSKip()
			EndDo
		Endif
		dbSelectArea("TRB")
		dbSkip()
	Enddo
	
	TRB->(DBCLOSEAREA())
EndIf
Return
