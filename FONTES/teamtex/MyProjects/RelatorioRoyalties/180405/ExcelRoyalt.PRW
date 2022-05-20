
 #Include "Protheus.ch"
#Include "TopConn.ch"

User Function EXCELROYAL()

Local oButton1
Local oButton2
Local oGet1
Local cGet1 := DATE()
Local oGet2
Local cGet2 := DATE()
Local oGet3
Local cGet3 := Space(6)
Local oGet4
Local cGet4 := "ZZZZZZ"
Local oGet5
Local cGet5 := Space(6)
Local oGet6
Local cGet6 := "ZZZZZZ"
Local oGroup1
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSay6


cGet1:= CTOD("01/"+STRZERO(Month( cGet1)  ,2)+"/"+STRZERO(Year( cGet1),4))
cGet2:= CTOD("01/"+STRZERO(Month( cGet2)+1,2)+"/"+STRZERO(Year( cGet2),4))-1


Private oDlg
Private	 ALISTBOX1 :={}

  DEFINE MSDIALOG oDlg TITLE "Relat๓rio de Royalties" FROM 000, 000  TO 380, 420 COLORS 0, 16777215 PIXEL

    @ 007, 008 GROUP oGroup1 TO 169, 187 OF oDlg COLOR 0, 16777215 PIXEL

    @ 020, 027 SAY oSay1 PROMPT "Data Inicial" 					SIZE 052, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 020, 088 MSGET oGet1 VAR cGet1 							SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL

    @ 038, 027 SAY oSay2 PROMPT "Data Final" 					SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 038, 088 MSGET oGet2 VAR cGet2 							SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL

    @ 058, 027 SAY oSay3 PROMPT "Cliente Inicial" 			 	SIZE 056, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 058, 088 MSGET oGet3 VAR cGet3	F3 "SA1" 				SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL

    @ 077, 027 SAY oSay4 PROMPT "Cliente Final" 	 			SIZE 047, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 077, 088 MSGET oGet4 VAR cGet4	F3 "SA1" 							SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL

    @ 095, 027 SAY oSay5 PROMPT "Produto Inicial" 				SIZE 048, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 095, 088 MSGET oGet5 VAR cGet5    F3 "SB1"				SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL

    @ 113, 027 SAY oSay6 PROMPT "Produto Final" 				SIZE 044, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 113, 088 MSGET oGet6 VAR cGet6	F3 "SB1"				SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL

    @ 144, 060 BUTTON oButton1 PROMPT "&Sair" 			ACTION(oDlg:End());
    															SIZE 037, 012 OF oDlg PIXEL
    @ 144, 110 BUTTON oButton2 PROMPT "&Confirmar"  	ACTION(SelecDados(cGet1,cGet2,cGet3,cGet4,cGet5,cGet6), oDlg:End());
    															SIZE 037, 012 OF oDlg PIXEL

  ACTIVATE MSDIALOG oDlg CENTERED

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEXCELCUST บAutor  ณMicrosiga           บ Data ณ  07/26/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SelecDados(xData1, xData2,xCli1,xCli2, xProd1, xProd2)
Local cPic_Val 	:= PesqPict("SD2", "D2_PRCVEN"	, 13)		// Pictures usadas para a edicao dos valores
Local cPic_Qtde	:= PesqPict("SD2", "D2_QUANT"	, 13)
Local _cAlias	:= GetNextAlias()
Local cQuery	:= ""
Local xAno 		:= ""
Local xMes 		:= ""
Local _cCliente	:= ""
Local nVPC		:=0		//VPC	A1_XPVPC	//% cadastrada no cliente
Default xData1 	:= data()
Default xData2 	:= data()

xAno	:= STRZERO(Year( xData1),4)
xMes	:= STRZERO(Month(xData1),2)

xData1	:= STRZERO(Year( xData1),4) + STRZERO(Month(xData1),2) + STRZERO(Day(xData1),2)
xData2	:= STRZERO(Year( xData2),4) + STRZERO(Month(xData2),2) + STRZERO(Day(xData2),2)


cQuery := "SELECT SF2.F2_DOC, SF2.F2_SERIE,SF2.F2_CLIENTE,SF2.F2_LOJA,SF2.F2_EMISSAO,SF2.F2_MOEDA, SF2.F2_XDTENT,"
cQuery += " SD2.D2_COD, SD2.D2_PRUNIT,SD2.D2_CF, SA1.A1_PAIS,"
cQuery += " SUM(SD2.D2_QUANT) QTDE "

cQuery += " FROM "			+ RetSqlTab("SF2") 	+ "  "

cQuery += " INNER JOIN " 	+ RetSqlTab("SD2")	+ "  "
cQuery += " ON SD2.D2_FILIAL  = '" +xFilial("SD2")	+ "' "
cQuery += " AND SD2.D2_DOC = SF2.F2_DOC "
cQuery += " AND SD2.D2_SERIE = SF2.F2_SERIE "
cQuery += " AND SD2.D_E_L_E_T_ <>'*' "

cQuery += " INNER JOIN " 	+ RetSqlTab("SB1") 	+ "  "
cQuery += " ON SB1.B1_FILIAL  = '" +xFilial("SB1")	+ "' "
cQuery += " AND SB1.B1_COD = SD2.D2_COD "
cQuery += " AND SB1.B1_COD >='"+ xProd1 + "' "
cQuery += " AND SB1.B1_COD <='"+ xProd2 + "' "
cQuery += " AND SB1.B1_XCODISN<>'' "
cQuery += " AND SB1.D_E_L_E_T_ <>'*' "

