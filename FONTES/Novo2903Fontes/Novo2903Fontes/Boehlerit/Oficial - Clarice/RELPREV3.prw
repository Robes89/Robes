#INCLUDE "rwmake.ch"
                          
// Rotina		: RELPREV3
// Descrição	: Carteira de Pedidos com apresentação do estoque
// Data			: Mar/2010
// Autor        : Wilson Santos


////////////////////////////////////////////////////////////////////////////
//  Inclusão da Coluna Peso Líquido - 05/01/2021                          //
//  Filtro para Agilizar o Processamento  - 31/03/2022                    //
//  Autor : Clarice Magyar Kun - Triyo Consultoria                        //
////////////////////////////////////////////////////////////////////////////

User Function RELPREV3()
Private oProcess 

// mv_par01 - Do  Produto
// mv_par02 - Até Produto
// mv_par03 - Da data de entrega
// mv_par04 - Ate data de entrega
// mv_par05 - Do  Vendedor
// mv_par06 - Até Vendedor 
// mv_par07 - Do cliente
// mv_par08 - Ate cliente
// mv_par09 - Abate Impostos  (Sim / Nao / Merc ) 
// mv_par10 - Da data de emissao
// mv_par11 - Ate data de emissao
// mv_par12 - Status Pedido (SEDPICO)   
// mv_par13 - Fabricante
// mv_par14 - Somente itens com estoque

//cPerg := "RELPR3"
cPerg    := PadR( 'RELPR3' , Len( SX1->X1_GRUPO ) )
AjustaSX1()
Pergunte(cPerg,.F.)

@ 86,42 TO 283,435 DIALOG oDlg5 TITLE "Carteira de Pedidos com Estoque"
@ 70,080 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
@ 70,118 BMPBUTTON TYPE 1 ACTION OkProc()
@ 70,156 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
@ 23,14 SAY "Geração do arquivo da carteira de pedidos pendentes" size 200,10
@ 33,14 SAY "e com informações do estoque" size 200,10
@ 43,14 SAY ""
@ 8,10 TO 060,180
ACTIVATE DIALOG oDlg5 CENTERED
          
Return

Static Function OkProc()
Close(oDlg5)

///Processa( {|| Runproc() } , "Carteira de Pedidos com Estoque" )
oProcess := MsNewProcess():New( { ||  Runproc(@oProcess, @lEnd)  } , "Carteira de Pedidos com Estoque" , "Aguarde..." , .F. )
oProcess:Activate()	
    
Return

//*******************************************************************************( INICIO )
STATIC FUNCTION Runproc(oProcess, lEnd)
 LOCAL nIpi := 0
 Local oTempTable
 Local aStru	:= {}
 Local cAlias1	:= "TRB"
 Local _nX
 Local _oExcel   := Nil

 Local _cPlan1   := ""
 Local _cTab1    := _cPlan1

 oTempTable := FWTemporaryTable():New( cAlias1 )
  
