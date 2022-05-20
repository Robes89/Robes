#INCLUDE "PSACD090.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APVT100.CH"

#DEFINE WMSV09001 "WMSV09001"
#DEFINE WMSV09002 "WMSV09002"
#DEFINE WMSV09003 "WMSV09003"
#DEFINE WMSV09004 "WMSV09004"
#DEFINE WMSV09005 "WMSV09005"
#DEFINE WMSV09006 "WMSV09006"
#DEFINE WMSV09007 "WMSV09007"
#DEFINE WMSV09008 "WMSV09008"
#DEFINE WMSV09009 "WMSV09009"
#DEFINE WMSV09010 "WMSV09010"
#DEFINE WMSV09011 "WMSV09011"
#DEFINE WMSV09012 "WMSV09012"
#DEFINE WMSV09013 "WMSV09013"
#DEFINE WMSV09014 "WMSV09014"
#DEFINE WMSV09015 "WMSV09015"
#DEFINE WMSV09016 "WMSV09016"
#DEFINE WMSV09017 "WMSV09017"
#DEFINE WMSV09018 "WMSV09018"
#DEFINE WMSV09019 "WMSV09019"
#DEFINE WMSV09020 "WMSV09020"
#DEFINE WMSV09021 "WMSV09021"
#DEFINE WMSV09022 "WMSV09022"
#DEFINE WMSV09023 "WMSV09023"
#DEFINE WMSV09024 "WMSV09024"
#DEFINE WMSV09025 "WMSV09025"
#DEFINE WMSV09026 "WMSV09026"
#DEFINE WMSV09027 "WMSV09027"
#DEFINE WMSV09028 "WMSV09028"
#DEFINE WMSV09029 "WMSV09029"
#DEFINE WMSV09030 "WMSV09030"

#define WMSA32009 "WMSA32009"
#define WMSA32010 "WMSA32010"
#define WMSA32011 "WMSA32011"
#define WMSA32012 "WMSA32012"
#define WMSA32029 "WMSA32029"

Static __WV090VLP  := ExistBlock("WV090VLP")
Static __WV090VLQ  := ExistBlock("WV090VLQ")
Static __cWmsLcEx  := SuperGetMV('MV_WMSLCEX',.F.,'') // Local de excesso
Static __cWmsEnEx  := SuperGetMV('MV_WMSENEX',.F.,"") // Endereço de excesso
Static __lUnitiza  := .F.
Static oMntUniItem := Nil
Static __QtExcUni  := 0
//------------------------------------------------------------
/*/{Protheus.doc} PSACD090
Clone WMSV090 - Conferencia de recebimento de documentos de entrada.
@author alexsander.correa / Thiago Meschiatti 
@since 01/04/2015 / 20/03/2018
@version 1.0
/*/
//------------------------------------------------------------
User Function PSACD090()
Local cKey09    := VtDescKey(09)
Local cKey15    := VtDescKey(15)
Local cKey24    := VtDescKey(24)
Local bkey09    := VTSetKey(09)
Local bkey15    := VTSetKey(15)
Local bkey24    := VTSetKey(24)
Local lRet      := .T.
Local aEmbarque := {}
Local cEmbarque := Space(Len(DCZ->DCZ_EMBARQ))
Local lWmsCRD := SuperGetMV("MV_WMSCRD",.F.,.F.)

	If !IntWMS() .And. !lWmsCRD
		WMSVTAviso(WMSV09015,STR0034) // Permitida utilização somente com Integração com o WMS (MV_INTWMS) ou integração com a conferência de recebimento WMS (MV_WMSCRD)!
		Return
	EndIf

	// Avalia se os parâmetros estão preenchidos e informa o usuário
//	PSA320Par()

	While .T.
		// Bloqueia Tecla Estorno
		VTSetKey(24)
		cEmbarque := Space(Len(DCZ->DCZ_EMBARQ))
		VtClear()
		WMSVTCabec(STR0001,.F.,.F.,.T.) // Conferência
		@ 01,00  VTSay STR0036 //Recebimento:
		@ 02, 00 VTGet cEmbarque Valid VldEmb(@cEmbarque)
		VTRead()
		If VTLastKey() == 27
			Exit
		EndIf
		If Empty(cEmbarque)
			LoadCofRec(@aEmbarque)
			If Empty(aEmbarque)
				WMSVTAviso(WMSV09001,STR0002) // Não existem conferências de recebimento pendentes para execução.
				VtKeyboard(Chr(20))
				lRet := .F.
				Exit
			Else
				VtClearBuffer()
				WMSVTCabec(STR0001,.F.,.F.,.T.) // Conferência
				nPos:=VTaBrowse(1,,,,{STR0003},aEmbarque,{20}) // Recebimento

				If VTLastKey() == 27
					Exit
				EndIf
				cEmbarque:= aEmbarque[nPos,1]
			EndIf
		EndIf
		// Efetua a conferencia dos produtos deste embarque
		If lRet
			VTSetKey(24,{|| CofPrdLot(cEmbarque,.T.)}, STR0004) // Estorno
			CofPrdLot(cEmbarque)
		EndIf
	EndDo
	// Restaura as teclas de talhao
	VTSetKey(09,bkey09,cKey09)
	VTSetKey(15,bkey15,cKey15)
	VTSetKey(24,bkey24,cKey24)
Return
/*--------------------------------------------------------------------------------
---LoadCofRec
---Monta embarques disponíveis para conferencia
---Alexsander Correa - 01/04/2015
---aEmbarque, Array (aEmbarque - codigo embarque, Caracter
                               - data geraçã0, Data)
----------------------------------------------------------------------------------*/
Static Function LoadCofRec(aEmbarque)
Local cQuery    := ""
Local cAliasDCW := GetNextAlias()
	aEmbarque := {}
	cQuery := "SELECT DCW_EMBARQ, DCW_DATGER"
	cQuery +=  " FROM "+RetSqlName("DCW")
	cQuery += " WHERE DCW_FILIAL = '"+xFilial('DCW')+"'"
	cQuery +=   " AND DCW_SITEMB IN ('1','3','4','5')"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDCW,.F.,.T.)
	TCSetField(cAliasDCW,'DCW_DATGER','D',)
	While !(cAliasDCW)->( Eof() )
		Aadd(aEmbarque,{(cAliasDCW)->DCW_EMBARQ,DTOC((cAliasDCW)->DCW_DATGER)})
		(cAliasDCW)->( DBSkip() )
	EndDo
	(cAliasDCW)->( DBCloseArea() )
Return .T.
/*--------------------------------------------------------------------------------
---CofPrdLot
---Permite efetuar a conferência dos produtos de um processo
---até que o usuário escolha a opção de finalizar a conferência.
---Jackson Patrick Werka - 01/04/2015
---cEmbarque, character, (cEmbarque do conferencia de recebimento)
---lEstorno, Logico, (Indica se é estorno)
----------------------------------------------------------------------------------*/
Static Function CofPrdLot(cEmbarque,lEstorno)
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local lWMSConf  := SuperGetMV('MV_WMSCONF',.F.,.F.)
Local cWmsUMI   := ""
Local cCodBar   := ""
Local cProduto  := ""
Local cPrdOri   := ""
Local cPrdAnt   := ""
Local cLoteCtl  := ""
Local cNumLote  := ""
Local cArmazem  := ""
Local cEndereco := ""
Local cTipUni  := ""
Local cIdUnit   := ""
Local cPictQt   := ""
Local cUM       := ""
Local cDscUM    := ""
Local nQtConf   := 0.00
Local nItem     := 0.00
Local lEncerra  := .F.
Local lAbandona := .F.
Local lPergunta := .F.
Local lWmsNew   := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local nAviso    := 0
Local cKey09    := VtDescKey(09)
Local cKey15    := VtDescKey(15)
Local cKey21    := VtDescKey(21)
// Ativa teclas de atalho
Local bkey09    := VTSetKey(9, {|| ShowPrdCof(cEmbarque)}, STR0016) // Produto
Local bkey15    := VTSetKey(15,{|| ShowOpeCof(cEmbarque)}, STR0014) // Operador
Local bkey21    := VTSetKey(21)
Local nPos      := 0
Local nLin      := 0
Local cAliasQry := ""
Local cAliasD11 := ""
Local nCont     := 0
Local lNewUnit  := .T.
Local lDetProd  := SuperGetMV('MV_WMSVSTC',.F.,.F.) // Apresenta descricao e norma do produto no coletor RF

