#Include "MATR110.CH"
//#INCLUDE "XMATR110.CH"
//#INCLUDE "FIVEWIN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MATR110  � Autor � Wagner Xavier         � Data � 05.09.91 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Emissao do Pedido de Compras                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
���              �        �      �                                        ��� 
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function PEDCOM(cAlias,nReg,nOpcx)

LOCAL wnrel		:= "PEDCOM"
LOCAL cDesc1	:= STR0001	//"Emissao dos pedidos de compras ou autorizacoes de entrega"
LOCAL cDesc2	:= STR0002	//"cadastradados e que ainda nao foram impressos"
LOCAL cDesc3	:= " "
LOCAL cString	:= "SC7" 

//Private nTotIPI    := 0
//Private nTotICMS   := 0
//Private nTotDesp   := 0
//Private nTotFrete  := 0
//Private nTotSeguro := 0
//Private nTotal     := 0  
//Private nTotMerc   := 0
//Private nTotalNF   := 0

PRIVATE lAuto		:= (nReg!=Nil)
PRIVATE Tamanho		:= "G"
PRIVATE titulo	 	:=STR0003										//"Emissao dos Pedidos de Compras ou Autorizacoes de Entrega"
PRIVATE aReturn 	:= {STR0004, 1,STR0005, 1, 2, 1, "",0 }		//"Zebrado"###"Administracao"
PRIVATE nomeprog	:="PEDCOM"
PRIVATE cPerg		:= PadR( "PEDCOM" , Len( SX1->X1_GRUPO ) )
PRIVATE nLastKey	:= 0
PRIVATE nBegin		:= 0
PRIVATE nDifColCC   := 0
PRIVATE aLinha		:= {}
PRIVATE aSenhas		:= {}
PRIVATE aUsuarios	:= {}
PRIVATE M_PAG	:= 1

PUBLIC lBR := .F.
PUBLIC cLmt

If Type("lPedido") != "L"
	lPedido := .F.
Endif

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01               Do Pedido                             �
//� mv_par02               Ate o Pedido                          �
//� mv_par03               A partir da data de emissao           �
//� mv_par04               Ate a data de emissao                 �
//� mv_par05               Somente os Novos                      �
//� mv_par06               Campo Descricao do Produto    	     �
//� mv_par07               Unidade de Medida:Primaria ou Secund. �
//� mv_par08               Imprime ? Pedido Compra ou Aut. Entreg�
//� mv_par09               Numero de vias                        �
//� mv_par10               Pedidos ? Liberados Bloqueados Ambos  �
//� mv_par11               Impr. SC's Firmes, Previstas ou Ambas �
//� mv_par12               Qual a Moeda ?                        �
//� mv_par13               Endereco de Entrega                   �
//����������������������������������������������������������������
AjustaSX1()
Pergunte(cPerg,.F.)                                           

//������������������������������������������������������������������������������������������������������������Ŀ
//� Verifica se no SX3 o C7_CC esta com tamanho 9 (Default) se igual a 9 muda o tamanho do relatorio           �
//� para Medio possibilitando a impressao em modo Paisagem ou retrato atraves da reducao na variavel nDifColCC �
//� se o tamanho do C7_CC no SX3 estiver > que 9 o relatorio sera impresso comprrimido com espaco para o campo �
//� C7_CC centro de custo para ate 20 posicoes,Obs.desabilitando a selecao do modo de impresso retrato/paisagem�
//��������������������������������������������������������������������������������������������������������������
dbSelectArea("SX3")
dbSetOrder(2)
If dbSeek("C7_CC")
   If SX3->X3_TAMANHO == 9
      nDifColCC := 11
      Tamanho   := "M"
   Endif
Endif 
Tamanho   := "G"
wnrel:=SetPrint(cString,wnrel,If(lAuto,Nil,"PEDCOM"),@Titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho,,!lAuto)

If nLastKey == 27
	Set Filter To
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter to
	Return
Endif

If lAuto
	mv_par08 := SC7->C7_TIPO
EndIf

If lPedido
	mv_par12 := SC7->C7_MOEDA
Endif

If mv_par08 == 1
	RptStatus({|lEnd| C110PC(@lEnd,wnRel,cString,nReg)},titulo)
Else
	RptStatus({|lEnd| C110AE(@lEnd,wnRel,cString,nReg)},titulo)
EndIf

lPedido := .F.

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � C110PC   � Autor � Cristina M. Ogura     � Data � 09.11.95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR110			                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function C110PC(lEnd,WnRel,cString,nReg)   

Local nReem
Local nOrder
Local cCondBus
Local nSavRec
Local aSavRec := {}
Local nLinObs := 0 
Local ncw := 0
Local i := 0


Private cCGCPict, cCepPict
//��������������������������������������������������������������Ŀ
//�Definir as pictures                                           �
//����������������������������������������������������������������
cCepPict:=PesqPict("SA2","A2_CEP")
cCGCPict:=PesqPict("SA2","A2_CGC")

If nDifColCC >0
   limite   := 130
Else
   limite   := 141   
Endif

li       := 80
nDescProd:= 0
nTotal   := 0
nTotMerc := 0
NumPed   := Space(6)

If lAuto
	dbSelectArea("SC7")
	dbGoto(nReg)
	SetRegua(1)
	mv_par01 := C7_NUM
	mv_par02 := C7_NUM
	mv_par03 := C7_EMISSAO
	mv_par04 := C7_EMISSAO
	mv_par05 := 2
	mv_par08 := C7_TIPO
	mv_par09 := 1
	mv_par10 := 3
	mv_par11 := 3
EndIf

If ( cPaisLoc$"ARG|POR|EUA" )
	cCondBus	:=	"1"+strzero(val(mv_par01),6)
	nOrder	:=	10
	nTipo		:= 1 
Else
	cCondBus	:=mv_par01
	nOrder	:=	1
EndIf

dbSelectArea("SC7")
dbSetOrder(nOrder)
SetRegua(RecCount())
dbSeek(xFilial("SC7")+cCondBus,.T.)

//�������������������������������������������������������������������Ŀ
//� Faz manualmente porque nao chama a funcao Cabec()                 �
//���������������������������������������������������������������������
@ 0,0 PSay AvalImp(Iif(nDifColCC > 0,132,220))

While !Eof() .And. C7_FILIAL = xFilial("SC7") .And. C7_NUM >= mv_par01 .And. ;
		C7_NUM <= mv_par02
	
	//��������������������������������������������������������������Ŀ
	//� Cria as variaveis para armazenar os valores do pedido        �
	//����������������������������������������������������������������
	nOrdem   := 1
	nReem    := 0
	cObs01   := " "
	cObs02   := " "
	cObs03   := " "
	cObs04   := " "
	
	If C7_EMITIDO == "S" .And. mv_par05 == 1
		dbSkip()
		Loop
	Endif
	If (C7_CONAPRO == "B" .And. mv_par10 == 1) .Or.;
	   (C7_CONAPRO != "B" .And. mv_par10 == 2)
		dbSkip()
		Loop
	Endif
	If (C7_EMISSAO < mv_par03) .Or. (C7_EMISSAO > mv_par04)
		dbSkip()
		Loop
	Endif
	If C7_TIPO == 2
		dbSkip()
		Loop
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Filtra Tipo de SCs Firmes ou Previstas                       �
	//����������������������������������������������������������������
	If !MtrAValOP(mv_par11, 'SC7')
		dbSkip()
		Loop
	EndIf
		
	MaFisEnd()
