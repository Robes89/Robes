#include "rwmake.ch"  


/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o  RELPVPC  ³  ³ Autor ³Ilidio F. Abreu        ³ Data ³ 23/11/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio de pedidos de Vendas e Compras e suas            .³±±
±±³          ³datas (emissao, digitacao, entrega prometida e efetiva)     ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico: LMT                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                   
                      
user Function RELPVPC   
 /*

Local cDesc1         := "Este programa tem como objetivo imprimir as datas "
Local cDesc2         := "dos pedidos de Venda e Compra."
Local cDesc3         := "Pedidos por Data"
Local cPict          := ""
Local titulo       := "Pedidos por Data"
Local nLin         := 80

Local Cabec1       := ""
Local Cabec2       := ""
Local imprime      := .T.
Private aOrd             := {"Pedido","Produto","Entrega LMT"}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite           := 132
Private tamanho          := "M"
Private nomeprog         := "RELPVPC" 
Private nTipo            := 18
Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey        := 0

Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "RELPVPC" 
 */
Private cString := "SC6"

if CHKFILE("COMPRA")
	COMPRA->(DBCLOSEAREA()) 
endif	
 if CHKFILE("VENDA")
	VENDA->(DBCLOSEAREA()) 
endif
 

cPerg    := PadR( 'RELPVP' , Len( SX1->X1_GRUPO ) )
AjustaSX1()  
pergunte(cPerg,.t.)

@ 86,42 TO 283,435 DIALOG oDlg TITLE "Datas de Pedidos"
@ 70,080 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
@ 70,118 BMPBUTTON TYPE 1 ACTION _Proc()
@ 70,156 BMPBUTTON TYPE 2 ACTION Close(oDlg)
@ 23,14 SAY " " size 200,10
@ 33,14 SAY "" size 200,10
@ 43,14 SAY ""
@ 8,10 TO 060,180
ACTIVATE DIALOG oDlg CENTERED
// DBCLOSEAREA("COMPRA")         
Return

//________________
Static Function _Proc


dbSelectArea("SC6")
dbSetOrder(2)




//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)


//SetDefault(aReturn,cString)


// nTipo := If(aReturn[4]==1,15,18)

//____________________________________________________________________
//RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
RunReport()
Return

//____________________________________________________________________
Static Function RunReport()

Local nOrdem
aStru := {}
//Vendas
aAdd(aStru,{"CODIGO",		"C",	TamSx3( "B1_COD" )[1],		TamSx3( "B1_COD")[2] } )
aAdd(aStru,{"COD_LMT",		"C",	TamSx3( "B1_CODLMT" )[1],	TamSx3( "B1_CODLMT")[2] } )
aAdd(aStru,{"STATPED",		"C",	TamSx3( "C5_STPAD" )[1],	TamSx3( "C5_STPAD")[2] } )

aAdd(aStru,{"DESCRICAO",	"C",	TamSx3( "B1_DESC" )[1],		TamSx3( "B1_COD")[2] } )
aAdd(aStru,{"PED_VENDA",	"C",	TamSx3( "C6_NUM" )[1],		TamSx3( "C6_NUM")[2] } )  
aAdd(aStru,{"PV_CLIENTE",	"C",	TamSx3( "C6_PEDCLI" )[1],	TamSx3( "C6_PEDCLI")[2] } )  

aAdd(aStru,{"CLIENTE",		"C",	TamSx3( "C5_NOMECLI" )[1],	TamSx3( "C5_NOMECLI")[2] } )
aAdd(aStru,{"ENTR_CLI",		"D",	TamSx3( "C6_PROMET" )[1],	TamSx3( "C6_PROMET")[2] } )
aAdd(aStru,{"ENTR_LMT",		"D",	TamSx3( "C6_ENTREG" )[1],	TamSx3( "C6_ENTREG")[2] } )  
aAdd(aStru,{"SUGEST_ENT",	"D",	TamSx3( "C6_SUGENTR" )[1],	TamSx3( "C6_SUGENTR")[2] } )
aAdd(aStru,{"EMISSAO",		"D",   	TamSx3( "C5_EMISSAO" )[1],	TamSx3( "C5_EMISSAO")[2] } )  
aAdd(aStru,{"EMISS_CLIE",	"D",	TamSx3( "C5_DTPDCLI" )[1],	TamSx3( "C5_DTPDCLI")[2] } )

