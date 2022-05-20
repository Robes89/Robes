#INCLUDE "RWMAKE.CH"
#INCLUDE "MATA410.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"       
#INCLUDE "FWADAPTEREAI.CH"     
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMDEF.CH"
#INCLUDE "FWLIBVERSION.CH"
                                           
#DEFINE ITENSSC6 300
       
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A410QtdGra³ Autor ³ Eduardo Riera         ³ Data ³ 23.02.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua a entrada de dados da quantidade quando a grade esta ³±±
±±³          ³ativa.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Sempre .T.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A410QtdGra()

Local nPProduto	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local nPQtdVen 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
Local nPPrcVen 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})
Local nPQtdLib 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDLIB"})
Local nPQtdVen2 := aScan(aHeader,{|x| AllTrim(x[2])=="C6_UNSVEN"})
Local nPBlq    	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_BLQ"})
Local nColuna 	:= 0
Local lGrade	:= MaGrade() 
Local cCpoName	:= StrTran(ReadVar(),"M->","")
Local lRet 		:= .T.
Local xCampos	:= {"C6_QTDVEN","C6_PRCVEN"}
Local aTotais	:= {}
Local lGrdMult	:= "MATA410" $ SuperGetMV("MV_GRDMULT",.F.,"")

If lGrdMult .And. aScan(xCampos,{|x| x == cCpoName}) > 0
	aAdd(aTotais,"C6_VALOR")
	aAdd(aTotais,"C6_VALDESC")
ElseIf cCpoName # "C6_PRCVEN"
	xCampos := cCpoName
Else
	lGrade := .F.
EndIf
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a grade esta ativa                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( lGrade )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Arrays auxiliares para armazenar a getdados principal³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oGrade:cProdRef	:= aCols[n][nPProduto]
	oGrade:nPosLinO	:= n   
	If oGrade:Show(xCampos,aTotais) .And. oGrade:lOk
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza a quantidade do acols original                                 ³  
		//³ATENCAO: a variavel nQtdInformada foi alimentada dentro do objeto com   ³ 
		//³         ReadVar(), mas o programador pode alimentala quando desejar.   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	          
		DO CASE    
			//POSICIONADO NA QUANTIDADE VENDIDA
			CASE "C6_QTDVEN" $ cCpoName    
				A410MultT("C6_QTDVEN",oGrade:nQtdInformada,.F.)
				aCols[n][nPQtdVen]	:= oGrade:nQtdInformada
				M->C6_QTDVEN		:= oGrade:nQtdInformada
				If ( nPQtdVen2 > 0 )
					oGrade:nQtdInformada := 0
					oGrade:nQtdInformada := oGrade:SomaGrade("C6_UNSVEN",oGrade:nPosLinO,oGrade:nQtdInformada)
					A410MultT("C6_UNSVEN",oGrade:nQtdInformada)
					aCols[n][nPQtdVen2] := oGrade:nQtdInformada
					M->C6_UNSVEN        := oGrade:nQtdInformada				
				EndIf   
			//POSICIONADO NO PRECO UNITARIO
			CASE "C6_PRCVEN" $ cCpoName    
				A410MultT("C6_PRCVEN",oGrade:nQtdInformada,.F.)
				aCols[n][nPPrcVen]	:= oGrade:nQtdInformada
				M->C6_PRCVEN		:= oGrade:nQtdInformada
			//POSICIONADO NA SEGUNDA UNIDADE DE MEDIDA DA QUANTIDADE					
			CASE "C6_UNSVEN" $ cCpoName  
				A410MultT("C6_UNSVEN",oGrade:nQtdInformada)
				aCols[n][nPQtdVen2]	:= oGrade:nQtdInformada
				M->C6_UNSVEN		:= oGrade:nQtdInformada
				oGrade:nQtdInformada:= 0
				oGrade:nQtdInformada:= oGrade:SomaGrade("C6_QTDVEN",oGrade:nPosLinO,oGrade:nQtdInformada)
				A410MultT("C6_QTDVEN",oGrade:nQtdInformada,.F.)
				aCols[n][nPQtdVen]	:= oGrade:nQtdInformada
				M->C6_QTDVEN		:= oGrade:nQtdInformada
			//POSICIONADO NA QUANTIDADE LIBERADA
			CASE "C6_QTDLIB" $ cCpoName
				aCols[n][nPQtdLib]	:= oGrade:nQtdInformada
				M->C6_QTDLIB		:= oGrade:nQtdInformada
			//POSICIONADO NO BLOQUEIO
			CASE "C6_BLQ" $ cCpoName
				aCols[n][nPBlq]	 := PadR("N",Len(SC6->C6_BLQ))
				M->C6_BLQ 		 := PadR("N",Len(SC6->C6_BLQ))
		END CASE
	ElseIf MatGrdPrRf(aCols[n,nPProduto])
		nColuna := aScan(aHeader,{|x| AllTrim(x[2]) == cCpoName})
		&(ReadVar()) := aCols[n,nColuna]
	EndIf
EndIf
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ma410GraGr³ Autor ³Eduardo Riera          ³ Data ³26.02.99  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Esta funcao compatibiliza o acols da grade de produtos com  ³±±
±±³          ³o acols original do pedido de vendas assim nao eh necessario³±±
±±³          ³qualquer modificacao na funcao de gravacao do Pedido de     ³±±
±±³          ³Venda                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Author  ³ BOPS  ³ Manutencao Efetuada                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ma410GraGr()

Local aColsOrig:= aClone(aCols)  //aCols Original
Local nMaxFor  := Len(aColsOrig)
Local nCntFor  := 0     // Contador
Local nPProduto:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local nPItem   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM"})
Local nPItGrade:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEMGRD"})
Local nPPrcVen := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})
Local nPQtdVen := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
Local nPQtdVen2:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_UNSVEN"})
Local nPQtdLib := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDLIB"})
Local nPValor  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"})
Local nPGrade  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_GRADE"})
Local nPValDesc := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALDESC"})
Local nPOpc    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_OPC"})
Local nPDescri := aScan(aHeader,{|x| AllTrim(x[2])=="C6_DESCRI"})
Local nPPrUnit := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRUNIT"})
Local nPBlq    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_BLQ"})
Local nOP      := aScan(aHeader,{|x| AllTrim(x[2])=="C6_NUMOP"})
Local nItemOP  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEMOP"})
Local nComis	 := 0
Local nX		 := 1
Local nZ		 := 0
Local aOP      := {}
Local nLinha   := 0     // Contador de Linhas
Local nColuna  := 0     // Contador de Colunas
Local nAcols   := 0     // Numero de Elementos do Acols
Local cProdRef := ""    // Codigo do Produto Grade
Local cItem    := "00"  // Controle de Itens do Pedido de Venda
Local aColsGrd := {} 	//montara aCols de produtos da grade aqui para poder ordenar pelo codigo
Local aPosCom	 := {}	//Array de campos de comissão na SC6
Local lTestaDel:= If(Len(aColsOrig[1])==Len(aHeader),.F.,.T.)
Local lGrdMult := "MATA410" $ SuperGetMV("MV_GRDMULT",.F.,"")

While nX != 0
	nComis := aScan(aHeader,{|x| AllTrim(x[2])==("C6_COMIS"+AllTrim(Str(nX)))})
	If nComis != 0
		aAdd(aPosCom,nComis)
		nX++
	Else
		nX := 0
	EndIf
EndDo

If MaGrade() .And. Type("oGrade")=="O" .And. Len(oGrade:aColsGrade) > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa o Acols para posterior atualizacao                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols := {}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Varre o acols original para atualizar a variavel aCols                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nCntFor := 1 To nMaxFor
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza o Controle de Itens do Pedido de Venda e da Grade              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cItem    := aColsOrig[nCntFor][nPitem] //Soma1(cItem,Len(SC6->C6_ITEM))
		cItemGrd := StrZero(0,TamSX3("C6_ITEMGRD")[1])
		cProdRef := aColsOrig[nCntFor][nPProduto]
		If ( !Empty(cProdRef) )                   
			oGrade:nPosLinO := nCntFor
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se foi digitado uma referencia                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( Len(oGrade:aHeadGrade) > 0 .And. oGrade:aHeadGrade[nCntFor][1] == "R" )
				For nLinha := 1 To Len(oGrade:aColsGrade[nCntFor])
					For nColuna := 2 To Len(oGrade:aHeadGrade[nCntFor])
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Verifica se a valor a ser gravado                                       ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If ( oGrade:aColsFieldByName("C6_QTDVEN",nCntFor,nLinha,nColuna) <> 0 .And.;
								If(lTestaDel,!aColsOrig[nCntFor][Len(aHeader)+1],.T.) )
							cItemGrd := Soma1(cItemGrd,Len(SC6->C6_ITEMGRD))
							cProdRef := aColsOrig[nCntFor][nPProduto]
							MatGrdPrRf(@cProdRef)                
							cProdRef := oGrade:GetNameProd(cProdRef,nLinha,nColuna) 
							aAdd(aColsGrd,aClone(aColsOrig[nCntFor]))
							nAcols := Len(aColsGrd)
							aColsGrd[nAcols][nPProduto ]  := PadR(cProdRef,Len(SB1->B1_COD))
							aColsGrd[nAcols][nPItem    ]  := cItem
							If ( nPItGrade <> 0 )
								aColsGrd[nAcols][nPItGrade ]  := cItemGrd
							EndIf
							If ( nPQtdVen <> 0 )
								aColsGrd[nAcols][nPQtdVen  ]  := oGrade:aColsFieldByName("C6_QTDVEN",nCntFor,nLinha,nColuna)
							EndIf
							// --- Tratamento OP
							If (nOP <> 0 .And. nItemOP <> 0)
								aOP := A410GrdOP(aColsGrd[nAcols][nPItem],aColsGrd[nAcols][nPProduto])
								aColsGrd[nAcols][nOP]    := aOP[1]
								aColsGrd[nAcols][nItemOP] := aOP[2]
							EndIf
							If ( nPQtdVen2 <> 0 )
								aColsGrd[nAcols][nPQtdVen2 ]  := oGrade:aColsFieldByName("C6_UNSVEN",nCntFor,nLinha,nColuna)
							EndIf
							If ( nPQtdLib <> 0 )
								aColsGrd[nAcols][nPQtdLib  ]  := oGrade:aColsFieldByName("C6_QTDLIB",nCntFor,nLinha,nColuna)
							EndIf
							If ( nPValor <> 0 )
								If lGrdMult
									aColsGrd[nAcols][nPValor   ]  := oGrade:aColsFieldByName("C6_VALOR",nCntFor,nLinha,nColuna)
								Else
									aColsGrd[nAcols][nPValor   ]  := a410Arred(oGrade:aColsFieldByName("C6_QTDVEN",nCntFor,nLinha,nColuna)*aColsOrig[nCntFor][nPPrcVen],"C6_VALOR")
								EndIf
							EndIf
							If  ( nPGrade <>  0 )
								aColsGrd[nAcols][nPGrade   ]  := "S"
							Endif
							If  ( nPValDesc !=  0 )
								If lGrdMult
									aColsGrd[nAcols][nPValDesc]	:= oGrade:aColsFieldByName("C6_VALDESC",nCntFor,nLinha,nColuna)
								Else
									aColsGrd[nAcols][nPValDesc]	:= (aColsOrig[nCntFor][nPValDesc]/aColsOrig[nCntFor][nPQtdVen])*aColsGrd[nAcols][nPQtdVen	]
								EndIf
							EndIf
							If Len(aPosCom) > 0 //Carrega comissão da SB1 para SC6
								dbSelectArea("SB1")
								SB1->(dbSetOrder(1))
								If SB1->(dbSeek(xFilial("SB1")+aColsGrd[nAcols][nPProduto])) .And. SB1->B1_COMIS > 0
									For nZ := 1 To Len(aPosCom)
										aColsGrd[nAcols][aPosCom[nZ]] := SB1->B1_COMIS
									Next nZ
								EndIf
							EndIf
							If  ( nPOpc !=  0 )
								aColsGrd[nAcols][nPOpc]	:= oGrade:aColsFieldByName("C6_OPC",nCntFor,nLinha,nColuna)
							EndIf
							If lGrdMult
								If  ( nPPrcVen != 0 )
									aColsGrd[nAcols][nPPrcVen]	:= oGrade:aColsFieldByName("C6_PRCVEN",nCntFor,nLinha,nColuna)
								EndIf
								If  ( nPDescri != 0 )
									aColsGrd[nAcols][nPDescri]	:= oGrade:aColsFieldByName("C6_DESCRI",nCntFor,nLinha,nColuna)
								EndIf
								If	( nPPrUnit != 0 )
									aColsGrd[nAcols][nPPrUnit]	:= oGrade:aColsFieldByName("C6_PRUNIT",nCntFor,nLinha,nColuna)
								EndIf
								If	(nPBlq != 0 )
									aColsGrd[nAcols][nPBlq]	:= oGrade:aColsFieldByName("C6_BLQ",nCntFor,nLinha,nColuna)
								EndIf
							EndIf
						Else
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se o item ja foi gravado para deleta-lo                        ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If ( !Empty(oGrade:aColsFieldByName("C6_ITEM",nCntFor,nLinha,nColuna)) )
								cProdRef := aColsOrig[nCntFor][nPProduto]
								cItemGrd := Soma1(cItemGrd,Len(SC6->C6_ITEMGRD))
								MatGrdPrRf(@cProdRef) 
								cProdRef := oGrade:GetNameProd(cProdRef,nLinha,nColuna) 
								aAdd(aColsGrd,aClone(aColsOrig[nCntFor]))
								nAcols := Len(aColsGrd)
								aColsGrd[nAcols][nPProduto ]  := PadR(cProdRef,Len(SB1->B1_COD))
								aColsGrd[nAcols][nPItem    ]  := cItem
								If ( nPItGrade <> 0 )
									aColsGrd[nAcols][nPItGrade ]  := cItemGrd
								EndIf
								If ( nPQtdVen <> 0 )
									aColsGrd[nAcols][nPQtdVen  ]  := oGrade:aColsFieldByName("C6_QTDVEN",nCntFor,nLinha,nColuna) 
								EndIf
								// --- Tratamento OP
								If (nOP <> 0 .And. nItemOP <> 0)
									aOP := A410GrdOP(aColsGrd[nAcols][nPItem],aColsGrd[nAcols][nPProduto])
									aColsGrd[nAcols][nOP]    := aOP[1]
									aColsGrd[nAcols][nItemOP] := aOP[2]
								EndIf
								If ( nPQtdLib <> 0 )
									aColsGrd[nAcols][nPQtdLib  ]  := oGrade:aColsFieldByName("C6_QTDLIB",nCntFor,nLinha,nColuna) 
								EndIf
								If ( nPValor <> 0 )
									If lGrdMult
										aColsGrd[nAcols][nPValor   ]  := oGrade:aColsFieldByName("C6_VALOR",nCntFor,nLinha,nColuna) 
									Else
										aColsGrd[nAcols][nPValor   ]  := a410Arred(oGrade:aColsFieldByName("C6_QTDVEN",nCntFor,nLinha,nColuna)*aColsOrig[nCntFor][nPPrcVen],"C6_VALOR")
									EndIf
								EndIf
								If  ( nPGrade <>  0 )
									aColsGrd[nAcols][nPGrade   ]  := "S"
								EndIf
								If  ( nPValDesc !=  0 )
									If lGrdMult
										aColsGrd[nAcols][nPValDesc]	:= oGrade:aColsFieldByName("C6_VALDESC",nCntFor,nLinha,nColuna) 
									Else
										aColsGrd[nAcols][nPValDesc]	:= (aColsOrig[nCntFor][nPValDesc]/aColsOrig[nCntFor][nPQtdVen])*aColsGrd[nAcols][nPQtdVen	]
									EndIf
								EndIf
								If  ( nPOpc !=  0 )
									aColsGrd[nAcols][nPOpc]	:= oGrade:aColsFieldByName("C6_OPC",nCntFor,nLinha,nColuna)
								EndIf
								If lGrdMult
									If  ( nPPrcVen != 0 )
										aColsGrd[nAcols][nPPrcVen]	:= oGrade:aColsFieldByName("C6_PRCVEN",nCntFor,nLinha,nColuna)
									EndIf
									If  ( nPDescri != 0 )
										aColsGrd[nAcols][nPDescri]	:= oGrade:aColsFieldByName("C6_DESCRI",nCntFor,nLinha,nColuna)
									EndIf
									If	( nPPrUnit != 0 )
										aColsGrd[nAcols][nPPrUnit]	:= oGrade:aColsFieldByName("C6_PRUNIT",nCntFor,nLinha,nColuna)
									EndIf
									If	(nPBlq != 0 )
										aColsGrd[nAcols][nPBlq]	:= oGrade:aColsFieldByName("C6_BLQ",nCntFor,nLinha,nColuna)
									EndIf
								EndIf
								aColsGrd[nAcols][Len(aHeader)+1] := .T.
							EndIf
						EndIf
					Next nColuna
				Next nLinha
				
				//--Ordena itens da grade pelo codigo para evitar erro durante alteracoes e liberacoes do PV
				aSort(aColsGrd,,,{|x,y| x[2] < y[2]})
				
				For nAcols := 1 To Len(aColsGrd)
					aColsGrd[nAcols][nPItGrade] := StrZero(nAcols,TamSX3("C6_ITEMGRD")[1])
					aAdd(aCols, aClone(aColsGrd[nAcols]) )
				Next nAcols
			Else
				aAdd(aCols,aClone(aColsOrig[nCntFor]))
				nAcols := Len(aCols)
				aCols[nAcols][nPItem    ]  := cItem
			EndIf
			//--Limpa array temporario utilizado para o sort
			aColsGrd := {}
		EndIf
	Next nCntFor
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ordena o aCols                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols       := aSort(aCols,,,{|x,y| x[nPItem]+x[nPItGrade] < y[nPItem]+y[nPItGrade] })
	oGrade:aColsGrade  := {}
	oGrade:aHeadGrade  := {}
EndIf
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A410Devol³ Autor ³ Henry Fila             ³ Data ³ 07-09-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Consulta de Historicos da Revisao.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                     ³±±
±±³          ³ ExpN1 = Numero do registro                                   ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A410Devol(cAlias,nReg,nOpcx)

	Local aColumns      := {}
	Local aFields       := {}
	Local aIndex	    := {}
    Local aSeek	        := {}    
    Local aSize		    := {}    
    Local aStrtSF1      := {}
	Local aStructSF1    := {}
	Local bBtnDoc		:= {|| ( A410DevoK( oMBrowse, lFornece ), oMBrowse:Refresh() ) }
    Local bBtnForn      := {|| IIF( A410Check( cAliasSF1, cAlias, cMarca, lFornece, nReg, nOpcx ), oDlgDev:End(), ) }
	Local cAliasSF1     := GetNextAlias()
    Local cAliasT       := GetNextAlias()
	Local cMarca	    := ""
	Local cIndice	    := ""
    Local cQuery        := ""    
	Local dDataDe   	:= CToD('  /  /  ')
	Local dDataAte  	:= CToD('  /  /  ')
	Local lFornece  	:= .F.
	Local nX            := 0
	Local oDlgDev		:= Nil
	Local oMBrowse		:= Nil
	Local oTempTable	:= Nil	
	
	Private cFornece 	:= CriaVar("F1_FORNECE",.F.)
	Private cLoja    	:= CriaVar("F1_LOJA",.F.)
	Private lForn    	:= .T.

	If Inclui
		//-- Valida filtro de retorno de doctos fiscais.
		If A410FRet(@lFornece,@dDataDe,@dDataAte,@lForn)
			If lFornece
				oTempTable := FWTemporaryTable():New( cAliasSF1 )
				aIndex := GtIndDevol( @aSeek, @cIndice )
				aColumns := GtColDevol( @aFields,@aStrtSF1,cIndice )
				aSize := FWGetDialogSize( oMainWnd )
				aStructSF1 := {{ "MARK","C",2,0 }}
				cMarca := GetMark()
				cQuery := GtQryDevol( aFields , dDataDe, dDataAte, lForn, lFornece )

				For nX := 1 To Len( aStrtSF1 )
       				aAdd(aStructSF1 ,  aStrtSF1[nX] )
				Next nX

				oTemptable:SetFields( aStructSF1 )

				For nX := 1 To Len( aIndex )
					oTempTable:AddIndex(cValtochar(aIndex[nX,1]), aIndex[nX,2] )
				Next nX

				oTempTable:Create()

				DBUseArea( .T., "TOPCONN", TcGenQry(,, cQuery ), cAliasT, .T., .T. )
				A410RetNF( oTempTable:GetRealName() , aStructSF1, cAliasT , cAliasSF1 )
    
				oDlgDev := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], OemToAnsi( STR0098 ) ,,,, nOr( WS_VISIBLE, WS_POPUP ),,,,, .T. ,,,, .T. ) //"Retorno de Doctos. de Entrada"
				oMBrowse := FWFormBrowse():New()
				oMBrowse:SetDescription( OemToAnsi( STR0098 ) ) //"Retorno de Doctos. de Entrada"
				oMBrowse:AddMarkColumn({|| IIF( ( cAliasSF1 )->MARK == cMarca, "LBOK", "LBNO") },{|| A410SelIt( cAliasSF1, cMarca ) },{|| A410SelAll( cAliasSF1, cMarca ) , oMBrowse:Refresh() })
				oMBrowse:SetOwner( oDlgDev )
				oMBrowse:SetDataQuery( .F. )
				oMBrowse:SetDataTable( .T. )
				oMBrowse:SetAlias( cAliasSF1 )
				oMBrowse:SetColumns( aColumns )
				oMBrowse:SetTemporary( .T. )
				oMBrowse:SetMenuDef( "" )
				oMBrowse:SetProfileID( "BRW_A410DEV" )
				oMBrowse:SetUseFilter( .T. )

				If Len(aSeek) > 0
					oMBrowse:SetSeek( Nil, aSeek )
				Endif
				
				oMBrowse:AddButton( OemtoAnsi(STR0053), bBtnForn, 0, 4, 0,,,,,{ OemtoAnsi( STR0053 ) }) //"Retornar"
				oMBrowse:DisableDetails()
				oMBrowse:DisableReports()
				oMBrowse:Activate()
				oDlgDev:Activate(,,,.T.)   
				
				oTempTable:Delete()

				aSize( aFields, 0 )
				aSize( aColumns, 0 )
				aSize( aSeek, 0 )
				aSize( aIndex, 0 )
				aSize( aSize, 0 )
				aSize( aStructSF1, 0 )
				aSize( aStrtSF1, 0 )
				FreeObj( oMBrowse )
				FreeObj( oDlgDev )
			Else
				
				cQuery := "@ " + A410DevFlt( dDataDe, dDataAte, lForn, lFornece )
				
				If Existblock( "A410RNF" )
					cQuery := ExecBlock(" A410RNF" , .F. , .F. , { dDataDe, dDataAte, lForn, lFornece } )
				EndIf
				
				If  ( Type( "l410Auto" ) <> "U" .And. !l410Auto )
					oMBrowse := FWMBrowse():New()
					oMBrowse:SetFilterDefault( cQuery )
					oMBrowse:SetAlias( "SF1" )
					oMBrowse:SetDescription( OemToAnsi( STR0098 ) )//-- Retorno de Doctos. de Entrada
					oMBrowse:SetIgnoreARotina( .T. )
					oMBrowse:SetMenuDef( "" )
					oMBrowse:DisableReports()
					oMBrowse:AddButton( OemtoAnsi( STR0053 ), bBtnDoc, 0, 4, 0,,,,,{ OemtoAnsi( STR0053 ) } )//"Retornar"
					SF1->( DbSetOrder( 1 ) )
					oMBrowse:Activate()
				Else
					SF1->( DBGoTo( nReg ) )
					A410ProcDv( "SF1", nReg, 4, lFornece, cFornece, cLoja )
				EndIf
			EndIf
		EndIf
	EndIf

	Inclui := !Inclui

Return .T.
                            
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³ A410SelIt   ºAutor  ³ Vendas Clientes º Data ³  04/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Marca e desmarca as notas de retorno de Doctos. de		  º±±
±±º          ³ Entrada.                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA410                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A410SelIt( cAlias, cMarca )

	Local aAreaSF1	:= SF1->(GetArea())
	Local lRet		:= .T.

	If ( cAlias )->( !Eof() )
		dbSelectArea("SF1")
		SF1->(dbSetOrder(2))		
		If SF1->( DBSeek( xFilial("SF1") + cFornece + cLoja + (cAlias)->F1_DOC + (cAlias)->F1_SERIE ) )
			If Empty( ( cAlias )->MARK )
				//Faz o bloqueio do registro que será processado.
				If SF1->( SimpleLock() )
					RecLock( cAlias, .F. )
					( cAlias )->MARK := cMarca
					( cAlias )->( MsUnLock() )
				Else
					Aviso( OemToAnsi( STR0014 ), STR0176, { "OK" } )	//"Atenção"###"Esta Nota Fiscal está sendo utilizada por outro usuário e não poderá ser selecionada."
					SF1->( RestArea( aAreaSF1 ) )
					lRet := .F.
				Endif
			Else
				//Faz o desbloqueio do registro que foi bloqueado pelo SimpleLock().
				SF1->(RecLock("SF1"))
				SF1->(MsUnlock())
				RecLock( cAlias, .F. )
				( cAlias )->MARK := "  "
				( cAlias )->( MsUnLock() )
			Endif
		Endif
    Endif

	aSize( aAreaSF1, 0 )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFunção    ³A410Check ºAutor  ³Vendas e CRM        º Data ³  14/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se possui alguma seleção de NF                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A410Check( cAliasT, cAlias, cMarca, lFornece, nReg, nOpcx )

    Local aAreaTmp  := ( cAliasT )->( GetArea() )
	Local cDocSF1   := ""
    Local lReturn   := .F.
    
    ( cAliasT )->( DbGoTop() )

    While (cAliasT)->(!Eof())
	
        If !Empty( (cAliasT)->MARK )
            cDocSF1 += "( SD1.D1_DOC = '" + ( cAliasT )->F1_DOC + "' AND SD1.D1_SERIE = '" + ( cAliasT )->F1_SERIE + "' ) OR "
        Endif

        ( cAliasT )->( DbSkip() )

    Enddo

	If (cAliasT)->(Eof()) .And. (cAliasT)->(Bof())
		Help( " ", 1, "ARQVAZIO" )
		lReturn := .F.
	Else
		If !Empty( cDocSF1 )
			cDocSF1 := SubStr( cDocSF1 , 1, Len( cDocSF1 ) -3 ) + " )"		
			lReturn := A410DevoK( Nil, lFornece, cAlias, nReg, nOpcx , cDocSF1)
		Else 	
			Help( "", 1, "HELP",, OemToAnsi( STR0187 ), 1, 0 )
		EndIf
	Endif

    RestArea( aAreaTmp )
    aSize( aAreaTmp, 0 )

