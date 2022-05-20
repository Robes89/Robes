#INCLUDE "rwmake.ch"

// Rotina		: RELCOMIS
// Descrição	: Relatório de Comissões
// Data			: 11/02/05
// Autor        : Daniel Gondran

User Function RELCOMIS()


// mv_par01 - Mes
// mv_par02 - Ano    
// mv_par03 - Abate Impostos
// mv_par04 - Ignora CFOPs

//cPerg := "RCOMIS"
 cPerg    := PadR( 'RCOMIS' , Len( SX1->X1_GRUPO ) )
AjustaSX1()
Pergunte(cPerg,.F.)

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Relatório de Comissões"
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
aAdd(aStru,{"MES"        ,"C",04,0})
aAdd(aStru,{"ANO"        ,"C",02,0})
aAdd(aStru,{"FAIXA"      ,"C",02,0})
aAdd(aStru,{"BASE"       ,"N",14,2})
aAdd(aStru,{"PERC"       ,"N",06,2})
aAdd(aStru,{"COMIS"      ,"N",14,2})
aAdd(aStru,{"BAIEMI"     ,"C",01,0})
aAdd(aStru,{"TITULO1"    ,"C",50,0})

oTemptable := FWTemporaryTable():New( "TRC")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"VENDEMP"} )
oTempTable:Create()
/*
cArq := CriaTrab(aStru,.T.)
dbUseArea(.T.,,cArq,"TRC",.T.)
cInd := CriaTrab(NIL,.F.)
IndRegua("TRC",cInd,"VENDEMP",,,"Selecionando Registros...")
*/
aStru := {}
aAdd(aStru,{"NOTA"       ,"C",06,0})
aAdd(aStru,{"CLIENTE"    ,"C",20,0})
aAdd(aStru,{"ITEM"       ,"C",03,0})
aAdd(aStru,{"EMISSAO"    ,"D",08,0})
aAdd(aStru,{"VENDEDOR"   ,"C",20,0})
aAdd(aStru,{"PRODUTO"    ,"C",15,0})
aAdd(aStru,{"MARCA"      ,"C",20,0})
aAdd(aStru,{"VALOR"      ,"N",14,2})
aAdd(aStru,{"ICMS"       ,"N",14,2})
aAdd(aStru,{"IPI"        ,"N",14,2})
aAdd(aStru,{"PIS"        ,"N",14,2})
aAdd(aStru,{"COFINS"     ,"N",14,2})

oTemptable := FWTemporaryTable():New( "TRB")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"NOTA"} )
oTempTable:Create()
/*
cArq := CriaTrab(aStru,.T.)
dbUseArea(.T.,,cArq,"TRB",.T.)
cInd := CriaTrab(NIL,.F.)
*/

iData 	 := ctod("01/01/"+mv_par02)
aEmps 	 := {"BO","FE","KI","NI","ON","BR","BI","MT"}
aEmpresa := {"BOEHLERIT","FETTE","KIENINGER","NIPPON","ONSRUD","FAB. BRASIL","BILZ","MORRIS TOOLING"}
mtit1    := "Comissoes por vendedor " +  mv_par01 + " / " + mv_par02

Set SoftSeek On
               
dbselectarea("SZ2")
dbSetOrder(1)
ProcRegua(LastRec())
dbSeek(xFilial("SZ2") + mv_par02 + mv_par01)
DO WHILE !EOF() .AND. Z2_FILIAL == xFilial("SZ2") .and. Z2_NUM == mv_par02 + mv_par01
	dbSelectArea("SA3")
	dbSetOrder(1)
	dbSeek(xFilial("SA3") + SZ2->Z2_VEND)
	dbSelectArea("TRC")
	RecLock( "TRC" , .T.)					
	VENDEMP	:= SA3->A3_NREDUZ
	MES		:= MV_PAR01
	ANO		:= MV_PAR02
	FAIXA	:= SZ2->Z2_FAIXA
	BASE	:= SZ2->Z2_BASE
	PERC	:= SZ2->Z2_PORC
	COMIS	:= SZ2->Z2_COMIS
	BAIEMI	:= SZ2->Z2_BAIEMI
	TITULO1 := mTit1
	MsUnLock()
	dbSelectArea("SZ2")
	dbSkip()
Enddo

ferase("\DADOSADV\COMIS.DBF")
dbselectarea("TRC")
dbgotop()
//COPY TO "\DADOSADV\COMIS.DBF"
Processa({||CpyS2T("\DADOSADV\COMIS.DBF","C:\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
ferase("\DADOSADV\VEND.DBF")
TRC->(DBCLOSEAREA())
mTESTE := "1;0;1;GIS"  // "EM DISCO;ATUALIZA;1 COPIA;NOME REL."
CALLCRYS("COMIS",,mTESTE)

Set SoftSeek Off
Return

// *----------------------------------------------------------------------------
Static Function AjustaSX1()
aPerg    := {}
//cPerg    := "RCOMIS"

Aadd( aPerg , { "Mes Referencia    ?" , "C" , 02 , "   "})
Aadd( aPerg , { "Ano Referencia    ?" , "C" , 04 , "   "})

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
Return Nil
  



/*
	dbSelectArea("TRB")
	RecLock("TRB",.T.)
	NOTA	 := SD2->D2_DOC
	CLIENTE	 := SA1->A1_NREDUZ
	ITEM	 := SD2->D2_ITEM
	EMISSAO	 := SD2->D2_EMISSAO
	VENDEDOR := cVend
	PRODUTO  := SD2->D2_COD
	VALOR    := mVrtotal
	MARCA    := mEmpresa
	ICMS 	 := SD2->D2_VALICM
	IPI		 := SD2->D2_VALIPI 
	PIS		 := SD2->D2_VALIMP5
	COFINS	 := SD2->D2_VALIMP6
	msUnlock()
*/

/*
ferase("\SIGAADV\SAIDA.DBF")
dbselectarea("TRB")
dbgotop()
COPY TO "\SIGAADV\SAIDA.DBF"
Processa({||CpyS2T("\SIGAADV\SAIDA.DBF","C:\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
ferase("\SIGAADV\SAIDA.DBF")
TRB->(DBCLOSEAREA())
*/
