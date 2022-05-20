#include 'fivewin.ch'
#include 'tbiconn.ch'
#include 'topconn.ch'    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CHAMUS   บAutor ณLuis Henrique Robustoบ Data ณ  07/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ CONTROLE DE CHAMADOS...                                    บฑฑ
ฑฑบ          ณ Controla os chamados, inclui, altera, exclui, e verifica   บฑฑ
ฑฑบ          ณ os andamentos de chamados...                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ RASS CONSULTORIA                                           บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ  MOTIVO                                         บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

#define CHR_LINE				'<hr>'
#define CHR_CENTER_OPEN			'<div align="center" >'
#define CHR_CENTER_CLOSE   		'</div>'
#define CHR_FONT_DET_OPEN		'<font face="Courier New" size="2">'
#define CHR_FONT_DET_CLOSE		'</font>'
#define CHR_ENTER				'<br>'
#define CHR_NEGRITO				'<b>'
#define CHR_NOTNEGRITO			'</b>'

User Function CHAMUS()
Private	_cEmpUso  	:= AllTrim(cEmpAnt)+"/",;
		_cPerg    	:= "CHAMUS",;
		_bFiltraBrw	:= ''
		_aIndexSZT 	:= {}
		_cFiltro  	:= ''

Private	cCadastro 	:= OemToAnsi('Controle de Chamados'),;
		cAlias	  	:= 'SZT',;
		aCores    	:= {{ "SZT->ZT_STATUS=='0'", 'ENABLE' },; // Aberto
						{ "SZT->ZT_STATUS=='8'", 'BR_PRETO'},; // Cancelado
						{ "SZT->ZT_STATUS=='9'", 'DISABLE'},; // Encerrado
						{ "SZT->ZT_STATUS=='1'", 'BR_AMARELO'} },;// Em analise
		aRotina   	:= {{ 'Pesquisar','AxPesqui',0,1},;
		               	{ 'Visualizar','U_CHAMEdit',0,2},;
        		       	{ 'Incluir','U_CHAMEdit',0,3},;
		               	{ 'Alterar','U_CHAMEdit',0,4},;
		               	{ 'Excluir','U_CHAMEdit',0,5},;
		               	{ 'Ence&rrar','U_CHAMEdit',0,6},;
		               	{ '&Cancelar','U_CHAMCan',0,7},;
		               	{ 'Im&primir','U_CHAMPRINT',0,9},;
		               	{ 'Legenda','U_CHAMLeng',0,8}}

		DbSelectArea(cAlias)
		(cAlias)->(DbSetOrder(1))
		(cAlias)->(DbGoTop())

		If	( cNivel < 8 ) // Caso nao seja Usuario Superior 
			If	! ( AllTrim(cModulo) $ "ATF|" ) // Caso o modulo nao seja Ativo Fixo
				_cFiltro := "SZT->ZT_SOLCHAM == __cUserId" // Filtra, mostrando somente os chamados do usuario.
			Else
				_cFiltro := "_cEmpUso $ SZT->ZT_EMPCHAM" // Filtra, mostrando os dados de todos os usuarios, mas somente da mesma empresa.
			EndIf
		Else
			AjustaSx1(_cPerg) // ajusta os parametros da rotina.
			If	! Pergunte(_cPerg,.T.) // Faz as perguntas ao usuario.
				Return .f.
			Else
				// Monta o filtro de acordo com os parametros selecionados.
				If	( mv_par01 == 1 ) // Pendentes
					_cFiltro := "(AllTrim(SZT->ZT_STATUS)='0' .or. AllTrim(SZT->ZT_STATUS)='1') "
				ElseIf	( mv_par01 == 2 ) // Em analise
					_cFiltro := "AllTrim(SZT->ZT_STATUS)='1'"
				ElseIf	( mv_par01 == 3 ) // Encerrados
					_cFiltro := "AllTrim(SZT->ZT_STATUS)='9'"
				ElseIf	( mv_par01 == 4 ) // Cancelados
					_cFiltro := "AllTrim(SZT->ZT_STATUS)='8'"
				Else
					_cFiltro := "AllTrim(SZT->ZT_STATUS)$'0/1/8/9'"
				EndIf
				If	( mv_par02 == 1 ) // Alto
					_cFiltro += " .AND. AllTrim(SZT->ZT_PRICHAM)='A'"
				ElseIf	( mv_par02 == 2 ) // Normal
					_cFiltro += " .AND. AllTrim(SZT->ZT_PRICHAM)='N'"
				ElseIf	( mv_par02 == 3 ) // Baixa
					_cFiltro += " .AND. AllTrim(SZT->ZT_PRICHAM)='B'"
				Else
					_cFiltro += " .AND. AllTrim(SZT->ZT_PRICHAM)$'A/B/N'"
				EndIf
				_cFiltro += " .AND. SZT->ZT_PROGRAM >= '" + mv_par03 + "' .AND. SZT->ZT_PROGRAM <= '" + mv_par04 + "' "
				If	( mv_par05 == 1 ) // Filtra por Tecnico /1=Sim,2=Nao
					_cFiltro += " .AND. ( (SZT->ZT_SOLCHAM == __cUserId) .or. (SZT->ZT_TECALOC == __cUserId) .or. (SZT->ZT_TECNICO == __cUserId) ) "
				EndIf
				If	( ! Empty(mv_par06) )
					_cFiltro += " .AND. ( AllTrim(Upper(mv_par06)) $ Upper(SZT->ZT_DESC) .or. AllTrim(Upper(mv_par06)) $ Upper(SZT->ZT_OCORREN) ) "
				EndIf
			EndIf
		EndIf

		If	! Empty(_cFiltro)
			_bFiltraBrw := {|| FilBrowse("SZT",@_aIndexSZT,@_cFiltro) }
			Eval(_bFiltraBrw)
		EndIf

		mBrowse(6,1,22,75,'SZT',,,,,,aCores)

		EndFilBrw("SZT",_aIndexSZT)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณxChamados บAutor ณLuis Henrique Robustoบ Data ณ  07/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Chamados...                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao Principal                                           บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ  MOTIVO                                         บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function CHAMEdit( cAlias, nReg, nOpcion )
