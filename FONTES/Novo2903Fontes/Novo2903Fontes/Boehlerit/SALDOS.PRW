#INCLUDE 'MATR240.CH'
//#Include 'FIVEWIN.Ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MATR240  ³ Autor ³ Eveli Morasco         ³ Data ³ 25/02/93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Saldos em Estoques                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Rodrigo Sart.³07/08/98³16964A³Acerto na filtragem dos almoxarifados   ³±±
±±³ Fernando Joly³23/10/98³15013A³Acerto na filtragem de Filiais          ³±±
±±³ Fernando Joly³03/12/98³XXXXXX³S¢ imprimir "Total do Produto" quando   ³±±
±±³              ³        ³      ³houver mais de 1 produto.               ³±±
±±³ Fernando Joly³21/12/98³18920A³Possibilitar filtragem pelo usuario.    ³±±
±±³ Cesar Valadao³30/03/99³XXXXXX³Manutencao na SetPrint()                ³±±
±±³ Aline        ³27/04/99³21147 ³Considerar o NewHead do Titulo          ³±±
±±³ Cesar Valadao³28/04/99³17188A³Inclusao da Pergunta - Descricao Produto³±±
±±³              ³        ³      ³Descricao Cientifica ou Generica.       ³±±
±±³ Cesar Valadao³08/12/99³25510A³Erro na Totalizacao de Produto Por      ³±±
±±³              ³        ³      ³Almoxarifado com Saldo Zerado.          ³±±
±±³ Patricia Sal.³11/07/00³005086³Acerto Salto de linha (P/ Almoxarifado) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcos Hirakaw³21/05/04³XXXXXX³Imprimir B1_CODITE quando for gestao de ³±±
±±³              ³        ³      ³Concessionarias ( MV_VEICULO = "S")     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function Saldos

