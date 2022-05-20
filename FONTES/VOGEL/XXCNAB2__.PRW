#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "fileio.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³XXCNAB2_  º Autor ³ TOTVS IBIRAPUERA          ³  21/08/20    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Programa para gerar arquivo texto sem interação com usuárioº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ V5FAT006                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function XXCNAB2(PAR01,PAR02,PAR03,PAR04,PAR05,PAR06,PAR07)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Private lRet		:= .T.
	Private oGeraTxt
	Private cString 	:= "SE1"
	Private cPerg 		:= "XXCNAB"
	Private	aDias		:= {31,31,28,31,30,31,30,31,31,30,31,30}
	Private cCodEmp
	Private Par07 		:= MsDocPath() + "\" + AllTrim(Par03) + "_" + StrZero(Year(PAR01),4) + StrZero(Month(PAR01),2) + ".TXT"


 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros ³
//³ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ³
//³ PAR01 Data De                        ³
//³ PAR02 Data Ate                       ³
//³ PAR03 Cliente                        ³
//³ PAR04 Loja                           ³
//³ PAR05 Titulo de                      ³
//³ PAR06 Titulo ate                     ³
//³ PAR07 Nome do Arquivo                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da tela de processamento.                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//@ 200,1 TO 400,480 DIALOG oGeraTxt TITLE OemToAnsi("Geracao de Arquivo Texto")
//@ 02,10 TO 095,230
//@ 10,018 Say "Este programa ira gerar um arquivo texto, conforme os parametros"
//@ 18,018 Say "definidos pelo usuario,com os registros do arquivo"
//@ 26,018 Say "de Titulos a serem enviados ao Banco"
//@ 70,128 BMPBUTTON TYPE 01 ACTION OkGeraTxt()
//@ 70,158 BMPBUTTON TYPE 02 ACTION Close(oGeraTxt)
//@ 70,188 BMPBUTTON TYPE 05 ACTION Pergunte(cPerg,.T.)
//
//Activate Dialog oGeraTxt Centered

	OkGeraTxt(PAR01,PAR02,PAR03,PAR04,PAR05,PAR06,PAR07)

Return lRet

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºFun‡„o    ³ OKGERATXTº Autor ³ TOTVS IBIRAPUERA   º Data ³  27/03/20   º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescri‡„o ³ Funcao chamada pelo botao OK na tela inicial de processamenº±±
	±±º          ³ to. Executa a geracao do arquivo texto.                    º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ Programa principal                                         º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function OkGeraTxt(PAR01,PAR02,PAR03,PAR04,PAR05,PAR06,PAR07)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o arquivo texto                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Private _cArq    := Alltrim(par07)
	Private nHdl    := fCreate(_cArq)
	Private cEOL    := CHR(13)+CHR(10)


	If nHdl == -1
		//MsgAlert("O arquivo de nome "+_cArq+" nao pode ser gerado! Verifique os parametros.","Atencao!")
		lRet := .F.
		Return
	Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa a regua de processamento                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Processa({|| RunCont(PAR01,PAR02,PAR03,PAR04,PAR05,PAR06,PAR07) },"Aguarde...")
Return

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºFun‡„o    ³ RUNCONT  º Autor ³ TOTVS IBIRAPUERA   º Data ³  27/03/20   º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescri‡„o ³ Funcao auxiliar chamada pela PROCESSA.  A funcao PROCESSA  º±±
	±±º          ³ monta a janela com a regua de processamento.               º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ Programa principal                                         º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunCont(PAR01,PAR02,PAR03,PAR04,PAR05,PAR06,PAR07)

	Local cLin, nValor