//	MaFisIniPC(SC7->C7_NUM)
	R110FiniPC(SC7->C7_NUM,,,)

	For ncw := 1 To mv_par09		// Imprime o numero de vias informadas
		
		ImpCabec()
		
		nTotal   := 0
		nTotMerc	:= 0
		nDescProd:= 0
		nReem    := SC7->C7_QTDREEM + 1
		nSavRec  := SC7->(Recno())
		NumPed   := SC7->C7_NUM
        nLinObs  := 0

		While !Eof() .And. C7_FILIAL = xFilial("SC7") .And. C7_NUM == NumPed
		
			If Ascan(aSavRec,Recno()) == 0		// Guardo recno p/gravacao
				AADD(aSavRec,Recno())
			Endif
			If lEnd
				@PROW()+1,001 PSAY STR0006	//"CANCELADO PELO OPERADOR"
				Goto Bottom
				Exit
			Endif
			
			IncRegua()
			
			//��������������������������������������������������������������Ŀ
			//� Verifica se havera salto de formulario                       �
			//����������������������������������������������������������������
			If li > 56
				nOrdem++
				ImpRodape()			// Imprime rodape do formulario e salta para a proxima folha
				ImpCabec()
			Endif
			
			li++
			
			dbSelectArea("SB1")
			dbSetOrder(1)
			dbSeek( xFilial()+SC7->C7_PRODUTO )
			cLmt := B1_CODLMT
			dbSelectArea("SC7")
			
			@ li,001 PSAY "|"
			@ li,002 PSAY C7_ITEM  		Picture PesqPict("SC7","c7_item")
			@ li,006 PSAY "|"
//			@ li,007 PSAY Left(cLmt,15)	Picture PesqPict("SC7","c7_produto")
			cLmt := " "
			@ li,007 PSAY C7_PRODUTO	Picture PesqPict("SC7","c7_produto")
			//��������������������������������������������������������������Ŀ
			//� Pesquisa Descricao do Produto                                �
			//����������������������������������������������������������������
			ImpProd()

			If SC7->C7_DESC1 != 0 .or. SC7->C7_DESC2 != 0 .or. SC7->C7_DESC3 != 0
				nDescProd+= CalcDesc(SC7->C7_TOTAL,SC7->C7_DESC1,SC7->C7_DESC2,SC7->C7_DESC3)
			Else
				nDescProd+=SC7->C7_VLDESC
			Endif
			//��������������������������������������������������������������Ŀ
			//� Inicializacao da Observacao do Pedido.                       �
			//����������������������������������������������������������������
			If !EMPTY(SC7->C7_OBS) .And. nLinObs < 5
                nLinObs++
				cVar:="cObs"+StrZero(nLinObs,2)
				Eval(MemVarBlock(cVar),SC7->C7_OBS)
			Endif

			dbSkip()
		EndDo
		
		dbGoto(nSavRec)

		If li>44
			nOrdem++
			ImpRodape()		// Imprime rodape do formulario e salta para a proxima folha
			ImpCabec()
		Endif

		FinalPed(nDescProd)		// Imprime os dados complementares do PC

	Next

	MaFisEnd()
		
	If Len(aSavRec)>0
		For i:=1 to Len(aSavRec)
			dbGoto(aSavRec[i])
			RecLock("SC7",.F.)  //Atualizacao do flag de Impressao
			Replace C7_QTDREEM With (C7_QTDREEM+1)
			Replace C7_EMITIDO With "S"
			MsUnLock()
		Next
		dbGoto(aSavRec[Len(aSavRec)])		// Posiciona no ultimo elemento e limpa array
	Endif
	
	aSavRec := {}
	
	dbSkip()
EndDo

dbSelectArea("SC7")
Set Filter To
dbSetOrder(1)

dbSelectArea("SX3")
dbSetOrder(1)

//��������������������������������������������������������������Ŀ
//� Se em disco, desvia para Spool                               �
//����������������������������������������������������������������
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	dbCommitAll()
	ourspool(wnrel)
Endif

MS_FLUSH()

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � C110AE   � Autor � Cristina M. Ogura     � Data � 09.11.95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR110			                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function C110AE(lEnd,WnRel,cString,nReg)  

Local nReem
Local nSavRec,aSavRec := {}
Local nLinObs := 0 
Local ncw := 0
Local i := 0

Private cCGCPict, cCepPict
//��������������������������������������������������������������Ŀ
//�Definir as pictures                                           �
//����������������������������������������������������������������
cCepPict:=PesqPict("SA2","A2_CEP")
cCGCPict:=PesqPict("SA2","A2_CGC")

If nDifColCC >0
   limite   := 130
Else
   limite   := 141   
Endif

li       := 80
nDescProd:= 0
nTotal   := 0
nTotMerc := 0
NumPed   := Space(6)

If !lAuto
	dbSelectArea("SC7")
	dbSetOrder(10)
	dbSeek(xFilial("SC7")+"2"+mv_par01,.T.)
Else
	dbSelectArea("SC7")
	dbGoto(nReg)
	mv_par01 := C7_NUM
	mv_par02 := C7_NUM
	mv_par03 := C7_EMISSAO
	mv_par04 := C7_EMISSAO
	mv_par05 := 2
	mv_par08 := C7_TIPO
	mv_par09 := 1
	mv_par10 := 3
	mv_par11 := 3
	dbSelectArea("SC7")
	dbSetOrder(10)
	dbSeek(xFilial("SC7")+"2"+mv_par01,.T.)
EndIf

SetRegua(Reccount())
//�������������������������������������������������������������������Ŀ
//� Faz manualmente porque nao chama a funcao Cabec()                 �
//���������������������������������������������������������������������
@ 0,0 PSay AvalImp(Iif(nDifColCC > 0,132,220))
While !Eof().And.C7_FILIAL = xFilial("SC7") .And. C7_NUM >= mv_par01 .And. C7_NUM <= mv_par02
	//��������������������������������������������������������������Ŀ
	//� Cria as variaveis para armazenar os valores do pedido        �
	//����������������������������������������������������������������
	nOrdem   := 1
	nReem    := 0
	cObs01   := " "
	cObs02   := " "
	cObs03   := " "
	cObs04   := " "
	
	If C7_EMITIDO == "S" .And. mv_par05 == 1
    	dbSelectArea("SC7")
		dbSkip()
		Loop
	Endif
	If (C7_CONAPRO == "B" .And. mv_par10 == 1) .Or.;
	   (C7_CONAPRO != "B" .And. mv_par10 == 2)
    	dbSelectArea("SC7")
		dbSkip()
		Loop
	Endif
	If (SC7->C7_EMISSAO < mv_par03) .Or. (SC7->C7_EMISSAO > mv_par04)
    	dbSelectArea("SC7")
		dbSkip()
		Loop
	Endif
	If SC7->C7_TIPO != 2
    	dbSelectArea("SC7")
		dbSkip()
		Loop
	EndIf
	
	//��������������������������������������������������������������Ŀ
	//� Filtra Tipo de SCs Firmes ou Previstas                       �
	//����������������������������������������������������������������
	If !MtrAValOP(mv_par11, 'SC7')
    	dbSelectArea("SC7")
		dbSkip()
		Loop
	EndIf
	
	MaFisEnd()
//	MaFisIniPC(SC7->C7_NUM)
	R110FiniPC(SC7->C7_NUM,,,)

	For ncw := 1 To mv_par09		// Imprime o numero de vias informadas
		
		ImpCabec()

		nTotal   := 0
		nTotMerc	:= 0
		
		nDescProd:= 0
		nReem    := SC7->C7_QTDREEM + 1
		nSavRec  := SC7->(Recno())
		NumPed   := SC7->C7_NUM
        nLinObs  := 0 

		While !Eof() .And. C7_FILIAL = xFilial("SC7") .And. C7_NUM == NumPed
			
			If Ascan(aSavRec,Recno()) == 0		// Guardo recno p/gravacao
				AADD(aSavRec,Recno())
			Endif
						
			If lEnd
				@PROW()+1,001 PSAY STR0006		//"CANCELADO PELO OPERADOR"
				Goto Bottom
				Exit
			Endif
			
			IncRegua()
			
			//��������������������������������������������������������������Ŀ
			//� Verifica se havera salto de formulario                       �
			//����������������������������������������������������������������
			If li > 56
				nOrdem++
				ImpRodape()		// Imprime rodape do formulario e salta para a proxima folha
				ImpCabec()
			Endif
			li++
			@ li,001 PSAY "|"
			@ li,002 PSAY SC7->C7_ITEM  	Picture PesqPict("SC7","C7_ITEM")
			@ li,006 PSAY "|"
			@ li,007 PSAY SC7->C7_PRODUTO	Picture PesqPict("SC7","C7_PRODUTO")
			//��������������������������������������������������������������Ŀ
			//� Pesquisa Descricao do Produto                                �
			//����������������������������������������������������������������
			ImpProd()		// Imprime dados do Produto
			
			If SC7->C7_DESC1 != 0 .or. SC7->C7_DESC2 != 0 .or. SC7->C7_DESC3 != 0
				nDescProd+= CalcDesc(SC7->C7_TOTAL,SC7->C7_DESC1,SC7->C7_DESC2,SC7->C7_DESC3)
			Else
			   nDescProd+=SC7->C7_VLDESC
			Endif		
			//��������������������������������������������������������������Ŀ
			//� Inicializacao da Observacao do Pedido.                       �
			//����������������������������������������������������������������
			If !EMPTY(SC7->C7_OBS) .And. nLinObs < 5
                nLinObs++
				cVar:="cObs"+StrZero(nLinObs,2)
				Eval(MemVarBlock(cVar),SC7->C7_OBS)
			Endif                                                             

         	dbSelectArea("SC7")
			dbSkip()
		EndDo
		
		dbGoto(nSavRec)
		If li>38
			nOrdem++
			ImpRodape()		// Imprime rodape do formulario e salta para a proxima folha
			ImpCabec()
		Endif
		
		FinalAE(nDescProd)		// dados complementares da Autorizacao de Entrega
	Next

	MaFisEnd()
	
	If Len(aSavRec)>0
		dbGoto(aSavRec[Len(aSavRec)])
		For i:=1 to Len(aSavRec)
			dbGoto(aSavRec[i])
			RecLock("SC7",.F.)  //Atualizacao do flag de Impressao
			Replace C7_EMITIDO With "S"
			Replace C7_QTDREEM With (C7_QTDREEM+1)
			MsUnLock()
		Next
	Endif
	aSavRec := {}
    dbSelectArea("SC7")
	dbSkip()
