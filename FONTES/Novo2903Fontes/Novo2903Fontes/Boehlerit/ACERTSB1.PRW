#INCLUDE "rwmake.ch"

User Function ACERTSB1()

 USE CLAEST3 ALIAS TRB
 
 DO WHILE ! TRB->( EOF() )         
 
    IF SB1->( DBSEEK( XFILIAL("SB1") + LEFT( TRB->CODIGO, 15 ) ) ) 
                                              
       DBSELECTAREA("SB1")
       RECLOCK("SB1", .F. ) 
       SB1->B1_CLAEST := SUBSTR( ALLTRIM( STRZERO( TRB->CLAEST, 0 ) ), 9, 2 )
       MSUNLOCK()
       
    ENDIF
    
    DBSELECTAREA("TRB")                         
    TRB->( DBSKIP() )       

 ENDDO                                                             

Return()

