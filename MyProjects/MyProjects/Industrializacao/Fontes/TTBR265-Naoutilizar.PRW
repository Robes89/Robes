#INCLUDE "MATR265.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MATR265  � Autor � Felipe Nunes Toledo   � Data � 17/07/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Pick-List Enderecamento                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
User Function TTBR265()
Local oReport

If TRepInUse()
	//������������������������������������������������������������������������Ŀ
	//�Interface de impressao                                                  �
	//��������������������������������������������������������������������������
	oReport:= ReportDef()
	oReport:PrintDialog()
Else
	TTBR265R3()
EndIf

Return NIL

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �Felipe Nunes Toledo    � Data �17/07/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       �MATR265                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local oReport
Local oSection1, oSection2, oSection3, oSection4, oSection5, oSection6
Local cTitle    := OemToAnsi(STR0006) //"Pick-List Enderecamento"
Local cQryRel   := GetNextAlias()
//Private cPerg   :="MTR265"
Private cPerg   :="TTB265"

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������
oReport:= TReport():New("TTBR265",cTitle,cPerg, {|oReport| ReportPrint(oReport,cQryRel)},OemToAnsi(STR0001)+" "+OemToAnsi(STR0002)+" "+OemToAnsi(STR0003)) //##"Este relatorio tem o objetivo de facilitar a retirada de materiais"##"apos o Faturamento de uma NF ou a Criacao de uma OP caso consumam"##"materiais que utilizam o controle de Localizacao Fisica"
oReport:SetLandscape() //Define a orientacao de pagina do relatorio como paisagem.

// tratamento provisorio, pois as perguntas serao disponibilizadas somente na release 12.1.17 Agosto/2017.
MV_PAR14 := Space(SerieNfId("SD2",6,"D2_SERIE"))
MV_PAR15 := Replicate("Z",SerieNfId("SD2",6,"D2_SERIE"))

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas (MTR265)                  �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01      Pick List   1 - NF  2 - OP                     �
//� mv_par02      De  Nota Fiscal Venda                          �
//� mv_par03      Ate Nota Fiscal Venda                          �
//� mv_par04      De  Data de Entrega                            �
//� mv_par05      Ate Data de Entrega                            �
//� mv_par06      De  Cliente                                    �
//� mv_par07      Ate Cliente                                    �
//� mv_par08      De  Ordem de Producao                          �
//� mv_par09      Ate Ordem de Producao                          �
//� mv_par10      Qtd p/ impressao 1 - Original 2 - Saldo        �
//� mv_par11      Considera OPs 1- Firmes 2- Previstas 3- Ambas  �
//� mv_par12      Moeda                                          �
//� mv_par13      Outras moedas                                  �
//� mv_par14      Serie De                                       �
//� mv_par15      Serie Ate                                      �
//� mv_par16      Produto De                                     �
//� mv_par17      Produto Ate                                    �
//����������������������������������������������������������������
Pergunte(oReport:GetParam(),.F.)

//������������������������������������������������������������������������Ŀ
//�Criacao das secoes utilizadas pelo relatorio                            �
//�                                                                        �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se��o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//��������������������������������������������������������������������������
//�������������������������������������������������������������Ŀ
//� oSection2 (Ordem de Producao)                               �
//���������������������������������������������������������������
oSection2 := TRSection():New(oReport,STR0034,{"SD4","SC2"},/*Ordem*/) //"Ordens de Produ��o"
oSection2:SetLineStyle()

//TRCell():New(oSection2,'D4_OP'     ,'SD4',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,'C2_PRODUTO','SC2',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,'B1_DESC'   ,'SB1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,'C2_DATPRI' ,'SC2',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,'C2_DATPRF' ,'SC2',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,'C2_QUANT'  ,'SC2',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,'C2_OBS'    ,'SC2',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

//oSection2:Cell('D4_OP'     ):SetCellBreak()
oSection2:Cell('C2_PRODUTO'):SetCellBreak()
oSection2:Cell('B1_DESC'   ):SetCellBreak()
oSection2:Cell('C2_DATPRI' ):SetCellBreak()
oSection2:Cell('C2_DATPRF' ):SetCellBreak()
oSection2:Cell('C2_QUANT'  ):SetCellBreak()
oSection2:Cell('C2_OBS'    ):SetCellBreak()


//�������������������������������������������������������������Ŀ
//� oSection5 (Item Ordem de Producao)                          �
//���������������������������������������������������������������

oSection5 := TRSection():New(oSection2,STR0036,{"SD4","SB1","SDC"},/*Ordem*/) //"Empenhos"
oSection5:SetHeaderPage()

