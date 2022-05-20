#INCLUDE "PROTHEUS.CH"          

// Rotina		: TELAOP
// DescriГЦo	: DigitaГЦo do historico OP
// Data			: 23/05/05
// Autor        : Daniel Gondran

User Function TELAOP()

cAlias := "SC2"
nReg   := SC2->(Recno())
nOpc   := 1

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

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Esta variavel indica se utiliza segunda unidade de medida    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE lUsaSegUm

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Estas variaveis indicam para as funcoes de validacao qual    Ё
//Ё programa as esta' chamando, no caso igual ao do MATA240      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE l240 :=.F.,l250:=.F.,l241 :=.T.,l242:=.F.,l261 := .F.,l185:=.F.
PRIVATE cCadastro:="Historico das Ordens de Producao"

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define Array contendo as Rotinas a executar do programa      Ё
//Ё ----------- Elementos contidos por dimensao ------------     Ё
//Ё 1. Nome a aparecer no cabecalho                              Ё
//Ё 2. Nome da Rotina associada                                  Ё
//Ё 3. Usado pela rotina                                         Ё
//Ё 4. Tipo de Transa┤└o a ser efetuada                          Ё
//Ё    1 - Pesquisa e Posiciona em um Banco de Dados             Ё
//Ё    2 - Simplesmente Mostra os Campos                         Ё
//Ё    3 - Inclui registros no Bancos de Dados                   Ё
//Ё    4 - Altera o registro corrente                            Ё
//Ё    5 - Remove o registro corrente do Banco de Dados          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

PRIVATE lCodBarra := .F.
PRIVATE aRotina := { {"Pesquisar","AxPesqui"  , 0 , 1},;		//Pesquisar
	{"Visualizar","A241Visual", 0 , 2},;		//Visualizar
	{"Incluir","U_Inclui0", 0 , 3},;      		//Incluir
	{"Estornar","U_xEstorna", 0, 6}}				//Estornar


dbSelectArea("SD3")
dbSetOrder(1)
mBrowse( 6, 1,22,75,"SD3")
Set Key VK_F12 To

RETURN NIL

User Function Inclui0()

SetPrvt("CALIAS,COPCAO,INCLUI,CPECA,CMAQUINA,CPECAFINA")
SetPrvt("CORDPROD,NQTDEETIQ,NQTDESEQU,NNUMELINH,NLASTKEY,CARTSECU")
SetPrvt("CTITULO,CSTRING,CDESC1,CDESC2,CDESC3,ALINHA")
SetPrvt("LEND,AR,NUSADO,AHEADER,ACGD,CLINHAOK")
SetPrvt("CTUDOOK,ACOLS,_NI,AC,LFIMEXEC,LTUDOOK")
SetPrvt("LVALIDAR,LRETMOD2,NPOSLOTE,NPOSOPRO,NPOSRECU,NPOSETIQ")
SetPrvt("NQTDEPECA,NCONTLINH,")

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis utilizadas pelo programa                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cAlias:="SD3"
cOpcao := "ALTERAR"
Inclui := .T.

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis dos Gets de Cabecalho                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dDesv 	  := GETMV("MV_ULSEM")
cDoc 	  := "      "
cTm  	  := "101"
cCC  	  := Space(9)
dEmissao  := ddatabase
nNumeLinh := nLastKey := 0
cArtSecu  := Space(5)
cTitulo   := "InventАrio Local 99"

cString   :="SD3"
cDesc1    := cDesc2:= cDesc3:= ""
aLinha    := { }
lEnd      := .f.

