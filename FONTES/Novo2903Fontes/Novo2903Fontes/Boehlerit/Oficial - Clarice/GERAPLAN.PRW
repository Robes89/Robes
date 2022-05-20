#INCLUDE "rwmake.ch"

// Rotina		: GERAPLAN
// Descrição	: Gera a planilha do Sr. Julio
// Data			: 19/01/05
// Autor        : Daniel Gondran

//Alterado em 03_09_07 Fernando
//Incluir campo FRETE no arquivo DBF

User Function GERAPLAN()

Private _cHrIni := SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)
// mv_par01 = da data (ano corrente)
// mv_par02 = Ate a data (ano corrente)
// mv_par03 = do produto
// mv_par04 = ate o produto
// mv_par05 = pertence a lista de preços
// mv_par06 = da data (ano anterior)
// mv_par07 = ate a data (ano anterior)
// mv_par08 = produtos / produtos + movimentos
// mv_par09 = do cliente
// mv_par10 = ate cliente
// mv_par11 = da area
// mv_par12 = ate area
// mv_par13 = da regiao
// mv_par14 = ate regiao
// mv_par15 = pasta

//cPerg := "GERAPX"
 cPerg    := PadR( 'GERAPX' , Len( SX1->X1_GRUPO ) )
AjustaSX1()
Pergunte(cPerg,.F.)

/*
X1_ORDEM X1_PERGUNT	X1_TIPO	X1_TAMANHO
01	Da Data (ano corr)?	D	8
02	Ate Data(ano corr)?	D	8
03	Do Produto        ?	C	15
04	Ate Produto       ?	C	15
05	Pertence Lista Pre?	N	1
06	Da Data (ano ante)?	D	8
07	Ate Data(ano ante)?	D	8
08	Imprime           ?	N	1
09	Do Cliente        ?	C	6
10	Ate Cliente       ?	C	6
11	Da Area           ?	C	5
12	Ate Area          ?	C	5
13	Da Regiao         ?	C	5
14	Ate Regiao        ?	C	5
15	Pasta p/ gerar arq?	C	30
*/
@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Gerador de Planilhas"
@ 70,080 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
@ 70,118 BMPBUTTON TYPE 1 ACTION OkProc()
@ 70,156 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
@ 23,14 SAY "O objetivo desta rotina é gerar um arquivo" size 200,10
@ 33,14 SAY "que será lido pelo Excell com diversas    " size 200,10
@ 43,14 SAY "informações do MicroSiga "                  size 200,10
@ 8,10 TO 060,180
ACTIVATE DIALOG oDlg5 CENTERED
Return

// *******************************************************************************************************************
Static Function OkProc()
Private oProcess 
Close(oDlg5)
///Processa({|| GeraMov() } , "GERAPLAN" )
oProcess := MsNewProcess():New( { ||  GeraMov(@oProcess, @lEnd)  } , "GERAPLAN" , "Aguarde..." , .F. )
oProcess:Activate()	

Return
// *******************************************************************************************************************
Static Function GeraMov(oProcess, lEnd)

Local nXX 		:= 0
Local cFields	:= ""
Local cDetal	:= ""
Local aStru 	:= {}
Local cFileName := ""
Local cPATH		:= ""
Local cDestino	:= ""
Local dPerIni := mv_par01
Local dPerFim := mv_par02
Local _nTotR1  := 0 

aAdd(aStru,{"CODINT"    ,"C",15,0})
aAdd(aStru,{"POSIPI"    ,"C",10,0})
aAdd(aStru,{"DESCRI"    ,"C",30,0})
aAdd(aStru,{"DENOM"     ,"C",58,0})
aAdd(aStru,{"CODLMT"    ,"C",46,0})
aAdd(aStru,{"CODISO"    ,"C",30,0})
aAdd(aStru,{"CLASSE"    ,"C",10,0})
aAdd(aStru,{"CODFABRI"  ,"C",02,0})
aAdd(aStru,{"GRUPO"     ,"C",04,0})
aAdd(aStru,{"SUBGRUPO"  ,"C",30,0})
aAdd(aStru,{"ESTSTATBR" ,"C",10,0})
aAdd(aStru,{"ESTSTATFO" ,"C",10,0})
aAdd(aStru,{"PERTLP"    ,"C",01,0})
aAdd(aStru,{"LISTAFOR"  ,"N",14,4})
aAdd(aStru,{"DESCONTO"  ,"N",14,4})
aAdd(aStru,{"TRANSPR"   ,"N",14,4})
aAdd(aStru,{"CUSTO"     ,"N",14,4})
aAdd(aStru,{"CUSTO04"   ,"N",14,4})
aAdd(aStru,{"LISTABR"   ,"N",14,4})
aAdd(aStru,{"ALIQICMS"  ,"N",06,2})
aAdd(aStru,{"ALIQIPI"   ,"N",06,2})
aAdd(aStru,{"ALIQIMP"   ,"N",06,2})
aAdd(aStru,{"ESTFIS"    ,"N",10,0})
aAdd(aStru,{"ESTDISP"   ,"N",10,0})
aAdd(aStru,{"PREVENT"   ,"N",10,0})
aAdd(aStru,{"FATQUANT"  ,"N",10,0})
aAdd(aStru,{"FATLIQ"    ,"N",14,4})
aAdd(aStru,{"FATBRUT"   ,"N",14,4})
aAdd(aStru,{"DEVOLIQ"   ,"N",14,4})
aAdd(aStru,{"FAT2QUANT" ,"N",10,0})
aAdd(aStru,{"FAT2LIQ"   ,"N",14,4})
aAdd(aStru,{"FAT2BRUT"  ,"N",14,4})
aAdd(aStru,{"DEVO2LIQ"  ,"N",14,4})
aAdd(aStru,{"PER1"      ,"D",08,0})
aAdd(aStru,{"PER2"      ,"D",08,0})
aAdd(aStru,{"CLIENTE"   ,"C",20,0})
aAdd(aStru,{"AREA"      ,"C",05,0})
aAdd(aStru,{"REGIAO"    ,"C",03,0})
aAdd(aStru,{"DESGRUPO"  ,"C",30,0})
aAdd(aStru,{"ORDGRUPO"  ,"C",03,0})
aAdd(aStru,{"CFO"       ,"C",05,0})
aAdd(aStru,{"DESCO"     ,"N",14,2})
aAdd(aStru,{"IPI"       ,"N",14,2})
aAdd(aStru,{"ICM"       ,"N",14,2})
aAdd(aStru,{"PIS"       ,"N",14,2})
aAdd(aStru,{"COF"       ,"N",14,2})
aAdd(aStru,{"FRETE"		,"N",14,2})
aAdd(aStru,{"DOC"       ,"C",09,0})
aAdd(aStru,{"EMISSAO"   ,"D",08,0})
aAdd(aStru,{"CODCLI"    ,"C",08,0})
aAdd(aStru,{"TIPO"      ,"C",01,0})
aAdd(aStru,{"NOME"      ,"C",40,0})
aAdd(aStru,{"CGC"       ,"C",14,0})
aAdd(aStru,{"VEND"      ,"C",06,0})
aAdd(aStru,{"NVEND"     ,"C",15,0})
aAdd(aStru,{"DIFAL"     ,"N",14,2})
aAdd(aStru,{"ICMSCOM"   ,"N",14,2})
aAdd(aStru,{"ICMSRET"   ,"N",14,2})
aAdd(aStru,{"MC"        ,"N",10,2})
aAdd(aStru,{"MC2"       ,"N",10,2})

