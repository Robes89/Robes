#INCLUDE "MATR480.CH"
//#INCLUDE "FIVEWIN.Ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR480  ³ Autor ³ Waldemiro L. Lustosa  ³ Data ³ 12.05.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio de Controle de Materiais de Terceiros em nosso po-³±±
±±³          ³der e nosso Material em poder de Terceiros.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ MATR480(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Rodrigo     ³23/06/98³XXXXXX³Acerto no tamanho do documento para 12    ³±±
±±³            ³        ³      ³posicoes                                  ³±±
±±³Fernando J. ³08.12.98³3781A ³Substituir PesqPictQt por PescPict        ³±±
±±³CesarValadao³30/03/99³XXXXXX³Manutencao na SetPrint()                  ³±±
±±³CesarValadao³04/05/99³21554A³Manutencao Lay-Out P Imprimir Quant c/ 17 ³±±
±±³CesarValadao³12/08/99³21421A³Manutencao Lay-Out P Imprimir NF Retorno  ³±±
±±³            ³        ³      ³Alinhada a NF de Origem                   ³±±
±±³Patricia Sal³13/12/99³14655A³Validacao p/Data Digitacao nas Devolucoes ³±±
±±³            ³        ³      ³Incl. Param Dt.Inicial/Final na CalcTerc()³±±
±±³Patricia Sal³20/12/99³XXXXXX³Conversao dos Campos Fornec./Cliente p/   ³±±
±±³            ³        ³      ³(20 posicoes) e Loja p/ 4 posicoes.       ³±±
±±³Iuspa       ³06/12/00³      ³Data de/ate para devolucoes               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DEMONST()

	LOCAL wnrel, nOrdem
	LOCAL Tamanho := "G"
	LOCAL cDesc1  := STR0001	//"Este programa ira emitir o Relatorio de Materiais"
	LOCAL cDesc2  := STR0002	//"de Terceiros em nosso poder e/ou nosso Material em"
	LOCAL cDesc3  := STR0003	//"poder de Terceiros."
	LOCAL cString := "SB6"
	LOCAL aOrd    := {OemToAnsi(STR0004),OemToAnsi(STR0005),OemToAnsi(STR0006)}	//" Produto/Local "###" Cliente/Fornecedor "###" Dt. Mov/Produto "

	PRIVATE cCondCli, cCondFor
	PRIVATE aReturn := {OemToAnsi(STR0007), 1,OemToAnsi(STR0008), 1, 2, 1, "",1 }		//"Zebrado"###"Administracao"
	PRIVATE nomeprog:= "DEMONSTRACAO"                          //CONSIGNACAO
	PRIVATE aLinha  := { },nLastKey := 0
//PRIVATE cPerg   := "PODER3"
	cPerg    := PadR( 'DEMTER' , Len( SX1->X1_GRUPO ) )       //CSGTER
	PRIVATE Titulo  := OemToAnsi(STR0009)	//"Relacao de materiais de Terceiros e em Terceiros"
	PRIVATE cabec1, cabec2, nTipo, CbTxt, CbCont

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Utiliza variaveis static p/ Grupo de Fornec/Clientes(001) e de Loja(002)    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Static aTamSXG, aTamSXG2

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CbTxt := SPACE(10)
	CbCont:= 00
	li	  := 80
	m_pag := 01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica conteudo da variavel p/ Grupo de Clientes/Forneced.(001) e Loja(002) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTamSXG  := If(aTamSXG  == NIL, TamSXG("001"), aTamSXG)
	aTamSXG2 := If(aTamSXG2 == NIL, TamSXG("002"), aTamSXG2)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                                  ³
//³ mv_par01   		// Cliente Inicial                		              ³
//³ mv_par02        // Cliente Final                       	              ³
//³ mv_par03        // Fornecedor Inicial                     	          ³
//³ mv_par04        // Fornecedor Final                          	      ³
//³ mv_par05        // Produto Inicial                              	  ³
//³ mv_par06        // Produto Final                         		      ³
//³ mv_par07        // Data Inicial                              	      ³
//³ mv_par08        // Data Final                                   	  ³
//³ mv_par09        // Situacao   (Todos / Em aberto)                     ³
//³ mv_par10        // Tipo   (De Terceiros / Em Terceiros / Ambos)		  ³
//³ mv_par11        // Custo em Qual Moeda  (1/2/3/4/5)             	  ³
//³ mv_par12        // Lista NF Devolucao  (Sim) (Nao)              	  ³
//³ mv_par13        // Devolucao data de                            	  ³
//³ mv_par14        // Devolucao data ate                           	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis p/ filtrar arquivo.                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCondCli := "B6_CLIFOR   <= mv_par02 .And. B6_CLIFOR  >= mv_par01 .And."+;
		" B6_CODLMT  <= mv_par06 .And. B6_CODLMT >= mv_par05 .And."+;
		" B6_DTDIGIT <= mv_par08 .And. B6_DTDIGIT >= mv_par07 .And."+;
		" B6_QUANT   <> 0 "

	cCondFor := "B6_CLIFOR   <= mv_par04 .And. B6_CLIFOR  >= mv_par03 .And."+;
		" B6_CODLMT  <= mv_par06 .And. B6_CODLMT  >= mv_par05 .And."+;
		" B6_DTDIGIT <= mv_par08 .And. B6_DTDIGIT >= mv_par07 .And."+;
		" B6_QUANT   <> 0 "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SetPrint                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel := "DEMONSTRACAO"

	Processa( {|| AtuB6_CODLMT() } , "Atualização do Código LMT" )

	wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho)

	If nLastKey == 27
		Return .T.
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return .T.
	Endif

	If Select( "TRA" ) # 0
		TRA->( DbCloseArea() )
	EndIf

	//cArqDBF		:= CriaTrab(NIL,.f.)
	aFields		:= {}

	aAdd( aFields , { "CLIFOR"		, "C" , 06 , 00 } )
	aAdd( aFields , { "LOJA"		, "C" , 02 , 00 } )
	aAdd( aFields , { "RAZAO"		, "C" , 40 , 00 } )
	aAdd( aFields , { "PRODUTO"		, "C" , 15 , 00 } )
	aAdd( aFields , { "CODPROCLI"	, "C" , 15 , 00 } )
	aAdd( aFields , { "CODLMT"		, "C" , 50 , 00 } )
	aAdd( aFields , { "DENOM"		, "C" , 60 , 00 } )
	aAdd( aFields , { "NOTA"		, "C" , 10 , 00 } )
	aAdd( aFields , { "DAT_ENV" 	, "D" , 08 , 00 } )
	aAdd( aFields , { "QTD_ENV"		, "N" , 12 , 03 } )
	aAdd( aFields , { "QTD_RET"		, "N" , 12 , 03 } )
	aAdd( aFields , { "QTD_SAL"		, "N" , 12 , 03 } )
	aAdd( aFields , { "VAL_UNI"		, "N" , 14 , 04 } )
	aAdd( aFields , { "VAL_TOT"		, "N" , 14 , 02 } )
	aAdd( aFields , { "DAT_RET" 	, "D" , 08 , 00 } )
	aAdd( aFields , { "TES"     	, "C" , 03 , 00 } )
	aAdd( aFields , { "VAL_ICM"		, "N" , 14 , 02 } )
	aAdd( aFields , { "VAL_IPI"		, "N" , 14 , 02 } )
	
	oTemptable := FWTemporaryTable():New( "TRA")
	oTemptable:SetFields( aFields )
	oTempTable:AddIndex("index1", {"COD"} )
	oTempTable:Create()

	//DbCreate( cArqDbf , aFields )
	//DbUseArea( .T. , , cArqDbf , "TRA" , .F. )

	RptStatus({|lEnd| R480Imp(@lEnd,wnRel,cString,Tamanho)},titulo)

Return NIL

// ****************************************************************************************
// Atualização do código LMT (B6_CODLMT), por não ter um ponto de entrada na rotina
// MATA216  (Refaz poder de terceiros), quando a mesma é processada este campo não é
// atualizado
// Wilson - 23/11/05
Static Function AtuB6_CODLMT()

	Local	cQuery

	cQuery	:= "UPDATE " + RetSqlName( "SB6" )
	cQuery	+= " SET B6_CODLMT = NVL((SELECT B1_CODLMT"
	cQuery	+= " FROM " + RetSqlName( "SB1" )
	cQuery	+= " WHERE D_E_L_E_T_ = ' '
	cQuery	+= " AND B1_COD = B6_PRODUTO"
	cQuery	+= " AND B1_FILIAL = '" + xFilial( "SB1" ) + "'" + "),'  ')"
	cQuery	+= " WHERE D_E_L_E_T_ = ' '"

	MsgRun( OemToAnsi( "Atualizando Código LMT" ), OemToAnsi( "Aguarde..." ), {|| TcSqlExec( cQuery ) } )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R480IMP  ³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 16.11.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR480			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// ****************************************************************************************