While .T.
	If nLastKey == 27
		Return
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Titulo da Janela                                             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aR:={}
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Array com descricao dos campos do Rodape do Modelo 2         Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	
	// aR[n,1] = Nome da Variavel Ex.:"cCliente"
	// aR[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
	// aR[n,3] = Titulo do Campo
	// aR[n,4] = Picture
	// aR[n,5] = Validacao
	// aR[n,6] = F3
	// aR[n,7] = Se campo e' editavel .t. se nao .f.
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Montando aHeader                                             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nUsado:= 0
	dbSelectArea("SX3")
	dbSetOrder(1)
	SX3->(dbSeek("SD3"))
	aHeader:={}
	While ! Eof() .And. SX3->x3_arquivo == "SD3"
		If Alltrim(SX3->x3_campo) $ "D3_COD,D3_QUANT"
			nUsado := nUsado + 1
			Aadd(aHeader, {TRIM(SX3->x3_titulo), SX3->x3_campo, SX3->x3_picture,;
			SX3->x3_tamanho, SX3->x3_decimal, "AllwaysTrue()",;
			SX3->x3_usado, SX3->x3_tipo, SX3->x3_arquivo, SX3->x3_context})
		Endif
		dbSelectArea("SX3")
		dbSkip()
	End
	SX3->(dbSeek("SD3"))
	While ! Eof() .And. SX3->x3_arquivo == "SD3"
		If Alltrim(SX3->x3_campo) $ "D3_LOCAL"
			nUsado := nUsado + 1
			Aadd(aHeader, {TRIM(SX3->x3_titulo), SX3->x3_campo, SX3->x3_picture,;
			SX3->x3_tamanho, SX3->x3_decimal, "AllwaysTrue()",;
			SX3->x3_usado, SX3->x3_tipo, SX3->x3_arquivo, SX3->x3_context})
		Endif
		dbSelectArea("SX3")
		dbSkip()
	End
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Montando aCols                                               Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea(cAlias)
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Array com coordenadas da GetDados no modelo2                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aCGD:={50,5,118,315}
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Validacoes na GetDados da Modelo 2                           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cLinhaOk := "AllwaysTrue()"
	cTudoOk  := "U_Verifcc()"
	
	aCols := {}
	Aadd(aCols,Array(nUsado+1))
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	For _ni:=1 to nUsado
		aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
	Next
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Array com descricao dos campos do Cabecalho do Modelo 2      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aC := {}
	cTM := "101"
	aAdd(aC,{"cDoc"     ,{20, 10}, "Numero Documento" ,"@!","U_Valdoc()",,.T.})
	aAdd(aC,{"cTM"      ,{20,100}, "TM"               ,"@!",,,.F.})
	aAdd(aC,{"cCC"      ,{20,150}, "Centro de Custo"  ,"@!","Existcpo('SI3')","SI3",.T.})
	aAdd(aC,{"dEmissao" ,{20,250}, "Emissao"          ,"@D","U_Valdata()",,.T.})
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Chamada da Modelo2                                           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea(cAlias)
	lFimExec := .F.
	lTudoOk  := .T.
	lValidar := .T.
	lRetMod2 := .T.
	
	While .T.
		lRetMod2 := Modelo2(cTitulo,aC,aR,aCGD,3,cLinhaOk,cTudoOk,{"D3_COD","D3_QUANT"})
		If lRetMod2 .and. !lTudoOk
			Loop
		Endif
		Exit
	End
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Grava                                                        Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lRetMod2.and.lTudoOk
		Grava()
	EndIf
	Return
End
Return


User Function Verifcc()
	If Empty(cCC)
		Alert ("Centro de Custo nЦo pode estar em branco")
		Return (.F.)
	Endif
Return (.T.)


User Function Valdata()
	If Empty(dEmissao)
		Alert ("Data de emissЦo nЦo pode estar em branco")
		Return (.F.)
	ElseIf dEmissao <= dDesv
		Alert ("Data de emissЦo nЦo pode ser menor que a data do Зltimo desvio")
		Return (.F.)
	Endif
Return (.T.)