TRCell():New(oSection5,'D4_COD'    ,'SD4',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection5,'B1_DESC'   ,'SB1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection5,'B1_UM'     ,'SB1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection5,'D4_LOTECTL','SD4',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection5,'D4_NUMLOTE','SD4',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection5,'DC_LOCALIZ','SDC',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection5,'DC_NUMSERI','SDC',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection5,'D4_QUANT'  ,'SD4',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection5,'D4_DTVALID','SD4',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection5,'D4_POTENCI','SD4',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

//�������������������������������������������������������������Ŀ
//� oSection6 (Item Remito)                                     �
//���������������������������������������������������������������
oSection6 := TRSection():New(oSection3,STR0037,{"SD2","SB1","SDB"},/*Ordem*/) //"Movimentos por Endere�o"
oSection6:SetHeaderPage()

TRCell():New(oSection6,'D2_COD'    ,'SD2',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection6,'B1_DESC'   ,'SB1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection6,'B1_UM'     ,'SB1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection6,'D2_LOTECTL','SD2',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection6,'D2_NUMLOTE','SD2',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection6,'DB_LOCALIZ','SDB',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection6,'DB_NUMSERI','SDB',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection6,'DB_QUANT'  ,'SDB',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint � Autor �Felipe Nunes Toledo  � Data �17/07/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportPrint devera ser criada para todos  ���
���          �os relatorios que poderao ser agendados pelo usuario.       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relatorio                           ���
�������������������������������������������������������������������������Ĵ��
���Uso       �MATR265                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportPrint(oReport, cQryRel)
Local oSection1	:= oReport:Section(1)
Local oSection2	:= oReport:Section(2)
Local oSection3	:= oReport:Section(3)
Local oSection4	:= oReport:Section(1):Section(1)
Local oSection5	:= oReport:Section(2):Section(1)
Local oSection6	:= oReport:Section(3):Section(1)
Local lExistBlock := ExistBlock("MR265MAIL")
Local cIndex
Local cChaveDB	:= cChaveC9 := cChave := cChave2 := cDocAnt := cCompara := cTitulo:= ""
Local nValorNf	:= 0
Local aTam		:= TamSX3("D2_TOTAL")
Local aAreaSB1	:= SB1->(GetArea())
Local bBlock
Local cWhere01
Local nSldSD4	:= 0
Local cSelectD2	:= ""
Local cSerieDe	:= ""
Local cSerieAte	:= ""

//������������������������������������������������������������������������Ŀ
//�Filtragem do relatorio                                                  �
//��������������������������������������������������������������������������
If cPaisLoc == "BRA"
	cSerieDe	:= MV_PAR14
	cSerieAte	:= MV_PAR15
Else
	cSerieDe	:= "   "
	cSerieAte	:= "ZZZ"
EndIf
//������������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao SQL                            �
//��������������������������������������������������������������������������
MakeSqlExpr(oReport:GetParam())

//��������������������������������������������������������������Ŀ
//� Condicao Where para filtrar OP's                             �
//����������������������������������������������������������������

cWhere01 := "%"
cWhere01  += "SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN || SC2.C2_ITEMGRD = SD4.D4_OP
cWhere01 += "%"

cSelectD2:= "%"
cSelectD2+= Iif(SerieNfId("SD2",3,"D2_SERIE")<>"D2_SERIE","D2_SDOC,","")
cSelectD2+= "%"

//������������������������������������������������������������������������Ŀ
//�Query do relatorio                                                      �
//��������������������������������������������������������������������������  
	
BEGIN REPORT QUERY oSection2
	BeginSql Alias cQryRel

	SELECT SD4.D4_FILIAL, SD4.D4_COD, SD4.D4_OP, SD4.D4_LOTECTL, SD4.D4_NUMLOTE, SD4.D4_DTVALID, 
	       SD4.D4_POTENCI, SD4.D4_LOCAL, SD4.D4_TRT, SD4.D4_QUANT, SD4.D4_QTDEORI,
	       SC2.C2_FILIAL, SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_ITEMGRD, SC2.C2_DATPRI,
	       SC2.C2_DATPRF, SC2.C2_PRODUTO, SC2.C2_QUANT, SC2.C2_OBS, SC2.C2_TPOP,
	       SB1.B1_FILIAL, SB1.B1_COD, SB1.B1_DESC, SB1.B1_UM
	FROM   %table:SD4% SD4
	INNER JOIN %table:SC2% SC2 ON
	       SC2.C2_FILIAL = %xFilial:SC2% AND
	       SC2.C2_DATPRF BETWEEN %Exp:mv_par04% AND %Exp:mv_par05% AND
	       SC2.%NotDel%
	LEFT JOIN %table:SB1% SB1 ON
	       SB1.B1_FILIAL = %xFilial:SB1% AND
	       SB1.B1_COD = SD4.D4_COD AND
	       SB1.%NotDel%
	WHERE  SD4.D4_FILIAL = %xFilial:SD4% AND
	       SD4.D4_OP BETWEEN %Exp:mv_par08% AND %Exp:mv_par09% AND
	       %Exp:cWhere01% AND
	       SD4.%NotDel%
	ORDER BY
	     SC2.C2_FILIAL, SD4.D4_COD, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_ITEMGRD
	EndSql
END REPORT QUERY oSection2
	
oSection5:SetParentQuery() //Define a utilizacao da Query para a secao Filha
  	    

//������������������������������������������������������������������������Ŀ
//�Inicio da impressao do fluxo do relatorio                               �
//��������������������������������������������������������������������������
dbSelectArea(cQryRel)

//�������������������������������Ŀ
//�Definindo o titulo do Relatorio�
//���������������������������������
oReport:SetTitle(oReport:Title()+"    "+STR0009) //"Pick-List Enderecamento"##"(Ordem de Producao)"

//���������������������������������������������Ŀ
//�Desabilitando secoes que nao seram utilizadas�
//�����������������������������������������������

oSection1:Disable()
oSection3:Disable()
oSection4:Disable()
oSection6:Disable()

oReport:SetMeter( SD4->(LastRec()) )
oSection2:Init()
oSection5:Init()

While !oReport:Cancel() .And. !(cQryRel)->(Eof())
	If !MtrAvalOp(mv_par11,"SC2",cQryRel)
		oReport:IncMeter()
		(cQryRel)->(dbSkip())
		Loop
	EndIf
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1") + (cQryRel)->C2_PRODUTO))
	oSection2:Cell('B1_DESC'):SetValue( SB1->B1_DESC )
	oSection2:PrintLine() //-- Impressao da secao 2
	oReport:ThinLine()
	cOpAnt := (cQryRel)->D4_COD
	While !(cQryRel)->(Eof()) .And. (cQryRel)->(D4_FILIAL+D4_COD) == xFilial("SD4")+cOpAnt
		If Localiza((cQryRel)->D4_COD)
			dbSelectArea("SDC")
			dbSetOrder(2)
			cChave := ''
			If Rastro((cQryRel)->D4_COD)
				cChave:=xFilial("SDC")+(cQryRel)->(D4_COD+D4_LOCAL+D4_OP+D4_TRT+D4_LOTECTL+D4_NUMLOTE)
				cCompara:="DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_OP+DC_TRT+DC_LOTECTL+DC_NUMLOTE"
			Else
				cChave:=xFilial("SDC")+(cQryRel)->(D4_COD+D4_LOCAL+D4_OP+D4_TRT)
				cCompara:="DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_OP+DC_TRT"
			EndIf
			
			//��������������������������������������������������������������Ŀ
			//� Varre composicao do empenho                                  �
			//����������������������������������������������������������������
			
			If !Empty(cChave) .AND. dbSeek(cChave)
				nSldSD4 := If(mv_par10==1,(cQryRel)->D4_QTDEORI,(cQryRel)->D4_QUANT)
				Do While SDC->(!Eof()) .And. cChave == &(cCompara)
		
					oSection5:Cell('DC_LOCALIZ'):Setvalue( SDC->DC_LOCALIZ )
					oSection5:Cell('DC_NUMSERI'):Setvalue( SDC->DC_NUMSERI )
					//��������������������������������������������������������������Ŀ
					//�Lista quantidade de acordo com o parametro selecionado        �
					//����������������������������������������������������������������
					If mv_par10 == 1
						oSection5:Cell('D4_QUANT'  ):Setvalue( SDC->DC_QTDORIG )
					Else
						oSection5:Cell('D4_QUANT'  ):Setvalue( SDC->DC_QUANT )
					EndIf
					oReport:IncMeter()
					oSection5:PrintLine() //-- Impressao da secao 4
					nSldSD4 -= If(mv_par10==1,SDC->DC_QTDORIG,SDC->DC_QUANT)
					SDC->(dbSkip())
				EndDo
			Else
				oSection5:Cell('DC_LOCALIZ'):Setvalue( '' )
				oSection5:Cell('DC_NUMSERI'):Setvalue( '' )
				If mv_par10 == 1
					oSection5:Cell('D4_QUANT'  ):Setvalue( (cQryRel)->D4_QTDEORI )
				Else
					oSection5:Cell('D4_QUANT'  ):Setvalue( (cQryRel)->D4_QUANT )
				EndIf
					oReport:IncMeter()
					oSection5:PrintLine() //-- Impressao da secao 4
				EndIf
			Else
				oSection5:Cell('DC_LOCALIZ'):Setvalue( '' )
				oSection5:Cell('DC_NUMSERI'):Setvalue( '' )
				If mv_par10 == 1
					oSection5:Cell('D4_QUANT'  ):Setvalue( (cQryRel)->D4_QTDEORI )
				Else
					oSection5:Cell('D4_QUANT'  ):Setvalue( (cQryRel)->D4_QUANT )
				EndIf
				oReport:IncMeter()
				oSection5:PrintLine() //-- Impressao da secao 4
			EndIf
			If nSldSD4 > 0 //Imprime linha para diferenca nao empenhada no SDC
				oSection5:Cell('DC_LOCALIZ'):Setvalue( '' )
				oSection5:Cell('DC_NUMSERI'):Setvalue( '' )
				oSection5:Cell('D4_QUANT'  ):Setvalue( nSldSD4 )
				oReport:IncMeter()
				oSection5:PrintLine() //-- Impressao da secao 4
				nSldSD4 := 0 //prepara para novo item
			EndIf
			(cQryRel)->(dbSkip())
		EndDo
		oReport:EndPage() //-- Salta Pagina
EndDo

oSection2:Finish()
oSection5:Finish()
(cQryRel)->(DbCloseArea()) 

RestArea(aAreaSB1)

Return Nil
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MATR265  � Autor � Jesus Pedro           � Data � 13.11.97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Pick-List de Vendas/Ordem de Producao (Localizacao Fisica  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � MATR265(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Rodrigo Sart�14/04/98�XXXXXX� Alterada rotina e acrescentada impressao ���
���            �        �      � para Ordem de Producao.                  ���
���Rodrigo Sart�23/04/98�XXXXXX� Incluida pergunta mv_par10               ���
���Rodrigo Sart�07/02/99�META  � Filtragem por Tipo de OP.                ���
���Wagner      �30/03/99�20633A� Acerto Indregua com SQL                  ���
���CesarValadao�30/03/99�XXXXXX� Manutencao na SetPrint()                 ���
���CesarValadao�08/07/99�22222A� Acerto para Nao Truncar Campos.          ���
���Aline C.Vale�15/07/99�22899A� Inclusao da loja na pesquisa cliente/forn���
���Rodrigo Sart�06/08/99�xxxxxx� Acerto na impressao qdo lista NF         ���
���Patricia Sal�20/12/99�xxxxxx� Exclusao dos controles p/ amb. DOS.      ���
���Marcello    �19/08/00�oooooo�Impressao da relacao em outras moedas     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user Function MATR265R3()
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
LOCAL tamanho:="G"
LOCAL cDesc1 :=STR0001	//"Este relatorio tem o objetivo de facilitar a retirada de materiais"
LOCAL cDesc2 :=STR0002	//"apos o Faturamento de uma NF ou a Criacao de uma OP caso consumam"
LOCAL cDesc3 :=STR0003	//"materiais que utilizam o controle de Localizacao Fisica"
LOCAL cString:="SD2"
PRIVATE cbCont,cabec1,cabec2,cbtxt
PRIVATE cPerg  :="MTR265"
PRIVATE aReturn := {STR0004,1,STR0005, 2, 2, 1, "",0 }	//"Zebrado"###"Administracao"
PRIVATE nomeprog:="MATR265",nLastKey := 0
PRIVATE li:=80, limite:=132, lRodape:=.F.
PRIVATE wnrel  := "MATR265"
PRIVATE titulo :=STR0006	//"Pick-List Localizacao Fisica"
PRIVATE cSerIni := ""
PRIVATE cSerFin := ""


//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//����������������������������������������������������������������
cbtxt   := SPACE(10)
cbcont  := 0
Li      := 80
m_pag   := 1

cabec1  := STR0007	//"PRODUTO         DESCRICAO                      UM LOTE       SUB-LOTE LOCALIZACAO     NUMERO DE SERIE      QUANTIDADE     DT VALIDADE   POTENCIA"
cabec2  := ""
//                     123456789012345 123456789012345678901234567890 12 1234567890 123456   123456789012345 12345678901234567890 12345678901234 1234567890    123456789012
//                               1         2         3         4         5         6         7         8         9        10        11        12        13        14
//                     012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789

//�������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                          �
//���������������������������������������������������������������
pergunte( cPerg,.F.)
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01      Pick List   1 - NF  2 - OP					 �
//� mv_par02	  De  Nota Fiscal Venda							 �
//� mv_par03	  Ate Nota Fiscal Venda							 �
//� mv_par04	  De  Data de Entrega							 �
//� mv_par05	  Ate Data de Entrega							 �
//� mv_par06	  De  Cliente									 �
//� mv_par07	  Ate Cliente									 �
//� mv_par08	  De  Ordem de Producao							 �
//� mv_par09	  Ate Ordem de Producao							 �
//� mv_par10	  Qtd p/ impressao 1 - Original 2 - Saldo		 �
//� mv_par11      Considera OPs 1- Firmes 2- Previstas 3- Ambas	 �
//� mv_par12	  Moeda											 �
//� mv_par13      Outras moedas									 �
//� mv_par14      Serie De                                       �
//� mv_par15      Serie Ate                                      �
//����������������������������������������������������������������

wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,Tamanho)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

//�������������������������������������������������������������Ŀ
//� Lista Pick-List para Nota Fiscal de Venda                   �
//���������������������������������������������������������������
cSerIni := MV_PAR14
cSerFin := MV_PAR15
If mv_par01 == 1
	titulo  += STR0008	//" (Nota Fiscal de Venda)"
	RptStatus({|lEnd| C265ImpNF(@lEnd,tamanho,titulo,wnRel,cString)},titulo)
ElseIf mv_par01 == 2
	//�������������������������������������������������������������Ŀ
	//� Lista Pick-List para Ordem de Producao                      �
	//���������������������������������������������������������������
	titulo  += STR0009	//" (Ordem de Producao)"
	RptStatus({|lEnd| C265ImpOP(@lEnd,tamanho,titulo,wnRel,cString)},titulo)
ElseIf cPaisLoc # "BRA"
	//�������������������������������������������������������������Ŀ
	//� Lista Pick-List para Remito                 �
	//���������������������������������������������������������������

    If cPaisloc $ "CHI"
		titulo  += " (" + STR0030 + ") "	//" (Remitos)"
    Elseif cPaisloc $ "COL|MEX|PAR"
   		titulo  += " (" + STR0031 + ") "	//" (Remitos)"
    Elseif cPaisloc $ "EUA|POR"
 		titulo  += " (" + STR0032 + ") "	//" (Remitos)"
    Elseif cPaisloc $ "ARG|URU"
		titulo  += " (" + STR0029 + ") "	//" (Remitos)"
    Endif
	RptStatus({|lEnd| C265ImpRem(@lEnd,tamanho,titulo,wnRel,cString)},titulo)
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � C265ImpNF� Autor � Jesus Pedro           � Data � 13.11.97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio para Pick-List da Nota Fiscal de Venda���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR265	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function C265ImpNF( lEnd, tamanho, titulo, wnRel )
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
LOCAL bBlock, cChaveAnt:="",cChaveDB:=""
LOCAL lExistBlock:=ExistBlock("MR265MAIL")
PRIVATE cNfAnt    := Space(TamSX3("D2_DOC")[1])
PRIVATE cSerieAnt := Space(TamSX3("D2_SERIE")[1])
PRIVATE nValorNf  := 0

//��������������������������������������������������������������Ŀ
//� Coloca areas nas Ordens Corretas                             �
//����������������������������������������������������������������
dbSelectArea("SB1")
dbSetOrder(1)

dbSelectArea("SD2")
dbSetOrder(1)

//��������������������������������������������������������������Ŀ
//� Monta filtro e indice da IndRegua                            �
//����������������������������������������������������������������
cIndex :="D2_FILIAL+D2_DOC+D2_SERIE+D2_ITEM+D2_COD+D2_ITEMPV+D2_LOTECTL+D2_NUMLOTE"

cExpres:='D2_FILIAL=="'+xFilial()+'".And.'
cExpres+='D2_DOC>="'+mv_par02+'".And.D2_DOC<="'+mv_par03+'".And.'
If cPaisLoc<>"BRA"
	cExpres+=' !('+IsRemito(2,'SD2->D2_TIPODOC')+') .And. '
Endif
cExpres+= SerieNfId("SD2",3,"D2_SERIE") + '>="'+cSerIni+'" .And. '
If !Empty(cSerFin)
	cExpres+= SerieNfId("SD2",3,"D2_SERIE") + '<="'+cSerFin+'" .And. '
Endif
cExpres+='D2_CLIENTE>="'+mv_par06+'".And.D2_CLIENTE<="'+mv_par07+'"'

cSD2ntx := CriaTrab(,.F.)
IndRegua("SD2", cSD2ntx, cIndex,,cExpres,STR0010)	//"Selecionando Registros ..."
nIndex := RetIndex("SD2")
dbSetOrder( nIndex+1 )

//��������������������������������������������������������Ŀ
//� Verifica o numero de registros validos para a SetRegua �
//����������������������������������������������������������
dbGoTop()
SetRegua(LastRec())

cChaveAnt := "????????????????"

SB8->(dbSetOrder(1))

While !Eof()
	//��������������������������������������������������������������Ŀ
	//� Verifica se o usuario interrompeu o relatorio                �
	//����������������������������������������������������������������
	If lAbortPrint
		@Prow()+1,001 PSAY STR0011	//"CANCELADO PELO OPERADOR"
		Exit
	Endif
	
	//��������������������������������������������������������������Ŀ
	//� Verifica os parametros para data de entrega                  �
	//����������������������������������������������������������������
	dbSelectArea("SC6")
	dbSetOrder( 1 )
	If !dbSeek( xFilial( "SC6" ) + SD2->D2_PEDIDO + SD2->D2_ITEMPV + ;
		SD2->D2_COD ) .Or. ( C6_ENTREG < mv_par04 .Or. C6_ENTREG > mv_par05 )
		dbSelectArea("SD2")
		IncRegua()
		dbSkip()
		Loop
	EndIf
	
	dbSelectArea( "SF2" )
	dbSetOrder( 1 )
	dbSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE)	
	
	//��������������������������������������������������������������Ŀ
	//� Verifica Moeda                                               �
	//����������������������������������������������������������������
	if mv_par13==2  //nao imprimir notas com moeda diferente da escolhida
	   if if(F2_MOEDA==0,1,F2_MOEDA)!=mv_par12
	      dbselectarea("SD2") 
  		  IncRegua()
	      dbskip()
	      loop
	   endif
	endif
	
	dbSelectArea( "SB1" )
	dbSeek( xFilial() + SD2->D2_COD )
	
	If SF2->F2_TIPO $ "D�B"
		dbSelectArea( "SA2" )
		dbSetOrder( 1 )
		dbSeek( xFilial() + SD2->D2_CLIENTE + SD2->D2_LOJA )
	Else
		dbSelectArea( "SA1" )
		dbSetOrder( 1 )
		dbSeek( xFilial() + SD2->D2_CLIENTE + SD2->D2_LOJA)
	EndIf
	
	dbSelectArea( "SA4" )
	dbSetOrder( 1 )
	dbSeek( xFilial() + SF2->F2_TRANSP )
	
	dbSelectArea( "SC9" )
	
	nValorNf += xmoeda(SD2->D2_TOTAL,SF2->F2_MOEDA,mv_par12,SF2->F2_EMISSAO,msdecimais(mv_par12)+1,SF2->F2_TXMOEDA)
	
	If cChaveAnt == SD2->D2_FILIAL + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_ITEM +;
		SD2->D2_COD + SD2->D2_ITEMPV + SD2->D2_LOTECTL
		dbSelectArea( "SD2" )
		cChaveAnt := D2_FILIAL + D2_DOC + D2_SERIE + D2_ITEM + D2_COD + D2_ITEMPV + D2_LOTECTL
		dbSkip()
		Loop
	EndIf
	
	//��������������������������������������������������������������Ŀ
	//� Lista o cabecalho da Nota Fiscal                             �
	//����������������������������������������������������������������
	CabecNF(Tamanho)
	
	//��������������������������������������������������������������Ŀ
	//� Lista o detalhe da Nota Fiscal                               �
	//����������������������������������������������������������������
	DetalheNF(Tamanho)
	
	If Localiza( SD2->D2_COD )
		dbSelectArea( "SDB" )
		dbSetOrder( 1 )
		cChaveDB :=xFilial("SDB")+SD2->D2_COD+SD2->D2_LOCAL+SD2->D2_NUMSEQ+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
		If dbSeek( cChaveDB )
			While !Eof() .And. cChaveDB == DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA
				If DB_ESTORNO == "S"
					dbSkip()
					Loop
				EndIf
				@ Li,113 PSAY DB_LOCALIZ Picture PesqPict("SDB","DB_LOCALIZ",15)
				@ Li,122 PSAY DB_NUMSERI Picture PesqPict("SDB","DB_NUMSERI",20)
				@ Li,147 PSAY DB_QUANT Picture PesqPictQt("DB_QUANT",14)
				@ li,162 PSAY SD2->D2_DTVALID Picture PesqPict("SD2","D2_DTVALID",10)
				@ li,176 PSAY SD2->D2_POTENCI Picture PesqPictQt("D2_POTENCI", 14)
				dbSkip()
				Li := Li + 1
				If Li > 55
					roda(cbcont,cbtxt,tamanho)
					CabecNF(Tamanho)
					DetalheNF(Tamanho)
				EndIf
			EndDo
		Else
			dbSelectArea( "SC9" )
			dbSetOrder( 2 )
			cChaveC9 := xFilial( "SC9" ) + SD2->D2_CLIENTE + SD2->D2_LOJA + ;
			SD2->D2_PEDIDO + SD2->D2_ITEMPV
			dbSeek( cChaveC9 )
			While !Eof() .And. cChaveC9 == C9_FILIAL + C9_CLIENTE + C9_LOJA + ;
				C9_PEDIDO + C9_ITEM
				//������������������������������������������Ŀ
				//� Verifica se a liberacao ja foi faturada  �
				//��������������������������������������������
				If Rastro( SD2->D2_COD, "S" )
					bBlock  := { || C9_PRODUTO + C9_NUMLOTE + C9_NFISCAL + ;
					C9_SERIENF <> SD2->D2_COD + SD2->D2_NUMLOTE + SD2->D2_DOC +;
					SD2->D2_SERIE }
				ElseIf Rastro( SC9->C9_PRODUTO, "L" )
					bBlock  := { || C9_PRODUTO + C9_LOTECTL + C9_NFISCAL + ;
					C9_SERIENF <> SD2->D2_COD + SD2->D2_LOTECTL + SD2->D2_DOC +;
					SD2->D2_SERIE  }
				Else
					bBlock  := { || C9_PRODUTO + C9_NFISCAL + C9_SERIENF <> ;
					SD2->D2_COD + SD2->D2_DOC + SD2->D2_SERIE }
				EndIf
				
				If C9_BLEST <> "10" .Or. C9_BLCRED <> "10" .Or. Eval( bBlock )
					dbSkip()
					Loop
				EndIf
				dbSelectArea('SDC')
				dbSetOrder(1)
				If Rastro(SD2->D2_COD, 'S')
					bBlock  := {|| SC9->C9_LOTECTL+SC9->C9_NUMLOTE == DC_LOTECTL+DC_NUMLOTE}
					cChave  := xFilial()+SC9->C9_PRODUTO+SD2->D2_LOCAL+'SC6'+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN
					cChave2 := SC9->C9_LOTECTL+SC9->C9_NUMLOTE
				ElseIf Rastro(SC9->C9_PRODUTO, 'L')
					bBlock  := {|| SC9->C9_LOTECTL == DC_LOTECTL}
					cChave  := xFilial()+SC9->C9_PRODUTO+SD2->D2_LOCAL+'SC6'+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN
					cChave2 := SC9->C9_LOTECTL
				Else
					bBlock  := {|| .T.}
					cChave  := xFilial()+SC9->C9_PRODUTO+SD2->D2_LOCAL+'SC6'+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN
					cChave2 := ''
				EndIf
				//��������������������������������������������������������������Ŀ
				//� Varre composicao do empenho                                  �
				//����������������������������������������������������������������
				If dbSeek(cChave+cChave2, .F.)
					Do While !Eof() .And. cChave==DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ .And. Eval(bBlock)
						@ Li, 070 PSAY DC_LOCALIZ Picture PesqPict('SDC', 'DC_LOCALIZ', 15)
						@ Li, 086 PSAY DC_NUMSERI Picture PesqPict('SDC', 'DC_NUMSERI', 20)
						//��������������������������������������������������������������Ŀ
						//�Lista quantidade de acordo com o parametro selecionado        �
						//����������������������������������������������������������������
						SB8->(dbSeek(xFilial("SB8") + SDC->(DC_PRODUTO+DC_LOCAL+DTOS(SC9->C9_DTVALID)+DC_LOTECTL+DC_NUMLOTE)))
						If mv_par10 == 1
							@ Li, 147 PSAY DC_QTDORIG Picture PesqPictQt('DC_QTDORIG',14)
							@ li,162 PSAY SC9->C9_DTVALID Picture PesqPict("SC9","C9_DTVALID",10)
							@ li,176 PSAY SB8->B8_POTENCI Picture PesqPictQt("B8_POTENCI", 14)
						Else
							@ Li, 147 PSAY DC_QUANT Picture PesqPictQt('DC_QUANT',14)
							@ li,162 PSAY SC9->C9_DTVALID Picture PesqPict("SC9","C9_DTVALID",10)
							@ li,176 PSAY SB8->B8_POTENCI Picture PesqPictQt("B8_POTENCI", 14)
						EndIf
						dbSelectArea('SDC')
						dbSkip()
						Li++
						If Li > 55
							Roda(cbcont,cbtxt,tamanho)
							CabecNF()
							DetalheNF()
						EndIf
					EndDo
				EndIf
				dbSelectArea('SC9')
				dbSkip()
			EndDo
		EndIf
	Else
		@ Li, 147 PSAY SD2->D2_QUANT Picture PesqPictQt("D2_QUANT",14)
	EndIf
	dbSelectArea("SD2")
	//��������������������������������������Ŀ
	//� Valor da N.f.                        �
	//����������������������������������������
	Li++
	cNfAnt := SD2->D2_DOC
	cSerieAnt := SD2->D2_SERIE
	IncRegua()
	dbSelectArea( "SD2" )
	cChaveAnt := D2_FILIAL + D2_DOC + D2_SERIE + D2_ITEM + D2_COD + D2_ITEMPV + D2_LOTECTL
	//��������������������������������������Ŀ
	//� Executa EXECBLOCK p/ envio de e-mail �
	//����������������������������������������
	If lExistBlock
		ExecBlock("MR265MAIL",.F.,.F.)
	EndIf
	dbSkip()
	If SD2->D2_DOC != cNfAnt .Or. SD2->D2_SERIE != cSerieAnt
		Li++
		@ Li, 00 PSAY STR0012 + Transform( nValorNf,PesqPict("SD2","D2_TOTAL",16,SF2->F2_MOEDA))    //"VALOR DA NOTA FISCAL: "
		Li++
		Li++
		@ Li, 00 PSAY STR0013	//"OBSERVACAO: "
		nValorNf := 0
	EndIf
EndDo

If Li != 80
	roda(cbcont,cbtxt,tamanho)
EndIf

dbSelectArea("SD2")
RetIndex("SD2")
Ferase( cSD2ntx + OrdBagExt() )

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CabecNF  � Autor � Jesus Pedro           � Data � 13.11.97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime o cabecalho do relatorio por PV                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR265	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CabecNF(Tamanho)
Local cTxt := ""
If Li > 55 .Or. SD2->D2_DOC != cNfAnt .Or. SD2->D2_SERIE != cSerieAnt
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,18)
	If SF2->F2_TIPO $ "D�B"
		@ Li, 00 PSAY STR0014 + AllTrim(SA2->A2_COD) + "/" + SA2->A2_LOJA + " - " + SA2->A2_NOME	//"CLIENTE/FORN.: "
		Li+=2
		@ Li, 00 PSAY STR0015 + AllTrim(SA2->A2_MUN) + " - " + SA2->A2_EST	//"MUNICIPIO....: "
		Li+=2
	Else
		@ Li, 00 PSAY STR0014 + AllTrim( SA1->A1_COD) + "/" + SA1->A1_LOJA + " - " + SA1->A1_NOME	//"CLIENTE/FORN.: "
		Li+=2
		@ Li, 00 PSAY STR0015 + AllTrim(SA1->A1_MUN) + " - " + SA1->A1_EST	//"MUNICIPIO....: "
		Li+=2
	EndIf
	@ Li, 00 PSAY STR0016 + SD2->D2_DOC	//"NOTA FISCAL..: "    
	Li+=2
	cTxt := Padr(Alltrim(Upper(SerieNfId("SD2",7,"D2_SERIE"))),Len(STR0015)-1,".")
    @ Li,00 PSAY cTxt + ": " + SerieNfId("SD2",2,"D2_SERIE")
	Li+=2
	@ Li, 00 PSAY STR0017 + SD2->D2_PEDIDO	//"PEDIDO.......: "
	Li+=2
	@ Li, 00 PSAY STR0018 + SA4->A4_NOME	//"TRANSPORTE...: "
	Li+=2
	@ Li, 00 PSAY STR0019 + AllTrim( Str( SF2->F2_VOLUME1 ) )	//"VOLUME.......: "
	@ Li, 45 PSAY STR0020 + SF2->F2_ESPECI1	//"ESPECIE....: "
	Li+=2
	@ Li, 00 PSAY STR0021 + Transform( SF2->F2_PLIQUI,PesqPict( "SF2", "F2_PLIQUI" ) )	//"PESO LIQ.....: "
	@ Li, 45 PSAY STR0022 + Transform( SF2->F2_PBRUTO,PesqPict( "SF2", "F2_PBRUTO" ) )	//"PESO BRUTO.: "
	Li+=2
	@ Li,00 PSAY __PrtThinLine()
	Li+=2
Endif
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � DetalheNF� Autor � Jesus Pedro           � Data � 13.11.97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime o detalhe da Nota Fiscal de Venda                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR265	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function DetalheNF(Tamanho)
@ Li,00 PSAY SD2->D2_COD				Picture PesqPict("SD2","D2_COD",30)
@ Li,45 PSAY Left(SB1->B1_DESC,30)	Picture PesqPict("SB1","B1_DESC",30)
@ Li,88 PSAY SB1->B1_UM					Picture PesqPict("SB1","B1_UM",4)
@ Li,91 PSAY SD2->D2_LOTECTL			Picture PesqPict("SD2","D2_LOTECTL",10)
@ Li,103 PSAY SD2->D2_NUMLOTE			Picture PesqPict("SD2","D2_NUMLOTE",6)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � C265ImpOP� Autor �Rodrigo de A. Sartorio � Data � 14.04.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio para Pick-List da Ordem de Producao   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR265	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function C265ImpOP( lEnd, tamanho, titulo, wnRel )
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
LOCAL cChave,cCompara
LOCAL nSldSD4 := 0
PRIVATE cOpAnt := Space(11)

//��������������������������������������������������������������Ŀ
//� Coloca areas nas Ordens Corretas                             �
//����������������������������������������������������������������
dbSelectArea("SB1")
dbSetOrder(1)

dbSelectArea("SD4")
dbSetOrder(2)

dbSelectArea("SDC")
dbSetOrder(2)

dbSelectArea("SC2")
dbSetOrder(1)

//��������������������������������������������������������������Ŀ
//� Monta filtro e indice da IndRegua                            �
//����������������������������������������������������������������
cIndex:=IndexKey()

cExpres:='C2_FILIAL=="'+xFilial()+'".And.'
cExpres+='C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD>="'+mv_par08+'".And.'
cExpres+='C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD<="'+mv_par09+'".And.'
cExpres+='DTOS(C2_DATPRF)>="'+DTOS(mv_par04)+'".And.'
cExpres+='DTOS(C2_DATPRF)<="'+DTOS(mv_par05)+'"'

cSC2ntx := CriaTrab(,.F.)
IndRegua("SC2", cSC2ntx, cIndex,,cExpres,STR0010)	//"Selecionando Registros ..."
nIndex := RetIndex("SC2")
dbSetOrder( nIndex+1 )

//��������������������������������������������������������Ŀ
//� Verifica o numero de registros validos para a SetRegua �
//����������������������������������������������������������
dbGoTop()
SetRegua(LastRec())

cChaveAnt := "????????????????"

While !Eof()
	//��������������������������������������������������������������Ŀ
	//� Verifica se o usuario interrompeu o relatorio                �
	//����������������������������������������������������������������
	
	If lAbortPrint
		@Prow()+1,001 PSAY STR0011	//"CANCELADO PELO OPERADOR"
		Exit
	Endif
	
	If !MtrAvalOp(mv_par11)
		dbSkip()
		Loop
	EndIf
	
	dbSelectArea("SB1")
	dbSeek(xFilial()+SC2->C2_PRODUTO)
	
	//��������������������������������������������������������������Ŀ
	//� Lista o cabecalho da Ordem de Producao                       �
	//����������������������������������������������������������������
	CabecOP(Tamanho)
	
	dbSelectArea("SD4")
	dbSeek(xFilial()+cOPAnt)
	While !Eof() .And. D4_FILIAL+D4_OP == xFilial("SD4")+cOpAnt
		//��������������������������������������������������������������Ŀ
		//� Lista o detalhe da ordem de producao                         �
		//����������������������������������������������������������������
		CabecOP(Tamanho)
		DetalheOP(Tamanho)
		If Localiza(SD4->D4_COD)
			dbSelectArea("SDC")
			cChave := ''
			If Rastro(SD4->D4_COD)
				cChave:=xFilial()+SD4->D4_COD+SD4->D4_LOCAL+SD4->D4_OP+SD4->D4_TRT+SD4->D4_LOTECTL+SD4->D4_NUMLOTE
				cCompara:="DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_OP+DC_TRT+DC_LOTECTL+DC_NUMLOTE"
			Else
				cChave:=xFilial()+SD4->D4_COD+SD4->D4_LOCAL+SD4->D4_OP+SD4->D4_TRT
				cCompara:="DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_OP+DC_TRT"
			EndIf
			//��������������������������������������������������������������Ŀ
			//� Varre composicao do empenho                                  �
			//����������������������������������������������������������������
			If !Empty(cChave) .AND. dbSeek(cChave)
				nSldSD4 := If(mv_par10==1,SD4->D4_QTDEORI,SD4->D4_QUANT)
				Do While !Eof() .And. cChave == &(cCompara)
					CabecOP(Tamanho)
					@ Li,91 PSAY DC_LOTECTL	Picture PesqPict("SDC","DC_LOTECTL",10)
					@ Li,103 PSAY DC_NUMLOTE	Picture PesqPict("SDC","DC_NUMLOTE",6)
					@ Li,112 PSAY DC_LOCALIZ Picture PesqPict("SDC","DC_LOCALIZ",15)
					@ Li,126 PSAY DC_NUMSERI Picture PesqPict("SDC","DC_NUMSERI",20)
					//��������������������������������������������������������������Ŀ
					//�Lista quantidade de acordo com o parametro selecionado        �
					//����������������������������������������������������������������
					If mv_par10 == 1
						@ Li,147 PSAY DC_QTDORIG Picture PesqPictQt("D4_QUANT",14)
						@ li,162 PSAY SD4->D4_DTVALID Picture PesqPict("SD4","D4_DTVALID",10)
						@ li,176 PSAY SD4->D4_POTENCI Picture PesqPictQt("D4_POTENCI", 14)
					Else
						@ Li,147 PSAY DC_QUANT Picture PesqPictQt("D4_QUANT",14)
						@ li,162 PSAY SD4->D4_DTVALID Picture PesqPict("SD4","D4_DTVALID",10)
						@ li,176 PSAY SD4->D4_POTENCI Picture PesqPictQt("D4_POTENCI", 14)
					EndIf
					Li++
					nSldSD4 -= If(mv_par10==1,DC_QTDORIG,DC_QUANT)
					dbSkip()
				EndDo
				If nSldSD4 > 0
					DetalheOP(Tamanho)
					@ Li,147 PSAY nSldSD4 Picture PesqPictQt("D4_QUANT",14)
					@ li,162 PSAY SD4->D4_DTVALID Picture PesqPict("SD4","D4_DTVALID",10)
					@ li,176 PSAY SD4->D4_POTENCI Picture PesqPictQt("D4_POTENCI", 14)
					Li++
				EndIf
			Else
				@ Li,147 PSAY If(mv_par10==1,SD4->D4_QTDEORI,SD4->D4_QUANT) Picture PesqPictQt("D4_QUANT",14)
				@ li,162 PSAY SD4->D4_DTVALID Picture PesqPict("SD4","D4_DTVALID",10)
				@ li,176 PSAY SD4->D4_POTENCI Picture PesqPictQt("D4_POTENCI", 14)
				Li++
			EndIf
		Else
			@ Li,147 PSAY If(mv_par10==1,SD4->D4_QTDEORI,SD4->D4_QUANT) Picture PesqPictQt("D4_QUANT",14)
			@ li,162 PSAY SD4->D4_DTVALID Picture PesqPict("SD4","D4_DTVALID",10)
			@ li,176 PSAY SD4->D4_POTENCI Picture PesqPictQt("D4_POTENCI", 14)
			Li++
		EndIf
		dbSelectArea("SD4")
		dbSkip()
	EndDo
	dbSelectArea("SC2")
	dbSkip()
EndDo

If Li != 80
	roda(cbcont,cbtxt,tamanho)
EndIf

dbSelectArea("SC2")
RetIndex("SC2")
Ferase(cSC2ntx+OrdBagExt())

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CabecOP  � Autor �Rodrigo de A. Sartorio � Data � 14.04.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime o cabecalho do relatorio por Ordem de Producao     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR265	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CabecOP(Tamanho)
Local aArea    := GetArea()
Local aAreaSB1 := SB1->(GetArea())
If Li > 55 .Or. SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD != cOpAnt
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,18)
	@ Li, 00 PSAY STR0023+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD	//"ORDEM DE PRODUCAO: "
	Li+=2
	SB1->(dbSeek(xFilial("SB1")+SC2->C2_PRODUTO))
	@ Li, 00 PSAY STR0024+SC2->C2_PRODUTO+" - "+SB1->B1_DESC	//"PRODUTO..........: "
	Li+=2
	@ Li, 00 PSAY STR0025	//"DATA PREV. INICIO: "
	@ Li, 19 PSAY SC2->C2_DATPRI
	Li+=2
	@ Li, 00 PSAY STR0026	//"DATA PREV. ENTREG: "
	@ Li, 19 PSAY SC2->C2_DATPRF
	Li+=2
	@ Li, 00 PSAY STR0027+Transform(SC2->C2_QUANT,PesqPictQt("C2_QUANT",14))	//"QUANTIDADE.......: "
	Li+=2
	@ Li, 00 PSAY STR0028+SC2->C2_OBS	//"OBSERVACAO.......: "
	Li+=2
	@ Li,00 PSAY __PrtThinLine()
	Li+=2
	cOPAnt:=SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD
