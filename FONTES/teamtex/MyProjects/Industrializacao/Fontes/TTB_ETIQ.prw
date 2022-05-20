/*
Padrao DATAMAX
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณimg01     บAutor  ณSandro Valex        บ Data ณ  19/06/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPonto de entrada referente a imagem de identificacao do     บฑฑ
ฑฑบ          ณproduto. Padrao Microsiga                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ                                                          	
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                             			
User Function TTB_ETIQ(aEtiq)
	Local nAlturati	 := 10  //Para impressใo do Titulo Dakhia Ind.Com.Termoplasticos.
	Local nLargurati := 10  //Para impressใo do Titulo Dakhia Ind.Com.Termoplasticos.
	Local nAlturavar := 10  //Para controle dos demais itens da etiqueta.
	Local nLarguravar:= 10  //Para controle dos demais itens da etiqurta.
	Local cTipof
	Local cFontea    :="3"
	Local cFonteb    :="1"
	Local cFontec    :="2"
	Local cLogo:="\SYSTEM\DAKHIA.BMP"
	

//	U_DK_ETIQ({cCodigo,cLote,cNFEnt,nqtde,cFornec,cTipof,cTipoBar})

    //MSCBPRINTER("ARGOX","LPT1",,,.F.)//Anterior,se der pau descomenta essa linha e comenta a de baixo!
    MSCBPRINTER("ARGOX","LPT1",,,.F.,,,,,,,,)
    MSCBCHKSTATUS(.F.) 	
	//***********************************
	//cgraf :="\LGRL01.BMP"
	//carquivo:="LGRL01"
    //MSCBLOADGRF(cgraf)
    MSCBBEGIN(1,4) //Padrใo 1,6
    //Quadrado 
    //MSCBBOX(esq_para_dir,baixo_para_cima,esq_para_dir,baixo_para_cima,Numero com a espessura em pixel)
    MSCBBOX (006,002,100,0198,001)//BOX PRINCIPAL DA ETIQUETA!       
    //MSCBBOX(004,002,098,0123,001)
	//       X1   Y1->  X2  Y2|   Esp.
	MSCBBOX (039,120,95,0196,001) //BOX PRINCIPAL DISPOSIวรO DA QUALIDADE
	       //  1ฐ 2ฐ   3ฐ  4ฐ
	MSCBBOX (050,130,060,0140,001) //BOX APROVADO
	MSCBBOX (065,130,075,0140,001) //BOX EM ANALISE
	MSCBBOX (080,130,090,0140,001) //BOX REPROVADO
	MSCBSAY(57,145,'APROVADO',"B","2","01,02")
	MSCBSAY(73,145,'EM ANALISE',"B","2","01,02")
	MSCBSAY(87,145,'REPROVADO',"B","2","01,02")
//1 ฐ Quando menor mais alto.
//2ฐ  Quando menor mais largo.<pra esquerda>
//3ฐ  Quando maior mais baixo.<cima pra baixo>
//4ฐ  Quanto maior mais pro final.<esquerda pra dideira>

	      // 39 -Altura da Caixa!
	// 1-Linha Horizontal abaixo do produto
	//MSCBLineH(30,30,76,1)
	// 2-Linha Horizontal abaixo do codigo
	//MSCBLineH(02,23,76,1) 
	// 3-Linha Horizontal abaixo do descricao
	//MSCBLineH(02,15,76,1) 
	//Linha vertical do lado do produto e codigo
	//MSCBLineV(30,23,34,1) 
    //MSCBLOADGRF(cLogo)   
	//MSCBGRAFIC(06,18,"DAKHIA",) //Padrใo ้ 2,26.
	     // X(12)  Y(30)
	     
    MSCBSAY(18,nLargurati + 30 ,'D A K H I A  I N D .  C O M .  T E R M O P L A S T I C O S ',"B",cFontea,"01,03")	
    MSCBSAY(14,nLargurati + 173,'FGQ-7-106',"B","2","01,03")	

   /*	If Empty(aEtiq[2])
   //		Alert("Lote vazio")
	//	EndIf
	*/
	
	MSCBSAY(32,135	,"N ETIQ: "   	+aEtiq[1],  "B", 	cFontea, "01,02")
	MSCBSAY(32,06	,"LOTE:.....: "	+aEtiq[2],  "B", 	cFontea, "01,02")
	MSCBSAY(32,80	,"NF: "	   		+aEtiq[3],	"B",	cFontea, "01,02")
