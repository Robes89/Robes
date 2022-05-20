#include "rwmake.ch"
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#EndIf

// Emissão de Notas Fiscais da LMT
// Wilson J. Santos
// Dez/2003

User Function NFLMT2()

If  SM0->M0_CODIGO != "98" .and. SM0->M0_CODIGO != "01"
	MsgBox( "Esta rotina é específica para emissão de Notas Fiscais da LMT !" )
	Return(.F.)
EndIf

SetPrvt("TITULO,CDESC1")
SetPrvt("CDESC2,CDESC3,CNATUREZA,ARETURN,CPERG")
SetPrvt("NLASTKEY,LCONTINUA,NLIN,WNREL,CSTRING")
SetPrvt("CNOME,CCOD,CLOJA,CCGC,CEND")
SetPrvt("CBAI,CCEP,CMUN,CTEL,CEST,CINS")
SetPrvt("cCDZFSA1,CEND_C,CBAI_C,CMUN_C,CEST_C,CCEP_C")
SetPrvt("AOBS,NXX,CMENSAGEM,NCONTA")
SetPrvt("NLINHAOBS,ADUP,NDUP,ACFO")
SetPrvt("AITENS,ASERVICOS,CFORMULA")
SetPrvt("CHP,CTEXTO,NPOS")
SetPrvt("NLIANT,ANFORI,CMENPAD")
SetPrvt("_SALIAS,AREGS,I,J,")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01             // Da Nota Fiscal                       ³
//³ mv_par02             // Ate a Nota Fiscal                    ³
//³ mv_par03             // Da Serie                             ³
//³ mv_par04             // Nota Fiscal de Entrada/Saida         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

titulo   := "Emissão de Notas Fiscais"
cDesc1   := PadC( "O objetivo desta rotina é a emissão de Notas Fiscais de Entradas/Saídas" , 90 )
cDesc2   := ""
cDesc3   := PadC( AllTrim( SM0->M0_NOMECOM ) , 90 )
cNatureza:= ""
aReturn  := { "Especial", 1,"Administração", 1, 2, 1,"",1 }
cPerg    := PadR( "NFISCA" , Len( SX1->X1_GRUPO ) )
nLastKey := 0
lContinua:= .T.
nLin     := 3
wnrel    := "NFISCAL"
lReal    := .T.

ValidPerg()

dbSelectArea("SX1")
//dbSeek("NFISCA01")
DbSeek( cPerg + "01" )
RecLock("SX1",.F.)
X1_CNT01 := StrZero(Val(GetMV( "MV_ULNFIMP" ))+1,6)
msUnlock()

Pergunte(cPerg,.F.)

cString	:= "SF2"

wnrel	:= SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.)

If nLastKey == 27	;	Return	;	EndIf
SetDefault(aReturn,cString)

If nLastKey == 27	;	Return	;	EndIf

RptStatus({|| EmiteNF()} , "Emissão de Notas Fiscais" )// Substituido pelo assistente de conversao do AP5 IDE em 11/11/02 ==>    RptStatus({|| Execute(RptDetail)} , "Emissao de Notas Fiscais" )
Return                                                              

****************************************************************************************
Static Function EmiteNF()
Private nPLiqui := 0
Private nPBruto := 0

@ 0,0 PSAY Chr(27)+"@"+CHR(15)+CHR(27)+"0"

lMostra	:= .T.