Return lReturn

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³a410ProcDv³Autor  ³Henry Fila             ³ Data ³07.09.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do cabecalho do pedido de venda                ³±±
±±³          ³ExpN2: Recno do cabecalho do pedido de venda                ³±±
±±³          ³ExpN3: Opcao do arotina                                     ³±±
±±³          ³ExpL3: Se traz baseado em uma entrada (SF1)                 ³±±
±±³          ³       .T. - Se baseia na nota fiscal de entrada            ³±±
±±³          ³       .F. - Copia um pedido de venda Normal                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Esta rotina tem como objetivo efetuar a interface com o usua³±±
±±³          ³rio e o pedido de vendas                                    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A410ProcDv(cAlias,nReg,nOpc,lFornece,cFornece,cLoja,cDocSF1)

Local aArea     := GetArea()
Local aAreaSX3  := SX3->(GetArea())
Local aAreaSF1  := SF1->(GetArea())
Local aAreaSD1  := SD1->(GetArea())
Local aAreaSB8  := SB8->(GetArea())
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aPosGet   := {}
Local aRegSC6   := {}
Local aRegSCV   := {}
Local aInfo     := {}
Local aValor    := {}

Local lLiber 	:= .F.
Local lTransf	:= .F.
Local lContinua := .T.
Local lPoder3   := .T. 
Local lM410PcDv := ExistBlock("M410PCDV")
Local nOpcA		:= 0
Local nUsado    := 0
Local nCntFor   := 0
Local nTotalPed := 0
Local nTotalDes := 0
Local nNumDec   := TamSX3("C6_VALOR")[2]
Local cItem		:= StrZero(0,TamSX3("C6_ITEM")[1])
Local nGetLin   := 0
Local nStack    := GetSX8Len()
Local nPosPrc   := 0
Local nPValDesc := 0
Local nPPrUnit  := 0
Local nPQuant   := 0
Local nSldQtd   := 0
Local nSldQtd2  := 0
Local nSldLiq   := 0
Local nSldBru   := 0
Local nX        := 0
Local nCntSD1   := 0
Local nTamPrcVen:= TamSX3("C6_PRCVEN")[2]

Local cAliasSD1 := "SD1"
Local cAliasSB1 := "SB1"
Local cCodTES   := ""
Local cCadastro := ""
Local cCampo    :=""
Local cTipoPed  :=""
Local cQuery   := ""
Local oDlg
Local oGetd
Local oSAY1
Local oSAY2
Local oSAY3
Local oSAY4
Local aRecnoSE1RA := {} // Array com os titulos selecionados pelo Adiantamento
Local aHeadAGG    := {}
Local aColsAGG    := {}
Local lBenefPodT	:=.F.
Local lCSTOri       := SuperGetMv("MV_CSTORI",.F.,.F.)
Local nPosItOri		:= 0
Local nPosClFis		:= 0
Local cFilSD1		:= xFilial("SD1")

Local cDicCampo  := ""
Local cDicArq    := ""
Local cDicUsado  := ""
Local cDicNivel  := ""
Local cDicTitulo := ""
Local cDicPictur := ""
Local nDicTam    := ""
Local nDicDec    := ""
Local cDicValid  := ""
Local cDicTipo   := ""
Local cDicContex := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas na LinhaOk                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCols      := {}
PRIVATE aHeader    := {}
PRIVATE aHeadFor   := {}
PRIVATE aColsFor   := {}
PRIVATE N          := 1
PRIVATE oGrade	  := MsMatGrade():New('oGrade',,"C6_QTDVEN",,"a410GValid()",{ {VK_F4,{|| A440Saldo(.T.,oGrade:aColsAux[oGrade:nPosLinO][aScan(oGrade:aHeadAux,{|x| AllTrim(x[2])=="C6_LOCAL"})] )}} }) 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0],aGETS[0]

PRIVATE oGetPV	:= Nil

Default lFornece := .F.
Default cFornece := SF1->F1_FORNECE
Default cLoja    := SF1->F1_LOJA
Default cDocSF1  := ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega perguntas do MATA440 e MATA410                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("MTA440",.F.)
lLiber := MV_PAR02 == 1
lTransf:= MV_PAR01 == 1

Pergunte("MTA410",.F.)
//Carrega as variaveis com os parametros da execauto
Ma410PerAut()

SB8->(dbSetOrder(3))

If SoftLock("SF1")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeader                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	M410DicIni("SC6")
	cDicCampo := M410RetCmp()
	cDicArq   := cValToChar(GetSX3Cache(cDicCampo, "X3_ARQUIVO"))

	While !M410DicEOF() .And. cDicArq == "SC6"

		cDicUsado   := GetSX3Cache(cDicCampo, "X3_USADO")
		cDicNivel   := GetSX3Cache(cDicCampo, "X3_NIVEL")

		If (	X3USO(cDicUsado) .And.;
				!( Trim(cDicCampo) == "C6_NUM" );
				.And. Trim(cDicCampo) <> "C6_QTDEMP";
				.And. Trim(cDicCampo) <> "C6_QTDENT";
				.And. cNivel >= cDicNivel )
			nUsado++
			
			cDicTitulo := M410DicTit(cDicCampo)
			cDicPictur := X3Picture(cDicCampo)
			nDicTam    := GetSX3Cache(cDicCampo, "X3_TAMANHO")
			nDicDec    := GetSX3Cache(cDicCampo, "X3_DECIMAL")
			cDicValid  := GetSX3Cache(cDicCampo, "X3_VALID")
			cDicTipo   := GetSX3Cache(cDicCampo, "X3_TIPO")
			cDicContex := GetSX3Cache(cDicCampo, "X3_CONTEXT")

			aAdd(aHeader,{ TRIM(cDicTitulo),;
				cDicCampo,;
				cDicPictur,;
				nDicTam,;
				nDicDec,;
				cDicValid,;
				cDicUsado,;
				cDicTipo,;
				cDicArq,;
				cDicContex } )
		EndIf

		M410PrxDic()
		cDicCampo := M410RetCmp()
		cDicArq   := cValToChar(GetSX3Cache(cDicCampo, "X3_ARQUIVO"))

	EndDo
	If ( lContinua )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem dos itens da Nota Fiscal de Devolucao/Retorno          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SD1")
		dbSetOrder(1)

		cAliasSD1 := "QRYSD1"
		cAliasSB1 := "QRYSD1"
		aStruSD1  := SD1->(dbStruct())
		cQuery    := "SELECT SD1.*,B1_DESC,B1_UM,B1_SEGUM "
		cQuery    += "FROM "+RetSqlName("SD1")+" SD1, "
		cQuery    += RetSqlName("SB1")+" SB1 "
		cQuery    += "WHERE SD1.D1_FILIAL='"+cFilSD1+"' AND "
		If !lFornece
			cQuery    += "SD1.D1_DOC = '"+SF1->F1_DOC+"' AND "
			cQuery    += "SD1.D1_SERIE = '"+SF1->F1_SERIE+"' AND "
		Else
			If !Empty(cDocSF1)
				cQuery += " ( "
				cQuery += cDocSF1 + " AND "
			EndIf
		EndIf
		cQuery    += "SD1.D1_FORNECE = '"+cFornece+"' AND "
		cQuery    += "SD1.D1_LOJA = '"+cLoja+"' AND "
		cQuery    += "SD1.D_E_L_E_T_=' ' AND "

		cQuery    += "SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND "
		cquery    += "SB1.B1_COD = SD1.D1_COD AND "
		cQuery    += "SB1.D_E_L_E_T_=' ' "

		cQuery    += "ORDER BY "+SqlOrder(SD1->(IndexKey()))

		cQuery    := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)

		For nX := 1 To Len(aStruSD1)
			If aStruSD1[nX][2]<>"C"
				TcSetField(cAliasSD1,aStruSD1[nX][1],aStruSD1[nX][2],aStruSD1[nX][3],aStruSD1[nX][4])
			EndIf
		Next nX

		nPosItOri := Ascan(aHeader,{|x| Alltrim(x[2])=="C6_ITEMORI"})
		nPosClFis := Ascan(aHeader,{|x| Alltrim(x[2])=="C6_CLASFIS"})

		While (cAliasSD1)->(! Eof()) .And. (cAliasSD1)->D1_FILIAL == cFilSD1 .And.;
			(cAliasSD1)->D1_FORNECE == cFornece .And.;
			(cAliasSD1)->D1_LOJA == cLoja .And.;
			If(!lFornece,(cAliasSD1)->D1_DOC == SF1->F1_DOC .And.;
							 (cAliasSD1)->D1_SERIE == SF1->F1_SERIE,.T.)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se existe quantidade a ser devolvida                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (cAliasSD1)->D1_QUANT > (cAliasSD1)->D1_QTDEDEV

				cItem := Soma1(cItem)

				SF1->(dbSetOrder(1))
				SF1->(MsSeek(xFilial("SF1")+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_TIPO))

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se existe um tes de devolucao correspondente           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				dbSelectArea("SF4")
				DbSetOrder(1)
				If MsSeek(xFilial("SF4")+(cAliasSD1)->D1_TES)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica o poder de terceiros                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lPoder3 
						lPoder3 := ( SF4->F4_PODER3=="R" ) 
					EndIf

					If Empty(SF4->F4_TESDV) .Or. !(SF4->(MsSeek(xFilial("SF4")+SF4->F4_TESDV)))
						Help(" ",1,"DSNOTESDEV")
						lContinua := .F.
						Exit 
					EndIf
					cCodTES := SF4->F4_CODIGO
					
					If !(lPoder3 .Or. SF1->F1_TIPO=="N")
						Help(" ",1,"A410PODER3")
						lContinua := .F.
						Exit 						
					EndIf
				
				EndIf

				aValor := A410SNfOri((cAliasSD1)->D1_FORNECE,;
											(cAliasSD1)->D1_LOJA,;
											(cAliasSD1)->D1_DOC,;
											(cAliasSD1)->D1_SERIE,;
											If(lPoder3,"",(cAliasSD1)->D1_ITEM),;
											(cAliasSD1)->D1_COD,;
											If(lPoder3,(cAliasSD1)->D1_IDENTB6,),;
											If(lPoder3,(cAliasSD1)->D1_LOCAL,),;
											cAliasSD1,,IIf(lForn,.F.,.T.) )

				nSldQtd:= aValor[1]
				nSldQtd2:=ConvUm((cAliasSD1)->D1_COD,nSldQtd,0,2)
				nSldLiq:= aValor[2]
				nSldBru:= nSldLiq+A410Arred(nSldLiq*(cAliasSD1)->D1_VALDESC/((cAliasSD1)->D1_TOTAL-(cAliasSD1)->D1_VALDESC),"C6_VALOR")

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se existe saldo                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nSldQtd <> 0

					nCntSD1++
					If nCntSD1 > 900  // No. maximo de Itens 
						Exit
					EndIf

					aAdd(aCols,Array(Len(aHeader)+1))
					For nCntFor := 1 To Len(aHeader)
						cCampo := Alltrim(aHeader[nCntFor,2])

						If ( aHeader[nCntFor,10] # "V" .And. !cCampo$"C6_QTDLIB#C6_RESERVA" )

							Do Case

								Case Alltrim(aHeader[nCntFor][2]) == "C6_ITEM"
									aCols[Len(aCols)][nCntFor] := cItem
								Case Alltrim(aHeader[nCntFor][2]) == "C6_PRODUTO"
									aCols[Len(aCols)][nCntFor] := (cAliasSD1)->D1_COD								
									SB1->(dbSetOrder(1))
									SB1->(MsSeek(xFilial("SB1")+(cAliasSD1)->D1_COD))
									aCols[Len(aCols)][nPosClFis] :=  IIf( !Empty(SB1->B1_TS), SB1->B1_TS, SF4->F4_CODIGO ) 
					 				//If ExistTrigger("C6_PRODUTO")
					   			        //		RunTrigger(2,Len(aCols))
								        //	EndIf
								Case Alltrim(aHeader[nCntFor][2]) == "C6_CC"
									aCols[Len(aCols)][nCntFor] := (cAliasSD1)->D1_CC
								Case Alltrim(aHeader[nCntFor][2]) == "C6_CONTA"
									aCols[Len(aCols)][nCntFor] := (cAliasSD1)->D1_CONTA
								Case Alltrim(aHeader[nCntFor][2]) == "C6_ITEMCTA"
									aCols[Len(aCols)][nCntFor] := (cAliasSD1)->D1_ITEMCTA
								Case Alltrim(aHeader[nCntFor][2]) == "C6_CLVL"
									aCols[Len(aCols)][nCntFor] :=(cAliasSD1)->D1_CLVL			
								Case Alltrim(aHeader[nCntFor][2]) == "C6_DESCRI"
									aCols[Len(aCols)][nCntFor] := (cAliasSB1)->B1_DESC
								Case Alltrim(aHeader[nCntFor][2]) == "C6_SEGUM"
									aCols[Len(aCols)][nCntFor] := (cAliasSB1)->B1_SEGUM
								Case Alltrim(aHeader[nCntFor][2]) == "C6_UM"
									aCols[Len(aCols)][nCntFor] := (cAliasSB1)->B1_UM
								Case Alltrim(aHeader[nCntFor][2]) == "C6_UNSVEN"
									aCols[Len(aCols)][nCntFor] := a410Arred(nSldQtd2,"C6_UNSVEN")
								Case Alltrim(aHeader[nCntFor][2]) == "C6_QTDVEN"
									aCols[Len(aCols)][nCntFor] := a410Arred(nSldQtd,"C6_QTDVEN")
								Case Alltrim(aHeader[nCntFor][2]) == "C6_PRCVEN"
									If nTamPrcVen > 2
										aCols[Len(aCols)][nCntFor] := a410Arred(((cAliasSD1)->D1_VUNIT-((cAliasSD1)->D1_VALDESC/(cAliasSD1)->D1_QUANT)),"C6_PRCVEN")
									Else
										aCols[Len(aCols)][nCntFor] := a410Arred(nSldLiq/IIf(nSldQtd==0,1,nSldQtd),"C6_PRCVEN")
									EndIf
								Case Alltrim(aHeader[nCntFor][2]) == "C6_PRUNIT"
									aCols[Len(aCols)][nCntFor] := (cAliasSD1)->D1_VUNIT
								Case Alltrim(aHeader[nCntFor][2]) == "C6_VALOR"
									If nSldQtd <> (cAliasSD1)->D1_QUANT
										If nTamPrcVen > 2
											aCols[Len(aCols)][nCntFor] := a410Arred(nSldQtd*a410Arred(((cAliasSD1)->D1_VUNIT-((cAliasSD1)->D1_VALDESC/(cAliasSD1)->D1_QUANT)),"C6_PRCVEN"),"C6_VALOR")
										Else
											aCols[Len(aCols)][nCntFor] := a410Arred(nSldQtd*a410Arred(nSldLiq/IIf(nSldQtd==0,1,nSldQtd),"C6_PRCVEN"),"C6_VALOR")
										EndIf
									Else
										aCols[Len(aCols)][nCntFor] := nSldLiq
									EndIf
								Case Alltrim(aHeader[nCntFor][2]) == "C6_VALDESC"
									If (cAliasSD1)->D1_VALDESC>0
										aCols[Len(aCols)][nCntFor] := a410Arred(((cAliasSD1)->D1_VUNIT-a410Arred(nSldLiq/IIf(nSldQtd==0,1,nSldQtd),"C6_PRCVEN"))*a410Arred(nSldQtd,"C6_QTDVEN"),"C6_VALDESC")
									Else
										aCols[Len(aCols)][nCntFor] := 0
									EndIf
								Case Alltrim(aHeader[nCntFor][2]) == "C6_DESCONT"
									If (cAliasSD1)->D1_DESC>0
										aCols[Len(aCols)][nCntFor] :=(cAliasSD1)->D1_DESC
									Else
										aCols[Len(aCols)][nCntFor] := 0
									EndIf
								Case Alltrim(aHeader[nCntFor][2]) == "C6_TES"
									aCols[Len(aCols)][nCntFor] := cCodTES
									SF4->(dbSetOrder(1))
									SF4->(MsSeek(xFilial("SF4")+cCodTES))
									If !Empty(Subs(aCols[Len(aCols)][nPosClFis],1,1)) .And. !Empty(SF4->F4_SITTRIB) 
										aCols[Len(aCols)][nPosClFis] :=Subs(aCols[Len(aCols)][nPosClFis],1,1)+SF4->F4_SITTRIB 								
					 				EndIf
					 				//If ExistTrigger("C6_TES    ")
					   				//	RunTrigger(2,Len(aCols))
									//EndIf
								Case Alltrim(aHeader[nCntFor][2]) == "C6_CF"
									aCols[Len(aCols)][nCntFor] := SF4->F4_CF
								Case Alltrim(aHeader[nCntFor][2]) == "C6_NFORI"
									aCols[Len(aCols)][nCntFor] := (cAliasSD1)->D1_DOC
								Case Alltrim(aHeader[nCntFor][2]) == "C6_SERIORI"
									aCols[Len(aCols)][nCntFor] := (cAliasSD1)->D1_SERIE // Deve amarrar pelo ID de controle D1_SERIE sera costrado apenas a serie por causa da picture !!! Manter Projeto Chave Unica.
								Case Alltrim(aHeader[nCntFor][2]) == "C6_ITEMORI" 
									aCols[Len(aCols)][nCntFor] := (cAliasSD1)->D1_ITEM
								Case Alltrim(aHeader[nCntFor][2]) == "C6_NUMLOTE"
									aCols[Len(aCols)][nCntFor] := IIF(SF4->F4_ESTOQUE == "S",(cAliasSD1)->D1_NUMLOTE ,"")
								Case Alltrim(aHeader[nCntFor][2]) == "C6_LOTECTL"
									aCols[Len(aCols)][nCntFor] := IIF(SF4->F4_ESTOQUE == "S",(cAliasSD1)->D1_LOTECTL ,"")
								Case Alltrim(aHeader[nCntFor][2]) == "C6_LOCAL"
									aCols[Len(aCols)][nCntFor] := (cAliasSD1)->D1_LOCAL
								Case Alltrim(aHeader[nCntFor][2]) == "C6_IDENTB6"
									aCols[Len(aCols)][nCntFor] := (cAliasSD1)->D1_IDENTB6
								Case Alltrim(aHeader[nCntFor][2]) == "C6_DTVALID"			
									If SF4->F4_ESTOQUE == "S"
										aCols[Len(aCols)][nCntFor] := (cAliasSD1)->D1_DTVALID
										If SB8->(MsSeek(xFilial("SB8")+(cAliasSD1)->D1_COD+(cAliasSD1)->D1_LOCAL+(cAliasSD1)->D1_LOTECTL+IIf(Rastro((cAliasSD1)->D1_COD,"S"),(cAliasSD1)->D1_NUMLOTE,"")))
											aCols[Len(aCols)][nCntFor] := SB8->B8_DTVALID
										Endif   
									Else
										aCols[Len(aCols)][nCntFor] := CTOD("  /  /  ")
									EndIf
								Case Alltrim(aHeader[nCntFor][2]) == "C6_CLASFIS"
									If lCSTOri .And. !Empty((cAliasSD1)->D1_CLASFIS) .And. !Empty(aCols[Len(aCols)][nPosItOri])
										aCols[Len(aCols)][nCntFor] := (cAliasSD1)->D1_CLASFIS
									Else
										aCols[Len(aCols)][nCntFor] := SB1->B1_ORIGEM+SF4->F4_SITTRIB
									EndIf
								OtherWise
									aCols[Len(aCols)][nCntFor] := CriaVar(cCampo)
							EndCase
						Else
							aCols[Len(aCols)][nCntFor] := CriaVar(cCampo)
						EndIf
					Next nCntFor

					aCols[Len(aCols)][Len(aHeader)+1] := .F.

					If lM410PCDV
						ExecBlock("M410PCDV",.F.,.F.,{cAliasSD1})
					Endif

				Endif

			Endif

			dbSelectArea(cAliasSD1)
			dbSkip()
		EndDo
		dbSelectArea(cAliasSD1)
		dbCloseArea()
		ChkFile("SC6",.F.)
		dbSelectArea("SC6")
		
		If (lContinua)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializa as variaveis de busca do acols                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPosPrc   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})
			nPValDesc := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALDESC"})
			nPPrUnit  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRUNIT"})
			nPQuant   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inici aliza desta forma para criar uma nova instancia de variaveis private³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cria Variaveis de Memoria da Enchoice                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			M410DicIni("SC5")
			cDicCampo := M410RetCmp()
			cDicArq   := cValToChar(GetSX3Cache(cDicCampo, "X3_ARQUIVO"))

			While (!M410DicEOF() .And. (cDicArq == "SC5") )

				cDicContex  := GetSX3Cache(cDicCampo, "X3_CONTEXT")

				If	( cDicContex <> "V" )
					Do Case

					Case Alltrim(cDicCampo) == "C5_TIPO"

						cTipoPed := "" 

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica o tipo da nota para o retorno do pedido     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Do Case
						Case SF1->F1_TIPO == "N" .And. lPoder3
							cTipoPed := "B" 
						Case SF1->F1_TIPO == "B" .And. lPoder3
							cTipoPed := "N" 
							lBenefPodT := .T.
						EndCase

						If Empty(cTipoPed)
							cTipoPed := "D" 
						Endif

						_SetOwnerPrvt(Trim(cDicCampo),cTipoPed )

					Case Alltrim(cDicCampo) == "C5_CLIENTE"
						_SetOwnerPrvt(Trim(cDicCampo),cFornece)
					Case Alltrim(cDicCampo) == "C5_LOJACLI"
						_SetOwnerPrvt(Trim(cDicCampo),cLoja)
					Case Alltrim(cDicCampo) == "C5_EMISSAO"
						_SetOwnerPrvt(Trim(cDicCampo),dDataBase)
					Case Alltrim(cDicCampo) == "C5_CONDPAG"
						_SetOwnerPrvt(Trim(cDicCampo),SF1->F1_COND)
					Case Alltrim(cDicCampo) == "C5_CLIENT"
						_SetOwnerPrvt(Trim(cDicCampo),cFornece)
					Case Alltrim(cDicCampo) == "C5_LOJAENT"
						_SetOwnerPrvt(Trim(cDicCampo),cLoja)
					OtherWise
						_SetOwnerPrvt(Trim(cDicCampo),CriaVar(cDicCampo))
					EndCase
				Else
					_SetOwnerPrvt(Trim(cDicCampo),CriaVar(cDicCampo))
				Endif

				M410PrxDic()
				cDicCampo := M410RetCmp()
				cDicArq   := cValToChar(GetSX3Cache(cDicCampo, "X3_ARQUIVO"))

			EndDo

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Busca o tipo do cliente/fornecedor                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If M->C5_TIPO$"DB"
				SA2->(dbSetOrder(1))
				If SA2->(MsSeek(xFilial("SA2")+M->C5_CLIENTE+M->C5_LOJACLI))
					_SetOwnerPrvt("C5_TIPOCLI",If(SA2->A2_TIPO=="J","R",SA2->A2_TIPO))
				EndIf
			Else
				SA1->(dbSetOrder(1))
				If SA1->(MsSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI))
					_SetOwnerPrvt("C5_TIPOCLI",SA1->A1_TIPO)
				Endif 
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Marca o cliente utilizado para verificar posterior mudanca ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			a410ChgCli(M->C5_CLIENTE+M->C5_LOJACLI)
		Endif

	EndIf
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso nao ache nenhum item , abandona rotina.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( lContinua ) .AND. ( Len(aCols) == 0 )
	lContinua := .F.
EndIf

aRegSC6 := {}
aRegSCV := {}

If ( lContinua )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o array com as formas de pagamento do SX5³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Ma410MtFor(@aHeadFor,@aColsFor)
	A410ReCalc(.F.,lBenefPodT)	

	If ( Type("l410Auto") == "U" .OR. !l410Auto )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz o calculo automatico de dimensoes de objetos     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCadastro := IIF(cCadastro == Nil,OemToAnsi("STR0007"),cCadastro) //"Atualização de Pedidos de Venda"
		aSize := MsAdvSize()
		aObjects := {}
		aAdd( aObjects, { 100, 100, .t., .t. } )
		aAdd( aObjects, { 100, 100, .t., .t. } )
		aAdd( aObjects, { 100, 015, .t., .f. } )
		aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
		aPosObj := MsObjSize( aInfo, aObjects )
		aPosGet := MsObjGetPos(aSize[3]-aSize[1],315,{{003,033,160,200,240,263}} )
		nGetLin := aPosObj[3,1]

		DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Armazenar dados do Pedido anterior.                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF M->C5_TIPO $ "DB"
			aTrocaF3 := {{"C5_CLIENTE","SA2"}}
		Else
			aTrocaF3 := {}
		EndIf
		oGetPV:=MSMGet():New( "SC5", nReg, 3, , , , , aPosObj[1],,3,,,"A415VldTOk",,,.T.)
		A410Limpa(.F.,M->C5_TIPO)
