#INCLUDE "RWMAKE.CH"

User Function Gera1RELPCA()

PRIVATE nTipoPed := 1
PRIVATE aRotina   := {{ "Pesquisar","PesqBrw", 0 , 1},; //"Pesquisar"
	{ "Visualizar","U_GERREL", 0 , 1},;                 //"Visualizar"
	{ "Incluir"   ,"U_GERREL", 0 , 3},;                 //"Incluir"
	{ "Alterar"   ,"U_GERREL", 0 , 4,6},;               //"Alterar"
	{ "Excluir"   ,"U_GERREL", 0 , 5,7},;               //"Excluir"
	{ "Imprimir"  ,"U_GERRELIMP",  0 , 2} }             //"Imprimir"

PRIVATE bFiltraBrw:= {|| Nil }
PRIVATE cCadastro := "Invoice"
PRIVATE aBackSC7  := {}
PRIVATE lPedido := .T.

mBrowse( 6, 1,22,75,"ZZ1",,,,,,)

Return( .T. )                  

User FUNCTION GERREL(cAlias,nReg,nOpcX)
                   
I:=0                                                
                   
aButtons   := {}

aadd(aButtons,{"OK"     ,{|| GravZZ1()    }, OemToAnsi("AAA"),OemToAnsi("BBB") } )
aadd(aButtons,{"Cancela",{|| (oDlg:End()) }, OemToAnsi("AAA"),OemToAnsi("BBB") } )

aObjects :={}
aPosObj  :={}
aSize    :=MsAdvSize()
aInfo    :={aSize[1],aSize[2],aSize[3],aSize[4],3,3}
               
AADD(aObjects,{100,020,.T.,.F.,.F.})
AADD(aObjects,{100,100,.T.,.T.,.F.})

aPosObj:=MsObjSize(aInfo,aObjects)
nOpca:=0

M->ZZ1_ORDER  := IF( nOpcX == 3, space( 6 )        , ZZ1->ZZ1_ORDER )                      
M->ZZ1_LINE   := IF( nOpcX == 3, space( 4 )        , ZZ1->ZZ1_LINE )                      
M->ZZ1_FORNEC := IF( nOpcX == 3, space( 10 )       , ZZ1->ZZ1_FORNEC )                      
M->ZZ1_EMISSA := IF( nOpcX == 3, CTOD( "  /  /  " ), ZZ1->ZZ1_EMISSA )                      
M->ZZ1_DATPRF := IF( nOpcX == 3, CTOD( "  /  /  " ), ZZ1->ZZ1_DATPRF )                      
M->ZZ1_CONFIR := IF( nOpcX == 3, space( 10 )       , ZZ1->ZZ1_CONFIR )                      
M->ZZ1_LMTCOD := IF( nOpcX == 3, space( 15 )       , ZZ1->ZZ1_LMTCOD )                      
M->ZZ1_SAPCOD := IF( nOpcX == 3, space( 10 )       , ZZ1->ZZ1_SAPCOD )                      
M->ZZ1_DESCRI := IF( nOpcX == 3, space( 46 )       , ZZ1->ZZ1_DESCRI )                      
M->ZZ1_QTY    := IF( nOpcX == 3, 0                 , ZZ1->ZZ1_QTY )                       
M->ZZ1_PRICE  := IF( nOpcX == 3, 0                 , ZZ1->ZZ1_PRICE )                      
M->ZZ1_VRFRET := IF( nOpcX == 3, 0                 , ZZ1->ZZ1_VRFRET )                      
M->ZZ1_TOTAL  := IF( nOpcX == 3, 0                 , ZZ1->ZZ1_TOTAL )                      
M->ZZ1_INVOIC := IF( nOpcX == 3, space( 10 )       , ZZ1->ZZ1_INVOIC )                      
M->ZZ1_DTINVO := IF( nOpcX == 3, CTOD( "  /  /  " ), ZZ1->ZZ1_DTINVO )                      
M->ZZ1_TRADUC := IF( nOpcX == 3, space( 30 )       , ZZ1->ZZ1_TRADUC )                      
M->ZZ1_NCM    := IF( nOpcX == 3, space( 10 )       , ZZ1->ZZ1_NCM )                      
M->ZZ1_LOCALI := IF( nOpcX == 3, space( 15 )       , ZZ1->ZZ1_LOCALI )                      
M->ZZ1_NFISCA := IF( nOpcX == 3, space( 09 )       , ZZ1->ZZ1_NFISCA )                      
M->ZZ1_SERIE  := IF( nOpcX == 3, space( 03 )       , ZZ1->ZZ1_SERIE )                      
M->ZZ1_DATENT := IF( nOpcX == 3, CTOD( "  /  /  " ), ZZ1->ZZ1_DATENT )                      

