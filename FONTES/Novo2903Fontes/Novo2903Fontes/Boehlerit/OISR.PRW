#INCLUDE "rwmake.ch"

// Rotina		: OISR
// Descrição	: Order Income and Sales Report
// Data			: 28/01/05
// Autor        : Daniel Gondran

User Function OISR()

// mv_par01 - Mes
// mv_par02 - Ano    
// mv_par03 - Faturamento (Bruto / Liquido)
// mv_par04 - Status Pedido (SEDPICO) 
// mv_par05 - Ignora CFOPs

//cPerg := "OISR01"
cPerg    := PadR( 'OISR01' , Len( SX1->X1_GRUPO ) )
AjustaSX1()
Pergunte(cPerg,.F.)

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Order Income and Sales Report"
@ 70,080 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
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

aStru := {}
aAdd(aStru,{"OGRUPO"	 ,"C",01,0})
aAdd(aStru,{"GRUPO"      ,"C",30,0})
aAdd(aStru,{"OEMP"	     ,"C",01,0})
aAdd(aStru,{"EMP"        ,"C",20,0})
aAdd(aStru,{"BUDGET"     ,"N",14,2})
aAdd(aStru,{"PBUDGET"    ,"N",06,2})
aAdd(aStru,{"ACTUAL"     ,"N",14,2})
aAdd(aStru,{"PACTUAL"    ,"N",06,2})
aAdd(aStru,{"PREVIOUS"   ,"N",14,2})
aAdd(aStru,{"ANO"        ,"C",04,0})
aAdd(aStru,{"MES"        ,"C",02,0})

oTemptable := FWTemporaryTable():New( "TRB")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"OGRUPO+OEMP"} )
oTempTable:Create()

//cArq := CriaTrab(aStru,.T.)
//dbUseArea(.T.,,cArq,"TRB",.T.)
//cInd := CriaTrab(NIL,.F.)
IndRegua("TRB",cInd,"OGRUPO+OEMP",,,"Selecionando Registros...")

iData 	 := ctod("01/"+mv_par01+"/"+mv_par02)
If Val(mv_par01) < 12
	iData2 := ctod("01/"+StrZero(Val(mv_par01)+1,2)+"/"+mv_par02) 
Else
	iData2 := ctod("01/01/"+StrZero(Val(mv_par02)+1,4))
Endif
aEmps 	 := {"BO","FE","KI","ON","NI","XX","BR","BI","MT"}
aEmpresa := {"BOEHLERIT","FETTE","KIENINGER","ONSRUD","NIPPON","XX","PRODUCTION","BILZ","MORRIS TOOLING"}
               
Set SoftSeek On