Local	oWindow,;
		oFontWin,;
		aFolders	:= {},;
		aHead		:= {},;
		bOk 		:= "{ || Iif(Iif(nOpcao<>6,!Empty(cDesCham).and.!Empty(cTipCham).and.!Empty(cPriCham),!Empty(cDesCham).and.!Empty(cTipCham).and.!Empty(cPriCham).and.!Empty(cClasFech)),(lSave:=.t.,oWindow:End()),Nil) }",;
		bCancel 	:= "{ || lSave:=.f. , oWindow:End() }",;
		aButtons	:= {},;
		_cMsgCic	:= '',;
		cTitWin

Private	nRegSM0		:= SM0->(Recno())

Private	cNumCham	:= "00000001",;
		cDesCham	:= Space(80),;
		dDtAbert	:= dDataBase,;
		dHrAbert	:= Time(),;
		cSolCham	:= __cUserId,;
		cEmpCham	:= cEmpAnt+'/'+cFilAnt,;
		cTipCham	:= Space(4),;
		cPriCham 	:= Space(4),;
		cModCham	:= cModulo,;
		cProgCham	:= Space(15),;
		mAberOcor,;
		oAberOcor,;
		mSoluOcor,;
		oSoluOcor,;
		mComentar,;
		oComentar,;
		dDtFecha	:= Ctod('  /  /  '),;
		dHrFecha	:= '  :  :  ',;
		cTecCham	:= Space(6),;
		cClasFech	:= Space(4),;
		cTecAloc	:= Space(6)

Private	nOpcao 		:= nOpcion,;		// Numero da opcao selecionada..
		lSave		:= .f.,;			// Variavel controla se tem ou nao que salvar.
		lEdite		:= .f.				// Controla se edita ou nao os dados.

