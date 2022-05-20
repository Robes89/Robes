#include "rwmake.ch"
#include "mata096.ch"
#INCLUDE "PROTHEUS.CH"          
#Define	PULA_LINHA	CHR( 13 ) + CHR( 10 )

// Fluxo de Pedidos
// Wilson Santos
// Nov/2008

User Function FLUPED()
PRIVATE	aRotina	:=	{	{ OemToAnsi("&Pesquisar"), 			"AxPesqui",	0,	1},;
						{ OemToAnsi("Vis&ualizar"),			"U_FPVIS",	0,	2},;
						{ OemToAnsi("&Vendas"),				"U_FPVEN",	0,	3},;
						{ OemToAnsi("&Engenharia"),			"U_FPMAN",	0,	4},;
						{ OemToAnsi("E&xcluir Processo"),	"U_FPEXCP",	0,	5},;
						{ OemToAnsi("Ex&cluir Últ.Lançto"),	"U_FPEXCU",	0,	5} }

PRIVATE cCadastro := OemToAnsi("Fluxo de Pedidos")

If	SM0->M0_CODIGO # "01"
	MsgBox( "Rotina disponível apenas para empresa LMT.", "ATENÇÃO...", "STOP" )
	Return
EndIf

dbSelectArea("SZB")
dbSetOrder(1)

mBrowse( 6, 1,22,75,"SZB")

dbSelectArea("SZB")
dbSetOrder(1)

Return

********************************************************************************************************************
User Function FPVEN(cAlias,nReg,nOpcx)
LOCAL bCampo
LOCAL lGravaOK := .T.
LOCAL oDlg, oGet,oReq,oComp
LOCAL nSaveSX8  := GetSX8Len()
Local aSizeAut		:= MsAdvSize(,.F.)   
Local aObjects		:= {}
Local aInfo 		:= {}
Local aPosObj		:= {}

PRIVATE nOpca := 0
Private	dZB_DTUS	:= Criavar( "ZB_DTSAI" )

If	!RetCodUsr() $ GetMv( "MV_FP_VEN" )
	MsgBox( "Inclusão somente permitida para usuário do setor de vendas." + PULA_LINHA + PULA_LINHA +;
	"Parâmetro 'MV_FP_VEN'", "Sem permissão..." , "STOP" )
	Return
EndIf

dbSelectArea( "SZB" )
SZB->( dbSetOrder( 1 ) )
aArea_SZB	:= SZB->( GetArea() )
Private	cZB_PEDIDO	:= SZB->ZB_PEDIDO
Private	cZB_ITEMPV	:= SZB->ZB_ITEMPV

If	SZB->( DbSeek( xFilial( "SZB" ) + cZB_PEDIDO + cZB_ITEMPV ) ) .and. Empty( SZB->ZB_DTSAI )
	U_FPMAN( cAlias, nReg, 4 )
	Return
EndIf

RestArea( aArea_SZB )
nSavReg  := RecNo()
M->ZB_PEDIDO	:= CriaVar( "ZB_PEDIDO" )
M->ZB_ITEMPV	:= CriaVar( "ZB_ITEMPV" )
M->ZB_CODLMT	:= CriaVar( "ZB_CODLMT" )
M->ZB_DENOM		:= CriaVar( "ZB_DENOM" )
M->ZB_PRODUTO	:= CriaVar( "ZB_PRODUTO" )
M->ZB_CLIENTE	:= CriaVar( "ZB_CLIENTE" )
M->ZB_LOJACLI	:= CriaVar( "ZB_LOJACLI" )
M->ZB_NOMCLI	:= CriaVar( "ZB_NOMCLI" )
M->ZB_VEND		:= CriaVar( "ZB_VEND" )
M->ZB_NOMVEN	:= CriaVar( "ZB_NOMVEN" )
M->ZB_COTACAO	:= CriaVar( "ZB_COTACAO" )

Private aTELA[0][0],aGETS[0],aHeader[0],Continua,nUsado:=0
bCampo := {|nCPO| Field(nCPO) }

dbSelectArea("SX3")
dbsetorder(1)
dbSeek( "SZB" )
While !EOF() .And. (sx3->x3_arquivo == "SZB" )
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ;
		AllTrim(x3_campo) $ "ZB_SEQ/ZB_DEPTOOR/ZB_DTENT/ZB_DTSAI/ZB_DEPTODE/ZB_OBS"
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
	Endif
	dbSkip()
End

_nPosDel		:= Len(aHeader) + 1

PRIVATE aCOLS[1][nUsado+1]
dbSelectArea("SX3")
dbsetorder(1)
dbSeek( "SZB" )
nUsado:=0
While !EOF() .And. (sx3->x3_arquivo == "SZB" )
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ;
		AllTrim(x3_campo) $ "ZB_SEQ/ZB_DEPTOOR/ZB_DTENT/ZB_DTSAI/ZB_DEPTODE/ZB_OBS"
		nUsado++
		If		AllTrim(aHeader[nUsado][2]) == "ZB_SEQ"
			aCOLS[1][nUsado] := Repl("0",x3_tamanho-1)+"1"
		ElseIf	AllTrim(aHeader[nUsado][2]) == "ZB_DEPTOOR"
			aCOLS[1][nUsado] := "1"
		ElseIf	AllTrim(aHeader[nUsado][2]) == "ZB_DTENT"
			aCOLS[1][nUsado] := Posicione( "SC5", 1, xFilial( "SC5" ) + M->ZB_PEDIDO, "C5_EMISSAO" )
		Else
			aCOLS[1][nUsado] := CriaVar(x3_campo)
		Endif
	Endif
	dbSkip()
EndDo

aCOLS[1][nUsado+1] := .F.

Continua := .F.
nOpca := 0
AAdd( aObjects, { 0,    25, .T., .F. })
AAdd( aObjects, { 100, 100, .T., .T. })
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
aPosObj := MsObjSize( aInfo, aObjects )
DEFINE MSDIALOG oDlg TITLE OemToAnsi("Fluxo de Pedidos") From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

@ 035,005 SAY OemToAnsi("Pedido") OF oDlg PIXEL
@ 035,045 MSGET M->ZB_PEDIDO Picture "999999" F3 "SC6" Valid ExistCpo( "SC6", M->ZB_PEDIDO, 1 ) .and. FP1() .and. ;
CheckSX3("ZB_PEDIDO") When VisualSX3("ZB_PEDIDO") OF oDlg PIXEL

@ 035,090 SAY OemToAnsi("Item") OF oDlg PIXEL
@ 035,105 MSGET M->ZB_ITEMPV Picture "@!" Valid ExistCpo( "SC6", M->ZB_PEDIDO + M->ZB_ITEMPV, 1 ) .AND. EXISTCHAV( "SZB", M->( ZB_PEDIDO + ZB_ITEMPV ) ) .and. ;
FP1() .and. CheckSX3("ZB_ITEMPV") When VisualSX3("ZB_ITEMPV") OF oDlg PIXEL 

@ 035,135 SAY OemToAnsi("Nº Cotação") OF oDlg PIXEL
@ 035,165 MSGET M->ZB_COTACAO Picture "@!" When VisualSX3("ZB_COTACAO") OF oDlg PIXEL 

@ 050,005 SAY OemToAnsi("Cód.LMT") OF oDlg PIXEL
@ 050,045 MSGET M->ZB_CODLMT When .F. OF oDlg PIXEL

@ 065,005 SAY OemToAnsi("Denominação") OF oDlg PIXEL
@ 065,045 MSGET M->ZB_DENOM When .F. OF oDlg PIXEL

@ 080,005 SAY OemToAnsi("Produto") OF oDlg PIXEL
@ 080,045 MSGET M->ZB_PRODUTO When .F. OF oDlg PIXEL

@ 095,005 SAY OemToAnsi("Cliente") OF oDlg PIXEL
@ 095,045 MSGET M->ZB_CLIENTE When .F. OF oDlg PIXEL

@ 095,090 SAY OemToAnsi("Loja") OF oDlg PIXEL
@ 095,105 MSGET M->ZB_LOJACLI When .F. OF oDlg PIXEL
                   
@ 095,135 MSGET M->ZB_NOMCLI When .F. OF oDlg PIXEL

@ 110,005 SAY OemToAnsi("Vendedor") OF oDlg PIXEL
@ 110,045 MSGET M->ZB_VEND When .F. OF oDlg PIXEL

@ 110,135 MSGET M->ZB_NOMVEN When .F. OF oDlg PIXEL

oGet := MSGetDados():New(aPosObj[2,1]+70,aPosObj[2,2],aPosObj[2,3]+25,aPosObj[2,4],nOpcx,"U_FPLINHA('1')","AllwaysTrue","+ZB_SEQ",.T.,,2,,1)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()})

