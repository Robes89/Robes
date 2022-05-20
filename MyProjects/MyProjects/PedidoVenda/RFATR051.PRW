#INCLUDE "RWMAKE.CH"
#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#include "topconn.ch"
/*
Descri??o ³Impressao do Pedido de Vendas  - TmsPrinter               
*/
User Function RFATR05()
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    LOCAL oDlg := NIL
    LOCAL cString	:= "SC5"
    PRIVATE titulo 	:= ""
    PRIVATE nLastKey:= 0
    PRIVATE cPerg	:= "MTR730"
    PRIVATE nomeProg:= FunName()
    Private nTotal	:= 0
    Private nSubTot	:= 0
 
    AjustaSx1(cPerg)
    If ! Pergunte(cPerg,.T.)
        Return
    Endif
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros					  		³
//³ mv_par01				// Numero da PT                   		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    wnrel := FunName()            //Nome Default do relatorio em Disco
 
    PRIVATE cTitulo := "Impressão do Pedido de Vendas"
    PRIVATE oPrn    := NIL
    PRIVATE oFont1  := NIL
    PRIVATE oFont2  := NIL
    PRIVATE oFont3  := NIL
    PRIVATE oFont4  := NIL
    PRIVATE oFont5  := NIL
    PRIVATE oFont6  := NIL
    Private nLastKey := 0
    Private nLin := 1650 // Linha de inicio da impressao das clausulas contratuais
 
    DEFINE FONT oFont1 NAME "Times New Roman" SIZE 0,20 BOLD  OF oPrn
    DEFINE FONT oFont2 NAME "Times New Roman" SIZE 0,14 BOLD OF oPrn
    DEFINE FONT oFont3 NAME "Times New Roman" SIZE 0,14 OF oPrn
    DEFINE FONT oFont4 NAME "Times New Roman" SIZE 0,14 ITALIC OF oPrn
    DEFINE FONT oFont5 NAME "Times New Roman" SIZE 0,14 OF oPrn
    DEFINE FONT oFont6 NAME "Courier New" BOLD
 
    oFont08	 := TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
    oFont08N := TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)
    oFont10	 := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
    oFont11  := TFont():New("Arial",11,11,,.F.,,,,.T.,.F.)
    oFont14	 := TFont():New("Arial",14,14,,.F.,,,,.T.,.F.)
    oFont16	 := TFont():New("Arial",16,16,,.F.,,,,.T.,.F.)
    oFont10N := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
    oFont12  := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
    oFont12N := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
    oFont16N := TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)
    oFont14N := TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)
    oFont06	 := TFont():New("Arial",06,06,,.F.,,,,.T.,.F.)
    oFont06N := TFont():New("Arial",06,06,,.T.,,,,.T.,.F.)
    oFont20  := TFont():New("Arial",20,20,,.T.,,,,.T.,.F.)
    oFont22  := TFont():New("Arial",22,22,,.T.,,,,.T.,.F.)
    oFont24  := TFont():New("Arial",24,24,,.T.,,,,.T.,.F.)
    oFont26  := TFont():New("Arial",26,26,,.T.,,,,.T.,.F.)
    oFont28  := TFont():New("Arial",28,28,,.T.,,,,.T.,.F.)

 
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela de Entrada de Dados - Parametros                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    nLastKey  := IIf(LastKey() == 27,27,nLastKey)
 
    If nLastKey == 27
        Return
    Endif
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio do lay-out / impressao                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 
    oPrn := TMSPrinter():New(cTitulo)
    oPrn:Setup()
    oPrn:SetPortrait()//SetPortrait() //SetLansCape()
    oPrn:StartPage()
    Imprimir()
    oPrn:EndPage()
    oPrn:End()
 
    DEFINE MSDIALOG oDlg FROM 264,182 TO 441,613 TITLE cTitulo OF oDlg PIXEL
    @ 004,010 TO 082,157 LABEL "" OF oDlg PIXEL
 
    @ 015,017 SAY "Esta rotina tem por objetivo imprimir"	OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE
    @ 030,017 SAY "o impresso customizado:"					OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE
    @ 045,017 SAY "Pedido de Venda" 						OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE
 
    @ 06,167 BUTTON "&Imprime" 		SIZE 036,012 ACTION oPrn:Print()   	OF oDlg PIXEL
    @ 28,167 BUTTON "Pre&view" 		SIZE 036,012 ACTION oPrn:Preview() 	OF oDlg PIXEL
    @ 49,167 BUTTON "Sai&r"    		SIZE 036,012 ACTION oDlg:End()     	OF oDlg PIXEL
 
    ACTIVATE MSDIALOG oDlg CENTERED
 
    oPrn:End()
 
 
