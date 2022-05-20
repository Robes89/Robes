#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} SIGR0003
Etiqueta de identificação do volume.

@author João Gustavo Orsi
@since 01/10/2014
@version P11
/*/
//-------------------------------------------------------------------
User Function SIGR0003(cCodCli,cLojaCli,x,nQtdEtq) 

//Local nX
Local cPorta 	:= 'LPT1'
Local cFonte	:= '1'
Local cTamDest	:= "'15,15'"
Local cTamRem	:= "'12,12'"
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
	MSCBSAY(05,05,'VOLUME: ' + cValToChar(x) + '/' + cValToChar(nQtdEtq),'N',cFonte,'20,20',.T.)
	MSCBSAY(05,10,'DESTINATARIO:','N',cFonte,'20,20',.T.)
	MSCBLineH(05,13,52,2,'B')
	MSCBSAY(05,15,cNomeCli,'N',cFonte,cTamDest,.T.)
	MSCBSAY(05,20,cEndCli,'N',cFonte,cTamDest,.T.)
	If !Empty(cComplem)
		MSCBSAY(05,25,SubStr(cComplem,1,40),'N',cFonte,cTamDest,.T.)
		MSCBSAY(05,30,cBairro,'N',cFonte,cTamDest,.T.)
		MSCBSAY(05,35,cCidade + '/' + cUf,'N',cFonte,cTamDest,.T.)
		MSCBSAY(05,40,'CEP: ' + cCepCli,'N',cFonte,cTamDest,.T.)
		MSCBSAYBAR(70,40,cCepCli,'N','MB07',13,.F.,.T.,.F.,,3,2,.F.,.F.,'1',.T.)
	Else
		MSCBSAY(05,25,cBairro,'N',cFonte,cTamDest,.T.)
		MSCBSAY(05,30,cCidade + '/' + cUf,'N',cFonte,cTamDest,.T.)
		MSCBSAY(05,35,'CEP: ' + cCepCli,'N',cFonte,cTamDest,.T.)
		MSCBSAYBAR(70,35,cCepCli,'N','MB07',13,.F.,.T.,.F.,,3,2,.F.,.F.,'1',.T.)
	EndIf		
	MSCBSAY(05,65,'REMETENTE:','N',cFonte,cTamRem,.T.)
	MSCBSAY(05,70,'SIGNUS IMPORT','N',cFonte,cTamRem,.T.)
	MSCBSAY(05,75,'RUA ALFREDO DA COSTA FIGO, 102','N',cFonte,cTamRem,.T.)
	MSCBSAY(05,80,'PRQ RURAL FAZENDA STA. CANDIDA','N',cFonte,cTamRem,.T.)
	MSCBSAY(05,85,'CAMPINAS/SP','N',cFonte,cTamRem,.T.)
	MSCBSAY(05,90,'CEP: 13087-534','N',cFonte,cTamRem,.T.)
	MSCBEND()
 	MS_FLUSH()
MSCBCLOSEPRINTER()

RestArea(aArea)

Return