Private	_oTipCham,;
		_cTipCham	:= Space(20),;
		_oPriCham,;
		_cPriCham	:= Space(20),;
		_oSolCham,;
		_cSolCham	:= Space(20),;
		_oEmpCham,;
		_cEmpCham	:= Space(20),;
		_oTecAloc,;
		_cTecAloc	:= Space(20),;
		_oTecCham,;
		_cMailTec,;
		_cTecCham	:= Space(20),;
		_oClasFech,;
		_cClasFech	:= Space(20),;
		_oModulo,;
		_oModCham,;
		_oPrograma,;
		_oProgCham,;
		oRadio,;
		nRadio 		:= 1

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se o chamado esta cancelado.!ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If	( nOpcao <> 3 ) .and. ( SZT->ZT_STATUS == '8' )
			Return
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica qual o titulo sera colocado na janela.!ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If	( nOpcao == 3 ) // Incluir
			cTitWin := 'Incluir'
		ElseIf	( nOpcao == 4 ) // Alterar
			cTitWin := 'Alterar'
		ElseIf	( nOpcao == 5 ) // Excluir
			cTitWin := 'Excluir'
		ElseIf	( nOpcao == 2 ) // Visualizar
			cTitWin := 'Visualizar'
		ElseIf	( nOpcao == 6 ) // Encerrar
			cTitWin := 'Encerrar'
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAutoriza a editar os "edites"ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If	( cNivel >= 8 ) .or. ( AllTrim(cModulo) $ "ATF|" )
			lEdite := .t.
		EndIf

		If	( cNivel < 8 )
			If	( nOpcao == 4 ) .or. ( nOpcao == 5 ) .or. ( nOpcao == 6 )
				Help('',1,'CHAMUS',,OemToAnsi('Voc๊ nใo tem permissใo para '+cTitWin+'.'),1)
				Return
			EndIf
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se o usuario pode alterar !ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If	( nOpcao==4 ) .and. ( ! Empty(SZT->ZT_TECNICO) )
			Help('',1,'CHAMUS',,OemToAnsi('Este chamado jแ foi encerrado.'),1)
			Return
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se o usuario pode alterar !ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If	( nOpcao==5 ) .and. ( ! Empty(SZT->ZT_TECNICO) .or. ! Empty(SZT->ZT_TECALOC) ) 
			Help('',1,'CHAMUS',,OemToAnsi('Este chamado jแ foi encerrado.'),1)
			Return
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAtualiza os dados.!ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If	( nOpcao <> 3 )
			cNumCham	:= SZT->ZT_NUMCHAM
			cEmpCham	:= SZT->ZT_EMPCHAM
			cSolCham	:= SZT->ZT_SOLCHAM
			cPriCham	:= SZT->ZT_PRICHAM
			cDesCham	:= SZT->ZT_DESC
			cTipCham	:= SZT->ZT_TIPO
			cModCham	:= SZT->ZT_MODULO
			cProgCham	:= SZT->ZT_PROGRAM
			dDtAbert	:= SZT->ZT_DTABERT
			dHrAbert	:= SZT->ZT_HRABERT
			mAberOcor	:= SZT->ZT_OCORREN
			cTecAloc	:= SZT->ZT_TECALOC
			mComentar	:= SZT->ZT_COMENTA
			dDtFecha	:= SZT->ZT_DTFECHA
			dHrFecha	:= SZT->ZT_HRFECHA
			cTecCham	:= SZT->ZT_TECNICO
			cClasFech	:= SZT->ZT_CLASSIF
			mSoluOcor	:= SZT->ZT_SOLUCAO
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณQuando estiver alterando o Chamado.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If	( nOpcao == 4 ) .and. Empty(cTecAloc)
				cTecAloc := __cUserId // Atualiza o Tecnico Alocado
			EndIf
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณQuando estiver ENCERRANDOณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If	( nOpcao == 6 ) .and. Empty(cTecCham)
				dDtFecha	:= dDataBase
				dHrFecha	:= Time()
				cTecCham	:= __cUserId
			EndIf
		Else
			cNumCham	:= GetSx8Num('SZT','ZC_NUMCHAM')
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณMonta a janela de interacao com o usuario. !ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DEFINE MSDIALOG oWindow FROM 38,16 TO 550,531 TITLE Alltrim(OemToAnsi('Chamados - Ocorr๊ncias ['+cTitWin+']')) Pixel //430,531 
		DEFINE FONT oFontWin NAME 'Arial' SIZE 6, 15 BOLD
		DEFINE FONT oFontMemo NAME 'Courier New' SIZE 0,15
		@ 015, 005 To 050, 255 Label OemToAnsi('Controle de Chamados') Of oWindow Pixel
		@ 023, 011 Say OemToAnsi('Chamado') Size 023, 007 Of oWindow Pixel
		@ 033, 011 MsGet cNumCham Size 017, 010 When .F. Font oFontWin Of oWindow Pixel
		@ 023, 050 Say OemToAnsi('Descri็ใo') Size 028, 007 Of oWindow Pixel
		@ 033, 050 MsGet cDesCham Size 200, 010 Picture ('@!') When nOpcao<>5.and.nOpcao<>2 Valid TEXTO() Of oWindow Pixel

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณDefine os Folders.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aAdd(aFolders,OemToAnsi('&Informa็๕es'))
		aAdd(aHead,'HEADER 1')
		aAdd(aFolders,OemToAnsi('&Abertura'))
		aAdd(aHead,'HEADER 2')
		If	( nOpcao == 2 ) .or. ( nOpcao == 4 ) .or. ( nOpcao == 5 ) .or. ( nOpcao == 6 )
			aAdd(aFolders,OemToAnsi('&Comentแrios T้cnicos'))
			aAdd(aHead,'HEADER 3')
		EndIf
		If	( nOpcao == 2 ) .or. ( nOpcao == 6 ) .or. ( nOpcao == 5 )
			aAdd(aFolders,OemToAnsi('&Encerramento'))
			aAdd(aHead,'HEADER 4')
		EndIf	
		oFolder := TFolder():New(055,005,aFolders,aHead,oWindow,,,,.T.,.F.,250,192)
		For nx:=1 to Len(aFolders)
			DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder:aDialogs[nx]
		Next nx

		//ฺฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณInformacoesณ
		//ภฤฤฤฤฤฤฤฤฤฤฤู
		@ 005, 005 Say OemToAnsi('Tipo:') Size 025, 007 Of oFolder:aDialogs[1] Pixel
		@ 005, 040 MsGet cTipCham Size 035, 010 F3 'ZO ' Valid xValid(1) When nOpcao<>5.and.nOpcao<>2 Of oFolder:aDialogs[1] Pixel
		@ 005, 083 Say _oTipCham Var _cTipCham Font oFontWin Of oFolder:aDialogs[1] Pixel
		@ 017, 005 Say OemToAnsi('Prioridade:') Size 025, 007 Of oFolder:aDialogs[1] Pixel
		@ 017, 040 MsGet cPriCham Size 035, 010 F3 'ZP ' Valid xValid(2) When nOpcao<>5.and.nOpcao<>2 Of oFolder:aDialogs[1] Pixel
		@ 017, 083 Say _oPriCham Var _cPriCham Font oFontWin Of oFolder:aDialogs[1] Pixel
		@ 029, 005 Say _oModulo Var OemToAnsi('M๓dulo:') Size 025, 007 Of oFolder:aDialogs[1] Pixel
		@ 029, 040 MsGet _oModCham Var cModCham Size 035, 010 When .f. Of oFolder:aDialogs[1] Pixel
		@ 041, 005 Say _oPrograma Var OemToAnsi('Programa:') Size 025, 007 Of oFolder:aDialogs[1] Pixel
		@ 041, 040 MsGet _oProgCham Var cProgCham Size 060, 010 When nOpcao<>5.and.nOpcao<>2 Of oFolder:aDialogs[1] Pixel
		If	( Empty(dDtFecha) )
			@ 095, 005 Say OemToAnsi('Dias em atraso:') Size 040, 007 Of oFolder:aDialogs[1] Pixel
			@ 095, 055 Say TransForm(dDataBase-dDtAbert,'@R 9999') Size 060, 010 Of oFolder:aDialogs[1] Pixel
		EndIf
		_oModulo:lVisible := .f.
		_oModCham:lVisible := .f.
		_oPrograma:lVisible := .f.
		_oProgCham:lVisible := .f.

		//ฺฤฤฤฤฤฤฤฤฟ
		//ณAberturaณ
		//ภฤฤฤฤฤฤฤฤู
		@ 005, 005 Say OemToAnsi('Data/Hora:') Size 025, 007 Of oFolder:aDialogs[2] Pixel
		@ 005, 040 MsGet dDtAbert Size 035, 010 When .f. Of oFolder:aDialogs[2] Pixel
		@ 005, 080 MsGet dHrAbert Size 035, 010 When .f. Of oFolder:aDialogs[2] Pixel
		@ 017, 005 Say OemToAnsi('Solicitante:') Size 025, 007 Of oFolder:aDialogs[2] Pixel
		@ 017, 040 MsGet cSolCham Size 035, 010 F3 'USR' Valid xValid(3) When lEdite .and. nOpcao<>5.and.nOpcao<>2 Of oFolder:aDialogs[2] Pixel
		@ 017, 083 Say _oSolCham Var _cSolCham Font oFontWin Of oFolder:aDialogs[2] Pixel
		xValid(3) // Atualiza os Solicitantes
		@ 029, 005 Say OemToAnsi('Empresa:') Size 025, 007 Of oFolder:aDialogs[2] Pixel
		@ 029, 040 MsGet cEmpCham Size 035, 010 When .f. Of oFolder:aDialogs[2] Pixel
		@ 029, 083 Say _oEmpCham Var _cEmpCham Font oFontWin Of oFolder:aDialogs[2] Pixel
		xValid(4) // Atualiza a empresa/filial
		@ 041, 005 Say OemToAnsi('Ocorr๊ncia:') Size 028, 007 Of oFolder:aDialogs[2] Pixel
		@ 041, 040 Get oAberOcor Var mAberOcor Memo When nOpcao<>5.and.nOpcao<>2 Size 200, 112 Of oFolder:aDialogs[2] Pixel
		oAberOcor:oFont:=oFontMemo
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณComentariosณ
		//ภฤฤฤฤฤฤฤฤฤฤฤู
		If	( nOpcao == 2 ) .or. ( nOpcao == 4 ) .or. ( nOpcao == 5 ) .or. ( nOpcao == 6 )
			@ 005, 005 Say OemToAnsi('T้c.Alocado:') Size 030, 007 Of oFolder:aDialogs[3] Pixel
			@ 005, 040 MsGet cTecAloc Size 035, 010 F3 'USR' Valid xValid(5) When lEdite .and. nOpcao<>5.and.nOpcao<>2 Of oFolder:aDialogs[3] Pixel
			@ 005, 083 Say _oTecAloc Var _cTecAloc Font oFontWin Of oFolder:aDialogs[3] Pixel
			If	( nOpcao <> 2 ) .and. ( nOpcao <> 5 )
				xValid(5) // Atualiza o Alocado
			EndIf	
			@ 017, 005 Say OemToAnsi('Comentแrios:') Size 030, 007 Of oFolder:aDialogs[3] Pixel
			@ 017, 040 Get oComentar Var mComentar Memo When nOpcao<>5.and.nOpcao<>2 Size 200, 132 Of oFolder:aDialogs[3] Pixel
			oComentar:oFont:=oFontMemo
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณEncerramentoณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤู
		If	( nOpcao == 2 ) .or. ( nOpcao == 5 ) .or. ( nOpcao == 6 )
			@ 005, 005 Say OemToAnsi('Data/Hora:') Size 025, 007 Of oFolder:aDialogs[4] Pixel
			@ 005, 040 MsGet dDtFecha Size 035, 010 When .f. Of oFolder:aDialogs[4] Pixel
			@ 005, 080 MsGet dHrFecha Size 035, 010 When .f. Of oFolder:aDialogs[4] Pixel
			@ 017, 005 Say OemToAnsi('T้cnico:') Size 025, 007 Of oFolder:aDialogs[4] Pixel
			@ 017, 040 MsGet cTecCham Size 035, 010 F3 'USR' Valid xValid(6) When lEdite .and. nOpcao<>5.and.nOpcao<>2 Of oFolder:aDialogs[4] Pixel
			@ 017, 083 Say _oTecCham Var _cTecCham Font oFontWin Of oFolder:aDialogs[4] Pixel
			xValid(6) // Atualiza o Tecnico
			@ 029, 005 Say OemToAnsi('Classif.') Size 025, 007 Of oFolder:aDialogs[4] Pixel
			@ 029, 040 MsGet cClasFech Size 035, 010 F3 'ZQ ' Valid xValid(7) When nOpcao<>5.and.nOpcao<>2 Of oFolder:aDialogs[4] Pixel
			@ 029, 083 Say _oClasFech Var _cClasFech Font oFontWin Of oFolder:aDialogs[4] Pixel
			@ 041, 005 Say OemToAnsi('Solu็ใo:') Size 028, 007 Of oFolder:aDialogs[4] Pixel
			@ 041, 040 Get oSoluOcor Var mSoluOcor Memo When nOpcao<>5.and.nOpcao<>2 Size 200, 100 Of oFolder:aDialogs[4] Pixel
			oSoluOcor:oFont:=oFontMemo
			@ 145, 005 Say OemToAnsi('Env. Resp.:') Size 030, 007 Of oFolder:aDialogs[4] Pixel
			@ 145, 040 Radio oRadio Var nRadio When lEdite.and.nOpcao<>5.and.nOpcao<>2 Size 090,007 Of oFolder:aDialogs[4] Pixel Prompt OemToAnsi('Nใo enviar'),OemToAnsi('CIC (Comunicador Intrachat)'),OemToAnsi('E-Mail do Solicitante')
		EndIf

		If	( nOpcao <> 3 )
			xValid(1)
			xValid(2)
			If	( nOpcao == 2 ) .or. ( nOpcao == 5 ) .or. ( nOpcao == 6 )
				xValid(7)
			EndIf
		EndIf
		ACTIVATE MSDIALOG oWindow CENTERED ON INIT EnchoiceBar(oWindow,&(bOk),&(bCancel),,aButtons)

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณExecuta o processo de gravacao dos dados. !ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If	( lSave )
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSalva os dados...ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If	( nOpcao <> 2 )
				MsgRun(OemToAnsi('Gerando o Chamado.... Aguarde....'),'',{|| CursorWait(), xGravaDados() ,CursorArrow()})
			EndIf
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณEnvia as mensagens de "ENCERRAMENTO"ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If	( nOpcao == 6 ) // ENCERRAR
				If	( nRadio == 2 ) // CIC
					_cMsgCic += Chr(10)+Chr(13)
					_cMsgCic += 'O Chamado ' + cNumCham 
					_cMsgCic += Chr(10)+Chr(13)+Chr(10)+Chr(13)
					_cMsgCic += AllTrim(cDesCham)
					_cMsgCic += Chr(10)+Chr(13)
					_cMsgCic += 'Foi Encerrado...'+Chr(10)+Chr(13)
					_cMsgCic += AllTrim(Substr(mSoluOcor,1,300)) + '...'
					U_SENDCIC(AllTrim(Upper(UsrRetName(cSolCham))),OemToAnsi(_cMsgCic))
				ElseIf	( nRadio == 3 ) // E-MAIL
					WfAvisaCham(UsrRetMail(cSolCham))
				EndIf
			EndIf
		Else
			If	( nOpcao == 3 )
				RollBackSx8()
			EndIf
		EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CHAMCan  บAutor ณLuis Henrique Robustoบ Data ณ  09/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para cancelar o chamado.                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao Principal                                           บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ MOTIVO                                          บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function CHAMCan()

	If	( SZT->ZT_STATUS == '0' )
		If	MsgYesNo(OemToAnsi('Deseja cancelar realmente este chamado ?'))
			If	RecLock('SZT',.F.)
				Replace SZT->ZT_STATUS	With '8'
				MsUnLock()
			Else
				Help('',1,'REGNOIS')
			EndIf
		EndIf
	Else
		Help('',1,'CHAMUS',,OemToAnsi('Este chamado nใo pode ser cancelado.'),1)
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณxGravaDadosบAutorณLuis Henrique Robustoบ Data ณ  07/02/05   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida os dados digitados...                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao Principal                                           บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ  MOTIVO                                         บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function xGravaDados()

	If	RecLock('SZT',Iif(nOpcao==3,.t.,.f.))
		If	( nOpcao == 5 )
			DbDelete()
		Else
			Replace SZT->ZT_NUMCHAM		With cNumCham
			Replace SZT->ZT_EMPCHAM		With cEmpCham
			Replace SZT->ZT_SOLCHAM		With cSolCham
			Replace SZT->ZT_PRICHAM		With cPriCham
			Replace SZT->ZT_DESC		With cDesCham
			Replace SZT->ZT_TIPO		With cTipCham
			If	( AllTrim(cTipCham) == '001' )
				Replace SZT->ZT_MODULO	With cModCham
				Replace SZT->ZT_PROGRAM	With cProgCham
			Else
				Replace SZT->ZT_MODULO	With Space(3)
				Replace SZT->ZT_PROGRAM	With Space(15)
			EndIf
			Replace SZT->ZT_DTABERT		With dDtAbert
			Replace SZT->ZT_HRABERT		With dHrAbert
			Replace SZT->ZT_OCORREN		With mAberOcor
			Replace SZT->ZT_TECALOC		With cTecAloc
			If	( Empty(cTecAloc) ) .and. ( ! Empty(cTecCham) )
				Replace SZT->ZT_TECALOC	With cTecCham
			EndIf
			Replace SZT->ZT_COMENTA		With mComentar
			Replace SZT->ZT_DTFECHA		With dDtFecha
			Replace SZT->ZT_HRFECHA		With dHrFecha
			Replace SZT->ZT_TECNICO		With cTecCham
			Replace SZT->ZT_CLASSIF		With cClasFech
			Replace SZT->ZT_SOLUCAO		With mSoluOcor
			If	( ! Empty(cTecCham) ) // Encerrado
				Replace SZT->ZT_STATUS		With '9'
			ElseIf	( ! Empty(cTecAloc) ) // Em analise
				Replace SZT->ZT_STATUS		With '1'
			ElseIf	( Empty(cTecCham) .and. Empty(cTecAloc) )
				Replace SZT->ZT_STATUS		With '0'
			EndIf
		EndIf
		MsUnLock()
	Else
		Help('',1,'REGNOIS')
	EndIf
	
	If	( nOpcao == 3 )
		ConfirmSx8Num('SZT')
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ xValid() บAutor ณLuis Henrique Robustoบ Data ณ  07/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida os dados digitados...                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao Principal                                           บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ  MOTIVO                                         บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function xValid( nType )
Local	lReturn	:= .f.

		Do Case
		Case	( nType == 1 ) // Tipo
			If	( ! Empty(cTipCham) )
				If	ExistCpo('SX5','ZO'+cTipCham)
					lReturn := .t.
					_cTipCham := Tabela('ZO',cTipCham)
					_oTipCham:Refresh()
				EndIf
				If	( AllTrim(cTipCham) == '001' )
					cModCham:= cModulo
					_oModulo:lVisible := .t.
					_oModCham:lVisible := .t.
					_oPrograma:lVisible := .t.
					_oProgCham:lVisible := .t.
				Else
					_oModulo:lVisible := .f.
					_oModCham:lVisible := .f.
					_oPrograma:lVisible := .f.
					_oProgCham:lVisible := .f.
				EndIf
			EndIf
		Case	( nType == 2 ) // Prioridade
			If	( ! Empty(cPriCham) )
				If	ExistCpo('SX5','ZP'+cPriCham)
					lReturn := .t.
					_cPriCham := Tabela('ZP',cPriCham)
					_oPriCham:Refresh()
				EndIf
			EndIf
		Case	( nType == 3 ) // Solicitante
			If	UsrExist(cSolCham)
				lReturn := .t.
				_cSolCham := Upper(UsrFullName(cSolCham))
				_oSolCham:Refresh()
			EndIf
		Case	( nType == 4 ) // Empresa
			nRegSM0   := SM0->(Recno())
			DbSelectArea('SM0')
			SM0->(DbGoTop())
			While 	SM0->( ! Eof() )
					If	( SubStr(cEmpCham,1,2) == AllTrim(SM0->M0_CODIGO) ) .and. ( SubStr(cEmpCham,4,2) == AllTrim(SM0->M0_CODFIL) )
						_cEmpCham := AllTrim(Upper(SM0->M0_NOME))+' ('+AllTrim(Upper(SM0->M0_FILIAL))+')'
					EndIf
				SM0->(DbSkip())	
			End
			SM0->(DbGoTo(nRegSM0))
			_oEmpCham:Refresh()
		Case	( nType == 5 ) // Tecnico Alocado
			If	( ! Empty(cTecAloc) )
				If	UsrExist(cTecAloc)
					lReturn := .t.
					_cTecAloc := Upper(UsrFullName(cTecAloc))
					_oTecAloc:Refresh()
				EndIf
			Else
				lReturn := .t.
			EndIf
		Case	( nType == 6 ) // Tecnico que solucionou
			If	( ! Empty(cTecCham) )
				If	UsrExist(cTecCham)
					lReturn := .t.
					_cMailTec := UsrRetMail(cTecCham)
					_cTecCham := Upper(UsrFullName(cTecCham))
					_oTecCham:Refresh()
				EndIf
			Else
				lReturn := .t.
			EndIf
		Case	( nType == 7 ) // Classificacao
			If	( ! Empty(cClasFech) )
				If	ExistCpo('SX5','ZQ'+cClasFech)
					lReturn := .t.
					_cClasFech := Tabela('ZQ',cClasFech)
					_oClasFech:Refresh()
				EndIf
			EndIf
		End Case