Return
 
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçào ¦ Impressao Pedido de Vendas   					          ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ TEAMTEX                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
STATIC FUNCTION Imprimir()
 
    Orcamento()
    Ms_Flush()
Return
 
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçào ¦ Impressao 										          ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ TEAMTEX                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
STATIC FUNCTION Orcamento()
    Private aMeses := {"Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"}
//cDia := SubStr(DtoS(dDataBase),7,2)
//cMes := SubStr(DtoS(dDataBase),5,2)
//cAno := SubStr(DtoS(dDataBase),1,4)
//cMesExt := MesExtenso(Month(dDataBase))
//cDataImpressao := cDia+" de "+cMesExt+" de "+cAno
 
//cPercICMS := GetMv("MV_ESTICM")
 
    dbSelectArea("SC5")
    dbSetOrder(01)
    dbSeek(mv_par03+mv_par01,.t.)
    While !Eof() .And. SC5->C5_NUM >= mv_par01 .and. SC5->C5_NUM <= mv_par02
        oPrn:StartPage()
 
        oPrn:Box(0099,0049,0339,2299)
        oPrn:Box(0100,0050,0340,2300)
        oPrn:Box(0101,0051,0341,2301)
	
        dbSelectArea("SA1")
        dbSetOrder(01)
        dbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
	
        dbSelectArea("SA4")
        dbSetOrder(01)
        dbSeek(xFilial("SA4")+SC5->C5_TRANSP)
	
        dbSelectArea("SC6")
        dbSetOrder(01)
        dbSeek(xFilial("SC6")+SC5->C5_NUM)
	
        dbSelectArea("SC9")
        dbSetOrder(01)
        dbSeek(xFilial("SC9")+SC9->C9_PEDIDO)

//-----1 LINHA------------------------------------------------------------------------------------------------------------------------------------------//

        oPrn:Say(0150,0100, "Pedido Nº",oFont12)
        oPrn:Say(0200,0100,OemToAnsi(SC5->C5_NUM),oFont26)
	
        oPrn:Say(0150,1700,"Data",oFont12)
        cData:=    substr(DtoS(SC5->C5_EMISSAO),7,2)+'-'+aMeses[val(substr(DtoS(SC5->C5_EMISSAO),5,2))]+'-'+substr(DtoS(SC5->C5_EMISSAO),1,4)
        oPrn:Say(0200,1700,cData,oFont26)
	           	
//-----2 LINHA------------------------------------------------------------------------------------------------------------------------------------------//
    
        oPrn:Box(0339,0049,0549,2299)
        oPrn:Box(0340,0050,0550,2300)
        oPrn:Box(0341,0051,0551,2301)
        oPrn:Say(0350,0100,"Nome",oFont12)
        oPrn:Say(0400,0100,SUBSTR(SA1->A1_NOME,1,35),oFont26)

//-----3 LINHA------------------------------------------------------------------------------------------------------------------------------------------//

        oPrn:Box(0549,0049,0859,2299)
        oPrn:Box(0550,0050,0860,2300)
        oPrn:Box(0551,0051,0861,2301)
        If Upper(SA1->A1_PESSOA) == "J"
            oPrn:Say(0590,0100,"CNPJ",oFont12)
            oPrn:Say(0640,0100,Transform(Alltrim(SA1->A1_CGC),"@R 99.999.999/9999-99"),oFont20)
        else
            oPrn:Say(0590,0100,"CPF",oFont12)
            oPrn:Say(0640,0100,Transform(Alltrim(SA1->A1_CGC),"@R 999.999.999-99"),oFont20)
        end
               
        oPrn:Say(0590,0900,"Cliente",oFont12)
        oPrn:Say(0640,0900,OemToAnsi(SA1->A1_COD),oFont16N)
                                 
        oPrn:Say(0590,1800,"Loja",oFont12)
        oPrn:Say(0640,1800,OemToAnsi(SA1->A1_LOJA),oFont16N)

//-----4 LINHA------------------------------------------------------------------------------------------------------------------------------------------//
	
        oPrn:Say(0710,0100,"Cidade",oFont12)
        oPrn:Say(0760,0100,OemToAnsi(SA1->A1_MUN),oFont16N)

        oPrn:Say(0710,1550,"UF",oFont12)
        oPrn:Say(0760,1550,OemToAnsi(SA1->A1_EST),oFont16N)
	
        oPrn:Say(0710,1800,"CEP   ",oFont12)
        oPrn:Say(0760,1800,TransForm(SA1->A1_CEP,'@R 99999-999'),oFont16N)