/*/
	cQuery1 := " SELECT E1.E1_PREFIXO, E1.E1_NUM, E1.E1_EMISSAO, E1.E1_VENCTO, E1.E1_VENCREA, E1.E1_VALOR, E1.E1_SALDO, A1.A1_COD, A1.A1_LOJA, A1.A1_NOME, A1.A1_CGC, A1.A1_CODMUN, A1.A1_CODSEG, F2_DOC, C6_DESCRI, C6_XSTT, C6_VALOR AS XVALOR, "
	cQuery1 += "        E1.E1_NUMBCO, E1.E1_CLIENTE, E1.E1_LOJA, E1.E1_PORTADO, E1.E1_AGEDEP, E1.E1_CONTA, F2.F2_VALBRUT, F2.F2_VALISS, A1.A1_END, A1.A1_BAIRRO, A1.A1_MUN, A1.A1_EST, A1.A1_COMPLEM, C6_NUM, C6_ITEM, C6_FILIAL FROM "
	cQuery1 += " SE1V50 AS E1"
	cQuery1 += "    INNER JOIN SA1V50 AS A1 ON A1.A1_COD = E1.E1_CLIENTE AND A1.A1_LOJA = E1.E1_LOJA AND A1.D_E_L_E_T_='' "
	cQuery1 += "    INNER JOIN SF2V50 AS F2 ON F2.F2_P_REF = 'AGLUT' AND F2.F2_CLIENTE = E1.E1_CLIENTE AND F2.F2_LOJA = E1.E1_LOJA  AND F2.D_E_L_E_T_='' "
	cQuery1 += "	INNER JOIN SC6V50 AS C6 ON C6.C6_NOTA = F2.F2_DOC AND C6.C6_SERIE = F2.F2_SERIE AND C6.C6_CLI = F2.F2_CLIENTE AND C6.C6_LOJA = F2.F2_LOJA AND C6.C6_DATFAT >= '" + DTOS(PAR01) + "' AND C6.C6_DATFAT <= '" + DTOS(PAR02) + "' AND C6.D_E_L_E_T_ = '' "
	//cQuery1 += "	INNER JOIN SD2V50 AS D2 ON C6.C6_NOTA = D2.D2_DOC AND C6.C6_SERIE = D2.D2_SERIE AND C6.C6_CLI = D2.D2_CLIENTE AND C6.C6_LOJA = D2.D2_LOJA AND C6.C6_NUM = D2.D2_PEDIDO AND C6.C6_ITEM = D2.D2_ITEMPV AND D2.D_E_L_E_T_ = '' "
	cQuery1 += "    WHERE E1.D_E_L_E_T_='' AND E1.E1_CLIENTE = '" + PAR03 + "' AND E1.E1_LOJA = '" + PAR04 + "' "
	cQuery1 += "      AND E1.E1_EMISSAO >= '" + DTOS(PAR01) + "' AND E1.E1_EMISSAO <= '" + DTOS(PAR02) + "' AND E1.E1_PREFIXO = 'AGL' "
	cQuery1 += "      AND E1.E1_NUM >= '" + PAR05 + "' AND E1.E1_NUM <= '" + PAR06 + "'
	cQuery1 += "      AND E1.E1_FILIAL = '" +xFilial("SE1")+ "'" 
	cQuery1 += "      AND A1.A1_FILIAL = '" +xFilial("SA1")+ "'"   
	cQuery1 += "      AND F2.F2_FILIAL = '" +xFilial("SF2")+ "'" 
	cQuery1 += "      AND C6.C6_FILIAL = '" +xFilial("SC6")+ "'"  
	/*/
	
 /////////////////////////////////////////////////////////////////
cPref := SE1->E1_PREFIXO

cQuery1 := " SELECT E1_FILIAL,  E1.E1_PREFIXO, E1.E1_NUM, F2.F2_EMISSAO,E1.E1_EMISSAO, E1.E1_VENCTO, E1.E1_VENCREA, E1.E1_VALOR, E1.E1_SALDO   " + CRLF
cQuery1 += "       ,E1.E1_NUMBCO, E1.E1_CLIENTE, E1.E1_LOJA, E1.E1_PORTADO, E1.E1_AGEDEP, E1.E1_CONTA " + CRLF
cQuery1 += "       ,A1.A1_COD, A1.A1_LOJA, A1.A1_NOME, A1.A1_CGC, A1.A1_CODMUN, A1.A1_CODSEG, A1.A1_END, A1.A1_BAIRRO, A1.A1_MUN, A1.A1_EST, A1.A1_COMPLEM " + CRLF
cQuery1 += "       ,F2.F2_FILIAL, F2_DOC, F2.F2_VALBRUT, F2.F2_VALISS, F2.F2_EMISSAO " + CRLF
cQuery1 += "       ,C6.C6_NUM, C6.C6_ITEM, C6_DESCRI, C6_XSTT, C6_VALOR AS XVALOR,C6_NUM, C6_ITEM, C6_FILIAL  " + CRLF
cQuery1 += " FROM " + RetSqlName("SE1") + " E1  " + CRLF
cQuery1 += " INNER JOIN  " + RetSqlName("SA1") + " A1 "+" ON A1.A1_COD = E1.E1_CLIENTE  " + CRLF
cQuery1 += "      AND A1.A1_LOJA = E1.E1_LOJA  " + CRLF
cQuery1 += "      AND A1.D_E_L_E_T_='' " + CRLF
cQuery1 += " INNER JOIN  " + RetSqlName("SF2") + " F2 "+" ON F2.F2_P_REF = 'AGLUT'  " + CRLF
cQuery1 += "      AND F2.F2_CLIENTE = '" + PAR03 + "'  " + CRLF
cQuery1 += "      AND F2.F2_LOJA = '" + PAR04 + "'  " + CRLF
cQuery1 += "      AND F2.F2_CLIENTE = E1.E1_CLIENTE  " + CRLF
cQuery1 += "      AND F2.F2_LOJA = E1.E1_LOJA   " + CRLF
cQuery1 += "      AND F2.F2_EMISSAO BETWEEN '" + DTOS(PAR01) + "' AND  '" + DTOS(PAR02) + "' " + CRLF
cQuery1 += "      AND F2.F2_FILIAL = E1.E1_FILORIG " + CRLF
cQuery1 += "      AND F2.D_E_L_E_T_='' " + CRLF
cQuery1 += " INNER JOIN  " + RetSqlName("SC6") + " C6 "+"  ON C6.C6_NOTA = F2.F2_DOC  " + CRLF
cQuery1 += "      AND C6.C6_SERIE = F2.F2_SERIE  " + CRLF
cQuery1 += "      AND C6.C6_CLI  = '" + PAR03 + "'  " + CRLF
cQuery1 += "      AND C6.C6_LOJA = '" + PAR04 + "' " + CRLF
cQuery1 += "      AND C6.C6_CLI = F2.F2_CLIENTE " + CRLF
cQuery1 += "      AND C6.C6_LOJA = F2.F2_LOJA  " + CRLF
cQuery1 += "      AND C6.C6_FILIAL = F2.F2_FILIAL " + CRLF
cQuery1 += "      AND  C6.C6_FILIAL = E1.E1_FILORIG " + CRLF
cQuery1 += "      AND C6.C6_DATFAT BETWEEN '" + DTOS(PAR01) + "' AND  '" + DTOS(PAR02) + "' " + CRLF
cQuery1 += "      AND C6.D_E_L_E_T_ = ''  " + CRLF
cQuery1 += "WHERE E1.D_E_L_E_T_=''  " + CRLF
cQuery1 += "      AND E1.E1_CLIENTE = '" + PAR03 + "'  " + CRLF
cQuery1 += "      AND E1.E1_LOJA = '" + PAR04 + "'  " + CRLF
cQuery1 += "      AND E1.E1_EMISSAO BETWEEN '" + DTOS(PAR01) + "' AND  '" + DTOS(PAR02) + "' " + CRLF
 
