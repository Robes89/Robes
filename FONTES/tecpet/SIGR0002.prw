#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} SIGR0002
Etiqueta dupla do AR.

@author João Gustavo Orsi
@since 01/10/2014
@version P11
/*/
//-------------------------------------------------------------------
User Function SIGR0002(cNumNf,cSerie,cCodCli,cLojaCli,nQtdEtq) 

//Local nX
Local cPorta 	:= 'LPT1'
Local cFonte	:= '2'
Local cTamanho	:= "'15,15'"
Local cNomeCli	:= ''
Local cEndCli 	:= ''
Local cComplem	:= ''
Local cBairro 	:= ''
Local cCidade	:= ''
Local cUf		:= ''
Local cCepCli	:= ''
Local cAlias	:= GetNextAlias()
Local aArea 	:= GetArea()

BeginSql Alias cAlias
	SELECT 	A1_NOME AS NOME, 
			A1_END AS ENDERECO, 
			A1_COMPLEM AS COMPLEMENTO, 
			A1_BAIRRO AS BAIRRO, 
			A1_MUN AS MUNICIPIO, 
			A1_EST AS ESTADO, 
			A1_CEP AS CEP
	FROM %table:SA1% SA1
	WHERE A1_FILIAL = %xFilial:SA1%
		AND A1_COD = %Exp:cCodCli%
		AND A1_LOJA = %Exp:cLojaCli%
		AND SA1.%NotDel%
EndSql

cNomeCli	:= AllTrim((cAlias)->NOME)
cEndCli 	:= AllTrim((cAlias)->ENDERECO)
cComplem	:= AllTrim((cAlias)->COMPLEMENTO)
cBairro 	:= AllTrim((cAlias)->BAIRRO)
cCidade		:= AllTrim((cAlias)->MUNICIPIO)
cUf			:= AllTrim((cAlias)->ESTADO)
cCepCli		:= AllTrim((cAlias)->CEP)

(cAlias)->(DbCloseArea()) 

MSCBPRINTER('FLEX',cPorta,,,.F.,,,,,)
	MSCBINFOETI('RECEBIMENTO','100X100')
	MSCBBEGIN(1,4)
	MSCBChkStatus(.F.)
	MSCBSAY(05,05,'DESTINATARIO:','N',cFonte,'20,20',.T.)
	MSCBSAY(05,10,cNomeCli,'N',cFonte,cTamanho,.T.)
	MSCBSAY(05,15,cEndCli,'N',cFonte,cTamanho,.T.)
	If !Empty(cComplem)
		MSCBSAY(05,20,SubStr(cComplem,1,40),'N',cFonte,cTamanho,.T.)
		MSCBSAY(05,25,cBairro,'N',cFonte,cTamanho,.T.)
		MSCBSAY(05,30,cCidade + '/' + cUf,'N',cFonte,cTamanho,.T.)
		MSCBSAY(05,35,'CEP: ' + cCepCli,'N',cFonte,cTamanho,.T.)
		MSCBSAY(05,40,'NF/SERIE: ' + cNumNf + '/' + cSerie,'N',cFonte,cTamanho,.T.)
	Else
		MSCBSAY(05,20,cBairro,'N',cFonte,cTamanho,.T.)
		MSCBSAY(05,25,cCidade + '/' + cUf,'N',cFonte,cTamanho,.T.)
		MSCBSAY(05,30,'CEP: ' + cCepCli,'N',cFonte,cTamanho,.T.)
		MSCBSAY(05,35,'NF/SERIE: ' + cNumNf + '/' + cSerie,'N',cFonte,cTamanho,.T.)
	EndIf
	MSCBSAY(05,50,'REMETENTE:','N',cFonte,'20,20',.T.)
	MSCBSAY(05,55,'SIGNUS IMPORT','N',cFonte,cTamanho,.T.)
	MSCBSAY(05,60,'RUA ALFREDO DA COSTA FIGO, 102','N',cFonte,cTamanho,.T.)
	MSCBSAY(05,65,'PRQ RURAL FAZENDA STA. CANDIDA','N',cFonte,cTamanho,.T.)
	MSCBSAY(05,70,'CAMPINAS/SP','N',cFonte,cTamanho,.T.)	
	MSCBSAY(05,75,'CEP: 13087-534','N',cFonte,cTamanho,.T.)
	MSCBEND()
 	MS_FLUSH()
MSCBCLOSEPRINTER()

RestArea(aArea)

Return