Endif
RestArea(aAreaSB1)
RestArea(aArea)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � DetalheOP� Autor �Rodrigo de A. Sartorio � Data � 14.04.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime o detalhe da Ordem de Producao                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR265	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function DetalheOP(Tamanho)
Local cAlias:=Alias()
dbSelectArea("SB1")
dbSeek(xFilial()+SD4->D4_COD)
@ Li,00 PSAY SD4->D4_COD				Picture PesqPict("SD4","D4_COD",15)
@ Li,46 PSAY Left(SB1->B1_DESC,30)	Picture PesqPict("SB1","B1_DESC",30)
@ Li,89 PSAY SB1->B1_UM					Picture PesqPict("SB1","B1_UM",2)
If !Localiza(SD4->D4_COD)
	@ Li,92 PSAY SD4->D4_LOTECTL	Picture PesqPict("SD4","D4_LOTECTL",10)
	@ Li,103 PSAY SD4->D4_NUMLOTE	Picture PesqPict("SD4","D4_NUMLOTE",6)
EndIf
dbSelectArea(cAlias)
Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �C265ImpRem�Autor  �Guilherme C. Leal   � Data �  04/18/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Picking List por/by Remito								  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function C265ImpRem( lEnd, tamanho, titulo, wnRel )
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
LOCAL cChaveAnt:="",cChaveDB:=""
LOCAL lExistBlock:=ExistBlock("MR265MAIL")
PRIVATE cNfAnt := Space(TamSX3("D2_DOC")[1])
PRIVATE cSerAnt:= Space(TamSX3("D2_SERIE")[1])
PRIVATE nValorNf := 0

