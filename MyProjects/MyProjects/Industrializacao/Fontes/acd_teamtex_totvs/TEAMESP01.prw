#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH" 
#INCLUDE "TOPCONN.CH"

//---------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TEAMESP01
MÓDULO PARA IMPRESSÃO DAS ETIQUETAS DE:
VOLUME PRIAMRIO:	- Chama Ponto de Entrada Padrão: IMG05 
VOLUME OFICIAL:		- Chama Ponto de Entrada Padrão: IMG05OFI  
VOLUME EMBARQUE:	- Chama Ponto de Entrada Padrão: IMG05OFI 
OUTRAS:				- Chama a Função ETITAVUL()	- Tratamento e Imagem da Etiqueta Avulsa
A partir da ORDEM DE SEPARAÇÃO: BOTÃO adicionado em Outra Ações.
PONTO DE ENTRADA para adicionar o Botão: ACD100M  -  Chamada no Ponto de Entrada: Aadd(aRotina,{"Etiquetas de Volumes","U_TEAMESP01()",0,2}) 
@author Totvs - Luiz Enrique de Araujo
@since 22/08/2018
@version 1.0
/*/  
//----------------------------------------------------------------------------------------------------------------------------------------------
User Function TEAMESP01()

Local cChave	:= ""
Local cNome		:= ""  
Local nTotVol	:= 0 
Local nQtdEmb	:= 0 
Local nVolTotal := 0
Local nx		:= 0
Local lRet		:= .t. 

Private nRadTipEti:= 1 
Private oRadTipEti		//Modelos das Etiqueta 
Private cMarca := GetMark()
Private aItens := {} 

If CB7->(EOF())
	MsgAlert('Informe uma Ordem de Separação.')
	Return
Endif

//Posiciona no Itens Liberados
SC9->(DBSetOrder(1)) //FILIAL+PEDIDO - C9_LOTECTL
SC9->(DbSeek(xFilial("SC9")+CB7->CB7_PEDIDO))
	
While SC9->(!Eof() .And. C9_FILIAL+C9_PEDIDO ==xFilial("SC9")+CB7->CB7_PEDIDO)   	

	nQtdEmb:= Posicione("SB1",1,xFilial("SB1")+SC9->C9_PRODUTO,"B1_QE") 
	cNome:= Alltrim(Posicione("SB1",1,xFilial("SB1")+SC9->C9_PRODUTO,"B1_DESC")) 
		
	If nQtdEmb == Nil .Or. nQtdEmb == 0 
		nQtdEmb:= 1
	Endif
	
	cMsg:= ""
	lresto:=.f.	
	If Int(SC9->C9_QTDLIB / nQtdEmb) <> SC9->C9_QTDLIB / nQtdEmb			
		cMsg:= "A quantidade de Itens do Produto: " + Alltrim(SC9->C9_PRODUTO) 		+ CRLF
		cMsg+= "Não é Multipla da quantidade por Embalagem: " + Strzero(nQtdEmb,4)	+ CRLF 
		cMsg+= "O ultimo Volume, não será um Volume Completo."						+ CRLF + CRLF
		cMsg+= "Confirma Gerar os Volumes nesta condição?"										
		If MsgYesNo(cMsg,"A T E N Ç Ã O")
			lresto:= .t.
		Else
			lRet:= .f.
			Exit
		Endif 
	Endif
   				
	nTotVol:= SC9->C9_QTDLIB / nQtdEmb   		
	For nx:= 1 to nTotVol 
		SC9->(aadd(aItens,{C9_PRODUTO,cNome,C9_LOTECTL,nQtdEmb}))  
	Next
	If lresto
		SC9->(aadd(aItens,{C9_PRODUTO,cNome,C9_LOTECTL,1}))
	Endif 
			 	 	 			
	SC9->(DbSkip())	
	
Enddo

If lRet 
	ASORT(aItens,,, { |x, y| x[1] < y[1] })
	MarcaEti(aItens)
Endif

Return 

//---------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MarcaEti
Função que apresenta as Opções do Modelos da Etiqueta e as Próprias Etiquetas a serem Impressas
@author Totvs - Luiz Enrique de Araujo
@since 08/08/2018
@version 1.0
/*/  
//----------------------------------------------------------------------------------------------------------------------------------------------
Static Function MarcaEti(aItens)

