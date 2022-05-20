#INCLUDE "rwmake.ch"
                                                        
// Rotina		: FATMENS
// Descrição	: Faturamento Mensal
// Data			: 29/01/05
// Autor        : Daniel Gondran

User Function FATMENS()

// mv_par01 - Mes
// mv_par02 - Ano
// mv_par03 - Tipo de relatório : Detalhes / Resumo
// mv_par04 - TES quanto ao faturamento
// mv_par05 - TES quanto ao estoque
// mv_par06 - Ignora CFOPs
// mv_par07 - Inclui CFOPs

//cPerg := "FATMEN    "
cPerg    := PadR( 'FATMEN' , Len( SX1->X1_GRUPO ) )
AjustaSX1()
Pergunte(cPerg,.F.)

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Faturamento Mensal"
@ 70,080 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
@ 70,118 BMPBUTTON TYPE 1 ACTION OkProc()
@ 70,156 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
@ 23,14 SAY " " size 200,10
@ 33,14 SAY "" size 200,10
@ 43,14 SAY ""
@ 8,10 TO 060,180
ACTIVATE DIALOG oDlg5 CENTERED

Return

Static Function OkProc()
Close(oDlg5)

Processa( {|| Runproc() } , "Gerando Arquivo" )

Return

//*******************************************************************************( INICIO )
STATIC FUNCTION Runproc()

Local _nX
Local cDetal := ""

aStru := {}
aAdd(aStru,{"OGRUPO"     ,"C",01,0})
aAdd(aStru,{"GRUPO"      ,"C",20,0})
aAdd(aStru,{"EMISSAO"    ,"D",08,0})
aAdd(aStru,{"VENDEDOR"   ,"C",20,0})
aAdd(aStru,{"VEND2"      ,"C",20,0})
aAdd(aStru,{"NUMERO"     ,"C",10,0})
aAdd(aStru,{"CLIENTE"    ,"C",20,0})
aAdd(aStru,{"VALBRUT"    ,"N",16,2})
aAdd(aStru,{"VALMERC"    ,"N",16,2})
aAdd(aStru,{"ICMS"       ,"N",16,2})
aAdd(aStru,{"IPI"        ,"N",16,2})
aAdd(aStru,{"PIS"        ,"N",16,2})
aAdd(aStru,{"COFINS"     ,"N",16,2})
aAdd(aStru,{"FATLIQ"     ,"N",16,2})
aAdd(aStru,{"ANO"        ,"C",04,0})
aAdd(aStru,{"MES"        ,"C",02,0})
aAdd(aStru,{"CFO"        ,"C",04,0})
aAdd(aStru,{"ICMSRET"     ,"N",16,2})
aAdd(aStru,{"DIFAL"      ,"N",16,2})
aAdd(aStru,{"ICMSCOM"    ,"N",16,2})

	oTempTable := FWTemporaryTable():New( "TRB" )
	
	oTemptable:SetFields( aStru )
	oTempTable:AddIndex("indice1", {"OGRUPO","NUMERO"} )
	//------------------
	//Criação da tabela
	//------------------
	oTempTable:Create()

/*cArq := CriaTrab(aStru,.T.)
dbUseArea(.T.,,cArq,"TRB",.T.)
cInd := CriaTrab(NIL,.F.)
IndRegua("TRB",cInd,"OGRUPO+NUMERO",,,"Selecionando Registros...")*/

aEmps 	 := {"BO","FE","KI","ON","NI","XX","BR","BI","MT"}
aEmpresa := {"BOEHLERIT","FETTE","KIENINGER","ONSRUD","NIPPON","XX","FABR.BRASIL","BILZ","MORRIS TOOLING"}

Set SoftSeek On

If mv_par03 == 1
	cGrupo  := "FATURAMENTO"
	coGrupo := "1"
	dbselectarea("SD2")
//	dbSetOrder(3)														// wilson - 20/05
	ProcRegua(LastRec())
//	dbGotop()															// wilson - 20/05
	SD2->( DbSetOrder( 5 ) )											// wilson - 20/05
	SD2->( DbSeek( xFilial( "SD2" ) + ;									// wilson - 20/05
					StrZero( Val( mv_par02 ) , 4 ) +;
					StrZero( Val( mv_par01 ) , 2 ) ) )
//	DO WHILE !EOF() .AND. D2_FILIAL == xFilial("SD2")					// wilson - 20/05
	DO WHILE !EOF() .AND.	D2_FILIAL == xFilial("SD2") .and. ;			// wilson - 20/05
							Year(D2_EMISSAO) == Val(mv_par02) .and. ;
							Month(D2_EMISSAO) == Val(mv_par01)
		IncProc( "Processando vendas dia » " + DtoC( D2_EMISSAO ) )
		If Month(D2_EMISSAO) == Val(mv_par01) .AND. Year(D2_EMISSAO) == Val(mv_par02)
			dbSelectArea("SF4")
			dbSetOrder(1)
			dbSeek(xFilial("SF4") + SD2->D2_TES)
