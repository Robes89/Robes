#INCLUDE "rwmake.ch"       

// Rotina		: IMPNFC
// Descrição	: Le as notas fiscais 2004 do Kin
// Data			: 17/01/05
// Autor        : Daniel Gondran

User Function IMPNFC()

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Importa NF Devolução"
@ 70,118 BMPBUTTON TYPE 1 ACTION OkProc()
@ 70,156 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
@ 23,14 SAY "O objetivo desta rotina é ler as NFs 2004 do" size 200,10
@ 33,14 SAY "Kin e gravar nas tabelas do MicroSiga       " size 200,10
@ 43,14 SAY " "          size 200,10
@ 8,10 TO 060,180
ACTIVATE DIALOG oDlg5 CENTERED
Return
*******************************************************************************************************************
Static Function OkProc()
Close(oDlg5)       
Processa({|| GeraMov() } , "Gerando Registros..." )
Return
*******************************************************************************************************************
Static Function GeraMov()

//SAIDA
aStru := {}
aAdd(aStru,{"NOTA"      ,"C",06,0})
aAdd(aStru,{"ITEM"      ,"C",03,0})
aAdd(aStru,{"PROD"      ,"C",07,0})
aAdd(aStru,{"EMPRESA"   ,"C",20,0})
aAdd(aStru,{"CGC"       ,"C",14,0})

oTemptableZ := FWTemporaryTable():New( "TRF")
oTemptableZ:SetFields( aStru )
oTempTableZ:AddIndex("index1", {"NOTA+ITEM"} )
oTempTableZ:Create()

//cArq := CriaTrab(aStru,.T.)
//dbUseArea(.T.,,cArq,"TRF",.T.)
//cInd := CriaTrab(NIL,.F.)
IndRegua("TRF",cArq,"NOTA+ITEM",,,"Aguarde...")
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

oTemptable := FWTemporaryTable():New( "TRC")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"NOTA+ITEM"} )
oTempTable:Create()

//cArq := CriaTrab(aStru,.T.)
//dbUseArea(.T.,,cArq,"TRC",.T.)
//cInd := CriaTrab(NIL,.F.)
IndRegua("TRC",cArq,"NOTA+ITEM",,,"Aguarde...")
//dbSetIndex(cArq+OrdBagExt())

oTemptableb := FWTemporaryTable():New( "TRB")
//oTemptable:SetFields( aStru )
oTempTableb:AddIndex("index1", {"NOTA+ITEM"} )
oTempTableb:Create()

//dbUseArea(.T.,"DBFCDX","\SIGAADV\KIN\ITEMC.DBF","TRB",.T.,.F.)
dbSelectArea("TRB")
cTrb := 'TRBb'
IndRegua("TRB",cTrb,"NOTA+ITEM",,,"Aguarde...")
dbSetIndex(cTrb+OrdBagExt())

dbSelectArea("TRC")
Append From TRB


// CABECALHO
aStru := {}
aAdd(aStru,{"NOTA"      ,"C",06,0})
aAdd(aStru,{"EMPRESA"   ,"C",20,0})
aAdd(aStru,{"CGC"       ,"C",14,0})
aAdd(aStru,{"DTEMI"     ,"D",08,0})
aAdd(aStru,{"DTENTR"    ,"D",08,0})
aAdd(aStru,{"ICMS"      ,"N",12,2})   
aAdd(aStru,{"NOPER01"   ,"N",04,0})   
aAdd(aStru,{"NFVENDA"   ,"C",06,0})   


oTemptable := FWTemporaryTable():New( "TRE")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"NOTA"} )
oTempTable:Create()

//cArq := CriaTrab(aStru,.T.)
//dbUseArea(.T.,,cArq,"TRE",.T.)
//cInd := CriaTrab(NIL,.F.)
//IndRegua("TRE",cArq,"NOTA",,,"Aguarde...")
//dbSetIndex(cArq+OrdBagExt())

oTemptableS := FWTemporaryTable():New( "TRD")
oTemptableS:SetFields( aStru )
oTempTableS:AddIndex("index1", {"NOTA"} )
oTempTableS:Create()