//	MSCBSAY(32,nLarguravar+145,		'DATA: '+ DTOC(DATE()),"B",cFontea,"01,02") 
//	MSCBSAY(40,06,'PRODUTO...:'		+AllTrim(SB1->B1_COD)+' - '+SB1->B1_DESC ,"B",cFontea,"01,02")
	cDescProd := Posicione("SB1",1,xFilial("SB1")+aEtiq[10],"B1_DESC")
	MSCBSAY(40,06	,"PRODUTO...: "	+AllTrim(aEtiq[10])+' - '+ALLTRIM(cDescProd) ,"B",cFontea,"01,02")
//--
	MSCBSAY(48,06	,'PESO/QTD..:' 	+ cValtoChar(aEtiq[4])+' '+(SB1->B1_UM),"B",cFontea,"01,02")
   //MSCBSAY(48,55," LOCAL: "		+cArmazem, "B", cFontea, "01,02")  
    MSCBSAY(48,nLarguravar+125,		'DISPOSICAO DA QUALIDADE',"B",cFontea,"01,02")
    MSCBSAY(66,06	,"DATA: "			+ DTOC(DATE()),"B",cFontea,"01,02") 
   
     cCliente:=Posicione("SA1",1,xFilial("SA1")+aEtiq[7],"A1_NOME")   //Pega a Descri็ใo dos tipos de Produtos!
// 			   POSICIONE("SX5",1,XFILIAL("SX5")+"X1"+M->CB0_XMOTIV,"X5_DESCRI")
    If !Empty(aEtiq[5])
  		MSCBSAY(57,06,"F: "				+aEtiq[5],"B", cFontea, "01,02")  
  	EndIf
  	
  	If !Empty(aEtiq[7])
		MSCBSAY(57,06,"Cliente: "		+Alltrim(cCliente),"B", cFontea, "01,02")    	
	EndIf
   //MSCBSAY(57,06,"FORNECEDOR:"	+cFornec+"-"+AllTrim(SA2->A2_NREDUZ), "B", cFontea, "01,02")  
    
    /*
   //MSCBSAY(38,06,'PESO: 1.000 KG',"B","2","01,02")
   //MSCBBOX(altura da caixa,,    esq_para_dir,   baixo_para_cima,    Numero com a espessura em pixel)
   //MSCBBOX  (050,050,090,090,001)	
   //MSCBSAY(46,92,'APROVADO',"B","2","01,02") 
   //MSCBSAY(54,92,'EM ANALISE',"B","2","01,02") 
   //MSCBSAY(62,92,'REPROVADO',"B","2","01,02") 
	
	
	//MSCBSAY(22,06,"LOTE: "+cLote, "B", "2", "01,02")
	//MSCBSAY(32,40,"VAL: "+ DTOC(dValid), "B", cFontea, "01,02")
	
	MSCBSAY(10,40,"CODIGO: ","B","2","01,01")
	MSCBSAY(10,50, , "B", "2", "01,01")
	MSCBSAY(20,10,"DESCRICAO","B","2","01,01")
	MSCBSAY(20,30,,"B", "2", "01,01") 
    /
    //                                          1     2         3          4         5           6
	//MSCBSayBar - Imprime c๓digo de barras ( [nXmm] [nYmm] [cConteudo] [cRota็ใo] [cTypePrt] [ nAltura ] 
	//
	//      7            8           9              10           11           12           13            14          15        16
	//[ *lDigver ] [ lLinha ] [ *lLinBaixo ] [ cSubSetIni ] [ nLargura ] [ nRelacao ] [ lCompacta ] [ lSerial ] [ cIncr ] [ lZerosL ] )
	
	//         1  2    3      4     5      6    7   8   9 10 11 12   13   14  15   16
	*/
    cTipof:=Posicione("SX5",1,xFilial("SX5")+"02"+SB1->B1_TIPO,"X5_DESCRI")   //Pega a Descri็ใo dos tipos de Produtos!      
    MSCBSAY(84,06,"TIPO: "+cTipof,"B",cFontea,"01,02") //88
    MSCBSAY(99,06,"Meu computador/Qualidade/Processos ISO9001:2008/Formularios/FGQ-7-106_Revisao: 00__Data: 08/06/2016","B",cFonteb,"01,02")
	MSCBSAYBAR(93,60,aEtiq[1],"B",aEtiq[9],20,.F.,.T.,.F.,   ,30, 3 , .F. ,.F.,"1",.T.) //97	
            
	MSCBInfoEti("Produto","admin	30X100")
	sConteudo:=MSCBEND() 
    //MSCBCLOSEPRINTER()
