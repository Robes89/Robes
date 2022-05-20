#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"

User Function TESTE()
Local	aSays		:= {}
Local	aButtons	:= {}
Local	nOpca		:= 0
Local	cCadastro	:= "Geração de arquivo Excel"

//cPerg := "XLSSB1"
Private cPerg    := PadR( 'XLSSB1' , Len( SX1->X1_GRUPO ) )
AjustaSX1()
Pergunte(cPerg,.F.)

Aadd(aSays, OemToAnsi( "Esta rotina irá gerar um arquivo excel por produto" ) )
Aadd(aSays, OemToAnsi( "referente a vendas, compras, estoque e ordem de produção" ) )

aAdd(aButtons, { 5,.T.,{|| Pergunte( cPerg , .T.) }} )
Aadd(aButtons, { 1, .T., { || nOpca := 1, IF( MsgYesNo( OemToAnsi( "Confirma geração ?" ), OemToAnsi( "Confimação..." ) ), FechaBatch(), nOpca := 0) }})
Aadd(aButtons, { 2, .T., { || FechaBatch() }})

FormBatch(cCadastro, aSays, aButtons)

If nOpca == 1
	Processa( { || TESTE1() }, "Gerando arquivo..." )
EndIf

Return

// ****************************************************************************************
Static Function TESTE1()
Local	cQuery := ""
Local	nTotDias	:= IF( mv_par05 >= 1 , mv_par05 * 30 , 0 )

aStru := {}
aAdd(aStru,{"CODIGO",		"C",	TamSx3( "B1_COD" )[1],		TamSx3( "B1_COD")[2] } )
aAdd(aStru,{"CODLMT",		"C",	TamSx3( "B1_CODLMT" )[1],	TamSx3( "B1_CODLMT")[2] } )
aAdd(aStru,{"DESC",			"C",	TamSx3( "B1_DESC" )[1],		TamSx3( "B1_COD")[2] } )
aAdd(aStru,{"DENOM",		"C",	TamSx3( "B1_DENOM" )[1],	TamSx3( "B1_DENOM")[2] } )
aAdd(aStru,{"ESTLMT",		"N",	TamSx3( "B2_QATU" )[1],		TamSx3( "B2_QATU")[2] } )
aAdd(aStru,{"ESTCONS",		"N",	TamSx3( "B2_QATU" )[1],		TamSx3( "B2_QATU")[2] } )
aAdd(aStru,{"ESTOQUE",		"N",	TamSx3( "B2_QATU" )[1],		TamSx3( "B2_QATU")[2] } )
aAdd(aStru,{"EMPENHO",		"N",	TamSx3( "B2_QEMP" )[1],		TamSx3( "B2_QEMP")[2] } )
aAdd(aStru,{"ESTATU",		"N",	TamSx3( "B2_QATU" )[1],		TamSx3( "B2_QATU")[2] } )
aAdd(aStru,{"PV",			"N",	TamSx3( "C6_QTDVEN" )[1],	TamSx3( "C6_QTDVEN")[2] } )
aAdd(aStru,{"VENDAS",		"N",	TamSx3( "D2_QUANT" )[1],	TamSx3( "D2_QUANT")[2] } )
aAdd(aStru,{"OPS",			"N",	TamSx3( "D3_QUANT" )[1],	TamSx3( "D3_QUANT")[2] } )
aAdd(aStru,{"TOTAL",		"N",	TamSx3( "D2_QUANT" )[1],	TamSx3( "D2_QUANT")[2] } )
aAdd(aStru,{"MESEST",		"N",	TamSx3( "C6_PRCVEN" )[1],	TamSx3( "C6_PRCVEN")[2] } )
aAdd(aStru,{"DTULTCOM",		"D",	TamSx3( "D1_EMISSAO" )[1],	TamSx3( "D1_EMISSAO")[2] } )
aAdd(aStru,{"QTDULTCOM",	"N",	TamSx3( "D1_QUANT" )[1],	TamSx3( "D1_QUANT")[2] } )
aAdd(aStru,{"DTULTVEN",		"D",	TamSx3( "D2_EMISSAO" )[1],	TamSx3( "D2_EMISSAO")[2] } )
aAdd(aStru,{"QTDULTVEN",	"N",	TamSx3( "D2_QUANT" )[1],	TamSx3( "D2_QUANT")[2] } )
aAdd(aStru,{"CMLMT",		"N",	TamSx3( "B2_CM1" )[1],		TamSx3( "B2_CM1")[2] } )
aAdd(aStru,{"CMCONS",		"N",	TamSx3( "B2_CM1" )[1],		TamSx3( "B2_CM1")[2] } )

oTemptable := FWTemporaryTable():New( "TRB")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"CODIGO"} )
oTempTable:Create()

//cArq := CriaTrab(aStru,.T.)
//dbUseArea(.T.,,cArq,"TRB",.T.)
//cInd := CriaTrab(NIL,.F.)
//IndRegua("TRB",cInd,"CODIGO",,,"Selecionando Registros...")

// *---------------------------------------------------------------------------------------
// estoques

