#Include 'TOTVS.ch'
#INCLUDE "FILEIO.CH"
#INCLUDE 'APWIZARD.CH'
#include 'protheus.ch'
#Include "TopConn.Ch"
#INCLUDE "RWMAKE.CH"

/*
TEAMTEX
Rotina de consulta logistica 
@author Marcos Bido
@since 18/06/2018
@version 1.0
*/

/* =============================================================== */
User Function TTEXCFAT004()

	Local oWizard    := NIL
	Local lFinish    := .F.
	Local cHeader    := ''
	Local cMessage   := ''
	Local cText      := ''
	Local cTitleProg := 'Analise Logistica '

	Local cTextP2    := ''
	Local oTextP2    := Nil

	Local cNameFunc  := Space(100)
	Local oNameFunc  := Nil
	Local cTextP3    := ''
	Local oTextP3    := Nil
	Local lOrdVetX3  := .T.
	Local oOrdVetX3  := .T.

	//Local oGroup1
	Local oGet1 := Nil
	Local oGet2 := Nil

	Local _dData1 := CTOD("01/03/2017")
	Local _dData2 := DATE()

	DEFINE FONT oArial10	NAME 'Arial'       WEIGHT 10
	DEFINE FONT oCouri11	NAME 'Courier New' WEIGHT 11

	cHeader  := 'Acompanhamento e Controle Logistico '
	cMessage := 'Assistente para processamento'
	cText    := 'Este assistente irá auxilia-lo na configuração dos parmetros para realização da extração '
	cText    += 'dos dados a partir dos parametros informados.'+CRLF+' O objetivo desta aplicação é efetuar a exportação '
	cText    += 'de dados de faturamento, a apresenta-los na forma de browse.' + CRLF + 'Clique em "Imprimir" para acessar as várias formas de impressao  ' 
	cText    += CRLF+ CRLF
	cText    += 'Clique em "Avançar" para continuar...'

	DEFINE	WIZARD	oWizard TITLE	'Acompanhamento e Controle Logistico ';
		HEADER	cHeader;
		MESSAGE	cMessage;
		TEXT	cText;
		NEXT 	{|| .T.};
		FINISH 	{|| .F.}


	cMessage := 'Informe o intervalo de datas para extração dos dados...'
	CREATE	PANEL 	oWizard  ;
		HEADER 	cHeader;
		MESSAGE	cMessage;
		BACK	{|| .T.} ;
		NEXT	{|| !Empty(_dData2) };
		FINISH	{|| .F.}

	cTextP2	:= 'Restrições:' + Chr(10)+Chr(13)
	cTextP2	+= Chr(10)+Chr(13)
	cTextP2	+= 'a.) Datas não podem estar em branco ' + Chr(10)+Chr(13)
	cTextP2	+= Chr(10)+Chr(13)

/*	cTextP2	+= 'b.) Os funcionarios devem estar cadastrados no sistema.' + Chr(10)+Chr(13)
	cTextP2	+= Chr(10)+Chr(13)
	cTextP2	+= 'c.) No conte?o dos campos n? pode haver caract/eres especiais como aspas simples ou duplas ' + "(')" + '(")' + ' e ponto e v?gula (;). Isso ira ocasionar em erro na montagem do arquivo.'
*/

@ 012, 010 Say oTextP2 PROMPT cTextP2 Size 228, 094 Of oWizard:oMPanel[2] FONT oArial10 Pixel
@ 085, 005 GROUP To 113, 245 PROMPT "Informe o Intervalo de Datas :" OF oWizard:oMPanel[2] Pixel
@ 007.5, 008 MSGET oGet1 VAR _dData1 					SIZE 050, 005 OF oWizard:oMPanel[2]
@ 007.5, 016 MSGET oGet2 VAR _dData2 					SIZE 050, 010 OF oWizard:oMPanel[2]

	cMessage := 'Iniciar o processamento...'
	CREATE	PANEL 	oWizard  ;
		HEADER 	cHeader;
		MESSAGE	cMessage;
		BACK	{|| .T.} ;
		NEXT	{|| .F.};
		FINISH	{|| lFinish := .T.}

	TSay():New(010, 005, {|| 'Ao término do processo será exibido um browse em tela . ' },;
		oWizard:oMPanel[3],, oCouri11,,,, .T.,,, 200, 50)

	TSay():New(045, 005, {|| 'Clique em "Imprimir" para acessar as várias formas de impressao ...' },;
		oWizard:oMPanel[3],, oCouri11,,,, .T.,,, 200, 50)

	ACTIVATE WIZARD oWizard Center

