#INCLUDE "MATR270.CH"
#Include "RWMAKE.Ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR270  ³ Autor ³ Wagner Xavier         ³ Data ³ 05.09.91 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Etiquetas para Inventario                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo Pim.³04/12/01³PYME  ³ Adequacao do fonte para utilizacao do    ³±±
±±³            ³        ³PYME  ³ Siga PyMe.                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function Matr270()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LOCAL titulo   := STR0001	//"Etiquetas para Inventario"
	LOCAL cDesc1   := STR0002	//"Este programa ira emitir etiquetas para contagem do estoque."
	LOCAL cDesc2   := STR0003	//"Sera emitido em 3 colunas para cada produto."
	LOCAL cDesc3   := ""
	LOCAL cString  := "SB1"
	LOCAL wnrel    := "MATR270"
	LOCAL aOrd     := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tratamento da Ordem para utilizacao do Siga Pyme             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !__lPyme
		aOrd := {OemToAnsi(STR0004),OemToAnsi(STR0005),OemToAnsi(STR0006),OemToAnsi(STR0007),OemToAnsi(STR0026)}   //" Por Codigo         "###" Por Tipo           "###" Por Descricao    "###" Por Grupo        "###" Por Localizacao Fisica "
	Else
		aOrd := {OemToAnsi(STR0004),OemToAnsi(STR0005),OemToAnsi(STR0006),OemToAnsi(STR0007)}   //" Por Codigo         "###" Por Tipo           "###" Por Descricao    "###" Por Grupo        "
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis tipo Private padrao de todos os relatorios         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PRIVATE aReturn:= { OemToAnsi(STR0008), 1,OemToAnsi(STR0009), 2, 2, 1, "",1 }    //"Zebrado"###"Administracao"
	PRIVATE nLastKey := 0 ,cPerg := PadR( "MTR270" , Len( SX1->X1_GRUPO ) )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01     // Almox. de                                    ³
	//³ mv_par02     // Almox. ate                                   ³
	//³ mv_par03     // Produto de                                   ³
	//³ mv_par04     // Produto ate                                  ³
	//³ mv_par05     // tipo de                                      ³
	//³ mv_par06     // tipo ate                                     ³
	//³ mv_par07     // grupo de                                     ³
	//³ mv_par08     // grupo ate                                    ³
	//³ mv_par09     // descricao de                                 ³
	//³ mv_par10     // descricao ate                                ³
	//³ mv_par11     // Numero da primeira ficha                     ³
	//³ mv_par12     // Data de Selecao de                           ³
	//³ mv_par13     // Data de Selecao ate                          ³
	//³ mv_par14     // Qual Ordem de Coluna                         ³
	//³ mv_par15     // Localizacao Fisica De                        ³
	//³ mv_par16     // Localizacao Fisica Ate                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	pergunte(cPerg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd)

	If nLastKey = 27
		Set Filter to
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey = 27
		Set Filter to
		Return
	Endif

	RptStatus( { |lEnd| C270Imp(@lEnd,wnrel,cString,titulo) } ,titulo )

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C270IMP  ³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 11.12.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR270			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C270Imp(lEnd,wnrel,cString,titulo)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis locais exclusivas deste programa                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LOCAL cLinha,cLinha1,cColuna,nNum
	LOCAL nTipo := 0
	LOCAL cOrd  := ""
	LOCAL cLocal,cLocaliz
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Contador de linha                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PRIVATE li		:= 80
	PRIVATE limite	:= 132

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis privadas exclusivas deste programa                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PRIVATE cCondicao,lContinua,cCondSB

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz manualmente porque nao chama a funcao Cabec()            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 0,0 PSay AvalImp(Limite)

	dbSelectArea("SB1")
	SetRegua(LastRec())

	Set Softseek On
	dbSetOrder(aReturn[8])

	If aReturn[8] == 4
		Seek cFilial+mv_par07
		cCondicao := "lContinua .And. !Eof() .And. B1_GRUPO <= mv_par08"
	ElseIf aReturn[8] == 3
		Seek cFilial+mv_par09
		cCondicao := "lContinua .And. !Eof() .And. B1_DESC <= mv_par10"
	ElseIf aReturn[8] == 2
		Seek cFilial+mv_par05
		cCondicao := "lContinua .And. !Eof() .And. B1_TIPO <= mv_par06"
	Else
		dbSetOrder(1)
		Seek cFilial+mv_par03
		cCondicao := "lContinua .And. !Eof() .And. B1_COD <= mv_par04"
	Endif
	Set SoftSeek Off

	cLinha  	:= "|"+Replicate("-",128)+"|"
	cLinha1 	:= Replicate("=",130)
	cColuna 	:= "|"+Space(42)+"|"+Space(42)+"|"+Space(42)+"|"
	lContinua 	:= .T.
	nNum 		:= mv_par11

	While &cCondicao .and. B1_FILIAL == cFilial

		If lEnd
			@ PROW()+1,001 PSay OemToAnsi(STR0010)   //"CANCELADO PELO OPERADOR"
			Exit
		EndIf

		IncRegua()

		If B1_COD < mv_par03 .Or. B1_COD > mv_par04
			SB1->(dbSkip())
			Loop
		EndIf

		If B1_TIPO < mv_par05 .Or. B1_TIPO > mv_par06
			SB1->(dbSkip())
			Loop
		EndIf

		If B1_GRUPO < mv_par07 .Or. B1_GRUPO > mv_par08
			SB1->(dbSkip())
			Loop
		EndIf

		If B1_DESC < mv_par09 .Or. B1_DESC > mv_par10
			SB1->(dbSkip())
			Loop
		EndIf

		If !__lPyme .And. aReturn[8] == 5
			If B1_LOCALIZ # "S"
				SB1->(dbSkip())
				Loop
			EndIf
		EndIf

		If aReturn[8] == 5
			dbSelectArea("SBF")
			dbSetOrder(2)
			dbSeek(cFilial+SB1->B1_COD)
			cCondSB := "BF_FILIAL+BF_PRODUTO"
			_cAlias := "SBF"
		Else
			dbSelectArea("SB2")
			dbSeek(cFilial+SB1->B1_COD)
			cCondSB := "B2_FILIAL+B2_COD"
			_cAlias := "SB2"
		EndIf

		If EOF()
			dbSelectArea("SB1")
			SB1->(dbSkip())
			Loop
		EndIf

		While !_cAlias->(EOF()) .And. &cCondSB == xFilial()+SB1->B1_COD

			If lEnd
				@ PROW()+1,001 PSay OemToAnsi(STR0010)	//"CANCELADO PELO OPERADOR"
				lContinua := .F.
				Exit
			EndIf

			If Li > 50
				Li := 3
			EndIf

			If aReturn[8] == 5
				If BF_LOCALIZ < mv_par15 .Or. BF_LOCALIZ > mv_par16
					_cAlias->(dbSkip())
					Loop
				EndIf
				dbSelectArea("SB2")
				dbSeek(cFilial+SB1->B1_COD+SBF->BF_LOCAL)
			EndIf

			If !Empty(SB2->B2_DINVENT)
				If (SB2->B2_DINVENT + SB1->B1_PERINV) < mv_par12 .Or. (SB2->B2_DINVENT + SB1->B1_PERINV) > mv_par13
					IIf(aReturn[8] == 5,dbSelectArea("SBF"),"")
					_cAlias->(dbSkip())
					Loop
				Endif
			EndIf

			If B2_LOCAL < mv_par01 .Or. B2_LOCAL > mv_par02
				IIf(aReturn[8] == 5,dbSelectArea("SBF"),"")
				_cAlias->(dbSkip())
				Loop
			EndIf

			@ Li,000 PSay cLinha
			Li++

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Faz a mudanca da ordem selecionada pelo mv_par14.       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nC:= 1 To 3
				If Val(Subs(mv_par14,nC,1)) == 1
					cOrd:= OemtoAnsi(STR0023)   //   "|          A-INVENTARIO No. "
				ElseIf Val(Subs(mv_par14,nC,1)) == 2
					cOrd:= OemtoAnsi(STR0024)   //   "|          B-INVENTARIO No. "
				ElseIf Val(Subs(mv_par14,nC,1)) == 3
					cOrd:= OemtoAnsi(STR0025)   //   "|          C-INVENTARIO No. "
				Endif
				If nC == 1
					@ Li,000 PSay cOrd+StrZero(nNum,6)
				ElseIf nC == 2
					@ Li,043 PSay cOrd+StrZero(nNum,6)
				ElseIf nC == 3
					@ Li,086 PSay cOrd+StrZero(nNum,6)
				Endif
			Next nC
			@ Li,129 PSay "|"
			dbSelectArea("SB1")
			Li++
			@ Li,000 PSay cColuna
			Li++
			@ Li,000 PSay "|"+Replicate(OemToAnsi(STR0011)+B1_COD+OemToAnsi(STR0012)+B1_TIPO+OemToAnsi(STR0013)+B1_GRUPO+OemToAnsi(STR0014)+B1_UM+"|",3)    //"Codigo:"###" Tp:"###" Gr:"###" Um:"
			Li++
			@ Li,000 PSay OemToAnsi(STR0015)+SubStr(B1_DESC,1,33)   //"|Descri.: "
			@ Li,043 PSay OemToAnsi(STR0015)+SubStr(B1_DESC,1,33)   //"|Descri.: "
			@ Li,086 PSay OemToAnsi(STR0015)+SubStr(B1_DESC,1,33)   //"|Descri.: "
			@ Li,129 PSay "|"
			Li++
			If aReturn[8] == 5
				dbSelectArea("SBF")
				cLocal   := BF_LOCAL
				cLocaliz := BF_LOCALIZ
			Else
				dbSelectArea("SB2")
				cLocal   := B2_LOCAL
				cLocaliz := B2_LOCALIZ
			EndIf
			@ Li,000 PSay OemToAnsi(STR0016)+cLocal+OemToAnsi(STR0017)+SubStr(cLocaliz,1,15)    //"|Almox..: "###" Localizacao : "
			@ Li,043 PSay OemToAnsi(STR0016)+cLocal+OemToAnsi(STR0017)+SubStr(cLocaliz,1,15)    //"|Almox..: "###" Localizacao : "
			@ Li,086 PSay OemToAnsi(STR0016)+cLocal+OemToAnsi(STR0017)+SubStr(cLocaliz,1,15)    //"|Almox..: "###" Localizacao : "
			@ Li,129 PSay "|"
			Li++
			@ Li,000 PSay cLinha
			Li++
			@ Li,000 PSay cColuna
			Li++

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Faz a mudanca da ordem selecionada pelo mv_par14.       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nC:= 1 To 3
				If Val(Subs(mv_par14,nC,1)) == 1
					cOrd:= OemToAnsi(STR0018)	//"| Data da 1a. contagem : ____/____/____"
				ElseIf Val(Subs(mv_par14,nC,1)) == 2
					cOrd:= OemToAnsi(STR0019)	//"| Data da 2a. contagem : ____/____/____"
				ElseIf Val(Subs(mv_par14,nC,1)) == 3
					cOrd:= OemToAnsi(STR0020)	//"| Data da 3a. contagem : ____/____/____"
				Endif
				If nC == 1
					@ Li,000 PSay cOrd
				ElseIf nC == 2
					@ Li,043 PSay cOrd
				ElseIf nC == 3
					@ Li,086 PSay cOrd
				Endif
			Next nC
			@ Li,129 PSay "|"
			Li++
			@ Li,000 PSay cLinha
			Li++
			@ Li,000 PSay cColuna
			Li++
			@ Li,000 PSay OemToAnsi(STR0021)	//"| Quantidade apurada:"
			@ Li,043 PSay OemToAnsi(STR0021)	//"| Quantidade apurada:"
			@ Li,086 PSay OemToAnsi(STR0021)	//"| Quantidade apurada:"
			@ Li,129 PSay "|"
			Li++
			@ Li,000 PSay cLinha
			Li++
			@ Li,000 PSay cColuna
			Li++
			@ Li,000 PSay "|"+Replicate(" -------------------- ------------------- |",3)
			Li++
			@ Li,000 PSay "|"+Replicate(OemToAnsi(STR0022),3)    //"  Visto funcionario     Visto Conferente  |"
			Li++
			@ Li,000 PSay cLinha
			Li += 2
			@ Li,000 PSay cLinha1
			Li += 2
			nNum++
			If aReturn[8] == 5
				dbSelectArea("SBF")
			Else
				dbSelectArea("SB2")
			EndIf
			_cAlias->(dbSkip())
		EndDo
		dbSelectArea("SB1")
		SB1->(dbSkip())
	EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve a condicao original do arquivo principal             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cString)
	Set Filter To
	dbSetOrder(1)

	If aReturn[5] = 1
		Set Printer TO
		Commit
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MR270Ord  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 29/10/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se os nrs estao entre 1 e 3.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR270                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MR270Ord()
	LOCAL nC,cVar:=&(ReadVar())
	For nC:= 1 To 3
		If Val(Subs(cVar,nC,1)) > 3
			Help(" ",1,".MTR27014.")
			Return(.F.)
		Endif
	Next
Return(.T.)
