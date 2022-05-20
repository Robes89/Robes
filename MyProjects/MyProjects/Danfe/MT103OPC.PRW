#Include 'Protheus.ch'

User Function MA103OPC()
	
	Local aRet := {}
	Local aArea 		:= GetArea()
	
	aAdd(aRet,{'Inf. NF', 'u_M103NFMN', 0, 2})
	
	RestArea(aArea)
	
Return aRet

//====================================================

User Function M103NFMN()
	
	Local aPergs 		:= {}
	Local cMarca	 	:= ""
	Local cNumer		:= ""
	Local aRet 			:= {}
	
	cMarca := SF1->F1_XMARCA
	cNumer := SF1->F1_XNUMERA
	
	aAdd( aPergs ,{1,"Marca : "		,cMarca,"@!",'.T.',,'.T.',40,.F.})
	aAdd( aPergs ,{1,"Numeração : "	,cNumer,"@!",'.T.',,'.T.',40,.F.})
	
	  If ParamBox(aPergs ,"Parametros ",aRet)
	
		If MsgYesNo("Atualiza dados?", "Atenção")

			Reclock("SF1",.F.)
		
				SF1->F1_XMARCA 	:= MV_PAR01
				SF1->F1_XNUMERA := MV_PAR02
		
			SF1->(MsUnlock())
		
		EndIf
	EndIf
Return