aAdd(aStru,{"VENDEDOR","C",15,0})
aAdd(aStru,{"PEDIDO"  ,"C",10,0})
aAdd(aStru,{"DTCADA"  ,"D",10,0})
aAdd(aStru,{"DTSOLIC" ,"D",10,0})
aAdd(aStru,{"DTENT"   ,"D",08,0})
aAdd(aStru,{"EMPRESA" ,"C",15,0})
aAdd(aStru,{"PEDCLIE" ,"C",20,0})
aAdd(aStru,{"PRODCLIE","C",30,0})
aAdd(aStru,{"CODLMT"  ,"C",TamSX3( "B1_CODLMT" )[1],0})    
aAdd(aStru,{"PESOLIQ"  ,"N",14,4})           // PESO LIQUIDO // B1_PESO
aAdd(aStru,{"CODIGO"  ,"C",TamSX3( "B1_COD" )[1],0})
aAdd(aStru,{"QTPEDIDO","N",10,0})
aAdd(aStru,{"QTPEND"  ,"N",10,0})
aAdd(aStru,{"VRUNIT"  ,"N",14,4})
aAdd(aStru,{"VRTOTAL" ,"N",14,4})
aAdd(aStru,{"VRLUNIT" ,"N",14,4})
aAdd(aStru,{"DENOM"   ,"C",58,0})
aAdd(aStru,{"EST_TOTAL" ,"N",10,0})
aAdd(aStru,{"EST_COMPR" ,"N",10,0})
aAdd(aStru,{"QT_DESEMBA" ,"N",10,0})     // QUANTIDADE DESEMBARAÇO
aAdd(aStru,{"QT_TRANSIT" ,"N",10,0})     // QUANTIDADE EM TRANSITO
aAdd(aStru,{"QUANT01" ,"N",10,0})
aAdd(aStru,{"ENTREG01","D",10,0})
aAdd(aStru,{"PEDIDO01","C",11,0})
aAdd(aStru,{"QUANT02" ,"N",10,0})
aAdd(aStru,{"ENTREG02","D",10,0})
aAdd(aStru,{"PEDIDO02","C",11,0})
aAdd(aStru,{"QUANT03" ,"N",10,0})
aAdd(aStru,{"ENTREG03","D",10,0})
aAdd(aStru,{"PEDIDO03","C",11,0})
aAdd(aStru,{"IMPOSTOS","C",12,0})
aAdd(aStru,{"DATA1"   ,"D",10,0})
aAdd(aStru,{"DATA2"   ,"D",10,0})
aAdd(aStru,{"CODCLI"  ,"C",06,0})
aAdd(aStru,{"LOJACLI" ,"C",02,0})
aAdd(aStru,{"NOMFANT" ,"C",20,0})
aAdd(aStru,{"CNPJ"    ,"C",15,0})

oTemptable:SetFields( aStru )
///oTempTable:AddIndex("indice1", {"CODIGO + DtoS(DTSOLIC) + PEDIDO"} )
//------------------
//Criação da tabela
//------------------
oTempTable:Create()
///////////////////////////////////////////////////////////////////////////////////////////////// Tabela 1
                   
Set SoftSeek On
cMoeda := "1"

 
dbselectarea("SC6")
//dbSetOrder(12)
dbSetOrder(18)
///ProcRegua(LastRec())

/////   Filtro para Agilizar o Processamento  
SET FILTER TO SC6->C6_QTDENT < SC6->C6_QTDVEN .and. SC6->C6_BLQ <> "R "
dbGoTop()
////////////

oProcess:SetRegua1(LastRec() )
oProcess:SetRegua2( LastRec() ) 