DEFINE MSDIALOG oDlg TITLE OemToAnsi( IF( nOpcX == 2, "Visualizar", ;
                                      IF( nOpcX == 3, "Inclusao", ;
                                      IF( nOpcX == 4, "Alteraçao", "Exclusao" ) ) ) ) ;
                           OF oMainWnd PIXEL FROM 050, 050 TO 650, 800
                            
@ 30,50	SAY OemToAnsi("Order:") //"N£mero Documento"
@ 30,100	GET M->ZZ1_ORDER F3 "SC71" When IF( nOpcX == 3, .T., IF( nOpcX == 4, .F., .F. ) ) Valid ChecOrder()
@ 45,50	SAY OemToAnsi("Line:") //"N£mero Documento"
@ 45,100	GET M->ZZ1_LINE PICTURE "@E 9999" When IF( nOpcX == 3, .T., IF( nOpcX == 4, .F., .F. ) ) Valid ChecLine( nOpcX )
@ 60,50	SAY OemToAnsi("Confirmation:") //"N£mero Documento"
@ 60,100	GET M->ZZ1_CONFIR PICTURE "@S" When IF( nOpcX == 3, .F., IF( nOpcX == 4, .F., .F. ) )
@ 75,50	SAY OemToAnsi("LMT Code:") //"N£mero Documento"
@ 75,100   GET M->ZZ1_LMTCOD PICTURE "@S" When IF( nOpcX == 3, .F., IF( nOpcX == 4, .F., .F. ) )
@ 90,50	SAY OemToAnsi("Sap Code:") //"N£mero Documento"
@ 90,100	GET M->ZZ1_SAPCOD PICTURE "@S" When IF( nOpcX == 3, .F., IF( nOpcX == 4, .F., .F. ) )
@ 105,50	SAY OemToAnsi("Description:") //"N£mero Documento"
@ 105,100	GET M->ZZ1_DESCRI PICTURE "@S" When IF( nOpcX == 3, .F., IF( nOpcX == 4, .F., .F. ) )
@ 120,50	SAY OemToAnsi("Qty:") //"N£mero Documento"
@ 120,100	GET M->ZZ1_QTY PICTURE PesqPict('ZZ1','ZZ1_QTY') SIZE 40,050 When IF( nOpcX == 3, .T., IF( nOpcX == 4, .T., .F. ) )
@ 135,50	SAY OemToAnsi("Price:") //"N£mero Documento"
@ 135,100	GET M->ZZ1_PRICE PICTURE PesqPict('ZZ1','ZZ1_PRICE') SIZE 60,050 When IF( nOpcX == 3, .T., IF( nOpcX == 4, .T., .F. ) )  
@ 135,250	SAY OemToAnsi("Frete:") //"N£mero Documento"
@ 135,300	GET M->ZZ1_VRFRET PICTURE "@E 99999,999.99" SIZE 60,050 When IF( nOpcX == 3, .T., IF( nOpcX == 4, .T., .F. ) ) Valid ChecTotal()
@ 150,50	SAY OemToAnsi("Total:") //"N£mero Documento"
@ 150,100	GET M->ZZ1_TOTAL PICTURE PesqPict('ZZ1','ZZ1_TOTAL') SIZE 60,050 When IF( nOpcX == 3, .T., IF( nOpcX == 4, .T., .F. ) ) Valid ChecPrice()
@ 165,50	SAY OemToAnsi("Invoice:") //"N£mero Documento"
@ 165,100	GET M->ZZ1_INVOIC PICTURE "@S" When IF( nOpcX == 3, .T., IF( nOpcX == 4, .T., .F. ) )
@ 180,50	SAY OemToAnsi("Data Invoice:") //"N£mero Documento"
@ 180,100	GET M->ZZ1_DTINVO PICTURE "@S" When IF( nOpcX == 3, .T., IF( nOpcX == 4, .T., .F. ) )
@ 195,50	SAY OemToAnsi("Traduçao:") //"N£mero Documento"
@ 195,100	GET M->ZZ1_TRADUC PICTURE "@S" When IF( nOpcX == 3, .F., IF( nOpcX == 4, .F., .F. ) )
@ 210,50	SAY OemToAnsi("NCM:") //"N£mero Documento"
@ 210,100	GET M->ZZ1_NCM PICTURE "@S" When IF( nOpcX == 3, .F., IF( nOpcX == 4, .F., .F. ) )
@ 225,50	SAY OemToAnsi("Localizaçao:") //"N£mero Documento"
@ 225,100	GET M->ZZ1_LOCALI PICTURE "@S" When IF( nOpcX == 3, .F., IF( nOpcX == 4, .F., .F. ) )

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,(oDlg:End())},{||oDlg:End(),nOpca:=0},,) 

