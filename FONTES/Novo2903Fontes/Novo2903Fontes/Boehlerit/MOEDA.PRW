User Function MOEDA()                        

_aSvAlias       := {Alias(),IndexOrd(),Recno()}

lRet := .F.
If M->C5_MOEDA <> 1
	dbSelectArea("SM2")
	dbSetOrder(1)
	If dbSeek(M->C5_EMISSAO) .and. &("M2_MOEDA" + StrZero(M->C5_MOEDA,1)) > 0
		lRet := .T.
	Endif
Else
	lRet := .T.
Endif

If !lRet
	Alert("Taxa da moeda não cadastrada em " + dtoc(M->C5_EMISSAO))  
Endif
// Retorna Area de Trabalho
DbSelectArea(_aSvAlias[1])
DbSetOrder(_aSvAlias[2])
DbGoTo(_aSvAlias[3])

Return(lRet)