dbSeek(xFilial("SC6")+dtos(mv_par03))
//DO WHILE !EOF() .AND. C6_FILIAL == xFilial() .and. DTOS(C6_PROMET) <= Dtos(mv_par04)
WHILE SC6->C6_FILIAL == xFilial() .and. DTOS(SC6->C6_PROMET) >= dtos(MV_PAR03) .AND.;
	DTOS(SC6->C6_PROMET) <= dtos(MV_PAR04) .AND. !EOF()
	///IncProc( "Processando entrega dia » " + DtoC( SC6->C6_PROMET ) )
	
	If lEnd	//houve cancelamento do processo		
		Exit	
 	EndIf
 	 	
	oProcess:IncRegua1('Processando...  '       )
	oProcess:IncRegua2('Pedido de Venda Número  --->>>>   '  + Alltrim(SC6->C6_NUM)   ) 
 	
	
    IF ALLTRIM( SC6->C6_PRODUTO ) == "FESRFAS00000029"
       I:=0
    ENDIF
       
	dbSelectArea("SC5")
	dbSetOrder(1)
	dbSeek(xFilial("SC5") + SC6->C6_NUM) // "Status Ped (SEPDICO)?"
	If !(SC5->C5_STPAD $ mv_par12) 
		dbSelectArea("SC6")
		oProcess:IncRegua1('Processando...  '       )
		oProcess:IncRegua2('Pedido de Venda Número  --->>>>   '  + Alltrim(SC6->C6_NUM)   ) 
		dbSkip()
		Loop
	Endif
	If !Empty(mv_par13)
		If Left(SC6->C6_PRODUTO,2) <> mv_par13
			dbSelectArea("SC6")
           	oProcess:IncRegua1('Processando...  '       )
			oProcess:IncRegua2('Pedido de Venda Número  --->>>>   '  + Alltrim(SC6->C6_NUM)   ) 
			dbSkip()					
			Loop
		Endif
	Endif
	nMoeda   := SC5->C5_MOEDA
	If nMoeda <> 1
		cMoeda := "M2_MOEDA" + StrZero(nMoeda,1)
		dbSelectArea("SM2")
		dbSeek(SC5->C5_EMISSAO)
		nConv  := &(cMoeda)
		If nConv == 0
			Alert ("Atenção: Cadastrar Moeda " + StrZero(nMoeda,1) + " no dia " + Dtoc(SC5->C5_EMISSAO))
		Endif			
	Else
		nConv := 1
	Endif
	dbSelectArea("SC6")
	If SC6->C6_CODLMT >= mv_par01 .and. SC6->C6_CODLMT <= mv_par02 .and. ;
	   SC6->C6_CLI >= mv_par07 .and. SC6->C6_CLI <= mv_par08 .and. ;
	   SC5->C5_EMISSAO >= mv_par10 .and. SC5->C5_EMISSAO <= mv_par11 .and. ;
	   SC6->C6_QTDENT < C6_QTDVEN .and. SC6->C6_BLQ <> "R "
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1") + SC6->C6_PRODUTO)
		cDenom := SB1->B1_DENOM
	
		dbSelectArea("SA1")     
		dbSetOrder(1)
		dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI)
	    _cNomFant := SA1->A1_NREDUZ
	    _cCnpj  := SA1->A1_CGC
		If SC5->C5_VEND1 >= mv_par05 .and. SC5->C5_VEND1 <= mv_par06
			cVend 	 := SC5->C5_NOMEVEN
			cEmp  	 := SC5->C5_NOMECLI
			dEmissao := SC5->C5_EMISSAO
		Else
			dbSelectArea("SC6")
           	oProcess:IncRegua1('Processando...  '       )
			oProcess:IncRegua2('Pedido de Venda Número  --->>>>   '  + Alltrim(SC6->C6_NUM)   ) 
			dbSkip()					
			Loop
		Endif

		mVRUNIT   := xValTot(SC5->C5_CLIENTE,SC5->C5_LOJACLI,SA1->A1_TIPO,SC6->C6_PRODUTO,SC6->C6_TES,xQtdPed(SC6->C6_QTDVEN,SC6->C6_QTDENT,SC6->C6_BLQ,SC5->C5_EMISSAO),SC6->C6_PRCVEN,SC5->C5_MOEDA,SC5->C5_EMISSAO,SC6->C6_NUM,SC6->C6_ITEM)
		mVRTOTAL  := mVRUNIT * xQtdPed(SC6->C6_QTDVEN,SC6->C6_QTDENT,SC6->C6_BLQ,SC5->C5_EMISSAO) 
	
		dbSelectArea("SC6")
		RecLock( "TRB" , .T. )					
		TRB->VENDEDOR	:= cVend
		TRB->PEDIDO		:= SC6->C6_NUM + "-" + SC6->C6_ITEM
		TRB->DTCADA		:= dEmissao
		TRB->DTSOLIC		:= SC6->C6_PROMET
		TRB->DTENT		:= SC6->C6_ENTREG
		TRB->EMPRESA     := cEmp
		TRB->PEDCLIE		:= SC6->C6_PEDCLI
		TRB->PRODCLIE	:= SC6->C6_CODCLI
		TRB->CODLMT		:= SC6->C6_CODLMT
                             TRB->PESOLIQ                     := SB1->B1_PESO
		TRB->CODIGO		:= SC6->C6_PRODUTO
		TRB->QTPEDIDO    := SC6->C6_QTDVEN
		TRB->QTPEND		:= SC6->C6_QTDVEN - SC6->C6_QTDENT
		TRB->VRTOTAL		:= SC6->C6_VALOR
		TRB->DATA1		:= mv_par03
		TRB->DATA2		:= mv_par04
		nIpi      	:= SB1->B1_IPI
		TRB->VRUNIT      := mVRUNIT * nConv
		TRB->VRTOTAL     := mVRTOTAL * nConv
		If mv_par09 == 2
			TRB->IMPOSTOS    := "Com impostos"
		ElseIf mv_par09 == 1
			TRB->IMPOSTOS := "Sem impostos"
		Else
			TRB->IMPOSTOS  := "Mercadoria"
		Endif               
		TRB->CODCLI    := SC5->C5_CLIENTE
		TRB->LOJACLI   := SC5->C5_LOJACLI
		TRB->NOMFANT   := _cNomFant
		TRB->CNPJ      := _cCNPJ
		TRB->( MsUnLock() )
    Endif
	dbSelectArea("SC6")
	dbSkip()