IF nOpca == 1
   GravZZ1( nOpcX )
ENDIF   

RETURN()

Static Function ChecOrder()                                                                      

 IF SC7->( DBSEEK( XFILIAL("SC7") + M->ZZ1_ORDER ) )

    lRet          := .T.

 ELSE
 
    MSGBOX( "Pedido nao encontrado !!!", "", "OK" )
    
    lRet          := .F.

 ENDIF
    
Return( lRet )

Static Function ChecLine( nOpcX )                              

 lRet          := .F.

 IF EMPTY( M->ZZ1_LINE )
    RETURN( .T. )
 ENDIF   

 M->ZZ1_LINE := STRZERO( VAL( M->ZZ1_LINE ), 4, 0 )
 
 IF nOpcX == 3 .OR. nOpcX == 4
    IF ZZ1->( DBSEEK( XFILIAL("ZZ1") + M->ZZ1_ORDER + M->ZZ1_LINE ) )
       M->ZZ1_CONFIR := ZZ1->ZZ1_CONFIR 
       M->ZZ1_LMTCOD := ZZ1->ZZ1_LMTCOD 
       M->ZZ1_SAPCOD := SB1->B1_CAT 
       M->ZZ1_DESCRI := ZZ1->ZZ1_DESCRI
       M->ZZ1_QTY    := ZZ1->ZZ1_QTY
       M->ZZ1_PRICE  := ZZ1->ZZ1_PRICE 
       M->ZZ1_VRFRET := ZZ1->ZZ1_VRFRET 
       M->ZZ1_TOTAL  := ZZ1->ZZ1_TOTAL 
       M->ZZ1_INVOIC := ZZ1->ZZ1_INVOIC 
       M->ZZ1_DTINVO := ZZ1->ZZ1_DTINVO 
       M->ZZ1_TRADUC := SB1->B1_DESC 
       M->ZZ1_NCM    := SB1->B1_POSIPI 
       M->ZZ1_LOCALI := SB1->B1_ENDE  
                   
       lRet          := .T.

    ELSE
 
       ZZ1->( DBSETORDER( 1 ) )      
                   
       IF SC7->( DBSEEK( XFILIAL("SC7") + M->ZZ1_ORDER + M->ZZ1_LINE ) )

         IF SC7->C7_QUANT - SC7->C7_QUJE == 0 
            MSGBOX( "Pedido Encerrado !!!", "", "OK" )
            lRet          := .F.
         ELSE
    
            SB1->( DBSEEK( XFILIAL("SB1") + SC7->C7_PRODUTO ) )
    
            DBSELECTAREA("ZZ1")          
                   
            M->ZZ1_FORNEC := SC7->C7_FORNECE 
            M->ZZ1_DATPRF := SC7->C7_DATPRF 
            M->ZZ1_EMISSA := SC7->C7_EMISSAO 
            M->ZZ1_CONFIR := SC7->C7_CONFIRM 
            M->ZZ1_LMTCOD := SC7->C7_PRODUTO 
            M->ZZ1_SAPCOD := SB1->B1_CAT 
            M->ZZ1_DESCRI := SC7->C7_CODLMT 
            M->ZZ1_QTY    := SC7->C7_QUANT - SC7->C7_QUJE
            M->ZZ1_PRICE  := SC7->C7_PRECO 
            M->ZZ1_VRFRET := 0 
            M->ZZ1_TOTAL  := SC7->C7_PRECO * ( SC7->C7_QUANT - SC7->C7_QUJE ) 
            M->ZZ1_INVOIC := SC7->C7_INVOICE 
            M->ZZ1_DTINVO := DATE() 
            M->ZZ1_TRADUC := SB1->B1_DESC 
            M->ZZ1_NCM    := SB1->B1_POSIPI 
            M->ZZ1_LOCALI := SB1->B1_ENDE  
 
            lRet          := .T.
    
         ENDIF
  
      ELSE
  
         MSGBOX( "Item do Pedido nao encontrado !!!", "", "OK" )
      
         lRet          := .F.

      ENDIF

   ENDIF

 ENDIF

