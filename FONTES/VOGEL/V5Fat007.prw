#Include "Protheus.Ch"
#Include "TopConn.Ch"

#DEFINE POS_PRODUTO 6
#DEFINE POS_CLIENTE  3
#DEFINE POS_LOJA 4
#DEFINE POS_PED 1
#DEFINE POS_AGLUTPED 18
#DEFINE TAM_ANOMES 4
#DEFINE	POS_PEDISIS 2
/*
Função.................: V5Fat007
Objetivo...............: Faturar Pedidos de venda de acordo com o tipo de produto
Autor..................: Leandro Diniz de Brito ( LDB ) - BRL Consulting
Data...................: 11/08/2016
Observações............:
*/
*------------------------*


User Function V5Fat007(aEmp) // Alterado em 21/11/2019 por Iago Bernardes. Tornando compatível com o Scheduler do Protheus
*------------------------*

Local aArea      	:= GetArea()
Local chTitle    	:= "TOTVS - Versão 2.3" // Alterado a versão em 24/01/2019, pois houve a correção do faturamento com series erradas.

Local chMsg      	:= "Vogel - Faturamento"
Local cTitle

Local cText     	:= "Este programa tem como objetivo faturar os pedidos de venda de acordo com os parametros selecionados."
Local bFinish    	:= { || .T. }

Local cResHead

Local lNoFirst
Local aCoord

Local nX
Local aTables	:= {"SA1", "SB1", "SE1", "SC5", "SC6", "ZX3"}
Local cGrpEmp	:= ""
Local cFilAtu	:= ""


Private oWizard

Private dDtIni
Private dDtFim

Private aTpProd
Private cTpProd

Private cTes

Private aDados      := {}

Private aDadosLog
Private dIniFat

Private cAliasTemp
Private lBlind	:= IsBlind()

Default aEmp := {"V5", "01"}

// Alterado em 21/11/2019 por Iago Bernardes.
// Caso a execução tenha origem no Scheduler, prepara o ambiente
If lBlind
	cGrpEmp	:= aEmp[1]
	cFilAtu	:= aEmp[2]
	
	// Ajusta a filial inicial para recuperar o conteúdo da SM0 (SIGAMAT)
	RpcSetType(3)
	RpcSetEnv(cGrpEmp, cFilAtu, , , "FAT", "U_V5FAT007", aTables)
	//	PREPARE ENVIRONMENT EMPRESA cGrpEmp FILIAL cFilAtu MODULO "FAT" TABLES "SA1", "SB1", "SE1", "SC5", "SC6", "ZX3"
EndIf

// Controle de semáforo
If !LockbyName("U_V5FAT007"  , .F., .F.)
	If !lBlind
		MsgStop( 'A rotina já está em execução. Finalizando.' )
	Else
		ConOut( 'V5FAT0007 - A rotina ja esta em execucao. Finalizando.' )
		RpcClearEnv()
	EndIf
	
	RestArea( aArea )
	Return
EndIf


// Inicializa as variáveis
//dDtIni	:= dDataBase
//dDtIni	:= STOD("20191101")
dDtIni	:= DaySub(dDataBase, SuperGetMV("ES_DIASFAT", .F., 30))
dDtFim	:= dDataBase
cTes	:= Space( Len( SF4->F4_CODIGO ) )
dIniFat	:= FirstDay( GetNewPar( 'MV_P_00081' , CtoD( '' ) ) )
//aTpProd     := { "SF-Fatura" , "SR-Serviço" , "ST-Telecom Modelo 22" , "RV-Mercantil Danfe" , "SC-Comunicação Modelo 21", "ME-Movimentações Danfe", "MM-Multiplos Modelos"  }
// Retirado a opcao de ME
aTpProd     := { "SF-Fatura" , "SR-Serviço" , "ST-Telecom Modelo 22" , "RV-Mercantil Danfe" , "SC-Comunicação Modelo 21", "MM-Multiplos Modelos"  }
cTpProd     := aTpProd[ 1 ]

If !( cEmpAnt $ u_EmpVogel() )
	// Alterado em 21/11/2019 por Iago Bernardes. Tornando compatível com o Scheduler do Protheus
	If !lBlind
		MsgStop( 'Empresa nao autorizada.' )
	Else
		ConOut( 'V5FAT007 - Empresa nao autorizada.' )
		RpcClearEnv()
	EndIf
	
	UnLockbyName("U_V5FAT007" , .F., .F.) // Desbloqueando Semáforo
	RestArea( aArea )
	Return
EndIf

If !AliasInDic( 'ZX3' )
	// Alterado em 21/11/2019 por Iago Bernardes. Tornando compatível com o Scheduler do Protheus
	If !lBlind
		MsgStop( 'Tabela ZX3 nao encontrada. Favor entrar em contato com a TI .' )
	Else
		ConOut( 'V5FAT007 - Tabela ZX3 nao encontrada. Favor entrar em contato com a TI .' )
		RpcClearEnv()
	EndIf
	
	UnLockbyName("U_V5FAT007" , .F., .F.) // Desbloqueando Semáforo
	RestArea( aArea )
	Return
EndIf

If Empty( dIniFat )
	// Alterado em 21/11/2019 por Iago Bernardes. Tornando compatível com o Scheduler do Protheus
	If !lBlind
		MsgStop( 'Parametro MV_P_00081 ( Data de Inicio de Faturamento ) nao configurado. Favor entrar em contato com a TI.' )
	Else
		ConOut( 'V5FAT007 - Parametro MV_P_00081 ( Data de Inicio de Faturamento ) nao configurado. Favor entrar em contato com a TI.' )
		RpcClearEnv()
	EndIf
	
	UnLockbyName("U_V5FAT007" , .F., .F.) // Desbloqueando Semáforo
	RestArea( aArea )
	Return
EndIf

// Alterado em 21/11/2019 por Iago Bernardes. Tornando compatível com o Scheduler do Protheus
If lBlind
	ConOut( 'V5FAT007 - Inicio da rotina via Scheduler. Hora: ' + Time() )
	ConOut( 'V5FAT007 - Empresa/Filial: "' + cGrpEmp + '/' + cFilAtu + '".' )
	
	For nX := 1 To Len(aTpProd)
		ConOut( 'V5FAT007 - Gerando notas fiscais. Tipo: ' + Alltrim(aTpProd[nX]) + '. Hora: ' + Time() )
		
		aDados := {}
		cTpProd := aTpProd[ nX ]
		
		If MontaQry()
			GeraNf()
		EndIf
		
		ConOut( 'V5FAT007 - Fim da geracao de notas fiscais. Tipo: ' + Alltrim(aTpProd[nX]) + '. Hora: ' + Time() )
	Next nX
	
	ConOut( 'V5FAT007 - Fim da rotina via Scheduler. Hora: ' + Time() )
	ConOut( 'V5FAT007 - Empresa/Filial: "' + cGrpEmp + '/' + cFilAtu + '".' )
	
	// Limpa o ambiente
	RpcClearEnv()
Else
	
	oWizard := ApWizard():New ( chTitle , chMsg , cTitle , cText , { || .T. } , /*bFinish*/ ,/*lPanel*/, cResHead , /*bExecute*/ , lNoFirst , aCoord )
	
	oWizard:NewPanel ( "Filtros"               , "Preencher todos os parametros abaixo" , { || .T. }/*bBack*/ , { || ValidaFiltro() }  ,bFinish ,, { || TelaFiltro() } /*bExecute*/  )
	oWizard:NewPanel ( "Pedidos"               , "" , { || .T. }/*bBack*/ , { || If( MsgYesNo( 'Confirma faturamento dos pedidos ?' , 'Atencao') , (  Processa( { || GeraNf() , 'Gerando notas fiscais...' } )  , .T. )   , .F. ) }  ,bFinish ,, { || TelaPedido() } /*bExecute*/  )
	oWizard:NewPanel ( "Resultado do Processamento"       , "" , { || .F. }/*bBack*/ , /*{ || .T. }*/  , bFinish ,.F., { || ExibeLog() } )
	
	oWizard:Activate( .T. )
EndIf

UnLockbyName("U_V5FAT007" , .F., .F.) // Desbloqueando Semáforo

RestArea( aArea )

Return

/*
Função...............: TelaFiltro
Objetivo.............: Tela de Seleção de Nota de Entrada
Autor................: Leandro Brito ( BRL Consulting )
Data.................: 11/08/2016
*/
*-----------------------------------------------*
Static Function TelaFiltro
*-----------------------------------------------*
Local oPanel  := oWizard:GetPanel( oWizard:nPanel )
Local oCombo

@10,10 Say "Data Inicial" Size 80,10 Of oPanel Pixel
@10,100 MSGet dDtIni    Size 50,10  Of oPanel Pixel

@25,10 Say "Data Final" Size 80,10 Of oPanel Pixel
@25,100 MSGet dDtFim   Size 50,10  Of oPanel Pixel

@40,10 Say "Tipo de Produto" Size 80,10 Of oPanel Pixel
oCombo := TComboBox():New(40,100,{|u|if(PCount()>0,cTpProd:=u,cTpProd)},aTpProd,100,20,oPanel,,{|| .T. },,,,.T.,,,,,,,,,'cTpProd')

Return

/*
Função...............: ExibeLog
Objetivo.............: Exibe Log da operação
Autor................: Leandro Brito ( BRL Consulting )
Data.................: 16/03/2015
*/
*-----------------------------------------------*
Static Function ExibeLog
*-----------------------------------------------*
Local oPanel  := oWizard:GetPanel( oWizard:nPanel )
Local oLbx

