#INCLUDE "rwmake.ch"

User Function MT500APO()
_lRet := .T.
If SC5->C5_STPAD $ "SPE"
	_aSvAlias       := {Alias(),IndexOrd(),Recno()}
	
	mNum 		:= SC6->C6_NUM
	mItem   	:= SC6->C6_ITEM
	mProduto	:= SC6->C6_PRODUTO
	mEmissao	:= SC5->C5_EMISSAO
	mEntOrig	:= SC6->C6_ENTREG
	mEntNova	:= SC6->C6_ENTREG
	mQtdOrig	:= SC6->C6_QTDVEN
	mQtdNova    := SC6->C6_QTDENT
	mPrcOrig 	:= SC6->C6_PRCVEN
	mPrcNovo 	:= SC6->C6_PRCVEN
	mValOrig 	:= SC6->C6_VALOR
	mValNovo 	:= SC6->C6_VALOR - (mQtdOrig-mQtdNova) * mPrcOrig
	
	dbSelectArea("SZ8")
	RecLock("SZ8",.T.)
	Z8_FILIAL 	:= xFilial("SZ8")
	Z8_NUM	 	:= mNum
	Z8_ITEM		:= mItem
	Z8_PRODUTO	:= mProduto
	Z8_EMISSAO  := mEmissao
	Z8_EMINOVO  := ddatabase
	Z8_ENTREG 	:= mEntOrig
	Z8_ENTNOVA  := mEntNova
	Z8_QTDORIG  := mQtdOrig
	Z8_QTDNOVA  := mQtdNova
	Z8_PRCORIG	:= mPrcOrig
	Z8_PRCNOVO  := mPrcNovo
	Z8_VALORIG  := mValOrig
	Z8_VALNOVO  := mValNovo
	Z8_STATUS 	:= "R"
	msUnlock()
	
	DbSelectArea(_aSvAlias[1])
	DbSetOrder(_aSvAlias[2])
	DbGoTo(_aSvAlias[3])
Endif

Return
