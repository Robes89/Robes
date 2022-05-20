#include "rwmake.ch"
#include "mata096.ch"
#INCLUDE "PROTHEUS.CH"          
#Define	PULA_LINHA	CHR( 13 ) + CHR( 10 )

// Fluxo de OP´s
// Wilson Santos
// Dez/2008

User Function FLUOPS()

Private	aRotina		:=	{	{ OemToAnsi("&Pesquisar"), 			"AxPesqui",	0,	1},;
							{ OemToAnsi("&Visualizar"),			"U_FOVIS",	0,	2},;
							{ OemToAnsi("P&cp"),				"U_FOPCP",	0,	3},;
							{ OemToAnsi("C&ompras"),			"U_FOMAN",	0,	4},;
							{ OemToAnsi("&Almoxarifado"),		"U_FOMAN",	0,	4},;
							{ OemToAnsi("C&Q Item"),			"U_FOMAN",	0,	4},;
							{ OemToAnsi("&BF"),					"U_FOMAN",	0,	4},;
							{ OemToAnsi("CQ B&F"),				"U_FOMAN",	0,	4},;
							{ OemToAnsi("Apo&nt.Produção"),		"U_FOMAN",	0,	4},;
							{ OemToAnsi("Es&toque"),			"U_FOMAN",	0,	4},;
							{ OemToAnsi("E&xcluir Processo"),	"U_FOEXCP",	0,	5},;
							{ OemToAnsi("Ex&cluir Últ.Lançto"),	"U_FOEXCU",	0,	5},;
							{ OemToAnsi("Produção"),			"U_FOPROD",	0,	6} }


Private	cCadastro	:= OemToAnsi("Fluxo de OP´s")
Private	aTipoOP		:= { "P-Pedido", "E-Estoque" }

If	SM0->M0_CODIGO # "01"
	MsgBox( "Rotina disponível apenas para empresa LMT.", "ATENÇÃO...", "STOP" )
	Return
EndIf

dbSelectArea("SZC")
dbSetOrder(1)

mBrowse( 6, 1,22,75,"SZC")

dbSelectArea("SZC")
dbSetOrder(1)

Return

********************************************************************************************************************
User Function FOPCP(cAlias,nReg,nOpcx)
Local	bCampo, oDlg, oGet, oReq, oComp
Local	lGravaOK	:= .T.
Local	nSaveSX8	:= GetSX8Len()
Local	aSizeAut	:= MsAdvSize(,.F.)   
Local	aObjects	:= {}
Local	aInfo 		:= {}
Local	aPosObj		:= {}

Private	aButtons	:= {}
Private	nOpca		:= 0
Private	dZC_DTUS	:= Criavar( "ZC_DTSAI" )

Private	aCols		:= {}
Private	aHeader		:= {}

//aAdd( aButtons , { "EDIT" , {|| u_TEMPOFOI( .T. ) } , "Tempos" } )

If	!RetCodUsr() $ GetMv( "MV_FP_PCP" )
	MsgBox( "Inclusão somente permitida para usuário do setor de PCP." + PULA_LINHA + PULA_LINHA +;
	"Parâmetro 'MV_FP_PCP'", "Sem permissão..." , "STOP" )
	Return
EndIf

dbSelectArea( "SZC" )
SZC->( dbSetOrder( 1 ) )
aArea_SZC	:= SZC->( GetArea() )
Private	cZC_TIPOOP	:= SZC->ZC_TIPOOP
Private	cZC_OP		:= SZC->ZC_OP

If	SZC->( DbSeek( xFilial( "SZC" ) + cZC_OP ) ) .and. Empty( SZC->ZC_DTSAI )
	U_FOMAN( cAlias, nReg, 4 )
	Return
Else
	aAdd( aButtons , { "EDIT" , {|| u_TEMPOFOI( .T. ) } , "Tempos" } )
EndIf

RestArea( aArea_SZC )
nSavReg  := RecNo()
M->ZC_TIPOOP	:= CriaVar( "ZC_TIPOOP" )
M->ZC_OP		:= CriaVar( "ZC_OP" )
M->ZC_CODLMT	:= CriaVar( "ZC_CODLMT" )
M->ZC_DENOM		:= CriaVar( "ZC_DENOM" )
M->ZC_PRODUTO	:= CriaVar( "ZC_PRODUTO" )
M->ZC_CLIENTE	:= CriaVar( "ZC_CLIENTE" )
M->ZC_LOJACLI	:= CriaVar( "ZC_LOJACLI" )
M->ZC_NOMCLI	:= CriaVar( "ZC_NOMCLI" )
M->ZC_VEND		:= CriaVar( "ZC_VEND" )
M->ZC_NOMVEN	:= CriaVar( "ZC_NOMVEN" )

Private aTELA[0][0],aGETS[0],aHeader[0],Continua,nUsado:=0
bCampo := {|nCPO| Field(nCPO) }
aCampos	:= { "ZC_SEQ", "ZC_DEPTOOR", "ZC_DTENT", "ZC_TIPFAB", "ZC_FORNEC", "ZC_LOJAFOR", "ZC_NOMFOR", "ZC_DTSAI", "ZC_DEPTODE", "ZC_OBS" }

DbSelectArea( "SX3" )
SX3->( DbSetOrder( 2 ) )
For nCA := 1 to Len( aCampos )
	If	SX3->( DbSeek( aCampos[ nCA ] ) ) .and. X3USO( SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
	EndIf
Next nCA

/*
dbSelectArea("SX3")
dbsetorder(1)
dbSeek( "SZC" )
While !EOF() .And. (x3_arquivo == "SZC" )
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ;
		AllTrim(x3_campo) $ "ZC_SEQ/ZC_DEPTOOR/ZC_DTENT/ZC_TIPFAB/ZC_FORNEC/ZC_LOJAFOR/ZC_NOMFOR/ZC_DTSAI/ZC_DEPTODE/ZC_OBS"
//		AllTrim(x3_campo) $ "ZC_SEQ/ZC_DEPTOOR/ZC_DTENT/ZC_DTSAI/ZC_DEPTODE/ZC_OBS"
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
	Endif
	dbSkip()
End
*/

_nPosDel		:= Len(aHeader) + 1

Private aCOLS[1][nUsado+1]

/*
dbSelectArea("SX3")
dbsetorder(1)
dbSeek( "SZC" )
nUsado:=0
While !EOF() .And. (x3_arquivo == "SZC" )
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ;
		AllTrim(x3_campo) $ "ZC_SEQ/ZC_DEPTOOR/ZC_DTENT/ZC_TIPFAB/ZC_FORNEC/ZC_LOJAFOR/ZC_NOMFOR/ZC_DTSAI/ZC_DEPTODE/ZC_OBS"
//		AllTrim(x3_campo) $ "ZC_SEQ/ZC_DEPTOOR/ZC_DTENT/ZC_DTSAI/ZC_DEPTODE/ZC_OBS"
		nUsado++
		If		AllTrim(aHeader[nUsado][2]) == "ZC_SEQ"
			aCOLS[1][nUsado] := Repl("0",x3_tamanho-1)+"1"
		ElseIf	AllTrim(aHeader[nUsado][2]) == "ZC_DEPTOOR"
			aCOLS[1][nUsado] := "3"
		ElseIf	AllTrim(aHeader[nUsado][2]) == "ZC_DTENT" .and. Left( M->ZC_TIPOOP, 1 ) == "P"
			aCOLS[1][nUsado] := Posicione( "SC2", 1, xFilial( "SC2" ) + M->ZC_OP, "C2_EMISSAO" )
		Else
			aCOLS[1][nUsado] := CriaVar(x3_campo)
		Endif
	Endif
	dbSkip()
EndDo
*/

nUsado:=0
DbSelectArea( "SX3" )
SX3->( DbSetOrder( 2 ) )
For nCA := 1 to Len( aCampos )
	If	SX3->( DbSeek( aCampos[ nCA ] ) ) .and. X3USO( SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL
		nUsado++
		If		AllTrim(aHeader[nUsado][2]) == "ZC_SEQ"
			aCOLS[1][nUsado] := Repl("0",x3_tamanho-1)+"1"
		ElseIf	AllTrim(aHeader[nUsado][2]) == "ZC_DEPTOOR"
			aCOLS[1][nUsado] := "3"
		ElseIf	AllTrim(aHeader[nUsado][2]) == "ZC_DTENT" .and. Left( M->ZC_TIPOOP, 1 ) == "E"
			aCOLS[1][nUsado] := Posicione( "SC2", 1, xFilial( "SC2" ) + M->ZC_OP, "C2_EMISSAO" )
		Else
			aCOLS[1][nUsado] := CriaVar(x3_campo)
		Endif
	EndIf
Next nCA

aCOLS[1][nUsado+1] := .F.

Continua := .F.
nOpca := 0
AAdd( aObjects, { 0,    25, .T., .F. })
AAdd( aObjects, { 100, 100, .T., .T. })
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
aPosObj := MsObjSize( aInfo, aObjects )
DEFINE MSDIALOG oDlg TITLE OemToAnsi("Fluxo de OP´s") From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

@ 020,005 SAY OemToAnsi("Tipo OP") OF oDlg PIXEL
@ 020,045 MSCOMBOBOX  oTipoOP VAR M->ZC_TIPOOP ITEMS aTipoOP Valid Left( M->ZC_TIPOOP, 1 ) $ "PE" SIZE 40,44 OF oDlg PIXEL

@ 020,090 SAY OemToAnsi("O.P.") OF oDlg PIXEL
@ 020,105 MSGET M->ZC_OP Picture "@!" F3 "SC2" Valid EXISTCHAV( "SZC", M->ZC_OP ) .and. FO1() .and. ;
CheckSX3("ZC_OP") When VisualSX3("ZC_OP") OF oDlg PIXEL 

@ 035,005 SAY OemToAnsi("Cód.LMT") OF oDlg PIXEL
@ 035,045 MSGET M->ZC_CODLMT When .F. OF oDlg PIXEL

@ 050,005 SAY OemToAnsi("Denominação") OF oDlg PIXEL
@ 050,045 MSGET M->ZC_DENOM When .F. OF oDlg PIXEL

@ 065,005 SAY OemToAnsi("Produto") OF oDlg PIXEL
@ 065,045 MSGET M->ZC_PRODUTO When .F. OF oDlg PIXEL

@ 080,005 SAY OemToAnsi("Cliente") OF oDlg PIXEL
@ 080,045 MSGET M->ZC_CLIENTE When .F. OF oDlg PIXEL

@ 080,090 SAY OemToAnsi("Loja") OF oDlg PIXEL
@ 080,105 MSGET M->ZC_LOJACLI When .F. OF oDlg PIXEL

@ 080,135 MSGET M->ZC_NOMCLI When .F. OF oDlg PIXEL

@ 095,005 SAY OemToAnsi("Vendedor") OF oDlg PIXEL
@ 095,045 MSGET M->ZC_VEND When .F. OF oDlg PIXEL

@ 095,135 MSGET M->ZC_NOMVEN When .F. OF oDlg PIXEL

oGet := MSGetDados():New(aPosObj[2,1]+70,aPosObj[2,2],aPosObj[2,3]+25,aPosObj[2,4],nOpcx,"U_FOLINHA('3')","AllwaysTrue","+ZC_SEQ",.T.,,2,,1)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()},,aButtons)

If nOpcA == 1

	Begin Transaction

		lTemItem	:= .F.
		For nLinha := 1 to Len( aCols )
			If  !GDDeleted(nLinha)
				lTemItem	:= .T.
				Exit
			EndIf
		Next nLinha

		If	!lTemItem
			Return
		EndIf

		lGeraDestino	:= .F.

		For nYY := 1 to 2

			If	nYY == 2 .and. !lGeraDestino
				Exit
			EndIf

			RecLock( "SZC", .T. )
			SZC->ZC_FILIAL	:= xFilial( "SZC" )
			SZC->ZC_TIPOOP	:= M->ZC_TIPOOP
			SZC->ZC_OP		:= M->ZC_OP
			SZC->ZC_CODLMT	:= M->ZC_CODLMT
			SZC->ZC_DENOM	:= M->ZC_DENOM
			SZC->ZC_PRODUTO	:= M->ZC_PRODUTO
			SZC->ZC_CLIENTE	:= M->ZC_CLIENTE
			SZC->ZC_LOJACLI	:= M->ZC_LOJACLI
			SZC->ZC_NOMCLI	:= M->ZC_NOMCLI
			SZC->ZC_VEND	:= M->ZC_VEND
			SZC->ZC_NOMVEN	:= M->ZC_NOMVEN

			For nLinha := 1 to Len( aCols )
				If  !GDDeleted(nLinha)
					If	nYY == 1
						SZC->ZC_SEQ		:= aCols[ nLinha , 1 ]
						SZC->ZC_DEPTOOR	:= aCols[ nLinha , 2 ]
						SZC->ZC_DTENT	:= aCols[ nLinha , 3 ]
						SZC->ZC_TIPFAB	:= aCols[ nLinha , 4 ]
						SZC->ZC_FORNEC	:= aCols[ nLinha , 5 ]
						SZC->ZC_LOJAFOR	:= aCols[ nLinha , 6 ]
						SZC->ZC_NOMFOR	:= aCols[ nLinha , 7 ]
						SZC->ZC_DTSAI	:= aCols[ nLinha , 8 ]
						SZC->ZC_DEPTODE	:= aCols[ nLinha , 9 ]
						SZC->ZC_OBS		:= aCols[ nLinha , 10 ]
						SZC->( MsUnLock() )
						lGeraDestino	:= !Empty( aCols[ nLinha , 9 ] )
					Else
						SZC->ZC_SEQ		:= StrZero( Val( aCols[ nLinha , 1 ] ) + 1 , 3 )
						SZC->ZC_DEPTOOR	:= aCols[ nLinha , 9 ]
						SZC->ZC_DTENT	:= aCols[ nLinha , 8 ]
						SZC->( MsUnLock() )
					EndIf
				EndIf
			Next nLinha

			SZC->( MsUnLock() )

		Next nYY

	End Transaction

