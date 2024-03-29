#Include "Protheus.ch"
#Include "TopConn.ch"

User Function EXCELCUST()

Local oButton1
Local oButton2
Local oGet1
Local cGet1 := DATE()
Local oGet2
Local cGet2 := DATE()
Local oGet3
Local cGet3 := Space(6)
Local oGet4
Local cGet4 := "01"
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

Local oGroup1
Local oRadMenu1
Local nRadMenu1 := 1
Local oRadMenu2
Local nRadMenu2 := 1

Private oDlg

Private	 ALISTBOX1 :={}

cGet1:= CTOD("01/"+STRZERO(Month( cGet1)  ,2)+"/"+STRZERO(Year( cGet1),4))
cGet2:= CTOD("01/"+STRZERO(Month( cGet2)+1,2)+"/"+STRZERO(Year( cGet2),4))-1



  DEFINE MSDIALOG oDlg TITLE "Relat�rio de Custo" FROM 000, 000  TO 350, 420 COLORS 0, 16777215 PIXEL

    @ 008, 008 GROUP oGroup1 TO 162, 201 OF oDlg COLOR 0, 16777215 PIXEL

    @ 022, 026 RADIO oRadMenu1 VAR nRadMenu1 ITEMS "Portugues","Frances" SIZE 092, 022 OF oDlg COLOR 0, 16777215 PIXEL

    @ 045, 026 SAY oSay1 PROMPT "Data Inicial" 		SIZE 052, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 045, 086 MSGET oGet1 VAR cGet1 				SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL

    @ 063, 026 SAY oSay2 PROMPT "Data Final" 		SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 063, 086 MSGET oGet2 VAR cGet2 				SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL

    @ 080, 026 SAY oSay3 PROMPT "Cliente" 			SIZE 056, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 080, 086 MSGET oGet3 VAR cGet3 F3 "SA1" 		SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL

   	@ 097, 026 SAY oSay4 PROMPT "Loja" 				SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 097, 086 MSGET oGet4 VAR cGet4	 			SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL

    @ 114, 026 SAY oSay5 PROMPT "Grupo Cliente" 	SIZE 056, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 114, 086 MSGET oGet5 VAR cGet5 F3 "ACY" 		SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL


    @ 137, 056 BUTTON oButton1 PROMPT "&Sair" 			ACTION(oDlg:End());
    															SIZE 037, 012 OF oDlg PIXEL
    @ 137, 107 BUTTON oButton2 PROMPT "&Confirmar"  	ACTION(SelecDados(	cGet1		,;
    																		cGet2		,;
    																		cGet3		,;
    																		cGet4		,;
    																		cGet5		,;
    																		nRadMenu1)	, oDlg:End());
    															SIZE 037, 012 OF oDlg PIXEL

  ACTIVATE MSDIALOG oDlg CENTERED

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EXCELCUST �Autor  �Microsiga           � Data �  07/26/17   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function SelecDados(xData1, xData2,xCli1,xLoja,xGrupo1,nRadMenu1)
Local cPic_Val 	:= PesqPict("SD2", "D2_PRCVEN"	, 13)		// Pictures usadas para a edicao dos valores
Local cPic_Qtde	:= PesqPict("SD2", "D2_QUANT"	, 13)
Local _cAlias	:= GetNextAlias()
Local _cAlias2	:= GetNextAlias()

Local cQuery	:= ""
Local xAno 		:= ""
Local xMes 		:= ""
Local _cCliente	:= ""
Local nVPC		:=0		//VPC	A1_XPVPC	//% cadastrada no cliente
Default xData1 := data()
Default xData2 := data()

xAno	:= STRZERO(Year( xData1),4)
xMes	:= STRZERO(Month(xData1),2)

xData1	:= STRZERO(Year( xData1),4) + STRZERO(Month(xData1),2) + STRZERO(Day(xData1),2)
xData2	:= STRZERO(Year( xData2),4) + STRZERO(Month(xData2),2) + STRZERO(Day(xData2),2)