//��������������������������������������������������������������Ŀ
//� Coloca areas nas Ordens Corretas                             �
//����������������������������������������������������������������
dbSelectArea("SB1")
dbSetOrder(1)

dbSelectArea("SD2")
dbSetOrder(3)

//��������������������������������������������������������������Ŀ
//� Monta filtro e indice da IndRegua                            �
//����������������������������������������������������������������
cIndex :="D2_FILIAL+D2_DOC+D2_ITEM+D2_COD+D2_LOTECTL+D2_NUMLOTE"

cExpres:='D2_FILIAL=="'+xFilial()+'".And.'
cExpres+='D2_DOC >= "' + mv_par14 + '".And. D2_DOC<= "'+mv_par15+'".And.'
cExpres+='D2_CLIENTE>= "'+mv_par06+'".And. D2_CLIENTE<="'+mv_par07+'"'
cExpres+='.And. ('+IsRemito(2,'SD2->D2_TIPODOC')+')'			
cSD2ntx := CriaTrab(,.F.)
IndRegua("SD2", cSD2ntx, cIndex,,cExpres,STR0010)	//"Selecionando Registros ..."
nIndex := RetIndex("SD2")
dbSetOrder( nIndex+1 )

//��������������������������������������������������������Ŀ
//� Verifica o numero de registros validos para a SetRegua �
//����������������������������������������������������������
dbGoTop()
SetRegua(LastRec())

