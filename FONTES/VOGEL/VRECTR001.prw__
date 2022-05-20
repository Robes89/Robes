#Include "Protheus.ch"
#Include "RWMake.ch"
#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "TOPConn.ch"

/*/Protheus.doc VRECONTR
@(long_description) Função para importação do CSV da Revisao do Contrato - Busca o arquivo e regua de processamento dos registros
@author Eduardo Silva - Triyo
@since 12/02/2021
@version 12.1.25
/*/

User Function VRECTR02()

Local cArquivo := ''  


//If Select("SM0") == 0
	RpcSetType(3)
	If !RpcSetEnv('V5', '01')
		Final("Erro ao abrir ambiente")
		lAmbOk := .F.
	EndIf
//EndIf
cArquivo := cGetFile()
If Empty(cArquivo)
	MsgAlert("Atenção, informe um arquivo válido antes de prosseguir com a importação.")
	Return Nil
EndIf
Processa({ || VRECONT2(cArquivo) })

Return Nil

/*/Protheus.doc VRECONT1
	Função para leitura e gravação das Revisções do Contrato conforme registros do arquivo CSV
	@author Eduardo Silva - Triyo
	@since  12/02/2021
/*/

Static Function VRECONT2(cArquivo)

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
Local cOpcRev	:= "3"
Local cTipRev   := "018"	// C=Renovação
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

// Montando o array conforme Contrato

// Gravo as tabelas conforme array
ProcRegua(Len(aDados))
cContra := ''
For i := 1 to Len(aDados)
	
	// Posicionamento no contrato que será revisado.
		IF cContra <> aDados[i,2] 
				cFil	:= aDados[i,1]
				cContra := aDados[i,2]
				cFilAnt := cFil
			IncProc("Gravando resgistro do Contrato: " + cContra)
			CN9->( dbSetOrder(7) )	// CN9_FILIAL + CN9_NUMERO + CN9_SITUAC
			If CN9->( dbSeek(cFil + PadR(cContra,TamSX3("CN9_NUMERO")[1]) + "05") )	
				
				A300STpRev('C')                             // Define o tipo de revisão que será realizado.
				oModel := FWLoadModel("CNTA300")                // Carrega o modelo de dados do contrato.
				oModel:SetOperation(MODEL_OPERATION_INSERT)     // Define operação do modelo. Será INSERIDA uma revisão.
				oModel:Activate(.T.)                            // Ativa o modelo. É necessária a utilização do parâmetro como true (.T.) para realizar uma copia.
				// Cabeçalho do Contrato
				oModel:SetValue( 'CN9MASTER'    , 'CN9_TIPREV'  , cTipRev )      // É obrigatório o preenchimento do tipo de revisão do contrato.
				oModel:SetValue( 'CN9MASTER'    , 'CN9_JUSTIF'  , 'teste' )    // É obrigatório o preenchimento da justificativa de revisão do contrato.
				oModel:SetValue( 'CN9MASTER'    , 'CN9_XOBS'  , 'teste' ) 
			Else
			 	Loop
			EndIF	
		EndIF
		
		
		If Select("TMPCNB") > 0
			TMPCNB->( dbCloseArea() )
		EndIf
		cQryCNB := " SELECT "
		cQryCNB += " 	CNB_CONTRA, CNB_NUMERO, MAX(CNB_REVISA) REVISA, CNB_ITEM, CNB_SLDMED,CNB_PRODUT, CNB_VLUNIT "
		cQryCNB += " FROM "
		cQryCNB += " 	" + RetSQLName("CNB")
		cQryCNB += " WHERE D_E_L_E_T_ = ' ' "
		cQryCNB += " 	AND CNB_CONTRA = '" + aDados[i, 02] + "' "
		cQryCNB += " 	AND CNB_PRODUT = '" + aDados[i, 03] + "' "
		cQryCNB += " 	AND CNB_ITMDST = ' ' "
		cQryCNB += " GROUP BY CNB_CONTRA, CNB_NUMERO, CNB_ITEM, CNB_PRODUT, CNB_VLUNIT ,CNB_SLDMED"
		TcQuery cQryCNB New Alias "TMPCNB"
		If TMPCNB->( !Eof() ) 
			oModel:GetModel('CNBDETAIL'):GoLine(Val(TMPCNB->CNB_ITEM))
			
			     // Alteração da quantidade do item.
			oModel:SetValue( 'CNBDETAIL'	, 'CNB_VLUNIT'   ,val( aDados[i, 04]) )
		EndIF			
		j := iif(Len(aDados) == i,i,i+1)
		IF  cContra <> aDados[j,2] .or.   Len(aDados) == i 
			
			//Validação e Gravação do Modelo
			If oModel:VldData()
				oModel:CommitData()			
				lSucesso := .T.
			Else
				aErro := {}
				aErro := oModel:GetErrorMessage()
				cMessage := "Id do formulário de origem:"  + ' [' + cValToChar(aErro[01]) + '], '
				cMessage += "Id do campo de origem: "      + ' [' + cValToChar(aErro[02]) + '], '
				cMessage += "Id do formulário de erro: "   + ' [' + cValToChar(aErro[03]) + '], '
				cMessage += "Id do campo de erro: "        + ' [' + cValToChar(aErro[04]) + '], '
				cMessage += "Id do erro: "                 + ' [' + cValToChar(aErro[05]) + '], '
				cMessage += "Mensagem do erro: "           + ' [' + cValToChar(aErro[06]) + '], '
				cMessage += "Mensagem da solução: "        + ' [' + cValToChar(aErro[07]) + '], '
				cMessage += "Valor atribuído: "            + ' [' + cValToChar(aErro[08]) + '], '
				cMessage += "Valor anterior: "             + ' [' + cValToChar(aErro[09]) + ']'
				cMessage += "FILIAL: "             + ' [' + cFilAnt + ']'
				cMessage += "Contrato: "             + ' [' + aDados[i, 02] + ']'
				MemoWrite("c:\temp\ImpRev_" + DtoS(dDatabase) + Strtran(Time(),":","") + ".log",cMessage)
 				   //Mostra mensagem de erro
 			   lRet := .F.
				//TmsMsgErr(aErro)
				lLogErro := .T.
			EndIf
		EndIF	
	
