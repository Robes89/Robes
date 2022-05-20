#include "rwmake.ch"    

User Function CONSMED()  

SetPrvt("CNATUREZA,TITULO,CDESC1,CDESC2,CDESC3,CSTRING")
SetPrvt("ARETURN,CTEXTO,TAMANHO,LIMITE,NOMEPROG,NTIPO")
SetPrvt("LI,M_PAG,NLASTKEY,NDIASANO,_AORD,CPERG")
SetPrvt("APERG,CBTXT,CBCONT,IMPRIME,WNREL,_CCHAVE")
SetPrvt("NOPC,_NTRB,ASTRU,CARQ,_NCONS3M,_NCONS6M")
SetPrvt("_NCONS12M,_NCONS24M,_NCONS36M,_NSALDOATU,CPRODANT,NSAVREC")
SetPrvt("CCODANT,_CARQIND,TITULO1,CABEC1,CABEC2,_ASALDO")

cNatureza   := ""
titulo      := PADC("Relatorio de Consumo Mensal de Produtos ",74)
cDesc1      := PADC("Este programa tem por objetivo imprimir Relatorio de Consumo de Produtos",71)
cDesc2      := PADC("conforme parametros informados pelo Usuario.",71)
cDesc3      := PADC("Especifico Sidel!!",71)
cString     := "SB1"
aReturn     := {"Zebrado",1,"Administracao",1,2,1,"",1}
cTexto      := ""
tamanho     := "M"
limite      := 80
nomeprog    := "RRO366"
nTipo       := 0
li          := 80
M_PAG       := 01
nLastKey    := 0
nDiasAno    := 365
_aOrd       :={"CODIGO","ABC ULT. 3 MESES","ABC ULT. 6 MESES","ABC ULT. 12 MESES","ABC ULT. 24 MESES","ABC ULT. 36 MESES"}
aPerg      := {}      // Array com perguntas do grupo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o grupo de perguntas esta no arquivo SX1 e carrega pergunte ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cPerg       := "RRO366"

//ajustasx1()

//IF !U_VERSX1(aPerg,cPerg)
//	RETURN   // ABANDONA PROGRAMA, SE USUARIO NAO CONFIRMOU PERGUNTAS
//ENDIF
IF !PERGUNTE(cPerg,.T.)
	RETURN   // ABANDONA PROGRAMA, SE USUARIO NAO CONFIRMOU PERGUNTAS
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt      := Space(10)
cbcont     := 00
imprime    := .T.

wnrel:="RRO366"
wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,_aOrd,.T.,Tamanho,"",.F.)

If nLastKey == 27 .OR. LASTKEY() == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27 .OR. LASTKEY() == 27
	Return
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa os codigos de caracter Comprimido/Normal da impressora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTipo  := 15

RptStatus({|| RptDetail()})// Substituido pelo assistente de conversao do AP5 IDE em 30/08/02 ==>    RptStatus({|| Execute(RptDetail)})
RETURN
// Substituido pelo assistente de conversao do AP5 IDE em 30/08/02 ==>    Function RptDetail
Static Function RptDetail()

// define chave de indixacao do relatorio. Variavel _cchave, e usada na fim, p/ indexar TRB
IF aReturn[8] == 1
	_cChave  := "CODPRO"
ELSEIF aReturn[8] == 2
	_cChave  := "CONS3M"
ELSEIF aReturn[8] == 3
	_cChave  := "CONS6M"
ELSEIF aReturn[8] == 4
	_cChave  := "CONS12M"
ELSEIF aReturn[8] == 5
	_cChave  := "CONS24M"
ELSEIF aReturn[8] == 6
	_cChave  := "CONS36M"
ENDIF

IF aReturn[8] > 1
	IF MSGBOX("Ordena por ABC (decrescente)?","Ordem ABC?","YESNO")
		_cChave := _cChave + "*-1"
	ENDIF
ENDIF


_nTRB := SELECT("TRB")
IF _nTRB > 0
	dbSelectArea("TRB")
	dbCloseArea()
ENDIF