//			If (F4_DUPLIC == "N" .and. mv_par04 == 1) .or. (F4_DUPLIC == "S" .and. mv_par04 == 2) .or. F4_CF $ mv_par06 .or. SD2->D2_TIPO == "D"
			If (F4_DUPLIC == "N" .and. mv_par04 == 1) .or. (F4_DUPLIC == "S" .and. mv_par04 == 2) .or. AllTrim(SD2->D2_CF) $ mv_par06 .or. SD2->D2_TIPO == "D"
				dbSelectArea("SD2")
				dbSkip()
				Loop
			Endif
			If (F4_ESTOQUE == "N" .and. mv_par05 == 1) .or. (F4_ESTOQUE == "S" .and. mv_par05 == 2)
				dbSelectArea("SD2")
				dbSkip()
				Loop
			Endif
			If !Empty(mv_par07) .and. !(AllTrim(SD2->D2_CF) $ mv_par07)
				dbSelectArea("SD2")
				dbSkip()
				Loop
			Endif
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(xFilial("SA1") + SD2->D2_CLIENTE + SD2->D2_LOJA)
			
//			dbSelectArea("SC5")
//			dbSetOrder(1)
//			dbSeek(xFilial("SC5") + SD2->D2_PEDIDO)

			dbSelectArea("SF2")
			dbSetOrder(1)
			dbSeek(xFilial("SF2") + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA)
			
			dbSelectArea("SA3")
			dbSetOrder(1)
			dbSeek(xFilial("SA3") + SF2->F2_VEND1)			
			
			cVend 	 := A3_NREDUZ
			dbSelectArea("SF2")
			// Tratamento para o 000009 - Paulo e o 000010 - Rogerio (70/30)
			lDoisV := .F.
			nPerc1 := 100
			nPerc2 := 100
			If !Empty(F2_VEND2)
				lDoisV := .T.
				dbSelectArea("SA3")
				dbSetOrder(1)
				dbSeek(xFilial("SA3") + SF2->F2_VEND2)
				mCampo2 := A3_NREDUZ
				cVend2  := A3_NREDUZ
				dbSelectArea("SF2")
				If F2_VEND1 == "000009"
					nPerc1 := 70
				ElseIf F2_VEND1 $ "000010/000026"
					nPerc1 := 30
				ElseIf F2_VEND1 == "000016"
					nPerc1 := 70
				ElseIf F2_VEND1 $ "000005/000008"
					nPerc1 := 50
				Endif
				If F2_VEND2 == "000009"
					nPerc2 := 70
				ElseIf F2_VEND2 $ "000010/000026"
					nPerc2 := 30
				ElseIf F2_VEND2 == "000016"
					nPerc2 := 70
				ElseIf F2_VEND2 $ "000005/000008"
					nPerc2 := 50
				Endif
			Endif

			dbSelectArea("TRB")
			lAchou := dbSeek(coGrupo + SD2->D2_DOC+"-"+SD2->D2_SERIE)
			RecLock( "TRB" , !lAchou)
			OGRUPO 		:= coGrupo
			GRUPO		:= cGrupo
			EMISSAO		:= SD2->D2_EMISSAO
			NUMERO		:= SD2->D2_DOC+"-"+SD2->D2_SERIE
			CLIENTE		:= SA1->A1_NREDUZ
			VALBRUT		+= (SD2->D2_TOTAL + IIF(SD2->D2_TIPO == "N" ,SD2->D2_VALIPI,0) + SD2->D2_VALFRE)+ SD2->D2_SEGURO + SD2->D2_ICMSRET * (nPerc1 / 100)            // + SD2->D2_DESPESA + SD2->D2_SEGURO
			VALMERC		+= (SD2->D2_TOTAL+SD2->D2_VALFRE) * (nPerc1 / 100)
			ICMS		+= (SD2->D2_VALICM) * (nPerc1 / 100)
			IPI			+= (SD2->D2_VALIPI) * (nPerc1 / 100)
			PIS			+= (IF(SF4->F4_PISCRED=="2",SD2->D2_VALIMP6,0)) * (nPerc1 / 100)
			COFINS		+= (IF(SF4->F4_PISCRED=="2",SD2->D2_VALIMP5,0)) * (nPerc1 / 100)
//			FATLIQ		+= (SD2->D2_TOTAL + SD2->D2_VALIPI - (SD2->D2_VALICM + SD2->D2_VALIPI + SD2->D2_VALIMP5 + SD2->D2_VALIMP6)) * (nPerc1 / 100)
			FATLIQ		+= (SD2->D2_TOTAL + SD2->D2_VALFRE + SD2->D2_DESPESA + SD2->D2_SEGURO - SD2->D2_VALICM - SD2->D2_VALIMP1 - SD2->D2_VALIMP2 - SD2->D2_VALIMP3 - SD2->D2_VALIMP4 - IF(SF4->F4_PISCRED=="2",SD2->D2_VALIMP5,0) - IF(SF4->F4_PISCRED=="2",SD2->D2_VALIMP6,0)- SD2->D2_DIFAL - SD2->D2_ICMSCOM ) * (nPerc1 / 100)
			ANO			:= mv_par02
			MES			:= mv_par01
			CFO			:= SD2->D2_CF
			VENDEDOR	:= cVend    
			ICMSRET		+= (SD2->D2_ICMSRET) * (nPerc1 / 100)
            DIFAL		+= (SD2->D2_DIFAL) * (nPerc1 / 100)			
            ICMSCOM		+= (SD2->D2_ICMSCOM) * (nPerc1 / 100)
