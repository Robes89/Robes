#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

// Rotina	: GERACAO DA CARTEIRA DE PEDIDOS CONGELADA
// Descrição	: Relatorio Carteira congelada
// Data		: 26/12/2016
// Autor        : FERNANDO PACHECO

User Function CARTDP()
ncount := 0
// mv_par01 - Ano 
// mv_par02 - Mes 
// mv_par03 - Data de Corte   

cPerg := "CARTDP"
// cPerg    := PadR( 'CARTDP' , Len( SX1->X1_GRUPO ) )
//AjustaSX1()
Pergunte(cPerg,.T.)                            
Processa( {|| Runproc() } , "Gerando Arquivo" )
Return

STATIC FUNCTION Runproc()

iData 	 := mv_par03 //ctod("01/01/"+mv_par04)
mesano   := mv_par02+mv_par01 //strzero(month(mv_par03),2)+str(year(mv_par03),4)
mvpar01  := ctod("01/01/15") //ctod("01/"+mv_par02+"/"+mv_par01)
mvpar02  := ctod("31/12/20")
aEmps 	 := {"BO","FE","KI","NI","ON","BR","BI","MT"}
aEmpresa := {"BOEHLERIT","FETTE","KIENINGER","NIPPON","ONSRUD","FAB. BRASIL","BILZ","MORRIS TOOLING"}
//mtit1    := "Carteira "+Iif(mv_par05==2,"bruta","liquida")+" por " + Iif(mv_par03==1,"empresa","vendedor") + " " + mv_par04

/*
cQuery:= ""
cQuery+="  SELECT *  "
cQuery+=" 	FROM "+RetSqlName("SC6")+" "
cQuery+=" 	WHERE "                 
cQuery+="   C6_QTDENT < C6_QTDVEN AND "
//cQuery+=" 	C5_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' AND  "
cQuery+="  	C6_FILIAL = '"+xFilial("SC6")+"' AND "
cQuery+=" 	D_E_L_E_T_ <> '*'  "

cQuery+=" 	ORDER BY C6_NUM, C6_ITEM "

TcQuery cQuery New Alias "TRB"

TcSetField('TRB',"C6_ENTREG","D",08,0)
TcSetField('TRB',"C6_QTDVEN","N",12,2)
TcSetField('TRB',"C6_QTDENT","N",12,2)
TcSetField('TRB',"C6_PRCVEN","N",12,2)		

DbSelectArea("TRB")
Count to nCount

TRB->(DbGotop())
//SetRegua(nCount)

While TRB->(!EOF())
*/

Set SoftSeek On
cMoeda := "1"
dbselectarea("SC6")
//dbSetOrder(1)
dbSetOrder(12)
ProcRegua(LastRec())
dbSeek(xFilial("SC6")+dtos(mvpar01))
//dbSeek(xFilial("SC6")+"111842")
//DO WHILE !EOF() .AND. C6_FILIAL == xFilial() .and. DTOS(C6_PROMET) <= Dtos(mv_par04)
WHILE SC6->C6_FILIAL == xFilial() .and. DTOS(SC6->C6_PROMET) >= dtos(MVPAR01) .AND.;
	DTOS(SC6->C6_PROMET) <= dtos(mvpar02) .AND. SC6->(!EOF())
	
	IncProc( "Processando entrega dia » " + DtoC( SC6->C6_PROMET ) )
    
    If SC6->C6_NUM <> "111842"  
//       Exit
    Endif   

    If ALLTRIM(SC6->C6_ITEM) <> '12'  
//       SC6->(DBSKIP())
//       Loop
    Endif       
	dbSelectArea("SC5")
	dbSetOrder(1)
	dbSeek(xFilial("SC5") + SC6->C6_NUM)  
	If !(SC5->C5_STPAD $ "SP") 
		dbSelectArea("SC6")
		dbSkip()
		loop
	Endif

	nIndice   := Ascan(aEmps,Left(SC6->C6_PRODUTO,2))
	If nIndice == 0
		mEmpresa := "OUTROS              "
	Else
		mEmpresa := Padr(aEmpresa[nIndice],20)
	Endif

	nMoeda   := SC5->C5_MOEDA
	If nMoeda <> 1
		cMoeda := "M2_MOEDA" + StrZero(nMoeda,1)
		dbSelectArea("SM2")
		dbSeek(SC5->C5_EMISSAO)
		nConv  := &(cMoeda)
		If nConv == 0
		//	Alert ("Atenção: Cadastrar Moeda " + StrZero(nMoeda,1) + " no dia " + Dtoc(SC5->C5_EMISSAO))
		   nConv := 1
		Endif			
	Else
		nConv := 1
	Endif
	dbSelectArea("SC6")
	If SC6->C6_QTDENT < C6_QTDVEN .and. SC6->C6_BLQ <> "R "
