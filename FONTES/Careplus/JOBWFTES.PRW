#include 'protheus.ch'
#include 'parmtype.ch'

user function JOBWFTES()
	Local lJob		:= ! ( Select("SX6") > 0 ) 
	if lJob
		RpcSetType ( 3 )
		RpcSetEnv( "01","0101",,,'COM') 	
	endif
	//U_PdComNim()  
	U_TIBW030Send("994616")  
return 