//			If lDoisV
//				VEND2		:= cVend2
//			Endif
			TRB->( MsUnLock() )
			If lDoisV
				RecLock( "TRB" , .T.)
				OGRUPO 		:= coGrupo
				GRUPO		:= cGrupo
				EMISSAO		:= SD2->D2_EMISSAO
				NUMERO		:= SD2->D2_DOC+"-"+SD2->D2_SERIE
				CLIENTE		:= SA1->A1_NREDUZ
				VALBRUT		+= (SD2->D2_TOTAL + IIF(SD2->D2_TIPO == "N" ,SD2->D2_VALIPI,0) + SD2->D2_VALFRE) + SD2->D2_SEGURO + SD2->D2_ICMSRET * (nPerc2 / 100)            // + SD2->D2_DESPESA + SD2->D2_SEGURO
				VALMERC		+= (SD2->D2_TOTAL + SD2->D2_VALFRE) * (nPerc2 / 100)
				ICMS		+= (SD2->D2_VALICM) * (nPerc2 / 100)
				IPI			+= (SD2->D2_VALIPI) * (nPerc2 / 100)
				PIS			+= (IF(SF4->F4_PISCRED=="2",SD2->D2_VALIMP6,0)) * (nPerc2 / 100)
				COFINS		+= (IF(SF4->F4_PISCRED=="2",SD2->D2_VALIMP5,0)) * (nPerc2 / 100)
//				FATLIQ		+= (SD2->D2_TOTAL + SD2->D2_VALIPI - (SD2->D2_VALICM + SD2->D2_VALIPI + SD2->D2_VALIMP5 + SD2->D2_VALIMP6)) * (nPerc2 / 100)
				FATLIQ		+= (SD2->D2_TOTAL +SD2->D2_VALFRE + SD2->D2_DESPESA + SD2->D2_SEGURO - SD2->D2_VALICM - SD2->D2_VALIMP1 - SD2->D2_VALIMP2 - SD2->D2_VALIMP3 - SD2->D2_VALIMP4 - IF(SF4->F4_PISCRED=="2",SD2->D2_VALIMP5,0) - IF(SF4->F4_PISCRED=="2",SD2->D2_VALIMP6,0) - SD2->D2_DIFAL - SD2->D2_ICMSCOM ) * (nPerc2 / 100)
				ANO			:= mv_par02
				MES			:= mv_par01
				CFO			:= SD2->D2_CF
				VENDEDOR	:= cVend2
//				VEND2		:= cVend
	            ICMSRET		+= (SD2->D2_ICMSRET) * (nPerc2 / 100)
	            DIFAL		+= (SD2->D2_DIFAL) * (nPerc2 / 100)			
                ICMSCOM		+= (SD2->D2_ICMSCOM) * (nPerc2 / 100)
                
				TRB->( MsUnLock() )
			Endif
		Endif
		dbSelectArea("SD2")
		dbSkip()
	Enddo
	
	cGrupo  := "DEVOLUCOES "
	coGrupo := "2"
	dbselectarea("SD1")
	SD1->( DbSetOrder( 1 ) )											// wilson - 20/05	
//	dbSetOrder(1)														// wilson - 20/05
	ProcRegua(LastRec())
//	dbGotop()															// wilson - 20/05
	SD1->( DbSetOrder( 6 ) )											// wilson - 20/05
	SD1->( DbSeek( xFilial( "SD1" ) +;									// wilson - 20/05
					StrZero( Val( mv_par02 ) , 4 ) +;
					StrZero( Val( mv_par01 ) , 2 ) ) )
//	DO WHILE !EOF() .AND. D1_FILIAL == xFilial("SD1")					// wilson - 20/05
	DO WHILE !EOF() .AND.	D1_FILIAL == xFilial("SD1") .and. ;			// wilson - 20/05
							Year( D1_DTDIGIT ) == Val(mv_par02) .and. ;	
							Month(D1_DTDIGIT) == Val(mv_par01)
		IncProc( "Processando dev.vendas dia » " + DtoC( D1_DTDIGIT ) )
		If Month(D1_DTDIGIT) == Val(mv_par01) .AND. Year(D1_DTDIGIT) == Val(mv_par02) .AND. D1_TIPO == "D"
			dbSelectArea("SF4")
			dbSetOrder(1)
			dbSeek(xFilial("SF4") + SD1->D1_TES)
