#include 'rwmake.ch'
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ SF1100i ³ Autor ³ Tanimoto              ³ Data ³ 23.06.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Ponto de entrada que ira trazer uma tela para preenchimen- ³±±
±±³          ³ to de dados adicionais da NF de entrada.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico LMT                                             ³±±
±±³          ³ Para ser preencimento de campos da nota fiscal de entrada  ³±±
±±³          ³ quando formulario proprio e que nao sao apresentados na    ³±±
±±³          ³ tela padrao da rotina MATA100() e tmb para notas de impor- ³±±
±±³          ³ tacao que necessita de dados da DI para transimissao SEFAZ ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/  
 
User Function SF1100I()
Local _aAreaSD1	:= SD1->( GetArea() )
Local _cAlias 	:=	Alias()
Local _nOrder 	:=	IndexOrd()
Local _nRecno 	:=	Recno()
//Variaveis para preencher e gravar na nota
Local _mObs		:=	space(250)
Local _cEspecie	:= Space(10)
Local _nVolume	:= 0
Local _cTransp	:= Space(6)
Local _cPlaca	:= Space(9)
Local _nPesoL	:= 0
Local _nPesoB	:= 0
Local lContinua	:= .F.
Local aSalva
Local nValFob  	:= 0
Local nValII    := 0
 
Local cFornece  := M->CA100FOR
Local cNota		:= M->CNFISCAL
Local cSerie   	:= M->CSERIE
Local cTipo		:= M->CTIPO
Local cLoja		:= M->CLOJA
//Objeto da tela da nota fiscal
Private oDlgNFE

_lAutoEx := .T.//(AllTrim(FunName())=="MATA103" .OR. AllTrim(FunName())=="MATA119")

dbSelectArea(_cAlias)
dbSetOrder(_nOrder)

If _lAutoEx .AND. SF1->F1_FORMUL= "S"
	cDoc := cNfiscal              
	//Tela para Preencher mais campos para nota fiscal diversas de entrada
	@ 010,020 To 400,400 Dialog oDlgNFE Title OemToAnsi( "Informacoes Adicionais para a NFE " + alltrim( SF1->F1_DOC ) )	
	@ 010,010 Say OemToAnsi("Mensagem para Nota" )
	@ 010,080 Get _mObs Picture "@S40"	
	@ 021,010 Say OemToAnsi("Transportadora" )   
	@ 021,080 Get _cTransp Picture "@!" F3 "SA4"	
	@ 032,010 Say OemToAnsi("Plcaca" )   
	@ 032,080 Get _cPlaca Picture "@! AAA-9999"
	@ 043,010 Say OemToAnsi("Especie Volume" )   
	@ 043,080 Get _cEspecie Picture "@!" Size 53,09
	@ 054,010 Say OemToAnsi("Volumes" )   
	@ 054,080 Get _nVolume Picture "@e 999,999,999.99" Size 53,09
	@ 065,010 Say OemToAnsi("Peso Bruto" )   
	@ 065,080 Get _nPesoB Picture "@e 999,999,999.99" Size 53,09
	@ 076,010 Say OemToAnsi("Peso Liquido" )   
	@ 076,080 Get _nPesoL Picture "@e 999,999,999.99" Size 53,09
//	@ 087,010 Say OemToAnsi("Valor CIF") 	
//	@ 087,080 Get nValCIF  Picture "999,999,999.99" Size 53,09
//	@ 098,010 Say OemToAnsi("Valor FOB") 	
//	@ 098,080 Get nValFob  Picture "999,999,999.99" Size 53,09
//	@ 109,010 Say OemToAnsi("Imp Importação") 
//	@ 109,080 Get nValII   Picture "999,999,999.99" Size 53,09
	@ 100,080 BMPBUTTON TYPE 01 ACTION (lContinua:=.T.,oDlgNFE:End())	//sai e grava dos dados
	@ 100,120 BMPBUTTON TYPE 02 ACTION (lContinua:=.F.,oDlgNFE:End())	//sai sem gravar dados
	Activate Dialog oDlgNFE CENTERED Valid()
	If lContinua
		dbSelectArea( "SF1" )
		RecLock( "SF1" , .F. )
		SF1->F1_MENNOTA		:=	_mObs 
		SF1->F1_ESPECI1		:=	_cEspecie
		SF1->F1_VOLUME1		:=	_nVolume
		SF1->F1_TRANSP		:=	_cTransp
		SF1->F1_PLACA		:=	StrTran(_cPlaca,"-","") //_cPlaca
		SF1->F1_PLIQUI		:=	_nPesoL
		SF1->F1_PBRUTO		:=	_nPesoB
		MsUnLock()
	EndIf
    //Abre tela para preenchimento de dados da importacao no programa CPOTELAIMP() localizada em pontos de entrada
	If Upper(Alltrim(SF1->F1_ESPECIE))=="SPED"
		If SA2->(dbseek(xFilial("SA2")+SF1->(F1_FORNECE+F1_LOJA)))
		 	If SA2->A2_EST=="EX"
		 		U_CpoTelaImp() 
		 	Endif 
		Endif 	 
	Endif 
End

Return(.T.)