aAdd(aStru,{"QTD_PV",		"N",	TamSx3( "C6_QTDVEN" )[1],	TamSx3( "C6_QTDVEN")[2] } )
aAdd(aStru,{"ESTOQUE",		"N",	TamSx3( "B2_QATU" )[1],		TamSx3( "B2_QATU")[2] } )

aAdd(aStru,{"COMPRA1",		"C",	TamSx3( "C7_NUM" )[1],		TamSx3( "C7_NUM")[2] } )
aAdd(aStru,{"QTD_PC1",		"N",	TamSx3( "C7_QUANT" )[1],	TamSx3( "C7_QUANT")[2] } )
aAdd(aStru,{"SOLIC_LMT1",	"D",	TamSx3( "C7_DATPRF" )[1],	TamSx3( "C7_DATPRF")[2] } )
aAdd(aStru,{"PREVISAO1",	"D",	TamSx3( "C7_PRVENT" )[1],	TamSx3( "C7_PRVENT")[2] } )
aAdd(aStru,{"EMISS_PC1",	"D",	TamSx3( "C7_EMISSAO" )[1],	TamSx3( "C7_EMISSAO")[2] } )

aAdd(aStru,{"COMPRA2",		"C",	TamSx3( "C7_NUM" )[1],		TamSx3( "C7_NUM")[2] } )
aAdd(aStru,{"QTD_PC2",		"N",	TamSx3( "C7_QUANT" )[1],	TamSx3( "C7_QUANT")[2] } )
aAdd(aStru,{"SOLIC_LMT2",	"D",	TamSx3( "C7_DATPRF" )[1],	TamSx3( "C7_DATPRF")[2] } )
aAdd(aStru,{"PREVISAO2",	"D",	TamSx3( "C7_PRVENT" )[1],	TamSx3( "C7_PRVENT")[2] } )
aAdd(aStru,{"EMISS_PC2",	"D",	TamSx3( "C7_EMISSAO" )[1],	TamSx3( "C7_EMISSAO")[2] } )

aAdd(aStru,{"COMPRA3",		"C",	TamSx3( "C7_NUM" )[1],		TamSx3( "C7_NUM")[2] } )
aAdd(aStru,{"QTD_PC3",		"N",	TamSx3( "C7_QUANT" )[1],	TamSx3( "C7_QUANT")[2] } )
aAdd(aStru,{"SOLIC_LMT3",	"D",	TamSx3( "C7_DATPRF" )[1],	TamSx3( "C7_DATPRF")[2] } )
aAdd(aStru,{"PREVISAO3",	"D",	TamSx3( "C7_PRVENT" )[1],	TamSx3( "C7_PRVENT")[2] } )
aAdd(aStru,{"EMISS_PC3",	"D",	TamSx3( "C7_EMISSAO" )[1],	TamSx3( "C7_EMISSAO")[2] } )
  
oTemptable := FWTemporaryTable():New( "TRB")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"CODIGO"} )
oTempTable:Create()
/*
cArq := CriaTrab(aStru,.T.)
dbUseArea(.T.,,cArq,"TRB",.T.)
cInd := CriaTrab(NIL,.F.)
IndRegua("TRB",cInd,"CODIGO",,,"Selecionando Registros...")
*/
dbSelectArea(cString)

// nOrdem := aReturn[8]
dbSetOrder(nOrdem)

//SetRegua(RecCount())

dbGoTop()
                                          
