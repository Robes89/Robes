#INCLUDE "MATR260.CH"
//#INCLUDE "FIVEWIN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR260  ³ Autor ³ Eveli Morasco         ³ Data ³ 01/03/93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Posicao dos Estoques                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo Pim.³09/12/97³09827A³Ajuste da descricao p/ 30 caracteres.     ³±±
±±³Fernando J. ³25/09/98³17720A³ Corre‡„o no Salto de Linhas.             ³±±
±±³Fernando J. ³02/12/98³18752A³A fun‡„o PesqPictQT foi substituida pela  ³±±
±±³            ³        ³      ³PesqPict.                                 ³±±
±±³Fernando J. ³21/12/98³18920A³Possibilitar filtragem pelo usuario.      ³±±
±±³Rodrigo Sart³08/02/99³META  ³Avaliacao da qtd empenhada prevista.      ³±±
±±³Cesar       ³30/03/99³XXXXXX³Manutencao na SetPrint()                  ³±±
±±³Patricia Sal³28/01/00³002121³Aumento da picture dos campos.            ³±±
±±³Jeremias    ³09.02.00³Melhor³Validacao da comparacao dos valores e da  ³±±
±±³            ³        ³      ³qtde quando do calculo do custo medio.    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function POSICAO()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local Titulo   := STR0001 //"Relacao da Posicao do Estoque"
	Local wnrel    := "POSICAO"
	Local cDesc1   := STR0002 //"Este relatorio emite a posicao dos saldos e empenhos de cada  produto"
	Local cDesc2   := STR0003       //"em estoque. Ele tambem mostrara' o saldo disponivel ,ou seja ,o saldo"
	Local cDesc3   := STR0004       //"subtraido dos empenhos."
	Local cString  := "SB1"
	Local aOrd     := {OemToAnsi(STR0005)} //,OemToAnsi(STR0006),OemToAnsi(STR0007),OemToAnsi(STR0008),OemToAnsi(STR0009)}    //" Por Codigo         "###" Por Tipo           "###" Por Descricao     "###" Por Grupo        "###" Por Almoxarifado   "
	Local lEnd     := .F.
	Local Tamanho  := "M"
	LOCAL aHelpPor:={},aHelpEng:={},aHelpSpa:={}
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
	Private nCOL1	  := 0
	Private XSB1	  := SB1->(XFILIAL("SB1"))
	Private XSB2	  := SB2->(XFILIAL("SB2"))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis tipo Private padrao de todos os relatorios         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PRIVATE aReturn  := {OemToAnsi(STR0010), 1,OemToAnsi(STR0011), 2, 2, 1, "",1 }   //"Zebrado"###"Administracao"
	PRIVATE nLastKey := 0 ,cPerg := PadR( "POSICA" , Len( SX1->X1_GRUPO ) )
	PRIVATE lCusUnif := SuperGetMV('MV_CUSFIL',.F.) //-- Identifica qdo utiliza custo por empresa

// wilson 11/07/08 na virada da 7.10 pra 8.11
// mudou a tratamento (F=Filial / E=Empresa / A=Almoxarifado)
	If	lCusUnif == "E"
		lCusUnif	:= .T.
	Else
		lCusUnif	:= .F.
	EndIf

	Ajustasx1()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                                ³
//³ mv_par01     // Aglutina por: Almoxarifado / Filial / Empresa       ³
//³ mv_par02     // Filial de       *                                   ³
//³ mv_par03     // Filial ate      *                                   ³
//³ mv_par04     // almoxarifado de *                                   ³
//³ mv_par05     // almoxarifado ate*                                   ³
//³ mv_par06     // codigo de       *                                   ³
//³ mv_par07     // codigo ate      *                                   ³
//³ mv_par08     // tipo de         *                                   ³
//³ mv_par09     // tipo ate        *                                   ³
//³ mv_par10     // grupo de        *                                   ³
//³ mv_par11     // grupo ate       *                                   ³
//³ mv_par12     // descricao de    *                                   ³
//³ mv_par13     // descricao ate   *                                   ³
//³ mv_par14     // imprime produtos: Todos /Positivos /Negativos       ³
//³ mv_par15     // Saldo a considerar : Atual / Fechamento / Movimento |
//³ mv_par16     // Qual Moeda (1 a 5)                                  ³
//³ mv_par17     // Aglutina por UM ?(S)im (N)ao                        ³
//³ mv_par18     // Lista itens zerados ? (S)im (N)ao                   ³
//³ mv_par19     // Imprimir o Valor ? Custo / Custo Std / Ult Prc Compr³
//³ mv_par20     // Data de Referencia                                  ³
//³ mv_par21     // Lista valores zerados ? (S)im (N)ao                 ³
//³ mv_par22     // QTDE na 2a. U.M. ? (S)im (N)ao                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd( aHelpPor, "Data de referencia para calculo do saldo" )
	Aadd( aHelpPor, "do produto quando utiliza saldo por     " )
	Aadd( aHelpPor, "movimento.                              " )
	Aadd( aHelpEng, "Reference date for product`s balances   " )
	Aadd( aHelpEng, "calculation, when using balance per     " )
	Aadd( aHelpEng, "transaction/movement.                   " )
	Aadd( aHelpSpa, "Fecha de referencia para calculo del    " )
	Aadd( aHelpSpa, "saldo del producto cuando usa saldo por " )
	Aadd( aHelpSpa, "movimiento.                             " )
	U_FTTVSX001( cPerg, "20","Data de Referencia  ","Data de Referencia  ","Reference Date           ","mv_chK","D",8,0,0,"G","","","","",;
		"mv_par20","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	U_FTTVSX001(cPerg,"22","QTDE. na 2a. U.M. ?","CTD. EN 2a. U.M. ?","QTTY. in 2a. U.M. ?", "mv_chm", "N", 1, 0, 2,"C", "", "", "", "","mv_par22","Sim","Si","Yes", "","Nao","No","No", "", "", "", "", "", "", "", "", "", "", "", "", "")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajustar o SX1 para SIGAVEI, SIGAPEC e SIGAOFI                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aSB1Cod	:= TAMSX3("B1_COD")
	aSB1Ite	:= TAMSX3("B1_CODITE")

	if lVEIC
		Tamanho  := "G"
		nCOL1		:= ABS(aSB1Cod[1] - aSB1Ite[1]) + 1 +  aSB1Cod[1]
		DBSELECTAREA("SX1")
		DBSETORDER(1)
		DBSEEK(cPerg)
		DO WHILE SX1->X1_GRUPO == cPerg .AND. !SX1->(EOF())
			IF "PRODU" $ UPPER(SX1->X1_PERGUNT) .AND. UPPER(SX1->X1_TIPO) == "C" .AND. ;
					(SX1->X1_TAMANHO <> aSB1Ite[1] .OR. UPPER(SX1->X1_F3) <> "VR4")

				RECLOCK("SX1",.F.)
				SX1->X1_TAMANHO := aSB1Ite[1]
				SX1->X1_F3 := "VR4"
				DBCOMMIT()
				MSUNLOCK()

			ENDIF
			DBSKIP()
		ENDDO
		DBCOMMITALL()
		RESTAREA(aArea1)
	else
		DBSELECTAREA("SX1")
		DBSETORDER(1)
		DBSEEK(cPerg)
		WHILE SX1->X1_GRUPO == cPerg .AND. !SX1->(EOF())
			IF "PRODU" $ UPPER(SX1->X1_PERGUNT) .AND. UPPER(SX1->X1_TIPO) == "C" .AND. ;
					(SX1->X1_TAMANHO <> aSB1Cod[1] .OR. UPPER(SX1->X1_F3) <> "SB1")

				RECLOCK("SX1",.F.)
				SX1->X1_TAMANHO := aSB1Cod[1]
				SX1->X1_F3 := "SB1"
				DBCOMMIT()
				MSUNLOCK()

			ENDIF
			DBSKIP()
		ENDDO
		DBCOMMITALL()
		RESTAREA(aArea1)
	endif

	pergunte(cPerg,.F.)

	If lCusUnif //-- Ajusta as perguntas para Custo Unificado
		MA260PergU()
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)

	If nLastKey = 27
		dbClearFilter()
		Return
	Endif

	If lCusUnif .And. ((mv_par01==1).Or.!(mv_par04=='**').Or.!(mv_par05=='**').Or.aReturn[8]==5) //-- Ajusta as perguntas para Custo Unificado
		If Aviso(STR0024, STR0025+CHR(10)+CHR(13)+STR0029+CHR(10)+CHR(13)+STR0026+CHR(10)+CHR(13)+STR0027+CHR(10)+CHR(13)+STR0028+CHR(10)+CHR(13)+STR0030, {STR0031,STR0032}) == 2
			dbClearFilter()
			Return Nil
		EndIf
	EndIf

	If mv_par04 == '**'
		mv_par04 := '  '
	EndIf
	If mv_par05 == '**'
		mv_par05 := 'zz'
	Endif

	SetDefault(aReturn,cString)
	If nLastKey = 27
		dbClearFilter()
		Return
	Endif

	mv_par16 := IIf( ((mv_par16 < 1) .Or. (mv_par16 > 5)),1,mv_par16 )
	Tipo     := IIF(aReturn[4]==1,15,18)

	If Type("NewHead")#"U"
		Titulo := (NewHead+" ("+AllTrim( aOrd[ aReturn[ 8 ] ] )+")")
	Else
		Titulo += " ("+AllTrim( aOrd[ aReturn[ 8 ] ] )+")"
	EndIf

	cFileTRB := ""
	RptStatus( { | lEnd | cFileTRB := r260Select( @lEnd ) },Titulo+STR0023 ) //": Preparacao..."

	If !Empty( cFileTRB )
		RptStatus({|lEnd| R260Imprime( @lEnd,cFileTRB,Titulo,wNRel,Tamanho,Tipo,aReturn[ 8 ] )},titulo)
	EndIf

