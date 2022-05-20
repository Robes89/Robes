#Include "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#Include "tbiconn.ch"
#INCLUDE 'MSOLE.CH'

#Define CLR_RGB_VERD1		RGB(57,213,45)    //Cor VERDE em RGB
#Define CLR_RGB_VERD2		RGB(224,247,214)  //Cor VERDE em RGB
#Define CLR_RGB_VERD3		RGB(237,252,235)  //Cor VERDE em RGB


/*
Funcao      : V5FAT009()
Parametros  : lPreview
Retorno     : Nenhum
Objetivos   : Impressão de Fatura Telecom
Autor       : Renato Rezende
Cliente		: Vogel
Data/Hora   : 23/08/2016
*/
*-----------------------------------------------*
User Function V5FAT009(lV5FAT, lVisua, _lCapa, _oCapa, _lWs)
	*-----------------------------------------------*
	Local lExec         := .T.
	Local cModelo := "\templates_relatorios\V5FAT009.dot"
	Local cFileDot := "V5FAT009.dot"
	Local lContinua := .T.
	Local nItens := 0

	Private oPrinter
	Private cArqTemp := ""

	Private cLocal		:= ''
	Private cLogo		:= "\system\V5\imagens\logo3.png"
	Private cFile		:= ""
	Private cPerg 	 	:= "V5FAT009"
	Private lVisual		:= IIF(ValType(lVisua)<>"L",.T.,lVisua)
	Private lV5FAT1		:= IIF(ValType(lV5FAT)<>"L",.F.,lV5FAT)


	Default _lCapa := .F.
	Default _lWs   := .F.

	cLocal := IIf(!_lWs, GetTempPath(), '')

	If !(cEmpAnt $ u_EmpVogel())
		If !_lWs
			MsgStop('Empresa nao autorizada para utilizar essa rotina!', 'TOTVS')
		Else
			Conout('Empresa nao autorizada para utilizar essa rotina!')
		EndIf
		Return
	EndIf


	If !File(cModelo)
		If !IsBlind()
			MsgInfo('Modelo .dot não encontrado para o relatório ( ' + cModelo + ' ) ')
		Else
			Conout('Modelo .dot não encontrado para o relatório ( ' + cModelo + ' ) ' )
		Endif

		lContinua := .F.

	EndIf

	If lContinua

		//Copia ele para a estacao local, para trabalhar com ele nela
		If !CpyS2T( cModelo, AllTrim(GetTempPath()))
			lContinua := .F.
			Aviso('ATENÇÃO',;
				'Não foi possível transferir o modelo Word do Servidor para sua estação de trabalho! Tente reiniciar o computador. Caso o problema persista, entre em contato com o Administrador do sistema', {'OK'}, 2)
		Else

			/// --------------------------------------------------------
			// SE CONSEGUIU TRANSFERIR O ARQUIVO, RENOMEIA O MESMO
			// PARA PREVENIR, EM CASO DE ERRO, O TRAVAMENTO DO ARQUIVO
			// DE MODELO
			// --------------------------------------------------------
			cArqTemp  := AllTrim(GetTempPath()) + GetNextAlias() + ".dot"

			FRename( AllTrim(GetTempPath()) + cFileDot , cArqTemp  )

			If lContinua

				If !lV5FAT1
					//Verifica os parâmetros do relatório
					CriaPerg(cPerg)
					If !Pergunte (cPerg,.T.)
						Return Nil
					EndIF
				Else
					//Caso venha pela rotina automatica
					MV_PAR01 := SF2->F2_DOC
					MV_PAR02 := SF2->F2_DOC
					MV_PAR03 := SF2->F2_SERIE
				EndIf

				If Select('SQL') > 0
					SQL->(DbCloseArea())
				EndIf

				cQuery:= "SELECT * FROM "+RETSQLNAME("SF2")
				cQuery+= " WHERE (F2_DOC >= '"+MV_PAR01+"' AND F2_DOC <= '"+MV_PAR02+"' ) "
				cQuery+= "   AND F2_SERIE = '"+MV_PAR03+"' "
				cQuery+= "   AND D_E_L_E_T_ <> '*' "
				cQuery+= "   AND F2_FILIAL = '"+xFilial("SF2")+"' "
				cQuery+= "ORDER BY F2_EMISSAO+F2_DOC+F2_SERIE"

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SQL",.T.,.T.)

				If SQL->(EOF()) .OR. SQL->(BOF())
					lExec := .F.
				EndIf

				If lExec
					Processa({|| cFile := MontaRel(_lCapa, _oCapa, _lWs)})
				Else
					If !_lWs
						Aviso("Aviso","Não existem informações.",{"Abandona"},2)
					Else
						Conout("Não existem informações.")
					EndIf
				EndIf

				If _lCapa
					_oCapa := oPrinter

				EndIf

			Endif

		Endif

		//Removendo o arquivo temporario
		Ferase(cArqTemp)

	Endif