//	SC6->C6_CODLMT >= mv_par01 .and. SC6->C6_CODLMT <= mv_par02 .and. ;
//	   SC6->C6_CLI >= mv_par07 .and. SC6->C6_CLI <= mv_par08 .and. ;
//	   SC5->C5_EMISSAO >= mv_par10 .and. SC5->C5_EMISSAO <= mv_par11 .and. ;
	   
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1") + SC6->C6_PRODUTO)
		cDenom := SB1->B1_DENOM
	
		dbSelectArea("SA1")     
		dbSetOrder(1)
		dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI)
	
//		If SC5->C5_VEND1 >= mv_par05 .and. SC5->C5_VEND1 <= mv_par06
			cVend 	 := SC5->C5_NOMEVEN
			cEmp  	 := SC5->C5_NOMECLI
			dEmissao := SC5->C5_EMISSAO
//		Else
//			dbSelectArea("SC6")
//			dbSkip()
//			Loop
//		Endif

		mVRUNIT   := xValTot(SC5->C5_CLIENTE,SC5->C5_LOJACLI,SA1->A1_TIPO,SC6->C6_PRODUTO,SC6->C6_TES,xQtdPed(SC6->C6_QTDVEN,SC6->C6_QTDENT,SC6->C6_BLQ,SC5->C5_EMISSAO) 	,SC6->C6_PRCVEN,SC5->C5_MOEDA,SC5->C5_EMISSAO,SC6->C6_NUM,SC6->C6_ITEM)
		mVRTOTAL  := mVRUNIT * xQtdPed(SC6->C6_QTDVEN,SC6->C6_QTDENT,SC6->C6_BLQ,SC5->C5_EMISSAO) 	
		mVRTOTAL  := mVRTOTAL * nConv
		
	dbSelectArea("SZ3")
	RecLock("SZ3",.T.)
	SZ3->Z3_FILIAL	:= XFILIAL("SZ3") 
	SZ3->Z3_ANO		:= MV_PAR01 
	SZ3->Z3_MES		:= MV_PAR02
	SZ3->Z3_PEDIDO	:= SC6->C6_NUM 
	SZ3->Z3_ITEM	:= SC6->C6_ITEM 
	SZ3->Z3_CLIENTE	:= SC5->C5_NOMECLI
	SZ3->Z3_STATPED	:= SC5->C5_STPAD 
	SZ3->Z3_EMISSAO	:= SC5->C5_EMISSAO
	SZ3->Z3_ENTREGA	:= SC6->C6_ENTREG
	SZ3->Z3_VEND	:= SC5->C5_NOMEVEN
	SZ3->Z3_PRODUTO	:= SC6->C6_PRODUTO
	SZ3->Z3_CODLMT	:= SC6->C6_CODLMT 
	SZ3->Z3_VALOR	:= mVRTOTAL
	SZ3->Z3_EMPRESA	:= mEmpresa
	SZ3->Z3_MOEDA	:= StrZero(SC5->C5_MOEDA,1)
	SZ3->Z3_RESIDUO	:= SC6->C6_BLQ 
	SZ3->Z3_DTCORTE	:= MV_PAR03
	SZ3->(msUnlock())

	dbSelectArea("SZ6")
	dbSetOrder(2)
	lAchou := dbSeek(xFilial("SZ6") + mesano + Dtos(SC6->C6_ENTREG) + SC6->C6_NUM + SC6->C6_ITEM)
        If !lAchou
			RecLock("SZ6",.t.)
			Z6_FILIAL 	:= SC6->C6_FILIAL
			Z6_MESANO 	:= mesano
			Z6_PRODUTO	:= SC6->C6_PRODUTO
			Z6_CODLMT	:= SC6->C6_CODLMT
			Z6_NUM		:= SC6->C6_NUM
			Z6_ITEM		:= SC6->C6_ITEM
			Z6_CLI		:= SC6->C6_CLI
			Z6_LOJA		:= SC6->C6_LOJA
			Z6_QTDVEN	:= SC6->C6_QTDVEN
			Z6_QTDENT	:= SC6->C6_QTDENT
			Z6_PRCVEN	:= SC6->C6_PRCVEN
			Z6_BLQ		:= SC6->C6_BLQ
			Z6_ENTREG	:= SC6->C6_ENTREG
			Z6_TES		:= SC6->C6_TES
			msUnlock()
		Endif

		dbSelectArea("SZ7")
		dbSetOrder(2)
		lAchou := dbSeek(xFilial("SZ7") + mesano + SC6->C6_NUM)
		If !lAchou
		   RecLock("SZ7",.T.)
		   Z7_FILIAL 	:= SC5->C5_FILIAL
		   Z7_MESANO 	:= mesano
		   Z7_STPAD		:= SC5->C5_STPAD
		   Z7_NUM		:= SC5->C5_NUM
		   Z7_EMISSAO	:= SC5->C5_EMISSAO
		   Z7_NOMEVEN	:= SC5->C5_NOMEVEN
		   Z7_NOMECLI	:= SC5->C5_NOMECLI
		   Z7_MOEDA		:= SC5->C5_MOEDA
		   msUnlock()
        Endif

    Endif
    dbSelectArea("SC6")
    SC6->(dbSkip())