//			If (F4_DUPLIC == "N" .and. mv_par04 == 1) .or. (F4_DUPLIC == "S" .and. mv_par04 == 2) .or. F4_CF $ mv_par06
			If (F4_DUPLIC == "N" .and. mv_par04 == 1) .or. (F4_DUPLIC == "S" .and. mv_par04 == 2) .or. AllTrim(SD1->D1_CF) $ mv_par06
				dbSelectArea("SD1")
				dbSkip()
				Loop
			Endif
			If (F4_ESTOQUE == "N" .and. mv_par05 == 1) .or. (F4_ESTOQUE == "S" .and. mv_par05 == 2)
				dbSelectArea("SD1")
				dbSkip()
				Loop
			Endif
			If !Empty(mv_par07) .and. !(AllTrim(SD1->D1_CF) $ mv_par07)
				dbSelectArea("SD1")
				dbSkip()
				Loop
			Endif
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(xFilial("SA1") + SD1->D1_FORNECE + SD1->D1_LOJA)
			
			dbSelectarea("SD2")
			dbSetOrder(3)
			If dbSeek(xFilial("SD2") + SD1->D1_NFORI + SD1->D1_SERIORI)
				dbSelectArea("SC5")
				dbSetOrder(1)
				dbSeek(xFilial("SC5") + SD2->D2_PEDIDO)
				cVend	:= C5_NOMEVEN
				cVendx  := C5_VEND2
				cVendy  := C5_VEND1
			Else
				dbSelectArea("SA3")
				dbSetOrder(1)
				dbSeek(xFilial("SA3") + SA1->A1_VEND)
				cVend 	 := A3_NREDUZ
				cVendx   := SA1->A1_VEND2
				cVendy   := SA1->A1_VEND
			Endif
			

			// Tratamento para o 000009 - Paulo e o 000010 - Rogerio (70/30)
			lDoisV := .F.
			nPerc1 := 100
			nPerc2 := 100
			If !Empty(cVendx)
				lDoisV := .T.
				dbSelectArea("SA3")
				dbSetOrder(1)
				dbSeek(xFilial("SA3") + cVendx)
				mCampo2 := A3_NREDUZ
				cVend2  := A3_NREDUZ
				dbSelectArea("SA1")
				If cVendy == "000009"
					nPerc1 := 70
				ElseIf cVendy $ "000010/000026"
					nPerc1 := 30
				ElseIf cVendy == "000016"
					nPerc1 := 70
				ElseIf cVendy $ "000005/000008"
					nPerc1 := 50
				Endif
				If cVendx == "000009"
					nPerc2 := 70
				ElseIf cVendx $ "000010/000026"
					nPerc2 := 30
				ElseIf cVendy == "000016"
					nPerc2 := 70
				ElseIf cVendx $ "000005/000008"
					nPerc2 := 50
				Endif
			Endif

			dbSelectArea("TRB")
			lAchou := dbSeek(coGrupo + SD1->D1_DOC+"-"+SD1->D1_SERIE)
			RecLock( "TRB" , !lAchou)
			OGRUPO 		:= coGrupo
			GRUPO		:= cGrupo
			EMISSAO		:= SD1->D1_DTDIGIT
			NUMERO		:= SD1->D1_DOC+"-"+SD1->D1_SERIE
			CLIENTE		:= SA1->A1_NREDUZ
			VALBRUT		+= (SD1->D1_TOTAL + SD1->D1_VALIPI + SD1->D1_VALFRE + SD1->D1_DESPESA + SD1->D1_SEGURO + SD1->D1_ICMSRET - SD1->D1_VALDESC) * (-1) * (nPerc1 / 100)
			VALMERC		+= SD1->D1_TOTAL - SD1->D1_VALDESC * (-1) * (nPerc1 / 100)
			ICMS		+= SD1->D1_VALICM  * (-1) * (nPerc1 / 100)
			IPI			+= SD1->D1_VALIPI  * (-1) * (nPerc1 / 100)
			PIS			+= IF(SF4->F4_PISCRED=="1",SD1->D1_VALIMP6,0) * (-1) * (nPerc1 / 100)
			COFINS		+= IF(SF4->F4_PISCRED=="1",SD1->D1_VALIMP5,0) * (-1) * (nPerc1 / 100)
//			FATLIQ		+= ((SD1->D1_TOTAL + SD1->D1_VALIPI + SD1->D1_VALFRE + SD1->D1_DESPESA + SD1->D1_SEGURO) - (SD1->D1_VALICM + SD1->D1_VALIPI + SD1->D1_VALIMP5 + SD1->D1_VALIMP6)) * (-1) * (nPerc1 / 100)
			FATLIQ		+= ((SD1->D1_TOTAL + SD1->D1_VALFRE + SD1->D1_DESPESA + SD1->D1_SEGURO - SD1->D1_VALDESC - SD1->D1_VALICM - SD1->D1_VALIMP1 - SD1->D1_VALIMP2 - SD1->D1_VALIMP3 - SD1->D1_VALIMP4 - IF(SF4->F4_PISCRED=="1",SD1->D1_VALIMP5,0) - IF(SF4->F4_PISCRED=="1",SD1->D1_VALIMP6,0)) ) * (-1) * (nPerc1 / 100)
			ANO			:= mv_par02
			MES			:= mv_par01
			CFO			:= SD1->D1_CF
			VENDEDOR	:= cVend    
			ICMSRET		+= SD1->D1_ICMSRET * (-1) * (nPerc1 / 100)
			
//			If lDoisV
//				VEND2		:= cVend2	
//			Endif
			TRB->( MsUnLock() )
			If lDoisV
				RecLock( "TRB" , .T.)
				OGRUPO 		:= coGrupo
				GRUPO		:= cGrupo
				EMISSAO		:= SD1->D1_DTDIGIT
				NUMERO		:= SD1->D1_DOC+"-"+SD1->D1_SERIE
				CLIENTE		:= SA1->A1_NREDUZ
				VALBRUT		+= (SD1->D1_TOTAL-SD1->D1_VALDESC + SD1->D1_VALIPI + SD1->D1_VALFRE + SD1->D1_DESPESA + SD1->D1_SEGURO)+ SD1->D1_ICMSRET * (-1) * (nPerc2 / 100)
				VALMERC		+= SD1->D1_TOTAL-SD1->D1_VALDESC * (-1) * (nPerc2 / 100)
				ICMS		+= SD1->D1_VALICM  * (-1) * (nPerc2 / 100)
				IPI			+= SD1->D1_VALIPI  * (-1) * (nPerc2 / 100)
				PIS			+= IF(SF4->F4_PISCRED=="1",SD1->D1_VALIMP6,0) * (-1) * (nPerc2 / 100)
				COFINS		+= IF(SF4->F4_PISCRED=="1",SD1->D1_VALIMP5,0) * (-1) * (nPerc2 / 100)