cChaveAnt := "????????????????"

cNfAnt := Space(TamSX3("D2_DOC")[1])
cSerAnt:= Space(TamSX3("D2_SERIE")[1])

While !Eof()
	//��������������������������������������������������������������Ŀ
	//� Verifica se o usuario interrompeu o relatorio                �
	//����������������������������������������������������������������
	If lAbortPrint
		@Prow()+1,001 PSAY STR0011	//"CANCELADO PELO OPERADOR"
		Exit
	Endif
	
	//��������������������������������������������������������������Ŀ
	//� Verifica Moeda                                               �
	//����������������������������������������������������������������
	if mv_par13==2  //nao imprimir remitos com moeda diferente da escolhida
	   if if(D2_MOEDA==0,1,D2_MOEDA)!=mv_par12
	      dbselectarea("SD2") 
  		  IncRegua()
	      dbskip()
	      loop
	   endif
	endif
	
	dbSelectArea( "SB1" )
	dbSeek( xFilial() + SD2->D2_COD )
	
	If SD2->D2_TIPO =="D"      // Devolucao/Devolucion/Return
		dbSelectArea( "SA2" )
		dbSetOrder(1)
		dbSeek( xFilial() + SD2->D2_CLIENTE + SD2->D2_LOJA )
	Else
		dbSelectArea( "SA1" )
		dbSetOrder( 1 )
		dbSeek( xFilial() + SD2->D2_CLIENTE + SD2->D2_LOJA)
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Cabecalho do Remito/Encabezado del Remito/Remitos Header     �
	//����������������������������������������������������������������
	CabecRem(Tamanho)
	
	//��������������������������������������������������������������Ŀ
	//� Detalhe do Remito/Detalle del Remito/Remito Detail           �
	//����������������������������������������������������������������
	DetalheRem(Tamanho)

	If Localiza( SD2->D2_COD )
		dbSelectArea( "SDB" )
		dbSetOrder(1)

		cChaveDB := xFilial("SDB")+SD2->D2_COD+SD2->D2_LOCAL+SD2->D2_NUMSEQ+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
		If dbSeek(cChaveDB)
			While !Eof() .And. cChaveDB == DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA
				If DB_ESTORNO == "S"
					dbSkip()
					Loop
				EndIf
				@ Li,113 PSAY DB_LOCALIZ Picture PesqPict("SDB","DB_LOCALIZ",15)
				@ Li,122 PSAY DB_NUMSERI Picture PesqPict("SDB","DB_NUMSERI",20)
				@ Li,147 PSAY DB_QUANT Picture PesqPictQt("DB_QUANT",14)
				dbSkip()
				Li := Li + 1
				If Li > 55
					roda(cbcont,cbtxt,tamanho)
					CabecRem(Tamanho)
					DetalheRem(Tamanho)
				EndIf
			EndDo
		Else
		EndIf
	Else
		@ Li, 86 PSAY SD2->D2_QUANT Picture PesqPictQt("D2_QUANT",14)
	EndIf
	dbSelectArea("SD2")

	Li++
	IncRegua()
	dbSelectArea( "SD2" )
	//��������������������������������������Ŀ
	//� Executa EXECBLOCK p/ envio de e-mail �
	//����������������������������������������
	If lExistBlock
		ExecBlock("MR265MAIL",.F.,.F.)
	EndIf
	dbSkip()
