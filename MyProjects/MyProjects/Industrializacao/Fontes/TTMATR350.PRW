#INCLUDE "MATR350.CH"
#INCLUDE "PRTOPDEF.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR350  ³ Autor ³ Marcos V. Ferreira    ³ Data ³ 13/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Lista de Faltas                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR350                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function TTMATR350()
Local oReport

If TRepInUse()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:= ReportDef()
	oReport:PrintDialog()
Else
	MATR350R3()
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Marcos V. Ferreira     ³ Data ³13/06/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR350			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

Local aOrdem    := {STR0018,STR0019} // "Por Produto          "###"Por Ordem de Producao"
Local cPictQt   := PesqPict("SB2","B2_QATU")
Local nTamQt    := TamSX3('B2_QATU')[1]
Local cAliasTRB := GetNextAlias()
Local oCabec
Local oFaltas        

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:=TReport():New("MATR350",STR0001,"MTR350", {|oReport| ReportPrint(oReport,aOrdem,cAliasTRB)},STR0002+" "+STR0003+" "+STR0004)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                          ³
//³ mv_par01     // Produto inicial                               ³
//³ mv_par02     // Produto final                                 ³
//³ mv_par03     // Considera saldo entradas em aberto            ³
//³ mv_par04     // Lista somente registros com saldo neg         ³
//³ mv_par05     // Almoxarifado de (para formacao do saldo Ini)  ³
//³ mv_par06     // Almoxarifado Ate(para formacao do saldo Ini)  ³
//³ mv_par07     // Considera OPs 1- Firmes 2- Previstas 3- Ambas ³
//³ mv_par08     // Apenas SCs com data limite de compra em atraso³
//³ mv_par09     // Da Ordem de Producao                          ³
//³ mv_par10     // Ate a Ordem de Producao                       ³
//³ mv_par11     // Listar as OPs 1.Atendidas/N Atendidas/Ambas   ³
//³ mv_par12     // Qtd. Nossa Poder 3o.  1-Ignora / 2-Soma       ³
//³ mv_par13     // Qtd. 3o. Nosso Poder  1-Ignora / 2-Subtrai    ³
//³ mv_par14     // Utiliza Data                                  ³
//³ mv_par15     // Data de referencia                            ³
//³ mv_par16     // Data de Entrega de                            ³
//³ mv_par17     // Data de Entrega até                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(oReport:uParam,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oCabec := TRSection():New(oReport,STR0038,{'SB1'},aOrdem) //"Lista de Faltas"##"Produtos"
oCabec:SetTotalInLine(.F.)

TRCell():New(oCabec,'B1_COD'		,'SB1',STR0013,/*Picture*/	,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oCabec,'B1_DESC'		,'SB1',STR0014,/*Picture*/	,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oCabec,'B1_TIPO'		,'SB1',STR0015,/*Picture*/	,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oCabec,'B1_GRUPO'		,'SB1',STR0016,/*Picture*/	,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oCabec,'SALDO'			,'   ',STR0017,cPictQt		,nTamQt		,/*lPixel*/,/*{|| code-block de impressao }*/)

oFaltas := TRSection():New(oCabec,STR0039,{'SD4','SB1',cAliasTRB},aOrdem) //"Empenhos"
oFaltas:SetTotalInLine(.F.)

TRCell():New(oFaltas,'TIPO'			,cAliasTRB	,STR0022	 			,/*Picture*/,01				,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oFaltas,'TIPODOC'		,cAliasTRB	,STR0023+CRLF+STR0024	,/*Picture*/,02				,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oFaltas,'DOCUMENTO'	,cAliasTRB	,STR0025				,/*Picture*/,12				,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oFaltas,'EMISSAO'		,cAliasTRB	,STR0026+CRLF+STR0027	,/*Picture*/,10				,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oFaltas,'DTEVENTO'		,cAliasTRB	,STR0028+CRLF+STR0029	,/*Picture*/,10				,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oFaltas,'B1_COD'		,'SB1'		,STR0030		   		,/*Picture*/,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oFaltas,'B1_DESC'		,'SB1'		,STR0031				,/*Picture*/,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oFaltas,'B1_TIPO'		,'SB1'		,STR0032				,/*Picture*/,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oFaltas,'B1_GRUPO'		,'SB1'		,STR0033				,/*Picture*/,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oFaltas,'QUANTIDADE'	,cAliasTRB	,STR0034				,cPictQt	,nTamQt			,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oFaltas,'SALDO'		,cAliasTRB	,STR0035				,cPictQt	,nTamQt			,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oFaltas,'DTCOMPRA'		,cAliasTRB	,STR0036+CRLF+STR0037	,/*Picture*/,10				,/*lPixel*/,/*{|| code-block de impressao }*/)

oFaltas:SetHeaderPage()

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint ³ Autor ³Marcos V. Ferreira   ³ Data ³13/06/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportPrint devera ser criada para todos  ³±±
±±³          ³os relatorios que poderao ser agendados pelo usuario.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatorio                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR350			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport,aOrdem,cAliasTRB)
Local oCabec    := oReport:Section(1)
Local oFaltas   := oReport:Section(1):Section(1)
Local nOrdem    := oCabec:GetOrder()
Local aCampos	:= {}
Local aTrab		:= {}
Local cTrtAnt	:= ""
Local cOpAnt	:= ""
Local aKey		:= {}
Local cOP		:= ""
Local nSeek		:= 0
Local nRecno	:= 0
Local nAcho		:= 0
Local dDataD4, dData
Local oTempTable := NIL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Titulo do relatorio                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:SetTitle(oReport:Title()+IIf(nOrdem == 1," - ("+AllTrim(STR0018)+")"," - ("+AllTrim(STR0019)+")"))

oTempTable := CreateTMP(cAliasTRB, nOrdem)

dbSelectArea("SD4")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transforma parametros Range em expressao SQL                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeAdvplExpr(oReport:uParam)

oReport:SetMsgPrint(STR0010) //"Selecionando Registros..."
T350PROC(cAliasTRB,oReport)

oReport:SetMsgPrint(STR0040) //"Imprimindo..."
If nOrdem == 1 
	A350Prod(oReport,oCabec,oFaltas,cAliasTRB)	//-- Por Produto
ElseIf nOrdem == 2 
	A350Op(oReport,oCabec,oFaltas,cAliasTRB)	//-- Por Ordem de Producao
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta arquivo de Trabalho                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTempTable:Delete()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³A350Prod  ³ Autor ³ Marcos V. Ferreira    ³ Data ³ 13.06.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR350			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A350Prod(oReport,oCabec,oFaltas,cAliasTRB)
Local lPassou  := .T.
Local lImprime := .T.
Local cCodAnt  := ""
Local nSaldoIni:= ""
Local nSaldo   := 0
Local nQemp    := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega codeblock dos campos utilizados no relatorios        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oCabec:Cell('SALDO'):SetBlock({|| nSaldoIni})

oFaltas:Cell('SALDO'):SetBlock({|| nSaldo})
oFaltas:Cell('DTCOMPRA'):SetBlock({|| SomaPrazo(DTEVENTO, - CalcPrazo(PRODUTO, nSaldo))})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posicionamento de tabelas auxiliares                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRPosition():New(oCabec,"SB1",1,{|| xFilial("SB1")+(cAliasTRB)->PRODUTO})
TRPosition():New(oFaltas,"SC2",1,{|| xFilial("SC2")+(cAliasTRB)->DOCUMENTO})
TRPosition():New(oFaltas,"SB1",1,{|| xFilial("SB1")+SC2->C2_PRODUTO})

dbSelectArea(cAliasTRB)
dbSetOrder(1)
dbGoTop()
oReport:SetMeter(LastRec())