User Function ValDoc()
	If Empty(cDoc)
		Alert ("Documento nЦo pode estar em branco")
		Return (.F.)
	Else             
		dbSelectArea("SD3")
		dbSetOrder(2)
		If dbSeek(xFilial("SD3") + cDoc)
			lTudoEsto := .T.
			do While !Eof() .and. D3_FILIAL == xFilial() .and. D3_DOC == cDoc
			 	If D3_ESTORNO <> "S"	
			 		lTudoEsto := .F.
			 		Exit
			 	Endif
			 	dbSkip()
			Enddo
			If !lTudoEsto	
		 		Alert ("Documento jА digitado")
		  		Return (.F.)
		  	Endif
		Endif
	Endif
Return (.T.)


Static Function Grava()

For kkk := 1 To LEN(aCols)

	If !aCols[kkk,4]
	
		cCod    := aCols[kkk,1]
		nQuant	:= aCols[kkk,2]
		cLocal	:= aCols[kkk,3]
	
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1") + cCod)
	
		dbSelectArea("SB2")
		dbSetOrder(1)
		dbSeek(xFilial("SB2") + cCod + cLocal)
		
		RecLock( "SD3" , .T. )
		SD3->D3_FILIAL	:= xFilial( "SD3" )
		SD3->D3_TM		:= cTM
		SD3->D3_COD		:= cCod
		SD3->D3_CC		:= cCC
		SD3->D3_UM		:= SB1->B1_UM
		SD3->D3_QUANT	:= nQuant
		SD3->D3_CF		:= "DE3"
		SD3->D3_CONTA	:= SB1->B1_CONTA
		SD3->D3_GRUPO   := SB1->B1_GRUPO
		SD3->D3_LOCAL	:= cLocal
		SD3->D3_DOC		:= cDoc
		SD3->D3_EMISSAO	:= dEmissao
		SD3->D3_NUMSEQ	:= ProxNum()
		SD3->D3_TIPO	:= SB1->B1_TIPO
		SD3->D3_USUARIO	:= SubStr( cUsuario , 7 , 15 )
		SD3->D3_CHAVE	:= "E0"
		SD3->D3_CUSTO1	:= nQuant * SB2->B2_CM1
		SD3->D3_CUSTO2	:= nQuant * SB2->B2_CM2
		SD3->D3_CUSTO3	:= nQuant * SB2->B2_CM3
		SD3->D3_CUSTO4	:= nQuant * SB2->B2_CM4
		SD3->D3_CUSTO5	:= nQuant * SB2->B2_CM5
		SD3->( MsUnLock() )
				
		dbSelectArea("SB2")
		dbSetOrder(1)
		dbSeek(xFilial("SB2") + cCod + "99")
		RecLock("SB2",.F.)
		nNovQuant  := SB2->B2_QATU - nQuant
		SB2->B2_QATU	:= nNovQuant
		SB2->B2_VATU1   := nNovQuant * SB2->B2_CM1
		SB2->B2_VATU2   := nNovQuant * SB2->B2_CM2
		SB2->B2_VATU3   := nNovQuant * SB2->B2_CM3
		SB2->B2_VATU4   := nNovQuant * SB2->B2_CM4
		SB2->B2_VATU5   := nNovQuant * SB2->B2_CM5
		SB2->( MsUnLock() )
			
		dbSeek(xFilial("SB2") + cCod + cLocal)
		RecLock("SB2",.F.)
		nNovQuant  := SB2->B2_QATU + nQuant
		SB2->B2_QATU	:= nNovQuant
		SB2->B2_VATU1   := nNovQuant * SB2->B2_CM1
		SB2->B2_VATU2   := nNovQuant * SB2->B2_CM2
		SB2->B2_VATU3   := nNovQuant * SB2->B2_CM3
		SB2->B2_VATU4   := nNovQuant * SB2->B2_CM4
		SB2->B2_VATU5   := nNovQuant * SB2->B2_CM5
		SB2->( MsUnLock() )
	Endif
Next
Return






User Function xEstorna()

LVar01:=1;nLinhas:=0
GetList:={}; nCntItem := 1;nCnt := 0
dDataFec := GetMV("MV_ULMES")
aRecnos:={}
nPosEstr:=0
aAlter:={}
lAbandona:=.F.; zi:=0
cCampo:=""; i:=0
cNumSeq  := ""
aAreaSD3 := {}

