#Include "PROTHEUS.CH"
#Include "Tbiconn.ch"
#Include "TopConn.ch"
#Include "RWMake.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTEAMCUST  บAutor  ณMicrosiga           บ Data ณ  07/18/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function TEAMCUST()
Local cAno 		:= STRZERO(Year(Date()),4)
Local cMes 		:= STRZERO(Month(Date()),2)
Local cGrupoAte := "ZZZZ"
Local cGrupoDe 	:= Space(4)
Local cProdAte	:= "ZZZZZZZZZZZZZZZ"
Local cProdDe	:= Space(15)
Local cTipo 	:= "PA"
Local oAno 		:= Space(4)
Local oMes

Local oGrupoAte
Local oGrupoDe
Local oProdAte
Local oProdDe
Local oTipo
Local oListBox1
Local nListBox1 := 1
Local oBtnCopia
Local oBtnEdita
Local oBtnPesq
Local oBtnSair
Local oGroup1
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSay6
Local oSay7

// Variaveis que definem a Acao do Formulario
Private VISUAL 		:= .F.
Private INCLUI 		:= .F.
Private ALTERA 		:= .F.
Private DELETA 		:= .F.

//ListBox
Private aListBox1 	:= {}
Private oListBox1
Private oBrowse

Private oDlg
Private oVerde		:= LoadBitmap( GetResources()	, "BR_VERDE")
Private oAmarelo	:= LoadBitmap( GetResources()	, "BR_AMARELO")


  DEFINE MSDIALOG oDlg TITLE "Custo Mensal" FROM 000, 000  TO 540, 980 COLORS 0, 16777215 PIXEL

    @ 007, 011 GROUP oGroup1 TO 264, 476 OF oDlg COLOR 0, 16777215 PIXEL


    @ 020, 020 SAY oSay1 PROMPT "Ano" 								SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 031, 020 MSGET oAno 		VAR cAno 							SIZE 025, 010 OF oDlg COLORS 0, 16777215 PIXEL

    @ 020, 048 SAY oSay2 PROMPT "M๊s" 								SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 031, 048 MSGET oMes 		VAR cMes 							SIZE 025, 010 OF oDlg COLORS 0, 16777215 PIXEL

    @ 020, 077 SAY oSay3 PROMPT "Produto De" 						SIZE 034, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 031, 077 MSGET oProdDe 	VAR cProdDe 	F3 "SB1"			SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL

    @ 020, 141 SAY oSay6 PROMPT "Produto At้" 						SIZE 049, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 031, 141 MSGET oProdAte 	VAR cProdAte   	F3 "SB1"			SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL

    @ 020, 206 SAY oSay4 PROMPT "Grupo De" 							SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 031, 206 MSGET oGrupoDe 	VAR cGrupoDe 	F3 "SBM" 			SIZE 030, 010 OF oDlg COLORS 0, 16777215 PIXEL

    @ 020, 240 SAY oSay5 PROMPT "Grupo At้" 						SIZE 028, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 031, 240 MSGET oGrupoAte 	VAR cGrupoAte 	F3 "SBM" 			SIZE 030, 010 OF oDlg COLORS 0, 16777215 PIXEL

    @ 020, 276 SAY oSay7 PROMPT "Tipo" 								SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 031, 276 MSGET oTipo 		VAR cTipo 							SIZE 030, 010 OF oDlg COLORS 0, 16777215 PIXEL

    @ 029, 325 BUTTON oBtnPesq PROMPT "&Pesquisar" 					ACTION(fListBox1(cAno, cMes, cProdDe, cProdAte, cGrupoDe, cGrupoAte, cTipo));
    																SIZE 037, 012 OF oDlg PIXEL

    _CriaTcBrowse()

    @ 240, 331 BUTTON oBtnCopia PROMPT "&Copiar" ACTION(CopiaSZP()) 								SIZE 037, 012 OF oDlg PIXEL
    @ 240, 374 BUTTON oBtnEdita PROMPT "Editar"	ACTION(CustoEditar(	cAno						,;
    																cMes						,;
    																aListBox1[oBrowse:nAT,02]	,;
    																aListBox1[oBrowse:nAT,03]	,;
    																aListBox1[oBrowse:nAT,04]	,;
    																aListBox1[oBrowse:nAT,05]	,;
    																aListBox1[oBrowse:nAT,06]	,;
    																aListBox1[oBrowse:nAT,07]	,;
    																aListBox1[oBrowse:nAT,08]	)) 	SIZE 037, 012 OF oDlg PIXEL
    @ 240, 417 BUTTON oBtnSair PROMPT "&Sair"			ACTION(oDlg:End())							SIZE 037, 012 OF oDlg PIXEL
    @ 240, 286 BUTTON oButton1 PROMPT "Atualiza Val"	Action(AtuPeriodo(cAno,cMes),fListBox1(cAno, cMes, cProdDe, cProdAte, cGrupoDe, cGrupoAte, cTipo));
    													SIZE 037, 012 OF oDlg PIXEL



  ACTIVATE MSDIALOG oDlg CENTERED

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTEAMCUST  บAutor  ณMicrosiga           บ Data ณ  07/18/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function _CriaTcBrowse()