cArq := CriaTrab(aStru,.T.)
dbUseArea(.T.,,cArq,"TRB",.T.)
cInd := CriaTrab(NIL,.F.)
IndRegua("TRB",cArq,"CODINT + CLIENTE + DOC",,,"Aguarde...")
dbSetIndex(cArq+OrdBagExt())

If mv_par05 == 1
	cmv_par05 := "S"
ElseIf mv_par05 == 2
	cmv_par05 := "N"
ElseIf mv_par05 == 3
	cmv_par05 := "A"
Else
	cmv_par05 := " "
Endif
/*
Set SoftSeek On
dbSelectArea("SB1")
dbSetOrder(1)
dbSeek(xFilial("SB1") +mv_par03)    // padr('BIFIHAS00000334',15) )  
*/
If Select("TRB1") > 0
	TRB1->(DbCloseArea())
Endif   

cQry := "SELECT DISTINCT D2_COD AS COD FROM " + RetSqlName("SD2") + " SD2 "  
cQry += " WHERE SD2.D_E_L_E_T_ = '' "
cQry += " AND D2_FILIAL = '" + xFilial('SD2') + "' " 
cQry += " AND D2_EMISSAO >= '20150101' "//BETWEEN '"+dtos(mv_par06)+"' AND '"+dtos(mv_par07)+"' " 
cQry += " AND D2_TIPO NOT IN  ('D') "
//cQry += " AND D2_CF NOT IN ('5551') "
cQry += " UNION  "
cQry += " SELECT DISTINCT D1_COD AS COD FROM " + RetSqlName("SD1") + " SD1 "  
cQry += " WHERE SD1.D_E_L_E_T_ = '' "
cQry += " AND D1_FILIAL = '" + xFilial('SD1') + "' " 
cQry += " AND D1_DTDIGIT  >= '20150101' "//BETWEEN '"+dtos(mv_par06)+"' AND '"+dtos(mv_par07)+"' " 
cQry += " AND D1_TIPO = 'D' "
cQry += " UNION "
cQry += " SELECT DISTINCT C6_PRODUTO AS COD FROM " + RetSqlName("SC6") + " SC6 "  
cQry += " WHERE SC6.D_E_L_E_T_ <> '*' "
cQry += " AND C6_FILIAL = '" + xFilial('SC6') + "' " 
cQry += " AND (C6_QTDENT < C6_QTDVEN) AND C6_BLQ <> 'R' "
cQry += " UNION "
cQry += " SELECT DISTINCT C7_PRODUTO AS COD FROM " + RetSqlName("SC7") + " SC7 "  
cQry += " WHERE SC7.D_E_L_E_T_ <> '*' "
cQry += " AND C7_FILIAL = '" + xFilial('SC7') + "' " 
cQry += " AND ((C7_QUANT - C7_QUJE) > 0) AND C7_RESIDUO <> 'S' "
cQry += " ORDER BY COD "

cQry := ChangeQuery(cQry)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TSB1",.F.,.T.)  

DbSelectArea("TSB1")                               
DbGoTop() 

///ProcRegua(LastRec())

TSB1->( dbEVal( { || ++_nTotR1 } , {||!EOF()} ) )
TSB1->(dbgotop()) 

oProcess:SetRegua1( _nTotR1 )
oProcess:SetRegua2( _nTotR1 )  
                             
