#INCLUDE "RWMAKE.CH"

User Function GeraRELPC1()

   Private _cHrIni := SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)

   PRIVATE nTipoPed := 1
   PRIVATE aRotina   := {{ "Pesquisar","PesqBrw", 0 , 1},;  //"Pesquisar"
   { "Visualizar","U_GERREL1", 0 , 1},;                     //"Visualizar"
   { "Incluir"   ,"U_GERREL1", 0 , 3},;                     //"Incluir"
   { "Alterar"   ,"U_GERREL1", 0 , 4,6},;                   //"Alterar"
   { "Excluir"   ,"U_GERREL1", 0 , 5,7},;                   //"Excluir"
   { "Imprimir"  ,"U_GERIM1",  0 , 2},;                     //"Imprimir"
   { "Exp.Excel"  ,"U_GEREXC",  0 , 2} }                    //"Imprimir"

   PRIVATE bFiltraBrw:= {|| Nil }
   PRIVATE cCadastro := "Invoice"
   PRIVATE aBackSC7  := {}
   PRIVATE lPedido := .T.
   PRIVATE nItInvoic := 0

   DBSELECTAREA("ZZ1")
   SET FILTER TO ZZ1->ZZ1_LINE <> "9999"

   mBrowse( 6, 1,22,75,"ZZ1",,,,,,)

Return( .T. )