End

dbSelectArea("SC7")
Set Filter To
dbSetOrder(1)

dbSelectArea("SX3")
dbSetOrder(1)
  
//��������������������������������������������������������������Ŀ
//� Se em disco, desvia para Spool                               �
//����������������������������������������������������������������
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif

MS_FLUSH()

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ImpProd  � Autor � Wagner Xavier         � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Pesquisar e imprimir  dados Cadastrais do Produto.         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ImpProd(Void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MatR110                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ImpProd()

LOCAL cDesc, nLinRef := 1, nBegin := 0, cDescri := "", nLinha:=0,;
		nTamDesc := 28, aColuna := Array(8)

If Empty(mv_par06)
	mv_par06 := "B1_DESC"
EndIf

//��������������������������������������������������������������Ŀ
//� Impressao da descricao generica do Produto.                  �
//����������������������������������������������������������������
If AllTrim(mv_par06) == "B1_DESC"
	cDescri := AllTrim (SB1->B1_CODLMT) + " / " + Alltrim(SB1->B1_DESC) + " ("+Alltrim(SB1->B1_CAT)+")"
	dbSelectArea("SC7")
EndIf

If AllTrim(mv_par06) == "B1_DENOM"
	If Empty (SB1->B1_DENOM) .or. Left(SB1->B1_TIPO,1) == "M"              //  (mv_par12==4 .and. ("Sergio" $ cUsuario .or. "Daniel" $ cUsuario))
		cDescri := Trim(SC7->C7_DESCRI) + " ("+Alltrim(SB1->B1_CAT)+")"
	Else
		cDescri := AllTrim (SB1->B1_CODLMT) + " / " + Alltrim(SB1->B1_DENOM)  //Tanimoto 17/09/13. Esta linha estava comentada e linha abaixo estava executando. O Sr. Jose carlos solicitou que imprimisse a descricao B1_DENOM conforme parametro
		//cDescri := Alltrim(SB1->B1_DESC) + " ("+Alltrim(SB1->B1_CAT)+")"
	Endif
	dbSelectArea("SC7")
EndIf

//��������������������������������������������������������������Ŀ
//� Impressao da descricao cientifica do Produto.                �
//����������������������������������������������������������������
If AllTrim(mv_par06) == "B5_CEME"
	dbSelectArea("SB5")
	dbSetOrder(1)
	If dbSeek( xFilial()+SC7->C7_PRODUTO )
		cDescri := Alltrim(B5_CEME) + " ("+Alltrim(SB1->B1_CAT)+")"
	EndIf
	dbSelectArea("SC7")
EndIf

dbSelectArea("SC7")
If AllTrim(mv_par06) == "C7_DESCRI"
	cDescri := Alltrim(SC7->C7_DESCRI) + " ("+Alltrim(SB1->B1_CAT)+")"
EndIf

If Empty(cDescri)
	cDescri := AllTrim (SB1->B1_CODLMT) + " / " + Alltrim(SB1->B1_DESC) + " ("+Alltrim(SB1->B1_CAT)+")"
	dbSelectArea("SC7")
EndIf

//dbSelectArea("SA5")
//dbSetOrder(1)
//If dbSeek(xFilial()+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_PRODUTO).And. !Empty(SA5->A5_CODPRF)
//	cDescri := cDescri + " ("+Alltrim(A5_CODPRF)+")"
//EndIf
dbSelectArea("SC7")
aColuna[1] :=  51
aColuna[2] :=  54
aColuna[3] :=  67
aColuna[4] :=  82
aColuna[5] :=  88
aColuna[6] := 105
aColuna[7] := 116
acoluna[8] := 144 - nDifColCC
           
nLinha2  := 1
nLinha	 := MLCount(cDescri,nTamDesc)
oldLinha := nLinha
If !Empty(Substr(cLmt,16))
	nLinha2++
Endif
If !Empty(Substr(cLmt,31))
	nLinha2++
Endif
If nLinha2 > nlinha
	nLinha := nLinha2
Endif

@ li,022 PSAY "|"
@ li,023 PSAY MemoLine(cDescri,nTamDesc,1)

ImpCampos()
For nBegin := 2 To IF(nLinha<2,2,nLinha)
	li++
	@ li,001 PSAY "|"
	@ li,006 PSAY "|"
//	@ li,007 PSAY Substr(cLmt,((nbegin-1)*15)+1,15)
	If	nBegin == 2
		@ li,007 PSAY "NCM: " + TransForm( SB1->B1_POSIPI , "@R XXXX.XX.XX" )
	EndIf
	@ li,022 PSAY "|"
	@ li,023 PSAY Iif(nBegin <= oldLinha,Memoline(cDescri,nTamDesc,nBegin),"")
	@ li,aColuna[1] PSAY "|"
	@ li,acoluna[2] PSAY "|"  
	@ li,acoluna[3] PSAY "|"  
    @ li,aColuna[4] PSAY "|"

	If mv_par08 == 1
	   	If cPaisLoc == "BRA"
	    	@ li,aColuna[5] PSAY "|"
	    	@ li,aColuna[5]+6 PSAY "|"
		else
			@ li,aColuna[5] PSAY " "
		EndIf
		@ li,aColuna[6]+2 PSAY "|"
		@ li,116 PSAY "|"
		@ li,137 - nDIfColCC PSAY "|"
		@ li,aColuna[8] PSAY "|"
	Else
		@ li,099 PSAY "|"
		@ li,110 PSAY "|"
		@ li,144 - nDifColCC PSAY "|"
	EndIf
Next nBegin

Return NIL
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ImpCampos� Autor � Wagner Xavier         � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprimir dados Complementares do Produto no Pedido.        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ImpCampos(Void)                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MatR110                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ImpCampos()

LOCAL aColuna[6]
Local nTxMoeda := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,Nil)

dbSelectArea("SC7")

	aColuna[1] :=  51
	aColuna[2] :=  54
	aColuna[3] :=  67
	aColuna[4] :=  82
	aColuna[5] :=  88
	aColuna[6] := 105

@ li,aColuna[1] PSAY "|"
If MV_PAR07 == 2 .And. !Empty(SC7->C7_SEGUM)
   @ li,PCOL() PSAY SC7->C7_SEGUM Picture PesqPict("SC7","C7_UM")
Else
   @ li,PCOL() PSAY SC7->C7_UM    Picture PesqPict("SC7","C7_UM")
EndIf
@ li,aColuna[2] PSAY "|"
If MV_PAR07 == 2 .And. !Empty(SC7->C7_QTSEGUM) 
   @ li,PCOL()+3	PSAY SC7->C7_QTSEGUM Picture "999999999"
Else
   @ li,PCOL()+3	PSAY SC7->C7_QUANT  //////Picture Iif(mv_par12 == 4,"999999999","999999,99")