//-----5 LINHA------------------------------------------------------------------------------------------------------------------------------------------//
	
	                  
        nLin := 900
	//oPrn:Box(0850,0050,0950,2300)
        oPrn:Say(nLin,0100,"Item"	  	            	,oFont12N)
        oPrn:Say(nLin,0200,"Produto"  	            	,oFont12N)
        oPrn:Say(nLin,0500,"Descricao"	            	,oFont12N)
        oPrn:Say(nLin,1750,"Quantidade"  	            ,oFont12N)
        oPrn:Say(nLin,2000,"Tipo Caixa"               	,oFont12N)
	
        dbSelectArea("SC6")
        dbSetOrder(01)
        dbSeek(xFilial("SC6")+SC5->C5_NUM)
	
        nLin    := nLin + 100
	
        While SC6->(!Eof()) .And. SC6->C6_NUM ==SC5->C5_NUM
//-----6 LINHA------------------------------------------------------------------------------------------------------------------------------------------//

            oPrn:Say(nLin,0100,OemToAnsi(SC6->C6_ITEM),		   		oFont12)
            oPrn:Say(nLin,0200,OemToAnsi(SC6->C6_PRODUTO),		   	oFont12)
            oPrn:Say(nLin,0500,REPLACE(SC6->C6_DESCRI,'DISP. RET. INF.',''),		  	 oFont12)
            oPrn:Say(nLin,1750,Transform(SC6->C6_QTDVEN,"@E 9,999,999.99"),		oFont12)

            _cCaixa := '1 - Unitaria'
            if SC6->C6_XCXMAST != '1'
                _cCaixa := '2 - Master'
            endif
			
            oPrn:Say(nLin,2000,OemToAnsi(_cCaixa),                oFont12)

            nLin+=0050
            IF nLin>= 2500
                mostr('R')
                oPrn:EndPage()
                oPrn:StartPage()
                mostr('C')
                nLin    := 1000
            ENDIF
		
            SC6->(DBSKIP())
        ENDDO
//-----7 LINHA------------------------------------------------------------------------------------------------------------------------------------------//

        nLin := 2550
        oPrn:box(nLin-51,0049,nLin+299,2299)
        oPrn:box(nLin-50,0050,nLin+300,2300)
        oPrn:box(nLin-49,0051,nLin+301,2301)
    
        oPrn:Say(nLin,0100,"Transportadora",oFont12)
        oPrn:Say(nLin+50,0100,posicione("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_NOME"),oFont16N)
    
        oPrn:Say(nLin,1550,"Especie",oFont12)
        oPrn:Say(nLin+50,1550,OemToAnsi(SC5->C5_ESPECI1),oFont16N)
                                 
        oPrn:Say(nLin,1900,"Total Volume",oFont12)
        oPrn:Say(nLin+50,1900,Transform(SC5->C5_VOLUME1,"@E 999,999"),		oFont16N)

//-----8 LINHA------------------------------------------------------------------------------------------------------------------------------------------//

        oPrn:Say(nLin+120,0100,"M3 ",oFont12)
        oPrn:Say(nLin+170,0100,Transform(SC5->C5_PCUB01,"@E 999,999.9999"),		oFont16N)
                                 
        oPrn:Say(nLin+120,0700,"Peso Cubado",oFont12)
        oPrn:Say(nLin+170,0700,Transform(SC5->C5_PCUB02,"@E 999,999.9999"),		oFont16N)

        oPrn:Say(nLin+120,1550,"Peso Liquido",oFont12)
        oPrn:Say(nLin+170,1550,Transform(SC5->C5_PESOL,"@E 999,999.99"),		oFont16N)

        oPrn:Say(nLin+120,1900,"Peso Bruto",oFont12)
        oPrn:Say(nLin+170,1900,Transform(SC5->C5_PBRUTO,"@E 999,999.99"),		oFont16N)

