#INCLUDE "rwmake.ch"

// Rotina		: MALA01
// Descrição	: Relatório Mala Direta Cliente
// Data			: 26/06/06
// Autor        : Daniel Gondran

User Function MALA01()

// mv_par01 - Cliente Inicial
// mv_par02 - Cliente Final
// mv_par03 - Contato Inicial
// mv_par04 - Contato Final

//cPerg := "MALA01"
 cPerg    := PadR( 'MALA01' , Len( SX1->X1_GRUPO ) )
AjustaSX1()
Pergunte(cPerg,.F.)

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Mala Direta Cliente"
@ 70,080 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
@ 70,118 BMPBUTTON TYPE 1 ACTION OkProc()
@ 70,156 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
@ 23,14 SAY "Este programa tem por objetivo imprimir as etiquetas de" size 200,10
@ 33,14 SAY "endereçamento dos clientes / contatos selecionados " size 200,10
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
aAdd(aStru,{"RAZAO"      ,"C",60,0})
aAdd(aStru,{"ENDERECO"   ,"C",40,0})
aAdd(aStru,{"BCE"        ,"C",40,0})
aAdd(aStru,{"CEP"        ,"C",20,0})
aAdd(aStru,{"CONTATO"    ,"C",60,0})
aAdd(aStru,{"FUNCAO"     ,"C",60,0})
aAdd(aStru,{"DEPTO"      ,"C",60,0})
aAdd(aStru,{"INFO"       ,"C",60,0})

oTemptable := FWTemporaryTable():New( "TRC")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"RAZAO"} )
oTempTable:Create()
/*
cArq := CriaTrab(aStru,.T.)
dbUseArea(.T.,,cArq,"TRC",.T.)
cInd := CriaTrab(NIL,.F.)
IndRegua("TRC",cInd,"RAZAO",,,"Selecionando Registros...")
*/
dbSelectArea("SA1")
dbSetOrder(1)

dbselectarea("SA1")
dbSeek(xFilial("SA1") + mv_par01,.T.)
ProcRegua(LastRec())
DO WHILE !EOF() .AND. SA1->A1_FILIAL == xFilial("SA1") .and. SA1->A1_COD <= mv_par02 
	IncProc()
	For kkk := mv_par03 to mv_par04
		cCampo1	:= "SA1->A1_CONT" + AllTrim(Str(kkk,2))	
		cCampo2	:= "SA1->A1_FUN" + AllTrim(Str(kkk,2))
		cCampo3 := "SA1->A1_DEP" + AllTrim(Str(kkk,2))
		cCampo4 := "SA1->A1_INFO" + AllTrim(Str(kkk,2))
		If Empty(&(cCampo1))
			Alert("Cliente " + AllTrim(SA1->A1_NOME) + " (" + SA1->A1_COD + ") Sem contato " + Str(kkk,2) + ". Não será impresso!")
		Else
			dbSelectArea("TRC")
			RecLock( "TRC" , .T.)
			RAZAO	:= SA1->A1_NOME
			ENDERECO:= Trim(SA1->A1_END)
			BCE	 	:= TRIM(SA1->A1_BAIRRO) + IIF(EMPTY(SA1->A1_BAIRRO),""," - ") + Trim(SA1->A1_MUN) + " - " + SA1->A1_EST
			CEP		:= Left(SA1->A1_CEP,5) + "-" + Right(SA1->A1_CEP,3)
			IF MV_PAR05 == 1
				CONTATO	:= &(cCampo1)
			ENDIF           
			IF MV_PAR06 == 1			
				FUNCAO	:= &(cCampo2)
			ENDIF
			IF MV_PAR07 == 1			
				DEPTO	:= &(cCampo3)
			ENDIF
			IF MV_PAR08 == 1			
				INFO 	:= &(cCampo4)
			ENDIF
			TRC->( MsUnLock() )
		Endif
	Next
	dbSelectArea("SA1")
	dbSkip()
Enddo

ferase("\DADOSADV\MALAC.DBF")
dbselectarea("TRC")
dbgotop()
//COPY TO "\DADOSADV\MALAC.DBF" VIA "DBFCDXADS"
Processa({||CpyS2T("\DADOSADV\MALAC.DBF","C:\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
ferase("\DADOSADV\MALAC.DBF")
TRC->(DBCLOSEAREA())
mTESTE := "1;0;1;GIS"  // "EM DISCO;ATUALIZA;1 COPIA;NOME REL."
CALLCRYS("MALAC",,mTESTE)
Return

// *----------------------------------------------------------------------------
Static Function AjustaSX1()
aPerg    := {}
//cPerg    := "MALA01"

Aadd( aPerg , { "Cliente Inicial     ?" , "C" , 06 , "SA1"})
Aadd( aPerg , { "Cliente Final       ?" , "C" , 06 , "SA1"})
Aadd( aPerg , { "Contato Inicial     ?" , "N" , 02 , "   "})
Aadd( aPerg , { "Contato Final       ?" , "N" , 02 , "   "})
Aadd( aPerg , { "Imprime Contato     ?" , "N" , 01 , "   "})
Aadd( aPerg , { "Imprime Funcao      ?" , "N" , 01 , "   "})
Aadd( aPerg , { "Imprime Depto       ?" , "N" , 01 , "   "})
Aadd( aPerg , { "Imprime Info        ?" , "N" , 01 , "   "})


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
		If nxx >= 5
			SX1->X1_GSC   := "C"
			SX1->X1_DEF01 := "Sim" 
			SX1->X1_DEF02 := "Nao"
		Endif		
		SX1->(msUnlock())
	EndIf		
Next nXX
Return Nil