Else

	SZD->( DbSetOrder( 1 ) )
	If	SZD->( DbSeek( xFilial( "SZD" ) + M->ZC_OP ) )
		RecLock( "SZD" )
		SZD->( DbDelete() )
		SZD->( MsUnLock() )
	EndIf

	SZE->( DbSetOrder( 1 ) )
	SZE->( DbSeek( xFilial( "SZE" ) + M->ZC_OP ) )
	While !SZE->( Eof() ) .and. SZE->ZE_FILIAL	== xFilial( "SZE" ) .and. SZE->ZE_OP == M->ZC_OP
		RecLock( "SZE" )
		SZE->( DbDelete() )
		SZE->( MsUnLock() )
		SZE->( DbSkip() )
	EndDo

EndIf

dbSelectArea( "SZC" )

Return nOpcA

********************************************************************************************************************
User Function FOMAN(cAlias,nReg,nOpcx)
Local	bCampo, oDlg, oGet,oReq,oComp
Local	lGravaOK	:= .T.
Local	nAcols		:= 0
Local	nCntFor		:= 0
Local	aSizeAut	:= MsAdvSize(,.F.)   
Local	aObjects	:= {}
Local	aInfo 		:= {}
Local	aPosObj		:= {}

Private	nOpca		:= 0
Private	aCols		:= {}
Private	aTipoOP		:= {}
Private	cZC_TIPOOP	:= SZC->ZC_TIPOOP
Private	cZC_OP		:= SZC->ZC_OP
Private	cZC_SEQ		:= Criavar( "ZC_SEQ" )
Private	dZC_DTUS	:= Criavar( "ZC_DTSAI" )
Private	cZC_DEPTODE	:= CriaVar( "ZC_DEPTODE" )

dbSelectArea("SZC")
dbSetOrder(1)
SZC->( DbSeek( xFilial( "SZC" ) + cZC_OP ) )
M->ZC_TIPOOP	:= SZC->ZC_TIPOOP
M->ZC_OP		:= SZC->ZC_OP
M->ZC_CODLMT	:= SZC->ZC_CODLMT
M->ZC_DENOM		:= SZC->ZC_DENOM
M->ZC_PRODUTO	:= SZC->ZC_PRODUTO
M->ZC_CLIENTE	:= SZC->ZC_CLIENTE
M->ZC_LOJACLI	:= SZC->ZC_LOJACLI
M->ZC_NOMCLI	:= SZC->ZC_NOMCLI
M->ZC_VEND		:= SZC->ZC_VEND
M->ZC_NOMVEN	:= SZC->ZC_NOMVEN

aTipoOp			:= IF( M->ZC_TIPOOP == "P" , { "P-Pedido" } , { "E-Estoque" } )

While !SZC->( Eof() ) .and. SZC->ZC_FILIAL	== xFilial( "SZC" ) .and. ;
							SZC->ZC_OP		== cZC_OP
	If	SZC->ZC_SEQ == "001" .and. Empty( SZC->ZC_DEPTODE )
		cZC_SEQ		:= "000"
//		dZC_DTUS	:= SZC->ZC_DTENT
		dZC_DTUS	:= CtoD( "" )
		cZC_DEPTODE	:= "3"
	Else
		cZC_SEQ		:= SZC->ZC_SEQ
		dZC_DTUS	:= SZC->ZC_DTSAI
		cZC_DEPTODE	:= IF( !Empty( SZC->ZC_DEPTODE ), SZC->ZC_DEPTODE, cZC_DEPTODE )
	EndIf
	SZC->( DbSkip() )
EndDo

SZC->( DbGoTo( nReg ) )

If		( ( cZC_DEPTODE == '1' .or. Empty( cZC_DEPTODE ) ) .and. !RetCodUsr() $ GetMv( "MV_FP_VEN" ) )
		MsgBox( "O próximo departamento a fazer atualizações é VENDAS." + PULA_LINHA + PULA_LINHA +;
		"Usuário não pertence a este departamento." + PULA_LINHA + PULA_LINHA +;
		"Verifique parâmetro 'MV_FP_VEN'", "Sem permissão..." , "STOP" )
		Return
ElseIf	( cZC_DEPTODE == '2' .and. !RetCodUsr() $ GetMv( "MV_FP_ENG" ) )
		MsgBox( "O próximo departamento a fazer atualizações é ENGENHARIA." + PULA_LINHA + PULA_LINHA +;
		"Usuário não pertence a este departamento." + PULA_LINHA + PULA_LINHA +;
		"Verifique parâmetro 'MV_FP_ENG'", "Sem permissão..." , "STOP" )
		Return
ElseIf	( cZC_DEPTODE == '3' .and. !RetCodUsr() $ GetMv( "MV_FP_PCP" ) )
		MsgBox( "O próximo departamento a fazer atualizações é PCP." + PULA_LINHA + PULA_LINHA +;
		"Usuário sem permissão para atualização." + PULA_LINHA + PULA_LINHA +;
		"Verifique parâmetro 'MV_FP_PCP'", "Sem permissão..." , "STOP" )
		Return
ElseIf	( cZC_DEPTODE == '4' .and. !RetCodUsr() $ GetMv( "MV_FP_COM" ) )
		MsgBox( "O próximo departamento a fazer atualizações é COMPRAS." + PULA_LINHA + PULA_LINHA +;
		"Usuário sem permissão para atualização." + PULA_LINHA + PULA_LINHA +;
		"Verifique parâmetro 'MV_FP_COM'", "Sem permissão..." , "STOP" )
		Return
ElseIf	( cZC_DEPTODE == '5' .and. !RetCodUsr() $ GetMv( "MV_FP_ALM" ) )
		MsgBox( "O próximo departamento a fazer atualizações é ALMOXARIFADO." + PULA_LINHA + PULA_LINHA +;
		"Usuário sem permissão para atualização." + PULA_LINHA + PULA_LINHA +;
		"Verifique parâmetro 'MV_FP_ALM'", "Sem permissão..." , "STOP" )
		Return
ElseIf	( cZC_DEPTODE == '6' .and. !RetCodUsr() $ GetMv( "MV_FP_CQI" ) )
		MsgBox( "O próximo departamento a fazer atualizações é CQ ITEM." + PULA_LINHA + PULA_LINHA +;
		"Usuário sem permissão para atualização." + PULA_LINHA + PULA_LINHA +;
		"Verifique parâmetro 'MV_FP_CQI'", "Sem permissão..." , "STOP" )
		Return
ElseIf	( cZC_DEPTODE == '7' .and. !RetCodUsr() $ GetMv( "MV_FP_BF" ) )
		MsgBox( "O próximo departamento a fazer atualizações é BF." + PULA_LINHA + PULA_LINHA +;
		"Usuário sem permissão para atualização." + PULA_LINHA + PULA_LINHA +;
		"Verifique parâmetro 'MV_FP_BF'", "Sem permissão..." , "STOP" )
		Return
ElseIf	( cZC_DEPTODE == '8' .and. !RetCodUsr() $ GetMv( "MV_FP_CQB" ) )
		MsgBox( "O próximo departamento a fazer atualizações é CQ BF." + PULA_LINHA + PULA_LINHA +;
		"Usuário sem permissão para atualização." + PULA_LINHA + PULA_LINHA +;
		"Verifique parâmetro 'MV_FP_CQB'", "Sem permissão..." , "STOP" )
		Return
ElseIf	( cZC_DEPTODE == '9' .and. !RetCodUsr() $ GetMv( "MV_FP_AP" ) )
		MsgBox( "O próximo departamento a fazer atualizações é APONTAMENTO DE PRODUÇÃO." + PULA_LINHA + PULA_LINHA +;
		"Usuário sem permissão para atualização." + PULA_LINHA + PULA_LINHA +;
		"Verifique parâmetro 'MV_FP_AP'", "Sem permissão..." , "STOP" )
		Return
ElseIf	( cZC_DEPTODE == '0' .and. !RetCodUsr() $ GetMv( "MV_FP_EXP" ) )
		MsgBox( "O próximo departamento a fazer atualizações é ESTOQUE." + PULA_LINHA + PULA_LINHA +;
		"Usuário sem permissão para atualização." + PULA_LINHA + PULA_LINHA +;
		"Verifique parâmetro 'MV_FP_EXP'", "Sem permissão..." , "STOP" )
		Return
ElseIf	( cZC_DEPTODE == 'B' .and. !RetCodUsr() $ GetMv( "MV_FP_PCP" ) )
		MsgBox( "O próximo departamento a fazer atualizações é PCP." + PULA_LINHA + PULA_LINHA +;
		"Usuário sem permissão para atualização." + PULA_LINHA + PULA_LINHA +;
		"Verifique parâmetro 'MV_FP_PCP'", "Sem permissão..." , "STOP" )
		Return
EndIf

nSavReg  := RecNo()
Private aTELA[0][0],aGETS[0],aHeader[0],Continua,nUsado:=0
bCampo := {|nCPO| Field(nCPO)}

aCampos	:= {}
If		cZC_DEPTODE == '1' .or. Empty( cZC_DEPTODE )
	cVldLin	:= "U_FOLINHA('1')"
	aCampos	:= { "ZC_SEQ", "ZC_DEPTOOR", "ZC_DTENT", "ZC_DTSAI", "ZC_DEPTODE", "ZC_OBS" }
ElseIf	cZC_DEPTODE == '2'
	cVldLin	:= "U_FOLINHA('2')"
	aCampos	:= { "ZC_SEQ", "ZC_DEPTOOR", "ZC_DTENT", "ZC_STATUS", "ZC_DTAPR", "ZC_DTSAI", "ZC_DEPTODE", "ZC_OBS" }
ElseIf	cZC_DEPTODE == '3'
	cVldLin	:= "U_FOLINHA('3')"
	aCampos	:= { "ZC_SEQ", "ZC_DEPTOOR", "ZC_DTENT", "ZC_TIPFAB", "ZC_FORNEC", "ZC_LOJAFOR", "ZC_NOMFOR", "ZC_DTSAI", "ZC_DEPTODE", "ZC_OBS" }
ElseIf	cZC_DEPTODE == '4'
	cVldLin	:= "U_FOLINHA('4')"
	aCampos	:= { "ZC_SEQ", "ZC_DEPTOOR", "ZC_DTENT", "ZC_DTSAI", "ZC_DEPTODE", "ZC_OBS" }
ElseIf	cZC_DEPTODE == '5'
	cVldLin	:= "U_FOLINHA('5')"
	aCampos	:= { "ZC_SEQ", "ZC_DEPTOOR", "ZC_DTENT", "ZC_DTISM", "ZC_DTFSM", "ZC_DTENV", "ZC_DTRET", "ZC_DTSAI", "ZC_DEPTODE", "ZC_OBS" }
ElseIf	cZC_DEPTODE == '6'
	cVldLin	:= "U_FOLINHA('6')"
	aCampos	:= { "ZC_SEQ", "ZC_DEPTOOR", "ZC_DTENT", "ZC_APROV", "ZC_DTSAI", "ZC_DEPTODE", "ZC_OBS" }
 ElseIf	cZC_DEPTODE == '7'
	cVldLin	:= "U_FOLINHA('7')"
	aCampos	:= { "ZC_SEQ", "ZC_DEPTOOR", "ZC_DTENT", "ZC_TEMBF", "ZC_FORNEC", "ZC_LOJAFOR", "ZC_NOMFOR", "ZC_DTENV", "ZC_DTRET", "ZC_DTSAI", "ZC_DEPTODE", "ZC_OBS" }
ElseIf	cZC_DEPTODE == '8'
	cVldLin	:= "U_FOLINHA('8')"
	aCampos	:= { "ZC_SEQ", "ZC_DEPTOOR", "ZC_DTENT", "ZC_APROV", "ZC_DTSAI", "ZC_DEPTODE", "ZC_OBS" }
ElseIf	cZC_DEPTODE == '9'
	cVldLin	:= "U_FOLINHA('9')"
	aCampos	:= { "ZC_SEQ", "ZC_DEPTOOR", "ZC_DTENT", "ZC_DTSAI", "ZC_DEPTODE", "ZC_OBS" }
ElseIf	cZC_DEPTODE == '0'
	cVldLin	:= "U_FOLINHA('0')"
//	aCampos	:= { "ZC_SEQ", "ZC_DEPTOOR", "ZC_DTENT", "ZC_NOTA", "ZC_DTSAI", "ZC_DEPTODE", "ZC_OBS" }
	aCampos	:= { "ZC_SEQ", "ZC_DEPTOOR", "ZC_DTENT", "ZC_DEPTODE", "ZC_OBS" }
ElseIf	cZC_DEPTODE == 'B'
	cVldLin	:= "U_FOLINHA('B')"
	aCampos	:= { "ZC_SEQ", "ZC_DEPTOOR", "ZC_DTENT", "ZC_TIPFAB", "ZC_FORNEC", "ZC_LOJAFOR", "ZC_NOMFOR", "ZC_DTSAI", "ZC_DEPTODE", "ZC_OBS" }
Else
	MsgBox( "Final do processo.", "Fim...", "INFO" )
	Return
EndIf