Enddo

/////  Retirando o Filtro
dbSelectArea("SC6")
dbClearFilter()
dbSetOrder(1)

// atualizando estoque atual e estoque comprometido

dbSelectArea("SB2")
SB2->( DbSetOrder( 1 ) )

dbSelectArea("TRB")
TRB->( DbGoTop() )

//ProcRegua( TRB->( LastRec() ) )

cCODIGO		:= space(len(TRB->CODIGO))

While !TRB->( Eof() )
	nEST_TOTAL	:= 0
	nEST_COMPR	:= 0

    IF ALLTRIM( TRB->CODIGO ) == "BIFILAS00000018"
       I:=0
    ENDIF
       
	dbSelectArea("ZZ1")
    ZZ1->( DBSETORDER( 5 ) )
//    DBSEEK( XFILIAL("ZZ1") + SB2->B2_COD )
    DBSEEK( XFILIAL("ZZ1") + TRB->CODIGO )
    nSaldTra := 0

//    DO WHILE ! ZZ1->( EOF() ) .AND. ZZ1->ZZ1_LMTCOD == SB2->B2_COD
    DO WHILE ! ZZ1->( EOF() ) .AND. ZZ1->ZZ1_LMTCOD == TRB->CODIGO

       IF ! EMPTY( ZZ1->ZZ1_NFISCA )
          ZZ1->( DBSKIP() )
          LOOP
       ENDIF
   
       nSaldTra := nSaldTra + ZZ1->ZZ1_QTY
   
       ZZ1->( DBSKIP() )
   
    ENDDO      

	nEST_TOTAL	:= 0
	If	TRB->CODIGO <> cCODIGO
//	If	TRB->CODIGO <> ZZ1->ZZ1_LMTCOD

    	dbSelectArea("TRB")
		RecLock( "TRB" )                          
    	dbSelectArea("SB2")
	    dbSetOrder(1)
        dbseek(xfilial("SB2")+TRB->CODIGO + "01")
//    	dbSelectArea("TRB")
		TRB->EST_TOTAL	:= SB2->B2_QATU-SB2->B2_QEMP
		TRB->EST_COMPR	:= ( TRB->EST_TOTAL - TRB->QTPEND )

    	dbSelectArea("SB2")
	    dbSeek(xFilial("SB2") + TRB->CODIGO + "07" )
	    IF FOUND()
           TRB->QT_DESEMBA := SB2->B2_QATU - SB2->B2_QEMP    
        ENDIF

        TRB->QT_TRANSIT := nSaldTra    
        
	    dbSelectArea("TRB")
		TRB->( MsUnLock() )
		cCODIGO		:= TRB->CODIGO
		
	Else

		RecLock( "TRB" )
    	dbSelectArea("SB2")
	    dbSetOrder(1)
        dbseek(xfilial("SB2")+TRB->CODIGO + "01")
//    	dbSelectArea("TRB")
		TRB->EST_TOTAL	:= SB2->B2_QATU - SB2->B2_QEMP
		TRB->EST_COMPR	:= ( nEST_TOTAL - TRB->QTPEND )	

    	dbSelectArea("SB2")
	    dbSeek(xFilial("SB2") + TRB->CODIGO + "07" )
	    IF FOUND()
           TRB->QT_DESEMBA := SB2->B2_QATU - SB2->B2_QEMP
        ENDIF

        TRB->QT_TRANSIT := nSaldTra    

	    dbSelectArea("TRB")
		TRB->( MsUnLock() )
		
	EndIf

	nEST_TOTAL	:= TRB->EST_COMPR

	If	mv_par14 == 1 .and. TRB->EST_TOTAL <= 0
		RecLock( "TRB" )
		TRB->( DbDelete() )
		TRB->( MsUnLock() )
	EndIf
		
	TRB->( DbSkip() )
