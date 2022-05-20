#Include "Protheus.ch"
#Include "RWMake.ch"
#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "TOPConn.ch"

/*/Protheus.doc VRECONTR
@(long_description) Fun��o para importa��o do CSV da Revisao do Contrato - Busca o arquivo e regua de processamento dos registros
@author Eduardo Silva - Triyo
@since 12/02/2021
@version 12.1.25
/*/

User Function VRECONTR()

Local cArquivo := cGetFile()
If Empty(cArquivo)
	MsgAlert("Aten��o, informe um arquivo v�lido antes de prosseguir com a importa��o.")
	Return Nil
EndIf
Processa({ || VRECONT1(cArquivo) })

Return Nil

/*/Protheus.doc VRECONT1
	Fun��o para leitura e grava��o das Revis��es do Contrato conforme registros do arquivo CSV
	@author Eduardo Silva - Triyo
	@since  12/02/2021
/*/

Static Function VRECONT1(cArquivo)

Local cLinha	:= ""
Local lPrim		:= .T.
Local aCampos	:= {}
Local aDados	:= {}
Local aContrat	:= {}
Local aErro		:= {}
Local i
Local j
Local k
Local _w4
Local lSucesso	:= .F.
Local cTxtLog	:= ""
Local lLogErro	:= .F.
Local cCaminho	:= "c:\temp\ImpRev_" + DtoS(dDatabase) + Strtran(Time(),":","") + ".log"
Local oModel    := Nil
Local cFil		:= ""
Local cContra   := ""
Local cMsgErro  := "" 
Local cOpcRev	:= "C"
Local cTipRev   := "018"	// C=Renova��o
Local lRet      := .F.
Local cQry      := ""
Local cQryCNA	:= ""
Local cQryCNB	:= ""
Local nPosA		:= 0
Local nPosB		:= 0
Local nPosC		:= 0
Local oGrid := Nil 
// Abertuta do Arquivo
FT_FUse(cArquivo)
ProcRegua(FT_FLastRec())
FT_FGoTop()
// Alimentando os Arrays
While !FT_FEof()
	IncProc("Lendo arquivo CSV...")
	cLinha := FT_FREADLN()
	If lPrim
		aCampos := Separa(cLinha,";",.T.)
		lPrim := .F.
	Else
		aAdd(aDados, Separa(cLinha,";",.T.) )
	EndIf
	FT_FSKip()
End
// Apresento a mensagem se coluna diferente
If Len(aCampos) > 9 .Or. Len(aCampos) < 9
	apMsgAlert(	"Planilha esta com quantidade de colunas erradas." + CRLF +;
		"Permitido at� 11 colunas conforme abaixo, Favor corrija." + CRLF +;
		"<FONT COLOR=RED SIZE=2>1.CN9_NUMERO; 2.CN9_VIGE; 3.CN9_JUSTIF; 4.CN9_TPCRON</FONT>" + CRLF +;
		"<FONT COLOR=RED SIZE=2>5.CN9_QTDPAR; 6.CN9_ARRAST; 7.CN9_REDVAL; 8.CNA_NUMERO</FONT>" + CRLF +;
		"<FONT COLOR=RED SIZE=2>9.CNA_TIPPLA; 10.CNB_PRODUTO; 11.CNB_QUAT</FONT>" + CRLF + CRLF + CRLF +;
		"<b>Observa��o:</b>" + CRLF +;
		"<b>Caso queira incluir mais colunas, favor entre em contato com o TI.</b>" + CRLF + CRLF + CRLF+;
		"<FONT COLOR=BLUE SIZE=4>O Processo ser� cancelado.</FONT>")
	Return