If cPref = 'AGL' 
   cQuery1 += "      AND E1.E1_PREFIXO = 'AGL'  " + CRLF
ElseIf cPref = 'E01' 
   cQuery1 += "      AND E1.E1_PREFIXO = 'E01' AND E1.E1_BAIXA = ''" + CRLF
Else
   cQuery1 += "     AND E1.E1_PREFIXO NOT IN('AGL','E01') AND E1.E1_BAIXA = ''" +CRLF
Endif
cQuery1 += "      AND E1.E1_NUM BETWEEN '" + PAR05 + "' AND  '" + PAR06 + "'  " + CRLF
cQuery1 += "      AND E1.E1_FILORIG = '" +xFilial("SF2")+ "'" 
cQuery1 += "      AND F2.F2_FILIAL = '" +xFilial("SF2")+ "'" 
cQuery1 += "      AND C6.C6_FILIAL = '" +xFilial("SC6")+ "'"  
cQuery1 += "      ORDER BY F2.F2_EMISSAO, F2_DOC, E1.E1_NUM " + CRLF

	
	cQuery1 := ChangeQuery(cQuery1)

	If Select( "TR1" ) > 0
		TR1->( dbCloseArea() )
	Endif

	dbUseArea( .T., "TOPCONN", TCGenQry( Nil, Nil, cQuery1 ), "TR1", .T., .F. )

	dbSelectArea("TR1")
	dbGotop()
	cIdent := TR1->E1_NUM

	ProcRegua(RecCount())
	nCSG := 1

// Posiciona o SA6 (Bancos)
	dbSelectArea("SA6")
	dbSetOrder(1)
	dbSeek(xFilial("SA6")+TR1->E1_PORTADO+TR1->E1_AGEDEP+TR1->E1_CONTA,.T.)

// Posiciona na Arq de Parametros CNAB
	dbSelectArea("SEE")
	dbSetOrder(1)
	dbSeek(xFilial("SEE")+TR1->E1_PORTADO+TR1->E1_AGEDEP+TR1->E1_CONTA,.T.)
	cCodEmp := AllTrim(SEE->EE_CODEMP)

// Posiciona o SA1 (Cliente)
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial()+TR1->E1_CLIENTE+TR1->E1_LOJA,.T.)

// Seleciona o SE1 (Contas a Receber)
	dbSelectArea("SE1")
	aDadosBanco := {SA6->A6_COD,;								// [1]Numero do Banco
	"Banco do Brasil",;										  	// [2]Nome do Banco
	SUBSTR(SA6->A6_AGENCIA,1,4),;							  	// [3]Agencia
	SUBSTR(SA6->A6_NUMCON,1,Len(AllTrim(SA6->A6_NUMCON))-1),; 	// [4]Conta Corrente
	SUBSTR(SA6->A6_NUMCON,Len(AllTrim(SA6->A6_NUMCON)),1),;	  	// [5]Digito da conta corrente
	AllTrim(SEE->EE_CODCART)}								  	// [6]Codigo da Carteira

	cNroDoc := SubStr(AllTrim(TR1->E1_NUMBCO), 1, 10)

	CB_RN_NN := Ret_cBarra(aDadosBanco[1],aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],cNroDoc,TR1->E1_SALDO,Stod(TR1->E1_VENCREA))