Default lEstorno := .F.
	While !lEncerra .And. !lAbandona
		cArmazem  := Space(Len(DCZ->DCZ_LOCAL))
		cEndereco := Space(TamSX3("BE_LOCALIZ")[1])
		If WmsX212118("D0R")
			cTipUni   := Space(TamSX3("D0R_CODUNI")[1])
			cIdUnit   := Space(TamSX3("D0R_IDUNIT")[1])
		EndIf
		nQtConf   := 0.00

		//   01234567890123456789
		// 0 ____Conferência_____
		// 1 Recebimento: 000000
		// 2 Informe o Armazém
		// 3 01
		// 4 Informe o Endereço
		// 5 DOCA
		WMSVTCabec(STR0001+Iif(lEstorno,' '+STR0004,''),.F.,.F.,.T.) // Conferência
		@ 01,00  VtSay STR0003 + ': ' + cEmbarque // Recebimento
		@ 02,00  VTSay STR0039 // Informe o Armazém
		@ 03,00  VtGet cArmazem Picture "@!" Valid ValidArm(cEmbarque,cArmazem)
		VtRead
		If VTLastKey() != 27 .And. (__lUnitiza .Or. lDetProd)
			@ 04,00  VTSay STR0040 // Informe o Endereço
			@ 05,00  VtGet cEndereco Picture "@!" Valid ValidEnd(cEmbarque,cArmazem,cEndereco)
			VtRead
		EndIf
		If VTLastKey()==27
			If !lEstorno
				nAviso := WMSVTAviso(WMSV09002,STR0010,{STR0012,STR0013}) // Deseja encerrar a conferencia? // Encerrar // Interromper
			Else
				Exit
			EndIf
			If nAviso == 1
				lEncerra := .T.
			ElseIf nAviso == 2
				lAbandona  := .T.
			Else
				Loop
			EndIf
		EndIf
		//   01234567890123456789
		// 0 ____Conferência_____
		// 1 Recebimento: 000000
		// 2 Informe o Untiz
		// 3 000001
		// 4 Tipo Unitz
		// 5 123456
		If !lEncerra .And. !lAbandona .And. __lUnitiza
			// Seta o armazém e endereço
			If oMntUniItem == Nil
				oMntUniItem := WMSDTCMontagemUnitizadorItens():New()
			EndIf
			oMntUniItem:oUnitiz:SetArmazem(cArmazem)
			oMntUniItem:oUnitiz:SetEnder(cEndereco)
			lNewUnit := .T.
			// Solicita o unitizador a ser conferido
			If !GetUniti(cEmbarque,cArmazem,@cIdUnit,@cTipUni,lEstorno,@lNewUnit)
				If !lEstorno
					nAviso := WMSVTAviso(WMSV09002,STR0010,{STR0012,STR0013}) // Deseja encerrar a conferencia? // Encerrar // Interromper
				Else
					Exit
				EndIf
				If nAviso == 1
					lEncerra := .T.
				ElseIf nAviso == 2
					lAbandona  := .T.
				Else
					Loop
				EndIf
			Else
				VTSetKey(21,{|| GetUniti(cEmbarque,cArmazem,@cIdUnit,@cTipUni,lEstorno,@lNewUnit)}, STR0043) // Ctrl+U // Unitizador
				VTSetKey(09,{|| ShowItens(cIdUnit)}, STR0044) // Ctrl+I // Itens Unitiz.
			EndIf
		EndIf

		While !lEncerra .And. !lAbandona
			//   01234567890123456789
			// 0 ____Conferência_____
			// 1 Recebimento: 000000
			// 2 Unitizador: UN0001
			// 3 Informe o Produto
			// 4 PA1
			// 5 Lote: AUTO000636
			// 6 Sub-Lote: 000000
			// 7 Informe a Qtde
			// 8               240.00
			VtClear()
			VtClearBuffer()
			lNewUnit  := .F.
			cCodBar   := Space(128)
			cProduto  := Space(Len(DCZ->DCZ_PROD))
			cPrdOri   := Space(Len(DCZ->DCZ_PRDORI))
			cLoteCtl  := Space(Len(DCZ->DCZ_LOTE))
			cNumLote  := Space(Len(DCZ->DCZ_SUBLOT))
			lPergunta := .F.
			nCont     := 0
			nLin      := 1
			WMSVTCabec(STR0001+Iif(lEstorno,' '+STR0004,''),.F.,.F.,.T.) // Conferência
			@ nLin++,00  VtSay STR0003 + ': ' + cEmbarque // Recebimento
			If __lUnitiza
				If Len(cIdUnit) == 6
					@ nLin++,00  VtSay STR0045 + cIdUnit // Unitizador:
				ElseIf Len(cIdUnit) <= 16
					@ nLin++,00  VtSay "ID: " + cIdUnit // Unitizador:
				Else
					@ nLin++,00  VtSay cIdUnit // Unitizador:
				EndIf
			EndIf
			@ nLin++,00  VTSay STR0005 // Informe o Produto
			@ nLin++,00  VtGet cCodBar Picture "@!" Valid ValidPrdLot(cEmbarque,cArmazem,cEndereco,@cProduto,@cLoteCtl,@cNumLote,@nQtConf,@cCodBar,lEstorno)
			// Descricao do Produto com tamanho especifico.
			VtRead()
			If VTLastKey()==27
				If lNewUnit
					Loop
				Else
					Exit
				EndIf
			EndIf

			If !lEncerra .And. !lAbandona

				dbSelectArea('DCW')
				DCW->(dbSetOrder(1))//DCW_FILIAL+DCW_EMBARQ
				DCW->( dbSeek(xFilial('DCW')+cEmbarque) )

				// Se tiver espaço na tela suficiente ele mostra o sub-lote na mesma tela
				If Rastro(cProduto)
					@ nLin,00  VtSay STR0037 // Lote
					@ nLin++,06  VtGet cLoteCtl Picture "@!" When VTLastKey()==05 .Or. Empty(cLoteCtl) Valid !Empty(cLoteCtl)
					//Solicita lote apenas quando a conferência for de Pré-Nota
					If DCW->DCW_TPCONF == "2" .And. Rastro(cProduto,"S")
						@ nLin,00 VTSay STR0038 // Sub-Lote
						@ nLin++,10 VTGet cNumLote Picture "@!" When VTLastKey()==05 .Or. Empty(cNumLote) Valid !Empty(cNumLote)
					EndIf
					VtRead()
				EndIf

				If VTLastKey()==27
					Loop // Volta para o inicio do produto
				EndIf
			EndIf
			If !lEncerra .And. !lAbandona
				// Forca selecionar unidade de medida se informou produto diferente ou a cada leitura do codigo do produto
				If cProduto <> cPrdAnt .Or. lWMSConf
					//  Carrega unidade de medida, simbolo da unidade e quantidade na unidade
					WmsValUM(@Nil,;    // Quantidade movimento
							@cWmsUMI,;  // Unidade parametrizada
							cProduto)   // Produto

					//  Seleciona unidade de medida
					WmsSelUM(cWmsUMI,; // Unidade parametrizada
							@cUM,;      // Unidade medida reduzida
							@cDscUM,;   // Descrição unidade medida
							Nil,;       // Quantidade movimento
							@nItem,;    // Item seleção unidade
							@cPictQt,;  // Mascara unidade medida
							Nil,;       // Quantidade no item seleção unidade
							.T.,;       // Indica se é uma conferência
							STR0001,;   // Descrição da tarefa
							Nil,;       // Armazem
							Nil,;       // Endereço
							cProduto,;  // Produto Origem
							cProduto,;  // Produto
							cLoteCtl,;  // Lote
							cNumLote)   // sub-lote
					If (VTLastKey()==27)
						Loop
					EndIf
				EndIf
				cPrdAnt := cProduto
			EndIf
			If !lEncerra .And. !lAbandona
				cPrdOri := cProduto
				// Verificar se produto existe na DCY como produto e componente ao mesmo tempo
				cQuery := " SELECT DCYA.DCY_PRDORI,"
				cQuery +=        " DCYA.DCY_PROD,"
				cQuery +=        " DCYA.DCY_LOTE,"
				cQuery +=        " DCYA.DCY_SUBLOT"
				cQuery +=   " FROM "+RetSqlName('DCY')+" DCYA"
				cQuery +=  " WHERE DCYA.DCY_FILIAL = '"+xFilial('DCY')+"'"
				cQuery +=    " AND DCYA.DCY_EMBARQ = '"+cEmbarque+"'"
				cQuery +=    " AND DCYA.DCY_PROD = '"+cProduto+"'"
				cQuery +=    " AND DCYA.DCY_LOTE = '"+cLoteCtl+"'"
				cQuery +=    " AND DCYA.DCY_SUBLOT = '"+cNumLote+"'"
				cQuery +=    " AND EXISTS (SELECT DCYB.DCY_PRDORI"
				cQuery +=                  " FROM "+RetSqlName('DCY')+" DCYB"
				cQuery +=                 " WHERE DCYB.DCY_FILIAL = '"+xFilial('DCY')+"'"
				cQuery +=                   " AND DCYB.DCY_EMBARQ = DCYA.DCY_EMBARQ"
				cQuery +=                   " AND DCYB.DCY_PROD = DCYA.DCY_PROD"
				cQuery +=                   " AND DCYB.DCY_PRDORI  <> DCYA.DCY_PRDORI"
				cQuery +=                   " AND DCYB.DCY_LOTE = DCYA.DCY_LOTE"
				cQuery +=                   " AND DCYB.DCY_SUBLOT = DCYA.DCY_SUBLOT"
				cQuery +=                   " AND DCYB.DCY_LOCAL = DCYA.DCY_LOCAL"
				cQuery +=                   " AND DCYB.D_E_L_E_T_ = ' ')"
				cQuery +=    " AND DCYA.D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				cAliasQry := GetNextAlias()
				dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
				If (cAliasQry)->(!Eof())
					lPergunta := .T.
				EndIf
				(cAliasQry)->(dbCloseArea())
				//Verifica se já possui na DCY como produto parte
				If lWmsNew .And. !lEstorno .And. !lPergunta
					cQuery := "SELECT DCY.DCY_PRDORI,"
					cQuery +=       " DCY.DCY_PROD"
					cQuery +=  " FROM "+RetSqlName("DCY")+" DCY"
					cQuery += " WHERE DCY.DCY_FILIAL = '"+xFilial("DCY")+"'"
					cQuery +=   " AND DCY.DCY_EMBARQ = '"+cEmbarque+"'"
					cQuery +=   " AND DCY.DCY_PROD   = '"+cProduto+"'"
					cQuery +=   " AND DCY.DCY_LOTE   = '"+cLoteCtl+"'"
					cQuery +=   " AND DCY.DCY_SUBLOT = '"+cNumLote+"'"
					cQuery +=   " AND DCY.D_E_L_E_T_ = ' '"
					cQuery := ChangeQuery(cQuery)
					cAliasQry := GetNextAlias()
					dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
					If (cAliasQry)->(!Eof())
						If (cAliasQry)->DCY_PRDORI <> (cAliasQry)->DCY_PROD
							cPrdOri := (cAliasQry)->DCY_PRDORI
						EndIf
					EndIf
					(cAliasQry)->(dbCloseArea())
				EndIf
				If lWmsNew .And. !lEstorno .And. cPrdOri == cProduto
					cQuery := "SELECT D11.D11_PRDORI"
					cQuery +=  " FROM "+RetSqlName("D11")+" D11"
					cQuery += " WHERE D11.D11_FILIAL = '"+xFilial("D11")+"'"
					cQuery +=   " AND D11.D11_PRDCMP = '"+cProduto+"'"
					cQuery +=   " AND D11.D_E_L_E_T_ = ' '"
					cQuery := ChangeQuery(cQuery)
					cAliasD11 := GetNextAlias()
					dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD11,.F.,.T.)
					If (cAliasD11)->(!Eof())
						cPrdOri := (cAliasD11)->D11_PRDORI
						lPergunta := .T.
					EndIf
					(cAliasD11)->(dbCloseArea())
				EndIf
				If lPergunta
					If WMSVTAviso(WMSV09005,STR0032, {STR0016 ,STR0031}) == 1
						cPrdOri := cProduto
					EndIf
				EndIf
				If VTLastKey()==27
					Loop
				EndIf
				// Validações do produto quando o armazém controla unitizador
				If  __lUnitiza
					oMntUniItem:SetPrdOri(cPrdOri)
					oMntUniItem:SetProduto(cProduto)
					oMntUniItem:SetLoteCtl(cLoteCtl)
					oMntUniItem:SetNumLote(cNumLote)
					oMntUniItem:SetUsaD0Q(.F.)
					If !oMntUniItem:VldPrdUni(lEstorno)
						WMSVTAviso(WMSV09029,oMntUniItem:GetErro())
						Loop
					EndIf
				EndIf
				If VTLastKey()==27
					Loop
				EndIf
				If (nLin + 1) > VTMaxRow()
					@ nLin,00 VTSay STR0011+': '
					@ nLin,Len(STR0011+': ') VTGet nQtConf Picture cPictQt When Empty(nQtConf) Valid ValidQtd(cEmbarque,__cUserID,cPrdOri,cProduto,cLoteCtl,cNumLote,@nQtConf,lEstorno,nItem,cArmazem)
				Else
					@ nLin++,00 VTSay PadR(STR0011+' '+cDscUM,VTMaxCol())
					@ nLin++,00 VTGet nQtConf Picture cPictQt When Empty(nQtConf) Valid ValidQtd(cEmbarque,__cUserID,cPrdOri,cProduto,cLoteCtl,cNumLote,@nQtConf,lEstorno,nItem,cArmazem)
				EndIf
				VTRead()
				If VTLastKey()==27 .Or. QtdComp(nQtConf) == 0
					Loop
				EndIf
			EndIf
			// Somente grava a quantidade se o usuário não cancelar
			If !lEncerra .And. !lAbandona
				VTMsg(STR0033) // Processando...
				GravCofOpe(cEmbarque,__cUserID,cPrdOri,cProduto,cLoteCtl,cNumLote,nQtConf,lEstorno,cArmazem,cEndereco,cIdUnit,cTipUni)
			EndIf
			// Se for estorno, sai ao executar a primeira vez
			If lEstorno
				Exit
			EndIf
		EndDo
		// Se o usuário optou por encerrar, deve verificar se pode ser finalizado a conferência
		If lEncerra
			lEncerra := FinCofRec(cEmbarque)
		EndIf
	EndDo
	// Restaura teclas
	VTSetKey(09,bkey09,cKey09)
	VTSetKey(15,bkey15,cKey15)
	VTSetKey(21,bkey21,cKey21)
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return
/*--------------------------------------------------------------------------------
---ShowPrdCof
---Apresenta produtos da conferencia
---Alexsander.Correa - 01/04/2015
---cEmbarque, character, (cEmbarque do conferencia de recebimento)
----------------------------------------------------------------------------------*/
Static Function ShowPrdCof(cEmbarque)
Local lRet     := .T.
Local aProduto := {}
Local aTelaAnt := VTSave(00, 00, VTMaxRow(), VTMaxCol())
	DCY->( dbSetOrder(1) )
	DCY->( dbSeek(xFilial('DCY')+cEmbarque) )
	While !DCY->( Eof() ) .And.;
			 DCY->DCY_FILIAL == xFilial('DCY') .And.;
			 DCY->DCY_EMBARQ == cEmbarque
		If QtdComp(DCY->DCY_QTCONF) > 0
			Aadd(aProduto,{IIf(DCY->DCY_QTORIG <> DCY->DCY_QTCONF,'*',' '),DCY->DCY_PROD,Posicione('SB1',1,xFilial('SB1')+DCY->DCY_PROD,'SB1->B1_DESC'),DCY->DCY_LOTE,DCY->DCY_SUBLOT,DCY->DCY_QTCONF})
		EndIf
		DCY->( dbSkip() )
	EndDo
	VtClearBuffer()
	WMSVTCabec(STR0001,.F.,.F.,.T.) // Produto
	nPos:=VTaBrowse(1,,,,{' ',STR0016,STR0017,STR0018,STR0019,STR0020},aProduto,{1,TamSx3("DCY_PROD")[1],30,TamSx3("DCY_LOTE")[1],TamSx3("DCY_SUBLOT")[1],11})//Produto|Descrição|Lote|Sub-Lote|Qtde Conferida
	VTKeyBoard(chr(20))
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---ShowOpeCof
---Apresenta os operados dos produtos conferidos
---Alexsander.Correa - 01/04/2015
---cEmbarque, character, (cEmbarque do conferencia de recebimento)
----------------------------------------------------------------------------------*/
Static Function ShowOpeCof(cEmbarque)
Local lRet      := .T.
Local cQuery    := ""
Local cAliasDCZ := GetNextAlias()
Local aOperador := {}
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
	// Movimento do SF1
	cQuery := " SELECT DISTINCT DCZ_OPER, DCD_NOMFUN "
	cQuery +=   " FROM "+RetSqlName("DCZ")+ " DCZ,"+RetSqlName("DCD")+" DCD"
	cQuery +=  " WHERE DCZ_FILIAL ='"+xFilial("DCZ")+"'"
	cQuery +=    " AND DCZ_EMBARQ = '" + cEmbarque +"'"
	cQuery +=    " AND DCZ.D_E_L_E_T_ = ' '"
	cQuery +=    " AND DCD_FILIAL = '"+xFilial("DCD")+"'"
	cQuery +=    " AND DCD_CODFUN = DCZ_OPER"
	cQuery +=    " AND DCD.D_E_L_E_T_ = ' '"
	cQuery +=  " ORDER BY DCZ_OPER"
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDCZ,.F.,.T.)
	While !(cAliasDCZ)->( Eof() )
		AAdd(aOperador,{(cAliasDCZ)->DCZ_OPER,(cAliasDCZ)->DCD_NOMFUN})
		(cAliasDCZ)->( DBSkip() )
	EndDo
	(cAliasDCZ)->( DBCloseArea() )

	If Empty(aOperador)
		WMSVTAviso(WMSV09003,STR0030) // Nao foi realizada nenhuma conferencia por nenhum operador.
		VtKeyboard(Chr(20))
		lRet := .F.
	Else
		VtClearBuffer()
		WMSVTCabec(STR0001,.F.,.F.,.T.) // Conferência
		nPos:=VTaBrowse(1,,,,{STR0014,STR0015},aOperador,{TamSx3("DCZ_OPER")[1],30}) // Operador // Nome
		VTKeyBoard(chr(20))
	EndIf
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---ValidPrdLot
---Valida o produto informado, verificando se o mesmo pertence a alguma
---distribuição de separação que está pendente ou em andamento
---Jackson Patrick Werka - 01/04/2015
---cEmbarque, character, (Embarque da conferência de recebimento)
---cArmazem, character, (Armazem no qual o produto se encontra)
---cEndereco, character, (Endereco no qual o produto se encontra)
---cProduto, character, (Produto informado)
---cLoteCtl, character, (Lote etiqueta)
---cNumLote, character, (Sub-lote etiqueta)
---nQtde, numerico, (Quantidade etiqueta)
---cCodBar, character, (Codigo de barras)
----------------------------------------------------------------------------------*/
Static Function ValidPrdLot(cEmbarque,cArmazem,cEndereco,cProduto,cLoteCtl,cNumLote,nQtde,cCodBar)
Local lRet     := .T.
Local lRetPE   := .T.
Local aTelaAnt := VTSave(00, 00, VTMaxRow(), VTMaxCol())

	lRet := !Empty(cCodBar)
	If lRet
		lRet := WMSValProd(Nil,@cProduto,@cLoteCtl,@cNumLote,@nQtde,@cCodBar)
		nQtde:= 0.00
	EndIf
	// Ponto de entrada para validações complementares do produto
	If lRet .And. __WV090VLP
		lRetPE := ExecBlock("WV090VLP",.F.,.F.,{cEmbarque,cProduto,cLoteCtl,cNumLote,nQtde})
		If ValType(lRetPE) == "L"
			lRet := lRetPE
		EndIf
	EndIf

	If lRet
		// Monta tela produto
		WmsMontPrd(Nil,;     // Unidade parametrizada
		           .T.,;       // Indica se é uma conferência
		           STR0001,;   // Descrição da tarefa
		           cArmazem,;  // Armazem
		           cEndereco,; // Endereço
		           cProduto,;  // Produto Origem
		           cProduto,;  // Produto
		           cLoteCtl,;  // Lote
		           cNumLote)   // sub-lote
	EndIf
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---ValidQtd
---Valida a digitação da quantidade
---Alexsander.Correa - 01/04/2015
---cEmbarque, character, (Embarque do conferencia de recebimento)
---cCodOpe, character, (Operador da  conferencia de recebimento)
---cPrdOri, character, (Produto origem da  conferencia de recebimento)
---cProduto, character, (Produto da conferencia de recebimento)
---cLoteCtl, character, (Lote do produto da conferencia de recebimento)
---cNumLote, character, (Sub-lote do lote do produto da conferencia de recebimento)
---nQtConf, numérico, (Quantidade conferida)
---lEstorno, Lógico, (Indica se é um estorno)
----------------------------------------------------------------------------------*/
Static Function ValidQtd(cEmbarque,cCodOpe,cPrdOri,cProduto,cLoteCtl,cNumLote,nQtConf,lEstorno,nItem,cArmazem)
Local lRet      := .T.
Local lRetPE    := .T.
Local cQuery    := ""
Local cAliasDCY := ""
Local nQuant    := 0
Local nQtdAnt   := nQtConf
Local nI
Local lWmsNew   := SuperGetMv("MV_WMSNEW",.F.,.F.)
	If QtdComp(nQtConf) <= 0
		Return .F.
	EndIf
	// Converter de 2a.UM p/ 1a.UM
	If nItem == 2
		nQtConf := ConvUm(cProduto,0,nQtConf,1)
	EndIf
	//Validações do quantidade que será inserida no unitizador
	If __lUnitiza
		If !(lRet := oMntUniItem:VldQtdSld(nQtConf,lEstorno))
			WMSVTAviso(WMSV09021,oMntUniItem:GetErro()) // Erro do objeto
		EndIf
	EndIf
	If lRet .And. lWmsNew .And. !lEstorno
		lRet := GeraExcesso(cEmbarque,cLoteCtl,cNumLote,cArmazem,@nQtConf,cProduto,cPrdOri,cCodOpe)
	EndIf
	If lRet .And. lEstorno
		DCZ->( dbSetOrder(1) )
		cAliasDCY := GetNextAlias()
		cQuery := " SELECT DCY.DCY_PRDORI, DCY.DCY_PROD"
		If lWmsNew
			cQuery += " , D11.D11_QTMULT "
		EndIf
		cQuery += " FROM "+RetSqlName("DCY")+" DCY"
		If lWmsNew
			cQuery += " , "+RetSqlName("D11")+" D11"
		EndIf
		cQuery += " WHERE DCY.DCY_FILIAL = '"+xFilial("DCY")+"'"
		cQuery += " AND DCY.DCY_EMBARQ = '"+cEmbarque+"'"
		cQuery += " AND DCY.DCY_PRDORI = '"+cProduto+"'"
		cQuery += " AND DCY.DCY_PRDORI <> DCY_PROD"
		cQuery += " AND DCY.DCY_LOTE = '"+cLoteCtl+"'"
		cQuery += " AND DCY.DCY_SUBLOT = '"+cNumLote+"'"
		cQuery += " AND DCY.D_E_L_E_T_ = ''"
		If lWmsNew
			cQuery += " AND D11.D11_FILIAL = '"+xFilial("D11")+"'"
			cQuery += " AND D11.D11_PRDORI = DCY_PRDORI"
			cQuery += " AND D11.D11_PRDCMP = DCY_PROD"
			cQuery += " AND D11.D_E_L_E_T_ = ''"
		EndIf
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDCY,.F.,.T.)
		If (cAliasDCY)->(!Eof() )
			While (cAliasDCY)->(!Eof() )
			 	nQuant := IIf(lWmsNew, nQtConf * (cAliasDCY)->D11_QTMULT, nQtConf)
				If !DCZ->( dbSeek(xFilial('DCZ')+cEmbarque+cCodOpe+(cAliasDCY)->DCY_PRDORI+(cAliasDCY)->DCY_PROD+cLoteCtl+cNumLote) )
					WMSVTAviso(WMSV09006,STR0022) // Não existe qtd conferida para este operador/produto.
					VtKeyboard(Chr(20))
					lRet := .F.
					Exit
				Else
					If QtdComp(nQuant) > QtdComp(DCZ->DCZ_QTCONF)
						WMSVTAviso(WMSV09007,STR0023) // Quantidade à estornar maior que a qtd conferida.
						VtKeyboard(Chr(20))
						lRet := .F.
						Exit
					EndIf
				EndIf
				(cAliasDCY)->(dbSkip())
			EndDo
		Else
			If !DCZ->( dbSeek(xFilial('DCZ')+cEmbarque+cCodOpe+cPrdOri+cProduto+cLoteCtl+cNumLote) )
				WMSVTAviso(WMSV09006,STR0022) // Não existe qtd conferida para este operador/produto.
				VtKeyboard(Chr(20))
				lRet := .F.
			Else
				If QtdComp(nQtConf) > QtdComp(DCZ->DCZ_QTCONF)
					WMSVTAviso(WMSV09007,STR0023) // Quantidade à estornar maior que a qtd conferida.
					VtKeyboard(Chr(20))
					lRet := .F.
				EndIf
			EndIf
		EndIf
		(cAliasDCY)->(dbCloseArea())
	EndIf
	// Ponto de entrada para validações complementares de quantidade
	If lRet .And. !lEstorno .And. __WV090VLQ
		lRetPE := ExecBlock("WV090VLQ",.F.,.F.,{cEmbarque,cProduto,cLoteCtl,cNumLote,nQtConf})
		If ValType(lRetPE) == "L"
			lRet := lRetPE
		EndIf
	EndIf
	//Se retornou falso retorna para a unidade que o usuário informou para mostrar em tela
	If !lRet
		nQtConf := nQtdAnt
	EndIf