User FUNCTION GERREL1(cAlias,nReg,nOpcX)

   Local oDlg,nOpca, oGet, bOk,nY

   PRIVATE l100Auto := .T.
   PRIVATE l103Auto := .T.
   PRIVATE nItens   := 1000
   PRIVATE aAutoCab:={} , aAutoItens :={}
   PRIVATE lDigita, lAglutina,lGeraLanc, lAbandona := .F.
   PRIVATE cIdentB6 := ""
   PRIVATE cSB6Ant:=""
   PRIVATE lA100CLAS:= (ExistBlock("A100CLAS"))      // Internacionaliza‡„o
   PRIVATE lA100GRAV:= (ExistBlock("A100GRAV"))      // Internacionaliza‡„o
   PRIVATE cCalcImpV:= GETMV("MV_GERIMPV")           // Internacionaliza‡„o
   PRIVATE cMarca   := " "
   PRIVATE lLoja    := .F.
   PRIVATE cTipoNF:='E' 									// Flag utilizada na AliqIcm()
   PRIVATE lIntegracao := IF(GetMV("MV_EASY")=="S",.T.,.F.)
   PRIVATE lEicFin     := IF(GetNewPar("MV_EASYFIN","N")=="S",.T.,.F.)
   PRIVATE lF1Import := IF(SF1->F1_Import=="S",.T.,.F.)
   PRIVATE lConFrete2:=.F.
   PRIVATE lConFrete :=.F.
   PRIVATE lConImp   := .F.
   PRIVATE lConImp2  :=.F., nTotImpos := 0
   PRIVATE aHeader   := {}, aCols := {}
   PRIVATE lZZ1Visual := IF( nOpcX == 2, .T., .F. )
   PRIVATE lZZ1Inclui := IF( nOpcX == 3, .T., .F. )
   PRIVATE lZZ1Altera := IF( nOpcX == 4, .T., .F. )
   PRIVATE lZZ1Esclui := IF( nOpcX == 5, .T., .F. )

   cZZ1 := ZZ1->ZZ1_INVOIC

   DBSELECTAREA("ZZ1")
   ZZ1->( DBGOTOP() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If Type("aBackZZ1")=="U" .Or. Empty(aBackZZ1)

      aBackZZ1 := {}

      dbSelectArea("SX3")
      dbSetOrder(1)
      MsSeek("ZZ1")
      While !Eof() .And. (SX3->X3_ARQUIVO == "ZZ1")
         IF ALLTRIM( SX3->X3_CAMPO ) $ "ZZ1_ORDER;ZZ1_LINE;ZZ1_CONFIR;ZZ1_LMTCOD;ZZ1_SAPCOD;ZZ1_SAPCOD;ZZ1_DESCRI;ZZ1_QTY;ZZ1_PRICE;ZZ1_TOTAL;ZZ1_TRADUC;ZZ1_NCM;ZZ1_LOCALI;ZZ1_NFISCA;ZZ1_SERIE;ZZ1_DATENT"
            IF X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL
               AADD(aBackZZ1,{ TRIM(x3titulo()),;
                  SX3->X3_CAMPO,;
                  SX3->X3_PICTURE,;
                  SX3->X3_TAMANHO,;
                  SX3->X3_DECIMAL,;
                  SX3->X3_VALID ,;
                  SX3->X3_USADO,;
                  SX3->X3_TIPO,;
                  SX3->X3_ARQUIVO,;
                  SX3->X3_CONTEXT})
            EndIf
         ENDIF
         dbSelectArea("SX3")
         dbSkip()
      EndDo
   EndIf
   aHeader := aBackZZ1
   nUsado  := Len(aHeader)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do acols e arrays acessorios.                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	

   nRegZZ1 := ZZ1->( RECNO() )

   If lZZ1Inclui
      aadd(aCols,Array(Len(aHeader)+1))
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Faz a montagem de uma linha em branco no aCols.              ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      For nY := 1 To Len(aHeader)
         aCols[1][nY] := CriaVar(aHeader[nY][2])
         aCols[1][nUsado+1] := .F.
      Next nY
   ELSE

      nRegZZ1 := ZZ1->( RECNO() )
      ZZ1->( DBSETORDER( 1 ) )

      ZZ1->( DBSEEK( XFILIAL("ZZ1") + cZZ1 ) )

      DO WHILE !ZZ1->( EOF() ) .AND. ZZ1->ZZ1_INVOIC == cZZ1

         If  EMPTY(ALLTRIM(ZZ1->ZZ1_ORDER))  .or. ALLTRIM(ZZ1->ZZ1_DESCRI) == "FRETE"
            ZZ1->(DBSKIP())
            Loop
         Endif

         aadd(aCols,Array(Len(aHeader)+1))

         For nY := 1 To LEN( aHeader )
            If ( aHeader[nY][10] <> "V")

               IF ! LEFT( ZZ1->ZZ1_DESCRI, 5 ) == "FRETE"

                  Do Case
                  Case Alltrim(aHeader[nY][2]) == "ZZ1_ORDER"
                     aCols[Len(aCols)][ny] := ZZ1->ZZ1_ORDER
                  Case Alltrim(aHeader[nY][2]) == "ZZ1_LINE"
                     aCols[Len(aCols)][ny] := ZZ1->ZZ1_LINE
                  Case Alltrim(aHeader[nY][2]) == "ZZ1_CONFIR"
                     aCols[Len(aCols)][ny] := ZZ1->ZZ1_CONFIR
                  Case Alltrim(aHeader[nY][2]) == "ZZ1_LMTCOD"
                     aCols[Len(aCols)][ny] := ZZ1->ZZ1_LMTCOD
                  Case Alltrim(aHeader[nY][2]) == "ZZ1_DESCRI"
                     aCols[Len(aCols)][ny] := ZZ1->ZZ1_DESCRI
                  Case Alltrim(aHeader[nY][2]) == "ZZ1_QTY"
                     aCols[Len(aCols)][ny] := ZZ1->ZZ1_QTY
                  Case Alltrim(aHeader[nY][2]) == "ZZ1_PRICE"
                     aCols[Len(aCols)][ny] := ZZ1->ZZ1_PRICE
                  Case Alltrim(aHeader[nY][2]) == "ZZ1_TOTAL"
                     aCols[Len(aCols)][ny] := ZZ1->ZZ1_TOTAL
                  Case Alltrim(aHeader[nY][2]) == "ZZ1_SAPCOD"
                     aCols[Len(aCols)][ny] := ZZ1->ZZ1_SAPCOD
                  Case Alltrim(aHeader[nY][2]) == "ZZ1_INVOIC"
                     aCols[Len(aCols)][ny] := ZZ1->ZZ1_INVOIC
                  Case Alltrim(aHeader[nY][2]) == "ZZ1_TRADUC"
                     aCols[Len(aCols)][ny] := ZZ1->ZZ1_TRADUC
                  Case Alltrim(aHeader[nY][2]) == "ZZ1_NCM"
                     aCols[Len(aCols)][ny] := ZZ1->ZZ1_NCM
                  Case Alltrim(aHeader[nY][2]) == "ZZ1_LOCALI"
                     aCols[Len(aCols)][ny] := ZZ1->ZZ1_LOCALI
                  Case Alltrim(aHeader[nY][2]) == "ZZ1_NFISCA"
                     aCols[Len(aCols)][ny] := ZZ1->ZZ1_NFISCA
                  Case Alltrim(aHeader[nY][2]) == "ZZ1_SERIE"
                     aCols[Len(aCols)][ny] := ZZ1->ZZ1_SERIE
                  Case Alltrim(aHeader[nY][2]) == "ZZ1_DATENT"
                     aCols[Len(aCols)][ny] := ZZ1->ZZ1_DATENT
                  EndCase

               ENDIF

            Else

            EndIf
            aCols[Len(aCols)][ LEN( aHeader ) +1] := .F.
         Next nY
         _flag1 := .f.
         _flag2 := .f.
         ZZ1->( DBSKIP() )

      ENDDO

   ENDIF

   ZZ1->( DBGOTO( nRegZZ1 ) )
   cOrder := ZZ1->ZZ1_ORDER
   cLine  := ZZ1->ZZ1_LINE
   ZZ1->( DBSETORDER( 1 ) )

   M->ZZ1_VRFRET := 0
   nTotInvoic := 0

   DBSELECTAREA("ZZ1")
   SET FILTER TO
   ZZ1->( DBGOTOP() )

   If ! lZZ1Inclui

      IF ZZ1->( DBSEEK( XFILIAL("ZZ1") + cZZ1 ) )

         M->ZZ1_VRFRET := 0
         nTotInvoic := 0

         DO WHILE ! ZZ1->( EOF() ) .AND. ZZ1->ZZ1_INVOIC == cZZ1

            nTotInvoic    := nTotInvoic    + ZZ1->ZZ1_TOTAL

            IF LEFT( ZZ1->ZZ1_DESCRI, 5 ) == "FRETE"
               M->ZZ1_VRFRET := ZZ1->ZZ1_VRFRET
               ZZ1->( DBSKIP() )
               LOOP
            ENDIF

            ZZ1->( DBSKIP() )

         ENDDO

      ENDIF

   ENDIF

   nTotInvoic := nTotInvoic + M->ZZ1_VRFRET

   ZZ1->( DBGOTO( nRegZZ1 ) )
   aButtons   := {}

   aObjects :={}
   aPosObj  :={}
   aSize    :=MsAdvSize()
   aInfo    :={aSize[1],aSize[2],aSize[3],aSize[4],3,3}

   AADD(aObjects,{100,020,.T.,.F.,.F.})
   AADD(aObjects,{100,100,.T.,.T.,.F.})

   aPosObj:=MsObjSize(aInfo,aObjects)
   nOpca:=0

   ZZ1->( DBSEEK( XFILIAL("ZZ1") + cZZ1 ) )

   M->ZZ1_ORDER  := IF( nOpcX == 3, space( 6 )        , ZZ1->ZZ1_ORDER )
   M->ZZ1_LINE   := IF( nOpcX == 3, space( 4 )        , ZZ1->ZZ1_LINE )
   M->ZZ1_FORNEC := IF( nOpcX == 3, space( 10 )       , ZZ1->ZZ1_FORNEC )
   M->ZZ1_EMISSA := IF( nOpcX == 3, CTOD( "  /  /  " ), ZZ1->ZZ1_EMISSA )
   M->ZZ1_DATPRF := IF( nOpcX == 3, CTOD( "  /  /  " ), ZZ1->ZZ1_DATPRF )
   M->ZZ1_CONFIR := IF( nOpcX == 3, space( 30 )       , ZZ1->ZZ1_CONFIR )
   M->ZZ1_LMTCOD := IF( nOpcX == 3, space( 15 )       , ZZ1->ZZ1_LMTCOD )
   M->ZZ1_SAPCOD := IF( nOpcX == 3, space( 10 )       , ZZ1->ZZ1_SAPCOD )
   M->ZZ1_DESCRI := IF( nOpcX == 3, space( 46 )       , ZZ1->ZZ1_DESCRI )
   M->ZZ1_QTY    := IF( nOpcX == 3, 0                 , ZZ1->ZZ1_QTY )
   M->ZZ1_PRICE  := IF( nOpcX == 3, 0                 , ZZ1->ZZ1_PRICE )
   M->ZZ1_TOTAL  := IF( nOpcX == 3, 0                 , ZZ1->ZZ1_TOTAL )
   M->ZZ1_INVOIC := IF( nOpcX == 3, space( 10 )       , ZZ1->ZZ1_INVOIC )
   M->ZZ1_DTINVO := IF( nOpcX == 3, CTOD( "  /  /  " ), ZZ1->ZZ1_DTINVO )
   M->ZZ1_TRADUC := IF( nOpcX == 3, space( 30 )       , ZZ1->ZZ1_TRADUC )
   M->ZZ1_NCM    := IF( nOpcX == 3, space( 10 )       , ZZ1->ZZ1_NCM )
   M->ZZ1_LOCALI := IF( nOpcX == 3, space( 15 )       , ZZ1->ZZ1_LOCALI )
   M->ZZ1_NFISCA := IF( nOpcX == 3, space( 09 )       , ZZ1->ZZ1_NFISCA )
   M->ZZ1_SERIE  := IF( nOpcX == 3, space( 03 )       , ZZ1->ZZ1_SERIE )
   M->ZZ1_DATENT := IF( nOpcX == 3, CTOD( "  /  /  " ), ZZ1->ZZ1_DATENT )

   DBSELECTAREA("ZZ1")
   SET FILTER TO ZZ1->ZZ1_LINE <> "9999"
   DEFINE MSDIALOG oDlg TITLE "Invoices" OF oMainWnd PIXEL From 120, 000 TO 650, 950

   @ 38, 010 SAY OemtoAnsi( "Invoice:" ) SIZE 100, 7 //OF oDlg PIXEL
   @ 38, 050 GET M->ZZ1_INVOIC   PICTURE '@S' SIZE 060, 050

   @ 38, 150 SAY OemtoAnsi( "Dt.Invoice" )   SIZE 50, 7 //OF oDlg PIXEL
   @ 38, 190 GET M->ZZ1_DTINVO PICTURE "@D" SIZE 060, 050

   @ 53, 010 SAY OemtoAnsi( "Total da Invoice:" ) SIZE 40, 7 //OF oDlg PIXEL
   @ 53, 050 GET nTotInvoic    PICTURE "@E 9,999,999.99" SIZE 060, 050

   @ 53, 150 SAY OemtoAnsi( "Valor Frete:" ) SIZE 40, 7 //OF oDlg PIXEL
   @ 53, 190 GET M->ZZ1_VRFRET PICTURE "@E 999,999,999.99" SIZE 060, 050

   oGet := MSGetDados():New(085,5,250,470,nOpcx,,"GravZZ1","",.T.,,,,nItens)
   bOK := { || GravZZ1( nOpcX ) .AND. CLOSE( oDlg ) } //.And. BOK(@nOpca,@oGet,@oDlg) }

   ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bOK,{||nOpca :=0,oDlg:End()},, aButtons)

   IF nOpca == 1
      GravZZ1( nOpcX )
   ENDIF

   DBSELECTAREA("ZZ1")
   SET FILTER TO ZZ1->ZZ1_LINE <> "9999"

   ZZ1->( DBSEEK( XFILIAL("ZZ1") + cZZ1 ) )

