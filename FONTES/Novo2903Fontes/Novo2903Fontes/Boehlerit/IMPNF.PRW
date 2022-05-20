#INCLUDE "rwmake.ch"       

// Rotina		: IMPNF
// Descrição	: Le as notas fiscais 2004 do Kin
// Data			: 17/01/05
// Autor        : Daniel Gondran

User Function IMPNF()

//cPerg := "IMPNFS"
cPerg    := PadR( 'IMPNFS' , Len( SX1->X1_GRUPO ) )

AjustaSX1()

Pergunte(cPerg,.F.)

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Importa NF"
@ 70,080 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
@ 70,118 BMPBUTTON TYPE 1 ACTION OkProc()
@ 70,156 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
@ 23,14 SAY "O objetivo desta rotina é ler as NFs 2004 do" size 200,10
@ 33,14 SAY "Kin e gravar nas tabelas do MicroSiga       " size 200,10
@ 43,14 SAY " "          size 200,10
@ 8,10 TO 060,180
ACTIVATE DIALOG oDlg5 CENTERED
Return
// *******************************************************************************************************************
Static Function OkProc()
Close(oDlg5)       
Processa({|| GeraMov() } , "Gerando Registros..." )
Return
// *******************************************************************************************************************
Static Function GeraMov()

xSerie := "UN "

//SAIDA
aStru := {}
aAdd(aStru,{"NOTA"      ,"C",06,0})
aAdd(aStru,{"ITEM"      ,"C",03,0})
aAdd(aStru,{"PROD"      ,"C",07,0})
aAdd(aStru,{"VALOR"     ,"N",16,4})
aAdd(aStru,{"EMPRESA"   ,"C",20,0})
aAdd(aStru,{"CGC"       ,"C",14,0})

oTemptable := FWTemporaryTable():New( "TRF")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"CGC+NOTA+ITEM"} )
oTempTable:Create()

//cArq := CriaTrab(aStru,.T.)
//dbUseArea(.T.,,cArq,"TRF",.T.)
//cInd := CriaTrab(NIL,.F.)
//IndRegua("TRF",cArq,"CGC+NOTA+ITEM",,,"Aguarde...")
//dbSetIndex(cArq+OrdBagExt())

// ITENS
aStru := {}
aAdd(aStru,{"NOTA"      ,"C",06,0})
aAdd(aStru,{"ITEM"      ,"C",03,0})
aAdd(aStru,{"PROD"      ,"C",07,0})
aAdd(aStru,{"CODIGO"    ,"C",15,0})
aAdd(aStru,{"QTD"       ,"N",14,3})
aAdd(aStru,{"IPI"       ,"N",06,2})
aAdd(aStru,{"VALOR"     ,"N",18,5})
aAdd(aStru,{"OLIQICMS"  ,"N",06,2})
aAdd(aStru,{"CODTRIB"   ,"C",03,0})

oTemptableB := FWTemporaryTable():New( "TRC")
oTemptableB:SetFields( aStru )
oTempTableB:AddIndex("index1", {"NOTA+ITEM"} )
oTempTableB:Create()

//cArq := CriaTrab(aStru,.T.)
//dbUseArea(.T.,,cArq,"TRC",.T.)
//cInd := CriaTrab(NIL,.F.)
IndRegua("TRC",cArq,"NOTA+ITEM",,,"Aguarde...")
//dbSetIndex(cArq+OrdBagExt())

oTemptableD := FWTemporaryTable():New( "TRB")
//oTemptable:SetFields( aStru )
oTempTableD:AddIndex("index1", {"NOTA+ITEM"} )
oTempTableD:Create()

//dbUseArea(.T.,"DBFCDX","\SIGAADV\KIN\ITEM.DBF","TRB",.T.,.F.)
dbSelectArea("TRB")
cTrb := 'Arq'
IndRegua("TRB",cTrb,"NOTA+ITEM",,,"Aguarde...")
//dbSetIndex(cTrb+OrdBagExt())

dbSelectArea("TRC")
Append From TRB