aStru   := {}
AADD(aStru,{ "CodPro"   ,"C",15,0 })
AADD(aStru,{ "_Local"   ,"C", 2,0 })
AADD(aStru,{ "Localiz"  ,"C", 5,0 })
AADD(aStru,{ "Tipo"     ,"C", 2,0 })
AADD(aStru,{ "DescPro"  ,"C",30,0 })
AADD(aStru,{ "CCusto"   ,"C",30,0 })
AADD(aStru,{ "_SALDOATU","N",16,0 })
AADD(aStru,{ "Cons3M"   ,"N",16,0 })
AADD(aStru,{ "Cons6M"   ,"N",16,0 })
AADD(aStru,{ "Cons12M"  ,"N",16,0 })
AADD(aStru,{ "Cons24M"  ,"N",16,0 })
AADD(aStru,{ "Cons36M"  ,"N",16,0 })


oTemptable := FWTemporaryTable():New( "TRB")
oTemptable:SetFields( aStru )
//oTempTable:AddIndex("index1", {"COD"} )
oTempTable:Create()
/*
cArq := CriaTrab(aStru, .T.)
dbUseArea(.T.,,cArq,"TRB",.F.,.F.)
*/

dbSelectArea("SB1")
dbSetOrder(1)
dbGotop()
dbSeek(xFilial("SB1")+MV_PAR04,.T.)

Processa({|| RunCont()},"Processando...") 
Return
Static Function RunCont()
ProcRegua(RecCount())


DO While !Eof()  .AND. SB1->B1_COD <= MV_PAR05
	
	IncProc()
	
	If SB1->B1_LOCPAD < mv_par06 .and. SB1->B1_LOCPAD > mv_par07
		DBSELECTAREA("SB1")
		DBSKIP()
		LOOP
	Endif
	
	_nCons3M     :=0
	_nCons6M     :=0
	_nCons12M    :=0
	_nCons24M    :=0
	_nCons36M    :=0
	_nSaldoAtu   := 0
	_fSaldoAt()  // calcula saldo atual