Return



//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณIMPRESSAO ETIQUETA PEQUENA -MAXFRIO-EDILSONณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
User Function DK_ETIPE(aEtiq)
	Local nAlturati	 := 10  //Para impressใo do Titulo Dakhia Ind.Com.Termoplasticos.
	Local nLargurati := 10  //Para impressใo do Titulo Dakhia Ind.Com.Termoplasticos.
	Local nAlturavar := 10  //Para controle dos demais itens da etiqueta.
	Local nLarguravar:= 10  //Para controle dos demais itens da etiqurta.
	Local cTipof
	Local cFontea    :="3"
	Local cFonteb    :="1"
	Local cFontec    :="2"
	Local cLogo:="\SYSTEM\DAKHIA.BMP"
	

//	U_DK_ETIQ({cCodigo,cLote,cNFEnt,nqtde,cFornec,cTipof,cTipoBar})

    //MSCBPRINTER("ARGOX","LPT1",,,.F.)//Anterior,se der pau descomenta essa linha e comenta a de baixo!
    MSCBPRINTER("ARGOX","LPT2",,,.F.,,,,,,,,)
    MSCBCHKSTATUS(.F.) 	
    MSCBBEGIN(1,4) //Padrใo 1,6
    MSCBBOX (004,003,0095,0048,001)//BOX PRINCIPAL DA ETIQUETA!       
//  MSCBBOX (003,003,0095,0050,001)//BOX PRINCIPAL DA ETIQUETA!       
//1 ฐ Quando menor mais alto.
//2ฐ  Quando menor mais largo.<pra esquerda>
//3ฐ  Quando maior mais baixo.<cima pra baixo>
//4ฐ  Quanto maior mais pro final.<esquerda pra dideira>

//	If !Empty(aEtiq[7])
		cCliente :=Posicione("SA1",1,xFilial("SA1")+aEtiq[1] ,"A1_NOME")   
		cDescProd:=Posicione("SB1",1,xFilial("SB1")+aEtiq[2] ,"B1_DESC")
		MSCBSAY(05,042,	 "CLIENTE: "		+Alltrim(cCliente),"N",cFontec,"01,02")    	
//	EndIf
 		
		MSCBSAY(05,035	,"PRODUTO...: "		+AllTrim(aEtiq[2])+' - '+ALLTRIM(cDescProd) 			,"N",cFontec,"01,02")
		MSCBSAY(05,028	,"DESCRICAO...: "	+AllTrim(aEtiq[3])										,"N",cFontec,"01,02")
		MSCBSAY(05,021	,"LOTE..:"			+AllTrim(aEtiq[5])+" 		COR:.....: "	+aEtiq[4] 	,"N",cFontec,"01,02")//Invertido ordem,sugestใo Edilson 18-07-16
		MSCBSAY(05,012	,"COD:" 			+cValtoChar(aEtiq[6])									,"N",cFontec,"01,02")//Antes era Peso/Qtd, edilson solicitou retirar e colocar cod.cliente(externo).
      	MSCBSAY(006,04	,"Meu computador/Qualidade/Formularios/FGQ-7-106_Rev.00__26/02/2015"		,"N",cFonteb,"01,02")
  		MSCBSAYBAR(038,008,aEtiq[7],"N",aEtiq[11],06,.F.,.T.,.F.,,30, 2 , .F. ,.F.,"1",.T.) //97	
        
	MSCBInfoEti("Produto","admin	30X100")
	sConteudo:=MSCBEND() 
    //MSCBCLOSEPRINTER()
Return