// 00 - HEADER
	cLin := "00"													// Tipo de Registro = 00				002
	cLin += StrZero(nCsg,12)										// Controle Sequencial de gravação		012
	cLin += PADR(cIdent,25)											// Identificador Conta Única			025
	cLin += TR1->E1_EMISSAO		                      				// Data de emissao da Fatura			008
	cLin += StrZero(Year(PAR01),4) + StrZero(Month(PAR01),2) 		// Mes Referencia                       006
	cLin += Dtos(dDataBase)                           				// Data da Geração do Arquivo           008
	cLin += TR1->E1_VENCTO											// Data de vencimento da fatura         008
	cLin += Left(SM0->M0_FAX,3)										// Código da Operadora (EOT)            003
	cLin += "VOGEL TELECOM  "										// Nome da Operadora                    015
	cLin += "0"+SM0->M0_CGC											// CNPJ da Operadora                    015
	cLin += SM0->M0_ESTCOB											// UF da Operadora                      002
	cLin += TR1->A1_COD + Space(9)									// Codigo do Cliente                    015
	cLin += LEFT(TR1->A1_NOME,30)									// Nome do Cliente						030
	cLin += "0"+TR1->A1_CGC                                        	// CNPJ do Cliente						015
	cLin += "V3R0"													// Versão do formato					004
	cLin += STRZERO(VAL(cIdent),16)									// Numero da Fatura						016
	cLin += CB_RN_NN[1]+"      "									// Código de Barras						050
	cLin += "03"													// Código de cobrança					002
	cLin += "COBRANCA SIMPLES    "                                  // Descrição da Cobrança				020
	cLin += "0000"													// Banco Cobrança						004
	cLin += "   0"													// Agencia Cobrança						004
	cLin += "         0"											// Conta Corrente Cobrança				010
	cLin += Space(35)												// Reservado para o Fisco				035
	cLin += Space(15)												// Filler								015
	cLin += Space(25)												// Campo livre para operadora			025
	cLin += "."														// Marcação de Fim						001
	cLin += cEOL


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravacao no arquivo texto. Testa por erros durante a gravacao da linha montada.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
	/*
		If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		Return
		Endif
	*/
		lRet := .F.
		Return
	Endif

	nContador := 0
	nC10	  := 0
	nC20	  := 0
	nC40	  := 0
	nC80	  := 0
	nValTot	  := 0
	nValSem   := 0
	nValImp   := 0
	nCont     := 0

	do While !Eof()

		nPos := At("STT",TR1->C6_DESCRI)
		cRecurso := ""
		cNumRec := ""
		If nPos > 0 .OR. !Empty(TR1->C6_XSTT)
			If nPos > 0
				cRecurso := Padr(AllTrim(Substr(ALLTRIM(TR1->C6_DESCRI),nPos)), 25)
				cNumRec  := Padr("STT-" +AllTrim(Substr(TR1->C6_DESCRI,nPos + 4)), 16)
			Else
				cRecurso := TR1->C6_XSTT + "          "
				cNumRec := TR1->C6_XSTT + " "
			Endif
		Else
			dbSelectArea("TR1")
			dbSkip()
			Loop
		Endif

		dbSelectArea("SD2")
		dbSetOrder(8)
		dbSeek(TR1->C6_FILIAL + TR1->C6_NUM + TR1->C6_ITEM)
	
		nValor := TR1->XVALOR - SD2->D2_DESCON // TR1->C6_VALOR // F2_VALBRUT - TR1->F2_VALISS
		nValTot += nValor
		nValSem += TR1->XVALOR - SD2->D2_DESCON - SD2->D2_VALISS - SD2->D2_VALCSL - SD2->D2_VALCOF - SD2->D2_VALPIS
		nValImp += SD2->D2_VALISS + SD2->D2_VALCSL + SD2->D2_VALCOF + SD2->D2_VALPIS
		nCont++


		If "SCM" $ TR1->C6_DESCRI
			cModal := "SCM "
		Else
			cModal := "STFC"
		Endif

		dbSelectArea("TR1")
		dbSkip()
	EndDo
	dbGotop()

	If !Empty(cNumRec)
		nCSG++
		nC10++

		//10 - RESUMO
		cLin := "10"													// Tipo de Registro = 10				002
		cLin += StrZero(nCsg,12)										// Controle Sequencial de gravação		012
		cLin += PADR(cIdent,25)											// Identificador Conta Única			025
		cLin += TR1->E1_EMISSAO		                      				// Data de emissao da Fatura			008
		cLin += StrZero(Year(PAR01),4) + StrZero(Month(PAR01),2) 		// Mes Referencia                       006
		cLin += cRecurso												// Identificador Unico do Recurso		025
		cLin += LEFT(TR1->A1_CODSEG,5)									// CNL do Recurso						005
		cLin += cNumRec													// Numero do Recurso					016
		cLin += cModal													// Modalidade							004
		cLin += "00000000"												// Data de ativação do serviço			008
		cLin += "00000000"												// Data de desativação do serviço		008
		cLin += "000000000"												// Qtd de registros 30 (chamadas)		009
		cLin += "0000000000000"											// Valor total dos registros 30			013
		cLin += StrZero(nCont,9)										// Qtd de registros 40 (serviços)		009
		cLin += StrZero(nValtot*10000,15)								// Valor total dos registros 40			015
		cLin += StrZero(nValImp*100,13)									// Valor total dos impostos				013
		cLin += StrZero(nValsem*100,13)									// Valor total							013
		cLin += "  "													// Degrau tarifário						002
		cLin += Space(5)												// Velocidade do Recurso				005
		cLin += Space(4)												// Unidade da velocidade do recurso		004
		cLin += TR1->E1_VENCTO											// Vencimento							008
		cLin += Space(114)												// Filler								114
		cLin += Space(25)												// Campo Livre para operadora			025
		cLin += "."														// Marcação de Fim						001
		cLin += cEOL

		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		/*
		Alert("Ocorreu um erro na gravacao do arquivo")
		*/   
			lRet := .F.
		Endif

		nCsg++
		nC20++

		//20 - ENDERECOS
		cLin := "20"													// Tipo de Registro = 20				002
		cLin += StrZero(nCsg,12)										// Controle Sequencial de gravação		012
		cLin += PADR(cIdent,25)											// Identificador Conta Única			025
		cLin += TR1->E1_EMISSAO		                      				// Data de emissao da Fatura			008
		cLin += StrZero(Year(PAR01),4) + StrZero(Month(PAR01),2) 		// Mes Referencia                       006
		cLin += cRecurso												// Identificador Unico do Recurso		025
		cLin += cNumRec													// Numero do Recurso					016
		cLin += LEFT(TR1->A1_CODSEG,5)									// CNL do Recurso Ponta A				005
		cLin += LEFT(TR1->A1_MUN,15)									// Localidade Ponta A					015
		cLin += TR1->A1_EST												// UF Ponta A							002
		cLin += LEFT(TR1->A1_END,30)									// Endereço Ponta A						030
		cLin += "00000"													// Nº endereço Ponta A					005
		cLin += LEFT(TR1->A1_COMPLEM,8)									// Complemento Ponta A					008
		cLin += LEFT(TR1->A1_BAIRRO,10)									// Bairro Ponta A						010

		cLin += SPACE(5)      											// CNL do Recurso Ponta B				005
		cLin += SPACE(15)           									// Localidade Ponta B					015
		cLin += SPACE(2)   												// UF Ponta B							002
		cLin += SPACE(30)           									// Endereço Ponta B						030
		cLin += SPACE(5)												// Nº endereço Ponta B					005
		cLin += SPACE(8)               									// Complemento Ponta B					008
		cLin += SPACE(10)              									// Bairro Ponta B						010

		cLin += SPACE(5)      											// CNL do Recurso Ponta C				005
		cLin += SPACE(15)           									// Localidade Ponta C					015
		cLin += SPACE(2)   												// UF Ponta C							002
		cLin += SPACE(30)           									// Endereço Ponta C						030
		cLin += SPACE(5)												// Nº endereço Ponta C					005
		cLin += SPACE(8)               									// Complemento Ponta C					008
		cLin += SPACE(10)              									// Bairro Ponta C						010

		cLin += Space(5)												// Filler                               005
		cLin += Space(25)												// Campo Livre para operadora			025
		cLin += "."														// Marcação de Fim						001
		cLin += cEOL

		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		/*
		Alert("Ocorreu um erro na gravacao do arquivo.")
		*/   
			lRet := .F.
		Endif


		nContador := 0
		nValNot	  := 0
		nValTot	  := 0
		nValImp   := 0

		dbSelectArea("TR1")
		dbGotop()
		cNota := TR1->F2_DOC

		do While !Eof()

			nPos := At("STT",TR1->C6_DESCRI)
			cRecurso := ""
			cNumRec := ""

			If nPos > 0 .OR. !Empty(TR1->C6_XSTT)
				If nPos > 0
					cRecurso := Padr(AllTrim(Substr(ALLTRIM(TR1->C6_DESCRI),nPos)), 25)
					cNumRec  := Padr("STT-" +AllTrim(Substr(TR1->C6_DESCRI,nPos + 4)), 16)
				Else
					cRecurso := TR1->C6_XSTT + "          "
					cNumRec := TR1->C6_XSTT + " "
				Endif
			Else
				dbSelectArea("TR1")
				dbSkip()
				Loop
			Endif



			dbSelectArea("SD2")
			dbSetOrder(8)
			dbSeek(TR1->C6_FILIAL + TR1->C6_NUM + TR1->C6_ITEM)

			nValor := TR1->XVALOR - SD2->D2_DESCON // TR1->C6_VALOR // F2_VALBRUT - TR1->F2_VALISS
			nValSem := TR1->XVALOR - SD2->D2_DESCON - SD2->D2_VALISS - SD2->D2_VALCSL - SD2->D2_VALCOF - SD2->D2_VALPIS
			nValNot += nValor
			nValTot += nValor        
			nValImp += SD2->D2_VALISS + SD2->D2_VALCSL + SD2->D2_VALCOF + SD2->D2_VALPIS
			nCont++

			dbSelectArea("TR1")

			If "SCM" $ TR1->C6_DESCRI
				cModal := "SCM "
			Else
				cModal := "STFC"
			Endif

			nContador++

			nCsg++
			nC40++

			// 40 - Servicos
			cLin := "40"													// Tipo de Registro = 20				002
			cLin += StrZero(nCsg,12)										// Controle Sequencial de gravação		012
			cLin += PADR(cIdent,25)											// Identificador Conta Única			025
			cLin += TR1->E1_EMISSAO		                      				// Data de emissao da Fatura			008
			cLin += StrZero(Year(PAR01),4) + StrZero(Month(PAR01),2) 		// Mes Referencia                       006
			cLin += cRecurso												// Identificador Unico do Recurso		025
			cLin += LEFT(TR1->A1_CODSEG,5)									// CNL                   				005
			cLin += cNumRec													// Numero do Recurso					016
			cLin += TR1->E1_EMISSAO											// Data do Servico						005
			cLin += "  "													// Codigo Nacional / Internacional      002
			cLin += Space(17)												// Numero Destino						017
			cLin += Space(5)												// Codigo Operadora Roaming				005
			cLin += Space(3)												// EOT Operadora (portabilidade)		003
			cLin += StrZero(aDias[Month(PAR01)],6)    						// Quantidade (dias)					006
			cLin += "DD"													// Unidade do Serviço (DD = Dias)		002
			cLin += Space(6)												// Horario do Serviço					006
			cLin += "205"													// Cod da Categoria do Servico			003
			cLin += "STD"													// Sigla da Categoria do Servico		003
			cLin += "TRAFEGO DADOS            "								// Descricao da Categoria do Servico	025
			cLin += StrZero(nValor*100,13)									// Valor total com impostos				013
			cLin += StrZero(nValSem*10000,15)								// Valor total sem impostos				015
			cLin += "1"														// Tipo Nota (1 = propria)				001
			cLin += TR1->F2_DOC + "   "										// Numero da NF							012
			cLin += Space(104)												// Filler								104
			cLin += Space(25)												// Campo Livre para operadora			025
			cLin += "."														// Marcação de Fim						001
			cLin += cEOL

			If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		/*
				If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
				Exit
				Endif
		*/              
				lRet := .F.
				Exit
			Endif

			cEmis	:= TR1->E1_EMISSAO
			cVencto := TR1->E1_VENCTO

			dbSelectArea("TR1")
			dbSkip()

			If TR1->(EOF()) .or. TR1->F2_DOC <> cNota

				nCsg++
				nC80++

				//80 - NOTA FISCAL
				cLin := "80"													// Tipo de Registro = 80				002
				cLin += StrZero(nCsg,12)										// Controle Sequencial de gravação		012
				cLin += PADR(cIdent,25)											// Identificador Conta Única			025
				cLin += cEmis				                      				// Data de emissao da Fatura			008
				cLin += StrZero(Year(PAR01),4) + StrZero(Month(PAR01),2) 		// Mes Referencia                       006
				cLin += cVencto													// Data de vencimento da fatura         008
				cLin += Left(SM0->M0_FAX,3)										// Código da Operadora (EOT)            003
				cLin += "VOGEL TELECOM  "										// Nome da Operadora                    015
				cLin += "0"+SM0->M0_CGC											// CNPJ da Operadora                    015
				cLin += StrZero(nValNot*100,13)									// Valor total							013
				cLin += "1"														// Tipo da Nota Fiscal (1 = propria)	001
				cLin += Padr(cNota,12)											// Numero da Nota Fiscal				012
				cLin += Space(204)												// Filler								204
				cLin += Space(25)												// Campo Livre para operadora			025
				cLin += "."														// Marcação de Fim						001
				cLin += cEOL

				If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
				/*
					If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
					Exit
					Endif
				*/
					lRet := .F.
					Exit
				Endif

				nValNot := 0
				cNota	:= TR1->F2_DOC
			Endif
		EndDo
	Endif

	nCsg++
	TR1->(dbGotop())