Return NIL

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³R260SELECT³ Autor ³ Ben-Hur M. Castilho   ³ Data ³ 20/11/96 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Preparacao do Arquivo de Trabalho p/ Relatorio             ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ MATR260                                                    ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R260Select( lEnd )
	Local	cFileTRB	:= ""
	Local	cQuery	:= "",;
		cIndxKEY	:= "",;
		aSizeQT	:= TamSX3( "B2_QATU" ),;
		aSizeVL	:= TamSX3( "B2_VATU1"),;
		aSaldo	:= {},;
		nQuant	:= 0,;
		nValor	:= 0,;
		nQuantR	:= 0,;
		nValorR	:= 0,;
		cFilOK	:= cFilAnt,;
		cAl1		:= "SB1",;
		cAl2		:= "SB2",;
		lExcl		:= .f.,;
		dDataRef
	Local   cUM    := IIf(mv_par22 == 1,"SEGUM ","UM    ")  // Verifica se Unidade de medida e 1a. ou 2a.

	Local	aCampos	:=	{	{ "FILIAL","C",02,00 },;
		{ "CODIGO","C",15,00 },;
		{ "CODLMT","C",46,00 },;
		{ "LOCAL ","C",02,00 },;
		{ "TIPO  ","C",02,00 },;
		{ "GRUPO ","C",04,00 },;
		{ "DESCRI","C",21,00 },;
		{ cUM     ,"C",02,00 },;
		{ "VALORR","N",aSizeVL[ 1 ]+1, aSizeVL[ 2 ] },;
		{ "QUANTR","N",aSizeQT[ 1 ]+1, aSizeQT[ 2 ] },;
		{ "VALOR ","N",aSizeVL[ 1 ]+1, aSizeVL[ 2 ] },;
		{ "QUANT ","N",aSizeQT[ 1 ]+1, aSizeQT[ 2 ] } ;
		}

	Local aStruSB1	:= {}
	Local cName
	Local cQryAd	:= ""
	Local nX

	dDataRef := Iif(Empty(mv_par20),dDataBase,mv_par20)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Para SIGAVEI, SIGAPEC e SIGAOFI                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	if ! lVEIC
		If (mv_par01 == 1)
			If (aReturn[ 8 ] == 5)
				cIndxKEY := "LOCAL"
			Else
				cIndxKEY := "FILIAL"
			EndIf
			Do Case
			Case (aReturn[ 8 ] == 1)
				If (mv_par17 == 1)
					cIndxKEY += "+" + cUM
				EndIf
//			cIndxKEY += "+CODIGO+LOCAL"
				cIndxKEY += "+CODLMT+LOCAL"
			Case (aReturn[ 8 ] == 2)
				cIndxKEY += "+TIPO"
				If (mv_par17 == 1)
					cIndxKEY += "+" + cUM
				EndIf
//			cIndxKEY += "+CODIGO+LOCAL"
				cIndxKEY += "+CODLMT+LOCAL"
			Case (aReturn[ 8 ] == 3)
				If (mv_par17 == 1)
					cIndxKEY += "+" + cUM
				EndIf
//			cIndxKEY += "+DESCRI+CODIGO+LOCAL"
				cIndxKEY += "+DESCRI+CODLMT+LOCAL"
			Case (aReturn[ 8 ] == 4)
				cIndxKEY += "+GRUPO"
				If (mv_par17 == 1)
					cIndxKEY += "+" + cUM
				EndIf
//			cIndxKEY += "+CODIGO+LOCAL"
				cIndxKEY += "+CODLMT+LOCAL"
			Case (aReturn[ 8 ] == 5)
				If (mv_par17 == 1)
					cIndxKEY += "+" + cUM
				EndIf
//			cIndxKEY += "+CODIGO+FILIAL"
				cIndxKEY += "+CODLMT+FILIAL"
			OTHERWISE
				If (mv_par17 == 1)
					cIndxKEY += "+" + cUM
				EndIf
//			cIndxKEY += "+CODIGO+LOCAL"
				cIndxKEY += "+CODLMT+LOCAL"
			EndCase
		Else // 	If (mv_par01 == 1)
			If (aReturn[ 8 ] == 5)
				cIndxKEY := "LOCAL"
			Else
				cIndxKEY := ""
			EndIf

			Do Case
			Case (aReturn[ 8 ] == 1)
				If (mv_par17 == 1)
					cIndxKEY += (iif(empty(cIndxKEY),"","+")+ cUM)
				EndIf
//			cIndxKEY += (iif(empty(cIndxKEY),"","+") + "CODIGO+FILIAL+LOCAL")
				cIndxKEY += (iif(empty(cIndxKEY),"","+") + "CODLMT+FILIAL+LOCAL")
			Case (aReturn[ 8 ] == 2)
				cIndxKEY += (iif(empty(cIndxKEY),"","+") + "TIPO")
				If (mv_par17 == 1)
					cIndxKEY += (iif(empty(cIndxKEY),"","+")+ cUM)
				EndIf
//			cIndxKEY += "+CODIGO+FILIAL+LOCAL"
				cIndxKEY += "+CODLMT+FILIAL+LOCAL"
			Case (aReturn[ 8 ] == 3)
				If (mv_par17 == 1)
					cIndxKEY += (iif(empty(cIndxKEY),"","+")+ cUM)
				EndIf
//			cIndxKEY += (iif(empty(cIndxKEY),"","+") + "DESCRI+CODIGO+FILIAL+LOCAL")
				cIndxKEY += (iif(empty(cIndxKEY),"","+") + "DESCRI+CODLMT+FILIAL+LOCAL")
			Case (aReturn[ 8 ] == 4)
				cIndxKEY += (iif(empty(cIndxKEY),"","+") + "GRUPO")
				If (mv_par17 == 1)
					cIndxKEY += (iif(empty(cIndxKEY),"","+")+ cUM)
				EndIf
//			cIndxKEY += "+CODIGO+FILIAL+LOCAL"
				cIndxKEY += "+CODLMT+FILIAL+LOCAL"
			Case (aReturn[ 8 ] == 5)
				If (mv_par17 == 1)
					cIndxKEY += (iif(empty(cIndxKEY),"","+")+ cUM)
				EndIf
