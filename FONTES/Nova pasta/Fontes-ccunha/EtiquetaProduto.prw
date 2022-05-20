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

User Function EtProTri()

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
	
	dbSelectArea("SA7")

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
			cImpCli   := Alltrim(Substr(Upper((cAliasReg)->A1_NOME),1,25))
			cImpEnd	  := Alltrim(Substr(Upper((cAliasReg)->A1_END),1,25))
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
  		
				cText += "<xpml><page quantity='0' pitch='60.1 mm'></xpml>n" + CRLF
				cText += "M0592" + CRLF
				cText += "d" + CRLF
				cText += "<xpml></page></xpml><xpml><page quantity='1' pitch='60.1 mm'></xpml>L" + CRLF
				cText += "D11" + CRLF
				cText += "R0000" + CRLF
				cText += "A2" + CRLF
				cText += "1X1100002110012L065001" + CRLF
				cText += "1X1100001890034L001043" + CRLF
				cText += "1X1100001890076L001043" + CRLF
				cText += "1X1100001890165L001043" + CRLF
				cText += "ySU8" + CRLF
				cText += "1911S0102150015P008P008NF" + CRLF
				cText += "1911S0101970012P007P007PED" + CRLF
				cText += "1911S0101990079P008P005ARTIGOS INFANTIS LTDA" + CRLF
				cText += "1911S0101660017P007P007CLIENTE:" + CRLF
				cText += "1911S0101520017P007P007END:" + CRLF
				cText += "1911S0101290017P007P007CEP:" + CRLF
				cText += "1911S0101160017P006P006CIDADE:" + CRLF
				cText += "1911S0101150182P007P006UF:" + CRLF
				cText += "1911S0100920022P006P006" + cImp11 + CRLF
				cText += "1911S0100770022P006P006" + cImp10 + CRLF
				cText += "1f6303700220054" + cImpBAR + CRLF
				cText += "1911S0100110061P009P0091" + CRLF
				cText += "1911S0100110071P009P0091" + CRLF
				cText += "1911S0100110082P009P0091" + CRLF
				cText += "1911S0100110093P009P0091" + CRLF
				cText += "1911S0100110103P009P0091" + CRLF
				cText += "1911S0100110114P009P0091" + CRLF
				cText += "1911S0100110129P009P0091" + CRLF
				cText += "1911S0100110139P009P0091" + CRLF
				cText += "1911S0100110150P009P0091" + CRLF
				cText += "1911S0100110161P009P0091" + CRLF
				cText += "1911S0100110171P009P0091" + CRLF
				cText += "1911S0100110182P009P0096" + CRLF
				cText += "1911S0100110041P009P0091" + CRLF
				cText += "1911S0102150037P008P005" + cImpNF + CRLF
				cText += "1911S0101960037P009P005" + cImpPED + CRLF
				cText += "1911S0101950181P012P012" + Alltrim(Str(nX)) + "/" + Alltrim(Str(nQtd)) + CRLF
				cText += "1911S0101660070P007P007" + cImpCLI + CRLF
				cText += "1911S0101550053P005P005" + Substr(cImpEND,1,35) + CRLF
				cText += "1911S0101310051P006P006" + cImpCEP + CRLF
				cText += "1911S0101160051P006P006" + cImpCID + CRLF
				cText += "1911S0101140202P009P009" + cImpUF + CRLF
				cText += "1911S0102120090P008P005TEAMTEX BRASIL" + CRLF
				cText += "1911S0102150167P008P008VOLUMES" + CRLF
				cText += "1X1100001880009L216001" + CRLF
				cText += "1X1100002110165L060001" + CRLF
				cText += "1X1100000050009B218227001001" + CRLF
				cText += "1X1100001070009L216001" + CRLF

				If ! Empty(cImpRMS)
					cText += "1911S0100920174P006P006RMStaltaltal" + CRLF
				Endif


				cText += "1911S0101440053P005P005" + Substr(cImpEND,36,35) + CRLF
				cText += "Q0001" + CRLF
				cText += "E" + CRLF
				cText += "<xpml></page></xpml><xpml><end/></xpml>" + CRLF
				
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


