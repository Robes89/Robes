#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"

User Function RESVEN()
Local	aSays		:= {}
Local	aButtons	:= {}
Local	nOpca		:= 0
Local	cCadastro	:= "Resumo por Vendedor"

	cPerg		:= PadR( "RESVEN" , Len( SX1->X1_GRUPO ) )

AjustaSX1()

Pergunte(cPerg,.F.)

Aadd(aSays, OemToAnsi( "Esta rotina irá gerar o relatório Resumo por Vendedor" ) )
Aadd(aSays, OemToAnsi( "" ) )

aAdd(aButtons, { 5,.T.,{|| Pergunte( cPerg , .T.) }} )
Aadd(aButtons, { 1, .T., { || nOpca := 1, FechaBatch() } } )
Aadd(aButtons, { 2, .T., { || FechaBatch() }})

FormBatch(cCadastro, aSays, aButtons)

If nOpca == 1
	MsAguarde( { || Processa( { || RESVEN1() } ) } , OemToAnsi( "Gerando arquivo arquivo de trabalho..." ) )
EndIf

Return

// ********************************************************************************************************************
Static Function RESVEN1()
Local cQuery := ""

aStru := {}
aAdd(aStru,{"TIPO",			"C",	TamSx3( "A3_FILIAL" )[1],	TamSx3( "A3_FILIAL")[2] } )
aAdd(aStru,{"VENDEDOR",		"C",	TamSx3( "A3_COD" )[1],		TamSx3( "A3_COD")[2] } )
aAdd(aStru,{"NOMEVEN",		"C",	TamSx3( "A3_NREDUZ" )[1],	TamSx3( "A3_NREDUZ")[2] } )
For nMes := 1 to 12
	aAdd(aStru,{"MES" + StrZero( nMes , 2 ),	"N",	TamSx3( "D2_TOTAL" )[1],	TamSx3( "D2_TOTAL")[2] } )
Next nMes

oTemptable := FWTemporaryTable():New( "TRA")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"IPO+VENDEDOR"} )
oTempTable:Create()

/*
cArq := CriaTrab(aStru,.T.)
dbUseArea(.T.,,cArq,"TRA",.T.)
cInd := CriaTrab(NIL,.F.)
IndRegua("TRA",cInd,"TIPO+VENDEDOR",,,"Ordenando registros...")
*/
DbSelectArea( "SD2" )
//aStru	:= SD2->( dbStruct() )
cQuery	:= " SELECT SF2.F2_VEND1, SA3.A3_NREDUZ"
If	mv_par02 == 1			// abate impostos
	For nMes := 1 to 12
		cQuery	+= ", SUM(CASE WHEN SUBSTR(SD2.D2_EMISSAO,1,6) = '" + StrZero( Val( mv_par01 ) , 4 ) + StrZero( nMes , 2 ) + "' AND SD2.D2_VALISS = 0 AND SD2.D2_VALFRE = 0 THEN SD2.D2_TOTAL-SD2.D2_VALICM-SD2.D2_VALIMP1-SD2.D2_VALIMP2-SD2.D2_VALIMP3-SD2.D2_VALIMP4-SD2.D2_VALIMP5 ELSE 0 END) AS V_MES" + StrZero( nMes , 2 )
		cQuery	+= ", SUM(CASE WHEN SUBSTR(SD2.D2_EMISSAO,1,6) = '" + StrZero( Val( mv_par01 ) , 4 ) + StrZero( nMes , 2 ) + "' THEN SD2.D2_CUSTO1 ELSE 0 END) AS C_MES" + StrZero( nMes , 2 )
		cQuery	+= ", SUM(CASE WHEN SUBSTR(SD2.D2_EMISSAO,1,6) = '" + StrZero( Val( mv_par01 ) , 4 ) + StrZero( nMes , 2 ) + "' AND SD2.D2_VALISS <> 0 THEN SD2.D2_TOTAL-SD2.D2_VALIMP1-SD2.D2_VALIMP2-SD2.D2_VALIMP3-SD2.D2_VALIMP4-SD2.D2_VALIMP5 ELSE 0 END) AS S_MES" + StrZero( nMes , 2 )
		cQuery	+= ", SUM(CASE WHEN SUBSTR(SD2.D2_EMISSAO,1,6) = '" + StrZero( Val( mv_par01 ) , 4 ) + StrZero( nMes , 2 ) + "' AND SD2.D2_VALFRE <> 0 THEN SD2.D2_VALFRE ELSE 0 END) AS F_MES" + StrZero( nMes , 2 )
	Next nMes