EndIf
// Montando o array conforme Contrato
For j := 1 to Len(aDados)
	If (nPosA := ASCan(aContrat, {|x|, x[02] == aDados[ j, 02 ] })) > 0 // Contrato
		If (nPosB := ASCan(aContrat[ nPosA, 06 ], {|x|, x[01] == aDados[ j, 06 ] })) > 0 // Tipo da Planilha ja existe
			If (nPosC := ASCan(aContrat[ nPosA, 06, nPosB, 02 ], {|x|, x[ 01 ] == aDados[j,07] })) > 0 // Produto
				aAdd( aContrat[ nPosA, 06, nPosB, 02, nPosC ], { aDados[j, 07], Val(aDados[j, 08]), Val(aDados[j, 09]) })
			Else
				aAdd( aContrat[ nPosA, 06, nPosB, 02 ], { aDados[j, 07], Val(aDados[j, 08]), Val(aDados[j, 09]) })
			EndIf
		Else // Planilha ainda nao existe 
			aAdd( aContrat[ nPosA ], { aDados[ j, 06 ], { { aDados[j, 07 ], Val(aDados[ j, 08 ]), Val(aDados[ j, 09 ])} } })
		EndIf
	Else // Contrato ainda Nao considerada ainda
		//             {       Filial,     Contrato,	      Vigencia,       Justif,           QtdParc, { {      TipPlan, { {        Produto,            QuantParc 		    Vlr Unit  } } } } }
		//             {           01,           02,                03,           04,                05, { {     ??.06.02, { { ??.06.??.02.01,       ??.06.??.02.02     ??.06.??.02.03  } } } } }
		aAdd(aContrat, { aDados[j,01], aDados[j,02], Val(aDados[j,03]), aDados[j,04], Val(aDados[j,05]), { { aDados[j,06], { {   aDados[j,07],    Val(aDados[j,08]),	Val(aDados[j,09]) } } } } })
	EndIf
Next j
// Gravo as tabelas conforme array
ProcRegua(Len(aContrat))
For i := 1 to Len(aContrat)
	cFil	:= aContrat[i,1]
	cContra := aContrat[i,2]
	IncProc("Gravando resgistro do Contrato: " + cContra)
	CN9->( dbSetOrder(7) )	// CN9_FILIAL + CN9_NUMERO + CN9_SITUAC
	If CN9->( dbSeek(cFil + PadR(cContra,TamSX3("CN9_NUMERO")[1]) + "05") )	// Posicionamento no contrato que ser� revisado.
		A300STpRev(cOpcRev)                             // Define o tipo de revis�o que ser� realizado.
		oModel := FWLoadModel("CNTA300")                // Carrega o modelo de dados do contrato.
		oModel:SetOperation(MODEL_OPERATION_INSERT)     // Define opera��o do modelo. Ser� INSERIDA uma revis�o.
		oModel:Activate(.T.)                            // Ativa o modelo. � necess�ria a utiliza��o do par�metro como true (.T.) para realizar uma copia.
		// Cabe�alho do Contrato
		oModel:SetValue( 'CN9MASTER'    , 'CN9_TIPREV'  , cTipRev)      // � obrigat�rio o preenchimento do tipo de revis�o do contrato.
		oModel:SetValue( 'CN9MASTER'    , 'CN9_VIGE'    , aContrat[i,3])
		oModel:SetValue( 'CN9MASTER'    , 'CN9_JUSTIF'  , aContrat[i,4])    // � obrigat�rio o preenchimento da justificativa de revis�o do contrato.
		oModel:SetValue( 'CN9MASTER'    , 'CN9_TPCRON'  , "1")
		oModel:SetValue( 'CN9MASTER'    , 'CN9_QTDPAR'  , aContrat[i,5])
		oModel:SetValue( 'CN9MASTER'    , 'CN9_ARRAST'  , "1")
		oModel:SetValue( 'CN9MASTER'    , 'CN9_REDVAL'  , "1")
		For J := 1 To Len(aContrat[ i, 06 ])	// Cabela�ho da Planilha
			If Select("TMPCNA") > 0
				TMPCNA->( dbCloseArea() )
			EndIf
			cQryCNA := " SELECT "
			cQryCNA += " 	CNA_CONTRA, CNA_NUMERO, MAX(CNA_REVISA) REVISA, CNA_TIPPLA "
			cQryCNA += " FROM "
			cQryCNA += " 	" + RetSQLName("CNA")
			cQryCNA += " WHERE D_E_L_E_T_ = ' ' "
			cQryCNA += " AND CNA_CONTRA = '" + aContrat[i, 02] + "' "
			cQryCNA += " AND CNA_TIPPLA = '" + aContrat[i, 06, j, 01] + "' "
			cQryCNA += " GROUP BY CNA_CONTRA, CNA_NUMERO, CNA_TIPPLA "
			TcQuery cQryCNA New Alias "TMPCNA"
			If TMPCNA->( !Eof() )
				CNA->( dbSetOrder(1) )	// CNA_FILIAL + CNA_CONTRA + CNA_REVISA + CNA_NUMERO
				If CNA->( dbSeek(cFil + TMPCNA->CNA_CONTRA + TMPCNA->REVISA + TMPCNA->CNA_NUMERO) )
					oModel:SetValue( 'CNADETAIL'    , 'CNA_TIPPLA'  , aContrat[i, 06, j, 01])
					oGrid := oModel:GetModel('CNBDETAIL')
					For k := 1 To Len(aContrat[ i, 06, j, 02 ])	// Itens da Planilha
						// Filtro do Produto conforme quantidade e valor unitario
						If Select("TMPCNB") > 0
							TMPCNB->( dbCloseArea() )
						EndIf
						cQryCNB := " SELECT "
						cQryCNB += " 	CNB_CONTRA, CNB_NUMERO, MAX(CNB_REVISA) REVISA, CNB_ITEM, CNB_PRODUT, CNB_VLUNIT "
						cQryCNB += " FROM "
						cQryCNB += " 	" + RetSQLName("CNB")
						cQryCNB += " WHERE D_E_L_E_T_ = ' ' "
						cQryCNB += " 	AND CNB_CONTRA = '" + aContrat[i, 02] + "' "
						cQryCNB += " 	AND CNB_PRODUT = '" + aContrat[i, 06, j, 02, k, 01] + "' "
						cQryCNB += " 	AND CNB_VLUNIT = '" + cValToChar(aContrat[i, 06, j, 02, k, 03]) + "' "
						cQryCNB += " 	AND CNB_ITMDST = ' ' "
						cQryCNB += " GROUP BY CNB_CONTRA, CNB_NUMERO, CNB_ITEM, CNB_PRODUT, CNB_VLUNIT "
						TcQuery cQryCNB New Alias "TMPCNB"
						If TMPCNB->( !Eof() )
							oGrid:GoLine(Val(TMPCNB->CNB_ITEM))
							oModel:GetModel('CNBDETAIL'):SetNoInserLine(.F.)
							oModel:GetModel('CNBDETAIL'):SetNoUpdateLine(.F.)
							oModel:SetValue( 'CNBDETAIL'	, 'CNB_QUANT'   , aContrat[i, 06, j, 02, k, 02])       // Altera��o da quantidade do item.
						EndIf
					Next k
				EndIf
			EndIf
		Next j
		CN300RdSld(oModel)  // Realiza a redistribui��o do saldo da planilha
		CN300AtCrs(oModel)  // Realiza a atualiza��o do cronograma financeiro
		//Valida��o e Grava��o do Modelo
		If oModel:VldData()
			oModel:CommitData()			
			lSucesso := .T.
		Else
			aErro := oModel:GetErrorMessage()
    		TmsMsgErr(aErro)
			lLogErro := .T.
		EndIf
	EndIf