If nOpcA == 1

	Begin Transaction

		lTemItem	:= .F.
		For nLinha := 1 to Len( aCols )
			If !aCols[nLinha,_nPosDel]
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

			RecLock( "SZB", .T. )
			SZB->ZB_FILIAL	:= xFilial( "SZB" )
			SZB->ZB_PEDIDO	:= M->ZB_PEDIDO
			SZB->ZB_ITEMPV	:= M->ZB_ITEMPV
			SZB->ZB_COTACAO	:= M->ZB_COTACAO
			SZB->ZB_CODLMT	:= M->ZB_CODLMT
			SZB->ZB_DENOM	:= M->ZB_DENOM
			SZB->ZB_PRODUTO	:= M->ZB_PRODUTO
			SZB->ZB_CLIENTE	:= M->ZB_CLIENTE
			SZB->ZB_LOJACLI	:= M->ZB_LOJACLI
			SZB->ZB_NOMCLI	:= M->ZB_NOMCLI
			SZB->ZB_VEND	:= M->ZB_VEND
			SZB->ZB_NOMVEN	:= M->ZB_NOMVEN

			For nLinha := 1 to Len( aCols )

				If	!aCols[nLinha,_nPosDel]

					If	nYY == 1						// depto origem
						SZB->ZB_SEQ		:= aCols[ nLinha , 1 ]
						SZB->ZB_DEPTOOR	:= aCols[ nLinha , 2 ]
						SZB->ZB_DTENT	:= aCols[ nLinha , 3 ]
						SZB->ZB_DTSAI	:= aCols[ nLinha , 4 ]
						SZB->ZB_DEPTODE	:= aCols[ nLinha , 5 ]
						SZB->ZB_OBS		:= aCols[ nLinha , 6 ]
//						SZB->( MsUnLock() )
						lGeraDestino	:= !Empty( aCols[ nLinha , 5 ] )

					Else								// depto destino

						SZB->ZB_SEQ		:= StrZero( Val( aCols[ nLinha , 1 ] ) + 1 , 3 )
						SZB->ZB_DEPTOOR	:= aCols[ nLinha , 5 ]
						SZB->ZB_DTENT	:= aCols[ nLinha , 4 ]
//						SZB->( MsUnLock() )

					EndIf

				EndIf

				If	SZB->ZB_DEPTODE == '2'
					SZB->ZB_STATUS = 'P'
				EndIf

				SZB->( MsUnLock() )

			Next nLinha

			SZB->( MsUnLock() )

		Next nYY

	End Transaction

EndIf

dbSelectArea( "SZB" )

Return nOpcA

********************************************************************************************************************
User Function FPMAN(cAlias,nReg,nOpcx)
LOCAL bCampo
LOCAL lGravaOK := .T.
LOCAL oDlg, oGet,oReq,oComp
LOCAL nAcols := 0
Local nCntFor:= 0
Local aSizeAut		:= MsAdvSize(,.F.)   
Local aObjects		:= {}
Local aInfo 		:= {}
Local aPosObj		:= {}

PRIVATE nOpca := 0,aCols:={}
Private	cZB_PEDIDO	:= SZB->ZB_PEDIDO
Private	cZB_ITEMPV	:= SZB->ZB_ITEMPV
Private	cZB_SEQ		:= Criavar( "ZB_SEQ" )
Private	dZB_DTUS	:= Criavar( "ZB_DTSAI" )
Private	cZB_DEPTODE	:= CriaVar( "ZB_DEPTODE" )

dbSelectArea("SZB")
dbSetOrder(1)
SZB->( DbSeek( xFilial( "SZB" ) + cZB_PEDIDO + cZB_ITEMPV ) )
M->ZB_PEDIDO	:= SZB->ZB_PEDIDO
M->ZB_ITEMPV	:= SZB->ZB_ITEMPV
M->ZB_CODLMT	:= SZB->ZB_CODLMT
M->ZB_DENOM		:= SZB->ZB_DENOM
M->ZB_PRODUTO	:= SZB->ZB_PRODUTO
M->ZB_CLIENTE	:= SZB->ZB_CLIENTE
M->ZB_LOJACLI	:= SZB->ZB_LOJACLI
M->ZB_NOMCLI	:= SZB->ZB_NOMCLI
M->ZB_VEND		:= SZB->ZB_VEND
M->ZB_NOMVEN	:= SZB->ZB_NOMVEN
M->ZB_COTACAO	:= SZB->ZB_COTACAO

While !SZB->( Eof() ) .and. SZB->ZB_FILIAL	== xFilial( "SZB" ) .and. ;
							SZB->ZB_PEDIDO	== cZB_PEDIDO .and. ;
							SZB->ZB_ITEMPV	== cZB_ITEMPV
	If	SZB->ZB_SEQ == "001" .and. Empty( SZB->ZB_DEPTODE )
		cZB_SEQ		:= "000"
		dZB_DTUS	:= SZB->ZB_DTENT
		cZB_DEPTODE	:= "1"
	Else
		cZB_SEQ		:= SZB->ZB_SEQ
		dZB_DTUS	:= SZB->ZB_DTSAI
		cZB_DEPTODE	:= IF( !Empty( SZB->ZB_DEPTODE ), SZB->ZB_DEPTODE, cZB_DEPTODE )
	EndIf
	SZB->( DbSkip() )
EndDo

SZB->( DbGoTo( nReg ) )

If	( ( cZB_DEPTODE == '1' .or. Empty( cZB_DEPTODE ) ) .and. !RetCodUsr() $ GetMv( "MV_FP_VEN" ) )
		MsgBox( "O próximo departamento a fazer atualizações é VENDAS." + PULA_LINHA + PULA_LINHA +;
		"Usuário não pertence a este departamento." + PULA_LINHA + PULA_LINHA +;
		"Verifique parâmetro 'MV_FP_VEN'", "Sem permissão..." , "STOP" )
		Return
ElseIf	( cZB_DEPTODE == '2' .and. !RetCodUsr() $ GetMv( "MV_FP_ENG" ) )
		MsgBox( "O próximo departamento a fazer atualizações é ENGENHARIA." + PULA_LINHA + PULA_LINHA +;
		"Usuário não pertence a este departamento." + PULA_LINHA + PULA_LINHA +;
		"Verifique parâmetro 'MV_FP_ENG'", "Sem permissão..." , "STOP" )
		Return
ElseIf	( cZB_DEPTODE == '3' .and. !RetCodUsr() $ GetMv( "MV_FP_PCP" ) )
		MsgBox( "O próximo departamento a fazer atualizações é PCP." + PULA_LINHA + PULA_LINHA +;
		"Usuário sem permissão para atualização." + PULA_LINHA + PULA_LINHA +;
		"Verifique parâmetro 'MV_FP_PCP'", "Sem permissão..." , "STOP" )
		Return
ElseIf	( cZB_DEPTODE == '4' .and. !RetCodUsr() $ GetMv( "MV_FP_COM" ) )
		MsgBox( "O próximo departamento a fazer atualizações é COMPRAS." + PULA_LINHA + PULA_LINHA +;
		"Usuário sem permissão para atualização." + PULA_LINHA + PULA_LINHA +;
		"Verifique parâmetro 'MV_FP_COM'", "Sem permissão..." , "STOP" )
		Return
ElseIf	( cZB_DEPTODE == '5' .and. !RetCodUsr() $ GetMv( "MV_FP_ALM" ) )
		MsgBox( "O próximo departamento a fazer atualizações é ALMOXARIFADO." + PULA_LINHA + PULA_LINHA +;
		"Usuário sem permissão para atualização." + PULA_LINHA + PULA_LINHA +;
		"Verifique parâmetro 'MV_FP_ALM'", "Sem permissão..." , "STOP" )
		Return
ElseIf	( cZB_DEPTODE == '6' .and. !RetCodUsr() $ GetMv( "MV_FP_CQI" ) )
		MsgBox( "O próximo departamento a fazer atualizações é CQ ITEM." + PULA_LINHA + PULA_LINHA +;
		"Usuário sem permissão para atualização." + PULA_LINHA + PULA_LINHA +;
		"Verifique parâmetro 'MV_FP_CQI'", "Sem permissão..." , "STOP" )
		Return
ElseIf	( cZB_DEPTODE == '7' .and. !RetCodUsr() $ GetMv( "MV_FP_BF" ) )
		MsgBox( "O próximo departamento a fazer atualizações é BF." + PULA_LINHA + PULA_LINHA +;
		"Usuário sem permissão para atualização." + PULA_LINHA + PULA_LINHA +;
		"Verifique parâmetro 'MV_FP_BF'", "Sem permissão..." , "STOP" )
		Return
ElseIf	( cZB_DEPTODE == '8' .and. !RetCodUsr() $ GetMv( "MV_FP_CQB" ) )
		MsgBox( "O próximo departamento a fazer atualizações é CQ BF." + PULA_LINHA + PULA_LINHA +;
		"Usuário sem permissão para atualização." + PULA_LINHA + PULA_LINHA +;
		"Verifique parâmetro 'MV_FP_CQB'", "Sem permissão..." , "STOP" )
		Return
ElseIf	( cZB_DEPTODE == '9' .and. !RetCodUsr() $ GetMv( "MV_FP_AP" ) )
		MsgBox( "O próximo departamento a fazer atualizações é APONTAMENTO DE PRODUÇÃO." + PULA_LINHA + PULA_LINHA +;
		"Usuário sem permissão para atualização." + PULA_LINHA + PULA_LINHA +;
		"Verifique parâmetro 'MV_FP_AP'", "Sem permissão..." , "STOP" )
		Return