oFaltas:Init(.F.)

While !oReport:Cancel() .And. !Eof()
	
	cCodAnt := (cAliasTRB)->PRODUTO
	
	dbSelectArea("SB2")
	dbSetOrder(1)
	MsSeek(xFilial("SB2")+cCodAnt)
	nSaldo := 0
	nQemp  := 0
	While !Eof() .And. B2_FILIAL+B2_COD == xFilial("SB2")+cCodAnt
		If SB2->B2_LOCAL >= mv_par05 .And. SB2->B2_LOCAL <= mv_par06
			nSaldo += SaldoSB2(.F.,.F.,dDataBase,mv_par13==2,mv_par12==1)
			nQemp  += If(mv_par07==1,B2_QEMP,If(mv_par07==2,B2_QEMPPRE,B2_QEMP+B2_QEMPPRE))
		EndIf
		dbSkip()
	EndDo

	nSaldoIni := nSaldo
	
	oFaltas:Init()
	lImprime := .T.
	lPassou  := .F.
	dbSelectArea(cAliasTRB)
	While !Eof() .And. PRODUTO == cCodAnt
		
		oReport:IncMeter()

		If TIPO == "E"
			nSaldo += QUANTIDADE
		Else
			nSaldo -= QUANTIDADE
		EndIf
		
		If (mv_par04 == 1 .And. nSaldoIni < nQemp) .Or. ((mv_par04 == 1 .And. nSaldo < 0) .Or. mv_par04 == 2)
			
			If lImprime
				oReport:SkipLine()
				oCabec:Init()
				oCabec:PrintLine()
				lImprime := .F.
			EndIf

			If !Empty(SubStr(DOCUMENTO,7,5)) .And. TIPODOC != "OP"
				oFaltas:Cell("B1_COD"	):Show()	//"Produto"
				oFaltas:Cell("B1_DESC"	):Show()	//"Descricao"
				oFaltas:Cell("B1_TIPO"	):Show()	//"Tipo"
				oFaltas:Cell("B1_GRUPO"	):Show()	//"Grupo"
			Else
				oFaltas:Cell("B1_COD"	):Hide()
				oFaltas:Cell("B1_DESC"	):Hide()
				oFaltas:Cell("B1_TIPO"	):Hide()
				oFaltas:Cell("B1_GRUPO"	):Hide()
			EndIf

			oFaltas:PrintLine()
			lPassou := .T.
		EndIf
		dbSelectArea(cAliasTRB)
		dbSkip()
	EndDo
	oFaltas:Finish()
	oCabec:Finish()
	
	If lPassou
		oReport:ThinLine() //-- Impressao de Linha Simples
	EndIf
	
EndDo

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A350Op    ³ Autor ³ Marcos V. Ferreira    ³ Data ³ 13.06.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR350			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A350Op(oReport,oCabec,oFaltas,cAliasTRB)
Local aAreaAnt := {}
Local aSaldo   := {}
Local aSalIni  := {}
Local cNumOP   := ""
Local lPassou  := .T.
Local lImprime := .T.
Local lSoma    := .T.
Local nSaldoIni:= 0
Local nSldIni  := 0
Local nSaldo   := 0
Local nPos     := 0
Local nReg     := 0
Local lProd    := .T.
Local lContinua:= .F.
Local aCabOP   := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posicionamento de tabelas auxiliares                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRPosition():New(oFaltas,"SC2",1,{|| xFilial("SC2")+(cAliasTRB)->DOCUMENTO})
TRPosition():New(oFaltas,"SB1",1,{|| xFilial("SB1")+SC2->C2_PRODUTO})
TRPosition():New(oCabec ,"SB1",1,{|| xFilial("SB1")+aCabOP[1][2]})

dbSelectArea("SD4")
dbSetOrder(1)

dbSelectArea(cAliasTRB)
dbSetOrder(1)
dbGoTop()
oReport:SetMeter(LastRec())
oReport:IncMeter(0)

oFaltas:Init(.F.)

