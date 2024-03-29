/*
Padrao Zebra
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �img01     �Autor  �Sandro Valex        � Data �  19/06/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada referente a imagem de identificacao do     ���
���          �produto. Padrao Microsiga                                   ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/           

User Function Img01 //dispositivo de identificacao de produto
Local cCodigo, sConteudo,cTipoBar, nX
Local nqtde    := If(len(paramixb) >= 1,paramixb[ 1],NIL)
Local cCodSep  := If(len(paramixb) >= 2,paramixb[ 2],NIL)
Local cCodID   := If(len(paramixb) >= 3,paramixb[ 3],NIL)
Local nCopias  := If(len(paramixb) >= 4,paramixb[ 4],0)
Local cNFEnt   := If(len(paramixb) >= 5,paramixb[ 5],NIL)
Local cSeriee  := If(len(paramixb) >= 6,paramixb[ 6],NIL)
Local cFornec  := If(len(paramixb) >= 7,paramixb[ 7],NIL)
Local cLojafo  := If(len(paramixb) >= 8,paramixb[ 8],NIL)
Local cArmazem := If(len(paramixb) >= 9,paramixb[ 9],NIL)
Local cOP      := If(len(paramixb) >=10,paramixb[10],NIL)
Local cNumSeq  := If(len(paramixb) >=11,paramixb[11],NIL)
Local cLote    := If(len(paramixb) >=12,paramixb[12],NIL)
Local cSLote   := If(len(paramixb) >=13,paramixb[13],NIL)
Local dValid   := If(len(paramixb) >=14,paramixb[14],NIL)
Local cCC  	   := If(len(paramixb) >=15,paramixb[15],NIL)
Local cLocOri  := If(len(paramixb) >=16,paramixb[16],NIL)
Local cOPREQ   := If(len(paramixb) >=17,paramixb[17],NIL)
Local cNumSerie:= If(len(paramixb) >=18,paramixb[18],NIL)
Local cOrigem  := If(len(paramixb) >=19,paramixb[19],NIL)
Local cEndereco:= If(len(paramixb) >=20,paramixb[20],NIL)
Local cPedido  := If(len(paramixb) >=21,paramixb[21],NIL)
Local nResto   := If(len(paramixb) >=22,paramixb[22],0)
Local cItNFE   := If(len(paramixb) >=23,paramixb[23],NIL)

cLocOri := If(cLocOri==cArmazem,' ',cLocOri)
nQtde   := If(nQtde==NIL,SB1->B1_QE,nQtde)
cCodSep := If(cCodSep==NIL,'',cCodSep)

/*
If nResto > 0 
   nCopias++
EndIf
*/

For nX := 1 to nCopias
	If cCodID#NIL

		CBRetEti(cCodID)
		nqtde 	 :=CB0->CB0_QTDE
		cCodSep  :=CB0->CB0_USUARI
		cNFEnt   :=CB0->CB0_NFENT
		cSeriee  :=CB0->CB0_SERIEE
		cFornec  :=CB0->CB0_FORNEC
		cLojafo  :=CB0->CB0_LOJAFO
		cArmazem :=CB0->CB0_LOCAL
		cOP      :=CB0->CB0_OP
		cNumSeq  :=CB0->CB0_NUMSEQ
		cLote    :=CB0->CB0_LOTE
		cSLote   :=CB0->CB0_SLOTE
		cCC      :=CB0->CB0_CC
		cLocOri  :=CB0->CB0_LOCORI
		cOPReq	 :=CB0->CB0_OPREQ
		cNumserie:=CB0->CB0_NUMSER		
		cOrigem  :=CB0->CB0_ORIGEM
		cEndereco:=CB0->CB0_LOCALI
		cPedido  :=CB0->CB0_PEDCOM
		cItNFE 	 :=CB0->CB0_ITNFE

	EndIf
	/*
    If nResto > 0 .and. nX==nCopias
      nQtde  := nResto
    EndIf
     */
	If Usacb0("01")
		cCodigo := If(cCodID ==NIL,CBGrvEti('01',{SB1->B1_COD,nQtde,cCodSep,cNFEnt,cSeriee,cFornec,cLojafo,cPedido,cEndereco,cArmazem,cOp,cNumSeq,NIL,NIL,NIL,cLote,cSLote,dValid,cCC,cLocOri,NIL,cOPReq,cNumserie,cOrigem,cItNFE}),cCodID)
	Else
		cCodigo := SB1->B1_CODBAR
	EndIf

	cCodigo := Alltrim(cCodigo)
	cTipoBar := 'MB07' //128
	If ! Usacb0("01")
		If Len(cCodigo) == 8
			cTipoBar := 'MB03'
		ElseIf Len(cCodigo) == 13
			cTipoBar := 'MB04'
		EndIf
	EndIf
	
	
	//MSCBLOADGRF("SIGA.GRF")
	MSCBBEGIN(1,6 )
	MSCBSAY(45,40, AllTrim(SB1->B1_COD), "N", "2", "032,035")
	MSCBSAY(25,35,SB1->B1_DESC,"N", "2", "020,030")

	MSCBSAYBAR(025,20,Alltrim(cCodigo) ,"N","MB07",12.15,.F.,.T.,.F.,,2,3,.F.,.F.,"1",.T.)
		
	If ! Empty(cLote)
		MSCBSAY(40,10,"Lote "+cLote+'-'+cSLote, "N", "2", "032,035")
	EndIf	

	MSCBInfoEti("Produto","30X100")
	sConteudo:=MSCBEND()
		
	If Type('cProgImp')=="C" .and. cProgImp=="ACDV120"
	    GravaCBE(CB0->CB0_CODETI,SB1->B1_COD,nQtdeEmb,cLote,dValid)
	EndIf
		    
