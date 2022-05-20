#Include "Matr120.ch"
#Include "PROTHEUS.CH"
//#Include "FIVEWIN.Ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR120  ³ Autor ³ Claudinei M. Benzi    ³ Data ³ 05.09.91  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emiss„o da Rela‡„o de Pedidos de Compras                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Rogerio F.G.  ³05/12/97³08197A³Inclusao do Telefone do Fornecedor       ³±±
±±³Rogerio F.G.  ³05/12/97³10426A³Alteracao da Picture Cpo C7_PRECO        ³±±
±±³Edson   M.    ³25/02/98³XXXXXX³Acerto da impressao dos Totais.          ³±±
±±³Bruno         ³10/12/98³Melhor³Acerto da impressao das A.E.(Argentina) .³±±
±±³Viviani       ³29/12/98³19074 ³Acerto do calculo total geral c/ desconto³±±
±±³Viviani       ³29/12/98³10634 ³Inclusao de fax e contato na ordem 3     ³±±
±±³Edson   M.    ³23/03/99³XXXXXX³Correcao no calculo do IPI.              ³±±
±±³Fernando Joly ³20/04/99³XXXXXX³Consistir SC's Firmes e Previstas.       ³±±
±±³Percy A Horna ³15/08/01³xxxxxx³Inclusao da funcao xMoeda() p/impressao  ³±±
±±³              ³        ³      ³em multimoeda, dependendo do parametro   ³±±
±±³              ³        ³      ³escolhido no grupo de perguntas do SX1.  ³±±
±±³              ³        ³      ³Impressao valores de impostos localizados³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function Relpca()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL CbTxt  := ""
Local wnrel  := ""
LOCAL cDesc1 :=STR0001	//"Emissao da Relacao de  Pedidos de Compras."
LOCAL cDesc2 :=STR0002	//"Sera solicitado em qual Ordem, qual o Intervalo para"
LOCAL cDesc3 :=STR0003	//"a emissao dos pedidos de compras."
LOCAL aOrd   := {STR0004,STR0005,STR0006}		//" Por Numero         "###" Por Produto        "###" Por Fornecedor   "

PRIVATE aTamSXG  := TamSXG("001")
PRIVATE nDifNome := 0
PRIVATE nTamNome := 35
PRIVATE titulo   :=STR0007	//"Relacao de Pedidos de Compras"
PRIVATE cPerg    := PadR( "RELPCA" , Len( SX1->X1_GRUPO ) )
PRIVATE cString  := "SC7"
PRIVATE aReturn  := { STR0008, 1,STR0009, 1, 2, 1, "",1 }		//"Zebrado"###"Administracao"
PRIVATE nomeprog := "RELPCA"
PRIVATE nLastKey := 0 
PRIVATE aLinha   := { }
PRIVATE LIMITE   :=220
PRIVATE cabec1   := ""
PRIVATE cabec2   := ""
PRIVATE tamanho  := "G"
PRIVATE oProcess 

If aTamSXG[1] != aTamSXG[3]
	nDifNome := aTamSXG[4] - aTamSXG[3]
	nTamNome := if(aTamSXG[1] != aTamSXG[3],35-(aTamSXG[4]-aTamSXG[3]),35)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Imprime  := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AjustaSX1()
Pergunte("RELPCA",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01       // do produto                                 ³
//³ mv_par02       // ate o produto                              ³
//³ mv_par03       // data de emissao de                         ³
//³ mv_par04       // data de emissao ate                        ³
//³ mv_par05       // data de entrega inicial                    ³
//³ mv_par06       // data de entrega final                      ³
//³ mv_par07       // todas ou em aberto ou residuos ou atendidos³
//³ mv_par08       // pedido inicial                             ³
//³ mv_par09       // pedido final                               ³
//³ mv_par10       // Listar  PC    AE    Ambos                  ³
//³ mv_par11       // Pedidos Liberados  Bloqueados Ambos        ³
//³ mv_par12       // Impr. SC's Firmes, Previstas ou Ambas      ³
//³ mv_par13       // Qual Moeda                                 ³
//³ mv_par14       // Descricao do produto                       ³
//³ mv_par15       // Fornecedor de                              ³
//³ mv_par16       // Fornecedor ate                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := "RELPCA"
wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.f.,Tamanho)

If nLastKey == 27
	Set Filter To
	Return
Endif
SetDefault(aReturn,cString)
If nLastKey == 27
	Set Filter To
	Return
Endif

///RptStatus({|lEnd| R120Imp(@lEnd,tamanho,wnrel,cString)},Titulo)
   oProcess := MsNewProcess():New( { ||  R120Imp(@lEnd,tamanho,wnrel,cString,@oProcess)  } , Titulo , "Aguarde..." , .F. )
   oProcess:Activate()	
     
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R120IMP  ³ Autor ³ Cristina M. Ogura     ³ Data ³ 10.11.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R120Imp(lEnd,tamanho,wnrel,cString,oProcess)

LOCAL cbtxt := SPACE(10)
LOCAL nQuebra,cCabQuebra,cQuebrant,cCOndBus
LOCAL CbCont
LOCAL nQuant_a_Rec := 0
Local nTotParc := 0
Local nTxMoeda := 1
Local _nTotR1 := 0

CbCont   := 00
nQuebra  := 00
li       := 80
m_pag    := 01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Totalizar os valores do relatorio  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nT_qtd_ped := 0		// qtde pedida
nT_vl_ipi  := 0		// valor do ipi
nT_vl_total:= 0      // valor total do pedido
nT_qtd_entr:= 0		// qtde entregue
nT_sd_receb:= 0		// saldo a receber
nT_desc    := 0		// total de desconto
nTotIVA    := 0    // Total de IVA (impostos)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Totalizar os valores p/ item de acordo com a ordem ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPedida    := 0	// qtde pedida
nValIpi    := 0 	// valor do ipi
nTotal     := 0   // valor total do pedido
nQuant     := 0	// qtde entregue
nSaldo     := 0 	// saldo a receber
nFlag		  := 0	// flag que indica se imprime totais por item ou nao
nITemIpi   := 0
nSalIpi    := 0
nFrete	  := 0	// valor do frete
nDesc      := 0 	// valor do desconto
nValIVA    := 0     // valor do IVA
nItemIVA   := 0     // valor do item do imposto

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os Cabecalhos de acordo com os parametros              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cabec1    := STR0011		//"RELACAO DOS PEDIDOS DE COMPRAS"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Localiza o ponto inicial para a impressao                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nOrdem := aReturn[8]

