#INCLUDE "rwmake.ch"

// Rotina		: MOVMAT
// Descrição	: Movimentação de Material
// Data			: 12/01/05
// Autor        : Daniel Gondran

User Function MOVMAT2()

Private _cHrIni := SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)

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
Private oProcess 
	Close(oDlg5)

	//Processa( {|| Runproc() } , "Gerando Arquivo" )
	oProcess := MsNewProcess():New( { ||  Runproc(@oProcess, @lEnd)  } , "Gerando Arquivo..." , "Aguarde..." , .F. )
    oProcess:Activate()	
	
	If Select( "TRB" ) # 0
		DbCloseArea( "TRB" )
	EndIf

Return

// *******************************************************************************************************************
STATIC FUNCTION Runproc(oProcess, lEnd)

	Local oTempTable
	Local nXX		:= 0
	Local cFields 	:= ""
	Local _nTotR1   := 0 

	If Select( "TRB" ) # 0
		DbCloseArea( "TRB" )
	EndIf

	If mv_par03>mv_par04
		Alert ("Data inicial não pode ser maior que final")
		If Select( "TRB" ) # 0
			DbCloseArea( "TRB" )
		EndIf
		
		Return 
	Endif

	oTempTable := FWTemporaryTable():New("TRB")

	aStru := {}
	aAdd(aStru,{"CODIGO"   	,"C",15,0})
	aAdd(aStru,{"CODLMT"   	,"C",42,0})
	aAdd(aStru,{"STANDAR"  	,"C",02,0})
	aAdd(aStru,{"PERFIL"   	,"C",40,0})		//		Incluido por Ilidio conforme instrucao do Sr. Jose Carlos em 26/10/09.
	aAdd(aStru,{"STATUSLMT"	,"C",04,0})
	aAdd(aStru,{"DENOM"    	,"C",58,0})
	aAdd(aStru,{"TIPO"     	,"C",02,0})
	aAdd(aStru,{"FORN"     	,"C",20,0})
	aAdd(aStru,{"QTSAIDA"  	,"N",10,0})
	aAdd(aStru,{"STKLMT"   	,"N",10,0})
	aAdd(aStru,{"CUSTO"    	,"N",12,2})
	aAdd(aStru,{"COMPRASP" 	,"N",10,0})
	aAdd(aStru,{"VENDASP"  	,"N",10,0})
	aAdd(aStru,{"CONSUMO"  	,"N",10,0})
	aAdd(aStru,{"PER1"     	,"D",08,0})                      
	aAdd(aStru,{"PER2"     	,"D",10,0})
	aAdd(aStru,{"MESES"    	,"C",08,0})
	aAdd(aStru,{"DIAS"     	,"C",24,0})
	aAdd(aStru,{"CODFOR"   	,"C",TamSX3("A5_CODPRF")[1],TamSX3("A5_CODPRF")[2]})
	aAdd(aStru,{"CLASSIF"   ,"C",50,0})
	aAdd(aStru,{"ULT3MES"  	,"N",10,0})
	aAdd(aStru,{"CLIENTE3" 	,"C",70,0})
	aAdd(aStru,{"ULT6MES"  	,"N",10,0})
	aAdd(aStru,{"CLIENTE6" 	,"C",70,0})
	aAdd(aStru,{"ULT12MES" 	,"N",10,0})
	aAdd(aStru,{"CLIENT12" 	,"C",70,0})
	aAdd(aStru,{"ULT24MES" 	,"N",10,0})
	aAdd(aStru,{"CLIENT24" 	,"C",70,0})
	aAdd(aStru,{"ULT36MES" 	,"N",10,0})
	aAdd(aStru,{"CLIENT36" 	,"C",70,0}) 
	aAdd(aStru,{"ULTSAIDA" 	,"D",08,0})  
	aAdd(aStru,{"TRANSITO" 	,"N",15,0})
	aAdd(aStru,{"DESEMBAR" 	,"N",15,0})
	
	oTemptable:SetFields(aStru)
	oTempTable:AddIndex("Index1", {"PERFIL"} )

	oTempTable:Create()

	cInd := CriaTrab(NIL,.F.)
	IndRegua("TRB",cInd,"CODLMT",,,"Selecionando Registros...")

	If Year(mv_par04) == Year(mv_par03)
		nMeses := Month(mv_par04) - Month(mv_par03) + 1
	Else
		nMeses := Month(mv_par04) - Month(mv_par03) + 13
	Endif

	dbSelectArea("SB1")
	dbSetOrder(18)
	///ProcRegua(LastRec())
	
	
	//SB1->( dbEVal( { || ++_nTotR1 } , {||!EOF()} ) )
	//SB1->(dbgotop()) 
	
	oProcess:SetRegua1( LastRec() )
	oProcess:SetRegua2( LastRec() ) 
	
	
	
	dbSeek(xFilial("SB1") + mv_par01,.T.)
	do While !SB1->(Eof()) .and. B1_FILIAL == xFilial("SB1") .and. B1_CODLMT <= mv_par02
		//IncProc()
		
		If lEnd	//houve cancelamento do processo		
			Exit	
	 	EndIf
	 	 	
		oProcess:IncRegua1('Processando...  '       )
		oProcess:IncRegua2('Produto.......  '  + Alltrim(SB1->B1_COD)   ) 
		
		
		
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
		nAtu	:= SB2->B2_QATU - SB2->B2_QEMP
		nQtSai  := 0
		nPendV  := 0
		nPendC  := 0
		nQtde	:= 0         
		_nCusto := nAtu * SB2->B2_CM1
		_nDesemb := 0
		IF SB2->( DBSEEK( XFILIAL("SB2") + SB1->B1_COD + "07" ) )
			_nDesemb := SB2->B2_QATU - SB2->B2_QEMP
		ENDIF   
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
		
		_nCons3M     :=0
		_nCons6M     :=0
		_nCons12M    :=0
		_nCons24M    :=0
		_nCons36M    :=0
		_cCliente3    := ""
		_cCliente6    := ""
		_cCliente12   := ""
		_cCliente24   := ""
		_cCliente36   := ""
		_dUltSaida    := ctod("")
		
		dbSelectArea("SD2")
		//dbSetOrder(11)
		dbOrderNickName("CODLMT")
		If dbSeek(xFilial("SD2") + SB1->B1_CODLMT)
			DO WHILE !SD2->(EOF()) .AND. D2_FILIAL == xFilial() .and. Trim(D2_CODLMT) == Trim(SB1->B1_CODLMT)
				If D2_SERIE == "ZZZ" .OR. D2_SERIE == "XXX" //.OR. LEFT(D2_COD,2) <> UPPER(MV_PAR06)
					SD2->(dbSkip())
					Loop
				Endif

				If SD2->D2_TIPO $ "D/B"
					SD2->(dbSkip())
					Loop
				Else
					If SD2->D2_EMISSAO > mv_par04 - 90   // Dentro dos ultimos 3 meses
						_nCons3m := _nCons3m + SD2->D2_QUANT
						If !ALLTRIM(SD2->D2_CLIENTE) $ _cCliente3
						_cCliente3 := _cCliente3 + "/"+ALLTRIM(SD2->D2_CLIENTE)
						Endif
					ElseIf SD2->D2_EMISSAO > MV_PAR04 - 180 // Dentro dos ultimos 6 meses
						_nCons6m := _nCons6m + SD2->D2_QUANT
						If !ALLTRIM(SD2->D2_CLIENTE) $ _cCliente6
						_cCliente6 := _cCliente6 + "/"+ALLTRIM(SD2->D2_CLIENTE)
						Endif
					ElseIf SD2->D2_EMISSAO > MV_PAR04 - 365 // Dentro do ultimo ano
						_nCons12m := _nCons12m + SD2->D2_QUANT
						If !ALLTRIM(SD2->D2_CLIENTE) $ _cCliente12
						_cCliente12 := _cCliente12 + "/"+ALLTRIM(SD2->D2_CLIENTE)
						Endif
					ElseIf SD2->D2_EMISSAO > MV_PAR04 - 730 // Dentro dos ultimos 2 anos
						_nCons24m := _nConsò24m + SD2->D2_QUANT
						If !ALLTRIM(SD2->D2_CLIENTE) $ _cCliente24
						_cCliente24 := _cCliente24 + "/"+ALLTRIM(SD2->D2_CLIENTE)
						Endif
					ElseIf SD2->D2_EMISSAO > MV_PAR04 - 1095 // Dentro dos ultimos 3 anos
						_nCons36m := _nCons36m + SD2->D2_QUANT
						If !ALLTRIM(SD2->D2_CLIENTE) $ _cCliente36
						_cCliente36 := _cCliente36 + "/"+ALLTRIM(SD2->D2_CLIENTE)
						Endif
					Endif
				Endif
				If _dUltSaida == ctod("")
				_dUltSaida := SD2->D2_EMISSAO
				else 
				If SD2->D2_EMISSAO > _dUltSaida
					_dUltSaida := SD2->D2_EMISSAO
				Endif
				Endif   
				If D2_EMISSAO < mv_par03 .or. D2_EMISSAO > MV_PAR04 
					SD2->(dbSkip())
					Loop
				Endif
				dbSelectArea("SF4")
				dbSetOrder(1)
				dbSeek(xFIlial("SF4") + SD2->D2_TES)
				If !SD2->D2_TES $ "511/548/584/597" .And. F4_ESTOQUE == "S" .AND. ( !(Substr(SF4->F4_CF,2,3) $ "111/112") .OR. Substr(SF4->F4_CF,2,3) $ "917/901" )
					//                                                               FAT. CONSIG                       	 REMESSA MOSTRUARIO		R E M E S S A     P /     I N D U S T R I A L I Z A C A O
					nQtSai += SD2->D2_QUANT
				Endif
				dbSelectArea("SD2")
				SD2->(dbSkip())
			Enddo
		Endif
		
		dbSelectArea("SD3")
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
		dbOrderNickName("CODLMT")
		IF dbSeek(xFilial("SC7") + SB1->B1_CODLMT,.T.)//	If dbSeek(SB1->B1_CODLMT)
			DO WHILE !SC7->(EOF()) .AND. C7_FILIAL == xFilial("SC7") .and. Trim(SC7->C7_CODLMT) == Trim(SB1->B1_CODLMT)
				If SC7->C7_QUANT > SC7->C7_QUJE .AND. C7_RESIDUO <> "S" // .AND. C7_EMISSAO >= mv_par03 .and. C7_EMISSAO <= mv_par04
					nPendC += C7_QUANT - C7_QUJE
				Endif 
					SC7->(dbSkip())
			Enddo
		Endif
		
		nSaldTra := 0
			
		dbSelectArea("ZZ1")
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
			CUSTO       := _nCusto
			
			COMPRASP    := nPendC
			VENDASP     := nPendV
			CONSUMO     := nAtu - nQtSai +nPendC -nPendV //(nQtSai / (nMeses*30)) * mv_par05

			PER1        := mv_par03
			PER2        := mv_par04
			MESES       := Str(mv_par05,2) + Iif(mv_par05==1," dia"," dias")
			DIAS        := "Estoque para " + AllTrim(Str(mv_par05,5)) + " dias"
			CODFOR		:= Posicione( "SA5" , 2 , xFilial( "SA5" ) + SB1->B1_COD , "A5_CODPRF" )
			CLASSIF		:= Posicione( "SZF" , 1 , xFilial( "SZF" ) + SB1->B1_CLAEST , "ZF_DESCRIC" )
			ULT3MES     := _nCons3m
			CLIENTE3    := _cCliente3
			ULT6MES     := _nCons6m
			CLIENTE6	:= _cCliente6
			ULT12MES    := _nCons12m
			CLIENT12 	:= _cCliente12
			ULT24MES	:= _nCons24m
			CLIENT24	:= _cCliente24
			ULT36MES	:= _nCons36m
			CLIENT36	:=_cCliente36
			ULTSAIDA    := _dUltSaida
			TRANSITO	:= nSaldTra
			DESEMBAR	:= _nDesemb  
			msUnlock()
		Endif
		
		dbSelectArea("SB1")
		dbSkip()
	Enddo

	cPATH:= 'C:\TEMP\'
	cFileName   := "MOVMAT2"+"_"+DTOS(DATE())+"_"+_cHrIni+"_"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)+".csv"
	cDestino	:= PADR(cPATH+cFileName, 100)

	dbselectarea("TRB")
	dbgotop()         
	
	For nXX := 1 to Len(aStru)
		cFields += aStru[nXX][1] + ";"//Nome do campo
	Next
	
	cFields := Left(cFields, Len(cFields) -1) //Remover o ultimo ponto e vírgula
	
	//Monta Cabeçalho Relatório
	U_ArqLog(cFields,cDestino,"")	
	
	
	While !TRB->(EOF())
			//IncProc()
			 		
			RecLock("TRB", .F.)
	
			cDetal:= ""
			cDetal+= cValToChar(TRB->CODIGO)   	+ ";"
			cDetal+= cValToChar(TRB->CODLMT)   	+ ";"
			cDetal+= cValToChar(TRB->STANDAR)   + ";"
			cDetal+= cValToChar(TRB->PERFIL)  	+ ";"
			cDetal+= cValToChar(TRB->STATUSLMT) + ";"
			cDetal+= cValToChar(TRB->DENOM)  	+ ";"
			cDetal+= cValToChar(TRB->TIPO)  	+ ";"
			cDetal+= cValToChar(TRB->FORN) 		+ ";"
			cDetal+= cValToChar(TRB->QTSAIDA) 	+ ";"
			cDetal+= cValToChar(TRB->STKLMT) 	+ ";"
			cDetal+= StrTran(cValToChar(TRB->CUSTO),".", ",") 	+ ";"
			cDetal+= cValToChar(TRB->COMPRASP) 	+ ";"
			cDetal+= cValToChar(TRB->VENDASP) 	+ ";"
			cDetal+= cValToChar(TRB->CONSUMO) 	+ ";"
			cDetal+= cValToChar(TRB->PER1) 		+ ";"
			cDetal+= cValToChar(TRB->PER2) 		+ ";"
			cDetal+= cValToChar(TRB->MESES) 	+ ";"
			cDetal+= cValToChar(TRB->DIAS) 		+ ";"
			cDetal+= cValToChar(TRB->CODFOR) 	+ ";"
			cDetal+= cValToChar(TRB->CLASSIF) 	+ ";"
			cDetal+= cValToChar(TRB->ULT3MES) 	+ ";"
			cDetal+= cValToChar(TRB->CLIENTE3) 	+ ";"
			cDetal+= cValToChar(TRB->ULT6MES) 	+ ";"
			cDetal+= cValToChar(TRB->CLIENTE6) 	+ ";"
			cDetal+= cValToChar(TRB->ULT12MES) 	+ ";"
			cDetal+= cValToChar(TRB->CLIENT12) 	+ ";"
			cDetal+= cValToChar(TRB->ULT24MES) 	+ ";"
			cDetal+= cValToChar(TRB->CLIENT24) 	+ ";"
			cDetal+= cValToChar(TRB->ULT36MES) 	+ ";"
			cDetal+= cValToChar(TRB->CLIENT36) 	+ ";"
			cDetal+= cValToChar(TRB->ULTSAIDA) 	+ ";"
			cDetal+= cValToChar(TRB->TRANSITO) 	+ ";"
			cDetal+= cValToChar(TRB->DESEMBAR)
			
			U_ArqLog(cDetal,cDestino,"")
			
			TRB->(MsUnLock())
			TRB->(DbSkip())
			
	EndDo
	
	MsgBox("Foi gerado o arquivo MOVMAT2 na pasta: "+CHR(13)+CHR(10)+cDestino,"Atenção","ALERT")

	If ApOleClient("MsExcel")  
		oExcelApp:= MsExcel():New()
		oExcelApp:WorkBooks:Open(cDestino)
		oExcelApp:SetVisible(.T.)
	EndIf

	TRB->(DBCLOSEAREA())

Return

// *******************************************************************************************************************
Static Function AjustaSX1()

Local nXX := 0

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