//		@ nGetLin,aPosGet[1,1]  SAY OemToAnsi(IIF(M->C5_TIPO$"DB",STR0008,STR0009)) SIZE 020,09 PIXEL	//"Fornec.:"###"Cliente: "
		@ nGetLin,aPosGet[1,2]  SAY oSAY1 VAR Space(40)						SIZE 120,09 PICTURE "@!"	OF oDlg PIXEL
		@ nGetLin,aPosGet[1,3]  SAY OemToAnsi(STR0011)						SIZE 020,09 OF oDlg PIXEL	//"Total :"
		@ nGetLin,aPosGet[1,4]  SAY oSAY2 VAR 0 PICTURE TM(0,16,Iif(cPaisloc $ "CHI|PAR",NIL,nNumDec))	SIZE 050,09 OF oDlg PIXEL		
		@ nGetLin,aPosGet[1,5]  SAY OemToAnsi(STR0012)						SIZE 030,09 OF oDlg PIXEL 	//"Desc. :"
		@ nGetLin,aPosGet[1,6]  SAY oSAY3 VAR 0 PICTURE TM(0,16,Iif(cPaisloc $ "CHI|PAR",NIL,nNumDec))		SIZE 050,09 OF oDlg PIXEL RIGHT
		@ nGetLin+10,aPosGet[1,5]  SAY OemToAnsi("=")							SIZE 020,09 OF oDlg PIXEL
		If cPaisLoc == "BRA"				
			@ nGetLin+10,aPosGet[1,6]  SAY oSAY4 VAR 0								SIZE 050,09 PICTURE TM(0,16,2) OF oDlg PIXEL RIGHT
		Else
			@ nGetLin+10,aPosGet[1,6]  SAY oSAY4 VAR 0								SIZE 050,09 PICTURE TM(0,16,Iif(cPaisloc $ "CHI|PAR",NIL,nNumDec)) OF oDlg PIXEL RIGHT
		EndIf
		oDlg:Cargo	:= {|c1,n2,n3,n4| oSay1:SetText(c1),;
			oSay2:SetText(n2),;
			oSay3:SetText(n3),;
			oSay4:SetText(n4) }
		Set Key VK_F4 to A440Stok(NIL,"A410")
		oGetd:=MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],3,"A410LinOk","A410TudOk","+C6_ITEM/C6_Local/C6_TES/C6_CF/C6_PEDCLI",.T.,,1,,ITENSSC6*IIF(MaGrade(),1,3.33),"A410Blq()")
		Private oGetDad:=oGetd
		A410Bonus(2)
		Ma410Rodap(oGetD,nTotalPed,nTotalDes)
		ACTIVATE MSDIALOG oDlg ON INIT Ma410Bar(oDlg,{||nOpcA:=1,if(A410VldTOk(nOpc).And.oGetd:TudoOk(),If(!obrigatorio(aGets,aTela),nOpcA := 0,oDlg:End()),nOpcA := 0)},{||oDlg:End()},nOpc,oGetD,nTotalPed,@aRecnoSE1RA,@aHeadAGG,@aColsAGG)
		SetKey(VK_F4,)
	Else
		nOpca := 1
	EndIf
	If ( nOpcA == 1 )
		A410Bonus(1)
		If a410Trava()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializa a gravacao dos lancamentos do SIGAPCO          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			PcoIniLan("000100")
			If !A410Grava(lLiber,lTransf,2,aHeadFor,aColsFor,aRegSC6,aRegSCV,nStack,,aRecnoSE1RA,aHeadAGG,aColsAGG)
				Help(" ",1,"A410NAOREG")
			EndIf
			If ( (ExistBlock("M410STTS") ) )
				ExecBlock("M410STTS",.F.,.F.,{7})	// 7- Identificar a operação da devolução
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza a gravacao dos lancamentos do SIGAPCO            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			PcoFinLan("000100")
		EndIf
	Else
		While GetSX8Len() > nStack
			RollBackSX8()
		EndDo
		If ( (ExistBlock("M410ABN")) )
			ExecBlock("M410ABN",.f.,.f.)
		EndIf
	EndIf
Else
	While GetSX8Len() > nStack
		RollBackSX8()
	EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpa cliente anterior para proximo pedido                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
a410ChgCli("")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Destrava Todos os Registros                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsUnLockAll()

RestArea(aAreaSX3)
RestArea(aAreaSF1)
RestArea(aAreaSD1)
RestArea(aAreaSB8)
RestArea(aArea)
Return( nOpcA )                

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ma410NFVP3³ Autor ³ Eduardo Riera         ³ Data ³           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ma410NFVP3()

Local aArea			:= GetArea("SC5")
Local cAliasSB6 	:= "SB6"
Local nX	    	:= 0
Local cFilSC6		:= xFilial("SC6")
Local cFilSB6		:= xFilial("SB6")
Local cFilSD2		:= xFilial("SD2")
Local cFilSD1		:= xFilial("SD1")
Local nTmD1Total	:= GetSX3Cache("D1_TOTAL",   "X3_TAMANHO")
Local nDcD1Total	:= GetSX3Cache("D1_TOTAL",   "X3_DECIMAL")
Local nTmD1ValDsc	:= GetSX3Cache("D1_VALDESC", "X3_TAMANHO")
Local nTmD2Total	:= GetSX3Cache("D2_TOTAL",   "X3_TAMANHO")
Local nDcD2Total	:= GetSX3Cache("D2_TOTAL",   "X3_DECIMAL")
Local nTmD2Descon	:= GetSX3Cache("D2_DESCON",  "X3_TAMANHO")
Local nDcD2Descon	:= GetSX3Cache("D2_DESCON",  "X3_DECIMAL")