Return lRet
/*--------------------------------------------------------------------------------
---GravCofOpe
---Grava conferencia
---Alexsander.Correa - 01/04/2015
---cEmbarque, character, (Embarque do conferencia de recebimento)
---cCodOpe, character, (Operador da  conferencia de recebimento)
---cPrdOri, character, (Produto origem da  conferencia de recebimento)
---cProduto, character, (Produto da conferencia de recebimento)
---cLoteCtl, character, (Lote do produto da conferencia de recebimento)
---cNumLote, character, (Sub-lote do lote do produto da conferencia de recebimento)
---nQtConf, numérico, (Quantidade conferida)
---lEstorno, Lógico, (Indica se é um estorno)
----------------------------------------------------------------------------------*/
Static Function GravCofOpe(cEmbarque,cCodOpe,cPrdOri,cProduto,cLoteCtl,cNumLote,nQtConf,lEstorno,cArmazem,cEndereco,cIdUnit,cTipUni)
Local aProdComp  := {}
Local nQtConfPai := 0
Local nI         := 0
Local oProdComp  := Nil
Local lRet       := .T.
Local lWmsNew    := SuperGetMV("MV_WMSNEW",.F.,.F.)
	// Verifica situação do embarque
	DCW->( dbSetOrder(1) )
	If DCW->( dbSeek(xFilial('DCW')+cEmbarque) )
		If DCW->DCW_SITEMB $ '6|7'
			WMSVTAviso(WMSV09008,STR0024) // Conferência já finalizada por outro processo!
			VtKeyboard(Chr(20))
			lRet := .F.
		EndIf
	Else
		WMSVTAviso(WMSV09009,STR0025) // Número recebimento informado não cadastrado.
		lRet := .F.
	EndIf
	If lRet
		Begin Transaction
			If lWmsNew
				// Grava array apenas de produtos conferidos
				oProdComp := WMSDTCProdutoComponente():New()
				oProdComp:SetProduto(cPrdOri)
				oProdComp:SetPrdOri(cPrdOri)
				oProdComp:EstProduto()
				aProdComp := oProdComp:GetArrProd()

				//Tratamentos para gravar ou estornar unitizador.
				If __lUnitiza
					If !lEstorno
						For nI := 1 To Len(aProdComp)
							If (cProduto == aProdComp[nI][1]) .Or. (cProduto == aProdComp[nI][3])
								oMntUniItem:oUnitiz:SetIdUnit(cIdUnit)
								oMntUniItem:oUnitiz:SetTipUni(cTipUni)
								oMntUniItem:SetProduto(aProdComp[nI][1])
								oMntUniItem:SetPrdOri(aProdComp[nI][3])
								oMntUniItem:SetLoteCtl(cLoteCtl)
								oMntUniItem:SetNumLote(cNumLote)
								oMntUniItem:SetQuant(IIf(cProduto == aProdComp[nI][3],(nQtConf * aProdComp[nI][2]),nQtConf))
								oMntUniItem:oUnitiz:SetStatus('5')
								If !oMntUniItem:IsDad()
									oMntUniItem:AssignD0S()
								EndIf
							EndIf
						Next nI
						__QtExcUni := 0
					Else
						For nI := 1 To Len(aProdComp)
							WMSA320EST(cEmbarque,aProdComp[nI][3],aProdComp[nI][1],cLoteCtl,cNumLote,cIdUnit,cCodOpe,.F.,IIf(cProduto == aProdComp[nI][3],(nQtConf * aProdComp[nI][2]),nQtConf))
						Next nI
					EndIf
				EndIf

				//Calcula a quantidade do produto pai, quando o produto informado for um filho
				nQtConfPai := CalcQtdConf(nQtConf,cPrdOri,cProduto,cLoteCtl,cNumLote,cArmazem,cEmbarque)
			Else
				aAdd(aProdComp,{cProduto,1,cProduto})
			EndIf

			//Realiza rateio da quantidade origem das linhas da DCY e grava registros
			RateioConf(lEstorno,cEmbarque,aProdComp,cProduto,cPrdOri,cLoteCtl,cNumLote,cArmazem,cIdUnit,cCodOpe,nQtConfPai,nQtConf)

			// Atualiza informações embarque
			lRet := A320COFDCY(cEmbarque,.F.,lEstorno)
			If !lRet
				DisarmTransaction()
				WMSVTAviso(WMSV09010,STR0026) // Não foi possível registrar a quantidade.
			EndIf
		End Transaction
	EndIf
