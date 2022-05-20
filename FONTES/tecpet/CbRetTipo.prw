#include "totvs.ch"

User Function CbRetTipo

Local cID 		:= PARAMIXB[1]
Local aAreaAtu 	:= GetArea()
Local aAreaSB1 	:= SB1->(GetARea())
Local lRet 		:= .F.

SB1->( dbSetOrder(1) )

If !Empty(cID)
	nPosLote 	:=  At("@", cID)
	nPosQtd	    := Rat("@", cID)
Endif

//Se nao tiver @, procura por pontos, criado para testes
If Empty(nPosLote+nPosQtd)
	nPosLote	:=	At(".", cID)
	nPosQtd		:=	RAt(".", cID)
Endif

If nPosLote > 0 .and. nPosQtd > 0
	lRet := .T.
Elseif SB1->( dbSeek( xFilial("SB1") + cID ) )
	lRet := .T.
Endif

RestArea(aAreaSB1)
RestArea(aAreaAtu)

Return lRet