DbSelectArea( "SX3" )
SX3->( DbSetOrder( 2 ) )
For nCA := 1 to Len( aCampos )
	If	SX3->( DbSeek( aCampos[ nCA ] ) ) .and. X3USO( SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
	EndIf
Next nCA

_nPosDel		:= Len(aHeader) + 1

Private aCOLS[1][nUsado+1]

aCols	:={}
dbSelectArea("SZC")
SZC->( DbSetOrder( 1 ) )
SZC->( DbGoTo( nReg ) )
While !SZC->( Eof() ) .and. SZC->ZC_FILIAL	== xFilial( "SZC" ) .and. ;
							SZC->ZC_OP		== cZC_OP
	If	SZC->ZC_DEPTOOR == cZC_DEPTODE
		AADD(aCols,Array(nUsado+1))
		For _ni:=1 to nUsado
			aCols[Len(aCols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
		Next 
		aCols[Len(aCols),nUsado+1]:=.F.
	EndIf
	SZC->( dbSkip() )
EndDo
If	Len( aCols ) = 0
	AADD(aCols,Array(nUsado+1))
	For _ni:=1 to nUsado
		If		( AllTrim(aHeader[_ni][2]) == "ZC_SEQ" )
			aCols[Len(aCols),_ni] := StrZero( Val( cZC_SEQ ) + 1 , 3 )
		ElseIf	( AllTrim(aHeader[_ni][2]) == "ZC_DEPTOOR" )
			aCols[Len(aCols),_ni] := cZC_DEPTODE
		ElseIf	AllTrim(aHeader[_ni][2]) == "ZC_DTENT"
			aCols[Len(aCols),_ni] := dZC_DTUS
//		ElseIf	AllTrim(aHeader[_ni][2]) == "ZC_OP"
//			SC6->( DbSetOrder( 1 ) )
//			SC6->( DbSeek( xFilial( "SC6" ) + cZC_TIPOOP + cZC_OP ) )
//			aCols[Len(aCols),_ni] := SC6->( C6_NUMOP + C6_ITEMOP )
//		ElseIf	AllTrim(aHeader[_ni][2]) == "ZC_NOTA"
//			SC6->( DbSetOrder( 1 ) )
//			SC6->( DbSeek( xFilial( "SC6" ) + cZC_TIPOOP + cZC_OP ) )
//			aCols[Len(aCols),_ni] := SC6->C6_NOTA
		Else
			aCols[Len(aCols),_ni] := CriaVar(AllTrim(aHeader[_ni][2]))
		EndIf
	Next 
	aCols[Len(aCols),nUsado+1]:=.F.
EndIf

Continua := .F.
nOpca := 0
AAdd( aObjects, { 0,    25, .T., .F. })
AAdd( aObjects, { 100, 100, .T., .T. })
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
aPosObj := MsObjSize( aInfo, aObjects )
DEFINE MSDIALOG oDlg TITLE OemToAnsi("Fluxo de OP´s") From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

@ 020,005 SAY OemToAnsi("Tipo OP") OF oDlg PIXEL
@ 020,045 MSCOMBOBOX  oTipoOP VAR M->ZC_TIPOOP ITEMS aTipoOP Valid Left( M->ZC_TIPOOP, 1 ) $ "PE" SIZE 40,44 When .F. OF oDlg PIXEL

@ 020,090 SAY OemToAnsi("O.P.") OF oDlg PIXEL
@ 020,105 MSGET M->ZC_OP Picture "@!" When .F. F3 "SC2" Valid EXISTCHAV( "SZC", M->ZC_OP ) .and. FO1() .and. ;
CheckSX3("ZC_OP") When VisualSX3("ZC_OP") OF oDlg PIXEL 

@ 035,005 SAY OemToAnsi("Cód.LMT") OF oDlg PIXEL
@ 035,045 MSGET M->ZC_CODLMT When .F. OF oDlg PIXEL

@ 050,005 SAY OemToAnsi("Denominação") OF oDlg PIXEL
@ 050,045 MSGET M->ZC_DENOM When .F. OF oDlg PIXEL

@ 065,005 SAY OemToAnsi("Produto") OF oDlg PIXEL
@ 065,045 MSGET M->ZC_PRODUTO When .F. OF oDlg PIXEL

@ 080,005 SAY OemToAnsi("Cliente") OF oDlg PIXEL
@ 080,045 MSGET M->ZC_CLIENTE When .F. OF oDlg PIXEL

@ 080,090 SAY OemToAnsi("Loja") OF oDlg PIXEL
@ 080,105 MSGET M->ZC_LOJACLI When .F. OF oDlg PIXEL

@ 080,135 MSGET M->ZC_NOMCLI When .F. OF oDlg PIXEL

@ 095,005 SAY OemToAnsi("Vendedor") OF oDlg PIXEL
@ 095,045 MSGET M->ZC_VEND When .F. OF oDlg PIXEL

@ 095,135 MSGET M->ZC_NOMVEN When .F. OF oDlg PIXEL

oGet := MSGetDados():New(aPosObj[2,1]+70,aPosObj[2,2],aPosObj[2,3]+25,aPosObj[2,4],nOpcx,cVldLin,"AllwaysTrue","+ZC_SEQ",.T.,,2,,1)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()})

If nOpcA == 1
	Begin Transaction

		lTemItem	:= .F.
		For nLinha := 1 to Len( aCols )
//			If !aCols[nLinha,_nPosDel]
			If  !GDDeleted(nLinha)
				lTemItem	:= .T.
				Exit
			EndIf
		Next nLinha

		If	!lTemItem
			Return
		EndIf

		DbSelectArea( "SZC" )
		SZC->( DbSetOrder( 1 ) )

		lGeraDestino	:= .F.

		For nYY := 1 to 2
			cSeq	:= IF( nYY == 1 , aCols[1,1] , StrZero( Val(aCols[1,1])+1 , 3 ) )

			If	nYY == 2 .and. !lGeraDestino
				Exit
			EndIf

			If	!SZC->( DbSeek( xFilial( "SZC" ) + cZC_OP + cSeq ) )
				RecLock( "SZC", .T. )
				SZC->ZC_FILIAL	:= xFilial( "SZC" )
				SZC->ZC_TIPOOP	:= M->ZC_TIPOOP
				SZC->ZC_OP		:= M->ZC_OP
				SZC->ZC_CODLMT	:= M->ZC_CODLMT
				SZC->ZC_DENOM	:= M->ZC_DENOM
				SZC->ZC_PRODUTO	:= M->ZC_PRODUTO
				SZC->ZC_CLIENTE	:= M->ZC_CLIENTE
				SZC->ZC_LOJACLI	:= M->ZC_LOJACLI
				SZC->ZC_NOMCLI	:= M->ZC_NOMCLI
				SZC->ZC_VEND	:= M->ZC_VEND
				SZC->ZC_NOMVEN	:= M->ZC_NOMVEN
			Else
				RecLock( "SZC" )
			EndIf

			For nLinha := 1 to Len( aCols )
				If  !GDDeleted(nLinha)
					If	nYY == 1
						xZC_DEPTOOR		:= Space( Len( SZC->ZC_DEPTOOR ) )
						xZC_DTENT		:= Ctod( "" )
						If		cZC_DEPTODE == '1'
							SZC->ZC_SEQ		:= aCols[ nLinha , 1 ]
							SZC->ZC_DEPTOOR	:= aCols[ nLinha , 2 ]
							SZC->ZC_DTENT	:= aCols[ nLinha , 3 ]
							SZC->ZC_DTSAI	:= aCols[ nLinha , 4 ]
							SZC->ZC_DEPTODE	:= aCols[ nLinha , 5 ]
							SZC->ZC_OBS		:= aCols[ nLinha , 6 ]
							xZC_DEPTOOR		:= aCols[ nLinha , 5 ]
							xZC_DTENT		:= aCols[ nLinha , 4 ]
						ElseIf	cZC_DEPTODE == '2'
							SZC->ZC_SEQ		:= aCols[ nLinha , 1 ]
							SZC->ZC_DEPTOOR	:= aCols[ nLinha , 2 ]
							SZC->ZC_DTENT	:= aCols[ nLinha , 3 ]
							SZC->ZC_STATUS	:= aCols[ nLinha , 4 ]
							SZC->ZC_DTAPR	:= aCols[ nLinha , 5 ]
							SZC->ZC_DTSAI	:= aCols[ nLinha , 6 ]
							SZC->ZC_DEPTODE	:= aCols[ nLinha , 7 ]
							SZC->ZC_OBS		:= aCols[ nLinha , 8 ]
							xZC_DEPTOOR		:= aCols[ nLinha , 7 ]
							xZC_DTENT		:= aCols[ nLinha , 6 ]
						ElseIf	cZC_DEPTODE == '3'
							SZC->ZC_SEQ		:= aCols[ nLinha , 1 ]
							SZC->ZC_DEPTOOR	:= aCols[ nLinha , 2 ]
							SZC->ZC_DTENT	:= aCols[ nLinha , 3 ]
							SZC->ZC_TIPFAB	:= aCols[ nLinha , 4 ]
							SZC->ZC_FORNEC	:= aCols[ nLinha , 5 ]
							SZC->ZC_LOJAFOR	:= aCols[ nLinha , 6 ]
							SZC->ZC_NOMFOR	:= aCols[ nLinha , 7 ]
							SZC->ZC_DTSAI	:= aCols[ nLinha , 8 ]
							SZC->ZC_DEPTODE	:= aCols[ nLinha , 9 ]
							SZC->ZC_OBS		:= aCols[ nLinha , 10 ]
							xZC_DEPTOOR		:= aCols[ nLinha , 9 ]
							xZC_DTENT		:= aCols[ nLinha , 8 ]
						ElseIf	cZC_DEPTODE == '4'
							SZC->ZC_SEQ		:= aCols[ nLinha , 1 ]
							SZC->ZC_DEPTOOR	:= aCols[ nLinha , 2 ]
							SZC->ZC_DTENT	:= aCols[ nLinha , 3 ]
							SZC->ZC_DTSAI	:= aCols[ nLinha , 4 ]
							SZC->ZC_DEPTODE	:= aCols[ nLinha , 5 ]
							SZC->ZC_OBS		:= aCols[ nLinha , 6 ]
							xZC_DEPTOOR		:= aCols[ nLinha , 5 ]
							xZC_DTENT		:= aCols[ nLinha , 4 ]
						ElseIf	cZC_DEPTODE == '5'
							SZC->ZC_SEQ		:= aCols[ nLinha , 1 ]
							SZC->ZC_DEPTOOR	:= aCols[ nLinha , 2 ]
							SZC->ZC_DTENT	:= aCols[ nLinha , 3 ]
							SZC->ZC_DTISM	:= aCols[ nLinha , 4 ]
							SZC->ZC_DTFSM	:= aCols[ nLinha , 5 ]
							SZC->ZC_DTENV	:= aCols[ nLinha , 6 ]
							SZC->ZC_DTRET	:= aCols[ nLinha , 7 ]
							SZC->ZC_DTSAI	:= aCols[ nLinha , 8 ]
							SZC->ZC_DEPTODE	:= aCols[ nLinha , 9 ]
							SZC->ZC_OBS		:= aCols[ nLinha , 10 ]
							xZC_DEPTOOR		:= aCols[ nLinha , 9 ]
							xZC_DTENT		:= aCols[ nLinha , 8 ]
						ElseIf	cZC_DEPTODE == '6'
							SZC->ZC_SEQ		:= aCols[ nLinha , 1 ]
							SZC->ZC_DEPTOOR	:= aCols[ nLinha , 2 ]
							SZC->ZC_DTENT	:= aCols[ nLinha , 3 ]
							SZC->ZC_APROV	:= aCols[ nLinha , 4 ]
							SZC->ZC_DTSAI	:= aCols[ nLinha , 5 ]
							SZC->ZC_DEPTODE	:= aCols[ nLinha , 6 ]
							SZC->ZC_OBS		:= aCols[ nLinha , 7 ]
							xZC_DEPTOOR		:= aCols[ nLinha , 6 ]
							xZC_DTENT		:= aCols[ nLinha , 5 ]
						ElseIf	cZC_DEPTODE == '7'
							SZC->ZC_SEQ		:= aCols[ nLinha , 1 ]
							SZC->ZC_DEPTOOR	:= aCols[ nLinha , 2 ]
							SZC->ZC_DTENT	:= aCols[ nLinha , 3 ]
							SZC->ZC_TEMBF	:= aCols[ nLinha , 4 ]
							SZC->ZC_FORNEC	:= aCols[ nLinha , 5 ]
							SZC->ZC_LOJAFOR	:= aCols[ nLinha , 6 ]
							SZC->ZC_NOMFOR	:= aCols[ nLinha , 7 ]
							SZC->ZC_DTENV	:= aCols[ nLinha , 8 ]
							SZC->ZC_DTRET	:= aCols[ nLinha , 9 ]
							SZC->ZC_DTSAI	:= aCols[ nLinha , 10 ]
							SZC->ZC_DEPTODE	:= aCols[ nLinha , 11 ]
							SZC->ZC_OBS		:= aCols[ nLinha , 12 ]
							xZC_DEPTOOR		:= aCols[ nLinha , 11 ]
							xZC_DTENT		:= aCols[ nLinha , 10 ]
						ElseIf	cZC_DEPTODE == '8'
							SZC->ZC_SEQ		:= aCols[ nLinha , 1 ]
							SZC->ZC_DEPTOOR	:= aCols[ nLinha , 2 ]
							SZC->ZC_DTENT	:= aCols[ nLinha , 3 ]
							SZC->ZC_APROV	:= aCols[ nLinha , 4 ]
							SZC->ZC_DTSAI	:= aCols[ nLinha , 5 ]
							SZC->ZC_DEPTODE	:= aCols[ nLinha , 6 ]
							SZC->ZC_OBS		:= aCols[ nLinha , 7 ]
							xZC_DEPTOOR		:= aCols[ nLinha , 6 ]
							xZC_DTENT		:= aCols[ nLinha , 5 ]
						ElseIf	cZC_DEPTODE == '9'
							SZC->ZC_SEQ		:= aCols[ nLinha , 1 ]
							SZC->ZC_DEPTOOR	:= aCols[ nLinha , 2 ]
							SZC->ZC_DTENT	:= aCols[ nLinha , 3 ]
							SZC->ZC_DTSAI	:= aCols[ nLinha , 4 ]
							SZC->ZC_DEPTODE	:= aCols[ nLinha , 5 ]
							SZC->ZC_OBS		:= aCols[ nLinha , 6 ]
							xZC_DEPTOOR		:= aCols[ nLinha , 5 ]
							xZC_DTENT		:= aCols[ nLinha , 4 ]
						ElseIf	cZC_DEPTODE == 'B'
							SZC->ZC_SEQ		:= aCols[ nLinha , 1 ]
							SZC->ZC_DEPTOOR	:= aCols[ nLinha , 2 ]
							SZC->ZC_DTENT	:= aCols[ nLinha , 3 ]
							SZC->ZC_TIPFAB	:= aCols[ nLinha , 4 ]
							SZC->ZC_FORNEC	:= aCols[ nLinha , 5 ]
							SZC->ZC_LOJAFOR	:= aCols[ nLinha , 6 ]
							SZC->ZC_NOMFOR	:= aCols[ nLinha , 7 ]
							SZC->ZC_DTSAI	:= aCols[ nLinha , 8 ]
							SZC->ZC_DEPTODE	:= aCols[ nLinha , 9 ]
							SZC->ZC_OBS		:= aCols[ nLinha , 10 ]
							xZC_DEPTOOR		:= aCols[ nLinha , 9 ]
							xZC_DTENT		:= aCols[ nLinha , 8 ]
						ElseIf	cZC_DEPTODE == '0'
							SZC->ZC_SEQ		:= aCols[ nLinha , 1 ]
							SZC->ZC_DEPTOOR	:= aCols[ nLinha , 2 ]
							SZC->ZC_DTENT	:= aCols[ nLinha , 3 ]
//							SZC->ZC_NOTA	:= aCols[ nLinha , 4 ]
//							SZC->ZC_DTSAI	:= aCols[ nLinha , 5 ]
							SZC->ZC_DEPTODE	:= "Z"
//							SZC->ZC_OBS		:= aCols[ nLinha , 7 ]
							SZC->ZC_OBS		:= aCols[ nLinha , 5 ]
							Exit
						EndIf
						lGeraDestino	:= !Empty( xZC_DEPTOOR )
					Else	
						SZC->ZC_SEQ		:= StrZero( Val( aCols[ nLinha , 1 ] ) + 1 , 3 )
						SZC->ZC_DEPTOOR	:= xZC_DEPTOOR
						SZC->ZC_DTENT	:= xZC_DTENT
					EndIf
					SZC->( MsUnLock() )
				EndIf
			Next nLinha

			SZC->( MsUnLock() )

		Next nYY

	End Transaction

EndIf

dbSelectArea("SZC")
SZC->( DbGoTo( nReg ) )

Return nOpca

********************************************************************************************************************
User Function FOVIS(cAlias,nReg,nOpcx)
Local	bCampo, oDlg, oGet,oReq,oComp
Local	lGravaOK	:= .T.
Local	nAcols		:= 0
Local	nCntFor		:= 0
Local	aSizeAut	:= MsAdvSize(,.F.)   
Local	aObjects	:= {}
Local	aInfo 		:= {}
Local	aPosObj		:= {}

Private	nOpca		:= 0
Private	aCols		:= {}  
Private	aTipoOP		:= {}
Private	cZC_TIPOOP	:= SZC->ZC_TIPOOP
Private	cZC_OP		:= SZC->ZC_OP

dbSelectArea("SZC")
dbSetOrder(1)
SZC->( DbSeek( xFilial( "SZC" ) + cZC_OP ) )

M->ZC_TIPOOP	:= SZC->ZC_TIPOOP
M->ZC_OP		:= SZC->ZC_OP
M->ZC_CODLMT	:= SZC->ZC_CODLMT
M->ZC_DENOM		:= SZC->ZC_DENOM
M->ZC_PRODUTO	:= SZC->ZC_PRODUTO
M->ZC_CLIENTE	:= SZC->ZC_CLIENTE
M->ZC_LOJACLI	:= SZC->ZC_LOJACLI
M->ZC_NOMCLI	:= SZC->ZC_NOMCLI
M->ZC_VEND		:= SZC->ZC_VEND
M->ZC_NOMVEN	:= SZC->ZC_NOMVEN

aTipoOp			:= IF( M->ZC_TIPOOP == "P" , { "P-Pedido" } , { "E-Estoque" } )

nSavReg  := RecNo()
Private aTELA[0][0],aGETS[0],aHeader[0],Continua,nUsado:=0
bCampo := {|nCPO| Field(nCPO)}

dbSelectArea("SX3")
dbSeek( "SZC" )
While !EOF() .And. (SX3x3_arquivo == "SZC" )
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ;
		!AllTrim(x3_campo) $ "ZC_TIPOOP/ZC_OP/ZC_CODLMT/ZC_DENOM/ZC_PRODUTO/ZC_CLIENTE/ZC_LOJACLI/ZC_NOMCLI/ZC_VEND/ZC_NOMVEN"
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
	Endif
	dbSkip()
End
dbSelectArea("SZC")
While !SZC->( Eof() ) .And. SZC->ZC_FILIAL	== xFilial( "SZC" ) .and. ;
							SZC->ZC_OP		== cZC_OP
	aadd(aCols,Array(nUsado+1))
	nAcols ++
	For nCntFor := 1 To nUsado
		If ( aHeader[nCntFor][10] != "V")
			aCols[nAcols][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
		EndIf
	Next nCntFor
	aCols[nAcols][nUsado+1] := .F.
	dbSkip()
EndDo

Continua := .F.
nOpca := 0
AAdd( aObjects, { 0,    25, .T., .F. })
AAdd( aObjects, { 100, 100, .T., .T. })
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
aPosObj := MsObjSize( aInfo, aObjects )
DEFINE MSDIALOG oDlg TITLE OemToAnsi("Fluxo de OP´s") From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

@ 020,005 SAY OemToAnsi("Tipo OP") OF oDlg PIXEL
@ 020,045 MSCOMBOBOX  oTipoOP VAR M->ZC_TIPOOP ITEMS aTipoOP Valid Left( M->ZC_TIPOOP, 1 ) $ "PE" SIZE 40,44 When .F. OF oDlg PIXEL

@ 020,090 SAY OemToAnsi("O.P.") OF oDlg PIXEL
@ 020,105 MSGET M->ZC_OP Picture "@!" When .F. F3 "SC2" Valid EXISTCHAV( "SZC", M->ZC_OP ) .and. FO1() .and. ;
CheckSX3("ZC_OP") When VisualSX3("ZC_OP") OF oDlg PIXEL 

@ 035,005 SAY OemToAnsi("Cód.LMT") OF oDlg PIXEL
@ 035,045 MSGET M->ZC_CODLMT When .F. OF oDlg PIXEL

@ 050,005 SAY OemToAnsi("Denominação") OF oDlg PIXEL
@ 050,045 MSGET M->ZC_DENOM When .F. OF oDlg PIXEL

@ 065,005 SAY OemToAnsi("Produto") OF oDlg PIXEL
@ 065,045 MSGET M->ZC_PRODUTO When .F. OF oDlg PIXEL

@ 080,005 SAY OemToAnsi("Cliente") OF oDlg PIXEL
@ 080,045 MSGET M->ZC_CLIENTE When .F. OF oDlg PIXEL

@ 080,090 SAY OemToAnsi("Loja") OF oDlg PIXEL
@ 080,105 MSGET M->ZC_LOJACLI When .F. OF oDlg PIXEL

@ 080,135 MSGET M->ZC_NOMCLI When .F. OF oDlg PIXEL

@ 095,005 SAY OemToAnsi("Vendedor") OF oDlg PIXEL
@ 095,045 MSGET M->ZC_VEND When .F. OF oDlg PIXEL

@ 095,135 MSGET M->ZC_NOMVEN When .F. OF oDlg PIXEL

oGet := MSGetDados():New(aPosObj[2,1]+70,aPosObj[2,2],aPosObj[2,3]+25,aPosObj[2,4],nOpcx,"AllwaysTrue","AllwaysTrue","+ZC_SEQ",.T.,,2,,1)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()})

