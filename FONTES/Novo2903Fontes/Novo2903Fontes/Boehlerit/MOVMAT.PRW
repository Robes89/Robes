
#INCLUDE "rwmake.ch"

// Rotina		: MOVMAT
// Descrição	: Movimentação de Material
// Data			: 12/01/05
// Autor        : Daniel Gondran

User Function MOVMAT()

// mv_par01 - Do  Produto
// mv_par02 - Até Produto
// mv_par03 - Data Inicial
// mv_par04 - Data Final
// mv_par05 - Estoque para quantos dias
// mv_par06 - Marca
// mv_par07 - Só produtos com movimentos (S/N)
// mv_par08 - do  grupo
// mv_par09 - até grupo

If Select( "TRB" ) # 0
	DbCloseArea( "TRB" )
EndIf

cPerg    := PadR( 'MOVMAT' , Len( SX1->X1_GRUPO ) )
AjustaSX1()
Pergunte(cPerg,.F.)

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Movimentação de Material"
@ 70,080 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
@ 70,118 BMPBUTTON TYPE 1 ACTION OkProc()
@ 70,156 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
@ 23,14 SAY " " size 200,10
@ 33,14 SAY " " size 200,10
@ 43,14 SAY " "
@ 8,10 TO 060,180
ACTIVATE DIALOG oDlg5 CENTERED
If Select( "TRB" ) # 0
	DbCloseArea( "TRB" )
EndIf

Return

// *******************************************************************************************************************
Static Function OkProc()
Close(oDlg5)

Processa( {|| Runproc() } , "Gerando Arquivo" )
If Select( "TRB" ) # 0
	DbCloseArea( "TRB" )
EndIf

Return

// *******************************************************************************************************************
STATIC FUNCTION Runproc()

If Select( "TRB" ) # 0
	DbCloseArea( "TRB" )
EndIf

aStru := {}
aAdd(aStru,{"CODIGO"   ,"C",15,0})
aAdd(aStru,{"CODLMT"   ,"C",42,0})
aAdd(aStru,{"STATUSLMT","C",04,0})
aAdd(aStru,{"STANDAR"  ,"C",02,0})		//		Incluido por Ilidio conforme instrucao do Sr. Jose Carlos em 21/10/09.
aAdd(aStru,{"PERFIL"   ,"C",40,0})		//		Incluido por Ilidio conforme instrucao do Sr. Jose Carlos em 26/10/09.
aAdd(aStru,{"DENOM"    ,"C",58,0})
aAdd(aStru,{"FORN"     ,"C",58,0})
aAdd(aStru,{"QTSAIDA"  ,"N",10,0})
aAdd(aStru,{"STKLMT"   ,"N",10,0})
aAdd(aStru,{"CONSUMO"     ,"N",10,0})
// aAdd(aStru,{"ESTFALT" ,"N",10,0})	//      Retirado por Ilidio conforme instrucao do Sr. Jose Carlos em 21/10/09.
aAdd(aStru,{"COMPRASP","N",10,0})
aAdd(aStru,{"VENDASP" ,"N",10,0})
aAdd(aStru,{"TRANSITO" ,"N",15,0})
aAdd(aStru,{"DESEMBAR" ,"N",15,0})
aAdd(aStru,{"PER1"    ,"D",08,0})                      
aAdd(aStru,{"PER2"    ,"D",10,0})
aAdd(aStru,{"MESES"   ,"C",08,0})
aAdd(aStru,{"DIAS"    ,"C",24,0})
aAdd(aStru,{"CODFOR"  ,"C",TamSX3("A5_CODPRF")[1],TamSX3("A5_CODPRF")[2]})
aAdd(aStru,{"CLASSIF" ,"C",50,0})

oTemptable := FWTemporaryTable():New( "TRB")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"CODLMT"} )
oTempTable:Create()

/*
cArq := CriaTrab(aStru,.T.)
dbUseArea(.T.,,cArq,"TRB",.T.)
cInd := CriaTrab(NIL,.F.)
IndRegua("TRB",cInd,"CODLMT",,,"Selecionando Registros...")
*/
If mv_par03>mv_par04
	Alert ("Data inicial não pode ser maior que final")
	If Select( "TRB" ) # 0
		DbCloseArea( "TRB" )
	EndIf
	
	Return
Endif