Else						// não abate impostos
	For nMes := 1 to 12
		cQuery	+= ", SUM(CASE WHEN SUBSTR(SD2.D2_EMISSAO,1,6) = '" + StrZero( Val( mv_par01 ) , 4 ) + StrZero( nMes , 2 ) + "' AND SD2.D2_VALISS = 0 AND SD2.D2_VALFRE = 0 THEN SD2.D2_TOTAL+SD2.D2_VALIPI ELSE 0 END) AS V_MES" + StrZero( nMes , 2 )
		cQuery	+= ", SUM(CASE WHEN SUBSTR(SD2.D2_EMISSAO,1,6) = '" + StrZero( Val( mv_par01 ) , 4 ) + StrZero( nMes , 2 ) + "' THEN SD2.D2_CUSTO1 ELSE 0 END) AS C_MES" + StrZero( nMes , 2 )
		cQuery	+= ", SUM(CASE WHEN SUBSTR(SD2.D2_EMISSAO,1,6) = '" + StrZero( Val( mv_par01 ) , 4 ) + StrZero( nMes , 2 ) + "' AND SD2.D2_VALISS <> 0 THEN SD2.D2_TOTAL ELSE 0 END) AS S_MES" + StrZero( nMes , 2 )
		cQuery	+= ", SUM(CASE WHEN SUBSTR(SD2.D2_EMISSAO,1,6) = '" + StrZero( Val( mv_par01 ) , 4 ) + StrZero( nMes , 2 ) + "' AND SD2.D2_VALFRE <> 0 THEN SD2.D2_VALFRE ELSE 0 END) AS F_MES" + StrZero( nMes , 2 )
	Next nMes
EndIf
cQuery	+= " FROM " + RetSqlName( "SD2" ) + " SD2"
cQuery	+= " INNER JOIN " + RetSqlName( "SF2" ) + " SF2 ON SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE"
cQuery	+= " AND SD2.D2_CLIENTE = SF2.F2_CLIENTE AND SD2.D2_LOJA = SF2.F2_LOJA"
cQuery	+= " AND SF2.D_E_L_E_T_ = ' '"
cQuery	+= " INNER JOIN " + RetSqlName( "SA3" ) + " SA3 ON SF2.F2_VEND1 = SA3.A3_COD"
cQuery	+= " AND SA3.D_E_L_E_T_ = ' '"
cQuery	+= " AND SA3.A3_ATIVO <> 'N'"
cQuery	+= " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SD2.D2_COD = SB1.B1_COD"
cQuery	+= " AND SB1.D_E_L_E_T_ = ' '"
cQuery	+= " AND SB1.B1_ATIVO <> 'N'"
cQuery	+= " INNER JOIN " + RetSqlName( "SF4" ) + " SF4 ON SD2.D2_TES = SF4.F4_CODIGO"
cQuery	+= " AND SF4.D_E_L_E_T_ = ' '"
cQuery	+= " AND SF4.F4_DUPLIC = 'S'"
cQuery	+= " WHERE"
cQuery	+= " SD2.D_E_L_E_T_ = ' '"
cQuery	+= " AND SD2.D2_TIPO NOT IN ('B','D'" + IF( mv_par02 == 1 , ",'P')" , ")" )
cQuery	+= " AND SUBSTR(SD2.D2_EMISSAO,1,4) = '" + StrZero( Val( mv_par01 ) , 4 ) + "'"
cQuery	+= " GROUP BY F2_VEND1, A3_NREDUZ"
cQuery	+= " ORDER BY F2_VEND1, A3_NREDUZ"

cQuery := ChangeQuery( cQuery )
MemoWrite("C:\RESVEN.TXT",cQuery)
MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),'VENDAS', .F., .T.)},OemToAnsi("Selecionando vendas..."))

DbSelectArea( "VENDAS" )
VENDAS->( DbGoTop() )
MsAguarde({|| ProcRegua( VENDAS->( LastRec() ) ) }, OemToAnsi( "Atualizando arquivo de trabalho..." ) )

