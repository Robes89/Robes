#Include "rwmake.ch"

User Function TEMPOFOI( lAuto )
Local	aBKP_aHeader, aBKP_aCols, nBKP_n

Private	lDigitaOP	:= lAuto

// Cadastro de tempos no fluxo de op´s - inclusão
// Wilson J. Santos
// Jan/2009

SetPrvt("AROTINA,COPCAO,NOPCE,NOPCG,NUSADO,AHEADER")
SetPrvt("ACOLS,_NI,CTITULO,CALIASENCHOICE,CALIASGETD,CLINOK")
SetPrvt("CTUDOK,CFIELDOK,ACPOENCHOICE,_LRET,aTitulos")

If	lAuto

	aBKP_aHeader	:= aClone( aHeader )
	aBKP_aCols		:= aClone( aCols )
	nBKP_n			:= n

	If	Empty( M->ZC_OP ) .or. Empty( M->ZC_CODLMT ) .or. Empty( M->ZC_PRODUTO )
		MsgBox( "Falta informar Nº da OP ou Código LMT ou Código Inteligente." , "Atenção..." , "STOP" )
		aHeader	:= aClone( aBKP_aHeader )
		aCols	:= aClone( aBKP_aCols )
		n		:= nBKP_n
		Return
	Else
		SZD->( DbSetOrder( 1 ) )
		If	SZD->( DbSeek( xFilial( "SZD" ) + M->ZC_OP ) )
			MsgBox( "Já lançado tempos para OP nº " + TransForm( M->ZC_OP , "@R 999999-99-999" ) , "Atenção..." , "STOP" )
			aHeader	:= aClone( aBKP_aHeader )
			aCols	:= aClone( aBKP_aCols )
			n		:= nBKP_n
			Return
		EndIf
	EndIf

EndIf

aRotina_OLD	:= aRotina
aTitulos	:= {}
cOpcao		:= "INCLUIR"
INCLUI		:= .T.
Do Case
	Case cOpcao=="INCLUIR";		nOpcE:=3 ; nOpcG:=3
	Case cOpcao=="ALTERAR";		nOpcE:=3 ; nOpcG:=3
	Case cOpcao=="VISUALIZAR";	nOpcE:=2 ; nOpcG:=2
	Case cOpcao=="EXCLUIR";		nOpcE:=2 ; nOpcG:=2
EndCase
RegToMemory("SZD",.T.,.F.)
nUsado:=0
dbSelectArea("SX3")
dbSeek("SZE")
aHeader:={}
While !Eof().And.(x3_arquivo=="SZE")
	If Alltrim(x3_campo)=="ZE_OP"
		dbSkip()
		Loop
	Endif
	If X3USO(x3_usado).And.cNivel>=x3_nivel
    	nUsado:=nUsado+1
        Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
	         x3_tamanho, x3_decimal,"AllwaysTrue()",;
    	     x3_usado, x3_tipo, x3_arquivo, x3_context } )
	Endif
    dbSkip()
End

If cOpcao == "INCLUIR"
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	For _ni:=1 to nUsado
		aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
	Next

	If	lAuto
		M->ZD_OP		:= M->ZC_OP
		M->ZD_CODLMT    := M->ZC_CODLMT
		M->ZD_PRODUTO	:= M->ZC_PRODUTO
	EndIf

Else
	cChave	:= ""
	aCols:={}
	dbSelectArea("SZE")
	dbSetOrder(1)
	dbSeek(xFilial()+M->ZD_OP)
	While !eof() .and. SZE->ZE_FILIAL == xFilial( "SZE" ) .and. SZE->ZE_OP == M->ZD_OP
		AADD(aCols,Array(nUsado+1))
		For _ni:=1 to nUsado
			aCols[Len(aCols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
		Next 
		aCols[Len(aCols),nUsado+1]:=.F.
		dbSkip()
	End
Endif
If Len(aCols)>0
	_nPosDel		:= Len(aHeader) + 1
	cTitulo			:= "Tempos - Fluxo de Op´s"
	cAliasEnchoice	:= "SZD"
	cAliasGetD		:= "SZE"
	cLinOk			:= "ExecBlock('TEMPOFOL',.f.,.f.)"
	cTudOk			:= "AllwaysTrue()"
	cFieldOk		:= "AllwaysTrue()"
	aCpoEnchoice	:= {}
	_lRet:=Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk)
	If _lRet .and. !Empty( aCols )

		RecLock( "SZD" , .T. )
		SZD->ZD_FILIAL	:= xFilial( "SZD" )
		SZD->ZD_OP		:= M->ZD_OP
		SZD->ZD_CODLMT	:= M->ZD_CODLMT
		SZD->ZD_PRODUTO	:= M->ZD_PRODUTO
		SZD->( MsUnLock() )

		For nLinha := 1 to Len( aCols )
//			If !aCols[nLinha,_nPosDel]
			If  !GDDeleted(nLinha)
				RecLock( "SZE" , .T. )
				SZE->ZE_FILIAL	:= xFilial( "SZE" )
				SZE->ZE_OP		:= M->ZD_OP
				SZE->ZE_DEPTO	:= aCols[ nLinha , 01 ]
				SZE->ZE_NRDIAS	:= aCols[ nLinha , 02 ]
				SZE->( MsUnLock() )
			EndIf

		Next nLinha

	EndIf

EndIf

aRotina	:= aRotina_OLD

If	lAuto
	aHeader	:= aClone( aBKP_aHeader )
	aCols	:= aClone( aBKP_aCols )
	n		:= nBKP_n
EndIf

Return
