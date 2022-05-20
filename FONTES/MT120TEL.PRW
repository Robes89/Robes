#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MT120TEL
Componente gerador de cintratos de Parcerias

@type  	Function
@author Mauro Paladini
@since 	27/01/2020

https://tdn.totvs.com/display/public/PROT/MT120TEL

/*/

User Function MT120TEL()

Local oDlg        := PARAMIXB[1]
Local aPosGet     := PARAMIXB[2]
Local aObj        := PARAMIXB[3]
Local nOpcx       := PARAMIXB[4]
Local nReg        := PARAMIXB[5]//
Local aCombo      := { 'Sim','Não'}
Local lEdit       := IIF( nOpcx == 3 .Or. nOpcx == 4 .Or. nOpcx ==  9 , .T. , .F. ) //Somente será editável, na Inclusão, Alteração e Cópia

Public oXContrato   := Nil
Public cXContrato   := 'Não'

If Str(nOpcx,1) $ '125' 
    SC7->(DbGoTo(nReg))
    aCombo      := { IIF( SC7->C7_XCOPARC == 'S' , 'Sim' , 'Não' ) }
    cXContrato  := aCombo[1]
EndIf

@ 052 ,aPosGet[1,12]-12 SAY "Gera Contrato*"    COLOR CLR_BLUE OF oDlg PIXEL SIZE 80,006
@ 050 ,aPosGet[1,7]+15  MSCOMBOBOX oXContrato VAR cXContrato ITEMS aCombo SIZE 030,006 OF oDlg PIXEL

oXContrato:bHelp := {|| ShowHelpCpo( "C7_XCOPARC", { GetHlpSoluc("C7_XCOPARC")[1]}, 5  )}

Return









/*/{Protheus.doc} VldCoParc
Valida preenchimento obrigatório do campo Gera Contrato

@type  	Function
@author Mauro Paladini
@since 	27/01/2020
/*/

User Function MsgStyle( cMsg , cTitle  )

Local cMsgHTMl  := ''

Default cMsg    := ''
Default cTitle  := ''

cMsgHTMl	:= '<html>'
cMsgHTMl	+= '<big style="font-family: arial, sans-serif;  margin: 0px;">' + cMsg +'</big>'
cMsgHTMl	+= '</html>'

MsgInfo(cMsgHTMl,cTitle)	

Return