/*	
	dbSelectArea("SD3")
	dbSetOrder(3)
	IF dbSeek(xFilial("SD3")+SB1->B1_COD,.F.)
		
		cProdAnt := SD3->D3_COD
		nSavRec  := Recno()
		While !Eof() .And. cProdAnt == SD3->D3_COD
			If SD3->D3_EMISSAO < MV_PAR01
				Dbskip()
				Loop
			Endif
			
			IF SD3->D3_CF == "DE6" .AND. ALLTRIM(SD3->D3_CC) == "TRANSFER"
				Dbskip()
				Loop
			ENDIF
			
			// Acumula Saidas
			If Substr(SD3->D3_CF,1,2) == "RE" .Or. SD3->D3_TM == "501"
				If SD3->D3_EMISSAO > mv_par02 - 90   // Dentro dos ultimos 3 meses
					_nCons3m := _nCons3m + SD3->D3_QUANT
				Endif
				If SD3->D3_EMISSAO > MV_PAR02 - 180 // Dentro dos ultimos 6 meses
					_nCons6m := _nCons6m + SD3->D3_QUANT
				Endif
				If SD3->D3_EMISSAO > MV_PAR02 - 365 // Dentro do ultimo ano
					_nCons12m := _nCons12m + SD3->D3_QUANT
				Endif
				If SD3->D3_EMISSAO > MV_PAR02 - 730 // Dentro dos ultimos 2 anos
					_nCons24m := _nCons24m + SD3->D3_QUANT
				Endif
				If SD3->D3_EMISSAO > MV_PAR02 - 1095 // Dentro dos ultimos 3 anos
					_nCons36m := _nCons36m + SD3->D3_QUANT
				Endif
			Endif
			
			// Acumula Entradas
			If Substr(SD3->D3_CF,1,2) == "DE" .Or. SD3->D3_TM == "001"
				If SD3->D3_EMISSAO > mv_par02 - 90   // Dentro dos ultimos 3 meses
					_nCons3m := _nCons3m - SD3->D3_QUANT
				Endif
				If SD3->D3_EMISSAO > MV_PAR02 - 180 // Dentro dos ultimos 6 meses
					_nCons6m := _nCons6m - SD3->D3_QUANT
				Endif
				If SD3->D3_EMISSAO > MV_PAR02 - 365 // Dentro do ultimo ano
					_nCons12m := _nCons12m - SD3->D3_QUANT
				Endif
				If SD3->D3_EMISSAO > MV_PAR02 - 730 // Dentro dos ultimos 2 anos
					_nCons24m := _nCons24m - SD3->D3_QUANT
				Endif
				If SD3->D3_EMISSAO > MV_PAR02 - 1095 // Dentro dos ultimos 3 anos
					_nCons36m := _nCons36m - SD3->D3_QUANT
				Endif
			Endif
			
			dbSkip()
		End
		dbGoto(nSavRec)
	Endif
*/	
	dbSelectArea("SD2")
	dbSetOrder(6)
	dbSeek(xFilial() + SB1->B1_COD,.T.)
	If found()
		cCodAnt := SB1->B1_COD
		While !Eof() .And. cCodAnt == SD2->D2_COD
			If SD2->D2_EMISSAO < MV_PAR01
				Dbskip()
				Loop
			Endif
			dbSelectArea("SF4")
			dbSetOrder(1)
			dbSeek(xFilial()+SD2->D2_TES)
			If SF4->F4_ESTOQUE != "S"
				dbSelectArea("SD2")
				dbSkip()
				Loop
			Endif
			
			If !SD2->D2_TIPO $ "D/B"
				If SD2->D2_EMISSAO > mv_par02 - 90   // Dentro dos ultimos 3 meses
					_nCons3m := _nCons3m + SD2->D2_QUANT
				Endif
				If SD2->D2_EMISSAO > MV_PAR02 - 180 // Dentro dos ultimos 6 meses
					_nCons6m := _nCons6m + SD2->D2_QUANT
				Endif
				If SD2->D2_EMISSAO > MV_PAR02 - 365 // Dentro do ultimo ano
					_nCons12m := _nCons12m + SD2->D2_QUANT
				Endif
				If SD2->D2_EMISSAO > MV_PAR02 - 730 // Dentro dos ultimos 2 anos
					_nCons24m := _nCons24m + SD2->D2_QUANT
				Endif
				If SD2->D2_EMISSAO > MV_PAR02 - 1095 // Dentro dos ultimos 3 anos
					_nCons36m := _nCons36m + SD2->D2_QUANT
				Endif
			Endif
			
			dbSelectArea("SD2")
			dbSkip()
		End
	Endif
	
	if mv_par03 == 2  .and. (_nCons3m+_nCons6m+_nCons12m+_nCons24m+_nCons36m+_nSaldoAtu)==0
		dbSelectArea("SB1")
		dbSkip()
		loop
	endif
	
	dbSelectArea("TRB")
	RecLock("TRB",.T.)
	Replace CodPro    With SB1->B1_COD
	Replace Localiz   With SB1->B1_LOCPAD
	Replace Tipo      With SB1->B1_TIPO
	Replace DescPro   With SB1->B1_DESC
	Replace _SALDOATU With _nSaldoAtu
	Replace Cons3m    With _nCons3m  / 3
	Replace Cons6m    With _nCons6m  / 6
	Replace Cons12m   With _nCons12m / 12
	Replace Cons24m   With _nCons24m / 24
	Replace Cons36m   With _nCons36m / 36
	MsUnlock()
	dbSelectArea("SB1")
	dbSkip()
	
EndDO

dbSelectArea("TRB")

//_cArqInd := criatrab("",.f.)
oTemptable := FWTemporaryTable():New( "TRB")
oTempTable:Create()
IndRegua("TRB",_cArqInd,_cChave,,,"Selecionando Registros ... ")
dbGotop()
titulo1   := "Relatorio de Consumo Medio Mensal de Produtos "

