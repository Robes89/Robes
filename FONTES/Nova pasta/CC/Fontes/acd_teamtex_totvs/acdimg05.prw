#include 'protheus.ch'
#include 'parmtype.ch'
#include "apvt100.ch"

//-----------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Img05
Ponto de entrada referente a imagem de identificacao de Volume temporaria
Padrao DATAMAX
@author Totvs
@since 08/08/2018
@version 1.0
/*/  
User Function Img05()   // imagem de etiqueta de volume temporaria 

Local cVolume := paramixb[1]
Local cPedido := paramixb[2]
Local cNota   := IF(len(paramixb)>=3,paramixb[3],nil)
Local cSerie  := IF(len(paramixb)>=4,paramixb[4],nil)
Local cID     := CBGrvEti('05',{cVolume,cPedido,cNota,cSerie}) 
Local nLin	  := 55
Local sConteudo   

//Dados da Empresa:
Local cXCODFIL 	:= SM0->M0_CODIGO + " - " + SM0->M0_CODFIL
Local cXEMPRESA := Capital(Trim(SM0->M0_NOME))
Local cCnpj		:= Transform(SM0->M0_CGC,"@R 99.999.999/9999-99") 
Local cXEMPFIL 	:= Capital(Trim(SM0->M0_FILIAL)) 
Local cXENDERE	:= Capital(Trim(SM0->M0_ENDCOB))
Local cXCIDADE	:= Capital(Trim(SM0->M0_CIDCOB))  
Local cXESTADO	:= Capital(Trim(SM0->M0_ESTCOB))
Local cXCEP		:= "CEP: " + Transform(Capital(Trim(SM0->M0_CEPCOB)),"@R 99999-999")  
Local cXTELEFO 	:= "Tel.: " + Capital(Trim(SM0->M0_TEL)) 

//MSCBLOADGRF("SIGA.BMP")
MSCBBEGIN(1,6)
	MSCBBOX(02,01,76,34,1)
	MSCBLineH(30,30,76,1)
	MSCBLineH(02,23,76,1)
	MSCBLineH(02,15,76,1)
	MSCBLineV(30,23,34,1)
	//MSCBGRAFIC(2,26,"SIGA")
	MSCBSAY(05,27,"TEAMTEX","N","2","01,01")
	MSCBSAY(33,31,"VOLUME: " + Alltrim(cVolume),"N","2","01,01")
	MSCBSAY(33,27,"CODIGO:","N","2","01,01")
	MSCBSAY(33,24,cVolume , "N", "2", "01,01")
	
	MSCBSAY(05,20,"PEDIDO","N","2","01,01")
	MSCBSAY(05,16,CB7->CB7_PEDIDO,"N", "2", "01,01")

	MSCBSAYBAR(22,03,Alltrim(cVolume),"N","MB07",8.36,.F.,.T.,.F.,,3,2,.F.,.F.,"1",.T.)
	
	MSCBInfoEti("VOLUME PRIMARIO","60X100")
	
sConteudo:=MSCBEND()

Return .T.

//-----------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Img05OFI
Ponto de entrada referente a imagem de identificacao de Volume OFICIAL Ou Etiqueta de Embarque
Padrao DATAMAX
@author Totvs
@since 08/08/2018
@version 1.0
/*/
User Function Img05OFI () // imagem de etiqueta de volume permanente (OFICIAL) 

Local cId     := CBGrvEti('05',{CB6->CB6_VOLUME,CB6->CB6_PEDIDO})
Local nTotEti := paramixb[1]
Local nAtu    := paramixb[2]
Local nLin	  := 55  

//Dados da Empresa:
Local cXCODFIL 	:= SM0->M0_CODIGO + " - " + SM0->M0_CODFIL
Local cXEMPRESA := Capital(Trim(SM0->M0_NOME))
Local cCnpj		:= Transform(SM0->M0_CGC,"@R 99.999.999/9999-99") 
Local cXEMPFIL 	:= Capital(Trim(SM0->M0_FILIAL)) 
Local cXENDERE	:= Capital(Trim(SM0->M0_ENDCOB))
Local cXCIDADE	:= Capital(Trim(SM0->M0_CIDCOB))  
Local cXESTADO	:= Capital(Trim(SM0->M0_ESTCOB))
Local cXCEP		:= "CEP: " + Transform(Capital(Trim(SM0->M0_CEPCOB)),"@R 99999-999")  
Local cXTELEFO 	:= "Tel.: " + Capital(Trim(SM0->M0_TEL)) 