RETURN()

User Function ChecQty()

   nItInvoic := n

   aCols[ n, 8 ] := aCols[ n, 6 ] * aCols[ n, 7 ]
   ChecQty1()

Return( .T. )

Static Function ChecQty1()

   aCols[ n, 8 ] := &__readvar * aCols[ n, 6 ]
   nTotalIt := aCols[ n, 8 ]

Return( aCols[ n, 8 ] )

User Function ChecQty2()

   nItInvoic := n

   aCols[ n, 8 ] := &__readvar * aCols[ n, 7 ]
   ChecQty3()

Return( .t. )

Static Function ChecQty3()

   aCols[ n, 8 ] := &__readvar * aCols[ n, 7 ]
   nTotalIt := aCols[ n, 8 ]

Return( aCols[ n, 8 ] )

User Function ChecPric()

   aCols[ n,  7 ] := ROUND( &__readvar / aCols[ n, 6 ], 6 )

   RetPrice()

Return( .t. )

Static Function RetPrice()

   aCols[ n,  7 ] := ROUND( &__readvar / aCols[ n, 6 ], 6 )

Return( aCols[ n, 7 ] )

Static Function ChecOrder()

   SC7->( DBSETORDER( 1 ) )

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

Return( lRet )

Static Function ChecTotal()

   M->ZZ1_TOTAL := ROUND( M->ZZ1_VRFRET + ( M->ZZ1_PRICE * M->ZZ1_QTY ) , 4  )

Return()

User Function MostrSB1()

   SB1->( DBSEEK( XFILIAL("SB1") + LEFT( aCols[ LEN( aCols ), 4 ], 15 ) ) )

   aCols[ LEN( aCols ),  9 ] := SB1->B1_CAT
   aCols[ LEN( aCols ), 10 ] := SB1->B1_DESC
   aCols[ LEN( aCols ), 11 ] := SB1->B1_POSIPI
   aCols[ LEN( aCols ), 12 ] := SB1->B1_ENDE