Return lRet
/*--------------------------------------------------------------------------------
---RateioConf
---Realiza rateio da quantidade origem e grava DCY/DCZ
---Amanda Rosa Vieira
----------------------------------------------------------------------------------*/
Static Function RateioConf(lEstorno,cEmbarque,aProdComp,cProduto,cPrdOri,cLoteCtl,cNumLote,cArmazem,cIdUnit,cCodOpe,nQtConfPai,nQtConf)
Local nI         := 1
Local nDiferenca := 0
Local nQtdOri    := 0
Local lContinua  := .T.
Local lRet       := .T.
	//Ajusta DCY e DCZ
	For nI := 1 To Len(aProdComp)
		If !lEstorno
			nDiferenca := 0
			//Ajusta DCY
			If !DCY->( dbSeek(xFilial('DCY')+cEmbarque+aProdComp[nI][3]+aProdComp[nI][1]+cLoteCtl+cNumLote+cArmazem) )
				//Zera quantidade origem
				nQtdOri := 0
				//Caso não seja uma conferência de excesso e não tenha encontrado uma linha da DCY correspondente ao lote,
				//procura sem o lote e então desconta a quantidade origem para criar uma nova linha na DCY
				If DCY->( dbSeek(xFilial('DCY')+cEmbarque+aProdComp[nI][3]+aProdComp[nI][1]+Space(TamSX3("DCY_LOTE")[1])+Space(TamSX3("DCY_SUBLOT")[1])+cArmazem) )
					RecLock('DCY',.F.)
					DCY->DCY_QTORIG -= (nQtConfPai*aProdComp[nI][2])
					DCY->(MsUnLock())
					nQtdOri := nQtConfPai*aProdComp[nI][2]
				EndIf
				RecLock('DCY',.T.)
				DCY->DCY_FILIAL := xFilial('DCY')
				DCY->DCY_EMBARQ := cEmbarque
				DCY->DCY_PRDORI := aProdComp[nI][3]
				DCY->DCY_PROD   := aProdComp[nI][1]
				DCY->DCY_LOTE   := cLoteCtl
				DCY->DCY_SUBLOT := cNumLote
				DCY->DCY_LOCAL  := cArmazem
				DCY->DCY_QTORIG := nQtdOri
				If (cProduto == aProdComp[nI][1]) .Or. (cProduto == aProdComp[nI][3])
					DCY->DCY_QTCONF := IIf(cProduto == aProdComp[nI][3],(nQtConf * aProdComp[nI][2]),nQtConf)
				Else
					DCY->DCY_QTCONF := 0
				EndIf
				DCY->(MsUnLock())
			Else
				nQtdOri :=  nQtConfPai*aProdComp[nI][2]
				nQtdOri := IIF(QtdComp(nQtdOri) > QtdComp(DCY->DCY_QTORIG),nQtdOri,DCY->DCY_QTORIG)
				nDiferenca := IIF(nQtdOri  > DCY->DCY_QTORIG,nQtdOri - DCY->DCY_QTORIG,0)
				RecLock('DCY',.F.)
				If (cProduto == aProdComp[nI][1]) .Or. (cProduto == aProdComp[nI][3])
					DCY->DCY_QTCONF += IIf(cProduto== aProdComp[nI][3],(nQtConf * aProdComp[nI][2]),nQtConf)
				EndIf
				DCY->DCY_QTORIG := nQtdOri
				DCY->(MsUnLock())
				//Verifica se a quantidade origem aumentou
				If QtdComp(nDiferenca) > 0
					//Ajusta quantidade origem da linha da DCY que não possui lote informado
					If DCY->(dbSeek(xFilial('DCY')+cEmbarque+aProdComp[nI][3]+aProdComp[nI][1]+Space(TamSX3("DCY_LOTE")[1])+Space(TamSX3("DCY_SUBLOT")[1])+cArmazem) )
						RecLock('DCY',.F.)
						DCY->DCY_QTORIG -= nDiferenca
						DCY->(MsUnLock())
					EndIf
				EndIf
			EndiF

			lContinua := .F.
			If cProduto <> cPrdOri
				If cProduto == aProdComp[nI][1]
					lContinua := .T.
				EndIf
			Else
				lContinua := .T.
			EndIf
		EndIf

		//Ajusta DCZ
		If lContinua
			If DCZ->( dbSeek(xFilial('DCZ')+cEmbarque+cCodOpe+aProdComp[nI][3]+aProdComp[nI][1]+cLoteCtl+cNumLote+cArmazem+cIdUnit) )
				RecLock('DCZ', .F.)
				If lEstorno
					DCZ->DCZ_QTCONF -= IIf(cProduto == aProdComp[nI][3],(nQtConf * aProdComp[nI][2]),nQtConf)
				Else
					DCZ->DCZ_QTCONF += IIf(cProduto == aProdComp[nI][3],(nQtConf * aProdComp[nI][2]),nQtConf)
				EndIf
				DCZ->(MsUnLock())
			Else
				RecLock('DCZ',.T.)
				DCZ->DCZ_FILIAL := xFilial('DCZ')
				DCZ->DCZ_EMBARQ := cEmbarque
				DCZ->DCZ_OPER   := cCodOpe
				DCZ->DCZ_PRDORI := aProdComp[nI][3]
				DCZ->DCZ_PROD   := aProdComp[nI][1]
				DCZ->DCZ_LOTE   := cLoteCtl
				DCZ->DCZ_SUBLOT := cNumLote
				DCZ->DCZ_QTCONF := IIf(cProduto == aProdComp[nI][3],(nQtConf * aProdComp[nI][2]),nQtConf)
				DCZ->DCZ_LOCAL  := cArmazem
				If __lUnitiza
					DCZ->DCZ_IDUNIT := cIdUnit
				EndIf
				DCZ->(MsUnLock())
			EndIf
		EndIf
	Next nI