cQuery += " INNER JOIN " 	+ RetSqlTab("SA1")	+ "  "
cQuery += " ON SA1.A1_FILIAL  = '" +xFilial("SA1")	+ "' "
cQuery += " AND SA1.A1_COD = SD2.D2_CLIENTE "
cQuery += " AND SA1.A1_LOJA = SD2.D2_LOJA "
cQuery += " AND SA1.A1_COD >='"+xCli1+"' "
cQuery += " AND SA1.A1_COD <='"+xCli2+"' "
cQuery += " AND SA1.D_E_L_E_T_ <>'*' "

cQuery += " WHERE SF2.F2_FILIAL  = '" +xFilial("SF2")	+ "' "
cQuery += " AND SF2.F2_EMISSAO Between '" + xData1 + "' AND '"+xData2+ "' "
cQuery += " AND SF2.D_E_L_E_T_ <>'*' "

cQuery += " GROUP BY  SF2.F2_DOC, SF2.F2_SERIE,SF2.F2_CLIENTE,SF2.F2_LOJA,SF2.F2_EMISSAO,SF2.F2_MOEDA, "
cQuery += " SF2.F2_XDTENT,SD2.D2_COD,SD2.D2_PRUNIT,SD2.D2_CF, SA1.A1_PAIS "


cQuery := 	ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), _cAlias,.F.,.T.)

While (_cAlias)->(!EOF())

	//----------------------------------------------------------------
	//Busca Dados do Cliente
	//----------------------------------------------------------------
 		DbSelectArea("SA1")
 		DbSetOrder(1)
 		DbSeek(xFilial("SA1")+(_cAlias)->F2_CLIENTE+(_cAlias)->F2_LOJA)

	//----------------------------------------------------------------
	//Busca os dados do Produto
	//----------------------------------------------------------------
	DbSelectArea("SB1")
	DbSetOrder(1)
	If DbSeek(xFilial("SB1")+ (_cAlias)->D2_COD)
		//----------------------------------------------------------------
		//Calculo da Margem Liquida
		//----------------------------------------------------------------
		nValRoyalties	:=0
		If SB1->B1_XPEROYA > 0
			nValRoyalties	:= ((_cAlias)->D2_PRUNIT * SB1->B1_XPEROYA)/100
		Endif

		xDevol:=0

		//----------------------------------------------------------------
		//Descricao do Pais
		//----------------------------------------------------------------
		_cNomPais	:= IIF(Empty(SA1->A1_PAIS),"BRASIL",Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_DESCR" ))

		Aadd(	aListBox1									,;
				{	(_cAlias)->F2_XDTENT					,;	//Data Entrega Mercadoria
					(_cAlias)->F2_EMISSAO					,;	//Emissใo
					(_cAlias)->F2_DOC +(_cAlias)->F2_SERIE	,;	//"Nบ DA NFE"
					_cNomPais								,;	//"Paํs de Destino"
					SB1->B1_CODBAR							,;	//"N๚mero EAN / UPC"
					SB1->B1_XCODISN							,;	//"C๓digo de Mercadoria Disney"
					SB1->B1_XDESDIS							,;	//"Descri็ใo da Mercadoria Disney"
					SB1->B1_XPERSON							,;	//"Descri็ใo da Personagem"
					SB1->B1_COD								,;	//"N๚mero de SKU"
					SB1->B1_DESC							,;	//"Descri็ใo de SKU"
					SB1->B1_XCANAL							,;	//"Canal de Distribui็ใo"
					SA1->A1_NOME							,;	//"Varejista"
					(_cAlias)->F2_MOEDA						,;	//"C๓digo de Moeda"
					(_cAlias)->D2_CF						,;	//"CFOP"
					(_cAlias)->QTDE							,;	//"Quantidade Bruta"
					xDevol									,;	//"Devolu็๕es"
					(_cAlias)->QTDE							,;	//"Quantidade Liquida"
					(_cAlias)->D2_PRUNIT					,;	//"Pre็o Unitario"
					SB1->B1_XPEROYA			 				,;	//"%Royalties"
					nValRoyalties							})	//Valor Royalties
    Endif
    (_cAlias)->(DbSkip())
End
DbCloseArea(_cAlias)

//----------------------------------------------------------------
//Buscar Devolucoes
//----------------------------------------------------------------
_cAlias2	:= GetNextAlias()

cQuery:= "SELECT SF1.F1_DOC, SF1.F1_SERIE,SF1.F1_FORNECE,SF1.F1_LOJA,SF1.F1_EMISSAO,SF1.F1_MOEDA, "
cQuery+= " SD1.D1_COD, SD1.D1_VUNIT ,SD1.D1_CF, SA1.A1_PAIS, "
cQuery+= " SUM(SD1.D1_QUANT) QTDE "

cQuery+= " FROM "+ RetSqlName("SF1") +" SF1 "

cQuery += " INNER JOIN " 				+ RetSqlTab("SD1") 	+ "  "
cQuery += " ON SD1.D1_FILIAL  ='" 		+xFilial("SD1") 	+ "' "
cQuery += " AND SD1.D1_DOC = SF1.F1_DOC "
cQuery += " AND SD1.D1_SERIE = SF1.F1_SERIE "
cQuery += " AND SD1.D_E_L_E_T_ <>'*' "

cQuery += " INNER JOIN " 				+ RetSqlTab("SB1") 	+ "  "
cQuery += " ON SB1.B1_FILIAL  = '" 		+xFilial("SB1") 	+ "' "
cQuery += " AND SB1.B1_COD = SD1.D1_COD "
cQuery += " AND SB1.B1_COD >='"+ xProd1 + "' "
cQuery += " AND SB1.B1_COD <='"+ xProd2 + "' "
cQuery += " AND SB1.B1_XCODISN<>''
cQuery += " AND SB1.D_E_L_E_T_ <>'*'

cQuery += " INNER JOIN " 				+ RetSqlTab("SA1") 	+ "  "
cQuery += " ON SA1.A1_FILIAL  = '" 		+xFilial("SA1") 	+ "' "
cQuery += " AND SA1.A1_COD = SF1.F1_FORNECE "
cQuery += " AND SA1.A1_LOJA = SF1.F1_LOJA "
cQuery += " AND SA1.A1_COD >='"+xCli1+"' "
cQuery += " AND SA1.A1_COD <='"+xCli2+"' "
cQuery += " AND SA1.D_E_L_E_T_ <>'*' "

cQuery += " WHERE SF1.F1_FILIAL  ='" 		+xFilial("SF1") 	+ "' "
cQuery += " AND SF1.F1_EMISSAO Between '" 	+ xData1 + "' AND '"+xData2+ "' "
cQuery += " AND SF1.F1_TIPO ='D' "
cQuery += " AND SF1.D_E_L_E_T_ <>'*' "

cQuery += " GROUP BY  SF1.F1_DOC, SF1.F1_SERIE,SF1.F1_FORNECE,SF1.F1_LOJA,SF1.F1_EMISSAO,SF1.F1_MOEDA, "
cQuery += " SD1.D1_COD, SD1.D1_VUNIT,SD1.D1_CF, SA1.A1_PAIS "

cQuery := 	ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), _cAlias2,.F.,.T.)

