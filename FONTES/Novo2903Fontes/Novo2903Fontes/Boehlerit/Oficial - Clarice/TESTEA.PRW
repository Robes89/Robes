#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "REPORT.CH"

User Function TESTEA()
Local	aSays		:= {}
Local	aButtons	:= {}
Local	nOpca		:= 0
 
Local	cCadastro	:= "Geração de arquivo Excel"
Private _cHrIni := SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)
 
cPerg    := PadR( 'XLSSB1A' , Len( SX1->X1_GRUPO ) )
AjustaSX1()
Pergunte(cPerg,.F.)        

Aadd(aSays, OemToAnsi( "Esta rotina irá gerar um arquivo excel por produto" ) )
Aadd(aSays, OemToAnsi( "referente a vendas, estoque e ordem de produção" ) )

aAdd(aButtons, { 5,.T.,{|| Pergunte( cPerg , .T.) }} )
Aadd(aButtons, { 1, .T., { || nOpca := 1, IF( MsgYesNo( OemToAnsi( "Confirma geração ?" ), OemToAnsi( "Atenção " ) ), FechaBatch(), nOpca := 0) }})
Aadd(aButtons, { 2, .T., { || FechaBatch() }})

FormBatch(cCadastro, aSays, aButtons)

If nOpca == 1
	Processa( { || TESTE1() }, "Gerando arquivo..." )
EndIf

Return

// ****************************************************************************************
Static Function TESTE1()
Local	cQuery := ""
Local	nTotDias	:= IF( mv_par05 >= 1 , mv_par05 * 30 , 0 )
Local   nj   		:= 0
Local  i :=0

aStru := {}
aAdd(aStru,{"CODIGO",		"C",	TamSx3( "B1_COD" )[1],		TamSx3( "B1_COD")[2] } )
aAdd(aStru,{"CODLMT",		"C",	TamSx3( "B1_CODLMT" )[1],	TamSx3( "B1_CODLMT")[2] } )
aAdd(aStru,{"DESC",			"C",	TamSx3( "B1_DESC" )[1],		TamSx3( "B1_COD")[2] } )
aAdd(aStru,{"DENOM",		"C",	TamSx3( "B1_DENOM" )[1],	TamSx3( "B1_DENOM")[2] } )
aAdd(aStru,{"ESTLMT",		"N",	TamSx3( "B2_QATU" )[1],		TamSx3( "B2_QATU")[2] } )
aAdd(aStru,{"ESTCONS",		"N",	TamSx3( "B2_QATU" )[1],		TamSx3( "B2_QATU")[2] } )
aAdd(aStru,{"ESTOQUE",		"N",	TamSx3( "B2_QATU" )[1],		TamSx3( "B2_QATU")[2] } )
aAdd(aStru,{"EMPENHO",		"N",	TamSx3( "B2_QEMP" )[1],		TamSx3( "B2_QEMP")[2] } )
aAdd(aStru,{"ESTATU",		"N",	TamSx3( "B2_QATU" )[1],		TamSx3( "B2_QATU")[2] } )  
aAdd(aStru,{"PC",			"N",	TamSx3( "C7_QUANT" )[1],	TamSx3( "C7_QUANT")[2] } )
aAdd(aStru,{"PV",			"N",	TamSx3( "C6_QTDVEN" )[1],	TamSx3( "C6_QTDVEN")[2] } )
aAdd(aStru,{"VENDAS",		"N",	TamSx3( "D2_QUANT" )[1],	TamSx3( "D2_QUANT")[2] } )
aAdd(aStru,{"OPS",			"N",	TamSx3( "D3_QUANT" )[1],	TamSx3( "D3_QUANT")[2] } )
aAdd(aStru,{"TOTAL",		"N",	TamSx3( "D2_QUANT" )[1],	TamSx3( "D2_QUANT")[2] } )
aAdd(aStru,{"MESEST",		"N",	12,		4} )    /////  TamSx3( "C6_PRCVEN" )[1],	TamSx3( "C6_PRCVEN")[2] } )
aAdd(aStru,{"DTULTCOM",		"D",	TamSx3( "D1_EMISSAO" )[1],	TamSx3( "D1_EMISSAO")[2] } )
aAdd(aStru,{"QTDULTCOM",	"N",	TamSx3( "D1_QUANT" )[1],	TamSx3( "D1_QUANT")[2] } )
aAdd(aStru,{"DTULTVEN",		"D",	TamSx3( "D2_EMISSAO" )[1],	TamSx3( "D2_EMISSAO")[2] } )
aAdd(aStru,{"QTDULTVEN",	"N",	TamSx3( "D2_QUANT" )[1],	TamSx3( "D2_QUANT")[2] } )
aAdd(aStru,{"CMLMT",		"N",	TamSx3( "B2_CM1" )[1],		TamSx3( "B2_CM1")[2] } )
aAdd(aStru,{"CMCONS",		"N",	TamSx3( "B2_CM1" )[1],		TamSx3( "B2_CM1")[2] } )
aAdd(aStru,{"CLASESTQ",	"C",	    55,	TamSx3( "B1_CLAEST")[2] } )

aStruFile:=aStru

cArq := CriaTrab(aStru,.T.)
dbUseArea(.T.,,cArq,"TRB",.T.)
cInd := CriaTrab(NIL,.F.)
IndRegua("TRB",cInd,"CODIGO",,,"Selecionando Registros...")

// *---------------------------------------------------------------------------------------
// estoques