//			cIndxKEY += (iif(empty(cIndxKEY),"","+") + "CODIGO+FILIAL")
				cIndxKEY += (iif(empty(cIndxKEY),"","+") + "CODLMT+FILIAL")
			OTHERWISE
				If (mv_par17 == 1)
					cIndxKEY += (iif(empty(cIndxKEY),"","+")+ cUM)
				EndIf
//			cIndxKEY += (iif(empty(cIndxKEY),"","+") + "CODIGO+LOCAL")
				cIndxKEY += (iif(empty(cIndxKEY),"","+") + "CODLMT+LOCAL")
			EndCase
		EndIf
	else
		aadd(aCampos,{"CODITE","C",aSB1Ite[ 1 ],00})
		If (mv_par01 == 1) // ARMAZEN
			If (aReturn[ 8 ] == 5) // ALMOXARIFADO
				cIndxKEY := "LOCAL"
			Else
				cIndxKEY := "FILIAL"
			EndIf
			Do Case
			Case (aReturn[ 8 ] == 1)
				If (mv_par17 == 1)
					cIndxKEY += "+" + cUM
				EndIf
				cIndxKEY += "+CODITE+LOCAL"
			Case (aReturn[ 8 ] == 2)
				cIndxKEY += "+TIPO"
				If (mv_par17 == 1)
					cIndxKEY += "+" + cUM
				EndIf
				cIndxKEY += "+CODITE+LOCAL"
			Case (aReturn[ 8 ] == 3)
				If (mv_par17 == 1)
					cIndxKEY += "+" + cUM
				EndIf
				cIndxKEY += "+DESCRI+CODITE+LOCAL"
			Case (aReturn[ 8 ] == 4)
				cIndxKEY += "+GRUPO"
				If (mv_par17 == 1)
					cIndxKEY += "+" + cUM
				EndIf
				cIndxKEY += "+CODITE+LOCAL"
			Case (aReturn[ 8 ] == 5)
				If (mv_par17 == 1)
					cIndxKEY += "+" + cUM
				EndIf
				cIndxKEY += "+CODITE+FILIAL"
			OTHERWISE
				If (mv_par17 == 1)
					cIndxKEY += "+" + cUM
				EndIf
				cIndxKEY += "+CODITE+LOCAL"
			EndCase
		Else // FILIAL / EMPRESA
			If (aReturn[ 8 ] == 5) // ALMOXARIFADO
				cIndxKEY := "LOCAL"
			Else
				cIndxKEY := ""
			EndIf
			Do Case
			Case (aReturn[ 8 ] == 1) // CODIGO
				If (mv_par17 == 1)
					cIndxKEY += (iif(empty(cIndxKEY),"","+")+ cUM)
				EndIf
				cIndxKEY += (iif(empty(cIndxKEY),"","+") + "CODITE+FILIAL+LOCAL")
			Case (aReturn[ 8 ] == 2)
				cIndxKEY += (iif(empty(cIndxKEY),"","+") + "TIPO")
				If (mv_par17 == 1)
					cIndxKEY += (iif(empty(cIndxKEY),"","+")+ cUM)
				EndIf
				cIndxKEY += (iif(empty(cIndxKEY),"","+") + "CODITE+FILIAL+LOCAL")
			Case (aReturn[ 8 ] == 3)
				If (mv_par17 == 1)
					cIndxKEY += (iif(empty(cIndxKEY),"","+") + cUM)
				EndIf
				cIndxKEY += (iif(empty(cIndxKEY),"","+") + "DESCRI+CODITE+FILIAL+LOCAL")
			Case (aReturn[ 8 ] == 4)
				cIndxKEY += (iif(empty(cIndxKEY),"","+") + "GRUPO")
				If (mv_par17 == 1)
					cIndxKEY += (iif(empty(cIndxKEY),"","+") + cUM)
				EndIf
				cIndxKEY += (iif(empty(cIndxKEY),"","+") + "CODITE+FILIAL+LOCAL")
			Case (aReturn[ 8 ] == 5)
				If (mv_par17 == 1)
					cIndxKEY += (iif(empty(cIndxKEY),"","+") + cUM)
				EndIf
				cIndxKEY += (iif(empty(cIndxKEY),"","+") + "CODITE+FILIAL")
			OTHERWISE
				If (mv_par17 == 1)
					cIndxKEY += (iif(empty(cIndxKEY),"","+")+ cUM)
				EndIf
				cIndxKEY += (iif(empty(cIndxKEY),"","+") + "CODITE+LOCAL")
			EndCase
		EndIf

	Endif
	cFileTRB := 'SB2A'

	oTemptable := FWTemporaryTable():New( cFileTRB)
	oTemptable:SetFields( aCampos )
	//oTempTable:AddIndex("index1", {"COD"} )
	oTempTable:Create()

	DbSelectArea( 0 )
	//DbCreate( cFileTRB,aCampos )

	//DbUseArea( .F.,,cFileTRB,cFileTRB,.F.,.F. )
	IndRegua( cFileTRB,cFileTRB,cIndxKEY,,,OemToAnsi(STR0013))   //"Organizando Arquivo..."

	DbSelectArea( "SB2" )
	SetRegua( LastRec() )
	dbSetOrder(3)

	IF lVEIC
		dbSeek(MV_PAR02,.t.)
	else
		dbSeek(MV_PAR02+MV_PAR06,.t.)
	endif


	IF xSB2 != "  "
		lExcl := .t.
	Endif

	While !Eof()
		IF lExcl
			cFilAnt := (cAl2)->B2_FILIAL
		Endif
		IncRegua()

		If	;
				( ( (cAl2)->B2_FILIAL >= MV_PAR02 ) .And. ( (cAl2)->B2_FILIAL <= MV_PAR03 ) );
				.And. ;
				( ( (cAl2)->B2_Local  >= MV_PAR04 ) .And. ( (cAl2)->B2_Local  <= MV_PAR05 ) );
				.And. ;
				(iif( lVEIC, .T. ,( (cAl2)->B2_CODLMT >= MV_PAR06 ) .And. ( (cAl2)->B2_CODLMT <= MV_PAR07 ) ) )


			dbSelectArea( cAl1 )
			dbSetOrder(1)
			If (DbSeek( XSB1 + (cAl2)->B2_COD) )

				If (	(	((cAl1)->B1_TIPO  >= MV_PAR08 ) .And. ((cAl1)->B1_TIPO  <= MV_PAR09 ));
						.And. ;
						(	((cAl1)->B1_GRUPO >= MV_PAR10 ) .And. ((cAl1)->B1_GRUPO <= MV_PAR11 ));
						.And. ;
						(	((cAl1)->B1_DESC  >= MV_PAR12 ) .And. ((cAl1)->B1_DESC  <= MV_PAR13 ));
						.And. ;
						(	(!Empty(aReturn[7]) .And. &(aReturn[7]) ) .Or. Empty(aReturn[7]));
						)
					Do Case
					Case (mv_par15 == 1)
						nQuant := (cAl2)->B2_QATU
					Case (mv_par15 == 2)
						nQuant := (cAl2)->B2_QFIM
					OtherWise
						nQuant := (aSaldo := CalcEst( (cAl2)->B2_COD,(cAl2)->B2_LOCAL,dDataRef+1,(cAl2)->B2_FILIAL ))[ 1 ]
					EndCase


					dbSelectArea( cAl1 )
					If (	(mv_par14 == 1);
							.Or.;
							((mv_par14 == 2) .And.(nQuant >= 0));
							.Or.;
							((mv_par14 == 3) .And.(nQuant  < 0));
							)

						Do Case
						Case (mv_par15 == 1)
							nValor := (cAl2)->(FieldGet( FieldPos( "B2_VATU"+Str( mv_par16,1 ) ) ))
						Case (mv_par15 == 2)
							nValor := (cAl2)->(FieldGet( FieldPos( "B2_VFIM"+Str( mv_par16,1 ) ) ))
						Case (mv_par15 == 3)
							nValor := aSaldo[ 1+mv_par16 ]
						EndCase
						Do Case
						Case (mv_par19 == 2)
							nValor := nQuant * (cAL1)->B1_CUSTD
						Case (mv_par19 == 3)
							nValor := nQuant * (cAL1)->B1_UPRC
						EndCase

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se devera ser impresso itens zerados                ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If (mv_par18==2)  .And. (QtdComp(nQuant)==QtdComp(0))
							dbSelectArea( cAl2 )
							dbSkip()
							Loop
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se devera ser impresso valores zerados              ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If (mv_par21==2) .And. (QtdComp(nValor)==QtdComp(0))
							dbSelectArea( cAl2 )
							dbSkip()
							Loop
						EndIf

						nQuantR := (cAl2)->B2_QEMP + AvalQtdPre("SB2",1,NIL,cAl2) + (cAl2)->B2_RESERVA + (cAl2)->B2_QEMPSA
						nValorR := (QtdComp(nValor) / QtdComp(nQuant)) * QtdComp(nQuantR)

						DbSelectArea( cFileTRB )
						DbAppend()

						FIELD->FILIAL := (cAl2)->B2_FILIAL
						FIELD->CODIGO := (cAl2)->B2_COD
						FIELD->CODLMT := (cAl1)->B1_CODLMT
						FIELD->LOCAL  := (cAl2)->B2_LOCAL
						FIELD->TIPO   := (cAl1)->B1_TIPO
						FIELD->GRUPO  := (cAl1)->B1_GRUPO
						FIELD->DESCRI := (cAl1)->B1_DESC
						If mv_par22 == 1
							FIELD->SEGUM  := (cAl1)->B1_SEGUM
						Else
							FIELD->UM     := (cAl1)->B1_UM
						Endif
						FIELD->QUANTR := nQuantR
						FIELD->VALORR := nValorR
						FIELD->QUANT  := nQuant
						FIELD->VALOR  := nValor
						IF lVEIC
							FIELD->CODITE := (cAl1)->B1_CODITE
						ENDIF
					EndIf
				EndIf

			EndIf

			DbSelectArea( cAl2 )
		EndIf

		DbSkip()
	EndDo

	cFilAnt := cFilOk

	dbSelectArea("SB1")
	dbClearFilter()