// CABECALHO
aStru := {}
aAdd(aStru,{"NOTA"      ,"N",06,0})
aAdd(aStru,{"EMPRESA"   ,"C",20,0})
aAdd(aStru,{"CGC"       ,"C",14,0})
aAdd(aStru,{"DTEMI"     ,"D",08,0})
aAdd(aStru,{"ALIQICMS"  ,"N",06,2})   
aAdd(aStru,{"NOPER01"   ,"N",04,0})   
aAdd(aStru,{"NOPER02"   ,"N",04,0})   
aAdd(aStru,{"NOPER03"   ,"N",04,0})   
aAdd(aStru,{"SITUACAO"  ,"N",01,0})
aAdd(aStru,{"CONREV"    ,"C",01,0})

oTemptable := FWTemporaryTable():New( "TRE")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"NOTA"} )
oTempTable:Create()

//cArq := CriaTrab(aStru,.T.)
//dbUseArea(.T.,,cArq,"TRE",.T.)
//cInd := CriaTrab(NIL,.F.)
//IndRegua("TRE",cArq,"NOTA",,,"Aguarde...")
//dbSetIndex(cArq+OrdBagExt())

oTemptable := FWTemporaryTable():New( "TRD")
oTempTable:Create()
//dbUseArea(.T.,"DBFCDX","\SIGAADV\KIN\CABEC.DBF","TRD",.T.,.F.)
//dbSelectArea("TRD")
//cTrb := CriaTrab(,.F.)                
IndRegua("TRD",cTrb,"NOTA",,,"Aguarde...")
dbSetIndex(cTrb+OrdBagExt())

dbSelectArea("TRE")
Append From TRD

/*
// PRODUTOS
aStru := {}
aAdd(aStru,{"CODIGO"    ,"C",07,0})
aAdd(aStru,{"TIPO"      ,"C",01,0})

cArq := CriaTrab(aStru,.T.)
dbUseArea(.T.,,cArq,"TRG",.T.)
cInd := CriaTrab(NIL,.F.)
IndRegua("TRG",cArq,"CODIGO",,,"Aguarde...")
dbSetIndex(cArq+OrdBagExt())

dbUseArea(.T.,"DBFCDX","\SIGAADV\KIN\INPRO.DBF","TRH",.T.,.F.)
dbSelectArea("TRH")
cTrb := CriaTrab(,.F.)                
IndRegua("TRH",cTrb,"CODIGO",,,"Aguarde...")
dbSetIndex(cTrb+OrdBagExt())

dbSelectArea("TRG")
Append From TRH
*/
set softseek off   

dbSelectArea("TRE")
dbGotop()    
ProcRegua(LastRec())
do While !Eof() //.and. TRE->NOTA<=84848
	IncProc() 
	dbSelectArea("SF2")  
	dbSetOrder(1)
	If dbSeek(xFilial("SF2") + StrZero (TRE->NOTA,6) + "ZZZ")
		dbSelectArea("TRE")
		dbSkip()
		Loop
	Endif
	dbSelectArea("TRE")
	IF TRE->DTEMI < mv_par01 .or. TRE->DTEMI > mv_par02
		dbSkip()
		Loop
	Endif
	If TRE->NOTA >= 86903 .AND. TRE->NOTA <= 86994
		dbSkip()
		Loop
	Endif
	If TRE->NOTA >= 88174 .AND. TRE->NOTA <= 88229
		dbSkip()
		Loop
	Endif 
//	SET SOFTSEEK ON

	dbSelectArea("SA1")
	cCod_Cli	:= Space( Len( SA1->A1_COD ) )
	cLoj_Cli	:= Space( Len( SA1->A1_LOJA ) )

// ***** wilson - inicio
	SA1->( DbSetOrder( 3 ) )
	If Left( TRE->CGC , 14 ) # "00000000000000" .and. SA1->( DbSeek( xFilial( "SA1" ) + Left( TRE->CGC , 14 ) ) )
		cCod_Cli	:= SA1->A1_COD
		cLoj_Cli	:= SA1->A1_LOJA
	Else
		SA1->( DbSetOrder( 5 ) )
		If SA1->( DbSeek( xFilial( "SA1" ) + Left( TRE->EMPRESA , 20 ) ) )
			cCod_Cli	:= SA1->A1_COD
			cLoj_Cli	:= SA1->A1_LOJA
		EndIf
	EndIf