EndDo               

dbSelectArea("SC7")
DBSETORDER( 7 )
          
dbSelectArea("SC2")
DBSETORDER( 2 )

dbSelectArea("TRB")
DBGOTOP()
DO WHILE ! TRB->( EOF() )
                            
   cCod      := TRB->CODIGO
      
   cPedido01 := ""
   dEntreg01 := CTOD( "  /  /  " )
   nQuant01  := 0
   
   cPedido02 := ""
   dEntreg02 := CTOD( "  /  /  " )
   nQuant02  := 0
   
   cPedido03 := ""
   dEntreg03 := CTOD( "  /  /  " )
   nQuant03  := 0                                         
                                    
   SC2->( DBSETORDER( 2 ) )
   
   IF LEFT( TRB->CODIGO, 2 ) == "BR"
   
	  dbSelectArea("SC2")
	  DBSEEK( XFILIAL("SC2") + cCod + "20141231") //     DBSEEK( XFILIAL("SC2") + cCod ) Tanimoto 17-08-13. Alterado pois nao estava trazendo nada. Solicitado Regina
   
      IF ! SC2->( BOF() )
         SC2->( DBSKIP( -1 ) )
      ENDIF   
                                        
      DO WHILE ! SC2->( BOF() ) .AND. SC2->C2_PRODUTO == cCod
   
         IF SC2->C2_QUANT == SC2->C2_QUJE
            SC2->( DBSKIP( -1 ) )
            LOOP
         ENDIF
      
         IF EMPTY( cPedido03 )   
            cPedido03 := SC2->C2_NUM + "-" + SC2->C2_ITEM
            dEntreg03 := SC2->C2_DATPRF
            nQuant03  := SC2->C2_QUANT - SC2->C2_QUJE
         ELSEIF EMPTY( cPedido02 )   
            cPedido02 := SC2->C2_NUM + "-" + SC2->C2_ITEM
            dEntreg02 := SC2->C2_DATPRF
            nQuant02  := SC2->C2_QUANT - SC2->C2_QUJE
         ELSEIF EMPTY( cPedido01 )   
            cPedido01 := SC2->C2_NUM + "-" + SC2->C2_ITEM
            dEntreg01 := SC2->C2_DATPRF                                           
            nQuant01  := SC2->C2_QUANT - SC2->C2_QUJE
         ENDIF
      
         SC2->( DBSKIP( -1 ) )
      
      ENDDO 
   
   ELSE     

		cQuery := " SELECT C7_NUM||'-'||C7_ITEM AS CPEDIDO, C7_DATPRF AS DTENTR, C7_QUANT - C7_QUJE AS NQUANT "
		cQuery += " FROM "+ RetSqlName("SC7") + " SC7 "
		cQuery += " WHERE SC7.D_E_L_E_T_ <> '*' "
		cQuery += " AND C7_FILIAL = '" + xFilial("SC7") + "' "
		cQuery += " AND C7_PRODUTO = '"+cCod+"'" 
		cQuery += " AND (C7_QUANT - C7_QUJE) > 0 "
		cQuery += " ORDER BY CPEDIDO DESC "

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TR7", .F., .T.)

		TcSetField('TR7',"DTENTR","D",8,0)
		TcSetField('TR7',"NQUANT","N",12,2)
        
		dbSelectArea("TR7")
		dbGoTop()
		_n := 1
	    WHILE ! TR7->( EOF() ) .AND. _n <= 3
            If _n == 1
               cPedido01 := TR7->CPEDIDO
               dEntreg01 := TR7->DTENTR
               nQuant01  := TR7->NQUANT
            Elseif _n == 2 
               cPedido02 := TR7->CPEDIDO
               dEntreg02 := TR7->DTENTR
               nQuant02  := TR7->NQUANT
            Else 
               cPedido03 := TR7->CPEDIDO
               dEntreg03 := TR7->DTENTR
               nQuant03  := TR7->NQUANT
            Endif
	        _n += 1
	        TR7->(dbSkip())
		ENDDO

		TR7->(dbCloseArea())
	ENDIF
   dbSelectArea("TRB")    
   IF ! EMPTY( cPedido01 ) .or. ! EMPTY( cPedido02 ) .or. ! EMPTY( cPedido03 )
	  RecLock( "TRB" )                                                            
      TRB->PEDIDO01 := cPedido01
      TRB->ENTREG01 := dEntreg01
      TRB->QUANT01  := nQuant01 
      TRB->PEDIDO02 := cPedido02
      TRB->ENTREG02 := dEntreg02
      TRB->QUANT02  := nQuant02
      TRB->PEDIDO03 := cPedido03
      TRB->ENTREG03 := dEntreg03
      TRB->QUANT03  := nQuant03
      TRB->( MsUnLock() )       
   Endif
   
   TRB->( DBSKIP() )
   