cQuery := " SELECT A1_XPVPC "
cQuery += " FROM "	+ RetSqlTab("SA1") + "  "
cQuery += " WHERE SA1.A1_FILIAL  = '" 	+xFilial("SA1")	+ "' "
If !Empty(xCli1)
	cQuery += " AND SA1.A1_COD = '"	+xCli1+ "' "
	cQuery += " AND SA1.A1_LOJA= '" +xLoja+ "' "
ElseIf !Empty(xGrupo1)
	cQuery += " AND SA1.A1_GRPVEN = '" 	+xGrupo1+"' "
Else
	Alert("Favor informar um cliente ou um grupo de venda para extrair o relat�rio!")
	Return
Endif
cQuery += " AND SA1.D_E_L_E_T_<>'*' "

cQuery := 	ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), _cAlias2,.F.,.T.)

If (_cAlias2)->(!EOF())
	nVPC :=SA1->A1_XPVPC
Endif

cQuery := " SELECT D2_COD PRODUTO, "
cQuery += "	SUM(D2_QUANT) QTDE, "
cQuery += "	SUM(D2_TOTAL) TOTPROD, "
cQuery += "	(SUM(D2_PRCVEN)/SUM(D2_QUANT)) MEDIAPRECO, "
cQuery += "	(SUM(D2_VALICM)/SUM(D2_QUANT)) MEDIAICMS, "
cQuery += "	(SUM(D2_VALPIS)/SUM(D2_QUANT)) MEDIAPIS, "
cQuery += "	(SUM(D2_VALCOF)/SUM(D2_QUANT)) MEDIACOF, "
cQuery += "	(SUM(D2_VALFRE)/SUM(D2_QUANT)) MEDIAFRETE, "
cQuery += "	(SUM(D2_COMIS1)/SUM(D2_QUANT)) MEDIACOMIS, "
cQuery += "	0 TOTMES "
cQuery += " FROM "	+ RetSqlTab("SD2") 		+ "  "

If !Empty(xGrupo1)
	cQuery += " INNER JOIN " + RetSqlTab("SA1") + "  "
	cQuery += " ON SA1.A1_COD = D2_CLIENTE "
	cQuery += " AND SA1.A1_LOJA = D2_LOJA
	cQuery += " AND SA1.A1_GRPVEN = '" 	+xGrupo1+"' "
	cQuery += " AND SA1.D_E_L_E_T_<>'*' "
Endif

cQuery += " WHERE D2_FILIAL  = '" 	+xFilial("SD2")	+ "' "

If !Empty(xCli1)
	cQuery += " AND D2_CLIENTE = '"	+xCli1+"' "
	cQuery += " AND D2_LOJA	   = '" +xLoja+"' "
Endif
cQuery += " AND D2_EMISSAO >= '"	+xData1+"' "
cQuery += " AND D2_EMISSAO <= '"	+xData2+"' "
cQuery += " AND D2_EMISSAO >= '"	+xData1+"' "
cQuery += " AND D2_EMISSAO <= '"	+xData2+"' "