EndIf
@ li,aColuna[3] PSAY "|"
If MV_PAR07 == 2 .And. !Empty(SC7->C7_QTSEGUM)  
   @ li,PCOL()	PSAY xMoeda((SC7->C7_TOTAL/SC7->C7_QTSEGUM),SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture PesqPict("SC7","C7_PRECO",14, mv_par12)
Else
   @ li,PCOL()	PSAY SC7->C7_PRECO Picture PesqPict("SC7","C7_PRECO",14,mv_par12)
//   @ li,PCOL()	PSAY xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture PesqPict("SC7","C7_PRECO",14,mv_par12)
EndIf
@ li,aColuna[4] PSAY "|"

If mv_par08 == 1
	If cPaisLoc == "BRA"
		@ li,PCOL()	PSAY Iif(mv_par12==1,SC7->C7_IPI,0) Picture PesqPictQt("C7_IPI",5)
		@ li,PCOL()	PSAY "|"
		@ li,PCOL()	PSAY Iif(mv_par12==1,SC7->C7_PICM,0) Picture PesqPictQt("C7_PICM",5)
		@ li,PCOL()	PSAY "|"
	Else
		@ li,    PCOL() 	PSAY "  "
		@ li,aColuna[5]-2 	PSAY " "
		@ li,    PCOL() 	PSAY " "
	EndIf
	@ li,PCOL()	PSAY SC7->C7_TOTAL Picture PesqPict("SC7","C7_TOTAL",12,mv_par12)
//	@ li,PCOL()	PSAY xMoeda(SC7->C7_TOTAL,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture PesqPict("SC7","C7_TOTAL",12,mv_par12)
	@ li,PCOL()	PSAY "|"
	@ li,PCOL()	PSAY SC7->C7_DATPRF  				 Picture PesqPict("SC7","C7_DATPRF")
	@ li,PCOL()	PSAY "|"
	@ li,PCOL()	PSAY SC7->C7_CC      				 Picture PesqPict("SC7","C7_CC",20)
	@ li,PCOL()	PSAY "|"
	@ li,PCOL()	PSAY SC7->C7_NUMSC
	@ li,PCOL()	PSAY "|"
Else
    @ li,  PCOL() PSAY SC7->C7_TOTAL Picture PesqPict("SC7","C7_TOTAL",16,mv_par12)
//  @ li,  PCOL() PSAY xMoeda(SC7->C7_TOTAL,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture PesqPict("SC7","C7_TOTAL",16,mv_par12)
	@ li,     098 PSAY "|"
	@ li,  PCOL() PSAY SC7->C7_DATPRF  				 Picture PesqPict("SC7","C7_DATPRF")
	@ li,     109 PSAY "|"
	@ li,  PCOL() PSAY SC7->C7_OP
	@ li,143 - nDifColCC PSAY "|"
EndIf

//nTotMerc	:= nTotMerc + SC7->C7_TOTAL
//nTotal	  	:= nTotal   + SC7->C7_TOTAL + SC7->C7_VALIPI
//nTotalNF   := nTotalNF  + SC7->C7_TOTAL + SC7->C7_VALIPI + SC7->C7_DESPESA + SC7->C7_VALFRE + SC7->C7_SEGURO
nTotMerc	:= Iif(mv_par12==1,MaFisRet(,"NF_TOTAL"),nTotal)
//nTotMerc	:= nTotal

//nTotIPI    := nTotIPI    + SC7->C7_VALIPI
//nTotICMS   := nTotICMS   + SC7->C7_VALICM
//nTotDesp   := nTotDesp   + SC7->C7_DESPESA
//nTotFrete  := nTotFrete  + SC7->C7_VALFRE
//nTotSeguro := nTotSeguro + SC7->C7_SEGURO

Return .T.
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FinalPed � Autor � Wagner Xavier         � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime os dados complementares do Pedido de Compra        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FinalPed(Void)                                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MatR110                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FinalPed(nDescProd)

Local nk 		:= 1,nG
Local nQuebra	:= 0
Local nTotDesc	:= nDescProd
Local lNewAlc	:= .F.
Local lLiber 	:= .F.
Local lImpLeg	:= .T.
Local cComprador:= ""
LOcal cAlter	:= ""
Local cAprov	:= ""
Local nTotIpi	:= Iif(mv_par12==1,MaFisRet(,'NF_VALIPI'),0)
Local nTotIcms	:= Iif(mv_par12==1,MaFisRet(,'NF_VALICM'),0)
Local nTotDesp	:= MaFisRet(,'NF_DESPESA')
Local nTotFrete	:= MaFisRet(,'NF_FRETE')
Local nTotalNF	:= Iif(mv_par12==1,MaFisRet(,"NF_TOTAL"),nTotal)
Local nTotSeguro:= MaFisRet(,'NF_SEGURO')
Local aValIVA   := MaFisRet(,"NF_VALIMP")
Local nValIVA   := 0
Local aColuna   := Array(8), nTotLinhas
Local nTxMoeda  := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,Nil)
Local nX := 0

If cPaisLoc <> "BRA" .And. !Empty(aValIVA)
   For nG:=1 to Len(aValIVA)
       nValIVA+=aValIVA[nG]
   Next
Endif

cMensagem:= Formula(C7_MSG)

If !Empty(cMensagem)
	li++
	@ li,001 PSAY "|"
	@ li,002 PSAY Padc(cMensagem,129)
	@ li,144 - nDifColCC PSAY "|"
Endif
li++
@ li,001 PSAY "|"
@ li,002 PSAY Replicate("-",limite)
@ li,144 - nDifColCC PSAY "|"
li++

aColuna[1] :=  51
aColuna[2] :=  54
aColuna[3] :=  67
aColuna[4] :=  82
aColuna[5] :=  88
aColuna[6] := 105
acoluna[7] := 116
aColuna[8] := 144 - nDifColCC 
nTotLinhas :=  40

While li<nTotLinhas
	@ li,001 PSAY "|"
	@ li,006 PSAY "|"
	@ li,022 PSAY "|"
	@ li,022 + nk PSAY "*"
	nk := IIf( nk == 42 , 1 , nk + 1 )
	@ li,aColuna[1] PSAY "|"
	@ li,aColuna[2] PSAY "|"
	@ li,aColuna[3] PSAY "|"
	@ li,aColuna[4] PSAY "|"
	If cPaisLoc == "BRA"
		@ li,aColuna[5] PSAY "|"
		@ li,aColuna[5]+6 PSAY "|"
	EndIf
	@ li,aColuna[6]+2 PSAY "|"
	@ li,116 PSAY "|"
	@ li,137 - nDifColCC PSAY "|"
	@ li,aColuna[8] PSAY "|"
	li++
EndDo
@ li,001 PSAY "|"
@ li,002 PSAY Replicate("-",limite)
@ li,144 - nDifColCC PSAY "|"
li++
@ li,001 PSAY "|"
@ li,015 PSAY STR0007		//"D E S C O N T O S -->"
@ li,037 PSAY C7_DESC1 Picture "999,99"
@ li,046 PSAY C7_DESC2 Picture "999,99"
@ li,055 PSAY C7_DESC3 Picture "999,99"