ElseIf	( cZB_DEPTODE == '0' .and. !RetCodUsr() $ GetMv( "MV_FP_EXP" ) )
		MsgBox( "O próximo departamento a fazer atualizações é EXPEDIÇÃO." + PULA_LINHA + PULA_LINHA +;
		"Usuário sem permissão para atualização." + PULA_LINHA + PULA_LINHA +;
		"Verifique parâmetro 'MV_FP_EXP'", "Sem permissão..." , "STOP" )
		Return
EndIf

nSavReg  := RecNo()
Private aTELA[0][0],aGETS[0],aHeader[0],Continua,nUsado:=0
bCampo := {|nCPO| Field(nCPO)}

aCampos	:= {}
If		cZB_DEPTODE == '1' .or. Empty( cZB_DEPTODE )
	cVldLin	:= "U_FPLINHA('1')"
	aCampos	:= { "ZB_SEQ", "ZB_DEPTOOR", "ZB_DTENT", "ZB_DTSAI", "ZB_DEPTODE", "ZB_OBS" }
ElseIf	cZB_DEPTODE == '2'
	cVldLin	:= "U_FPLINHA('2')"
	aCampos	:= { "ZB_SEQ", "ZB_DEPTOOR", "ZB_DTENT", "ZB_STATUS", "ZB_DTAPR", "ZB_DTSAI", "ZB_DEPTODE", "ZB_OBS" }
ElseIf	cZB_DEPTODE == '3'
	cVldLin	:= "U_FPLINHA('3')"
	aCampos	:= { "ZB_SEQ", "ZB_DEPTOOR", "ZB_DTENT", "ZB_TIPFAB", "ZB_FORNEC", "ZB_LOJAFOR", "ZB_NOMFOR", "ZB_OP", "ZB_DTSAI", "ZB_DEPTODE", "ZB_OBS" }
ElseIf	cZB_DEPTODE == '4'
	cVldLin	:= "U_FPLINHA('4')"
	aCampos	:= { "ZB_SEQ", "ZB_DEPTOOR", "ZB_DTENT", "ZB_DTSAI", "ZB_DEPTODE", "ZB_OBS" }
ElseIf	cZB_DEPTODE == '5'
	cVldLin	:= "U_FPLINHA('5')"
	aCampos	:= { "ZB_SEQ", "ZB_DEPTOOR", "ZB_DTENT", "ZB_DTISM", "ZB_DTFSM", "ZB_DTENV", "ZB_DTRET", "ZB_DTSAI", "ZB_DEPTODE", "ZB_OBS" }
ElseIf	cZB_DEPTODE == '6'
	cVldLin	:= "U_FPLINHA('6')"
	aCampos	:= { "ZB_SEQ", "ZB_DEPTOOR", "ZB_DTENT", "ZB_APROV", "ZB_DTSAI", "ZB_DEPTODE", "ZB_OBS" }
ElseIf	cZB_DEPTODE == '7'
	cVldLin	:= "U_FPLINHA('7')"
	aCampos	:= { "ZB_SEQ", "ZB_DEPTOOR", "ZB_DTENT", "ZB_TEMBF", "ZB_FORNEC", "ZB_LOJAFOR", "ZB_NOMFOR", "ZB_DTENV", "ZB_DTRET", "ZB_DTSAI", "ZB_DEPTODE", "ZB_OBS" }
ElseIf	cZB_DEPTODE == '8'
	cVldLin	:= "U_FPLINHA('8')"
	aCampos	:= { "ZB_SEQ", "ZB_DEPTOOR", "ZB_DTENT", "ZB_APROV", "ZB_DTSAI", "ZB_DEPTODE", "ZB_OBS" }
ElseIf	cZB_DEPTODE == '9'
	cVldLin	:= "U_FPLINHA('9')"
	aCampos	:= { "ZB_SEQ", "ZB_DEPTOOR", "ZB_DTENT", "ZB_OP", "ZB_DTSAI", "ZB_DEPTODE", "ZB_OBS" }
ElseIf	cZB_DEPTODE == '0'
	cVldLin	:= "U_FPLINHA('0')"
	aCampos	:= { "ZB_SEQ", "ZB_DEPTOOR", "ZB_DTENT", "ZB_NOTA", "ZB_DTSAI", "ZB_DEPTODE", "ZB_OBS" }
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

PRIVATE aCOLS[1][nUsado+1]

aCols	:={}
dbSelectArea("SZB")
SZB->( DbSetOrder( 1 ) )
SZB->( DbGoTo( nReg ) )
While !SZB->( Eof() ) .and. SZB->ZB_FILIAL	== xFilial( "SZB" ) .and. ;
							SZB->ZB_PEDIDO	== cZB_PEDIDO .and. ;
							SZB->ZB_ITEMPV	== cZB_ITEMPV
	If	SZB->ZB_DEPTOOR == cZB_DEPTODE
		AADD(aCols,Array(nUsado+1))
		For _ni:=1 to nUsado
			aCols[Len(aCols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
		Next 
		aCols[Len(aCols),nUsado+1]:=.F.
	EndIf
	SZB->( dbSkip() )
EndDo
If	Len( aCols ) = 0
	AADD(aCols,Array(nUsado+1))
	For _ni:=1 to nUsado
		If		( AllTrim(aHeader[_ni][2]) == "ZB_SEQ" )
			aCols[Len(aCols),_ni] := StrZero( Val( cZB_SEQ ) + 1 , 3 )
		ElseIf	( AllTrim(aHeader[_ni][2]) == "ZB_DEPTOOR" )
			aCols[Len(aCols),_ni] := cZB_DEPTODE
		ElseIf	AllTrim(aHeader[_ni][2]) == "ZB_DTENT"
			aCols[Len(aCols),_ni] := dZB_DTUS
		ElseIf	AllTrim(aHeader[_ni][2]) == "ZB_OP"
			SC6->( DbSetOrder( 1 ) )
			SC6->( DbSeek( xFilial( "SC6" ) + cZB_PEDIDO + cZB_ITEMPV ) )
			aCols[Len(aCols),_ni] := SC6->( C6_NUMOP + C6_ITEMOP )
		ElseIf	AllTrim(aHeader[_ni][2]) == "ZB_NOTA"
			SC6->( DbSetOrder( 1 ) )
			SC6->( DbSeek( xFilial( "SC6" ) + cZB_PEDIDO + cZB_ITEMPV ) )
			aCols[Len(aCols),_ni] := SC6->C6_NOTA
		Else
//			aCols[Len(aCols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
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
DEFINE MSDIALOG oDlg TITLE OemToAnsi("Fluxo de Pedidos") From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

@ 020,005 SAY OemToAnsi("Pedido") OF oDlg PIXEL
@ 020,045 MSGET M->ZB_PEDIDO Picture "999999" When .F. OF oDlg PIXEL

@ 020,090 SAY OemToAnsi("Item") OF oDlg PIXEL
@ 020,105 MSGET M->ZB_ITEMPV Picture "@!" Valid When .F. OF oDlg PIXEL 

@ 020,135 SAY OemToAnsi("Nº Cotação") OF oDlg PIXEL
@ 020,165 MSGET M->ZB_COTACAO Picture "@!" When .F. OF oDlg PIXEL 

@ 035,005 SAY OemToAnsi("Cód.LMT") OF oDlg PIXEL
@ 035,045 MSGET M->ZB_CODLMT When .F. OF oDlg PIXEL

@ 050,005 SAY OemToAnsi("Denominação") OF oDlg PIXEL
@ 050,045 MSGET M->ZB_DENOM When .F. OF oDlg PIXEL

@ 065,005 SAY OemToAnsi("Produto") OF oDlg PIXEL
@ 065,045 MSGET M->ZB_PRODUTO When .F. OF oDlg PIXEL

@ 080,005 SAY OemToAnsi("Cliente") OF oDlg PIXEL
@ 080,045 MSGET M->ZB_CLIENTE When .F. OF oDlg PIXEL

@ 080,090 SAY OemToAnsi("Loja") OF oDlg PIXEL
@ 080,105 MSGET M->ZB_LOJACLI When .F. OF oDlg PIXEL

@ 080,135 MSGET M->ZB_NOMCLI When .F. OF oDlg PIXEL

@ 095,005 SAY OemToAnsi("Vendedor") OF oDlg PIXEL
@ 095,045 MSGET M->ZB_VEND When .F. OF oDlg PIXEL

@ 095,135 MSGET M->ZB_NOMVEN When .F. OF oDlg PIXEL

oGet := MSGetDados():New(aPosObj[2,1]+70,aPosObj[2,2],aPosObj[2,3]+25,aPosObj[2,4],nOpcx,cVldLin,"AllwaysTrue","+ZB_SEQ",.T.,,2,,1)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()})

