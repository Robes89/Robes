#INCLUDE "RWMAKE.CH"

// Relatórios de exceções
// Wilson Santos
// Set/2010

/*
#FAP20160623 - Implementação de novos TES no filtro do relatório
,'735','737','738'
*/
User Function RELEXC()
	Local	cCadastro	:= OemToAnsi( "Relatório de Exceções" )
	Local	nOpca		:= 0
	Local	aSays		:= {}
	Local	aButtons	:= {}

	Private cPerg	 	:= PadR( "RELEXC" , Len( SX1->X1_GRUPO ) )

	AjustaSX1( cPerg )

	Pergunte( cPerg , .F. )

	aAdd( aSays,	OemToAnsi( "Emissão do relatório de exceções," ) )
	aAdd( aSays,	OemToAnsi( "de acordo com os parâmetros" ) )
	aAdd( aButtons,	{ 5,.T.,{|| Pergunte( cPerg , .T. ) } } )
	aAdd( aButtons,	{ 1,.T.,{|o| nOpca:= 1, If( RELEXC_1(), o:oWnd:End(), nOpca:=0 ) } } )
	aAdd( aButtons,	{ 2,.T.,{|o| o:oWnd:End() }} )
	FormBatch( cCadastro, aSays, aButtons ,,220,380)

	If	nOpca == 1
		Processa( {|lEnd| RELEXC_2() } , cCadastro )
	Endif

Return

// ************************************************************************************************************************************************
Static Function RELEXC_1()
	Local	lRetorno	:= .T.

	If		Empty( mv_par02 )
		MsgBox( "Código LMT final não poderá ficar em branco." , "Atenção..." , "STOP" )
		lRetorno	:= .F.
	ElseIf	Upper( mv_par02 ) < Upper( mv_par01 )
		MsgBox( "Informe um código LMT válido entre o código inicial e final." , "Atenção..." , "STOP" )
		lRetorno	:= .F.
	ElseIf	Empty( mv_par04 )
		MsgBox( "Código Inteligente final não poderá ficar em branco." , "Atenção..." , "STOP" )
		lRetorno	:= .F.
	ElseIf	Upper( mv_par04 ) < Upper( mv_par03 )
		MsgBox( "Informe um código inteligente válido entre o código inicial e final." , "Atenção..." , "STOP" )
		lRetorno	:= .F.
	ElseIf	Empty( mv_par06 )
		MsgBox( "Informe uma data de entrega limite" , "Atenção..." , "STOP" )
		lRetorno	:= .F.
	EndIf

Return( lRetorno )

// ************************************************************************************************************************************************
Static Function RELEXC_2()
	
	Local oTempTable
	Local aStru		:= {}
	Local cDestino	:= ""
	Local cDetal	:= ""
	Local cFileName := ""
	Local cPATH		:= ""
	Local nXX		:= 0
	Local cFields 	:= ""
	
	oTempTable := FWTemporaryTable():New("TRA01")
	
	aAdd(aStru,{"CODLMT",	"C",	46,	0})
	aAdd(aStru,{"CODIGO",	"C",	15,	0})
	aAdd(aStru,{"DENOM",	"C",	58,	0})
	aAdd(aStru,{"PED_VEN",	"N",	9,	0})
	aAdd(aStru,{"PED_COM",	"N",	9,	0})
	aAdd(aStru,{"ORD_PRO",	"N",	9,	0})
	aAdd(aStru,{"EST_DIS",	"N",	9,	0})
	aAdd(aStru,{"TRANSITO",	"N",	9,	0})
	aAdd(aStru,{"SALDO",	"N",	9,	0})
	
	oTemptable:SetFields( aStru )
	oTempTable:AddIndex("indice1", {"CODLMT"},{"CODIGO"},{"DENOM"} )
	//------------------
	//Criação da tabela
	//------------------
	oTempTable:Create()

