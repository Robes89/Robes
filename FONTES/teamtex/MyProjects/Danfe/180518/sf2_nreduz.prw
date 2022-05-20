#include "rwmake.ch"
#Include "tbiconn.ch" 
#Include "TOPCONN.CH"

/*/
	Ponto de entrada utilizado para gravar informações do Cliente no Cabecalho da NF de saida 
	SA1->A1_NREDUZ ----- SF2->F2_NREDUZ
	SA1->A1_CGC    ----- SF2->F2_CGC
	Desenvolvido especifo para TEAM TEX 
	Marcos Bido - Triyo - 18/05/2018
/*/

USER FUNCTION SF2460i()

IF SF4->F4_CODIGO >= "500" //nota fiscal de saida  
	// salva ponteiros
	_cAlias := Alias()
	_nOrdem := IndexOrd()
	_nRecno := Recno()
	_cCodCli	 := SF2->F2_CLIENTE + SF2->F2_LOJA
	DbSelectArea("SA1")
	DbSetOrder(1)
	IF !DBSEEK(XFILIAL()+_cCodCli)
		MsgAlert("ATENCAO!!, Não Achou o Cliente ! " + _cCodCli)
	ELSE
		DBSELECTAREA("SF2")
		RecLock("SF2",.F.)                   
		Replace F2_NREDUZ	with SA1->A1_NREDUZ
		Replace F2_CGC		with SA1->A1_CGC
		MsUnlock()     
    Endif
	// RETORNA PONTEIRO DOS ARQUIVOS
	dbSelectArea(_cAlias)
	dbSetOrder(_nOrdem)
	dbGoto(_nRecno) 
Endif

Return
