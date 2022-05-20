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

User Function IMPINV()

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
Processa({ || VRECONT1(cArquivo) })

Return Nil

/*/Protheus.doc VRECONT1
	Função para leitura e gravação das Revisções do Contrato conforme registros do arquivo CSV
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
Local lSucesso	:= .T.
Local cTxtLog	:= ""
Local lLogErro	:= .F.
Local cCaminho	:= "c:\temp\ImpRev_" + DtoS(dDatabase) + Strtran(Time(),":","") + ".log"
Local oModel    := Nil
Local cFil		:= ""
Local cContra   := ""
Local cMsgErro  := "" 
Local cOpcRev	:= "3"
Local cTipRev   := "003"	// C=Renovação
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
dbSelectArea("SBK")

dbSelectArea("SBJ")
For i := 1 to Len(aDados)
	IF !Empty(aDados[i , 6 ])
        RecLock("SBJ",.T.)
        SBJ->BJ_FILIAL  :=  aDados[i , 1 ]
        SBJ->BJ_COD     :=  aDados[i , 2 ]
        SBJ->BJ_LOCAL   :=  aDados[i , 3]
        SBJ->BJ_DATA    := STOD(aDados[i , 4])
        SBJ->BJ_QINI    :=  val(aDados[i , 5 ])
        SBJ->BJ_LOTECTL :=  aDados[i , 6 ]
        SBJ->BJ_DTVALID :=   STOD(aDados[i , 7])
        SBJ->(MsUnlock())
    EndIf    

    IF !Empty(aDados[i , 8 ])
        RecLock("SBK",.T.)
        SBK->BK_FILIAL  :=  aDados[i , 1 ]
        SBK->BK_COD := aDados[i , 2 ]
        SBK->BK_LOCAL := aDados[i , 3]
        SBK->BK_DATA :=  STOD(aDados[i , 4])
        SBK->BK_QINI := val(aDados[i , 5 ])
        SBK->BK_LOTECTL := aDados[i , 6 ]
        SBK->BK_LOCALIZ :=  aDados[i , 8 ]
        //SBK->BK_NUMSERI :=  aDados[i , 9 ]
        SBK->(MsUnlock())
    EndIf    

	
Next i
// Aprovo as revisões dos contratos

If lSucesso
	MsgRun("Importação dos registros concluída com sucesso!!!",,{|| Sleep(2000) })
EndIf

Return lRet