//				FATLIQ		+= ((SD1->D1_TOTAL + SD1->D1_VALIPI + SD1->D1_VALFRE + SD1->D1_DESPESA + SD1->D1_SEGURO) - (SD1->D1_VALICM + SD1->D1_VALIPI + SD1->D1_VALIMP5 + SD1->D1_VALIMP6)) * (-1) * (nPerc2 / 100)
				FATLIQ		+= ((SD1->D1_TOTAL + SD1->D1_VALFRE + SD1->D1_DESPESA + SD1->D1_SEGURO - SD1->D1_VALDESC - SD1->D1_VALICM - SD1->D1_VALIMP1 - SD1->D1_VALIMP2 - SD1->D1_VALIMP3 - SD1->D1_VALIMP4 - IF(SF4->F4_PISCRED=="1",SD1->D1_VALIMP5,0) - IF(SF4->F4_PISCRED=="1",SD1->D1_VALIMP6,0)) ) * (-1) * (nPerc2 / 100)
				ANO			:= mv_par02
				MES			:= mv_par01
				CFO			:= SD1->D1_CF
				VENDEDOR	:= cVend2 
				ICMSRET		+= (SD1->D1_ICMSRET) * (-1) * (nPerc2 / 100)

//				VEND2		:= cVend
				TRB->( MsUnLock() )
			Endif
		Endif
		dbSelectArea("SD1")
		dbSkip()
	Enddo

	cPATH:= 'C:\TEMP\'
	cFileName   := "SAIDAM"+"_"+DTOS(DATE())+"_"+SUBSTR(TIME(),1,2)+"_"+SUBSTR(TIME(),4,2)+"_"+SUBSTR(TIME(),7,2)+".csv"
	cDestino	:= PADR(cPATH+cFileName, 100)

	cCabec:=""
	//Monta Cabeçalho Relatório
	For _nX:=1 To Len(aStru)
		cCabec+= aStru[_nX,1]+";" 
	Next _nX

	cCabec:=SubStr(cCabec,1,Len(cCabec)-1)
	u_ArqLog(cCabec,cDestino,"")
	
	dbselectarea("TRB")
	TRB->(dbgotop())         

	While TRB->(!EOF())
		
		cDetal:= ""
		cDetal+= cValToChar(TRB->OGRUPO  ) + ";"
		cDetal+= cValToChar(TRB->GRUPO   ) + ";"
		cDetal+= cValToChar(TRB->EMISSAO ) + ";"
		cDetal+= cValToChar(TRB->VENDEDOR) + ";"
		cDetal+= cValToChar(TRB->VEND2   ) + ";"
		cDetal+= cValToChar(TRB->NUMERO  ) + ";"
		cDetal+= cValToChar(TRB->CLIENTE ) + ";"
		cDetal+= strTran(cValToChar(TRB->VALBRUT ),".",",") + ";" //alterado por juliana.mellao - ticket 9039798
		cDetal+= strTran(cValToChar(TRB->VALMERC ),".",",") + ";"
		cDetal+= strTran(cValToChar(TRB->ICMS    ),".",",") + ";"
		cDetal+= strTran(cValToChar(TRB->IPI     ),".",",") + ";"
		cDetal+= strTran(cValToChar(TRB->PIS     ),".",",") + ";"
		cDetal+= strTran(cValToChar(TRB->COFINS  ),".",",") + ";"
		cDetal+= strTran(cValToChar(TRB->FATLIQ  ),".",",") + ";"
		cDetal+= cValToChar(TRB->ANO     ) + ";"
		cDetal+= cValToChar(TRB->MES     ) + ";"
		cDetal+= cValToChar(TRB->CFO     ) + ";"
		cDetal+= strTran(cValToChar(TRB->ICMSRET ),".",",") + ";"
		cDetal+= cValToChar(TRB->DIFAL   ) + ";"
		cDetal+= strTran(cValToChar(TRB->ICMSCOM ),".",",")
		
		u_ArqLog(cDetal,cDestino,"")
		TRB->(dbSkip())
	EndDo	
	
	//Carrega EXCEL
	If ApOleClient("MsExcel")
		oExcelApp:= MsExcel():New()
		oExcelApp:WorkBooks:Open(cDestino)
		oExcelApp:SetVisible(.T.)
	Endif
	
	/*ferase("\DADOSADV\FATM.DBF")
	dbselectarea("TRB")
	dbgotop()
	COPY TO "\DADOSADV\FATM.DBF" VIA "DBFCDXADS"
	COPY TO "\DADOSADV\SAIDAM.DBF"
	Processa({||CpyS2T("\DADOSADV\FATM.DBF","C:\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
	Processa({||CpyS2T("\DADOSADV\SAIDAM.DBF","C:\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
	ferase("\DADOSADV\FATM.DBF")
	ferase("\DADOSADV\SAIDAM.DBF")
	TRB->(DBCLOSEAREA())
	
	//mTESTE := "1;0;1;GIS"  // "EM DISCO;ATUALIZA;1 COPIA;NOME REL."
	
	//CALLCRYS("FATMENS",,mTESTE)*/
	
Else
	
	cGrupo  := "FATURAMENTO"
	coGrupo := "1"
	dbselectarea("SD2")
//	dbSetOrder(3)														// wilson - 20/05
	ProcRegua(LastRec())
//	dbGotop()															// wilson - 20/05
	SD2->( DbSetOrder( 5 ) )											// wilson - 20/05
	SD2->( DbSeek( xFilial( "SD2" ) + ;									// wilson - 20/05
					StrZero( Val( mv_par02 ) , 4 ) +;
					StrZero( Val( mv_par01 ) , 2 ) ) )
