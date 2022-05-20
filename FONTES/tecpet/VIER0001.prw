#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} VIER0001
Etiqueta de identifica��o de produto.

@author Jo�o Gustavo Orsi
@since 19/01/2015
@version P11
/*/
//-------------------------------------------------------------------

User Function VIER0001(cCodProd,nQtdEtq) 

Local cPorta 	:= 'LPT1'
Local cDescProd	:= ''
Local cDescIng	:= ''
Local cCodBar	:= ''
Local cAlias	:= GetNextAlias()

BeginSql Alias cAlias
	SELECT 	B1_DESC AS DESCPOR,
			B1_ZZDESIN AS DESCING,
			B1_CODBAR AS CODBAR
	FROM %table:SB1% SB1
	WHERE B1_FILIAL = %xFilial:SB1%
		AND B1_COD = %Exp:cCodProd%
		AND SB1.%NotDel%
EndSql

cDescProd	:= AllTrim((cAlias)->DESCPOR)
cDescIng	:= AllTrim((cAlias)->DESCING)
cCodBar 	:= AllTrim((cAlias)->CODBAR)

(cAlias)->(DbCloseArea()) 

MSCBPRINTER('ZEBRA',cPorta,,,.F.,,,,,)
	MSCBINFOETI('RECEBIMENTO','100X100')
	MSCBBEGIN(1,4)
	MSCBChkStatus(.F.)
	MSCBWRITE("CT~~CD,~CC^~CT~")
	MSCBWRITE("^XA~TA000~JSN^LT0^MNW^MTD^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ")
	MSCBWRITE("~DG000.GRF,01536,016,")
	MSCBWRITE(",::::::::::::::::::::::::::::7FgNFC0:::::7FMF87FXFC07FMF01FXFC07FLFC00FXFC0::::7FMF01FXFC07FMF87FXFC07FgNFC0::7FF33FE4F97FF03FHF81C3FF80FIFC0:7FF03FC0781FE007FF0H03F8001FHFC07FFC1FC0F81F0H03FE0H03F80H0IFC07FFC1FC0F81F0180F80H03F8780FHFC0:7FFC1F83F81E0FC0F81F03FHFE0FHFC07FFE0F83F81E0FE0787FC3FIF0FHFC0:7FFE0F83F81E0I0707FC3FC0H0IFC07FFE0E07F81E0I0707FC3E0I0IFC0:7FHF0207F81E0I0707FC3E0300FHFC07FHF0207F81E0FIF07FC3C0FE0FHFC07FHFH01FF81E0FIF81FC3C0FF0FHFC0:7FHFC01FF81E03FHF81F03C0FE0FHFC07FHFC03FF81F01E3F80H03E0780FHFC0:7FHFE03FF81F0I0FE0H03E0I0IFC07FHFE03FF81FC0H0FE0H03F80H0IFC07FHFE07FF87FF007FF81C3FF070FHFC0:7FXF03FMFC07FWFE03FMFC0:7FVFI0OFC07FVFH01FNFC07FVF803FNFC0:7FVF8FPFC07FgNFC0::,::::::::::::::^XA")
	MSCBWRITE("^MMT")
	MSCBWRITE("^PW799")
	MSCBWRITE("^LL0400")
	MSCBWRITE("^LS0")
	MSCBWRITE("^FT640,96^XG000.GRF,1,1^FS")
	MSCBWRITE("^FT23,51^A0N,28,28^FH\^FDPRODUTO: " + cCodProd + "^FS")
	MSCBWRITE("^FT23,85^A0N,28,28^FH\^FDDESCRICAO PORTUGUES:^FS")
	MSCBWRITE("^FT23,119^A0N,28,28^FH\^FD" + cDescProd + "^FS")
	MSCBWRITE("^FT23,153^A0N,28,28^FH\^FDDESCRICAO INGLES:^FS")
	MSCBWRITE("^FT23,187^A0N,28,28^FH\^FD" + cDescIng + "^FS")
	MSCBWRITE("^FT23,221^A0N,28,28^FH\^FDQUANTIDADE: " + cValToChar(nQtdEtq) + "^FS")
	MSCBWRITE("^BY4,3,88^FT22,327^BCN,,Y,N")
	MSCBWRITE("^FD>:" + cCodBar + "^FS")
	MSCBWRITE("^PQ1,0,1,Y^XZ")
	MSCBWRITE("^XA^ID000.GRF^FS^XZ")
	MSCBEND()
 	MS_FLUSH()
MSCBCLOSEPRINTER()

Return