//dbUseArea(.T.,"DBFCDX","\SIGAADV\KIN\CABECC.DBF","TRD",.T.,.F.)
dbSelectArea("TRD")
cTrb := 'cArqb'              
IndRegua("TRD",cTrb,"NOTA",,,"Aguarde...")
dbSetIndex(cTrb+OrdBagExt())

dbSelectArea("TRE")
Append From TRD


set softseek off
dbGotop()
ProcRegua(LastRec())
do While !Eof()
	IncProc()
	dbSelectArea("SA1")
	dbSetOrder(3)
	If !dbSeek(xFilial("SA1") + TRE->CGC)
		dbSelectArea("TRF")
		RecLock("TRF",.T.)
		EMPRESA := TRE->EMPRESA
		CGC     := TRE->CGC
		msUnlock()
		dbSelectArea("TRE")
		dbSkip()
		Loop
    Endif

	dbSelectArea("TRC")
	If dbSeek(TRE->NOTA)
		lProcessa := .T.
		do While !Eof() .and. Alltrim(TRC->NOTA) == AllTrim(TRE->NOTA)
			dbSelectArea("SB1")
			dbSetOrder(14)
			dbSeek(xFilial("SB1") + TRC->PROD)
			If !Found()// .AND. TRC->CODIGO == "#"
				dbSelectArea("TRF")
				RecLock("TRF",.T.)
				NOTA := TRC->NOTA
				ITEM := TRC->ITEM
				PROD := TRC->PROD
				msUnlock()
//				lProcessa := .F.
			Endif
			dbSelectArea("TRC")
			dbSkip()
		Enddo 


		If lProcessa .AND. TRE->NFVENDA > " "
			dbSeek(TRE->NOTA)
			nTotal   := 0
			nValBrut := 0
			nValIcm  := 0
			nValIpi  := 0
			nBaseIpi := 0
			nBaseIcm := 0			
			do While !Eof() .and. TRC->NOTA == TRE->NOTA
				pcof := IIF(MONTH(TRE->DTEMI)<3,3,7.6)			
				dbSelectArea("SB1")
				dbSetOrder(14)
				dbSeek(xFilial("SB1") + TRC->PROD)
				dbSelectArea("SD1")
				dbSetOrder(1)
				lAchou := dbSeek(xFilial("SD1") + StrZero(Val(TRE->NOTA),6) + "UNI" + SA1->A1_COD + SA1->A1_LOJA + SB1->B1_COD + StrZero(Val(TRC->ITEM),4))
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
				D1_FORNECE  := SA1->A1_COD
				D1_LOJA		:= SA1->A1_LOJA
				D1_DOC      := StrZero (Val(TRE->NOTA),6)
				D1_LOCAL	:= "01"
				D1_TP       := SB1->B1_TIPO
				D1_EMISSAO  := TRE->DTEMI	
				D1_DTDIGIT  := TRE->DTENTR
				D1_SERIE	:= "UNI"        	
				D1_GRUPO	:= SB1->B1_GRUPO
				D1_TIPO     := "D"
				D1_BASEICM  := (TRC->VALOR * TRC->QTD + TRC->VALOR * TRC->QTD * (TRC->IPI / 100))
				D1_BASEIPI  := TRC->VALOR * TRC->QTD
				D1_NFORI    := TRE->NFVENDA
				D1_SERIORI  := "UNI"
				D1_VALIMP5  := TRC->VALOR * TRC->QTD * pcof / 100
				D1_VALIMP6  := TRC->VALOR * TRC->QTD * 1.65 / 100
				D1_BASIMP5  := TRC->VALOR * TRC->QTD
				D1_BASIMP6	:= TRC->VALOR * TRC->QTD
				D1_ALQIMP5  := pcof
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
    		F1_FORNECE	:= SA1->A1_COD
		    F1_LOJA		:= SA1->A1_LOJA
    		F1_DTDIGIT  := TRE->DTENTR
    		F1_EMISSAO	:= TRE->DTEMI
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
	Endif
	dbSelectArea("TRE")
	dbSKip()
Enddo    

dbSelectArea("TRF")
//copy to \SIGAADV\SAIDAC.DBF Via "DBFCDXADS" 	

TRB->(DBCLOSEAREA())
TRC->(DBCLOSEAREA())
TRD->(DBCLOSEAREA())
TRE->(DBCLOSEAREA())
TRF->(DBCLOSEAREA())
Return
