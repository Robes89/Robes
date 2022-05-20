#include "protheus.ch"  
#Include "Colors.ch"
#Include "Font.ch"
#Include "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  | PSPickPV ºAutor ³Guilherme Ricci    º Data ³ 26/07/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Pick List de pedidos de venda                              º±±
±±º          ³                                    						  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
USER FUNCTION PSPickPV()
Local oReport

//Private cPerg := "PSPickPV"
Private cPerg := "MTR777"

If TRepInUse()
	//ValidPerg(@cPerg)
	Pergunte(cPerg,.F.)
	oReport := ReportDef(cPerg)
	oReport:PrintDialog()	
EndIf                       
RETURN

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ReportDef ³ Autor ³ Marcio Nascimento   ³ Data ³ 15/04/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montagem do layout do relatorio.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Protheus 10                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION ReportDef(cPerg)
Local oReport
Local oSection
Local oSection2
Local cTitulo	:= "Picklist TecPet"  

oReport := TReport():New("PSPickPV",cTitulo,cPerg,{|oReport| PrintReport(oReport)},cTitulo)
oReport:SetLandscape()
oSection := TRSection():New(oReport,cTitulo,{"SC9","SB1","SDC"}) 
oSection:AutoSize()           
//oSection:SetTotalText("Total")
oSection:SetTotalInLine(.F.)  
//	TRCell():New(oSection1,/*Nome_Celula*/	,/*Alias*/ ,/*Titulo*/		,/*Picture*/					,/*Tamanho*/			,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"C9_PEDIDO"		,"TSC9", "Pedido"			,"@!"							,TamSx3("C9_PEDIDO")[1]	,,	)
	TRCell():New(oSection,"C9_ITEM"			,"TSC9", "Item"				,"@!"							,TamSx3("C9_ITEM")[1]	,,	)
	TRCell():New(oSection,"C9_PRODUTO"		,"TSC9", "Produto"			,PesqPict("SB1","B1_COD")		,TamSX3("B1_COD")[1]	,, 	) 
	TRCell():New(oSection,"B1_DESC"			,"TSC9", "Descrição" 		,PesqPict("SB1","B1_DESC")		,TamSX3("B1_DESC")[1]	,,,,.T. 	)
	TRCell():New(oSection,"C9_LOCAL"		,"TSC9", "Armazém"			,PesqPict("SB2","B2_LOCAL")		,TamSX3("B2_LOCAL")[1]	,, 	) 
	TRCell():New(oSection,"C9_QTDLIB" 		,"TSC9", "Quant"			,PesqPict("SC9","C9_QTDLIB")	,TamSx3("C9_QTDLIB")[1],,  )  
		
//	TRFunction():New(oSection:Cell("D2_CUSTO1"),NIL,"SUM",,,,,,.F.)

oSection2 := TRSection():New(oSection,"Enderecos",{"SC9","SB1","SDC"},,,,,,,,,,5/*nLeftMargin*/) 
oSection2:AutoSize()           
//oSection:SetTotalText("Total")
oSection2:SetTotalInLine(.F.)  
//	TRCell():New(oSection1,/*Nome_Celula*/	,/*Alias*/ ,/*Titulo*/		,/*Picture*/					,/*Tamanho*/			,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"DC_LOTECTL"		,"TSC9", "Lote"			,PesqPict("SDC","DC_LOTECTL")	,TamSx3("DC_LOTECTL")[1]	,,	)
	TRCell():New(oSection2,"DC_LOCALIZ"		,"TSC9", "Endereco"		,PesqPict("SDC","DC_LOCALIZ")	,TamSx3("DC_LOCALIZ")[1]	,,	)
	TRCell():New(oSection2,"DC_QUANT"		,"TSC9", "Quant."		,PesqPict("SDC","DC_QUANT")		,TamSX3("DC_QUANT")[1]	,, 	) 
	TRCell():New(oSection2,"____________"	,""	   , "Qtd Pallets" 	, "@!"  						,12,,,,.T. 	)
	TRCell():New(oSection2,"____________"	,""    , "Qtd Separada" , "@!"  						,12,,,,.T. 	)

