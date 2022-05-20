#INCLUDE "MATR260.CH"
#INCLUDE "PROTHEUS.CH"

Static aNameCells := {}

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MATR260x  �                                                ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Posicao dos Estoques                                       ���
*/

user Function MATR260x()
Local oReport
Local lContinua	:= .F.
Local aSX1		:= {}

Private oTempTable	:= NIL
Private aMV_PAR		:= array(25) // total de perguntas do grupo MTR260R1
Private cPerg		:= ""

aSX1 := DefineSX1()
cPerg := aSX1[1] // grupo de pergunta
lContinua := aSX1[2] // O grupo de pergunta esta correto

If lContinua
	//������������������������������������������������������������������������Ŀ
	//�Interface de impressao                                                  �
	//��������������������������������������������������������������������������
	oReport:= ReportDef()
	oReport:PrintDialog()
Else
	Help('',1,'MTR260SX1',,'N�o foi encontrado o grupo de perguntas MTR260R1.',1,0)
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef �                                                 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR260x			                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local aOrdem    := {OemToAnsi(STR0005),OemToAnsi(STR0006),OemToAnsi(STR0007),OemToAnsi(STR0008),OemToAnsi(STR0009)}    //" Por Codigo         "###" Por Tipo           "###" Por Descricao     "###" Por Grupo        "###" Por Almoxarifado   "
Local cAliasTRB	:= GetNextAlias()
Local nSizeQT	:= TamSX3("B2_QATU")[1] + 4
Local nSizeVL	:= TamSX3("B2_VATU1")[1] + 4
Local nTamProd	:= TamSX3("B1_COD")[1] + 5
Local nSizeLZ   := TamSX3("NNR_DESCRI")[1]
Local cPictQT   := PesqPict("SB2","B2_QATU")
Local cPictVL   := PesqPict("SB2","B2_VATU1")
Local cPictLZ   := PesqPict("NNR","NNR_DESCRI")
Local oReport
Local oSection

oReport:= TReport():New("MATR260x",STR0001,cPerg,,)

IIf( !( IsBlind() ), Pergunte( cPerg, .F. ), Nil ) 
//�����������������������������������������������������������������������
// Variaveis utilizadas para parametros no grupo de pergunta MTR260R1
//�����������������������������������������������������������������������
// mv_par01 - Aglutina por: Almoxarifado / Filial / Empresa
// mv_par02 - Filial de
// mv_par03 - Filial ate
// mv_par04 - almoxarifado de
// mv_par05 - almoxarifado ate
// mv_par06 - Produto de
// mv_par07 - Produto ate
// mv_par08 - tipo de
// mv_par09 - tipo ate
// mv_par10 - grupo de
// mv_par11 - grupo ate
// mv_par12 - descricao de
// mv_par13 - descricao ate
// mv_par14 - Codigo do Item de
// mv_par15 - Codigo do Item ate
// mv_par16 - imprime produtos: Todos /Positivos /Negativos
// mv_par17 - Saldo a considerar : Atual / Fechamento / Movimento
// mv_par18 - Qual Moeda (1 a 5)
// mv_par19 - Aglutina por UM ?(S)im (N)ao
// mv_par20 - Lista itens zerados ? (S)im (N)ao
// mv_par21 - Imprimir o Valor ? Custo / Custo Std / Ult Prc Compr
// mv_par22 - Data de Referencia
// mv_par23 - Lista valores zerados ? (S)im (N)ao
// mv_par24 - QTDE na 2a. U.M. ? (S)im (N)ao
// mv_par25 - Imprime descricao do Armazem ? (S)im (N)ao
//�����������������������������������������������������������������������

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������
oSection := TRSection():New(oReport,STR0053,{"SB2","SB1"},aOrdem) //"Saldos em Estoque"
MontaTrab(oReport,oSection:GetOrder(),cAliasTRB,oSection,.T.)                                                    //STR0002+" "+STR0003+" "+STR0004
oReport := TReport():New("MATR260X",'Listagem de Invent�rio',cPerg, {|oReport| ReportPrint(oreport,aOrdem,cAliasTRB)}, " " ) //"Relacao da Posicao do Estoque"
oReport:SetUseGC(.F.) //-- Desabilita GE para n�o conflitar com perguntas do relat�rio
If TamSX3("B1_COD")[1] > 15
	oReport:SetLandscape()
EndIf

//��������������������������������������������������������������Ŀ
//� Criacao da Sessao 1                                          �
//����������������������������������������������������������������
oSection := TRSection():New(oReport,STR0053,{"SB2","SB1",cAliasTRB},aOrdem) //"Saldos em Estoque"
oSection:SetTotalInLine(.F.)

