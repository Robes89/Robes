#include "totvs.ch"
#include 'fwmvcdef.ch'
#include "rptdef.ch"
#include "fwprintsetup.ch"
#include "tbiconn.ch"

/*
Funcao      : V5FAT016()
Parametros  : lPreview
Retorno     : _aRet
Objetivos   : Impressão da nova fatura da Vogel com capa, boleto, notas e faturas.
Autor       : Ciro Pedreira
Cliente		: Vogel
Data/Hora   : 24/07/2018
*/

User Function V5FAT016(lV5FAT, lVisua, _cNaoAut, _lBolUni, _lMulta, _nPMulta, _nPJuros, _lWS,aNotasCapa)

	Local _aAreaMem := GetArea()
	Local _aAreaSF2 := SF2->(GetArea())
	Local _aAreaSE1 := SE1->(GetArea())

	Local lExec := .T.
	Local _aRet := {}

	Local cLocal   := ''
	Local cPerg    := "V5FAT016"
	Local cQuery   := ''
	Local _cTip460 := SuperGetMV('VO_TIPAGLU',, 'BOL')

	Private _oPrint16

	Private lVisual	:= IIF(ValType(lVisua) <> "L", .T., lVisua)
	Private lV5FAT1	:= IIF(ValType(lV5FAT) <> "L", .F., lV5FAT)

	Default _cNaoAut := ''
	Default _lBolUni := .T.
	Default _nPMulta := 0
	Default _nPJuros := 0
	Default _lWS     := .F.
	Default _lMulta  := .F.
	Default aNotasCapa := {}

	cLocal := IIf(!_lWs, GetTempPath(), '')

	If !lV5FAT1
		// Verifica os parâmetros do relatório.
		CriaPerg(cPerg)
		If !Pergunte (cPerg,.T.)
			Return Nil
		EndIf
	Else
		// Caso venha pela rotina automatica.
		MV_PAR01 := SE1->E1_NUM
		MV_PAR02 := SE1->E1_NUM
		MV_PAR03 := SE1->E1_PREFIXO
	EndIf

	If Select('SQL16') > 0
		SQL16->(DbCloseArea())
	EndIf

	Conout('V5FAT016 - ' + AllTrim(Str(SE1->(Recno()))))

	cQuery := "SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_VALOR, SE1.R_E_C_N_O_ SE1REC "
	cQuery += "FROM " + RetSqlName('SE1') + " SE1 "
	cQuery += "WHERE SE1.D_E_L_E_T_ = '' "
	cQuery += "AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' "
	cQuery += "AND SE1.E1_NUM >= '" + MV_PAR01 + "' "
	cQuery += "AND SE1.E1_NUM <= '" + MV_PAR02 + "' "
	cQuery += "AND SE1.E1_PREFIXO = '" + MV_PAR03 + "' "
	If _lBolUni
		cQuery += "AND SE1.E1_TIPO = '" + _cTip460 + "' "
	Else
		cQuery += "AND SE1.E1_TIPO IN ('NF', 'DIC') "
	EndIf
	cQuery += "ORDER BY E1_EMISSAO+E1_NUM+E1_PREFIXO"

	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "SQL16", .T., .T.)

	If SQL16->(EOF()) .OR. SQL16->(BOF())
		lExec := .F.
	EndIf

	If lExec
		Processa({|| _aRet := MONTAREL(cLocal, @_cNaoAut, _lBolUni, _lMulta, _nPMulta, _nPJuros, _lWS,aNotasCapa)})
	Else
		Aviso("Aviso", "Não existem informações para os parametros informados.", {"Ok"}, 2)
	EndIf

	SQL16->(DbCloseArea())

	RestArea(_aAreaMem)
	RestArea(_aAreaSF2)
	RestArea(_aAreaSE1)

Return _aRet

/*
Função  : MONTAREL
Retorno : _aRet
Objetivo: Gera o relatório
Autor   : Ciro Pedreira
Data    : 24/07/2018
*/

Static Function MONTAREL(cLocal, _cNaoAut, _lBolUni, _lMulta, _nPMulta, _nPJuros, _lWS,aNotasCapa)

	Local _aRet := {}

	ProcRegua(0)

	While SQL16->(!EOF())

		_aRet := GERAREL(cLocal, @_cNaoAut, _lBolUni, _lMulta, _nPMulta, _nPJuros, _lWS,aNotasCapa)

		SQL16->(DbSkip())

	EndDo

Return _aRet