//	DO WHILE !EOF() .AND. D2_FILIAL == xFilial("SD2")					// wilson - 20/05
	DO WHILE !EOF() .AND.	D2_FILIAL == xFilial("SD2") .and. ;			// wilson - 20/05
							Year(D2_EMISSAO) == Val(mv_par02) .and. ;
							Month(D2_EMISSAO) == Val(mv_par01)
		IncProc( "Processando vendas dia » " + DtoC( D2_EMISSAO ) )
		If Month(D2_EMISSAO) == Val(mv_par01) .AND. Year(D2_EMISSAO) == Val(mv_par02)
			dbSelectArea("SF4")
			dbSetOrder(1)
			dbSeek(xFilial("SF4") + SD2->D2_TES)
//			If (F4_DUPLIC == "N" .and. mv_par04 == 1) .or. (F4_DUPLIC == "S" .and. mv_par04 == 2) .or. F4_CF $ mv_par06 .or. SD2->D2_TIPO == "D"
			If (F4_DUPLIC == "N" .and. mv_par04 == 1) .or. (F4_DUPLIC == "S" .and. mv_par04 == 2) .or. AllTrim(SD2->D2_CF) $ mv_par06 .or. SD2->D2_TIPO == "D"
				dbSelectArea("SD2")
				dbSkip()
				Loop
			Endif
			If (F4_ESTOQUE == "N" .and. mv_par05 == 1) .or. (F4_ESTOQUE == "S" .and. mv_par05 == 2)
				dbSelectArea("SD2")
				dbSkip()
				Loop
			Endif
			If !Empty(mv_par07) .and. !(AllTrim(SD2->D2_CF) $ mv_par07)
				dbSelectArea("SD2")
				dbSkip()
				Loop
			Endif
			dbSelectArea("SD2")
			nIndice := Ascan(aEmps,Left(D2_COD,2))
			If nIndice == 0
				mCampo := "OUTROS              "
				mOrdem := "5"
			Else
				mCampo := Padr(aEmpresa[nIndice],20)
				mOrdem := StrZero(nIndice,1)
			Endif

			// Tratamento para o 000009 - Paulo e o 000010 - Rogerio (70/30) - Regina 18/11/10
			lDoisV := .F.
			nPerc1 := 100
			nPerc2 := 100
			If !Empty(cVendx)
				lDoisV := .T.
				dbSelectArea("SA3")
				dbSetOrder(1)
				dbSeek(xFilial("SA3") + cVendx)
				mCampo2 := A3_NREDUZ
				cVend2  := A3_NREDUZ
				dbSelectArea("SA1")
				If cVendy == "000009"
					nPerc1 := 70
				ElseIf cVendy $ "000010/000026"
					nPerc1 := 30
				ElseIf cVendy == "000016"
					nPerc1 := 70
				ElseIf cVendy $ "000005/000008"
					nPerc1 := 50
				Endif
				If cVendx == "000009"
					nPerc2 := 70
				ElseIf cVendx $ "000010/000026"
					nPerc2 := 30
				ElseIf cVendy == "000016"
					nPerc2 := 70
				ElseIf cVendx $ "000005/000008"
					nPerc2 := 50
				Endif
			Endif

	
			dbSelectArea("TRB")
			lAchou := dbSeek(coGrupo + mOrdem)
			RecLock( "TRB" , !lAchou)
			OGRUPO 		:= coGrupo
			GRUPO		:= cGrupo
			EMISSAO		:= SD2->D2_EMISSAO
			NUMERO		:= mOrdem
			CLIENTE		:= mCampo
			VALBRUT		+= SD2->D2_TOTAL + IIF(SD2->D2_TIPO == "N" ,SD2->D2_VALIPI,0) + SD2->D2_VALFRE + SD2->D2_SEGURO + SD2->D2_ICMSRET  // + SD2->D2_DESPESA + SD2->D2_SEGURO
			VALMERC		+= SD2->D2_TOTAL + SD2->D2_VALFRE
			ICMS		+= SD2->D2_VALICM
			IPI			+= SD2->D2_VALIPI
			PIS			+= IF(SF4->F4_PISCRED=="2",SD2->D2_VALIMP6,0)
			COFINS		+= IF(SF4->F4_PISCRED=="2",SD2->D2_VALIMP5,0)
//			FATLIQ		+= SD2->D2_TOTAL + SD2->D2_VALIPI + SD2->D2_VALFRE - (SD2->D2_VALICM + SD2->D2_VALIPI + SD2->D2_VALIMP5 + SD2->D2_VALIMP6)
			FATLIQ		+= (SD2->D2_TOTAL + SD2->D2_VALFRE + SD2->D2_DESPESA + SD2->D2_SEGURO - SD2->D2_VALICM - SD2->D2_VALIMP1 - SD2->D2_VALIMP2 - SD2->D2_VALIMP3 - SD2->D2_VALIMP4 - IF(SF4->F4_PISCRED=="2",SD2->D2_VALIMP5,0) - IF(SF4->F4_PISCRED=="2",SD2->D2_VALIMP6,0)- SD2->D2_DIFAL - SD2->D2_ICMSCOM ) * (nPerc1 / 100)
			ANO			:= mv_par02
			MES			:= mv_par01 
			ICMSRET		+= (SD2->D2_ICMSRET) 
            DIFAL		+= (SD2->D2_DIFAL) 			
            ICMSCOM		+= (SD2->D2_ICMSCOM) 
            
            			TRB->( MsUnLock() )
		Endif
		dbSelectArea("SD2")
		dbSkip()
	Enddo
	
	cGrupo  := "DEVOLUCOES "
	coGrupo := "2"
	dbselectarea("SD1")