Return( .T. )

User FUNCTION GERIM1(cAlias,nReg,nOpcX)

   LOCAL cbtxt := SPACE(10)
   LOCAL nQuebra,cCabQuebra,cQuebrant,cCOndBus, nI,nF
   LOCAL CbCont
   LOCAL nQuant_a_Rec := 0
   Local nTotParc := 0
   Local nTxMoeda := 1

   LOCAL CbTxt  := ""
   Local wnrel  := ""
   LOCAL cDesc1 := "Emissao da Relacao de Invoices."
   LOCAL cDesc2 := ""
   LOCAL cDesc3 := ""

   Local nXX 		   := 0
   Local cFields	   := ""
   Local cDetal	   := ""
   Local aStru 	   := {}
   Local cFileName   := ""
   Local cPATH		   := ""
   Local cDestino	   := ""

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

   dbSetOrder( nOrdem )
   ZZ1->( DBGOTOP() )

   cabec1 := "ORDER  LINE CONFIRMATION                   LMTCODE         SAPCODE              DESCRIPTION                                  QTY        PRICE        TOTAL INVOICE          DATA      TRADUÇAO                        NCM         LOCAL     N.FISCAL  SERIE ENTRADA"
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
   aFrete    := {}

   aStru := {}
   aAdd(aStru,{"NRORDER"       ,"C",06,0})
   aAdd(aStru,{"LINE"          ,"C",04,0})
   aAdd(aStru,{"CONFIRM"       ,"C",30,0})
   aAdd(aStru,{"LMTCOD"        ,"C",15,0})
   aAdd(aStru,{"SAPCOD"        ,"C",10,0})
   aAdd(aStru,{"DESCRI"	       ,"C",46,0})
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

   cArq := CriaTrab(aStru,.T.)
   dbUseArea(.T.,,cArq,"TRB",.T.)
   cInd := CriaTrab(NIL,.F.)
   nTotItem := 0
   nTotFret := 0

   DBSELECTAREA("ZZ1")
   SET FILTER TO

   IF nOrdem == 1
      ZZ1->( DBSEEK( XFILIAL("ZZ1") + ALLTRIM( MV_PAR01 ) ) )
   ENDIF

   cOrder := ZZ1->ZZ1_ORDER

   Do While ! ZZ1->( Eof() )

      IF ZZ1->ZZ1_INVOIC < MV_PAR01 .OR. ZZ1->ZZ1_INVOIC > MV_PAR02
         ZZ1->( DBSKIP() )
         LOOP
      ENDIF

      IF ( ZZ1->ZZ1_DTINVO < MV_PAR03 .OR. ZZ1->ZZ1_DTINVO > MV_PAR04 )
         ZZ1->( DBSKIP() )
         LOOP
      ENDIF

      IF ( ZZ1->ZZ1_FORNEC < MV_PAR05 .OR. ZZ1->ZZ1_FORNEC > MV_PAR06 )
         ZZ1->( DBSKIP() )
         LOOP
      ENDIF

      IF ( ! EMPTY( ZZ1->ZZ1_NFISCA ) .AND. MV_PAR08 $ "A;a" )
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

      IF ZZ1->ZZ1_LINE <> "9999"

         cOrder := ZZ1->ZZ1_ORDER

         @ li,000 PSAY ZZ1->ZZ1_ORDER
         @ li,007 PSAY ZZ1->ZZ1_LINE

         SC7->( DBSETORDER( 1 ) )
         SC7->( DBSEEK( XFILIAL("SC7") + ZZ1->ZZ1_ORDER + ZZ1->ZZ1_LINE ) )

         IF ! EMPTY( SC7->C7_CONFIRM )
            @ li,012 PSAY SC7->C7_CONFIRM
         ELSE
            @ li,012 PSAY ZZ1->ZZ1_CONFIR
         ENDIF
         @ li,043 PSAY ZZ1->ZZ1_LMTCOD
         IF UPPER( MV_PAR07 ) == "S"
            @ li,069 PSAY ZZ1->ZZ1_SAPCOD
         ENDIF
         @ li,080 PSAY LEFT( ZZ1->ZZ1_DESCRI, 40 )
         @ li,121 PSAY ZZ1->ZZ1_QTY    PICTURE "@E 999,999"
         @ li,129 PSAY ZZ1->ZZ1_PRICE  PICTURE "@E 999,999.9999"
         @ li,142 PSAY ZZ1->ZZ1_TOTAL  PICTURE "@E 9,999,999.99"
         @ li,155 PSAY ZZ1->ZZ1_INVOIC
         @ li,172 PSAY ZZ1->ZZ1_DTINVO
         @ li,182 PSAY ZZ1->ZZ1_TRADUC
         @ li,214 PSAY ZZ1->ZZ1_NCM
         @ li,226 PSAY ZZ1->ZZ1_LOCALI
         @ li,243 PSAY ZZ1->ZZ1_NFISCA
         @ li,254 PSAY ZZ1->ZZ1_SERIE
         @ li,260 PSAY ZZ1->ZZ1_DATENT

         DBSELECTAREA("TRB")
         RECLOCK("TRB", .T. )

         TRB->NRORDER   := ZZ1->ZZ1_ORDER
         TRB->LINE      := ZZ1->ZZ1_LINE

         SC7->( DBSETORDER( 1 ) )
         SC7->( DBSEEK( XFILIAL("SC7") + ZZ1->ZZ1_ORDER + ZZ1->ZZ1_LINE ) )

         IF ! EMPTY( SC7->C7_CONFIRM )
            TRB->CONFIRM   := SC7->C7_CONFIRM
         ELSE
            TRB->CONFIRM   := ZZ1->ZZ1_CONFIR
         ENDIF

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
         li     := li + 1
      ENDIF

      DBSELECTAREA("ZZ1")

      IF ZZ1->ZZ1_LINE <> "9999"
         cInvoice := ZZ1->ZZ1_INVOIC
      Else
         nTotFret  := nTotFret  + ZZ1->ZZ1_VRFRET
      ENDIF

      IF ZZ1->ZZ1_INVOIC <> cInvoice .AND. nOrdem == 1
         nTotItem  := 0 //nTotItem  + ZZ1->ZZ1_TOTAL
         nTotOrder := 0
         li     := li + 1
      Else
         nTotItem  := nTotItem  + ZZ1->ZZ1_TOTAL
         nTotOrder := nTotOrder + ZZ1->ZZ1_TOTAL //+ ZZ1->ZZ1_VRFRET
      Endif

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

      If nTotFret > 0 // := nTotFret  + ZZ1->ZZ1_VRFRET

         nF := ASCAN( aFrete, cInvoice )
         lRet1 := .F.

         FOR nF := 1 TO LEN( aFrete )
            IF aFrete[ nF, 1 ] == cInvoice
               lRet1 := .T.
               EXIT
            ENDIF
         NEXT nF

         IF !lRet1
            AADD( aFrete, { cInvoice, nTotFret } )
         ENDIF
         nTotFret  := 0
      Endif
      
      nTotOrder := 0

      ZZ1->( DBSKIP() )

      IF ZZ1->ZZ1_INVOIC <> cInvoice //.AND. nOrdem == 1
         cInvoice := ZZ1->ZZ1_INVOIC
      ENDIF

   ENDDO

   nTotFrete := 0

   If len(aFrete) > 0
      FOR nF := 1 TO LEN( aFrete )
         nTotFrete +=  aFrete[ nF, 2 ]
      NEXT nF
   Endif

   @ li,080 PSAY "Total Itens"
   @ li,142 PSAY nTotItem  PICTURE "@E 9,999,999.99"

   li     := li + 3

   @ li,080 PSAY "Total Frete"
   @ li,142 PSAY nTotFrete  PICTURE "@E 9,999,999.99"
   li     := li + 3

   @ li,080 PSAY "Total"
   @ li,142 PSAY nTotItem + nTotFrete  PICTURE "@E 9,999,999.99"

   li     := li + 3

   DBSELECTAREA("TRB")
   RECLOCK("TRB", .T. )

   TRB->DESCRI    := "Sub-Total"
   TRB->TOTAL     := nTotItem

   MSUNLOCK("TRB")
   RECLOCK("TRB", .T. )

   TRB->DESCRI    := "Frete"
   TRB->TOTAL     := nTotFrete

   MSUNLOCK("TRB")
   RECLOCK("TRB", .T. )

   TRB->DESCRI    := "Total"
   TRB->TOTAL     := nTotItem + nTotFrete

   MSUNLOCK("TRB")

   li     := li + 3

   @ li,015 PSAY "RESUMO"

   DBSELECTAREA("TRB")
   RECLOCK("TRB", .T. )

   TRB->DESCRI    := "RESUMO"

   MSUNLOCK("TRB")

   li     := li + 2

   nTotal := 0

   ASORT(aOrder,,, { |x, y| x[1] < y[1] })
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
   
   cPATH:= 'C:\TEMP\'
   cFileName   := "GERARELPCA"+"_"+DTOS(DATE())+"_"+_cHrIni+"_"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)+".CSV"
   cDestino	:= PADR(cPATH+cFileName, 100)

   //CABEÇALHO
   For nXX := 1 to Len(aStru)
      cFields += aStru[nXX][1] + ";"//Nome do campo
   Next

   cFields := Left(cFields, Len(cFields) -1) //Remover a ultimo ponto e virgula
   U_ArqLog(cFields,cDestino,"")

   DbSelectArea("TRB")
   DbGoTop()         
      
   While !TRB->(EOF())
         IncProc()
         RecLock("TRB", .F.)

         cDetal:= ""
         cDetal+= cValToChar(NRORDER)   	+ ";"	
         cDetal+= cValToChar(LINE)   	   + ";"
         cDetal+= cValToChar(CONFIRM)   	+ ";"
         cDetal+= cValToChar(LMTCOD)   	+ ";"
         cDetal+= cValToChar(SAPCOD)   	+ ";"
         cDetal+= cValToChar(DESCRI)   	+ ";"
         cDetal+= cValToChar(QTY)   	   + ";"
         cDetal+= StrTran(cValToChar(PRICE),".", ",") + ";"
         cDetal+= StrTran(cValToChar(TOTAL),".", ",") + ";"
         cDetal+= cValToChar(INVOICE)     + ";"
         cDetal+= cValToChar(DTINVOICE)   + ";"
         cDetal+= cValToChar(TRADUCAO)    + ";"
         cDetal+= cValToChar(NCM)   	   + ";"
         cDetal+= cValToChar(LOCALIZ)     + ";"
         cDetal+= cValToChar(NFISCA)      + ";"
         cDetal+= cValToChar(SERIE)       + ";"
         cDetal+= cValToChar(DATENT)      + ";"
         cDetal+= cValToChar(ITEMNF)

         U_ArqLog(cDetal,cDestino,"")

         TRB->(MsUnLock())
         TRB->(DbSkip())
         
   EndDo

   TRB->(DBCLOSEAREA())

   DBSELECTAREA("ZZ1")
   SET FILTER TO ZZ1->ZZ1_LINE <> "9999"

   ZZ1->( DBGOTO( nRegZZ1 ) )