Return lReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CHAMLeng บAutor ณLuis Henrique Robustoบ Data ณ  07/02/04   บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Lengenda da rotina..                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao Principal                                           บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ  MOTIVO                                         บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function CHAMLeng()
Local	aLegenda  := {	{'ENABLE'		,'Aberto'},;
						{'BR_AMARELO'	,'Em Anแlise'},;
						{'BR_PRETO'	    ,'Cancelado'},;
						{'DISABLE'		,'Encerrado'}	}

		BrwLegenda(cCadastro,'Legenda',aLegenda)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัอออออออออออออออออออออหอออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณWfAvisaChamบAutor ณLuis Henrique RobustoบData ณ  09/02/05   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯอออออออออออออออออออออสอออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ ENVIO DE E-MAILs de resposta.                              บฑฑ
ฑฑบ          ณ Esta funcao envia um e-mail para o usuario que solicitou.  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao Principal                                           บฑฑ
ฑฑฬออออออออออุอออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA  ณ  MOTIVO                                        บฑฑ
ฑฑฬออออออออออุอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ           ณ                                                บฑฑ
ฑฑศออออออออออฯอออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function WfAvisaCham( cTo )
Local	_cSmtpSrv 	:= AllTrim(GetMv('MV_WFSMTPS')),;
		_cAccount 	:= AllTrim(GetMv('MV_WFCONTA')),;
		_cPassSmtp	:= AllTrim(GetMv('MV_WFSENHA')),;
		_cSmtpError	:= '',;
		_lOk		:= .f.,;
		_cTitulo 	:= OemToAnsi('[RASS CONSULT.] CHAMADO: '+cNumCham),;
		_cTo		:= cTo,;
		_cFrom		:= _cMailTec,;
		_cMensagem	:= '',;
		_lReturn	:= .f.

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณMonta a mensagem no corpo do e-mail..ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		_cMensagem	+= CHR_CENTER_OPEN + CHR_CENTER_CLOSE + CHR_LINE + CHR_ENTER
		_cMensagem	+= CHR_FONT_DET_OPEN
		_cMensagem	+= OemToAnsi('Chamado: ') + cNumCham + CHR_ENTER + CHR_ENTER
		_cMensagem	+= OemToAnsi('Foi Encerrado.... ') + CHR_ENTER + CHR_ENTER
		_cMensagem	+= OemToAnsi('Solu็ใo: ') + mSoluOcor + CHR_ENTER + CHR_ENTER
		_cMensagem	+= OemToAnsi('T้cnico: ') + _cTecCham + CHR_ENTER + CHR_ENTER
		_cMensagem	+= CHR_LINE + CHR_ENTER + CHR_NEGRITO
		_cMensagem	+= OemToAnsi('RASS CONSULTORIA') + CHR_NOTNEGRITO + CHR_ENTER
		_cMensagem	+= CHR_NEGRITO + OemToAnsi('Centro de Processamento de dados') + CHR_ENTER + CHR_NOTNEGRITO
		_cMensagem	+= CHR_ENTER + CHR_LINE
		_cMensagem	+= CHR_FONT_DET_CLOSE

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณConectando com o Servidor. !!ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		CONNECT SMTP SERVER _cSmtpSrv ACCOUNT _cAccount PASSWORD _cPassSmtp RESULT _lOk
		ConOut('Conectando com o Servidor SMTP')

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCaso a conexao for esbelecida com sucesso, inicia o processo de envio do e-mail..ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If	( _lOk )
			ConOut('Enviando o e-mail')
			SEND MAIL FROM _cFrom TO _cTo SUBJECT _cTitulo BODY _cMensagem RESULT _lOk
			ConOut('De........: ' + _cFrom)
			ConOut('Para......: ' + _cTo)
			ConOut('Assunto...: ' + _cTitulo)
			ConOut('Status....: Enviado com Sucesso')
			If	( ! _lOk )
				GET MAIL ERROR _cSmtpError
				ConOut(_cSmtpError)
				_lReturn := .f.
			EndIf
			DISCONNECT SMTP SERVER
			ConOut('Desconectando do Servidor')
			_lReturn := .t.
		Else
			GET MAIL ERROR _cSmtpError
			ConOut(_cSmtpError)
			_lReturn := .f.
		EndIf