DbSelectArea( "SB2" )
aStru	:= SB2->( dbStruct() )
cQuery	:= " SELECT SB2.B2_COD, SB1.B1_CODLMT, SB1.B1_CLAEST, SB1.B1_DESC, SB1.B1_DENOM  "
cQuery	+= ", SUM(CASE WHEN SB2.B2_LOCAL = '01' THEN SB2.B2_QATU ELSE 0 END) AS ESTLMT"
cQuery	+= ", SUM(CASE WHEN SB2.B2_LOCAL = '01' THEN SB2.B2_CM1 ELSE 0 END) AS CMLMT"
cQuery	+= ", SUM(CASE WHEN SB2.B2_LOCAL = '02' THEN SB2.B2_QATU ELSE 0 END) AS ESTCONS"
cQuery	+= ", SUM(CASE WHEN SB2.B2_LOCAL = '02' THEN SB2.B2_CM1 ELSE 0 END) AS CMCONS"
cQuery	+= ", SUM(CASE WHEN SB2.B2_LOCAL IN ('01','02') THEN SB2.B2_QATU ELSE 0 END) AS ESTOQUE"
cQuery	+= ", SUM(CASE WHEN SB2.B2_LOCAL IN ('01','02') THEN SB2.B2_QEMP ELSE 0 END) AS EMPENHO"
cQuery	+= ", SUM(CASE WHEN SB2.B2_LOCAL IN ('01','02') THEN (SB2.B2_QATU-SB2.B2_QEMP) ELSE 0 END) AS ESTATU"
cQuery	+= " FROM " + RetSqlName( "SB2" ) + " SB2"
cQuery	+= " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SB2.B2_COD = SB1.B1_COD"
cQuery	+= " AND SB1.D_E_L_E_T_ = ' '"
cQuery	+= " AND SB1.B1_MSBLQL <> '1'"
cQuery	+= " WHERE"
cQuery	+= " SB2.D_E_L_E_T_ = ' '"
cQuery	+= " AND SB2.B2_COD BETWEEN '" + MV_PAR01 +"' AND '" + MV_PAR02 + "' "
cQuery	+= " AND SB2.B2_CODLMT BETWEEN '" + MV_PAR03 +"' AND '" + MV_PAR04 + "' "
///cQuery	+= " AND (SB2.B2_QATU <> 0 OR SB2.B2_QEMP <> 0)"
cQuery	+= " AND SUBSTRING(SB2.B2_COD,1,3) <> 'MOD'"
cQuery	+= " GROUP BY SB2.B2_COD, SB1.B1_CODLMT, SB1.B1_CLAEST, SB1.B1_DESC, SB1.B1_DENOM"
cQuery	+= " ORDER BY SB2.B2_COD"

cQuery := ChangeQuery( cQuery )

If Select("ESTOQUES") > 0
   DBCloseArea('ESTOQUES')
Endif

MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),'ESTOQUES', .F., .T.)},OemToAnsi("Selecionando estoque"))
For nj := 1 to Len(aStru)
	If	aStru[nj,2] != 'C'
		TCSetField( 'ESTOQUES' , aStru[nj,1] , aStru[nj,2] , aStru[nj,3] , aStru[nj,4] )
	EndIf	
Next nj

TcSetField( "ESTOQUES",	"ESTLMT",	"N",	TamSx3( "B2_QATU" )[1],	TamSx3( "B2_QATU")[2] )
TcSetField( "ESTOQUES",	"CMLMT",	"N",	TamSx3( "B2_CM1" )[1],	TamSx3( "B2_CM1")[2] )
TcSetField( "ESTOQUES",	"ESTCONS",	"N",	TamSx3( "B2_QATU" )[1],	TamSx3( "B2_QATU")[2] )
TcSetField( "ESTOQUES",	"CMCONS",	"N",	TamSx3( "B2_CM1" )[1],	TamSx3( "B2_CM1")[2] )
TcSetField( "ESTOQUES",	"ESTOQUE",	"N",	TamSx3( "B2_QATU" )[1],	TamSx3( "B2_QATU")[2] )
TcSetField( "ESTOQUES",	"EMPENHO",	"N",	TamSx3( "B2_QATU" )[1],	TamSx3( "B2_QATU")[2] )
TcSetField( "ESTOQUES",	"ESTATU",	"N",	TamSx3( "B2_QATU" )[1],	TamSx3( "B2_QATU")[2] )
TcSetField( "ESTOQUES",	"CLASESTQ",	"C",	55,	TamSx3( "B1_CLAEST")[2] )
//TcSetField( "ESTOQUES",	"CLASESTQ",	"C",	TamSx3( "B1_CLAEST" )[1],	TamSx3( "B1_CLAEST")[2] )


////////  Inclui no arquivo de trabalho

DbSelectArea( "ESTOQUES" )
ESTOQUES->( DbGoTop() )
MsAguarde({|| ProcRegua( ESTOQUES->( LastRec() ) ) }, OemToAnsi( "Atualizando dados do estoque..." ) )

While !ESTOQUES->( Eof() )

	IncProc()

	////If	ESTOQUES->ESTLMT # 0 .or. ESTOQUES->ESTCONS # 0 .or. ESTOQUES->EMPENHO # 0
	
	    SB1->( DBSEEK( XFILIAL("SB1") + ESTOQUES->B2_COD ) ) 
	    SZF->( DBSEEK( XFILIAL("SZF") + SB1->B1_CLAEST ) )
	    
		RecLock( "TRB" , !TRB->( DbSeek( ESTOQUES->B2_COD ) ) )
		TRB->CODIGO	  := ESTOQUES->B2_COD
		TRB->CODLMT	  := ESTOQUES->B1_CODLMT
		TRB->DESC		:= ESTOQUES->B1_DESC
		TRB->DENOM		:= ESTOQUES->B1_DENOM
		TRB->ESTLMT		:= ESTOQUES->ESTLMT
		TRB->ESTCONS	:= ESTOQUES->ESTCONS
		TRB->ESTOQUE	:= ESTOQUES->ESTOQUE     
		TRB->EMPENHO	:= ESTOQUES->EMPENHO
		TRB->ESTATU		:= ESTOQUES->ESTATU
		TRB->CMLMT		:= ESTOQUES->CMLMT
		TRB->CMCONS		:= ESTOQUES->CMCONS
		TRB->CLASESTQ	:= SB1->B1_CLAEST + " - " + ALLTRIM ( SZF->ZF_DESCRIC ) 
 
		TRB->( MsUnLock() )
	/////EndIf                                    
	
	ESTOQUES->( DbSkip() )

EndDo

 ESTOQUES->(DBCloseArea())

 
///ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Aglutina as Ordens de Producao em aberto                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


cQuery	:=  " SELECT  SC2.C2_FILIAL, SC2.C2_PRODUTO,SC2.C2_DATRF,  SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM ,SC2.R_E_C_N_O_  AS  WREC "
cQuery	+= " FROM " + RetSqlName( "SC2" ) + " SC2"
cQuery	+= " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SC2.C2_FILIAL = SB1.B1_FILIAL  AND SC2.C2_PRODUTO = SB1.B1_COD  "
cQuery	+= " AND SB1.D_E_L_E_T_ = ' '"
//cQuery	+= " AND SB1.B1_ATIVO <> 'N'"
cQuery	+= " WHERE"
cQuery	+= " SC2.D_E_L_E_T_ = ' '"
cQuery	+= " AND SC2.C2_PRODUTO BETWEEN '" + MV_PAR01 +"' AND '" + MV_PAR02 + "' "
cQuery	+= " AND SC2.C2_CODLMT BETWEEN '" + MV_PAR03 +"' AND '" + MV_PAR04 + "' "
cQuery	+= " ORDER BY SC2.C2_PRODUTO"

