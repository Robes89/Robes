#INCLUDE "rwmake.ch"       

// Rotina		: _NFORI2
// Descrição	: Referente NF Original ___ Complementar Importação
// Obs			: Chamada do Cadastro de Fórmula
// Data			: 01/02/05
// Autor        : Daniel Gondran

User Function _NFORI2()
	If Left(AllTrim(FunName()),5) $"NFLMT/NFFETTE"  
		_aSvAlias := {Alias(),IndexOrd(),Recno()}
		_cString  := ""
		lPrim     := .T.
	
		dbSelectArea("SF8")
		oldOrdF8 := IndexOrd()
		oldRecF8 := Recno()
		dbSetOrder(1)
		aNotas := {}
		If dbSeek(xFilial("SF8") + SF1->F1_DOC + SF1->F1_SERIE)
			do While !Eof() .and. F8_FILIAL == xFilial("SF8") .and. F8_NFDIFRE + F8_SEDIFRE;
											== SF1->F1_DOC + SF1->F1_SERIE 
				If !Empty(F8_NFORIG)
					If lPrim 
						If Ascan(aNotas,F8_NFORIG) == 0
							_cString += F8_NFORIG 
							lPrim := .F.
							aadd(aNotas,F8_NFORIG)
						Endif
					Else
						If Ascan(aNotas,F8_NFORIG) == 0
							_cString += ", " + F8_NFORIG
							aadd(aNotas,F8_NFORIG)
						Endif
					Endif
				Endif
				dbSkip()
			Enddo
			dbSetOrder(oldOrdF8)
			dbGoto(oldRecF8)
		Endif
		DbSelectArea(_aSvAlias[1])
		DbSetOrder(_aSvAlias[2])
		DbGoTo(_aSvAlias[3])
		Return (_cString)
	Else	
		Return ("")
	Endif