// Cria Browse

Define Font oFont Name 'Courier New' Size 0, -12

oBrowse := TCBrowse():New( 051, 020, 443, 184,,;
		{"Sit"				,;	//cor entrega
		"Produto"			,;	//01
		"Descricao"			,;	//02
		"Custo Importacao"	,;	//03
		"Selo Inmetro"		,;	//04
		"Provisao Adm"		,;  //05
		"Imposto Benef"		,;	//06
		"Custo Logistico"	},;	//07
		{	40				,;	//cor entrega
			40				,;	//01
			100				,;	//02
			40				,;	//03
			40				,;	//04
			40				,; 	//05
			40				,;	//06
			40				},; //07
oDlg,,,,,{||},,oFont,,,,,.F.,,.T.,,.F.,,, )

aListBox1:={}

Aadd(aListBox1,{	.T.	,;	//cor entrega
					""	,;	//01
					""	,;	//02
					""	,;	//03
					""	,;	//04
					""	,;	//05
					""	,;	//06
					""	})	//07


oBrowse:bLine := {|| {		Iif((aListBox1[oBrowse:nAt][1]),oVerde,oVermelho) ,;
							aListBox1[oBrowse:nAT,02],;
							aListBox1[oBrowse:nAT,03],;
							aListBox1[oBrowse:nAT,04],;
							aListBox1[oBrowse:nAT,05],;
							aListBox1[oBrowse:nAT,06],;
							aListBox1[oBrowse:nAT,07],;
							aListBox1[oBrowse:nAT,08]}}


oBrowse:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNOVO2     บAutor  ณMicrosiga           บ Data ณ  06/28/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                      		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fListBox1(xAno, xMes, xProd1, xProd2, xGrupo1,xGrupo2,xTipo)
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

If Empty(xAno+xMes) //+xMes+xProd1+xProd2+xGrupo1+xGrupo2+xTipo)

	Aadd(aListBox1,{	.T.	,;	//cor entrega
						""	,;	//01
						""	,;	//02
						""	,;	//03
						""	,;	//04
						""	,;	//05
						""	,;	//06
						""	})	//07

	MsgInfo("Informe o Ano e Mes para Pesquisa!")

