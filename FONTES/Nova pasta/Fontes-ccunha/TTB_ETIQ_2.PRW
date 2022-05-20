#include "rwmake.ch"                       
#include "topconn.ch"                                                                                               
#include "tbiconn.ch"                                           
#include "tbicode.ch"                                                           
#Include "Protheus.Ch"

/*
Padrao ELTRON
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DK_ETIQ_2 ºAutor  ³TECNORAV        º Data ³  06/03/17       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressão Etiqueta Zebra "ELTRON/TLP2844" com Cod Barra	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Dakhia                                                     º±±                                                          	
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³IMPRESSAO ETIQUETA GRANDE³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                                            			
User Function TTB_ETIQ_2(xEtiq)

	Local nAlturati	 		:= 10  //Para impressão do Titulo Dakhia Ind.Com.Termoplasticos.
	Local nLargurati 		:= 10  //Para impressão do Titulo Dakhia Ind.Com.Termoplasticos.
	Local nAlturavar 		:= 10  //Para controle dos demais itens da etiqueta.
	Local nLarguravar		:= 10  //Para controle dos demais itens da etiqurta.
	Local cTipof
	Local cFontea    		:="4" //Testado, não saiu descrição.
	Local cFonteb    		:="1" //Testado, saiu muito pequeno.
	Local cFontec    		:="2" //Testado, saiu pequeno, mas razoavel.
	Local cFonted			:="3" //Ficou Boa
	Local cLogo				:="\SYSTEM\DAKHIA.BMP"
	Local aModelo	   		:= {"ARGOX","ELTRON","ZEBRA"}
	Local I 				:= 0  
	LOCAL aAreaAnt  := GETAREA()

	

   
    MSCBPRINTER("ELTRON","LPT1",,,.F.,,,,,,,,)
    MSCBCHKSTATUS(.F.) 	
	//***********************************
	//cgraf :="\LGRL01.BMP"
	//carquivo:="LGRL01"
    //MSCBLOADGRF(cgraf)
    MSCBBEGIN(1,6) //Padrão 1,6
    //Quadrado 
    //MSCBBOX(esq_para_dir,baixo_para_cima,esq_para_dir,baixo_para_cima,Numero com a espessura em pixel)
    
	MSCBBOX (006,002,100,0198,001)	//BOX PRINCIPAL DA ETIQUETA!       
	//MSCBBOX (45,04,98,75,001)		//BOX PRINCIPAL DISPOSIÇÃO DA QUALIDADE
	MSCBBOX (45,04,97,75,001)		//BOX PRINCIPAL DISPOSIÇÃO DA QUALIDADE
	
	MSCBSAY(57,55,'APROVADO(VERDE)',"B","2","01,02")//MYI_AJUSTADO CONFORME SOLICITACAO JOHNNY EM 09/11/2018
	MSCBSAY(73,55,'ANALISE(AMAREL)',"B","2","01,02")
	MSCBSAY(87,55,'REPROV.(VERMEL)',"B","2","01,02")//MYI_AJUSTADO CONFORME SOLICITACAO JOHNNY EM 09/11/2018
	
	//20170303 - douglas
	//MSCBBOX (X,Y,X1,Y2,001)
	//******  cartesiano
	//X = ESQUERDA PARA DIREITA
	//Y = CIMA PARA BAIXO
	//X1 = DIREITA PARA ESQUERDA
	//Y1 = BAIXO PARA CIMA
	

	//MSCBBOX (055,60,065,070,001) //BOX APROVADO ////MYI_AJUSTADO CONFORME SOLICITACAO JOHNNY EM 09/11/2018
	MSCBBOX (070,60,080,070,001) //BOX EM ANALISE
	//MSCBBOX (085,60,095,070,001) //BOX REPROVADO ////MYI_AJUSTADO CONFORME SOLICITACAO JOHNNY EM 09/11/2018
	     
    MSCBSAY(14,170	,'DAKHIA IND. COM. TERMOPLASTICOS',"B",cFontea,"01,02")
    	
    MSCBSAY(9,30		,'FGQ-7-106',"B","1","01,02")
	
	MSCBSAY(25,195	,"LOTE: "			+ xEtiq[2]												,"B"	,cFontea	,"01,02")
	MSCBSAY(25,123	,"NF: "	   		+ xEtiq[3]												,"B"	,cFontea	,"01,02")
	MSCBSAY(25,80		,"N ETIQ: "   	+ xEtiq[1]												,"B"	,cFontea	,"01,02")

 //	cDescProd := Posicione("SB1",1,xFilial("SB1") + xEtiq[10],"B1_DESC")	
	
 	IF LEN(ALLTRIM(xEtiq[11])) >= 35                                                         //cFontec
		MSCBSAY(30,195	,"PRODUTO: "	+ AllTrim(xEtiq[10])+ ' - ' + AllTrim(xEtiq[11]) ,"B",cFontec,"01,02")
		
 	ELSE
 		MSCBSAY(30,195	,"PRODUTO: "	+ AllTrim(xEtiq[10])+ ' - ' + AllTrim(xEtiq[11]) ,"B",cFonted,"01,02")
 	ENDIF

	MSCBSAY(35,195	,'PESO/QTD: ' 	+ cValtoChar(xEtiq[4])+' '+(SB1->B1_UM)			,"B"	,cFontea	,"01,02")    	
   
     cCliente:=Posicione("SA1",1,xFilial("SA1")+xEtiq[7],"A1_NOME")   //Pega a Descrição dos tipos de Produtos!

    If !Empty(xEtiq[5])
  		MSCBSAY(40,195,"F: "				+ xEtiq[5]												,"B"	,cFontea, "01,02")  
  	EndIf
  	
  	If !Empty(xEtiq[7])
		MSCBSAY(40,195,"Cliente: "		+ Alltrim(cCliente)									,"B"	,cFontea, "01,02")    	
	EndIf
	
	MSCBSAY(45,195	,"DATA: "			+ DTOC(DATE())										,"B"	,cFontea,"01,02") 
		
	MSCBSAY(48,70		,'DISPOSICAO DA QUALIDADE'												,"B"	,"1","1,2")
  
   cTipof:=Posicione("SX5",1,xFilial("SX5")+"02"+SB1->B1_TIPO,"X5_DESCRI")   		//Pega a Descrição dos tipos de Produtos! B8_XTIPO
   
   //cTipof:=Posicione("SB8",5,xFilial("SB8")+"02"+SB1->B1_TIPO,"B8_XDESC")   		//Pega a Descrição dos tipos de Produtos!
         
    MSCBSAY(50,195	,"TIPO: " + cTipof														,"B"	,cFontea,"01,02") //88
   
    If !Empty(xEtiq[12])  //Adriano-Solicitado por Jhoony em 18-07-17 especifico Max-Frio.Controle de Bags.Amostras.
    MSCBSAY(55,195,"BAG: " + Alltrim(cValtoChar(xEtiq[12]))										,"B"	,cFontea,"01,02") //88
    EndIf
     
	MSCBSAYBAR(60,145,xEtiq[1],"B",xEtiq[9],20,.F.,.T.,.F.,   ,4, 1 , .F. ,.F.,,.T.)	
	
	//MSCBSAYBAR(60,145,"0000000001","B","MB07",20,.F.,.T.,.F.,,4,1,.F.,.F.,,.T.) //TESTE OK	
	
	MSCBSAY(98,195	,"Meu computador/Qualidade/Processos ISO9001:2008/Formularios/FGQ-7-106_Revisao: 00__Data: 08/06/2016","B","1","01,01")
            
	MSCBInfoEti("Produto","admin	30X100")
	sConteudo:=MSCBEND() 
    //MSCBCLOSEPRINTER()
    
 //NEX
         
 	RESTAREA(aAreaAnt) 
 	
 
Return