//	dbSetOrder(1)														// wilson - 20/05
	ProcRegua(LastRec())
//	dbGotop()															// wilson - 20/05
	SD1->( DbSetOrder( 6 ) )											// wilson - 20/05
	SD1->( DbSeek( xFilial( "SD1" ) +;									// wilson - 20/05
					StrZero( Val( mv_par02 ) , 4 ) +;
					StrZero( Val( mv_par01 ) , 2 ) ) )
//	DO WHILE !EOF() .AND. D1_FILIAL == xFilial("SD1")					// wilson - 20/05
	DO WHILE !EOF() .AND.	D1_FILIAL == xFilial("SD1") .and. ;			// wilson - 20/05
							Year( D1_DTDIGIT ) == Val(mv_par02) .and. ;	
							Month(D1_DTDIGIT) == Val(mv_par01)
		IncProc( "Processando dev.vendas dia » " + DtoC( D1_DTDIGIT ) )
		If Month(D1_DTDIGIT) == Val(mv_par01) .AND. Year(D1_DTDIGIT) == Val(mv_par02) .AND. D1_TIPO == "D"
			dbSelectArea("SF4")
			dbSetOrder(1)
			dbSeek(xFilial("SF4") + SD1->D1_TES)
//			If (F4_DUPLIC == "N" .and. mv_par04 == 1) .or. (F4_DUPLIC == "S" .and. mv_par04 == 2) .or. F4_CF $ mv_par06
			If (F4_DUPLIC == "N" .and. mv_par04 == 1) .or. (F4_DUPLIC == "S" .and. mv_par04 == 2) .or. AllTrim(SD1->D1_CF) $ mv_par06
				dbSelectArea("SD1")
				dbSkip()
				Loop
			Endif
			If (F4_ESTOQUE == "N" .and. mv_par05 == 1) .or. (F4_ESTOQUE == "S" .and. mv_par05 == 2)
				dbSelectArea("SD1")
				dbSkip()
				Loop
			Endif
			If !Empty(mv_par07) .and. !(AllTrim(SD1->D1_CF) $ mv_par07)
				dbSelectArea("SD1")
				dbSkip()
				Loop
			Endif
			dbSelectArea("SD1")
			nIndice := Ascan(aEmps,Left(D1_COD,2))
			If nIndice == 0
				mCampo := "OUTROS              "
				mOrdem := "5"
			Else
				mCampo := Padr(aEmpresa[nIndice],20)
				mOrdem := StrZero(nIndice,1)
			Endif
			dbSelectArea("TRB")
			lAchou := dbSeek(coGrupo + mOrdem)
			RecLock( "TRB" , !lAchou)
			OGRUPO 		:= coGrupo
			GRUPO		:= cGrupo
			EMISSAO		:= SD1->D1_DTDIGIT
			NUMERO		:= mOrdem
			CLIENTE		:= mCampo
			VALBRUT		+= (SD1->D1_TOTAL-SD1->D1_VALDESC + SD1->D1_VALIPI + SD1->D1_VALFRE + SD1->D1_DESPESA + SD1->D1_SEGURO + SD1->D1_ICMSRET) * (-1)
			VALMERC		+= SD1->D1_TOTAL-SD1->D1_VALDESC * (-1)
			ICMS		+= SD1->D1_VALICM  * (-1)
			IPI			+= SD1->D1_VALIPI  * (-1)
			PIS			+= IF(SF4->F4_PISCRED=="1",SD1->D1_VALIMP6,0) * (-1)
			COFINS		+= IF(SF4->F4_PISCRED=="1",SD1->D1_VALIMP5,0) * (-1)