Enddo
                                              
alert("Concluido")
Return

Static Function AjustaSX1()
aPerg    := {}

Aadd( aPerg , { "Ano                 ?" , "C" , 04 , "   "})
Aadd( aPerg , { "Mes                 ?" , "C" , 02 , "   "})
Aadd( aPerg , { "Data de Corte       ?" , "D" , 08 , "   "})
//Aadd( aPerg , { "Ano Referencia      ?" , "C" , 04 , "   "})
//Aadd( aPerg , { "Abate impostos      ?" , "N" , 01 , "   "})

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
		SX1->(MsUnlock())
	EndIf
Next nXX
Return Nil

Static Function xValTot(cCodCl,cLoj,cTpCli,cCodP,cTes,nQtd,nPrcUnit,nMoe,dEmis,cNumP,cItemP)

Local aArea := GetArea()
Local nTotal := 0
Local nVaIPI := 0
Local nVaICM := 0
Local nVaPIS := 0
Local nVaCOF := 0

Local lFat  := .f.

dbSelectArea("SD2")
dbSetOrder(13)
If dbSeek(cNumP+cItemP)
   nVaFrete  := SD2->D2_VALFRE
   nVaSeguro := SD2->D2_SEGURO
   nVaDespesa:= SD2->D2_DESPESA
   nVaICM    := SD2->D2_VALICM
   nVaIPI    := SD2->D2_VALIPI
   nVaCOF    := SD2->D2_VALIMP5
   nVaPIS    := SD2->D2_VALIMP6
   nTotal    := SD2->D2_TOTAL 
   nQtd      := SD2->D2_QUANT
   lFat      := .t.
Else
   nVaFrete  := 0
   nVaSeguro := 0     
   nVaDespesa:= 0
Endif   

// Inicializa a funcao fiscal para poder simular os valores dos impostos
MaFisIni(cCodCl,;	// 1-Codigo Cliente/Fornecedor (Obrigatorio)
cLoj,;			// 02-Loja do Cliente/Fornecedor (Obrigatorio)
"C",;			// 03-C:Cliente , F:Fornecedor (Obrigatorio)
"N",;			// 04-Tipo da NF( "N","D","B","C","P","I" ) (Obrigatorio)
cTpCli)			// 05-Tipo do Cliente/Fornecedor (Obrigatorio)

//Inicializa a funcao fiscal por itens para poder simular os valores dos impostos
MaFisAdd(cCodP,;   	// 1-Codigo do Produto ( Obrigatorio )
cTes,;	   			// 2-Codigo do TES ( Opcional )
nQtd,;	   			// 3-Quantidade ( Obrigatorio )
nPrcUnit,;  		// 4 -Preco Unitario ( Obrigatorio )
0,; 				// 5 -Valor do Desconto ( Opcional )
"",;				// 6 -Numero da NF Original ( Devolucao/Benef )
"",;				// 7 -Serie da NF Original ( Devolucao/Benef )
,;					// 8 -RecNo da NF Original no arq SD1/SD2
0,;					// 9 -Valor do Frete do Item ( Opcional )
0,;					// 10-Valor da Despesa do item ( Opcional )
0,;					// 11-Valor do Seguro do item ( Opcional )
0,;					// 12-Valor do Frete Autonomo ( Opcional )
nQtd * nPrcUnit)	// 13-Valor da Mercadoria ( Obrigatorio )

// Calcula os valor Total
  If !lFat	
	nTotal := MaFisRet(1,'IT_VALMERC') - MaFisRet(1,'IT_VALISS')

	nVaIPI := MaFisRet(1,'IT_VALIPI')
	nVaICM := MaFisRet(1,'IT_VALICM')
	nVaPIS := MaFisRet(1,'IT_VALPIS') + MaFisRet(1,'IT_VALPS2')
	nVaCOF := MaFisRet(1,'IT_VALCOF') + MaFisRet(1,'IT_VALCF2')
  Endif	
	nTotal := (nTotal - nVaICM - nVaPIS - nVaCOF + nVaFrete + nVaSeguro + nVaDespesa) / nQtd //- nVaIPI 

MaFisEnd()

RestArea( aArea )

Return (nTotal)

Static Function xQtdPed(nQV,nQE,cBL,dDTE)

local nVal := 0

nVal := nQV - nQE  

Return nVal

Static Function BuscaDados(cCampos,cGrupo)
Local cRetorno:=""

If SBM->(MsSeek(xFilial("SBM")+cGrupo))
	If cCampos=="BM_FAMILIA"
		cRetorno:=Posicione("SX5",1,xFilial("SX5") + "W2" + SBM->BM_FAMILIA , "X5_DESCRI")
	ElseIf cCampos=="BM_SUBGRUP"
		cRetorno:=Posicione("SX5",1,xFilial("SX5") + "W1" + SBM->BM_SUBGRUP , "X5_DESCRI")
	EndIf	
EndIf

Return cRetorno

