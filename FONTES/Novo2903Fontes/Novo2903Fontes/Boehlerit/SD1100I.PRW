


User Function SD1100I()
//#FAP20170124
//RETORNO SIMBÓLICO OU FISICO DE MERCADORIA - TIRA DO 02/03 e ATUALIZA 01     

Local	aArea_SF4	:= SF4->( GetArea() )
Local	aArea_SB1	:= SB1->( GetArea() )

AREGSD3 := {}
PRIVATE NHDLPRV
PRIVATE LCRIAHEADER := .T.
PRIVATE CLOTEEST 
PRIVATE N
private TOTAL := 0

Private cCusMed := GetMv('MV_CUSMED')   ; aLog          := {}
cCodOrig        := SD1->D1_COD          ; cLocOrig		:= SD1->D1_LOCAL
nQuant260       := SD1->D1_QUANT        ; cDocto        := SD1->D1_DOC
dEmis260        := SD1->D1_DTDIGIT      ; nQuant260D    := 0
cNumLote        := ''                   ; cLoteDigi		:= ''
dDtValid        := CTOD('  /  /  ')     ; cNumSerie		:= ''
cLoclzOrig      := ''                   ; cCodDest      := SD1->D1_COD
cLocDest        := "01"			        ; cLocLzDest    := ''
lEstorno        := .F.                  ; nRecOrig		:= 0
nRecDest        := ''                   ; cPrograma		:= '#MSD1100I'
_aSvAlias       := {Alias(),IndexOrd(),Recno()}
lD3_CODLMT		:= .F.

// Ponto de entrada para gravar o CODLMT no SB2

SB1->( DbSetOrder( 1 ) )
SB1->( DbSeek( xFilial( "SB1" ) + SD1->D1_COD ) )

U_GravaLmt()

// Consignacao
If !Empty(cLocDest) .And. ( Substr(SD1->D1_CF,2,3) $ "918/919" )
	lD3_CODLMT		:= .T.
    clocorig:="02"
   a260Processa(cCodOrig,cLocOrig,nQuant260,cDocto,dEmis260,nQuant260D,cNumLote,cLoteDigi,dDtValid,cNumSerie,cLoclzOrig,cCodDest,cLocDest,cLocLzDest,lEstorno,nRecOrig,nRecDest,cPrograma)
   aAdd(aLog,{cCodOrig,cLocOrig,nQuant260,cLocDest})
Endif          
                               	
// Demonstracao
If Substr( SD1->D1_CF , 2 , 3 ) $ "913" .or. ( Substr( SD1->D1_CF , 2 , 3 ) $ "949" .and. ;
	SF4->( DbSeek( xFilial( "SF4" ) + SD1->D1_TES ) ) .and. "MOSTRUARIO" $ Upper( SF4->F4_TXTUSER ) )
	lD3_CODLMT		:= .T.
    clocorig:="03"
   a260Processa(cCodOrig,cLocOrig,nQuant260,cDocto,dEmis260,nQuant260D,cNumLote,cLoteDigi,dDtValid,cNumSerie,cLoclzOrig,cCodDest,cLocDest,cLocLzDest,lEstorno,nRecOrig,nRecDest,cPrograma)
   aAdd(aLog,{cCodOrig,cLocOrig,nQuant260,cLocDest})
Endif     

If 	lD3_CODLMT
    dbSelectArea("SB1")
    dbSetOrder(1)
    dbSelectArea("SD3")
    dbSetOrder(2)
    dbSeek(xFilial("SD3") + cDocto)
	Do While !Eof() .AND. (SD3->D3_DOC == cDocto) .AND. SD3->D3_EMISSAO == SD1->D1_DTDIGIT
		SB1->(dbSeek(xFilial("SB1") + SD3->D3_COD))
		RecLock("SD3",.F.)
		SD3->D3_CODLMT := SB1->B1_CODLMT
		msUnlock()
		dbSkip()
	Enddo
	dbSelectArea("SB2")
	dbSeek(xFilial("SB2") + SD1->D1_COD)
	do While !Eof() .and. B2_FILIAL == xFilial("SB2") .and. B2_COD == SD1->D1_COD
		RecLock("SB2",.F.)
		B2_CODLMT := SB1->B1_CODLMT
		MsUnlock()
		dbSkip()
	Enddo
Endif                                         