While (_cAlias2)->(!EOF())

	//----------------------------------------------------------------
	//Busca Dados do Cliente
	//----------------------------------------------------------------
 	DbSelectArea("SA1")
 	DbSetOrder(1)
 	DbSeek(xFilial("SA1")+(_cAlias2)->F1_FORNECE+(_cAlias2)->F1_LOJA)

	//----------------------------------------------------------------
	//Busca os dados do Produto
	//----------------------------------------------------------------
	DbSelectArea("SB1")
	DbSetOrder(1)
	If DbSeek(xFilial("SB1")+ (_cAlias2)->D1_COD)
		//----------------------------------------------------------------
		//Calculo da Margem Liquida
		//----------------------------------------------------------------
		nValRoyalties	:=0
		If SB1->B1_XPEROYA > 0
			nValRoyalties	:= ((_cAlias2)->D1_VUNIT * SB1->B1_XPEROYA)/100
		Endif

		xDevol := (_cAlias2)->QTDE*-1

		//----------------------------------------------------------------
		//Descricao do Pais
		//----------------------------------------------------------------
		_cNomPais	:= IIF(Empty(SA1->A1_PAIS),"BRASIL",Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_DESCR" ))

		Aadd(	aListBox1											,;
				{   ""												,;	//Data Entrega Mercadoria
				(_cAlias2)->F1_EMISSAO							,;	//Emissใo
				(_cAlias2)->F1_DOC +(_cAlias2)->F1_SERIE		,;	//"Nบ DA NFE"
				_cNomPais   									,;	//"Paํs de Destino"
				SB1->B1_CODBAR									,;	//"N๚mero EAN / UPC"
				SB1->B1_XCODISN									,;	//"C๓digo de Mercadoria Disney"
				SB1->B1_XDESDIS									,;	//"Descri็ใo da Mercadoria Disney"
				SB1->B1_XPERSON									,;	//"Descri็ใo da Personagem"
				SB1->B1_COD										,;	//"N๚mero de SKU"
				SB1->B1_DESC									,;	//"Descri็ใo de SKU"
				SB1->B1_XCANAL									,;	//"Canal de Distribui็ใo"
				SA1->A1_NOME									,;	//"Varejista"
				(_cAlias2)->F1_MOEDA							,;	//"C๓digo de Moeda"
				(_cAlias2)->D1_CF								,;	//"CFOP"
				0			    								,;	//"Quantidade Bruta"
				xDevol											,;	//"Devolu็๕es"
				(_cAlias2)->QTDE*-1								,;	//"Quantidade Liquida"
				(_cAlias2)->D1_VUNIT*-1							,;	//"Pre็o Unitario"
				SB1->B1_XPEROYA			 						,;	//"%Royalties"
				(((_cAlias2)->D1_VUNIT*(_cAlias2)->D1_VUNIT)/100)*-1	})	//Valor do Royalties
	Endif
	(_cAlias2)->(DbSkip())
End
DbCloseArea(_cAlias2)

GeraPlan()
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEXCELROYALT บAutor  ณMicrosiga           บ Data ณ  07/26/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GeraPlan()
local nI			:= 0
local cLocArq		:= ""
local oExcelApp		:= MsExcel():New()
Local cArquivo		:= "EXCELROYALT_"+DtoS(Date())+"_"+StrTran(Left(Time(),5),":","")+".xls"
Local cLocalServ	:= "relatorio\"
Local nHandle		:= FCreate( cLocalServ + cArquivo , 0 )
Local cLinha		:= ""

Begin Sequence

	If  (nHandle < 0)
		Alert("Problema para criar a planilha!")
		Break
	EndIf

	FWrite(nHandle, FAcento( fCabe็alho() ))

	For nI:= 1 To Len(aListBox1)

		//Alternar a cor da linha
		cLinha := If((nI % 2) <= 0, fLinha2(), fLinha1())

		cLinha := StrTran(cLinha, "AAAAAAAAAA", DtoC(StoD(aListBox1[nI][01])))  // Data Entrega
		cLinha := StrTran(cLinha, "BBBBBBBBBB", DtoC(StoD(aListBox1[nI][02])))  // Data Emissao
		cLinha := StrTran(cLinha, "CCCCCCCCCC", aListBox1[nI][03])  // NFE
		cLinha := StrTran(cLinha, "DDDDDDDDDD", aListBox1[nI][04])  // Pais Destino
		cLinha := StrTran(cLinha, "EEEEEEEEEE", aListBox1[nI][05])  // Numero EAN / UPC
		cLinha := StrTran(cLinha, "FFFFFFFFFF", aListBox1[nI][06])  // Codigo de Mercadoria Disney
		cLinha := StrTran(cLinha, "GGGGGGGGGG", aListBox1[nI][07])  // Descricao de Mercadoria Disney
		cLinha := StrTran(cLinha, "HHHHHHHHHH", aListBox1[nI][08])  // Descricao da Personagem
		cLinha := StrTran(cLinha, "JJJJJJJJJJ", aListBox1[nI][09])  // Numero do SKU
		cLinha := StrTran(cLinha, "LLLLLLLLLL", aListBox1[nI][10])  // Descricao do SKU
		cLinha := StrTran(cLinha, "MMMMMMMMMM", aListBox1[nI][11])  // Canal de distribuicao
		cLinha := StrTran(cLinha, "NNNNNNNNNN", aListBox1[nI][12])  // Varejista
		cLinha := StrTran(cLinha, "OOO"       , CValToChar(aListBox1[nI][13]))  // Codigo de Moeda
		cLinha := StrTran(cLinha, "PPPP"      , aListBox1[nI][14])  // CFOP
		cLinha := StrTran(cLinha, "999999999999999", CValToChar(aListBox1[nI][15]))  // Quantidade Bruta
		cLinha := StrTran(cLinha, "999999999999998", CValToChar(aListBox1[nI][16]))  // Devolucoes
		cLinha := StrTran(cLinha, "999999999999997", CValToChar(aListBox1[nI][17]))  // Quantidade Liquida
		cLinha := StrTran(cLinha, "999999999999996", CValToChar(aListBox1[nI][18]))  // Preco Unitario
		cLinha := StrTran(cLinha, "999999999999995", CValToChar(aListBox1[nI][19]))  // % Royalties
		cLinha := StrTran(cLinha, "999999999999994", CValToChar(aListBox1[nI][20]))  // Valor Royalties

		FWrite(nHandle, FAcento( cLinha ))

	Next nI

	FWrite(nHandle, fFinal())
	FClose(nHandle)

	cLocArq := cGetFile("Todos os Arquivos|*.*", OemToAnsi("Informe o diret๓rio para gravacao do arquivo Excel"), 0, "SERVIDOR\", .T., GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY)
	If __CopyFile(cLocalServ + cArquivo, cLocArq + cArquivo)
		MsgInfo("Relat๓rio gerado em: " + cLocArq + cArquivo)
		oExcelApp:WorkBooks:Open(cLocArq + cArquivo)
		oExcelApp:SetVisible(.T.)
	Else
		MsgInfo("Arquivo nใo copiado para o Diretorio " + cLocArq + cArquivo)
	Endif

End Sequence

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEXCELCUST บAutor  ณMicrosiga           บ Data ณ  07/27/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CustoMes(xProd,xAno, xMes,cB1Desc,nCustImport,nValSelo,nPrevAdm,nVPC)

Local _cAlias2		:= GetNextAlias()
Local cQuery		:= ""

cQuery := " SELECT SB1.B1_COD, SB1.B1_DESC, B1_XFORUSO, SZP.ZP_CUSTIMP, SZP.ZP_CUSTSEL ,SZP.ZP_CUSTADM "
cQuery += " FROM "	+ RetSqlTab("SB1") + "  "
cQuery += " LEFT JOIN "	+ RetSqlTab("SZP") + "  "
cQuery += " ON SZP.ZP_FILIAL = '" +xFilial("SZP")	+ "' "
cQuery += " AND SZP.ZP_ANO ='" + xAno + "' "
cQuery += " AND SZP.ZP_MES ='" + xMes + "' "
cQuery += " AND SZP.ZP_PRODUTO = SB1.B1_COD "
cQuery += " AND SZP.D_E_L_E_T_ <>'*' "
cQuery += " WHERE SB1.B1_FILIAL  = '" 	+xFilial("SB1")	+ "' "
cQuery += " AND SB1.B1_COD = '"			+xProd+"' "
cQuery += " AND SB1.D_E_L_E_T_ <>'*' "

cQuery := 	ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), _cAlias2,.F.,.T.)