do While TSB1->(!Eof()) //.and. B1_COD <= mv_par04  //== 'BIFIHAS00000334'  //
    dbSelectArea("SB1")
    dbSetOrder(1)
    dbSeek(xFilial("SB1") +TSB1->COD)    // padr('BIFIHAS00000334',15) )  
    
    If lEnd	//houve cancelamento do processo		
		Exit	
 	EndIf
 	 	
	oProcess:IncRegua1('Processando...  '       )
	oProcess:IncRegua2('Produto  --->>>>   '  + Alltrim(TSB1->COD)   ) 
 	
    

   // If SB1->B1_MSBLQL  <> '1'  
       ///////Continua - produto não bloqueado
	//Else              
	   ///////If SB1->B1_COD == 'BIFIHAS00000334'
	   ////////Else
	//	  TSB1->(dbSkip())
	//	  Loop
	   ///////Endif	  
   // Endif



	///IncProc("Processando produto » " + SB1->B1_COD )
	If B1_PERTLP == cmv_par05 .or. cmv_par05 == " "
		nCusto := 0.00
		nCusto2:= 0.00

		dbSelectArea("SB2")
		dbSetOrder(1)
		Set SoftSeek Off
		dbSeek(xFilial("SB2") + SB1->B1_COD)
		
		dbSelectArea("SBM")
		dbSetOrder(1)
		dbSeek(xFilial("SBM") + SB1->B1_GRUPO)
		DESGRSBM	:= alltrim(SBM->BM_DESC)
		ORDGRSBM    := SBM->BM_ORDEM
		
		if SB1->B1_SUPERGR <> space(3)
			dbSelectArea("SX5")
			dbSetOrder(1)
			dbSeek(xFilial("SX5")+"Z7"+SB1->B1_SUPERGR)
			DESGRSBM	:= alltrim(SX5->X5_DESCRI)
			ORDGRSBM    := SX5->X5_CHAVE
		endif
				
		dbSelectArea("DA1")
		dbSetOrder(1)
		dbSeek(xFilial("DA1") + "001" + SB1->B1_COD)
		
		Set SoftSeek On
		// Pedidos de Venda

		If Select("TRB1") > 0
			TRB1->(DbCloseArea())
		Endif   

		cQry := "SELECT SUM(C6_QTDVEN - C6_QTDENT) AS PEND "
		cQry += " FROM " + RetSqlName("SC6") + " SC6 "  
		cQry += " WHERE SC6.D_E_L_E_T_ <> '*' " 
		cQry += " AND C6_FILIAL = '" + xFilial('SC6') + "' " 
		cQry += " AND (C6_QTDENT < C6_QTDVEN) AND C6_BLQ <> 'R' "
		cQry += " AND C6_PRODUTO = '"+Alltrim(SB1->B1_COD)+"' "

		cQry := ChangeQuery(cQry)
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRB1",.F.,.T.)  

		TcSetField('TRB1',"PEND","N",12,2)

		DbSelectArea("TRB1")                               
		DbGoTop() 
		nPend := TRB1->PEND

		TRB1->(DbCloseArea())
		//Pedidos de Compra
		If Select("TRB2") > 0
			TRB2->(DbCloseArea())
		Endif   

		cQry := "SELECT SUM(C7_QUANT - C7_QUJE) AS SALDO "
		cQry += " FROM " + RetSqlName("SC7") + " SC7 "  
		cQry += " WHERE SC7.D_E_L_E_T_ <> '*' " 
		cQry += " AND C7_FILIAL = '" + xFilial('SC7') + "' " 
		cQry += " AND ((C7_QUANT - C7_QUJE) > 0) AND C7_RESIDUO <> 'S' "
		cQry += " AND C7_PRODUTO = '"+Alltrim(SB1->B1_COD)+"' "

		cQry := ChangeQuery(cQry)
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRB2",.F.,.T.)  

		TcSetField('TRB2',"SALDO","N",12,2)

		DbSelectArea("TRB2")                               
		DbGoTop() 
		nEntra := TRB2->SALDO

		TRB2->(DbCloseArea())
		If mv_par08 == 2  // Movimentos

			If Select("TRB3") > 0
				TRB3->(DbCloseArea())
			Endif   

			cQry := "SELECT * "
			cQry += " FROM " + RetSqlName("SD2") + " SD2 "  
			cQry += " WHERE SD2.D_E_L_E_T_ <> '*' " 
			cQry += " AND D2_FILIAL = '" + xFilial('SD2') + "' " 
			cQry += " AND D2_EMISSAO BETWEEN '"+dtos(dPerIni)+"' AND '"+dtos(dPerFim)+"' " 
			cQry += " AND D2_COD = '"+Alltrim(SB1->B1_COD)+"' "
			cQry += " AND D2_TIPO NOT IN ('D') "
			cQry += " AND D2_CF NOT IN ('5551') "
			If !Empty(mv_par09)
			   cQry += " AND D2_CLIENTE BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' "
			Endif
			cQry := ChangeQuery(cQry)
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRB3",.F.,.T.)  

			TcSetField('TRB3',"D2_QUANT","N",12,2)
			TcSetField('TRB3',"D2_DESCON","N",12,2)
			TcSetField('TRB3',"D2_VALIPI","N",12,2)
			TcSetField('TRB3',"D2_VALFRE","N",12,2)
			TcSetField('TRB3',"D2_TOTAL","N",12,2)
			TcSetField('TRB3',"D2_VALICM","N",12,2)   
			TcSetField('TRB3',"D2_ICMSRET","N",12,2)   
			TcSetField('TRB3',"D2_VALIMP1","N",12,2)
			TcSetField('TRB3',"D2_VALIMP2","N",12,2)
			TcSetField('TRB3',"D2_VALIMP3","N",12,2)
			TcSetField('TRB3',"D2_VALIMP4","N",12,2)
			TcSetField('TRB3',"D2_VALIMP5","N",12,2)
			TcSetField('TRB3',"D2_VALIMP6","N",12,2)
			TcSetField('TRB3',"D2_CUSTO1","N",12,2)
			TcSetField('TRB3',"D2_EMISSAO","D",8,0)
			TcSetField('TRB3',"D2_DIFAL","N",12,2)
			TcSetField('TRB3',"D2_ICMSCOM","N",12,2)  
		
			DbSelectArea("TRB3")                               
			DbGoTop() 

			nQuant := 0.00
			nLiq   := 0.00
			nBrut  := 0.00
			nDevo  := 0.00
			nCusto := 0.00
			nQuant2:= 0.00
			nLiq2  := 0.00
			nBrut2 := 0.00
			nDevo2 := 0.00
			nCusto2:= 0.00
			
			do While TRB3->(!Eof()) //.and. xFilial("SD2") == D2_FILIAL .and. D2_COD == SB1->B1_COD
				If TRB3->D2_TIPO =="B" 
					dbSelectArea("SA2")
					dbSetOrder(1)
					dbSeek(xFilial("SA2") + TRB3->(D2_CLIENTE +D2_LOJA) )
					xcA1NREDUZ 	:= A2_NREDUZ
					xcA1AREA	:= "AMZ5N"
					xcA1REGIAO	:= "SPZ"
					xcA1COD		:= A2_COD
					xcA1LOJA	:= A2_LOJA
					xcA1NOME	:= A2_NOME
					xcA1CGC		:= A2_CGC
					xcA1VEND	:= "999999"
				Else
					dbSelectArea("SA1")
					dbSetOrder(1)
					dbSeek(xFilial("SA1") + TRB3->(D2_CLIENTE + D2_LOJA) )
					xcA1NREDUZ 	:= A1_NREDUZ
					xcA1AREA	:= A1_AREA
					xcA1REGIAO	:= A1_REGIAO
					xcA1COD		:= A1_COD
					xcA1LOJA	:= A1_LOJA
					xcA1NOME	:= A1_NOME
					xcA1CGC		:= A1_CGC
					xcA1VEND	:= A1_VEND
				Endif				
				dbSelectArea("SA3")
				dbSetOrder(1)
				dbSeek(xFilial("SA3") + xcA1VEND)
				//dbSelectArea("SD2")
				dbSelectArea("TRB3")
				//If TRB3->D2_CLIENTE < mv_par09 .or. TRB3->D2_CLIENTE > mv_par10 .or.;
				If 	xcA1AREA < mv_par11 .or. xcA1AREA > mv_par12 .or.;
					xcA1REGIAO < mv_par13 .or. xcA1REGIAO > mv_par14
					dbSelectArea("TRB3")
					TRB3->(dbSkip())
					Loop
				Endif
				//If Year(D2_EMISSAO)>2004
					dbSelectArea("SF4")
					dbSetOrder(1)
					dbSeek(xFilial("SF4") + TRB3->D2_TES)
					If F4_DUPLIC == "N"  //.or. TRB3->D2_TIPO == "D" .OR. Substr(F4_CF,1,4)=="5551"
						//dbSelectArea("SD2")
						dbSelectArea("TRB3")
						TRB3->(dbSkip())
						Loop
					Endif
				//Endif
				dbSelectArea("TRB3") //SD2")
				
				//If Year(D2_EMISSAO)<=2004 .and. 
                If TRB3->D2_TES == "691"  // TES de Serviços deve entrar
                   //continua
                Else   
				   If !(Substr(ALLTRIM(TRB3->D2_CF),2,3) $ "111,112,107,108,102,101,110,109,401,403") 
					   TRB3->(dbSkip())
					   Loop
				   Endif
				Endif
				
				If TRB3->D2_EMISSAO >= mv_par01 .and. TRB3->D2_EMISSAO <= mv_par02
					nQuant := TRB3->D2_QUANT
					nLiq   := TRB3->D2_TOTAL - TRB3->D2_VALICM - TRB3->D2_VALIMP1 - TRB3->D2_VALIMP2 - TRB3->D2_VALIMP3 - TRB3->D2_VALIMP4 - TRB3->D2_VALIMP5 - TRB3->D2_VALIMP6 - TRB3->D2_DIFAL - TRB3->D2_ICMSCOM   // Alterado Regina 15/08/17
					nBrut  := TRB3->D2_TOTAL +  TRB3->D2_VALFRE + TRB3->D2_VALIPI + TRB3->D2_ICMSRET //IIF(SD2->D2_TIPO=="P", 0 , TRB3->D2_VALIPI) +
					nCusto := TRB3->D2_CUSTO1
				Else
					nQuant := 0
					nLiq   := 0
					nBrut  := 0
					nCusto := 0
				Endif
				
				If TRB3->D2_EMISSAO >= mv_par06 .and. TRB3->D2_EMISSAO <= mv_par07
					nQuant2:= TRB3->D2_QUANT
					nLiq2  := TRB3->D2_TOTAL - TRB3->D2_VALICM - TRB3->D2_VALIMP1 - TRB3->D2_VALIMP2 - TRB3->D2_VALIMP3 - TRB3->D2_VALIMP4 - TRB3->D2_VALIMP5 - TRB3->D2_VALIMP6 - TRB3->D2_DIFAL - TRB3->D2_ICMSCOM   //Alterado Regina 15/08/17
					nBrut2 := TRB3->D2_TOTAL + TRB3->D2_VALFRE + TRB3->D2_VALIPI  + TRB3->D2_ICMSRET  // + IIF(TRB3->D2_TIPO=="P", 0 , TRB3->D2_VALIPI)
					nCusto2:= TRB3->D2_CUSTO1
				Else
					nQuant2:= 0
					nLiq2  := 0
					nBrut2 := 0
					nCusto2:= 0
				Endif
				If Iif(TRB3->D2_TIPO $ "C/P" , .T. , nQuant + nQuant2 > 0 )
					dbSelectArea("TRB")
  //				lAchou := dbSeek(SB1->B1_COD + SA1->A1_NREDUZ + SD2->D2_DOC)
					RecLock("TRB",.T.)
					CODINT		:= SB1->B1_COD
					POSIPI		:= SB1->B1_POSIPI
					DESCRI  	:= SB1->B1_DESC
					DENOM   	:= SB1->B1_DENOM
					CODLMT  	:= SB1->B1_CODLMT
					CODISO  	:= SB1->B1_CODISO
					CLASSE  	:= SB1->B1_CLASSE
					CODFABRI	:= SB1->B1_FABRIC
					GRUPO   	:= SB1->B1_GRUPO
					SUBGRUPO	:= " "
					ESTSTATBR   := SB1->B1_STATUS
					ESTSTATFO   := " "
					PERTLP		:= SB1->B1_PERTLP
					LISTAFOR    := SB1->B1_PREURO
					DESCONTO    := SB1->B1_DESCONT
					TRANSPR     := SB1->B1_TRANSPR
					CUSTO       := nCusto
					CUSTO04		:= nCusto2
					LISTABR     := DA1->DA1_PRCVEN
					ALIQICMS    := SB1->B1_PICM
					ALIQIPI     := SB1->B1_IPI
					ALIQIMP     := 0
					ESTFIS      := SB2->B2_QATU
					ESTDISP     := SB2->B2_QATU - nPend
					PREVENT     := nEntra
					FATQUANT    := nQuant
					FATLIQ      := nLiq
					FATBRUT     := nBrut
					DEVOLIQ     := nDevo
					FAT2QUANT   := nQuant2
					FAT2LIQ     := nLiq2
					FAT2BRUT    := nBrut2
					DEVO2LIQ    := nDevo2
					PER1		:= mv_par01
					PER2		:= mv_par02
					CLIENTE	    := xcA1NREDUZ
					AREA		:= xcA1AREA
					REGIAO		:= xcA1REGIAO
