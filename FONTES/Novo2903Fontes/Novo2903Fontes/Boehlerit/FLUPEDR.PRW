#Include "rwmake.ch"

User Function FLUPEDR()

Local	cDesc1	:= "Relatório - Fluxo de Pedidos / OP´s"
Local	cDesc2	:= ""
Local	cDesc3	:= ""

Private	titulo	:= "RELATÓRIO GERENCIAL FLUXO DE PEDIDOS"
cPerg	:= PadR( "FLUPED" , Len( SX1->X1_GRUPO ) )
Private	cString	:= "SZC"
Private	aReturn	:= { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
Private	nomeprog:= cPerg
Private	nLastKey:= 0 
Private	cabec1	:= ""
Private	cabec2	:= ""
Private	tamanho	:= "G"
Private	caracter:= 15
Private	wnrel	:= "FLUPEDR"

If	SM0->M0_CODIGO # "01"
	MsgBox( "Rotina disponível apenas para empresa LMT.", "ATENÇÃO...", "STOP" )
	Return
EndIf

AjustaSX1()

Pergunte(cPerg,.F.)

wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,.f.,Tamanho)

If nLastKey == 27
	Set Filter To
	Return
Endif
SetDefault(aReturn,cString)
If nLastKey == 27
	Set Filter To
	Return
Endif

If	Select( "TRBEXCEL" ) # 0
	TRBEXCEL->( DbCloseArea() )
EndIf

aStru := {}
aAdd(aStru,{"OP",		"C",	TamSx3( "ZC_OP" )[1],	TamSx3( "ZC_OP")[2] } )
aAdd(aStru,{"DESVIO",	"N",	10, 0 } )
aAdd(aStru,{"DEPTO",	"C",	30,	0 } )
aAdd(aStru,{"EMI_PED",	"D",	08,	0 } )

oTemptable := FWTemporaryTable():New( "TRBEXCEL")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"OP"} )
oTempTable:Create()
/*
cArq := CriaTrab(aStru,.T.)
dbUseArea(.T.,,cArq,"TRBEXCEL",.T.)
cInd := CriaTrab(NIL,.F.)
IndRegua("TRBEXCEL",cInd,"OP",,,"Selecionando Registros...")
*/
If		mv_par09 == 1					// Relatório de Op´s
	RptStatus({|lEnd| FLUPEDR01(@lEnd,tamanho,wnrel,cString)},Titulo)
ElseIf	mv_par09 == 2					// Relatório de Pedidos
	RptStatus({|lEnd| FLUPEDR02(@lEnd,tamanho,wnrel,cString)},Titulo)
EndIf

Return .T.

********************************************************************************************************************
Static Function FLUPEDR01(lEnd,tamanho,wnrel,cString)

Local	cZC_OP			:= ""
Local	nCol1			:= 0
Local	nCol2			:= 0
Local	nCol3			:= 0
Local	aRealizado		:= {}
Local	aDesvio			:= {}
Local	aDepto			:= {}
Local	aPrevisto		:= {}
Local	aStatus_Atual	:= {}
Local	nTotalDias		:= 0
Local	dPrazoPrevisto	:= CtoD( "" )
Local	dPrazoReal		:= CtoD( "" )
Local	nDesvioGeral	:= 0
Local	nQtdDesvio		:= 0
Local	nDesvio			:= 0
Local	aArea_SZC

Private	LI			:= 100
Private	m_pag		:= 1

SZB->( DbSetOrder( 1 ) )
SC2->( DbSetOrder( 1 ) )
SC5->( DbSetOrder( 1 ) )
SC6->( DbSetOrder( 1 ) )
SZE->( DbSetOrder( 1 ) )

DbSelectArea( "SZC" )
SZC->( DbSetOrder( 1 ) )
SZC->( DbSeek( xFilial( "SZC" ) + mv_par01 , .T. ) )

SetRegua( SZC->( LastRec() ) )