// ***** wilson - fim

//	dbSetOrder(5)
//	dbSeek(xFilial("SA1") + TRE->EMPRESA)
	/*
		dbSelectArea("TRF")
		lAchou := dbSeek(TRE->CGC)
		RecLock("TRF",!lAchou)
		EMPRESA := TRE->EMPRESA
		CGC     := TRE->CGC
		msUnlock()
		dbSelectArea("TRE")
		dbSkip()
		Loop
*/
//    SET SOFTSEEK OFF
	dbSelectArea("TRC")
	If dbSeek(AllTrim(Str(TRE->NOTA,6)))
		lProcessa := .T.
		do While !Eof() .and. Alltrim(TRC->NOTA) == AllTrim(Str(TRE->NOTA,6))
			dbSelectArea("SB1")
			dbSetOrder(14)
			dbSeek(xFilial("SB1") + TRC->PROD)
			If !Found() .AND. Substr(StrZero(TRE->NOPER01,4),2,3) $ "111,112,107,108,102,101,110,109"
				dbSelectArea("TRF")
				RecLock("TRF",.T.)
				NOTA := TRC->NOTA
				ITEM := TRC->ITEM
				PROD := TRC->PROD
				VALOR := TRC->VALOR
				msUnlock()
				lProcessa := .F.
			Endif
			dbSelectArea("TRC")
			dbSkip()
		Enddo 
		
		
		If lProcessa .AND. TRE->SITUACAO<>3
			dbSeek(AllTrim(Str(TRE->NOTA,6)))
			nTotal   := 0
			nValBrut := 0
			nValIcm  := 0
			nValIpi  := 0
			nBaseIpi := 0    
			nBaseIcm := 0
			do While !Eof() .and. Alltrim(TRC->NOTA) == AllTrim(Str(TRE->NOTA ,6))
				dbSelectArea("SB1")
				dbSetOrder(14)
				If dbSeek(xFilial("SB1") + TRC->PROD)
					pcof := IIF(MONTH(TRE->DTEMI)<3,3,7.6)
					dbSelectArea("SD2")
					dbSetOrder(3)
					lAchou := dbSeek(xFilial("SD2") + StrZero(TRE->NOTA,6) + xSerie + cCod_Cli + cLoj_Cli + SB1->B1_COD + StrZero(Val(TRC->ITEM),2))
					RecLock("SD2",!lAchou)
					D2_FILIAL	:= xFilial("SD2")
					D2_ITEM	  	:= StrZero(Val(TRC->ITEM),2)
					D2_COD		:= SB1->B1_COD
					D2_CODLMT	:= SB1->B1_CODLMT
					D2_UM		:= SB1->B1_UM
					D2_QUANT    := TRC->QTD
					D2_PRCVEN   := TRC->VALOR 
					D2_TOTAL    := TRC->VALOR * TRC->QTD
					D2_VALIPI   := TRC->VALOR * TRC->QTD * (TRC->IPI / 100)
					D2_VALICM   := (TRC->VALOR * TRC->QTD + Iif(TRE->CONREV=="C",TRC->VALOR * TRC->QTD * (TRC->IPI / 100),0)) * (TRC->OLIQICMS / 100)
					D2_CF       := StrZero(TRE->NOPER01,4)
					D2_IPI      := TRC->IPI
					D2_PICM     := TRC->OLIQICMS
					D2_CLIENTE  := cCod_Cli
					D2_LOJA		:= cLoj_Cli
					D2_DOC      := StrZero (TRE->NOTA,6)
					//D2_DOC      := StrZero (TRE->NOTA,9)
					D2_LOCAL	:= "01"
					D2_TP       := SB1->B1_TIPO
					D2_EMISSAO  := TRE->DTEMI	
					D2_SERIE	:= xSerie
					D2_GRUPO	:= SB1->B1_GRUPO
					D2_EST      := SA1->A1_EST
					D2_PRUNIT	:= TRC->VALOR
					D2_TIPO     := "N"
					D2_BASEICM  := TRC->VALOR * TRC->QTD + Iif(TRE->CONREV=="C",TRC->VALOR * TRC->QTD * (TRC->IPI / 100),0)
					D2_BASEIPI  := TRC->VALOR * TRC->QTD
					D2_VALIMP5  := TRC->VALOR * TRC->QTD * pcof / 100
					D2_VALIMP6  := TRC->VALOR * TRC->QTD * 1.65 / 100
					D2_BASIMP5  := TRC->VALOR * TRC->QTD
					D2_BASIMP6	:= TRC->VALOR * TRC->QTD
					D2_ALQIMP5  := pcof
					D2_ALQIMP6  := 1.65
					msUnlock()
					nTotal   += D2_TOTAL
					nValBrut += D2_TOTAL + D2_VALIPI
					nValIcm  += D2_VALICM
					nValIpi  += D2_VALIPI
					nBaseIPI += D2_BASEIPI
					nBaseIcm += D2_BASEICM
				Endif
				dbSelectArea("TRC")
				dbSkip()
			Enddo
	
			dbSelectArea("SF2")
			dbSetOrder(1)
			lAchou := dbSeek(xFilial("SF2") + StrZero (TRE->NOTA,6) )
			RecLock("SF2",!lAchou)
			F2_FILIAL	:= xFilial("SF2")
	    	F2_DOC		:= StrZero (TRE->NOTA,6) 
		    F2_SERIE    := xSerie
    		F2_CLIENTE	:= cCod_Cli
		    F2_LOJA		:= cLoj_Cli
    		F2_EMISSAO  := TRE->DTEMI
	    	F2_EST      := SA1->A1_EST
	    	F2_TIPOCLI  := SA1->A1_TIPO
		    F2_VALBRUT  := nValBrut
    		F2_VALICM   := nValIcm
		    F2_VALIPI   := nValIpi
    		F2_BASEIPI  := nBaseIpi
    		F2_BASEICM	:= nBaseIcm
	    	F2_VALMERC  := nTotal
	    	F2_VALFAT   := nValBrut
	    	F2_TIPO     := "N"
		    F2_MOEDA    := 1
		    F2_BASIMP5  := nTotal
		    F2_BASIMP6  := nTotal
    		msUnlock() 
   		Endif
        