Static Function R480Imp(lEnd,WnRel,cString,Tamanho)

	LOCAL limite :=132
	nTipo:=IIF(aReturn[4]==1,15,18)

	nOrdem := aReturn[8]

	dbSelectArea("SB6")

	If nOrdem == 1
		xR480Prod(lEnd,Tamanho)
	Endif
	/*
	ElseIf nOrdem == 2
		xR480CliFor(lEnd,Tamanho)
	ElseIf nOrdem == 3
		xR480Data(lEnd,Tamanho)
	EndIf
	*/
	ferase("DEMTER.DBF")
	dbselectarea("TRA")
	dbgotop()
	//COPY TO "DEMTER.DBF"
	Processa({||CpyS2T("DEMTER.DBF","C:\TEMP\",.T.)},"Copiando Arquivo","Aguarde...",.F.)

	cDestino := 'C:\DEMTER.DBF'

	cPATH:= 'C:\TEMP\'
	cFileName   := "DEMTER.DBF"
	cDestino	:= PADR(cPATH+cFileName, 100)

	dbselectarea("TRA")
	dbgotop()
	//COPY TO (cFileName)

	If U_MLSCpyFile(cFileName,cDestino)
		If ApOleClient("MsExcel")
			oExcelApp:= MsExcel():New()
			oExcelApp:WorkBooks:Open(cDestino)
			oExcelApp:SetVisible(.T.)
		Endif
	EndIf

	ferase("DEMTER.DBF")

	TRA->(DBCLOSEAREA())

	dbSelectArea("SB6")
	Set Filter To
	dbSetOrder(1)

	If aReturn[5] == 1
		Set Printer To
		dbCommitAll()
		ourspool(wnrel)
	Endif

	MS_FLUSH()

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R480Prod ³ Autor ³ Waldemiro L. Lustosa  ³ Data ³ 12/04/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime Por Ordem de Produto / LOCAL.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR480                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// ****************************************************************************************
Static Function xR480Prod(lEnd,Tamanho)

	LOCAL cCliFor, cProdLOCAL := ""
	LOCAL cQuebra,aSaldo:={}
	LOCAL nCusTot := nQuant := nQuJe := nTotal := nTotDev := 0
	Local nTGQuant:= nTGQuje := 0
	LOCAL nGerTot := nGerTotDev:=nGerCusTot:=0
	LOCAL nSaldo  := 0
	Local nCusto  := 0
	Local nPrUnit := 0
	LOCAL cSeek   := ""
	LOCAL aAreaSB6:= {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Cabecalho de acordo com o tipo de emissao            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par10 == 1
		titulo := STR0010		//"RELACAO DE MATERIAIS DE TERCEIROS EM NOSSO PODER - PRODUTO / LOCAL"
	ElseIf mv_par10 == 2
		titulo := STR0011		//"RELACAO DE MATERIAIS NOSSOS EM PODER DE TERCEIROS - PRODUTO / LOCAL"
	Else
		titulo := STR0012		//"RELACAO DE MATERIAIS DE TERCEIROS E EM TERCEIROS - PRODUTO / LOCAL"
	EndIf

	cabec1 := "            Cliente /        Loja  -  Documento  - Data de  Unid.de ---------------------- Quantidade ------------------- --------------- Valores -----------   Custo Prod. TM  Segunda       Preco        Data    Dt Ult."
	cabec2 := "            Fornecedor              Numero  Serie  Emissao   Medida          Original      Ja' entregue             Saldo Total Nota Fiscal   Total Devolvido    na Moeda X     Un.Med.       Unitario   Lancto    Entrega"
	//  Cliente:XXXXXXXXXXXXXXXXXXXX XX    999999   XXX  99/99/9999   XX   99999999999999999 99999999999999999 99999999999999999 99999999999999999 99999999999999999 9999999999999  X    XX     999999999999  99/99/9999 99/99/9999
	//            1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2
	//  01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890


	dbSelectArea("SB6")
	dbSetOrder(5)
	dbgotop()
	SetRegua(LastRec())
	While !Eof() .And. B6_FILIAL == xFilial("SB6")
		IncRegua()

		If lEnd
			@Prow()+1,001 PSay STR0016		//"CANCELADO PELO OPERADOR"
			Exit
		Endif

/*
	dbSelectArea("SB6")	
		If !Empty(aReturn[7])
			If !&(aReturn[7])
			dbSkip()
			Loop
			EndIf
		EndIf
*/
//	dbSelectArea("SF4")
//	dbSeek(cFilial+SB6->B6_TES)
//	If SF4->F4_PODER3 == "D"
//		dbselectArea("SB6")
//		dbSkip()
//		Loop
//	EndIf
		IF ALLTRIM( SB6->B6_DOC ) == "000052015"
			I:=0
		ENDIF


		Do Case
		Case SB6->B6_TES $ Alltrim(mv_par16)
			//Continua
		Case SB6->B6_TES $ Alltrim(mv_par17)
			//Continua
		Case SB6->B6_TES $ Alltrim(mv_par18)
			//Continua
		Case SB6->B6_TES $ Alltrim(mv_par19)
			//Continua
		Otherwise
			dbselectArea("SB6")
			dbSkip()
			Loop
		End Case


		dbSelectArea("SB6")

		IF	IIf(SB6->B6_TPCF == "C" , &cCondCli , &cCondFor )
			aSaldo:=CalcT3(SB6->B6_PRODUTO,SB6->B6_CLIFOR,SB6->B6_LOJA,SB6->B6_IDENT,SB6->B6_TES,,mv_par07,mv_par08)
			dbSelectArea("SB6")
			nSaldo  := aSaldo[1]
			nPrUnit := aSaldo[3]
		Else
			dbSkip()
			Loop
		Endif

		If mv_par09 == 2 .And. nSaldo <= 0
			dbSkip()
			Loop
		EndIf
		If mv_par10 == 1 .And. B6_TIPO != "D"
			dbSkip()
			Loop
		ElseIf mv_par10 == 2 .And. B6_TIPO != "E"
			dbSkip()
			Loop
		EndIf

		dbSelectArea("SB6")

		nCusTot:=0
		nQuant :=0
		nQuJe  :=0
		nTotal :=0
		nTotDev:=0
		nSaldo :=0
		aSaldo :={}
		nCusto :=0
		cQuebra:= B6_CODLMT

		While !Eof() .And. xFilial("SB6") == B6_FILIAL .And. cQuebra == B6_CODLMT

			IncRegua()

			IF ALLTRIM( SB6->B6_DOC ) == "000052015"
				I:=0
			ENDIF
			If li > 55
				Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho,nTipo)
			EndIf

			dbSelectArea("SB6")
			If !Empty(aReturn[7])
				If !&(aReturn[7])
					dbSkip()
					Loop
				EndIf
			EndIf

			dbSelectArea("SF4")
			dbSeek(cFilial+SB6->B6_TES)
			If SF4->F4_PODER3 == "D"
				dbselectArea("SB6")
				dbSkip()
				loop
			Endif

			dbSelectArea("SB6")

			IF	IIf(B6_TPCF == "C" , &cCondCli , &cCondFor )
				aSaldo:=CalcT3(SB6->B6_PRODUTO,SB6->B6_CLIFOR,SB6->B6_LOJA,SB6->B6_IDENT,SB6->B6_TES,,mv_par07,mv_par08)
				dbSelectArea("SB6")
				nSaldo  := aSaldo[1]
				nPrUnit := aSaldo[3]

				If mv_par09 == 2 .And. nSaldo <= 0
					dbSkip()
					Loop
				EndIf
				If mv_par10 == 1 .And. B6_TIPO != "D"
					dbSkip()
					Loop
				ElseIf mv_par10 == 2 .And. B6_TIPO != "E"
					dbSkip()
					Loop
				EndIf
				If cProdLOCAL != B6_CODLMT
					dbSelectArea("SB1")
					dbSetOrder(1)
					If dbSeek(cFilial+SB6->B6_PRODUTO)
						If !Empty(cProdLOCAL)
							li += 2
						EndIf
						If li > 55
							Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho,nTipo)
						EndIf
						@ li,000 PSay STR0017+Trim(B1_CODLMT)+" <-> "+Trim(B1_DENOM)  //+" / "+SB6->B6_LOCAL		//"PRODUTO / LOCAL: "
						cProdLOCAL := SB6->B6_CODLMT
					Else
						Help(" ",1,"R480PRODUT")
						dbSelectArea("SB6")
						dbSetOrder(5)
						Return .F.
					EndIf
				EndIf
				dbSelectArea("SB6")

				If li > 55
					Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho,nTipo)
				EndIf

				If !Empty(cProdLocal)

					li++
					@ li,000 PSay IIf(B6_TPCF == "C",STR0018,STR0019)		//"Clie:"###"Forn:"
					@ li,008 PSay B6_CLIFOR
					@ li,030 PSay B6_LOJA
					@ li,036 PSay B6_DOC
					@ li,045 PSay "-" + B6_SERIE
					@ li,050 PSay Dtoc(B6_EMISSAO)
					@ li,062 PSay B6_UM

					// Quantidade Original
					@ li,068 PSay B6_QUANT Picture PesqPict("SB6","B6_QUANT",17)
					nQuant += B6_QUANT
					nTGQuant += B6_QUANT

					// Quantidade Ja Entregue
					@ li,086 PSay (B6_QUANT - nSaldo) Picture PesqPict("SB6","B6_QUANT",17)
					nQuJe += (B6_QUANT - nSaldo)
					nTGQuJe += (B6_QUANT - nSaldo)

					// Saldo
					@ li,104 PSay nSaldo Picture PesqPict("SB6", "B6_QUANT",17)

					// Total Nota Fiscal
					@ li,122 PSay Transform(B6_QUANT * nPrUnit,'@E 99,999,999,999.99')
					nTotal += B6_QUANT * nPrUnit
					nGerTot+= B6_QUANT * nPrUnit

					// Total Nota Fiscal Devolvido
					@ li,140 PSay Transform((B6_QUANT-nSaldo) * nPrUnit,'@E 99,999,999,999.99')
					nTotDev += (B6_QUANT-nSaldo) * nPrUnit
					nGerTotDev+=(B6_QUANT-nSaldo) * nPrUnit

					// Custo na Moeda
					nCusto := (&("B6_CUSTO"+Str(mv_par11,1,0)) / B6_QUANT) * nSaldo
					nCusTot+= nCusto
					nGerCusTot+=nCusto

					@ li,158 PSay Transform(nCusto,'@E 999,999,999.99')
					@ li,173 PSay B6_TIPO
					@ li,178 PSay B6_SEGUM
					@ li,184 Psay Transform(B6_PRUNIT,'@E 999,999.9999')
					@ li,199 PSay Dtoc(B6_DTDIGIT)
					@ li,210 PSay Dtoc(B6_UENT)

					aArea_SA1	:= SA1->( GetArea() )
					aArea_SA2	:= SA2->( GetArea() )
					aArea_SA7	:= SA7->( GetArea() )
					aArea_SB1	:= SB1->( GetArea() )

					dbSelectArea("SD2")
					dbSetOrder(4)  //D2_FILIAL+D2_NUMSEQ
					dbSeek(xFilial("SD2"))

					RecLock( "TRA" , .T. )
					TRA->CLIFOR		:= SB6->B6_CLIFOR
					TRA->LOJA		:= SB6->B6_LOJA
					IF SB6->B6_TPCF # "C"
						TRA->RAZAO	:= Posicione( "SA2" , 1 , xFilial( "SA2" ) + SB6->( B6_CLIFOR + B6_LOJA ) , "A2_NOME" )
					Else
						TRA->RAZAO	:= Posicione( "SA1" , 1 , xFilial( "SA1" ) + SB6->( B6_CLIFOR + B6_LOJA ) , "A1_NOME" )
					EndIf
					TRA->PRODUTO	:= SB6->B6_PRODUTO
					TRA->CODPROCLI	:= Posicione( "SA7" , 1 , xFilial( "SA7" ) + SB6->( B6_CLIFOR + B6_LOJA + B6_PRODUTO ) , "A7_CODCLI" )
					TRA->CODLMT		:= SB6->B6_CODLMT
					TRA->DENOM		:= Posicione( "SB1" , 18 , xFilial( "SB1" ) + SB6->B6_CODLMT , "B1_DESC" ) //TRA->DENOM		:= Posicione( "SB1" , 9 , xFilial( "SB1" ) + SB6->B6_CODLMT , "B1_DESC" ) Tanimoto 17-08-13. Alterado para ordem 18 pelo CODLMT. Solicitado Regina
					TRA->NOTA		:= SB6->B6_DOC
					TRA->DAT_ENV	:= SB6->B6_EMISSAO
					TRA->QTD_ENV	:= SB6->B6_QUANT
					TRA->QTD_RET	:= (SB6->B6_QUANT - nSaldo)
					TRA->QTD_SAL	:= nSaldo
					TRA->VAL_UNI	:= nPrUnit
					TRA->VAL_TOT	:= (nSaldo * nPrUnit)
					TRA->DAT_RET	:= SB6->B6_UENT
					TRA->TES    	:= SB6->B6_TES
					TRA->( MsUnLock() )

					RestArea( aArea_SA1 )
					RestArea( aArea_SA2	)
					RestArea( aArea_SA7	)
					RestArea( aArea_SB1	)

					DbSelectArea( "SB6" )
					// Lista as devolucoes da remessa
					If mv_par12 == 1 .And. ((B6_QUANT - nSaldo) > 0)
						aAreaSB6 := SB6->(GetArea())
						NREC := SB6->(Recno())
						SB6->( dbSetOrder(3) )
						cSeek:=xFilial("SB6")+B6_IDENT+B6_PRODUTO+"D"
						If SB6->( dbSeek(cSeek) )
							Do While !SB6->( Eof() ) .And. SB6->( B6_FILIAL+B6_IDENT+B6_PRODUTO+B6_PODER3 ) == cSeek
								If SB6->B6_DTDIGIT < mv_par13 .Or. SB6->B6_DTDIGIT > mv_par14
									DbSelectArea("SB6")
									DbSkip()
									Loop
								Endif
								If li > 55
									Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho,nTipo)
								EndIf
								li++
								@ li,000 PSay IIf(B6_TPCF == "C",STR0018,STR0019)		//"Clie:"###"Forn:"
								@ li,008 PSay B6_CLIFOR
								@ li,030 PSay B6_LOJA
								@ li,036 PSay B6_DOC
								@ li,045 PSay B6_SERIE
								@ li,050 PSay Dtoc(B6_EMISSAO)
								@ li,062 PSay B6_UM
								// Quantidade Original (era na coluna 068)
								@ li,086 PSay B6_QUANT Picture PesqPict("SB6", "B6_QUANT",17)
								// Total Nota Fiscal
								@ li,122 PSay Transform(B6_QUANT * nPrUnit,'@E 99,999,999,999.99')
								@ li,173 PSay B6_TIPO
								@ li,178 PSay B6_SEGUM
								@ li,184 Psay Transform(B6_PRUNIT,'@E 999,999.9999')
								@ li,199 PSay Dtoc(B6_DTDIGIT)
								@ li,210 PSay Dtoc(B6_UENT)
								SB6->( dbSkip() )
							EndDo
							li++
						EndIf
						RestArea(aAreaSB6)
						SB6->(dbGoto(NREC))
						SB6->( dbSetOrder(5) )
					EndIf
				EndIf
			EndIf
			SB6->(dbSkip())
		EndDo
		If nQuant > 0
			li++
			@ li,000 PSay "TOTAL PRODUTO -> "+cQuebra
			@ li,068 PSay nQuant        		Picture PesqPict("SB6", "B6_QUANT",17)
			@ li,086 PSay nQuje             	Picture PesqPict("SB6", "B6_QUANT",17)
			@ li,104 PSay (nQuant - nQuJe)  	Picture PesqPict("SB6", "B6_QUANT",17)
			@ li,122 PSay Transform(nTotal, '@E 99,999,999,999.99')
			@ li,140 PSay Transform(nTotDev,'@E 99,999,999,999.99')
			@ li,158 PSay Transform(nCusTot,'@E 999,999,999.99')
		Endif
	End

	li++;li++
	@ li,000 PSay STR0021			//"T O T A L    G E R A L  ---------- >"
	@ li,068 PSay nTGQuant        		Picture PesqPict("SB6", "B6_QUANT",17)
	@ li,086 PSay nTGQuje             	Picture PesqPict("SB6", "B6_QUANT",17)
	@ li,104 PSay (nTGQuant - nTGQuJe)  	Picture PesqPict("SB6", "B6_QUANT",17)
	@ li,122 PSay Transform(nGerTot	  ,'@E 99,999,999,999.99')
	@ li,140 PSay Transform(nGerTotDev,'@E 99,999,999,999.99')
	@ li,158 PSay Transform(nGerCusTot,'@E 999,999,999.99')
	Roda(CbCont,CbTxt,Tamanho)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R480CliFor³ Autor ³ Waldemiro L. Lustosa  ³ Data ³ 12/04/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime Por Ordem de Cliente / Fornecedor.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR480                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
	****************************************************************************************
