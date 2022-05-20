#Include "MATR850.CH"
//#Include "FIVEWIN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR850  ³ Autor ³ Paulo Boschetti       ³ Data ³ 13.08.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relacao Das Ordens de Producao                              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ MATR850(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Edson   M.  ³19/01/98³XXXXXX³ Inclusao do Campo C2_SLDOP.              ³±±
±±³Edson   M.  ³02/02/98³XXXXXX³ Subst. do Campo C2_SLDOP p/ Funcao.      ³±±
±±³Rodrigo Sart³24/03/98³08929A³ Inclusao da Coluna Termino Real da OP.   ³±±
±±³Rodrigo Sart³05/10/98³15995A³ Acerto na filtragem das filiais          ³±±
±±³Rodrigo Sart³03/11/98³XXXXXX³ Acerto p/ Bug Ano 2000                   ³±±
±±³Fernando J. ³07/02/99³META  ³Imprimir OP's Firmes, Previstas ou Ambas. ³±±
±±³Cesar       ³31/03/99³XXXXXX³Manutencao na SetPrint()                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
User Function ROP()
LOCAL titulo 	:= STR0001 								//"Relacao Das Ordens de Producao" 
LOCAL cString	:= "SC2"
LOCAL wnrel		:= "ROP"
LOCAL cDesc		:= STR0002								//"Este programa ira imprimir a Rela‡„o das Ordens de Produ‡„o."
LOCAL aOrd    	:= {STR0003,STR0004,STR0005}			//"Por O.P.       "###"Por Produto    "###"Por Centro de Custo"
LOCAL tamanho	:= "G"
PRIVATE aReturn := {STR0006,1,STR0007, 1, 2, 1, "",1 }	//"Zebrado"###"Administracao"
PRIVATE cPerg   := PadR( "ROP001" , Len( SX1->X1_GRUPO ) )
PRIVATE nLastKey:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("ROP001",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01        	// Da OP                                 ³
//³ mv_par02        	// Ate a OP                              ³
//³ mv_par03        	// Do Produto                            ³
//³ mv_par04        	// Ate o Produto                         ³
//³ mv_par05        	// Do Centro de Custo                    ³
//³ mv_par06        	// Ate o Centro de Custo                 ³
//³ mv_par07        	// Da data                               ³
//³ mv_par08        	// Ate a data                            ³
//³ mv_par09        	// 1-EM ABERTO 2-ENCERRADAS  3-TODAS     ³
//³ mv_par10        	// 1-SACRAMENTADAS 2-SUSPENSA 3-TODAS    ³
//³ mv_par11            // Impr. OP's Firmes, Previstas ou Ambas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc,"","",.F.,aOrd,,Tamanho)

If aReturn[4] == 1
   Tamanho := "M"
Endif    
If nLastKey == 27
   Set Filter To
   Return
Endif

SetDefault(aReturn,cString)
             
If nLastKey == 27
   Set Filter To
   Return
Endif

RptStatus({|lEnd| R850Imp(@lEnd,wnRel,titulo,tamanho)},titulo)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R850Imp  ³ Autor ³ Waldemiro L. Lustosa  ³ Data ³ 13.11.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do Relat¢rio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR850			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R850Imp(lEnd,wnRel,titulo,tamanho)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL CbTxt
LOCAL CbCont,cabec1,cabec2
LOCAL limite   := If(aReturn[4] == 1,132,180)
LOCAL nomeprog := "ROP"
LOCAL nTipo    := 0 
LOCAL cProduto := SPACE(LEN(SC2->C2_CODLMT))
LOCAL cStatus,nOrdem,cSeek
LOCAL cTotal   := "",nTotOri:= 0,nTotSaldo:=0 // Totalizar qdo ordem for por produto
LOCAL cQuery   := ""
LOCAL lQuery   := .F.
LOCAL aStruSC2 := {}
LOCAL cAliasSC2:= "SC2"
LOCAL cTPOP    := ""
LOCAL cNumOpDe :=Substr(mv_par01,1,Len(SC2->C2_NUM) )
LOCAL cItemOpDe:=Substr(mv_par01,1+Len(SC2->C2_NUM),Len(SC2->C2_ITEM)) 
LOCAL cSeqOpDe :=Substr(mv_par01,1+Len(SC2->C2_NUM)+Len(SC2->C2_ITEM),Len(SC2->C2_SEQUEN)) 
LOCAL cItGrdDe :=Substr(mv_par01,1+Len(SC2->C2_NUM)+Len(SC2->C2_ITEM)+Len(SC2->C2_SEQUEN),Len(SC2->C2_ITEMGRD)) 
LOCAL cNumOpAte:=Substr(mv_par02,1,Len(SC2->C2_NUM))
LOCAL cItemOpAte:=Substr(mv_par02,1+Len(SC2->C2_NUM),Len(SC2->C2_ITEM))
LOCAL cSeqOpAte:=Substr(mv_par02,1+Len(SC2->C2_NUM)+Len(SC2->C2_ITEM),Len(SC2->C2_SEQUEN)) 
LOCAL cItGrdAte:=Substr(mv_par02,1+Len(SC2->C2_NUM)+Len(SC2->C2_ITEM)+Len(SC2->C2_SEQUEN),Len(SC2->C2_ITEMGRD)) 
LOCAL lTipo    := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt  := SPACE(10)
cbcont := 0
li     := 80
m_pag  := 1

nTipo  := IIF(aReturn[4]==1,15,18)
nOrdem := aReturn[8]
lTipo  := IIF(aReturn[4]==1,.T.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os Cabecalhos                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
titulo += IIf(nOrdem==1,STR0008,IIf(nOrdem==2,STR0009,STR0010))	//" - Por O.P."###" - Por Produto"###" - Por Centro de Custo"
cabec1 := "NUMERO         P R O D U T O                   FORNECEDOR                               EMISSAO      ENTREGA     ENTREGA       QUANTIDADE          SALDO A      METAL     CLIENTE                   PR. UNIT"
cabec2 := "                                                                                                    PREVISTA        REAL         ORIGINAL         ENTREGAR"
//					   1234567890123  123456789012345  1234567890123456789012345678901234567890  1234567890  1234567890  1234567890  1234567890  123456789012345  123456789012345       1  1 
//                               1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17
//                     012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
// 1a Linha Posicoes:000/015/032/074/086/098/110/122/139/161/164

dbSelectArea("SC2")
dbSetOrder( Iif(nOrdem==2,9,nOrdem) )
cIndex := 'C2_NUM'
nIndex :=0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variavel para controle do filtro                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par10 == 1 
		cStatus := "S"
	ElseIf mv_par10 == 2
		cStatus := "U"
	ElseIf mv_par10 == 3
		cStatus := "SUDN "
	EndIf	
	cQuery 	:= "C2_FILIAL=='"+xFilial("SC2")+"'.And.C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD>='"+mv_par01+"'"
	cQuery 	+= ".And.C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD<='"+mv_par02+"'"
	cQuery  += ".And.C2_CODLMT>='"+mv_par03+"'.And.C2_CODLMT<=+'"+mv_par04+"'"
	cQuery  += ".And.C2_STATUS$'"+cStatus+"'
	cQuery  += ".And.C2_CC>='"+mv_par05+"'.And.C2_CC<='"+mv_par06+"'"
	cQuery  += ".And.DtoS(C2_EMISSAO)>='"+DtoS(mv_par07)+"'.And.DtoS(C2_EMISSAO)<='"+DtoS(mv_par08)+"'"
	IndRegua("SC2",cIndex,IndexKey(),,cQuery)
	nIndex := RetIndex("SC2")
	#IFNDEF TOP
		dbSetIndex(cIndex+OrdBagExt())
	#ENDIF

	dbSetOrder(nIndex+1)
	cAliasSC2 := "SC2"


SetRegua(RecCount())		// Total de Elementos da regua
dbGoTop()
While !Eof()

	IncRegua()

	If lEnd
		@ Prow()+1,001 PSay STR0013	//	"CANCELADO PELO OPERADOR"
		Exit
	EndIF

	If mv_par09 == 1  // O.P.s EM ABERTO
		If !Empty(C2_DATRF)
			dbSkip()
			Loop
		Endif
	Elseif mv_par09 == 2 //O.P.S ENCERRADAS
		If Empty(C2_DATRF)
			dbSkip()
			Loop
		Endif
	Endif
	
	//-- Valida se a OP deve ser Impressa ou n„o
//	#IFNDEF TOP
		If !MtrAValOP(mv_par11, 'SC2')
			dbSkip()
			Loop
		EndIf
//	#ENDIF	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtro do Usuario ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aReturn[7])
		If !&(aReturn[7])
			dbSkip()
			Loop
		EndIf
	EndIf	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Termina filtragem e grava variavel p/ totalizacao            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTotal  := IIf(nOrdem==2,xFilial("SC2")+C2_CODLMT,xFilial("SC2"))
	nTotOri := nTotSaldo:=0
	Do While !Eof() .And. cTotal == IIf(nOrdem==2,C2_FILIAL+C2_CODLMT,C2_FILIAL)
		IncRegua()

		If mv_par09 == 1  // O.P.s EM ABERTO
			If !Empty(C2_DATRF)
				dbSkip()
				Loop
			Endif
		Elseif mv_par09 == 2 //O.P.S ENCERRADAS
			If Empty(C2_DATRF)
				dbSkip()
				Loop
			Endif
		Endif

		//-- Valida se a OP deve ser Impressa ou n„o
//		#IFNDEF TOP
			If !MtrAValOP(mv_par11, 'SC2')
				dbSkip()
				Loop
			EndIf
//		#ENDIF	
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Filtro do Usuario ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(aReturn[7])
			If !&(aReturn[7])
				dbSkip()
				Loop
			EndIf
		EndIf	

		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial()+(cAliasSC2)->C2_PRODUTO))

		IF li > 58
			Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		EndIF

		// 1a Linha Posicoes:000/015/032/074/086/098/110/122/139/161/164
		@Li ,000 PSay C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
		If(Empty(C2_CODLMT))
			@Li ,015 PSay Space(30)
		Else
			@Li ,015 PSay Left(C2_CODLMT,30)
		EndIf
		cNmReduz := Posicione("SA2",1,xFilial("SA2")+SC2->C2_CODFORN,"A2_NREDUZ")
		If(Empty(cNmReduz))
			cNmReduz := Space(20)
		EndIf
		If lTipo