Default nRadTipEti:= 1	// 1= Etiquetra de Volume Oficial - 2 Etiqueta de Embarque  

//Posiciona no Pedido
If CB7->CB7_PEDIDO <> SC5->C5_NUM	//Evita Seek desnecessário
	SC5->(DbSetOrder(1)) 	//FILIAL+PEDIDO
	If !SC5->(DbSeek(xFilial("SC6")+CB7->CB7_PEDIDO))
		CBAlert("Impossível Imprimir. Pedido não encontrado") 
	 	Return .F.  
	Endif 
Endif
  	
//Posiciona no Cliente 
If SC5->C5_CLIENTE + SC5->C5_LOJACLI <> SA1->A1_COD + SA1->A1_LOJA   	//Evita Seek desnecessário
	SA1->(DbSetOrder(1)) //Filial + Cliente + Loja 
	If !SA1->(dbSeek(xFilial("SA1")+ SC5->C5_CLIENTE + SC5->C5_LOJACLI))  
		CBAlert("Impossível Imprimir. Cliente não encontrado") 
	   	Return .F.  
	Endif 
Endif

//Posiciona na Transportadora
If SC5->C5_TRANSP <> SA4->A4_COD   	//Evita Seek desnecessário
	SA4->(DbSetOrder(1)) 
	If !SA4->(DbSeek(xFilial("SA4") + SC5->C5_TRANSP))
		CBAlert("Impossível Imprimir. Transportadora não encontrada") 
	 	Return .F.  
	Endif
Endif

cDesCli	:= Alltrim(SA1->A1_NOME)
cEndere	:= "END.: "		+ Alltrim(SA1->A1_END)
cCgc	:= "CNPJ: " 	+ transform(SA1->A1_CGC,"@R 99.999.999/9999-99")  
cCep	:= "CEP " 		+ Transform(SA1->A1_CEP,"@R 99999-999") 
cCidad	:= "CIDADE: "	+ Alltrim(SA1->A1_MUN)
cUF		:= "UF: "		+ Alltrim(SA1->A1_EST)
cDesTran:= "TRANSP.: " 	+ Alltrim(SA4->A4_NOME)	
		
CB9->(DbSetOrder(1))

