#include "totvs.ch"
#include 'fwmvcdef.ch'
#include "rptdef.ch"
#include "fwprintsetup.ch"
#include "tbiconn.ch"
#include 'protheus.ch'
#INCLUDE "TOPCONN.CH"

/*
Funcao      : V5FAT018()
Parametros  : lPreview
Retorno     : Nenhum
Objetivos   : Impressão de nota de serviço da prefeitura do Rio de Janeiro.
Autor       : Iago Bernardes
Cliente		: Vogel
Data/Hora   : 29/11/2019
*/

User Function V5FAT018(lV5FAT, lVisua, _lCapa, _oCapa, _cNaoAut, _lWs)

	Local lExec := .T.

	Private oPrinter

	Private cLocal := ''
	Private cFile  := ""
	Private cPerg  := "V5FAT018"

	Private lVisual	:= IIF(ValType(lVisua) <> "L", .T., lVisua)
	Private lV5FAT1	:= IIF(ValType(lV5FAT) <> "L", .F., lV5FAT)

	Default _cNaoAut := ''
	Default _lWs     := .F.
	Default _lCapa   := .F.

	VarInfo("V5FAT018 - _oCapa", _oCapa)

	cLocal := IIf(!_lWs, GetTempPath(), '')

	If !lV5FAT1
		// Verifica os parâmetros do relatório.
		CriaPerg(cPerg)
		If !Pergunte (cPerg,.T.)
			Return Nil
		EndIF
	Else
		// Caso venha pela rotina automatica.
		MV_PAR01 := SF2->F2_DOC
		MV_PAR02 := SF2->F2_DOC
		MV_PAR03 := SF2->F2_SERIE
	EndIf
//
	If Select('SQL') > 0
		SQL->(DbCloseArea())
	EndIf

	cQuery := "SELECT R_E_C_N_O_ SF2REC, F2_DOC, F2_SERIE "
	cQuery += "FROM " + RetSQLName("SF2") + " "
	cQuery += "WHERE (F2_DOC >= '" + MV_PAR01 + "' AND F2_DOC <= '" + MV_PAR02 + "') "
	cQuery += "AND F2_SERIE = '" + MV_PAR03 + "' "
	cQuery += "AND F2_ESPECIE = 'NFPS' "
	cQuery += "AND D_E_L_E_T_ <> '*' "
	cQuery += "AND F2_FILIAL = '" + xFilial("SF2") + "' "
	cQuery += "ORDER BY F2_EMISSAO+F2_DOC+F2_SERIE"

	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "SQL", .T., .T.)

	If SQL->(EOF()) .OR. SQL->(BOF())
		lExec := .F.
	EndIf

	If lExec
		Processa({|| cFile := MONTAREL(_lCapa, _oCapa, @_cNaoAut, _lWs)})
	Else
		If !_lWs
			Aviso("Aviso", "Não existem informações.", {"Ok"}, 2)
		Else
			Conout("Não existem informações.")
		EndIf
	EndIf

	SQL->(DbCloseArea())

	If _lCapa .And. Empty(_cNaoAut)
		_oCapa := oPrinter
	EndIf

Return (cFile)

/*
Função  : MONTAREL
Retorno : cFile
Objetivo: Gera o relatório
Autor   : Ciro Pedreira
Data    : 01/06/2018
*/
Static Function MONTAREL(_lCapa, _oCapa, _cNaoAut, _lWs)

	ProcRegua(0)

	While SQL->(!EOF())

		SF2->(DbGoTo(SQL->SF2REC))

		If !Empty(SF2->F2_CODNFE)

			cFile := GERAREL(_lCapa, _oCapa, _lWs)

		Else

			If !Empty(_cNaoAut)
				_cNaoAut += CRLF
			EndIf

			_cNaoAut += AllTrim(SF2->F2_DOC) + ' - ' + AllTrim(SF2->F2_SERIE)

			If !_lCapa

				If _lWs
					Alert('Nota fiscal não autorizada pela prefeitura! Nota fiscal: ' + AllTrim(SF2->F2_DOC) + ' - ' + AllTrim(SF2->F2_SERIE) + '.')
				Else
					Conout('Nota fiscal não autorizada pela prefeitura! Nota fiscal: ' + AllTrim(SF2->F2_DOC) + ' - ' + AllTrim(SF2->F2_SERIE) + '.')
				EndIf

			EndIf

		EndIf

		SQL->(DbSkip())

	EndDo

Return cFile

/*
Função  : GERAREL
Retorno : cFile
Objetivo: Gera o relatório
Autor   : Ciro Pedreira
Data    : 01/06/2018
*/