Return( lRet ) 

Static Function ChecTotal()                                                                                               
                                                                                               
 M->ZZ1_TOTAL := ROUND( M->ZZ1_VRFRET + ( M->ZZ1_PRICE * M->ZZ1_QTY ) , 4  )
 
Return()

Static Function ChecPrice()                                                                                               
                                                                                               
 M->ZZ1_PRICE := ROUND( M->ZZ1_TOTAL / M->ZZ1_QTY, 4 )
 
Return()

User FUNCTION GERRELIMP(cAlias,nReg,nOpcX)
                   
LOCAL cbtxt := SPACE(10)
LOCAL nQuebra,cCabQuebra,cQuebrant,cCOndBus
LOCAL CbCont
LOCAL nQuant_a_Rec := 0
Local nTotParc := 0
Local nTxMoeda := 1
Local nI

LOCAL CbTxt  := ""
Local wnrel  := ""
LOCAL cDesc1 := "Emissao da Relacao de Invoices."
LOCAL cDesc2 := ""
LOCAL cDesc3 := ""
//LOCAL aOrd   := {STR0004,STR0005,STR0006}		//" Por Numero         "###" Por Produto        "###" Por Fornecedor   "

PRIVATE aTamSXG  := TamSXG("001")
PRIVATE nDifNome := 0
PRIVATE nTamNome := 35
PRIVATE titulo   := "Relacao de Invoices"
PRIVATE cPerg    := PadR( "GERREL" , Len( SX1->X1_GRUPO ) )
PRIVATE cString  := "ZZ1"
PRIVATE aReturn  := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
PRIVATE nomeprog := "GERRELIMP"
PRIVATE nLastKey := 0               
PRIVATE aLinha   := { }
PRIVATE LIMITE   :=220
PRIVATE cabec1   := ""
PRIVATE cabec2   := ""
PRIVATE tamanho  := "G"

Imprime  := .T.

Pergunte("GERREL",.F.)

aOrd    := { "Invoice", "Data Invoice", "Descriçao", "Order + Line" }	

wnrel := "GERRELIMP"
wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.f.,Tamanho)

If nLastKey == 27
	Set Filter To
	Return
Endif              

SetDefault(aReturn,cString)
If nLastKey == 27
	Set Filter To
	Return
Endif

CbCont   := 00
nQuebra  := 00
li       := 80
m_pag    := 01

nT_qtd_ped := 0		// qtde pedida
nT_vl_ipi  := 0		// valor do ipi
nT_vl_total:= 0      // valor total do pedido
nT_qtd_entr:= 0		// qtde entregue
nT_sd_receb:= 0		// saldo a receber
nT_desc    := 0		// total de desconto
nTotIVA    := 0    // Total de IVA (impostos)

nPedida    := 0	// qtde pedida
nValIpi    := 0 	// valor do ipi
nTotal     := 0   // valor total do pedido
nQuant     := 0	// qtde entregue
nSaldo     := 0 	// saldo a receber
nFlag		  := 0	// flag que indica se imprime totais por item ou nao
nITemIpi   := 0
nSalIpi    := 0
nFrete	  := 0	// valor do frete
nDesc      := 0 	// valor do desconto
nValIVA    := 0     // valor do IVA
nItemIVA   := 0     // valor do item do imposto

cabec1    := "RELACAO DOS PEDIDOS DE COMPRAS"

nOrdem := aReturn[8]

dbSelectArea("ZZ1")
nRegZZ1 := ZZ1->( RECNO() )

dbSetOrder(nOrdem)                            
ZZ1->( DBGOTOP() )

cabec1 := "ORDER  LINE CONFIRMATION LMTCODE         SAPCODE    DESCRIPTION                                    QTY     PRICE        TOTAL        INVOICE    DATA     TRADUÇAO                       NCM        LOCALIZAÇAO     N.FISCAL  SERIE ENTRADA"
//		   0         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20
//         0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789

//If mv_par07==1
//	titulo+=STR0025	//", Todos"
//Elseif mv_par07==2
//	titulo+=STR0026	//", Em Abertos"
//Elseif mv_par07==3
//	titulo+=STR0027	//", Residuos"
//Elseif mv_par07==4         
//	titulo+=STR0028	//", Atendidos"
//Endif

//SetRegua(RecCount())

nTotOrder := 0
aOrder    := {}