dbSelectArea("SZC")
SZC->( DbGoTo( nReg ) )

Return nOpca

********************************************************************************************************************
User Function FOEXCP(cAlias,nReg,nOpcx)
Local	bCampo, oDlg, oGet,oReq,oComp
Local	lGravaOK	:= .T.
Local	nAcols		:= 0
Local	nCntFor		:= 0
Local	aSizeAut	:= MsAdvSize(,.F.)
Local	aObjects	:= {}
Local	aInfo 		:= {}
Local	aPosObj		:= {}

Private	aTipoOP		:= {}

If		!RetCodUsr() $ GetMv( "MV_FP_VEN" ) .and. !RetCodUsr() $ GetMv( "MV_FP_ENG" )
		MsgBox( "Usuário sem acesso para exclusão." + PULA_LINHA + PULA_LINHA +;
		"Somente usuários dos departamentos de 'vendas' e 'engenharia' tem este acesso" + PULA_LINHA + PULA_LINHA +;
		"Verifique os parâmetros 'MV_FP_VEN' e 'MV_FP_ENG'", "Sem permissão..." , "STOP" )
		Return
EndIf

Private	nOpca		:= 0
Private	aCols		:= {}  
Private	cZC_TIPOOP	:= SZC->ZC_TIPOOP
Private	cZC_OP		:= SZC->ZC_OP

dbSelectArea("SZC")
dbSetOrder(1)
SZC->( DbSeek( xFilial( "SZC" ) + cZC_OP ) )

M->ZC_TIPOOP	:= SZC->ZC_TIPOOP
M->ZC_OP		:= SZC->ZC_OP
M->ZC_CODLMT	:= SZC->ZC_CODLMT
M->ZC_DENOM		:= SZC->ZC_DENOM
M->ZC_PRODUTO	:= SZC->ZC_PRODUTO
M->ZC_CLIENTE	:= SZC->ZC_CLIENTE
M->ZC_LOJACLI	:= SZC->ZC_LOJACLI
M->ZC_NOMCLI	:= SZC->ZC_NOMCLI
M->ZC_VEND		:= SZC->ZC_VEND
M->ZC_NOMVEN	:= SZC->ZC_NOMVEN

aTipoOp			:= IF( M->ZC_TIPOOP == "P" , { "P-Pedido" } , { "E-Estoque" } )

nSavReg  := RecNo()
Private aTELA[0][0],aGETS[0],aHeader[0],Continua,nUsado:=0
bCampo := {|nCPO| Field(nCPO)}

dbSelectArea("SX3")
dbSeek( "SZC" )
While !EOF() .And. (SX3->x3_arquivo == "SZC" )
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ;
		!AllTrim(x3_campo) $ "ZC_TIPOOP/ZC_OP/ZC_CODLMT/ZC_DENOM/ZC_PRODUTO/ZC_CLIENTE/ZC_LOJACLI/ZC_NOMCLI/ZC_VEND/ZC_NOMVEN"
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
	Endif
	dbSkip()
End
dbSelectArea("SZC")
While !SZC->( Eof() ) .And. SZC->ZC_FILIAL	== xFilial( "SZC" ) .and. ;
							SZC->ZC_OP		== cZC_OP
	aadd(aCols,Array(nUsado+1))
	nAcols ++
	For nCntFor := 1 To nUsado
		If ( aHeader[nCntFor][10] != "V")
			aCols[nAcols][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
		EndIf
	Next nCntFor
	aCols[nAcols][nUsado+1] := .F.
	dbSkip()
EndDo

Continua := .F.
nOpca := 0
AAdd( aObjects, { 0,    25, .T., .F. })
AAdd( aObjects, { 100, 100, .T., .T. })
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
aPosObj := MsObjSize( aInfo, aObjects )
DEFINE MSDIALOG oDlg TITLE OemToAnsi("Fluxo de OP´s") From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

@ 020,005 SAY OemToAnsi("Tipo OP") OF oDlg PIXEL
@ 020,045 MSCOMBOBOX  oTipoOP VAR M->ZC_TIPOOP ITEMS aTipoOP Valid Left( M->ZC_TIPOOP, 1 ) $ "PE" SIZE 40,44 When .F. OF oDlg PIXEL

@ 020,090 SAY OemToAnsi("O.P.") OF oDlg PIXEL
@ 020,105 MSGET M->ZC_OP Picture "@!" When .F. F3 "SC2" Valid EXISTCHAV( "SZC", M->ZC_OP ) .and. FO1() .and. ;
CheckSX3("ZC_OP") When VisualSX3("ZC_OP") OF oDlg PIXEL 

@ 035,005 SAY OemToAnsi("Cód.LMT") OF oDlg PIXEL
@ 035,045 MSGET M->ZC_CODLMT When .F. OF oDlg PIXEL

@ 050,005 SAY OemToAnsi("Denominação") OF oDlg PIXEL
@ 050,045 MSGET M->ZC_DENOM When .F. OF oDlg PIXEL

@ 065,005 SAY OemToAnsi("Produto") OF oDlg PIXEL
@ 065,045 MSGET M->ZC_PRODUTO When .F. OF oDlg PIXEL

@ 080,005 SAY OemToAnsi("Cliente") OF oDlg PIXEL
@ 080,045 MSGET M->ZC_CLIENTE When .F. OF oDlg PIXEL

@ 080,090 SAY OemToAnsi("Loja") OF oDlg PIXEL
@ 080,105 MSGET M->ZC_LOJACLI When .F. OF oDlg PIXEL

@ 080,135 MSGET M->ZC_NOMCLI When .F. OF oDlg PIXEL

@ 095,005 SAY OemToAnsi("Vendedor") OF oDlg PIXEL
@ 095,045 MSGET M->ZC_VEND When .F. OF oDlg PIXEL

@ 095,135 MSGET M->ZC_NOMVEN When .F. OF oDlg PIXEL

oGet := MSGetDados():New(aPosObj[2,1]+70,aPosObj[2,2],aPosObj[2,3]+25,aPosObj[2,4],nOpcx,"AllwaysTrue","AllwaysTrue","+ZC_SEQ",.T.,,2,,1)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()})

