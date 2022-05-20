#INCLUDE "TOTVS.CH"
#include "TopConn.Ch"
#INCLUDE "PROTHEUS.CH"
//#INCLUDE "TBIConn.ch"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "APWEBSRV.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TEAMLOGISTºAutor  ³Microsiga           º Data ³  07/03/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function TEAMLOGIST()
Local oButton1
Local oGroup1
Local oGet1
Local _dData1 := CTOD("01/03/2017")
Local oGet2
Local _dData2 := DATE()


// Variaveis que definem a Acao do Formulario
Private VISUAL 		:= .F.
Private INCLUI 		:= .F.
Private ALTERA 		:= .F.
Private DELETA 		:= .F.

//ListBox
Private aListBox1 	:= {}
Private oListBox1
Private oBrowse

Private oDlg2
Private oVerde		:= LoadBitmap( GetResources()	, "BR_VERDE")
Private oAmarelo	:= LoadBitmap( GetResources()	, "BR_AMARELO")
Private oVermelho	:= LoadBitmap(GetResources()	, "BR_VERMELHO"	)


  DEFINE MSDIALOG oDlg2 TITLE "Controle Logistico" FROM 000, 000  TO 600, 1400 COLORS 0, 16777215 PIXEL //OF GetWndDEFAULT()

    @ 007, 007 GROUP oGroup1 TO 292, 686 OF oDlg2 COLOR 0, 16777215 PIXEL

    @ 022, 016 SAY oSay1 PROMPT "Data Inicial" 			SIZE 034, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
    @ 022, 055 MSGET oGet1 VAR _dData1 					SIZE 060, 010 OF oDlg2 COLORS 0, 16777215 PIXEL

    @ 022, 125 SAY oSay3 PROMPT "Data Final" 			SIZE 032, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
    @ 022, 157 MSGET oGet2 VAR _dData2 					SIZE 060, 010 OF oDlg2 COLORS 0, 16777215 PIXEL

    @ 022, 236 BUTTON oButton2 PROMPT "&Pesquisar" 		ACTION(   	Processa({|lEnd|fListBox1(_dData1,_dData2)}));
    													SIZE 037, 012 OF oDlg2 PIXEL




   	_CriaTcBrowse()


    @ 265, 631 BUTTON oButton1 PROMPT "&Sair"  			Action(oDlg2:End());
    													SIZE 037, 012 OF oDlg2 PIXEL
	// Chamadas das ListBox do Sistema


  ACTIVATE MSDIALOG oDlg2 CENTERED


/*
 DEFINE MSDIALOG oDlg2 TITLE "Controle Logistico" FROM 000, 000  TO 500, 950 COLORS 0, 16777215 PIXEL //OF GetWndDEFAULT()

    @ 007, 007 GROUP oGroup1 TO 243, 452 OF oDlg2 COLOR 0, 16777215 PIXEL

    @ 022, 016 SAY oSay1 PROMPT "Data Inicial" 			SIZE 034, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
    @ 022, 055 MSGET oGet1 VAR _dData1 					SIZE 060, 010 OF oDlg2 COLORS 0, 16777215 PIXEL

    @ 022, 125 SAY oSay3 PROMPT "Data Final" 			SIZE 032, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
    @ 022, 157 MSGET oGet2 VAR _dData2 					SIZE 060, 010 OF oDlg2 COLORS 0, 16777215 PIXEL

    @ 022, 236 BUTTON oButton2 PROMPT "&Pesquisar" 		ACTION(   	Processa({|lEnd|fListBox1(_dData1,_dData2)}));
    													SIZE 037, 012 OF oDlg2 PIXEL




   	_CriaTcBrowse()


    @ 219, 403 BUTTON oButton1 PROMPT "&Sair"  			Action(oDlg2:End());
    													SIZE 037, 012 OF oDlg2 PIXEL
	// Chamadas das ListBox do Sistema


  ACTIVATE MSDIALOG oDlg2 CENTERED


*/


Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TEAMLOGISTºAutor  ³Microsiga           º Data ³  07/06/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function _CriaTcBrowse()

Define Font oFont Name 'Courier New' Size 0, -12