// Pedido de Vendas
	cPEDVEN	:= "SELECT SUM(SC6.C6_QTDVEN-SC6.C6_QTDENT) "
	cPEDVEN	+= "FROM "
	cPEDVEN	+= RetSqlName( "SC6" ) + " SC6, "
	cPEDVEN	+= RetSqlName( "SC5" ) + " SC5, "
	cPEDVEN	+= RetSqlName( "SF4" ) + " SF4 "
	cPEDVEN	+= "WHERE "
	cPEDVEN	+= "SC6.D_E_L_E_T_ = ' ' "
	cPEDVEN	+= "AND SC5.D_E_L_E_T_ = ' ' "
	cPEDVEN	+= "AND SF4.D_E_L_E_T_ = ' ' "
	cPEDVEN	+= "AND SC6.C6_FILIAL = '" + xFilial( "SC6" ) + "' "
	cPEDVEN	+= "AND SC5.C5_FILIAL = '" + xFilial( "SC5" ) + "' "
	cPEDVEN	+= "AND SC6.C6_PRODUTO = B1_COD "
	cPEDVEN	+= "AND SC6.C6_NUM = SC5.C5_NUM "
	cPEDVEN	+= "AND SC5.C5_STPAD IN ('S','P','C','D','M') "
	cPEDVEN	+= "AND SC6.C6_BLQ NOT IN ('R ') "
	cPEDVEN	+= "AND SC6.C6_LOCAL = '01' "
	cPEDVEN	+= "AND SC6.C6_TES = SF4.F4_CODIGO "
	cPEDVEN	+= "AND (SF4.F4_ESTOQUE = 'S' OR SC6.C6_CF IN ('5912', '6912', '5917' , '6917' ) OR SC6.C6_TES IN ('511','548','597','654','657','658','692','708','735','737','738'))"  // REGINA 14/04/11 e 14;09;11 //#FAP20160623
	cPEDVEN	+= "AND SC6.C6_ENTREG <= '" + DtoS( mv_par06 ) + "'"

// Pedido de Compras
	cPEDCOM	:= "SELECT SUM(SC7.C7_QUANT-SC7.C7_QUJE) "
	cPEDCOM	+= "FROM "
	cPEDCOM	+= RetSqlName( "SC7" ) + " SC7 "
	cPEDCOM	+= "WHERE "
	cPEDCOM	+= "SC7.D_E_L_E_T_ = ' ' "
	cPEDCOM	+= "AND SC7.C7_FILIAL = '" + xFilial( "SC7" ) + "' "
	cPEDCOM	+= "AND SC7.C7_PRODUTO = B1_COD "
	cPEDCOM	+= "AND SC7.C7_RESIDUO NOT IN ('S') "
	cPEDCOM	+= "AND SC7.C7_LOCAL = '01'"

// Ordem de Produção
	cORDPRO	:= "SELECT SUM(SC2.C2_QUANT-SC2.C2_QUJE) "
	cORDPRO	+= "FROM "
	cORDPRO	+= RetSqlName( "SC2" ) + " SC2 "
	cORDPRO	+= "WHERE "
	cORDPRO	+= "SC2.D_E_L_E_T_ = ' ' "
	cORDPRO	+= "AND SC2.C2_FILIAL = '" + xFilial( "SC2" ) + "' "
	cORDPRO	+= "AND SC2.C2_PRODUTO = B1_COD "
	cORDPRO	+= "AND SC2.C2_DATRF = ' ' "
	cORDPRO	+= "AND SC2.C2_LOCAL = '01' "

// Saldo em Estoque, almoxarifado 01
	cESTDIS	:= "SELECT SUM(SB2.B2_QATU-SB2.B2_QEMP) "
	cESTDIS	+= "FROM "
	cESTDIS	+= RetSqlName( "SB2" ) + " SB2 "
	cESTDIS	+= "WHERE "
	cESTDIS	+= "SB2.D_E_L_E_T_ = ' ' "
	cESTDIS	+= "AND SB2.B2_FILIAL = '" + xFilial( "SB2" ) + "' "
	cESTDIS	+= "AND SB2.B2_COD = B1_COD "
	cESTDIS	+= "AND SB2.B2_LOCAL = '01' "

// Saldo em Estoque, almoxarifado 07 (importação)
	cTRANSITO:= "SELECT SUM(SB2.B2_QATU-SB2.B2_QEMP) "
	cTRANSITO+= "FROM "
	cTRANSITO+= RetSqlName( "SB2" ) + " SB2 "
	cTRANSITO+= "WHERE "
	cTRANSITO+= "SB2.D_E_L_E_T_ = ' ' "
	cTRANSITO+= "AND SB2.B2_FILIAL = '" + xFilial( "SB2" ) + "' "
	cTRANSITO+= "AND SB2.B2_COD = B1_COD "
	cTRANSITO+= "AND SB2.B2_LOCAL = '07' "