/*
Função  : GERAREL
Retorno : _aRet
Objetivo: Gera o relatório
Autor   : Ciro Pedreira
Data    : 24/07/2018
*/

Static Function GERAREL(cLocal, _cNaoAut, _lBolUni, _lMulta, _nPMulta, _nPJuros, _lWS,aNotasCapa)

	Local _aRet    := {}
	Local cNomeArq := 'Fatura_' + AllTrim(SQL16->E1_PREFIXO) + "_" + AllTrim(SQL16->E1_NUM)
	Local cDirBol  := "\FTP\" + cEmpAnt + "\V5FAT016\"

	If !LisDir(cDirBol)
		MakeDir("\FTP")
		MakeDir("\FTP\" + cEmpAnt)
		MakeDir("\FTP\" + cEmpAnt + "\V5FAT016\")
	EndIf

/*	If !lVisual
		_oPrint16 := FWMSPrinter():New(cNomeArq, IMP_PDF, .F.,, .T., .F.,,,,,, .F., 0)
Else
		_oPrint16 := FWMSPrinter():New(cNomeArq, IMP_PDF, .F.,, .T., .F.,,,,,, .T., 0)
EndIf

	// Ordem obrigatoria de configuração do relatório.
	_oPrint16:SetResolution(72)
	_oPrint16:SetPortrait() // Retrato ou SetLandScape para paisagem.
	_oPrint16:SetPaperSize(9)
	_oPrint16:SetMargin(0,0,0,0)
If !_lWs
		_oPrint16:cPathPDF := cLocal
Else
		_oPrint16:cPathPDF := cDirBol
		_oPrint16:lServer := _lWs
EndIf
*/
// Impressao do cabecalho do relatorio.
_aRet := IMPNF(_oPrint16, cLocal, cNomeArq, cDirBol, @_cNaoAut, _lBolUni, _lMulta, _nPMulta, _nPJuros, _lWS,aNotasCapa)
_oPrint16 := Nil

Return _aRet

/*
Função  : IMPNF
Retorno : cFile
Objetivo: Gera o relatório
Autor   : Ciro Pedreira
Data    : 10/06/2018
*/

Static Function IMPNF(_oPrint16, cLocal, cNomeArq, cDirBol, _cNaoAut, _lBolUni, _lMulta, _nPMulta, _nPJuros, _lWS,aNotasCapa)

	Local _aBoleto  := {}
	Local _dDtVenc  := CToD('')
	Local _nValor   := 0
	Local _cLinDig  := ''
	Local _cQuery   := ''
	Local _cRet     := ''
	Local _cArqFat  := ''
	Local _cArqBol  := ''
	Local _cArqBol2 := ''
	Local _aDetCapa := {}
	Local _cCID     := ''
	Local _cDesc    := ''
	Local _cNFNAut  := ''
	Local aAnexos := {}
	Local cCapa := ""
	Local cAnexo := ""
	Local nValLiq := 0
	Local cReferencia := IIf( SE1->E1_PREFIXO = 'AGL' , SE1->E1_NUM , SE1->E1_XID ) 

	VarInfo("V5FAT016 - IMPNF - _oPrint16", _oPrint16)

	SE1->(DbGoTo(SQL16->SE1REC))

	SA1->(DbSetOrder(1)) // Indice 1 - A1_FILIAL+A1_COD+A1_LOJA
	SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))

	VarInfo("V5FAT016 - IMPNF - _lBolUni", _lBolUni)

	If _lBolUni

		// Obtem alguns dados do boleto para impressão na capa da fatura.

		If SA1->A1_XBOLDEP != 'N' .AND. SA1->A1_XBOLDEP != "2"

			If SA1->A1_P_TPBOL == '1' // Itaú.
				_aBoleto := U_V5FIN001(.F.,, .T.,, .T., _lMulta, _nPMulta, _nPJuros, _lWS) // Boleto Itaú.
			ElseIf SA1->A1_P_TPBOL == '2' // Santander.
				_aBoleto := U_V5FIN004(.F.,, .T.,, .T., _lMulta, _nPMulta, _nPJuros, _lWS) // Boleto Santander.
			ElseIf SA1->A1_P_TPBOL == '3' // Banco do Brasil.
				_aBoleto := U_V5FIN005(.F.,, .T.,, .T., _lMulta, _nPMulta, _nPJuros, _lWS) // Boleto Banco do Brasil.
			EndIf

			VarInfo("V5FAT016 - IMPNF - _aBoleto", _aBoleto)

			If Len(_aBoleto) == 3
				_dDtVenc := _aBoleto[3]
				_nValor  := _aBoleto[2]
				_cLinDig := _aBoleto[1][2] // Linha digitável do boleto.
			EndIf

		Endif

		_cQuery := "SELECT E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, "
		_cQuery += "E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_VALOR, SE1.R_E_C_N_O_ SE1REC "
		_cQuery += "FROM " + RetSqlName('SE1') + " SE1 "
		_cQuery += "INNER JOIN " + RetSqlName('SE5') + " SE5 ON "
		_cQuery += "SE5.D_E_L_E_T_ = '' "
		_cQuery += "AND SE5.E5_FILIAL = '" + xFilial('SE5') + "' "
		_cQuery += "AND SE5.E5_DOCUMEN = SE1.E1_NUMLIQ "
		_cQuery += "AND SE5.E5_MOTBX = 'LIQ' "
		_cQuery += "WHERE SE1.D_E_L_E_T_ = '' "
		_cQuery += "AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' "
		_cQuery += "AND SE1.E1_NUM = '" + SE1->E1_NUM + "' "
		_cQuery += "AND SE5.E5_TIPO NOT LIKE  '%-%' "
		_cQuery += "AND SE1.E1_PREFIXO = '" + SE1->E1_PREFIXO + "' "
		_cQuery += "ORDER BY E5_NUMERO+E5_PREFIXO"

	Else

		/*Validacao para nova melhoria, que alimenta o campo E1_XID, se nao esta preenchido ainda, 
		busca CLIENTE + DATA */

		If Empty(SE1->E1_XID)

			_cQuery := "SELECT E1_PREFIXO E5_PREFIXO, E1_NUM E5_NUMERO, E1_PARCELA E5_PARCELA, E1_TIPO E5_TIPO, "
			_cQuery += "E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_VALOR, SE1.R_E_C_N_O_ SE1REC "
			_cQuery += "FROM " + RetSqlName('SE1') + " SE1 "
			_cQuery += "WHERE SE1.D_E_L_E_T_ = '' "
			_cQuery += "AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' "
			_cQuery += "AND SE1.E1_EMISSAO = '" + DTOS(SE1->E1_EMISSAO) + "' "
			_cQuery += "AND E1_CLIENTE = '"   + SE1->E1_CLIENTE + "'"
			_cQuery += "AND SE1.E1_TIPO NOT LIKE  '%-%' "
			_cQuery += "ORDER BY E1_NUM+E1_PREFIXO"

		Else

			_cQuery := "SELECT E1_PREFIXO E5_PREFIXO, E1_NUM E5_NUMERO, E1_PARCELA E5_PARCELA, E1_TIPO E5_TIPO, "
			_cQuery += "E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_VALOR, SE1.R_E_C_N_O_ SE1REC "
			_cQuery += "FROM " + RetSqlName('SE1') + " SE1 "
			_cQuery += "WHERE SE1.D_E_L_E_T_ = '' "
			_cQuery += "AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' "
			_cQuery += "AND SE1.E1_XID = '" + SE1->E1_XID + "' "
			_cQuery += "AND SE1.E1_TIPO NOT LIKE  '%-%' "
			_cQuery += "ORDER BY E1_NUM+E1_PREFIXO"

		Endif

		If SA1->A1_XBOLDEP != 'N' .AND. SA1->A1_XBOLDEP != "2"

			// Obtem alguns dados do boleto para impressão na capa da fatura.
			If SA1->A1_P_TPBOL == '1' // Itaú.
				_aBoleto := U_V5FIN001(.F.,, .T.,, .T., _lMulta, _nPMulta, _nPJuros, _lWS) // Boleto Itaú.
			ElseIf SA1->A1_P_TPBOL == '2' // Santander.
				_aBoleto := U_V5FIN004(.F.,, .T.,, .T., _lMulta, _nPMulta, _nPJuros, _lWS) // Boleto Santander.
			ElseIf SA1->A1_P_TPBOL == '3' // Banco do Brasil.
				_aBoleto := U_V5FIN005(.F.,, .T.,, .T., _lMulta, _nPMulta, _nPJuros, _lWS) // Boleto Banco do Brasil.
			EndIf

			VarInfo("V5FAT016 - IMPNF - _aBoleto", _aBoleto)

			If Len(_aBoleto) == 3
				_dDtVenc := _aBoleto[3]
				_nValor  := _aBoleto[2]
				_cLinDig := _aBoleto[1][2] // Linha digitável do boleto.
			EndIf

		Endif


		VarInfo("V5FAT016 - IMPNF - _aBoleto", _aBoleto)

		_dDtVenc := CToD('//')
		_nValor  := 0
		_cLinDig := '' // Linha digitável do boleto.

	EndIf

	DbUseArea(.T., "TOPCONN", TcGenQry(,, _cQuery), "SQL2", .T., .T.)

	// Geração das notas.
	If SQL2->(!EOF())

		_aDetCapa := {}

		// Loop em todas as notas que foram aglutinadas.
		While SQL2->(!EOF())

			_cDesc := ''

			SF2->(DbSetOrder(1)) // Indice 1 - F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
			If SF2->(DbSeek(xFilial('SF2')+SQL2->E5_NUMERO+SQL2->E5_PREFIXO))

				//Auxilio para nao imprimir duas vez a nota em documentos diferentes na boleto / fatura
				// Agora e validado pelo campo F2_XID

				If Empty(SF2->F2_XID )

					If aScan( aNotasCapa, {|x| x == SF2->F2_DOC + SF2->F2_SERIE} ) == 0
						aAdd(aNotasCapa, SF2->F2_DOC + SF2->F2_SERIE )
					Endif

				Endif


				SD2->(DbSetOrder(3)) // Indice 1 - D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
				If SD2->(DbSeek(xFilial('SD2')+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))

					SC6->(DbSetOrder(1)) // Indice 1 - C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
					If SC6->(DbSeek(xFilial('SC6')+SD2->D2_PEDIDO+SD2->D2_ITEMPV+SD2->D2_COD))

						// _cDesc := SC6->C6_DESCRI
						// Solicitado Fabricio para buscar sempre da descricao na capa

					EndIf

					SB1->(DbSetOrder(1)) // Indice 1 - B1_FILIAL+B1_COD
					If SB1->(DbSeek(xFilial('SB1')+SD2->D2_COD))

						If Empty(_cDesc)

							_cDesc := SB1->B1_DESC

						EndIf

					EndIf

					SC5->(DbSetOrder(1)) // Indice 1 - C5_FILIAL+C5_NUM
					If SC5->(DbSeek(xFilial('SC5')+SD2->D2_PEDIDO))

						_cCID := SC5->C5_P_CID

					EndIf

					If AllTrim(SF2->F2_ESPECIE) == 'NFSC' // Conectividade
						AAdd(_aDetCapa, {'SCM', SF2->F2_DOC, _cDesc, SF2->F2_VALBRUT})
					Elseif AllTrim(SF2->F2_ESPECIE) == 'NTST' // Voz
						AAdd(_aDetCapa, {'VOZ', SF2->F2_DOC, _cDesc, SF2->F2_VALBRUT})
					ElseIf AllTrim(SF2->F2_ESPECIE) == 'FAT' // Fatura comercial.
						AAdd(_aDetCapa, {'LOC', SF2->F2_DOC, _cDesc, SF2->F2_VALBRUT})
					ElseIf AllTrim(SF2->F2_ESPECIE) == 'NFPS' // Nota fiscal de serviço.

						nValLiq := SF2->F2_VALBRUT

					/*	If SF2->F2_VALCSLL + SF2->F2_VALCOFI + SF2->F2_VALPIS > 10
							nValLiq := nValLiq - ( SF2->F2_VALCSLL + SF2->F2_VALCOFI + SF2->F2_VALPIS )
					Endif
					If SF2->F2_VALIRRF > 10
							nValLiq := nValLiq - SF2->F2_VALIRRF
					Endif*/
						//AAdd(_aDetCapa, {'SVA', SF2->F2_NFELETR, _cDesc, SF2->F2_VALFAT})// alterado para carragar o valor da Fatura para NFPS - R.P.B 08/08/2019
						AAdd(_aDetCapa, {'SVA', SF2->F2_NFELETR, _cDesc, nValLiq})// alterado para carragar o valor da Fatura para NFPS - R.P.B 08/08/2019
				EndIf

				If !_lBolUni
						_nValor += SQL2->E1_VALOR
				EndIf

			EndIf

		EndIf

			SQL2->(DbSkip())

	EndDo

		VarInfo("V5FAT016 - Apos primeiro loop - _oPrint16", _oPrint16)

		cCapa := U_V5FAT015(lVisual, .F., @_oPrint16, _dDtVenc, _nValor, _cLinDig, _aDetCapa, _cCID,,, cReferencia) // Geração da capa da fatura.
	If !Empty(cCapa)
			AAdd( aAnexos , cCapa)
	Endif

		VarInfo("V5FAT016 - Apos V5FAT015 - _oPrint16", _oPrint16)

		SQL2->(DbGoTop())

		// Loop em todas as notas que foram aglutinadas.
		_oPrintBkp := _oPrint16

	While SQL2->(!EOF())

		If ! lErroArq
				//_oPrint16 := _oPrintBkp

				VarInfo("V5FAT016 - Dentro do segundo loop - _oPrint16", _oPrint16)

				SF2->(DbSetOrder(1)) // Indice 1 - F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
			If SF2->(DbSeek(xFilial('SF2')+SQL2->E5_NUMERO+SQL2->E5_PREFIXO))

				If AllTrim(SF2->F2_ESPECIE) == 'NFPS' // Nota fiscal de serviço.

						_cNFNAut := ''

					If SM0->M0_ESTCOB == 'RS'

							cAnexo := U_V5FAT012(lV5FAT1,lVisual, .F., @_oPrint16, @_cNFNAut, _lWS) // NFS-e Porto Alegre.

						If !Empty(cAnexo)
								aAdd( aAnexos , cAnexo )
						Endif

							VarInfo("V5FAT016 - Apos V5FAT012 - _oPrint16", _oPrint16)

					ElseIf SM0->M0_ESTCOB == 'MG'

							cAnexo := U_V5FAT013(lV5FAT1,lVisual, .F., @_oPrint16, @_cNFNAut, _lWS) // NFS-e Belo Horizonte.

						If !Empty(cAnexo)
								aAdd( aAnexos , cAnexo )
						Endif

							VarInfo("V5FAT016 - Apos V5FAT013 - _oPrint16", _oPrint16)

					ElseIf SM0->M0_ESTCOB == 'SP'

							// U_V5FAT014(.T.,, .T., @_oPrint16, @_cNFNAut, _lWS) // NFS-e São Paulo.
							cAnexo := U_V5FAT014(lV5FAT1,lVisual, .F., @_oPrint16, @_cNFNAut, _lWS) // NFS-e São Paulo.
						If !Empty(cAnexo)
								aAdd( aAnexos , cAnexo )
						Endif


							VarInfo("V5FAT016 - Apos V5FAT014 - _oPrint16", _oPrint16)

					ElseIf SM0->M0_ESTCOB == 'SC'

							cAnexo := U_V5FAT017(lV5FAT1,lVisual, .F., @_oPrint16, @_cNFNAut, _lWS) // NFS-e Palhoça.

						If !Empty(cAnexo)
								aAdd( aAnexos , cAnexo )
						Endif

							VarInfo("V5FAT016 - Apos V5FAT017 - _oPrint16", _oPrint16)

					ElseIf SM0->M0_ESTCOB == 'RJ'

							cAnexo := U_V5FAT018(.T.,lVisual, .F., @_oPrint16, @_cNFNAut, _lWS) // NFS-e Rio de Janeiro.
							If !Empty(cAnexo)
								aAdd( aAnexos , cAnexo )
							Endif
							VarInfo("V5FAT016 - Apos V5FAT018 - _oPrint16", _oPrint16)

					ElseIf SM0->M0_ESTCOB == 'PE'

							U_V5FAT019(.T.,, .F., @_oPrint16, @_cNFNAut, _lWS) // NFS-e Recife.

							VarInfo("V5FAT016 - Apos V5FAT019 - _oPrint16", _oPrint16)

					EndIf

						_cNaoAut += _cNFNAut

				ElseIf AllTrim(SF2->F2_ESPECIE) == "FAT" // Fatura.

						cAnexo := U_V5FAT009(lV5FAT1,lVisual, .F., @_oPrint16, _lWS)

					If !Empty(cAnexo)
							AAdd ( aAnexos , cAnexo )
					Endif

						VarInfo("V5FAT016 - Apos V5FAT009 - _oPrint16", _oPrint16)

				ElseIf AllTrim(SF2->F2_ESPECIE) $ "NFST|NTST" // Telecom.

						cAnexo := U_V5FAT004(lV5FAT1,lVisual, .F., @_oPrint16, _lWS)

					If !Empty(cAnexo)
							aAdd( aAnexos , cAnexo )
					Endif

						VarInfo("V5FAT016 - Apos V5FAT004 - _oPrint16", _oPrint16)

				ElseIf AllTrim(SF2->F2_ESPECIE) == "NFSC" // Comunicação.

						//cAnexo := U_V5FAT004(lV5FAT1,lVisual, .F., @_oPrint16, _lWS)
						cAnexo := U_V5FAT010(lV5FAT1,lVisual, .F., @_oPrint16, _lWS)
					If !Empty(cAnexo)
							aAdd( aAnexos , cAnexo )
					Endif

						VarInfo("V5FAT016 - Apos V5FAT010 - _oPrint16", _oPrint16)

				EndIf

			EndIf

		Endif

			SQL2->(DbSkip())

	EndDo

