#include "rwmake.ch"

User Function ATUCODLMT( aParam )

Local	lAuto		:= (aParam != Nil)
Local	aTabelas	:= { 	{ "SA5", "A5", "A5_PRODUTO" },;
							{ "SB2", "B2", "B2_COD" },;
							{ "SB6", "B6", "B6_PRODUTO" },;
							{ "SB9", "B9", "B9_COD" },;
							{ "SC1", "C1", "C1_PRODUTO" },;
							{ "SC2", "C2", "C2_PRODUTO" },;
							{ "SC6", "C6", "C6_PRODUTO" },;
							{ "SC7", "C7", "C7_PRODUTO" },;
							{ "SD1", "D1", "D1_COD" },;
							{ "SD2", "D2", "D2_COD" },;
							{ "SD3", "D3", "D3_COD" },;
							{ "SD4", "D4", "D4_COD" },;
							{ "SG1", "G1", "G1_COD" },;
							{ "SZ3", "Z3", "Z3_PRODUTO" },;
							{ "SZ6", "Z6", "Z6_PRODUTO" },;
							{ "SZ9", "Z9", "Z9_COD" },;
							{ "SZA", "ZA", "ZA_COD" },;
							{ "SZB", "ZB", "ZB_PRODUTO" },;
							{ "SZC", "ZC", "ZC_PRODUTO" } }

Private	cTitulo	:= "Atualização do Código LMT"

If	!lAuto
	If	!MsgYesNo( "Confirma a atualização do código LMT em todas tabelas?" )
		Return
	EndIf

	For nTab := 1 to Len( aTabelas )
		ATUCODLMT1( aTabelas[ nTab, 1 ], aTabelas[ nTab, 2 ], aTabelas[ nTab, 3 ] , lAuto )
	Next nTab

Else 

	ConOut("Inicio do processo via Job")
	OpenSm0()

	RpcSetType(3) //para nao usar licenca.
	RpcSetEnv("01","01",,'EST')

	ConOut("Inicio do processamento. Data e Hora de inicio: " + DTOC(Date()) + " - " + Time())
	For nTab := 1 to Len( aTabelas )
		BatchProcess( cTitulo, 	"Atualizando código LMT",	"ATUCODLMT_1",{ || ATUCODLMT1( aTabelas[ nTab, 1 ], aTabelas[ nTab, 2 ], aTabelas[ nTab, 3 ] , lAuto ) }, { || .F. })
	Next nTab
	ConOut("Final do processamento. Data e Hora de finalização: " + DTOC(Date()) + " - " + Time())

EndIf

Return NIL

********************************************************************************************************************
Static Function ATUCODLMT1( cTabela, cPrefixo , cCampo , lAuto )
Local	cQuery

cQuery	:= "UPDATE " + RetSqlName( cTabela )
cQuery	+= " SET " + cPrefixo + "_CODLMT = NVL((SELECT B1_CODLMT
cQuery	+= " FROM " + RetSqlName( "SB1" )
cQuery	+= " WHERE D_E_L_E_T_ = ' '"
cQuery	+= " AND B1_COD = " + cCampo
cQuery	+= " AND B1_FILIAL = '" + xFilial( "SB1" ) + "'" + "),'  ')"
cQuery	+= " WHERE D_E_L_E_T_ = ' '"

If	!lAuto
	MsgRun( OemToAnsi( "Atualizando Código LMT - Tabela " + cTabela ), OemToAnsi( "Aguarde..." ), {|| TcSqlExec( cQuery ) } )
Else
	TcSqlExec( cQuery )
EndIf

Return
