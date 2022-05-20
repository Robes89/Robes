//--------------------------------------------------------------------------
// Pto Entrada : SB6GRAVA
// Descricao   : Apos gravar SB6
// Ajustes por Wilson em 23/11/05
//--------------------------------------------------------------------------

User Function SB6GRAVA()

Local	aArea_SB1	:= SB1->( GetArea() )

SB1->( DbSetOrder( 1 ) )
If	SB1->( DbSeek( xFilial( "SB1" ) + SB6->B6_PRODUTO ) )
	RecLock( "SB6" )
	SB6->B6_CODLMT	:= SB1->B1_CODLMT
	SB6->( MsUnLock() )
EndIf

RestArea( aArea_SB1 )

Return( .T. )











/*
_aSvAlias       := {Alias(),IndexOrd(),Recno()}
oldInd := SB6->(IndexOrd())
oldRec := SB6->(Recno())

oldIndD2 := SD2->(IndexOrd())
oldRecD2 := SD2->(Recno())


dbSelectArea("SB1")
dbSetOrder(1)
If dbSeek(xFilial("SB1") + SB6->B6_PRODUTO)
	dbSelectArea("SD2")
	dbSetOrder(3)
	dbSeek(xFilial("SD2") + SB6->B6_DOC + SB6->B6_SERIE + SB6->B6_CLIFOR + SB6->B6_LOJA + SB6->B6_PRODUTO,.F.)
	dbSelectArea("SB6")
	RecLock("SB6",.F.)
	SB6->B6_CODLMT := SB1->B1_CODLMT 
	If SD2->D2_DOC == SB6->B6_DOC .and. SD2->D2_COD == SB6->B6_PRODUTO .and. Trim(Funname()) == "MATA460A"
		SB6->B6_LOCAL := SD2->D2_LOCAL
	Endif
	msUnlock()
Endif

// Retorna Area de Trabalho
SB6->(dbSetOrder(oldInd))
SB6->(dbGoto(oldRec))

SD2->(dbSetOrder(oldIndD2))
SD2->(dbGoto(oldRecD2))


DbSelectArea(_aSvAlias[1])
DbSetOrder(_aSvAlias[2])
DbGoTo(_aSvAlias[3])

Return
*/