Else

	cQuery := " SELECT SB1.B1_COD, SB1.B1_DESC, B1_XFORUSO, SZP.ZP_CUSTIMP, SZP.ZP_CUSTSEL ,SZP.ZP_CUSTADM,SZP.ZP_IMPBENE, SZP.ZP_CUSTLOG "
	cQuery += " FROM "	+ RetSqlTab("SB1") + "  "
	cQuery += " LEFT JOIN "	+ RetSqlTab("SZP") + "  "
	cQuery += " ON SZP.ZP_FILIAL = '" +xFilial("SZP")	+ "' "
	cQuery += " AND SZP.ZP_ANO ='" + xAno + "' "
	cQuery += " AND SZP.ZP_MES ='" + xMes + "' "
	cQuery += " AND SZP.ZP_PRODUTO = SB1.B1_COD "
	cQuery += " AND SZP.D_E_L_E_T_ <>'*' "
	cQuery += " WHERE SB1.B1_FILIAL  = '" +xFilial("SB1")	+ "' "
	cQuery += " AND SB1.B1_COD >= '"+xProd1+"' "
	cQuery += " AND SB1.B1_COD <= '"+xProd2+"' "
	cQuery += " AND SB1.B1_GRUPO >= '"+xGrupo1+"' "
	cQuery += " AND SB1.B1_GRUPO <= '"+xGrupo2+"' "
	cQuery += " AND SB1.B1_TIPO = '"+xTipo+"' "
	cQuery += " AND SB1.D_E_L_E_T_ <>'*' "

	cQuery := 	ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), _cAlias,.F.,.T.)

	If (_cAlias)->(EOF())
		Aadd(aListBox1,{	.T.	,;	//Situacao
							""	,;	//01
							""	,;	//02
							""	,;	//03
							""	,;	//04
							""	,;	//05
							""	,;	//06
							""	})	//07
	Else

		While (_cAlias)->(!EOF())

			_oCorSit	:=.T.

			If	(_cAlias)->B1_XFORUSO == "S"
				 _oCorSit	:= .F.
			Endif

			// Carrege aqui sua array da Listbox
			Aadd(aListBox1,{	    _oCorSit				,;	//Situacao
									(_cAlias)->B1_COD		,;	//01 Produto
									(_cAlias)->B1_DESC		,;	//02 Descricao
									PadL(Transform((_cAlias)->ZP_CUSTIMP,"@E 999,999,999.9999"),16)	,;	//03 Custo de Importacao
									PadL(Transform((_cAlias)->ZP_CUSTSEL,"@E 999,999,999.9999"),16)	,;	//04 Selo Inmetro
									PadL(Transform((_cAlias)->ZP_CUSTADM,"@E 999,999,999.9999"),16)	,;	//05 Prov. Inmetro
									PadL(Transform((_cAlias)->ZP_IMPBENE,"@E 999,999,999.9999"),16)	,;	//06 Imposto Beneficio
									PadL(Transform((_cAlias)->ZP_CUSTLOG,"@E 999,999,999.9999"),16)	})	//07 Custo Logistico

	    	(_cAlias)->(DbSkip())
		End
	Endif
Endif

DbCloseArea(_cAlias)


 // Seta vetor para a browse
oBrowse:SetArray(aListBox1)


oBrowse:bLine := {|| {		Iif((aListBox1[oBrowse:nAt][1]),oVerde,oAmarelo) ,;
							aListBox1[oBrowse:nAT,02],;
							aListBox1[oBrowse:nAT,03],;
							aListBox1[oBrowse:nAT,04],;
							aListBox1[oBrowse:nAT,05],;
							aListBox1[oBrowse:nAT,06],;
							aListBox1[oBrowse:nAT,07],;
							aListBox1[oBrowse:nAT,08]}}

oBrowse:Refresh()