Cabec1 := " Codigo Produto  Tipo Descricao                        SALDO ATUAL  ***************** C O S U M O S   M E D I O S ******************"
Cabec2 := SPACE(55)+IIF(MV_PAR08==2,"              ","SEM EMPENHOS  ")+          "Ult. 3 meses Ult. 6 meses Ultimo ano   Ult. 2 anos  Ult. 3 anos "
//          xxxxxxxxxxxxxxx   xx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                9,999,999.99 9,999,999.99 9,999,999.99 9,999,999.99 9,999,999.99
//         0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012346578901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//         0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        200

DO While !Eof()
	
	If li > 55
		cabec(titulo1,cabec1,cabec2,nomeprog,tamanho,nTipo)
	Endif
	
	@li, 00 PSAY  CodPro
	@li, 19 PSAY  tipo
	@li, 22 PSAY  DescPro
	@li, 55 PSAY  _SALDOATU Picture "9,999,999"
	@li, 68 PSAY  Cons3m    Picture "9,999,999"
	@li, 81 PSAY  Cons6m    Picture "9,999,999"
	@li, 94 PSAY  Cons12m   Picture "9,999,999"
	@li,107 PSAY  Cons24m   Picture "9,999,999"
	@li,120 PSAY  Cons36m   Picture "9,999,999"
	
	li:=li+1
	dbSelectArea("TRB")
	dbSkip()
EndDO

Roda(cbCont,cbTxt,tamanho)

dbSelectArea("TRB")
dbCloseArea()
Ferase(cArq+".DBF")
Ferase(_cArqInd+ORDBAGEXT())

Set Device To Screen
If aReturn[5] == 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
Endif
MS_FLUSH()

Return

Static Function _fSaldoAt()

DBSELECTAREA("SB2")
DBSETORDER(1)
DBGOTOP()
IF DBSEEK(XFILIAL("SB2")+SB1->B1_COD,.F.)
	DO WHILE !EOF() .AND. SB1->B1_COD == SB2->B2_COD
		IF SB2->B2_LOCAL < MV_PAR06 .OR. SB2->B2_LOCAL > MV_PAR07
			DBSKIP()
			LOOP
		ENDIF
		IF MV_PAR08 == 1
			_aSaldo := CALCEST(SB2->B2_COD,SB2->B2_LOCAL,dDataBase+1) // saldo sem considerar empenhos e reservas
			_nSaldoAtu := _nSaldoAtu + _aSaldo[1]
		ELSE
			_nSaldoAtu := _nSaldoAtu + SALDOSB2()
		ENDIF
		DBSKIP()
	ENDDO
ENDIF

Return

Static Function AjustaSX1()
aPerg    := {}

Aadd( aPerg , { "DATA DE             ?" , "D" , 08 , "   "})
Aadd( aPerg , { "DATA ATE            ?" , "D" , 08 , "   "})
Aadd( aPerg , { "CONSIDERA QTDE ZERO ?" , "N" , 01 , "   "})
Aadd( aPerg , { "DO PRODUTO          ?" , "C" , 15 , "SB1"})
Aadd( aPerg , { "ATE PRODUTO         ?" , "C" , 15 , "SB1"})
Aadd( aPerg , { "DO ALMOXARIFADO     ?" , "C" , 02 , "   "})
Aadd( aPerg , { "ATE ALMOXARIFADO    ?" , "C" , 02 , "   "})
Aadd( aPerg , { "Empenhos no Saldo   ?" , "N" , 01 , "   "})

For nXX := 1 to Len( aPerg )
	If !SX1->( DbSeek( Padr(cPerg,10) + StrZero( nXX , 2 ) ) )
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
		If nxx == 8
			SX1->X1_GSC   := "C"
			SX1->X1_DEF01 := "Nao Considera"
			SX1->X1_DEF02 := "Considera"
		Endif
		If nxx == 3 //.or. nxx == 8 .OR. nxx == 10 .OR. nxx == 11
			SX1->X1_GSC   := "C"
			SX1->X1_DEF01 := "Sim"
			SX1->X1_DEF02 := "Nao"
		Endif
	EndIf
Next nXX
Return Nil