Return lRet
/*--------------------------------------------------------------------------------
---FinCofRec
---Verifica/Finaliza conferencia de embarque
---Alexsander.Correa - 01/04/2015
---cEmbarque, character, (Embarque do conferencia de recebimento)
----------------------------------------------------------------------------------*/
Static Function FinCofRec(cEmbarque)
Local aAreaDCW := DCW->( GetArea() )
Local lRet     := .T.
Local aBoxDCW  := RetSx3Box(Posicione('SX3',2,'DCW_SITEMB','X3CBox()'),,,1)
	DCW->( dbSetOrder(1) )
	If DCW->( dbSeek(xFilial('DCW')+cEmbarque) )
		WMSVTCabec(STR0001,.F.,.F.,.T.)
		@ Int(VTMaxRow()/2), 00 VtSay STR0033 // Processando...
		If PS320FiCo(.F.)
			//   01234567890123456789
			// 0 ____Conferência_____
			// 1 Recebimento: 000000
			// 2 --------------------
			// 3 Conferido
			// 4 --------------------
			VtClear()
			WMSVTCabec(STR0001,.F.,.F.,.T.) // Conferência
			//Mostra Dados
			@ 01,00  VTSay STR0003 + ': ' + cEmbarque // Embarque
			@ 02,00  VTSay Replicate('-',VTMaxCol())
			@ 03,00  VtSay aBoxDCW[Val(DCW->DCW_SITEMB) , 3 ]
			@ 04,00  VTSay Replicate('-',VTMaxCol())
			WMSVTRodPe()
		Else
			WMSVTAviso(WMSV09013,STR0029) // Não foi possível finalizar a conferência.
			lRet := .F.
		EndIf
	Else
		WMSVTAviso(WMSV09014,STR0025) // Número recebimento informado não cadastrado.
		lRet := .F.
	EndIf
	RestArea(aAreaDCW)
Return lRet
//-------------------------------------------------
// Valida número do embarque
//-------------------------------------------------
Static Function VldEmb(cEmbarque)
Local cQuery    := ""
Local cAliasDCW := GetNextAlias()
Local lRet      := .T.
	//Se o número do embarque está vazio retorna true para que mostre a lista de embarques pendentes
	If Empty(cEmbarque)
		Return .T.
	EndIf
	cQuery := "SELECT DCW_EMBARQ"
	cQuery +=  " FROM "+RetSqlName("DCW")
	cQuery += " WHERE DCW_FILIAL = '"+xFilial('DCW')+"'"
	cQuery +=   " AND DCW_EMBARQ = '"+cEmbarque+"'"
	cQuery +=   " AND DCW_SITEMB IN ('1','3','4','5')"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDCW,.F.,.T.)
	If (cAliasDCW)->(Eof())
		WMSVTAviso(WMSV09016,STR0035) //Não existe conferência de recebimento pendentes com o código informado.
		VtKeyboard(Chr(20))
		lRet := .F.
	EndIf
	(cAliasDCW)->( DBCloseArea() )
Return lRet
//-------------------------------------------------
// Valida o armazém informado
//-------------------------------------------------
Static Function ValidArm(cEmbarque,cArmazem)
Local lRet      := .T.
Local cQuery    := ""
Local cAliasDCY := ""
	NNR->(dbSetOrder(1))
	If NNR->(dbSeek(xFilial("NNR")+cArmazem))
		__lUnitiza := WmsArmUnit(cArmazem)
	Else
		WmsMessage(STR0046,WMSV09024) // Armazem inválido!
		lRet := .F.
	EndIf
	If lRet
		cQuery := " SELECT DCY_LOCAL"
		cQuery +=   " FROM "+RetSqlName('DCY')+" DCY"
		cQuery +=  " WHERE DCY_FILIAL = '"+xFilial('DCY')+"'"
		cQuery +=    " AND DCY_EMBARQ = '"+cEmbarque+"'"
		cQuery +=    " AND DCY_LOCAL  = '"+cArmazem+"'"
		cQuery +=    " AND D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasDCY := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCY,.F.,.T.)
		If (cAliasDCY)->(EoF())
			WMSVTAviso(WMSV09017,WmsFmtMsg(STR0047,{{"[VAR01]",cArmazem}})) // Não há conferência prevista para o armazém [VAR01].
			lRet := .F.
		EndIf
		(cAliasDCY)->(DbCloseArea())
	EndIf
	If !lRet
		VtKeyboard(Chr(20))
	EndIf
