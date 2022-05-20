#Include "rwmake.ch"

User Function MT930SF3()

If mv_par03 == 2 .and. SF3->F3_FORMULA $ "014/020"	// nf's de saídas, resumo de ipi
	
	cChave := SF3->F3_NFISCAL + SF3->F3_SERIE + SF3->F3_CLIEFOR + SF3->F3_LOJA
	nRecno := Recno()
	do While SF3->F3_NFISCAL + SF3->F3_SERIE + SF3->F3_CLIEFOR + SF3->F3_LOJA == cChave
		If SF3->F3_FORMULA $ "014/020"
			RecLock( "SF3",.F. )
			SF3->F3_VALCONT	:= 0
			SF3->( MsUnLock() )
		Endif
		dbSkip()
	Enddo
	dbGoto(nRecno)
	
EndIf

Return