cQuery := ChangeQuery( cQuery )
 
MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),'ORDEM', .F., .T.)},OemToAnsi("Selecionando OPs"))

DbSelectArea( "ORDEM" )
ORDEM->( DbGoTop() )
MsAguarde({|| ProcRegua( ORDEM->( LastRec() ) ) }, OemToAnsi( "Atualizando OP's..." ) )

While !ORDEM->( Eof() )
 
           wqde:=0.00 
  
           wfilial       :=C2_FILIAL
           wproduto :=C2_PRODUTO
		   wcodLMT  :=B1_CODLMT
		   wdescb1  :=B1_DESC
           wdenom   :=B1_DENOM
		   
      
			Do While   !ORDEM->( Eof() ) .And.  C2_FILIAL + C2_PRODUTO == wfilial + wproduto
 
				IncProc()

                IF empty(C2_DATRF)
                    DbSelectArea( "SC2" )
                    SC2->(DBGOTO(ORDEM->WREC))
			    	If Empty(SC2->C2_DATRF) .And. (aSC2Sld()) > 0 ////.And. MtrAvalOp(mv_par16)
	                   wqde:=wqde+aSC2Sld()
				    EndIf
				Endif	

                DbSelectArea( "ORDEM" )
				dbSkip()

			EndDo

	    	If	wqde<> 0.00

	         	if  TRB->(DbSeek( wproduto ,.T. ))
				    if TRB->(RecLock( "TRB" ,.F. ))
		                TRB->OPS		   := wqde
	                	TRB->TOTAL		  += wqde
					    TRB->( MsUnLock() )
					Endif	
	            EndIf
			Endif	

            dbSelectArea("ORDEM")


	enddo

   ORDEM->(DBCloseArea())

//______________________________________________

 

// *---------------------------------------------------------------------------------------
// pedidos de vendas  
 

DbSelectArea( "SC6" )
aStru	:= SC6->( dbStruct() )
cQuery	:= " SELECT SC6.C6_PRODUTO, SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM"
cQuery	+= ", SUM( SC6.C6_QTDVEN - SC6.C6_QTDENT ) AS PV"
cQuery	+= " FROM " + RetSqlName( "SC6" ) + " SC6"
cQuery	+= " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SC6.C6_PRODUTO = SB1.B1_COD"
cQuery  += " AND SB1.B1_MSBLQL <> '1'"
cQuery	+= " AND SB1.D_E_L_E_T_ = ' '"
///cQuery	+= " AND SB1.B1_ATIVO <> 'N'"
cQuery	+= " INNER JOIN " + RetSqlName( "SF4" ) + " SF4 ON SC6.C6_TES = SF4.F4_CODIGO"
cQuery	+= " AND SF4.D_E_L_E_T_ = ' '"
////cQuery	+= " AND SF4.F4_DUPLIC = 'S'"
cQuery	+= " AND SF4.F4_ESTOQUE = 'S'"
cQuery	+= " WHERE"
cQuery	+= " SC6.D_E_L_E_T_ = ' '"
cQuery	+= " AND SC6.C6_PRODUTO BETWEEN '" + MV_PAR01 +"' AND '" + MV_PAR02 + "' "
cQuery	+= " AND SC6.C6_CODLMT BETWEEN '" + MV_PAR03 +"' AND '" + MV_PAR04 + "' "
//cQuery	+= " AND SC6.C6_ENTREG <= '" + dtos( ddatabase + nTotDias ) + "' "

//cQuery	+= " AND SC6.C6_ENTREG <= '" + dtos( mv_par06 ) + "' "  // ILIDIO inclusao da pergunta DE / ATE : 
//cQuery	+= " AND SC6.C6_ENTREG <= '" + dtos( mv_par07 ) + "' "  // ILIDIO
cQuery	+= " AND SC6.C6_ENTREG BETWEEN '" + dtos(MV_PAR06) +"' AND '" + dtos(MV_PAR07) + "' "
cQuery	+= " AND SUBSTRING(SC6.C6_BLQ,1,1) <> 'R' "
cQuery	+= " AND (SC6.C6_QTDVEN - SC6.C6_QTDENT)  > 0 "
cQuery	+= " AND SUBSTRING(SC6.C6_PRODUTO,1,3) <> 'MOD'"
cQuery	+= " GROUP BY SC6.C6_PRODUTO, SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM"
cQuery	+= " ORDER BY SC6.C6_PRODUTO"

cQuery := ChangeQuery( cQuery )
If Select("PEDIDOS") > 0
   DbCloseArea('PEDIDOS')
Endif

MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),'PEDIDOS', .F., .T.)},OemToAnsi("Selecionando pedidos de vendas"))
For nj := 1 to Len(aStru)
	If	aStru[nj,2] != 'C'
		TCSetField( 'PEDIDOS' , aStru[nj,1] , aStru[nj,2] , aStru[nj,3] , aStru[nj,4] )
	EndIf	
Next nj

TcSetField( "PEDIDOS",	"PV",	"N",	TamSx3( "C6_QTDVEN" )[1],	TamSx3( "C6_QTDVEN")[2] )

////////  Inclui no arquivo de trabalho
DbSelectArea( "PEDIDOS" )
PEDIDOS->( DbGoTop() )
MsAguarde({|| ProcRegua( PEDIDOS->( LastRec() ) ) }, OemToAnsi( "Atualizando pedidos de vendas..." ) )

While !PEDIDOS->( Eof() )

	IncProc()

	If	PEDIDOS->PV # 0
		RecLock( "TRB" , !TRB->( DbSeek( PEDIDOS->C6_PRODUTO ) ) )
		TRB->CODIGO		:= PEDIDOS->C6_PRODUTO
		TRB->CODLMT		:= PEDIDOS->B1_CODLMT
		TRB->DESC		:= PEDIDOS->B1_DESC
		TRB->DENOM		:= PEDIDOS->B1_DENOM
		TRB->PV			:= PEDIDOS->PV
		TRB->( MsUnLock() )
	EndIf
	
	PEDIDOS->( DbSkip() )

EndDo

 PEDIDOS->(DBCloseArea())

           
//*------------------------------------------------------------------------------------- 
// pedidos de compras 