Return lRet
//-------------------------------------------------
// Valida o endereço informado
//-------------------------------------------------
Static Function ValidEnd(cEmbarque,cArmazem,cEndereco)
Local lRet     := .T.
Local cQuery   := ""
Local cAliasSD1:= ""
	SBE->(DbSetOrder(1)) //BE_FILIAL+BE_LOCAL+BE_LOCALIZ
	If !SBE->(DbSeek(xFilial('SBE')+cArmazem+cEndereco))
		WmsMessage(STR0048,WMSV09018) // Endereço inválido!
		lRet := .F.
	Else
		If DLTipoEnd(SBE->BE_ESTFIS) != 5
			WmsMessage(STR0049,WMSV09022) // Somente endereços de estrutura do tipo box/doca podem ser informados!
			lRet := .F.
		EndIf
	EndIf
	If lRet .And. cArmazem <> __cWmsLcEx
		cQuery := " SELECT SD1.D1_ENDER"
		cQuery +=   " FROM "+RetSqlName('DCX')+" DCX"
		cQuery +=  " INNER JOIN "+RetSqlName('SD1')+" SD1"
		cQuery +=     " ON SD1.D1_FILIAL  = '"+xFilial('SD1')+"'"
		cQuery +=    " AND SD1.D1_DOC     = DCX.DCX_DOC"
		cQuery +=    " AND SD1.D1_SERIE   = DCX.DCX_SERIE"
		cQuery +=    " AND SD1.D1_FORNECE = DCX.DCX_FORNEC"
		cQuery +=    " AND SD1.D1_LOJA    = DCX.DCX_LOJA"
		cQuery +=    " AND SD1.D1_LOCAL   = '"+cArmazem+"'"
		cQuery +=    " AND (SD1.D1_ENDER  = '"+cEndereco+"' OR"
		cQuery +=         " SD1.D1_ENDER  = '"+Space(TamSX3("D1_ENDER")[1])+"')"
		cQuery +=    " AND SD1.D_E_L_E_T_ = ' '"
		cQuery +=  " WHERE DCX.DCX_FILIAL = '"+xFilial('DCX')+"'"
		cQuery +=    " AND DCX.DCX_EMBARQ = '"+cEmbarque+"'"
		cQuery +=    " AND DCX.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasSD1 := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSD1,.F.,.T.)
		If (cAliasSD1)->(EoF())
			WmsMessage(WmsFmtMsg(STR0050,{{"[VAR01]",cArmazem},{"[VAR02]",cEndereco}}),WMSV09023) // Não existe conferência de recebimento prevista para o armazém [VAR01] e endereço [VAR02]!
			lRet := .F.
		EndIf
		(cAliasSD1)->(DbCloseArea())
	EndIf
	If !lRet
		VtKeyboard(Chr(20))
	EndIf
Return lRet
//-------------------------------------------------
// Valida o id do unitizador informado
//-------------------------------------------------
Static Function ValidUnitz(cEmbarque,cArmazem,cIdUnit,cTipUni,lEstorno)
Local lRet := .T.
Default lEstorno := .F.
	If Empty(cIdUnit)
		lRet := .F.
	EndIf
	If lRet
		oMntUniItem:SetIdUnit(cIdUnit)
		oMntUniItem:SetUsaD0Q(.F.)
		If !oMntUniItem:VldIdUnit(2,@cTipUni,lEstorno)
			If !Empty(oMntUniItem:GetErro())
				WMSVTAviso(WMSV09019,oMntUniItem:GetErro())
				VtKeyboard(Chr(20))
			EndIf
			lRet := .F.
		EndIf
		If lRet .And. !lEstorno .And. !WMSA320VUN(cEmbarque,cIdUnit)
			WMSVTAviso(WMSV09027,WmsFmtMsg(STR0061,{{"[VAR01]",cIdUnit}})) // O unitizador [VAR01] está sendo utilizado por outro processo.
			VtKeyboard(Chr(20))
			lRet := .F.
		EndIf
	EndIf