dbSelectArea("SC7")
dbSetOrder(nOrdem)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica qual ordem foi selecionada                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica qual ordem foi selecionada                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOrdem == 1
	If ( cPaisLoc$"ARG|POR|EUA" )	//Ordena los pedidos de compra y luego la AE.
		DbSetOrder(10)
		cCondBus	:=	"0"+MV_PAR08
	Else
		cCondBus	:=	mv_par08
	EndIf
	
	dbSeek(xFilial("SC7")+cCondBus,.T.)
	cCampo     := "SC7->C7_NUM"

	If mv_par10 == 2
		cTexQuebra := STR0012	//"AUTOR. N. : "
	Else
		cTexQuebra := STR0013	//"PEDIDO N. : "
	EndIf
	titulo     += STR0014		//" - POR NUMERO"
	
	// Verifica se utilizara LayOut Maximo
	if aTamSXG[1] != aTamSXG[3]
		cabec1 := "ITEM CODIGO          DESCRICAO                         CODIGO               RAZAO SOCIAL          DATA DE  ENTREGA   QUANTIDADE  UM     VALOR        VALOR         VALOR TOTAL  QUANT.      QUANT. A      SALDO   CONFIRM DENOMINACAO                    NCM             LOCALIZACAO"
		//		   0         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20
		//         0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	Else
		cabec1 := "ITEM CODIGO          DESCRICAO                         CODIGO RAZAO SOCIAL                 OP     DATA DE  ENTREGA   QUANTIDADE  UM     VALOR        VALOR         VALOR TOTAL  QUANT.      QUANT. A      SALDO   CONFIRM DENOMINACAO                    NCM             LOCALIZACAO"
		//                      1         2         3         4         5         6         7         8         9        10        11        12        13   X    14        X5        16   X    17        18        19        20        10
		//                      0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	Endif
		cabec2 := "     PRODUTO         DO PRODUTO                        FORN.                                      EMISSAO  PREVISTA      PEDIDA           UNIT.        IPI             (C/IPI)   ENTREGUE    RECEBER    RECEBER        DENOMINACAO                    NCM             LOCALIZACAO"	
ElseIf nOrdem == 2
	dbSeek(xFilial("SC7")+mv_par01,.T.)
	cCampo     := "SC7->C7_CODLMT"
	cTexQuebra := STR0017	//"PRODUTO : "
	titulo     += STR0018	//" - POR PRODUTO"
	If ( cPaisLoc$"ARG|POR|EUA" )
		cabec1 :=	STR0043 //"PED/AE ITEM  DATA         CODIGO RAZAO SOCIAL                            FONE        ENTREGA      QUANTIDADE          VALOR         VALOR      PRECO TOTAL        QUANTIDADE      QUANT. A       SALDO     RESIDUOS"
	EndIf
	// Verifica se utilizara LayOut Maximo
	if aTamSXG[1] != aTamSXG[3]
		cabec1 := "PEDIDO ITEM  DATA      CODIGO               RAZAO SOCIAL             OP           ENTREGA         QUANTIDADE           VALOR    DESCONTO           VALOR     PRECO TOTAL      QUANTIDADE   QUANT. A      SALDO CONFIRMACAO DENOMINACAO                    NCM             LOCALIZACAO"
		//							 123456  12  99/99/9999 12345678901234567890 123456789012345678901 12345789012345 12/34/5678 123456789012345 123456789012345 123456789012 1234567890123 123456789012345 123456789012345 1234567890 123456789012345   Sim
		//							 1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21
		//							 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	Else
		cabec1 := "PEDIDO ITEM  DATA      CODIGO RAZAO SOCIAL                           OP           ENTREGA         QUANTIDADE           VALOR    DESCONTO           VALOR     PRECO TOTAL      QUANTIDADE   QUANT. A      SALDO CONFIRMACAO DENOMINACAO                    NCM             LOCALIZACAO"
		//		  					 123456  12  99/99/9999 123456 12345678901234567890123456789012345 12345789012345 12/34/5678 123456789012345 123456789012345 123456789012 1234567890123 123456789012345 123456789012345 1234567890 123456789012345   Sim
		//							 1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21
		//							 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	Endif
	cabec2 := STR0020 //"             EMISSAO   FORN.                                      FORN.           PREVISTA            PEDIDA        UNITARIO                         IPI       (C/IPI)          ENTREGUE    RECEBER        RECEBER ELIMINADOS"
