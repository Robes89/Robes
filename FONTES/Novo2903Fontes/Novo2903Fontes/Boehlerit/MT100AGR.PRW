#include "rwmake.ch"        // incluido pelo assistente de conversao do AP6 IDE em 23/09/02
#include "topconn.ch"
#INCLUDE "FIVEWIN.CH"
#include "Protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT100AGR  º Autor ³                    º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ PE Apos a gravacao da NF. Grava informações referente a    º±±
±±º          ³ mensagem da NF                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA100 	documento de entrada                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

*/
//**********************                         
USER Function MT100AGR()
//**********************

Local lRet := .t.

IF INCLUI .OR. l103Class
	
	IF SF1->F1_FORMUL = 'S'
		U_NFESF1()
	ENDIF	
	
ENDIF               

RETURN lRet


//*******************
User Function NFESF1()                                  
//*******************

Local	oMens1 
Local	oMens2 
Local	oMens3 
Local	oMens4 
Local	oMens5 

Local	oobj1 
Local	oobj2 
Local	oobj3 
Local	oobj4 
Local	oobj5 
Local   lPri := .t.
Local   aMens := {}

Private oDlgp	// Dialog Principal
Private aMens     := {}
Private Mens1     := space(45)
Private Mens2     := space(45)
Private Mens3     := space(45)
Private Mens4     := space(45)
Private Mens5     := space(45)                     
Private Mens      := SF1->F1_MENS_P     

Private cMensNF   := ""      

//************************************************************************************************************
SA2->(DBSETORDER(1))
SA2->(DbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA))   	 

SD1->(DBSETORDER(1))
SD1->(DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))   	 

While SD1->(!EOF()) .And. xFilial("SF1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA = xFilial("SD1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA

     If !Empty(SD1->D1_NFORI)
         
     	if lPri         
			cMensNF := IIF(SD1->D1_TIPO="D","Devol.Ref.NF:","Ret.NF:")    	
			lPri := .f.
     	endif
     	nReg:=SD1->(Recno())    
     	citem := SD1->D1_ITEMORI
     	cNFO  := alltrim(SD1->D1_NFORI)
     	cSero := Alltrim(SD1->D1_SERIORI)
     	cCod  := SD1->D1_COD    

		SF2->(DbSetOrder(1))     	
     	SF2->(DbSeek(xFilial("SF2")+SD1->D1_NFORI+SD1->D1_SERIORI+SF1->F1_FORNECE+SF1->F1_LOJA))     	     	

		If(SF1->F1_TIPO$"D")
		
	     	cMensNF+=cNFO+" de:"+TRANSFORM(SD2->D2_EMISSAO,"@e")+space(01)
		     	
		Else    

	     	cMensNF+=cNFO+"-"

	    Endif                  

        SD1->(DbGoto(nReg))	    
	    
     Endif                  
     
     SD1->(DBSKIP())
         
Enddo  

RecLock("SF1",.F.)
SF1->F1_MENS_P  := alltrim(SF1->F1_MENS_P)+" "+Alltrim(cMensNF)
msUnlock()
       
Mens1 := substr(SF1->F1_MENS_P,1,45)
Mens2 := substr(SF1->F1_MENS_P,46,45)
Mens3 := substr(SF1->F1_MENS_P,91,45)
Mens4 := substr(SF1->F1_MENS_P,136,45)
Mens5 := substr(SF1->F1_MENS_P,181,45)

DEFINE MSDIALOG oDlgp TITLE "Informações Adicionais" FROM 005,002 TO 200,450 PIXEL				

@ 010,007 Say "Mensagem"    Size 150,600 COLOR CLR_BLACK PIXEL OF oDlgp
@ 009,040 MsGet oMens1 Var Mens1 Size 150,010 COLOR CLR_BLACK   PIXEL OF oDlgp
@ 020,040 MsGet oMens2 Var Mens2 Size 150,010 COLOR CLR_BLACK   PIXEL OF oDlgp 
@ 031,040 MsGet oMens3 Var Mens3 Size 150,010 COLOR CLR_BLACK   PIXEL OF oDlgp
@ 042,040 MsGet oMens4 Var Mens4 Size 150,010 COLOR CLR_BLACK   PIXEL OF oDlgp
@ 053,040 MsGet oMens5 Var Mens5 Size 150,010 COLOR CLR_BLACK   PIXEL OF oDlgp 

@ 080,123 BmpButton Type 1 Action Eval({|| ExecBlock("GrvSF1",.F.,.F.),Close(oDlgp)})
@ 080,153 BmpButton Type 2 Action Close(oDlgp)
ACTIVATE  MSDIALOG oDlgp CENTERED

Return

//**************************
User Function GrvSF1
//**************************

Local Mens   := rtrim(Mens1) +" "+ rtrim(Mens2) +" "+ rtrim(Mens3) +" "+ rtrim(Mens4) +" "+ rtrim(Mens5)

RecLock("SF1",.F.)
SF1->F1_MENS_P   := Mens
msUnlock()

Return