If Year(mv_par04) == Year(mv_par03)
	nMeses := Month(mv_par04) - Month(mv_par03) + 1
Else
	nMeses := Month(mv_par04) - Month(mv_par03) + 13
Endif

dbSelectArea("SB1")
dbSetOrder(9)
ProcRegua(LastRec())
dbSeek(xFilial("SB1") + mv_par01,.T.)
do While !SB1->(Eof()) .and. B1_FILIAL == xFilial("SB1") .and. B1_CODLMT <= mv_par02
	IncProc()
	
	If	Empty(B1_CODLMT) .or. IF( !Empty( mv_par06 ) , Left(B1_COD,2) <> Upper( mv_par06 ) , .F. ) .or. ;
		SB1->B1_ATIVO == "N"
		SB1->(dbSkip())
		Loop
	Endif
	
	If	SB1->B1_GRUPO < mv_par08 .or. SB1->B1_GRUPO > mv_par09
		SB1->( DbSkip() )
		Loop
	EndIf
	
	dbSelectArea("SB2")
	dbSetOrder(1)
	dbSeek(xFilial("SB2") + SB1->B1_COD + "01")
	nAtu	:= B2_QATU - B2_QEMP
	nQtSai  := 0
	nPendV  := 0
	nPendC  := 0
	nQtde	:= 0
	dbselectarea("SC6")
	//dbSetOrder(10)
	dbOrderNickName("CODLMT")
	If dbSeek(xFilial("SC6")+SB1->B1_CODLMT)
		DO WHILE !SC6->(EOF()) .AND. C6_FILIAL == xFilial() .and. Trim(C6_CODLMT) == Trim(SB1->B1_CODLMT)
			dbSelectArea("SC5")
			dbSetOrder(1)
			dbSeek(xFilial("SC5") + SC6->C6_NUM)
			if ! SC5->C5_STPAD $ mv_par10          // Pergunta adicionada p/ Ilidio em 26/10/09 a pedido de Jose Carlos
				dbselectarea("SC6")
				dbSkip()
				loop
			endif
			dbSelectArea("SC6")
			If C6_QTDENT < C6_QTDVEN .and. C6_BLQ <> "R " //.and. SC5->C5_EMISSAO >= MV_PAR03 .AND. SC5->C5_EMISSAO <= MV_PAR04
				nPendV += (C6_QTDVEN - C6_QTDENT)
			Endif
			SC6->(dbSkip())
		Enddo
	Endif
	
	dbSelectArea("SD2")
	//dbSetOrder(11)
	dbOrderNickName("CODLMT")
	If dbSeek(xFilial("SD2") + SB1->B1_CODLMT)
		DO WHILE !SD2->(EOF()) .AND. D2_FILIAL == xFilial() .and. Trim(D2_CODLMT) == Trim(SB1->B1_CODLMT)
			If D2_SERIE == "ZZZ" .OR. D2_SERIE == "XXX" .OR. D2_EMISSAO < mv_par03 .or. D2_EMISSAO > MV_PAR04 .OR. LEFT(D2_COD,2) <> UPPER(MV_PAR06)
				SD2->(dbSkip())
				Loop
			Endif
			dbSelectArea("SF4")
			dbSetOrder(1)
			dbSeek(xFIlial("SF4") + SD2->D2_TES)
			//If (F4_ESTOQUE == "S" .AND. !(Substr(SF4->F4_CF,2,3) $ "111/112") ) .AND. !SD2->D2_TES $ "511/548/584/597" .OR. Substr(SF4->F4_CF,2,3) == "917" .OR. (Substr(SF4->F4_CF,2,3) == "901" .AND. F4_ESTOQUE == "S")
			If !SD2->D2_TES $ "511/548/584/597" .And. F4_ESTOQUE == "S" .AND. ( !(Substr(SF4->F4_CF,2,3) $ "111/112") .OR. Substr(SF4->F4_CF,2,3) $ "917/901" )
				//                                                               FAT. CONSIG                       	 REMESSA MOSTRUARIO		R E M E S S A     P /     I N D U S T R I A L I Z A C A O
				nQtSai += SD2->D2_QUANT
			Endif
			dbSelectArea("SD2")
			SD2->(dbSkip())
		Enddo
	Endif
	
	dbSelectArea("SD3")
	//dbSetOrder(13)
	dbOrderNickName("CODLMT")
	If dbSeek(xFilial("SD3") + SB1->B1_CODLMT)
		DO WHILE !SD3->(EOF()) .AND. D3_FILIAL == xFilial() .and. Trim(D3_CODLMT) == Trim(SB1->B1_CODLMT)
			If D3_ESTORNO == "S" .OR. D3_EMISSAO < mv_par03 .or. D3_EMISSAO > MV_PAR04 .OR. LEFT(D3_COD,2)<>UPPER(MV_PAR06)
				SD3->(dbSkip())
				Loop
			Endif
			If D3_CF $ "RE0/RE1" .AND. D3_DOC<>"INVENT" .and. !D3_TM $ "503/600"	// REQUISICAO CONSUMO e PERDA DEMONST/MOSTRU
				nQtSai += SD3->D3_QUANT
			Endif
			dbSelectArea("SD3")
			SD3->(dbSkip())
		Enddo
	Endif
	
	dbselectarea("SC7")                        // Criar gatilho no C7_NUM p/ tela do C7_TIPOPC
	//dbSetOrder(21)                             // Por aqui o C7_TIPOPC //
	dbOrderNickName("CODLMT")
    IF dbSeek(xFilial("SC7") + SB1->B1_CODLMT,.T.)//	If dbSeek(SB1->B1_CODLMT)
		DO WHILE !SC7->(EOF()) .AND. C7_FILIAL == xFilial("SC7") .and. Trim(SC7->C7_CODLMT) == Trim(SB1->B1_CODLMT)
			If SC7->C7_QUANT > SC7->C7_QUJE .AND. C7_RESIDUO <> "S" // .AND. C7_EMISSAO >= mv_par03 .and. C7_EMISSAO <= mv_par04
				nPendC += C7_QUANT - C7_QUJE
			Endif 
			//Adiciona produtos que estão no armazem 07 como pendentes - Everton Luiz Rosa 08/09/10
		
				//Fim do Processo 
			
				SC7->(dbSkip())
