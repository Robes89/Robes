#include "ACDV100.ch" 
#include "protheus.ch"
#include "apvt100.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ACDV100   � Autor � Ricardo               � Data � 23/04/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Reimpressao de etiquetas                                   ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
���              �        �      �                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
STATIC Function ACDV100()
Local    oDlg, oEtiq, oLocImp
Local    cTitulo 	:= STR0010 //"Reimpressao de Etiquetas" 

local lVolta, lSai
Private  cEtiq , cLocImp
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

IF IsTelNet()
   While .t.            
      cEtiq   := Space(20)
      cLocImp := Space(6)
      lSair   := .f.
   	VTClear()               
	If lVT100B
		While .T.
			lVolta := .F.
			
			@ 1,0 VTSay STR0001 //"Reimpressao de"
			@ 2,0 VTSay STR0002 //"Etiqueta :"
			@ 3,0 VTGet cEtiq pict '@!' VALID ! Empty(cEtiq) .and. VldEtiq(cEtiq) F3 "CB0"
			vtread
			If VTLastkey() != 27
				VTClear()
			
				@ 2,0 VTSay STR0007 //"Local de Impressao:"
				@ 3,0 VTGet cLocImp pict '@!' VALID ! Empty(cLocImp) .and. VldLocImp() F3 "CB5"
				VTRead                      
				IF VTLastKey() == 27
					Exit
				EndIf
			else
				lSair := .t. // Sai dos dois la�os
				exit
			endif
			
			if lVolta
				loop
			endif
			exit
	
		enddo
		if lSair 
			exit
		endif
	else
	   @ 1,0 VTSay STR0001 //"Reimpressao de"
	   @ 2,0 VTSay STR0002 //"Etiqueta :"
	   @ 4,0 VTSay STR0007 //"Local de Impressao:"
  	   @ 3,0 VTGet cEtiq pict '@!' VALID ! Empty(cEtiq) .and. VldEtiq(cEtiq) F3 "CB0"
 	  	@ 5,0 VTGet cLocImp pict '@!' VALID ! Empty(cLocImp) .and. VldLocImp() F3 "CB5"
	   VTRead                      
      IF VTLastKey() == 27
         Exit
	EndIf
  EndIf
 Enddo
Else
   cEtiq   := Space(20)
   cLocImp := Space(6)
	DEFINE MSDIALOG oDlg FROM  180,080 TO 320,380 TITLE OemtoAnsi(cTitulo) PIXEL
	@ 10,10 SAY OemToAnsi(STR0011) SIZE 50,8 OF oDlg PIXEL //"Etiqueta"
	@ 30,10 SAY OemToAnsi(STR0012) SIZE 50,8 OF oDlg PIXEL //"Local de Impressao "
	@ 10,60 MSGET oEtiq VAR cEtiq PICTURE "@!" F3 "CB0" VALID VldEtiq(cEtiq)  SIZE 80,10 OF oDlg PIXEL
	@ 30,60 MSGET oLocImp VAR cLocImp PICTURE "@!" F3 "CB5" SIZE 40,10 OF oDlg PIXEL
	DEFINE SBUTTON FROM 50,80 TYPE 1 ENABLE OF oDlg ACTION (ReimprEti(),oDlg:End())
	DEFINE SBUTTON FROM 50,110 TYPE 2 ENABLE OF oDlg ACTION oDlg:End()
	ACTIVATE MSDIALOG oDlg CENTERED
EndIf
         
Return

Static Function VldEtiq(cEtiq)
dbSelectArea("CB0") 
CB0->(dbSetOrder(1))  
If Len(AllTrim(cEtiq))>10
	CB0->(dbSetOrder(2))             
EndIf                  
If ! CB0->(dbSeek(xFilial()+cEtiq))	 
	If IsTelNet()
		VTAlert(STR0006,STR0004,.T.,3000)	 //"Etiqueta nao existe"###"Atencao"
	Else
		MsgStop(STR0006) //"Etiqueta nao existe"
	EndIf
   Return(.F.)
Endif
CB0->(dbSetOrder(1))             
Return .t.

Static Function VldLocImp() 
Return ReimprEti()

Static Function ReimprEti()
Local   lErro := .f.

If IsTelNet()	
	VTMSG(STR0009)				 //"Imprimindo..."
EndIf
	
If CB0->CB0_TIPO == "01" //Tipo '01' produto
   If CBProdUnit(CB0->CB0_CODPRO)
		lErro:= ! ACDI10PR(cEtiq,cLocImp)	
	Else 
		lErro:= ! ACDI10CX(cEtiq,cLocImp)	
	EndIf	
Elseif CB0->CB0_TIPO == "02" //Tipo '02' localizacao
	lErro :=! ACDI020LO(cEtiq,cLocImp)
Elseif CB0->CB0_TIPO == "04" //Tipo '04' operador
	lErro :=! ACDI060US(cEtiq,cLocImp)
Elseif CB0->CB0_TIPO == "06" //Tipo '06' transportadora
	lErro :=! ACDI050Tr(cEtiq,cLocImp)
Else
   If IsTelNet()
   	VTAlert(STR0003,STR0004,.T.,3000) //"Rotina de impressao nao disponivel para esta etiqueta"###"Atencao"
   Else
   	MsgStop(STR0003) //"Rotina de impressao nao disponivel para esta etiqueta"
   EndIF
Endif
If lErro
	If IsTelNet()
		VTAlert(STR0005,STR0004,.T.,3000)		 //"Problema na impressao"###"Atencao"		   
	Else
		MsgStop(STR0005) //"Problema na impressao"
	EndIf
Endif
Return ! lErro