While !oReport:Cancel() .And. !Eof()
	
	oReport:IncMeter()
	cNumOP   := OP
	nReg     := Recno()
	lImprime := .T.
	lPassou  := .F.
	lSoma    := .T.
	nSaldo   := 0
	lProd    := .T.
	
	While !oReport:Cancel() .And. !Eof() .And. OP == cNumOP
		
		If lProd
			cProduto:= (cAliasTRB)->PRODUTO
			nReg 	:= (cAliasTRB)->(Recno())
			If mv_par11 < 3
				nPos := aScan(aSalIni,{|x| x[1] == (cAliasTRB)->PRODUTO})
				If nPos == 0
					cProduto := (cAliasTRB)->PRODUTO
					SB2->(MsSeek(xFilial("SB2")+cProduto))
					While !oReport:Cancel() .And. !SB2->(Eof()) .And. SB2->B2_FILIAL+SB2->B2_COD == xFilial("SB2")+cProduto
						If SB2->B2_LOCAL >= mv_par05 .And. SB2->B2_LOCAL <= mv_par06
							nSaldo += SaldoSB2(.F.,.F.,dDataBase,mv_par13==2,mv_par12==1)
						EndIf
						SB2->(dbSkip())
					EndDo
				Else
					nSaldo := aSalIni[nPos,2]
				EndIf
				While !oReport:Cancel() .And. !Eof() .And. cProduto == (cAliasTRB)->PRODUTO
					If TIPO == "E"
						nSaldo += QUANTIDADE
					Else
						nSaldo -= QUANTIDADE
					EndIf
					nPos := aScan(aSalIni,{|x| x[1] == (cAliasTRB)->PRODUTO})
					If nPos == 0
						aAdd(aSalIni,{(cAliasTRB)->PRODUTO,nSaldo})
					Else
						aSalIni[nPos,2]:=nSaldo
					Endif
					dbSkip()
				EndDo
				If (mv_par11 == 1 .And. nSaldo >= 0) .Or. (mv_par11 == 2 .And. nSaldo < 0)
					dbGoTo(nReg)
					lProd  := .F.
					lSoma  := .T.
					nSaldo := 0
				Else
					Loop
				EndIf
			EndIf
		EndIf
		
		If QUANTIDADE == 0
			dbSkip()
			Loop
		EndIf
		
		If !lSoma
			nSaldo := 0
		EndIf
		
		If lImprime
			If !Empty(SubStr(OP,7,5)) .And. TIPODOC != "OP"
				dbSelectArea("SC2")
				dbSetOrder(1)
				MsSeek(xFilial("SC2")+cNUMOP)
				dbSelectArea("SB1")
				dbSetOrder(1)
				MsSeek(xFilial("SB1")+SC2->C2_PRODUTO)
				dbSelectArea(cAliasTRB)
			EndIf

			nPos := aScan(aSaldo,{|x| x[1] == SB1->B1_COD})

			If nPos == 0
				aAreaAnt := SB2->(GetArea())
				SB2->(MsSeek(xFilial("SB2")+SB1->B1_COD))
				While !oReport:Cancel() .And. !SB2->(Eof()) .And. SB2->B2_FILIAL+SB2->B2_COD == xFilial("SB2")+SB1->B1_COD
					If SB2->B2_LOCAL >= mv_par05 .And. SB2->B2_LOCAL <= mv_par06
						nSaldoIni := SaldoSB2(.F.,.F.,dDataBase,mv_par13==2,mv_par12==1)
					EndIf
					SB2->(dbSkip())
				EndDo
				RestArea(aAreaAnt)
				dbSelectArea(cAliasTRB)
				aAdd(aSaldo,{SB1->B1_COD,nSaldoIni})
				nPos := Len(aSaldo)
			Else
				aSaldo[nPos,2] += nSaldoIni
				nSaldo := nSaldoIni
			EndIf
			aCabOP := {}
			aAdd(aCabOP,{STR0021+cNUMOP,SB1->B1_COD,STR0014+SB1->B1_DESC,STR0015+SB1->B1_TIPO,STR0016+SB1->B1_GRUPO,STR0017,aSaldo[nPos,2]})
		EndIf

		SB1->(MsSeek(xFilial("SB1")+(cAliasTRB)->PRODUTO))
		nPos := aScan(aSalIni,{|x| x[1] == (cAliasTRB)->PRODUTO})

		If nPos == 0
			dbSelectArea("SB2")
			dbSetOrder(1)
			MsSeek(xFilial("SB2")+(cAliasTRB)->PRODUTO)
			nSldIni := 0
			While !oReport:Cancel() .And. !Eof() .And. B2_FILIAL+B2_COD == xFilial("SB2")+(cAliasTRB)->PRODUTO
				If SB2->B2_LOCAL >= mv_par05 .And. SB2->B2_LOCAL <= mv_par06
					nSldIni += SaldoSB2(.F.,.F.,dDataBase,mv_par13==2,mv_par12==1)
				EndIf
				dbSkip()
			EndDo
			dbSelectArea(cAliasTRB)
			aAdd(aSalIni,{(cAliasTRB)->PRODUTO,nSldIni})
			nPos		:= Len(aSalIni)
			nSaldo		+= nSldIni
			lContinua	:= .T.
		Else
			nSaldo		:= aSalIni[nPos,2]
			lContinua	:= .F.
		EndIf

		If mv_par11 == 3
			If TIPO == "E"
				nSaldo += QUANTIDADE
			Else
				nSaldo -= QUANTIDADE
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao do cabecalho da O.P.                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lImprime .And. ((mv_par04 == 1 .And. nSaldo < 0) .Or. mv_par04 == 2)
			oCabec:Init()
			oReport:PrintText(aCabOP[1][1])	//"OP : "
			oCabec:Cell("B1_COD"	):Show() 	//"Produto : "
			oCabec:Cell("B1_DESC"	):Show()	//"Descricao : "
			oCabec:Cell("B1_TIPO"	):Show()	//"Tipo : "
			oCabec:Cell("B1_GRUPO"	):Show()	//"Grupo : "
			oCabec:Cell('SALDO'	 	):SetValue(aCabOP[1][7]) //"Saldo : "
            oCabec:PrintLine()
			oCabec:Finish()
			lImprime := .F.
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao do Saldo Atual do Produto                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lContinua .And. ((mv_par04 == 1 .And. nSaldo < 0) .Or. mv_par04 == 2)
			oFaltas:Cell("TIPO"			):SetValue("E")		//"Tipo"
			oFaltas:Cell("TIPODOC"		):SetValue("")		//"Tipo do Documento"
			oFaltas:Cell("DOCUMENTO"	):SetValue(STR0017)	//"Saldo Atual"
			oFaltas:Cell("EMISSAO" 		):SetValue("")		//"Emissao"	
			oFaltas:Cell("DTEVENTO"		):SetValue("")		//"Data do Evento"			
			oFaltas:Cell("B1_DESC"		):Hide()           //"Descricao"
			oFaltas:Cell("B1_TIPO"		):Hide()           //"Tipo"
			oFaltas:Cell("B1_GRUPO"		):Hide()           //"Grupo"
			oFaltas:Cell('QUANTIDADE'	):SetValue(0)      //"Quantidade"
			oFaltas:Cell('SALDO'	 	):SetValue(nSldIni)//"Saldo"
			oFaltas:Cell('DTCOMPRA'	 	):SetValue("")     //"Data da Compra"
			oFaltas:PrintLine()
			lContinua := .F.
		EndIf
		
		If (mv_par04 == 1 .And. nSaldo < 0) .Or. mv_par04 == 2
			oFaltas:Cell("TIPO"			):SetValue(TIPO)		//"Tipo"
			oFaltas:Cell("TIPODOC"		):SetValue(TIPODOC)		//"Tipo do Documento"
			oFaltas:Cell("DOCUMENTO"	):SetValue(DOCUMENTO)	//"Documento"
			oFaltas:Cell("EMISSAO" 		):SetValue(EMISSAO)		//"Emissao"	
			oFaltas:Cell("DTEVENTO"		):SetValue(DTEVENTO)	//"Data do Evento"			
			oFaltas:Cell("B1_COD"		):Show()				//"Produto"
			oFaltas:Cell("B1_DESC"		):Show()				//"Desricao"
			oFaltas:Cell("B1_TIPO"		):Show()				//"Tipo"
			oFaltas:Cell("B1_GRUPO"		):Show()				//"Grupo"
			oFaltas:Cell('QUANTIDADE'	):SetValue(QUANTIDADE)	//"Quantidade"
			oFaltas:Cell('SALDO'		):SetValue(nSaldo)		//"Saldo"
			oFaltas:Cell('DTCOMPRA'	 	):SetValue(SomaPrazo(DTEVENTO, - CalcPrazo(PRODUTO, nSaldo)))
			oFaltas:PrintLine()
			lPassou := .T.
		EndIf

		dbSkip()

		lSoma := If((cAliasTRB)->PRODUTO==SB1->B1_COD,.T.,.F.)
		aSalIni[nPos,2] := nSaldo
		lProd := !lSoma

	EndDo

	If lPassou
		oReport:ThinLine() //-- Impressao de Linha Simples
		oReport:SkipLine() //-- Salta Linha
	EndIf
	
EndDo

oFaltas:Finish()

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR350  ³ Autor ³ Eveli Morasco         ³ Data ³ 17/03/93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Lista de Faltas                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³FernandoJoly³10/11/98³XXXXXX³Ajuste para o ano 2000.                   ³±±
±±³Rodrigo Sart³07/02/99³META  ³ Filtragem por Tipo de OP.                ³±±
±±³Cesar       ³30/03/99³XXXXXX³Manutencao na SetPrint()                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Descri‡…o ³ PLANO DE MELHORIA CONTINUA                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ITEM PMC  ³ Responsavel              ³ Data                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³      01  ³Marcos V. Ferreira        ³07/02/2006                       ³±±
±±³      02  ³Erike Yuri da Silva       ³15/12/2005                       ³±±
±±³      03  ³                          ³                                 ³±±
±±³      04  ³Flavio Luiz Vicco         ³10/01/2006                       ³±±
±±³      05  ³Marcos V. Ferreira        ³07/02/2006                       ³±±
±±³      06  ³                          ³                                 ³±±
±±³      07  ³Flavio Luiz Vicco         ³10/01/2006                       ³±±
±±³      08  ³                          ³                                 ³±±
±±³      09  ³                          ³                                 ³±±
±±³      10  ³Erike Yuri da Silva       ³ 15/12/2005                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
user Function MATR350R3()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL Tamanho  := "M"
LOCAL titulo   := STR0001	//"Lista de Faltas"
LOCAL cDesc1   := STR0002	//"O relatorio fara' a alocacao do material em  estoque `as OP's"
LOCAL cDesc2   := STR0003	//"em ordem sequencial ,deixando que as faltas sejam localizadas"
LOCAL cDesc3   := STR0004	//"nas ultimas OP's."
LOCAL cString  := "SD4"
LOCAL wnrel    := "MATR350"
LOCAL aOrd     := {OemToAnsi(STR0018),OemToAnsi(STR0019)} // "Por Produto          "###"Por Ordem de Producao"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis tipo Private padrao de todos os relatorios         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aReturn  := {OemToAnsi(STR0005), 1,OemToAnsi(STR0006), 2, 2, 1, "",1 }	//"Zebrado"###"Administracao"
PRIVATE nLastKey := 0 ,cPerg := "MTR350"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                          ³
//³ mv_par01     // Produto inicial                               ³
//³ mv_par02     // Produto final                                 ³
//³ mv_par03     // Considera saldo entradas em aberto            ³
//³ mv_par04     // Lista somente registros com saldo neg         ³
//³ mv_par05     // Almoxarifado de (para formacao do saldo Ini)  ³
//³ mv_par06     // Almoxarifado Ate(para formacao do saldo Ini)  ³
//³ mv_par07     // Considera OPs 1- Firmes 2- Previstas 3- Ambas ³
//³ mv_par08     // Apenas SCs com data limite de compra em atraso³
//³ mv_par09     // Da Ordem de Producao                          ³
//³ mv_par10     // Ate a Ordem de Producao                       ³
//³ mv_par11     // Listar as OPs 1.Atendidas/N Atendidas/Ambas   ³
//³ mv_par12     // Qtd. Nossa Poder 3o.  1-Ignora / 2-Soma       ³
//³ mv_par13     // Qtd. 3o. Nosso Poder  1-Ignora / 2-Subtrai    ³
//³ mv_par14     // Utiliza Data                                  ³
//³ mv_par15     // Data de referencia                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclui pergunta no SX1                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("MTR350",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)