Return (cFile)

/*
Função  : MontaRel
Retorno : cFile
Objetivo: Gera o relatório
Autor   : Renato Rezende
Data    : 23/08/2016
*/
	*-----------------------------------*
Static Function MontaRel(_lCapa, _oCapa, _lWs)
	*-----------------------------------*

//ProcRegua(RecCount())
	While SQL->(!EOF())
		cFile:= GeraRel(_lCapa, _oCapa, _lWs)
		SQL->(DbSkip())
	EndDo

Return cFile

/*
Função  : GeraRel
Retorno : cFile
Objetivo: Gera o relatório
Autor   : Renato Rezende
Data    : 08/08/2016
*/
Static Function GeraRel(_lCapa, _oCapa, _lWs)

	Local oWord
	Local lContinua := .T.
	Local cDadosCli := ""
	Local dDtConv := ""
	Local nItens := 0
	Local aCond := Condicao(SQL->F2_VALBRUT,SQL->F2_COND)
	Local cVencto := ""
	Local cArqOpen := ""
	Local cDescProd := ""
	Local cDirBol			:= "\FTP\" + cEmpAnt + "\V5FAT005\"

	Local cNomeArq		:= 'fatura_'+cFilAnt+"_"+Alltrim(SQL->F2_DOC)+"_"+Alltrim(SQL->F2_SERIE)
	Local cFile := cDirBol + cNomeArq + ".pdf"
	Local cObs := ""
	Local cMenNota := ""
	Local aCompetencia := {}
	Local cCfop := ""
	Local cDadosEmp := ""

	Private nTotal			:= 0


	If _lWs
		// Se for WS nao carrega as macros, ja busca o  relatorio gerado
		If File(cDirBol + cNomeArq + ".PDF")
			cFile :=  cDirBol + cNomeArq + ".PDF"
		Else
			cFile := ""
		Endif

		Return(cFile)

	Endif

	//  Se encontrou retorno da funcao de condicao de pagamento busca o primeiro vencimento
	/* If Len(aCond) > 0
		cVencto := Dtoc(aCond[1][1])
	Endif */

	cVencto := U_VOGATU13(SQL->F2_DOC,SQL->F2_SERIE)

	oWord := OLE_CreateLink()
	If oWord == "-1"
		Aviso('ATENÇÃO', 'Não foi possível estabelecer a conexao com o MS-Word!', {'OK'}, 2)
		lContinua := .F.
	EndIF

	// --------------------------------------
	// POSICIONA NAS TABELAS
	//--------------------------------------
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+SQL->F2_CLIENTE+SQL->F2_LOJA))

	SE1->(DbSetOrder(2)) //E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
	SE1->(DbSeek(xFilial("SE1")+SQL->F2_CLIENTE+SQL->F2_LOJA+SQL->F2_PREFIXO+SQL->F2_DUPL+Space(TamSX3("E1_PARCELA")[1])+"NF"))

	SD2->(DbSetOrder(3))
	SD2->(DbSeek(xFilial("SD2")+SQL->F2_DOC+SQL->F2_SERIE))

	SC5->(DbSetOrder(1))
	SC5->(DbSeek(xFilial("SD2")+SD2->D2_PEDIDO))

	// ---------------------------------
	// CARREGA MODELO
	// -----------------------------------
	OLE_NewFile(oWord, Alltrim(cArqTemp))

	OLE_SetProperty( oWord, oleWdVisible,   .F. )
	OLE_SetProperty( oWord, oleWdPrintBack, .F. )

	//Atualiza docvariables

	// Dados da Empresa
	cDadosEmp += Alltrim(SM0->M0_CEPCOB) + " - "
	cDadosEmp += Alltrim(SM0->M0_BAIRCOB) + " - "
	cDadosEmp += Alltrim(SM0->M0_CIDCOB) + " - "
	cDadosEmp += Alltrim(SM0->M0_ESTCOB)


	OLE_SetDocumentVar(oWord, 'ccGcEmp'			,  Transform(SM0->M0_CGC,PesqPict("SA1","A1_CGC")) ) // Cnpj
	OLE_SetDocumentVar(oWord, 'cIEEmp'			,  Transform(SM0->M0_INSC,PesqPict("SA1","A1_INSC")) ) // Inscricao Estadual
	OLE_SetDocumentVar(oWord, 'cEndEmp'			,  SM0->M0_ENDCOB ) // Endereco
	OLE_SetDocumentVar(oWord, 'cNomeEmp'			,  SM0->M0_NOMECOM ) // Nome
	OLE_SetDocumentVar(oWord, 'cDadosEmp'			,  cDadosEmp ) // Nome

	//Dados do cliente

	cDadosCli += Alltrim(SA1->A1_CEP) + " - "
	cDadosCli += Alltrim(SA1->A1_BAIRRO) + " - "
	cDadosCli += AllTrim(SA1->A1_MUN) + " - "
	cDadosCli += AllTrim(SA1->A1_EST)

	OLE_SetDocumentVar(oWord, 'cCid'			,  Alltrim(SA1->A1_COD) ) // Cid
	OLE_SetDocumentVar(oWord, 'cNomeCli'			,  Alltrim(SA1->A1_NOME) ) // Nome
	OLE_SetDocumentVar(oWord, 'cEndCli'			,  Alltrim(SA1->A1_END) + IIf( Empty(SA1->A1_COMPLEM) , '' , ' - ' + SA1->A1_COMPLEM) ) // Endereco + Complemento
	OLE_SetDocumentVar(oWord, 'cDadosCli'			,   cDadosCli ) // CEP + Bairro + Municipo + Estado
	OLE_SetDocumentVar(oWord, 'cCnpjCli'			,   Transform(SA1->A1_CGC,PesqPict("SA1","A1_CGC") ))  //CNPJ
	OLE_SetDocumentVar(oWord, 'cIECli'			,   Transform(SA1->A1_INSCR,PesqPict("SA1","A1_INSCR") )) // Inscricao estadual

	//Atualizando dados da nota

	//Dados nf

	aCompetencia := U_VOGATU08(SQL->F2_DOC,SQL->F2_SERIE)

	OLE_SetDocumentVar(oWord, 'cDoc'			,   SQL->F2_DOC )
	OLE_SetDocumentVar(oWord, 'cSerie'			,   SQL->F2_SERIE )
	OLE_SetDocumentVar(oWord, 'cMesAnoRef'			, aCompetencia[1] )
	OLE_SetDocumentVar(oWord, 'cEmisDoc'			, Dtoc(Stod(SQL->F2_EMISSAO)) )
	OLE_SetDocumentVar(oWord, 'cPeriodo'			, aCompetencia[2] )
	OLE_SetDocumentVar(oWord, 'cVlBruto'			, Transform(SQL->F2_VALBRUT,PesqPict("SF2","F2_VALBRUT")))
	OLE_SetDocumentVar(oWord, 'cVencto'			,  cVencto )


	//Buscando Mensagem para nota
	cMenNota := U_VOGATU07(SQL->F2_DOC,SQL->F2_SERIE)
	OLE_SetDocumentVar(oWord, 'cMenNota'			,  cMenNota )

	SD2->(DbSetOrder(3))
	SD2->(dbSeek( FWxFilial("SF2") + SQL->F2_DOC + SQL->F2_SERIE ))

	While !SD2->(EOF()) .And. SQL->F2_DOC + SQL->F2_SERIE == SD2->D2_DOC  + SD2->D2_SERIE

		SC6->(dbSetOrder(1))
		If SC6->(DbSeek(xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV+SD2->D2_COD))
			cDescProd := Alltrim(SC6->C6_DESCRI)
		Else
			cDescProd := POSICIONE("SB1",1,FWxFilial("SB1") + SD2->D2_COD , "B1_DESC")
		EndIf

		nItens++

		OLE_SetDocumentVar(oWord, 'cProd' + AllTrim(Str(nItens))		, cDescProd )
		OLE_SetDocumentVar(oWord, 'cTotProd' + AllTrim(Str(nItens))		, Transform(SD2->D2_TOTAL,PesqPict("SD2","D2_TOTAL"))   )

		If Empty(cCfop)
			cCfop := SD2->D2_CF
		Endif

		SD2->(dbSkip())

	EndDo

	OLE_SetDocumentVar(oWord, 'cCfop' 		, cCfop  ) // CFOP
	OLE_SetDocumentVar(oWord, 'cEmissao' 		,  Dtoc(dDataBase)  ) // Data Base

	//Mensagem Marketing
	cObs := " "
	dbSelectArea("ZZ4")
	dbSetOrder(1)
	dbGotop()
	do While !Eof()
		If dDataBase >= ZZ4_DTINI .and. dDataBase <= ZZ4_DTFIM
			cObs := ZZ4_MSG
			Exit
		Endif
		dbSkip()
	Enddo

	OLE_SetDocumentVar(oWord, 'cobsx2', AllTrim(cObs) )

	OLE_SetDocumentVar(oWord, 'QtdePro', AllTrim(Str(nItens)))
	OLE_ExecuteMacro(oWord, "mcrFatCom")

	//-- Atualiza os campos
	OLE_UpDateFields(oWord)

	cArqOpen := GetTempPath() + cNomeArq + ".pdf"

	OLE_SaveAsFile(oWord, cArqOpen,,,, '17') //--Parametro '17' salva em pdf
	Sleep(1000) //Carregar todas as macros antes de abrir

	If lVisual
		ShellExecute( "Open", cArqOpen  , "" ,  GetTempPath() , 0)
	Endif

	//Copiando para o servidor se ainda nao existe
	If !File(cDirBol + cNomeArq + ".PDF")
		CpyT2S( cArqOpen , cDirBol ,.T. )
	Endif

	//--Fecha link com MS-Word
	OLE_CloseFile(oWord)
	OLE_CloseLink(oWord)