EndDo

dbSelectArea("SD2")
RetIndex("SD2")
Ferase( cSD2ntx + OrdBagExt() )

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()
return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CabecRem � Autor � Guilherme C. Leal     � Data � 18.04.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cabecalho/Encabezado/Header				                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR265	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CabecRem(Tamanho)
Local nEsp := 15
Local cTxt := ""
If Li > 55 .Or. (SD2->D2_REMITO != cNfAnt .And. SD2->D2_SERIE != cSerAnt)
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,18)
	If SD2->D2_TIPO $ "D"
		cTxt := Padr(STR0014,nEsp,".")
		@ Li, 00 PSAY cTxt + ": " + AllTrim(SA2->A2_COD) + "/" + SA2->A2_LOJA + " - " + SA2->A2_NOME	//"CLIENTE/FORN.: "
		Li+=2
		cTxt := Padr(STR0015,nEsp,".")		
		@ Li, 00 PSAY cTxt + ": " + AllTrim(SA2->A2_MUN) + " - " + SA2->A2_EST	//"MUNICIPIO....: "
		Li+=2
	Else
		cTxt := Padr(STR0014,nEsp,".")
		@ Li, 00 PSAY cTxt + ": " + AllTrim( SA1->A1_COD) + "/" + SA1->A1_LOJA + " - " + SA1->A1_NOME	//"CLIENTE/FORN.: "
		Li+=2
		cTxt := Padr(STR0015,nEsp,".")		
		@ Li, 00 PSAY cTxt + ": " + AllTrim(SA1->A1_MUN) + " - " + SA1->A1_EST	//"MUNICIPIO....: "
		Li+=2
	EndIf
    If cPaisloc $ "CHI"
	    cTxt := Padr(STR0030,nEsp,".")
    Elseif cPaisloc $ "COL|MEX|PAR"
	    cTxt := Padr(STR0031,nEsp,".")
    Elseif cPaisloc $ "EUA|POR"
	    cTxt := Padr(STR0032,nEsp,".")
    Elseif cPaisloc $ "ARG|URU"
	    cTxt := Padr(STR0029,nEsp,".")
    Endif
	@ Li, 00 PSAY cTxt + ": " + SD2->D2_DOC	
    
    Li+=2
    cTxt := Padr(Alltrim(Upper(SerieNfId("SD2",7,"D2_SERIE"))),nEsp,".")
    @ Li,00 PSAY cTxt +": " + SerieNfId("SD2",2,"D2_SERIE")

	Li+=2
	cTxt := Padr(STR0017,nEsp,".")
	@ Li, 00 PSAY cTxt + ": " + SD2->D2_PEDIDO	//"PEDIDO.......: "
	Li+=2
	@ Li,00 PSAY __PrtThinLine()
	Li+=2
	cNfAnt := SD2->D2_DOC
    cSerAnt:= SD2->D2_SERIE
Endif
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �DetalheRem� Autor � Guilherme C. Leal     � Data � 18.04.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Detalhe do Remito/Detalle del Remito/Remito Detail         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR265	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function DetalheRem(Tamanho)
@ Li,00 PSAY SD2->D2_COD			Picture PesqPict("SD2","D2_COD",15)
@ Li,16 PSAY Left(SB1->B1_DESC,30)		Picture PesqPict("SB1","B1_DESC",30)
@ Li,47 PSAY SB1->B1_UM				Picture PesqPict("SB1","B1_UM",2)
@ Li,50 PSAY SD2->D2_LOTECTL			Picture PesqPict("SD2","D2_LOTECTL",10)
@ Li,61 PSAY SD2->D2_NUMLOTE			Picture PesqPict("SD2","D2_NUMLOTE",6)
Return