// mv_par07	:= if(type('mv_par07') # "D", dtos(ctod(mv_par07)),mv_par07)
// mv_par08	:= if(type('mv_par08') # "D",  dtos(ctod(mv_par08)),mv_par08)
    // Pedido de Venda C6_NUM == "041858"
cQuery	:= "SELECT SC6.C6_PRODUTO AS CODIGO, SC5.C5_STPAD, SC6.C6_CODLMT AS COD_LMT, SC6.C6_PEDCLI AS PV_CLIENTE, "
cQuery	+= "SB1.B1_DESC AS DESCRICAO,  "
cQuery	+= "C6_NUM AS PED_VENDA, (SC6.C6_QTDVEN - SC6.C6_QTDENT) AS QTD_PV, SC6.C6_PROMET AS ENTR_CLI, SC6.C6_ENTREG AS ENTR_LMT, "
cQuery	+= "SC6.C6_SUGENTR AS ENTR_APS, SC5.C5_EMISSAO AS EMISSAO, SC5.C5_NOMECLI AS CLIENTE, "
cQuery	+= " SC5.C5_DTPDCLI AS EMISS_CLIE, SC6.C6_DATFAT AS FATURAMENTO"
cQuery	+= " FROM "+RetSqlName("SC5")+" SC5 ," + RetSqlName("SC6")+" SC6, "	+ RetSqlName("SB1")+" SB1, "
cQuery	+= RetSqlName("SF4")+" SF4 " 	
cQuery += "WHERE  SC6.C6_NUM = SC5.C5_NUM AND "
cQuery += " SC6.C6_PRODUTO BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' AND "
cQuery += " SC6.C6_ENTREG BETWEEN '"+DTOS(mv_par07)+"' AND '"+DTOS(mv_par08)+"' AND "
cQuery	+= " SC5.C5_VEND1 BETWEEN '"+mv_par09+"' AND '"+mv_par10+"' AND "
cQuery	+= " SC5.C5_CLIENTE BETWEEN '"+mv_par11+"' AND '"+mv_par12+"' AND "


if ! empty(ALLTRIM(mv_par14))
	cQuery  += " SUBSTR(SC6.C6_PRODUTO,1,2) = '" +ALLTRIM(mv_par14)+ "' AND "
endif

cQuery += " SC6.C6_CODLMT BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' AND "
cQuery += " SC6.C6_QTDENT < SC6.C6_QTDVEN AND SC6.C6_BLQ <> 'R' AND SC6.D_E_L_E_T_=' ' AND SC5.D_E_L_E_T_=' ' AND "  
cQuery	+= "SC6.C6_PRODUTO = SB1.B1_COD AND (SC6.C6_TES = SF4.F4_CODIGO AND SF4.F4_DUPLIC = 'S' ) AND "
cQuery	+= "SB1.B1_TIPO = 'PA' "
cQuery += "AND SC5.C5_EMISSAO BETWEEN '"+DTOS(mv_par03)+"' AND '"+DTOS(mv_par04)+"' ORDER BY SC6.C6_PRODUTO"   //C5_DTPDCLI
// cQuery := ChangeQuery(cQuery)

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "VENDA", .F., .T.) 


	// Pedido de Compra
cQuery	:= "SELECT SC7.C7_PRODUTO AS CODIGO, SC7.C7_CODLMT AS CODLMT, SC7.C7_QUANT AS QTD_PC, SC7.C7_DATPRF AS SOLIC_LMT, "
cQuery	+= " SC7.C7_PRVENT AS PREVISAO, SC7.C7_EMISSAO AS EMISS_PC, C7_NUM AS PED_COMPRA, SB1.B1_DESC "
//cQuery	+= " SB2.B2_QATU AS ESTOQUE "
cQuery	+= " FROM "+ RetSqlName("SC7")+" SC7, "+ RetSqlName("SF4")+ " SF4, "+ RetSqlName("SB1")+ " SB1, "
cQuery	+= + RetSqlName("SD1")+" SD1 "
cQuery += "WHERE SC7.C7_PRODUTO BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' AND "
cQuery += "SC7.C7_NUM = SD1.D1_PEDIDO AND "
cQuery += "SD1.D1_DTDIGIT BETWEEN '"+DTOS(mv_par07)+"' AND '"+DTOS(mv_par08)+"' AND "
cQuery += "SC7.C7_CODLMT BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' AND "
cQuery	+= "SC7.C7_ENCER = ' ' AND SC7.C7_TES = SF4.F4_CODIGO  AND " 
cQuery	+= " SB1.B1_TIPO = 'PA' AND"