If nLastKey = 27
	dbClearFilter()
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	dbClearFilter()
	Return
Endif

RptStatus({|lEnd| C350Imp(@lEnd,wnRel,cString,titulo,Tamanho)},titulo)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C350IMP  ³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 13.12.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR350			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C350Imp(lEnd,WnRel,cString,titulo,Tamanho)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis locais exclusivas deste programa                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL dData, aCampos := {}, aTrab := {}, cTrtAnt:="", cOpAnt := ""
LOCAL nSeek, aKey, lContinua := .T., cOP := "" , nRecno
LOCAL nAcho:=0
LOCAL dDataD4
LOCAL oTempTable := NIL
Local cAliasTRB	:= GetNextAlias()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Contadores de linha e pagina                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE li := 80 ,m_pag := 1
PRIVATE cRodaTxt := STR0007	//"REGISTRO(S)"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis privadas exclusivas deste programa                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cArqTrb

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa os codigos de caracter Comprimido/Normal da impressora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTipo  := IIF(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os Cabecalhos                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cabec1 := STR0008		//"E/S TIP DOCUMENTO     DATA       DATA DO    CODIGO          DESCRICAO DO PRODUTO      TP GRUP     QUANTIDADE          SALDO  DATA DA"
cabec2 := STR0009		//"    DOC               EMISSAO    EVENTO                                                                                       COMPRA"
						//  1  12  1234567890123 99/99/9999 99/99/9999 123456789012345 1234567890123456789012345 12 1234 999,999,999.99 999,999,999.99 99/99/9999
						// 0         1         2         3         4         5         6         7         8         9        10        11        12        13        14
						// 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
						// Componente : 123456789012345 Descricao : 123456789012345678901234567890 Tipo : 12 Grupo : 1234 Saldo Atual: 999,999,999.99

dbSelectArea("SD4")
SetRegua(LastRec())

oTempTable := CreateTMP(cAliasTRB,aReturn[8])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava as entradas e saidas previstas no arquivo de trabalho  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SD4")
If aReturn[8] == 1
	dbSetOrder(3)
	dbSeek(xFilial("SD4")+mv_par01,.T.)
ElseIf aReturn[8] == 2
	dbSetOrder(2)
	dbSeek(xFilial("SD4")+mv_par09,.T.)
EndIf

T350PROC(cAliasTRB,,@lEnd)

dbSelectArea(cAliasTRB)
dbSetOrder(1)
dbGoTop()

If lContinua
	If aReturn[8] == 1
		R350Prod(lEnd,wnrel,Tamanho,Titulo+" - ("+AllTrim(STR0018)+")",cAliasTRB)
	ElseIf aReturn[8] == 2
		R350OP(lEnd,wnrel,Tamanho,Titulo+" - ("+AllTrim(STR0019)+")",cAliasTRB)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta arquivo de Trabalho                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTempTable:Delete()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve a condicao original do arquivo principal             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cString)
dbClearFilter()
dbSetOrder(1)

If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R350PROD ³ Autor ³ Larson Zordan         ³ Data ³ 25.09.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR350			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function R350Prod(lEnd,wnrel,Tamanho,Titulo,cAliasTrb)
Local cCodAnt  := ""
Local cDesc    := ""
Local cTipo    := ""
Local cGrup    := ""
Local nSaldoIni:= ""
Local nCntImpr := 0
Local nSaldo   := 0
Local nQemp    := 0
Local lPassou  := .T.
Local lImprime := .T.
Local cProd    := ""

While !Eof()
	
	If lEnd
		@ PROW()+1,001 PSay STR0011		//"CANCELADO PELO OPERADOR"
		Exit
	EndIf
	
	cCodAnt := PRODUTO
	
	dbSelectArea("SB1")
	dbSeek(xFilial("SB1")+cCodAnt)
	cDesc := SubStr(B1_DESC,1,30)
	cTipo := B1_TIPO
	cGrup := B1_GRUPO
	
	dbSelectArea("SB2")
	dbSeek(xFilial("SB2")+cCodAnt)
	nSaldo := 0
	nQemp  := 0
	While !EOF() .And. B2_FILIAL+B2_COD == xFilial("SB2")+cCodAnt
		If SB2->B2_LOCAL >= mv_par05 .And. SB2->B2_LOCAL <= mv_par06
			
			nSaldo += SaldoSB2(.F.,.F.,dDataBase,mv_par13==2,mv_par12==1)
			
			nQemp  += If(mv_par07==1,B2_QEMP,If(mv_par07==2,B2_QEMPPRE,B2_QEMP+B2_QEMPPRE))
		Endif
		Skip
	EndDo
	nSaldoIni := nSaldo
	
	dbSelectArea(cAliasTRB)
	lImprime := .T.
	lPassou  := .F.
	While !Eof() .And. PRODUTO == cCodAnt
		
		If TIPO == "E"
			nSaldo += QUANTIDADE
		Else
			nSaldo -= QUANTIDADE
		EndIf
		
		If (mv_par04 == 1 .And. nSaldoIni < nQemp) .Or. ((mv_par04 == 1 .And. nSaldo < 0) .Or. mv_par04 == 2)
			If li > 60
				Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
				lImprime := .T.
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Adiciona 1 ao contador de registros impressos         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nCntImpr++
			
			If lImprime
				@ li,000 PSay STR0013+cCodAnt	//"Componente : "
				@ li,029 PSay STR0014+cDesc		//"Descricao : "
				@ li,072 PSay STR0015+cTipo		//"Tipo : "
				@ li,082 PSay STR0016+cGrup		//"Grupo : "
				@ li,095 PSay STR0017			//"Saldo Atual:"
				@ li,112 PSay nSaldoIni Picture PesqPict("SB2","B2_QATU",14)
				lImprime := .F.
				li += 2
			EndIf
			
			If !Empty(SubStr(DOCUMENTO,7,5)) .And. TIPODOC != "OP"
				dbSelectArea("SC2")
				dbSeek(xFilial("SC2")+(cAliasTRB)->DOCUMENTO)
				dbSelectArea("SB1")
				dbSeek(xFilial("SB1")+SC2->C2_PRODUTO)
				dbSelectArea(cAliasTRB)
			EndIf
			
			cProd := SB1->B1_COD
			
			@ li,000 PSay TIPO
			@ li,004 PSay TIPODOC
			@ li,008 PSay DOCUMENTO
			@ li,022 PSay EMISSAO
			@ li,033 PSay DTEVENTO
			If !Empty(SubStr(DOCUMENTO,7,5)) .And. TIPODOC != "OP"
				@ li,044 PSay SB1->B1_COD
				@ li,060 PSay SubStr(SB1->B1_DESC,1,25)
				@ li,086 PSay SB1->B1_TIPO
				@ li,089 PSay SB1->B1_GRUPO
			EndIf
			@ li,094 PSay QUANTIDADE   Picture PesqPict("SB2","B2_QATU",14)
			@ li,109 PSay nSaldo       Picture PesqPict("SB2","B2_QATU",14)
			@ li,124 PSay SomaPrazo(DTEVENTO, - CalcPrazo(PRODUTO, nSaldo))
			lPassou := .T.
			li++
		EndIf
		dbSkip()
	EndDO
	If lPassou
		@ li,000 PSay __PrtThinLine()
		li++
	EndIf
	