aStru := {}
aAdd(aStru,{"NRORDER"       ,"C",06,0})
aAdd(aStru,{"LINE"          ,"C",04,0})
aAdd(aStru,{"CONFIRM"       ,"C",10,0})
aAdd(aStru,{"LMTCOD"        ,"C",15,0})
aAdd(aStru,{"SAPCOD"        ,"C",10,0})
aAdd(aStru,{"DESCRI"	    ,"C",46,0})
aAdd(aStru,{"QTY"           ,"N",09,0})
aAdd(aStru,{"PRICE"         ,"N",14,4})
aAdd(aStru,{"TOTAL"         ,"N",14,2})
aAdd(aStru,{"INVOICE"       ,"C",10,0})
aAdd(aStru,{"DTINVOICE"     ,"D",08,0})
aAdd(aStru,{"TRADUCAO"      ,"C",30,0})
aAdd(aStru,{"NCM"           ,"C",10,0})
aAdd(aStru,{"LOCALIZ"       ,"C",15,0})
aAdd(aStru,{"NFISCA"        ,"C",09,0})
aAdd(aStru,{"SERIE"         ,"C",03,0})
aAdd(aStru,{"DATENT"        ,"D",08,0})
aAdd(aStru,{"ITEMNF"        ,"C",04,0})


oTemptable := FWTemporaryTable():New( "TRB")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"NRORDER"} )
oTempTable:Create()

//cArq := CriaTrab(aStru,.T.)
//dbUseArea(.T.,,cArq,"TRB",.T.)
//cInd := CriaTrab(NIL,.F.)                                      
nTotItem := 0

Do While ! ZZ1->( Eof() )

//	IncRegua()                   

    IF ZZ1->ZZ1_INVOIC < MV_PAR01 .OR. ZZ1->ZZ1_INVOIC > MV_PAR02
       ZZ1->( DBSKIP() )
       LOOP
    ENDIF   

    IF ZZ1->ZZ1_DTINVO < MV_PAR03 .OR. ZZ1->ZZ1_DTINVO > MV_PAR04
       ZZ1->( DBSKIP() )
       LOOP
    ENDIF   

    IF ZZ1->ZZ1_FORNEC < MV_PAR05 .OR. ZZ1->ZZ1_FORNEC > MV_PAR06
       ZZ1->( DBSKIP() )
       LOOP
    ENDIF   

	If lEnd
		@PROW()+1,001 PSAY "CANCELADO PELO OPERADOR"
		Exit
	Endif

	If li > 55                                       
	   @ 00,00 PSAY CHR(15) 
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
	Endif                       

	nItemIpi := 0
	nSalIpi := 0
	nItemIVA  := 0
	
	@ li,000 PSAY ZZ1->ZZ1_ORDER 
	@ li,007 PSAY ZZ1->ZZ1_LINE 
	@ li,012 PSAY ZZ1->ZZ1_CONFIR 
	@ li,025 PSAY ZZ1->ZZ1_LMTCOD                                
	IF UPPER( MV_PAR07 ) == "S"
	   @ li,041 PSAY ZZ1->ZZ1_SAPCOD 
	ENDIF   
	@ li,052 PSAY ZZ1->ZZ1_DESCRI 
	@ li,099 PSAY ZZ1->ZZ1_QTY    PICTURE "@E 999,999"
	@ li,107 PSAY ZZ1->ZZ1_PRICE  PICTURE "@E 999,999.9999"
	@ li,120 PSAY ZZ1->ZZ1_TOTAL  PICTURE "@E 9,999,999.99" 
	@ li,133 PSAY ZZ1->ZZ1_INVOIC 
	@ li,144 PSAY ZZ1->ZZ1_DTINVO 
	@ li,153 PSAY ZZ1->ZZ1_TRADUC 
	@ li,184 PSAY ZZ1->ZZ1_NCM 
	@ li,195 PSAY ZZ1->ZZ1_LOCALI 
	@ li,211 PSAY ZZ1->ZZ1_NFISCA 
	@ li,221 PSAY ZZ1->ZZ1_SERIE 
	@ li,225 PSAY ZZ1->ZZ1_DATENT
                        
    DBSELECTAREA("TRB")                                 
    RECLOCK("TRB", .T. )            
    
    TRB->NRORDER   := ZZ1->ZZ1_ORDER        
    TRB->LINE      := ZZ1->ZZ1_LINE        
    TRB->CONFIRM   := ZZ1->ZZ1_CONFIR        
    TRB->LMTCOD    := ZZ1->ZZ1_LMTCOD        
	IF UPPER( MV_PAR07 ) == "S"
       TRB->SAPCOD    := ZZ1->ZZ1_SAPCOD        
    ENDIF   
    TRB->DESCRI    := ZZ1->ZZ1_DESCRI        
    TRB->QTY       := ZZ1->ZZ1_QTY        
    TRB->PRICE     := ZZ1->ZZ1_PRICE        
    TRB->TOTAL     := ZZ1->ZZ1_TOTAL       
    TRB->INVOICE   := ZZ1->ZZ1_INVOIC        
    TRB->DTINVOICE := ZZ1->ZZ1_DTINVO        
    TRB->TRADUCAO  := ZZ1->ZZ1_TRADUC        
    TRB->NCM       := ZZ1->ZZ1_NCM        
    TRB->LOCALIZ   := ZZ1->ZZ1_LOCALI        
    TRB->NFISCA    := ZZ1->ZZ1_NFISCA        
    TRB->SERIE     := ZZ1->ZZ1_SERIE        
    TRB->DATENT    := ZZ1->ZZ1_DATENT        

    MSUNLOCK("TRB")
    
    DBSELECTAREA("ZZ1")
    
    li     := li + 1
    cInvoice := ZZ1->ZZ1_INVOIC
    nTotOrder := nTotOrder + ZZ1->ZZ1_TOTAL
    nTotItem  := nTotItem    + ZZ1->ZZ1_TOTAL
    
	ZZ1->( DBSKIP() )
	                     
	IF ZZ1->ZZ1_INVOIC <> cInvoice
       nI := ASCAN( aOrder, cInvoice )
       
       lRet := .F.
                                   
       FOR nI := 1 TO LEN( aOrder )
          IF aOrder[ nI, 1 ] == cInvoice
             lRet := .T.
             EXIT
          ENDIF
       NEXT nI
             
       IF lRet
          aOrder[ nI, 2 ] := aOrder[ nI, 2 ] + nTotOrder
       ELSE   
          AADD( aOrder, { cInvoice, nTotOrder } )	
       ENDIF   
       nTotOrder := 0
    ENDIF
       
