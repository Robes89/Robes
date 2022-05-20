/*
Padrao Zebra
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³IMG05     ºAutor  ³Sandro Valex        º Data ³  19/06/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada referente a imagem de identificacao do     º±±
±±º          ³volume temporario                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function Img05   // imagem de etiqueta de volume temporaria
	Local aArea := GetArea()
	Local cVolume := paramixb[1]
	Local cPedido := paramixb[2]
	Local cNota   := IF(len(paramixb)>=3,paramixb[3],nil)
	Local cSerie  := IF(len(paramixb)>=4,paramixb[4],nil)
	Local cID := CBGrvEti('05',{cVolume,cPedido,cNota,cSerie})
	Local sConteudo
	Local nLin	  := 55
	DBSELECTAREA("CB9")
	DBSETORDER(1)
	DBSEEK(XFILIAL("CB9")+CB7->CB7_ORDSEP)
	while CB9->CB9_FILIAL+CB9_ORDSEP == XFILIAL("CB9")+CB7->CB7_ORDSEP
		nLin	  := 55
		MSCBBEGIN(1,1)  
		MSCBBOX(05,02,100,55,2)
		//primeira linha
		MSCBSAY(10,nLin-=  6,"TEAM TEX: "  	,"N","3" ,"25,35")
		MSCBSAY(45,nLin     ,AllTrim(CB9->CB9_PROD) ,"N","4" ,"25,35") 
		MSCBSAY(80,nLin     ,"Volume: "  	,"N","3" ,"25,35") 
		//segunda linha
		MSCBSAY(10,nLin-=  5,CB7->CB7_ORDSEP	,"N","3" ,"25,35") 
		MSCBSAY(80,nLin     ,STR(VAL(cVolume))+"/"+STR(SC5->C5_VOLUME1)	,"N","3" ,"25,35") 

		//quadrante 1 
		MSCBLineH(05,nLin-= 2,100,2)
		MSCBLineV(30,nLin,55,2)	
		MSCBLineV(78,nLin,55,2)
		MSCBSAY(10,nLin-=  5,SUBSTR(ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+CB9->CB9_PROD,"B1_DESC")),1,45),"N","3" ,"25,35")                 // Descricao produto
		if len(AllTrim(SB1->B1_DESC))>45
			MSCBSAY(10,nLin-=  5,SUBSTR(ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+CB9->CB9_PROD,"B1_DESC")),46,len(AllTrim(SB1->B1_DESC))),"N","3" ,"25,35")                 // Descricao produto
		ENDIF
		//	MSCBSAYBAR(15,nLin-= 30,Alltrim(SB1->B1_CODBAR),"N", "MB07",15,.F.,.T.,.F.,,3,2)
		MSCBSAYBAR(15,nLin-= 30,ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+CB9->CB9_PROD,"B1_CODBAR")),"N", "MB07",25,.F.,.T.,.F.,,10,3)
		//	MSCBSAYBAR(30,01,cCodBar,"N","MB07",24.36,.F.,.F.,.F.,,12,3,.F.,.F.,"1",.T.)
		MSCBInfoEti("Volume","30X100")
		MSCBEND()
		MSCBCLOSEPRINTER() 
		CB9->(DBSKiP())
	ENDDO
	RestArea(aArea)
RETURN()	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMG05OFI  ºAutor  ³Sandro Valex        º Data ³  19/06/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada referente a imagem de identificacao do     º±±
±±º          ³volume permanente."Oficial"                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function Img05OFI // imagem de etiqueta de volume permanente (OFICIAL)
	Local cId     := CBGrvEti('05',{CB6->CB6_VOLUME,CB6->CB6_PEDIDO})
	Local nTotEti := paramixb[1]
	Local nAtu    := paramixb[2]

	Local 	cRot 		:=  'N'
	Local 	cNota		:= 	Alltrim(CB6->CB6_NOTA) 
	Local 	cSerie		:= 	Alltrim(CB6->CB6_SERIE) 
	//12345678901234567890123456789012345678901234567890123456789012345678901234567890	
	Local	cNome		:=  "cliente teste w w w w w w w w w w w w w w w w w wwwwwwwwwwwa" 
	Local 	cNome1		:=  Upper(Subs(cNome,1,30 /*41*/))
	Local 	cNome2		:=  Upper(Subs(cNome,31,50))
	Local	cEnd		:=  "Rua Arlindo Fernando de Oliveira, 135 - bairro do portao wxwxwxwxwxwxwxwxwxwxwxa" 
	Local 	cEnd1		:=  Upper(Subs(cEnd,1,45 /*41*/))
	Local 	cEnd2		:=  Upper(Subs(cEnd,46,80))

	Local 	nLin 		:= 05
	//	MSCBPRINTER("ZEBRA","LPT1",,,/*lSrv 5*/ .F./*F imprime client*/,/*6*/,/*7*/,/*8*/,/*9*/,/*10*/,.F.) //Zebra ZT230
	//	MSCBCHKStatus(.F.)
	MSCBBEGIN(/*nCopias*/1,/*Velocidade*/1)
	MSCBBOX(04,04,98,58)
	MSCBLineH(04,14,98,3,"B")
	MSCBLineV(30,04,14)
	MSCBLineV(70,04,14)

	MSCBSAY( 7,nLin+= 1 ,"NOTA FISCAL"  						,"N","0" ,"25,30") 
	MSCBSAY(34,nLin     ,"R E M E T E N T E" 		 			,"N","0" ,"25,35") 
	MSCBSAY(72,nLin     ,"TOTAL VOL. NF"  	  					,"N","0" ,"25,30")  

	MSCBSAY( 7,nLin+= 4 ,cNota			 	 					,"N","0" ,"25,25") 
	MSCBSAY(31,nLin     ,"TEAM TEX BRASIL ART"  				,"N","0" ,"25,32") 
	MSCBSAY(76,nLin     ,StrZero(nAtu,2)+"/"+StrZero(nTotEti,2)	,"N","0" ,"25,35") 

	MSCBSAY( 7,nLin+= 6 ,"CLIENTE: ","N","0" ,"35,35") 
	MSCBSAY(25,nLin     ,cNome1  	,"N","0" ,"35,30") 
	MSCBSAY(25,nLin+= 5 ,cNome2  	,"N","0" ,"35,30") 
	MSCBSAY( 7,nLin+= 5 ,"END.: "	,"N","0" ,"30,30")  // TRATAR QUEBRA DE LINHA AQUI (FCOL)
	MSCBSAY(17,nLin     ,cEnd1					   		,"N","0" ,"30,25")  
	MSCBSAY(17,nLin+= 4 ,cEnd2					   		,"N","0" ,"30,25")  
	MSCBSAY( 7,nLin+= 5 ,"CEP: 00000-000"		   		,"N","0" ,"30,25")  
	MSCBSAY(30,nLin     ,"CIDADE: [CIDADE]" 			,"N","0" ,"30,25")  
	MSCBSAY(86,nLin     ,"UF: XX"  			 	  		,"N","0" ,"30,25")  
	MSCBSAY(35,nLin+= 6 ,"VOLUME"  			 	  		,"N","0" ,"30,80")  
	MSCBSAYBAR(18,nLin+= 4,"3507460074543","N", "MB07",8,.F.,.T.,.F.,,3,2)

	//	MSCBSAY(fCol(cEnd),nLin+= 10,cEnd   	,"N","0" ,"160,160")
	//	MSCBSAYBAR(30,nLin+= 20,Alltrim(SBE->BE_LOCALIZ),cRot, "MB07",15,.F.,.F.,.F.,,3,2)
	//	MSCBSAY(fCol(cArm)*2,nLin+= 16,cArm+cEnd	,"N","0" ,"020,030")

	MSCBEND()
	MSCBCLOSEPRINTER()
	MS_FLUSH()
Return

