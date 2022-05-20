#INCLUDE "rwmake.ch"

// Rotina		: RELOG
// Descrição	: Relatório log de alterações de pedidos
// Data			: 24/04/06
// Autor        : Daniel Gondran

User Function RELOG()

// mv_par01 - Data alt ini    
// mv_par02 - Data alt fim   
// mv_par03 - Data emi ini   
// mv_par04 - Data emi fim  

//cPerg := "RELOG1"
Local cPerg    := PadR( 'RELOG1' , Len( SX1->X1_GRUPO ) )

//AjustaSX1()

Pergunte(cPerg,.F.)

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Relatório Alterações de Pedidos"
@ 70,080 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg,.T.)
@ 70,118 BMPBUTTON TYPE 1 ACTION OkProc()
@ 70,156 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
@ 23,14 SAY " " size 200,10
@ 33,14 SAY "" size 200,10
@ 43,14 SAY ""
@ 8,10 TO 060,180
ACTIVATE DIALOG oDlg5 CENTERED

Return

Static Function OkProc()
Close(oDlg5)

Processa( {|| Runproc() } , "Gerando Arquivo" )

Return

//*******************************************************************************( INICIO )
STATIC FUNCTION Runproc()

Local cDestino := ""
Local _nX := 0

aStru := {}
aAdd(aStru,{"PEDIDO"     ,"C",06,0})
aAdd(aStru,{"ITEM"       ,"C",02,0})
aAdd(aStru,{"PRODUTO"    ,"C",15,0})
aAdd(aStru,{"CLIENTE"    ,"C",20,0})
aAdd(aStru,{"CODLMT"     ,"C",46,0})
aAdd(aStru,{"EMIORIG"    ,"D",08,0})
aAdd(aStru,{"ALTERA"     ,"D",08,0})
aAdd(aStru,{"ENTORIG"    ,"D",08,0})
aAdd(aStru,{"NOVAENT"    ,"D",08,0})
aAdd(aStru,{"QTDORIG"    ,"N",14,2})
aAdd(aStru,{"NOVAQTD"    ,"N",14,2})
aAdd(aStru,{"PRCORIG"    ,"N",14,4})
aAdd(aStru,{"NOVOPRC"    ,"N",14,4})
aAdd(aStru,{"TOTORIG"    ,"N",14,2})
aAdd(aStru,{"NOVOTOT"    ,"N",14,2})
aAdd(aStru,{"CSTAT"      ,"C",01,0})
aAdd(aStru,{"DIF"        ,"N",14,2})
aAdd(aStru,{"TITULO1"    ,"C",80,0})
aAdd(aStru,{"TITULO2"    ,"C",80,0})
	
	oTempTable := FWTemporaryTable():New( "TRC" )
	
	oTemptable:SetFields( aStru )
	//oTempTable:AddIndex("indice1", {"PEDIDO+ITEM"} )
	//------------------
	//Criação da tabela
	//------------------
	oTempTable:Create()


//cArq := CriaTrab(aStru,.T.)
//dbUseArea(.T.,,cArq,"TRC",.T.)
//cInd := CriaTrab(NIL,.F.)
//IndRegua("TRC",cInd,"PEDIDO+ITEM",,,"Selecionando Registros...")
ar:={"A","A","A","A","A","A","R","A","A","A","A","A"}
mtit1    := "Periodo : de " + dtoc(mv_par01) + " a " + dtoc(mv_par02)

dbselectarea("SZ8")
dbGotop()
//dbSetOrder(2)
//dbSeek(xFilial("SZ8") + dtos(mv_par02))
ProcRegua(LastRec())

