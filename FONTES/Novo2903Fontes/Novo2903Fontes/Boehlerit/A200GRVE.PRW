#include "rwmake.ch"

User Function A200GRVE()

Local	aArea_SB1	:= SB1->( GetArea() )
Local	aArea_SG1	:= SG1->( GetArea() )

SB1->( DbSetOrder( 1 ) )
SG1->( DbSetOrder( 1 ) )

IF ALTERA
	SG1->(DBSKIP(-1))
	xCod := SG1->G1_COD
	If SB1->( DbSeek( xFilial( "SB1" ) + xCOD ) )
		DO WHILE !SG1->(BOF()) .AND. SG1->G1_COD == xCOD
			RecLock( "SG1" )
			SG1->G1_CODLMT	:= SB1->B1_CODLMT
			SG1->( MsUnLock() )
			SG1->(dbSkip(-1))
		ENDDO
	EndIf
ELSE
	SG1->(DBSKIP())
	xCod := SG1->G1_COD
	If SB1->( DbSeek( xFilial( "SB1" ) + xCOD ) )
		DO WHILE !SG1->(EOF()) .AND. SG1->G1_COD == xCOD
			RecLock( "SG1" )
			SG1->G1_CODLMT	:= SB1->B1_CODLMT
			SG1->( MsUnLock() )
			SG1->(dbSkip(1))
		ENDDO
	EndIf
ENDIF

RestArea( aArea_SB1 )
RestArea( aArea_SG1 )

Return
