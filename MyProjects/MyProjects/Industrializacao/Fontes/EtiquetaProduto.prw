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

	Local cCliDe    := ''
	Local cCliAte   := ''

	Local cLojaDe    := ''
	Local cLojaAte   := ''

	Local cOPDe     := ''

	Local cVolDe    := ''
	Local cVolAte   := ''
	Local cText     := ''

	Local cImpBar      := '' //Codigo de barras do topo da etiqueta
	Local cSKU         := '' 
	Local cDescProd    := ''
	Local cModelo	   := '' 
	Local cGrupo       := '' 
	Local cOrigem      := '' 
	Local cLote        := '' 
	Local cImpBARSerie := ''
	Local cQuery    := ''
	Local cAliasReg := GetNextAlias()
	local cAliasSDB:= GetNextAlias()

	dbSelectArea("SA7")

	If Pergunte("TRYETTEAMP",.T.)

		cOPDe     := MV_PAR01
		cPORTA    := Iif(MV_PAR09=1,'LPT1','LPT2')   

        cQuery += " SELECT SC2.C2_NUM,SC2.C2_ITEM,SC2.C2_SEQUEN,SB1.B1_CODBAR,SB1.B1_COD,SB1.B1_DESC,SB1.B1_CODTYPE,SB1.B1_CMASSA, SD3.D3_NUMSEQ, SD3.D3_COD, SD3.D3_DOC FROM " + RetsqlName("SC2") + " SC2 "
		cQuery += " LEFT JOIN " + RetsqlName("SC5") + " SC5 ON SC5.C5_FILIAL=SC2.C2_FILIAL AND SC5.C5_NUM=SC2.C2_NUM AND SC5.D_E_L_E_T_='' "
		cQuery += " LEFT JOIN " + RetsqlName("SA1") + " SA1 ON SA1.A1_COD = SC5.C5_CLIENTE AND SA1.A1_LOJA = SC5.C5_LOJACLI AND SA1.A1_COD BETWEEN '" + MV_PAR05+ "' AND '" + MV_PAR06+"' AND  SA1.D_E_L_E_T_ = ''
		cQuery += " JOIN " + RetsqlName("SB1") + " SB1 ON B1_COD = SC2.C2_PRODUTO"
		cQuery += " JOIN " + RetsqlName("SD3") + " SD3 ON SD3.D3_FILIAL=SC2.C2_FILIAL AND SD3.D3_OP = SC2.C2_NUM+SC2.C2_ITEM + SC2.C2_SEQUEN"						
		cQuery += "	WHERE SC2.C2_NUM+SC2.C2_ITEM + SC2.C2_SEQUEN BETWEEN '"+ MV_PAR03+ "' AND '" + MV_PAR04+"' " 
		cQuery += "	AND	SC2.C2_SEQUEN = '002' 
		cQuery += "	AND SC2.C2_NUM BETWEEN '" + MV_PAR01+ "' AND '" + MV_PAR02+ "' " 		
		cQuery += "	AND	B1_IMPORT='N' "
		cQuery += "	AND SD3.D3_CF IN('PR0','PR1') AND SD3.D3_ESTORNO=' '
		cQuery += "	AND	SC2.D_E_L_E_T_ = ''   AND SB1.D_E_L_E_T_ = ''  AND SD3.D_E_L_E_T_ = '' "		
		cQuery += " ORDER BY SC2.C2_NUM,SC2.C2_ITEM,SC2.C2_SEQUEN " 

		If Select(cAliasReg) > 0
			cAliasReg->( DbCloseArea() )
		EndIf

		DBUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasReg )

		dbSelectArea(cAliasReg)

		While (cAliasReg)->( ! Eof() )

			cImpBar      := PadL(Alltrim((cAliasReg)->B1_CODBAR),13,'0')
			cSKU         := Substr(Alltrim((cAliasReg)->B1_COD),1,7)
			cDescProd    := Substr(Alltrim((cAliasReg)->B1_DESC),16,50)

			cTYPE:=Posicione("SX5",1,xFilial("SX5")+"ZZ" + (cAliasReg)->B1_CODTYPE,"X5_DESCRI")		
			cTYPE:=Alltrim(cTYPE)  

			cGrupo:=Posicione("SX5",1,xFilial("SX5")+"ZK" + (cAliasReg)->B1_CMASSA,"X5_DESCRI")
			cGrupo:= Alltrim(cGrupo)  			
			cOrigem      := 'BRASIL' 

			cDRIMOD:=Posicione("SX5",1,xFilial("SX5")+"ZX" + (cAliasReg)->B1_CMODELO,"X5_DESCRI")
			cDRIMOD:= Alltrim(cDRIMOD)  			
			
			cDRITP:=Posicione("SX5",1,xFilial("SX5")+"ZW" + (cAliasReg)->B1_XTIPO,"X5_DESCRI")
			cDRITP:= Alltrim(cDRITP)  			


			cQuery:=" SELECT * FROM " + RetsqlName("SDB") + "  SDB "
			cQuery += "	WHERE	SDB.DB_FILIAL = '" + xFilial ("SDB") + "' "
			cQuery += "	AND	SDB.D_E_L_E_T_ = '' 
			cQuery += "	AND	SDB.DB_NUMSEQ = '"+ (cAliasReg)->D3_NUMSEQ +"' "
			cQuery += "	AND	SDB.DB_TM ='499' "  
			cQuery += " AND SDB.DB_PRODUTO= '"+(cAliasReg)->D3_COD +"' "
			cQuery += " AND SDB.DB_ESTORNO=' '
			cQuery += " AND SDB.DB_DOC= '" + (cAliasReg)->D3_DOC +"' "
			cQuery += " ORDER BY SDB.DB_FILIAL,SDB.DB_NUMSERI

     		if SELECT("cAliasSDB") > 0
               cAliasSDB->(dbclosearea())
          	endif

			DBUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , "cAliasSDB", .F., .T. )
			
			dbSelectArea("cAliasSDB")

			While cAliasSDB->(!Eof())	

				cLote        := Alltrim(cAliasSDB->DB_LOTECTL)  

				cImpBARSerie := PadL(Alltrim(cAliasSDB->DB_NUMSERI),12,'0')//Alltrim((cAliasSDB)->DB_NUMSERI)

				cText := ''	

				cText += "<xpml><page quantity='0' pitch='60.1 mm'></xpml>n"+ CRLF
				cText += "M0592"+ CRLF
				cText += "d"+ CRLF
				cText += "<xpml></page></xpml><xpml><page quantity='1' pitch='60.1 mm'></xpml>L"+ CRLF
				cText += "D11"+ CRLF
				cText += "R0000"+ CRLF
				cText += "A2"+ CRLF
				cText += "1f6303701430057" + cImpBAR + CRLF
				cText += "ySU8"+ CRLF
				cText += "1911S0101330057P009P009" + Alltrim(Substr(cImpBAR,1,1)) + CRLF    //1+ CRLF
				cText += "1911S0101330067P009P009" + Alltrim(Substr(cImpBAR,2,1)) + CRLF    //1+ CRLF
				cText += "1911S0101330078P009P009" + Alltrim(Substr(cImpBAR,3,1)) + CRLF    //1+ CRLF
				cText += "1911S0101330088P009P009" + Alltrim(Substr(cImpBAR,4,1)) + CRLF    //1+ CRLF
				cText += "1911S0101330099P009P009" + Alltrim(Substr(cImpBAR,5,1)) + CRLF    //1+ CRLF
				cText += "1911S0101330109P009P009" + Alltrim(Substr(cImpBAR,6,1)) + CRLF    //1+ CRLF
				cText += "1911S0101330125P009P009" + Alltrim(Substr(cImpBAR,7,1)) + CRLF    //1+ CRLF
				cText += "1911S0101330135P009P009" + Alltrim(Substr(cImpBAR,8,1)) + CRLF    //1+ CRLF
				cText += "1911S0101330146P009P009" + Alltrim(Substr(cImpBAR,9,1)) + CRLF    //1+ CRLF
				cText += "1911S0101330156P009P009" + Alltrim(Substr(cImpBAR,10,1)) + CRLF    //1+ CRLF
				cText += "1911S0101330167P009P009" + Alltrim(Substr(cImpBAR,11,1)) + CRLF    //1+ CRLF
				cText += "1911S0101330177P009P009" + Alltrim(Substr(cImpBAR,12,1)) + CRLF    //1+ CRLF
				cText += "1911S0101330187P009P009" + Alltrim(Substr(cImpBAR,13,1)) + CRLF    //1+ CRLF
				cText += "1911S0101140018P008P009MODELO:"+ CRLF
				cText += "1911S0101030018P008P009"+ CRLF
				cText += "1X1100000050009B218227001001"+ CRLF
				cText += "1911S0102010067P016P016" + cSKU + CRLF
				cText += "1911S0101840030P006P006" + cDescProd + CRLF
				cText += "1911S0100670020P008P009LOTE:"+ CRLF
				cText += "1911S0100460020P008P009N� DE"+ CRLF
				cText += "1911S0100320020P008P009SERIE:"+ CRLF
				cText += "1911S0100180020P008P009"+ CRLF
				cText += "1911S0101140086P008P009" + cTYPE + CRLF
				cText += "1911S0100960073P008P009" + cDRIMOD + CRLF
				cText += "1911S0100800077P008P009" + cOrigem + CRLF
				cText += "1911S0100670062P008P009" + cLote + CRLF
				cText += "1911S0100960018P008P009GRUPO:"+ CRLF
				cText += "1911S0100800018P008P009ORIGEM:"+ CRLF
				cText += "1f6303700230068" + cImpBARSerie + CRLF
				cText += "1911S0100120068P009P009" + Alltrim(Substr(cImpBARSerie,1,1)) + CRLF    //1+ CRLF
				cText += "1911S0100120085P009P009" + Alltrim(Substr(cImpBARSerie,2,1)) + CRLF    //1+ CRLF
				cText += "1911S0100120096P009P009" + Alltrim(Substr(cImpBARSerie,3,1)) + CRLF    //1+ CRLF
				cText += "1911S0100120106P009P009" + Alltrim(Substr(cImpBARSerie,4,1)) + CRLF    //1+ CRLF
				cText += "1911S0100120117P009P009" + Alltrim(Substr(cImpBARSerie,5,1)) + CRLF    //1+ CRLF
				cText += "1911S0100120128P009P009" + Alltrim(Substr(cImpBARSerie,6,1)) + CRLF    //1+ CRLF
				cText += "1911S0100120143P009P009" + Alltrim(Substr(cImpBARSerie,7,1)) + CRLF    //1+ CRLF
				cText += "1911S0100120153P009P009" + Alltrim(Substr(cImpBARSerie,8,1)) + CRLF    //1+ CRLF
				cText += "1911S0100120164P009P009" + Alltrim(Substr(cImpBARSerie,9,1)) + CRLF    //1+ CRLF
				cText += "1911S0100120174P009P009" + Alltrim(Substr(cImpBARSerie,10,1)) + CRLF    //1+ CRLF
				cText += "1911S0100120185P009P009" + Alltrim(Substr(cImpBARSerie,11,1)) + CRLF    //1+ CRLF
				cText += "1911S0100120196P009P009" + Alltrim(Substr(cImpBARSerie,12,1)) + CRLF    //1+ CRLF
				cText += "1911S0100120207P009P009" + Alltrim(Substr(cImpBARSerie,13,1)) + CRLF    //1+ CRLF
				cText += "Q0001"+ CRLF
				cText += "E"+ CRLF
				cText += "<xpml></page></xpml><xpml><end/></xpml>"+ CRLF


				FERASE('C:\TEMP\ZEBRA.TXT')
				arq := ' '
				arq := 'C:\TEMP\ZEBRA.TXT'
				memowrite(ARQ,CTEXT)

				COPY FILE "C:\TEMP\ZEBRA.TXT" TO &(cPORTA)

				cAliasSDB->( dbSkip() )
			End
		
			(cAliasReg)->( dbSkip() )
		
		End
	

	eNDIF
Return