DO WHILE !EOF() // .AND. Z8_FILIAL == xFilial("SZ8") .and. Z8_EMISSAO <= mv_par02 
	IncProc()
	If SZ8->Z8_EMISSAO >= MV_PAR03 .AND. SZ8->Z8_EMISSAO <= MV_PAR04      // EMISSAO
		If SZ8->Z8_EMINOVO >= MV_PAR01 .AND. SZ8->Z8_EMINOVO <= MV_PAR02  // ALTERAÇÃO
			If EMPTY(SZ8->Z8_PRODUTO)
				dbSkip()
				Loop
			Endif
			If MONTH(SZ8->Z8_EMISSAO) == MONTH(SZ8->Z8_EMINOVO)
				dbSkip()
				Loop
			Endif
			IF SZ8->Z8_STATUS == "E"
				dbSkip()
				Loop
			Endif
			dbSelectArea("SC5")
			dbSetOrder(1)
			dbSeek(xFilial("SC5") + SZ8->Z8_NUM)
			If SC5->C5_STPAD $ "SPE" .OR. SZ8->Z8_NUM = "000000"
				dbSelectArea("SB1")
				dbSetOrder(1)
				dbSeek(xFilial("SB1") + SZ8->Z8_PRODUTO)
				nIpi      := SB1->B1_IPI						
				// Abate impostos
				
				dbSelectArea("SA1")
				dbSetOrder(1)
				dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI)
				cCli	:= A1_NREDUZ

				dbSelectArea("SC6")
				dbSetOrder(2)
				dbSeek(xFilial("SC6") + SZ8->Z8_PRODUTO + SC5->C5_NUM)
				
				IF EOF() .OR. EMPTY	(SC6->C6_TES)
					dbSelectArea("SF4")
					dbSetOrder(1)
					dbSeek(xFilial("SF4") + "514")
				ELSE	
					dbSelectArea("SF4")
					dbSetOrder(1)
					dbSeek(xFilial("SF4") + SC6->C6_TES)
                ENDIF

				
				IF F4_ICM == "S"
					lcalicm := .T.
				Else
					lcalicm := .F.
				Endif
				If F4_IPI == "S"
					lcalipi := .T.
				Else
					lcalipi := .F.
				Endif
				If F4_PISCOF == "1"
					lcalpis := .T.
					lcalcof := .F.
				ElseIf F4_PISCOF == "2"
					lcalpis := .F.
					lcalcof := .T.
				ElseIf F4_PISCOF == "3"
					lcalpis := .T.
					lcalcof := .T.
				Else
					lcalpis := .F.
					lcalcof := .F.
				Endif

				
				dbSelectArea("SC6")
				cNorte := GetMV("MV_NORTE")
				If SA1->A1_EST $ cNorte
					nIcms := 7
				ElseIf SA1->A1_EST == "SP"
					If SB1->B1_PICM > 0
						nIcms := SB1->B1_PICM
					Else
						nIcms := 18
					Endif
				Else
					nIcms := 12
				Endif
				nCof := GetMV("MV_TXCOFIN")
				nPis := GetMV("MV_TXPIS")
				mVR1 := SZ8->Z8_PRCORIG - IIF(.t.,;
			             Iif(.T.,(SZ8->Z8_PRCORIG + 0) * ;
			             Iif(SF4->F4_INCIDE=="F",(1 + (nIpi / 100)),1) * nIcms/100,0),0) - ;
			             SZ8->Z8_PRCORIG * (Iif(lCalPis,nPis,0) + ;
			             Iif(lcalcof,nCof,0))/100

				mVR2 := SZ8->Z8_PRCNOVO - IIF(.t.,;
			             Iif(.T.,(SZ8->Z8_PRCNOVO + 0) * ;
			             Iif(SF4->F4_INCIDE=="F",(1 + (nIpi / 100)),1) * nIcms/100,0),0) - ;
			             SZ8->Z8_PRCNOVO * (Iif(lCalPis,nPis,0) + ;
			             Iif(lcalcof,nCof,0))/100

				mVRTOT1	:= mVR1 * SZ8->Z8_QTDORIG
				mVRTOT2	:= mVR2 * SZ8->Z8_QTDNOVA
				
				dbSelectArea("TRC")
				RecLock( "TRC" , .T.)
				PEDIDO	:= SZ8->Z8_NUM
				ITEM	:= SZ8->Z8_ITEM
				PRODUTO	:= SZ8->Z8_PRODUTO
				CLIENTE := cCli
				CODLMT	:= SB1->B1_CODLMT
				EMIORIG	:= SZ8->Z8_EMISSAO
				ALTERA	:= SZ8->Z8_EMINOVO
				ENTORIG	:= SZ8->Z8_ENTREG
				NOVAENT	:= SZ8->Z8_ENTNOVO
				QTDORIG	:= SZ8->Z8_QTDORIG
				NOVAQTD	:= SZ8->Z8_QTDNOVA
				PRCORIG	:= MVR1 // SZ8->Z8_PRCORIG
				NOVOPRC	:= MVR2 // SZ8->Z8_PRCNOVO
				TOTORIG	:= MVRTOT1 // SZ8->Z8_VALORIG
				NOVOTOT	:= MVRTOT2 // SZ8->Z8_VALNOVO
				CSTAT	:= SZ8->Z8_STATUS
				DIF		:= MVRTOT2 - MVRTOT1 // SZ8->Z8_VALNOVO - SZ8->Z8_VALORIG
				TITULO1 := mTit1
				TITULO2 := AR[MONTH(MV_PAR01)]
				TRC->( MsUnLock() )
			Endif
		Endif
	Endif
	dbSelectArea("SZ8")
	dbSkip()
