#INCLUDE "rwmake.ch"

User Function MTA410()

If !(M->C5_TIPO $ "B/D") .AND. Empty(M->C5_VEND1)
	Alert ("Favor digitar codigo do vendedor")
	Return (.F.)
Endif

_lRet := .T.

If Altera .AND. M->C5_STPAD $ "SPE"
	_aSvAlias       := {Alias(),IndexOrd(),Recno()}
	
	nPosIte  := Ascan(aHeader,{|x| AllTrim(x[2]) == "C6_ITEM"})
	nPosPro  := Ascan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})
	nPosEnt  := Ascan(aHeader,{|x| AllTrim(x[2]) == "C6_ENTREG"})
	
	nPosQtd  := Ascan(aHeader,{|x| AllTrim(x[2]) == "C6_QTDVEN"})
	nPosPre  := Ascan(aHeader,{|x| AllTrim(x[2]) == "C6_PRCVEN"})
	nPosVal  := Ascan(aHeader,{|x| AllTrim(x[2]) == "C6_VALOR"})
	
	nPosSta	 := Ascan(aHeader,{|x| AllTrim(x[2]) == "C6_NUMPEDP"})
	
	//	If StrZero(Year(ddatabase),4) + StrZero(month(ddatabase),2) >;
	//	   StrZero(Year(SC5->C5_EMISSAO),4) + StrZero(month(SC5->C5_EMISSAO),2)
	
	dbSelectArea("SC6")
	dbSetOrder(1)
	dbSeek(xFilial("SC6") + SC5->C5_NUM)
	mPedido := Month(SC5->C5_EMISSAO)
	nRecs  := 0
	nAcols := 0
	do While !Eof() .and. xFilial("SC6") == C6_FILIAL .and. SC5->C5_NUM == C6_NUM
		nRecs ++
		dbSkip()
	Enddo
	
	For kkk := 1 to Len (aCols)
		If !aCols[kkk,Len(aHeader) + 1]
			nAcols++
		Endif
		dbSelectArea("SC6")
		dbSetOrder(1)
		dbSeek(xFilial("SC6") + SC5->C5_NUM + aCols[kkk,nPosIte] + aCols[kkk,nPosPro])
		lIgual := .T.
		mNum 		:= C6_NUM
		mItem   	:= C6_ITEM
		mProduto	:= C6_PRODUTO
		mEmissao	:= SC5->C5_EMISSAO
		mEntOrig	:= C6_ENTREG
		mEntNova	:= C6_ENTREG
		mQtdOrig	:= C6_QTDVEN
		mQtdNova    := C6_QTDVEN
		mPrcOrig 	:= C6_PRCVEN
		mPrcNovo 	:= C6_PRCVEN
		mValOrig 	:= C6_VALOR
		mValNovo 	:= c6_VALOR
		MSTATUS		:= C6_NUMPEDP
		
		If !Empty(mStatus) .and. SC5->C5_STPAD == "S"
			dbSelectArea("SZ8")
			RecLock("SZ8",.T.)
			Z8_FILIAL 	:= xFilial("SZ8")
			Z8_NUM	 	:= mNum
			Z8_ITEM		:= mItem
			Z8_PRODUTO	:= mProduto
			Z8_EMISSAO  := mEmissao
			Z8_EMINOVO  := ddatabase
			Z8_ENTREG 	:= mEntOrig
			Z8_ENTNOVO  := mEntNova
			Z8_QTDORIG  := mQtdOrig
			Z8_QTDNOVA  := mQtdNova
			Z8_PRCORIG	:= mPrcOrig
			Z8_PRCNOVO  := mPrcNovo
			Z8_VALORIG  := mValOrig
			Z8_VALNOVO  := mValNovo
			Z8_STATUS	:= "E"
			msUnlock()
		Endif
		
		If dbSeek(xFilial("SC6") + SC5->C5_NUM + aCols[kkk,nPosIte] + aCols[kkk,nPosPro])
			If aCols[kkk,nPosQtd] <> SC6->C6_QTDVEN
				lIgual := .F.
				mQtdOrig := SC6->C6_QTDVEN
				mQtdNova := aCols[kkk,nPosQtd]
			Endif
			If aCols[kkk,nPosPre] <> SC6->C6_PRCVEN
				lIgual := .F.
				mPrcOrig := SC6->C6_PRCVEN
				mPrcNovo := aCols[kkk,nPosPre]
			Endif
			If aCols[kkk,nPosEnt] <> SC6->C6_ENTREG
				lIgual := .F.
				mEntOrig := SC6->C6_ENTREG
				mEntNova := aCols[kkk,nPosEnt]
			Endif
			If !lIgual
				mValOrig := SC6->C6_VALOR
				mValNovo := aCols[kkk,nPosVal]
				dbSelectArea("SZ8")
				RecLock("SZ8",.T.)
				Z8_FILIAL 	:= xFilial("SZ8")
				Z8_NUM	 	:= mNum
				Z8_ITEM		:= mItem
				Z8_PRODUTO	:= mProduto
				Z8_EMISSAO  := mEmissao
				Z8_EMINOVO  := ddatabase
				Z8_ENTREG 	:= mEntOrig
				Z8_ENTNOVO  := mEntNova
				Z8_QTDORIG  := mQtdOrig
				Z8_QTDNOVA  := mQtdNova
				Z8_PRCORIG	:= mPrcOrig
				Z8_PRCNOVO  := mPrcNovo
				Z8_VALORIG  := mValOrig
				Z8_VALNOVO  := mValNovo
				Z8_STATUS	:= "A"
				msUnlock()
			Endif
		Else
			dbSelectArea("SZ8")
			RecLock("SZ8",.T.)
			Z8_FILIAL 	:= xFilial("SZ8")
			Z8_NUM	 	:= SC5->C5_NUM
			Z8_ITEM		:= aCols[kkk,nPosIte]
			Z8_PRODUTO	:= aCols[kkk,nPosPro]
			Z8_EMISSAO  := SC5->C5_EMISSAO
			Z8_EMINOVO  := ddatabase
			Z8_ENTREG 	:= CTOD("  /  /  ")
			Z8_ENTNOVO 	:= aCols[kkk,nPosEnt]
			Z8_QTDORIG  := 0
			Z8_QTDNOVA  := aCols[kkk,nPosQtd]
			Z8_PRCORIG	:= 0
			Z8_PRCNOVO  := aCols[kkk,nPosPre]
			Z8_VALORIG  := 0
			Z8_VALNOVO  := aCols[kkk,nPosVal]
			Z8_STATUS	:= "I"
			msUnlock()
			If SC6->(dbSeek(xFilial("SC6") + SC5->C5_NUM + aCols[kkk,nPosIte])) .and. SC6->C6_PRODUTO <> aCols[kkk,nPosPro]
				dbSelectArea("SZ8")
				RecLock("SZ8",.T.)
				Z8_FILIAL 	:= xFilial("SZ8")
				Z8_NUM	 	:= SC5->C5_NUM
				Z8_ITEM		:= aCols[kkk,nPosIte]
				Z8_PRODUTO	:= SC6->C6_PRODUTO
				Z8_EMISSAO  := SC5->C5_EMISSAO
				Z8_EMINOVO  := ddatabase
				Z8_ENTREG 	:= SC6->C6_ENTREG
				Z8_ENTNOVO 	:= CTOD("  /  /  ")
				Z8_QTDORIG  := SC6->C6_QTDVEN
				Z8_QTDNOVA  := 0
				Z8_PRCORIG	:= SC6->C6_PRCVEN
				Z8_PRCNOVO  := 0
				Z8_VALORIG  := SC6->C6_VALOR
				Z8_VALNOVO  := 0
				Z8_STATUS	:= "R"
				msUnlock()
			Endif
		Endif
	Next
	
	If nRecs > nAcols .and. month(ddatabase) > mpedido
		Alert("Nao pode excluir itens. Utilize Eliminação de Residuos.")
		_lRet := .F.
	Endif
	//	Endif
	
	DbSelectArea(_aSvAlias[1])
	DbSetOrder(_aSvAlias[2])
	DbGoTo(_aSvAlias[3])