DbSelectArea( "SC7" )
aStru	:= SC7->( dbStruct() )
cQuery	:= " SELECT SC7.C7_PRODUTO, SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM"
cQuery	+= ", SUM( SC7.C7_QUANT - SC7.C7_QUJE ) AS PC"
cQuery	+= " FROM " + RetSqlName( "SC7" ) + " SC7"
cQuery	+= " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SC7.C7_PRODUTO = SB1.B1_COD"
cQuery	+= " AND SB1.D_E_L_E_T_ = ' '"
cQuery	+= " AND SB1.B1_ATIVO <> 'N'"
//cQuery	+= " INNER JOIN " + RetSqlName( "SF4" ) + " SF4 ON SC7.C7_TES = SF4.F4_CODIGO"
//cQuery	+= " AND SF4.D_E_L_E_T_ = ' '"
// cQuery	+= " AND SF4.F4_DUPLIC = 'S'"
cQuery	+= " WHERE"
cQuery	+= " SC7.D_E_L_E_T_ = ' '"
cQuery	+= " AND SC7.C7_PRODUTO BETWEEN '" + MV_PAR01 +"' AND '" + MV_PAR02 + "' "
cQuery	+= " AND SC7.C7_CODLMT BETWEEN '" + MV_PAR03 +"' AND '" + MV_PAR04 + "' "
//cQuery	+= " AND SC6.C6_ENTREG <= '" + dtos( ddatabase + nTotDias ) + "' "

//cQuery	+= " AND SC7.C7_DATPRF <= '" + dtos( mv_par06 ) + "' "  // ILIDIO inclusao da pergunta DE / ATE : 
//cQuery	+= " AND SC7.C7_DATPRF <= '" + dtos( mv_par07 ) + "' "  // ILIDIO
cQuery	+= " AND SC7.C7_DATPRF BETWEEN '" + dtos(MV_PAR06) +"' AND '" + dtos(MV_PAR07) + "' "
cQuery	+= " AND SC7.C7_ENCER <> 'E' "                                                
cQuery	+= " AND SUBSTRING(SC7.C7_PRODUTO,1,3) <> 'MOD'"  
cQuery	+= " AND (SC7.C7_QUANT - SC7.C7_QUJE)  > 0 "
cQuery	+= " GROUP BY SC7.C7_PRODUTO, SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM"
cQuery	+= " ORDER BY SC7.C7_PRODUTO"

cQuery := ChangeQuery( cQuery )

If Select("COMPRAS") > 0
   DbCloseArea('COMPRAS')
Endif

MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),'COMPRAS', .F., .T.)},OemToAnsi("Selecionando pedidos de Compras"))
For nj := 1 to Len(aStru)
	If	aStru[nj,2] != 'C'
		TCSetField( 'COMPRAS' , aStru[nj,1] , aStru[nj,2] , aStru[nj,3] , aStru[nj,4] )
	EndIf	
Next nj

TcSetField( "COMPRAS",	"PC",	"N",	TamSx3( "C7_QUANT" )[1],	TamSx3( "C7_QUANT")[2] )

////////  Inclui no arquivo de trabalho

DbSelectArea( "COMPRAS" )
COMPRAS->( DbGoTop() )
MsAguarde({|| ProcRegua( COMPRAS->( LastRec() ) ) }, OemToAnsi( "Atualizando Compras..." ) )

While !COMPRAS->( Eof() )

	IncProc()
	
	IF  COMPRAS->C7_PRODUTO == "BOTOAAS00001434"
		_YY := 0 
	ENDIF

	If	COMPRAS->PC # 0
		RecLock( "TRB" , !TRB->( DbSeek( COMPRAS->C7_PRODUTO ) ) )
		TRB->CODIGO		:= COMPRAS->C7_PRODUTO
		TRB->CODLMT		:= COMPRAS->B1_CODLMT
		TRB->DESC		:= COMPRAS->B1_DESC
		TRB->DENOM		:= COMPRAS->B1_DENOM
		TRB->PC			:= COMPRAS->PC        
		TRB->( MsUnLock() )
	EndIf
	
	COMPRAS->( DbSkip() )

EndDo

COMPRAS->(DBCloseArea())

// *---------------------------------------------------------------------------------------
// vendas

DbSelectArea( "SD2" )
aStru	:= SD2->( dbStruct() )
cQuery	:= " SELECT SD2.D2_COD, SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM"
cQuery	+= ", SUM( SD2.D2_QUANT ) AS VENDAS"
cQuery	+= " FROM " + RetSqlName( "SD2" ) + " SD2"
cQuery	+= " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SD2.D2_COD = SB1.B1_COD"
cQuery	+= " AND SB1.D_E_L_E_T_ = ' '"
cQuery	+= " AND SB1.B1_ATIVO <> 'N'"
cQuery	+= " INNER JOIN " + RetSqlName( "SF4" ) + " SF4 ON SD2.D2_TES = SF4.F4_CODIGO"
cQuery	+= " AND SF4.D_E_L_E_T_ = ' '"
cQuery	+= " AND SF4.F4_DUPLIC = 'S'"
cQuery	+= " WHERE"
cQuery	+= " SD2.D_E_L_E_T_ = ' '"
cQuery	+= " AND SD2.D2_COD BETWEEN '" + MV_PAR01 +"' AND '" + MV_PAR02 + "' "
cQuery	+= " AND SD2.D2_CODLMT BETWEEN '" + MV_PAR03 +"' AND '" + MV_PAR04 + "' "
cQuery	+= " AND SD2.D2_EMISSAO > '" + dtos( ddatabase - nTotDias ) + "' "
cQuery	+= " AND SUBSTRING(SD2.D2_COD,1,3) <> 'MOD'"
cQuery	+= " GROUP BY SD2.D2_COD, SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM"
cQuery	+= " ORDER BY SD2.D2_COD"

cQuery := ChangeQuery( cQuery )
If Select("VENDAS") > 0
   DBCloseArea('VENDAS')
ENDIF

MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),'VENDAS', .F., .T.)},OemToAnsi("Selecionando vendas"))
For nj := 1 to Len(aStru)
	If	aStru[nj,2] != 'C'
		TCSetField( 'VENDAS' , aStru[nj,1] , aStru[nj,2] , aStru[nj,3] , aStru[nj,4] )
	EndIf	
Next nj

TcSetField( "VENDAS",	"VENDAS",	"N",	TamSx3( "D2_QUANT" )[1],	TamSx3( "D2_QUANT")[2] )


////  Inclui no arquivo de Trabalho

DbSelectArea( "VENDAS" )
VENDAS->( DbGoTop() )
MsAguarde({|| ProcRegua( VENDAS->( LastRec() ) ) }, OemToAnsi( "Atualizando vendas..." ) )

