#include "Protheus.ch"
#include "FileIO.ch"
#include "TOPCONN.CH"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ ETIQVOL  ºAutor  ³ Lucas Ývila        º Data ³  18/06/15  º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDesc.     ³ Etiqueta Volume (Térmica - ZEBRA)    º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºUso       ³ Etiqueta Volume                                            ¹±±
±±ºUso       ³                    	                                  º±±
±±ºUso       ³                                        			  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
USER FUNCTION RPCP001()
Local cAlias  := "SF2"
Private aRotina   := { { OemToAnsi("Pesquisar") , "AxPesqui",     0, 1},;
					   { OemToAnsi("Visualizar"), "AxVisual",     0, 2},;
					   { OemToAnsi("Etiqueta")  , "U_IMPETVOL()", 0, 2} }

cCadastro := OemToAnsi("Etiquetas Volume")

mBrowse(06, 01, 22, 75, cAlias)
Return(Nil)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ ETIQVOL   ºAutor  ³ Andre          º Data ³  14/06/06º      ±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDesc.     ³ Impressao da Etiqueta Volume                               º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºUso       ³                                                            º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function IMPETVOL()
Local aArea      := GetArea()

Local nMargX     := 0
Local nMargY     := 0
Local cPerg      := PadR("MTR710", Len(SX1->X1_GRUPO))
Local i
Local nP := 1
Local cAlias  := GetNextAlias()
Local oFont12 		:= TFont():New("Arial",,8,,.f.,,,,,.f.)
Local ntam := 0 
LOCAL nJ := 0 
//GeraX1(cPerg)

IF !Pergunte(cPerg,.T.)
	RETURN(NIL)
ENDIF

//PZebra(.T.)

oPrint := tMSPrinter():New("ACTEGA")   


//	oPrint:Setup()

cQuery := " "
cQuery += " select * from " + RetSQLName("SF2") + " where D_E_L_E_T_ = ' ' and F2_SERIE = '"+cvaltochar(MV_PAR01)+" ' and F2_DOC = '"+Alltrim(MV_PAR03)+" '  and F2_FILIAL = '"+xFilial("SF2")+"'  " 



cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.F.,.T.)

While  (cAlias)->(!eof()) 


	oPrint:StartPage()
	oPrint:SetLandscape()
	//oPrint:SetPaperSize(DMPAPER_ENV_C5) // 110 x 220 
	oPrint:Setup()

	dbselectarea("SF2")
	dbsetorder(1)
	dbseek((cAlias)->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO ) ,.f.)
	dbselectarea("SA1")
	dbsetorder(1)
	dbgotop()
	dbseek(xfilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,.f.)
	
	dbselectarea("SA4")
	dbsetorder(1)
	dbgotop()
	dbseek(xfilial("SA4")+SF2->F2_TRANSP,.f.)
	
    // Eliminando Impressao Etiqueta BrasPress
    //If SA4->A4_ETBPRES != "S"
	   
	   dbselectarea("SD2")
	   dbsetorder(3)
	   dbgotop()
	   dbseek(xfilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE,.f.)
	
	   for i:=1 to SF2->F2_VOLUME1
	
		oPrint:Say(nMargX+35,nMargY +57,"NF: "+SF2->F2_DOC+" Pedido:"+SD2->D2_PEDIDO 				 		 ,oFont12)  
		nMargX += 38
		ntam := mlcount(SA1->A1_NOME,35)
		For nJ := 1 to ntam
			If nTam ==  1
				oPrint:Say(nMargX+55,nMargY +57,"Nome: "+ memoline(SA1->A1_NOME,35,nJ) 		 ,oFont12) 
				nMargX += 55
			ELSE
				oPrint:Say(nMargX+38,nMargY +57, memoline(SA1->A1_NOME,35,nJ) 		 ,oFont12) 
				nMargX += 38
			ENDIF	
		NEXT
		oPrint:Say(nMargX+55,nMargY +67,"End: "+substr(sa1->a1_endent,1,30)		 ,oFont12) 
		nMargX += 55
		oPrint:Say(nMargX+55,nMargY +67,"CEP:"+trans(sa1->a1_cep,"@r 99999-999")+" "+subs(sa1->a1_mun ,1,10)+" "+sa1->a1_est	 ,oFont12) 
		nMargX += 55
		oPrint:Say(nMargX+55,nMargY +67,"Transportadora: "+substr(SA4->A4_NOME,1,30)		 ,oFont12) 
		nMargX += 55
		oPrint:Say(nMargX+55,nMargY +67,"Volume: "+strzero(nP,4,0)+"/"+strzero(SF2->F2_VOLUME1,4,0)+" Especie:"+SF2->F2_ESPECI1	 ,oFont12) 
		nP += 1
		nMargX     := 0
		nMargY     := 0
		
		If i < SF2->F2_VOLUME1
			oPrint:EndPage()
			oPrint:StartPage()
		ENDIF
	   next
	
	oPrint:Print()
(cAlias)->(DBSKIP())  
ENDDO
//PZebra(.F.)
DbCloseArea()
RestArea(aArea)
RETURN()