If mv_par04 == 2

	SA1->( DbSetOrder( 1 ) )
	SA2->( DbSetOrder( 1 ) )
	SA4->( DbSetOrder( 1 ) )
	SB1->( DbSetOrder( 1 ) )
	SC5->( DbSetOrder( 1 ) )
	SC6->( DbSetOrder( 1 ) )
	SE1->( DbSetOrder( 2 ) )
	SF4->( DbSetOrder( 1 ) )
	SD2->( DbSetOrder( 3 ) )

	DbSelectArea( "SF2" )
	SF2->( DbSetOrder( 1 ) )
	SF2->( DbSeek( xFilial() + mv_par01 + mv_par03 , .t. ) )

	SetRegua( Val(mv_par02) - Val(mv_par01) )

	While !SF2->( Eof() ) .and.	SF2->F2_FILIAL == xFilial( "SF2" ) .and. ;
		SF2->F2_DOC <= mv_par02

		IncRegua()

		If SF2->F2_SERIE # mv_par03	;	SF2->( DbSkip() )	;	Loop	;	EndIf
		/*
		If	!Empty( GetMV( "MV_ULNFIMP" ) ) .and. ;
		SF2->F2_DOC > StrZero( ( Val( GetMV( "MV_ULNFIMP" ) ) + 1 ) , 6 )
		MsgBox( "A última Nota Fiscal impressa foi " + GetMV( "MV_ULNFIMP" ) +;
		" portanto não será permitido imprimir apartir no nº " + SF2->F2_DOC +;
		". Favor alterar a número inicial." , "ATENÇÃO" , "ALERT" )
		lMostra	:= .F.
		Exit
		EndIf

		If	!Empty( GetMV( "MV_ULNFIMP" ) ) .and. ;
		SF2->F2_NFIMP == "S" .and. SF2->F2_DOC <= GetMV( "MV_ULNFIMP" )
		If	!MsgBox( "Nota Fiscal " + SF2->F2_DOC + " já impressa. Tem certeza que "+;
		"deseja reimprimir ?" , "ATENÇÃO" , "YESNO" )
		lMostra	:= .F.
		Exit
		EndIf
		EndIf
		*/
		IF SF2->F2_NFIMP == "S"
			If	!MsgBox( "Nota Fiscal " + SF2->F2_DOC + " já impressa. Tem certeza que "+;
				"deseja reimprimir ?" , "ATENÇÃO" , "YESNO" )
				SF2->(dbSkip())
				Loop
			Endif
		Endif

		cEnde    := ""
		If SF2->F2_TIPO $ "BD"
			SA2->( DbSeek( xFilial( "SA2" ) + SF2->F2_CLIENTE + SF2->F2_LOJA ) )
			cNome    := SA2->A2_NOME
			cCod     := SA2->A2_COD
			cLoja    := SA2->A2_LOJA
			cCGC     := SA2->A2_CGC
			cEnd     := SA2->A2_END
			cBai     := Left( SA2->A2_BAIRRO , 25 )
			cCep     := SA2->A2_CEP
			cMun     := SA2->A2_MUN
			cTel     := SA2->A2_TEL
			cEst     := SA2->A2_EST
			cIns     := SA2->A2_INSCR
			cCDZFSA1 := ""
			cEnd_C   := ""
			cBai_C   := ""
			cMun_C   := ""
			cEst_C   := ""
			cCep_C   := ""
		Else
			SA1->( DbSeek( xFilial( "SA1" ) + SF2->F2_CLIENTE + SF2->F2_LOJA ) )
			cNome    := SA1->A1_NOME
			cCod     := SA1->A1_COD
			cLoja    := SA1->A1_LOJA
			cCGC     := SA1->A1_CGC
			cEnd     := SA1->A1_END
			cBai     := Left( SA1->A1_BAIRRO , 25 )
			cCep     := SA1->A1_CEP
			cMun     := SA1->A1_MUN
			cTel     := SA1->A1_TEL
			cEst     := SA1->A1_EST
			cIns     := SA1->A1_INSCR
			cCDZFSA1 := SA1->A1_SUFRAMA
			cEnd_C   := SA1->A1_ENDCOB
			cBai_C   := SA1->A1_BAIRROC
			cMun_C   := SA1->A1_MUNC
			cEst_C   := SA1->A1_ESTC
			cCep_C   := SA1->A1_CEPC
			If SA1->A1_ENDENT <> SA1->A1_END
				cEndE := "End. entrega: " + Trim(SA1->A1_ENDENT) + " - " + Trim(SA1->A1_BAIRROE) + " - " + Trim(SA1->A1_MUNE) + " - " + SA1->A1_ESTE + " - CEP:" + SA1->A1_CEPE
			Endif
		EndIf

		SA4->( DbSeek( xFilial( "SA4" ) + SF2->F2_TRANSP ) )
		
		nCof := SF2->F2_VALIMP5
		nPis := SF2->F2_VALIMP6

		aObs  := {}
		For nXX := 1 to 10
			aAdd( aObs , " " )
		Next

		SD2->( DbSeek( xFilial( "SD2" ) + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA ) )

		cMensagem	:= ""
		cFormula    := ""

		cTexto   	:= IF( SC5->( DbSeek( xFilial( "SC5" ) + SD2->D2_PEDIDO ) ) , AllTrim( SC5->C5_MENNOTA ) , "" )
		cMensagem   := AllTrim( cTexto ) + IF( !Empty( cTexto ) , " # " , "" )

		cTexto		:= Formula( SC5->C5_MENPAD )
		cMensagem   += AllTrim( cTexto ) + IF( !Empty( cTexto ) , " # " , "" )
		cFormula    += SC5->C5_MENPAD

		aDup	:= {}                      && Duplicatas
		For nXX := 1 to 8
			aAdd( aDup , { "" , "" , "" } )
		Next
		nDup  := 1

		SE1->( DbSeek( xFilial( "SE1" ) + SF2->F2_CLIENTE + SF2->F2_LOJA +;
		SF2->F2_SERIE + SF2->F2_DOC ) )
		While !SE1->( Eof() ) .and. SE1->E1_FILIAL == xFilial( "SE1" ) .and. ;
			SE1->E1_CLIENTE == SF2->F2_CLIENTE .and. SE1->E1_LOJA == SF2->F2_LOJA .and. ;
			SE1->E1_PREFIXO == SF2->F2_SERIE .and. SE1->E1_NUM == SF2->F2_DOC .and. ;
			nDup<=8
			If !"-" $ SE1->E1_TIPO
				aDup[ nDup , 01 ] := SE1->E1_PARCELA // SE1->E1_NUM +
				aDup[ nDup , 02 ] := SE1->E1_VENCTO
				aDup[ nDup , 03 ] := SE1->E1_VALOR - SE1->E1_IRRF - SE1->E1_CSLL - SE1->E1_COFINS - SE1->E1_PIS
				If SE1->E1_MOEDA <> 1
					lReal  := .F.
					ccampo := "M2_MOEDA" + StrZero(SE1->E1_MOEDA,1)
					dbSelectArea("SM2")
					dbSeek(SF2->F2_EMISSAO)
					aDup [nDup, 03 ] := SE1->E1_VLCRUZ // aDup [nDup, 03 ] * &ccampo
				Endif
				nDup  := nDup + 1
			EndIf
			SE1->( DbSkip() )
		EndDo

		nLetra		:= 64
		aClasfis	:= {}
		aCFO        := {}
		aItens      := {}
		aServicos   := {}
		cHP         := ""
		cPedCli     := ""
		coordx      := {0,0,0,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2}
		coordy		:= {4,24,44,64,84,104,4,24,44,64,84,104,4,24,44,64,84,104}
		lSuframa	:= .F.
		nVDZF		:= 0

		SD2->( DbSeek( xFilial( "SD2" ) + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA ) )
		
		nPLiqui := 0
		nPBruto := 0
		
		While !SD2->( Eof() ) .and.	SD2->D2_FILIAL == xFILIAL( "SD2" )  .and. ;
			SD2->D2_DOC    == SF2->F2_DOC       .and. ;
			SD2->D2_SERIE  == SF2->F2_SERIE     .and. ;
			SD2->D2_CLIENTE== SF2->F2_CLIENTE   .and. ;
			SD2->D2_LOJA   == SF2->F2_LOJA

			SB1->( DbSeek( xFILIAL( "SB1" ) + SD2->D2_COD ) )
			cCDZFSB1	:= SB1->B1_IMPZFRC
			SF4->( DbSeek( xFILIAL( "SF4" ) + SD2->D2_TES ) )
			
			nPLiqui += SB1->B1_PESO   * SD2->D2_QUANT
			nPBruto += (SB1->B1_PESO * 1.10) * SD2->D2_QUANT
			
			If aScan( aCFO , { |x| x[3] == SD2->D2_TES } ) == 0
				aAdd( aCFO , { SF4->F4_TEXTO , SD2->D2_CF , SD2->D2_TES } )
				ccFo := Substr(SD2->D2_CF,2,3)
			EndIf

			If !Empty(Trim(SF4->F4_MENSAGE) ) .and. !Trim(SF4->F4_MENSAGE) $ cFormula
				cFormula	:= cFormula + Trim(SF4->F4_MENSAGE)
				cTexto		:= AllTrim( Formula( SF4->F4_MENSAGE ) )
				cMensagem   += AllTrim( cTexto ) + IF( !Empty( cTexto ) , " # " , "" )
			EndIf

			If SF2->F2_TIPO $ "IP"
				If ! (SD2->D2_NFORI $ cMensagem)
					cTexto := SD2->D2_NFORI
					cMensagem   += AllTrim( cTexto ) + IF( !Empty( cTexto ) , " # " , "" )
				Endif
			Endif
			/*
				lPrim 	 := .T.
				_cString := ""
				oldOrdD2 := IndexOrd()
				oldRecD2 := Recno()
				dbSetOrder(3)
				aNotas 	 := {}
				If dbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE)
					do While !Eof() .and. D2_FILIAL == xFilial("SD2") .and. D2_DOC + D2_SERIE;
													== SF2->F2_DOC + SF2->F2_SERIE
						If !Empty(D2_NFORI)
							If lPrim
								If Ascan(aNotas,D2_NFORI) == 0
									_cString += D2_NFORI
									lPrim := .F.
									aadd(aNotas,D2_NFORI)
								Endif
							Else
								If Ascan(aNotas,D2_NFORI) == 0
									_cString += ", " + D2_NFORI
									aadd(aNotas,D2_NFORI)
								Endif
							Endif
						Endif
						dbSkip()
					Enddo
					dbSetOrder(oldOrdD2)
					dbGoto(oldRecD2)
				Endif
				cTexto := "NF Orig: " + _cString
				cMensagem   += AllTrim( cTexto ) + IF( !Empty( cTexto ) , " # " , "" )
			Endif
			*/

