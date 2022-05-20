#INCLUDE "rwmake.ch"       

User Function CONEST9X()              

Local cTabela   := GetMv( "MV_TABPREC" )
LOCAL cCodigo   := GetMv( "MV_CONEST9" )

PRIVATE NENTRA := 0 
PRIVATE NSAIDA := 0

IF ! PERGUNTE("CONES9", .T. )
   RETURN
ENDIF                                     
   
DBSELECTAREA("SB2")
SB2->( DBSETORDER( 1 ) )
//SET FILTER TO ! ( SB2->B2_COD < MV_PAR01 .OR. SB2->B2_CODLMT > MV_PAR02 )

//IF ! EMPTY( MV_PAR03 ) .AND. UPPER( MV_PAR04 ) <> "ZZZZZZZ"
//   IF MV_PAR03 $ cCodigo .AND. MV_PAR04 $ cCodigo 
//      SET FILTER TO ( LEFT( SB2->B2_COD, 7 ) >= MV_PAR03 .AND. LEFT( SB2->B2_COD, 7 ) <= MV_PAR04 )  
//   ELSE
//      MSGBOX( "Grupos Incorretos !!!", "", "OK" )
//      RETURN
//   ENDIF                   
//ELSE
//   SET FILTER TO ( LEFT( SB2->B2_COD, 7 ) $ cCodigo )  
//ENDIF                                             
 
IF ! EMPTY( MV_PAR03 ) .AND. UPPER( MV_PAR04 ) <> "ZZZZZZZ"
   IF MV_PAR03 $ cCodigo .AND. MV_PAR04 $ cCodigo 
      cPesq := MV_PAR03 + "/" + MV_PAR04
      SET FILTER TO ( LEFT( SB2->B2_COD, 7 ) $ cPesq )  
   ELSE
      MSGBOX( "Grupos Incorretos !!!", "", "OK" )
      RETURN
   ENDIF                   
ELSE
   SET FILTER TO ( LEFT( SB2->B2_COD, 7 ) $ cCodigo )  
ENDIF                                             
 
SB2->( DBGOTOP() )          

cCod := ""
cCodLMT := ""
     
IF UPPER( MV_PAR05 ) == "S"     
              
DO WHILE ! SB2->( EOF() ) 
                                               
   cCod     := SB2->B2_COD
   cCodLMT  := SB2->B2_CODLMT
  
   nAtual   := 0
   nImed    := 0
   nEmpenho := 0
   nTrans   := 0

   SB1->( DBSEEK( XFILIAL("SB1") + cCod ) )

   DO WHILE ! SB2->( EOF() ) .AND. SB2->B2_COD == cCod
   
      IF SB2->B2_LOCAL == "01"
         nAtual   := SB2->B2_QATU
         nImed    := SB2->B2_QATU - SB2->B2_QEMP
         nEmpenho := SB2->B2_QEMP

      ENDIF
   
      IF SB2->B2_LOCAL == "07"
         nTrans := SB2->B2_QATU
      ENDIF
      
      SB2->( DBSKIP() )
   
   ENDDO                               
   
   IF nAtual <> 0 .OR. nImed <> 0 .OR. nEmpenho <> 0 .OR. nTrans <> 0 .OR. nEntra <> 0 .OR. nSaida <>0

      nRegSB2 := SB2->( RECNO() )
    
      adTela9()
                                                                                                               
      SB2->( DBSETORDER( 1 ) )
      SB2->( DBGOTO( nRegSB2 ) )
      
      dbSelectArea("DA1")
      dbSetOrder(1)
      dbSeek(xFilial("DA1") + cTabela + cCod )

      DBSELECTAREA("ZZ0")
      
      IF ZZ0->( DBSEEK( XFILIAL("ZZ0") + cCod ) )
         RECLOCK( "ZZ0", .F. )
      ELSE   
         RECLOCK( "ZZ0", .T. )                       
      ENDIF
         
      ZZ0->ZZ0_FILIAL := XFILIAL("ZZ0")
      ZZ0->ZZ0_CODIGO := cCod
      ZZ0->ZZ0_CODLMT := cCodLMT
      ZZ0->ZZ0_DESC   := SB1->B1_DESC

      ZZ0->ZZ0_ESTATU := nAtual
      ZZ0->ZZ0_ESTIME := nImed
      ZZ0->ZZ0_EMPENH := nEmpenho
      ZZ0->ZZ0_PRLIST := DA1->DA1_PRCVEN

      ZZ0->ZZ0_DATAAT := DATE()
      ZZ0->ZZ0_HORAAT := TIME()

      ZZ0->ZZ0_PEDCOM := nEntra
      ZZ0->ZZ0_PEDVEN := nSaida

      ZZ0->ZZ0_ESTRAN := nTrans
        
      ZZ0->( MSUNLOCK() )
   
   ELSE
   
//      DBSELECTAREA("ZZ0")
      
//      IF ZZ0->( DBSEEK( XFILIAL("ZZ0") + cCod ) )
         
//         RECLOCK( "ZZ0", .F. )
         
//         DELETE
         
//         ZZ0->( MSUNLOCK() )
         
//      ENDIF   

   ENDIF
   
   DBSELECTAREA("SB2")
     
ENDDO

ENDIF