While !VENDAS->( Eof() )

	IncProc()

     
	

	If	VENDAS->VENDAS # 0
		RecLock( "TRB" , !TRB->( DbSeek( VENDAS->D2_COD ) ) )
		TRB->CODIGO		:= VENDAS->D2_COD
		TRB->CODLMT		:= VENDAS->B1_CODLMT
		TRB->DESC		:= VENDAS->B1_DESC
		TRB->DENOM		:= VENDAS->B1_DENOM
		TRB->VENDAS		:= VENDAS->VENDAS
		TRB->TOTAL		+= VENDAS->VENDAS
		TRB->( MsUnLock() )
	EndIf
	
	VENDAS->( DbSkip() )

EndDo

VENDAS->(DBCloseArea())

// *---------------------------------------------------------------------------------------
// dados da Última venda

DbSelectArea( "SD2" )
aStru	:= SD2->( dbStruct() )

cQuery	:= " SELECT SD2.D2_COD, SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM"
cQuery	+= ", SD2.D2_EMISSAO AS DTULTVEN,SUM( SD2.D2_QUANT) AS QTDULTVEN"
cQuery	+= " FROM " + RetSqlName( "SD2" ) + " SD2"
cQuery	+= " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SD2.D2_COD = SB1.B1_COD"
cQuery	+= " AND SB1.D_E_L_E_T_ = ' '"
cQuery	+= " AND SB1.B1_ATIVO <> 'N'"
cQuery	+= " INNER JOIN " + RetSqlName( "SF4" ) + " SF4 ON SD2.D2_TES = SF4.F4_CODIGO"
cQuery	+= " AND SF4.D_E_L_E_T_ = ' '"
cQuery	+= " AND SF4.F4_DUPLIC = 'S'"
cQuery	+= " WHERE"
cQuery	+= " SD2.D_E_L_E_T_ = ' '"
cQuery	+= " AND SD2.D2_COD BETWEEN '" + MV_PAR01 +"' AND '" + MV_PAR02 + "' "
cQuery	+= " AND SD2.D2_CODLMT BETWEEN '" + MV_PAR03 +"' AND '" + MV_PAR04 + "' "
cQuery	+= " AND SD2.D2_QUANT > 0"
cQuery	+= " AND SUBSTRING(SD2.D2_COD,1,3) <> 'MOD'"
cQuery	+= " GROUP BY SD2.D2_COD, SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM, SD2.D2_EMISSAO"
cQuery	+= " ORDER BY SD2.D2_COD, SD2.D2_EMISSAO "

cQuery := ChangeQuery( cQuery )

If Select("ULTVEN") > 0
   DbCloseArea('ULTVEN')
ENDIF

MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),'ULTVEN', .F., .T.)},OemToAnsi("Selecionando Última venda"))
For nj := 1 to Len(aStru)
	If	aStru[nj,2] != 'C'
		TCSetField( 'ULTVEN' , aStru[nj,1] , aStru[nj,2] , aStru[nj,3] , aStru[nj,4] )
	EndIf	
Next nj

TcSetField( "ULTVEN",	"DTULTVEN",		"D",	TamSx3( "D2_EMISSAO" )[1],	TamSx3( "D2_EMISSAO")[2] )
TcSetField( "ULTVEN",	"QTDULTVEN",	"N",	TamSx3( "D2_QUANT" )[1],	TamSx3( "D2_QUANT")[2] )

DbSelectArea( "ULTVEN" )
ULTVEN->( DbGoTop() )
MsAguarde({|| ProcRegua( ULTVEN->( LastRec() ) ) }, OemToAnsi( "Atualizando Última Venda..." ) )

While !ULTVEN->( Eof() )

	IncProc()

    wcod:=ULTVEN->D2_COD
	wDTULTVEN :=ctod('  /  /    ')
	wQTDULTVEN:=0.00

    While !ULTVEN->( Eof() ) .and.  ULTVEN->D2_COD =wcod
	         wDTULTVEN   := ULTVEN->DTULTVEN
	         wQTDULTVEN := ULTVEN->QTDULTVEN
		    ULTVEN->( DbSkip() )
    EndDo


	If   wQTDULTVEN # 0
	    if TRB->( DbSeek(wcod ,.T.))
		     RecLock( "TRB" , .F.) 
		     TRB->DTULTVEN   := wDTULTVEN
	         TRB->QTDULTVEN := wQTDULTVEN
		     TRB->( MsUnLock() )
	     EndIf
	Endif	 
	
 

EndDo

 ULTVEN->(DBCloseArea())


///////////// dados da Última compra

DbSelectArea( "SD1" )
aStru	:= SD1->( dbStruct() )

cQuery	:= " SELECT SD1.D1_COD, SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM"
cQuery	+= ", SD1.D1_EMISSAO AS DTULTCOM,SUM( SD1.D1_QUANT) AS QTDULTCOM"
cQuery	+= " FROM " + RetSqlName( "SD1" ) + " SD1"
cQuery	+= " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SD1.D1_COD = SB1.B1_COD"
cQuery	+= " AND SB1.D_E_L_E_T_ = ' '"
cQuery	+= " AND SB1.B1_ATIVO <> 'N'"
cQuery	+= " INNER JOIN " + RetSqlName( "SF4" ) + " SF4 ON SD1.D1_TES = SF4.F4_CODIGO"
cQuery	+= " AND SF4.D_E_L_E_T_ = ' '"
//cQuery	+= " AND (SF4.F4_DUPLIC = 'S' OR SUBSTR(SD1.D1_CF,1,4)='3101' OR SUBSTR(SD1.D1_CF,1,4)='3102')"
cQuery	+= " WHERE"
cQuery	+= " SD1.D_E_L_E_T_ = ' '"
cQuery	+= " AND SD1.D1_COD BETWEEN '" + MV_PAR01 +"' AND '" + MV_PAR02 + "' "
cQuery	+= " AND SD1.D1_CODLMT BETWEEN '" + MV_PAR03 +"' AND '" + MV_PAR04 + "' "
cQuery	+= " AND SD1.D1_QUANT > 0"
cQuery	+= " AND (SF4.F4_DUPLIC = 'S' OR SUBSTRING(SD1.D1_CF,1,4)='3101' OR SUBSTRING(SD1.D1_CF,1,4)='3102')"
cQuery	+= " AND SUBSTRING(SD1.D1_COD,1,3) <> 'MOD'"
cQuery	+= " GROUP BY SD1.D1_COD, SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM, SD1.D1_EMISSAO"
cQuery	+= " ORDER BY SD1.D1_COD, SD1.D1_EMISSAO "

cQuery := ChangeQuery( cQuery )

If Select("ULTCOM") > 0
   DbCloseArea('ULTCOM')
ENDIF

MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),'ULTCOM', .F., .T.)},OemToAnsi("Selecionando Última compra"))
For nj := 1 to Len(aStru)
	If	aStru[nj,2] != 'C'
		TCSetField( 'ULTCOM' , aStru[nj,1] , aStru[nj,2] , aStru[nj,3] , aStru[nj,4] )
	EndIf	
Next nj

TcSetField( "ULTCOM",	"DTULTCOM",		"D",	TamSx3( "D1_EMISSAO" )[1],	TamSx3( "D1_EMISSAOs")[2] )
TcSetField( "ULTCOM",	"QTDULTCOM",	"N",	TamSx3( "D1_QUANT" )[1],	TamSx3( "D1_QUANT")[2] )

DbSelectArea( "ULTCOM" )
ULTCOM->( DbGoTop() )
MsAguarde({|| ProcRegua(ULTCOM->( LastRec() ) ) }, OemToAnsi( "Atualizando Última Compra..." ) )

While !ULTCOM->( Eof() )

	IncProc()

	wcod:=ULTCOM->D1_COD
	wDTULTCOM   :=ctod('  /  /    ')
	wQTDULTCOM :=0.00
 

	While !ULTCOM->( Eof() ) .and. ULTCOM->D1_COD=wcod
            wDTULTCOM:=ULTCOM->DTULTCOM
			wQTDULTCOM := ULTCOM->QTDULTCOM
            ULTCOM->( DbSkip() )
	Enddo		

 
	If	wQTDULTCOM # 0
	    if  TRB->(DbSeek( wcod ,.T.))
		     RecLock( "TRB" , .F.) 
		     TRB->DTULTCOM   := wDTULTCOM
	         TRB->QTDULTCOM := wQTDULTCOM
		     TRB->( MsUnLock() )
	     EndIf
	Endif	 
	  

EndDo 

ULTCOM->(DBCloseArea())
 

// *---------------------------------------------------------------------------------------
// Requisições

/*

DbSelectArea( "SD3" )
aStru	:= SD3->( dbStruct() )
cQuery	:= " SELECT SD3.D3_COD, SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM"
cQuery	+= ", SUM(CASE WHEN SUBSTRING(SD3.D3_CF,1,2) = 'RE' THEN SD3.D3_QUANT ELSE 0 END) AS REQ"
cQuery	+= ", SUM(CASE WHEN SUBSTRING(SD3.D3_CF,1,2) = 'DE' THEN SD3.D3_QUANT ELSE 0 END) AS DEV"
cQuery	+= " FROM " + RetSqlName( "SD3" ) + " SD3"
cQuery	+= " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SD3.D3_COD = SB1.B1_COD"
cQuery	+= " AND SB1.D_E_L_E_T_ = ' '"
cQuery	+= " AND SB1.B1_ATIVO <> 'N'"
cQuery	+= " WHERE"
cQuery	+= " SD3.D_E_L_E_T_ = ' '"
cQuery	+= " AND SD3.D3_COD BETWEEN '" + MV_PAR01 +"' AND '" + MV_PAR02 + "' "
cQuery	+= " AND SD3.D3_CODLMT BETWEEN '" + MV_PAR03 +"' AND '" + MV_PAR04 + "' "
cQuery	+= " AND SD3.D3_EMISSAO > '" + dtos( ddatabase - nTotDias ) + "' "
cQuery	+= " AND SUBSTRING(SD3.D3_CF,1,2) IN ('RE','DE')"
cQuery	+= " AND SD3.D3_OP <> ' '"
cQuery	+= " AND SUBSTRING(SD3.D3_COD,1,3) <> 'MOD'"
cQuery	+= " GROUP BY SD3.D3_COD, SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM"
cQuery	+= " ORDER BY SD3.D3_COD"

cQuery := ChangeQuery( cQuery )
//MemoWrite("C:\TESTE.TXT",cQuery)

If Select("TMPCSV") > 0
   REQ->( DbCloseArea() )
ENDIF
MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),'REQ', .F., .T.)},OemToAnsi("Selecionando requisições"))
For nj := 1 to Len(aStru)
	If	aStru[nj,2] != 'C'
		TCSetField( 'REQ' , aStru[nj,1] , aStru[nj,2] , aStru[nj,3] , aStru[nj,4] )
	EndIf	
Next nj

TcSetField( "REQ",	"REQ",	"N",	TamSx3( "D3_QUANT" )[1],	TamSx3( "D3_QUANT")[2] )
TcSetField( "REQ",	"DEV",	"N",	TamSx3( "D3_QUANT" )[1],	TamSx3( "D3_QUANT")[2] )


*/

// *---------------------------------------------------------------------------------------

 

 /*

 

DbSelectArea( "REQ" )
REQ->( DbGoTop() )
MsAguarde({|| ProcRegua( REQ->( LastRec() ) ) }, OemToAnsi( "Atualizando Requisições..." ) )

While !REQ->( Eof() )

	IncProc()

	If	REQ->REQ # 0
		RecLock( "TRB" , !TRB->( DbSeek( REQ->D3_COD ) ) )
		TRB->CODIGO		:= REQ->D3_COD
		TRB->CODLMT		:= REQ->B1_CODLMT
		TRB->DESC		  := REQ->B1_DESC
		TRB->DENOM		:= REQ->B1_DENOM
		TRB->REQ		   := REQ->REQ
		////TRB->TOTAL		+= REQ->REQ
		TRB->( MsUnLock() )
	EndIf
	
	REQ->( DbSkip() )

EndDo
 
REQ->(DBCloseArea())

 */
 //////////////////////////////////////////////////////////////////////////////

wTemp:={}

DbSelectArea( "TRB" )
TRB->( DbGoTop() )
MsAguarde({|| ProcRegua( TRB->( LastRec() ) ) }, OemToAnsi( "Atualizando Mês Estoque..." ) )

While !TRB->( Eof() )

	IncProc()

	RecLock( "TRB" )

    TRB->TOTAL		= TRB->VENDAS + TRB->OPS
	If	TRB->TOTAL <> 0    .and.   mv_par05<>0
		TRB->MESEST	:= (TRB->ESTATU - TRB->PV) / (TRB->TOTAL/mv_par05)      // (ilidio) retirado o nr. 12 e inserida a mv_par05
	Else
		TRB->MESEST	:=  9999999
	EndIf

	 
	TRB->( MsUnLock() )

	aadd(wtemp,{ ;
		 TRB->CODIGO ,;
         TRB->CODLMT ,;
         TRB->DESC ,;
         TRB->DENOM ,;
         TRB->ESTLMT ,;
         TRB->ESTCONS ,;
         TRB->ESTOQUE ,;
         TRB->EMPENHO ,;
         TRB->ESTATU ,;
         TRB->PC ,;
         TRB->PV ,;
         TRB->VENDAS ,;
         TRB->OPS ,;
         TRB->TOTAL ,;
         iif(TRB->MESEST<>9999999,TransForm(TRB->MESEST,'@E 999,999.9999') ,'9999999') ,;
         TRB->DTULTCOM  ,;
         TRB->QTDULTCOM ,;
         TRB->DTULTVEN ,;
         TRB->QTDULTVEN ,;
         TRB->CMLMT ,;
         TRB->CMCONS ,;
         TRB->CLASESTQ ;
	})



	TRB->( DbSkip() )