//					DESGRUPO	:= SBM->BM_DESC
//					ORDGRUPO    := SBM->BM_ORDEM
					DESGRUPO	:= DESGRSBM
					ORDGRUPO    := ORDGRSBM
					CFO			:= TRB3->D2_CF
					DESCO		:= TRB3->D2_DESCON
					IPI			:= TRB3->D2_VALIPI
					ICM			:= TRB3->D2_VALICM
					PIS			:= TRB3->D2_VALIMP6
					COF			:= TRB3->D2_VALIMP5
					FRETE		:= TRB3->D2_VALFRE
					DOC			:= TRB3->D2_DOC
					EMISSAO		:= TRB3->D2_EMISSAO
					CODCLI		:= xcA1COD + xcA1LOJA
					TIPO		:= TRB3->D2_TIPO
					NOME		:= xcA1NOME
					CGC			:= xcA1CGC
					VEND		:= xcA1VEND
					NVEND		:= SA3->A3_NREDUZ  
					DIFAL       := TRB3->D2_DIFAL
                    ICMSCOM     := TRB3->D2_ICMSCOM
                    ICMSRET     := TRB3->D2_ICMSRET
                                        
					msUnlock()
					RecLock("TRB",.F.)
					MC 		:= IIF(FATLIQ==0,0,((FATLIQ - CUSTO ) / FATLIQ ) * 100)
					MC2		:= iif(FAT2LIQ==0,0,((FAT2LIQ - CUSTO04 ) / FAT2LIQ ) * 100)
					msUnlock()
				Endif
				
				//dbSelectArea("SD2")
				dbSelectArea("TRB3")
				TRB3->(dbSkip())
			Enddo

			TRB3->(DbCloseArea())
			
			// Devoluções

			If Select("TRB4") > 0
				TRB4->(DbCloseArea())
			Endif   

			cQry := "SELECT * "
			cQry += " FROM " + RetSqlName("SD1") + " SD1 "  
			cQry += " WHERE SD1.D_E_L_E_T_ <> '*' " 
			cQry += " AND D1_FILIAL = '" + xFilial('SD1') + "' " 
			cQry += " AND D1_DTDIGIT BETWEEN '"+dtos(dPerIni)+"' AND '"+dtos(dPerFim)+"' " 
			cQry += " AND D1_COD = '"+Alltrim(SB1->B1_COD)+"' "
			cQry += " AND D1_TIPO = 'D'  "
			cQry += " AND ( D1_CF IN ('1201','1202','2201','2202','1411','2411','1412','2412') OR "
			cQry += "       D1_TES IN ('048','049','050','169','218','238','248','254','255','260','269','274','275') ) "
			If !Empty(mv_par09)
			   cQry += " AND D1_FORNECE BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' "
			Endif
			cQry := ChangeQuery(cQry)
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRB4",.F.,.T.)  

			TcSetField('TRB4',"D1_QUANT","N",12,2)
			TcSetField('TRB4',"D1_VALDESC","N",12,2)
			TcSetField('TRB4',"D1_IPI","N",12,2)
			TcSetField('TRB4',"D1_VALFRE","N",12,2)
			TcSetField('TRB4',"D1_TOTAL","N",12,2)
			TcSetField('TRB4',"D1_VALICM","N",12,2)
			TcSetField('TRB4',"D1_ICMSRET","N",12,2)
			TcSetField('TRB4',"D1_VALIMP1","N",12,2)
			TcSetField('TRB4',"D1_VALIMP2","N",12,2)
			TcSetField('TRB4',"D1_VALIMP3","N",12,2)
			TcSetField('TRB4',"D1_VALIMP4","N",12,2)
			TcSetField('TRB4',"D1_VALIMP5","N",12,2)
			TcSetField('TRB4',"D1_VALIMP6","N",12,2)
			TcSetField('TRB4',"D1_CUSTO","N",12,2)
			TcSetField('TRB4',"D1_DTDIGIT","D",8,0)

			DbSelectArea("TRB4")                               
			DbGoTop()              
			
			Do While TRB4->(!Eof())