//-----9 LINHA------------------------------------------------------------------------------------------------------------------------------------------//

        nLin += 300
        oPrn:box(nLin-1,0049,nLin+249,2299)
        oPrn:box(nLin,  0050,nLin+250,2300)
        oPrn:box(nLin+1,0051,nLin+251,2301)
        nLin += 50
        oPrn:Say(nLin,0100,"Mensagem da Nota",oFont12N)
	                                                  
        nTamObs:=100
	             
        nLin := nLin + 50
        oPrn:Say(nLin,0100,upper(Substr(SC5->C5_MENNOTA,1,nTamObs)),oFont12)
        nLin := nLin + 50
        oPrn:Say(nLin,0100,upper(Substr(SC5->C5_MENNOTA,101,nTamObs)),oFont12)
        nLin := nLin + 50
        oPrn:Say(nLin,0100,upper(Substr(SC5->C5_MENNOTA,201,nTamObs)),oFont12)
        nLin := nLin + 50
        oPrn:Say(nLin,0100,upper(Substr(SC5->C5_MENNOTA,301,nTamObs)),oFont12)
        nLin := nLin + 50
        oPrn:Say(nLin,0100,upper(Substr(SC5->C5_MENNOTA,401,nTamObs)),oFont12)

        dbSelectArea("SC5")
        dbSkip()
        oPrn:EndPage()

    EndDo
 
Return
 
/*
Descri??o ³ Ajusta perguntas do SX1      
*/
Static Function AjustaSX1(cPerg)
 
    Local aArea := GetArea()
    PutSx1(cPerg,"01","No Pedido Vendas               ?"," "," ","mv_ch1","C",6,0,0,	"G","","   ","","","mv_par01"," "," "," ","",	" "," "," "," "," "," ", " "," "," ","SC5",	" "," ",{"Informe numero do Pedido Vendas"},{"Informe o numero do Pedido de Vendas de"},{"Informe o Numero do Pedido de Vendas"})
    PutSx1(cPerg,"02","Pedido Vendas Ate             ?"," "," ","mv_ch2","C",6,0,0,	"G","","   ","","","mv_par02"," "," "," ","",	" "," "," "," "," "," ", " "," "," ","SC5"," "," ",{"Informe o numero do Orcamento"},{"Informe o numero do Pedido de Vendas ate"},{"Informe o Numero do Pedido de Compras ate"})
    PutSx1(cPerg,"03","Filial ?"," "," ","mv_ch3","C",2,0,0,	"G","","   ","","","mv_par03"," "," "," ","",	" "," "," "," "," "," ", " "," "," "," ",	" "," ",{"Informe a Filial do numero do Orcamento"},{"Informe a Filial do numero do Orcamento"},{"Informe a Filial do numero do Orcamento"})
 
    RestArea(aArea)
Return()
/*
autor: LEandro Duarte
nome: mostr
função rotina para efetuar o ajuste de cabeçalho e de rodapé
*/
Static Function mostr(cTipo)
    if cTipo == 'C' // cabeçalho
        oPrn:Box(0099,0049,0339,2299)
        oPrn:Box(0100,0050,0340,2300)
        oPrn:Box(0101,0051,0341,2301)
    
//-----1 LINHA------------------------------------------------------------------------------------------------------------------------------------------//

        oPrn:Say(0150,0100, "Pedido Nº",oFont12)
        oPrn:Say(0200,0100,OemToAnsi(SC5->C5_NUM),oFont26)
    
        oPrn:Say(0150,1700,"Data",oFont12)
        cData:=    substr(DtoS(SC5->C5_EMISSAO),7,2)+'-'+aMeses[val(substr(DtoS(SC5->C5_EMISSAO),5,2))]+'-'+substr(DtoS(SC5->C5_EMISSAO),1,4)
        oPrn:Say(0200,1700,cData,oFont26)
                
//-----2 LINHA------------------------------------------------------------------------------------------------------------------------------------------//
    
        oPrn:Box(0339,0049,0549,2299)
        oPrn:Box(0340,0050,0550,2300)
        oPrn:Box(0341,0051,0551,2301)
        oPrn:Say(0350,0100,"Nome",oFont12)
        oPrn:Say(0400,0100,SUBSTR(SA1->A1_NOME,1,35),oFont26)

//-----3 LINHA------------------------------------------------------------------------------------------------------------------------------------------//

        oPrn:Box(0549,0049,0859,2299)
        oPrn:Box(0550,0050,0860,2300)
        oPrn:Box(0551,0051,0861,2301)
        If Upper(SA1->A1_PESSOA) == "J"
            oPrn:Say(0590,0100,"CNPJ",oFont12)
            oPrn:Say(0640,0100,Transform(Alltrim(SA1->A1_CGC),"@R 99.999.999/9999-99"),oFont20)
        else
            oPrn:Say(0590,0100,"CPF",oFont12)
            oPrn:Say(0640,0100,Transform(Alltrim(SA1->A1_CGC),"@R 999.999.999-99"),oFont20)
        end
               
        oPrn:Say(0590,0900,"Cliente",oFont12)
        oPrn:Say(0640,0900,OemToAnsi(SA1->A1_COD),oFont16N)
                                 
        oPrn:Say(0590,1800,"Loja",oFont12)
        oPrn:Say(0640,1800,OemToAnsi(SA1->A1_LOJA),oFont16N)