ENDDO
           
@ li,107 PSAY "Total"
@ li,120 PSAY nTotItem  PICTURE "@E 9,999,999.99" 

DBSELECTAREA("TRB")                                 
RECLOCK("TRB", .T. )            

RECLOCK("TRB", .T. )            

RECLOCK("TRB", .T. )            

TRB->DESCRI    := "Total"        
TRB->TOTAL     := nTotItem        
    
MSUNLOCK("TRB")

li     := li + 3

@ li,015 PSAY "RESUMO" 

DBSELECTAREA("TRB")                                 
RECLOCK("TRB", .T. )            

RECLOCK("TRB", .T. )            

RECLOCK("TRB", .T. )            

TRB->DESCRI    := "RESUMO"        
    
MSUNLOCK("TRB")

li     := li + 2
nTotal := 0

FOR nI := 1 TO LEN( aOrder )

	If li > 55                                       
	   @ 00,00 PSAY CHR(15) 
	   cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
       li     := li + 3

       @ li,015 PSAY "RESUMO" 

       li     := li + 2
	Endif                       

    @ li,015 PSAY aOrder[ nI, 1 ] 
    @ li,030 PSAY aOrder[ nI, 2 ] PICTURE "@E 9,999,999.99"

    DBSELECTAREA("TRB")                                 
    RECLOCK("TRB", .T. )            

    TRB->DESCRI    := aOrder[ nI, 1 ]        
    TRB->TOTAL     := aOrder[ nI, 2 ]        
    
    MSUNLOCK("TRB")
    
   li     := li + 1
   nTotal := nTotal + aOrder[ nI, 2 ]
   
NEXT nI
    
li     := li + 1
@ li,030 PSAY nTotal PICTURE "@E 9,999,999.99"

DBSELECTAREA("TRB")                                 
RECLOCK("TRB", .T. )            

RECLOCK("TRB", .T. )            

TRB->DESCRI    := "TOTAL"        
TRB->TOTAL     := nTotal        
    
MSUNLOCK("TRB")
    
dbSelectArea("ZZ1")
Set Filter To
dbSetOrder(1)

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	ourspool(wnrel)
Endif

MS_FLUSH()

