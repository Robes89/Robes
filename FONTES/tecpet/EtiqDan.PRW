#include "totvs.ch"
#include "topconn.ch"

/*
Autor : Guilherme Ricci - TOTVS IP - 22/02/2017
Descrição: Programa responsável pela impressão das etiquetas de produto. Será utilizado em pontos de entrada.
*/

User Function EtiqDan()

	Local aProd		:= {}
	Local cQuery	:= ""
	Local aRet		:= {}
	
	aRet := ValidPerg()
	
	If !Empty(aRet)
		
		cQuery := " SELECT D1_COD, " + CRLF
		cQuery += " CASE WHEN B5_UMIND = '2' THEN D1_QTSEGUM " + CRLF
		cQuery += " 	 ELSE D1_QUANT END D1_QUANT, " + CRLF
		cQuery += " D1_LOTECTL, D1_DTVALID " + CRLF
		cQuery += " FROM " + RetSqlName("SD1") + " D1" + CRLF
		cQuery += " INNER JOIN " + RetSqlName("SB1") + " B1 ON B1_COD = D1_COD AND B1_FILIAL = '"+ xFilial("SB1")+"' AND B1.D_E_L_E_T_=' '" + CRLF
		cQuery += " INNER JOIN " + RetSqlName("SB5") + " B5 ON B5_COD = D1_COD AND B5_FILIAL = '"+ xFilial("SB5")+"' AND B5.D_E_L_E_T_=' '" + CRLF
		cQuery += " WHERE D1.D_E_L_E_T_=' '" + CRLF
		cQuery += " AND D1_FILIAL = '" + xFilial("SD1") + "'" + CRLF
		cQuery += " AND D1_DOC = '" + SF1->F1_DOC + "'" + CRLF
		cQuery += " AND D1_SERIE = '" + SF1->F1_SERIE + "'" + CRLF
		cQuery += " AND D1_FORNECE = '" + SF1->F1_FORNECE + "'" + CRLF
		cQuery += " AND D1_LOJA = '" + SF1->F1_LOJA + "'" + CRLF
		cQuery += " AND D1_ITEM >= '" + aRet[1] + "'" + CRLF
		cQuery += " AND D1_ITEM <= '" + aRet[2] + "'" + CRLF
		
		If Select("QETIQ") > 0
			QETIQ->(dbCloseArea())
		Endif
		
		tcQuery cQuery New Alias "QETIQ"
		
		If QETIQ->(!eof())
			
			While QETIQ->(!eof())
				aAdd( aProd, {QETIQ->D1_COD, Iif( Substr(aRet[3],1,1) == "1", 1, QETIQ->D1_QUANT ), QETIQ->D1_LOTECTL, QETIQ->D1_DTVALID} )
				QETIQ->(dbSkip())
			EndDo
			
			If !Empty(aProd)
				Imprime(aProd)	
			Endif
			
		Else
			MsgAlert("Não há itens a serem impressos com os parâmetros informados.", "Aviso")
		Endif
		
		QETIQ->(dbCloseArea())
				
	Endif

Return

Static Function ValidPerg( lNF )

	Local aRet 		:= {}
	Local aParamBox	:= {}
	//Local aPorta	:= {"1 - LPT1","2 - LPT2","3 - LPT3","4 - LPT4"}
	Local aQtd		:= {"1 - Unica", "2 - Qtd do Item"}
	 		 		
    aAdd(aParamBox,{1, "Item de"								, CriaVar("D1_ITEM",.F.), "@!", ".T.", /*F3*/ , ".T.", 50, .F.}) // MV_PAR01
    aAdd(aParamBox,{1, "Item ate"								, "ZZZZ", "@!", ".T.", /*F3*/ , ".T.", 50, .F.}) // MV_PAR02
    aAdd(aParamBox,{2, "Qtd. de Etiq"							, aQtd[2]	,aQtd	,50	,""	,.T.})		// MV_PAR03
    
    If Len(aParambox) > 0
		ParamBox(aParamBox,"Configurações",@aRet,,,,,,,"ImpEtiPr",.T.,.T.)
	Endif
		                                                              
Return aRet