cCadastro := "Consulta Produtos"
aRotina := { { "Pesquisar","AxPesqui", 0 , 1}}
                
DBSELECTAREA("ZZ0")
//SET FILTER TO ! ( ZZ0->ZZ0_CODLMT < MV_PAR01 .OR. ZZ0->ZZ0_CODLMT > MV_PAR02 )
//SET FILTER TO ( LEFT( ZZ0->ZZ0_CODIGO, 7 ) $ cCodigo )

IF ! EMPTY( MV_PAR03 ) .AND. UPPER( MV_PAR04 ) <> "ZZZZZZZ" 
   IF MV_PAR03 $ cCodigo .AND. MV_PAR04 $ cCodigo 
      cPesq := MV_PAR03 + "/" + MV_PAR04
      SET FILTER TO ( LEFT( ZZ0->ZZ0_CODIGO, 7 ) $ cPesq )  
   ELSE
      MSGBOX( "Grupos Incorretos !!!", "", "OK" )
      RETURN
   ENDIF                   
ELSE
   SET FILTER TO ( LEFT( ZZ0->ZZ0_CODIGO, 7 ) $ cCodigo )  
ENDIF                                                                                                           
 
ZZ0->( DBGOTOP() )                        
                        
mBrowse( 6, 1,22,75,"ZZ0" )
//markbrow( "ZZ0", "", "", )  
      
Return

*******************************************************************************************************************

Static Function adTela9(lContinua)

Local aArea     := GetArea()
Local nSaldoLC  := 0
Local nValItem  := 0
Local nValPed   := 0
Local nLimCred  := 0
Local nMoeda    := 0
Local nQtdVen   := 0
Local nSalPedL  := 0
Local nSalPed   := 0
Local nSalDup	:= 0
Local nSalDupM	:= 0
Local nValAtraso:= 0
Local nOpca 	:= 0
Local nSalvEmp  := 0
Local nCntFor   := 0
Local cDescBloq := ""
Local cDescri   := ""
Local cCondSC9  := ""
Local oBtn
Local oDlg
Local bWhile    := Nil
Local nMCusto   := 0
Local nMCustoCli := 0  	
Local nDecs		:= 0
Local aSaldos
Local lLiberado := .F.
Local nSalFin   := 0
Local nSalFinM  := 0
Local nLcFin    := 0
Local nLcFinM   := 0
Local bcols     :={}
Local aHeader   :={}
Local cMoeda    := ""
Local cTabela   := GetMv( "MV_TABPREC" )
Local nDias		:= GetMV( "MV_DIASEST" )
Local nSaldo07	:= 0
                              
dbSelectArea("SB2")           
dbSetOrder(1)
IF dbSeek(xFilial("SB2") + SB1->B1_COD + "07")
   nSaldo07 := SB2->B2_QATU - SB2->B2_QEMP
ENDIF   

dbSelectArea("SB2")           
dbSetOrder(1)
dbSeek(xFilial("SB2") + SB1->B1_COD + SB1->B1_LOCPAD)

nDispo  := SB2->B2_QATU - SB2->B2_QEMP
nCont   := 0
nImedi1 := SB2->B2_QATU 
nImedi2 := SB2->B2_QATU 
nImedi3 := SB2->B2_QATU 

dbSelectArea("DA1")
dbSetOrder(1)
dbSeek(xFilial("DA1") + cTabela + SB1->B1_COD)

dbSelectArea("SC6")
dbSetOrder(2)
dbSeek(xFilial("SC6") + SB1->B1_COD)
nSaida := 0
While !Eof() .and. C6_FILIAL == xFilial() .and. C6_PRODUTO == SB1->B1_COD
	nSaldo := C6_QTDVEN - C6_QTDENT
	If nSaldo > 0 .and. C6_BLQ <> "R "
		dbSelectArea("SC5")
		dbSetOrder(1)
		dbSeek(xFilial("SC5") + SC6->C6_NUM)		
		nDispo 	-= nSaldo
		nSaida 	+= nSaldo
		nCont++
	Endif
	dbSelectArea("SC6")
	dbSkip()
Enddo

dbSelectArea("SC7")
dbSetOrder(4)
dbSeek(xFilial("SC7") + SB1->B1_COD)
nEntra := 0
While !Eof() .and. C7_FILIAL == xFilial() .and. C7_PRODUTO == SB1->B1_COD
	nSaldo := C7_QUANT - C7_QUJE
	If nSaldo > 0 .AND. C7_RESIDUO <> "S"
		nDispo  += nSaldo
		nEntra  += nSaldo
		nCont++
	Endif 
	dbSelectArea("SC7")
	dbSkip()
Enddo

dbSelectArea("SC2")
dbSetOrder(2)
dbSeek(xFilial("SC2") + SB1->B1_COD)

While !Eof() .and. C2_FILIAL == xFilial() .and. C2_PRODUTO == SB1->B1_COD
	nSaldo := C2_QUANT - C2_QUJE - C2_PERDA
	If nSaldo > 0 .AND. Empty(C2_DATRF)
		nImedi1 -= nSaldo
		nDispo += nSaldo
		nEntra += nSaldo
		nCont++
	Endif
	dbSkip()
Enddo

Return(nOpcA)

*******************************************************************************************************************