@ li,068 PSAY xMoeda(nTotDesc,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture PesqPict("SC7","C7_VLDESC",14, mv_par12)

@ li,144 - nDifColCC PSAY "|"
li++
@ li,001 PSAY "|"
@ li,002 PSAY Replicate("-",limite)
@ li,144 - nDifColCC PSAY "|"
li++
@ li,001 PSAY "|"
//��������������������������������������������������������������Ŀ
//� Posiciona o Arquivo de Empresa SM0.                          �
//����������������������������������������������������������������
cAlias := Alias()
dbSelectArea("SM0")
dbSetOrder(1)   // forca o indice na ordem certa
nRegistro := Recno()
dbSeek(SUBS(cNumEmp,1,2)+SC7->C7_FILENT)

//��������������������������������������������������������������Ŀ
//� Imprime endereco de entrega do SM0 somente se o MV_PAR13 =" "�
//����������������������������������������������������������������
If Empty(MV_PAR13)
	@ li,003 PSAY STR0008 + AllTrim(SM0->M0_ENDENT)+" - "+AllTrim(SM0->M0_CIDENT)+" - "+AllTrim(SM0->M0_ESTENT)+;
	" - CEP: "+AllTrim(Trans(Alltrim(SM0->M0_CEPENT),cCepPict))		//"Local de Entrega  : "
//	@ li,057 PSAY "-"
//	@ li,061 PSAY SM0->M0_CIDENT
//	@ li,083 PSAY "-"
//	@ li,085 PSAY SM0->M0_ESTENT
//	@ li,088 PSAY "-"
//	@ li,090 PSAY STR0009	//"CEP :"
//	@ li,096 PSAY Trans(Alltrim(SM0->M0_CEPENT),cCepPict)
Else
	@ li,003 PSAY STR0008 + MV_PAR13		//"Local de Entrega  : " imprime o endereco digitado na pergunte
Endif

@ li,144 - nDifColCC PSAY "|"
dbGoto(nRegistro)
dbSelectArea( cAlias )

li++
@ li,001 PSAY "|"
@ li,003 PSAY STR0010 + AllTrim(SM0->M0_ENDCOB)+" - "+AllTrim(SM0->M0_CIDCOB)+" - "+AllTrim(SM0->M0_ESTCOB)+;
" - CEP: "+AllTrim(Trans(Alltrim(SM0->M0_CEPCOB),cCepPict))		//"Local de Cobranca : "
//@ li,057 PSAY "-"
//@ li,061 PSAY SM0->M0_CIDCOB
//@ li,083 PSAY "-"
//@ li,085 PSAY SM0->M0_ESTCOB
//@ li,088 PSAY "-"
//@ li,090 PSAY STR0009	//"CEP :"
//@ li,096 PSAY Trans(Alltrim(SM0->M0_CEPCOB),cCepPict)
@ li,144 - nDifColCC PSAY "|"
li++
@ li,001 PSAY "|"
@ li,002 PSAY Replicate("-",limite)
@ li,144 - nDifColCC PSAY "|"

dbSelectArea("SE4")
dbSetOrder(1)
dbSeek(xFilial()+SC7->C7_COND)
dbSelectArea("SC7")
li++
@ li,001 PSAY "|"
@ li,003 PSAY STR0011+SubStr(SE4->E4_COND,1,15)		//"Condicao de Pagto "
@ li,038 PSAY STR0012		//"|Data de Emissao|"
@ li,056 PSAY STR0013		//"Total das Mercadorias : "
//@ li,094 PSAY xMoeda(nTotal,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture tm(nTotal,14,MsDecimais(MV_PAR12))
@ li,094 PSAY nTotMerc Picture tm(nTotMerc,14,MsDecimais(MV_PAR12))
@ li,144 - nDifColCC PSAY "|"
li++
@ li,001 PSAY "|"
@ li,003 PSAY SubStr(SE4->E4_DESCRI,1,34)
@ li,038 PSAY "|"
@ li,043 PSAY SC7->C7_EMISSAO
@ li,054 PSAY "|"
If cPaisLoc<>"BRA"
   	@ li,056 PSAY OemtoAnsi(STR0063)	//"Total de los Impuestos : "
	@ li,094 PSAY xMoeda(nValIVA,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture tm(nValIVA,14,MsDecimais(MV_PAR12))
Else
	@ li,056 PSAY STR0064		//"Total com Impostos : "
//	@ li,094 PSAY xMoeda(nTotMerc,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture tm(nTotMerc,14,MsDecimais(MV_PAR12))
	@ li,094 PSAY nTotal Picture tm(nTotal,14,MsDecimais(MV_PAR12))
Endif
@ li,144 - nDifColCC PSAY "|"
li++
@ li,001 PSAY "|"
@ li,002 PSAY Replicate("-",52)
@ li,054 PSAY "|"
@ li,055 PSAY Replicate("-",88 - nDifColCC)
@ li,144 - nDifColCC PSAY "|"
li++
dbSelectArea("SM4")
dbSetOrder(1)
dbSeek(xFilial()+SC7->C7_REAJUST)
dbSelectArea("SC7")

@ li,001 PSAY "|"
@ li,003 PSAY STR0014		//"Reajuste :"
@ li,014 PSAY SC7->C7_REAJUST Picture PesqPict("SC7","c7_reajust",,mv_par12)
@ li,018 PSAY SM4->M4_DESCR

If cPaisLoc == "BRA"
	@ li,054 PSAY STR0015		//"| IPI   :"
//	@ li,064 PSAY xMoeda(nTotIPI,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture tm(nTotIpi,14,MsDecimais(MV_PAR12))
	@ li,064 PSAY nTotIPI Picture tm(nTotIpi,14,MsDecimais(MV_PAR12))
	@ li,088 PSAY "| ICMS   : "
//	@ li,100 PSAY xMoeda(0,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture tm(nTotIcms,14,MsDecimais(MV_PAR12))  // nTotIcms
//	@ li,100 PSAY xMoeda(nTotIcms,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture tm(nTotIcms,14,MsDecimais(MV_PAR12))  // nTotIcms
	@ li,100 PSAY nTotIcms Picture tm(nTotIcms,14,MsDecimais(MV_PAR12))  // nTotIcms
	@ li,144 - nDifColCC PSAY "|"
Else	
	@ li,054 PSAY "|"
	@ li,144 - nDifColCC PSAY "|"
EndIf

li++
@ li,001 PSAY "|"
@ li,002 PSAY Replicate("-",52)
@ li,054 PSAY (STR0049) //"| Frete :"
//@ li,064 PSAY xMoeda(nTotFrete,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture tm(nTotFrete,14,MsDecimais(MV_PAR12))
@ li,064 PSAY nTotFrete Picture tm(nTotFrete,14,MsDecimais(MV_PAR12))
@ li,088 PSAY (STR0058) //"| Despesas :"
//@ li,100 PSAY xMoeda(nTotDesp,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture tm(nTotDesp,14,MsDecimais(MV_PAR12))
@ li,100 PSAY nTotDesp Picture tm(nTotDesp,14,MsDecimais(MV_PAR12))

@ li,144 - nDifColCC PSAY "|"
//��������������������������������������������������������������Ŀ
//� Inicializar campos de Observacoes.                           �
//����������������������������������������������������������������
If Empty(cObs02)
	If Len(cObs01) > 50
		cObs := cObs01
		cObs01 := Substr(cObs,1,50)
		For nX := 2 To 4
			cVar  := "cObs"+StrZero(nX,2)
			&cVar := Substr(cObs,(50*(nX-1))+1,50)
		Next
	EndIf
Else
	cObs01:= Substr(cObs01,1,IIf(Len(cObs01)<50,Len(cObs01),50))
	cObs02:= Substr(cObs02,1,IIf(Len(cObs02)<50,Len(cObs01),50))
	cObs03:= Substr(cObs03,1,IIf(Len(cObs03)<50,Len(cObs01),50))
	cObs04:= Substr(cObs04,1,IIf(Len(cObs04)<50,Len(cObs01),50))
EndIf

dbSelectArea("SC7")
If !Empty(C7_APROV)
	lNewAlc := .T.
	cComprador := UsrFullName(SC7->C7_USER)
	If C7_CONAPRO != "B"
		lLiber := .T.
	EndIf
	dbSelectArea("SCR")
	dbSetOrder(1)
	dbSeek(xFilial()+"PC"+SC7->C7_NUM)
	While !Eof() .And. SCR->CR_FILIAL+Alltrim(SCR->CR_NUM)==xFilial("SCR")+SC7->C7_NUM .And. SCR->CR_TIPO == "PC"
	  cAprov += AllTrim(UsrFullName(SCR->CR_USER))+" ["+;
	 	  IF(SCR->CR_STATUS=="03","Ok",IF(SCR->CR_STATUS=="04","BLQ","??"))+"] - "
	  dbSelectArea("SCR")
	  dbSkip()
	Enddo
	If !Empty(SC7->C7_GRUPCOM)
		dbSelectArea("SAJ")
		dbSetOrder(1)
		dbSeek(xFilial()+SC7->C7_GRUPCOM)
		While !Eof() .And. SAJ->AJ_FILIAL+SAJ->AJ_GRCOM == xFilial("SAJ")+SC7->C7_GRUPCOM
			If SAJ->AJ_USER != SC7->C7_USER
				cAlter += AllTrim(UsrFullName(SAJ->AJ_USER))+"/"
			EndIf
			dbSelectArea("SAJ")
			dbSkip()
		EndDo
	EndIf
EndIf

li++
@ li,001 PSAY STR0016		//"| Observacoes"
@ li,054 PSAY STR0017		//"| Grupo :"
@ li,088 PSAY STR0059      //"| SEGURO :"
@ li,100 PSAY nTotSeguro Picture tm(nTotSeguro,14,MsDecimais(MV_PAR12))
//@ li,100 PSAY xMoeda(nTotSeguro,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture tm(nTotSeguro,14,MsDecimais(MV_PAR12))
@ li,144 - nDifColCC PSAY "|"
li++
@ li,001 PSAY "|"
@ li,003 PSAY cObs01
@ li,054 PSAY "|"+Replicate("-",88 - nDifColCC)
@ li,144 - nDifColCC PSAY "|"
li++
@ li,001 PSAY "|"
@ li,003 PSAY cObs02
@ li,054 PSAY STR0018		//"| Total Geral : "

If !lNewAlc
//	@ li,094 PSAY xMoeda(nTotalNF,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture tm(nTotalNF,14,MsDecimais(MV_PAR12))
	@ li,094 PSAY nTotalNF Picture tm(nTotalNF,14,MsDecimais(MV_PAR12))
Else
	If lLiber
//		@ li,094 PSAY xMoeda(nTotalNF,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture tm(nTotalNF,14,MsDecimais(MV_PAR12))
		@ li,094 PSAY nTotalNF Picture tm(nTotalNF,14,MsDecimais(MV_PAR12))
	Else
		@ li,080 PSAY (STR0051)
	EndIf
EndIf
		
@ li,144 - nDifColCC PSAY "|"
li++
@ li,001 PSAY "|"
@ li,003 PSAY cObs03
@ li,054 PSAY "|"+Replicate("-",88 - nDifColCC)
@ li,144 - nDifColCC PSAY "|"
li++

If !lNewAlc
	@ li,001 PSAY "|"
	@ li,003 PSAY cObs04
	@ li,054 PSAY "|"
	@ li,061 PSAY STR0019		//"|           Liberacao do Pedido"
	@ li,102 PSAY STR0020		//"| Obs. do Frete: "
	@ li,119 PSAY IF( SC7->C7_TPFRETE $ "F","FOB",IF(SC7->C7_TPFRETE $ "C","CIF"," " ))
	@ li,144 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"+Replicate("-",59)
	@ li,061 PSAY "|"
	@ li,102 PSAY "|"
	@ li,144 - nDifColCC PSAY "|"
	
	li++
	cLiberador := ""
	nPosicao := 0
	@ li,001 PSAY "|"
	@ li,007 PSAY STR0021		//"Comprador"
	@ li,021 PSAY "|"
	@ li,028 PSAY STR0022		//"Gerencia"
	@ li,041 PSAY "|"
	@ li,046 PSAY STR0023		//"Diretoria"
	@ li,061 PSAY "|     ------------------------------"
	@ li,102 PSAY "|"
	@ li,144 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,021 PSAY "|"
	@ li,041 PSAY "|"
	@ li,061 PSAY "|     " + R110Center(cLiberador) // 30 posicoes
	@ li,102 PSAY "|"
	@ li,144 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",limite)
	@ li,144 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY STR0024		//"|   NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero do nosso Pedido de Compras."
	@ li,144 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",limite)
	@ li,144 - nDifColCC PSAY "|"
Else
	@ li,001 PSAY "|"
	@ li,003 PSAY cObs04
	@ li,054 PSAY "|"
	@ li,059 PSAY IF(lLiber,STR0050,STR0051)		//"     P E D I D O   L I B E R A D O"#"|     P E D I D O   B L O Q U E A D O !!!"
	@ li,102 PSAY STR0020		//"| Obs. do Frete: "
	@ li,119 PSAY IF( SC7->C7_TPFRETE $ "F","FOB",IF(SC7->C7_TPFRETE $ "C","CIF"," " ))
	@ li,144 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"+Replicate("-",99)
	@ li,102 PSAY "|"
	@ li,144 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,003 PSAY STR0052		//"Comprador Responsavel :"
	@ li,027 PSAY Substr(cComprador,1,60)
	@ li,088 PSAY "|"
	@ li,089 PSAY STR0060      //"BLQ:Bloqueado"
	@ li,102 PSAY "|"
	@ li,144 - nDifColCC PSAY "|"
	li++	
	nAuxLin := Len(cAlter)
	@ li,001 PSAY "|"
	@ li,003 PSAY STR0053		//"Compradores Alternativos :"
	While nAuxLin > 0 .oR. lImpLeg
		@ li,029 PSAY Substr(cAlter,Len(cAlter)-nAuxLin+1,60)
		@ li,088 PSAY "|"
		If lImpLeg 
			@ li,089 PSAY STR0061   //"Ok:Liberado"
			lImpLeg := .F.
		EndIf
		@ li,102 PSAY "|"
		@ li,144 - nDifColCC PSAY "|"
		nAuxLin -= 60
		li++	
	EndDo		
	nAuxLin := Len(cAprov)
	lImpLeg := .T.
	@ li,001 PSAY "|"
	@ li,003 PSAY STR0054		//"Aprovador(es) :"
	While nAuxLin > 0	.Or. lImpLeg
		@ li,019 PSAY Substr(cAprov,Len(cAprov)-nAuxLin+1,70)
		@ li,088 PSAY "|"
		If lImpLeg
			@ li,089 PSAY STR0062  //"??:Aguar.Lib"
			lImpLeg := .F.
		EndIf
		@ li,102 PSAY "|"
		@ li,144 - nDifColCC PSAY "|"
		nAUxLin -=70
		li++	
	EndDo
	If nAuxLin == 0
		li++
	EndIf
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",limite)
	@ li,144 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY STR0024		//"|   NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero do nosso Pedido de Compras."
	@ li,144 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",limite)
	@ li,144 - nDifColCC PSAY "|"	
EndIf

Return .T.
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FinalAE  � Autor � Cristina Ogura        � Data � 05.04.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime os dados complementares da Autorizacao de Entrega  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FinalAE(Void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MatR110                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FinalAE(nDescProd)
Local nk 		:= 1
Local nTotDesc	:= nDescProd
Local nTotNF	:= MaFisRet(,'NF_TOTAL')
Local nTxMoeda	:= IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,Nil)
Local nX := 0

cMensagem:= Formula(C7_MSG)

If !Empty(cMensagem)
	li++
	@ li,001 PSAY "|"
	@ li,002 PSAY Padc(cMensagem,129)
	@ li,144 - nDifColCC PSAY "|"
Endif
li++
@ li,001 PSAY "|"
@ li,002 PSAY Replicate("-",limite)
@ li,144 - nDifColCC PSAY "|"
li++
While li<39
	@ li,001 PSAY "|"
	@ li,006 PSAY "|"
	@ li,022 PSAY "|"
	@ li,022 + nk PSAY "*"
	nk := IIf( nk == 32 , 1 , nk + 1 )
	@ li,051 PSAY "|"
	@ li,054 PSAY "|"
	@ li,067 PSAY "|"
	@ li,082 PSAY "|"
	@ li,099 PSAY "|"
	@ li,110 PSAY "|"
	@ li,144 - nDifColCC PSAY "|"
	li++
EndDo
@ li,001 PSAY "|"
@ li,002 PSAY Replicate("-",limite)
@ li,144 - nDifColCC PSAY "|"
li++
@ li,001 PSAY "|"

//��������������������������������������������������������������Ŀ
//� Posiciona o Arquivo de Empresa SM0.                          �
//����������������������������������������������������������������
cAlias := Alias()
dbSelectArea("SM0")
dbSetOrder(1)   // forca o indice na ordem certa
nRegistro := Recno()
dbSeek(SUBS(cNumEmp,1,2)+SC7->C7_FILENT)
//��������������������������������������������������������������Ŀ
//� Imprime endereco de entrega do SM0 somente se o MV_PAR13 =" "�
//����������������������������������������������������������������
If Empty(MV_PAR13)
	@ li,003 PSAY STR0008 + AllTrim(SM0->M0_ENDENT)+" - "+AllTrim(SM0->M0_CIDENT)+" - "+AllTrim(SM0->M0_ESTENT)+;
	" - CEP: "+AllTrim(Trans(Alltrim(SM0->M0_CEPENT),cCepPict))		//"Local de Entrega  : "
//	@ li,003 PSAY STR0008 + AllTrim(SM0->M0_ENDENT)		//"Local de Entrega  : "
//	@ li,057 PSAY "-"
//	@ li,061 PSAY SM0->M0_CIDENT
//	@ li,083 PSAY "-"
//	@ li,085 PSAY SM0->M0_ESTENT
// 	@ li,088 PSAY "-"
//	@ li,090 PSAY STR0009	//"CEP :"
//	@ li,096 PSAY Trans(Alltrim(SM0->M0_CEPENT),cCepPict)
Else
	@ li,003 PSAY STR0008 + MV_PAR13		//"Local de Entrega  : " imprime o endereco digitado na pergunte
Endif

@ li,144 - nDifColCC PSAY "|"
dbGoto(nRegistro)
dbSelectArea(cAlias)

li++
@ li,001 PSAY "|"
@ li,003 PSAY STR0010 + AllTrim(SM0->M0_ENDCOB)+" - "+AllTrim(SM0->M0_CIDCOB)+" - "+AllTrim(SM0->M0_ESTCOB)+;
" - CEP: "+AllTrim(Trans(Alltrim(SM0->M0_CEPCOB),cCepPict))		//"Local de Cobranca : "
//@ li,003 PSAY STR0010 + AllTrim(SM0->M0_ENDCOB)		//"Local de Cobranca : "
//@ li,057 PSAY "-"
//@ li,061 PSAY SM0->M0_CIDCOB
//@ li,083 PSAY "-"
//@ li,085 PSAY SM0->M0_ESTCOB
//@ li,088 PSAY "-"
//@ li,090 PSAY STR0009	//"CEP :"
//@ li,096 PSAY Trans(Alltrim(SM0->M0_CEPCOB),cCepPict)
@ li,144 - nDifColCC PSAY "|"
li++
@ li,001 PSAY "|"
@ li,002 PSAY Replicate("-",limite)
@ li,144 - nDifColCC PSAY "|"

dbSelectArea("SE4")
dbSetOrder(1)
dbSeek(xFilial()+SC7->C7_COND)
dbSelectArea("SC7")
li++
@ li,001 PSAY "|"
@ li,003 PSAY STR0011+SubStr(SE4->E4_COND,1,15)		//"Condicao de Pagto "
@ li,038 PSAY STR0012		// "|Data de Emissao|"
@ li,056 PSAY STR0013		// "Total das Mercadorias : "
@ li,094 PSAY xMoeda(nTotal,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture tm(nTotal,14,MsDecimais(MV_PAR12))

@ li,144 - nDifColCC PSAY "|"
li++
@ li,001 PSAY "|"
@ li,003 PSAY SubStr(SE4->E4_DESCRI,1,34)
@ li,038 PSAY "|"
@ li,043 PSAY SC7->C7_EMISSAO
@ li,054 PSAY "|"
@ li,056 PSAY STR0064		// "Total com Impostos : "
@ li,094 PSAY xMoeda(nTotMerc,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture tm(nTotMerc,14,MsDecimais(MV_PAR12))
@ li,144 - nDifColCC PSAY "|"
li++
@ li,001 PSAY "|"
@ li,002 PSAY Replicate("-",52)
@ li,054 PSAY "|"
@ li,055 PSAY Replicate("-",88 - nDifColCC)
@ li,144 - nDifColCC PSAY "|"
li++
dbSelectArea("SM4")
dbSeek(xFilial()+SC7->C7_REAJUST)
dbSelectArea("SC7")
@ li,001 PSAY "|"
@ li,003 PSAY STR0014		//"Reajuste :"
@ li,014 PSAY SC7->C7_REAJUST Picture PesqPict("SC7","c7_reajust",,mv_par12)
@ li,018 PSAY SM4->M4_DESCR
@ li,054 PSAY STR0018		//"| Total Geral : "

@ li,094 PSAY xMoeda(nTotNF,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda)      Picture tm(nTotNF,14,MsDecimais(MV_PAR12))
@ li,144 - nDifColCC PSAY "|"
li++
@ li,001 PSAY "|"
@ li,002 PSAY Replicate("-",limite)
@ li,144 - nDifColCC PSAY "|"
//��������������������������������������������������������������Ŀ
//� Inicializar campos de Observacoes.                           �
//����������������������������������������������������������������
If Empty(cObs02)
	If Len(cObs01) > 50
		cObs 	:= cObs01
		cObs01:= Substr(cObs,1,50)
		For nX := 2 To 4
			cVar  := "cObs"+StrZero(nX,2)
			&cVar := Substr(cObs,(50*(nX-1))+1,50)
		Next
	EndIf
Else
	cObs01:= Substr(cObs01,1,IIf(Len(cObs01)<50,Len(cObs01),50))
	cObs02:= Substr(cObs02,1,IIf(Len(cObs02)<50,Len(cObs01),50))
	cObs03:= Substr(cObs03,1,IIf(Len(cObs03)<50,Len(cObs01),50))
	cObs04:= Substr(cObs04,1,IIf(Len(cObs04)<50,Len(cObs01),50))
EndIf

li++
@ li,001 PSAY STR0025	//"| Observacoes"
@ li,054 PSAY STR0026	//"| Comprador    "
@ li,070 PSAY STR0027	//"| Gerencia     "
@ li,085 PSAY STR0028	//"| Diretoria    "
@ li,144 - nDifColCC PSAY "|"

li++
@ li,001 PSAY "|"
@ li,003 PSAY cObs01
@ li,054 PSAY "|"
@ li,070 PSAY "|"
@ li,085 PSAY "|"
@ li,144 - nDifColCC PSAY "|"

li++
@ li,001 PSAY "|"
@ li,003 PSAY cObs02
@ li,054 PSAY "|"
@ li,070 PSAY "|"
@ li,085 PSAY "|"
@ li,144 - nDifColCC PSAY "|"

li++
@ li,001 PSAY "|"
@ li,003 PSAY cObs03
@ li,054 PSAY "|"
@ li,070 PSAY "|"
@ li,085 PSAY "|"
@ li,144 - nDifColCC PSAY "|"

li++
@ li,001 PSAY "|"
@ li,003 PSAY cObs04
@ li,054 PSAY "|"
@ li,070 PSAY "|"
@ li,085 PSAY "|"
@ li,144 - nDifColCC PSAY "|"
li++
@ li,001 PSAY "|"
@ li,002 PSAY Replicate("-",limite)
@ li,144 - nDifColCC PSAY "|"
li++
@ li,001 PSAY STR0029	//"|   NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero da Autorizacao de Entrega."
@ li,144 - nDifColCC PSAY "|"
li++
@ li,001 PSAY "|"
@ li,002 PSAY Replicate("-",limite)
@ li,144 - nDifColCC PSAY "|"

Return .T.
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ImpRodape� Autor � Wagner Xavier         � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime o rodape do formulario e salta para a proxima folha���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ImpRodape(Void)   			         					  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 					                     				      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MatR110                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ImpRodape()
li++
@ li,001 PSAY "|"
@ li,002 PSAY Replicate("-",limite)
@ li,144 - nDifColCC PSAY "|"
li++
@ li,001 PSAY "|"
@ li,070 PSAY STR0030		//"Continua ..."
@ li,144 - nDifColCC PSAY "|"
li++
@ li,001 PSAY "|"
@ li,002 PSAY Replicate("-",limite)
@ li,144 - nDifColCC PSAY "|"
li:=0
Return .T.
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ImpCabec � Autor � Wagner Xavier         � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime o Cabecalho do Pedido de Compra                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ImpCabec(Void)                                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MatR110                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ImpCabec()
Local nOrden, cCGC
LOCAL cMoeda
Local NCW := 0

cMoeda := Iif(mv_par12<10,Str(mv_par12,1),Str(mv_par12,2))

@ 01,001 PSAY "|"
@ 01,002 PSAY Replicate("-",limite)
@ 01,144 - nDifColCC PSAY "|"
@ 02,001 PSAY "|"
@ 02,029 PSAY IIf(nOrdem>1,(STR0033)," ")		//" - continuacao"

If mv_par08 == 1 
	@ 02,045 PSAY (STR0031)+" = "+GetMV("MV_MOEDA"+cMoeda) 	//"| P E D I D O  D E  C O M P R A S"
Else
	@ 02,045 PSAY (STR0032)+" = "+GetMV("MV_MOEDA"+cMoeda)  //"| A U T. D E  E N T R E G A     "
EndIf

If ( Mv_PAR08==2 )
	@ 02,090 PSAY "|"
	@ 02,093 PSAY SC7->C7_NUMSC + "/" + SC7->C7_NUM  //    Picture PesqPict("SC7","c7_num")	
Else
	@ 02,096 PSAY "|"
	@ 02,101 PSAY SC7->C7_NUM      Picture PesqPict("SC7","c7_num")
EndIf

@ 02,107 PSAY "/"+Str(nOrdem,1)
@ 02,112 PSAY IIf(SC7->C7_QTDREEM>0,Str(SC7->C7_QTDREEM+1,2)+STR0034+Str(ncw,2)+STR0035," ")		//"a.Emissao "###"a.VIA"
@ 02,144 - nDifColCC PSAY "|"
@ 03,001 PSAY "|"
@ 03,003 PSAY AllTrim(SM0->M0_NOMECOM)
@ 03,045 PSAY "|"+Replicate("-",97 - nDifColCC)
@ 03,144 - nDifColCC PSAY "|"
@ 04,001 PSAY "|"
@ 04,003 PSAY AllTrim(SM0->M0_ENDENT)
dbSelectArea("SA2")
dbSetOrder(1)
dbSeek(xFilial()+SC7->C7_FORNECE+SC7->C7_LOJA)
@ 04,045 PSAY "|"
If ( cPaisLoc$"ARG|POR|EUA" )
	@ 04,047 PSAY Substr(SA2->A2_NOME,1,35)+"-"+SA2->A2_COD+"-"+SA2->A2_LOJA	
Else
	@ 04,047 PSAY Substr(SA2->A2_NOME,1,35)+"-"+SA2->A2_COD+"-"+SA2->A2_LOJA+(STR0036)+" " + SA2->A2_INSCR		//" I.E.: "	
EndIf
@ 04,144 - nDifColCC PSAY "|"
@ 05,001 PSAY "|"
@ 05,003 PSAY (STR0009)+Trans(SM0->M0_CEPENT,cCepPict)+" - "+Trim(SM0->M0_CIDENT)+" - "+SM0->M0_ESTENT		//"CEP :"
@ 05,045 PSAY "|"
@ 05,047 PSAY SA2->A2_END    		Picture PesqPict("SA2","A2_END")
@ 05,089 PSAY "-  "+Trim(SA2->A2_BAIRRO)	Picture "@!"
@ 05,144 - nDifColCC PSAY "|"
@ 06,001 PSAY "|"
@ 06,003 PSAY STR0037+SM0->M0_TEL		//"TEL: "
@ 06,023 PSAY STR0038+SM0->M0_FAX		//"FAX: "
@ 06,045 PSAY "|"
@ 06,047 PSAY Trim(SA2->A2_MUN)  Picture "@!"
@ 06,069 PSAY SA2->A2_EST    		Picture PesqPict("SA2","A2_EST")
@ 06,074 PSAY STR0009	//"CEP :"
@ 06,081 PSAY SA2->A2_CEP    		Picture PesqPict("SA2","A2_CEP")

dbSelectArea("SX3")
nOrden = IndexOrd()
dbSetOrder(2)
dbSeek("A2_CGC")
cCGC := Alltrim(X3TITULO())
@ 06,093 PSAY cCGC //"CGC: "
dbSetOrder(nOrden)

dbSelectArea("SA2")
@ 06,103 PSAY SA2->A2_CGC    		Picture PesqPict("SA2","A2_CGC")
@ 06,144 - nDifColCC PSAY "|"
@ 07,001 PSAY "|"
@ 07,002 PSAY (cCGC) + " "+ Transform(SM0->M0_CGC,cCgcPict)		//"CGC: "
If cPaisLoc == "BRA"
	@ 07,029 PSAY (STR0041)+ InscrEst()		//"IE:"
EndIf
@ 07,045 PSAY "|"
@ 07,047 PSAY SC7->C7_CONTATO Picture PesqPict("SC7","C7_CONTATO")
@ 07,069 PSAY STR0042	//"FONE: "
@ 07,075 PSAY "("+Substr(SA2->A2_DDD,1,3)+") "+Substr(SA2->A2_TEL,1,15)
@ 07,100 PSAY (STR0038)	//"FAX: "
@ 07,106 PSAY "("+Substr(SA2->A2_DDD,1,3)+") "+SA2->A2_FAX Picture PesqPict("SA2","A2_FAX")
@ 07,144 - nDifColCC PSAY "|"
@ 08,001 PSAY "|"
@ 08,002 PSAY Replicate("-",limite)
@ 08,144 - nDifColCC PSAY "|"

If mv_par08 == 1
	@ 09,001 PSAY "|"
	@ 09,002 PSAY STR0043	//"Itm|"
	@ 09,009 PSAY STR0044	//"Codigo      "
	@ 09,022 PSAY STR0045	//"|Descricao do Material"
	@ 09,051 PSAY STR0046	//"|UM|  Quant."
	If cPaisLoc <> "BRA"
		@ 09,067 PSAY IIF(nDifColcc == 0,STR0056,STR0057)	//"|Valor Unitario|      Valor Total   |Entrega   |  C.C.   | S.C. |"
	Else
		@ 09,067 PSAY IIF(nDifColcc == 0,STR0047,STR0055)	//"|Valor Unitario|IPI% |  Valor Total   | Entrega  |  C.C.   | S.C. |"
	EndIf
	@ 10,001 PSAY "|"
	@ 10,002 PSAY Replicate("-",limite)
	@ 10,144 - nDifColCC PSAY "|"
Else
	@ 09,001 PSAY "|"
	@ 09,002 PSAY STR0043	//"Itm|"
	@ 09,009 PSAY STR0044	//"Codigo      "
	@ 09,022 PSAY STR0045	//"|Descricao do Material"
	@ 09,051 PSAY STR0046	//"|UM|  Quant."
	@ 09,067 PSAY STR0048	//"|Valor Unitario|  Valor Total   |Entrega | Numero da OP  "
	@ 09,144 - nDifColCC PSAY "|"
	@ 10,001 PSAY "|"
	@ 10,002 PSAY Replicate("-",limite)
	@ 10,144 - nDifColCC PSAY "|"
EndIf
dbSelectArea("SC7")
li := 10
Return .T.
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �R110Center� Autor � Jose Lucas            � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Centralizar o Nome do Liberador do Pedido.                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ExpC1 := R110CenteR(ExpC2)                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 := Nome do Liberador                                 ���
���Parametros� ExpC2 := Nome do Liberador Centralizado                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MatR110                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function R110Center(cLiberador)
Return( Space((30-Len(AllTrim(cLiberador)))/2)+AllTrim(cLiberador) )
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AjustaSX1 �Autor  �Alexandre Lemes     � Data � 17/12/2002  ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MATR110                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function AjustaSX1()
 
U_FTTVSX001(cPerg,"13","Endereco de Entrega ?         ","Local de Entrega              ","Delivery Address              ",;
       "mv_chd","C",40,0,0,"G","","","","","mv_par13","","","","","","","","","","","","","","","","",;
       {"Forneca o endereco ou sera impresso o  ","endereco que consta no arquivo SM0.   "},;
       {"                                       ","                                      "},;
       {"                                       ","                                      "})

Return    


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �R110FIniPC� Autor � Edson Maricate        � Data �20/05/2000���
�������������������������������������������������������������������������Ĵ��
���Descricao � Inicializa as funcoes Fiscais com o Pedido de Compras      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � R110FIniPC(ExpC1,ExpC2)                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 := Numero do Pedido                                  ���
���          � ExpC2 := Item do Pedido                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR110,MATR120,Fluxo de Caixa                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
		While !EOF() .AND. (SX3->X3_ARQUIVO == 'SC7')
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


