#INCLUDE "PROTHEUS.CH"
//--------------------------------------------------------------------------
// Pto Entrada : SF1100I
// Descricao   : Gravação do cabeçalho da NF entrada
//--------------------------------------------------------------------------

User Function SF1140I()

_aSvAlias   := {Alias(),IndexOrd(),Recno()}
nValFob		:= 0       
nValII		:= 0
/*
dbSelectArea("SD1")
dbSetOrder(1)
dbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA)
DO While !Eof() .and. xFilial("SD1") == D1_FILIAL .and. D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA ==;
					  SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA
	nValFob += D1_VALFOB
	nValII  += D1_VALII
	dbSkip()
Enddo
*/        

nOpca := 0
DEFINE MSDIALOG oDlg TITLE OemToAnsi("Informe Valor FOB e Imp. Importação")  FROM 9,0 To 18,38 OF oMainWnd 
@ 1.0, 2 	Say OemToAnsi("Valor FOB") 	
@ 1.0, 7.5	MSGET nValFob  Picture "999,999,999.99" SIZE 70,10 Of oDlg
@ 2.0, 2 	Say OemToAnsi("Imp Importação") 
@ 2.0, 7.5	MSGET nValII   Picture "999,999,999.99" SIZE 70,10 Of oDlg
@  .3, 1 TO 3.5,18.8 OF oDlg
	
DEFINE SBUTTON FROM 052,057.3 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM 052,084.4 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTERED

dbSelectArea("SF1")
RecLock("SF1",.F.)
F1_FOB_R := nValFob					  
F1_II	 := nValII
msUnlock()

// Retorna Area de Trabalho
DbSelectArea(_aSvAlias[1])
DbSetOrder(_aSvAlias[2])
DbGoTo(_aSvAlias[3])

Return 