cGrupo  := "ORDER INCOME"
coGrupo := "1"
dbselectarea("SC5")
dbSetOrder(2)
ProcRegua(LastRec())
dbSeek(xFilial("SC5")+dtos(idata))
DO WHILE !EOF() .AND. C5_FILIAL == xFilial("SC5") .and. Year(C5_EMISSAO) == Year(idata) //.and. Month(C5_EMISSAO) == Month(idata)
	IncProc(C5_NUM)
	If !(C5_STPAD $ mv_par04)
		dbSkip()
		loop
	Endif
	nMoeda   := C5_MOEDA
	If nMoeda <> 1
		cMoeda := "M2_MOEDA" + StrZero(nMoeda,1)
		dbSelectArea("SM2")
		dbSeek(SC5->C5_EMISSAO)
		nConv  := &(cMoeda)
		If nConv == 0
			Alert ("Atenção: Cadastrar Moeda " + StrZero(nMoeda,1) + " no dia " + Dtoc(SC5->C5_EMISSAO))
		Endif			
	Else
		nConv := 1
	Endif
	
	dbSelectArea("SC6")    
	dbSetOrder(1)
	dbSeek(xFilial("SC6") + SC5->C5_NUM)
	do While !Eof() .and. C6_FILIAL == xFilial("SC6") .and. C6_NUM == SC5->C5_NUM
		dbSelectArea("SF4")
		dbSetOrder(1)
		dbSeek(xFilial("SF4") + SC6->C6_TES) 
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
	
		nIndice := Ascan(aEmps,Left(SC6->C6_PRODUTO,2))
		If nIndice == 0
			cEmp  := "OUTROS              "
			coEmp := "6"
		Else
			cEmp  := Padr(aEmpresa[nIndice],20)
			coEmp := StrZero(nIndice,1)
		Endif
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFIlial("SB1") + SC6->C6_PRODUTO)
		If mv_par03 == 1
			nIpi      := SB1->B1_IPI
			mVRUNIT   := SC6->C6_PRCVEN + IIF(lcalipi,(SC6->C6_PRCVEN * nIpi / 100),0)
			mVRTOTAL  := mVRUNIT * SC6->C6_QTDVEN			
			nIndice   := Ascan(aEmps,Left(SC6->C6_PRODUTO,2))
		Else      
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(xFilial("SA1") + SC6->C6_CLI + SC6->C6_LOJA)
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
			mVRUNIT   := SC6->C6_PRCVEN - IIF(lcalicm,SC6->C6_PRCVEN * nIcms/100,0) - SC6->C6_PRCVEN * (IIF(lcalpis,nPis,0)+IIF(lcalcof,nCof,0))/100
			mVRTOTAL  := mVRUNIT * SC6->C6_QTDVEN
		Endif
        If Month(SC5->C5_EMISSAO) == Month(idata)
			dbSelectArea("TRB")
			lAchou := dbSeek(coGrupo + coEmp)		
			RecLock( "TRB" , !lAchou)					
			OGRUPO 		:= coGrupo
			GRUPO		:= cGrupo
			OEMP		:= coEmp
			EMP			:= cEmp
		    BUDGET  	:= 0
			ACTUAL      += mVRTOTAL * nConv
			PREVIOUS	:= 0
			TRB->( MsUnLock() )
		Endif
        If Month(SC5->C5_EMISSAO) <= Month(idata)		
			dbSelectArea("TRB")
			lAchou := dbSeek("3" + coEmp)		
			RecLock( "TRB" , !lAchou)					
			OGRUPO 		:= "3"
			GRUPO		:= "CUMULATIVE " + cGrupo
			OEMP		:= coEmp
			EMP			:= cEmp
		    BUDGET  	:= 0
			ACTUAL      += mVRTOTAL * nConv
			PREVIOUS	:= 0
			TRB->( MsUnLock() )
		Endif
		dbSelectArea("SC6")
		dbSkip()
	Enddo
	dbSelectArea("SC5")
	dbSkip()
Enddo



cGrupo  := "SALES"
coGrupo := "2"
dbselectarea("SD2")
dbSetOrder(5)
ProcRegua(LastRec())
dbSeek(xFilial("SD2")+dtos(idata))
DO WHILE !EOF() .AND. D2_FILIAL == xFilial("SD2") .and. Year(D2_EMISSAO) == Year(idata)
	IncProc(D2_DOC)
	dbSelectArea("SF4")
	dbSetOrder(1)
	dbSeek(xFilial("SF4") + SD2->D2_TES)
	If F4_DUPLIC == "N" .OR. F4_CF $ mv_par05
		dbSelectArea("SD2")
		dbSkip()
		Loop
	Endif
	dbSelectArea("SD2")
	
	nIndice := Ascan(aEmps,Left(D2_COD,2))
	If nIndice == 0
		cEmp  := "OUTROS              "
		coEmp := "6"
	Else
		cEmp  := Padr(aEmpresa[nIndice],20)
		coEmp := StrZero(nIndice,1)
	Endif

	If mv_par03 == 1
		mVRTOTAL 	:= SD2->D2_TOTAL + SD2->D2_VALIPI + SD2->D2_VALFRE
	Else
		mVRTOTAL	:= SD2->D2_TOTAL - SD2->D2_VALICM - SD2->D2_VALIMP1 - SD2->D2_VALIMP2 - SD2->D2_VALIMP3 - SD2->D2_VALIMP4 - SD2->D2_VALIMP5 - SD2->D2_VALIMP6
	Endif 
        
    If Month(SD2->D2_EMISSAO) == Month(idata)
		dbSelectArea("TRB")
		lAchou := dbSeek(coGrupo + coEmp)		
		RecLock( "TRB" , !lAchou)					
		OGRUPO 		:= coGrupo
		GRUPO		:= cGrupo
		OEMP		:= coEmp
		EMP			:= cEmp
	    BUDGET  	:= 0
		ACTUAL      += mVRTOTAL
		PREVIOUS	:= 0
		TRB->( MsUnLock() )
	Endif
    If Month(SD2->D2_EMISSAO) == Month(idata)	
		dbSelectArea("TRB")
		lAchou := dbSeek("4" + coEmp)		
		RecLock( "TRB" , !lAchou)					
		OGRUPO 		:= "4"
		GRUPO		:= "CUMULATIVE " + cGrupo
		OEMP		:= coEmp
		EMP			:= cEmp
	    BUDGET  	:= 0
		ACTUAL      += mVRTOTAL
		PREVIOUS	:= 0
		TRB->( MsUnLock() )
	Endif
	dbSelectArea("SD2")
	dbSkip()