EndIf

If Empty(_cNaoAut)

	If !_lWs
			/*
		If File(cLocal + cNomeArq + ".pdf")
				FErase(cLocal + cNomeArq + ".pdf")
		EndIf
			
			// Visualizar o documento.
		If lVisual
				// tratar _oPrint16:Preview()
		Else
				// tratar _oPrint16:Print()
			If CpyT2S(cLocal + cNomeArq + ".pdf", cDirBol, .T.)
					_cArqFat := cDirBol + cNomeArq + ".pdf"
			Else
					MsgStop('Erro na cópia do arquivo PDF para o servidor. Fatura ' + cNomeArq + ".pdf")
			EndIf
		EndIf
			*/
	Else

		// tratar _oPrint16:Print()

		_cArqFat := cDirBol + cNomeArq + ".pdf"

	EndIf

	If _lBolUni

		//Validacao se gera o boleto
		If SA1->A1_XBOLDEP != 'N' .AND. SA1->A1_XBOLDEP != "2"

			SE1->(DbGoTo(SQL16->SE1REC)) // Posiciona novamente no SE1 gerado pela liquidação.

			SA1->(DbSetOrder(1)) // Indice 1 - A1_FILIAL+A1_COD+A1_LOJA
			SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))

			// Geração do boleto aglutinado.
			If SA1->A1_P_TPBOL == '1' // Itaú
				_cArqBol := U_V5FIN001(.F., lVisual, .T.,, .F., _lMulta, _nPMulta, _nPJuros, _lWS) // Boleto Itaú.
			ElseIf SA1->A1_P_TPBOL == '2' // Santander.
				_cArqBol := U_V5FIN004(.F., lVisual, .T.,, .F., _lMulta, _nPMulta, _nPJuros, _lWS) // Boleto Santander.
			ElseIf SA1->A1_P_TPBOL == '3' // Banco do Brasil.
				_cArqBol := U_V5FIN005(.F., lVisual, .T.,, .F., _lMulta, _nPMulta, _nPJuros, _lWS) // Boleto Banco do Brasil.
			EndIf

			If !Empty(_cArqBol)
				aAdd ( aAnexos , _cArqBol)
			Endif

		Endif

	Else

		SQL2->(DbGoTop())

		// Loop em todas as notas que foram aglutinadas.
		While SQL2->(!EOF())

			SE1->(DbGoTo(SQL2->SE1REC)) // Posiciona novamente no SE1 de cada nota.

			SA1->(DbSetOrder(1)) // Indice 1 - A1_FILIAL+A1_COD+A1_LOJA
			SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))

			SF2->(DbSetOrder(1)) // Indice 1 - F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
			If SF2->(DbSeek(xFilial('SF2')+SQL2->E5_NUMERO+SQL2->E5_PREFIXO))

				If  SA1->(FieldPos("A1_XBOLDEP")) == 0 .OR. ( SA1->A1_XBOLDEP != 'N' .AND. SA1->A1_XBOLDEP != "2"  )   //SA1->(SA1->A1_XBOLDEP == '1'
					// Geração do boleto aglutinado.
					If SA1->A1_P_TPBOL == '1' // Itaú
						_cArqBol2 := U_V5FIN001(.F., lVisual, .T.,, .F., _lMulta, _nPMulta, _nPJuros, _lWS) // Boleto Itaú.
					ElseIf SA1->A1_P_TPBOL == '2' // Santander.
						_cArqBol2 := U_V5FIN004(.F., lVisual, .T.,, .F., _lMulta, _nPMulta, _nPJuros, _lWS) // Boleto Santander.
					ElseIf SA1->A1_P_TPBOL == '3' // Banco do Brasil.
						_cArqBol2 := U_V5FIN005(.F., lVisual, .T.,, .F., _lMulta, _nPMulta, _nPJuros, _lWS) // Boleto Banco do Brasil.
					EndIf

				Endif

				If !Empty(_cArqBol2)
					aAdd ( aAnexos , _cArqBol2)
				Endif

				If !Empty(_cArqBol)
					_cArqBol += ';'
				EndIf

				_cArqBol += _cArqBol2

			EndIf

			SQL2->(DBSkip())

		EndDo

	EndIf