/*
			dbSelectArea("SD1")
			dbSetOrder(2)
			dbSeek(xFilial("SD1") + SB1->B1_COD)
			do While !Eof() .and. xFilial("SD1") == D1_FILIAL .and. D1_COD == SB1->B1_COD
*/
				dbSelectArea("SA1")
				dbSetOrder(1)
				dbSeek(xFilial("SA1") + TRB4->(D1_FORNECE +D1_LOJA))
				dbSelectArea("SA3")
				dbSetOrder(1)
				dbSeek(xFilial("SA3") + SA1->A1_VEND)
				dbSelectArea("SF4")
				dbSetOrder(1)
				dbSeek(xFilial("SF4") + TRB4->D1_TES)
				dbSelectArea("TRB4")
//				If D1_FORNECE < mv_par09 .or. D1_FORNECE > mv_par10 .or.;
				If	SA1->A1_AREA < mv_par11 .or. SA1->A1_AREA > mv_par12 .or.;
					SA1->A1_REGIAO < mv_par13 .or. SA1->A1_REGIAO > mv_par14
					dbSelectArea("TRB4")
					TRB4->(dbSkip())
					Loop
				Endif
				
//				If (Trim(D1_CF) $ "1201,1202,2201,2202" .AND. Year(D1_DTDIGIT)==2004) .or.;
//					(D1_TIPO == "D" .AND. Year(D1_DTDIGIT) > 2004 .and. 
				If 	SF4->F4_DUPLIC == "S"
					
					If TRB4->D1_DTDIGIT >= mv_par01 .and. TRB4->D1_DTDIGIT <= mv_par02
						nQuant := TRB4->D1_QUANT * (-1)
						nLiq   := (TRB4->D1_TOTAL-TRB4->D1_VALDESC - TRB4->D1_VALICM - TRB4->D1_VALIMP1 - TRB4->D1_VALIMP2 - TRB4->D1_VALIMP3 - TRB4->D1_VALIMP4 - TRB4->D1_VALIMP5 - TRB4->D1_VALIMP6) * (-1)
						nBrut  := (TRB4->D1_TOTAL + TRB4->D1_VALIPI + TRB4->D1_VALFRE + TRB4->D1_ICMSRET) * (-1)
						nDevo  := (TRB4->D1_TOTAL-TRB4->D1_VALDESC - TRB4->D1_VALICM - TRB4->D1_VALIMP1 - TRB4->D1_VALIMP2 - TRB4->D1_VALIMP3 - TRB4->D1_VALIMP4 - TRB4->D1_VALIMP5 - TRB4->D1_VALIMP6)
						nCusto := TRB4->D1_CUSTO * (-1)
					Else
						nQuant := 0
						nLiq   := 0
						nBrut  := 0
						nDevo  := 0
						nCusto := 0
					Endif
					If TRB4->D1_DTDIGIT >= mv_par06 .and. TRB4->D1_DTDIGIT <= mv_par07
						nQuant2:= TRB4->D1_QUANT * (-1)
						nLiq2  := (TRB4->D1_TOTAL- TRB4->D1_VALDESC - TRB4->D1_VALICM - TRB4->D1_VALIMP1 - TRB4->D1_VALIMP2 - TRB4->D1_VALIMP3 - TRB4->D1_VALIMP4 - TRB4->D1_VALIMP5 - TRB4->D1_VALIMP6) * (-1)
						nBrut2 := (TRB4->D1_TOTAL + TRB4->D1_VALIPI + TRB4->D1_VALFRE + TRB4->D1_ICMSRET) * (-1)
						nDevo2 := (TRB4->D1_TOTAL-TRB4->D1_VALDESC - TRB4->D1_VALICM - TRB4->D1_VALIMP1 - TRB4->D1_VALIMP2 - TRB4->D1_VALIMP3 - TRB4->D1_VALIMP4 - TRB4->D1_VALIMP5 - TRB4->D1_VALIMP6)
						nCusto2 := TRB4->D1_CUSTO * (-1)
					Else
						nQuant2 := 0
						nLiq2   := 0
						nBrut2  := 0
						nDevo2  := 0
						nCusto2 := 0
					Endif
					
					dbSelectArea("TRB")