if ! empty(ALLTRIM(mv_par14))
	cQuery  += " SUBSTR(SB1.B1_COD,1,2) = '" +ALLTRIM(mv_par14)+ "' AND "
endif

cQuery	+= " SF4.F4_DUPLIC = 'S' AND SC7.C7_PRODUTO = SB1.B1_COD AND "
cQuery	+= " SC7.C7_EMISSAO BETWEEN '"+DTOS(mv_par03)+"' AND '"+DTOS(mv_par04)+"' " 
cQuery	+= " ORDER BY C7_PRODUTO
cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "COMPRA", .F., .T.)

dbselectarea("SB2")
SB2->(INDEXORD(1))
_nEst := 0

dbselectarea("VENDA")
dbgotop()
while ! VENDA->(eof())                                  
	if !C5_STPAD $  ALLTRIM(mv_par13)
		venda->(dbskip())	
		loop
	endif   
	if SB2->(dbseek(xfilial("SB1")+VENDA->CODIGO))
		_nEst := SaldoSB2()
	endif
	
    reclock("TRB",.t.)
	TRB->CODIGO		:=	VENDA->CODIGO
	TRB->COD_LMT	:=	VENDA->COD_LMT
	TRB->DESCRICAO	:=	VENDA->DESCRICAO
	TRB->PED_VENDA	:=	VENDA->PED_VENDA
	TRB->PV_CLIENTE	:=	VENDA->PV_CLIENTE
	TRB->QTD_PV		:=	VENDA->QTD_PV
	TRB->ENTR_CLI	:=	stod(VENDA->ENTR_CLI)
	TRB->ENTR_LMT	:=	stod(VENDA->ENTR_LMT)
	TRB->SUGEST_ENT	:=	stod(VENDA->ENTR_APS)
	TRB->EMISSAO	:=	stod(VENDA->EMISSAO)
	TRB->CLIENTE	:=	VENDA->CLIENTE
	TRB->EMISS_CLIE	:=	stod(VENDA->EMISS_CLIE)      
	TRB->ESTOQUE	:=  _nEst
	TRB->STATPED  	:=  VENDA->C5_STPAD
	msunlockall()                      

	_nEst := 0
	venda->(dbskip())

enddo	
//DBCLOSEAREA("VENDA")
dbselectarea("COMPRA")
dbgotop()


while ! COMPRA->(eof())
    reclock("TRB",(!TRB->(DBSEEK( COMPRA->CODIGO))))
	TRB->CODIGO		:=	COMPRA->CODIGO
	TRB->DESCRICAO	:=	COMPRA->B1_DESC
//		TRB->ESTOQUE	:=  COMPRA->ESTOQUE	
	TRB->COD_LMT	:=	COMPRA->CODLMT