Return

********************************
Static Function GravZZ1( nOpcX )
********************************
   Local nI:=0;

   DBSELECTAREA("ZZ1")
   SET FILTER TO

   nTotal := 0
   ZZ1->( DBGOTO( nRegZZ1 ) )

   FOR nI := 1 TO LEN( aCols )

      If Empty(Alltrim(aCols[ nI, 1 ]))
         aCols[ nI, 16 ] :=  .T.
         Loop
      Endif
      IF aCols[ nI, 16 ] <> .T.  .and. Valtype(aCols[ nI, 16 ]) == "L"
         If Valtype(aCols[ nI, 8 ]) == "N"
            nTotal     := nTotal + aCols[ nI, 8 ]
         Endif
      ENDIF

   NEXT nI

   IF M->ZZ1_VRFRET <> 0
      nTotal     := nTotal + M->ZZ1_VRFRET
   ENDIF

   nTotal     := INT( nTotal * 100 ) / 100

   ZZ1->( DBGOTO( nRegZZ1 ) )

   IF nOpcX == 5
      DBSELECTAREA("ZZ1")
      ZZ1->( DBGOTO( nRegZZ1 ) )

      ZZ1->( DBSEEK( XFILIAL("ZZ1") + cZZ1 ) )

      DO WHILE !ZZ1->( EOF() ) .AND. ZZ1->ZZ1_INVOIC == cZZ1
         RECLOCK("ZZ1", .F. )
         DELETE

         MSUNLOCK("ZZ1")
         ZZ1->( DBSKIP() )
      ENDDO

      Return( .T. )

   ENDIF

   IF ROUND( nTotal, 2 ) <> ROUND( nTotInvoic, 2 )
      If MsgYesNo("Valor Total não bate com os parciais !!!" + " " + STR(NTOTINVOIC, 15,2) +  STR(NTOTAL,15,2)+", deseja continuar?",OemToAnsi('ATENÇÃO'))
         //Return( .T. )
      Else
         Return( .F. )
      Endif
   ENDIF

   DBSELECTAREA("ZZ1")
   ZZ1->( DBSETORDER( 1 ) )

   FOR nI := 1 TO LEN( aCols )

      IF aCols[ nI, 16 ] == .T.
         RECLOCK( "ZZ1", .F. )
         DELETE
         MSUNLOCK()
         Loop
      Endif
      SB1->( DBSEEK( XFILIAL("SB1") + LEFT( aCols[ nI, 4 ], 15 ) ) )

      IF ZZ1->( DBSEEK( XFILIAL("ZZ1") + cZZ1 + aCols[ nI, 1 ] + aCols[ nI, 2 ] ) )
         RECLOCK( "ZZ1", .F. )
         ZZ1->ZZ1_ORDER  := aCols[ nI, 1 ]
         ZZ1->ZZ1_LINE   := aCols[ nI, 2 ]
      ELSE
         RECLOCK( "ZZ1", .T. )
         ZZ1->ZZ1_FILIAL := XFILIAL("ZZ1")
         ZZ1->ZZ1_ORDER  := aCols[ nI, 1 ]
         ZZ1->ZZ1_LINE   := aCols[ nI, 2 ]
      ENDIF

      IF EMPTY( M->ZZ1_FORNEC )
         IF SC7->( DBSEEK( XFILIAL("SC7") + aCols[ nI, 1 ] + aCols[ nI, 2 ] ) )
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

      M->ZZ1_FORNEC := ZZ1->ZZ1_FORNEC
      M->ZZ1_DATPRF := ZZ1->ZZ1_DATPRF
      M->ZZ1_EMISSA := ZZ1->ZZ1_EMISSA

      ZZ1->ZZ1_CONFIR := aCols[ nI, 3 ]
      ZZ1->ZZ1_LMTCOD := aCols[ nI, 4 ]
      ZZ1->ZZ1_SAPCOD := SB1->B1_CAT
      ZZ1->ZZ1_DESCRI := aCols[ nI, 5 ]
      ZZ1->ZZ1_QTY    := aCols[ nI, 6 ]
      ZZ1->ZZ1_PRICE  := aCols[ nI, 7 ]
      ZZ1->ZZ1_TOTAL  := aCols[ nI, 8 ]
      ZZ1->ZZ1_INVOIC := M->ZZ1_INVOIC
      ZZ1->ZZ1_DTINVO := M->ZZ1_DTINVO
      ZZ1->ZZ1_TRADUC := SB1->B1_DESC
      ZZ1->ZZ1_NCM    := SB1->B1_POSIPI
      ZZ1->ZZ1_LOCALI := SB1->B1_ENDE

      ZZ1->ZZ1_NFISCA := aCols[ nI, 13 ]
      ZZ1->ZZ1_SERIE  := aCols[ nI, 14 ]
      ZZ1->ZZ1_DATENT := aCols[ nI, 15 ]

      MSUNLOCK()

   NEXT nI

   IF M->ZZ1_VRFRET <> 0
      IF nOpcX == 5
         RECLOCK( "ZZ1", .T. )
      ELSE
         IF ! ZZ1->( EOF() )
            ZZ1->( DBSKIP() )
         ENDIF
         IF LEFT( ZZ1->ZZ1_DESCRI, 5 ) == "FRETE"
            RECLOCK( "ZZ1", .F. )
         ELSE
            RECLOCK( "ZZ1", .T. )
         ENDIF
         ZZ1->ZZ1_FILIAL := XFILIAL("ZZ1")
         ZZ1->ZZ1_ORDER  := aCols[ nI - 1, 1 ]
         ZZ1->ZZ1_LINE   := "9999"
         ZZ1->ZZ1_DESCRI := "FRETE"
         ZZ1->ZZ1_INVOIC := M->ZZ1_INVOIC
         ZZ1->ZZ1_DTINVO := M->ZZ1_DTINVO
         ZZ1->ZZ1_DATPRF := M->ZZ1_DATPRF
         ZZ1->ZZ1_EMISSA := M->ZZ1_EMISSA
         ZZ1->ZZ1_FORNEC := M->ZZ1_FORNEC
         ZZ1->ZZ1_VRFRET := M->ZZ1_VRFRET
         ZZ1->( MSUNLOCK() )
      ENDIF

      ZZ1->( DBGOTO( nRegZZ1 ) )

   ENDIF

   M->ZZ1_VRFRET := 0
   nTotInvoic := 0

   DO WHILE ! ZZ1->( EOF() ) .AND. ZZ1->ZZ1_INVOIC == cZZ1

      M->ZZ1_VRFRET := M->ZZ1_VRFRET + ZZ1->ZZ1_VRFRET
      nTotInvoic    := nTotInvoic    + ZZ1->ZZ1_TOTAL

      ZZ1->( DBSKIP() )

   ENDDO

   ZZ1->( DBGOTO( nRegZZ1 ) )
   ZZ1->( DBSETORDER( 1 ) )

   DBSELECTAREA("ZZ1")
   SET FILTER TO ZZ1->ZZ1_LINE <> "9999"

   ZZ1->( DBGOTO( nRegZZ1 ) )