Return _lReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณxPrintChamบAutor ณLuis Henrique Robustoบ Data ณ  11/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para imprimir o chamado.                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao Principal                                           บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ  MOTIVO                                         บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function CHAMPRINT()
Private	cStartPath	:= GetSrvProfString('Startpath',''),;
		cFileLogo	:= cStartPath + 'logorech_' + AllTrim(cEmpAnt) + '.bmp'

Private	oPrint		:= TMSPrinter():New(OemToAnsi('Controle de Chamado')),;
		oBrush		:= TBrush():New(,4),;
		oFont07		:= TFont():New('Courier New',07,07,,.F.,,,,.T.,.F.),;
		oFont08		:= TFont():New('Courier New',08,08,,.F.,,,,.T.,.F.),;
		oFont08n	:= TFont():New('Courier New',08,08,,.T.,,,,.T.,.F.),;
		oFont10Co   := TFont():New('Courier New',10,10,,.F.,,,,.T.,.F.),;
		oFont09		:= TFont():New('Tahoma',09,09,,.F.,,,,.T.,.F.),;
		oFont10		:= TFont():New('Tahoma',10,10,,.F.,,,,.T.,.F.),;
		oFont10n	:= TFont():New('Courier New',10,10,,.T.,,,,.T.,.F.),;
		oFont11		:= TFont():New('Tahoma',11,11,,.F.,,,,.T.,.F.),;
		oFont12		:= TFont():New('Tahoma',12,12,,.T.,,,,.T.,.F.),;
		oFont14		:= TFont():New('Tahoma',14,14,,.T.,,,,.T.,.F.),;
		oFont14s	:= TFont():New('Arial',14,14,,.T.,,,,.T.,.T.),;
		oFont15		:= TFont():New('Courier New',15,15,,.T.,,,,.T.,.F.),;
		oFont18		:= TFont():New('Arial',18,18,,.T.,,,,.T.,.T.),;
		oFont18n	:= TFont():New('Arial',18,18,,.T.,,,,.T.,.F.),;
		oFont16		:= TFont():New('Arial',16,16,,.T.,,,,.T.,.F.),;
		oFont22		:= TFont():New('Arial',22,22,,.T.,,,,.T.,.F.)