Next i
// Aprovo as revis�es dos contratos
ProcRegua(Len(aContrat))
For _w4 := 1 to Len(aContrat) 
	IncProc("Aprovando as revis�es do Contrato: " + aContrat[_w4,2])
	cQry := " SELECT "
	cQry += " 	R_E_C_N_O_ AS RECCN9 FROM " + RetSqlName("CN9")
	cQry += " WHERE D_E_L_E_T_ = '' "
	cQry += " 	AND CN9_NUMERO = '" + aContrat[_w4,2] + "' "
	cQry += " 	AND CN9_SITUAC = '09' "
	TcQuery cQry New Alias "TMPA"
	dbSelectArea("TMPA")
	dbGoTop()
	While !Eof()
		If TMPA->RECCN9 > 0
			dbSelectArea("CN9")
			dbGoTo(TMPA->RECCN9)
			CN300Aprov(.T.,,@cMsgErro) //Fun��o retorna 0 em caso de falha e 1 em caso de sucesso.
			dbSelectArea("TMPA")
			dbSkip()
		EndIf
		dbSelectArea("TMPA")
		dbSkip()
	End
	dbSelectArea("TMPA")
	dbCloseArea()
Next
FT_FUse()
// Gero Log de Erro
If lLogErro
	apMsgInfo(	"Arquivo de log com inconsist�ncias criado no caminho abaixo: " + CRLF + CRLF +;
		"<FONT COLOR=BLUE SIZE=4>" + cCaminho + "</FONT>" + CRLF + CRLF + CRLF+;
		"<b>Observa��o:</b>" + CRLF +;
		"Caso n�o exista favor criar a pasta TEMP dentro do <b>C:</b>", "L O G    D E    A R Q U I V O")
	MemoWrite( cCaminho, cTxtLog )
EndIf
// Apresento a mensagem se todo o processamento foi gerado com sucesso
If lSucesso
	MsgRun("Importa��o dos registros conclu�da com sucesso!!!",,{|| Sleep(2000) })
EndIf

Return lRet