//-----4 LINHA------------------------------------------------------------------------------------------------------------------------------------------//
    
        oPrn:Say(0710,0100,"Cidade",oFont12)
        oPrn:Say(0760,0100,OemToAnsi(SA1->A1_MUN),oFont16N)

        oPrn:Say(0710,1550,"UF",oFont12)
        oPrn:Say(0760,1550,OemToAnsi(SA1->A1_EST),oFont16N)
    
        oPrn:Say(0710,1800,"CEP   ",oFont12)
        oPrn:Say(0760,1800,TransForm(SA1->A1_CEP,'@R 99999-999'),oFont16N)

//-----5 LINHA------------------------------------------------------------------------------------------------------------------------------------------//
    
                      
        nLin := 900
        oPrn:Say(nLin,0100,"Item"                       ,oFont12N)
        oPrn:Say(nLin,0200,"Produto"                    ,oFont12N)
        oPrn:Say(nLin,0500,"Descricao"                  ,oFont12N)
        oPrn:Say(nLin,1750,"Quantidade"                 ,oFont12N)
        oPrn:Say(nLin,2000,"Tipo Caixa"                 ,oFont12N)
    
   
        nLin    := nLin + 100
    elseif cTipo == 'R' // Rodapé
        nLin := 2550
        oPrn:box(nLin-51,0049,nLin+299,2299)
        oPrn:box(nLin-50,0050,nLin+300,2300)
        oPrn:box(nLin-49,0051,nLin+301,2301)
    
        oPrn:Say(nLin,0100,"Transportadora",oFont12)
        oPrn:Say(nLin+50,0100,posicione("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_NOME"),oFont16N)
    
        oPrn:Say(nLin,1550,"Especie",oFont12)
        oPrn:Say(nLin+50,1550,OemToAnsi(SC5->C5_ESPECI1),oFont16N)
                                 
        oPrn:Say(nLin,1900,"Total Volume",oFont12)
        oPrn:Say(nLin+50,1900,Transform(SC5->C5_VOLUME1,"@E 999,999"),      oFont16N)

//-----8 LINHA------------------------------------------------------------------------------------------------------------------------------------------//

        oPrn:Say(nLin+120,0100,"M3 ",oFont12)
        oPrn:Say(nLin+170,0100,Transform(SC5->C5_PCUB01,"@E 999,999.9999"),     oFont16N)
                                 
        oPrn:Say(nLin+120,0700,"Peso Cubado",oFont12)
        oPrn:Say(nLin+170,0700,Transform(SC5->C5_PCUB02,"@E 999,999.9999"),     oFont16N)

        oPrn:Say(nLin+120,1550,"Peso Liquido",oFont12)
        oPrn:Say(nLin+170,1550,Transform(SC5->C5_PESOL,"@E 999,999.99"),        oFont16N)

        oPrn:Say(nLin+120,1900,"Peso Bruto",oFont12)
        oPrn:Say(nLin+170,1900,Transform(SC5->C5_PBRUTO,"@E 999,999.99"),       oFont16N)

//-----9 LINHA------------------------------------------------------------------------------------------------------------------------------------------//

        nLin += 300
        oPrn:box(nLin-1,0049,nLin+249,2299)
        oPrn:box(nLin,  0050,nLin+250,2300)
        oPrn:box(nLin+1,0051,nLin+251,2301)
        nLin += 50
        oPrn:Say(nLin,0100,"Mensagem da Nota",oFont12N)
                                                      
        nTamObs:=100
                 
        nLin := nLin + 50
        oPrn:Say(nLin,0100,upper(Substr(SC5->C5_MENNOTA,1,nTamObs)),oFont12)
        nLin := nLin + 50
        oPrn:Say(nLin,0100,upper(Substr(SC5->C5_MENNOTA,101,nTamObs)),oFont12)
        nLin := nLin + 50
        oPrn:Say(nLin,0100,upper(Substr(SC5->C5_MENNOTA,201,nTamObs)),oFont12)
        nLin := nLin + 50
        oPrn:Say(nLin,0100,upper(Substr(SC5->C5_MENNOTA,301,nTamObs)),oFont12)
        nLin := nLin + 50
        oPrn:Say(nLin,0100,upper(Substr(SC5->C5_MENNOTA,401,nTamObs)),oFont12)
    endif
Return()