Private	aAberOcor	:= {},;
		aComentar	:= {},;
		aSolucao	:= {}

Private	nLin		:= 30	// Linha que o sistema esta imprimindo.
		nPage		:= 0

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณMonta os dados em array.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		For i:=1 To MlCount(SZT->ZT_OCORREN,56)
			If	! Empty(AllTrim(MemoLine(SZT->ZT_OCORREN,56,i)))
				aAdd(aAberOcor,AllTrim(MemoLine(SZT->ZT_OCORREN,56,i)))
			EndIf
		Next
		For i:=1 To MlCount(SZT->ZT_COMENTA,56)
			If	! Empty(AllTrim(MemoLine(SZT->ZT_COMENTA,56,i)))
				aAdd(aComentar,AllTrim(MemoLine(SZT->ZT_COMENTA,56,i)))
			EndIf
		Next
		For i:=1 To MlCount(SZT->ZT_SOLUCAO,56)
			If	! Empty(AllTrim(MemoLine(SZT->ZT_SOLUCAO,56,i)))
				aAdd(aSolucao,AllTrim(MemoLine(SZT->ZT_SOLUCAO,56,i)))
			EndIf
		Next

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSeta a pagina para impressao em Retrato.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oPrint:SetPortrait()

		xCabecPrint()

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณIMPRIME A PARTE DE INFORMACOES DO CHAMADO.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oPrint:Say(nLin,0050,OemToAnsi('N๚mero Chamado: '),oFont08n)
		oPrint:Say(nLin,0350,OemToAnsi('Descri็ใo: '),oFont08n)
		oPrint:Say(nLin,1600,OemToAnsi('Dt. Abertura: '),oFont08n)
		oPrint:Say(nLin,2000,OemToAnsi('Empresa/Filial: '),oFont08n)
		nLin += 40
		oPrint:Say(nLin,0050,SZT->ZT_NUMCHAM,oFont10Co)
		oPrint:Say(nLin,0350,SubStr(SZT->ZT_DESC,1,50),oFont10Co)
		oPrint:Say(nLin,1600,DtoC(SZT->ZT_DTABERT)+'-'+SZT->ZT_HRABERT,oFont10Co)
		oPrint:Say(nLin,2000,SZT->ZT_EMPCHAM,oFont10Co)

		nLin += 60 // Espaco entre os campos

		oPrint:Say(nLin,0050,OemToAnsi('Tipo: '),oFont08n)
		oPrint:Say(nLin,1000,OemToAnsi('Prioridade: '),oFont08n)
		oPrint:Say(nLin,1600,OemToAnsi('Solicitante: '),oFont08n)
		nLin += 40
		oPrint:Say(nLin,0050,Tabela('ZO',SZT->ZT_TIPO) + ' ' + SZT->ZT_MODULO + ' ' + SZT->ZT_PROGRAM,oFont10Co)
		oPrint:Say(nLin,1000,Tabela('ZP',SZT->ZT_PRICHAM),oFont10Co)
		oPrint:Say(nLin,1600,Upper(UsrFullName(SZT->ZT_SOLCHAM)),oFont10Co)

		nLin += 60 // Espaco entre os campos

		oPrint:Say(nLin,0050,OemToAnsi('Ocorr๊ncia:'),oFont08n)

		For i:=1 To Len(aAberOcor)
			nLin += 40
			If	( nLin >= 3000 )
				xCabecPrint()
			EndIf
			oPrint:Say(nLin,0050,aAberOcor[i],oFont10Co)
		Next i

		nLin += 60 // Espaco entre os campos

		If	( nLin >= 3000 )
			xCabecPrint()
		EndIf

		oPrint:Line(nLin,0050,nLin,2300) // Linha Separacao

		nLin += 30

		If	( nLin >= 3000 )
			xCabecPrint()
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณIMPRIME OS DADOS DOS COMENTARIOSณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If	( SZT->ZT_STATUS == '1' ) .or. ( SZT->ZT_STATUS == '8' ) .or. ( SZT->ZT_STATUS == '9' )

			oPrint:Say(nLin,0050,OemToAnsi('T้cnico Alocado:'),oFont08n)
			nLin += 40
			If	( nLin >= 3000 )
				xCabecPrint()
			EndIf

			oPrint:Say(nLin,0050,Upper(UsrFullName(SZT->ZT_TECALOC)),oFont10Co)

			nLin += 60 // Espaco entre os campos

			If	( nLin >= 3000 )
				xCabecPrint()
			EndIf

			oPrint:Say(nLin,0050,OemToAnsi('Comentแrios:'),oFont08n)

			For i:=1 To Len(aComentar)
				nLin += 40
				If	( nLin >= 3000 )
					xCabecPrint()
				EndIf
				oPrint:Say(nLin,0050,aComentar[i],oFont10Co)
			Next i

			nLin += 60 // Espaco entre os campos

			If	( nLin >= 3000 )
				xCabecPrint()
			EndIf

			oPrint:Line(nLin,0050,nLin,2300) // Linha Separacao

			nLin += 30

			If	( nLin >= 3000 )
				xCabecPrint()
			EndIf

		EndIf	

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณIMPRIME OS DADOS DOS COMENTARIOSณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If	( SZT->ZT_STATUS == '9' ) .or. ( SZT->ZT_STATUS == '8' )

			oPrint:Say(nLin,0050,OemToAnsi('T้cnico:'),oFont08n)
			oPrint:Say(nLin,1600,OemToAnsi('Dt. Encerramento: '),oFont08n)
			oPrint:Say(nLin,2000,OemToAnsi('Classifica็ใo: '),oFont08n)
			nLin += 40
			oPrint:Say(nLin,0050,Upper(UsrFullName(SZT->ZT_TECNICO)),oFont10Co)
			oPrint:Say(nLin,1600,DtoC(SZT->ZT_DTFECHA)+'-'+SZT->ZT_HRFECHA,oFont10Co)
			If	! Empty(SZT->ZT_CLASSIF)
				oPrint:Say(nLin,2000,Tabela('ZQ',SZT->ZT_CLASSIF),oFont10Co)
			EndIf

			nLin += 60 // Espaco entre os campos

			If	( nLin >= 3000 )
				xCabecPrint()
			EndIf

			oPrint:Say(nLin,0050,OemToAnsi('Solu็ใo:'),oFont08n)

			For i:=1 To Len(aSolucao)
				nLin += 40
				If	( nLin >= 3000 )
					xCabecPrint()
				EndIf
				oPrint:Say(nLin,0050,aSolucao[i],oFont10Co)
			Next i

			nLin += 60 // Espaco entre os campos

			If	( nLin >= 3000 )
				xCabecPrint()
			EndIf

			oPrint:Line(nLin,0050,nLin,2300) // Linha Separacao

		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณFina a impressao do relatorio.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oPrint:EndPage()

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณMostra em video a impressao do relatorio. !ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oPrint:Preview()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัอออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณxCabecPrintบAutor ณLuis Henrique Robustoบ Data ณ  11/02/05  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯอออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para imprimir o cabecalho do relatorio.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao Principal                                           บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ  MOTIVO                                         บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function xCabecPrint()
Local	cStatus	:= ''

		If	( SZT->ZT_STATUS == '0' )
			cStatus	:= 'Aberto'
		ElseIf	( SZT->ZT_STATUS == '1' )
			cStatus	:= 'Em Anแlise'
		ElseIf	( SZT->ZT_STATUS == '8' )
			cStatus	:= 'Cancelado'
		ElseIf	( SZT->ZT_STATUS == '9' )
			cStatus	:= 'Encerrado'
		EndIf

		nLin := 30

		If	( nPage > 0 )
			oPrint:EndPage()
		EndIf
		
		nPage++

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณInicia a impressao da pagina.!ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oPrint:StartPage()

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณImprime o cabecalho da empresa. !ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oPrint:SayBitmap(nLin+20,040,cFileLogo,230,175) // 560,350)
		oPrint:Say(nLin+20,700,'RASS CONSULTORIA',oFont16)
		oPrint:Say(nLin+150,700,'Centro de Processamento de Dados',oFont11)
		oPrint:Say(nLin+195,700,'Suporte on-line',oFont11)
		oPrint:Say(nLin+285,700,AllTrim('Manuais: intranet.rechtratores.com.br'),oFont11)

		oPrint:Say(nLin+100,1700,'Ficha de Chamado',oFont18n)
		oPrint:Say(nLin+180,1700,SZT->ZT_NUMCHAM + ' - ' + OemToAnsi(cStatus),oFont14s)

		nLin += 450

		oPrint:Line(nLin,0050,nLin,2300) // Linha Separacao

		nLin += 30

