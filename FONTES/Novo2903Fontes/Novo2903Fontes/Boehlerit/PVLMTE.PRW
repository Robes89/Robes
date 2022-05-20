User Function PVLMTE()

SetPrvt("AROTINA,COPCAO,NOPCE,NOPCG,NUSADO,AHEADER")
SetPrvt("ACOLS,_NI,CTITULO,CALIASENCHOICE,CALIASGETD,CLINOK")
SetPrvt("CTUDOK,CFIELDOK,ACPOENCHOICE,_LRET,")

cOpcao	:= "EXCLUIR"
Do Case
	Case cOpcao=="INCLUIR";		nOpcE:=3 ; nOpcG:=3
	Case cOpcao=="ALTERAR";		nOpcE:=3 ; nOpcG:=3
	Case cOpcao=="VISUALIZAR";	nOpcE:=2 ; nOpcG:=2
	Case cOpcao=="EXCLUIR";		nOpcE:=2 ; nOpcG:=2
EndCase
RegToMemory("SZ4",.F.)
cChave	:= M->Z4_TIPO + IF( M->Z4_TIPO $ "A/M" , M->Z4_MARCA , M->Z4_VEND )
nUsado:=0

dbSelectArea("SX3")
dbSeek("SZ5")
aHeader:={}
While !Eof().And.(x3_arquivo=="SZ5")
	If Alltrim(x3_campo)=="Z5_TIPO" .or. Alltrim(x3_campo)=="Z5_MARCA" .or. ;
		Alltrim(x3_campo)=="Z5_VEND"
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
	dbSelectArea("SZ5")
	dbSetOrder(IF( M->Z4_TIPO $ "A/M" , 1 , 2 ) )
	dbSeek(xFilial()+M->Z4_TIPO+IF( M->Z4_TIPO $ "A/M" , M->Z4_MARCA , M->Z4_VEND ) )
	While !eof() .and. SZ5->Z5_TIPO == M->Z4_TIPO .and. ;
		IF( M->Z4_TIPO $ "A/M" , SZ5->Z5_MARCA == M->Z4_MARCA , SZ5->Z5_VEND == M->Z4_VEND )
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
	cTitulo			:= "Previsão de Vendas LMT"
	cAliasEnchoice	:= "SZ4"
	cAliasGetD		:= "SZ5"
	cLinOk			:= "AllwaysTrue()"
	cTudOk			:= "AllwaysTrue()"
	cFieldOk		:= "AllwaysTrue()"
	aCpoEnchoice	:= {"Z5_ANO","Z5_VALOR01","Z5_VALOR02","Z5_VALOR03","Z5_VALOR04",;
						"Z5_VALOR05","Z5_VALOR06","Z5_VALOR07","Z5_VALOR08","Z5_VALOR09",;
						"Z5_VALOR10","Z5_VALOR11","Z5_VALOR12"}
	_lRet:=Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk)

	If _lRet

		If SZ4->( DbSeek( xFilial( "SZ4" ) + cChave ) )
			RecLock( "SZ4" , .F. )
			SZ4->( DbDelete() )
			SZ4->( MsUnLock() )
		EndIf

		SZ5->( DbSetOrder( IF( M->Z4_TIPO $ "A/M" , 1 , 2 ) ) )
		SZ5->( DbSeek( xFilial( "SZ5" ) + cChave ) )
		While !SZ5->( Eof() ) .and. SZ5->Z5_FILIAL == xFilial( "SZ5" ) .and. ;
			IF( M->Z4_TIPO $ "A/M" , SZ5->( Z5_TIPO + Z5_MARCA ) , SZ5->( Z5_TIPO + Z5_VEND ) ) == cChave
			RecLock( "SZ5" )
			SZ5->( DbDelete() )
			SZ5->( DbSkip() )
		EndDo

	EndIf

Endif

Return