If nOpcA == 1

	If	!MsgYesNo( "Confirmando a exclusão, todos processos serão excluídos. Confirma?", "ATENÇÃO..." )
		SZC->( DbGoTo( nReg ) )
		Return
	EndIf

	Begin Transaction

		DbSelectArea( "SZC" )
		SZC->( DbSetOrder( 1 ) )
		SZC->( DbSeek( xFilial( "SZC" ) + cZC_OP ) )
		While !SZC->( Eof() ) .and.	SZC->ZC_FILIAL	== xFilial( "SZC" ) .and. ;
									SZC->ZC_OP		== cZC_OP

			RecLock( "SZC", .F. )
			SZC->( DbDelete() )
			SZC->( MsUnLock() )

			SZC->( DbSkip() )
		EndDo

		SZD->( DbSetOrder( 1 ) )
		If	SZD->( DbSeek( xFilial( "SZD" ) + cZC_OP ) )
			RecLock( "SZD" )
			SZD->( DbDelete() )
			SZD->( MsUnLock() )
		EndIf

		SZE->( DbSetOrder( 1 ) )
		SZE->( DbSeek( xFilial( "SZE" ) + cZC_OP ) )
		While !SZE->( Eof() ) .and. SZE->ZE_FILIAL	== xFilial( "SZE" ) .and. SZE->ZE_OP == cZC_OP
			RecLock( "SZE" )
			SZE->( DbDelete() )
			SZE->( MsUnLock() )
			SZE->( DbSkip() )
		EndDo

	End Transaction

EndIf

dbSelectArea("SZC")

Return nOpca

********************************************************************************************************************
User Function FOEXCU(cAlias,nReg,nOpcx)
Local	bCampo, oDlg, oGet,oReq,oComp
Local	lGravaOK	:= .T.
Local	nAcols		:= 0
Local	nCntFor		:= 0
Local	aSizeAut	:= MsAdvSize(,.F.)
Local	aObjects	:= {}
Local	aInfo 		:= {}
Local	aPosObj		:= {}

Private	aTipoOP		:= {}

If		!RetCodUsr() $ GetMv( "MV_FP_VEN" ) .and. !RetCodUsr() $ GetMv( "MV_FP_ENG" )
		MsgBox( "Usuário sem acesso para exclusão." + PULA_LINHA + PULA_LINHA +;
		"Somente usuários dos departamentos de 'vendas' e 'engenharia' tem este acesso" + PULA_LINHA + PULA_LINHA +;
		"Verifique os parâmetros 'MV_FP_VEN' e 'MV_FP_ENG'", "Sem permissão..." , "STOP" )
		Return
EndIf

Private	nOpca		:= 0
Private	aCols		:= {}  
Private	cZC_TIPOOP	:= SZC->ZC_TIPOOP
Private	cZC_OP		:= SZC->ZC_OP

dbSelectArea("SZC")
dbSetOrder(1)
SZC->( DbSeek( xFilial( "SZC" ) + cZC_OP ) )

M->ZC_TIPOOP	:= SZC->ZC_TIPOOP
M->ZC_OP		:= SZC->ZC_OP
M->ZC_CODLMT	:= SZC->ZC_CODLMT
M->ZC_DENOM		:= SZC->ZC_DENOM
M->ZC_PRODUTO	:= SZC->ZC_PRODUTO
M->ZC_CLIENTE	:= SZC->ZC_CLIENTE
M->ZC_LOJACLI	:= SZC->ZC_LOJACLI
M->ZC_NOMCLI	:= SZC->ZC_NOMCLI
M->ZC_VEND		:= SZC->ZC_VEND
M->ZC_NOMVEN	:= SZC->ZC_NOMVEN

aTipoOp			:= IF( M->ZC_TIPOOP == "P" , { "P-Pedido" } , { "E-Estoque" } )

nSavReg  := RecNo()
Private aTELA[0][0],aGETS[0],aHeader[0],Continua,nUsado:=0
bCampo := {|nCPO| Field(nCPO)}

dbSelectArea("SX3")
dbSeek( "SZC" )
While !EOF() .And. (SX3->x3_arquivo == "SZC" )
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ;
		!AllTrim(x3_campo) $ "ZC_TIPOOP/ZC_OP/ZC_CODLMT/ZC_DENOM/ZC_PRODUTO/ZC_CLIENTE/ZC_LOJACLI/ZC_NOMCLI/ZC_VEND/ZC_NOMVEN"
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
	Endif
	dbSkip()
End
nUltRec	:= 0
dbSelectArea("SZC")
While !SZC->( Eof() ) .And. SZC->ZC_FILIAL	== xFilial( "SZC" ) .and. ;
							SZC->ZC_OP		== cZC_OP
	nUltRec	:= SZC->( Recno() )
	SZC->( DbSkip() )
EndDo
dbSelectArea("SZC")
SZC->( DbGoTo( nUltRec ) )
While !SZC->( Eof() ) .And. SZC->ZC_FILIAL	== xFilial( "SZC" ) .and. ;
							SZC->ZC_OP		== cZC_OP
	aadd(aCols,Array(nUsado+1))
	nAcols ++
	For nCntFor := 1 To nUsado
		If ( aHeader[nCntFor][10] != "V")
			aCols[nAcols][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
		EndIf
	Next nCntFor
	aCols[nAcols][nUsado+1] := .F.
	dbSkip()
EndDo

Continua := .F.
nOpca := 0
AAdd( aObjects, { 0,    25, .T., .F. })
AAdd( aObjects, { 100, 100, .T., .T. })
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
aPosObj := MsObjSize( aInfo, aObjects )
DEFINE MSDIALOG oDlg TITLE OemToAnsi("Fluxo de OP´s") From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

@ 020,005 SAY OemToAnsi("Tipo OP") OF oDlg PIXEL
@ 020,045 MSCOMBOBOX  oTipoOP VAR M->ZC_TIPOOP ITEMS aTipoOP Valid Left( M->ZC_TIPOOP, 1 ) $ "PE" SIZE 40,44 When .F. OF oDlg PIXEL

@ 020,090 SAY OemToAnsi("O.P.") OF oDlg PIXEL
@ 020,105 MSGET M->ZC_OP Picture "@!" When .F. F3 "SC2" Valid EXISTCHAV( "SZC", M->ZC_OP ) .and. FO1() .and. ;
CheckSX3("ZC_OP") When VisualSX3("ZC_OP") OF oDlg PIXEL 

@ 035,005 SAY OemToAnsi("Cód.LMT") OF oDlg PIXEL
@ 035,045 MSGET M->ZC_CODLMT When .F. OF oDlg PIXEL

@ 050,005 SAY OemToAnsi("Denominação") OF oDlg PIXEL
@ 050,045 MSGET M->ZC_DENOM When .F. OF oDlg PIXEL

@ 065,005 SAY OemToAnsi("Produto") OF oDlg PIXEL
@ 065,045 MSGET M->ZC_PRODUTO When .F. OF oDlg PIXEL

@ 080,005 SAY OemToAnsi("Cliente") OF oDlg PIXEL
@ 080,045 MSGET M->ZC_CLIENTE When .F. OF oDlg PIXEL

@ 080,090 SAY OemToAnsi("Loja") OF oDlg PIXEL
@ 080,105 MSGET M->ZC_LOJACLI When .F. OF oDlg PIXEL

@ 080,135 MSGET M->ZC_NOMCLI When .F. OF oDlg PIXEL

@ 095,005 SAY OemToAnsi("Vendedor") OF oDlg PIXEL
@ 095,045 MSGET M->ZC_VEND When .F. OF oDlg PIXEL

@ 095,135 MSGET M->ZC_NOMVEN When .F. OF oDlg PIXEL

oGet := MSGetDados():New(aPosObj[2,1]+70,aPosObj[2,2],aPosObj[2,3]+25,aPosObj[2,4],nOpcx,"AllwaysTrue","AllwaysTrue","+ZC_SEQ",.T.,,2,,1)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()})

If nOpcA == 1

	If	!MsgYesNo( "Apenas o último lançamento será excluído. Confirma?", "ATENÇÃO..." )
		SZC->( DbGoTo( nReg ) )
		Return
	EndIf

	Begin Transaction

		DbSelectArea( "SZC" )
		SZC->( DbSetOrder( 1 ) )
		SZC->( DbGoTo( nUltRec ) )
		While !SZC->( Eof() ) .and.	SZC->ZC_FILIAL	== xFilial( "SZC" ) .and. ;
									SZC->ZC_OP		== cZC_OP

			RecLock( "SZC", .F. )
			SZC->( DbDelete() )
			SZC->( MsUnLock() )

			SZC->( DbSkip() )
		EndDo

	End Transaction

EndIf

dbSelectArea("SZC")

Return nOpca

