#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "TOPCONN.CH"

#Define CRLF Chr(13)+Chr(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÝÝÝÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝ»±±
±±ºPrograma  ³ VOGRELDSC ºAutor  ³Marcelo P. Costa   º Data ³  05/02/2021 º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDesc.     ³ Relatório de detalhamento da Solicitação de Compras        º±±
±±º          ³                                                            º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºUso       ³ SIGACOM                                                    º±±
±±ÈÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function VOGRELDSC()

	Local oReport
	Private aRet := {}

//Grupo de Perguntas
	perguntas()

	If Empty(aRet)
		MsgAlert("Operacao cancelada")
		Return()
	EndIf

	oReport := reportDef()

	oReport:printDialog()
Return

//======================================================================================================
// ANALITICO
//======================================================================================================

static function reportDef()
	Local oReport
	Local oSection1
	Local cTitulo := ''


	cTitulo := 'Detalhamento de Solicitacoes de Compras'

	oReport := TReport():New('VOGRELDSC', cTitulo, , {|oReport| PrintRepoA(oReport)},"Relatorio Detalhamento de Solicitacoes de Compras .")
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()

	oSection1 := TRSection():New(oReport,"Detalhamento de Solicitacoes de Compras",{"QRY"})
	oSection1:SetTotalInLine(.F.)

	TRCell():New(oSection1, "C1_FILIAL"	 , "QRY", " FILIAL"	              ,PesqPict('SC1',"C1_FILIAL")	 ,TamSX3("C1_FILIAL")   [1]+1)
	TRCell():New(oSection1, "C1_EMISSAO" , "QRY", " DT EMISSAO SC "	      ,PesqPict('SC1',"C1_EMISSAO")	 ,TamSX3("C1_EMISSAO")  [1]+1)
	TRCell():New(oSection1, "C1_DATPRF"  , "QRY", " NECESSIDADE "	      ,PesqPict('SC1',"C1_DATPRF")	 ,TamSX3("C1_DATPRF")   [1]+1)
	TRCell():New(oSection1, "C1_NUM"     , "QRY", " NUMERO DA SC "	      ,PesqPict('SC1',"C1_NUM")	     ,TamSX3("C1_NUM")      [1]+1)
	TRCell():New(oSection1, "C1_LOCAL"   , "QRY", " ARMAZEM SC "          ,PesqPict('SC1',"C1_LOCAL")	 ,TamSX3("C1_LOCAL")    [1]+1)
	TRCell():New(oSection1, "C1_ITEM"    , "QRY", " ITEM DA SC "          ,PesqPict('SC1',"C1_ITEM")	 ,TamSX3("C1_ITEM")     [1]+1)
	TRCell():New(oSection1, "C1_PRODUTO" , "QRY", " PRODUTO SC "	      ,PesqPict('SC1',"C1_PRODUTO")	 ,TamSX3("C1_PRODUTO")  [1]+1)
	TRCell():New(oSection1, "C1_DESCRI"  , "QRY", " DESCRICAO "	          ,PesqPict('SC1',"C1_DESCRI")   ,TamSX3("C1_DESCRI")   [1]+1)
	TRCell():New(oSection1, "C1_QUANT"   , "QRY", " QUANTIDADE SC "	      ,PesqPict('SC1',"C1_QUANT")	 ,TamSX3("C1_QUANT")    [1]+1)
	TRCell():New(oSection1, "C1_XVLUNIT" , "QRY", " VL. UNITARIO"	      ,PesqPict('SC1',"C1_XVLUNIT")	 ,TamSX3("C1_XVLUNIT")  [1]+1)
	TRCell():New(oSection1, "C1_XVLESTI" , "QRY", " VL. ESTIMADO"	      ,PesqPict('SC1',"C1_XVLESTI")	 ,TamSX3("C1_XVLESTI")  [1]+1)
	TRCell():New(oSection1, "B1_GRUPO"   , "QRY", " GRUPO PRODUTO SC "    ,PesqPict('SC7',"C7_PRODUTO")	 ,TamSX3("C7_PRODUTO")  [1]+1)
	TRCell():New(oSection1, "C1_CC"      , "QRY", " CENTRO CUSTO "	      ,PesqPict('SC1',"C1_CC")	     ,TamSX3("C1_CC")       [1]+1)
	TRCell():New(oSection1, "C1_XTIPO"   , "QRY", " TIPO "                ,PesqPict('SC1',"C1_XTIPO")	 ,TamSX3("C1_XTIPO")    [1]+1)
	TRCell():New(oSection1, "C1_XORDINV" , "QRY", " ORD INVEST "	      ,PesqPict('SC1',"C1_XORDINV")	 ,TamSX3("C1_XORDINV")  [1]+1)
	TRCell():New(oSection1, "C1_XOBSWF"  , "QRY", " OBS. WF "	          ,PesqPict('SC1',"C1_XOBSWF")	 ,TamSX3("C1_XOBSWF")   [1]+1)
	TRCell():New(oSection1, "C1_SOLICIT" , "QRY", " SOLICITANTE "	      ,PesqPict('SC1',"C1_SOLICIT")	 ,TamSX3("C1_SOLICIT")  [1]+1)
	If MV_PAR05 == 1
	TRCell():New(oSection1, "COI_DTHAPR" , "QRY", " DT APROVACAO SC"      ,PesqPict('COI',"COI_DTHAPR")	 ,TamSX3("COI_DTHAPR")  [1]+1)
	EndIf
	TRCell():New(oSection1, "STATUS_SC"  , "QRY", " STATUS_SC "	          ,,)
	TRCell():New(oSection1, "C7_NUM"     , "QRY", " NUMERO PC "	          ,PesqPict('SC7',"C7_NUM")	     ,TamSX3("C7_NUM")      [1]+1)
	TRCell():New(oSection1, "C7_EMISSAO" , "QRY", " DT EMISSAO PC "	      ,PesqPict('SC7',"C7_EMISSAO")	 ,TamSX3("C7_EMISSAO")  [1]+1)
	TRCell():New(oSection1, "C7_ITEM"    , "QRY", " ITEM PC "   	      ,PesqPict('SC7',"C7_ITEM")	 ,TamSX3("C7_ITEM")     [1]+1)
	TRCell():New(oSection1, "C7_PRODUTO" , "QRY", " PRODUTO PC "	      ,PesqPict('SC7',"C7_PRODUTO")	 ,TamSX3("C7_PRODUTO")  [1]+1)
	TRCell():New(oSection1, "C7_QUANT"   , "QRY", " QUANTIDADE PC "	      ,PesqPict('SC7',"C7_QUANT")	 ,TamSX3("C7_QUANT")    [1]+1)
	TRCell():New(oSection1, "C7_QUJE"    , "QRY", " QTD. ENTREGUE "	      ,PesqPict('SC7',"C7_QUJE")	 ,TamSX3("C7_QUJE")     [1]+1)
	TRCell():New(oSection1, "C7_PRECO"   , "QRY", " PRC. UNITARIO "	      ,PesqPict('SC7',"C7_PRECO")	 ,TamSX3("C7_PRECO")    [1]+1)
	TRCell():New(oSection1, "C7_TOTAL"   , "QRY", " VLR. TOTAL "	      ,PesqPict('SC7',"C7_TOTAL")	 ,TamSX3("C7_TOTAL")    [1]+1)
	TRCell():New(oSection1, "C7_DATPRF"  , "QRY", " DT ENTREGA PC "	      ,PesqPict('SC7',"C7_DATPRF")	 ,TamSX3("C1_NUM")      [1]+1)
	IF MV_PAR05 == 1
	TRCell():New(oSection1, "COK_UPED"   , "QRY", " COMPRADOR "           ,PesqPict('COK',"COK_UPED")    ,TamSX3("COK_UPED")    [1]+1)
	EndIf
	TRCell():New(oSection1, "C7_LOJA"    , "QRY", " LOJA "       	      ,PesqPict('SC7',"C7_LOJA")	 ,TamSX3("C7_LOJA")     [1]+1)
	TRCell():New(oSection1, "STATUS_PC"  , "QRY", " STATUS_PC"	          ,,)
	IF MV_PAR05 == 1
	TRCell():New(oSection1, "COK_DTHPED" , "QRY", " DT APROVACAO PC "     ,PesqPict('COK',"COK_UPED")    ,TamSX3("COK_UPED")    [1]+1)
	endIf
	TRCell():New(oSection1, "C7_FORNECE" , "QRY", " FORNECEDOR "    	  ,PesqPict('SC7',"C7_FORNECE")	 ,TamSX3("C7_FORNECE")  [1]+1)
	TRCell():New(oSection1, "A2_NOME"    , "QRY", " RAZAO SOCIAL "	      ,PesqPict('SA2',"A2_NOME")	 ,TamSX3("A2_NOME")     [1]+1)
	TRCell():New(oSection1, "A2_CGC"     , "QRY", " CNPJ FORNECEDOR "	  ,PesqPict('SA2',"A2_CGC")	     ,TamSX3("A2_CGC")      [1]+1)
	TRCell():New(oSection1, "D1_DOC"     , "QRY", " DOCUMENTO "	          ,PesqPict('SD1',"D1_DOC")	     ,TamSX3("D1_DOC")      [1]+1)
	TRCell():New(oSection1, "D1_EMISSAO" , "QRY", " DT EMISSAO NF "	      ,PesqPict('SD1',"D1_EMISSAO")	 ,TamSX3("D1_EMISSAO")  [1]+1)
	if MV_PAR05 == 1
	TRCell():New(oSection1, "COH_DTHLPN" , "QRY", " DT PRE-NOTA "	      ,PesqPict('COH',"COH_DTHLPN")	 ,TamSX3("COH_DTHLPN")  [1]+1)
	endIf
	TRCell():New(oSection1, "COH_ULPN"   , "QRY", " RESPONSAVEL PRE-NOTA" ,PesqPict('COH',"COH_ULPN")	 ,TamSX3("COH_ULPN")    [1]+1)
	TRCell():New(oSection1, "D1_DTDIGIT" , "QRY", " DT DIGITACAO "	      ,PesqPict('SD1',"D1_DTDIGIT")	 ,TamSX3("C1_NUM")      [1]+1)
	if MV_PAR05 == 1
	TRCell():New(oSection1, "COH_UCLS"   , "QRY", " RESP.CLASSIFIC. NF"	  ,PesqPict('COH',"COH_UCLS")    ,TamSX3("COH_UCLS")    [1]+1)
	endIf
	TRCell():New(oSection1, "D1_CC"      , "QRY", " CENTRO DE CUSTO "	  ,PesqPict('SD1',"D1_CC")	     ,TamSX3("D1_CC")       [1]+1)
	TRCell():New(oSection1, "D1_XTIPO"   , "QRY", " TIPO "	              ,PesqPict('SD1',"D1_XTIPO")	 ,TamSX3("D1_XTIPO")    [1]+1)
	TRCell():New(oSection1, "D1_XORDINV" , "QRY", " ORD. INVEST"	      ,PesqPict('SD1',"D1_XORDINV")	 ,TamSX3("D1_XORDINV")  [1]+1)


