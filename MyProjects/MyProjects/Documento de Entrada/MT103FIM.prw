#include "Protheus.ch"
#include "Rwmake.ch"


User Function MT103FIM()
Local nOpcao 	:= PARAMIXB[1]   // Opção Escolhida pelo usuario no aRotina
Local nConfirma := PARAMIXB[2]   // Se o usuario confirmou a operação de gravação da NFECODIGO DE APLICAÇÃO DO USUARIO
Local aArea		:= GetArea()
Local cFilial 	:= SD1->D1_FILIAL
Local cEntrada	:= DTOS(SD1->D1_EMISSAO)
Local nNFiscal	:= SD1->D1_DOC
Local cSerie	:= SD1->D1_SERIE
Local cFornece	:= SD1->D1_FORNECE
Local cLoja		:= SD1->D1_LOJA
Local cTES		:= SD1->D1_TES
Local nValCont	:= 0
Local cKeySD1	:= cFilial+nNFiscal+cSerie+cFornece+cLoja                                                         
Local cPerICMS	:= SD1->D1_PICM       
Local nPerRed 	:= Posicione("SF4", 1, xFilial("SF4")+cTES,"F4_PICMDIF")   

If nOpcao == 3 .AND. cTES $ "134"
	
	//Posiciona no 1o item da Nota Fiscal
	DbSelectArea("SD1")
	SD1->(DbSetOrder(1))
	SD1->(DbSeek(cKeySD1))
	
	//SFT - Posiciona no Livro Fiscal atualizar valores contabeis de acordo com regime especial	
	While SD1->(!Eof()) .And. SD1->(xFilial("SD1")+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == cKeySD1
	
		//Atualiza dados SD1
		RecLock("SD1",.F.)
        SD1->D1_XBSREGE		:= SD1->D1_BASEICM //Base ICMS
        SD1->D1_XVREGES 	:= Round(((SD1->D1_BASEICM * cPerICMS)/100),2)	//Valor do ICMS 18%
        SD1->D1_XVDIFRE		:= Round(((SD1->D1_XVREGES * nPerRed)/100),2)			//Valor do ICMS 18% MENOS os 35% do reg. especial	
		SD1->(MsUnLock())   

		//Atualiza dados CD2   
		DbSelectArea("CD2")
		CD2->(DbSetOrder(2))//CD2_FILIAL+CD2_TPMOV+CD2_SERIE+CD2_DOC+CD2_CODFOR+CD2_LOJFOR+CD2_ITEM+CD2_CODPRO+CD2_IMP
		If CD2->(DbSeek(xFilial("CD2")+"E"+SD1->(D1_SERIE+D1_DOC+D1_FORNECE+D1_LOJA+D1_ITEM+D1_COD+"ICM")))
			RecLock("CD2",.F.)
	        CD2->CD2_DESONE		:= Round(((SD1->D1_XVREGES * nPerRed)/100),2)			//Valor do ICMS 18% MENOS os 35% do reg. especial	
			CD2->(MsUnLock())   
		EndIf
		
		//Atualiza dados SFT
		DbSelectArea("SFT")
		SFT->(DbSetOrder(1))//FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
		If SFT->(DbSeek(xFilial("SFT")+"E"+SD1->(D1_SERIE+D1_DOC+D1_FORNECE+D1_LOJA+D1_ITEM)))
			RecLock("SFT",.F.)
            nICMS18 		:= Round(((SD1->D1_BASEICM * cPerICMS)/100),2)	//Valor do ICMS 18%
            nICMSRed		:= Round(((nICMS18 * nPerRed)/100),2)			//Valor do ICMS 18% MENOS os 35% do reg. especial	
            SFT->FT_VALCONT	:= Round((SD1->D1_BASEICM - nICMSRed),2)    	//Valor contabil
			nValCont 		+= Round((SD1->D1_BASEICM - nICMSRed),2)
			SFT->(MsUnLock())   
		EndIf
		SD1->(DbSkip())

	Enddo
	
	//SF3 - Posiciona no Livro Fiscal atualizar valores contabeis de acordo com regime especial
	DbSelectArea("SF3")
	SF3->(DbSetOrder(1))//F3_FILIAL+DTOS(F3_ENTRADA)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA+F3_CFO+STR(F3_ALIQICM, 5, 2)
	If SF3->( DbSeek(xFilial("SF3")+cEntrada+nNFiscal+cSerie+cFornece+cLoja) )
		RecLock("SF3",.F.)
		SF3->F3_VALCONT:= nValCont
		SF3->(MsUnLock())
	EndIf
	ApMsgInfo("Olá, devido esta ser uma nota de importação os valores contábeis dos livros foram ajustados para respeitar o regime especial da empresa. Valor Atual: "+cValToChar(nValCont),"Team Tex - Reg. Especial")
	
EndIf
RestArea(aArea)
Return (NIL)