dbSelectArea("SC6")
dbSetOrder(1)
MsSeek(cFilSC6+SC5->C5_NUM)
While SC6->(! Eof()) .And. SC6->C6_FILIAL == cFilSC6 .And. SC6->C6_NUM == SC5->C5_NUM
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica os produto que possuem poder de terceiro neste cliente ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SB6")
	dbSetOrder(2)
	cAliasSB6 := "F4PODER3_SQL"
	cQuery := "SELECT DISTINCT(SD1.R_E_C_N_O_) SD1RECNO,D1_TOTAL,D1_VALDESC,0 SD2RECNO,0 D2_TOTAL,0 D2_DESCON,D1_LOTECTL,D1_NUMLOTE,"
	cQuery += "B6_FILIAL,B6_PRODUTO,B6_CLIFOR,B6_LOJA,B6_PODER3,B6_IDENTB6,B6_TPCF,B6_QUANT,B6_QULIB "
	cQuery += "FROM "+RetSqlName("SB6")+" SB6 ,"
	cQuery += RetSqlName("SD2")+" SD2 "
	cQuery += "WHERE SB6.B6_FILIAL='"+cFilSB6+"' AND "
	cQuery += "SB6.B6_PRODUTO='"+SC6->C6_PRODUTO+"' AND "
	cQuery += "SB6.B6_CLIFOR='"+SC5->C5_CLIENTE+"' AND "
	cQuery += "SB6.B6_LOJA='"+SC5->C5_LOJACLI+"' AND "
	cQuery += "SB6.B6_PODER3='R' AND "
	cQuery += "SB6.B6_TPCF = 'C' AND "
	cQuery += "SB6.D_E_L_E_T_=' ' AND "
	cQuery += "SB6.B6_TIPO='E' AND "
	cQuery += "SD2.D2_FILIAL='"+cFilSD2+"' AND "
	cQuery += "SD2.D2_NUMSEQ=SB6.B6_IDENT AND "
	cQuery += "SD2.D_E_L_E_T_=' ' "
	cQuery += "UNION ALL "
	cQuery += "SELECT DISTINCT(0) SD1RECNO,0 D1_TOTAL,0 D1_VALDESC,SD2.R_E_C_N_O_ SD2RECNO,D2_TOTAL,D2_DESCON, '' D1_LOTECTL, '' D1_NUMLOTE,"
	cQuery += "B6_FILIAL,B6_PRODUTO,B6_CLIFOR,B6_LOJA,B6_PODER3,B6_IDENTB6,B6_TPCF,B6_QUANT,B6_QULIB "
	cQuery += "FROM "+RetSqlName("SB6")+" SB6 ,"
	cQuery += RetSqlName("SD1")+" SD1 "
	cQuery += "WHERE SB6.B6_FILIAL='"+cFilSB6+"' AND "
	cQuery += "SB6.B6_PRODUTO='"+SC6->C6_PRODUTO+"' AND "
	cQuery += "SB6.B6_CLIFOR='"+SC5->C5_CLIENTE+"' AND "
	cQuery += "SB6.B6_LOJA='"+SC5->C5_LOJACLI+"' AND "
	cQuery += "SB6.B6_PODER3='D' AND "
	cQuery += "SB6.B6_TPCF = 'C' AND "
	cQuery += "SB6.D_E_L_E_T_=' ' AND "
	cQuery += "SB6.B6_TIPO='E' AND "
	cQuery += "SD1.D1_FILIAL='"+cFilSD1+"' AND "
	cQuery += "SD1.D1_DOC=SB6.B6_DOC AND "
	cQuery += "SD1.D1_SERIE=SB6.B6_SERIE AND "
	cQuery += "SD1.D1_FORNECE=SB6.B6_CLIFOR AND "
	cQuery += "SD1.D1_LOJA=SB6.B6_LOJA AND "
	cQuery += "SD1.D1_LOCAL=SB6.B6_LOCAL AND "
	cQuery += "SD1.D1_COD=SB6.B6_PRODUTO AND "
	cQuery += "SD1.D1_IDENTB6=SB6.B6_IDENT AND "
	cQuery += "SD1.D1_QUANT=SB6.B6_QUANT AND "
	cQuery += "SD1.D_E_L_E_T_=' ' "

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB6,.T.,.T.)

	TcSetField(cAliasSD1,"D1_TOTAL",  "N", nTmD1Total,  nDcD1Total)
	TcSetField(cAliasSD1,"D1_VALDESC","N", nTmD1ValDsc, nDcD1Total)
	TcSetField(cAliasSD1,"D2_TOTAL",  "N", nTmD2Total,  nDcD2Total)
	TcSetField(cAliasSD1,"D2_DESCON", "N", nTmD2Descon, nDcD2Descon)
	TcSetField(cAliasSD1,"SD1RECNO",  "N", 12, 0 )
	TcSetField(cAliasSD1,"SD2RECNO",  "N", 12, 0 )

	While !Eof() .And. (cAliasSB6)->B6_FILIAL = cFilSB6 .And.;
		(cAliasSB6)->B6_PRODUTO == cProduto .And.;
		IIF(IsTriangular(),.T.,(cAliasSB6)->B6_CLIFOR == cCliFor .And.;
		(cAliasSB6)->B6_LOJA == cLoja )

		If lMtProcP3
			lProcessa := ExecBlock("MTPROCP3",.F.,.F.,{cAliasSB6,.T.}) // Segundo parametro era o antigo lQuery fora de utilização a partir 2017 
		Endif

		If lProcessa
			If ((cES == "E" .And. (cAliasSB6)->B6_TIPO == "E") .Or. (cES == "S" .And. (cAliasSB6)->B6_TIPO == "D") ) .And. (cAliasSB6)->B6_TPCF==cTpCliFor
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verificar qual eh a tabela de origem do poder de terceiros          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ((cAliasSB6)->B6_TIPO=="D" .And. (cAliasSB6)->B6_PODER3 == "R" ) .Or. ((cAliasSB6)->B6_TIPO=="E" .And. (cAliasSB6)->B6_PODER3 == "D")
					dbSelectArea("SD1")
					If (cAliasSB6)->B6_PODER3 == "R"
						dbSetOrder(4)
						MsSeek(cFilSD1+(cAliasSB6)->B6_IDENT)
					Else
						dbSetOrder(1)
						MsSeek(cFilSD1+(cAliasSB6)->B6_DOC+(cAliasSB6)->B6_SERIE+(cAliasSB6)->B6_CLIFOR+(cAliasSB6)->B6_LOJA+(cAliasSB6)->B6_PRODUTO)
						While SD1->(! Eof()) .And. cFilSD1 == SD1->D1_FILIAL .And.;
							(cAliasSB6)->B6_DOC == SD1->D1_DOC .And.;
							(cAliasSB6)->B6_SERIE == SD1->D1_SERIE .And.;
							(cAliasSB6)->B6_CLIFOR == SD1->D1_FORNECE .And.;
							(cAliasSB6)->B6_LOJA == SD1->D1_LOJA .And.;
							(cAliasSB6)->B6_PRODUTO == SD1->D1_COD
							If (cAliasSB6)->B6_IDENT==SD1->D1_IDENTB6 .And. (cAliasSB6)->B6_QUANT=SD1->D1_QUANT
								Exit
							EndIf
							SD1->(dbSkip())
						EndDo
					EndIf
				Else
					dbSelectArea("SD2")
					If (cAliasSB6)->B6_PODER3=="R"
						dbSetOrder(4)
						MsSeek(cFilSD2+(cAliasSB6)->B6_IDENT)
					Else
						dbSetOrder(3)
						MsSeek(cFilSD2+(cAliasSB6)->B6_DOC+(cAliasSB6)->B6_SERIE+(cAliasSB6)->B6_CLIFOR+(cAliasSB6)->B6_LOJA+(cAliasSB6)->B6_PRODUTO)
						While SD2->(! Eof()) .And. cFilSD2 == SD2->D2_FILIAL .And.;
							(cAliasSB6)->B6_DOC == SD2->D2_DOC .And.;
							(cAliasSB6)->B6_SERIE == SD2->D2_SERIE .And.;
							(cAliasSB6)->B6_CLIFOR == SD2->D2_CLIENTE .And.;
							(cAliasSB6)->B6_LOJA == SD2->D2_LOJA .And.;
							(cAliasSB6)->B6_PRODUTO == SD2->D2_COD
							If (cAliasSB6)->B6_IDENT==SD2->D2_IDENTB6 .And. (cAliasSB6)->B6_QUANT=SD2->D2_QUANT
								Exit
							EndIf
							SD2->(dbSkip())
						EndDo
					EndIf
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calculo do saldo em valor e quantidade para devolucao de terceiros  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nSldQtd := 0
				nSldBru := 0
				nSldLiq := 0
				If Empty((cAliasSB6)->B6_IDENTB6)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Na primeira remessa deve-se tirar os valores contidos na interface  ³
					//³ para evitar baixa de saldo maior que o disponivel                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If cES == "E"
						For nX := 1 To Len(aCols)
							If nX <> N .And. !aCols[nX][Len(aHeader)+1] .And. aCols[nX][nPIdentB6]==(cAliasSB6)->B6_IDENT
								nSldQtd -= aCols[nX][nPQuant]
								nSldBru -= aCols[nX][nPValor]
							EndIf
						Next nX
					Else
						For nX := 1 To Len(aCols)
							If nX <> N .And. !aCols[nX][Len(aHeader)+1] .And. aCols[nX][nPIdentB6]==(cAliasSB6)->B6_IDENT
								nSldQtd -= aCols[nX][nPQuant]
								nSldLiq -= aCols[nX][nPValor]
								
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Desconsidera a quantidade ja faturada                               ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If !Empty( cNumPV )
									SC6->( dbSetOrder( 1 ) )
									If SC6->( MsSeek( cFilSC6 + cNumPv + aCols[nX, nPItem ] ) )
										nSldQtd += SC6->C6_QTDENT
										nSldLiq += aCols[nX,nPUnit] * SC6->C6_QTDENT
										nSldLiq := A410Arred( nSldLiq, "C6_VALOR" )
									EndIf
								EndIf
								
							EndIf
						Next nX
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Calculo do saldo do poder de terceiros                              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nSldQtd  += (cAliasSB6)->B6_QUANT-(cAliasSB6)->B6_QULIB
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Calculo do saldo do poder de terceiros                              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nSldQtd  -= (cAliasSB6)->B6_QUANT-(cAliasSB6)->B6_QULIB
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verificar qual eh a tabela de origem do poder de terceiros e calcula³
				//³ o valor total do saldo de poder de/em terceiros                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ((cAliasSB6)->B6_TIPO=="D" .And. (cAliasSB6)->B6_PODER3 == "R" ) .Or. ((cAliasSB6)->B6_TIPO=="E" .And. (cAliasSB6)->B6_PODER3 == "D")
					If (cAliasSB6)->B6_PODER3 == "R"
						nSldLiq += (cAliasSD1)->D1_TOTAL-(cAliasSD1)->D1_VALDESC
						nSldBru += nSldLiq+A410Arred(nSldLiq*(cAliasSD1)->D1_VALDESC/((cAliasSD1)->D1_TOTAL-(cAliasSD1)->D1_VALDESC),"C6_VALOR")
					Else
						nSldLiq -= (cAliasSD1)->D1_TOTAL-(cAliasSD1)->D1_VALDESC
						nSldBru -= Abs(nSldLiq)+A410Arred(Abs(nSldLiq)*(cAliasSD1)->D1_VALDESC/((cAliasSD1)->D1_TOTAL-(cAliasSD1)->D1_VALDESC),"C6_VALOR")
					EndIf
				Else
					If (cAliasSB6)->B6_PODER3 == "R"
						nSldBru += (cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_DESCON
						nSldLiq += nSldBru-A410Arred(nSldBru*(cAliasSD2)->D2_DESCON/((cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_DESCON),"C6_VALOR")
					Else
						nSldBru -= (cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_DESCON
						nSldLiq -= Abs(nSldBru)-A410Arred(Abs(nSldBru)*(cAliasSD2)->D2_DESCON/((cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_DESCON),"C6_VALOR")
					EndIf
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza o arquivo temporario com os dados do poder de terceiro     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea(cAliasTRB)
				dbSetOrder(3)
				If nSldQtd <> 0 .Or. nSldLiq <> 0
					If !Empty((cAliasSB6)->B6_IDENTB6)
						(cAliasTRB)->(MsSeek((cAliasSB6)->B6_IDENTB6))
					Else
						(cAliasTRB)->(MsSeek((cAliasSB6)->B6_IDENT))
					EndIf
					If (cAliasTRB)->(!Found())
						RecLock(cAliasTRB,.T.)
						For nX := 1 To Len(aStruTRB)
							If !( AllTrim(aStruTRB[nX][1])$"B6_SALDO#B6_TOTALL#B6_TOTALB#B6_QULIB" ) .AND.;
								(cAliasSB6)->(ColumnPos(aStruTRB[nX][1])) <> 0                        .AND.;
								(cAliasTrb)->(ColumnPos(aStruTRB[nX][1])) <> 0

								(cAliasTRB)->(FieldPut(nX,(cAliasSB6)->(FieldGet(ColumnPos(aStruTRB[nX][1])))))
							EndIf
						Next nX
					Else
						RecLock(cAliasTRB)
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica o documento original para obter alguns dados posteriores   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Empty((cAliasSB6)->B6_IDENTB6)
						For nX := 1 To Len(aStruTRB)
							If !( AllTrim(aStruTRB[nX][1]) $ "B6_SALDO#B6_TOTALL#B6_TOTALB#B6_QULIB" ) .AND.;
								(cAliasSB6)->(ColumnPos(aStruTRB[nX][1])) <> 0                          .AND.;
								(cAliasTRB)->(ColumnPos(aStruTRB[nX][1])) <> 0

								(cAliasTRB)->(FieldPut(nX,(cAliasSB6)->(FieldGet(ColumnPos(aStruTRB[nX][1])))))
							EndIf
						Next nX
						
						If (cAliasSB6)->B6_TIPO=="D"
							(cAliasTRB)->SD1RECNO := (cAliasSD1)->SD1RECNO 
						Else
							(cAliasTRB)->SD2RECNO := (cAliasSD2)->SD2RECNO
						EndIf
					EndIf
					(cAliasTRB)->B6_SALDO += a410Arred(nSldQtd,"C6_QTDVEN")
					(cAliasTRB)->B6_QULIB += a410Arred((cAliasSB6)->B6_QULIB,"C6_QTDVEN")
					(cAliasTRB)->B6_TOTALL+= nSldLiq
					(cAliasTRB)->B6_TOTALB+= nSldBru
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Calcula o valor unitario do poder de terceiros                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					(cAliasTRB)->B6_PRCVEN:= a410Arred((cAliasTRB)->B6_TOTALL/((cAliasTRB)->B6_SALDO+(cAliasTRB)->B6_QULIB),"D2_PRCVEN")
					(cAliasTRB)->B6_PRUNIT:= a410Arred((cAliasTRB)->B6_TOTALB/((cAliasTRB)->B6_SALDO+(cAliasTRB)->B6_QULIB),"D2_PRCVEN")
					If cES == "E"
						(cAliasTRB)->D2_LOTECTL:= (cAliasSD2)->D2_LOTECTL
						(cAliasTRB)->D2_NUMLOTE:= (cAliasSD2)->D2_NUMLOTE
					Else
						(cAliasTRB)->D1_LOTECTL:= (cAliasSD1)->D1_LOTECTL
						(cAliasTRB)->D1_NUMLOTE:= (cAliasSD1)->D1_NUMLOTE
					EndIf
					MsUnLock()
				EndIf
			EndIf
		EndIf
		dbSelectArea(cAliasSB6)
		dbSkip()
	EndDo
EndDo
If lQuery
	dbSelectArea(cAliasSB6)
	dbCloseArea()
	dbSelectArea("SB6")
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retira os documentos totalmente devolvidos                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAliasTRB)
dbClearIndex()
dbGotop()
While !Eof()
	If (cAliasTRB)->B6_SALDO<=0
		dbDelete()
	EndIf
	dbSkip()
EndDo
Pack
aNomInd := {}
For nX := 1 To Len(aChave)
	aAdd(aNomInd,SubStr(cNomeTrb,1,7)+chr(64+nX))
	IndRegua(cAliasTRB,aNomInd[nX],aChave[nX])
Next nX
dbClearIndex()
For nX := 1 To Len(aNomInd)
	dbSetIndex(aNomInd[nX])
Next nX
dbSetOrder(1)
dbGotop()
PRIVATE aHeader := aHeadTRB
xPesq := aPesq[(cAliasTRB)->(IndexOrd())][1]
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona registros                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTpCliFor == "C"
	dbSelectArea("SA1")
	dbSetOrder(1)
	MsSeek(xFilial("SA1")+cCliFor+cLoja)
Else
	dbSelectArea("SA2")
	dbSetOrder(1)
	MsSeek(xFilial("SA2")+cCliFor+cLoja)
EndIf
dbSelectArea("SB1")
dbSetOrder(1)
MsSeek(xFilial("SB1")+cProduto)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula as coordenadas da interface                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize[1] /= 1.5
aSize[2] /= 1.5
aSize[3] /= 1.5
aSize[4] /= 1.3
aSize[5] /= 1.5
aSize[6] /= 1.3
aSize[7] /= 1.5

aAdd( aObjects, { 100, 020,.T.,.F.,.T.} )
aAdd( aObjects, { 100, 060,.T.,.T.} )
aAdd( aObjects, { 100, 020,.T.,.F.} )
aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Interface com o usuario                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !(cAliasTRB)->(Eof())
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0075) FROM aSize[7],000 TO aSize[6],aSize[5] OF oMainWnd PIXEL //"Documentos de Origem"
	@ aPosObj[1,1],aPosObj[1,2] MSPANEL oPanel PROMPT "" SIZE aPosObj[1,3],aPosObj[1,4] OF oDlg CENTERED LOWERED
	If !IsTriangular()
		If cTpCliFor == "C"
			cTexto1 := AllTrim(RetTitle("F2_CLIENTE"))+"/"+AllTrim(RetTitle("F2_LOJA"))+": "+SA1->A1_COD+"/"+SA1->A1_LOJA+"  -  "+RetTitle("A1_NOME")+": "+SA1->A1_NOME
		Else
			cTexto1 := AllTrim(RetTitle("F1_FORNECE"))+"/"+AllTrim(RetTitle("F1_LOJA"))+": "+SA2->A2_COD+"/"+SA2->A2_LOJA+"  -  "+RetTitle("A2_NOME")+": "+SA2->A2_NOME
		EndIf
	Else
		cTexto1 := STR0076 //"Operacao Triangular"
	EndIf
	@ 002,005 SAY cTexto1 SIZE aPosObj[1,3],008 OF oPanel PIXEL
	cTexto2 := AllTrim(RetTitle("B1_COD"))+": "+SB1->B1_COD+"/"+SB1->B1_DESC
	@ 012,005 SAY cTexto2 SIZE aPosObj[1,3],008 OF oPanel PIXEL
	oGetDb := MsGetDB():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],1,"Allwaystrue","allwaystrue","",.F., , ,.F., ,cAliasTRB)

	DEFINE SBUTTON FROM aPosObj[3,1]+000,aPosObj[3,4]-030 TYPE 1 ACTION (nOpcA := 1,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM aPosObj[3,1]+012,aPosObj[3,4]-030 TYPE 2 ACTION (nOpcA := 0,oDlg:End()) ENABLE OF oDlg

	@ aPosObj[3,1]+00,aPosObj[3,2]+00 SAY OemToAnsi(STR0077) PIXEL //"Pesquisar por:"
	@ aPosObj[3,1]+12,aPosObj[3,2]+00 SAY OemToAnsi(STR0078) PIXEL //"Localizar"
	@ aPosObj[3,1]+00,aPosObj[3,2]+40 MSCOMBOBOX oCombo VAR cCombo ITEMS aOrdem SIZE 100,044 OF oDlg PIXEL ;
	                                  VALID ((cAliasTRB)->(dbSetOrder(oCombo:nAt)),(cAliasTRB)->(dbGotop()),xPesq := aPesq[(cAliasTRB)->(IndexOrd())][1],.T.)
	@ aPosObj[3,1]+12,aPosObj[3,2]+40 MSGET oGet VAR xPesq Of oDlg PICTURE aPesq[(cAliasTRB)->(IndexOrd())][2] PIXEL ;
	                                  VALID ((cAliasTRB)->(MsSeek(Iif(ValType(xPesq)=="C",AllTrim(xPesq),xPesq),.T.)),.T.).And.IIf(oGetDb:oBrowse:Refresh()==Nil,.T.,.T.)
	FATPDLogUser("MA410NFVP3")
	ACTIVATE MSDIALOG oDlg CENTERED
Else
	Help(" ",1,"F4NAONOTA")
	lRetorno := .F.
EndIf
If nOpcA == 1
	lRetorno := .T.
	aHeader   := aClone(aSavHead)
	If cES == "S"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica os campos a serem atualizados                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPNfOri   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_NFORI"})
		nPSerOri  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_SERIORI"})
		nPItemOri := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEMORI"})
		nPLocal   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOCAL"})
		nPPrUnit  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRUNIT"})
		nPPrcVen  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})
		nPQuant   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
		nPQuant2UM:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_UNSVEN"})
		nPLoteCtl := aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOTECTL"})
		nPNumLote := aScan(aHeader,{|x| AllTrim(x[2])=="C6_NUMLOTE"})
		nPDtValid := aScan(aHeader,{|x| AllTrim(x[2])=="C6_DTVALID"})
		nPPotenc  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_POTENCI"})
		nPValor   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"})
		nPValDesc := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALDESC"})
		nPIdentB6 := aScan(aHeader,{|x| AllTrim(x[2])=="C6_IDENTB6"})
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona registros                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SD1->(MsGoto((cAliasTRB)->SD1RECNO))
		SF4->(dbSetOrder(1))
		SF4->(MsSeek(xFilial("SF4")+aCols[n][nPTES]))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Preenche acols                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nPIdentB6 <> 0
			aCols[N][nPIdentB6] := (cAliasTRB)->B6_IDENT
		EndIf
		If nPNfOri <> 0
			aCols[N][nPNfOri] := SD1->D1_DOC
		EndIf
		If nPSerOri <> 0
			aCols[N][nPSerOri] := SD1->D1_SERIE
		EndIf
		If nPItemOri <> 0
			aCols[N][nPItemOri] := SD1->D1_ITEM
		EndIf
		If nPPrUnit <> 0
			If (cAliasTRB)->B6_PRUNIT == (cAliasTRB)->B6_PRCVEN .And. Abs((cAliasTRB)->B6_PRCVEN-SD1->D1_VUNIT)<=.01
				aCols[N][nPPrUnit] := 0
			Else
				aCols[N][nPPrUnit] := A410Arred((cAliasTRB)->B6_PRUNIT,"C6_PRUNIT")
			EndIf
		EndIf
		If nPPrcVen <> 0
			If (cAliasTRB)->B6_PRUNIT == (cAliasTRB)->B6_PRCVEN .And. Abs((cAliasTRB)->B6_PRCVEN-SD1->D1_VUNIT)<=.01
				aCols[N][nPPrcVen] := A410Arred(SD1->D1_VUNIT,"C6_PRCVEN")
			Else
				aCols[N][nPPrcVen] := A410Arred((cAliasTRB)->B6_PRCVEN,"C6_PRCVEN")
			EndIf
		EndIf
		If nPQuant <> 0 .And. (aCols[N][nPQuant] > (cAliasTRB)->B6_SALDO .Or. aCols[N][nPQuant] == 0 )
			aCols[N][nPQuant] := Min((cAliasTRB)->B6_SALDO,A410SNfOri(cCliFor,cLoja,SD1->D1_DOC,SD1->D1_SERIE,"",SD1->D1_COD,(cAliasTRB)->B6_IDENT,aCols[n][nPosLocal])[1])
			If nPQuant2UM <> 0
				aCols[N][nPQuant2UM] := ConvUm(cProduto,aCols[N][nPQuant],0,2)
			EndIf
		EndIf
		If Rastro(cProduto) .And. SF4->F4_ESTOQUE=="S"
			If nPLoteCtl <> 0
				aCols[N][nPLoteCtl] := SD1->D1_LOTECTL
			EndIf
			If nPNumLote <> 0
				aCols[N][nPNumLote] := SD1->D1_NUMLOTE
			EndIf
			If nPDtValid <> 0 .Or. nPPotenc <> 0
				dbSelectArea("SB8")
				dbSetOrder(3)
				If MsSeek(xFilial("SB8")+cProduto+aCols[N][nPLocal]+aCols[n][nPLoteCtl]+IIf(Rastro(cProduto,"S"),aCols[N][nPNumLote],""))
					If nPDtValid <> 0
						aCols[n][nPDtValid] := SB8->B8_DTVALID
					EndIf
					If nPPotenc <> 0
						aCols[n][nPPotenc] := SB8->B8_POTENCI
					EndIf
				EndIf
			EndIf
		EndIf
		A410MultT("C6_QTDVEN",aCols[N,nPQuant])
		A410MultT("C6_PRCVEN",aCols[N,nPPrcVen])
		If nPValDesc <> 0 .AND. nPPrUnit > 0 .AND. aCols[n][nPPrUnit] <> 0
			aCols[n][nPValDesc] := a410Arred((aCols[n][nPPrUnit]-aCols[n][nPPrcVen])*IIf(aCols[n][nPQuant]==0,1,aCols[n][nPQuant]),"C6_VALDESC")
			A410MultT("C6_VALDESC",aCols[n][nPValDesc])
		EndIf
		If nPLocal <> 0
			aCols[N][nPLocal] := SD1->D1_LOCAL
			// Pesquisa os armazens dos movimentos do controle de qualidade
			If SD1->D1_LOCAL == cLocalCQ
				// Monta array com os armazens tratados na movimentacao do CQ
				cSeekSD7   := xFilial('SD7')+SD1->D1_NUMCQ+SD1->D1_COD+SD1->D1_LOCAL
				SD7->(dbSetOrder(1))
				SD7->(dbSeek(cSeekSD7))
				Do While !SD7->(Eof()) .And. cSeekSD7 == SD7->D7_FILIAL+SD7->D7_NUMERO+SD7->D7_PRODUTO+SD7->D7_LOCAL
					If SD7->D7_TIPO >= 1     .AND.;
					   SD7->D7_TIPO <= 2     .AND.;
					   SD7->D7_ESTORNO # 'S' .AND.;
					   aScan(aArmazensCQ,SD7->D7_LOCDEST) == 0
						aAdd(aArmazensCQ,SD7->D7_LOCDEST)
					EndIf
					SD7->(dbSkip())
				EndDo
				// Monta texto para apresentacao no combobox
				If Len(aArmazensCQ) > 1
					nOpca:=0
					For nx:=1 to Len(aArmazensCQ)
						aAdd(aTextoCQ,OemToAnsi(STR0046)+" "+aArmazensCQ[nx])
					Next nx
					DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0084) From 130,70 To 270,360 OF oMainWnd PIXEL
					@ 05,13 SAY OemToAnsi(STR0085) OF oDlg PIXEL SIZE 110,9
					@ 17,13 TO 42,122 LABEL "" OF oDlg  PIXEL
					@ 23,17 MSCOMBOBOX oCombo VAR cCombo ITEMS aTextoCQ SIZE 100,044 OF oDlg PIXEL ON CHANGE (cLocalCQ:=aArmazensCQ[oCombo:nAt])
					DEFINE SBUTTON FROM 50,072 TYPE 1 Action (nOpca:=1,oDlg:End()) ENABLE OF oDlg PIXEL
					DEFINE SBUTTON FROM 50,099 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg PIXEL
					ACTIVATE MSDIALOG oDlg
					// Utiliza armazem relacionado ao movimento do CQ
					If nOpca == 1
						aCols[N][nPLocal] := cLocalCQ
					EndIf
				ElseIf Len(aArmazensCQ) > 0
					aCols[N][nPLocal] := aArmazensCQ[1]
				EndIf
			EndIf
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica os campos a serem atualizados                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPNfOri   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_NFORI"})
		nPSerOri  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_SERIORI"})
		nPItemOri := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEMORI"})
		nPLocal   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_LOCAL"})
		nPPrcVen  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_VUNIT"})
		nPQuant   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_QUANT"})
		nPQuant2UM:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_QTSEGUM"})
		nPLoteCtl := aScan(aHeader,{|x| AllTrim(x[2])=="D1_LOTECTL"})
		nPNumLote := aScan(aHeader,{|x| AllTrim(x[2])=="D1_NUMLOTE"})
		nPDtValid := aScan(aHeader,{|x| AllTrim(x[2])=="D1_DTVALID"})
		nPPotenc  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_POTENCI"})
		nPValor   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TOTAL"})
		nPValDesc := aScan(aHeader,{|x| AllTrim(x[2])=="D1_VALDESC"})
		nPDesc    := aScan(aHeader,{|x| AllTrim(x[2])=="D1_DESC"})
		nPIdentB6 := aScan(aHeader,{|x| AllTrim(x[2])=="D1_IDENTB6"})
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona registros                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SD2->(MsGoto((cAliasTRB)->SD2RECNO))
		SF4->(dbSetOrder(1))
		SF4->(MsSeek(xFilial("SF4")+aCols[n][nPTES]))
		nRegistro := (cAliasTRB)->SD2RECNO
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Preenche acols                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nPIdentB6 <> 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Libera a trava obtida                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If FindFunction( "LEAVE1CODE" )
				cAntB6Ident := aCols[ n, nPIdentB6 ]
				If !Empty( cAntB6Ident ) .And. cAntB6Ident <> (cAliasTRB)->B6_IDENT
					Leave1Code( "SD1_D1_IDENTB6" + cAntB6Ident )
				EndIf
			EndIf

			aCols[N][nPIdentB6] := (cAliasTRB)->B6_IDENT
		EndIf
		If nPNfOri <> 0
			aCols[N][nPNfOri] := SD2->D2_DOC
		EndIf
		If nPSerOri <> 0
			aCols[N][nPSerOri] := SD2->D2_SERIE
		EndIf
		If nPItemOri <> 0
			aCols[N][nPItemOri] := SD2->D2_ITEM
		EndIf
		If nPLocal <> 0
			aCols[N][nPLocal] := SD2->D2_LOCAL
		EndIf
		If nPPrcVen <> 0
			If (cAliasTRB)->B6_PRUNIT == (cAliasTRB)->B6_PRCVEN .And. Abs((cAliasTRB)->B6_PRCVEN-SD2->D2_PRCVEN)<=.01
				aCols[N][nPPrcVen] := A410Arred(SD2->D2_PRCVEN,"D1_VUNIT")
			Else
				aCols[N][nPPrcVen] := A410Arred((cAliasTRB)->B6_PRUNIT,"D1_VUNIT")
			EndIf
		EndIf
		If nPQuant <> 0 .And. ( aCols[N][nPQuant] > (cAliasTRB)->B6_SALDO .Or. aCols[N][nPQuant]==0 )
			aCols[N][nPQuant] := (cAliasTRB)->B6_SALDO
			If nPQuant2UM <> 0
				aCols[N][nPQuant2UM] := ConvUm(cProduto,aCols[N][nPQuant],0,2)
			EndIf
		EndIf
		If Rastro(cProduto) .And. SF4->F4_ESTOQUE=="S"
			If nPLoteCtl <> 0
				aCols[N][nPLoteCtl] := SD2->D2_LOTECTL
			EndIf
			If nPNumLote <> 0
				aCols[N][nPNumLote] := SD2->D2_NUMLOTE
			EndIf
			If nPDtValid <> 0 .Or. nPPotenc <> 0
				dbSelectArea("SB8")
				dbSetOrder(3)
				If MsSeek(xFilial("SB8")+cProduto+aCols[N][nPLocal]+aCols[n][nPLoteCtl]+IIf(Rastro(cProduto,"S"),aCols[N][nPNumLote],""))
					If nPDtValid <> 0
						aCols[n][nPDtValid] := SB8->B8_DTVALID
					EndIf
					If nPPotenc <> 0
						aCols[n][nPPotenc] := SB8->B8_POTENCI
					EndIf
				EndIf
			EndIf
		EndIf
		If nPValDesc <> 0 .And. nPQuant <> 0 .And. nPDesc <> 0
			aCols[n][nPValDesc] := a410Arred(((cAliasTRB)->B6_PRUNIT-(cAliasTRB)->B6_PRCVEN)*IIf(aCols[n][nPQuant]==0,1,aCols[n][nPQuant]),"D1_VALDESC")
		EndIf
		aCols[n][nPValor] := a410Arred(IIf(aCols[n][nPQuant]==0,1,aCols[n][nPQuant])*aCols[n][nPPrcVen],"D1_TOTAL")
	EndIf
	If !Empty(cReadVar)
		Do Case
			Case cReadVar $ "M->C6_QTDVEN"
				&(cReadVar) := aCols[n][nPQuant]
			Case cReadVar $ "M->C6_UNSVEN"
				&(cReadVar) := aCols[n][nPQuant2UM]
			OtherWise
				&(cReadVar) := aCols[n][nPQuant]
		EndCase
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a integridade da rotina                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAliasTRB)
dbCloseArea()
RestArea(aArea)
SetFocus(nHandle)
Return(lRetorno) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ A410Line  ³ Autor ³ Patricia A. Salomao  ³ Data ³ 26/07/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Atualizacao da bLine do documento.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A410Line(ExpN1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Posicao da linha no listbox                        ³±±
±±³          ³ ExpA1 - Array com as notas de entrada                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA410                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A410Line(nAT,aSF1)

Local abLine     := {}
Local nCnt       := 0

For nCnt := 1 To Len(aSF1[nAT])
	If nCnt == 1
		aAdd( abLine, Iif(aSF1[ nAT, nCnt ] , oMarked, oNoMarked ) )
	Else
		aAdd( abLine, aSF1[ nAT, nCnt ] )
	EndIf
Next nCnt
Return abLine

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ A410RetNF ³ Autor ³ Patricia A. Salomao  ³ Data ³ 26/07/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Retorna as notas                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A410RetNF(ExpA1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Nome da Tabela temporaria        				  ³±±
±±³          ³ ExpA1 - Campos que deverao ser apresentados				  ³±±
±±³          ³ ExpC2 - Alias da Tabela temporaria                         ³±±
±±³          ³ ExpC2 - Alias do Browse			                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA410                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A410RetNF(cAliasTmp , aStructSF1, cAliasT , cAlias)

	Local aStructTmp    := ( cAliasT )->( DBStruct() )
    Local aStructIns    := {}
	Local cSQLInsert    := ""
	Local nPos          := 0
    Local nX            := 0

    For nX := 1 To Len( aStructSF1 )
        If aStructSF1[nX][2] $ "D#L#N"
            TCSetField( cAliasT, aStructSF1[ nX, 1 ], aStructSF1[ nX, 2 ], aStructSF1[ nX, 3 ], aStructSF1[ nX, 4 ] )
        EndIf
    Next nX

	If (cAliasT)->( !Eof() )

		If TCGetDB() == "MSSQL"

			cSQLInsert += " INSERT INTO " + cAliasTmp + " ( "

			For nX := 1 To Len( aStructTmp )
				nPos := aScan( aStructSF1, { |x| AllTrim( x[1] ) == AllTrim( aStructTmp[ nX,1 ] )})
				If nPos > 0
					cSQLInsert += aStructTmp[ nX,1 ] + ", "
					aAdd(aStructIns, aStructTmp[nX])
				EndIf
			Next nX

			If !Empty( cSQLInsert )
				cSQLInsert := Substring(cSQLInsert,1,Len(cSQLInsert)-2)
			Endif

			cSQLInsert += " ) VALUES "

			While (cAliasT)->( !Eof() )

				cSQLInsert += "( "
				For nX := 1 To Len(aStructIns)
					nPos := ( cAliasT )->(FieldPos(aStructIns[nX, 1]))
					If nPos > 0
						If ValType(( cAliasT )->( FieldGet( nPos ) )) == "N"
							cSQLInsert +=  "'"   + CValToChar( ( cAliasT )->( FieldGet( nPos ) ) ) + "',"
						ElseIf ValType(( cAliasT )->( FieldGet( nPos ) )) == "D"
							cSQLInsert +=  "'"   + DtoS( ( cAliasT )->( FieldGet( nPos ) ) ) + "',"
						Else
							cSQLInsert +=  "'"   + ( cAliasT )->( FieldGet( nPos ) ) + "',"
						Endif
					Endif
				Next nX
				
				cSQLInsert := Substring(cSQLInsert,1,Len(cSQLInsert)-1) + " ), "
				( cAliasT )->( DbSkip() )

			Enddo
			
			cSQLInsert := Substring(cSQLInsert,1,Len(cSQLInsert)-2)
			
			nRet := TCSQLExec( cSQLInsert )
								
			If nRet < 0
				MsgStop( TCSqlError() ) 
			EndIf

		Else
		
			While (cAliasT)->( !Eof() )

				RecLock( cAlias, .T.)
				nLen := Len( aStructSF1 )
					For nX := 1 To nLen
						nPos := aScan(aStructTmp,{|x| AllTrim( x[1] ) == AllTrim(aStructSF1[nX][1])})
						If nPos > 0 
							(cAlias)->( FieldPut( nX, (cAliasT)->( FieldGet(nPos) ) ) )
						EndIf
					Next nX
				( cAlias )->( MsUnlock() )
		
				(cAliasT)->( DBSkip() ) 
			Enddo
		
		Endif

	Endif

    FreeObj(aStructTmp)
	FreeObj(aStructIns)

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ A410FRet ³ Autor ³ Patricia A. Salomao   ³ Data ³ 26/07/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Filtro para retornar de doctos fiscais.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A410FRet()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpL1 - Fornecedor ?                                       ³±±
±±³          ³ ExpD1 - Data Inicio                                        ³±±
±±³          ³ ExpD2 - Data Fim                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA410                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A410FRet(lFornece,dDataDe,dDataAte,lForn)

Local cTDataDe  := OemToAnsi(STR0096) //-- Dt. Entrada De
Local cTDataAte := OemToAnsi(STR0097) //-- Dt. Entrada Ate
Local cTFornece := RetTitle("F1_FORNECE")
Local cTLoja    := RetTitle("F1_LOJA")
Local nOpcao    := 0
Local lCliente  := .F.
Local lDocto    := .F.
Local oDlgEsp
Local oCliente
Local oForn
Local oDocto 
Local oFornece
Local oPanelCli
Local oPanelFor

If ( Type("l410Auto") == "U" .OR. !l410Auto )
	DEFINE MSDIALOG oDlgEsp FROM 00,00 TO 190,490 PIXEL TITLE OemToAnsi(STR0098) //-- Retorno de Doctos. de Entrada

		//-- Fornecedor'
		@ 02,10 CHECKBOX oForn VAR lForn PROMPT OemToAnsi(STR0099) SIZE 50,010 ;
			ON CLICK( lCliente := .F., oCliente:Refresh(), A410CliFor(lForn,@lFornece,@lDocto,oDocto,oFornece,oDlgEsp,oPanelCli,oPanelFor)) OF oDlgEsp PIXEL  //-- Fornecedor

		//-- 'Cliente'
		@ 02,120 CHECKBOX oCliente VAR lCliente PROMPT OemToAnsi(STR0105) SIZE 50,010 ;
			ON CLICK( lForn := .F., oForn:Refresh(), A410CliFor(lForn,@lFornece,@lDocto,oDocto,oFornece,oDlgEsp,oPanelCli,oPanelFor)) OF oDlgEsp PIXEL //-- Cliente

		@ 018,000 MSPANEL oPanelCli OF oDlgEsp SIZE 245,020               

		@ 018,000 MSPANEL oPanelFor OF oDlgEsp SIZE 245,020

		cTFornece := RetTitle("F1_FORNECE")
		cTLoja    := RetTitle("F2_LOJA")
		@ 001,05 SAY cTFornece PIXEL SIZE 47 ,9 OF oPanelFor
		@ 001,40 MSGET cFornece F3 'FOR' SIZE 65, 10 OF oPanelFor PIXEL

		@ 001,120 SAY cTLoja PIXEL OF oPanelFor
		@ 001,160 MSGET cLoja SIZE 20, 10 OF oPanelFor PIXEL ;
				VALID Vazio() .Or. ExistCpo('SA2',cFornece+cLoja,1)

		cTLoja    := RetTitle("F2_LOJA")
		@ 001,05 SAY RetTitle("F2_CLIENTE") PIXEL SIZE 50 ,10 OF oPanelCli
		@ 001,40 MSGET cFornece F3 'SA1' SIZE 65, 10 OF oPanelCli PIXEL

		@ 001,120 SAY cTLoja PIXEL OF oPanelCli
		@ 001,160 MSGET cLoja SIZE 20, 10 OF oPanelCli PIXEL ;
				VALID Vazio() .Or. ExistCpo('SA1',cFornece+cLoja,1)
		oPanelCli:Hide()

		@ 39,05 SAY cTDataDe PIXEL //-- Data De
		@ 38,40 MSGET dDataDe PICTURE "@D" SIZE 45, 10 OF oDlgEsp PIXEL

		@ 39,120 SAY cTDataAte PIXEL //-- Data Ate
		@ 38,160 MSGET dDataAte PICTURE "@D" SIZE 45, 10 OF oDlgEsp PIXEL

		@ 60,003 TO 085,195 LABEL OemToAnsi(STR0100) OF oDlgEsp PIXEL  //-- Tipo de Selecao

		//-- 'Fornecedor'
		@ 70,10 CHECKBOX oFornece VAR lFornece PROMPT PadR(IIf(lForn,OemToAnsi(STR0099),RetTitle("F2_CLIENTE")),20) SIZE 50,010 ;
			ON CLICK( lDocto := .F., oDocto:Refresh() ) OF oDlgEsp PIXEL  //-- Fornecedor

		//-- 'Documento'
		@ 70,120 CHECKBOX oDocto VAR lDocto PROMPT OemToAnsi(STR0102) SIZE 50,010 ;
			ON CLICK( lFornece := .F., oFornece:Refresh() ) OF oDlgEsp PIXEL //-- Documento

		DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlgEsp ENABLE ;
			ACTION If(!Empty(cFornece) .And. !Empty(cLoja) .And. ;
						!Empty(dDataDe) .And. !Empty(dDataAte) .And. ;
						(lFornece .Or. lDocto)  .And. IIF(lForn,ExistCpo('SA2',cFornece+cLoja,1),ExistCpo('SA1',cFornece+cLoja,1)),(nOpcao := 1,oDlgEsp:End()),.F.)

	DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlgEsp ENABLE ACTION (nOpcao := 0,oDlgEsp:End())

	ACTIVATE MSDIALOG oDlgEsp CENTERED
Else
	aREtauto	:= GetParAuto("MATA410TESTCASE")
	lFornece	:= aRetAuto[1]
	dDataDe		:= aRetAuto[2]
	dDataAte	:= aRetAuto[3]
	lForn		:= aRetAuto[4]
	cFornece	:= aRetAuto[5]
	cLoja		:= aRetAuto[6]
	nOpcao := 1
EndIf
Return ( nOpcao == 1 )   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³A410CliFor³ Autor ³ Patricia A. Salomao   ³ Data ³ 26/07/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Desenha Tela conforme selecao: Fornecedor ou Cliente        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A410CliFor()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpL1 - Fornecedor ? (1o.CheckBox)                         ³±±
±±³          ³ ExpL2 - Fornecedor ? (2o.CheckBox)                         ³±±
±±³          ³ ExpL3 - Documento  ? (2o.CheckBox)                         ³±±
±±³          ³ ExpO1 - Objeto Documento                                   ³±±
±±³          ³ ExpO2 - Objeto Fornecedor                                  ³±±
±±³          ³ ExpO3 - Objeto Dialog                                      ³±±
±±³          ³ ExpO4 - Objeto Panel Cliente                               ³±±
±±³          ³ ExpO5 - Objeto Panel Fornecedor                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA410                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A410CliFor(lForn,lFornece,lDocto,oDocto,oFornece,oDlgEsp,oPanelCli,oPanelFor)

//-- Se Clicou em Fornecedor
If lForn
	oPanelCli:Hide()
	oPanelFor:Show()
Else //-- Se Clicou em Cliente
	oPanelFor:Hide()
	oPanelCli:Show()
EndIf

oFornece:cCaption := IIf(lForn,OemToAnsi(STR0099),RetTitle("F2_CLIENTE"))
oFornece:cTitle   := IIf(lForn,OemToAnsi(STR0099),RetTitle("F2_CLIENTE"))
If lFornece
	lDocto := .F.
	oDocto:Refresh()
ElseIf lDocto
	 lFornece := .F.
	 oFornece:Refresh() 
EndIf

oDlgEsp:SetFocus()
oDlgEsp:Refresh()
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A410RemBenºAutor  ³Andre Anjos         º Data ³  04/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Exibe tela para marcacao do empenho relacionado a remessa  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA410                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A410RemBen()

Local aArea     := GetArea()
Local lContinua := .T.
Local lFirst    := .T.
Local cMarca    := ""
Local cFiltro   := ""
Local aListSD4  := {}
Local nOpc      := 0
Local nX        := 0
Local nPos      := 0
Local lMarca    := .F.
Local nQtde1Tot := 0
Local nQtde2Tot := 0
Local aTamX3    := TamSX3("D4_QUANT")
Local aCampos   := {"",AllTrim(RetTitle("D4_OP")),AllTrim(RetTitle("D4_QUANT")),AllTrim(RetTitle("D4_QTSEGUM"))}
Local oOk       := LoadBitMap(GetResources(), "LBOK")
Local oNo       := LoadBitMap(GetResources(), "LBNO")

Local nPosCod 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local nPosTes 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"})
Local nPosLoc 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOCAL"})
Local nPosItem  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM"})
Local nPosQuant := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
Local nPosQtSUM := aScan(aHeader,{|x| AllTrim(x[2])=="C6_UNSVEN"})
Local nPosLCtl  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOTECTL"})
Local nPosLote  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_NUMLOTE"})
Local nPosDtVal := aScan(aHeader,{|x| AllTrim(x[2])=="C6_DTVALID"})
Local nPosEnder := aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOCALIZ"})
Local nPosNumS  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_NUMSERI"})
Local nPosLib1  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDLIB"})
Local nPosLib2  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDLIB2"})
Local nPosPrc 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})
Local nPosTot 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"})
Local l410remb  := Existblock("M410REMB")
Local nTpCtlBN  := A410CtEmpBN()
Local aQtdEnv   := {}
Local nQtdDigit := 0
Local nY        := 0
Local nPosDig   := 0

//-- Verifica se o tipo de pedido e Beneficiamento, se produto e tipo BN e se a TES e de remessa e atualiza estoque
If  Empty(M->C5_TIPO) .Or. AllTrim(M->C5_TIPO) != "B" .Or.;
	Empty(aCols[n,nPosCod]) .Or. (SB1->(dbSeek(xFilial("SB1")+aCols[n,nPosCod])) .And. Iif(l410remb,ExecBlock("M410REMB",.F.,.F.,{SB1->B1_COD}),AllTrim(SB1->B1_TIPO) != "BN")) .Or.;
	Empty(aCols[n,nPosTes]) .Or. (SF4->(dbSeek(xFilial("SF4")+aCols[n,nPosTes])) .And. AllTrim(SF4->F4_PODER3) != "R" .Or.;
	AllTrim(SF4->F4_ESTOQUE) != "S")
	lContinua := .F.
Else
	lContinua := .T.
EndIf