While !VENDAS->( Eof() )

	IncProc()

	// faturamento produtos
	RecLock( "TRA" , .T. )
	TRA->TIPO		:= "1"
	TRA->VENDEDOR	:= VENDAS->F2_VEND1
	TRA->NOMEVEN	:= VENDAS->A3_NREDUZ
	For nMes := 1 to 12
		cMes		:= StrZero( nMes , 2 )
		cCampoT		:= "TRA->MES" + cMes
		cCampoV		:= "VENDAS->V_MES" + cMes
		&cCampoT	:= &cCampoV
	Next nMes
	TRA->( MsUnLock() )

	// faturamento serviços
	For	nMes := 1 to 12
		cMes		:= StrZero( nMes , 2 )
		cCampoT		:= "TRA->MES" + cMes
		cCampoS		:= "VENDAS->S_MES" + cMes
		If	&cCampoS # 0
			If	!TRA->( DbSeek( "11" + "SERVIC" ) )
				RecLock( "TRA" , .T. )
				TRA->TIPO		:= "11"
				TRA->VENDEDOR	:= "SERVIC"
				TRA->NOMEVEN	:= "SERVICO"
			Else
				RecLock( "TRA" )
			EndIf
			&cCampoT	+= &cCampoS
		EndIf
	Next nMes

	// faturamento fretes
	For	nMes := 1 to 12
		cMes		:= StrZero( nMes , 2 )
		cCampoT		:= "TRA->MES" + cMes
		cCampoF		:= "VENDAS->F_MES" + cMes
		If	&cCampoF # 0
			If	!TRA->( DbSeek( "12" + "FRETE" ) )
				RecLock( "TRA" , .T. )
				TRA->TIPO		:= "12"
				TRA->VENDEDOR	:= "FRETE"
				TRA->NOMEVEN	:= "FRETE"
			Else
				RecLock( "TRA" )
			EndIf
			&cCampoT	+= &cCampoF
		EndIf
	Next nMes

	// custo
	RecLock( "TRA" , .T. )
	TRA->TIPO		:= "2"
	TRA->VENDEDOR	:= VENDAS->F2_VEND1
	TRA->NOMEVEN	:= VENDAS->A3_NREDUZ
	For nMes := 1 to 12
		cMes		:= StrZero( nMes , 2 )
		cCampoT		:= "TRA->MES" + cMes
		cCampoC		:= "VENDAS->C_MES" + cMes
		&cCampoT	:= &cCampoC
	Next nMes
	TRA->( MsUnLock() )

	// lucro
	RecLock( "TRA" , .T. )
	TRA->TIPO		:= "3"
	TRA->VENDEDOR	:= VENDAS->F2_VEND1
	TRA->NOMEVEN	:= VENDAS->A3_NREDUZ
	For nMes := 1 to 12
		cMes  		:= StrZero( nMes , 2 )
		cCampoT		:= "TRA->MES" + cMes
		cCampoV		:= "VENDAS->V_MES" + cMes
		cCampoC		:= "VENDAS->C_MES" + cMes
		&cCampoT	:= &cCampoV - &cCampoC
	Next nMes
	TRA->( MsUnLock() )

	// rentalibilidade
	RecLock( "TRA" , .T. )
	TRA->TIPO		:= "4"
	TRA->VENDEDOR	:= VENDAS->F2_VEND1
	TRA->NOMEVEN	:= VENDAS->A3_NREDUZ
	For nMes := 1 to 12
		cMes		:= StrZero( nMes , 2 )
		cCampoT		:= "TRA->MES" + cMes
		cCampoV		:= "VENDAS->V_MES" + cMes
		cCampoC		:= "VENDAS->C_MES" + cMes
		&cCampoT	:= ( ( ( &cCampoV - &cCampoC ) / &cCampoV ) * 100 )
	Next nMes
	TRA->( MsUnLock() )

	VENDAS->( DbSkip() )
EndDo

DBSelectArea("TRA")
TRA->( DBGoTop() )

//COPY TO "RESVEN.DBF" VIA "DBFCDXADS"
//__CopyFile( "RESVEN.DBF" , "C:\" + "RESVEN.XLS" )

TRA->(DBCloseArea())
VENDAS->(DBCloseArea())

/*
cfile := "C:\TRB.XLS"
oExcelApp:= MsExcel():New()
oExcelApp:WorkBooks:Open( cfile)
oExcelApp:SetVisible(.T.)
*/
Return

// ********************************************************************************************************************
Static Function AjustaSX1()
aPerg    := {}

aAdd( aPerg , { "Ano de referência   ?",	"C",	4,	0,	"" })
aAdd( aPerg , { "Abate Impostos      ?",	"N",	1,	0,	"" })
aAdd( aPerg , { "Considera Devolução ?",	"N",	1,	0,	"" })

For nXX := 1 to Len( aPerg )
	If !SX1->( DbSeek( cPerg + StrZero( nXX , 2 ) ) ) 
		RecLock( "SX1" , .T. )
		SX1->X1_GRUPO     := cPerg
		SX1->X1_ORDEM     := StrZero( nXX , 2 )
		SX1->X1_PERGUNT   := aPerg[nXX][1]
		SX1->X1_VARIAVL   := "mv_ch" + Str( nXX , 1 )
		SX1->X1_TIPO      := aPerg[nXX][2]
		SX1->X1_TAMANHO   := aPerg[nXX][3]
		SX1->X1_DECIMAL	  := aPerg[nXX][4]
		SX1->X1_PRESEL    := 1
		SX1->X1_GSC       := "G"
		SX1->X1_VAR01     := "mv_par" + StrZero( nXX , 2 )
		SX1->X1_F3		  := aPerg[nxx][5]
		If nxx == 2 .or. nxx == 3
			SX1->X1_GSC   := "C"
			SX1->X1_DEF01 := "Sim"
			SX1->X1_DEF02 := "Nao"
		Endif
		SX1->(MsUnLock())
	EndIf
Next nXX
Return