Return( cFileTRB )

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³R260IMPRIM³ Autor ³ Ben-Hur M. Castilho   ³ Data ³ 20/11/96 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Preparacao do Arquivo de Trabalho p/ Relatorio             ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ MATR260                                                    ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function R260Imprime( lEnd,cFileTRB,cTitulo,wNRel,cTam,nTipo,nOrdem )

	#define DET_SIZE  13

	#define DET_CODE   1
	#define DET_TIPO   2
	#define DET_GRUP   3
	#define DET_DESC   4
	#define DET_UM     5
	#define DET_FL     6
	#define DET_ALMX   7
	#define DET_SALD   8
	#define DET_EMPN   9
	#define DET_DISP  10
	#define DET_VEST  11
	#define DET_VEMP  12
	#define DET_KEYV  13

	#define ACM_SIZE   6

	#define ACM_CODE   1
	#define ACM_SALD   2
	#define ACM_EMPN   3
	#define ACM_DISP   4
	#define ACM_VEST   5
	#define ACM_VEMP   6

	Local	aPrnDET   := nil,;
		aTotUM    := nil,;
		aTotORD   := nil,;
		aTotUM1   := nil

	Local	cLPrnCd   := ""
	Local   cprod     := ""

	Local	lPrintCAB := .F.,;
		lPrintDET := .F.,;
		lPrintTOT := .F.,;
		lPrintOUT := .F.,;
		lPrintLIN := .F.

	Local	nTotValEst:=0,;
		nTotValEmp:=0,;
		nTotValSal:=0,;
		nTotValRPR:=0,;
		nTotValRes:=0,;
		nTotValEs2:=0,;
		nTotValEm2:=0,;
		nTotValSa2:=0,;
		nTotValRP2:=0,;
		nTotValRe2:=0


	Local cPicture	:= PesqPict("SB2", If( (mv_par15 == 1),"B2_QATU","B2_QFIM" ),14 )
	Local cPicVal	:= PesqPict("SB2","B2_VATU"+Str(mv_par16,1),15)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis tipo Local para SIGAVEI, SIGAPEC e SIGAOFI         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LOCAL lT		:= .F.
	LOCAL lT1	:= .F.
	LOCAL lT2	:= .F.
	LOCAL cArm0	:= alltrim(OemToAnsi(STR0009))
	LOCAL cArm1	:= ""
	LOCAL cArm2	:= ""
	LOCAL n2		:= len(cArm0)
	LOCAL n1
	for	n1	:= n2	to	1 step -1
		cArm2	:=	substr(cArm0,n1,1)
		if cArm2 <> " "
			cArm1	:= cArm2 + cArm1
		else
			exit
		endif
	next
	n1	:= 0
	if lVeic
		n1	:= 016
	endif
	Private	Li		:= 80,;
		M_Pag := 1

	cCab01 := "CODIGO LMT                               CODIGO           SALDO       EMPENHO PARA       ESTOQUE       ____________VALOR ___________"
	cCab02 := OemToAnsi(STR0015)        //"                                                          EM ESTOQUE  REQ/PV/RESERVA   DISPONIVEL    EM ESTOQUE          EMPENHADO "