If CB9->(DbSeek(xFilial('CB9')+CB7->CB7_ORDSEP))
 
	nLin:= 55	
	If nRadTipEti == 1	//IMPRIME ETIQUETA DE VOLUME OFICIAL
		MSCBBEGIN(1,1)  
			MSCBBOX(05,02,100,55,2)
			//primeira linha -----------------------------------------------------------------------------------------------------------
			MSCBSAY(10,nLin-=  6,"TEAM TEX: "  	,"N","3" ,"25,35")
			//Dados da Empresa:			
			MSCBSAY(32,nLin     ,SUBSTR(AllTrim(cDesCli),1,24)   					,"N","3" ,"10,10") 
			/*MSCBSAY(32,nLin-03   ,AllTrim(cCnpj) 	   								,"N","4" ,"10,10") 
			MSCBSAY(32,nLin-06   ,AllTrim(cXENDERE) 								,"N","4" ,"10,10") 
			MSCBSAY(32,nLin-09   ,AllTrim(cXCIDADE) + " - " + AllTrim(cXESTADO) 	,"N","4" ,"10,10") 
			MSCBSAY(32,nLin-12   ,AllTrim(cXCEP) 	+ " - " + AllTrim(cXTELEFO)		,"N","4" ,"10,10")*/
			//Dados do Volume		
			MSCBSAY(80,nLin     ,"Volume: "  	,"N","3" ,"25,35") 
			//segunda linha -----------------------------------------------------------------------------------------------------------
			MSCBSAY(10,nLin-=  5,CB7->CB7_ORDSEP	,"N","3" ,"25,35") 
			MSCBSAY(80,nLin     ,STRzero(nAtu,3)+"/"+STRzero(nTotEti,3)	,"N","3" ,"25,35")   
			//-------------------------------------------------------------------------------------------------------------------------
			//quadrante 1 
			MSCBLineH(02,nLin-= 2,100,2)
			MSCBLineV(30,nLin,55,2)	
			MSCBLineV(78,nLin,55,2) 
			//-------------------------------------------------------------------------------------------------------------------------
			MSCBSAY(45,nLin-=  5    ,AllTrim(CB9->CB9_PROD) ,"N","3" ,"25,25") 
			MSCBSAY(8,nLin-=  4	,SUBSTR(ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+CB9->CB9_PROD,"B1_DESC")),1,45),"N","3" ,"25,35")                 // Descricao produto
			If Len(AllTrim(SB1->B1_DESC)) > 45
				MSCBSAY(8,nLin-=  5,SUBSTR(ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+CB9->CB9_PROD,"B1_DESC")),46,len(AllTrim(SB1->B1_DESC))),"N","3" ,"25,35")                 // Descricao produto
			ENDIF
			MSCBSAYBAR(17,nLin-= 28,ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+CB9->CB9_PROD,"B1_CODBAR")),"N", "MB07",23,.F.,.T.,.F.,,10,3)
			MSCBInfoEti("VOLUME OFICIAL","60X100")
		MSCBEND() 
	Else	// Imprime Etiqueta de EMBARQUE  O PARAMETRO "MV_CBPE006" DO ACD DEVE ESTAR COMO .T.
		MSCBBEGIN(1,1)  
			MSCBBOX(05,02,100,55,2)
			//primeira linha
			MSCBSAY(10,nLin-=  6,"TEAM TEX: "  											,"N","2" ,"25,35")
			MSCBSAY(47,nLin     ,"REMETENTE"											,"N","2" ,"25,35") 
			MSCBSAY(41,nLin-5	,"TEAM TEX BRASIL"										,"N","2" ,"25,35")
			MSCBSAY(80,nLin     ,"Nota Fiscal: "  										,"N","2" ,"25,35") 
			//segunda linha
			MSCBSAY(10,nLin-=  5,CB7->CB7_ORDSEP										,"N","2" ,"25,35") 
			MSCBSAY(80,nLin     ,Alltrim(CB7->CB7_NOTA) + "-"+ Alltrim(CB7->CB7_serie)	,"N","2" ,"25,35") 
			//quadrante 1 
			MSCBLineH(05,nLin-= 2,100,2)
			MSCBLineV(30,nLin,55,2)	
			MSCBLineV(78,nLin,55,2)
			MSCBSAY(10,nLin-=  5,"No. PEDIDO CLIENTE: " + Alltrim(CB7->CB7_PEDIDO)		,"N","2" ,"25,35")  
			
			MSCBLineH(05,nLin-= 2,100,2)
  	
			MSCBSAY(10,nLin-=  5,cDesCli							   					,"N","2" ,"20,30") 
			MSCBSAY(10,nLin-=  5,cCgc	   												,"N","2" ,"20,30") 
			MSCBSAY(10,nLin-=  5,cEndere												,"N","2" ,"20,30")
			MSCBSAY(10,nLin-=  5,cCep + "   "+ cCidad + "   " + cUF						,"N","2" ,"20,30") 
			
			MSCBLineH(05,nLin-= 2,100,2)
			
			MSCBSAY(10,nLin-=  6,cDesTran												,"N","2" ,"20,30") 
			        	
			//MSCBSAYBAR(15,nLin-= 30,ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+CB9->CB9_PROD,"B1_CODBAR")),"N", "MB07",25,.F.,.T.,.F.,,10,3) 
			
			MSCBInfoEti("EMBARQUE","60X100")  
			
		MSCBEND()
	Endif
Endif 

Return .t.