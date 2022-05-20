#INCLUDE "rwmake.ch"       

// Rotina		: CONSIG
// Descrição	: Obs. Livros fiscais NF de consignação
// Obs			: Chamada da Formula 014 
// Data			: 13/01/05
// Autor        : Daniel Gondran

User Function CONSIG()
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
				If D2_CF == SF3->F3_CFO							
					If lPrim 
						_cString += D2_NFORI + "/" + D2_SERIORI + " de " + Dtoc(D2_EMISSAO)
						lPrim := .F.
					Else
						_cString += ", " + D2_NFORI + "/" + D2_SERIORI + " de " + Dtoc(D2_EMISSAO)
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