ENDDO

cPATH		:= 'C:\TEMP\'
cFileName   := "RP03"+"_"+DTOS(DATE())+"_"+SUBSTR(TIME(),1,2)+"_"+SUBSTR(TIME(),4,2)+"_"+SUBSTR(TIME(),7,2)+".CSV"
cDestino	:= PADR(cPATH+cFileName, 100)

cCabec:=""
//Monta Cabeçalho Relatório
For _nX:=1 To Len(aStru)
	cCabec+= aStru[_nX,1]+";" 
Next _nX

cCabec:=SubStr(cCabec,1,Len(cCabec)-1)
u_ArqLog(cCabec,cDestino,"")

dbselectarea("TRB")
TRB->(dbGoTop())
While TRB->(!EOF())
	
	cDetal:= ""
	cDetal+= cValToChar(TRB->VENDEDOR   )  + ";"
	cDetal+= cValToChar(TRB->PEDIDO     )  + ";"
	cDetal+= cValToChar(TRB->DTCADA     )  + ";"
	cDetal+= cValToChar(TRB->DTSOLIC    )  + ";"
	cDetal+= cValToChar(TRB->DTENT      )  + ";"
	cDetal+= cValToChar(TRB->EMPRESA    )  + ";"
	cDetal+= cValToChar(TRB->PEDCLIE    )  + ";"
	cDetal+= cValToChar(TRB->PRODCLIE   )  + ";"
	cDetal+= cValToChar(TRB->CODLMT     )  + ";"
    cDetal+= StrTran(cValToChar(TRB->PESOLIQ ),".", ",")  + ";" 
	cDetal+= cValToChar(TRB->CODIGO     )  + ";"
	cDetal+= cValToChar(TRB->QTPEDIDO   )  + ";"
	cDetal+= cValToChar(TRB->QTPEND     )  + ";"
	cDetal+= StrTran(cValToChar(TRB->VRUNIT     ),".", ",")  + ";"
	cDetal+= StrTran(cValToChar(TRB->VRTOTAL    ),".", ",")  + ";"
	cDetal+= StrTran(cValToChar(TRB->VRLUNIT    ),".", ",")  + ";"
	cDetal+= cValToChar(TRB->DENOM      )  + ";"
	cDetal+= cValToChar(TRB->EST_TOTAL  )  + ";"
	cDetal+= cValToChar(TRB->EST_COMPR  )  + ";"
	cDetal+= cValToChar(TRB->QT_DESEMBA )  + ";"
	cDetal+= cValToChar(TRB->QT_TRANSIT )  + ";"
	cDetal+= cValToChar(TRB->QUANT01    )  + ";"
	cDetal+= cValToChar(TRB->ENTREG01   )  + ";"
	cDetal+= cValToChar(TRB->PEDIDO01   )  + ";"
	cDetal+= cValToChar(TRB->QUANT02    )  + ";"
	cDetal+= cValToChar(TRB->ENTREG02   )  + ";"
	cDetal+= cValToChar(TRB->PEDIDO02   )  + ";"
	cDetal+= cValToChar(TRB->QUANT03    )  + ";"
	cDetal+= cValToChar(TRB->ENTREG03   )  + ";"
	cDetal+= cValToChar(TRB->PEDIDO03   )  + ";"
	cDetal+= cValToChar(TRB->IMPOSTOS   )  + ";"
	cDetal+= cValToChar(TRB->DATA1      )  + ";"
	cDetal+= cValToChar(TRB->DATA2      )  + ";"
	cDetal+= cValToChar(TRB->CODCLI     )  + ";"
	cDetal+= cValToChar(TRB->LOJACLI    )  + ";"
	cDetal+= cValToChar(TRB->NOMFANT    )  + ";"
	cDetal+= cValToChar(TRB->CNPJ       )
	
	u_ArqLog(cDetal,cDestino,"")
	TRB->(dbSkip())
