#INCLUDE "XMATR906.CH"                           
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ MATR906  ³ Autor ³ Liber de Esteban      ³ Data ³ 15/07/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio PIS e COFINS                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
USER FUNCTION XMATR906()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                 ³
//³ mv_par01        // Pis/Cofins/Ambos ?                ³
//³ mv_par02        // Data Inicial                      ³
//³ mv_par03        // Data Final                        ³
//³ mv_par04        // Analitico/Sintetico               ³
//³ mv_par05        // Livro Selecionado                 ³
//³ mv_par06        // Processa filiais                  ³
//³ mv_par07        // Filial Inicial                    ³
//³ mv_par08        // Filial Final                      ³
//³ mv_par09		// Total por Dia                     ³
//³ mv_par10		// Resumo por CFOP                   ³
//³ mv_par11		// Resumo das Notas Fiscais          ³
//³ mv_par12 		// Imp. Cum/Não Cum? 		   		 ³
//³ mv_par13 		// Dif. Orgão Público? 			   	 ³
//³ mv_par14 		// Quebra Resumo     			   	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Local oReport

AjustaSX1()
If FindFunction("TRepInUse") .And. TRepInUse()
	oReport:=ReportDef()
	oReport:PrintDialog()
Else
	MATR906R3()
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ReportDef ³ Autor ³ Liber de Esteban      ³ Data ³ 15/07/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Definicao do componente                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()
Local oReport
Local oPISCOF1, oPISCOF2, oPISCOF3
Local oTotAliq, oContr, oComple, oResumo, oTotCFOP, oTotDTEMI
Local oResCFOP, oResAliq, oResMov
Local oBreakRFS

// " Produto          NCM         Valor Contabil            Zona Franca      Aliquota              Valor da Contribuicao                            Base da Contribuicao              Documento   Serie  Emissao                "
// "                                                          Desconto                             Debito                 Credito                  Debito                 Credito" 
// "XXXXXXXXXXXXXXX  XXXXXXXXXX  999,999,999,999.99   999,999,999,999.99    99.99    999,999,999,999.99      999,999,999,999.99      999,999,999,999.99      999,999,999,999.99
// 0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21        22
// 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//"Relatorio - (PIS/COFINS)"###"Este programa emite Relatorio das Contribuicoes ao PIS e COFINS"
oReport := TReport():New("MATR906",STR0115,"MTR906",{|oReport| ReportPrint(oReport)},STR0114) 

oReport:SetLandscape()

Pergunte("MTR906",.F.)

//Secao 1 - PIS/COFINS ordenada por CFOP                           
//New(obj,<titulo>,{<TAB>},{<Ordem Rel.>}
oPISCOF1 := TRSection():New(oReport,STR0135,{"TRB"},{STR0116,STR0060,STR0061})
TRCell():New(oPISCOF1,"TIPO"     ,"TRB",STR0141,/*Picture*/						  ,06					         ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPISCOF1,"ES"       ,"TRB",STR0140,/*Picture*/						  ,01				      	   ,/*lPixel*/,{|| TRB->ES })
TRCell():New(oPISCOF1,"CFOP"     ,"TRB",STR0116,/*Picture*/						  ,TamSx3("D2_CF")[1]	   ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPISCOF1,"PRODUTO"  ,"TRB",STR0062,/*Picture*/						  ,TamSx3("D2_COD")[1]+20		,/*lPixel*/,/*{|| code-block de impressao }*/) //"Produto"
TRCell():New(oPISCOF1,"NCM"      ,"TRB",STR0128,/*Picture*/			 			  ,TamSx3("B1_POSIPI")[1] ,/*lPixel*/,/*{|| code-block de impressao }*/) //"NCM"
TRCell():New(oPISCOF1,"VALORCONT","TRB",STR0063,PesqPict("SD2","D2_TOTAL")  ,TamSx3("D2_TOTAL")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor Contabil"
TRCell():New(oPISCOF1,"ZFRANCA"  ,"TRB",STR0064,PesqPict("SD2","D2_DESCZFR"),TamSx3("D2_DESCZFR")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Zona Franca"
TRCell():New(oPISCOF1,"ALIQ"     ,"TRB",STR0065,PesqPict("SB1","B1_VLR_COF"),TamSx3("B1_VLR_COF")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Aliquota"
TRCell():New(oPISCOF1,"VALDEBT"  ,     ,STR0066,PesqPict("SD2","D2_TOTAL")  ,TamSx3("D2_TOTAL")[1]	,/*lPixel*/,{|| IIF(TRB->TIPO == "PIS" , IIF(TRB->ES == "E" ,TRB->PISDENT,  TRB->PISDSAI)   , IIF(TRB->ES == "E" ,TRB->COFDENT  ,TRB->COFDSAI))   }) //"Val. Contr. Debito"
TRCell():New(oPISCOF1,"VALCRED"  ,     ,STR0067,PesqPict("SD2","D2_TOTAL")  ,TamSx3("D2_TOTAL")[1]	,/*lPixel*/,{|| IIF(TRB->TIPO == "PIS" , IIF(TRB->ES == "E" ,TRB->PISCENT,  TRB->PISCSAI)   , IIF(TRB->ES == "E" ,TRB->COFCENT  ,TRB->COFCSAI))   }) //"Val. Contr Credito"
TRCell():New(oPISCOF1,"BASEDEBT" ,     ,STR0068,PesqPict("SD2","D2_TOTAL")  ,TamSx3("D2_TOTAL")[1]	,/*lPixel*/,{|| IIF(TRB->TIPO == "PIS" , IIF(TRB->ES == "E" ,TRB->BASPIDENT,TRB->BASPIDSAI) , IIF(TRB->ES == "E" ,TRB->BASCODENT,TRB->BASCODSAI)) }) //"Base Contr. Debito"
TRCell():New(oPISCOF1,"BASECRED" ,     ,STR0069,PesqPict("SD2","D2_TOTAL")  ,TamSx3("D2_TOTAL")[1]	,/*lPixel*/,{|| IIF(TRB->TIPO == "PIS" , IIF(TRB->ES == "E" ,TRB->BASPICENT,TRB->BASPICSAI) , IIF(TRB->ES == "E" ,TRB->BASCOCENT,TRB->BASCOCSAI)) }) //"Base Contr Credito"
TRCell():New(oPISCOF1,"NUMNF"    ,"TRB",STR0070,/*Picture*/				        ,TamSx3("D2_DOC")[1]+1	   ,/*lPixel*/,/*{|| code-block de impressao }*/) //"Documento"
TRCell():New(oPISCOF1,"SERIE"    ,"TRB",STR0071,/*Picture*/				        ,TamSx3("D2_SERIE")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Serie"
TRCell():New(oPISCOF1,"EMISSAO"  ,"TRB",STR0072,PesqPict("SD2","D2_EMISSAO"),13                      ,/*lPixel*/,/*{|| code-block de impressao }*/) //"Emissao"
TRCell():New(oPISCOF1,"CLIFOR"   ,"TRB",STR0129,/*Picture*/		         	  ,40					         ,/*lPixel*/,/*{|| code-block de impressao }*/) //"Cliente/Fornecedor"
//Secao 2 - PIS/COFINS ordenada por NF                             
oPISCOF2 := TRSection():New(oReport,STR0136,{"TRB"},{"CFOP",STR0060,STR0061})
TRCell():New(oPISCOF2,"TIPO"     ,"TRB",STR0141,/*Picture*/							,06								,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPISCOF2,"ES"       ,"TRB",STR0140,/*Picture*/							,01								,/*lPixel*/,{|| TRB->ES })
TRCell():New(oPISCOF2,"NUMNF"    ,"TRB",STR0070,PesqPict("SD2","D2_DOC")			,TamSx3("D2_DOC")[1]			,/*lPixel*/,/*{|| code-block de impressao }*/) //"Documento"
TRCell():New(oPISCOF2,"SERIE"    ,"TRB",STR0071,/*Picture*/							,TamSx3("D2_SERIE")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/) //"Serie"
TRCell():New(oPISCOF2,"EMISSAO"  ,"TRB",STR0072,PesqPict("SD2","D2_EMISSAO")	,13	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Emissao"
TRCell():New(oPISCOF2,"CLIFOR"   ,"TRB",STR0129,/*Picture*/							,40								,/*lPixel*/,/*{|| code-block de impressao }*/) //"Cliente/Fornecedor"
TRCell():New(oPISCOF2,"PRODUTO"  ,"TRB",STR0062,/*Picture*/							,TamSx3("D2_COD")[1]			,/*lPixel*/,/*{|| code-block de impressao }*/) //"Produto"
TRCell():New(oPISCOF2,"NCM"      ,"TRB",STR0128,/*Picture*/							,TamSx3("B1_POSIPI")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/) //"NCM"
TRCell():New(oPISCOF2,"VALORCONT","TRB",STR0063,PesqPict("SD2","D2_TOTAL")	,TamSx3("D2_TOTAL")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor Contabil"
TRCell():New(oPISCOF2,"ZFRANCA"  ,"TRB",STR0064,PesqPict("SD2","D2_DESCZFR")	,TamSx3("D2_DESCZFR")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Zona Franca"
TRCell():New(oPISCOF2,"ALIQ"     ,"TRB",STR0065,PesqPict("SB1","B1_VLR_COF")	,TamSx3("B1_VLR_COF")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Aliquota"
TRCell():New(oPISCOF2,"VALDEBT"  ,     ,STR0066,PesqPict("SD2","D2_TOTAL")	,TamSx3("D2_TOTAL")[1]		,/*lPixel*/,{|| IIF(TRB->TIPO=="PIS",IIF(TRB->ES=="E",TRB->PISDENT,  TRB->PISDSAI)  ,IIF(TRB->ES=="E",TRB->COFDENT  ,TRB->COFDSAI))   }) //"Val. Contr. Debito"
TRCell():New(oPISCOF2,"VALCRED"  ,     ,STR0067,PesqPict("SD2","D2_TOTAL")	,TamSx3("D2_TOTAL")[1]		,/*lPixel*/,{|| IIF(TRB->TIPO=="PIS",IIF(TRB->ES=="E",TRB->PISCENT,  TRB->PISCSAI)  ,IIF(TRB->ES=="E",TRB->COFCENT  ,TRB->COFCSAI))   }) //"Val. Contr Credito"
TRCell():New(oPISCOF2,"BASEDEBT" ,     ,STR0068,PesqPict("SD2","D2_TOTAL")	,TamSx3("D2_TOTAL")[1]		,/*lPixel*/,{|| IIF(TRB->TIPO=="PIS",IIF(TRB->ES=="E",TRB->BASPIDENT,TRB->BASPIDSAI),IIF(TRB->ES=="E",TRB->BASCODENT,TRB->BASCODSAI)) }) //"Base Contr. Debito"
TRCell():New(oPISCOF2,"BASECRED" ,     ,STR0069,PesqPict("SD2","D2_TOTAL")	,TamSx3("D2_TOTAL")[1]		,/*lPixel*/,{|| IIF(TRB->TIPO=="PIS",IIF(TRB->ES=="E",TRB->BASPICENT,TRB->BASPICSAI),IIF(TRB->ES=="E",TRB->BASCOCENT,TRB->BASCOCSAI)) }) //"Base Contr Credito"
//Secao 3 - PIS/COFINS ordenada por Data da NF                     
oPISCOF3 := TRSection():New(oReport,STR0137,{"TRB"},{"CFOP",STR0060,STR0061})
TRCell():New(oPISCOF3,"TIPO"     ,"TRB",STR0141,/*Picture*/							,06								,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPISCOF3,"ES"       ,"TRB",STR0140,/*Picture*/							,01								,/*lPixel*/,{|| TRB->ES })
TRCell():New(oPISCOF3,"EMISSAO"  ,"TRB",STR0072,PesqPict("SD2","D2_EMISSAO")	,13	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Emissao"
TRCell():New(oPISCOF3,"CLIFOR"   ,"TRB",STR0129,/*Picture*/							,40								,/*lPixel*/,/*{|| code-block de impressao }*/) //"Cliente/Fornecedor"
TRCell():New(oPISCOF3,"NUMNF"    ,"TRB",STR0070,/*Picture*/							,TamSx3("D2_DOC")[1]			,/*lPixel*/,/*{|| code-block de impressao }*/) //"Documento"
TRCell():New(oPISCOF3,"SERIE"    ,"TRB",STR0071,/*Picture*/							,TamSx3("D2_SERIE")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/) //"Serie"
TRCell():New(oPISCOF3,"PRODUTO"  ,"TRB",STR0062,/*Picture*/							,TamSx3("D2_COD")[1]			,/*lPixel*/,/*{|| code-block de impressao }*/) //"Produto"
TRCell():New(oPISCOF3,"NCM"      ,"TRB",STR0128,/*Picture*/							,TamSx3("B1_POSIPI")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/) //"NCM"
TRCell():New(oPISCOF3,"VALORCONT","TRB",STR0063,PesqPict("SD2","D2_TOTAL")	,TamSx3("D2_TOTAL")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor Contabil"
TRCell():New(oPISCOF3,"ZFRANCA"  ,"TRB",STR0064,PesqPict("SD2","D2_DESCZFR")	,TamSx3("D2_DESCZFR")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Zona Franca"
TRCell():New(oPISCOF3,"ALIQ"     ,"TRB",STR0065,PesqPict("SB1","B1_VLR_COF") ,TamSx3("B1_VLR_COF")[1]  ,/*lPixel*/,/*{|| code-block de impressao }*/) //"Aliquota"
TRCell():New(oPISCOF3,"VALDEBT"  ,     ,STR0066,PesqPict("SD2","D2_TOTAL")	,TamSx3("D2_TOTAL")[1]		,/*lPixel*/,{|| IIF(TRB->TIPO=="PIS",IIF(TRB->ES=="E",TRB->PISDENT,  TRB->PISDSAI)  ,IIF(TRB->ES=="E",TRB->COFDENT  ,TRB->COFDSAI))   }) //"Val. Contr. Debito"
TRCell():New(oPISCOF3,"VALCRED"  ,     ,STR0067,PesqPict("SD2","D2_TOTAL")	,TamSx3("D2_TOTAL")[1]		,/*lPixel*/,{|| IIF(TRB->TIPO=="PIS",IIF(TRB->ES=="E",TRB->PISCENT,  TRB->PISCSAI)  ,IIF(TRB->ES=="E",TRB->COFCENT  ,TRB->COFCSAI))   }) //"Val. Contr Credito"
TRCell():New(oPISCOF3,"BASEDEBT" ,     ,STR0068,PesqPict("SD2","D2_TOTAL")	,TamSx3("D2_TOTAL")[1]		,/*lPixel*/,{|| IIF(TRB->TIPO=="PIS",IIF(TRB->ES=="E",TRB->BASPIDENT,TRB->BASPIDSAI),IIF(TRB->ES=="E",TRB->BASCODENT,TRB->BASCODSAI)) }) //"Base Contr. Debito"
TRCell():New(oPISCOF3,"BASECRED" ,     ,STR0069,PesqPict("SD2","D2_TOTAL")	,TamSx3("D2_TOTAL")[1]		,/*lPixel*/,{|| IIF(TRB->TIPO=="PIS",IIF(TRB->ES=="E",TRB->BASPICENT,TRB->BASPICSAI),IIF(TRB->ES=="E",TRB->BASCOCENT,TRB->BASCOCSAI)) }) //"Base Contr Credito"
//Secao 4 - Totalizacao das aliquotas na quebra de Entrada/Saida e PIS/COFINS 
oTotAliq := TRSection():New(oReport,Alltrim(STR0073),{},{})
TRCell():New(oTotAliq,"DESCRI"   ,,				,										,30							,/*lPixel*/,/*{|| code-block de impressao }*/) // "Descricao"
TRCell():New(oTotAliq,"VALORCONT",,STR0063	,PesqPict("SD2","D2_TOTAL")	,TamSx3("D2_TOTAL")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor Contabil"
TRCell():New(oTotAliq,"ZFRANCA"  ,,STR0064	,PesqPict("SD2","D2_DESCZFR")	,TamSx3("D2_DESCZFR")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Zona Franca"
TRCell():New(oTotAliq,"	ESPACA"   ,,STR0065	,                           	,TamSx3("B1_VLR_COF")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Zona Franca"
TRCell():New(oTotAliq,"VALDEBT"  ,,STR0066	,PesqPict("SD2","D2_TOTAL")	,TamSx3("D2_TOTAL")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Val. Contr. Debito"
TRCell():New(oTotAliq,"VALCRED"  ,,STR0067	,PesqPict("SD2","D2_TOTAL")	,TamSx3("D2_TOTAL")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Val. Contr Credito"
TRCell():New(oTotAliq,"BASEDEBT" ,,STR0068	,PesqPict("SD2","D2_TOTAL")	,TamSx3("D2_TOTAL")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Base Contr. Debito"
TRCell():New(oTotAliq,"BASECRED" ,,STR0069	,PesqPict("SD2","D2_TOTAL")	,TamSx3("D2_TOTAL")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Base Contr Credito"
oTotAliq:SetTotalInLine(.F.)         
//Totaliza Secao 4
TRFunction():New(oTotAliq:Cell("VALORCONT"),NIL,"SUM",,,/*cPicture*/,/*uFormula*/,.T.,.F.,.F.,,,,,,,,.T.)
TRFunction():New(oTotAliq:Cell("ZFRANCA"),	NIL,"SUM",,,/*cPicture*/,/*uFormula*/,.T.,.F.,.F.,,,,,,,,.T.)
TRFunction():New(oTotAliq:Cell("VALDEBT"),	NIL,"SUM",,,/*cPicture*/,/*uFormula*/,.T.,.F.,.F.,,,,,,,,.T.)
TRFunction():New(oTotAliq:Cell("VALCRED"),	NIL,"SUM",,,/*cPicture*/,/*uFormula*/,.T.,.F.,.F.,,,,,,,,.T.)
TRFunction():New(oTotAliq:Cell("BASEDEBT"),	NIL,"SUM",,,/*cPicture*/,/*uFormula*/,.T.,.F.,.F.,,,,,,,,.T.)
TRFunction():New(oTotAliq:Cell("BASECRED"),	NIL,"SUM",,,/*cPicture*/,/*uFormula*/,.T.,.F.,.F.,,,,,,,,.T.)
//Secao 5 - Valores de Contribuicao                            
oContr := TRSection():New(oReport,STR0074,{},{})
TRCell():New(oContr,"CFOP"     ,,STR0116,											,06						 		,/*lPixel*/,/*{|| code-block de impressao }*/) //"CFOP"
TRCell():New(oContr,"VALOR"    ,,STR0075,PesqPict("SD2","D2_TOTAL")		,TamSx3("D2_TOTAL")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor"
TRCell():New(oContr,"CD"       ,,STR0138,											,03								,/*lPixel*/,/*{|| code-block de impressao }*/) // "Credito/Debito"
TRCell():New(oContr,"VALORCONT",,STR0063,PesqPict("SD2","D2_TOTAL")		,TamSx3("D2_TOTAL")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oContr,"ZFRANCA"  ,,STR0064,PesqPict("SD2","D2_TOTAL")		,TamSx3("D2_TOTAL")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oContr,"ALIQ"     ,,STR0139,											,TamSx3("B1_VLR_COF")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/) // "Aliquota"
TRCell():New(oContr,"VALDEBT"  ,,STR0066,PesqPict("SD2","D2_TOTAL")		,TamSx3("D2_TOTAL")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oContr,"VALCRED"  ,,STR0067,PesqPict("SD2","D2_TOTAL")		,TamSx3("D2_TOTAL")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oContr,"BASEDEBT" ,,STR0068,PesqPict("SD2","D2_TOTAL")		,TamSx3("D2_TOTAL")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oContr,"BASECRED" ,,STR0069,PesqPict("SD2","D2_TOTAL")		,TamSx3("D2_TOTAL")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/)
//Secao 6 - Informacoes Complementares da Apuracao.             
oComple := TRSection():New(oReport,STR0076,{},{})
TRCell():New(oComple,"DESCR",,STR0077,										,70							,,/*{|| code-block de impressao }*/) //"Dsecrição"
TRCell():New(oComple,"VALOR",,STR0075,PesqPict("SD2","D2_TOTAL")	,TamSx3("D2_TOTAL")[1]	,,/*{|| code-block de impressao }*/)
//Secao 7 - Resumo de movimentacoes de cada filial                 
oResumo := TRSection():New(oReport,STR0117,{},{})
TRCell():New(oResumo,"DESCR" ,,STR0078,									,30							,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valores para Cálculo"
TRCell():New(oResumo,"TRIBUT",,STR0079,PesqPict("SD2","D2_TOTAL"),TamSx3("D2_TOTAL")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Tributado"
TRCell():New(oResumo,"OUTROS",,STR0080,PesqPict("SD2","D2_TOTAL"),TamSx3("D2_TOTAL")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Outros"
TRCell():New(oResumo,"TOTAL" ,,STR0088,PesqPict("SD2","D2_TOTAL"),TamSx3("D2_TOTAL")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)
//Secao 8 - Resumo por CFOP                                        
oResCFOP := TRSection():New(oReport,STR0081,{},{})
TRCell():New(oResCFOP,"CFOP"     ,     ,STR0116,									,04,							,/*{|| code-block de impressao }*/) //"CFOP"
TRCell():New(oResCFOP,"X5_DESCRI","SX5",STR0082,									,40,							,/*{|| code-block de impressao }*/) //"Descrição"
TRCell():New(oResCFOP,"FILIAL"   ,     ,STR0083,									,02,							,/*{|| code-block de impressao }*/) //"Filial"
TRCell():New(oResCFOP,"BASECNT"  ,     ,STR0084,PesqPict("SD2","D2_TOTAL"),TamSx3("D2_TOTAL")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Base da Contribuição"
TRCell():New(oResCFOP,"VALORCNT" ,     ,STR0085,PesqPict("SD2","D2_TOTAL"),TamSx3("D2_TOTAL")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor da Contribuição"
//Totaliza Secao 8 
oBreakRFS := TRBreak():New(oResCFOP,oResCFOP:Cell("CFOP"),STR0086,.F.) //"Total do CFOP"
TRFunction():New(oResCFOP:Cell("BASECNT"), NIL,"SUM",oBreakRFS,/*cTitle*/,/*cPicture*/,/*{|| code-block de impressao }*/,.F.,.F.,.F.)
TRFunction():New(oResCFOP:Cell("VALORCNT"),NIL,"SUM",oBreakRFS,/*cTitle*/,/*cPicture*/,/*{|| code-block de impressao }*/,.F.,.F.,.F.)
//Secao 9 - Resumo por Aliquota                                    
oResAliq := TRSection():New(oReport,STR0087,{},{})
TRCell():New(oResAliq,"FILIAL",,STR0083,										,08,								,/*{|| code-block de impressao }*/) //"Filial"
TRCell():New(oResAliq,"ALIQ"  ,,STR0065,PesqPict("SB1","B1_VLR_COF"),TamSx3("B1_VLR_COF")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Aliquota"
TRCell():New(oResAliq,"VALOR" ,,STR0075,PesqPict("SD2","D2_TOTAL")	,TamSx3("D2_TOTAL")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor"
//Totaliza Secao 9
oResAliq:SetTotalText(STR0088) //Total
oResAliq:SetTotalInLine(.F.)
TRFunction():New(oResAliq:Cell("VALOR"),NIL,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*{|| code-block de impressao }*/,.T.,.F.,.F.)
//Secao 10 - Resumo de movimentacoes de todas as filiais            
oResMov := TRSection():New(oReport,STR0118,{},{})
TRCell():New(oResMov,"DESCR" ,,STR0078,									,30,							,/*{|| code-block de impressao }*/) //"Valores para Cálculo"
TRCell():New(oResMov,"TRIBUT",,STR0079,PesqPict("SD2","D2_TOTAL"),TamSx3("D2_TOTAL")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Tributado"
TRCell():New(oResMov,"OUTROS",,STR0080,PesqPict("SD2","D2_TOTAL"),TamSx3("D2_TOTAL")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Outros"
TRCell():New(oResMov,"TOTAL" ,,STR0088,PesqPict("SD2","D2_TOTAL"),TamSx3("D2_TOTAL")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Total"
//Secao 11 - Totalizacao das aliquotas por CFOP
oTotCFOP := TRSection():New(oReport,Alltrim(STR0053),{},{})
TRCell():New(oTotCFOP,"DESCRI"   ,,				,										,30								,/*lPixel*/,/*{|| code-block de impressao }*/) // "Descricao"
TRCell():New(oTotCFOP,"VALORCONT",,STR0063	,PesqPict("SD2","D2_TOTAL")	,TamSx3("D2_TOTAL")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor Contabil"
TRCell():New(oTotCFOP,"ZFRANCA"  ,,STR0064	,PesqPict("SD2","D2_DESCZFR")	,TamSx3("D2_DESCZFR")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Zona Franca"
TRCell():New(oTotCFOP,"ESPACA"   ,,STR0065	,PesqPict("SB1","B1_VLR_COF")	,TamSx3("B1_VLR_COF")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Zona Franca"
TRCell():New(oTotCFOP,"VALDEBT"  ,,STR0066	,PesqPict("SD2","D2_TOTAL")	,TamSx3("D2_TOTAL")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/) //"Val. Contr. Debito"
TRCell():New(oTotCFOP,"VALCRED"  ,,STR0067	,PesqPict("SD2","D2_TOTAL")	,TamSx3("D2_TOTAL")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/) //"Val. Contr Credito"
TRCell():New(oTotCFOP,"BASEDEBT" ,,STR0068	,PesqPict("SD2","D2_TOTAL")	,TamSx3("D2_TOTAL")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/) //"Base Contr. Debito"
TRCell():New(oTotCFOP,"BASECRED" ,,STR0069	,PesqPict("SD2","D2_TOTAL")	,TamSx3("D2_TOTAL")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/) //"Base Contr Credito"
oTotCFOP:SetTotalInLine(.F.)         
//Secao 12 - Totalizacao por Data
oTotDTEMI := TRSection():New(oReport,Alltrim(STR0091),{},{})
TRCell():New(oTotDTEMI,"DESCRI"   ,,			,										,30								,/*lPixel*/,/*{|| code-block de impressao }*/) // "Descricao"
TRCell():New(oTotDTEMI,"VALORCONT",,STR0063	,PesqPict("SD2","D2_TOTAL")	,TamSx3("D2_TOTAL")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor Contabil"
TRCell():New(oTotDTEMI,"ZFRANCA"  ,,STR0064	,PesqPict("SD2","D2_DESCZFR")	,TamSx3("D2_DESCZFR")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Zona Franca"
TRCell():New(oTotDTEMI,"ESPACA"   ,,STR0065	,PesqPict("SB1","B1_VLR_COF")	,TamSx3("B1_VLR_COF")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Zona Franca"
TRCell():New(oTotDTEMI,"VALDEBT"  ,,STR0066	,PesqPict("SD2","D2_TOTAL")	,TamSx3("D2_TOTAL")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/) //"Val. Contr. Debito"
TRCell():New(oTotDTEMI,"VALCRED"  ,,STR0067	,PesqPict("SD2","D2_TOTAL")	,TamSx3("D2_TOTAL")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/) //"Val. Contr Credito"
TRCell():New(oTotDTEMI,"BASEDEBT" ,,STR0068	,PesqPict("SD2","D2_TOTAL")	,TamSx3("D2_TOTAL")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/) //"Base Contr. Debito"
TRCell():New(oTotDTEMI,"BASECRED" ,,STR0069	,PesqPict("SD2","D2_TOTAL")	,TamSx3("D2_TOTAL")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/) //"Base Contr Credito"
oTotDTEMI:SetTotalInLine(.F.)         
Return(oReport)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³Liber de Esteban       ³ Data ³18/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportPrint(oReport)

Local nOrdem 		:= oReport:Section(1):GetOrder()
Local oPISCOF		:= oReport:Section(nOrdem)
Local oContr 		:= oReport:Section(5)
Local oComple		:= oReport:Section(6)
Local oResumo		:= oReport:Section(7)
                 	
Local aAliqEs	  	:= {}
Local aAliqCFGer	:= {}
Local aCFOPCOFE  	:= {}
Local aCFOPCOFS  	:= {}
Local aTAlCOFE		:= {}
Local aTAlCOFS		:= {}
Local aCFOPPISE  	:= {}
Local aCFOPPISS		:= {}
Local aTAlPISE		:= {}
Local aTAlPISS		:= {}
Local aTotDoCFOP	:= {}
Local aTotPorCFOP	:= {}
Local aTotDtEmis    := {}
Local aTotResumo	:= CriaArrRes() //Cria array p/ total resumo
Local aAreaSM0   	:= SM0->(GetArea())

Local nContCp
Local nPosAliq		:= 0
Local nX			:= 0
Local nY			:= 0
Local nTeste		:= 0
Local nScanPis   	:= 0
Local nScanCof   	:= 0

Local cFilOri   	:= ""
Local cFilIni    	:= ""
Local cFilFin    	:= ""
Local cCfopAnt 		:= ""
Local cEsAnt		:= ""
Local cTipoAnt		:= ""
Local cCliFor		:= ""
Local cContArq
Local cArqCp
Local cLinArq
Local lFirstReg		:= .T.
Local lResumo		:= .F.
Local cEs			:= ""  
Local cCfop			:= ""  
Local nPag          := 0
Local cTipo			:= ""
Local dDtEmis		:= CToD("  /  /    ")
Local nTamDsc		:= 0
Local oFont01

Private lApurCof	:= .F.
Private lApurPis	:= .F.

Private aResumo		:= {}
Private aTApurPIS	:= {0,0,0,0,0,0,0}
Private aTApurCOF	:= {0,0,0,0,0,0,0}
Private aRelImp		:= MaFisRelImp("MT100",{ "SD1" })
Private aRelImp2	:= MaFisRelImp("MT100",{ "SD2" })

Private cCpVlPisEn 	:= ""
Private cCpBsPisEn 	:= ""
Private cCpVlPisSa 	:= ""
Private cCpBsPisSa 	:= ""
Private cCpAlPisSa 	:= ""
Private cCpAlPisEn 	:= ""
Private cCpVlCofEn 	:= ""
Private cCpBsCofEn 	:= ""
Private cCpVlCofSa 	:= ""
Private cCpBsCofSa 	:= ""
Private cCpAlCofEn 	:= ""
Private cCpAlCofSa 	:= ""

Private nPsVlPisEn 	:= 0
Private nPsBsPisEn 	:= 0
Private nPsVlPisSa 	:= 0
Private nPsBsPisSa 	:= 0
Private nPsAlPisEn 	:= 0
Private nPsAlPisSa 	:= 0
Private nPsVlCofEn 	:= 0
Private nPsBsCofEn 	:= 0
Private nPsVlCofSa 	:= 0
Private nPsBsCofSa 	:= 0
Private nPsAlCofEn 	:= 0
Private nPsAlCofSa 	:= 0
Private nTDedPIS	:= 0
Private nTDedCOF   	:= 0

Private cArqTemp	:= ""
Private aArqTemp	:= CriaArrTRB() //Array para montagem de tabela temporaria (TRB)          

TrataCpos() //Tratamento para os campos - PIS/COFINS

TRPosition():New(oPISCOF,"SX5",1,{|| xFilial("SX5")+"13"+TRB->CFOP })
                          
//oPISCOF:Cell("TIPO"):Disable()
//oPISCOF:Cell("ES"):Disable()

//Tamanho do campo DESCRI, depende da ordem do relatorio              
nTamDsc := TamSx3("D2_COD")[1] + 1
If nOrdem==2
	If oReport:GetOrientation() == 1 //Retrato: Estreita colunas
		nTamDsc := TamSx3("D2_DOC")[1] + TamSx3("D2_SERIE")[1] + TamSx3("D2_EMISSAO")[1] + 19 + TamSx3("D2_COD")[1] - 5 + TamSx3("B1_POSIPI")[1] + 7
    Else
		nTamDsc := TamSx3("D2_DOC")[1] + TamSx3("D2_SERIE")[1] + TamSx3("D2_EMISSAO")[1] + 40 + TamSx3("D2_COD")[1] + TamSx3("B1_POSIPI")[1] + 7
	EndIf	    
ElseIf nOrdem==3
	If oReport:GetOrientation() == 1//Retrato: Estreita colunas
		nTamDsc := TamSx3("D2_DOC")[1] + TamSx3("D2_SERIE")[1] + TamSx3("D2_EMISSAO")[1] + 19 + TamSx3("D2_COD")[1] - 5 + TamSx3("B1_POSIPI")[1] + 7
	Else
		nTamDsc := TamSx3("D2_DOC")[1] + TamSx3("D2_SERIE")[1] + TamSx3("D2_EMISSAO")[1] + 40 + TamSx3("D2_COD")[1] + TamSx3("B1_POSIPI")[1] + 7	
	EndIf
endif
//Titulo do relatorio
If mv_par12 == 3
	oReport:SetTitle(STR0093) 
ElseIf mv_par12 == 1 
	oReport:SetTitle(STR0145) 
Else
	oReport:SetTitle(STR0146) 
EndIf
//Verifica se ira processar mais de uma filial.                                        
//Se sim, ira emitir o relatorio separadamente, criando um resumo das filiais no final.
If mv_par06 == 1
	cFilIni := mv_par07
	cFilFin := mv_par08
Else
	cFilIni := cFilAnt
	cFilFin := cFilAnt
Endif
//Realizada varredura no SIGAMAT
cFilOri := cFilAnt
dbSelectArea("SM0")
SM0->(dbSeek(cEmpAnt+cFilIni,.T.))
While SM0->M0_CODIGO == cEmpAnt .And. SM0->M0_CODFIL <= cFilFin .And. !SM0->(Eof())
	cFilAnt := SM0->M0_CODFIL		
	//Monta Arquivo temporario 
	IF MontaTRB()	
		DbSelectArea("TRB")
		oReport:SetMeter(TRB->(LastRec()))
		DbGoTop()		
		//Imprime o cabecalho do relatorio
		oReport:PrintText(STR0121 + SM0->M0_NOMECOM,,10) 
		oReport:PrintText(STR0094 + Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),,10)
		oReport:PrintText(STR0122 + DTOC(mv_par02) + STR0095 + DTOC(mv_par03),,10) 
		oReport:SkipLine() //pula linha
		oReport:FatLine()  //Desenha uma linha com altura maior que a do metodo ThinLine						
		//Ordem por CFOP                           		
		If nOrdem == 1	  				
			If oReport:GetOrientation() == 1 
				oFont01:= TFont():New("Serif",,7,,.F.,,,,.T.,.F.) 
				oPISCOF:SetAutoSize()
				oPISCOF:SetLineBreak()
				oPISCOF:nColSpace := 0					
				oPISCOF:ACELL[4]:oFONTBODY := oFont01  
				oPISCOF:ACELL[5]:oFONTBODY := oFont01
				oPISCOF:ACELL[6]:oFONTBODY := oFont01     
				oPISCOF:ACELL[7]:oFONTBODY := oFont01  
				oPISCOF:ACELL[8]:oFONTBODY := oFont01
				oPISCOF:ACELL[8]:nSize     := 5
				oPISCOF:ACELL[9]:oFONTBODY := oFont01
				oPISCOF:ACELL[10]:oFONTBODY := oFont01
				oPISCOF:ACELL[11]:oFONTBODY := oFont01
				oPISCOF:ACELL[12]:oFONTBODY := oFont01
				oPISCOF:ACELL[13]:oFONTBODY := oFont01
				oPISCOF:ACELL[14]:oFONTBODY := oFont01
				oPISCOF:ACELL[15]:oFONTBODY := oFont01  															
				oPISCOF:ACELL[15]:nSize     := 10
				oPISCOF:ACELL[16]:oFONTBODY := oFont01  															
				oPISCOF:ACELL[16]:nSize     := 20
		    EndIf				   	   	    
   	  // 	    oPISCOF:Cell("CFOP"):Disable()		
 		    //Resume as NF
			If mv_par11 == 1
				oPISCOF:Cell("PRODUTO")	:Hide()
				oPISCOF:Cell("NCM")		:Hide()
			EndIf
	  		oPISCOF:Init()	  		
			//sintetico
			If mv_par04 == 2 
				oPISCOF:Cell("VALORCONT")	:Enable()
				oPISCOF:Cell("ZFRANCA")		:Enable()
				oPISCOF:Cell("VALDEBT")		:Enable()
				oPISCOF:Cell("VALCRED")		:Enable()
				oPISCOF:Cell("BASEDEBT")	:Enable()
				oPISCOF:Cell("BASECRED")	:Enable()
				
				oPISCOF:Cell("PRODUTO")		:SetTitle('')
				oPISCOF:Cell("NCM")			:SetTitle('')
				oPISCOF:Cell("ALIQ")		:SetTitle('')
				oPISCOF:Cell("NUMNF")		:SetTitle('')
				oPISCOF:Cell("SERIE")		:SetTitle('')
				oPISCOF:Cell("EMISSAO")		:SetTitle('')
				oPISCOF:Cell("CLIFOR")		:SetTitle('')
				
				oPISCOF:Cell("PRODUTO")		:Hide()
				oPISCOF:Cell("NCM")			:Hide()
				oPISCOF:Cell("ALIQ")		:Hide()
				oPISCOF:Cell("NUMNF")		:Hide()
				oPISCOF:Cell("SERIE")		:Hide()
				oPISCOF:Cell("EMISSAO")		:Hide()
				oPISCOF:Cell("CLIFOR")		:Hide()
			EndIf		   				
	  		
			While !TRB->(Eof())		                                                      
				cTipo	:= TRB->TIPO
				
				oPISCOF:SetHeaderSection(.T.)
				oPISCOF:PrintHeader()
				oPISCOF:SetHeaderSection(.F.)
				oReport:SkipLine()
				
				While !TRB->(Eof()) .and. TRB->TIPO == cTipo
				   if cES <> TRB->ES
						//PIS/COFINS - ENTRADAS/SAIDAS
						oReport:PrintText(IIF(TRB->TIPO == "PIS",STR0096,STR0097) + " - " + IIF(TRB->ES == "E",STR0119,STR0120),,1100) 
					endif	
					cES := TRB->ES
					While !TRB->(Eof()) .and. TRB->TIPO == cTipo .and. TRB->ES == cES
						cCFOP := TRB->CFOP
						//CFOP
						oReport:PrintText(TRB->CFOP+IIF(SX5->(MsSeek(xFilial("SX5")+"13"+TRB->CFOP))," - "+AllTrim(SX5->X5_DESCRI),""))
						//Produto
						While !TRB->(Eof()) .and. TRB->TIPO == cTipo .and. TRB->ES == cES .and. TRB->CFOP == cCFOP	
							dDtEmis := TRB->EMISSAO
							While !TRB->(Eof()) .and. TRB->TIPO == cTipo .and. TRB->ES == cES .and. TRB->CFOP == cCFOP	 .and. TRB->EMISSAO == dDtEmis
								//Monta os arrays para os totais
								M906TotRel(@aAliqCFGer,@aAliqEs,@aCFOPPISE,@aCFOPPISS,@aCFOPCOFE,@aCFOPCOFS,@aTAlPISE,@aTAlPISS,@aTAlCOFE,@aTAlCOFS,@aTotDoCFOP,@aTotDtEmis)	
								If mv_par04 == 1
									oPISCOF:Printline()												
									oReport:IncMeter() //Incr. a regua
								EndIf
								TRB->(dbSkip())											
							EndDo 
							If mv_par09 == 1 .and. (nOrdem >= 2 .or. (nOrdem == 1 .and. mv_par04 == 1))
								M906DTEMIS(oReport,aTotDtEmis,nTamDsc)
							Endif				
						EndDo 
		                If mv_par04 == 1
							M906CFOP(oReport,aTotDoCFOP,aTotPorCFOP,nTamDsc)
						Else
							AADD(aTotPorCFOP,aTotDoCFOP)
							aTotDoCFOP	:= {}
						Endif
					EndDo
					oReport:SkipLine()
					If mv_par10 == 1 
					   M906TCFOP(oReport,aTotPorCFOP,nTamDsc)
                    Endif 
					M906ENTSAI(oReport,aAliqEs,nTamDsc)
				EndDo 
				CONTRI906(oReport,aAliqCFGer,cTipo)
				cES := ""
			EndDo 
			oPISCOF:Finish()			
		Else		
			//Ordem por NF + SERIE + DT EMISSAO        
			If nOrdem == 2
				//Ajusta tamanho das celulas se for Portrait (retrato)
				If oReport:GetOrientation() == 1 
					oFont01:= TFont():New("Courier",,7,,.F.,,,,.T.,.F.) 
					oPISCOF:SetAutoSize()
					oPISCOF:SetLineBreak()
					oPISCOF:nColSpace := 0					
					oPISCOF:ACELL[3]:oFONTBODY  := oFont01
					oPISCOF:ACELL[4]:oFONTBODY  := oFont01
					oPISCOF:ACELL[5]:oFONTBODY  := oFont01
					oPISCOF:ACELL[6]:oFONTBODY  := oFont01     
					oPISCOF:ACELL[6]:nSize      := 22
					oPISCOF:ACELL[7]:oFONTBODY  := oFont01  
					oPISCOF:ACELL[7]:nSize      := oPISCOF:ACELL[7]:nSize 
					oPISCOF:ACELL[8]:oFONTBODY  := oFont01
					oPISCOF:ACELL[9]:oFONTBODY  := oFont01
					oPISCOF:ACELL[10]:oFONTBODY := oFont01
					oPISCOF:ACELL[11]:oFONTBODY := oFont01
					oPISCOF:ACELL[11]:nSize     := 5
					oPISCOF:ACELL[12]:oFONTBODY := oFont01
					oPISCOF:ACELL[13]:oFONTBODY := oFont01
					oPISCOF:ACELL[14]:oFONTBODY := oFont01
					oPISCOF:ACELL[15]:oFONTBODY := oFont01  															
			    EndIf				
				cCpoOrd := "TRB->NUMNF + TRB->SERIE"
				IndRegua ("TRB", cArqTemp, "TIPO+ES+NUMNF+SERIE+DToS(EMISSAO)")				
			//Ordem por DT EMISSAO + NF + SERIE        ³
			ElseIf nOrdem == 3
				//Ajusta tamanho das celulas se for Portrait (retrato)
				If oReport:GetOrientation() == 1
					oFont01:= TFont():New("Serif",,7,,.F.,,,,.T.,.F.) 
					oPISCOF:SetAutoSize()
					oPISCOF:SetLineBreak()
					oPISCOF:nColSpace := 0
					oPISCOF:ACELL[3]:oFONTBODY  := oFont01
					oPISCOF:ACELL[4]:oFONTBODY  := oFont01
					oPISCOF:ACELL[4]:nSize      := 22
					oPISCOF:ACELL[5]:oFONTBODY  := oFont01
					oPISCOF:ACELL[6]:oFONTBODY  := oFont01
					oPISCOF:ACELL[7]:oFONTBODY  := oFont01
					oPISCOF:ACELL[8]:oFONTBODY  := oFont01
					oPISCOF:ACELL[9]:oFONTBODY  := oFont01
					oPISCOF:ACELL[10]:oFONTBODY := oFont01
					oPISCOF:ACELL[11]:oFONTBODY := oFont01
					oPISCOF:ACELL[11]:nSize     := 5
					oPISCOF:ACELL[12]:oFONTBODY := oFont01
					oPISCOF:ACELL[13]:oFONTBODY := oFont01
					oPISCOF:ACELL[14]:oFONTBODY := oFont01
					oPISCOF:ACELL[15]:oFONTBODY := oFont01  															
			    EndIf				
				cCpoOrd := "DToS(TRB->EMISSAO)"
				IndRegua ("TRB", cArqTemp, "TIPO+ES+DToS(EMISSAO)+NUMNF+SERIE")					
			EndIf
	  		oPISCOF:Init()
			While !TRB->(Eof())		                                                      
				cTipo	:= TRB->TIPO
				While !TRB->(Eof()) .and. TRB->TIPO == cTipo
				   if cES <> TRB->ES
						//PIS/COFINS - ENTRADAS/SAIDAS
						oReport:PrintText(IIF(TRB->TIPO == "PIS",STR0096,STR0097) + " - " + IIF(TRB->ES == "E",STR0119,STR0120),,1100) 
					endif	
					oPISCOF:SetHeaderSection(.T.)
					oPISCOF:PrintHeader()
					oPISCOF:SetHeaderSection(.F.)
					cES := TRB->ES                 
					While !TRB->(Eof()) .and. TRB->TIPO == cTipo .and. TRB->ES == cES
						If nOrdem == 2
							cQuebra := TRB->NUMNF + TRB->SERIE
						Else	
							cQuebra := DToS(TRB->EMISSAO)
						Endif	
						While !TRB->(Eof()) .and. TRB->TIPO == cTipo .and. TRB->ES == cES .and. &cCpoOrd == cQuebra
							//Monta os arrays para os totais
							M906TotRel(@aAliqCFGer,@aAliqEs,@aCFOPPISE,@aCFOPPISS,@aCFOPCOFE,@aCFOPCOFS,@aTAlPISE,@aTAlPISS,@aTAlCOFE,@aTAlCOFS,@aTotDoCFOP,@aTotDtEmis)	
							If mv_par04 == 1
								oPISCOF:Printline()												
								oReport:IncMeter() //Incr. a regua
							EndIf
							TRB->(dbSkip())											
						EndDo 
						If mv_par09 == 1 .and. (nOrdem >= 2 .or. (nOrdem == 1 .and. mv_par04 == 1))
							M906DTEMIS(oReport,aTotDtEmis,nTamDsc)
						Endif				
					EndDo
					If mv_par04 == 1
						M906CFOP(oReport,aTotDoCFOP,aTotPorCFOP,nTamDsc)
					Else
						AADD(aTotPorCFOP,aTotDoCFOP)
						aTotDoCFOP	:= {}
					Endif 					
					oReport:SkipLine()
					If mv_par10 == 1 
					   M906TCFOP(oReport,aTotPorCFOP,nTamDsc)
                    Endif 
					M906ENTSAI(oReport,aAliqEs,nTamDsc)
				EndDo 
				CONTRI906(oReport,aAliqCFGer,cTipo)
				cES := ""
			EndDo 
			oPISCOF:Finish()	
		EndIf		
		//Informações Complementares da Apuração		
		//Cumulativo/NCumulativo
		If mv_par12 == 1
			cArqCp := AllTrim(strzero(month(mv_par02),2)+substr(strzero(year(mv_par02),4),3,2)+SM0->M0_CODIGO+SM0->M0_CODFIL)+".CNC"
		Else
			cArqCp := AllTrim(strzero(month(mv_par02),2)+substr(strzero(year(mv_par02),4),3,2)+SM0->M0_CODIGO+SM0->M0_CODFIL)+".CP"
		EndIf	
		If File(cArqCp)
			oReport:SetTitle(STR0076) 
						
			oComple:Cell("DESCR"):SetBlock( {|| Substr(cLinArq,01,70)      } )
			oComple:Cell("VALOR"):SetBlock( {|| Val(Substr(cLinArq,71,14)) } )	
			
			cContArq	:=	MemoRead(cArqCp)
			
			oComple:Init()
			For nContCp :=1 to MlCount(cContArq,100)
				cLinArq := MemoLine(cContArq,100,nContCp)
				oComple:PrintLine()
			Next
			oComple:Finish()
			oReport:EndPage()
			
			lResumo:= .T.
		Endif
		//Resumo
		If lResumo
			oResumo:Cell("DESCR"):SetBlock ( {|| aResumo[nX][1]} )
			oResumo:Cell("TRIBUT"):SetBlock( {|| aResumo[nX][2]} )
			oResumo:Cell("OUTROS"):SetBlock( {|| aResumo[nX][3]} )
			oResumo:Cell("TOTAL"):SetBlock ( {|| aResumo[nX][2] + aResumo[nX][3]} )
			oReport:SetTitle(STR0117) 
			oResumo:Init()			
			For nX := 1 To Len(aResumo)				
				oResumo:Printline()
				For nY := 2 To 3
					aTotResumo[nX][nY] += aResumo[nX][nY]
				Next				
			Next
			oResumo:Finish()
			oReport:EndPage()
		EndIf				
	EndIf	
	//Deleta o temporario a cada filial processada³
	TRB->(DbCloseArea())
	FErase(cArqTemp+GetDBExtension())
	#IFNDEF TOP
		FErase(cArqTemp+OrdBagExt())
	#ENDIF	
	SM0->(dbSkip())		
EndDo
DbSelectArea("SM0")                                                               						
SM0->(DbGoTop())
SM0->(dbSeek(cEmpAnt+cFilOri,.T.))
cFilAnt := cFilOri
//Imprime o total processado de todas as filiais 
If mv_par06 == 1	
	oResCFOP	:= oReport:Section(8)
	oResAliq	:= oReport:Section(9)
	oResMov 	:= oReport:Section(10)		  
    
   oReport:SetTitle(STR0102) //"Resumo Geral - Totalização das Filiais"
	
	If len(aCFOPCOFE) > 0 .or. len(aCFOPCOFS) > 0 .or. len(aTAlCOFE) > 0 .or. len(aTAlCOFS) > 0	                                                    
		cTipo := "COF"
		oReport:PrintText(STR0097,,1100) //"COFINS - Contribuição para o Financiamento da Seguridade Social"
		oReport:FatLine()		
		If nOrdem == 1			
			If len(aCFOPCOFE) > 0
				aCFOPCOFE := aSORT(aCFOPCOFE,,,{|X,Y|X[2]+X[1]<Y[2]+Y[1]})
				lEntrada  := .T.
				
				oReport:PrintText(STR0123,,10) //"Resumo por CFOP Processado - ENTRADAS"
				oReport:ThinLine()				

				oResCFOP:Cell("CFOP"):SetBlock( {|| aCFOPCOFE[nX][2]} )
				oResCFOP:Cell("FILIAL"):SetBlock( {|| aCFOPCOFE[nX][1]} )
				oResCFOP:Cell("BASECNT"):SetBlock( {|| Abs(aCFOPCOFE[nX][3])} )
				oResCFOP:Cell("VALORCNT"):SetBlock( {|| Abs(aCFOPCOFE[nX][4])} )			
				
				oResCFOP:Init()
				
				cCfopAnt := " "
				For nX := 1 To Len(aCFOPCOFE)			    	
			    	If cCfopAnt != aCFOPCOFE[nX][2]
			    		cCfopAnt :=aCFOPCOFE[nX][2]
						SX5->(MsSeek(xFilial("SX5")+"13"+cCfopAnt))
			    		oResCFOP:Cell("CFOP"):Show()
			    		oResCFOP:Cell("X5_DESCRI"):Show()
			    	Else
			    		oResCFOP:Cell("CFOP"):Hide()
			    		oResCFOP:Cell("X5_DESCRI"):Hide()
			    	EndIf
			    	oResCFOP:PrintLine()					
				Next
				
				oResCFOP:Finish()
				oReport:SkipLine()
				oReport:ThinLine()				
			EndIf
			
			If len(aCFOPCOFS) > 0
				aCFOPCOFS := aSORT(aCFOPCOFS,,,{|X,Y|X[2]+X[1]<Y[2]+Y[1]})
				lEntrada  := .F. 
				
				oReport:PrintText(STR0124,,10) //"Resumo por CFOP Processado - SAIDAS"
				oReport:ThinLine()
				
				oResCFOP:Cell("CFOP"):SetBlock( {|| aCFOPCOFS[nX][2]} )
				oResCFOP:Cell("FILIAL"):SetBlock( {|| aCFOPCOFS[nX][1]} )
				oResCFOP:Cell("BASECNT"):SetBlock( {|| Abs(aCFOPCOFS[nX][3])} )
				oResCFOP:Cell("VALORCNT"):SetBlock( {|| Abs(aCFOPCOFS[nX][4])} )
				
				oResCFOP:Init()
				
				cCfopAnt := " "
				For nX := 1 To Len(aCFOPCOFS)			    	
			    	If cCfopAnt != aCFOPCOFS[nX][2]
			    		cCfopAnt := aCFOPCOFS[nX][2]
						SX5->(MsSeek(xFilial("SX5")+"13"+cCfopAnt))
			    		oResCFOP:Cell("CFOP"):Show()
			    		oResCFOP:Cell("X5_DESCRI"):Show()
			    	Else
			    		oResCFOP:Cell("CFOP"):Hide()
			    		oResCFOP:Cell("X5_DESCRI"):Hide()
			    	EndIf
			    	oResCFOP:PrintLine()
					
				Next
				
				oResCFOP:Finish()
				oReport:SkipLine()
				oReport:ThinLine()				
			EndIf			
		EndIf
		
		If len(aTAlCOFE) > 0
			oReport:PrintText(STR0103,,10) //"Resumo por Aliquotas Processadas - ENTRADAS"
			oReport:ThinLine()
			
			oResAliq:Cell("FILIAL"):SetBlock( {|| aTAlCOFE[nX][1]} )
			oResAliq:Cell("ALIQ"):SetBlock( {|| aTAlCOFE[nX][2]} )
			oResAliq:Cell("VALOR"):SetBlock( {|| Abs(aTAlCOFE[nX][3])} )
			
			oResAliq:Init()
			
			For nX := 1 To Len(aTAlCOFE)		    	
		    	oResAliq:PrintLine()				
			Next
			
			oResAliq:Finish()
			oReport:SkipLine()
			oReport:ThinLine()			
		EndIf
		
		If len(aTAlCOFS) > 0
			oReport:PrintText(STR0104,,10) //"Resumo por Aliquotas Processadas - SAIDAS"
			oReport:ThinLine()
			
			oResAliq:Cell("FILIAL"):SetBlock( {|| aTAlCOFS[nX][1]} )
			oResAliq:Cell("ALIQ"):SetBlock( {|| aTAlCOFS[nX][2]} )
			oResAliq:Cell("VALOR"):SetBlock( {|| Abs(aTAlCOFS[nX][3])} )
			
			oResAliq:Init()
			
			For nX := 1 To Len(aTAlCOFS)		    	
		    	oResAliq:PrintLine()				
			Next
			
			oResAliq:Finish()
			oReport:SkipLine()
			oReport:ThinLine()			
		EndIf		
	EndIf
	
	If lApurCof 
		oReport:PrintText(STR0126,,10) //"Resumo Apurado"
		oReport:ThinLine()
		oReport:PrintText(STR0105,,10) //"Total Apurado...........:"
		
		nLin := oReport:Row()
		oReport:PrintText(Transform(ABS(aTApurCOF[1]),PesqPict("SD2","D2_TOTAL"))	,nLin,oContr:Cell("VALOR"):ColPos())
		oReport:PrintText(IIf(aTApurCOF[1] < 0,"(C)","(D)")							  	,nLin,oContr:Cell("CD"):ColPos())
		oReport:PrintText(Transform(Abs(aTApurCOF[2]),PesqPict("SD2","D2_TOTAL"))	,nLin,oContr:Cell("VALORCONT"):ColPos())
		oReport:PrintText(Transform(aTApurCOF[3],PesqPict("SD2","D2_TOTAL"))		,nLin,oContr:Cell("ZFRANCA"):ColPos())
		oReport:PrintText(Transform(aTApurCOF[4],PesqPict("SD2","D2_TOTAL"))		,nLin,oContr:Cell("VALDEBT"):ColPos())
		oReport:PrintText(Transform(aTApurCOF[5],PesqPict("SD2","D2_TOTAL"))		,nLin,oContr:Cell("VALCRED"):ColPos())
		oReport:PrintText(Transform(aTApurCOF[6],PesqPict("SD2","D2_TOTAL"))		,nLin,oContr:Cell("BASEDEBT"):ColPos())
		oReport:PrintText(Transform(aTApurCOF[7],PesqPict("SD2","D2_TOTAL"))		,nLin,oContr:Cell("BASECRED"):ColPos())

		oReport:SkipLine(2)
		oReport:PrintText(STR0106,,10) //"Total de Retenção.......:"
		oReport:PrintText(Transform(nTDedCOF,PesqPict("SD2","D2_TOTAL")),,oContr:Cell("VALOR"):ColPos())
		
		oReport:SkipLine()
		oReport:PrintText(STR0107,,10) //"Total da Contribuição...:"
		nLin := oReport:Row()
		oReport:PrintText(Transform(ABS(aTApurCOF[1] - nTDedCOF),PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("VALOR"):ColPos())
		oReport:PrintText(IIf(aTApurCOF[1] < 0,"(C)","(D)"),nLin,oContr:Cell("CD"):ColPos())
		oReport:PrintText(Transform(Abs(aTApurCOF[2]),PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("VALORCONT"):ColPos())
		oReport:PrintText(Transform(aTApurCOF[3],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("ZFRANCA"):ColPos())
		oReport:PrintText(Transform(aTApurCOF[4],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("VALDEBT"):ColPos())
		oReport:PrintText(Transform(aTApurCOF[5],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("VALCRED"):ColPos())
		oReport:PrintText(Transform(aTApurCOF[6],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("BASEDEBT"):ColPos())
		oReport:PrintText(Transform(aTApurCOF[7],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("BASECRED"):ColPos())	
		oReport:SkipLine(2)
		oReport:FatLine()
	EndIf
	
	If len(aCFOPPISE) > 0 .or. len(aCFOPPISS) > 0 .or. len(aTAlPISE) > 0 .or. len(aTAlPISS) > 0	
		cTipo := "PIS"
		oReport:PrintText(STR0096,,1200) //"PIS - Programa de Integração Social"
		oReport:FatLine()
		
		If nOrdem == 1		
			If len(aCFOPPISE) > 0
				aCFOPPISE := aSORT(aCFOPPISE,,,{|X,Y|X[2]+X[1]<Y[2]+Y[1]})
				lEntrada  := .T. 
				
				oReport:PrintText(STR0123,,10) //"Resumo por CFOP Processado - ENTRADAS"
				oReport:ThinLine()
				
				oResCFOP:Cell("CFOP"):SetBlock( {|| aCFOPPISE[nX][2]} )
				oResCFOP:Cell("FILIAL"):SetBlock( {|| aCFOPPISE[nX][1]} )
				oResCFOP:Cell("BASECNT"):SetBlock( {|| Abs(aCFOPPISE[nX][3])} )
				oResCFOP:Cell("VALORCNT"):SetBlock( {|| Abs(aCFOPPISE[nX][4])} )
				
				oResCFOP:Init()
				
				cCfopAnt := " "
				For nX := 1 To Len(aCFOPPISE)			    	
			    	If cCfopAnt != aCFOPPISE[nX][2]
			    		cCfopAnt := aCFOPPISE[nX][2]
						SX5->(MsSeek(xFilial("SX5")+"13"+cCfopAnt))
			    		oResCFOP:Cell("CFOP"):Show()
			    		oResCFOP:Cell("X5_DESCRI"):Show()
			    	Else
			    		oResCFOP:Cell("CFOP"):Hide()
			    		oResCFOP:Cell("X5_DESCRI"):Hide()
			    	EndIf
			    	oResCFOP:PrintLine()					
				Next
				
				oResCFOP:Finish()
				oReport:SkipLine()
				oReport:ThinLine()				
			EndIf
			
			If len(aCFOPPISS) > 0
				aCFOPPISS := aSORT(aCFOPPISS,,,{|X,Y|X[2]+X[1]<Y[2]+Y[1]})
				lEntrada  := .F.
				oReport:PrintText(STR0124,,10) //"Resumo por CFOP Processado - SAIDAS"
				oReport:ThinLine()
				
				oResCFOP:Cell("CFOP"):SetBlock( {|| aCFOPPISS[nX][2]} )
				oResCFOP:Cell("FILIAL"):SetBlock( {|| aCFOPPISS[nX][1]} )
				oResCFOP:Cell("BASECNT"):SetBlock( {|| Abs(aCFOPPISS[nX][3])} )
				oResCFOP:Cell("VALORCNT"):SetBlock( {|| Abs(aCFOPPISS[nX][4])} )
				
				oResCFOP:Init()
				
				cCfopAnt := " "
				For nX := 1 To Len(aCFOPPISS)			    	
			    	If cCfopAnt != aCFOPPISS[nX][2]
			    		cCfopAnt :=aCFOPPISS[nX][2]
						SX5->(MsSeek(xFilial("SX5")+"13"+cCfopAnt))			    		
			    		oResCFOP:Cell("CFOP"):Show()
			    		oResCFOP:Cell("X5_DESCRI"):Show()
			    	Else
			    		oResCFOP:Cell("CFOP"):Hide()
			    		oResCFOP:Cell("X5_DESCRI"):Hide()
			    	EndIf
			    	oResCFOP:PrintLine()					
				Next
				
				oResCFOP:Finish()
				oReport:SkipLine()
				oReport:ThinLine()				
			EndIf			
		EndIf
		
		If len(aTAlPISE) > 0
			oReport:PrintText(STR0103,,10) //"Resumo por Aliquotas Processadas - ENTRADAS"
			oReport:ThinLine()
			
			oResAliq:Cell("FILIAL"):SetBlock( {|| aTAlPISE[nX][1]} )
			oResAliq:Cell("ALIQ"):SetBlock( {|| aTAlPISE[nX][2]} )
			oResAliq:Cell("VALOR"):SetBlock( {|| Abs(aTAlPISE[nX][3])} )
			
			oResAliq:Init()
			
			For nX := 1 To Len(aTAlPISE)		    	
		    	oResAliq:PrintLine()				
			Next
			
			oResAliq:Finish()
			oReport:SkipLine()
			oReport:ThinLine()			
		EndIf
		
		If len(aTAlPISS) > 0
			oReport:PrintText(STR0104,,10) //"Resumo por Aliquotas Processadas - SAIDAS"
			oReport:ThinLine()
			
			oResAliq:Cell("FILIAL"):SetBlock( {|| aTAlPISS[nX][1]} )
			oResAliq:Cell("ALIQ"):SetBlock( {|| aTAlPISS[nX][2]} )
			oResAliq:Cell("VALOR"):SetBlock( {|| Abs(aTAlPISS[nX][3])} )
			
			oResAliq:Init()
			
			For nX := 1 To Len(aTAlPISS)		    	
		    	oResAliq:PrintLine()				
			Next
			
			oResAliq:Finish()
			oReport:SkipLine()
			oReport:ThinLine()			
		EndIf		
	EndIf
	
	If lApurPis 
		oReport:PrintText(STR0126,,10) //"Resumo Apurado"
		oReport:ThinLine()
		oReport:PrintText(STR0105,,10) //"Total Apurado...........:"
		
		nLin := oReport:Row()
		oReport:PrintText(Transform(ABS(aTApurPIS[1]),PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("VALOR"):ColPos())
		oReport:PrintText(IIf(aTApurPIS[1] < 0,"(C)","(D)"),nLin,oContr:Cell("CD"):ColPos())
		oReport:PrintText(Transform(Abs(aTApurPIS[2]),PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("VALORCONT"):ColPos())
		oReport:PrintText(Transform(aTApurPIS[3],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("ZFRANCA"):ColPos())
		oReport:PrintText(Transform(aTApurPIS[4],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("VALDEBT"):ColPos())
		oReport:PrintText(Transform(aTApurPIS[5],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("VALCRED"):ColPos())
		oReport:PrintText(Transform(aTApurPIS[6],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("BASEDEBT"):ColPos())
		oReport:PrintText(Transform(aTApurPIS[7],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("BASECRED"):ColPos())
		
		oReport:SkipLine(2)
		oReport:PrintText(STR0106,,10) //"Total de Retenção.......:"
		oReport:PrintText(Transform(nTDedPIS,PesqPict("SD2","D2_TOTAL")),,oContr:Cell("VALOR"):ColPos())
		
		oReport:SkipLine()
		oReport:PrintText(STR0107,,10) //"Total da Contribuição...:"
		nLin := oReport:Row()
		oReport:PrintText(Transform(ABS(aTApurPIS[1] - nTDedPIS),PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("VALOR"):ColPos())
		oReport:PrintText(IIf(aTApurPIS[1] < 0,"(C)","(D)"),nLin,oContr:Cell("CD"):ColPos())
		oReport:PrintText(Transform(Abs(aTApurPIS[2]),PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("VALORCONT"):ColPos())
		oReport:PrintText(Transform(aTApurPIS[3],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("ZFRANCA"):ColPos())
		oReport:PrintText(Transform(aTApurPIS[4],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("VALDEBT"):ColPos())
		oReport:PrintText(Transform(aTApurPIS[5],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("VALCRED"):ColPos())
		oReport:PrintText(Transform(aTApurPIS[6],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("BASEDEBT"):ColPos())
		oReport:PrintText(Transform(aTApurPIS[7],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("BASECRED"):ColPos())	
		oReport:SkipLine(2)
		oReport:FatLine()
	EndIf
	
	If lResumo	
		oReport:PrintText(STR0118,,1300) //"Resumo por Movimento Processado"
		oReport:FatLine()
		
		oResMov:Cell("DESCR"):SetBlock( {|| aTotResumo[nX][1]} )
		oResMov:Cell("TRIBUT"):SetBlock( {|| aTotResumo[nX][2]} )
		oResMov:Cell("OUTROS"):SetBlock( {|| aTotResumo[nX][3]} )
		oResMov:Cell("TOTAL"):SetBlock( {|| aTotResumo[nX][2] + aTotResumo[nX][3]} )
		
		oResMov:Init()
		
		For nX := 1 To Len(aTotResumo)	    	
	    	oResMov:PrintLine()			
		Next
		
		oResMov:Finish()		
	EndIf
EndIf
//Reposiciona na filial corrente              
RestArea(aAreaSM0)
cFilAnt := SM0->M0_CODFIL
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M906ENTSAI³ Autor ³ Liber De Esteban      ³ Data ³ 22/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime Resumo de Contribuicoes de PIS e COFINS            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±³          ³ExpO2: Array contendo valores para totalizacao              ³±±
±±³          ³ExpO3: Tipo do regustro (PIS/COFINS)                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M906ENTSAI(oReport,aAliqes,nTamDsc)

Local nX
Local nOrdem 	:= oReport:Section(1):GetOrder()
Local oTotAliq	:= oReport:Section(4)   

oTotAliq:SetTotalText(Iif(TRB->ES=="S",STR0101,STR0100))
oTotAliq:SetHeaderSection(.F.)
oTotAliq:Cell("DESCRI")   :SetSize(nTamDsc+5,.f.)
oTotAliq:Cell("DESCRI")   :SetBlock( {|| STR0127 + Transform(aAliqEs[nX][1],"@E 99.99%")} ) //"Total da Aliquota "
oTotAliq:Cell("VALORCONT"):SetBlock( {|| aAliqEs[nX][2]} )
oTotAliq:Cell("ZFRANCA")  :SetBlock( {|| aAliqEs[nX][3]} )
oTotAliq:Cell("VALDEBT")  :SetBlock( {|| aAliqEs[nX][4]} )
oTotAliq:Cell("VALCRED")  :SetBlock( {|| aAliqEs[nX][5]} )
oTotAliq:Cell("BASEDEBT") :SetBlock( {|| aAliqEs[nX][6]} )
oTotAliq:Cell("BASECRED") :SetBlock( {|| aAliqEs[nX][7]} )

oTotAliq:Init()
For nX := 1 to len(aAliqes)
	oTotAliq:PrintLine()
Next
oTotAliq:Finish()
aAliqes := {}

oReport:SkipLine()
oReport:SkipLine()

Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M906CFOP  ³ Autor ³ Mauro A. Goncalves    ³ Data ³ 22/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime Total do CFOP de Contribuicoes de PIS e COFINS     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±³          ³ExpO2: Array contendo valores para totalizacao              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M906CFOP(oReport,aTotDoCFOP,aTotPorCFOP,nTamDsc)

Local nX
Local nOrdem 	:= oReport:Section(1):GetOrder()
Local oTotCFOP	:= oReport:Section(11)

oTotCFOP:SetHeaderSection(.F.)
oTotCFOP:Cell("DESCRI")   :SetSize(nTamDsc+5,.f.)
oTotCFOP:Cell("DESCRI")   :SetBlock( {|| STR0086 + " - " + aTotDoCFOP[nX][1]} ) //Total do CFOP
oTotCFOP:Cell("VALORCONT"):SetBlock( {|| aTotDoCFOP[nX][2]} )
oTotCFOP:Cell("ZFRANCA")  :SetBlock( {|| aTotDoCFOP[nX][3]} )
oTotCFOP:Cell("VALDEBT")  :SetBlock( {|| aTotDoCFOP[nX][4]} )
oTotCFOP:Cell("VALCRED")  :SetBlock( {|| aTotDoCFOP[nX][5]} )
oTotCFOP:Cell("BASEDEBT") :SetBlock( {|| aTotDoCFOP[nX][6]} )
oTotCFOP:Cell("BASECRED") :SetBlock( {|| aTotDoCFOP[nX][7]} )

oTotCFOP:Init()
For nX := 1 to len(aTotDoCFOP)
	oTotCFOP:PrintLine()
Next
oTotCFOP:Finish()    

AADD(aTotPorCFOP,aTotDoCFOP)
aTotDoCFOP	:= {}

oReport:SkipLine()
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M906TCFOP ³ Autor ³ Mauro A. Goncalves    ³ Data ³ 22/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime Total por CFOP de Contribuicoes de PIS e COFINS    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±³          ³ExpO2: Array contendo valores para totalizacao              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M906TCFOP(oReport,aTotPorCFOP,nTamDsc)

Local nX
Local nOrdem	:= oReport:Section(1):GetOrder()
Local oTotCFOP	:= oReport:Section(11)   
  
oTotCFOP:SetHeaderSection(.F.)
oTotCFOP:Cell("DESCRI")   :SetSize(nTamDsc+5,.f.)
oTotCFOP:Cell("DESCRI")   :SetBlock( {|| iif(nX==1,STR0053,space(len(STR0053))) + " " + aTotPorCFOP[nX][1][1]} ) //Total por CFOP
oTotCFOP:Cell("VALORCONT"):SetBlock( {|| aTotPorCFOP[nX][1][2]} )
oTotCFOP:Cell("ZFRANCA")  :SetBlock( {|| aTotPorCFOP[nX][1][3]} )
oTotCFOP:Cell("VALDEBT")  :SetBlock( {|| aTotPorCFOP[nX][1][4]} )
oTotCFOP:Cell("VALCRED")  :SetBlock( {|| aTotPorCFOP[nX][1][5]} )
oTotCFOP:Cell("BASEDEBT") :SetBlock( {|| aTotPorCFOP[nX][1][6]} )
oTotCFOP:Cell("BASECRED") :SetBlock( {|| aTotPorCFOP[nX][1][7]} )

oTotCFOP:Init()
For nX := 1 to len(aTotPorCFOP)
	oTotCFOP:PrintLine()
Next
oTotCFOP:Finish()    

aTotPorCFOP	:= {}

Return                                 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M906DTEMIS³ Autor ³ Mauro A. Goncalves    ³ Data ³ 22/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime Total por Data de Contribuicoes de PIS e COFINS    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±³          ³ExpO2: Array contendo valores para totalizacao              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M906DTEMIS(oReport,aTotDtEmis,nTamDsc)

Local nX
Local nOrdem		:= oReport:Section(1):GetOrder()
Local oTotDTEMI	:= oReport:Section(12)   
  
oTotDTEMI:SetHeaderSection(.F.)
oTotDTEMI:Cell("DESCRI")   :SetSize(nTamDsc+5,.f.)
oTotDTEMI:Cell("DESCRI")   :SetBlock( {|| STR0091 + " " + DtoC(aTotDtEmis[nX][1])} ) //Total por Data
oTotDTEMI:Cell("VALORCONT"):SetBlock( {|| aTotDtEmis[nX][2]} )
oTotDTEMI:Cell("ZFRANCA")  :SetBlock( {|| aTotDtEmis[nX][3]} )
oTotDTEMI:Cell("VALDEBT")  :SetBlock( {|| aTotDtEmis[nX][4]} )
oTotDTEMI:Cell("VALCRED")  :SetBlock( {|| aTotDtEmis[nX][5]} )
oTotDTEMI:Cell("BASEDEBT") :SetBlock( {|| aTotDtEmis[nX][6]} )
oTotDTEMI:Cell("BASECRED") :SetBlock( {|| aTotDtEmis[nX][7]} )

oTotDTEMI:Init()
For nX := 1 to len(aTotDtEmis)                                            	
	oTotDTEMI:PrintLine()
Next
oTotDTEMI:Finish()    

aTotDtEmis := {}

oReport:SkipLine()
Return                      

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CONTRI906 ³ Autor ³ Liber De Esteban      ³ Data ³ 22/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime Resumo de Contribuicoes de PIS e COFINS            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±³          ³ExpO2: Array contendo valores para totalizacao              ³±±
±±³          ³ExpO3: Tipo do regustro (PIS/COFINS)                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CONTRI906(oReport,aAliqCFGer,cTipo)

Local oContr 		:= oReport:Section(5)
Local nOrdem 		:= oReport:Section(1):GetOrder()
Local oPISCOF		:= oReport:Section(nOrdem)
Local nAliq 		:= 0
Local nX			:= 0
Local nY			:= 0
Local aValContri	:= {0,0,0,0,0,0,0}
Local aContAliq 	:= {0,0,0,0,0,0,0}
Local aRet			:= {0,0}
Local lOrgPub		:= IIF(mv_par13 == 1,.T.,.F.)
Local aDedRet		:= FsCalRt2(mv_par02,mv_par03,,,2,,@aRet,,.T.,cFilAnt,,lOrgPub)
Local nDedRet		:= IIF(cTipo=="PIS",aDedRet[1],aDedRet[2])
Local nRetencao	:= IIF(cTipo=="PIS",aRet[1],aRet[2]) // Tratamento para as empresas que nao sao Orgaos Publicos
Local lFirst 		:= .T.

nTDedPIS	+= IIF(cTipo=="PIS",nDedRet,0)
nTDedCOF	+= IIF(cTipo=="PIS",0,nDedRet)
//Ordena o array por aliquota + CFOP 
Asort(aAliqCFGer,,,{|x,y|Str(x[1])+x[2] < Str(y[1])+y[2]})

If nOrdem >= 2
	oContr:Cell("CD"):SetSize(31,.F./*lPixel*/)
EndIf

oContr:Cell("CFOP"):SetBlock( {|| aAliqCFGer[nX][2]} )
oContr:Cell("VALOR"):SetBlock( {|| abs(aAliqCFGer[nX][3])} )
oContr:Cell("CD"):SetBlock( {|| IIf(aAliqCFGer[nX][3] < 0,"(C)","(D)")} )
oContr:Cell("VALORCONT"):SetBlock( {|| abs(aAliqCFGer[nX][4])} )
oContr:Cell("ZFRANCA"):SetBlock( {|| aAliqCFGer[nX][5]} )
oContr:Cell("ALIQ"):SetValue( Space(TamSx3("B1_VLR_COF")[1]) )
oContr:Cell("VALDEBT"):SetBlock( {|| aAliqCFGer[nX][6]} )
oContr:Cell("VALCRED"):SetBlock( {|| aAliqCFGer[nX][7]} )
oContr:Cell("BASEDEBT"):SetBlock( {|| aAliqCFGer[nX][8]} )
oContr:Cell("BASECRED"):SetBlock( {|| aAliqCFGer[nX][9]} )

oReport:SkipLine(2)
oReport:FatLine()
oReport:PrintText(STR0108,,10) //"Contribuição: "

nAliq		:= 0
lFirst	:= .T.

oContr:Init()
For nX := 1 To Len(aAliqCFGer)	
   //Detalha CFOP
	If mv_par10 == 2
		oContr:Hide()
	EndIf	
	If nAliq <> aAliqCFGer[nX][1]
		If !lFirst
			oContr:Finish()
			oReport:SkipLine()
			oReport:PrintText(STR0088,,10) //"Total"
			oReport:ThinLine()
			nLin := oReport:Row()
			oReport:PrintText(Transform(ABS(aContAliq[1]),PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("VALOR"):ColPos())
			oReport:PrintText(IIf(aContAliq[1] < 0,"(C)","(D)"),nLin,oContr:Cell("CD"):ColPos())
			oReport:PrintText(Transform(Abs(aContAliq[2]),PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("VALORCONT"):ColPos())
			oReport:PrintText(Transform(aContAliq[3],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("ZFRANCA"):ColPos())
			oReport:PrintText(Transform(aContAliq[4],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("VALDEBT"):ColPos()+28)
			oReport:PrintText(Transform(aContAliq[5],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("VALCRED"):ColPos()+26)
			oReport:PrintText(Transform(aContAliq[6],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("BASEDEBT"):ColPos()+22)
			oReport:PrintText(Transform(aContAliq[7],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("BASECRED"):ColPos()+20)
			oContr:Init()
		EndIf
		aContAliq := {0,0,0,0,0,0,0}
		nAliq     := aAliqCFGer[nX][1]
		oReport:SkipLine(2)
		oReport:PrintText(STR0109 + Transform(nAliq,Iif(nAliq<>0,PesqPict("SB1","B1_VLR_COF",TamSx3("B1_VLR_COF")[1]),PesqPict("SB1","B1_VLR_COF",TamSx3("B1_VLR_COF")[1]))),,10) //"Aliquota: "
		lFirst    := .F.
	Endif
   //Detalha CFOP
	If mv_par10 == 2
		oContr:Hide()
	EndIf
	
	For nY := 1 to 7
		aContAliq[nY]  += aAliqCFGer[nX][nY+2]
		aValContri[nY] += aAliqCFGer[nX][nY+2]
		If cTipo == "PIS"
			aTApurPIS[nY] += aAliqCFGer[nX][nY+2]
			lApurPis := .T.
		Else
			aTApurCOF[nY] += aAliqCFGer[nX][nY+2]
			lApurCof := .T.
		EndIf
	Next
		
	oContr:Printline()	
Next
oContr:Finish()

If Len(aAliqCFGer) > 0	
	oReport:SkipLine()
	oReport:PrintText(STR0088,,10) //"Total"
	oReport:ThinLine()
	nLin := oReport:Row()
	oReport:PrintText(Transform(ABS(aContAliq[1]),PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("VALOR"):ColPos())
	oReport:PrintText(IIf(aContAliq[1] < 0,"(C)","(D)"),nLin,oContr:Cell("CD"):ColPos())
	oReport:PrintText(Transform(Abs(aContAliq[2]),PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("VALORCONT"):ColPos())
	oReport:PrintText(Transform(aContAliq[3],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("ZFRANCA"):ColPos())
	oReport:PrintText(Transform(aContAliq[4],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("VALDEBT"):ColPos()+28)
	oReport:PrintText(Transform(aContAliq[5],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("VALCRED"):ColPos()+26)
	oReport:PrintText(Transform(aContAliq[6],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("BASEDEBT"):ColPos()+22)
	oReport:PrintText(Transform(aContAliq[7],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("BASECRED"):ColPos()+20)

	oReport:SkipLine(2)
	oReport:PrintText(STR0110,,10) //"Total Apurado"
	oReport:ThinLine()
	nLin := oReport:Row()
	oReport:PrintText(Transform(ABS(aValContri[1]),PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("VALOR"):ColPos())
	oReport:PrintText(IIf(aValContri[1] < 0,"(C)","(D)"),nLin,oContr:Cell("CD"):ColPos())
	oReport:PrintText(Transform(Abs(aValContri[2]),PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("VALORCONT"):ColPos())
	oReport:PrintText(Transform(aValContri[3],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("ZFRANCA"):ColPos())
	oReport:PrintText(Transform(aValContri[4],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("VALDEBT"):ColPos()+28)
	oReport:PrintText(Transform(aValContri[5],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("VALCRED"):ColPos()+26)
	oReport:PrintText(Transform(aValContri[6],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("BASEDEBT"):ColPos()+22)
	oReport:PrintText(Transform(aValContri[7],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("BASECRED"):ColPos()+20)

	oReport:SkipLine(2)                                        
	oReport:PrintText(STR0143,,10) //"Total de Retenção(Modalidade da Dedução: Vencimento)........: "
	oReport:ThinLine()
	oReport:PrintText(Transform(nRetencao,PesqPict("SD2","D2_TOTAL")),,oContr:Cell("VALOR"):ColPos())
	
	oReport:SkipLine(2)
	oReport:PrintText(STR0144,,10) //"Total de Retenção - Orgãos Públicos(Modalidade da Dedução: Pagamento)........: "
	oReport:ThinLine()
	oReport:PrintText(Transform((IIF(nDedRet > nRetencao .And. lOrgPub,nDedRet-nRetencao,0)),PesqPict("SD2","D2_TOTAL")),,oContr:Cell("VALOR"):ColPos())
	
	oReport:SkipLine()
	oReport:PrintText(STR0112,,10) //"Total da Contribuição"
	oReport:ThinLine()
	nLin := oReport:Row()
	oReport:PrintText(Transform(ABS(aValContri[1] - nDedRet),PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("VALOR"):ColPos())
	oReport:PrintText(IIf(aValContri[1] < 0,"(C)","(D)"),nLin,oContr:Cell("CD"):ColPos())
	oReport:PrintText(Transform(Abs(aValContri[2]),PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("VALORCONT"):ColPos())
	oReport:PrintText(Transform(aValContri[3],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("ZFRANCA"):ColPos())
	oReport:PrintText(Transform(aValContri[4],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("VALDEBT"):ColPos()+28)
	oReport:PrintText(Transform(aValContri[5],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("VALCRED"):ColPos()+26)
	oReport:PrintText(Transform(aValContri[6],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("BASEDEBT"):ColPos()+22)
	oReport:PrintText(Transform(aValContri[7],PesqPict("SD2","D2_TOTAL")),nLin,oContr:Cell("BASECRED"):ColPos()+20)

	oReport:SkipLine(2)
	oReport:PrintText(STR0113,,10) //"(C) Credito / (D) Debito"	
EndIf
oReport:EndPage()
aAliqCFGer	:= {}
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ 
 ³ Autor ³ Liber De Esteban      ³ Data ³ 12/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria arquivo de trabalho para impressao no modelo grafico  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MONTATRB()

#IFDEF TOP
	Local aStruSD1		:= {}
	Local aStruSD2		:= {}
	Local aStruSB1 	 	:= {}
	Local aStruSF2		:= {}
	Local aStruSF1		:= {}
	Local aStruSF4		:= {}
	Local nX			:= 0
#ENDIF

Local cAliasSD2  	:= "SD2"
Local cAliasSD1  	:= "SD1"
Local cAliasSB1  	:= "SB1"
Local cAliasSF4  	:= "SF4"
Local cAliasSF2  	:= "SF2"
Local cAliasSF1  	:= "SF1"
Local cB1_GRTRIB 	:= ""             
Local cCliFor		:= ""
Local dDtCorte	  	:= GetNewPar("MV_DTCORTE",CtoD("01/02/2004"))		//A partir desta data o sistema devera utilizar as informacoes gravadas na base
Local lApurac    	:= (SF4->(FieldPos("F4_PISFISC")) > 0)
Local lA1_GRPTRIB	:= SA1->(FieldPos("A1_GRPTRIB")) != 0
Local lA2_GRPTRIB	:= SA2->(FieldPos("A2_GRPTRIB")) != 0
Local nRedPis	  	:= 1
Local nRedCOF	  	:= 1
Local nValPisPas 	:= 0
Local nBasPisPas 	:= 0
Local nValCofins 	:= 0 
Local nBasCofins 	:= 0 
Local nTxPis     	:= 0
Local nTxCof     	:= 0
Local nExPis     	:= 0
Local nExCof     	:= 0
Local nPautaPIS		:= 0
Local nPautaCOF		:= 0
Local cDebSTPIS		:= GetNewPar("MV_DBSTPIS","1")
Local cDebSTCOF		:= GetNewPar("MV_DBSTCOF","1")      

#IFDEF TOP
	Local cDEDBCOF		:= GetNewPar("MV_DEDBCOF"," ")      
	Local cDEDBPIS		:= GetNewPar("MV_DEDBPIS"," ")      
#ENDIF	

//Array para impressao do resumo por filial
aResumo	:= {}
AADD(aResumo,{STR0120,0,0}) //"Saidas"
AADD(aResumo,{STR0089,0,0}) //"Devoluções de Saidas"
AADD(aResumo,{STR0119,0,0}) //"Entradas"
AADD(aResumo,{STR0090,0,0}) //"Devoluções de Entradas"

oTemptable := FWTemporaryTable():New( "TRB")
//oTemptable:SetFields( aStru )
//oTempTable:AddIndex("index1", {"COD"} )
oTempTable:Create()

//cArqTemp := CriaTrab(aArqTemp)
//dbUseArea(.T.,__LocalDriver,cArqTemp,"TRB")
//IndRegua("TRB",cArqTemp,IIF(MV_PAR09==1,"TIPO+CFOP+DTOS(EMISSAO)","TIPO+CFOP"))
dbSelectArea("TRB")                                                                   
//Processamento das Saidas
dbSelectArea("SD2")
SD2->(dbSetOrder(5))
#IFDEF TOP
	lQuery		:= .T.
	cAliasSD2	:= "a906AMontSD2"
	cAliasSF2	:= "a906AMontSD2"
	cAliasSF4	:= "a906AMontSD2"
	cAliasSB1	:= "a906AMontSD2"

	aStruSD2	:= SD2->(dbStruct())
	aStruSB1	:= SB1->(dbStruct())	
	aStruSF4	:= SF4->(dbStruct())	
	aStruSF2	:= SF2->(dbStruct())	

	cQuery		:= "SELECT DISTINCT(D2_ITEM)D2_ITEM,F4_AGREG,F4_IPI,F2_SERIE,F2_DOC,F2_SEGURO,F2_FRETE,F2_DESPESA,F2_VALMERC,D2_TOTAL,D2_DOC,D2_SERIE,D2_EMISSAO,D2_CF,D2_COD,D2_DESCZFR,B1_POSIPI,D2_TIPO,"
	cQuery		+= "D2_ICMSRET,D2_VALIPI,D2_VALFRE,D2_SEGURO,D2_DESPESA,D2_CLIENTE,D2_LOJA,D2_VALBRUT "
	If !Empty( nPsVlPisSa )
		cQuery += "," + cCpVlPisSa
	EndIf
	If !Empty( nPsBsPisSa )
		cQuery += "," + cCpBsPisSa
	EndIf	
	If !Empty( nPsAlPisSa )
		cQuery += "," + cCpAlPisSa
	EndIf	
	If !Empty( nPsVlCofSa ) 
		cQuery += "," + cCpVlCOfSa 
	EndIf	
	If !Empty( nPsBsCofSa ) 
		cQuery += "," + cCpBsCofSa 
	EndIf
	If !Empty( nPsAlCofSa ) 
		cQuery += "," + cCpAlCOfSa 
	EndIf
	If SB1->(FieldPos("B1_PPIS")) >0
		cQuery += ",B1_PPIS "
	Endif
	If SB1->(FieldPos("B1_REDPIS")) > 0
		cQuery += ",B1_REDPIS "
	Endif
	If SB1->(FieldPos("B1_VLR_PIS")) >0    // Valor de Pauta PIS
		cQuery += ",B1_VLR_PIS "
	Endif
	If SB1->(FieldPos("B1_REDCOF")) > 0
		cQuery += ",B1_REDCOF "
	Endif
	If SB1->(FieldPos("B1_PCOFINS")) > 0	
		cQuery += ",B1_PCOFINS "
	Endif
	If SB1->(FieldPos("B1_VLR_COF")) >0    // Valor de Pauta COFINS
		cQuery += ",B1_VLR_COF "
	Endif		
	If SB1->(FieldPos("B1_GRTRIB")) > 0	
		cQuery += ",B1_GRTRIB "
	Endif	
	If SF4->(FieldPos("F4_BASEPIS")) > 0
		cQuery += ",F4_BASEPIS "	
	Endif	
	If SF4->(FieldPos("F4_BASECOF")) > 0
		cQuery += ",F4_BASECOF "	
	Endif
	If SF4->(FieldPos("F4_PISCOF")) > 0
		cQuery += ",F4_PISCOF "	
	Endif
	If SF4->(FieldPos("F4_PISCRED")) > 0
		cQuery += ",F4_PISCRED "	
	Endif	
	If SF4->(FieldPos("F4_TPREG")) > 0
		cQuery += ",F4_TPREG "	
	Endif		
	If lApurac
		cQuery += ",F4_PISFISC "
	Endif     
	//ADICIONA A DESCRIÇÃO DO ITEM NA SELECT
	cQuery += ",B1_DESC "
	cQuery 	+= "FROM "+RetSqlName("SD2")+" SD2 "
	cQuery 	+= "LEFT JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"' AND F4_CODIGO = D2_TES AND SF4.D_E_L_E_T_ = ' ' "  	
	cQuery 	+= "LEFT JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND	B1_COD = D2_COD AND SB1.D_E_L_E_T_ = ' ' "
	cQuery 	+= "LEFT JOIN "+RetSqlName("SF2")+" SF2 ON F2_FILIAL = '"+xFilial("SF2")+"' AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND "
	cQuery  += "F2_CLIENTE = D2_CLIENTE AND F2_LOJA = D2_LOJA AND F2_EMISSAO = D2_EMISSAO AND SF2.D_E_L_E_T_ = ' ' "
	cQuery 	+= "LEFT JOIN "+RetSqlName("SF3")+" SF3 ON F3_FILIAL = '"+xFilial("SF3")+"' AND F3_NFISCAL = D2_DOC AND F3_SERIE = D2_SERIE AND "
	cQuery  += "F3_CLIEFOR = D2_CLIENTE AND F3_LOJA = D2_LOJA AND SF3.D_E_L_E_T_ = ' ' " 	
	
	If MV_PAR12 == 1
		cQuery	+= "LEFT JOIN "+RetSqlName("SE1")+" SE1	ON E1_NUM = D2_DOC AND E1_PREFIXO = D2_SERIE"
	EndIf		

	cQuery 	+= "WHERE D2_FILIAL='"+xFilial("SD2")+"' AND "
	If MV_PAR12 == 1 .And. MV_PAR15 == 1
		cQuery 	+= "E1_BAIXA>='"+Dtos(MV_PAR02)+"' AND "
		cQuery 	+= "E1_BAIXA<='"+Dtos(MV_PAR03)+"' AND "		
		cQuery  += "SE1.D_E_L_E_T_ = ' ' AND "	
	Else	
		cQuery 	+= "D2_EMISSAO>='"+Dtos(MV_PAR02)+"' AND "
		cQuery 	+= "D2_EMISSAO<='"+Dtos(MV_PAR03)+"' AND "
	EndIf	
					
	cQuery  += "SD2.D_E_L_E_T_ = ' ' "	
		
	//Livro Selecionado	
	If !((Empty (MV_PAR05)) .Or. ("*"$MV_PAR05))
		cQuery += " AND F3_NRLIVRO='"+MV_PAR05+"' "
	EndIf
	  	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso os parametros/TES estejam configurados para deduzir o IPI da base de calculo 		    ³
	//³de PIS/COFINS considero o documento de complemento no relatorio, caso contrario mesmo que	³
	//³o documento calcule PIS/COFINS nao deve ser levado.                                      	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Upper(cDEDBCOF) $ "P#S" .Or. Upper(cDEDBPIS) $ "P#S" 
		cQuery  += " AND ((F4_IPI = 'S' AND F4_CREDIPI = 'N' "		
		cQuery  += " AND SF2.F2_TIPO IN('I', 'P'))  "	        	//Considera NF de Compelementos que utilizam a mesma TES que calcule PIS/COFINS
		cQuery  += " OR  (SF2.F2_TIPO NOT IN('I', 'P'))) "	        //Nao considera NF de Compelementos que utilizam a mesma TES que calcule PIS/COFINS		
	Else
		cQuery  += " AND SF2.F2_TIPO NOT IN('I', 'P') "	        	//Nao considera NF de Compelementos que utilizam a mesma TES que calcule PIS/COFINS
	EndIF
	
	If ExistBlock("MT996QRY")
		cQuery := ExecBlock("MT996QRY",.F.,.F.,{cQuery,1})
	EndIf

    If mv_par11 ==1
		cQuery += "ORDER BY D2_CF, D2_DOC, D2_CLIENTE"
	Else
		cQuery += "ORDER BY D2_CF, D2_COD, D2_CLIENTE"
	Endif	

	cQuery := ChangeQuery(cQuery)                                                      			
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)

	For nX := 1 To len(aStruSD2)
		If aStruSD2[nX][2] <> "C" .And. FieldPos(aStruSD2[nX][1])<>0
			TcSetField(cAliasSD2,aStruSD2[nX][1],aStruSD2[nX][2],aStruSD2[nX][3],aStruSD2[nX][4])
		EndIf
	Next nX

	For nX := 1 To len(aStruSB1)
		If aStruSB1[nX][2] <> "C" .And. FieldPos(aStruSB1[nX][1])<>0
			TcSetField(cAliasSB1,aStruSB1[nX][1],aStruSB1[nX][2],aStruSB1[nX][3],aStruSB1[nX][4])
		EndIf
	Next nX

	For nX := 1 To len(aStruSF4)
		If aStruSF4[nX][2] <> "C" .And. FieldPos(aStruSF4[nX][1])<>0
			TcSetField(cAliasSF4,aStruSF4[nX][1],aStruSF4[nX][2],aStruSF4[nX][3],aStruSF4[nX][4])
		EndIf
	Next nX

	For nX := 1 To len(aStruSF2)
		If aStruSF2[nX][2] <> "C" .And. FieldPos(aStruSF2[nX][1])<>0
			TcSetField(cAliasSF2,aStruSF2[nX][1],aStruSF2[nX][2],aStruSF2[nX][3],aStruSF2[nX][4])
		EndIf
	Next nX

	dbSelectArea(cAliasSD2)	
	nPsVlPisSa := ( cAliasSD2 )->( FieldPos( cCpVlPisSa ) )
	nPsBsPisSa := ( cAliasSD2 )->( FieldPos( cCpBsPisSa ) )
	nPsAlPisSa := ( cAliasSD2 )->( FieldPos( cCpAlPisSa ) )
	nPsVlCofSa := ( cAliasSD2 )->( FieldPos( cCpVlCofSa ) ) 
	nPsBsCOfSa := ( cAliasSD2 )->( FieldPos( cCpBsCofSa ) ) 
	nPsAlCofSa := ( cAliasSD2 )->( FieldPos( cCpAlCofSa ) ) 
#ELSE
    cAliasSD2 := "SD2"
    cIndex    := 'D2_CF'
	//CriaTrab(NIL,.F.)
	cKey	  := 'D2_CF'
	cCondicao := 'D2_FILIAL=="'+xFilial("SD2")+'".And.'
	cCondicao += 'DTOS(D2_EMISSAO)>="'+DTOS(MV_PAR02)+'".And.DTOS(D2_EMISSAO)<="'+DTOS(MV_PAR03)+'".And.'
	cCondicao += '!D2_TIPO$"I#P"'		//Nao considera NF de Compelementos que utilizam a mesma TES que calcule PIS/COFINS
	IndRegua(cAliasSD2,cIndex,cKey,,cCondicao)
	nIndex := RetIndex("SD2")
	dbSelectArea("SD2")
	dbSetIndex(cIndex+OrdBagExt())
	 
	dbSetOrder(nIndex+1)
	dbGoTop()
	dbSelectArea(cAliasSD2)
#ENDIF
While (cAliasSD2)->(!Eof()) 
	nPautaPIS := 0
	nPautaCOF := 0
	
	If !lQuery
		SF4->(dbSetOrder(1))
		SF4->(MsSeek(xFilial("SF4")+(cAliasSD2)->D2_TES))
		SB1->(dbSetOrder(1))
		SB1->(MsSeek(xFilial("SB1")+(cAliasSD2)->D2_COD))
		SF2->(dbSetOrder(1))
		SF2->(MsSeek(xFilial("SF2")+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
		cB1_GRTRIB := SB1->B1_GRTRIB
	Else
		cB1_GRTRIB := (cAliasSB1)->B1_GRTRIB
	EndIf
	//Verifica Cliente/Fornecedor
	SA1->(dbSetOrder(1))
	SA2->(dbSetOrder(1))
	If (cAliasSD2)->D2_TIPO$"DB"
		SA2->(MsSeek(xFilial("SA2")+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
		cCliFor 	:= SA2->A2_NOME
	Else
		SA1->(MsSeek(xFilial("SA1")+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
		cCliFor 	:= SA1->A1_NOME
	Endif	
	//Verifica a excecao fiscal
	cGrpTrib 	:= ""
	cUF		 	:= ""
	nExPis		:= 0
	nExCof 		:= 0
	If lA1_GRPTRIB .And. lA2_GRPTRIB .And. !Empty(cB1_GRTRIB)
		SA1->(dbSetOrder(1))
		SA2->(dbSetOrder(1))
		If (cAliasSD2)->D2_TIPO$"DB"
			SA2->(MsSeek(xFilial("SA2")+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
			cGrpTrib 	:= SA2->A2_GRPTRIB
			cUF			:= SA2->A2_EST
		Else
			SA1->(MsSeek(xFilial("SA2")+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
			cGrpTrib	:= SA1->A1_GRPTRIB
			cUF		:= SA1->A1_EST
		Endif                 	
		If !Empty(cGrpTrib)
			dbSelectArea("SF7")
			SF7->(dbSetOrder(1))
			If SF7->(dbSeek(xFilial("SF7")+cB1_GRTRIB+cGrpTrib))
				While !SF7->(Eof()) .And. SF7->F7_FILIAL+SF7->F7_GRTRIB+SF7->F7_GRPCLI == xFilial("SF7")+cB1_GRTRIB+cGrpTrib
					If (cUF == SF7->F7_EST .Or. SF7->F7_EST == "**")
						nExPis	:= Iif(SF7->(FieldPos("F7_ALIQPIS")) > 0,SF7->F7_ALIQPIS,0)
						nExCof 	:= Iif(SF7->(FieldPos("F7_ALIQCOF")) > 0,SF7->F7_ALIQCOF,0)
						Exit
					Endif
					SF7->(dbSkip())
				End
			EndIf
		EndIf
	EndIf
	
	If (cAliasSF4)->F4_AGREG <> "N"		
		If SB1->(FieldPos("B1_PPIS")) >0
			nTxPIS	:= 	Iif((cAliasSB1)->B1_PPIS <> 0,(cAliasSB1)->B1_PPIS , GetMv("MV_TXPIS"))
		Endif	
		If SB1->(FieldPos("B1_REDPIS")) > 0
			nRedPIS	:= 	Iif((cAliasSB1)->B1_REDPIS > 0,1-((cAliasSB1)->B1_REDPIS / 100 ), 1 )
		Endif		
		If SF4->(FieldPos("F4_BASEPIS")) > 0
			nRedPIS	*= 	Iif((cAliasSF4)->F4_BASEPIS > 0,1-((cAliasSF4)->F4_BASEPIS / 100 ), 1 )
		Endif		
		If SB1->(FieldPos("B1_VLR_PIS")) >0    // Valor de Pauta PIS
			nPautaPIS := (cAliasSB1)->B1_VLR_PIS
		Endif		
		If SB1->(FieldPos("B1_REDCOF")) > 0
			nRedCOF	:= 	Iif((cAliasSB1)->B1_REDCOF > 0,1-((cAliasSB1)->B1_REDCOF / 100 ), 1 )
		EndIf		
		If SF4->(FieldPos("F4_BASECOF")) > 0
			nRedCOF	*= 	Iif((cAliasSF4)->F4_BASECOF > 0,1-((cAliasSF4)->F4_BASECOF / 100 ), 1 )
		EndIf		
		If SB1->(FieldPos("B1_PCOFINS")) > 0	
			nTxCOF	:=	if((cAliasSB1)->B1_PCOFINS <> 0,(cAliasSB1)->B1_PCOFINS , GetMv("MV_TXCOFIN"))
		Endif  		
		If SB1->(FieldPos("B1_VLR_COF")) >0    // Valor de Pauta COFINS
			nPautaCOF := (cAliasSB1)->B1_VLR_COF
		Endif	

		If SF4->(FieldPos("F4_PISCOF")) > 0
			If !lApurac .Or. ((cAliasSF4)->F4_PISFISC<>"2")
				If (cAliasSF4)->F4_PISCOF $ "13" //1-PIS;3-Ambos
					nValPisPas := 0
					nBasPisPas := 0
					//Verifica se existem os campos para gravacao do valor/base do PIS 
					If (cAliasSD2)->D2_EMISSAO >= dDtCorte .And. ;
						!Empty( nPsVlPisSa ) .And. !Empty( nPsBsPisSa ) .And.  !Empty( nPsAlPisSa )
						nValPisPas	:= ( cAliasSD2 )->( FieldGet( nPsVlPisSa ) )
						nBasPisPas	:= ( cAliasSD2 )->( FieldGet( nPsBsPisSa ) )
						nTxPIS		:= ( cAliasSD2 )->( FieldGet( nPsAlPisSa ) )
					EndIf
					//PIS e Ambos
					If mv_par01 <> 2 .And. mv_par12 == 3 .And. !(cAliasSF4)->F4_TPREG$"123"
						RecLock("TRB",.T.)
						TRB->NUMNF     	:= (cAliasSD2)->D2_DOC
						TRB->SERIE     	:= (cAliasSD2)->D2_SERIE
						TRB->EMISSAO   	:= (cAliasSD2)->D2_EMISSAO
						TRB->CFOP      	:= (cAliasSD2)->D2_CF
						TRB->PRODUTO   	:= ALLTRIM((cAliasSD2)->D2_COD)+' - '+ALLTRIM((cAliasSB1)->B1_DESC)
						TRB->NCM       	:= (cAliasSB1)->B1_POSIPI
						TRB->VALORCONT 	:= CompVlCont(cAliasSD2)
						TRB->ZFRANCA   	:= (cAliasSD2)->D2_DESCZFR
						TRB->ALIQ      	:= Iif(nExPis == 0,Iif(nPautaPIS <> 0,nPautaPIS,nTxPIS),nExPis)
						TRB->TIPO      	:= "PIS"
						TRB->ES				:=	"S"
						TRB->CLIFOR			:= cCliFor
						TRB->PAUTA			:= Iif(nPautaPIS <> 0,"S","N")
						MsUnlock()
						//Verifica a Data de Corte ( 01/02/2004 )                           
						If (cAliasSD2)->D2_EMISSAO >= dDtCorte
							//Sempre efetua o debito na saida                       
							If SF4->(FieldPos("F4_PISCRED")) >0
								RecLock("TRB",.F.)
								If (cAliasSF4)->F4_PISCRED <> "4" .And. (cAliasSF4)->F4_PISCRED <> "1" // Se a opcao for 'calcula'/'credita', nao debita 
									TRB->PISDSAI   := nValPisPas
									TRB->BASPIDSAI := nBasPisPas					
								Endif	
								If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
									TRB->PISCSAI   := nValPisPas
									TRB->BASPICSAI := nBasPisPas
								Endif	
								MsUnlock()
							Endif	
						Else
							//Sempre efetua o debito na saida                                   
							If SF4->(FieldPos("F4_PISCRED")) >0
								RecLock("TRB",.F.)
								If (cAliasSF4)->F4_PISCRED <> "4" .And. (cAliasSF4)->F4_PISCRED <> "1"  // Se a opcao for 'calcula', nao debita 
									TRB->PISDSAI   := ( ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC) ) * nRedPis ) * (TRB->ALIQ/100)
									TRB->BASPIDSAI := ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC)  ) * nRedPis
								Endif	
								If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
									TRB->PISCSAI   := ( ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC) )  * nRedPis) * (TRB->ALIQ/100)
									TRB->BASPICSAI := ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC)  ) * nRedPis
								Endif	
								MsUnlock()
							Endif
						EndIf						
					Endif
					If mv_par01 <> 2 .And. mv_par12 == 1 .And. (cAliasSF4)->F4_TPREG$"123" //NAO CUMULATIVO/CUMULATIVO/AMBOS
						RecLock("TRB",.T.)
						TRB->NUMNF     	:= (cAliasSD2)->D2_DOC
						TRB->SERIE     	:= (cAliasSD2)->D2_SERIE
						TRB->EMISSAO   	:= (cAliasSD2)->D2_EMISSAO
						TRB->CFOP      	:= (cAliasSD2)->D2_CF
						TRB->PRODUTO   	:= ALLTRIM((cAliasSD2)->D2_COD)+' - '+ALLTRIM((cAliasSB1)->B1_DESC)
						TRB->NCM       	:= (cAliasSB1)->B1_POSIPI
						TRB->VALORCONT 	:= CompVlCont(cAliasSD2)
						TRB->ZFRANCA   	:= (cAliasSD2)->D2_DESCZFR
						TRB->ALIQ      	:= Iif(nExPis == 0,Iif(nPautaPIS <> 0,nPautaPIS,nTxPIS),nExPis)
						TRB->TIPO      	:= "PIS"
						TRB->ES			:=	"S"
						TRB->CLIFOR		:= cCliFor
						TRB->PAUTA		:= Iif(nPautaPIS <> 0,"S","N")
						MsUnlock()
						//Verifica a Data de Corte ( 01/02/2004 )
						If (cAliasSD2)->D2_EMISSAO >= dDtCorte
							//Sempre efetua o debito na saida                                  
							If SF4->(FieldPos("F4_PISCRED")) >0
								RecLock("TRB",.F.)
								If (cAliasSF4)->F4_PISCRED <> "4"  // Se a opcao for 'calcula', nao debita 
									TRB->PISDSAI   := nValPisPas
									TRB->BASPIDSAI := nBasPisPas					
								Endif	
							   //Cofins - Ambos
								If (cAliasSF4)->F4_PISCOF $ "23" .And. (cAliasSF4)->F4_PISCRED == "1" .And. mv_par01 <> 1
									TRB->PISCSAI   := nValPisPas
									TRB->BASPICSAI := nBasPisPas
								Endif	
								MsUnlock()
							Endif	
						Else
							//Sempre efetua o debito na saida                                   
							If SF4->(FieldPos("F4_PISCRED")) >0
								RecLock("TRB",.F.)
								If (cAliasSF4)->F4_PISCRED <> "4"  // Se a opcao for 'calcula', nao debita 
									TRB->PISDSAI   := ( ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC) ) * nRedPis ) * (TRB->ALIQ/100)
									TRB->BASPIDSAI := ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC)  ) * nRedPis
								Endif	
								If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
									TRB->PISCSAI   := ( ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC) )  * nRedPis) * (TRB->ALIQ/100)
									TRB->BASPICSAI := ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC)  ) * nRedPis
								Endif	
								MsUnlock()
							Endif
						EndIf						
					Endif	
					//NAO CUMULATIVO/CUMULATIVO/AMBOS					
					If mv_par01 <> 2 .And. mv_par12 == 2 .And. (cAliasSF4)->F4_TPREG$"1" 
						RecLock("TRB",.T.)
						TRB->NUMNF     	:= (cAliasSD2)->D2_DOC
						TRB->SERIE     	:= (cAliasSD2)->D2_SERIE
						TRB->EMISSAO   	:= (cAliasSD2)->D2_EMISSAO
						TRB->CFOP      	:= (cAliasSD2)->D2_CF
						TRB->PRODUTO   	:= ALLTRIM((cAliasSD2)->D2_COD)+' - '+ALLTRIM((cAliasSB1)->B1_DESC)
						TRB->NCM       	:= (cAliasSB1)->B1_POSIPI
						TRB->VALORCONT 	:= CompVlCont(cAliasSD2)
						TRB->ZFRANCA   	:= (cAliasSD2)->D2_DESCZFR
						TRB->ALIQ      	:= Iif(nExPis == 0,Iif(nPautaPIS <> 0,nPautaPIS,nTxPIS),nExPis)
						TRB->TIPO      	:= "PIS"
						TRB->ES			:=	"S"
						TRB->CLIFOR		:= cCliFor
						TRB->PAUTA		:= Iif(nPautaPIS <> 0,"S","N")
						MsUnlock()
						//Verifica a Data de Corte ( 01/02/2004 )                           
						If (cAliasSD2)->D2_EMISSAO >= dDtCorte
							//Sempre efetua o debito na saida                                   
							If SF4->(FieldPos("F4_PISCRED")) >0
								RecLock("TRB",.F.)
								If (cAliasSF4)->F4_PISCRED <> "4"  // Se a opcao for 'calcula', nao debita 
									TRB->PISDSAI   := nValPisPas
									TRB->BASPIDSAI := nBasPisPas					
								Endif	
								If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
									TRB->PISCSAI   := nValPisPas
									TRB->BASPICSAI := nBasPisPas
								Endif	
								MsUnlock()
							Endif	
						Else
							//Sempre efetua o debito na saida                                   
							If SF4->(FieldPos("F4_PISCRED")) >0
								RecLock("TRB",.F.)
								If (cAliasSF4)->F4_PISCRED <> "4"  // Se a opcao for 'calcula', nao debita 
									TRB->PISDSAI   := ( ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC) ) * nRedPis ) * (TRB->ALIQ/100)
									TRB->BASPIDSAI := ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC)  ) * nRedPis
								Endif	
								If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
									TRB->PISCSAI   := ( ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC) )  * nRedPis) * (TRB->ALIQ/100)
									TRB->BASPICSAI := ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC)  ) * nRedPis
								Endif	
								MsUnlock()
							Endif
						EndIf						
					Endif								
				EndIf
				//Cofins - Ambos
				If (cAliasSF4)->F4_PISCOF $ "23" .And. mv_par01 <> 1 .And. mv_par12 == 3 .And. !(cAliasSF4)->F4_TPREG$"123" 
					nValCofins := 0
					nBasCofins := 0
					//Verifica se existem os campos para gravacao do valor/base da COFINS 
					If (cAliasSD2)->D2_EMISSAO >= dDtCorte .And. ;
						!Empty( nPsVlCofSa ) .And. !Empty( nPsBsCofSa ) .And. !Empty( nPsAlCofSa )
						nValCofins	:= ( cAliasSD2 )->( FieldGet( nPsVlCofSa ) )
						nBasCofins	:= ( cAliasSD2 )->( FieldGet( nPsBsCofSa ) )
						nTxCOF		:= ( cAliasSD2 )->( FieldGet( nPsAlCofSa ) )
					EndIf						
					RecLock("TRB",.T.)
					TRB->NUMNF     := (cAliasSD2)->D2_DOC
					TRB->SERIE     := (cAliasSD2)->D2_SERIE
					TRB->EMISSAO   := (cAliasSD2)->D2_EMISSAO
					TRB->CFOP      := (cAliasSD2)->D2_CF
					TRB->PRODUTO   	:= ALLTRIM((cAliasSD2)->D2_COD)+' - '+ALLTRIM((cAliasSB1)->B1_DESC)
					TRB->NCM       := (cAliasSB1)->B1_POSIPI
					TRB->VALORCONT := CompVlCont(cAliasSD2)
					TRB->ZFRANCA   := (cAliasSD2)->D2_DESCZFR
					TRB->ALIQ      := Iif(nExCof == 0,Iif(nPautaCOF <> 0,nPautaCOF,nTxCOF),nExCof)
					TRB->TIPO      := "COF"
					TRB->ES        := "S"
					TRB->CLIFOR		:= cCliFor
					TRB->PAUTA		:= Iif(nPautaCOF <> 0,"S","N")					
					MsUnlock()
					//Verifica a Data de Corte ( 01/02/2004 )                           
					If (cAliasSD2)->D2_EMISSAO >= dDtCorte
						If SF4->(FieldPos("F4_PISCRED")) >0
							RecLock("TRB",.F.)
							If (cAliasSF4)->F4_PISCRED <> "4" .And. (cAliasSF4)->F4_PISCRED <> "1" // Se a opcao for 'calcula', nao debita 
								TRB->COFDSAI   := nValCofins
								TRB->BASCODSAI := nBasCofins
							Endif	
							If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
								TRB->COFCSAI   := nValCofins
								TRB->BASCOCSAI := nBasCofins
							Endif	
							MsUnlock()
						Endif	
		            Else
						If SF4->(FieldPos("F4_PISCRED")) >0
							RecLock("TRB",.F.)
							If (cAliasSF4)->F4_PISCRED <> "4" .And. (cAliasSF4)->F4_PISCRED <> "1"
								TRB->COFDSAI   := ( ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC) ) * nRedCOF) * (TRB->ALIQ/100)
								TRB->BASCODSAI := ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC)  ) * nRedCOF
							Endif	
							If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita ;2-Debita
								TRB->COFCSAI   := ( ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC) )  * nRedCOF) * (TRB->ALIQ/100)
								TRB->BASCOCSAI := ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC)  ) * nRedCOF
							Endif	
							MsUnlock()
						Endif	
					Endif
				EndIf							
				//NAO CUMULATIVO/CUMULATIVO/AMBOS
				If (cAliasSF4)->F4_PISCOF $ "23" .And. mv_par01 <> 1 .And. mv_par12 == 1 .And. (cAliasSF4)->F4_TPREG$"123" 
					nValCofins := 0
					nBasCofins := 0
					//Verifica se existem os campos para gravacao do valor/base da COFINS  
					If (cAliasSD2)->D2_EMISSAO >= dDtCorte .And. ;
						!Empty( nPsVlCofSa ) .And. !Empty( nPsBsCofSa ) .And. !Empty( nPsAlCofSa )
						nValCofins	:= ( cAliasSD2 )->( FieldGet( nPsVlCofSa ) )
						nBasCofins	:= ( cAliasSD2 )->( FieldGet( nPsBsCofSa ) )
						nTxCOF		:= ( cAliasSD2 )->( FieldGet( nPsAlCofSa ) )
					EndIf						
					RecLock("TRB",.T.)
					TRB->NUMNF     := (cAliasSD2)->D2_DOC
					TRB->SERIE     := (cAliasSD2)->D2_SERIE
					TRB->EMISSAO   := (cAliasSD2)->D2_EMISSAO
					TRB->CFOP      := (cAliasSD2)->D2_CF
					TRB->PRODUTO   	:= ALLTRIM((cAliasSD2)->D2_COD)+' - '+ALLTRIM((cAliasSB1)->B1_DESC)
					TRB->NCM       := (cAliasSB1)->B1_POSIPI
					TRB->VALORCONT := CompVlCont(cAliasSD2)
					TRB->ZFRANCA   := (cAliasSD2)->D2_DESCZFR
					TRB->ALIQ      := Iif(nExCof == 0,Iif(nPautaCOF <> 0,nPautaCOF,nTxCOF),nExCof)
					TRB->TIPO      := "COF"
					TRB->ES        := "S"
					TRB->CLIFOR	   := cCliFor
					TRB->PAUTA	   := Iif(nPautaCOF <> 0,"S","N")					
					MsUnlock()
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica a Data de Corte ( 01/02/2004 )                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (cAliasSD2)->D2_EMISSAO >= dDtCorte
						If SF4->(FieldPos("F4_PISCRED")) >0
							RecLock("TRB",.F.)
							If (cAliasSF4)->F4_PISCRED <> "4"  // Se a opcao for 'calcula', nao debita 
								TRB->COFDSAI   := nValCofins
								TRB->BASCODSAI := nBasCofins
							Endif	
							If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
								TRB->COFCSAI   := nValCofins
								TRB->BASCOCSAI := nBasCofins
							Endif	
							MsUnlock()
						Endif	
		            Else
						If SF4->(FieldPos("F4_PISCRED")) >0
							RecLock("TRB",.F.)
							If (cAliasSF4)->F4_PISCRED <> "4"
								TRB->COFDSAI   := ( ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC) ) * nRedCOF) * (TRB->ALIQ/100)
								TRB->BASCODSAI := ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC)  ) * nRedCOF
							Endif	
							If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita ;2-Debita
								TRB->COFCSAI   := ( ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC) )  * nRedCOF) * (TRB->ALIQ/100)
								TRB->BASCOCSAI := ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC)  ) * nRedCOF
							Endif	
							MsUnlock()
						Endif	
					Endif
				EndIf		
				//NAO CUMULATIVO/CUMULATIVO/AMBOS
				If (cAliasSF4)->F4_PISCOF $ "23" .And. mv_par01 <> 1 .And. mv_par12 == 2 .And. (cAliasSF4)->F4_TPREG$"1" 
					nValCofins := 0
					nBasCofins := 0
					//Verifica se existem os campos para gravacao do valor/base da COFINS  
					If (cAliasSD2)->D2_EMISSAO >= dDtCorte .And. ;
						!Empty( nPsVlCofSa ) .And. !Empty( nPsBsCofSa ) .And. !Empty( nPsAlCofSa )
						nValCofins	:= ( cAliasSD2 )->( FieldGet( nPsVlCofSa ) )
						nBasCofins	:= ( cAliasSD2 )->( FieldGet( nPsBsCofSa ) )
						nTxCOF		:= ( cAliasSD2 )->( FieldGet( nPsAlCofSa ) )
					EndIf						
					RecLock("TRB",.T.)
					TRB->NUMNF     := (cAliasSD2)->D2_DOC
					TRB->SERIE     := (cAliasSD2)->D2_SERIE
					TRB->EMISSAO   := (cAliasSD2)->D2_EMISSAO
					TRB->CFOP      := (cAliasSD2)->D2_CF
					TRB->PRODUTO   	:= ALLTRIM((cAliasSD2)->D2_COD)+' - '+ALLTRIM((cAliasSB1)->B1_DESC)
					TRB->NCM       := (cAliasSB1)->B1_POSIPI
					TRB->VALORCONT := CompVlCont(cAliasSD2)
					TRB->ZFRANCA   := (cAliasSD2)->D2_DESCZFR
					TRB->ALIQ      := Iif(nExCof == 0,Iif(nPautaCOF <> 0,nPautaCOF,nTxCOF),nExCof)
					TRB->TIPO      := "COF"
					TRB->ES        := "S"
					TRB->CLIFOR	   := cCliFor
					TRB->PAUTA	   := Iif(nPautaCOF <> 0,"S","N")					
					MsUnlock()
					//Verifica a Data de Corte ( 01/02/2004 )                           
					If (cAliasSD2)->D2_EMISSAO >= dDtCorte
						If SF4->(FieldPos("F4_PISCRED")) >0
							RecLock("TRB",.F.)
							If (cAliasSF4)->F4_PISCRED <> "4"  // Se a opcao for 'calcula', nao debita 
								TRB->COFDSAI   := nValCofins
								TRB->BASCODSAI := nBasCofins
							Endif	
							If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
								TRB->COFCSAI   := nValCofins
								TRB->BASCOCSAI := nBasCofins
							Endif	
							MsUnlock()
						Endif	
		            Else
						If SF4->(FieldPos("F4_PISCRED")) >0
							RecLock("TRB",.F.)
							If (cAliasSF4)->F4_PISCRED <> "4"
								TRB->COFDSAI   := ( ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC) ) * nRedCOF) * (TRB->ALIQ/100)
								TRB->BASCODSAI := ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC)  ) * nRedCOF
							Endif	
							If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita ;2-Debita
								TRB->COFCSAI   := ( ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC) )  * nRedCOF) * (TRB->ALIQ/100)
								TRB->BASCOCSAI := ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC)  ) * nRedCOF
							Endif	
							MsUnlock()
						Endif	
					Endif
				EndIf
				//Gera as informacoes para o Resumo -  Saida 			
				If mv_par12 == 1 .And. (cAliasSF4)->F4_TPREG$"123" //NAO CUMULATIVO/CUMULATIVO/AMBOS
					If (cAliasSF4)->F4_PISCOF $ "123" //1-PIS;2-COFINS;3-Ambos				
						If !(cAliasSD2)->D2_TIPO $ "BD"                   
							If (cAliasSF4)->F4_PISCOF == "1" 
								aResumo[1][2] += (cAliasSD2)->D2_TOTAL+If(cDebSTPIS=="6",0,(cAliasSD2)->D2_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD2)->D2_TIPO=="P",0,(cAliasSD2)->D2_VALIPI))+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA)
							EndIf
							If (cAliasSF4)->F4_PISCOF == "2" 
								aResumo[1][2] += (cAliasSD2)->D2_TOTAL+If(cDebSTCOF=="6",0,(cAliasSD2)->D2_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD2)->D2_TIPO=="P",0,(cAliasSD2)->D2_VALIPI))+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA)
							EndIf
							If (cAliasSF4)->F4_PISCOF == "3" 
								aResumo[1][2] += (cAliasSD2)->D2_TOTAL+If(cDebSTCOF=="6" .And. cDebSTPIS=="6",0,(cAliasSD2)->D2_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD2)->D2_TIPO=="P",0,(cAliasSD2)->D2_VALIPI))+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA)
							EndIf
							//nVendTrib
						EndIf
					
						If (cAliasSD2)->D2_TIPO == "D" 
							If (cAliasSF4)->F4_PISCOF == "1" 
								aResumo[4][2] += (cAliasSD2)->D2_TOTAL+If(cDebSTPIS=="6",0,(cAliasSD2)->D2_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD2)->D2_TIPO=="P",0,(cAliasSD2)->D2_VALIPI))+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA)
							EndIf
							If (cAliasSF4)->F4_PISCOF == "2" 
								aResumo[4][2] += (cAliasSD2)->D2_TOTAL+If(cDebSTCOF=="6",0,(cAliasSD2)->D2_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD2)->D2_TIPO=="P",0,(cAliasSD2)->D2_VALIPI))+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA)
							EndIf						
							If (cAliasSF4)->F4_PISCOF == "3" 
								aResumo[4][2] += (cAliasSD2)->D2_TOTAL+If(cDebSTPIS=="6" .And. cDebSTCOF=="6",0,(cAliasSD2)->D2_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD2)->D2_TIPO=="P",0,(cAliasSD2)->D2_VALIPI))+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA)
							EndIf						
							//nDevCompT
						EndIF									
					ELSE
						If !(cAliasSD2)->D2_TIPO $ "BD" 
							aResumo[1][3] += (cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD2)->D2_TIPO=="P",0,(cAliasSD2)->D2_VALIPI))+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA
							//nValVend
						EndIF				
	
			   		If (cAliasSD2)->D2_TIPO == "D" 
							aResumo[4][3] += (cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD2)->D2_TIPO=="P",0,(cAliasSD2)->D2_VALIPI))+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA // Devolucoes Compras D2
							//nValDevComp
						EndIF				
					Endif
				Endif	                                            
				//NAO CUMULATIVO/CUMULATIVO/AMBOS
				If mv_par12 == 2 .And. (cAliasSF4)->F4_TPREG$"1" 
					If (cAliasSF4)->F4_PISCOF $ "123" //1-PIS;2-COFINS;3-Ambos					
						If !(cAliasSD2)->D2_TIPO $ "BD" 
							If (cAliasSF4)->F4_PISCOF == "1"
								aResumo[1][2] += (cAliasSD2)->D2_TOTAL+If(cDebSTPIS=="6",0,(cAliasSD2)->D2_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD2)->D2_TIPO=="P",0,(cAliasSD2)->D2_VALIPI))+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA)
							EndIf
							If (cAliasSF4)->F4_PISCOF == "2"
								aResumo[1][2] += (cAliasSD2)->D2_TOTAL+If(cDebSTCOF=="6",0,(cAliasSD2)->D2_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD2)->D2_TIPO=="P",0,(cAliasSD2)->D2_VALIPI))+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA)
							EndIf
							If (cAliasSF4)->F4_PISCOF == "3"
								aResumo[1][2] += (cAliasSD2)->D2_TOTAL+If(cDebSTCOF=="6" .And. cDebSTPIS=="6",0,(cAliasSD2)->D2_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD2)->D2_TIPO=="P",0,(cAliasSD2)->D2_VALIPI))+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA)
							EndIf
							//nVendTrib
						EndIf
						
						If (cAliasSD2)->D2_TIPO == "D" 
							If (cAliasSF4)->F4_PISCOF == "1"
								aResumo[4][2] += (cAliasSD2)->D2_TOTAL+If(cDebSTPIS=="6",0,(cAliasSD2)->D2_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD2)->D2_TIPO=="P",0,(cAliasSD2)->D2_VALIPI))+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA)
							EndIf
							If (cAliasSF4)->F4_PISCOF == "2"
								aResumo[4][2] += (cAliasSD2)->D2_TOTAL+If(cDebSTCOF=="6",0,(cAliasSD2)->D2_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD2)->D2_TIPO=="P",0,(cAliasSD2)->D2_VALIPI))+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA)
							EndIf
							If (cAliasSF4)->F4_PISCOF == "3"
								aResumo[4][2] += (cAliasSD2)->D2_TOTAL+If(cDebSTCOF=="6" .And. cDebSTPIS=="6",0,(cAliasSD2)->D2_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD2)->D2_TIPO=="P",0,(cAliasSD2)->D2_VALIPI))+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA)
							EndIf							
							//nDevCompT
						EndIF										
					ELSE
						If !(cAliasSD2)->D2_TIPO $ "BD"               						
							aResumo[1][3] += (cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD2)->D2_TIPO=="P",0,(cAliasSD2)->D2_VALIPI))+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA
							//nValVend
						EndIF	
			   		If (cAliasSD2)->D2_TIPO == "D" 
							aResumo[4][3] += (cAliasSD2)->D2_TOTAL+If(cDebSTCOF=="6",0,(cAliasSD2)->D2_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD2)->D2_TIPO=="P",0,(cAliasSD2)->D2_VALIPI))+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA) // Devolucoes Compras D2
							//nValDevComp
						EndIF				
					Endif
				EndIf
				//NAO CUMULATIVO/CUMULATIVO/AMBOS
				If mv_par12 == 3 .And. !((cAliasSF4)->F4_TPREG$"123") .And. !(cAliasSF4)->F4_TPREG$"123" 
					If (cAliasSF4)->F4_PISCOF $ "123" //1-PIS;2-COFINS;3-Ambos
					
						If !(cAliasSD2)->D2_TIPO $ "BD" 							
							If (cAliasSF4)->F4_PISCOF == "1"
								aResumo[1][2] += (cAliasSD2)->D2_TOTAL+If(cDebSTPIS=="6",0,(cAliasSD2)->D2_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD2)->D2_TIPO=="P",0,(cAliasSD2)->D2_VALIPI))+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA)
							EndIf
							If (cAliasSF4)->F4_PISCOF == "2"
								aResumo[1][2] += (cAliasSD2)->D2_TOTAL+If(cDebSTCOF=="6",0,(cAliasSD2)->D2_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD2)->D2_TIPO=="P",0,(cAliasSD2)->D2_VALIPI))+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA)
							EndIf
							If (cAliasSF4)->F4_PISCOF == "3"
								aResumo[1][2] += (cAliasSD2)->D2_TOTAL+If(cDebSTCOF=="6" .And. cDebSTPIS=="6" ,0,(cAliasSD2)->D2_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD2)->D2_TIPO=="P",0,(cAliasSD2)->D2_VALIPI))+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA)
							EndIf
							//nVendTrib
						EndIf
						
						If (cAliasSD2)->D2_TIPO == "D" 
							If (cAliasSF4)->F4_PISCOF == "1"							
								aResumo[4][2] += (cAliasSD2)->D2_TOTAL+If(cDebSTPIS=="6"  .And. cDebSTPIS=="6",0,(cAliasSD2)->D2_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD2)->D2_TIPO=="P",0,(cAliasSD2)->D2_VALIPI))+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA)
							EndIf
							If (cAliasSF4)->F4_PISCOF == "2"							
								aResumo[4][2] += (cAliasSD2)->D2_TOTAL+If(cDebSTCOF=="6",0,(cAliasSD2)->D2_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD2)->D2_TIPO=="P",0,(cAliasSD2)->D2_VALIPI))+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA)
							EndIf
							If (cAliasSF4)->F4_PISCOF == "3"							
								aResumo[4][2] += (cAliasSD2)->D2_TOTAL+If(cDebSTPIS=="6"  .And. cDebSTPIS=="6",0,(cAliasSD2)->D2_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD2)->D2_TIPO=="P",0,(cAliasSD2)->D2_VALIPI))+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA)
							EndIf							
							//nDevCompT
						EndIF	
									
					ELSE
						If !(cAliasSD2)->D2_TIPO $ "BD" 
							aResumo[1][3] += (cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD2)->D2_TIPO=="P",0,(cAliasSD2)->D2_VALIPI))+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA
							//nValVend
						EndIF				
		
			   		If (cAliasSD2)->D2_TIPO == "D" 
							aResumo[4][3] += (cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD2)->D2_TIPO=="P",0,(cAliasSD2)->D2_VALIPI))+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA // Devolucoes Compras D2
							//nValDevComp
						EndIF				
					Endif
				EndIf			
			Endif	
		EndIf
	EndIf
	(cAliasSD2)->( dbSkip())
EndDo
If lQuery
	dbSelectArea(cAliasSD2)
	dbCloseArea()
	dbSelectArea("SD2")
Else
	dbSelectArea("SD2")
	RetIndex("SD2")
	dbClearFilter()
	Ferase(cIndex+OrdBagExt())
EndIf
//Processamento das Entradas                                        
dbSelectArea("SD1")
SD1->(dbSetOrder(6))
#IFDEF TOP
	lQuery		:= .T.
	cAliasSD1	:= "a906AMontSD1"
	cAliasSF4	:= "a906AMontSD1"
	cAliasSB1	:= "a906AMontSD1"	
	cAliasSF1	:= "a906AMontSD1"	

	aStruSD1	:= SD1->(dbStruct())
	aStruSB1	:= SB1->(dbStruct())	
	aStruSF4	:= SF4->(dbStruct())	
	aStruSF1	:= SF1->(dbStruct())	

	cQuery		:= "SELECT DISTINCT(D1_ITEM)D1_ITEM,D1_CF,D1_COD,D1_TOTAL,D1_VALDESC,B1_POSIPI,D1_DOC,D1_SERIE,D1_DTDIGIT,D1_TIPO, "
	cQuery		+= "D1_ICMSRET,D1_VALIPI,D1_VALFRE,D1_SEGURO,D1_DESPESA,D1_VALICM,D1_FORNECE,D1_LOJA, "

	If !Empty( nPsVlPisEn )
		cQuery += cCpVlPisEn + ","
	EndIf
	If !Empty( nPsBsPisEn )
		cQuery += cCpBsPisEn + ","
	EndIf
	If !Empty( nPsAlPisEn )
		cQuery += cCpAlPisEn + ","
	EndIf	
	If !Empty( nPsVlCofEn ) 
		cQuery += cCpVlCofEn + "," 
	EndIf 
	If !Empty( nPsBsCofEn ) 
		cQuery += cCpBsCofEn + "," 
	EndIf 
	If !Empty( nPsAlCofEn ) 
		cQuery += cCpAlCofEn + "," 
	EndIf 
	If SF4->( FieldPos( "F4_AGRPIS" ) )>0
		cQuery	+=	"F4_AGRPIS,"
	EndIF
	If SF4->( FieldPos( "F4_AGRCOF" ) )>0
		cQuery	+=	"F4_AGRCOF,"
	EndIF

	cQuery  += "F4_AGREG,F4_PISCOF,F4_IPI,F1_SEGURO,F1_FRETE,F1_DESPESA,F1_VALMERC,F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA "

	If SB1->(FieldPos("B1_PPIS")) >0
		cQuery += ",B1_PPIS "
	Endif	
	If SB1->(FieldPos("B1_REDPIS")) > 0
		cQuery += ",B1_REDPIS "
	Endif	
	If SB1->(FieldPos("B1_VLR_PIS")) >0    // Valor de Pauta PIS
		cQuery += ",B1_VLR_PIS "
	Endif	
	If SB1->(FieldPos("B1_REDCOF")) > 0
		cQuery += ",B1_REDCOF "
	Endif	
	If SB1->(FieldPos("B1_PCOFINS")) > 0	
		cQuery += ",B1_PCOFINS "
	Endif
	If SB1->(FieldPos("B1_VLR_COF")) >0    // Valor de Pauta COFINS
		cQuery += ",B1_VLR_COF "
	Endif	
	If SB1->(FieldPos("B1_GRTRIB")) > 0	
		cQuery += ",B1_GRTRIB "
	Endif
	If SF4->(FieldPos("F4_BASEPIS")) > 0
		cQuery += ",F4_BASEPIS "
	Endif	
	If SF4->(FieldPos("F4_PISCOF")) > 0
		cQuery += ",F4_PISCOF "	
	Endif		
	If SF4->(FieldPos("F4_BASECOF")) > 0
		cQuery += ",F4_BASECOF "	
	Endif
	If SF4->(FieldPos("F4_PISCRED")) > 0
		cQuery += ",F4_PISCRED "	
	Endif		
	If SF4->(FieldPos("F4_TPREG")) > 0
		cQuery += ",F4_TPREG "	
	Endif		
	If lApurac
		cQuery += ",F4_PISFISC "
	Endif
   //Tratamento Aliquota Majorada da PIS.
	If SF4->(FieldPos("F4_MALQPIS") > 0) .And. SD1->(FieldPos("D1_VALPMAJ") > 0) 
	    cQuery += ",F4_MALQPIS, D1_VALPMAJ "
	EndIf 
    //Tratamento Aliquota Majorada da COFINS.
	If SF4->(FieldPos("F4_MALQCOF") > 0) .And. SD1->(FieldPos("D1_VALCMAJ") > 0)
	    cQuery += ",F4_MALQCOF,D1_VALCMAJ "
	EndIf    
	cQuery += ",B1_DESC "
	cQuery 	+= "FROM "+RetSqlName("SD1")+" SD1 "
	cQuery 	+= "LEFT JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL ='"+xFilial("SF4")+"' AND F4_CODIGO = D1_TES AND SF4.D_E_L_E_T_ = ' ' " 
	cQuery 	+= "LEFT JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = D1_COD AND SB1.D_E_L_E_T_ = ' ' " 	
	cQuery 	+= "LEFT JOIN "+RetSqlName("SF1")+" SF1 ON F1_FILIAL = '"+xFilial("SF1")+"' AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND "
	cQuery  += "F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA AND F1_DTDIGIT = D1_DTDIGIT AND SF1.D_E_L_E_T_ = ' ' "	
	cQuery 	+= "LEFT JOIN "+RetSqlName("SF3")+" SF3 ON F3_FILIAL = '"+xFilial("SF3")+"' AND F3_NFISCAL = D1_DOC AND F3_SERIE = D1_SERIE AND "
	cQuery  += "F3_CLIEFOR = D1_FORNECE AND F3_LOJA = D1_LOJA AND SF3.D_E_L_E_T_ = ' ' " 	 	

	cQuery 	+= "WHERE D1_FILIAL='"+xFilial("SD1")+"' AND "
	cQuery 	+= "D1_DTDIGIT>='"+Dtos(MV_PAR02)+"' AND "
	cQuery 	+= "D1_DTDIGIT<='"+Dtos(MV_PAR03)+"' AND "
	cQuery	+= "SD1.D_E_L_E_T_ = ' ' "
		
	//Livro Selecionado	
	If !((Empty (MV_PAR05)) .Or. ("*"$MV_PAR05))
		cQuery += " AND F3_NRLIVRO='"+MV_PAR05+"' "
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso os parametros/TES estejam configurados para deduzir o IPI da base de calculo  	        ³
	//³de PIS/COFINS considero o documento de complemento no relatorio, caso contrario mesmo que	³
	//³o documento calcule PIS/COFINS nao deve ser levado.                                      	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Upper(cDEDBCOF) $ "P#S" .Or. Upper(cDEDBPIS) $ "P#S" 
		cQuery  += " AND ((F4_IPI = 'S' AND F4_CREDIPI = 'N' "		
		cQuery  += " AND SF1.F1_TIPO IN('I', 'P'))  "	        	//Considera NF de Compelementos que utilizam a mesma TES que calcule PIS/COFINS
		cQuery  += " OR  (SF1.F1_TIPO NOT IN('I', 'P'))) "	        //Nao considera NF de Compelementos que utilizam a mesma TES que calcule PIS/COFINS		
	Else
		cQuery  += " AND SF1.F1_TIPO NOT IN('I', 'P') "	        	//Nao considera NF de Compelementos que utilizam a mesma TES que calcule PIS/COFINS
	EndIF		
	
	If ExistBlock("MT996QRY")
		cQuery := ExecBlock("MT996QRY",.F.,.F.,{cQuery,2})
	EndIf

	If mv_par11 ==1
		cQuery += "ORDER BY D1_CF, D1_DOC"
	Else
		cQuery += "ORDER BY D1_CF, D1_COD"
	Endif

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)

	For nX := 1 To len(aStruSD1)
		If aStruSD1[nX][2] <> "C" .And. FieldPos(aStruSD1[nX][1])<>0
			TcSetField(cAliasSD1,aStruSD1[nX][1],aStruSD1[nX][2],aStruSD1[nX][3],aStruSD1[nX][4])
		EndIf
	Next nX

	For nX := 1 To len(aStruSB1)
		If aStruSB1[nX][2] <> "C" .And. FieldPos(aStruSB1[nX][1])<>0
			TcSetField(cAliasSB1,aStruSB1[nX][1],aStruSB1[nX][2],aStruSB1[nX][3],aStruSB1[nX][4])
		EndIf
	Next nX

	For nX := 1 To len(aStruSF4)
		If aStruSF4[nX][2] <> "C" .And. FieldPos(aStruSF4[nX][1])<>0
			TcSetField(cAliasSF4,aStruSF4[nX][1],aStruSF4[nX][2],aStruSF4[nX][3],aStruSF4[nX][4])
		EndIf
	Next nX

	For nX := 1 To len(aStruSF1)
		If aStruSF1[nX][2] <> "C" .And. FieldPos(aStruSF1[nX][1])<>0
			TcSetField(cAliasSF1,aStruSF1[nX][1],aStruSF1[nX][2],aStruSF1[nX][3],aStruSF1[nX][4])
		EndIf
	Next nX                     	
	
	dbSelectArea(cAliasSD1)
	nPsVlPisEn := ( cAliasSD1 )->( FieldPos( cCpVlPisEn ) )
	nPsBsPisEn := ( cAliasSD1 )->( FieldPos( cCpBsPisEn ) )
	nPsAlPisEn := ( cAliasSD1 )->( FieldPos( cCpAlPisEn ) ) 	
	nPsVlCofEn := ( cAliasSD1 )->( FieldPos( cCpVlCofEn ) )
	nPsBsCofEn := ( cAliasSD1 )->( FieldPos( cCpBsCofEn ) ) 	
	nPsAlCofEn := ( cAliasSD1 )->( FieldPos( cCpAlCofEn ) )
#ELSE
   cAliasSD1	:= "SD1"
   cIndex1		:= 'D1_CF' //CriaTrab(NIL,.F.)
	cKey			:= 'D1_CF'
	cCondicao	:= 'D1_FILIAL=="'+xFilial("SD1")+'".And.'
	cCondicao	+= 'DTOS(D1_DTDIGIT)>="'+DTOS(MV_PAR02)+'".And.DTOS(D1_DTDIGIT)<="'+DTOS(MV_PAR03)+'".And.'
	cCondicao	+= '!D1_TIPO$"I#P"'		//Nao considera NF de Compelementos que utilizam a mesma TES que calcule PIS/COFINS
	IndRegua(cAliasSD1,cIndex1,cKey,,cCondicao)
	nIndex := RetIndex("SD1")
	dbSelectArea("SD1")
	dbSetIndex(cIndex1+OrdBagExt())
	 
	dbSetOrder(nIndex+1)
	dbGoTop()
	dbSelectArea(cAliasSD1)
#ENDIF
While (cAliasSD1)->(!Eof()) 
	nPautaPIS := 0
	nPautaCOF := 0
	
	If !lQuery
		SF4->(dbSetOrder(1))
		SF4->(MsSeek(xFilial("SF4")+(cAliasSD1)->D1_TES))
		SB1->(dbSetOrder(1))
		SB1->(MsSeek(xFilial("SB1")+(cAliasSD1)->D1_COD))
		SF1->(dbSetOrder(1))
		SF1->(MsSeek(xFilial("SF1")+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_TIPO))
		cB1_GRTRIB := SB1->B1_GRTRIB
	Else                            
		cB1_GRTRIB := (cAliasSB1)->B1_GRTRIB
		//Livro Selecionado
		If !((Empty (MV_PAR05)) .Or. ("*"$MV_PAR05))
			If !(SF3->F3_NRLIVRO==MV_PAR05)
				lValido := .F.
			EndIf
		EndIf
	EndIf                        
	//Verifica Cliente/Fornecedor   
	SA1->(dbSetOrder(1))
	SA2->(dbSetOrder(1))
		
	If (cAliasSD1)->D1_TIPO$"DB"
		SA1->(MsSeek(xFilial("SA1")+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))
		cCliFor 	:= SA1->A1_NOME
	Else
		SA2->(MsSeek(xFilial("SA2")+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))
		cCliFor 	:= SA2->A2_NOME
	Endif
	//Verifica a excecao fiscal
	cGrpTrib 	:= ""
	cUF		 	:= ""
	nExPis		:= 0
	nExCof 		:= 0
	If lA1_GRPTRIB .And. lA2_GRPTRIB .And. !Empty(cB1_GRTRIB)
		SA1->(dbSetOrder(1))
		SA2->(dbSetOrder(1))
		If (cAliasSD1)->D1_TIPO$"DB"
			SA1->(MsSeek(xFilial("SA2")+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))
			cGrpTrib	:= SA1->A1_GRPTRIB
			cUF		:= SA1->A1_EST
		Else
			SA2->(MsSeek(xFilial("SA2")+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))
			cGrpTrib	:= SA2->A2_GRPTRIB
			cUF		:= SA2->A2_EST
		Endif                 	
		If !Empty(cGrpTrib)
			dbSelectArea("SF7")
			SF7->(dbSetOrder(1))
			If SF7->(dbSeek(xFilial("SF7")+cB1_GRTRIB+cGrpTrib))
				While !SF7->(Eof()) .And. SF7->F7_FILIAL+SF7->F7_GRTRIB+SF7->F7_GRPCLI == xFilial("SF7")+cB1_GRTRIB+cGrpTrib
					If (cUF == SF7->F7_EST .Or. SF7->F7_EST == "**")
						nExPis	:= Iif(SF7->(FieldPos("F7_ALIQPIS")) > 0,SF7->F7_ALIQPIS,0)
						nExCof	:= Iif(SF7->(FieldPos("F7_ALIQCOF")) > 0,SF7->F7_ALIQCOF,0)
						Exit
					Endif
					SF7->(dbSkip())
				End
			EndIf
		EndIf
	EndIf
    
	If (cAliasSF4)->F4_AGREG <> "N"
		If SB1->(FieldPos("B1_PPIS")) >0
			nTxPIS	:= 	Iif((cAliasSB1)->B1_PPIS <> 0,(cAliasSB1)->B1_PPIS , GetMv("MV_TXPIS"))    
		Endif
		If SB1->(FieldPos("B1_REDPIS")) > 0
			nRedPIS	:= 	Iif((cAliasSB1)->B1_REDPIS > 0,1-((cAliasSB1)->B1_REDPIS / 100 ), 1 )
		Endif
		If SB1->(FieldPos("B1_VLR_PIS")) >0    // Valor de Pauta PIS
			nPautaPIS	:= 	Iif((cAliasSD1)->D1_TIPO$"C",0,(cAliasSB1)->B1_VLR_PIS)
		Endif	
		If SF4->(FieldPos("F4_BASEPIS")) > 0
			nRedPIS	*= 	Iif((cAliasSF4)->F4_BASEPIS > 0,1-((cAliasSF4)->F4_BASEPIS / 100 ), 1 )
		Endif		
		If SB1->(FieldPos("B1_REDCOF")) > 0
			nRedCOF	:= 	Iif((cAliasSB1)->B1_REDCOF > 0,1-((cAliasSB1)->B1_REDCOF / 100 ), 1 )
		Endif
		If SF4->(FieldPos("F4_BASECOF")) > 0
			nRedCOF	*= 	Iif((cAliasSF4)->F4_BASECOF > 0,1-((cAliasSF4)->F4_BASECOF / 100 ), 1 )
		EndIf
		If SB1->(FieldPos("B1_PCOFINS")) > 0
			nTxCOF	:=	if((cAliasSB1)->B1_PCOFINS <> 0,(cAliasSB1)->B1_PCOFINS , GetMv("MV_TXCOFIN"))
		Endif
		If SB1->(FieldPos("B1_VLR_COF")) >0    // Valor de Pauta COFINS
			nPautaCOF	:= 	Iif((cAliasSD1)->D1_TIPO$"C",0,(cAliasSB1)->B1_VLR_COF)
		Endif	
		If SF4->(FieldPos("F4_PISCOF")) >0
			If !lApurac .Or. ((cAliasSF4)->F4_PISFISC<>"2")
				If (cAliasSF4)->F4_PISCOF $ "13" //1-PIS,3=Ambos
					If SF4->(FieldPos("F4_PISCRED")) >0	
						nValPisPas := 0
						nBasPisPas := 0
						//Verifica se existem os campos para gravacao do valor/base do PIS  
						If (cAliasSD1)->D1_DTDIGIT >= dDtCorte .And. ;
							!Empty( nPsVlPisEn ) .And. !Empty( nPsBsPisEn ) .And. !Empty( nPsAlPisEn )
							nValPisPas	:= ( cAliasSD1 )->( FieldGet( nPsVlPisEn ) )
							nBasPisPas	:= ( cAliasSD1 )->( FieldGet( nPsBsPisEn ) )
							nTxPIS		:= ( cAliasSD1 )->( FieldGet( nPsAlPisEn ) )
						EndIf
						// Tratamento do Majorado
						If (cAliasSD1)->D1_VALPMAJ > 0
							nValPisPas := nValPisPas - (cAliasSD1)->D1_VALPMAJ
							nTxPIS     := nTxPIS - (cAliasSF4)->F4_MALQPIS
						EndIf 
						//PIS e Ambos
						If mv_par01 <> 2 .And. mv_par12 == 3 .And. !(cAliasSF4)->F4_TPREG$"123"
							RecLock("TRB",.T.)
							TRB->NUMNF     := (cAliasSD1)->D1_DOC
							TRB->SERIE     := (cAliasSD1)->D1_SERIE
							TRB->EMISSAO   := (cAliasSD1)->D1_DTDIGIT
							TRB->CFOP      := (cAliasSD1)->D1_CF
							TRB->PRODUTO   	:= ALLTRIM((cAliasSD1)->D1_COD)+' - '+ALLTRIM((cAliasSB1)->B1_DESC)
							TRB->NCM       := (cAliasSB1)->B1_POSIPI
							TRB->VALORCONT := CompVlCont(cAliasSD1,(cAliasSF4)->F4_AGREG,(cAliasSF4)->F4_IPI)
							TRB->ZFRANCA   := 0
							TRB->ALIQ      := Iif(nExPis == 0,Iif(nPautaPIS <> 0,nPautaPIS,nTxPIS),nExPis)
							TRB->TIPO      := "PIS"
							TRB->ES        := "E"
							TRB->CLIFOR	   := cCliFor
							TRB->PAUTA	   := Iif(nPautaPIS <> 0,"S","N")							
							MsUnlock()
							//Verifica a Data de Corte ( 01/02/2004 )                           
							If (cAliasSD1)->D1_DTDIGIT >= dDtCorte
								RecLock("TRB",.F.)
								If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
									TRB->PISCENT   := nValPisPas
									TRB->BASPICENT := nBasPisPas					
								ElseIf (cAliasSF4)->F4_PISCRED =="2"
									TRB->PISDENT   := nValPisPas
									TRB->BASPIDENT := nBasPisPas					
                        Endif
								MsUnlock()
							Else			
								RecLock("TRB",.F.)
								If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
									TRB->PISCENT   := ( ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC) * nRedPis) * (TRB->ALIQ/100)
									TRB->BASPICENT := ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC )  * nRedPis
								ElseIf (cAliasSF4)->F4_PISCRED =="2"
									TRB->PISDENT   := ( ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC) * nRedPis) * (TRB->ALIQ/100)
									TRB->BASPIDENT := ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC  ) * nRedPis
                        Endif
								MsUnlock()
							EndIf				
							//Acumula PIS no Valor Contabil                  
							//Produtos importados devem agregar esses valores
							If SF4->(FieldPos("F4_AGRPIS")) > 0
								If (cAliasSF4)->F4_AGRPIS = "1"
								    RecLock("TRB",.F.)
									If (cAliasSF4)->F4_PISCRED == "1"
								    	TRB->VALORCONT += TRB->PISCENT 
								 	Else                               
								 		TRB->VALORCONT += TRB->PISDENT 
								 	Endif
							    	MsUnlock()
								Endif
							Endif	
						Endif
						//NAO CUMULATIVO/CUMULATIVO/AMBOS
						If mv_par01 <> 2 .And. mv_par12 == 1 .And. (cAliasSF4)->F4_TPREG$"123" 
							RecLock("TRB",.T.)
							TRB->NUMNF     := (cAliasSD1)->D1_DOC
							TRB->SERIE     := (cAliasSD1)->D1_SERIE
							TRB->EMISSAO   := (cAliasSD1)->D1_DTDIGIT
							TRB->CFOP      := (cAliasSD1)->D1_CF
							TRB->PRODUTO   	:= ALLTRIM((cAliasSD1)->D1_COD)+' - '+ALLTRIM((cAliasSB1)->B1_DESC)
							TRB->NCM       := (cAliasSB1)->B1_POSIPI
							TRB->VALORCONT := CompVlCont(cAliasSD1,(cAliasSF4)->F4_AGREG,(cAliasSF4)->F4_IPI)
							TRB->ZFRANCA   := 0
							TRB->ALIQ      := Iif(nExPis == 0,Iif(nPautaPIS <> 0,nPautaPIS,nTxPIS),nExPis)
							TRB->TIPO      := "PIS"
							TRB->ES        := "E"
							TRB->CLIFOR	   := cCliFor
							TRB->PAUTA	   := Iif(nPautaPIS <> 0,"S","N")							
							MsUnlock()
							//Verifica a Data de Corte ( 01/02/2004 )                           
							If (cAliasSD1)->D1_DTDIGIT >= dDtCorte
								RecLock("TRB",.F.)
								If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
									TRB->PISCENT   := nValPisPas
									TRB->BASPICENT := nBasPisPas					
								ElseIf (cAliasSF4)->F4_PISCRED =="2"
									TRB->PISDENT   := nValPisPas
									TRB->BASPIDENT := nBasPisPas					
                        Endif
								MsUnlock()
							Else			
								RecLock("TRB",.F.)
								If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
									TRB->PISCENT   := ( ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC) * nRedPis) * (TRB->ALIQ/100)
									TRB->BASPICENT := ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC )  * nRedPis
								ElseIf (cAliasSF4)->F4_PISCRED =="2"
									TRB->PISDENT   := ( ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC) * nRedPis) * (TRB->ALIQ/100)
									TRB->BASPIDENT := ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC  ) * nRedPis
                        Endif
								MsUnlock()
							EndIf				
							//Acumula PIS no Valor Contabil                  
							//Produtos importados devem agregar esses valores
							If SF4->(FieldPos("F4_AGRPIS")) > 0
								If (cAliasSF4)->F4_AGRPIS = "1"
									RecLock("TRB",.F.)
									If (cAliasSF4)->F4_PISCRED == "1"
								    	TRB->VALORCONT += TRB->PISCENT 
								 	Else                               
								 		TRB->VALORCONT += TRB->PISDENT 
								 	Endif
							    	MsUnlock()
								Endif
							Endif	
						Endif
						//NAO CUMULATIVO/CUMULATIVO/AMBOS
						If mv_par01 <> 2 .And. mv_par12 == 2 .And. (cAliasSF4)->F4_TPREG$"1" 
							RecLock("TRB",.T.)
							TRB->NUMNF     := (cAliasSD1)->D1_DOC
							TRB->SERIE     := (cAliasSD1)->D1_SERIE
							TRB->EMISSAO   := (cAliasSD1)->D1_DTDIGIT
							TRB->CFOP      := (cAliasSD1)->D1_CF
							TRB->PRODUTO   	:= ALLTRIM((cAliasSD1)->D1_COD)+' - '+ALLTRIM((cAliasSB1)->B1_DESC)
							TRB->NCM       := (cAliasSB1)->B1_POSIPI
							TRB->VALORCONT := CompVlCont(cAliasSD1,(cAliasSF4)->F4_AGREG,(cAliasSF4)->F4_IPI)
							TRB->ZFRANCA   := 0
							TRB->ALIQ      := Iif(nExPis == 0,Iif(nPautaPIS <> 0,nPautaPIS,nTxPIS),nExPis)
							TRB->TIPO      := "PIS"
							TRB->ES        := "E"
							TRB->CLIFOR	   := cCliFor
							TRB->PAUTA	   := Iif(nPautaPIS <> 0,"S","N")							
							MsUnlock()
							//Verifica a Data de Corte ( 01/02/2004 )                           
							If (cAliasSD1)->D1_DTDIGIT >= dDtCorte
								RecLock("TRB",.F.)
								If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
									TRB->PISCENT   := nValPisPas
									TRB->BASPICENT := nBasPisPas					
								ElseIf (cAliasSF4)->F4_PISCRED =="2"
									TRB->PISDENT   := nValPisPas
									TRB->BASPIDENT := nBasPisPas					
                        Endif
								MsUnlock()
							Else			
								RecLock("TRB",.F.)
								If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
									TRB->PISCENT   := ( ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC) * nRedPis) * (TRB->ALIQ/100)
									TRB->BASPICENT := ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC )  * nRedPis
								ElseIf (cAliasSF4)->F4_PISCRED =="2"
									TRB->PISDENT   := ( ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC) * nRedPis) * (TRB->ALIQ/100)
									TRB->BASPIDENT := ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC  ) * nRedPis
                        Endif
								MsUnlock()
							EndIf				
							//Acumula PIS no Valor Contabil                  
							//Produtos importados devem agregar esses valores
							If SF4->(FieldPos("F4_AGRPIS")) > 0
								If (cAliasSF4)->F4_AGRPIS = "1"
								    RecLock("TRB",.F.)
									If (cAliasSF4)->F4_PISCRED == "1"
								    	TRB->VALORCONT += TRB->PISCENT 
								 	Else                               
								 		TRB->VALORCONT += TRB->PISDENT 
								 	Endif
							    	MsUnlock()
								Endif
							Endif	
						Endif					
					EndIf
				Endif
				//COFINS-Ambos
				If (cAliasSF4)->F4_PISCOF $ "23" .And. mv_par01 <> 1 .And. mv_par12 == 3 .And. !(cAliasSF4)->F4_TPREG$"123"
					If SF4->(FieldPos("F4_PISCRED")) >0
						nValCofins := 0 
						nBasCofins := 0 					
						//Verifica se existem os campos para gravacao do valor/base da COFINS 
						If (cAliasSD1)->D1_DTDIGIT >= dDtCorte .And. ;
							!Empty( nPsVlCofEn ) .And. !Empty( nPsBsCofEn ) .And. !Empty( nPsAlCofEn )
							nValCofins	:= ( cAliasSD1 )->( FieldGet( nPsVlCofEn ) )
							nBasCofins	:= ( cAliasSD1 )->( FieldGet( nPsBsCofEn ) )
							nTxCOF		:= ( cAliasSD1 )->( FieldGet( nPsAlCofEn ) )
							//TRATAMENTO COFINS MAJORADA.
							IF	SF4->(FieldPos("F4_MALQPIS") > 0)
								nTxPIS := nTxPIS - (cAliasSF4)->F4_MALQPIS
							EndIF
							If SF4->(FieldPos("F4_MALQCOF") > 0) .And. SD1->(FieldPos("D1_VALCMAJ") > 0)
							    If (cAliasSF4)->F4_MALQCOF > 0
							    	nTxCOF := nTxCOF - (cAliasSF4)->F4_MALQCOF
							    EndIf
							    If (cAliasSD1)->D1_VALCMAJ > 0
							    	nValCofins := nValCofins - (cAliasSD1)->D1_VALCMAJ
							    EndIf 	
							EndIf  
						EndIf						
						RecLock("TRB",.T.)
						TRB->NUMNF     := (cAliasSD1)->D1_DOC
						TRB->SERIE     := (cAliasSD1)->D1_SERIE   
						TRB->EMISSAO   := (cAliasSD1)->D1_DTDIGIT
						TRB->CFOP      := (cAliasSD1)->D1_CF
						TRB->PRODUTO   	:= ALLTRIM((cAliasSD1)->D1_COD)+' - '+ALLTRIM((cAliasSB1)->B1_DESC)
						TRB->NCM       := (cAliasSB1)->B1_POSIPI
						TRB->VALORCONT := CompVlCont(cAliasSD1,(cAliasSF4)->F4_AGREG,(cAliasSF4)->F4_IPI)
						TRB->ZFRANCA   := 0
						TRB->ALIQ      := Iif(nExCof == 0,Iif(nPautaCOF <> 0,nPautaCOF,nTxCOF),nExCof)
						TRB->TIPO      := "COF"
						TRB->ES        := "E"        
						TRB->CLIFOR    := cCliFor 
						TRB->PAUTA	   := Iif(nPautaCOF <> 0,"S","N")
						MsUnlock()
						//Verifica a Data de Corte ( 01/02/2004 )                           
						If (cAliasSD1)->D1_DTDIGIT >= dDtCorte
							RecLock("TRB",.F.)
							If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
								TRB->COFCENT   := nValCofins
								TRB->BASCOCENT := nBasCofins
							ElseIf (cAliasSF4)->F4_PISCRED =="2"
								TRB->COFDENT   := nValCofins
								TRB->BASCODENT := nBasCofins 
                    Endif
                    MsUnlock()
						Else
							RecLock("TRB",.F.)
							If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita ;2-Debita
								TRB->COFCENT   := ( ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC )  * nRedCOF) * (TRB->ALIQ/100)
								TRB->BASCOCENT := ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC  ) * nRedCOF
							ElseIf	(cAliasSF4)->F4_PISCRED =="2"
								TRB->COFDENT   := ( ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC )  * nRedCOF) * (TRB->ALIQ/100)
								TRB->BASCODENT := ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC  ) * nRedCOF
							Endif	
							MsUnlock()
						Endif
						//Acumula COFINS no Valor Contabil               
						//Produtos importados devem agregar esses valores
						If SF4->(FieldPos("F4_AGRCOF")) > 0
							If (cAliasSF4)->F4_AGRCOF = "1"
							    RecLock("TRB",.F.)
							    If (cAliasSF4)->F4_PISCRED == "1"
									 TRB->VALORCONT += TRB->COFCENT
							    Else                              
							    	 TRB->VALORCONT += TRB->COFDENT
							    Endif
						    	 MsUnlock()
							Endif
						Endif	
					Endif	
				Endif
				//NAO CUMULATIVO/CUMULATIVO/AMBOS							
				If (cAliasSF4)->F4_PISCOF $ "23" .And. mv_par01 <> 1 .And. mv_par12 == 1 .And. (cAliasSF4)->F4_TPREG$"123" 
					If SF4->(FieldPos("F4_PISCRED")) >0
						nValCofins := 0 
						nBasCofins := 0 					
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se existem os campos para gravacao do valor/base da COFINS ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If (cAliasSD1)->D1_DTDIGIT >= dDtCorte .And. ;
							!Empty( nPsVlCofEn ) .And. !Empty( nPsBsCofEn ) .And. !Empty( nPsAlCofEn )
							nValCofins := ( cAliasSD1 )->( FieldGet( nPsVlCofEn ) )
							nBasCofins := ( cAliasSD1 )->( FieldGet( nPsBsCofEn ) )
							nTxCOF := ( cAliasSD1 )->( FieldGet( nPsAlCofEn ) )
							//TRATAMENTO COFINS MAJORADA.
							IF	SF4->(FieldPos("F4_MALQPIS") > 0)
								nTxPIS := nTxPIS - (cAliasSF4)->F4_MALQPIS
							EndIF
							If SF4->(FieldPos("F4_MALQCOF") > 0) .And. SD1->(FieldPos("D1_VALCMAJ") > 0)
							    If (cAliasSF4)->F4_MALQCOF > 0
							    	nTxCOF := nTxCOF - (cAliasSF4)->F4_MALQCOF
							    EndIf
							    If (cAliasSD1)->D1_VALCMAJ > 0
							    	nValCofins := nValCofins - (cAliasSD1)->D1_VALCMAJ
							    EndIf 	
							EndIf  
						EndIf	
					
						RecLock("TRB",.T.)
						TRB->NUMNF     := (cAliasSD1)->D1_DOC
						TRB->SERIE     := (cAliasSD1)->D1_SERIE   
						TRB->EMISSAO   := (cAliasSD1)->D1_DTDIGIT
						TRB->CFOP      := (cAliasSD1)->D1_CF
						TRB->PRODUTO   	:= ALLTRIM((cAliasSD1)->D1_COD)+' - '+ALLTRIM((cAliasSB1)->B1_DESC)
						TRB->NCM       := (cAliasSB1)->B1_POSIPI
						TRB->VALORCONT := CompVlCont(cAliasSD1,(cAliasSF4)->F4_AGREG,(cAliasSF4)->F4_IPI)
						TRB->ZFRANCA   := 0
						TRB->ALIQ      := Iif(nExCof == 0,Iif(nPautaCOF <> 0,nPautaCOF,nTxCOF),nExCof)
						TRB->TIPO      := "COF"
						TRB->ES        := "E"        
						TRB->CLIFOR    := cCliFor 
						TRB->PAUTA	   := Iif(nPautaCOF <> 0,"S","N")
						MsUnlock()
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica a Data de Corte ( 01/02/2004 )                           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If (cAliasSD1)->D1_DTDIGIT >= dDtCorte
							RecLock("TRB",.F.)
							If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
								TRB->COFCENT   := nValCofins
								TRB->BASCOCENT := nBasCofins
							ElseIf (cAliasSF4)->F4_PISCRED =="2"
								TRB->COFDENT   := nValCofins
								TRB->BASCODENT := nBasCofins 
                     Endif
                     MsUnlock()
						Else
							RecLock("TRB",.F.)
							If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita ;2-Debita
								TRB->COFCENT   := ( ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC )  * nRedCOF) * (TRB->ALIQ/100)
								TRB->BASCOCENT := ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC  ) * nRedCOF
							ElseIf (cAliasSF4)->F4_PISCRED =="2"
								TRB->COFDENT   := ( ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC )  * nRedCOF) * (TRB->ALIQ/100)
								TRB->BASCODENT := ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC  ) * nRedCOF
							Endif	
							MsUnlock()
						Endif
						//Acumula COFINS no Valor Contabil               
						//Produtos importados devem agregar esses valores
						If SF4->(FieldPos("F4_AGRCOF")) > 0
							If (cAliasSF4)->F4_AGRCOF = "1"
							    RecLock("TRB",.F.)
							    If (cAliasSF4)->F4_PISCRED == "1"
								    	TRB->VALORCONT += TRB->COFCENT
							    Else                              
								    	TRB->VALORCONT += TRB->COFDENT
							    Endif
						    	MsUnlock()
							Endif
						Endif	
					Endif	
				Endif			
				//NAO CUMULATIVO/CUMULATIVO/AMBOS
				If (cAliasSF4)->F4_PISCOF $ "23" .And. mv_par01 <> 1 .And. mv_par12 == 2 .And. (cAliasSF4)->F4_TPREG$"1" 
					If SF4->(FieldPos("F4_PISCRED")) >0
						nValCofins := 0 
						nBasCofins := 0 					
						//Verifica se existem os campos para gravacao do valor/base da COFINS 
						If (cAliasSD1)->D1_DTDIGIT >= dDtCorte .And. ;
							!Empty( nPsVlCofEn ) .And. !Empty( nPsBsCofEn ) .And. !Empty( nPsAlCofEn )
							nValCofins	:= ( cAliasSD1 )->( FieldGet( nPsVlCofEn ) )
							nBasCofins	:= ( cAliasSD1 )->( FieldGet( nPsBsCofEn ) )
							nTxCOF		:= ( cAliasSD1 )->( FieldGet( nPsAlCofEn ) )
							//TRATAMENTO COFINS MAJORADA.
							IF	SF4->(FieldPos("F4_MALQPIS") > 0)
								nTxPIS := nTxPIS - (cAliasSF4)->F4_MALQPIS
							EndIF
							If SF4->(FieldPos("F4_MALQCOF") > 0) .And. SD1->(FieldPos("D1_VALCMAJ") > 0)
							    If (cAliasSF4)->F4_MALQCOF > 0
							    	nTxCOF := nTxCOF - (cAliasSF4)->F4_MALQCOF
							    EndIf
							    If (cAliasSD1)->D1_VALCMAJ > 0
							    	nValCofins := nValCofins - (cAliasSD1)->D1_VALCMAJ
							    EndIf 	
							EndIf  
						EndIf						
						RecLock("TRB",.T.)
						TRB->NUMNF     := (cAliasSD1)->D1_DOC
						TRB->SERIE     := (cAliasSD1)->D1_SERIE   
						TRB->EMISSAO   := (cAliasSD1)->D1_DTDIGIT
						TRB->CFOP      := (cAliasSD1)->D1_CF
						TRB->PRODUTO   	:= ALLTRIM((cAliasSD1)->D1_COD)+' - '+ALLTRIM((cAliasSB1)->B1_DESC)
						TRB->NCM       := (cAliasSB1)->B1_POSIPI
						TRB->VALORCONT := CompVlCont(cAliasSD1,(cAliasSF4)->F4_AGREG,(cAliasSF4)->F4_IPI)
 						TRB->ZFRANCA   := 0
						TRB->ALIQ      := Iif(nExCof == 0,Iif(nPautaCOF <> 0,nPautaCOF,nTxCOF),nExCof)
						TRB->TIPO      := "COF"
						TRB->ES        := "E"        
						TRB->CLIFOR    := cCliFor 
						TRB->PAUTA	   := Iif(nPautaCOF <> 0,"S","N")
						MsUnlock()
						//Verifica a Data de Corte ( 01/02/2004 )                           
						If (cAliasSD1)->D1_DTDIGIT >= dDtCorte
							RecLock("TRB",.F.)
							If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
								TRB->COFCENT   := nValCofins
								TRB->BASCOCENT := nBasCofins
							ElseIf (cAliasSF4)->F4_PISCRED =="2"
								TRB->COFDENT   := nValCofins
								TRB->BASCODENT := nBasCofins 
                    Endif
                    MsUnlock()
						Else
							RecLock("TRB",.F.)
							If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita ;2-Debita
								TRB->COFCENT   := ( ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC )  * nRedCOF) * (TRB->ALIQ/100)
								TRB->BASCOCENT := ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC  ) * nRedCOF
							ElseIf	(cAliasSF4)->F4_PISCRED =="2"
								TRB->COFDENT   := ( ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC )  * nRedCOF) * (TRB->ALIQ/100)
								TRB->BASCODENT := ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC  ) * nRedCOF
							Endif	
							MsUnlock()
						Endif
						//Acumula COFINS no Valor Contabil               
						//Produtos importados devem agregar esses valores
						If SF4->(FieldPos("F4_AGRCOF")) > 0
							If (cAliasSF4)->F4_AGRCOF = "1"
							    RecLock("TRB",.F.)
							    If (cAliasSF4)->F4_PISCRED == "1"
							    	 TRB->VALORCONT += TRB->COFCENT
							    Else                              
							    	 TRB->VALORCONT += TRB->COFDENT
							    Endif
						    	MsUnlock()
							Endif
						Endif	
					Endif	
				Endif
				//Gera as informacoes para o Resumo -  Entrada 				
				If mv_par12 == 3 .And. !((cAliasSF4)->F4_TPREG$"123") .And. !(cAliasSF4)->F4_TPREG$"123"//NAO CUMULATIVO/CUMULATIVO/AMBOS		
					If (cAliasSF4)->F4_PISCOF $ "123" //1-PIS;2-COFINS;3-Ambos				 
						If !(cAliasSD1)->D1_TIPO $ "BD"                                
							If (cAliasSF4)->F4_PISCOF == "1"
						 		aResumo[3][2] += ((cAliasSD1)->D1_TOTAL + IIf(cDebSTPIS=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
						 	EndIf
							If (cAliasSF4)->F4_PISCOF == "2"
						 		aResumo[3][2] += ((cAliasSD1)->D1_TOTAL + IIf(cDebSTCOF=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
						 	EndIf
							If (cAliasSF4)->F4_PISCOF == "3"
						 		aResumo[3][2] += ((cAliasSD1)->D1_TOTAL + IIf(cDebSTCOF=="6" .And. cDebSTPIS=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
						 	EndIf
						 	//nCompTrib
						EndIf                         
					
						If (cAliasSD1)->D1_TIPO == "D" 
							If (cAliasSF4)->F4_PISCOF == "1"
								aResumo[2][2] += ((cAliasSD1)->D1_TOTAL + IIf(cDebSTPIS=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
							EndIf
							If (cAliasSF4)->F4_PISCOF == "2"
								aResumo[2][2] += ((cAliasSD1)->D1_TOTAL + IIf(cDebSTCOF=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
							EndIf
							If (cAliasSF4)->F4_PISCOF == "3"
								aResumo[2][2] += ((cAliasSD1)->D1_TOTAL + IIf(cDebSTCOF=="6" .And. cDebSTPIS=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
							EndIf
							//nDevVendT
						EndIF									
					ELSE		
						If !(cAliasSD1)->D1_TIPO $ "BD" 
							 aResumo[3][3] += ((cAliasSD1)->D1_TOTAL+(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC
							 //nValComp
						EndIF						
						If (cAliasSD1)->D1_TIPO == "D" 
							aResumo[2][3] += ((cAliasSD1)->D1_TOTAL+(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC
							//nValDevVend
						EndIF		
					EndIf							
				EndIf
				//NAO CUMULATIVO/CUMULATIVO/AMBOS		
				If mv_par12 == 1 .And. (cAliasSF4)->F4_TPREG$"123" 
					If (cAliasSF4)->F4_PISCOF $ "123" //1-PIS;2-COFINS;3-Ambos					 
						If !(cAliasSD1)->D1_TIPO $ "BD"
							If (cAliasSF4)->F4_PISCOF == "1"
						 		aResumo[3][2] += ((cAliasSD1)->D1_TOTAL + IIf(cDebSTPIS=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
						 	EndIf
							If (cAliasSF4)->F4_PISCOF == "2"
						 		aResumo[3][2] += ((cAliasSD1)->D1_TOTAL + IIf(cDebSTCOF=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
						 	EndIf
							If (cAliasSF4)->F4_PISCOF == "3"
						 		aResumo[3][2] += ((cAliasSD1)->D1_TOTAL + IIf(cDebSTCOF=="6" .And. cDebSTPIS=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
						 	EndIf
						 	//nCompTrib
						EndIf                         
							
						If (cAliasSD1)->D1_TIPO == "D" 
							If (cAliasSF4)->F4_PISCOF == "1"
								aResumo[2][2] += ((cAliasSD1)->D1_TOTAL + IIf(cDebSTPIS=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
							EndIf
							If (cAliasSF4)->F4_PISCOF == "2"
								aResumo[2][2] += ((cAliasSD1)->D1_TOTAL + IIf(cDebSTCOF=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
							EndIf							                           
							If (cAliasSF4)->F4_PISCOF == "3"
								aResumo[2][2] += ((cAliasSD1)->D1_TOTAL + IIf(cDebSTCOF=="6" .And. cDebSTPIS=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
							EndIf							                           							
							//nDevVendT
						EndIF										
					ELSE		
						If !(cAliasSD1)->D1_TIPO $ "BD" 
							 aResumo[3][3] += ((cAliasSD1)->D1_TOTAL+(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC
							 //nValComp
						EndIF						
						If (cAliasSD1)->D1_TIPO == "D" 
							aResumo[2][3] += ((cAliasSD1)->D1_TOTAL+(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC
							//nValDevVend
						EndIF		
					EndIf
				EndIf 				
				
				If mv_par12 == 2 .And. (cAliasSF4)->F4_TPREG$"1" //NAO CUMULATIVO/CUMULATIVO/AMBOS		
					If (cAliasSF4)->F4_PISCOF $ "123" //1-PIS;2-COFINS;3-Ambos					 
						If !(cAliasSD1)->D1_TIPO $ "BD"
							If (cAliasSF4)->F4_PISCOF == "1"
						 		aResumo[3][2] += ((cAliasSD1)->D1_TOTAL + IIf(cDebSTPIS=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
						 	EndIf
							If (cAliasSF4)->F4_PISCOF == "2"
						 		aResumo[3][2] += ((cAliasSD1)->D1_TOTAL + IIf(cDebSTCOF=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
						 	EndIf
							If (cAliasSF4)->F4_PISCOF == "3"
						 		aResumo[3][2] += ((cAliasSD1)->D1_TOTAL + IIf(cDebSTPIS=="6" .And. cDebSTCOF=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
						 	EndIf
						 	//nCompTrib
						EndIf                         						
						If (cAliasSD1)->D1_TIPO == "D" 
							If (cAliasSF4)->F4_PISCOF == "1"
								aResumo[2][2] += ((cAliasSD1)->D1_TOTAL + IIf(cDebSTPIS=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
							EndIf
							If (cAliasSF4)->F4_PISCOF == "2"
								aResumo[2][2] += ((cAliasSD1)->D1_TOTAL + IIf(cDebSTCOF=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
							EndIf
							If (cAliasSF4)->F4_PISCOF == "3"
								aResumo[2][2] += ((cAliasSD1)->D1_TOTAL + IIf(cDebSTCOF=="6" .And. cDebSTPIS=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
							EndIf
							//nDevVendT
						EndIF										
					ELSE		
						If !(cAliasSD1)->D1_TIPO $ "BD" 
							 aResumo[3][3] += ((cAliasSD1)->D1_TOTAL+(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC
							 //nValComp
						EndIF						
						If (cAliasSD1)->D1_TIPO == "D" 
							aResumo[2][3] += ((cAliasSD1)->D1_TOTAL+(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC
							//nValDevVend
						EndIF		
					EndIf
				EndIf			
			EndIf
		EndIf
	EndIf
	(cAliasSD1)->( dbSkip())
EndDo

If lQuery
	dbSelectArea(cAliasSD1)
	dbCloseArea()
	dbSelectArea("SD1")
Else
	dbSelectArea("SD1")
	RetIndex("SD1")
	Set Filter to
	Ferase(cIndex1+OrdBagExt())
EndIf   
Return (TRB->(LastRec())>0)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CriaArrTRB³ Autor ³ Mauro A. Goncalves    ³ Data ³ 22/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria array da estrutura da tabela temporaria TRB           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CriaArrTRB()
Private aArqTemp := {}

AADD(aArqTemp,{"NUMNF"		,"C",TamSx3("D2_DOC")[1]		,0})
AADD(aArqTemp,{"SERIE"		,"C",TamSx3("D2_SERIE")[1]		,0})
AADD(aArqTemp,{"EMISSAO"   ,"D",TamSx3("D2_EMISSAO")[1]	,0})
AADD(aArqTemp,{"TIPO"		,"C",03								,0})
AADD(aArqTemp,{"CFOP"	   ,"C",04								,0})
AADD(aArqTemp,{"PRODUTO"	,"C",TamSx3("D2_COD")[1]+TamSx3("B1_DESC")[1],0})
AADD(aArqTemp,{"NCM"			,"C",TamSx3("B1_POSIPI")[1]	,0})
AADD(aArqTemp,{"VALORCONT"	,"N",TamSx3("D2_TOTAL")[1]		,TamSx3("D2_TOTAL")[2]})
AADD(aArqTemp,{"ZFRANCA"	,"N",TamSx3("D2_DESCZFR")[1]	,TamSx3("D2_DESCZFR")[2]})
AADD(aArqTemp,{"ALIQ"		,"N",TamSx3("B1_VLR_COF")[1]	,TamSx3("B1_VLR_COF")[2]})
AADD(aArqTemp,{"PISCSAI"	,"N",TamSx3("D2_TOTAL")[1]		,TamSx3("D2_TOTAL")[2]})
AADD(aArqTemp,{"PISDSAI"	,"N",TamSx3("D2_TOTAL")[1]		,TamSx3("D2_TOTAL")[2]})
AADD(aArqTemp,{"BASPICSAI"	,"N",TamSx3("D2_TOTAL")[1]		,TamSx3("D2_TOTAL")[2]})
AADD(aArqTemp,{"BASPIDSAI"	,"N",TamSx3("D2_TOTAL")[1]		,TamSx3("D2_TOTAL")[2]})
AADD(aArqTemp,{"PISCENT"	,"N",TamSx3("D2_TOTAL")[1]		,TamSx3("D2_TOTAL")[2]})
AADD(aArqTemp,{"PISDENT"	,"N",TamSx3("D2_TOTAL")[1]		,TamSx3("D2_TOTAL")[2]})
AADD(aArqTemp,{"BASPICENT"	,"N",TamSx3("D2_TOTAL")[1]		,TamSx3("D2_TOTAL")[2]})
AADD(aArqTemp,{"BASPIDENT"	,"N",TamSx3("D2_TOTAL")[1]		,TamSx3("D2_TOTAL")[2]})
AADD(aArqTemp,{"COFCSAI"	,"N",TamSx3("D2_TOTAL")[1]		,TamSx3("D2_TOTAL")[2]})
AADD(aArqTemp,{"COFDSAI"	,"N",TamSx3("D2_TOTAL")[1]		,TamSx3("D2_TOTAL")[2]})
AADD(aArqTemp,{"BASCOCSAI"	,"N",TamSx3("D2_TOTAL")[1]		,TamSx3("D2_TOTAL")[2]})
AADD(aArqTemp,{"BASCODSAI"	,"N",TamSx3("D2_TOTAL")[1]		,TamSx3("D2_TOTAL")[2]})
AADD(aArqTemp,{"COFCENT"	,"N",TamSx3("D2_TOTAL")[1]		,TamSx3("D2_TOTAL")[2]})
AADD(aArqTemp,{"COFDENT"	,"N",TamSx3("D2_TOTAL")[1]		,TamSx3("D2_TOTAL")[2]})
AADD(aArqTemp,{"BASCOCENT"	,"N",TamSx3("D2_TOTAL")[1]		,TamSx3("D2_TOTAL")[2]})
AADD(aArqTemp,{"BASCODENT"	,"N",TamSx3("D2_TOTAL")[1]		,TamSx3("D2_TOTAL")[2]})
AADD(aArqTemp,{"ES"			,"C",01								,0})
AADD(aArqTemp,{"CLIFOR"		,"C",40								,0})
AADD(aArqTemp,{"PAUTA"		,"C",01								,0})
AADD(aArqTemp,{"DESC_PROD"	,"C",TamSx3("D2_COD")[1]		,0})
Return aArqTemp
          
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CriaArrRes³ Autor ³ Mauro A. Goncalves    ³ Data ³ 22/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria array do total do resumo							           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CriaArrRes()
Private aTotResumo := {}

AADD(aTotResumo,{STR0120,0,0}) //"Saidas"
AADD(aTotResumo,{STR0089,0,0}) //"Devoluções de Saidas"
AADD(aTotResumo,{STR0119,0,0}) //"Entradas"
AADD(aTotResumo,{STR0090,0,0}) //"Devoluções de Entradas"
Return aTotResumo

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TrataCpos ³ Autor ³ Mauro A. Goncalves    ³ Data ³ 22/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Trata os campos de PIS/COF 							           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TrataCpos()
//Tratamento para os campos do PIS - Entrada                        
If !Empty( nScanPis := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_BASEPS2"} ) )
	cCpBsPisEn := aRelImp[nScanPis,2]
	nPsBsPisEn := SD1->(FieldPos(cCpBsPisEn))
EndIf
If !Empty( nScanPis := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_VALPS2"} ) )
	cCpVlPisEn := aRelImp[nScanPis,2]
	nPsVlPisEn := SD1->(FieldPos(cCpVlPisEn))
EndIf
If !Empty( nScanPis := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_ALIQPS2"} ) )
	cCpAlPisEn := aRelImp[nScanPis,2]
	nPsAlPisEn := SD1->(FieldPos(cCpAlPisEn))
EndIf
//Tratamento para os campos do PIS - Saida                          
If !Empty( nScanPis := aScan(aRelImp2,{|x| x[1]=="SD2" .And. x[3]=="IT_BASEPS2"} ) )
	cCpBsPisSa := aRelImp2[nScanPis,2]
	nPsBsPisSa := SD2->(FieldPos(cCpBsPisSa))
EndIf
If !Empty( nScanPis := aScan(aRelImp2,{|x| x[1]=="SD2" .And. x[3]=="IT_VALPS2"} ) )
	cCpVlPisSa := aRelImp2[nScanPis,2]
	nPsVlPisSa := SD2->(FieldPos(cCpVlPisSa))
EndIf 	
If !Empty( nScanPis := aScan(aRelImp2,{|x| x[1]=="SD2" .And. x[3]=="IT_ALIQPS2"} ) )
	cCpAlPisSa := aRelImp2[nScanPis,2]
	nPsAlPisSa := SD2->(FieldPos(cCpAlPisSa))
EndIf 	
//Tratamento para os campos do COF - Entrada                        
If !Empty( nScanCof := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_BASECF2"} ) )
	cCpBsCofEn := aRelImp[nScanCof,2]
	nPsBsCofEn := SD1->(FieldPos(cCpBsCofEn))
EndIf 	
If !Empty( nScanCof := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_VALCF2"} ) )
	cCpVlCofEn := aRelImp[nScanCof,2]
	nPsVlCofEn := SD1->(FieldPos(cCpVlCofEn))
EndIf 	
If !Empty( nScanCof := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_ALIQCF2"} ) )
	cCpAlCofEn := aRelImp[nScanCof,2]
	nPsAlCofEn := SD1->(FieldPos(cCpAlCofEn))
EndIf 	
//Tratamento para os campos do COF - Saida                          
If !Empty( nScanCof := aScan(aRelImp2,{|x| x[1]=="SD2" .And. x[3]=="IT_BASECF2"} ) )
	cCpBsCofSa := aRelImp2[nScanCof,2]
	nPsBsCofSa := SD2->(FieldPos(cCpBsCofSa))
EndIf 	
If !Empty( nScanCof := aScan(aRelImp2,{|x| x[1]=="SD2" .And. x[3]=="IT_VALCF2"} ) )
	cCpVlCofSa := aRelImp2[nScanCof,2]
	nPsVlCofSa := SD2->(FieldPos(cCpVlCofSa))
EndIf 	
If !Empty( nScanCof := aScan(aRelImp2,{|x| x[1]=="SD2" .And. x[3]=="IT_ALIQCF2"} ) )
	cCpAlCofSa := aRelImp2[nScanCof,2]
	nPsAlCofSa := SD2->(FieldPos(cCpAlCofSa))
EndIf
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M906TotRel³ Autor ³ Mauro A. Goncalves    ³ Data ³ 22/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Alimenta os arrays para os totais					           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M906TotRel(aAliqCFGer,aAliqEs,aCFOPPISE,aCFOPPISS,aCFOPCOFE,aCFOPCOFS,aTAlPISE,aTAlPISS,aTAlCOFE,aTAlCOFS,aTotDoCFOP,aTotDtEmis)
Local nAliq		:= 0
Local nPos		:= 0         
Local cCFOP		:= ""
Local dDtEmis	:= CtoD("  /  /    ")

//Total por Data              
dDtEmis	:= TRB->EMISSAO
nPos		:= Ascan(aTotDtEmis,{|x| x[1]==dDtEmis})
If nPos > 0
	aTotDtEmis[nPos][2]  += TRB->VALORCONT 
	aTotDtEmis[nPos][3]  += TRB->ZFRANCA   
	aTotDtEmis[nPos][4]  += IIF(TRB->TIPO == "PIS" , IIF(TRB->ES == "E",TRB->PISDENT,TRB->PISDSAI) , IIF(TRB->ES == "E",TRB->COFDENT,TRB->COFDSAI)) //contribuicao debito
	aTotDtEmis[nPos][5]  += IIF(TRB->TIPO == "PIS" , IIF(TRB->ES == "E",TRB->PISCENT,TRB->PISCSAI) , IIF(TRB->ES == "E",TRB->COFCENT,TRB->COFCSAI)) //contribuicao credito
	aTotDtEmis[nPos][6]  += IIF(TRB->TIPO == "PIS" , IIF(TRB->ES == "E",TRB->BASPIDENT,TRB->BASPIDSAI) , IIF(TRB->ES == "E",TRB->BASCODENT,TRB->BASCODSAI)) //base debito
	aTotDtEmis[nPos][7]  += IIF(TRB->TIPO == "PIS" , IIF(TRB->ES == "E",TRB->BASPICENT,TRB->BASPICSAI) , IIF(TRB->ES == "E",TRB->BASCOCENT,TRB->BASCOCSAI)) //base credito
Else
	If TRB->TIPO == "PIS"
		AADD(aTotDtEmis,{TRB->EMISSAO,TRB->VALORCONT,TRB->ZFRANCA,IIF(TRB->ES=="E",TRB->PISDENT,TRB->PISDSAI),IIF(TRB->ES=="E",TRB->PISCENT,TRB->PISCSAI),IIF(TRB->ES=="E",TRB->BASPIDENT,TRB->BASPIDSAI),IIF(TRB->ES=="E",TRB->BASPICENT,TRB->BASPICSAI)})
	Else
		AADD(aTotDtEmis,{TRB->EMISSAO,TRB->VALORCONT,TRB->ZFRANCA,IIF(TRB->ES=="E",TRB->COFDENT,TRB->COFDSAI),IIF(TRB->ES=="E",TRB->COFCENT,TRB->COFCSAI),IIF(TRB->ES=="E",TRB->BASCODENT,TRB->BASCODSAI),IIF(TRB->ES=="E",TRB->BASCOCENT,TRB->BASCOCSAI)})
	EndIf
Endif
//Total por aliquota para impressao do resumo de contribuicao      
nAliq	:= Iif(TRB->PAUTA=="S",0,TRB->ALIQ)
nPos  := Ascan(aAliqCFGer,{|x| x[1]==nAliq .And. x[2]==TRB->CFOP})
If nPos > 0
	aAliqCFGer[nPos][3]  += IIF(TRB->TIPO == "PIS" , IIF(TRB->ES == "E",TRB->PISDENT,TRB->PISDSAI)-IIF(TRB->ES == "E",TRB->PISCENT,TRB->PISCSAI) , IIF(TRB->ES == "E",TRB->COFDENT,TRB->COFDSAI)-IIF(TRB->ES == "E",TRB->COFCENT,TRB->COFCSAI))
	aAliqCFGer[nPos][4]  += (TRB->VALORCONT * IIF(TRB->ES=="E",-1,1)) //valor contabil
	aAliqCFGer[nPos][5]  += TRB->ZFRANCA 																																						//Desconto Zona Franca
	aAliqCFGer[nPos][6]  += IIF(TRB->TIPO == "PIS" , IIF(TRB->ES == "E",TRB->PISDENT,TRB->PISDSAI) , IIF(TRB->ES == "E",TRB->COFDENT,TRB->COFDSAI)) //contribuicao debito
	aAliqCFGer[nPos][7]  += IIF(TRB->TIPO == "PIS" , IIF(TRB->ES == "E",TRB->PISCENT,TRB->PISCSAI) , IIF(TRB->ES == "E",TRB->COFCENT,TRB->COFCSAI)) //contribuicao credito
	aAliqCFGer[nPos][8]  += IIF(TRB->TIPO == "PIS" , IIF(TRB->ES == "E",TRB->BASPIDENT,TRB->BASPIDSAI) , IIF(TRB->ES == "E",TRB->BASCODENT,TRB->BASCODSAI)) //base debito
	aAliqCFGer[nPos][9]  += IIF(TRB->TIPO == "PIS" , IIF(TRB->ES == "E",TRB->BASPICENT,TRB->BASPICSAI) , IIF(TRB->ES == "E",TRB->BASCOCENT,TRB->BASCOCSAI)) //base credito
Else
	If TRB->TIPO == "PIS"
		AADD(aAliqCFGer,{Iif(TRB->PAUTA=="S",0,TRB->ALIQ),TRB->CFOP,IIF(TRB->ES=="E",TRB->PISDENT,TRB->PISDSAI)-IIF(TRB->ES=="E",TRB->PISCENT,TRB->PISCSAI),TRB->VALORCONT*IIF(TRB->ES=="E",-1,1),TRB->ZFRANCA,IIF(TRB->ES == "E",TRB->PISDENT,TRB->PISDSAI),IIF(TRB->ES == "E",TRB->PISCENT,TRB->PISCSAI),IIF(TRB->ES == "E",TRB->BASPIDENT,TRB->BASPIDSAI),IIF(TRB->ES == "E",TRB->BASPICENT,TRB->BASPICSAI)})
	Else
		AADD(aAliqCFGer,{Iif(TRB->PAUTA=="S",0,TRB->ALIQ),TRB->CFOP,IIF(TRB->ES=="E",TRB->COFDENT,TRB->COFDSAI)-IIF(TRB->ES=="E",TRB->COFCENT,TRB->COFCSAI),TRB->VALORCONT*IIF(TRB->ES=="E",-1,1),TRB->ZFRANCA,IIF(TRB->ES == "E",TRB->COFDENT,TRB->COFDSAI),IIF(TRB->ES == "E",TRB->COFCENT,TRB->COFCSAI),IIF(TRB->ES == "E",TRB->BASCODENT,TRB->BASCODSAI),IIF(TRB->ES == "E",TRB->BASCOCENT,TRB->BASCOCSAI)})
	EndIf
Endif						
//Acumula a contribuicao por aliquota para impressao do resumo na quebra de entrada/saida  
nAliq	:= Iif(TRB->PAUTA=="S",0,TRB->ALIQ)
nPos 	:= Ascan(aAliqEs,{|x| x[1]==nAliq})
If nPos > 0
	aAliqEs[nPos][2]  += TRB->VALORCONT 
	aAliqEs[nPos][3]  += TRB->ZFRANCA   
	aAliqEs[nPos][4]  += IIF(TRB->TIPO == "PIS" , IIF(TRB->ES == "E",TRB->PISDENT,TRB->PISDSAI) , IIF(TRB->ES == "E",TRB->COFDENT,TRB->COFDSAI)) //contribuicao debito
	aAliqEs[nPos][5]  += IIF(TRB->TIPO == "PIS" , IIF(TRB->ES == "E",TRB->PISCENT,TRB->PISCSAI) , IIF(TRB->ES == "E",TRB->COFCENT,TRB->COFCSAI)) //contribuicao credito
	aAliqEs[nPos][6]  += IIF(TRB->TIPO == "PIS" , IIF(TRB->ES == "E",TRB->BASPIDENT,TRB->BASPIDSAI) , IIF(TRB->ES == "E",TRB->BASCODENT,TRB->BASCODSAI)) //base debito
	aAliqEs[nPos][7]  += IIF(TRB->TIPO == "PIS" , IIF(TRB->ES == "E",TRB->BASPICENT,TRB->BASPICSAI) , IIF(TRB->ES == "E",TRB->BASCOCENT,TRB->BASCOCSAI)) //base credito
Else
	If TRB->TIPO == "PIS"
		AADD(aAliqEs,{Iif(TRB->PAUTA=="	S",0,TRB->ALIQ),TRB->VALORCONT,TRB->ZFRANCA,IIF(TRB->ES == "E",TRB->PISDENT,TRB->PISDSAI),IIF(TRB->ES == "E",TRB->PISCENT,TRB->PISCSAI),IIF(TRB->ES == "E",TRB->BASPIDENT,TRB->BASPIDSAI),IIF(TRB->ES == "E",TRB->BASPICENT,TRB->BASPICSAI)})
	Else
		AADD(aAliqEs,{Iif(TRB->PAUTA=="S",0,TRB->ALIQ),TRB->VALORCONT,TRB->ZFRANCA,IIF(TRB->ES == "E",TRB->COFDENT,TRB->COFDSAI),IIF(TRB->ES == "E",TRB->COFCENT,TRB->COFCSAI),IIF(TRB->ES == "E",TRB->BASCODENT,TRB->BASCODSAI),IIF(TRB->ES == "E",TRB->BASCOCENT,TRB->BASCOCSAI)})
	EndIf
Endif
//Acumula a contribuicao por CFOP  
cCFOP	:= TRB->CFOP
nPos 	:= Ascan(aTotDoCFOP,{|x| x[1]==cCFOP})
If nPos > 0
	aTotDoCFOP[nPos][2]  += TRB->VALORCONT 
	aTotDoCFOP[nPos][3]  += TRB->ZFRANCA   
	aTotDoCFOP[nPos][4]  += IIF(TRB->TIPO == "PIS" , IIF(TRB->ES == "E",TRB->PISDENT,TRB->PISDSAI) , IIF(TRB->ES == "E",TRB->COFDENT,TRB->COFDSAI)) //contribuicao debito
	aTotDoCFOP[nPos][5]  += IIF(TRB->TIPO == "PIS" , IIF(TRB->ES == "E",TRB->PISCENT,TRB->PISCSAI) , IIF(TRB->ES == "E",TRB->COFCENT,TRB->COFCSAI)) //contribuicao credito
	aTotDoCFOP[nPos][6]  += IIF(TRB->TIPO == "PIS" , IIF(TRB->ES == "E",TRB->BASPIDENT,TRB->BASPIDSAI) , IIF(TRB->ES == "E",TRB->BASCODENT,TRB->BASCODSAI)) //base debito
	aTotDoCFOP[nPos][7]  += IIF(TRB->TIPO == "PIS" , IIF(TRB->ES == "E",TRB->BASPICENT,TRB->BASPICSAI) , IIF(TRB->ES == "E",TRB->BASCOCENT,TRB->BASCOCSAI)) //base credito
Else
	If TRB->TIPO == "PIS"
		AADD(aTotDoCFOP,{TRB->CFOP,TRB->VALORCONT,TRB->ZFRANCA,IIF(TRB->ES=="E",TRB->PISDENT,TRB->PISDSAI),IIF(TRB->ES=="E",TRB->PISCENT,TRB->PISCSAI),IIF(TRB->ES=="E",TRB->BASPIDENT,TRB->BASPIDSAI),IIF(TRB->ES=="E",TRB->BASPICENT,TRB->BASPICSAI)})
	Else
		AADD(aTotDoCFOP,{TRB->CFOP,TRB->VALORCONT,TRB->ZFRANCA,IIF(TRB->ES=="E",TRB->COFDENT,TRB->COFDSAI),IIF(TRB->ES=="E",TRB->COFCENT,TRB->COFCSAI),IIF(TRB->ES=="E",TRB->BASCODENT,TRB->BASCODSAI),IIF(TRB->ES=="E",TRB->BASCOCENT,TRB->BASCOCSAI)})
	EndIf
Endif
//Acumula total por CFOP para impressao do resumo por filiais
If mv_par06 == 1
	If TRB->TIPO == "PIS"
		nPos := Ascan(If(TRB->ES=="E",aCFOPPISE,aCFOPPISS),{|x| x[1]==SM0->M0_CODFIL .And. x[2]==TRB->CFOP})
		If nPos > 0
			If TRB->ES=="E"
				aCFOPPISE[nPos][3]  += TRB->BASPIDENT - TRB->BASPICENT
				aCFOPPISE[nPos][4]  += TRB->PISDENT 	- TRB->PISCENT
			Else
				aCFOPPISS[nPos][3]  += TRB->BASPIDSAI - TRB->BASPICSAI
				aCFOPPISS[nPos][4]  += TRB->PISDSAI 	- TRB->PISCSAI
			EndIf
		Else
			If TRB->ES=="E"
				AADD(aCFOPPISE,{SM0->M0_CODFIL,TRB->CFOP,TRB->BASPIDENT - TRB->BASPICENT,TRB->PISDENT - TRB->PISCENT})
			Else
				AADD(aCFOPPISS,{SM0->M0_CODFIL,TRB->CFOP,TRB->BASPIDSAI - TRB->BASPICSAI,TRB->PISDSAI - TRB->PISCSAI})
			EndIf
		EndIf
	Else
		nPos := Ascan(If(TRB->ES=="E",aCFOPCOFE,aCFOPCOFS),{|x| x[1]==SM0->M0_CODFIL .And. x[2]==TRB->CFOP})
		If nPos > 0
			If TRB->ES=="E"
				aCFOPCOFE[nPos][3]  += TRB->BASCODENT - TRB->BASCOCENT
				aCFOPCOFE[nPos][4]  += TRB->COFDENT 	- TRB->COFCENT
			Else
				aCFOPCOFS[nPos][3]  += TRB->BASCODSAI - TRB->BASCOCSAI
				aCFOPCOFS[nPos][4]  += TRB->COFDSAI 	- TRB->COFCSAI
			EndIf
		Else
			If TRB->ES=="E"
				AADD(aCFOPCOFE,{SM0->M0_CODFIL,TRB->CFOP,TRB->BASCODENT - TRB->BASCOCENT,TRB->COFDENT - TRB->COFCENT})
			Else
				AADD(aCFOPCOFS,{SM0->M0_CODFIL,TRB->CFOP,TRB->BASCODSAI - TRB->BASCOCSAI,TRB->COFDSAI - TRB->COFCSAI})
			EndIf
		EndIf
	EndIf
	//Acumula total por Aliquota para impressao do resumo por filiais
	If TRB->TIPO == "PIS"
		nAliq := Iif(TRB->PAUTA=="S",0,TRB->ALIQ)
		nPos  := Ascan(If(TRB->ES=="E",aTAlPISE,aTAlPISS),{|x| x[1]==SM0->M0_CODFIL .And. x[2]==nAliq})
		If nPos > 0
			If TRB->ES=="E"
				aTAlPISE[nPos][3] += TRB->PISDENT-TRB->PISCENT
			Else
				aTAlPISS[nPos][3] += TRB->PISDSAI-TRB->PISCSAI
			EndIf
		Else
			If TRB->ES=="E"
				AADD(aTAlPISE,{SM0->M0_CODFIL,Iif(TRB->PAUTA=="S",0,TRB->ALIQ),TRB->PISDENT-TRB->PISCENT})
			Else
				AADD(aTAlPISS,{SM0->M0_CODFIL,Iif(TRB->PAUTA=="S",0,TRB->ALIQ),TRB->PISDSAI-TRB->PISCSAI})
			EndIf                                                  		
		EndIf
	Else
		nAliq	:= Iif(TRB->PAUTA=="S",0,TRB->ALIQ)
		nPos	:= Ascan(If(TRB->ES=="E",aTAlCOFE,aTAlCOFS),{|x| x[1]==SM0->M0_CODFIL .And. x[2]==nAliq})
		If nPos > 0
			If TRB->ES=="E"
				aTAlCOFE[nPos][3] += TRB->COFDENT-TRB->COFCENT      										
			Else
				aTAlCOFS[nPos][3] += TRB->COFDSAI-TRB->COFCSAI
			EndIf
		Else
			If TRB->ES=="E"
				AADD(aTAlCOFE,{SM0->M0_CODFIL,Iif(TRB->PAUTA=="S",0,TRB->ALIQ),TRB->COFDENT-TRB->COFCENT})
			Else
				AADD(aTAlCOFS,{SM0->M0_CODFIL,Iif(TRB->PAUTA=="S",0,TRB->ALIQ),TRB->COFDSAI-TRB->COFCSAI})
			EndIf
		EndIf                      				
	EndIf
EndIf
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CompVlCont³ Autor ³ Mauro A. Goncalves    ³ Data ³ 22/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Compoe o valor contabil para ser usado em todo relatorio   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Alias D1/D2                                          ³±±
±±³          ³ExpO2: Campo F4_Agreg                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CompVlCont(cAlias,cF4Agreg,cF4Ipi)
Local   nVlCtb		:= 0
Default cF4Agreg	:= ''
Default cF4Ipi  	:= ''

If At("D1",cAlias)>0 //Entradas
	nVlCtb :=	(cAlias)->D1_TOTAL+;
					(cAlias)->D1_ICMSRET+;
					IIF(cF4Ipi$"R",0,(cAlias)->D1_VALIPI)+;  // Validação para tratar " Não Atacadista " F4_IPI = R
					(cAlias)->D1_VALFRE+;
					(cAlias)->D1_SEGURO+;
					(cAlias)->D1_DESPESA+;
					IIf(cF4Agreg$"I/B",(cAlias)->D1_VALICM,0)-;
					(cAlias)->D1_VALDESC
ElseIf At("D2",cAlias)>0 //Saidas
	nVlCtb :=	(cAlias)->D2_VALBRUT
Endif	
Return nVlCtb

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MATR906R3 ³ Autor ³ Nereu Humberto Jr.    ³ Data ³ 17/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio PIS e COFINS (Release 3)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MATR906R3
Local	 cText1   := STR0001 //"Este programa emite Relatorio das Contribuicoes ao PIS e COFINS"
Local	 cString  := "SD2"
Local	 aOrd	  := {STR0036, STR0037, STR0056}
Private	 cTitulo  := STR0002 //"Relatorio - (PIS/COFINS)"
Private	 cPerg    := "MTR906"
Private	 nLastKey := 0
Private  m_pag    := 01
Private  Limite   := 220
Private  cTamanho := "G"
Private  lEnd     := .F.
Private  NomeProg := "MATR906"
Private  aReturn  := { STR0003 , 1, STR0004 , 2, 2, 1, "",1 } //"Zebrado" , "Administracao"

AjustaSX1()
Pergunte(cPerg,.F.)
//Envia controle para a funcao SETPRINT                        
wnrel	:=	"MATR906"   // nome default do relatorio em disco
wnrel	:=	SetPrint(cString,wnrel,cPerg,cTitulo,cText1,,,.F.,aOrd,,cTamanho,,.F.)
If nLastKey==27
   dbClearFilter()
   Return
Endif       
SetDefault(aReturn,cString)
If nLastKey==27
   dbClearFilter()
   Return
Endif       

RptStatus({|lEnd| a906Relat(@lEnd,wnRel,cString,cTamanho)},cTitulo)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A906Relat    ³ Autor ³Edstron E. Correia ³ Data ³ 02/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Selecao e Emissao das Contribuicoes ao PIS e COFINS        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A906Relat(lEnd,WnRel,cString,cTamanho)

Local aStruSD1	  := {}
Local aStruSD2	  := {}
Local aStruSB1 	  := {}
Local aStruSF2	  := {}
Local aStruSF1	  := {}
Local aStruSF4	  := {}
Local aResAliCF	  := {}   // Resumo por Aliquota + CFOP
Local aArqTemp	  := {}
Local aPIS		  := {}
Local aCOFINS	  := {}
Local aRelImp	  := MaFisRelImp("MT100",{ "SD1" })
Local aRelImp2	  := MaFisRelImp("MT100",{ "SD2" })
Local aTotaisPIS  := Array( 8 )
Local aTotaisCOF  := Array( 8 ) 
Local aAliqs	  := {}
Local aDedRet	  := {0,0}
Local aTotSai	  := Array(3)
Local aTotDevS	  := Array(3)
Local aTotEnt	  := Array(3)
Local aTotDevE	  := Array(3)
Local aTotApur	  := Array(2,3)
Local aTAlPISS	  := {}  
Local aTAlCOFS	  := {}  
Local aTAlPISE	  := {}  
Local aTAlCOFE	  := {}  
Local aCFOPPISS	  := {}  
Local aCFOPCOFS   := {}  
Local aCFOPPISE   := {}  
Local aCFOPCOFE   := {}        
Local aAliqCFGer  := {}
Local aContrAliq  := Array(6)
Local aValContri  := Array(6)
Local aRet		  := {0,0}

Local cAliasSD2   := "SD2"
Local cAliasSD1   := "SD1"
Local cAliasSB1   := "SB1"
Local cAliasSF4   := "SF4"
Local cAliasSF2   := "SF2"
Local cAliasSF1   := "SF1"
Local cCpVlPisEn  := ""
Local cCpBsPisEn  := ""
Local cCpVlPisSa  := ""
Local cCpBsPisSa  := ""
Local cCpAlPisSa  := ""
Local cCpAlPisEn  := ""
Local cCpVlCofEn  :=  ""
Local cCpBsCofEn  :=  ""
Local cCpVlCofSa  := ""
Local cCpBsCofSa  := ""
Local cCpAlCofEn  := ""
Local cCpAlCofSa  := ""
Local cLinha      := ""
Local cLinha2	  := ""
Local cArqTemp    := ""
Local cabec1      := ""
Local cabec2      := ""
Local cQuebra     := ""
Local cChave	  := ""
Local cTipo       := ""
Local cCodCfop    := ""
Local cContArq    := ""
Local cLinArq     := ""
Local cArqCp      := ""
Local cB1_GRTRIB  := ""
Local cFilOri     := SM0->M0_CODFIL
Local cFilIni     := ""
Local cFilFin     := ""
Local cFilProc    := ""           
Local cCFOP		  := ""
Local cDesc_cfop  := ""                                     
Local CNumNota	  := ""                                     
Local cSerie      := ""
Local cEmissao    := ""
Local cNcm        := ""
Local cProd       := ""
Local dDtCorte	  := GetNewPar("MV_DTCORTE",CtoD("01/02/2004"))		//A partir desta data o sistema devera utilizar as informacoes gravadas na base
Local cCliFor	  := ""
Local cDebSTPIS   := GetNewPar("MV_DBSTPIS","1")
Local cDebSTCOF   := GetNewPar("MV_DBSTCOF","1")           

Local lRet        := .F.
Local lContinua   := .T.
Local lEntrada    := .F.
Local lQuebra     := .F.
Local lFirst      := .F.
Local lResumo	  := .F.
Local lApurac     := (SF4->(FieldPos("F4_PISFISC")) > 0)

Local nPos		  	:= 0
Local nX		      := 0
Local nRedPis	  	:= 1
Local nRedCOF	  	:= 1
Local nValPisPas 	:= 0
Local nBasPisPas 	:= 0
Local nPsVlPisEn 	:= 0
Local nPsBsPisEn 	:= 0
Local nPsVlPisSa 	:= 0
Local nPsBsPisSa 	:= 0
Local nPsAlPisEn 	:= 0
Local nPsAlPisSa 	:= 0
Local nPosCofins 	:= 0 
Local nValCofins 	:= 0 
Local nBasCofins 	:= 0 
Local nPsVlCofEn 	:= 0 
Local nPsBsCofEn 	:= 0  
Local nPsVlCofSa 	:= 0 
Local nPsBsCofSa 	:= 0 
Local nPsAlCofEn 	:= 0  
Local nPsAlCofSa 	:= 0 
Local nScanPis   	:= 0
Local nScanCof   	:= 0  
Local nTxPis     	:= 0
Local nTxCof     	:= 0
Local nCredPis   	:= 0
Local nCredCof   	:= 0
Local nValCont   	:= 0
Local nZFranca   	:= 0
Local nValDebi   	:= 0
Local nValCred   	:= 0
Local nBasDebi   	:= 0
Local nBasCred   	:= 0
Local nDValCont  	:= 0
Local nDZFranca  	:= 0
Local nDValDebi  	:= 0
Local nDValCred  	:= 0
Local nDBasDebi  	:= 0
Local nDBasCred  	:= 0
Local nGValCont  	:= 0
Local nGZFranca  	:= 0
Local nGValDebi  	:= 0
Local nGValCred  	:= 0
Local nGBasDebi  	:= 0
Local nGBasCred  	:= 0
Local nValContri 	:= 0
Local nContCp    	:= 0
Local nExPis     	:= 0
Local nExCof     	:= 0
Local nValDevVend	:= 0
Local nValComp   	:= 0
Local nValVend   	:= 0 
Local nValDevComp	:= 0
Local nVendTrib  	:= 0
Local nDevCompT  	:= 0
Local nCompTrib  	:= 0
Local nDevVendT  	:= 0 
Local nTValPIS   	:= 0
Local nTValCOF   	:= 0
Local nTotal     	:= 0 
Local nTot_emp	  	:= 0
Local nPosAliq   	:= 0            
Local nContrAli	    := 0
Local nAliq			:= 0 
Local nAcVlrCtb 	:= 0
Local nAcZfranca	:= 0
Local nAcVlrCtbD	:= 0
Local nAcVlrCtbC	:= 0
Local nAcBsCtbD	    := 0
Local nAcBsCtbC		:= 0 
Local nCt			:= 0  
Local nPautaPIS		:= 0
Local nPautaCOF		:= 0
Local nXX			:= 0
Local nLiAnt	    := 0 
Local nAliqP		:= 0
Local lOrgPub		:= IIF(mv_par13 == 1,.T.,.F.)  
Local cDEDBCOF      := GetNewPar("MV_DEDBCOF"," ")      
Local cDEDBPIS      := GetNewPar("MV_DEDBPIS"," ")  
Local nContCp2    := 0    

cbtxt      := Space(10)
cbcont     := 00
li         := 80

If mv_par04 == 1 // Analitico
	Cabec1 := STR0022  //" Produto          NCM         Valor Contabil            Zona Franca      Aliquota              Valor da Contribuicao                            Base da Contribuicao              Documento   Serie  Emissao   Cliente/Forn."
Else	                                                                                                                                                                                                                                              
	Cabec1 := STR0005  //" Produto          NCM         Valor Contabil            Zona Franca      Aliquota              Valor da Contribuicao                            Base da Contribuicao"
Endif	

Cabec2 := STR0006  //"                                                          Desconto                             Debito                 Credito                  Debito                 Credito" 

// " Produto          NCM         Valor Contabil            Zona Franca      Aliquota              Valor da Contribuicao                            Base da Contribuicao              Documento   Serie  Emissao                "
// "                                                          Desconto                             Debito                 Credito                  Debito                 Credito" 
// "XXXXXXXXXXXXXXX  XXXXXXXXXX  999,999,999,999.99   999,999,999,999.99    99.99    999,999,999,999.99      999,999,999,999.99      999,999,999,999.99      999,999,999,999.99
// 0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21        22
// 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901

SetRegua(SD1->(LastRec())+SD2->(LastRec())) 

//Inicialização do Array de Total Contribuicao
For nCt := 1 To len(aValContri)
	aValContri[nCt] := 0
Next nCt  

//Tratamento para os campos do PIS - Entrada                        
If !Empty( nScanPis := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_BASEPS2"} ) )
	cCpBsPisEn := aRelImp[nScanPis,2]
	nPsBsPisEn := SD1->(FieldPos(cCpBsPisEn))
EndIf
If !Empty( nScanPis := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_VALPS2"} ) )
	cCpVlPisEn := aRelImp[nScanPis,2]
	nPsVlPisEn := SD1->(FieldPos(cCpVlPisEn))
EndIf
If !Empty( nScanPis := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_ALIQPS2"} ) )
	cCpAlPisEn := aRelImp[nScanPis,2]
	nPsAlPisEn := SD1->(FieldPos(cCpAlPisEn))
EndIf
//Tratamento para os campos do PIS - Saida                          
If !Empty( nScanPis := aScan(aRelImp2,{|x| x[1]=="SD2" .And. x[3]=="IT_BASEPS2"} ) )
	cCpBsPisSa := aRelImp2[nScanPis,2]
	nPsBsPisSa := SD2->(FieldPos(cCpBsPisSa))
EndIf
If !Empty( nScanPis := aScan(aRelImp2,{|x| x[1]=="SD2" .And. x[3]=="IT_VALPS2"} ) )
	cCpVlPisSa := aRelImp2[nScanPis,2]
	nPsVlPisSa := SD2->(FieldPos(cCpVlPisSa))
EndIf 	
If !Empty( nScanPis := aScan(aRelImp2,{|x| x[1]=="SD2" .And. x[3]=="IT_ALIQPS2"} ) )
	cCpAlPisSa := aRelImp2[nScanPis,2]
	nPsAlPisSa := SD2->(FieldPos(cCpAlPisSa))
EndIf 	

AFill( aTotaisCof, 0 ) 

//Tratamento para os campos do COF - Entrada                        
If !Empty( nScanCof := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_BASECF2"} ) )
	cCpBsCofEn := aRelImp[nScanCof,2]
	nPsBsCofEn := SD1->(FieldPos(cCpBsCofEn))
EndIf 	

If !Empty( nScanCof := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_VALCF2"} ) )
	cCpVlCofEn := aRelImp[nScanCof,2]
	nPsVlCofEn := SD1->(FieldPos(cCpVlCofEn))
EndIf 	

If !Empty( nScanCof := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_ALIQCF2"} ) )
	cCpAlCofEn := aRelImp[nScanCof,2]
	nPsAlCofEn := SD1->(FieldPos(cCpAlCofEn))
EndIf 	

//Tratamento para os campos do COF - Saida                          
If !Empty( nScanCof := aScan(aRelImp2,{|x| x[1]=="SD2" .And. x[3]=="IT_BASECF2"} ) )
	cCpBsCofSa := aRelImp2[nScanCof,2]
	nPsBsCofSa := SD2->(FieldPos(cCpBsCofSa))
EndIf 	

If !Empty( nScanCof := aScan(aRelImp2,{|x| x[1]=="SD2" .And. x[3]=="IT_VALCF2"} ) )
	cCpVlCofSa := aRelImp2[nScanCof,2]
	nPsVlCofSa := SD2->(FieldPos(cCpVlCofSa))
EndIf 	

If !Empty( nScanCof := aScan(aRelImp2,{|x| x[1]=="SD2" .And. x[3]=="IT_ALIQCF2"} ) )
	cCpAlCofSa := aRelImp2[nScanCof,2]
	nPsAlCofSa := SD2->(FieldPos(cCpAlCofSa))
EndIf 	

AADD(aArqTemp,{"NUMNF"		,"C",TamSx3("D2_DOC")[1],0})
AADD(aArqTemp,{"SERIE"		,"C",03,0})
AADD(aArqTemp,{"EMISSAO"   ,"D",TamSx3("D2_EMISSAO")[1],0})
AADD(aArqTemp,{"TIPO"		,"C",03,0})
AADD(aArqTemp,{"CFOP"	   ,"C",04,0})
AADD(aArqTemp,{"PRODUTO"	,"C",15,0})
AADD(aArqTemp,{"NCM"			,"C",10,0})
AADD(aArqTemp,{"VALORCONT"	,"N",14,2})
AADD(aArqTemp,{"ZFRANCA"	,"N",14,2})
AADD(aArqTemp,{"ALIQ"		,"N",TamSx3("B1_VLR_COF")[1],TamSx3("B1_VLR_COF")[2]})
AADD(aArqTemp,{"PISCSAI"	,"N",14,2})
AADD(aArqTemp,{"PISDSAI"	,"N",14,2})
AADD(aArqTemp,{"BASPICSAI"	,"N",14,2})
AADD(aArqTemp,{"BASPIDSAI"	,"N",14,2})
AADD(aArqTemp,{"PISCENT"	,"N",14,2})
AADD(aArqTemp,{"PISDENT"	,"N",14,2})
AADD(aArqTemp,{"BASPICENT"	,"N",14,2})
AADD(aArqTemp,{"BASPIDENT"	,"N",14,2})
AADD(aArqTemp,{"COFCSAI"	,"N",14,2})
AADD(aArqTemp,{"COFDSAI"	,"N",14,2})
AADD(aArqTemp,{"BASCOCSAI"	,"N",14,2})
AADD(aArqTemp,{"BASCODSAI"	,"N",14,2})
AADD(aArqTemp,{"COFCENT"	,"N",14,2})
AADD(aArqTemp,{"COFDENT"	,"N",14,2})
AADD(aArqTemp,{"BASCOCENT"	,"N",14,2})
AADD(aArqTemp,{"BASCODENT"	,"N",14,2})
AADD(aArqTemp,{"ES"			,"C",01,0})
AADD(aArqTemp,{"CLIFOR"		,"C",16,0})
AADD(aArqTemp,{"PAUTA"		,"C",01,0})     
//Array para totalizar os movimentos por filial
For nX := 1 to 3
	aTotSai[nX] 		:= 0
	aTotDevS[nX]		:= 0
	aTotEnt[nX]			:= 0
	aTotDevE[nX]		:= 0
	aTotApur[1][nX]	:= 0
	aTotApur[2][nX]	:= 0
Next
//Verifica se ira processar mais de uma filial.                                        
//Se sim, ira emitir o relatorio separadamente, criando um resumo das filiais ao final.
If mv_par06 == 1
	cFilIni := mv_par07
	cFilFin := mv_par08
Else
	cFilIni := cFilAnt
	cFilFin := cFilAnt
Endif

dbSelectArea("SM0")
SM0->(dbSeek(cEmpAnt+cFilIni,.T.))

cFilProc := cFilIni	
While SM0->M0_CODIGO == cEmpAnt .And. SM0->M0_CODFIL <= cFilFin .And. !SM0->(Eof())	
	cFilAnt := SM0->M0_CODFIL
	//Cria o temporario para cada filial processada.                 
	//cArqTemp := CriaTrab(aArqTemp)
	//dbUseArea(.T.,__LocalDriver,cArqTemp,"TRB")
	//IndRegua("TRB",cArqTemp,IIF(MV_PAR09==1,"TIPO+CFOP+DTOS(EMISSAO)","TIPO+CFOP"))
	//dbSelectArea("TRB")
	
	
	oTemptable := FWTemporaryTable():New( "TRB")
	oTemptable:SetFields( aArqTemp )
	oTempTable:AddIndex("index1", {"TIPO+CFOP+DTOS(EMISSAO)","TIPO+CFOP"} )
	oTempTable:Create()
	
	//Processamento das Saidas                                          
	dbSelectArea("SD2")
	SD2->(dbSetOrder(5))
	#IFDEF TOP
		lQuery		:= .T.
		cAliasSD2	:= "a906AMontSD2"
		cAliasSF2	:= "a906AMontSD2"
		cAliasSF4	:= "a906AMontSD2"
		cAliasSB1	:= "a906AMontSD2"
	
		aStruSD2	:= SD2->(dbStruct())
		aStruSB1	:= SB1->(dbStruct())	
		aStruSF4	:= SF4->(dbStruct())	
		aStruSF2	:= SF2->(dbStruct())	
	
		cQuery		:= "SELECT DISTINCT(D2_ITEM)D2_ITEM,F4_AGREG,F4_IPI,F2_SERIE,F2_DOC,F2_SEGURO,F2_FRETE,F2_DESPESA,F2_VALMERC,D2_TOTAL,D2_DOC,D2_SERIE,D2_EMISSAO,D2_CF,D2_COD,D2_DESCZFR,B1_POSIPI,D2_TIPO,"
		cQuery		+= "D2_ICMSRET,D2_VALIPI,D2_VALFRE,D2_SEGURO,D2_DESPESA,D2_CLIENTE,D2_LOJA,D2_VALBRUT "
		
		If !Empty( nPsVlPisSa )
			cQuery += "," + cCpVlPisSa
		EndIf
	
		If !Empty( nPsBsPisSa )
			cQuery += "," + cCpBsPisSa
		EndIf
		
		If !Empty( nPsAlPisSa )
			cQuery += "," + cCpAlPisSa
		EndIf
		
		If !Empty( nPsVlCofSa ) 
			cQuery += "," + cCpVlCOfSa 
		EndIf 
		
		If !Empty( nPsBsCofSa ) 
			cQuery += "," + cCpBsCofSa 
		EndIf 
	
		If !Empty( nPsAlCofSa ) 
			cQuery += "," + cCpAlCOfSa 
		EndIf 	
	
		If SB1->(FieldPos("B1_PPIS")) >0
			cQuery += ",B1_PPIS "
		Endif	
	
		If SB1->(FieldPos("B1_REDPIS")) > 0
			cQuery += ",B1_REDPIS "
		Endif	
	
		If SB1->(FieldPos("B1_VLR_PIS")) > 0 //Valor de Pauta PIS
			cQuery += ",B1_VLR_PIS "
		Endif	

		If SB1->(FieldPos("B1_REDCOF")) > 0
			cQuery += ",B1_REDCOF "
		Endif	
	
		If SB1->(FieldPos("B1_PCOFINS")) > 0	
			cQuery += ",B1_PCOFINS "
		Endif
	
		If SB1->(FieldPos("B1_VLR_COF")) > 0 //Valor de Pauta COFINS
			cQuery += ",B1_VLR_COF "
        Endif

		If SB1->(FieldPos("B1_GRTRIB")) > 0	
			cQuery += ",B1_GRTRIB "
		Endif

		If SF4->(FieldPos("F4_BASEPIS")) > 0
			cQuery += ",F4_BASEPIS "	
		Endif		
		
		If SF4->(FieldPos("F4_BASECOF")) > 0
			cQuery += ",F4_BASECOF "	
		Endif
	
		If SF4->(FieldPos("F4_PISCOF")) > 0
			cQuery += ",F4_PISCOF "	
		Endif		
	
		If SF4->(FieldPos("F4_PISCRED")) > 0
			cQuery += ",F4_PISCRED "	
		Endif		
		
		If SF4->(FieldPos("F4_TPREG")) > 0
			cQuery += ",F4_TPREG "	
		Endif		
		If lApurac
			cQuery += ",F4_PISFISC "
		Endif
			cQuery += ",B1_DESC "	
		cQuery 	+= "FROM "+RetSqlName("SD2")+" SD2 "
		cQuery 	+= "LEFT JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"' AND F4_CODIGO = D2_TES AND SF4.D_E_L_E_T_ = ' ' "	
		cQuery 	+= "LEFT JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = D2_COD AND SB1.D_E_L_E_T_ = ' ' "	
		cQuery 	+= "LEFT JOIN "+RetSqlName("SF2")+" SF2 ON F2_FILIAL = '"+xFilial("SF2")+"' AND F2_DOC = D2_DOC AND	F2_SERIE = D2_SERIE AND "
		cQuery  += "F2_CLIENTE = D2_CLIENTE AND F2_LOJA = D2_LOJA AND F2_EMISSAO = D2_EMISSAO AND SF2.D_E_L_E_T_ = ' ' "	
		cQuery 	+= "LEFT JOIN "+RetSqlName("SF3")+" SF3 ON F3_FILIAL = '"+xFilial("SF3")+"' AND	F3_NFISCAL = D2_DOC AND F3_SERIE = D2_SERIE AND "
		cQuery  += "F3_CLIEFOR = D2_CLIENTE AND F3_LOJA = D2_LOJA AND SF3.D_E_L_E_T_ = ' ' "
		
		If MV_PAR12 == 1
			cQuery	+= "LEFT JOIN "+RetSqlName("SE1")+" SE1	ON E1_NUM = D2_DOC AND E1_PREFIXO = D2_SERIE"
		EndIf		

		cQuery 	+= "WHERE D2_FILIAL='"+xFilial("SD2")+"' AND "
		If MV_PAR12 == 1 .And. MV_PAR15 == 1
			cQuery 	+= "E1_BAIXA>='"+Dtos(MV_PAR02)+"' AND "
			cQuery 	+= "E1_BAIXA<='"+Dtos(MV_PAR03)+"' AND "		
			cQuery  += "SE1.D_E_L_E_T_ = ' ' "	
		Else	
			cQuery 	+= "D2_EMISSAO>='"+Dtos(MV_PAR02)+"' AND "
			cQuery 	+= "D2_EMISSAO<='"+Dtos(MV_PAR03)+"' AND "
			cQuery	+= "SD2.D_E_L_E_T_ = ' ' "
		EndIf
					
		//Livro Selecionado		
		If !((Empty (MV_PAR05)) .Or. ("*"$MV_PAR05))
			cQuery += " AND F3_NRLIVRO='"+MV_PAR05+"' "
		EndIf						
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso os parametros/TES estejam configurados para deduzir o IPI da base de calculo  	        ³
		//³de PIS/COFINS considero o documento de complemento no relatorio, caso contrario mesmo que	³
		//³o documento calcule PIS/COFINS nao deve ser levado.                                      	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Upper(cDEDBCOF) $ "P#S" .Or. Upper(cDEDBPIS) $ "P#S" 
			cQuery  += " AND ((F4_IPI = 'S' AND F4_CREDIPI = 'N' "		
			cQuery  += " AND SF2.F2_TIPO IN('I', 'P'))  "	        	//Considera NF de Compelementos que utilizam a mesma TES que calcule PIS/COFINS
			cQuery  += " OR  (SF2.F2_TIPO NOT IN('I', 'P'))) "	        //Nao considera NF de Compelementos que utilizam a mesma TES que calcule PIS/COFINS		
		Else
			cQuery  += " AND SF2.F2_TIPO NOT IN('I', 'P') "	        	//Nao considera NF de Compelementos que utilizam a mesma TES que calcule PIS/COFINS
		EndIF			
		
		If ExistBlock("MT996QRY")
			cQuery := ExecBlock("MT996QRY",.F.,.F.,{cQuery,1})
		EndIf
	
	    If mv_par11 ==1
			cQuery += "ORDER BY D2_CF, D2_DOC"
		Else
			cQuery += "ORDER BY D2_CF, D2_COD"
		Endif	
	
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)
	
		For nX := 1 To len(aStruSD2)
			If aStruSD2[nX][2] <> "C" .And. FieldPos(aStruSD2[nX][1])<>0
				TcSetField(cAliasSD2,aStruSD2[nX][1],aStruSD2[nX][2],aStruSD2[nX][3],aStruSD2[nX][4])
			EndIf
		Next nX
	
		For nX := 1 To len(aStruSB1)
			If aStruSB1[nX][2] <> "C" .And. FieldPos(aStruSB1[nX][1])<>0
				TcSetField(cAliasSB1,aStruSB1[nX][1],aStruSB1[nX][2],aStruSB1[nX][3],aStruSB1[nX][4])
			EndIf
		Next nX
	
		For nX := 1 To len(aStruSF4)
			If aStruSF4[nX][2] <> "C" .And. FieldPos(aStruSF4[nX][1])<>0
				TcSetField(cAliasSF4,aStruSF4[nX][1],aStruSF4[nX][2],aStruSF4[nX][3],aStruSF4[nX][4])
			EndIf
		Next nX
	
		For nX := 1 To len(aStruSF2)
			If aStruSF2[nX][2] <> "C" .And. FieldPos(aStruSF2[nX][1])<>0
				TcSetField(cAliasSF2,aStruSF2[nX][1],aStruSF2[nX][2],aStruSF2[nX][3],aStruSF2[nX][4])
			EndIf
		Next nX
	
		dbSelectArea(cAliasSD2)	
		nPsVlPisSa := ( cAliasSD2 )->( FieldPos( cCpVlPisSa ) )
		nPsBsPisSa := ( cAliasSD2 )->( FieldPos( cCpBsPisSa ) )
		nPsAlPisSa := ( cAliasSD2 )->( FieldPos( cCpAlPisSa ) )
		nPsVlCofSa := ( cAliasSD2 )->( FieldPos( cCpVlCofSa ) ) 
		nPsBsCOfSa := ( cAliasSD2 )->( FieldPos( cCpBsCofSa ) ) 
		nPsAlCofSa := ( cAliasSD2 )->( FieldPos( cCpAlCofSa ) ) 
	#ELSE
		cAliasSD2 := "SD2"
	    cIndex    := 'D2_CF'//CriaTrab(NIL,.F.)
		cKey		 := 'D2_CF'
		cCondicao := 'D2_FILIAL=="'+xFilial("SD2")+'".And.'
		cCondicao += 'DTOS(D2_EMISSAO)>="'+DTOS(MV_PAR02)+'".And.DTOS(D2_EMISSAO)<="'+DTOS(MV_PAR03)+'".And.'
		cCondicao += '!D2_TIPO$"I#P"'		//Nao considera NF de Compelementos que utilizam a mesma TES que calcule PIS/COFINS
		IndRegua(cAliasSD2,cIndex,cKey,,cCondicao)
		nIndex := RetIndex("SD2")
		dbSelectArea("SD2")
		dbSetIndex(cIndex+OrdBagExt())
		 
		dbSetOrder(nIndex+1)
		dbGoTop()
		dbSelectArea(cAliasSD2)
	#ENDIF
	While (cAliasSD2)->(!Eof()) 
		nPautaPIS := 0
		nPautaCOF := 0
		
		If !lQuery
			SF4->(dbSetOrder(1))
			SF4->(MsSeek(xFilial("SF4")+(cAliasSD2)->D2_TES))
			SB1->(dbSetOrder(1))
			SB1->(MsSeek(xFilial("SB1")+(cAliasSD2)->D2_COD))
			SF2->(dbSetOrder(1))
			SF2->(MsSeek(xFilial("SF2")+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
			cB1_GRTRIB := SB1->B1_GRTRIB
		Else                            
			cB1_GRTRIB := (cAliasSB1)->B1_GRTRIB
		EndIf                        		                            
		//Verifica Cliente/Fornecedor    
		SA1->(dbSetOrder(1))
		SA2->(dbSetOrder(1))
		If (cAliasSD2)->D2_TIPO$"DB"
			SA2->(MsSeek(xFilial("SA2")+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
			cCliFor 	:= SA2->A2_NOME
		Else
			SA1->(MsSeek(xFilial("SA1")+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
			cCliFor 	:= SA1->A1_NOME
		Endif
		
		If (cAliasSF4)->F4_AGREG <> "N"	
			If SB1->(FieldPos("B1_PPIS")) >0
				nTxPIS	:= 	Iif((cAliasSB1)->B1_PPIS <> 0,(cAliasSB1)->B1_PPIS , GetMv("MV_TXPIS"))
			Endif	
			If SB1->(FieldPos("B1_REDPIS")) > 0
				nRedPIS	:= 	Iif((cAliasSB1)->B1_REDPIS > 0,1-((cAliasSB1)->B1_REDPIS / 100 ), 1 )
			Endif			
			If SF4->(FieldPos("F4_BASEPIS")) > 0
				nRedPIS	*= 	Iif((cAliasSF4)->F4_BASEPIS > 0,1-((cAliasSF4)->F4_BASEPIS / 100 ), 1 )
			Endif			
			If SB1->(FieldPos("B1_VLR_PIS")) > 0
				nPautaPIS	:= 	(cAliasSB1)->B1_VLR_PIS
			Endif
			If SB1->(FieldPos("B1_REDCOF")) > 0
				nRedCOF	:= 	Iif((cAliasSB1)->B1_REDCOF > 0,1-((cAliasSB1)->B1_REDCOF / 100 ), 1 )
			EndIf			
			If SF4->(FieldPos("F4_BASECOF")) > 0
				nRedCOF	*= 	Iif((cAliasSF4)->F4_BASECOF > 0,1-((cAliasSF4)->F4_BASECOF / 100 ), 1 )
			EndIf	
			If SB1->(FieldPos("B1_PCOFINS")) > 0	
				nTxCOF	:=	if((cAliasSB1)->B1_PCOFINS <> 0,(cAliasSB1)->B1_PCOFINS , GetMv("MV_TXCOFIN"))
			Endif	           
			If SB1->(FieldPos("B1_VLR_COF")) > 0
				nPautaCOF	:= 	(cAliasSB1)->B1_VLR_COF
			Endif
			If SF4->(FieldPos("F4_PISCOF")) > 0
				If !lApurac .Or. ((cAliasSF4)->F4_PISFISC<>"2")
					If (cAliasSF4)->F4_PISCOF $ "13" //1-PIS;3-Ambos
						nValPisPas := 0
						nBasPisPas := 0
						//Verifica se existem os campos para gravacao do valor/base do PIS  
						If (cAliasSD2)->D2_EMISSAO >= dDtCorte .And. ;
							!Empty( nPsVlPisSa ) .And. !Empty( nPsBsPisSa ) .And.  !Empty( nPsAlPisSa )
							nValPisPas	:= ( cAliasSD2 )->( FieldGet( nPsVlPisSa ) )
							nBasPisPas	:= ( cAliasSD2 )->( FieldGet( nPsBsPisSa ) )
							nTxPIS		:= ( cAliasSD2 )->( FieldGet( nPsAlPisSa ) )
						EndIf
						
						If mv_par01 <> 2 .And. mv_par12 == 3 .And. !(cAliasSF4)->F4_TPREG$"123"//PIS e Ambos
							RecLock("TRB",.T.)
							TRB->NUMNF     	:= (cAliasSD2)->D2_DOC
							TRB->SERIE     	:= (cAliasSD2)->D2_SERIE
							TRB->EMISSAO   	:= (cAliasSD2)->D2_EMISSAO
							TRB->CFOP      	:= (cAliasSD2)->D2_CF
							TRB->PRODUTO   	:= ALLTRIM((cAliasSD2)->D2_COD)+' - '+ALLTRIM((cAliasSB1)->B1_DESC)
							TRB->NCM       	:= (cAliasSB1)->B1_POSIPI
							TRB->VALORCONT 	:= CompVlCont(cAliasSD2)
							TRB->ZFRANCA   	:= (cAliasSD2)->D2_DESCZFR
							TRB->ALIQ      	:= Iif(nExPis == 0,Iif(nPautaPIS <> 0,nPautaPIS,nTxPIS),nExPis)
							TRB->TIPO      	:= "PIS"
							TRB->ES			:=	"S"
							TRB->CLIFOR		:= cCliFor
							TRB->PAUTA		:= Iif(nPautaPIS <> 0,"S","N")
							MsUnlock()
							//Verifica a Data de Corte ( 01/02/2004 )                           
							If (cAliasSD2)->D2_EMISSAO >= dDtCorte
								//Sempre efetua o debito na saida                                   
								If SF4->(FieldPos("F4_PISCRED")) >0
									RecLock("TRB",.F.)
									If (cAliasSF4)->F4_PISCRED <> "4" .And. (cAliasSF4)->F4_PISCRED <> "1" // Se a opcao for 'calcula'/'credita', nao debita 
										TRB->PISDSAI   := nValPisPas
										TRB->BASPIDSAI := nBasPisPas					
									Endif	
									If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
										TRB->PISCSAI   := nValPisPas
										TRB->BASPICSAI := nBasPisPas
									Endif	
									MsUnlock()
								Endif	
							Else
								//Sempre efetua o debito na saida                                   
								If SF4->(FieldPos("F4_PISCRED")) >0
									RecLock("TRB",.F.)
									If (cAliasSF4)->F4_PISCRED <> "4" .And. (cAliasSF4)->F4_PISCRED <> "1"  // Se a opcao for 'calcula', nao debita 
										TRB->PISDSAI   := ( ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC) ) * nRedPis ) * (TRB->ALIQ/100)
										TRB->BASPIDSAI := ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC)  ) * nRedPis
									Endif	
									If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
										TRB->PISCSAI   := ( ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC) )  * nRedPis) * (TRB->ALIQ/100)
										TRB->BASPICSAI := ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC)  ) * nRedPis
									Endif	
									MsUnlock()
								Endif
							EndIf						
						Endif
						If mv_par01 <> 2 .And. mv_par12 == 1 .And. (cAliasSF4)->F4_TPREG$"123" //NAO CUMULATIVO/CUMULATIVO/AMBOS
							RecLock("TRB",.T.)
							TRB->NUMNF     	:= (cAliasSD2)->D2_DOC
							TRB->SERIE     	:= (cAliasSD2)->D2_SERIE
							TRB->EMISSAO   	:= (cAliasSD2)->D2_EMISSAO
							TRB->CFOP      	:= (cAliasSD2)->D2_CF
							TRB->PRODUTO   	:= ALLTRIM((cAliasSD2)->D2_COD)+' - '+ALLTRIM((cAliasSB1)->B1_DESC)
							TRB->NCM       	:= (cAliasSB1)->B1_POSIPI
							TRB->VALORCONT 	:= CompVlCont(cAliasSD2)
							TRB->ZFRANCA   	:= (cAliasSD2)->D2_DESCZFR
							TRB->ALIQ      	:= Iif(nExPis == 0,Iif(nPautaPIS <> 0,nPautaPIS,nTxPIS),nExPis)
							TRB->TIPO      	:= "PIS"
							TRB->ES			:=	"S"
							TRB->CLIFOR		:= cCliFor
							TRB->PAUTA		:= Iif(nPautaPIS <> 0,"S","N")
							MsUnlock()
							//Verifica a Data de Corte ( 01/02/2004 )                           
							If (cAliasSD2)->D2_EMISSAO >= dDtCorte
								//Sempre efetua o debito na saida                                   
								If SF4->(FieldPos("F4_PISCRED")) >0
									RecLock("TRB",.F.)
									If (cAliasSF4)->F4_PISCRED <> "4"  // Se a opcao for 'calcula', nao debita 
										TRB->PISDSAI   := nValPisPas
										TRB->BASPIDSAI := nBasPisPas					
									Endif	
									If (cAliasSF4)->F4_PISCOF $ "23" .And. (cAliasSF4)->F4_PISCRED == "1" .And. mv_par01 <> 1 // 2-Cofins; 3- Ambos
										TRB->PISCSAI   := nValPisPas
										TRB->BASPICSAI := nBasPisPas
									Endif	
									MsUnlock()
								Endif	
							Else
								//Sempre efetua o debito na saida                                   
								If SF4->(FieldPos("F4_PISCRED")) >0
									RecLock("TRB",.F.)
									If (cAliasSF4)->F4_PISCRED <> "4"  // Se a opcao for 'calcula', nao debita 
										TRB->PISDSAI   := ( ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC) ) * nRedPis ) * (TRB->ALIQ/100)
										TRB->BASPIDSAI := ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC)  ) * nRedPis
									Endif	
									If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
										TRB->PISCSAI   := ( ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC) )  * nRedPis) * (TRB->ALIQ/100)
										TRB->BASPICSAI := ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC)  ) * nRedPis
									Endif	
									MsUnlock()
								Endif
							EndIf						
						Endif						
						
						If mv_par01 <> 2 .And. mv_par12 == 2 .And. (cAliasSF4)->F4_TPREG$"1" //NAO CUMULATIVO/CUMULATIVO/AMBOS
							RecLock("TRB",.T.)
							TRB->NUMNF     	:= (cAliasSD2)->D2_DOC
							TRB->SERIE     	:= (cAliasSD2)->D2_SERIE
							TRB->EMISSAO   	:= (cAliasSD2)->D2_EMISSAO
							TRB->CFOP      	:= (cAliasSD2)->D2_CF
							TRB->PRODUTO   	:= ALLTRIM((cAliasSD2)->D2_COD)+' - '+ALLTRIM((cAliasSB1)->B1_DESC)
							TRB->NCM       	:= (cAliasSB1)->B1_POSIPI
							TRB->VALORCONT 	:= CompVlCont(cAliasSD2)
							TRB->ZFRANCA   	:= (cAliasSD2)->D2_DESCZFR
							TRB->ALIQ      	:= Iif(nExPis == 0,Iif(nPautaPIS <> 0,nPautaPIS,nTxPIS),nExPis)
							TRB->TIPO      	:= "PIS"
							TRB->ES			:=	"S"
							TRB->CLIFOR		:= cCliFor
							TRB->PAUTA		:= Iif(nPautaPIS <> 0,"S","N")
							MsUnlock()
							//Verifica a Data de Corte ( 01/02/2004 )                           
							If (cAliasSD2)->D2_EMISSAO >= dDtCorte
								//Sempre efetua o debito na saida                                   
								If SF4->(FieldPos("F4_PISCRED")) >0
									RecLock("TRB",.F.)
									If (cAliasSF4)->F4_PISCRED <> "4"  // Se a opcao for 'calcula', nao debita 
										TRB->PISDSAI   := nValPisPas
										TRB->BASPIDSAI := nBasPisPas					
									Endif	
									If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
										TRB->PISCSAI   := nValPisPas
										TRB->BASPICSAI := nBasPisPas
									Endif	
									MsUnlock()
								Endif	
							Else
								//Sempre efetua o debito na saida                                   
								If SF4->(FieldPos("F4_PISCRED")) >0
									RecLock("TRB",.F.)
									If (cAliasSF4)->F4_PISCRED <> "4"  // Se a opcao for 'calcula', nao debita 
										TRB->PISDSAI   := ( ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC) ) * nRedPis ) * (TRB->ALIQ/100)
										TRB->BASPIDSAI := ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC)  ) * nRedPis
									Endif	
									If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
										TRB->PISCSAI   := ( ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC) )  * nRedPis) * (TRB->ALIQ/100)
										TRB->BASPICSAI := ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC)  ) * nRedPis
									Endif	
									MsUnlock()
								Endif
							EndIf						
						Endif
					EndIf
					If (cAliasSF4)->F4_PISCOF $ "23" .And. mv_par01 <> 1 .And. mv_par12 == 3 .And. !(cAliasSF4)->F4_TPREG$"123"// 2-Cofins; 3- Ambos
						nValCofins := 0 
						nBasCofins := 0 					
						//Verifica se existem os campos para gravacao do valor/base da COFINS  
						If (cAliasSD2)->D2_EMISSAO >= dDtCorte .And. ;
							!Empty( nPsVlCofSa ) .And. !Empty( nPsBsCofSa ) .And. !Empty( nPsAlCofSa )
							nValCofins := ( cAliasSD2 )->( FieldGet( nPsVlCofSa ) )
							nBasCofins := ( cAliasSD2 )->( FieldGet( nPsBsCofSa ) )
							nTxCOF := ( cAliasSD2 )->( FieldGet( nPsAlCofSa ) )
						EndIf							
						RecLock("TRB",.T.)
						TRB->NUMNF     := (cAliasSD2)->D2_DOC
						TRB->SERIE     := (cAliasSD2)->D2_SERIE    
						TRB->EMISSAO   := (cAliasSD2)->D2_EMISSAO
						TRB->CFOP      := (cAliasSD2)->D2_CF
						TRB->PRODUTO   	:= ALLTRIM((cAliasSD2)->D2_COD)+' - '+ALLTRIM((cAliasSB1)->B1_DESC)	
						TRB->NCM       := (cAliasSB1)->B1_POSIPI
						TRB->VALORCONT := CompVlCont(cAliasSD2)
						TRB->ZFRANCA   := (cAliasSD2)->D2_DESCZFR
						TRB->ALIQ      := Iif(nExCof == 0,Iif(nPautaCOF <> 0,nPautaCOF,nTxCOF),nExCof)
						TRB->TIPO      := "COF"
						TRB->ES        := "S"
						TRB->CLIFOR	   := cCliFor
						TRB->PAUTA	   := Iif(nPautaCOF <> 0,"S","N")
						MsUnlock()
						//Verifica a Data de Corte ( 01/02/2004 )                           
						If (cAliasSD2)->D2_EMISSAO >= dDtCorte
							If SF4->(FieldPos("F4_PISCRED")) >0
								RecLock("TRB",.F.)
								If (cAliasSF4)->F4_PISCRED <> "4" .And. (cAliasSF4)->F4_PISCRED <> "1"// Se a opcao for 'calcula'/'credita', nao debita 
									TRB->COFDSAI   := nValCofins
									TRB->BASCODSAI := nBasCofins
								Endif	
								If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
									TRB->COFCSAI   := nValCofins
									TRB->BASCOCSAI := nBasCofins
								Endif	
								MsUnlock()
							Endif	
			            Else
							If SF4->(FieldPos("F4_PISCRED")) >0
								RecLock("TRB",.F.)
								If (cAliasSF4)->F4_PISCRED <> "4" .And. (cAliasSF4)->F4_PISCRED <> "1"
									TRB->COFDSAI   := ( ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC) ) * nRedCOF) * (TRB->ALIQ/100)
									TRB->BASCODSAI := ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC)  ) * nRedCOF
								Endif	
								If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita ;2-Debita
									TRB->COFCSAI   := ( ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC) )  * nRedCOF) * (TRB->ALIQ/100)
									TRB->BASCOCSAI := ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC)  ) * nRedCOF
								Endif	
								MsUnlock()
							Endif	
						Endif
					EndIf							
					
					If (cAliasSF4)->F4_PISCOF $ "23" .And. mv_par01 <> 1 .And. mv_par12 == 1 .And. (cAliasSF4)->F4_TPREG$"123" //NAO CUMULATIVO/CUMULATIVO/AMBOS
						nValCofins := 0 
						nBasCofins := 0 					
						//Verifica se existem os campos para gravacao do valor/base da COFINS  
						If (cAliasSD2)->D2_EMISSAO >= dDtCorte .And. ;
							!Empty( nPsVlCofSa ) .And. !Empty( nPsBsCofSa ) .And. !Empty( nPsAlCofSa )
							nValCofins	:= ( cAliasSD2 )->( FieldGet( nPsVlCofSa ) )
							nBasCofins	:= ( cAliasSD2 )->( FieldGet( nPsBsCofSa ) )
							nTxCOF		:= ( cAliasSD2 )->( FieldGet( nPsAlCofSa ) )
						EndIf							
						RecLock("TRB",.T.)
						TRB->NUMNF     := (cAliasSD2)->D2_DOC
						TRB->SERIE     := (cAliasSD2)->D2_SERIE    
						TRB->EMISSAO   := (cAliasSD2)->D2_EMISSAO
						TRB->CFOP      := (cAliasSD2)->D2_CF
						TRB->PRODUTO   	:= ALLTRIM((cAliasSD2)->D2_COD)+' - '+ALLTRIM((cAliasSB1)->B1_DESC)
						TRB->NCM       := (cAliasSB1)->B1_POSIPI
						TRB->VALORCONT := CompVlCont(cAliasSD2)
						TRB->ZFRANCA   := (cAliasSD2)->D2_DESCZFR
						TRB->ALIQ      := Iif(nExCof == 0,Iif(nPautaCOF <> 0,nPautaCOF,nTxCOF),nExCof)
						TRB->TIPO      := "COF"
						TRB->ES        := "S"
						TRB->CLIFOR	   := cCliFor
						TRB->PAUTA	   := Iif(nPautaCOF <> 0,"S","N")
						MsUnlock()
						//Verifica a Data de Corte ( 01/02/2004 )                           
						If (cAliasSD2)->D2_EMISSAO >= dDtCorte
							If SF4->(FieldPos("F4_PISCRED")) >0
								RecLock("TRB",.F.)
								If (cAliasSF4)->F4_PISCRED <> "4"  // Se a opcao for 'calcula', nao debita 
									TRB->COFDSAI   := nValCofins
									TRB->BASCODSAI := nBasCofins
								Endif	
								If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
									TRB->COFCSAI   := nValCofins
									TRB->BASCOCSAI := nBasCofins
								Endif	
								MsUnlock()
							Endif	
			            Else
							If SF4->(FieldPos("F4_PISCRED")) >0
								RecLock("TRB",.F.)
								If (cAliasSF4)->F4_PISCRED <> "4"
									TRB->COFDSAI   := ( ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC) ) * nRedCOF) * (TRB->ALIQ/100)
									TRB->BASCODSAI := ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC)  ) * nRedCOF
								Endif	
								If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita ;2-Debita
									TRB->COFCSAI   := ( ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC) )  * nRedCOF) * (TRB->ALIQ/100)
									TRB->BASCOCSAI := ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC)  ) * nRedCOF
								Endif	
								MsUnlock()
							Endif	
						Endif
					EndIf											
					
					If (cAliasSF4)->F4_PISCOF $ "23" .And. mv_par01 <> 1 .And. mv_par12 == 2 .And. (cAliasSF4)->F4_TPREG$"1" //NAO CUMULATIVO/CUMULATIVO/AMBOS
						nValCofins := 0 
						nBasCofins := 0 					
						//Verifica se existem os campos para gravacao do valor/base da COFINS  
						If (cAliasSD2)->D2_EMISSAO >= dDtCorte .And. ;
							!Empty( nPsVlCofSa ) .And. !Empty( nPsBsCofSa ) .And. !Empty( nPsAlCofSa )
							nValCofins := ( cAliasSD2 )->( FieldGet( nPsVlCofSa ) )
							nBasCofins := ( cAliasSD2 )->( FieldGet( nPsBsCofSa ) )
							nTxCOF := ( cAliasSD2 )->( FieldGet( nPsAlCofSa ) )
						EndIf							
						RecLock("TRB",.T.)
						TRB->NUMNF     := (cAliasSD2)->D2_DOC
						TRB->SERIE     := (cAliasSD2)->D2_SERIE    
						TRB->EMISSAO   := (cAliasSD2)->D2_EMISSAO
						TRB->CFOP      := (cAliasSD2)->D2_CF
						TRB->PRODUTO   	:= ALLTRIM((cAliasSD2)->D2_COD)+' - '+ALLTRIM((cAliasSB1)->B1_DESC)
						TRB->NCM       := (cAliasSB1)->B1_POSIPI
						TRB->VALORCONT := CompVlCont(cAliasSD2)
						TRB->ZFRANCA   := (cAliasSD2)->D2_DESCZFR
						TRB->ALIQ      := Iif(nExCof == 0,Iif(nPautaCOF <> 0,nPautaCOF,nTxCOF),nExCof)
						TRB->TIPO      := "COF"
						TRB->ES        := "S"
						TRB->CLIFOR	   := cCliFor
						TRB->PAUTA	   := Iif(nPautaCOF <> 0,"S","N")
						MsUnlock()
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica a Data de Corte ( 01/02/2004 )                           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If (cAliasSD2)->D2_EMISSAO >= dDtCorte
							If SF4->(FieldPos("F4_PISCRED")) >0
								RecLock("TRB",.F.)
								If (cAliasSF4)->F4_PISCRED <> "4"  // Se a opcao for 'calcula', nao debita 
									TRB->COFDSAI   := nValCofins
									TRB->BASCODSAI := nBasCofins
								Endif	
								If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
									TRB->COFCSAI   := nValCofins
									TRB->BASCOCSAI := nBasCofins
								Endif	
								MsUnlock()
							Endif	
			            Else
							If SF4->(FieldPos("F4_PISCRED")) >0
								RecLock("TRB",.F.)
								If (cAliasSF4)->F4_PISCRED <> "4"
									TRB->COFDSAI   := ( ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC) ) * nRedCOF) * (TRB->ALIQ/100)
									TRB->BASCODSAI := ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC)  ) * nRedCOF
								Endif	
								If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita ;2-Debita
									TRB->COFCSAI   := ( ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC) )  * nRedCOF) * (TRB->ALIQ/100)
									TRB->BASCOCSAI := ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC)  ) * nRedCOF
								Endif	
								MsUnlock()
							Endif	
						Endif
					EndIf
					//Gera as informacoes para o Resumo -  Saida 				
					If (cAliasSF4)->F4_PISCOF $ "123" //1-PIS;2-COFINS;3-Ambos					
						If !(cAliasSD2)->D2_TIPO $ "BD"           
							If (cAliasSF4)->F4_PISCOF == "1"
								nVendTrib += (cAliasSD2)->D2_TOTAL+IIf(cDebSTPIS=="6",0,(cAliasSD2)->D2_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD2)->D2_TIPO=="P",0,(cAliasSD2)->D2_VALIPI))+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA)
							EndIf
							If (cAliasSF4)->F4_PISCOF == "2"
								nVendTrib += (cAliasSD2)->D2_TOTAL+IIf(cDebSTCOF=="6",0,(cAliasSD2)->D2_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD2)->D2_TIPO=="P",0,(cAliasSD2)->D2_VALIPI))+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA)
							EndIf
							If (cAliasSF4)->F4_PISCOF == "3"
								nVendTrib += (cAliasSD2)->D2_TOTAL+IIf(cDebSTCOF=="6" .And. cDebSTPIS=="6",0,(cAliasSD2)->D2_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD2)->D2_TIPO=="P",0,(cAliasSD2)->D2_VALIPI))+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA)
							EndIf
						EndIf						
						If (cAliasSD2)->D2_TIPO == "D" 
							If (cAliasSF4)->F4_PISCOF == "1"
								nDevCompT += (cAliasSD2)->D2_TOTAL+IIf(cDebSTPIS=="6",0,(cAliasSD2)->D2_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD2)->D2_TIPO=="P",0,(cAliasSD2)->D2_VALIPI))+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA)
							EndIf
							If (cAliasSF4)->F4_PISCOF == "2"
								nDevCompT += (cAliasSD2)->D2_TOTAL+IIf(cDebSTCOF=="6",0,(cAliasSD2)->D2_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD2)->D2_TIPO=="P",0,(cAliasSD2)->D2_VALIPI))+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA)
							EndIf
							If (cAliasSF4)->F4_PISCOF == "3"
								nDevCompT += (cAliasSD2)->D2_TOTAL+IIf(cDebSTCOF=="6" .And. cDebSTPIS=="6",0,(cAliasSD2)->D2_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD2)->D2_TIPO=="P",0,(cAliasSD2)->D2_VALIPI))+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA)
							EndIf
						EndIF									
					ELSE
						If !(cAliasSD2)->D2_TIPO $ "BD" 
							nValVend += (cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD2)->D2_TIPO=="P",0,(cAliasSD2)->D2_VALIPI))+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA
						EndIF	
			   		If (cAliasSD2)->D2_TIPO == "D" 
							nValDevComp += (cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD2)->D2_TIPO=="P",0,(cAliasSD2)->D2_VALIPI))+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA // Devolucoes Compras D2
						EndIF				
					Endif
				Endif	
			EndIf
		EndIf	
		(cAliasSD2)->( dbSkip())
		IncRegua()
	EndDo
	If lQuery
		dbSelectArea(cAliasSD2)
		dbCloseArea()
		dbSelectArea("SD2")
	Else
		dbSelectArea("SD2")
		RetIndex("SD2")
		dbClearFilter()
		Ferase(cIndex+OrdBagExt())
	EndIf	
	//Processamento das Entradas                                        
	dbSelectArea("SD1")
	SD1->(dbSetOrder(6))
	#IFDEF TOP
		lQuery		:= .T.
		cAliasSD1	:= "a906AMontSD1"
		cAliasSF4	:= "a906AMontSD1"
		cAliasSB1	:= "a906AMontSD1"	
		cAliasSF1	:= "a906AMontSD1"	
	
		aStruSD1	:= SD1->(dbStruct())
		aStruSB1	:= SB1->(dbStruct())	
		aStruSF4	:= SF4->(dbStruct())	
		aStruSF1	:= SF1->(dbStruct())	
	
		cQuery		:= "SELECT DISTINCT(D1_ITEM)D1_ITEM,D1_CF,D1_COD,D1_TOTAL,D1_VALDESC,B1_POSIPI,D1_DOC,D1_SERIE,D1_DTDIGIT,D1_TIPO,"
		cQuery		+= "D1_ICMSRET,D1_VALIPI,D1_VALFRE,D1_SEGURO,D1_DESPESA,D1_VALICM,D1_FORNECE,D1_LOJA, "
	
		If !Empty( nPsVlPisEn )
			cQuery += cCpVlPisEn + ","
		EndIf
	
		If !Empty( nPsBsPisEn )
			cQuery += cCpBsPisEn + ","
		EndIf
		
		If !Empty( nPsAlPisEn )
			cQuery += cCpAlPisEn + ","
		EndIf	
		
		If !Empty( nPsVlCofEn ) 
			cQuery += cCpVlCofEn + "," 
		EndIf 
		
		If !Empty( nPsBsCofEn ) 
			cQuery += cCpBsCofEn + "," 
		EndIf 
		
		If !Empty( nPsAlCofEn ) 
			cQuery += cCpAlCofEn + "," 
		EndIf 
		
		If SF4->( FieldPos( "F4_AGRPIS" ) )>0
			cQuery	+=	"F4_AGRPIS,"
		EndIF
	
		If SF4->( FieldPos( "F4_AGRCOF" ) )>0
			cQuery	+=	"F4_AGRCOF,"
		EndIF
	
		cQuery  += "F4_AGREG,F4_PISCOF,F4_IPI,F1_SEGURO,F1_FRETE,F1_DESPESA,F1_VALMERC,F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA "
	
		If SB1->(FieldPos("B1_PPIS")) >0
			cQuery += ",B1_PPIS "
		Endif	
	
		If SB1->(FieldPos("B1_REDPIS")) > 0
			cQuery += ",B1_REDPIS "
		Endif	
	
		If SB1->(FieldPos("B1_VLR_PIS")) > 0 //Valor Pauta PIS
			cQuery += ",B1_VLR_PIS "
		Endif	

		If SB1->(FieldPos("B1_REDCOF")) > 0
			cQuery += ",B1_REDCOF "
		Endif	
	
		If SB1->(FieldPos("B1_PCOFINS")) > 0	
			cQuery += ",B1_PCOFINS "
		Endif
		
		If SB1->(FieldPos("B1_VLR_COF")) > 0 //Valor Pauta COFINS
			cQuery += ",B1_VLR_COF "
		Endif	

		If SB1->(FieldPos("B1_GRTRIB")) > 0	
			cQuery += ",B1_GRTRIB "
		Endif

		If SF4->(FieldPos("F4_BASEPIS")) > 0
			cQuery += ",F4_BASEPIS "
		Endif	
	
		If SF4->(FieldPos("F4_PISCOF")) > 0
			cQuery += ",F4_PISCOF "	
		Endif		
		
		If SF4->(FieldPos("F4_BASECOF")) > 0
			cQuery += ",F4_BASECOF "	
		Endif
	
		If SF4->(FieldPos("F4_PISCRED")) > 0
			cQuery += ",F4_PISCRED "	
		Endif		
		
		If SF4->(FieldPos("F4_TPREG")) > 0
			cQuery += ",F4_TPREG "	
		Endif		
		If lApurac
			cQuery += ",F4_PISFISC "
		Endif
			cQuery += ",B1_DESC "
		If SF4->(FieldPos("F4_MALQPIS") > 0) .And. SD1->(FieldPos("D1_VALPMAJ") > 0) 
	    	cQuery += ",F4_MALQPIS, D1_VALPMAJ "
		EndIf 		
		If SF4->(FieldPos("F4_MALQCOF") > 0) .And. SD1->(FieldPos("D1_VALCMAJ") > 0)
			cQuery += ",F4_MALQCOF,D1_VALCMAJ "
		EndIf
		cQuery += ",B1_DESC "	
		cQuery 	+= "FROM "+RetSqlName("SD1")+" SD1 "
		cQuery 	+= "LEFT JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"' AND F4_CODIGO = D1_TES AND SF4.D_E_L_E_T_ = ' ' "
		cQuery 	+= "LEFT JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = D1_COD AND SB1.D_E_L_E_T_ = ' ' "	
		cQuery 	+= "LEFT JOIN "+RetSqlName("SF1")+" SF1 ON F1_FILIAL = '"+xFilial("SF1")+"' AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND "
		cQuery 	+= "F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA AND F1_DTDIGIT = D1_DTDIGIT AND SF1.D_E_L_E_T_ = ' '	
		cQuery 	+= "LEFT JOIN "+RetSqlName("SF3")+" SF3 ON F3_FILIAL = '"+xFilial("SF3")+"' AND F3_NFISCAL = D1_DOC AND F3_SERIE = D1_SERIE AND "
		cQuery  += "F3_CLIEFOR = D1_FORNECE AND F3_LOJA = D1_LOJA  AND SF3.D_E_L_E_T_ = ' ' "
		
		cQuery 	+= "WHERE D1_FILIAL='"+xFilial("SD1")+"' AND "
		cQuery 	+= "D1_DTDIGIT>='"+Dtos(MV_PAR02)+"' AND "
		cQuery 	+= "D1_DTDIGIT<='"+Dtos(MV_PAR03)+"' AND "
		cQuery	+= "SD1.D_E_L_E_T_ = ' ' "
						
		//Livro Selecionado	
		If !((Empty (MV_PAR05)) .Or. ("*"$MV_PAR05))
			cQuery += " AND F3_NRLIVRO='"+MV_PAR05+"' "
		EndIf
				 			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso os parametros/TES estejam configurados para deduzir o IPI da base de calculo  	        ³
		//³de PIS/COFINS considero o documento de complemento no relatorio, caso contrario mesmo que	³
		//³o documento calcule PIS/COFINS nao deve ser levado.                                      	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Upper(cDEDBCOF) $ "P#S" .Or. Upper(cDEDBPIS) $ "P#S" 
			cQuery  += " AND ((F4_IPI = 'S' AND F4_CREDIPI = 'N' "		
			cQuery  += " AND SF1.F1_TIPO IN('I', 'P'))  "	        	//Considera NF de Compelementos que utilizam a mesma TES que calcule PIS/COFINS
			cQuery  += " OR  (SF1.F1_TIPO NOT IN('I', 'P'))) "	        //Nao considera NF de Compelementos que utilizam a mesma TES que calcule PIS/COFINS		
		Else
			cQuery  += " AND SF1.F1_TIPO NOT IN('I', 'P') "	        	//Nao considera NF de Compelementos que utilizam a mesma TES que calcule PIS/COFINS
		EndIF		
		
		If ExistBlock("MT996QRY")
			cQuery := ExecBlock("MT996QRY",.F.,.F.,{cQuery,2})
		EndIf
	
	    If mv_par11 ==1
			cQuery += "ORDER BY D1_CF, D1_DOC, D1_FORNECE" 
		Else
			cQuery += "ORDER BY D1_CF, D1_COD, D1_FORNECE"
		Endif
	
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)
	
		For nX := 1 To len(aStruSD1)
			If aStruSD1[nX][2] <> "C" .And. FieldPos(aStruSD1[nX][1])<>0
				TcSetField(cAliasSD1,aStruSD1[nX][1],aStruSD1[nX][2],aStruSD1[nX][3],aStruSD1[nX][4])
			EndIf
		Next nX
	
		For nX := 1 To len(aStruSB1)
			If aStruSB1[nX][2] <> "C" .And. FieldPos(aStruSB1[nX][1])<>0
				TcSetField(cAliasSB1,aStruSB1[nX][1],aStruSB1[nX][2],aStruSB1[nX][3],aStruSB1[nX][4])
			EndIf
		Next nX
	
		For nX := 1 To len(aStruSF4)
			If aStruSF4[nX][2] <> "C" .And. FieldPos(aStruSF4[nX][1])<>0
				TcSetField(cAliasSF4,aStruSF4[nX][1],aStruSF4[nX][2],aStruSF4[nX][3],aStruSF4[nX][4])
			EndIf
		Next nX
	
		For nX := 1 To len(aStruSF1)
			If aStruSF1[nX][2] <> "C" .And. FieldPos(aStruSF1[nX][1])<>0
				TcSetField(cAliasSF1,aStruSF1[nX][1],aStruSF1[nX][2],aStruSF1[nX][3],aStruSF1[nX][4])
			EndIf
		Next nX                     	
		
		dbSelectArea(cAliasSD1)
		nPsVlPisEn := ( cAliasSD1 )->( FieldPos( cCpVlPisEn ) )
		nPsBsPisEn := ( cAliasSD1 )->( FieldPos( cCpBsPisEn ) )
		nPsAlPisEn := ( cAliasSD1 )->( FieldPos( cCpAlPisEn ) ) 	
		nPsVlCofEn := ( cAliasSD1 )->( FieldPos( cCpVlCofEn ) )
		nPsBsCofEn := ( cAliasSD1 )->( FieldPos( cCpBsCofEn ) ) 	
		nPsAlCofEn := ( cAliasSD1 )->( FieldPos( cCpAlCofEn ) )
	#ELSE
	   cAliasSD1	:= "SD1"
	   cIndex1		:= 'D1_CF'//CriaTrab(NIL,.F.)
		cKey			:= 'D1_CF'
		cCondicao	:= 'D1_FILIAL=="'+xFilial("SD1")+'".And.'
		cCondicao	+= 'DTOS(D1_DTDIGIT)>="'+DTOS(MV_PAR02)+'".And.DTOS(D1_DTDIGIT)<="'+DTOS(MV_PAR03)+'".And.'
		cCondicao	+= '!D1_TIPO$"I#P"'		//Nao considera NF de Compelementos que utilizam a mesma TES que calcule PIS/COFINS
		IndRegua(cAliasSD1,cIndex1,cKey,,cCondicao)
		nIndex := RetIndex("SD1")
		dbSelectArea("SD1")
		dbSetIndex(cIndex1+OrdBagExt())
		 
		dbSetOrder(nIndex+1)
		dbGoTop()
		dbSelectArea(cAliasSD1)
	#ENDIF
	While (cAliasSD1)->(!Eof()) 
		nPautaPIS := 0
		nPautaCOF := 0
		
		If !lQuery
			SF4->(dbSetOrder(1))
			SF4->(MsSeek(xFilial("SF4")+(cAliasSD1)->D1_TES))
			SB1->(dbSetOrder(1))
			SB1->(MsSeek(xFilial("SB1")+(cAliasSD1)->D1_COD))
			SF1->(dbSetOrder(1))
			SF1->(MsSeek(xFilial("SF1")+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_TIPO))
			cB1_GRTRIB := SB1->B1_GRTRIB
		Else                            
			cB1_GRTRIB := (cAliasSB1)->B1_GRTRIB
			//Livro Selecionado
			If !((Empty (MV_PAR05)) .Or. ("*"$MV_PAR05))
				If !(SF3->F3_NRLIVRO==MV_PAR05)
					lValido := .F.
				EndIf
			EndIf
		EndIf        
		//Verifica Cliente/Fornecedor    
		SA1->(dbSetOrder(1))
		SA2->(dbSetOrder(1))		
		If (cAliasSD1)->D1_TIPO$"DB"
			SA1->(MsSeek(xFilial("SA1")+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))
			cCliFor 	:= SA1->A1_NOME
		Else
			SA2->(MsSeek(xFilial("SA2")+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))
			cCliFor 	:= SA2->A2_NOME
		Endif                 
		If (cAliasSF4)->F4_AGREG <> "N"
			If SB1->(FieldPos("B1_PPIS")) >0
				nTxPIS	:= 	Iif((cAliasSB1)->B1_PPIS <> 0,(cAliasSB1)->B1_PPIS , GetMv("MV_TXPIS"))    
			Endif
			If SB1->(FieldPos("B1_REDPIS")) > 0
				nRedPIS	:= 	Iif((cAliasSB1)->B1_REDPIS > 0,1-((cAliasSB1)->B1_REDPIS / 100 ), 1 )
			Endif
			If SB1->(FieldPos("B1_VLR_PIS")) > 0
				nPautaPIS	:= 	Iif((cAliasSD1)->D1_TIPO$"C",0,(cAliasSB1)->B1_VLR_PIS)
			Endif
			If SF4->(FieldPos("F4_BASEPIS")) > 0
				nRedPIS	*= 	Iif((cAliasSF4)->F4_BASEPIS > 0,1-((cAliasSF4)->F4_BASEPIS / 100 ), 1 )
			Endif		
			If SB1->(FieldPos("B1_REDCOF")) > 0
				nRedCOF	:= 	Iif((cAliasSB1)->B1_REDCOF > 0,1-((cAliasSB1)->B1_REDCOF / 100 ), 1 )
			Endif
			If SF4->(FieldPos("F4_BASECOF")) > 0
				nRedCOF	*= 	Iif((cAliasSF4)->F4_BASECOF > 0,1-((cAliasSF4)->F4_BASECOF / 100 ), 1 )
			EndIf
			If SB1->(FieldPos("B1_PCOFINS")) > 0
				nTxCOF	:=	if((cAliasSB1)->B1_PCOFINS <> 0,(cAliasSB1)->B1_PCOFINS , GetMv("MV_TXCOFIN"))
			Endif
			If SB1->(FieldPos("B1_VLR_COF")) > 0
				nPautaCOF	:= 	Iif((cAliasSD1)->D1_TIPO$"C",0,(cAliasSB1)->B1_VLR_COF)
			Endif
			If SF4->(FieldPos("F4_PISCOF")) >0
				If !lApurac .Or. ((cAliasSF4)->F4_PISFISC<>"2")
					If (cAliasSF4)->F4_PISCOF $ "13" //1-PIS,3=Ambos
						If SF4->(FieldPos("F4_PISCRED")) >0	
							nValPisPas := 0
							nBasPisPas := 0
							//Verifica se existem os campos para gravacao do valor/base do PIS  
							If (cAliasSD1)->D1_DTDIGIT >= dDtCorte .And. ;
								!Empty( nPsVlPisEn ) .And. !Empty( nPsBsPisEn ) .And. !Empty( nPsAlPisEn )
								nValPisPas	:= ( cAliasSD1 )->( FieldGet( nPsVlPisEn ) )
								nBasPisPas	:= ( cAliasSD1 )->( FieldGet( nPsBsPisEn ) )
								nTxPIS		:= ( cAliasSD1 )->( FieldGet( nPsAlPisEn ) )
							EndIf
							//Tratamento do Majorado
							If (cAliasSD1)->D1_VALPMAJ > 0
								nValPisPas := nValPisPas - (cAliasSD1)->D1_VALPMAJ
								nTxPIS     := nTxPIS - (cAliasSF4)->F4_MALQPIS
							EndIf 
							If mv_par01 <> 2 .And. mv_par12 == 3 .And. !(cAliasSF4)->F4_TPREG$"123"//PIS e Ambos
								RecLock("TRB",.T.)
								TRB->NUMNF     := (cAliasSD1)->D1_DOC
								TRB->SERIE     := (cAliasSD1)->D1_SERIE
								TRB->EMISSAO   := (cAliasSD1)->D1_DTDIGIT
								TRB->CFOP      := (cAliasSD1)->D1_CF
								TRB->PRODUTO   	:= ALLTRIM((cAliasSD1)->D1_COD)+' - '+ALLTRIM((cAliasSB1)->B1_DESC)
								TRB->NCM       := (cAliasSB1)->B1_POSIPI
								TRB->VALORCONT := CompVlCont(cAliasSD1,(cAliasSF4)->F4_AGREG,(cAliasSF4)->F4_IPI)
								TRB->ZFRANCA   := 0
								TRB->ALIQ      := Iif(nExPis == 0,Iif(nPautaPIS <> 0,nPautaPIS,nTxPIS),nExPis)
								TRB->TIPO      := "PIS"
								TRB->ES        := "E"
								TRB->CLIFOR	   := cCliFor
								TRB->PAUTA		:= Iif(nPautaPIS <> 0,"S","N")
								MsUnlock()
								//Verifica a Data de Corte ( 01/02/2004 )                           
								If (cAliasSD1)->D1_DTDIGIT >= dDtCorte
									RecLock("TRB",.F.)
									If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
										TRB->PISCENT   := nValPisPas
										TRB->BASPICENT := nBasPisPas					
									ElseIf (cAliasSF4)->F4_PISCRED =="2"
										TRB->PISDENT   := nValPisPas
										TRB->BASPIDENT := nBasPisPas					
	                        Endif
									MsUnlock()
								Else			
									RecLock("TRB",.F.)
									If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
										TRB->PISCENT   := ( ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC) * nRedPis) * (TRB->ALIQ/100)
										TRB->BASPICENT := ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC )  * nRedPis
									ElseIf (cAliasSF4)->F4_PISCRED =="2"
										TRB->PISDENT   := ( ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC) * nRedPis) * (TRB->ALIQ/100)
										TRB->BASPIDENT := ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC  ) * nRedPis
	                        Endif
									MsUnlock()
								EndIf				
								//Acumula PIS no Valor Contabil                  
								//Produtos importados devem agregar esses valores
								If SF4->(FieldPos("F4_AGRPIS")) > 0
									If (cAliasSF4)->F4_AGRPIS = "1"
									    RecLock("TRB",.F.)
										If (cAliasSF4)->F4_PISCRED == "1"
									    	TRB->VALORCONT += TRB->PISCENT 
									 	Else                               
									 		TRB->VALORCONT += TRB->PISDENT 
									 	Endif
								    	MsUnlock()
									Endif
								Endif	
							Endif
							If mv_par01 <> 2 .And. mv_par12 == 1 .And. (cAliasSF4)->F4_TPREG$"123" //NAO CUMULATIVO/CUMULATIVO/AMBOS
								RecLock("TRB",.T.)
								TRB->NUMNF     := (cAliasSD1)->D1_DOC
								TRB->SERIE     := (cAliasSD1)->D1_SERIE
								TRB->EMISSAO   := (cAliasSD1)->D1_DTDIGIT
								TRB->CFOP      := (cAliasSD1)->D1_CF
								TRB->PRODUTO   	:= ALLTRIM((cAliasSD1)->D1_COD)+' - '+ALLTRIM((cAliasSB1)->B1_DESC)
								TRB->NCM       := (cAliasSB1)->B1_POSIPI
								TRB->VALORCONT := CompVlCont(cAliasSD1,(cAliasSF4)->F4_AGREG,(cAliasSF4)->F4_IPI)
								TRB->ZFRANCA   := 0
								TRB->ALIQ      := Iif(nExPis == 0,Iif(nPautaPIS <> 0,nPautaPIS,nTxPIS),nExPis)
								TRB->TIPO      := "PIS"
								TRB->ES        := "E"
								TRB->CLIFOR	   := cCliFor
								TRB->PAUTA	   := Iif(nPautaPIS <> 0,"S","N")
								MsUnlock()
								//Verifica a Data de Corte ( 01/02/2004 )                           
								If (cAliasSD1)->D1_DTDIGIT >= dDtCorte
									RecLock("TRB",.F.)
									If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
										TRB->PISCENT   := nValPisPas
										TRB->BASPICENT := nBasPisPas					
									ElseIf (cAliasSF4)->F4_PISCRED =="2"
										TRB->PISDENT   := nValPisPas
										TRB->BASPIDENT := nBasPisPas					
	                        Endif
									MsUnlock()
								Else			
									RecLock("TRB",.F.)
									If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
										TRB->PISCENT   := ( ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC) * nRedPis) * (TRB->ALIQ/100)
										TRB->BASPICENT := ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC )  * nRedPis
									ElseIf (cAliasSF4)->F4_PISCRED =="2"
										TRB->PISDENT   := ( ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC) * nRedPis) * (TRB->ALIQ/100)
										TRB->BASPIDENT := ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC  ) * nRedPis
	                        Endif
									MsUnlock()
								EndIf				
								//Acumula PIS no Valor Contabil                  
								//Produtos importados devem agregar esses valores
								If SF4->(FieldPos("F4_AGRPIS")) > 0
									If (cAliasSF4)->F4_AGRPIS = "1"
										RecLock("TRB",.F.)
										If (cAliasSF4)->F4_PISCRED == "1"
									    	TRB->VALORCONT += TRB->PISCENT 
									 	Else                               
									 		TRB->VALORCONT += TRB->PISDENT 
									 	Endif
								    	MsUnlock()
									Endif
								Endif	
							Endif
							If mv_par01 <> 2 .And. mv_par12 == 2 .And. (cAliasSF4)->F4_TPREG$"1" //NAO CUMULATIVO/CUMULATIVO/AMBOS
								RecLock("TRB",.T.)
								TRB->NUMNF     := (cAliasSD1)->D1_DOC
								TRB->SERIE     := (cAliasSD1)->D1_SERIE
								TRB->EMISSAO   := (cAliasSD1)->D1_DTDIGIT
								TRB->CFOP      := (cAliasSD1)->D1_CF
								TRB->PRODUTO   	:= ALLTRIM((cAliasSD1)->D1_COD)+' - '+ALLTRIM((cAliasSB1)->B1_DESC)
								TRB->NCM       := (cAliasSB1)->B1_POSIPI
								TRB->VALORCONT := CompVlCont(cAliasSD1,(cAliasSF4)->F4_AGREG,(cAliasSF4)->F4_IPI)
								TRB->ZFRANCA   := 0
								TRB->ALIQ      := Iif(nExPis == 0,Iif(nPautaPIS <> 0,nPautaPIS,nTxPIS),nExPis)
								TRB->TIPO      := "PIS"
								TRB->ES        := "E"
								TRB->CLIFOR	   := cCliFor
								TRB->PAUTA	   := Iif(nPautaPIS <> 0,"S","N")
								MsUnlock()
								//Verifica a Data de Corte ( 01/02/2004 )                           
								If (cAliasSD1)->D1_DTDIGIT >= dDtCorte
									RecLock("TRB",.F.)
									If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
										TRB->PISCENT   := nValPisPas
										TRB->BASPICENT := nBasPisPas					
									ElseIf (cAliasSF4)->F4_PISCRED =="2"
										TRB->PISDENT   := nValPisPas
										TRB->BASPIDENT := nBasPisPas					
	                        Endif
									MsUnlock()
								Else			
									RecLock("TRB",.F.)
									If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
										TRB->PISCENT   := ( ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC) * nRedPis) * (TRB->ALIQ/100)
										TRB->BASPICENT := ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC )  * nRedPis
									ElseIf (cAliasSF4)->F4_PISCRED =="2"
										TRB->PISDENT   := ( ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC) * nRedPis) * (TRB->ALIQ/100)
										TRB->BASPIDENT := ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC  ) * nRedPis
	                        Endif
									MsUnlock()
								EndIf				
								//Acumula PIS no Valor Contabil                  
								//Produtos importados devem agregar esses valores
								If SF4->(FieldPos("F4_AGRPIS")) > 0
									If (cAliasSF4)->F4_AGRPIS = "1"
									    RecLock("TRB",.F.)
										If (cAliasSF4)->F4_PISCRED == "1"
									    	TRB->VALORCONT += TRB->PISCENT 
									 	Else                               
									 		TRB->VALORCONT += TRB->PISDENT 
									 	Endif
								    	MsUnlock()
									Endif
								Endif	
							Endif						
						EndIf
					Endif
					If (cAliasSF4)->F4_PISCOF $ "23" .And. mv_par01 <> 1 .And. mv_par12 == 3 .And. !(cAliasSF4)->F4_TPREG$"123"//2-COFINS;3-Ambos
						If SF4->(FieldPos("F4_PISCRED")) >0
							nValCofins := 0 
							nBasCofins := 0 					
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Verifica se existem os campos para gravacao do valor/base da COFINS ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If (cAliasSD1)->D1_DTDIGIT >= dDtCorte .And. ;
								!Empty( nPsVlCofEn ) .And. !Empty( nPsBsCofEn ) .And. !Empty( nPsAlCofEn )
								nValCofins := ( cAliasSD1 )->( FieldGet( nPsVlCofEn ) )
								nBasCofins := ( cAliasSD1 )->( FieldGet( nPsBsCofEn ) )
								nTxCOF := ( cAliasSD1 )->( FieldGet( nPsAlCofEn ) )
								//TRATAMENTO COFINS MAJORADA.
								If SF4->(FieldPos("F4_MALQPIS") > 0)
									If (cAliasSF4)->F4_MALQPIS > 0
										nTxPIS := nTxPIS - (cAliasSF4)->F4_MALQPIS
									EndIf
								EndIf
								If SF4->(FieldPos("F4_MALQCOF") > 0) .And. SD1->(FieldPos("D1_VALCMAJ") > 0)
								    If (cAliasSF4)->F4_MALQCOF > 0
								    	nTxCOF := nTxCOF - (cAliasSF4)->F4_MALQCOF
								    EndIf
								    If (cAliasSD1)->D1_VALCMAJ > 0
								    	nValCofins := nValCofins - (cAliasSD1)->D1_VALCMAJ
								    EndIf
							    EndIf 	
							EndIf							
							RecLock("TRB",.T.)
							TRB->NUMNF     := (cAliasSD1)->D1_DOC
							TRB->SERIE     := (cAliasSD1)->D1_SERIE   
							TRB->EMISSAO   := (cAliasSD1)->D1_DTDIGIT
							TRB->CFOP      := (cAliasSD1)->D1_CF
							TRB->PRODUTO   	:= ALLTRIM((cAliasSD1)->D1_COD)+' - '+ALLTRIM((cAliasSB1)->B1_DESC)
							TRB->NCM       := (cAliasSB1)->B1_POSIPI
							TRB->VALORCONT := CompVlCont(cAliasSD1,(cAliasSF4)->F4_AGREG,(cAliasSF4)->F4_IPI)
							TRB->ZFRANCA   := 0
							TRB->ALIQ      := Iif(nExCof == 0,Iif(nPautaCOF <> 0,nPautaCOF,nTxCOF),nExCof)
							TRB->TIPO      := "COF"
							TRB->ES        := "E"
							TRB->CLIFOR	   := cCliFor	
							TRB->PAUTA	   := Iif(nPautaCOF <> 0,"S","N")
							MsUnlock()
							//Verifica a Data de Corte ( 01/02/2004 )                           
							If (cAliasSD1)->D1_DTDIGIT >= dDtCorte
								RecLock("TRB",.F.)
								If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
									TRB->COFCENT   := nValCofins
									TRB->BASCOCENT := nBasCofins
								ElseIf (cAliasSF4)->F4_PISCRED =="2"
									TRB->COFDENT   := nValCofins
									TRB->BASCODENT := nBasCofins 
	                    Endif
	                    MsUnlock()
							Else
								RecLock("TRB",.F.)
								If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita ;2-Debita
									TRB->COFCENT   := ( ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC )  * nRedCOF) * (TRB->ALIQ/100)
									TRB->BASCOCENT := ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC  ) * nRedCOF
								ElseIf	(cAliasSF4)->F4_PISCRED =="2"
									TRB->COFDENT   := ( ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC )  * nRedCOF) * (TRB->ALIQ/100)
									TRB->BASCODENT := ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC  ) * nRedCOF
								Endif	
								MsUnlock()
							Endif
							//Acumula COFINS no Valor Contabil               
							//Produtos importados devem agregar esses valores
							If SF4->(FieldPos("F4_AGRCOF")) > 0
								If (cAliasSF4)->F4_AGRCOF = "1"
								    RecLock("TRB",.F.)
								    If (cAliasSF4)->F4_PISCRED == "1"
								    	TRB->VALORCONT += TRB->COFCENT
								    Else                              
								    	TRB->VALORCONT += TRB->COFDENT
								    Endif
							    	MsUnlock()
								Endif
							Endif	
						Endif	
					Endif
												
					If (cAliasSF4)->F4_PISCOF $ "23" .And. mv_par01 <> 1 .And. mv_par12 == 1 .And. (cAliasSF4)->F4_TPREG$"123" //NAO CUMULATIVO/CUMULATIVO/AMBOS
						If SF4->(FieldPos("F4_PISCRED")) >0
							nValCofins := 0 
							nBasCofins := 0 					
							//Verifica se existem os campos para gravacao do valor/base da COFINS 
							If (cAliasSD1)->D1_DTDIGIT >= dDtCorte .And. ;
								!Empty( nPsVlCofEn ) .And. !Empty( nPsBsCofEn ) .And. !Empty( nPsAlCofEn )
								nValCofins := ( cAliasSD1 )->( FieldGet( nPsVlCofEn ) )
								nBasCofins := ( cAliasSD1 )->( FieldGet( nPsBsCofEn ) )
								nTxCOF := ( cAliasSD1 )->( FieldGet( nPsAlCofEn ) )
								//TRATAMENTO COFINS MAJORADA.
								If SF4->(FieldPos("F4_MALQPIS") > 0)
									If (cAliasSF4)->F4_MALQPIS > 0
										nTxPIS := nTxPIS - (cAliasSF4)->F4_MALQPIS
									EndIf
								EndIf
								If SF4->(FieldPos("F4_MALQCOF") > 0) .And. SD1->(FieldPos("D1_VALCMAJ") > 0)
								    If (cAliasSF4)->F4_MALQCOF > 0
								    	nTxCOF := nTxCOF - (cAliasSF4)->F4_MALQCOF
								    EndIf
								    If (cAliasSD1)->D1_VALCMAJ > 0
								    	nValCofins := nValCofins - (cAliasSD1)->D1_VALCMAJ
								    EndIf
							    EndIf 
							EndIf							
							RecLock("TRB",.T.)
							TRB->NUMNF     := (cAliasSD1)->D1_DOC
							TRB->SERIE     := (cAliasSD1)->D1_SERIE   
							TRB->EMISSAO   := (cAliasSD1)->D1_DTDIGIT
							TRB->CFOP      := (cAliasSD1)->D1_CF
							TRB->PRODUTO   	:= ALLTRIM((cAliasSD1)->D1_COD)+' - '+ALLTRIM((cAliasSB1)->B1_DESC)
							TRB->NCM       := (cAliasSB1)->B1_POSIPI
							TRB->VALORCONT := CompVlCont(cAliasSD1,(cAliasSF4)->F4_AGREG,(cAliasSF4)->F4_IPI)
							TRB->ZFRANCA   := 0
							TRB->ALIQ      := Iif(nExCof == 0,Iif(nPautaCOF <> 0,nPautaCOF,nTxCOF),nExCof)
							TRB->TIPO      := "COF"
							TRB->ES        := "E"
							TRB->CLIFOR	   := cCliFor	
							TRB->PAUTA	   := Iif(nPautaCOF <> 0,"S","N")
							MsUnlock()
							//Verifica a Data de Corte ( 01/02/2004 )                           
							If (cAliasSD1)->D1_DTDIGIT >= dDtCorte
								RecLock("TRB",.F.)
								If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
									TRB->COFCENT   := nValCofins
									TRB->BASCOCENT := nBasCofins
								ElseIf (cAliasSF4)->F4_PISCRED =="2"
									TRB->COFDENT   := nValCofins
									TRB->BASCODENT := nBasCofins 
	                     Endif
	                     MsUnlock()
							Else
								RecLock("TRB",.F.)
								If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita ;2-Debita
									TRB->COFCENT   := ( ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC )  * nRedCOF) * (TRB->ALIQ/100)
									TRB->BASCOCENT := ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC  ) * nRedCOF
								ElseIf	(cAliasSF4)->F4_PISCRED =="2"
									TRB->COFDENT   := ( ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC )  * nRedCOF) * (TRB->ALIQ/100)
									TRB->BASCODENT := ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC  ) * nRedCOF
								Endif	
								MsUnlock()
							Endif
							//Acumula COFINS no Valor Contabil               
							//Produtos importados devem agregar esses valores
							If SF4->(FieldPos("F4_AGRCOF")) > 0
								If (cAliasSF4)->F4_AGRCOF = "1"
								    RecLock("TRB",.F.)
								    If (cAliasSF4)->F4_PISCRED == "1"
								    	TRB->VALORCONT += TRB->COFCENT
								    Else                              
								    	TRB->VALORCONT += TRB->COFDENT
								    Endif
							    	MsUnlock()
								Endif
							Endif	
						Endif	
					Endif					
					
					If (cAliasSF4)->F4_PISCOF $ "23" .And. mv_par01 <> 1 .And. mv_par12 == 2 .And. (cAliasSF4)->F4_TPREG$"1" //NAO CUMULATIVO/CUMULATIVO/AMBOS
						If SF4->(FieldPos("F4_PISCRED")) >0
							nValCofins := 0 
							nBasCofins := 0 					
							//Verifica se existem os campos para gravacao do valor/base da COFINS
							If (cAliasSD1)->D1_DTDIGIT >= dDtCorte .And. ;
								!Empty( nPsVlCofEn ) .And. !Empty( nPsBsCofEn ) .And. !Empty( nPsAlCofEn )
								nValCofins := ( cAliasSD1 )->( FieldGet( nPsVlCofEn ) )
								nBasCofins := ( cAliasSD1 )->( FieldGet( nPsBsCofEn ) )
								nTxCOF := ( cAliasSD1 )->( FieldGet( nPsAlCofEn ) )
								//TRATAMENTO COFINS MAJORADA.
								If SF4->(FieldPos("F4_MALQPIS") > 0)
									If (cAliasSF4)->F4_MALQPIS > 0
										nTxPIS := nTxPIS - (cAliasSF4)->F4_MALQPIS
									EndIf
								EndIf
								If SF4->(FieldPos("F4_MALQCOF") > 0) .And. SD1->(FieldPos("D1_VALCMAJ") > 0)
								    If (cAliasSF4)->F4_MALQCOF > 0
								    	nTxCOF := nTxCOF - (cAliasSF4)->F4_MALQCOF
								    EndIf
								    If (cAliasSD1)->D1_VALCMAJ > 0
								    	nValCofins := nValCofins - (cAliasSD1)->D1_VALCMAJ
								    EndIf
							    EndIf 
							EndIf							
							RecLock("TRB",.T.)
							TRB->NUMNF     := (cAliasSD1)->D1_DOC
							TRB->SERIE     := (cAliasSD1)->D1_SERIE   
							TRB->EMISSAO   := (cAliasSD1)->D1_DTDIGIT
							TRB->CFOP      := (cAliasSD1)->D1_CF
							TRB->PRODUTO   	:= ALLTRIM((cAliasSD1)->D1_COD)+' - '+ALLTRIM((cAliasSB1)->B1_DESC)
							TRB->NCM       := (cAliasSB1)->B1_POSIPI
							TRB->VALORCONT := CompVlCont(cAliasSD1,(cAliasSF4)->F4_AGREG,(cAliasSF4)->F4_IPI)
							TRB->ZFRANCA   := 0
							TRB->ALIQ      := Iif(nExCof == 0,Iif(nPautaCOF <> 0,nPautaCOF,nTxCOF),nExCof)
							TRB->TIPO      := "COF"
							TRB->ES        := "E"
							TRB->CLIFOR	   := cCliFor	
							TRB->PAUTA	   := Iif(nPautaCOF <> 0,"S","N")
							MsUnlock()
							//Verifica a Data de Corte ( 01/02/2004 )                           
							If (cAliasSD1)->D1_DTDIGIT >= dDtCorte
								RecLock("TRB",.F.)
								If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
									TRB->COFCENT   := nValCofins
									TRB->BASCOCENT := nBasCofins
								ElseIf (cAliasSF4)->F4_PISCRED =="2"
									TRB->COFDENT   := nValCofins
									TRB->BASCODENT := nBasCofins 
	                     	Endif
			               MsUnlock()
							Else
								RecLock("TRB",.F.)
								If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita ;2-Debita
									TRB->COFCENT   := ( ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC )  * nRedCOF) * (TRB->ALIQ/100)
									TRB->BASCOCENT := ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC  ) * nRedCOF
								ElseIf	(cAliasSF4)->F4_PISCRED =="2"
									TRB->COFDENT   := ( ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC )  * nRedCOF) * (TRB->ALIQ/100)
									TRB->BASCODENT := ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC  ) * nRedCOF
								Endif	
								MsUnlock()
							Endif
							//Acumula COFINS no Valor Contabil               
							//Produtos importados devem agregar esses valores
							If SF4->(FieldPos("F4_AGRCOF")) > 0
								If (cAliasSF4)->F4_AGRCOF = "1"
								    RecLock("TRB",.F.)
								    If (cAliasSF4)->F4_PISCRED == "1"
								    	 TRB->VALORCONT += TRB->COFCENT
								    Else                              
								    	 TRB->VALORCONT += TRB->COFDENT
								    Endif
							    	MsUnlock()
								Endif
							Endif	
						Endif	
					Endif				
					//Gera as informacoes para o Resumo -  Entrada 
					If mv_par12 == 3 .And. !((cAliasSF4)->F4_TPREG$"123") .And. !(cAliasSF4)->F4_TPREG$"123"//NAO CUMULATIVO/CUMULATIVO/AMBOS		
						If (cAliasSF4)->F4_PISCOF $ "123" //1-PIS;2-COFINS;3-Ambos					 
							If !(cAliasSD1)->D1_TIPO $ "BD"                           
								If (cAliasSF4)->F4_PISCOF == "1"
							 		nCompTrib += ((cAliasSD1)->D1_TOTAL+IIf(cDebSTPIS=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
								EndIf
								If (cAliasSF4)->F4_PISCOF == "2"
							 		nCompTrib += ((cAliasSD1)->D1_TOTAL+IIf(cDebSTCOF=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
								EndIf
								If (cAliasSF4)->F4_PISCOF == "3"
							 		nCompTrib += ((cAliasSD1)->D1_TOTAL+IIf(cDebSTCOF=="6" .And. cDebSTPIS=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
								EndIf
							EndIf                         						
							If (cAliasSD1)->D1_TIPO == "D" 
								If (cAliasSF4)->F4_PISCOF == "1"
									nDevVendT += ((cAliasSD1)->D1_TOTAL+IIf(cDebSTPIS=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
								EndIf
								If (cAliasSF4)->F4_PISCOF == "2"
									nDevVendT += ((cAliasSD1)->D1_TOTAL+IIf(cDebSTCOF=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
								EndIf
								If (cAliasSF4)->F4_PISCOF == "3"
									nDevVendT += ((cAliasSD1)->D1_TOTAL+IIf(cDebSTCOF=="6" .And. cDebSTPIS=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
								EndIf
							EndIF										
						ELSE		
							If !(cAliasSD1)->D1_TIPO $ "BD" 
								nValComp += ((cAliasSD1)->D1_TOTAL+(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC
							EndIF						
							If (cAliasSD1)->D1_TIPO == "D" 
								nValDevVend += ((cAliasSD1)->D1_TOTAL+(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC
							EndIF		
						EndIf							
					EndIf
					If mv_par12 == 1 .And. (cAliasSF4)->F4_TPREG$"123" //NAO CUMULATIVO/CUMULATIVO/AMBOS		
						If (cAliasSF4)->F4_PISCOF $ "123" //1-PIS;2-COFINS;3-Ambos						 
							If !(cAliasSD1)->D1_TIPO $ "BD"
							 	If (cAliasSF4)->F4_PISCOF == "1" 
							 		nCompTrib += ((cAliasSD1)->D1_TOTAL+IIf(cDebSTPIS=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
								EndIf
							 	If (cAliasSF4)->F4_PISCOF == "2" 
							 		nCompTrib += ((cAliasSD1)->D1_TOTAL+IIf(cDebSTCOF=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
								EndIf
							 	If (cAliasSF4)->F4_PISCOF == "3" 
							 		nCompTrib += ((cAliasSD1)->D1_TOTAL+IIf(cDebSTPIS=="6" .And. cDebSTCOF=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
								EndIf
							EndIf                         							
							If (cAliasSD1)->D1_TIPO == "D" 
							 	If (cAliasSF4)->F4_PISCOF == "1" 
									nDevVendT += ((cAliasSD1)->D1_TOTAL+IIf(cDebSTPIS=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
								EndIf
							 	If (cAliasSF4)->F4_PISCOF == "2" 
									nDevVendT += ((cAliasSD1)->D1_TOTAL+IIf(cDebSTCOF=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
								EndIf
							 	If (cAliasSF4)->F4_PISCOF == "3" 
									nDevVendT += ((cAliasSD1)->D1_TOTAL+IIf(cDebSTPIS=="6" .And. cDebSTCOF=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
								EndIf
							EndIF											
						ELSE		
							If !(cAliasSD1)->D1_TIPO $ "BD" 
								nValComp += ((cAliasSD1)->D1_TOTAL+(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC
							EndIF						
							If (cAliasSD1)->D1_TIPO == "D" 
								nValDevVend += ((cAliasSD1)->D1_TOTAL+(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC
							EndIF		
						EndIf
					EndIf
					
					If mv_par12 == 2 .And. (cAliasSF4)->F4_TPREG$"1" //NAO CUMULATIVO/CUMULATIVO/AMBOS		
						If (cAliasSF4)->F4_PISCOF $ "123" //1-PIS;2-COFINS;3-Ambos						 
							If !(cAliasSD1)->D1_TIPO $ "BD"
							 	If (cAliasSF4)->F4_PISCOF == "1"
							 		nCompTrib += ((cAliasSD1)->D1_TOTAL+IIf(cDebSTPIS=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
								EndIf
							 	If (cAliasSF4)->F4_PISCOF == "2"
							 		nCompTrib += ((cAliasSD1)->D1_TOTAL+IIf(cDebSTCOF=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
								EndIf
							 	If (cAliasSF4)->F4_PISCOF == "3"
							 		nCompTrib += ((cAliasSD1)->D1_TOTAL+IIf(cDebSTPIS=="6" .And. cDebSTCOF=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
								EndIf								
							EndIf                         							
							If (cAliasSD1)->D1_TIPO == "D"     
							 	If (cAliasSF4)->F4_PISCOF == "1"							
									nDevVendT += ((cAliasSD1)->D1_TOTAL+IIf(cDebSTPIS=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
								EndIf
							 	If (cAliasSF4)->F4_PISCOF == "2"							
									nDevVendT += ((cAliasSD1)->D1_TOTAL+IIf(cDebSTCOF=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
								EndIf
							 	If (cAliasSF4)->F4_PISCOF == "3"							
									nDevVendT += ((cAliasSD1)->D1_TOTAL+IIf(cDebSTPIS=="6" .And. cDebSTCOF=="6",0,(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC)
								EndIf																
							EndIF											
						ELSE		
							If !(cAliasSD1)->D1_TIPO $ "BD" 
								nValComp += ((cAliasSD1)->D1_TOTAL+(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC
							EndIF						
							If (cAliasSD1)->D1_TIPO == "D" 
								nValDevVend += ((cAliasSD1)->D1_TOTAL+(cAliasSD1)->D1_ICMSRET+If((cAliasSF4)->F4_IPI=="R",0,If((cAliasSD1)->D1_TIPO=="P",0,(cAliasSD1)->D1_VALIPI))+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC
							EndIF		
						EndIf
					EndIf																	
				EndIf
			EndIf
		EndIf		
		(cAliasSD1)->( dbSkip())
		IncRegua()
	EndDo
	
	If lQuery
		dbSelectArea(cAliasSD1)
		dbCloseArea()
		dbSelectArea("SD1")
	Else
		dbSelectArea("SD1")
		RetIndex("SD1")
		Set Filter to
		Ferase(cIndex1+OrdBagExt())
	EndIf
	//Apura os valores referentes as retencoes                    
	aDedRet := {}
	aDedRet := FsCalRt2(mv_par02,mv_par03,,,2,,@aRet,,.T.,cFilAnt,,lOrgPub)

	dbSelectArea("TRB")
	SetRegua(RecCount())		// Total de Elementos da regua
	dbGoTop()
	
	If (aReturn[8]>=2)
		R906Imp (cArqTemp,@aTAlPISS,@aTAlCOFS,@aTAlPISE,@aTAlCOFE,@aTotApur, aReturn[8])
		lResumo	:=	.T.
	Else
		While !Eof() .And. lContinua	
			IF lEnd
				@Prow()+1,001 PSAY STR0007  //"CANCELADO PELO OPERADOR"
				lContinua := .F.
				Exit
			Endif		
			IncRegua()	
			//Impressao do cabecalho geral
			cTitulo  := STR0002 //"Relatorio - (PIS/COFINS)"
			If mv_par04 == 1
				Cabec1 := STR0022  //" Produto          NCM         Valor Contabil            Zona Franca      Aliquota              Valor da Contribuicao                            Base da Contribuicao              Documento   Serie  Emissao                "
			Else	                                                                                                                                                                                                                                         
				Cabec1 := STR0005  //" Produto          NCM         Valor Contabil            Zona Franca      Aliquota              Valor da Contribuicao                            Base da Contribuicao"
			Endif	
			Cabec2 := STR0006  //"                                                          Desconto                             Debito                 Credito                  Debito                 Credito" 
			nLiAnt	:=	li
			If li > 58
				cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
			EndIf			
			nValCont	:= 0
			nZFranca	:= 0
			nValDebi	:= 0
			nValCred	:= 0
			nBasDebi	:= 0
			nBasCred	:= 0			
			nDValCont	:= 0
			nDZFranca	:= 0
			nDValDebi	:= 0
			nDValCred	:= 0
			nDBasDebi	:= 0
			nDBasCred	:= 0			
			nAcVlrCtb	:= 0
			nAcZfranca	:= 0
			nAcVlrCtbD	:= 0
			nAcVlrCtbC	:= 0
			nAcBsCtbD	:= 0
			nAcBsCtbC	:= 0
			
			IF MV_PAR09==1
				dDT_EMISS	:=	TRB->EMISSAO
			ENDIF

			lEntrada := IIf(Substr(TRB->CFOP,1,1) < "5",.T.,.F.)
			
			If !lFirst    
				@Li, 001 Psay OemToAnsi (STR0008) + SM0->M0_NOMECOM //"Empresa : "
				Li++ 
				@Li, 001 Psay OemToAnsi (STR0021) + Transform(SM0->M0_CGC,"@R 99.999.999/9999-99") //"CNPJ    : "
				Li++ 
				@Li, 001 Psay OemToAnsi (STR0009) + Dtoc(mv_par02) + " - " + Dtoc(mv_par03) //"Periodo : "
				Li := Li + 2
				lFirst := .T.
			Endif
			
			If TRB->TIPO <> cTipo .Or. lQuebra  
				If lQuebra .And. TRB->TIPO <> cTipo .And. !nLiAnt>58
					cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
				Endif
				@Li, 001 PSAY IIf(TRB->TIPO == "PIS",PADC(STR0010+IIf(Substr(TRB->CFOP,1,1) < "5",STR0011,STR0012),Limite),;
			                 PADC(STR0013+IIf(Substr(TRB->CFOP,1,1) < "5",STR0011,STR0012),Limite))
				Li := Li + 2
				cTipo := TRB->TIPO
				lQuebra  := .F.								
				
				@Li, 001 PSAY TRB->CFOP+IIF(SX5->(MsSeek(xFilial("SX5")+"13"+TRB->CFOP))," - "+AllTrim(SX5->X5_DESCRI),"")
				Li++  				
			Else
				If TRB->TIPO == cTipo .And. TRB->CFOP <> cCodCfop 
					@Li, 001 PSAY TRB->CFOP+IIF(SX5->(MsSeek(xFilial("SX5")+"13"+TRB->CFOP))," - "+AllTrim(SX5->X5_DESCRI),"")
					Li++  
				EndIf							
			Endif							
			//Define a quebra para a impressao do relatorio de acordo com escolha nos parametros                                                      
			If mv_par14 == 1
				cQuebra	:=	TRB->TIPO+TRB->CFOP+TRB->CLIFOR
			Elseif mv_par14 == 2
				cQuebra	:=	TRB->TIPO+TRB->CFOP
			Endif
						
			If mv_par14 == 1
				cChave	:=	TRB->TIPO+TRB->CFOP+TRB->CLIFOR
			Elseif mv_par14 == 2
				cChave	:=		TRB->TIPO+TRB->CFOP
			Endif		
			
			While !Eof() .And. cChave == cQuebra				
				If li > 58
					cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
				EndIf    				
				cCodCfop := TRB->CFOP				
				If mv_par04 == 1 .and. mv_par11 <> 1  
					@Li , 001 PSAY TRB->PRODUTO
					@Li , 018 PSAY TRB->NCM
					@Li , 030 PSAY TRB->VALORCONT Picture PesqPict("SD2","D2_TOTAL",14)
					@Li , 050 PSAY TRB->ZFRANCA   Picture PesqPict("SD2","D2_DESCZFR",14)
					@Li , 070 PSAY Transform(TRB->ALIQ,Iif(TRB->PAUTA=="S",PesqPict("SB1","B1_VLR_COF",TamSx3("B1_VLR_COF")[1]),PesqPict("SB1","B1_VLR_COF",TamSx3("B1_VLR_COF")[1])))				
					If Substr(TRB->CFOP,1,1) >= "5"
						@Li , 083 PSAY IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI)     Picture PesqPict("SD2","D2_TOTAL",14)
						@Li , 107 PSAY IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI)     Picture PesqPict("SD2","D2_TOTAL",14)
						@Li , 131 PSAY IIF(TRB->TIPO == "PIS",TRB->BASPIDSAI,TRB->BASCODSAI) Picture PesqPict("SD2","D2_TOTAL",14)
						@Li , 155 PSAY IIF(TRB->TIPO == "PIS",TRB->BASPICSAI,TRB->BASCOCSAI) Picture PesqPict("SD2","D2_TOTAL",14)
					Else	
						@Li , 083 PSAY IIF(TRB->TIPO == "PIS",TRB->PISDENT,TRB->COFDENT)     Picture PesqPict("SD2","D2_TOTAL",14)
						@Li , 107 PSAY IIF(TRB->TIPO == "PIS",TRB->PISCENT,TRB->COFCENT)     Picture PesqPict("SD2","D2_TOTAL",14)
						@Li , 131 PSAY IIF(TRB->TIPO == "PIS",TRB->BASPIDENT,TRB->BASCODENT) Picture PesqPict("SD2","D2_TOTAL",14) 
						@Li , 155 PSAY IIF(TRB->TIPO == "PIS",TRB->BASPICENT,TRB->BASCOCENT) Picture PesqPict("SD2","D2_TOTAL",14)
					Endif					
					@Li , 178 PSAY TRB->NUMNF
					@Li , 189 PSAY TRB->SERIE
					@Li , 194 PSAY TRB->EMISSAO
					@Li , 203 PSAY TRB->CLIFOR				
		      Endif
	         If mv_par11 == 1 
					If mv_par04 == 1  
						nAcVlrCtb += TRB->VALORCONT
						nAcZfranca += TRB->ZFRANCA
						If Substr(TRB->CFOP,1,1) >= "5"
							nAcVlrCtbD += IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI)
							nAcVlrCtbC += IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI) 
							nAcBsCtbD += IIF(TRB->TIPO == "PIS",TRB->BASPIDSAI,TRB->BASCODSAI)
							nAcBsCtbC += IIF(TRB->TIPO == "PIS",TRB->BASPICSAI,TRB->BASCOCSAI)
						Else	
							nAcVlrCtbD += IIF(TRB->TIPO == "PIS",TRB->PISDENT,TRB->COFDENT)   
							nAcVlrCtbC += IIF(TRB->TIPO == "PIS",TRB->PISCENT,TRB->COFCENT)    
							nAcBsCtbD += IIF(TRB->TIPO == "PIS",TRB->BASPIDENT,TRB->BASCODENT) 
							nAcBsCtbC += IIF(TRB->TIPO == "PIS",TRB->BASPICENT,TRB->BASCOCENT) 
						Endif  
						cNumNota :=  TRB->NUMNF
						cSerie   :=  TRB->SERIE
						cEmissao :=  TRB->EMISSAO
						cNcm     :=  TRB->NCM
						cProd    :=  TRB->PRODUTO
						cCliFor  :=  TRB->CLIFOR
			      Endif 
		      EndIf        
				nValCont  += TRB->VALORCONT
				nZFranca  += TRB->ZFRANCA				
				nDValCont += TRB->VALORCONT
				nDZFranca += TRB->ZFRANCA				
				nGValCont += TRB->VALORCONT
				nGZFranca += TRB->ZFRANCA	
		
				If Substr(TRB->CFOP,1,1) >= "5"
					nValDebi += IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI)
					nValCred += IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI)
					nBasDebi += IIF(TRB->TIPO == "PIS",TRB->BASPIDSAI,TRB->BASCODSAI)
					nBasCred += IIF(TRB->TIPO == "PIS",TRB->BASPICSAI,TRB->BASCOCSAI)
					
					nDValDebi += IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI)
					nDValCred += IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI)
					nDBasDebi += IIF(TRB->TIPO == "PIS",TRB->BASPIDSAI,TRB->BASCODSAI)
					nDBasCred += IIF(TRB->TIPO == "PIS",TRB->BASPICSAI,TRB->BASCOCSAI)
	
					nGValDebi += IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI)
					nGValCred += IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI)
					nGBasDebi += IIF(TRB->TIPO == "PIS",TRB->BASPIDSAI,TRB->BASCODSAI)
					nGBasCred += IIF(TRB->TIPO == "PIS",TRB->BASPICSAI,TRB->BASCOCSAI)
					
					nAliqP   := Iif(TRB->PAUTA=="S",0,TRB->ALIQ)
					nPosAliq := Ascan(aAliqs,{|x| x[1]==nAliqP})
					If nPosAliq > 0
						aAliqs[nPosAliq][2]  += IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI)-IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI)
						aAliqs[nPosAliq][3]  += TRB->VALORCONT
						aAliqs[nPosAliq][4]  += TRB->ZFRANCA
						aAliqs[nPosAliq][5]  += IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI)
						aAliqs[nPosAliq][6]  += IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI)
						aAliqs[nPosAliq][7]  += IIF(TRB->TIPO == "PIS",TRB->BASPIDSAI,TRB->BASCODSAI)
						aAliqs[nPosAliq][8]  += IIF(TRB->TIPO == "PIS",TRB->BASPICSAI,TRB->BASCOCSAI)
						If TRB->TIPO == "PIS"
							nAliqP					:= Iif(TRB->PAUTA=="S",0,TRB->ALIQ)
							nPosAliq					:= Ascan(aTAlPISS,{|x| x[1]==nAliqP .AND. X[3]==SM0->M0_CODFIL})
							aTAlPISS[nPosAliq][2]+= TRB->PISDSAI-TRB->PISCSAI
						Else
							nAliqP					:= Iif(TRB->PAUTA=="S",0,TRB->ALIQ)
							nPosAliq					:= Ascan(aTAlCOFS,{|x| x[1]==nAliqP .AND. X[3]==SM0->M0_CODFIL})
							aTAlCOFS[nPosAliq][2]+= TRB->COFDSAI-TRB->COFCSAI
						Endif
					Else
						AADD(aAliqs,{Iif(TRB->PAUTA=="S",0,TRB->ALIQ),;
						              IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI)-IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI),;
						              TRB->VALORCONT,;
						              TRB->ZFRANCA,;
						              IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI),;
						              IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI),;
						              IIF(TRB->TIPO == "PIS",TRB->BASPIDSAI,TRB->BASCODSAI),;
						              IIF(TRB->TIPO == "PIS",TRB->BASPICSAI,TRB->BASCOCSAI),;
						              TRB->PAUTA})
						If TRB->TIPO == "PIS"					              
							AADD(aTAlPISS,{Iif(TRB->PAUTA=="S",0,TRB->ALIQ),TRB->PISDSAI-TRB->PISCSAI,SM0->M0_CODFIL})
						Else                                                       
							AADD(aTAlCOFS,{Iif(TRB->PAUTA=="S",0,TRB->ALIQ),TRB->COFDSAI-TRB->COFCSAI,SM0->M0_CODFIL})
						Endif
					Endif					
					//Acumula a contribuicao por aliquota para impressao do resumo
					nAliqP	:= Iif(TRB->PAUTA=="S",0,TRB->ALIQ)
					nPosAliq := Ascan(aAliqCFGer,{|x| x[1]==nAliqP .And. x[2]==TRB->CFOP})
					If nPosAliq > 0
						aAliqCFGer[nPosAliq][3]  += IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI)-IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI)
						aAliqCFGer[nPosAliq][4]  += TRB->VALORCONT //valor contabil
						aAliqCFGer[nPosAliq][5]  += TRB->ZFRANCA //Desconto Zona Franca
						aAliqCFGer[nPosAliq][6]  += IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI) //contribuicao debito
						aAliqCFGer[nPosAliq][7]  += IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI) //contribuicao credito										
						aAliqCFGer[nPosAliq][8]  += IIF(TRB->TIPO == "PIS",TRB->BASPIDSAI,TRB->BASCODSAI) //base debito
						aAliqCFGer[nPosAliq][9]  += IIF(TRB->TIPO == "PIS",TRB->BASPICSAI,TRB->BASCOCSAI) //base credito																													
					Else 
						AADD(aAliqCFGer,{Iif(TRB->PAUTA=="S",0,TRB->ALIQ),TRB->CFOP,IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI)-IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI),TRB->VALORCONT,TRB->ZFRANCA,IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI),IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI),IIF(TRB->TIPO == "PIS",TRB->BASPIDSAI,TRB->BASCODSAI),IIF(TRB->TIPO == "PIS",TRB->BASPICSAI,TRB->BASCOCSAI)})
					Endif
					//Totalizador do Relatorio por Aliquota + CFOP
					nAliqP 	:= Iif(TRB->PAUTA=="S",0,TRB->ALIQ)
					nPosAliq := aScan(aResAliCF,{|x| x[1]==nAliqP .And. x[2]==TRB->CFOP})
					If nPosAliq == 0
						AADD(aResAliCF,{Iif(TRB->PAUTA=="S",0,TRB->ALIQ),;
							              TRB->CFOP,;
							              IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI)-IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI),;
							              TRB->VALORCONT,;
							              TRB->ZFRANCA,;
							              IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI),;
							              IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI),;
							              IIF(TRB->TIPO == "PIS",TRB->BASPIDSAI,TRB->BASCODSAI),;
						   	           IIF(TRB->TIPO == "PIS",TRB->BASPICSAI,TRB->BASCOCSAI),;
						      	        TRB->PAUTA})
					Else
						aResAliCF[nPosAliq][3]  += IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI)-IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI)
						aResAliCF[nPosAliq][4]  += TRB->VALORCONT
						aResAliCF[nPosAliq][5]  += TRB->ZFRANCA
						aResAliCF[nPosAliq][6]  += IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI)
						aResAliCF[nPosAliq][7]  += IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI)
						aResAliCF[nPosAliq][8]  += IIF(TRB->TIPO == "PIS",TRB->BASPIDSAI,TRB->BASCODSAI)
						aResAliCF[nPosAliq][9]  += IIF(TRB->TIPO == "PIS",TRB->BASPICSAI,TRB->BASCOCSAI)
					Endif
				Else
					nValDebi += IIF(TRB->TIPO == "PIS",TRB->PISDENT,TRB->COFDENT) 
					nValCred += IIF(TRB->TIPO == "PIS",TRB->PISCENT,TRB->COFCENT) 
					nBasDebi += IIF(TRB->TIPO == "PIS",TRB->BASPIDENT,TRB->BASCODENT) 
					nBasCred += IIF(TRB->TIPO == "PIS",TRB->BASPICENT,TRB->BASCOCENT) 
					
					nDValDebi += IIF(TRB->TIPO == "PIS",TRB->PISDENT,TRB->COFDENT) 
					nDValCred += IIF(TRB->TIPO == "PIS",TRB->PISCENT,TRB->COFCENT) 
					nDBasDebi += IIF(TRB->TIPO == "PIS",TRB->BASPIDENT,TRB->BASCODENT) 
					nDBasCred += IIF(TRB->TIPO == "PIS",TRB->BASPICENT,TRB->BASCOCENT)                                                                    
	
					nGValDebi += IIF(TRB->TIPO == "PIS",TRB->PISDENT,TRB->COFDENT) 
					nGValCred += IIF(TRB->TIPO == "PIS",TRB->PISCENT,TRB->COFCENT) 
					nGBasDebi += IIF(TRB->TIPO == "PIS",TRB->BASPIDENT,TRB->BASCODENT) 
					nGBasCred += IIF(TRB->TIPO == "PIS",TRB->BASPICENT,TRB->BASCOCENT) 
		            
					nAliqP 	:= Iif(TRB->PAUTA=="S",0,TRB->ALIQ)
					nPosAliq := Ascan(aAliqs,{|x| x[1]==nAliqP})
					If nPosAliq > 0
						aAliqs[nPosAliq][2]  += IIF(TRB->TIPO == "PIS",TRB->PISDENT,TRB->COFDENT)-IIF(TRB->TIPO == "PIS",TRB->PISCENT,TRB->COFCENT) 
						aAliqs[nPosAliq][3]  += TRB->VALORCONT
						aAliqs[nPosAliq][4]  += TRB->ZFRANCA
						aAliqs[nPosAliq][5]  += IIF(TRB->TIPO == "PIS",TRB->PISDENT,TRB->COFDENT) 
						aAliqs[nPosAliq][6]  += IIF(TRB->TIPO == "PIS",TRB->PISCENT,TRB->COFCENT) 
						aAliqs[nPosAliq][7]  += IIF(TRB->TIPO == "PIS",TRB->BASPIDENT,TRB->BASCODENT) 
						aAliqs[nPosAliq][8]  += IIF(TRB->TIPO == "PIS",TRB->BASPICENT,TRB->BASCOCENT)                                                
						If TRB->TIPO == "PIS"
	  					   nAliqP					:= Iif(TRB->PAUTA=="S",0,TRB->ALIQ)
	  					   nPosAliq					:= Ascan(aTAlPISE,{|x| x[1]==nAliqP .AND. X[3]==SM0->M0_CODFIL})
							aTAlPISE[nPosAliq][2]+= TRB->PISDENT-TRB->PISCENT
						Else
							nAliqP					:= Iif(TRB->PAUTA=="S",0,TRB->ALIQ)
							nPosAliq					:= Ascan(aTAlCOFE,{|x| x[1]==nAliqP .AND. X[3]==SM0->M0_CODFIL})
							aTAlCOFE[nPosAliq][2]+= TRB->COFDENT-TRB->COFCENT
						Endif
					Else
						AADD(aAliqs,{Iif(TRB->PAUTA=="S",0,TRB->ALIQ),;
						             IIF(TRB->TIPO == "PIS",TRB->PISDENT,TRB->COFDENT)-IIF(TRB->TIPO == "PIS",TRB->PISCENT,TRB->COFCENT),;
						             TRB->VALORCONT,;
						             TRB->ZFRANCA,;
						             IIF(TRB->TIPO == "PIS",TRB->PISDENT,TRB->COFDENT),;
						             IIF(TRB->TIPO == "PIS",TRB->PISCENT,TRB->COFCENT),;
						             IIF(TRB->TIPO == "PIS",TRB->BASPIDENT,TRB->BASCODENT),;
						             IIF(TRB->TIPO == "PIS",TRB->BASPICENT,TRB->BASCOCENT),;
						             TRB->PAUTA})
						If TRB->TIPO == "PIS"
							AADD(aTAlPISE,{Iif(TRB->PAUTA=="S",0,TRB->ALIQ),TRB->PISDENT-TRB->PISCENT,SM0->M0_CODFIL})
						Else
							AADD(aTAlCOFE,{Iif(TRB->PAUTA=="S",0,TRB->ALIQ),TRB->COFDENT-TRB->COFCENT,SM0->M0_CODFIL})
						Endif
					Endif
					//Acumula a contribuicao por aliquota para impressao do resumo
					nAliqP	:= Iif(TRB->PAUTA=="S",0,TRB->ALIQ)
					nPosAliq := Ascan(aAliqCFGer,{|x| x[1]==nAliqP .And. x[2]==TRB->CFOP})
					If nPosAliq > 0
						aAliqCFGer[nPosAliq][3]  += IIF(TRB->TIPO == "PIS",TRB->PISDENT,TRB->COFDENT)-IIF(TRB->TIPO == "PIS",TRB->PISCENT,TRB->COFCENT) 
						aAliqCFGer[nPosAliq][4]  += (TRB->VALORCONT * IIF(TRB->ES=="E",-1,1)) //valor contabil
						aAliqCFGer[nPosAliq][5]  += TRB->ZFRANCA //Desconto Zona Franca
						aAliqCFGer[nPosAliq][6]  += IIF(TRB->TIPO == "PIS",TRB->PISDENT,TRB->COFDENT) //contribuicao debito
		 				aAliqCFGer[nPosAliq][7]  += IIF(TRB->TIPO == "PIS",TRB->PISCENT,TRB->COFCENT) //contribuicao credito										
	   				aAliqCFGer[nPosAliq][8]  += IIF(TRB->TIPO == "PIS",TRB->BASPIDENT,TRB->BASCODENT) //base debito
	   				aAliqCFGer[nPosAliq][9]  += IIF(TRB->TIPO == "PIS",TRB->BASPICENT,TRB->BASCOCENT) //base credito						
					Else  
						AADD(aAliqCFGer,{Iif(TRB->PAUTA=="S",0,TRB->ALIQ),TRB->CFOP,IIF(TRB->TIPO == "PIS",TRB->PISDENT,TRB->COFDENT)-IIF(TRB->TIPO == "PIS",TRB->PISCENT,TRB->COFCENT),(TRB->VALORCONT * IIF(TRB->ES=="E",-1,1)),TRB->ZFRANCA,IIF(TRB->TIPO == "PIS",TRB->PISDENT,TRB->COFDENT),IIF(TRB->TIPO == "PIS",TRB->PISCENT,TRB->COFCENT),IIF(TRB->TIPO == "PIS",TRB->BASPIDENT,TRB->BASCODENT),IIF(TRB->TIPO == "PIS",TRB->BASPICENT,TRB->BASCOCENT)})
					Endif
					//Totalizador do Relatorio por Aliquota + CFOP
					nAliqP 	:= Iif(TRB->PAUTA=="S",0,TRB->ALIQ)
					nPosAliq := aScan(aResAliCF,{|x| x[1]==nAliqP .And. x[2]==TRB->CFOP})
					If nPosAliq == 0
						AADD(aResAliCF,{Iif(TRB->PAUTA=="S",0,TRB->ALIQ),;
							             TRB->CFOP,; 
							             IIF(TRB->TIPO == "PIS",TRB->PISDENT,TRB->COFDENT)-IIF(TRB->TIPO == "PIS",TRB->PISCENT,TRB->COFCENT),;
							             TRB->VALORCONT,;
							             TRB->ZFRANCA,;
							             IIF(TRB->TIPO == "PIS",TRB->PISDENT,TRB->COFDENT),;
							             IIF(TRB->TIPO == "PIS",TRB->PISCENT,TRB->COFCENT),;
							             IIF(TRB->TIPO == "PIS",TRB->BASPIDENT,TRB->BASCODENT),;
							             IIF(TRB->TIPO == "PIS",TRB->BASPICENT,TRB->BASCOCENT),;
						   	          TRB->PAUTA})
					Else
						aResAliCF[nPosAliq][3]  += IIF(TRB->TIPO == "PIS",TRB->PISDENT,TRB->COFDENT)-IIF(TRB->TIPO == "PIS",TRB->PISCENT,TRB->COFCENT) 
						aResAliCF[nPosAliq][4]  += TRB->VALORCONT
						aResAliCF[nPosAliq][5]  += TRB->ZFRANCA
						aResAliCF[nPosAliq][6]  += IIF(TRB->TIPO == "PIS",TRB->PISDENT,TRB->COFDENT) 
						aResAliCF[nPosAliq][7]  += IIF(TRB->TIPO == "PIS",TRB->PISCENT,TRB->COFCENT) 
						aResAliCF[nPosAliq][8]  += IIF(TRB->TIPO == "PIS",TRB->BASPIDENT,TRB->BASCODENT) 
						aResAliCF[nPosAliq][9]  += IIF(TRB->TIPO == "PIS",TRB->BASPICENT,TRB->BASCOCENT)                                                
					Endif
				Endif			
				cNumNota	:= TRB->NUMNF
				//Ordena o array por aliquota + CFOP  
				Asort(aResAliCF,,,{|x,y|Str(x[1])+x[2] < Str(y[1])+y[2]})									
				If mv_par04 == 1 .And. mv_par11 <> 1
					Li++
				Endif	
				TRB->(dbSkip())			
				If cNumNota <> TRB->NUMNF .OR. cChave <> cQuebra
					If mv_par11 == 1 .And. mv_par04 == 1
						@Li , 030 PSAY nAcVlrCtb Picture PesqPict("SD2","D2_TOTAL",14)
						@Li , 050 PSAY nAcZfranca  Picture PesqPict("SD2","D2_DESCZFR",14)
			
						@Li , 083 PSAY nAcVlrCtbD Picture PesqPict("SD2","D2_TOTAL",14)
						@Li , 107 PSAY nAcVlrCtbC Picture PesqPict("SD2","D2_TOTAL",14)
						@Li , 131 PSAY nAcBsCtbD Picture PesqPict("SD2","D2_TOTAL",14)
						@Li , 155 PSAY nAcBsCtbC Picture PesqPict("SD2","D2_TOTAL",14)
							
						@Li , 178 PSAY cNumNota
						@Li , 191 PSAY cSerie
						@Li , 196 PSAY cEmissao
						@Li , 205 PSAY cCliFor
	   					Li++   		   				
	   					nAcVlrCtb 	:= 0
						nAcZfranca	:= 0
						nAcVlrCtbD	:= 0
						nAcVlrCtbC	:= 0
						nAcBsCtbD	:= 0
						nAcBsCtbC	:= 0
					EndIf         				
				EndIf
				//
				IF MV_PAR09 ==1
					If  TRB->EMISSAO <> dDT_EMISS .OR. cChave <> cQuebra
						@Li, 001 Psay __PrtThinLine()
						Li++
						@Li, 001 PSAY STR0052//"Total do dia - " 
						TRB->(dbSkip(-1))
						@Li, 016 PSAY TRB->EMISSAO
						@Li, 030 PSAY nDValCont Picture PesqPict("SD2","D2_TOTAL",14)
						@Li, 050 PSAY nDZFranca Picture PesqPict("SD2","D2_DESCZFR",14)
						@Li, 083 PSAY nDValDebi Picture PesqPict("SD2","D2_TOTAL",14)
						@Li, 107 PSAY nDValCred Picture PesqPict("SD2","D2_TOTAL",14)
						@Li, 131 PSAY nDBasDebi Picture PesqPict("SD2","D2_TOTAL",14)
						@Li, 155 PSAY nDBasCred Picture PesqPict("SD2","D2_TOTAL",14)
						Li    	  := Li + 2 					
						nDValCont := 0
						nDZFranca := 0
						nDValDebi := 0
						nDValCred := 0
						nDBasDebi := 0
						nDBasCred := 0
						TRB->(dbSkip())
						dDT_EMISS := TRB->EMISSAO
					EndIf
				ENDIF
				If mv_par14 == 1
					cChave	:=	TRB->TIPO+TRB->CFOP+TRB->CLIFOR
				Elseif mv_par14 == 2
					cChave	:=	TRB->TIPO+TRB->CFOP
				Endif	
				If  cChave <> cQuebra
			    	@Li, 001 Psay __PrtThinLine()
				    Li++
					@Li, 001 PSAY STR0014+Substr(cQuebra,4,4)  //"Total do CFOP - "
					@Li, 030 PSAY nValCont Picture PesqPict("SD2","D2_TOTAL",14)
					@Li, 050 PSAY nZFranca Picture PesqPict("SD2","D2_DESCZFR",14)
					@Li, 083 PSAY nValDebi Picture PesqPict("SD2","D2_TOTAL",14)
					@Li, 107 PSAY nValCred Picture PesqPict("SD2","D2_TOTAL",14)
					@Li, 131 PSAY nBasDebi Picture PesqPict("SD2","D2_TOTAL",14)
					@Li, 155 PSAY nBasCred Picture PesqPict("SD2","D2_TOTAL",14)
					Li := Li + 2 
					TRB->(dbSkip(-1))
					SX5->(DBSETORDER(1))				
					IF SX5->(dbseek(xFILIAL("SX5")+"13"+TRB->CFOP))
						cDesc_CFOP	:=	SX5->X5_DESCRI
					ENDIF
					IF TRB->TIPO=="COF"
						IF TRB->ES=="E"
							AADD(aCFOPCOFE,{TRB->CFOP,nValDebi-nValCred,SM0->M0_CODFIL,nBasDebi-nBasCred,cDesc_CFOP})
						ELSE
					    	AADD(aCFOPCOFS,{TRB->CFOP,nValDebi-nValCred,SM0->M0_CODFIL,nBasDebi-nBasCred,cDesc_CFOP})
						ENDIF
					ELSE
						IF TRB->ES="E"
							AADD(aCFOPPISE,{TRB->CFOP,nValDebi-nValCred,SM0->M0_CODFIL,nBasDebi-nBasCred,cDesc_CFOP})
						ELSE
							AADD(aCFOPPISS,{TRB->CFOP,nValDebi-nValCred,SM0->M0_CODFIL,nBasDebi-nBasCred,cDesc_CFOP})
						ENDIF
					ENDIF	
					TRB->(dbSkip())
				Endif 
				
				If ( (Substr(TRB->CFOP,1,1) >= "5" .And. lEntrada) .Or. TRB->(Eof()) ) .Or. (!lEntrada .And. TRB->(Eof())) .Or. TRB->TIPO <> cTipo
					@Li, 001 Psay __PrtThinLine()
					Li++					
					aSort(aALiqs,,,{|x,y| x[1]>y[1]})
					For nX := 1 To Len(aAliqs)
						aContrAliq	:=	{aALiqs[nX][3], aALiqs[nX][4], aALiqs[nX][5], aALiqs[nX][6], aALiqs[nX][7], aALiqs[nX][8]}
						If Li > 58
							Cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
						EndIf	
						// Imprime, alem do total por aliquota, os CFOPs de cada uma das aliquotas impressas
						If mv_par10 == 1                                   
							nPosAliq := aScan(aResAliCF,{|x| x[1]==aAliqs[nX][1]})
							If nPosAliq > 0
								For nPos := nPosAliq to Len(aResAliCF)
									If aResAliCF[nPos][01] <> aAliqs[nX][1]
										Exit
									Endif
									// Imprime o cabecalho do total por CFOP        
									If nPos == nPosAliq           
										@Li, 001 PSAY STR0053 // "Total por CFOP:"
									Endif
									If Li > 58
										Cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
									EndIf
									@Li, 021 PSAY aResAliCF[nPos][2] 
									@Li, 030 PSAY aResAliCF[nPos][4] Picture PesqPict("SD2","D2_TOTAL",14)
									@Li, 050 PSAY aResAliCF[nPos][5] Picture PesqPict("SD2","D2_DESCZFR",14)
									@Li, 083 PSAY aResAliCF[nPos][6] Picture PesqPict("SD2","D2_TOTAL",14)
									@Li, 107 PSAY aResAliCF[nPos][7] Picture PesqPict("SD2","D2_TOTAL",14)
									@Li, 131 PSAY aResAliCF[nPos][8] Picture PesqPict("SD2","D2_TOTAL",14)
									@Li, 155 PSAY aResAliCF[nPos][9] Picture PesqPict("SD2","D2_TOTAL",14)
									Li++                                                              
								Next
							Endif
						Endif           
						
						If aAliqs[nX][9]=="S"
							aContrAliq	:=	{0,0,0,0,0,0}
							For nXX := nX To Len(aALiqs)
								If aAliqs[nXX][9]=="S" .And. aAliqs[nX][1]==0
									nX				 := nXX
									aContrAliq[1]+= aALiqs[nXX][3]
									aContrAliq[2]+= aALiqs[nXX][4]
									aContrAliq[3]+= aALiqs[nXX][5]
									aContrAliq[4]+= aALiqs[nXX][6]
									aContrAliq[5]+= aALiqs[nXX][7]
									aContrAliq[6]+= aALiqs[nXX][8]
								Else
									Exit
								EndIf
							Next nXX
						EndIf
												
						@Li, 001 PSAY STR0031+Transform(aAliqs[nX][1],"@E 99.99%") //"Total da Aliquota "
						@Li, 030 PSAY aContrAliq[1] Picture PesqPict("SD2","D2_TOTAL",14)
						@Li, 050 PSAY aContrAliq[2] Picture PesqPict("SD2","D2_DESCZFR",14)
						@Li, 083 PSAY aContrAliq[3] Picture PesqPict("SD2","D2_TOTAL",14)
						@Li, 107 PSAY aContrAliq[4] Picture PesqPict("SD2","D2_TOTAL",14)
						@Li, 131 PSAY aContrAliq[5] Picture PesqPict("SD2","D2_TOTAL",14)
						@Li, 155 PSAY aContrAliq[6] Picture PesqPict("SD2","D2_TOTAL",14)
						Li += 2    
					Next
					//@Li, 001 Psay __PrtThinLine()
					Li++
					@Li, 001 PSAY STR0015+IIF(lEntrada,STR0016,STR0017) //"Total de " + "Entradas","Saidas"
					@Li, 030 PSAY nGValCont Picture PesqPict("SD2","D2_TOTAL",14)
					@Li, 050 PSAY nGZFranca Picture PesqPict("SD2","D2_DESCZFR",14)
					@Li, 083 PSAY nGValDebi Picture PesqPict("SD2","D2_TOTAL",14)
					@Li, 107 PSAY nGValCred Picture PesqPict("SD2","D2_TOTAL",14)
					@Li, 131 PSAY nGBasDebi Picture PesqPict("SD2","D2_TOTAL",14)
					@Li, 155 PSAY nGBasCred Picture PesqPict("SD2","D2_TOTAL",14)
					Li				:= Li + 3 					
					nValContri	+= nGValDebi-nGValCred
					nAliq			:= 0   
					nContrAli	:= 0
					For nCt := 1 To len(aContrAliq)
   					aContrAliq[nCt] := 0
					Next nCt   
					
					If TRB->TIPO <> cTipo 					
						@Li, 001 Psay Repli("-",Limite)
						Li++
						@Li, 001 Psay STR0032 //"Contribuicao : "
						Li++
						Li++ 	
						//Ordena o array por aliquota + CFOP  
						Asort(aAliqCFGer,,,{|x,y|Str(x[1])+x[2] < Str(y[1])+y[2]})						
						// Imprime o valor apurado por aliquota ou por aliquota + cfop
						For nX := 1 To Len(aAliqCFGer)						                              			
							If Li > 58
								Cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
							EndIf							
							If nAliq <> aAliqCFGer[nX][1] 						
								If nX <> 1
									@Li, 001 PSAY STR0047 + Space(04) 
									@Li, 011 PSAY Transform(Abs(nContrAli),PesqPict("SD2","D2_TOTAL",14))+IIf(nContrAli<0,"  (C)","  (D)")+Transform(Abs(aContrAliq[1]),PesqPict("SD2","D2_TOTAL",14))+Space(6)+Transform(Abs(aContrAliq[2]),PesqPict("SD2","D2_DESCZFR",14))+Space(19)+Transform(Abs(aContrAliq[3]),PesqPict("SD2","D2_TOTAL",14))+;
												     Space(10)+Transform(Abs(aContrAliq[4]),PesqPict("SD2","D2_TOTAL",14))+Space(10)+Transform(Abs(aContrAliq[5]),PesqPict("SD2","D2_TOTAL",14))+Space(10)+Transform(Abs(aContrAliq[6]),PesqPict("SD2","D2_TOTAL",14))									
									Li			+= 2
									nContrAli:= 0    
									For nCt:=1 To len(aContrAliq)
				   					aContrAliq[nCt] := 0
									Next 
								Endif
								@Li, 001 PSAY STR0029 + Transform(aAliqCFGer[nX][1],PesqPict("SB1","B1_VLR_COF",TamSx3("B1_VLR_COF")[1]))
								Li++  
								If mv_par10 == 1
									@Li, 001 PSAY STR0054
									Li++
								Endif
								nAliq	:= aAliqCFGer[nX][1]
							Endif							 
							If mv_par10 == 1
								@Li, 001 PSAY aAliqCFGer[nX][2]+Space(06)+Transform(Abs(aAliqCFGer[nX][3]),PesqPict("SD2","D2_TOTAL",14))+IIf(aAliqCFGer[nX][3]<0,"  (C)","  (D)")+Transform(Abs(aAliqCFGer[nX][4]),PesqPict("SD2","D2_TOTAL",14))+Space(6)+Transform(Abs(aAliqCFGer[nX][5]),PesqPict("SD2","D2_DESCZFR",14))+Space(19)+Transform(Abs(aAliqCFGer[nX][6]),PesqPict("SD2","D2_TOTAL",14))+;
												  Space(10)+Transform(Abs(aAliqCFGer[nX][7]),PesqPict("SD2","D2_TOTAL",14))+Space(10)+Transform(Abs(aAliqCFGer[nX][8]),PesqPict("SD2","D2_TOTAL",14))+Space(10)+Transform(Abs(aAliqCFGer[nX][9]),PesqPict("SD2","D2_TOTAL",14))
								Li++                                                                                                                                                                                                                              
							Endif             
							nContrAli	 += aAliqCFGer[nX][3]              
							aContrAliq[1]+= aAliqCFGer[nX][4] 
							aContrAliq[2]+= aAliqCFGer[nX][5] 
							aContrAliq[3]+= aAliqCFGer[nX][6]
							aContrAliq[4]+= aAliqCFGer[nX][7] 
							aContrAliq[5]+= aAliqCFGer[nX][8] 
							aContrAliq[6]+= aAliqCFGer[nX][9]
							aValContri[1]+= aAliqCFGer[nX][4] 
							aValContri[2]+= aAliqCFGer[nX][5] 
							aValContri[3]+= aAliqCFGer[nX][6]
							aValContri[4]+= aAliqCFGer[nX][7] 
							aValContri[5]+= aAliqCFGer[nX][8] 
							aValContri[6]+= aAliqCFGer[nX][9]
						Next
						@Li, 001 PSAY STR0047 + Space(04) + Transform(Abs(nContrAli),PesqPict("SD2","D2_TOTAL",14)) + IIf(nContrAli < 0,"  (C)","  (D)")+ Transform(Abs(aContrAliq[1]),PesqPict("SD2","D2_TOTAL",14)) + Space(6)+  Transform(Abs(aContrAliq[2]),PesqPict("SD2","D2_DESCZFR",14))+ Space(19)+ Transform(Abs(aContrAliq[3]),PesqPict("SD2","D2_TOTAL",14))+;
										  Space(10) +  Transform(Abs(aContrAliq[4]),PesqPict("SD2","D2_TOTAL",14)) + Space(10)+  Transform(Abs(aContrAliq[5]),PesqPict("SD2","D2_TOTAL",14)) + Space(10)+  Transform(Abs(aContrAliq[6]),PesqPict("SD2","D2_TOTAL",14))
						Li += 2						//"Total Contribuicao ............: "
						@Li, 001 PSAY STR0039
						Li++
						@Li, 011 PSAY Transform(Abs(nValContri),PesqPict("SD2","D2_TOTAL",14)) +  IIf(nValContri < 0,"  (C)","  (D)") + Transform(Abs(aValContri[1]),PesqPict("SD2","D2_TOTAL",14)) + Space(6)+  Transform(Abs(aValContri[2]),PesqPict("SD2","D2_DESCZFR",14))+ Space(19)+ Transform(Abs(aValContri[3]),PesqPict("SD2","D2_TOTAL",14))+;
						              Space(10) +  Transform(Abs(aValContri[4]),PesqPict("SD2","D2_TOTAL",14)) + Space(10)+  Transform(Abs(aValContri[5]),PesqPict("SD2","D2_TOTAL",14)) + Space(10)+  Transform(Abs(aValContri[6]),PesqPict("SD2","D2_TOTAL",14)) //"Total Apurado............: " 						
						Li++                         
						Li++                         
						@Li, 001 PSAY STR0143 //"Total de Retenção(Modalidade da Dedução: Vencimento)........: " --> Empresas que nao sao de Direito Publico
						Li++
						@Li, 011 PSAY Transform(IIF(cTipo=="PIS",aRet[1],aRet[2]),PesqPict("SD2","D2_TOTAL",14))
						Li++
						Li++ 
						@Li, 001 PSAY STR0144 //"Total de Retenção - Orgãos Públicos(Modalidade da Dedução: Pagamento)........: "
						Li++
						@Li, 011 PSAY Transform(IIF(cTipo=="PIS" .And. lOrgPub,(aDedRet[1]-aRet[1]),IIF(lOrgPub,(aDedRet[2]-aRet[2]),0)),PesqPict("SD2","D2_TOTAL",14))
						Li++          
						Li++  
						nContrAli := IIF(cTipo=="PIS",nValContri-aDedRet[1],nValContri-aDedRet[2])
						@Li, 001 PSAY STR0018
						Li++
						@Li, 011 PSAY Transform(IIF(cTipo=="PIS",Abs(nValContri-aDedRet[1]),Abs(nValContri-aDedRet[2])),PesqPict("SD2","D2_TOTAL",14)) + IIf(nValContri < 0,"  (C)","  (D)") + Transform(Abs(aValContri[1]),PesqPict("SD2","D2_TOTAL",14)) + Space(6)+  Transform(Abs(aValContri[2]),PesqPict("SD2","D2_DESCZFR",14))+ Space(19)+ Transform(Abs(aValContri[3]),PesqPict("SD2","D2_TOTAL",14))+;
						              Space(10) +  Transform(Abs(aValContri[4]),PesqPict("SD2","D2_TOTAL",14)) + Space(10)+  Transform(Abs(aValContri[5]),PesqPict("SD2","D2_TOTAL",14)) + Space(10)+  Transform(Abs(aValContri[6]),PesqPict("SD2","D2_TOTAL",14))//"Total da Contribuicao : "
						Li += 2
						@Li, 001 PSAY STR0055
						//Totalizadores da impressao por filial
						If cTipo == "PIS"
							aTotApur[01][01]  += nValContri
							aTotApur[01][02]  += aDedRet[1]
							aTotApur[01][03]  += nValContri-aDedRet[1]
						Else
							aTotApur[02][01]  += nValContri
							aTotApur[02][02]  += aDedRet[2]
							aTotApur[02][03]  += nValContri-aDedRet[2]
						Endif
						nValContri	:= 0
						aAliqs 		:= {} 
						aResAliCF 	:= {}    
						aAliqCFGer	:= {}
						For nCt:=1 To len(aValContri)
							aValContri[nCt] := 0
						Next nCt 						 												
						Li++
					Else
						aAliqs 		:= {} 
						aResAliCF 	:= {}    
					Endif			        
					lEntrada  := .F.
			    	lQuebra   := .T.					
					nGValCont := 0  
					nGZFranca := 0
					nGValDebi := 0
					nGValCred := 0
					nGBasDebi := 0
					nGBasCred := 0 																		
				Endif
				If mv_par14 == 1
					cChave	:=	TRB->TIPO+TRB->CFOP+TRB->CLIFOR
				Elseif mv_par14 == 2
					cChave	:=		TRB->TIPO+TRB->CFOP
				Endif                               							
			EndDo
			lResumo:= .T.	
		EndDo	
	EndIf          
	
	If mv_par12 == 1
		cArqCp := AllTrim(strzero(month(mv_par02),2)+substr(strzero(year(mv_par02),4),3,2)+SM0->M0_CODIGO+SM0->M0_CODFIL)+".CNC"
	Else
		cArqCp := AllTrim(strzero(month(mv_par02),2)+substr(strzero(year(mv_par02),4),3,2)+SM0->M0_CODIGO+SM0->M0_CODFIL)+".CP"
   	EndIf		
   	
	If File(cArqCp)
		cTitulo := STR0019  //"Informacoes Complementares da Apuracao"
		cabec1  := STR0020  //" Descricao                                                                            Valores"
		cabec2  := ""
		cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)		
		cContArq	:=	MemoRead(cArqCp)
		For nContCp :=1 to MlCount(cContArq,100)
		    cLinArq := MemoLine(cContArq,100,nContCp)
			@Li, 001 PSAY Substr(cLinArq,01,70)
			@Li, 071 PSAY Val(Substr(cLinArq,71,14)) Picture PesqPict("SD2","D2_TOTAL",14)
	       Li++
	      IF nContCp2 == 60
	      cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
	      nContCp2 := 0
	      EndIf
	      nContCp2++
		Next
		lResumo:= .T.	
	Endif            
	
	If lResumo .And. TRB->(LastRec()) > 0
		cTitulo := STR0023 // "Resumo"
		cabec1  := STR0024 // "Valores para Calculo              Tributado           Outros            Total"
		cabec2  := "" 
		cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
		@Li,   001 PSAY STR0025+Transform(nVendTrib,PesqPict("SD2","D2_TOTAL",17))+Transform(nValVend,PesqPict("SD2","D2_TOTAL",17))+Transform(nVendTrib+nValVend,PesqPict("SD2","D2_TOTAL",17))  // "Saídas                   "
		@Li+1, 001 PSAY STR0026+Transform(nDevCompT,PesqPict("SD2","D2_TOTAL",17))+Transform(nValDevComp,PesqPict("SD2","D2_TOTAL",17))+Transform(nDevCompT+nValDevComp,PesqPict("SD2","D2_TOTAL",17)) // "Devoluções de Saídas     "
		@Li+2, 001 PSAY STR0027+Transform(nCompTrib,PesqPict("SD2","D2_TOTAL",17))+Transform(nValComp,PesqPict("SD2","D2_TOTAL",17))+Transform(nCompTrib+nValComp,PesqPict("SD2","D2_TOTAL",17))// "Entradas                 "
		@Li+3, 001 PSAY STR0028+Transform(nDevVendT,PesqPict("SD2","D2_TOTAL",17))+Transform(nValDevVend,PesqPict("SD2","D2_TOTAL",17))+Transform(nDevVendT+nValDevVend,PesqPict("SD2","D2_TOTAL",17)) // "Devoluções de Entradas   "
		aTotSai[01]		+= nVendTrib 
		aTotSai[02]		+= nValVend
		aTotSai[03]		+= nVendTrib + nValVend
		aTotDevS[01]	+= nDevCompT
		aTotDevS[02]	+= nValDevComp
		aTotDevS[03]	+= nDevCompT + nValDevComp
		aTotEnt[01] 	+= nCompTrib
		aTotEnt[02] 	+= nValComp
		aTotEnt[03] 	+= nCompTrib + nValComp
		aTotDevE[01] 	+= nDevVendT
		aTotDevE[02] 	+= nValDevVend
		aTotDevE[03] 	+= nDevVendT + nValDevVend
	EndIf
	
	SM0->(dbSkip())
	//Zera todas as variaveis de acumulacao (caso haja a necessidade de imprimir mais de uma filial)
	cQuebra    	:= ""
	cTipo      	:= ""
	aPIS		:= {}
	aCOFINS	  	:= {}
	aTotaisPIS 	:= Array(8)
	aTotaisCOF 	:= Array(8) 
	nPos		:= 0
	nX			:= 0
	nRedPis	  	:= 1
	nRedCOF	  	:= 1
	nValPisPas 	:= 0
	nBasPisPas 	:= 0
	nPosCofins 	:= 0 
	nValCofins 	:= 0 
	nBasCofins 	:= 0 
	nScanPis   	:= 0
	nScanCof   	:= 0  
	nTxPis     	:= 0
	nTxCof     	:= 0
	nCredPis   	:= 0
	nCredCof   	:= 0
	nValCont   	:= 0
	nZFranca   	:= 0
	nValDebi   	:= 0
	nValCred   	:= 0
	nBasDebi   	:= 0
	nBasCred   	:= 0
	nGValCont  	:= 0
	nGZFranca  	:= 0
	nGValDebi  	:= 0
	nGValCred  	:= 0
	nGBasDebi  	:= 0
	nGBasCred  	:= 0
	nValContri 	:= 0
	nContCp    	:= 0
	nExPis      := 0
	nExCof      := 0
	lRet       	:= .F.
	lContinua  	:= .T.
	lEntrada   	:= .F.
	lQuebra    	:= .F.
	lFirst     	:= .F.
	nValDevVend := 0
	nValComp    := 0
	nValVend    := 0 
	nValDevComp := 0
	nVendTrib	:= 0
	nDevCompT   := 0
	nCompTrib   := 0
	nDevVendT   := 0 
	aAliqs 	  	:= {}
	nPosAliq    := 0
	aDedRet     := {0,0}
	cbtxt      	:= Space(10)
	cbcont     	:= 00
	li         	:= 80
	aResAliCF 	:= {}    
	aAliqCFGer	:= {}      
	For nCt := 1 To len(aValContri)
		aValContri[nCt] := 0
	Next nCt 	
	//Deleta o temporario a cada filial processada
	dbSelectArea("TRB")
	dbCloseArea()
	Ferase(cArqTemp+GetDBExtension())
	Ferase(cArqTemp+OrdBagExt())
Enddo
//Volta a empresa anteriormente selecionada.
DbSelectArea("SM0")       
SM0->(DbGoTop())
SM0->(dbSeek(cEmpAnt+cFilOri,.T.))
cFilAnt := cFilOri
//Imprime o total processado de todas as filiais.
If mv_par06 == 1
	cTitulo := STR0041 // "Resumo Geral - Totalizacao das Filiais"
	cabec1  := ""
	cabec2  := "" 
	cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
	//Resumo totalizador de filiais - COFINS
	@Li,001 Psay Repli("-",Limite)
	Li++ 
	@Li,001 Psay PADC(STR0013,Limite)
	Li++ 	
	@Li,001 Psay Repli("-",Limite)
	Li++ 
	//Resumo por CFOP - COFINS - ENTRADAS    
	@Li,001 Psay STR0048//"RESUMO POR CFOP PROCESSADO - ENTRADAS"
	Li++ 
	@Li,001 Psay Repli("-",Limite)                        
	Li++ 
	@Li,001 Psay STR0049//"CFOP             Descrição"
	Li++
	@Li,001 Psay STR0051//"        Filial               Base da Contribuição     Valor da Contribuição"
	Li++
	@Li,001 Psay Repli("-",Limite)                        	
	Li++	
	nTotal 	:= 0
	nTot_emp := 0		
	aCFOPCOFE:= aSORT(aCFOPCOFE,,,{|X,Y|X[1]+X[3]<Y[1]+Y[3]}) 
   For nX := 1 To Len(aCFOPCOFE)
		@Li,001 Psay aCFOPCOFE[nX][1]
	    @Li,018 Psay aCFOPCOFE[nX][5]
	    Li++
	    cCFOP  :=aCFOPCOFE[nX][1]
	    WHILE aCFOPCOFE[nX][1]==cCFOP
			If Li > 58
				Cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
			EndIf          
			@LI,013 PSAY aCFOPCOFE[nX][3]
			@Li,033 Psay Transform(Abs(aCFOPCOFE[nX][4]),PesqPict("SD2","D2_TOTAL",17))
			@Li,059 Psay Transform(Abs(aCFOPCOFE[nX][2]),PesqPict("SD2","D2_TOTAL",17))
			nTotal 	 += Abs(aCFOPCOFE[nX][2])
			nTot_emp += Abs(aCFOPCOFE[nX][4])
			Li++
			nX++
			IF nX>Len(aCFOPCOFE)
				EXIT
			ENDIF
		END
	   nX--
		@Li,033 Psay Transform(nTot_emp,PesqPict("SD2","D2_TOTAL",17))
		@Li,059 Psay Transform(nTotal,PesqPict("SD2","D2_TOTAL",17))
		Li+=2
		If Li > 58
			Cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
		EndIf
		nTotal 	:= 0
		nTot_emp := 0     
	Next  
	If Li > 58
		Cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
	EndIf
	//Resumo por CFOP - COFINS - SAIDAS      
	@Li,001 Psay Repli("-",Limite)
	Li++ 
	@Li,001 Psay STR0050//"RESUMO POR CFOP PROCESSADO - SAIDAS"
	Li++ 
	@Li,001 Psay Repli("-",Limite)                        
	Li++ 
	@Li,001 Psay STR0049//"CFOP             Descrição"
	Li++
	@Li,001 Psay STR0051//"        Filial               Base da Contribuição     Valor da Contribuição"
	Li++ 
	@Li,001 Psay Repli("-",Limite)                        	
	Li++ 
	nTotal 	 := 0
	nTot_emp  := 0
	aCFOPCOFS := aSORT(aCFOPCOFS,,,{|X,Y|X[1]+X[3]<Y[1]+Y[3]})
	For nX := 1 To Len(aCFOPCOFS)
 	    @Li,001 Psay aCFOPCOFS[nX][1]
	    @Li,018 Psay aCFOPCOFS[nX][5]
	    Li++
	  	 cCFOP  := aCFOPCOFS[nX][1]
	    WHILE aCFOPCOFS[nX][1]==cCFOP 
			If Li > 58
				Cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
			EndIf          
			@LI,013 PSAY aCFOPCOFS[nX][3]
			@Li,033 Psay Transform(Abs(aCFOPCOFS[nX][4]),PesqPict("SD2","D2_TOTAL",17))
			@Li,059 Psay Transform(Abs(aCFOPCOFS[nX][2]),PesqPict("SD2","D2_TOTAL",17))
			nTotal 	+= Abs(aCFOPCOFS[nX][2])
			nTot_emp += Abs(aCFOPCOFS[nX][4])
			Li++
			nX++
			IF nX>Len(aCFOPCOFS)
				EXIT
			ENDIF
		END
	    nX--
		@Li,003 Psay STR0047 // "Total:"
		@Li,033 Psay Transform(nTot_emp,PesqPict("SD2","D2_TOTAL",17))
		@Li,059 Psay Transform(nTotal,PesqPict("SD2","D2_TOTAL",17))
		Li+=2
		If Li > 58
			Cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
		EndIf
		nTotal 	:= 0      
		nTot_emp := 0 
	Next
	If Li > 58
		Cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
	EndIf
	//Resumo por aliquota - COFINS - ENTRADAS
	@Li,001 Psay STR0043 // "RESUMO POR ALIQUOTA PROCESSADA - ENTRADAS"
	Li++ 
	@Li,001 Psay Repli("-",Limite)                        
	Li++ 
	@Li,001 Psay STR0044 //Filial  Aliquota                    Valor
	Li++ 
	@Li,001 Psay Repli("-",Limite)                        	
	Li++ 
	For nX := 1 To Len(aTAlCOFE)
		If Li > 58
			Cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
		EndIf          
		@li,005 Psay aTAlCOFE[nX][3]
		@Li,011 Psay Transform(aTAlCOFE[nX][1],PesqPict("SB1","B1_VLR_COF",TamSx3("B1_VLR_COF")[1]))
		@Li,026 Psay Transform(Abs(aTAlCOFE[nX][2]),PesqPict("SD2","D2_TOTAL",17))
		nTotal += Abs(aTAlCOFE[nX][2])
		Li++
	Next  
	@Li,003 Psay STR0047 // "Total:"
	@Li,026 Psay Transform(nTotal,PesqPict("SD2","D2_TOTAL",17))
	Li++	
	If Li > 58
		Cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
	EndIf      
	//Resumo por aliquota - COFINS - SAIDAS  
	@Li,001 Psay Repli("-",Limite)
	Li++ 
	@Li,001 Psay STR0046 // "RESUMO POR ALIQUOTA PROCESSADA - SAIDAS"
	Li++ 
	@Li,001 Psay Repli("-",Limite)                        
	Li++ 
	@Li,001 Psay STR0044 //Filial  Aliquota                    Valor
	Li++ 
	@Li,001 Psay Repli("-",Limite)                        	
	Li++ 
	nTotal := 0
	For nX := 1 To Len(aTAlCOFS)
		If Li > 58
			Cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
		EndIf          
		@Li,005 Psay aTAlCOFS[nX][3]
		@Li,011 Psay Transform(aTAlCOFS[nX][1],PesqPict("SB1","B1_VLR_COF",TamSx3("B1_VLR_COF")[1]))
		@Li,026 Psay Transform(Abs(aTAlCOFS[nX][2]),PesqPict("SD2","D2_TOTAL",17))
		nTotal += Abs(aTAlCOFS[nX][2])
		Li++
	Next  
	@Li,003 Psay STR0047 // "Total:"
	@Li,026 Psay Transform(nTotal,PesqPict("SD2","D2_TOTAL",17))
	Li++
	If Li > 58
		Cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
	EndIf          
	//Resumo apurado - COFINS
	@Li,001 Psay Repli("-",Limite)
	Li++ 
	@Li,001 Psay STR0045 // "RESUMO APURADO"
	Li++ 
	@Li,001 Psay Repli("-",Limite)                        
	Li++ 
	@Li,001 PSAY STR0039
	Li++
	@Li,011 PSAY Transform(Abs(aTotApur[02][01]),PesqPict("SD2","D2_TOTAL",14)) + IIf(aTotApur[02][01] < 0,"  (C)","  (D)") + Transform(Abs(aValContri[1]),PesqPict("SD2","D2_TOTAL",14)) + Space(6)+  Transform(Abs(aValContri[2]),PesqPict("SD2","D2_DESCZFR",14))+ Space(19)+ Transform(Abs(aValContri[3]),PesqPict("SD2","D2_TOTAL",14))+;
					 Space(10) + Transform(Abs(aValContri[4]),PesqPict("SD2","D2_TOTAL",14)) + Space(10)+  Transform(Abs(aValContri[5]),PesqPict("SD2","D2_TOTAL",14)) + Space(10)+  Transform(Abs(aValContri[6]),PesqPict("SD2","D2_TOTAL",14)) //"Total Apurado............: "
	Li++ 
	@Li,001 PSAY STR0040
	Li++
	@Li,011 PSAY Transform(aTotApur[02][02],PesqPict("SD2","D2_TOTAL",14)) //"Total de Retencao........: "
	Li++          
	@Li,001 PSAY STR0018
	Li++
	@Li,011 PSAY Transform(Abs(aTotApur[02][03]),PesqPict("SD2","D2_TOTAL",14)) + IIf(aTotApur[02][03] < 0,"  (C)","  (D)") + Transform(Abs(aValContri[1]),PesqPict("SD2","D2_TOTAL",14)) + Space(6)+  Transform(Abs(aValContri[2]),PesqPict("SD2","D2_DESCZFR",14))+ Space(19)+ Transform(Abs(aValContri[3]),PesqPict("SD2","D2_TOTAL",14))+;
			       Space(10) + Transform(Abs(aValContri[4]),PesqPict("SD2","D2_TOTAL",14)) + Space(10)+  Transform(Abs(aValContri[5]),PesqPict("SD2","D2_TOTAL",14)) + Space(10)+  Transform(Abs(aValContri[6]),PesqPict("SD2","D2_TOTAL",14)) //"Total da Contribuicao : "
	Li++
	If Li > 58
		Cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
	EndIf      
	//Resumo totalizador de filiais - PIS   
	@Li,001 Psay Repli("-",Limite)
	Li++ 
	@Li,001 Psay PADC(STR0010,Limite)
	Li++ 	
	@Li,001 Psay Repli("-",Limite)
	Li++ 
	//Resumo por CFOP - PIS - ENTRADAS       
	@Li,001 Psay STR0048//"RESUMO POR CFOP PROCESSADO - ENTRADAS"
	Li++ 
	@Li,001 Psay Repli("-",Limite)                        
	Li++ 
	@Li,001 Psay STR0049//"CFOP             Descrição"
	Li++
	@Li,001 Psay STR0051//"        Filial               Base da Contribuição     Valor da Contribuição"
	Li++ 
	@Li,001 Psay Repli("-",Limite)                        	
	Li++ 
  	nTotal	 := 0
  	nTot_emp  := 0   	      
  	aCFOPPISE := aSORT(aCFOPPISE,,,{|X,Y|X[1]+X[3]<Y[1]+Y[3]})
   For nX := 1 To Len(aCFOPPISE)
	    @Li,001 Psay aCFOPPISE[nX][1]
	    @Li,018 Psay aCFOPPISE[nX][5]
	    Li++
	    cCFOP  := aCFOPPISE[nX][1]
	    WHILE aCFOPPISE[nX][1]==cCFOP 
			If Li > 58
				Cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
			EndIf
	  		@LI,013 PSAY aCFOPPISE[nX][3]
			@Li,033 Psay Transform(Abs(aCFOPPISE[nX][4]),PesqPict("SD2","D2_TOTAL",17))
			@Li,059 Psay Transform(Abs(aCFOPPISE[nX][2]),PesqPict("SD2","D2_TOTAL",17))
			nTotal 	+= Abs(aCFOPPISE[nX][2])
			nTot_emp += Abs(aCFOPPISE[nX][4])			
			Li++
			nX++
			IF nX>Len(aCFOPPISE)
				EXIT
			ENDIF
		END
	   nX--
		@Li,003 Psay STR0047 // "Total:"
		@Li,033 Psay Transform(nTot_emp,PesqPict("SD2","D2_TOTAL",17))
		@Li,059 Psay Transform(nTotal,PesqPict("SD2","D2_TOTAL",17))
		Li+=2
		If Li > 58
			Cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
		EndIf
		nTotal   := 0      
		nTot_emp := 0 
	Next
	If Li > 58
		Cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
	EndIf      
	//Resumo por CFOP - PIS - SAIDAS         
	@Li,001 Psay Repli("-",Limite)
	Li++ 
	@Li,001 Psay STR0050//"RESUMO POR CFOP PROCESSADO - SAIDAS"
	Li++ 
	@Li,001 Psay Repli("-",Limite)                        
	Li++ 
	@Li,001 Psay STR0049//"CFOP             Descrição"
	Li++
	@Li,001 Psay STR0051//"        Filial               Base da Contribuição     Valor da Contribuição"
	Li++ 
	@Li,001 Psay Repli("-",Limite)                        	
	Li++ 
	nTotal  	 := 0
	nTot_emp  := 0
	aCFOPPISS := aSORT(aCFOPPISS,,,{|X,Y|X[1]+X[3]<Y[1]+Y[3]})
	For nX := 1 To Len(aCFOPPISS)
	    @Li,001 Psay aCFOPPISS[nX][1]
	    @Li,018 Psay aCFOPPISS[nX][5]
	    Li++
	    cCFOP  := aCFOPPISS[nX][1]
	    WHILE aCFOPPISS[nX][1]==cCFOP
			If Li > 58
				Cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
			EndIf          
			@LI,013 PSAY aCFOPPISS[nX][3]
			@Li,033 Psay Transform(Abs(aCFOPPISS[nX][4]),PesqPict("SD2","D2_TOTAL",17))
			@Li,059 Psay Transform(Abs(aCFOPPISS[nX][2]),PesqPict("SD2","D2_TOTAL",17))
			nTotal 	+= Abs(aCFOPPISS[nX][2])
			nTot_emp += Abs(aCFOPPISS[nX][4])
			Li++
			nX++
			IF nX>Len(aCFOPPISS)
				EXIT
			ENDIF
		END
	   nX--
		@Li,003 Psay STR0047 // "Total:"
		@Li,033 Psay Transform(nTot_emp,PesqPict("SD2","D2_TOTAL",17))
		@Li,059 Psay Transform(nTotal,PesqPict("SD2","D2_TOTAL",17))
		Li+=2
		If Li > 58
			Cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
		EndIf
 		nTotal   := 0
		nTot_emp := 0       
	Next
	If Li > 58
		Cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
	EndIf                     	
	//Resumo por aliquota - PIS - ENTRADAS   
	@Li,001 Psay STR0043 // "RESUMO POR ALIQUOTA PROCESSADA - ENTRADAS"
	Li++ 
	@Li,001 Psay Repli("-",Limite)                        
	Li++ 
	@Li,001 Psay STR0044 //Filial Aliquota                    Valor
	Li++ 
	@Li,001 Psay Repli("-",Limite)                        	
	Li++ 
	nTotal := 0
	For nX := 1 To Len(aTAlPISE)
		If Li > 58
			Cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
		EndIf          
		@Li,005 Psay aTAlPISE[nX][3]
		@Li,011 Psay Transform(aTAlPISE[nX][1],PesqPict("SB1","B1_VLR_PIS",12))
		@Li,026 Psay Transform(Abs(aTAlPISE[nX][2]),PesqPict("SD2","D2_TOTAL",17))
		nTotal += Abs(aTAlPISE[nX][2])
		Li++
	Next  
	@Li,003 Psay STR0047 // "Total:"
	@Li,026 Psay Transform(nTotal,PesqPict("SD2","D2_TOTAL",17))
	Li++	
	If Li > 58
		Cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
	EndIf      
	//Resumo por aliquota - PIS - SAIDAS     
	@Li,001 Psay Repli("-",Limite)
	Li++ 
	@Li,001 Psay STR0046 // "RESUMO POR ALIQUOTA PROCESSADA - SAIDAS"
	Li++ 
	@Li,001 Psay Repli("-",Limite)                        
	Li++ 
	@Li,001 Psay STR0044 //Filial  Aliquota                    Valor
	Li++ 
	@Li,001 Psay Repli("-",Limite)                        	
	Li++ 
	nTotal := 0
	For nX := 1 To Len(aTAlPISS)
		If Li > 58
			Cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
		EndIf   
		@Li,005 Psay aTAlPISS[nX][3]       
		@Li,011 Psay Transform(aTAlPISS[nX][1],PesqPict("SB1","B1_VLR_PIS",12))
		@Li,026 Psay Transform(Abs(aTAlPISS[nX][2]),PesqPict("SD2","D2_TOTAL",17))
		nTotal += Abs(aTAlPISS[nX][2])
		Li++
	Next       
	@Li,003 Psay STR0047 // "Total:"
	@Li,026 Psay Transform(nTotal,PesqPict("SD2","D2_TOTAL",17))
	Li++
	If Li > 58
		Cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
	EndIf          
	//Resumo apurado - PIS
	@Li,001 Psay Repli("-",Limite)
	Li++ 
	@Li,001 Psay STR0045 // RESUMO APURADO        
	Li++ 
	@Li,001 Psay Repli("-",Limite)                        
	Li++ 
	@Li,001 PSAY STR0039+Transform(Abs(aTotApur[01][01]),PesqPict("SD2","D2_TOTAL",14)) + IIf(aTotApur[01][01] < 0,"  (C)","  (D)") + Transform(Abs(aValContri[1]),PesqPict("SD2","D2_TOTAL",14)) + Space(6)+  Transform(Abs(aValContri[2]),PesqPict("SD2","D2_DESCZFR",14))+ Space(19)+ Transform(Abs(aValContri[3]),PesqPict("SD2","D2_TOTAL",14));
			+ Space(10) +  Transform(Abs(aValContri[4]),PesqPict("SD2","D2_TOTAL",14)) + Space(10)+  Transform(Abs(aValContri[5]),PesqPict("SD2","D2_TOTAL",14)) + Space(10)+  Transform(Abs(aValContri[6]),PesqPict("SD2","D2_TOTAL",14)) //"Total Apurado............: "
	Li++ 
	@Li,001 PSAY STR0040+Transform(aTotApur[01][02],PesqPict("SD2","D2_TOTAL",14)) //"Total de Retencao........: "
	Li++          
	@Li,001 PSAY STR0018+Transform(Abs(aTotApur[01][03]),PesqPict("SD2","D2_TOTAL",14)) + IIf(aTotApur[01][03] < 0,"  (C)","  (D)") + Transform(Abs(aValContri[1]),PesqPict("SD2","D2_TOTAL",14)) + Space(6)+  Transform(Abs(aValContri[2]),PesqPict("SD2","D2_DESCZFR",14))+ Space(19)+ Transform(Abs(aValContri[3]),PesqPict("SD2","D2_TOTAL",14))+;
			       Space(10) +  Transform(Abs(aValContri[4]),PesqPict("SD2","D2_TOTAL",14)) + Space(10)+  Transform(Abs(aValContri[5]),PesqPict("SD2","D2_TOTAL",14)) + Space(10)+  Transform(Abs(aValContri[6]),PesqPict("SD2","D2_TOTAL",14))  //"Total da Contribuicao : "
	Li++
	//para aparecer o resumo inteiro do Montante dos movimentos processados no periodo
	If Li > 50
		Cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
	EndIf      
	//Montante dos movimentos processados no periodo
	If lResumo
		@Li,001 Psay Repli("-",Limite) 
		Li++ 
		@Li,001 Psay PadC(STR0042,Limite) // RESUMO POR MOVIMENTO PROCESSADO
		Li++ 
		@Li,001 Psay Repli("-",Limite)
		Li++ 
		@Li,001 Psay STR0024 //"Valores para Calculo              Tributado           Outros            Total"
		Li++ 
		@Li,001 Psay Repli("-",Limite)
		Li++ 
		@Li,001 Psay STR0025+Transform(aTotSai[01],PesqPict("SD2","D2_TOTAL",17))+Transform(aTotSai[02],PesqPict("SD2","D2_TOTAL",17))+Transform(aTotSai[03],PesqPict("SD2","D2_TOTAL",17))  // "Saídas                   "
		Li++ 
		@Li,001 Psay STR0026+Transform(aTotDevS[01],PesqPict("SD2","D2_TOTAL",17))+Transform(aTotDevS[02],PesqPict("SD2","D2_TOTAL",17))+Transform(aTotDevS[03],PesqPict("SD2","D2_TOTAL",17)) // "Devoluções de Saídas     "
		Li++ 
		@Li,001 Psay STR0027+Transform(aTotEnt[01],PesqPict("SD2","D2_TOTAL",17))+Transform(aTotEnt[02],PesqPict("SD2","D2_TOTAL",17))+Transform(aTotEnt[03],PesqPict("SD2","D2_TOTAL",17))// "Entradas                 "
		Li++ 
		@Li,001 Psay STR0028+Transform(aTotDevE[01],PesqPict("SD2","D2_TOTAL",17))+Transform(aTotDevE[02],PesqPict("SD2","D2_TOTAL",17))+Transform(aTotDevE[03],PesqPict("SD2","D2_TOTAL",17)) // "Devoluções de Entradas   "
		Li++ 
	Endif
Endif

Roda(cbcont,cbtxt,ctamanho)

If aReturn[5] == 1
	Set Printer TO
   dbcommitAll()
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³R906Imp   ³ Autor ³Gustavo G. Rueda       ³ Data ³05/01/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de impressao por nota fiscal.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R906Imp(cArqTemp,aTAlPISS,aTAlCOFS,aTAlPISE,aTAlCOFE,aTotApur, nOrd)
	Local  aLay[2]
	Local  aImp			:=	{}
	Local  aAliqs 	  	:= 	{}
	Local  aDedRet     := {0,0}
	Local  aAliqCFGer	:= {} 
	Local  aResAliCF	:= {}
	Local  aContrAliq  := Array(6)
	Local  aSomaAliq	:= Array(6)
	Local  cCabec1		:=	""
	Local  cCabec2		:=	""
	Local  cQuebra  	:= 	""
	Local  cTipo			:=	""
	Local  cCfop			:=	""
	Local  cCabec		:=	""	
	Local  lFirst		:=	.F.
	Local  lContinua  	:= 	.T.
	Local  Lin			:=	1
	Local  nContribC	:=	0
	Local  nContribD	:=	0
	Local  nContribBC	:=	0
	Local  nContribBD	:=	0
	Local  nValCont		:= 	0
	Local  nZFranca		:= 	0
	Local  nValDebi		:= 	0
	Local  nValCred		:=	 	0
	Local  nBasDebi		:= 	0
	Local  nBasCred		:= 	0
	Local  nGValDebi 	:= 	0
	Local  nGValCred 	:= 	0
	Local  nPosAliq		:=	0
	Local  nX				:=	1
	Local  nContrAli	:= 	0
	Local  nAliq			:= 	0 
	Local  nPos			:= 	0                    
	Local  nCt			:= 	0  
	Local  aTotDia		:= 	Array(7)
	Local  aRet			:= 	{0,0}	
	Local  cTotDia		:= 	STR0134	//"  Total do dia - ########                                   ##################  ##################            ##################  ##################    ##################  ##################                     "
	Local  nXX	 		:= 	0
	Local  nAliqP 		:= 	0	
	Local  nAcVlrCtb   := 	0
	Local  nAcZfranca  := 	0
	Local  nAcVlrCtbD  := 	0
	Local  nAcVlrCtbC  := 	0
	Local  nAcVlrCtbBD := 	0
	Local  nAcVlrCtbBC	:= 	0
	Local  cNumNota 	:= 	""
	Local  cSerie   	:= 	""
	Local  cEmissao 	:= 	""
	Local  cNcm     	:= 	""
	Local  cProd    	:= 	""
	Local  cCliFor  	:= 	""
	Local  cPauta	 	:= 	""
	Local  lOrgPub		:= IIF(mv_par13 == 1,.T.,.F.)
	
	For nCt := 1 To len(aContrAliq)
		aContrAliq[nCt] := 0
	Next  
	For nCt := 1 To len(aSomaAliq)
		aSomaAliq[nCt] := 0
	Next 	  
	//Apura os valores referentes as retencoes                    
	aDedRet	:= FsCalRt2(mv_par02,mv_par03,,,2,,@aRet,,.T.,cFilAnt,,lOrgPub)
	aLay[2]	:= STR0038 //"  ########################################################  ##################  ##################  #####    ##################  ##################    ##################  ################## "
	Li			:=	99
	If (nOrd==2)
		If (MV_PAR04==1) // Analitica
			cCabec1	:=	STR0130	//" Documento    Serie  Emissao   Produto          NCM         Valor Contabil      Zona Franca         Aliquota                 Valor da Contribuicao                      Base da Contribuicao      Cliente/Forn.     "
			aLay[1]	:=	STR0131	//"  ######      ###    ########  ###############  ##########  ##################  ##################  #####    ##################  ##################    ##################  ##################    ##################"
		Else
			cCabec1	:=	STR0033	//" Documento    Serie  Emissao   Produto          NCM         Valor Contabil      Zona Franca         Aliquota           Valor da Contribuicao                     Base da Contribuicao          "
			aLay[1]	:=	STR0035	//"  ######      ###    ########  ###############  ##########  ##################  ##################  #####    ##################  ##################    ##################  ################## "
		Endif	
		cCabec2	:=	STR0034	//"                                                                                                                          Debito             Credito                Debito             Credito "
		IndRegua ("TRB", cArqTemp, "TIPO+ES+NUMNF+SERIE+DToS (EMISSAO)")
	ElseIf (nOrd==3)
		If (MV_PAR04==1) // Analitica
			cCabec1	:=	STR0132	//" Emissao   Documento    Serie  Produto          NCM         Valor Contabil      Zona Franca         Aliquota                 Valor da Contribuicao                      Base da Contribuicao      Cliente/Forn.     "
			aLay[1]	:=	STR0133	//" ########   ######      ###    ###############  ##########  ##################  ##################  #####    ##################  ##################    ##################  ##################    ##################"
   		Else
			cCabec1	:=	STR0057	//" Emissao   Documento    Serie  Produto          NCM         Valor Contabil      Zona Franca         Aliquota                 Valor da Contribuicao                      Base da Contribuicao   "
			aLay[1]	:=	STR0058	//" ########   ######      ###    ###############  ##########  ##################  ##################  #####    ##################  ##################    ##################  ################## "
   		Endif
		cCabec2	:=	STR0034	//"                                                                                                                          Debito             Credito                Debito             Credito "
		IndRegua ("TRB", cArqTemp, "TIPO+ES+DToS (EMISSAO)+NUMNF+SERIE")
	EndIF
	aTotDia[1]	:=	TRB->EMISSAO
	aTotDia[2]	:=	0
	aTotDia[3]	:=	0
	aTotDia[4]	:=	0
	aTotDia[5]	:=	0
	aTotDia[6]	:=	0
	aTotDia[7]	:=	0               		
	Do While !TRB->(Eof ()) .And. (lContinua)	
		If (lEnd)
			@ Prow()+1,001 PSay STR0007  //"CANCELADO PELO OPERADOR"
			lContinua := .F.
			Exit
		Endif
		IncRegua()
		If (Li>58)
			cabec (ctitulo, cCabec1, cCabec2, nomeprog, ctamanho, 15)
		EndIf                                                                                                                                       
		If !(lFirst)
			@ Li, 001 Psay OemToAnsi (STR0008) + SM0->M0_NOMECOM //"Empresa : "
			Li++ 
			@ Li, 001 Psay OemToAnsi (STR0021) + Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")  //"CNPJ    : "
			Li++ 
			@ Li, 001 Psay OemToAnsi (STR0009) + Dtoc(mv_par02) + " - " + Dtoc(mv_par03) //"Periodo : "
			Li++
		Endif
		cQuebra  := TRB->TIPO+TRB->ES+TRB->CLIFOR
		//Quebra do totalizador por dia durante o processamento
		If (MV_PAR09==1) .And. (nOrd==3) .And. lFirst .And.;
			(TRB->EMISSAO<>aTotDia[1] .Or. TRB->ES<>cCfop .Or. TRB->TIPO<>cTipo)			
			@ Li, 001 PSAY __PrtThinLine()
			Li++
			FmtLin (aTotDia,cTotDia,,"@X",@Li)
			Li++
			aTotDia[1]	:=	TRB->EMISSAO
			aTotDia[2]	:=	0
			aTotDia[3]	:=	0
			aTotDia[4]	:=	0
			aTotDia[5]	:=	0
			aTotDia[6]	:=	0
			aTotDia[7]	:=	0
		EndIf
		If (TRB->TIPO<>cTipo) .Or. (TRB->ES<>cCfop)
			If (lFirst)
				@ Li, 001 PSAY __PrtThinLine()
				Li++
				//Array jah totalizado por aliquota, pronto para impressao
				aSort(aALiqs,,,{|x,y| x[1]>y[1]})
				For nX := 1 To Len (aALiqs)					
					aContrAliq	:=	{aALiqs[nX][3], aALiqs[nX][4], aALiqs[nX][5], aALiqs[nX][6], aALiqs[nX][7], aALiqs[nX][8]}
					//Quebra do totalizador por CFOP durante o processamento
					If mv_par10 == 1                                   
						nPosAliq := aScan(aResAliCF,{|x| x[1]==aAliqs[nX][1]})
						If nPosAliq > 0							
							For nPos := nPosAliq to Len(aResAliCF)
								If aResAliCF[nPos][01] <> aAliqs[nX][1]
									Exit
								Endif
								If (Li>58)
									cabec (ctitulo, cCabec1, cCabec2, nomeprog, ctamanho, 15)
								EndIf    								                                                                                                                                   
								// Imprime o cabecalho do total por CFOP        
								If nPos == nPosAliq
									cCabec := STR0053 + Space(05) + aResAliCF[nPos][2]
								Else
									cCabec := STR0053
									cCabec := Space(Len(cCabec)) + Space(05) + aResAliCF[nPos][2]
								Endif								
								FmtLin({cCabec, Transform (aResAliCF[nPos][4], "@E 999,999,999,999.99"), Transform (aResAliCF[nPos][5], "@E 999,999,999,999.99"),;
										Transform (aResAliCF[nPos][6], "@E 999,999,999,999.99"), Transform (aResAliCF[nPos][7], "@E 999,999,999,999.99"),;
										Transform (aResAliCF[nPos][8], "@E 999,999,999,999.99"), Transform (aResAliCF[nPos][9], "@E 999,999,999,999.99")},aLay[2],,"@X",@Li)
							Next
						Endif
					Endif
					If aAliqs[nX][9]=="S"
						aContrAliq	:=	{0,0,0,0,0,0}
						For nXX := nX To Len(aALiqs)
							If aAliqs[nXX][9]=="S" .And. aAliqs[nX][1]==0
								nX := nXX
								aContrAliq[1]+= aALiqs[nXX][3]
								aContrAliq[2]+= aALiqs[nXX][4]
								aContrAliq[3]+= aALiqs[nXX][5]
								aContrAliq[4]+= aALiqs[nXX][6]
								aContrAliq[5]+= aALiqs[nXX][7]
								aContrAliq[6]+= aALiqs[nXX][8]
							Else
								Exit
							EndIf
						Next 
					EndIf
					FmtLin({STR0031+Transform(aAliqs[nX][1],PesqPict("SB1","B1_VLR_COF",TamSx3("B1_VLR_COF")[1])), Transform (aContrAliq[1], "@E 999,999,999,999.99"), Transform (aContrAliq[2], "@E 999,999,999,999.99"),;
							Transform (aContrAliq[3], "@E 999,999,999,999.99"), Transform (aContrAliq[4], "@E 999,999,999,999.99"),;
							Transform (aContrAliq[5], "@E 999,999,999,999.99"), Transform (aContrAliq[6], "@E 999,999,999,999.99")},aLay[2],,"@X",@Li)
					Li++
				Next 				
				//Impressao do total das entradas/saidas durante o processamento
				FmtLin({Iif (TRB->ES=="S", STR0015+STR0017, STR0015+STR0016), Transform (nValCont, "@E 999,999,999,999.99"), Transform (nZFranca, "@E 999,999,999,999.99"),;
						Transform (nValDebi, "@E 999,999,999,999.99"), Transform (nValCred, "@E 999,999,999,999.99"),;
						Transform (nBasDebi, "@E 999,999,999,999.99"), Transform (nBasCred, "@E 999,999,999,999.99")}, aLay[2],,"@X",@Li)				
				//Impressao da parte da contribuicao ao final das informacoes do PIS ou COFINS, durante o processamento
				If (TRB->TIPO<>cTipo)
					Li+=2
					@ Li, 001 Psay __PrtThinLine()
					Li++
					@ Li, 001 Psay STR0032 //"Contribuicao : "
					Li+=2
					//Ordena o array por aliquota + CFOP  
					Asort(aAliqCFGer,,,{|x,y|Str(x[1])+x[2] < Str(y[1])+y[2]})					
					aContrAliq	:=	{0,0,0,0,0,0}
					//Imprime o valor apurado por aliquota ou por aliquota + cfop
					For nX := 1 To Len(aAliqCFGer)					                
						If (Li>58)
							cabec (ctitulo, cCabec1, cCabec2, nomeprog, ctamanho, 15)
						EndIf						
						If nAliq <> aAliqCFGer[nX][1] 						
							If nX <> 1                        
					   		@Li, 001 PSAY STR0047 + Space(04) + Transform(Abs(nContrAli),PesqPict("SD2","D2_TOTAL",14)) + IIf(nContrAli < 0,"  (C)","  (D)")+ Space(34)+ Transform(Abs(aContrAliq[1]),PesqPict("SD2","D2_TOTAL",14)) + Space(6)+  Transform(Abs(aContrAliq[2]),PesqPict("SD2","D2_DESCZFR",14))+ Space(16)+ Transform(Abs(aContrAliq[3]),PesqPict("SD2","D2_TOTAL",14))+;
								              Space(6) +  Transform(Abs(aContrAliq[4]),PesqPict("SD2","D2_TOTAL",14)) + Space(8)+  Transform(Abs(aContrAliq[5]),PesqPict("SD2","D2_TOTAL",14)) + Space(6)+  Transform(Abs(aContrAliq[6]),PesqPict("SD2","D2_TOTAL",14))								
								Li+=2
								nContrAli := 0 
								For nCt := 1 To len(aContrAliq)
			   					aContrAliq[nCt] := 0
								Next nCt   								           
							Endif
							@Li, 001 PSAY STR0029 + Transform(aAliqCFGer[nX][1],PesqPict("SB1","B1_VLR_COF",TamSx3("B1_VLR_COF")[1]))
							Li++  
							If mv_par10 == 1
								@Li, 001 PSAY STR0054
								Li++
							Endif
							nAliq 	:= aAliqCFGer[nX][1]
						Endif						 
						If mv_par10 == 1
							@Li, 001 PSAY aAliqCFGer[nX][2] + Space(06) + Transform(Abs(aAliqCFGer[nX][3]),PesqPict("SD2","D2_TOTAL",14)) + IIf(aAliqCFGer[nX][3] < 0,"  (C)","  (D)") + Space(34)+ Transform(Abs(aAliqCFGer[nX][4]),PesqPict("SD2","D2_TOTAL",14)) + Space(6)+  Transform(Abs(aAliqCFGer[nX][5]),PesqPict("SD2","D2_DESCZFR",14))+ Space(16)+ Transform(Abs(aAliqCFGer[nX][6]),PesqPict("SD2","D2_TOTAL",14))+;
								           Space(6) +  Transform(Abs(aAliqCFGer[nX][7]),PesqPict("SD2","D2_TOTAL",14)) + Space(8)+  Transform(Abs(aAliqCFGer[nX][8]),PesqPict("SD2","D2_TOTAL",14)) + Space(6)+  Transform(Abs(aAliqCFGer[nX][9]),PesqPict("SD2","D2_TOTAL",14))	
							Li++                                                              
						Endif             
						nContrAli	  += aAliqCFGer[nX][3]  
						
						aContrAliq[1] += aAliqCFGer[nX][4] 
						aContrAliq[2] += aAliqCFGer[nX][5] 
						aContrAliq[3] += aAliqCFGer[nX][6]
						aContrAliq[4] += aAliqCFGer[nX][7] 
						aContrAliq[5] += aAliqCFGer[nX][8] 
						aContrAliq[6] += aAliqCFGer[nX][9]

						aSomaAliq[1]  += aAliqCFGer[nX][4]            
						aSomaAliq[2]  += aAliqCFGer[nX][5]
						aSomaAliq[3]  += aAliqCFGer[nX][6]
						aSomaAliq[4]  += aAliqCFGer[nX][7]
						aSomaAliq[5]  += aAliqCFGer[nX][8]
						aSomaAliq[6]  += aAliqCFGer[nX][9]   																														
					Next
					If (Li>58)
						cabec (ctitulo, cCabec1, cCabec2, nomeprog, ctamanho, 15)
					EndIf
					//Total
					@Li, 001 PSAY STR0047 + Space(04) + Transform(Abs(nContrAli),PesqPict("SD2","D2_TOTAL",14)) + IIf(nContrAli < 0,"  (C)","  (D)")+ Space(34)+ Transform(Abs(aContrAliq[1]),PesqPict("SD2","D2_TOTAL",14)) + Space(6)+  Transform(Abs(aContrAliq[2]),PesqPict("SD2","D2_DESCZFR",14))+ Space(16)+ Transform(Abs(aContrAliq[3]),PesqPict("SD2","D2_TOTAL",14))+;
					              Space(6) + Transform(Abs(aContrAliq[4]),PesqPict("SD2","D2_TOTAL",14)) + Space(8)+  Transform(Abs(aContrAliq[5]),PesqPict("SD2","D2_TOTAL",14)) + Space(6)+  Transform(Abs(aContrAliq[6]),PesqPict("SD2","D2_TOTAL",14))
					Li+=2					
					//"Total Apurado............: "
					@Li, 001 PSAY STR0039
					Li++
					@Li, 011 PSAY Transform(Abs(nGValDebi-nGValCred),PesqPict("SD2","D2_TOTAL",14)) + IIf(nGValDebi-nGValCred < 0,"  (C)","  (D)")+ Space(34)+Transform(Abs(aSomaAliq[1]),PesqPict("SD2","D2_TOTAL",14)) + Space(6)+  Transform(Abs(aSomaAliq[2]),PesqPict("SD2","D2_DESCZFR",14))+ Space(16)+ Transform(Abs(aSomaAliq[3]),PesqPict("SD2","D2_TOTAL",14))+;
				   	           Space(6) + Transform(Abs(aSomaAliq[4]),PesqPict("SD2","D2_TOTAL",14)) + Space(8)+  Transform(Abs(aSomaAliq[5]),PesqPict("SD2","D2_TOTAL",14)) + Space(6)+  Transform(Abs(aSomaAliq[6]),PesqPict("SD2","D2_TOTAL",14)) 
			   	Li++
			   	Li++
					//"Total das Retencoes........: "
					@Li, 001 PSAY STR0143 //"Total de Retenção(Modalidade da Dedução: Vencimento)........: "  --> Empresas que nao sao de Direito Publico
					Li++
					@Li, 011 PSAY Transform(IIF(cTipo=="PIS",aRet[1],aRet[2]),PesqPict("SD2","D2_TOTAL",14))
					Li++
					Li++ 
					@Li, 001 PSAY STR0144 //"Total de Retenção - Orgãos Públicos(Modalidade da Dedução: Pagamento)........: "
					Li++
					@Li, 011 PSAY Transform(IIF(cTipo=="PIS",(aDedRet[1]-aRet[1]),(aDedRet[2]-aRet[2])),PesqPict("SD2","D2_TOTAL",14))
					Li++          
					Li++  
					nContrAli := IIF(cTipo=="PIS",(nGValDebi-nGValCred)-aDedRet[1],(nGValDebi-nGValCred)-aDedRet[2])					
					//"Total da Contribuicao....: "
					@Li, 001 PSAY STR0018
					Li++
					@Li, 011 PSAY Transform(IIF(cTipo=="PIS",Abs((nGValDebi-nGValCred)-aDedRet[1]),Abs((nGValDebi-nGValCred)-aDedRet[2])),PesqPict("SD2","D2_TOTAL",14)) + IIf(nContrAli < 0,"  (C)","  (D)") + Space(34) + Transform(Abs(aSomaAliq[1]),PesqPict("SD2","D2_TOTAL",14)) + Space(6)+  Transform(Abs(aSomaAliq[2]),PesqPict("SD2","D2_DESCZFR",14))+ Space(16)+ Transform(Abs(aSomaAliq[3]),PesqPict("SD2","D2_TOTAL",14))+;
						      Space(6) +  Transform(Abs(aSomaAliq[4]),PesqPict("SD2","D2_TOTAL",14)) + Space(8)+  Transform(Abs(aSomaAliq[5]),PesqPict("SD2","D2_TOTAL",14)) + Space(6)+  Transform(Abs(aSomaAliq[6]),PesqPict("SD2","D2_TOTAL",14))//"Total da Contribuicao : "					
					If cTipo == "PIS"
						aTotApur[01][01]  += nGValDebi-nGValCred
						aTotApur[01][02]  += aDedRet[1]
						aTotApur[01][03]  += (nGValDebi-nGValCred)-aDedRet[1]
					Else
						aTotApur[02][01]  += nGValDebi-nGValCred
						aTotApur[02][02]  += aDedRet[2]
						aTotApur[02][03]  += (nGValDebi-nGValCred)-aDedRet[2]
					Endif
					nGValDebi 	:= 0
					nGValCred 	:= 0
					aAliqCFGer	:=	{}
				EndIf
				aAliqs		:=	{}            
				aResAliCF 	:= {}         
				nValCont	:=	0
				nZFranca 	:=	0
				nValDebi	:=	0
				nValCred 	:=	0
				nBasDebi 	:=	0
				nBasCred 	:=	0
				For nCt := 1 To len(aSomaAliq)
					aSomaAliq[nCt] := 0
				Next nCt  	  
			EndIf
			If (TRB->TIPO<>cTipo) .And. lFirst
				Cabec (cTitulo, cCabec1, cCabec2, nomeprog, cTamanho, 15)
			EndIf
			Li++
			@ Li, 001 PSay IIf (TRB->TIPO=="PIS", PadC (STR0010+ Iif (SubStr (TRB->CFOP, 1, 1)<"5", STR0011, STR0012), Limite),;
		                  PadC (STR0013+Iif (SubStr (TRB->CFOP, 1, 1)<"5", STR0011, STR0012), Limite))
			Li	+=	2
			cTipo :=	TRB->TIPO
			cCfop	:=	TRB->ES
			lFirst:=	.T.
		Endif
		If (SubStr (TRB->CFOP, 1, 1)>="5")
			nContribC	:=	Iif (TRB->TIPO=="PIS", TRB->PISDSAI, TRB->COFDSAI)
			nContribD	:=	Iif (TRB->TIPO=="PIS", TRB->PISCSAI, TRB->COFCSAI)
			nContribBC	:=	Iif (TRB->TIPO=="PIS", TRB->BASPIDSAI, TRB->BASCODSAI)
			nContribBD	:=	Iif (TRB->TIPO=="PIS", TRB->BASPICSAI, TRB->BASCOCSAI)
		Else	
			nContribC	:=	Iif (TRB->TIPO=="PIS", TRB->PISDENT, TRB->COFDENT)
			nContribD	:=	Iif (TRB->TIPO=="PIS", TRB->PISCENT, TRB->COFCENT)
			nContribBC	:=	Iif (TRB->TIPO=="PIS", TRB->BASPIDENT, TRB->BASCODENT)
			nContribBD	:=	Iif (TRB->TIPO=="PIS", TRB->BASPICENT, TRB->BASCOCENT)
		Endif
		//Impressao das movimentacoes (NOTAS FISCAIS)
      If MV_PAR04 == 1 // Analitico
        	If MV_PAR11 == 1 // Resume as NF's
        		//Acumula os valores para imprimir posteriormente
				nAcVlrCtb   += TRB->VALORCONT
				nAcZfranca  += TRB->ZFRANCA
				nAcVlrCtbD  += nContribD
				nAcVlrCtbC  += nContribC
				nAcVlrCtbBD += nContribBD
				nAcVlrCtbBC	+= nContribBC
				
				cNumNota 	:= TRB->NUMNF
				cSerie   	:= TRB->SERIE
				cEmissao 	:= TRB->EMISSAO
				cNcm     	:= TRB->NCM
				cProd    	:= TRB->PRODUTO
				cCliFor  	:= TRB->CLIFOR
				cPauta	 	:= TRB->PAUTA				
        	Else
				If (nOrd==2)
			       aImp	:=	{TRB->NUMNF, TRB->SERIE, TRB->EMISSAO,	TRB->PRODUTO, TRB->NCM, Transform (TRB->VALORCONT, "@E 999,999,999,999.99"),;
				 		    	Transform (TRB->ZFRANCA, "@E 999,999,999,999.99"), 	Transform(TRB->ALIQ,Iif(TRB->PAUTA=="S",PesqPict("SB1","B1_VLR_COF",TamSx3("B1_VLR_COF")[1]),PesqPict("SB1","B1_VLR_COF",TamSx3("B1_VLR_COF")[1]))), Transform (nContribC, "@E 999,999,999,999.99"),;
				   	   	Transform (nContribD, "@E 999,999,999,999.99"), Transform (nContribBC, "@E 999,999,999,999.99"), Transform (nContribBD, "@E 999,999,999,999.99"),;
				   	   	TRB->CLIFOR}
		  		ElseIf (nOrd==3)
			       aImp	:=	{TRB->EMISSAO, TRB->NUMNF, TRB->SERIE,	TRB->PRODUTO, TRB->NCM, Transform (TRB->VALORCONT, "@E 999,999,999,999.99"),;
				    	   	Transform (TRB->ZFRANCA, "@E 999,999,999,999.99"), 	Transform(TRB->ALIQ,Iif(TRB->PAUTA=="S",PesqPict("SB1","B1_VLR_COF",TamSx3("B1_VLR_COF")[1]),PesqPict("SB1","B1_VLR_COF",TamSx3("B1_VLR_COF")[1]))), Transform (nContribC, "@E 999,999,999,999.99"),;
				   	   	Transform (nContribD, "@E 999,999,999,999.99"), Transform (nContribBC, "@E 999,999,999,999.99"), Transform (nContribBD, "@E 999,999,999,999.99"),;
				   	   	TRB->CLIFOR}
			    EndIf
  				FmtLin (aImp, aLay[1],,, @Li)
			EndIf
		EndIf
	   aTotDia[2]	+=	TRB->VALORCONT
	   aTotDia[3]	+=	TRB->ZFRANCA
	   aTotDia[4]	+=	nContribC
	   aTotDia[5]	+=	nContribD
	   aTotDia[6]	+=	nContribBC
		aTotDia[7]	+=	nContribBD
		nValCont	+=	TRB->VALORCONT
		nZFranca 	+=	TRB->ZFRANCA
		If (SubStr (TRB->CFOP, 1, 1)>="5")
			nValDebi	+= 	Iif (TRB->TIPO=="PIS", TRB->PISDSAI, TRB->COFDSAI)
			nValCred 	+= 	Iif (TRB->TIPO=="PIS", TRB->PISCSAI, TRB->COFCSAI)
			nBasDebi 	+= 	Iif (TRB->TIPO=="PIS", TRB->BASPIDSAI, TRB->BASCODSAI)
			nBasCred 	+=	Iif (TRB->TIPO=="PIS", TRB->BASPICSAI, TRB->BASCOCSAI)
			nGValDebi 	+= 	Iif (TRB->TIPO=="PIS", TRB->PISDSAI, TRB->COFDSAI)
			nGValCred 	+= 	Iif (TRB->TIPO=="PIS", TRB->PISCSAI, TRB->COFCSAI)			//
			nAliqP 		:=  Iif(TRB->PAUTA=="S",0,TRB->ALIQ)
			nPosAliq	:=	Ascan(aAliqs,{|x| x[1]==nAliqP})
			If (nPosAliq>0)
				aAliqs[nPosAliq][2] += IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI)-IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI)
				aAliqs[nPosAliq][3] += TRB->VALORCONT
				aAliqs[nPosAliq][4] += TRB->ZFRANCA
				aAliqs[nPosAliq][5] += IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI)
				aAliqs[nPosAliq][6] += IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI)
				aAliqs[nPosAliq][7] += IIF(TRB->TIPO == "PIS",TRB->BASPIDSAI,TRB->BASCODSAI)
				aAliqs[nPosAliq][8] += IIF(TRB->TIPO == "PIS",TRB->BASPICSAI,TRB->BASCOCSAI)
				If TRB->TIPO == "PIS"
					nAliqP 	:= Iif(TRB->PAUTA=="S",0,TRB->ALIQ)
					nPosAliq	:=	Ascan(atalpiss,{|x| x[1]==nAliqP .and. x[3]==sm0->m0_codfil})
					If nPosAliq > 0
						aTAlPISS[nPosAliq][2] += TRB->PISDSAI-TRB->PISCSAI
					EndIf
				Else
					nAliqP 	:= Iif(TRB->PAUTA=="S",0,TRB->ALIQ)
					nPosAliq	:=	Ascan(atalcofs,{|x| x[1]==nAliqP .and. x[3]==sm0->m0_codfil})
					If nPosAliq > 0  
						aTAlCOFS[nPosAliq][2] += TRB->COFDSAI-TRB->COFCSAI
					endIf
				Endif
			Else
				aAdd (aAliqs, {Iif(TRB->PAUTA=="S",0,TRB->ALIQ),;
				              Iif (TRB->TIPO=="PIS", TRB->PISDSAI, TRB->COFDSAI)-Iif (TRB->TIPO=="PIS", TRB->PISCSAI, TRB->COFCSAI),;
				              TRB->VALORCONT, TRB->ZFRANCA,;
				              Iif (TRB->TIPO=="PIS", TRB->PISDSAI, TRB->COFDSAI),;
				              Iif (TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI),;
				              Iif (TRB->TIPO=="PIS", TRB->BASPIDSAI, TRB->BASCODSAI),;
				              Iif (TRB->TIPO == "PIS",TRB->BASPICSAI,TRB->BASCOCSAI),;
				              TRB->PAUTA})
				If TRB->TIPO == "PIS"					              
					AADD(aTAlPISS,{Iif(TRB->PAUTA=="S",0,TRB->ALIQ),TRB->PISDSAI-TRB->PISCSAI,sm0->m0_codfil})
				Else                                                       
					AADD(aTAlCOFS,{Iif(TRB->PAUTA=="S",0,TRB->ALIQ),TRB->COFDSAI-TRB->COFCSAI,sm0->m0_codfil})
				Endif
			Endif      
			//Acumula a contribuicao por aliquota para impressao do resumo
			nAliqP   := Iif(TRB->PAUTA=="S",0,TRB->ALIQ)
			nPosAliq := Ascan(aAliqCFGer,{|x| x[1]==nAliqP .And. x[2]==TRB->CFOP})
			If nPosAliq > 0
				aAliqCFGer[nPosAliq][3]  += IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI)-IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI)
				aAliqCFGer[nPosAliq][4]  += TRB->VALORCONT //valor contabil
				aAliqCFGer[nPosAliq][5]  += TRB->ZFRANCA //Desconto Zona Franca
				aAliqCFGer[nPosAliq][6]  += IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI) //contribuicao debito
				aAliqCFGer[nPosAliq][7]  += IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI) //contribuicao credito										
				aAliqCFGer[nPosAliq][8]  += IIF(TRB->TIPO == "PIS",TRB->BASPIDSAI,TRB->BASCODSAI) //base debito
				aAliqCFGer[nPosAliq][9]  += IIF(TRB->TIPO == "PIS",TRB->BASPICSAI,TRB->BASCOCSAI) //base credito					
			Else
				AADD(aAliqCFGer,{Iif(TRB->PAUTA=="S",0,TRB->ALIQ),TRB->CFOP,IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI)-IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI),TRB->VALORCONT,TRB->ZFRANCA,IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI),IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI),IIF(TRB->TIPO == "PIS",TRB->BASPIDSAI,TRB->BASCODSAI),IIF(TRB->TIPO == "PIS",TRB->BASPICSAI,TRB->BASCOCSAI)})				
			Endif
			//Totalizador do Relatorio por Aliquota + CFOP
			nAliqP 	:= Iif(TRB->PAUTA=="S",0,TRB->ALIQ)
			nPosAliq := aScan(aResAliCF,{|x| x[1]==nAliqP .And. x[2]==TRB->CFOP})
			If nPosAliq == 0
				AADD(aResAliCF,{Iif(TRB->PAUTA=="S",0,TRB->ALIQ),;
				              TRB->CFOP,;
				              IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI)-IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI),;
				              TRB->VALORCONT,;
				              TRB->ZFRANCA,;
				              IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI),;
				              IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI),;
				              IIF(TRB->TIPO == "PIS",TRB->BASPIDSAI,TRB->BASCODSAI),;
				              IIF(TRB->TIPO == "PIS",TRB->BASPICSAI,TRB->BASCOCSAI),;
				              TRB->PAUTA})
			Else
				aResAliCF[nPosAliq][3]  += IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI)-IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI)
				aResAliCF[nPosAliq][4]  += TRB->VALORCONT
				aResAliCF[nPosAliq][5]  += TRB->ZFRANCA
				aResAliCF[nPosAliq][6]  += IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI)
				aResAliCF[nPosAliq][7]  += IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI)
				aResAliCF[nPosAliq][8]  += IIF(TRB->TIPO == "PIS",TRB->BASPIDSAI,TRB->BASCODSAI)
				aResAliCF[nPosAliq][9]  += IIF(TRB->TIPO == "PIS",TRB->BASPICSAI,TRB->BASCOCSAI)
			Endif
		Else
			nValDebi 	+=		Iif (TRB->TIPO=="PIS", TRB->PISDENT, TRB->COFDENT) 
			nValCred 	+= 	Iif (TRB->TIPO=="PIS", TRB->PISCENT, TRB->COFCENT) 
			nBasDebi 	+= 	Iif (TRB->TIPO=="PIS", TRB->BASPIDENT, TRB->BASCODENT) 
			nBasCred 	+= 	Iif (TRB->TIPO=="PIS", TRB->BASPICENT, TRB->BASCOCENT) 
			nGValDebi	+= 	Iif (TRB->TIPO=="PIS", TRB->PISDENT, TRB->COFDENT) 
			nGValCred	+= 	Iif (TRB->TIPO=="PIS", TRB->PISCENT, TRB->COFCENT) 
			nAliqP 		:= 	Iif(TRB->PAUTA=="S",0,TRB->ALIQ)
			nPosAliq		:=		Ascan(aAliqs,{|x| x[1]==nAliqP})
			If (nPosAliq>0)
				aAliqs[nPosAliq][2]	    += 	Iif (TRB->TIPO=="PIS", TRB->PISDENT, TRB->COFDENT)-Iif (TRB->TIPO=="PIS", TRB->PISCENT, TRB->COFCENT)
				aAliqs[nPosAliq][3] 	+= 	TRB->VALORCONT
				aAliqs[nPosAliq][4] 	+= 	TRB->ZFRANCA
				aAliqs[nPosAliq][5] 	+= 	Iif (TRB->TIPO=="PIS", TRB->PISDENT, TRB->COFDENT) 
				aAliqs[nPosAliq][6] 	+= 	Iif (TRB->TIPO=="PIS", TRB->PISCENT, TRB->COFCENT) 
				aAliqs[nPosAliq][7] 	+= 	Iif (TRB->TIPO=="PIS", TRB->BASPIDENT, TRB->BASCODENT) 
				aAliqs[nPosAliq][8] 	+=		Iif (TRB->TIPO=="PIS", TRB->BASPICENT, TRB->BASCOCENT) 
				If TRB->TIPO == "PIS"
					nAliqP 					 := Iif(TRB->PAUTA=="S",0,TRB->ALIQ)
					nPosAliq					 :=	Ascan(atalpise,{|x| x[1]==nAliqP .and. x[3]==sm0->m0_codfil})
					If nPosAliq > 0
						aTAlPISE[nPosAliq][2] += TRB->PISDENT-TRB->PISCENT
					EndIf	
					
				Else
					nAliqP 					 := Iif(TRB->PAUTA=="S",0,TRB->ALIQ)
					nPosAliq					 :=	Ascan(atalcofe,{|x| x[1]==nAliqP .and. x[3]==sm0->m0_codfil})
					If nPosAliq >0
						aTAlCOFE[nPosAliq][2] += TRB->COFDENT-TRB->COFCENT
					EndIf	
				Endif
			Else
				aAdd (aAliqs,{Iif(TRB->PAUTA=="S",0,TRB->ALIQ),;
				             Iif (TRB->TIPO=="PIS", TRB->PISDENT, TRB->COFDENT)-Iif (TRB->TIPO=="PIS", TRB->PISCENT, TRB->COFCENT),;
				             TRB->VALORCONT,;
				             TRB->ZFRANCA,;
				             Iif (TRB->TIPO=="PIS", TRB->PISDENT, TRB->COFDENT),;
				             Iif (TRB->TIPO=="PIS", TRB->PISCENT, TRB->COFCENT),;
				             Iif (TRB->TIPO=="PIS", TRB->BASPIDENT, TRB->BASCODENT),;
				             Iif (TRB->TIPO=="PIS", TRB->BASPICENT, TRB->BASCOCENT),;
				             TRB->PAUTA})
				If TRB->TIPO == "PIS"
					AADD(aTAlPISE,{Iif(TRB->PAUTA=="S",0,TRB->ALIQ),TRB->PISDENT-TRB->PISCENT,sm0->m0_codfil})
				Else
					AADD(aTAlCOFE,{Iif(TRB->PAUTA=="S",0,TRB->ALIQ),TRB->COFDENT-TRB->COFCENT,sm0->m0_codfil})
				Endif
			Endif
			//Acumula a contribuicao por aliquota para impressao do resumo
			nAliqP   := Iif(TRB->PAUTA=="S",0,TRB->ALIQ)
			nPosAliq := Ascan(aAliqCFGer,{|x| x[1]==nAliqP .And. x[2]==TRB->CFOP})
			If nPosAliq > 0
				aAliqCFGer[nPosAliq][3]  += IIF(TRB->TIPO == "PIS",TRB->PISDENT,TRB->COFDENT)-IIF(TRB->TIPO == "PIS",TRB->PISCENT,TRB->COFCENT) 
				aAliqCFGer[nPosAliq][4]  += TRB->VALORCONT //valor contabil
				aAliqCFGer[nPosAliq][5]  += TRB->ZFRANCA //Desconto Zona Franca
				aAliqCFGer[nPosAliq][6]  += IIF(TRB->TIPO == "PIS",TRB->PISDENT,TRB->COFDENT) //contribuicao debito
				aAliqCFGer[nPosAliq][7]  += IIF(TRB->TIPO == "PIS",TRB->PISCENT,TRB->COFCENT) //contribuicao credito										
				aAliqCFGer[nPosAliq][8]  += IIF(TRB->TIPO == "PIS",TRB->BASPIDENT,TRB->BASCODENT) //base debito
				aAliqCFGer[nPosAliq][9]  += IIF(TRB->TIPO == "PIS",TRB->BASPICENT,TRB->BASCOCENT) //base credito					
			Else
				AADD(aAliqCFGer,{Iif(TRB->PAUTA=="S",0,TRB->ALIQ),TRB->CFOP,IIF(TRB->TIPO == "PIS",TRB->PISDENT,TRB->COFDENT)-IIF(TRB->TIPO == "PIS",TRB->PISCENT,TRB->COFCENT),TRB->VALORCONT,TRB->ZFRANCA,IIF(TRB->TIPO == "PIS",TRB->PISDENT,TRB->COFDENT),IIF(TRB->TIPO == "PIS",TRB->PISCENT,TRB->COFCENT),IIF(TRB->TIPO == "PIS",TRB->BASPIDENT,TRB->BASCODENT),IIF(TRB->TIPO == "PIS",TRB->BASPICENT,TRB->BASCOCENT)}) 
			Endif
			//Totalizador do Relatorio por Aliquota + CFOP
			nAliqP 	:= Iif(TRB->PAUTA=="S",0,TRB->ALIQ)
			nPosAliq := aScan(aResAliCF,{|x| x[1]==nAliqP .And. x[2]==TRB->CFOP})
			If nPosAliq == 0
				AADD(aResAliCF,{Iif(TRB->PAUTA=="S",0,TRB->ALIQ),;
				               TRB->CFOP,; 
				               IIF(TRB->TIPO == "PIS",TRB->PISDENT,TRB->COFDENT)-IIF(TRB->TIPO == "PIS",TRB->PISCENT,TRB->COFCENT),;
  				               TRB->VALORCONT,;
				               TRB->ZFRANCA,;
				               IIF(TRB->TIPO == "PIS",TRB->PISDENT,TRB->COFDENT),;
				               IIF(TRB->TIPO == "PIS",TRB->PISCENT,TRB->COFCENT),;
				               IIF(TRB->TIPO == "PIS",TRB->BASPIDENT,TRB->BASCODENT),;
				               IIF(TRB->TIPO == "PIS",TRB->BASPICENT,TRB->BASCOCENT),;
				               TRB->PAUTA})
			Else
				aResAliCF[nPosAliq][3]  += IIF(TRB->TIPO == "PIS",TRB->PISDENT,TRB->COFDENT)-IIF(TRB->TIPO == "PIS",TRB->PISCENT,TRB->COFCENT) 
				aResAliCF[nPosAliq][4]  += TRB->VALORCONT
				aResAliCF[nPosAliq][5]  += TRB->ZFRANCA
				aResAliCF[nPosAliq][6]  += IIF(TRB->TIPO == "PIS",TRB->PISDENT,TRB->COFDENT) 
				aResAliCF[nPosAliq][7]  += IIF(TRB->TIPO == "PIS",TRB->PISCENT,TRB->COFCENT) 
				aResAliCF[nPosAliq][8]  += IIF(TRB->TIPO == "PIS",TRB->BASPIDENT,TRB->BASCODENT) 
				aResAliCF[nPosAliq][9]  += IIF(TRB->TIPO == "PIS",TRB->BASPICENT,TRB->BASCOCENT)                                                
			Endif
		Endif		
		//Ordena o array por aliquota + CFOP  
		Asort(aResAliCF,,,{|x,y|Str(x[1])+x[2] < Str(y[1])+y[2]})							
		TRB->(DbSkip ())
		If cNumNota <> TRB->NUMNF .OR. TRB->TIPO+TRB->ES+TRB->CLIFOR <> cQuebra .Or. TRB->(EOF())
			If mv_par11 == 1 .And. mv_par04 == 1
				//Imprime valores acumulados
		       If (nOrd==2)
			        aImp := {cNumNota, cSerie, cEmissao, cProd, cNcm, Transform (nAcVlrCtb, "@E 999,999,999,999.99"),;
					       	Transform (nAcZfranca, "@E 999,999,999,999.99"), "",;
					       	Transform (nAcVlrCtbC, "@E 999,999,999,999.99"), Transform (nAcVlrCtbD, "@E 999,999,999,999.99"),;
					       	Transform (nAcVlrCtbBC, "@E 999,999,999,999.99"), Transform (nAcVlrCtbBD, "@E 999,999,999,999.99"),;
				   	   	cCliFor}
		  		ElseIf (nOrd==3)
			        aImp := {cEmissao, cNumNota, cSerie, cProd, cNcm, Transform (nAcVlrCtb, "@E 999,999,999,999.99"),;
					       	Transform (nAcZfranca, "@E 999,999,999,999.99"), "",;
					       	Transform (nAcVlrCtbC, "@E 999,999,999,999.99"), Transform (nAcVlrCtbD, "@E 999,999,999,999.99"),;
					       	Transform (nAcVlrCtbBC, "@E 999,999,999,999.99"), Transform (nAcVlrCtbBD, "@E 999,999,999,999.99"),;
				   	   	cCliFor}
			   EndIf			    
  				
  				FmtLin (aImp, aLay[1],,, @Li)
				
				cNumNota 	:= TRB->NUMNF
				cSerie   	:= TRB->SERIE
				cEmissao	:= TRB->EMISSAO
				cNcm		:= TRB->NCM
				cProd		:= TRB->PRODUTO
				cCliFor 	:= TRB->CLIFOR
				cPauta		:= TRB->PAUTA
				nAcVlrCtb   := 0
				nAcZfranca  := 0
				nAcVlrCtbD  := 0
				nAcVlrCtbC  := 0
				nAcVlrCtbBD := 0
			EndIf
		EndIf
	EndDo

	If TRB->(LastRec()) > 0
		//Quebra do totalizador por dia no termino do processamento
		If (MV_PAR09==1) .And. (nOrd==3) .And. lFirst .And.;
			(TRB->EMISSAO<>aTotDia[1] .Or. TRB->ES<>cCfop .Or. TRB->TIPO<>cTipo)			
			@ Li, 001 PSAY __PrtThinLine()
			Li++

			FmtLin (aTotDia,cTotDia,,"@X",@Li)
			Li++

			aTotDia[1]	:= TRB->EMISSAO
			aTotDia[2]	:= 0
			aTotDia[3]	:= 0
			aTotDia[4]	:= 0
			aTotDia[5]	:= 0
			aTotDia[6]	:= 0
			aTotDia[7]	:= 0
		EndIf
		
		@ Li, 001 PSAY __PrtThinLine()
		Li++
		
		aSort(aALiqs,,,{|x,y| x[1]>y[1]})
		For nX := 1 To Len (aALiqs)
			aContrAliq	:=	{aALiqs[nX][3], aALiqs[nX][4], aALiqs[nX][5], aALiqs[nX][6], aALiqs[nX][7], aALiqs[nX][8]}
			// Imprime, alem do total por aliquota, os CFOPs de cada uma das aliquotas impressas
			If mv_par10 == 1
				nPosAliq := aScan(aResAliCF,{|x| x[1]==aAliqs[nX][1]})
				If nPosAliq > 0
					For nPos := nPosAliq to Len(aResAliCF)
						If aResAliCF[nPos][01] <> aAliqs[nX][1] 
							Exit
						Endif
						If (Li>58)
							cabec (ctitulo, cCabec1, cCabec2, nomeprog, ctamanho, 15)
						EndIf    					                                                                                                                                   
						// Imprime o cabecalho do total por CFOP        
						If nPos == nPosAliq
							cCabec := STR0053 + Space(05) + aResAliCF[nPos][2]
						Else
							cCabec := STR0053
							cCabec := Space(Len(cCabec)) + Space(05) + aResAliCF[nPos][2]
						Endif						
						FmtLin ({cCabec, Transform (aResAliCF[nPos][4], "@E 999,999,999,999.99"), Transform (aResAliCF[nPos][5], "@E 999,999,999,999.99"),;
							Transform (aResAliCF[nPos][6], "@E 999,999,999,999.99"), Transform (aResAliCF[nPos][7], "@E 999,999,999,999.99"),;
							Transform (aResAliCF[nPos][8], "@E 999,999,999,999.99"), Transform (aResAliCF[nPos][9], "@E 999,999,999,999.99")},aLay[2],,"@X",@Li)
					Next
				Endif
			Endif           

			If aAliqs[nX][9]=="S"
				aContrAliq	:=	{0,0,0,0,0,0}
				For nXX := nX To Len(aALiqs)
					If aAliqs[nXX][9]=="S" .And. aAliqs[nX][1]==0
						nX 			 := nXX
						aContrAliq[1]+= aALiqs[nXX][3]
						aContrAliq[2]+= aALiqs[nXX][4]
						aContrAliq[3]+= aALiqs[nXX][5]
						aContrAliq[4]+= aALiqs[nXX][6]
						aContrAliq[5]+= aALiqs[nXX][7]
						aContrAliq[6]+= aALiqs[nXX][8]
					Else
						Exit
					EndIf
				Next nXX
			EndIf

			FmtLin ({STR0031+Transform (aAliqs[nX][1],PesqPict("SB1","B1_VLR_COF",TamSx3("B1_VLR_COF")[1])), Transform (aContrAliq[1], "@E 999,999,999,999.99"), Transform (aContrAliq[2], "@E 999,999,999,999.99"),;
						Transform (aContrAliq[3], "@E 999,999,999,999.99"), Transform (aContrAliq[4], "@E 999,999,999,999.99"),;
						Transform (aContrAliq[5], "@E 999,999,999,999.99"), Transform (aContrAliq[6], "@E 999,999,999,999.99")},aLay[2],,"@X",@Li)
			Li++
		Next (nX)
		
		FmtLin ({Iif (TRB->ES=="S",STR0015+STR0017, STR0015+STR0016), Transform (nValCont, "@E 999,999,999,999.99"), Transform (nZFranca, "@E 999,999,999,999.99"),;
					Transform (nValDebi, "@E 999,999,999,999.99"), Transform (nValCred, "@E 999,999,999,999.99"),;
					Transform (nBasDebi, "@E 999,999,999,999.99"), Transform (nBasCred, "@E 999,999,999,999.99")}, aLay[2],,"@X",@Li)
		
		Li+=2
		@ Li, 001 Psay __PrtThinLine()
		Li++
		@ Li, 001 Psay STR0032 //"Contribuicao : "
		Li	+=	2
		//Ordena o array por aliquota + CFOP  
		Asort(aAliqCFGer,,,{|x,y|Str(x[1])+x[2] < Str(y[1])+y[2]})					
		nContrAli	:= 0
		nAliq		:= 0 
		For nCt := 1 To len(aContrAliq)
  			aContrAliq[nCt] := 0
		Next nCt   		
		// Imprime o valor apurado por aliquota ou por aliquota + cfop
		For nX := 1 To Len(aAliqCFGer)		                
			If (Li>58)
				cabec (ctitulo, cCabec1, cCabec2, nomeprog, ctamanho, 15)
			EndIf		
			If nAliq <> aAliqCFGer[nX][1] 						
				If nX <> 1 
					@Li, 001 PSAY STR0047 + Space(04) + Transform(Abs(nContrAli),PesqPict("SD2","D2_TOTAL",14)) + IIf(nContrAli < 0,"  (C)","  (D)")+ Space(34)+ Transform(Abs(aContrAliq[1]),PesqPict("SD2","D2_TOTAL",14)) + Space(6)+  Transform(Abs(aContrAliq[2]),PesqPict("SD2","D2_DESCZFR",14))+ Space(16)+ Transform(Abs(aContrAliq[3]),PesqPict("SD2","D2_TOTAL",14))+;
				  					  Space(6) +  Transform(Abs(aContrAliq[4]),PesqPict("SD2","D2_TOTAL",14)) + Space(8)+  Transform(Abs(aContrAliq[5]),PesqPict("SD2","D2_TOTAL",14)) + Space(6)+  Transform(Abs(aContrAliq[6]),PesqPict("SD2","D2_TOTAL",14))					
					Li += 2
					nContrAli 	:= 0            
					For nCt := 1 To len(aContrAliq)
						aContrAliq[nCt] := 0
					Next nCt   					
				Endif
				@Li, 001 PSAY STR0029 + Transform(aAliqCFGer[nX][1],PesqPict("SB1","B1_VLR_COF",TamSx3("B1_VLR_COF")[1]))
				Li++  
				If mv_par10 == 1
					@Li, 001 PSAY STR0054
					Li++
				Endif
				nAliq 	:= aAliqCFGer[nX][1]
			Endif
			 
			If mv_par10 == 1
				@Li, 001 PSAY aAliqCFGer[nX][2] + Space(06) + Transform(Abs(aAliqCFGer[nX][3]),PesqPict("SD2","D2_TOTAL",14)) + IIf(aAliqCFGer[nX][3] < 0,"  (C)","  (D)")+ Space(34)+ Transform(Abs(aAliqCFGer[nX][4]),PesqPict("SD2","D2_TOTAL",14)) + Space(6)+  Transform(Abs(aAliqCFGer[nX][5]),PesqPict("SD2","D2_DESCZFR",14))+ Space(16)+ Transform(Abs(aAliqCFGer[nX][6]),PesqPict("SD2","D2_TOTAL",14))+;
								  Space(6) +  Transform(Abs(aAliqCFGer[nX][7]),PesqPict("SD2","D2_TOTAL",14)) + Space(8)+  Transform(Abs(aAliqCFGer[nX][8]),PesqPict("SD2","D2_TOTAL",14)) + Space(6)+  Transform(Abs(aAliqCFGer[nX][9]),PesqPict("SD2","D2_TOTAL",14))
				Li++                                                              
			Endif             
			nContrAli	 += aAliqCFGer[nX][3]              
			aContrAliq[1]+= aAliqCFGer[nX][4] 
			aContrAliq[2]+= aAliqCFGer[nX][5] 
			aContrAliq[3]+= aAliqCFGer[nX][6]
			aContrAliq[4]+= aAliqCFGer[nX][7] 
			aContrAliq[5]+= aAliqCFGer[nX][8] 
			aContrAliq[6]+= aAliqCFGer[nX][9]	 		
			aSomaAliq[1] += aAliqCFGer[nX][4]            
			aSomaAliq[2] += aAliqCFGer[nX][5]
			aSomaAliq[3] += aAliqCFGer[nX][6]
			aSomaAliq[4] += aAliqCFGer[nX][7]
			aSomaAliq[5] += aAliqCFGer[nX][8]
			aSomaAliq[6] += aAliqCFGer[nX][9] 			
		Next

		If (Li>58)
			cabec (ctitulo, cCabec1, cCabec2, nomeprog, ctamanho, 15)
		EndIf                                                                                                                                       

		@Li, 001 PSAY STR0047 + Space(04) + Transform(Abs(nContrAli),PesqPict("SD2","D2_TOTAL",14)) + IIf(nContrAli < 0,"  (C)","  (D)")+ Space(34)+ Transform(Abs(aContrAliq[1]),PesqPict("SD2","D2_TOTAL",14)) + Space(6)+  Transform(Abs(aContrAliq[2]),PesqPict("SD2","D2_DESCZFR",14))+ Space(16)+ Transform(Abs(aContrAliq[3]),PesqPict("SD2","D2_TOTAL",14))+;
						  Space(6) +  Transform(Abs(aContrAliq[4]),PesqPict("SD2","D2_TOTAL",14)) + Space(8)+  Transform(Abs(aContrAliq[5]),PesqPict("SD2","D2_TOTAL",14)) + Space(6)+  Transform(Abs(aContrAliq[6]),PesqPict("SD2","D2_TOTAL",14))
		Li+=2

		//"Total Apurado............: "
		@Li, 001 PSAY STR0039
		Li++
		@Li, 011 PSAY Transform(Abs(nGValDebi-nGValCred),PesqPict("SD2","D2_TOTAL",14)) + IIf(nGValDebi-nGValCred < 0,"  (C)","  (D)")+ Space(34)+Transform(Abs(aSomaAliq[1]),PesqPict("SD2","D2_TOTAL",14)) + Space(6)+  Transform(Abs(aSomaAliq[2]),PesqPict("SD2","D2_DESCZFR",14))+ Space(16)+ Transform(Abs(aSomaAliq[3]),PesqPict("SD2","D2_TOTAL",14))+;
	   	           Space(6) +  Transform(Abs(aSomaAliq[4]),PesqPict("SD2","D2_TOTAL",14)) + Space(8)+  Transform(Abs(aSomaAliq[5]),PesqPict("SD2","D2_TOTAL",14)) + Space(6)+  Transform(Abs(aSomaAliq[6]),PesqPict("SD2","D2_TOTAL",14)) 
   	Li++
		Li++                         		
		//"Total das Retencoes........: "
		@Li, 001 PSAY STR0143 // "Total de Retenção(Modalidade da Dedução: Vencimento)........: "  --> Empresas que nao sao de Direito Publico
		Li++
		@Li, 011 PSAY Transform(IIF(cTipo=="PIS",aRet[1],aRet[2]),PesqPict("SD2","D2_TOTAL",14))
		Li++
		Li++ 
		@Li, 001 PSAY STR0144 //"Total de Retenção - Orgãos Públicos(Modalidade da Dedução: Pagamento)........: "
		Li++
		@Li, 011 PSAY Transform(IIF(cTipo=="PIS",(aDedRet[1]-aRet[1]),(aDedRet[2]-aRet[2])),PesqPict("SD2","D2_TOTAL",14))
		Li++          
		Li++  
		nContrAli := IIF(cTipo=="PIS",(nGValDebi-nGValCred)-aDedRet[1],(nGValDebi-nGValCred)-aDedRet[2])  
		@Li, 001 PSAY STR0018
		Li++ 
		@Li, 011 PSAY Transform(IIF(cTipo=="PIS",Abs((nGValDebi-nGValCred)-aDedRet[1]),Abs((nGValDebi-nGValCred)-aDedRet[2])),PesqPict("SD2","D2_TOTAL",14))+;
			  				IIf(nContrAli < 0,"  (C)","  (D)") + Space(34) + Transform(Abs(aSomaAliq[1]),PesqPict("SD2","D2_TOTAL",14)) + Space(6)+  Transform(Abs(aSomaAliq[2]),PesqPict("SD2","D2_DESCZFR",14))+;
							Space(16)+ Transform(Abs(aSomaAliq[3]),PesqPict("SD2","D2_TOTAL",14))+ Space(6) +  Transform(Abs(aSomaAliq[4]),PesqPict("SD2","D2_TOTAL",14)) + Space(8)+  Transform(Abs(aSomaAliq[5]),PesqPict("SD2","D2_TOTAL",14))+;
							Space(06)+ Transform(Abs(aSomaAliq[6]),PesqPict("SD2","D2_TOTAL",14))//"Total da Contribuicao : "
		If cTipo == "PIS"
			aTotApur[01][01]  += nGValDebi-nGValCred
			aTotApur[01][02]  += aDedRet[1]
			aTotApur[01][03]  += (nGValDebi-nGValCred)-aDedRet[1]
		Else
			aTotApur[02][01]  += nGValDebi-nGValCred
			aTotApur[02][02]  += aDedRet[2]
			aTotApur[02][03]  += (nGValDebi-nGValCred)-aDedRet[2]
		Endif
	Endif
Return (.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AjustaSX1 ³ Autor ³ Nereu Humberto Jr     ³ Data ³03.07.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria as perguntas necesarias para o programa                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1()

Local cPerg    := "MTR906"
Local aHelpPor :={}
Local aHelpEng :={}
Local aHelpSpa :={}

aHelpPor	:=	{}
aHelpEng	:=	{}
aHelpSpa	:=	{}
//
/*-----------------------MV_PAR05--------------------------*/
Aadd( aHelpPor, "Informe numero do livro a ser processado" )
Aadd( aHelpEng, "Ledger Book number                      " )
Aadd( aHelpSpa, "Numero del Libro Fiscal                 " ) 

u_FTTVSX001(cPerg, "05","Livro Selecionado","Livro Seleccionado"	,"Selected Book","mv_ch5","C",3,0,0,"G",  			, "   ","","","mv_par05"," "," "," ","","","","","","","","","","","",""," ",aHelpPor,aHelpEng,aHelpSpa)

/*-----------------------MV_PAR06--------------------------*/
aHelpPor	:=	{}
aHelpEng	:=	{}
aHelpSpa	:=	{}
Aadd( aHelpPor, "Informe se deseja imprimir os valores   " )
Aadd( aHelpPor, "por filial, apresentando um resumo ao   " )
Aadd( aHelpPor, "final com o total das movimentacoes     " ) 
Aadd( aHelpEng, "Informe se deseja imprimir os valores   " )
Aadd( aHelpEng, "por filial, apresentando um resumo ao   " )
Aadd( aHelpEng, "final com o total das movimentacoes     " ) 
Aadd( aHelpSpa, "Informe se deseja imprimir os valores   " )
Aadd( aHelpSpa, "por filial, apresentando um resumo ao   " )
Aadd( aHelpSpa, "final com o total das movimentacoes     " ) 

u_FTTVSX001(cPerg, "06","Processa Filiais ?","Processa Filiais ?","Processa Filiais ?","mv_ch6","N",1,0,0,"C",,"","","","mv_par06","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","",""," ",aHelpPor,aHelpEng,aHelpSpa)

/*-----------------------MV_PAR07--------------------------*/
aHelpPor	:=	{}
aHelpEng	:=	{}
aHelpSpa	:=	{}
Aadd( aHelpPor, "Informe a filial inicial a ser          " )
Aadd( aHelpPor, "processada, caso deseje imprimir o      " )
Aadd( aHelpPor, "relatorio por filial.                   " ) 
Aadd( aHelpEng, "Informe a filial inicial a ser          " )
Aadd( aHelpEng, "processada, caso deseje imprimir o      " )
Aadd( aHelpEng, "relatorio por filial.                   " ) 
Aadd( aHelpSpa, "Informe a filial inicial a ser          " )
Aadd( aHelpSpa, "processada, caso deseje imprimir o      " )
Aadd( aHelpSpa, "relatorio por filial.                   " ) 
u_FTTVSX001(cPerg, "07","Da Filial ?","Da Filial ?","Da Filial ?","mv_ch7","C",2,0,0,"G",,"","","","mv_par07","","","","","","","","","","","","","","",""," ",aHelpPor,aHelpEng,aHelpSpa)

/*-----------------------MV_PAR08--------------------------*/
aHelpPor	:=	{}
aHelpEng	:=	{}
aHelpSpa	:=	{}
Aadd( aHelpPor, "Informe a filial final a ser            " )
Aadd( aHelpPor, "processada, caso deseje imprimir o      " )
Aadd( aHelpPor, "relatorio por filial.                   " ) 
Aadd( aHelpEng, "Informe a filial final a ser            " )
Aadd( aHelpEng, "processada, caso deseje imprimir o      " )
Aadd( aHelpEng, "relatorio por filial.                   " ) 
Aadd( aHelpSpa, "Informe a filial final a ser            " )
Aadd( aHelpSpa, "processada, caso deseje imprimir o      " )
Aadd( aHelpSpa, "relatorio por filial.                   " ) 
u_FTTVSX001(cPerg, "08","Ate Filial ?","Ate Filial ?","Ate Filial ?","mv_ch8","C",2,0,0,"G",,"","","","mv_par08","","","","","","","","","","","","","","",""," ",aHelpPor,aHelpEng,aHelpSpa)

/*-----------------------MV_PAR09--------------------------*/
aHelpPor	:=	{}
aHelpEng	:=	{}
aHelpSpa	:=	{}
Aadd( aHelpPor, "Informe se deseja imprimir os totais   " )
Aadd( aHelpPor, "por dia. " )
Aadd( aHelpEng, "Informe se deseja imprimir os totais   " )
Aadd( aHelpEng, "por dia. " )
Aadd( aHelpSpa, "Informe se deseja imprimir os totais   " )
Aadd( aHelpSpa, "por dia. " ) 
u_FTTVSX001(cPerg, "09","Total por Dia ?","Total por Dia ?","Total por Dia ?","mv_ch9","N",1,0,0,"C",,"","","","mv_par09","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","",""," ",aHelpPor,aHelpEng,aHelpSpa)

/*-----------------------MV_PAR10--------------------------*/
aHelpPor	:=	{}
aHelpEng	:=	{}
aHelpSpa	:=	{}
Aadd( aHelpPor, "Informe se deseja detalhar os CFOPs    " )
Aadd( aHelpPor, "processados em cada aliquota           " )
Aadd( aHelpPor, "apresentada no relatório.              " )
Aadd( aHelpEng, "Informe se deseja detalhar os CFOPs    " )
Aadd( aHelpEng, "processados em cada aliquota           " )
Aadd( aHelpEng, "apresentada no relatório.              " )
Aadd( aHelpSpa, "Informe se deseja detalhar os CFOPs    " )
Aadd( aHelpSpa, "processados em cada aliquota           " )
Aadd( aHelpSpa, "apresentada no relatório.              " )
u_FTTVSX001(cPerg, "10","Detalha CFOP ?","Detalha CFOP","Detalha CFOP","mv_cha","N",1,0,2,"C",,"","","","mv_par10","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","",""," ",aHelpPor,aHelpEng,aHelpSpa)

/*-----------------------MV_PAR11--------------------------*/
aHelpPor	:=	{}
aHelpEng	:=	{}
aHelpSpa	:=	{}
Aadd( aHelpPor, "Informe se deseja agrupar os itens     " )
Aadd( aHelpPor, "das notas fiscais ao emitir relatório  " )
Aadd( aHelpPor, "de forma analítica                     " )
Aadd( aHelpEng, "Informe se deseja agrupar os itens     " )
Aadd( aHelpEng, "das notas fiscais ao emitir relatório  " )
Aadd( aHelpEng, "de forma analítica                     " )
Aadd( aHelpSpa, "Informe se deseja agrupar os itens     " )
Aadd( aHelpSpa, "das notas fiscais ao emitir relatório  " )
Aadd( aHelpSpa, "de forma analítica                     " )
u_FTTVSX001(cPerg, "11","Resume as Notas Fiscais?","Resume as Notas Fiscais?","Resume as Notas Fiscais?","mv_chb","N",1,0,2,"C",,"","","","mv_par11","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","",""," ",aHelpPor,aHelpEng,aHelpSpa)
/*-----------------------MV_PAR12--------------------------*/
aHelpPor	:=	{}
aHelpEng	:=	{}
aHelpSpa	:=	{}
Aadd( aHelpPor, "Informe se o relatório a ser processado" )
Aadd( aHelpPor, "é referente à apuração do PIS / COFINS " )
Aadd( aHelpPor, "Cumulativo / Não cumulativo.	        " ) 
Aadd( aHelpPor, "Sim = Cumulativo / Não cumulativo.	    " )
Aadd( aHelpPor, "Não Cumulativo = Apenas não cumulativo." ) 
Aadd( aHelpPor, "Não = Não Imprime." )
Aadd( aHelpEng, "Informe se o relatório a ser processado" )
Aadd( aHelpEng, "é referente à apuração do PIS / COFINS " )
Aadd( aHelpEng, "Cumulativo / Não cumulativo.           " )
Aadd( aHelpEng, "Sim = Cumulativo / Não cumulativo.	    " )
Aadd( aHelpEng, "Não Cumulativo = Apenas não cumulativo." ) 
Aadd( aHelpEng, "Não = Não Imprime." )
Aadd( aHelpSpa, "Informe se o relatório a ser processado" )
Aadd( aHelpSpa, "é referente à apuração do PIS / COFINS " )
Aadd( aHelpSpa, "Cumulativo / Não cumulativo.           " )
Aadd( aHelpSpa, "Sim = Cumulativo / Não cumulativo.	    " )
Aadd( aHelpSpa, "Não Cumulativo = Apenas não cumulativo." ) 
Aadd( aHelpSpa, "Não = Não Imprime." )
u_FTTVSX001(cPerg, "12","Imp. Cum/Não Cum?","Imp. Cum/Não Cum?","Imp. Cum/Não Cum?","mv_chc","N",1,0,3,"C",,"","","","mv_par12","Sim","Sim","Sim","","Não Cumulativo","Não Cumulativo","Não Cumulativo","Não","Não","Não","","","","",""," ",aHelpPor,aHelpEng,aHelpSpa)
/*-----------------------MV_PAR13--------------------------*/
aHelpPor	:=	{}
aHelpEng	:=	{}
aHelpSpa	:=	{}
Aadd( aHelpPor, "Informe se o relatório a ser processado" )
Aadd( aHelpPor, "é referente à apuração do PIS / COFINS " )
Aadd( aHelpPor, "com Diferimento de Orgãos Públicos.    " ) 
Aadd( aHelpPor, "Sim = Diferimento Orgãos Públicos.	    " )
Aadd( aHelpPor, "Não = Apuração Normal." ) 

Aadd( aHelpEng, "Informe se o relatório a ser processado" )
Aadd( aHelpEng, "é referente à apuração do PIS / COFINS " )
Aadd( aHelpEng, "com Diferimento de Orgãos Públicos.    " ) 
Aadd( aHelpEng, "Sim = Diferimento Orgãos Públicos.	    " )
Aadd( aHelpEng, "Não = Apuração Normal." ) 

Aadd( aHelpSpa, "Informe se o relatório a ser processado" )
Aadd( aHelpSpa, "é referente à apuração do PIS / COFINS " )
Aadd( aHelpSpa, "com Diferimento de Orgãos Públicos.    " ) 
Aadd( aHelpSpa, "Sim = Diferimento Orgãos Públicos.	    " )
Aadd( aHelpSpa, "Não = Apuração Normal." ) 
u_FTTVSX001(cPerg, "13","Dif. Orgão Público?","Dif. Orgão Público?","Dif. Orgão Público?","mv_chd","N",1,0,2,"C",,"","","","mv_par13","Sim","Sim","Sim","","Não","Não","Não","","Não","Não","Não","","","",""," ",aHelpPor,aHelpEng,aHelpSpa)

/*-----------------------MV_PAR14--------------------------*/
aHelpPor	:=	{}
aHelpEng	:=	{}
aHelpSpa	:=	{}
Aadd( aHelpPor, "Informe se o resumo utilizara quebra   " )
Aadd( aHelpPor, "por CFOP e Cliente/Fornecedor ou apenas" )
Aadd( aHelpPor, "por CFOP.								" ) 
Aadd( aHelpPor, "1 = CFOP e Clie/Forn					" )
Aadd( aHelpPor, "2 = CFOP								" ) 

Aadd( aHelpEng, "Informe se o resumo utilizara quebra   " )
Aadd( aHelpEng, "por CFOP e Cliente/Fornecedor ou apenas" )
Aadd( aHelpEng, "por CFOP.								" ) 
Aadd( aHelpEng, "1 = CFOP e Clie/Forn					" )
Aadd( aHelpEng, "2 = CFOP								" ) 

Aadd( aHelpSpa, "Informe se o resumo utilizara quebra   " )
Aadd( aHelpSpa, "por CFOP e Cliente/Fornecedor ou apenas" )
Aadd( aHelpSpa, "por CFOP.								" ) 
Aadd( aHelpSpa, "1 = CFOP e Clie/Forn					" )
Aadd( aHelpSpa, "2 = CFOP								" ) 

u_FTTVSX001(cPerg, "14","Quebra do Resumo","Quebra do Resumo","Quebra do Resumo","mv_che","N",1,0,1,"C",,"","","","mv_par14","1-CFOP+CliFor","1-CFOP+CliFor","1-CFOP+CliFor","","2-CFOP","2-CFOP","2-CFOP","","","","","","","",""," ",aHelpPor,aHelpEng,aHelpSpa)

/*-----------------------MV_PAR15--------------------------*/
aHelpPor	:=	{}
aHelpEng	:=	{}
aHelpSpa	:=	{}
Aadd( aHelpPor, "Informe o tipo de apuração:            " )
Aadd( aHelpPor, "1 - Lucro Presumido - R CX(Caixa)      " )
Aadd( aHelpPor, "2 - Lucro Presumido - R CP(Competência)" )
Aadd( aHelpPor, "Obs: Válido apenas para Imp.Cumulativo " ) 
Aadd( aHelpPor, "/Não Cumulativo = Sim						" )

Aadd( aHelpEng, "Informe o tipo de apuração:            " )
Aadd( aHelpEng, "1 - Lucro Presumido - R CX(Caixa)      " )
Aadd( aHelpEng, "2 - Lucro Presumido - R CP(Competência)" )
Aadd( aHelpPor, "Obs: Válido apenas para Imp.Cumulativo " ) 
Aadd( aHelpPor, "/Não Cumulativo = Sim						" ) 

Aadd( aHelpSpa, "Informe o tipo de apuração:            " )
Aadd( aHelpSpa, "1 - Lucro Presumido - R CX(Caixa)      " )
Aadd( aHelpSpa, "2 - Lucro Presumido - R CP(Competência)" )
Aadd( aHelpPor, "Obs: Válido apenas para Imp.Cumulativo " ) 
Aadd( aHelpPor, "/Não Cumulativo = Sim						" ) 

u_FTTVSX001(cPerg, "15","Tipo de apuração","Tipo de apuração","Tipo de apuração","mv_chf","N",1,0,1,"C",,"","","","mv_par15","1-Lucro Pres.CX","1-Lucro Pres.CX","1-Lucro Pres.CX","","2-Lucro Pres.CP","2-Lucro Pres.CP","2-Lucro Pres.CP","","","","","","","",""," ",aHelpPor,aHelpEng,aHelpSpa)

Return




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FsCalRt2  ³ Autor ³ LMDT Serviços         ³ Data ³27.06.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cópia ajustada da função FsCalcRet - Deducao do contas      ³±±
±±³          ³a receber dos valores pagos por retencao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: [1] Valor Total de Retencao de PIS                   ³±±
±±³Retorno   ³ExpA2: [2] Valor Total de Retencao de COFINS                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpD1: Data Inicial                                         ³±±
±±³Parametros³ExpD2: Data Final                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FsCalRt2(dDtIni,dDtFim,lRelatorio,aTrb,nFilial,cBckFil,aRet,aCumNCum,lRelConf,cRelFil,lImpValBruto,lOrgPub,lCTipVL)
Local lM996E1	 :=	ExistBlock ("M996E1")
Local aArea      := GetArea()
Local aValor     := {0,0}
Local cArqInd    := ""
Local cChave     := ""
Local cFiltro    := ""
Local nIndex     := 0
Local aBaixas    := {}
Local nX         := 0
Local cAliasSE1  := "SE1"
Local lQuery     := .F.
Local cQuebra    := ""
Local cFatura    := ""
Local cCliente   := ""
Local cTpFatura  := ""
Local cIndex     := ""
Local cCondicao  := ""
Local aAreaSe1	 := {}
Local aAreaSe5	 :=	{}
Local lAchouAbat := .F.
Local lB1TPREG   := SB1->(FieldPos("B1_TPREG")) > 0
Local aComp	   :=	{}
Local nTotAbImp  := 0
Local nTotAbt	   := 0
Local nAbtPis	   := 0
Local nAbtCof	   := 0
Local nPerc	   := 0
Local nPisProp   := 0
Local nCofProp   := 0
Local nVlrProp   := 0    
Local nPropFatBx := 0
Local lM996DRet  := ExistBlock("M996DRet")
Local lCumNCum	 :=	aCumNCum<>Nil .And. ValType(aCumNCum)=="A" .And. Len(aCumNCum)==4
Local aRelImp    := {0,0}
Local cCpVlPisSa := ""
Local nPsVlPisSa := 0
Local cCpVlCofSa := ""
Local nPsVlCofSa := 0
Local aAuxCNC    :=	{0,0,0,0}
Local cRetBaiEmi := GetNewPar("MV_BR10925",.F.) //1-Baixa 2-Emissão
Local aF600Aux	:= {}

#IFDEF TOP
	Local aStruSE1  := {}
	Local cQuery    := ""
#ENDIF

Default lRelatorio	:=	.F.
Default nFilial		:= 0
Default cBckFil     := ""     
Default aTrb		:= {}
Default aRet 		:= {0,0}
Default lRelConf	:= .F.
Default cRelFil     := ""   
Default lImpValBruto:= .F.           
Default lOrgPub		:= .F.           

#IFNDEF TOP
	Return aRelImp
#ENDIF
           
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Considera somente titulo do tipo 'VL' para o relatorio MATR946 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Default lCTipVL     := .F.       
If (lRelatorio)
	If Len (aTrb)==0
		MTrbRel (@aTrb,lCTipVL)
	Else
		//Apaga TRB Criado
		MTrbRel (@aTrb)
		Return (.T.)
	EndIf
EndIf

//Abro SE5 com outro alias sem filtro
If Select("__SE5") == 0
	ChkFile("SE5",.F.,"__SE5")	
Endif
//#FAP
If Select("__SE1") == 0
	ChkFile("SE1",.F.,"__SE1")	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Selecionando Registros recebidos de orgaos publicos.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAliasSE5 := "SE5"
dbSelectArea(cAliasSE5)

#IFDEF TOP
    If (TcSrvType ()<>"AS/400")
    	cAliasSE5	:=	GetNextAlias()
		
		// Se a tabela for compartilhada e a opcao escolhida for considera filial = Nao, devera ser verificado o campo
		// MSFIL, caso exista na base.
		
	    If FWModeAccess("SE5",3)=="C" .And. SE5->(FieldPos("E5_MSFIL")) > 0 .And. nFilial == 2
	    	cFiltro := "%"
			If lRelConf   //mando a filial que estou processando no relatorio de conferencia por esta variavel -> cRelFil
				cFiltro += "SE5.E5_MSFIL = '"+ %Exp:( cRelFil )% +"' AND "
			Else
				cFiltro += "SE5.E5_MSFIL = '"+ %Exp:(SM0->M0_CODFIL)% +"' AND "
			Endif
		Else
			cFiltro := "%"
			cFiltro += "SE5.E5_FILIAL = '"+ %Exp:( xFilial("SE5") )% +"' AND "
		Endif
		
		cFiltro += "%"

    	BeginSql Alias cAliasSE5
    	
    		COLUMN E5_DATA AS DATE
			
			SELECT				
				SE5.*
			FROM 
				%Table:SE5% SE5
			WHERE
				SE5.E5_DATA >= %Exp:DToS(dDtIni)% AND
				SE5.E5_DATA <= %Exp:Dtos(dDtFim)% AND
				SE5.E5_MOTBX <> %Exp:Space(Len(SE5->E5_MOTBX))% AND
				((SE5.E5_TIPODOC IN ('VL','BA','V2','LJ') AND SE5.E5_RECPAG ='R') OR
				(SE5.E5_TIPODOC = 'ES' AND SE5.E5_RECPAG ='P')) AND
				SE5.E5_SITUACA = ' ' AND
				%Exp:cFiltro%
				SE5.%NotDel%
		EndSql
	Else
#ENDIF
	    cIndex	:= 'E5_MSFIL'//CriaTrab(NIL,.F.)
	    
	    
	    If FWModeAccess("SE5",3)=="C" .And. (cAliasSE5)->(FieldPos("E5_MSFIL")) > 0 .And. nFilial == 2
			If lRelConf   //mando a filial que estou processando no relatorio de conferencia por esta variavel -> cRelFil
				cFiltro := "E5_MSFIL=='"+cRelFil+"'.And."
			Else
				cFiltro := "E5_MSFIL=='"+SM0->M0_CODFIL+"'.And."
			Endif
		Else
			cFiltro := "E5_FILIAL=='"+xFilial("SE5")+"'.And."
		Endif

		cFiltro += "Dtos(E5_DATA)>='" + Dtos(dDtIni) + "'.And."
		cFiltro += "Dtos(E5_DATA)<='" + Dtos(dDtFim) + "'.And."
		cFiltro += "E5_MOTBX != '"+Space(Len(SE5->E5_MOTBX))+"'.And."
		cFiltro += "((E5_TIPODOC $ ('VL,BA,V2,LJ') .And. E5_RECPAG=='R') .OR. "
		cFiltro += "(E5_TIPODOC == 'ES' .And. E5_RECPAG =='P')) .And. E5_SITUACA==' '"
		cChave   := "E5_FILIAL+DTOS(E5_DATA)+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_MOTBX+E5_SEQ"
		IndRegua(cAliasSE5,cIndex,cChave,,cFiltro)
		nIndex := RetIndex(cAliasSE5)
		
		#IFNDEF TOP
			DbSetIndex (cIndex+OrdBagExt ())
		#ENDIF
		
		DbSetOrder(nIndex+1)
		MsSeek(xFilial(), .T.)
#IFDEF TOP
	Endif
#ENDIF 

cQuebra := (cAliasSE5)->E5_PREFIXO+(cAliasSE5)->E5_NUMERO+(cAliasSE5)->E5_PARCELA+(cAliasSE5)->E5_TIPO+(cAliasSE5)->E5_CLIFOR+(cAliasSE5)->E5_LOJA
While (!(cAliasSE5)->(Eof ()) .And. xFilial("SE5")==(cAliasSE5)->E5_FILIAL)
    
	// Caso a tabela seja compartilhada, devera processar somente uma filial para q nao seja multiplicado 
	//os valores pela quantidade de filiais existentes, e caso a pergunta "considera filiais" = Sim.
	If (FWModeAccess("SE5",3)=="C" .And. cFilAnt <> cBckFil .And. nFilial == 1)
		(cAliasSE5)->(DbSkip())  
		Loop
	Endif    
	
	// Ponto de Entrada para excluir determinadas baixas do processamento
	If lM996DRet
		If ExecBlock("M996DRet",.F.,.F.,)
			(cAliasSE5)->(dbSkip())
			Loop
		Endif
	Endif                 
	
	//Verifica se tem baixa cancelada
   If TemBxCanc((cAliasSE5)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ))
	  (cAliasSE5)->( dbskip())
	  loop
   EndIf        
    #IFDEF TOP
		aadd (aBaixas, {(cAliasSE5)->E5_MOTBX, (cAliasSE5)->E5_SEQ, (cAliasSE5)->R_E_C_N_O_, (cAliasSE5)->E5_VALOR })
	#ELSE   
	    aadd (aBaixas, {(cAliasSE5)->E5_MOTBX, (cAliasSE5)->E5_SEQ, (cAliasSE5)->(Recno ()), (cAliasSE5)->E5_VALOR })			
	#ENDIF
        
	aAreaSE5   		:= (cAliasSE5)->(GetArea())
        aComp		:={}
        aComp		:=Baixas((cAliasSE5)->E5_NATUREZA,(cAliasSE5)->E5_PREFIXO,(cAliasSE5)->E5_NUMERO,(cAliasSE5)->E5_PARCELA,(cAliasSE5)->E5_TIPO,,"R",(cAliasSE5)->E5_CLIFOR,(cAliasSE5)->E5_DATA,(cAliasSE5)->E5_LOJA)
	RestArea(aAreaSe5)	
        
	DbSelectArea(cAliasSE5)
	(cAliasSE5)->(DbSkip ())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a quebra da baixa do titulo                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cQuebra<>(cAliasSE5)->E5_PREFIXO+(cAliasSE5)->E5_NUMERO+(cAliasSE5)->E5_PARCELA+(cAliasSE5)->E5_TIPO+(cAliasSE5)->E5_CLIFOR+(cAliasSE5)->E5_LOJA .Or. (cAliasSE5)->(Eof ()))
		If (!Empty (aBaixas))
			aAreaSe5	:=	(cAliasSE5)->(GetArea())
			For nX := 1 To Len(aBaixas)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posicionando Registros.                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SE5")
				MsGoto (aBaixas[nX][3])
				If SE5->E5_TIPODOC$"VL#BA#V2#LJ"
					DbSelectArea ("SE1")
					SE1->(DbSetOrder(2))
					If (SE1->(MsSeek(xFilial("SE1")+SE5->E5_CLIFOR+SE5->E5_LOJA+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO)))
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Tratamento para fatura a receber                             ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
						If (AllTrim (SE1->E1_FATURA)=="NOTFAT")
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Calculo do valor total da fatura a receber                   ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cFatura    := SE1->E1_PREFIXO+SE1->E1_NUM
							cCliente   := SE1->E1_CLIENTE+SE1->E1_LOJA
							cTpFatura  := SE1->E1_TIPO
							nVlrFatura := 0					//Valor total da fatura
							nVlrbxFat  := SE5->E5_VALOR	//Valor baixado da fatura
							
							dbSelectArea("SE1")
							dbSetOrder(1)
							MsSeek(xfilial("SE1")+cFatura)
							While !Eof() .And. xFilial("SE1") == SE1->E1_FILIAL .And. SE1->E1_PREFIXO+SE1->E1_NUM == cFatura
							
								If SE1->E1_TIPO == cTpFatura
								
									nVlrFatura += SE1->E1_VALOR
									
								EndIf
								         
								dbSelectArea("SE1")
								dbSkip()
							EndDo
							//Proporcao do valor baixado da fatura
							nPropFatBx := nVlrbxFat / nVlrFatura
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Verifica os titulos de origem da fatura                      ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							dbSelectArea("SE1")
							dbSetOrder(10)
							MsSeek(xFilial("SE1")+cCliente+cFatura,.F.)
							While ( !Eof() .And. xFilial("SE1") == SE1->E1_FILIAL .And.;
								SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_FATPREF+SE1->E1_FATURA == cCliente+cFatura )
								If SE1->E1_SCORGP == "1" .And. !(SE1->E1_TIPO$MVABATIM+"|PIS|COF|CSL") .And. lOrgPub
									//retorno valor deste titulo que foi faturado.
									nPisProp := 0
									nCofProp := 0
									nVlrProp := 0
									
									VlrFat(nPropFatBx,@nPisProp,@nCofProp,@nVlrProp)										

									If lRelatorio
										RecLock (aTrb[1][1],.T.)
										(aTrb[1][1])->TRB_PREFIX	:=	SE1->E1_PREFIXO
										(aTrb[1][1])->TRB_NUMERO	:=	SE1->E1_NUM
										(aTrb[1][1])->TRB_PARCEL	:=	SE1->E1_PARCELA
										(aTrb[1][1])->TRB_TIPO		:=	SE1->E1_TIPO
										(aTrb[1][1])->TRB_CLIENT	:=	SE1->E1_CLIENTE
										(aTrb[1][1])->TRB_LOJA		:=	SE1->E1_LOJA
										(aTrb[1][1])->TRB_EMISSA	:=	SE1->E1_EMISSAO
										(aTrb[1][1])->TRB_VENCTO	:=	SE1->E1_VENCREA
										(aTrb[1][1])->TRB_VALOR  	:=	SE1->E1_VALOR
										(aTrb[1][1])->TRB_SALDO  	:=	SE1->E1_SALDO
										(aTrb[1][1])->TRB_VALTIT	:=	nVlrProp
										(aTrb[1][1])->TRB_VLPIS 	:=	nPisProp
										(aTrb[1][1])->TRB_VLCOF 	:=	nCofProp
										(aTrb[1][1])->TRB_VLPAGO	:=	(SE1->E1_VALOR-SE1->E1_PIS-SE1->E1_COFINS-SE1->E1_CSLL-SE1->E1_IRRF-SE1->E1_INSS)
										
										(aTrb[1][1])->TRB_SCORGP	:=	"1"
										(aTrb[1][1])->TRB_DTPAG0	:=	SE5->E5_DATA	//Data do ultimo pagamento
										(aTrb[1][1])->TRB_PIS		:=	SE1->E1_PIS
										(aTrb[1][1])->TRB_COFINS	:=	SE1->E1_COFINS
										MsUnLock ()
									Else
										aValor[1] += nPisProp
										aValor[2] += nCofProp
									EndIf
								EndIf
								SE1->(dbSkip())
							EndDo
						ElseIf ((SE1->E1_SCORGP=="1") .And. lOrgPub .And. Empty(E1_FATURA) .And. !(SE1->E1_TIPO$MVABATIM+"|PIS|COF|CSL"))  .OR. (!Empty(E1_FATURA) .And. SE5->E5_DATA<=SE1->E1_DTFATURA .and. SE5->E5_MOTBX != "FAT")
							//Verifico valor dos abatimentos antes de proporcionalizar
							aAreaSE1 := GetArea()
							nTotAbImp	:= 0
							nAbtPis		:= 0
							nAbtCof		:= 0
							nTotAbt   := SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA,"S",dDataBase,@nTotAbImp,@nAbtPis,@nAbtCof) 
							nTotAbt	 -= nTotAbImp 	
							RestArea(aAreaSe1)	

							If (lRelatorio)
								RecLock (aTrb[1][1], .T.)
								(aTrb[1][1])->TRB_PREFIX	:=	SE1->E1_PREFIXO
								(aTrb[1][1])->TRB_NUMERO	:=	SE1->E1_NUM
								(aTrb[1][1])->TRB_PARCEL	:=	SE1->E1_PARCELA
								(aTrb[1][1])->TRB_TIPO		:=	SE1->E1_TIPO
								(aTrb[1][1])->TRB_CLIENT	:=	SE1->E1_CLIENTE
								(aTrb[1][1])->TRB_LOJA		:=	SE1->E1_LOJA
								(aTrb[1][1])->TRB_EMISSA	:=	SE1->E1_EMISSAO
								(aTrb[1][1])->TRB_VENCTO	:=	SE1->E1_VENCREA										//Quando nao for fatura, devo considerar o valor bruto do titulo principal
								(aTrb[1][1])->TRB_VALOR 	:=	SE1->E1_VALOR
								(aTrb[1][1])->TRB_SALDO 	:=	SE1->E1_SALDO
								(aTrb[1][1])->TRB_VALTIT	:=	SE5->E5_VALOR
								If (nAbtPis+nAbtCof+aComp[14]+aComp[15] > 0) .Or. Empty(SE1->E1_FATURA)
								   (aTrb[1][1])->TRB_VLPIS	:=	(SE5->E5_VALOR*SE1->E1_PIS)/((SE1->E1_VALOR-(aComp[13]+nTotAbt))-SE1->E1_PIS-SE1->E1_COFINS-SE1->E1_CSLL-SE1->E1_IRRF-SE1->E1_INSS)
								   (aTrb[1][1])->TRB_VLCOF	:=	(SE5->E5_VALOR*SE1->E1_COFINS)/((SE1->E1_VALOR-(aComp[13]+nTotAbt))-SE1->E1_PIS-SE1->E1_COFINS-SE1->E1_CSLL-SE1->E1_IRRF-SE1->E1_INSS)
								Else     
								   nPerc	:=((SE5->E5_VALOR/SE1->E1_VALOR))
									(aTrb[1][1])->TRB_VLPIS	:=	SE1->E1_PIS*nPerc
									(aTrb[1][1])->TRB_VLCOF	:=	SE1->E1_COFINS*nPerc
							    Endif   
								(aTrb[1][1])->TRB_VLPAGO	:=	(SE1->E1_VALOR-SE1->E1_PIS-SE1->E1_COFINS-SE1->E1_CSLL-SE1->E1_IRRF-SE1->E1_INSS) //SE5->E5_VALOR
								(aTrb[1][1])->TRB_SCORGP	:=	"1"
								(aTrb[1][1])->TRB_DTPAG0	:=	SE5->E5_DATA	//Data do ultimo pagamento
								(aTrb[1][1])->TRB_PIS		:=	SE1->E1_PIS
								(aTrb[1][1])->TRB_COFINS	:=	SE1->E1_COFINS
								MsUnLock ()
 								Else                                                               	//Quando nao for fatura, devo considerar o valor bruto do titulo principal
							   If (nAbtPis+nAbtCof+aComp[14]+aComp[15] > 0) .Or. Empty(SE1->E1_FATURA)
							      aValor[1] += (SE5->E5_VALOR*SE1->E1_PIS)/((SE1->E1_VALOR-(aComp[13]+nTotAbt))) //-SE1->E1_PIS-SE1->E1_COFINS-SE1->E1_CSLL-SE1->E1_IRRF-SE1->E1_INSS)
							      aValor[2] += (SE5->E5_VALOR*SE1->E1_COFINS)/((SE1->E1_VALOR-(aComp[13]+nTotAbt))) //-SE1->E1_PIS-SE1->E1_COFINS-SE1->E1_CSLL-SE1->E1_IRRF-SE1->E1_INSS)
							   Else
								   nPerc	:=((SE5->E5_VALOR/SE1->E1_VALOR))
									aValor[1] 	+=	SE1->E1_PIS*nPerc
									aValor[2] 	+=	SE1->E1_COFINS*nPerc
							   Endif   
							EndIf
						EndIf
					EndIf
				ElseIf (SE5->E5_TIPODOC=="ES")
					DbSelectArea ("SE1")
					SE1->(DbSetOrder(2))
					If (SE1->(MsSeek(xFilial("SE1")+SE5->E5_CLIFOR+SE5->E5_LOJA+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO)))
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Tratamento para fatura a receber                             ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
						If (AllTrim (SE1->E1_FATURA)=="NOTFAT") 
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Calculo do valor total da fatura a receber                   ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cFatura    := SE1->E1_PREFIXO+SE1->E1_NUM
							cCliente   := SE1->E1_CLIENTE+SE1->E1_LOJA
							cTpFatura  := SE1->E1_TIPO
							nVlrFatura := 0
							
							dbSelectArea("SE1")
							dbSetOrder(1)
							MsSeek(xfilial("SE1")+cFatura)
							While !Eof() .And. xFilial("SE1") == SE1->E1_FILIAL .And. SE1->E1_PREFIXO+SE1->E1_NUM == cFatura
							
								If SE1->E1_TIPO == cTpFatura
								
									nVlrFatura += SE1->E1_VALOR
									
								EndIf
								         
								dbSelectArea("SE1")
								dbSkip()
							EndDo
							//Proporcao do valor baixado da fatura
							nPropFatBx := nVlrbxFat / nVlrFatura
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Verifica os titulos de origem da fatura                      ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							dbSelectArea("SE1")
							dbSetOrder(10)
							MsSeek(xFilial("SE1")+cCliente+cFatura,.F.)
							While ( !Eof() .And. xFilial("SE1") == SE1->E1_FILIAL .And.;
								SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_FATPREF+SE1->E1_FATURA == cCliente+cFatura )
								If SE1->E1_SCORGP == "1" .And. !(SE1->E1_TIPO$MVPIABT+MVCFABT)
									If lRelatorio
										RecLock (aTrb[1][1],.T.)
										(aTrb[1][1])->TRB_PREFIX	:=	SE1->E1_PREFIXO
										(aTrb[1][1])->TRB_NUMERO	:=	SE1->E1_NUM
										(aTrb[1][1])->TRB_PARCEL	:=	SE1->E1_PARCELA
										(aTrb[1][1])->TRB_TIPO		:=	SE1->E1_TIPO
										(aTrb[1][1])->TRB_CLIENT	:=	SE1->E1_CLIENTE
										(aTrb[1][1])->TRB_LOJA		:=	SE1->E1_LOJA
										(aTrb[1][1])->TRB_EMISSA	:=	SE1->E1_EMISSAO
										(aTrb[1][1])->TRB_VENCTO	:=	SE1->E1_VENCREA    
										(aTrb[1][1])->TRB_VALOR     := (SE1->E1_VALOR)*-1
										(aTrb[1][1])->TRB_SALDO	    := (SE1->E1_SALDO)*-1
										(aTrb[1][1])->TRB_VALTIT	:=	nVlrProp*-1
										(aTrb[1][1])->TRB_VLPIS	    :=	nPisProp*-1
										(aTrb[1][1])->TRB_VLCOF	    :=	nCofProp*-1
										(aTrb[1][1])->TRB_VLPAGO	:=	(SE1->E1_VALOR-SE1->E1_PIS-SE1->E1_COFINS-SE1->E1_CSLL-SE1->E1_IRRF-SE1->E1_INSS)*-1
										(aTrb[1][1])->TRB_SCORGP	:=	"1"
										(aTrb[1][1])->TRB_DTPAG0	:=	SE5->E5_DATA	//Data do ultimo pagamento
										(aTrb[1][1])->TRB_PIS		:=	(SE1->E1_PIS)*-1
										(aTrb[1][1])->TRB_COFINS	:=	(SE1->E1_COFINS)*-1
										MsUnLock ()
									Else
										aValor[1] += nPisProp*-1
										aValor[2] += nCofProp*-1
									EndIf
								EndIf
								SE1->(dbSkip())
							EndDo
						ElseIf (SE1->E1_SCORGP=="1") .AND. Empty(E1_FATURA) .And. !(SE1->E1_TIPO$MVPIABT+MVCFABT)
							If (lRelatorio)
								RecLock (aTrb[1][1], .T.)
								(aTrb[1][1])->TRB_PREFIX	:=	SE1->E1_PREFIXO
								(aTrb[1][1])->TRB_NUMERO	:=	SE1->E1_NUM
								(aTrb[1][1])->TRB_PARCEL	:=	SE1->E1_PARCELA
								(aTrb[1][1])->TRB_TIPO		:=	SE1->E1_TIPO
								(aTrb[1][1])->TRB_CLIENT	:=	SE1->E1_CLIENTE
								(aTrb[1][1])->TRB_LOJA		:=	SE1->E1_LOJA
								(aTrb[1][1])->TRB_EMISSA	:=	SE1->E1_EMISSAO
								(aTrb[1][1])->TRB_VENCTO	:=	SE1->E1_VENCREA										//Quando nao for fatura, devo considerar o valor bruto do titulo principal
     							(aTrb[1][1])->TRB_VALOR	    :=	(SE1->E1_VALOR)*-1
								(aTrb[1][1])->TRB_SALDO	    :=	(SE1->E1_SALDO)*-1
								(aTrb[1][1])->TRB_VALTIT	+=	(SE5->E5_VALOR)*-1
								(aTrb[1][1])->TRB_VLPIS  	:=	((SE5->E5_VALOR*SE1->E1_PIS)/((SE1->E1_VALOR)-SE1->E1_PIS-SE1->E1_COFINS-SE1->E1_CSLL-SE1->E1_IRRF-SE1->E1_INSS))*-1		
								(aTrb[1][1])->TRB_VLCOF	    :=	((SE5->E5_VALOR*SE1->E1_COFINS)/((SE1->E1_VALOR)-SE1->E1_PIS-SE1->E1_COFINS-SE1->E1_CSLL-SE1->E1_IRRF-SE1->E1_INSS))*-1
								(aTrb[1][1])->TRB_VLPAGO	:=	(SE1->E1_VALOR-SE1->E1_PIS-SE1->E1_COFINS-SE1->E1_CSLL-SE1->E1_IRRF-SE1->E1_INSS)*-1
								(aTrb[1][1])->TRB_SCORGP	:=	"1"
								(aTrb[1][1])->TRB_DTPAG0	:=	SE5->E5_DATA	//Data do ultimo pagamento
								(aTrb[1][1])->TRB_PIS		:=	(SE1->E1_PIS)*-1
								(aTrb[1][1])->TRB_COFINS	:=	(SE1->E1_COFINS)*-1
								MsUnLock ()
 								Else                                                               	//Quando nao for fatura, devo considerar o valor bruto do titulo principal
							   aValor[1] += ((SE5->E5_VALOR*SE1->E1_PIS)/((SE1->E1_VALOR)-SE1->E1_PIS-SE1->E1_COFINS-SE1->E1_CSLL-SE1->E1_IRRF-SE1->E1_INSS))*-1	
							   aValor[2] += ((SE5->E5_VALOR*SE1->E1_COFINS)/((SE1->E1_VALOR)-SE1->E1_PIS-SE1->E1_COFINS-SE1->E1_CSLL-SE1->E1_IRRF-SE1->E1_INSS))*-1
							EndIf
						EndIf
					EndIf					
				EndIf
			Next nX
			RestArea (aAreaSe5)
			aBaixas := {}
            nTotBaixa	:= 	0.00
            nTotVal		:=	0.00
			cQuebra 	:=  (cAliasSE5)->E5_PREFIXO+(cAliasSE5)->E5_NUMERO+(cAliasSE5)->E5_PARCELA+(cAliasSE5)->E5_TIPO+(cAliasSE5)->E5_CLIFOR+(cAliasSE5)->E5_LOJA
		EndIf
	EndIf
EndDo

dbSelectArea("SE5")
RetIndex("SE5")
dbClearFilter()
Ferase(cArqInd+OrdBagExt())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Selecionando Registros nao recebidos de orgaos publicos.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SomaAbat ("","","","R")	//Retorna Alias __SE1

If lCumNCum
	SD2->(dbSetOrder(3))
	SF4->(dbSetOrder(1))
	
	aRelImp    := MaFisRelImp("MT100",{ "SD2" })	
	If !Empty( nScanPis := aScan(aRelImp,{|x| x[1]=="SD2" .And. x[3]=="IT_VALPS2"} ) )
		cCpVlPisSa := aRelImp[nScanPis,2]
		nPsVlPisSa := SD2->(FieldPos(cCpVlPisSa))
	EndIf 	                    
	If !Empty( nScanCof := aScan(aRelImp,{|x| x[1]=="SD2" .And. x[3]=="IT_VALCF2"} ) )
		cCpVlCofSa := aRelImp[nScanCof,2]
		nPsVlCofSa := SD2->(FieldPos(cCpVlCofSa))
	EndIf
EndIf

dbSelectArea("SE1")
dbSetOrder(1)
ProcRegua(LastRec())
#IFDEF TOP
    If TcSrvType()<>"AS/400"
	    lQuery := .T.
		cAliasSE1 := "SE1ABAT"
		aStruSE1  := SE1->(dbStruct())		
		cQuery := "SELECT E1_TIPO, E1_NATUREZ, E1_VALOR, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_LOJA, E1_EMISSAO, E1_VENCREA, E1_PIS, E1_COFINS, E1_FATURA,E1_BAIXA, "
		cQuery += "SE5.E5_VRETPIS, SE5.E5_VRETCOF, "
		cQuery += " SE5.E5_PREFIXO, SE5.E5_NUMERO, SE5.E5_PARCELA, SE5.E5_TIPO, SE5.E5_CLIFOR, SE5.E5_LOJA, SE5.E5_SEQ, SE5.E5_TIPODOC "
		
		If lCTipVL
			cQuery += ",SE5.E5_SEQ   "
		EndIf
		cQuery += "FROM " + RetSqlName("SE1") + " SE1 " 
		cQuery += "LEFT JOIN " + RetSqlName("SE5") + " SE5 " 
		cQuery += "ON E5_FILIAL=E1_FILIAL AND E5_PREFIXO = E1_PREFIXO AND E5_NUMERO=E1_NUM AND E5_TIPO=E1_TIPO AND E5_CLIENTE=E1_CLIENTE AND E5_LOJA=E1_LOJA AND SE5.D_E_L_E_T_ = ' ' "
		cQuery += "AND E5_TIPODOC NOT IN ('BA','C2','CD','CM','CP','CX','D2','DC','IS','J2','JR','M2','MT','OG','TL','VM','ES') "  //Nao considera tipos de documentos gravados na SE5 que nao geram movimentacao bancaria
		cQuery += "WHERE "
		// Se a tabela for compartilhada e a opcao escolhida for considera filial = Nao, devera ser verificado o campo
		// MSFIL, caso exista na base.
		If FWModeAccess("SE1",3)=="C" .And. SE1->(FieldPos("E1_MSFIL")) > 0 .And. nFilial == 2
			If lRelConf   //mando a filial que estou processando no relatorio de conferencia por esta variavel -> cRelFil
				cQuery += "E1_MSFIL='"+cRelFil+"' AND "
			Else
				cQuery += "E1_MSFIL='"+SM0->M0_CODFIL+"' AND "
			Endif
		Else
			cQuery += "E1_FILIAL='"+xFilial("SE1")+"' AND "
		Endif	
		cQuery += "E1_BAIXA>='"+Dtos(dDtIni)+"' AND "
		cQuery += "E1_BAIXA<='"+Dtos(dDtFim)+"' AND "	
		cQuery += "E1_TIPO NOT IN "+FormatIn (MVABATIM+"|PIS|COF|CSL", "|")+" AND "	//ADMXFUN.PRX
		cQuery += "SE1.D_E_L_E_T_ = ' ' "
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³O campo E1_SCORGP eh gravado  no MATA461 de acordo com o cliente/produto.                                                                                             ³
		//³Processo para criacao/alimentacao deste campo:                                                                                                                        ³
		//³- Criar os parametros MV_A1M996 e relacionar o campo da tabela SA1 do tipo caracter, combo (1=Sim;2=Nao) que identifica bem ou servico contratado por Orgaos Publicos.³
		//³- Criar os parametros MV_B1M996 e relacionar o campo da tabela SB1 do tipo caracter, combo (1=Sim;2=Nao) que identifica bem ou servico contratado por Orgaos Publicos.³
		//³- Criar o campo na tabela SE1 (E1_SCORGP) do tipo do tipo caracter, combo (1=Sim;2=Nao) que identifica bem ou servico contratado por Orgaos Publicos.                 ³
		//³- Após as criacoes, serah gravado automaticamente na tabela SE1 quando os dois campos (SA1 e SB1) estiverem definidos como "1=Sim".                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery += "AND E1_SCORGP NOT IN ('1') "	//Somente os recebidos, ou seja, sem saldo. 
		
		If lCTipVL
			cQuery += " AND E5_TIPODOC = 'VL' "	
		EndIf
		If (lM996E1)
			cQuery	+=	" AND "
			cQuery	+=	ExecBlock ("M996E1",.F.,.F.,)
		EndIf

		cQuery += "ORDER BY "
		
		If lCTipVL
			cQuery += " SE5.E5_SEQ DESC, "
		EndIf
		
		cQuery += SqlOrder(SE1->(IndexKey()))		
	
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE1)
	
		For nX := 1 To len(aStruSE1)
			If aStruSE1[nX][2] <> "C" .And. FieldPos(aStruSE1[nX][1])<>0
				TcSetField(cAliasSE1,aStruSE1[nX][1],aStruSE1[nX][2],aStruSE1[nX][3],aStruSE1[nX][4])
			EndIf
		Next nX 
		dbSelectArea(cAliasSE1)	
	Else
#ENDIF
	    cIndex    := 'E1_NUM'
		
		//CriaTrab(NIL,.F.)

		// Se a tabela for compartilhada e a opcao escolhida for considera filial = Nao, devera ser verificado o campo
		// MSFIL, caso exista na base.
    
   		If FWModeAccess("SE1",3)=="C" .And. SE1->(FieldPos("E1_MSFIL")) > 0 .And. nFilial == 2
			If lRelConf   //mando a filial que estou processando no relatorio de conferencia por esta variavel -> cRelFil
				cCondicao := 'E1_MSFIL=="'+cRelFil+'" .And. '
			Else
			    cCondicao := 'E1_MSFIL=="'+SM0->M0_CODFIL+'" .And. '
			Endif  
		ElseIf FWModeAccess("SE1",3)=="C" .And. SE1->(FieldPos("E1_FILORIG")) > 0 .And. nFilial == 2
			If lRelConf   //mando a filial que estou processando no relatorio de conferencia por esta variavel -> cRelFil
				cCondicao := 'E1_FILORIG=="'+cRelFil+'" .And. '
			Else
			    cCondicao := 'E1_FILORIG=="'+SM0->M0_CODFIL+'" .And. '
			Endif
	    Else
	        cCondicao := 'E1_FILIAL=="'+xFilial("SE1")+'".And.'
	   	Endif
	   	
	   	cCondicao += 'DTOS(E1_BAIXA)>="'+DTOS(dDtIni)+'".And.DTOS(E1_BAIXA)<="'+DTOS(dDtFim)+'" '
		cCondicao += '.And. !(E1_TIPO$MVABATIM + "|PIS|COF|CSL" )'
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³O campo E1_SCORGP eh gravado  no MATA461 de acordo com o cliente/produto.                                                                                             ³
		//³Processo para criacao/alimentacao deste campo:                                                                                                                        ³
		//³- Criar os parametros MV_A1M996 e relacionar o campo da tabela SA1 do tipo caracter, combo (1=Sim;2=Nao) que identifica bem ou servico contratado por Orgaos Publicos.³
		//³- Criar os parametros MV_B1M996 e relacionar o campo da tabela SB1 do tipo caracter, combo (1=Sim;2=Nao) que identifica bem ou servico contratado por Orgaos Publicos.³
		//³- Criar o campo na tabela SE1 (E1_SCORGP) do tipo do tipo caracter, combo (1=Sim;2=Nao) que identifica bem ou servico contratado por Orgaos Publicos.                 ³
		//³- Após as criacoes, serah gravado automaticamente na tabela SE1 quando os dois campos (SA1 e SB1) estiverem definidos como "1=Sim".                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCondicao += '.And. E1_SCORGP<>"1" '	//Somente os recebidos, ou seja, sem saldo.

		If (lM996E1)
			cCondicao	+=	" .And. "
			cCondicao	+=	ExecBlock ("M996E1",.F.,.F.,)
		EndIf

	    IndRegua(cAliasSE1,cIndex,SE1->(IndexKey()),,cCondicao)
	    nIndex := RetIndex("SE1")
		#IFNDEF TOP
			dbSetIndex(cIndex+OrdBagExt())
		#ENDIF
		dbSelectArea("SE1")
	    dbSetOrder(nIndex+1)
	
	    dbSelectArea(cAliasSE1)
	    ProcRegua(LastRec())
	    dbGoTop()
#IFDEF TOP
	Endif    
#ENDIF
nCont := 1   
While (cAliasSE1)->(!Eof()) 	

	// Caso a tabela seja compartilhada, devera processar somente uma filial para q nao seja multiplicado 
	//os valores pela quantidade de filiais existentes, e caso a pergunta "considera filiais" = Sim.

	If (FWModeAccess("SE1",3)=="C" .And. cFilAnt <> cBckFil .And. nFilial == 1)
		(cAliasSE1)->(DbSkip())  
		Loop
	Endif  
	
	If TemBxCanc((cAliasSE1)->E5_PREFIXO+(cAliasSE1)->E5_NUMERO+(cAliasSE1)->E5_PARCELA+(cAliasSE1)->E5_TIPO+(cAliasSE1)->E5_CLIFOR+(cAliasSE1)->E5_LOJA+(cAliasSE1)->E5_SEQ)
		(cAliasSE1)->(dbskip())
		Loop
	EndIf
	
	If (cAliasSE1)->E1_FATURA <> "NOTFAT"	
		aAreaSE1 := GetArea()
		//Abro SE1 sem filtro para localizacao dos titulos de Pis e Cofins
		dbSelectArea("__SE1")
		///dbSelectArea(cAliasSE1)	
	    ///(cAliasSE1)->(dbSetOrder(2))  ///#FAP	
	    __SE1->(dbSetOrder(2))  //clie_Loja+pref+Num+Parc+tipo
		lAchouAbat := .F.

		If FTemImpCR("COF",(cAliasSE1)->E1_CLIENTE,(cAliasSE1)->E1_LOJA,(cAliasSE1)->E1_PREFIXO,(cAliasSE1)->E1_NUM,(cAliasSE1)->E1_PARCELA,(cAliasSE1)->E1_TIPO)
			lAchouAbat := .T.
		ElseIf FTemImpCR("PIS",(cAliasSE1)->E1_CLIENTE,(cAliasSE1)->E1_LOJA,(cAliasSE1)->E1_PREFIXO,(cAliasSE1)->E1_NUM,(cAliasSE1)->E1_PARCELA,(cAliasSE1)->E1_TIPO)
			lAchouAbat := .T.        
        EndIf   

        //Verifica se o título tem valor de retenção e está vinculada a outro Título
        IF cRetBaiEmi == "1" .AND. !lAchouAbat
	        lAchouAbat:= BuscaSFQ((cAliasSE1)->E1_PREFIXO,(cAliasSE1)->E1_NUM,(cAliasSE1)->E1_PARCELA,(cAliasSE1)->E1_TIPO,(cAliasSE1)->E1_CLIENTE,(cAliasSE1)->E1_LOJA)
	  	EndIF

		//Caso tenha achado o titulo de PI- ou CF-, efetuo o processamento pois este titulo principal 
		//teve retencao dos impostos
		If lAchouAbat			
			If (lRelatorio)
				RecLock (aTrb[1][1], .T.)
				(aTrb[1][1])->TRB_PREFIX	:=	(cAliasSE1)->E1_PREFIXO
				(aTrb[1][1])->TRB_NUMERO	:=	(cAliasSE1)->E1_NUM
				(aTrb[1][1])->TRB_PARCEL	:=	(cAliasSE1)->E1_PARCELA
				(aTrb[1][1])->TRB_TIPO		:=	(cAliasSE1)->E1_TIPO
				(aTrb[1][1])->TRB_CLIENT	:=	(cAliasSE1)->E1_CLIENTE
				(aTrb[1][1])->TRB_LOJA		:=	(cAliasSE1)->E1_LOJA
				(aTrb[1][1])->TRB_EMISSA	:=	(cAliasSE1)->E1_EMISSAO
				(aTrb[1][1])->TRB_VENCTO	:=	(cAliasSE1)->E1_VENCREA
				(aTrb[1][1])->TRB_DTPAG0	:=	CToD ("  /  /  ")   
				 If lImpValBruto == .T.
				    (aTrb[1][1])->TRB_VALOR	:= (cAliasSE1)->E1_VALOR
				 Else
				    (aTrb[1][1])->TRB_VALOR	:= 0
				 Endif
				(aTrb[1][1])->TRB_VLPAGO	:=	0
				(aTrb[1][1])->TRB_VALTIT	:=	0
				(aTrb[1][1])->TRB_SCORGP	:=	"2"
				(aTrb[1][1])->TRB_VLPIS  	:=	(cAliasSE1)->E1_PIS
				(aTrb[1][1])->TRB_VLCOF 	:=	(cAliasSE1)->E1_COFINS
				If lCTipVL
					(aTrb[1][1])->TRB_SEQ	    :=	(cAliasSE1)->E5_SEQ
				EndIf
				MsUnLock ()
			Else
            If cRetBaiEmi == "1" .and. (cAliasSE1)->E5_VRETPIS > 0
				aValor[1] 	+= (cAliasSE1)->E5_VRETPIS
				aValor[2] 	+= (cAliasSE1)->E5_VRETCOF			
			ElseIf cRetBaiEmi == "2"	
				aValor[1] 	+=	(cAliasSE1)->E1_PIS    
				aValor[2] 	+=	(cAliasSE1)->E1_COFINS
            Endif                          
            If (Empty((cAliasSE1)->E5_SEQ) .Or. (cAliasSE1)->E5_SEQ == '01') .And. cRetBaiEmi == "1"// Bloqueio a exponencial do valor de Pis e Cofins sobre o título principal
            	aF600Aux:= FinSpdF600(Month(dDtIni),Year(dDtIni))  //Retornar retenções
            	If nCont<=len(aF600Aux)    
					aRet[1]		+= aF600Aux[nCont][7]
					aRet[2]		+= aF600Aux[nCont][8]
					nCont ++
				EndIf
			ElseIf Empty((cAliasSE1)->E5_SEQ) .Or. (cAliasSE1)->E5_SEQ == '01'	// Bloqueio a exponencial do valor de Pis e Cofins sobre o título principal
				aRet[1]		+= (cAliasSE1)->E1_PIS
				aRet[2]		+= (cAliasSE1)->E1_COFINS
			EndIf
				If lCumNCum
					aAuxCNC	:=	{0,0,0,0}
					If SD2->(MsSeek(xFilial("SD2")+(cAliasSE1)->(E1_NUM+E1_PREFIXO+E1_CLIENTE+E1_LOJA)))
						While !SD2->(Eof()) .And. xFilial("SD2")+(cAliasSE1)->(E1_NUM+E1_PREFIXO+E1_CLIENTE+E1_LOJA)==;
							xFilial("SD2")+SD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)
	
							If GetNewPar("MV_M996TPR","1")==1
								If SF4->(MsSeek(xFilial("SF4")+SD2->D2_TES))
	
									If SF4->F4_TPREG$"13"	//NAO CUMULATIVO/AMBOS
										aAuxCNC[1]	+=	SD2->(FieldGet(nPsVlPisSa))
										aAuxCNC[2]	+=	SD2->(FieldGet(nPsVlCofSa))
									EndIf
									If SF4->F4_TPREG$"23"	//CUMULATIVO/AMBOS
										aAuxCNC[3]	+=	SD2->(FieldGet(nPsVlPisSa))
										aAuxCNC[4]	+=	SD2->(FieldGet(nPsVlCofSa))
									EndIf
		
		 						EndIf
							Elseif GetNewPar("MV_M996TPR","1")==2
								If SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD))
								
									If lB1TPREG .AND. SB1->B1_TPREG$"13"	//NAO CUMULATIVO/AMBOS
										aAuxCNC[1]	+=	SD2->(FieldGet(nPsVlPisSa))
										aAuxCNC[2]	+=	SD2->(FieldGet(nPsVlCofSa))
									EndIf
									If lB1TPREG .AND. SB1->B1_TPREG$"23"	//CUMULATIVO/AMBOS
										aAuxCNC[3]	+=	SD2->(FieldGet(nPsVlPisSa))
										aAuxCNC[4]	+=	SD2->(FieldGet(nPsVlCofSa))
									EndIf
								Endif
							Endif
	
							SD2->(dbSkip())
						End
					    If (cAliasSE1)->E5_TIPODOC <> "JR"
							aCumNCum[1]	+=	((cAliasSE1)->E1_PIS/aAuxCNC[1])*aAuxCNC[1]
							aCumNCum[2]	+=	((cAliasSE1)->E1_COFINS/aAuxCNC[2])*aAuxCNC[2]
							aCumNCum[3]	+=	((cAliasSE1)->E1_PIS/aAuxCNC[3])*aAuxCNC[3]
							aCumNCum[4]	+=	((cAliasSE1)->E1_COFINS/aAuxCNC[4])*aAuxCNC[4]
      					Endif
					EndIf
				EndIf
				
			EndIf
		Endif
		RestArea(aAreaSe1)	
	EndIf
	(cAliasSE1)->(DbSkip ())
	IncProc() 	
EndDo	
    
If lQuery
	dbSelectArea(cAliasSE1)
	dbCloseArea()
Else
  	dbSelectArea("SE1")
	RetIndex("SE1")
	Set Filter to
	Ferase(cIndex+OrdBagExt())
EndIf

RestArea(aArea)

Return({Round(aValor[1],2),Round(aValor[2],2)})





//-------------------------------------------------------------------
/*/Função BuscaSFQ			
Busca os títulos de retenção vinculados ao título que atingiu o valor mínimo de retenção, quando a retenção é na baixa. Exemplo:
T´tulo 001 de 1000 - Não reteve
T´tulo 002 de 2000 - Não reteve
T´tulo 003 de 7000 - Reteve

Ao baixar o terceiro título deverá ser considerado o valor de retenção dos 3 títulos, e através da SFQ irei saber quais títulos estão vinculados.
/*/
//-------------------------------------------------------------------

Static Function BuscaSFQ(cPrefix,cNum,nParcela,cTipo,cCliente,cLoja)

Local lRet		:= .F.    

dbSelectArea("SFQ")
SFQ->(DbSetOrder(2))

//Busco para ver se este título tem valor de retenção vinculado a outro título
If SFQ->(MsSeek(xFilial("SFQ")+"E1B"+cPrefix+cNum+nParcela+cTipo+cCliente+cLoja))
	lRet:= .T.
EndIF

Return lRet  
