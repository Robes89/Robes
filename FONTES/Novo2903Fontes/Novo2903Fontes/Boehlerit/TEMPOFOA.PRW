User Function TEMPOFOA()

// Cadastro de tempos no fluxo de op´s - alteração
// Wilson J. Santos
// Jan/2009

SetPrvt("AROTINA,COPCAO,NOPCE,NOPCG,NUSADO,AHEADER")
SetPrvt("ACOLS,_NI,CTITULO,CALIASENCHOICE,CALIASGETD,CLINOK")
SetPrvt("CTUDOK,CFIELDOK,ACPOENCHOICE,_LRET,")

aRotina_OLD	:= aRotina
cOpcao		:= "ALTERAR"
INCLUI		:= .F.
Do Case
	Case cOpcao=="INCLUIR";		nOpcE:=3 ; nOpcG:=3
	Case cOpcao=="ALTERAR";		nOpcE:=3 ; nOpcG:=3
	Case cOpcao=="VISUALIZAR";	nOpcE:=2 ; nOpcG:=2
	Case cOpcao=="EXCLUIR";		nOpcE:=2 ; nOpcG:=2
EndCase
RegToMemory("SZD",.F.)
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
Else
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

		SZE->( DbSetOrder( 1 ) )
		SZE->( DbSeek( xFilial( "SZE" ) + M->ZD_OP ) )
		While !SZE->( Eof() ) .and. SZE->ZE_FILIAL == xFilial( "SZE" ) .and. SZE->ZE_OP == M->ZD_OP
			RecLock( "SZE" )
			SZE->( DbDelete() )
			SZE->( DbSkip() )
		EndDo
		
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

	Endif

Endif
      
aRotina	:= aRotina_OLD

Return