// Cria Browse
//oBrowse := TCBrowse():New( 045, 016, 425, 167,,;
oBrowse := TCBrowse():New( 045, 016,  658, 213,,;
		{"Sit.Entrega"		,;	//01 cor entrega
		"Sit.Coleta"		,;	//02 cor coleta
		"NFE"				,;	//03
		"DATA"				,;	//04
		"PED.CLI"			,;	//05
		"CLIENTE"			,;	//06
		"LOJA"				,;	//07
		"TRANSPORTADORA"	,;	//08
		"QTDE"				,;	//09
		"Volume do pedido"	,;	//10
		"Metro Cub"			,;	//11
		"Peso Cub"			,;	//12
		"Ag.Entrega"		,;	//13
		"Dt.Prev.Coleta"	,;	//14
		"Retrabalho"		,;	//15
		"Dt.Saida"			,;	//16
		"Dt.Entrega"		,;	//17
		"Armazem"			,;	//18
		"Frete"             ,;	//19
		"Status"			,;	//20
		"Observacao"		},;	//21
		{	80,;	//01 cor entrega
			80,;	//02 cor coleta
			40,;	//03
			40,;	//04
			60,;	//05
			40,;	//06
			40,;	//07
			90,;	//08
			40,;	//09
			40,;	//10
			40,;	//11
			40,;	//12
 			40,;	//13
			40,;	//14
			40,;	//15
			40,;	//16
			40,;	//17
			40,;	//18
			40,;	//19
			40,;	//20
			100},;  //21
oDlg2,,,,,{||},,oFont,,,,,.F.,,.T.,,.F.,,, )

aListBox1:={}

Aadd(aListBox1,{	.T.	,;	//01 cor entrega
					.T.	,;	//02 cor coleta
					""	,;	//03
					""	,;	//04
					""	,;	//05
					""	,;	//06
					""	,;	//07
					""	,;	//08
					""	,;	//09
					""	,;	//10
					""	,;	//11
					""	,;	//12
					""	,;	//13
					""	,;	//14
					""	,;	//15
					""	,;	//16
					""	,;	//17
					""	,;	//18
					""	,;	//19
					""	,;	//20
					""	})	//21


oBrowse:bLine := {|| {		Iif((aListBox1[oBrowse:nAt][1]),oVerde,oVermelho) ,;
							Iif((aListBox1[oBrowse:nAt][2]),oVerde,oAmarelo ) ,;
							aListBox1[oBrowse:nAT,03],;
							aListBox1[oBrowse:nAT,04],;
							aListBox1[oBrowse:nAT,05],;
							aListBox1[oBrowse:nAT,06],;
							aListBox1[oBrowse:nAT,07],;
							aListBox1[oBrowse:nAT,08],;
							aListBox1[oBrowse:nAT,09],;
							aListBox1[oBrowse:nAT,10],;
							aListBox1[oBrowse:nAT,11],;
							aListBox1[oBrowse:nAT,12],;
							aListBox1[oBrowse:nAT,13],;
							aListBox1[oBrowse:nAT,14],;
							aListBox1[oBrowse:nAT,15],;
							aListBox1[oBrowse:nAT,16],;
							aListBox1[oBrowse:nAT,17],;
							aListBox1[oBrowse:nAT,18],;
							aListBox1[oBrowse:nAT,19],;
							aListBox1[oBrowse:nAT,20],;
							aListBox1[oBrowse:nAT,21]}}


oBrowse:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NOVO2     ºAutor  ³Microsiga           º Data ³  06/28/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                      		  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fListBox1(xData1,xData2)
Local _nTotM3		:= 0
Local _nTotPeso3	:= 0
Local _cPedido		:=""
Local _cTransp		:=""
Local _nQuant		:= 0
Local _cVolume		:= 0
Local _cFrete		:= ""

Local cQuery		:= ""
Local _cAlias		:= GetNextAlias()
Local _cAlias2		:= ""

aListBox1:={}

If Empty(xData1)

	Aadd(aListBox1,{	.T.	,;	//01 cor entrega
						.T.	,;	//02 cor coleta
						""	,;	//03
						""	,;	//04
						""	,;	//05
						""	,;	//06
						""	,;	//07
						""	,;	//08
						""	,;	//09
						""	,;	//10
						""	,;	//11
						""	,;	//12
						""	,;	//13
						""	,;	//14
						""	,;	//15
						""	,;	//16
						""	,;	//17
						""	,;	//18
						""	,;	//19
						""	,;	//20
						""	})	//21