If (_cAlias2)->(!EOF())
	cB1Desc		:=(_cAlias2)->B1_DESC
	nCustImport	:=(_cAlias2)->ZP_CUSTIMP 	//Custo mensal de importacao vpc
	nValSelo	:=(_cAlias2)->ZP_CUSTSEL	//VALOR SELO DE INMETRO
	nPrevAdm	:=(_cAlias2)->ZP_CUSTADM	//PROVISรO ADMINISTRATIVA
Endif

DbCloseArea(_cAlias2)

Return


STATIC Function fCabe็alho()

Local cXML := '<?xml version="1.0"?>' + CRLF
cXML += '<?mso-application progid="Excel.Sheet"?>' + CRLF
cXML += '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"' + CRLF
cXML += ' xmlns:o="urn:schemas-microsoft-com:office:office"' + CRLF
cXML += ' xmlns:x="urn:schemas-microsoft-com:office:excel"' + CRLF
cXML += ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"' + CRLF
cXML += ' xmlns:html="http://www.w3.org/TR/REC-html40">' + CRLF
cXML += ' <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">' + CRLF
cXML += '  <Author>Microsiga Protheus</Author>' + CRLF
cXML += '  <LastAuthor>Antonio Carlos Ferreira</LastAuthor>' + CRLF
cXML += '  <Created>2011-11-11T00:00:00Z</Created>' + CRLF
cXML += '  <Version>15.00</Version>' + CRLF
cXML += ' </DocumentProperties>' + CRLF
cXML += ' <OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office">' + CRLF
cXML += '  <AllowPNG/>' + CRLF
cXML += ' </OfficeDocumentSettings>' + CRLF
cXML += ' <ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
cXML += '  <WindowHeight>9750</WindowHeight>' + CRLF
cXML += '  <WindowWidth>20430</WindowWidth>' + CRLF
cXML += '  <WindowTopX>0</WindowTopX>' + CRLF
cXML += '  <WindowTopY>0</WindowTopY>' + CRLF
cXML += '  <ProtectStructure>False</ProtectStructure>' + CRLF
cXML += '  <ProtectWindows>False</ProtectWindows>' + CRLF
cXML += ' </ExcelWorkbook>' + CRLF
cXML += ' <Styles>' + CRLF
cXML += '  <Style ss:ID="Default" ss:Name="Normal">' + CRLF
cXML += '   <Alignment ss:Vertical="Bottom"/>' + CRLF
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + CRLF
cXML += '  </Style>' + CRLF
cXML += '  <Style ss:ID="s63">' + CRLF
cXML += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>' + CRLF
cXML += '   <Borders>' + CRLF
cXML += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="3"' + CRLF
cXML += '     ss:Color="#FFFFFF"/>' + CRLF
cXML += '   </Borders>' + CRLF
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12" ss:Color="#333399"' + CRLF
cXML += '    ss:Bold="1"/>' + CRLF
cXML += '   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>' + CRLF
cXML += '  </Style>' + CRLF
cXML += '  <Style ss:ID="s65">' + CRLF
cXML += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>' + CRLF
cXML += '   <Borders>' + CRLF
cXML += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#4F81BD"/>' + CRLF
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#4F81BD"/>' + CRLF
cXML += '   </Borders>' + CRLF
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF"' + CRLF
cXML += '    ss:Bold="1"/>' + CRLF
cXML += '   <Interior ss:Color="#4F81BD" ss:Pattern="Solid"/>' + CRLF
cXML += '  </Style>' + CRLF
cXML += '  <Style ss:ID="s66">' + CRLF
cXML += '   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>' + CRLF
cXML += '   <Borders>' + CRLF
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#B8CCE4"/>' + CRLF
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#B8CCE4"/>' + CRLF
cXML += '   </Borders>' + CRLF
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + CRLF
cXML += '   <Interior ss:Color="#B8CCE4" ss:Pattern="Solid"/>' + CRLF
cXML += '  </Style>' + CRLF
cXML += '  <Style ss:ID="s68">' + CRLF
cXML += '   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>' + CRLF
cXML += '   <Borders>' + CRLF
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#DCE6F1"/>' + CRLF
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#DCE6F1"/>' + CRLF
cXML += '   </Borders>' + CRLF
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + CRLF
cXML += '   <Interior ss:Color="#DCE6F1" ss:Pattern="Solid"/>' + CRLF
cXML += '  </Style>' + CRLF
cXML += '  <Style ss:ID="s70">' + CRLF
cXML += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>' + CRLF
cXML += '   <Borders>' + CRLF
cXML += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#4F81BD"/>' + CRLF
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#4F81BD"/>' + CRLF
cXML += '   </Borders>' + CRLF
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF"' + CRLF
cXML += '    ss:Bold="1"/>' + CRLF
cXML += '   <Interior ss:Color="#4F81BD" ss:Pattern="Solid"/>' + CRLF
cXML += '   <NumberFormat ss:Format="#,##0.0000"/>' + CRLF
cXML += '  </Style>' + CRLF
cXML += '  <Style ss:ID="s71">' + CRLF
cXML += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>' + CRLF
cXML += '   <Borders>' + CRLF
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#B8CCE4"/>' + CRLF
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#B8CCE4"/>' + CRLF
cXML += '   </Borders>' + CRLF
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + CRLF
cXML += '   <Interior ss:Color="#B8CCE4" ss:Pattern="Solid"/>' + CRLF
cXML += '   <NumberFormat ss:Format="#,##0.0000"/>' + CRLF
cXML += '  </Style>' + CRLF
cXML += '  <Style ss:ID="s72">' + CRLF
cXML += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>' + CRLF
cXML += '   <Borders>' + CRLF
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#DCE6F1"/>' + CRLF
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#DCE6F1"/>' + CRLF
cXML += '   </Borders>' + CRLF
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + CRLF
cXML += '   <Interior ss:Color="#DCE6F1" ss:Pattern="Solid"/>' + CRLF
cXML += '   <NumberFormat ss:Format="#,##0.0000"/>' + CRLF
cXML += '  </Style>' + CRLF
cXML += '  <Style ss:ID="s73">' + CRLF
cXML += '   <NumberFormat ss:Format="#,##0.0000"/>' + CRLF
cXML += '  </Style>' + CRLF
cXML += '  <Style ss:ID="s74">' + CRLF
cXML += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>' + CRLF
cXML += '   <Borders>' + CRLF
cXML += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#4F81BD"/>' + CRLF
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#4F81BD"/>' + CRLF
cXML += '   </Borders>' + CRLF
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF"' + CRLF
cXML += '    ss:Bold="1"/>' + CRLF
cXML += '   <Interior ss:Color="#4F81BD" ss:Pattern="Solid"/>' + CRLF
cXML += '   <NumberFormat ss:Format="Fixed"/>' + CRLF
cXML += '  </Style>' + CRLF
cXML += '  <Style ss:ID="s75">' + CRLF
cXML += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>' + CRLF
cXML += '   <Borders>' + CRLF
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#B8CCE4"/>' + CRLF
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#B8CCE4"/>' + CRLF
cXML += '   </Borders>' + CRLF
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + CRLF
cXML += '   <Interior ss:Color="#B8CCE4" ss:Pattern="Solid"/>' + CRLF
cXML += '   <NumberFormat ss:Format="Fixed"/>' + CRLF
cXML += '  </Style>' + CRLF
cXML += '  <Style ss:ID="s76">' + CRLF
cXML += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>' + CRLF
cXML += '   <Borders>' + CRLF
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#DCE6F1"/>' + CRLF
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#DCE6F1"/>' + CRLF
cXML += '   </Borders>' + CRLF
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + CRLF
cXML += '   <Interior ss:Color="#DCE6F1" ss:Pattern="Solid"/>' + CRLF
cXML += '   <NumberFormat ss:Format="Fixed"/>' + CRLF
cXML += '  </Style>' + CRLF
cXML += '  <Style ss:ID="s77">' + CRLF
cXML += '   <NumberFormat ss:Format="Fixed"/>' + CRLF
cXML += '  </Style>' + CRLF
cXML += '  <Style ss:ID="s78">' + CRLF
cXML += '   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>' + CRLF
cXML += '   <Borders>' + CRLF
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#B8CCE4"/>' + CRLF
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#B8CCE4"/>' + CRLF
cXML += '   </Borders>' + CRLF
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + CRLF
cXML += '   <Interior ss:Color="#B8CCE4" ss:Pattern="Solid"/>' + CRLF
cXML += '   <NumberFormat ss:Format="Short Date"/>' + CRLF
cXML += '  </Style>' + CRLF
cXML += '  <Style ss:ID="s79">' + CRLF
cXML += '   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>' + CRLF
cXML += '   <Borders>' + CRLF
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#DCE6F1"/>' + CRLF
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#DCE6F1"/>' + CRLF
cXML += '   </Borders>' + CRLF
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + CRLF
cXML += '   <Interior ss:Color="#DCE6F1" ss:Pattern="Solid"/>' + CRLF
cXML += '   <NumberFormat ss:Format="Short Date"/>' + CRLF
cXML += '  </Style>' + CRLF
cXML += '  <Style ss:ID="s80">' + CRLF
cXML += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>' + CRLF
cXML += '   <Borders>' + CRLF
cXML += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#4F81BD"/>' + CRLF
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#4F81BD"/>' + CRLF
cXML += '   </Borders>' + CRLF
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF"' + CRLF
cXML += '    ss:Bold="1"/>' + CRLF
cXML += '   <Interior ss:Color="#4F81BD" ss:Pattern="Solid"/>' + CRLF
cXML += '   <NumberFormat ss:Format="Short Date"/>' + CRLF
cXML += '  </Style>' + CRLF
cXML += '  <Style ss:ID="s81">' + CRLF
cXML += '   <NumberFormat ss:Format="Short Date"/>' + CRLF
cXML += '  </Style>' + CRLF
cXML += '  <Style ss:ID="s82">' + CRLF
cXML += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>' + CRLF
cXML += '   <Borders>' + CRLF
cXML += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#4F81BD"/>' + CRLF
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#4F81BD"/>' + CRLF
cXML += '   </Borders>' + CRLF
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF"' + CRLF
cXML += '    ss:Bold="1"/>' + CRLF
cXML += '   <Interior ss:Color="#4F81BD" ss:Pattern="Solid"/>' + CRLF
cXML += '   <NumberFormat ss:Format="@"/>' + CRLF
cXML += '  </Style>' + CRLF
cXML += '  <Style ss:ID="s83">' + CRLF
cXML += '   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>' + CRLF
cXML += '   <Borders>' + CRLF
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#B8CCE4"/>' + CRLF
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#B8CCE4"/>' + CRLF
cXML += '   </Borders>' + CRLF
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + CRLF
cXML += '   <Interior ss:Color="#B8CCE4" ss:Pattern="Solid"/>' + CRLF
cXML += '   <NumberFormat ss:Format="@"/>' + CRLF
cXML += '  </Style>' + CRLF
cXML += '  <Style ss:ID="s84">' + CRLF
cXML += '   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>' + CRLF
cXML += '   <Borders>' + CRLF
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#DCE6F1"/>' + CRLF
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#DCE6F1"/>' + CRLF
cXML += '   </Borders>' + CRLF
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + CRLF
cXML += '   <Interior ss:Color="#DCE6F1" ss:Pattern="Solid"/>' + CRLF
cXML += '   <NumberFormat ss:Format="@"/>' + CRLF
cXML += '  </Style>' + CRLF
cXML += '  <Style ss:ID="s85">' + CRLF
cXML += '   <NumberFormat ss:Format="@"/>' + CRLF
cXML += '  </Style>' + CRLF
cXML += ' </Styles>' + CRLF
cXML += ' <Worksheet ss:Name="1-Relatorio_Movimentacao_Disn">' + CRLF
cXML += '  <Table ss:ExpandedColumnCount="20" ss:ExpandedRowCount="4" x:FullColumns="1"' + CRLF
cXML += '   x:FullRows="1" ss:DefaultRowHeight="15">' + CRLF
cXML += '   <Column ss:StyleID="s81" ss:Width="151.5"/>' + CRLF
cXML += '   <Column ss:StyleID="s81" ss:Width="56.25"/>' + CRLF
cXML += '   <Column ss:Width="79.5"/>' + CRLF
cXML += '   <Column ss:Width="99"/>' + CRLF
cXML += '   <Column ss:StyleID="s85" ss:Width="105.75"/>' + CRLF
cXML += '   <Column ss:StyleID="s85" ss:Width="178.5"/>' + CRLF
cXML += '   <Column ss:Width="257.25"/>' + CRLF
cXML += '   <Column ss:Width="231"/>' + CRLF
cXML += '   <Column ss:StyleID="s85" ss:Width="85.5"/>' + CRLF
cXML += '   <Column ss:Width="290.25"/>' + CRLF
cXML += '   <Column ss:Width="198"/>' + CRLF
cXML += '   <Column ss:Width="145.5"/>' + CRLF
cXML += '   <Column ss:Width="99"/>' + CRLF
cXML += '   <Column ss:StyleID="s85" ss:Width="26.25"/>' + CRLF
cXML += '   <Column ss:StyleID="s73" ss:Width="122.25" ss:Span="3"/>' + CRLF
cXML += '   <Column ss:Index="19" ss:StyleID="s77" ss:Width="99"/>' + CRLF
cXML += '   <Column ss:StyleID="s73" ss:Width="122.25"/>' + CRLF
cXML += '   <Row ss:AutoFitHeight="0">' + CRLF
cXML += '    <Cell ss:MergeAcross="19" ss:StyleID="s63"><Data ss:Type="String">Relat๓rio de Royalties</Data></Cell>' + CRLF
cXML += '   </Row>' + CRLF
cXML += '   <Row ss:AutoFitHeight="0">' + CRLF
cXML += '    <Cell ss:StyleID="s80"><Data ss:Type="String">Data Entrega Mercadoria</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s80"><Data ss:Type="String">Emissใo</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Nบ DA NFE</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Paํs de Destino</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s82"><Data ss:Type="String">N๚mero EAN / UPC</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s82"><Data ss:Type="String">C๓digo de Mercadoria Disney</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Descri็ใo da Mercadoria Disney</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Descri็ใo da Personagem</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s82"><Data ss:Type="String">N๚mero de SKU</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Descri็ใo de SKU</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Canal de Distribui็ใo</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Varejista</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">C๓digo de Moeda</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s82"><Data ss:Type="String">CFOP</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s70"><Data ss:Type="String">Quantidade Bruta</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s70"><Data ss:Type="String">Devolu็๕es</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s70"><Data ss:Type="String">Quantidade Liquida</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s70"><Data ss:Type="String">Pre็o Unitario</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s74"><Data ss:Type="String">%Royalties</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s70"><Data ss:Type="String">Valor Royalties</Data></Cell>' + CRLF
cXML += '   </Row>' + CRLF

