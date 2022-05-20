#INCLUDE "rwmake.ch"

// Rotina		: CBAIXA
// Descrição	: 
// Data			: 
// Autor        : 

User Function CBAIXA()

// mv_par01 - Data Inicial
// mv_par02 - Data Final

//cPerg := "CBAIXA"
cPerg    := PadR( 'CBAIXA' , Len( SX1->X1_GRUPO ) )
AjustaSX1()
Pergunte(cPerg,.F.)

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "CBAIXA"
@ 70,080 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
@ 70,118 BMPBUTTON TYPE 1 ACTION OkProc()
@ 70,156 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
@ 23,14 SAY " " size 200,10
@ 33,14 SAY " " size 200,10
@ 43,14 SAY " "
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
aAdd(aStru,{"VEND"    ,"C",06,0})
aAdd(aStru,{"BAIXA"   ,"D",08,0})
aAdd(aStru,{"VENDEDOR","C",15,0})  
aAdd(aStru,{"NUMERO"  ,"C",10,0})  
aAdd(aStru,{"CLIENTE" ,"C",25,0})  
aAdd(aStru,{"VALBRUT" ,"N",16,2})  
aAdd(aStru,{"ICMS"    ,"N",16,2})
aAdd(aStru,{"IPI"     ,"N",16,2})  
aAdd(aStru,{"PIS"     ,"N",16,2})  
aAdd(aStru,{"COFINS"  ,"N",16,2})  
aAdd(aStru,{"FRETE"   ,"N",16,2})  
aAdd(aStru,{"VALLIQ"  ,"N",16,2})  

oTemptable := FWTemporaryTable():New( "TRB")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"VENDEDOR"} )
oTempTable:Create()

//cArq := CriaTrab(aStru,.T.)
//dbUseArea(.T.,,cArq,"TRB",.T.)
//cInd := CriaTrab(NIL,.F.)
//IndRegua("TRB",cInd,"VENDEDOR",,,"Selecionando Registros...")

// Comissao pela BAIXA

dbSelectArea("SE1")
dbSetOrder(7)
dbSeek(xFilial("SE1"))
ProcRegua(LastRec())
DO WHILE !EOF() .AND. E1_FILIAL == xFilial("SE1") 
	IncProc()	
	If E1_VALOR - E1_SALDO <= 0 .OR. E1_BAIXA < mv_par01 .or. E1_BAIXA > mv_par02
		dbSKip()
		Loop
	Endif		
	dbSelectArea("SA3")
	dbSetOrder(1)
	dbSeek(xFilial("SA3") + SE1->E1_VEND1)
	If A3_TIPO == "I" .or. Eof()
		dbSelectArea("SE1")
		dbSkip()
		loop
	Endif
	dbSelectArea("SF2")
	dbSetOrder(1)
	dbSeek(xFilial("SF2") + SE1->E1_NUM + SE1->E1_PREFIXO + SE1->E1_CLIENTE + SE1->E1_LOJA)
	nFator := SE1->E1_VALOR / SF2->F2_VALBRUT
	nIcms  := F2_VALICM * nFator
	nIPI   := F2_VALIPI * nFator
	nPis   := F2_VALIMP6 * nFator
	nCof   := F2_VALIMP5 * nFAtor
	nFrete := F2_FRETE * nFator

	dbSelectArea("TRB")
	RecLock("TRB",.T.)
	VEND	:= SA3->A3_COD
	VENDEDOR:= SA3->A3_NREDUZ
	BAIXA	:= SE1->E1_BAIXA
	NUMERO	:= SE1->E1_NUM + "-" + SE1->E1_PREFIXO
	CLIENTE	:= SE1->E1_NOMCLI
	VALBRUT := SE1->E1_VALOR - SE1->E1_SALDO
	Icms 	:= nIcms
	IPI   	:= nIpi
	Pis    	:= nPis
	Cofins  := nCof
	Frete   := nFrete
	VALLIQ  := SE1->E1_VALOR - SE1->E1_SALDO - nIcms - nIpi - nPis - nCof - nFrete
	
	msUnlock()
	dbSelectArea("SE1")
	dbSkip()
Enddo


	
ferase("\DADOSADV\CBAIXA.DBF")
dbselectarea("TRB")
dbgotop()
//COPY TO "\DADOSADV\CBAIXA.DBF"
Processa({||CpyS2T("\DADOSADV\CBAIXA.DBF","C:\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
ferase("\DADOSADV\CBAIXA.DBF")

TRB->(DBCLOSEAREA())


Set SoftSeek Off
Return

// *----------------------------------------------------------------------------
Static Function AjustaSX1()
aPerg    := {}
//cPerg    := "CBAIXA"

Aadd( aPerg , { "Data inicial      ?" , "D" , 08 , " "})    
Aadd( aPerg , { "Data final        ?" , "D" , 08 , " "})    


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
		SX1->(MsUnlock())
	EndIf
Next nXX
Return Nil