If lContinua
	cFiltro := "D4_FILIAL = '" +xFilial("SD4") +"' .And. D4_COD == '" +aCols[n,nPosCod] +"' .And. "
	cFiltro += "QtdComp(D4_QUANT) > QtdComp(0) .And. Posicione('SC2',1,xFilial('SC2')+D4_OP,'C2_TPOP') == 'F' "

 	dbSelectArea("SD4")
	dbSetOrder(1)
	dbSetFilter({|| &cFiltro}, cFiltro)
	dbGoTop()
	cMarca := GetMark()
	If Bof() .and. Eof()
		Help(" ",1,"A410NOEMP")
	Else
		While !EOF()

			If nTpCtlBN == 2 // metodo novo - multiplos envios
				aQtdEnv   := A410QtEnBN(D4_OP, D4_COD, D4_LOCAL)
				nQtde1Tot := D4_QTDEORI - aQtdEnv[1]
				nQtde2Tot := ConvUM(D4_COD, nQtde1Tot, 0, 2)
				
				nQtdDigit := 0
				For nY := 1 to Len(aColsBn)
					nPosDig := aScan(aCols, {|x| x[1] == aColsBn[nY, 3]})
					If (nPosDig > 0 .and. n != nPosDig)              .AND.;
						!( aCols[nPosDig, Len(aCols[nPosDig])])      .And.;
						aCols[nPosDig, nPosCod] == aCols[n, nPosCod] .And.;
						SD4->(Recno())==aColsBn[nY,2]
						nQtdDigit += aCols[nPosDig, nPosQuant]
					EndIf
				Next nY

				If QtdComp(nQtdDigit) > 0
					If QtdComp(nQtdDigit) >= QtdComp(nQtde1Tot) // ja informou a qtde. total disponivel para envio
						dbSkip()
						Loop
					EndIf
					nQtde1Tot -= nQtdDigit
					nQtde2Tot := ConvUM(D4_COD, nQtde1Tot, 0, 2)
				EndIf
			EndIf
			
			If Localiza(D4_COD)
				dbSelectArea("SDC")
				dbSetOrder(2)
				dbSeek(xFilial("SDC")+SD4->(D4_COD+D4_LOCAL+D4_OP+D4_TRT+D4_LOTECTL+D4_NUMLOTE))
				While !EOF() .And. DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_OP+DC_TRT+DC_LOTECTL+DC_NUMLOTE == xFilial("SDC")+SD4->(D4_COD+D4_LOCAL+D4_OP+D4_TRT+D4_LOTECTL+D4_NUMLOTE)
					If aScan(aColsBn,{|x| x[2] == Recno() }) > 0
						nQtde1Tot -= DC_QUANT
						nQtde2Tot -= DC_QTSEGUM
					EndIf
					dbSkip()
				End
				dbSelectArea("SD4")
			EndIf
			If nQtde1Tot > 0
				nPos := aScan(aListSD4,{|x| x[2] == SD4->D4_OP})
				If nPos > 0 
					aListSD4[nPos,3] += nQtde1Tot
					aListSD4[nPos,4] += nQtde2Tot
				Else
					aAdd(aListSD4,{lMarca,SD4->D4_OP, nQtde1Tot, nQtde2Tot})
				EndIf
			EndIf
			SD4->(dbSkip())
		End
		If !Empty(aListSD4) 
			aSort(aListSD4,,,{|x,y| x[2] < y[2]})
			DEFINE MSDIALOG oDlg FROM 50,40 TO 285,750 TITLE STR0119+AllTrim(aCols[n,nPosItem]) Of oMainWnd PIXEL //"Selecione o empenho - Item"
			oListBox := TWBrowse():New(05,4,243,86,,aCampos,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
			oListBox:SetArray(aListSD4)
			oListBox:bLDblClick := {|| aListSD4[oListBox:nAt,1] := !aListSD4[oListBox:nAt,1]}
			oListBox:bLine := {|| {If(aListSD4[oListBox:nAt,1],oOk,oNo),aListSD4[oListBox:nAT,2],;
											Str(aListSD4[oListBox:nAT,3],aTamX3[1],aTamX3[2]),;
											Str(aListSD4[oListBox:nAT,4],aTamX3[1],aTamX3[2]) }}
	
			oListBox:Align := CONTROL_ALIGN_ALLCLIENT
			ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||(nOpc := 1,oDlg:End())},{||(nOpc := 0,oDlg:End())})
		Else
			Help(" ",1,"A410NOEMP")
		EndIf
	EndIf
Else
	Help(" ",1,"A410NOBN")
EndIf

SD4->(dbClearFilter())
If nOpc == 1
	nPos := n
	For nX := 1 To Len(aListSD4) 
		If aListSD4[nX,1] == .F.	
			Loop
		EndIf
		dbSelectArea("SD4")
		dbSetOrder(2)
		dbSeek(xFilial("SD4")+aListSD4[nX,2]+aCols[n,nPosCod])  
		While !EOF() .And. D4_FILIAL+D4_OP+D4_COD == xFilial("SD4")+aListSD4[nX,2]+aCols[n,nPosCod]

			If nTpCtlBN == 2 // metodo novo - multiplos envios
				aQtdEnv   := A410QtEnBN(D4_OP, D4_COD, D4_LOCAL)
				nQtde1Tot := D4_QTDEORI - aQtdEnv[1]
				nQtde2Tot := ConvUM(D4_COD, nQtde1Tot, 0, 2)
				
				nQtdDigit := 0
				For nY := 1 to Len(aColsBn)
					nPosDig := aScan(aCols, {|x| x[1] == aColsBn[nY, 3]})
					If (nPosDig > 0  .and. n != nPosDig)            .AND.;
					   !(aCols[nPosDig, Len(aCols[nPosDig])])       .AND.;
					   aCols[nPosDig, nPosCod] == aCols[n, nPosCod] .AND.;
					   SD4->(Recno())==aColsBn[nY,2]

						nQtdDigit += aCols[nPosDig, nPosQuant]

					EndIf
				Next nY

				If QtdComp(nQtdDigit) > 0
					If QtdComp(nQtdDigit) >= QtdComp(nQtde1Tot) // ja informou a qtde. total disponivel para envio
						dbSkip()
						Loop
					EndIf
					nQtde1Tot -= nQtdDigit
					nQtde2Tot := ConvUM(D4_COD, nQtde1Tot, 0, 2)
				EndIf
			EndIf

			If Localiza(aCols[n,nPosCod])
				dbSelectArea("SDC")
				dbSetOrder(2)
				dbSeek(xFilial("SDC")+SD4->(D4_COD+D4_LOCAL+D4_OP+D4_TRT+D4_LOTECTL+D4_NUMLOTE))
				While !EOF() .And. DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_OP+DC_TRT+DC_LOTECTL+DC_NUMLOTE == xFilial("SDC")+SD4->(D4_COD+D4_LOCAL+D4_OP+D4_TRT+D4_LOTECTL+D4_NUMLOTE)
					If !lFirst
						aAdd(aCols,aClone(aCols[n]))
						nPos := Len(aCols)
						aCols[nPos,nPosItem] := Soma1(aCols[Len(aCols)-1,nPosItem])
						aCols[nPos,nPosTes] := aCols[n,nPosTes]
						aCols[nPos,nPosPrc] := aCols[n,nPosPrc]
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Monta o AcolsGrade e o AheadGrade para este item - apenas compatibilizacao  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
						If MaGrade()
							oGrade:MontaGrade(nPos,aCols[nPos,nPosCod],.T.,,.F.) 
						EndIf
					EndIf
					aCols[nPos,nPosLoc]   := DC_LOCAL
					aCols[nPos,nPosQuant] := DC_QUANT
					aCols[nPos,nPosQtSUM] := DC_QTSEGUM
					aCols[nPos,nPosLCtl]  := DC_LOTECTL
					aCols[nPos,nPosLote]  := DC_NUMLOTE
					aCols[nPos,nPosEnder] := DC_LOCALIZ
					aCols[nPos,nPosNumS]  := DC_NUMSERI
					aCols[nPos,nPosTot]   := A410Arred(aCols[nPos,nPosQuant] * aCols[nPos,nPosPrc],"C6_VALOR") 
					
					If mv_par01 == 1
						aCols[nPos,nPosLib1] := aCols[nPos,nPosQuant]
						aCols[nPos,nPosLib2] := aCols[nPos,nPosQtSUM]
					EndIf
					
					If nTpCtlBN == 2 // metodo novo - multiplos envios
						If aScan(aColsBn,{|x| x[1] == "SDC" .And. x[2] == Recno() .And. x[3] == aCols[n, nPosItem] }) == 0 // nao eh o mesmo item
							aAdd(aColsBn,{"SDC",Recno(),aCols[nPos,nPosItem]})
						EndIf
						If aScan(aColsBn,{|x| x[1] == "SD4" .And. x[2] == SD4->(Recno()) .And. x[3] == aCols[n, nPosItem] }) == 0 // nao eh o mesmo item
							aAdd(aColsBn,{"SD4",SD4->(Recno()),aCols[nPos,nPosItem]}) // para garantir a gravacao na SGO
						EndIf
					EndIf
					
					If lFirst
						lFirst := .F.
					EndIf

					nQtde1Tot -= DC_QUANT
					nQtde2Tot -= DC_QTSEGUM
					dbSkip()
				End
				dbSelectArea("SD4")
			EndIf
			
			If nQtde1Tot > 0
				If !lFirst
					aAdd(aCols,aClone(aCols[n]))
					nPos := Len(aCols)
					aCols[nPos,nPosItem] := Soma1(aCols[Len(aCols)-1,nPosItem])
					aCols[nPos,nPosTes]  := aCols[n,nPosTes]
					aCols[nPos,nPosPrc]  := aCols[n,nPosPrc]
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Monta o AcolsGrade e o AheadGrade para este item - apenas compatibilizacao  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
					If MaGrade()
						oGrade:MontaGrade(nPos,aCols[nPos,nPosCod],.T.,,.F.) 
					EndIf
				EndIf
				aCols[nPos,nPosLoc]   := D4_LOCAL
				aCols[nPos,nPosQuant] := nQtde1Tot
				aCols[nPos,nPosQtSUM] := nQtde2Tot
				aCols[nPos,nPosLCtl]  := D4_LOTECTL
				aCols[nPos,nPosLote]  := D4_NUMLOTE
				aCols[nPos,nPosDtVal] := D4_DTVALID
				aCols[nPos,nPosEnder] := CriaVar("C6_LOCALIZ",.F.)
				aCols[nPos,nPosNumS]  := CriaVar("C6_NUMSERI",.F.)
				aCols[nPos,nPosTot]   := A410Arred(aCols[nPos,nPosQuant] * aCols[nPos,nPosPrc],"C6_VALOR") 

				If mv_par01 == 1
					aCols[nPos,nPosLib1] := aCols[nPos,nPosQuant]
					aCols[nPos,nPosLib2] := aCols[nPos,nPosQtSUM]
				EndIf

				If nTpCtlBN == 2
					If aScan(aColsBn,{|x| x[1] == "SD4" .And. x[2] == Recno() .And. x[3] == aCols[n, nPosItem] }) == 0 // nao eh o mesmo item
						aAdd(aColsBn,{"SD4",Recno(),aCols[nPos,nPosItem]})
					EndIf
				EndIf
				
				If lFirst
					lFirst := .F.
				EndIf				
			EndIf
			SD4->(dbSkip())
		End
	Next nX
	Ma410Rodap()
EndIf

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A410CarBenºAutor  ³Andre Anjos		 º Data ³  07/04/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Carrega relacionamentos entre SC6 e SD4,SDC para produtos  º±±
±±º          ³ tipo BN.													  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA410, FATXFUN                                       	  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A410CarBen(cNumPV,cItemPV)

Local aArea    := GetArea()
Local aRet		:= {}
Local cFiltro	:= ""
Local nTpCtlBN	:= A410CtEmpBN()
Local cFilSGO	:= xFilial("SGO")

Default cNumPv := ""

cFiltro := "DC_FILIAL == '" +xFilial("SDC") +"' .And. DC_ORIGEM == 'SC2' .And. DC_PEDIDO == '" +cNumPv +"'"
If !Empty(cItemPv)
	cFiltro += " .And. DC_ITEM == '" +cItemPV +"'"
EndIf

If nTpCtlBN == 2 // metodo novo - multiplos envios
    SGO->(dbSetOrder(2))
    SGO->(dbSeek(cFilSGO+cNumPV+If(!Empty(cItemPv),cItemPv,"")))
    While SGO->(! Eof())            .AND.;
	      SGO->GO_FILIAL == cFilSGO .AND.;
		  SGO->GO_NUMPV  == cNumPV  .AND.;
		  If(!Empty(cItemPv),SGO->GO_ITEMPV,"") == If(!Empty(cItemPv),cItemPv,"")
		aAdd(aRet, {"SD4", SGO->GO_RECNOD4, SGO->GO_ITEMPV})
		SGO->(dbSkip())
	EndDo
EndIf

SDC->(dbSetFilter({|| &cFiltro}, cFiltro))
SDC->(dbGoTop())
While SDC->(! EOF())
	aAdd(aRet, {"SDC", SDC->(Recno()), SDC->DC_ITEM})
	SDC->(dbSkip())
EndDo
SDC->(dbClearFilter())

RestArea(aArea)
Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A410GrvMedºAutor  ³Andre Anjos 		 º Data ³  25/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao que executa a rotina automatica da medicao (CNTA120)º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA410			                                       	  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/   
Function A410GrvMed(aCab,aItens)
Local aArea := GetArea()

If Type("lMsErroAuto") # "L"
	PRIVATE lMsErroAuto := .F.
Else
	lMsErroAuto := .F.
EndIf

//-- Gera a medicao
MsExecAuto({|a,b,c|,CNTA120(a,b,c)},aCab,aItens,3)		

//-- Encerra a medicao
If !lMsErroAuto
	MsExecAuto({|a,b,c|,CNTA120(a,b,c)},aCab,aItens,6)
EndIf

If lMsErroAuto
	MostraErro()
	RecLock("SC5",.F.)
	Replace SC5->C5_MDNUMED With CriaVar("C5_MDNUMED")
	Replace SC5->C5_MDCONTR With CriaVar("C5_MDNUMED")
	Replace SC5->C5_MDPLANI With CriaVar("C5_MDNUMED")
	MsUnLock()
	Aviso(STR0127,STR0133 +SC5->C5_NUM +STR0134,{"Ok"}) //SIGAGCT - O pedido de venda número ### não foi vinculado ao contrato selecionado.
EndIf

RestArea(aArea)
Return   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A410CCPed   ³ Autor ³ Vendas Clientes      ³ Data ³ 22/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se existe amarracao do Ped. de vendas com o Ped.    ³±±
±±³			 ³ de Compras Caso exista, e o Ped. de vendas seja alterado, a  ³±±
±±³          ³ mesma alteracao devera ser feita no Ped. de Compras.			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Param01 - aCols do Ped. de Vendas com as alteracoes para o   ³±±
±±³          ³ Ped.	de Compras							                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ MATA410		                							    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A410CCPed(aCols,aHeader,aMTA177PER,nOpcao)   

Local cFilPed  := SC6->C6_FILPED      // Filial do Ped. de compras
Local cNumDoc  := SC6->C6_PEDCOM      // Numero do Doc do Ped.  Compras
Local cItem    := SC6->C6_ITPC        // Numero do Item do Pedido
Local nProd    := aScan( aHeader,{|x| Trim(x[2]) == "C6_PRODUTO" } )  
Local nITem    := aScan( aHeader,{|x| Trim(x[2]) == "C6_ITEM"    } )  
Local nQuant   := aScan( aHeader,{|x| Trim(x[2]) == "C6_QTDVEN"  } )   
Local nI       := 0                    // variavel para controle do for
Local aCbPC    := {}                   // Array para Cabecalho do Ped. de Compras
Local aItPC    := {}                   // Array para Itens do Ped. de Compras
Local aArea    := GetArea() 
Local cTxtLog  := ""                   // variavel para controle de errro no MSExecAuto
Local aMsgErr  := {}                   // array para guardar as mensagens de erro  
Local cDefine  := If(nOpcao == 1 ,STR0139 ,STR0138)                       //"Exclui Pedido de Compra" / "Atualiza Pedido de Compra"
Local lPedCom  := If(!Empty(cNumDoc ),MsgYesNo(cDefine, STR0137), .F. )  //"Pedidos de Compra"
Local cFilBkp  := cFilAnt    
Local cFilCent := ""                   //Filial Centralizadora do SC7     
Local cTES     := ""                   // Tes para geracao do Pedido de compra  
Local cFilAIB  := ""                   // Filia da Dabela AIB.
Local nPrUnit  := 0                    // Preco unitario.       

DEFAULT aCols       := {}
DEFAULT aMTA177PER  := {}   
DEFAULT nOpcao      := 1   // Se for 1 Deleta o Doc de Compra se for 2 Exclui para a inclusao com a alteracao 

PRIVATE lMsErroAuto := .F.

DbSelectArea("SC7")
DbSetOrder(1)
DbSeek(cFilPed + cNumDoc + cItem ) 

cFilAnt := If (!Empty(SC7->C7_FILIAL), SC7->C7_FILIAL, cFilAnt )  
cFilCent:= SC7->C7_FILCEN
If !Empty(cNumDoc ) .AND. lPedCom  //CABECARIO DO PEDIDO DE COMPRAS 
    	aAdd(aCbPC, {'C7_NUM'		, SC7->C7_NUM		    , Nil})	//--Numero do Pedido
		aAdd(aCbPC, {'C7_EMISSAO'	, SC7->C7_EMISSAO		, Nil})	//--Data de Emissao
		aAdd(aCbPC, {'C7_FORNECE'	, SC7->C7_FORNECE	    , Nil})	//--Fornecedor
		aAdd(aCbPC, {'C7_LOJA'		, SC7->C7_LOJA			, Nil})	//--Loja do Fornecedor
		aAdd(aCbPC, {'C7_CONTATO'	, SC7->C7_CONTATO     	, Nil})	//--Contato
		aAdd(aCbPC, {'C7_COND'		, SC7->C7_COND			, Nil})	//--Condicao de Pagamento
		aAdd(aCbPC, {'C7_FILENT'	, SC7->C7_FILENT		, Nil})	//--Filial de Entrega			
		
	For nI := 1 to Len(aCols)  //ITENS DO PEDIDO DE COMPRAS
		cTES := RetFldProd(aCols[nI][nProd], 'B1_TE')  
		If aMTA177PER[1][1] == 1
			nPrUnit := RetFldProd(aCols[nI][nProd], 'B1_UPRC')
		ElseIf aMTA177PER[1][1] == 2
		//-- Obtem o preco unitario atraves da tabela informada e para o fornecedor do pedido de compra
			cFilAIB := If( FWModeAccess("AIB",3)=="C", xFilial('AIB'), cFilAnt ) 
			nPrUnit := GetAdvFval( 'AIB','AIB_PRCCOM', cFilAIB + aCbPC[3][2] + aCbPC[4][2] + aMTA177PER[1][2] + aCols[nI][nProd]	, 2 )
		Else
			nPrUnit := RetFldProd(aCols[nI][nProd], 'B1_CUSTD')
		EndIf	
		aAdd(aItPC, {{ 'C7_ITEM'	 , PaDL(Val(aCols[nI][nITEM]),4,"0") 	 , NIL },;
						  { 'C7_PRODUTO' , aCols[nI][nProd]					 , NIL },;
						  { 'C7_CODTAB'  , If(aMTA177PER[1][1] = 2, aMTA177PER[1][2], Criavar('C7_CODTAB',.F.))				     , NIL },;
						  { 'C7_QUANT'	 , aCols[nI][nQuant]				 , NIL },;
						  { 'C7_PRECO'	 , nPrUnit		 					 , NIL },;
						  { 'C7_TES'	 , cTES	        	    			 , NIL },;
						  { 'C7_FILCEN'	 , cFilCent							 , Nil },;
						  { 'C7_TPOP'	 , 'F'								 , NIL } } )						
	Next nI 
	If Len( aCbPC ) > 0 .And. Len( aItPC ) > 0   
   		Begin Transaction
			For nI := 1 to nOpcao
				lMsErroAuto := .F.
				MSExecAuto( {|v,x,y,z,w| MATA120(v,x,y,z,w)}, 1, aCbPC, aItPC,If (nI = 1 ,5 , 3), .F. )
				If lMsErroAuto 
					Exit
				EndIf 
			Next nI	
			If lMsErroAuto
				cTxtLog := NomeAutoLog()
				If ValType( cTxtLog ) == 'C'
					aAdd( aMsgErr, Memoread( cTxtLog ) )
				EndIf		
				Disarmtransaction()
			EndIf
		End Transaction	
	EndIf	
EndIf

If Len( aMsgErr ) > 0
	For nI := 1 To Len( aMsgErr )
		AutoGrLog( aMsgErr[nI] )
	Next  nI
	AutoGrLog('')
	MostraErro()
EndIf 

cFilAnt := cFilBkp
RestArea(aArea)
Return(NIL)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A410CtEmpBN ³ Autor ³ Emerson Rony Oliveira ³Data ³ 22/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica qual e o metodo utilizado para envio de materiais do³±±
±±³			 ³ tipo BN para beneficiamento.                                 ³±±
±±³          ³ Caso a entidade SGO exista no dicionario, sera adotado o novo³±±
±±³          ³ metodo para controle atraves de envios parciais.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³0 - Nenhuma forma de controle esta ativada.                   ³±±
±±³          ³1 - Esta sendo utilizado o metodo antigo de controle, ou seja,³±±
±±³          ³    apenas um envio por SD4.                                  ³±±
±±³          ³2 - Esta sendo utilizado o novo metodo de controle, ou seja,  ³±±
±±³          ³    sera possivel realizar envios parciais.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ MATA410, MATA103                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A410CtEmpBN()

Local lEmpBN := SuperGetMV("MV_EMPBN",.F.,.F.)
Local nRet   := If(lEmpBN, 2, 0)	// 2 = Múltiplos envios: Gravação na SGO
                                    // 0 = Não controla envios para Beneficiamento

Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A410QtEnBN  ³ Autor ³ Emerson Rony Oliveira ³Data ³ 22/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que retorna a quantidade ja enviada com base nos      ³±±
±±³			 ³ empenhos ja realizados na tabela SGO.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOP      - Numero da OP                                      ³±±
±±³          ³ cProduto - Codigo do produto                                 ³±±
±±³          ³ cLocal   - Codigo do armazem                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³nRet - Quantidade na 1a. e 2a. UM ja enviada.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ MATA410                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Static Function A410QtEnBN(cOP, cProduto, cLocal)

Local aRet     := {}
Local cSeek    := ""
Local nQtdEnv  := 0
Local nQtdEnv2 := 0

SGO->(dbSetOrder(1)) // GO_FILIAL+GO_OP+GO_COD+GO_LOCAL
SGO->(dbSeek(cSeek := xFilial('SD4')+cOP+cProduto+cLocal))
Do While SGO->(! Eof()) .And. cSeek == SGO->GO_FILIAL + SGO->GO_OP + SGO->GO_COD + SGO->GO_LOCAL
	nQtdEnv  += SGO->GO_QUANT
	nQtdEnv2 += SGO->GO_QTSEGUM
	SGO->(dbSkip())
EndDo
aAdd(aRet, nQtdEnv)
aAdd(aRet, nQtdEnv2)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A410InGrdMºAutor  ³Andre Anjos		 º Data ³  21/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para inicialiar a grade multicampo				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA410                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A410InGrdM(lEdit)

Local nPQTDVEN := 0
Local nPPRCVEN := 0
Local lGrdMult  := "MATA410" $ SuperGetMV("MV_GRDMULT",.F.,"")

Default lEdit := .F.

If lGrdMult
	aAdd(oGrade:aCposCtrlGrd,{"C6_PRCVEN",.F.,{},{},.T.})
	aAdd(oGrade:aCposCtrlGrd,{"C6_VALOR",.F.,{},{},.F.})
	aAdd(oGrade:aCposCtrlGrd,{"C6_VALDESC",.F.,{},{},.F.})
	aAdd(oGrade:aCposCtrlGrd,{"C6_DESCRI",.F.,{},{},.F.})
	aAdd(oGrade:aCposCtrlGrd,{"C6_PRUNIT",.F.,{},{},.F.})
	
	If lEdit
		nPQTDVEN := aScan(oGrade:aCposCtrlGrd, {|x| x[1] == "C6_QTDVEN"})
		nPPRCVEN := aScan(oGrade:aCposCtrlGrd, {|x| x[1] == "C6_PRCVEN"})
		
		If Len(oGrade:aCposCtrlGrd[nPQTDVEN]) == 3
			aAdd(oGrade:aCposCtrlGrd[nPQTDVEN],{ }) //Array de gatilhos
			aAdd(oGrade:aCposCtrlGrd[nPQTDVEN],.T.) //Flag de obrigatoriedade		
		EndIf
		
		//-- Campos a atualizar ao confirmar a tela da grade
		aAdd(oGrade:aCposCtrlGrd[nPQTDVEN,3],{"C6_DESCRI",{|| Posicione("SB1",1,xFilial("SB1")+oGrade:GetNameProd(,nLinha,nColuna),"B1_DESC")}})
		
		//-- Campos a atualizar na grade multicampo
		aAdd(oGrade:aCposCtrlGrd[nPQTDVEN,4],{"C6_PRCVEN",{|| A410GrInPr(nLinha,nColuna) }})
		aAdd(oGrade:aCposCtrlGrd[nPQTDVEN,4],{"C6_VALDESC",{|| A410GrInDs(nLinha,nColuna) }})
		aAdd(oGrade:aCposCtrlGrd[nPQTDVEN,4],{"C6_VALOR",{|| A410Arred(&(ReadVar()) * oGrade:GetFieldMC("C6_PRCVEN"),"C6_VALOR")}})
		aAdd(oGrade:aCposCtrlGrd[nPPRCVEN,4],{"C6_VALOR",{|| A410Arred(&(ReadVar()) * oGrade:GetFieldMC("C6_QTDVEN"),"C6_VALOR")}})
	EndIf
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A410GrInPrºAutor  ³Andre Anjos		 º Data ³  27/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para inicializacao do preco unitario na grade multi-º±±
±±º          ³ campo                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA410													  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A410GrInPr(nLin,nCol)

Local nRet      := 0
Local nPValDesc := aScan(oGrade:aHeadAux,{|x| AllTrim(x[2]) == "C6_VALDESC"})
Local nPPerDesc := aScan(oGrade:aHeadAux,{|x| AllTrim(x[2]) == "C6_DESCONT"})

