#include 'protheus.ch'
#include 'parmtype.ch'
#include "apvt100.ch"
//-----------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Img01
Ponto de entrada referente a imagem de identificacao de PRODUTO
Padrao DATAMAX
@author Luiz Enrique de Araujo
@since 16/11/2018
@version 1.0
/*/ 
//SB1 DEVE ESTAR POSICIONADO
User Function Img01 //Identificacao de produto

Local cCodigo,sConteudo,cTipoBar, nX
Local nqtde		:= If(len(paramixb) >= 1,paramixb[ 1],NIL)
Local cCodSep 	:= If(len(paramixb) >= 2,paramixb[ 2],NIL)
Local cCodID 	:= If(len(paramixb) >= 3,paramixb[ 3],NIL)
Local nCopias	:= If(len(paramixb) >= 4,paramixb[ 4],0)
Local cNFEnt  	:= If(len(paramixb) >= 5,paramixb[ 5],NIL)
Local cSeriee  	:= If(len(paramixb) >= 6,paramixb[ 6],NIL)
Local cFornec  	:= If(len(paramixb) >= 7,paramixb[ 7],NIL)
Local cLojafo  	:= If(len(paramixb) >= 8,paramixb[ 8],NIL)
Local cArmazem 	:= If(len(paramixb) >= 9,paramixb[ 9],NIL)
Local cOP      	:= If(len(paramixb) >=10,paramixb[10],NIL)
Local cNumSeq  	:= If(len(paramixb) >=11,paramixb[11],NIL)
Local cLote    	:= If(len(paramixb) >=12,paramixb[12],NIL)
Local cSLote   	:= If(len(paramixb) >=13,paramixb[13],NIL)
Local dValid   	:= If(len(paramixb) >=14,paramixb[14],NIL)
Local cCC  		:= If(len(paramixb) >=15,paramixb[15],NIL)
Local cLocOri  	:= If(len(paramixb) >=16,paramixb[16],NIL)
Local cOPREQ   	:= If(len(paramixb) >=17,paramixb[17],NIL)
Local cNumSerie	:= If(len(paramixb) >=18,paramixb[18],NIL)
Local cOrigem  	:= If(len(paramixb) >=19,paramixb[19],NIL)
Local cEndereco	:= If(len(paramixb) >=20,paramixb[20],NIL)
Local cPedido  	:= If(len(paramixb) >=21,paramixb[21],NIL)
Local nResto   	:= If(len(paramixb) >=22,paramixb[22],0)
Local cItNFE   	:= If(len(paramixb) >=23,paramixb[23],NIL)   

Local cProd1:= ""
Local cProd2:= ""
Local cDescr:= ""  
Local nLin	:= 55     
Local cCodPalete   := SuperGetMV("FS_CDPALET",.F.,"P000000000")

//Dados da Empresa:
Local cXCODFIL 	:= SM0->M0_CODIGO + " - " + SM0->M0_CODFIL
Local cXEMPRESA := Capital(Trim(SM0->M0_NOME))
Local cCnpj		:= Transform(SM0->M0_CGC,"@R 99.999.999/9999-99") 
Local cXEMPFIL 	:= Capital(Trim(SM0->M0_FILIAL)) 
Local cXENDERE	:= Capital(Trim(SM0->M0_ENDCOB))
Local cXCIDADE	:= Capital(Trim(SM0->M0_CIDCOB))  
Local cXESTADO	:= Capital(Trim(SM0->M0_ESTCOB))
Local cXCEP		:= Transform(Capital(Trim(SM0->M0_CEPCOB)),"@R 99999-999") 
Local cXTELEFO 	:= Capital(Trim(SM0->M0_TEL)) 

Default nResto	:= 0

If nResto > 0 
   nCopias++
EndIf

If !Empty(SB1->B1_XPALET)  
	If MsgYesNo("Este Produto ja foi paletizado no Palete: " + Alltrim(SB1->B1_XPALET)+ ". Deseja Criar um Novo Palete ?","PALETE/PRODUTO")
		cCodPalete:= Soma1(cCodPalete)  
		PUTMV("FS_CDPALET",cCodPalete)
	Else
		cCodPalete:= Alltrim(SB1->B1_XPALET)
	Endif  
Else
	cCodPalete:= Soma1(cCodPalete)
	PUTMV("FS_CDPALET",cCodPalete)
Endif

IF nCopias == 0
	nCopias:=1
Endif

cCodigo	:= Alltrim(SB1->B1_CODBAR)
cDescr	:= Alltrim(SB1->B1_DESC)  
cTipoBar := 'MB07' //128

If Len(cCodigo) == 8
	cTipoBar := 'MB03'
ElseIf Len(cCodigo) == 13
	cTipoBar := 'MB04'
EndIf

//Trata Tamanho do Nome do Produto
cProd1 := MemoLine(cDescr, 30, 1)
cProd2 := MemoLine(cDescr, 30, 2)

For nX := 1 to nCopias	
	If nResto > 0 .and. nX==nCopias
      	nQtde  := nResto
   	EndIf	
	//MSCBLOADGRF("SIGA.GRF") 
	MSCBBEGIN(1,6) 		
		MSCBBOX(05,02,100,55,2)
		//primeira linha -----------------------------------------------------------------------------------------------------------
		MSCBSAY(10,49,"TEAM TEX: "  		,"N","3" ,"25,35")
		MSCBSAY(32,49,"Palete: "  			,"N","3" ,"25,35") 
		//segunda linha -----------------------------------------------------------------------------------------------------------
		MSCBSAY(60,49,Alltrim(cCodPalete)	,"N","3" ,"35,35")   
		//-------------------------------------------------------------------------------------------------------------------------
		//quadrante 1 
		MSCBLineH(05,40,100,2)
		MSCBLineV(30,40,55,2)	
		//------------------------------------------------------------------------------------------------------------------------- 
		MSCBSAYBAR(15,35,Alltrim(SB1->B1_CODBAR),"N", "MB07",8,.F.,.T.,.F.,,10,3)    
		//-------------------------------------------------------------------------------------------------------------------------
	   	MSCBSAY(60,20,cProd1,"N","3" ,"25,25")   
		MSCBSAY(60,17,cProd2,"N","3" ,"25,25")
		//-------------------------------------------------------------------------------------------------------------------------
		MSCBSAYBAR(15,10,Alltrim(cCodPalete),"N", "MB07",8,.F.,.T.,.F.,,10,3)
		//-------------------------------------------------------------------------------------------------------------------------   	
		MSCBInfoEti("Produto","30X100")			
	MSCBEND()  			   
Next 

//Attualiza o Produto com o último Palete utilizado
SB1->(RecLock("SB1"))
SB1->B1_XPALET:= cCodPalete
SB1->(MsUnlock())

Return sConteudo