// Produtos
	cQuery	:= "SELECT B1_CODLMT CODLMT, "
	cQuery	+= "B1_COD CODIGO, "
	cQuery	+= "B1_DENOM DENOM, "
	cQuery	+= "ISNULL((" + cPEDVEN + "), 0) PED_VEN, "
	cQuery	+= "ISNULL((" + cPEDCOM + "), 0) PED_COM, "
	cQuery	+= "ISNULL((" + cORDPRO + "), 0) ORD_PRO, "
	cQuery	+= "ISNULL((" + cESTDIS + "), 0) EST_DIS, "
	cQuery	+= "ISNULL((" + cTRANSITO+ "), 0) TRANSITO, "
	cQuery	+= "0 SALDO "
	cQuery	+= "FROM "
	cQuery	+= RetSqlName( "SB1" ) + " SB1 "
	cQuery	+= "WHERE "
	cQuery	+= "SB1.D_E_L_E_T_ = ' ' "
	cQuery	+= "AND SB1.B1_TIPO = 'PA' "
	cQuery	+= "AND SB1.B1_CODLMT BETWEEN '" + UPPER( MV_PAR01 ) + "' AND '" + UPPER( MV_PAR02 ) + "' "
	cQuery	+= "AND SB1.B1_COD BETWEEN '" + UPPER( MV_PAR03 ) + "' AND '" + UPPER( MV_PAR04 ) + "' "
	cQuery	+= "AND SUBSTRING( SB1.B1_COD , 1 , 6 ) NOT IN ('BRMDBF','BRACBF')"

	If		mv_par07 == 1
		cQuery	+= "AND SUBSTRING( SB1.B1_COD , 1 , 2 ) IN ('BR')"
	ElseIf	mv_par07 == 2
		cQuery	+= "AND SUBSTRING( SB1.B1_COD , 1 , 2 ) NOT IN ('BR')"
	EndIf

	If		mv_par05 == 1
		cQuery	+= "ORDER BY SB1.B1_CODLMT"
	ElseIf	mv_par05 == 2
		cQuery	+= "ORDER BY SB1.B1_COD"
	EndIf

	For nXX := 1 to Len(aStru)
		cFields += aStru[nXX][1] + ","//Nome do campo
	Next
	cFields := Left(cFields, Len(cFields) -1) //Remover a ultima vírgula
	
	cQry := "INSERT INTO " + oTempTable:GetRealName()
	cQry += " (" + cFields + ") "
	cQry += cQuery
	
	If TCSqlExec(cQry) < 0
		MSGALERT( "Não foi possível fazer a cópia dos dados, verificar com o administrador!", "Atenção!" )
	Else
		
		DbSelectArea("TRA01")
		DbGoTop()
	
		ProcRegua(TRA01->(LastRec()))
	
		cPATH:= 'C:\TEMP\'
		cFileName   := "RELEXC"+"_"+DTOS(DATE())+"_"+SUBSTR(TIME(),1,2)+"_"+SUBSTR(TIME(),4,2)+"_"+SUBSTR(TIME(),7,2)+".csv"
		cDestino	:= PADR(cPATH+cFileName, 100)
		
		//Monta Cabeçalho Relatório
		cFields := StrTran(cFields, ",", ";" )
		U_ArqLog(cFields,cDestino,"")
	
		While !TRA01->(EOF())
			IncProc()
			RecLock("TRA01", .F.)
	
			If	TRA01->( EST_DIS + TRANSITO + PED_COM + ORD_PRO - PED_VEN ) < 0
				TRA01->SALDO := TRA01->( EST_DIS + TRANSITO + PED_COM + ORD_PRO - PED_VEN )
				
				cDetal:= ""
				cDetal+= cValToChar(TRA01->CODLMT)   + ";"
				cDetal+= cValToChar(TRA01->CODIGO)   + ";"
				cDetal+= cValToChar(TRA01->DENOM)    + ";"
				cDetal+= cValToChar(TRA01->PED_VEN)  + ";"
				cDetal+= cValToChar(TRA01->PED_COM)  + ";"
				cDetal+= cValToChar(TRA01->ORD_PRO)  + ";"
				cDetal+= cValToChar(TRA01->EST_DIS)  + ";"
				cDetal+= cValToChar(TRA01->TRANSITO) + ";"
				cDetal+= cValToChar(TRA01->SALDO)
				
				U_ArqLog(cDetal,cDestino,"")
					
			Else
				TRA01->( DbDelete() )
			EndIf
			
			TRA01->(MsUnLock())
			TRA01->(DbSkip())
			
		EndDo
			
		TRA01->(DbCloseArea())
	
		MsgBox("Foi gerado o arquivo RELEXC na pasta: C:\TEMP\RELEXC.csv " ,"Atenção","ALERT")
	
		If ApOleClient("MsExcel")
			oExcelApp:= MsExcel():New()
			oExcelApp:WorkBooks:Open(cDestino)
			oExcelApp:SetVisible(.T.)
		EndIf
	EndIf
	
	oTempTable:Delete()
	