//			If !Empty( SF4->F4_FORMULA ) .and. !SF4->F4_FORMULA $ cFormula
//				cFormula	:= cFormula + SF4->F4_FORMULA
//				cTexto		:= AllTrim( Formula( SF4->F4_FORMULA ) )
//				cMensagem   += AllTrim( cTexto ) + IF( !Empty( cTexto ) , " # " , "" )
//			EndIf

			SC6->( DbSeek( xFILIAL( "SC6" ) + SD2->D2_PEDIDO + SD2->D2_ITEMPV + SD2->D2_COD ) )

			If SD2->D2_ALIQISS # 0

				If ( nPos	:= Ascan( aServicos , { |x| x[6] == SD2->D2_COD } ) ) == 0
					aAdd( aServicos , { SB1->B1_DENOM , SD2->D2_VALISS , SD2->D2_QUANT , SD2->D2_PRCVEN , SD2->D2_TOTAL , SD2->D2_COD , SC6->C6_PEDCLI } )
				Else
					aServicos[ nPos , 2 ]	+= SD2->D2_VALISS
					aServicos[ nPos , 3 ]	+= SD2->D2_QUANT
					aServicos[ nPos , 5 ]	+= SD2->D2_TOTAL
					aServicos[ nPos , 4 ]	:= aServicos[ nPos , 5 ] / aServicos[ nPos , 3 ]
				EndIf
			Else
				cLetra	:= ""
				If ( nPos	:= aScan( aClasFis , { |x| x[2] == SB1->B1_POSIPI } ) ) == 0
					nLetra++
					aAdd( aClasFis , { Chr( nLetra ) , SB1->B1_POSIPI , coordx[nletra-64], coordy[nletra-64] } )
					nPos	:= Len( aClasFis )
				EndIf
				cLetra	:= aClasFis[ nPos , 1 ]
				aArea_SF2	:= SF2->( GetArea() )
				// Cod.Inteligente (COD) + Denominacao (DESC) + Cod. Lmt + Cod. CLi + Req. Cli
				aAdd( aItens , {	Left(SD2->D2_COD,15),;
				Trim(SB1->B1_DESC) + " / " + Trim(SB1->B1_CODLMT) + IF(!Empty(SC6->C6_CODCLI)," / " + Trim(SC6->C6_CODCLI),"") +;
				IF(!Empty(SC6->C6_REQCLI)," / " + Trim(SC6->C6_REQCLI),"")+IF(!Empty(SC6->C6_PEDCLI)," / P.C: " + Trim(SC6->C6_PEDCLI),"")+;
				IF(!Empty(SC6->C6_NFORI)," / REF.N.NF "+AllTrim(SC6->C6_NFORI) + " DE " + DtoC(Posicione("SF2",1,xFilial("SF2")+SC6->(C6_NFORI+C6_SERIORI+C6_CLI+C6_LOJA),"F2_EMISSAO")),""),;
				cLetra ,;
				SD2->D2_CLASFIS , SD2->D2_UM , SD2->D2_QUANT ,;
				IF(SD2->D2_DESCZFR == 0, SD2->D2_PRCVEN,((SD2->D2_TOTAL + SD2->D2_DESCON + SD2->D2_DESCZFR) / SD2->D2_QUANT)) ,;
				IF(SD2->D2_DESCZFR == 0, SD2->D2_TOTAL ,(SD2->D2_TOTAL + SD2->D2_DESCON + SD2->D2_DESCZFR)) ,;
                SD2->D2_PICM , SD2->D2_IPI , SD2->D2_VALIPI, SC6->C6_PEDCLI } )
				If SD2->D2_DESCZFR # 0				//SD2->D2_CF == "6109 "
					lSuframa := .T.
					nSuframa := SD2->D2_PICM
					nVDZF		+= SD2->D2_DESCZFR
				Endif
				RestArea( aArea_SF2 )
			EndIf

			SD2->( DbSkip() )
		EndDo
		// Trata pedido do Cliente
		lTudoIg := .F.
		If !Empty(aItens)
			lTudoIg := .T.
			cPedCli := aItens[1,12]
			For kkk :=1 to Len(aItens)
				If Empty(aItens[kkk,12]) .or. aItens[kkk,12] == cPedCli
				Else
					lTudoIg := .F.
				Endif
			Next
		Endif

		If Empty( aItens ) .and. !Empty(aServicos)
			lTudoIg := .T.
			cPedCli := aServicos[1,7]
			For kkk :=1 to Len(aServicos)
				If Empty(aServicos[kkk,7]) .or. aServicos[kkk,7] == cPedCli
				Else
					lTudoIg := .F.
				Endif
			Next
		Endif

		// So para teste
		/*
		For nletra :=66 to 66+7
		aadd( aClasFis , { Chr( nLetra ) , SB1->B1_POSIPI , coordx[nletra-64], coordy[nletra-64] } )
		Next
		nletra :=66
		*/

		// Montagem dos dados adicionais

		nConta      := 1
		nLinhaObs   := 1

		If !empty(cEnde)
			For nXX := nLinhaObs to 10
				If Empty( AllTrim( SubStr( cEnde , nConta , 128) ) )
					Exit
				EndIf
				aObs[ nXX ] := AllTrim( SubStr( cEnde , nConta , 128) )
				nConta      := nConta + 128
				nLinhaObs   := nLinhaObs + 1
			Next nXX
		Endif

		nConta := 1
		For nXX := nLinhaObs to 10
			If Empty( AllTrim( SubStr( cMensagem , nConta , 128) ) )
				Exit
			EndIf
			aObs[ nXX ] := AllTrim( SubStr( cMensagem , nConta , 128) )
			nConta      := nConta + 128
			nLinhaObs   := nLinhaObs + 1
		Next nXX

		/* Coloca as letras da CF na mensagem
		cMensagem	:= ""
		nSeqCF		:= 1
		nQuebraCF	:= 1
		For nXX := nLinhaObs to 10
		For nCF := nSeqCF to Len( aClasFis )
		If nQuebraCF > 8	;	Exit	;	EndIf
		cMensagem	+= aClasFis[ nCF , 1 ] + "-" + aClasFis[ nCF , 2 ] + " "
		nQuebraCF++
		nSeqCF++
		Next nCF
		If !Empty( cMensagem )
		aObs[ nXX ] := AllTrim( cMensagem )
		nLinhaObs   := nLinhaObs + 1
		EndIf
		cMensagem	:= ""
		nQuebraCF		:= 1
		Next nXX
		*/

		nConta      := 1
		cMensagem	:= ""
		nImpostos	:= SF2->F2_VALIRRF + SF2->F2_VALCSLL + SF2->F2_VALCOFI + SF2->F2_VALPIS

		If SF2->F2_VALIRRF # 0
			cMensagem	+= "I.R.R.F"
		EndIf

		If SF2->F2_VALCSLL # 0
			cMensagem	+= IF( !Empty( cMensagem ) , "/" , "" ) + "C.S.L.L"
		EndIf

		If SF2->F2_VALCOFI # 0
			cMensagem	+= IF( !Empty( cMensagem ) , "/" , "" ) + "COFINS"
		EndIf

		If SF2->F2_VALPIS # 0
			cMensagem	+= IF( !Empty( cMensagem ) , "/" , "" ) + "PIS"
		EndIf

		If !Empty( cMensagem )
			cMensagem	+= ": " + AllTrim( TransForm( nImpostos , "@E 9,999,999.99" ) )
		EndIf
		
		//Imprime formula 48 se existir substituicao tributaria
		If(SF2->F2_ICMSRET > 0)
			cMensagem += " # " + Formula("040")
		EndIf
		
		lICMSRet := .T.
		
		If(SF2->F2_TIPO == "I" .And. SF2->F2_ICMSRET > 0)
			lICMSRet := .F.
			_aArea := GetArea()
			SD2->( DbSeek( xFilial( "SD2" ) + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA ) )
			_Rec := SF2->(RECNO())
			SF2->( DbSeek( xFilial( "SF2" ) + SD2->D2_NFORI + SD2->D2_SERIORI + SD2->D2_CLIENTE + SD2->D2_LOJA ) )
			cMensagem += " Conforme nota fiscal Nº " + SF2->F2_DOC + " de " + TransForm( SF2->F2_EMISSAO , "" ) + "."
			SF2->(DBGoTo(_Rec))
			RestArea(_aArea)
		EndIf
		
		For nXX := nLinhaObs to 10
			If Empty( AllTrim( SubStr( cMensagem , nConta , 128) ) )
				Exit
			EndIf
			aObs[ nXX ] := AllTrim( SubStr( cMensagem , nConta , 128) )
			nConta      := nConta + 128
			nLinhaObs   := nLinhaObs + 1
		Next nXX

		// Inicio da Impressao
		nComeco := 1
		Do While .T.
			lDuas   := .F.
			@ nLin , 186 PSAY TransForm( SF2->F2_DOC , "@R XXX.XXX" )
			nLin++
			@ nLin , 153 PSAY "X"
			nLin  := nLin + 5
			@ nLin , 002 PSAY ""
			For nXX := 1 to Len( aCFO )				// Descrição CFOP
				@ nLin , PCol() PSAY AllTrim( aCFO[ nXX , 1 ] ) + IF( nXX + 1 <= Len( aCFO ) , "/" , "" )
			Next nXX
			@ nLin , 099 PSAY ""
			For nXX := 1 to Len( aCFO )				// CFOP
				@ nLin , PCol() PSAY AllTrim( aCFO[ nXX , 2 ] ) + IF( nXX + 1 <= Len( aCFO ) , "/" , "" )
			Next nXX
			nLin  := nLin + 3
			@ nLin , 002 PSAY cNome + Space( 82 ) + "Codigo : " + cCod + IF( !Empty( cLoja ) , "/" + cLoja , "" )
			@ nLin , 150 PSAY cCGC Picture PesqPict( "SA1" , "A1_CGC" )
			@ nLin , 182 PSAY TransForm( SF2->F2_EMISSAO, "" )
			nLin  := nLin + 2
			@ nLin , 002 PSAY cEnd
			If !Empty(cBai)
				@ nLin , 127 PSAY AllTrim( cBai )
			Endif
			@ nLin , 163 PSAY cCep Picture PesqPict( "SA1" , "A1_CEP" )
			nLin  := nLin + 2
			@ nLin , 002 PSAY cMun
			@ nLin , 089 PSAY cTel
			@ nLin , 127 PSAY cEst
			@ nLin , 150 PSAY cIns
			nLin  := nLin + 3
			/*****************************************************************************************
			nCol	:= 00
			nCol	:= 04
			For nXX := 1 to Len( aDup )			// Vencimento
			If !Empty( aDup[ nXX , 01 ] )
			@ nLin , 002 PSAY aDup[ nXX, 01 ]
			@ nLin , nCol PSAY TransForm( aDup[ nXX , 02 ] , "" )
			@ nLin , nCol +14 PSAY TransForm( aDup[ nXX , 03 ] , "@E 99,999,999.99" )
			nLin++
			EndIf
			Next

			nValFat := (SF2->F2_VALFAT)
			nLin -= 1
			@ nLin, 074 psay SubStr(AllTrim(Extenso(nValFat)),001,55)
			nLin +=1
			@ nLin, 074 psay SubStr(AllTrim(Extenso(nValFat)),056,55)
			*****************************************************************************************/

			*------------ Novo bloco - 25/08/04
			cExtVal	:= Extenso( SF2->F2_VALBRUT )

			If !Empty( aDup[ 1 , 2 ] )				// Se existir 1o. vencimento
				@ nLin , 002 PSAY aDup[ 1 , 01 ]
				@ nLin , 012 PSAY TransForm( aDup[ 1 , 02 ] , "" )
				@ nLin , 035 PSAY TransForm( aDup[ 1 , 03 ] , "@E 99,999,999.99" )
			EndIf

			If !Empty( aDup[ 2 , 2 ] )				// Se existir 2o. vencimento
				@ nLin , 052 PSAY aDup[ 2 , 01 ]
				@ nLin , 062 PSAY TransForm( aDup[ 2 , 02 ] , "" )
				@ nLin , 085 PSAY TransForm( aDup[ 2 , 03 ] , "@E 99,999,999.99" )
			EndIf

			If !Empty( aDup[ 3 , 2 ] )				// Se existir 3o. vencimento
				@ nLin , 102 PSAY aDup[ 3 , 01 ]
				@ nLin , 112 PSAY TransForm( aDup[ 3 , 02 ] , "" )
				@ nLin , 135 PSAY TransForm( aDup[ 3 , 03 ] , "@E 99,999,999.99" )
			EndIf

			If !Empty( aDup[ 4 , 2 ] )				// Se existir 4o. vencimento
				@ nLin , 152 PSAY aDup[ 4 , 01 ]
				@ nLin , 162 PSAY TransForm( aDup[ 4 , 02 ] , "" )
				@ nLin , 184 PSAY TransForm( aDup[ 4 , 03 ] , "@E 99,999,999.99" )
			EndIf

			nLin++

			If !Empty( aDup[ 5 , 2 ] )				// Se existir 5o. vencimento
				@ nLin , 002 PSAY aDup[ 5 , 01 ]
				@ nLin , 012 PSAY TransForm( aDup[ 5 , 02 ] , "" )
				@ nLin , 035 PSAY TransForm( aDup[ 5 , 03 ] , "@E 99,999,999.99" )
			EndIf

			If !Empty( aDup[ 6 , 2 ] )				// Se existir 6o. vencimento
				@ nLin , 052 PSAY aDup[ 6 , 01 ]
				@ nLin , 062 PSAY TransForm( aDup[ 6 , 02 ] , "" )
				@ nLin , 085 PSAY TransForm( aDup[ 6 , 03 ] , "@E 99,999,999.99" )
			EndIf

			If !Empty( aDup[ 7 , 2 ] )				// Se existir 7o. vencimento
				@ nLin , 102 PSAY aDup[ 7 , 01 ]
				@ nLin , 112 PSAY TransForm( aDup[ 7 , 02 ] , "" )
				@ nLin , 135 PSAY TransForm( aDup[ 7 , 03 ] , "@E 99,999,999.99" )
			EndIf

			If !Empty( aDup[ 8 , 2 ] )				// Se existir 8o. vencimento
				@ nLin , 152 PSAY aDup[ 8 , 01 ]
				@ nLin , 162 PSAY TransForm( aDup[ 8 , 02 ] , "" )
				@ nLin , 185 PSAY TransForm( aDup[ 8 , 03 ] , "@E 99,999,999.99" )
			EndIf


            // Impressão dos ITENS


			nLiAnt	:= nLin + 35
			nLin	+= 5
			nLinItem := 1
			tSuframa := 0
			For nXX := nComeco to Len( aItens )
				If !lTudoIg
					aItens [nXX,02] += " / PC: " + aItens[nxx, 12]
				Endif
				@ nLin , 002 PSAY AllTrim( Left( aItens[ nXX , 01 ] , 15 ) )
				cDescri1 := SubStr( aItens[ nXX , 02 ] , 1 ,  85 )
				cDescri2 := Substr( aItens[ nXX , 02 ] , 86 , 85 )
				cDescri3 := Substr( aItens[ nXX , 02 ] , 171)
				@ nLin , 028 PSAY cDescri1
				If !Empty (cDescri2)
					nLin++  ; nLinItem++
					@ nLin , 028 PSAY cDescri2
				Endif
				If !Empty (cDescri3)
					nLin++  ; nLinItem++
					@ nLin , 028 PSAY cDescri3
				Endif
				@ nLin , 117 PSAY aItens[ nXX , 03 ]
				@ nLin , 121 PSAY aItens[ nXX , 04 ]
				@ nLin , 126 PSAY aItens[ nXX , 05 ]
				If aItens[ nXX , 06 ] - Int( aItens[ nXX , 06 ] ) > 0
					@ nLin , 130 PSAY TransForm( aItens[ nXX , 06 ] , "@E 9999.999" )
				Else
					@ nLin , 130 PSAY TransForm( aItens[ nXX , 06 ] , "@E 9999,999" )
				EndIf
				@ nLin , 144 PSAY TransForm( aItens[ nXX , 07 ] , "@E 999,999.9999" )
				If(lICMSRet)
					@ nLin , 160 PSAY TransForm( aItens[ nXX , 08 ] , "@E 99,999,999.99" )
				EndIf
				@ nLin , 177 PSAY TransForm( aItens[ nXX , 09 ] , "99" )
				@ nLin , 182 PSAY TransForm( aItens[ nXX , 10 ] , "99" )
				@ nLin , 186 PSAY TransForm( aItens[ nXX , 11 ] , "@E 99,999.99" )
				tSuframa += aItens[nXX,08]
				nLin++    ;   nLinItem++
				If nLinItem > 26 .and. nxx < Len(aItens)
					lDuas := .T.
					nComeco := nxx + 1
					Exit
				Endif
			Next

			If lSuframa
				nLin++
				@ nLin,028 Psay "Desconto de " + Trim(Str(nSuframa,2)) + "% ref. ao ICMS"
				dSuframa := tSuframa * nSuframa / 100
				dSuframa := Int(dSuframa * 100) / 100
