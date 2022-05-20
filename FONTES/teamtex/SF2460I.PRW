#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "PARMTYPE.CH"

/*/{Protheus.doc} SF2460I
//GERA PR1 PARA SUBIR NOTAS NO INTELIPOST
@author Henrique Cunha
@since 03/10/2020
@version 1.0
@return ${return}, ${return_description}
@type function
/*/

User Function SF2460I()

Local _aArea := GetArea()

DBSelectArea("PR1")
PR1->(DBSetOrder(1))

If !PR1->(MSSeek(xFilial("PR1") + "SF2"+Str(SF2->(Recno()),16)) )
	RECLOCK("PR1",.T.)
		PR1->PR1_FILIAL := xFilial("PR1")
		PR1->PR1_ALIAS  := "SF2"
		PR1->PR1_RECNO  := SF2->(RECNO())
		PR1->PR1_TIPREQ := "1"
		PR1->PR1_STINT  := "P"
		PR1->PR1_CHAVE  := xFilial("SF2") + SF2->F2_DOC
	PR1->(MsUnlock())
Endif 
	
RESTAREA(_aArea)

Return