//		   @Li ,032 PSay SubStr(SB1->B1_DESC,1,25)
//		   @Li ,058 PSay C2_CC
		   @Li ,046 Psay cNmReduz
		   
		   @Li ,068 PSay C2_EMISSAO
		   @Li ,077 PSay C2_DATPRF
		   @Li ,086 PSay C2_DATRF
		   @Li ,097 PSay C2_QUANT Picture PesqPictQt("C2_QUANT",15)
		   @Li ,112 PSay IIf(Empty(C2_DATRF),aSC2Sld(cAliasSC2),0) Picture PesqPictQt("C2_QUANT",15)
		Else
//		   @Li ,032 PSay SubStr(SB1->B1_DESC,1,40)
//		   @Li ,074 PSay C2_CC
		   @Li ,046 Psay cNmReduz
		   @Li ,086 PSay C2_EMISSAO
		   @Li ,099 PSay C2_DATPRF
		   @Li ,111 PSay C2_DATRF
		   @Li ,125 PSay C2_QUANT Picture PesqPictQt("C2_QUANT",15)
		   @Li ,142 PSay IIf(Empty(C2_DATRF),aSC2Sld(cAliasSC2),0) Picture PesqPictQt("C2_QUANT",15)
		Endif   
		
		If ! __lPyme
		    IF lTipo
			   //@Li ,126 PSay C2_STATUS
			   @Li ,129 PSay SB1->B1_METAL			//C2_TPOP
		    Else
			   //@Li ,161 PSay C2_STATUS
			   @Li ,164 PSay SB1->B1_METAL			//C2_TPOP
			Endif
		EndIf	
		
		dbSelectArea("SC6")
		dBSetOrder(2)
		dbSeek(xFilial("SC6") + SC2->C2_PRODUTO + SC2->C2_NUM)
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1") + SC6->C6_CLI + SC6->C6_LOJA)
		@ Li, 170 PSay SA1->A1_NREDUZ
		@ Li, 190 PSay SC6->C6_PRCVEN PICTURE "@E 999,999,999.99"
		dbSelectArea("SC2")
		
		Li++
		If nOrdem # 2 .And. !lTipo
			@Li ,  0 PSay __PrtThinLine()
			Li++
		Else
			nTotOri	 += C2_QUANT
			nTotSaldo+= IIf(Empty(C2_DATRF),aSC2Sld(cAliasSC2),0)
		EndIf
		dbSkip()
	EndDo