Endif

If Inclui
	_aSvAlias       := {Alias(),IndexOrd(),Recno()}
	
	nPosSta  := Ascan(aHeader,{|x| AllTrim(x[2]) == "C6_NUMPEDP"})
	nPosPe   := Ascan(aHeader,{|x| AllTrim(x[2]) == "C6_ITEMPE"})
	nPosIte  := Ascan(aHeader,{|x| AllTrim(x[2]) == "C6_ITEM"})
	nPosPro  := Ascan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})
	nPosEnt  := Ascan(aHeader,{|x| AllTrim(x[2]) == "C6_ENTREG"})
	nPosQtd  := Ascan(aHeader,{|x| AllTrim(x[2]) == "C6_QTDVEN"})
	nPosPre  := Ascan(aHeader,{|x| AllTrim(x[2]) == "C6_PRCVEN"})
	nPosVal  := Ascan(aHeader,{|x| AllTrim(x[2]) == "C6_VALOR"})
	
	For kkk :=1 to len(acols)
		If M->C5_STPAD $ "S/P" .AND. !Empty(acols[kkk,nPosSta]) .and. !aCols[kkk,Len(aHeader) + 1]
			aArea_SC6	:= SC6->( GetArea() )
			
			dbSelectArea("SC6")
			nnPed	:= acols[kkk,nPosSta]
			cItemPE	:= acols[kkk,nPosPe]
			ccCod	:= acols[kkk,nPosPro]
			nQtd	:= acols[kkk,nPosQtd]
			
			// Atualiza item do pedido estimado
			
			SC6->(dbSetOrder(1))
			SC6->(dbSeek(xFilial("SC6") + nnPed + cItemPE + ccCod ))
			
			While !SC6->( Eof() ) .and.	SC6->C6_FILIAL	== xFilial() .and. ;
				SC6->C6_NUM		== nnPed .and. ;
				SC6->C6_ITEM	== cItemPE .and. ;
				SC6->C6_PRODUTO	== ccCod
				Reclock("SC6",.f.)
				SC6->C6_QTDENT += nQtd
				SC6->( MsUnlock() )
				SC6->(dbSkip())
			Enddo
			
			RestArea( aArea_SC6 )
		Endif
	Next
	
	DbSelectArea(_aSvAlias[1])
	DbSetOrder(_aSvAlias[2])
	DbGoTo(_aSvAlias[3])
Endif


Return(_lRet)
