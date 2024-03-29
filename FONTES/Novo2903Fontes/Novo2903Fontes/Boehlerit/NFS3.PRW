#INCLUDE "MATR485.CH"
//#INCLUDE "FIVEWIN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MATR485  � Autor �Rodrigo de A. Sartorio � Data � 20/01/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de NF's De / Em Terceiros                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAEST                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Rodrigo     �23/06/98�XXXXXX�Acerto no tamanho do documento para 12    ���
���            �        �      �posicoes                                  ���
���Cesar       �30/03/99�XXXXXX�Manutencao na SetPrint()                  ���
���Patricia Sal�20/12/99�XXXXXX�Conversao dos Campos Cliente/Fornec. p/ 20���
���            �        �      �posicoes.                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function NFS3
//�����������������������������������������d���������������������Ŀ
//� Variaveis obrigatorias dos programas de relatorio            �
//����������������������������������������������������������������
LOCAL Tamanho  := "M"
LOCAL titulo   := STR0001	//"Relatorio de NF's De / Em Terceiros"
LOCAL cDesc1   := STR0002	//"Emite a relacao de todas as NF's envolvidas no processo de  controle"
LOCAL cDesc2   := STR0003	//"de Poder de Terceiros"
LOCAL cDesc3   := ""
LOCAL cString  := "SB6"
LOCAL aOrd     := {OemToAnsi(STR0004),OemToAnsi(STR0005),OemToAnsi(STR0006)}		//" Nota Fiscal "###" Cliente/Fornecedor "###" Produto "
LOCAL wnrel    := "NFS3"

//��������������������������������������������������������������Ŀ
//� Variaveis tipo Private padrao de todos os relatorios         �
//����������������������������������������������������������������
PRIVATE aReturn:= {OemToAnsi(STR0007), 1,OemToAnsi(STR0008), 2, 2, 1, "",1 }		//"Zebrado"###"Administracao"
PRIVATE nLastKey:= 0
//cPerg := "NFS301"
cPerg    := PadR( 'NFS301' , Len( SX1->X1_GRUPO ) )

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01     // Lista Notas: Fornecedores / Clientes / Ambos �
//� mv_par02     // De  Nota                                     �
//� mv_par03     // Ate Nota                                     �
//� mv_par04     // De  Serie                                    �
//� mv_par05     // Ate Serie                                    �
//� mv_par06     // De  Data                                     �
//� mv_par07     // Ate Data                                     �
//� mv_par08     // De  Produto                                  �
//� mv_par09     // Ate Produto                                  �
//� mv_par10     // De  Fornecedor/Cliente                       �
//� mv_par11     // Ate Fornecedor/Cliente                       �
//� mv_par12     // Tipo : De Terceiros/Em Terceiros /Ambos      �
//����������������������������������������������������������������
pergunte(cPerg,.F.)

//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT                        �
//����������������������������������������������������������������

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)

If nLastKey = 27
	Set Filter to
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Set Filter to
	Return
Endif

RptStatus({|lEnd| C485Imp(aOrd,@lEnd,wnRel,titulo,Tamanho)},titulo)

Return NIL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � C485IMP  � Autor � Rodrigo de A. Sartorio� Data � 20/01/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR485  			                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function C485Imp(aOrd,lEnd,WnRel,titulo,Tamanho)
//��������������������������������������������������������������Ŀ
//� Variaveis locais exclusivas deste programa                   �
//����������������������������������������������������������������

LOCAL nTipo    := 0
LOCAL cRodaTxt := STR0009		//"REGISTRO(S)"
LOCAL nCntImpr := 0

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas na totalizacao do relatorio             �
//����������������������������������������������������������������
LOCAL nTotal:=0,nTotQuant:=0
LOCAL cQuebra,cCampo,cMens
LOCAL cIndex

//��������������������������������������������������������������Ŀ
//� Condicao de Filtragem do SB6                                 �
//����������������������������������������������������������������
LOCAL cTipo:= IIF(mv_par01==1,"F",IIF(mv_par01==2,"C","CF"))
LOCAL cCond:= 'B6_FILIAL=="'+xFilial("SB6")+'".And.B6_TPCF $ "'+cTipo+'".And.'
	  cCond+= 'B6_DOC>="'+mv_par02+'".And.B6_DOC<="'+mv_par03+'".And.'
	  cCond+= 'B6_SERIE>="'+mv_par04+'".And.B6_SERIE<="'+mv_par05+'".And.'
	  cCond+= 'DTOS(B6_EMISSAO)>="'+DTOS(mv_par06)+'".And.DTOS(B6_EMISSAO)<="'+DTOS(mv_par07)+'"'

//��������������������������������������������������������������Ŀ
//� Indice Condicional de acordo com a ordem selecionada.        �
//����������������������������������������������������������������
If aReturn[8] = 1
	cIndex:="B6_FILIAL+B6_DOC+B6_SERIE+B6_TIPO+B6_CLIFOR+B6_TPCF"
	cCampo:="B6_FILIAL+B6_DOC+B6_SERIE+B6_TIPO"
	cMens :=STR0010		//"da Nota Fiscal:"
ElseIf aReturn[8] = 2
	cIndex:="B6_FILIAL+B6_CLIFOR+B6_TPCF+B6_DOC+B6_SERIE"
	cCampo:="B6_FILIAL+B6_CLIFOR+B6_TPCF"
	cMens :=STR0011		//"do Cliente/Fornecedor:"
ElseIf aReturn[8] = 3
	cIndex:="B6_FILIAL+B6_PRODUTO+B6_DOC+B6_SERIE"
	cCampo:="B6_FILIAL+B6_PRODUTO"
	cMens :=STR0012		//"do Produto:"
EndIf