EndDo

//Carrega EXCEL
If ApOleClient("MsExcel")
	oExcelApp:= MsExcel():New()
	oExcelApp:WorkBooks:Open(cDestino)
	oExcelApp:SetVisible(.T.)
Endif

TRB->(DBCLOSEAREA())

mTESTE := "1;0;1;GIS"  // "EM DISCO;ATUALIZA;1 COPIA;NOME REL."

//CALLCRYS("RELPV3",,mTESTE)

Set SoftSeek Off


MsgInfo("Processamento finalizado e relatório gerado com sucesso!" )
   	

Return

// *----------------------------------------------------------------------------
Static Function AjustaSX1()
Local nXX
aPerg    := {}
cPerg    := PadR( 'RELPR3' , Len( SX1->X1_GRUPO ) )

Aadd( aPerg , { "Do Cod Lmt          ?" , "C" , TamSX3( "B1_CODLMT" )[1] , "SB1LMT"})
Aadd( aPerg , { "Ate Cod Lmt         ?" , "C" , TamSX3( "B1_CODLMT" )[1] , "SB1LMT"})
Aadd( aPerg , { "Da Data Entrega     ?" , "D" , 08 , "   "})
Aadd( aPerg , { "Ate Data Entrega    ?" , "D" , 08 , "   "})  
Aadd( aPerg , { "Do Vendedor         ?" , "C" , TamSX3( "A3_COD" )[1] , "SA3"})
Aadd( aPerg , { "Ate Vendedor        ?" , "C" , TamSX3( "A3_COD" )[1] , "SA3"})
Aadd( aPerg , { "Do Cliente          ?" , "C" , TamSX3( "A1_COD" )[1] , "SA1"})
Aadd( aPerg , { "Ate Cliente         ?" , "C" , TamSX3( "A1_COD" )[1] , "SA1"})
Aadd( aPerg , { "Abate impostos      ?" , "N" , 01 , "   "})
Aadd( aPerg , { "Da Data Emissao     ?" , "D" , 08 , "   "})
Aadd( aPerg , { "Ate Data Emissao    ?" , "D" , 08 , "   "})  
Aadd( aPerg , { "Status Ped (SEPDICO)?" , "C" , 07 , "   "})
Aadd( aPerg , { "Fabricante          ?" , "C" , 02 , "   "})
Aadd( aPerg , { "Somente Itens com estoque ?" , "N" , 01 , "   "})

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
		If nxx == 9 .or. nXX == 14
			SX1->X1_GSC   := "C"
			SX1->X1_DEF01 := "Sim"
			SX1->X1_DEF02 := "Nao"
		Endif
		SX1->(MsUnLock())
	EndIf
Next nXX
Return Nil

Static Function xValTot(cCodCl,cLoj,cTpCli,cCodP,cTes,nQtd,nPrcUnit,nMoe,dEmis,cNumP,cItemP)

Local aArea := GetArea()
Local nTotal := 0
Local nVaIPI := 0
Local nVaICM := 0
Local nVaPIS := 0
Local nVaCOF := 0

Local lAbIMP := mv_par09==1
Local lAbIPI := mv_par09==1
Local lAbICM := mv_par09==1
Local lAbPIS := mv_par09==1
Local lAbCOF := mv_par09==1    
Local lFat  := .f.

dbSelectArea("SD2")
//dbSetOrder(13)
dbSetOrder(18)
If dbSeek(cNumP+cItemP)
   nVaFrete  := SD2->D2_VALFRE
   nVaSeguro := SD2->D2_SEGURO
   nVaDespesa:= SD2->D2_DESPESA
   nVaICM    := SD2->D2_VALICM
   nVaIPI    := SD2->D2_VALIPI
   nVaCOF    := SD2->D2_VALIMP5
   nVaPIS    := SD2->D2_VALIMP6
   nTotal    := SD2->D2_TOTAL 
   nQtd      := SD2->D2_QUANT
   lFat      := .t.
