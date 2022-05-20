#INCLUDE "rwmake.ch"       

// Rotina		: CONEST
// Descrição	: Tela de consulta de estoque
// Data			: 30/12/04
// Autor        : Daniel Gondran

User Function CONEST()
cCadastro := "Consulta Produtos"
aRotina := { { "Pesquisar","AxPesqui", 0 , 1},;
             { "Consultar","U_adTela()"  , 0 , 3}}

mBrowse( 6, 1,22,75,"SB1")

Return

// *******************************************************************************************************************
User Function adTela(lContinua)

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
Local cTabela   := GetMv( "MV_TABPREC" )
Local nDias		:= GetMV("MV_DIASEST")
Local nSaldo07	:= 0
Local nSaldTra	:= 0

Private cCadastro := "Consulta posição estoque"

If ( lContinua )
	dbSelectArea("SB1")
	dbSetOrder(9)
	If dbSeek(xFilial()+mv_par01,.F.)
		lContinua := .T.
	Else
		Alert("Codigo não Encontrado")
		Return(1)
	EndIf
EndIf
                              
dbSelectArea("SB2")           
dbSetOrder(1)
IF dbSeek(xFilial("SB2") + SB1->B1_COD + "07")
   nSaldo07 := SB2->B2_QATU - SB2->B2_QEMP
ENDIF   

dbSelectArea("SB2")           
dbSetOrder(1)
dbSeek(xFilial("SB2") + SB1->B1_COD + SB1->B1_LOCPAD)

If ( __cUserID ) $ GetMv( "MV_CONEST" )
	aHeader  := {"Tipo","Entrega","Numero","Empresa","Quantidade","Status","Prc.Unitário","Data"}//Everton
Else
	aHeader  := {"Tipo","Entrega","Numero","Empresa","Quantidade","Status"}
EndIf
nDispo  := SB2->B2_QATU - SB2->B2_QEMP
nCont   := 0
nImedi1 := SB2->B2_QATU 
nImedi2 := SB2->B2_QATU 
nImedi3 := SB2->B2_QATU 

ZZ1->( DBSETORDER( 5 ) )
ZZ1->( DBSEEK( XFILIAL("ZZ1") + SB1->B1_COD ) )

DO WHILE ! ZZ1->( EOF() ) .AND. ZZ1->ZZ1_LMTCOD == SB1->B1_COD

   IF ! EMPTY( ZZ1->ZZ1_NFISCA )
      ZZ1->( DBSKIP() )
      LOOP
   ENDIF
   
   nSaldTra := nSaldTra + ZZ1->ZZ1_QTY
   
   ZZ1->( DBSKIP() )
   
ENDDO      

dbSelectArea("DA1")
dbSetOrder(1)
dbSeek(xFilial("DA1") + cTabela + SB1->B1_COD)
                                 
dbSelectArea("SC6")
dbSetOrder(2)
dbSeek(xFilial("SC6") + SB1->B1_COD)
nSaida := 0
While !Eof() .and. C6_FILIAL == xFilial() .and. C6_PRODUTO == SB1->B1_COD
	nSaldo := C6_QTDVEN - C6_QTDENT
	If nSaldo > 0 .and. C6_BLQ <> "R "
		dbSelectArea("SC5")
		dbSetOrder(1)
		dbSeek(xFilial("SC5") + SC6->C6_NUM)		
		If	SM0->M0_CODIGO == "01"
			cStatus := Iif(SC5->C5_STPAD=="S","Simples",Iif(SC5->C5_STPAD=="E","Estimado",;
		    		   Iif(SC5->C5_STPAD=="P","Programado",Iif(SC5->C5_STPAD=="D","Demonstraçãoo",;
	    			   Iif(SC5->C5_STPAD=="I","Industrialização",Iif(SC5->C5_STPAD=="C","Consignação",;
	    			   Iif(SC5->C5_STPAD=="O","Outros",Iif(SC5->C5_STPAD=="M","Mostruario"," "))))))))
//	    			   Iif(SC5->C5_STPAD=="O","Outros"," ")))))))           //#FAP20170314
			If ( __cUserID ) $ GetMv( "MV_CONEST" )