EndDo
If li != 80
	Roda(nCntImpr,cRodaTxt,Tamanho)
EndIf
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R350OP   ³ Autor ³ Larson Zordan         ³ Data ³ 25.09.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR350			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function R350OP(lEnd,wnrel,Tamanho,Titulo,cAliasTRB)
Local aAreaAnt := {}
Local aSaldo   := {}
Local aSalIni  := {}
Local cNumOP   := ""
Local cDesc    := ""
Local cTipo    := ""
Local cGrup    := ""
Local lPassou  := .T.
Local lImprime := .T.
Local lSoma    := .T.
Local nSaldoIni:= 0
Local nSldIni  := 0
Local nCntImpr := 0
Local nSaldo   := 0
Local nQemp    := 0
Local nPos     := 0
Local nReg     := 0
Local lProd    := .T.
Local lContinua:= .F.
Local aCabOP   := {}

SD4->(dbSetOrder(1))

While !Eof()
	
	If lEnd
		@ PROW()+1,001 PSay STR0011		//"CANCELADO PELO OPERADOR"
		Exit
	EndIf
	
	cNumOP   := OP
	nReg     := Recno()
	lImprime := .T.
	lPassou  := .F.
	lSoma    := .T.
	nSaldo   := 0
	lProd    := .T.
	
	While !Eof() .And. OP == cNumOP
		
		If lProd
			cProduto := (cAliasTRB)->PRODUTO
			nReg := (cAliasTRB)->(Recno())
			
			If mv_par11 < 3
				nPos := aScan(aSalIni,{|x| x[1] == (cAliasTRB)->PRODUTO})
				If nPos == 0
					cProduto := (cAliasTRB)->PRODUTO
					SB2->(dbSeek(xFilial("SB2")+cProduto))
					While !SB2->(Eof()) .And. SB2->B2_FILIAL+SB2->B2_COD == xFilial("SB2")+cProduto
						If SB2->B2_LOCAL >= mv_par05 .And. SB2->B2_LOCAL <= mv_par06
							
							nSaldo += SaldoSB2(.F.,.F.,dDataBase,mv_par13==2,mv_par12==1)
							
						Endif
						SB2->(dbSkip())
					EndDo
				Else
					nSaldo := aSalIni[nPos,2]
				EndIf
				While !Eof() .And. cProduto == (cAliasTRB)->PRODUTO
					If TIPO == "E"
						nSaldo += QUANTIDADE
					Else
						nSaldo -= QUANTIDADE
					EndIf
					nPos := aScan(aSalIni,{|x| x[1] == (cAliasTRB)->PRODUTO})
					If nPos == 0
						aAdd(aSalIni,{(cAliasTRB)->PRODUTO,nSaldo})
					Else
						aSalIni[nPos,2]:=nSaldo
					Endif
					dbSkip()
				EndDo
				If (mv_par11 == 1 .And. nSaldo >= 0) .Or. (mv_par11 == 2 .And. nSaldo < 0)
					dbGoTo(nReg)
					lProd  := .F.
					lSoma  := .T.
					nSaldo := 0
				Else
					Loop
				EndIf
			EndIf
		EndIf
		
		If QUANTIDADE == 0
			dbSkip()
			Loop
		EndIf
		
		If !lSoma
			nSaldo := 0
		EndIf
		
		If li > 60
			Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
			lImprime := .T.
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Adiciona 1 ao contador de registros impressos         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nCntImpr++
		
		If lImprime
			If !Empty(SubStr(OP,7,5)) .And. TIPODOC != "OP"
				dbSelectArea("SC2")
				dbSeek(xFilial("SC2")+cNUMOP)
				dbSelectArea("SB1")
				dbSeek(xFilial("SB1")+SC2->C2_PRODUTO)
				dbSelectArea(cAliasTRB)
			EndIf
			nPos := aScan(aSaldo,{|x| x[1] == SB1->B1_COD})
			If nPos == 0
				aAreaAnt := SB2->(GetArea())
				SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD))
				While !SB2->(Eof()) .And. SB2->B2_FILIAL+SB2->B2_COD == xFilial("SB2")+SB1->B1_COD
					If SB2->B2_LOCAL >= mv_par05 .And. SB2->B2_LOCAL <= mv_par06
						
						nSaldoIni := SaldoSB2(.F.,.F.,dDataBase,mv_par13==2,mv_par12==1)
						
					Endif
					SB2->(dbSkip())
				EndDo
				RestArea(aAreaAnt)
				dbSelectArea(cAliasTRB)
				aAdd(aSaldo,{SB1->B1_COD,nSaldoIni})
				nPos := Len(aSaldo)
			Else
				aSaldo[nPos,2] += nSaldoIni
				nSaldo := nSaldoIni
			EndIf
			aCabOP := {}
			aAdd(aCabOP,{STR0021+cNUMOP,STR0020+SB1->B1_COD,STR0014+SB1->B1_DESC,STR0015+SB1->B1_TIPO,STR0016+SB1->B1_GRUPO,STR0017,aSaldo[nPos,2]})
		EndIf
		
		SB1->(dbSeek(xFilial("SB1")+(cAliasTRB)->PRODUTO))
		nPos := aScan(aSalIni,{|x| x[1] == (cAliasTRB)->PRODUTO})
		If nPos == 0
			dbSelectArea("SB2")
			dbSeek(xFilial("SB2")+(cAliasTRB)->PRODUTO)
			nSldIni := 0
			While !EOF() .And. B2_FILIAL+B2_COD == xFilial("SB2")+(cAliasTRB)->PRODUTO
				If SB2->B2_LOCAL >= mv_par05 .And. SB2->B2_LOCAL <= mv_par06
					
					nSldIni += SaldoSB2(.F.,.F.,dDataBase,mv_par13==2,mv_par12==1)
					
				Endif
				Skip
			EndDo
			dbSelectArea(cAliasTRB)
			aAdd(aSalIni,{(cAliasTRB)->PRODUTO,nSldIni})
			nPos		:= Len(aSalIni)
			nSaldo		+= nSldIni
			lContinua	:= .T.
		Else
			nSaldo		:= aSalIni[nPos,2]
			lContinua	:= .F.
		EndIf
		
		If mv_par11 == 3
			If TIPO == "E"
				nSaldo += QUANTIDADE
			Else
				nSaldo -= QUANTIDADE
			EndIf
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao do cabecalho da O.P.                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lImprime .And. ((mv_par04 == 1 .And. nSaldo < 0) .Or. mv_par04 == 2)
			@ li,000 PSay aCabOP[1][1]	   	//"OP : "
			li ++
			@ li,000 PSay aCabOP[1][2]	   	//"Produto : "
			@ li,029 PSay aCabOP[1][3]		//"Descricao : "
			@ li,073 PSay aCabOP[1][4]		//"Tipo : "
			@ li,083 PSay aCabOP[1][5]		//"Grupo : "
			@ li,096 PSay aCabOP[1][6]		//"Saldo Atual:"
			@ li,113 PSay aCabOP[1][7]  Picture PesqPict("SB2","B2_QATU",14)
			lImprime := .F.
			li += 2
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao do Saldo Atual do Produto                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lContinua .And. ((mv_par04 == 1 .And. nSaldo < 0) .Or. mv_par04 == 2)
			@ li,000 PSay "E"
			@ li,004 PSay STR0017  //"Saldo Atual"
			@ li,044 PSay SB1->B1_COD
			@ li,109 PSay nSldIni Picture PesqPict("SB2","B2_QATU",14)
			li ++
			lContinua := .F.
		Endif
		
		If ((mv_par04 == 1 .And. nSaldo < 0) .Or. mv_par04 == 2)
			@ li,000 PSay TIPO
			@ li,004 PSay TIPODOC
			@ li,022 PSay EMISSAO
			@ li,033 PSay DTEVENTO
			If !(!Empty(SubStr(DOCUMENTO,7,5)) .And. TIPODOC != "OP")
				SB1->(dbSeek(xFilial("SB1")+(cAliasTRB)->PRODUTO))
			EndIf
			@ li,044 PSay SB1->B1_COD
			@ li,060 PSay SubStr(SB1->B1_DESC,1,25)
			@ li,086 PSay SB1->B1_TIPO
			@ li,089 PSay SB1->B1_GRUPO
			@ li,094 PSay QUANTIDADE	Picture PesqPict("SB2","B2_QATU",14)
			@ li,109 PSay nSaldo 	 	Picture PesqPict("SB2","B2_QATU",14)
			@ li,124 PSay SomaPrazo(DTEVENTO, - CalcPrazo(PRODUTO, nSaldo))
			lPassou := .T.
			li++
		Endif
		dbSkip()
		lSoma := If((cAliasTRB)->PRODUTO==SB1->B1_COD,.T.,.F.)
		aSalIni[nPos,2] := nSaldo
		lProd := !lSoma
	EndDo
	If lPassou
		@ li,000 PSay __PrtThinLine()
		li++
	EndIf
	
