#include "rwmake.ch"
User Function PRECO()

Local	aArea_DA1	:= DA1->( GetArea() )
Local	aArea_SB1	:= SB1->( GetArea() )

dbSelectArea("SB1")
dbSetOrder(9)
If dbSeek(xFilial("SB1") + M->C6_CODLMT)
	dbSelectArea("DA1")
	dbSetOrder(1)
//	dbSeek(xFilial("DA1") + "001" + SB1->B1_COD)
	If	!Empty( M->C5_TABELA )
		DA1->( dbSeek( xFilial( "DA1" ) + M->C5_TABELA + SB1->B1_COD ) )
		ACOLS[N,6] := DA1->DA1_PRCVEN
	Else
		ACOLS[N,6] := SB1->B1_PRV1
	EndIf
Endif

RestArea( aArea_DA1 )
RestArea( aArea_SB1 )
Return (.T.)