Else

	If !(AllTrim(FunName()) == 'V5FAT006')

		Alert('A seguinte nota fiscal não foi autorizada pela prefeitura: ' + _cNaoAut, 'Impressão Bloqueada')

	EndIf

EndIf

SQL2->(DbCloseArea())

Return aAnexos//{_cArqFat, _cArqBol}

/*
Função  : CriaPerg
Objetivo: Verificar se os parametros estão criados corretamente.
Autor   : Ciro Pedreira
Data    : 24/07/2018
*/

Static Function CriaPerg(cPerg)

	Local lAjuste := .F.

	Local nI := 0

	Local aHlpPor := {}
	Local aHlpEng := {}
	Local aHlpSpa := {}
	Local aSX1    := {	{"01", "Nota De ?"	},;
		{"02", "Nota Ate ?"	},;
		{"03", "Série ?"	}}

	// Verifica se o SX1 está correto.
	SX1->(DbSetOrder(1))
	For nI := 1 To Len(aSX1)
		If SX1->(DbSeek(PadR(cPerg,10) + aSX1[nI][1]))
			If AllTrim(SX1->X1_PERGUNT) <> AllTrim(aSX1[nI][2])
				lAjuste := .T.
				Exit
			EndIf
		Else
			lAjuste := .T.
			Exit
		EndIf
	Next

	If lAjuste

		SX1->(DbSetOrder(1))
		If SX1->(DbSeek(AllTrim(cPerg)))
			While SX1->(!EOF()) .and. AllTrim(SX1->X1_GRUPO) == AllTrim(cPerg)

				SX1->(RecLock("SX1",.F.))
				SX1->(DbDelete())
				SX1->(MsUnlock())

				SX1->(DbSkip())
			EndDo
		EndIf

		aHlpPor := {}
		Aadd( aHlpPor, "Informe a Nota Inicial a partir da qual")
		Aadd( aHlpPor, "se deseja imprimir o relatório.")
		Aadd( aHlpPor, "Caso queira imprimir todas as notas,")
		Aadd( aHlpPor, "deixe esse campo em branco.")

		CRIASX1(cPerg,"01","Nota De ?","Nota De ?","Nota De ?","mv_ch1","C",9,0,0,"G","","","","S","mv_par01","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

		aHlpPor := {}
		Aadd( aHlpPor, "Informe a Nota Final até a qual")
		Aadd( aHlpPor, "se desejá imprimir o relatório.")
		Aadd( aHlpPor, "Caso queira imprimir todas as notas ")
		Aadd( aHlpPor, "preencha este campo com 'ZZZZZZZZZ'.")

		CRIASX1(cPerg,"02","Nota Ate ?","Nota Ate ?","Nota Ate ?","mv_ch2","C",9,0,0,"G","","","","S","mv_par02","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

		aHlpPor := {}
		Aadd( aHlpPor, "Informe a Série da qual")
		Aadd( aHlpPor, "se desejá imprimir o relatório.")

		CRIASX1(cPerg,"03","Série ?","Série ?","Série ?","mv_ch3","C",3,0,0,"G","","","","S","mv_par03","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

	EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRIASX1   ºAutor  ³Ciro Pedreira       º Data ³  08/03/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria as perguntas do relatorio no SX1.                      º±±
±±º          ³Função baseada no PutSx1(), que na versão 12 foi descontinu-º±±
±±º          ³ada.                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LS Selection                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CRIASX1(_cGrupo, _cOrdem, _cPergunt, _cPerSpa, _cPerEng, _cVar, _cTipo, _nTamanho, _nDecimal, _nPresel, _cGSC, _cValid,;
		_cF3, _cGrpSxg, _cPyme, _cVar01, _cDef01, _cDefSpa1, _cDefEng1, _cCnt01, _cDef02, _cDefSpa2, _cDefEng2,;
		_cDef03, _cDefSpa3, _cDefEng3, _cDef04, _cDefSpa4, _cDefEng4, _cDef05, _cDefSpa5, _cDefEng5, _aHelpPor, _aHelpEng, _aHelpSpa, _cHelp)

	Local _aAreaMem := GetArea()
	Local _cKey     := ''
	Local _lPort    := .F.
	Local _lSpa     := .F.
	Local _lIngl    := .F.

	_cKey := "P." + AllTrim(_cGrupo) + AllTrim(_cOrdem) + "."

	_cPyme   := Iif(_cPyme   == Nil, "", _cPyme)
	_cF3     := Iif(_cF3     == Nil, "", _cF3)
	_cGrpSxg := Iif(_cGrpSxg == Nil, "", _cGrpSxg)
	_cCnt01  := Iif(_cCnt01  == Nil, "", _cCnt01)
	_cHelp   := Iif(_cHelp   == Nil, "", _cHelp)

	SX1->(DbSetOrder(1)) // Indice 1 - X1_GRUPO+X1_ORDEM

	// Ajusta o tamanho do grupo.
	_cGrupo := PadR(_cGrupo, Len(SX1->X1_GRUPO), " ")

	If SX1->(!DbSeek(_cGrupo+_cOrdem))

		_cPergunt := If(!"?" $ _cPergunt .And. !Empty(_cPergunt), AllTrim(_cPergunt) + "?", _cPergunt)
		_cPerSpa  := If(!"?" $ _cPerSpa .And. !Empty(_cPerSpa), AllTrim(_cPerSpa) + "?" , _cPerSpa)
		_cPerEng  := If(!"?" $ _cPerEng .And. !Empty(_cPerEng), AllTrim(_cPerEng) + "?" , _cPerEng)

		RecLock("SX1", .T.)

		SX1->X1_GRUPO   := _cGrupo
		SX1->X1_ORDEM   := _cOrdem
		SX1->X1_PERGUNT := _cPergunt
		SX1->X1_PERSPA  := _cPerSpa
		SX1->X1_PERENG  := _cPerEng
		SX1->X1_VARIAVL := _cVar
		SX1->X1_TIPO    := _cTipo
		SX1->X1_TAMANHO := _nTamanho
		SX1->X1_DECIMAL := _nDecimal
		SX1->X1_PRESEL  := _nPresel
		SX1->X1_GSC     := _cGSC
		SX1->X1_VALID   := _cValid

		SX1->X1_VAR01   := _cVar01

		SX1->X1_F3      := _cF3
		SX1->X1_GRPSXG  := _cGrpSxg

		If SX1->(ColumnPos("X1_PYME")) > 0
			If _cPyme != Nil
				SX1->X1_PYME := _cPyme
			EndIf
		EndIf

		SX1->X1_CNT01 := _cCnt01

		If _cGSC == "C" // Multiplas escolhas.

			SX1->X1_DEF01   := _cDef01
			SX1->X1_DEFSPA1 := _cDefSpa1
			SX1->X1_DEFENG1 := _cDefEng1

			SX1->X1_DEF02   := _cDef02
			SX1->X1_DEFSPA2 := _cDefSpa2
			SX1->X1_DEFENG2 := _cDefEng2

			SX1->X1_DEF03   := _cDef03
			SX1->X1_DEFSPA3 := _cDefSpa3
			SX1->X1_DEFENG3 := _cDefEng3

			SX1->X1_DEF04   := _cDef04
			SX1->X1_DEFSPA4 := _cDefSpa4
			SX1->X1_DEFENG4 := _cDefEng4

			SX1->X1_DEF05   := _cDef05
			SX1->X1_DEFSPA5 := _cDefSpa5
			SX1->X1_DEFENG5 := _cDefEng5

		EndIf

		SX1->X1_HELP := _cHelp

		PutSX1Help(_cKey, _aHelpPor, _aHelpEng, _aHelpSpa)

		SX1->(MsUnlock())

	Else

		_lPort := !"?" $ SX1->X1_PERGUNT .And. !Empty(SX1->X1_PERGUNT)
		_lSpa  := !"?" $ SX1->X1_PERSPA .And. !Empty(SX1->X1_PERSPA)
		_lIngl := !"?" $ SX1->X1_PERENG .And. !Empty(SX1->X1_PERENG)

		If _lPort .Or. _lSpa .Or. _lIngl

			RecLock("SX1", .F.)

			If _lPort
				SX1->X1_PERGUNT := AllTrim(SX1->X1_PERGUNT) + "?"
			EndIf
			If _lSpa
				SX1->X1_PERSPA := AllTrim(SX1->X1_PERSPA) + "?"
			EndIf
			If _lIngl
				SX1->X1_PERENG := AllTrim(SX1->X1_PERENG) + "?"
			EndIf

			SX1->(MsUnLock())

		EndIf

	EndIf

	RestArea(_aAreaMem)

Return