Static Function Imprime( aProd )
	
	Local nX := 0
	Local nY := 0
	Local cDesc := ""
	Local lDisableSetup := .F.
	Local lEsquerda	:= .F.
	Local nDireita := 100
	Local cNorma := ""  
	Local nQtdTot	:= 0
	Local nQtdEti 	:= 0
	Local nQuant	:= 0
	Local nQtdNorm	:= 0
	
	Local nLargPaper 	:= 0
	Local nLin			:= 0
	Local nPulaLin		:= 0
	
	Private oPrinter
	
	Private oFont04 		:= TFont():New("Arial", 04, 04,, .F.,,,,, .F., .F.)
	Private oFont04N 		:= TFont():New("Arial", 04, 04,, .T.,,,,, .F., .F.)
	Private oFont05 		:= TFont():New("Arial", 05, 05,, .F.,,,,, .F., .F.)
	Private oFont05N 		:= TFont():New("Arial", 05, 05,, .T.,,,,, .F., .F.)
	Private oFont08 		:= TFont():New("Arial", 08, 08,, .F.,,,,, .F., .F.)
	Private oFont08N 		:= TFont():New("Arial", 08, 08,, .T.,,,,, .F., .F.)
	Private oFont09 		:= TFont():New("Arial", 09, 09,, .F.,,,,, .F., .F.)
	Private oFont09N 		:= TFont():New("Arial", 09, 09,, .T.,,,,, .F., .F.)
	Private oFont10 		:= TFont():New("Arial", 10, 10,, .F.,,,,, .F., .F.)	
	Private oFont10N 		:= TFont():New("Arial", 10, 10,, .T.,,,,, .F., .F.)
	Private oFont11 		:= TFont():New("Arial", 11, 11,, .F.,,,,, .F., .F.)
	Private oFont11N 		:= TFont():New("Arial", 11, 11,, .T.,,,,, .F., .F.)
	Private oFont12 		:= TFont():New("Arial", 12, 12,, .F.,,,,, .F., .F.)
	Private oFont12N 		:= TFont():New("Arial", 12, 12,, .T.,,,,, .F., .F.)
	Private oFont14 		:= TFont():New("Arial", 14, 14,, .F.,,,,, .F., .F.)
	Private oFont14N 		:= TFont():New("Arial", 14, 14,, .T.,,,,, .F., .F.)
	Private oFont16 		:= TFont():New("Arial", 16, 16,, .F.,,,,, .F., .F.)
	Private oFont16N 		:= TFont():New("Arial", 16, 16,, .T.,,,,, .F., .F.)
	Private oFont16NI 		:= TFont():New("Arial", 16, 16,, .T.,,,,, .F., .T.)
	Private oFont18 		:= TFont():New("Arial", 18, 18,, .F.,,,,, .F., .F.)
	Private oFont18N 		:= TFont():New("Arial", 18, 18,, .T.,,,,, .F., .F.)
	Private oFont20 		:= TFont():New("Arial", 20, 20,, .F.,,,,, .F., .F.)
	Private oFont22N 		:= TFont():New("Arial", 22, 22,, .T.,,,,, .F., .F.)
	Private oFont26 		:= TFont():New("Arial", 26, 26,, .F.,,,,, .F., .F.)
	Private oFont26N 		:= TFont():New("Arial", 26, 26,, .T.,,,,, .F., .F.)
	Private oFont32 		:= TFont():New("Arial", 32, 32,, .F.,,,,, .F., .F.) //  Define a fonte		
	Private oFont32N 		:= TFont():New("Arial", 32, 32,, .T.,,,,, .F., .F.) //  Define a fonte		
	Private oFont48N 		:= TFont():New("Arial", 48, 48,, .T.,,,,, .F., .F.) //  Define a fonte
	
	oPrinter := FWMSPrinter():New("Etiqueta Danone",,.F.,,lDisableSetup,,,)