cQuery += " AND SD2.D_E_L_E_T_ <>'*' "
cQuery += " GROUP BY D2_COD "

	cQuery := 	ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), _cAlias,.F.,.T.)

	While (_cAlias)->(!EOF())

        cB1Desc		:=""
		nCustImport	:=0 	//Custo mensal de importacao vpc
		nValCaixa	:=0		//VALOR CAIXA
		nValSelo	:=0		//VALOR SELO DE INMETRO
		nRoyalties	:=0 	//DE ACORDO COM RELATPRIO DE ROYALTIES verificar onde fica o cadastro
		nPrevAdm	:=0		//PROVIS�O ADMINISTRATIVA
		nImpBenef	:=0 	//IMPOSTO SOBRE BENEFICIOS Criar o campo na tela de controle logistico.
		nCustLogist	:=0 	//Custo Logistico  - Novo Campo

		CustoMes((_cAlias)->PRODUTO,xAno, xMes,@cB1Desc,@nCustImport,@nValSelo,@nPrevAdm,@nVPC,@nImpBenef,@nCustLogist)

		//----------------------------------------------------------------
		//Calculo da Margem Liquida
		//----------------------------------------------------------------
		nMargemLiq := (_cAlias)->MEDIAPRECO - (	nCustImport				+;
												(_cAlias)->MEDIAICMS	+;
												(_cAlias)->MEDIAPIS		+;
												(_cAlias)->MEDIACOF		+;
												nValCaixa				+;
												nValSelo				+;
												nVPC					+;
												(_cAlias)->MEDIAFRETE	+;
												(_cAlias)->MEDIACOMIS	+;
												nRoyalties				+;
												nPrevAdm+nImpBenef		+;
												nCustLogist		)
		//----------------------------------------------------------------
		//Calculo do Percentual da Margem Liquida
		//----------------------------------------------------------------
		nPerMargLiq	:=( (_cAlias)->TOTPROD/(_cAlias)->MEDIAPRECO) * 100

		//----------------------------------------------------------------
		//Calculo do Total de Vendas
		//----------------------------------------------------------------
		nTotVen		:=(_cAlias)->MEDIAPRECO*(_cAlias)->QTDE

		//----------------------------------------------------------------
		//Calculo Margem Liquida X Quantidade
		//----------------------------------------------------------------
		nMgLiqVsQtd := nMargemLiq*(_cAlias)->QTDE

		//----------------------------------------------------------------
		//Calculo VPC
		//----------------------------------------------------------------
		nValVPC:=0
		If nVPC>0
			nValVPC	:= (nVPC*(_cAlias)->MEDIAPRECO)/100
		Endif

		//----------------------------------------------------------------
		//Somar Custo Logistico na previsao administrativa
		//----------------------------------------------------------------
		//nPrevAdm+=nCustLogist

 		Aadd(	aListBox1										,;
				{	(_cAlias)->PRODUTO							,;	//01 C�DIGO PRODUTO
					cB1Desc										,;	//02 DESCRI��O PRODUTO
					((_cAlias)->QTDE)							,;	//03 QUANTIDADE VENDIDA MENSAL		Somat�rio de todas as NFs que contenham esse produto
					((_cAlias)->MEDIAPRECO)	   					,;	//04 VALOR UNIT�RIO DE VENDA		Somat�rio do valor do produto de todas as NFs que contenham esse produto / quantidade vendida mensal
					(nCustImport)*-1		   					,;	//05 CUSTO MENSAL IMPORTA��O		valor Tela Custo Margem Liquida
					((_cAlias)->MEDIAICMS)*-1					,;	//06 I.C.M.S.						Somat�rio do valor do ICMS do produto de todas as NFs que contenham esse produto / quantidade vendida mensal
					((_cAlias)->MEDIAPIS)*-1	 				,;	//07 P.I.S.							Somat�rio do valor do PIS do produto de todas as NFs que contenham esse produto / quantidade vendida mensal
					((_cAlias)->MEDIACOF)*-1	 				,;	//08 COFINS							Somat�rio do valor do COFINS do produto de todas as NFs que contenham esse produto / quantidade vendida mensal
					(nValCaixa)*-1			 					,;	//09 VALOR CAIXA					Verificar se existe no GCV, ou na estrutura do produto
					(nValSelo)*-1			   					,;	//10 VALOR SELO DE INMETRO			VALOR TELA Custo Margem Liquida
					nValVPC*-1								 	,;	//11 VPC							A1_XPVPC	//% cadastrada no cliente
					((_cAlias)->MEDIAFRETE)*-1  				,;	//12 VALOR FRETE DE VENDA			Somat�rio do Frete da nota  / quantidade vendida mensal
					((_cAlias)->MEDIACOMIS)*-1 					,;	//13 COMISS�O 1						Somat�rio Comiss�o do produto na nota / quantidade vendida mensal
					(nRoyalties)*-1			   					,;	//14 ROYALTIES						DE ACORDO COM RELATPRIO DE ROYALTIES verificar onde fica o cadastro
					(nPrevAdm)*-1								,;	//15 PROVIS�O ADMINISTRATIVA		VALRO TELA Custo Margem Liquida
					(nCustLogist)*-1							,;	//16 PROVIS�O ADMINISTRATIVA		VALRO TELA Custo Margem Liquida
					(nImpBenef)*(_cAlias)->MEDIAPRECO*-1		,;	//17 IMPOSTO SOBRE BENEFICIOS		VERIFICAR
					(nMargemLiq)				   				,;	//18 MARGEM L�QUIDA VALOR
					(nPerMargLiq)				   				,;	//19 MARGEM L�QUIDA %				total / valor unit
					(nTotVen)					   				,;	//20 TOTAL VENDAS					total x qtd
					(nMgLiqVsQtd)			   					})	//21 Margem Liquida X Qtade

    	(_cAlias)->(DbSkip())
	End
	DbCloseArea(_cAlias)

	GeraPlan(nRadMenu1)

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EXCELCUST �Autor  �Microsiga           � Data �  07/26/17   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GeraPlan(nIdioma)
local nI			:= 0
local cLocArq		:= ""
local oExcelApp		:= MsExcel():New()
Local cArquivo		:= "EXCELCUST_"+DtoS(Date())+"_"+StrTran(Left(Time(),5),":","")+".xls"
Local cLocalServ	:= "relatorio\"
Local nHandle		:= FCreate( cLocalServ + cArquivo , 0 )
Local cLinha		:= ""