return (oReport)


Static Function PrintRepoA(oReport)

	Local oSection1 := oReport:Section(1)
	Local cQuery    := ""
	Local CQRY2  := ""
	Local CQRY3  := ""
	local aDadoRel :={}
	Local cFil:= ''
	Local cPedido := ''
	Local cItPed := ''
	local cItPed1 := ''
	local  n:= 0

	oSection1:Init()
	oSection1:SetHeaderSection(.T.)

	cQuery := " SELECT C1_FILIAL,C1_EMISSAO,C1_DATPRF,C1_NUM,C1_ITEM,C1_PRODUTO,C1_DESCRI,B1_GRUPO,C1_QUANT,C1_XVLUNIT,C1_XVLESTI,"
	cQuery += " C1_CC,C1_CONTA,C1_XTIPO,C1_XORDINV,"
	cQuery += " ISNULL(CONVERT(VARCHAR(2047),CONVERT(VARBINARY(2047),C1_XOBSWF)),'') AS C1_XOBSWF,"
	cQuery += " C1_SOLICIT,C1_LOCAL,
	cQuery += " (CASE "
	cQuery += "      WHEN C1_QUJE = 0  AND C1_COTACAO = SPACE(LEN(C1_COTACAO)) AND C1_APROV = 'L' AND C1_RESIDUO = '' THEN 'PENDENTE'"
	cQuery += "      WHEN C1_QUJE > 0  AND C1_PEDIDO <>'' AND C1_RESIDUO = '' THEN 'TOTALMENTE ATENDIDA'"
	cQuery += "      WHEN C1_QUJE > 0  AND C1_PEDIDO = '' AND C1_RESIDUO = '' THEN 'PARCIALMENTE ATENDIDA'"
	cQuery += "      WHEN C1_TPSC != '2' And C1_QUJE = 0 And C1_COTACAO <> Space(Len(C1_COTACAO)) And C1_IMPORT <>'S' THEN 'EM COTACAO'"
	cQuery += "      WHEN C1_RESIDUO <>'' THEN 'ELIMINADA POR RESIDUO'"
	cQuery += "      WHEN C1_QUJE = 0 AND (C1_COTACAO = SPACE(LEN(C1_COTACAO)) OR C1_COTACAO = 'IMPORT') AND C1_APROV = 'R' THEN 'REJEITADA'"
	cQuery += "      WHEN C1_QUJE = 0 AND (C1_COTACAO = SPACE(LEN(C1_COTACAO)) OR C1_COTACAO = 'IMPORT') AND C1_APROV = 'B' THEN 'BLOQUEADA'"
	cQuery += "      WHEN C1_TIPO = 2 THEN 'IMPORTACAO'END) AS STATUS_SC,"
	cQuery += " C7_EMISSAO,C7_NUM,C7_ITEM,C7_PRODUTO,C7_QUANT,C7_QUJE,C7_PRECO,C7_TOTAL,C7_DATPRF,"
	cQuery += " C7_FORNECE,"
	cQuery += " C7_LOJA,"
	cQuery += " (CASE "
	cQuery += "     WHEN C7_TIPO <>'1' And C7_RESIDUO='' THEN 'AE,PC' "
	cQuery += "     WHEN C7_TIPO = '2' And C7_RESIDUO='' THEN 'AE Eliminada por Residuo'"
	cQuery += "     WHEN C7_TIPO = '1' And C7_RESIDUO='' THEN 'PC Eliminado por Residuo'"
	cQuery += "     WHEN C7_ACCPROC <> '1' And C7_CONAPRO ='B' And C7_QUJE < C7_QUANT THEN 'Em aprovacao'"
	cQuery += "     WHEN C7_ACCPROC <> '1' And C7_CONAPRO ='R' And C7_QUJE < C7_QUANT THEN 'Rejeitado'"
	cQuery += "     WHEN C7_CONTRA <> '' And C7_RESIDUO = '' THEN 'Pedido de Contrato' "
	cQuery += "     WHEN C7_ACCPROC ='1' THEN 'Integracao com o portal marketplace' "
	cQuery += "     WHEN C7_QUJE = '0' And C7_QTDACLA = '0' THEN 'PC-Pendente' "
	cQuery += "     WHEN C7_QUJE <>'0' And C7_QUJE < C7_QUANT THEN 'PC-Parcialmente Atendido' "
	cQuery += "     WHEN C7_QUJE >= C7_QUANT THEN 'PC-Atendido'"
	cQuery += "     WHEN C7_QTDACLA > 0 THEN 'Em recebimento' "
	cQuery += "     END ) AS STATUS_PC,"
	cQuery += " A2_NOME,A2_CGC,D1_DOC,D1_EMISSAO,D1_DTDIGIT,D1_CONTA,D1_CC,D1_XTIPO,D1_XORDINV "
	IF MV_PAR05 == 1 
	cQuery += ",ZA1_DATA,ZA1_USER,CR_USER,CR_APROV,CR_DATALIB,CR_USERLIB"
	EndIf
	cQuery += " FROM " + RETSQLNAME("SC1") + " C1 "
	cQuery += " FULL JOIN " + RETSQLNAME("SB1") + " B1 ON B1.D_E_L_E_T_='' AND B1.B1_FILIAL=C1.C1_FILIAL AND B1.B1_COD = C1.C1_PRODUTO "
	cQuery += " FULL JOIN " + RETSQLNAME("SC7") + " C7 ON C7.D_E_L_E_T_='' AND C7.C7_FILIAL=C1.C1_FILIAL AND C7.C7_NUMSC = C1.C1_NUM AND C7.C7_ITEMSC = C1.C1_ITEM "
	cQuery += " FULL JOIN " + RETSQLNAME("SA2") + " A2 ON A2.D_E_L_E_T_='' AND A2.A2_COD = C7.C7_FORNECE AND A2.A2_LOJA = C7.C7_LOJA"
	cQuery += " FULL JOIN " + RETSQLNAME("SD1") + " D1 ON D1.D_E_L_E_T_='' AND D1.D1_PEDIDO = C7.C7_NUM AND D1.D1_ITEMPC = C7.C7_ITEM AND D1.D1_FORNECE = C7.C7_FORNECE AND D1.D1_LOJA = C7.C7_LOJA"
	IF MV_PAR05 == 1 
	cQuery += " FULL JOIN " + RETSQLNAME("SCR") + " CR ON CR.D_E_L_E_T_='' AND CR.CR_FILIAL = C7.C7_FILIAL AND CR.CR_NUM = C7.C7_NUM AND CR_TIPO='PC' AND CR_STATUS IN('03','05')"
	
	cQuery += " FULL JOIN " + RETSQLNAME("ZA1") + " Z1 ON Z1.D_E_L_E_T_='' AND C1.C1_FILIAL = Z1.ZA1_FILIAL AND C1.C1_NUM = Z1.ZA1_NUMSC "
	endIf
	cQuery += " WHERE C1.D_E_L_E_T_='' "
	cQuery += " AND C1.C1_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'
	cQuery += " AND C1.C1_FILIAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'

	TCQUERY (cQuery) ALIAS "QRY" NEW

	If Select("QRY") > 0
		dbSelectArea("QRY")
		//	QRY->(dbCloseArea())
	EndIf

	QRY->(dbGoTop())
	oReport:SetMeter(QRY->(RecCount()))
	QRY->(dbGoTop())

	While QRY->(!EOF())

		cFil    := QRY->C1_FILIAL
		cPedido := QRY->C7_NUM
		cItPed  := SUBSTR(QRY->C7_ITEM,2,4)
		cItPed1 := QRY->C7_ITEM
		IF MV_PAR05 == 1
			cqry2 := " SELECT COH_FILIAL,COH_NUMSC,COH_ITEM,COH_DOCPED,COH_ITPED,COH_DTHLPN,COH_ULPN, "
			cqry2 += " COH_DTHCLS,COH_UCLS,COI_DTHSOL,COI_USOL,COI_DTHAPR,COI_UAPR FROM COHV50 COH  "
			cqry2 += " INNER JOIN COIV50 COI ON COI.COI_FILIAL = COH.COH_FILIAL AND COI.COI_NUMSC = COH.COH_NUMSC "
			cqry2 += "       AND COI.COI_ITEM = COH.COH_ITEM AND COI.D_E_L_E_T_='' "
			cqry2 += " WHERE COH.D_E_L_E_T_=''  "
			cqry2 += " AND COH.COH_FILIAL = '"+cFil+"' "
			cqry2 += " AND COH.COH_DOCPED ='"+cPedido+"' "
			cqry2 += " AND COH.COH_ITPED ='"+cItPed+"'"
			cqry2 += " ORDER BY COH_DOCPED,COH_ITPED"
		Else
			cqry2 := " SELECT COH_FILIAL,COH_NUMSC,COH_ITEM,COH_DOCPED,COH_ITPED,COH_DTHLPN,COH_ULPN FROM COHV50 COH "
			//cqry2 += " COH_DTHCLS,COH_UCLS,COI_DTHSOL,COI_USOL,COI_DTHAPR,COI_UAPR FROM COHV50 COH  "
			cqry2 += " INNER JOIN COIV50 COI ON COI.COI_FILIAL = COH.COH_FILIAL AND COI.COI_NUMSC = COH.COH_NUMSC "
			cqry2 += "       AND COI.COI_ITEM = COH.COH_ITEM AND COI.D_E_L_E_T_='' "
			cqry2 += " WHERE COH.D_E_L_E_T_=''  "
			cqry2 += " AND COH.COH_FILIAL = '"+cFil+"' "
			cqry2 += " AND COH.COH_DOCPED ='"+cPedido+"' "
			cqry2 += " AND COH.COH_ITPED ='"+cItPed+"'"
			cqry2 += " ORDER BY COH_DOCPED,COH_ITPED"
		EndIf	

		TCQUERY (cqry2) ALIAS "CQRY2" NEW

		cQry3 := " SELECT COK_DTHPED,COK_UPED,COK_DTHLIB,COK_ULIB FROM COKV50 COK "
		cQry3 += " WHERE COK.D_E_L_E_T_='' "
		cQry3 += " AND COK.COK_FILIAL='"+cFil+"' "
		cQry3 += " AND COK.COK_DOCPED='"+cPedido+"' "
		cQry3 += " AND COK.COK_ITPED='"+cItPed1+"'"

		TCQUERY (cqry3) ALIAS "CQRY3" NEW

		If Select("CQRY2") > 0
			dbSelectArea("CQRY2")
		EndIf
		If Select("CQRY3") > 0
			dbSelectArea("CQRY3")
		EndIf