//99 - TRAILER
	cLin := "99"													// Tipo de Registro = 99				002
	cLin += StrZero(nCsg,12)										// Controle Sequencial de gravação		012
	cLin += PADR(cIdent,25)											// Identificador Conta Única			025
	cLin += TR1->E1_EMISSAO		                      				// Data de emissao da Fatura			008
	cLin += StrZero(Year(PAR01),4) + StrZero(Month(PAR01),2) 		// Mes Referencia                       006
	cLin += TR1->E1_VENCTO											// Data de vencimento da fatura         008
	cLin += TR1->A1_COD + Space(9)                                  // Codigo do Cliente                    015
	cLin += StrZero(nValTot*100,13)									// Valor total							013
	cLin += StrZero(nCsg,12)										// Quantidade Total de Registros		012
	cLin += StrZero(nValTot*100,13)									// Valor Total Registros tipo 10		013
	cLin += StrZero(nC10,9)											// Quantidade Registros tipo 10			009
	cLin += StrZero(nC20,9)											// Quantidade Registros tipo 20			009
	cLin += StrZero(0,13)											// Valor Total Registros tipo 30		013
	cLin += StrZero(0,9)											// Quantidade Registros tipo 30			009
	cLin += StrZero(nValTot,13)										// Valor Total Registros tipo 40		013
	cLin += StrZero(nC40,9)											// Quantidade Registros tipo 40			009
	cLin += "-"														// Sinal de negativo					001
	cLin += StrZero(0,13)											// Valor Total Registros tipo 50		013
	cLin += StrZero(0,9)											// Quantidade Registros tipo 50			009
	cLin += StrZero(0,13)											// Valor Total Registros tipo 60		013
	cLin += StrZero(0,9)											// Quantidade Registros tipo 60			009
	cLin += "+"														// Sinal de positivo					001
	cLin += StrZero(0,13)											// Valor Total Registros tipo 70		013
	cLin += StrZero(0,9)											// Quantidade Registros tipo 70			009
	cLin += StrZero(nValTot*100,13)									// Valor Total Registros tipo 80		013
	cLin += StrZero(nC80,9)											// Quantidade Registros tipo 80			009
	cLin += Space(58)												// Filler								058
	cLin += Space(25)												// Campo Livre para operadora			025
	cLin += "."														// Marcação de Fim						001
	cLin += cEOL

	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
	/*
		If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		Return
		Endif
	*/          
		lRet := .F.
		Return
	Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ O arquivo texto deve ser fechado, bem como o dialogo criado na funcao anterior.                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	fClose(nHdl)