DEFAULT nIdioma	:=1


Begin Sequence

	If  (nHandle < 0)
		Alert("Problema para criar a planilha!")
		Break
	EndIf

	FWrite(nHandle, FAcento( fCabe�alho() ))

	FWrite(nHandle, FAcento( fTitulo(nIdioma) ))

	For nI:= 1 To Len(aListBox1)

		//Alternar a cor da linha
		cLinha := If((nI % 2) <= 0, fLinha2(), fLinha1())

		cLinha := StrTran(cLinha, "AAAAAAAAAAAAAAA", aListBox1[nI][01])
		cLinha := StrTran(cLinha, "BBBBBBBBBBBBBBB", aListBox1[nI][02])
		cLinha := StrTran(cLinha, "999999999999999", CValToChar(aListBox1[nI][03]))
		cLinha := StrTran(cLinha, "999999999999998", CValToChar(aListBox1[nI][04]))
		cLinha := StrTran(cLinha, "999999999999997", CValToChar(aListBox1[nI][05]))
		cLinha := StrTran(cLinha, "999999999999996", CValToChar(aListBox1[nI][06]))
		cLinha := StrTran(cLinha, "999999999999995", CValToChar(aListBox1[nI][07]))
		cLinha := StrTran(cLinha, "999999999999994", CValToChar(aListBox1[nI][08]))
		cLinha := StrTran(cLinha, "999999999999993", CValToChar(aListBox1[nI][09]))
		cLinha := StrTran(cLinha, "999999999999992", CValToChar(aListBox1[nI][10]))
		cLinha := StrTran(cLinha, "999999999999991", CValToChar(aListBox1[nI][11]))
		cLinha := StrTran(cLinha, "999999999999990", CValToChar(aListBox1[nI][12]))
		cLinha := StrTran(cLinha, "999999999999989", CValToChar(aListBox1[nI][13]))
		cLinha := StrTran(cLinha, "999999999999988", CValToChar(aListBox1[nI][14]))
		cLinha := StrTran(cLinha, "999999999999987", CValToChar(aListBox1[nI][15]))
		cLinha := StrTran(cLinha, "999999999999986", CValToChar(aListBox1[nI][16]))
		cLinha := StrTran(cLinha, "999999999999985", CValToChar(aListBox1[nI][17]))
		cLinha := StrTran(cLinha, "999999999999984", CValToChar(aListBox1[nI][18]))
		cLinha := StrTran(cLinha, "999999999999983", CValToChar(aListBox1[nI][19]))
		cLinha := StrTran(cLinha, "999999999999982", CValToChar(aListBox1[nI][20]))
		cLinha := StrTran(cLinha, "999999999999981", CValToChar(aListBox1[nI][21]))

		FWrite(nHandle, FAcento( cLinha ))

	Next nI

	FWrite(nHandle, fFinal())
	FClose(nHandle)

	cLocArq := cGetFile("Todos os Arquivos|*.*", OemToAnsi("Informe o diret�rio para gravacao do arquivo Excel"), 0, "SERVIDOR\", .T., GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY)
	If __CopyFile(cLocalServ + cArquivo, cLocArq + cArquivo)
		MsgInfo("Relat�rio gerado em: " + cLocArq + cArquivo)
		oExcelApp:WorkBooks:Open(cLocArq + cArquivo)
		oExcelApp:SetVisible(.T.)
	Else
		MsgInfo("Arquivo n�o copiado para o Diretorio " + cLocArq + cArquivo)
	Endif

End Sequence

Return



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EXCELCUST �Autor  �Microsiga           � Data �  07/27/17   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function CustoMes(xProd,xAno, xMes,cB1Desc,nCustImport,nValSelo,nPrevAdm,nVPC,nImpBenef,nCustLogist)

Local _cAlias2		:= GetNextAlias()
Local cQuery		:= ""

cQuery := " SELECT SB1.B1_COD, SB1.B1_DESC, B1_XFORUSO, SZP.ZP_CUSTIMP, SZP.ZP_CUSTSEL ,SZP.ZP_CUSTADM,SZP.ZP_IMPBENE,SZP.ZP_CUSTLOG "
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
	nPrevAdm	:=(_cAlias2)->ZP_CUSTADM	//PROVIS�O ADMINISTRATIVA
	nImpBenef	:=(_cAlias2)->ZP_IMPBENE	//Imposto Beneficio
	nCustLogist	:=(_cAlias2)->ZP_CUSTLOG 	//Custo Logistica
Endif

DbCloseArea(_cAlias2)

Return


STATIC Function fCabe�alho()

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
cXML += '  <LastSaved>2018-03-21T12:39:51Z</LastSaved>' + CRLF
cXML += '  <Version>15.00</Version>' + CRLF
cXML += ' </DocumentProperties>' + CRLF
cXML += ' <OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office">' + CRLF
cXML += '  <AllowPNG/>' + CRLF
cXML += ' </OfficeDocumentSettings>' + CRLF
cXML += ' <ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
cXML += '  <WindowHeight>7680</WindowHeight>' + CRLF
cXML += '  <WindowWidth>16755</WindowWidth>' + CRLF
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
cXML += '  <Style ss:ID="s87">' + CRLF
cXML += '   <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>' + CRLF
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
cXML += '  <Style ss:ID="s90">' + CRLF
cXML += '   <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>' + CRLF
cXML += '   <NumberFormat ss:Format="#,##0.0000"/>' + CRLF
cXML += '  </Style>' + CRLF
cXML += '  <Style ss:ID="s96">' + CRLF
cXML += '   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>' + CRLF
cXML += '   <Borders>' + CRLF
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#B8CCE4"/>' + CRLF
cXML += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#DCE6F1"/>' + CRLF
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#B8CCE4"/>' + CRLF
cXML += '   </Borders>' + CRLF
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + CRLF
cXML += '   <Interior ss:Color="#D9E1F2" ss:Pattern="Solid"/>' + CRLF
cXML += '  </Style>' + CRLF
cXML += '  <Style ss:ID="s97">' + CRLF
cXML += '   <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>' + CRLF
cXML += '   <Borders>' + CRLF
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#B8CCE4"/>' + CRLF
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#B8CCE4"/>' + CRLF
cXML += '   </Borders>' + CRLF
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + CRLF
cXML += '   <Interior ss:Color="#D9E1F2" ss:Pattern="Solid"/>' + CRLF
cXML += '   <NumberFormat ss:Format="#,##0.0000"/>' + CRLF
cXML += '  </Style>' + CRLF
cXML += '  <Style ss:ID="s98">' + CRLF
cXML += '   <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>' + CRLF
cXML += '   <Borders>' + CRLF
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#B8CCE4"/>' + CRLF
cXML += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#B8CCE4"/>' + CRLF
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#B8CCE4"/>' + CRLF
cXML += '   </Borders>' + CRLF
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + CRLF
cXML += '   <Interior ss:Color="#D9E1F2" ss:Pattern="Solid"/>' + CRLF
cXML += '   <NumberFormat ss:Format="#,##0.0000"/>' + CRLF
cXML += '  </Style>' + CRLF
cXML += '  <Style ss:ID="s99">' + CRLF
cXML += '   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>' + CRLF
cXML += '   <Borders>' + CRLF
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#B8CCE4"/>' + CRLF
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#B8CCE4"/>' + CRLF
cXML += '   </Borders>' + CRLF
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + CRLF
cXML += '   <Interior ss:Color="#D9E1F2" ss:Pattern="Solid"/>' + CRLF
cXML += '  </Style>' + CRLF
cXML += '  <Style ss:ID="s100">' + CRLF
cXML += '   <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>' + CRLF
cXML += '   <Borders>' + CRLF
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#DCE6F1"/>' + CRLF
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#DCE6F1"/>' + CRLF
cXML += '   </Borders>' + CRLF
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + CRLF
cXML += '   <Interior ss:Color="#D9E1F2" ss:Pattern="Solid"/>' + CRLF
cXML += '   <NumberFormat ss:Format="#,##0.0000"/>' + CRLF
cXML += '  </Style>' + CRLF
cXML += '  <Style ss:ID="s102">' + CRLF
cXML += '   <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>' + CRLF
cXML += '   <Borders>' + CRLF
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#B8CCE4"/>' + CRLF
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#B8CCE4"/>' + CRLF
cXML += '   </Borders>' + CRLF
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + CRLF
cXML += '   <Interior ss:Color="#B4C6E7" ss:Pattern="Solid"/>' + CRLF
cXML += '   <NumberFormat ss:Format="#,##0.0000"/>' + CRLF
cXML += '  </Style>' + CRLF
cXML += '  <Style ss:ID="s103">' + CRLF
cXML += '   <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>' + CRLF
cXML += '   <Borders>' + CRLF
cXML += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#DCE6F1"/>' + CRLF
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#B8CCE4"/>' + CRLF
cXML += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#B8CCE4"/>' + CRLF
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#B8CCE4"/>' + CRLF
cXML += '   </Borders>' + CRLF
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + CRLF
cXML += '   <Interior ss:Color="#B4C6E7" ss:Pattern="Solid"/>' + CRLF
cXML += '   <NumberFormat ss:Format="#,##0.0000"/>' + CRLF
cXML += '  </Style>' + CRLF
cXML += '  <Style ss:ID="s104">' + CRLF
cXML += '   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>' + CRLF
cXML += '   <Borders>' + CRLF
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#B8CCE4"/>' + CRLF
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF
cXML += '     ss:Color="#B8CCE4"/>' + CRLF
cXML += '   </Borders>' + CRLF
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + CRLF
cXML += '   <Interior ss:Color="#B4C6E7" ss:Pattern="Solid"/>' + CRLF
cXML += '  </Style>' + CRLF
cXML += ' </Styles>' + CRLF
cXML += ' <Worksheet ss:Name="1-WorkSheet">' + CRLF
cXML += '  <Table ss:ExpandedColumnCount="21" ss:ExpandedRowCount="4" x:FullColumns="1"' + CRLF
cXML += '   x:FullRows="1" ss:DefaultRowHeight="15">' + CRLF
cXML += '   <Column ss:Width="108"/>' + CRLF
cXML += '   <Column ss:Width="290.25"/>' + CRLF
cXML += '   <Column ss:StyleID="s90" ss:Width="166.5"/>' + CRLF
cXML += '   <Column ss:StyleID="s90" ss:Width="153" ss:Span="1"/>' + CRLF
cXML += '   <Column ss:Index="6" ss:StyleID="s90" ss:Width="122.25" ss:Span="3"/>' + CRLF
cXML += '   <Column ss:Index="10" ss:StyleID="s90" ss:Width="140.25"/>' + CRLF
cXML += '   <Column ss:StyleID="s90" ss:Width="122.25"/>' + CRLF
cXML += '   <Column ss:StyleID="s90" ss:Width="133.5"/>' + CRLF
cXML += '   <Column ss:StyleID="s90" ss:Width="122.25" ss:Span="1"/>' + CRLF
cXML += '   <Column ss:Index="15" ss:StyleID="s90" ss:Width="153"/>' + CRLF
cXML += '   <Column ss:StyleID="s90" ss:Width="122.25"/>' + CRLF
cXML += '   <Column ss:StyleID="s90" ss:Width="159.75"/>' + CRLF
cXML += '   <Column ss:StyleID="s90" ss:Width="133.5" ss:Span="1"/>' + CRLF
cXML += '   <Column ss:Index="20" ss:StyleID="s90" ss:Width="122.25"/>' + CRLF
cXML += '   <Column ss:StyleID="s90" ss:Width="180"/>' + CRLF
cXML += '   <Row ss:AutoFitHeight="0">' + CRLF
cXML += '    <Cell ss:MergeAcross="20" ss:StyleID="s63"><Data ss:Type="String">Relat�rio Custo Mensal</Data></Cell>' + CRLF
cXML += '   </Row>' + CRLF

Return cXML


STATIC Function fTitulo(nIdioma)

Local cXML := '   <Row ss:AutoFitHeight="0">' + CRLF

If  (nIdioma == 1)
	cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">C�DIGO PRODUTO</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">DESCRI��O PRODUTO</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">QUANTIDADE VENDIDA MENSAL</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">VALOR UNIT�RIO DE VENDA</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">CUSTO MENSAL IMPORTA��O</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">I.C.M.S.</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">P.I.S.</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">COFINS</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">VALOR CAIXA</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">VALOR SELO DE INMETRO</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">VPC</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">VALOR FRETE DE VENDA</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">COMISS�O 1</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">ROYALTIES</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">PROVIS�O ADMINISTRATIVA</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">CUSTO LOGISTICO</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">IMPOSTO SOBRE BENEFICIOS</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">MARGEM L�QUIDA VALOR</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">MARGEM L�QUIDA %</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">TOTAL VENDAS</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">MARGEM L�QUIDA X QUANTIDADE</Data></Cell>' + CRLF
Else
	cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">GENCODE</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">DESCRIPTION</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">QUANTIT� VENDU</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">VALEUR UNITAIRE</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">CO�T MENSUEL</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">I.C.M.S.</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">P.I.S.</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">COFINS</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">COLIS</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">TIMBRE INMETRO</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">VPC</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">FRET DE VENTE</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">COMMISSION</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">ROYALTIES</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">PROVISION ADMINISTRATIF</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">CO�T LOGISTIQUE</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">IMP�T SUR B�N�FICES</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">B�N�FICE FINALE</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">B�N�FICE FINALE %</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">TOTAL CHIFFRES D'+chr(39)+'AFFAIRE</Data></Cell>' + CRLF
	cXML += '    <Cell ss:StyleID="s87"><Data ss:Type="String">TOTAL B�N�FICE</Data></Cell>' + CRLF
EndIf
cXML += '   </Row>' + CRLF

Return cXML


STATIC Function fLinha1()

Local cXML := '   <Row ss:AutoFitHeight="0">' + CRLF
cXML += '    <Cell ss:StyleID="s104"><Data ss:Type="String" x:Ticked="1">AAAAAAAAAAAAAAA</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s104"><Data ss:Type="String" x:Ticked="1">BBBBBBBBBBBBBBB</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s103"><Data ss:Type="Number">999999999999999</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s102"><Data ss:Type="Number">999999999999998</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s102"><Data ss:Type="Number">999999999999997</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s102"><Data ss:Type="Number">999999999999996</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s102"><Data ss:Type="Number">999999999999995</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s102"><Data ss:Type="Number">999999999999994</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s102"><Data ss:Type="Number">999999999999993</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s102"><Data ss:Type="Number">999999999999992</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s102"><Data ss:Type="Number">999999999999991</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s102"><Data ss:Type="Number">999999999999990</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s102"><Data ss:Type="Number">999999999999989</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s102"><Data ss:Type="Number">999999999999988</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s102"><Data ss:Type="Number">999999999999987</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s102"><Data ss:Type="Number">999999999999986</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s102"><Data ss:Type="Number">999999999999985</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s102"><Data ss:Type="Number">999999999999984</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s102"><Data ss:Type="Number">999999999999983</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s102"><Data ss:Type="Number">999999999999982</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s102"><Data ss:Type="Number">999999999999981</Data></Cell>' + CRLF
cXML += '   </Row>' + CRLF

Return cXML


STATIC Function fLinha2()

Local cXML := '   <Row ss:AutoFitHeight="0">' + CRLF
cXML += '    <Cell ss:StyleID="s99"><Data ss:Type="String" x:Ticked="1">AAAAAAAAAAAAAAA</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s96"><Data ss:Type="String" x:Ticked="1">BBBBBBBBBBBBBBB</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s100"><Data ss:Type="Number">999999999999999</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s98"><Data ss:Type="Number">999999999999998</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s97"><Data ss:Type="Number">999999999999997</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s97"><Data ss:Type="Number">999999999999996</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s97"><Data ss:Type="Number">999999999999995</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s97"><Data ss:Type="Number">999999999999994</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s97"><Data ss:Type="Number">999999999999993</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s97"><Data ss:Type="Number">999999999999992</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s97"><Data ss:Type="Number">999999999999991</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s97"><Data ss:Type="Number">999999999999990</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s97"><Data ss:Type="Number">999999999999989</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s97"><Data ss:Type="Number">999999999999988</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s97"><Data ss:Type="Number">999999999999987</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s97"><Data ss:Type="Number">999999999999986</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s97"><Data ss:Type="Number">999999999999985</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s97"><Data ss:Type="Number">999999999999984</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s97"><Data ss:Type="Number">999999999999983</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s97"><Data ss:Type="Number">999999999999982</Data></Cell>' + CRLF
cXML += '    <Cell ss:StyleID="s97"><Data ss:Type="Number">999999999999981</Data></Cell>' + CRLF
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
cXML += '     <RangeSelection>R1C1:R1C21</RangeSelection>' + CRLF
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
Fun��o para converter o acento para o acento Excel.

@param		cExpressao	Expressao para conversao
@param		cTexto		Texto convertido.

@author		Antonio C Ferreira
@since		31/03/2017
/*/
//===========================================================================================
STATIC Function FAcento( cExpressao )

	Local nA      := 0
	Local cAcento := "������������������������������������"
	Local aAcento := {"Ç","ç","Ã","ã","Õ","õ","�" + chr(129),"É","�" + chr(141),"Ó","Ú","á","é","í","ó","ú","Â","â","Ê","ê","Ô","ô","Ü","ü","Û","û","À","à","È","è","Ì","ì","Ò","ò","Ù","ù"}
	Local cChar   := ""
	Local cTexto  := ""

	For nA := 1 to Len(cExpressao)
	    cChar  := SubStr(cExpressao,nA,1)
	    nP     := At(cChar, cAcento)
	    cTexto += If(nP <= 0, cChar, aAcento[nP])
	Next nA

Return ( cTexto )