Static Function xR480CliFor(lEnd,Tamanho)

	LOCAL cCliFor, cCliForAnt
	LOCAL cQuebra,aSaldo:={}
	LOCAL cIndex, cKey, nIndex, cNomeCliFor := "", cDescCliFor := ""
	LOCAL cVar,cFilter
	LOCAL nSaldo  := 0
	LOCAL nCusto  := 0
	LOCAL nPrUnit := 0
	LOCAL nGerTot := nGerTotDev:=nGerCusTot:=0
	LOCAL nCusTot := nQuant:=nQuJe:=nTotal:=nTotDev:= 0
	Local nTGQuant := nTGQuje := 0
	LOCAL aAreaSB6:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho usando indice condicional.          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SB6")
	cIndex  := 'B6_CLIFOR'
	cKey    := 'B6_FILIAL+B6_TPCF+B6_CLIFOR+B6_LOJA+B6_CODLMT+DTOS(B6_DTDIGIT)+B6_DOC' // ERA B6_PRODUTO
	cFilter := SB6->(DbFilter())
	If Empty( cFilter )
		cFilter := 'B6_FILIAL == "'+xFilial('SB6')+'"'
	Else
		cFilter := 'B6_FILIAL == "'+xFilial('SB6')+'" .And. ' + cFilter
	EndIf

	IndRegua("SB6",cIndex,cKey,,cFilter,STR0022)		//" Criando Indice ...    "
	nIndex := RetIndex("SB6")
	#IFNDEF TOP
		dbSetIndex(cIndex+OrdBagExt())
	#ENDIF
	dbSetOrder(nIndex+1)
	dbGoTop()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Cabecalho de acordo com o tipo de emissao            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par10 == 1
		titulo := STR0023		//"RELACAO DE MATERIAIS DE TERCEIROS EM NOSSO PODER - CLIENTE / FORNECEDOR"
	ElseIf mv_par10 == 2
		titulo := STR0024		//"RELACAO DE MATERIAIS NOSSOS EM PODER DE TERCEIROS - CLIENTE / FORNECEDOR"
	Else
		titulo := STR0025		//"RELACAO DE MATERIAIS DE TERCEIROS E EM TERCEIROS - CLIENTE / FORNECEDOR"
	EndIf
	cabec1 := "                                                                                 -Documento-  Data de         Unid. de ---------Quantidade------------  ------------ Valores --------------     Preco       TM  Data da Ult."
	cabec2 := "Produto                                                                          Num   Serie  Emissao  Almox.  Medida  Original Ja entregue      Saldo  Total Nota Fiscal   Total Devolvido    Unitario           Entrega   "
	// XXXXXXXXXXXXXXX  999999999999    XXX  99/99/9999 XX      XX    99999999999999999  99999999999999999  99999999999999999  99999999999999999 99999999999999999 99999999999999  X   XX      999999999999   99/99/99   99/99/99
	//           1         2         3         4         5         6         7         8         9         C         1         2         3         4         5         6         7         8         9         D       & 1         2
	// 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890

	SetRegua(LastRec())

	While !Eof()

		IncRegua()

		If lEnd
			@Prow()+1,001 PSay STR0016		//"CANCELADO PELO OPERADOR"
			Exit
		EndIf

		dbSelectArea("SB6")
		If !Empty(aReturn[7])
			If !&(aReturn[7])
				dbSkip()
				Loop
			EndIf
		EndIf

		dbSelectArea("SF4")
		dbSeek(cFilial+SB6->B6_TES)
		If SF4->F4_PODER3 == "D"
			dbselectArea("SB6")
			dbSkip()
			Loop
		EndIf

		dbSelectArea("SB6")

		IF	IIf(B6_TPCF == "C" , &cCondCli , &cCondFor )
			aSaldo:=CalcT3(SB6->B6_PRODUTO,SB6->B6_CLIFOR,SB6->B6_LOJA,SB6->B6_IDENT,SB6->B6_TES,,mv_par07,mv_par08)
			dbSelectArea("SB6")
			nSaldo:= aSaldo[1]
			nPrUnit := aSaldo[3]
		Else
			dbSkip()
			Loop
		EndIf

		If mv_par09 == 2 .And. nSaldo <= 0
			dbSkip()
			Loop
		EndIf
		If mv_par10 == 1 .And. B6_TIPO != "D"
			dbSkip()
			Loop
		ElseIf mv_par10 == 2 .And. B6_TIPO != "E"
			dbSkip()
			Loop
		EndIf

		cQuebra  := B6_CLIFOR+B6_LOJA+B6_PRODUTO+B6_TPCF
		nCusTot  := 0
		nQuant	 := 0
		nQuJe	 := 0
		nTotal	 := 0
		nTotDev	 := 0

		Do While B6_CLIFOR+B6_LOJA+B6_PRODUTO+B6_TPCF == cQuebra

			IncRegua()

			DbSelectArea( "SB6" )
			If	!(If(B6_TPCF == "C" , &cCondCli , &cCondFor ))
				dbSkip()
				Loop
			EndIf

			If !Empty(aReturn[7])
				If !&(aReturn[7])
					dbSkip()
					Loop
				EndIf
			EndIf

			dbSelectArea("SF4")
			dbSeek(cFilial+SB6->B6_TES)
			If SF4->F4_PODER3 == "D"
				dbSelectArea("SB6")
				dbSkip()
				Loop
			Endif

			dbSelectArea("SB6")
			aSaldo:=CalcT3(SB6->B6_PRODUTO,SB6->B6_CLIFOR,SB6->B6_LOJA,SB6->B6_IDENT,SB6->B6_TES,,mv_par07,mv_par08)
			dbSelectArea("SB6")
			nSaldo:= aSaldo[1]

			If mv_par09 == 2 .And. nSaldo <= 0
				dbSkip()
				Loop
			EndIf

			If mv_par10 == 1 .And. B6_TIPO != "D"
				dbSkip()
				Loop
			ElseIf mv_par10 == 2 .And. B6_TIPO != "E"
				dbSkip()
				Loop
			EndIf

			If Li > 55
				Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho,nTipo)
			EndIf

			If cCliForAnt != B6_TPCF .Or. cNomeCliFor != B6_CLIFOR+B6_LOJA
				dbSelectArea(IIf(B6_TPCF == "C" , "SA1" , "SA2" ) )
				dbSeek(cFilial+SB6->B6_CLIFOR+SB6->B6_LOJA)
				If Found()
					If !Empty(cDescCliFor)
						li++
					EndIf
					cDescCliFor	:= IIf(SB6->B6_TPCF == "C" , STR0028 , STR0029)		//"CLIENTE / LOJA: "###"FORNECEDOR / LOJA: "
					@ li,000 PSay cDescCliFor+Trim( IIf(SB6->B6_TPCF == "C" ,A1_COD+" - "+A1_NOME , A2_COD+" - "+A2_NOME )  )+" / "+IIf(SB6->B6_TPCF == "C" , A1_LOJA , A2_LOJA )
					cNomeCliFor := SB6->B6_CLIFOR+SB6->B6_LOJA
					cCliForAnt 	:= SB6->B6_TPCF
				Else
					Help(" ",1,"R480CLIFOR")
					RetIndex("SB6")
					dbSelectArea("SB6")
					dbSetOrder(1)
					cIndex += OrdBagExt()
					Ferase(cIndex)
					Return .F.
				EndIf
				dbSelectArea("SB6")
			EndIf

			If Li > 55
				Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho,nTipo)
			EndIf

			If Len(cNomeCliFor) != 0
				li++
				dbSelectArea("SB1")
				dbSetOrder(1)
				dbSeek(cFilial+SB6->B6_PRODUTO)
				cProda1 := Trim(SB1->B1_CODLMT) + " / " + Trim(SB1->B1_DENOM)
				cProda2 := ""
				dbSelectArea("SB6")

				@ li,000 PSay cProda1
				@ li,025+32+9+15 PSay B6_DOC
				@ li,033+32+9+15 PSay B6_SERIE
				@ li,038+32+9+15 PSay Dtoc(B6_EMISSAO)
				@ li,049+32+9+15 PSay B6_LOCAL
				@ li,057+32+9+15 PSay B6_UM

				// Quantidade Original
				@ li,063+48+6 PSay B6_QUANT Picture "@E 99,999,999"
				nQuant     += B6_QUANT
				nTGQuant     += B6_QUANT

				// localiza Saldo
				aSaldo:=CalcT3(SB6->B6_PRODUTO,SB6->B6_CLIFOR,SB6->B6_LOJA,SB6->B6_IDENT,SB6->B6_TES,,mv_par07,mv_par08)
				dbSelectArea("SB6")
				nSaldo  := aSaldo[1]
				nPrUnit := aSaldo[3]

				// Quantidade Ja Entregue
				@ li,082+47 PSay (B6_QUANT - nSaldo) Picture "@E 99,999,999"
				nQuJe     += B6_QUANT - nSaldo
				nTGQuJe     += B6_QUANT - nSaldo

				// Saldo
				@ li,101+39 PSay nSaldo Picture "@E 99,999,999"

				// Total da Nota Fiscal
				@ li,120+32 PSay Transform(B6_QUANT * nPrUnit,'@E 99,999,999,999.99')
				nTotal	+= B6_QUANT * nPrUnit
				nGerTot	+= B6_QUANT * nPrUnit

				// Total da Nota Fiscal Devolvido
				@ li,170 PSay Transform((B6_QUANT - nSaldo) * nPrUnit,'@E 999,999,999.99')
				nTotDev		+= (B6_QUANT - nSaldo) * nPrUnit
				nGerTotDev	+= (B6_QUANT - nSaldo) * nPrUnit
				nCusto 		:= (&("B6_CUSTO"+Str(mv_par11,1,0)) / B6_QUANT) * nSaldo
				nCusTot 	+= nCusto
				nGerCusTot 	+= nCusto

				@ li,185 PSay Transform(B6_PRUNIT,'@E 999,999.9999')
				@ li,204 PSay B6_TIPO
				@ li,210 PSay Dtoc(B6_UENT)

				aArea_SA1	:= SA1->( GetArea() )
				aArea_SA2	:= SA2->( GetArea() )
				aArea_SA7	:= SA7->( GetArea() )
				aArea_SB1	:= SB1->( GetArea() )

				RecLock( "TRA" , .T. )
				TRA->CLIFOR		:= SB6->B6_CLIFOR
				TRA->LOJA		:= SB6->B6_LOJA
				IF SB6->B6_TPCF # "C"
					TRA->RAZAO	:= Posicione( "SA2" , 1 , xFilial( "SA2" ) + SB6->( B6_CLIFOR + B6_LOJA ) , "A2_NOME" )
				Else
					TRA->RAZAO	:= Posicione( "SA1" , 1 , xFilial( "SA1" ) + SB6->( B6_CLIFOR + B6_LOJA ) , "A1_NOME" )
				EndIf
				TRA->PRODUTO	:= SB6->B6_PRODUTO
				TRA->CODPROCLI	:= Posicione( "SA7" , 1 , xFilial( "SA7" ) + SB6->( B6_CLIFOR + B6_LOJA + B6_PRODUTO ) , "A7_CODCLI" )
				TRA->CODLMT		:= SB6->B6_CODLMT
				TRA->DENOM		:= Posicione( "SB1" , 18 , xFilial( "SB1" ) + SB6->B6_CODLMT , "B1_DESC" ) //			TRA->DENOM		:= Posicione( "SB1" , 9 , xFilial( "SB1" ) + SB6->B6_CODLMT , "B1_DESC" ) Tanimoto 17-08-13. Alterado para ordem 18. Solicitado REgina
				TRA->NOTA		:= SB6->B6_DOC
				TRA->DAT_ENV	:= SB6->B6_EMISSAO
				TRA->QTD_ENV	:= SB6->B6_QUANT
				TRA->QTD_RET	:= (SB6->B6_QUANT - nSaldo)
				TRA->QTD_SAL	:= nSaldo
				TRA->VAL_UNI	:= nPrUnit
				TRA->VAL_TOT	:= (nSaldo * nPrUnit)
				TRA->DAT_RET	:= SB6->B6_UENT
				TRA->TES    	:= SB6->B6_TES
				TRA->( MsUnLock() )

				RestArea( aArea_SA1 )
				RestArea( aArea_SA2	)
				RestArea( aArea_SA7	)
				RestArea( aArea_SB1	)

			EndIf

			// Lista as devolucoes da remessa
			If mv_par12 == 1 .And. ((B6_QUANT - nSaldo) > 0)
				aAreaSB6 := SB6->(GetArea())
				DbSelectArea( "SB6" )
				dbSetOrder(3)
				cSeek:=xFilial()+B6_IDENT+B6_PRODUTO+"D"
				If SB6->( dbSeek(cSeek) )
					li++
					@ li,000 PSay STR0041	//"Notas Fiscais de Retorno"
					Do While !SB6->( Eof() ) .And. SB6->( B6_FILIAL+B6_IDENT+B6_PRODUTO+B6_PODER3 ) == cSeek
						If SB6->B6_DTDIGIT < mv_par13 .Or. SB6->B6_DTDIGIT > mv_par14
							DbSelectArea("SB6")
							DbSkip()
							Loop
						EndIf
						If li > 55
							Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho,nTipo)
						EndIf
						li++
						@ li,025+32+24 PSay B6_DOC
						@ li,033+32+24 PSay B6_SERIE
						@ li,038+32+24 PSay Dtoc(B6_EMISSAO)
						@ li,049+32+24 PSay B6_LOCAL
						@ li,057+32+24 PSay B6_UM
						// Quantidade Original
						@ li,063+48+6 PSay B6_QUANT Picture "@E 99,999,999"
						// Total da Nota Fiscal
						@ li,152 PSay Transform(B6_QUANT * nPrUnit,'@E 99,999,999,999.99')
						// Total da Nota Fiscal Devolvido
						@ li,185 PSay Transform(B6_PRUNIT,'@E 999,999.9999')
						@ li,204 PSay B6_TIPO
						@ li,210 PSay Dtoc(B6_UENT)
						SB6->( dbSkip() )
					EndDo
					li++
				EndIf
				RestArea(aAreaSB6)
				dbSetOrder(nIndex+1)
			EndIf

			SB6->( dbSkip() )
		EndDo
		If nQuant > 0
			li++
			DbSelectArea( "SB6" )
			dbSkip(-1)
			cVar:=IIF(B6_TPCF == "C" ,STR0030,STR0031)	//"CLIENTE ---->"###"FORNECEDOR --->"
			dbSkip();IncRegua()
			If li > 55
				Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho,nTipo)
			EndIf
			@ li,000 PSay STR0032 +cVar		//"TOTAL DO PRODUTO NO "
			@ li,063+48+6 PSay nQuant					Picture "@E 99,999,999"
			@ li,082+47 PSay nQuje					Picture "@E 99,999,999"
			@ li,101+39 PSay (nQuant - nQuJe)	Picture "@E 99,999,999"
			@ li,120+32 PSay Transform(nTotal ,'@E 99,999,999,999.99')
			@ li,170    PSay Transform(nTotDev,'@E 999,999,999.99')
			li++
		Endif
	End
	li++
	@ li,000 PSay STR0021		//"T O T A L    G E R A L  ---------- >"
	@ li,063+48+6 PSay nTGQuant					Picture "@E 99,999,999"
	@ li,082+47 PSay nTGQuje					Picture "@E 99,999,999"
	@ li,101+39 PSay (nTGQuant - nTGQuJe)	Picture "@E 99,999,999"
	@ li,119+32 PSay Transform(nGerTot	 ,'@E 9,999,999,999.99')
	@ li,152    PSay Transform(nGerTotDev,'@E 9,999,999,999.99')
	Roda(CbCont,CbTxt,Tamanho)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve condicao original ao SB6 e apaga arquivo de trabalho.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RetIndex("SB6")
	dbSelectArea("SB6")
	dbSetOrder(1)
	cIndex += OrdBagExt()
	Ferase(cIndex)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R480Data ³ Autor ³ Waldemiro L. Lustosa  ³ Data ³ 13/04/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime Por Ordem de Data do Movimento (B6_DTDIGIT).       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR480                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
	****************************************************************************************