Return()




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTEAMCUST  บAutor  ณMicrosiga           บ Data ณ  07/19/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CustoEditar(xAno, xMes, xCod, xDesc, xCustImp, xCustSelo,xCustADM,xImpBenef,xCustLog)
Local oButton1
Local oButton2
Local oGet1
Local cGet1 := xAno
Local oGet2
Local cGet2 := xMes
Local oGet3
Local cGet3 := xCod
Local oGet4
Local cGet4 := xDesc
Local oGet5
Local cGet5 := xCustImp
Local oGet6
Local cGet6 := xCustSelo
Local oGet7
Local cGet7 := xCustADM
Local oGet8
Local cGet8 := xImpBenef
Local oGet9
Local cGet9 := xCustLog
Local oGroup1
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSay6
Local oSay7
Local oSay8
Local oSay9
Static oDlg2

  DEFINE MSDIALOG oDlg2 TITLE "Custo Mensal" FROM 000, 000  TO 350, 680 COLORS 0, 16777215 PIXEL

    @ 008, 007 GROUP oGroup1 TO 140, 331 OF oDlg2 COLOR 0, 16777215 PIXEL

    @ 020, 016 SAY oSay1 PROMPT "Ano" 									SIZE 025, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
    @ 032, 016 MSGET oGet1 VAR cGet1 									SIZE 023, 010 OF oDlg2 COLORS 0, 16777215 READONLY PIXEL
    @ 020, 043 SAY oSay2 PROMPT "Mes" 									SIZE 025, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
    @ 032, 043 MSGET oGet2 VAR cGet2 									SIZE 023, 010 OF oDlg2 COLORS 0, 16777215 READONLY PIXEL
    @ 020, 072 SAY oSay3 PROMPT "Produto" 								SIZE 025, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
    @ 032, 072 MSGET oGet3 VAR cGet3 									SIZE 060, 010 OF oDlg2 COLORS 0, 16777215 READONLY PIXEL
    @ 020, 136 SAY oSay4 PROMPT "Descricao" 							SIZE 025, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
    @ 032, 136 MSGET oGet4 VAR cGet4 									SIZE 184, 010 OF oDlg2 COLORS 0, 16777215 READONLY PIXEL
    @ 056, 016 SAY oSay5 PROMPT "Custo Importacao" 						SIZE 047, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
    @ 056, 072 MSGET oGet5 VAR cGet5 	Picture "@E 999,999,999.99"		SIZE 060, 010 OF oDlg2 COLORS 0, 16777215 PIXEL
    @ 072, 016 SAY oSay6 PROMPT "Selo Inmetro" 							SIZE 047, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
    @ 072, 071 MSGET oGet6 VAR cGet6 	Picture "@E 999,999,999.99" 	SIZE 060, 010 OF oDlg2 COLORS 0, 16777215 PIXEL
    @ 088, 016 SAY oSay7 PROMPT "Prov.Administrativa" 					SIZE 051, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
    @ 088, 071 MSGET oGet7 VAR cGet7 	Picture "@E 999,999,999.99" 	SIZE 060, 010 OF oDlg2 COLORS 0, 16777215 PIXEL
    @ 104, 016 SAY oSay8 PROMPT "%Imp.Beneficio" 						SIZE 043, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
    @ 104, 071 MSGET oGet8 VAR cGet8	Picture "@E 999.99"				SIZE 060, 010 OF oDlg2 COLORS 0, 16777215 PIXEL
    @ 120, 016 SAY oSay9 PROMPT "Custo Logistico" 						SIZE 050, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
    @ 120, 071 MSGET oGet9 VAR cGet9	Picture "@E 999,999,999.99"		SIZE 060, 010 OF oDlg2 COLORS 0, 16777215 PIXEL

    @ 148, 238 BUTTON oButton1 PROMPT "S&air" 	ACTION(oDlg2:End())		SIZE 037, 012 OF oDlg2 PIXEL
    @ 148, 285 BUTTON oButton2 PROMPT "&Salvar" ACTION(GrvSZP(cGet1,cGet2,cGet3,cGet5,cGet6,cGet7,cGet8,cGet9), oDlg2:End());
    																	SIZE 037, 012 OF oDlg2 PIXEL

  ACTIVATE MSDIALOG oDlg2 CENTERED

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTEAMCUST  บAutor  ณMicrosiga           บ Data ณ  07/19/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GrvSZP(xAno,xMes,xCod,xCustImp,xCustSelo,xCustProv,xImpBenef,xCustLog)
Local _lInclui	:= .T.

DbSelectArea("SZP")
DbSetOrder(1)
If DbSeek(xFilial("SZP")+xAno+xMes+xCod)
	_lInclui:= .F.
Endif

RecLock("SZP",_lInclui)

	SZP->ZP_ANO 	:=	xAno
	SZP->ZP_MES 	:=	xMes
	SZP->ZP_PRODUTO :=	xCod
	SZP->ZP_CUSTIMP	:=	xCustImp
	SZP->ZP_CUSTSEL	:=	xCustSelo
	SZP->ZP_CUSTADM	:=	xCustProv
	SZP->ZP_IMPBENE	:=	xImpBenef
	SZP->ZP_CUSTLOG	:=	xCustLog
SZP->(MsUnlock())


aListBox1[oBrowse:nAT,04]	:= xCustImp
aListBox1[oBrowse:nAT,05]	:= xCustSelo
aListBox1[oBrowse:nAT,06]	:= xCustProv
aListBox1[oBrowse:nAT,07]	:= xImpBenef
aListBox1[oBrowse:nAT,08]	:= xCustLog

 // Seta vetor para a browse
oBrowse:SetArray(aListBox1)



oBrowse:bLine := {|| {		Iif((aListBox1[oBrowse:nAt][1]),oVerde,oAmarelo) ,;
							aListBox1[oBrowse:nAT,02],;
							aListBox1[oBrowse:nAT,03],;
							aListBox1[oBrowse:nAT,04],;
							aListBox1[oBrowse:nAT,05],;
							aListBox1[oBrowse:nAT,06],;
							aListBox1[oBrowse:nAT,07],;
							aListBox1[oBrowse:nAT,08]}}