Else

	xData1 := Alltrim(STR(Year(xData1))) + Alltrim(STRZERO(Month(xData1),2)) +""+ Alltrim(STRZERO(Day(xData1),2))
	xData2 := Alltrim(STR(Year(xData2))) + Alltrim(STRZERO(Month(xData2),2)) +""+ Alltrim(STRZERO(Day(xData2),2))

	cQuery := " SELECT * "
	cQuery += " FROM "	+ RetSqlTab("SF2") + "  "
	cQuery += " WHERE SF2.F2_FILIAL  = '" +xFilial("SF2")	+ "' "
	cQuery += " AND SF2.F2_EMISSAO >= '"+xData1+"' "
	cQuery += " AND SF2.F2_EMISSAO <= '"+xData2+"' "
	cQuery += " AND SF2.F2_XSTATUS ='' "
	cQuery += " AND SF2.D_E_L_E_T_ <>'*' "

	cQuery := 	ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), _cAlias,.F.,.T.)
	TCSetField(_cAlias,"F2_EMISSAO","D",8,0)
	TCSetField(_cAlias,"F2_XNCOLET","D",8,0)
	TCSetField(_cAlias,"F2_XDCOLET","D",8,0)
	TCSetField(_cAlias,"F2_XDRETIR","D",8,0)
	TCSetField(_cAlias,"F2_XDAGENT","D",8,0)
	TCSetField(_cAlias,"F2_XDRETRA","D",8,0)
	TCSetField(_cAlias,"F2_XDTSAID","D",8,0)
	TCSetField(_cAlias,"F2_XDTENT","D",8,0)

	If (_cAlias)->(EOF())
		Aadd(aListBox1,{	.T.	,;	//01 cor entrega
							.T.	,;	//02 cor coleta
							""	,;	//03
							""	,;	//04
							""	,;	//05
							""	,;	//06
							""	,;	//07
							""	,;	//08
							""	,;	//09
							""	,;	//10
							""	,;	//11
							""	,;	//12
							""	,;	//13
							""	,;	//14
							""	,;	//15
							""	,;	//16
							""	,;	//17
							""	,;	//18
							""	,;	//19
							""	,;	//20
							""	})	//21

	Else

		ProcRegua((_cAlias)->(RecCount()))

		(_cAlias)->(DbGotop())

		While (_cAlias)->(!EOF())

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
			_cAlias2		:= GetNextAlias()


			cQuery := " SELECT SD2.* "
			cQuery += " FROM "	+ RetSqlTab("SD2") + " "
			cQuery += " WHERE SD2.D2_FILIAL  = '" +xFilial("SD2")	+ "' "
			cQuery += " AND SD2.D2_DOC = '" 	+ (_cAlias)->F2_DOC  	+ "' "
			cQuery += " AND SD2.D2_SERIE='"		+ (_cAlias)->F2_SERIE	+ "' "
			cQuery += " AND SD2.D2_CLIENTE = '"	+ (_cAlias)->F2_CLIENTE	+ "' "
			cQuery += " AND SD2.D2_LOJA='"		+ (_cAlias)->F2_LOJA	+ "' "
			cQuery += " AND SD2.D_E_L_E_T_ <>'*' "

			cQuery := 	ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), _cAlias2,.F.,.T.)

	        While (_cAlias2)->(!EOF())
	        	//_cPedCli 	:= (_cAlias2)->D2_PEDIDO
				_nQuant		+=	(_cAlias2)->D2_QUANT

				_cVolume	:= 0

				//--------------------------------------------------------
				//Calculo do Peso e Metro Cubico
				//--------------------------------------------------------
				DbSelectArea("SB5")
				DbSetOrder(1)
				If DbSeek(xFilial("SB5")+(_cAlias2)->D2_COD)
					_nTotM3		+=	SB5->B5_XMETCUB * (_cAlias2)->D2_QUANT
					_nTotPeso3	+=	SB5->B5_XPESCUB * (_cAlias2)->D2_QUANT
	            Endif
		    	//-----------------------------------------------------------------------------------
				//Busca dados do Pedido
				//-----------------------------------------------------------------------------------
				If lPedido
					DbSelectArea("SC5")
					DbSetOrder(1)
					If DbSeek(xFilial("SC5")+(_cAlias2)->D2_PEDIDO)
						If !Empty(SC5->C5_TRANSP)
							_cTransp	:= Posicione("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_NOME") 		//TRANSPORTADORA
						Endif
						_cVolume	:= SC5->C5_VOLUME1		//Volume do pedido

						If Alltrim(SC5->C5_TPFRETE) =="C"
							_cFrete="CIF"
						ElseIf Alltrim(SC5->C5_TPFRETE) =="F"
							_cFrete="FOB"
						ElseIf Alltrim(SC5->C5_TPFRETE) =="T"
							_cFrete="POR CONTA DE TERCEIROS"
						ElseIf Alltrim(SC5->C5_TPFRETE) =="S"
							_cFrete="SEM FRETE"
						Endif
					Endif

					DbSelectArea("SC6")
					DbSetOrder(1)
					If DbSeek(xFilial("SC6")+(_cAlias2)->D2_PEDIDO)
					    If !Empty(SC6->C6_PEDCLI)
							_cPedCli:= SC6->C6_PEDCLI
						Endif
					Endif

					lPedido := .F.
	    		Endif
	    		(_cAlias2)->(DbSkip())
	    	End
	    	DbCloseArea(_cAlias2)
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
			_oCorEntrega	:=.T.
			_oCorColeta		:=.T.

			If	(_cAlias)->F2_XDAGENT< Date()
				 _oCorEntrega	:= .F.
			Endif
			If (_cAlias)->F2_XDCOLET < Date()
				_oCorColeta		:= .F.
			Endif

			_cNomeCli	:=""
			DbSelectArea("SA1")
			DbSetOrder(1)
			If DbSeek(xFilial("SA1")+(_cAlias)->F2_CLIENTE+(_cAlias)->F2_LOJA)
				_cNomeCli	:= (_cAlias)->F2_CLIENTE + "-"+SA1->A1_NOME
			Endif

			// Carrege aqui sua array da Listbox
			Aadd(aListBox1,{	    _oCorEntrega			,;	//01 cor entregal
									_oCorColeta				,;	//02 cor coleta
									(_cAlias)->F2_DOC		,;	//03 NFE
									(_cAlias)->F2_EMISSAO	,;	//04 DATA
									_cPedCli+space(20)		,;	//05 SD2->D2_PEDIDO				//PED.CLI
									_cNomeCli				,;	//06 CLIENTE
									(_cAlias)->F2_LOJA		,;	//07 LOJA
									_cTransp				,;	//08 SC5->C5_TRANSP				TRANSPORTADORA
									PadL(Transform(_nQuant,"@E 999,999,999.9999"),16)	,;	//09 SD2->D2_QUANT				QTDE
									PadL(Transform(_cVolume,"@E 999,999,999.9999"),16)	,;	//10 SC5->C5_VOLUME1			 Volume do pedido
									PadL(Transform(_nTotM3,"@E 999,999,999.9999"),16)	,;	//11 m3 	(Metro Cubico)
									PadL(Transform(_nTotPeso3,"@E 999,999,999.9999"),16)	,;	//12 peso3	(Peso Cubico
									(_cAlias)->F2_XDAGENT	,;	//13 Data de Agendamento Entrega
									(_cAlias)->F2_XDCOLET	,;	//14 Data Prevista Coleta
									(_cAlias)->F2_XDRETRA	,;	//15 Data do Retrabalho
									(_cAlias)->F2_XDTSAID	,;	//16 Data de Saida da Mercadoria
									(_cAlias)->F2_XDTENT	,;	//17 Data da Entrega
									(_cAlias)->F2_XARMAZE	,;	//18 Armazem
									_cFrete					,;	//19 SC5->C5_TPFRETE FRETE (C=CIF,F=FOB,T=POR CONTA DE TERCEIROS, S=SEM FRETE)
									(_cAlias)->F2_XSTATUS	,;	//20 Status do transporte
									(_cAlias)->F2_XOBSCOL	})	//21 Observação da coleta


									//	(_cAlias)->F2_XNCOLET	,;	//13 Numero da Coleta		 RETIRADO EM 27-12 A PEDIDO DO ANDREW

	    	(_cAlias)->(DbSkip())
		End
	Endif