//  	                                   123456789012345 12 1234 123456789012345678901 12 12 12 999,999,999.99 999,999,999.99 9999,999,999.99 9999,999,999.99 9999,999,999.99
//      	                               0         1         2         3         4         5         6         7         8         9        10        11        12        13
//          	                           0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012

	if lVEIC
		cCab01 := substr(cCab01,1,aSB1Cod[1]) + SPACE(nCOL1) + substr(cCab01,aSB1Cod[1]+1)
		cCab02 := substr(cCab02,1,aSB1Cod[1]) + SPACE(nCOL1) + substr(cCab02,aSB1Cod[1]+1)
	endif
	DbSelectArea( cFileTRB )
	DbGoTop()
	While !Eof()

		If	(LastKey() == 286) .OR. If(lEND==Nil,.F.,lEND) .OR. lAbortPrint
			Exit
		EndIf

		If (aPrnDET == nil)

			If lVEIC
				aPrnDET := Array( DET_SIZE + 1)
				aPrnDET[ DET_CODE ] := FIELD->CODITE
				aPrnDET[ DET_SIZE + 1 ] := FIELD->CODIGO
			else
				aPrnDET := Array( DET_SIZE )
				aPrnDET[ DET_CODE ] := FIELD->CODIGO
			endif
			aPrnDET[ DET_TIPO ] := FIELD->TIPO
			aPrnDET[ DET_GRUP ] := FIELD->GRUPO
			aPrnDET[ DET_DESC ] := FIELD->DESCRI
			aPrnDET[ DET_UM   ] := If(mv_par22==1,FIELD->SEGUM,FIELD->UM)

			aPrnDET[ DET_FL   ] := ""
			aPrnDET[ DET_ALMX ] := ""
			aPrnDET[ DET_SALD ] := 0
			aPrnDET[ DET_EMPN ] := 0
			aPrnDET[ DET_DISP ] := 0
			aPrnDET[ DET_VEST ] := 0
			aPrnDET[ DET_VEMP ] := 0

			aPrnDET[ DET_KEYV ] := ""
		EndIf

		If (mv_par17 == 1) .And. (aTotUM == nil)
			aTotUM	:= { IIf(mv_par22==1,FIELD->SEGUM,FIELD->UM),0,0,0,0,0 }
		EndIf
		If (mv_par17 == 1) .And. (aTotUM1 == nil)
			aTotUM1	:= { IIf(mv_par22==1,FIELD->SEGUM,FIELD->UM)+FIELD->LOCAL,0,0,0,0,0 }
		EndIf

		If (((nOrdem == 2) .Or. (nOrdem == 4)) .And. (aTotORD == nil))

			aTotORD := { IIf( (nOrdem == 2),FIELD->TIPO,FIELD->GRUPO ),0,0,0,0,0 }
		EndIf

		Do Case
		Case (mv_par01 == 1)

			aPrnDET[ DET_FL   ] := FIELD->FILIAL
			aPrnDET[ DET_ALMX ] := FIELD->LOCAL

		Case ((mv_par01 == 2) .And. (aPrnDET[ DET_KEYV ] == ""))

			aPrnDET[ DET_FL   ] := FIELD->FILIAL
			aPrnDET[ DET_ALMX ] := IIf( (aReturn[ 8 ] == 5),FIELD->Local,"**" )

		Case ((mv_par01 == 3) .And. (aPrnDET[ DET_KEYV ] == ""))

			aPrnDET[ DET_FL   ] := "**"
			aPrnDET[ DET_ALMX ] := IIf( (aReturn[ 8 ] == 5),FIELD->Local,"**" )

		EndCase

		If aPrnDET[ DET_KEYV ] == ""
			If lVEIC
				Do Case
				Case (mv_par01 == 1)
					If (aReturn[ 8 ] == 5)
						// aPrnDET[ DET_KEYV ] := FIELD->LOCAL+FIELD->CODITE+FIELD->FILIAL
						If (mv_par17 == 1)
							aPrnDET[ DET_KEYV ] := FIELD->LOCAL+IIf(mv_par22==1,FIELD->SEGUM,FIELD->UM)+FIELD->CODITE+FIELD->FILIAL
						ELSE
							aPrnDET[ DET_KEYV ] := FIELD->LOCAL+FIELD->CODITE+FIELD->FILIAL
						ENDIF
					Else
						If (mv_par17 == 1)
							aPrnDET[ DET_KEYV ] := IIf(mv_par22==1,FIELD->SEGUM,FIELD->UM)+FIELD->CODITE+FIELD->FILIAL+FIELD->LOCAL
						else
							aPrnDET[ DET_KEYV ] := FIELD->CODITE+FIELD->FILIAL+FIELD->LOCAL
						Endif
					Endif
				Case (mv_par01 == 2)
					If (aReturn[ 8 ] == 5)
						If (mv_par17 == 1)
							aPrnDET[ DET_KEYV ] := FIELD->LOCAL+IIf(mv_par22==1,FIELD->SEGUM,FIELD->UM)+FIELD->CODITE+FIELD->FILIAL
						ELSE
							aPrnDET[ DET_KEYV ] := FIELD->LOCAL+FIELD->CODITE+FIELD->FILIAL
						ENDIF
					Else
						If (mv_par17 == 1)
							aPrnDET[ DET_KEYV ] := IIf(mv_par22==1,FIELD->SEGUM,FIELD->UM)+FIELD->CODITE+FIELD->FILIAL
						else
							aPrnDET[ DET_KEYV ] := FIELD->CODITE+FIELD->FILIAL
						Endif
					Endif
				Case (mv_par01 == 3)
					If (aReturn[ 8 ] == 5)
						If (mv_par17 == 1)
							aPrnDET[ DET_KEYV ] := FIELD->LOCAL+IIf(mv_par22==1,FIELD->SEGUM,FIELD->UM)+FIELD->CODITE
						ELSE
							aPrnDET[ DET_KEYV ] := FIELD->LOCAL+FIELD->CODITE
						ENDIF
					Else
						If (mv_par17 == 1)
							aPrnDET[ DET_KEYV ] := IIf(mv_par22==1,FIELD->SEGUM,FIELD->UM)+FIELD->CODITE
						else
							aPrnDET[ DET_KEYV ] := FIELD->CODITE
						Endif
					Endif
				EndCase
			ELSE
				Do Case
				Case (mv_par01 == 1)
					If (aReturn[ 8 ] == 5)
						If (mv_par17 == 1)
							aPrnDET[ DET_KEYV ] := FIELD->Local+IIf(mv_par22==1,FIELD->SEGUM,FIELD->UM)+FIELD->CODIGO+FIELD->FILIAL
						ELSE
							aPrnDET[ DET_KEYV ] := FIELD->Local+FIELD->CODIGO+FIELD->FILIAL
						ENDIF
					Else
						If (mv_par17 == 1)
							aPrnDET[ DET_KEYV ] := IIf(mv_par22==1,FIELD->SEGUM,FIELD->UM)+FIELD->CODIGO+FIELD->FILIAL+FIELD->Local
						else
							aPrnDET[ DET_KEYV ] := FIELD->CODIGO+FIELD->FILIAL+FIELD->Local
						endif
					Endif
				Case (mv_par01 == 2)
					If (aReturn[ 8 ] == 5)
						If (mv_par17 == 1)
							aPrnDET[ DET_KEYV ] := FIELD->Local+IIf(mv_par22==1,FIELD->SEGUM,FIELD->UM)+FIELD->CODIGO+FIELD->FILIAL
						ELSE
							aPrnDET[ DET_KEYV ] := FIELD->Local+FIELD->CODIGO+FIELD->FILIAL
						ENDIF
					Else
						If (mv_par17 == 1)
							aPrnDET[ DET_KEYV ] := IIf(mv_par22==1,FIELD->SEGUM,FIELD->UM)+FIELD->CODIGO+FIELD->FILIAL
						else
							aPrnDET[ DET_KEYV ] := FIELD->CODIGO+FIELD->FILIAL
						endif
					Endif
				Case (mv_par01 == 3)
					If (aReturn[ 8 ] == 5)
						If (mv_par17 == 1)
							aPrnDET[ DET_KEYV ] := FIELD->Local+IIf(mv_par22==1,FIELD->SEGUM,FIELD->UM)+FIELD->CODIGO
						ELSE
							aPrnDET[ DET_KEYV ] := FIELD->Local+FIELD->CODIGO
						ENDIF
					Else
						If (mv_par17 == 1)
							aPrnDET[ DET_KEYV ] := IIf(mv_par22==1,FIELD->SEGUM,FIELD->UM)+FIELD->CODIGO
						else
							aPrnDET[ DET_KEYV ] := FIELD->CODIGO
						endif
					Endif
				EndCase
			EndIf
		EndIf

		cProd:= FIELD->CODIGO
		aPrnDET[ DET_SALD ] += FIELD->QUANT
		aPrnDET[ DET_EMPN ] += FIELD->QUANTR
		aPrnDET[ DET_DISP ] += (FIELD->QUANT-FIELD->QUANTR)
		aPrnDET[ DET_VEST ] += FIELD->VALOR
		aPrnDET[ DET_VEMP ] += FIELD->VALORR

		If (mv_par17 == 1)

			aTotUM[ ACM_SALD ] += FIELD->QUANT
			aTotUM[ ACM_EMPN ] += FIELD->QUANTR
			aTotUM[ ACM_DISP ] += (FIELD->QUANT-FIELD->QUANTR)
			aTotUM[ ACM_VEST ] += FIELD->VALOR
			aTotUM[ ACM_VEMP ] += FIELD->VALORR

			aTotUM1[ ACM_SALD ] += FIELD->QUANT
			aTotUM1[ ACM_EMPN ] += FIELD->QUANTR
			aTotUM1[ ACM_DISP ] += (FIELD->QUANT-FIELD->QUANTR)
			aTotUM1[ ACM_VEST ] += FIELD->VALOR
			aTotUM1[ ACM_VEMP ] += FIELD->VALORR
		EndIf

		If ((nOrdem == 2) .Or. (nOrdem == 4))

			aTotORD[ ACM_SALD ] += FIELD->QUANT
			aTotORD[ ACM_EMPN ] += FIELD->QUANTR
			aTotORD[ ACM_DISP ] += (FIELD->QUANT-FIELD->QUANTR)
			aTotORD[ ACM_VEST ] += FIELD->VALOR
			aTotORD[ ACM_VEMP ] += FIELD->VALORR
		EndIf

		DbSkip()

		If lVEIC
			Do Case
			Case (mv_par01 == 1)
				If (aReturn[ 8 ] == 5)
					If (mv_par17 == 1)
						lPrintDET := !(aPrnDET[ DET_KEYV ] == FIELD->LOCAL+IIf(mv_par22==1,FIELD->SEGUM,FIELD->UM)+FIELD->CODITE+FIELD->FILIAL)
					ELSE
						lPrintDET := !(aPrnDET[ DET_KEYV ] == FIELD->LOCAL+FIELD->CODITE+FIELD->FILIAL)
					ENDIF
				Else
					If (mv_par17 == 1)
						lPrintDET := !(aPrnDET[ DET_KEYV ] == IIf(mv_par22==1,FIELD->SEGUM,FIELD->UM)+FIELD->CODITE+FIELD->FILIAL+FIELD->LOCAL)
					else
						lPrintDET := !(aPrnDET[ DET_KEYV ] == FIELD->CODITE+FIELD->FILIAL+FIELD->LOCAL)
					endif
				Endif
			Case (mv_par01 == 2)
				If (aReturn[ 8 ] == 5)
					If (mv_par17 == 1)
						lPrintDET := !(aPrnDET[ DET_KEYV ] == FIELD->LOCAL+IIf(mv_par22==1,FIELD->SEGUM,FIELD->UM)+FIELD->CODITE+FIELD->FILIAL)
					ELSE
						lPrintDET := !(aPrnDET[ DET_KEYV ] == FIELD->LOCAL+FIELD->CODITE+FIELD->FILIAL)
					ENDIF
				Else
					If (mv_par17 == 1)
						lPrintDET := !(aPrnDET[ DET_KEYV ] == IIf(mv_par22==1,FIELD->SEGUM,FIELD->UM)+FIELD->CODITE+FIELD->FILIAL)
					else
						lPrintDET := !(aPrnDET[ DET_KEYV ] == FIELD->CODITE+FIELD->FILIAL)
					endif
				Endif
			Case (mv_par01 == 3)
				If (aReturn[ 8 ] == 5)
					If (mv_par17 == 1)
						lPrintDET := !(aPrnDET[ DET_KEYV ] == FIELD->LOCAL+IIf(mv_par22==1,FIELD->SEGUM,FIELD->UM)+FIELD->CODITE)
					ELSE
						lPrintDET := !(aPrnDET[ DET_KEYV ] == FIELD->LOCAL+FIELD->CODITE)
					ENDIF
				Else
					If (mv_par17 == 1)
						lPrintDET := !(aPrnDET[ DET_KEYV ] == IIf(mv_par22==1,FIELD->SEGUM,FIELD->UM)+FIELD->CODITE)
					else
						lPrintDET := !(aPrnDET[ DET_KEYV ] == FIELD->CODITE)
					endif
				Endif
			EndCase
		ELSE
			Do Case
			Case (mv_par01 == 1)
				If (aReturn[ 8 ] == 5)
					If (mv_par17 == 1)
						lPrintDET := !(aPrnDET[ DET_KEYV ] == FIELD->Local+IIf(mv_par22==1,FIELD->SEGUM,FIELD->UM)+FIELD->CODIGO+FIELD->FILIAL)
					ELSE
						lPrintDET := !(aPrnDET[ DET_KEYV ] == FIELD->Local+FIELD->CODIGO+FIELD->FILIAL)
					ENDIF
				Else
					If (mv_par17 == 1)
						lPrintDET := !(aPrnDET[ DET_KEYV ] == IIf(mv_par22==1,FIELD->SEGUM,FIELD->UM)+FIELD->CODIGO+FIELD->FILIAL+FIELD->Local)
					else
						lPrintDET := !(aPrnDET[ DET_KEYV ] == FIELD->CODIGO+FIELD->FILIAL+FIELD->Local)
					Endif
				Endif
			Case (mv_par01 == 2)
				If (aReturn[ 8 ] == 5)
					If (mv_par17 == 1)
						lPrintDET := !(aPrnDET[ DET_KEYV ] == FIELD->Local+IIf(mv_par22==1,FIELD->SEGUM,FIELD->UM)+FIELD->CODIGO+FIELD->FILIAL)
					else
						lPrintDET := !(aPrnDET[ DET_KEYV ] == FIELD->Local+FIELD->CODIGO+FIELD->FILIAL)
					Endif
				Else
					If (mv_par17 == 1)
						lPrintDET := !(aPrnDET[ DET_KEYV ] == IIf(mv_par22==1,FIELD->SEGUM,FIELD->UM)+FIELD->CODIGO+FIELD->FILIAL)
					else
						lPrintDET := !(aPrnDET[ DET_KEYV ] == FIELD->CODIGO+FIELD->FILIAL)
					Endif
				Endif
			Case (mv_par01 == 3)
				If (aReturn[ 8 ] == 5)
					If (mv_par17 == 1)
						lPrintDET := !(aPrnDET[ DET_KEYV ] == FIELD->Local+IIf(mv_par22==1,FIELD->SEGUM,FIELD->UM)+FIELD->CODIGO)
					Else
						lPrintDET := !(aPrnDET[ DET_KEYV ] == FIELD->Local+FIELD->CODIGO)
					Endif
				Else
					If (mv_par17 == 1)
						lPrintDET := !(aPrnDET[ DET_KEYV ] == IIf(mv_par22==1,FIELD->SEGUM,FIELD->UM)+FIELD->CODIGO)
					else
						lPrintDET := !(aPrnDET[ DET_KEYV ] == FIELD->CODIGO)
					Endif
				Endif
			EndCase
		Endif

		If lCusUnif .And. lPrintDET
			If (mv_par18==2) .And. (QtdComp(aPrnDET[DET_SALD])==QtdComp(0))
				aPrnDET := Nil
				Loop
			EndIf
		EndIf
		Do Case
		Case	(nOrdem <> 5).AND.;
				(	(mv_par17 == 1);
				.And. ;
				(aTotUM[ ACM_CODE ] <> IIf(mv_par22==1,FIELD->SEGUM,FIELD->UM));
				)
			lPrintTOT := .T.
		Case	(nOrdem == 5).AND.;
				(	(mv_par17 == 1) ;
				.And. ;
				(	(aTotUM1[ ACM_CODE ] <> IIf(mv_par22==1,FIELD->SEGUM,FIELD->UM)+FIELD->Local);
				.OR.;
				(aTotUM[ ACM_CODE ] <> IIf(mv_par22==1,FIELD->SEGUM,FIELD->UM));
				);
				)
			lPrintTOT := .T.
		Case (( (nOrdem == 2) .Or. (nOrdem == 4) ) .And. ;
				!(aTotORD[ ACM_CODE ] == IIf( (nOrdem == 2),FIELD->TIPO,FIELD->GRUPO )))

			lPrintTOT := .T.
		EndCase

		If lPrintDET .Or. lPrintTOT

			If (Li > 56)
				Cabec( cTitulo,cCab01,cCab02,wNRel,cTam,nTipo )
			EndIf

			Do Case
			Case !(aPrnDET[ DET_CODE ] == cLPrnCd)
				cLPrnCd := aPrnDET[ DET_CODE ] ; lPrintCAB := .T.
			EndCase

			If lPrintCAB .Or. lPrintOUT
				dbSelectArea("SB1")
				dbSetOrder(1)
				dbSeek(xFilial("SB1") + aPrnDET[ DET_CODE ])
				DbSelectArea( cFileTRB )
			/*
				IF lVEIC
				@ Li,000 PSay aPrnDET[ DET_CODE ] + " "+ aPrnDET[ DET_SIZE + 1 ]
				//  := FIELD->CODIGO
				else
				@ Li,000 PSay aPrnDET[ DET_CODE ]
				endif

			@ Li,016 + nCOL1 PSay aPrnDET[ DET_TIPO ]
			@ Li,019 + nCOL1 PSay aPrnDET[ DET_GRUP ]
			@ Li,024 + nCOL1 PSay aPrnDET[ DET_DESC ]
			@ Li,046 + nCOL1 PSay aPrnDET[ DET_UM   ]
			*/
				@ Li,000 PSay Left(SB1->B1_CODLMT,40) + " " + SB1->B1_COD