//	oPrinter:SetMargin( 5, 5, 5, 5 )
	oPrinter:SetLandscape()
	oPrinter:SetPaperSize(9) // A4
	
	nLargPaper := 920
	
	For nX := 1 To Len(aProd)
	
		cDesc := Alltrim(Posicione("SB1", 1, xFilial("SB1") + aProd[nX,1], "B1_DESC"))
		nQtdTot := aProd[nX,2]
		
		DC3->(dbSetOrder(1))
		If DC3->(dbSeek(xFilial("DC3")+SB1->B1_COD))
			cNorma 		:= cValtoChar(Posicione("DC2",1,xFilial("DC2")+DC3->DC3_CODNOR,"DC2_LASTRO")) + " X " + cValToChar(DC2->DC2_CAMADA)
			nQtdNorm 	:= DC2->(DC2_LASTRO * DC2_CAMADA)
			If nQtdNorm > 0
				If nQtdTot / nQtdNorm <> Ceiling( nQtdTot / nQtdNorm )
					If !MsgYesNo(	"Atenção: A última etiqueta do produto " + Alltrim(SB1->B1_COD) + " - " + cDesc + ;
									" será gerada com quantidade diferente da quantidade da norma (" + cValToChar(nQtdNorm) + "). Deseja continuar?")
						Return
					Endif
				Endif
				nQtdEti := Ceiling( nQtdTot / nQtdNorm ) // Arredonda para cima
			Endif
		Endif
		
		If Empty(nQtdEti)
			MsgAlert("O produto " + AllTrim( SB1->B1_COD ) + " - " + cDesc + " não possui sequência de abastecimento cadastrada. Favor verificar.")
		Else
			For nY := 1 To nQtdEti
			
				lEsquerda 	:= !lEsquerda
				nLin		:= 340
				nPulaLin	:= 20
				nQuant		:= Min( nQtdNorm, nQtdTot )
				nQtdTot		-= nQuant
				
				If lEsquerda
					nDireita := 0
					oPrinter:Startpage()
				Else
					nDireita := nLargPaper/2-20
					oPrinter:Line( 50, nLargPaper/2-20, 550, nLargPaper/2-20 )
				Endif
				
				cCodBar := Alltrim(aProd[nX,1]) + "@" + Alltrim(aProd[nX,3]) + "@" + cValToChar(nQuant)
				
				//oPrinter:Box( 50, 50+nDireita, 300, 100+nDireita, "-10" 
				
				oPrinter:Box( 100, 50+nDireita, 500, 380+nDireita )
				
				oPrinter:Say( nLin, 90+nDireita, "Produto: " + aProd[nX,1] , oFont20 )	
				nLin += nPulaLin
		 		oPrinter:Say( nLin, 90+nDireita, Substr(cDesc, 1, 30), oFont20 )
		 		nLin += nPulaLin
				oPrinter:Say( nLin, 90+nDireita, Substr(cDesc, 31, 30), oFont20 )
				nLin += nPulaLin
				oPrinter:Say( nLin, 90+nDireita, Substr(cDesc, 61, 30), oFont20 )
				nLin += nPulaLin
				
				If !Empty(aProd[nX,3])
					oPrinter:Say( nLin, 90+nDireita, "Lote: " + aProd[nX,3] , oFont20 )	
					nLin += nPulaLin
					oPrinter:Say( nLin, 90+nDireita, "Validade: " + DtoC(StoD(aProd[nX,4])) , oFont20 )	
					nLin += nPulaLin
				Endif
				
				If nQuant == nQtdNorm
					oPrinter:Say( nLin, 90+nDireita, "Norma: " + cNorma , oFont20 )
				Else
					oPrinter:Say( nLin, 90+nDireita, "Quantidade: " + cValToChar(nQuant) , oFont20 )
				Endif
				
				oPrinter:SayBitmap( 110, 55+nDireita, "\system\lgrl01.bmp", 100, 70 )
				oPrinter:SayBitmap( 110, 260+nDireita, "\system\logodanone.bmp", 110, 65 )
				
				If lEsquerda
					oPrinter:FWMSBAR("CODE128" , 18,  8, cCodBar ,oPrinter, /*lCheck*/,/*Color*/,/*lHorz*/, /*nWidth*/, /*nHeigth*/,/*lBanner*/,/*cFont*/,/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,/*lCmtr2Pix*/)
				Else
					oPrinter:FWMSBAR("CODE128" , 18,  43, cCodBar ,oPrinter, /*lCheck*/,/*Color*/,/*lHorz*/, /*nWidth*/, /*nHeigth*/,/*lBanner*/,/*cFont*/,/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,/*lCmtr2Pix*/)
				Endif
												
				If !lEsquerda
			 		oPrinter:Endpage()
				Endif
			Next nY
		Endif
	Next nX
	
	If lEsquerda
		oPrinter:Endpage()
	Endif
	                                                           
	oPrinter:Preview()
	Ms_Flush()

Return