If !Empty(&(ReadVar()))
	If Empty(oGrade:aColsAux[oGrade:nPosLinO,nPValDesc])//-- Se preencheu a quantidade e não tem desconto no item do PV
		If Empty(oGrade:aColsFieldByName("C6_PRCVEN",,nLin,nCol,.T.)) //-- Se nao foi digitado preco
			nRet := A410InPrcV(oGrade:GetNameProd(,nLin,nCol),oGrade:nPosLinO,oGrade:aColsFieldByName("C6_QTDVEN",,nLin,nCol))
		Else
			nRet := oGrade:aColsFieldByName("C6_PRCVEN",,nLin,nCol,.T.)
		EndIf
		nRet += A410Tabela(,,,,,,,,.T.,,,oGrade:aColsGrade[oGrade:nPosLinO,nLin,nCol,oGrade:GetFieldGrdPos("C6_OPC")]) //Chamada somente para somar preco dos opcionais
	Else
		If Empty(nRet := oGrade:aColsFieldByName("C6_PRCVEN",,nLin,nCol,.T.))
			nRet := oGrade:aColsFieldByName("C6_PRUNIT",,nLin,nCol,.T.) * (1 - (oGrade:aColsAux[oGrade:nPosLinO,nPPerDesc] / 100))
		EndIf
	EndIf
EndIf
Return nRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A410InPrcVºAutor  ³ Andre Anjos		 º Data ³  03/02/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao que inicializa o preco de venda quando digitada     º±±
±±º          ³ quantidade na grade multicampo.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA410                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A410InPrcV(cProduto,nLinGetD,nQtd)

Local nPreco   := 0
Local cCliente := M->C5_CLIENTE
Local cLojaCli := If(Empty(M->C5_LOJAENT),M->C5_LOJACLI,M->C5_LOJAENT)
Local nColuna  := aScan(oGrade:aHeadGrade[nLinGetD],{|x| ValType(x) # "C" .And. AllTrim(x[2]) == StrTran(ReadVar(),"M->","")})
Local nPDESCON := aScan(oGrade:aHeadAux,{|x| AllTrim(x[2]) == "C6_DESCONT"})
Local nPGRDVAL := oGrade:GetFieldGrdPos("C6_VALOR")
Local nPGRDVDE := oGrade:GetFieldGrdPos("C6_VALDESC")
Local nPGRDPRU := oGrade:GetFieldGrdPos("C6_PRUNIT")
Local lPrcDec  := SuperGetMV("MV_PRCDEC",,.F.)

If &(ReadVar()) > 0
	//-- Toma como base o preco de tabela
	nPreco := A410Tabela(cProduto,M->C5_TABELA,nLinGetD,nQtd,cCliente,cLojaCli,,,,,.T.)
	oGrade:aColsGrade[nLinGetD,n,nColuna,nPGRDPRU] := nPreco
	
	//-- Aplica descontos do cabecalho
	nPreco := FtDescCab(nPreco,{M->C5_DESC1,M->C5_DESC2,M->C5_DESC3,M->C5_DESC4},If(cPaisLoc $ "CHI|PAR".And.lPrcDec,M->C5_MOEDA,NIL))
	
	//Aplica desconto do item
	nPreco := FtDescItem(0,@nPreco,nQtd,@oGrade:aColsGrade[nLinGetD,n,nColuna,nPGRDVAL],@oGrade:aColsAux[nLinGetD,nPDESCON],@oGrade:aColsGrade[nLinGetD,n,nColuna,nPGRDVDE],0,1,nQtd,If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))	
Else
	oGrade:aColsGrade[nLinGetD,n,nColuna,nPGRDPRU] := 0
EndIf
Return nPreco  

//-------------------------------------------------------------------
/*{Protheus.doc} A410GrInDs()
Função que inicializa o valor de desonto na grade de produtos multicampo
@author Andre Anjos
@since 19/08/2013
@version 1.0
@return Valor do desconto aplicado ao item da grade*/
//-------------------------------------------------------------------
Static Function A410GrInDs(nLinha,nColuna)

Local nRet 	:= 0
Local nPrUnit := oGrade:aColsFieldByName("C6_PRUNIT",,nLinha,nColuna)
Local nPrcVen := oGrade:GetFieldMC("C6_PRCVEN")

If Empty(nPrUnit) 
	nRet := (((&(ReadVar()) * 100) / oGrade:aColsFieldByName("C6_QTDVEN",,nLinha,nColuna)) / 100) * oGrade:aColsFieldByName("C6_VALDESC",,nLinha,nColuna)
ElseIf !Empty(nPrcVen)
	nRet := (&(ReadVar()) * nPrUnit) - (&(ReadVar()) * nPrcVen)  
EndIf
Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A410KeyF9 ºAutor  ³Andre Anjos         º Data ³  27/07/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao da tecla F9 na inclusao de pedido de venda.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA410													  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A410KeyF9()

Local oDlg	      := NIL
Local oGet01      := NIL
Local aCampos     := {}
Local aTitle      := {}
Local aCpsComis   := {}
Local aVendors    := {}
Local aStruCNA    := CNA->(dbStruct())
Local cConsSxb    := "CN9003"
Local cLine       := ""
Local cQuery	  := ""
Local nOpca		  := 0
LOcal nX		  := 0
Local nY		  := 0
Local nPercCNF	  := 0
Local n
Local oOk  		  := LoadBitmap(GetResources(),"LBTIK")
Local oNo  		  := LoadBitmap(GetResources(),"LBNO")
Local lSugVal     := GetNewPar("MV_CNSUGME","1") == "1"
Local lRealMed    := GetNewPar( "MV_CNREALM", "S" ) == "S"
Local lReajMed    := GetNewPar( "MV_CNREAJM", "S" ) == "S"
Local lFisico     := .F.
Local lRet 		  := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para manipulacao do aCols. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nITEM    := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ITEM"})
Local nPRODUTO := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})
Local nUM      := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_UM"})
Local nQTDVEN  := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_QTDVEN"})
Local nPRCVEN  := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRCVEN"})
Local nVALOR   := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_VALOR"})
Local nSEGUM   := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_SEGUM"})
Local nTES     := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_TES"})
Local nUNSVEN  := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_UNSVEN"})
Local nLOCAL   := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_LOCAL"})
Local nCF      := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_CF"})
Local nENTREG  := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ENTREG"})
Local nDESCRI  := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_DESCRI"})
Local nPRUNIT  := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRUNIT"})
Local nSUGENTR := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_SUGENTR"})
Local nITEMED  := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ITEMED"})
Local nDESCONT := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_DESCONT"})
Local nVALDESC := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_VALDESC"})
Local nCodIss  := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_CODISS"})
Local oTempTable := Nil

Private aHeadDcs  	:= {}

For nX := 1 To 5
	aAdd(aCpsComis, aScan(aHeader,{|x| AllTrim(x[2]) == ("C6_COMIS"+Str(nX,1))}))
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se posicionado no cliente, tipo de pedido normal  ³
//³ e parametro MV_CNPEDVE ativo, abre janela para    ³
//³ selecao do contrato a vincular (SIGAGCT).         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SuperGetMV("MV_CNPEDVE",.F.,.F.) .And. ReadVar() == "M->C5_CLIENTE" .And. M->C5_TIPO == "N"
	If !Empty(CND->( ColumnPos( "CND_PARCEL" ) ))
		aTitle := { "",CNA->(RetTitle("CNA_NUMERO")),CNA->(RetTitle("CNF_PARCEL")),CNA->(RetTitle("CNA_DTINI")),CNA->(RetTitle("CNA_VLTOT")),CNA->(RetTitle("CNA_DTFIM")),CNA->(RetTitle("CNA_FORNEC")),CNA->(RetTitle("CNA_LJFORN")),CNA->(RetTitle("CNA_CRONOG")),CNA->(RetTitle("CNF_VLPREV"))}
	Else                                                                                                         
		aTitle := { "",CNA->(RetTitle("CNA_NUMERO")),CNA->(RetTitle("CNA_DTINI")),CNA->(RetTitle("CNA_VLTOT")),CNA->(RetTitle("CNA_DTFIM")),CNA->(RetTitle("CNA_FORNEC")),CNA->(RetTitle("CNA_LJFORN")),CNA->(RetTitle("CNA_CRONOG")),CNA->(RetTitle("CNF_VLPREV"))}
	EndIf
	
	//-- Variaveis private para manipulacao na CN120VlCon
	Private oBrowse := NIL
	Private oCbx	:= NIL
	Private lMedeve := .F.//medicao Eventual
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adiciona parcela e valor previsao a estrutura da planilha    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aStruCNA,{"CNF_PARCEL","C",TamSX3("CNF_PARCEL")[1],TamSX3("CNF_PARCEL")[2]})
	aAdd(aStruCNA,{"CNF_VLPREV","N",TamSX3("CNF_VLPREV")[1],TamSX3("CNF_VLPREV")[2]})
	
	//-------------------------------------------------------------------
	// Instancia tabela temporária.  
	//-------------------------------------------------------------------
	oTempTable	:= FWTemporaryTable():New( "TRBCNA" )
	
	//-------------------------------------------------------------------
	// Atribui o  os índices.  
	//-------------------------------------------------------------------
	oTempTable:SetFields( aStruCNA )
	oTempTable:AddIndex("1",{"CNA_FILIAL","CNA_CONTRA","CNA_REVISA","CNA_NUMERO"})
		
	//------------------
	//Criação da tabela
	//------------------
	oTempTable:Create()
			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Configura campos exibidos na inclusao de medicoes  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(CND->( ColumnPos( "CND_PARCEL" ) ))
		aCampos := {"",TRBCNA->CNA_NUMERO,TRBCNA->CNF_PARCEL,TRBCNA->CNA_DTINI,TRBCNA->CNA_VLTOT,TRBCNA->CNA_DTFIM,TRBCNA->CNA_FORNEC,TRBCNA->CNA_LJFORN,TRBCNA->CNA_CRONOG,TRBCNA->CNF_VLPREV}
	Else
		aCampos := {"",TRBCNA->CNA_NUMERO,TRBCNA->CNA_DTINI,TRBCNA->CNA_VLTOT,TRBCNA->CNA_DTFIM,TRBCNA->CNA_FORNEC,TRBCNA->CNA_LJFORN,TRBCNA->CNA_CRONOG,TRBCNA->CNF_VLPREV}
	EndIf
	
	If ExistBlock("CN120SXB")
		cConsSxb := If(Valtype(cConsSxb:=ExecBlock("CN120SXB",.F.,.F.))=="C",cConsSxb,"CN9003") 
	EndIf
	
	DEFINE MSDIALOG oDlg TITLE STR0135 From 74,7 TO 400,606 PIXEL //Vínculo a Contrato - SIGAGCT
	
	@ 10,04   SAY OemToansi(RetTitle("CN9_NUMERO")) SIZE 73, 8 OF oDlg PIXEL
	@ 09,37   MSGET oGet01 VAR cContra PICTURE PesqPict("CN9","CN9_NUMERO") F3 cConsSxb SIZE 60,9 VALID A410VldGCT() .And. CN120VlCon(1,,cFilCTR) OF oDlg PIXEL
	
	@ 10,104  SAY OemToansi(RetTitle("CNF_COMPET")) SIZE 73, 8 OF oDlg PIXEL
	@ 09,137 ComboBox oCbx Var cCompet ON CHANGE CN120Compet(,cFilCTR) SIZE 50,9 OF oDlg PIXEL
	
	If !Empty(CND->( ColumnPos( "CND_PARCEL" ) ))
		cLine := "{If((cPlan+cParcel==(TRBCNA->CNA_NUMERO+TRBCNA->CNF_PARCEL)),oOk,oNo),TRBCNA->CNA_NUMERO,TRBCNA->CNF_PARCEL,TRBCNA->CNA_DTINI,Transform(TRBCNA->CNA_VLTOT,PesqPict('CNA','CNA_VLTOT')),TRBCNA->CNA_DTFIM,TRBCNA->CNA_FORNEC,TRBCNA->CNA_LJFORN,TRBCNA->CNA_CRONOG,Transform(TRBCNA->CNF_VLPREV,PesqPict('CNF','CNF_VLPREV')),"
	Else
		cLine := "{If((cPlan==TRBCNA->CNA_NUMERO),oOk,oNo),TRBCNA->CNA_NUMERO,TRBCNA->CNA_DTINI,Transform(TRBCNA->CNA_VLTOT,PesqPict('CNA','CNA_VLTOT')),TRBCNA->CNA_DTFIM,TRBCNA->CNA_FORNEC,TRBCNA->CNA_LJFORN,TRBCNA->CNA_CRONOG,Transform(TRBCNA->CNF_VLPREV,PesqPict('CNF','CNF_VLPREV')),"
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Finaliza construcao do cLine ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cLine := substr(cLine,1,len(cLine)-1)+"}"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Configura browse    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBrowse := TWBrowse():New( 30, 4,__DlgWidth(oDlg)-8,__DlgHeight(oDlg)-58, {|| {aCampos} },aTitle,{030,090},oDlg,,,,,,,,,,,,,"TRBCNA", .T. )
	oBrowse:bLine := &( "{ || " + cLine + " }" )
	If !Empty(CND->( ColumnPos( "CND_PARCEL" ) ))
		oBrowse:bLDblClick := {|| If(!Empty(TRBCNA->CNA_NUMERO),((cPlan:= TRBCNA->CNA_NUMERO,cParcel:=TRBCNA->CNF_PARCEL), oBrowse:Refresh()),) }
	Else
		oBrowse:bLDblClick := {|| If(!Empty(TRBCNA->CNA_NUMERO),(cPlan := TRBCNA->CNA_NUMERO, oBrowse:Refresh()),) }
	EndIf
	
	DEFINE SBUTTON FROM 150, 240 When .T. TYPE 1 ACTION (If(Empty(cPlan),Help(" ",1,"CNTA120_01"),(oDlg:End(),nOpca:=1))) ENABLE OF oDlg//"Selecione uma planilha"
	DEFINE SBUTTON FROM 150, 270 When .T. TYPE 2 ACTION (oDlg:End(),nOpca:=2) ENABLE OF oDlg
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apaga arquivo temporario                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If( valtype(oTempTable) == "O")
		oTempTable:Delete()
		freeObj(oTempTable)
		oTempTable := nil
	EndIf
	
	If nOpca == 1
		
		cFilCTR := CN9->CN9_FILCTR
		lFisico := 	CN300RetSt('FISICO',0,cPlan,cContra,cFilCTR,.F.)

		If !lSugVal
			lSugVal := lFisico
		EndIf	
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza campos do cabecalho do pedido (SC5)       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		//Posiciona na planilha
		CNA->( dbSetOrder( 1 ) ) //CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_NUMERO
		If CNA->( dbSeek( FWxFilial("CNA",cFilCTR) + cContra + cRevisa + cPlan ) )				
			lRet := .T.
			M->C5_MDCONTR := cContra
			M->C5_MDPLANI := cPlan
			M->C5_CLIENTE := CNA->CNA_CLIENT
			M->C5_LOJACLI := CNA->CNA_LOJACL
			M->C5_CONDPAG := CN9->CN9_CONDPG
			M->C5_MOEDA	  := CN9->CN9_MOEDA
			M->C5_TIPOCLI := Posicione( "SA1", 1, FWxFilial("SA1") + CNA->CNA_CLIENT + CNA->CNA_LOJACL, "A1_TIPO" )
		EndIf
		
		aVendors := CtaVend(cContra)
		If !Empty(aVendors)
			For nX := 1 To Len(aVendors)
				&("M->C5_VEND"+Str(nX,1,0)) := aVendors[nX,1]
				&("M->C5_COMIS"+Str(nX,1,0)) := aVendors[nX,2]
			Next nX
		Else
			For nX := 1 To 5
				&("M->C5_VEND"+Str(nX,1,0)) := CriaVar("C5_VEND1",.F.)
				&("M->C5_COMIS"+Str(nX,1,0)) := CriaVar("C5_COMIS1",.F.)
			Next nX
		EndIf
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se for contrato fixo (com planilha), realiza |
		//| o preenchimento do aCols do PV com os itens  ³
		//| da planilha (CNB).							 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .And. lFixo
			//Limpa aCols, pois so aceita itens da planilha
			aCols := {}					
				
			dbSelectArea("CNB")
			dbSetOrder(1)
			dbSeek(xFilial("CNB",cFilCTR)+cContra+cRevisa+cPlan)
			While CNB->(CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO) == xFilial("CNB",cFilCTR)+cContra+cRevisa+cPlan
				If CNB->CNB_SLDMED > 0
					aAdd(aCols,Array(Len(aHeader)+1))
					aCols[Len(aCols),Len(aHeader)+1] := .F.
			
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿              
					//³ Inicializa campos da getdados                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nX :=1 to Len(aHeader)
						If !(IsHeadRec(aHeader[nX,2]) .OR. IsHeadAlias(aHeader[nX,2]))
							aCols[Len(aCols),nX] := CriaVar(aHeader[nX,2])
						EndIf
					Next nX
					
					SB1->(dbSeek(xFilial("SB1")+CNB->CNB_PRODUT))
			                              
					aCols[Len(aCols),nITEM]    := PadL(Right(CNB->CNB_ITEM,TamSX3("C6_ITEM")[1]),TamSX3("C6_ITEM")[1],"0")
					aCols[Len(aCols),nITEMED]  := PadL(Right(CNB->CNB_ITEM,TamSX3("C6_ITEMED")[1]),TamSX3("C6_ITEMED")[1],"0")
					aCols[Len(aCols),nPRODUTO] := CNB->CNB_PRODUT
					aCols[Len(aCols),nUM]		:= SB1->B1_UM
					aCOls[Len(aCols),nSEGUM]	:= SB1->B1_SEGUM
					aCOls[Len(aCols),nLOCAL]	:= SB1->B1_LOCPAD
					aCols[Len(aCols),nTES]     := SB1->B1_TS
					aCols[Len(aCols),nDESCRI]  := SB1->B1_DESC
					aCols[Len(aCols),nCF]	    := Posicione("SF4",1,xFilial("SF4")+SB1->B1_TS,"F4_CF")
					aCols[Len(aCols),nPRUNIT]  := A410Arred(CNB->CNB_VLUNIT * If(CN9->CN9_FLGCAU=='1' .And. CN9->CN9_TPCAUC=='2',(1 - (CN9->CN9_MINCAU / 100)),1),"C6_PRUNIT")
					aCols[Len(aCols),nPRCVEN]  := A410Arred(aCols[Len(aCols),nPRUNIT],"C6_PRCVEN")
					aCols[Len(aCols),nCodIss]  := SB1->B1_CODISS
					If !Empty(CNB->CNB_DESC)
						aCols[len(aCols),nDESCONT] := A410Arred(CNB->CNB_DESC,"C6_DESCONT")
						aCols[Len(aCols),nPRCVEN]  -= A410Arred((CNB->CNB_VLUNIT * CNB->CNB_DESC) / 100,"C6_PRCVEN")
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se o item e comissionado     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If CNB->CNB_FLGCMS == "1"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Complementa as comissoes de acordo com os contratos ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						For nX := 1 to Len(aVendors)
							If !Empty(aCpsComis[nX])
								aCols[Len(aCols),aCpsComis[nX]] := aVendors[nX,2]
							EndIf
						Next nX
					EndIf
			
					If !lMedeve .Or. lSugVal
						dbSelectArea("CNF")
						If !Empty(cParcel) .And. !Empty(CND->(ColumnPos("CND_PARCEL")))
							dbSetOrder(3)
							dbSeek(xFilial("CNF",cFilCTR)+cContra+cRevisa+CNA->CNA_CRONOG+cParcel)
						Else
							dbSetOrder(2)
							dbSeek(xFilial("CNF",cFilCTR)+cContra+cRevisa+CNA->CNA_CRONOG+cCompet)
						EndIf
						
						CN0->(dbSetOrder(1))
						CN0->(dbSeek(xFilial("CN0",cFilCTR)+CN9->CN9_TIPREV))
										
						If (!lRealMed .And. CN0->CN0_TIPO == '3') .Or. (!lReajMed .And. CN0->CN0_TIPO == '2')									 	
							cQuery := "SELECT SUM(CNB.CNB_VLTOT) AS CNB_VLTOT "
							cQuery += "FROM " +RetSqlName("CNB") +" CNB "
							cQuery += "WHERE CNB.CNB_FILIAL = '"+xFilial("CNB",cFilCTR)  +"' AND "
							cQuery += "CNB_CONTRA = '" +CNA->CNA_CONTRA +"' AND "
							cQuery += "CNB_REVISA = '" +CNA->CNA_REVISA +"' AND "
							cQuery += "CNB_VLUNIT <> CNB_PRCORI AND "
							cQuery += "CNB.D_E_L_E_T_  =  ' '"
																		
							cQuery := ChangeQuery(cQuery)				
							dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"CNBTMP")
							TCSetField("CNBTMP","CNB_VLTOT","N",TamSX3("CNB_VLTOT")[1],TamSX3("CNB_VLTOT")[2])
							 									
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Calcula percentual da parcela com o total dos itens ³
							//³da planilha a serem medidos                         ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !("CNBTMP")->(Eof())  
								nPercCNF := (CNF->CNF_SALDO*100)/("CNBTMP")->CNB_VLTOT
							Else
								nPercCNF := (CNF->CNF_SALDO*100)/CNA->CNA_VLTOT
							EndIf					   		                    
							("CNBTMP")->(dbCloseArea())  
						Else
							nPercCNF := (CNF->CNF_SALDO*100)/CNA->CNA_VLTOT
						EndIf 						
						
						If !lFisico      
							aCols[Len(aCols),nQTDVEN] := A410Arred(Min((CNB->CNB_QUANT * nPercCNF)/100,CNB->CNB_SLDMED),"C6_QTDVEN")
							aCols[Len(aCols),nUNSVEN] := ConvUM(CNB->CNB_PRODUT,aCols[Len(aCols),nQTDVEN],0,2)
						Else
							dbSelectArea("CNS")
							dbSetOrder(1)						
							If dbSeek(xFilial("CNS",cFilCTR)+cContra+cRevisa+CNF->CNF_NUMERO+CNF->CNF_PARCEL+CNB->CNB_ITEM)
								aCols[Len(aCols),nQTDVEN] := A410Arred(Min(If((CNS->CNS_SLDQTD > 0),CNS->CNS_SLDQTD,0),CNB->CNB_SLDMED),"C6_QTDVEN")
								aCols[Len(aCols),nUNSVEN] := ConvUM(CNB->CNB_PRODUT,aCols[Len(aCols),nQTDVEN],0,2)
							EndIf
						EndIf									
						aCols[Len(aCols),nVALOR] := A410Arred(aCols[Len(aCols),nQTDVEN] * aCols[Len(aCols),nPRCVEN],"C6_VALOR")
						aCols[len(aCols),nVALDESC] := A410Arred((aCols[Len(aCols),nQTDVEN] * aCols[Len(aCols),nPRUNIT]) - aCols[Len(aCols),nVALOR],"C6_VALDESC")
					EndIf
			        
					aCols[Len(aCols),nENTREG]  := dDataBase
					aCols[Len(aCols),nSUGENTR] := dDataBase
				EndIf			
				dbSelectArea("CNB")
				dbSkip()
			EndDo
			Ma410Rodap()
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿              
			//³ Ajusta itens que ja possam estar no aCols ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nX :=1 to Len(aCols)
				aCols[nX,nITEMED] := CriaVar("C6_ITEMED",.F.)
				aCols[nX,nPRUNIT] := CriaVar("C6_PRUNIT",.F.)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Complementa as comissoes de acordo com os contratos ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(aVendors)
					For nY := 1 to Len(aVendors)
						If !Empty(aCpsComis[nY])
							aCols[nX,aCpsComis[nY]] := aVendors[nY,2]
						EndIf
					Next nY
				Else
					For nY := 1 to Len(aCpsComis)
						aCols[nx,aCpsComis[nY]] := CriaVar("C6_COMIS1",.F.)
					Next nY
				EndIf
			Next nX
		EndIf
	EndIf
EndIf   