EndDo
If li != 80
	Roda(nCntImpr,cRodaTxt,Tamanho)
EndIf
Return(.T.)


/*/{Protheus.doc} CreateTMP
//TODO Cria a tabela temporaria para o processamento do relatorio, a qual sera lida para impressão
@author reynaldo
@since 21/12/2017
@version 1.0
@return objeto, Retorna o objeto criado pela FWTemporaryTable
@param cAliasTMP, characters, Alias da tabela do relatorio
@param nOrdem, numeric, Ordenação de impressão do relatorio
@type function
/*/
Static Function CreateTMP(cAliasTMP,nOrdem)
Local aTrab
Local aKey
Local oTempTable

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define estrutura e gera o arquivo de trabalho                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTrab := {	{"TIPO"      ,"C",01,0},;
			{"DOCUMENTO" ,"C",TamSX3("D3_OP")[1],0},;
			{"DTEVENTO"  ,"D",08,0},;
			{"PRODUTO"   ,"C",TamSX3("B1_COD")[1],0},;
			{"QUANTIDADE","N",TamSX3('B2_QATU')[1],TamSX3('B2_QATU')[2]},;
			{"EMISSAO"   ,"D",08,0},;
			{"OP"        ,"C",TamSX3("D3_OP")[1],0},;
			{"TIPODOC"   ,"C",02,0},;
			{"CHAVE"     ,"C",TamSX3("D3_OP")[1],0} ; 
		}

If nOrdem == 1
	aKey := {"PRODUTO","DTEVENTO","TIPO"}
ElseIf nOrdem == 2
	aKey := {"OP","DTEVENTO","PRODUTO"}
EndIf

oTempTable := FWTemporaryTable():New( cAliasTMP )
oTempTable:SetFields( aTrab )
oTempTable:AddIndex("01", aKey )
oTempTable:AddIndex("02", {"TIPODOC","CHAVE"} )
oTempTable:Create()

Return oTempTable

/*/{Protheus.doc} T350PROC
//TODO Processa as informações para o relatorio.
@author reynaldo
@since 07/12/2017
@version 1.0
@return ${return}, ${return_description}
@param cAliasTRB, characters, descricao
@type function
/*/
static Function T350PROC(cAliasTRB,oReport,lEnd)
Local lContinua	:= .T.
Local cCodAnt	:= ""
Local cTrtAnt	:= ""
Local cOP		:= ""
Local aCampos	:= {}
Local dData		:= stod("")
Local dDataD4	:= stod("")
Local nAcho		:= 0
Local nRecno	:= 0
Local nSeek		:= 0
Local cWhereTpOP:= ""
Local cAliasSel := GetNextAlias()
Local nBarra	:= 0
Local nTime		:= 0

DEFAULT oReport := NIL
DEFAULT lEnd 	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se deve considerar saldos em aberto das entradas    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par03 == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona nos indices dos arquivos a serem pesquisados       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SC1")
	dbSetOrder(2)

	dbSelectArea("SC2")
	dbSetOrder(2)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Novo Indice para pesquisa do SC7.                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SC7")
	dbSetOrder(1)

	dbSelectArea("SC8")
	dbSetOrder(3)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava as entradas e saidas previstas no arquivo de trabalho  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cWhereTpOP := "%"+QryAvalOP(mv_par07, "SC2")+"%"

nTime := Seconds()

BeginSQL Alias cAliasSel

	COLUMN D4_DATA as Date

	SELECT 
		SD4.D4_COD, MIN(SD4.D4_DATA) DATAMIN, MAX(SD4.D4_DATA) DATAMAX
	FROM 
		%Table:SD4% SD4
	INNER JOIN 
		%Table:SC2% SC2
		ON SC2.C2_FILIAL = %xFilial:SC2% AND SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN = SD4.D4_OP AND SC2.%Exp:cWhereTpOP% AND SC2.%NotDel%
	
	INNER JOIN 
		%Table:SC6% SC6
		ON SC6.C6_FILIAL = %xFilial:SC2% AND SC2.C2_PEDIDO||SC2.C2_ITEMPV = SC6.C6_NUM||SC6.C6_ITEM AND SC6.%NotDel%
     
	WHERE 
		SD4.D4_FILIAL = %XFilial:SD4%
		AND SD4.D4_COD BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% 
		AND SD4.D4_OP BETWEEN %Exp:MV_PAR09%  AND %Exp:MV_PAR10% 
		AND SD4.D4_QUANT > 0 
		AND SC6.C6_DTSAIDA BETWEEN %Exp:MV_PAR16% AND %Exp:MV_PAR17% 
		AND SD4.%NotDel%
	GROUP BY SD4.D4_COD
	ORDER BY SD4.D4_COD 	
EndSQL

nBarra := 0
(cAliasSel)->(dbEval({|| nBarra++}))
If oReport==NIL
	SetRegua(nBarra)
Else
	oReport:SetMeter(nBarra)
EndIf

(cAliasSel)->(dbGoTop())

While (cAliasSel)->(!Eof())
	// verifica se o usuario cancelou o processamento
	lEnd := CancelRpt(oReport,lEnd,.T.)
	If lEnd
		Exit
	EndIf

	dData := IIf(MV_PAR14 == 01 .Or. Empty(mv_par15), stod((cAliasSel)->DATAMAX), mv_par15 )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se deve considerar saldos em aberto das entradas    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par03 == 1
		R350SalAbe(oReport, @lEnd, cAliasTRB, (cAliasSel)->D4_COD, dData, (cAliasSel)->DATAMIN, (cAliasSel)->DATAMAX)
	EndIf

	// Seleciona os empenhos, como executa somente 1x por codigo e a query esta na ordem 
	// de produto e data decrescente. Assumo a data calculada
	R350Empenh(oReport, @lEnd, cAliasTRB, (cAliasSel)->D4_COD)

	dbSelectArea(cAliasSel)
	dbSkip()