If nOpcA == 1
	Begin Transaction

		lTemItem	:= .F.
		For nLinha := 1 to Len( aCols )
			If !aCols[nLinha,_nPosDel]
				lTemItem	:= .T.
				Exit
			EndIf
		Next nLinha

		If	!lTemItem
			Return
		EndIf

		DbSelectArea( "SZB" )
		SZB->( DbSetOrder( 1 ) )

		lGeraDestino	:= .F.

		For nYY := 1 to 2
			cSeq	:= IF( nYY == 1 , aCols[1,1] , StrZero( Val(aCols[1,1])+1 , 3 ) )

			If	nYY == 2 .and. !lGeraDestino
				Exit
			EndIf

			If	!SZB->( DbSeek( xFilial( "SZB" ) + cZB_PEDIDO + cZB_ITEMPV + cSeq ) )
				RecLock( "SZB", .T. )
				SZB->ZB_FILIAL	:= xFilial( "SZB" )
				SZB->ZB_PEDIDO	:= M->ZB_PEDIDO
				SZB->ZB_ITEMPV	:= M->ZB_ITEMPV
				SZB->ZB_COTACAO	:= M->ZB_COTACAO
				SZB->ZB_CODLMT	:= M->ZB_CODLMT
				SZB->ZB_DENOM	:= M->ZB_DENOM
				SZB->ZB_PRODUTO	:= M->ZB_PRODUTO
				SZB->ZB_CLIENTE	:= M->ZB_CLIENTE
				SZB->ZB_LOJACLI	:= M->ZB_LOJACLI
				SZB->ZB_NOMCLI	:= M->ZB_NOMCLI
				SZB->ZB_VEND	:= M->ZB_VEND
				SZB->ZB_NOMVEN	:= M->ZB_NOMVEN
			Else
				RecLock( "SZB" )
			EndIf

			For nLinha := 1 to Len( aCols )

				If	!aCols[nLinha,_nPosDel]

					If	nYY == 1
						xZB_DEPTOOR		:= Space( Len( SZB->ZB_DEPTOOR ) )
						xZB_DTENT		:= Ctod( "" )

						If		cZB_DEPTODE == '1'
							SZB->ZB_SEQ		:= aCols[ nLinha , 1 ]
							SZB->ZB_DEPTOOR	:= aCols[ nLinha , 2 ]
							SZB->ZB_DTENT	:= aCols[ nLinha , 3 ]
							SZB->ZB_DTSAI	:= aCols[ nLinha , 4 ]
							SZB->ZB_DEPTODE	:= aCols[ nLinha , 5 ]
							SZB->ZB_OBS		:= aCols[ nLinha , 6 ]
							xZB_DEPTOOR		:= aCols[ nLinha , 5 ]
							xZB_DTENT		:= aCols[ nLinha , 4 ]
						ElseIf	cZB_DEPTODE == '2'
							SZB->ZB_SEQ		:= aCols[ nLinha , 1 ]
							SZB->ZB_DEPTOOR	:= aCols[ nLinha , 2 ]
							SZB->ZB_DTENT	:= aCols[ nLinha , 3 ]
							SZB->ZB_STATUS	:= aCols[ nLinha , 4 ]
							SZB->ZB_DTAPR	:= aCols[ nLinha , 5 ]
							SZB->ZB_DTSAI	:= aCols[ nLinha , 6 ]
							SZB->ZB_DEPTODE	:= aCols[ nLinha , 7 ]
							SZB->ZB_OBS		:= aCols[ nLinha , 8 ]
							xZB_DEPTOOR		:= aCols[ nLinha , 7 ]
							xZB_DTENT		:= aCols[ nLinha , 6 ]
						ElseIf	cZB_DEPTODE == '3'
							SZB->ZB_SEQ		:= aCols[ nLinha , 1 ]
							SZB->ZB_DEPTOOR	:= aCols[ nLinha , 2 ]
							SZB->ZB_DTENT	:= aCols[ nLinha , 3 ]
							SZB->ZB_TIPFAB	:= aCols[ nLinha , 4 ]
							SZB->ZB_FORNEC	:= aCols[ nLinha , 5 ]
							SZB->ZB_LOJAFOR	:= aCols[ nLinha , 6 ]
							SZB->ZB_NOMFOR	:= aCols[ nLinha , 7 ]
							SZB->ZB_OP		:= aCols[ nLinha , 8 ]
							SZB->ZB_DTSAI	:= aCols[ nLinha , 9 ]
							SZB->ZB_DEPTODE	:= aCols[ nLinha , 10 ]
							SZB->ZB_OBS		:= aCols[ nLinha , 11 ]
							xZB_DEPTOOR		:= aCols[ nLinha , 10 ]
							xZB_DTENT		:= aCols[ nLinha , 9 ]
						ElseIf	cZB_DEPTODE == '4'
							SZB->ZB_SEQ		:= aCols[ nLinha , 1 ]
							SZB->ZB_DEPTOOR	:= aCols[ nLinha , 2 ]
							SZB->ZB_DTENT	:= aCols[ nLinha , 3 ]
							SZB->ZB_DTSAI	:= aCols[ nLinha , 4 ]
							SZB->ZB_DEPTODE	:= aCols[ nLinha , 5 ]
							SZB->ZB_OBS		:= aCols[ nLinha , 6 ]
							xZB_DEPTOOR		:= aCols[ nLinha , 5 ]
							xZB_DTENT		:= aCols[ nLinha , 4 ]
						ElseIf	cZB_DEPTODE == '5'
							SZB->ZB_SEQ		:= aCols[ nLinha , 1 ]
							SZB->ZB_DEPTOOR	:= aCols[ nLinha , 2 ]
							SZB->ZB_DTENT	:= aCols[ nLinha , 3 ]
							SZB->ZB_DTISM	:= aCols[ nLinha , 4 ]
							SZB->ZB_DTFSM	:= aCols[ nLinha , 5 ]
							SZB->ZB_DTENV	:= aCols[ nLinha , 6 ]
							SZB->ZB_DTRET	:= aCols[ nLinha , 7 ]
							SZB->ZB_DTSAI	:= aCols[ nLinha , 8 ]
							SZB->ZB_DEPTODE	:= aCols[ nLinha , 9 ]
							SZB->ZB_OBS		:= aCols[ nLinha , 10 ]
							xZB_DEPTOOR		:= aCols[ nLinha , 9 ]
							xZB_DTENT		:= aCols[ nLinha , 8 ]
						ElseIf	cZB_DEPTODE == '6'
							SZB->ZB_SEQ		:= aCols[ nLinha , 1 ]
							SZB->ZB_DEPTOOR	:= aCols[ nLinha , 2 ]
							SZB->ZB_DTENT	:= aCols[ nLinha , 3 ]
							SZB->ZB_APROV	:= aCols[ nLinha , 4 ]
							SZB->ZB_DTSAI	:= aCols[ nLinha , 5 ]
							SZB->ZB_DEPTODE	:= aCols[ nLinha , 6 ]
							SZB->ZB_OBS		:= aCols[ nLinha , 7 ]
							xZB_DEPTOOR		:= aCols[ nLinha , 6 ]
							xZB_DTENT		:= aCols[ nLinha , 5 ]
						ElseIf	cZB_DEPTODE == '7'
							SZB->ZB_SEQ		:= aCols[ nLinha , 1 ]
							SZB->ZB_DEPTOOR	:= aCols[ nLinha , 2 ]
							SZB->ZB_DTENT	:= aCols[ nLinha , 3 ]
							SZB->ZB_TEMBF	:= aCols[ nLinha , 4 ]
							SZB->ZB_FORNEC	:= aCols[ nLinha , 5 ]
							SZB->ZB_LOJAFOR	:= aCols[ nLinha , 6 ]
							SZB->ZB_NOMFOR	:= aCols[ nLinha , 7 ]
							SZB->ZB_DTENV	:= aCols[ nLinha , 8 ]
							SZB->ZB_DTRET	:= aCols[ nLinha , 9 ]
							SZB->ZB_DTSAI	:= aCols[ nLinha , 10 ]
							SZB->ZB_DEPTODE	:= aCols[ nLinha , 11 ]
							SZB->ZB_OBS		:= aCols[ nLinha , 12 ]
							xZB_DEPTOOR		:= aCols[ nLinha , 11 ]
							xZB_DTENT		:= aCols[ nLinha , 10 ]
						ElseIf	cZB_DEPTODE == '8'
							SZB->ZB_SEQ		:= aCols[ nLinha , 1 ]
							SZB->ZB_DEPTOOR	:= aCols[ nLinha , 2 ]
							SZB->ZB_DTENT	:= aCols[ nLinha , 3 ]
							SZB->ZB_APROV	:= aCols[ nLinha , 4 ]
							SZB->ZB_DTSAI	:= aCols[ nLinha , 5 ]
							SZB->ZB_DEPTODE	:= aCols[ nLinha , 6 ]
							SZB->ZB_OBS		:= aCols[ nLinha , 7 ]
							xZB_DEPTOOR		:= aCols[ nLinha , 6 ]
							xZB_DTENT		:= aCols[ nLinha , 5 ]
						ElseIf	cZB_DEPTODE == '9'
							SZB->ZB_SEQ		:= aCols[ nLinha , 1 ]
							SZB->ZB_DEPTOOR	:= aCols[ nLinha , 2 ]
							SZB->ZB_DTENT	:= aCols[ nLinha , 3 ]
							SZB->ZB_OP		:= aCols[ nLinha , 4 ]
							SZB->ZB_DTSAI	:= aCols[ nLinha , 5 ]
							SZB->ZB_DEPTODE	:= aCols[ nLinha , 6 ]
							SZB->ZB_OBS		:= aCols[ nLinha , 7 ]
							xZB_DEPTOOR		:= aCols[ nLinha , 6 ]
							xZB_DTENT		:= aCols[ nLinha , 5 ]
						ElseIf	cZB_DEPTODE == '0'
							SZB->ZB_SEQ		:= aCols[ nLinha , 1 ]
							SZB->ZB_DEPTOOR	:= aCols[ nLinha , 2 ]
							SZB->ZB_DTENT	:= aCols[ nLinha , 3 ]
							SZB->ZB_NOTA	:= aCols[ nLinha , 4 ]
							SZB->ZB_DTSAI	:= aCols[ nLinha , 5 ]
							SZB->ZB_DEPTODE	:= "Z"
							SZB->ZB_OBS		:= aCols[ nLinha , 7 ]
							Exit
						EndIf
						lGeraDestino	:= !Empty( xZB_DEPTOOR )
					Else								// depto destino
						SZB->ZB_SEQ		:= StrZero( Val( aCols[ nLinha , 1 ] ) + 1 , 3 )
						SZB->ZB_DEPTOOR	:= xZB_DEPTOOR
						SZB->ZB_DTENT	:= xZB_DTENT
						SZB->( MsUnLock() )
					EndIf

					If	SZB->ZB_DEPTODE == '2'
						SZB->ZB_STATUS = 'P'
					EndIf
					
					SZB->( MsUnLock() )
				EndIf
			Next nLinha

			SZB->( MsUnLock() )

		Next nYY

	End Transaction

