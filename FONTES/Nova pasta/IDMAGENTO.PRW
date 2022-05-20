#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

/*/{Protheus.doc} CARGAMGT
CARGA DE ID'S DO MAGENTO DE ACORDO COM SKU PROTHEUS
@author Henrique Cunha
@since 05/08/2020
@version 1.0
/*/

User Function CARGAMGT()

Local cArqCSV	:= ""

Local aRet		:= {}
Local aPergs	:= {}
Local aLinhas	:= {}

//ABERTURA DE EMPRESAS
RPCSETENV('01','02')

//PERGUNTAS
aAdd(aPergs,{6,"Arquivo: ",PADR('',150),"",,"",90 ,.T.," .CSV |*.CSV",'',GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE})

If !ParamBox(aPergs ,"Parametros ",aRet)
	Alert("Processo Cancelado!")
	Return()
Else	

	cArqCSV := AllTrim(aRet[1])
	//VERIFICA SE O ARQUIVO REALMENTE EXISTE
	If ! File(cArqCSV)
		MsgStop("Arquivo " + cArqCSV + " nao Existe.")
		Return()
	EndIf
	
	FT_FUse(cArqCSV)
	FT_FGoTop()
	
	//LEITURA DAS LINHAS DO ARQUIVO
	MsgRun("Aguarde... Realizando Leitura do Arquivo...",,{|| RdArq(@aLinhas)})
	
	If Len(aLinhas) = 0
		MsgStop("Não há Linhas para Leitura de Arquivo!")
		Return()
	Else
        //GRAVACAO DAS LINHAS
		MsgRun("Aguarde... Gravando ID's...",,{|| U_MGTPROC(aLinhas)})	
	EndIf
	
EndIf

//MENSAGEM DE FINALIZACAO
Alert("Fim")

Return

/*/{Protheus.doc} MGTPROC
GRAVACAO DE ID'S DO MAGENTO DE ACORDO COM SKU PROTHEUS
@author Henrique Cunha
@since 05/08/2020
@version 1.0
/*/

User Function MGTPROC(aLinhas)

Local _nX := 0

DBSelectArea("SB1")
SB1->(DBSetOrder(1))

For _nX := 2 To Len(aLinhas)
    If SB1->(DBSeek(xFilial("SB1")+AllTrim(aLinhas[_nX][2])))
        RECLOCK("SB1",.F.)
            SB1->B1_XIDMGNT := AllTrim(aLinhas[_nX][1])
        SB1->(MSUnlock())
    EndIf
Next _nX

Return

/*/{Protheus.doc} RdArq
REALIZA LEITURA DE ARQUIVO CSV
@author Henrique Cunha
@since 05/08/2020
@version 1.0
/*/

Static Function RdArq(aLinhas)

Local cLinAux	:= ""
Local aAuxLin := {}

While !FT_FEOF()
	cLinAux := FT_fReadLn()
	aAuxLin := STRTOKARR2(cLinAux,";",.T.)
	AADD(aLinhas,aAuxLin)
	FT_FSKIP()	
EndDo

FT_FUSE()

Return