EndDo
(cAliasSel)->(dbCloseArea())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve as ordens principais dos arquivos                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC1")
dbSetOrder(1)

dbSelectArea("SC2")
dbSetOrder(1)

dbSelectArea("SC7")
dbSetOrder(1)

dbSelectArea("SC8")
dbSetOrder(1)

Return

/*/{Protheus.doc} R350Empenh
Seleciona os empenhos do produto atéa data informada
@author reynaldo
@since 08/11/2017
@version 1.0
@return ${return}, ${return_description}
@param oReport, object, Objeto TReport
@param aCampos, array, array com as informaçoes a serem impressas
@param cCodAnt, characters, Codigo do produto para pesquisa
@param dData, date, Data limite para pesquisa
@type function
/*/
static Function R350Empenh(oReport, lEnd, cAliasTRB, cCodAnt, dData)
Local cAliasTMP := GetNextAlias()
Local aArea		:= GetArea()
Local aCampos	:= {}
Local cWhereTpOP:= "%"+QryAvalOP(mv_par07, "SC2")+"%"

BeginSQL Alias cAliasTMP
	
	COLUMN D4_DATA as Date
	
	SELECT D4_OP, D4_DATA, D4_COD, D4_QUANT 
	FROM 
		%Table:SD4% SD4
	INNER JOIN %Table:SC2% SC2
	ON SC2.C2_FILIAL = %xFilial:SC2% 
		AND SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN = SD4.D4_OP 
		AND SC2.%Exp:cWhereTpOP% AND SC2.%NotDel%
	
	INNER JOIN 
		%Table:SC6% SC6
		ON SC6.C6_FILIAL = %xFilial:SC2% AND SC2.C2_PEDIDO||SC2.C2_ITEMPV = SC6.C6_NUM||SC6.C6_ITEM AND SC6.%NotDel%

	WHERE 
		SD4.D4_FILIAL = %XFilial:SD4%
		AND SD4.D4_COD = %Exp:cCodAnt%
		AND SD4.D4_OP BETWEEN %Exp:MV_PAR09%  AND %Exp:MV_PAR10% 
		AND SD4.D4_QUANT > 0
		AND SC6.C6_DTSAIDA BETWEEN %Exp:MV_PAR16% AND %Exp:MV_PAR17%  
		AND SD4.%NotDel%
EndSQL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega array com os Empenhos de material                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !lEnd .And. !Eof() 
	// verifica se o usuario cancelou o processamento
	lEnd := CancelRpt(oReport,lEnd)
	If lEnd
		Exit
	EndIf

	If mv_par08 == 1 .And. (SomaPrazo((cAliasTMP)->D4_DATA, - CalcPrazo((cAliasTMP)->D4_COD,(cAliasTMP)->D4_QUANT)) >= dDataBase)
		// Não faz nada
	Else
		aCampos := { "S",(cAliasTMP)->D4_OP,(cAliasTMP)->D4_DATA,(cAliasTMP)->D4_COD,(cAliasTMP)->D4_QUANT,(cAliasTMP)->D4_DATA,STR0012,(cAliasTMP)->D4_OP,""}	//"EM"
		GrvTmp(cAliasTRB, aCampos)
	EndIf
	dbSelectArea(cAliasTMP)
	dbSkip()

EndDo
(cAliasTMP)->(dbCloseArea())

RestArea(aArea)
Return

/*/{Protheus.doc} GrvTmp
//TODO Descrição auto-gerada.
@author reynaldo
@since 23/11/2017
@version 1.0
@return ${return}, ${return_description}
@param cAliasTRB, characters, descricao
@param aCampos, array, descricao
@type function
/*/
Static Function GrvTmp(cAliasTRB, aCampos)
Local cAliasOld := Alias()

RecLock(cAliasTRB, .T.)
Replace	TIPO       With aCampos[01],;
		DOCUMENTO  With aCampos[02],;
		DTEVENTO   With aCampos[03],;
		PRODUTO    With aCampos[04],;
		QUANTIDADE With aCampos[05],;
		EMISSAO    With aCampos[06],;
		TIPODOC    With aCampos[07],;
		OP         With aCampos[08],;
		CHAVE      With aCampos[09] 
MsUnlock()

dbSelectArea(cAliasOld)

Return

/*/{Protheus.doc} CancelRpt
//TODO Verifica se o usuario cancelou o processamento/impressão do relatorio
@author reynaldo
@since 21/12/2017
@version 1.0
@return logico, se o usuario cancelou o relatorio
@param oReport, object, Obejto do Treport para impressão do relatorio
@param lEnd, logical, Controle de cancelamento de impressão em versão R3
@type function
/*/

static Function CancelRpt(oReport,lEnd,lMeter)

Default oReport	:= NIL
Default lEnd	:= .F.
Default lMeter	:= .F.
	
If oReport == NIL
	If lMeter
		IncRegua()
	EndIf

	If lEnd
		@ PROW()+1,001 PSay STR0011		//"CANCELADO PELO OPERADOR"
	EndIf
Else
	If lMeter
		oReport:IncMeter()
	EndIf
	lEnd := oReport:Cancel()
EndIf

Return lEnd