EndIf

dbSelectArea("SZB")
SZB->( DbGoTo( nReg ) )

Return nOpca

********************************************************************************************************************
User Function FPVIS(cAlias,nReg,nOpcx)
LOCAL bCampo
LOCAL lGravaOK := .T.
LOCAL oDlg, oGet,oReq,oComp
LOCAL nAcols := 0
Local nCntFor:= 0
Local aSizeAut		:= MsAdvSize(,.F.)   
Local aObjects		:= {}
Local aInfo 		:= {}
Local aPosObj		:= {}

PRIVATE nOpca := 0
PRIVATE aCols := {}  
Private	cZB_PEDIDO	:= SZB->ZB_PEDIDO
Private	cZB_ITEMPV	:= SZB->ZB_ITEMPV

dbSelectArea("SZB")
dbSetOrder(1)
SZB->( DbSeek( xFilial( "SZB" ) + cZB_PEDIDO + cZB_ITEMPV ) )

M->ZB_PEDIDO	:= SZB->ZB_PEDIDO
M->ZB_ITEMPV	:= SZB->ZB_ITEMPV
M->ZB_CODLMT	:= SZB->ZB_CODLMT
M->ZB_DENOM		:= SZB->ZB_DENOM
M->ZB_PRODUTO	:= SZB->ZB_PRODUTO
M->ZB_CLIENTE	:= SZB->ZB_CLIENTE
M->ZB_LOJACLI	:= SZB->ZB_LOJACLI
M->ZB_NOMCLI	:= SZB->ZB_NOMCLI
M->ZB_VEND		:= SZB->ZB_VEND
M->ZB_NOMVEN	:= SZB->ZB_NOMVEN
M->ZB_COTACAO	:= SZB->ZB_COTACAO

nSavReg  := RecNo()
Private aTELA[0][0],aGETS[0],aHeader[0],Continua,nUsado:=0
bCampo := {|nCPO| Field(nCPO)}

dbSelectArea("SX3")
dbSeek( "SZB" )
While !EOF() .And. (SX3->x3_arquivo == "SZB" )
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ;
		!AllTrim(x3_campo) $ "ZB_PEDIDO/ZB_ITEMPV/ZB_COTACAO/ZB_CODLMT/ZB_DENOM/ZB_PRODUTO/ZB_CLIENTE/ZB_LOJACLI/ZB_NOMCLI/ZB_VEND/ZB_NOMVEN"
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
	Endif
	dbSkip()
End
dbSelectArea("SZB")
While !SZB->( Eof() ) .And. SZB->ZB_FILIAL	== xFilial( "SZB" ) .and. ;
							SZB->ZB_PEDIDO	== cZB_PEDIDO .and. ;
							SZB->ZB_ITEMPV	== cZB_ITEMPV
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
DEFINE MSDIALOG oDlg TITLE OemToAnsi("Fluxo de Pedidos") From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

@ 020,005 SAY OemToAnsi("Pedido") OF oDlg PIXEL
@ 020,045 MSGET M->ZB_PEDIDO Picture "999999" When .F. OF oDlg PIXEL

@ 020,090 SAY OemToAnsi("Item") OF oDlg PIXEL
@ 020,105 MSGET M->ZB_ITEMPV Picture "@!" Valid When .F. OF oDlg PIXEL 

@ 020,135 SAY OemToAnsi("Nº Cotação") OF oDlg PIXEL
@ 020,165 MSGET M->ZB_COTACAO Picture "@!" When .F. OF oDlg PIXEL 

@ 035,005 SAY OemToAnsi("Cód.LMT") OF oDlg PIXEL
@ 035,045 MSGET M->ZB_CODLMT When .F. OF oDlg PIXEL

@ 050,005 SAY OemToAnsi("Denominação") OF oDlg PIXEL
@ 050,045 MSGET M->ZB_DENOM When .F. OF oDlg PIXEL

@ 065,005 SAY OemToAnsi("Produto") OF oDlg PIXEL
@ 065,045 MSGET M->ZB_PRODUTO When .F. OF oDlg PIXEL

@ 080,005 SAY OemToAnsi("Cliente") OF oDlg PIXEL
@ 080,045 MSGET M->ZB_CLIENTE When .F. OF oDlg PIXEL

@ 080,090 SAY OemToAnsi("Loja") OF oDlg PIXEL
@ 080,105 MSGET M->ZB_LOJACLI When .F. OF oDlg PIXEL

@ 080,135 MSGET M->ZB_NOMCLI When .F. OF oDlg PIXEL

@ 095,005 SAY OemToAnsi("Vendedor") OF oDlg PIXEL
@ 095,045 MSGET M->ZB_VEND When .F. OF oDlg PIXEL

@ 095,135 MSGET M->ZB_NOMVEN When .F. OF oDlg PIXEL

oGet := MSGetDados():New(aPosObj[2,1]+70,aPosObj[2,2],aPosObj[2,3]+25,aPosObj[2,4],nOpcx,"AllwaysTrue","AllwaysTrue","+ZB_SEQ",.T.,,2,,1)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()})

dbSelectArea("SZB")
SZB->( DbGoTo( nReg ) )

Return nOpca

********************************************************************************************************************
User Function FPEXCP(cAlias,nReg,nOpcx)
LOCAL bCampo
LOCAL lGravaOK := .T.
LOCAL oDlg, oGet,oReq,oComp
LOCAL nAcols := 0
Local nCntFor:= 0
Local aSizeAut	:= MsAdvSize(,.F.)   
Local aObjects	:= {}
Local aInfo 	:= {}
Local aPosObj	:= {}

If	!RetCodUsr() $ GetMv( "MV_FP_VEN" ) .and. !RetCodUsr() $ GetMv( "MV_FP_ENG" )
	MsgBox( "Usuário sem acesso para exclusão." + PULA_LINHA + PULA_LINHA +;
	"Somente usuários dos departamentos de vendas e engenharia tem este acesso" + PULA_LINHA + PULA_LINHA +;
	"Verifique os parâmetros 'MV_FP_VEN','MV_FP_ENG'", "Sem permissão..." , "STOP" )
	Return
EndIf

PRIVATE nOpca := 0
PRIVATE aCols := {}  
Private	cZB_PEDIDO	:= SZB->ZB_PEDIDO
Private	cZB_ITEMPV	:= SZB->ZB_ITEMPV

dbSelectArea("SZB")
dbSetOrder(1)
SZB->( DbSeek( xFilial( "SZB" ) + cZB_PEDIDO + cZB_ITEMPV ) )

M->ZB_PEDIDO	:= SZB->ZB_PEDIDO
M->ZB_ITEMPV	:= SZB->ZB_ITEMPV
M->ZB_CODLMT	:= SZB->ZB_CODLMT
M->ZB_DENOM		:= SZB->ZB_DENOM
M->ZB_PRODUTO	:= SZB->ZB_PRODUTO
M->ZB_CLIENTE	:= SZB->ZB_CLIENTE
M->ZB_LOJACLI	:= SZB->ZB_LOJACLI
M->ZB_NOMCLI	:= SZB->ZB_NOMCLI
M->ZB_VEND		:= SZB->ZB_VEND
M->ZB_NOMVEN	:= SZB->ZB_NOMVEN
M->ZB_COTACAO	:= SZB->ZB_COTACAO

nSavReg  := RecNo()
Private aTELA[0][0],aGETS[0],aHeader[0],Continua,nUsado:=0
bCampo := {|nCPO| Field(nCPO)}