Else				// Ordem == 3
	dbSeek(xFilial("SC7"))
	cCampo     := "SC7->C7_FORNECE+SC7->C7_LOJA"
	cTexQuebra := STR0021	//"FORNECEDOR : "
	titulo     += STR0022	//" - POR FORNECEDOR"
	If ( cPaisLoc$"ARG|POR|EUA" )
		cabec1 := "PED/AE ITEM  DATA     CODIGO           DESCRICAO DO PRODUTO              OP     ENTREGA     QUANTIDADE            PRECO            VALOR       PRECO TOTAL        QUANTIDADE      QUANT. A       SALDO     CONFIRMACAO DENOMINACAO                    NCM             LOCALIZACAO"
	Else
		cabec1 := "PEDIDO ITEM  DATA     CODIGO           DESCRICAO DO PRODUTO              OP     ENTREGA     QUANTIDADE            PRECO            VALOR       PRECO TOTAL        QUANTIDADE      QUANT. A       SALDO     CONFIRMACAO DENOMINACAO                    NCM             LOCALIZACAO"
	EndIf
	cabec2 :=     "NUMERO       EMISSAO  PRODUTO                                                   PREVISTA        PEDIDA         UNITARIO              IPI         (C/IPI)            ENTREGUE    RECEBER        RECEBER             "
	//             123456  12  12/45/78 123456789012345 123456789012345678901234567890 1234  12/34/56 123456789012345 123456789012345 123456789012 1234567890123 123456789012345 123456789012345 1234567890 123456789012345   Sim
	//             1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22        23
	//             01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890

	cabec1 := "PEDIDO ÍTEM DATA     CÓDIGO          DESCRIÇÃO DO PRODUTO           COD.PRODUTO FORNEC.  ENTREGA   QUANTIDADE         PREÇO         VALOR   PREÇO TOTAL  QUANTIDADE    QUANT. A         SALDO     CONFIRMACAO DENOMINACAO                    NCM             LOCALIZACAO"
	cabec2 := "NÚMERO      EMISSÃO  PRODUTO                                                             PREVISTA      PEDIDA      UNITÁRIO           IPI       (C/IPI)    ENTREGUE     RECEBER       RECEBER             "
	//         123456 1234 11/11/11 123456789012345 123456789012345678901234567890 12345678901234567890 11/11/11 999,999.999 99,999,999.99 99,999,999.99 99,999,999.99 999,999.999 999,999.999 99,999,999.99 12345678901234567890
	//                   1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
	//         01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
Endif

If mv_par07==1
	titulo+=STR0025	//", Todos"
Elseif mv_par07==2
	titulo+=STR0026	//", Em Abertos"
Elseif mv_par07==3
	titulo+=STR0027	//", Residuos"
Elseif mv_par07==4
	titulo+=STR0028	//", Atendidos"
Endif

titulo += " - " + GetMv("MV_MOEDA"+STR(mv_par13,1))		//" MOEDA "
////SetRegua(RecCount())

SC7->( dbEVal( { || ++_nTotR1 } , {||!EOF()} ) )
SC7->(dbgotop()) 