Return

// ************************************************************************************************************************************************
Static Function RELEXC_3(cTitulo)

	Private oArial10	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
	Private oArial12N	:= TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)
	Private oArial14N	:= TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)
	Private	nLin	   	:= 10000
	Private oPrint		:= TMSPrinter():New(cTitulo )
//Private oPen		:= TPen():New(,7,CLR_BLACK,oPrint)

//oPrint:SetPortrait()
	oPrint:SetLandscape()

	DbSelectArea( "TRA01" )
	TRA01->( DbGoTop() )

//SetRegua( TRA01->( RecCount() ) )

	While	!TRA01->( Eof() )

//	IncRegua()

		nSaldo	:= TRA01->( EST_DIS + PED_COM + ORD_PRO - PED_VEN )
		If	nSaldo >= 0
			TRA01->( DbSkip() )
			Loop
		EndIf

		If	nLin > 3000
			oPrint:EndPage()
			nLin	:= RELEXC_CAB(cTitulo)
		EndIf

		oPrint:Say(nLin,0030,TRA01->CODLMT,oArial10)
		oPrint:Say(nLin,0830,TRA01->CODIGO,oArial10)
		oPrint:Say(nLin,1110,TRA01->DENOM,oArial10)
		oPrint:Say(nLin,2150,TransForm(TRA01->PED_VEN,"@E 999,999,999.999"),oArial10)
		oPrint:Say(nLin,2400,TransForm(TRA01->PED_COM,"@E 999,999,999.999"),oArial10)
		oPrint:Say(nLin,2650,TransForm(TRA01->ORD_PRO,"@E 999,999,999.999"),oArial10)
		oPrint:Say(nLin,2900,TransForm(TRA01->EST_DIS,"@E 999,999,999.999"),oArial10)
		oPrint:Say(nLin,2900,TransForm(TRA01->TRANSITO,"@E 999,999,999.999"),oArial10)
		oPrint:Say(nLin,3150,TransForm(nSaldo,"@E 999,999,999.999"),oArial10)
		nLin	+= 40

		TRA01->( DbSkip() )

	EndDo

	oPrint:EndPage()
	oPrint:Preview() 	// Visualiza antes de imprimir

Return

//	************************************************************************************************************************************************
Static Function RELEXC_CAB(cTitulo)
	Local	nLin	:= 20

	oPrint:StartPage()
	oPrint:Box(nLin,0030,200 ,3330)
	oPrint:Say(nLin+=70,0050,SM0->M0_NOME,oArial12N)
	oPrint:Say(nLin    ,1500,"RELATÓRIO DE EXCEÇÕES",oArial14N)
	oPrint:Say(nLin+=130,0030,"CODIGO",oArial10)
	oPrint:Say(nLin     ,0830,"CODIGO",oArial10)
	oPrint:Say(nLin     ,1110,"DENOMINACAO",oArial10)
	oPrint:Say(nLin     ,2200,"PEDIDO",oArial10)
	oPrint:Say(nLin     ,2460,"PEDIDO",oArial10)
	oPrint:Say(nLin     ,2710,"ORDEM",oArial10)
	oPrint:Say(nLin     ,2930,"ESTOQUE",oArial10)
	oPrint:Say(nLin     ,3220,"SALDO",oArial10)
	oPrint:Say(nLin+=040,0030,"LMT",oArial10)
	oPrint:Say(nLin     ,0830,"INTELIGENTE",oArial10)
	oPrint:Say(nLin     ,2170,"DE VENDA",oArial10)
	oPrint:Say(nLin     ,2400,"DE COMPRA",oArial10)
	oPrint:Say(nLin     ,2610,"DE PRODUCAO",oArial10)
	oPrint:Say(nLin     ,2900,"DISPONIVEL",oArial10)
	oPrint:Line(nLin+=40 ,0030,nLin,3330)
	nLin+=40