/*

		If lProcessa .AND. TRE->SITUACAO==4 .OR. TRE->SITUACAO==6
			dbSeek(TRE->NOTA)
			nTotal   := 0
			nValBrut := 0
			nValIcm  := 0
			nValIpi  := 0
			nBaseIpi := 0
			do While !Eof() .and. TRC->NOTA == TRE->NOTA 
				dbSelectArea("SB1")
				dbSetOrder(14)
				If dbSeek(xFilial("SB1") + TRC->PROD)
				dbSelectArea("SD1")
				dbSetOrder(1)
				lAchou := dbSeek(xFilial("SD1") + StrZero(Val(TRE->NOTA),6) + "UNI" + cCod_Cli + cLoj_Cli + SB1->B1_COD + StrZero(Val(TRC->ITEM),4))
				RecLock("SD1",!lAchou)
				D1_FILIAL	:= xFilial("SD1")
				D1_ITEM	  	:= StrZero(Val(TRC->ITEM),4)
				D1_COD		:= SB1->B1_COD
				D1_CODLMT	:= SB1->B1_CODLMT
				D1_UM		:= SB1->B1_UM
				D1_QUANT    := TRC->QTD
				D1_VUNIT    := TRC->VALOR 
				D1_TOTAL    := TRC->VALOR * TRC->QTD
				D1_VALIPI   := TRC->VALOR * TRC->QTD * (TRC->IPI / 100)
				D1_VALICM   := (TRC->VALOR * TRC->QTD + TRC->VALOR * TRC->QTD * (TRC->IPI / 100)) * (TRC->OLIQICMS / 100)
				D1_CF       := StrZero(TRE->NOPER01,4)
				D1_IPI      := TRC->IPI
				D1_PICM     := TRC->OLIQICMS
				D1_FORNECE  := cCod_Cli
				D1_LOJA		:= cLoj_Cli
				D1_DOC      := StrZero (Val(TRE->NOTA),6)
				D1_LOCAL	:= "01"
				D1_TP       := SB1->B1_TIPO
				D1_EMISSAO  := TRE->DTEMI	
				D1_DTDIGIT  := TRE->DTEMI
				D1_SERIE	:= "UNI"        	
				D1_GRUPO	:= SB1->B1_GRUPO
				D1_TIPO     := "D"
				D1_BASEICM  := (TRC->VALOR * TRC->QTD + TRC->VALOR * TRC->QTD * (TRC->IPI / 100))
				D1_BASEIPI  := TRC->VALOR * TRC->QTD
				D1_NFORI    := TRE->NFVENDA
				D1_SERIORI  := "UNI"
				D1_VALIMP5  := TRC->VALOR * TRC->QTD * 7.6 / 100
				D1_VALIMP6  := TRC->VALOR * TRC->QTD * 1.65 / 100
				D1_BASIMP5  := TRC->VALOR * TRC->QTD
				D1_BASIMP6	:= TRC->VALOR * TRC->QTD
				D1_ALQIMP5  := 7.60
				D1_ALQIMP6  := 1.65
				
				msUnlock()
				nValBrut += D1_TOTAL + D1_VALIPI
				nValIcm  += D1_VALICM
				nValIpi  += D1_VALIPI
				nBaseIPI += D1_BASEIPI
				nBaseICM += D1_BASEICM
				nTotal   += D1_TOTAL
				dbSelectArea("TRC")
				dbSkip()
			Enddo
	
			dbSelectArea("SF1")
			dbSetOrder(1)
			lAchou := dbSeek(xFilial("SF1") + StrZero (Val(TRE->NOTA),6) )
			RecLock("SF1",!lAchou)
			F1_FILIAL	:= xFilial("SF1")
	    	F1_DOC		:= StrZero (Val(TRE->NOTA),6) 
		    F1_SERIE    := "UNI"
    		F1_FORNECE	:= cCod_Cli
		    F1_LOJA		:= cLoj_Cli
    		F1_DTDIGIT  := TRE->DTEMI
	    	F1_EST      := SA1->A1_EST
		    F1_VALBRUT  := nValBrut
    		F1_VALICM   := nValIcm
		    F1_VALIPI   := nValIpi
    		F1_BASEIPI  := nBaseIpi
	    	F1_VALMERC  := nTotal  
	    	F1_TIPO     := "D"
		    F1_MOEDA    := 1
		    F1_BASEICM  := nBaseIcm
		    F1_BASIMP5  := nTotal
		    F1_BASIMP6  := nTotal
    		msUnlock() 
   		Endif
*/				
   		
	Endif
	dbSelectArea("TRE")
	dbSKip()