DbSelectArea( "SB2" )
aStru	:= SB2->( dbStruct() )
cQuery	:= " SELECT SB2.B2_COD, SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM"
cQuery	+= ", SUM(CASE WHEN SB2.B2_LOCAL = '01' THEN SB2.B2_QATU ELSE 0 END) AS ESTLMT"
cQuery	+= ", SUM(CASE WHEN SB2.B2_LOCAL = '01' THEN SB2.B2_CM1 ELSE 0 END) AS CMLMT"
cQuery	+= ", SUM(CASE WHEN SB2.B2_LOCAL = '02' THEN SB2.B2_QATU ELSE 0 END) AS ESTCONS"
cQuery	+= ", SUM(CASE WHEN SB2.B2_LOCAL = '02' THEN SB2.B2_CM1 ELSE 0 END) AS CMCONS"
cQuery	+= ", SUM(CASE WHEN SB2.B2_LOCAL IN ('01','02') THEN SB2.B2_QATU ELSE 0 END) AS ESTOQUE"
cQuery	+= ", SUM(CASE WHEN SB2.B2_LOCAL IN ('01','02') THEN SB2.B2_QEMP ELSE 0 END) AS EMPENHO"
cQuery	+= ", SUM(CASE WHEN SB2.B2_LOCAL IN ('01','02') THEN (SB2.B2_QATU-SB2.B2_QEMP) ELSE 0 END) AS ESTATU"
cQuery	+= " FROM " + RetSqlName( "SB2" ) + " SB2"
cQuery	+= " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SB2.B2_COD = SB1.B1_COD"
cQuery	+= " AND SB1.D_E_L_E_T_ = ' '"
cQuery	+= " AND SB1.B1_ATIVO <> 'N'"
cQuery	+= " WHERE"
cQuery	+= " SB2.D_E_L_E_T_ = ' '"
cQuery	+= " AND SB2.B2_COD BETWEEN '" + MV_PAR01 +"' AND '" + MV_PAR02 + "' "
cQuery	+= " AND SB2.B2_CODLMT BETWEEN '" + MV_PAR03 +"' AND '" + MV_PAR04 + "' "
cQuery	+= " AND (SB2.B2_QATU <> 0 OR SB2.B2_QEMP <> 0)"
cQuery	+= " AND SUBSTRING(SB2.B2_COD,1,3) <> 'MOD'"
cQuery	+= " GROUP BY SB2.B2_COD, SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM"
cQuery	+= " ORDER BY SB2.B2_COD"

cQuery := ChangeQuery( cQuery )
//MemoWrite("C:\TESTE.TXT",cQuery)
MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),'ESTOQUES', .F., .T.)},OemToAnsi("Selecionando estoque"))
For nj := 1 to Len(aStru)
	If	aStru[nj,2] != 'C'
		TCSetField( 'ESTOQUES' , aStru[nj,1] , aStru[nj,2] , aStru[nj,3] , aStru[nj,4] )
	EndIf	
Next nj

TcSetField( "ESTOQUES",	"ESTLMT",	"N",	TamSx3( "B2_QATU" )[1],	TamSx3( "B2_QATU")[2] )
TcSetField( "ESTOQUES",	"CMLMT",	"N",	TamSx3( "B2_CM1" )[1],	TamSx3( "B2_CM1")[2] )
TcSetField( "ESTOQUES",	"ESTCONS",	"N",	TamSx3( "B2_QATU" )[1],	TamSx3( "B2_QATU")[2] )
TcSetField( "ESTOQUES",	"CMCONS",	"N",	TamSx3( "B2_CM1" )[1],	TamSx3( "B2_CM1")[2] )
TcSetField( "ESTOQUES",	"ESTOQUE",	"N",	TamSx3( "B2_QATU" )[1],	TamSx3( "B2_QATU")[2] )
TcSetField( "ESTOQUES",	"EMPENHO",	"N",	TamSx3( "B2_QATU" )[1],	TamSx3( "B2_QATU")[2] )
TcSetField( "ESTOQUES",	"ESTATU",	"N",	TamSx3( "B2_QATU" )[1],	TamSx3( "B2_QATU")[2] )

// *---------------------------------------------------------------------------------------
// pedidos de vendas

DbSelectArea( "SC6" )
aStru	:= SC6->( dbStruct() )
cQuery	:= " SELECT SC6.C6_PRODUTO, SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM"
cQuery	+= ", SUM( SC6.C6_QTDVEN - SC6.C6_QTDENT ) AS PV"
cQuery	+= " FROM " + RetSqlName( "SC6" ) + " SC6"
cQuery	+= " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SC6.C6_PRODUTO = SB1.B1_COD"
cQuery	+= " AND SB1.D_E_L_E_T_ = ' '"
cQuery	+= " AND SB1.B1_ATIVO <> 'N'"
cQuery	+= " INNER JOIN " + RetSqlName( "SF4" ) + " SF4 ON SC6.C6_TES = SF4.F4_CODIGO"
cQuery	+= " AND SF4.D_E_L_E_T_ = ' '"
cQuery	+= " AND SF4.F4_DUPLIC = 'S'"
cQuery	+= " WHERE"
cQuery	+= " SC6.D_E_L_E_T_ = ' '"
cQuery	+= " AND SC6.C6_PRODUTO BETWEEN '" + MV_PAR01 +"' AND '" + MV_PAR02 + "' "
cQuery	+= " AND SC6.C6_CODLMT BETWEEN '" + MV_PAR03 +"' AND '" + MV_PAR04 + "' "
cQuery	+= " AND SC6.C6_ENTREG <= '" + dtos( ddatabase + nTotDias ) + "' "
cQuery	+= " AND SUBSTRING(SC6.C6_BLQ,1,1) <> 'R' "
cQuery	+= " AND ( SC6.C6_QTDENT < SC6.C6_QTDVEN )"
cQuery	+= " AND SUBSTRING(SC6.C6_PRODUTO,1,3) <> 'MOD'"
cQuery	+= " GROUP BY SC6.C6_PRODUTO, SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM"
cQuery	+= " ORDER BY SC6.C6_PRODUTO"

cQuery := ChangeQuery( cQuery )
//MemoWrite("C:\TESTE.TXT",cQuery)
MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),'PEDIDOS', .F., .T.)},OemToAnsi("Selecionando pedidos de vendas"))
For nj := 1 to Len(aStru)
	If	aStru[nj,2] != 'C'
		TCSetField( 'PEDIDOS' , aStru[nj,1] , aStru[nj,2] , aStru[nj,3] , aStru[nj,4] )
	EndIf	
Next nj

TcSetField( "PEDIDOS",	"PV",	"N",	TamSx3( "C6_QTDVEN" )[1],	TamSx3( "C6_QTDVEN")[2] )

*---------------------------------------------------------------------------------------
// vendas

