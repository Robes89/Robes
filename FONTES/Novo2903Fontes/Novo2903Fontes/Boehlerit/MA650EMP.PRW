#Include "rwmake.ch"

// atualização do código LMT nos empenhos
// Wilson Santos
// Out/2008

User Function MA650EMP()
Local	aArea_SB1	:= SB1->( GetArea() )
Local	aArea_SD4	:= SD4->( GetArea() )

SD4->( DbSetOrder( 2 ) )
SD4->( DbSeek( xFilial( "SD4" ) + SC2->( C2_NUM + C2_ITEM + C2_SEQUEN + C2_ITEMGRD ) ) )
While !SD4->( Eof() ) .and. SD4->D4_FILIAL	== xFilial( "SD4" ) .and. ;
							SD4->D4_OP		== SC2->( C2_NUM + C2_ITEM + C2_SEQUEN + C2_ITEMGRD )
	RecLock( "SD4" )
	SD4->D4_CODLMT	:= Posicione( "SB1" , 1 , xFilial( "SB1" ) + SD4->D4_COD , "B1_CODLMT" )
	SD4->( MsUnLock() )
	SD4->( DbSkip() )
EndDo

RestArea( aArea_SB1 )
RestArea( aArea_SD4 )

Return( .T. )
