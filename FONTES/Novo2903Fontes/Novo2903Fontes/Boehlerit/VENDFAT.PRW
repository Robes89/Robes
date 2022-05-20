#INCLUDE "rwmake.ch"

// Rotina		: VENDFAT
// Descrição	: Venda Liquida / Faturamento Liquido
// Data			: 20/01/05
// Autor        : Daniel Gondran

User Function VENDFAT()

// mv_par01 - Do  Produto
// mv_par02 - Até Produto
// mv_par03 - Quebra (empresa / vendedor)
// mv_par04 - Ano    
// mv_par05 - Abate Impostos

//cPerg := "VENFAT"
 cPerg    := PadR( 'VENFAT' , Len( SX1->X1_GRUPO ) )
AjustaSX1()
Pergunte(cPerg,.F.)

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Venda Liquida Anual"
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
aAdd(aStru,{"VENDEMP"    ,"C",20,0})
aAdd(aStru,{"PREV01"     ,"N",14,2})
aAdd(aStru,{"PREV02"     ,"N",14,2})
aAdd(aStru,{"PREV03"     ,"N",14,2})
aAdd(aStru,{"PREV04"     ,"N",14,2})
aAdd(aStru,{"PREV05"     ,"N",14,2})
aAdd(aStru,{"PREV06"     ,"N",14,2})
aAdd(aStru,{"PREV07"     ,"N",14,2})
aAdd(aStru,{"PREV08"     ,"N",14,2})
aAdd(aStru,{"PREV09"     ,"N",14,2})
aAdd(aStru,{"PREV10"     ,"N",14,2})
aAdd(aStru,{"PREV11"     ,"N",14,2})
aAdd(aStru,{"PREV12"     ,"N",14,2})
aAdd(aStru,{"PREV13"     ,"N",14,2})
aAdd(aStru,{"REAL01"     ,"N",14,2})
aAdd(aStru,{"REAL02"     ,"N",14,2})
aAdd(aStru,{"REAL03"     ,"N",14,2})
aAdd(aStru,{"REAL04"     ,"N",14,2})
aAdd(aStru,{"REAL05"     ,"N",14,2})
aAdd(aStru,{"REAL06"     ,"N",14,2})
aAdd(aStru,{"REAL07"     ,"N",14,2})
aAdd(aStru,{"REAL08"     ,"N",14,2})
aAdd(aStru,{"REAL09"     ,"N",14,2})
aAdd(aStru,{"REAL10"     ,"N",14,2})
aAdd(aStru,{"REAL11"     ,"N",14,2})
aAdd(aStru,{"REAL12"     ,"N",14,2})
aAdd(aStru,{"REAL13"     ,"N",14,2})
aAdd(aStru,{"TITULO1"    ,"C",52,0})
aAdd(aStru,{"TITULO2"    ,"C",52,0})

oTemptable := FWTemporaryTable():New( "TRB")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"VENDEMP"} )
oTempTable:Create()

//cArq := CriaTrab(aStru,.T.)
//dbUseArea(.T.,,cArq,"TRB",.T.)
//cInd := CriaTrab(NIL,.F.)
//IndRegua("TRB",cInd,"VENDEMP",,,"Selecionando Registros...")
/*                   
cArq := CriaTrab(aStru,.T.)
dbUseArea(.T.,,cArq,"TRC",.T.)
cInd := CriaTrab(NIL,.F.)
IndRegua("TRC",cInd,"VENDEMP",,,"Selecionando Registros...")
*/                   
iData 	 := ctod("01/01/"+mv_par04)
aEmps 	 := {"BO","FE","KI","BR","ON","BI","MT"}
aEmpresa := {"BOEHLERIT","FETTE","KIENINGER","FAB. BRASIL","ONSRUD","BILZ","MORRIS TOOLING"}
mtit1    := "Venda Liquida por " + Iif(mv_par03==1,"empresa","vendedor") + " " + mv_par04 + ;
            " (" + Iif(mv_par05==1,"com","sem") + " impostos)"
mtit2    := "Faturamento Liquido por " + Iif(mv_par03==1,"empresa","vendedor") + " " + mv_par04 + ;
            " (" + Iif(mv_par05==1,"com","sem") + " impostos)"
               
Set SoftSeek On
               
//VENDA
dbselectarea("SC5")
dbSetOrder(2)
ProcRegua(LastRec())
dbSeek(xFilial("SC5")+dtos(idata))
DO WHILE !EOF() .AND. C5_FILIAL == xFilial("SC5") .and. Year(C5_EMISSAO) == Year(idata)
	IncProc(C5_NUM)
	cVend 	 := C5_NOMEVEN
	cMes     := "REAL" + StrZero(Month(C5_EMISSAO),2)
	dbSelectArea("SC6")    
	dbSetOrder(1)
	dbSeek(xFilial("SC6") + SC5->C5_NUM)
	do While !Eof() .and. C6_FILIAL == xFilial("SC6") .and. C6_NUM == SC5->C5_NUM
		If mv_par03 == 2
			mCampo := cVend
		Else
			nIndice := Ascan(aEmps,Left(C6_PRODUTO,2))
			If nIndice == 0
				mCampo := "OUTROS              "
			Else
				mCampo := Padr(aEmpresa[nIndice],20)
			Endif
		Endif
		If mv_par05 == 2
			mVRTOTAL 	:= SC6->C6_VALOR
		Else
			If SB1->B1_PICM > 0
				nIcms := SB1->B1_PICM
			Else
				cTripa := GetMV("MV_ESTICM")
				nIcms := Val(Substr(cTripa,At(SA1->A1_EST,cTripa)+2,2))
			Endif
			nCof := GetMV("MV_TXCOFIN")
			nPis := GetMV("MV_TXPIS")
			mVRUNIT   := SC6->C6_PRCVEN - SC6->C6_PRCVEN * nIcms/100 - SC6->C6_PRCVEN * (nPis+nCof)/100
			mVRTOTAL  := mVRUNIT * SC6->C6_QTDVEN
		Endif
        
		dbSelectArea("TRB")
		lAChou := dbSeek(mCampo)
		RecLock( "TRB" , !lAchou)					
		VENDEMP		:= mCampo
		&(cMes)		:= mVRTOTAL
		TITULO1     := mTit1
		TRB->( MsUnLock() )
		dbSelectArea("SC6")
		dbSkip()
	Enddo
	dbSelectArea("SC5")
	dbSkip()