Static Function GERAREL(_lCapa, _oCapa, _lWs)

	Local nCont := 0
	Private oFont6n  := TFont():New("Arial",3, 6,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oFont6   := TFont():New("Arial",3, 6,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFont7   := TFont():New("Arial",3, 7,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFont7n  := TFont():New("Arial",3, 7,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oFont8   := TFont():New('Arial',3, 8,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFont8n  := TFont():New('Arial',3, 8,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oFont9   := TFont():New('Arial',3, 9,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFont9n  := TFont():New('Arial',3, 9,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oFont10  := TFont():New('Arial',3, 10,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFont10n := TFont():New('Arial',3, 10,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oFont11n := TFont():New('Arial',3, 11,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oFont12  := TFont():New("Arial",3, 12,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFont12n := TFont():New("Arial",3, 12,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oFont13  := TFont():New("Arial",3, 13,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFont14  := TFont():New("Arial",3, 14,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFont14n := TFont():New("Arial",3, 14,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oFont17  := TFont():New('Arial',3, 17,,.F.)
	Private oFont17n := TFont():New('Arial',3, 17,,.T.)

	Private nSalto  := 10
	Private nLin    := 0
	Private cNomeArq		:= 'fatura_'+cFilAnt+"_"+Alltrim(SQL->F2_DOC)+"_"+Alltrim(SQL->F2_SERIE)
	///Private cNomeArq := 'NFSe_RJ_' + Alltrim(SQL->F2_DOC) + GravaData(Date(), .F., 5) + SubStr(Time(), 1, 2) + SubStr(Time(), 4, 2) + SubStr(Time(), 7, 2)
	Private cDirBol  := "\FTP\" + cEmpAnt + "\V5FAT018\"

	Private _nCol    := 0
	Private _nColMax := 0
	Private _nLinMax := 0

	If !LisDir(cDirBol)
		MakeDir("\FTP")
		MakeDir("\FTP\" + cEmpAnt)
		MakeDir("\FTP\" + cEmpAnt + "\V5FAT018\")
	EndIf

	VarInfo("V5FAT018 - _lCapa", _lCapa)
	//Protecao contra arquivo .rel
	If File(cLocal+cNomeArq + ".pdf")
		lErroArq := .T.
		While nCont < 10
			If FErase(cLocal+cNomeArq + ".pdf") == 0
				lErroArq := .F.
				Exit
			Endif
			nCont++

			If nCont == 0
				Return .F.
			Endif

		EndDo
	Endif
	If !_lCapa

		If !lVisual
			oPrinter:= FWMSPrinter():New(cNomeArq,IMP_PDF,.F.,,.T.,.F.,,,,,,.F.,0)
		Else
			oPrinter:= FWMSPrinter():New(cNomeArq,IMP_PDF,.F.,,.T.,.F.,,,,,,.T.,0)
		EndIf

		// Ordem obrigatoria de configuração do relatório.
		oPrinter:SetResolution(72)
		oPrinter:SetPortrait() // Retrato ou SetLandScape para paisagem.
		oPrinter:SetPaperSize(9)
		oPrinter:SetMargin(0,0,0,0)
		If !_lWs
			oPrinter:cPathPDF := cLocal
		Else
			oPrinter:cPathPDF := cDirBol
			oPrinter:lServer := _lWs
		EndIf

	Else

		oPrinter := _oCapa

		VarInfo("V5FAT018 - Definindo objeto do relatorio _oCapa", _oCapa)
		VarInfo("V5FAT018 - Definindo objeto do relatorio oPrinter", oPrinter)

	EndIf

	_nColMax := 870 //oPrinter:nHorzSize()
	_nLinMax := 810 //oPrinter:nVertSize()

	//Impressao do cabecalho do relatorio
	cFile := IMPNF(@nLin, _lCapa, _oCapa, _lWs)

	If !_lCapa

		oPrinter := Nil

	EndIf

Return (cFile)

/*
Função  : IMPNF
Retorno : cFile
Objetivo: Gera o relatório
Autor   : Ciro Pedreira
Data    : 10/06/2018
*/
Static Function IMPNF(nLin, _lCapa, _oCapa, _lWs)

	Local cDesc     := ""
	Local _cLogo    := '\system\logo_rio_de_janeiro.png'
	Local _nPosPV   := 0
	Local _cEmail   := ''
	Local _cEmailPs := 'nf-e@vogeltelecom.com'
	Local _cLogoEmp := "\system\lgrlv5.bmp"
	Local _nTotRet  := 0
	Local _cPicture := ''
	Local _cOperNat := '1'
	Local _nRetISS  := 0
	Local cServico  :=  SuperGetMV('ES_SERV08',, '107')
	Local _cXSTT    := ""
	Local vecto     := ""
	VarInfo("V5FAT018 - IMPNF", oPrinter)

	oPrinter:StartPage()

	SF2->(DbGoTo(SQL->SF2REC))

	SA1->(DbSetOrder(1)) // Indice 1 - A1_FILIAL+A1_COD+A1_LOJA
	SA1->(DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))

	SE1->(DbSetOrder(2)) // Indice 2 - E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	SE1->(DbSeek(xFilial("SE1")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_PREFIXO+SF2->F2_DUPL+Space(TamSX3("E1_PARCELA")[1])+"NF"))

	SD2->(DbSetOrder(3)) // Indice 3 - D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	SD2->(DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))

	SB1->(DbSetOrder(1)) // Indice 1 - B1_FILIAL+B1_COD
	SB1->(DbSeek(xFilial('SB1')+SD2->D2_COD))

	SC5->(DbSetOrder(1)) // Indice 1 - C5_FILIAL+C5_NUM
	SC5->(DbSeek(xFilial("SD2")+SD2->D2_PEDIDO))

	SF4->(DbSetOrder(1)) // Indice 1 - F4_FILIAL+F4_CODIGO
	SF4->(DbSeek(xFilial('SF4')+SD2->D2_TES))

	_nCol := 30

	nLin += nSalto

	// BOX OUTRAS INFORMAÇÕES
	oPrinter:Box(	nLin	, _nCol		, _nLinMax - 200	, _nColMax - 300	, "-4"	)
	oPrinter:Box(	nLin	, _nCol		, 505				, _nColMax - 300	, "-4"	)

	// BOX DEDUÇÕES E ALÍQUOTAS
	oPrinter:Box(	nLin	, _nCol		, 480				, _nColMax - 300	, "-4"	)
	oPrinter:Box(	nLin	, 120		, 480				, _nColMax - 300	, "-4"	)
	oPrinter:Box(	nLin	, 210		, 480				, _nColMax - 300	, "-4"	)
	oPrinter:Box(	nLin	, 300		, 480				, _nColMax - 300	, "-4"	)
	oPrinter:Box(	nLin	, 390		, 480				, _nColMax - 300	, "-4"	)
	oPrinter:Box(	nLin	, 480		, 480				, _nColMax - 300	, "-4"	)

	// BOX SERVIÇO PRESTADO
	oPrinter:Box(	nLin	, _nCol		, 455				, _nColMax - 300	, "-4"	)

	// BOX VALOR DA NOTA
	oPrinter:Box(	nLin	, _nCol		, 430				, _nColMax - 300	, "-4"	)

	// BOX DISCRIMINAÇÃO DOS SERVIÇOS
	oPrinter:Box(	nLin	, _nCol		, 410				, _nColMax - 300	, "-4"	)
	oPrinter:Box(	nLin	, _nCol		, 215				, _nColMax - 300	, "-4"	)

	// BOX TOMADOR DE SERVIÇOS
	oPrinter:Box(	nLin	, _nCol		, 195				, _nColMax - 300	, "-4"	)

	// BOX PRESTADOR DE SERVIÇOS
	oPrinter:Box(	nLin	, _nCol		, 135				, _nColMax - 300	, "-4"	)

	// BOX (PREFEITURA DA CIDADE DO RIO DE JANEIRO)
	oPrinter:Box(	nLin	, _nCol		, 065				, _nColMax - 300	, "-4"	)
	oPrinter:Box(	nLin	, 475		, 065				, _nColMax - 300	, "-4"	)
	oPrinter:Box(	nLin	, 475		, 046				, _nColMax - 300	, "-4"	)
	oPrinter:Box(	nLin	, 475		, 028				, _nColMax - 300	, "-4"	)

	_nCol := 50


	// Logo da prefeitura.
	oPrinter:SayBitmap(nLin + 5, _nCol , _cLogo, 35, 47)

	_nCol := 480

	nLin += nSalto
	oPrinter:SayAlign(nLin, 170, "PREFEITURA DA CIDADE DO RIO DE JANEIRO",oFont14n, 500, 500, CLR_BLACK, 0, 1)
	oPrinter:SayAlign(nLin - 7, _nCol, "Número da Nota", oFont7n, 500, 500, CLR_BLACK, 0, 1)
	oPrinter:SayAlign(nLin, _nCol, AllTrim(SF2->F2_NFELETR), oFont7, 500, 500, CLR_BLACK, 0, 1)

	nLin += nSalto
	oPrinter:SayAlign(nLin + 5, 200, "SECRETARIA MUNICIPAL DE FAZENDA",oFont11n, 500, 500, CLR_BLACK, 0, 1)
	oPrinter:SayAlign(nLin, _nCol, "Data e Hora de Emissão", oFont7n, 500, 500, CLR_BLACK, 0, 1)
	oPrinter:SayAlign(nLin + 7, _nCol, DToC(SF2->F2_EMINFE), oFont7, 500, 500, CLR_BLACK, 0, 1)

	nLin += nSalto
	oPrinter:SayAlign(nLin + 5, 170, "NOTA FISCAL DE SERVIÇOS ELETRÔNICA - NFS-e",oFont12n, 500, 500, CLR_BLACK, 0, 1)
	oPrinter:SayAlign(nLin + 7, _nCol, "Código de Verificação:", oFont7n, 500, 500, CLR_BLACK, 0, 1)
	oPrinter:SayAlign(nLin + 14, _nCol, AllTrim(SF2->F2_CODNFE), oFont7, 500, 500, CLR_BLACK, 0, 1)

	_nCol := 50

	nLin += nSalto
	// Logo da empresa.
	oPrinter:SayBitmap(nLin + 20, _nCol, _cLogoEmp, 90, 45)

	_nCol := 150

	// Prestador do serviço.

	nLin += nSalto * 2
	oPrinter:SayAlign(nLin, 250, "PRESTADOR DE SERVIÇOS",oFont10n, 500, 500, CLR_BLACK, 0, 1)

	nLin += nSalto
	oPrinter:SayAlign(nLin, _nCol, "CPF/CNPJ: " + AllTrim(Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")),oFont9n, 500, 500, CLR_BLACK, 0, 1)
	oPrinter:SayAlign(nLin, _nCol + 150, "Inscrição Municipal: " + AllTrim(SM0->M0_INSCM),oFont9n, 500, 500, CLR_BLACK, 0, 1)
	oPrinter:SayAlign(nLin, _nCol + 300, "Inscrição Estadual: " + AllTrim(SM0->M0_INSC),oFont9n, 500, 500, CLR_BLACK, 0, 1)

	nLin += nSalto
	oPrinter:SayAlign(nLin, _nCol, "Nome/Razão Social: " + AllTrim(SM0->M0_NOMECOM),oFont9n, 500, 500, CLR_BLACK, 0, 1)
	oPrinter:SayAlign(nLin, _nCol + 305, "Tel: " + AllTrim(SM0->M0_TEL),oFont9n, 500, 500, CLR_BLACK, 0, 1)

	nLin += nSalto
	oPrinter:SayAlign(nLin, _nCol, "Nome Fantasia: " + AllTrim(SM0->M0_NOME),oFont9n, 500, 500, CLR_BLACK, 0, 1)

	nLin += nSalto
	oPrinter:SayAlign(nLin, _nCol, "Endereço: " + AllTrim(SM0->M0_ENDENT) + " " + AllTrim(Capital(SM0->M0_COMPENT)) + ' - ' + AllTrim(Capital(SM0->M0_BAIRCOB)) + ' - CEP: ' + AllTrim(Transform(SM0->M0_CEPCOB,"@R 99999-999")),oFont9n, 500, 500, CLR_BLACK, 0, 1)

	nLin += nSalto
	oPrinter:SayAlign(nLin, _nCol, "Município: " + AllTrim(Capital(SM0->M0_CIDCOB)),oFont9n, 500, 500, CLR_BLACK, 0, 1)
	oPrinter:SayAlign(nLin, _nCol + 200, "UF: " + AllTrim(SM0->M0_ESTCOB),oFont9n, 500, 500, CLR_BLACK, 0, 1)
	oPrinter:SayAlign(nLin, _nCol + 275, 'Email: ' + _cEmailPs,oFont9n, 500, 500, CLR_BLACK, 0, 1)
	_nCol := 50

	nLin += nSalto * 2
	// Tomador do serviço.
	oPrinter:SayAlign(nLin, 250, "TOMADOR DE SERVIÇOS",oFont10n, 500, 500, CLR_BLACK, 0, 1)

	nLin += nSalto
	If SA1->A1_PESSOA == "F"
		oPrinter:SayAlign(nLin, _nCol, "CPF/CNPJ: " + AllTrim(Transform(SA1->A1_CGC,"@R 999.999.999-99")),oFont9n, 500, 500, CLR_BLACK, 0, 1)
	Else
		oPrinter:SayAlign(nLin, _nCol, "CPF/CNPJ: " + AllTrim(Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")),oFont9n, 500, 500, CLR_BLACK, 0, 1)
	EndIf
	oPrinter:SayAlign(nLin, _nCol + 200, "Inscrição Municipal: " + AllTrim(SA1->A1_INSCRM),oFont9n, 500, 500, CLR_BLACK, 0, 1)
	oPrinter:SayAlign(nLin, _nCol + 350, "Inscrição Estadual: " + AllTrim(SA1->A1_INSCR),oFont9n, 500, 500, CLR_BLACK, 0, 1)

	nLin += nSalto
	oPrinter:SayAlign(nLin, _nCol, "Nome/Razão Social: " + AllTrim(SA1->A1_NOME),oFont9n, 500, 500, CLR_BLACK, 0, 1)
	oPrinter:SayAlign(nLin, _nCol + 300, "Tel: " + Alltrim(AllTrim(SA1->A1_DDD) + " " + AllTrim(SA1->A1_TEL)),oFont9n, 500, 500, CLR_BLACK, 0, 1)

	nLin += nSalto
	oPrinter:SayAlign(nLin, _nCol, "Endereço: " + AllTrim(Capital(SA1->A1_END)) + " " + AllTrim(Capital(SA1->A1_COMPLEM)) + ' - ' + AllTrim(Capital(SA1->A1_BAIRRO)) + ' - CEP: ' + AllTrim(Transform(SA1->A1_CEP,"@R 99999-999")),oFont9n, 500, 500, CLR_BLACK, 0, 1)

	nLin += nSalto
	oPrinter:SayAlign(nLin, _nCol, "Município: " + AllTrim(Capital(SA1->A1_MUN)),oFont9n, 500, 500, CLR_BLACK, 0, 1)
	oPrinter:SayAlign(nLin, _nCol + 200, "UF: " + AllTrim(SA1->A1_EST),oFont9n, 500, 500, CLR_BLACK, 0, 1)

	_nPosPV := At(';', SA1->A1_EMAIL)
	If _nPosPV > 0
		_cEmail := AllTrim(SubStr(SA1->A1_EMAIL, 1, _nPosPV - 1))
	Else
		_cEmail := AllTrim(SA1->A1_EMAIL)
	EndIf

	oPrinter:SayAlign(nLin, _nCol + 275, 'Email: ' + _cEmail,oFont9n, 500, 500, CLR_BLACK, 0, 1)

	_nCol := 50

	nLin += nSalto * 2
	oPrinter:SayAlign(nLin, 250, "DISCRIMINAÇÃO DOS SERVIÇOS",oFont10n, 500, 500, CLR_BLACK, 0, 1)

	// Descricao do produto.
	SC6->(DbSetOrder(1))
	If SC6->(DbSeek(xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV+SD2->D2_COD))
		cDesc := AllTrim(SC6->C6_DESCRI)
	Else
		cDesc := AllTrim(SB1->B1_DESC)
	EndIf

	_cXSTT := ""

	_cNota  := SF2->F2_DOC
	_cSerie := SF2->F2_SERIE

	If Select("QRY") > 0
		dbSelectArea("QRY")
		QRY->(dbCloseArea())
	EndIf

	cQuery2 := "SELECT C6_XSTT,C6_NOTA, C6_SERIE "
	cQuery2 += "FROM " + RetSQLName("SC6") + " "
	cQuery2 += "WHERE C6_NOTA = '" + _cNota +  "' "
	cQuery2 += "AND C6_SERIE = '" + _cSerie + "' "
	cQuery2 += "AND D_E_L_E_T_ <> '*' "
	cQuery2 += "AND C6_FILIAL = '" + xFilial("SC6") + "' "
	cQuery2 += "GROUP BY C6_XSTT,C6_NOTA, C6_SERIE  "
	cQuery2 += "ORDER BY C6_XSTT,C6_NOTA, C6_SERIE  "

	TcQuery cQuery2 New Alias "QRY"

	DbSelectArea('QRY')
	QRY->(dbGoTop())

	nLin += nSalto * 2

	While QRY->(!Eof())

		If alltrim(QRY->C6_XSTT) <> ""
			If !(alltrim(QRY->C6_XSTT) $(cDesc))
				_cXSTT += " / "+alltrim(QRY->C6_XSTT)
			EndIf
		EndIf
		QRY->(DbSkip())
	End

	cDesc := cDesc + _cXSTT
	nDesc := Len(cDesc)

	cDesc1 := AllTrim(SubStr(AllTrim(cDesc), 1, 130))
	cDesc2 := AllTrim(SubStr(AllTrim(cDesc), 131, 130))
	cDesc3 := AllTrim(SubStr(AllTrim(cDesc), 261, 130))
	cDesc4 := AllTrim(SubStr(AllTrim(cDesc), 391, 130))
	cDesc5 := AllTrim(SubStr(AllTrim(cDesc), 521, 130))
	cDesc6 := AllTrim(SubStr(AllTrim(cDesc), 651, 130))
	cDesc7 := AllTrim(SubStr(AllTrim(cDesc), 781, 130))
	cDesc8 := AllTrim(SubStr(AllTrim(cDesc), 911, 130))
	cDesc9 := AllTrim(SubStr(AllTrim(cDesc), 1041, 130))
	cDesc10:= AllTrim(SubStr(AllTrim(cDesc), 1171, 130))

	If cDesc1 <> ""
		oPrinter:SayAlign(nLin, _nCol, cDesc1, oFont8, 500, 500, CLR_BLACK, 0, 1)
		nLin += nSalto
	EndIf
	If cDesc2 <> ""
		oPrinter:SayAlign(nLin, _nCol, cDesc2, oFont8, 500, 500, CLR_BLACK, 0, 1)
		nLin += nSalto
	EndIf

	If cDesc3 <> ""
		oPrinter:SayAlign(nLin, _nCol, cDesc3, oFont8, 500, 500, CLR_BLACK, 0, 1)
		nLin += nSalto
	EndIf
	If cDesc4 <> ""
		oPrinter:SayAlign(nLin, _nCol, cDesc4, oFont8, 500, 500, CLR_BLACK, 0, 1)
		nLin += nSalto
	EndIf
	If cDesc5 <> ""
		oPrinter:SayAlign(nLin, _nCol, cDesc5, oFont8, 500, 500, CLR_BLACK, 0, 1)
		nLin += nSalto
	EndIf
	If cDesc6 <> ""
		oPrinter:SayAlign(nLin, _nCol, cDesc6, oFont8, 500, 500, CLR_BLACK, 0, 1)
		nLin += nSalto
	EndIf

	If cDesc7 <> ""
		oPrinter:SayAlign(nLin, _nCol, cDesc7, oFont8, 500, 500, CLR_BLACK, 0, 1)
		nLin += nSalto
	EndIf

	If cDesc8 <> ""
		oPrinter:SayAlign(nLin, _nCol, cDesc8, oFont8, 500, 500, CLR_BLACK, 0, 1)
		nLin += nSalto
	EndIf

	If cDesc9 <> ""
		oPrinter:SayAlign(nLin, _nCol, cDesc9, oFont8, 500, 500, CLR_BLACK, 0, 1)
		nLin += nSalto
	EndIf

	If cDesc10 <> ""
		oPrinter:SayAlign(nLin, _nCol, cDesc10, oFont8, 500, 500, CLR_BLACK, 0, 1)
		nLin += nSalto*2
	EndIf

/*	If Len(cDesc) > 73
		oPrinter:SayAlign(nLin, _nCol, AllTrim(SubStr(AllTrim(cDesc), 1, 72)), oFont8, 500, 500, CLR_BLACK, 0, 1)
		nLin += nSalto
		oPrinter:SayAlign(nLin, _nCol, AllTrim(SubStr(AllTrim(cDesc), 73)), oFont8, 500, 500, CLR_BLACK, 0, 1)
Else
		oPrinter:SayAlign(nLin, _nCol, AllTrim(cDesc), oFont8, 500, 500, CLR_BLACK, 0, 1)
EndIf
*/	
nLin += nSalto*2
//oPrinter:SayAlign(nLin, _nCol, AllTrim(SC5->C5_MENNOTA), oFont8, 500, 500, CLR_BLACK, 0, 1)
oPrinter:SayAlign(nLin, _nCol, RetMenNota(), oFont8, 500, 500, CLR_BLACK, 0, 1)

nLin += nSalto * 3
_nVpcc := 0
If SF2->(F2_VALCSLL + F2_VALCOFI + F2_VALPIS) >= 10
	_nVpcc := SF2->(F2_VALCSLL + F2_VALCOFI + F2_VALPIS)
	oPrinter:SayAlign(nLin+1, 034, "Ret.COFINS(R$)",oFont7, 500, 500, CLR_BLACK, 0, 1)
	oPrinter:SayAlign(nLin+1, 114, "Ret.CSLL(R$)",oFont7, 500, 500, CLR_BLACK, 0, 1)
	oPrinter:SayAlign(nLin+1, 194, "Ret.INSS(R$)",oFont7, 500, 500, CLR_BLACK, 0, 1)
	oPrinter:SayAlign(nLin+1, 274, "Ret.IR(R$)",oFont7, 500, 500, CLR_BLACK, 0, 1)
	oPrinter:SayAlign(nLin+1, 354, "Ret.PIS (R$)",oFont7, 500, 500, CLR_BLACK, 0, 1)
//	oPrinter:SayAlign(nLin+1, 434, "Outras Retenções(R$)",oFont7, 500, 500, CLR_BLACK, 0, 1)
	nLin += nSalto
	oPrinter:SayAlign(nLin, 034, Transform(SF2->F2_VALCOFI, PesqPict('SF2', 'F2_VALCOFI')),oFont7n, 500, 500, CLR_BLACK, 0, 1)
	oPrinter:SayAlign(nLin, 114, Transform(SF2->F2_VALCSLL, PesqPict('SF2', 'F2_VALCSLL')),oFont7n, 500, 500, CLR_BLACK, 0, 1)
	oPrinter:SayAlign(nLin, 194, Transform(SF2->F2_VALINSS, PesqPict('SF2', 'F2_VALINSS')),oFont7n, 500, 500, CLR_BLACK, 0, 1)
	oPrinter:SayAlign(nLin, 274, Transform(SF2->F2_VALIRRF, PesqPict('SF2', 'F2_VALIRRF')),oFont7n, 500, 500, CLR_BLACK, 0, 1)
	oPrinter:SayAlign(nLin, 354, Transform(SF2->F2_VALPIS, PesqPict('SF2', 'F2_VALPIS')),oFont7n, 500, 500, CLR_BLACK, 0, 1)
//	oPrinter:SayAlign(nLin, 434, Transform(0, PesqPict('SF2', 'F2_VALISS')),oFont7n, 500, 500, CLR_BLACK, 0, 1)
Endif


nLin := 410
oPrinter:SayAlign(nLin + 5, 230, "VALOR TOTAL DA NOTA = R$ " + AllTrim(Transform(SF2->F2_VALBRUT, PesqPict('SF2', 'F2_VALBRUT'))),oFont11n, 500, 500, CLR_BLACK, 0, 1)

nLin += nSalto * 2
oPrinter:SayAlign(nLin + 3, _nCol, "Serviço Prestado",oFont7, 500, 500, CLR_BLACK, 0, 1)

SX5->(DbSetOrder(1)) // Indice 1 - X5_FILIAL+X5_TABELA+X5_CHAVE
//SX5->(DbSeek(xFilial('SX5')+'60'+SB1->B1_CODISS)) //MARCELO 04/02/21
SX5->(DbSeek(xFilial('SX5')+'60'+SD2->D2_CODISS)) //MARCELO 04/02/21

nLin += nSalto
//oPrinter:SayAlign(nLin + 3, _nCol, AllTrim(SB1->B1_TRIBMUN) + " / " + AllTrim(Capital(SX5->X5_DESCRI)),oFont7n, 500, 500, CLR_BLACK, 0, 1)
oPrinter:SayAlign(nLin - 1, _nCol, AllTrim(Posicione('SBZ',1,xFilial('SBZ')+SB1->B1_COD,'BZ_TRIBMUN')) + " / " + AllTrim(Capital(SX5->X5_DESCRI)),oFont7n, 500, 500, CLR_BLACK, 0, 1) //Marcelo 04/02/21
nLin += nSalto * 2
//	oPrinter:SayAlign(nLin + 1, 034, "IR",oFont7, 500, 500, CLR_BLACK, 0, 1)
oPrinter:SayAlign(nLin + 1, 055, "Deduções (R$)",oFont7, 500, 500, CLR_BLACK, 0, 1)
oPrinter:SayAlign(nLin + 1, 135, "Desconto Incond. (R$)",oFont7, 500, 500, CLR_BLACK, 0, 1)
oPrinter:SayAlign(nLin + 1, 225, "Base de Cálculo (R$)",oFont7, 500, 500, CLR_BLACK, 0, 1)
oPrinter:SayAlign(nLin + 1, 330, "Aliquota (%)",oFont7, 500, 500, CLR_BLACK, 0, 1)
oPrinter:SayAlign(nLin + 1, 405, "Valor do ISS (R$)",oFont7, 500, 500, CLR_BLACK, 0, 1)
oPrinter:SayAlign(nLin + 1, 510, "Crédito (R$)",oFont7, 500, 500, CLR_BLACK, 0, 1)

nLin += nSalto
// Valores.
//	oPrinter:SayAlign(nLin, 034, Transform(SF2->F2_VALIRRF, PesqPict('SF2', 'F2_VALIRRF')),oFont8, 500, 500, CLR_BLACK, 0, 1)
oPrinter:SayAlign(nLin, 055, Transform(0, PesqPict('SF2', 'F2_VALINSS')),oFont7n, 500, 500, CLR_BLACK, 0, 1)
oPrinter:SayAlign(nLin, 140, Transform(0, PesqPict('SF2', 'F2_VALINSS')),oFont7n, 500, 500, CLR_BLACK, 0, 1)
oPrinter:SayAlign(nLin, 230, Transform(SF2->F2_VALBRUT, PesqPict('SF2', 'F2_VALBRUT')),oFont7n, 500, 500, CLR_BLACK, 0, 1)
oPrinter:SayAlign(nLin, 335, AllTrim(Transform(SD2->D2_ALIQISS, PesqPict('SD2', 'D2_ALIQISS'))) + '%',oFont7n, 500, 500, CLR_BLACK, 0, 1)
oPrinter:SayAlign(nLin, 405, Transform(SF2->F2_VALISS, PesqPict('SF2', 'F2_VALISS')),oFont7n, 500, 500, CLR_BLACK, 0, 1)
oPrinter:SayAlign(nLin, 500, Transform(0, PesqPict('SF2', 'F2_VALPIS')),oFont7n, 500, 500, CLR_BLACK, 0, 1)

nLin += nSalto * 2
oPrinter:SayAlign(nLin, 260, "OUTRAS INFORMAÇÕES",oFont11n, 500, 500, CLR_BLACK, 0, 1)

nLin += nSalto * 2
////	oPrinter:SayAlign(nLin, _nCol, AllTrim(SC5->C5_MENNOTA), oFont8, 500, 500, CLR_BLACK, 0, 1)
oPrinter:SayAlign(nLin, _nCol, RetMenNota(), oFont8, 500, 500, CLR_BLACK, 0, 1)
nLin += nSalto
oPrinter:SayAlign(nLin, _nCol, 'Esta NFS-e foi emitida com respaldo na Lei n° 5.098 de 15/10/2009 e no Descreto n° 32.250 de 11/05/2010', oFont8, 500, 500, CLR_BLACK, 0, 1)
nLin += nSalto
oPrinter:SayAlign(nLin, _nCol, 'PROCON-RJ: Rua da Ajuda, 5 subsolo; www.procon.rj.gov.br', oFont8, 500, 500, CLR_BLACK, 0, 1)
nLin += nSalto

IF MONTH(SF2->F2_EMISSAO) = 01
	dVecto := '20210203'
ElseIF  MONTH(SF2->F2_EMISSAO) = 02
	dVecto := '20210303'
ElseIF  MONTH(SF2->F2_EMISSAO) = 03
	dVecto := '20210406'
ElseIF  MONTH(SF2->F2_EMISSAO) = 04
	dVecto := '20210505'
ElseIF  MONTH(SF2->F2_EMISSAO) = 05
	dVecto := '20210604'
ElseIF  MONTH(SF2->F2_EMISSAO) = 06
	dVecto := '20210705'
ElseIF  MONTH(SF2->F2_EMISSAO) = 07
	dVecto := '20210804'
ElseIF  MONTH(SF2->F2_EMISSAO) = 08
	dVecto := '20210903'
ElseIF  MONTH(SF2->F2_EMISSAO) = 09
	dVecto := '20211005'
ElseIF  MONTH(SF2->F2_EMISSAO) = 10
	dVecto :='20211104'
ElseIF  MONTH(SF2->F2_EMISSAO) = 11
	dVecto := '20211203'
ElseIF  MONTH(SF2->F2_EMISSAO) = 12
	dVecto := '20220105'
Endif

ano := substr(dVecto,1,4)
mes := substr(dVecto,5,2)
dia := substr(dVecto,7,2)
Vecto1 := dia+"/"+mes+"/"+ano

oPrinter:SayAlign(nLin, _nCol, 'Data de vencimento do ISS dessa NFs-e :', oFont8, 500, 500, CLR_BLACK, 0, 1)
oPrinter:SayAlign(nLin, _nCol+150, Vecto1, oFont8, 500, 500, CLR_BLACK, 0, 1)
nLin += nSalto
oPrinter:SayAlign(nLin, _nCol, 'Esta NFS-e substitui o RPS Nº:', oFont8, 500, 500, CLR_BLACK, 0, 1)
oPrinter:SayAlign(nLin, _nCol+150,SF2->F2_DOC, oFont8, 500, 500, CLR_BLACK, 0, 1)
nLin += nSalto

_nValiq := 0
IF _nVpcc >= 10
	_nValiq := SF2->F2_VALBRUT - (_nVpcc +  SF2->F2_VALINSS + SF2->F2_VALIRRF)
Else
	_nValiq := SF2->F2_VALBRUT
Endif
nLin += nSalto
oPrinter:SayAlign(nLin, _nCol, 'Valor Liquido a Pagar: R$ '+ AllTrim(Transform(_nValiq, PesqPict('SF2', 'F2_VALBRUT'))), oFont8, 500, 500, CLR_BLACK, 0, 1)

If !_lWs

	If File(cLocal + cNomeArq + ".pdf")
		FErase(cLocal + cNomeArq + ".pdf")
	EndIf
	cFile := cDirBol + cNomeArq + ".pdf"
	If !_lCapa

		// Visualizar o documento.
		If lVisual
			oPrinter:Preview()
		Else
			oPrinter:Print()
			If CpyT2S(cLocal + cNomeArq + ".pdf", cDirBol, .T.)
				cFile := cDirBol + cNomeArq + ".pdf"
			Else
				MsgStop('Erro na cópia do arquivo PDF para o servidor. Nota ' + cNomeArq + ".pdf")
			EndIf
		EndIf
		lErroArq := ! U_VOGATU10(cDirBol+cNomeArq+".pdf")
	EndIf

Else

	If !_lCapa


		oPrinter:Print()

		cFile := cDirBol + cNomeArq + ".pdf"

	EndIf

EndIf

Return (cFile)

/*
Função  : CriaPerg
Objetivo: Verificar se os parametros estão criados corretamente.
Autor   : Ciro Pedreira
Data    : 01/06/2018
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
//Busca todos os pedidos que compoem a nota para montar a concatenacao do MENNOTA
Static Function RetMenNota()

	Local aArea := GetArea()
	Local cRet := ""
	Local cAliasQry := GetNextAlias()

	BeginSQL Alias cAliasQry

	SELECT C5_MENNOTA
	FROM %TABLE:SC5% SC5
	WHERE C5_FILIAL = %Exp:FWxFilial("SC5")%
	AND C5_NUM IN (
			SELECT DISTINCT D2_PEDIDO  FROM %TABLE:SD2% SD2
        		   WHERE D2_FILIAL = %Exp:FWxFilial("SD2")%
						AND D2_DOC = %Exp:SF2->F2_DOC%
						AND D2_SERIE = %Exp:SF2->F2_SERIE%
			            AND SD2.D_E_L_E_T_ = ''
						) 
			AND C5_FILIAL = %Exp:FWxFilial("SC5")%
            AND SC5.D_E_L_E_T_ = ''  
	
	EndSQL

	While !(cAliasQry)->(EOF())

		cRet += IIf( Empty( Alltrim((cAliasQry)->C5_MENNOTA) ) , '' , Alltrim((cAliasQry)->C5_MENNOTA) + " /" )

		(cAliasQry)->(dbSkip())

	EndDo

	cRet := Left(cRet,Len(cRet)-1)

	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)

Return cRet

