#include "Protheus.ch"
User Function ttbretnumser()
	local rNUMSERIE:='0000000000001' //Strzero(1,12,0)
	local cAlias := getNextAlias()
	
	BeginSql Alias cAlias
	
		SELECT MAX(DB_NUMSERI) as cNUMSERI FROM  %TABLE:SDB% SDB 
		WHERE SDB.DB_FILIAL = %EXP:xfILIAL("SDB")% AND SDB.%NOTDEL%
	
	EndSQl
	
	If !Empty((cAlias)->cNUMSERI)
	
		rNUMSERIE:=SOMA1(Substr( (cAlias)->cNUMSERI,1,13))
	
	Endif
	
Return(rNUMSERIE)