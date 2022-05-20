
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "RPTDEF.CH" 
#INCLUDE 'APWebSrv.ch'
#include 'Fileio.ch'  
#INCLUDE "TBICODE.CH"
#INCLUDE "FWPrintSetup.ch"

User Function M110STTS()
 
Local cNumSol   := Paramixb[1]
Local nOpt      := Paramixb[2]

 
Do case
    case nOpt == 1     
      DBSelectArea("SC1")
      DBSetOrder(1)
      DBSeek(XfILIAL('SC1')+cNumSol)
      
      RecLock("PR2",.T.)
      PR2->PR2_CODIGO :='00004'
      PR2->PR2_CPODES := cvaltochar(SC1->(RECNO()))
   
      PR2->(MsUnlock())
Endcase
     
Return Nil