SetKey(VK_F4,{||A440Stok(NIL,"A410")})
SetKey(VK_F9,{||A410KeyF9()})
Return     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³A410TotPoder3³ Autor ³ Vendas CRM			   ³ Data ³08/02/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Função utilizada para retornar valor total do saldo de poder   ³±±
±±³          ³de/em terceiros.									             		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A410TotPoder3(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1=Código do produto						                 		³±±
±±³          ³ExpC2=Tipo do Pedido (D=Dev.Compra/B=Util. Fornecedor)	     	³±±
±±³          ³ExpC3=Código do Cliente/Fornecedor		                     	³±±
±±³          ³ExpC4=Loja do Cliente/Fornecedor									³±±
±±³          ³ExpC5=Identificação da Origem										³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³																 		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/             
Function A410TotPoder3(cProduto,cTpNF,cCliFor,cLoja,cIdentB6)

Local aArea		:= GetArea()
Local cTpCliFor := IIf(cTpNF $ "DB","F","C")
Local cAliasSD1 := "SD1"
Local cAliasSD2 := "SD2"
Local cAliasSB6 := "SB6"
Local cQuery    := ""
Local cQuery1   := ""
Local cQuery2   := ""
Local lQuery    := .F.
Local lProcessa := .T.
Local nSldLiq   := 0
Local cFilSB6	:= xFilial("SB6")
Local cFilSD1	:= xFilial("SD1")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MV_VLDDATA - Valida data de emissao do documento de beneficiamento  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lVldData   := SuperGetMv("MV_VLDDATA",.F.,.T.)

dbSelectArea("SB6")
dbSetOrder(2)

If  !("POSTGRES" $ TCGetDB())
	lQuery    := .T.
	cAliasSB6 := "F4PODER3_SQL"
	cAliasSD1 := "F4PODER3_SQL"
	cAliasSD2 := "F4PODER3_SQL"

	cQuery := "SELECT DISTINCT(SD1.R_E_C_N_O_) SD1RECNO,SB6.R_E_C_N_O_ SB6RECNO,D1_VUNIT,D1_TOTAL,D1_VALDESC,D1_VALDEV,0 SD2RECNO,0 D2_PRCVEN,0 D2_TOTAL,0 D2_DESCON,D1_NUMLOTE NUMLOTE,D1_LOTECTL LOTECTL,'' D2_TIPO,D1_TIPO, "
	cQuery += "B6_FILIAL,B6_PRODUTO,B6_CLIFOR,B6_LOJA,B6_PODER3,B6_IDENTB6,B6_TPCF,B6_QUANT,B6_QULIB,B6_TIPO "
	cQuery1:= " FROM "+RetSqlName("SB6")+" SB6 ,"
	cQuery1 += RetSqlName("SD1")+" SD1 "
	cQuery1 += "WHERE SB6.B6_FILIAL='"+cFilSB6+"' AND "
	cQuery1 += "SB6.B6_PRODUTO    = '"+cProduto+"' AND "
	If !IsTriangular()
		cQuery1 += "SB6.B6_CLIFOR = '"+cCliFor+"' AND "
		cQuery1 += "SB6.B6_LOJA   = '"+cLoja+"' AND "
	EndIf
	cQuery1 += "SB6.B6_PODER3  = 'R' AND "
	cQuery1 += "(SB6.B6_IDENT = '" +cIdentB6+"' OR "
	cQuery1 += " SB6.B6_IDENTB6 = '" +cIdentB6+"') AND "
	cQuery1 += "SB6.B6_TPCF    = '"+cTpCliFor+"' AND "
	cQuery1 += "SB6.D_E_L_E_T_ = ' ' AND "
	cQuery1 += "SB6.B6_TIPO   = 'D' AND "
	cQuery1 += "SD1.D1_FILIAL = '"+cFilSD1+"' AND "
	cQuery1 += "SD1.D1_NUMSEQ = SB6.B6_IDENT AND "
	If lVldData
		cQuery1 += "SD1.D1_DTDIGIT <= '" + DTOS(dDataBase) + "' AND "
	EndIf	
	cQuery1 += "SD1.D_E_L_E_T_=' ' "
	cQuery += cQuery1 + " UNION ALL "
	cQuery += "SELECT DISTINCT(0) SD1RECNO,SB6.R_E_C_N_O_ SB6RECNO,0 D1_VUNIT,0 D1_TOTAL,0 D1_VALDESC,0 D1_VALDEV,SD2.R_E_C_N_O_ SD2RECNO,D2_PRCVEN,D2_TOTAL,D2_DESCON,D2_NUMLOTE NUMLOTE,D2_LOTECTL LOTECTL, D2_TIPO,'' D1_TIPO, "
	cQuery += "B6_FILIAL,B6_PRODUTO,B6_CLIFOR,B6_LOJA,B6_PODER3,B6_IDENTB6,B6_TPCF,B6_QUANT,B6_QULIB,B6_TIPO "
	cQuery2:= " FROM "+RetSqlName("SB6")+" SB6 ,"
	cQuery2 += RetSqlName("SD2")+" SD2 "			
	cQuery2 += "WHERE SB6.B6_FILIAL = '"+cFilSB6+"' AND "
	cQuery2 += "SB6.B6_PRODUTO	   = '"+cProduto+"' AND "
	cQuery2 += "SB6.B6_PODER3	   = 'D' AND "
	cQuery2 += "(SB6.B6_IDENT = '" +cIdentB6+"' OR "
	cQuery2 += " SB6.B6_IDENTB6 = '" +cIdentB6+"') AND "
	cQuery2 += "SB6.B6_TPCF         = '"+cTpCliFor+"' AND "
	cQuery2 += "SB6.D_E_L_E_T_	   = ' ' AND "
	If !IsTriangular()
		cQuery2 += "SB6.B6_CLIFOR='"+cCliFor+"' AND "
		cQuery2 += "SB6.B6_LOJA='"+cLoja+"' AND "
	EndIf
	cQuery2 += "SB6.B6_TIPO    ='D' AND "
	cQuery2 += "SD2.D2_FILIAL  ='"+xFilial("SD2")+"' AND "
	cQuery2 += "SD2.D2_DOC	  = SB6.B6_DOC AND "
	cQuery2 += "SD2.D2_SERIE   = SB6.B6_SERIE AND "
	cQuery2 += "SD2.D2_CLIENTE = SB6.B6_CLIFOR AND "
	cQuery2 += "SD2.D2_LOJA    = SB6.B6_LOJA AND " 
	cQuery2 += "SD2.D2_COD     = SB6.B6_PRODUTO AND "
	cQuery2 += "SD2.D2_IDENTB6 = SB6.B6_IDENT AND "
	cQuery2 += "SD2.D2_QUANT	  = SB6.B6_QUANT AND "
	If lVldData
		cQuery2 += "SD2.D2_EMISSAO <= '" + DTOS(dDataBase) + "' AND "
	EndIf	
	cQuery2 += "SD2.D_E_L_E_T_=' ' "	
	cQuery := cQuery + cQuery2
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB6,.T.,.F.)	
Else
	If IsTriangular()
		MsSeek(cFilSB6+cProduto)	
	Else
		MsSeek(cFilSB6+cProduto+cCliFor+cLoja,.F.)
	EndIf
EndIf

If lQuery
	dbSelectArea(cAliasSB6)
	dbGotop()
EndIf
While (cAliasSB6)->(!Eof()) .And. (cAliasSB6)->B6_FILIAL = cFilSB6 .And.;
		(cAliasSB6)->B6_PRODUTO == cProduto .And.;
		IIF(IsTriangular(),.T.,IIf(lQuery,.T.,(cAliasSB6)->B6_CLIFOR == cCliFor .And.;
		(cAliasSB6)->B6_LOJA == cLoja ))

	If lProcessa .AND.;
	   (cAliasSB6)->B6_TIPO == "D" .AND.;
	   (cAliasSB6)->B6_TPCF == cTpCliFor
		If !lQuery
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verificar qual eh a tabela de origem do poder de terceiros          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ((cAliasSB6)->B6_TIPO=="D" .And. (cAliasSB6)->B6_PODER3 == "R" ) .Or. ((cAliasSB6)->B6_TIPO=="E" .And. (cAliasSB6)->B6_PODER3 == "D")
				dbSelectArea("SD1")
				If (cAliasSB6)->B6_PODER3 == "R"
					SD1->(dbSetOrder(4))
					SD1->(dbSeek(cFilSD1+(cAliasSB6)->B6_IDENT))
				Else
					SD1->(dbSetOrder(1))
					SD1->(dbSeek(cFilSD1+(cAliasSB6)->B6_DOC+(cAliasSB6)->B6_SERIE+(cAliasSB6)->B6_CLIFOR+(cAliasSB6)->B6_LOJA+(cAliasSB6)->B6_PRODUTO))
					While SD1->(!Eof()) .And. cFilSD1 == SD1->D1_FILIAL .And.;
							(cAliasSB6)->B6_DOC       == SD1->D1_DOC .And.;
							(cAliasSB6)->B6_SERIE     == SD1->D1_SERIE .And.;
							(cAliasSB6)->B6_CLIFOR    == SD1->D1_FORNECE .And.;
							(cAliasSB6)->B6_LOJA      == SD1->D1_LOJA .And.;
							(cAliasSB6)->B6_PRODUTO   == SD1->D1_COD
							
						If (cAliasSB6)->B6_IDENT==SD1->D1_IDENTB6 .And. (cAliasSB6)->B6_QUANT=SD1->D1_QUANT
							Exit
						EndIf				
						SD1->(dbSkip())
					EndDo
				EndIf
			EndIf
		EndIf			                          
		If ((cAliasSB6)->B6_TIPO=="D" .And. (cAliasSB6)->B6_PODER3 == "R" ) .Or. ((cAliasSB6)->B6_TIPO=="E" .And. (cAliasSB6)->B6_PODER3 == "D")
			lProcessa := lProcessa .And. (cAliasSD1)->D1_TIPO<>"I"
		EndIf
		If lProcessa
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verificar qual eh a tabela de origem do poder de terceiros e calcula³
			//³ o valor total do saldo de poder de/em terceiros                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ((((cAliasSB6)->B6_TIPO=="D" .And. (cAliasSB6)->B6_PODER3 == "R" ) .Or. ((cAliasSB6)->B6_TIPO=="E" .And. (cAliasSB6)->B6_PODER3 == "D")) .And.;
				IIf (lQuery,.T.,(((cAliasSB6)->B6_IDENT == cIdentB6) .Or. ((cAliasSB6)->B6_IDENTB6 == cIdentB6))))
				If (cAliasSB6)->B6_PODER3 == "R"
					nSldLiq += (cAliasSD1)->D1_TOTAL-(cAliasSD1)->D1_VALDESC-(cAliasSD1)->D1_VALDEV
				Else
					nSldLiq -= (cAliasSD1)->D1_TOTAL-(cAliasSD1)->D1_VALDESC-(cAliasSD1)->D1_VALDEV
				EndIf
			EndIf
		EndIf
	EndIf
	dbSelectArea(cAliasSB6)
	dbSkip()
EndDo

If lQuery
	dbSelectArea(cAliasSB6)
	dbCloseArea()
	RestArea(aArea)
Else
	dbSelectArea("SD1")
	dbSetOrder(4)
	dbSeek(cFilSD1+cIdentB6)
EndIf
Return(nSldLiq) 

//------------------------------------------------------------------------------
/*/{Protheus.doc} Ma410Bom
    Função que carrega a Estrutura do Produto no Pedido de Venda

	@sample	    Ma410Bom(aHeader,aCols,nX)
    @param		aHeader , Array     , Array do Cabeçalho
	@param		aCols   , Array	    , Array dos Itens
	@param		nX      , Numérico 	, Número da linha posicionada 
	@return		.T.		, Lógico

    @author		Squad CRM/FAT
    @since		30/07/2019
    @version	1.0
/*/
//------------------------------------------------------------------------------
Function Ma410Bom(aHeader,aCols,nX)

Local aArea     := GetArea()
Local aBOM      := {}
Local nPProduto := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})
Local nPTES     := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_TES"})
Local nPQtdVen  := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_QTDVEN"})
Local nPItem    := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ITEM"})
Local nPTotal   := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_VALOR"})
Local nY        := 0
Local cItem     := ""
Local lMA410BOM := ExistBlock("MA410BOM")

Private N 	    := nX
Private nEstru  := 0

//Localiza todos os componentes do primeiro nível da estrutura.
A410Explod(aCols[nX][nPProduto],aCols[nX][nPQtdVen],@aBOM)

If lMA410BOM
	ExecBlock("MA410BOM",.F.,.F.,{aBOM})
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona os produtos no aCols                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aBOM)
		cItem := aCols[Len(aCols)][nPItem]
		aAdd(aCOLS,Array(Len(aHeader)+1))
		For nY	:= 1 To Len(aHeader)
			If ( AllTrim(aHeader[nY][2]) == "C6_ITEM" )
				aCols[Len(aCols)][nY] := Soma1(cItem)
			Else
				If (aHeader[nY,2] <> "C6_REC_WT") .And. (aHeader[nY,2] <> "C6_ALI_WT")				
					aCols[Len(aCols)][nY] := CriaVar(aHeader[nY][2])
				EndIf	
			EndIf
		Next nY
		N := Len(aCols)
		aCOLS[N][Len(aHeader)+1] := .F.
		A410Produto(aBom[nX][1],.F.)
		aCols[N][nPProduto] := aBom[nX][1]
		A410MultT("M->C6_PRODUTO",aBom[nX][1])
		If ExistTrigger("C6_PRODUTO")
			RunTrigger(2,N,Nil,,"C6_PRODUTO")
		EndIf
		A410SegUm(.T.)
		A410MultT("M->C6_QTDVEN",aBom[nX][2])
		If ExistTrigger("C6_QTDVEN ")
			RunTrigger(2,N,Nil,,"C6_QTDVEN ")
		EndIf
		If Empty(aCols[N][nPTotal]) .Or. Empty(aCols[N][nPTES])
			aCOLS[N][Len(aHeader)+1] := .T.
		EndIf
	Next nX
EndIf	

RestArea(aArea)
Return(.T.)

//------------------------------------------------------------------------------
/*/{Protheus.doc} A410Explod
    Função recursiva para localizar todos os componentes do primeiro nível 
	da estrutura.

    @sample	    A410Explod(cProduto,nQuant,aNewStruct)
	@param		cProduto   , Caractere 	, Código do Produto Pai
	@param		nQuant     , Numérico  	, Quantidade do Produto Pai 
    @param		aNewStruct , Array     	, Array de retorno
	@return		Nil

    @author		Squad CRM/FAT
    @since		30/07/2019
    @version	1.0
/*/
//------------------------------------------------------------------------------
Static Function A410Explod(cProduto,nQuant,aNewStruct)

Local aAreaAnt	 := GetArea()
Local nX		 := 0
Local aArrayAux  := {}

//Variável private declarada na função Ma410Bom()
nEstru := 0
//Faz a explosão de uma estrutura a partir do SG1
aArrayAux := Estrut(cProduto,nQuant,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Processa todos os componentes do 1 nível da estrutura,  |
//| verificando a existência de produtos fantasmas.         |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SB1")
dbSetOrder(1)
For nX := 1 to Len(aArrayAux)
	If MsSeek(xFilial("SB1")+aArrayAux[nx,3]) 	//Filial+Componente
		If RetFldProd(SB1->B1_COD,"B1_FANTASM") $ "S"
			A410Explod(aArrayAux[nx,3],aArrayAux[nx,4],aNewStruct) 	//Componente+Qtde
		Else
			aAdd(aNewStruct,{aArrayAux[nx,3],aArrayAux[nx,4],SB1->B1_DESC})
		EndIf
	EndIf
Next nX

RestArea(aAreaAnt)
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³a410SNfOri³ Autor ³Eduardo Riera          ³ Data ³01.03.99  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula o Saldo da Nota Original informada.                 ³±±
±±³          ³Calcula o Saldo do poder de terceiros.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1: Quantidade ja utilizada                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Cliente/Fornecedor                                   ³±±
±±³          ³ExpC2: Loja                                                 ³±±
±±³          ³ExpC3: Nota Fiscal Original                                 ³±±
±±³          ³ExpC4: Serie Original                                       ³±±
±±³          ³ExpC5: Item da Nota Original                                ³±±
±±³          ³ExpC6: Codigo do Produto                                    ³±±
±±³          ³ExpC7: Identificador do Poder de Terceiro                   ³±±
±±³          ³ExpC8: Local Padrao                                         ³±±
±±³          ³ExpC7: Alias do SD1                                    (OPC)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A410SNfOri(cCliFor,cLoja,cNfOri,cSerOri,cItemOri,cProduto,cIdentB6,cLocal,cAliasSD1,aPedido,l410ProcDv)

Local aArea 	:= GetArea()
Local aAreaSD1	:= SD1->(GetArea())
Local aAreaSC6	:= SC6->(GetArea())
Local aAreaSF4	:= SF4->(GetArea())
Local aAreaSB6	:= SB6->(GetArea())
Local aStruSC6  := {}
Local aCq       := {}
Local aRetCq    := {}
Local nX        := 0
Local nQuant	:= 0
Local nValor    := 0
Local nPQtdVen	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"  .Or. AllTrim(x[2])=="D2_QUANT"})
Local nPPrcVen	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"  .Or. AllTrim(x[2])=="D2_PRCVEN"})
Local nPNfOri 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_NFORI"   .Or. AllTrim(x[2])=="D2_NFORI"})
Local nPSerOri	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_SERIORI" .Or. AllTrim(x[2])=="D2_SERIORI"})
Local nPItemOri := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEMORI" .Or. AllTrim(x[2])=="D2_ITEMORI"})
Local nPIdentb6 := aScan(aHeader,{|x| AllTrim(x[2])=="C6_IDENTB6" .Or. AllTrim(x[2])=="D2_IDENTB6"})
Local nPTES     := aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"     .Or. AllTrim(x[2])=="D2_TES"})
Local nPProduto := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO" .Or. AllTrim(x[2])=="D2_COD"})
Local nUsado	:= 0
Local nCntFor	:= 0
Local cCq       := SuperGetMv("MV_CQ")
Local cQuery    := ""
Local cAliasSC6 := "SC6"
Local lQuery    := .F.
Local aSaldoCQ  := {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
Local nQtdCols  := 0
Local nQtdPed   := 0
Local cFilSD1	:= xFilial("SD1")
Local cFilSC6	:= xFilial("SC6")
Local cFilSF4	:= xFilial("SF4")
Local cFilSB6	:= xFilial("SB6")

DEFAULT aPedido   := {}
DEFAULT cIdentB6  := CriaVar("C6_IDENTB6",.F.)
DEFAULT cAliasSD1 := "SD1"
DEFAULT l410ProcDv:= .F.	//Se for .T., está vindo da rotina de "Retornar" do pedido de vendas (Função: A410ProcDv)

If Type("M->C5_NUM") == "U"
	M->C5_NUM := ""
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para devolucao                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  ( !Empty(cItemOri) )
	dbSelectArea("SD1")
	dbSetOrder(1)
	If ( ( cFilSD1  == (cAliasSD1)->D1_FILIAL  .AND.;
	       cNfOri   == (cAliasSD1)->D1_DOC     .AND.;
		   cSerOri  == (cAliasSD1)->D1_SERIE   .AND.;
		   cCliFor  == (cAliasSD1)->D1_FORNECE .AND.;
		   cLoja    == (cAliasSD1)->D1_LOJA    .AND.;
		   cProduto == (cAliasSD1)->D1_COD     .AND.;
		   cItemOri == (cAliasSD1)->D1_ITEM )          .Or. ;
				MsSeek(cFilSD1+cNfOri+cSerOri+cCliFor+cLoja+cProduto+cItemOri) )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica quantidade ja faturada independente da TES                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nQuant += (cAliasSD1)->D1_QUANT
		nQuant -= (cAliasSD1)->D1_QTDEDEV
		nValor += (cAliasSD1)->D1_TOTAL-(cAliasSD1)->D1_VALDESC
		nValor -= (cAliasSD1)->D1_VALDEV
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica quantidade no CQ                                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (cAliasSD1)->D1_LOCAL == cCQ
			If __lPyme
				aCQ := fLibRejCQ((cAliasSD1)->D1_COD,(cAliasSD1)->D1_DOC,(cAliasSD1)->D1_SERIE,(cAliasSD1)->D1_FORNECE,(cAliasSD1)->D1_LOJA,Nil,(cAliasSD1)->D1_ITEM)
			Else
				aCQ := fLibRejCQ((cAliasSD1)->D1_COD,(cAliasSD1)->D1_DOC,(cAliasSD1)->D1_SERIE,(cAliasSD1)->D1_FORNECE,(cAliasSD1)->D1_LOJA,(cAliasSD1)->D1_NUMLOTE,(cAliasSD1)->D1_ITEM)				
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica a quantidade em  Pedido de Venda                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SC6")
		dbSetOrder(5)

		lQuery := .T.
		cAliasSC6 := "A410SNFORI"
		aStruSC6  := SC6->(dbStruct())
		cQuery := "SELECT SC6.C6_FILIAL,SC6.C6_CLI,SC6.C6_LOJA,SC6.C6_PRODUTO,"
		cQuery += "SC6.C6_NFORI,SC6.C6_SERIORI,SC6.C6_ITEMORI,SC6.C6_NUM,"
		cQuery += "SC6.C6_QTDVEN,SC6.C6_QTDENT,SC6.C6_QTDEMP,SC6.C6_PRCVEN,"
		cQuery += "SC6.C6_NOTA "
		cQuery += "FROM "+RetSqlName("SC6")+" SC6 "
		cQuery += "WHERE SC6.C6_FILIAL = '"+cFilSC6+"' AND "
		cQuery += "SC6.C6_CLI='"+cCliFor+"' AND "
		cQuery += "SC6.C6_LOJA='"+cLoja+"' AND "
		cQuery += "SC6.C6_PRODUTO='"+cProduto+"' AND "
		cQuery += "SC6.C6_NFORI='"+cNfOri+"' AND "
		cQuery += "SC6.C6_SERIORI='"+cSerOri+"' AND "
		cQuery += "SC6.C6_ITEMORI='"+cItemOri+"' AND "
		cQuery += "SC6.C6_BLQ <> 'R' AND "
		cQuery += "SC6.D_E_L_E_T_=' ' "
		cQuery += "ORDER BY "+SqlOrder(SC6->(IndexKey()))
		
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC6,.T.,.T.)
		
		For nX := 1 To Len(aStruSC6)
			If ColumnPos(aStruSC6[nX][1])<>0 .And. aStruSC6[nX][2]<>"C"
				TcSetField(cAliasSC6,aStruSC6[nX][1],aStruSC6[nX][2],aStruSC6[nX][3],aStruSC6[nX][4])
			EndIf
		Next nX
			
		While ( (cAliasSC6)->(! Eof()) .And. cFilSC6 == (cAliasSC6)->C6_FILIAL .And.;
				cCliFor == (cAliasSC6)->C6_CLI .And.;
				cLoja == (cAliasSC6)->C6_LOJA .And.;
				cProduto == (cAliasSC6)->C6_PRODUTO .And.;
				cNfOri == (cAliasSC6)->C6_NFORI .And.;
				cSerOri == (cAliasSC6)->C6_SERIORI .And.;
				cItemOri == (cAliasSC6)->C6_ITEMORI )

			If ( M->C5_NUM != (cAliasSC6)->C6_NUM )			
				If aScan(aPedido,{|x| x == (cAliasSC6)->C6_NUM}) == 0  .And. (Max((cAliasSC6)->C6_QTDVEN,(cAliasSC6)->C6_QTDEMP)-(cAliasSC6)->C6_QTDENT) > 0
					aAdd(aPedido,(cAliasSC6)->C6_NUM)
				EndIf
				nQuant -= (Max((cAliasSC6)->C6_QTDVEN,(cAliasSC6)->C6_QTDEMP)-(cAliasSC6)->C6_QTDENT)
				nValor -= (cAliasSC6)->C6_PRCVEN*Max((Max((cAliasSC6)->C6_QTDVEN,(cAliasSC6)->C6_QTDEMP)-(cAliasSC6)->C6_QTDENT),IIf(Empty((cAliasSC6)->C6_NOTA).And.(cAliasSC6)->C6_QTDVEN==0,1,0))
			Else
				nQuant += (cAliasSC6)->C6_QTDENT
				nValor += (cAliasSC6)->C6_PRCVEN*Max((cAliasSC6)->C6_QTDENT,IIf(Empty((cAliasSC6)->C6_NOTA).And.(cAliasSC6)->C6_QTDVEN==0,1,0))
			EndIf

			(cAliasSC6)->(dbSkip())
		EndDo
		If lQuery
			(cAliasSC6)->(dbCloseArea())
			dbSelectArea("SC6")
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica a quantidade no Pedido Atual                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nUsado := Len(aHeader)
		For nCntFor := 1  To Len(aCols)
			If ( !aCols[nCntFor][nUsado+1]           .And.;
			     nPNfOri   != 0                      .And.;
			     nPSerOri  != 0                      .And.;
			     nPItemOri != 0                      .And.;
				 n <> nCntFor                        .And.;
			     aCols[nCntFor][nPNfOri] == cNfOri   .And.;
			     aCols[nCntFor][nPSerOri] == cSerOri .And.;
			     aCols[nCntFor][nPItemOri] == cItemOri )

				nQuant -= aCols[nCntFor][nPQtdVen]
				nValor -= aCols[nCntFor][nPPrcVen]*aCols[nCntFor][nPQtdVen]

			EndIf
		Next nCntFor
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para  Poder de Terceiros - nao se deve verificar F4_ESTOQUE  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica o Saldo do Poder de Terceiro no SB6 com identificador          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nQuant := 0
	nValor := 0
	SF4->(dbSetOrder(1))
	dbSelectArea("SB6")
	dbSetOrder(3)
	If ( MsSeek(cFilSB6+cIdentB6+cProduto+"R",.F.) )
		nQuant := SB6->B6_SALDO - SB6->B6_QULIB
		nValor := ( nQuant * SB6->B6_PRUNIT ) - (cAliasSD1)->D1_VALDESC

		// Verifica se existe complemento de preco e acrescenta valor unitario correspondente
		If (nComplPrc := MaAvCpUnit(SB6->(B6_FILIAL+B6_IDENT+B6_PRODUTO)+"R")) > 0
			nValor += nComplPrc * nQuant
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica a quantidade em  Pedido de Venda                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SC6")
		dbSetOrder(5)
		If SC6->( MsSeek(cFilSC6+cCliFor+cLoja+cProduto+cNfOri+cSerOri) )
			While ( SC6->(! Eof()) .And. cFilSC6 == SC6->C6_FILIAL .And.;
					cCliFor   == SC6->C6_CLI		.And.;
					cLoja     == SC6->C6_LOJA		.And.;
					cProduto  == SC6->C6_PRODUTO	.And.;
					cNfOri    == SC6->C6_NFORI		.And.;
					cSerOri   == SC6->C6_SERIORI )

				If  ( cIdentB6 ==  SC6->C6_IDENTB6 )
					If SF4->( MsSeek(cFilSF4+SC6->C6_TES) ) .AND. SF4->F4_PODER3 == "D"
						If ( M->C5_NUM != SC6->C6_NUM )
							If aScan(aPedido,{|x| x == (cAliasSC6)->C6_NUM}) == 0 .And.  (Max((cAliasSC6)->C6_QTDVEN,(cAliasSC6)->C6_QTDEMP)-(cAliasSC6)->C6_QTDENT) > 0
								aAdd(aPedido,(cAliasSC6)->C6_NUM)
							EndIf
							nQuant -= (If(SC6->C6_QTDEMP>0,0,SC6->C6_QTDVEN)-SC6->C6_QTDENT)
							nValor -= ((If(SC6->C6_QTDEMP>0,0,SC6->C6_QTDVEN)-SC6->C6_QTDENT)*SC6->C6_PRCVEN)
							nQtdPed += SC6->C6_QTDVEN
						Else
							nQuant += SC6->C6_QTDENT
							nQuant += SC6->C6_QTDEMP
							nValor += ((SC6->C6_QTDENT)*SC6->C6_PRCVEN)
							nValor += ((SC6->C6_QTDEMP)*SC6->C6_PRCVEN)
							nQtdPed += If(SC6->C6_QTDENT>0,SC6->C6_QTDVEN-SC6->C6_QTDENT,0)
						EndIf
					EndIf
				EndIf

				SC6->(dbSkip())
			EndDo
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica a quantidade no Pedido Atual                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nUsado := Len(aHeader)
		For nCntFor := 1  To Len(aCols)
			If ( !aCols[nCntFor][nUsado+1] .And. nPIdentB6 != 0 )                                        .AND.;
			   ( ( aCols[nCntFor][nPIdentB6] == cIdentB6 ) .And. cProduto == aCols[nCntFor][nPProduto] ) .AND.;
			   ( SF4->( MsSeek(cFilSF4+aCols[nCntFor][nPTes]) ) .AND. SF4->F4_PODER3 == "D" )

				nQuant -= aCols[nCntFor][nPQtdVen]
				nValor += aCols[nCntFor][nPQtdVen]*aCols[nCntFor][nPPrcVen]
				nQtdCols += aCols[nCntFor][nPQtdVen]

			EndIf
		Next nCntFor

		dbSelectArea("SD1")
		dbSetOrder(4)
		If MsSeek(cFilSD1+SB6->B6_IDENT)
			aSaldoCQ := A175CalcQt(SD1->D1_NUMCQ, SB6->B6_PRODUTO, SB6->B6_LOCAL)
		Endif	
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Nao ha como otimizar o codigo pois pode haver poder de terceiro         ³
		//³gravados c/ identificador ou nao, assim somente eh possivel calcular  o ³
		//³saldo verificando  todas os  pedidos deste  cliente  com este  produto  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SB6->(dbSetOrder(2))
		SB6->(MsSeek(cFilSB6+cProduto+cCliFor+cLoja+"R"))
		While ( SB6->(! Eof())               .And.;
		        cFilSB6   == SB6->B6_FILIAL  .And.;
				cProduto  == SB6->B6_PRODUTO .And.;
				cCliFor   == SB6->B6_CLIFOR  .And.;
				cLoja     == SB6->B6_LOJA    .And.;
				"R"       == SB6->B6_PODER3 )
			If !( ( M->C5_TIPO == "B" .And. SB6->B6_TPCF != "F") .Or.;
			      ( M->C5_TIPO == "N" .And. SB6->B6_TPCF != "C") )
				nQuant += ( SB6->B6_SALDO - SB6->B6_QULIB )
				nValor += (( SB6->B6_SALDO - SB6->B6_QULIB )*SB6->B6_PRUNIT) - (cAliasSD1)->D1_VALDESC
			EndIf
			SB6->(dbSkip())
		EndDo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica a quantidade em Pedido de Venda                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SC6")
		dbSetOrder(5)
		If SC6->( MsSeek(cFilSC6+cCliFor+cLoja+cProduto) )
			While ( SC6->(! Eof())            .And.;
			        cFilSC6 == SC6->C6_FILIAL .And.;
					cCliFor	== SC6->C6_CLI    .And.;
					cLoja == SC6->C6_LOJA     .And.;
					cProduto == SC6->C6_PRODUTO )

				If SF4->(MsSeek(cFilSF4+SC6->C6_TES)) .AND. SF4->F4_PODER3 == "D"
					If ( M->C5_NUM != SC6->C6_NUM )
						nQuant -= (SC6->C6_QTDVEN-SC6->C6_QTDENT)
						nValor -= IIf(Empty(SC6->C6_NOTA).And.SC6->C6_QTDVEN==0,1,SC6->C6_QTDVEN-SC6->C6_QTDENT)*SC6->C6_PRCVEN
					Else
						nQuant += SC6->C6_QTDENT
						nValor += IIf(Empty(SC6->C6_NOTA).And.SC6->C6_QTDVEN==0,1,SC6->C6_QTDENT)*SC6->C6_PRCVEN
					EndIf
				EndIf
				SC6->(dbSkip())
			EndDo
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica a quantidade no Pedido Atual                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nUsado := Len(aHeader)
		For nCntFor := 1  To Len(aCols)
			If ( !aCols[nCntFor][nUsado+1] .And. nPIdentB6 != 0 )                        .AND.;
			   ( ( MsSeek(cFilSF4+aCols[nCntFor][nPTes]) ) .AND. SF4->F4_PODER3 == "D" )

				nQuant -= aCols[nCntFor][nPQtdVen]
				nValor -= IIf(Empty(SC6->C6_NOTA).And.SC6->C6_QTDVEN==0,1,aCols[nCntFor][nPQtdVen])*aCols[nCntFor][nPPrcVen]
				nQtdCols += aCols[nCntFor][nPQtdVen]

			EndIf
		Next nCntFor
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Prepara o array com os dados do controle de qualidade                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCntFor := 1  To Len(aCq)
	If aCq[nCntFor,1] > 0 	.And. aCq[nCntFor,2] > 0
		AADD(aRetCq,{aCq[nCntFor,2],ConvUm(cProduto,aCq[nCntFor,2],0,2),aCq[nCntFor,3]})
	EndIf
Next nCntFor
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a entrada da rotina                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaSB6)
RestArea(aAreaSF4)
RestArea(aAreaSC6)
RestArea(aAreaSD1)
RestArea(aArea)