//	Close(oGeraTxt)

Return


/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³Ret_cBarra³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASE DO ITAU COM CODIGO DE BARRAS      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cNroDoc,nValor,dVencto)

	LOCAL cValorFinal 	:= strzero((nValor*100),10)
	LOCAL nDvnn			:= 0
	LOCAL nDvcb			:= 0
	LOCAL nDv			:= 0
	LOCAL cNN			:= ''
	LOCAL cRN			:= ''
	LOCAL cCB			:= ''
	LOCAL cS			:= ''
	LOCAL cFator      	:= Strzero(dVencto - ctod("07/10/97"),4)
	LOCAL cCart			:= AllTrim(SEE->EE_CODCART) //"17" // Código da carteira (2 caracteres).
	Local _cConvenio    := SubStr(AllTrim(SEE->EE_CODEMP), 1, 7) // Codigo do convenio. (7 caracteres).
	Local _nMoeda       := '9' // Codigo da moeda.

//-----------------------------
// Definicao do NOSSO NUMERO
// ----------------------------
//cS    :=  cCart + cNroDoc //19 001000012
	cS    := cNroDoc
	nDvnn := modulo11(cS,.F.) // digito verifacador
	cNNSD := cS //Nosso Numero sem digito
	cNNCD := PADL(cS+AllTrim(Str(nDvnn)),13,'0')
	cNN   := _cConvenio + cNroDoc + '-' + AllTrim(Str(nDvnn))