//			FATLIQ		+= ((SD1->D1_TOTAL + SD1->D1_VALIPI + SD1->D1_VALFRE + SD1->D1_DESPESA + SD1->D1_SEGURO) - (SD1->D1_VALICM + SD1->D1_VALIPI + SD1->D1_VALIMP5 + SD1->D1_VALIMP6)) * (-1)
			FATLIQ		+= ((SD1->D1_TOTAL + SD1->D1_VALFRE + SD1->D1_DESPESA + SD1->D1_SEGURO - SD1->D1_VALDESC - SD1->D1_VALICM - SD1->D1_VALIMP1 - SD1->D1_VALIMP2 - SD1->D1_VALIMP3 - SD1->D1_VALIMP4 - IF(SF4->F4_PISCRED=="1",SD1->D1_VALIMP5,0) - IF(SF4->F4_PISCRED=="1",SD1->D1_VALIMP6,0)) ) * (-1) * (nPerc1 / 100)
			ANO			:= mv_par02
			MES			:= mv_par01
			ICMSRET		+= SD1->D1_ICMSRET * (-1)

			TRB->( MsUnLock() )
		Endif
		dbSelectArea("SD1")
		dbSkip()
	Enddo
	
	cPATH:= 'C:\TEMP\'
	cFileName   := "SAIDAM"+"_"+DTOS(DATE())+"_"+SUBSTR(TIME(),1,2)+"_"+SUBSTR(TIME(),4,2)+"_"+SUBSTR(TIME(),7,2)+".csv"
	cDestino	:= PADR(cPATH+cFileName, 100)

	cCabec:=""
	//Monta Cabeçalho Relatório
	For _nX:=1 To Len(aStru)
		cCabec+= aStru[_nX,1]+";" 
	Next _nX

	cCabec:=SubStr(cCabec,1,Len(cCabec)-1)
	u_ArqLog(cCabec,cDestino,"")
	
	dbselectarea("TRB")
	TRB->(dbgotop())   
	
	While TRB->(!EOF())
		
		cDetal:= ""
		cDetal+= cValToChar(TRB->OGRUPO  ) + ";"
		cDetal+= cValToChar(TRB->GRUPO   ) + ";"
		cDetal+= cValToChar(TRB->EMISSAO ) + ";"
		cDetal+= cValToChar(TRB->VENDEDOR) + ";"
		cDetal+= cValToChar(TRB->VEND2   ) + ";"
		cDetal+= cValToChar(TRB->NUMERO  ) + ";"
		cDetal+= cValToChar(TRB->CLIENTE ) + ";"
		cDetal+= strTran(cValToChar(TRB->VALBRUT ),".",",") + ";"
		cDetal+= strTran(cValToChar(TRB->VALMERC ),".",",") + ";"
		cDetal+= strTran(cValToChar(TRB->ICMS    ),".",",") + ";"
		cDetal+= strTran(cValToChar(TRB->IPI     ),".",",") + ";"
		cDetal+= strTran(cValToChar(TRB->PIS     ),".",",") + ";"
		cDetal+= strTran(cValToChar(TRB->COFINS  ),".",",") + ";"
		cDetal+= strTran(cValToChar(TRB->FATLIQ  ),".",",") + ";"
		cDetal+= cValToChar(TRB->ANO     ) + ";"
		cDetal+= cValToChar(TRB->MES     ) + ";"
		cDetal+= cValToChar(TRB->CFO     ) + ";"
		cDetal+= strTran(cValToChar(TRB->ICMSRET ),".",",") + ";"
		cDetal+= cValToChar(TRB->DIFAL   ) + ";"
		cDetal+= strTran(cValToChar(TRB->ICMSCOM ),".",",")
		
		u_ArqLog(cDetal,cDestino,"")
		TRB->(dbSkip())
	EndDo	
	
	//Carrega EXCEL
	If ApOleClient("MsExcel")
		oExcelApp:= MsExcel():New()
		oExcelApp:WorkBooks:Open(cDestino)
		oExcelApp:SetVisible(.T.)
	Endif
	
/*	ferase("\DADOSADV\FATM.DBF")
	dbselectarea("TRB")
	dbgotop()
	COPY TO "\DADOSADV\FATM.DBF" VIA "DBFCDXADS"
	Processa({||CpyS2T("\DADOSADV\FATM.DBF","C:\TEMP",.T.)},"Copiando Arquivo","Aguarde...",.F.)
	ferase("\DADOSADV\FATM.DBF")
	TRB->(DBCLOSEAREA())
	
	mTESTE := "1;0;1;GIS"  // "EM DISCO;ATUALIZA;1 COPIA;NOME REL."
	
	CALLCRYS("FATMENSD",,mTESTE)*/
	
Endif

TRB->(DBCLOSEAREA())

Set SoftSeek Off
Return

// *----------------------------------------------------------------------------
Static Function AjustaSX1()

Local nXX

aPerg    := {}
cPerg    := "FATMEN    "

Aadd( aPerg , { "Mes Referencia      ?" , "C" , 02 , "   "})
Aadd( aPerg , { "Ano Referencia      ?" , "C" , 04 , "   "})
Aadd( aPerg , { "Tipo de Relatório   ?" , "N" , 01 , "   "})
Aadd( aPerg , { "Tes qto Faturamento ?" , "N" , 01 , "   "})
Aadd( aPerg , { "Tes qto Estoque     ?" , "N" , 01 , "   "})
Aadd( aPerg , { "Ignora CFOPs        :" , "C" , 40 , "   "})
Aadd( aPerg , { "Inclui CFOPs        :" , "C" , 70 , "   "})

For nXX := 1 to Len( aPerg )
	If !SX1->( DbSeek( cPerg + StrZero( nXX , 2 ) ) )
		RecLock( "SX1" , .T. )
		SX1->X1_GRUPO   := cPerg
		SX1->X1_ORDEM   := StrZero( nXX , 2 )
		SX1->X1_PERGUNT := aPerg[nXX][1]
		SX1->X1_VARIAVL := "mv_ch" + Str( nXX , 1 )
		SX1->X1_TIPO    := aPerg[nXX][2]
		SX1->X1_TAMANHO := aPerg[nXX][3]
		SX1->X1_PRESEL  := 1
		SX1->X1_GSC     := "G"
		SX1->X1_VAR01   := "mv_par" + StrZero( nXX , 2 )
		SX1->X1_F3		:= aPerg[nxx][4]
		If nxx == 3
			SX1->X1_GSC   := "C"
			SX1->X1_DEF01 := "Detalhado"
			SX1->X1_DEF02 := "Resumo por Empresa"
		Endif
		If nxx == 4
			SX1->X1_GSC   := "C"
			SX1->X1_DEF01 := "Gera Financeiro"
			SX1->X1_DEF02 := "Nao Gera"
			SX1->X1_DEF03 := "Considera ambos"
		Endif
		If nxx == 5
			SX1->X1_GSC   := "C"
			SX1->X1_DEF01 := "Movimenta"
			SX1->X1_DEF02 := "Nao Movimenta"
			SX1->X1_DEF03 := "Considera ambos"
		Endif
		SX1->(MsUnlock())
	EndIf
Next nXX
Return Nil