Endif

DbCloseArea(_cAlias)

// Seta vetor para a browse
oBrowse:SetArray(aListBox1)

oBrowse:bLine := {|| {		Iif((aListBox1[oBrowse:nAt][1]),oVerde,oVermelho) ,;
							Iif((aListBox1[oBrowse:nAt][2]),oVerde,oAmarelo ) ,;
							aListBox1[oBrowse:nAT,03],;
							aListBox1[oBrowse:nAT,04],;
							aListBox1[oBrowse:nAT,05],;
							aListBox1[oBrowse:nAT,06],;
							aListBox1[oBrowse:nAT,07],;
							aListBox1[oBrowse:nAT,08],;
							aListBox1[oBrowse:nAT,09],;
							aListBox1[oBrowse:nAT,10],;
							aListBox1[oBrowse:nAT,11],;
							aListBox1[oBrowse:nAT,12],;
							aListBox1[oBrowse:nAT,13],;
							aListBox1[oBrowse:nAT,14],;
							aListBox1[oBrowse:nAT,15],;
							aListBox1[oBrowse:nAT,16],;
							aListBox1[oBrowse:nAT,17],;
							aListBox1[oBrowse:nAT,18],;
							aListBox1[oBrowse:nAT,19],;
							aListBox1[oBrowse:nAT,20],;
							aListBox1[oBrowse:nAT,21]}}

							//,;
							//aListBox1[oBrowse:nAT,22]

oBrowse:Refresh()

Return()

Static Function C(nTam)
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
		nTam *= 0.8
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
		nTam *= 1
	Else	// Resolucao 1024x768 e acima
		nTam *= 1.28
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para tema "Flat"³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If "MP8" $ oApp:cVersion
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
			nTam *= 0.90
		EndIf
	EndIf
Return Int(nTam)



User Function CALCPES()

	If INCLUI .OR. ALTERA
		//xResult		:= M->B5_COMPR   * M->B5_LARG   *M->B5_ALTURA
		xResult	    	:=M->B5_XECCOME*M->B5_ECALTEM*M->B5_ECLARGE
		M->B5_XPESCUB	:= xResult * 300
	Else
		Return
	Endif


Return(xResult)