RETURN (oReport)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³PrintRepor³ Autor ³ Marcio Nascimento   ³ Data ³ 15/05/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao do Relatorio                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Protheus 10                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION PrintReport(oReport)

Local oSection 	:= oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
Local cWhere := ""

Local cChave := ""

If MV_PAR03 == 1
	cWhere := "%C9_BLEST = ' '%"
Elseif MV_PAR03 == 2
	cWhere := "%C9_BLCRED = ' '%"
Elseif MV_PAR03 == 3
	cWhere := "%C9_BLEST = ' ' AND C9_BLCRED = ' '%"
Endif

oSection:BeginQuery()		    

	BeginSql alias "TSC9"
	/*
		SELECT C2_NUM+C2_ITEM+C2_SEQUEN AS OP, C2_PRODUTO AS PRODUTO, B1_DESC AS DESCRICAO, C2_QUANT AS QTD_OP,
		G2_OPERAC AS OPERACAO, G2_RECURSO AS RECURSO, G2_DESCRI AS DESC_OPER, G2_SETUP AS TEMPO_SETUP, G2_TEMPAD AS TEMPO_PADRAO,
		(CASE WHEN G2_TPOPER = '1' THEN 'PC' ELSE 'LT' END) AS TPOPER, (CASE WHEN G2_TPOPER = '1' THEN G2_TEMPAD*C2_QUANT ELSE G2_TEMPAD END) AS TEMPO_TOTAL
		FROM %table:SC2% C2, %table:SG2% G2, %table:SB1% B1
		WHERE C2_PRODUTO = G2_PRODUTO AND
		(CASE WHEN C2_ROTEIRO = ' ' THEN '01' ELSE C2_ROTEIRO END) = G2_CODIGO AND
		C2_PRODUTO = B1_COD AND
		C2.D_E_L_E_T_ <> '*' AND
		G2.D_E_L_E_T_ <> '*' AND
		B1.D_E_L_E_T_ <> '*' AND
		C2_NUM+C2_ITEM+C2_SEQUEN >= %exp:MV_PAR01% AND
		C2_NUM+C2_ITEM+C2_SEQUEN <= %exp:MV_PAR02% AND
		C2_PRODUTO >= %exp:MV_PAR03% AND
		C2_PRODUTO <= %exp:MV_PAR04%
		ORDER BY OP, OPERACAO
	*/
		SELECT C9_PEDIDO, C9_ITEM, C9_PRODUTO, B1_DESC, C9_LOCAL, C9_QTDLIB, DC_LOTECTL, DC_LOCALIZ, DC_QUANT
		FROM %TABLE:SC9% C9
		INNER JOIN %TABLE:SB1% B1 ON B1_COD = C9_PRODUTO AND B1.D_E_L_E_T_ = ' '
		LEFT JOIN %TABLE:SDC% DC ON DC_FILIAL = C9_FILIAL AND DC_PEDIDO = C9_PEDIDO AND DC_ITEM = C9_ITEM AND DC_SEQ = C9_SEQUEN AND DC.D_E_L_E_T_=' '
		WHERE C9_FILIAL = %EXP:XFILIAL("SC9")%
		AND C9_PEDIDO >= %EXP:MV_PAR01%
		AND C9_PEDIDO <= %EXP:MV_PAR02%
		AND %exp:cWhere%
		AND C9.D_E_L_E_T_=' '
		ORDER BY C9_PEDIDO, C9_ITEM
	EndSql          		

oSection:EndQuery()

While TSC9->(!eof())	
	cChave := TSC9->(C9_PEDIDO + C9_ITEM)	
	If oReport:Cancel()
		Exit
	Endif	
	oSection:Init()
	oSection:PrintLine()	
	oSection2:Init()	
	While TSC9->(!eof()) .and. TSC9->(C9_PEDIDO+C9_ITEM) == cChave
		oSection2:PrintLine()
		TSC9->(dbSkip())
	EndDo	
	oSection2:Finish()
	oSection:Finish()	
	oReport:IncMeter()		
EndDo
RETURN