Local aCpoVol:=	{{ "OK"		,, "OK"			,"@!"},;
				{ "PRODUTO"	,, "Produto"	,"@!"},;
				{ "NOME"	,, "Nome"		,"@!"},;				  
				{ "LOTE"	,, "Lote"		,"@!"},;
				{ "ETIQUETA",, "Etiqueta"	,"@!"}}                        
Local oDlg
Local oVols 
Local oFila 
Local cFila		:= Space(06) 
Local oNomFila
Local cNomFila	:= ""
Local lInverte:=.F.
Local aButtons:= {} 
Local oPanB1			//Painel para Modelos das Etiqueta 
Local oPanB2 			//Painel para apresentação das Etiquetas disponíveis				  		

//MV_IACD01 FILA PARA EXPEDIÇÃO
cFila:= SuperGetMV("MV_IACD01",,Space(06)) 
cFila:= Padr(cFila,TamSX3("CB5_CODIGO")[1])

CB5->(dbsetOrder(1))
If CB5->(dbSeek(xFilial()+cFila)) 
	cNomFila:=  CB5->CB5_DESCRI
Endif  

CriaArqs(aItens)

//Adiciona botoes na enchoicebar:
aadd(aButtons,{"PESQUISA",{||PesqVol(oVols)},"Pesquisa" })
  
DEFINE MSDIALOG oDlg TITLE "GERADOR DE ETIQUETA - Ordem de Separacao: " + Alltrim(CB7->CB7_ORDSEP) FROM 0,0 TO 460,850 PIXEL OF oMainWnd 

	//Painel para Escolha do Modelo da Etiqueta
	oPanB1:=TPanel():New(1,1,"   Modelo:",oDlg,/*[aoFont]*/,,,/*CorTexto*/,/*CLR_BLUE*/,040,060,.F.,.T.) 
	oPanB1:ALIGN:= CONTROL_ALIGN_BOTTOM	// CONTROL_ALIGN_TOP	//CONTROL_ALIGN_RIGHT
	@ 010,010 RADIO oRadTipEti VAR nRadTipEti ITEMS "Etiqueta de Volume Oficial", "Etiqueta de Embarque", "Outras" SIZE 100,050 OF oPanB1 PIXEL
	oRadTipEti:bChange := {|| TrataEscolha()}   
	
	@ 043, 010 SAY   "Local de Impressão:" OF oPanB1 PIXEL
	@ 042, 060 MSGET oFila 		VAR cFila 		SIZE 050,07  OF oPanB1 PIXEL F3 'CB5' VALID LocalImp(cFila,oNomFila,@cNomFila)
	@ 042, 130 MSGET oNomFila 	VAR cNomFila 	SIZE 250,07  OF oPanB1 PIXEL  When .F.
   	
	//Painel para Escolha das Etiquetas
	oPanB2	:=TPanel():New(1,1,,oDlg,/*[aoFont]*/,,,/*CorTexto*/,CLR_RED,100,100,.F.,.F.) 
	oPanB2 :ALIGN:= CONTROL_ALIGN_ALLCLIENT	//CONTROL_ALIGN_LEFT	// CONTROL_ALIGN_TOP  
   	
	oVols:=MsSelect():New("VOLUME","OK",,aCpoVol,@lInverte,@cMarca,{008,133,120,275},,,oPanB2)
	oVols:oBrowse:lHasMark	   := .T.
	oVols:oBrowse:lCanAllMark 	:= .T.
	oVols:bAval               	:= {|| AtuMark(oVols,.F.,oDlg)} //-- Marca / Desmarca o Item posicionado
	oVols:oBrowse:bAllMark    	:= {|| AtuMark(oVols,.T.,oDlg)} //-- Marca / Desmarca todos os Itens
	oVols:oBrowse:Align       	:= CONTROL_ALIGN_ALLCLIENT 

ACTIVATE DIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| MsgRun("Imprimindo volumes",,{|| ImpEtiq(cFila)}),/*oDlg:End()*/},{|| oDlg:End()},,aButtons)

VOLUME->(DbCloseArea())

Return