Return( .T. )


User FUNCTION GEREXC(cAlias,nReg,nOpcX)

   LOCAL cbtxt := SPACE(10)
   LOCAL nQuebra,cCabQuebra,cQuebrant,cCOndBus
   LOCAL CbCont
   LOCAL nQuant_a_Rec := 0
   Local nTotParc := 0
   Local nTxMoeda := 1

   LOCAL CbTxt  := ""
   Local wnrel  := ""
   LOCAL cDesc1 := "Emissao da Relacao de Invoices."
   LOCAL cDesc2 := ""
   LOCAL cDesc3 := ""
Local nI, nF
   Local nXX 		:= 0
   Local cFields	:= ""
   Local cDetal	:= ""
   Local aStru 	:= {}
   Local cFileName := ""
   Local cPATH		:= ""
   Local cDestino	:= ""

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

   Pergunte("GERREL",.T.)

   aOrd    := { "Invoice", "Data Invoice", "Descriçao", "Order + Line" }

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
   nTotIVA    := 0      // Total de IVA (impostos)

   nPedida    := 0	   // qtde pedida
   nValIpi    := 0 	   // valor do ipi
   nTotal     := 0      // valor total do pedido
   nQuant     := 0	   // qtde entregue
   nSaldo     := 0 	   // saldo a receber
   nFlag		  := 0	   // flag que indica se imprime totais por item ou nao
   nITemIpi   := 0
   nSalIpi    := 0
   nFrete	  := 0	   // valor do frete
   nDesc      := 0 	   // valor do desconto
   nValIVA    := 0      // valor do IVA
   nItemIVA   := 0      // valor do item do imposto

   cabec1    := "RELACAO DOS PEDIDOS DE COMPRAS"

   nOrdem := 1 //aReturn[8]

   dbSelectArea("ZZ1")
   nRegZZ1 := ZZ1->( RECNO() )

   dbSetOrder( 1 ) //nOrdem )
   ZZ1->( DBGOTOP() )

   cabec1 := "ORDER  LINE CONFIRMATION                   LMTCODE         SAPCODE              DESCRIPTION                                  QTY        PRICE        TOTAL INVOICE          DATA      TRADUÇAO                        NCM         LOCAL     N.FISCAL  SERIE ENTRADA"