/*
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ GeraX1   ³ Autor ³ MICROSIGA             ³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica as perguntas incluindo-as caso nao existam        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Uso Generico.                                              ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GeraX1(cPergunta)
LOCAL cPerg := PADR(cPergunta, Len(SX1->X1_GRUPO))
LOCAL aArea    := GetArea()
LOCAL aRegs    := {}
LOCAL i :=  0
LOCAL j :=  0
Private aHelpPor := {}
Private aHelpSpa := {}
Private aHelpEng := {}
dbSelectArea("SX1")
dbSetOrder(1)

	IF "IMPETVOL  " $ cPerg
		AADD(aRegs,{cPerg,"01","Serie     ?","","","mv_ch1","C",06,00,00,"G",""          ,"mv_par01","",   "","","","","",   "","","","","","","","","","","","","","","","","","","SF2","","",""})
		AADD(aRegs,{cPerg,"02","Nota Fiscal   ?","","","mv_ch2","C",06,00,00,"G","NaoVazio()","mv_par02","",   "","","","","",   "","","","","","","","","","","","","","","","","","","SF2","","",""})

		For i:=1 to Len(aRegs)
			If !dbSeek(cPerg+aRegs[i,2])
				RecLock("SX1",.T.)
				For j:=1 to FCount()
					If j <= Len(aRegs[i])
						FieldPut(j,aRegs[i,j])
					Endif
				Next
				MsUnlock()
			endif
		Next
		Elseif "PMETR1   " $ cPerg
		AADD(aRegs,{cPerg,"01","Porta ?             ","","","mv_ch1","N",01,0,0,"C","","mv_par01","LPT1","","","","","LPT2","","","","","COM1","","","","","COM2","","","","","","","","","","","",".MAETR101."})
		AADD(aRegs,{cPerg,"02","Impressora ?        ","","","mv_ch2","N",01,0,0,"C","","mv_par02","S600","","","","","",    "","","","","",    "","","","","",    "","","","","","","","","","","",".MAETR102."})
		dbSelectArea("SX1")
		dbSetOrder(1)
		For i:=1 to Len(aRegs)
			If !dbSeek(cPerg+aRegs[i,2])
				RecLock("SX1",.T.)
				For j:=1 to FCount()
					If j <= Len(aRegs[i])
						FieldPut(j,aRegs[i,j])
					Endif
				Next
				MsUnlock()
				aHelpPor := {} ; aHelpSpa := {} ; aHelpEng := {}
				IF i==1
					AADD(aHelpPor,"Selecione a impressora                    ")
				ELSEIF i==2
					AADD(aHelpPor,"Selecione a porta onde a impressora está  ")
					AADD(aHelpPor,"conectada                                 ")
				ENDIF
				PutSX1Help("P."+cPerg+strzero(i,2)+".",aHelpPor,aHelpEng,aHelpSpa)
			endif
		Next
	ENDIF

RestArea(aArea)
Return(nil)
*/
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ PZebra   ºAutor  ³Microsiga           º Data ³  28/08/05   º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDesc.     ³ Ativar/Desativa zebra                                      º±±
±±ÌÝÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºUso       ³ Ativar/Desativar impressora Zebra                          º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºParametros³ lAcao    .T.-Ativa, .F.-Desativa                           º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
STATIC FUNCTION PZebra(lAcao)
LOCAL aPorta     := {}
LOCAL cPorta     := ""
LOCAL aImp       := {}
LOCAL cImp       := ""
Local cEtPerg    := PadR("PMETR1    ", Len(SX1->X1_GRUPO))

GeraX1( cEtPerg )
	IF lAcao
		Pergunte(cEtPerg,.T.)
		aPorta    := RetBoxX1(cEtPerg,"01")
		cPorta    := aPorta[MV_PAR01]
		aImp    := RetBoxX1(cEtPerg,"02")
		cImp    := aImp[MV_PAR02]
		MSCBPRINTER(cImp, cPorta, , ,.F., , , , , , ) // configura impressora
		MSCBCHKSTATUS(.F.) // Nao checar impressoa
	ELSE
		MSCBCLOSEPRINTER() //Finaliza a conexão com a impressora
	ENDIF
Return Nil

/*
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ RetBoxX1 ³ Autor ³ Choite                ³ Data ³ 28/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao generica para retornar em Array do Box do SX1       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RetBoxX1(cPerg,cOrdem)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Caracter que contem a pergunta a ser pesquisada    ³±±
±±³          ³ ExpC1 = Caracter que contem a ordem da pergunta            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´*/
STATIC Function RetBoxX1(cPerg,cOrdem)
LOCAL aRet        := {}
LOCAL cCampo    := ""
LOCAL cCntCpo    := 0

SX1->(dbSetOrder(1))
	If SX1->(dbSeek(cPerg+cOrdem)) .And. SX1->X1_GSC=="C"
		WHILE .T.
			cCntCpo++
			cCampo := "X1_DEF"+strzero(cCntCpo,2)
				IF Type('"'+cCampo+'"')=="U"
					EXIT
				ENDIF
			xConteudo := alltrim(SX1->(&cCampo))
				IF !empty(xConteudo)
					aadd(aRet,xConteudo)
				ELSE
					EXIT
				ENDIF
		END
	Endif
Return(aRet)