Static Function xR480Data(lEnd,Tamanho)
	LOCAL nCusTot := nQuant := nQuJe := nTotal := nTotDev := 0
	Local nTGQuant := nTGQuje := 0
	LOCAL nGerTot:=nGerTotDev:=nGerCusTot:=0
	LOCAL cIndex, cKey, nIndex, cFilter
	LOCAL cCondFiltr:=""
	LOCAL aSaldo  := {}
	Local nSaldo  := 0
	Local nCusto  := 0
	Local nPrUnit := 0
	LOCAL cQuebra, lImprime:=.F.
	LOCAL aAreaSB6:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho usando indice condicional.          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SB6")
	cIndex  := 'B6_FILIAL'
	cKey    := "B6_FILIAL+DTOS(B6_DTDIGIT)+B6_CODLMT+B6_CLIFOR+B6_LOJA" // ERA B6_PRODUTO
	cFilter := SB6->(DbFilter())
	If Empty( cFilter )
		cFilter := 'B6_FILIAL == "'+xFilial('SB6')+'"'
	Else
		cFilter := 'B6_FILIAL == "'+xFilial('SB6')+'" .And. ' + cFilter
	EndIf
	IndRegua("SB6",cIndex,cKey,,cFilter,STR0022)		//" Criando Indice ...    "
	nIndex := RetIndex("SB6")
	#IFNDEF TOP
		dbSetIndex(cIndex+OrdBagExt())
	#ENDIF
	dbSetOrder(nIndex+1)
	dbGoTop()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Cabecalho de acordo com o tipo de emissao            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par10 == 1
		titulo := STR0033		//"RELACAO DE MATERIAIS DE TERCEIROS EM NOSSO PODER - DATA DO MOVIMENTO"
	ElseIf mv_par10 == 2
		titulo := STR0034		//"RELACAO DE MATERIAIS NOSSOS EM PODER DE TERCEIROS - DATA DO MOVIMENTO"
	Else
		titulo := STR0035		//"RELACAO DE MATERIAIS DE TERCEIROS E EM TERCEIROS - DATA DO MOVIMENTO"
	EndIf

	cabec1 := "         Cliente /                                    -Document- Data de       UM --------------------- Quantidade ----------------- ------------ Valores ------------ Custo Produto TM Seg.  Preco             Data       -
	cabec2 := "         Fornec.          Loja Produto                Num  Serie Emissao  Almox           Original     Ja' entregue            Saldo Total Nota Fiscal Total Devolvido  na Moeda X      UM    Unitario  Lancamento   Entrega


	SetRegua(LastRec())

	While !Eof()

		IncRegua()

		If lEnd
			@Prow()+1,001 PSay STR0016		//"CANCELADO PELO OPERADOR"
			Exit
		Endif

		dbSelectArea("SB6")
		If !Empty(aReturn[7])
			If !&(aReturn[7])
				dbSkip()
				Loop
			EndIf
		EndIf

		IF	!(Iif(B6_TPCF == "C" , &cCondCli , &cCondFor ))
			dbSkip()
			Loop
		EndIf

		dbSelectArea("SF4")
		dbSeek(cFilial+SB6->B6_TES)
		If SF4->F4_PODER3 == "D"
			dbselectArea("SB6")
			dbSkip()
			loop
		Endif

		dbSelectArea("SB6")
		aSaldo  := CalcT3(SB6->B6_PRODUTO,SB6->B6_CLIFOR,SB6->B6_LOJA,SB6->B6_IDENT,SB6->B6_TES,,mv_par07,mv_par08)
		dbSelectArea("SB6")
		nSaldo  := aSaldo[1]
		nPrUnit := aSaldo[3]

		If mv_par09 == 2 .And. nSaldo <= 0
			dbSkip()
			Loop
		ElseIf mv_par10 == 1 .And. B6_TIPO != "D"
			dbSkip()
			Loop
		ElseIf mv_par10 == 2 .And. B6_TIPO != "E"
			dbSkip()
			Loop
		Endif
		nCusTot  := 0
		nQuant   := 0
		nQuJe    := 0
		nTotal   := 0
		nTotDev  := 0
		cQuebra  := dTos(B6_EMISSAO)+B6_CODLMT
		lImprime := .T.
		While !Eof() .And. cQuebra == dTos(B6_EMISSAO)+B6_CODLMT .And. B6_Filial == xFilial()

			IncRegua()

			If li > 55
				Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho,nTipo)
			EndIf

			dbSelectArea("SB6")
			If !Empty(aReturn[7])
				If !&(aReturn[7])
					dbSkip()
					Loop
				EndIf
			EndIf

			IF	!(Iif(B6_TPCF == "C" , &cCondCli , &cCondFor ))
				dbSkip()
				Loop
			EndIf

			dbSelectArea("SF4")
			dbSeek(cFilial+SB6->B6_TES)
			If SF4->F4_PODER3 == "D"
				dbselectArea("SB6")
				dbSkip()
				loop
			Endif

			dbSelectArea("SB6")
			aSaldo:=CalcT3(SB6->B6_PRODUTO,SB6->B6_CLIFOR,SB6->B6_LOJA,SB6->B6_IDENT,SB6->B6_TES,,mv_par07,mv_par08)
			dbSelectArea("SB6")
			nSaldo  := aSaldo[1]
			nPrUnit := aSaldo[3]

			If mv_par09 == 2 .And. nSaldo <= 0
				dbSkip()
				Loop
			ElseIf mv_par10 == 1 .And. B6_TIPO != "D"
				dbSkip()
				Loop
			ElseIf mv_par10 == 2 .And. B6_TIPO != "E"
				dbSkip()
				Loop
			Endif

			If lImprime
				li++
				@ li,000 PSay STR0038 + dToc(B6_EMISSAO)		//"DATA DE MOVIMENTACAO : "
				lImprime := .F.
			Endif
			dbSelectArea("SB1")
			dbSetOrder(1)
			dbSeek(cFilial+SB6->B6_PRODUTO)
			cProd1 := Left(SB1->B1_CODLMT,23)
			cProd2 := Substr(SB1->B1_CODLMT,24)
			ll2    := .T.
			If Empty(cProd2)
				ll2 := .F.
			Endif
			dbSelectArea("SB6")
			li++
			@ li,000 PSay IIf(B6_TPCF == "C" , STR0018, STR0039 )		//"Clie:"###"Forn:"
			@ li,005 PSay B6_CLIFOR
			@ li,026 PSay B6_LOJA
			@ li,031 PSay cProd1
			@ li,047+7 PSay B6_DOC
			@ li,061 PSay B6_SERIE
			@ li,065 PSay Dtoc(B6_EMISSAO)
			@ li,075 PSay B6_LOCAL
			@ li,079 PSay B6_UM


			// Quantidade Original
			@ li,082 PSay B6_QUANT Picture PesqPict("SB6", "B6_QUANT",16)
			nQuant += B6_QUANT
			nTGQuant += B6_QUANT

			// Localiza o Saldo
			aSaldo:=CalcT3(SB6->B6_PRODUTO,SB6->B6_CLIFOR,SB6->B6_LOJA,SB6->B6_IDENT,SB6->B6_TES,,mv_par07,mv_par08)
			dbSelectArea("SB6")
			nSaldo  := aSaldo[1]
			nPrUnit := aSaldo[3]

			// Quantidade Ja Entregue
			@ li,100 PSay (B6_QUANT - nSaldo) Picture PesqPict("SB6", "B6_QUANT",15)
			nQuJe += (B6_QUANT - nSaldo)
			nTGQuJe += (B6_QUANT - nSaldo)

			// Saldo
			@ li,116 PSay nSaldo Picture PesqPict("SB6", "B6_QUANT",16)

			// Total da Nota Fiscal
			@ li,133 PSay Transform(B6_QUANT * nPrUnit,'@E 99,999,999,999.99')
			nTotal += B6_QUANT * nPrUnit
			nGerTot+= B6_QUANT * nPrUnit

			// Total da Nota Fiscal Devolvido
			@ li,151 PSay Transform((B6_QUANT - nSaldo) * nPrUnit,'@E 999,999,999.99')
			nTotDev += (B6_QUANT - nSaldo) * nPrUnit
			nGerTotDev	+= (B6_QUANT - nSaldo) * nPrUnit
			nCusto := (&("B6_CUSTO"+Str(mv_par11,1,0)) / B6_QUANT) * nSaldo
			nCusTot+= nCusto
			nGerCusTot+= nCusto

			@ li,167 PSay Transform(nCusto,'@E 999,999,999.99')
			@ li,182 PSay B6_TIPO
			@ li,184 PSay B6_SEGUM
			@ li,187 PSay Transform(B6_PRUNIT,'@E 999,999.9999')
			@ li,200 PSay Dtoc(B6_DTDIGIT)
			@ li,210 PSay Dtoc(B6_UENT)

			aArea_SA1	:= SA1->( GetArea() )
			aArea_SA2	:= SA2->( GetArea() )
			aArea_SA7	:= SA7->( GetArea() )
			aArea_SB1	:= SB1->( GetArea() )

			RecLock( "TRA" , .T. )
			TRA->CLIFOR		:= SB6->B6_CLIFOR
			TRA->LOJA		:= SB6->B6_LOJA
			IF SB6->B6_TPCF # "C"
				TRA->RAZAO	:= Posicione( "SA2" , 1 , xFilial( "SA2" ) + SB6->( B6_CLIFOR + B6_LOJA ) , "A2_NOME" )
			Else
				TRA->RAZAO	:= Posicione( "SA1" , 1 , xFilial( "SA1" ) + SB6->( B6_CLIFOR + B6_LOJA ) , "A1_NOME" )
			EndIf
			TRA->PRODUTO	:= SB6->B6_PRODUTO
			TRA->CODPROCLI	:= Posicione( "SA7" , 1 , xFilial( "SA7" ) + SB6->( B6_CLIFOR + B6_LOJA + B6_PRODUTO ) , "A7_CODCLI" )
			TRA->CODLMT		:= SB6->B6_CODLMT
			TRA->DENOM		:= Posicione( "SB1" , 18 , xFilial( "SB1" ) + SB6->B6_CODLMT , "B1_DESC" ) //		TRA->DENOM		:= Posicione( "SB1" , 18 , xFilial( "SB1" ) + SB6->B6_CODLMT , "B1_DESC" ) Tanimoto 17-08-13. Alterado para ordem 18. Solicitado REgina
			TRA->NOTA		:= SB6->B6_DOC
			TRA->DAT_ENV	:= SB6->B6_EMISSAO
			TRA->QTD_ENV	:= SB6->B6_QUANT
			TRA->QTD_RET	:= (SB6->B6_QUANT - nSaldo)
			TRA->QTD_SAL	:= nSaldo
			TRA->VAL_UNI	:= nPrUnit
			TRA->VAL_TOT	:= (nSaldo * nPrUnit)
			TRA->DAT_RET	:= SB6->B6_UENT
			TRA->TES    	:= SB6->B6_TES
			TRA->( MsUnLock() )

			RestArea( aArea_SA1 )
			RestArea( aArea_SA2	)
			RestArea( aArea_SA7	)
			RestArea( aArea_SB1	)

			// Lista as devolucoes da remessa
			If mv_par12 == 1 .And. ((SB6->B6_QUANT - nSaldo) > 0)
				aAreaSB6 := SB6->(GetArea())
				DbSelectArea( "SB6" )
				dbSetOrder(3)
				cSeek:=xFilial()+SB6->B6_IDENT+SB6->B6_PRODUTO+"D"
				If SB6->( dbSeek(cSeek) )
					li++
					@ li,000 PSay STR0041	//"Notas Fiscais de Retorno"
					If ll2
						@ li,031 PSay cProd2
						ll2 := .F.
					Endif
					Do While !SB6->( Eof() ) .And. SB6->( B6_FILIAL+B6_IDENT+B6_PRODUTO+B6_PODER3 ) == cSeek
						If SB6->B6_DTDIGIT < mv_par13 .Or. SB6->B6_DTDIGIT > mv_par14
							DbSelectArea("SB6")
							DbSkip()
							Loop
						Endif
						If li > 55
							Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho,nTipo)
						EndIf
						li++
						dbSelectArea("SB1")
						dbSetOrder(1)
						dbSeek(cFilial+SB6->B6_PRODUTO)
						cProda1 := Left(SB1->B1_CODLMT,23)
						cProda2 := Substr(SB1->B1_CODLMT,24)
						dbSelectArea("SB6")

						@ li,000 PSay IIf(B6_TPCF == "C" , STR0018, STR0039 )		//"Clie:"###"Forn:"
						@ li,005 PSay B6_CLIFOR
						@ li,026 PSay B6_LOJA
						@ li,031 PSay cProda1
						@ li,047+7 PSay B6_DOC
						@ li,061 PSay B6_SERIE
						@ li,065 PSay Dtoc(B6_EMISSAO)
						@ li,075 PSay B6_LOCAL
						@ li,079 PSay B6_UM
						// Quantidade Original
						@ li,082 PSay B6_QUANT Picture PesqPict("SB6", "B6_QUANT",16)
						// Total da Nota Fiscal
						@ li,133 PSay Transform(B6_QUANT * nPrUnit,'@E 99,999,999,999.99')
						@ li,182 PSay B6_TIPO
						@ li,184 PSay B6_SEGUM
						@ li,187 PSay Transform(B6_PRUNIT,'@E 999,999.9999')
						@ li,200 PSay Dtoc(B6_DTDIGIT)
						@ li,210 PSay Dtoc(B6_UENT)
						If !Empty(cProda2)
							li++
							@ li,031 PSay cProda2
						Endif
						SB6->( dbSkip() )
					EndDo
					li++
				EndIf
				RestArea(aAreaSB6)
				dbSetOrder(nIndex+1)
			EndIf

			SB6->( dbSkip() )
		EndDo
		If nQuant > 0
			li++
			@ li,000 PSay "TOTAL DO PRODUTO NA DATA ----->"
			If ll2
				@ li,031 PSay cProd2
				ll2 := .F.
			Endif
			@ li,082 PSay nQuant 			 Picture PesqPict("SB6", "B6_QUANT",16)
			@ li,100 PSay nQuJe  			 Picture PesqPict("SB6", "B6_QUANT",15)
			@ li,116 PSay (nQuant - nQuJe) Picture PesqPict("SB6", "B6_QUANT",16)
			@ li,133 PSay Transform(nTotal, '@E 99,999,999,999.99')
			@ li,151 PSay Transform(nTotDev,'@E 999,999,999.99')
			@ li,167 PSay Transform(nCusTot,'@E 999,999,999.99')
			li++
		Endif
	End

	li++;li++
	@ li,000 PSay STR0021		//"T O T A L    G E R A L  ---------- >"
	@ li,082 PSay nTGQuant 			 Picture PesqPict("SB6", "B6_QUANT",16)
	@ li,100 PSay nTGQuJe  			 Picture PesqPict("SB6", "B6_QUANT",15)
	@ li,116 PSay (nTGQuant - nTGQuJe) Picture PesqPict("SB6", "B6_QUANT",16)
	@ li,133 PSay Transform(nGerTot	 ,'@E 99,999,999,999.99')
	@ li,151 PSay Transform(nGerTotDev,'@E 999,999,999.99')
	@ li,167 PSay Transform(nGerCusTot,'@E 999,999,999.99')
	Roda(CbCont,CbTxt,Tamanho)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve condicao original ao SB6 e apaga arquivo de trabalho.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RetIndex("SB6")
	dbSelectArea("SB6")
	dbSetOrder(1)
	cIndex += OrdBagExt()
	Ferase(cIndex)