EndDo

 
//////////////////  Impressão TReport///////////////////////////////////////////////////////////////
 
 u_impvdaA()

TRB->(DBCloseArea())

Return


User Function impvdaA()
Local oReport     
Local oSection1   

oReport:=ReportDef() 
oReport:PrintDialog()

Return

////////////////////////////////////////////////////////////////////////////////

// *---------------------------------------------------------------------------------------


/*
cPATH		:= 'C:\TEMP\'
cFileName   := "TRB"+"_"+DTOS(DATE())+"_"+SUBSTR(TIME(),1,2)+"_"+SUBSTR(TIME(),4,2)+"_"+SUBSTR(TIME(),7,2)+".CSV"
cDestino	:= PADR(cPATH+cFileName, 100)

cCabec:=""
//Monta Cabeçalho Relatório
 
For   i:=1  To   Len(aStruFile)
	cCabec+= aStruFile[i,1]+";" 
Next i

/////cCabec:= { "CODIGO", "CODLMT","DESC",  "ESTLMT" ,"ESTCONS","EMPENHO","ESTOQUE","ESTATU", "PC" ,"PV" , "VENDAS","OPS" , "TOTAL", "MESEST",  "QTDULTCOM" , "DTULTVEN", "QTDULTVEN" ,"CMLMT" , "CMCONS", "CLASESTQ" } 
	

cCabec:=SubStr(cCabec,1,Len(cCabec)-1)
u_ArqLog(cCabec,cDestino,"")

dbselectarea("TRB")
TRB->(dbGoTop())
While TRB->(!EOF())

   // cDetal+= StrTran(cValToChar(TRB->PESOLIQ ),".", ",")  + ";" 

    wMov:=	 TRB->ESTLMT + ;
	 TRB->ESTCONS  + ;
	 TRB->ESTOQUE  + ;
	 TRB->EMPENHO  + ; 
 	 TRB->ESTATU    + ;
	 TRB->PC    + ;
	 TRB->PV   + ;
	 TRB->VENDAS  + ;
	 TRB->OPS  + ;
	 TRB->TOTAL
 
     if wMov 	 >0.00
	
	cDetal:= ""
	cDetal+= cValToChar(TRB->CODIGO   )  + ";"
	cDetal+= cValToChar(TRB->CODLMT   )  + ";"
	cDetal+= cValToChar(TRB->DESC   )  + ";"
	cDetal+= cValToChar(TRB->DENOM   )  + ";"
	cDetal+= cValToChar(TRB->ESTLMT   )  + ";"
	cDetal+= cValToChar(TRB->ESTCONS  )  + ";"
	cDetal+= cValToChar(TRB->ESTOQUE  )  + ";"
	cDetal+= cValToChar(TRB->EMPENHO   )  + ";"
 	cDetal+= cValToChar(TRB->ESTATU   )  + ";"
	cDetal+= cValToChar(TRB->PC   )  + ";"
	cDetal+= cValToChar(TRB->PV  )  + ";"
	cDetal+= cValToChar(TRB->VENDAS  )  + ";"
	cDetal+= cValToChar(TRB->OPS   )  + ";"
	cDetal+= StrTran(cValToChar(TRB->TOTAL ),".", ",")  + ";" 
	cDetal+= StrTran(allTrim(str(trb->mesest,12,4)),".", ",")  + ";"  
	cDetal+= cValToChar(TRB->DTULTCOM   )  + ";"
	cDetal+= cValToChar(TRB->QTDULTCOM   )  + ";"
	cDetal+= cValToChar(TRB->DTULTVEN   )  + ";"
	cDetal+= cValToChar(TRB->QTDULTVEN )  + ";"
	cDetal+= StrTran(cValToChar(TRB->CMLMT ),".", ",")     + ";"
	cDetal+= cValToChar(TRB->CMCONS   )  + ";"
	cDetal+= cValToChar(TRB->CLASESTQ   )   
	
   	
	u_ArqLog(cDetal,cDestino,"")

    Endif

	TRB->(dbSkip())
EndDo
 

TRB->(DBCloseArea())

/*
ESTOQUES->(DBCloseArea())
PEDIDOS->(DBCloseArea())               
COMPRAS->(DBCloseArea())               
VENDAS->(DBCloseArea())
OPS->(DBCloseArea())
ULTVEN->(DBCloseArea())
ULTCOM->(DBCloseArea())
FErase("ULTVEN.DBF")
FErase("ULTCOM.DBF")
*/


/*
//Carrega EXCEL
If ApOleClient("MsExcel")
	oExcelApp:= MsExcel():New()
	oExcelApp:WorkBooks:Open(cDestino)
	oExcelApp:SetVisible(.T.)
 EndIf

*/

 

Return

// ****************************************************************************************
Static Function AjustaSX1()
Local   nXX         := 0

aPerg    := {}
cPerg    := "XLSSB1A   "

Aadd( aPerg , { "Codigo de      ?  " , "C" , 15 , 0, "SB1"}) 
Aadd( aPerg , { "Codigo ate     ?  " , "C" , 15 , 0, "SB1"}) 
Aadd( aPerg , { "Do Cod Lmt     ?" , "C" , TamSX3( "B1_CODLMT" )[1], 0 , "SB1LMT"})
Aadd( aPerg , { "Ate Cod Lmt    ?" , "C" , TamSX3( "B1_CODLMT" )[1], 0 , "SB1LMT"})
Aadd( aPerg , { "Quantos meses  ?  " , "N" , 02 , 0, ""}) 
Aadd( aPerg , { "PV/PC Entr. de:   " , "D" , 08 , 0, ""}) 
Aadd( aPerg , { "PV / PC Entr. ate:" , "D" , 08 , 0, ""}) 


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
		SX1->(MsUnLock())
	EndIf
Next nXX
Return Nil

 

 