DbSelectArea( "SD2" )
aStru	:= SD2->( dbStruct() )
cQuery	:= " SELECT SD2.D2_COD, SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM"
cQuery	+= ", SUM( SD2.D2_QUANT ) AS VENDAS"
cQuery	+= " FROM " + RetSqlName( "SD2" ) + " SD2"
cQuery	+= " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SD2.D2_COD = SB1.B1_COD"
cQuery	+= " AND SB1.D_E_L_E_T_ = ' '"
cQuery	+= " AND SB1.B1_ATIVO <> 'N'"
cQuery	+= " INNER JOIN " + RetSqlName( "SF4" ) + " SF4 ON SD2.D2_TES = SF4.F4_CODIGO"
cQuery	+= " AND SF4.D_E_L_E_T_ = ' '"
cQuery	+= " AND SF4.F4_DUPLIC = 'S'"
cQuery	+= " WHERE"
cQuery	+= " SD2.D_E_L_E_T_ = ' '"
cQuery	+= " AND SD2.D2_COD BETWEEN '" + MV_PAR01 +"' AND '" + MV_PAR02 + "' "
cQuery	+= " AND SD2.D2_CODLMT BETWEEN '" + MV_PAR03 +"' AND '" + MV_PAR04 + "' "
cQuery	+= " AND SD2.D2_EMISSAO > '" + dtos( ddatabase - nTotDias ) + "' "
cQuery	+= " AND SUBSTRING(SD2.D2_COD,1,3) <> 'MOD'"
cQuery	+= " GROUP BY SD2.D2_COD, SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM"
cQuery	+= " ORDER BY SD2.D2_COD"

cQuery := ChangeQuery( cQuery )
//MemoWrite("C:\TESTE.TXT",cQuery)
MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),'VENDAS', .F., .T.)},OemToAnsi("Selecionando vendas"))
For nj := 1 to Len(aStru)
	If	aStru[nj,2] != 'C'
		TCSetField( 'VENDAS' , aStru[nj,1] , aStru[nj,2] , aStru[nj,3] , aStru[nj,4] )
	EndIf	
Next nj

TcSetField( "VENDAS",	"VENDAS",	"N",	TamSx3( "D2_QUANT" )[1],	TamSx3( "D2_QUANT")[2] )

// *---------------------------------------------------------------------------------------
// op´s requisições

DbSelectArea( "SD3" )
aStru	:= SD3->( dbStruct() )
cQuery	:= " SELECT SD3.D3_COD, SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM"
cQuery	+= ", SUM(CASE WHEN SUBSTRING(SD3.D3_CF,1,2) = 'RE' THEN SD3.D3_QUANT ELSE 0 END) AS REQ"
cQuery	+= ", SUM(CASE WHEN SUBSTRING(SD3.D3_CF,1,2) = 'DE' THEN SD3.D3_QUANT ELSE 0 END) AS DEV"
cQuery	+= " FROM " + RetSqlName( "SD3" ) + " SD3"
cQuery	+= " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SD3.D3_COD = SB1.B1_COD"
cQuery	+= " AND SB1.D_E_L_E_T_ = ' '"
cQuery	+= " AND SB1.B1_ATIVO <> 'N'"
cQuery	+= " WHERE"
cQuery	+= " SD3.D_E_L_E_T_ = ' '"
cQuery	+= " AND SD3.D3_COD BETWEEN '" + MV_PAR01 +"' AND '" + MV_PAR02 + "' "
cQuery	+= " AND SD3.D3_CODLMT BETWEEN '" + MV_PAR03 +"' AND '" + MV_PAR04 + "' "
cQuery	+= " AND SD3.D3_EMISSAO > '" + dtos( ddatabase - nTotDias ) + "' "
cQuery	+= " AND SUBSTRING(SD3.D3_CF,1,2) IN ('RE','DE')"
cQuery	+= " AND SD3.D3_OP <> ' '"
cQuery	+= " AND SUBSTRING(SD3.D3_COD,1,3) <> 'MOD'"
cQuery	+= " GROUP BY SD3.D3_COD, SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM"
cQuery	+= " ORDER BY SD3.D3_COD"

cQuery := ChangeQuery( cQuery )
//MemoWrite("C:\TESTE.TXT",cQuery)
MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),'OPS', .F., .T.)},OemToAnsi("Selecionando requisições"))
For nj := 1 to Len(aStru)
	If	aStru[nj,2] != 'C'
		TCSetField( 'OPS' , aStru[nj,1] , aStru[nj,2] , aStru[nj,3] , aStru[nj,4] )
	EndIf	
Next nj

TcSetField( "OPS",	"REQ",	"N",	TamSx3( "D3_QUANT" )[1],	TamSx3( "D3_QUANT")[2] )
TcSetField( "OPS",	"DEV",	"N",	TamSx3( "D3_QUANT" )[1],	TamSx3( "D3_QUANT")[2] )

// *---------------------------------------------------------------------------------------
// dados da última venda

DbSelectArea( "SD2" )
aStru	:= SD2->( dbStruct() )

cQuery	:= " SELECT SD2.D2_COD, SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM"
cQuery	+= ", SD2.D2_EMISSAO AS DTULTVEN,SUM( SD2.D2_QUANT) AS QTDULTVEN"
cQuery	+= " FROM " + RetSqlName( "SD2" ) + " SD2"
cQuery	+= " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SD2.D2_COD = SB1.B1_COD"
cQuery	+= " AND SB1.D_E_L_E_T_ = ' '"
cQuery	+= " AND SB1.B1_ATIVO <> 'N'"
cQuery	+= " INNER JOIN " + RetSqlName( "SF4" ) + " SF4 ON SD2.D2_TES = SF4.F4_CODIGO"
cQuery	+= " AND SF4.D_E_L_E_T_ = ' '"
cQuery	+= " AND SF4.F4_DUPLIC = 'S'"
cQuery	+= " WHERE"
cQuery	+= " SD2.D_E_L_E_T_ = ' '"
cQuery	+= " AND SD2.D2_COD BETWEEN '" + MV_PAR01 +"' AND '" + MV_PAR02 + "' "
cQuery	+= " AND SD2.D2_CODLMT BETWEEN '" + MV_PAR03 +"' AND '" + MV_PAR04 + "' "
cQuery	+= " AND SD2.D2_QUANT > 0"
cQuery	+= " AND SUBSTRING(SD2.D2_COD,1,3) <> 'MOD'"
cQuery	+= " GROUP BY SD2.D2_COD, SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM, SD2.D2_EMISSAO"
cQuery	+= " ORDER BY SD2.D2_COD, SD2.D2_EMISSAO DESC"

