#INCLUDE "rwmake.ch"       

// Rotina		: _NFORI
// Descrição	: Referente NF Original ___ Devolução
// Obs			: Chamada da Formula 016
// Data			: 01/02/05
// Autor        : Daniel Gondran

User Function _NFORI()
	If AllTrim(FunName()) == "NFLMT"  
		_aSvAlias := {Alias(),IndexOrd(),Recno()}
		_cString  := ""
		lPrim     := .T.
	
		dbSelectArea("SD2") 
		oldOrdD2 := IndexOrd()
		oldRecD2 := Recno()
		dbSetOrder(3)
		aNotas := {}
		If dbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE)
			do While !Eof() .and. D2_FILIAL == xFilial("SD2") .and. D2_DOC + D2_SERIE;
											== SF2->F2_DOC + SF2->F2_SERIE 
				If !Empty(D2_NFORI)
					If lPrim 
						If Ascan(aNotas,D2_NFORI) == 0
							_cString += D2_NFORI 
							lPrim := .F.
							aadd(aNotas,D2_NFORI)
						Endif
					Else
						If Ascan(aNotas,D2_NFORI) == 0
							_cString += ", " + D2_NFORI 
							aadd(aNotas,D2_NFORI)
						Endif
					Endif
				Endif
				dbSkip()
			Enddo
			dbSetOrder(oldOrdD2)
			dbGoto(oldRecD2)
		Endif
		DbSelectArea(_aSvAlias[1])
		DbSetOrder(_aSvAlias[2])
		DbGoTo(_aSvAlias[3])
		Return (_cString)
	Else	
		Return ("")
	Endif