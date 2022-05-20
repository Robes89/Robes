#INCLUDE "rwmake.ch"       

// Rotina		: CONEST
// Descrição	: Tela de consulta de OPs
// Data			: 24/05/05
// Autor        : Daniel Gondran

User Function CONOPS()
/*
cPerg 	 := PadR( "_CONES" , Len( SX1->X1_GRUPO ) )
AjustaSX1()
Pergunte (cPerg,.F.)
@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Consulta de estoque"
@ 70,080 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
@ 70,118 BMPBUTTON TYPE 1 ACTION OkProc()
@ 70,156 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
@ 23,14 SAY "O objetivo desta rotina é apresentar o estoque" size 200,10
@ 33,14 SAY "e os clientes com pedidos pendentes"         size 200,10
@ 43,14 SAY " "
@ 8,10 TO 060,180
ACTIVATE DIALOG oDlg5 CENTERED
Return
*******************************************************************************************************************
Static Function OkProc()
Close(oDlg5)       
Processa({|| GeraMov() } , "Gerando Registros..." )
Return
*******************************************************************************************************************
Static Function GeraMov()
*/
cCadastro := "Consulta OPs"
aRotina := { { "Pesquisar","AxPesqui", 0 , 1},;
             { "Consultar","U_adTelao()"  , 0 , 3}}

mBrowse( 6, 1,22,75,"SC2")

//lContinua := .T.
//nOpcA := adTela( @lContinua )

Return
//************************************************************************************


User Function adTelao(lContinua)

Local aArea     := GetArea()
Local nSaldoLC  := 0
Local nValItem  := 0
Local nValPed   := 0
Local nLimCred  := 0
Local nMoeda    := 0
Local nQtdVen   := 0
Local nSalPedL  := 0
Local nSalPed   := 0
Local nSalDup	:= 0
Local nSalDupM	:= 0
Local nValAtraso:= 0
Local nOpca 	:= 0
Local nSalvEmp  := 0
Local nCntFor   := 0
Local cDescBloq := ""
Local cDescri   := ""
Local cCondSC9  := ""
Local oBtn
Local oDlg
Local bWhile    := Nil
Local nMCusto   := 0
Local nMCustoCli := 0  	
Local nDecs		:= 0
Local aSaldos
Local lLiberado := .F.
Local nSalFin   := 0
Local nSalFinM  := 0
Local nLcFin    := 0
Local nLcFinM   := 0
Local bcols     :={}
Local aHeader   :={}
Local cMoeda    := ""
Private cCadastro := "Consulta OPs"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona no SC2                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( lContinua )
	dbSelectArea("SC2")
	dbSetOrder(1)
	If dbSeek(xFilial()+mv_par01,.F.)
		lContinua := .T.
	Else
		Alert("Codigo não Encontrado")
		Return(1)
	EndIf
EndIf


aHeader  := {"Ped.Compra","Fornecedor","Emissao","Entrega","Qtd Solicitada","Qtd entregue"}
nDispo := SB2->B2_QATU
nCont  := 0

//Historico
dbSelectArea("SZ4")
dbSetOrder(1)
If dbSeek(xFilial("SZ4") + SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN)
	cCliente := SZ4->Z4_CLIENTE + " / " + SZ4->Z4_LOJA
	dEmissao := dtoc(SZ4->Z4_EMISSAO)
	nQuant	 := SZ4->Z4_QUANT
	dEntrega := dtoc(SZ4->Z4_ENTREGA) 
Else                                                          
	dbSelectArea("SC5")
	dbSetOrder(1)
	If dbSeek(xFilial("SC5") + SC2->C2_NUM)
		cCliente := SC5->C5_CLIENTE + " / " + SC5->C5_LOJACLI
	Else
		cCliente := "Sem Pedido Venda"
	Endif
    dEmissao := dToc(SC2->C2_EMISSAO)
    nQUant   := SC2->C2_QUANT
    dEntrega := dToc(SC2->C2_DATPRF)
Endif
	