//					lAchou := dbSeek(SB1->B1_COD + SA1->A1_NREDUZ + SD2->D2_DOC)
					RecLock("TRB",.T.)
					CODINT		:= SB1->B1_COD   
					POSIPI		:= SB1->B1_POSIPI					
					DESCRI  	:= SB1->B1_DESC
					DENOM   	:= SB1->B1_DENOM
					CODLMT  	:= SB1->B1_CODLMT
					CODISO  	:= SB1->B1_CODISO
					CLASSE  	:= SB1->B1_CLASSE
					CODFABRI	:= SB1->B1_FABRIC
					GRUPO   	:= SB1->B1_GRUPO
					SUBGRUPO	:= " "
					ESTSTATBR   := SB1->B1_STATUS
					ESTSTATFO   := " "
					PERTLP		:= SB1->B1_PERTLP
					LISTAFOR    := SB1->B1_PREURO
					DESCONTO    := SB1->B1_DESCONT
					TRANSPR     := SB1->B1_TRANSPR
					CUSTO       := nCusto
					CUSTO04		:= nCusto2
					LISTABR     := DA1->DA1_PRCVEN
					ALIQICMS    := SB1->B1_PICM
					ALIQIPI     := SB1->B1_IPI
					ALIQIMP     := 0
					ESTFIS      := SB2->B2_QATU
					ESTDISP     := SB2->B2_QATU - nPend
					PREVENT     := nEntra
					FATQUANT    := nQuant
					FATLIQ      := nLiq
					FATBRUT     := nBrut
					DEVOLIQ     := nDevo
					FAT2QUANT   := nQuant2
					FAT2LIQ     := nLiq2
					FAT2BRUT    := nBrut2
					DEVO2LIQ    := nDevo2
					PER1		:= mv_par01
					PER2		:= mv_par02
					CLIENTE	    := SA1->A1_NREDUZ
					AREA		:= SA1->A1_AREA
					REGIAO		:= SA1->A1_REGIAO