Next

Return .f. //sConteudo

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �img01cx   �Autor  �Sandro Valex        � Data �  19/06/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada referente a imagem de identificacao do     ���
���          �produto para caixa a agranel                                ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function Img01CX //dispositivo de identificacao de produto
Local cCodigo,sConteudo,cTipoBar, nX
Local nqtde 	:= If(len(paramixb) >= 1,paramixb[ 1],NIL)
Local cCodSep 	:= If(len(paramixb) >= 2,paramixb[ 2],NIL)
Local cCodID 	:= If(len(paramixb) >= 3,paramixb[ 3],NIL)
Local nCopias	:= If(len(paramixb) >= 4,paramixb[ 4],NIL)
Local cArmazem := If(len(paramixb) >= 5,paramixb[ 5],NIL)
Local cEndereco:= If(len(paramixb) >= 6,paramixb[ 6],NIL)

nQtde   := If(nQtde==NIL,SB1->B1_QE,nQtde)
cCodSep := If(cCodSep==NIL,'',cCodSep)

For nX := 1 to nCopias
	If Usacb0("01")
		cCodigo := If(cCodID ==NIL,CBGrvEti('01',{SB1->B1_COD,nQtde,cCodSep,NIL,NIL,NIL,NIL,NIL,cEndereco,cArmazem,,,,,,,,}),cCodID)
	Else
		cCodigo := SB1->B1_CODBAR
	EndIf
	cCodigo := Alltrim(cCodigo)
	cTipoBar := 'MB07' //128
	If ! Usacb0("01")
		If Len(cCodigo) == 8
			cTipoBar := 'MB03'
		ElseIf Len(cCodigo) == 13
			cTipoBar := 'MB04'
		EndIf
	EndIf
	MSCBLOADGRF("SIGA.GRF")
	MSCBBEGIN(1,6)
	MSCBBOX(30,05,76,05)
	MSCBBOX(02,12.7,76,12.7)
	MSCBBOX(02,21,76,21)
	MSCBBOX(30,01,30,12.7,3)
	MSCBGRAFIC(2,3,"SIGA")
	MSCBSAY(33,02,'CAIXA',"N","0","025,035")
	MSCBSAY(33,06,"CODIGO","N","A","012,008")
	MSCBSAY(33,08, AllTrim(SB1->B1_COD), "N", "0", "032,035")
	MSCBSAY(05,14,"DESCRICAO","N","A","012,008")
	MSCBSAY(05,17,SB1->B1_DESC,"N", "0", "020,030")
	MSCBSAYBAR(23,22,cCodigo,"N",cTipoBar,8.36,.F.,.T.,.F.,,2,1,.F.,.F.,"1",.T.)
	MSCBInfoEti("Produto Granel","30X100")
	sConteudo:=MSCBEND()
Next
Return sConteudo

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �img01De   �Autor  �Sandro Valex        � Data �  19/06/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada referente a imagem de identificacao da     ���
���          �Unidade de despacho                                         ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function Img01DE //dispositivo de identificacao de unidade de despacho produto
Local nCopias 	:= If(len(paramixb) >= 1,paramixb[ 1],NIL)
Local cCodigo 	:= If(len(paramixb) >= 2,Alltrim(paramixb[ 2]),NIL)

MSCBLOADGRF("SIGA.GRF")
MSCBBEGIN(nCopias,6)
	MSCBBOX(30,05,76,05)
	MSCBBOX(02,12.7,76,12.7)
	MSCBBOX(02,21,76,21)
	MSCBBOX(30,01,30,12.7,3)
	MSCBGRAFIC(2,3,"SIGA")
	MSCBSAY(33,02,'UNID. DE DESPACHO',"N","0","025,035")
	MSCBSAY(33,06,"CODIGO","N","A","012,008")
	MSCBSAY(33,08, AllTrim(SB1->B1_COD), "N", "0", "032,035")
	MSCBSAY(05,14,"DESCRICAO","N","A","012,008")
	MSCBSAY(05,17,SB1->B1_DESC,"N", "0", "020,030")
	MSCBSAYBAR(23,22,cCodigo,"N","MB01",8.36,.F.,.T.,.F.,,2,1,.F.,.F.,"1",.T.)  // codigo intercaldo 2 e 5 para EAN14
	MSCBInfoEti("Unid.Despacho","30X100")
sConteudo:=MSCBEND()
Return sConteudo
