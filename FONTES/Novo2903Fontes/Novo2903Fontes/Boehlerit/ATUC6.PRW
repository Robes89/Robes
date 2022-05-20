User Function ATUC6()

Processa( {|| ATU() } , "Atualização" )

Return NIL               



********************************************************************************************************************
Static Function ATU()

SC5->( DbSetOrder( 1 ) )
SC6->( DbSetOrder( 1 ) )

dbSelectArea("SC5")
dbGotop()
ProcRegua( SC5->( LastRec() ) )

While !SC5->( Eof() ) 

	IncProc( "Processando pedido » " + SC5->C5_NUM )
	
	If SC5->C5_STPAD == "S" 
		
		dbSelectArea("SC6")
		dbSeek(xFilial("SC6") + SC5->C5_NUM)
		do While !Eof() .and. SC6->C6_NUM == SC5->C5_NUM
			If SC6->C6_QTDENT < SC6->C6_QTDVEN .AND. !Empty(SC6->C6_NUMPEDP) .AND. Empty(SC6->C6_BLQ)
				nQuant 	:= SC6->C6_QTDVEN - SC6->C6_QTDENT
				nnPed	:= SC6->C6_NUMPEDP
				cItemPE	:= SC6->C6_ITEMPE
				ccCod	:= SC6->C6_PRODUTO
				XR := RECNO()
				If SC6->(dbSeek(xFilial("SC6") + nnPed + cItemPE + ccCod ))
					RecLock("SC6",.F.)
					SC6->C6_QTDEMP2	:= SC6->C6_QTDENT
					SC6->C6_QTDENT 	+= nQuant
					msUnlock()
				Endif
				dbGoto(XR)				
			Endif
			dbSkip()
		Enddo
	Endif	
	SC5->( DbSkip() )
EndDo

Return