Next i 
// Aprovo as revisões dos contratos
ProcRegua(Len(aDados))
For _w4 := 1 to Len(aDados) 
	cFil	:= aDados[_w4,1]
	cContra := aDados[_w4,2]
	cFilAnt := cFil
	IncProc("Aprovando as revisões do Contrato: " + aDados[_w4,2])
	cQry := " SELECT "
	cQry += " 	R_E_C_N_O_ AS RECCN9 FROM " + RetSqlName("CN9")
	cQry += " WHERE D_E_L_E_T_ = '' "
	cQry += " 	AND CN9_NUMERO = '" + aDados[_w4,2] + "' "
	cQry += " 	AND CN9_SITUAC = '09' "
	TcQuery cQry New Alias "TMPA"
	dbSelectArea("TMPA")
	dbGoTop()
	While !Eof()
		If TMPA->RECCN9 > 0
			dbSelectArea("CN9")
			dbGoTo(TMPA->RECCN9)
			CN300Aprov(.T.,,@cMsgErro) //Função retorna 0 em caso de falha e 1 em caso de sucesso.
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
	apMsgInfo(	"Arquivo de log com inconsistências criado no caminho abaixo: " + CRLF + CRLF +;
		"<FONT COLOR=BLUE SIZE=4>" + cCaminho + "</FONT>" + CRLF + CRLF + CRLF+;
		"<b>Observação:</b>" + CRLF +;
		"Caso não exista favor criar a pasta TEMP dentro do <b>C:</b>", "L O G    D E    A R Q U I V O")
	MemoWrite( cCaminho, cTxtLog )
EndIf
// Apresento a mensagem se todo o processamento foi gerado com sucesso
If lSucesso
	MsgRun("Importação dos registros concluída com sucesso!!!",,{|| Sleep(2000) })
EndIf

Return lRet