Return cXML


STATIC Function fLinha1()

Local cXML := '   <Row ss:AutoFitHeight="0">' + CRLF
cXML += '    <Cell ss:StyleID="s78"><Data ss:Type="String">AAAAAAAAAA</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s78"><Data ss:Type="String">BBBBBBBBBB</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s66"><Data ss:Type="String">CCCCCCCCCC</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s66"><Data ss:Type="String">DDDDDDDDDD</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s83"><Data ss:Type="String">EEEEEEEEEE</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s83"><Data ss:Type="String">FFFFFFFFFF</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s66"><Data ss:Type="String">GGGGGGGGGG</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s66"><Data ss:Type="String">HHHHHHHHHH</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s83"><Data ss:Type="String">JJJJJJJJJJ</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s66"><Data ss:Type="String">LLLLLLLLLL</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s66"><Data ss:Type="String">MMMMMMMMMM</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s66"><Data ss:Type="String">NNNNNNNNNN</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s66"><Data ss:Type="String">OOO</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s83"><Data ss:Type="String">PPPP</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s71"><Data ss:Type="Number">999999999999999</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s71"><Data ss:Type="Number">999999999999998</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s71"><Data ss:Type="Number">999999999999997</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s71"><Data ss:Type="Number">999999999999996</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s75"><Data ss:Type="Number">999999999999995</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s71"><Data ss:Type="Number">999999999999994</Data></Cell>' + CRLF
cXML += '   </Row>' + CRLF