If lFinish

	Processa({||  ProcImp(_dData1,_dData2/*, Alltrim(cNameFunc),1,.T., lOrdVetX3*/) }, cTitleProg, 'Processando os dados ...')
	
EndIf

Return .T.


/*
ProcImp
Realiza a geração do arquivo para posterior apresentação em browse
@author Marcos Bido
@since 19/06/2018
@version 1.0
*/


Static Function ProcImp(xData1,xData2)

Local lErro			:= .F.
Local lErroB1		:= .F.


Local AWBROWSE		:= {}
Local AWHEAD		:= {"Status Entrega","Status Coleta","Numero Pedido","Data Emissao","Numero Nota Fiscal","Data","Num.Pedido do Cliente","Cliente",;
"Loja","Transportadora","Quantidade","Volume do Pedido","Metro Cubico","Peso Cubagem","Agência Entrega","Dt.Prev.Coleta",;
"Retrabalho","Dt.Saida","Dt.Entrega","Armazem","Frete","Observacao"		}

Local lContinua		:= .F.

//Local aSizeAut	:= MsAdvSize(,.F.,400)
Local aSizeAut	:= MsAdvSize()

Local oOK := LoadBitmap(GetResources(),'br_verde')
Local oNO := LoadBitmap(GetResources(),'br_vermelho')
local oBrowse
Local oButton1
Local oButton2

ProcRegua(RecCount())

//aRotina := {}

xData1 := Alltrim(STR(Year(xData1))) + Alltrim(STRZERO(Month(xData1),2)) +""+ Alltrim(STRZERO(Day(xData1),2))
xData2 := Alltrim(STR(Year(xData2))) + Alltrim(STRZERO(Month(xData2),2)) +""+ Alltrim(STRZERO(Day(xData2),2))

If Select("TRB") > 0
	DbSelectArea("TRB")
	DbCloseArea()
Endif

cQuery := " SELECT SF2.* "
cQuery += " FROM "	+ RetSqlTab("SF2") + ""
cQuery += " WHERE SF2.F2_FILIAL  = '" +xFilial("SF2")	+ "' "
cQuery += " AND SF2.F2_EMISSAO >= '"+xData1+"' "
cQuery += " AND SF2.F2_EMISSAO <= '"+xData2+"' "
cQuery += " AND SF2.F2_XSTATUS ='' "
cQuery += " AND SF2.D_E_L_E_T_ <>'*' "

TCQUERY cQuery NEW ALIAS "TRB"

TCSetField("TRB","F2_EMISSAO","D")
TCSetField("TRB","F2_XNCOLET","D")
TCSetField("TRB","F2_XDCOLET","D")
TCSetField("TRB","F2_XDRETIR","D")
TCSetField("TRB","F2_XDAGENT","D")
TCSetField("TRB","F2_XDRETRA","D")
TCSetField("TRB","F2_XDTSAID","D")
TCSetField("TRB","F2_XDTENT" ,"D")

DBSELECTAREA('TRB')
Count to _nQtdReg
ProcRegua(_nQtdReg)
TRB->(DbGoTop())