/*
// Retorno de Demonstração / Mostruário
If Substr( SD1->D1_CF , 2 , 3 ) $ "913" .or. ( Substr( SD1->D1_CF , 2 , 3 ) $ "949" .and. ;
	SF4->( DbSeek( xFilial( "SF4" ) + SD1->D1_TES ) ) .and. "MOSTRUARIO" $ Upper( SF4->F4_TXTUSER ) )

	// Baixa local 03
	RecLock( "SD3" , .T. )
	SD3->D3_FILIAL	:= xFilial( "SD3" )
	SD3->D3_TM		:= "600"
	SD3->D3_CODLMT	:= SD1->D1_CODLMT
	SD3->D3_COD		:= SD1->D1_COD
	SD3->D3_CF		:= "RE0"
	SD3->D3_UM		:= SD1->D1_UM
	SD3->D3_QUANT	:= SD1->D1_QUANT
	SD3->D3_CONTA	:= SD1->D1_CONTA	
	SD3->D3_LOCAL	:= "03"
	SD3->D3_GRUPO   := SD1->D1_GRUPO
	SD3->D3_DOC		:= SD1->D1_DOC
	SD3->D3_EMISSAO	:= SD1->D1_DTDIGIT
	SD3->D3_NUMSEQ	:= ProxNum()
	SD3->D3_TIPO	:= SD1->D1_TP
	SD3->D3_USUARIO	:= SubStr( cUsuario , 7 , 15 )
	SD3->D3_CHAVE	:= "E0"
	SD3->( MsUnLock() )

	// Entrada no local 01 de retorno de demonstração/mostruário
	If SD1->D1_TES $ GetMv( "MV_TESESTO" )
		RecLock( "SD3" , .T. )
		SD3->D3_FILIAL	:= xFilial( "SD3" )
		SD3->D3_TM		:= "300"
		SD3->D3_CODLMT	:= SD1->D1_CODLMT
		SD3->D3_COD		:= SD1->D1_COD
		SD3->D3_CF		:= "DE0"
		SD3->D3_UM		:= SD1->D1_UM
		SD3->D3_QUANT	:= SD1->D1_QUANT
		SD3->D3_CONTA	:= SD1->D1_CONTA	
		SD3->D3_LOCAL	:= "01"
		SD3->D3_GRUPO   := SD1->D1_GRUPO
		SD3->D3_DOC		:= SD1->D1_DOC
		SD3->D3_EMISSAO	:= SD1->D1_DTDIGIT
		SD3->D3_NUMSEQ	:= ProxNum()
		SD3->D3_TIPO	:= SD1->D1_TP
		SD3->D3_USUARIO	:= SubStr( cUsuario , 7 , 15 )
		SD3->D3_CHAVE	:= "E0"
		SD3->( MsUnLock() )
	EndIf
EndIf	  
*/
	
// Retorna Area de Trabalho
DbSelectArea(_aSvAlias[1])
DbSetOrder(_aSvAlias[2])
DbGoTo(_aSvAlias[3])

RestArea( aArea_SF4 )
RestArea( aArea_SB1 )
	
DbSelectArea(_aSvAlias[1])
DbSetOrder(_aSvAlias[2])
DbGoTo(_aSvAlias[3])

DBSELECTAREA("ZZ1")    
DBSETORDER( 4 )
 
///DBSEEK( XFILIAL("ZZ1") + SD1->D1_PEDIDO )
DBSEEK( XFILIAL("ZZ1") + SD1->D1_PEDIDO + SD1->D1_ITEMPC + SD1->D1_CODLMT )

IF FOUND()
            // LER O SD1 E ENQUANTO TIVER REGISTRO DO MESMO PEDIDO E O MESMO ITEM 
            // GRAVAR DOCUMENTO, SERIE, ETC....
  WHILE ZZ1->ZZ1_ORDER == SD1->D1_PEDIDO .AND.  !Eof() // SD1->D1_DOC == cDocto .AND. !Eof()
    
    if  ZZ1->ZZ1_LMTCOD <> SD1->D1_COD  .or. !EMPTY(ZZ1->ZZ1_NFISCA)
    	DBSKIP()
    	LOOP
    endif

    if  ZZ1->ZZ1_LINE <> SD1->D1_ITEMPC
    	DBSKIP()
    	LOOP
    endif

    RECLOCK( "ZZ1", .F. )
 
    ZZ1->ZZ1_NFISCA := SD1->D1_DOC 
    ZZ1->ZZ1_SERIE  := SD1->D1_SERIE  
    ZZ1->ZZ1_DATENT := SD1->D1_DTDIGIT  
    ZZ1->ZZ1_ITEMNF := SD1->D1_ITEM 

// FEFRAAS00000393 ZZ1_LMTCOD
// FEFRAAS00000393 SD1->D1_COD

    MSUNLOCK()
	DBSELECTAREA("ZZ1")
	DBSKIP()
  end
    
  DBSELECTAREA("ZZ1")    
  DBSEEK( XFILIAL("ZZ1") + SD1->D1_PEDIDO + "9999" )
  IF FOUND()
    RECLOCK( "ZZ1", .F. )
	 
    ZZ1->ZZ1_NFISCA := SD1->D1_DOC 
    ZZ1->ZZ1_SERIE  := SD1->D1_SERIE  
    ZZ1->ZZ1_DATENT := SD1->D1_DTDIGIT  
    ZZ1->ZZ1_ITEMNF := SD1->D1_ITEM 
	 
    MSUNLOCK()
	    
  ENDIF
    
  ZZ1->( DBSETORDER( 1 ) )      
ENDIF
      
/*
 DBSELECTAREA("ZZ1")    
 ZZ1->( DBSETORDER( 4 ) )      
                   
 IF ZZ1->( DBSEEK( XFILIAL("ZZ1") + SD1->D1_PEDIDO + SD1->D1_ITEMPC + SD1->D1_CODLMT ) )

    RECLOCK( "ZZ1", .F. )
 
    ZZ1->ZZ1_NFISCA := SD1->D1_DOC 
    ZZ1->ZZ1_SERIE  := SD1->D1_SERIE  
    ZZ1->ZZ1_DATENT := SD1->D1_DTDIGIT  
    ZZ1->ZZ1_ITEMNF := SD1->D1_ITEM 
 
    MSUNLOCK()
    
 ENDIF
 
 IF ZZ1->( DBSEEK( XFILIAL("ZZ1") + SD1->D1_PEDIDO + "9999" ) )

    RECLOCK( "ZZ1", .F. )
 
    ZZ1->ZZ1_NFISCA := SD1->D1_DOC 
    ZZ1->ZZ1_SERIE  := SD1->D1_SERIE  
    ZZ1->ZZ1_DATENT := SD1->D1_DTDIGIT  
    ZZ1->ZZ1_ITEMNF := SD1->D1_ITEM 
 
    MSUNLOCK()
    
 ENDIF
 
 ZZ1->( DBSETORDER( 1 ) )      
*/
                   

Return
