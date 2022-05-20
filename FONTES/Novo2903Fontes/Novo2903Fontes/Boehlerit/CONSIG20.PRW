#INCLUDE "rwmake.ch"       

// Rotina		: CONSIG
// Descrição	: Obs. Livros fiscais NF de consignação
// Obs			: Chamada da Formula 020 
// Data			: 10/02/05
// Autor        : Daniel Gondran

User Function CONSIG20()
	If AllTrim(FunName()) $ "MATR930/MATR920"  
		_aSvAlias := {Alias(),IndexOrd(),Recno()}
		_cString  := ""
		lPrim     := .T.
	
		dbSelectArea("SF2")
		oldOrdF2 := IndexOrd()
		oldRecF2 := Recno()
		dbSetOrder(1)
		If dbSeek(xFilial("SF2") + SF3->F3_NFISCAL + SF3->F3_SERIE + SF3->F3_CLIEFOR + SF3->F3_LOJA)	
			_cString  := "Venda em Consignacao industrial - NF "
			nConsig   := 0
			dbSelectArea("SD2")
			oldOrdD2 := IndexOrd()
			oldRecD2 := Recno()
			dbSetOrder(3)
    	
			dbSeek(xFilial("SD2") + SF3->F3_NFISCAL + SF3->F3_SERIE + SF3->F3_CLIEFOR + SF3->F3_LOJA)
			do While !Eof() .and. D2_FILIAL == xFilial("SD2") .and. D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA;
											== SF3->F3_NFISCAL + SF3->F3_SERIE + SF3->F3_CLIEFOR + SF3->F3_LOJA
				SF2->(dbSeek(xFilial("SF2") + SD2->D2_NFORI + IIF(SD2->D2_NFORI<="089707","ZZZ",SD2->D2_SERIORI)))																		
				If Substr(D2_CF,2,3) == "112"							
					If lPrim 
						_cString += D2_NFORI + "/" + D2_SERIORI    //* + " de " + Dtoc(SF2->F2_EMISSAO) alterado por Regina
						lPrim := .F.
					Else
						_cString += ", " + D2_NFORI + "/" + D2_SERIORI // + " de " + Dtoc(SF2->F2_EMISSAO) alterado por Regina
					Endif
					nConsig += D2_TOTAL
				Endif
				dbSkip()
			Enddo
			_cString += " Total: " + AllTrim(Str(nConsig,12,2))
			dbSetOrder(oldOrdD2)
			dbGoto(oldRecD2)
		Endif
		dbSelectArea("SF2")
		dbSetOrder(oldOrdF2)
		dbGoto(oldRecF2)
		DbSelectArea(_aSvAlias[1])
		DbSetOrder(_aSvAlias[2])
		DbGoTo(_aSvAlias[3])
		Return (_cString)
	Else	
		Return ("")
	Endif