//				@ nLin,160 Psay Transform(dSuframa, "@E 99,999,999.99")
				@ nLin,160 Psay Transform(nVDZF, "@E 99,999,999.99")
			Endif              
			
			If !Empty(cCDZFSA1)
				nLin++
				nLin++				
				@ nLin,028 Psay "Cod. Suframa: " + cCDZFSA1
				nLin++
				If AllTrim(aCfo[1,2]) $ "6109/6110/6119"
					@ nLin,028 Psay "Pis:"
					@ nLin,034 Psay Transform(nPis, "@E 999,999.99")
					@ nLin,054 Psay "Cofins:"
					@ nLin,060 Psay Transform(nCof, "@E 999,999.99")
			    Endif
			Endif

			If !Empty( aServicos )
				nLin  := nLiAnt -1
				nPos  := 1
				@ nLin , 184 PSAY TransForm( aServicos[ 01 , 02 ] , "@E 999,999.99" )
				nLin  ++
				// 1a. Linha da descricao
				@ nLin , 002 PSAY SubStr( aServicos[ 01 , 01 ] , nPos , 184 )
				nPos    := nPos + 184
				@ nLin , 120 Psay TransForm( aServicos[ 01 , 03 ] , "@E 999,999" )
				@ nLin , 135 PSAY TransForm( aServicos[ 01 , 04 ] , "@E 999,999.99" )
				@ nLin , 160 PSAY TransForm( aServicos[ 01 , 05 ] , "@E 999,999.99" )
				nLin++
				// 2a. Linha da descricao
				If !Empty( SubStr( aServicos[ 01 , 01 ] , nPos , 184 ) )
					@ nLin , 002 PSAY SubStr( aServicos[ 01 , 01 ] , nPos , 184 )
					nPos    := nPos + 184
				EndIf
				@ nLin , 184 PSAY TransForm( aServicos[ 01 , 05 ] , "@E 999,999.99" )
				// 3a. Linha da descricao
				If !Empty( SubStr( aServicos[ 01 , 01 ] , nPos , 184 ) )
					@ nLin , 002 PSAY SubStr( aServicos[ 01 , 01 ] , nPos , 184 )
					nPos    := nPos + 184
				EndIf
				nLin  := nLin + 1


				//	nLin  := nLin + 1
			EndIf
			nLin    := nLiAnt + 1
			nLin    := nLin + 4
			//			nLin := 39
			If lDuas
				@ nLin , 008 PSAY "**************"
				@ nLin , 050 PSAY "**************"
				@ nLin , 092 PSAY "**************"
				@ nLin , 134 PSAY "**************"
				@ nLin , 176 PSAY "**************"
				nLin    := nLin + 2
				@ nLin , 008 PSAY "**************"
				@ nLin , 050 PSAY "**************"
				@ nLin , 092 PSAY "**************"
				@ nLin , 134 PSAY "**************"
				@ nLin , 176 PSAY "**************"
				nLin    := nLin + 2
			Else
				If !(cCfo $ "111/112")
					@ nLin , 008 PSAY TransForm( SF2->F2_BASEICM	, "@E 999,999,999.99" )
					@ nLin , 050 PSAY TransForm( SF2->F2_VALICM		, "@E 999,999,999.99" )
				Else
					@ nLin , 008 PSAY TransForm (0 , "@E 999,999,999.99" )
					@ nLin , 050 PSAY Transform (0 , "@E 999,999,999.99")
				Endif
				@ nLin , 092 PSAY TransForm( SF2->F2_BRICMS		, "@E 999,999,999.99" )
				@ nLin , 134 PSAY TransForm( SF2->F2_ICMSRET	, "@E 999,999,999.99" )
				@ nLin , 176 PSAY TransForm( SF2->F2_VALMERC - SF2->F2_BASEISS	, "@E 999,999,999.99" )
				nLin    := nLin + 2
				@ nLin , 008 PSAY TransForm( SF2->F2_FRETE		, "@E 999,999,999.99" )
				@ nLin , 050 PSAY TransForm( SF2->F2_SEGURO		, "@E 999,999,999.99" )
				@ nLin , 092 PSAY TransForm( SF2->F2_DESPESA	, "@E 999,999,999.99" )
				If !(cCfo $ "111/112")
					@ nLin , 134 PSAY TransForm( SF2->F2_VALIPI		, "@E 999,999,999.99" )
				Else
					@ nLin , 134 PSAY Transform (0 , "@E 999,999,999.99")
				Endif