oProcess:SetRegua1( _nTotR1 )
oProcess:SetRegua2( _nTotR1 ) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia a leitura do arquivo SC7                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do While !Eof() .And. C7_FILIAL = xFilial()

    nTxMoeda := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,Nil)
	////IncRegua()
	If lEnd
		@PROW()+1,001 PSAY STR0029	//"CANCELADO PELO OPERADOR"
		Exit
	Endif
	
	oProcess:IncRegua1('Processando...  '       )
	oProcess:IncRegua2('Pedido de Compra...  '  + Alltrim(SC7->C7_NUM)   ) 
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste este item. POR PEDIDO                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If C7_NUM < mv_par08 .Or. C7_NUM > mv_par09
		dbSkip()
		Loop
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste este item. POR PRODUTO                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If C7_CODLMT < mv_par01 .Or. C7_CODLMT > mv_par02
		dbSkip()
		Loop
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste este item. POR EMISSAO                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If C7_EMISSAO < mv_par03 .Or. C7_EMISSAO > mv_par04
		dbSkip()
		Loop
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste este item. POR DATA ENTREGA                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If C7_DATPRF < mv_par05 .Or. C7_DATPRF > mv_par06
		dbSkip()
		Loop
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste se o pedidos esta liberado.                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (C7_CONAPRO == "B" .And. mv_par11 == 1) .Or.;
	   (C7_CONAPRO != "B" .And. mv_par11 == 2)
		dbSkip()
		Loop
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste este item. EM ABERTO                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par07 == 2
		If C7_QUANT-C7_QUJE <= 0 .Or. !EMPTY(C7_RESIDUO)
			dbSkip()
			Loop
		Endif
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste este item. RESIDUOS                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par07 == 3
		If EMPTY(C7_RESIDUO)
			dbSkip()
			Loop
		Endif
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste este item. ATENDIDOS                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par07 == 4
		If C7_QUANT > C7_QUJE
			dbSkip()
			Loop
		Endif
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste Tipo	de Pedido  1-PC    2-AE    3-Ambos             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par10 == 1 .And. C7_TIPO != 1
		dbSkip()
		Loop
	ElseIf mv_par10 == 2 .And.	C7_TIPO !=2
		dbSkip()
		Loop
	Endif
  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste este item. por fornecedor                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If C7_FORNECE < mv_par15 .Or. C7_FORNECE > mv_par16
		dbSkip()
		Loop
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtra Tipo de SCs Firmes ou Previstas                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !MtrAValOP(mv_par12, 'SC7')
		dbSkip()
		Loop
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se e nova pagina                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If li > 55                                       
	   @ 00,00 PSAY CHR(15) 
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
	Endif

	If nQuebra == 0
		cQuebrant := &cCampo
		li++
		If li > 55
	      @ 00,00 PSAY CHR(15) 
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
		Endif
		If nOrdem = 1
			cCabQuebra := " "
		ElseIf nOrdem = 2                                      
			dbSelectArea("SC7")
			cCabQuebra := Alltrim(SC7->C7_DESCRI)

			If Empty(mv_par14)
				mv_par14 := "B1_DESC"
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Impressao da descricao generica do Produto.                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If AllTrim(mv_par14) == "B1_DESC"
				dbSelectArea("SB1")
				dbSetOrder(1)
				dbSeek(cFilial+&cCampo)
				cCabQuebra := Alltrim(SB1->B1_DESC)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Impressao da descricao cientifica do Produto.                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If AllTrim(mv_par14) == "B5_CEME"
				dbSelectArea("SB5")
				dbSetOrder(1)
				If dbSeek(cFilial+&cCampo)
					cCabQuebra := Alltrim(B5_CEME)
				EndIf
			EndIf
			
			dbSelectArea("SC7")
			If AllTrim(mv_par14) == "C7_DESCRI"
				cCabQuebra := Alltrim(SC7->C7_DESCRI)
			EndIf
		ElseIf nOrdem = 3
			dbSelectArea("SA2")
			dbSeek(cFilial+&cCampo)
			cCabQuebra := A2_NOME
		Endif
		If ( cPaisLoc$"ARG|POR|EUA" ).AND.mv_par10==3.And.nOrdem==1
			If ( SC7->C7_TIPO==2 )
				@ li,000 PSAY STR0012 + &cCampo + " " + Substr(cCabQuebra,1,(nTamNome-5))
			Else
		        If nOrdem == 1 .And. !Empty(SC7->C7_NUMSC)
     				@ li,000 PSAY STR0013 + &cCampo + " " + STR0048 + SC7->C7_NUMSC + " " + Substr(cCabQuebra,1,(nTamNome-5))      
                Else
     				@ li,000 PSAY STR0013 + &cCampo + " " + Substr(cCabQuebra,1,(nTamNome-5))
				Endif
			Endif
		Else
		    If nOrdem == 1 .And. !Empty(SC7->C7_NUMSC)
			    @ li,000 PSAY cTexQuebra + &cCampo + " " + STR0048 + SC7->C7_NUMSC + " " + Substr(cCabQuebra,1,(nTamNome-5))
		    Else
			    @ li,000 PSAY cTexQuebra + &cCampo + " " + Substr(cCabQuebra,1,(nTamNome-5))
		    Endif
		EndIf

		If nOrdem = 1 .or. nOrdem = 3
			dbSelectArea("SA2")
			If dbSeek(cFilial+SC7->C7_FORNECE+SC7->C7_LOJA)
				If nOrdem = 1
					@ li,055 PSAY SC7->C7_FORNECE
					@ li,(062+nDifNome) PSAY Substr(SA2->A2_NOME,1,nTamNome)
					@ li,098 PSAY STR0041+Substr(SA2->A2_TEL,1,15) // Fone.:
				Else
					@ li,055 PSAY STR0041+Substr(SA2->A2_TEL,1,15) + STR0044 + SA2->A2_FAX + STR0045 + SA2->A2_CONTATO   // Fone.: Fax: Contato:
				Endif			
			Endif
			dbSelectArea("SC7")
		Endif
		nQuebra := 1
		nFlag:=0
	Endif

	dbSelectArea("SC7")
	If cQuebrant != &cCampo
		nQuebra := 0
		li++
		If li > 55
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
		Endif
        If nFlag > 1 .Or. nOrdem != 2
			Impitem()
			nFlag:=0
		EndIf
		nPedida:=nValIpi:=nTotal:=nQuant:=nSaldo:=nValIVA:=0
		@ li,000 PSAY __PrtThinLine()
		Loop
	Endif
	li++
	If li > 55
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
	Endif
	nItemIpi := 0
	nSalIpi := 0
	nItemIVA  := 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica ordem a ser impressa           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//	MaFisIniPC(SC7->C7_NUM,SC7->C7_ITEM,SC7->C7_SEQUEN)
	R110FiniPC(SC7->C7_NUM,SC7->C7_ITEM,SC7->C7_SEQUEN,)
	If nOrdem = 1
		nTotParc := ImpOrd1()
	ElseIf nOrdem = 2
		nTotParc := ImpOrd2()
	Else
		nTotParc := ImpOrd3()
	Endif
	nTotal 	+= xMoeda(nTotParc,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Soma as variaveis dos totais p/item     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPedida = nPedida + C7_QUANT
	nValIpi = nValIpi + xMoeda(nItemIPI,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)
	nQuant  = nQuant  + C7_QUJE
	nQuant_a_Rec := If(Empty(C7_RESIDUO),IIF(C7_QUANT-C7_QUJE<0,0,C7_QUANT-C7_QUJE),0)
	nSaldo  = nSaldo  + (nQuant_a_Rec * IIf(Empty(C7_REAJUST),xMoeda(C7_PRECO,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda),xMoeda(Formula(C7_REAJUST),SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda))) + xMoeda(nSalIPI,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)
	nValIVA := nValIVA + xMoeda(nItemIVA,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valor do Frete         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nFrete := C7_FRETE
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valor do Desconto         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If C7_DESC1 != 0 .or. C7_DESC2 != 0 .or. C7_DESC3 != 0
		nDesc += CalcDesc(C7_TOTAL,C7_DESC1,C7_DESC2,C7_DESC3)
	Else
		nDesc += C7_VLDESC
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Soma as variaveis dos totais gerais     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nT_vl_ipi   := nT_vl_ipi   + xMoeda(nItemIPI,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)
	nT_vl_total := nT_vl_total + xMoeda(nTotParc,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)
	nT_sd_receb := nT_sd_receb + (nQuant_a_Rec * IIf(Empty(C7_REAJUST),xMoeda(C7_PRECO,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda),xMoeda(Formula(C7_REAJUST),SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda))) + xMoeda(nSalIPI,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)
	nTotIVA     := nTotIVA     + xMoeda(nItemIVA,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)
	dbSelectArea("SC7")
	dbSkip()
EndDo
If nOrdem <> 1
	nT_Desc += xMoeda(nDesc,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)
  	nDesc := 0
EndIf

If nFlag > 1 .Or. nOrdem != 2
	If li > 55 .And. li != 80
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
	Endif
	If li != 80
        li++
		Impitem()
	Endif
	nFlag:=0
EndIf

If nT_qtd_ped > 0 .Or. nT_vl_ipi > 0 .Or.;
		nT_vl_total > 0 .Or. nT_qtd_entr > 0 .Or. nT_sd_receb > 0
	Imptot(limite)
Endif

IF li != 80
	li++
	If li > 55
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
	Endif
	@ li,000 PSAY __PrtThinLine()
	roda(CbCont,STR0030,"G")		//"PEDIDOS"
EndIF

dbSelectArea("SC7")
Set Filter To
dbSetOrder(1)

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	ourspool(wnrel)
Endif

MS_FLUSH()

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ IMPORD1  ³ Autor ³ Claudinei M. Benzi    ³ Data ³ 05.09.91 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do relatorio na 1a ordem                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function ImpOrd1()

Local nQuant_a_Rec:=0
Local aTam		:= TamSx3("C7_PRECO")
Local aTamVal	:= TamSx3("C7_VALICM")
Local nTotal	:= MaFisRet(,'NF_TOTAL')
Local aValIVA   := MaFisRet(,"NF_VALIMP")
Local nI
Local cDescri := Alltrim(SC7->C7_DESCRI)
Local nTxMoeda := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,Nil)
Local j := 0

If Empty(mv_par14)
	mv_par14 := "B1_DESC"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao da descricao generica do Produto.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If AllTrim(mv_par14) == "B1_DESC"
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek( xFilial()+SC7->C7_PRODUTO )
	cDescri := Alltrim(SB1->B1_DESC)
	dbSelectArea("SC7")
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao da descricao cientifica do Produto.                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If AllTrim(mv_par14) == "B5_CEME"
	dbSelectArea("SB5")
	dbSetOrder(1)
	If dbSeek( xFilial()+SC7->C7_PRODUTO )
		cDescri := Alltrim(B5_CEME)
	EndIf
	dbSelectArea("SC7")
EndIf

dbSelectArea("SC7")
If AllTrim(mv_par14) == "C7_DESCRI"
	cDescri := Alltrim(SC7->C7_DESCRI)
EndIf

If cPaisLoc <> "BRA" .And. !Empty( aValIVA )
   For nI := 1 To Len( aValIVA )
       nItemIVA += aValIVA[nI]
   Next
Endif

dbSelectArea("SB1")
dbSeek(cFilial+SC7->C7_PRODUTO)
dbSelectArea("SC7")
@ li,000 PSAY C7_ITEM
@ li,005 PSAY Trim(C7_CODLMT) + " / " + Trim(SB1->B1_DENOM)
nFlag++
//@ li,021 PSAY Subs(cDescri,1,28)
//If Found()
//	@ li,050 PSAY B1_GRUPO
//EndIf
dbSelectArea("SC7")
@ li,087 PSAY LEFT(C7_OP,11) 
@ li,099 PSAY C7_EMISSAO
@ li,109 PSAY C7_DATPRF
@ li,120 PSAY C7_QUANT Picture Tm(C7_QUANT,08,0)
@ li,129 PSAY C7_UM
If !Empty(C7_REAJUST)
	@ li,132 PSAY xMoeda(Formula(C7_REAJUST),SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,aTam[2],nTxMoeda) Picture tm(Formula(C7_REAJUST),10,aTam[2])
Else
	@ li,132 PSAY xMoeda(C7_PRECO,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,aTam[2],nTxMoeda) Picture tm(C7_PRECO,13,aTam[2])
Endif
nItemIPI := CalcIPI()[1]
nSalIPI := CalcIPI()[2]
If cPaisLoc <> "BRA"
	@ li,146 PSAY xMoeda(nItemIVA,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)  Picture tm(nItemIVA,15,aTamVal[2])
Else
	@ li,146 PSAY xMoeda(nItemIPI,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)  Picture tm(nItemIPI,15,aTamVal[2])
EndIf
@ li,161 PSAY xMoeda(nTotal,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda) Picture tm(nTotal,15,aTamVal[2])
@ li,177 PSAY C7_QUJE Picture "999999"
nQuant_a_Rec := If(Empty(C7_RESIDUO),IIF(C7_QUANT-C7_QUJE<0,0,C7_QUANT-C7_QUJE),0)
@ li,185 PSAY nQuant_a_Rec Picture "999999"

If Empty(C7_REAJUST)
	@ li,191 PSAY (nQuant_a_Rec * xMoeda(C7_PRECO,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)) +;
		xMoeda(nSalIPI,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda) Picture tm(C7_TOTAL,15,aTamVal[2])
Else
	@ li,191 PSAY (nQuant_a_Rec * xMoeda(Formula(C7_REAJUST),SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)) + ;
		xMoeda(nSalIPI,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda) Picture tm(C7_TOTAL,15,aTamVal[2])
Endif	
//@ li,215 PSAY If(Empty(C7_RESIDUO),STR0031,STR0032)		//'Nao'###'Sim'
@LI,207 PSAY C7_CONFIRM

IF ! EMPTY( SB1->B1_DESC + SB1->B1_POSIPI + SB1->B1_ENDE ) 
   // DENOMINACAO NCM        LOCALIZACAO
   @LI,218 PSAY SB1->B1_DESC
   @LI,249 PSAY SB1->B1_POSIPI
   @LI,265 PSAY SB1->B1_ENDE
ENDIF
   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao da Descricao Adicional do Produto (se houver)      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For j:=29 TO Len(Trim(cDescri)) Step 28
	If !empty(Subs(cDescri,j,28))
		Li++
		If li > 55
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
		Endif
		@ li,21 PSAY SubStr(cDescri,j,28)
	Endif
Next j

Return nTotal

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ IMPORD2  ³ Autor ³ Claudinei M. Benzi    ³ Data ³ 05.09.91 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do relatorio na 2a ordem                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function ImpOrd2()

Local nQuant_a_Rec
Local aTam		:= TamSx3("C7_PRECO")
Local aTamVal	:= TamSx3("C7_VALICM")
Local nTotal	:= MaFisRet(,'NF_TOTAL')
Local aValIVA   := MaFisRet(,"NF_VALIMP")
Local nTxMoeda  := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,Nil)
Local nI

