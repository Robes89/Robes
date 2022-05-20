#Include 'Protheus.ch'
#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#Include "Protheus.ch"

User Function EtEmbTri()
	#define CRLF Chr(13)+ Chr(10)


	Local cPedDe       := ''
	Local cPedAte      := ''
	Local cOPDe        := ''
	Local cOPAte       := ''
	Local cCliDe       := ''
	Local cCliAte      := ''
	Local cDataDe      := ''
	Local cDataAte     := ''
	Local cReimp       := ''
	Local cVolDe       := ''
	Local cVolAte      := ''
	Local cText        := ''
	Local nX
	Local nQtd
	Local cop          := ''
	Local cImpPed      := ''
	Local cImpNF       := ''
	Local cImpCli      := ''
	Local cImpEnd      := ''
	Local cImpCEP      := ''
	Local cImpCid      := ''
	Local cImpUF       := ''
	Local cImpBAR      := ''
	Local cImpRMS      := ''
	Local cImp11       := ''
	Local cImp10       := ''
	Local cQuery       := ''
	Local cAliasReg    := GetNextAlias()
	Local cAliasRegsd4 := GetNextAlias()
	Local cAliasRegsd5 := GetNextAlias()
	Local cVolume      := SuperGetMV("MV_PDETIQ",.F.,"")
	Local nX:=0


	If Pergunte("TRYETTEAM",.T.)
	
		cPedDe    := MV_PAR01
		cPedAte   := MV_PAR02
		cOPDe     := ALLTRIM(MV_PAR03)
		cOPAte    := ALLTRIM(MV_PAR04)
		cCliDe    := MV_PAR05
		clojaDe   := MV_PAR06
		cCliAte   := MV_PAR07
		clojaAte  := MV_PAR08
		cDataDe   := MV_PAR09
		cDataAte  := MV_PAR10
		cporta	  := Iif(MV_PAR11=1,'LPT1','LPT2') 
		cVolde    := MV_PAR12
		cVolate	  := MV_PAR13
		

		cQuery += " SELECT * FROM " + RetsqlName("SC2") + "  SC2 "
		cQuery += " JOIN " + RetsqlName("SC6") + " SC6 ON SC6.C6_FILIAL=SC2.C2_FILIAL AND SC6.C6_NUMOP=SC2.C2_NUM AND SC6.C6_ITEMOP=SC2.C2_ITEM 
		cQuery += " JOIN " + RetsqlName("SA1") + " SA1 ON SA1.A1_COD = SC6.C6_CLI AND SA1.A1_LOJA = SC6.C6_LOJA
		cQuery += " JOIN " + RetsqlName("SB1") + " SB1 ON SB1.B1_COD = SC6.C6_PRODUTO		
		cQuery += "	WHERE	SC6.C6_FILIAL = '" + xFilial ("SC6") + "'"
		cQuery += "	AND	C2_NUM	>= '" + cPedDe + "' 
		cQuery += "	AND	C2_NUM	<= '" + cPedAte + "' 
		cQuery += "	AND	C2_ITEM	>= '" + SUBSTR(cOPDe,7,2) + "' 
		cQuery += " AND C2_ITEM <= '" + SUBSTR(cOPAte,7,2) + "' "
		cQuery += "	AND	C2_SEQUEN='001' "
		cQuery += "	AND	C2_FILIAL='" + xFilial ("SC2") + "'"
		cQuery += "	AND	C6_FILIAL='" + xFilial ("SC6") + "'"
		cQuery += "	AND	C6_CLI		BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR07 + "' "
		cQuery += "	AND	C6_LOJA		BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR08 + "' "
		cQuery += "	AND	C2_DATPRI	BETWEEN '" + DtoS(MV_PAR09) + "' AND '" + DtoS(MV_PAR10) + "' "
		cQuery += "	AND	SC2.D_E_L_E_T_ = '' AND	SC6.D_E_L_E_T_ = ''  AND SB1.D_E_L_E_T_ = '' AND SA1.D_E_L_E_T_ = '' "
		cQuery += " ORDER BY SC2.C2_NUM,SC2.C2_ITEM,SC2.C2_SEQUEN "  


		If Select(cAliasReg) > 0
			cAliasReg->( DbCloseArea() )
		EndIf
		
		DBUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasReg )
	 	
		dbSelectArea(cAliasReg)
	 		 		
		While (cAliasReg)->( ! Eof() ) 
			cPed:=(cAliasReg)->C2_NUM //+C2_ITEM+C2_SEQUEN)
			nContfor:=0

			If Select(cAliasRegSD5) > 0
				(cAliasRegSD5)->( DbCloseArea() )
			EndIf					

			cQuery := " SELECT SUM(SD4.D4_QTDEORI) AS NVOLUME FROM " + RetsqlName("SD4") + "  SD4 "
			cQuery += " JOIN " + RetsqlName("SB1") + " SB1 ON SB1.B1_COD = SD4.D4_COD
			cQuery += "	WHERE	SD4.D4_FILIAL = '" + (cAliasReg)->C2_FILIAL + "'"
			cQuery += "	AND	SUBSTRING(SD4.D4_OP,1,6)='"+(cAliasReg)->(C2_NUM)+ "' "
			cQuery += " AND SB1.B1_GRUPO ='"+cVolume+ "' "
			cQuery += "	AND	SD4.D_E_L_E_T_ = ' '  "
			DBUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasRegsd5 )			 				 	

			nQtdPVEN := (cAliasRegsd5)->nvolume


			While (cAliasReg)->( ! Eof() ) .And. cPed = (cAliasReg)->C2_NUM
			        cOp:=(cAliasReg)->(C2_NUM+C2_ITEM+C2_SEQUEN)    
					nQtd:=0
					
					While (cAliasReg)->( ! Eof() ) .AND. cOp = (cAliasReg)->(C2_NUM + C2_ITEM + C2_SEQUEN)

							If Select(cAliasRegSD4) > 0
								(cAliasRegSD4)->( DbCloseArea() )
							EndIf			

							cQuery := " SELECT SUM(SD4.D4_QTDEORI) AS NVOLUME FROM " + RetsqlName("SD4") + "  SD4 "
							cQuery += " JOIN " + RetsqlName("SB1") + " SB1 ON SB1.B1_COD = SD4.D4_COD
							cQuery += "	WHERE	SD4.D4_FILIAL = '" + (cAliasReg)->C2_FILIAL + "'"
							cQuery += "	AND	SD4.D4_OP='"+(cAliasReg)->(C2_NUM+C2_ITEM+C2_SEQUEN)+ "' "
							cQuery += " AND SB1.B1_GRUPO ='"+cVolume+ "' "
							cQuery += "	AND	SD4.D_E_L_E_T_ = ' '  "
							DBUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasRegsd4 )			 				 	

							nQtd  := (cAliasRegsd4)->nvolume	

							SD2->(DBSetOrder(8))
							SD2->(DBSEEK(xFilial('SD2')+(cAliasReg)->C6_NUM+(cAliasReg)->C6_ITEM))

							cImpPed := Alltrim((cAliasReg)->C2_NUM) + Alltrim((cAliasReg)->C2_ITEM)
							cImpNF  := Alltrim(SD2->D2_DOC)
							cImpCli := Alltrim(Substr(Upper((cAliasReg)->A1_NOME),1,25))
							cImpEnd := Alltrim(Substr(Upper((cAliasReg)->A1_END),1,25))
							cImpCEP := Alltrim((cAliasReg)->A1_CEP)
							cImpCid := Alltrim(Substr(Upper((cAliasReg)->A1_MUN),1,22))
							cImpUF  := Alltrim(Upper((cAliasReg)->A1_EST))
							cImpBAR := PadL(Alltrim((cAliasReg)->B1_CODBAR),13,'0')
							cImpRMS := Alltrim(Posicione("SA7",1,xFilial("SA7") + avKey((cAliasReg)->A1_COD,"A7_CLIENTE") + avKey((cAliasReg)->A1_LOJA,"A7_LOJA") + avKey((cAliasReg)->B1_COD,"A7_PRODUTO")  ,"A7_CPRMS" ))
							cImp11  := Alltrim((cAliasReg)->B1_DESC)
							cImp10  := Alltrim((cAliasReg)->B1_COD)
							   
					       	nX:=1

							For nX := 1 to nQtd	    
								
								If nX + nContfor >= val(alltrim(cVolde)) .AND. nX + nContfor <= Val(alltrim(cVolate))
									cText := ''
								
									cText += "		<xpml><page quantity='0' pitch='60.1 mm'></xpml>n"+ CRLF
									cText += "M0592"+ CRLF
									cText += "d"+ CRLF
									cText += "<xpml></page></xpml><xpml><page quantity='1' pitch='60.1 mm'></xpml>L"+ CRLF
									cText += "D11"+ CRLF
									cText += "R0000"+ CRLF
									cText += "A2"+ CRLF
									cText += "1X1100000010014L001224"+ CRLF
									cText += "1X1100000010388L001224"+ CRLF
									cText += "1X1100002240015L374001"+ CRLF
									cText += "1X1100000010015L374001"+ CRLF
									cText += "1X1100001910015L106001"+ CRLF
									cText += "1X1100001570015L374001"+ CRLF
									cText += "1X1100001580054L001067"+ CRLF
									cText += "1X1100001580120L001067"+ CRLF
									cText += "1X1100001580296L001067"+ CRLF
									cText += "1X1100001910296L093001"+ CRLF
									cText += "1X1100000980015L374001"+ CRLF
									cText += "ySU8"+ CRLF
									cText += "1911S0102020024P012P012NF"+ CRLF
									cText += "1911S0101690018P012P012PED"+ CRLF
									cText += "1911S0102020302P012P012VOLUMES"+ CRLF
									cText += "1911S0101690124P016P010ARTIGOS INFANTIS LTDA"+ CRLF
									cText += "1911S0101420018P009P009CLIENTE:"+ CRLF
									cText += "1911S0101230019P009P009END:"+ CRLF
									cText += "1911S0101020020P009P009CEP:"+ CRLF
									cText += "1911S0101020126P009P009CIDADE:"+ CRLF
									cText += "1911S0101020335P009P009UF:"+ CRLF
							
									If ! Empty(cImpRMS)
						
										cText += "1911S0100810301P009P009" +"RMS "+ Alltrim(cImpRMS) + CRLF
									Endif
							
									cText += "1911S0100820021P008P008" + Alltrim(cImp11) + CRLF
									cText += "1911S0100670021P008P008" + Alltrim(cImp10) + CRLF
							
									cText += "1f8404300150127" + cImpBAR + CRLF
									cText += "1911S0100050127P009P009" + Alltrim(Substr(cImpBAR,1,1)) + CRLF    //1+ CRLF
									cText += "1911S0100050141P009P009" + Alltrim(Substr(cImpBAR,2,1)) + CRLF    //1+ CRLF
									cText += "1911S0100050156P009P009" + Alltrim(Substr(cImpBAR,3,1)) + CRLF    //1+ CRLF
									cText += "1911S0100050169P009P009" + Alltrim(Substr(cImpBAR,4,1)) + CRLF    //1+ CRLF
									cText += "1911S0100050184P009P009" + Alltrim(Substr(cImpBAR,5,1)) + CRLF    //1+ CRLF
									cText += "1911S0100050198P009P009" + Alltrim(Substr(cImpBAR,6,1)) + CRLF    //1+ CRLF
									cText += "1911S0100050218P009P009" + Alltrim(Substr(cImpBAR,7,1)) + CRLF    //1+ CRLF
									cText += "1911S0100050232P009P009" + Alltrim(Substr(cImpBAR,8,1)) + CRLF    //1+ CRLF
									cText += "1911S0100050246P009P009" + Alltrim(Substr(cImpBAR,9,1)) + CRLF    //1+ CRLF
									cText += "1911S0100050260P009P009" + Alltrim(Substr(cImpBAR,10,1)) + CRLF    //1+ CRLF
									cText += "1911S0100050274P009P009" + Alltrim(Substr(cImpBAR,11,1)) + CRLF    //1+ CRLF
									cText += "1911S0100050288P009P009" + Alltrim(Substr(cImpBAR,12,1)) + CRLF    //1+ CRLF
									cText += "1911S0100050302P009P009" + Alltrim(Substr(cImpBAR,13,1)) + CRLF    //1+ CRLF
									cText += "1911S0102020058P013P008" + Alltrim(cImpNF) + CRLF
									cText += "1911S0101680058P012P007" + Alltrim(cImpPed) + CRLF
									cText += "1911S0101670326P012P012" + Alltrim(Str( nX + nContfor )) + "/" + Alltrim(Str(nQtdPVEN)) + CRLF
									cText += "1911S0101420080P008P008" + Alltrim(cImpCli) + CRLF
									cText += "1911S0101240082P008P008" + Alltrim(cImpEnd) + CRLF
									cText += "1911S0101020060P008P008" + Alltrim(cImpCEP) + CRLF
									cText += "1911S0101010179P008P008" + Alltrim(cImpCid) + CRLF
									cText += "1911S0101020358P009P009" + Alltrim(cImpUF) + CRLF
									cText += "1911S0101970141P018P011TEAMTEX BRASIL"+ CRLF
									cText += "Q0001"+ CRLF
									cText += "E"+ CRLF
									cText += "<xpml></page></xpml><xpml><end/></xpml>"+ CRLF
					
									FERASE('C:\TEMP\ZEBRA.TXT')
									arq := ' '
									arq := 'C:\TEMP\ZEBRA.TXT'
									memowrite(ARQ,CTEXT)
							
									COPY FILE "C:\TEMP\ZEBRA.TXT" TO &cporta
							Endif 		
						        
						Next nX
				
						(cAliasReg)->( dbSkip() )
		 				nContfor := nContfor + nQtd											
				    End 
			 End
		End 		
	Endif
Return