While TRB->(!EOF())
	
	IncProc()
	
	_cTransp	:=""
	_cVolume	:=""
	_cFrete		:=""
	_nQuant		:=0
	_nTotM3		:=0
	_nTotPeso3	:=0
	_cPedCli 	:= ""
	lPedido		:=.T.
	
	//-------------------------------------------------------------
	//Lista os produtos
	//-------------------------------------------------------------
	
	If Select("TRB2") > 0
		DbSelectArea("TRB2")
		DbCloseArea()
	Endif
	
	cQuery2 := " SELECT SD2.* "
	cQuery2 += " FROM "	+ RetSqlTab("SD2") + ""
	cQuery2 += " WHERE SD2.D2_FILIAL  = '" +xFilial("SD2")	+ "' "
	cQuery2 += " AND SD2.D2_DOC = '" 		+ TRB->F2_DOC  	+ "' "
	cQuery2 += " AND SD2.D2_SERIE='"		+ TRB->F2_SERIE	+ "' "
	cQuery2 += " AND SD2.D2_CLIENTE = '"	+ TRB->F2_CLIENTE	+ "' "
	cQuery2 += " AND SD2.D2_LOJA='"			+ TRB->F2_LOJA	+ "' "
	cQuery2 += " AND SD2.D_E_L_E_T_ <>'*' "
	
	TCQUERY cQuery2 NEW ALIAS "TRB2"
	
	dbSelectArea("TRB2")
	
	
	While TRB2->( !EOF())
		
		_cPedCli 	:= D2_PEDIDO
		
		_nQuant		+=	D2_QUANT
		_cVolume	:= 0
		
		//-----------------------------------------------------------------------------------
		//Busca dados do Pedido
		//-----------------------------------------------------------------------------------
		If lPedido
			dbSelectArea("SB5")
			dbSetOrder(1)
			DbSelectArea("SC5")
			DbSetOrder(1)
			
			If DbSeek(xFilial("SC5")+TRB2->D2_PEDIDO)
				
				_NumPedido := SC5->C5_NUM
				_DtEmissao := SC5->C5_EMISSAO
				_cVolume   := SC5->C5_VOLUME1		//Volume do pedido
				
				_nTotM3		:=	SC5->C5_PCUB01
				_nTotPeso3	:=	SC5->C5_PCUB02
				
				If !Empty(SC5->C5_TRANSP)
					_cTransp	:= Posicione("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_NREDUZ") 		//TRANSPORTADORA
				Endif
				
				If Alltrim(SC5->C5_TPFRETE) =="C"
					_cFrete="CIF"
				ElseIf Alltrim(SC5->C5_TPFRETE) =="F"
					_cFrete="FOB"
				ElseIf Alltrim(SC5->C5_TPFRETE) =="T"
					_cFrete="POR CONTA DE TERCEIROS"
				ElseIf Alltrim(SC5->C5_TPFRETE) =="S"
					_cFrete="SEM FRETE"
				Endif
				
				DbSelectArea("SC6")
				DbSetOrder(1)
				If DbSeek(xFilial("SC6")+TRB2->D2_PEDIDO)
					If !Empty(SC6->C6_PEDCLI)
						_cPedCli:= SC6->C6_PEDCLI
					Endif
				Endif
				
			endif
			lPedido := .F.
		Endif
		
		dbSelectArea("TRB2")
		TRB2->(DbSkip())
	End
	//DbCloseArea("TRB2")
	
	
	//----------------------------------------------------------------------------------------------------
	//a)As notas que tiverem o campo "Ag. Entrega" com data ultrapassada, ou seja com data maior
	//  que a data do dia, o próprio campo deverá ficar marcado em "Vermelho".
	//b)Quando o campo "Data Prevista da Coleta" estiver com a data ultrapassada em relação a data do dia,
	//  o campo deverá ficar marcado em "Amarelo".
	//c)O campo "Status Transporte" devera contem as seguintes opções:
	//		Entregue (A mercadoria foi efetivamente entregue).
	//		Devolução (Foi realizada devolução de mercadoria).
	//d)Quando o campo "Status Transporte" estiver preenchido com uma das duas opções citadas no item "C"
	//	a nota não deverá aparecer na tela de visualização.
	//e)Quando o campo "Status Transporte" estiver preenchido com uma das duas opções citadas no item "C"
	//  os campos criados mo item 1 não deveram mais permitir alteração.
	//----------------------------------------------------------------------------------------------------
	_oCorEntrega	:=.T.  // verde
	_oCorColeta		:=.T.  // verde
	
	If	TRB->F2_XDAGENT < dDatabase
		_oCorEntrega	:= .F.
	Endif
	If TRB->F2_XDCOLET < dDatabase
		_oCorColeta		:= .F.
	Endif
	
	_cNomeCli	:=""
	DbSelectArea("SA1")
	DbSetOrder(1)
	
	If DbSeek(xFilial("SA1")+TRB->F2_CLIENTE+TRB->F2_LOJA)
		_cNomeCli	:= TRB->F2_CLIENTE + "-"+SA1->A1_NOME
	Endif
	
	// Carrege aqui sua array da Listbox
	Aadd( AWBROWSE , {		 ;
	_oCorEntrega			,;	//01 cor entregal
	_oCorColeta				,;	//02 cor coleta
	_NumPedido     			,;	//03 Num.pedido
	_DtEmissao				,;	//04 DATA entrega
	TRB->F2_DOC				,;	//05 NFE
	TRB->F2_EMISSAO			,;	//06 DATA
	_cPedCli+space(20)		,;	//07 SD2->D2_PEDIDO				//PED.CLI
	_cNomeCli				,;	//08 CLIENTE
	TRB->F2_LOJA			,;	//09 LOJA
	_cTransp				,;	//10 SC5->C5_TRANSP				TRANSPORTADORA
	PadL(Transform(_nQuant,"@E 999,999,999.9999"),16)	,;	//11 SD2->D2_QUANT				QTDE
	PadL(Transform(_cVolume,"@E 999,999,999.9999"),16)	,;	//12 SC5->C5_VOLUME1			 Volume do pedido
	PadL(Transform(_nTotM3,"@E 999,999,999.9999"),16)	,;	//13 m3 	(Metro Cubico)
	PadL(Transform(_nTotPeso3,"@E 999,999,999.9999"),16)	,;	//14 peso3	(Peso Cubico
	TRB->F2_XDAGENT			,;	//15 Data de Agendamento Entrega
	TRB->F2_XDCOLET			,;	//16 Data Prevista Coleta
	TRB->F2_XDRETRA			,;	//17 Data do Retrabalho
	TRB->F2_XDTSAID			,;	//18 Data de Saida da Mercadoria
	TRB->F2_XDTENT			,;	//19 Data da Entrega
	TRB->F2_XARMAZE			,;	//20 Armazem
	_cFrete					,;	//21 SC5->C5_TPFRETE FRETE (C=CIF,F=FOB,T=POR CONTA DE TERCEIROS, S=SEM FRETE)
	TRB->F2_XOBSCOL	})			//22 Observação da coleta
	
	TRB->(DbSkip())
	