oBrowse:Refresh()


Return()



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTEAMCUST  บAutor  ณMicrosiga           บ Data ณ  07/19/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CopiaSZP()
Local oButton1
Local oButton2
Local oGet1
Local cGet1 := Space(4)
Local oGet2
Local cGet2 := Space(2)
Local oGet3
Local cGet3 := Space(4)
Local oGet4
Local cGet4 := Space(2)
Local oGroup1
Local oGroup2
Local oGroup3
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Static oDlg3

  DEFINE MSDIALOG oDlg3 TITLE "Copia de Tabela" FROM 000, 000  TO 330, 530 COLORS 0, 16777215 PIXEL

    @ 008, 003 GROUP oGroup3 TO 152, 252 OF oDlg3 COLOR 0, 16777215 PIXEL

    @ 020, 016 GROUP oGroup1 TO 074, 197 PROMPT "|    Tabela Original    |" OF oDlg3 COLOR 0, 16777215 PIXEL
    @ 035, 036 SAY oSay1 PROMPT "Informe o Ano de Refer๊ncia" 			SIZE 076, 007 OF oDlg3 COLORS 0, 16777215 PIXEL
    @ 035, 116 MSGET oGet1 VAR cGet1 									SIZE 060, 010 OF oDlg3 COLORS 0, 16777215 PIXEL
    @ 051, 036 SAY oSay2 PROMPT "Informe o M๊s de Refer๊ncia" 			SIZE 073, 007 OF oDlg3 COLORS 0, 16777215 PIXEL
    @ 051, 116 MSGET oGet2 VAR cGet2 									SIZE 060, 010 OF oDlg3 COLORS 0, 16777215 PIXEL

	@ 083, 016 GROUP oGroup2 TO 137, 197 PROMPT "|    Tabela Destino    |" OF oDlg3 COLOR 0, 16777215 PIXEL
    @ 096, 036 SAY oSay3 PROMPT "Informe o Ano de Destino" 				SIZE 069, 007 OF oDlg3 COLORS 0, 16777215 PIXEL
    @ 096, 116 MSGET oGet3 VAR cGet3 									SIZE 060, 010 OF oDlg3 COLORS 0, 16777215 PIXEL
    @ 113, 036 SAY oSay4 PROMPT "Informe o M๊s de Destino" 				SIZE 072, 007 OF oDlg3 COLORS 0, 16777215 PIXEL
	@ 113, 116 MSGET oGet4 VAR cGet4 									SIZE 060, 010 OF oDlg3 COLORS 0, 16777215 PIXEL

    @ 023, 205 BUTTON oButton1 PROMPT "&Copiar" ACTION(CONFCOPIA(cGet1, cGet2, cGet3, cGet4),oDlg3:End());
    											 						SIZE 037, 012 OF oDlg3 PIXEL
    @ 043, 205 BUTTON oButton2 PROMPT "&Sair" 	ACTION(oDlg3:End())		SIZE 037, 012 OF oDlg3 PIXEL

  ACTIVATE MSDIALOG oDlg3 CENTERED

Return

Static Function CONFCOPIA(xAno, xMes, xAnoDest, xMesDest)


	If MsgYesNo("Confirma copia da tabela?")
		Processa({|lEnd| GRAVAREG(xAno, xMes, xAnoDest, xMesDest)},"Copiando Registro...")
	EndIf