If cPaisLoc <> "BRA" .And. !Empty( aValIVA )
   For nI := 1 To Len( aValIVA )
       nItemIVA += aValIVA[nI]
   Next
Endif

dbSelectArea("SC7")
If ( cPaisLoc$"ARG|POR|EUA" )
	@ li,000 PSAY If(C7_TIPO==1,"P"+C7_NUM,"A"+C7_NUM)
Else
	@ li,000 PSAY C7_NUM
EndIf
@ li,007 PSAY C7_ITEM
nFlag++
@ li,012 PSAY C7_EMISSAO
@ li,023 PSAY C7_FORNECE
dbSelectArea("SA2")
If dbSeek(cFilial+SC7->C7_FORNECE+SC7->C7_LOJA)
	@li,(30+nDifNome) PSAY Subs(A2_NOME,1,nTamNome)
//	@li,66 PSAY Substr(A2_TEL,1,15)
Endif
DbSelectArea("SC7")
@ li,66 PSAY Left(C7_OP,11)
@ li,82 PSAY C7_DATPRF
@ li,93 PSAY C7_QUANT Picture tm(C7_QUANT,15,2)
If !Empty(C7_REAJUST)
	@ li,109 PSAY xMoeda(Formula(C7_REAJUST),SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,aTam[2],nTxMoeda) Picture tm(Formula(C7_REAJUST),15,aTam[2])