Else
   nVaFrete  := 0
   nVaSeguro := 0     
   nVaDespesa:= 0
Endif   

// Inicializa a funcao fiscal para poder simular os valores dos impostos
MaFisIni(cCodCl,;	// 1-Codigo Cliente/Fornecedor (Obrigatorio)
cLoj,;			// 02-Loja do Cliente/Fornecedor (Obrigatorio)
"C",;			// 03-C:Cliente , F:Fornecedor (Obrigatorio)
"N",;			// 04-Tipo da NF( "N","D","B","C","P","I" ) (Obrigatorio)
cTpCli)			// 05-Tipo do Cliente/Fornecedor (Obrigatorio)

//Inicializa a funcao fiscal por itens para poder simular os valores dos impostos
MaFisAdd(cCodP,;   	// 1-Codigo do Produto ( Obrigatorio )
cTes,;	   			// 2-Codigo do TES ( Opcional )
nQtd,;	   			// 3-Quantidade ( Obrigatorio )
nPrcUnit,;  		// 4 -Preco Unitario ( Obrigatorio )
0,; 				// 5 -Valor do Desconto ( Opcional )
"",;				// 6 -Numero da NF Original ( Devolucao/Benef )
"",;				// 7 -Serie da NF Original ( Devolucao/Benef )
,;					// 8 -RecNo da NF Original no arq SD1/SD2
0,;					// 9 -Valor do Frete do Item ( Opcional )
0,;					// 10-Valor da Despesa do item ( Opcional )
0,;					// 11-Valor do Seguro do item ( Opcional )
0,;					// 12-Valor do Frete Autonomo ( Opcional )
nQtd * nPrcUnit)	// 13-Valor da Mercadoria ( Obrigatorio )

// Calcula os valor Total
IF lAbIMP

  If !lFat	
	nTotal := MaFisRet(1,'IT_VALMERC') - MaFisRet(1,'IT_VALISS')

	nVaIPI := IIF(lAbIPI,MaFisRet(1,'IT_VALIPI'),0)
	nVaICM := IIF(lAbICM,MaFisRet(1,'IT_VALICM'),0)
	nVaPIS := IIF(lAbPIS,MaFisRet(1,'IT_VALPIS') + MaFisRet(1,'IT_VALPS2'),0)
	nVaCOF := IIF(lAbCOF,MaFisRet(1,'IT_VALCOF') + MaFisRet(1,'IT_VALCF2'),0)
  Endif	
	nTotal := (nTotal - nVaICM - nVaPIS - nVaCOF + nVaFrete + nVaSeguro + nVaDespesa) / nQtd //- nVaIPI 

Else                     
	nTotal := MaFisRet(1,'IT_VALMERC')
	nVaSol := MaFisRet(1,'IT_VALSOL')
	nVaIPI := nTotal * (MaFisRet(1,'IT_ALIQIPI')/100)
    nTotal := ((nTotal + nVaIPI + nVaSol ) + nVaFrete + nVaSeguro + nVaDespesa) / nQtd

EndIf

MaFisEnd()

RestArea( aArea )

Return (nTotal)

Static Function xQtdPed(nQV,nQE,cBL,dDTE)

local nVal := 0

nVal := nQV - nQE  

Return nVal

Static Function BuscaDados(cCampos,cGrupo)
Local cRetorno:=""

If SBM->(MsSeek(xFilial("SBM")+cGrupo))
	If cCampos=="BM_FAMILIA"
		cRetorno:=Posicione("SX5",1,xFilial("SX5") + "W2" + SBM->BM_FAMILIA , "X5_DESCRI")
	ElseIf cCampos=="BM_SUBGRUP"
		cRetorno:=Posicione("SX5",1,xFilial("SX5") + "W1" + SBM->BM_SUBGRUP , "X5_DESCRI")
	EndIf	
EndIf

Return cRetorno