Return({NoRound(nQuant,TamSX3("C6_QTDVEN")[2]),IIf(!l410ProcDv,a410Arred(nValor,"C6_VALOR"),nValor),If(Len(aRetCq)>0,aRetCq,""),aSaldoCQ,nQtdCols,nQtdPed})

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A410GrdOP º Autor ³ Materiais          º Data ³ 30/12/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o Numero da OP amarrada ao Item do PV com Grade    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA410                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A410GrdOP(cItem,cProduto)

Local aAreaSC6 := SC6->(GetArea())
Local aRet     := {}

SC6->(dbSetOrder(1))
If SC6->(MsSeek(xFilial("SC6")+M->C5_NUM+cItem+cProduto))
	aRet := {SC6->C6_NUMOP,SC6->C6_ITEMOP}
Else
	aRet := {Space(Len(SC6->C6_NUMOP)),Space(Len(SC6->C6_ITEMOP))}
EndIf

RestArea(aAreaSC6)
Return aRet

//--------------------------------------------------------------------
/*/{Protheus.doc} A410MenNo
Função para verificar o conteudo do campo C5_MENNOTA

@author TOTVS Protheus
@since  12/01/2017
@obs   Serviços
@version 1.0
/*/
//--------------------------------------------------------------------
Function A410MenNo()

Local lRet := .T.

If "M->C5_MENNOTA" $ ReadVar()
	lRet:= Texto()
EndIf
Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} A410DevFlt
	Esta Função tem como objetivo montar o filtro utilizado na rotina de Retorno de Doc. de Entrada

	@sample		A410DevFlt( dDataDe, dDataAte, lForn, lFornece )
	@param		dDataDe		, Data	, Data Inicio
	@param		dDataAte	, Data	, Data Fim
	@param		lForn		, Lógico, Fornecedor ou Cliente
	@param		lFornece	, Lógico, Exibe por Documento ou Fornecedor
	@author 	Squad CRM
	@since 		11/04/2019
	@version 	P12
	@return 	lRet , Logico,  Retorna existe conteudo no Browse
/*/
//-------------------------------------------------------------------
Static Function A410DevFlt( dDataDe, dDataAte, lForn, lFornece )

	Local cFilter	:= ""
	Local cConcat	:= "+"

	If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"
		cConcat := "||"
	Endif

	cFilter := " F1_FILIAL = '" + xFilial("SF1") + "' "
	cFilter += " AND F1_FORNECE = '" + cFornece + "' "
	cFilter += " AND F1_LOJA    = '" + cLoja    + "' "

	If lFornece
		cFilter += " AND F1_DTDIGIT BETWEEN '" + DtoS( dDataDe )  + "' AND '" + DtoS( dDataAte ) + "' "		
		cFilter += " AND F1_STATUS  <> '" + Space( Len( SF1->F1_STATUS ) ) + "' "		
	Else
		cFilter += " AND F1_EMISSAO >= '" + DtoS( dDataDe )  + "' "
		cFilter += " AND F1_EMISSAO <= '" + DtoS( dDataAte ) + "' "
	Endif
	
	If lForn
		cFilter += " AND F1_TIPO NOT IN ('D','B','C') "
	Else
		cFilter += " AND F1_TIPO = 'B' "
	EndIf

	cFilter += " AND NOT EXISTS ( "
	cFilter += " SELECT D1_FILIAL "+ cConcat + " D1_DOC " + cConcat + " D1_SERIE FROM ( "
	cFilter += " SELECT D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, SUM(D1_QUANT) D1_QUANT "
	cFilter += " FROM " + RetSqlName( "SD1" )
	cFilter += " WHERE D1_FILIAL = '" + xFilial( "SD1" ) + "' "
	cFilter += " AND D1_FORNECE = '" + cFornece + "' "
	cFilter += " AND D1_LOJA = '" + cLoja    + "' "
	cFilter += " AND D_E_L_E_T_ = ' ' "
	cFilter += " GROUP BY  D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE "
	cFilter += " ) SD1 INNER JOIN ( "
	cFilter += " SELECT C6_FILIAL, C6_NFORI, C6_SERIORI, C6_CLI, SUM(C6_QTDVEN) C6_QTDVEN "
	cFilter += " FROM " + RetSqlName( "SC5" ) + " SC5 "
	cFilter += " INNER JOIN " + RetSqlName( "SC6" ) + " SC6 "
	cFilter += " ON C5_FILIAL = C6_FILIAL AND "
	cFilter += " C5_NUM = C6_NUM AND "
	cFilter += " SC5.D_E_L_E_T_ = SC6.D_E_L_E_T_ "
	cFilter += " WHERE C5_FILIAL = '" + xFilial( "SC5" ) + "' "
	cFilter += " AND C5_CLIENTE = '" + cFornece + "' "
	cFilter += " AND C5_LOJACLI = '" + cLoja    + "' "

	If lForn
		cFilter += " AND C5_TIPO IN ('D', 'B') "
	Else
		cFilter += " AND C5_TIPO = 'N' "
	EndIf

	cFilter += " AND SC5.D_E_L_E_T_ <> '*' "
	cFilter += " GROUP BY C6_FILIAL, C6_NFORI, C6_SERIORI , C6_CLI "
	cFilter += " ) SC6 "
	cFilter += " ON D1_FILIAL = C6_FILIAL AND D1_DOC = C6_NFORI AND D1_SERIE = C6_SERIORI "
	cFilter += " AND D1_FORNECE = C6_CLI AND D1_QUANT <= C6_QTDVEN "
	cFilter += " WHERE D1_FILIAL = F1_FILIAL "
	cFilter += " AND D1_DOC = F1_DOC "
	cFilter += " AND D1_SERIE = F1_SERIE ) "

	If lFornece
		cFilter += " AND " + RetSqlName("SF1") + ".D_E_L_E_T_ = ' ' "
	Endif

Return cFilter

//------------------------------------------------------------------
/*/{Protheus.doc} A410DevoK
	Esta Função tem como objetivo verificar a ação ao clicar no botão retornar
	no pedido de vendas

	@author 	Squad CRM
	@since 		11/04/2019
	@version 	P12
	@return 	lRet , Logico,  Retorna existe conteudo no Browse
/*/
//-------------------------------------------------------------------
Function A410DevoK( oBrowse, lFornece, cAlias, nReg, nOpcx , cDocSF1 )
	
	Local lRet 		:= .T.

	Default lFornece := .F.

	If lFornece
		If A410ProcDv( cAlias, nReg, nOpcx, lFornece, cFornece, cLoja, cDocSF1 ) == 0
			lRet := .F.
		Endif
	Else
		If !Empty(SF1->F1_DOC)
			A410ProcDv( "SF1", SF1->( Recno() ), 4 )
			oBrowse:Refresh()
		Else
			Help( " ", 1, "ARQVAZIO" )
			lRet := .F.
		Endif
	Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} GtColDevol
    Retorna as colunas utilizadas no browse

    @sample		GtColDevol()
	@param		aFields  	, Array	, Array com nome dos campos
	@param		aStrtSF1  	, Array	, Array da estrutura da tabela SF1
    @return		aFields		, Array	, Colunas/Campos do Browse
    @author		Squad CRM
    @since		12/04/2019
    @version	P12
/*/
//------------------------------------------------------------------------------
Static Function GtColDevol( aFields, aStrtSF1, cIndice )

    Local aAreaSX3  := SX3->( GetArea() )
    Local aColumns  := {}
    Local nLinha    := 0
	Local nOrd		:= 0

	Local cDicCampo  := ""
	Local cDicArq    := ""
	Local cDicUsado  := ""
	Local cDicTitulo := ""
	Local cDicPictur := ""
	Local nDicTam    := ""
	Local nDicDec    := ""
	Local cDicTipo   := ""
	Local cDicContex := ""
	Local cDicCBox   := ""
	Local cDicBrowse := ""
	
    Default aFields := {}
	aStrtSF1 := SF1->( DBStruct())

	M410DicIni("SF1")
	cDicCampo := M410RetCmp()
	cDicArq   := cValToChar(GetSX3Cache(cDicCampo, "X3_ARQUIVO"))

	While !M410DicEOF() .And. cDicArq == "SF1"

		cDicUsado   := GetSX3Cache(cDicCampo, "X3_USADO")
		cDicBrowse  := GetSX3Cache(cDicCampo, "X3_BROWSE")
		cDicContex  := GetSX3Cache(cDicCampo, "X3_CONTEXT")
		cDicTipo    := GetSX3Cache(cDicCampo, "X3_TIPO")

		If ((X3Uso( cDicUsado ) .And. cDicBrowse == "S" .And. cDicContex <> "V" .And. cDicTipo <> "M") .OR. (cDicCampo $ cIndice)) // Campos do índice devem ser atualizados paras que o filtro funcione.
            
			cDicCBox    := Posicione("SX3", 2, cDicCampo, "X3CBox()")
			cDicTitulo  := M410DicTit(cDicCampo)
			cDicPictur  := X3Picture(cDicCampo)
			nDicTam     := GetSX3Cache(cDicCampo, "X3_TAMANHO")
			nDicDec     := GetSX3Cache(cDicCampo, "X3_DECIMAL")

			aAdd( aColumns, FWBrwColumn():New() )
			nLinha := Len( aColumns )
			nOrd := Ascan(aStrtSF1,{|x| AllTrim(X[1]) == AllTrim(cDicCampo)})
			
			aAdd( aFields,{cDicCampo,nOrd})
            
			If Empty( cDicCBox )
				aColumns[ nLinha ]:SetData( &("{ || " + cDicCampo + " }" ))
			Else
				aColumns[ nLinha ]:SetData( &("{|| X3Combo('" + cDicCampo + "'," + cDicCampo +")}" ) )
			EndIf

			aColumns[ nLinha ]:SetTitle(cDicTitulo)
            aColumns[ nLinha ]:SetType(cDicTipo)
			aColumns[ nLinha ]:SetPicture(cDicPictur)
            aColumns[ nLinha ]:SetSize(nDicTam)
            aColumns[ nLinha ]:SetDecimal(nDicDec)
            
        EndIf

		M410PrxDic()
		cDicCampo := M410RetCmp()
		cDicArq   := cValToChar(GetSX3Cache(cDicCampo, "X3_ARQUIVO"))

    EndDo
	aSort(aFields,,,{ |x,y| x[2]<y[2]})
    RestArea( aAreaSX3 )
    aSize( aAreaSX3,0 )

Return aColumns

//------------------------------------------------------------------------------
/*/{Protheus.doc} GtIndDevol
    Retorna todos os indices utilizado na SF1

    @sample	    GtIndDevol( cAlias, aSeek )    
    @param		aSeek    , Array    , Array utilizando no campo de Pesquisa do Browse
    @return		aIndex   , Array    , Array contendo todos os indices
    @author		Squad CRM
    @since		16/04/2019
    @version	P12
/*/
//------------------------------------------------------------------------------
Static Function GtIndDevol( aSeek, cIndice )

    Local aIndex    := {}
    Local aIndexTmp := {}
    Local aSeekTmp  := {}
    Local cIndex    := ""
    Local nX        := 1
    Local nY        := 0
    Local nAt       := 0
    Local nRat      := 0
	Local nIndex	:= 1
    
    Default aSeek   := {}    

	cIndex := SF1->( IndexKey( nX ) )

	While !Empty( cIndex )

		aIndexTmp := Separa( cIndex , "+" )
		For nY := 1 To Len( aIndexTmp )
			If "DTOS" $ aIndexTmp[ nY ] .Or. "STR" $ aIndexTmp[ nY ]
				If "STR" $ aIndexTmp[ nY ]
					nRat := At("," , aIndexTmp[ nY ] ) -1
					If nRat > 0
						nAt :=  Len(aIndexTmp[ nY ] )
						aIndexTmp[nY] := Substring( aIndexTmp[ nY ] , 1 ,nRat )+")"
					EndIf
				EndIf
				nRat := Rat("(" , aIndexTmp[ nY ] ) + 1
				nAt :=  At(")"  , aIndexTmp[ nY ] ) - nRat
				aIndexTmp[nY] := Substring( aIndexTmp[ nY ] , nRat ,nAt )
			Endif
		Next nY
		If nX > 1
			nIndex := nX
		EndIf
		aSeekTmp := GetSeek( aIndexTmp, nIndex )
		If Len( aSeekTmp ) > 0
			aAdd( aSeek , aSeekTmp )
		Endif
		
		aAdd( aIndex , { nIndex , aIndexTmp } )
		nX++
		cIndex := SF1->( IndexKey( nX ) )
		cIndice += cIndex
	Enddo

Return aIndex

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetSeek
    Retorna todos os indices de Pesquisa

    @sample	    GetSeek(aIndex)
    @param		aIndex   , Array    , Array de campos do indice
    @return		aSeek    , Array    , Array utilizando no campo de Pesquisa do Browse
    @author		Squad CRM
    @since		16/04/2019
    @version	P12
/*/
//------------------------------------------------------------------------------
Static Function GetSeek( aIndex, nIndex )
	
    Local aSeek     := {}
	Local cCampo	:= ""
    Local cTitulo   := ""
    Local cTipo	    := ""
    Local cMask		:= ""
    Local cIndice	:= ""
	Local nDecimal  := 0
    Local nI        := 0
    Local nTamanho  := 0	
    Local lShowPesq := .T.	
	Local aFields	:= {}

	//cIndice:= SF1->( IndexKey( nIndex ) )
    For nI := 1 To Len( aIndex )
        cCampo := FWX3Titulo( aIndex[nI] ) //Titulo

        If !Empty( cCampo )
    		cTitulo  := Alltrim( cCampo )
			cTipo	 :=  GetSX3Cache(aIndex[nI],"X3_TIPO")
            nTamanho := TamSx3(aIndex[nI])[1]
            nDecimal := TamSx3(aIndex[nI])[2]
			cMask 	 := X3Picture(aIndex[nI])
			If nI <> Len(aIndex)
				cIndice  += cTitulo + "+"
			Else
				cIndice  += cTitulo
			EndIf		
			aAdd(aFields,{ "", cTipo, nTamanho, nDecimal, cTitulo,cMask,aIndex[nI]})
        Endif
		
    Next nI
	If !Empty( cIndice )
		aSeek := { cIndice, aFields, nIndex, lShowPesq }
	Endif  

Return aSeek

//------------------------------------------------------------------------------
/*/{Protheus.doc} GtQryDevol
    Retorna as colunas utilizadas no browse

    @sample	    GtQryDevol(cAlias,aColumns)
    @param		aFields	, Array     	, Colunas utilizadas no Select    
    @return		cQuery  , Caractere  	, Retorna Query

    @author		Squad CRM
    @since		12/04/2019
    @version	1.0
/*/
//------------------------------------------------------------------------------
Static Function GtQryDevol( aFields , dDataDe, dDataAte, lForn, lFornece )

    Local cQuery    := " SELECT '  ' MARK, "
    Local nI        := 0
   
    Default aFields := {}    

    If Len( aFields ) > 0

        For nI := 1 To Len( aFields )
            cQuery += aFields[ nI,1 ] + ", "
        Next nI

        cQuery := Substr( cQuery, 1, Len( cQuery )-2 )

    Else
        cQuery += " * "
    Endif

    cQuery += " FROM " + RetSqlName( "SF1" ) 
    cQuery += " WHERE " + A410DevFlt( dDataDe, dDataAte, lForn, lFornece )
    cQuery += " ORDER BY " + SqlOrder( SF1->( IndexKey(1) ) )

    If Existblock("A410RNF")
		cQuery := ExecBlock("A410RNF",.F.,.F.,{ dDataDe, dDataAte, lForn, lFornece })				
	EndIf

    cQuery := ChangeQuery( cQuery )	

Return cQuery

//------------------------------------------------------------------------------
/*/{Protheus.doc} A410SelAll
    Marca/Desmarca todos registros do browse

    @sample	    A410SelAll(cAlias,cMarca)
    @param		Alias   , Caractere  , Alias temporario
    @param		cMarca  , Caractere  , Marca utilizada no Browse
    @return		Nulo

    @author		Squad CRM
    @since		16/04/2019
    @version	1.0
/*/
//------------------------------------------------------------------------------
Static Function A410SelAll( cAlias, cMarca )

    Local aAreaTmp	:= ( cAlias )->( GetArea() )	
    
    ( cAlias )->( DbGoTop() )

    While ( cAlias )->( !Eof() )
		//Verifica se registro pode ser marcado
        If !A410SelIt( cAlias, cMarca )
			Exit
		Endif
        
        ( cAlias )->( DbSkip() )

    Enddo

    RestArea( aAreaTmp )
    aSize( aAreaTmp, 0 )

Return Nil

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informações enviadas, 
    quando a regra de auditoria de rotinas com campos sensíveis ou pessoais estiver habilitada
	Remover essa função quando não houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que será utilizada no log das tabelas
    @param nOpc, Numerico, Opção atribuída a função em execução - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria não esteja aplicada, também retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} M410DicIni()
Funcao para inicializar as variaveis de controle para consulta a
dados do SX3 via API's

@param		cArqCpos	, Char    , Alias a ser utilizado na consulta SX3 dos campos
@author 	Squad CRM & Faturamento
@since 		03/06/2020
@version 	12.1.27
@return 	Nulo
/*/
//-----------------------------------------------------------------------------------
Static Function M410DicIni(cArqCpos)

	Static nNumCpo    := 0  
	Static aCamposDic := {}
	Static cAliasDic  := ""  
	Static lFWSX3Util := Nil
	Static nQtdCampos := 0

	Local aCmpsAux1 := {}
	Local aCmpsAux2 := {}
	Local nCampo    := ""

	Default cArqCpos := ""

	// Inicializar variaveis
	aSize(aCamposDic, 0)
	nNumCpo    := 1
	cAliasDic  := cArqCpos

	// Realizar as verificacoes de que os componentes para tratar os Debitos 
	// tecnicos estao no ambiente do cliente
	If lFWSX3Util == Nil
		M410VrfSQ()
	EndIf

	// Iniciar ou posicionar nas estruturas de dados para buscar o campo do
	// alias do cArqSX3 para utilizacao pelas demais funcoes associadas a esta
	If lFWSX3Util
		aCmpsAux1 := FWSX3Util():GetAllFields(cAliasDic)
		nQtdCampos := Len(aCmpsAux1)

		// Ordenar pelo campo X3_ORDEM
		For nCampo = 1 To nQtdCampos
			aAdd(aCmpsAux2, {aCmpsAux1[nCampo], GetSX3Cache(aCmpsAux1[nCampo], "X3_ORDEM")})
		Next nCampo
		aSort(aCmpsAux2, , , {|campo1, campo2| campo1[2] < campo2[2]})
		For nCampo = 1 To nQtdCampos
			aAdd(aCamposDic, aCmpsAux2[nCampo][1])
		Next nCampo
		FreeObj(aCmpsAux1)
		FreeObj(aCmpsAux2)
	Else
		DbSelectArea("SX3")
		SX3->(dbSetOrder(1))
		SX3->(MsSeek(cAliasDic))
	Endif

Return Nil

//-------------------------------------------------------------------------------
/*/{Protheus.doc} M410VrfSQ()
Funcao para verificar se os componentes indicados pelo Framework para realizar
a leitura dos dicionários SX3 estao no ambiente.

@param		Não há.
@author 	Squad CRM & Faturamento
@since 		03/06/2020
@version 	12.1.27
@return 	Null
/*/
//-------------------------------------------------------------------------------
Static Function M410VrfSQ()
	Local cVersaoLib := ""
	
	cVersaoLib := FWLibVersion()

	If cVersaoLib > "20180823"
		lFWSX3Util := .T.
	Else
		lFWSX3Util := .F.
	EndIf

Return Nil

//-------------------------------------------------------------------------------
/*/{Protheus.doc} M410PrxDic()
Funcao para posicionar na proxima linha do SX3 para ler os seus respectivos dados

@param		Nao há
@author 	Squad CRM & Faturamento
@since 		03/06/2020
@version 	12.1.27
@return 	Nulo
/*/
//-------------------------------------------------------------------------------
Static Function M410PrxDic()

	If lFWSX3Util
		nNumCpo++
	Else
		SX3->(DbSkip())
	EndIf
Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} M410RetCmp()
Funcao para retornar o campo da posicionada linha no SX3 

@param		Nao há
@author 	Squad CRM & Faturamento
@since 		03/06/2020
@version 	12.1.27
@return 	cCampo , Char , Campo da linha posicionada no SX3
/*/
//-------------------------------------------------------------------------------
Static Function M410RetCmp()
	Local cCampo  := ""
	Local nPosCpo := 0

	If lFWSX3Util
		If nNumCpo <= nQtdCampos
			cCampo := aCamposDic[nNumCpo]	
		EndIf
	Else
		nPosCpo := SX3->(ColumnPos("X3_CAMPO"))
		cCampo  := SX3->(FieldGet(nPosCpo))
	EndIf
Return cCampo

//-------------------------------------------------------------------------------
/*/{Protheus.doc} M410DicEOF()
Funcao para retornar se o SX3 esta no final de arquivo ou nao

@param		Nao há
@author 	Squad CRM & Faturamento
@since 		03/06/2020
@version 	12.1.27
@return 	lEhEOF , Boolean , Indica se esta no final do arquivo ou nao
/*/
//-------------------------------------------------------------------------------
Static Function M410DicEOF()

	Local lEhEOF := .F.

	If lFWSX3Util
		If nNumCpo > nQtdCampos
			lEhEOF := .T.
		EndIf
	Else
		lEhEOF := SX3->(EOF())
	EndIf

Return lEhEOF

//-------------------------------------------------------------------------------
/*/{Protheus.doc} M410DicTit()
Funcao para retornar o titulo do campo do SX3

@param		Nao há
@author 	Squad CRM & Faturamento
@since 		15/06/2020
@version 	12.1.27
@return 	cTitulo , Character , Titulo do campo no idioma do ambiente
/*/
//-------------------------------------------------------------------------------
Static Function M410DicTit(cCampo)

	Local cTitulo := ""

	If lFWSX3Util
		cTitulo := FWX3Titulo(cCampo)
	Else
		cTitulo := X3Titulo()
	EndIf

Return cTitulo