//PC
nnOp := Str(Val(SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN),11)
dbSelectArea("SC7")
dbSetOrder(8)
dbSeek(xFilial("SC7") + AllTrim(nnOp))
nEntra := 0
do While !Eof() .and. C7_FILIAL == xFilial() .and. AllTrim(C7_OP) == AllTrim(nnOp)
	nSaldo := C7_QUANT - C7_QUJE
	If nSaldo > 0 .AND. C7_RESIDUO <> "S"
		cStatus := " "
		dbSelectArea("SA2")
		dbSetOrder(1)
		dbSeek(xFilial("SA2") + SC7->C7_FORNECE)
		Aadd(bcols,{SC7->C7_NUM+"/"+SC7->C7_ITEM,SA2->A2_NREDUZ,Dtoc(SC7->C7_EMISSAO),Dtoc(SC7->C7_DATPRF),;
		            Transform(SC7->C7_QUANT,"   999,999"),Transform(SC7->C7_QUJE,"   999,999")})
		nCont++
	Endif 
	dbSelectArea("SC7")
	dbSkip()
Enddo

If nCont == 0
	Aadd(bcols,{" "," "," "," "," "," "})
Endif

aCols := Asort(bCols,,,{ |x , y| x[1] < y[1]})

DEFINE MSDIALOG oDlg FROM  125,3 TO 450,608 TITLE cCadastro PIXEL 
//@ 003, 004  TO 033, 299 
//@ 130, 004  TO 150, 155 
//@ 130, 160  TO 150, 240 

@ 138, 202 BUTTON "Imprime"   SIZE 28,11  ACTION ( U_ImpCre() )  
DEFINE SBUTTON FROM 138, 242 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM 138, 272 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
/*
@ 135, 007 BUTTON "Posicao"   SIZE 28,11  ACTION (U_Posic(),cCadastro:= OemToAnsi(STR0005) )               
@ 135, 036 BUTTON "Cliente"   SIZE 28,11  ACTION (cCadastro:=OemToAnsi(STR0037),AxVisual("SA1",SA1->(RecNo()),1),cCadastro:= OemToAnsi(STR0005) )  	
@ 135, 065 BUTTON "Pedido"    SIZE 28,11  ACTION (cCadastro:=OemToAnsi(STR0038),a410Visual("SC5",SC5->(RecNo()),1),cCadastro:= OemToAnsi(STR0005) )	
@ 135, 094 BUTTON "Estoque"   SIZE 28,11  ACTION ( a450ConEst(cProduto,cLocal) )  
@ 135, 123 BUTTON "Imprime"   SIZE 28,11  ACTION ( U_ImpCre() )  
	
@ 135, 165 BUTTON OemToAnsi(STR0011)   SIZE 34,11  ACTION (nOpca := 4,oDlg:End() )      				//"Lib.Todos"
@ 135, 200 BUTTON "Sair"   SIZE 34,11  ACTION (nOpca := 3,oDlg:End() )      				//"Rejeita"
*/
@ 005, 008 SAY "OP:"             
@ 005, 020 SAY SC2->C2_NUM + " " + SC2->C2_ITEM + " " + SC2->C2_SEQUEN
@ 005, 060 SAY "Cliente:" 
@ 005, 090 SAY cCliente 
@ 005, 200 SAY "Emissao:"        SIZE 42, 7   
@ 005, 240 SAY dEmissao
@ 015, 008 SAY "Produto:"              SIZE 42, 7   
@ 015, 030 SAY SC2->C2_CODLMT
@ 015, 108 SAY "Quantidade:"          SIZE 42, 7   
@ 015, 150 SAY Transform(nQuant,"    999,999,999.99")
@ 015, 200 SAY "Entrega:"              SIZE 42, 7   
@ 015, 240 SAY dEntrega
@ 025, 008 SAY "Historico:"
@ 025, 033 Say Substr(SZ4->Z4_HIST,  1, 90)
@ 033, 033 Say Substr(SZ4->Z4_HIST, 91, 90)
@ 041, 033 Say Substr(SZ4->Z4_HIST,181, 90)		
@ 049, 033 Say Substr(SZ4->Z4_HIST,271, 90)		

oLbx := RDListBox(4, .5, 295, 80, bcols, aHeader,{30,55,35,35,50,50})

ACTIVATE MSDIALOG oDlg

Return(nOpcA)

// *--------------------------------------------------------------------------------------

Static Function AjustaSX1()
aPerg    := {}
cPerg    := PadR( "_CONOP" , Len( SX1->X1_GRUPO ) )

Aadd( aPerg , { "OP Numero         ?" , "C" , 11 , 0, "SC2"}) 

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
		SX1->(MsUnlock())
	EndIf
Next nXX
Return Nil