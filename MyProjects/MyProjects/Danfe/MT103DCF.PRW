#Include 'Protheus.ch'

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MT103DCF
Ponto de entrada após a gravação da Nota de Entrada
@type User function
@author Daniel Castro
@version 1.0
@since 04/09/2017
@return nil
@obs nil
@sample nil
/*/
//--------------------------------------------------------------------------------------------------------


User Function MT103DCF

Local lInclui := PARAMIXB[1]
Local lAltera := PARAMIXB[2]
Local lVisual := PARAMIXB[3]
Local aCamposPar := PARAMIXB[4]
Local aCamposRet := {}	

Local aArea 		:= GetArea()                                     
Local aPergs 		:= {}
Local cMarca	 	:= space(15)
Local cNumer		:= Space(10)
Local aRet 	   		:= {}

If lInclui
	
	aAdd( aPergs ,{1,"Marca : "		,cMarca,"@!",'.T.',,'.T.',40,.F.})
	aAdd( aPergs ,{1,"Numeração : "	,cNumer,"@!",'.T.',,'.T.',40,.F.})
	
	If !ParamBox(aPergs ,"Inf. Comp. NF " + cNFiscal ,aRet) 
		aAdd(aRet,"")
		aAdd(aRet,"")
	EndIf
	
	If !Empty(aRet[1]) .AND. !Empty(aRet[2])
	
	   	aAdd(aCamposRet, {"F1_XMARCA", aRet[1]})
		aAdd(aCamposRet, {"F1_XNUMERA", aRet[2]}) 
	
	EndIf

EndIf

Return aCamposRet