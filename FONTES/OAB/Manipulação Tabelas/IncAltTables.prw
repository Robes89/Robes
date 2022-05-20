#include 'Totvs.ch'
#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} IncRegSZB
//Inclui registros na tabela SZB
@author Philip Pellegrini
@since 29/12/2020
/*/
User function IncRegSZB(cCod, cDesc, cCodCli, cDataIni)
	
	Local lRet := .T.
	
	RecLock("SZB",.T.)

	SZB->ZB_FILIAL := xFilial("SZB")
	SZB->ZB_CODIGO := cCod
	SZB->ZB_DESC	:= cDesc
	SZB->ZB_CODCLI := cCodCli
	SZB->ZB_MOTIVO := ''
	SZB->ZB_DTLANC := Date()
	SZB->ZB_DTINI  := sTod(cDataIni)
	SZB->ZB_DTFIM  := cTod('')

	MsUnlock()

Return lRet

/*/{Protheus.doc} AltRegSZB
//Altera registros na tabela SZB
@author Philip Pellegrini
@since 29/12/2020
/*/
User function AltRegSZB(cCod, cDesc, cCodCli, cDataIni, cDataFim)
	
	Local lRet := .T.
	
	RecLock("SZB",.F.)
	SZB->ZB_DTFIM  := sTod(cDataFim)
	MsUnlock()
	
Return lRet

/*/{Protheus.doc} AltXlicenc
//Altera campo A1_XLICENC LICENCIAMENTO na tabela SA1
@author Philip Pellegrini
@since 29/12/2020
/*/
User Function AltXlicenc(cCodCli, cStatus)
	
	Local lRet := .T.

	dbSelectArea("SA1")
	dbSetORder(1)
	
	cStatus := Right(cStatus,1)
	
	If SA1->(DBSeek(xFilial("SA1") + cCodCli))
		
		RecLock("SA1",.F.)
		SA1->A1_XLICENC  := cStatus
		MsUnlock()
		
	Endif 
	
Return lRet


/*/{Protheus.doc} AltXCanc
//Altera campo A1_XCANCEL CANCELAMENTO na tabela SA1
@author Philip Pellegrini
@since 29/12/2020
/*/
User Function AltXCanc(cCodCli, cStatus)
	
	Local lRet := .T.

	dbSelectArea("SA1")
	dbSetORder(1)
	
	
	If SA1->(DBSeek(xFilial("SA1") + cCodCli))
		
		RecLock("SA1",.F.)
		SA1->A1_XCANCEL  := cStatus
		MsUnlock()
		
	Endif 
	
Return lRet