Enddo


     
     
     
// Devoluções
dbselectarea("SD1")
dbSetOrder(6)
ProcRegua(LastRec())
dbSeek(xFilial("SD1")+dtos(idata))
DO WHILE !EOF() .AND. D1_FILIAL == xFilial("SD1") .and. Year(D1_DTDIGIT) == Year(idata)
	IncProc(D1_DOC)
	If SD1->D1_TIPO <> "D"
		dbSkip()
		Loop
	Endif	
	dbSelectArea("SF4")
	dbSetOrder(1)
	dbSeek(xFilial("SF4") + SD1->D1_TES)
	If F4_DUPLIC == "N" .OR. F4_CF $ mv_par05
		dbSelectArea("SD1")
		dbSkip()
		Loop
	Endif
	dbSelectArea("SD1")
	
	nIndice := Ascan(aEmps,Left(D1_COD,2))
	If nIndice == 0
		cEmp  := "OUTROS              "
		coEmp := "6"
	Else
		cEmp  := Padr(aEmpresa[nIndice],20)
		coEmp := StrZero(nIndice,1)
	Endif

	If mv_par03 == 1
		mVRTOTAL 	:= (SD1->D1_TOTAL-SD1->D1_VALDESC + SD1->D1_VALIPI + SD1->D1_VALFRE) * (-1)
	Else
		mVRTOTAL	:= (SD1->D1_TOTAL-SD1->D1_VALDESC - SD1->D1_VALICM - SD1->D1_VALIMP1 - SD1->D1_VALIMP2 - SD1->D1_VALIMP3 - SD1->D1_VALIMP4 - SD1->D1_VALIMP5 - SD1->D1_VALIMP6) * (-1)
	Endif 
        
    If Month(SD1->D1_DTDIGIT) == Month(idata)
		dbSelectArea("TRB")
		lAchou := dbSeek(coGrupo + coEmp)		
		RecLock( "TRB" , !lAchou)					
		OGRUPO 		:= coGrupo
		GRUPO		:= cGrupo
		OEMP		:= coEmp
		EMP			:= cEmp
	    BUDGET  	:= 0
		ACTUAL      += mVRTOTAL
		PREVIOUS	:= 0
		TRB->( MsUnLock() )
	Endif
    If Month(SD1->D1_DTDIGIT) <= Month(idata)	
		dbSelectArea("TRB")
		lAchou := dbSeek("4" + coEmp)		
		RecLock( "TRB" , !lAchou)					
		OGRUPO 		:= "4"
		GRUPO		:= "CUMULATIVE " + cGrupo
		OEMP		:= coEmp
		EMP			:= cEmp
	    BUDGET  	:= 0
		ACTUAL      += mVRTOTAL
		PREVIOUS	:= 0
		TRB->( MsUnLock() )
	Endif
	dbSelectArea("SD1")
	dbSkip()
Enddo

       













