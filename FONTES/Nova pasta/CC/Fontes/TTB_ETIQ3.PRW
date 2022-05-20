#include "rwmake.ch"                       
#include "topconn.ch"                                                                                               
#include "tbiconn.ch"                                           
#include "tbicode.ch"                                                           
#Include "Protheus.Ch"

/*
Padrao ELTRON
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDK_ETIQ3 บAutor  ณTECNORAV        บ Data ณ  09/05/17   	  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpressใo Etiqueta Zebra "ELTRON/TLP2844" com Cod Barra	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Dakhia                                                     บฑฑ                                                          	
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณIMPRESSAO ETIQUETA PEQUENA ZEBRAณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
                                            			
USER Function TTB_ETIQ3(aEtiq)

	Local nAlturati  := 10  //Para impressใo do Titulo Dakhia Ind.Com.Termoplasticos.
	Local nLargurati := 10  //Para impressใo do Titulo Dakhia Ind.Com.Termoplasticos.
	Local nAlturavar := 10  //Para controle dos demais itens da etiqueta.
	Local nLarguravar:= 10  //Para controle dos demais itens da etiqurta.
	Local cTipof
	Local cFonteA    :="2"	
	Local cFonteB    :="1"	
	//Local cLogo:="\SYSTEM\DAKHIA.BMP"
	
	/*Local cLogo			:= SuperGetMv("DK_XLOGOP",.F., '\SYSTEM\DAKHIA.BMP')
	Local cModeloETQ		:= SuperGetMv("DK_XETIQP",.F., 'ELTRON')
	Local cPortaEIQ 		:= SuperGetMv("DK_XPORTP",.F., 'LPT2')
	Local cISO				:= SuperGetMv("DK_XISOP",.F., 'Meu computador/Qualidade/Formularios/FGQ-7-106_Rev.00__26/02/2015')*/
	
	Local cLogo				:= GETMV("DK_XLOGOP")
	Local cModeloETQ		:= GETMV("DK_XETIQP")
	Local cPortaEIQ 		:= GETMV("DK_XPORTP")
	Local cISO				:= GETMV("DK_XISOP")
	
	 //MSCBPRINTER("ELTRON","LPT2",,,.F.,,,,,,,,)
    MSCBPRINTER(cModeloETQ,cPortaEIQ,,,.F.,,,,,,,,)
    MSCBCHKSTATUS(.F.) 	
    MSCBBEGIN(1,4) //Padrใo 1,6
   
    MSCBBOX (003,001,0100,0047,001)//BOX PRINCIPAL DA ETIQUETA!  

	cCliente :=Posicione("SA1",1,xFilial("SA1") + aEtiq[1] ,"A1_NOME")   
	cDescProd:=Posicione("SB1",1,xFilial("SB1") + aEtiq[2] ,"B1_DESC")
	
	MSCBSAY(080,002	,"Etiq: " 			    + CVALTOCHAR(PADL(aEtiq[12],4,"0")) 					,"N",cFonteA,"01,02")
	MSCBSAY(005,002	,"CLIENTE: " 			+ Alltrim(cCliente)										,"N",cFonteA,"01,02")
	MSCBSAY(005,008	,"PRODUTO...: " 		+ AllTrim(aEtiq[2]) + ' - ' + ALLTRIM(cDescProd) 		,"N",cFonteA,"01,02") // Tamanho Caracter 62  	
	MSCBSAY(005,014	,"DESCRICAO...: "	 	+ AllTrim(aEtiq[3])										,"N",cFonteA,"01,02")
 	MSCBSAY(005,019	,"LOTE..:"				+ AllTrim(aEtiq[5]) + " 		COR:.....: "+  aEtiq[4]	,"N",cFonteA,"01,02")//Invertido ordem,sugestใo Edilson 18-07-16	
	MSCBSAY(005,031	,"COD:" 				+ cValtoChar(aEtiq[6])									,"N",cFonteA,"01,02")//Antes era Peso/Qtd, edilson solicitou retirar e colocar cod.cliente(externo).
	
	MSCBSAYBAR(048,028,aEtiq[7],"N",aEtiq[11],10,.F.,.T.,.F.,,2, 2 , .F. ,.F.,"1",.T.) //97
		
	MSCBSAY(005,044	,cISO,"N",cFonteB,"01,02")
    
	MSCBInfoEti("Produto","admin	30X100")
	sConteudo:=MSCBEND() 
    //MSCBCLOSEPRINTER()
Return