#include "rwmake.ch"

// Ponto de entrada na inclusão / alteração de estrutura de produtos
// atualização do campo G1_CODLMT
// Wilson Santos
// Out/2008

User Function A200BOK()

Local	aRecnos		:= PARAMIXB[1]
Local	cProduto	:= PARAMIXB[2]
Local	aArea_SG1	:= SG1->( GetArea() )
Local	aArea_SB1	:= SB1->( GetArea() )

SB1->( DbSetOrder( 1 ) )

For nXX := 1 to Len( aRecnos )

	SG1->( DbGoTo( aRecnos[ nXX , 1 ] ) )
	If	SB1->( DbSeek( xFilial( "SG1" ) + SG1->G1_COD ) )
		RecLock( "SG1" )
		SG1->G1_CODLMT	:= SB1->B1_CODLMT
		SG1->( MsUnLock() )
	EndIf

Next nXX

RestArea( aArea_SG1 )
RestArea( aArea_SB1 )

Return( .T. )