Return

Static Function AjustaSx1(cPerg)
Local	_nx		:= 0,;
		_nh		:= 0,;
		_nlh	:= 0,;
		_aHelp	:= Array(8,1),;
		_aRegs  := {},;
		_sAlias := Alias(),;
		_aHead	:= {"SX1->X1_GRUPO","SX1->X1_ORDEM","SX1->X1_PERGUNTE","SX1->X1_PERSPA","SX1->X1_PERENG	",;
					"SX1->X1_VARIAVL","SX1->X1_TIPO","SX1->X1_TAMANHO","SX1->X1_DECIMAL","SX1->X1_PRESEL",;
					"SX1->X1_GSC","SX1->X1_VALID","SX1->X1_VAR01","SX1->X1_DEF01","SX1->X1_DEF02",;
					"SX1->X1_DEF03","SX1->X1_DEF04","SX1->X1_DEF05","SX1->X1_F3"}

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCria uma array, contendo todos os valores...ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aAdd(_aRegs,{cPerg,'01',"Filtrar por ?"      ,"Filtrar por ?"      ,"Filtrar por ?"      ,'mv_ch1','N', 1,0,0,'C','','mv_par01','Pendentes','Em analise','Encerrados','Cancelados','Todos',''})
		aAdd(_aRegs,{cPerg,'02',"Prioridade ?"       ,"Prioridade ?"       ,"Prioridade ?"       ,'mv_ch2','N', 1,0,0,'C','','mv_par02','Alta','Normal','Baixa','Ambas','',''})
		aAdd(_aRegs,{cPerg,'03',"Programa Inicial? " ,"Programa Inicial? " ,"Programa Inicial? " ,'mv_ch3','C',10,0,0,'G','','mv_par03','','','','',"",""})
		aAdd(_aRegs,{cPerg,'04',"Programa Final? "   ,"Programa Final? "   ,"Programa Final? "   ,'mv_ch4','C',10,0,0,'G','','mv_par04','','','','',"",""})
		aAdd(_aRegs,{cPerg,'05',"Filtra por Tecnico?","Filtra por Tecnico?","Filtra por Tecnico?",'mv_ch5','N', 1,0,0,'C','','mv_par05','Sim','Nao','','',"",""})
		aAdd(_aRegs,{cPerg,'06',"Que contem (palavra)","Que contem (palavra)","Que contem (palavra)",'mv_ch6','C',20,0,0,'G','','mv_par06','','','','',"",""})

		DbSelectArea('SX1')
		SX1->(DbSetOrder(1))

		/*For _nx:=1 to Len(_aRegs)
			If	RecLock('SX1',Iif(!SX1->(DbSeek(_aRegs[_nx][01]+_aRegs[_nx][02])),.t.,.f.))
				For nlh:=1 to Len(_aHead)
					If	( nlh <> 10 )
						Replace &(_aHead[nlh]) With _aRegs[_nx][nlh]
					EndIf
				Next nlh
				MsUnlock()
			Else
				Help('',1,'REGNOIS')
			Endif
		Next _nx
       */ 

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณMonta array com o help dos campos dos parametros.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aAdd(_aHelp[01],OemToAnsi("Escolha os chamados que deseja visualizar: Abertos, em analise, encerrados, cancelados ou todos."))
		aAdd(_aHelp[02],OemToAnsi("De qual prioridade voc๊ quer visualizar?"))
		aAdd(_aHelp[03],OemToAnsi("Programa, para os chamados envolvendo Microsiga, inicial ?"))
		aAdd(_aHelp[04],OemToAnsi("Programa, para os chamados envolvendo Microsiga, final ?"))
		/*
		For _nh:=1 to Len(_aHelp)
			PutSX1Help("P."+AllTrim(cPerg)+StrZero(_nh,2)+".",_aHelp[_nh],_aHelp[_nh],_aHelp[_nh])
		Next _nh
		*/

Return Nil