// A partir de 07/12/09 comecaram a digitar a data EMISS_PC com mais 10 dias devido ao tempo de traslado	
	if empty(alltrim(TRB->COMPRA1))
		TRB->COMPRA1	:=	COMPRA->PED_COMPRA
		TRB->QTD_PC1	:=	COMPRA->QTD_PC         
		TRB->SOLIC_LMT1	:=	if(stod(COMPRA->EMISS_PC) < ctod("07/12/09"),stod(COMPRA->SOLIC_LMT) + 10,stod(COMPRA->SOLIC_LMT))
		TRB->PREVISAO1	:=	stod(COMPRA->PREVISAO)
		TRB->EMISS_PC1	:=	stod(COMPRA->EMISS_PC)
	elseif empty(alltrim(TRB->COMPRA2)) .and. ! COMPRA->PED_COMPRA $(TRB->COMPRA1)
		TRB->COMPRA2	:=	COMPRA->PED_COMPRA
		TRB->QTD_PC2	:=	COMPRA->QTD_PC         
		TRB->SOLIC_LMT2	:=	if(stod(COMPRA->EMISS_PC) < ctod("07/12/09"),stod(COMPRA->SOLIC_LMT) + 10,stod(COMPRA->SOLIC_LMT))
		TRB->PREVISAO2	:=	stod(COMPRA->PREVISAO)
		TRB->EMISS_PC2	:=	stod(COMPRA->EMISS_PC)
	elseif empty(alltrim(TRB->COMPRA3)) .and. ! COMPRA->PED_COMPRA $(TRB->COMPRA1+"|"+TRB->COMPRA1)
		TRB->COMPRA3	:=	COMPRA->PED_COMPRA
		TRB->QTD_PC3	:=	COMPRA->QTD_PC         
		TRB->SOLIC_LMT3	:=	if(stod(COMPRA->EMISS_PC) < ctod("07/12/09"),stod(COMPRA->SOLIC_LMT) + 10,stod(COMPRA->SOLIC_LMT))
		TRB->PREVISAO3	:=	stod(COMPRA->PREVISAO)
		TRB->EMISS_PC3	:=	stod(COMPRA->EMISS_PC)
	endif
	msunlockall()
	COMPRA->(dbskip())

EndDo
// DBCLOSEAREA("COMPRA")         

dbselectarea("TRB")
 //OPY TO "TRB.DBF" VIA "DBFCDXADS"
__CopyFile( "TRB.DBF" , "C:\" + "DATAPED.XLS" )       



SET DEVICE TO SCREEN

MsgBox( "Criado o Arquivc DATAPED.XLS em ' C:\ '" )
DBCLOSEAREA("TRB")

Return

//_________________________________________________
Static Function AjustaSX1()
aPerg    := {}
cPerg    := "RELPVP    "

Aadd( aPerg , { "Codigo de           ?", "C" , 15 , 0, "SB1"})    // MV_PAR01
Aadd( aPerg , { "Codigo ate          ?", "C" , 15 , 0, "SB1"})    // MV_PAR02
Aadd( aPerg , { "Emissao de          ?", "D" , 8 , 0, ""})   		// MV_PAR03
Aadd( aPerg , { "Emissao ate         ?", "D" , 8 , 0, ""})   		// MV_PAR04
Aadd( aPerg , { "Do Cod Lmt          ?", "C" , TamSX3( "B1_CODLMT" )[1], 0 , "SB1LMT"})
Aadd( aPerg , { "Ate Cod Lmt         ?", "C" , TamSX3( "B1_CODLMT" )[1], 0 , "SB1LMT"})
Aadd( aPerg , { "Da Data de Entrega  ?", "D" , 8 , 0, ""})   		// MV_PAR07
Aadd( aPerg , { "Ate Data de Entrega ?", "D" , 8 , 0, ""})  		// MV_PAR08
Aadd( aPerg , { "Do Vendedor         ?", "C" , 6 , 0, "SA3"})  	 	// MV_PAR09
Aadd( aPerg , { "Ate Vendedor        ?", "C" , 6 , 0, "SA3"})   		// MV_PAR010
Aadd( aPerg , { "Do Cliente          ?", "C" , 6 , 0, "SA1"}) 	  	// MV_PAR011
Aadd( aPerg , { "Ate Cliente         ?", "C" , 6 , 0, "SA1"})   		// MV_PAR012
Aadd( aPerg , { "Status Ped (SEPDICO)?", "C" , 7 , 0, "   "})   		// MV_PAR013
Aadd( aPerg , { "Fabricante          ?", "C" , 2 , 0, "   "})   		// MV_PAR014



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
	EndIf
Next nXX
Return Nil