cQuery := ChangeQuery( cQuery )
//MemoWrite("C:\TESTE.TXT",cQuery)
MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),'ULTVEN', .F., .T.)},OemToAnsi("Selecionando última venda"))
For nj := 1 to Len(aStru)
	If	aStru[nj,2] != 'C'
		TCSetField( 'ULTVEN' , aStru[nj,1] , aStru[nj,2] , aStru[nj,3] , aStru[nj,4] )
	EndIf	
Next nj

TcSetField( "ULTVEN",	"DTULTVEN",		"D",	TamSx3( "D2_EMISSAO" )[1],	TamSx3( "D2_EMISSAO")[2] )
TcSetField( "ULTVEN",	"QTDULTVEN",	"N",	TamSx3( "D2_QUANT" )[1],	TamSx3( "D2_QUANT")[2] )

DBSelectArea("ULTVEN")
//COPY TO "ULTVEN.DTC" VIA "DBFCDXADS" // ALTERADO DE DBF PARA DTC SAMANTA SILVA
ULTVEN->( DbCloseArea() )
//dbUseArea(.T.,,"ULTVEN","ULTVEN",.T.)
//dbUseArea(.T.,"DBFCDXADS","ULTVEN.DTC","ULTVEN",.T.)  //INCLUIDO 26/10/2018 SAMANTA SILVA
oTemptable := FWTemporaryTable():New( "ULTVEN")
oTempTable:Create()

//cInd := CriaTrab(NIL,.F.)
IndRegua("ULTVEN",cInd,"SUBSTR(D2_COD,1,15)",,,"Ordenando registros...")     //ALTEREDO OS SUBSTR PARA SUBSTRING SAMANTA SILVA

// *---------------------------------------------------------------------------------------
// dados da última compra

DbSelectArea( "SD1" )
aStru	:= SD1->( dbStruct() )

cQuery	:= " SELECT SD1.D1_COD, SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM"
cQuery	+= ", SD1.D1_DTDIGIT AS DTULTCOM,SUM( SD1.D1_QUANT) AS QTDULTCOM"
cQuery	+= " FROM " + RetSqlName( "SD1" ) + " SD1"
cQuery	+= " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SD1.D1_COD = SB1.B1_COD"
cQuery	+= " AND SB1.D_E_L_E_T_ = ' '"
cQuery	+= " AND SB1.B1_ATIVO <> 'N'"
cQuery	+= " INNER JOIN " + RetSqlName( "SF4" ) + " SF4 ON SD1.D1_TES = SF4.F4_CODIGO"
cQuery	+= " AND SF4.D_E_L_E_T_ = ' '"
//cQuery	+= " AND (SF4.F4_DUPLIC = 'S' OR SUBSTR(SD1.D1_CF,1,4)='3101' OR SUBSTR(SD1.D1_CF,1,4)='3102')"
cQuery	+= " WHERE"
cQuery	+= " SD1.D_E_L_E_T_ = ' '"
cQuery	+= " AND SD1.D1_COD BETWEEN '" + MV_PAR01 +"' AND '" + MV_PAR02 + "' "
cQuery	+= " AND SD1.D1_CODLMT BETWEEN '" + MV_PAR03 +"' AND '" + MV_PAR04 + "' "
cQuery	+= " AND SD1.D1_QUANT > 0"
cQuery	+= " AND (SF4.F4_DUPLIC = 'S' OR SUBSTRING(SD1.D1_CF,1,4)='3101' OR SUBSTRING(SD1.D1_CF,1,4)='3102')"
cQuery	+= " AND SUBSTRING(SD1.D1_COD,1,3) <> 'MOD'"
cQuery	+= " GROUP BY SD1.D1_COD, SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM, SD1.D1_DTDIGIT"
cQuery	+= " ORDER BY SD1.D1_COD, SD1.D1_DTDIGIT DESC"

cQuery := ChangeQuery( cQuery )
//MemoWrite("C:\TESTE.TXT",cQuery)
MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),'ULTCOM', .F., .T.)},OemToAnsi("Selecionando última compra"))
For nj := 1 to Len(aStru)
	If	aStru[nj,2] != 'C'
		TCSetField( 'ULTCOM' , aStru[nj,1] , aStru[nj,2] , aStru[nj,3] , aStru[nj,4] )
	EndIf	
Next nj

TcSetField( "ULTCOM",	"DTULTCOM",		"D",	TamSx3( "D1_DTDIGIT" )[1],	TamSx3( "D1_DTDIGITs")[2] )
TcSetField( "ULTCOM",	"QTDULTCOM",	"N",	TamSx3( "D1_QUANT" )[1],	TamSx3( "D1_QUANT")[2] )

DBSelectArea("ULTCOM")
//COPY TO "ULTCOM.DTC" VIA "DBFCDXADS" //ALTERADO DE DBF PARA DTC SAMANTA SILVA 26/10/2018
ULTCOM->( DbCloseArea() )
//dbUseArea(.T.,,"ULTCOM","ULTCOM",.T.)

oTemptable := FWTemporaryTable():New( "ULTCOM")
oTempTable:Create()

//dbUseArea(.T.,"DBFCDXADS","ULTCOM.DTC","ULTCOM",.T.)     //adicionado SAMANTA SILVA
//cInd := CriaTrab(NIL,.F.)
IndRegua("ULTCOM",cInd,"SUBSTR(D1_COD,1,15)",,,"Ordenando registros...")

// *---------------------------------------------------------------------------------------
// montando arquivo de trabalho

DbSelectArea( "ESTOQUES" )
ESTOQUES->( DbGoTop() )
MsAguarde({|| ProcRegua( ESTOQUES->( LastRec() ) ) }, OemToAnsi( "Atualizando dados do estoque..." ) )