TRCell():New(oSection,'B2_LOCAL'	,'SB2','Arm.',/*Picture*/,7,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():New(oSection,'B1_COD'		,'SB1',STR0036,/*Picture*/,nTamProd+5,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,'B1_CODLMT'		,'SB1','Cod.LMT',/*Picture*/,nTamProd+25,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():New(oSection,'B1_TIPO'		,'SB1',STR0037,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
///TRCell():New(oSection,'B1_GRUPO'	,'SB1',STR0038,/*Picture*/,7,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,'B1_DESC'		,'SB1',STR0039,/*Picture*/,If(oReport:GetOrientation() == 1,50,),/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,'B1_GRUPO'	,'SB1','Grupo',/*Picture*/,7,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():New(oSection,'B1_UM'		,'SB1','Unid',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT")
//TRCell():New(oSection,'B1_SEGUM'	,'SB1',STR0040,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
//TRCell():New(oSection,'B2_FILIAL'	,'SB2',STR0041,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,'B1_PESO'		,'SB1','Peso',cPictQT	,12,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")

TRCell():New(oSection,'B1_ENDE'		,'SB1','Endere�o',/*cPictQT*/	,12,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")

TRCell():New(oSection,'QUANT'		,cAliasTRB,'  Saldo'+CRLF+'Estoque',cPictQT							,nSizeQT,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
TRCell():New(oSection,'QUANTR'		,cAliasTRB,'EMPENHO'+CRLF+STR0046,cPictQT							,nSizeQT,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
//TRCell():New(oSection,'DISPON'		,cAliasTRB,STR0047+CRLF+STR0048,cPictQT							,nSizeQT,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
//TRCell():New(oSection,'VALOR'		,cAliasTRB,STR0049+CRLF+STR0044,If(cPaisLoc=="CHI",'',cPictVL)	,nSizeVL,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
//TRCell():New(oSection,'VALORR'		,cAliasTRB,STR0049+CRLF+STR0050,If(cPaisLoc=="CHI",'',cPictVL)	,nSizeVL,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
//TRCell():New(oSection,'DESCARM'		,cAliasTRB,STR0051+CRLF+STR0052,cPictLZ							,nSizeLZ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,'B1_LOJPROC'	,'SB1',' Contagem',/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)

oSection:SetHeaderPage()
oSection:SetNoFilter(cAliasTRB)

Return(oReport)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint � Autor �Marcos V. Ferreira   � Data �16/06/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportPrint devera ser criada para todos  ���
���          �os relatorios que poderao ser agendados pelo usuario.       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relatorio                           ���
���          �ExpA2: Array com as ordem do relatorio                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR260			                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportPrint(oReport,aOrdem,cAliasTRB)

Local oSection	:= oReport:Section(1)
Local nOrdem	:= oSection:GetOrder()
Local nX		:= 0
Local nQtdCol 	:= 0
Local cCodAnt	:= ""
Local cFilAnter	:= ""
Local cNameCell	:= ""
Local lRet		:= .T.
Local oBreak01
Local oBreak02
Local nTamLOC	:= TamSX3("B2_LOCAL")[1]
Local cALL_LOC	:= Replicate('*', nTamLOC)
Local cALL_Empty:= Replicate(' ', nTamLOC)
Local cALL_ZZ	:= Replicate('Z', nTamLOC)
Local lCusUnif	:= A330CusFil() // Verifica se utiliza custo unificado por Empresa/Filial
Local cPicture := '999,999,999,999,999,999.99'

//��������������������������������������������������������������Ŀ
//� Variaveis Private                                            |
//����������������������������������������������������������������

aNameCells	:= {}

//��������������������������������������������������������������Ŀ
//� Se for executado do MTR260 deve ajustar para o grupo de pergunta MTR260R1
//����������������������������������������������������������������
If oReport:uParam =="MTR260"

	For nX := 01 to 13
		aMV_PAR[nX] := &("mv_par"+StrZero(nX,2))
	Next nX
	aMV_PAR[14] := MV_PAR06
	aMV_PAR[15] := MV_PAR07

	For nX := 14 to 23
		aMV_PAR[nX+2] := &("mv_par"+StrZero(nX,2) )
	Next nX

Else
	For nX := 01 to 25
		aMV_PAR[nX] := &("mv_par"+StrZero(nX,2))
	Next nX
EndIf

//��������������������������������������������������������������Ŀ
//� Definicao do titulo do relatorio                             |
//����������������������������������������������������������������
//oReport:SetTitle(oReport:Title()+" - ("+AllTrim(aOrdem[oSection:GetOrder()])+" - "+AllTrim(SuperGetMv("MV_SIMB"+Ltrim(Str(aMV_PAR[18])),.F.))+")")
oReport:SetTitle(oReport:Title()+" - ("+AllTrim(aOrdem[oSection:GetOrder()])+")")

//��������������������������������������������������������������Ŀ
//� Definicao da linha de SubTotal                               |
//����������������������������������������������������������������
If StrZero(nOrdem,1) $ "245"
	If nOrdem == 2
		//-- SubtTotal por Tipo
	//	oBreak01 := TRBreak():New(oSection,oSection:Cell("B1_TIPO"),STR0016+" "+STR0017,.F.)
	ElseIf nOrdem == 4
		//-- SubtTotal por Grupo
	//	oBreak01 := TRBreak():New(oSection,oSection:Cell("B1_GRUPO"),STR0016+" "+STR0018,.F.)
	ElseIf nOrdem == 5
		//-- SubtTotal por Armazem
	//	oBreak01 := TRBreak():New(oSection,oSection:Cell("B2_LOCAL"),STR0033,.F.)
	EndIf
		
	TRFunction():New(oSection:Cell('QUANT'	),NIL,"SUM",oBreak01,/*Titulo*/, cPicture,/*uFormula*/,.F.,.F.)
	TRFunction():New(oSection:Cell('QUANTR'	),NIL,"SUM",oBreak01,/*Titulo*/, cPicture,/*uFormula*/,.F.,.F.)
//	TRFunction():New(oSection:Cell('DISPON'	),NIL,"SUM",oBreak01,/*Titulo*/, cPicture,/*uFormula*/,.F.,.F.)
//	TRFunction():New(oSection:Cell('VALOR'	),NIL,"SUM",oBreak01,/*Titulo*/, cPicture,/*uFormula*/,.F.,.F.)
//	TRFunction():New(oSection:Cell('VALORR'	),NIL,"SUM",oBreak01,/*Titulo*/, cPicture,/*uFormula*/,.F.,.F.)
EndIf

//��������������������������������������������������������������Ŀ
//� Definicao da linha de SubTotal da Unidade de Medida          |
//����������������������������������������������������������������
If aMV_PAR[19] == 1
	If aMV_PAR[24] == 1 //-- SubTotal pela 2a.U.M.
	//	oBreak02 := TRBreak():New(oSection,oSection:Cell("B1_SEGUM"),STR0019,.F.)
	Else //-- SubTotal pela 1a. U.M.
	///	oBreak02 := TRBreak():New(oSection,oSection:Cell("B1_UM"),STR0019,.F.)
	EndIf

	TRFunction():New(oSection:Cell('QUANT'	),NIL,"SUM",oBreak02,/*Titulo*/, cPicture,/*uFormula*/,.F.,.F.)
	TRFunction():New(oSection:Cell('QUANTR'	),NIL,"SUM",oBreak02,/*Titulo*/, cPicture,/*uFormula*/,.F.,.F.)
//	TRFunction():New(oSection:Cell('DISPON'	),NIL,"SUM",oBreak02,/*Titulo*/, cPicture,/*uFormula*/,.F.,.F.)
//	TRFunction():New(oSection:Cell('VALOR'	),NIL,"SUM",oBreak02,/*Titulo*/, cPicture,/*uFormula*/,.F.,.F.)
//	TRFunction():New(oSection:Cell('VALORR'	),NIL,"SUM",oBreak02,/*Titulo*/, cPicture,/*uFormula*/,.F.,.F.)
EndIf

//��������������������������������������������������������������Ŀ
//� Definicao da linha de Total Geral                            |
//����������������������������������������������������������������

TRFunction():New(oSection:Cell('QUANT'	),NIL,"SUM",/*oBreak*/,/*Titulo*/,cPicture,/*uFormula*/,.T.,.F.)
TRFunction():New(oSection:Cell('QUANTR'	),NIL,"SUM",/*oBreak*/,/*Titulo*/,cPicture,/*uFormula*/,.T.,.F.)
//TRFunction():New(oSection:Cell('DISPON'	),NIL,"SUM",/*oBreak*/,/*Titulo*/,cPicture,/*uFormula*/,.T.,.F.)
//TRFunction():New(oSection:Cell('VALOR'	),NIL,"SUM",/*oBreak*/,/*Titulo*/,cPicture,/*uFormula*/,.T.,.F.)
//TRFunction():New(oSection:Cell('VALORR'	),NIL,"SUM",/*oBreak*/,/*Titulo*/,cPicture,/*uFormula*/,.T.,.F.)

If oSection:UseFilter()
	
	nQtdCol := Len(oSection:aCell)
	For nX := 1 to nQtdCol
		If oSection:aCell[nX]:lUserField .And. oSection:aCell[nX]:cAlias == "SB2" .And. oSection:aCell[nX]:cType == "N"
			cNameCell	:= oSection:aCell[nX]:cName
			aAdd(aNameCells,cNameCell)
			If StrZero(nOrdem,1) $ "245"
			//	TRFunction():New(oSection:Cell(cNameCell),NIL,"SUM",oBreak01,/*Titulo*/,/*cPicture*/,/*uFormula*/,.F.,.F.)
			EndIf
			If aMV_PAR[19] == 1
			//	TRFunction():New(oSection:Cell(cNameCell),NIL,"SUM",oBreak02,/*Titulo*/,/*cPicture*/,/*uFormula*/,.F.,.F.)
			EndIf

			//TRFunction():New(oSection:Cell(cNameCell),NIL,"SUM",,,,,.T.,.F.)
		EndIf
	Next nX
EndIf

//���������������������������������������������������������������Ŀ
//�	Visualizar a coluna B1_UM ou B1_SEGUM conforme parametrizacao |
//�����������������������������������������������������������������
If aMV_PAR[24] == 1
	oSection:Cell('B1_UM'):Disable()
Else
	//oSection:Cell('B1_SEGUM'):Disable()
EndIf

oSection:Cell('B1_TIPO'):Disable()

//���������������������������������������������������������������Ŀ
//�	Visualizar "Descricao do Armazem" conforme parametrizacao     |
//�����������������������������������������������������������������
If aMV_PAR[25] != 1
////	oSection:Cell('DESCARM'):Disable()
EndIf

//��������������������������������������������������������������Ŀ
//� Ajusta as perguntas para Custo Unificado                     |
//����������������������������������������������������������������
If lCusUnif .And. ((aMV_PAR[01]==1) .Or. !(aMV_PAR[04]==cALL_LOC) .Or. !(aMV_PAR[05]==cALL_LOC) .Or. nOrdem==5)
	If Aviso(STR0024,STR0025+CHR(10)+CHR(13)+STR0029+CHR(10)+CHR(13)+STR0026+CHR(10)+CHR(13)+STR0027+CHR(10)+CHR(13)+STR0028+CHR(10)+CHR(13)+STR0030,{STR0031,STR0032}) == 2
		lRet := .F.
	EndIf
EndIf

If lRet

	If aMV_PAR[04] == cALL_LOC
		aMV_PAR[04] := cALL_Empty
	EndIf

	If aMV_PAR[05] == cALL_LOC
		aMV_PAR[05] := cALL_ZZ
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Ajusta parametro de configuracao da Moeda                    |
	//����������������������������������������������������������������
	aMV_PAR[18] := If( ((aMV_PAR[18] < 1) .Or. (aMV_PAR[18] > 5)),1,aMV_PAR[18] )

	//��������������������������������������������������������������Ŀ
	//� Monta arquivo de trabalho                                    |
	//����������������������������������������������������������������
	MontaTrab(oReport,nOrdem,cAliasTRB,oSection,.F.)

	//��������������������������������������������������������������Ŀ
	//�	Processando Impressao                                        |
	//����������������������������������������������������������������
	dbSelectArea( cAliasTRB )
	( cAliasTRB )->( dbGoTop() )
	oReport:SetMeter(LastRec())

	//��������������������������������������������������������������Ŀ
	//�	Posiciona nas tabelas SB1 e SB2                              |
	//����������������������������������������������������������������
	TRPosition():New(oSection,"SB1",1,{|| If(FWModeAccess("SB1") == "E" .And. FWModeAccess("SB2") == "E",(cAliasTRB)->FILIAL+(cAliasTRB)->CODIGO,xFilial("SB1")+(cAliasTRB)->CODIGO)})
	TRPosition():New(oSection,"SB2",1,{|| (cAliasTRB)->FILIAL+(cAliasTRB)->CODIGO+(cAliasTRB)->LOCAL})

	//��������������������������������������������������������������Ŀ
	//�	Aglutina por Armazem/Filial/Empresa                          |
	//����������������������������������������������������������������
	If aMV_PAR[01] == 2
		If !(nOrdem == 5)
			oSection:Cell("B2_LOCAL"):SetValue(cALL_LOC)
		EndIf
	ElseIf aMV_PAR[01] == 3
		///oSection:Cell("B2_FILIAL"):SetValue(Replicate("*",FWSizeFilial()))
		If !(nOrdem == 5)
			oSection:Cell("B2_LOCAL"):SetValue(cALL_LOC)
		EndIf
	EndIf

	//oSection:Cell("B1_CODLMT"):SetValue(cALL_LOC)

	oSection:Init()
	cCodAnt  := ""
	cFilAnter  := ""
	While !oReport:Cancel() .And. !Eof()

		oReport:IncMeter()

		If ( (aMV_PAR[16] == 1) .Or. ((aMV_PAR[16] == 2) .And. (QtdComp(FIELD->QUANT) >= QtdComp(0)) ) .Or. ;
		   ( (aMV_PAR[16] == 3) .And. (QtdComp(FIELD->QUANT) < QtdComp(0)) ) )

		    If (cAliasTRB)->CODIGO == cCodAnt .And. (cAliasTRB)->FILIAL == cFilAnter
				//oSection:Cell('B1_COD'		):Hide()
				oSection:Cell('B1_TIPO'		):Hide()
				///oSection:Cell('B1_GRUPO'	):Hide()
				///oSection:Cell('B1_DESC'		):Hide()
				If aMV_PAR[24] == 1
					//oSection:Cell('B1_SEGUM'):Hide()
				Else
					//oSection:Cell('B1_UM'	):Hide()
				EndIf
		    Else
				oSection:Cell('B1_COD'		):Show()
				oSection:Cell('B1_CODLMT'	):Show()
				oSection:Cell('B1_TIPO'		):Show()
				oSection:Cell('B1_GRUPO'	):Show()
				oSection:Cell('B1_DESC'		):Show()
				oSection:Cell('B1_PESO'		):Show()
				oSection:Cell('B1_ENDE'		):Show()
				oSection:Cell('B1_LOJPROC'	):Show()
				If aMV_PAR[24] == 1
					//oSection:Cell('B1_SEGUM'):Show()
				Else
					oSection:Cell('B1_UM'	):Show()
				EndIf
		    EndIf

			 

		    // atribui os valores para os campos customizados
			//For nX := 1 To Len(aNameCells)
			//	oSection:Cell(aNameCells[nX]):SetValue((cAliasTRB)->&(aNameCells[nX]))
			//Next nX

			oSection:PrintLine()

			cCodAnt := (cAliasTRB)->CODIGO
			cFilAnter := (cAliasTRB)->FILIAL
		EndIf
		dbSkip()
	EndDo

	oSection:Finish()

	//��������������������������������������������������������������Ŀ
	//�	Apagando arquivo de trabalho temporario                      |
	//����������������������������������������������������������������
	oTempTable:Delete()

EndIf

Return 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MontaTrab | Autor � Marcos V. Ferreira    � Data � 16/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Preparacao do Arquivo de Trabalho p/ Relatorio             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR260                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MontaTrab(oReport,nOrdem,cAliasTRB,oSection,lVisualiz)
Local cWhere		:= ""
Local cWhereB1  	:= ""
Local cWhereB9		:= ""
Local cWhereNNR 	:= ""
Local cWhereLOCAL 	:= ""
Local aSizeQT		:= TamSX3( "B2_QATU" )
Local aSizeVL		:= TamSX3( "B2_VATU1")
Local aSaldo		:= {}
Local nQuant		:= 0
Local nValor		:= 0
Local nQuantR		:= 0
Local nValorR		:= 0
Local cFilOK		:= cFilAnt
Local cAliasSB1		:= "SB1"
Local lExcl			:= .F.
Local lAglutLoc 	:= .F.
Local lAglutFil 	:= .F.
Local lAchou    	:= .F.
Local cSeek     	:= ""
Local cCampos		:= ""
Local cAliasSB2 	:= "SB2"
Local nX			:= 0
Local cFilUser		:= ""
Local dDataRef		:= Ctod('')
Local aStrucSB1		:= {}
Local aStrucSB2		:= {}
Local aStrucSB9		:= {}
Local lVeic			:= Upper(SuperGetMV('MV_VEICULO',.F.,'N'))=="S"
Local nDec			:= 0
Local aSM0 			:= FWLoadSM0(.T., .T.)
Local aNotAccess := {}
Local nCount := 0
Local cFil := "" 
Local cGrEmp		:= FWGrpCompany()
Local cFNoAccess	:= ''
Local lNoRunCalc	:= .F.
Local cIsNull		:= MatIsNull()
Local cCodPrdAte	:= ''
Local cDescAte		:= ''
Local lMvAcento		:= Upper( SuperGetMV( 'MV_ACENTO',.F.,'N' ) ) == 'S'
Local cWhereD1		:= ""
Local cWhereD2		:= ""
Local cWhereD3		:= ""
Local cLocProc		:= GetMvNNR('MV_LOCPROC','99')
Local cAsc255		:= Chr( 255 )

Default lVisualiz:= .F.

// cria a tabela temporaria para guardar as informacoes para impress�o
NewTable(cAliasTRB, oReport:GetOrientation(),nOrdem,aSizeVL,aSizeQT,lVeic)

If !lVisualiz
	// Cria array de filiais que o usu�rio n�o possui acesso.
	For nCount := 1 To Len(aSM0)
		If aSM0[nCount,1] == cGrEmp .And. !aSM0[nCount][11]
			cFil := FWxFilial("SB2", aSM0[nCount][2])
			IIf(ASCAN(aNotAccess, cFil) == 0, AADD(aNotAccess, cFil), Nil)
		EndIf
	Next nCount

	aStrucSB1 := SB1->(dbStruct())
	aStrucSB2 := SB2->(dbStruct())
	aStrucSB9 := SB9->(dbStruct())
	
	nDec := MsDecimais(aMV_PAR[18])
	AEval( aNotAccess ,{ | x | cFNoAccess += AllTrim( x ) + '|' }  )
	dDataRef := IIf(Empty(aMV_PAR[22]),dDataBase,aMV_PAR[22])
	// obtem o filtro de usuario em formato SQL
	cFilUser := oSection:GetSqlExp()
	
	//��������������������������������������������������������������Ŀ
	//�	Aglutina por Armazem/Filial/Empresa                          |
	//����������������������������������������������������������������
	If aMV_PAR[01] == 2
		If !(nOrdem == 5)
			lAglutLoc := .T.
		EndIf
	ElseIf aMV_PAR[01] == 3
		lAglutFil := .T.
		If !(nOrdem == 5)
			lAglutLoc := .T.
		EndIf
	EndIf
	
	dbSelectArea("SB2")
	oReport:SetMeter(LastRec())
	
	cSelect := ""
	
	//Adiciona campos personalizados na Query para Aglutinar valores
	For nX := 1 To Len(aNameCells)
		cSelect += "," + aNameCells[nX] + " "
	Next nX
	
	//������������������������������������������������������������������������Ŀ
	//� Filtro adicional no clausula Where                                     |
	//��������������������������������������������������������������������������
	cWhere := ""
	If lVeic
		If !Empty( aMV_PAR[15] )
			cWhere += " SB1.B1_CODITE BETWEEN '" + aMV_PAR[14] + "' AND '" + aMV_PAR[15] + "' "
		EndIf

	Else
		If !Empty( aMV_PAR[07] )
			cCodPrdAte := IIf( Left( AllTrim( Upper( aMV_PAR[07] ) ), 3 ) == 'ZZZ' .And. lMvAcento, cAsc255, aMV_PAR[07] )
			cWhere += " SB1.B1_COD    BETWEEN '" + aMV_PAR[06] + "' AND '" + cCodPrdAte + "' "
		EndIf
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Considera filtro de usuario                                  �
	//����������������������������������������������������������������
	If !Empty(cFilUser)
		cWhere +=  + IIf( Empty( cWhere ), " " + cFilUser , " AND " + cFilUser )
	EndIf
	cWhere += ""
	
	cWhereB2 := ""
	If FWModeAccess("SB2") == "E"
		If !Empty( aMV_PAR[03] )
			cWhereB2 += " SB2.B2_FILIAL BETWEEN '"+ aMV_PAR[02] + "' AND '" + aMV_PAR[03] + "' "
		EndIf
	Else
	    cWhereB2 += " SB2.B2_FILIAL = '" + xFilial("SB2") + "'"
	EndIf
	cWhereB2 += ""
	
	cWhereB9 := ""
	If FWModeAccess("SB9") == "E"
		If !Empty( aMV_PAR[03] )
			cWhereB9 += " SB9A.B9_FILIAL BETWEEN '"+ aMV_PAR[02] + "' AND '" + aMV_PAR[03] + "' "
		EndIf
	Else
	    cWhereB9 += " SB9A.B9_FILIAL = '" + xFilial("SB1") + "' "
	EndIf
	cWhereB9 += ""
	
	cWhereB1 := ""
	If FWModeAccess("SB1") == "E"
		If FWModeAccess("SB2") == "E"
			cWhereB1 += " SB1.B1_FILIAL = SB2.B2_FILIAL "
	    Else
			If !Empty( aMV_PAR[03] )
				cWhereB1 += " SB1.B1_FILIAL BETWEEN '"+ aMV_PAR[02] + "' AND '" + aMV_PAR[03] + "' "
			EndIf
	    EndIf
	Else
	     cWhereB1 += " SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
	EndIf
	cWhereB1 += ""
	
	cWhereNNR := ""
	If FWModeAccess("NNR") == "E"
		If FWModeAccess("SB2") == "E"
			cWhereNNR += " NNR.NNR_FILIAL = SB2.B2_FILIAL "
	    Else
			If !Empty( aMV_PAR[03] )
				cWhereNNR += " NNR.NNR_FILIAL BETWEEN '"+ aMV_PAR[02] + "' AND '" + aMV_PAR[03] + "' "
			EndIf
	    EndIf
	Else
	   	cWhereNNR += " NNR.NNR_FILIAL = '" + xFilial("NNR") + "'"
	EndIf
	cWhereNNR += ""


	cWhereD1 := ""
	If FWModeAccess("SD1") == "E"
		If FWModeAccess("SB2") == "E"
			cWhereD1 += " SD1.D1_FILIAL = SB2.B2_FILIAL "
	    Else
			If !Empty( aMV_PAR[03] )
				cWhereD1 += " SD1.D1_FILIAL BETWEEN '"+ aMV_PAR[02] + "' AND '" + aMV_PAR[03] + "' "
			EndIf
		EndIf
	Else
	    cWhereD1 += " SD1.D1_FILIAL = '" + xFilial("SD1") + "'"
	EndIf
	cWhereD1 += " "

	cWhereD2 := ""
	If FWModeAccess("SD2") == "E"
		If FWModeAccess("SB2") == "E"
			cWhereD2 += " SD2.D2_FILIAL = SB2.B2_FILIAL "
	    Else
			If !Empty( aMV_PAR[03] )
				cWhereD2 += " SD2.D2_FILIAL BETWEEN '"+ aMV_PAR[02] + "' AND '" + aMV_PAR[03] + "' "
			EndIf
		EndIf
	Else
	    cWhereD2 += " SD2.D2_FILIAL = '" + xFilial("SD2") + "'"
	EndIf
	cWhereD2 += " "

	cWhereD3 := ""
	If FWModeAccess("SD3") == "E"
		If FWModeAccess("SB2") == "E"
			cWhereD3 += " SD3.D3_FILIAL = SB2.B2_FILIAL "
	    Else
			If !Empty( aMV_PAR[03] )
				cWhereD3 += " SD3.D3_FILIAL BETWEEN '"+ aMV_PAR[02] + "' AND '" + aMV_PAR[03] + "' "
			EndIf
		EndIf
	Else
	    cWhereD3 += " SD3.D3_FILIAL = '" + xFilial("SD3") + "'"
	EndIf
	cWhereD3 += " "

	cWhereLOCAL := ""
	If !Empty( aMV_PAR[05] )
		cWhereLOCAL += " SB2.B2_LOCAL BETWEEN '"+ aMV_PAR[04] + "' AND '" + aMV_PAR[05] + "' "
	EndIf

	cCampos +=""
	For nX := 1 To Len(aNameCells)
		cCampos += ", " + aNameCells[nX]
	Next nX
	cCampos +=""

	//������������������������������������������������������������������������Ŀ
	//�Transforma parametros Range em expressao SQL                            �
	//��������������������������������������������������������������������������
	MakeSqlExpr(oReport:uParam)
	
	cAliasSB2 := GetNextAlias()
	cAliasSB1 := cAliasSB2
	
	//������������������������������������������������������������������������Ŀ
	//�Inicio do Embedded SQL                                                  �
	//��������������������������������������������������������������������������

	cQuery := " SELECT B2_FILIAL, B2_LOCAL, B2_COD, "
	If (aMV_PAR[17] == 3)
		cQuery += "	   		"+ cIsNull +"( SB9.B9_COD, ' ' ) B9_COD,  	"
		cQuery += "	   		"+ cIsNull +"( SB9.B9_QINI,  0  ) B9_QINI,  "
		cQuery += "	   		"+ cIsNull +"( SB9.B9_QISEGUM, 0  ) B9_QISEGUM,"
		cQuery += "	   		"+ cIsNull +"( SB9.B9_VINI1, 0  ) B9_VINI1, " 
		cQuery += "	   		"+ cIsNull +"( SB9.B9_VINI2, 0  ) B9_VINI2, " 
		cQuery += "	   		"+ cIsNull +"( SB9.B9_VINI3, 0  ) B9_VINI3, " 
		cQuery += "	   		"+ cIsNull +"( SB9.B9_VINI4, 0  ) B9_VINI4, " 
		cQuery += "	   		"+ cIsNull +"( SB9.B9_VINI5, 0  ) B9_VINI5, " 				

		cQuery += "	   		( 	SELECT "+ cIsNull +"( MAX( SD1.D1_COD ), ' ' ) D1_COD "
		cQuery += "	   			FROM "+ RetSQLName( 'SD1' ) +"  SD1 "
		cQuery += "	   			WHERE "+ IIf( Empty( cWhereD1 ), " SD1.D1_FILIAL IS NOT NULL ", cWhereD1 ) +" "
		cQuery += "	   				AND SD1.D1_COD =  "+ cIsNull +"( SB9.B9_COD, ' ' )  "
		cQuery += "	   				AND SD1.D1_LOCAL = "+ cIsNull +"( SB9.B9_LOCAL, ' ' )"  
		cQuery += "	   				AND SD1.D1_DTDIGIT BETWEEN  "+ cIsNull +"( SB9.B9_DATA, ' ' ) AND '"+ Dtos( dDataRef ) +"'  "
		cQuery += "	   				AND SD1.D_E_L_E_T_ = ' '  "
		cQuery += "	   		) D1_COD,  "

		cQuery += "	   		( 	SELECT "+ cIsNull +"( MAX( SD2.D2_COD ), ' ' ) D2_COD  "
		cQuery += "	   			FROM "+ RetSQLName( 'SD2' ) +"   SD2  "
		cQuery += "	   			WHERE "+ IIf( Empty( cWhereD2 ), " SD2.D2_FILIAL IS NOT NULL ", cWhereD2 ) +" "
		cQuery += "	   				AND SD2.D2_COD =  "+ cIsNull +"( SB9.B9_COD, ' ' ) " 
		cQuery += "	   				AND SD2.D2_LOCAL =  "+ cIsNull +"( SB9.B9_LOCAL, ' ' ) "  
		cQuery += "	   				AND SD2.D2_EMISSAO BETWEEN  "+ cIsNull +"( SB9.B9_DATA, ' ' ) AND '"+ Dtos( dDataRef ) +"'  "
		cQuery += "	   				AND SD2.D_E_L_E_T_ = ' '  "
		cQuery += "	   		) D2_COD,  "

		cQuery += "			( 	SELECT  "+ cIsNull +"( MAX( SD3.D3_COD ), ' ' )  "
		cQuery += "			  	FROM  "+ RetSQLName( 'SD3' ) +"   SD3  "
		cQuery += "			  	WHERE "+ IIf( Empty( cWhereD3 ), " SD3.D3_FILIAL IS NOT NULL ", cWhereD3 ) +" "
		cQuery += "				  AND SD3.D3_COD =  "+ cIsNull +"( SB9.B9_COD, ' ' )  "
		cQuery += "	   			  AND SD3.D3_LOCAL =  "+ cIsNull +"( SB9.B9_LOCAL, ' ' )  "
		cQuery += "	   			  AND SD3.D3_EMISSAO BETWEEN  "+ cIsNull +"( SB9.B9_DATA, ' ' ) AND '"+ Dtos( dDataRef ) +"'  "
		cQuery += "	   			  AND SD3.D_E_L_E_T_ = ' '  "
		cQuery += "	   	  	) D3_COD, "  
	EndIf

	cQuery += "	   		B2_QATU, B2_QTSEGUM, B2_QFIM, B2_QFIM2, B2_VATU1, B2_VATU2, "
	cQuery += "   	   	B2_VATU3, B2_VATU4, B2_VATU5, B2_VFIMFF1, B2_VFIMFF2, B2_VFIMFF3, B2_VFIMFF4, B2_VFIMFF5, "
	cQuery += "   	   	B2_QEMP, B2_QEMP2, B2_QEMPPRE, B2_RESERVA, B2_RESERV2, B2_QEMPSA, B2_QEMPPRJ, B2_VFIM1, "
	cQuery += "   	   	B2_QEMPPR2, B2_VFIM2, B2_VFIM3, B2_VFIM4, B2_VFIM5, B1_COD, B1_FILIAL, B1_TIPO, B1_GRUPO, "
	cQuery += "   	   	B1_DESC, B1_CUSTD, B1_UPRC, B1_MCUSTD, B1_SEGUM, B1_UM, B1_CODITE, NNR_DESCRI, "
	cQuery += "   	   	B1_CODLMT,B1_PESO,B1_ENDE,B1_LOJPROC,B2_SALPPRE, B2_QEPRE2 "

	cQuery += "   	   "+ IIf( Empty( cCampos ), '', cCampos ) +" "

	cQuery += " FROM "+ RetSQLName( 'SB2' ) +" SB2 "
	cQuery += " 	INNER JOIN "+ RetSQLName( 'SB1' ) +" SB1 ON ( "+ IIf( Empty( cWhereB1 ), " SB1.B1_COD = SB2.B2_COD " , cWhereB1 +" AND SB1.B1_COD = SB2.B2_COD "  ) +" ) "
	cQuery += " 	INNER JOIN "+ RetSQLName( 'NNR' ) +" NNR ON ( "+ IIf( Empty( cWhereNNR ), " NNR.NNR_CODIGO = SB2.B2_LOCAL " , cWhereNNR +" AND NNR.NNR_CODIGO = SB2.B2_LOCAL "  ) +" ) "
	
	If (aMV_PAR[17] == 3)
		cQuery += " 	LEFT OUTER JOIN (  "
		cQuery += " 				  SELECT B9_FILIAL, B9_COD, B9_LOCAL, B9_DATA, B9_QINI, B9_VINI1, B9_QISEGUM, B9_VINI2, B9_VINI3, B9_VINI4, B9_VINI5 "
		cQuery += " 				  FROM "+ RetSQLName( 'SB9' ) +" SB9A "
		cQuery += " 				  WHERE "+ cWhereB9 + " AND "
		cQuery += " 					SB9A.B9_DATA = (  "
		cQuery += " 					 					SELECT "+ cIsNull +"( MAX( SB9B.B9_DATA ), ' ' )  "
		cQuery += " 					  					FROM "+ RetSQLName( 'SB9' ) +" SB9B  "
		cQuery += " 				  						WHERE SB9B.B9_FILIAL = SB9A.B9_FILIAL  "
		cQuery += " 						  					AND SB9B.B9_COD  = SB9A.B9_COD  "
		cQuery += " 						  					AND SB9B.B9_LOCAL = SB9A.B9_LOCAL"  
		cQuery += " 						  					AND SB9B.B9_DATA <= '"+ Dtos( dDataRef ) +"'  "
		cQuery += " 						  					AND SB9B.D_E_L_E_T_ = ' '  "
		cQuery += " 					  					)  "
		cQuery += " 				  AND SB9A.D_E_L_E_T_ = ' '  "
		cQuery += " 	) SB9 ON ( SB9.B9_FILIAL = SB2.B2_FILIAL AND SB9.B9_COD = SB2.B2_COD AND SB9.B9_LOCAL = SB2.B2_LOCAL )  "
	EndIf

	cQuery += " WHERE "+ IIf( Empty( cWhereB2 ), "", cWhereB2 + " AND " ) +" "
	If !Empty( aMV_PAR[11] )
		cQuery += " 	SB1.B1_GRUPO BETWEEN '"+ aMV_PAR[10] +"' AND '"+ aMV_PAR[11] +"' AND "
	EndIf
	
	If !Empty( aMV_PAR[09] )
		cQuery += " 	SB1.B1_TIPO  BETWEEN '"+ aMV_PAR[08] +"' AND '"+ aMV_PAR[09] +"' AND "
	EndIf
	
	If !Empty( aMV_PAR[13] )
		cDescAte := IIf( Left( AllTrim( Upper( aMV_PAR[13] ) ), 3 ) == 'ZZZ' .And. lMvAcento, cAsc255, aMV_PAR[13] )
		cQuery += " 	SB1.B1_DESC BETWEEN  '"+ aMV_PAR[12] +"' AND '"+ cDescAte +"' AND "
	EndIf
	
	If !Empty( cWhereLOCAL )
		cQuery += " 	"+ cWhereLOCAL +" AND "
	EndIf
	
	If !Empty( cWhere )
		cQuery += "   "+ cWhere +" AND "
	EndIf

	If !( Empty( cFNoAccess ) )
		cQuery += " SB2.B2_FILIAL NOT IN "+ FormatIn( cFNoAccess, '|' ) +" AND "
	EndIf

	cQuery += " 	NNR.D_E_L_E_T_ = ' ' "
	cQuery += " 	AND SB2.D_E_L_E_T_ = ' ' "
	cQuery += " 	AND SB1.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., __cRdd, TcGenQry( ,, cQuery ), cAliasSB2, .T., .F. )
	
	AEval( aStrucSB1, { | x | IIf( x[2] <> "C", TcSetField(cAliasSB2, x[1], x[2], x[3], x[4] ), Nil ) } )
	AEval( aStrucSB2, { | x | IIf( x[2] <> "C", TcSetField(cAliasSB2, x[1], x[2], x[3], x[4] ), Nil ) } )
	
	If (aMV_PAR[17] == 3)
		AEval( aStrucSB9, { | x | IIf( x[2] <> "C", TcSetField(cAliasSB2, x[1], x[2], x[3], x[4] ), Nil ) } )
	EndIf
	
	nContador := 0
	lExcl := xFilial("SB2") != Space(FwSizeFilial())
	dbSelectArea( cAliasSB2 )
	While !oReport:Cancel() .And. !Eof()
		
		If lExcl
			cFilAnt := (cAliasSB2)->B2_FILIAL
		EndIf
	
		oReport:IncMeter()
		If (aMV_PAR[17] == 3)
			lNoRunCalc := ( !Empty( ( cAliasSB2 )->B9_COD ) ) .And. ( Empty( ( cAliasSB2 )->D1_COD ) .And. Empty( ( cAliasSB2 )->D2_COD ) .And. Empty( ( cAliasSB2 )->D3_COD ) ) .And. (cAliasSB2)->B2_LOCAL <> cLocProc
		EndIf

		Do Case
			Case (aMV_PAR[17] == 1)
				nQuant := If( aMV_PAR[24]==1, ConvUM( (cAliasSB2)->B2_COD, (cAliasSB2)->B2_QATU, (cAliasSB2)->B2_QTSEGUM, 2 ), (cAliasSB2)->B2_QATU )

			Case (aMV_PAR[17] == 2)
				nQuant := If( aMV_PAR[24]==1, ConvUM( (cAliasSB2)->B2_COD, (cAliasSB2)->B2_QFIM, (cAliasSB2)->B2_QFIM2, 2 ), (cAliasSB2)->B2_QFIM )
			
			Case (aMV_PAR[17] == 3)
				If lNoRunCalc
					nQuant := If( aMV_PAR[24]==1, ( cAliasSB2 )->B9_QISEGUM, ( cAliasSB2 )->B9_QINI )
				Else
					nQuant := (aSaldo := CalcEst( (cAliasSB2)->B2_COD,(cAliasSB2)->B2_LOCAL,dDataRef+1,(cAliasSB2)->B2_FILIAL ))[ If( aMV_PAR[24]==1, 7, 1 ) ]
				EndIf

			Case (aMV_PAR[17] == 4)
				nQuant := If( aMV_PAR[24]==1, ConvUM( (cAliasSB2)->B2_COD, (cAliasSB2)->B2_QFIM, (cAliasSB2)->B2_QFIM2, 2 ), (cAliasSB2)->B2_QFIM )
			
			Case (aMV_PAR[17] == 5)
				nQuant := (aSaldo := CalcEstFF( (cAliasSB2)->B2_COD,(cAliasSB2)->B2_LOCAL,dDataRef+1,(cAliasSB2)->B2_FILIAL ))[ If( aMV_PAR[24]==1, 7, 1 ) ]
		EndCase

		dbSelectArea( cAliasSB1 )
		If (aMV_PAR[21] == 1)
			Do Case
				Case (aMV_PAR[17] == 1)
					nValor := (cAliasSB2)->(FieldGet( FieldPos( "B2_VATU"+Str( aMV_PAR[18],1 ) ) ))
				
				Case (aMV_PAR[17] == 2)
					nValor := (cAliasSB2)->(FieldGet( FieldPos( "B2_VFIM"+Str( aMV_PAR[18],1 ) ) ))
				
				Case (aMV_PAR[17] == 3)
					If lNoRunCalc
						nValor := (cAliasSB2)->( FieldGet( FieldPos( "B9_VINI"+Str( aMV_PAR[18],1 ) ) ))
					Else
						nValor := aSaldo[ 1+aMV_PAR[18] ]
					EndIf
					
				Case (aMV_PAR[17] == 4)
					nValor := (cAliasSB2)->(FieldGet( FieldPos( "B2_VFIMFF"+Str( aMV_PAR[18],1 ) ) ))

				Case (aMV_PAR[17] == 5)
						nValor := aSaldo[ 1+aMV_PAR[18] ]
	
			EndCase
		Else
			//�����������������������������������������������������������������Ŀ
			//� Converte valores para a moeda do relatorio (C.St. e U.Pr.Compra)�
			//�������������������������������������������������������������������
			Do Case
				Case (aMV_PAR[21] == 2)
					nValor := nQuant * xMoeda( RetFldProd((cAliasSB1)->B1_COD,"B1_CUSTD",cAliasSB1),Val( (cAliasSB1)->B1_MCUSTD ),aMV_PAR[18],dDataRef,4 )
				Case (aMV_PAR[21] == 3)  // Ult.Pr.Compra sempre na Moeda 1
					nValor := nQuant * xMoeda( RetFldProd((cAliasSB1)->B1_COD,"B1_UPRC" ,cAliasSB1),1,aMV_PAR[18],dDataRef,4 )
			EndCase
		EndIf
	
		If (aMV_PAR[24]==1)
			nQuantR := (cAliasSB2)->B2_QEMP2 + AvalQtdPre("SB2",1,.T.,cAliasSB2) + (cAliasSB2)->B2_RESERV2  + ConvUM( (cAliasSB2)->B2_COD, (cAliasSB2)->B2_QEMPSA, 0, 2)+(cAliasSB2)->B2_QEMPPR2
		Else
			nQuantR := (cAliasSB2)->B2_QEMP + AvalQtdPre("SB2",1,NIL,cAliasSB2) + (cAliasSB2)->B2_RESERVA + (cAliasSB2)->B2_QEMPSA + (cAliasSB2)->B2_QEMPPRJ
		EndIf
	
		nValorR := (QtdComp(nValor) / QtdComp(nQuant)) * QtdComp(nQuantR)

		//Verifica se � para Apresentar os Registros com Valores e Quantidades Zerados
		If ( aMV_PAR[20] == 2 .And. QtdComp( nQuant ) == QtdComp( 0 ) ) .Or. ( aMV_PAR[23] == 2 .And. QtdComp( nValor ) == QtdComp( 0 ) )
			dbSelectArea( cAliasSB2 )
			( cAliasSB2 )->( dbSkip() )
			Loop
		EndIf

		//���������������������������������������������������������������Ŀ
		//� Monta Chave de pesquisa para aglutinar Armazem/Filial/Empresa �
		//�����������������������������������������������������������������
		If lAglutLoc .Or. lAglutFil
			If (nOrdem == 5)
				cSeek := (cAliasSB2)->B2_LOCAL
			Else
				cSeek := ""
			EndIf
			Do Case
				Case (nOrdem == 1)
					If (aMV_PAR[19] == 1)
						cSeek += IIf(aMV_PAR[24]==1,(cAliasSB1)->B1_SEGUM,(cAliasSB1)->B1_UM)
					EndIf
					cSeek += IIf(!lVeic,(cAliasSB2)->B2_COD,(cAliasSB2)->B1_CODITE)+IIf(lAglutFil,"",(cAliasSB2)->B2_FILIAL)+IIf(lAglutLoc,"",(cAliasSB2)->B2_LOCAL)
				Case (nOrdem == 2)
					cSeek += (cAliasSB1)->B1_TIPO
					If (aMV_PAR[19] == 1)
						cSeek += IIf(aMV_PAR[24]==1,(cAliasSB1)->B1_SEGUM,(cAliasSB1)->B1_UM)
					EndIf
					cSeek += IIf(!lVeic,(cAliasSB2)->B2_COD,(cAliasSB2)->B1_CODITE)+IIf(lAglutFil,"",(cAliasSB2)->B2_FILIAL)+IIf(lAglutLoc,"",(cAliasSB2)->B2_LOCAL)
				Case (nOrdem == 3)
					If (aMV_PAR[19] == 1)
						cSeek += IIf(aMV_PAR[24]==1,(cAliasSB1)->B1_SEGUM,(cAliasSB1)->B1_UM)
					EndIf
					cSeek += (cAliasSB1)->B1_DESC+IIf(!lVeic,(cAliasSB2)->B2_COD,(cAliasSB2)->B1_CODITE)+IIf(lAglutFil,"",(cAliasSB2)->B2_FILIAL)+IIf(lAglutLoc,"",(cAliasSB2)->B2_LOCAL)
				Case (nOrdem == 4)
					cSeek += (cAliasSB1)->B1_GRUPO
					If (aMV_PAR[19] == 1)
						cSeek += IIf(aMV_PAR[24]==1,(cAliasSB1)->B1_SEGUM,(cAliasSB1)->B1_UM)
					EndIf
					cSeek += IIf(!lVeic,(cAliasSB2)->B2_COD,(cAliasSB2)->B1_CODITE)+IIf(lAglutFil,"",(cAliasSB2)->B2_FILIAL)+IIf(lAglutLoc,"",(cAliasSB2)->B2_LOCAL)
				Case (nOrdem == 5)
					If (aMV_PAR[19] == 1)
						cSeek += IIf(aMV_PAR[24]==1,(cAliasSB1)->B1_SEGUM,(cAliasSB1)->B1_UM)
					EndIf
					cSeek += IIf(!lVeic,(cAliasSB2)->B2_COD,(cAliasSB2)->B1_CODITE)+IIf(lAglutFil,"",(cAliasSB2)->B2_FILIAL)
				OtherWise
					If (aMV_PAR[19] == 1)
						cSeek += IIf(aMV_PAR[24]==1,(cAliasSB1)->B1_SEGUM,(cAliasSB1)->B1_UM)
					EndIf
					cSeek += IIf(!lVeic,(cAliasSB2)->B2_COD,(cAliasSB2)->B1_CODITE)+IIf(lAglutLoc,"",(cAliasSB2)->B2_LOCAL)
			EndCase
		EndIf
	
		dbSelectArea( cAliasTRB )
		If lAglutLoc .Or. lAglutFil
		    lAchou := !dbSeek( cSeek )
			If ( lAchou )
				( cAliasTRB )->( dbAppend( lAchou ) )
			Else
				RecLock( cAliasTRB, lAchou )				
			EndIf
		Else
			( cAliasTRB )->( dbAppend( .T. ) )
		EndIf
	
		FIELD->FILIAL := (cAliasSB2)->B2_FILIAL
		FIELD->CODIGO := (cAliasSB2)->B2_COD
		FIELD->CODLMT := (cAliasSB1)->B1_CODLMT
		FIELD->PESO := (cAliasSB1)->B1_PESO
		FIELD->ENDE :=(cAliasSB1)->B1_ENDE
		FIELD->LOJPROC := (cAliasSB1)->B1_LOJPROC
		FIELD->LOCAL  := (cAliasSB2)->B2_LOCAL
		FIELD->TIPO   := (cAliasSB1)->B1_TIPO
		FIELD->GRUPO  := (cAliasSB1)->B1_GRUPO
		FIELD->DESCRI := (cAliasSB1)->B1_DESC
		If aMV_PAR[24] == 1
			FIELD->SEGUM  := (cAliasSB1)->B1_SEGUM
	 	Else
	 		FIELD->UM     := (cAliasSB1)->B1_UM
	 	EndIf
		FIELD->QUANTR += nQuantR
		FIELD->VALORR += Round(nValorR,nDec)
		FIELD->QUANT  += nQuant
		FIELD->VALOR  += Round(nValor,nDec)
		///FIELD->DISPON += (nQuant - nQuantR)
		If lVeic
			FIELD->CODITE := (cAliasSB1)->B1_CODITE
		EndIf
		If aMV_PAR[25] == 1
			FIELD->DESCARM := (cAliasSB2)->NNR_DESCRI
		EndIf
	
		For nX := 1 To Len(aNameCells)
			FIELD->&(aNameCells[nX]) += (cAliasSB2)->&(aNameCells[nX])
		Next nX

		If lAglutLoc .Or. lAglutFil
			If ( lAchou )
				( cAliasTRB )->( dbCommit() )		
			Else
				( cAliasTRB )->( MsUnlock() )
			EndIf
		Else
			( cAliasTRB )->( dbCommit() )		
		EndIf

		dbSelectArea( cAliasSB2 )
		( cAliasSB2 )->( dbSkip() )	
	EndDo

	( cAliasTRB )->( dbrUnlock() )
	( cAliasTRB )->( dbCommit() )

	cFilAnt := cFilOK

	//�������������������������������������������������������������������������������������Ŀ
	//� Apaga os arquivos de trabalho, cancela os filtros e restabelece as ordens originais.|
	//���������������������������������������������������������������������������������������
	dbSelectArea(cAliasSB2)
	dbCloseArea()
	ChkFile("SB2",.F.)
	
	dbSelectArea("SB1")
	dbClearFilter()
EndIf

Return .T.

// Define qual o Grupo de pergunta a ser
//utilizado no relatorio
Static Function DefineSX1()
Local cRet		:= "MTR260"
Local lRet 		:= .T.
Local lVeiculo	:= Upper(SuperGetMV('MV_VEICULO',.F.,'N'))=="S"

If TableInDic("G3Q",.F.)
	dbSelectArea("SX1")
	dbSetOrder(1) //X1_GRUPO+X1_ORDEM
	If dbSeek("MTR260R1")
		cRet := "MTR260R1"
	EndIf
EndIf

lRet := (cRet == "MTR260R1")

// Se estou tratando o grupo de pergunta MTR260 devo verificar se
// a pergunta 06 est� correta
If !lRet
	dbSelectArea("SX1")
	dbSetOrder(1) //X1_GRUPO+X1_ORDEM
	If dbSeek(padr(cRet,len(SX1->X1_GRUPO))+ "06")
		If lVeiculo
			If SX1->X1_F3==padr("VR4",len(SX1->X1_F3))
				lRet := .T.
			EndIf
		Else
			If SX1->X1_F3==padr("SB1",len(SX1->X1_F3))
				lRet := .T.
			EndIf
		EndIf
	EndIf
EndIf

Return {cRet,lRet}


/*/{Protheus.doc} NewTable
//TODO Cria a tabela temporaria para armazenar as informa�oes que ser�o impressas 
@author reynaldo
@since 26/02/2018
@version 1.0
@return logico, sempre verdadeiro
@param cAliasTRB, caracter, nome do alias da tabela 
@param lTamDesc, logical, define o tamanho do descricao, conforme orientacao de impressao do relatorio
@param nOrdem, numeric, define a ordem de impress�o que impacta na ordenacao dos registros
@param aSizeVL, array, tamanho e decimais para campos de valor(custo)
@param aSizeQT, array, tamanho e decimais para campos de quantidade
@param lVeic, logical, descricao
@type function
/*/
Static Function NewTable(cAliasTRB, lTamDesc,nOrdem,aSizeVL,aSizeQT,lVeic)
Local cUM    	:= If(aMV_PAR[24] == 1,"SEGUM","UM")
Local aCampos	:= {}
Local nX		:= 0
Local aIndxKEY	:= {}
Local aSizeCell	:= {}
Local aSB1Ite 	:= TAMSX3("B1_CODITE")

DEFAULT aSizeQT	:= TamSX3( "B2_QATU" )
DEFAULT aSizeVL	:= TamSX3( "B2_VATU1")
 		
aCampos:= {	{ "FILIAL"	,"C",FWSizeFilial(),00 },;
			{ "CODIGO"	,"C",TamSX3("B1_COD")[1],00 },;
			{ "CODLMT"	,"C",TamSX3("B1_CODLMT")[1],00 },;
			{ "LOCAL"	,"C",TamSX3("B2_LOCAL")[1],00 },;
			{ "LOJPROC"	,"C",20	,00 },;
			{ "TIPO"	,"C",02	,00 },;
			{ "GRUPO"	,"C",04	,00 },;
			{ "ENDE"	,"C",12	,00 },;
			{ "DESCRI"	,"C",If(lTamDesc == 1,50,TamSX3("B1_DESC")[1]),00 },;
			{ cUM     	,"C",02	,00 },;
			{ "PESO"	,"N",aSizeVL[ 1 ]+1	, aSizeVL[ 2 ] },;
			{ "VALORR"	,"N",aSizeVL[ 1 ]+1	, aSizeVL[ 2 ] },;
			{ "QUANTR"	,"N",aSizeQT[ 1 ]+1	, aSizeQT[ 2 ] },;
			{ "VALOR"	,"N",aSizeVL[ 1 ]+1	, aSizeVL[ 2 ] },;
			{ "QUANT"	,"N",aSizeQT[ 1 ]+1	, aSizeQT[ 2 ] },;
			{ "DESCARM"	,"C",TamSX3("NNR_DESCRI")[1],00 } }
			//{ "DISPON"	,"N",aSizeQT[ 1 ]+1	, aSizeQT[ 2 ] };
	//	}

If Len(aNameCells)>0
	//Adiciona campos personalizados a query
	For nX := 1 To Len(aNameCells)
		aSizeCell := TamSx3(aNameCells[nX])
		aAdd(aCampos,{aNameCells[nX],"N",aSizeCell[1],aSizeCell[2]})
	Next nX
EndIf

//��������������������������������������������������������������Ŀ
//� Para SIGAVEI, SIGAPEC e SIGAOFI                              �
//����������������������������������������������������������������
If !lVeic
	If (aMV_PAR[01] == 1)
		If (nOrdem == 5)
			Aadd(aIndxKEY,"LOCAL")
		Else
			Aadd(aIndxKEY,"FILIAL")
		EndIf
		Do Case
			Case (nOrdem == 1)
				If (aMV_PAR[19] == 1)
					Aadd(aIndxKEY,cUM)
				EndIf
				Aadd(aIndxKEY,"CODIGO")
				Aadd(aIndxKEY,"LOCAL")
			Case (nOrdem == 2)
				Aadd(aIndxKEY,"TIPO")
				If (aMV_PAR[19] == 1)
					Aadd(aIndxKEY,cUM)
				EndIf
				Aadd(aIndxKEY,"CODIGO")
				Aadd(aIndxKEY,"LOCAL")
			Case (nOrdem == 3)
				If (aMV_PAR[19] == 1)
					Aadd(aIndxKEY,cUM)
				EndIf
				Aadd(aIndxKEY,"DESCRI")
				Aadd(aIndxKEY,"CODIGO")
				Aadd(aIndxKEY,"LOCAL")
			Case (nOrdem == 4)
				Aadd(aIndxKEY,"GRUPO")
				If (aMV_PAR[19] == 1)
					Aadd(aIndxKEY,cUM)
				EndIf
				Aadd(aIndxKEY,"CODIGO")
				Aadd(aIndxKEY,"LOCAL")
			Case (nOrdem == 5)
				If (aMV_PAR[19] == 1)
					Aadd(aIndxKEY,cUM)
				EndIf
				Aadd(aIndxKEY,"CODIGO")
				Aadd(aIndxKEY,"FILIAL")
			OtherWise
				If (aMV_PAR[19] == 1)
					Aadd(aIndxKEY,cUM)
				EndIf
				Aadd(aIndxKEY,"CODIGO")
				Aadd(aIndxKEY,"LOCAL")
		EndCase
	Else //-- (aMV_PAR[01] == 1)
		If (nOrdem == 5)
			Aadd(aIndxKEY,"LOCAL")
		Else
			aIndxKEY := {}
		EndIf

		Do Case
			Case (nOrdem == 1)
				If (aMV_PAR[19] == 1)
					Aadd(aIndxKEY,cUM)
				EndIf
				Aadd(aIndxKEY,"CODIGO")
				Aadd(aIndxKEY,"FILIAL")
				Aadd(aIndxKEY,"LOCAL")
			Case (nOrdem == 2)
				Aadd(aIndxKEY,"TIPO")
				If (aMV_PAR[19] == 1)
					Aadd(aIndxKEY,cUM)
				EndIf
				Aadd(aIndxKEY,"CODIGO")
				Aadd(aIndxKEY,"FILIAL")
				Aadd(aIndxKEY,"LOCAL")
			Case (nOrdem == 3)
				If (aMV_PAR[19] == 1)
					Aadd(aIndxKEY,cUM)
				EndIf
				Aadd(aIndxKEY,"DESCRI")
				Aadd(aIndxKEY,"CODIGO")
				Aadd(aIndxKEY,"FILIAL")
				Aadd(aIndxKEY,"LOCAL")
			Case (nOrdem == 4)
				Aadd(aIndxKEY,"GRUPO")
				If (aMV_PAR[19] == 1)
					Aadd(aIndxKEY,cUM)
				EndIf
				Aadd(aIndxKEY,"CODIGO")
				Aadd(aIndxKEY,"FILIAL")
				Aadd(aIndxKEY,"LOCAL")
			Case (nOrdem == 5)
				If (aMV_PAR[19] == 1)
					Aadd(aIndxKEY,cUM)
				EndIf
				Aadd(aIndxKEY,"CODIGO")
				Aadd(aIndxKEY,"FILIAL")
			OtherWise
				If (aMV_PAR[19] == 1)
					Aadd(aIndxKEY,cUM)
				EndIf
				Aadd(aIndxKEY,"CODIGO")
				Aadd(aIndxKEY,"LOCAL")
		EndCase
	EndIf
Else
	aAdd(aCampos,{"CODITE","C",aSB1Ite[ 1 ],00})
	If (aMV_PAR[01] == 1) // ARMAZEN
		If (nOrdem == 5) // ALMOXARIFADO
			Aadd(aIndxKEY,"LOCAL")
		Else
			Aadd(aIndxKEY,"FILIAL")
		EndIf
		Do Case
			Case (nOrdem == 1)
				If (aMV_PAR[19] == 1)
					Aadd(aIndxKEY,cUM)
				EndIf
				Aadd(aIndxKEY,"CODITE")
				Aadd(aIndxKEY,"LOCAL")
			Case (nOrdem == 2)
				Aadd(aIndxKEY,"TIPO")
				If (aMV_PAR[19] == 1)
					Aadd(aIndxKEY,cUM)
				EndIf
				Aadd(aIndxKEY,"CODITE")
				Aadd(aIndxKEY,"LOCAL")
			Case (nOrdem == 3)
				If (aMV_PAR[19] == 1)
					Aadd(aIndxKEY,cUM)
				EndIf
 				Aadd(aIndxKEY,"DESCRI")
 				Aadd(aIndxKEY,"CODITE")
 				Aadd(aIndxKEY,"LOCAL")
			Case (nOrdem == 4)
				Aadd(aIndxKEY,"GRUPO")
				If (aMV_PAR[19] == 1)
					Aadd(aIndxKEY,cUM)
				EndIf
				Aadd(aIndxKEY,"CODITE")
				Aadd(aIndxKEY,"LOCAL")
			Case (nOrdem == 5)
				If (aMV_PAR[19] == 1)
					Aadd(aIndxKEY,cUM)
				EndIf
				Aadd(aIndxKEY,"CODITE")
				Aadd(aIndxKEY,"FILIAL")
			OtherWise
				If (aMV_PAR[19] == 1)
					Aadd(aIndxKEY,cUM)
				EndIf
				Aadd(aIndxKEY,"CODITE")
				Aadd(aIndxKEY,"LOCAL")
		EndCase
	Else // FILIAL / EMPRESA
		If (nOrdem == 5) // ALMOXARIFADO
			Aadd(aIndxKEY,"LOCAL")
		Else
			aIndxKEY := {}
		EndIf
		Do Case
			Case (nOrdem == 1) // CODIGO
				If (aMV_PAR[19] == 1)
					Aadd(aIndxKEY,cUM)
				EndIf
				Aadd(aIndxKEY,"CODITE")
				Aadd(aIndxKEY,"FILIAL")
				Aadd(aIndxKEY,"LOCAL")
			Case (nOrdem == 2)
				Aadd(aIndxKEY,"TIPO")
				If (aMV_PAR[19] == 1)
					Aadd(aIndxKEY,cUM)
				EndIf
				Aadd(aIndxKEY,"CODITE")
				Aadd(aIndxKEY,"FILIAL")
				Aadd(aIndxKEY,"LOCAL")
			Case (nOrdem == 3)
				If (aMV_PAR[19] == 1)
					Aadd(aIndxKEY,cUM)
				EndIf
				Aadd(aIndxKEY,"DESCRI")
				Aadd(aIndxKEY,"CODITE")
				Aadd(aIndxKEY,"FILIAL")
				Aadd(aIndxKEY,"LOCAL")
			Case (nOrdem == 4)
				Aadd(aIndxKEY,"GRUPO")
				If (aMV_PAR[19] == 1)
					Aadd(aIndxKEY,cUM)
				EndIf
				Aadd(aIndxKEY,"CODITE")
				Aadd(aIndxKEY,"FILIAL")
				Aadd(aIndxKEY,"LOCAL")
			Case (nOrdem == 5)
				If (aMV_PAR[19] == 1)
					Aadd(aIndxKEY,cUM)
				EndIf
				Aadd(aIndxKEY,"CODITE")
				Aadd(aIndxKEY,"FILIAL")
			OtherWise
				If (aMV_PAR[19] == 1)
					Aadd(aIndxKEY,cUM)
				EndIf
				Aadd(aIndxKEY,"CODITE")
				Aadd(aIndxKEY,"LOCAL")
		EndCase
	EndIf
EndIf

If Select(cAliasTRB) >0
	If oTempTable:lCreated
		oTempTable:delete()
	EndIf
EndIf

oTempTable := FWTemporaryTable():New( cAliasTRB )
oTempTable:SetFields( aCampos )
oTempTable:AddIndex("01", aIndxKEY )
oTempTable:Create()

Return .T.


/*/
{Protheus.doc} SchedDef
	Funcao Responsavel por definir informacoes para Execu??o do Relatorio via Schedule
	@type  Static Function
	@author Paulo V. Beraldo
	@since Fev/2020
	@version 1.00
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/


Static Function SchedDef()
Local cPerg	 := DefineSX1()[ 1 ]
Local aParam := Nil
local aOrdem := {OemToAnsi(STR0005),OemToAnsi(STR0006),OemToAnsi(STR0007),OemToAnsi(STR0008),OemToAnsi(STR0009)} 
               //" Por Codigo         "###" Por Tipo           "###" Por Descricao     "###" Por Grupo        "###" Por Almoxarifado   "

aParam := { "R", cPerg , "SB2" , aOrdem, OemToAnsi(STR0001) }    

Return aParam