//				@ nLin , 176 PSAY TransForm( IF(lSuframa,tSuframa-dSuframa,SF2->F2_VALBRUT)	, "@E 999,999,999.99" )
				@ nLin , 176 PSAY TransForm( SF2->F2_VALBRUT , "@E 999,999,999.99" )
				nLin    := nLin + 3
			Endif

			If !lduas
				@ nLin , 002 PSAY SA4->A4_NOME

				If SC5->C5_TPFRETE == "C" .or. SC5->C5_TPFRETE == " "
					@ nLin, 134 PSAY "1"
				ElseIf SC5->C5_TPFRETE == "F"
					@ nLin, 134 PSAY "2"
				EndIf

				@ nLin , 164 PSAY SA4->A4_CGC Picture PesqPict( "SA4" , "A4_CGC" )
				nLin	:= nLin + 2
				@ nLin , 002 PSAY SA4->A4_END
				@ nLin , 121 PSAY SA4->A4_MUN
				@ nLin , 153 PSAY SA4->A4_EST
				@ nLin , 164 PSAY SA4->A4_INSEST
				nLin	:= nLin + 2
				@ nLin , 002 PSAY TransForm( SF2->F2_VOLUME1 , "@E 999,999" )
				@ nLin , 032 PSAY SF2->F2_ESPECI1
				
				//Fernando 29/02/08
				//Alterar impressao do peso liquido e bruto informados no cabecalho
				//pelo peso calculado PESO * QUANTIDADE
				//@ nLin , 136 PSAY TransForm( SF2->F2_PBRUTO  , "@E 99,999.9999" )
				//@ nLin , 174 PSAY TransForm( SF2->F2_PLIQUI  , "@E 99,999.9999" )
				
				@ nLin , 136 PSAY TransForm( IF( SC5->C5_PBRUTO # 0 , SC5->C5_PBRUTO , nPBruto ) , "@E 99,999.9999" )
				@ nLin , 174 PSAY TransForm( IF( SC5->C5_PESOL # 0 , SC5->C5_PESOL , nPLiqui ) , "@E 99,999.9999" )
				
				nLin := nLin + 3

				For nXX := 1 to 10
					@ nLin , 002 PSAY aObs[nXX] + " "
					If nXX == 3
						If !Empty( aItens )
							@ nLin ,135 PSAY IF(lTUdoIg,AllTrim(aItens[1,12])+" "," ")
						ElseIf !Empty( aServicos )
							@ nLin ,135 PSAY IF(lTUdoIg,AllTrim(aServicos[1,7])+" "," ")
						EndIf
						@ nlin ,158 PSAY SC5->C5_NUM
						@ nlin ,175 PSAY SC5->C5_NOMEVEN
					Endif
					nLin	:= nLin + 1
				Next
				nLin := nLin + 2

				For kkk :=1 to Len(aClasFis)
					If !Empty(aClasFis[kkk,1])
						@ nLin + aClasFis[kkk,3],aClasFis[kkk,4] PSAY aClasFis[kkk,1]+"-"+aClasFis[kkk,2]
					Endif
				Next
				nLin := nLin + 7
				@ nLin , 186 PSAY TransForm( SF2->F2_DOC , "@R XXX.XXX" )
				nLin := nLin + 8
				Exit
			Else
				nlin += 26
				@ nLin , 186 PSAY TransForm( SF2->F2_DOC , "@R XXX.XXX" )
				nLin := nLin + 9
			Endif
		Enddo
		DbSelectArea( "SF2" )
		If Empty( SF2->F2_NFIMP )
			RecLock( "SF2" )
			SF2->F2_NFIMP	:= "S"
			SF2->( MsUnLock() )
			PutMV( "MV_ULNFIMP" , SF2->F2_DOC )
		EndIf
		SF2->( DbSkip() )
	EndDo

Else           // Nota Fiscal de Entrada

	SA1->( DbSetOrder( 1 ) )
	SA2->( DbSetOrder( 1 ) )
	SA4->( DbSetOrder( 1 ) )
	SF4->( DbSetOrder( 1 ) )
	SD1->( DbSetOrder( 1 ) )
	SE2->( DbSetOrder( 1 ) )
	SC7->( DbSetOrder( 1 ) )

	DbSelectArea( "SF1" )
	SF1->( DbSetOrder( 1 ) )
	SF1->( DbSeek( xFilial() + mv_par01 + mv_par03 , .t. ) )

	SetRegua( Val(mv_par02) - Val(mv_par01) )

	While !SF1->( Eof() ) .and.	SF1->F1_FILIAL == xFilial( "SF1" ) .and. ;
		SF1->F1_DOC <= mv_par02

		IncRegua()

		If SF1->F1_SERIE # mv_par03 .or. SF1->F1_FORMUL # "S"
			SF1->( DbSkip() )
			Loop
		EndIf

		If !SF1->F1_TIPO $ "BD"
			SA2->( DbSeek( xFilial( "SA2" ) + SF1->F1_FORNECE + SF1->F1_LOJA ) )
			cNome    := SA2->A2_NOME
			cCod     := SA2->A2_COD
			cLoja    := SA2->A2_LOJA
			cCGC     := SA2->A2_CGC
			cEnd     := SA2->A2_END
			cBai     := Left( SA2->A2_BAIRRO , 25 )
			cCep     := SA2->A2_CEP
			cMun     := SA2->A2_MUN
			cTel     := SA2->A2_TEL
			cEst     := SA2->A2_EST
			cIns     := SA2->A2_INSCR
			cCDZFSA1 := ""
			cEnd_C   := ""
			cBai_C   := ""
			cMun_C   := ""
			cEst_C   := ""
			cCep_C   := ""
		Else
			SA1->( DbSeek( xFilial( "SA1" ) + SF1->F1_FORNECE + SF1->F1_LOJA ) )
			cNome    := SA1->A1_NOME
			cCod     := SA1->A1_COD
			cLoja    := SA1->A1_LOJA
			cCGC     := SA1->A1_CGC
			cEnd     := SA1->A1_END
			cBai     := Left( SA1->A1_BAIRRO , 25 )
			cCep     := SA1->A1_CEP
			cMun     := SA1->A1_MUN
			cTel     := SA1->A1_TEL
			cEst     := SA1->A1_EST
			cIns     := SA1->A1_INSCR
			cCDZFSA1 := SA1->A1_SUFRAMA
			cEnd_C   := SA1->A1_ENDCOB
			cBai_C   := SA1->A1_BAIRROC
			cMun_C   := SA1->A1_MUNC
			cEst_C   := SA1->A1_ESTC
			cCep_C   := SA1->A1_CEPC
		EndIf

		//		SA4->( DbSeek( xFilial( "SA4" ) + SF2->F2_TRANSP ) )

		aObs  := {}
		For nXX := 1 to 10
			aAdd( aObs , "" )
		Next

		cMensagem:= ""
		aDup  := {}                      && Duplicatas
		For nXX := 1 to 8
			aAdd( aDup , { "" , "" , "" } )
		Next
		nDup  := 1

		SE2->( DbSeek( xFilial( "SE2" ) + SF1->F1_SERIE + SF1->F1_DOC ) )
		While !SE2->( Eof() ) .and. SE2->E2_FILIAL == xFilial( "SE2" ) .and. ;
			SE2->E2_PREFIXO == SF1->F1_SERIE .and. SE2->E2_NUM == SF1->F1_DOC .and. ;
			nDup<=4
			If !"-" $ SE1->E1_TIPO
				aDup[ nDup , 01 ] := SE2->E2_PARCELA // SE2->E2_NUM + SE2->E2_PARCELA
				aDup[ nDup , 02 ] := SE2->E2_VENCTO
				aDup[ nDup , 03 ] := SE2->E2_VALOR - SE2->E2_IRRF - SE2->E2_CSLL - SE2->E2_COFINS - SE2->E2_PIS
				nDup  := nDup + 1
			Endif
			SE2->( DbSkip() )
		EndDo

		nLetra		:= 64
		aClasfis	:= {}
		aCFO        := {}
		aItens      := {}
		aServicos   := {}
		cFormula    := ""
		cHP         := ""
		coordx      := {0,0,0,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2}
		coordy		:= {4,24,44,64,84,104,4,24,44,64,84,104,4,24,44,64,84,104}

		SD1->( DbSeek( xFilial( "SD1" ) + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA ) )

		While !SD1->( Eof() ) .and.	SD1->D1_FILIAL == xFILIAL( "SD1" )  .and. ;
			SD1->D1_DOC    == SF1->F1_DOC       .and. ;
			SD1->D1_SERIE  == SF1->F1_SERIE     .and. ;
			SD1->D1_FORNECE== SF1->F1_FORNECE   .and. ;
			SD1->D1_LOJA   == SF1->F1_LOJA

			SB1->( DbSeek( xFILIAL( "SB1" ) + SD1->D1_COD ) )
			SF4->( DbSeek( xFILIAL( "SF4" ) + SD1->D1_TES ) )
			SC7->( dbSeek (xFilial( "SC7" ) + SD1->D1_PEDIDO + SD1->D1_ITEMPC ) )

			If aScan( aCFO , { |x| x[3] == SD1->D1_TES } ) == 0
				aAdd( aCFO , { SF4->F4_TEXTO , SD1->D1_CF , SD1->D1_TES } )
			EndIf

//			If !Empty( SF4->F4_FORMULA ) .and. !SF4->F4_FORMULA $ cFormula
//				cFormula	:= cFormula + SF4->F4_FORMULA
//				cTexto		:= AllTrim( Formula( SF4->F4_FORMULA ) )
//				cMensagem   := AllTrim( cTexto ) + IF( !Empty( cTexto ) , " # " , "" )
//			EndIf

			If !Empty(Trim(SF4->F4_MENSAGE) ) .and. !Trim(SF4->F4_MENSAGE) $ cFormula
				cFormula	:= cFormula + Trim(SF4->F4_MENSAGE)
				cTexto		:= AllTrim( Formula( SF4->F4_MENSAGE ) )
				cMensagem   += AllTrim( cTexto ) + IF( !Empty( cTexto ) , " # " , "" )
			EndIf

			If !Empty(Trim(SC7->C7_OBS) )
				cTexto		:= AllTrim( SC7->C7_OBS )
				cMensagem   += AllTrim( cTexto ) + IF( !Empty( cTexto ) , " # " , "" )
			EndIf


			If SF1->F1_TIPO $ "B/D"
				If ! (SD1->D1_NFORI $ cMensagem)
					cTexto := SD1->D1_NFORI
					cMensagem   += AllTrim( cTexto ) + IF( !Empty( cTexto ) , " # " , "" )
				Endif
			Endif

			If SD1->D1_ALIQISS # 0
				aAdd( aServicos , { SB1->B1_DENOM , SD1->D1_VALISS , SD1->D1_QUANT , SD1->D1_VUNIT , SD1->D1_TOTAL } )
			Else
				cLetra	:= ""
				If ( nPos	:= aScan( aClasFis , { |x| x[2] == SB1->B1_POSIPI } ) ) == 0
					nLetra++
					aAdd( aClasFis , { Chr( nLetra ) , SB1->B1_POSIPI , coordx[nletra-64], coordy[nletra-64] } )
					nPos	:= Len( aClasFis )
				EndIf
				cLetra	:= aClasFis[ nPos , 1 ]
				aAdd( aItens , {	Left(SD1->D1_COD,15) , Trim(SB1->B1_DESC) + " / " + Trim(SB1->B1_CODLMT),;
				cLetra ,;
				SD1->D1_CLASFIS , SD1->D1_UM , SD1->D1_QUANT ,;
				((SD1->D1_TOTAL-SD1->D1_VALDESC)/SD1->D1_QUANT),  (SD1->D1_TOTAL - SD1->D1_VALDESC) ,;
				SD1->D1_PICM ,SD1->D1_IPI , SD1->D1_VALIPI } )
			EndIf

			SD1->( DbSkip() )
		EndDo

		// Montagem dos dados adicionais

		nConta      := 1
		nLinhaObs   := 1


		For nXX := nLinhaObs to 10
			If Empty( AllTrim( SubStr( cMensagem , nConta , 128) ) )
				Exit
			EndIf
			aObs[ nXX ] := AllTrim( SubStr( cMensagem , nConta , 128) )
			nConta      := nConta + 128
			nLinhaObs   := nLinhaObs + 1
		Next nXX
		/*
		cMensagem	:= ""
		nSeqCF		:= 1
		nQuebraCF	:= 1
		For nXX := nLinhaObs to 10
		For nCF := nSeqCF to Len( aClasFis )
		If nQuebraCF > 8	;	Exit	;	EndIf
		cMensagem	+= aClasFis[ nCF , 1 ] + "-" + aClasFis[ nCF , 2 ] + " "
		nQuebraCF++
		nSeqCF++
		Next nCF
		aObs[ nXX ] := AllTrim( cMensagem )
		nLinhaObs   := nLinhaObs + 1
		cMensagem	:= ""
		nQuebraCF		:= 1
		Next nXX
		*/
		// Inicio da Impressao
		nComeco := 1
		Do While .T.
			lDuas   := .F.
			@ nLin , 186 PSAY TransForm( SF1->F1_DOC , "@R XXX.XXX" )
			nLin++
			@ nLin , 167 PSAY "X"
			nLin  := nLin + 5
			@ nLin , 002 PSAY ""
			For nXX := 1 to Len( aCFO )				// Descrição CFOP
				@ nLin , PCol() PSAY AllTrim( aCFO[ nXX , 1 ] ) + IF( nXX + 1 <= Len( aCFO ) , "/" , "" )
			Next nXX
			@ nLin , 099 PSAY ""
			For nXX := 1 to Len( aCFO )				// CFOP
				@ nLin , PCol() PSAY AllTrim( aCFO[ nXX , 2 ] ) + IF( nXX + 1 <= Len( aCFO ) , "/" , "" )
			Next nXX
			nLin  := nLin + 3
			@ nLin , 002 PSAY cNome + Space( 02 ) + cCod + IF( !Empty( cLoja ) , "/" + cLoja , "" )
			@ nLin , 150 PSAY cCGC Picture PesqPict( "SA1" , "A1_CGC" )
			@ nLin , 182 PSAY TransForm( SF1->F1_DTDIGIT , "" )
			nLin  := nLin + 2
			@ nLin , 002 PSAY cEnd
			If !Empty(cBai)
				@ nLin , 127 PSAY AllTrim( cBai )
			Endif
			@ nLin , 163 PSAY cCep Picture PesqPict( "SA1" , "A1_CEP" )
			nLin  := nLin + 2
			@ nLin , 002 PSAY cMun
			@ nLin , 089 PSAY cTel
			@ nLin , 127 PSAY cEst
			@ nLin , 150 PSAY cIns
			nLin  := nLin + 3
			/*
			@ nLin , 002 PSAY IF( !Empty( SF1->F1_DUPL ) , TransForm( SF1->F1_DOC , "@R XXX.XXX" ) , "" )
			nCol	:= 64
			For nXX := 1 to Len( aDup )			// Vencimento
			If !Empty( aDup[ nXX , 02 ] )
			@ nLin , nCol PSAY TransForm( aDup[ nXX , 02 ] , "" )
			EndIf
			nCol	+= 24
			Next
			nLin	+= 2
			nCol	:= 62
			For nXX := 1 to Len( aDup )			// Valor
			If !Empty( aDup[ nXX , 03 ] )
			@ nLin , nCol PSAY TransForm( aDup[ nXX , 03 ] , "@E 99,999,999.99" )
			EndIf
			nCol	+= 24
			Next
			nLin	+= 2
			nLiAnt	:= nLin + 29
			*/
			cExtVal	:= Extenso( SF1->F1_VALBRUT )

			If !Empty( aDup[ 1 , 2 ] )				// Se existir 1o. vencimento
				@ nLin , 002 PSAY aDup[ 1 , 01 ]
				@ nLin , 012 PSAY TransForm( aDup[ 1 , 02 ] , "" )
				@ nLin , 035 PSAY TransForm( aDup[ 1 , 03 ] , "@E 99,999,999.99" )
			EndIf

			If !Empty( aDup[ 2 , 2 ] )				// Se existir 2o. vencimento
				@ nLin , 052 PSAY aDup[ 2 , 01 ]
				@ nLin , 062 PSAY TransForm( aDup[ 2 , 02 ] , "" )
				@ nLin , 085 PSAY TransForm( aDup[ 2 , 03 ] , "@E 99,999,999.99" )
			EndIf

			If !Empty( aDup[ 3 , 2 ] )				// Se existir 2o. vencimento
				@ nLin , 102 PSAY aDup[ 2 , 01 ]
				@ nLin , 112 PSAY TransForm( aDup[ 2 , 02 ] , "" )
				@ nLin , 135 PSAY TransForm( aDup[ 2 , 03 ] , "@E 99,999,999.99" )
			EndIf

			If !Empty( aDup[ 4 , 2 ] )				// Se existir 2o. vencimento
				@ nLin , 152 PSAY aDup[ 2 , 01 ]
				@ nLin , 162 PSAY TransForm( aDup[ 2 , 02 ] , "" )
				@ nLin , 184 PSAY TransForm( aDup[ 2 , 03 ] , "@E 99,999,999.99" )
			EndIf

			nLin++

			If !Empty( aDup[ 5 , 2 ] )				// Se existir 3o. vencimento
				@ nLin , 002 PSAY aDup[ 3 , 01 ]
				@ nLin , 012 PSAY TransForm( aDup[ 3 , 02 ] , "" )
				@ nLin , 035 PSAY TransForm( aDup[ 3 , 03 ] , "@E 99,999,999.99" )
			EndIf

			If !Empty( aDup[ 6 , 2 ] )				// Se existir 4o. vencimento
				@ nLin , 052 PSAY aDup[ 4 , 01 ]
				@ nLin , 062 PSAY TransForm( aDup[ 4 , 02 ] , "" )
				@ nLin , 085 PSAY TransForm( aDup[ 4 , 03 ] , "@E 99,999,999.99" )
			EndIf

			If !Empty( aDup[ 7 , 2 ] )				// Se existir 3o. vencimento
				@ nLin , 102 PSAY aDup[ 3 , 01 ]
				@ nLin , 112 PSAY TransForm( aDup[ 3 , 02 ] , "" )
				@ nLin , 135 PSAY TransForm( aDup[ 3 , 03 ] , "@E 99,999,999.99" )
			EndIf

			If !Empty( aDup[ 8 , 2 ] )				// Se existir 4o. vencimento
				@ nLin , 152 PSAY aDup[ 4 , 01 ]
				@ nLin , 162 PSAY TransForm( aDup[ 4 , 02 ] , "" )
				@ nLin , 185 PSAY TransForm( aDup[ 4 , 03 ] , "@E 99,999,999.99" )
			EndIf


			//  nLin += 2

			nLiAnt	:= nLin + 35
			nLin	+= 5
			nLinItem := 1

			For nXX := nComeco to Len( aItens )
				@ nLin , 002 PSAY AllTrim( Left( aItens[ nXX , 01 ] , 15 ) )
				cDescri1 := SubStr( aItens[ nXX , 02 ] , 1 ,  85 )
				cDescri2 := Substr( aItens[ nXX , 02 ] , 86 , 85 )
				cDescri3 := Substr( aItens[ nXX , 02 ] , 171)
    	     	@ nLin , 028 PSAY cDescri1
				If !Empty (cDescri2)
					nLin++  ; nLinItem++
					@ nLin , 028 PSAY cDescri2
				Endif
				If !Empty (cDescri3)
					nLin++  ; nLinItem++
					@ nLin , 028 PSAY cDescri3
				Endif
				@ nLin , 117 PSAY aItens[ nXX , 03 ]
				@ nLin , 121 PSAY aItens[ nXX , 04 ]
				@ nLin , 126 PSAY aItens[ nXX , 05 ]
				If aItens[ nXX , 06 ] - Int( aItens[ nXX , 06 ] ) > 0
					@ nLin , 130 PSAY TransForm( aItens[ nXX , 06 ] , "@E 9999.99" )
				Else
					@ nLin , 130 PSAY TransForm( aItens[ nXX , 06 ] , "@E 999,999" )
				EndIf
				@ nLin , 144 PSAY TransForm( aItens[ nXX , 07 ] , "@E 999,999.9999" )
				@ nLin , 160 PSAY TransForm( aItens[ nXX , 08 ] , "@E 99,999,999.99" )
				@ nLin , 177 PSAY TransForm( aItens[ nXX , 09 ] , "99" )
				@ nLin , 182 PSAY TransForm( aItens[ nXX , 10 ] , "99" )
				@ nLin , 186 PSAY TransForm( aItens[ nXX , 11 ] , "@E 9,999,999.99" )
				nLinItem++
				nLin  := nLin + 1
		  		If nLinItem > 26 .and. nxx < Len(aItens)
		  			lDuas := .T.
		  			nComeco := nxx + 1
		  			Exit
		  		Endif
			Next
/*
			If SF1->F1_VALIMP6 # 0
				nLin  := nLin + 1
				@ nLin , 018 PSAY "PIS....: " + TransForm( SF1->F1_VALIMP6 , "@E 999,999.99" )
			EndIf

			If SF1->F1_VALIMP5 # 0
				nLin  := nLin + 1
				@ nLin , 018 PSAY "COFINS.: " + TransForm( SF1->F1_VALIMP5 , "@E 999,999.99" )
			EndIf
*/
			If !Empty( aServicos )
				nLin    := nLiAnt - 1
				nPos  := 1

				// 1a. Linha da descricao
				@ nLin , 002 PSAY SubStr( aServicos[ 01 , 01 ] , nPos , 100 )
				nLin    := nLin + 1
				nPos    := nPos + 100

				// 2a. Linha da descricao
				If !Empty( SubStr( aServicos[ 01 , 01 ] , nPos , 100 ) )
					@ nLin , 002 PSAY SubStr( aServicos[ 01 , 01 ] , nPos , 100 )
					nLin  := nLin + 1
					nPos    := nPos + 100
				Else
					nLin  := nLin + 1
				EndIf

				// 3a. Linha da descricao
				If !Empty( SubStr( aServicos[ 01 , 01 ] , nPos , 100 ) )
					@ nLin , 002 PSAY SubStr( aServicos[ 01 , 01 ] , nPos , 100 )
					nPos    := nPos + 100
				EndIf

				@ nLin , 161 PSAY TransForm( aServicos[ 01 , 02 ] , "@E 999,999.99" )
				nLin  := nLin + 1

				// 4a. Linha da descricao
				If !Empty( SubStr( aServicos[ 01 , 01 ] , nPos , 100 ) )
					@ nLin , 002 PSAY SubStr( aServicos[ 01 , 01 ] , nPos , 100 )
					nLin  := nLin + 1
					nPos    := nPos + 100
				Else
					nLin  := nLin + 1
				EndIf

				// 5a. Linha da descricao
				If !Empty( SubStr( aServicos[ 01 , 01 ] , nPos , 100 ) )
					@ nLin , 002 PSAY SubStr( aServicos[ 01 , 01 ] , nPos , 100 )
				EndIf
				@ nLin , 161 PSAY TransForm( aServicos[ 01 , 05 ] , "@E 999,999.99" )

			EndIf
			nLin    := nLiAnt + 1
			nLin    := nLin + 4
			If lDuas
				@ nLin , 008 PSAY "**************"
				@ nLin , 050 PSAY "**************"
				@ nLin , 092 PSAY "**************"
				@ nLin , 134 PSAY "**************"
				@ nLin , 176 PSAY "**************"
				nLin    := nLin + 2
				@ nLin , 008 PSAY "**************"
				@ nLin , 050 PSAY "**************"
				@ nLin , 092 PSAY "**************"
				@ nLin , 134 PSAY "**************"
				@ nLin , 176 PSAY "**************"
				nLin    := nLin + 2
			Else
				If SF1->F1_TIPO == "I"
					@ nLin , 050 PSAY TransForm( SF1->F1_VALICM		, "@E 999,999,999.99" )
					nLin := nLin + 5
				ElseIf SF1->F1_TIPO == "P"
					nLin := nLin + 2
					@ nLin , 092 PSAY TransForm( SF1->F1_VALIPI		, "@E 999,999,999.99" )
					@ nLin , 134 PSAY TransForm( SF1->F1_VALBRUT	, "@E 999,999,999.99" )
					nLin := nLin + 3
				Else
					@ nLin , 008 PSAY TransForm( SF1->F1_BASEICM	, "@E 999,999,999.99" )
					@ nLin , 050 PSAY TransForm( SF1->F1_VALICM		, "@E 999,999,999.99" )
					@ nLin , 092 PSAY TransForm( SF1->F1_BRICMS		, "@E 999,999,999.99" )
					@ nLin , 134 PSAY TransForm( SF1->F1_ICMSRET	, "@E 999,999,999.99" )
					@ nLin , 176 PSAY TransForm( SF1->F1_VALMERC - SF1->F1_DESCONT	, "@E 999,999,999.99" )
					nLin    := nLin + 2
					@ nLin , 008 PSAY TransForm( SF1->F1_FRETE		, "@E 999,999,999.99" )
					@ nLin , 050 PSAY TransForm( SF1->F1_SEGURO		, "@E 999,999,999.99" )
					@ nLin , 092 PSAY TransForm( SF1->F1_DESPESA	, "@E 999,999,999.99" )
					@ nLin , 134 PSAY TransForm( SF1->F1_VALIPI		, "@E 999,999,999.99" )
					@ nLin , 176 PSAY TransForm( SF1->F1_VALBRUT	, "@E 999,999,999.99" )
					nLin    := nLin + 3
				Endif
			Endif
			IF !lduas
				//       	@ nLin , 002 PSAY SA4->A4_NOME

				//		If SC5->C5_TPFRETE == "C" .or. SC5->C5_TPFRETE == " "
				//           	@ nLin, 121 PSAY "1"
				//		ElseIf SC5->C5_TPFRETE == "F"
				//           	@ nLin, 121 PSAY "2"
				//		EndIf

				//       	@ nLin , 146 PSAY SA4->A4_CGC Picture PesqPict( "SA4" , "A4_CGC" )
				nLin	:= nLin + 2
				//       	@ nLin , 002 PSAY SA4->A4_END
				//       	@ nLin , 107 PSAY SA4->A4_MUN
				//       	@ nLin , 138 PSAY SA4->A4_EST
				//       	@ nLin , 146 PSAY SA4->A4_INSEST
				nLin	:= nLin + 2
				//       	@ nLin , 008 PSAY TransForm( SF2->F2_VOLUME1 , "@E 999,999" )
				//       	@ nLin , 020 PSAY SF2->F2_ESPECI1
				//       	@ nLin , 136 PSAY TransForm( SF2->F2_PBRUTO  , "@E 99,999.9999" )
				//       	@ nLin , 159 PSAY TransForm( SF2->F2_PLIQUI  , "@E 99,999.9999" )

				nLin    := nLin + 3

				For nXX := 1 to 10
					@ nLin , 002 PSAY aObs[nXX]
					nLin	:= nLin + 1
				Next

				nLin := nLin + 2

				For kkk :=1 to Len(aClasFis)
					If !Empty(aClasFis[kkk,1])
						@ nLin + aClasFis[kkk,3],aClasFis[kkk,4] PSAY aClasFis[kkk,1]+"-"+aClasFis[kkk,2]
					Endif
				Next

				nLin    := nLin + 7
				@ nLin , 186 PSAY TransForm( SF1->F1_DOC , "@R XXX.XXX" )
				nLin    := nLin + 8
				Exit
			Else
				nlin += 27
				@ nLin , 186 PSAY TransForm( SF1->F1_DOC , "@R XXX.XXX" )
				nLin := nLin + 9
			Endif
		Enddo

		PutMV( "MV_ULNFIMP" , SF1->F1_DOC )

		DbSelectArea( "SF1" )
		SF1->( DbSkip() )
	EndDo

EndIf

//@ 0,0 PSAY CHR(27)+"@"
@ nLin,0 PSAY CHR(27)+"@"

Set Device To Screen

If lMostra
	If aReturn[5] == 1
		Set Printer TO
		dbcommitAll()
		ourspool(wnrel)
	EndIf

	MS_FLUSH()
EndIf

Return

****************************************************************************************
Static Function ValidPerg()

Local _sAlias := Alias()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
//cPerg := PADR(cPerg,6)

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01","Da N.Fiscal " ,"Da N.Fiscal " ,"Da N.Fiscal " ,"mv_ch1","C",06,0,0,"G",""        ,"mv_par01","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Ate N.Fiscal" ,"Ate N.Fiscal" ,"Ate N.Fiscal" ,"mv_ch2","C",06,0,0,"G",""        ,"mv_par02","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Serie       " ,"Serie       " ,"Serie       " ,"mv_ch3","C",03,0,0,"G",""        ,"mv_par03","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","N.F. de     " ,"N.F. de     " ,"N.F. de     " ,"mv_ch4","N",01,0,0,"C",""        ,"mv_par04","Entrada","","","","","Saida","","","","","","","",""})

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

dbSelectArea(_sAlias)

Return

// 329	((SD2->D2_TOTAL + SD2->D2_DESCON + SD2->D2_DESCZFR) / SD2->D2_QUANT) , (SD2->D2_TOTAL + SD2->D2_DESCON + SD2->D2_DESCZFR) 