While !ESTOQUES->( Eof() )

	IncProc()

	If	ESTOQUES->ESTLMT # 0 .or. ESTOQUES->ESTCONS # 0 .or. ESTOQUES->EMPENHO # 0
		RecLock( "TRB" , !TRB->( DbSeek( ESTOQUES->B2_COD ) ) )
		TRB->CODIGO		:= ESTOQUES->B2_COD
		TRB->CODLMT		:= ESTOQUES->B1_CODLMT
		TRB->DESC		:= ESTOQUES->B1_DESC
		TRB->DENOM		:= ESTOQUES->B1_DENOM
		TRB->ESTLMT		:= ESTOQUES->ESTLMT
		TRB->ESTCONS	:= ESTOQUES->ESTCONS
		TRB->ESTOQUE	:= ESTOQUES->ESTOQUE
		TRB->EMPENHO	:= ESTOQUES->EMPENHO
		TRB->ESTATU		:= ESTOQUES->ESTATU
		TRB->CMLMT		:= ESTOQUES->CMLMT
		TRB->CMCONS		:= ESTOQUES->CMCONS
		TRB->( MsUnLock() )
	EndIf
	
	ESTOQUES->( DbSkip() )

EndDo

DbSelectArea( "PEDIDOS" )
PEDIDOS->( DbGoTop() )
MsAguarde({|| ProcRegua( PEDIDOS->( LastRec() ) ) }, OemToAnsi( "Atualizando pedidos de vendas..." ) )

While !PEDIDOS->( Eof() )

	IncProc()

	If	PEDIDOS->PV # 0
		RecLock( "TRB" , !TRB->( DbSeek( PEDIDOS->C6_PRODUTO ) ) )
		TRB->CODIGO		:= PEDIDOS->C6_PRODUTO
		TRB->CODLMT		:= PEDIDOS->B1_CODLMT
		TRB->DESC		:= PEDIDOS->B1_DESC
		TRB->DENOM		:= PEDIDOS->B1_DENOM
		TRB->PV			:= PEDIDOS->PV
		TRB->( MsUnLock() )
	EndIf
	
	PEDIDOS->( DbSkip() )

EndDo

DbSelectArea( "VENDAS" )
VENDAS->( DbGoTop() )
MsAguarde({|| ProcRegua( VENDAS->( LastRec() ) ) }, OemToAnsi( "Atualizando vendas..." ) )

While !VENDAS->( Eof() )

	IncProc()

	If	VENDAS->VENDAS # 0
		RecLock( "TRB" , !TRB->( DbSeek( VENDAS->D2_COD ) ) )
		TRB->CODIGO		:= VENDAS->D2_COD
		TRB->CODLMT		:= VENDAS->B1_CODLMT
		TRB->DESC		:= VENDAS->B1_DESC
		TRB->DENOM		:= VENDAS->B1_DENOM
		TRB->VENDAS		:= VENDAS->VENDAS
		TRB->TOTAL		+= VENDAS->VENDAS
		TRB->( MsUnLock() )
	EndIf
	
	VENDAS->( DbSkip() )

EndDo

DbSelectArea( "OPS" )
OPS->( DbGoTop() )
MsAguarde({|| ProcRegua( OPS->( LastRec() ) ) }, OemToAnsi( "Atualizando OP´s..." ) )

While !OPS->( Eof() )

	IncProc()

	If	OPS->REQ # 0
		RecLock( "TRB" , !TRB->( DbSeek( OPS->D3_COD ) ) )
		TRB->CODIGO		:= OPS->D3_COD
		TRB->CODLMT		:= OPS->B1_CODLMT
		TRB->DESC		:= OPS->B1_DESC
		TRB->DENOM		:= OPS->B1_DENOM
		TRB->OPS		:= OPS->REQ
		TRB->TOTAL		+= OPS->REQ
		TRB->( MsUnLock() )
	EndIf
	
	OPS->( DbSkip() )

EndDo

DbSelectArea( "TRB" )
TRB->( DbGoTop() )
MsAguarde({|| ProcRegua( TRB->( LastRec() ) ) }, OemToAnsi( "Atualizando última venda..." ) )

While !TRB->( Eof() )

	IncProc()

	If	ULTVEN->( DbSeek( SubStr( TRB->CODIGO , 1 , 15 ) ) )
		RecLock( "TRB" )
		TRB->DTULTVEN	:= ULTVEN->DTULTVEN
		TRB->QTDULTVEN	:= ULTVEN->QTDULTVEN
		TRB->( MsUnLock() )
	EndIf

	RecLock( "TRB" )
	If	TRB->TOTAL <> 0
		TRB->MESEST	:= (TRB->ESTATU - TRB->PV) / (TRB->TOTAL/12)        // ilidio
	Else
		TRB->MESEST	:= 9999999
	EndIf
	TRB->( MsUnLock() )

	TRB->( DbSkip() )

EndDo

DbSelectArea( "TRB" )
TRB->( DbGoTop() )
MsAguarde({|| ProcRegua( TRB->( LastRec() ) ) }, OemToAnsi( "Atualizando última compra..." ) )

While !TRB->( Eof() )

	IncProc()

	If	ULTCOM->( DbSeek( SubStr( TRB->CODIGO , 1 , 15 ) ) )
		RecLock( "TRB" )
		TRB->DTULTCOM	:= ULTCOM->DTULTCOM
		TRB->QTDULTCOM	:= ULTCOM->QTDULTCOM
		TRB->( MsUnLock() )
	EndIf
	
	TRB->( DbSkip() )

EndDo
// *---------------------------------------------------------------------------------------

DBSelectArea("TRB")
TRB->( DBGoTop() )