/*/{Protheus.doc} R350SalAbe
Faz a selecao nas solicitacoes de compra, cotações e pedido de compra
@author reynaldo
@since 08/11/2017
@version 1.0
@return ${return}, ${return_description}
@param oReport, object, Objeto Treport
@param lEnd, logical, Cancela Impressão
@param cAliasTRB, characters, Alias da tabela de trabalho
@param cCodAnt, characters, Codigo do produto a ser pesquisado
@param dData, date, data limite para pesquisa
@param cDataMin, characters, Menor data em formato AAAAMMDD
@param cDataMax, characters, Maior data em formato AAAAMMDD
@type function
/*/
User Function R350SalAbe(oReport, lEnd, cAliasTRB, cCodAnt, dData ,cDataMin, cDataMax)
Local nAcho
Local nSeek
Local aArea := GetArea()
Local aCampos
Local cFilialSC1
Local cAliasTMP := GetNextAlias()
Local cWhereTpOP:= ""
Local aTam	:= {}
Local nTam1	:= 0
Local nDec1	:= 0
Local nTam2	:= 0
Local nDec2	:= 0
Local nTam3	:= 0
Local nDec3	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega array com Solicitacoes de Compra ou Cotacoes em aberto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC1")
cFilialSC1 := xFilial("SC1") 
MsSeek(cFilialSC1+cCodAnt)
While !lEnd .And. !Eof() .And. C1_FILIAL+C1_PRODUTO == cFilialSC1+cCodAnt

	// verifica se o usuario cancelou o processamento
	lEnd := CancelRpt(oReport,lEnd)
	If lEnd
		Exit
	EndIf

	If C1_DATPRF <= dData .And. MtrAvalOP(mv_par07,"SC1")
		If mv_par08 == 1 .And. (SomaPrazo(C1_DATPRF, - CalcPrazo(C1_PRODUTO, C1_QUANT)) >= dDataBase)
			dbSkip()
			Loop
		EndIf
		(cAliasTRB)->(dbSetOrder(2))
		If !(cAliasTRB)->(dbSeek("SC"+SC1->(C1_NUM+"/"+C1_ITEM))) 
			If C1_QUJE < C1_QUANT
				If !Empty(C1_COTACAO)
					dbSelectArea("SC8")
					MsSeek(xFilial("SC8")+SC1->C1_COTACAO+SC1->C1_PRODUTO)
					If Found() .And. Empty(C8_NUMPED)
						(cAliasTRB)->(dbSetOrder(2))
						If !(cAliasTRB)->(dbSeek("CT"+sc8->(C8_NUM+"/"+C8_ITEM)))
							aCampos := { "E",C8_NUM,SC1->C1_DATPRF,C8_PRODUTO,C8_QUANT,C8_EMISSAO,"CT",SC1->C1_OP,C8_NUM+"/"+C8_ITEM}
							GrvTmp(cAliasTRB, aCampos)
						EndIf
					Else
						dbSelectArea("SC1")
						aCampos := { "E",C1_NUM,C1_DATPRF,C1_PRODUTO,C1_QUANT-C1_QUJE,C1_EMISSAO,"SC",SC1->C1_OP,C1_NUM+"/"+C1_ITEM}
						GrvTmp(cAliasTRB, aCampos)
					EndIf
				Else
					dbSelectArea("SC1")
					aCampos := { "E",C1_NUM,C1_DATPRF,C1_PRODUTO,C1_QUANT-C1_QUJE,C1_EMISSAO,"SC",SC1->C1_OP,C1_NUM+"/"+C1_ITEM}
					GrvTmp(cAliasTRB, aCampos)
				EndIf
			EndIf
		EndIf
	EndIf
	dbSelectArea("SC1")
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega array com os Pedidos de Compas em aberto estando     ³
//³ vinculado ou não a uma solicação de compra                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC7")
aTam := TamSX3("C7_QUANT")
nTam1 := aTam[1]
nDec1 := aTam[2]
aTam := TamSX3("C7_QUJE")
nTam2 := aTam[1]
nDec2 := aTam[2]
BeginSQL Alias cAliasTMP

	COLUMN C7_DATPRF as Date
	COLUMN C7_EMISSAO as Date
	COLUMN C7_QUANT as Numeric(nTam1,nDec1)
	COLUMN C7_QUJE  as Numeric(nTam2,nDec2)

	SELECT
		C7_PRODUTO, C7_NUM, C7_DATPRF, C7_QUANT, C7_QUJE, C7_EMISSAO, C7_OP, C7_ITEM
	FROM 
		%Table:SC7% SC7
	WHERE 
		SC7.C7_FILIAL = %xFilial:SC7%
		AND SC7.C7_PRODUTO = %Exp:cCodAnt%
		AND SC7.C7_DATPRF <= %Exp:dtos(dData)%
		AND SC7.C7_QUJE < SC7.C7_QUANT 
		AND C7_RESIDUO = %Exp:CriaVar("C7_RESIDUO")%
		AND SC7.%NotDel%
		
EndSQL

While !lEnd .And. !Eof()
	// verifica se o usuario cancelou o processamento
	lEnd := CancelRpt(oReport,lEnd)
	If lEnd
		Exit
	EndIf

	If mv_par08 == 1 .And. (SomaPrazo(C7_DATPRF, - CalcPrazo(C7_PRODUTO, C7_QUANT)) >= dDataBase)
		// faz nada
	Else
		(cAliasTRB)->(dbSetOrder(2))
		If !(cAliasTRB)->(dbSeek("PC"+(cAliasTMP)->(C7_NUM+"/"+C7_ITEM)))
			aCampos := { "E",C7_NUM,C7_DATPRF,C7_PRODUTO,C7_QUANT-C7_QUJE,C7_EMISSAO,"PC",C7_OP+"/"+C7_ITEM,C7_NUM+"/"+C7_ITEM}
			GrvTmp(cAliasTRB, aCampos)
		EndIf
	EndIf
	dbSelectArea(cAliasTMP)
	dbSkip()
EndDo
(cAliasTMP)->(dbCloseArea())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega array com Ordens de Producao em aberto               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC2")
cWhereTpOP:= "%"+QryAvalOP(mv_par07, "SC2")+"%"
aTam := TamSX3("C2_QUANT")
nTam1 := aTam[1]
nDec1 := aTam[2]
aTam := TamSX3("C2_QUJE")
nTam2 := aTam[1]
nDec2 := aTam[2]
aTam := TamSX3("C2_PERDA")
nTam3 := aTam[1]
nDec3 := aTam[2]
BeginSQL Alias cAliasTMP

	COLUMN C2_DATPRF as Date
	COLUMN C2_EMISSAO as Date
	COLUMN C2_QUANT as Numeric(nTam1,nDec1)
	COLUMN C2_QUJE  as Numeric(nTam2,nDec2)
	COLUMN C2_PERDA as Numeric(nTam3,nDec3)

	SELECT
		C2_NUM, C2_ITEM, C2_SEQUEN, C2_ITEMGRD, C2_DATPRF, C2_PRODUTO, C2_QUANT, C2_QUJE, C2_PERDA, C2_EMISSAO
	FROM  %Table:SC2% SC2
	INNER JOIN 
		%Table:SC6% SC6
	ON SC6.C6_FILIAL = %xFilial:SC2% AND SC2.C2_NUM||SC2.C2_ITEM = SC6.C6_OP||SC6.C6_ITEMOP AND SC6.%NotDel%
	
	WHERE 
		SC2.C2_FILIAL = %xFilial:SC2%
		AND SC2.C2_PRODUTO = %Exp:cCodAnt%
		AND (SC2.C2_QUJE+SC2.C2_PERDA) < SC2.C2_QUANT 
		AND SC2.C2_DATRF = '          '
		AND SC2.C2_DATPRF > %Exp:cDataMin%
		AND SC2.C2_DATPRF <= %Exp:cDataMax%
		AND SC6.C6_DTSAIDA BETWEEN %Exp:MV_PAR16% AND %Exp:MV_PAR17% 
		AND SC2.%Exp:cWhereTpOP% 
		AND SC2.%NotDel%
		
EndSQL

While !lEnd .And. !Eof()
	// verifica se o usuario cancelou o processamento
	lEnd := CancelRpt(oReport,lEnd)
	If lEnd
		Exit
	EndIf

	If mv_par08 == 1 .And. (SomaPrazo(C2_DATPRF, - CalcPrazo(C2_PRODUTO, C2_QUANT)) >= dDataBase)
		// faz nada
	Else
		aCampos := { "E",C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD,C2_DATPRF,C2_PRODUTO,C2_QUANT-C2_QUJE-C2_PERDA,C2_EMISSAO,"OP",C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD,C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD}
		GrvTmp(cAliasTRB, aCampos)
	EndIf
	dbSelectArea(cAliasTMP)		
	dbSkip()
EndDo
(cAliasTMP)->(dbCloseArea())
RestArea(aArea)
Return

/*/{Protheus.doc} QryAvalOP
//TODO Descrição auto-gerada.
@author reynaldo
@since 24/11/2017
@version 1.0
@return ${return}, ${return_description}
@param nSelecao, numeric, descricao
@param cAlias, characters, descricao
@type function
/*/
Static Function QryAvalOP(nSelecao,cAlias)
Local cRet	:= ""

Default cAlias    := "SC2"

nSelecao:=If(nSelecao == NIL,1,nSelecao)

If nSelecao == 1
	cRet := Substr(cAlias,2,2)+"_TPOP <> 'P' " 
Else
	If nSelecao == 2
		cRet := Substr(cAlias,2,2)+"_TPOP not in (' ','P') "
	Else 
		cRet := Substr(cAlias,2,2)+"_TPOP in ('F','P',' ') "
	EndIf
EndIf

Return cRet