//----------------------------------
//	 Definicao do CODIGO DE BARRAS
//----------------------------------
	cLivre 	:= Strzero(Val(cAgencia),4)+ cCart + cNNSD + Strzero(Val(cConta),8) + "0"

//cS		:= cBanco + cFator +  cValorFinal + cLivre // + Subs(cNN,1,11) + Subs(cNN,13,1) + cAgencia + cConta + cDacCC + '000'
	cS		:= cBanco + _nMoeda + cFator + cValorFinal + '000000' + _cConvenio + cNroDoc + cCart
	nDvcb 	:= modulo11(cS,.T.)
	cCB   	:= SubStr(cS, 1, 4) + AllTrim(Str(nDvcb)) + SubStr(cS,5)// + SubStr(cS,31)

//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
//	Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
//	AAABC.CCCCX		WWWDD.DDDDDY	FFFFF.FQQQQZ	K			UUUUVVVVVVVVVV

// 	CAMPO 1:
//	AAA	= Codigo do banco na Camara de Compensacao
//	B     = Codigo da moeda, sempre 9
//	CCCCC = 5 primeiros digidos do cLivre
//	X     = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

//**CEDENTE
	cCedente:=SUBSTR(cCodEmp,1,4)// "4806"
//cS    := cBanco + "9" + Substr(cLivre,1,4)
	cS    := cBanco + _nMoeda + SubStr(cCB, 20, 5)
	nDv   := modulo10(cS)  //DAC
	cRN   := SubStr(cS, 1, 5) + '.' + SubStr(cS, 6, 4) + AllTrim(Str(nDv)) + '  '