dbSelectArea("SX3")
dbSeek( "SZB" )
While !EOF() .And. (SX3->x3_arquivo == "SZB" )
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ;
		!AllTrim(x3_campo) $ "ZB_PEDIDO/ZB_ITEMPV/ZB_COTACAO/ZB_CODLMT/ZB_DENOM/ZB_PRODUTO/ZB_CLIENTE/ZB_LOJACLI/ZB_NOMCLI/ZB_VEND/ZB_NOMVEN"
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
	Endif
	dbSkip()
End
dbSelectArea("SZB")
While !SZB->( Eof() ) .And. SZB->ZB_FILIAL	== xFilial( "SZB" ) .and. ;
							SZB->ZB_PEDIDO	== cZB_PEDIDO .and. ;
							SZB->ZB_ITEMPV	== cZB_ITEMPV
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
DEFINE MSDIALOG oDlg TITLE OemToAnsi("Fluxo de Pedidos") From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

@ 020,005 SAY OemToAnsi("Pedido") OF oDlg PIXEL
@ 020,045 MSGET M->ZB_PEDIDO Picture "999999" When .F. OF oDlg PIXEL

@ 020,090 SAY OemToAnsi("Item") OF oDlg PIXEL
@ 020,105 MSGET M->ZB_ITEMPV Picture "@!" Valid When .F. OF oDlg PIXEL 

@ 020,135 SAY OemToAnsi("Nº Cotação") OF oDlg PIXEL
@ 020,165 MSGET M->ZB_COTACAO Picture "@!" When .F. OF oDlg PIXEL 

@ 035,005 SAY OemToAnsi("Cód.LMT") OF oDlg PIXEL
@ 035,045 MSGET M->ZB_CODLMT When .F. OF oDlg PIXEL

@ 050,005 SAY OemToAnsi("Denominação") OF oDlg PIXEL
@ 050,045 MSGET M->ZB_DENOM When .F. OF oDlg PIXEL

@ 065,005 SAY OemToAnsi("Produto") OF oDlg PIXEL
@ 065,045 MSGET M->ZB_PRODUTO When .F. OF oDlg PIXEL

@ 080,005 SAY OemToAnsi("Cliente") OF oDlg PIXEL
@ 080,045 MSGET M->ZB_CLIENTE When .F. OF oDlg PIXEL

@ 080,090 SAY OemToAnsi("Loja") OF oDlg PIXEL
@ 080,105 MSGET M->ZB_LOJACLI When .F. OF oDlg PIXEL

@ 080,135 MSGET M->ZB_NOMCLI When .F. OF oDlg PIXEL

@ 095,005 SAY OemToAnsi("Vendedor") OF oDlg PIXEL
@ 095,045 MSGET M->ZB_VEND When .F. OF oDlg PIXEL

@ 095,135 MSGET M->ZB_NOMVEN When .F. OF oDlg PIXEL

oGet := MSGetDados():New(aPosObj[2,1]+70,aPosObj[2,2],aPosObj[2,3]+25,aPosObj[2,4],nOpcx,"AllwaysTrue","AllwaysTrue","+ZB_SEQ",.T.,,2,,1)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()})

If nOpcA == 1

	If	!MsgYesNo( "Confirmando a exclusão, todos processos serão excluídos. Confirma?", "ATENÇÃO..." )
		SZB->( DbGoTo( nReg ) )
		Return
	EndIf

	Begin Transaction

		DbSelectArea( "SZB" )
		SZB->( DbSetOrder( 1 ) )
		SZB->( DbSeek( xFilial( "SZB" ) + cZB_PEDIDO + cZB_ITEMPV ) )
		While !SZB->( Eof() ) .and.	SZB->ZB_FILIAL	== xFilial( "SZB" ) .and. ;
									SZB->ZB_PEDIDO	== cZB_PEDIDO .and. ;
									SZB->ZB_ITEMPV	== cZB_ITEMPV

			RecLock( "SZB", .F. )
			SZB->( DbDelete() )
			SZB->( MsUnLock() )

			SZB->( DbSkip() )
		EndDo

	End Transaction

EndIf

dbSelectArea("SZB")

Return nOpca

********************************************************************************************************************
User Function FPEXCU(cAlias,nReg,nOpcx)
LOCAL bCampo
LOCAL lGravaOK := .T.
LOCAL oDlg, oGet,oReq,oComp
LOCAL nAcols := 0
Local nCntFor:= 0
Local aSizeAut	:= MsAdvSize(,.F.)   
Local aObjects	:= {}
Local aInfo 	:= {}
Local aPosObj	:= {}

If	!RetCodUsr() $ GetMv( "MV_FP_VEN" ) .and. !RetCodUsr() $ GetMv( "MV_FP_ENG" )
	MsgBox( "Usuário sem acesso para exclusão." + PULA_LINHA + PULA_LINHA +;
	"Somente usuários dos departamentos de vendas e engenharia tem este acesso" + PULA_LINHA + PULA_LINHA +;
	"Verifique os parâmetros 'MV_FP_VEN','MV_FP_ENG'", "Sem permissão..." , "STOP" )
	Return
EndIf

PRIVATE nOpca := 0
PRIVATE aCols := {}  
Private	cZB_PEDIDO	:= SZB->ZB_PEDIDO
Private	cZB_ITEMPV	:= SZB->ZB_ITEMPV

dbSelectArea("SZB")
dbSetOrder(1)
SZB->( DbSeek( xFilial( "SZB" ) + cZB_PEDIDO + cZB_ITEMPV ) )

M->ZB_PEDIDO	:= SZB->ZB_PEDIDO
M->ZB_ITEMPV	:= SZB->ZB_ITEMPV
M->ZB_CODLMT	:= SZB->ZB_CODLMT
M->ZB_DENOM		:= SZB->ZB_DENOM
M->ZB_PRODUTO	:= SZB->ZB_PRODUTO
M->ZB_CLIENTE	:= SZB->ZB_CLIENTE
M->ZB_LOJACLI	:= SZB->ZB_LOJACLI
M->ZB_NOMCLI	:= SZB->ZB_NOMCLI
M->ZB_VEND		:= SZB->ZB_VEND
M->ZB_NOMVEN	:= SZB->ZB_NOMVEN
M->ZB_COTACAO	:= SZB->ZB_COTACAO

nSavReg  := RecNo()
Private aTELA[0][0],aGETS[0],aHeader[0],Continua,nUsado:=0
bCampo := {|nCPO| Field(nCPO)}

dbSelectArea("SX3")
dbSeek( "SZB" )
While !EOF() .And. (SX3->x3_arquivo == "SZB" )
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ;
		!AllTrim(x3_campo) $ "ZB_PEDIDO/ZB_ITEMPV/ZB_COTACAO/ZB_CODLMT/ZB_DENOM/ZB_PRODUTO/ZB_CLIENTE/ZB_LOJACLI/ZB_NOMCLI/ZB_VEND/ZB_NOMVEN"
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
	Endif
	dbSkip()
End
nUltRec	:= 0
dbSelectArea("SZB")
While !SZB->( Eof() ) .And. SZB->ZB_FILIAL	== xFilial( "SZB" ) .and. ;
							SZB->ZB_PEDIDO	== cZB_PEDIDO .and. ;
							SZB->ZB_ITEMPV	== cZB_ITEMPV
	nUltRec	:= SZB->( Recno() )
	SZB->( DbSkip() )
EndDo

dbSelectArea("SZB")
SZB->( DbGoTo( nUltRec ) )
While !SZB->( Eof() ) .And. SZB->ZB_FILIAL	== xFilial( "SZB" ) .and. ;
							SZB->ZB_PEDIDO	== cZB_PEDIDO .and. ;
							SZB->ZB_ITEMPV	== cZB_ITEMPV
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
DEFINE MSDIALOG oDlg TITLE OemToAnsi("Fluxo de Pedidos") From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

@ 020,005 SAY OemToAnsi("Pedido") OF oDlg PIXEL
@ 020,045 MSGET M->ZB_PEDIDO Picture "999999" When .F. OF oDlg PIXEL

@ 020,090 SAY OemToAnsi("Item") OF oDlg PIXEL
@ 020,105 MSGET M->ZB_ITEMPV Picture "@!" Valid When .F. OF oDlg PIXEL 

@ 020,135 SAY OemToAnsi("Nº Cotação") OF oDlg PIXEL
@ 020,165 MSGET M->ZB_COTACAO Picture "@!" When .F. OF oDlg PIXEL 

@ 035,005 SAY OemToAnsi("Cód.LMT") OF oDlg PIXEL
@ 035,045 MSGET M->ZB_CODLMT When .F. OF oDlg PIXEL

@ 050,005 SAY OemToAnsi("Denominação") OF oDlg PIXEL
@ 050,045 MSGET M->ZB_DENOM When .F. OF oDlg PIXEL

@ 065,005 SAY OemToAnsi("Produto") OF oDlg PIXEL
@ 065,045 MSGET M->ZB_PRODUTO When .F. OF oDlg PIXEL