//			Alert (STrZero(li,2) + " "+ SB1->B1_CODLMT)
				lPrintCAB := .F. ; lPrintOUT := .F.
			EndIf

//		@ Li,049 + nCOL1 PSay aPrnDET[ DET_FL   ]
//		@ Li,052 + nCOL1 PSay aPrnDET[ DET_ALMX ]
			If mv_par22 == 1
				@ Li,056 + nCOL1 PSay ConvUm(aPrnDET[ DET_CODE ],aPrnDET[ DET_SALD ],0,2) Picture cPicture
				@ Li,072 + nCOL1 PSay ConvUm(aPrnDET[ DET_CODE ],aPrnDET[ DET_EMPN ],0,2) Picture cPicture
				@ Li,085 + nCOL1 PSay ConvUm(aPrnDET[ DET_CODE ],aPrnDET[ DET_DISP ],0,2) Picture cPicture
				@ Li,100 + nCOL1 PSay ConvUm(aPrnDET[ DET_CODE ],aPrnDET[ DET_VEST ],0,2) Picture cPicVal
				@ Li,117 + nCOL1 PSay ConvUm(aPrnDET[ DET_CODE ],aPrnDET[ DET_VEMP ],0,2) Picture cPicVal
			Else
				@ Li,056 + nCOL1 PSay aPrnDET[ DET_SALD ] Picture cPicture
				@ Li,072 + nCOL1 PSay aPrnDET[ DET_EMPN ] Picture cPicture
				@ Li,085 + nCOL1 PSay aPrnDET[ DET_DISP ] Picture cPicture
				@ Li,100 + nCOL1 PSay aPrnDET[ DET_VEST ] Picture cPicVal
				@ Li,117 + nCOL1 PSay aPrnDET[ DET_VEMP ] Picture cPicVal
			Endif

			nTotValSal+=aPrnDET[ DET_SALD ]
			nTotValRpr+=aPrnDET[ DET_EMPN ]
			nTotValRes+=aPrnDET[ DET_DISP ]
			nTotValEst+=aPrnDET[ DET_VEST ]
			nTotValEmp+=aPrnDET[ DET_VEMP ]

			//totaliza valores na 2a. unidade de medida
			If mv_par22 == 1
				nTotValSa2+=ConvUm(aPrnDET[ DET_CODE ],aPrnDET[ DET_SALD ],0,2)
				nTotValRp2+=ConvUm(aPrnDET[ DET_CODE ],aPrnDET[ DET_EMPN ],0,2)
				nTotValRe2+=ConvUm(aPrnDET[ DET_CODE ],aPrnDET[ DET_DISP ],0,2)
				nTotValEs2+=ConvUm(aPrnDET[ DET_CODE ],aPrnDET[ DET_VEST ],0,2)
				nTotValEm2+=ConvUm(aPrnDET[ DET_CODE ],aPrnDET[ DET_VEMP ],0,2)
			Endif
			aPrnDET := nil ; Li++

			lT		:= .F.	// IMPRIMIR E ZERAR aTotUM
			lT1	:= .F.	// IMPRIMIR E ZERAR aTotUM1

			IF (mv_par17 == 1)
				IF nORDEM <> 5 .AND. (aTotUM[ ACM_CODE ] <> IIf(mv_par22==1,FIELD->SEGUM,FIELD->UM))
					lT	:= .T. // IMPRIMIR E ZERAR aTotUM
				ELSE
					IF nORDEM == 5
						// unidade diferente !
						IF (aTotUM[ ACM_CODE ] <> IIf(mv_par22==1,FIELD->SEGUM,FIELD->UM))
							lT	:= .T. // IMPRIMIR E ZERAR aTotUM E aTotUM1.
							if lT2
								lT1	:= .T. // IMPRIMIR E ZERAR aTotUM1.
								lT2	:= .F. // SE TEM Q IMPRIMIR O aTotUM1.
							endif
						ELSE // unidade igual e local diferente !
							IF ( SUBSTR( aTotUM1[ ACM_CODE ], LEN(aTotUM1[ACM_CODE]) -1, 2) <> FIELD->Local)
								lT		:= .F. // NAO IMPRIMIR E ZERAR aTotUM.
								lT1		:= .T. // IMPRIMIR E ZERAR aTotUM1.
								if !lT2
									lT2	:= .T.
								endif
							ENDIF
						ENDIF
					ENDIF
				ENDIF
			ENDIF

			IF lT	 .OR. lT1
				Li++
				IF nORDEM <> 5
					@ Li,016 PSay OemToAnsi(STR0019)+aTotUM[ ACM_CODE ]   //"Total Unidade Medida : "
					If mv_par22 == 1
						@ Li,054 + nCOL1 PSay ConvUm(cProd,aTotUM[ ACM_SALD ],0,2) Picture cPicture
						@ Li,070 + nCOL1 PSay ConvUm(cProd,aTotUM[ ACM_EMPN ],0,2) Picture cPicture
						@ Li,085 + nCOL1 PSay ConvUm(cProd,aTotUM[ ACM_DISP ],0,2) Picture cPicture
						@ Li,100 + nCOL1 PSay ConvUm(cProd,aTotUM[ ACM_VEST ],0,2) Picture cPicVal
						@ Li,117 + nCOL1 PSay ConvUm(cProd,aTotUM[ ACM_VEMP ],0,2) Picture cPicVal
					Else
						@ Li,054 + nCOL1 PSay aTotUM[ ACM_SALD ] Picture cPicture
						@ Li,070 + nCOL1 PSay aTotUM[ ACM_EMPN ] Picture cPicture
						@ Li,085 + nCOL1 PSay aTotUM[ ACM_DISP ] Picture cPicture
						@ Li,100 + nCOL1 PSay aTotUM[ ACM_VEST ] Picture cPicVal
						@ Li,117 + nCOL1 PSay aTotUM[ ACM_VEMP ] Picture cPicVal
					Endif

					aTotUM    := nil

				ELSE
					IF lT1
						@ Li,n1 PSay "Sub" + OemToAnsi(STR0019) ; //"SubTotal Unidade Medida : "
						+ SUBSTR(aTotUM1[ ACM_CODE ],1,LEN(aTotUM1[ ACM_CODE ])-2) ;
							+ " - " + cArm1 + " : " ;
							+ SUBSTR(aTotUM1[ ACM_CODE ],LEN(aTotUM1[ ACM_CODE ])-1,2)
						IF mv_par22 == 1
							@ Li,054 + nCOL1 PSay ConvUm(cProd,aTotUM1[ ACM_SALD ],0,2) Picture cPicture
							@ Li,070 + nCOL1 PSay Convum(cProd,aTotUM1[ ACM_EMPN ],0,2) Picture cPicture
							@ Li,085 + nCOL1 PSay ConvUm(cProd,aTotUM1[ ACM_DISP ],0,2) Picture cPicture
							@ Li,100 + nCOL1 PSay ConvUm(cProd,aTotUM1[ ACM_VEST ],0,2) Picture cPicVal
							@ Li,117 + nCOL1 PSay ConvUm(cProd,aTotUM1[ ACM_VEMP ],0,2) Picture cPicVal
						Else
							@ Li,054 + nCOL1 PSay aTotUM1[ ACM_SALD ] Picture cPicture
							@ Li,070 + nCOL1 PSay aTotUM1[ ACM_EMPN ] Picture cPicture
							@ Li,085 + nCOL1 PSay aTotUM1[ ACM_DISP ] Picture cPicture
							@ Li,100 + nCOL1 PSay aTotUM1[ ACM_VEST ] Picture cPicVal
							@ Li,117 + nCOL1 PSay aTotUM1[ ACM_VEMP ] Picture cPicVal
						Endif

						aTotUM1	:= nil
						lT2		:= .T.

					ENDIF
					IF lT
						IF lT1
							Li	+=	2
						ENDIF

						@ Li,016 PSay OemToAnsi(STR0019)+aTotUM[ ACM_CODE ]   //"Total Unidade Medida : "
						If mv_par22 == 1
							@ Li,054 + nCOL1 PSay ConvUm(cProd,aTotUM[ ACM_SALD ],0,2) Picture cPicture
							@ Li,070 + nCOL1 PSay ConvUm(cProd,aTotUM[ ACM_EMPN ],0,2) Picture cPicture
							@ Li,085 + nCOL1 PSay ConvUm(cProd,aTotUM[ ACM_DISP ],0,2) Picture cPicture
							@ Li,100 + nCOL1 PSay ConvUm(cProd,aTotUM[ ACM_VEST ],0,2) Picture cPicVal
							@ Li,117 + nCOL1 PSay ConvUm(cProd,aTotUM[ ACM_VEMP ],0,2) Picture cPicVal
						Else
							@ Li,054 + nCOL1 PSay aTotUM[ ACM_SALD ] Picture cPicture
							@ Li,070 + nCOL1 PSay aTotUM[ ACM_EMPN ] Picture cPicture
							@ Li,085 + nCOL1 PSay aTotUM[ ACM_DISP ] Picture cPicture
							@ Li,100 + nCOL1 PSay aTotUM[ ACM_VEST ] Picture cPicVal
							@ Li,117 + nCOL1 PSay aTotUM[ ACM_VEMP ] Picture cPicVal
						Endif

						aTotUM1	:= nil
						aTotUM	:= nil
						lT2		:= .F.

					ENDIF
				ENDIF
				Li++

				lPrintLIN := .T.
				lPrintTOT := .F. ; lPrintOUT := .T.
			EndIf

			If (((nOrdem == 2) .Or. (nOrdem == 4)) .And. ;
					!(aTotORD[ ACM_CODE ] == IIf( (nOrdem == 2),FIELD->TIPO,FIELD->GRUPO )))

				Li++

				@ Li,016 PSay OemToAnsi(STR0016)+IIf( (nOrdem == 2),OemToAnsi(STR0017),OemToAnsi(STR0018))+" : "+aTotORD[ ACM_CODE ]   //"Total do "###"Tipo"###"Grupo"

				If mv_par22 == 1
					@ Li,054 + nCOL1 PSay ConvUm(cProd,aTotORD[ ACM_SALD ],0,2) Picture cPicture
					@ Li,070 + nCOL1 PSay ConvUm(cProd,aTotORD[ ACM_EMPN ],0,2) Picture cPicture
					@ Li,085 + nCOL1 PSay ConvUm(cProd,aTotORD[ ACM_DISP ],0,2) Picture cPicture
					@ Li,100 + nCOL1 PSay ConvUm(cProd,aTotORD[ ACM_VEST ],0,2) Picture cPicVal
					@ Li,117 + nCOL1 PSay ConvUm(cProd,aTotORD[ ACM_VEMP ],0,2) Picture cPicVal
				Else
					@ Li,054 + nCOL1 PSay aTotORD[ ACM_SALD ] Picture cPicture
					@ Li,070 + nCOL1 PSay aTotORD[ ACM_EMPN ] Picture cPicture
					@ Li,085 + nCOL1 PSay aTotORD[ ACM_DISP ] Picture cPicture
					@ Li,100 + nCOL1 PSay aTotORD[ ACM_VEST ] Picture cPicVal
					@ Li,117 + nCOL1 PSay aTotORD[ ACM_VEMP ] Picture cPicVal
				Endif

				Li++

				aTotORD   := nil ; lPrintLIN := .T.
				lPrintTOT := .F. ; lPrintOUT := .T.
			EndIf

			If lPrintLIN
				Li++ ; lPrintLIN := .F.
			EndIf
		EndIf
	EndDo

	If nTotValSal + nTotValRPR + nTotValRes + nTotValEst + nTotValEmp # 0
		If Li > 56
			Cabec(cTitulo,cCab01,cCab02,wnRel,cTam,nTipo)
		EndIf
		Li += IIf(mv_par17#1,1,0)
		@ Li,016 PSay OemToAnsi(STR0020) // "Total Geral : "
		If mv_par22 == 1
			@ Li,054 + nCOL1 PSay nTotValSa2 Picture cPicture
			@ Li,070 + nCOL1 PSay nTotValRp2 Picture cPicture
			@ Li,085 + nCOL1 PSay nTotValRe2 Picture cPicture
			@ Li,100 + nCOL1 PSay nTotValEs2 Picture cPicVal
			@ Li,117 + nCOL1 PSay nTotValEm2 Picture cPicVal
		Else
			@ Li,054 + nCOL1 PSay nTotValSal Picture cPicture
			@ Li,070 + nCOL1 PSay nTotValRPR Picture cPicture
			@ Li,085 + nCOL1 PSay nTotValRes Picture cPicture
			@ Li,100 + nCOL1 PSay nTotValEst Picture cPicVal
			@ Li,117 + nCOL1 PSay nTotValEmp Picture cPicVal
		Endif
	EndIf

	If (LastKey() == 286) .OR. IIf(lEND==Nil,.F.,lEND) .OR. lAbortPrint
		@ pRow()+1,00 PSay OemToAnsi(STR0021)     //"CANCELADO PELO OPERADOR."
	Else
		Roda( LastRec(), OemToAnsi(STR0022),cTam )    //"Registro(s) processado(s)"
	EndIf

	SET DEVICE TO SCREEN

	MS_FLUSH()

	If (aReturn[ 5 ] == 1)
		SET PRINTER TO
		OurSpool( wNRel )
	Endif

	DbSelectArea( cFileTRB )  ; DbCloseArea()
	FErase( cFileTRB+GetDBExtension() )
	FErase( cFileTRB+OrdBagExt() )

	DbSelectArea( "SB1" )

Return( nil )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MA260PergUºAutor  ³Microsiga           º Data ³  01/28/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Altera as Perguntas no SX1 para utilizacao do MV_CUSFIL     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MA260PergU()

Local aAreaAnt := GetArea()

	If lCusUnif //-- Ajusta as perguntas para Custo Unificado
	dbSelectArea('SX1')
	dbSetOrder(1)
		If dbSeek('POSICA01', .F.) .And. !(X1_PRESEL==2.Or.X1_PRESEL==3) //-- Aglutina por Filial
		RecLock('SX1', .F.)
		Replace X1_PRESEL With 2
		MsUnlock()
		EndIf
		If dbSeek('POSICA04', .F.) .And. !(X1_CNT01=='**') //-- Armazem De **
		RecLock('SX1', .F.)
		Replace X1_CNT01 With '**'
		MsUnlock()
		EndIf
		If dbSeek('POSICA05', .F.) .And. !(X1_CNT01=='**') //-- Armazem Ate **
		RecLock('SX1', .F.)
		Replace X1_CNT01 With '**'
		MsUnlock()
		EndIf
	EndIf

RestArea(aAreaAnt)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³AjustaSX1 ºAutor  ³Fernando J. Siquini º Data ³  02/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inclui a 21a pergunta do MTR260 no SX1                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATR260                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AjustaSX1()

U_FTTVSX001(cPerg, '21' , 'Listar Prods C/ Valor Zerado ?', ;
	'Muestra Valores a Cero ?      ', ;
	'Show Zeroed Values ?          ', 'mv_chk', 'C', 1, 0, 2, 'C', '', '', '', '', 'mv_par21', ;
	'Sim' , ;
	'Si', ;
	'Yes', '', ;
	'Nao', ;
	'No', ;
	'No','','','','','','','','','', ;
	{'Determina se produtos que possuam o     ', ;
	'Custo apurado igual a ZERO devem ser    ', ;
	'impressos.                              '}, ;
	{'Defina si los productos con el coste   ', ;
	'calculado igual Cero tienen que ser    ', ;
	'impressos                              '}, ;
	{'Define if Products with Calculated Cost', ;
	'equal Zero have to be printed.         ', ;
	'                                       '})

RETURN