Return .T.

Static Function CalcT3(cCod,cClIfor,cLoja,cIdentB6,cTesB6,cTipo,dDtIni,dDtFim)

	Local aArq       := GetArea()
	Local aArqSF4    := SF4->(GetArea())
	Local aArqSB6    := SB6->(GetArea())
	Local aStruSB6   := {}
	Local aSaldo     := {0,0,0,0,0,0}
	Local lConsIni   := (ValType(dDtIni)=='D'.And.!Empty(dDtIni))
	Local lConsFim   := (ValType(dDtFim)=='D'.And.!Empty(dDtFim))
	Local lQuery     := .F.
	Local cAliasSB6  := "SB6"
	Local cAliasSF4  := "SF4"
	Local aNF        := {}
	Local cNF        := ""
	Local l103       := IsInCallStack("MATA103")

	#IFDEF TOP
		Local cQuery     := ""
		Local nX         := 0
	#ELSE
		Local cCompB6    := ""
		Local nRegSB6    := 0
		Local cFilterB6  := SB6->(dbFilter())
	#ENDIF

	dbSelectArea("SB6")
	If !Empty(cIdentB6)
		DbSetOrder(3)
		lQuery     := .T.
		aStruSB6   := SB6->(dbStruct())
		cAliasSB6  := "CALCTERC"
		cAliasSF4  := "CALCTERC"

		cQuery := "SELECT "+SqlOrder(SB6->(IndexKey()))+","
		For nX := 1 To Len(aStruSB6)
			If !aStruSB6[nX][1]$cQuery
				cQuery += aStruSB6[nX][1]+","
			EndIf
		Next nX
		cQuery += "SF4.F4_PODER3 "
		cQuery += " FROM "+RetSqlName("SB6")+" SB6,"+RetSqlName("SF4")+" SF4 "
		cQuery += "WHERE SB6.B6_FILIAL='"+xFilial("SB6")+"' AND "
		cQuery += "SB6.B6_IDENT='"+cIdentB6+"' AND "
		cQuery += "SB6.B6_PRODUTO='"+cCod+"' AND "
		cQuery += "SB6.D_E_L_E_T_=' ' AND "
		If cTesB6 <= "500"
			If cTipo == "B"
				cQuery += "SB6.B6_TPCF='C' AND "
			ElseIf cTipo == "N"
				cQuery += "SB6.B6_TPCF='F' AND "
			EndIf
		Else
			If cTipo == "B"
				cQuery += "SB6.B6_TPCF='F' AND "
			ElseIf cTipo == "N"
				cQuery += "SB6.B6_TPCF='C' AND "
			EndIf
		EndIf
		If ( lConsIni )
			cQuery += "SB6.B6_DTDIGIT>='"+Dtos(dDtIni)+"' AND "
		EndIf
		If ( lConsFim )
			cQuery += "SB6.B6_DTDIGIT<='"+Dtos(dDtFim)+"' AND "
		EndIf
		cQuery += "SF4.F4_FILIAL='"+xFilial("SF4")+"' AND "
		cQuery += "SF4.F4_CODIGO=SB6.B6_TES AND "
		cQuery += "SF4.D_E_L_E_T_=' ' "
		If SB6->(FieldPos("B6_IDENTB6"))<>0
			cQuery += "UNION ALL "+StrTran(cQuery,"B6_IDENT=","B6_IDENTB6=")+" "
		EndIf
		cQuery += "ORDER BY 1,2,3,4"

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB6,.T.,.T.)

		For nX := 1 To Len(aStruSB6)
			If ( aStruSB6[nX][2] <> "C" )
				TcSetField(cAliasSB6,aStruSB6[nX][1],aStruSB6[nX][2],aStruSB6[nX][3],aStruSB6[nX][4])
			EndIf
		Next nX
		While !Eof() .And. xFilial("SB6") == (cAliasSB6)->B6_FILIAL .And.;
				(IIf(SB6->(FieldPos("B6_IDENTB6"))<>0,cIdentB6==(cAliasSB6)->B6_IDENTB6,.F.) .Or.;
				cIdentB6==(cAliasSB6)->B6_IDENT ) .And.;
				cCod == (cAliasSB6)->B6_PRODUTO

			If  !lQuery
				If (cAliasSB6)->(FieldPos("B6_IDENTB6"))<>0 .And. !Empty((cAliasSB6)->B6_IDENTB6)
					DbSelectArea(cAliasSB6)
					DbSkip()
					Loop
				EndIf
				DbSelectArea("SF4")
				dbSetOrder(1)
				DbSeek(xFilial()+(cAliasSB6)->B6_TES)
				//-- Condicao para DBFCDX deve ser o inverso do SQL, ja que indica registros a serem
				//-- desconsiderados, ao contrario do SQL que indica registros a serem considerados
				If cTesB6 <= "500"
					If (cTipo == "B" .And. (cAliasSB6)->B6_TPCF != "C") .Or. (cTipo == "N" .And. (cAliasSB6)->B6_TPCF != "F")
						DbSelectArea(cAliasSB6)
						DbSkip()
						Loop
					EndIf
				Else
					If (cTipo == "B" .And. (cAliasSB6)->B6_TPCF != "F") .Or. (cTipo == "N" .And. (cAliasSB6)->B6_TPCF != "C")
						DbSelectArea(cAliasSB6)
						DbSkip()
						Loop
					EndIf
				EndIf
				//-- Condicao para DBF deve ser o inverso do SQL, ja que indica registros a serem
				//-- desconsiderados, ao contrario do SQL que indica registros a serem considerados
				//-- Consiste Data Inicial e Final na Composi‡Æo do Saldo
				If (lConsIni.And.(cAliasSB6)->B6_DTDIGIT<dDtIni).Or.(lConsFim.And.(cAliasSB6)->B6_DTDIGIT>dDtFim)
					DbSelectArea(cAliasSB6)
					DbSkip()
					Loop
				EndIf
			EndIf
			If (cAliasSF4)->F4_PODER3 == "R"
				aSaldo[1]+= (cAliasSB6)->B6_QUANT
				aSaldo[2]+= (cAliasSB6)->B6_QULIB

				If l103
					aSaldo[3]+= ((cAliasSB6)->B6_PRUNIT*(cAliasSB6)->B6_QUANT)-aSaldo[4]
				Else
					aSaldo[3]+= ((cAliasSB6)->B6_PRUNIT*IIF((cAliasSB6)->B6_QUANT==0,1,aSaldo[1]))
				EndIf

				#IFNDEF TOP
					If (cAliasSB6)->(FieldPos("B6_IDENTB6"))<>0
						nRegSB6 := (cAliasSB6)->(RecNo())
						cCompB6 := (cAliasSB6)->B6_IDENT
						If (cAliasSB6)->B6_QUANT == 0
							aSaldo[5]+= (cAliasSB6)->B6_PRUNIT
						Else
							aSaldo[5]+= (cAliasSB6)->B6_PRUNIT * (cAliasSB6)->B6_QUANT
							aSaldo[6]= (cAliasSB6)->B6_QUANT
						EndIf

						(cAliasSB6)->(dbSetOrder(4))
						If (cAliasSB6)->(MsSeek(xFilial("SB6")+cCompB6+cCod+"R"))
							While !Eof() .And. xFilial("SB6") == (cAliasSB6)->B6_FILIAL .And.;
									cCompB6 == (cAliasSB6)->B6_IDENTB6 .And.;
									"R" == (cAliasSB6)->B6_PODER3

								aSaldo[3]+= (cAliasSB6)->B6_PRUNIT
								dbSelectArea(cAliasSB6)
								dbSkip()
							EndDo
						EndIf
						(cAliasSB6)->(MsGoto(nRegSB6))
					EndIf
				#ELSE
					If (cAliasSB6)->B6_QUANT == 0
						aSaldo[5]+= (cAliasSB6)->B6_PRUNIT
					Else
						aSaldo[5]+= (cAliasSB6)->B6_PRUNIT * (cAliasSB6)->B6_QUANT
						aSaldo[6]= (cAliasSB6)->B6_QUANT
					EndIf
				#ENDIF
			ElseIf (cAliasSF4)->F4_PODER3 == "D"
				aSaldo[1]-= (cAliasSB6)->B6_QUANT

				SD1->(dbSetOrder(1))
				SD1->(dbSeek(xFilial("SD1")+(cAliasSB6)->B6_DOC+(cAliasSB6)->B6_SERIE+(cAliasSB6)->B6_CLIFOR+(cAliasSB6)->B6_LOJA+(cAliasSB6)->B6_PRODUTO))
				While !Eof() .And. xFilial("SD1") == SD1->D1_FILIAL .And.;
						(cAliasSB6)->B6_DOC == SD1->D1_DOC .And.;
						(cAliasSB6)->B6_SERIE == SD1->D1_SERIE .And.;
						(cAliasSB6)->B6_CLIFOR == SD1->D1_FORNECE .And.;
						(cAliasSB6)->B6_LOJA == SD1->D1_LOJA .And.;
						(cAliasSB6)->B6_PRODUTO == SD1->D1_COD

					// Verifica se o Item já não está somado para não duplicar a soma //
					cNF:= SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD+SD1->D1_ITEM
					If (cAliasSB6)->B6_IDENT==SD1->D1_IDENTB6
						If Ascan(aNF,cNF) = 0
							aSaldo[4]+= (SD1->D1_TOTAL - SD1->D1_VALDESC)
							aadd(aNF,cNF)
						EndIf
					EndIf

					SD1->(dbSkip())
				EndDo
			EndIf
			DbSelectArea(cAliasSB6)
			DbSkip()
		EndDo
		#IFDEF TOP
			dbSelectArea(cAliasSB6)
			dbCloseArea()
			dbSelectArea("SB6")
		#ELSE
			dbSelectArea("SB6")
			If !Empty(cFilterB6)
				Set Filter to &(cFilterB6)
			EndIf
		#ENDIF
	EndIf
//
// Calculo do valor unitario
//
	aSaldo[3] := A410Arred(If(aSaldo[1]==0,aSaldo[3],Round(aSaldo[3]/aSaldo[1],TamSX3("D2_PRCVEN")[2])),"D2_PRCVEN")

	RestArea(aArqSF4)
	RestArea(aArqSB6)
	RestArea(aArq)
Return(aSaldo)