// 	CAMPO 2:
//	WWW =COD CEDENTE PADRAO
//	DDDDDDD = Posição 14 a 20 do Nosso Numero
//	Y          = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

//**Complemento Cedente
	cCompCed:=SUBSTR(cCodEmp,5,3) //"301"
//cS 	:=Subs(cLivre,6,10)
	cS 	:= SubStr(cCB, 25, 10)
	nDv	:= modulo10(cS)
	cRN	+= SubStr(cS, 1, 5) + '.' + SubStr(cS, 6, 5) + AllTrim(Str(nDv)) + '  '

// 	CAMPO 3:
//	FFFFFF = Posição 22 a 27 do Nosso Numero
//	QQQQ =Tipo de modalidade
//	Z          = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

//**Tipo de modalidade
	cS 	:= SubStr(cCB, 35, 10)
	nDv	:= modulo10(cS)
	cRN	+= SubStr(cS, 1, 5) + '.' + SubStr(cS, 6, 5) + AllTrim(Str(nDv)) + ' '

//	CAMPO 4:
//	     K = DAC do Codigo de Barras
	cRN += AllTrim(Str(nDvcb)) + '  '

// 	CAMPO 5:
//	      UUUU = Fator de Vencimento
//	VVVVVVVVVV = Valor do Titulo
	cRN  += cFator + StrZero((nValor * 100), 14 - Len(cFator))

Return({cCB,cRN,cNN})



/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³ Funcao    ³ MODULO10()  ³ Autor ³ Flavio Novaes    ³ Data ³ 03/02/2005 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Descricao ³ Impressao de Boleto Bancario do Banco Santander com Codigo ³±±
	±±³           ³ de Barras, Linha Digitavel e Nosso Numero.                 ³±±
	±±³           ³ Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso       ³ FINANCEIRO                                                 ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION Modulo10(cData)
	LOCAL L,D,P := 0
	LOCAL B     := .F.
	L := Len(cData)
	B := .T.
	D := 0
	WHILE L > 0
		P := VAL(SUBSTR(cData, L, 1))
		IF (B)
			P := P * 2
			IF P > 9
				P := P - 9
			ENDIF
		ENDIF
		D := D + P
		L := L - 1
		B := !B
	ENDDO
	D := 10 - (Mod(D,10))
	IF D = 10
		D := 0
	ENDIF
RETURN(D)





/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³ Funcao    ³ MODULO11()  ³ Autor ³ Flavio Novaes    ³ Data ³ 03/02/2005 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Descricao ³ Impressao de Boleto Bancario do Banco Santander com Codigo ³±±
	±±³           ³ de Barras, Linha Digitavel e Nosso Numero.                 ³±±
	±±³           ³ Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso       ³ FINANCEIRO                                                 ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION Modulo11(cData,lCodBarra)
	LOCAL L, D, P := 0
	Default lCodBarra := .F.


	L := LEN(cdata)
	D := 0
	P := 1
	WHILE L > 0
		P := P + 1
		D := D + (VAL(SUBSTR(cData, L, 1)) * P)
		IF P == 9
			P := 1
		ENDIF
		L := L - 1
	ENDDO

	D := (mod(D,11))

//Tratamento para digito verificador.
	If lCodBarra //Codigo de Barras
		//Se o resto for 0,1 ou 10 o digito é 1
		IF (D == 0 .Or. D == 1 .Or. D == 10)
			D := 1
		ELSE
			D := 11 - (mod(D,11))
		ENDIF
	Else //Nosso Numero
		IF (D == 0 .Or. D == 1 .Or. D == 10)
			//Se o resto for 0 ou 1 o digito é 0
			IF (D == 0 .Or. D == 1)
				D := 0

				//Se o resto for 10 o digito é 1
			ELSEIF (D == 10)
				D := 1
			ENDIF
		ELSE
			D := 11 - (mod(D,11))
		ENDIF
	EndIf

RETURN(D)