@ 080,005 SAY OemToAnsi("Cliente") OF oDlg PIXEL
@ 080,045 MSGET M->ZB_CLIENTE When .F. OF oDlg PIXEL

@ 080,090 SAY OemToAnsi("Loja") OF oDlg PIXEL
@ 080,105 MSGET M->ZB_LOJACLI When .F. OF oDlg PIXEL

@ 080,135 MSGET M->ZB_NOMCLI When .F. OF oDlg PIXEL

@ 095,005 SAY OemToAnsi("Vendedor") OF oDlg PIXEL
@ 095,045 MSGET M->ZB_VEND When .F. OF oDlg PIXEL

@ 095,135 MSGET M->ZB_NOMVEN When .F. OF oDlg PIXEL

oGet := MSGetDados():New(aPosObj[2,1]+70,aPosObj[2,2],aPosObj[2,3]+25,aPosObj[2,4],nOpcx,"AllwaysTrue","AllwaysTrue","+ZB_SEQ",.T.,,2,,1)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()})

If nOpcA == 1

	If	!MsgYesNo( "Apenas o último lançamento será excluído. Confirma?", "ATENÇÃO..." )
		SZB->( DbGoTo( nReg ) )
		Return
	EndIf

	Begin Transaction

		DbSelectArea( "SZB" )
		SZB->( DbSetOrder( 1 ) )
		SZB->( DbGoTo( nUltRec ) )
		While !SZB->( Eof() ) .and.	SZB->ZB_FILIAL	== xFilial( "SZB" ) .and. ;
									SZB->ZB_PEDIDO	== cZB_PEDIDO .and. ;
									SZB->ZB_ITEMPV	== cZB_ITEMPV

			RecLock( "SZB", .F. )
			SZB->( DbDelete() )
			SZB->( MsUnLock() )

			SZB->( DbSkip() )
		EndDo

	End Transaction

EndIf

dbSelectArea("SZB")

Return nOpca

********************************************************************************************************************
User Function FPLINHA( cPasta )
Local	lRetorno	:= .T.
Local	cZB_SEQ		:= aCols[n][GdFieldPos("ZB_SEQ",aHeader)]
Local	dZB_DTENT	:= aCols[n][GdFieldPos("ZB_DTENT",aHeader)]
Local	dZB_DTSAI	:= aCols[n][GdFieldPos("ZB_DTSAI",aHeader)]
Local	cZB_DEPTOOR	:= aCols[n][GdFieldPos("ZB_DEPTOOR",aHeader)]
Local	cZB_DEPTODE	:= aCols[n][GdFieldPos("ZB_DEPTODE",aHeader)]

If		RetCodUsr() $ GetMv( "MV_FP_VEN" ) .and. cPasta == "1"
	If	dZB_DTENT # Posicione( "SC5", 1, xFilial( "SC5" ) + M->ZB_PEDIDO, "C5_EMISSAO" )
		MsgBox( "Data de entrada não pode ser diferente da emissão do pedido que é " +;
		DtoC( Posicione( "SC5", 1, xFilial( "SC5" ) + M->ZB_PEDIDO, "C5_EMISSAO" ) ) , "Inconsistência...", "STOP" )
		aCols[n][GdFieldPos("ZB_DTENT",aHeader)]	:= Posicione( "SC5", 1, xFilial( "SC5" ) + M->ZB_PEDIDO, "C5_EMISSAO" )
		lRetorno	:= .F.
	EndIf
EndIf

If		!Empty( dZB_DTUS ) .and. dZB_DTENT < dZB_DTUS
	MsgBox( "Data de entrada não pode ser inferior a data da última saída que é " + DtoC( dZB_DTUS ), "Inconsistência...", "STOP" )
	aCols[n][GdFieldPos("ZB_DTENT",aHeader)]	:= dZB_DTUS
	lRetorno	:= .F.
ElseIf	dZB_DTENT > dZB_DTSAI .and. !Empty( dZB_DTSAI )
	MsgBox( "Data de entrada não pode ser superior a data de saída.", "Inconsistência...", "STOP" )
	lRetorno	:= .F.
ElseIf	dZB_DTSAI < dZB_DTENT .and. !Empty( dZB_DTSAI )
	MsgBox( "Data de saída não pode ser inferior a data de entrada.", "Inconsistência...", "STOP" )
	lRetorno	:= .F.
ElseIf	Empty( dZB_DTSAI ) .and. !Empty( cZB_DEPTODE )
	MsgBox( "Para informar departamento destino, obrigatório informar data de saída.", "Inconsistência...", "STOP" )
	lRetorno	:= .F.
ElseIf	Empty( cZB_DEPTODE ) .and. !Empty( dZB_DTSAI )
	MsgBox( "Obrigatório informar depto destino qdo informado data de saída.", "Inconsistência...", "STOP" )
	lRetorno	:= .F.
ElseIf	!Empty( cZB_DEPTODE ) .and. Empty( dZB_DTSAI )
	MsgBox( "Não é permitido informar depto destino senão informar data de saída.", "Inconsistência...", "STOP" )
	lRetorno	:= .F.
ElseIf	cZB_DEPTODE == cZB_DEPTOOR
	MsgBox( "Não é permitido informar depto destino igual ao depto que esta fazendo atualizações.", "Inconsistência...", "STOP" )
	lRetorno	:= .F.
EndIf