Else
	@ li,109 PSAY xMoeda(C7_PRECO,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,aTam[2],nTxMoeda) Picture tm(C7_PRECO,15,aTam[2])
Endif
nItemIPI := CalcIPI()[1]
nSalIPI := CalcIPI()[2]
@ li,124 PSAY xMoeda(C7_VLDESC,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)  Picture tm(C7_VLDESC,12,aTamVal[2])
If cPaisLoc <> "BRA"
	@ li,137 PSAY xMoeda(nItemIVA,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)  Picture tm(nItemIVA,15,aTamVal[2])
Else
	@ li,137 PSAY xMoeda(nItemIPI,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)  Picture tm(nItemIPI,15,aTamVal[2])
EndIf
@ li,153 PSAY xMoeda(nTotal,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda) Picture tm(nTotal,15,aTamVal[2])
@ li,169 PSAY C7_QUJE Picture "999999"
nQuant_a_Rec := If(Empty(C7_RESIDUO),IIF(C7_QUANT-C7_QUJE<0,0,C7_QUANT-C7_QUJE),0)
@ li,180 PSAY nQuant_a_Rec Picture "999999"

If Empty(C7_REAJUST)
	@ li,190 PSAY (nQuant_a_Rec * xMoeda(C7_PRECO,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)- ;
		xMoeda(C7_VLDESC,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda))+ ;
		xMoeda(nSalIPI,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda) Picture tm(C7_TOTAL,15,aTamVal[2])
Else
	@ li,190 PSAY (nQuant_a_Rec * xMoeda(Formula(C7_REAJUST),SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)) + ;
		xMoeda(nSalIPI,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda) Picture tm(C7_TOTAL,15,aTamVal[2])
Endif	
//@ li,207 PSAY If(Empty(C7_RESIDUO),STR0031,STR0032)		//'Nao'###'Sim'
@ LI,207 PSAY C7_CONFIRM

IF ! EMPTY( SB1->B1_DESC + SB1->B1_POSIPI + SB1->B1_ENDE ) 
   // DENOMINACAO NCM        LOCALIZACAO
   @LI,218 PSAY SB1->B1_DESC
   @LI,249 PSAY SB1->B1_POSIPI
   @LI,265 PSAY SB1->B1_ENDE
ENDIF
   
Return nTotal

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ IMPORD3  ³ Autor ³ Claudinei M. Benzi    ³ Data ³ 05.09.91 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do relatorio na 3a ordem                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function ImpOrd3()
Local nQuant_a_Rec:=0
Local aTam		:= TamSx3("C7_PRECO")
Local aTamVal	:= TamSx3("C7_VALICM")
Local nTotal	:= MaFisRet(,"NF_TOTAL")
Local aValIVA   := MaFisRet(,"NF_VALIMP")
Local nI
Local cDescri := Alltrim(SC7->C7_DESCRI)
Local nTxMoeda := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,Nil)
Local j := 0

If Empty(mv_par14)
	mv_par14 := "B1_DESC"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao da descricao generica do Produto.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  


dbSelectArea("SB1")
dbSetOrder(1)
dbSeek( xFilial()+SC7->C7_PRODUTO )
cDescri := Alltrim(SB1->B1_CODLMT) + " / " + AllTrim(SB1->B1_DENOM)
dbSelectArea("SC7")

If cPaisLoc <> "BRA" .And. !Empty( aValIVA )
   For nI := 1 To Len( aValIVA )
       nItemIVA += aValIVA[nI]
   Next
Endif

//	cabec1 := "PEDIDO ÍTEM DATA     CÓDIGO          DESCRIÇÃO DO PRODUTO           COD.PRODUTO FORNEC.  ENTREGA   QUANTIDADE         PREÇO         VALOR   PREÇO TOTAL  QUANTIDADE    QUANT. A         SALDO     CONFIRMACAO     "
//	cabec2 := "NÚMERO      EMISSÃO  PRODUTO                                                             PREVISTA      PEDIDA      UNITÁRIO           IPI       (C/IPI)    ENTREGUE     RECEBER       RECEBER                     "
	//         123456 1234 11/11/11 123456789012345 123456789012345678901234567890 12345678901234567890 11/11/11 999,999.999 99,999,999.99 99,999,999.99 99,999,999.99 999,999.999 999,999.999 99,999,999.99 12345678901234567890
	//                   1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
	//         01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890

dbSelectArea("SC7")
If ( cPaisLoc$"ARG|POR|EUA" )
	@li,000 PSAY If(C7_TIPO==1,"P"+C7_NUM,"A"+C7_NUM)
Else
	@li,000 PSAY C7_NUM