Enddo

	cPATH:= 'C:\TEMP\'
	cFileName   := "_LOG"+"_"+DTOS(DATE())+"_"+SUBSTR(TIME(),1,2)+"_"+SUBSTR(TIME(),4,2)+"_"+SUBSTR(TIME(),7,2)+".csv"
	cDestino	:= PADR(cPATH+cFileName, 100)

	cCabec:=""
	//Monta Cabeçalho Relatório
	For _nX:=1 To Len(aStru)
		cCabec+= aStru[_nX,1]+";" 
	Next _nX

	cCabec:=SubStr(cCabec,1,Len(cCabec)-1)
	u_ArqLog(cCabec,cDestino,"")

	dbselectarea("TRC")
	TRC->(dbgotop())         

	While TRC->(!EOF())
		
		cDetal:= ""
		cDetal+= "'" + Alltrim(TRC->PEDIDO ) + ";"
		cDetal+= "'" + Alltrim(TRC->ITEM   ) + ";"
		cDetal+= "'" + Alltrim(TRC->PRODUTO) 	  + ";"
		cDetal+= "'" + Alltrim(TRC->CLIENTE) + ";"
		cDetal+= cValToChar(TRC->CODLMT ) + ";"
		cDetal+= cValToChar(TRC->EMIORIG) + ";"
		cDetal+= cValToChar(TRC->ALTERA ) + ";"
		cDetal+= cValToChar(TRC->ENTORIG) + ";"
		cDetal+= cValToChar(TRC->NOVAENT) + ";"
		cDetal+= StrTran(cValToChar(TRC->QTDORIG),".",",") + ";"
		cDetal+= StrTran(cValToChar(TRC->NOVAQTD),".",",") + ";"
		cDetal+= StrTran(cValToChar(TRC->PRCORIG),".",",") + ";"
		cDetal+= StrTran(cValToChar(TRC->NOVOPRC),".",",") + ";"
		cDetal+= StrTran(cValToChar(TRC->TOTORIG),".",",") + ";"
		cDetal+= StrTran(cValToChar(TRC->NOVOTOT),".",",") + ";"
		cDetal+= cValToChar(TRC->CSTAT  ) + ";"
		cDetal+= StrTran(cValToChar(TRC->DIF),".",",") + ";"
		cDetal+= cValToChar(TRC->TITULO1) + ";"
		cDetal+= cValToChar(TRC->TITULO2)
		
		u_ArqLog(cDetal,cDestino,"")
		TRC->(dbSkip())
	EndDo

//Carrega EXCEL
If ApOleClient("MsExcel")
	oExcelApp:= MsExcel():New()
	oExcelApp:WorkBooks:Open(cDestino)
	oExcelApp:SetVisible(.T.)
Endif

TRC->(DBCLOSEAREA())

/*ferase("\DADOSADV\_LOG.DBF")
dbselectarea("TRC")
dbgotop()
COPY TO "\DADOSADV\_LOG.DBF" VIA "DBFCDXADS"
Processa({||CpyS2T("\DADOSADV\_LOG.DBF","C:\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
Processa({||CpyS2T("\DADOSADV\_LOG.DBF","C:\WINDOWS\TEMP\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
//Processa({||CpyS2T("\DADOSADV\_LOG.DBF","C:\INST\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
ferase("\DADOSADV\_LOG.DBF")
TRC->(DBCLOSEAREA())
mTESTE := "1;0;1;GIS"  // "EM DISCO;ATUALIZA;1 COPIA;NOME REL."
CALLCRYS("RLOG",,mTESTE)*/

//Set SoftSeek Off
Return

// *----------------------------------------------------------------------------
/*Static Function AjustaSX1()
aPerg    := {}
//cPerg    := "RELOG1"

Aadd( aPerg , { "Data Alteracao Ini  ?" , "D" , 08 , "   "})
Aadd( aPerg , { "Data Alteracao Fim  ?" , "D" , 08 , "   "})
Aadd( aPerg , { "Data Emissao Ini    ?" , "D" , 08 , "   "})
Aadd( aPerg , { "Data Emissao Fim    ?" , "D" , 08 , "   "})

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
		SX1->(MsUnLock())
	EndIf
Next nXX
Return Nil*/
