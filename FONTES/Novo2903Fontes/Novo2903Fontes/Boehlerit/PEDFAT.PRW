#include "rwmake.ch"
//#include "topconn.ch"
#Define IniFatLine  Chr(27)+Chr(06)+Chr(01)
#Define FimFatLine  Chr(27)+Chr(06)+Chr(02)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RELFAT    ºAutor  ³ Mauricio           º Data ³  29/03/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PROGRAMA PARA IMPRIMIR SEPARAÇÃO DE PEDIDO VENDAS          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ RELATORIO SEPRAÇÃO PEDIDO VENDAS                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PEDFAT()
Private cString        := "SC9"
Private aOrd           := {}
Private cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Private cDesc2         := "de acordo com os parametros informados pelo usuario."
Private cDesc3         := "SEPARAÇÃO DE PEDIDO"
Private tamanho        := "G"
Private nomeprog       := "PEDFAT001"
Private lAbortPrint    := .F.
Private nTipo          := 15
Private aReturn        := { "Zebrado", 1, "Administracao", 1, 1, 1, "", 1}
Private nLastKey       := 0
Private cPerg          := "PEDFAT"
Private titulo         := "SEPARAÇÃO DE PEDIDO"
Private Li             := 80
Private Cabec1         := ""
Private Cabec2         := ""
Private m_pag          := 01
Private wnrel          := "PEDFAT001"
Private lImp           := .F.
PRIVATE nPEDID         := ""
Private cCODCLI        := ""
Private cLOJA			:= ""
Private cNOMECLI    	:= ""
Private cENDERECO		:= ""
Private cESTADO			:= ""
Private cITEM			:= ""
Private cPRODUTO		:= ""
Private cDESCPROD		:= ""
Private nQUANTLIB		:= 0
Private cPEDIDO			:= ""
Private dDATALIB		:= ""
Private nLOCAL			:= 0
Private cVENDEDOR		:= ""
Private cTRANPNOME		:= ""
Private cFONETRANSP		:= ""
Private cDDDTRANSP		:= ""
Private cFRETE			:= ""
Private nQTDE			:= 0
Private nESTOQUE		:= 0
Private dDTENTREGA		:= ""
Private cUM				:= ""


//variaveis
// Carrega - Cria parametros
cPerg    := PADR(cPerg,10)
aRegs    := {}

aAdd(aRegs,{cPerg,"01","DO PEDIDO        ?"," "," ","mv_ch1","C", 06,0,0,"G","","mv_par01",""       ,"","","","",""       ,"","","","",""       ,"","","","","","","","","","","","","","   ","","","",""          })
aAdd(aRegs,{cPerg,"02","ATE O PEDIDO     ?"," "," ","mv_ch2","C", 06,0,0,"G","","mv_par02",""       ,"","","","",""       ,"","","","",""       ,"","","","","","","","","","","","","","   ","","","",""          })
aAdd(aRegs,{cPerg,"03","DATA DE          ?"," "," ","mv_ch3","D", 08,0,0,"G","","mv_par03",""       ,"","","","",""       ,"","","","",""       ,"","","","","","","","","","","","","","   ","","","",""          })
aAdd(aRegs,{cPerg,"04","DATA ATE         ?"," "," ","mv_ch4","D", 08,0,0,"G","","mv_par04",""       ,"","","","",""       ,"","","","",""       ,"","","","","","","","","","","","","","   ","","","",""          })
dbSelectArea("SX1")
For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			FieldPut(j,aRegs[i,j])
		Next
		MsUnlock()
		dbCommit()
	Endif
Next
Pergunte(cPerg,.F.)

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

Processa({|| RunReport() },Titulo,,.t.)
Return nil


Static Function RunReport()
Cabec1 := " CODIGO LOJA CLIENTE                                               ENDEREÇO                                   ESTADO"
Cabec2 := " "
*
*01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
*          1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22