aObjects :={}; aPosObj  :={}
aSize    :=MsAdvSize()
aInfo    :={aSize[1],aSize[2],aSize[3],aSize[4],3,3}
PRIVATE aRatVei    := {}
PRIVATE aRatFro    := {}
PRIVATE aArraySDG  := {}
aButtons  := IF(Type("aButtons") == "U", {}, aButtons)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Campos que podem ser alterados na GetDados                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
AADD(aAlter,"D3_ESTORNO")

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se existe algum dado no arquivo                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea( cAlias )
dbSetOrder(1)
If RecCount() == 0
	Return .T.
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se esta' na filial correta                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If xFilial() != D3_FILIAL
	Help(" ",1,"A000FI")
	Return .T.
Endif

If Subs(D3_CF,1,2) == "PR" .Or. Subs(D3_CF,3,1)$"12457"
	Help(" ",1,"A240NAO")
	Return
EndIf

If D3_ESTORNO == "S" .Or. D3_CF == "499" .Or. D3_CF == "999"
	Help(" ",1,"A240ESTORN")
	Return
EndIf

If GetMV("MV_CQ") == D3_LOCAL
	Help(" ",1,"A240LOCCQ")
	Return
Else
	cNumSeq:=SD3->D3_NUMSEQ
	cProduto:=SD3->D3_COD
	aAreaSD3:=GetArea()
	dbSetOrder(4)
	If dbSeek(xFilial()+cNumSeq)
		While !EoF() .And. xFilial()+cNumSeq == D3_FILIAL+D3_NUMSEQ
			If (nReg # Recno()) .And. (GetMV("MV_CQ") == D3_LOCAL) .And. (cProduto == SD3->D3_COD)
				Help(" ",1,"A240LOCCQ")
				RestArea(aAreaSD3)
				Return
			EndIf
			dbSkip()
		End
	EndIf
	RestArea(aAreaSD3)
EndIf

//здддддддддддддддддддддддддддддддддддд©
//Ё Verifica se a OP ja' foi encerrada Ё
//юдддддддддддддддддддддддддддддддддддды
dbSelectArea("SC2")
dbSeek(xFilial()+SD3->D3_OP)
If !EMPTY(C2_DATRF)
	Help(" ",1,"MA240OPENC")
	dbSelectArea("SD3")
	Return
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verificar data do ultimo fechamento em SX6.                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If dDataFec >= SD3->D3_EMISSAO
	Help ( " ", 1, "FECHTO" )
	Return
EndIf

dbSelectArea(cAlias)
PRIVATE	nOpcA ,cDocumento := D3_DOC ,dA241Data := D3_EMISSAO,;
	cCC := D3_CC, cTM := D3_tm

If Empty(cDocumento)
	Return .T.
EndIf

nSavRec := RecNo()
dbSetOrder(2)
dbSeek( xFilial()+cDocumento )

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta a entrada de dados do arquivo                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Private aHeader[0],Continua,nUsado:=0

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Montagem do aHeader                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek( cAlias )
cArquivo := SX3->x3_arquivo
While !EOF() .And. (cArquivo == cAlias)
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. !Trim(x3_campo) $ "D3_DOC/D3_CC/D3_TM/D3_PERDA/D3_EMISSAO/D3_PARCTOT"
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal, x3_valid,;
			x3_usado, x3_tipo, x3_arquivo, x3_context } )
	Endif
	dbSkip()