Return (.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTEAMCUST  บAutor  ณMicrosiga           บ Data ณ  07/19/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GRAVAREG(xAno, xMes, xAnoDest, xMesDest)
Local cQuery		:= ""
Local _cAlias		:= GetNextAlias()
Local _lInclui		:= .T.

If Empty(xAno) .OR. Empty(xMes) //+xMes+xProd1+xProd2+xGrupo1+xGrupo2+xTipo)
	MsgInfo("Informe o Ano e Mes de Referencia!")
ElseIf Empty(xAnoDest) .OR. Empty(xMesDest) //+xMes+xProd1+xProd2+xGrupo1+xGrupo2+xTipo)
	MsgInfo("Informe o Ano e Mes de Destino!")
ElseIf (xAno+xMes) == (xAnoDest+xMesDest)  //+xMes+xProd1+xProd2+xGrupo1+xGrupo2+xTipo)
	MsgInfo("Ano/Mes de Ref๊ncia nao pode ser igual Ano/Mes de Destino!")
Else

	cQuery := " SELECT SZP.ZP_ANO, SZP.ZP_MES, SZP.ZP_PRODUTO, SZP.ZP_CUSTIMP, SZP.ZP_CUSTSEL ,SZP.ZP_CUSTADM,SZP.ZP_IMPBENE, SZP.ZP_CUSTLOG "
	cQuery += " FROM "	+ RetSqlTab("SZP") + "  "
	cQuery += " Where SZP.ZP_FILIAL = '" +xFilial("SZP")	+ "' "
	cQuery += " AND SZP.ZP_ANO ='" + xAno + "' "
	cQuery += " AND SZP.ZP_MES ='" + xMes + "' "
	cQuery += " AND SZP.D_E_L_E_T_ <>'*' "

	cQuery := 	ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), _cAlias,.F.,.T.)

	If (_cAlias)->(EOF())
    	MsgInfo("Nใo foram encontrados registro neste perํodo!!")
	Else
		ProcRegua((_cAlias)->(RecCount()))

		While (_cAlias)->(!EOF())

          	IncProc()

			_lInclui:= .T.
			DbSelectArea("SZP")
			DbSetOrder(1)
			If DbSeek(xFilial("SZP")+xAnoDest+ xMesDest+(_cAlias)->ZP_PRODUTO)
				_lInclui:= .F.
			Endif

			RecLock("SZP",_lInclui)
				SZP->ZP_ANO 	:=	xAnoDest
				SZP->ZP_MES 	:=	xMesDest
				SZP->ZP_PRODUTO := 	(_cAlias)->ZP_PRODUTO
				SZP->ZP_CUSTIMP	:=  (_cAlias)->ZP_CUSTIMP
				SZP->ZP_CUSTSEL	:= 	(_cAlias)->ZP_CUSTSEL
				SZP->ZP_CUSTADM	:= 	(_cAlias)->ZP_CUSTADM
				SZP->ZP_IMPBENE	:=	(_cAlias)->ZP_IMPBENE
				SZP->ZP_CUSTLOG	:=	(_cAlias)->ZP_CUSTLOG
			SZP->(MsUnlock())


	    	(_cAlias)->(DbSkip())
		End
	Endif
Endif

DbCloseArea(_cAlias)
MsgInfo("Processamento concluํdo!!!")

Return()


Static Function AtuPeriodo(xAno, xMes)
Local oButton1
Local oButton2
Local oGet1
Local cGet1 := xAno
Local oGet2
Local cGet2 := xMes
Local oGet8
Local cGet8 := 0
Local oGet9
Local cGet9 := 0
Local oGroup1
Local oSay1
Local oSay2
Local oSay3
Local oSay8
Local oSay9
Static oDlg4

If Empty(xAno+xMes)
	Return
Endif

  DEFINE MSDIALOG oDlg4 TITLE "Atualiza็ใo de Valores" FROM 000, 000  TO 270, 360 COLORS 0, 16777215 PIXEL

    @ 019, 016 SAY oSay3 PROMPT "Esta rotina atualiza os valores do periodo selecionado." SIZE 142, 007 OF oDlg4 COLORS 0, 16777215 PIXEL

    @ 010, 006 GROUP oGroup1 TO 108, 164 OF oDlg4 COLOR 0, 16777215 PIXEL

    @ 032, 016 SAY oSay1 PROMPT "Ano" 										SIZE 025, 007 OF oDlg4 COLORS 0, 16777215 PIXEL
    @ 032, 043 SAY oSay2 PROMPT "Mes"										SIZE 025, 007 OF oDlg4 COLORS 0, 16777215 PIXEL
    @ 044, 016 MSGET oGet1 VAR cGet1 										SIZE 023, 010 OF oDlg4 COLORS 0, 16777215 READONLY PIXEL
    @ 044, 043 MSGET oGet2 VAR cGet2 										SIZE 023, 010 OF oDlg4 COLORS 0, 16777215 READONLY PIXEL

    @ 064, 016 SAY oSay8 PROMPT "%Imp.Beneficio" 							SIZE 043, 007 OF oDlg4 COLORS 0, 16777215 PIXEL
    @ 064, 074 MSGET oGet8 VAR cGet8	Picture "@E 999.99"					SIZE 060, 010 OF oDlg4 COLORS 0, 16777215 PIXEL

    @ 083, 017 SAY oSay9 PROMPT "Custo Logistico" 							SIZE 050, 007 OF oDlg4 COLORS 0, 16777215 PIXEL
    @ 083, 074 MSGET oGet9 VAR cGet9	Picture "@E 999,999,999.99"			SIZE 060, 010 OF oDlg4 COLORS 0, 16777215 PIXEL

    @ 112, 108 BUTTON oButton1 PROMPT "S&air" 		ACTION(oDlg4:End()) 	SIZE 037, 012 OF oDlg4 PIXEL
    @ 112, 061 BUTTON oButton2 PROMPT "&Salvar" 	ACTION(AtuMes2(cGet1,cGet2, cGet8, cGet9),oDlg4:End());
    																		SIZE 037, 012 OF oDlg4 PIXEL


  ACTIVATE MSDIALOG oDlg4 CENTERED