cGrupo  := "BACKLOG"
coGrupo := "5"
dbselectarea("SC6")
dbSetOrder(3)
ProcRegua(LastRec())
//dbSeek(xFilial("SC6")+dtos(idata))
dbGotop()
DO WHILE !EOF() .AND. C6_FILIAL == xFilial("SC6") //.and. Year(C6_ENTREG) == Year(idata) .and. Month(C6_ENTREG) == Month(idata)
	IncProc(C6_NUM)
	If C6_QTDENT >= C6_QTDVEN 
		dbSkip()
		Loop
	Endif
	dbSelectArea("SC5")
	dbSetOrder(1)
	dbSeek(xFilial("SC5") + SC6->C6_NUM)
	If !(C5_STPAD $ mv_par04) .or.C5_EMISSAO >= idata2
		dbSelectArea("SC6")
		dbSkip()
		loop
	Endif
	nMoeda   := C5_MOEDA
	If nMoeda <> 1
		cMoeda := "M2_MOEDA" + StrZero(nMoeda,1)
		dbSelectArea("SM2")
		dbSeek(SC5->C5_EMISSAO)
		nConv  := &(cMoeda)
		If nConv == 0
			Alert ("Atenção: Cadastrar Moeda " + StrZero(nMoeda,1) + " no dia " + Dtoc(SC5->C5_EMIISAO))
		Endif			
	Else
		nConv := 1
	Endif
	
	dbSelectArea("SC6")    
	nIndice := Ascan(aEmps,Left(C6_PRODUTO,2))
	If nIndice == 0
		cEmp  := "OUTROS              "
		coEmp := "6"
	Else
		cEmp  := Padr(aEmpresa[nIndice],20)
		coEmp := StrZero(nIndice,1)
	Endif
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFIlial("SB1") + SC6->C6_PRODUTO)
	If mv_par03 == 1
		nIpi      := SB1->B1_IPI
		mVRUNIT   := SC6->C6_PRCVEN + (SC6->C6_PRCVEN * nIpi / 100)
		mVRTOTAL  := mVRUNIT * SC6->C6_QTDVEN			
		nIndice   := Ascan(aEmps,Left(SC6->C6_PRODUTO,2))
	Else      
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1") + SC6->C6_CLI + SC6->C6_LOJA)
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
		mVRUNIT   := SC6->C6_PRCVEN - SC6->C6_PRCVEN * nIcms/100 - SC6->C6_PRCVEN * (nPis+nCof)/100
		mVRTOTAL  := mVRUNIT * SC6->C6_QTDVEN
	Endif
       
	dbSelectArea("TRB")
	lAchou := dbSeek(coGrupo + coEmp)
	RecLock( "TRB" , !lAchou)					
	OGRUPO 		:= coGrupo
	GRUPO		:= cGrupo
	OEMP		:= coEmp
	EMP			:= cEmp
    BUDGET  	:= 0
	ACTUAL      += mVRTOTAL * nConv
	PREVIOUS	:= 0
	TRB->( MsUnLock() )
	dbSelectArea("SC6")
	dbSkip()
Enddo







// Percentuais
dbSelectArea("TRB")
dbGotop()
do While !EOF()
	RecLock("TRB",.F.)
	If BUDGET <> 0
		PBUDGET := ((ACTUAL / BUDGET) - 1) * 100
	Endif
	If PREVIOUS <> 0
		PACTUAL := ((ACTUAL / PREVIOUS) - 1) * 100
	Endif
	ANO			:= mv_par02
	MES			:= mv_par01
	msUnlock()
	dbSkip()
Enddo	

ferase("\DADOSADV\OISR.DBF")
dbselectarea("TRB")
dbgotop()
//COPY TO "\DADOSADV\OISR.DBF" VIA "DBFCDXADS"
Processa({||CpyS2T("\DADOSADV\OISR.DBF","C:\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
ferase("\DADOSADV\OISR.DBF")
TRB->(DBCLOSEAREA())

mTESTE := "1;0;1;GIS"  // "EM DISCO;ATUALIZA;1 COPIA;NOME REL."

CALLCRYS("OISR",,mTESTE)

Set SoftSeek Off
Return

// *----------------------------------------------------------------------------
Static Function AjustaSX1()
aPerg    := {}
//cPerg    := "OISR01"

Aadd( aPerg , { "Mes Referencia      ?" , "C" , 02 , "   "})
Aadd( aPerg , { "Ano Referencia      ?" , "C" , 04 , "   "})
Aadd( aPerg , { "Faturamento         ?" , "N" , 01 , "   "})
Aadd( aPerg , { "Status Ped (SEPDICO)?" , "C" , 07 , "   "})
Aadd( aPerg , { "Ignora CFOPs        :" , "C" , 40 , "   "})

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
		If nxx == 3
			SX1->X1_GSC   := "C"
			SX1->X1_DEF01 := "Bruto"
			SX1->X1_DEF02 := "Liquido"
		Endif
		SX1->(MsUnLock())
	EndIf
Next nXX
Return Nil