//			Endif
		Enddo
	Endif
	
	If   nqtsai <> 0 .or. nPendV <> 0 .or. mv_par07 == 2
		dbSelectArea("SZH")   	      // tabela de perfis de estoque
		dbsetorder(1)
		dbseek(xfilial("SB1")+SB1->B1_PEREST)
		dbSelectArea("TRB")
		RecLock("TRB",.T.)
		CODIGO		:= SB1->B1_COD
		CODLMT		:= SB1->B1_CODLMT
		STANDAR		:= SB1->B1_STANDAR
		PERFIL		:= SZH->ZH_DESCRIC
		STATUSLMT	:= SB1->B1_STATUS
		DENOM       := SB1->B1_DENOM
		TIPO		:= SB1->B1_STANDAR
		FORN        := SB1->B1_FABRIC
		QTSAIDA     := nQtSai
		STKLMT      := nAtu
		CONSUMO     := (nQtSai / (nMeses*30)) * mv_par05
		
		//      Retirado por Ilidio conforme instrucao do Sr. Jose Carlos em 26/10/09.
		//		ESTFALT     := nAtu - ((nQtSai / (nMeses*30)) * mv_par05)
		
		COMPRASP    := nPendC
		VENDASP     := nPendV
		PER1        := mv_par03
		PER2        := mv_par04
		MESES       := Str(mv_par05,2) + Iif(mv_par05==1," dia"," dias")
		DIAS        := "Estoque para " + AllTrim(Str(mv_par05,5)) + " dias"
		CODFOR		:= Posicione( "SA5" , 2 , xFilial( "SA5" ) + SB1->B1_COD , "A5_CODPRF" )
		CLASSIF		:= Posicione( "SZF" , 1 , xFilial( "SZF" ) + SB1->B1_CLAEST , "ZF_DESCRIC" )

		IF SB1->B1_COD == "BOCOEAS00000003" .OR. SB1->B1_COD == "BOPDBBS00000064" .OR. SB1->B1_COD == "FECOEAS00000012"
			I:= 0
		ENDIF
        nSaldTra := 0
        
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

        TRANSITO	:= nSaldTra

        IF SB2->( DBSEEK( XFILIAL("SB2") + SB1->B1_COD + "07" ) )
		   DESEMBAR	:= SB2->B2_QATU - SB2->B2_QEMP
		ENDIF   
		 
		msUnlock()
	Endif
	
	dbSelectArea("SB1")
	dbSkip()