********************************************************************************************************************
User Function FOLINHA( cPasta )
Local 	lRetorno	:= .T.
Local 	cZC_SEQ		:= aCols[n][GdFieldPos("ZC_SEQ",aHeader)]
Local 	dZC_DTENT	:= aCols[n][GdFieldPos("ZC_DTENT",aHeader)]
Local 	dZC_DTSAI	:= IF( cPasta # "A" , aCols[n][GdFieldPos("ZC_DTSAI",aHeader)] , CtoD( "" ) )
Local 	cZC_DEPTOOR	:= aCols[n][GdFieldPos("ZC_DEPTOOR",aHeader)]
Local 	cZC_DEPTODE	:= aCols[n][GdFieldPos("ZC_DEPTODE",aHeader)]

If		RetCodUsr() $ GetMv( "MV_FP_PCP" ) .and. cPasta == "3" .and. Left( M->ZC_TIPOOP, 1 ) == "P"
	If	1=2 .and. dZC_DTENT # Posicione( "SC2", 1, xFilial( "SC2" ) + M->ZC_OP, "C2_EMISSAO" )
		MsgBox( "Data de entrada não pode ser diferente da emissão da OP que é " +;
		DtoC( Posicione( "SC2", 1, xFilial( "SC2" ) + M->ZC_OP, "C2_EMISSAO" ) ) , "Inconsistência...", "STOP" )
		aCols[n][GdFieldPos("ZC_DTENT",aHeader)]	:= Posicione( "SC2", 1, xFilial( "SC2" ) + M->ZC_OP, "C2_EMISSAO" )
		lRetorno	:= .F.
	EndIf
EndIf

If		!Empty( dZC_DTUS ) .and. dZC_DTENT < dZC_DTUS
	MsgBox( "Data de entrada não pode ser inferior a data da última saída que é " + DtoC( dZC_DTUS ), "Inconsistência...", "STOP" )
	aCols[n][GdFieldPos("ZC_DTENT",aHeader)]	:= dZC_DTUS
	lRetorno	:= .F.
ElseIf	dZC_DTENT > dZC_DTSAI .and. !Empty( dZC_DTSAI )
	MsgBox( "Data de entrada não pode ser superior a data de saída.", "Inconsistência...", "STOP" )
	lRetorno	:= .F.
ElseIf	dZC_DTSAI < dZC_DTENT .and. !Empty( dZC_DTSAI )
	MsgBox( "Data de saída não pode ser inferior a data de entrada.", "Inconsistência...", "STOP" )
	lRetorno	:= .F.
ElseIf	Empty( dZC_DTSAI ) .and. !Empty( cZC_DEPTODE ) .and. cPasta # "A"
	MsgBox( "Para informar departamento destino, obrigatório informar data de saída.", "Inconsistência...", "STOP" )
	lRetorno	:= .F.
ElseIf	Empty( cZC_DEPTODE ) .and. !Empty( dZC_DTSAI )
	MsgBox( "Obrigatório informar depto destino qdo informado data de saída.", "Inconsistência...", "STOP" )
	lRetorno	:= .F.
ElseIf	!Empty( cZC_DEPTODE ) .and. Empty( dZC_DTSAI ) .and. cPasta # "A"
	MsgBox( "Não é permitido informar depto destino senão informar data de saída.", "Inconsistência...", "STOP" )
	lRetorno	:= .F.
ElseIf	cZC_DEPTODE == cZC_DEPTOOR .and. cZC_SEQ <> "001"
	MsgBox( "Não é permitido informar depto destino igual ao depto que esta fazendo atualizações.", "Inconsistência...", "STOP" )
	lRetorno	:= .F.
EndIf

If	cPasta == '2'
	cZC_STATUS	:= aCols[n][GdFieldPos("ZC_STATUS",aHeader)]
	dZC_DTAPR	:= aCols[n][GdFieldPos("ZC_DTAPR",aHeader)]
	If		dZC_DTENT < dZC_DTUS
		MsgBox( "Data de entrada não pode ser inferior a data da última saída que é " + DtoC( dZC_DTUS ), "Inconsistência...", "STOP" )
		lRetorno	:= .F.
	EndIf

	If	!Empty( cZC_STATUS )
		If		cZC_STATUS == "P" .and. !Empty( dZC_DTAPR )
			MsgBox( "Só informar data de aprovação quando status for APROVADO.", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		ElseIf	cZC_STATUS == "A" .and. Empty( dZC_DTAPR )
			MsgBox( "Status APROVADO, obrigatório informar data de aprovação.", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf
	EndIf

	If	!Empty( dZC_DTAPR )
		If		Empty( cZC_STATUS )
			MsgBox( "Só informar data de aprovação quando status for APROVADO.", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		ElseIf	dZC_DTAPR < dZC_DTENT
			MsgBox( "Data de aprovação deve ser superior a data de entrada.", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf
	EndIf
	
	If	!Empty( dZC_DTSAI )
		If		dZC_DTSAI < dZC_DTAPR
			MsgBox( "Data de saída deve ser superior a data de aprovação.", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf
	EndIf		

EndIf

If	cPasta == "3"// .or. cPasta == "B"
	cZC_TIPFAB	:= aCols[n][GdFieldPos("ZC_TIPFAB",aHeader)]
	cZC_FORNEC	:= aCols[n][GdFieldPos("ZC_FORNEC",aHeader)]

//	If		dZC_DTENT < dZC_DTUS
//		MsgBox( "Data de entrada não pode ser inferior a data da última saída que é " + DtoC( dZC_DTUS ), "Inconsistência...", "STOP" )
//		lRetorno	:= .F.
//	EndIf

	If		Empty( cZC_TIPFAB ) .and. !Empty( cZC_FORNEC )
		MsgBox( "Só informar fornecedor se tipo de fabricação for EXTERNA.", "Inconsistência...", "STOP" )
		lRetorno	:= .F.
	EndIf
	
	If	!Empty( cZC_TIPFAB )
		If		cZC_TIPFAB == "E" .and. Empty( cZC_FORNEC )
			MsgBox( "Tipo de fabricação EXTERNA, obrigatório informar fornecedor.", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		ElseIf	cZC_TIPFAB == "I" .and. !Empty( cZC_FORNEC )
			MsgBox( "Tipo de fabricação INTERNA, não pode informar fornecedor.", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf
	EndIf

//	If	Empty( cZC_OP ) .and. !Empty( cZC_DEPTODE )
//		MsgBox( "Direcionamento impossível. Não foi gerado OP para este ítem.", "Inconsistência...", "STOP" )
//		lRetorno	:= .F.
//	EndIf

EndIf

If	cPasta == "5"
	dZC_DTISM	:= aCols[n][GdFieldPos("ZC_DTISM",aHeader)]
	dZC_DTFSM	:= aCols[n][GdFieldPos("ZC_DTFSM",aHeader)]
	dZC_DTENV	:= aCols[n][GdFieldPos("ZC_DTENV",aHeader)]
	dZC_DTRET	:= aCols[n][GdFieldPos("ZC_DTRET",aHeader)]

	If		!Empty( dZC_DTISM )
		If	dZC_DTISM < dZC_DTENT .and. !Empty( dZC_DTENT )
			MsgBox( "Data de início da separação de materiais não pode ser inferior a data de entrada", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf
	EndIf

	If	!Empty( dZC_DTFSM )
		If	dZC_DTFSM < dZC_DTISM .and. !Empty( dZC_DTISM )
			MsgBox( "Data final da separação de materiais não pode ser inferior a data inicial da separação de materiais", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf
	EndIf

	If	!Empty( dZC_DTENV )
		If	dZC_DTENV < dZC_DTFSM .and. !Empty( dZC_DTFSM )
			MsgBox( "Data de envio não pode ser inferior a data final da separação de materiais.", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf
		If	dZC_DTENV < dZC_DTISM .and. !Empty( dZC_DTISM )
			MsgBox( "Data de envio não pode ser inferior a data inicial da separação de materiais.", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf
	EndIf
	
	If	!Empty( dZC_DTRET )
		If	dZC_DTRET < dZC_DTENV .and. !Empty( dZC_DTENV )
			MsgBox( "Data de retorno não pode ser inferior a data de envio.", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf
		If	dZC_DTRET < dZC_DTFSM .and. !Empty( dZC_DTFSM )
			MsgBox( "Data de retorno não pode ser inferior a data final da separação de materiais", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf
		If	dZC_DTRET < dZC_DTISM .and. !Empty( dZC_DTISM )
			MsgBox( "Data de retorno não pode ser inferior a data inicial da separação de materiais", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf
	EndIf
	
	If	!Empty( dZC_DTSAI )
		If	dZC_DTSAI < dZC_DTRET .and. !Empty( dZC_DTRET )
			MsgBox( "Data de saída não pode ser inferior a data do último retorno", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf
		If	dZC_DTSAI < dZC_DTENV .and. !Empty( dZC_DTENV )
			MsgBox( "Data de saída não pode ser inferior a data de envio", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf
		If	dZC_DTSAI < dZC_DTFSM .and. !Empty( dZC_DTFSM )
			MsgBox( "Data de saída não pode ser inferior a data final de separação de materiais", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf
		If	dZC_DTSAI < dZC_DTISM .and. !Empty( dZC_DTISM )
			MsgBox( "Data de saída não pode ser inferior a data inicial da separação de materiais", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf
	EndIf

EndIf

If	cPasta == "6" .or. cPasta == "8"
	cZC_APROV	:= aCols[n][GdFieldPos("ZC_APROV",aHeader)]

//	If	cZC_APROV # "S" .and. !Empty( dZC_DTSAI )
//		MsgBox( "Só pode informar data de saída se APROVADO = 'Sim'", "Inconsistência...", "STOP" )
//		lRetorno	:= .F.
//	EndIf

	If	cZC_APROV == "S" .and. Empty( dZC_DTSAI )
		MsgBox( "Obrigatório informar data de saída quando APROVADO = 'Sim'", "Inconsistência...", "STOP" )
		lRetorno	:= .F.
	EndIf

EndIf

If	cPasta == "7"
	cZC_TEMBF	:= aCols[n][GdFieldPos("ZC_TEMBF",aHeader)]
	cZC_FORNEC	:= aCols[n][GdFieldPos("ZC_FORNEC",aHeader)]
	dZC_DTENV	:= aCols[n][GdFieldPos("ZC_DTENV",aHeader)]
	dZC_DTRET	:= aCols[n][GdFieldPos("ZC_DTRET",aHeader)]

	If	cZC_TEMBF == "S"
		If	Empty( cZC_FORNEC )
			MsgBox( "Por ter sido informado que tem BF, obrigatório informar fornecedor.", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf
		If	Empty( dZC_DTENV )
			MsgBox( "Não informado data de envio", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf
		If	!Empty( dZC_DTENV )
			If	Empty( cZC_FORNEC )
				MsgBox( "Só pode informar data de envio se informado fornecedor", "Inconsistência...", "STOP" )
				lRetorno	:= .F.
			EndIf
			If	dZC_DTENV < dZC_DTENT
				MsgBox( "Data de envio não pode ser inferior a data de entrada", "Inconsistência...", "STOP" )
				lRetorno	:= .F.
			EndIf
		EndIf
		If	!Empty( dZC_DTRET )
			If	Empty( cZC_FORNEC )
				MsgBox( "Só pode informar data de retorno se informado fornecedor", "Inconsistência...", "STOP" )
				lRetorno	:= .F.
			EndIf
			If	dZC_DTRET < dZC_DTENV .and. !Empty( dZC_DTENV )
				MsgBox( "Data de retorno não pode ser inferior a data de envio", "Inconsistência...", "STOP" )
				lRetorno	:= .F.
			EndIf
			If	Empty( dZC_DTENV )
				MsgBox( "Não informado data de envio", "Inconsistência...", "STOP" )
				lRetorno	:= .F.
			EndIf
		EndIf
	Else
		If	!Empty( cZC_FORNEC )
			MsgBox( "Só pode informar fornecedor se possuir BF", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf

		If	!Empty( dZC_DTENV )
			MsgBox( "Só pode informar data de envio se possuir BF", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf

	EndIf

	If	!Empty( dZC_DTSAI )

		If	dZC_DTSAI < dZC_DTRET .and. !Empty( dZC_DTRET )
			MsgBox( "Data de saída não pode ser inferior a data de retorno", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf

		If	dZC_DTSAI < dZC_DTENV .and. !Empty( dZC_DTENV )
			MsgBox( "Data de saída não pode ser inferior a data de envio", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf

	EndIf

EndIf

If	cPasta == "9"
//	cZC_OP		:= aCols[n][GdFieldPos("ZC_OP",aHeader)]

	If	!Empty( dZC_DTSAI )

//		If	Empty( cZC_OP )
//			MsgBox( "Não foi aberto OP para este item.", "Inconsistência...", "STOP" )
//			aCols[n][GdFieldPos("ZC_DTSAI",aHeader)]	:= CriaVar( "ZC_DTSAI" )
//			aCols[n][GdFieldPos("ZC_DEPTODE",aHeader)]	:= CriaVar( "ZC_DEPTODE" )
//			lRetorno	:= .F.
//		EndIf

		lProducao	:= .F.
//		SD3->( DbSeek( xFilial( "SD3" ) + cZC_OP ) )
//		While !SD3->( Eof() ) .and. SD3->D3_FILIAL	== xFilial( "SD3" ) .and. ;
//									Left( SD3->D3_OP , Len( AllTrim( cZC_OP ) ) ) == cZC_OP
//			If	AllTrim( SD3->D3_CF ) == "PR0"
//				lProducao	:= .T.
//				Exit
//			EndIf
			
//			SD3->( DbSkip() )
//		EndDo
		
		If	!lProducao .and. 1=2
			MsgBox( "Não foi apontado produção para este ítem.", "Inconsistência...", "STOP" )
			aCols[n][GdFieldPos("ZC_DTSAI",aHeader)]	:= CriaVar( "ZC_DTSAI" )
			aCols[n][GdFieldPos("ZC_DEPTODE",aHeader)]	:= CriaVar( "ZC_DEPTODE" )
			lRetorno	:= .F.
		EndIf

	EndIf

EndIf

/*
If	cPasta == "A"
	cZC_NOTA	:= aCols[n][GdFieldPos("ZC_NOTA",aHeader)]

	If	!Empty( dZC_DTSAI )

		If	Empty( cZC_NOTA )
			MsgBox( "Não foi gerado nota fiscal para este item.", "Inconsistência...", "STOP" )
			aCols[n][GdFieldPos("ZC_DTSAI",aHeader)]	:= CriaVar( "ZC_DTSAI" )
			aCols[n][GdFieldPos("ZC_DEPTODE",aHeader)]	:= CriaVar( "ZC_DEPTODE" )
			lRetorno	:= .F.
		EndIf

	EndIf

EndIf
*/

Return( lRetorno )

********************************************************************************************************************
Static Function FO1()

If	Left( M->ZC_TIPOOP, 1 ) == "P"

	SC5->( DbSetOrder( 1 ) )
	If	!SC5->( DbSeek( xFilial( "SC5" ) + Left( M->ZC_OP, 6 ) ) )
		MsgBox( "Pedido inexistente.", "Atenção...", "STOP" )
		Return( .F. )
	EndIf

	SC6->( DbSetOrder( 1 ) )
	If	!SC6->( DbSeek( xFilial( "SC6" ) + Left( M->ZC_OP, 8 ) ) )
		MsgBox( "Ítem do pedido inexistente.", "Atenção...", "STOP" )
		Return( .F. )
	EndIf

	M->ZC_CODLMT	:= SC6->C6_CODLMT
	M->ZC_DENOM		:= Posicione( "SB1", 1, xFilial( "SB1" ) + SC6->C6_PRODUTO, "B1_DENOM" )
	M->ZC_PRODUTO	:= SC6->C6_PRODUTO
	M->ZC_CLIENTE	:= SC6->C6_CLI
	M->ZC_LOJACLI	:= SC6->C6_LOJA
	M->ZC_NOMCLI	:= Posicione( "SA1", 1, xFilial( "SA1" ) + SC6->( C6_CLI + C6_LOJA ), "A1_NREDUZ" )
	M->ZC_VEND		:= Posicione( "SC5", 1, xFilial( "SC5" ) + SC6->C6_NUM, "C5_VEND1" )
	M->ZC_NOMVEN	:= Posicione( "SA3", 1, xFilial( "SA3" ) + SC5->C5_VEND1, "A3_NREDUZ" )
//	aCols[1,3]		:= Posicione( "SC2", 1, xFilial( "SC2" ) + M->ZC_OP, "C2_EMISSAO" )
	aCols[1,3]		:= CtoD( "" )

	SZB->( DbSetOrder( 1 ) )
	SZB->( DbSeek( xFilial( "SZB" ) + Left( M->ZC_OP , 8 ) ) )
	While	!SZB->( Eof() ) .and.	SZB->ZB_FILIAL	== xFilial( "SZB" ) .and. ;
									SZB->( ZB_PEDIDO + ZB_ITEMPV ) == Left( M->ZC_OP , 8 )

		If	SZB->ZB_DEPTODE == "3"
			aCols[1,3]	:= SZB->ZB_DTSAI
			dZC_DTUS	:= SZB->ZB_DTSAI
		EndIf

		SZB->( DbSkip() )
	EndDo

ElseIf	Left( M->ZC_TIPOOP, 1 ) == "E"

	If	Empty( M->ZC_OP )
		MsgBox( "O.P. não pode ficar em branco.", "Atenção...", "STOP" )
		Return( .F. )
	EndIf

	SC2->( DbSetOrder( 1 ) )
	If	!SC2->( DbSeek( xFilial( "SC2" ) + Left( M->ZC_OP, 11 ) ) )
		MsgBox( "OP inexistente.", "Atenção...", "STOP" )
		Return( .F. )
	EndIf

	M->ZC_CODLMT	:= SC2->C2_CODLMT
	M->ZC_DENOM		:= Posicione( "SB1", 1, xFilial( "SB1" ) + SC2->C2_PRODUTO, "B1_DENOM" )
	M->ZC_PRODUTO	:= SC2->C2_PRODUTO
	M->ZC_CLIENTE	:= CriaVar( "ZC_CLIENTE" )
	M->ZC_LOJACLI	:= CriaVar( "ZC_LOJACLI" )
	M->ZC_NOMCLI	:= CriaVar( "ZC_NOMCLI" )
	M->ZC_VEND		:= CriaVar( "ZC_VEND" )
	M->ZC_NOMVEN	:= CriaVar( "ZC_NOMVEN" )
	aCols[1,3]		:= CriaVar( "ZC_DTENT" )

EndIf

Return( .T. )




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FOPROD    ºAutor  ³Luiz Ferreira       º Data ³  10/04/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Botão para criar linha do Acols como Depto de Origem como   º±±
±±º          ³produção                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LMT Leading                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FOPROD(cAlias,nReg,nOpcx)
Local	bCampo, oDlg, oGet,oReq,oComp
Local	lGravaOK	:= .T.
Local	nAcols		:= 0
Local	nCntFor		:= 0
Local	aSizeAut	:= MsAdvSize(,.F.)   
Local	aObjects	:= {}
Local	aInfo 		:= {}
Local	aPosObj		:= {}

Private	nOpca		:= 0
Private	aCols		:= {}
Private	aTipoOP		:= {}
Private	cZC_TIPOOP	:= SZC->ZC_TIPOOP
Private	cZC_OP		:= SZC->ZC_OP
Private	cZC_SEQ		:= Criavar( "ZC_SEQ" )
Private	dZC_DTUS	:= Criavar( "ZC_DTSAI" )
Private	cZC_DEPTODE	:= CriaVar( "ZC_DEPTODE" )

dbSelectArea("SZC")
dbSetOrder(1)
SZC->( DbSeek( xFilial( "SZC" ) + cZC_OP ) )
M->ZC_TIPOOP	:= SZC->ZC_TIPOOP
M->ZC_OP		:= SZC->ZC_OP
M->ZC_CODLMT	:= SZC->ZC_CODLMT
M->ZC_DENOM		:= SZC->ZC_DENOM
M->ZC_PRODUTO	:= SZC->ZC_PRODUTO
M->ZC_CLIENTE	:= SZC->ZC_CLIENTE
M->ZC_LOJACLI	:= SZC->ZC_LOJACLI
M->ZC_NOMCLI	:= SZC->ZC_NOMCLI
M->ZC_VEND		:= SZC->ZC_VEND
M->ZC_NOMVEN	:= SZC->ZC_NOMVEN

aTipoOp			:= IF( M->ZC_TIPOOP == "P" , { "P-Pedido" } , { "E-Estoque" } )

While !SZC->( Eof() ) .and. SZC->ZC_FILIAL	== xFilial( "SZC" ) .and. ;
							SZC->ZC_OP		== cZC_OP
	If	SZC->ZC_SEQ == "001" .and. Empty( SZC->ZC_DEPTODE )
		cZC_SEQ		:= "000"
//		dZC_DTUS	:= SZC->ZC_DTENT
		dZC_DTUS	:= CtoD( "" )
		cZC_DEPTODE	:= "3"
	Else
		cZC_SEQ		:= SZC->ZC_SEQ
		dZC_DTUS	:= SZC->ZC_DTSAI
//		cZC_DEPTODE	:= IF( !Empty( SZC->ZC_DEPTODE ), SZC->ZC_DEPTODE, cZC_DEPTODE )
		cZC_DEPTODE	:= 'B'
	EndIf
	SZC->( DbSkip() )
EndDo

SZC->( DbGoTo( nReg ) )

If		( ( cZC_DEPTODE == '1' .or. Empty( cZC_DEPTODE ) ) .and. !RetCodUsr() $ GetMv( "MV_FP_VEN" ) )
		MsgBox( "O próximo departamento a fazer atualizações é VENDAS." + PULA_LINHA + PULA_LINHA +;
		"Usuário não pertence a este departamento." + PULA_LINHA + PULA_LINHA +;
		"Verifique parâmetro 'MV_FP_VEN'", "Sem permissão..." , "STOP" )
		Return
ElseIf	( cZC_DEPTODE == '2' .and. !RetCodUsr() $ GetMv( "MV_FP_ENG" ) )
		MsgBox( "O próximo departamento a fazer atualizações é ENGENHARIA." + PULA_LINHA + PULA_LINHA +;
		"Usuário não pertence a este departamento." + PULA_LINHA + PULA_LINHA +;
		"Verifique parâmetro 'MV_FP_ENG'", "Sem permissão..." , "STOP" )
		Return
ElseIf	( cZC_DEPTODE == '3' .and. !RetCodUsr() $ GetMv( "MV_FP_PCP" ) )
		MsgBox( "O próximo departamento a fazer atualizações é PCP." + PULA_LINHA + PULA_LINHA +;
		"Usuário sem permissão para atualização." + PULA_LINHA + PULA_LINHA +;
		"Verifique parâmetro 'MV_FP_PCP'", "Sem permissão..." , "STOP" )
		Return
ElseIf	( cZC_DEPTODE == '4' .and. !RetCodUsr() $ GetMv( "MV_FP_COM" ) )
		MsgBox( "O próximo departamento a fazer atualizações é COMPRAS." + PULA_LINHA + PULA_LINHA +;
		"Usuário sem permissão para atualização." + PULA_LINHA + PULA_LINHA +;
		"Verifique parâmetro 'MV_FP_COM'", "Sem permissão..." , "STOP" )
		Return
ElseIf	( cZC_DEPTODE == '5' .and. !RetCodUsr() $ GetMv( "MV_FP_ALM" ) )
		MsgBox( "O próximo departamento a fazer atualizações é ALMOXARIFADO." + PULA_LINHA + PULA_LINHA +;
		"Usuário sem permissão para atualização." + PULA_LINHA + PULA_LINHA +;
		"Verifique parâmetro 'MV_FP_ALM'", "Sem permissão..." , "STOP" )
		Return
ElseIf	( cZC_DEPTODE == '6' .and. !RetCodUsr() $ GetMv( "MV_FP_CQI" ) )
		MsgBox( "O próximo departamento a fazer atualizações é CQ ITEM." + PULA_LINHA + PULA_LINHA +;
		"Usuário sem permissão para atualização." + PULA_LINHA + PULA_LINHA +;
		"Verifique parâmetro 'MV_FP_CQI'", "Sem permissão..." , "STOP" )
		Return
ElseIf	( cZC_DEPTODE == '7' .and. !RetCodUsr() $ GetMv( "MV_FP_BF" ) )
		MsgBox( "O próximo departamento a fazer atualizações é BF." + PULA_LINHA + PULA_LINHA +;
		"Usuário sem permissão para atualização." + PULA_LINHA + PULA_LINHA +;
		"Verifique parâmetro 'MV_FP_BF'", "Sem permissão..." , "STOP" )
		Return
ElseIf	( cZC_DEPTODE == '8' .and. !RetCodUsr() $ GetMv( "MV_FP_CQB" ) )
		MsgBox( "O próximo departamento a fazer atualizações é CQ BF." + PULA_LINHA + PULA_LINHA +;
		"Usuário sem permissão para atualização." + PULA_LINHA + PULA_LINHA +;
		"Verifique parâmetro 'MV_FP_CQB'", "Sem permissão..." , "STOP" )
		Return
ElseIf	( cZC_DEPTODE == '9' .and. !RetCodUsr() $ GetMv( "MV_FP_AP" ) )
		MsgBox( "O próximo departamento a fazer atualizações é APONTAMENTO DE PRODUÇÃO." + PULA_LINHA + PULA_LINHA +;
		"Usuário sem permissão para atualização." + PULA_LINHA + PULA_LINHA +;
		"Verifique parâmetro 'MV_FP_AP'", "Sem permissão..." , "STOP" )
		Return
ElseIf	( cZC_DEPTODE == '0' .and. !RetCodUsr() $ GetMv( "MV_FP_EXP" ) )
		MsgBox( "O próximo departamento a fazer atualizações é ESTOQUE." + PULA_LINHA + PULA_LINHA +;
		"Usuário sem permissão para atualização." + PULA_LINHA + PULA_LINHA +;
		"Verifique parâmetro 'MV_FP_EXP'", "Sem permissão..." , "STOP" )
		Return
ElseIf	( cZC_DEPTODE == 'B' .and. !RetCodUsr() $ GetMv( "MV_FP_PCP" ) )
		MsgBox( "O próximo departamento a fazer atualizações é PCP." + PULA_LINHA + PULA_LINHA +;
		"Usuário sem permissão para atualização." + PULA_LINHA + PULA_LINHA +;
		"Verifique parâmetro 'MV_FP_PCP'", "Sem permissão..." , "STOP" )
		Return
EndIf

nSavReg  := RecNo()
Private aTELA[0][0],aGETS[0],aHeader[0],Continua,nUsado:=0
bCampo := {|nCPO| Field(nCPO)}

aCampos	:= {}
If		cZC_DEPTODE == '1' .or. Empty( cZC_DEPTODE )
	cVldLin	:= "U_FOLINHA('1')"
	aCampos	:= { "ZC_SEQ", "ZC_DEPTOOR", "ZC_DTENT", "ZC_DTSAI", "ZC_DEPTODE", "ZC_OBS" }
ElseIf	cZC_DEPTODE == '2'
	cVldLin	:= "U_FOLINHA('2')"
	aCampos	:= { "ZC_SEQ", "ZC_DEPTOOR", "ZC_DTENT", "ZC_STATUS", "ZC_DTAPR", "ZC_DTSAI", "ZC_DEPTODE", "ZC_OBS" }
ElseIf	cZC_DEPTODE == '3'
	cVldLin	:= "U_FOLINHA('3')"
	aCampos	:= { "ZC_SEQ", "ZC_DEPTOOR", "ZC_DTENT", "ZC_TIPFAB", "ZC_FORNEC", "ZC_LOJAFOR", "ZC_NOMFOR", "ZC_DTSAI", "ZC_DEPTODE", "ZC_OBS" }
ElseIf	cZC_DEPTODE == '4'
	cVldLin	:= "U_FOLINHA('4')"
	aCampos	:= { "ZC_SEQ", "ZC_DEPTOOR", "ZC_DTENT", "ZC_DTSAI", "ZC_DEPTODE", "ZC_OBS" }
ElseIf	cZC_DEPTODE == '5'
	cVldLin	:= "U_FOLINHA('5')"
	aCampos	:= { "ZC_SEQ", "ZC_DEPTOOR", "ZC_DTENT", "ZC_DTISM", "ZC_DTFSM", "ZC_DTENV", "ZC_DTRET", "ZC_DTSAI", "ZC_DEPTODE", "ZC_OBS" }
ElseIf	cZC_DEPTODE == '6'
	cVldLin	:= "U_FOLINHA('6')"
	aCampos	:= { "ZC_SEQ", "ZC_DEPTOOR", "ZC_DTENT", "ZC_APROV", "ZC_DTSAI", "ZC_DEPTODE", "ZC_OBS" }
 ElseIf	cZC_DEPTODE == '7'
	cVldLin	:= "U_FOLINHA('7')"
	aCampos	:= { "ZC_SEQ", "ZC_DEPTOOR", "ZC_DTENT", "ZC_TEMBF", "ZC_FORNEC", "ZC_LOJAFOR", "ZC_NOMFOR", "ZC_DTENV", "ZC_DTRET", "ZC_DTSAI", "ZC_DEPTODE", "ZC_OBS" }
ElseIf	cZC_DEPTODE == '8'
	cVldLin	:= "U_FOLINHA('8')"
	aCampos	:= { "ZC_SEQ", "ZC_DEPTOOR", "ZC_DTENT", "ZC_APROV", "ZC_DTSAI", "ZC_DEPTODE", "ZC_OBS" }
ElseIf	cZC_DEPTODE == '9'
	cVldLin	:= "U_FOLINHA('9')"
	aCampos	:= { "ZC_SEQ", "ZC_DEPTOOR", "ZC_DTENT", "ZC_DTSAI", "ZC_DEPTODE", "ZC_OBS" }
ElseIf	cZC_DEPTODE == '0'
	cVldLin	:= "U_FOLINHA('0')"
//	aCampos	:= { "ZC_SEQ", "ZC_DEPTOOR", "ZC_DTENT", "ZC_NOTA", "ZC_DTSAI", "ZC_DEPTODE", "ZC_OBS" }
	aCampos	:= { "ZC_SEQ", "ZC_DEPTOOR", "ZC_DTENT", "ZC_DEPTODE", "ZC_OBS" }
ElseIf	cZC_DEPTODE == 'B'
	cVldLin	:= "U_FOLINHA('B')"
	aCampos	:= { "ZC_SEQ", "ZC_DEPTOOR", "ZC_DTENT", "ZC_TIPFAB", "ZC_FORNEC", "ZC_LOJAFOR", "ZC_NOMFOR", "ZC_DTSAI", "ZC_DEPTODE", "ZC_OBS" }
Else
	MsgBox( "Final do processo.", "Fim...", "INFO" )
	Return
EndIf

DbSelectArea( "SX3" )
SX3->( DbSetOrder( 2 ) )
For nCA := 1 to Len( aCampos )
	If	SX3->( DbSeek( aCampos[ nCA ] ) ) .and. X3USO( SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
	EndIf
Next nCA

_nPosDel		:= Len(aHeader) + 1

Private aCOLS[1][nUsado+1]

aCols	:={}
dbSelectArea("SZC")
SZC->( DbSetOrder( 1 ) )
SZC->( DbGoTo( nReg ) )
While !SZC->( Eof() ) .and. SZC->ZC_FILIAL	== xFilial( "SZC" ) .and. ;
							SZC->ZC_OP		== cZC_OP
	If	SZC->ZC_DEPTOOR == cZC_DEPTODE
		AADD(aCols,Array(nUsado+1))
		For _ni:=1 to nUsado
			aCols[Len(aCols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
		Next 
		aCols[Len(aCols),nUsado+1]:=.F.
	EndIf
	SZC->( dbSkip() )
EndDo
If	Len( aCols ) = 0
	AADD(aCols,Array(nUsado+1))
	For _ni:=1 to nUsado
		If		( AllTrim(aHeader[_ni][2]) == "ZC_SEQ" )
			aCols[Len(aCols),_ni] := StrZero( Val( cZC_SEQ ) + 1 , 3 )
		ElseIf	( AllTrim(aHeader[_ni][2]) == "ZC_DEPTOOR" )
			aCols[Len(aCols),_ni] := cZC_DEPTODE
		ElseIf	AllTrim(aHeader[_ni][2]) == "ZC_DTENT"
			aCols[Len(aCols),_ni] := dZC_DTUS
//		ElseIf	AllTrim(aHeader[_ni][2]) == "ZC_OP"
//			SC6->( DbSetOrder( 1 ) )
//			SC6->( DbSeek( xFilial( "SC6" ) + cZC_TIPOOP + cZC_OP ) )
//			aCols[Len(aCols),_ni] := SC6->( C6_NUMOP + C6_ITEMOP )
//		ElseIf	AllTrim(aHeader[_ni][2]) == "ZC_NOTA"
//			SC6->( DbSetOrder( 1 ) )
//			SC6->( DbSeek( xFilial( "SC6" ) + cZC_TIPOOP + cZC_OP ) )
//			aCols[Len(aCols),_ni] := SC6->C6_NOTA
		Else
			aCols[Len(aCols),_ni] := CriaVar(AllTrim(aHeader[_ni][2]))
		EndIf
	Next 
	aCols[Len(aCols),nUsado+1]:=.F.
EndIf

Continua := .F.
nOpca := 0
AAdd( aObjects, { 0,    25, .T., .F. })
AAdd( aObjects, { 100, 100, .T., .T. })
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
aPosObj := MsObjSize( aInfo, aObjects )
DEFINE MSDIALOG oDlg TITLE OemToAnsi("Fluxo de OP´s") From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

@ 020,005 SAY OemToAnsi("Tipo OP") OF oDlg PIXEL
@ 020,045 MSCOMBOBOX  oTipoOP VAR M->ZC_TIPOOP ITEMS aTipoOP Valid Left( M->ZC_TIPOOP, 1 ) $ "PE" SIZE 40,44 When .F. OF oDlg PIXEL

@ 020,090 SAY OemToAnsi("O.P.") OF oDlg PIXEL
@ 020,105 MSGET M->ZC_OP Picture "@!" When .F. F3 "SC2" Valid EXISTCHAV( "SZC", M->ZC_OP ) .and. FO1() .and. ;
CheckSX3("ZC_OP") When VisualSX3("ZC_OP") OF oDlg PIXEL 

@ 035,005 SAY OemToAnsi("Cód.LMT") OF oDlg PIXEL
@ 035,045 MSGET M->ZC_CODLMT When .F. OF oDlg PIXEL

@ 050,005 SAY OemToAnsi("Denominação") OF oDlg PIXEL
@ 050,045 MSGET M->ZC_DENOM When .F. OF oDlg PIXEL

@ 065,005 SAY OemToAnsi("Produto") OF oDlg PIXEL
@ 065,045 MSGET M->ZC_PRODUTO When .F. OF oDlg PIXEL

@ 080,005 SAY OemToAnsi("Cliente") OF oDlg PIXEL
@ 080,045 MSGET M->ZC_CLIENTE When .F. OF oDlg PIXEL

@ 080,090 SAY OemToAnsi("Loja") OF oDlg PIXEL
@ 080,105 MSGET M->ZC_LOJACLI When .F. OF oDlg PIXEL

@ 080,135 MSGET M->ZC_NOMCLI When .F. OF oDlg PIXEL

@ 095,005 SAY OemToAnsi("Vendedor") OF oDlg PIXEL
@ 095,045 MSGET M->ZC_VEND When .F. OF oDlg PIXEL

@ 095,135 MSGET M->ZC_NOMVEN When .F. OF oDlg PIXEL

oGet := MSGetDados():New(aPosObj[2,1]+70,aPosObj[2,2],aPosObj[2,3]+25,aPosObj[2,4],nOpcx,cVldLin,"AllwaysTrue","+ZC_SEQ",.T.,,2,,1)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()})

If nOpcA == 1
	Begin Transaction

		lTemItem	:= .F.
		For nLinha := 1 to Len( aCols )
//			If !aCols[nLinha,_nPosDel]
			If  !GDDeleted(nLinha)
				lTemItem	:= .T.
				Exit
			EndIf
		Next nLinha

		If	!lTemItem
			Return
		EndIf

		DbSelectArea( "SZC" )
		SZC->( DbSetOrder( 1 ) )

		lGeraDestino	:= .F.

		For nYY := 1 to 2
			cSeq	:= IF( nYY == 1 , aCols[1,1] , StrZero( Val(aCols[1,1])+1 , 3 ) )

			If	nYY == 2 .and. !lGeraDestino
				Exit
			EndIf

			If	!SZC->( DbSeek( xFilial( "SZC" ) + cZC_OP + cSeq ) )
				RecLock( "SZC", .T. )
				SZC->ZC_FILIAL	:= xFilial( "SZC" )
				SZC->ZC_TIPOOP	:= M->ZC_TIPOOP
				SZC->ZC_OP		:= M->ZC_OP
				SZC->ZC_CODLMT	:= M->ZC_CODLMT
				SZC->ZC_DENOM	:= M->ZC_DENOM
				SZC->ZC_PRODUTO	:= M->ZC_PRODUTO
				SZC->ZC_CLIENTE	:= M->ZC_CLIENTE
				SZC->ZC_LOJACLI	:= M->ZC_LOJACLI
				SZC->ZC_NOMCLI	:= M->ZC_NOMCLI
				SZC->ZC_VEND	:= M->ZC_VEND
				SZC->ZC_NOMVEN	:= M->ZC_NOMVEN
			Else
				RecLock( "SZC" )
			EndIf

			For nLinha := 1 to Len( aCols )
				If  !GDDeleted(nLinha)
					If	nYY == 1
						xZC_DEPTOOR		:= Space( Len( SZC->ZC_DEPTOOR ) )
						xZC_DTENT		:= Ctod( "" )
						If		cZC_DEPTODE == '1'
							SZC->ZC_SEQ		:= aCols[ nLinha , 1 ]
							SZC->ZC_DEPTOOR	:= aCols[ nLinha , 2 ]
							SZC->ZC_DTENT	:= aCols[ nLinha , 3 ]
							SZC->ZC_DTSAI	:= aCols[ nLinha , 4 ]
							SZC->ZC_DEPTODE	:= aCols[ nLinha , 5 ]
							SZC->ZC_OBS		:= aCols[ nLinha , 6 ]
							xZC_DEPTOOR		:= aCols[ nLinha , 5 ]
							xZC_DTENT		:= aCols[ nLinha , 4 ]
						ElseIf	cZC_DEPTODE == '2'
							SZC->ZC_SEQ		:= aCols[ nLinha , 1 ]
							SZC->ZC_DEPTOOR	:= aCols[ nLinha , 2 ]
							SZC->ZC_DTENT	:= aCols[ nLinha , 3 ]
							SZC->ZC_STATUS	:= aCols[ nLinha , 4 ]
							SZC->ZC_DTAPR	:= aCols[ nLinha , 5 ]
							SZC->ZC_DTSAI	:= aCols[ nLinha , 6 ]
							SZC->ZC_DEPTODE	:= aCols[ nLinha , 7 ]
							SZC->ZC_OBS		:= aCols[ nLinha , 8 ]
							xZC_DEPTOOR		:= aCols[ nLinha , 7 ]
							xZC_DTENT		:= aCols[ nLinha , 6 ]
						ElseIf	cZC_DEPTODE == '3'
							SZC->ZC_SEQ		:= aCols[ nLinha , 1 ]
							SZC->ZC_DEPTOOR	:= aCols[ nLinha , 2 ]
							SZC->ZC_DTENT	:= aCols[ nLinha , 3 ]
							SZC->ZC_TIPFAB	:= aCols[ nLinha , 4 ]
							SZC->ZC_FORNEC	:= aCols[ nLinha , 5 ]
							SZC->ZC_LOJAFOR	:= aCols[ nLinha , 6 ]
							SZC->ZC_NOMFOR	:= aCols[ nLinha , 7 ]
							SZC->ZC_DTSAI	:= aCols[ nLinha , 8 ]
							SZC->ZC_DEPTODE	:= aCols[ nLinha , 9 ]
							SZC->ZC_OBS		:= aCols[ nLinha , 10 ]
							xZC_DEPTOOR		:= aCols[ nLinha , 9 ]
							xZC_DTENT		:= aCols[ nLinha , 8 ]
						ElseIf	cZC_DEPTODE == '4'
							SZC->ZC_SEQ		:= aCols[ nLinha , 1 ]
							SZC->ZC_DEPTOOR	:= aCols[ nLinha , 2 ]
							SZC->ZC_DTENT	:= aCols[ nLinha , 3 ]
							SZC->ZC_DTSAI	:= aCols[ nLinha , 4 ]
							SZC->ZC_DEPTODE	:= aCols[ nLinha , 5 ]
							SZC->ZC_OBS		:= aCols[ nLinha , 6 ]
							xZC_DEPTOOR		:= aCols[ nLinha , 5 ]
							xZC_DTENT		:= aCols[ nLinha , 4 ]
						ElseIf	cZC_DEPTODE == '5'
							SZC->ZC_SEQ		:= aCols[ nLinha , 1 ]
							SZC->ZC_DEPTOOR	:= aCols[ nLinha , 2 ]
							SZC->ZC_DTENT	:= aCols[ nLinha , 3 ]
							SZC->ZC_DTISM	:= aCols[ nLinha , 4 ]
							SZC->ZC_DTFSM	:= aCols[ nLinha , 5 ]
							SZC->ZC_DTENV	:= aCols[ nLinha , 6 ]
							SZC->ZC_DTRET	:= aCols[ nLinha , 7 ]
							SZC->ZC_DTSAI	:= aCols[ nLinha , 8 ]
							SZC->ZC_DEPTODE	:= aCols[ nLinha , 9 ]
							SZC->ZC_OBS		:= aCols[ nLinha , 10 ]
							xZC_DEPTOOR		:= aCols[ nLinha , 9 ]
							xZC_DTENT		:= aCols[ nLinha , 8 ]
						ElseIf	cZC_DEPTODE == '6'
							SZC->ZC_SEQ		:= aCols[ nLinha , 1 ]
							SZC->ZC_DEPTOOR	:= aCols[ nLinha , 2 ]
							SZC->ZC_DTENT	:= aCols[ nLinha , 3 ]
							SZC->ZC_APROV	:= aCols[ nLinha , 4 ]
							SZC->ZC_DTSAI	:= aCols[ nLinha , 5 ]
							SZC->ZC_DEPTODE	:= aCols[ nLinha , 6 ]
							SZC->ZC_OBS		:= aCols[ nLinha , 7 ]
							xZC_DEPTOOR		:= aCols[ nLinha , 6 ]
							xZC_DTENT		:= aCols[ nLinha , 5 ]
						ElseIf	cZC_DEPTODE == '7'
							SZC->ZC_SEQ		:= aCols[ nLinha , 1 ]
							SZC->ZC_DEPTOOR	:= aCols[ nLinha , 2 ]
							SZC->ZC_DTENT	:= aCols[ nLinha , 3 ]
							SZC->ZC_TEMBF	:= aCols[ nLinha , 4 ]
							SZC->ZC_FORNEC	:= aCols[ nLinha , 5 ]
							SZC->ZC_LOJAFOR	:= aCols[ nLinha , 6 ]
							SZC->ZC_NOMFOR	:= aCols[ nLinha , 7 ]
							SZC->ZC_DTENV	:= aCols[ nLinha , 8 ]
							SZC->ZC_DTRET	:= aCols[ nLinha , 9 ]
							SZC->ZC_DTSAI	:= aCols[ nLinha , 10 ]
							SZC->ZC_DEPTODE	:= aCols[ nLinha , 11 ]
							SZC->ZC_OBS		:= aCols[ nLinha , 12 ]
							xZC_DEPTOOR		:= aCols[ nLinha , 11 ]
							xZC_DTENT		:= aCols[ nLinha , 10 ]
						ElseIf	cZC_DEPTODE == '8'
							SZC->ZC_SEQ		:= aCols[ nLinha , 1 ]
							SZC->ZC_DEPTOOR	:= aCols[ nLinha , 2 ]
							SZC->ZC_DTENT	:= aCols[ nLinha , 3 ]
							SZC->ZC_APROV	:= aCols[ nLinha , 4 ]
							SZC->ZC_DTSAI	:= aCols[ nLinha , 5 ]
							SZC->ZC_DEPTODE	:= aCols[ nLinha , 6 ]
							SZC->ZC_OBS		:= aCols[ nLinha , 7 ]
							xZC_DEPTOOR		:= aCols[ nLinha , 6 ]
							xZC_DTENT		:= aCols[ nLinha , 5 ]
						ElseIf	cZC_DEPTODE == '9'
							SZC->ZC_SEQ		:= aCols[ nLinha , 1 ]
							SZC->ZC_DEPTOOR	:= aCols[ nLinha , 2 ]
							SZC->ZC_DTENT	:= aCols[ nLinha , 3 ]
							SZC->ZC_DTSAI	:= aCols[ nLinha , 4 ]
							SZC->ZC_DEPTODE	:= aCols[ nLinha , 5 ]
							SZC->ZC_OBS		:= aCols[ nLinha , 6 ]
							xZC_DEPTOOR		:= aCols[ nLinha , 5 ]
							xZC_DTENT		:= aCols[ nLinha , 4 ]
						ElseIf	cZC_DEPTODE == 'B'
							SZC->ZC_SEQ		:= aCols[ nLinha , 1 ]
							SZC->ZC_DEPTOOR	:= aCols[ nLinha , 2 ]
							SZC->ZC_DTENT	:= aCols[ nLinha , 3 ]
							SZC->ZC_TIPFAB	:= aCols[ nLinha , 4 ]
							SZC->ZC_FORNEC	:= aCols[ nLinha , 5 ]
							SZC->ZC_LOJAFOR	:= aCols[ nLinha , 6 ]
							SZC->ZC_NOMFOR	:= aCols[ nLinha , 7 ]
							SZC->ZC_DTSAI	:= aCols[ nLinha , 8 ]
							SZC->ZC_DEPTODE	:= aCols[ nLinha , 9 ]
							SZC->ZC_OBS		:= aCols[ nLinha , 10 ]
							xZC_DEPTOOR		:= aCols[ nLinha , 9 ]
							xZC_DTENT		:= aCols[ nLinha , 8 ]
						ElseIf	cZC_DEPTODE == '0'
							SZC->ZC_SEQ		:= aCols[ nLinha , 1 ]
							SZC->ZC_DEPTOOR	:= aCols[ nLinha , 2 ]
							SZC->ZC_DTENT	:= aCols[ nLinha , 3 ]
//							SZC->ZC_NOTA	:= aCols[ nLinha , 4 ]
//							SZC->ZC_DTSAI	:= aCols[ nLinha , 5 ]
							SZC->ZC_DEPTODE	:= "Z"
//							SZC->ZC_OBS		:= aCols[ nLinha , 7 ]
							SZC->ZC_OBS		:= aCols[ nLinha , 5 ]
							Exit
						EndIf
						lGeraDestino	:= !Empty( xZC_DEPTOOR )
					Else	
						SZC->ZC_SEQ		:= StrZero( Val( aCols[ nLinha , 1 ] ) + 1 , 3 )
						SZC->ZC_DEPTOOR	:= xZC_DEPTOOR
						SZC->ZC_DTENT	:= xZC_DTENT
					EndIf
					SZC->( MsUnLock() )
				EndIf
			Next nLinha

			SZC->( MsUnLock() )

		Next nYY

	End Transaction

EndIf

dbSelectArea("SZC")
SZC->( DbGoTo( nReg ) )

Return nOpca