Return cXML


STATIC Function fLinha2()

Local cXML := '   <Row ss:AutoFitHeight="0">' + CRLF
cXML += '    <Cell ss:StyleID="s79"><Data ss:Type="String">AAAAAAAAAA</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s79"><Data ss:Type="String">BBBBBBBBBB</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s68"><Data ss:Type="String">CCCCCCCCCC</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s68"><Data ss:Type="String">DDDDDDDDDD</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s84"><Data ss:Type="String">EEEEEEEEEE</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s84"><Data ss:Type="String">FFFFFFFFFF</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s68"><Data ss:Type="String">GGGGGGGGGG</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s68"><Data ss:Type="String">HHHHHHHHHH</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s84"><Data ss:Type="String">JJJJJJJJJJ</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s68"><Data ss:Type="String">LLLLLLLLLL</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s68"><Data ss:Type="String">MMMMMMMMMM</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s68"><Data ss:Type="String">NNNNNNNNNN</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s68"><Data ss:Type="String">OOO</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s84"><Data ss:Type="String">PPPP</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s72"><Data ss:Type="Number">999999999999999</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s72"><Data ss:Type="Number">999999999999998</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s72"><Data ss:Type="Number">999999999999997</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s72"><Data ss:Type="Number">999999999999996</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s76"><Data ss:Type="Number">999999999999995</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s72"><Data ss:Type="Number">999999999999994</Data></Cell>' + CRLF
cXML += '   </Row>' + CRLF