If !Empty( aDadosLog )
	
	oLbx := TWBrowse():New( ,,,,,,,oPanel,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	oLbx:Align := CONTROL_ALIGN_ALLCLIENT
	
	oLbx:SetArray( aDadosLog )
	
	oLbx:AddColumn( TCColumn():New('Pedido'    ,{ || aDadosLog[oLbx:nAt,01] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
	oLbx:AddColumn( TCColumn():New('Mensagem'    ,{ || aDadosLog[oLbx:nAt,02] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
	oLbx:Refresh()
	
EndIf

Return

/*
Função...............: ValidaFiltro
Objetivo.............: Validação da Tela de Seleção de Filtro
Autor................: Leandro Brito ( BRL Consulting )
Data.................: 23/03/2015
*/
*-----------------------------------------------*
Static Function ValidaFiltro
*-----------------------------------------------*

If Empty( dDtIni ) .Or. Empty( dDtFim )
	MsgStop( 'Preencher datas inicial e final' )
	Return( .F. )
EndIf

Return( .T. )

/*
Função...............: TelaPedido
Objetivo.............: Exibir pedidos de venda a Faturar
Autor................: Leandro Brito ( BRL Consulting )
Data.................: 11/08/2016
*/
*-----------------------------------------------*
Static Function TelaPedido
*-----------------------------------------------*
Local oPanel  	:= oWizard:GetPanel( oWizard:nPanel )
Local aArea		:= GetArea()

Local lRet			:= .T.

Local oLbx

Begin Sequence

If !MontaQry()
	lRet := .F.
	Break
EndIf

oLbx := TWBrowse():New( ,,,,,,,oPanel,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
oLbx:Align := CONTROL_ALIGN_ALLCLIENT

oLbx:SetArray( aDados )

oLbx:AddColumn( TCColumn():New('Pedido'    ,{ || aDados[oLbx:nAt,01] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
oLbx:AddColumn( TCColumn():New('Emissao'    ,{ || aDados[oLbx:nAt,02] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
oLbx:AddColumn( TCColumn():New('Ped.Sistech'    ,{ || aDados[oLbx:nAt,12] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
oLbx:AddColumn( TCColumn():New('Cliente'    ,{ || aDados[oLbx:nAt,03] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
oLbx:AddColumn( TCColumn():New('Loja'    ,{ || aDados[oLbx:nAt,04] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
oLbx:AddColumn( TCColumn():New('Item'    ,{ || aDados[oLbx:nAt,05] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
oLbx:AddColumn( TCColumn():New('Produto'    ,{ || aDados[oLbx:nAt,06] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
oLbx:AddColumn( TCColumn():New('Descrição'    ,{ || aDados[oLbx:nAt,07] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
oLbx:AddColumn( TCColumn():New('Qtde'    ,{ || aDados[oLbx:nAt,08] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
oLbx:AddColumn( TCColumn():New('Prc.Unit.'    ,{ || aDados[oLbx:nAt,09] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
oLbx:AddColumn( TCColumn():New('Total'    ,{ || aDados[oLbx:nAt,10] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )

oLbx:GoTop()
oLbx:Refresh()

If Select ( cAliasTemp ) > 0
	( cAliasTemp )->( DbCloseArea() )
EndIf

End Sequence

RestArea( aArea )

Return( lRet )

/*
Função...............: MontaQry
Objetivo.............: Monta query de seleção de pedidos de venda
Autor................: Iago Bernardes ( TOTVS Ibirapuera )
Data.................: 21/11/2019
*/
*-----------------------------------------------*
Static Function MontaQry
*-----------------------------------------------*

Local aArea	:= GetArea()
Local cSql  := ''
Local lRet	:= .T.

cAliasTemp := GetNextAlias()

If Select ( cAliasTemp ) > 0
	( cAliasTemp )->( DbCloseArea() )
EndIf

cSql := "SELECT C6_NUM, C5_EMISSAO, C5_CLIENTE, C5_LOJACLI, C6_ITEM, C6_PRODUTO, C6_DESCRI, C6_QTDVEN, C6_PRCVEN,"
cSql += "C6_TES, C6_VALOR, C5.R_E_C_N_O_ RECSC5, C5_P_REF, C5_P_AGLUT, B1_TIPO , C5_TIPO ,  C5_CLIENT ,  C5_LOJAENT , C5_TRANSP ,  "
cSql += " C5_TIPOCLI , C5_CONDPAG , C5_VEND1 , C5_TPFRETE , C5_INCISS , C5_RECISS , C5_FORNISS , C5_REAJUST , A1_XAGLPED "

cSql += "FROM " + RetSqlName( 'SC6' ) + "  "
cSql += "C6 INNER JOIN " + RetSqlName( 'SC5' ) + " C5 ON "
cSql += "C5_FILIAL = C6_FILIAL "
cSql += "AND C5_NUM = C6_NUM "
cSql += "INNER JOIN " + RetSqlName( 'SB1' ) + " B1 ON "
cSql += "B1_COD = C6_PRODUTO "
cSql += "INNER JOIN " + RetSqlName( 'SA1' ) + " A1 ON "
cSql += " A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI "
cSql += "WHERE C6.D_E_L_E_T_ = '' "
cSql += "AND C5.D_E_L_E_T_ = '' "
cSql += "AND A1.D_E_L_E_T_ = '' "
cSql += "AND B1.D_E_L_E_T_ = '' "
cSql += "AND A1_FILIAL = '" + xFilial( 'SA1' ) + "' "
cSql += "AND B1_FILIAL = '" + xFilial( 'SB1' ) + "' "
cSql += "AND C5_FILIAL = '" + xFilial( 'SC5' ) + "' "
cSql += "AND C6_FILIAL = '" + xFilial( 'SC6' ) + "' "


If AllTrim(Left(cTpProd, 2)) # 'MM' .AND. AllTrim(Left(cTpProd, 2)) # 'MA'
///If AllTrim(Left(cTpProd, 2)) # 'MM'                                             //Triyo 13/11/2020
	cSql += "AND B1_TIPO = '" + Left( cTpProd , 2 )  + "' "
	cSql += "AND C5_P_AGLUT <> 'S' " // Adição dessa linha em 24/01/19 para filtrar corretamente os pedidos que não sejam Multiplos Modelos.
Else
	cSql += "AND C5_P_AGLUT = 'S'
EndIf

cSql += "AND C6_QTDVEN > C6_QTDENT "
cSql += "AND C6_BLQ NOT IN ( 'R' , 'S' ) "
cSql += "AND C5_EMISSAO BETWEEN '" + DtoS( dDtIni ) + "' AND '"  + DtoS( dDtFim ) + "' "
cSql += "AND C5_P_REF <> '' "
cSql += "ORDER BY "

cSQL += "  C5_NUM , C6_ITEM "

TCQuery cSql ALIAS ( cAliasTemp ) NEW

TCSetField( cAliasTemp , 'C6_QTDVEN' , 'N' , TamSx3( 'C6_QTDVEN' )[ 1 ] , TamSx3( 'C6_QTDVEN' )[ 2 ] )
TCSetField( cAliasTemp , 'C6_PRCVEN' , 'N' , TamSx3( 'C6_PRCVEN' )[ 1 ] , TamSx3( 'C6_PRCVEN' )[ 2 ] )
TCSetField( cAliasTemp , 'C6_VALOR'  , 'N' , TamSx3( 'C6_VALOR' )[ 1 ] , TamSx3( 'C6_VALOR' )[ 2 ] )
TCSetField( cAliasTemp , 'C5_EMISSAO' , 'D' , 8 )

aDados		:= {}
( cAliasTemp )->( DbEval( { || Aadd( aDados , { C6_NUM,;
C5_EMISSAO,;
C5_CLIENTE,; 
C5_LOJACLI,;
C6_ITEM,;
C6_PRODUTO,;
C6_DESCRI,;
C6_QTDVEN,;
C6_PRCVEN,;
C6_VALOR,;
RECSC5,;
C5_P_REF,;
C6_TES,;
C5_P_AGLUT,;
C5_TIPO,;
C5_CLIENTE,;
C5_LOJACLI,;
IIf(Empty(C5_P_AGLUT),A1_XAGLPED,C5_P_AGLUT),;
B1_TIPO } ) } ) )


///A1_XAGLPED } ) } ) )


DbSelectArea( 'SC6' )

If Len( aDados ) == 0
	If !lBlind
		MsgStop( 'Nao existem dados para exibição.' )
	Else
		ConOut( 'V5FAT007 - Nao existem dados para processamento.' )
	EndIf
	
	lRet := .F.
Else
	If lBlind
		ConOut( 'V5FAT007 - Foram encontrados ' + cValToChar(Len(aDados)) + ' registros para processamento.' )
	EndIf
	
	lRet := .T.
EndIf

RestArea( aArea )

Return lRet


/*
Função...............: GeraNF
Objetivo.............: Gerar Nota Fiscal
Autor................: Leandro Brito ( BRL Consulting )
Data.................: 12/08/2016
*/
*-----------------------------------------------*
Static Function GeraNF
*-----------------------------------------------*
Local i,j
Local cPedido := ''
Local cPedVog := ''
Local cChaveAlugt := ""
Local cCliente := ""
Local cLoja := ""
Local cProduto := ""

Local cSerieNF

Local cRet

Local cTipoPrd :=  IIf(Left( cTpProd , 2 )=="MA","MM",Left( cTpProd , 2 )) // MA converte para MM na validacao de Serie
//Local cEspecie

//Local aNotPed := {}

Local _aItAglut := {}
Local _aNotas   := {}
Local _aCab460  := {}
Local _aIte460  := {}
Local _cFil460  := ''
Local _nVal460  := 0
Local _cNum460  := ''
Local _cPre460  := SuperGetMV('VO_PREAGLU',, 'AGL')
Local _cTip460  := SuperGetMV('VO_TIPAGLU',, 'BOL')
Local _cEmit460 := ''
Local _cNat460  := ''
Local _cCli460  := ''
Local _cMoe460  := ''
Local _cLoj460  := ''
Local _dVen460  := ''
Local _cPag460  := ''
Local _dEmi460  := CToD('01/01/2000')
Local _nN       := 0
Local _nP       := 0
Local _nD       := 0
//Local _nVlrAbat := 0
Local _aLiquid  := {}
Local _nPos_L   := 0
Local _nCont    := 0  //Add por Raphael - Cyberpolos 08/10/2019  | controla qtd de itens a serem processados, para que não haja erro de limite de elementos no array(_aLiquid[2])
Local _cPedVogel := ''
Local nx
Local aLibsPed := {}
Local aProdsAglut := {}
Local aBkpaDados := {}
Local aPedsAglut := {}
Local aAuxAglut := {}
Local cMsgLiq := ""
Local cPedidos := ""
Local cAglut := ""
Local cImpBol := ""
Local aAuxCli := {}
Local aAuxNotas := {}

Local nX := 0
Local nZ := 0
Local cId := ""

Private lMsErroAuto := .F.

Begin Sequence

ZX3->( DbSetOrder( 1 ) )

aDadosLog := {}
VerSerieNf( @cSerieNf , cTipoPrd )

If Empty( cSerieNf ) .And. AllTrim(cTipoPrd) # 'MM'
	If !lBlind
		Aadd( aDadosLog , { '' , 'Serie não parametrizada para o tipo de produto ' + cTipoPrd + '. Contatar a TI.' } )
	Else
		ConOut( 'V5FAT007 - Serie não parametrizada para o tipo de produto ' + cTipoPrd + '.' )
	EndIf
	
	Break
EndIf

cSerieNf := PadR( cSerieNf , 3 )

/*
* Tratamento parametro MV_SER79
*/

If cTipoPrd == 'ST'
	If SX6->( !DbSeek( cFilAnt + 'MV_SER79' ) )
		SX6->( RecLock( 'SX6' , .T. ) )
		SX6->X6_FIL := cFilAnt
		SX6->X6_VAR := 'MV_SER79'
		SX6->X6_TIPO := 'C'
		SX6->X6_DESCRIC := 'Series que devem ser consideradas para as Notas'
		SX6->X6_DESC1	:= 'Fiscais Modelo 01 da CAT79.'
		SX6->X6_CONTEUD := cSerieNf
		SX6->( MSUnlock() )
		
	ElseIf At( cSerieNf , SX6->X6_CONTEUD ) == 0
		SX6->( RecLock( 'SX6' , .F. ) )
		aSeries := Separa( AllTrim( SX6->X6_CONTEUD ) , "/" )
		
		If Len( aSeries ) > 23
			ADel( aSeries , 1 )
			aSeries[ Len( aSeries ) ] := cSerieNf
		Else
			Aadd( aSeries , cSerieNf )
		EndIf
		
		cSer79 :=  ""
		For nx := 1 To Len( aSeries )
			If !Empty( cSer79 )
				cSer79 += "/"
			EndIf
			cSer79 += PadR( aSeries[ nx ] , 3 )
		Next
		
		SX6->X6_CONTEUD := cSer79
		SX6->( MSUnlock() )
		
	EndIf
EndIf

cPedVog := aDados[1,12]

If !lBlind
	ProcRegua( Len( aDados ) )
EndIf


//cPedido <> aDados[ i ][ 1 ]

For i := 1 To Len( aDados )
	
	// Primero processa so pedidos que nao aglutinam ou DANFE
	If aDados[i][POS_AGLUTPED] == "S" .And. Left(cTpProd,2) != "ME"
		Loop
	Endif
	
	If !lBlind
		IncProc()
	EndIf
	
	If cPedido <> aDados[ i ][ 1 ]
		
		cPedido := aDados[ i ][ 1 ]
		
		_nCont++
		
		SC5->( DbSetOrder( 1 ) )
		SC5->( DbSeek( xFilial('SC5') + cPedido ) )

		If Alltrim(SC5->C5_RECISS) <> ""
			lRecIssC5 := .T.
		Else
			lRecIssC5 := .F.
		Endif
		
		SA1->(DbSetOrder(1)) // Indice 1 - A1_FILIAL+A1_COD+A1_LOJA
		SA1->(DbSeek(xFilial('SA1')+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
		
		cTipoPes := Left(SA1->A1_XTIPO,2)
		If SA1->A1_RECISS == "1"
			lRecIss := .T.
		Else
			lRecIss := .F.
		Endif
		
		cImpBol := SA1->A1_XBOLDEP
		
		_cPedVogel := Alltrim(SC5->C5_P_REF)
		
		If Ascan( aDados , { | x | x[ 1 ] == cPedido .And. x[ 13 ] == '999' } ) > 0
			If !lBlind
				Aadd( aDadosLog , { cPedido , 	'Ped.Ref ' + SC5->C5_P_REF + ' não faturado. Tributação não parametrizada.' } )
			Else
				ConOut( 'V5FAT007 - Ped.Ref ' + SC5->C5_P_REF + ' não faturado. Tributação não parametrizada.' )
			EndIf
			
			Loop
		EndIf
		
		/*
		** Liberacao do Pedido de Venda
		*/
		
		aPvlNfs:={} ;aBloqueio:={}
		Ma410LbNfs(2,@aPvlNfs,@aBloqueio)
		Ma410LbNfs(1,@aPvlNfs,@aBloqueio)
		
		If !Empty( aBloqueio )
			
			/*
			** Se houve algum bloqueio nao gera NF e guarda no Log
			*/
			For j := 1 To Len( aBloqueio )
				If !lBlind
					Aadd( aDadosLog , { aBloqueio[ j ][ 1 ] , 'Produto ' + aBloqueio[ j ][ 4 ] + ' : ' + If ( !Empty( aBloqueio[ j ][ 6 ] ) , 'Bloqueio credito.' , '' ) + 	If( !Empty( aBloqueio[ j ][ 7 ] ) , 'Bloqueio Estoque.' , '' ) } )
				Else
					ConOut( 'V5FAT007 - Produto ' + aBloqueio[ j ][ 4 ] + ' : ' + If ( !Empty( aBloqueio[ j ][ 6 ] ) , 'Bloqueio credito.' , '' ) + If( !Empty( aBloqueio[ j ][ 7 ] ) , 'Bloqueio Estoque.' , '' ) )
				EndIf
			Next
			
		Else
			
			If !Empty(aPvlNfs)
				
				// Desativado Bruno, segundo Fabricio semrpe vai ter a regra de olhar as naturezas
				If Left(cTipoPrd,2) == "ME" //aDados[i][14] # 'S' // Se não for o caso de um pedido de aglutinação de boletos, continua tratamento antigo.
					//If aDados[i][14] # 'S' // Se não for o caso de um pedido de aglutinação de boletos, continua tratamento antigo.
					// Posiciona no SX5 para evitar o faturamento do pedido com série errada.
					SX5->(DbSetOrder(1)) // Indice 1 - X5_FILIAL+X5_TABELA+X5_CHAVE
					SX5->(DbSeek(xFilial('SX5')+'01'+cSerieNf))
					
					/*
					** Gera Nota Fiscal de Saida
					*/
					
					Pergunte("MT460A",.F.)
					
					cRet := MaPvlNfs( aPvlNfs ,;
					cSerieNf ,;
					.F. ,; //** Mostra Lancamentos Contabeis
					.F. ,; //** Aglutina Lanuamentos
					.F. ,; //** Cont. On Line ?
					.F. ,; //** Cont. Custo On-line ?
					.F. ,; //** Reaj. na mesma N.F.?
					3 ,; //** Metodo calc.acr.fin? Taxa defl/Dif.lista/% Acrs.ped
					1,; //** Arred.prc unit vist?  Sempre/Nunca/Consumid.final
					.F.,;  //** Atualiza Cli.X Prod?
					.F. ,,,,,,; //** Ecf ?
					dDataBase )
					
					If Empty( cRet )
						If !lBlind
							Aadd( aDadosLog , { cPedido , 	'Pedido não faturado.' } )
						Else
							ConOut( 'V5FAT007 - Pedido ' + cPedido + ' não faturado.' )
						EndIf
						
					Else
						If !lBlind
							Aadd( aDadosLog , { cPedido , 	'Faturado com sucesso. Ped.Ref ' + SC5->C5_P_REF + ' - NF ' + cRet + ' Serie ' + cSerieNf } )
						Else
							ConOut( 'V5FAT007 - Pedido ' + cPedido + ' faturado com sucesso. Ped.Ref ' + SC5->C5_P_REF + ' - NF ' + cRet + ' Serie ' + cSerieNf )
						EndIF
						
						
						/*
						* Atualiza campo F2_P_REF
						*/
						TcSqlExec( "UPDATE " + RetSqlName( "SF2" ) + " SET F2_P_REF = '" + SC5->C5_P_REF + "', F2_P_AGLUT = 'N' WHERE F2_FILIAL = '" + xFilial( 'SF2' ) + "' AND " +;
						"F2_DOC = '" + cRet + "' AND F2_SERIE = '" + cSerieNf + "' AND F2_CLIENTE = '" + SC5->C5_CLIENTE + "' AND F2_LOJA = '" + SC5->C5_LOJACLI + "' " )
						
						/*
						* Atualiza campo D2_P_REF
						*/
						TcSqlExec( "UPDATE " + RetSqlName( "SD2" ) + " SET D2_P_REF = '" + SC5->C5_P_REF + "' WHERE D2_FILIAL = '" + xFilial( 'SD2' ) + "' AND " +;
						"D2_DOC = '" + cRet + "' AND D2_SERIE = '" + cSerieNf + "' AND D2_CLIENTE = '" + SC5->C5_CLIENTE + "' AND D2_LOJA = '" + SC5->C5_LOJACLI + "' " )
						
						/*
						* Atualiza campo E1_P_REF
						*/
						cImpBol := SA1->A1_XBOLDEP
						TcSqlExec( "UPDATE " + RetSqlName( "SE1" ) + " SET E1_P_REF = '" + SC5->C5_P_REF + "', E1_P_BOL = '"+cImpBol+"', E1_P_AGLUT = 'N' WHERE E1_FILIAL = '" + xFilial( 'SE1' ) + "' AND " +;
						"E1_NUM = '" + cRet + "' AND E1_SERIE = '" + cSerieNf + "' AND E1_CLIENTE = '" + SC5->C5_CLIENTE + "' AND E1_LOJA = '" + SC5->C5_LOJACLI + "' " )
						
					EndIf
					
				Else
					
					/*
					** Gera Nota Fiscal de Saida, onde cada item representa uma nota separada.
					*/
					
					Conout('V5FAT007 - Inicio do faturamento do pedido ' + SC5->C5_P_REF + ' Hora: ' + Time())
					
					_aNotas := {}
					
					// Ordena o array de itens de pedido liberados por codigo de produto.
					ASort(aPvlNfs, 1,, {|x, y| x[6] < y[6] })
					
					_cCodPro := ''
					
					For _nN := 1 To Len(aPvlNfs)
						
						/*/   Murilo
						If Empty(_cCodPro)
							_cCodPro  := aPvlNfs[_nN][6]
							_aItAglut := {}
						EndIf
						/*/

						If Empty(_cCodPro)
							_cCodPro  := aPvlNfs[_nN][6]
							//_cTipoP   := aPvlNfs[_nN][19]	
							_aItAglut := {}
						EndIf

						
						// Tratamento para produtos iguais serem faturados na mesma nota fiscal.
						////If _cCodPro == aPvlNfs[_nN][6]    Murilo

						If _cCodPro == aPvlNfs[_nN][6]  //.Or. _cTipoP == aPvlNfs[_nN][19]
							
							AAdd(_aItAglut, aPvlNfs[_nN])
							
							If (_nN + 1) <= Len(aPvlNfs)
								If _cCodPro == aPvlNfs[_nN + 1][6]
									Loop
								EndIf
							EndIf
							
						EndIf
                       
					   /*/ Murilo
						// Tratamento para produtos iguais serem faturados na mesma nota fiscal.
						If _cCodPro == aPvlNfs[_nN][6]
							
							AAdd(_aItAglut, aPvlNfs[_nN])
							
							If (_nN + 1) <= Len(aPvlNfs)
								If _cCodPro == aPvlNfs[_nN + 1][6]
									Loop
								EndIf
							EndIf
							
						EndIf
					   /*/


						_cCodPro := ''
						
						SB1->(DbSetOrder(1)) // Indice 1 - B1_FILIAL+B1_COD
						If SB1->(DbSeek(xFilial('SB1')+_aItAglut[1][6])) // Posição 6 é o código do produto.
							
							cxTipo	 := Left(SB1->B1_XTIPO,2) // Obtem o tipo de cada item da nota, pois a serie é designada de acordo com o tipo.
							cTipoPrd := SB1->B1_TIPO
							cSerieNf := ''
							
							VerSerieNf(@cSerieNf , cTipoPrd)
							
							If Empty( cSerieNf )
								If !lBlind
									Aadd( aDadosLog , { '' , 'Serie não parametrizada para o tipo de produto ' + cTipoPrd + '. Aglutinação de boletos. Contatar a TI.' } )
								Else
									ConOut( 'V5FAT007 - Serie não parametrizada para o tipo de produto ' + cTipoPrd + '. Aglutinação de boletos. Contatar a TI.' )
								EndIf
								
								Break
							EndIf
							
							cSerieNf := PadR(cSerieNf, 3)
							
							// Posiciona no SX5 para evitar o faturamento do pedido com série errada.
							SX5->(DbSetOrder(1)) // Indice 1 - X5_FILIAL+X5_TABELA+X5_CHAVE
							SX5->(DbSeek(xFilial('SX5')+'01'+cSerieNf))
							
							// Procura a Natureza na tabela ZZ3 e grava no cabeçalho do Pedido
							ZZ3->(dbSetOrder(1))
							If ZZ3->(dbSeek(xFilial("ZZ3") + cxTipo + cTipoPes))
								SC5->(RecLock("SC5",.F.))
								If lRecIssC5                // Triyo - 17/11/2020 - Se C5_RECISS = .T. ele verifica o A1_RECISS
                                    If Alltrim(SC5->C5_RECISS) == "1"     // verifica se recolhe ISS no pedido esta como SIM
								      SC5->C5_NATUREZ := ZZ3->ZZ3_NATREC
                                    Else
									  SC5->C5_NATUREZ := ZZ3->ZZ3_NAT
									EndIf
                                Else
								    If lRecIss              // verifica se recolhe ISS no cliente esta como SIM
									  SC5->C5_NATUREZ := ZZ3->ZZ3_NATREC
								    Else
									  SC5->C5_NATUREZ := ZZ3->ZZ3_NAT
								    Endif
								EndIf	
								SC5->(msUnlock())
								/*
								SC6->(dbSetOrder(1))
								SC6->(dbSeek(xFilial("SC6") + cPedido))
								do While !SC6->(EOF()) .and. SC6->C6_NUM == cPedido
								RecLock("SC6",.F.)
								SC6->C6_TES := ZZ3->ZZ3_TES
								SC6->(msUnlock())
								SC6->(dbSkip())
								ENDDO
								*/
							Endif
							
							Pergunte("MT460A",.F.)
							
							cRet := MaPvlNfs( _aItAglut ,;
							cSerieNf ,;
							.F. ,; //** Mostra Lancamentos Contabeis
							.F. ,; //** Aglutina Lançamentos
							.F. ,; //** Cont. On Line ?
							.F. ,; //** Cont. Custo On-line ?
							.F. ,; //** Reaj. na mesma N.F.?
							3 ,; //** Metodo calc.acr.fin? Taxa defl/Dif.lista/% Acrs.ped
							1,; //** Arred.prc unit vist?  Sempre/Nunca/Consumid.final
							.F.,;  //** Atualiza Cli.X Prod?
							.F. ,,,,,,; //** Ecf ?
							dDataBase )

										
							If Empty( cRet )
								If !lBlind
									Aadd( aDadosLog , { cPedido , 	'Pedido não faturado. Aglutinação de boletos.' } )
								Else
									ConOut( 'V5FAT007 - Pedido ' + cPedido + ' não faturado. Aglutinação de boletos.' )
								EndIf
								
							Else
								If !lBlind
									Aadd( aDadosLog , { cPedido , 	'Faturado com sucesso. Aglutinação de boletos. Ped.Ref ' + SC5->C5_P_REF + ' - NF ' + cRet + ' Serie ' + cSerieNf } )
								Else
									ConOut( 'V5FAT007 - Pedido ' + cPedido + ' faturado com sucesso. Aglutinação de boletos. Ped.Ref ' + SC5->C5_P_REF + ' - NF ' + cRet + ' Serie ' + cSerieNf )
								EndIf
								If Len(aDados) > 0
										// POSICIONANDO NA CHAVE PARA TROCA DE NOTAS CLIENTE + LOJA  + PRODUTO
									cCliente := aDados[i][POS_CLIENTE]
									cLoja := aDados[i][POS_LOJA]
									cProduto := aDados[i][POS_PRODUTO]
									cPedido := aDados[i][POS_PED]
								Endif
								aAuxNotas := {}
								aAdd(aAuxNotas,cRet)
								aAdd(aAuxNotas,cSerieNF)
		
								nPos := AScan(aAuxCli, {|x| x[1] == cCliente+cPedido})
								If nPos == 0
									aAdd(aAuxCli,{cCliente+cPedido , { AClone(aAuxNotas)} , '' })
								Else
									aAdd(aAuxCli[nPos][2], AClone(aAuxNotas))
								Endif
										
								
								/*
								* Atualiza campo F2_P_REF
								*/
								TcSqlExec( "UPDATE " + RetSqlName( "SF2" ) + " SET F2_P_REF = '" + SC5->C5_P_REF + "', F2_P_AGLUT = 'S' WHERE F2_FILIAL = '" + xFilial( 'SF2' ) + "' AND " +;
								"F2_DOC = '" + cRet + "' AND F2_SERIE = '" + cSerieNf + "' AND F2_CLIENTE = '" + SC5->C5_CLIENTE + "' AND F2_LOJA = '" + SC5->C5_LOJACLI + "' " )
								
								/*
								* Atualiza campo D2_P_REF
								*/
								TcSqlExec( "UPDATE " + RetSqlName( "SD2" ) + " SET D2_P_REF = '" + SC5->C5_P_REF + "' WHERE D2_FILIAL = '" + xFilial( 'SD2' ) + "' AND " +;
								"D2_DOC = '" + cRet + "' AND D2_SERIE = '" + cSerieNf + "' AND D2_CLIENTE = '" + SC5->C5_CLIENTE + "' AND D2_LOJA = '" + SC5->C5_LOJACLI + "' " )
								
								/*
								* Atualiza campo E1_P_REF
								*/
								TcSqlExec( "UPDATE " + RetSqlName( "SE1" ) + " SET E1_P_REF = '" + SC5->C5_P_REF + "', E1_P_BOL = '"+cImpBol+"', E1_P_AGLUT = 'S' WHERE E1_FILIAL = '" + xFilial( 'SE1' ) + "' AND " +;
								"E1_NUM = '" + cRet + "' AND E1_SERIE = '" + cSerieNf + "' AND E1_CLIENTE = '" + SC5->C5_CLIENTE + "' AND E1_LOJA = '" + SC5->C5_LOJACLI + "' " )
								
								_aNotas := {}
								
								If SA1->A1_XBOLUNI == 'S' .And. Left(cTpProd,2)  != "ME" // Ajuste em 13/08/2019.
								///If SA1->A1_XBOLUNI == 'S' .And. Left(cTpProd,2)  != "MM" // Ajuste em 13/08/2019.     // Triyo 13/11/2020
									AAdd(_aNotas, cRet)
									AAdd(_aNotas, cSerieNf)
									AAdd(_aNotas, SC5->C5_P_REF)
									AAdd(_aNotas, SC5->C5_CONDPAG)
									AAdd(_aNotas, .F.) // Cliente nao aglutina
									
									_nPos_L := AScan(_aLiquid, {|l| l[1] == SC5->C5_P_REF })
									If _nPos_L == 0
										AAdd(_aLiquid, {SC5->C5_P_REF, {AClone(_aNotas)}}) // Armazena os numeros das notas e serie para a Liquidação (FINA460).
									Else
										AAdd(_aLiquid[_nPos_L][2], AClone(_aNotas))
									EndIf
								EndIf
								
							EndIf
							
						Else
							If !lBlind
								Aadd( aDadosLog , { cPedido , 	'Produto não encontrado. Aglutinação de boletos.' } )
							Else
								ConOut( 'V5FAT007 - Produto não encontrado. Aglutinação de boletos.' )
							EndIf
							
						EndIf
						
					Next _nN
					
					Conout('V5FAT007 - Fim do faturamento do pedido ' + SC5->C5_P_REF + ' Hora: ' + Time())
					
				EndIf
				
			Else
				If !lBlind
					Aadd( aDadosLog , { cPedido , 	'Não há itens liberados para faturar.' } )
				Else
					ConOut( 'V5FAT007 - Não há itens liberados para faturar.' )
				EndIf
				
			EndIf
			
		EndIf
		
	EndIf
	
	// Add por Raphael - Cyberpolos 08/10/2019 | controla qtd de itens a serem processados, para que não haja erro de limite de elementos no array(_aLiquid[2])
	// Se atingir o limite estipulado, sai do FOR
	If _nCont >= 500 .and.  i < Len(aDados)
		
		If 	_cPedVogel <>  Alltrim(aDados[ i + 1][ 12 ])   //Pedido Vogel atual <> Proximo pedido Vogel
			
			i := Len( aDados )
			
		EndIf
		
	EndIf
	
Next


aBkpaDados := AClone(aDados)

//Restaura array para novo filtro
aDados := aClone(aBkpaDados)

// Ordenando dados para clientes que aglutinam acrescetando produto
aDados :=  ASort( aDados  ,,, { | x , y | x[ POS_PRODUTO ]  + x[ POS_CLIENTE ] +  x[ POS_LOJA ]  + x[POS_PED] <  y[ POS_PRODUTO ]  + y[ POS_CLIENTE ] +  y[ POS_LOJA ]  + y [POS_PED]} )

//---------------------------------------------------------------------------------------------
// ELIMINANDO PRODUTOS JA GERADOS QUE NAO AGLUTINAM OU QUE AGLUTINAM MAS SEPARAM POR PRODUTOS
// -------------------------------------------------------------------------------------------
While .T.
	
	// Enquanto houve itens que nao aglutinam, processa a rotina até nao ter mais
	//If Ascan( aDados , { | x | x[POS_AGLUTPED] != "S" } ) == 0 .And.  Ascan( aDados , { | x | x[14] != "S" } ) == 0
	If Ascan( aDados , { | x | x[POS_AGLUTPED] != "S" } )   == 0
		Exit
	Endif
	
	For i :=  1  To Len(aDados)
		If aDados[i][POS_AGLUTPED] != "S" // .OR. aDados[i][14] # 'S'
			aDel(aDados,i)
			aSize(aDados,Len(aDados)-1)
			Exit
		Endif
	Next
	
End

//--------------------------------------------------------------------------------------------
//
//--------------------------------------------------------------------------------------------

If Len(aDados) > 0
	
	// POSICIONANDO NA CHAVE PARA TROCA DE NOTAS CLIENTE + LOJA  + PRODUTO
	cCliente := aDados[1][POS_CLIENTE]
	cLoja := aDados[1][POS_LOJA]
	cProduto := aDados[1][POS_PRODUTO]
	
	
Endif

//Faturamento danfe nao aceita quebras mesmo cliente Aglut Ped
If Left(cTpProd,2) == "ME"
	aDados := {}
Endif

For i := 1 To Len( aDados )
	
	// SE TROCOU A CHAVE, GERA NF
	If  cCliente + cLoja != aDados[i][POS_CLIENTE] + aDados[i][POS_LOJA]   .OR. cProduto != aDados[i][POS_PRODUTO]  // .OR.  i == 1
		
		
		Pergunte("MT460A",.F.)
		
		cRet := MaPvlNfs( aProdsAglut ,;
		cSerieNf ,;
		.F. ,; //** Mostra Lancamentos Contabeis
		.F. ,; //** Aglutina Lanuamentos
		.F. ,; //** Cont. On Line ?
		.F. ,; //** Cont. Custo On-line ?
		.F. ,; //** Reaj. na mesma N.F.?
		3 ,; //** Metodo calc.acr.fin? Taxa defl/Dif.lista/% Acrs.ped
		1,; //** Arred.prc unit vist?  Sempre/Nunca/Consumid.final
		.F.,;  //** Atualiza Cli.X Prod?
		.F. ,,,,,,; //** Ecf ?
		dDataBase )
		
		//Atualizando ID por cliente
		aAuxNotas := {}
		aAdd(aAuxNotas,cRet)
		aAdd(aAuxNotas,cSerieNF)
		
		nPos := AScan(aAuxCli, {|x| x[1] == cCliente})
		If nPos == 0
			aAdd(aAuxCli,{cCliente , { AClone(aAuxNotas)} , '' })
		Else
			aAdd(aAuxCli[nPos][2], AClone(aAuxNotas))
		Endif
		
		
		aLibsPed := {} // Zerando os pedidos que ja foram liberados
		
		If Empty( cRet )
			If !lBlind
				Aadd( aDadosLog , { cPedido , 	'Pedido não faturado. Aglutinação de boletos.' } )
			Else
				ConOut( 'V5FAT007 - Pedido ' + cPedido + ' não faturado. Aglutinação de boletos.' )
			EndIf
			
		Else
			If !lBlind
				
				//Customiza mensagem de pedidods
				If Len( aPedsAglut ) > 0
					For nX := 1 To len(aPedsAglut)
						cPedidos += aPedsAglut[nX] + "/"
					Next
					cPedidos := Left(cPedidos,Len(cPedidos)-1)
				Endif
				
				//Aadd( aDadosLog , { cPedidos , 	'Faturado com sucesso. Aglutinação de boletos. Ped.Ref ' + SC5->C5_P_REF + ' - NF ' + cRet + ' Serie ' + cSerieNf } )
				Aadd( aDadosLog , { cPedidos , 	'Faturado com sucesso. Aglutinação de boletos. NF ' + cRet + ' Serie ' + cSerieNf } )
			Else
				ConOut( 'V5FAT007 - Pedido ' + cPedido + ' faturado com sucesso. Aglutinação de boletos. Ped.Ref ' + SC5->C5_P_REF + ' - NF ' + cRet + ' Serie ' + cSerieNf )
			EndIf
			
			// ARMAZENANDO DADOS PARA GERACAO DO TITULO AGL
			_aNotas := {}
			
			SA1->(dbSetOrder(1))
			SA1->(dbSeek( FWxFilial("SA1") + cCliente + cLoja ))
			
			cImpBol := SA1->A1_XBOLDEP
			
			SC5->(dbSeek( FWxFilial("SC5") + aDados[i][POS_PED] ))
		
			If Empty(SC5->C5_P_AGLUT)
				If SA1->A1_XAGLPED == 'S'
					cAglut := "S"
				Else
					cAglut := "N"
				Endif
			ElseIf 	 SC5->C5_P_AGLUT == 'S'
				cAglut := "S"
			Else
				cAglut := "N"
			Endif

				
			
			
			/*
			* Atualiza campo F2_P_REF
			*/
			TcSqlExec( "UPDATE " + RetSqlName( "SF2" ) + " SET F2_P_REF = 'AGLUT', F2_P_AGLUT = '" + cAglut + "' WHERE F2_FILIAL = '" + xFilial( 'SF2' ) + "' AND " +;
			"F2_DOC = '" + cRet + "' AND F2_SERIE = '" + cSerieNf + "' " )
			
			/*
			* Atualiza campo D2_P_REF
			*/
			TcSqlExec( "UPDATE " + RetSqlName( "SD2" ) + " SET D2_P_REF = 'AGLUT' WHERE D2_FILIAL = '" + xFilial( 'SD2' ) + "' AND " +;
			"D2_DOC = '" + cRet + "' AND D2_SERIE = '" + cSerieNf + "' ")
			
			/*
			* Atualiza campo E1_P_REF
			*/
			TcSqlExec( "UPDATE " + RetSqlName( "SE1" ) + " SET E1_P_REF = 'AGLUT', E1_P_BOL = '"+cImpBol+"', E1_P_AGLUT = '" + cAglut + "'   WHERE E1_FILIAL = '" + xFilial( 'SE1' ) + "' AND " +;
			"E1_NUM = '" + cRet + "' AND E1_SERIE = '" + cSerieNf + "' " )
			
			
			If SA1->A1_XBOLUNI == 'S' .And. Left(cTpProd,2)  != "ME" // Ajuste em 13/08/2019.
				AAdd(_aNotas, cRet)
				AAdd(_aNotas, cSerieNf)
				AAdd(_aNotas, cCliente+cLoja)
				AAdd(_aNotas, SC5->C5_CONDPAG)
				AAdd(_aNotas, .T.) // Cliente Aglutina
				
				// ARMAZENA PEDIDOS AGLUTINADOS
				If Len( aPedsAglut ) > 0
					AAdd(_aNotas , aPedsAglut )
				Endif
				
				_nPos_L := AScan(_aLiquid, {|l| l[1] == cCliente+cLoja})
				If _nPos_L == 0
					AAdd(_aLiquid, { cCliente+cLoja, {AClone(_aNotas)}}) // Armazena os numeros das notas e serie para a Liquidação (FINA460).
				Else
					AAdd(_aLiquid[_nPos_L][2], AClone(_aNotas))
				EndIf
				
			EndIf
			
			aLibsPed := {}
			cPedidos := ""
			aPedsAglut := {}
			
			
		Endif
		
		// ATUALIZANDO DADOS
		cPedido := aDados[i][POS_PED]
		aProdsAglut := {}
		
		cCliente := aDados[i][POS_CLIENTE]
		cLoja := aDados[i][POS_LOJA]
		cProduto := aDados[i][POS_PRODUTO]
		
		
	Endif
	
	
	// POSICIONANDO NO PEDIDO
	SC5->( DbSetOrder( 1 ) )
	SC5->( DbSeek( xFilial('SC5') + aDados[i][POS_PED] ) )

	If Alltrim(SC5->C5_RECISS) <> ""
		lRecIssC5 := .T.
	Else
		lRecIssC5 := .F.
	Endif
	
	aPvlNfs:={}
	aBloqueio:={}
	
	//REALIZA A LIBERACAO DO MESMO
	Ma410LbNfs(2,@aPvlNfs,@aBloqueio)
	Ma410LbNfs(1,@aPvlNfs,@aBloqueio)
	
	
	// ADICIONA O PEDIDO PARA GRAVAR OS PEDIDOS AGLUTINADOS EM UMA FATURA
	If Ascan( aPedsAglut , { | x | x == aDados[i][POS_PED]  } ) == 0
		aAdd ( aPedsAglut , aDados[i][POS_PED] )
	Endif
	
	// Adiciona pedidos que aglutinam o produto, pois ira salvar em tabela de histórico para controle
	SA1->(DbSetOrder(1)) // Indice 1 - A1_FILIAL+A1_COD+A1_LOJA
	SA1->(DbSeek(xFilial('SA1')+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
	
	//iss
	If SA1->A1_RECISS == "1"
		lRecIss := .T.
	Else
		lRecIss := .F.
	Endif
	
	cTipoPes := Left(SA1->A1_XTIPO,2)
	cImpBol := SA1->A1_XBOLDEP
	
	// Procura o Produto no pedido posicionado
	For nX := 1 To Len(aPvlNfs)
		If Alltrim(cProduto) == Alltrim(aPvlNfs[nX][6]) .And. Ascan( aProdsAglut , { | x | x[1] == aPvlNfs[nX][1] .And. x[2] == aPvlNfs[nX][2] } ) == 0
			aAdd ( aProdsAglut , aPvlNfs[nX])
		Endif
	Next
	
	SB1->(DbSetOrder(1)) // Indice 1 - B1_FILIAL+B1_COD
	If SB1->(DbSeek(xFilial('SB1')+aDados[i][POS_PRODUTO])) // Posição 6 é o código do produto.
		
		_cCodPro := ''
		
		cxTipo	 := Left(SB1->B1_XTIPO,2) // Obtem o tipo de cada item da nota, pois a serie é designada de acordo com o tipo.
		cTipoPrd := SB1->B1_TIPO
		cSerieNf := ''
		
		VerSerieNf(@cSerieNf , cTipoPrd)
		
		If Empty( cSerieNf )
			If !lBlind
				Aadd( aDadosLog , { '' , 'Serie não parametrizada para o tipo de produto ' + cTipoPrd + '. Aglutinação de boletos. Contatar a TI.' } )
			Else
				ConOut( 'V5FAT007 - Serie não parametrizada para o tipo de produto ' + cTipoPrd + '. Aglutinação de boletos. Contatar a TI.' )
			EndIf
			
			Break
		EndIf
		
		cSerieNf := PadR(cSerieNf, 3)
		
		// Posiciona no SX5 para evitar o faturamento do pedido com série errada.
		SX5->(DbSetOrder(1)) // Indice 1 - X5_FILIAL+X5_TABELA+X5_CHAVE
		SX5->(DbSeek(xFilial('SX5')+'01'+cSerieNf))
		
		// Procura a Natureza na tabela ZZ3 e grava no cabeçalho do Pedido
		ZZ3->(dbSetOrder(1))
		If ZZ3->(dbSeek(xFilial("ZZ3") + cxTipo + cTipoPes))
			SC5->(RecLock("SC5",.F.))
			If lRecIssC5                // Triyo - 17/11/2020 - Se C5_RECISS = .T. ele verifica o A1_RECISS
                If Alltrim(SC5->C5_RECISS) == "1"     // verifica se recolhe ISS no pedido esta como SIM
					SC5->C5_NATUREZ := ZZ3->ZZ3_NATREC
                Else
					SC5->C5_NATUREZ := ZZ3->ZZ3_NAT
				EndIf
            Else
				If lRecIss              // verifica se recolhe ISS no cliente esta como SIM
					 SC5->C5_NATUREZ := ZZ3->ZZ3_NATREC
				Else
					SC5->C5_NATUREZ := ZZ3->ZZ3_NAT
				Endif
			EndIf	

			
		Endif
		
	Endif
	
Next

// GERANDO ULTIMA NOTA APOS O LAÇO
If Len(aProdsAglut)  > 0
	
	Pergunte("MT460A",.F.)
	
	cRet := MaPvlNfs( aProdsAglut ,;
	cSerieNf ,;
	.F. ,; //** Mostra Lancamentos Contabeis
	.F. ,; //** Aglutina Lanuamentos
	.F. ,; //** Cont. On Line ?
	.F. ,; //** Cont. Custo On-line ?
	.F. ,; //** Reaj. na mesma N.F.?
	3 ,; //** Metodo calc.acr.fin? Taxa defl/Dif.lista/% Acrs.ped
	1,; //** Arred.prc unit vist?  Sempre/Nunca/Consumid.final
	.F.,;  //** Atualiza Cli.X Prod?
	.F. ,,,,,,; //** Ecf ?
	dDataBase )
	
	If Empty( cRet )
		If !lBlind
			Aadd( aDadosLog , { cPedidos , 	'Pedido não faturado. Aglutinação de boletos.' } )
		Else
			ConOut( 'V5FAT007 - Pedido ' + cPedidos + ' não faturado. Aglutinação de boletos.' )
		EndIf
		
	Else
		
		//Atualizando ID por cliente
		aAuxNotas := {}
		aAdd(aAuxNotas,cRet)
		aAdd(aAuxNotas,cSerieNF)
		
		nPos := AScan(aAuxCli, {|x| x[1] == aDados[Len(aDados)][POS_CLIENTE]})
		If nPos == 0
			aAdd(aAuxCli,{aDados[Len(aDados)][POS_CLIENTE] , { AClone(aAuxNotas)}, '' })
		Else
			aAdd(aAuxCli[nPos][2], AClone(aAuxNotas))
		Endif
		
		
		// DADOS PARA AGLUTINACAO
		SA1->(dbSetOrder(1))
		SA1->(dbSeek( FWxFilial("SA1") + cCliente + cLoja ))
		
		SC5->(dbSeek( FWxFilial("SC5") + aDados[1][POS_PED] ))
		
		cImpBol := SA1->A1_XBOLDEP
	
		If Empty(SC5->C5_P_AGLUT)
			If SA1->A1_XAGLPED == 'S'
				cAglut := "S"
			Else
				cAglut := "N"
			Endif
		ElseIf 	 SC5->C5_P_AGLUT == 'S'
			cAglut := "S"
		Else
			cAglut := "N"
		Endif

		
		If SA1->A1_XBOLUNI == 'S' .And. Left(cTpProd,2)  != "ME" // Ajuste em 13/08/2019.

			_aNotas := {}
			
			AAdd(_aNotas, cRet)
			AAdd(_aNotas, cSerieNf)
			AAdd(_aNotas, cCliente+cLoja)
			AAdd(_aNotas, SC5->C5_CONDPAG)
			AAdd(_aNotas, .T.) // Cliente Aglutina
			
			// ARMAZENA PEDIDOS AGLUTINADOS
			If Len( aPedsAglut ) > 0
				AAdd(_aNotas , aPedsAglut )
			Endif
			
			_nPos_L := AScan(_aLiquid, {|l| l[1] == cCliente+cLoja})
			If _nPos_L == 0
				AAdd(_aLiquid, { cCliente+cLoja, {AClone(_aNotas)}}) // Armazena os numeros das notas e serie para a Liquidação (FINA460).
			Else
				AAdd(_aLiquid[_nPos_L][2], AClone(_aNotas))
			EndIf
			
		EndIf
		
		If !lBlind
			//Customiza mensagem de pedidods
			If Len( aPedsAglut ) > 0
				For nX := 1 To len(aPedsAglut)
					cPedidos += aPedsAglut[nX] + "/"
				Next
				cPedidos := Left(cPedidos,Len(cPedidos)-1)
			Endif
			//Aadd( aDadosLog , { cPedidos , 	'Faturado com sucesso. Aglutinação de boletos. Ped.Ref ' + SC5->C5_P_REF + ' - NF ' + cRet + ' Serie ' + cSerieNf } )
			Aadd( aDadosLog , { cPedidos , 	'Faturado com sucesso. Aglutinação de boletos. NF ' + cRet + ' Serie ' + cSerieNf } )
			
			/*
			* Atualiza campo F2_P_REF
			*/
			TcSqlExec( "UPDATE " + RetSqlName( "SF2" ) + " SET F2_P_REF = 'AGLUT', F2_P_AGLUT = '" + cAglut + "'  WHERE F2_FILIAL = '" + xFilial( 'SF2' ) + "' AND " +;
			"F2_DOC = '" + cRet + "' AND F2_SERIE = '" + cSerieNf + "' " )
			
			/*
			* Atualiza campo D2_P_REF
			*/
			TcSqlExec( "UPDATE " + RetSqlName( "SD2" ) + " SET D2_P_REF = 'AGLUT' WHERE D2_FILIAL = '" + xFilial( 'SD2' ) + "' AND " +;
			"D2_DOC = '" + cRet + "' AND D2_SERIE = '" + cSerieNf + "' ")
			
			/*
			* Atualiza campo E1_P_REF
			*/
			TcSqlExec( "UPDATE " + RetSqlName( "SE1" ) + " SET E1_P_REF = 'AGLUT', E1_P_BOL = '"+SC5->C5_P_BOL+"', E1_P_AGLUT = '" + cAglut + "'  WHERE E1_FILIAL = '" + xFilial( 'SE1' ) + "' AND " +;
			"E1_NUM = '" + cRet + "' AND E1_SERIE = '" + cSerieNf + "' " )
			
		Else
			ConOut( 'V5FAT007 - Pedido ' + cPedido + ' faturado com sucesso. Aglutinação de boletos. Ped.Ref ' + SC5->C5_P_REF + ' - NF ' + cRet + ' Serie ' + cSerieNf )
		EndIf
		
	Endif

Endif


//Atualizando campos


For nX := 1 To Len(aAuxCli)
	
    cId := GetMv("ES_REFSE1")
    PutMv("ES_REFSE1",Soma1(cId))
	
   	aAuxCli[nX][3] := Alltrim(cId)
	

	For nZ := 1 To Len(aAuxCli[nX][2])
    
       TcSqlExec( "UPDATE " + RetSqlName( "SF2" ) + " SET F2_XID = '" + aAuxCli[nX][3] + "' WHERE F2_FILIAL = '" + xFilial( 'SF2' ) + "' AND " +;
       "F2_DOC = '" + aAuxCli[nX][2][nZ][1] + "' AND F2_SERIE = '" + aAuxCli[nX][2][nZ][2] + "' AND F2_XID = '' " )

    	TcSqlExec( "UPDATE " + RetSqlName( "SE1" ) + " SET E1_XID = '" + aAuxCli[nX][3] + "'  WHERE E1_FILIAL = '" + xFilial( 'SE1' ) + "' AND " +;
        "E1_NUM = '" + aAuxCli[nX][2][nZ][1] + "' AND E1_SERIE = '" + aAuxCli[nX][2][nZ][2] + "' AND E1_XID = '' " )
    
       	TcSqlExec( "UPDATE " + RetSqlName( "SD2" ) + " SET D2_XID = '" + aAuxCli[nX][3] + "' WHERE D2_FILIAL = '" + xFilial( 'SD2' ) + "' AND " +;
        "D2_DOC = '" + aAuxCli[nX][2][nZ][1] + "' AND D2_SERIE = '" + aAuxCli[nX][2][nZ][2] + "' AND  D2_XID = '' " )
		
    ///Next


	    //Tabela integradora
        dbSelectArea("PR1")
        PR1->(DbSetOrder(2))
        //Grava PR1 - Para envio do tracking
   		If !PR1->(DbSeek(xFilial("PR1") + aAuxCli[nX][3] ) )
		
	    	RecLock("PR1",.T.)
		
    		PR1->PR1_FILIAL := xFilial("PR1")
    		PR1->PR1_ALIAS  := "SF2"
    		PR1->PR1_RECNO  := 0
    		PR1->PR1_TIPREQ := "2"
    		PR1->PR1_STINT  := "P"
    		PR1->PR1_CHAVE  := aAuxCli[nX][3]
		
		   	PR1->(MsUnlock())
				
    	Endif

	Next	
	
Next

/*/
//Verifica as notas fiscais que estão sem o numero de identificação //Triyo - 09/11/2020

cQuery := " SELECT  " + CRLF
cQuery += " SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA,SF2.F2_EMISSAO, SF2.F2_XID "   + CRLF
cQuery += " FROM " + RetSqlName("SF2") + " SF2" + CRLF
cQuery += " WHERE SF2.D_E_L_E_T_ = '' "   + CRLF
cQuery += " AND   SF2.F2_XID = '' "     + CRLF 
cQuery += " AND   SF2.F2_EMISSAO =  '" + DtoS(dDatabase) + "' "  + CRLF
cQuery += " ORDER BY SF2.F2_EMISSAO,SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA " + CRLF


If Select("QRY") > 0
	dbSelectArea("QRY")
	QRY->(dbCloseArea())
EndIf

TcQuery cQuery New Alias "QRY"

DbSelectArea('QRY')
QRY->(dbGoTop())


// Grava o numero de identificação nas notas fiscais  //Triyo - 09/11/2020
While !QRY->(EOF())

    _cFilial := xFilial("PR1")
    _cDoc := QRY->F2_DOC
    _cSerie := QRY->F2_SERIE

	cId := GetMv("ES_REFSE1")
    PutMv("ES_REFSE1",Soma1(cId))

    TcSqlExec( "UPDATE " + RetSqlName( "SF2" ) + " SET F2_XID = '" + cId + "' WHERE F2_FILIAL = '" + xFilial( 'SF2' ) + "' AND " +;
	"F2_DOC = '" + _cDoc + "' AND F2_SERIE = '" + _cSerie + "' " )
		
	TcSqlExec( "UPDATE " + RetSqlName( "SE1" ) + " SET E1_XID = '" + cId + "'  WHERE E1_FILIAL = '" + xFilial( 'SE1' ) + "' AND " +;
	"E1_NUM = '" + _cDoc + "' AND E1_SERIE = '" + _cSerie + "' " )
    
	TcSqlExec( "UPDATE " + RetSqlName( "SD2" ) + " SET D2_XID = '" + cId + "' WHERE D2_FILIAL = '" + xFilial( 'SD2' ) + "' AND " +;
	"D2_DOC = '" + _cDoc + "' AND D2_SERIE = '" + _cSerie + "'  " )

    //Grava PR1 - Para envio do tracking

  	//Tabela integradora

	If !PR1->(DbSeek(xFilial("PR1") + cId ) )
		
	    RecLock("PR1",.T.)
		
    	PR1->PR1_FILIAL := xFilial("PR1")
    	PR1->PR1_ALIAS  := "SF2"
    	PR1->PR1_RECNO  := 0
    	PR1->PR1_TIPREQ := "2"
    	PR1->PR1_STINT  := "P"
    	PR1->PR1_CHAVE  := cId
		
	    PR1->(MsUnlock())
 	EndIf

    QRY->(dbSkip())

End
/*/

MemoWrite( GetTempPath() + "V5FAT007.txt", VarInfo("aAuxCli", aAuxCli, , .F.))

// Novo trecho em 12/09/2019.
If Len(_aLiquid) > 0
	
	For _nP := 1 To Len(_aLiquid)
		
		Conout('V5FAT007 - Inicio da geracao da liquidacao do pedido ' + _aLiquid[_nP][1] + ' Hora: ' + Time())
		
		// Filtro para encontrar os titulos a serem liquidados.
		_cFil460 := "E1_FILIAL == '" + xFilial('SE1') + "' .And. "
		_cFil460 += "E1_SITUACA $ '0FG' .And. "
		_cFil460 += "E1_SALDO > 0 .And. "
		_cFil460 += "( "
		
		_nVal460 := 0
		_nDecres := 0
		
		SE1->(DbSetOrder(1)) // Indice 1 - E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		//VarInfo('_aLiquid[_nP][2]', _aLiquid[_nP][2])
		
		For _nD := 1 To Len(_aLiquid[_nP][2])
			
			If SE1->(DbSeek(xFilial('SE1')+_aLiquid[_nP][2][_nD][2]+_aLiquid[_nP][2][_nD][1]))
				
				If _nD > 1
					_cFil460 += ".Or. "
				EndIf
				
				_cFil460 += "(E1_NUM == '" + SE1->E1_NUM + "' .And. "
				_cFil460 += "E1_PREFIXO == '" + SE1->E1_PREFIXO + "') "
				
				While SE1->(!EOF()) .And. SE1->E1_FILIAL == xFilial('SE1') .And. AllTrim(SE1->E1_PREFIXO) == AllTrim(_aLiquid[_nP][2][_nD][2]) .And.;
					AllTrim(SE1->E1_NUM) == AllTrim(_aLiquid[_nP][2][_nD][1]) // Loop para o caso de condição de pagamento parcelada.
					
					//If AllTrim(SE1->E1_TIPO) $ 'NF/DIC' // Não soma impostos gerados via retenção.
					
					_nVal460 += SE1->E1_VALOR // - SE1->E1_IRRF - SE1->E1_CSLL - SE1->E1_COFINS - SE1->E1_PIS)
					If SE1->E1_TIPO <> "NF "
						_nDecres += SE1->E1_VALOR
					Endif
					
					If _nD == Len(_aLiquid[_nP][2])
						
						// Gera a nova duplicata com os dados da ultima nota.
						_cNat460 := GetMv("ES_NATAGL")  // Natureza no parâmetro
						_cCli460 := SE1->E1_CLIENTE
						_cMoe460 := SE1->E1_MOEDA
						_cLoj460 := SE1->E1_LOJA
						_dVen460 := SE1->E1_VENCTO
						
					If ! _aLiquid[_nP][2][_nD][5]
							_cNum460 := SubStr(_aLiquid[_nP][1], 1, TamSx3('E1_NUM')[1]) // Numero da duplicata liquidada será o numero do pedido Sistec.
					Else
							cNum460 := MontaNum(SE1->E1_CLIENTE , SE1->E1_LOJA , SE1->E1_PREFIXO  ) // Numero da duplicata liquidada será o numero do pedido Sistec.
					Endif
					If	! _aLiquid[_nP][2][1][5]
						IF Empty(SE1->E1_PEDIDO)
							cqry := "SLECT * FROM "+RetSqlNAme("SE1")+" where E1_NUM = '"+SE1->E1_NUM+"' and E1_TIPO = 'NF' and E1_CLIENTE = '"+SE1->E1_CLIENTE+"' And E1_LOJA = '"+SE1->E1_LOJA+"' "
							cqry := changeQuery(cqry)
							cAliasF := GetNextAlias()
							//DBUseArea(.T.,/*cDriver*/,cqry,cAliasF,.T.,.T.)
							DbUseArea(.T., "TOPCONN", TcGenQry(,, cqry), cAliasF, .T., .T.)
							cPedidoNe := (cAliasF)->E1_PEDIDO
						Else
							cPedidoNe := SE1->E1_PEDIDO
						EndIF
						nPos := AScan(aAuxCli, {|x| x[1] == SE1->E1_CLIENTE+cPedidoNe })
					Else
						nPos := AScan(aAuxCli, {|x| x[1] == SE1->E1_CLIENTE})
					EndIF
						_cNum460 := aAuxCli[nPos][3]
						
						_cPag460 := _aLiquid[_nP][2][_nD][4] // SC5->C5_CONDPAG
						_dEmi460 := SE1->E1_EMISSAO
						
					EndIf
					
					//EndIf
					
					SE1->(DbSkip())
					
				EndDo
				
			EndIf
			
		Next _nD
		
		_cFil460 += ") .And. "
		_cFil460 += "DToS(E1_EMISSAO) == '" + DToS(_dEmi460) + "' .And. "
		_cFil460 += "E1_NUMLIQ == '" + Space(TamSx3("E1_NUMLIQ")[1]) + "' .And. "
		_cFil460 += "E1_CLIENTE == '" + _cCli460 + "' .And. "
		_cFil460 += "E1_LOJA == '" + _cLoj460 + "' " // "' .And. "
		//		_cFil460 += "AllTrim(E1_TIPO) $ 'NF/DIC'" // Para o filtro, não pode constar os impostos via retenção.
		
		// Tratamento das duplicatas para geração da Liquidação (FINA460).
		_aCab460 := { {"cCondicao"	, _cPag460	},;
		{"cNatureza"	, _cNat460	},;
		{"E1_TIPO"	, _cTip460	},;
		{"cCliente"	, _cCli460	},;
		{"nMoeda"		, _cMoe460	},;
		{"cLoja"		, _cLoj460	}}
		
		_cEmit460 := 'Aglutinação de boletos.'
		_aIte460  := {}
		
		// Dados do titulo que será gerado.
		Aadd(_aIte460, {{"E1_PREFIXO"	, _cPre460	},; // Prefixo.
		{"E1_BCOCHQ" 	, "001"  	},; // Banco do cheque.
		{"E1_AGECHQ" 	, "001"  	},; // Agencia do cheque.
		{"E1_CTACHQ" 	, "001"  	},; // Conta do cheque.
		{"E1_NUM"		, _cNum460	},; // Numero do cheque (dará origem ao numero do titulo).
		{"E1_EMITCHQ" 	, _cEmit460	},; // Emitente do cheque.
		{"E1_VENCTO" 	, _dVen460	},; // Vencimento.
		{"E1_VLCRUZ"	, _nVal460 	},; // Valor do cheque/titulo.
		{"E1_ACRESC"	, 0			},; // Acrescimo.
		{"E1_DECRESC"	, _nDecres	* 	2	}}) // Decrescimo.
		
		MSExecAuto({|a,b,c,d,e| FINA460(a,b,c,d,e) },, _aCab460, _aIte460, 3, _cFil460) // Liquidação.
		
		If lMsErroAuto
			If !lBlind
				MsgAlert('Erro ao gerar aglutinação. Entrar em contato com T.I . E enviar a mensagem a seguir','Atencao')
				
				MostraErro()
			Else
				ConOut("V5FAT007 - Erro ao gerar aglutinação. Entrar em contato com T.I . E enviar a mensagem a seguir")
			EndIf
			
		Else
			If !lBlind
				cMsgLiq := ""
				//Modifica a mensagem se for varios pedidos
				If _aLiquid[_nP][2][1][5]
					For nX := 1 To Len(_aLiquid[_nP][2][1][6])
						cMsgLiq += _aLiquid[_nP][2][1][6][nX] + "/"
					Next
					
					cMsgLiq := Left(cMsgLiq, Len(cMsgLiq)-1)
					
					Aadd( aDadosLog , { cMsgLiq , 	'Liquidação realizada com sucesso. Aglutinação de boletos. Ped.Ref(s) ' + cMsgLiq + ' - NF ' + _cNum460 + ' Serie ' + _cPre460 } )
				Else
					Aadd( aDadosLog , { cPedido , 	'Liquidação realizada com sucesso. Aglutinação de boletos. Ped.Ref ' + _aLiquid[_nP][1] + ' - NF ' + _cNum460 + ' Serie ' + _cPre460 } )
				Endif
				
			Else
				ConOut( 'V5FAT007 - Liquidação realizada com sucesso. Aglutinação de boletos. Ped.Ref ' + _aLiquid[_nP][1] + ' - NF ' + _cNum460 + ' Serie ' + _cPre460 )
			EndIf
			
			// Se o cliente aglutina pedidos
			If _aLiquid[_nP][2][1][5]
				//Atualiza tabela de amarrações
				Reclock("Z06",.T.)
				Z06_FILIAL := FWxFilial("Z06")
				Z06_FATURA := _cNum460
				Z06->(MsUnLock())
				For nX := 1 To Len(_aLiquid[_nP][2][1][6])
					
					Reclock("Z05",.T.)
					Z05_FILIAL := FWxFilial("Z05")
					Z05_PEDIDO := _aLiquid[_nP][2][1][6][nX]
					Z05_FATURA := _cNum460
					Z05->(MsUnLock())
					
				Next
				
			Endif
		EndIf
		
		dbSelectArea("SE1")
		dbSetOrder(1)
		If dbSeek(xFilial("SE1") + _cPre460 + _cNum460 + "A   " + _cTip460)
			nnValor := SE1->E1_VALOR - SE1->E1_DECRESC
			RecLock("SE1",.F.)
			SE1->E1_VALOR	:= nnValor
			SE1->E1_SALDO	:= nnValor
			SE1->E1_VLCRUZ	:= nnValor
			SE1->E1_DECRESC	:= 0
			SE1->E1_SDDECRE := 0
/* Alterado por Marcelo - 11/12/2020 - 15:59
            If  cImpBol == "1" 
			    If Empty(SE1->E1_BAIXA)
				   RecLock("SE1", .F.)
			       SE1->E1_PORTADO := "001"
			       SE1->E1_AGEDEP	:= "3347"
			       SE1->E1_CONTA	:= "99958090"
			       MsUnLock()	
			    EndIf   		
		    EndIf	
*/
			msUnlock()
		Endif
		
		Conout('V5FAT007 - Fim da geracao da liquidacao do pedido ' + _aLiquid[_nP][1] + ' Hora: ' + Time())
		
	Next _nP
	
	// Add por Raphael - Cyberpolos 08/10/2019 | controla qtd de itens a serem processados, para que não haja erro de limite de elementos no array(_aLiquid[2])
	// Se atingiu o limite estipulado, informa o usuario para processar a rotina novamente, já que não foram processados todos os itens.
	If _nCont >= 500
		If !lBlind
			MsgInfo("Devido a quantidade de itens, o processo de faturamento deve ser realizado novamente.","Atenção")
		Else
			ConOut("V5FAT007 - Devido a quantidade de itens, o processo de faturamento deve ser realizado novamente.","Atenção")
		EndIf
		
	EndIf
	
EndIf

End Sequence

cQuery := " SELECT " + CRLF
cQuery += " E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_SERIE, E1_TIPO, E1_EMISSAO, E1_CLIENTE, E1_LOJA, E1_TIPO " + CRLF
cQuery += " FROM " + RetSqlName("SE1") + " SE1" + CRLF
cQuery += " WHERE SE1.D_E_L_E_T_ =''  " + CRLF
cQuery += " AND E1_BAIXA <> '' " + CRLF
cQuery += " AND E1_PORTADO <> '' " + CRLF
cQuery += " AND E1_AGEDEP <> '' " + CRLF
cQuery += " AND E1_CONTA <> '' " + CRLF
cQuery += " AND E1_EMISSAO = '"+dtos(DDATABASE)+"' " + CRLF
cQuery += " ORDER BY E1_FILIAL,E1_CLIENTE,E1_LOJA,E1_PREFIXO,E1_NUM  " + CRLF

If Select("QRY") > 0
	dbSelectArea("QRY")
	QRY->(dbCloseArea())
EndIf

TcQuery cQuery New Alias "QRY"

DbSelectArea('QRY')
QRY->(dbGoTop())

While QRY->(!Eof())

    cCliente :=  QRY->(E1_CLIENTE)
	cLoja    :=  QRY->(E1_LOJA)
	cSerie   :=  QRY->(E1_PREFIXO)
	cNota    :=  QRY->(E1_NUM)
	cTipo    :=  QRY->(E1_TIPO)

    dbSelectArea("SE1")
    dbSetOrder(2)
    If dbSeek(xFilial("SE1") + cCliente + cLoja + cSerie + cNota)
		While	!SE1->(Eof()) .And. ;
			SE1->(E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM) == (xFilial("SE1") + cCliente + cLoja + cSerie + cNota) .And. ;
			SE1->E1_TIPO = cTipo
   
    		RecLock("SE1", .F.)
			SE1->E1_PORTADO := ""
			SE1->E1_AGEDEP	:= ""
			SE1->E1_CONTA	:= ""
			MsUnLock()	
			SE1->(DbSkip())
		End	
	EndIf
	QRY->(DbSkip())
End	  
	   	

Return

/*
Função...............: VerSerieNf
Objetivo.............: Retornar serie da nota de acordo com tipo de produto
Autor................: Leandro Brito ( BRL Consulting )
Data.................: 12/08/2016
*/
*---------------------------------------------------------------*
Static Function VerSerieNf( cSerieNf , cTipoPrd )
*---------------------------------------------------------------*
//Local dMesAtu := FirstDay( dDataBase )
Local cFilSX5 := xFilial("SX5")
If ZX3->( DbSeek( xFilial('ZX3') + cEmpAnt + cFilAnt + cTipoPrd ) )
	If !( cTipoPrd $ 'SC,ST' )
		cSerieNF := ZX3->ZX3_SERIE
	Else
		/*
		* Busca serie para o mes de Faturamento
		*/
		//cSerieNf 	:= Left( ZX3->ZX3_SERIE , 1 ) + '01'
		cSerieNF := ZX3->ZX3_SERIE
	EndIf
	//Verificar se precisa colocar filial no SX5
	If ZX3->ZX3_EXCLU
		cFilSX5 := cFilAnt
	EndIf
	/*
	* Insere serie na SX5 caso nao encontre
	*/
	If SX5->( DbSetOrder( 1 ), !DbSeek( cFilSX5 + PadR( '01' , Len( SX5->X5_TABELA ) ) + PadR( cSerieNF , Len( SX5->X5_CHAVE ) ) ) )
		SX5->( RecLock( "SX5" , .T. ) )
		SX5->X5_FILIAL := cFilSX5
		SX5->X5_TABELA := '01'
		SX5->X5_CHAVE  := cSerieNF
		SX5->X5_DESCRI := PadL( '1' , Len( SF2->F2_DOC ) , '0' )
		SX5->( MSUnlock() )
	EndIf
EndIf

Return

/*
Função...............: RetEspecie
Objetivo.............: Retornar especie para um determinado tipo de produto
Autor................: Leandro Brito ( BRL Consulting )
Data.................: 12/08/2016
*/
/*
*---------------------------------------------------------------*
Static Function RetEspecie( cTpPrd )
*---------------------------------------------------------------*
Local aEspecie := { { 'RV' , 'SPED' } , { 'SF' , 'FAT' } , { 'SR' , 'NFPS' } , { 'SC' , 'NFSC' } , { 'ST' , 'NTST' }, { 'ME' , 'SPED' } }
Local nPos
Local cEspecie := ''

If ( nPos := Ascan( aEspecie , { | x | x[ 1 ] == cTpPrd } ) ) > 0
cEspecie := aEspecie[ nPos ][ 2 ]
EndIf

Return( cEspecie )
*/
// Monta o Numero do Titulo aglutinado, em clientes que armazenam varios pedidos em um so
Static Function MontaNum(cCliente,cLoja,cPrefixo)

Local cAliasQry := GetNextAlias()
Local cData := Substr(Dtos(dDtIni),5,2) + Substr(Dtos(dDtIni),3,2) //Formata MMAA
Local cAux := ""
Local nTamSer := Len(cPrefixo)

BeginSQL Alias cAliasQry
	
	SELECT TOP 1 E1_NUM
	
	FROM %TABLE:SE1% SE1
	
	WHERE E1_FILIAL = %Exp:FWxFilial("SE1")%
	
	//AND E1_CLIENTE = %Exp:cCliente% AND E1_LOJA = %Exp:cLoja%
	
	AND E1_PREFIXO = 'AGL' // Aglutinados
	
	//AND SUBSTRING(E1_NUM,5,%Exp:nTamSer%) = %Exp:cPrefixo%
	
	AND SUBSTRING(E1_NUM,1,4) = %Exp:cData%
	
	AND SE1.D_E_L_E_T_ = ''
	
	ORDER BY R_E_C_N_O_ DESC
	
EndSQL

// Se ja existe gerado um arquivo naquela competencia apenas soma o sequencial do final
If !(cAliasQry)->(EOF())
	cAux := Right( Alltrim((cAliasQry)->E1_NUM) , 5 )
	cAux := Soma1(cAux,5)
	
	cRet := Left( (cAliasQry)->E1_NUM , TAM_ANOMES  )  + cAux
Else
	//Senao formata conforme MMDD + PREFIXO + SEQUENCIAL INICIANDO EM 01
	cRet := cData + "00001"
Endif

(cAliasQry)->(dbCloseArea())


Return cRet
