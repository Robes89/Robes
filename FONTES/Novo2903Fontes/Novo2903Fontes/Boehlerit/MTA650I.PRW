#Include "rwmake.ch"

// Gravar o c�digo LMT na tabela de ordens de produ��o de acordo com o c�digo LMT
// informado no item do pedido de vendas
// Wilson J.Santos
// 20/01/2005

User Function MTA650I()
Local	aArea_SB1	:= SB1->( GetArea() )

RecLock( "SC2" )
SC2->C2_CODLMT	:= Posicione( "SB1" , 1, xFilial( "SB1" ) + SC2->C2_PRODUTO , "B1_CODLMT" )
SC2->( MsUnLock() )

RestArea( aArea_SB1 )

Return( .T. )