End
For nx = 1 To Len(aHeader)
	Do Case
	Case Trim(aHeader[nx][2]) == "D3_COD"
		nPosCod:=nX
	Case Trim(aHeader[nx][2]) == "D3_LOCAL"
		nPosLocal:=nX
	Case Trim(aHeader[nx][2]) == "D3_NUMLOTE"
		nPosLote:=nX
	Case Trim(aHeader[nx][2]) == "D3_LOTECTL"
		nPosLotCTL:=nX
	Case Trim(aHeader[nx][2]) == "D3_DTVALID"
		nPosDValid:=nX
	Case Trim(aHeader[nx][2]) == "D3_QUANT"
		nPosQuant:=nX
	Case Trim(aHeader[nx][2]) == "D3_SEGUM"
		nPosSegUm:=nX
	Case Trim(aHeader[nx][2]) == "D3_QTSEGUM"
		nPosQtSegUm:=nX
	Case Trim(aHeader[nx][2]) == "D3_CUSTO1"
		nPosCusto1:=nX
	Case Trim(aHeader[nx][2]) == "D3_UM"
		nPosUm:=nX
	Case Trim(aHeader[nx][2]) == "D3_CONTA"
		nPosConta:=nX
	Case Trim(aHeader[nx][2]) == "D3_GRUPO"
		nPosGrupo:=nX
	Case Trim(aHeader[nx][2]) == "D3_TIPO"
		nPosTipo:=nX
	Case Trim(aHeader[nx][2]) == "D3_OP"
		nPosOp:=nX
	Case Trim(aHeader[nx][2]) == "D3_TRT"
		nPosTrt:=nX
	Case Trim(aHeader[nx][2]) == "D3_DESCRI"
		nPosDesc:=nX
	Case Trim(aHeader[nx][2]) == "D3_ESTORNO"
		nPosEstr:=NX
	Case Trim(aHeader[nx][2]) == "D3_LOCALIZ"
		nPosLocali:=nX
	Case Trim(aHeader[nx][2]) == "D3_NUMSERI"
		nPosNumSer:=nX                        
	Case Trim(aHeader[nx][2]) == "D3_CODVEI"
		nPosCodVei:=nX
	Case Trim(aHeader[nx][2]) == "D3_VIAGEM"
		nPosViagem:=nX				
	EndCase
Next nx

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Validacao do uso de alguns campos obrigatorios               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

PRIVATE aCOLS:={}

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Montagem do aCols                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SB1->(dbSetorder(1))
dbSelectArea(cAlias)
nCnt := 0
lEmBranco:=.F.
While !EOF() .And. D3_FILIAL+D3_DOC == xFilial()+cDocumento
	If Empty(D3_DOC)
		lEmBranco:=.T.
		dbSkip()
		Loop
	Endif
	If D3_TM # cTm .And. Empty(D3_ESTORNO)
		dbSkip()
		Loop
	EndIf
	If D3_ESTORNO == "S"
		dbSkip()
		Loop
	Endif
	AADD(aRecnos,Recno())
	nCnt++
	AADD(aCols,Array(Len(aHeader)))
	For i:=1 to Len(aHeader)
		cCampo:=Alltrim(aHeader[i,2])
		If aHeader[i,10] # "V" .And. cCampo == "D3_ESTORNO"
			aCOLS[Len(aCols)][i] := "S"
		ElseIf aHeader[i,10] # "V" .And. cCampo != "D3_ESTORNO"
			aCOLS[Len(aCols)][i] := FieldGet(FieldPos(cCampo))
		ElseIf aHeader[i,10] == "V"
			aCOLS[Len(aCols)][i] := CriaVar(cCampo)
		Endif
	Next i
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Preenche descricao do produto no campo virtual       Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If ValType(nPosDesc) == "N" .And. nPosDesc > 0
		If SB1->(dbSeek(xFilial("SB1")+aCols[Len(aCols),nPosCod]))
			aCols[Len(aCols),nPosDesc]:= SB1->B1_DESC
		EndIf          		
	EndIf           
	
	dbSelectArea(cAlias)
	dbSkip()
End

//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Caso nao ache nenhum item , abandona rotina.         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nCnt == 0
	dbGoTo( nSavRec )
	dbSetOrder(1)
	Return .T.
Endif


AADD(aObjects,{100,020,.T.,.F.,.F.})
AADD(aObjects,{100,100,.T.,.T.,.F.})

