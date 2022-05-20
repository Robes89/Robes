#include "Protheus.ch"
 
///  Incluir Coluna
User Function OM010COL()
Local cCampo := ""
If PARAMIXB[2] == "DA1_CODLMT"	
cCampo := PARAMIXB[1] + "->B1_CODLMT"
EndIf
cCampo := &(cCampo)	
Return(cCampo)


///  Incluir Campo
User Function OM010CPO()
Local aCampos := {"DA1_CODLMT"}    
Return(aCampos)


/// Incluir Query
User Function OM010QRY()
 Local cQuery := PARAMIXB[1]
 // Adicionar o campo B1_CODBAR na  query
 cQuery := Substr(cQuery,1,54)+ ", B1_CODLMT " + Substr(cQuery,56)
Return cQuery




