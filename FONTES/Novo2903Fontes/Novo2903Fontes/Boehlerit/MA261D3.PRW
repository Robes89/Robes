User Function MA261D3()

Local	aArea_SB1	:= SB1->( GetArea() )
Local	aArea_SD3	:= SD3->( GetArea() )
Local	cD3_NUMSEQ	:= SD3->D3_NUMSEQ


// Ponto de entrada para gravar o CODLMT no SB2

SB1->( DbSetOrder( 1 ) )
SB1->( DbSeek( xFilial( "SB1" ) + SD3->D3_COD ) )

U_GravaLmt()

SD3->( DbSetOrder( 4 ) )
SD3->( DbSeek( xFilial( "SD3" ) + cD3_NUMSEQ ) )

While !SD3->( Eof() ) .and.	SD3->D3_FILIAL	== xFilial( "SD3" ) .and. ;
							SD3->D3_NUMSEQ	== cD3_NUMSEQ
	RecLock( "SD3" )
	SD3->D3_CODLMT	:= Posicione( "SB1" , 1 , xFilial( "SB1" ) + SD3->D3_COD , "B1_CODLMT" )
	SD3->( MsUnLock() )
	SD3->( DbSkip() )
EndDo

RestArea( aArea_SB1 )
RestArea( aArea_SD3 )
	
Return