aStru := {}
aAdd(aStru,{"CODCLI","C",06,0})//codigo c9_cliente
aAdd(aStru,{"LOJA"  ,"C",02,0})// loja  c9_loja
aAdd(aStru,{"NOMECLI"  ,"C",30,0})//nome cliente a1_nome
aAdd(aStru,{"ENDERECO" ,"C",50,0})// endereço a1_end
aAdd(aStru,{"ESTADO" ,"C",2,0}) // estoque  a1_est
aAdd(aStru,{"ITEM"   ,"C",3,0}) //C9_ITEM
aAdd(aStru,{"PRODUTO" ,"C",15,0})// CODIGO PRODUTO C9_PRODUTO
aAdd(aStru,{"DESCPROD" ,"C",40,0})// DESCRIÇÃO DO PRODUTO
aAdd(aStru,{"QUANTLIB"  ,"N",9,0})     //C9_QTDLIB
aAdd(aStru,{"PEDIDO"  ,"C",6,0}) //PEDIDO  C9_PEDIDO
aAdd(aStru,{"DATALIB","D",8,0}) //C9_DATALIB
aAdd(aStru,{"LOCAL"  ,"N",10,0}) //B2_LOCALIZ
aAdd(aStru,{"VENDEDOR"  ,"C",20,0})// A3_NOME
aAdd(aStru,{"TRANPNOME"   ,"C",30,0})//A4_NREDUZ
aAdd(aStru,{"FONETRANSP" ,"C",8,0}) //A4_TEL
aAdd(aStru,{"DDDTRANSP" ,"C",3,0})  //A4_DDD
aAdd(aStru,{"FRETE" ,"C",1,0}) //C5_
aAdd(aStru,{"QTDE" ,"N",10,0}) //C6_QTDVEN
aAdd(aStru,{"ESTOQUE" ,"N",10,0}) //ESTOQUE B2_QATU
aAdd(aStru,{"DTENTREGA" ,"D",8,0}) //C6_ENTREG
aAdd(aStru,{"UM" ,"D",8,0}) //C6_UM UNIDADE DE MEDIDCA
aAdd(aStru,{"PREVEN" ,"N",16,0}) //preço de venda


oTemptable := FWTemporaryTable():New( "TRB")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"PRODUTO"} )
oTempTable:Create()

//cArq := CriaTrab(aStru,.T.)
//dbUseArea(.T.,,cArq,"TRB",.T.)
//cInd := CriaTrab(NIL,.F.)
IndRegua("TRB",cInd,"PEDIDO" ,,,"Selecionando Registros...")
IndRegua("TRB",cInd,"PRODUTO" ,,,"Selecionando Registros...")

Set SoftSeek On
cMoeda := "1"

DbSelectArea("SC9")
DbSetOrder(1)
dbSeek(xFilial("SC9")+mv_par01)
WHILE !EOF() .AND. C9_FILIAL == xFilial() ;
	.and. SC9->C9_PRODUTO == mv_par01 .AND. SC9->C9_DATALIB >= dTos(mv_par03) .AND. SC9->C9_DATALIB <= dTos(mv_par04)
	
	
	DbSelectArea("SA1")
	DbSetOrder(2)
	dbSeek(xFilial("SA1")+SC9->C9_CLIENTE)
	
	cNOMECLI	:= SA1->A1_CLIENTE
	cENDERECO	:= SA1->A1_END
	cESTADO		:= SA1->A1_EST
	SA1->(dbSkip())
	
	DbSelectArea("SC6")
	DbSetOrder(2)
	dbSeek(xFilial("SC6")+SC9->C9_PRODUTO)
	nQTDE		:= SC6->C6_QTDVEN
	dDTENTREGA	:= SC6->C6_ENTREG
	cUM			:= SC6->C6_UM
	SC6->(dbSkip())
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	dbSeek(xFilial("SB1")+C9_PRODUTO)
	cDESCPROD	:= SB1->B1_DESC
	SB1->(dbSkip())
	
	DbSelectArea("SB2")
	DbSetOrder(1)
	dbSeek(xFilial("SB2")+C9_PRODUTO)
	cLOCAL		:= SB2->B2_LOCALIZA
	nESTOQUE	:= SB2->B2_QATU
	SB2->(dbSkip())
	
	DbSelectArea("SC5")
	DbSetOrder(1)
	dbSeek(xFilial("SC5")+SC9->C9_PEDIDO)
	cFRETE	:= SC5->C5_TPFRETE
	DbSelectArea("SA4")
	DbSetOrder(1)
	dbSeek(xFilial("SA4")+SC5->C5_TRANSP)
	cTRASNPNOME	:= SA4->A4_NREDUZ
	cDDDTRANSP	:= SA4->A4_DDD
	cFONETRANSP	:= SA4->A4_TEL
	SA4->(dbSkip())
	DbSelectArea("SA3")
	DbSetOrder(1)
	dbSeek(xFilial("SA3")+SC5->C5_VEND1)
	cVENDEDOR	:= SA3->A3_NOME
	SA3->(dbSkip())
	
	SC5->(dbSkip())
	
	RecLock( "TRB" , .T. )
	TRB->CODCLI 	:= SC9->C9_CLIENTE
	TRB->LOJA		:= SC9->C9_LOJA
	TRB->NOMECLI	:= cNOMECLI
	TRB->ENDERECO	:= cENDERECO
	TRB->ESTADO		:= cESTADO
	TRB->ITEM		:= SC9->C9_ITEM
	TRB->PRODUTO	:= SC9->C9_PRODUTO
	TRB->DESCPROD	:= cDESCPROD
	TRB->QUANTLIB	:= SC9->C9_QTDLIB
	TRB->LOCALIZ    := cLOCAL
	TRB->VENDEDOR	:= cVENDEDOR
	TRB->TRASNPNOME	:= cTRASNPNOME
	TRB->FONETRANSP	:= cFONETRANSP
	TRB->DDDTRANSP	:= cDDDTRANSP
	TRB->FRETE		:= cFRETE
	TRB->QTDE		:= nQTDE
	TRB->ESTOQUE	:= nESTOQUE
	TRB->PEDIDO		:= SC9->C9_PEDIDO
	TBR->DATALIB	:= SC9->C9_DATALIB
	TRB->DESCPROD   := cDESCPROD
	TRB->DTENTREGA	:= dDTENTREGA
	TRB->UM			:= cUM
	TRB->PREVEN		:= SC9->C9_PRCVEN
	
	TRB->( MsUnLock() )
	SC9->(dbSkip())
	DbSkip()