Return (cFile)


/*
Função  : CriaPerg
Objetivo: Verificar se os parametros estão criados corretamente.
Autor   : Renato Rezende
Data    : 16/08/2016
*/
	*--------------------------------*
Static Function CriaPerg(cPerg)
	*--------------------------------*
	Local lAjuste := .F.

	Local nI := 0

	Local aHlpPor := {}
	Local aHlpEng := {}
	Local aHlpSpa := {}
	Local aSX1    := {	{"01","Nota De ?"    },;
		{"02","Nota Ate ?"   },;
		{"03","Série ?"  	 }}

//Verifica se o SX1 está correto
	SX1->(DbSetOrder(1))
	For nI:=1 To Len(aSX1)
		If SX1->(DbSeek(PadR(cPerg,10)+aSX1[nI][1]))
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

		PutSx1(cPerg,"01","Nota De ?","Nota De ?","Nota De ?","mv_ch1","C",9,0,0,"G","","","","S","mv_par01","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

		aHlpPor := {}
		Aadd( aHlpPor, "Informe a Nota Final até a qual")
		Aadd( aHlpPor, "se desejá imprimir o relatório.")
		Aadd( aHlpPor, "Caso queira imprimir todas as notas ")
		Aadd( aHlpPor, "preencha este campo com 'ZZZZZZZZZ'.")

		PutSx1(cPerg,"02","Nota Ate ?","Nota Ate ?","Nota Ate ?","mv_ch2","C",9,0,0,"G","","","","S","mv_par02","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

		aHlpPor := {}
		Aadd( aHlpPor, "Informe a Série da qual")
		Aadd( aHlpPor, "se desejá imprimir o relatório.")

		PutSx1(cPerg,"03","Série ?","Série ?","Série ?","mv_ch3","C",3,0,0,"G","","","","S","mv_par03","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

	EndIf

Return Nil