EndIf
@ li,007 PSAY C7_ITEM
nFlag++
@ li,012 PSAY C7_EMISSAO
@ li,021 PSAY C7_PRODUTO
@ li,037 PSAY Subs(cDescri,1,30)
dbSelectArea("SB1")
If dbSeek(xFilial()+SC7->C7_PRODUTO)
//	@ li,068 PSAY B1_GRUPO
Endif
dbSelectArea("SC7")
@ li,068 PSAY Posicione( "SA5" , 1 , xFilial( "SA5" ) + SC7->( C7_FORNECE + C7_LOJA + C7_PRODUTO ) , "A5_CODPRF" )
@ li,089 PSAY C7_DATPRF
@ li,098 PSAY C7_QUANT Picture tm(C7_QUANT,11,0)
If !Empty(C7_REAJUST)
	@li,110 PSAY xMoeda(Formula(C7_REAJUST),SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,aTam[2],nTxMoeda) Picture tm(Formula(C7_REAJUST),13,aTam[2])
Else
	@li,110 PSAY xMoeda(C7_PRECO,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,aTam[2],nTxMoeda) Picture tm(C7_PRECO,13,aTam[2])
Endif
nItemIPI := CalcIPI()[1]
nSalIPI := CalcIPI()[2]
//@ li,115 PSAY xMoeda(C7_VLDESC,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda) Picture tm(C7_VLDESC,12,2)
If cPaisLoc <> "BRA"
	@ li,124 PSAY xMoeda(nItemIVA,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)  Picture tm(nItemIVA,13,aTamVal[2])
Else
	@ li,124 PSAY xMoeda(nItemIPI,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)  Picture tm(nItemIPI,13,aTamVal[2])
EndIf
@ li,138 PSAY xMoeda(nTotal,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda) Picture tm(nTotal,13,aTamVal[2])
@ li,152 PSAY C7_QUJE	Picture tm(C7_QUJE,11,0)
nQuant_a_Rec := If(Empty(C7_RESIDUO),IIF(C7_QUANT-C7_QUJE<0,0,C7_QUANT-C7_QUJE),0)
@ li,164 PSAY nQuant_a_Rec Picture tm(C7_QUANT-C7_QUJE,11,0)

If Empty(C7_REAJUST)
	@ li,176 PSAY (nQuant_a_Rec * xMoeda(C7_PRECO,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)- ;
		xMoeda(C7_VLDESC,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda))+ ;
		xMoeda(nSalIPI,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda) Picture tm(C7_TOTAL,13,aTamVal[2])
Else
	@ li,176 PSAY (nQuant_a_Rec * xMoeda(Formula(C7_REAJUST),SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)) + ;
		xMoeda(nSalIPI,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda) Picture tm(C7_TOTAL,13,aTamVal[2])
Endif	
@ li,195 PSAY C7_CONFIRM

IF ! EMPTY( SB1->B1_DESC + SB1->B1_POSIPI + SB1->B1_ENDE ) 
   // DENOMINACAO NCM        LOCALIZACAO
   @LI,218 PSAY SB1->B1_DESC
   @LI,249 PSAY SB1->B1_POSIPI
   @LI,265 PSAY  SB1->B1_ENDE
ENDIF
   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao da Descricao Adicional do Produto (se houver)      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For j:=31 TO Len(Trim(cDescri)) Step 30
	If !empty(Subs(cDescri,j,44))
		li++
		If li > 55
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
		Endif
		@ li,37 PSAY AllTrim( SubStr(cDescri,j,30) )
	Endif
Next j

Return nTotal

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ IMPTOT   ³ Autor ³ Cristina M. Ogura     ³ Data ³ 03.02.95³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao dos totais do relatorio                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function ImpTot(limite)

Local nc1,nc2,nc3,nc4,nc5,nc6      // numeros das colunas para aparecer os
// totais dependendo do tipo de rela-
// torio escolhido(1,2,3)
nc1:=nc2:=nc3:=nc4:=nc5:=nc6:=0
If nOrdem = 1
	nc3:= 146
	nc4:= 161; nc6:= 191
ElseIf nOrdem = 2
	nc3:= 137
	nc4:= 153;nc6:= 190
Else
	nc3:= 124
	nc4:= 138;nc6:= 176
Endif
li+=2
@ li,000 PSAY STR0033	//"Total Geral "
If cPaisLoc <> "BRA"
	@ li,nc3 PSAY nTotIVA   Picture tm(nTotIVA,15,2)
Else
	If	nOrdem # 3
		@ li,nc3 PSAY nT_vl_ipi Picture tm(nT_vl_ipi,15,2)
	Else
		@ li,nc3 PSAY nT_vl_ipi Picture tm(nT_vl_ipi,13,2)
	EndIf
EndIf
If nOrdem # 3
	@ li,nc4 PSAY nT_vl_total           Picture tm(nT_vl_total,15,2)
	@ li,nc6 PSAY nT_sd_receb - nT_desc Picture tm(nT_sd_receb,15,2)
Else
	@ li,nc4 PSAY nT_vl_total           Picture tm(nT_vl_total,13,2)
	@ li,nc6 PSAY nT_sd_receb - nT_desc Picture tm(nT_sd_receb,13,2)
EndIf
Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ IMPITEM  ³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 08.05.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao dos totais p/ item de acordo com a ordem         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function ImpItem()

Local nc1,nc2,nc3,nc4,nc5,nc6		// numeros das colunas para aparecer os
Local nTxMoeda := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,Nil)
// totais dependendo do tipo de rela-
// torio escolhido(1,2,3)

nc1:=nc2:=nc3:=nc4:=nc5:=nc6:=0
If nOrdem = 1
	nc3:= 146
	nc4:= 161; nc6:= 191
	cTotal:=STR0034	//"Total dos Itens "
ElseIf nOrdem = 2
	nc3:= 137
	nc4:= 153; nc6:= 190
	cTotal:=STR0035	//"Total do Produto"