//COPY TO "TRB.DTC" VIA "DBFCDXADS"
__CopyFile( "TRB.DTC" , "C:\" + "TRB.XLS" )       

TRB->(DBCloseArea())
ESTOQUES->(DBCloseArea())
PEDIDOS->(DBCloseArea())
VENDAS->(DBCloseArea())
OPS->(DBCloseArea())
ULTVEN->(DBCloseArea())
ULTCOM->(DBCloseArea())
FErase("ULTVEN.dtc")
FErase("ULTCOM.dtc")

cfile := "C:\TRB.XLS"

oExcelApp:= MsExcel():New()
oExcelApp:WorkBooks:Open( cfile)
oExcelApp:SetVisible(.T.)

Return

// ****************************************************************************************
Static Function AjustaSX1()
aPerg    := {}
//cPerg    := "XLSSB1"

Aadd( aPerg , { "Codigo de      ?" , "C" , 15 , 0, "SB1"}) 
Aadd( aPerg , { "Codigo ate     ?" , "C" , 15 , 0, "SB1"}) 
Aadd( aPerg , { "Do Cod Lmt     ?" , "C" , TamSX3( "B1_CODLMT" )[1], 0 , "SB1LMT"})
Aadd( aPerg , { "Ate Cod Lmt    ?" , "C" , TamSX3( "B1_CODLMT" )[1], 0 , "SB1LMT"})
Aadd( aPerg , { "Quantos meses  ?" , "N" , 02 , 0, ""}) 

For nXX := 1 to Len( aPerg )
	If !SX1->( DbSeek( cPerg + StrZero( nXX , 2 ) ) ) 
		RecLock( "SX1" , .T. )
		SX1->X1_GRUPO     := cPerg
		SX1->X1_ORDEM     := StrZero( nXX , 2 )
		SX1->X1_PERGUNT   := aPerg[nXX][1]
		SX1->X1_VARIAVL   := "mv_ch" + Str( nXX , 1 )
		SX1->X1_TIPO      := aPerg[nXX][2]
		SX1->X1_TAMANHO   := aPerg[nXX][3]
		SX1->X1_DECIMAL	  := aPerg[nXX][4]
		SX1->X1_PRESEL    := 1
		SX1->X1_GSC       := "G"
		SX1->X1_VAR01     := "mv_par" + StrZero( nXX , 2 )
		SX1->X1_F3		  := aPerg[nxx][5]
		SX1->(MsUnLock())
	EndIf
Next nXX
Return Nil

/*
cQuery := "SELECT 'SB1' TIPO,B1_COD,B1_CODLMT CODLMT,B1_DENOM DENOM,B1_DESC,B2_QATU QATU,B2_QEMP QEMP,0 PV, 0 QTDVEN, 0 QTDOP, ' ' DTULTVEN,NVL(MAX(D1_DTDIGIT),' ') DTULTCOM, 0 QTDUVEN, 0 QTDUCOM, '' TPSD3, ' ' DTULTPRO, 0 CUSTMED "
cQuery += "FROM " + RetSqlName("SB1") +" SB1 "
cQuery += "LEFT OUTER JOIN " + RetSqlNAme("SB2") + " SB2 ON SB1.B1_COD = SB2.B2_COD AND SB2.D_E_L_E_T_ <> '*' AND SB2.B2_LOCAL = '01' "
cQuery += "INNER JOIN " + RetSqlName("SD1") + " SD1 ON SB1.B1_COD = SD1.D1_COD AND SD1.D1_FILIAL = '01' AND D1_TIPO = 'N' AND SD1.D_E_L_E_T_ <> '*' "
cQuery += "INNER JOIN " + RetSqlName("SF4") + " SF4 ON SD1.D1_TES = SF4.F4_CODIGO AND SF4.D_E_L_E_T_ <> '*' AND SF4.F4_FILIAL = '01' AND (SF4.F4_DUPLIC = 'S' OR (SUBSTR(SD1.D1_CF,1,4)='3101' OR SUBSTR(SD1.D1_CF,1,4)='3102')) "
cQuery += "WHERE SB1.D_E_L_E_T_ <> '*' AND SB1.B1_ATIVO = 'S' "
cQuery += "AND SB1.B1_COD BETWEEN '" + MV_PAR01 +"' AND '" + MV_PAR02 + "' "
cQuery += "AND SB1.B1_CODLMT BETWEEN '" + MV_PAR03 +"' AND '" + MV_PAR04 + "' "
cQuery += "GROUP BY B1_COD,B1_CODLMT,B1_DENOM,B1_DESC,B2_QATU,B2_QEMP "

cQuery += "UNION ALL "

cQuery += "SELECT 'SD2' TIPO,B1_COD,B1_CODLMT CODLMT,B1_DENOM DENOM,B1_DESC,B2_QATU QATU,B2_QEMP QEMP,0 PV, NVL(SUM(D2_QUANT),0) QTDVEN, 0 QTDOP, NVL(MAX(D2_EMISSAO),' ') DTULTVEN,' ' DTULTCOM, 0 QTDUVEN, 0 QTDUCOM, '' TPSD3, ' ' DTULTPRO, 0 CUSTMED "
cQuery += "FROM " + RetSqlName("SB1") + " SB1 "
cQuery += "LEFT OUTER JOIN " + RetSqlName("SB2") + " SB2 ON SB1.B1_COD = SB2.B2_COD AND SB2.D_E_L_E_T_ <> '*' AND SB2.B2_LOCAL = '02' "
cQuery += "INNER JOIN " + RetSqlName("SD2") + " SD2 ON SB1.B1_COD = SD2.D2_COD AND D2_EMISSAO > '" + dtos(ddatabase-365) + "' AND SD2.D_E_L_E_T_ <> '*' AND SD2.D2_TIPO = 'N' "
cQuery += "INNER JOIN " + RetSqlName("SF4") + " SF4 ON SD2.D2_TES = SF4.F4_CODIGO AND SF4.D_E_L_E_T_ <> '*' AND SF4.F4_DUPLIC = 'S' AND SF4.F4_FILIAL = '01' "
cQuery += "WHERE SB1.D_E_L_E_T_ <> '*' AND SB1.B1_ATIVO = 'S' "
cQuery += "AND SB1.B1_COD BETWEEN '" + MV_PAR01 +"' AND '" + MV_PAR02 + "' "
cQuery += "AND SB1.B1_CODLMT BETWEEN '" + MV_PAR03 +"' AND '" + MV_PAR04 + "' "
cQuery += "GROUP BY B1_COD,B1_CODLMT,B1_DENOM,B1_DESC, B2_QATU,B2_QEMP "

cQuery += "UNION ALL "

cQuery += "SELECT 'SC6' TIPO,B1_COD,B1_CODLMT CODLMT,B1_DENOM DENOM,B1_DESC,0 QATU,0 QEMP,NVL(SUM(C6_QTDVEN-C6_QTDENT),0) PV,0 QTDVEN, 0 QTDOP,' ' DTULTVEN, ' ' DTULTCOM, 0 QTDUVEN, 0 QTDUCOM, '' TPSD3, ' ' DTULTPRO, 0 CUSTMED "
cQuery += "FROM " + RetSqlName("SB1") + " SB1 "
cQuery += "INNER JOIN " + RetSqlName("SC6") + " SC6 ON SB1.B1_COD = SC6.C6_PRODUTO AND SC6.C6_FILIAL = '01' AND SC6.D_E_L_E_T_ <> '*' "
cQuery += "INNER JOIN " + RetSqlName("SF4") + " SF4 ON SC6.C6_TES = SF4.F4_CODIGO AND SF4.D_E_L_E_T_ <> '*' AND SF4.F4_DUPLIC = 'S' AND SF4.F4_FILIAL = '01' "
cQuery += "AND SC6.C6_ENTREG <= '" + dtos(ddatabase+365) + "' "
cQuery += "AND SUBSTR(SC6.C6_BLQ,1,1) <> 'R' "
cQuery += "AND SC6.C6_QTDENT < SC6.C6_QTDVEN "
cQuery += "WHERE SB1.D_E_L_E_T_ <> '*' AND SB1.B1_ATIVO = 'S' "
cQuery += "AND SB1.B1_COD BETWEEN '" + MV_PAR01 +"' AND '" + MV_PAR02 + "' "
cQuery += "AND SB1.B1_CODLMT BETWEEN '" + MV_PAR03 +"' AND '" + MV_PAR04 + "' "
cQuery += "GROUP BY B1_COD,B1_CODLMT,B1_DENOM,B1_DESC "

cQuery += "UNION ALL "

// requisições
cQuery += "SELECT 'SD3' TIPO,B1_COD,B1_CODLMT CODLMT,B1_DENOM DENOM,B1_DESC,0 QATU,0 QEMP,0 PV,0 QTDVEN, NVL(SUM(D3_QUANT),0) QTDOP,' ' DTULTVEN, ' ' DTULTCOM, 0 QTDUVEN, 0 QTDUCOM, 'R' TPSD3, ' ' DTULTPRO, 0 CUSTMED "
cQuery += "FROM " + RetSqlName("SB1") + " SB1 "
cQuery += "INNER JOIN " + RetSqlName("SD3") + " SD3 ON SB1.B1_COD = SD3.D3_COD AND SD3.D3_FILIAL = '01' AND SD3.D_E_L_E_T_ <> '*' AND SUBSTR(SD3.D3_CF,1,2) = 'RE' AND SD3.D3_EMISSAO > '" + dtos(ddatabase-365) + "' AND SD3.D3_OP <> '' "
cQuery += "WHERE SB1.D_E_L_E_T_ <> '*' AND SB1.B1_ATIVO = 'S' "
cQuery += "AND SB1.B1_COD BETWEEN '" + MV_PAR01 +"' AND '" + MV_PAR02 + "' "
cQuery += "AND SB1.B1_CODLMT BETWEEN '" + MV_PAR03 +"' AND '" + MV_PAR04 + "' "
cQuery += "GROUP BY B1_COD,B1_CODLMT,B1_DENOM,B1_DESC "

cQuery += "UNION ALL "

// devoluções
cQuery += "SELECT 'SD3' TIPO,B1_COD,B1_CODLMT CODLMT,B1_DENOM DENOM,B1_DESC,0 QATU,0 QEMP,0 PV,0 QTDVEN, NVL(SUM(D3_QUANT),0) QTDOP,' ' DTULTVEN, ' ' DTULTCOM, 0 QTDUVEN, 0 QTDUCOM, 'D' TPSD3, ' ' DTULTPRO, 0 CUSTMED "
cQuery += "FROM " + RetSqlName("SB1") + " SB1 "
cQuery += "INNER JOIN " + RetSqlName("SD3") + " SD3 ON SB1.B1_COD = SD3.D3_COD AND SD3.D3_FILIAL = '01' AND SD3.D_E_L_E_T_ <> '*' AND SUBSTR(SD3.D3_CF,1,2) = 'DE' AND SD3.D3_EMISSAO > '" + dtos(ddatabase-365) + "' AND SD3.D3_OP <> '' "
cQuery += "WHERE SB1.D_E_L_E_T_ <> '*' AND SB1.B1_ATIVO = 'S' "
cQuery += "AND SB1.B1_COD BETWEEN '" + MV_PAR01 +"' AND '" + MV_PAR02 + "' "
cQuery += "AND SB1.B1_CODLMT BETWEEN '" + MV_PAR03 +"' AND '" + MV_PAR04 + "' "
cQuery += "GROUP BY B1_COD,B1_CODLMT,B1_DENOM,B1_DESC "

cQuery += "UNION ALL "

// produções
cQuery += "SELECT 'PRO' TIPO,B1_COD,B1_CODLMT CODLMT,B1_DENOM DENOM,B1_DESC,0 QATU,0 QEMP,0 PV,0 QTDVEN, NVL(SUM(D3_QUANT),0) QTDOP,' ' DTULTVEN, ' ' DTULTCOM, 0 QTDUVEN, 0 QTDUCOM, 'P' TPSD3, NVL(MAX(D3_EMISSAO),' ') DTULTPRO, 0 CUSTMED "
cQuery += "FROM " + RetSqlName("SB1") + " SB1 "
cQuery += "INNER JOIN " + RetSqlName("SD3") + " SD3 ON SB1.B1_COD = SD3.D3_COD AND SD3.D3_FILIAL = '01' AND SD3.D_E_L_E_T_ <> '*' AND SUBSTR(SD3.D3_CF,1,2) = 'PR' AND SD3.D3_EMISSAO > '" + dtos(ddatabase-365) + "' AND SD3.D3_OP <> '' "
cQuery += "WHERE SB1.D_E_L_E_T_ <> '*' AND SB1.B1_ATIVO = 'S' "
cQuery += "AND SB1.B1_COD BETWEEN '" + MV_PAR01 +"' AND '" + MV_PAR02 + "' "
cQuery += "AND SB1.B1_CODLMT BETWEEN '" + MV_PAR03 +"' AND '" + MV_PAR04 + "' "
cQuery += "GROUP BY B1_COD,B1_CODLMT,B1_DENOM,B1_DESC,D3_EMISSAO "

cQuery += "UNION ALL "

cQuery += "SELECT 'SB9' TIPO,B1_COD,B1_CODLMT CODLMT,B1_DENOM DENOM,B1_DESC,0 QATU,0 QEMP,0 PV,0 QTDVEN, 0 QTDOP,' ' DTULTVEN, ' ' DTULTCOM, 0 QTDUVEN, 0 QTDUCOM, 'D' TPSD3, ' ' DTULTPRO, NVL(SUM(SB9.B9_VINI1/SB9.B9_QINI),0) CUSTMED "
cQuery += "FROM " + RetSqlName("SB1") + " SB1 "
cQuery += "INNER JOIN " + RetSqlName("SB9") + " SB9 ON SB1.B1_COD = SB9.B9_COD AND SB9.B9_FILIAL = '01' AND SB9.D_E_L_E_T_ <> '*' AND SB9.B9_VINI1 > 0 AND SB9.B9_QINI > 0 AND SB9.B9_DATA = '" + dtos(GETMV("MV_ULMES")) + "' "
cQuery += "WHERE SB1.D_E_L_E_T_ <> '*' AND SB1.B1_ATIVO = 'S' "
cQuery += "AND SB1.B1_COD BETWEEN '" + MV_PAR01 +"' AND '" + MV_PAR02 + "' "
cQuery += "AND SB1.B1_CODLMT BETWEEN '" + MV_PAR03 +"' AND '" + MV_PAR04 + "' "
cQuery += "GROUP BY B1_COD,B1_CODLMT,B1_DENOM,B1_DESC "
cQuery += "ORDER BY B1_COD "

cQuery := ChangeQuery(cQuery)
//MemoWrite("C:\TESTE.TXT",cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRA", .F., .T.)

ProcRegua(LastRec())
DBSelectArea("TRA")
DBGoTop()
Do While !EoF()
	IncProc(TRA->B1_COD)
	If(TRA->QATU > 0 .OR. TRA->QEMP > 0 .OR. TRA->QTDVEN > 0 .OR. TRA->PV > 0 .OR. TRA->QTDOP > 0 .OR. TRA->CUSTMED <> 0)
		DBSelectArea("TRB")
		Do Case
			Case TRA->TIPO = "SB1"
				RecLock("TRB",.T.)
				TRB->CODIGO 	:= TRA->B1_COD
				TRB->CODLMT 	:= TRA->CODLMT
				TRB->DESC		:= TRA->B1_DESC
				TRB->DENOM		:= TRA->DENOM
				TRB->ESTLMT		:= TRA->QATU
			  	TRB->ESTOQUE	+= TRA->QATU
				TRB->EMPENHO	+= TRA->QEMP
				TRB->ESTATU		:= TRA->QATU - TRA->QEMP
				TRB->DTULTCOM	:= StoD(TRA->DTULTCOM)
			Case TRA->TIPO = "SD2"
				If(DBSeek(TRA->B1_COD))
					RecLock("TRB",.F.)
				Else
					RecLock("TRB",.T.)
					TRB->CODIGO 	:= TRA->B1_COD
					TRB->CODLMT 	:= TRA->CODLMT
					TRB->DESC		:= TRA->B1_DESC
					TRB->DENOM		:= TRA->DENOM
				EndIf
				TRB->ESTCONS	:= TRA->QATU
				TRB->ESTOQUE	+= TRA->QATU
				TRB->EMPENHO	+= TRA->QEMP
				TRB->ESTATU		:= TRB->ESTOQUE - TRB->EMPENHO
				TRB->VENDAS		+= TRA->QTDVEN
				TRB->DTULTVEN	:= StoD(TRA->DTULTVEN)
				TRB->QTDULTVEN	:= TRA->QTDUVEN
				TRB->TOTAL		+= TRA->QTDVEN
			Case TRA->TIPO = "SC6"
				If(DBSeek(TRA->B1_COD))
					RecLock("TRB",.F.)
				Else
					RecLock("TRB",.T.)
					TRB->CODIGO 	:= TRA->B1_COD
					TRB->CODLMT 	:= TRA->CODLMT
					TRB->DESC		:= TRA->B1_DESC
					TRB->DENOM		:= TRA->DENOM
				EndIf
				TRB->PV := TRA->PV
			Case TRA->TIPO = "SD3"
				If(DBSeek(TRA->B1_COD))
					RecLock("TRB",.F.)
				Else
					RecLock("TRB",.T.)
					TRB->CODIGO 	:= TRA->B1_COD
					TRB->CODLMT 	:= TRA->CODLMT
					TRB->DESC		:= TRA->B1_DESC
					TRB->DENOM		:= TRA->DENOM
				EndIf
				If(Alltrim(TRA->TPSD3) == "R")
					TRB->OPS   += TRA->QTDOP
					TRB->TOTAL += TRA->QTDOP
				Else
					TRB->OPS   -= TRA->QTDOP
					TRB->TOTAL -= TRA->QTDOP
				EndIf
			Case TRA->TIPO = "PRO"
				If(DBSeek(TRA->B1_COD))
					RecLock("TRB",.F.)
				Else
					RecLock("TRB",.T.)
					TRB->CODIGO 	:= TRA->B1_COD
					TRB->CODLMT 	:= TRA->CODLMT
					TRB->DESC		:= TRA->B1_DESC
					TRB->DENOM		:= TRA->DENOM
				EndIf
				If	(StoD(TRA->DTULTPRO) > TRB->DTULTCOM)
					TRB->DTULTCOM	:= StoD(TRA->DTULTPRO)
					TRB->QTDULTCOM	:= TRA->QTDOP
				EndIf
			Case TRA->TIPO = "SB9"
				If(DBSeek(TRA->B1_COD))
					RecLock("TRB",.F.)
				Else
					RecLock("TRB",.T.)
					TRB->CODIGO 	:= TRA->B1_COD
					TRB->CODLMT 	:= TRA->CODLMT
					TRB->DESC		:= TRA->B1_DESC
					TRB->DENOM		:= TRA->DENOM
				EndIf
				TRB->CUSMED := TRA->CUSTMED
		EndCase

		If(TRB->TOTAL <> 0)
			TRB->MESEST	:= (TRB->ESTATU - TRB->PV) / (TRB->TOTAL/12)
		Else
			TRB->MESEST	:= 9999999
		EndIf
		
		MsUnLock()
		DBSelectArea("TRA")
	EndIf
	
	DBSkip()
EndDo

*/