/*
oPrint:Say(nLin,0030,"1234567890123456789012345678901234567890123456",oArial10)
oPrint:Say(nLin,0830,"123456789012345",oArial10)
oPrint:Say(nLin,1110,"123456789012345678901234567890123456789012345678901234567890",oArial10)
oPrint:Say(nLin,2150,"999,999.999",oArial10)
oPrint:Say(nLin,2400,"999,999.999",oArial10)
oPrint:Say(nLin,2650,"999,999.999",oArial10)
oPrint:Say(nLin,2900,"999,999.999",oArial10)
oPrint:Say(nLin,3150,"999,999.999",oArial10)
*/
/*
CÓDIGO                                           CÓDIGO            DENOMINAÇÃO                                                         PEDIDO        PEDIDO         ORDEM       ESTOQUE         SALDO
LMT                                              INTELIGENTE                                                                         DE VENDA     DE COMPRA   DE PRODUCAO    DISPONÍVEL
1234567890123456789012345678901234567890123456   123456789012345   123456789012345678901234567890123456789012345678901234567890   999,999.999   999,999.999   999,999.999   999,999.999   999,999.999
*/

Return nLin

// ************************************************************************************************************************************************
Static Function AjustaSX1(cPerg)

	Local	aAreaOLD	:= GetArea()
	Local	aHelp		:= {}
	Local	aPerg		:= {}
	Local	nXX			:= 0

