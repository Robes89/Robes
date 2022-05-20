#INCLUDE "TOTVS.CH"
#include "TopConn.Ch"
#INCLUDE "PROTHEUS.CH"
//#INCLUDE "TBIConn.ch"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "APWEBSRV.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TEAMEntregºAutor  ³Microsiga           º Data ³  07/06/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Controle de Entrega - Inclusao/Alteracao                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function TEAMEntreg()                        
Local oButton1
Local oButton2
Local oComboBo1
Local nComboBo1 := 1
Local oGet1
Local cGet1 := space(10)
Local oGet2
Local cGet2 := CTOD("  /  /  ")
Local oGet3
Local cGet3 := CTOD("  /  /  ")
Local oGet4
Local cGet4 := CTOD("  /  /  ")
Local oGet5
Local cGet5 := CTOD("  /  /  ")
Local oGet6
Local cGet6 := CTOD("  /  /  ")
Local oGet7
Local cGet7 := CTOD("  /  /  ")
Local oGet8
Local cGet8 := CTOD("  /  /  ")
Local oGet10
Local cGet10 := Space(150)
Local oGroup1
Local oSay1
Local oSay10
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSay6
Local oSay7
Local oSay8
Local oSay9 
Local xValSt 
Static oDlg                                              

cGet1		:= SF2->F2_XNCOLET
cGet2		:= SF2->F2_XDCOLET				//"Data Prevista Coleta"
//cGet3		:= SF2->F2_XDRETIR				//"Data de Retirada"
cGet4		:= SF2->F2_XDTENT				//"Data da Entrega" 
cGet5		:= SF2->F2_XDAGENT				//"Data de Agendamento Entrega" 
cGet6		:= SF2->F2_XDTSAID				//"Data de Saida da Mercadoria" 
cGet7		:= SF2->F2_XDRETRA				//"Data do Retrabalho"
cGet8		:= SF2->F2_XARMAZE				//"Armazem" 			
nComboBo1 	:= Val(SF2->F2_XSTATUS)			//"Status do transporte"
xValSt		:= Val(SF2->F2_XSTATUS)			//"Status do transporte"

cGet10		:= SF2->F2_XOBSCOL				//"Observação da coleta" 
          
dbSelectArea("SD2")
dbSetOrder(3)
If DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
	cGet8	:=   Posicione("NNR" , 1 , xFilial("NNR") + SD2->D2_LOCAL ,"NNR_DESCRI")      
Endif
                                                                               

  DEFINE MSDIALOG oDlg TITLE "Controle Logistico" FROM 000, 000  TO 450, 750 COLORS 0, 16777215 PIXEL

    @ 008, 008 GROUP oGroup1 TO 209, 365 OF oDlg COLOR 0, 16777215 PIXEL

    @ 018, 118 MSGET oGet8 VAR cGet8 													SIZE 060, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL  
    @ 018, 022 SAY oSay8 PROMPT "Armazem" 												SIZE 048, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 034, 022 SAY oSay5 PROMPT "Data do Retrabalho" 									SIZE 084, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 034, 118 MSGET oGet7 VAR cGet7 													SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL 
    @ 051, 022 SAY oSay2 PROMPT "Data Prevista Coleta" 									SIZE 059, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 051, 118 MSGET oGet2 VAR cGet2 													SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 068, 022 SAY oSay1 PROMPT "Numero da Coleta" 										SIZE 051, 007 OF oDlg COLORS 0, 16777215 PIXEL 
    @ 068, 118 MSGET oGet1 VAR cGet1 													SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL               
    @ 084, 022 SAY oSay4 PROMPT "Data de Agendamento Entrega" 							SIZE 080, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 084, 118 MSGET oGet5 VAR cGet5 													SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL   
    @ 098, 118 MSGET oGet6 VAR cGet6 													SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 098, 022 SAY oSay6 PROMPT "Data de Saida da Mercadoria" 							SIZE 085, 007 OF oDlg COLORS 0, 16777215 PIXEL    
    @ 115, 022 SAY oSay7 PROMPT "Data da Entrega" 										SIZE 063, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 115, 118 MSGET oGet4 VAR cGet4 													SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 132, 022 SAY oSay9 PROMPT "Status do transporte" 									SIZE 061, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 132, 119 MSCOMBOBOX oComboBo1 VAR nComboBo1 ITEMS {"1=Entregue","2=Devolução",""}; 	
    																					SIZE 072, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 148, 022 SAY oSay10 PROMPT "Observação da coleta" 								SIZE 068, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 157, 023 MSGET oGet10 VAR cGet10 													SIZE 324, 010 OF oDlg COLORS 0, 16777215 PIXEL  
    //@ 180, 262 BUTTON oButton1 PROMPT "&Salvar"	ACTION(_GRAVADADOS(cGet1,cGet2,cGet4,cGet5,cGet6,cGet7,cGet8,nComboBo1,cGet10,xValSt),oDlg:End(),u_TEAMParcela(cGet4)); 										
    @ 180, 262 BUTTON oButton1 PROMPT "&Salvar"	ACTION(_GRAVADADOS(cGet1,cGet2,cGet4,cGet5,cGet6,cGet7,cGet8,nComboBo1,cGet10,xValSt),oDlg:End()); 										
    																					SIZE 037, 012 OF oDlg PIXEL
    @ 180, 311 BUTTON oButton2 PROMPT "S&air"  	ACTION(oDlg:End())						SIZE 037, 012 OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg CENTERED

Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TEAMENTREGºAutor  ³Microsiga           º Data ³  07/06/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function _GRAVADADOS(xPar1,xPar2,xPar4,xPar5,xPar6,xPar7,xPar8,xPar9,xPar10,xPar11)
   
If xPar11 > 0  
	If!("Administrador" $ cusuario)
		Alert("Contate o Administrador para alteração!!" )
		Return
	Endif
Endif
	
If VALTYPE(XPAR9) == "N"        
	If Alltrim(STR(xPar9))=="0"   
		xPar9:=""
	Else
		xPar9 := Alltrim(STR(xPar9))
	Endif
Endif

DbSelectArea("SF2")
Reclock("SF2",.F.)
	SF2->F2_XNCOLET	:= xPar1	//"Numero da Coleta" 	
	SF2->F2_XDCOLET	:= xPar2	//"Data Prevista Coleta"
//	SF2->F2_XDRETIR	:= xPar3	//"Data de Retirada"
	SF2->F2_XDTENT	:= xPar4	//"Data da Entrega" 
	SF2->F2_XDAGENT	:= xPar5	//"Data de Agendamento Entrega" 
	SF2->F2_XDTSAID	:= xPar6	//"Data de Saida da Mercadoria" 
	SF2->F2_XDRETRA	:= xPar7	//"Data do Retrabalho"
	SF2->F2_XARMAZE	:= xPar8	//"Armazem" 			
	SF2->F2_XSTATUS	:= xPar9	//"Status do transporte"
	SF2->F2_XOBSCOL	:= xPar10	//"Observação da coleta" 
SF2->(MsUnlock())	



Return