/*	If nOrdem == 2
		Li++           
		@Li ,000 PSay STR0014	//"Total ---->"
		@Li ,015 PSay Substr(cTotal,3)
        If lTipo
		   @Li ,097 PSay nTotOri	Picture PesqPictQt("C2_QUANT",15)
	 	   @Li ,112 PSay nTotSaldo	Picture PesqPictQt("C2_QUANT",15)
	 	   Li++
		   @Li ,  0 PSay __PrtThinLine()
        Else
		   @Li ,125 PSay nTotOri	Picture PesqPictQt("C2_QUANT",15)
	 	   @Li ,142 PSay nTotSaldo	Picture PesqPictQt("C2_QUANT",15)
	 	   Li++
		   @Li ,  0 PSay __PrtThinLine()
		Endif   
		Li++
	EndIf*/
EndDo

If Li != 80
	Roda(cbcont,cbtxt)
EndIF

If lQuery
	dbSelectArea(cAliasSC2)
	dbCloseArea()
EndIf

dbSelectArea("SC2")
Set Filter To
dbSetOrder(1)

If File(cIndex+ordbagext())
	Ferase(cIndex+ordbagext())
Endif

If aReturn[5] == 1
   Set Printer To
   OurSpool(wnrel)
EndIf

MS_FLUSH()
Return NIL
