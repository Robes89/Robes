User Function ATUVEN()

Processa( {|| ATU() } , "Atualização" )

Return NIL               



********************************************************************************************************************
Static Function ATU()

SD2->( DbSetOrder( 3 ) )
SF2->( DbSetOrder( 1 ) )
SC5->( DbSetOrder( 1 ) )

dbSelectArea("SF2")
dbSetOrder(1)
dbGOTOP()
ProcRegua( SF5->( LastRec() ) )

While !SF2->( Eof() ) 

	IncProc( "Processando DOC » " + SF2->F2_DOC )
	
	If SF2->F2_VEND1 == "000010" 
		dbSelectArea("SD2")
		If dbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA)
			dbSelectArea("SC5")
			If dbSeek(xFilial("SC5") + SD2->D2_PEDIDO)
				If SC5->C5_EMISSAO >= ctod("07/04/2006")
					RecLock("SF2")
					SF2->F2_VEND1 := "000026"
					msUnlock()
				Endif
			Endif
		Endif
	Endif

	If SF2->F2_VEND2 == "000010" 
		dbSelectArea("SD2")
		If dbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA)
			dbSelectArea("SC5")
			If dbSeek(xFilial("SC5") + SD2->D2_PEDIDO)
				If SC5->C5_EMISSAO >= ctod("07/04/2006")
					RecLock("SF2")
					SF2->F2_VEND2 := "000026"
					msUnlock()
				Endif
			Endif
		Endif
	Endif

	
	SF2->( DbSkip() )
EndDo

Return