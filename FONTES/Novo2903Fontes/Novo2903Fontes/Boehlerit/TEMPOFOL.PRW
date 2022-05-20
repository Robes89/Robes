#Include "rwmake.ch"

User Function TEMPOFOl()

// Cadastro de tempos no fluxo de op´s - validação da linha
// Wilson J. Santos
// Jan/2009

Local	cZE_DEPTO		:= aCols[n][GdFieldPos("ZE_DEPTO",aHeader)]
Local	nPosZE_DEPTO	:= GdFieldPos("ZE_DEPTO",aHeader)

For nLinha := 1 To Len(aCols)
//	If	!aCols[nLinha,_nPosDel] .and. nLinha # n
	If  !GDDeleted(nLinha) .and. nLinha # n
		If cZE_DEPTO == aCols[nLinha][GdFieldPos("ZE_DEPTO",aHeader)]
			MsgBox( "Departamento já informado.", "Atenção...", "STOP" )
			Return( .F. )
		EndIf
	EndIf                            
Next nLinha

Return( .T. )
