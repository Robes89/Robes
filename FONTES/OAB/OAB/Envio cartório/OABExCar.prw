
#Include "Totvs.ch"


/*/{Protheus.doc} OABExCae
(long_description) Montagem de arquivo borderos para cartório
@type  Static Function
@author Philip Pellegrini
@since date 03/21
@version version 12.1.25
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/

User Function OABExCae(aDados)

	Local cQuery    := ""
	Local cNomeArq  := "ArqBordero" + Alltrim(Str(YEAR(DATE()))) + Alltrim(Str(MONTH(DATE()))) + Padl(Alltrim(Str(Day(DATE()))),2,"0") + Substr(Time(),1,2) + Substr(Time(),4,2) + Substr(Time(),7,2) +".xml"
	Local cPath     := GetTempPath()
	Local cAlias    := GetNextAlias()
	Local cLinha    := ''
	Local cPrefixo  := ''
	Local cNum      := ''
	Local cParcela  := ''
	Local cTipo     := ''
	Local oExcel := FWMSEXCEL():New()

	oExcel:AddworkSheet("OABExCae")
	oExcel:AddTable ("OABExCae","Títulos para cartório")

	//Cabeçalho

	oExcel:AddColumn("OABExCae","Títulos para cartório","PREFIXO",1,1)
	oExcel:AddColumn("OABExCae","Títulos para cartório","TITULO",1,1)
	oExcel:AddColumn("OABExCae","Títulos para cartório","PARCELA",1,2)
	oExcel:AddColumn("OABExCae","Títulos para cartório","TIPO",1,2)
	oExcel:AddColumn("OABExCae","Títulos para cartório","CLIENTE",1,2)

	dbSelectArea("SE1")
	SE1->(dbSetOrder(1))

	For nX := 1 to Len(aDados)

		cPrefixo  := aDados[nX][2]
		cNum      := aDados[nX][3]
		cParcela  := aDados[nX][4]
		cTipo     := aDados[nX][5]

		If SE1->(dbSeek(xFilial("SE1")+ AvKey(cPrefixo,"E1_PREFIXO") + AvKey(cNum,"E1_NUM" )+AvKey(cParcela,"E1_PARCELA"))

			cCliente := AllTrim(POSICIONE("SA1",3,xFilial("SA1")+SE1->E1_CLIENTE,"A1_COD"))
			cCliente += " - " AllTrim(POSICIONE("SA1",3,xFilial("SA1")+SE1->E1_CLIENTE,"A1_NOME"))

			oExcel:AddRow("OABExCae","Títulos para cartório", { 	cPrefixo,;
																	cNum ,; 
																	cParcela ,; 
																	cTipo ,;  
																	cCliente})
		Endif 
	Next

	If !Empty(oExcel:aWorkSheet)

		oExcel:Activate()
		oExcel:GetXMLFile(cArquivo)

		If ApOleClient( 'MsExcel' ) 
			oExcelApp := MsExcel():New()
			oExcelApp:WorkBooks:Open( cPath + cNomeArq )
			oExcelApp:SetVisible(.T.)
		EndIf
 
   	 	CpyS2T("\SYSTEM\"+cNomeArq, cPath)

	EndIf

Return cPath + cNomeArq