//				Aadd(bcols,{"PV",Dtoc(SC6->C6_PROMET),SC6->C6_NUM+" / "+SC6->C6_ITEM,SC5->C5_NOMECLI,;
//				            Transform(nSaldo,"   999,999"),cStatus,TransForm(SC6->C6_PRCVEN,"@E 999,999.99"),SC5->C5_EMISSAO})
				Aadd(bcols,{"PV",Dtoc(SC6->C6_PROMET),SC6->C6_NUM+" / "+SC6->C6_ITEM,SC5->C5_NOMECLI,;
				            Transform(nSaldo,"   999,999"),cStatus,TransForm(SC6->C6_PRCVEN,"@E 999,999.99"),SC5->C5_EMISSAO})

			Else
//				Aadd(bcols,{"PV",Dtoc(SC6->C6_PROMET),SC6->C6_NUM+" / "+SC6->C6_ITEM,SC5->C5_NOMECLI,;
//				            Transform(nSaldo,"   999,999"),cStatus})
				Aadd(bcols,{"PV",Dtoc(SC6->C6_PROMET),SC6->C6_NUM+" / "+SC6->C6_ITEM,SC5->C5_NOMECLI,;
				            Transform(nSaldo,"   999,999"),cStatus})

			EndIf
		Else
			cStatus	:= " "
			If ( __cUserID ) $ GetMv( "MV_CONEST" )
				Aadd(bcols,{"PV",Dtoc(SC6->C6_PROMET),SC6->C6_NUM+" / "+SC6->C6_ITEM,POSICIONE("SA1",1,XFILIAL("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI),"A1_NREDUZ"),;
				            Transform(nSaldo,"   999,999"),cStatus,TransForm(SC6->C6_PRCVEN,"@E 999,999.99"),SC5->C5_EMISSAO})
			Else
				Aadd(bcols,{"PV",Dtoc(SC6->C6_PROMET),SC6->C6_NUM+" / "+SC6->C6_ITEM,SC5->C5_NOMECLI,;
				            Transform(nSaldo,"   999,999"),cStatus})
			EndIf

		EndIf

		nDispo 	-= nSaldo
		nSaida 	+= nSaldo
		nCont++
	Endif
	dbSelectArea("SC6")
	dbSkip()
Enddo

dbSelectArea("SC7")
dbSetOrder(4)
dbSeek(xFilial("SC7") + SB1->B1_COD)
nEntra := 0
While !Eof() .and. C7_FILIAL == xFilial() .and. C7_PRODUTO == SB1->B1_COD
	nSaldo := C7_QUANT - C7_QUJE
	If nSaldo > 0 .AND. C7_RESIDUO <> "S"
		cStatus := " "
		dbSelectArea("SA2")
		dbSetOrder(1)
		dbSeek(xFilial("SA2") + SC7->C7_FORNECE)
		If ( __cUserID ) $ GetMv( "MV_CONEST" )
//			Aadd(bcols,{"PC",Dtoc(SC7->C7_DATPRF),SC7->C7_NUM+" / "+SC7->C7_ITEM,SA2->A2_NREDUZ,;
//			            Transform(nSaldo,"   999,999"),cStatus,SC7->C7_PRECO,SC7->C7_EMISSAO})
			Aadd(bcols,{"PC",Dtoc(SC7->C7_DATPRF),SC7->C7_NUM+" / "+SC7->C7_ITEM,SA2->A2_NREDUZ,;
			            Transform(nSaldo,"   999,999"),cStatus,SC7->C7_PRECO,SC7->C7_EMISSAO})
		Else
//			Aadd(bcols,{"PC",Dtoc(SC7->C7_DATPRF),SC7->C7_NUM+" / "+SC7->C7_ITEM,SA2->A2_NREDUZ,;
//			            Transform(nSaldo,"   999,999"),cStatus})
			Aadd(bcols,{"PC",Dtoc(SC7->C7_DATPRF),SC7->C7_NUM+" / "+SC7->C7_ITEM,SA2->A2_NREDUZ,;
			            Transform(nSaldo,"   999,999"),cStatus})
		EndIf
		nDispo  += nSaldo
		nEntra  += nSaldo
		nCont++
	Endif 
	dbSelectArea("SC7")
	dbSkip()
Enddo

dbSelectArea("SC2")
dbSetOrder(2)
dbSeek(xFilial("SC2") + SB1->B1_COD)

While !Eof() .and. C2_FILIAL == xFilial() .and. C2_PRODUTO == SB1->B1_COD
	nSaldo := C2_QUANT - C2_QUJE - C2_PERDA
	If nSaldo > 0 .AND. Empty(C2_DATRF)
		cStatus := " "
		If ( __cUserID ) $ GetMv( "MV_CONEST" )
			Aadd(bcols,{"OP",Dtoc(SC2->C2_DATPRF),SC2->C2_NUM+" / "+SC2->C2_ITEM," ",;
			            Transform(nSaldo,"   999,999"),cStatus,0,SC2->C2_EMISSAO})
		Else
			Aadd(bcols,{"OP",Dtoc(SC2->C2_DATPRF),SC2->C2_NUM+" / "+SC2->C2_ITEM," ",;
			            Transform(nSaldo,"   999,999"),cStatus})
		EndIf
		
		nImedi1 -= nSaldo
		nDispo += nSaldo
		nEntra += nSaldo
		nCont++
	Endif
	dbSkip()
Enddo

dbSelectArea("SD4")
dbSetOrder(1)
dbSeek(xFilial("SD4") + SB1->B1_COD)

dbSelectArea("SC2")
dbSetOrder(1)
dbSeek(xFilial("SC2") + SD4->D4_OP)

dbSelectArea("SD4")

While !Eof() .and. D4_FILIAL == xFilial() .and. D4_COD == SB1->B1_COD
	nSaldo := SD4->D4_QUANT 
	If nSaldo > 0 
		SC2->( dbSeek(xFilial("SC2") + SD4->D4_OP) )
		cStatus := " "
		If ( __cUserID ) $ GetMv( "MV_CONEST" )
			Aadd(bcols,{"REQ",Dtoc(SD4->D4_DATA),LEFT(SD4->D4_OP,6)+" / "+SUBSTR(SD4->D4_OP,7,2)," ",;
			            Transform(nSaldo,"    999,999"),cStatus,0,SC2->C2_EMISSAO})
		Else
			Aadd(bcols,{"REQ",Dtoc(SD4->D4_DATA),LEFT(SD4->D4_OP,6)+" / "+SUBSTR(SD4->D4_OP,7,2)," ",;
			            Transform(nSaldo,"    999,999"),cStatus})
		EndIf
		
		nImedi1 -= nSaldo
		nCont++
	Endif
	dbSkip()
Enddo

If nCont == 0
	If ( __cUserID ) $ GetMv( "MV_CONEST" )
		Aadd(bcols,{" "," "," "," "," "," "," "," "})
	Else
		Aadd(bcols,{" "," "," "," "," "," "})
	EndIf
Endif

aCols := Asort(bCols,,,{ |x , y| x[1] + Dtos(ctod(x[2])) + x[3] < y[1] + Dtos(ctod(y[2])) + y[3]})

//DEFINE MSDIALOG oDlg FROM  125,3 TO 430,608 TITLE cCadastro PIXEL 
DEFINE MSDIALOG oDlg FROM  125,3 TO 480,770 TITLE cCadastro PIXEL 
//@ 003, 004  TO 033, 299 
//@ 130, 004  TO 150, 155 
//@ 130, 160  TO 150, 240 

//DEFINE SBUTTON FROM 138, 242 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM 163, 325 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
//DEFINE SBUTTON FROM 138, 272 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
DEFINE SBUTTON FROM 163, 355 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
/*
@ 135, 007 BUTTON "Posicao"   SIZE 28,11  ACTION (U_Posic(),cCadastro:= OemToAnsi(STR0005) )               
@ 135, 036 BUTTON "Cliente"   SIZE 28,11  ACTION (cCadastro:=OemToAnsi(STR0037),AxVisual("SA1",SA1->(RecNo()),1),cCadastro:= OemToAnsi(STR0005) )  	
@ 135, 065 BUTTON "Pedido"    SIZE 28,11  ACTION (cCadastro:=OemToAnsi(STR0038),a410Visual("SC5",SC5->(RecNo()),1),cCadastro:= OemToAnsi(STR0005) )	
@ 135, 094 BUTTON "Estoque"   SIZE 28,11  ACTION ( a450ConEst(cProduto,cLocal) )  
@ 135, 123 BUTTON "Imprime"   SIZE 28,11  ACTION ( U_ImpCre() )  
	
@ 135, 165 BUTTON OemToAnsi(STR0011)   SIZE 34,11  ACTION (nOpca := 4,oDlg:End() )      				//"Lib.Todos"
@ 135, 200 BUTTON "Sair"   SIZE 34,11  ACTION (nOpca := 3,oDlg:End() )      				//"Rejeita"
*/
@ 009, 008 SAY "Produto:"              //SIZE 23, 7   
If	SM0->M0_CODIGO == "01"				// LMT
	@ 009, 050 SAY SB1->B1_CODLMT          //SIZE 26, 7 
Else
	@ 009, 050 SAY SB1->B1_COD         //SIZE 26, 7 
EndIf
@ 009, 288 SAY "Tabela de Preço:"      SIZE 42, 7   
@ 009, 330 SAY cTabela
@ 017, 008 SAY "Denominação:"          //SIZE 35, 7  
If	SM0->M0_CODIGO == "01"				// LMT
	@ 017, 050 SAY SB1->B1_DENOM           //SIZE 96, 7 
Else
	@ 017, 050 SAY SB1->B1_DESC           //SIZE 96, 7 
EndIf
@ 025, 008 SAY "Estoque Atual:"        SIZE 42, 7   
@ 025, 050 SAY Transform(SB2->B2_QATU,"    999,999,999.99")
@ 025, 108 SAY "Estoque Imediato:"         SIZE 42, 7   
@ 025, 150 SAY Transform(SB2->B2_QATU-SB2->B2_QEMP,"    999,999,999.99")

@ 025, 208 SAY "Est.em Transito:"          SIZE 42, 7   
@ 025, 250 SAY Transform( nSaldTra,"    999,999,999.99")
@ 025, 288 SAY "Est.Desembaraço:"         SIZE 42, 7   
@ 025, 330 SAY Transform( nSaldo07,"    999,999,999.99")

//@ 025, 208 SAY "Estoque " + StrZero(ndias,2) + " dias:"     
//@ 025, 250 SAY Transform(nImedi2,"    999,999,999.99")
//@ 025, 288 SAY "Estoque acima " + StrZero(ndias,2) + " dias:"      
//@ 025, 330 SAY Transform(nImedi3,"    999,999,999.99")
@ 033, 008 SAY "Ped. Compras:"         SIZE 42, 7   
@ 033, 050 SAY Transform(nEntra,"    999,999,999.99")
@ 033, 108 SAY "Ped. Vendas:"          SIZE 42, 7   
@ 033, 150 SAY Transform(nSaida,"    999,999,999.99")
@ 033, 208 SAY "Empenho:"              SIZE 42, 7   
@ 033, 250 SAY Transform(SB2->B2_QEMP,"    999,999,999.99")
@ 033, 288 SAY "Preço Lista:"          SIZE 42, 7   
@ 033, 330 SAY Transform(DA1->DA1_PRCVEN,"    999,999,999.9999")
		
//oLbx := RDListBox(3, .5, 295, 95, bcols, aHeader,{15,35,40,100,33,20})
oLbx := RDListBox(3, .5, 380, 120, bcols, aHeader,{15,35,40,100,33,20})

ACTIVATE MSDIALOG oDlg

Return(nOpcA)

// *******************************************************************************************************************
Static Function AjustaSX1()
aPerg    := {}
//cPerg    := "_CONES"
cPerg    := PadR( '_CONES' , Len( SX1->X1_GRUPO ) )

Aadd( aPerg , { "Codigo LMT          ?" , "C" , TamSX3( "B1_CODLMT" )[1] , "SB1LMT"})

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