Enddo

//RestArea( aArea_SB1 )
//RestArea( aArea_SC6 )
//RestArea( aArea_SD2 )
//RestArea( aArea_SD3 )
//RestArea( aArea_SC7 )

ferase("\DADOSADV\MOVMAT.DBF")
dbselectarea("TRB")
dbgotop()
//COPY TO "\DADOSADV\MOVMAT.DBF" VIA "DBFCDXADS"
Processa({||CpyS2T("\DADOSADV\MOVMAT.DBF","C:\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
ferase("\DADOSADV\MOVMAT.DBF")

TRB->(DBCLOSEAREA())

mTESTE := "1;0;1;GIS"  // "EM DISCO;ATUALIZA;1 COPIA;NOME REL."

CALLCRYS("MOVMATX1",,mTESTE)

Return

// *******************************************************************************************************************
Static Function AjustaSX1()
aPerg    := {}
cPerg    := PadR( 'MOVMAT' , Len( SX1->X1_GRUPO ) )

Aadd( aPerg , { "Do Cod Lmt        ?" , "C" , TamSX3( "B1_CODLMT" )[1] , "SB1LMT"})
Aadd( aPerg , { "Ate Cod Lmt       ?" , "C" , TamSX3( "B1_CODLMT" )[1] , "SB1LMT"})
Aadd( aPerg , { "Data inicial      ?" , "D" , 08 , " "})    // 03
Aadd( aPerg , { "Data final        ?" , "D" , 08 , " "})    // 04
Aadd( aPerg , { "Est p/ qtos dias  ?" , "N" , 03 , " "})    // 05
Aadd( aPerg , { "Marca             ?" , "C" , 02 , " "})    // 06
Aadd( aPerg , { "Só Prod.c/Movtos  ?" , "N" , 01 , " "})    // 07
Aadd( aPerg , { "Do  Grupo         ?" , "C" , 04 , "SBM"})  // 08
Aadd( aPerg , { "Ate Grupo         ?" , "C" , 04 , "SBM"})  // 09
Aadd( aPerg , { "Tipos de Ped. Vendas:" , "C" , 07 , " "})    // 10
//Aadd( aPerg , { "Tipos de Ped. Compras:" , "C" , 07 , " "})    // 10

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
		If nxx == 7
			SX1->X1_GSC   := "C"
			SX1->X1_DEF01 := "Sim"
			SX1->X1_DEF02 := "Nao"
		Endif
		SX1->(MsUnlock())
	EndIf
Next nXX
Return Nil


/*
************************** para melhorar perfomance, muito lento
//******** cria índices temporários de todas tabelas
aArea_SB1	:= SB1->( GetArea() )
dbSelectArea("SB1")
cIndexSB1	:= CriaTrab(NIL,.F.)
cKeySB1		:= "B1_FILIAL + B1_CODLMT"
cFiltroSB1	:= "B1_FILIAL == '" + xFilial( "SB1" ) + "'"
cFiltroSB1	+= " .and. Upper( B1_CODLMT ) >= '" + Upper( mv_par01 ) + "'"
cFiltroSB1	+= " .and. Upper( B1_CODLMT ) <= '" + Upper( mv_par02 ) + "'"
cFiltroSB1	+= " .and. Left( B1_COD , 2 ) $ '" + Upper( mv_par06 ) + "'"
IndRegua("SB1",cIndexSB1,cKeySB1,,cFiltroSB1,"Criando indice - SB1")
nIndex := RetIndex("SB1")
dbSetOrder(nIndex+1)

aArea_SC6	:= SC6->( GetArea() )
dbSelectArea("SC6")
cIndexSC6	:= CriaTrab(NIL,.F.)
cKeySC6		:= "C6_FILIAL + C6_CODLMT"
cFiltroSC6	:= "C6_FILIAL == '" + xFilial( "SC6" ) + "'"
cFiltroSC6	+= " .and. Upper( C6_CODLMT ) >= '" + Upper( mv_par01 ) + "'"
cFiltroSC6	+= " .and. Upper( C6_CODLMT ) <= '" + Upper( mv_par02 ) + "'"
cFiltroSC6	+= " .and. Left( C6_PRODUTO , 2 ) $ '" + Upper( mv_par06 ) + "'"
cFiltroSC6	+= " .and. C6_QTDENT < C6_QTDVEN .and. C6_BLQ <> 'R '"
IndRegua("SC6",cIndexSC6,cKeySC6,,cFiltroSC6,"Criando indice - SC6")
nIndex := RetIndex("SC6")
dbSetOrder(nIndex+1)

aArea_SD2	:= SD2->( GetArea() )
dbSelectArea("SD2")
cIndexSD2	:= CriaTrab(NIL,.F.)
cKeySD2		:= "D2_FILIAL + D2_CODLMT"
cFiltroSD2	:= "D2_FILIAL == '" + xFilial( "SD2" ) + "'"
cFiltroSD2	+= " .and. Upper( D2_CODLMT ) >= '" + Upper( mv_par01 ) + "'"
cFiltroSD2	+= " .and. Upper( D2_CODLMT ) <= '" + Upper( mv_par02 ) + "'"
cFiltroSD2	+= " .and. Left( D2_COD , 2 ) $ '" + Upper( mv_par06 ) + "'"
cFiltroSD2	+= " .and. !D2_SERIE $ 'ZZZ/XXX' .and. Dtos( D2_EMISSAO ) >= '" + DtoS( mv_par03 ) + "'"
cFiltroSD2	+= " .and. DtoS( D2_EMISSAO ) <= '" + DtoS( MV_PAR04 ) + "' .and. LEFT(D2_COD,2) $ '" + UPPER(MV_PAR06) + "'"
IndRegua("SD2",cIndexSD2,cKeySD2,,cFiltroSD2,"Criando indice - SD2")
nIndex := RetIndex("SD2")
dbSetOrder(nIndex+1)

aArea_SD3	:= SD3->( GetArea() )
dbSelectArea("SD3")
cIndexSD3	:= CriaTrab(NIL,.F.)
cKeySD3		:= "D3_FILIAL + D3_CODLMT"
cFiltroSD3	:= "D3_FILIAL == '" + xFilial( "SD3" ) + "'"
cFiltroSD3	+= " .and. Upper( D3_CODLMT ) >= '" + Upper( mv_par01 ) + "'"
cFiltroSD3	+= " .and. Upper( D3_CODLMT ) <= '" + Upper( mv_par02 ) + "'"
cFiltroSD3	+= " .and. Left( D3_COD , 2 ) $ '" + Upper( mv_par06 ) + "'"
cFiltroSD3	+= " .and. D3_ESTORNO <> 'S' .and. DtoS( D3_EMISSAO ) >= '" + DtoS( mv_par03 ) + "'"
cFiltroSD3	+= " .and. DtoS( D3_EMISSAO ) <= '" + DtoS( MV_PAR04 ) + "' .and. LEFT(D3_COD,2) $ '" + UPPER(MV_PAR06) + "'"
cFiltroSD3	+= " .and. D3_CF $ 'RE0/RE1' .AND. D3_DOC <> 'INVENT'"
IndRegua("SD3",cIndexSD3,cKeySD3,,cFiltroSD3,"Criando indice - SD3")
nIndex := RetIndex("SD3")
dbSetOrder(nIndex+1)

aArea_SC7	:= SC7->( GetArea() )
dbSelectArea("SC7")
cIndexSC7	:= CriaTrab(NIL,.F.)
cKeySC7		:= "C7_FILIAL + C7_CODLMT"
cFiltroSC7	:= "C7_FILIAL == '" + xFilial( "SC7" ) + "'"
cFiltroSC7	+= " .and. Upper( C7_CODLMT ) >= '" + Upper( mv_par01 ) + "'"
cFiltroSC7	+= " .and. Upper( C7_CODLMT ) <= '" + Upper( mv_par02 ) + "'"
cFiltroSC7	+= " .and. Left( C7_PRODUTO , 2 ) $ '" + Upper( mv_par06 ) + "'"
cFiltroSC7	+= " .and. C7_QUANT > C7_QUJE .and. C7_RESIDUO <> 'S'"
IndRegua("SC7",cIndexSC7,cKeySC7,,cFiltroSC7,"Criando indice - SC7")
nIndex := RetIndex("SC7")
dbSetOrder(nIndex+1)
//******** cria índices temporários de todas tabelas
*/
