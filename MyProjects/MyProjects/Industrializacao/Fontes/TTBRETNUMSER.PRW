#include "Protheus.ch"

User Function ttbretnumser()
Local rNUMSERIE:=Space(11)
	
	local cAlias := getNextAlias()
	
	BeginSql Alias cAlias
	
		SELECT MAX(DB_NUMSERI) as cNUMSERI FROM  %TABLE:SDB% SDB 
		WHERE SDB.DB_FILIAL = %EXP:xfILIAL("SDB")% AND SDB.%NOTDEL%
	
	EndSQl
	
	rNUMSERIE:=SOMA1(Alltrim( (cAlias)->cNUMSERI))

	cCod := EanDigito(PADL(AllTrim(rNUMSERIE),12,"0"))

	cNumserie:=cCod  
	
	
Return(rNUMSERIE)