Static Function ReportDef()
Local ctitulo:='Arquivo excel por produto referente a vendas, estoque e ordem de produção' 
Local oReport     
Local oSection1     
Local cFileName   := "TRB"+"_"+DTOS(DATE())+"_"+SUBSTR(TIME(),1,2)+"_"+SUBSTR(TIME(),4,2)+"_"+SUBSTR(TIME(),7,2) 
 
Private oFont10N	:= TFont():New("Courier new",10,10,.T.,.T.,5,.T.,5,.T.,.F.)   



oReport := TReport():New(cFileName,cTitulo,cPerg,{|oReport| ReportPrint(oReport)},cTitulo)
 
oReport:HideParamPage() 
oReport:ParamReadOnly(.T.)
oReport:setLandScape(.t.)
 
oReport:setdevice(4)

 

dbSelectArea("SX1")

cPerg    := PadR( 'XLSSB1A' , Len( SX1->X1_GRUPO ) ) 

Pergunte(cPerg,.F.)

 
 

oSection1:= TRSection():New( oReport , "Planilha", {"TRB"} )
//oSection1:Settotalinline(.F.)
//oSection1:Settotaltext('Total Geral')
 
TRCell():New(oSection1,"CODIGO"         ,"TRB" , "CODIGO"      ,,15)  
TRCell():New(oSection1,"CODLMT "        ,"TRB" , "CODLMT"      ,,46) 
TRCell():New(oSection1,"DESC"             ,"TRB" , "DESC"          ,,30) 
TRCell():New(oSection1,"DENOM"          ,"TRB" , "DENOM"      ,,58)  
TRCell():New(oSection1,"ESTLMT"         ,"TRB" , "ESTLMT"      ,"@e 99999999",15)    
TRCell():New(oSection1,"ESTCONS"         ,"TRB" , "ESTCONS"    ,"@e 99999999",15)  
TRCell():New(oSection1,"ESTOQUE"         ,"TRB" , "ESTOQUE"     ,"@e 99999999",15)   
TRCell():New(oSection1,"EMPENHO"         ,"TRB" , "EMPENHO"     ,"@e 99999999",15)  
TRCell():New(oSection1,"ESTATU"         ,"TRB" , "ESTATU"     ,"@e 99999999",15)  
TRCell():New(oSection1,"PC"                 ,"TRB" , "PC"     ,"@e 99999999",15)  
TRCell():New(oSection1,"PV "         ,"TRB" , "PV "     ,"@e 99999999",15)  
TRCell():New(oSection1,"VENDAS  "         ,"TRB" , "VENDAS  "    ,"@e 99999999",15)  
TRCell():New(oSection1,"OPS"         ,"TRB", "OPS"      ,"@e 99999999",15)  
TRCell():New(oSection1,"TOTAL "         ,"TRB", "TOTAL "     ,"@e 99999999",15)  
TRCell():New(oSection1,"MESEST"         ,"TRB" , "MESEST"      ,  ,15)  
TRCell():New(oSection1,"DTULTCOM "         ,"TRB" , "DTULTCOM "      ,,15)   
TRCell():New(oSection1,"QTDULTCOM "         ,"TRB", "QTDULTCOM "     ,"@e 99999999",15)  
TRCell():New(oSection1,"DTULTVEN"         ,"TRB", "DTULTVEN"      ,,15)  
TRCell():New(oSection1,"QTDULTVEN "         ,"TRB" , "QTDULTVEN "      ,"@e 99999999",15)  
TRCell():New(oSection1,"CMLMT"         ,"TRB" , "CMLMT"       ,"@e 9,999.9999",15)  
TRCell():New(oSection1,"CMCONS"         ,"TRB" , "CMCONS"       ,"@e 9,999.9999",15)  
TRCell():New(oSection1,"CLASESTQ  "         ,"TRB" , "CLASESTQ  "      ,,15) 
	 	
oSection1:Cell( "MESEST" ):SetAlign('RIGHT')
 

Return oReport 



Static Function ReportPrint(oReport) 

Local oSection1	:=	oReport:Section(1)  
Local wrec:=0
  

if oReport:nDevice<>4
   alert('Atenção -> Deixar indicado como "Tipo Planilha"'+chr(13)+"A formatação não é adequada para outros tipos.") 
Endif   

 
oReport:SetMeter(len(wtemp))
 
	
oReport:SetTitle(oReport:Title())

    
oSection1:Init()

    wrec:=1
	
for wrec:=1  to len(wtemp)

     If oReport:Cancel()
            Exit
     EndIf 

oSection1:Cell("CODIGO"          ):SetValue(wtemp[wrec,1]) 
oSection1:Cell("CODLMT"         ):SetValue(wtemp[wrec,2]) 
oSection1:Cell("DESC"              ):SetValue(wtemp[wrec,3]) 
oSection1:Cell("DENOM"           ):SetValue(wtemp[wrec,4]) 
oSection1:Cell("ESTLMT"          ):SetValue(wtemp[wrec,5]) 
oSection1:Cell("ESTCONS"        ):SetValue(wtemp[wrec,6]) 
oSection1:Cell("ESTOQUE"        ):SetValue(wtemp[wrec,7]) 
oSection1:Cell("EMPENHO"        ):SetValue(wtemp[wrec,8]) 
oSection1:Cell("ESTATU"           ):SetValue(wtemp[wrec,9]) 
oSection1:Cell("PC"                   ):SetValue(wtemp[wrec,10]) 
oSection1:Cell("PV"                   ):SetValue(wtemp[wrec,11]) 
oSection1:Cell("VENDAS"           ):SetValue(wtemp[wrec,12]) 
oSection1:Cell("OPS"                 ):SetValue(wtemp[wrec,13]) 
oSection1:Cell("TOTAL"              ):SetValue(wtemp[wrec,14]) 
oSection1:Cell("MESEST"           ):SetValue(wtemp[wrec,15]) 
oSection1:Cell("DTULTCOM"       ):SetValue(wtemp[wrec,16]) 
oSection1:Cell("QTDULTCOM"     ):SetValue(wtemp[wrec,17]) 
oSection1:Cell("DTULTVEN"        ):SetValue(wtemp[wrec,18]) 
oSection1:Cell("QTDULTVEN"      ):SetValue(wtemp[wrec,19]) 
oSection1:Cell("CMLMT"             ):SetValue(wtemp[wrec,20]) 
oSection1:Cell("CMCONS"           ):SetValue(wtemp[wrec,21]) 
oSection1:Cell("CLASESTQ"        ):SetValue(wtemp[wrec,22]) 
 
 

oSection1:PrintLine()
oReport:IncMeter()

if oReport:nDevice==4
   oSection1:lheaderSection:=.F.
Endif

Next wrec

oSection1:Finish() 
  
Return