/*
Aadd(	aHelp,	{	{"Código LMT Inicial."},;	//Portugues
					{"Código LMT Inicial."},;	//Ingles
					{"Código LMT Inicial."}})	//Espanhol

PutSx1(cPerg, "01","Código LMT Inicial ?","Código LMT Inicial ?","Código LMT Inicial ?","mv_ch1","C",TamSX3("B1_CODLMT")[1],0,0,;
	"G","","SB1LMT","","","mv_par01"," "," "," ",""," "," "," "," "," "," ", " "," "," "," ",;
	" "," ",aHelp[1][1],aHelp[1][2],aHelp[1][3])

Aadd(	aHelp,	{	{"Código LMT Final."},;
					{"Código LMT Final."},;
					{"Código LMT Final."}})

PutSx1(cPerg, "02","Código LMT Final ?","Código LMT Final ?","Código LMT Final ?","mv_ch2","C",TamSX3("B1_CODLMT")[1],0,0,;
	"G","","SB1LMT","","","mv_par02"," "," "," ",""," "," "," "," "," "," ", " "," "," "," ",;
	" "," ",aHelp[2][1],aHelp[2][2],aHelp[2][3])

Aadd(	aHelp,	{	{"Código Inteligente Inicial."},;
					{"Código Inteligente Inicial."},;
					{"Código Inteligente Inicial."}})

PutSx1(cPerg, "03","Código Inteligente Inicial ?","Código Inteligente Inicial ?","Código Inteligente Inicial ?","mv_ch3","C",TamSX3("B1_COD")[1],0,0,;
	"G","","SB1","","","mv_par03"," "," "," ",""," "," "," "," "," "," ", " "," "," "," ",;
	" "," ",aHelp[3][1],aHelp[3][2],aHelp[3][3])

Aadd(	aHelp,	{	{"Código Inteligente Final."},;
					{"Código Inteligente Final."},;
					{"Código Inteligente Final."}})

PutSx1(cPerg, "04","Código Inteligente Final   ?","Código Inteligente Final   ?","Código Inteligente Final   ?","mv_ch4","C",TamSX3("B1_COD")[1],0,0,;
	"G","","SB1","","","mv_par04"," "," "," ",""," "," "," "," "," "," ", " "," "," "," ",;
	" "," ",aHelp[4][1],aHelp[4][2],aHelp[4][3])

Aadd(	aHelp,	{	{"Pelo Código LMT ou Código Inteligente."},;
					{"Pelo Código LMT ou Código Inteligente."},;
					{"Pelo Código LMT ou Código Inteligente."}})

PutSx1(cPerg, "05","Impressão pelo Código      ?","Impressão pelo Código      ?","Impressão pelo Código      ?","mv_ch5","N",0,0,0,;
	"C","","","","","mv_par05","LMT"," "," ","","Inteligente "," "," "," "," "," ", " "," "," "," ",;
	" "," ",aHelp[5][1],aHelp[5][2],aHelp[5][3])

Aadd(	aHelp,	{	{"Data de entrega limite."},;
					{"Data de entrega limite."},;
					{"Data de entrega limite.."}})

PutSx1(cPerg, "06","Data de Entrega Limite     ?","Data de Entrega Limite     ?","Data de Entrega Limite     ?","mv_ch6","D",8,0,0,;
	"G","","","","","mv_par06"," "," "," ",""," "," "," "," "," "," ", " "," "," "," ",;
	" "," ",aHelp[6][1],aHelp[6][2],aHelp[6][3])

Aadd(	aHelp,	{	{"Qual classificação de ítem."},;
					{"Qual classificação de ítem."},;
					{"Qual classificação de ítem."}})

PutSx1(cPerg, "07","Classificação de Ítem      ?","Classificação de Ítem      ?","Classificação de Ítem      ?","mv_ch7","N",0,0,0,;
	"C","","","","","mv_par07","Nacional"," "," ","","Importado"," "," ","Ambos",""," ", " "," "," "," ",;
	" "," ",aHelp[7][1],aHelp[7][2],aHelp[7][3])
*/

	Aadd( aPerg , { "Código LMT Inicial         ?" 	, "C" , TamSX3("B1_CODLMT")[1] 	, "SB1LMT"})
	Aadd( aPerg , { "Código LMT Final           ?" 	, "C" , TamSX3("B1_CODLMT")[1] 	, "SB1LMT"})
	Aadd( aPerg , { "Código Inteligente Inicial ?" 	, "C" , TamSX3("B1_COD")[1] 	, "SB1"})
	Aadd( aPerg , { "Código Inteligente Final   ?" 	, "C" , TamSX3("B1_COD")[1] 	, "SB1"})
	Aadd( aPerg , { "Impressão pelo Código      ?" 	, "N" , 01 						, "   "})
	Aadd( aPerg , { "Data de Entrega Limite     ?" 	, "D" , 08	 					, "   "})
	Aadd( aPerg , { "Classificação de Ítem      ?" 	, "N" , 01						, "   "})

	For nXX := 1 to Len( aPerg )
		If !SX1->( DbSeek( cPerg + StrZero( nXX , 2 ) ) )
			RecLock( "SX1" , .T. )
			SX1->X1_GRUPO   := cPerg
			SX1->X1_ORDEM   := StrZero( nXX , 2 )
			SX1->X1_PERGUNT := aPerg[nXX][1]
			SX1->X1_VARIAVL := "mv_ch" + Str( nXX , 1 )
			SX1->X1_TIPO    := aPerg[nXX][2]
			SX1->X1_TAMANHO := aPerg[nXX][3]
			SX1->X1_PRESEL  := 1
			SX1->X1_GSC     := "G"
			SX1->X1_VAR01   := "mv_par" + StrZero( nXX , 2 )
			SX1->X1_F3		:= aPerg[nxx][4]
			If nxx == 5
				SX1->X1_GSC   := "C"
				SX1->X1_DEF01 := "LMT"
				SX1->X1_DEF02 := "Inteligente"
			Endif
			If nxx == 7
				SX1->X1_GSC   := "C"
				SX1->X1_DEF01 := "Nacional"
				SX1->X1_DEF02 := "Importado"
				SX1->X1_DEF03 := "Ambos"
			Endif
			SX1->(MsUnLock())
		EndIf
	Next nXX


	RestArea( aAreaOLD )

Return