Enddo
/*
//FATURAMENTO	
dbselectarea("SD2")
dbSetOrder(5)
ProcRegua(LastRec())
dbSeek(xFilial("SD2")+dtos(idata))
DO WHILE !EOF() .AND. D2_FILIAL == xFilial("SD2") .and. Year(D2_EMISSAO) == Year(idata)
	IncProc(D2_DOC)
	dbSelectArea("SC5")
	dbSetOrder(1)
	dbSeek(xFilial("SC5") + SD2->D2_PEDIDO + SD2->D2_ITEMPV)
	cVend 	 := C5_NOMEVEN
	dbSelectArea("SD2")
	cMes     := "REAL" + StrZero(Month(D2_EMISSAO),2)
	If mv_par03 == 2
		mCampo := cVend
	Else
		nIndice := Ascan(aEmps,Left(D2_COD,2))
		If nIndice == 0
			mCampo := "OUTROS              "
		Else
			mCampo := Padr(aEmpresa[nIndice],20)
		Endif
	Endif
	If mv_par05 == 2
		mVRTOTAL 	:= SD2->D2_TOTAL
	Else
		mVRTOTAL	:= SD2->D2_TOTAL - SD2->D2_VALICM
	Endif 
        
	dbSelectArea("TRC")
	lAChou := dbSeek(mCampo)
	RecLock( "TRC" , !lAchou)					
	VENDEMP		:= mCampo
	&(cMes)		:= mVRTOTAL
	TITULO2     := mTit1
	TRC->( MsUnLock() )
	dbSelectArea("SD2")
	dbSkip()
Enddo
  */
//TOTAL
dbSelectArea("TRB")
dbGotop()
do While !EOF()
	RecLock("TRB",.F.)
	P13:=PREV01+PREV02+PREV03+PREV04+PREV05+PREV06+PREV07+PREV08+PREV09+PREV10+PREV11+PREV12
	R13:=REAL01+REAL02+REAL03+REAL04+REAL05+REAL06+REAL07+REAL08+REAL09+REAL10+REAL11+REAL12	
	msUnlock()
	dbSkip()
Enddo	
	/*
dbSelectArea("TRC")
dbGotop()
do While !EOF()
	RecLock("TRC",.F.)
	P13:=PREV01+PREV02+PREV03+PREV04+PREV05+PREV06+PREV07+PREV08+PREV09+PREV10+PREV11+PREV12
	R13:=REAL01+REAL02+REAL03+REAL04+REAL05+REAL06+REAL07+REAL08+REAL09+REAL10+REAL11+REAL12	
	msUnlock()
	dbSkip()
Enddo	
		*/
ferase("\DADOSADV\VEND.DBF")
dbselectarea("TRB")
dbgotop()
//COPY TO "\DADOSADV\VEND.DBF" VIA "DBFCDXADS"
Processa({||CpyS2T("\DADOSADV\VEND.DBF","C:\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
ferase("\DADOSADV\VEND.DBF")
TRB->(DBCLOSEAREA())
mTESTE := "1;0;1;GIS"  // "EM DISCO;ATUALIZA;1 COPIA;NOME REL."
CALLCRYS("VEND",,mTESTE)
          /*
ferase("\DADOSADV\FAT.DBF")
dbselectarea("TRC")
dbgotop()
COPY TO "\DADOSADV\FAT.DBF"
Processa({||CpyS2T("\DADOSADV\FAT.DBF","C:\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
ferase("\DADOSADV\FAT.DBF")
TRC->(DBCLOSEAREA())
mTESTE := "1;0;1;GIS"  // "EM DISCO;ATUALIZA;1 COPIA;NOME REL."
//CALLCRYS("FATX",,mTESTE)
            */
Set SoftSeek Off
Return

// *----------------------------------------------------------------------------
Static Function AjustaSX1()
aPerg    := {}
//cPerg    := "VENFAT"

Aadd( aPerg , { "Do Produto        ?" , "C" , 15 , "SB1"})
Aadd( aPerg , { "Ate Produto       ?" , "C" , 15 , "SB1"})
Aadd( aPerg , { "Empresa/Vendedor  ?" , "N" , 01 , "   "})
Aadd( aPerg , { "Ano Referencia    ?" , "C" , 04 , "   "})
Aadd( aPerg , { "Abate impostos    ?" , "N" , 01 , "   "})

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
			SX1->X1_DEF01 := "Empresa"
			SX1->X1_DEF02 := "Vendedor"
		Endif
		If nxx == 5
			SX1->X1_GSC   := "C"
			SX1->X1_DEF01 := "Sim"
			SX1->X1_DEF02 := "Nao"
		Endif
		SX1->(MsUnLock())
	EndIf
Next nXX
Return Nil