Return lRet
//-------------------------------------------------
// Valida o tipo do unitizador informado
//-------------------------------------------------
Static Function ValidTpUni(cTipUni)
Local lRet        := .T.
	oMntUniItem:oUnitiz:SetTipUni(cTipUni)
	oMntUniItem:SetUsaD0Q(.F.)
	If !oMntUniItem:VldTipUni()
		If !Empty(oMntUniItem:GetErro())
			WmsMessage(oMntUniItem:GetErro(),WMSV09025)
			VtKeyboard(Chr(20))
		EndIf
		lRet := .F.
	EndIf
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} GeraExcesso
Valida se está sendo conferida quantidade excedente.
@author  Amanda Rosa Vieira
@version P12
@since   24/04/2017
/*/
//----------------------------------------------------------
Static Function GeraExcesso(cEmbarque,cLoteCtl,cNumLote,cLocal,nQtdInf,cPrdConf,cPrdOri,cCodOpe)
Local cAliasDCY := GetNextAlias()
Local cProduto  := ""
Local nI        := 1
Local nQtdExc   := 0
Local nQtdConf  := 0
Local nSaldoPai := nQtdInf
Local nQtdExcPrd:= 0
Local nPos      := 0
Local lRet      := .T.
Local lArmExcUni:= WmsArmUnit(__cWmsLcEx) //Identifica se armazém de excesso possui controle de unitizador.
Local lArmExcDif:= !(__cWmsLcEx == cLocal) //Indica se o armazém de excesso é diferente do armazém 'normal'
Local aProdComp := {}
Local aExcesso  := {}
Local aTela     := VtSave()
Local oProdComp := WMSDTCProdutoComponente():New()
Local aCab, aSize

	oProdComp:SetPrdOri(cPrdOri)
	If oProdComp:LoadData(3)
		oProdComp:EstProduto()
		aProdComp:= oProdComp:GetArrProd()
	Else
		aAdd(aProdComp,{cPrdConf,1,cPrdConf})
	EndIf

	For nI := 1 To Len(aProdComp)
		If cPrdConf == aProdComp[nI][3] .Or. cPrdConf == aProdComp[nI][1]
			//Calcula quantidade saldo disponível para conferência
			cQuery := " SELECT SUM(DCY_QTORIG - DCY_QTCONF) DCY_SALDO"
			cQuery +=   " FROM "+RetSqlName('DCY')+" DCY"
			cQuery +=  " WHERE DCY.DCY_FILIAL = '"+xFilial('DCY')+"'"
			cQuery +=    " AND DCY.DCY_EMBARQ = '"+cEmbarque+"'"
			cQuery +=    " AND DCY.DCY_PRDORI = '"+aProdComp[nI][3]+"'"
			cQuery +=    " AND DCY.DCY_PROD = '"+aProdComp[nI][1]+"'"
			cQuery +=    " AND (DCY.DCY_LOTE = '"+cLoteCtl+"' OR"
			cQuery +=         " DCY.DCY_LOTE = '"+Space(TamSX3("DCY_LOTE")[1])+"')"
			cQuery +=    " AND (DCY.DCY_SUBLOT = '"+cNumLote+"' OR"
			cQuery +=         " DCY.DCY_SUBLOT = '"+Space(TamSX3("DCY_SUBLOT")[1])+"')"
			cQuery +=    " AND DCY.DCY_LOCAL  = '"+cLocal+"'"
			cQuery +=    " AND DCY.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDCY,.F.,.T.)
			If (cAliasDCY)->(!EoF())
				//Quantidade conferida
				nQtdConf := nQtdInf
				If cPrdConf == aProdComp[nI][3]
					nQtdConf := nQtdInf*aProdComp[nI][2]
					//Grava saldo do produto pai, o qual é o menor dos saldos encontrados para os filhos
					nSaldoPai:= IIF(QtdComp(nSaldoPai) > QtdComp((cAliasDCY)->DCY_SALDO),(cAliasDCY)->DCY_SALDO,nSaldoPai)
				EndIf
				//Calcula quantidade do excesso
				If QtdComp((cAliasDCY)->DCY_SALDO) > 0
					If QtdComp((cAliasDCY)->DCY_SALDO) < QtdComp(nQtdConf)
						nQtdExc := nQtdConf - (cAliasDCY)->DCY_SALDO
					EndIf
				Else
					//Se não encontrou quantidade na DCY, toda a quantidade será jogada em excesso
					nQtdExc := nQtdConf
				EndIf
				//Verifica se há quantidade excedente, para criar as DCY de excesso.
				If QtdComp(nQtdExc) > 0
					Aadd(aExcesso,{aProdComp[nI][1],nQtdExc,aProdComp[nI][3],cLoteCtl,cNumLote,__cWmsLcEx}) //Produto|Quantidade|Prd. Origem|Lote|Sub-Lote|Armazém
				EndIf
			EndIf
			(cAliasDCY)->(DbCloseArea())
		EndIf
	Next nI
	If Len(aExcesso) > 0
		If lArmExcUni .And. lArmExcDif
			//Faz tela de pergunta
			aCab  := {STR0051,STR0052,STR0053,STR0054,STR0055,STR0056} //Produto|Quantidade|Prd. Origem|Lote|Sub-Lote|Armazém
			aSize := {TamSx3("DCY_PROD")[1],TamSx3("DCY_QTCONF")[1],TamSx3("DCY_PRDORI")[1],TamSx3("DCY_LOTE")[1],TamSx3("DCY_SUBLOT")[1],TamSx3("DCY_LOCAL")[1]}
			VTClear()
			WMSVTAviso(WMSV09028,STR0062) //Conferência de produto em excesso.A quantidade excedente ficará pendente de conferência.
			WMSVTCabec(STR0057,.F.,.F.,.T.) //Conferir Excesso
			VTaBrowse(1,0,(VTMaxRow()-1),VTMaxCol(),aCab,aExcesso,aSize)
			VTKeyBoard(Chr(20))
		EndIF
		If VTLastKey() == 27
			VtRestore(,,,,aTela)
			Return .F.
		EndIf

		// Cria itens na DCY
		DCY->(dbSetOrder(1))
		For nI := 1 To Len(aProdComp)
			cProduto := aProdComp[nI][1]
			//Quando o armazém de excesso não for unitizado grava a quantidade conferida,
			//caso contrário o produto ficará pendente de conferência no armazém de excesso para montagem do unitizador.
			If lArmExcUni .And. lArmExcDif
				nQtdExcPrd := 0
			Else
				nPos := aScan(aExcesso, {|x| x[1]+x[3] == cProduto+cPrdOri})
				nQtdExcPrd := Iif(nPos == 0,0,aExcesso[nPos][2])
			EndIf
			//Grava excesso das partes
			If !DCY->(dbSeek(xFilial('DCY')+cEmbarque+cPrdOri+cProduto+cLoteCtl+cNumLote+__cWmsLcEx))
				RecLock('DCY',.T.)
				DCY->DCY_FILIAL := xFilial('DCY')
				DCY->DCY_EMBARQ := cEmbarque
				DCY->DCY_PROD   := cProduto
				DCY->DCY_PRDORI := cPrdOri
				DCY->DCY_LOTE   := cLoteCtl
				DCY->DCY_SUBLOT := cNumLote
				DCY->DCY_QTORIG := 0
				DCY->DCY_QTCONF := nQtdExcPrd
				DCY->DCY_LOCAL  := __cWmsLcEx
				DCY->(MsUnlock())
			ElseIf (!lArmExcUni .Or. !lArmExcDif) .And. QtdComp(nQtdExcPrd) > 0
				RecLock('DCY',.F.)
				DCY->DCY_QTCONF += nQtdExcPrd
				DCY->(MsUnlock())
			EndIf
			//Grava DCZ para a quantidade conferida no armazém de excesso.
			If (!lArmExcUni .Or. !lArmExcDif) .And. QtdComp(nQtdExcPrd) > 0
				If DCZ->(dbSeek(xFilial('DCZ')+cEmbarque+cCodOpe+aProdComp[nI][3]+aProdComp[nI][1]+cLoteCtl+cNumLote+__cWmsLcEx) )
					RecLock('DCZ', .F.)
					DCZ->DCZ_QTCONF += IIf(cProduto == aProdComp[nI][3],(nQtdExcPrd * aProdComp[nI][2]),nQtdExcPrd)
					DCZ->(MsUnLock())
				Else
					RecLock('DCZ',.T.)
					DCZ->DCZ_FILIAL := xFilial('DCZ')
					DCZ->DCZ_EMBARQ := cEmbarque
					DCZ->DCZ_OPER   := cCodOpe
					DCZ->DCZ_PRDORI := aProdComp[nI][3]
					DCZ->DCZ_PROD   := aProdComp[nI][1]
					DCZ->DCZ_LOTE   := cLoteCtl
					DCZ->DCZ_SUBLOT := cNumLote
					DCZ->DCZ_QTCONF := IIf(cProduto == aProdComp[nI][3],(nQtdExcPrd * aProdComp[nI][2]),nQtdExcPrd)
					DCZ->DCZ_LOCAL  := __cWmsLcEx
					// Caso o armazém de excesso seja igual ao normal, atribui o mesmo unitizador conferido
					If !lArmExcDif
						DCZ->DCZ_IDUNIT := oMntUniItem:GetIdUnit()
					EndIf
					DCZ->(MsUnLock())
				EndIf
			EndIf
		Next nI
		//Calcula quantidade conferida do produto pai
		//Gera DCY para produto pai
		cQuery := " SELECT CASE WHEN(MIN(DCY.DCY_QTCONF / D11.D11_QTMULT)) IS NULL THEN 0 ELSE (MIN(DCY.DCY_QTCONF / D11.D11_QTMULT)) END DCY_QTCONF"
		cQuery +=   " FROM "+RetSqlName('DCY')+" DCY"
		cQuery +=  " INNER JOIN "+RetSqlName('D11')+" D11"
		cQuery +=     " ON D11.D11_FILIAL = '"+xFilial('D11')+"'"
		cQuery +=    " AND D11.D11_PRODUT = DCY.DCY_PRDORI"
		cQuery +=    " AND D11.D11_PRDORI = DCY.DCY_PRDORI"
		cQuery +=    " AND D11.D11_PRDCMP = DCY.DCY_PROD"
		cQuery +=    " AND D11.D_E_L_E_T_ = ' '"
		cQuery +=  " WHERE DCY.DCY_FILIAL = '"+xFilial('DCY')+"'"
		cQuery +=    " AND DCY.DCY_EMBARQ = '"+cEmbarque+"'"
		cQuery +=    " AND DCY.DCY_PRDORI = '"+cPrdOri+"'"
		cQuery +=    " AND DCY.DCY_LOTE   = '"+cLoteCtl+"'"
		cQuery +=    " AND DCY.DCY_SUBLOT = '"+cNumLote+"'"
		cQuery +=    " AND DCY.DCY_LOCAL  = '"+__cWmsLcEx+"'"
		cQuery +=    " AND DCY.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasDCY := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCY,.F.,.T.)
		If (cAliasDCY)->(!EoF())
			If !DCY->(dbSeek(xFilial('DCY')+cEmbarque+cPrdOri+cPrdOri+cLoteCtl+cNumLote+__cWmsLcEx))
				RecLock('DCY',.T.)
				DCY->DCY_FILIAL := xFilial('DCY')
				DCY->DCY_EMBARQ := cEmbarque
				DCY->DCY_PRDORI := cPrdOri
				DCY->DCY_PROD   := cPrdOri
				DCY->DCY_LOTE   := cLoteCtl
				DCY->DCY_SUBLOT := cNumLote
				DCY->DCY_QTORIG := 0
				DCY->DCY_QTCONF := Int((cAliasDCY)->DCY_QTCONF)
				DCY->DCY_LOCAL  := __cWmsLcEx
				DCY->(MsUnlock())
			ElseIf (!lArmExcUni .Or. !lArmExcDif) .And. QtdComp(Int((cAliasDCY)->DCY_QTCONF)) > 0
				RecLock('DCY',.F.)
				DCY->DCY_QTCONF := Int((cAliasDCY)->DCY_QTCONF)
				DCY->(MsUnlock())
			EndIf
		EndIF
		(cAliasDCY)->(DbCloseArea())
		//Verifica saldo disponível do produto pai, quanto este estiver sendo conferido
		If cPrdConf  == aProdComp[1][3]
			If QtdComp(nSaldoPai) > 0
				If QtdComp(nSaldoPai) < QtdComp(nQtdInf)
					nQtdExc := nQtdInf - nSaldoPai
				EndIf
			Else
				//Se não encontrou quantidade na DCY, toda a quantidade será jogada em excesso
				nQtdExc := nQtdInf
			EndIf
		EndIf
		//Ajusta status do embarque
		DCW->(DbSetOrder(1))//DCW_FILIAL+DCW_EMBARQ
		If DCW->(DbSeek(xFilial('DCW')+ cEmbarque)) .And. DCW->DCW_SITEMB == '1'
			RecLock('DCW',.F.)
			DCW->DCW_SITEMB := '5' //Em andamento
			DCW->(MsUnlock())
		EndIf
		//Ajusta quantidade que está sendo conferida, removendo o excesso
		nQtdInf -= nQtdExc
		// Quanto o excesso for no mesmo armazém que o normal, precisa adicionar a quantidade também no unitizador
		If lArmExcUni .And. !lArmExcDif
			__QtExcUni := nQtdExc
		Else
			__QtExcUni := 0
		EndIf
	EndIf
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} GetUnitz
Troca unitizador que está sendo conferido.
@author  Amanda Rosa Vieira
@version P12
@since   24/04/2017
/*/
//----------------------------------------------------------
Static Function GetUniti(cEmbarque,cArmazem,cIdUnit,cTipUni,lEstorno,lNewUnit)
Local lRet      := .T.
Local aTela     := VtSave()
Local cIdUniAux := Space(TamSX3("D0R_IDUNIT")[1])
Local cTpUniAux := cTipUni
Default lEstorno := .F.
	If Empty(cTpUniAux)
		oMntUniItem:oUnitiz:oTipUnit:FindPadrao()
		cTpUniAux := oMntUniItem:oUnitiz:oTipUnit:GetTipUni()
	EndIf
	VtClear()
	If !Empty(cTpUniAux)
		VTKeyBoard(Chr(13))
	EndIf
	WMSVTCabec(STR0001+Iif(lEstorno,' '+STR0004,''),.F.,.F.,.T.) // Conferência
	@ 01,00  VtSay STR0003 + ': ' + cEmbarque // Recebimento
	@ 02,00  VTSay STR0042 // Tipo Unitz.
	@ 03,00  VtGet cTpUniAux Picture "@!" Valid ValidTpUni(cTpUniAux) When !(oMntUniItem:oUnitiz:UniHasItem()) F3 "D0T"
	@ 04,00  VTSay STR0041 // Informe o Untiz.
	@ 05,00  VtGet cIdUniAux Picture "@!" Valid ValidUnitz(cEmbarque,cArmazem,cIdUniAux,@cTpUniAux,lEstorno)
	VtRead()
	VtRestore(,,,,aTela)

	If VtLastkey() == 27
		oMntUniItem:SetIdUnit(cIdUnit)
		oMntUniItem:oUnitiz:SetTipUni(cTipUni)
		lRet := .F.
	EndIf

	If lRet
		If !oMntUniItem:oUnitiz:LoadData()
			oMntUniItem:oUnitiz:SetDatIni(dDataBase)
			oMntUniItem:oUnitiz:SetHorIni(Time())
		EndIf
		// Anula data e hora final para forçar gravar atualizado
		oMntUniItem:oUnitiz:SetDatFim(StoD(""))
		oMntUniItem:oUnitiz:SetHorFim("")

		cIdUnit  := cIdUniAux
		cTipUni  := cTpUniAux
		If !lNewUnit
			VTKeyBoard(Chr(27)) // Força um ESC para voltar o inicio do produto
			lNewUnit := .T.
		EndIf
	EndIf
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} ShowItens
Mostra itens do unitizador
@author  Inovação WMS
@version P12
@since   02/04/2017
/*/
//----------------------------------------------------------
Static Function ShowItens(cUnitiz)
Local cKey09   := VtDescKey(09)
Local cKey15   := VtDescKey(15)
Local cKey21   := VtDescKey(21)
Local bKey09   := VTSetKey(09)
Local bKey15   := VTSetKey(15)
Local bKey21   := VTSetKey(21)

	// Deve validar se o unitizador possui itens
	If !oMntUniItem:oUnitiz:UniHasItem()
		WMSVTAviso(WMSV09026, STR0058) // O unitizador não possui itens.
		lRet := .F.
	Else
	   GetItens(cUnitiz)
	EndIf
	// Restaura Tecla
	VTSetKey(09,bKey09, cKey09)
	VTSetKey(15,bKey15, cKey15)
	VTSetKey(21,bKey21, cKey21)
Return Nil
//----------------------------------------------------------------------------------
Static Function GetItens(cUnitiz)
Local aAreaAnt := GetArea()
Local aTela    := VTSave()
Local aCab     := {}
Local aSize    := {}
Local aPrdUni  := {}
Local cQuery   := ""
Local cAliasQry:= ""
Local aTamSX3  := TamSx3('D0S_QUANT')

	cQuery := " SELECT D0S.D0S_CODPRO,"
	cQuery +=        " D0S.D0S_LOTECT,"
	cQuery +=        " D0S.D0S_NUMLOT,"
	cQuery +=        " D0S.D0S_PRDORI,"
	cQuery +=        " D0S.D0S_QUANT"
	cQuery +=   " FROM "+RetSqlName("D0S")+" D0S"
	cQuery +=  " WHERE D0S.D0S_FILIAL = '"+xFilial("D0S")+"'"
	cQuery +=    " AND D0S.D0S_IDUNIT = '"+cUnitiz+"'"
	cQuery +=    " AND D0s.D_E_L_E_T_ = ' '"
	cQuery +=  " ORDER BY D0S.D0S_PRDORI, D0S.D0S_CODPRO, D0S.D0S_LOTECT, D0S.D0S_NUMLOT"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	TcSetField(cAliasQry,'D0S_QUANT','N',aTamSX3[1],aTamSX3[2])
	Do While (cAliasQry)->(!Eof())
		aAdd(aPrdUni,{(cAliasQry)->D0S_CODPRO,(cAliasQry)->D0S_LOTECT,(cAliasQry)->D0S_NUMLOT,(cAliasQry)->D0S_QUANT,(cAliasQry)->D0S_PRDORI})
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

	VTClear()
	aCab  := {RetTitle("D0S_CODPRO"),RetTitle("D0S_LOTECT"),RetTitle("D0S_NUMLOT"),RetTitle("D0S_QUANT"),RetTitle("D0S_PRDORI")}
	aSize := {TamSx3("D0S_CODPRO")[1],TamSx3("D0S_LOTECT")[1],TamSx3("D0S_NUMLOT")[1],TamSx3("D0S_QUANT")[1],TamSx3("D0S_PRDORI")[1]}
	WMSVTCabec(STR0059,.F.,.F.,.T.) // Itens Unitizador
	VTaBrowse(1,0,(VTMaxRow()-1),VTMaxCol(),aCab,aPrdUni,aSize)

	VtRestore(,,,,aTela)
	RestArea(aAreaAnt)
Return Nil
//----------------------------------------------------------
/*/{Protheus.doc} CalcQtdConf
Calcula quantidade já conferida para o produto
@author  Amanda Rosa Vieira
@version P12
@since   05/07/2017
/*/
//----------------------------------------------------------
Static Function CalcQtdConf(nQtConf,cPrdOri,cProduto,cLote,cNumLote,cLocal,cEmbarque)
Local cQuery    := ""
Local cAliasDCY := ""

	DCY->(DbSetOrder(1))
	If DCY->( dbSeek(xFilial('DCY')+cEmbarque+cPrdOri+cProduto+cLote+cNumLote+cLocal) )
		nQtConf += DCY->DCY_QTCONF
	EndIf

	//Desconta quantidade em excesso que já foi gravada em outro ponto
	cQuery := " SELECT SUM(DCY.DCY_QTORIG) DCY_QTORIG"
	cQuery +=   " FROM "+RetSqlName('DCY')+" DCY"
	cQuery +=  " WHERE DCY.DCY_FILIAL = '"+xFilial('DCY')+"'"
	cQuery +=    " AND DCY.DCY_EMBARQ = '"+cEmbarque+"'"
	cQuery +=    " AND DCY.DCY_PRDORI = '"+cPrdOri+"'"
	cQuery +=    " AND (DCY.DCY_LOTE  = '"+cLote+"' OR DCY.DCY_LOTE = ' ')"
	cQuery +=    " AND (DCY.DCY_SUBLOT= '"+cNumLote+"' OR DCY.DCY_SUBLOT = ' ')"
	cQuery +=    " AND DCY.DCY_PROD   = '"+cProduto+"'"
	cQuery +=    " AND DCY.D_E_L_E_T_ = ' '"
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	If (cAliasQry)->(!EoF())
		If nQtConf > (cAliasQry)->DCY_QTORIG
			//Remove quantidade excedente
			nQtConf -= (nQtConf - (cAliasQry)->DCY_QTORIG)
		EndIf
	EndIf

	D11->(DbSetOrder(1)) //D11_FILIAL+D11_PRODUT+D11_PRDORI+D11_PRDCMP
	If D11->(DbSeek(xFilial("D11")+cPrdOri+cPrdOri+cProduto))
		nQtConf := nQtConf/D11->D11_QTMULT
	EndIf

	//Caso o cálculo do produto pai gere um valor com decimais arredonda para cima dessa forma gera a linha do produto pai de forma coerente com a quantidade conferida para o filho
	If !(cPrdOri == cProduto) .And. nQtConf > Int(nQtConf)
		nQtConf := Int(nQtConf)+1
	EndIf
Return nQtConf


/*
** Cópia de validação Wms320FiCo
*/
Static Function PS320FiCo(lAutomato)
	Local aAreaDCW  := DCW->(GetArea())
	Local aAreaDCY  := DCY->(GetArea())
	Local lEncerra  := .F.
	Local lDiverge  := .F.
	Local lRet      := .T.
	Local nQtdOrig	:= 0
	Local nQtdConf	:= 0
	Default lAutomato := .F.

	If DCW->DCW_SITEMB <> "5"
		WmsMessage("Finalização permitida somente para embarque em andamento!",WMSA32009,1) // Finalização permitida somente para embarque em andamento!
		Return .F.
	EndIf

	If !lAutomato
		If !WmsQuestion("Confirma a finalização do processo de conferência?") // Confirma a finalização do processo de conferência?
			Return .F.
		EndIf
	EndIf

	// Força a releitura do registro
	DCW->( DbSeek(xFilial('DCW')+DCW->DCW_EMBARQ) )
	If DCW->DCW_SITEMB $ '6|7'
		WmsMessage("Conferencia já finalizada por outro processo!",WMSA32010,1) // Conferencia já finalizada por outro processo!
		Return .F.
	EndIf

	// Verifica se algum item foi conferido
	DCY->( dbSetOrder(1) )
	// DCY_FILIAL+DCY_EMBARQ+DCY_PROD+DCY_LOTE+DCY_SUBLOT
	DCY->( dbSeek(xFilial('DCY')+DCW->DCW_EMBARQ) )
	While !DCY->( Eof() ) .And. DCY->DCY_FILIAL == xFilial('DCY') .And. DCY->DCY_EMBARQ == DCW->DCW_EMBARQ .And. lEncerra == .F.
		nQtdConf += QtdComp(DCY->DCY_QTCONF)
		
		DCY->( dbSkip() )
	EndDo

	If nQtdConf > QtdComp(0)
		lEncerra := .T.
	EndIf

	If !lEncerra
		WmsMessage("Finalização não permitida. Não foi conferido nenhuma quantidade.",WMSA32011,1) // Finalização não permitida. Não foi conferido nenhuma quantidade.
		Return .F.
	EndIf
	
	nQtdConf := 0

	// Verifica se algum item foi conferido
	DCY->( dbSetOrder(1) )
	// DCY_FILIAL+DCY_EMBARQ+DCY_PROD+DCY_LOTE+DCY_SUBLOT
	DCY->( dbSeek(xFilial('DCY')+DCW->DCW_EMBARQ) )
	While !DCY->( Eof() ) .And. DCY->DCY_FILIAL == xFilial('DCY') .And. DCY->DCY_EMBARQ == DCW->DCW_EMBARQ .And. lDiverge == .F.
		nQtdOrig += QtdComp(DCY->DCY_QTORIG)
		nQtdConf += QtdComp(DCY->DCY_QTCONF)
		
		DCY->( dbSkip() )
	EndDo

	If nQtdOrig <> nQtdConf
		lDiverge := .T.
	EndIf

	If lDiverge .And. !lAutomato
		If !WmsQuestion("Foram encontradas divergencias na contagem. Confirma encerramento?") // Foram encontradas divergencias na contagem. Confirma encerramento?
			RestArea(aAreaDCY)
			RestArea(aAreaDCW)
			Return .F.
		EndIf
	EndIf

	// Verifica se todos os parametros estão preechidos quando pelo menos um está parametrizado
	// Removido por o cliente não utilizar - Regra Dione Oliveira.
//	If lDiverge .And. !Wm320ClPar() .And. !(Wm320MovEx() .And. Wm320MovFt()) .And. !lAutomato
//		If !WmsQuestion("Os parâmetros da conferência estão incompletos! Os tratamentos de falta e excesso podem não ser realizados. Deseja continuar mesmo assim?",WMSA32029) // "Os parâmetros da conferência estão incompletos! Os tratamentos de falta e excesso podem não ser realizados. Deseja continuar mesmo assim?"
//			lRet := .F.
//		EndIf
//	EndIf

	If lRet
		Processa({|| lRet := A320FINCOF(DCW->DCW_EMBARQ,DCW->DCW_TPCONF,lDiverge)}, "Finalizando Conferência", "Aguarde" + "...", .T.) // Finalizando Conferência // Aguarde
	EndIf

	If !lAutomato .And. !IsTelNet()
		If lRet
			BrwRefresh(.T.)
		Else
			WmsMessage("Não foi possível finalizar a conferência.",WMSA32012,2) // Não foi possível finalizar a conferência.
		EndIf
	EndIf

	RestArea(aAreaDCY)
	RestArea(aAreaDCW)
Return lRet
