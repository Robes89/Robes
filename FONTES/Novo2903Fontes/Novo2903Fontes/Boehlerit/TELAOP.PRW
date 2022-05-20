#INCLUDE "PROTHEUS.CH"          

// Rotina		: TELAOP
// Descrição	: Digitação do historico OP
// Data			: 23/05/05
// Autor        : Daniel Gondran
/*
User Function TELAOP()

cAlias := "SC2"
nReg   := SC2->(Recno())
nOpc   := 1

Public  pAltera
Private lLogMov    := GetMV("MV_IMPMOV")
PRIVATE cCusMed := GetMv("MV_CUSMED")
PRIVATE bCols :={|x,y|aCols[x][y]}
PRIVATE nPosCod,nPosLocal,nPosLote,nPosLotCTL,nPosDValid,nPosQuant,nPosCusto1,nPosUm
PRIVATE nPosConta,nPosCC,nPosGrupo,nPosTipo,nPosSegUm,nPosQtSegUm,nPosDesc,nPosOp,nPosTRT
PRIVATE nPosLocali,nPosNumSer,nPos241Loc,nPos241Qtd
PRIVATE nPosCodVei := 0
PRIVATE nPosViagem := 0

Private aAutoCab  := {} , aAutoItens :={}
Private cFunc     := Nil
Private aButtons   := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Esta variavel indica se utiliza segunda unidade de medida    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE lUsaSegUm

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Estas variaveis indicam para as funcoes de validacao qual    ³
//³ programa as esta' chamando, no caso igual ao do MATA240      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE l240 :=.F.,l250:=.F.,l241 :=.T.,l242:=.F.,l261 := .F.,l185:=.F.
PRIVATE cCadastro:="Historico das Ordens de Producao"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

PRIVATE lCodBarra := .F.
PRIVATE aRotina := { {"Pesquisar","AxPesqui"  , 0 , 1},;		//Pesquisar
	{"Visualizar","U_vis", 0 , 2},;		//Visualizar
	{"Alterar","U_Inc", 0 , 3}}      		//Alterar



dbSelectArea("SC2")
dbSetOrder(1)
mBrowse( 6, 1,22,75,"SC2")
Set Key VK_F12 To

RETURN NIL           

User Function Vis
	paltera := 2
	U_Inclui0()
Return

User Function Inc
	paltera := 6
	U_Inclui0()
Return


User Function Inclui0()

SetPrvt("CALIAS,COPCAO,INCLUI,CPECA,CMAQUINA,CPECAFINA")
SetPrvt("CORDPROD,NQTDEETIQ,NQTDESEQU,NNUMELINH,NLASTKEY,CARTSECU")
SetPrvt("CTITULO,CSTRING,CDESC1,CDESC2,CDESC3,ALINHA")
SetPrvt("LEND,AR,NUSADO,AHEADER,ACGD,CLINHAOK")
SetPrvt("CTUDOOK,ACOLS,_NI,AC,LFIMEXEC,LTUDOOK")
SetPrvt("LVALIDAR,LRETMOD2,NPOSLOTE,NPOSOPRO,NPOSRECU,NPOSETIQ")
SetPrvt("NQTDEPECA,NCONTLINH,")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas pelo programa                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAlias:="SC2"
cOpcao := "ALTERAR"
Inclui := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis dos Gets de Cabecalho                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cOP       := SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN
cCliente  := "      "
cLoja     := "  "
cEmissao  := CTOD("  /  /  ")
cNome	  := Space(20)
nNumeLinh := nLastKey := 0
cTitulo   := "Historico das Ordens de Producao"

cString   :="SZ4"
cDesc1    := cDesc2:= cDesc3:= ""
aLinha    := { }
lEnd      := .f.

While .T.
	If nLastKey == 27
		Return
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Titulo da Janela                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aR:={}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Array com descricao dos campos do Rodape do Modelo 2         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	// aR[n,1] = Nome da Variavel Ex.:"cCliente"
	// aR[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
	// aR[n,3] = Titulo do Campo
	// aR[n,4] = Picture
	// aR[n,5] = Validacao
	// aR[n,6] = F3
	// aR[n,7] = Se campo e' editavel .t. se nao .f.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montando aHeader                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nUsado:= 0
	dbSelectArea("SX3")
	dbSetOrder(2)
	aHeader:={}
	axcampos := {"Z4_PRODUTO","Z4_CODLMT","Z4_QUANT","Z4_ENTREGA","Z4_HIST"}
	For kkk := 1 to Len(axcampos)
		SX3->(dbSeek(axcampos[kkk]))
		nUsado ++
		Aadd(aHeader, {TRIM(SX3->x3_titulo), SX3->x3_campo, SX3->x3_picture,;
		SX3->x3_tamanho, SX3->x3_decimal, Iif(Trim(SX3->X3_CAMPO)=="Z4_PRODUTO",;
		"ExistCpo('SB1',M->Z4_PRODUTO)",""),;
		SX3->x3_usado, SX3->x3_tipo, SX3->x3_arquivo, SX3->x3_context})
	Next
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montando aCols                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAlias)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Array com coordenadas da GetDados no modelo2                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCGD:={50,5,118,315}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validacoes na GetDados da Modelo 2                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cLinhaOk := "U_VALLI()"
	cTudoOk  := "AllwaysTrue()"
	
	aCols := {}
	Aadd(aCols,Array(nUsado+1))
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	For _ni:=1 to nUsado
		aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
	Next
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Array com descricao dos campos do Cabecalho do Modelo 2      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aC   := {}
	aAdd(aC,{"cOP"      ,{ 20,010}, "OP:"              ,"@!","ExistCpo('SC2').and.U_BUSCA()",,.T.})
	aAdd(aC,{"cCliente" ,{ 20,150}, "Cliente"          ,"@!",,,.F.})
	aAdd(aC,{"cLoja"    ,{ 20,210}, "Loja"             ,"@!",,,.F.})
	aAdd(aC,{"cEmissao" ,{ 35,010}, "Emissao"          ,"@!",,,.F.})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chamada da Modelo2                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAlias)
	lFimExec := .F.
	lTudoOk  := .T.
	lValidar := .T.
	lRetMod2 := .T.
	axcampos := {"Z4_PRODUTO","Z4_CODLMT","Z4_QUANT","Z4_ENTREGA","Z4_HIST"}
	
//	While .T.
		lRetMod2 := Modelo2(cTitulo,aC,aR,aCGD,pAltera,cLinhaOk,cTudoOk,axcampos)
//		If lRetMod2 .and. !lTudoOk
//			Loop
//		Endif
//		Exit
//	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetMod2.and.lTudoOk
		Grava()
	EndIf
	Return
End
Return


User Function Busca()
	dbSelectArea("SZ4")
	dbSetOrder(1)
	If dbSeek(xFilial("SZ4") + cOP)
		cCliente := SZ4->Z4_CLIENTE
    	cLoja    := SZ4->Z4_LOJA
	    cEmissao := SZ4->Z4_EMISSAO
		dbSelectArea("SZ4")
		dbSetOrder(1)
		dbSeek(xFilial("SZ4") + cOP)
		do While !Eof() .and. Z4_OP == cOp
			aCols[len(aCols),1]  := SZ4->Z4_PRODUTO 
			aCols[len(aCols),2]  := SZ4->Z4_CODLMT
			aCols[len(aCols),3]  := SZ4->Z4_QUANT
			aCols[len(aCols),4]  := SZ4->Z4_ENTREGA
			aCols[len(aCols),5]  := SZ4->Z4_HIST
			aCols[len(aCols),6] := .F.
			dbSkip()
			If Z4_OP == cOP
				Aadd(aCols,Array(6))
			Endif
		Enddo 
		n := 1
		_oGetD := CallMod2Obj()
		_oGetD:oBrowse:Refresh()
	Else
		dbSelectArea("SC2")
		dbSetOrder(1)
		If dbSeek(xFilial("SC2") + cOP)
			dbSelectArea("SC5")
			dbSetOrder(1)
			If dbSeek(xFilial("SC5") + Left(cOp,6))
				cCliente := SC5->C5_CLIENTE
		    	cLoja    := SC5->C5_LOJACLI
			    cEmissao := SC2->C2_EMISSAO
				dbSelectArea("SC2")
				dbSetOrder(1)
				dbSeek(xFilial("SC2") + cOp)
				do While !Eof() .and. C2_NUM + C2_ITEM + C2_SEQUEN == cOp
					aCols[len(aCols),1]  := SC2->C2_PRODUTO 
					aCols[len(aCols),2]  := SC2->C2_CODLMT
					aCols[len(aCols),3]  := SC2->C2_QUANT
					aCols[len(aCols),4]  := SC2->C2_DATPRF 
					aCols[len(aCols),6] := .F.
					dbSkip()
					If C2_NUM == cOP
						Aadd(aCols,Array(6))
					Endif
				Enddo 
				n := 1
				_oGetD := CallMod2Obj()
				_oGetD:oBrowse:Refresh()
			Else
				Alert("OP não tem pedido associado")
				Return(.F.)		
			Endif
	    Else
			Alert("OP não encontrada")
			Return(.F.)		
		Endif
	Endif
Return		 

Static Function Grava()
    dbSelectArea("SZ4")
    dbSetOrder(1)
	For kkk := 1 To LEN(aCols)
		lAchou := dbSeek(xFilial("SZ4") + cOp)
		If !aCols[kkk,6]
			RecLock( "SZ4" , !lAchou )
			SZ4->Z4_FILIAL	:= xFilial( "SZ4" )
			SZ4->Z4_OP		:= cOp
			SZ4->Z4_CLIENTE	:= ccliente
			SZ4->Z4_LOJA	:= cLoja
			SZ4->Z4_EMISSAO := cEmissao
			SZ4->Z4_PRODUTO := aCols[kkk,1]
			SZ4->Z4_CODLMT  := aCols[kkk,2]			
			SZ4->Z4_QUANT   := aCols[kkk,3]  
			SZ4->Z4_ENTREGA := aCols[kkk,4]  
			SZ4->Z4_HIST    := aCols[kkk,5]			
			SZ4->( MsUnLock() )
		Else
			RecLock( "SZ4" , .F.)
			dbDelete()
			msUnLock()
		Endif
		dbSelectArea("SZ4")
	Next
Return

User Function ValLi()
Return(.T.)
*/