//					DESGRUPO	:= SBM->BM_DESC
//					ORDGRUPO    := SBM->BM_ORDEM
					DESGRUPO	:= DESGRSBM
					ORDGRUPO    := ORDGRSBM
					CFO			:= TRB4->D1_CF
					DESCO		:= TRB4->D1_DESC
					IPI			:= TRB4->D1_VALIPI
					ICM			:= TRB4->D1_VALICM
					PIS			:= TRB4->D1_VALIMP6
					COF			:= TRB4->D1_VALIMP5
					FRETE		:= TRB4->D1_VALFRE
					DOC			:= TRB4->D1_DOC
					EMISSAO		:= TRB4->D1_DTDIGIT
					CODCLI		:= SA1->A1_COD+SA1->A1_LOJA
					TIPO		:= TRB4->D1_TIPO
					NOME		:= SA1->A1_NOME
					CGC			:= SA1->A1_CGC
					VEND		:= SA1->A1_VEND
					NVEND		:= SA3->A3_NREDUZ
					DIFAL		:= 0 ///" "
					ICMSCOM		:= 0 ///" " 
					ICMSRET		:= TRB4->D1_ICMSRET
					
					msUnlock()
					RecLock("TRB",.F.)
					MC 			:= IIF(FATLIQ==0,0,((FATLIQ - CUSTO ) / FATLIQ ) * 100)
					MC2	 		:= iif(FAT2LIQ==0,0,((FAT2LIQ - CUSTO04 ) / FAT2LIQ ) * 100)
					msUnlock()
					
				Endif
				dbSelectArea("TRB4") //SD1")
				TRB4->(dbSkip())
			Enddo

			TRB4->(DbCloseArea())
						
		Else  // Produtos
			
			dbSelectArea("TRB")
			RecLock("TRB",.T.)
			CODINT		:= SB1->B1_COD
			POSIPI		:= SB1->B1_POSIPI			
			DESCRI  	:= SB1->B1_DESC
			DENOM   	:= SB1->B1_DENOM
			CODLMT  	:= SB1->B1_CODLMT
			CODISO  	:= SB1->B1_CODISO
			CLASSE  	:= SB1->B1_CLASSE
			CODFABRI	:= SB1->B1_FABRIC
			GRUPO   	:= SB1->B1_GRUPO
			SUBGRUPO	:= " "
			ESTSTATBR   := SB1->B1_STATUS
			ESTSTATFO   := " "
			PERTLP		:= SB1->B1_PERTLP
			LISTAFOR    := SB1->B1_PREURO
			DESCONTO    := SB1->B1_DESCONT
			TRANSPR     := SB1->B1_TRANSPR
			CUSTO       := nCusto
			CUSTO04		:= nCusto2
			LISTABR     := DA1->DA1_PRCVEN
			ALIQICMS    := SB1->B1_PICM
			ALIQIPI     := SB1->B1_IPI
			ALIQIMP     := 0
			ESTFIS      := SB2->B2_QATU
			ESTDISP     := SB2->B2_QATU - nPend
			PREVENT     := nEntra
			PER1		:= mv_par01
			PER2		:= mv_par02
//			DESGRUPO	:= SBM->BM_DESC
//			ORDGRUPO    := SBM->BM_ORDEM
			DESGRUPO	:= DESGRSBM
			ORDGRUPO    := ORDGRSBM
			
			msUnlock()
		Endif
		
	Else           // Fora da lista de precos
	Endif
	dbSelectArea("TSB1")
	TSB1->(dbSkip())
Enddo

mpasta := "\" + AllTrim(mv_par15) + "\GERAPLAN.CSV"
ferase(mpasta)   

cPATH:= 'C:\TEMP\'
cFileName   := "GERAPLAN"+"_"+DTOS(DATE())+"_"+_cHrIni+"_"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)+".CSV"
cDestino	:= PADR(cPATH+cFileName, 100)

//CABEÇALHO
For nXX := 1 to Len(aStru)
	cFields += aStru[nXX][1] + ";"//Nome do campo
Next
cFields := Left(cFields, Len(cFields) -1) //Remover a ultimo ponto e virgula vírgula
U_ArqLog(cFields,cDestino,"")

dbselectarea("TRB")
dbgotop()         
	
While !TRB->(EOF())
		///IncProc()
		RecLock("TRB", .F.)

		cDetal:= ""
		cDetal+= cValToChar(CODINT)   	+ ";"	
		cDetal+= cValToChar(POSIPI)   	+ ";"
		cDetal+= cValToChar(DESCRI)   	+ ";"
		cDetal+= cValToChar(DENOM)   	+ ";"
		cDetal+= cValToChar(CODLMT)   	+ ";"
		cDetal+= cValToChar(CODISO)   	+ ";"
		cDetal+= cValToChar(CLASSE)   	+ ";"
		cDetal+= cValToChar(CODFABRI)   + ";"
		cDetal+= cValToChar(GRUPO)   	+ ";"
		cDetal+= cValToChar(SUBGRUPO)   + ";"
		cDetal+= cValToChar(ESTSTATBR)  + ";"
		cDetal+= cValToChar(ESTSTATFO)  + ";"
		cDetal+= cValToChar(PERTLP)   	+ ";"
		cDetal+= StrTran(cValToChar(LISTAFOR),".", ",") + ";"
		cDetal+= StrTran(cValToChar(DESCONTO),".", ",") + ";"
		cDetal+= StrTran(cValToChar(TRANSPR) ,".", ",")	+ ";"
		cDetal+= StrTran(cValToChar(CUSTO)   ,".", ",")	+ ";"
		cDetal+= StrTran(cValToChar(CUSTO04) ,".", ",") + ";"
		cDetal+= StrTran(cValToChar(LISTABR) ,".", ",") + ";"
		cDetal+= StrTran(cValToChar(ALIQICMS),".", ",") + ";"
		cDetal+= StrTran(cValToChar(ALIQIPI) ,".", ",") + ";"
		cDetal+= StrTran(cValToChar(ALIQIMP) ,".", ",") + ";"
		cDetal+= cValToChar(ESTFIS)   	+ ";"
		cDetal+= cValToChar(ESTDISP)   	+ ";"
		cDetal+= cValToChar(PREVENT)   	+ ";"
		cDetal+= cValToChar(FATQUANT)   + ";"
		cDetal+= StrTran(cValToChar(FATLIQ) ,".", ",")	+ ";"
		cDetal+= StrTran(cValToChar(FATBRUT),".", ",") 	+ ";"
		cDetal+= StrTran(cValToChar(DEVOLIQ),".", ",") 	+ ";"
		cDetal+= cValToChar(FAT2QUANT)  + ";"
		cDetal+= StrTran(cValToChar(FAT2LIQ) ,".", ",")	+ ";"
		cDetal+= StrTran(cValToChar(FAT2BRUT),".", ",") + ";"
		cDetal+= StrTran(cValToChar(DEVO2LIQ),".", ",") + ";"
		cDetal+= cValToChar(PER1)   	+ ";"
		cDetal+= cValToChar(PER2)   	+ ";"
		cDetal+= cValToChar(CLIENTE)   	+ ";"
		cDetal+= cValToChar(AREA)   	+ ";"
		cDetal+= cValToChar(REGIAO)   	+ ";"
		cDetal+= cValToChar(DESGRUPO)   + ";"
		cDetal+= cValToChar(ORDGRUPO)   + ";"
		cDetal+= cValToChar(CFO)   		+ ";"
		cDetal+= StrTran(cValToChar(DESCO),".", ",")	+ ";"
		cDetal+= StrTran(cValToChar(IPI)  ,".", ",") 	+ ";"
		cDetal+= StrTran(cValToChar(ICM)  ,".", ",") 	+ ";"
		cDetal+= StrTran(cValToChar(PIS)  ,".", ",") 	+ ";"
		cDetal+= StrTran(cValToChar(COF)  ,".", ",") 	+ ";"
		cDetal+= StrTran(cValToChar(FRETE),".", ",")   	+ ";"
		cDetal+= cValToChar(DOC)   		+ ";"
		cDetal+= cValToChar(EMISSAO)   	+ ";"
		cDetal+= cValToChar(CODCLI)   	+ ";"
		cDetal+= cValToChar(TIPO)   	+ ";"
		cDetal+= cValToChar(NOME)   	+ ";"
		cDetal+= cValToChar(CGC)   		+ ";"
		cDetal+= cValToChar(VEND)   	+ ";"
		cDetal+= cValToChar(NVEND)   	+ ";"
		cDetal+= StrTran(cValToChar(DIFAL)  ,".", ",") 	+ ";"
		cDetal+= StrTran(cValToChar(ICMSCOM),".", ",")  + ";"
		cDetal+= StrTran(cValToChar(ICMSRET),".", ",")  + ";"
		cDetal+= StrTran(cValToChar(MC)   	,".", ",")	+ ";"
		cDetal+= StrTran(cValToChar(MC2)   	,".", ",")
		
		U_ArqLog(cDetal,cDestino,"")

		TRB->(MsUnLock())
		TRB->(DbSkip())
		