Return


Static Function AtuMes(xAno, xMes)
	If MsgYesNo("Confirma atualiza็ใo dos valores para o perํodo?")
		Processa({|lEnd| GRAVAREG(xAno, xMes, xAnoDest, xMesDest)},"Copiando Registro...")
	EndIf
Return

Static Function AtuMes2(xAno, xMes, xImpBenef, xCustLogist)
	If MsgYesNo("Confirma atualiza็ใo dos valores para o perํodo?")
		Processa({|lEnd| ATUSZP2(xAno, xMes, xImpBenef, xCustLogist)},"Atualizando Registro...")
	EndIf
Return



Static Function ATUSZP2(xAno, xMes, xImpBenef, xCustLogist)

Local cQuery		:= ""
Local _cAlias		:= GetNextAlias()
Local _lInclui		:= .T.
Local nCont			:= 0

If Empty(xAno) .OR. Empty(xMes) //+xMes+xProd1+xProd2+xGrupo1+xGrupo2+xTipo)
	MsgInfo("Informe o Ano e Mes de Referencia!")
Else

/*
	cQuery := " SELECT SZP.ZP_ANO, SZP.ZP_MES, SZP.ZP_PRODUTO, SZP.ZP_CUSTIMP, SZP.ZP_CUSTSEL ,SZP.ZP_CUSTADM,SZP.ZP_IMPBENE, SZP.ZP_CUSTLOG "
	cQuery += " FROM "	+ RetSqlTab("SZP") + "  "
	cQuery += " Where SZP.ZP_FILIAL = '" +xFilial("SZP")	+ "' "
	cQuery += " AND SZP.ZP_ANO ='" + xAno + "' "
	cQuery += " AND SZP.ZP_MES ='" + xMes + "' "
	cQuery += " AND SZP.D_E_L_E_T_ <>'*' "

	cQuery := 	ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), _cAlias,.F.,.T.)

	If (_cAlias)->(EOF())
*/

	If Len(aListBox1)==0

    	MsgInfo("Nใo foram encontrados registro neste perํodo!!")
	Else
		ProcRegua(Len(aListBox1))

		For nCont:=1 to Len(aListBox1)
          	IncProc()

			DbSelectArea("SZP")
			DbSetOrder(1)
			If DbSeek(xFilial("SZP")+xAno+xMes+aListBox1[nCont][2])
				RecLock("SZP",.F.)
					SZP->ZP_IMPBENE	:=	xImpBenef
					SZP->ZP_CUSTLOG	:=	xCustLogist
				SZP->(MsUnlock())
			Else
				RecLock("SZP",.T.)
					SZP->ZP_ANO 	:=	xAno
					SZP->ZP_MES 	:=	xMes
					SZP->ZP_PRODUTO :=	aListBox1[nCont][2]
					SZP->ZP_IMPBENE	:=	xImpBenef
					SZP->ZP_CUSTLOG	:=	xCustLogist
				SZP->(MsUnlock())
			Endif
		Next
	Endif
Endif

DbCloseArea(_cAlias)
MsgInfo("Processamento concluํdo!!!")

Return