Enddo    

dbSelectArea("TRF")
//copy to \SIGAADV\SAIDA.DBF	Via "DBFCDXADS" 

TRB->(DBCLOSEAREA())
TRC->(DBCLOSEAREA())
TRD->(DBCLOSEAREA())
TRE->(DBCLOSEAREA())
TRF->(DBCLOSEAREA())
Return


Static Function AjustaSX1()
aPerg    := {}
//cPerg    := "IMPNFS"

Aadd( aPerg , { "Da Data           ?" , "D" , 08 })
Aadd( aPerg , { "Ate Data          ?" , "D" , 08 })

For nXX := 1 to Len( aPerg )
	If !SX1->( DbSeek( cPerg + StrZero( nXX , 2 ) ) )
		RecLock( "SX1" , .T. )
		SX1->X1_GRUPO     := cPerg
		SX1->X1_ORDEM     := StrZero( nXX , 2 )
		SX1->X1_PERGUNT   := aPerg[nXX][1]
		SX1->X1_VARIAVL   := "mv_ch" + Str( nXX , 1 )
		SX1->X1_TIPO      := aPerg[nXX][2]
		SX1->X1_TAMANHO   := aPerg[nXX][3]
		SX1->X1_PRESEL    := 1
		SX1->X1_GSC       := "G"
		SX1->X1_VAR01     := "mv_par" + StrZero( nXX , 2 )
		SX1->(MsUnlock())
	EndIf
Next nXX
Return Nil

