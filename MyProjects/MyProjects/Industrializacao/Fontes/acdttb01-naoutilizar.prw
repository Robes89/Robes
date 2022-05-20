User Function acdttb01(paramixbc) //Identificacao de produto
Local cCodigo,sConteudo,cTipoBar, nX
Private cEtiqProd := Space(48)
Private nqtde 	 := If(len(paramixbc) >= 1,paramixbc[ 1],NIL)
Private cCodSep  := If(len(paramixbc) >= 2,paramixbc[ 2],NIL)
Private cCodID 	 := If(len(paramixbc) >= 3,paramixbc[ 3],NIL)
Private nCopias	 := If(len(paramixbc) >= 4,paramixbc[ 4],0)
Private cNota  	 := If(len(paramixbc) >= 5,paramixbc[ 5],NIL)
Private cSerie   := If(len(paramixbc) >= 6,paramixbc[ 6],NIL)
Private cFornec  := If(len(paramixbc) >= 7,paramixbc[ 7],NIL)
Private cLoja    := If(len(paramixbc) >= 8,paramixbc[ 8],NIL)
Private cArmazem:=  If(len(paramixbc) >= 9,paramixbc[ 9],NIL)
Private cOP      := If(len(paramixbc) >=10,paramixbc[10],NIL)
Private cNumSeq  := If(len(paramixbc) >=11,paramixbc[11],NIL)
Private cLote    := If(len(paramixbc) >=12,paramixbc[12],NIL)
Private cSLote   := If(len(paramixbc) >=13,paramixbc[13],NIL)
Private dValid   := If(len(paramixbc) >=14,paramixbc[14],NIL)
Private cCC      := If(len(paramixbc) >=15,paramixbc[15],NIL)
Private cLocOri  := If(len(paramixbc) >=16,paramixbc[16],NIL)
Private cOPREQ   := If(len(paramixbc) >=17,paramixbc[17],NIL)
Private cNumSerie:= If(len(paramixbc) >=18,paramixbc[18],NIL)
Private cOrigem  := If(len(paramixbc) >=19,paramixbc[19],NIL)
Private cEndereco:= If(len(paramixbc) >=20,paramixbc[20],NIL)
Private cPedido  := If(len(paramixbc) >=21,paramixbc[21],NIL)
Private nResto   := If(len(paramixbc) >=22,paramixbc[22],0  )
Private cItNFE   := If(len(paramixbc) >=23,paramixbc[23],NIL)
Private CCODOPE  := If(len(paramixbc) >=24,paramixbc[24],NIL)
Private cUsacb001:=Usacb0("01")
Private aLog     := {}

cLocOri := If(cLocOri==cArmazem,' ',cLocOri)
nQtde   := If(nQtde==NIL,SB1->B1_QE,nQtde)
cCodSep := If(cCodSep==NIL,'',cCodSep)

SB1->(MsSeek(xFilial("SB1")+SD1->D1_COD))
nresto:= 0

If CBProdUnit(SD1->D1_COD) .and. ! CBQtdVar(SD1->D1_COD)
	// quantidade de embalagem fixa no B1_QE
	nQE   := CBQEmbI()
	nQtde := Int(SD1->D1_QUANT/nQE)
	nResto  :=SD1->D1_QUANT%nQE
					
Else
	//granel ou //quantidade de embalagem variada conforme item de nota
	nQE   := SD1->D1_QUANT
	nQtde := 1
EndIf

For I:=1 TO nQe

	If cUsacb001
		cCodigo := If(cCodID ==NIL,CBGrvEti('01',{SB1->B1_COD,nQtde,cCodSep,cNota,cSerie,cFornec,cLoja,cPedido,cEndereco,cArmazem,cOp,cNumSeq,NIL,NIL,NIL,cLote,cSLote,dValid,cCC,cLocOri,NIL,cOPReq,cNumserie,cOrigem,cItNFE}),cCodID)
	Else
		cCodigo := SB1->B1_CODBAR
	EndIf

	cCodigo := Alltrim(cCodigo)
	cTipoBar := 'MB07' //128

	If cUsacb001
		If Len(cCodigo) == 8
			cTipoBar := 'MB03'
		Elseif Len(cCodigo) == 13
			cTipoBar := 'MB04'
		EndIf

		GravaCBE(CB0->CB0_CODETI,SB1->B1_COD,nQtde,cLote,dValid)
	
		dbSelectArea('CB0')
		dbSetOrder(10)
		dbseek(xfilial('CB0')+cNota+cSerie,.F.)
		
		While !Eof() .And.CB0->CB0_NFENT=CNOTA .and. CB0->CB0_SERIEE = CSERIE   
			Reclock("CB0",.f.)
			CB0->CB0_PALLET:=SD1->D1_PALLET 
			CB0->(MsUnlock())
			Dbskip()
		End 
    
	Endif
Next 			    
Return sConteudo


User Function xGeraPallet()
Local nX
//Local cEtiPallet:= CBProxCod("MV_CODCB0")
Local cEtiPallet:= CBProxCod("MV_CODCB0")


CB0->(DbSetOrder(1))
For nX:= 1 to Len(aHisEti)
   If CB0->(DbSeek(xFilial("CB0")+aHisEti[nX])) 
      Reclock("CB0",.f.)
      CB0->CB0_PALLET:= cEtiPallet
      CB0->(MsUnlock())
   Endif
Next

Return