If	cPasta == '2'
	cZB_STATUS	:= aCols[n][GdFieldPos("ZB_STATUS",aHeader)]
	dZB_DTAPR	:= aCols[n][GdFieldPos("ZB_DTAPR",aHeader)]
	If		dZB_DTENT < dZB_DTUS
		MsgBox( "Data de entrada não pode ser inferior a data da última saída que é " + DtoC( dZB_DTUS ), "Inconsistência...", "STOP" )
		lRetorno	:= .F.
	EndIf

	If	!Empty( cZB_STATUS )
		If		cZB_STATUS == "P" .and. !Empty( dZB_DTAPR )
			MsgBox( "Só informar data de aprovação quando status for APROVADO.", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		ElseIf	cZB_STATUS == "A" .and. Empty( dZB_DTAPR )
			MsgBox( "Status APROVADO, obrigatório informar data de aprovação.", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf
	EndIf

	If	!Empty( dZB_DTAPR )
		If		Empty( cZB_STATUS )
			MsgBox( "Só informar data de aprovação quando status for APROVADO.", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		ElseIf	dZB_DTAPR < dZB_DTENT
			MsgBox( "Data de aprovação deve ser superior a data de entrada.", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf
	EndIf
	
	If	!Empty( dZB_DTSAI )
		If		dZB_DTSAI < dZB_DTAPR
			MsgBox( "Data de saída deve ser superior a data de aprovação.", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf
	EndIf		

EndIf

If	cPasta == "3"
	cZB_TIPFAB	:= aCols[n][GdFieldPos("ZB_TIPFAB",aHeader)]
	cZB_FORNEC	:= aCols[n][GdFieldPos("ZB_FORNEC",aHeader)]
	cZB_OP		:= aCols[n][GdFieldPos("ZB_OP",aHeader)]

	If		dZB_DTENT < dZB_DTUS
		MsgBox( "Data de entrada não pode ser inferior a data da última saída que é " + DtoC( dZB_DTUS ), "Inconsistência...", "STOP" )
		lRetorno	:= .F.
	EndIf

	If		Empty( cZB_TIPFAB ) .and. !Empty( cZB_FORNEC )
		MsgBox( "Só informar fornecedor se tipo de fabricação for EXTERNA.", "Inconsistência...", "STOP" )
		lRetorno	:= .F.
	EndIf
	
	If	!Empty( cZB_TIPFAB )
		If		cZB_TIPFAB == "E" .and. Empty( cZB_FORNEC )
			MsgBox( "Tipo de fabricação EXTERNA, obrigatório informar fornecedor.", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		ElseIf	cZB_TIPFAB == "I" .and. !Empty( cZB_FORNEC )
			MsgBox( "Tipo de fabricação INTERNA, não pode informar fornecedor.", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf
	EndIf

	If	Empty( cZB_OP ) .and. !Empty( cZB_DEPTODE )
		MsgBox( "Direcionamento impossível. Não foi gerado OP para este ítem.", "Inconsistência...", "STOP" )
		lRetorno	:= .F.
	EndIf

EndIf

If	cPasta == "5"
	dZB_DTISM	:= aCols[n][GdFieldPos("ZB_DTISM",aHeader)]
	dZB_DTFSM	:= aCols[n][GdFieldPos("ZB_DTFSM",aHeader)]
	dZB_DTENV	:= aCols[n][GdFieldPos("ZB_DTENV",aHeader)]
	dZB_DTRET	:= aCols[n][GdFieldPos("ZB_DTRET",aHeader)]

	If		!Empty( dZB_DTISM )
		If	dZB_DTISM < dZB_DTENT .and. !Empty( dZB_DTENT )
			MsgBox( "Data de início da separação de materiais não pode ser inferior a data de entrada", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf
	EndIf

	If	!Empty( dZB_DTFSM )
		If	dZB_DTFSM < dZB_DTISM .and. !Empty( dZB_DTISM )
			MsgBox( "Data final da separação de materiais não pode ser inferior a data inicial da separação de materiais", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf
	EndIf

	If	!Empty( dZB_DTENV )
		If	dZB_DTENV < dZB_DTFSM .and. !Empty( dZB_DTFSM )
			MsgBox( "Data de envio não pode ser inferior a data final da separação de materiais.", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf
		If	dZB_DTENV < dZB_DTISM .and. !Empty( dZB_DTISM )
			MsgBox( "Data de envio não pode ser inferior a data inicial da separação de materiais.", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf
	EndIf
	
	If	!Empty( dZB_DTRET )
		If	dZB_DTRET < dZB_DTENV .and. !Empty( dZB_DTENV )
			MsgBox( "Data de retorno não pode ser inferior a data de envio.", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf
		If	dZB_DTRET < dZB_DTFSM .and. !Empty( dZB_DTFSM )
			MsgBox( "Data de retorno não pode ser inferior a data final da separação de materiais", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf
		If	dZB_DTRET < dZB_DTISM .and. !Empty( dZB_DTISM )
			MsgBox( "Data de retorno não pode ser inferior a data inicial da separação de materiais", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf
	EndIf
	
	If	!Empty( dZB_DTSAI )
		If	dZB_DTSAI < dZB_DTRET .and. !Empty( dZB_DTRET )
			MsgBox( "Data de saída não pode ser inferior a data do último retorno", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf
		If	dZB_DTSAI < dZB_DTENV .and. !Empty( dZB_DTENV )
			MsgBox( "Data de saída não pode ser inferior a data de envio", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf
		If	dZB_DTSAI < dZB_DTFSM .and. !Empty( dZB_DTFSM )
			MsgBox( "Data de saída não pode ser inferior a data final de separação de materiais", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf
		If	dZB_DTSAI < dZB_DTISM .and. !Empty( dZB_DTISM )
			MsgBox( "Data de saída não pode ser inferior a data inicial da separação de materiais", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf
	EndIf

EndIf

If	cPasta == "6" .or. cPasta == "8"
	cZB_APROV	:= aCols[n][GdFieldPos("ZB_APROV",aHeader)]

//	If	cZB_APROV # "S" .and. !Empty( dZB_DTSAI )
//		MsgBox( "Só pode informar data de saída se APROVADO = 'Sim'", "Inconsistência...", "STOP" )
//		lRetorno	:= .F.
//	EndIf

	If	cZB_APROV == "S" .and. Empty( dZB_DTSAI )
		MsgBox( "Obrigatório informar data de saída quando APROVADO = 'Sim'", "Inconsistência...", "STOP" )
		lRetorno	:= .F.
	EndIf

EndIf

If	cPasta == "7"
	cZB_TEMBF	:= aCols[n][GdFieldPos("ZB_TEMBF",aHeader)]
	cZB_FORNEC	:= aCols[n][GdFieldPos("ZB_FORNEC",aHeader)]
	dZB_DTENV	:= aCols[n][GdFieldPos("ZB_DTENV",aHeader)]
	dZB_DTRET	:= aCols[n][GdFieldPos("ZB_DTRET",aHeader)]

	If	cZB_TEMBF == "S" .and. Empty( cZB_FORNEC )
		MsgBox( "Por ter sido informado que tem BF, obrigatório informar fornecedor.", "Inconsistência...", "STOP" )
		lRetorno	:= .F.
	EndIf

	If	!Empty( cZB_FORNEC )

		If	Empty( cZB_TEMBF ) .or. cZB_TEMBF == "N"
			MsgBox( "Só pode informar fornecedor se possuir BF", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf

		If	Empty( dZB_DTENV )
			MsgBox( "Não informado data de envio", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf

	EndIf

	If	!Empty( dZB_DTENV )

		If	Empty( cZB_FORNEC )
			MsgBox( "Só pode informar data de envio se informado fornecedor", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf

		If	dZB_DTENV < dZB_DTENT
			MsgBox( "Data de envio não pode ser inferior a data de entrada", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf

	EndIf

	If	!Empty( dZB_DTRET )

		If	Empty( cZB_FORNEC )
			MsgBox( "Só pode informar data de retorno se informado fornecedor", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf

		If	dZB_DTRET < dZB_DTENV .and. !Empty( dZB_DTENV )
			MsgBox( "Data de retorno não pode ser inferior a data de envio", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf

		If	Empty( dZB_DTENV )
			MsgBox( "Não informado data de envio", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf

	EndIf

	If	!Empty( dZB_DTSAI )

		If	dZB_DTSAI < dZB_DTRET .and. !Empty( dZB_DTRET )
			MsgBox( "Data de saída não pode ser inferior a data de retorno", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf

		If	dZB_DTSAI < dZB_DTENV .and. !Empty( dZB_DTENV )
			MsgBox( "Data de saída não pode ser inferior a data de envio", "Inconsistência...", "STOP" )
			lRetorno	:= .F.
		EndIf

	EndIf

EndIf

If	cPasta == "9"
	cZB_OP		:= aCols[n][GdFieldPos("ZB_OP",aHeader)]

	If	!Empty( dZB_DTSAI )

		If	Empty( cZB_OP )
			MsgBox( "Não foi aberto OP para este item.", "Inconsistência...", "STOP" )
			aCols[n][GdFieldPos("ZB_DTSAI",aHeader)]	:= CriaVar( "ZB_DTSAI" )
			aCols[n][GdFieldPos("ZB_DEPTODE",aHeader)]	:= CriaVar( "ZB_DEPTODE" )
			lRetorno	:= .F.
		EndIf

		lProducao	:= .F.
		SD3->( DbSeek( xFilial( "SD3" ) + cZB_OP ) )
		While !SD3->( Eof() ) .and. SD3->D3_FILIAL	== xFilial( "SD3" ) .and. ;
									Left( SD3->D3_OP , Len( AllTrim( cZB_OP ) ) ) == cZB_OP
			If	AllTrim( SD3->D3_CF ) == "PR0"
				lProducao	:= .T.
				Exit
			EndIf
			
			SD3->( DbSkip() )
		EndDo
		
		If	!lProducao .and. 1=2
			MsgBox( "Não foi apontado produção para este ítem.", "Inconsistência...", "STOP" )
			aCols[n][GdFieldPos("ZB_DTSAI",aHeader)]	:= CriaVar( "ZB_DTSAI" )
			aCols[n][GdFieldPos("ZB_DEPTODE",aHeader)]	:= CriaVar( "ZB_DEPTODE" )
			lRetorno	:= .F.
		EndIf

	EndIf

EndIf

If	cPasta == "A"
	cZB_NOTA	:= aCols[n][GdFieldPos("ZB_NOTA",aHeader)]

	If	!Empty( dZB_DTSAI )

		If	Empty( cZB_NOTA )
			MsgBox( "Não foi gerado nota fiscal para este item.", "Inconsistência...", "STOP" )
			aCols[n][GdFieldPos("ZB_DTSAI",aHeader)]	:= CriaVar( "ZB_DTSAI" )
			aCols[n][GdFieldPos("ZB_DEPTODE",aHeader)]	:= CriaVar( "ZB_DEPTODE" )
			lRetorno	:= .F.
		EndIf

	EndIf

EndIf

Return( lRetorno )

********************************************************************************************************************
Static Function FP1()

SC6->( DbSetOrder( 1 ) )
If		Upper( AllTrim( ReadVar() ) ) == "M->ZB_PEDIDO"
	SC6->( DbSeek( xFilial( "SC6" ) + M->ZB_PEDIDO ) )
	M->ZB_ITEMPV	:= SC6->C6_ITEM
ElseIf	Upper( AllTrim( ReadVar() ) ) == "M->ZB_ITEMPV"
	SC6->( DbSeek( xFilial( "SC6" ) + M->ZB_PEDIDO + M->ZB_ITEMPV ) )

	If	SC6->C6_QTDENT >= SC6->C6_QTDVEN .and. 1=2
		MsgBox( "Item do pedido já faturamento 100%", "", "STOP" )
		Return( .F. )
	EndIf

EndIf

M->ZB_CODLMT	:= SC6->C6_CODLMT
M->ZB_DENOM		:= Posicione( "SB1", 1, xFilial( "SB1" ) + SC6->C6_PRODUTO, "B1_DENOM" )
M->ZB_PRODUTO	:= SC6->C6_PRODUTO
M->ZB_CLIENTE	:= SC6->C6_CLI
M->ZB_LOJACLI	:= SC6->C6_LOJA
M->ZB_NOMCLI	:= Posicione( "SA1", 1, xFilial( "SA1" ) + SC6->( C6_CLI + C6_LOJA ), "A1_NREDUZ" )
M->ZB_VEND		:= Posicione( "SC5", 1, xFilial( "SC5" ) + SC6->C6_NUM, "C5_VEND1" )
M->ZB_NOMVEN	:= Posicione( "SA3", 1, xFilial( "SA3" ) + SC5->C5_VEND1, "A3_NREDUZ" )

aCols[1,3]		:= Posicione( "SC5", 1, xFilial( "SC5" ) + SC6->C6_NUM, "C5_EMISSAO" )

Return( .T. )