End
DbCloseArea("TRB")



If Len(AWBROWSE) > 0
	
	aSort( AWBROWSE,,,{|x,y| y[3] > x[3]})
	
	DEFINE DIALOG oDlg2 TITLE "Controle Logistico - v2106" FROM 000, 000  TO aSizeAut[6],aSizeAut[5] COLORS 0, 16777215 PIXEL
	oBrowse := TCBrowse():New( 01 , 01, 0800 ,300,/*bLine*/,AWHEAD,/*colsize*/,;
	oDlg2,/*cField*/,/*uValue1*/,/*uValue2*/,/*bChange*/,/*bLDblClick*/,;
	/*bRClick*/,/*oFont*/,/*oCursor*/,/*nClrFore*/,/*nClrBack*/,/*cMsg*/,;
	.F.,/*cAlias*/,.T.,/*bWhen*/,.F.,/*bValid*/,/*lHScroll*/,/*lVScroll*/)
	
	oBrowse:SetArray(AWBROWSE)
	oBrowse:bLine := {||{;
	If(AWBROWSE[oBrowse:nAt,01],oOK,oNO),;
		If(AWBROWSE[oBrowse:nAt,02],oOK,oNO),;
			AWBROWSE[oBrowse:nAt,03],;
			AWBROWSE[oBrowse:nAt,04],;
			AWBROWSE[oBrowse:nAt,05],;
			AWBROWSE[oBrowse:nAt,06],;
			AWBROWSE[oBrowse:nAt,07],;
			AWBROWSE[oBrowse:nAt,08],;
			AWBROWSE[oBrowse:nAT,09],;
			AWBROWSE[oBrowse:nAT,10],;
			AWBROWSE[oBrowse:nAT,11],;
			AWBROWSE[oBrowse:nAT,12],;
			AWBROWSE[oBrowse:nAT,13],;
			AWBROWSE[oBrowse:nAT,14],;
			AWBROWSE[oBrowse:nAT,15],;
			AWBROWSE[oBrowse:nAT,16],;
			AWBROWSE[oBrowse:nAT,17],;
			AWBROWSE[oBrowse:nAT,18],;
			AWBROWSE[oBrowse:nAT,19],;
			AWBROWSE[oBrowse:nAT,20],;
			AWBROWSE[oBrowse:nAT,21],;
			AWBROWSE[oBrowse:nAT,22]} }
			
			// Scroll type
			oBrowse:nScrollType := 1
			@ 280, 325 BUTTON oButton1 PROMPT "Imprime" SIZE 036, 013 OF oDlg2 ACTION (Imprime(AWBROWSE,AWHEAD)) PIXEL
			//	@ 050, 625 BUTTON oButton1 PROMPT "Confirmar" SIZE 036, 013 OF oDlg2 ACTION (oDlg2:End(), lContinua := .T.) PIXEL
			//	@ 070, 625 BUTTON oButton2 PROMPT "Cancelar" SIZE 036, 013 OF oDlg2 ACTION (oDlg2:End(), lContinua := .F.) PIXEL
			
			ACTIVATE DIALOG oDlg2 CENTERED
		Else
			Alert('Não foi encontrado nenhum registro elegível nessa planilha, favor verificar os cadastros!')
			lContinua := .F.
		EndIf
		
		If lContinua
		EndIf
		
		
		//ENDDO
		
		Return