aPosObj:=MsObjSize(aInfo,aObjects)

nOpca:=0
DEFINE MSDIALOG oDlg TITLE OemToAnsi("Estorno Mov. 101") OF oMainWnd PIXEL FROM aSize[7],0 TO aSize[6],aSize[5] 
@ 1.5,.7	SAY OemToAnsi("Numero Documento") //"Nёmero Documento"
@ 1.5,7 	MSGET cDocumento When .F.
@ 1.5,6+Len(cDocumento)   SAY OemToAnsi("TM") //"TM"
@ 1.5,7.5+Len(cDocumento)  	MSGET cTm When .F.
@ 1.5,11+Len(cDocumento)   SAY OemToAnsi("Centro de Custo") //"Centro de Custo"
@ 1.5,16+Len(cDocumento)  	MSGET cCC When .F.
@ 1.5,23+Len(cDocumento)   SAY OemToAnsi("Emisao") //"Emissao"
@ 1.5,26+Len(cDocumento)   MSGET dA241Data When .F.
oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"AllwaysTrue","AllwaysTrue","",.F.,aAlter)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=2,If(MTA241ESTOk(),oDlg:End(),nOpca:=0)},{||oDlg:End(),nOpca:=0},,aButtons)

If nOpcA == 2
	Begin Transaction
		nCnt := 0
		dbSelectArea(cAlias)
		For nx = 1 to Len(aRecnos)
			If nPosEstr > 0
				If aCols[nx,nPosEstr] == "S"
					dbGoTo(aRecnos[nx])
					If A240EstrOk(SD3->D3_COD,SD3->D3_LOCAL,SD3->D3_LOTECTL,SD3->D3_NUMLOTE,SD3->D3_NUMSEQ,SD3->D3_DOC,SD3->D3_QUANT)
						RecLock(cAlias,.F.)
						//здддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Envia p/func. de atualizacoes (SD3,SB2,SB3,SC2,..) Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддды
						a240DesAtu()
						dbSelectArea(cAlias)
					EndIf
				EndIf
			Else
				Help("",1,"D3_ESTORNO")
				Exit
			EndIf
		Next nx

	End Transaction
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Restaura a integridade da janela                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea(cAlias)
dbGoto(nReg)

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©╠╠
╠╠Ё                                                                       Ё╠╠
╠╠Ё                                                                       Ё╠╠
╠╠Ё                   ROTINAS DE CRITICA DE CAMPOS                        Ё╠╠
╠╠Ё                                                                       Ё╠╠
╠╠Ё                                                                       Ё╠╠
╠╠юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    Ёa241TudOk Ё Autor Ё Eveli Morasco         Ё Data Ё          Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Critica se a nota toda esta' Ok                            Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ ExpC1 = Objeto a ser verificado.                           Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё Mata241                                                    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function a241TudoOk(o)
Static lExistMT241OK := NIL
Local lRetorno:=.T.
If Empty(cTM)
	Help(" ",1,"D3_TM")
	lRetorno := .F.
Else
	If ! A241Check()
		lRetorno := .F.
	Else
		If lExistMT241OK == NIL
			lExistMT241OK:=ExistBlock("MT241TOK")
		EndIf
		If lExistMT241OK
			lRetorno := ExecBlock("MT241TOK",.F.,.F.)
			If ValType(lRetorno) # "L"
				lRetorno:=.T.
			EndIf
		EndIf
	EndIf
Endif
Return lRetorno

Static Function MTA241ESTOK()
Local lRet := .T.
If lRet .And. ExistBlock('MT241EXT')
	lRet := ExecBlock('MT241EXT', .F., .F.)
Endif
If ValType(lRet) # "L"
	lRet := .T.
EndIf
If lRet
	lRet := MTA241OK()
EndIf
Return lRet

Static Function MTA241OK()
Return (MsgYesNo("Confirma o estorno da movimentaГЦo?","AtenГЦo")) 
