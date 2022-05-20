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


	Local cPedDe    := ''
	Local cPedAte   := ''
	Local cOPDe     := ''
	Local cOPAte    := ''
	Local cCliDe    := ''
	Local cCliAte   := ''
	Local cDataDe   := ''
	Local cDataAte  := ''
	Local cReimp    := ''
	Local cVolDe    := ''
	Local cVolAte   := ''
	Local cText     := ''
	
	Local cImpPed   := ''
	Local cImpNF    := ''
	Local cImpCli	:= ''
	Local cImpEnd	:= ''
	Local cImpCEP	:= ''
	Local cImpCid	:= ''
	Local cImpUF	:= ''
	Local cImpBAR	:= ''
	Local cImpRMS	:= ''
	Local cImp11	:= ''
	Local cImp10	:= ''
	Local cQuery     := ''
	Local cAliasReg  := GetNextAlias()

	If Pergunte("TRYETTEAM",.T.)
	
		cPedDe    := MV_PAR01
		cPedAte   := MV_PAR02
		cOPDe     := MV_PAR03
		cOPAte    := MV_PAR04
		cCliDe    := MV_PAR05
		cCliAte   := MV_PAR06
		cDataDe   := MV_PAR07
		cDataAte  := MV_PAR08
		cReimp    := MV_PAR09
		cVolDe    := MV_PAR10
		cVolAte   := MV_PAR11
	 	
		cQuery += " SELECT * FROM " + RetsqlName("CB0") + "  CB0 "
		cQuery += " JOIN " + RetsqlName("SA1") + " SA1 ON SA1.A1_COD = CB0_CLI AND SA1.A1_LOJA = CB0.CB0_LOJACL
		cQuery += " JOIN " + RetsqlName("SB1") + " SB1 ON SB1.B1_COD = CB0.CB0_CODPRO
		cQuery += "	WHERE	CB0.CB0_FILIAL = '" + xFilial ("CB0") + "'"
		cQuery += "	AND	CB0_PEDVEN	BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
		cQuery += "	AND	CB0_OP		BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
		cQuery += "	AND	CB0_CLI		BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
		cQuery += "	AND	CB0_DTNASC	BETWEEN '" + DtoS(MV_PAR07) + "' AND '" + DtoS(MV_PAR08) + "' "
		cQuery += "	AND	CB0.D_E_L_E_T_ = '' "


		If Select(cAliasReg) > 0
			cAliasReg->( DbCloseArea() )
		EndIf
		
		DBUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasReg )
	 	
		dbSelectArea(cAliasReg)
	 	
	 		
		While (cAliasReg)->( ! Eof() )
	 		
			cImpPed   := Alltrim((cAliasReg)->CB0_PEDVEN)
			cImpNF    := Alltrim((cAliasReg)->CB0_NFSAI)
			cImpCli   := Alltrim(Substr(Upper((cAliasReg)->A1_NOME),1,50))
			cImpEnd	  := Alltrim(Substr(Upper((cAliasReg)->A1_END),1,50))
			cImpCEP	  := Alltrim((cAliasReg)->A1_CEP)
			cImpCid	  := Alltrim(Substr(Upper((cAliasReg)->A1_MUN),1,22))
			cImpUF	  := Alltrim(Upper((cAliasReg)->A1_ESTADO))
			cImpBAR	  := PadL(Alltrim((cAliasReg)->B1_COD),12,'0')
			cImpRMS	  := Alltrim(Posicione("SA7",1,xFilial("SA7") + avKey((cAliasReg)->A1_COD,"A7_CLIENTE") + avKey((cAliasReg)->A1_LOJA,"A7_LOJA") + avKey((cAliasReg)->B1_COD,"A7_PRODUTO")  ,"A7_PCRMS" ))
			cImp11	  := Alltrim((cAliasReg)->B1_DESC)
			cImp10	  := Alltrim((cAliasReg)->B1_COD)
			
			nQtd      := (cAliasReg)->CB0_QTDE
		
			For nX := 1 to nQtd
				
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
					cText += "1911S0100810301P009P009" +"RMS"+ Alltrim(cImpRMS) + CRLF
				Endif
		
				If cReimp == 1
					cText += "1911S0100820021P008P008" + Alltrim(cImp11) + CRLF
					cText += "1911S0100670021P008P008" + Alltrim(cImp10) + CRLF
				Endif
		
				cText += "1f8404300160117" + cImpBAR + CRLF
				cText += "1911S0100050127P009P0095"+ CRLF
				cText += "1911S0100050141P009P0090"+ CRLF
				cText += "1911S0100050156P009P0097"+ CRLF
				cText += "1911S0100050169P009P0094"+ CRLF
				cText += "1911S0100050184P009P0096"+ CRLF
				cText += "1911S0100050198P009P0090"+ CRLF
				cText += "1911S0100050218P009P0090"+ CRLF
				cText += "1911S0100050232P009P0096"+ CRLF
				cText += "1911S0100050246P009P0094"+ CRLF
				cText += "1911S0100050260P009P0099"+ CRLF
				cText += "1911S0100050274P009P0099"+ CRLF
				cText += "1911S0100050288P009P0095"+ CRLF
				cText += "1911S0100050100P009P0093"+ CRLF
				cText += "1911S0102020058P013P008" + Alltrim(cImpNF) + CRLF
				cText += "1911S0101680058P012P007" + Alltrim(cImpPed) + CRLF
				cText += "1911S0101670326P012P012" + Alltrim(Str(nX)) + "/" + Alltrim(Str(nQtd)) + CRLF
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
		
				COPY FILE "C:\TEMP\ZEBRA.TXT" TO LPT1
			
			Next nX
			
			(cAliasReg)->( dbSkip() )
		
		End
		
		
	Endif
Return