Return cXML


STATIC Function fFinal()

Local cXML := '  </Table>' + CRLF
cXML += '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
cXML += '   <PageSetup>' + CRLF
cXML += '    <Header x:Margin="0.31496062000000002"/>' + CRLF
cXML += '    <Footer x:Margin="0.31496062000000002"/>' + CRLF
cXML += '    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"' + CRLF
cXML += '     x:Right="0.511811024" x:Top="0.78740157499999996"/>' + CRLF
cXML += '   </PageSetup>' + CRLF
cXML += '   <Unsynced/>' + CRLF
cXML += '   <Print>' + CRLF
cXML += '    <ValidPrinterInfo/>' + CRLF
cXML += '    <PaperSizeIndex>9</PaperSizeIndex>' + CRLF
cXML += '    <VerticalResolution>0</VerticalResolution>' + CRLF
cXML += '   </Print>' + CRLF
cXML += '   <Selected/>' + CRLF
cXML += '   <Panes>' + CRLF
cXML += '    <Pane>' + CRLF
cXML += '     <Number>3</Number>' + CRLF
cXML += '     <RangeSelection>R1C1:R1C20</RangeSelection>' + CRLF
cXML += '    </Pane>' + CRLF
cXML += '   </Panes>' + CRLF
cXML += '   <ProtectObjects>False</ProtectObjects>' + CRLF
cXML += '   <ProtectScenarios>False</ProtectScenarios>' + CRLF
cXML += '  </WorksheetOptions>' + CRLF
cXML += ' </Worksheet>' + CRLF
cXML += '</Workbook>' + CRLF

Return cXML


//===========================================================================================
/*/{Protheus.doc} FAcento
Fun็ใo para converter o acento para o acento Excel.

@param		cExpressao	Expressao para conversao
@param		cTexto		Texto convertido.

@author		Antonio C Ferreira
@since		31/03/2017
/*/
//===========================================================================================
STATIC Function FAcento( cExpressao )

	Local nA      := 0
	Local cAcento := "ว็รใี๕มษอำฺแ้ํ๓๚ยโส๊ิ๔ÜüÛ๛ภเศ่ฬ์า๒ู๙"
	Local aAcento := {"ร","รง","ร","รฃ","ร•","รต","ร" + chr(129),"ร","ร" + chr(141),"ร“","ร","รก","รฉ","รญ","รณ","รบ","ร","รข","ร","รช","ร”","รด","ร","รผ","ร","รป","ร€","ร ","ร","รจ","ร","รฌ","ร’","รฒ","ร","รน"}
	Local cChar   := ""
	Local cTexto  := ""

	For nA := 1 to Len(cExpressao)
	    cChar  := SubStr(cExpressao,nA,1)
	    nP     := At(cChar, cAcento)
	    cTexto += If(nP <= 0, cChar, aAcento[nP])
	Next nA

Return ( cTexto )