Local Tamanho    := 'M'
Local Titulo     := STR0001 // 'Saldos em Estoque'
Local cDesc1     := STR0002 // "Este programa ira' emitir um resumo dos saldos, em quantidade,"
Local cDesc2     := STR0003 // 'dos produtos em estoque.'
Local cDesc3     := ''
Local cString    := 'SB1'
Local aOrd       := {OemToAnsi(STR0004)} //,OemToAnsi(STR0005),OemToAnsi(STR0006),OemToAnsi(STR0007)} // ' Por Codigo         '###' Por Tipo           '###' Por Descricao    '###' Por Grupo        '
Local WnRel      := 'SALDOS'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis tipo Local para SIGAVEI, SIGAPEC e SIGAOFI         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea1	:= Getarea() 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis tipo Private para SIGAVEI, SIGAPEC e SIGAOFI       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lVEIC   := UPPER(GETMV("MV_VEICULO"))=="S"
Private aSB1Cod := {}
Private aSB1Ite := {}
Private nCOL1	 := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis tipo Private padrao de todos os relatorios         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aReturn  := {OemToAnsi(STR0008), 1,OemToAnsi(STR0009), 2, 2, 1, '',1 } // 'Zebrado'###'Administracao'
Private nLastKey := 0
cPerg    := PadR( 'SALDOS' , Len( SX1->X1_GRUPO ) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria a Pergunta Nova no Sx1                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PutSx1(cPerg,"18","QTDE. na 2a. U.M. ?","CTD. EN 2a. U.M. ?","QTTY. in 2a. U.M. ?", "mv_chi", "N", 1, 0, 2,"C", "", "", "", "","MV_PAR18","Sim","Si","Yes", "","Nao","No","No", "", "", "", "", "", "", "", "", "", "", "", "", "")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                                  ³
//³ mv_par01     // Aglutina por: Almoxarifado / Filial / Empresa         ³
//³ mv_par02     // Filial de                                             ³
//³ mv_par03     // Filial ate                                            ³
//³ mv_par04     // Almoxarifado de                                       ³
//³ mv_par05     // Almoxarifado ate                                      ³
//³ mv_par06     // Produto de                                            ³
//³ mv_par07     // Produto ate                                           ³
//³ mv_par08     // tipo de                                               ³
//³ mv_par09     // tipo ate                                              ³
//³ mv_par10     // grupo de                                              ³
//³ mv_par11     // grupo ate                                             ³
//³ mv_par12     // descricao de                                          ³
//³ mv_par13     // descricao ate                                         ³
//³ mv_par14     // imprime qtde zeradas                                  ³
//³ mv_par15     // Saldo a considerar : Atual / Fechamento / Movimento   ³
//³ mv_par16     // Lista Somente Saldos Negativos                 		  ³
//³ mv_par17     // Descricao Produto : Cientifica / Generica      		  ³
//³ mv_par18   	 // QTDE. na 2a. U.M. ?     (Sim/Nao)                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajustar o SX1 para SIGAVEI, SIGAPEC e SIGAOFI                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aSB1Cod	:= TAMSX3("B1_COD")
aSB1Ite	:= TAMSX3("B1_CODITE")

Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WnRel := SetPrint(cString,WnRel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)

If mv_par18 == 1
   Tamanho := "P"
Endif 

If nLastKey == 27
	DBSELECTAREA(cString)
	dbClearFilter()
	Return Nil
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	DBSELECTAREA(cString)
	dbClearFilter()
	Return Nil
Endif

RptStatus({|lEnd| C240Imp(aOrd,@lEnd,WnRel,Titulo,Tamanho)},Titulo)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ C240IMP  ³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 11.12.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR240													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C240Imp(aOrd,lEnd,WnRel,Titulo,Tamanho)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cRodaTxt   := 'REG(S)'
Local nCntImpr   := 0
Local nTipo      := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis locais exclusivas deste programa                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lImpr      :=.F.
Local nSoma      := 0
Local nTotSoma   := 0
Local nX         := 0
Local nRegM0     := 0
Local nIndB1     := 0
Local nIndB2     := 0
Local nQtdProd   := 0
Local aSalProd   := {}
Local cFilialDe  := ''
Local cQuebra1   := ''
Local cCampo     := ''
Local cMens      := ''
Local aProd      := {}
Local aProd1     := {}
Local aArea
Local cFilOld    := 'úú'
Local cCodAnt    := 'úú'
Local cDesc 
Local lIsCient
Local cPict
Local nQtdBlq    := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais utilizadas na montagem das Querys           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cQuery     := ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajustar variaveis LOCAIS para SIGAVEI, SIGAPEC e SIGAOFI     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cCodite    := ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajustar variaveis PRIVATE para SIGAVEI, SIGAPEC e SIGAOFI    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE XSB1			:= XFILIAL('SB1')
PRIVATE XSB2			:= XFILIAL('SB2')
PRIVATE XSB5			:= XFILIAL('SB5')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Private utilizadas na montagem das Querys          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cAliasTOP  := ''

// Fernando 09/11/99 
If ( cPaisLoc=="CHI" )
	Tamanho := 'M'
	cPict   := "@E 999,999,999.99"
Else          
	cPict:= PesqPictQt(If(mv_par15==1,'B2_QATU','B2_QFIM'),15)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Private exclusivas deste programa                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cQuebra2   := ''
Private cCond2     := ''
Private cFiltroB1  := ''
Private cIndB1     := ''
Private aFiliais   := {}
Private cFiltroB2  := ''
Private cIndB2     := ''
Private lContinua  := .T.
Private cNomArqB1  := ''
Private cNomArqB2  := ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Contadores de linha e pagina                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private Li         := 80
Private m_pag      := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa os codigos de caracter Comprimido/Normal da impressora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona a ordem escolhida ao Titulo do relatorio          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type('NewHead') # 'U'
	NewHead := AllTrim(NewHead)
	NewHead += ' (' + AllTrim(SubStr(aOrd[aReturn[8]],6,20)) + ')'
Else
	Titulo := AllTrim(Titulo)
	Titulo += ' (' + AllTrim(SubStr(aOrd[aReturn[8]],6,20)) + ')'
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os Cabecalhos                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCabec1 := If(mv_par18<>1,'CODIGO LMT                                             DENOMINACAO                                       UM FL ALM   QUANTIDADE  ',OemToAnsi(STR0020)) // 'CODIGO          TP GRUP DESCRICAO                      UM FL ALM   QUANTIDADE  '
cCabec2 := ''
							 //-- 123456789012345 12 1234 123456789012345678901234567890 12 12 12 999,999,999.99
							 //-- 0         1         2         3         4         5         6         7
							 //-- 012345678901234567890123456789012345678901234567890123456789012345678901234567890

if lVEIC
   cCabec1 := substr(cCabec1,1,aSB1Cod[1]) + SPACE(nCOL1) + substr(cCabec1,aSB1Cod[1]+1)
   if !Empty(cCabec2)
	   cCabec2 := substr(cCabec2,1,aSB1Cod[1]) + SPACE(nCOL1) + substr(cCabec2,aSB1Cod[1]+1)
	endif
endif


//-- Alimenta Array com Filiais a serem Pesquizadas
aFiliais := {}
nRegM0   := SM0->(Recno())
SM0->(DBSeek(cEmpAnt, .T.))
Do While !SM0->(Eof()) .And. SM0->M0_CODIGO == cEmpAnt
	If SM0->M0_CODFIL >= mv_par02 .And. SM0->M0_CODFIL <= mv_par03
		aAdd(aFiliais, SM0->M0_CODFIL)
	Endif
	SM0->(dbSkip())
End
SM0->(dbGoto(nRegM0))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processos de Inicia‡„o dos Arquivos Utilizados               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//-- SB2 (Saldos em Estoque)
	dbSelectArea('SB2')
	dbSetOrder(1)
	
	if ! lVEIC 	// Filtro para SIGAVEI, SIGAPEC e SIGAOFI
	
		cFiltroB2 := 'B2_COD>="'+mv_par06+'".And.B2_COD<="'+mv_par07+'".And.'
		cFiltroB2 += 'B2_LOCAL>="'+mv_par04+'".And.B2_LOCAL<="'+mv_par05+'"'
		If !Empty(xSB2)
			cFiltroB2 += '.And.B2_FILIAL>="'+mv_par02+'".And.B2_FILIAL<="'+mv_par03+'"'
		EndIf
	
	else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Filtro para SIGAVEI, SIGAPEC e SIGAOFI                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   // nao precisa do filtro para B2_COD nos SIGAVEI, SIGAPEC e SIGAOFI!
		// cFiltroB2 := 'B2_COD>="'+mv_par06+'".And.B2_COD<="'+mv_par07+'".And.'
		cFiltroB2 := 'B2_LOCAL>="'+mv_par04+'".And.B2_LOCAL<="'+mv_par05+'"'
		If !Empty(xSB2)
			cFiltroB2 += '.And.B2_FILIAL>="'+mv_par02+'".And.B2_FILIAL<="'+mv_par03+'"'
		EndIf
	EndIf
	
	If mv_par01 == 3
		cIndB2 := 'B2_CODLMT + B2_FILIAL + B2_LOCAL'
	ElseIf mv_par01 == 2
		cIndB2 := 'B2_FILIAL + B2_CODLMT + B2_LOCAL'
	Else
		cIndB2 := 'B2_CODLMT + B2_FILIAL + B2_LOCAL'
	EndIf	
/*	
	cNomArqB2 := CriaTrab('',.F.)
	IndRegua('SB2',cNomArqB2,cIndB2,,cFiltroB2,STR0015) //'Selecionando Registros...'
	nIndB2 := RetIndex('SB2')
	dbSetIndex(cNomArqB2 + OrdBagExt())
	dbSetOrder(nIndB2 + 1)
	dbGoTop()
*/	   
/*
cIndice2 := CriaTrab("",.F.)
IndRegua("SB2",cIndice2,cIndB2,,cFiltroB2,"Selecionando Registros")
cIndTrab := SubStr(cIndice2,1,7)+"A"
nIndex := RetIndex("SB2")
#IFNDEF TOP
	dbSetIndex(cIndice2+OrdBagExt())
#ENDIF
dbSetOrder(nIndex+1)
*/	
	

	//-- SB1 (Produtos)
	dbSelectArea('SB1')
	dbSetOrder(aReturn[8]+8)

	if lVEIC 	// Filtro para SIGAVEI, SIGAPEC e SIGAOFI

		cFiltroB1 := 'B1_CODITE>="'+mv_par06+'".And.B1_CODITE<="'+mv_par07+'".And.'
		cFiltroB1 += 'B1_TIPO>="'+mv_par08+'".And.B1_TIPO<="'+mv_par09+'".And.'
		cFiltroB1 += 'B1_GRUPO>="'+mv_par10+'".And.B1_GRUPO<="'+mv_par11+'"'
		If !Empty(xSB1)
			cFiltroB1 += '.And.B1_FILIAL>="'+mv_par02+'".And.B1_FILIAL<="'+mv_par03+'"'
		EndIf
   	
		If aReturn[8] == 4
			cIndB1 := 'B1_GRUPO+B1_CODITE+B1_FILIAL'
			cCampo := 'B1_GRUPO'
			cMens  := OemToAnsi(STR0012) // 'Grupo.........'
		ElseIf aReturn[8] == 3
			cIndB1 := 'B1_DESC+B1_CODITE+B1_FILIAL'
			cCampo := .T.
		ElseIf aReturn[8] == 2
			cIndB1 := 'B1_TIPO+B1_CODITE+B1_FILIAL'
			cCampo := 'B1_TIPO'
			cMens  := OemToAnsi(STR0011) // 'Tipo..........'
		Else
			cIndB1 := 'B1_CODITE+B1_FILIAL'
			cCampo := .T.
		Endif

	ELSE

		cFiltroB1 := 'B1_CODLMT>=Trim("'+mv_par06+'").And.B1_CODLMT<=Trim("'+mv_par07+'").And.'
		cFiltroB1 += 'B1_TIPO>="'+mv_par08+'".And.B1_TIPO<="'+mv_par09+'".And.'
		cFiltroB1 += 'B1_GRUPO>="'+mv_par10+'".And.B1_GRUPO<="'+mv_par11+'"'
		If !Empty(xSB1)
			cFiltroB1 += '.And.B1_FILIAL>="'+mv_par02+'".And.B1_FILIAL<="'+mv_par03+'"'
		EndIf
	
		If aReturn[8] == 4
			cIndB1 := 'B1_GRUPO+B1_CODLMT+B1_FILIAL'
			cCampo := 'B1_GRUPO'
			cMens  := OemToAnsi(STR0012) // 'Grupo.........'
		ElseIf aReturn[8] == 3
			cIndB1 := 'B1_DESC+B1_CODLMT+B1_FILIAL'
			cCampo := .T.
		ElseIf aReturn[8] == 2
			cIndB1 := 'B1_TIPO+B1_CODLMT+B1_FILIAL'
			cCampo := 'B1_TIPO'
			cMens  := OemToAnsi(STR0011) // 'Tipo..........'
		Else
			cIndB1 := 'B1_CODLMT+B1_FILIAL'
			cCampo := .T.
		Endif
	
	endif
/*	
	cNomArqB1 := CriaTrab('',.F.)
	IndRegua('SB1',cNomArqB1,cIndB1,,cFiltroB1,STR0015) //'Selecionando Registros...'
	nIndB1 := RetIndex('SB1')
	dbSetIndex(cNomArqB1 + OrdBagExt())
	dbSetOrder(nIndB1 + 1)
*/	
cIndice1 := CriaTrab("",.F.)
IndRegua("SB1",cIndice1,cIndB1,,cFiltroB1,"Selecionando Registros")
cIndTrab := SubStr(cIndice1,1,7)+"A"
nIndex := RetIndex("SB1")
#IFNDEF TOP
	dbSetIndex(cIndice1+OrdBagExt())
#ENDIF
dbSetOrder(nIndex+1)
	
	
	
	dbGoTop()
	SetRegua(LastRec())

	cFilialDe := If(Empty(xSB2),xSB2,mv_par02)
	
	If aReturn[8] == 4
		DBSeek(mv_par10, .T.)
	ElseIf aReturn[8] == 3
		//-- Pesquisa Somente se a Descricao For Generica.
		If mv_par17 == 2
			DBSeek(mv_par12, .T.)
		Endif
	ElseIf aReturn[8] == 2
		DBSeek(mv_par08, .T.)
	Else
		DBSeek(mv_par06, .T.)
	Endif
	
	//-- 1§ Looping no Arquivo Principal (SB1)
	Do While !SB1->(Eof()) .and. lContinua
	
		aProd  := {}
		aProd1 := {}
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se imprime nome cientifico do produto. Se Sim    ³
		//³ verifica se existe registro no SB5 e se nao esta vazio    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cDesc := SB1->B1_DESC
		lIsCient := .F.
		If mv_par17 == 1
			dbSelectArea("SB5")
			DBSeek(xSB5 + SB1->B1_COD)
			If Found() .and. !Empty(B5_CEME)
				cDesc := B5_CEME
				lIsCient := .T.
			EndIf
			dbSelectArea('SB1')
		Endif
		
		//-- Consiste Descri‡Æo De/At‚
		If cDesc < mv_par12 .Or. cDesc > mv_par13
			SB1->(dbSkip())
			Loop
		EndIf
		
		//-- Filtro do usuario
		If !Empty(aReturn[7]) .And. !&(aReturn[7])
			SB1->(dbSkip())
			Loop
		EndIf
			
		If lEnd
			@ PROW()+1, 001 pSay OemToAnsi(STR0013) // 'CANCELADO PELO OPERADOR'
			Exit
		EndIf
		
		cQuebra1 := If(aReturn[8]==1.Or.aReturn[8]==3,.T.,&(cCampo))
		
		//-- 2§ Looping no Arquivo Principal (SB1)
		Do While !SB1->(Eof()) .And. (cQuebra1 == If(aReturn[8]==1.Or.aReturn[8]==3,.T.,&(cCampo))) .And. lContinua
	
			//-- Incrementa R‚gua
			IncRegua()
	
			lImpr := .F.
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se imprime nome cientifico do produto. Se Sim    ³
			//³ verifica se existe registro no SB5 e se nao esta vazio    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cDesc := SB1->B1_DESC
			lIsCient := .F.
			If mv_par17 == 1
				dbSelectArea("SB5")
				DBSeek(xSB5 + SB1->B1_COD)
				If Found() .and. !Empty(B5_CEME)
					cDesc := B5_CEME
					lIsCient := .T.
				EndIf
				dbSelectArea('SB1')
			Endif
			
			//-- Consiste Descri‡Æo De/At‚
			If cDesc < mv_par12 .Or. cDesc > mv_par13
				SB1->(dbSkip())
				Loop
			EndIf
			
			//-- Filtro do usuario
			If !Empty(aReturn[7]) .And. !&(aReturn[7])
				SB1->(dbSkip())
				Loop
			EndIf
	
			For nX := 1 to Len(aFiliais)
				
				IF !lContinua
					Exit
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Localiza produto no Cadastro de ACUMULADOS DO ESTOQUE        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea('SB2')
				dbSetOrder(3)
				If mv_par01 == 3
					DBSeek(xSB2+SB1->B1_CODLMT + If(Empty(xSB2),xSB2,aFiliais[nX]), .T.)
				ElseIf mv_par01 == 2
					DBSeek(xSB2+ SB1->B1_CODLMT, .T.)
				Else
					DBSeek(xSB2+SB1->B1_CODLMT + If(Empty(xSB2),xSB2,aFiliais[nX]) + mv_par04, .T.)
				EndIf
				
				//-- 1§ Looping no Arquivo Secund rio (SB2)
				Do While lContinua .And. !SB2->(Eof()) .And. B2_CODLMT == SB1->B1_CODLMT
				
					If mv_par01 == 3
						If Empty(xSB1)
							cQuebra2  := B2_CODLMT
							cCond2	 := 'B2_CODLMT == cQuebra2'
						Else
							cQuebra2  := B2_CODLMT + B2_FILIAL
							cCond2	 := 'B2_CODLMT + B2_FILIAL == cQuebra2'
						EndIf	
					ElseIf mv_par01 == 2
						cQuebra2 := B2_FILIAL + B2_CODLMT
						cCond2   := 'B2_FILIAL + B2_CODLMT == cQuebra2'					
					Else
						cQuebra2 := B2_CODLMT + B2_FILIAL + B2_LOCAL
						cCond2   := 'B2_CODLMT + B2_FILIAL + B2_LOCAL == cQuebra2'
					EndIf
					
					//-- NÆo deixa o mesmo Filial/Produto passar mais de 1 vez
					If Len(aProd) <= 4096
						If Len(aProd) == 0 .Or. Len(aProd[Len(aProd)]) == 4096
							aAdd(aProd, {})
						EndIf
						If aScan(aProd[Len(aProd)], cQuebra2) > 0
							SB2->(dbSkip())
							Loop
						Else
							aAdd(aProd[Len(aProd)], cQuebra2)
						EndIf
					Else
						If Len(aProd1) == 0 .Or. Len(aProd1[Len(aProd1)]) == 4096
							aAdd(aProd1, {})
						EndIf
						If aScan(aProd1[Len(aProd1)], cQuebra2) > 0
							SB2->(dbSkip())
							Loop
						Else
							aAdd(aProd1[Len(aProd1)], cQuebra2)
						EndIf					
					EndIf
	
					//-- 2§ Looping no Arquivo Secund rio (SB2)
					Do While lContinua .And. !SB2->(Eof()) .And. &(cCond2)
	
						If aReturn[8] == 2 //-- Tipo
							If SB1->B1_TIPO # fContSB1(SB2->B2_FILIAL, SB2->B2_CODLMT, 'B1_TIPO')
								SB2->(dbSkip())
								Loop
							EndIf
						ElseIf aReturn[8] == 4 //-- Grupo
							If SB1->B1_GRUPO # fContSB1(SB2->B2_FILIAL, SB2->B2_CODLMT, 'B1_GRUPO')
								SB2->(dbSkip())
								Loop
							EndIf
						EndIf
		
						If !Empty(SB2->B2_FILIAL)
							//-- Posiciona o SM0 na Filial Correta
							If SM0->(DBSeek(cEmpAnt+SB2->B2_FILIAL, .F.))
								//-- Atualiza a Variavel utilizada pela fun‡Æo xFilial()
								If !(cFilAnt==SM0->M0_CODFIL)
									cFilAnt := SM0->M0_CODFIL
								EndIf	
							EndIf
						EndIf
	
						If lEnd
							@ PROW()+1, 001 pSay OemToAnsi(STR0013) // 'CANCELADO PELO OPERADOR'
							lContinua := .F.
							Exit
						EndIf
	
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Carrega array com dados do produto na data base.             ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						IF mv_par15 > 2
							//-- Verifica se o SM0 esta posicionado na Filial Correta
							If !Empty(SB2->B2_FILIAL) .And. !(cFilAnt==SB2->B2_FILIAL)
								aSalProd := {0,0,0,0,0,0,0}
							Else
								aSalProd := CalcEst(SB2->B2_COD,SB2->B2_LOCAL,dDataBase+1)
							EndIf	
						Else
							aSalProd := {0,0,0,0,0,0,0}
						Endif
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se devera ser impressa o produto zerado             ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If If(mv_par15==1,B2_QATU,If(mv_par15==2,B2_QFIM,aSalProd[1])) == 0 .And. mv_par14 == 2 .Or. ;
						   If(mv_par15==1,B2_QATU,If(mv_par15==2,B2_QFIM,aSalProd[1])) > 0 .And. mv_par16 == 1 .OR.  ; 
						   If(mv_par15==1,B2_QATU,If(mv_par15==2,B2_QFIM,aSalProd[1])) < 0 .And. mv_par16 == 2 .OR. ;
						   B2_LOCAL < mv_par04 .or. B2_LOCAL > mv_par05
							cCodAnt := SB2->B2_CODLMT
							cCodAnt2:= SB2->B2_COD
							SB2->(dbSkip())
							If mv_par01 == 1 .And. SB2->B2_CODLMT # cCodAnt .And. (If(mv_par15==1,B2_QATU,If(mv_par15==2,B2_QFIM,aSalProd[1])) <> 0 .And. mv_par14 == 2)
								If nQtdProd > 1
									lImpr := .T.
								Else
									nSoma    := 0
									nQtdProd := 0
								EndIf
							EndIf
							Loop
						EndIf
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Adiciona 1 ao contador de registros impressos         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If mv_par01 == 1
						
							If Li > 55
								Cabec(Titulo,cCabec1,cCabec2,WnRel,Tamanho,nTipo)
							EndIf
						
							if lVEIC
								@ Li, 00 pSay SB1->B1_CODITE + " " + SB1->B1_COD
							ELSE              
								IF tRIM(SB1->B1_CODLMT) == SB1->B1_DENOM
									@ Li, 00 pSay B2_CODLMT
								Else
									@ Li, 00 pSay B2_CODLMT + " " + SB1->B1_DENOM
								Endif
							Endif

//							@ Li, 16 + nCOL1 pSay fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_TIPO')
//							@ Li, 19 + nCOL1 pSay fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_GRUPO')
//							@ Li, 24 + nCOL1 pSay Left(If(lIsCient, cDesc,	fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_DESC')),30)
							@ Li, 55 + 50 + nCOL1 pSay fContSB1(SB2->B2_FILIAL, SB2->B2_CODLMT, 'B1_UM')
							@ Li, 58 + 50 + nCOL1 pSay B2_FILIAL
							@ Li, 61 + 50 + nCOL1 pSay B2_LOCAL
							@ Li, 63 + 50 + nCOL1 pSay Transform( If(mv_par15==1,B2_QATU,If(mv_par15==2,B2_QFIM,aSalProd[1])), cPict)
							If mv_par18 == 1
                               @ Li, 81 + nCOL1 pSay fContSB1(SB2->B2_FILIAL, SB2->B2_CODLMT, 'B1_SEGUM')
   							   @ Li, 84 + nCOL1 pSay Transform( If(mv_par15==1,ConvUm(B2_COD,B2_QATU,0,2),If(mv_par15==2,ConvUm(B2_COD,B2_QFIM,0,2),ConvUm(B2_COD,aSalProd[1],0,2))), cPict)
						 	   @ Li, 99 + nCOL1 pSay SubStr(If(SubStr(B2_STATUS,1,1)$"2",STR0019,STR0018),1,1)
						 	Else   
					 	       @ Li, 79 + 50 + nCOL1 pSay SubStr(If(SubStr(B2_STATUS,1,1)$"2",STR0019,STR0018),1,1)
						    Endif
							Li++
							nQtdProd ++
							If SubStr(B2_STATUS,1,1) $ "2"
	 							nQtdBlq += If(mv_par15==1,B2_QATU,If(mv_par15==2,B2_QFIM,aSalProd[1]))
	 						EndIf
						EndIf
						         
					    nSoma    += If(mv_par15==1,B2_QATU,If(mv_par15==2,B2_QFIM,aSalProd[1]))
						nTotSoma += If(mv_par15==1,B2_QATU,If(mv_par15==2,B2_QFIM,aSalProd[1]))
						
						cFilOld := SB2->B2_FILIAL
						cCodAnt := SB2->B2_CODLMT
						cCodAnt2:= SB2->B2_COD	
						SB2->(dbSkip())
						
					EndDo
					
					If !(mv_par01 # 1 .And. (nSoma == 0 .And. mv_par14 == 2) .Or. (nSoma >= 0  .And. mv_par16 == 1) .oR. (nSoma < 0  .And. mv_par16 == 2))
						lImpr:=.T.
					EndIf
					
					If lImpr	
						If Li > 55
							Cabec(Titulo,cCabec1,cCabec2,WnRel,Tamanho,nTipo)
						EndIf
	
						If mv_par01 == 1
							If SB2->B2_CODLMT # cCodAnt .And. ;
								(aReturn[8] # 2 .And. aReturn[8] # 4)
								If nQtdProd > 1
									@ Li, 24 + nCOL1 pSay "(" + SubStr(STR0018,1,1)+ ") = " + OemToAnsi(STR0017) + OemToAnsi(STR0018) + Replicate('.',14)   //"Qtde. "###"Liberada  "
									@ Li, 63 + 50 + nCOL1 pSay Transform((nSoma-nQtdBlq), cPict)
									If mv_par18 == 1
									   @ Li, 84 + nCOL1 pSay Transform(ConvUm(SB1->B1_COD,(nSoma-nQtdBlq),0,2), cPict)
									Endif
									Li++
									@ Li, 24 + nCOL1 pSay "(" + SubStr(STR0019,1,1)+ ") = " + OemToAnsi(STR0017) + OemToAnsi(STR0019) + Replicate('.',14)   //"Qtde. "###"Bloqueada "
									@ Li, 63 + 50 + nCOL1 pSay Transform(nQtdBlq, cPict)
									If mv_par18 == 1
									   @ Li, 84 + nCOL1 pSay Transform(ConvUm(SB1->B1_COD,nQtdBlq,0,2), cPict)
                                    Endif
									Li++
				 					If ! lVEIC
										@ Li, 24 pSay OemToAnsi(STR0014) + Space(1) + cCodAnt // 'Total do Produto'
									Else
										@ Li, 24 pSay OemToAnsi(STR0014) + Space(1) + SB1->B1_CODITE  + " " + cCodAnt // 'Total do Produto'
									Endif
									@ Li, 63 + 50 + nCOL1 pSay Transform(nSoma, cPict)
									If mv_par18 == 1
									   @ Li, 84 + nCOL1 pSay Transform(ConvUm(SB1->B1_COD,nSoma,0,2), cPict)
									Endif
									Li += 2
									nQtdBlq := 0
								EndIf	
								nSoma    := 0
								nQtdProd := 0
							EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se devera ser impressa o produto zerado             ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						ElseIf !(nSoma == 0 .And. mv_par14 == 2) .Or. (nSoma >= 0  .And. mv_par16 == 1) .Or. (nSoma < 0  .And. mv_par16 == 2) 
							if lVEIC
								@ Li, 00 pSay SB1->B1_CODITE  + " " + SB1->B1_COD
							ELSE
								@ Li, 00 pSay cCodAnt
							ENDIF	
//							@ Li, 16 + nCOL1 pSay fContSB1(cFilOld, cCodAnt, 'B1_TIPO')
//							@ Li, 19 + nCOL1 pSay fContSB1(cFilOld, cCodAnt, 'B1_GRUPO')
//							@ Li, 24 + nCOL1 pSay Left(If(lIsCient, cDesc,	fContSB1(cFilOld, cCodAnt, 'B1_DESC')),30)
							@ Li, 55 + 50 + nCOL1 pSay fContSB1(cFilOld, cCodAnt2, 'B1_UM')
							@ Li, 58 + 50 + nCOL1 pSay If(mv_par01==2,cFilOld,'**')
							@ Li, 61 + 50 + nCOL1 pSay '**'
							@ Li, 63 + 50 + nCOL1 pSay Transform(nSoma, cPict)
							If mv_par18 == 1
                               @ Li, 81 + nCOL1 pSay fContSB1(SB2->B2_FILIAL, SB2->B2_CODLMT, 'B1_SEGUM')
							   @ Li, 84 + nCOL1 pSay Transform(ConvUm(SB1->B1_COD,nSoma,0,2), cPict)
							Endif
							Li++
							nSoma := 0
						EndIf
						
						lImpr := .F.
						
					EndIf
				EndDo
			
			Next nX
			                                      
			dbSelectArea('SB1')
			SB1->(dbSkip())
	
		EndDo
	
		If Li > 55
			Cabec(Titulo,cCabec1,cCabec2,WnRel,Tamanho,nTipo)
		EndIf
	
		If (aReturn[8] == 2 .Or. aReturn[8] == 4) .And. ;
			nTotSoma # 0
			@ Li, 40 + nCOL1 pSay STR0016 + cMens //'Total do '
			@ Li, 63 + 50 + nCOL1 pSay Transform(nTotSoma, cPict)
			If mv_par18 == 1
			   @ Li, 84 + nCOL1 pSay Transform(ConvUm(SB1->B1_COD,nTotSoma,0,2), cPict)
			Endif
			Li += 2
			nTotSoma := 0
		EndIf
	
	EndDo

If Li # 80
	Roda(nCntImpr,cRodaTxt,Tamanho)
EndIf

//-- Retorna a Posi‡Æo Correta do SM0
SM0->(dbGoto(nRegM0))
//-- Reinicializa o Conteudo da Variavel cFilAnt
If !(cFilAnt==SM0->M0_CODFIL)	
	cFilAnt := SM0->M0_CODFIL
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve as ordens originais dos arquivos                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SB2")
dbClearFilter()
RetIndex('SB2')
dbSetOrder(1)

dbSelectArea("SB1")
dbClearFilter()
RetIndex('SB1')
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga indices de trabalho                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
If File(cIndice2 += OrdBagExt())
	fErase(cIndice2)
EndIf	
*/
If File(cNomArqB1 += OrdBagExt())
	fErase(cNomArqB1)
EndIf	

If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(WnRel)
Endif

Ms_Flush()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fContSB1 ³ Autor ³ Fernando Joly Siquini ³ Data ³ 13.10.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Procura produto em SB1 e retorna o conteudo do campo       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fContSB1( cChave, cCampo)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³ cFil   = Filial de procura                                 ³±±
±±³Parƒmetros³ cCod   = Codido de procura                                 ³±±
±±³          ³ cCampo = Campo cujo conte£do se deseja retornar            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

	Static Function fContSB1(cFil, cCod, cCampo)
	
	//-- Inicializa Variaveis
	Local cCont      := &('SB1->' + cCampo)
	Local cPesq      := ''
	Local nPos       := 0
	Local nOrdem     := SB1->(IndexOrd())
	Local nRecno     := SB1->(Recno())
	
	If Empty(xSB1) .And. !Empty(cFil)
		cFil := xSB1
	EndIf
	
	cPesq := cFil + cCod
	
	If cPesq == Nil .Or. cCampo == Nil
		Return cCont
	EndIf	
		
	SB1->(dbSetOrder(9))
	If SB1->(DBSeek(cPesq, .F.)) .And. (nPos := SB1->(FieldPos(Upper(cCampo)))) > 0
		cCont := SB1->(FieldGet(nPos))
	EndIf
		
	SB1->(dbSetOrder(nOrdem))
	SB1->(dbGoto(nRecno))
	
	Return cCont