End


dbSelectArea("TRB")
ProcRegua(0)
dbgoTop()

Do While !eof()
	IncProc("Imprimindo ...")
	If lAbortPrint
		LI+=1
		@ LI,001 PSAY "*** Cancelado pelo Operador ***"
		lImp := .F.
		exit
	Endif
	
	lImp:=.t.
	if li>55
		LI:=Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo,,.f.)
		LI++
	endif
	
	nPEDID := TRB->PEDIDO
	
	@ LI,001 PSAY TRB->CODCLI//ARQUI->C9_CLIENTE
	@ LI,008 PSAY TRB->LOJA//ARQUI->C9_LOJA
	@ LI,013 PSAY TRB->NOMECLI//ARQUI->(SUBSTR(A1_NOME,1,50))
	@ LI,067 PSAY TRB->ENDERECO// ARQUI->(SUBSTR(A1_END,1,40))
	@ LI,112 PSAY TRB->ESTADO// ARQUI->A1_EST
	LI+=2
	@ LI,01 PSAY "ITEM      CÓDIGO           DESCRIÇÃO                      QUANTIDADE              PEDIDO       DT.LIBERAÇÃO          LOCALIZAÇÃO"
	LI++
	
	nTotitens := 0
	
	WHILE TRB->PEDIDO == nPEDID
		
		LI++
		@ LI,001 PSAY TRB->ITEM //ARQUI->C9_ITEM
		@ LI,012 PSAY TRB->PRODUTO //ARQUI->C9_PRODUTO
		@ LI,028 PSAY TRB->DESCPROD //ARQUI->(SUBSTR(B1_DESC,1,30))
		@ LI,059 PSAY TRB->QUANTLIB PICTURE "@E 999,999"//ARQUI->C9_QTDLIB PICTURE "@E 999,999"
		@ LI,084 PSAY TRB->PEDIDO //ARQUI->C9_PEDIDO
		@ LI,099 PSAY TBR->DATALIB //ARQUI->C9_DATALIB
		@ LI,122 PSAY TRB->LOCALIZ //ARQUI->B2_LOCALIZ
		nTotitens += TBR->DATALIB//C9_QTDLIB * C9_PRCVEN
		
		DBSKIP()
	ENDDO
	LI+=2
	@ LI,001 PSAY "TOTAL PEDIDO S/IMP: "
	@ LI,020 PSAY nTotitens PICTURE "@E 999,999,999.99"
	
Enddo

dbSelectArea("ARQUI")
dbCloseArea()

roda(,,tamanho)

If aReturn[5]==1
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()
Return nil