dbselectarea("TRB")
dbgotop()
ferase("\SIGAADV\GERARELPCA.DBF")
COPY TO "\SIGAADV\GERARELPCA.DBF" Via "DBFCDXADS" 
Processa({||CpyS2T("\SIGAADV\GERARELPCA.DBF","C:\",.T.)},"Copiando Arquivo","Aguarde...",.F.)
ferase("\SIGAADV\GERARELPCA.DBF")
TRB->(DBCLOSEAREA())

ZZ1->( DBGOTO( nRegZZ1 ) )

Return

Static Function GravZZ1( nOpcX )

 IF nOpcX == 5
    DBSELECTAREA("ZZ1")
    RECLOCK("ZZ1", .F. )
    DELETE
    MSUNLOCK("ZZ1")
    RETURN
 ENDIF   

 SB1->( DBSEEK( XFILIAL("SB1") + LEFT( M->ZZ1_LMTCOD, 15 ) ) )
    
 DBSELECTAREA("ZZ1")    
 ZZ1->( DBSETORDER( 4 ) )      
                   
 IF ZZ1->( DBSEEK( XFILIAL("ZZ1") + M->ZZ1_ORDER + M->ZZ1_LINE ) )
    RECLOCK( "ZZ1", .F. )
 ELSE
    RECLOCK( "ZZ1", .T. )
    ZZ1->ZZ1_FILIAL := XFILIAL("ZZ1") 
    ZZ1->ZZ1_ORDER  := M->ZZ1_ORDER 
    ZZ1->ZZ1_LINE   := M->ZZ1_LINE 
 ENDIF                  
 
 IF EMPTY( M->ZZ1_FORNEC )
    IF SC7->( DBSEEK( XFILIAL("SC7") + M->ZZ1_ORDER + M->ZZ1_LINE ) )
       ZZ1->ZZ1_FORNEC := SC7->C7_FORNECE 
       ZZ1->ZZ1_DATPRF := SC7->C7_DATPRF 
       ZZ1->ZZ1_EMISSA := SC7->C7_EMISSAO 
    ELSE   
       ZZ1->ZZ1_FORNEC := M->ZZ1_FORNEC 
       ZZ1->ZZ1_DATPRF := M->ZZ1_DATPRF 
       ZZ1->ZZ1_EMISSA := M->ZZ1_EMISSA 
    ENDIF                               
 ELSE   
    ZZ1->ZZ1_FORNEC := M->ZZ1_FORNEC 
    ZZ1->ZZ1_DATPRF := M->ZZ1_DATPRF 
    ZZ1->ZZ1_EMISSA := M->ZZ1_EMISSA 
 ENDIF
 ZZ1->ZZ1_CONFIR := M->ZZ1_CONFIR 
 ZZ1->ZZ1_LMTCOD := M->ZZ1_LMTCOD 
 ZZ1->ZZ1_SAPCOD := SB1->B1_CAT 
 ZZ1->ZZ1_DESCRI := M->ZZ1_DESCRI
 ZZ1->ZZ1_QTY    := M->ZZ1_QTY
 ZZ1->ZZ1_PRICE  := M->ZZ1_PRICE 
 ZZ1->ZZ1_VRFRET := M->ZZ1_VRFRET 
 ZZ1->ZZ1_TOTAL  := M->ZZ1_TOTAL 
 ZZ1->ZZ1_INVOIC := M->ZZ1_INVOIC 
 ZZ1->ZZ1_DTINVO := M->ZZ1_DTINVO 
 ZZ1->ZZ1_TRADUC := SB1->B1_DESC 
 ZZ1->ZZ1_NCM    := SB1->B1_POSIPI 
 ZZ1->ZZ1_LOCALI := SB1->B1_ENDE  
 
 MSUNLOCK()
 
 ZZ1->( DBSETORDER( 1 ) )      
                   
Return
/*   
User Function MTA120G2()
 
 IF SC7->( DELETED() )
    IF ZZ1->( DBSEEK( XFILIAL("ZZ1") + SC7->C7_NUM + SC7->C7_ITEM ) )
       DBSELECTAREA("ZZ1")
       RECLOCK("ZZ1", .F. )
       DELETE
       MSUNLOCK("ZZ1")
    ENDIF   
    RETURN
 ENDIF   

 IF LEFT( SC7->C7_PRODUTO, 2 ) <> "BR" .AND. SC7->C7_QUANT <> SC7->C7_QUJE
                              
    SB1->( DBSEEK( XFILIAL("SB1") + SC7->C7_PRODUTO ) )
    
    DBSELECTAREA("ZZ1")          
                   
    IF ZZ1->( DBSEEK( XFILIAL("ZZ1") + SC7->C7_NUM + SC7->C7_ITEM ) )
       RECLOCK( "ZZ1", .F. )
    ELSE
       RECLOCK( "ZZ1", .T. )
       ZZ1->ZZ1_FILIAL := XFILIAL("ZZ1") 
       ZZ1->ZZ1_ORDER  := SC7->C7_NUM 
       ZZ1->ZZ1_LINE   := SC7->C7_ITEM 
    ENDIF                  
 
    ZZ1->ZZ1_FORNEC := SC7->C7_FORNECE 
    ZZ1->ZZ1_DATPRF := SC7->C7_DATPRF 
    ZZ1->ZZ1_EMISSA := SC7->C7_EMISSAO 
    ZZ1->ZZ1_CONFIR := M->ZZ1_CONFIR 
    ZZ1->ZZ1_LMTCOD := SC7->C7_PRODUTO 
    ZZ1->ZZ1_SAPCOD := SB1->B1_CAT 
    ZZ1->ZZ1_DESCRI := SC7->C7_CODLMT 
    ZZ1->ZZ1_QTY    := SC7->C7_QUANT - SC7->C7_QUJE
    ZZ1->ZZ1_PRICE  := SC7->C7_PRECO 
    ZZ1->ZZ1_TOTAL  := SC7->C7_PRECO * ( SC7->C7_QUANT - SC7->C7_QUJE ) 
    ZZ1->ZZ1_INVOIC := SC7->C7_INVOICE 
    ZZ1->ZZ1_TRADUC := SB1->B1_DESC 
    ZZ1->ZZ1_NCM    := SB1->B1_POSIPI 
    ZZ1->ZZ1_LOCALI := SB1->B1_ENDE  
 
    MSUNLOCK()
 
 ENDIF
 
Return( .T. )

User Function GeraZZ1()
 
 DO WHILE ! SC7->( EOF() )

    IF SC7->( DELETED() )
       IF ZZ1->( DBSEEK( XFILIAL("ZZ1") + SC7->C7_NUM + SC7->C7_ITEM ) )
          DBSELECTAREA("ZZ1")
          RECLOCK("ZZ1", .F. )
          DELETE
          MSUNLOCK("ZZ1")
       ENDIF   
       DBSELECTAREA("SC7")
       SC7->( DBSKIP() )
       LOOP
    ENDIF   

    IF LEFT( SC7->C7_PRODUTO, 2 ) <> "BR" .AND. SC7->C7_QUANT <> SC7->C7_QUJE
                              
       SB1->( DBSEEK( XFILIAL("SB1") + SC7->C7_PRODUTO ) )
    
       DBSELECTAREA("ZZ1")          
                   
       IF ZZ1->( DBSEEK( XFILIAL("ZZ1") + SC7->C7_NUM + SC7->C7_ITEM ) )
          RECLOCK( "ZZ1", .F. )
       ELSE
          RECLOCK( "ZZ1", .T. )
          ZZ1->ZZ1_FILIAL := XFILIAL("ZZ1") 
          ZZ1->ZZ1_ORDER  := SC7->C7_NUM 
          ZZ1->ZZ1_LINE   := SC7->C7_ITEM 
       ENDIF                  
 
       ZZ1->ZZ1_FORNEC := SC7->C7_FORNECE 
       ZZ1->ZZ1_DATPRF := SC7->C7_DATPRF 
       ZZ1->ZZ1_EMISSA := SC7->C7_EMISSAO 
       ZZ1->ZZ1_CONFIR := SC7->C7_CONFIRM 
       ZZ1->ZZ1_LMTCOD := SC7->C7_PRODUTO 
       ZZ1->ZZ1_SAPCOD := SB1->B1_CAT 
       ZZ1->ZZ1_DESCRI := SC7->C7_CODLMT 
       ZZ1->ZZ1_QTY    := SC7->C7_QUANT - SC7->C7_QUJE
       ZZ1->ZZ1_PRICE  := SC7->C7_PRECO 
       ZZ1->ZZ1_TOTAL  := SC7->C7_PRECO * ( SC7->C7_QUANT - SC7->C7_QUJE ) 
       ZZ1->ZZ1_INVOIC := SC7->C7_INVOICE 
       ZZ1->ZZ1_TRADUC := SB1->B1_DESC 
       ZZ1->ZZ1_NCM    := SB1->B1_POSIPI 
       ZZ1->ZZ1_LOCALI := SB1->B1_ENDE  
 
       MSUNLOCK()
 
    ENDIF                    
 
    SC7->( DBSKIP() )

 ENDDO                 
 
 ZZ1->( DBGOTOP() )
 
Return( .T. )
*/
                    



                     