Else
   nc3:= 124
	nc4:= 138;nc6:= 176
	cTotal:=STR0036	//"Total do Fornecedor"
Endif

li ++
@ li,000 PSAY cTotal
If cPaisLoc <> "BRA"
	@ li,nc3 PSAY nValIVA  Picture tm(nValIVA,15,2)
Else
	if	nOrdem # 3
		@ li,nc3 PSAY nValIpi  Picture tm(nValIpi,15,2)
	else
		@ li,nc3 PSAY nValIpi  Picture tm(nValIpi,13,2)
	endif
EndIf
If nOrdem # 3
	@ li,nc4 PSAY nTotal   Picture tm(nTotal,15,2)
	@ li,nc6 PSAY (nSaldo-If(nOrdem<>1,nDesc,0)) Picture tm(nSaldo,15,2)
else
	@ li,nc4 PSAY nTotal   Picture tm(nTotal,13,2)
	@ li,nc6 PSAY (nSaldo-If(nOrdem<>1,nDesc,0)) Picture tm(nSaldo,13,2)
endif
li++
If li > 55
 	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
Endif

nT_desc += xMoeda(nDesc,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)
nDesc:=0
Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CALCIPI  ³ Autor ³ Marcos Bregantim      ³ Data ³ 30.08.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo do IPI                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CalcIPI()
Local nToTIPI	:= 0,nTotal,nSalIPI:= 0
Local nValor 	:= (C7_QUANT) * IIf(Empty(C7_REAJUST),C7_PRECO,Formula(C7_REAJUST))
Local nSaldo 	:= (C7_QUANT-C7_QUJE) * IIf(Empty(C7_REAJUST),C7_PRECO,Formula(C7_REAJUST))
Local nTotDesc := C7_VLDESC

If cPaisLoc <> "BRA"
	nSalIPI := (C7_QUANT-C7_QUJE) * nItemIVA / C7_QUANT
Else
	If nTotDesc == 0
		nTotDesc := CalcDesc(nValor,SC7->C7_DESC1,SC7->C7_DESC2,SC7->C7_DESC3)
	EndIF
	nTotal := nValor - nTotDesc
	nTotIPI := IIF(SC7->C7_IPIBRUT == "L",nTotal, nValor) * ( SC7->C7_IPI / 100 )
    If Empty(C7_RESIDUO)
	   nTotal := nSaldo - nTotDesc
	   nSalIPI := IIF(SC7->C7_IPIBRUT == "L",nTotal, nSaldo) * ( SC7->C7_IPI / 100 )
    Endif
EndIf

Return {nTotIPI,nSalIPI} 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AjustaSX1 ºAutor  ³Alexandre Lemes     º Data ³ 26/09/2002  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATR120 AP6                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSX1()
 
PutSx1(cPerg,"15","Fornecedor de      ?","De proveedor       ?","From supplier      ?","mv_chf","C", 6,0,2,"G","","SA2","","","mv_par15","","","","","","","","","","","","","","","","","","","","","","","","","","","") 
PutSx1(cPerg,"16","Fornecedor ate     ?","A proveedor        ?","To supplier        ?","mv_chg","C", 6,0,2,"G","","SA2","","","mv_par16","","","","","","","","","","","","","","","","","","","","","","","","","","","") 
   
Return   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³R110FIniPC³ Autor ³ Edson Maricate        ³ Data ³20/05/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializa as funcoes Fiscais com o Pedido de Compras      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ R110FIniPC(ExpC1,ExpC2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 := Numero do Pedido                                  ³±±
±±³          ³ ExpC2 := Item do Pedido                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR110,MATR120,Fluxo de Caixa                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R110FIniPC(cPedido,cItem,cSequen,cFiltro)

Local aArea		:= GetArea()
Local aAreaSC7	:= SC7->(GetArea())
Local cValid		:= ""
Local nPosRef		:= 0
Local nItem		:= 0
Local cItemDe		:= IIf(cItem==Nil,'',cItem)
Local cItemAte	:= IIf(cItem==Nil,Repl('Z',Len(SC7->C7_ITEM)),cItem)
Local cRefCols	:= ''
DEFAULT cSequen	:= ""
DEFAULT cFiltro	:= ""

dbSelectArea("SC7")
dbSetOrder(1)
If dbSeek(xFilial("SC7")+cPedido+cItemDe+Alltrim(cSequen))
	MaFisEnd()
	MaFisIni(SC7->C7_FORNECE,SC7->C7_LOJA,"F","N","R",{})
	While !Eof() .AND. SC7->C7_FILIAL+SC7->C7_NUM == xFilial("SC7")+cPedido .AND. ;
			SC7->C7_ITEM <= cItemAte .AND. (Empty(cSequen) .OR. cSequen == SC7->C7_SEQUEN)

		// Nao processar os Impostos se o item possuir residuo eliminado  
		If &cFiltro
			dbSelectArea('SC7')
			dbSkip()
			Loop
		EndIf
            
		// Inicia a Carga do item nas funcoes MATXFIS  
		nItem++
		MaFisIniLoad(nItem)
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek('SC7')
		While !EOF() .AND. (X3_ARQUIVO == 'SC7')
			cValid	:= StrTran(UPPER(SX3->X3_VALID)," ","")
			cValid	:= StrTran(cValid,"'",'"')
			If "MAFISREF" $ cValid .And. SX3->X3_CONTEXT <> "V"	
				nPosRef  := AT('MAFISREF("',cValid) + 10
				cRefCols := Substr(cValid,nPosRef,AT('","MT120",',cValid)-nPosRef )
				// Carrega os valores direto do SC7.           
				MaFisLoad(cRefCols,&("SC7->"+ SX3->X3_CAMPO),nItem)
			EndIf
			dbSkip()
		End
		MaFisEndLoad(nItem,2)
		dbSelectArea('SC7')
		dbSkip()
	End
EndIf

RestArea(aAreaSC7)
RestArea(aArea)

Return .T.