EndDo
			
TRB->(DbCloseArea())

MsgBox("Foi gerado o arquivo GERAPLAN na pasta: "+CHR(13)+CHR(10)+cDestino,"Atenção","ALERT")

If ApOleClient("MsExcel")  
	oExcelApp:= MsExcel():New()
	oExcelApp:WorkBooks:Open(cDestino)
	oExcelApp:SetVisible(.T.)
EndIf

//dbselectarea("TRB")
//dbgotop()
//COPY TO &mpasta
//Processa({||CpyS2T(mpasta,"C:\",.T.)},"Copiando Arquivo","Aguarde...",.F.)

/////TRB->(DBCLOSEAREA())
mTESTE := "1;0;1;GIS"  // "EM DISCO;ATUALIZA;1 COPIA;NOME REL."
If mv_par08 == 1
//	CALLCRYS("GERAPLAN",,mTESTE)
Endif
If mv_par08 == 2
//	CALLCRYS("GERAGRU",,mTESTE)
Endif
If mv_par08 == 3
//	CALLCRYS("GERAARE",,mTESTE)
Endif
If mv_par08 == 4
//	CALLCRYS("GERACLI",,mTESTE)
Endif

Set SoftSeek Off
Return

// ***************************************************************************************

Static Function AjustaSX1()
Local nXX := 0 
aPerg    := {}
//cPerg    := "GERAPX"

Aadd( aPerg , { "Da Data (ano corr)?" , "D" , 08 })
Aadd( aPerg , { "Ate Data(ano corr)?" , "D" , 08 })
Aadd( aPerg , { "Do Produto        ?" , "C" , 15 })
Aadd( aPerg , { "Ate Produto       ?" , "C" , 15 })
Aadd( aPerg , { "Pertence Lista Pre?" , "N" , 01 })
Aadd( aPerg , { "Da Data (ano ante)?" , "D" , 08 })
Aadd( aPerg , { "Ate Data(ano ante)?" , "D" , 08 })
Aadd( aPerg , { "Imprime           ?" , "N" , 01 })
Aadd( aPerg , { "Do Cliente        ?" , "C" , 06 })
Aadd( aPerg , { "Ate Cliente       ?" , "C" , 06 })
Aadd( aPerg , { "Da Area           ?" , "C" , 05 })
Aadd( aPerg , { "Ate Area          ?" , "C" , 05 })
Aadd( aPerg , { "Da Regiao         ?" , "C" , 05 })
Aadd( aPerg , { "Ate Regiao        ?" , "C" , 05 })
Aadd( aPerg , { "Pasta p/ gerar arq?" , "C" , 30 })

For nXX := 1 to Len( aPerg )
	If !SX1->( DbSeek( cPerg + StrZero( nXX , 2 ) ) )
		RecLock( "SX1" , .T. )
		SX1->X1_GRUPO     := cPerg
		SX1->X1_ORDEM     := StrZero( nXX , 2 )
		SX1->X1_PERGUNT   := aPerg[nXX][1]
		SX1->X1_VARIAVL   := "mv_ch" + Str( nXX , 1 )
		SX1->X1_TIPO      := aPerg[nXX][2]
		SX1->X1_TAMANHO   := aPerg[nXX][3]
		SX1->X1_PRESEL    := 1
		SX1->X1_GSC       := "G"
		SX1->X1_VAR01     := "mv_par" + StrZero( nXX , 2 )
		If nxx == 5
			SX1->X1_GSC   := "C"
			SX1->X1_DEF01 := "Sim"
			SX1->X1_DEF02 := "Nao"
			SX1->X1_DEF03 := "Analisado"
			SX1->X1_DEF03 := "Todos"
		EndIf
		If nxx == 8
			SX1->X1_GSC   := "C"
			SX1->X1_DEF01 := "Produtos"
			SX1->X1_DEF02 := "Produtos+Movimentos"
		EndIf
		SX1->(MsUnlock())
	EndIf
Next nXX
Return Nil