//		   0         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20
//         0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789

   nTotOrder := 0
   aOrder    := {}
   aFrete    := {}

   aStru := {}
   aAdd(aStru,{"NRORDER"       ,"C",06,0})
   aAdd(aStru,{"LINE"          ,"C",04,0})
   aAdd(aStru,{"CONFIRM"       ,"C",30,0})
   aAdd(aStru,{"LMTCOD"        ,"C",15,0})
   aAdd(aStru,{"SAPCOD"        ,"C",10,0})
   aAdd(aStru,{"DESCRI"	       ,"C",46,0})
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

   cArq := CriaTrab(aStru,.T.)
   dbUseArea(.T.,,cArq,"TRB",.T.)
   cInd := CriaTrab(NIL,.F.)
   nTotItem := 0
   nTotFret := 0

   DBSELECTAREA("ZZ1")
   SET FILTER TO

   IF nOrdem == 1
      ZZ1->( DBSEEK( XFILIAL("ZZ1") + ALLTRIM( MV_PAR01 ) ) )
   ENDIF

   cOrder := ZZ1->ZZ1_ORDER

   Do While ! ZZ1->( Eof() )

      IF ZZ1->ZZ1_INVOIC < MV_PAR01 .OR. ZZ1->ZZ1_INVOIC > MV_PAR02
         ZZ1->( DBSKIP() )
         LOOP
      ENDIF

      IF ( ZZ1->ZZ1_DTINVO < MV_PAR03 .OR. ZZ1->ZZ1_DTINVO > MV_PAR04 )
         ZZ1->( DBSKIP() )
         LOOP
      ENDIF

      IF ( ZZ1->ZZ1_FORNEC < MV_PAR05 .OR. ZZ1->ZZ1_FORNEC > MV_PAR06 )
         ZZ1->( DBSKIP() )
         LOOP
      ENDIF

      IF ( ! EMPTY( ZZ1->ZZ1_NFISCA ) .AND. MV_PAR08 $ "A;a" )
         ZZ1->( DBSKIP() )
         LOOP
      ENDIF

      nItemIpi := 0
      nSalIpi := 0
      nItemIVA  := 0

      IF ZZ1->ZZ1_LINE <> "9999"

         cOrder := ZZ1->ZZ1_ORDER

         SC7->( DBSETORDER( 1 ) )
         SC7->( DBSEEK( XFILIAL("SC7") + ZZ1->ZZ1_ORDER + ZZ1->ZZ1_LINE ) )

         DBSELECTAREA("TRB")
         RECLOCK("TRB", .T. )

         TRB->NRORDER   := ZZ1->ZZ1_ORDER
         TRB->LINE      := ZZ1->ZZ1_LINE

         SC7->( DBSETORDER( 1 ) )
         SC7->( DBSEEK( XFILIAL("SC7") + ZZ1->ZZ1_ORDER + ZZ1->ZZ1_LINE ) )

         IF ! EMPTY( SC7->C7_CONFIRM )
            TRB->CONFIRM   := SC7->C7_CONFIRM
         ELSE
            TRB->CONFIRM   := ZZ1->ZZ1_CONFIR
         ENDIF

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

      ENDIF

      DBSELECTAREA("ZZ1")

      IF ZZ1->ZZ1_LINE <> "9999"
         cInvoice := ZZ1->ZZ1_INVOIC
      Else
         nTotFret  := nTotFret  + ZZ1->ZZ1_VRFRET
      ENDIF

      IF ZZ1->ZZ1_INVOIC <> cInvoice .AND. nOrdem == 1
         nTotItem  := 0 //nTotItem  + ZZ1->ZZ1_TOTAL
         nTotOrder := 0
      Else
         nTotItem  := nTotItem  + ZZ1->ZZ1_TOTAL
         nTotOrder := nTotOrder + ZZ1->ZZ1_TOTAL //+ ZZ1->ZZ1_VRFRET
      Endif

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

      If nTotFret > 0 // := nTotFret  + ZZ1->ZZ1_VRFRET

         nF := ASCAN( aFrete, cInvoice )
         lRet1 := .F.

         FOR nF := 1 TO LEN( aFrete )
            IF aFrete[ nF, 1 ] == cInvoice
               lRet1 := .T.
               EXIT
            ENDIF
         NEXT nF

         IF !lRet1
            AADD( aFrete, { cInvoice, nTotFret } )
         ENDIF
         nTotFret  := 0
      Endif

      nTotOrder := 0

      ZZ1->( DBSKIP() )

      IF ZZ1->ZZ1_INVOIC <> cInvoice //.AND. nOrdem == 1
         cInvoice := ZZ1->ZZ1_INVOIC
      ENDIF

   ENDDO

   DBSELECTAREA("TRB")
   RECLOCK("TRB", .T. )

   TRB->DESCRI    := "Sub-Total"
   TRB->TOTAL     := nTotItem

   MSUNLOCK("TRB")

   nTotFrete := 0

   If len(aFrete) > 0
      FOR nF := 1 TO LEN( aFrete )
         nTotFrete +=  aFrete[ nF, 2 ]
      NEXT nF
   Endif

   RECLOCK("TRB", .T. )

   TRB->DESCRI    := "Frete"
   TRB->TOTAL     := nTotFrete //nTotFret

   MSUNLOCK("TRB")
   RECLOCK("TRB", .T. )

   TRB->DESCRI    := "Total"
   TRB->TOTAL     := nTotItem + nTotFrete //nTotFret

   MSUNLOCK("TRB")

   DBSELECTAREA("TRB")
   RECLOCK("TRB", .T. )

   TRB->DESCRI    := "RESUMO"

   MSUNLOCK("TRB")

   nTotal := 0

   ASORT(aOrder,,, { |x, y| x[1] < y[1] })
   FOR nI := 1 TO LEN( aOrder )

      @ li,015 PSAY aOrder[ nI, 1 ]
      @ li,030 PSAY aOrder[ nI, 2 ] PICTURE "@E 9,999,999.99"

      DBSELECTAREA("TRB")
      RECLOCK("TRB", .T. )

      TRB->DESCRI    := aOrder[ nI, 1 ]
      TRB->TOTAL     := aOrder[ nI, 2 ]

      MSUNLOCK("TRB")

      nTotal := nTotal + aOrder[ nI, 2 ]

   NEXT nI

   DBSELECTAREA("TRB")
   RECLOCK("TRB", .T. )

   TRB->DESCRI    := "TOTAL"
   TRB->TOTAL     := nTotal

   MSUNLOCK("TRB")

   dbSelectArea("ZZ1")
   Set Filter To
   dbSetOrder(1)

   DBSELECTAREA("ZZ1")
   SET FILTER TO ZZ1->ZZ1_LINE <> "9999"

   ZZ1->( DBGOTO( nRegZZ1 ) )

   cPATH       := 'C:\TEMP\'
   cFileName   := "GERRELIMP"+"_"+DTOS(DATE())+"_"+_cHrIni+"_"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)+".CSV"
   cDestino	   := PADR(cPATH+cFileName, 100)

   //CABEÇALHO
   For nXX := 1 to Len(aStru)
      cFields += aStru[nXX][1] + ";"//Nome do campo
   Next

   cFields := Left(cFields, Len(cFields) -1) //Remover a ultimo ponto e virgula
   U_ArqLog(cFields,cDestino,"")

   DbSelectArea("TRB")
   DbGoTop()         
      
   While !TRB->(EOF())
         IncProc()
         RecLock("TRB", .F.)

         cDetal:= ""
         cDetal+= cValToChar(NRORDER)   	+ ";"	
         cDetal+= cValToChar(LINE)   	   + ";"
         cDetal+= cValToChar(CONFIRM)   	+ ";"
         cDetal+= cValToChar(LMTCOD)   	+ ";"
         cDetal+= cValToChar(SAPCOD)   	+ ";"
         cDetal+= cValToChar(DESCRI)   	+ ";"
         cDetal+= cValToChar(QTY)   	   + ";"
         cDetal+= StrTran(cValToChar(PRICE),".", ",") + ";"
         cDetal+= StrTran(cValToChar(TOTAL),".", ",") + ";"
         cDetal+= cValToChar(INVOICE)     + ";"
         cDetal+= cValToChar(DTINVOICE)   + ";"
         cDetal+= cValToChar(TRADUCAO)    + ";"
         cDetal+= cValToChar(NCM)   	   + ";"
         cDetal+= cValToChar(LOCALIZ)     + ";"
         cDetal+= cValToChar(NFISCA)      + ";"
         cDetal+= cValToChar(SERIE)       + ";"
         cDetal+= cValToChar(DATENT)      + ";"
         cDetal+= cValToChar(ITEMNF)

         U_ArqLog(cDetal,cDestino,"")

         TRB->(MsUnLock())
         TRB->(DbSkip())
         
   EndDo

   Alert("Arquivo gerado na pasta: "+ cDestino)

   If ApOleClient("MsExcel")
      oExcelApp:= MsExcel():New()
      oExcelApp:WorkBooks:Open(cDestino)
      oExcelApp:SetVisible(.T.)
   EndIf
   
   TRB->(DbCloseArea())
   
Return