While !SZC->( Eof() ) .and.	SZC->ZC_FILIAL	== xFilial( "SZC" ) .and. ;
							SZC->ZC_OP		<= mv_par02

	cZC_OP	:= SZC->ZC_OP
	lOK		:= .T.

	If	SZC->ZC_TIPOOP == "P"

		If	!SZB->( DbSeek( xFilial( "SZB" ) + Left( SZC->ZC_OP , 8 ) ) ) .or. ;
			SZB->ZB_DTENT < mv_par05 .or. SZB->ZB_DTENT > mv_par06
			lOK		:= .F.
		EndIf

	Else

		If	SZC->ZC_DTENT < mv_par05 .or. SZC->ZC_DTENT > mv_par06
			lOK		:= .F.
		EndIf

	EndIf

	aStatus_Atual	:= Status01( SZC->ZC_OP )

	If	!lOK .or. ;
		( aStatus_Atual[2] == "Z" .and. mv_par10 == 2 ) .or. ;
		!( aStatus_Atual[4] >= mv_par11 .and. aStatus_Atual[4] <= mv_par12 )
		While !SZC->( Eof() ) .and.	SZC->ZC_FILIAL	== xFilial( "SZC" ) .and. SZC->ZC_OP == cZC_OP
			IncRegua()
			SZC->( DbSkip() )
		EndDo
		Loop
	EndIf

	aArea_SZC	:= SZC->( GetArea() )

	For nAA := 1 to IF( mv_par07 == 1 .or. !Empty( mv_par08 ) , 2 , 1 )

		If		nAA == 1					// análise
		 	If	( mv_par07 == 2 .and. Empty( mv_par08 ) )
				lImprime	:= .T.
			Else
				lImprime	:= .F.
			EndIf
		ElseIf	nAA == 2					// imprime
			lImprime	:= .T.
		EndIf

		If	nAA == 2
			RestArea( aArea_SZC )
		EndIf

		SZB->( DbSeek( xFilial( "SZB" ) + Left( SZC->ZC_OP , 8 ) ) )
		SC6->( DbSeek( xFilial( "SC6" ) + Left( SZC->ZC_OP , 8 ) ) )
		SC5->( DbSeek( xFilial( "SC5" ) + Left( SZC->ZC_OP , 6 ) ) )
		SC2->( DbSeek( xFilial( "SC2" ) + cZC_OP ) )

		If	nAA == 1
			aStatus_Atual	:= Status01( SZC->ZC_OP )
		EndIf

		If	lImprime

			If	LI > 55
				Cabec( titulo , cabec1 , cabec2 , nomeprog , tamanho , caracter )
			Else
				@ li,000 PSAY __PrtThinLine()
				LI++
			EndIf

			@ LI, 000 PSAY "Nº PEDIDO: " + TransForm( SZB->( ZB_PEDIDO + ZB_ITEMPV ) , "@R XXXXXX-XX" )
			@ LI, 027 PSAY "CLIENTE: " + TransForm( SZB->( ZB_CLIENTE + ZB_LOJACLI ) , "@R XXXXXX-XX" ) + " - " + SZB->ZB_NOMCLI
			@ LI, 078 PSAY "PRODUTO: " + SZC->ZC_PRODUTO
			@ LI, 112 PSAY "CÓD.LMT: " + SZC->ZC_CODLMT
			@ LI, 177 PSAY "Nº OP: " + TransForm( SZC->ZC_OP , "@R XXXXXX-XX-XXX" )
			LI	+= 2
			@ LI, 000 PSAY "<--------- VENDAS ---------->                    <------- ENGENHARIA -------->                    <----------- PCP ----------->"
			@ LI, 160 PSAY "* STATUS ATUAL: " + aStatus_Atual[1]
			LI++
			@ LI, 000 PSAY "ENTRADA   SAÍDA     REALIZADO                    ENTRADA   SAÍDA     REALIZADO                    ENTRADA   SAÍDA     REALIZADO"
			@ LI, 160 PSAY IF( !Empty( aStatus_Atual[3] ) , "* FORNECEDOR  : " + AllTrim( aStatus_Atual[3] ) + " / " + aStatus_Atual[4] + "-" + aStatus_Atual[5] , "" )
	
			LI++
		EndIf

		nCol1	:= 00
		nCol2	:= 10
		nCol3	:= 23

		aRealizado	:= {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
		aDesvio		:= {.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.}
		aDepto		:= {"","","","","","","","","","","","","","","","","","","",""}
		aPrevisto	:= {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
		nTotalDias	:= 0
		dPrazoReal	:= CtoD( "" )

		While !SZB->( Eof() ) .and. SZB->ZB_FILIAL == xFilial( "SZB" ) .and. SZB->( ZB_PEDIDO + ZB_ITEMPV ) == Left( cZC_OP , 8 )

			If		SZB->ZB_DEPTOOR == "1"				// Vendas
				If	lImprime
					@ LI, nCol1 PSAY TransForm( SZB->ZB_DTENT , "@E" )
					@ LI, nCol2 PSAY TransForm( SZB->ZB_DTSAI , "@E" )
				EndIf
				If	!Empty( SZB->ZB_DTSAI )
					If	lImprime
						@ LI, nCol3 PSAY TransForm( SZB->( ZB_DTSAI - ZB_DTENT ) , "@E 999" )
					EndIf
					nTotalDias	+= SZB->( ZB_DTSAI - ZB_DTENT )
				Else
					If	lImprime
						@ LI, nCol3 PSAY TransForm( Date() - SZB->ZB_DTENT , "@E 999" )
					EndIf
					nTotalDias	+= Date() - SZB->ZB_DTENT
				EndIf
			ElseIf	SZB->ZB_DEPTOOR == "2"				// Engenharia
				If	lImprime
					@ LI, nCol1 PSAY TransForm( SZB->ZB_DTENT , "@E" )
					@ LI, nCol2 PSAY TransForm( SZB->ZB_DTSAI , "@E" )
				EndIf
				If	!Empty( SZB->ZB_DTSAI )
					If	lImprime
						@ LI, nCol3 PSAY TransForm( SZB->( ZB_DTSAI - ZB_DTENT ) , "@E 999" )
					EndIf
					nTotalDias	+= SZB->( ZB_DTSAI - ZB_DTENT )
				Else
					If	lImprime
						@ LI, nCol3 PSAY TransForm( Date() - SZB->ZB_DTENT , "@E 999" )
					EndIf
					nTotalDias	+= Date() - SZB->ZB_DTENT
				EndIf
			EndIf
			nCol1		+= 49
			nCol2		+= 49
			nCol3		+= 49

			SZB->( DbSkip() )
		EndDo

		SZE->( DbSeek( xFilial( "SZE" ) + cZC_OP ) )
		While !SZE->( Eof() ) .and. SZE->ZE_FILIAL == xFilial( "SZE" ) .and. SZE->ZE_OP == cZC_OP
			If	Val(SZE->ZE_DEPTO) >= 1 .and. Val(SZE->ZE_DEPTO) <= 9
				aPrevisto[Val(SZE->ZE_DEPTO)]		:= SZE->ZE_NRDIAS
			Else
				aPrevisto[Asc(SZE->ZE_DEPTO)-55]	:= SZE->ZE_NRDIAS
			EndIf
			SZE->( DbSkip() )
		EndDo

		nCol1	:= 098
		nCol2	:= 108
		nCol3	:= 121

		While !SZC->( Eof() ) .and. SZC->ZC_FILIAL == xFilial( "SZC" ) .and. SZC->ZC_OP == cZC_OP

			If	!lImprime
				IncRegua()
			EndIf

			If	SZC->ZC_DEPTOOR == "3"					// PCP
				If	lImprime
					@ LI, nCol1 PSAY TransForm( SZC->ZC_DTENT , "@E" )
					@ LI, nCol2 PSAY TransForm( SZC->ZC_DTSAI , "@E" )
				EndIf
				If	!Empty( SZC->ZC_DTSAI )
					If	lImprime
						@ LI, nCol3 PSAY TransForm( SZC->( ZC_DTSAI - ZC_DTENT ) , "@E 999" )
					EndIf
					nTotalDias	+= SZC->( ZC_DTSAI - ZC_DTENT )
				Else
					If	lImprime
						@ LI, nCol3 PSAY TransForm( Date() - SZC->ZC_DTENT , "@E 999" )
					EndIf
					nTotalDias	+= Date() - SZC->ZC_DTENT
				EndIf
			ElseIf	Val(SZC->ZC_DEPTOOR) >= 1 .and. Val(SZC->ZC_DEPTOOR) <= 9
				If	!Empty( SZC->ZC_DTSAI )
					aRealizado[Val(SZC->ZC_DEPTOOR)]	+= SZC->( ZC_DTSAI - ZC_DTENT )
					aDepto[Val(SZC->ZC_DEPTOOR)]		:= SZC->ZC_DEPTOOR
					aDesvio[Val(SZC->ZC_DEPTOOR)]		:= .T.
				Else
					aRealizado[Val(SZC->ZC_DEPTOOR)]	+= Date() - SZC->ZC_DTENT
					aDepto[Val(SZC->ZC_DEPTOOR)]		:= SZC->ZC_DEPTOOR
					aDesvio[Val(SZC->ZC_DEPTOOR)]		:= .F.
				EndIf
			Else
				If	!Empty( SZC->ZC_DTSAI )
					aRealizado[Asc(SZC->ZC_DEPTOOR)-55]	+= SZC->( ZC_DTSAI - ZC_DTENT )
					aDepto[Asc(SZC->ZC_DEPTOOR)-55]		:= SZC->ZC_DEPTOOR
					aDesvio[Asc(SZC->ZC_DEPTOOR)-55]	:= .T.
				Else
					aRealizado[Asc(SZC->ZC_DEPTOOR)-55]	+= Date() - SZC->ZC_DTENT
					aDepto[Asc(SZC->ZC_DEPTOOR)-55]		:= SZC->ZC_DEPTOOR
					aDesvio[Asc(SZC->ZC_DEPTOOR)-55]	:= .F.
				EndIf
			EndIf

			nCol1		+= 50
			nCol2		+= 50
			nCol3		+= 50

			SZC->( DbSkip() )
		EndDo

		If	lImprime
			LI	+= 2
			@ LI, 000 PSAY "<-------- COMPRAS -------->   <------ ALMOXARIFADO ----->   <-------- CQ ITEM -------->   <---------- BF ----------->   <--------- CQ BF --------->   <- APONTAMENTO  PRODUÇÃO ->   <-------- ESTOQUE -------->"
			LI++
			@ LI, 000 PSAY "REALIZADO  PREVISTO  DESVIO   REALIZADO  PREVISTO  DESVIO   REALIZADO  PREVISTO  DESVIO   REALIZADO  PREVISTO  DESVIO   REALIZADO  PREVISTO  DESVIO   REALIZADO  PREVISTO  DESVIO   REALIZADO  PREVISTO  DESVIO"
			LI++	
		EndIf

		nCol1		:= 03
		nCol2		:= 13
		nCol3		:= 22
		nQtdDesvio	:= 0
		nDesvio		:= 0

		For nXX := 4 to 10
			nTotalDias	+= aPrevisto[ nXX ]
			If	!Empty( aDepto[ nXX ] )
				nDesvio	:= ( aRealizado[ nXX ] - aPrevisto[ nXX ] )
				If	lImprime
					@ LI, nCol1 PSAY TransForm( aRealizado[ nXX ] , "@E 999" )
					@ LI, nCol2 PSAY TransForm( aPrevisto[ nXX ] , "@E 999" )
					@ LI, nCol3 PSAY TransForm( nDesvio , "@E 999" )
				EndIf
//				nQtdDesvio	+= nDesvio
//				nQtdDesvio	+= IF( aDesvio[ nXX ] , nDesvio , 0 )
//				nQtdDesvio	+= IF( nDesvio > 0 , nDesvio , 0 )

				If	aDesvio[ nXX ] .or. nDesvio > 0
					nQtdDesvio	+= nDesvio
				EndIf

			Else
				If	lImprime
					@ LI, nCol1 PSAY "---"
					@ LI, nCol2 PSAY TransForm( aPrevisto[ nXX ] , "@E 999" )
					@ LI, nCol3 PSAY "---"
				EndIf
			EndIf
			nCol1	+= 30
			nCol2	+= 30
			nCol3	+= 30
		Next nXX

		If		!SC5->( Eof() )
			dPrazoPrevisto	:= SC5->C5_EMISSAO + nTotalDias
			dPrazoReal		:= SC5->C5_EMISSAO + nTotalDias + nQtdDesvio
		ElseIf	!SC2->( Eof() )
			dPrazoPrevisto	:= SC2->C2_EMISSAO + nTotalDias
			dPrazoReal		:= SC2->C2_EMISSAO + nTotalDias + nQtdDesvio
		Else
			dPrazoPrevisto	:= CtoD( "" )
			dPrazoReal		:= CtoD( "" )
		EndIf
		If		!SC6->( Eof() )
			nDesvioGeral	:= dPrazoReal - SC6->C6_ENTREG
		ElseIf	!SC2->( Eof() )
			nDesvioGeral	:= dPrazoReal - SC2->C2_DATPRF
		Else
			nDesvioGeral	:= 0
		EndIf

		If	lImprime
			LI	+= 2
			@ LI, 000 PSAY "PRAZO CLIENTE                    PRAZO PREVISTO                    PRAZO REAL                    DESVIO"
			LI++

			@ LI, 003 PSAY TransForm( IF( !SC6->( Eof() ) , SC6->C6_ENTREG , IF( !SC2->( Eof() ) , SC2->C2_DATPRF , CtoD( "" ) ) ) , "@E" )
			@ LI, 036 PSAY TransForm( dPrazoPrevisto , "@E" )
			@ LI, 068 PSAY TransForm( dPrazoReal , "@E" )
			If	!Empty( dPrazoReal )
				@ LI, 098 PSAY TransForm( nDesvioGeral , "@E 9999" )

				If	!Empty( cZC_OP ) .and. !TRBEXCEL->( DbSeek( cZC_OP ) )
					RecLock( "TRBEXCEL" , .T. )
					TRBEXCEL->OP		:= cZC_OP
					TRBEXCEL->DESVIO	:= nDesvioGeral
					TRBEXCEL->DEPTO		:= aStatus_Atual[1]
					TRBEXCEL->EMI_PED	:= IF( !SC5->( Eof() ) , SC5->C5_EMISSAO , IF( !SC2->( Eof() ) , SC2->C2_EMISSAO , CtoD( "" ) ) )
					TRBEXCEL->( MsUnLock() )
				EndIf

			Else
				@ LI, 098 PSAY TransForm( 0 , "@E 999" )
			EndIf
			LI	+= 2
			@ li,000 PSAY __PrtThinLine()
		EndIf

		If	;
			( mv_par07 == 1 .and. nDesvioGeral <= 0 ) .or. ;					// só pedidos atrasados
			( !Empty( mv_par08 ) .and. aStatus_Atual[2] # Upper( mv_par08 ) )	// só status atual
			Exit
		EndIf

	Next nAA

EndDo

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	ourspool(wnrel)
Endif

MS_FLUSH()

DBSelectArea("TRBEXCEL")
TRBEXCEL->( DBGoTop() )

//COPY TO "TRBEXCEL.DBF" VIA "DBFCDXADS"
__CopyFile( "TRBEXCEL.DBF" , "RELATO\" + "ROP.XLS" )

FErase( "TRBEXCEL.DBF" )

Return

********************************************************************************************************************
Static Function Status01( cZC_OP )

Local	aArea_SZC	:= SZC->( GetArea() )
Local	aDepto		:= {	"",;
							"",;
							Space( Len( SZC->ZC_NOMFOR ) ),;
							Space( Len( SZC->ZC_FORNEC ) ),;
							Space( Len( SZC->ZC_LOJAFOR ) ) }

DbSelectArea( "SZC" )
SZC->( DbSetOrder( 1 ) )
SZC->( DbSeek( xFilial( "SZC" ) + cZC_OP ) )

While !SZC->( Eof() ) .and.	SZC->ZC_FILIAL	== xFilial( "SZC" ) .and. ;
							SZC->ZC_OP		== cZC_OP
	If	!Empty( SZC->ZC_DEPTOOR )
		aDepto[1]	:= Upper( X3Combo( "ZC_DEPTOOR" , SZC->ZC_DEPTOOR ) )
		aDepto[2]	:= SZC->ZC_DEPTOOR
	EndIf

	If	!Empty( SZC->ZC_DEPTODE )
		aDepto[1]	:= Upper( X3Combo( "ZC_DEPTODE" , SZC->ZC_DEPTODE ) )
		aDepto[2]	:= SZC->ZC_DEPTODE
	Else
		If	!Empty( SZC->ZC_FORNEC )
			aDepto[3]	:= SZC->ZC_NOMFOR
			aDepto[4]	:= SZC->ZC_FORNEC
			aDepto[5]	:= SZC->ZC_LOJAFOR
		EndIf
	EndIf

	SZC->( DbSkip() )
EndDo

RestArea( aArea_SZC )

Return( aDepto )

********************************************************************************************************************
Static Function FLUPEDR02(lEnd,tamanho,wnrel,cString)

Local	cZC_OP			:= ""
Local	nCol1			:= 0
Local	nCol2			:= 0
Local	nCol3			:= 0
Local	aRealizado		:= {}
Local	aDesvio			:= {}
Local	aDepto			:= {}
Local	aPrevisto		:= {}
Local	aStatus_Atual	:= {}
Local	nTotalDias		:= 0
Local	dPrazoPrevisto	:= CtoD( "" )
Local	dPrazoReal		:= CtoD( "" )
Local	nDesvioGeral	:= 0
Local	nQtdDesvio		:= 0
Local	nDesvio			:= 0
Local	aArea_SZC

Private	LI			:= 100
Private	m_pag		:= 1

SZB->( DbSetOrder( 1 ) )
SZC->( DbSetOrder( 1 ) )
SC2->( DbSetOrder( 1 ) )
SC5->( DbSetOrder( 1 ) )
SC6->( DbSetOrder( 1 ) )
SZE->( DbSetOrder( 1 ) )

DbSelectArea( "SZB" )
SZB->( DbSetOrder( 1 ) )
SZB->( DbSeek( xFilial( "SZB" ) + mv_par03 , .T. ) )

SetRegua( SZB->( LastRec() ) )

While !SZB->( Eof() ) .and.	SZB->ZB_FILIAL	== xFilial( "SZB" ) .and. SZB->( ZB_PEDIDO + ZB_ITEMPV ) <= mv_par04

	cPEDIDO	:= SZB->( ZB_PEDIDO + ZB_ITEMPV )
	lOK		:= .T.

	If	SZB->( ZB_PEDIDO + ZB_ITEMPV ) < mv_par03 .or. SZB->( ZB_PEDIDO + ZB_ITEMPV ) > mv_par04 .or. ;
		SZB->ZB_DTENT < mv_par05 .or. SZB->ZB_DTENT > mv_par06
		lOK		:= .F.
	EndIf
	
	If	!SZC->( DbSeek( xFilial( "SZC" ) + cPEDIDO ) )
		aStatus_Atual	:= Status02( "SZB" , SZB->( ZB_PEDIDO + ZB_ITEMPV ) )
	Else
		aStatus_Atual	:= Status02( "SZC" , SZC->ZC_OP )
	EndIf

	If	!lOK .or. ;
		( aStatus_atual[2] == "Z" .and. mv_par10 == 2 ) .or. ;
		!( aStatus_Atual[4] >= mv_par11 .and. aStatus_Atual[4] <= mv_par12 )
		While !SZB->( Eof() ) .and.	SZB->ZB_FILIAL	== xFilial( "SZB" ) .and. SZB->( ZB_PEDIDO + ZB_ITEMPV ) == cPedido
			IncRegua()
			SZB->( DbSkip() )
		EndDo
		Loop
	Else
		IncRegua()
	EndIf

	aArea_SZB		:= SZB->( GetArea() )
	aArea_SZC		:= SZC->( GetArea() )
	cZC_OP			:= SZC->ZC_OP

	For nAA := 1 to IF( mv_par07 == 1 .or. !Empty( mv_par08 ) , 2 , 1 )

		If		nAA == 1					// análise
		 	If	( mv_par07 == 2 .and. Empty( mv_par08 ) )
				lImprime	:= .T.
			Else
				lImprime	:= .F.
			EndIf
		ElseIf	nAA == 2					// imprime
			lImprime	:= .T.
		EndIf

		If	nAA == 2
			RestArea( aArea_SZB )
			RestArea( aArea_SZC )
		EndIf

		SC6->( DbSeek( xFilial( "SC6" ) + cPEDIDO ) )
		SC5->( DbSeek( xFilial( "SC5" ) + Left( cPEDIDO , 6 ) ) )
		SC2->( DbSeek( xFilial( "SC2" ) + cZC_OP ) )

		If	nAA == 1
			If	SZC->( Eof() )
				aStatus_Atual	:= Status02( "SZB" , SZB->( ZB_PEDIDO + ZB_ITEMPV ) )
			Else
				aStatus_Atual	:= Status02( "SZC" , SZC->ZC_OP )
			EndIf
		EndIf

		If	lImprime

			If	LI > 55
				Cabec( titulo , cabec1 , cabec2 , nomeprog , tamanho , caracter )
			Else
				@ li,000 PSAY __PrtThinLine()
				LI++
			EndIf

			@ LI, 000 PSAY "Nº PEDIDO: " + TransForm( SZB->( ZB_PEDIDO + ZB_ITEMPV ) , "@R XXXXXX-XX" )
			@ LI, 027 PSAY "CLIENTE: " + TransForm( SZB->( ZB_CLIENTE + ZB_LOJACLI ) , "@R XXXXXX-XX" ) + " - " + SZB->ZB_NOMCLI
			@ LI, 078 PSAY "PRODUTO: " + SZC->ZC_PRODUTO
			@ LI, 112 PSAY "CÓD.LMT: " + SZC->ZC_CODLMT
			@ LI, 177 PSAY "Nº OP: " + TransForm( SZC->ZC_OP , "@R XXXXXX-XX-XXX" )
			LI	+= 2
			@ LI, 000 PSAY "<--------- VENDAS ---------->                    <------- ENGENHARIA -------->                    <----------- PCP ----------->"
			@ LI, 160 PSAY "* STATUS ATUAL: " + aStatus_Atual[1]
			LI++
			@ LI, 000 PSAY "ENTRADA   SAÍDA     REALIZADO                    ENTRADA   SAÍDA     REALIZADO                    ENTRADA   SAÍDA     REALIZADO"
			@ LI, 160 PSAY IF( !Empty( aStatus_Atual[3] ) , "* FORNECEDOR  : " + AllTrim( aStatus_Atual[3] ) + " / " + aStatus_Atual[4] + "-" + aStatus_Atual[5] , "" )
	
			LI++
		EndIf

		nCol1	:= 00
		nCol2	:= 10
		nCol3	:= 23

		aRealizado	:= {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
		aDesvio		:= {.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.}
		aDepto		:= {"","","","","","","","","","","","","","","","","","","",""}
		aPrevisto	:= {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
		nTotalDias	:= 0
		dPrazoReal	:= CtoD( "" )

		While !SZB->( Eof() ) .and. SZB->ZB_FILIAL == xFilial( "SZB" ) .and. SZB->( ZB_PEDIDO + ZB_ITEMPV ) == cPEDIDO

			If		SZB->ZB_DEPTOOR == "1"				// Vendas
				If	lImprime
					@ LI, nCol1 PSAY TransForm( SZB->ZB_DTENT , "@E" )
					@ LI, nCol2 PSAY TransForm( SZB->ZB_DTSAI , "@E" )
				EndIf
				If	!Empty( SZB->ZB_DTSAI )
					If	lImprime
						@ LI, nCol3 PSAY TransForm( SZB->( ZB_DTSAI - ZB_DTENT ) , "@E 999" )
					EndIf
					nTotalDias	+= SZB->( ZB_DTSAI - ZB_DTENT )
				Else
					If	lImprime
						@ LI, nCol3 PSAY TransForm( Date() - SZB->ZB_DTENT , "@E 999" )
					EndIf
					nTotalDias	+= Date() - SZB->ZB_DTENT
				EndIf
			ElseIf	SZB->ZB_DEPTOOR == "2"				// Engenharia
				If	lImprime
					@ LI, nCol1 PSAY TransForm( SZB->ZB_DTENT , "@E" )
					@ LI, nCol2 PSAY TransForm( SZB->ZB_DTSAI , "@E" )
				EndIf
				If	!Empty( SZB->ZB_DTSAI )
					If	lImprime
						@ LI, nCol3 PSAY TransForm( SZB->( ZB_DTSAI - ZB_DTENT ) , "@E 999" )
					EndIf
					nTotalDias	+= SZB->( ZB_DTSAI - ZB_DTENT )
				Else
					If	lImprime
						@ LI, nCol3 PSAY TransForm( Date() - SZB->ZB_DTENT , "@E 999" )
					EndIf
					nTotalDias	+= Date() - SZB->ZB_DTENT
				EndIf
			EndIf
			nCol1		+= 49
			nCol2		+= 49
			nCol3		+= 49

			SZB->( DbSkip() )
		EndDo

		SZE->( DbSeek( xFilial( "SZE" ) + cZC_OP ) )
		While !SZE->( Eof() ) .and. SZE->ZE_FILIAL == xFilial( "SZE" ) .and. SZE->ZE_OP == cZC_OP
			If	Val(SZE->ZE_DEPTO) >= 1 .and. Val(SZE->ZE_DEPTO) <= 9
				aPrevisto[Val(SZE->ZE_DEPTO)]		:= SZE->ZE_NRDIAS
			Else
				aPrevisto[Asc(SZE->ZE_DEPTO)-55]	:= SZE->ZE_NRDIAS
			EndIf
			SZE->( DbSkip() )
		EndDo

		nCol1	:= 098
		nCol2	:= 108
		nCol3	:= 121

		While !SZC->( Eof() ) .and. SZC->ZC_FILIAL == xFilial( "SZC" ) .and. SZC->ZC_OP == cZC_OP

			If	SZC->ZC_DEPTOOR == "3"					// PCP
				If	lImprime
					@ LI, nCol1 PSAY TransForm( SZC->ZC_DTENT , "@E" )
					@ LI, nCol2 PSAY TransForm( SZC->ZC_DTSAI , "@E" )
				EndIf
				If	!Empty( SZC->ZC_DTSAI )
					If	lImprime
						@ LI, nCol3 PSAY TransForm( SZC->( ZC_DTSAI - ZC_DTENT ) , "@E 999" )
					EndIf
					nTotalDias	+= SZC->( ZC_DTSAI - ZC_DTENT )
				Else
					If	lImprime
						@ LI, nCol3 PSAY TransForm( Date() - SZC->ZC_DTENT , "@E 999" )
					EndIf
					nTotalDias	+= Date() - SZC->ZC_DTENT
				EndIf
			ElseIf	Val(SZC->ZC_DEPTOOR) >= 1 .and. Val(SZC->ZC_DEPTOOR) <= 9
				If	!Empty( SZC->ZC_DTSAI )
					aRealizado[Val(SZC->ZC_DEPTOOR)]	+= SZC->( ZC_DTSAI - ZC_DTENT )
					aDepto[Val(SZC->ZC_DEPTOOR)]		:= SZC->ZC_DEPTOOR
					aDesvio[Val(SZC->ZC_DEPTOOR)]		:= .T.
				Else
					aRealizado[Val(SZC->ZC_DEPTOOR)]	+= Date() - SZC->ZC_DTENT
					aDepto[Val(SZC->ZC_DEPTOOR)]		:= SZC->ZC_DEPTOOR
					aDesvio[Val(SZC->ZC_DEPTOOR)]		:= .F.
				EndIf
			Else
				If	!Empty( SZC->ZC_DTSAI )
					aRealizado[Asc(SZC->ZC_DEPTOOR)-55]	+= SZC->( ZC_DTSAI - ZC_DTENT )
					aDepto[Asc(SZC->ZC_DEPTOOR)-55]		:= SZC->ZC_DEPTOOR
					aDesvio[Asc(SZC->ZC_DEPTOOR)-55]	:= .T.
				Else
					aRealizado[Asc(SZC->ZC_DEPTOOR)-55]	+= Date() - SZC->ZC_DTENT
					aDepto[Asc(SZC->ZC_DEPTOOR)-55]		:= SZC->ZC_DEPTOOR
					aDesvio[Asc(SZC->ZC_DEPTOOR)-55]	:= .F.
				EndIf
			EndIf

			nCol1		+= 50
			nCol2		+= 50
			nCol3		+= 50

			SZC->( DbSkip() )
		EndDo

		If	lImprime
			LI	+= 2
			@ LI, 000 PSAY "<-------- COMPRAS -------->   <------ ALMOXARIFADO ----->   <-------- CQ ITEM -------->   <---------- BF ----------->   <--------- CQ BF --------->   <- APONTAMENTO  PRODUÇÃO ->   <-------- ESTOQUE -------->"
			LI++
			@ LI, 000 PSAY "REALIZADO  PREVISTO  DESVIO   REALIZADO  PREVISTO  DESVIO   REALIZADO  PREVISTO  DESVIO   REALIZADO  PREVISTO  DESVIO   REALIZADO  PREVISTO  DESVIO   REALIZADO  PREVISTO  DESVIO   REALIZADO  PREVISTO  DESVIO"
			LI++	
		EndIf

		nCol1		:= 3
		nCol2		:= 13
		nCol3		:= 22
		nQtdDesvio	:= 0
		nDesvio		:= 0

		For nXX := 4 to 10
			nTotalDias	+= aPrevisto[ nXX ]
			If	!Empty( aDepto[ nXX ] )
				nDesvio	:= ( aRealizado[ nXX ] - aPrevisto[ nXX ] )
				If	lImprime
					@ LI, nCol1 PSAY TransForm( aRealizado[ nXX ] , "@E 999" )
					@ LI, nCol2 PSAY TransForm( aPrevisto[ nXX ] , "@E 999" )
					@ LI, nCol3 PSAY TransForm( nDesvio , "@E 999" )
				EndIf
//				nQtdDesvio	+= nDesvio
//				nQtdDesvio	+= IF( aDesvio[ nXX ] , nDesvio , 0 )
//				nQtdDesvio	+= IF( nDesvio > 0 , nDesvio , 0 )

				If	aDesvio[ nXX ] .or. nDesvio > 0
					nQtdDesvio	+= nDesvio
				EndIf

			Else
				If	lImprime
					@ LI, nCol1 PSAY "---"
					@ LI, nCol2 PSAY TransForm( aPrevisto[ nXX ] , "@E 999" )
					@ LI, nCol3 PSAY "---"
				EndIf
			EndIf
			nCol1	+= 30
			nCol2	+= 30
			nCol3	+= 30
		Next nXX

		If		!SC5->( Eof() )
			dPrazoPrevisto	:= SC5->C5_EMISSAO + nTotalDias
			dPrazoReal		:= SC5->C5_EMISSAO + nTotalDias + nQtdDesvio
		ElseIf	!SC2->( Eof() )
			dPrazoPrevisto	:= SC2->C2_EMISSAO + nTotalDias
			dPrazoReal		:= SC2->C2_EMISSAO + nTotalDias + nQtdDesvio
		Else
			dPrazoPrevisto	:= CtoD( "" )
			dPrazoReal		:= CtoD( "" )
		EndIf

		If		!SC6->( Eof() )
			nDesvioGeral	:= dPrazoReal - SC6->C6_ENTREG
		ElseIf	!SC2->( Eof() )
			nDesvioGeral	:= dPrazoReal - SC2->C2_DATPRF
		Else
			nDesvioGeral	:= 0
		EndIf

		If	lImprime
			LI	+= 2
			@ LI, 000 PSAY "PRAZO CLIENTE                    PRAZO PREVISTO                    PRAZO REAL                    DESVIO"
			LI++

			@ LI, 003 PSAY TransForm( IF( !SC6->( Eof() ) , SC6->C6_ENTREG , IF( !SC2->( Eof() ) , SC2->C2_DATPRF , CtoD( "" ) ) ) , "@E" )
			@ LI, 036 PSAY TransForm( dPrazoPrevisto , "@E" )
			@ LI, 068 PSAY TransForm( dPrazoReal , "@E" )
			If	!Empty( dPrazoReal )
				@ LI, 098 PSAY TransForm( nDesvioGeral , "@E 9999" )

				If	!Empty( cZC_OP ) .and. !TRBEXCEL->( DbSeek( cZC_OP ) )
					RecLock( "TRBEXCEL" , .T. )
					TRBEXCEL->OP		:= cZC_OP
					TRBEXCEL->DESVIO	:= nDesvioGeral
					TRBEXCEL->DEPTO		:= aStatus_Atual[1]
					TRBEXCEL->EMI_PED	:= IF( !SC5->( Eof() ) , SC5->C5_EMISSAO , IF( !SC2->( Eof() ) , SC2->C2_EMISSAO , CtoD( "" ) ) )
					TRBEXCEL->( MsUnLock() )
				EndIf

			Else
				@ LI, 098 PSAY TransForm( 0 , "@E 999" )
			EndIf
			LI	+= 2
			@ li,000 PSAY __PrtThinLine()
		EndIf

		If	;
			( mv_par07 == 1 .and. nDesvioGeral <= 0 ) .or. ;					// só pedidos atrasados
			( !Empty( mv_par08 ) .and. aStatus_Atual[2] # Upper( mv_par08 ) )	// só status atual
			Exit
		EndIf

	Next nAA

EndDo

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	ourspool(wnrel)
Endif

MS_FLUSH()

DBSelectArea("TRBEXCEL")
TRBEXCEL->( DBGoTop() )

//COPY TO "TRBEXCEL.DBF" VIA "DBFCDXADS"
__CopyFile( "TRBEXCEL.DBF" , "RELATO\" + "RPED.XLS" )

FErase( "TRBEXCEL.DBF" )

Return

********************************************************************************************************************
Static Function Status02( cAlias , cChave )

Local	aArea_SZB	:= SZB->( GetArea() )
Local	aArea_SZC	:= SZC->( GetArea() )
Local	aDepto		:= {	"",;
							"",;
							Space( Len( SZC->ZC_NOMFOR ) ),;
							Space( Len( SZC->ZC_FORNEC ) ),;
							Space( Len( SZC->ZC_LOJAFOR ) ) }

If	cAlias == "SZB"
	DbSelectArea( "SZB" )
	SZB->( DbSetOrder( 1 ) )
	SZB->( DbSeek( xFilial( "SZB" ) + cChave ) )

	While !SZB->( Eof() ) .and.	SZB->ZB_FILIAL	== xFilial( "SZB" ) .and. SZB->( ZB_PEDIDO + ZB_ITEMPV ) == cChave

		If	!Empty( SZB->ZB_DEPTOOR )
			aDepto[1]	:= Upper( X3Combo( "ZB_DEPTOOR" , SZB->ZB_DEPTOOR ) )
			aDepto[2]	:= SZB->ZB_DEPTOOR
		EndIf

		If	!Empty( SZB->ZB_DEPTODE )
			aDepto[1]	:= Upper( X3Combo( "ZB_DEPTODE" , SZB->ZB_DEPTODE ) )
			aDepto[2]	:= SZB->ZB_DEPTODE
		Else
			If	!Empty( SZB->ZB_FORNEC )
				aDepto[3]	:= SZB->ZB_NOMFOR
				aDepto[4]	:= SZB->ZB_FORNEC
				aDepto[5]	:= SZB->ZB_LOJAFOR
			EndIf
		EndIf

		SZB->( DbSkip() )
	EndDo

Else

	DbSelectArea( "SZC" )
	SZC->( DbSetOrder( 1 ) )
	SZC->( DbSeek( xFilial( "SZC" ) + cChave ) )

	While !SZC->( Eof() ) .and.	SZC->ZC_FILIAL	== xFilial( "SZC" ) .and. SZC->ZC_OP == cChave

		If	!Empty( SZC->ZC_DEPTOOR )
			aDepto[1]	:= Upper( X3Combo( "ZC_DEPTOOR" , SZC->ZC_DEPTOOR ) )
			aDepto[2]	:= SZC->ZC_DEPTOOR
		EndIf

		If	!Empty( SZC->ZC_DEPTODE )
			aDepto[1]	:= Upper( X3Combo( "ZC_DEPTODE" , SZC->ZC_DEPTODE ) )
			aDepto[2]	:= SZC->ZC_DEPTODE
		Else
			If	!Empty( SZC->ZC_FORNEC )
				aDepto[3]	:= SZC->ZC_NOMFOR
				aDepto[4]	:= SZC->ZC_FORNEC
				aDepto[5]	:= SZC->ZC_LOJAFOR
			EndIf
		EndIf

		SZC->( DbSkip() )

	EndDo

EndIf

RestArea( aArea_SZB )
RestArea( aArea_SZC )

Return( aDepto )

********************************************************************************************************************
Static Function AjustaSX1()
Local	aPerg    := {}

aAdd( aPerg , { "Da  Op                    ?" , "C" , 11 , 00 , "G" , "" , "" , "" , "" , "" , "SZC" } )
aAdd( aPerg , { "Até Op                    ?" , "C" , 11 , 00 , "G" , "" , "" , "" , "" , "" , "SZC" } )
aAdd( aPerg , { "Do  Pedido                ?" , "C" , 08 , 00 , "G" , "" , "" , "" , "" , "" , "SZB" } )
aAdd( aPerg , { "Até Pedido                ?" , "C" , 08 , 00 , "G" , "" , "" , "" , "" , "" , "SZB" } )
aAdd( aPerg , { "Da  Data                  ?" , "D" , 08 , 00 , "G" , "" , "" , "" , "" , "" , "" } )
aAdd( aPerg , { "Até Data                  ?" , "D" , 08 , 00 , "G" , "" , "" , "" , "" , "" , "" } )
aAdd( aPerg , { "Só pedidos atrasados      ?" , "N" , 01 , 00 , "C" , "Sim" , "Não", "" , "" , "" , "" } )
aAdd( aPerg , { "Status                    ?" , "C" , 01 , 00 , "G" , "" , "" , "" , "" , "" , "Z8" } )
aAdd( aPerg , { "Relatório de              ?" , "N" , 01 , 00 , "C" , "Op´s" , "Pedidos", "" , "" , "" , "" } )
aAdd( aPerg , { "Considera Op´s Finalizadas?" , "N" , 01 , 00 , "C" , "Sim" , "Não", "" , "" , "" , "" } )
aAdd( aPerg , { "Do  Fornecedor            ?" , "C" , 06 , 00 , "G" , "" , "" , "" , "" , "" , "SA2" } )
aAdd( aPerg , { "Até Fornecedor            ?" , "C" , 06 , 00 , "G" , "" , "" , "" , "" , "" , "SA2" } )

For nXX := 1 to Len( aPerg )
	If !SX1->( DbSeek( cPerg + StrZero( nXX , 2 ) ) )
		RecLock( "SX1" , .T. )
		SX1->X1_GRUPO	:= cPerg
		SX1->X1_ORDEM	:= StrZero( nXX , 2 )
		SX1->X1_VARIAVL	:= "mv_ch"  + Chr( nXX + 96 )
		SX1->X1_VAR01	:= "mv_par" + Strzero( nXX , 2 )
		SX1->X1_PRESEL	:= 1
		SX1->X1_PERGUNT	:= aPerg[ nXX , 01 ]
		SX1->X1_TIPO	:= aPerg[ nXX , 02 ]
		SX1->X1_TAMANHO	:= aPerg[ nXX , 03 ]
		SX1->X1_DECIMAL	:= aPerg[ nXX , 04 ]
		SX1->X1_GSC		:= aPerg[ nXX , 05 ]
		SX1->X1_DEF01	:= aPerg[ nXX , 06 ]
		SX1->X1_DEF02	:= aPerg[ nXX , 07 ]
		SX1->X1_DEF03	:= aPerg[ nXX , 08 ]
		SX1->X1_DEF04	:= aPerg[ nXX , 09 ]
		SX1->X1_DEF05	:= aPerg[ nXX , 10 ]
		SX1->X1_F3		:= aPerg[ nXX , 11 ]
		SX1->( MsUnlock() )
	EndIf
Next nXX

Return