//	
	IF MV_PAR05 == 1
		AADD(aDadoRel,{QRY->C1_FILIAL,; //1
		QRY->C1_EMISSAO,; //2
		QRY->C1_DATPRF,; //3
		QRY->C1_NUM,; //4
		QRY->C1_LOCAL,; //5
		QRY->C1_ITEM,; //6
		QRY->C1_PRODUTO,;//7
		QRY->C1_DESCRI,; //8
		QRY->C1_QUANT,; //9
		QRY->C1_XVLUNIT,; //10
		QRY->C1_XVLESTI,; //11
		QRY->B1_GRUPO,; //12
		QRY->C1_CC,; //13
		QRY->C1_XTIPO,;//14
		QRY->C1_XORDINV,; //15
		QRY->C1_XOBSWF,; //16
		QRY->C1_SOLICIT,; //17
		QRY->STATUS_SC,; //18
		QRY->C7_NUM,;  //19
		QRY->C7_EMISSAO,; //20
		QRY->C7_ITEM,; //21
		QRY->C7_PRODUTO,; //22
		QRY->C7_QUANT,; //23
		QRY->C7_QUJE,; //24
		QRY->C7_PRECO,; //25
		QRY->C7_TOTAL,; // 26
		QRY->C7_DATPRF,; //27
		QRY->C7_FORNECE,; //28
		QRY->C7_LOJA,; //29
		QRY->STATUS_PC,; //30
		QRY->A2_NOME,; //31
		QRY->A2_CGC,; //32
		QRY->D1_DOC,; //33
		QRY->D1_EMISSAO,; //34
		QRY->D1_DTDIGIT,; //35
		QRY->D1_CC,; //36
		QRY->D1_XTIPO,; //37
		QRY->D1_XORDINV,; //38
		SUBSTR(CQRY2->COH_DTHLPN,1,10),; //39
		CQRY2->COH_ULPN,;  //40
		SUBSTR(CQRY2->COH_DTHCLS,1,10),; //41
		CQRY2->COH_UCLS,;   //42
		SUBSTR(CQRY2->COI_DTHSOL,1,10),;  //43
		CQRY2->COI_USOL,;    //44
		SUBSTR(CQRY2->COI_DTHAPR,1,10),;  //45
		CQRY2->COI_UAPR,;    //46
		SUBSTR(CQRY3->COK_DTHPED,1,10),; //47
		CQRY3->COK_UPED,;   //48
		SUBSTR(CQRY3->COK_DTHLIB,1,10),; //49
		CQRY3->COK_ULIB,; //50
		UsrRetName(QRY->CR_USER),; //51
		UsrRetName(QRY->CR_APROV),; //52 
		QRY->CR_DATALIB,; //53
		UsrRetName(QRY->CR_USERLIB),; //54
        QRY->ZA1_DATA,; //55
	    UsrRetName(QRY->ZA1_USER)}) //56
	Else
		AADD(aDadoRel,{QRY->C1_FILIAL,; //1
		QRY->C1_EMISSAO,; //2
		QRY->C1_DATPRF,; //3
		QRY->C1_NUM,; //4
		QRY->C1_LOCAL,; //5
		QRY->C1_ITEM,; //6
		QRY->C1_PRODUTO,;//7
		QRY->C1_DESCRI,; //8
		QRY->C1_QUANT,; //9
		QRY->C1_XVLUNIT,; //10
		QRY->C1_XVLESTI,; //11
		QRY->B1_GRUPO,; //12
		QRY->C1_CC,; //13
		QRY->C1_XTIPO,;//14
		QRY->C1_XORDINV,; //15
		QRY->C1_XOBSWF,; //16
		QRY->C1_SOLICIT,; //17
		QRY->STATUS_SC,; //18
		QRY->C7_NUM,;  //19
		QRY->C7_EMISSAO,; //20
		QRY->C7_ITEM,; //21
		QRY->C7_PRODUTO,; //22
		QRY->C7_QUANT,; //23
		QRY->C7_QUJE,; //24
		QRY->C7_PRECO,; //25
		QRY->C7_TOTAL,; // 26
		QRY->C7_DATPRF,; //27
		QRY->C7_FORNECE,; //28
		QRY->C7_LOJA,; //29
		QRY->STATUS_PC,; //30
		QRY->A2_NOME,; //31
		QRY->A2_CGC,; //32
		QRY->D1_DOC,; //33
		QRY->D1_EMISSAO,; //34
		QRY->D1_DTDIGIT,; //35
		QRY->D1_CC,; //36
		QRY->D1_XTIPO,; //37
		QRY->D1_XORDINV,; //38
		CQRY2->COH_ULPN,;  //40
		CQRY3->COK_ULIB}) //52
	EndIf
		CQRY2->(dbCloseArea())
		CQRY3->(dbCloseArea())
		QRY->(dbSkip())
		If oReport:Cancel()
			Exit
		EndIf
	Enddo
	QRY->(dbCloseArea())

	FOR I:= 1 TO LEN(aDadoRel)
		oSection1:Cell("C1_FILIAL"):SetValue(aDadoRel[I][1])            // QRY->C1_FILIAL  1
		oSection1:Cell("C1_EMISSAO"):SetValue(stod(aDadoRel[I][2]))     // QRY->C1_EMISSAO 2
		oSection1:Cell("C1_DATPRF"):SetValue(stod(aDadoRel[I][3]))      // QRY->C1_DATPRF  3
		oSection1:Cell("C1_NUM"):SetValue(aDadoRel[I][4])               // QRY->C1_NUM     4
		oSection1:Cell("C1_LOCAL"):SetValue(aDadoRel[I][5])             // QRY->C1_LOCAL   5
		oSection1:Cell("C1_ITEM"):SetValue(aDadoRel[I][6])              // QRY->C1_ITEM    6
		oSection1:Cell("C1_PRODUTO"):SetValue(aDadoRel[I][7])           // QRY->C1_PRODUTO 7
		oSection1:Cell("C1_DESCRI"):SetValue(aDadoRel[I][8] )           // QRY->C1_DESCRI  8
		oSection1:Cell("C1_QUANT"):SetValue(aDadoRel[I][9])             // QRY->C1_QUANT   9
		oSection1:Cell("C1_XVLUNIT"):SetValue(aDadoRel[I][10])          // QRY->C1_XVLUNIT 10
		oSection1:Cell("C1_XVLESTI"):SetValue(aDadoRel[I][11])          // QRY->C1_XVLESTI 11
		oSection1:Cell("B1_GRUPO"):SetValue(aDadoRel[I][12])            // QRY->B1_GRUPO   12
		oSection1:Cell("C1_CC"):SetValue(aDadoRel[I][13])               // QRY->C1_CC      13
		oSection1:Cell("C1_XTIPO"):SetValue(aDadoRel[I][14])            // QRY->C1_XTIPO   14
		oSection1:Cell("C1_XORDINV"):SetValue(aDadoRel[I][15])          // QRY->C1_XORDINV 15
		oSection1:Cell("C1_XOBSWF"):SetValue(aDadoRel[I][16])           // QRY->C1_XOBSWF  16
		oSection1:Cell("C1_SOLICIT"):SetValue(aDadoRel[I][17])          // QRY->C1_SOLICIT 17
		IF MV_PAR05 == 1
			oSection1:Cell("COI_DTHAPR"):SetValue(STOD(aDadoRel[I][iif(MV_PAR05 == 1 ,55,51)]))       // QRY->COI_DTHAPR 18
		EndIf
		oSection1:Cell("STATUS_SC"):SetValue(aDadoRel[I][18])           // QRY->STATUS_SC  19
		oSection1:Cell("C7_NUM"):SetValue(aDadoRel[I][19])              // QRY->C7_NUM     20
		oSection1:Cell("C7_EMISSAO"):SetValue(stod(aDadoRel[I][20]))    // QRY->C7_EMISSAO 21
		oSection1:Cell("C7_ITEM"):SetValue(aDadoRel[I][21])             // QRY->C7_ITEM    22
		oSection1:Cell("C7_PRODUTO"):SetValue(aDadoRel[I][22])          // QRY->C7_PRODUTO 23
		oSection1:Cell("C7_QUANT"):SetValue(aDadoRel[I][23])            // QRY->C7_QUANT   24
		oSection1:Cell("C7_QUJE"):SetValue(aDadoRel[I][24])             // QRY->C7_QUJE    25
		oSection1:Cell("C7_PRECO"):SetValue(aDadoRel[I][25])            // QRY->C7_PRECO   26
		oSection1:Cell("C7_TOTAL"):SetValue(aDadoRel[I][26])            // QRY->C7_TOTAL   27
		oSection1:Cell("C7_DATPRF"):SetValue(STOD(aDadoRel[I][27]))     // QRY->C7_DATPRF  28
		If MV_PAR05 == 1
			oSection1:Cell("COK_UPED"):SetValue(aDadoRel[I][iif(MV_PAR05 == 1 ,48,46)])            // QRY->COK_UPED   29
		EndIf
		oSection1:Cell("C7_LOJA"):SetValue(aDadoRel[I][29])             // QRY->C7_LOJA    31
		oSection1:Cell("STATUS_PC"):SetValue(aDadoRel[I][30])           // QRY->STATUS_PC  32
		If MV_PAR05 == 1
			oSection1:Cell("COK_DTHPED"):SetValue(aDadoRel[I][47])          // QRY->COK_DTHPED 33
		EndIf
		oSection1:Cell("C7_FORNECE"):SetValue(aDadoRel[I][28])          // QRY->C7_FORNECE 30
		oSection1:Cell("A2_NOME"):SetValue(aDadoRel[I][31])             // QRY->A2_NOME    34
		oSection1:Cell("A2_CGC"):SetValue(aDadoRel[I][32])              // QRY->A2_CGC     35
		oSection1:Cell("D1_DOC"):SetValue(aDadoRel[I][33])              // QRY->D1_DOC     36
		oSection1:Cell("D1_EMISSAO"):SetValue(stod(aDadoRel[I][34]))    // QRY->D1_EMISSAO 37
		If MV_PAR05 == 1
			oSection1:Cell("COH_DTHLPN"):SetValue(aDadoRel[I][39])       // QRY->COH_DTHLPN 38
		EndIf
		oSection1:Cell("COH_ULPN"):SetValue(aDadoRel[I][iif(MV_PAR05 == 1 ,40,39)])         // QRY->COH_ULPN   39
		oSection1:Cell("D1_DTDIGIT"):SetValue(stod(aDadoRel[I][35]))    // QRY->D1_DTDIGIT 40
		If MV_PAR05 == 1
			oSection1:Cell("COH_UCLS"):SetValue(aDadoRel[I][iif(MV_PAR05 == 1 ,42,40)]) 
		EndIf				           // QRY->COH_UCLS   41
		oSection1:Cell("D1_CC"):SetValue(aDadoRel[I][36])               // QRY->D1_CC      42
		oSection1:Cell("D1_XTIPO"):SetValue(aDadoRel[I][37])            // QRY->D1_XTIPO   43
		oSection1:Cell("D1_XORDINV"):SetValue(aDadoRel[I][38])          // QRY->D1_XORDINV 44
		oSection1:PrintLine()

	NEXT I
	oSection1:Finish()

return


//======================================================================================================

Static Function Perguntas()

	Local aPergs := {}
	Local 	aCombo          := {"Dt Aprova��o","Somente Solicita"}
	aAdd( aPergs ,{1, "Emissao de "				, CriaVar('C1_EMISSAO',.F.)					,  ,, ,,, 150, .F.} )
	aAdd( aPergs ,{1, "Emissao Ate "			, CriaVar('C1_EMISSAO',.F.)					,  ,, ,,, 150, .F.} )
	aAdd( aPergs ,{1, "Filial De "				, CriaVar('C1_FILIAL',.F.)					,  ,, ,,, 150, .F.} )
	aAdd( aPergs ,{1, "Filial Ate "				, CriaVar('C1_FILIAL',.F.)					,  ,, ,,, 150, .F.} )
	//aAdd( aPergs ,{1, "Tipo Relat"				, CriaVar('C1_FILIAL',.F.)					,  ,, ,,, 150, .F.} )
	aAdd(aPergs, {3, "Tipo Relat?",1,aCombo,50,"",.T.})
	ParamBox(aPergs ,"Parametros ",aRet)

Return