//---------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TrataEscolha
Função que trata a escolha das Etiquetas 
@author Totvs - Luiz Enrique de Araujo
@since 08/08/2018
@version 1.0
/*/  
//----------------------------------------------------------------------------------------------------------------------------------------------
Static Function TrataEscolha()

Local cmsg:= "A T E N Ç Ã O " + CRLF + CRLF 
	 
If nRadTipEti ==  2 .And. ! GetMv("MV_CBPE006",.F., .F.)
	cmsg+= "O Parametro do ACD: MV_CBPE006, não esta habilitado para" + CRLF  
	cmsg+= "gravar a Nota Fiscal na Ordem de Separação." + CRLF + CRLF
	cmsg+= "A Nota Fiscal não será Impressa na Etiqueta de Embarque."  
	MsgStop(cmsg) 
Endif

Return

//---------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtuMark
Função que MARCA ou DESMARCA as Etiquetas a serem Impressas
@author Totvs - Luiz Enrique de Araujo
@since 08/08/2018
@version 1.0
/*/  
//----------------------------------------------------------------------------------------------------------------------------------------------
Static Function AtuMark(oMark, lMarkAll, oDlgPrinc) 

Local   lMarcaAtu  := VOLUME->( IsMark( 'OK', ThisMark(), ThisInv() ) )
Local   cMarcaAtual

Private nRecAtu    := VOLUME->(Recno())
           
CursorWait()   

cMarcaAtual := "  "
If !lMarcaAtu
	cMarcaAtual := cMark := ThisMark()
Endif

If !lMarkAll //-- Somente o item posicionado
	RecLock("VOLUME",.F.)
	VOLUME->OK := cMarcaAtual
	VOLUME->(MsUnLock())	 
Else //Todos os itens
	VOLUME->(DbGoTop())
	While VOLUME->(!Eof())
		RecLock("VOLUME",.F.)
		VOLUME->OK := cMarcaAtual
		VOLUME->(MsUnLock())
		VOLUME->(DbSkip())
	Enddo
	VOLUME->(DbGoTop())
Endif

oMark:oBrowse:DrawSelect()
oMark:oBrowse:Refresh()
CursorArrow()

Return


//---------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtuMark
Função que IMPRIME Etiquetas Selecionadas
@author Totvs - Luiz Enrique de Araujo
@since 08/08/2018
@version 1.0
/*/  
//----------------------------------------------------------------------------------------------------------------------------------------------
Static Function ImpEtiq(cFila)

Local lEtiFim	:= .f. 
Local lImp		:= .f.
Local lret		:= .t. 

//Analisa se Exitem Etiquetas de Volumes a Serem Impressas
If VOLUME->(Eof()) .And. (nRadTipEti ==1 .Or. nRadTipEti == 2)
	CBAlert('Não exite VOLUME a ser Impresso!')
	Return
Endif 

If Empty(CB7->CB7_NOTA) .And. nRadTipEti == 2 // Não Faturado e solicita Etiqueta de Embarque
	CBAlert("Impossível Imprimir Etiqueta de Embarque. Pedido Não Faturado") 
 	Return .F.  
Endif 

//Analisa se Exitem Etiquetas de Volumes Marcadas para Impressão 
VOLUME->(DbGoTop())
While VOLUME->(!Eof()) 
	If VOLUME->(IsMark("OK",ThisMark(),ThisInv()))	
		lImp:= .t.
		Exit
	Endif
	VOLUME->(DbSkip())	
Enddo

If !lImp .And. (nRadTipEti ==1 .Or. nRadTipEti == 2)
	CBAlert('VOLUMES não selecionados para Impressão!')
	Return
Endif 
 
IF !CB5SetImp(Alltrim(cFila),IsTelNet())
	CBAlert('Codigo do tipo de impressao invalido!')
	Return
Endif

If nRadTipEti == 1 .Or. nRadTipEti == 2		//ETIQUETA DE VOLUME OFICIAL ou ETIQUETA DE EMBARQUE

	VOLUME->(DbGoTop())
	lret:= .t.	
	While VOLUME->(!Eof()) .And. lret
		If !VOLUME->(IsMark("OK",ThisMark(),ThisInv()))	
			VOLUME->(DbSkip())
			Loop
		Endif	
		lret:= ExecBlock("IMG05OFI",,,{Val(Right(VOLUME->ETIQUETA,3)),Val(Left(VOLUME->ETIQUETA,3)),""})	
		VOLUME->(DbSkip())	
	Enddo   	
	
ElseIf nRadTipEti == 3	//OUTRAS ETIQUETAS 

	If !FunName() = "ETITAVUL"    
		CBAlert('Não exite Modelo de Etiqueta!')
   		Return
	Endif 
	
	U_ETITAVUL()	//Tratamento e Imagem da Etiqueta Avulsa
	 
Endif

MSCBCLOSEPRINTER() 

CBAlert('Impressão Concluida!')

Return


//---------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtuMark
Função que PESQUISA VOLUME
@author Totvs - Luiz Enrique de Araujo
@since 08/08/2018
@version 1.0
/*/  
//----------------------------------------------------------------------------------------------------------------------------------------------
Static Function PesqVol(oVols)  