/*/{Protheus.doc} Imprime
(long_description)
@author mynam
@since 26/04/2018
@version 1.0
@param aCOLS, array, (Descrição do parâmetro)
@param aHeader, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function Imprime(aCOLS, aHeader)
Local oReport
oReport := xDefArray( aCOLS, aHeader )
oReport:PrintDialog()
Return

Static Function xDefArray( aCOLS, aHeader )
Local oReport
Local oSection
Local nLen := Len(aHeader)
Local nX := 0

oReport := TReport():New( 'Conferencia', 'Conferencia Logistica', , {|oReport| xImprArray( oReport, aCOLS )}, 'Conferencia Logistica' )

oSection1 := TRSection():New(oReport, "Layout",)

for nX := 1 to len(aHeader)
	TRCell():New(oSection1,"CEL"+Alltrim(Str(nX))				, , aHeader[nX]				,						, 20,,)
Next

Return( oReport )




//-----------------------------------------------------------------------
// Rotina | xImprArray   | Autor | Robson Luiz - Rleg | Data | 04.04.2013
//-----------------------------------------------------------------------
// Descr. | Impressão dos dos dados do array.
//-----------------------------------------------------------------------
// Uso    | Oficina de Programação
//-----------------------------------------------------------------------
Static Function xImprArray( oReport, aCOLS )
Local oSection := oReport:Section(1) // Retorna objeto da classe TRSection (seção). Tipo Caracter: Título da seção. Tipo Numérico: Índice da seção segundo a ordem de criação dos componentes TRSection.
Local nX := 0
Local nY := 0

/*
+-----------------------------------------------------+
| Define o limite da régua de progressão do relatório |
+-----------------------------------------------------+
SetMeter(nTotal)

nTotal - Limite da régua

*/
oReport:SetMeter( Len( aCOLS ) )

/*
+---------------------------------------------------------------------+
| Inicializa as configurações e define a primeira página do relatório |
+---------------------------------------------------------------------+
Init()

Não é necessário executar o método Init se for utilizar o método Print, já que estes fazem o controle de inicialização e finalização da impressão.
*/
oSection:Init()

For nX := 1 To Len( aCOLS )
	// Retorna se o usuário cancelou a impressão do relatório
	If oReport:Cancel()
		Exit
	EndIf
	
	For nY := 1 To 8
		If ValType( aCOLS[ nX, nY ] ) == 'D'
			oSection:Cell("CEL"+Alltrim(Str(nY))):SetBlock( &("{ || '" + Dtoc(aCOLS[ nX, nY ]) + "'}") )
		Elseif ValType( aCOLS[ nX, nY ] ) == 'N'
			oSection:Cell("CEL"+Alltrim(Str(nY))):SetBlock( &("{ || '" + TransForm(aCOLS[ nX, nY ],'@E 999,999,999.99') + "'}") )
		Elseif ValType( aCOLS[ nX, nY ] ) == 'L'
			//			oSection:Cell("CEL"+Alltrim(Str(nY-1))):SetBlock( &("{ || ''}") )
		Else
			oSection:Cell("CEL"+Alltrim(Str(nY))):SetBlock( &("{ || '" + aCOLS[ nX, nY ] + "'}") )
		Endif
	Next
	
	// Incrementa a régua de progressão do relatório
	oReport:IncMeter()
	
	/*
	+------------------------------------------------+
	| Imprime a linha baseado nas células existentes |
	+------------------------------------------------+
	PrintLine(lEvalPosition,lParamPage,lExcel)
	
	lEvalPosition	- Força a atualização do conteúdo das células
	lParamPage		- Aponta que é a impressão da página de parâmetros
	lExcel			- Aponta que é geração em planilha
	
	*/
	oSection:PrintLine()
Next

/*
Finaliza a impressão do relatório, imprime os totalizadores, fecha as querys e índices temporários, entre outros tratamentos do componente.
Não é necessário executar o método Finish se for utilizar o método Print, já que este faz o controle de inicialização e finalização da impressão.
*/
oSection:Finish()
Return