//����������������������������������������������������������Ŀ
//� Pega o nome do arquivo de indice de trabalho             �
//������������������������������������������������������������
cNomArq := 'B6_CLIFOR'

//����������������������������������������������������������Ŀ
//� Cria o indice de trabalho                                �
//������������������������������������������������������������
dbSelectArea("SB6")
IndRegua("SB6",cNomArq,cIndex,,cCond,STR0013)		//"Selecionando Registros..."
dbGoTop()

//��������������������������������������������������������������Ŀ
//� Inicializa variaveis para controlar cursor de progressao     �
//����������������������������������������������������������������
SetRegua(LastRec())

//������������������������������������������������������������Ŀ
//� Adiciona a ordem escolhida ao titulo do relatorio          �
//��������������������������������������������������������������
titulo+=" "+aOrd[aReturn[8]]

//�������������������������������������������������������������������Ŀ
//� Inicializa os codigos de caracter Comprimido/Normal da impressora �
//���������������������������������������������������������������������
nTipo  := IIF(aReturn[4]==1,15,18)

//��������������������������������������������������������������Ŀ
//� Contadores de linha e pagina                                 �
//����������������������������������������������������������������
PRIVATE li := 80 ,m_pag := 1

//����������������������������������������������������������Ŀ
//� Cria o cabecalho.                                        �
//������������������������������������������������������������
cabec1 := STR0014	//"NOTA        SERIE CLIENTE/    PRODUTO          QUANTIDADE                PRECO             VALOR      DATA     TIPO TES TIPO"
cabec2 := STR0015	//"FISCAL            FORNECEDOR                                          UNITARIO                      EMISSAO   DE/EM      NF" 
					// XXXXXXXXXXXX XXX  XXXXXX - X  XXXXXXXXXXXXXXX  XXXXXXXXXXXXXX  XXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXX  XXXXXXXXXX   X   XXX  X
					// 0         1         2         3         4         5         6         7         8         9        10        11        12   
					// 0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123

Do While !Eof()
	nTotal:=0
	nTotQuant:=0
	If B6_PRODUTO < mv_par08 .Or. B6_PRODUTO > mv_par09 .Or.;
		B6_CLIFOR < mv_par10 .Or. B6_CLIFOR > mv_par11
		IncRegua()
		dbSkip()
		Loop
	EndIf
	If mv_par12 == 1 .And. B6_TIPO != "D"
		dbSkip();IncRegua()
		Loop
	ElseIf mv_par12 == 2 .And. B6_TIPO != "E"
		dbSkip();IncRegua()
		Loop
	EndIf
	cQuebra:=&(cCampo)
	Do While !Eof() .And. &(cCampo) == cQuebra
		IncRegua()
		If B6_PRODUTO < mv_par08 .Or. B6_PRODUTO > mv_par09 .Or.;
			B6_CLIFOR < mv_par10 .Or. B6_CLIFOR > mv_par11
			dbSkip()
			Loop
		EndIf
		If mv_par12 == 1 .And. B6_TIPO != "D"
			dbSkip();IncRegua()
			Loop
		ElseIf mv_par12 == 2 .And. B6_TIPO != "E"
			dbSkip();IncRegua()
			Loop
		EndIf
		If li > 58
			cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
		EndIf
		@ li,000 PSay B6_DOC 			Picture PesqPict("SB6","B6_DOC",11)
		@ li,013 PSay B6_SERIE 			Picture PesqPict("SB6","B6_SERIE",3)
		@ li,018 PSay B6_CLIFOR			Picture PesqPict("SB6","B6_CLIFOR",6)
		@ li,024 PSay "- "+B6_TPCF
		@ li,030 PSay B6_PRODUTO		Picture PesqPict("SB6","B6_PRODUTO",15)
		@ li,046 PSay B6_QUANT			Picture PesqPictQt("B6_QUANT",14)
		@ li,062 PSay B6_PRUNIT			Picture PesqPict("SB6","B6_PRUNIT",16)
		@ li,080 PSay Transform(B6_QUANT * B6_PRUNIT,'@E 99,999,999,999.99')
		@ li,099 PSay B6_EMISSAO
		@ li,112 PSay B6_TIPO			Picture PesqPict("SB6","B6_TIPO",1)
		@ li,117 PSay B6_TES			Picture PesqPict("SB6","B6_TES",3)
		@ li,124 PSay B6_PODER3
		If B6_TES < "500"
			nTotal+= B6_QUANT*B6_PRUNIT
		Else
			nTotal-= B6_QUANT*B6_PRUNIT
		EndIf	
		If aReturn[8] == 3
			If B6_TES < "500"
				nTotQuant+=B6_QUANT
			Else
				nTotQuant-=B6_QUANT
			EndIf	
		EndIf
		li++
		dbSkip()
	EndDo
	If nTotal > 0 .Or. nTotQuant > 0
		If li > 58
			cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
		EndIf
		@ li,00 PSay STR0016+cMens		//"Total "
		If aReturn[8] = 3
			@ li,46 PSay nTotQuant	Picture PesqPictQt("B6_QUANT",14)
		EndIf
		@ li,80 PSay Transform(nTotal,'@E 99,999,999,999.99')
		li++;li++
	EndIf
EndDo

IF li != 80
	Roda(nCntImpr,cRodaTxt,Tamanho)
EndIF

//��������������������������������������������������������������Ŀ
//� Devolve as ordens originais do arquivo                       �
//����������������������������������������������������������������
RetIndex("SB6")
Set Filter to

//��������������������������������������������������������������Ŀ
//� Apaga indice de trabalho                                     �
//����������������������������������������������������������������
cNomArq += OrdBagExt()
Delete File &(cNomArq)

If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return