Local oDlgPar
Local oSBr
Local cVolPes:= Space(TamSx3("B1_COD")[1]) 
Local oQtde

oDlgPar:= MsDialog():New( 26, 43, 140, 482, "PESQUISA DE PRODUTO",,,.F.,,,,,,.T.,,,.F.)
oDlgPar:lEscClose := .F.
oSbr   := TScrollBox():New(oDlgPar, 6, 7, 28, 206,.T.,.F.,.T.)

oDlgPar:SetWallPaper("FUNDOBARRA")
cVolPes := Space(10)

TSay():New( 06, 10, {|| "PRODUTO:"},oSbr,,, .F., .F., .F., .T.,,,,, .F., .F., .F., .F., .F. )
oQtde := TGet():New( 05, 35, { | u | If( PCount() == 0, cVolPes, cVolPes := u ) },oSbr, 110, 15, "@!",,,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F. ,,"cVolPes",,,, )
SButton():New( 038, 187,1, {|| oDlgPar:End()}, oDlgPar, .T.,,)
oDlgPar:Activate( oDlgPar:bLClicked, oDlgPar:bMoved, oDlgPar:bPainted, .T.,,,, oDlgPar:bRClicked, )

VOLUME->(DbSeek(cVolPes,.T.))  

oVols:oBrowse:Refresh()

Return

//---------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtuMark
Função que Monta Estrutura do arquivo temporario (Volumes CB6)
@author Totvs - Luiz Enrique de Araujo
@since 08/08/2018
@version 1.0
/*/  
//----------------------------------------------------------------------------------------------------------------------------------------------
Static Function CriaArqs(aItens)

Local cArq
Local aStru	:=	{}
Local nX

aStru := {}
AADD(aStru,{"OK"		,"C",02,0})
AADD(aStru,{"PRODUTO"	,"C",15,0})
AADD(aStru,{"NOME"		,"C",30,0}) 
AADD(aStru,{"LOTE"		,"C",10,0})
AADD(aStru,{"ETIQUETA"	,"C",07,0}) 

cArq := Criatrab(aStru,.T.)  
cInd1 := Left( cArq, 7 ) + "1"
DbUseArea(.t.,,cArq,"VOLUME")
IndRegua( "VOLUME", cInd1, "PRODUTO", , , "Gerando Indice Temporario...")

For nX:=1 to Len(aItens)
	Reclock("VOLUME",.T.)
	VOLUME->OK			:= "OK"
	VOLUME->PRODUTO		:= aItens[nX,01] 
	VOLUME->NOME		:= aItens[nX,02]
	VOLUME->LOTE		:= aItens[nX,03]
	VOLUME->ETIQUETA	:= Strzero(nX,3) + "/" +Strzero(Len(aItens),3)
	VOLUME->(MsUnLock())
Next
VOLUME->(DbGoTop())

Return 

//-----------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LocalImp
Verifica se local de impressão é valido
@author Luiz Enrique de Araujo
@since 21/06/2018
@version 1.0
/*/  
Static Function LocalImp (CodLocal,oNomFila,cNomFila)
 	     
CB5->(dbsetOrder(1))
If !CB5->(dbSeek(xFilial()+CodLocal)) 
	CBAlert("Local de Impressão Inválido")
	Return .F.
Endif  

cNomFila:= Alltrim(CB5->CB5_DESCRI) 
oNomFila:Refresh()
 
Return .T.   

