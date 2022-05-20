User Function SD1100E()                 
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
cLocLzDest      := ''
lEstorno        := .F.                  ; nRecOrig		:= 0
nRecDest        := ''                   ; cPrograma		:= '#MSD1100E'
_aSvAlias       := {Alias(),IndexOrd(),Recno()}
lD3_CODLMT		:= .F.
mDATA           := SD1->D1_DTDIGIT

//Consignação
IF Substr(SD1->D1_CF,2,3) $ "918/919"
	cLocDest        :="02"
    cLocOrig		:="01"
   a260Processa(cCodOrig,cLocOrig,nQuant260,cDocto,dEmis260,nQuant260D,cNumLote,cLoteDigi,dDtValid,cNumSerie,cLoclzOrig,cCodDest,cLocDest,cLocLzDest,lEstorno,nRecOrig,nRecDest,cPrograma)

	DBSELECTAREA("SD3")
	DBSETORDER(2)
	DBGOTOP()
	DBSEEK(xFILIAL()+cDocto)
	DO WHILE !EOF() .AND. (SD3->D3_DOC == cDocto) .AND. (DTOS(SD3->D3_EMISSAO) == DTOS(mDATA))
        RECLOCK("SD3",.F.)
        DBDELETE()
		MSUNLOCK()
		DBSELECTAREA("SD3")
		DBSKIP()
	ENDDO
ENDIF
             
//Demonstração
If Substr( SD1->D1_CF , 2 , 3 ) $ "913" .or. ( Substr( SD1->D1_CF , 2 , 3 ) $ "949" .and. ;
	SF4->( DbSeek( xFilial( "SF4" ) + SD1->D1_TES ) ) .and. "MOSTRUARIO" $ Upper( SF4->F4_TXTUSER ) )

	cLocDest        :="03"
    cLocOrig		:="01"
   a260Processa(cCodOrig,cLocOrig,nQuant260,cDocto,dEmis260,nQuant260D,cNumLote,cLoteDigi,dDtValid,cNumSerie,cLoclzOrig,cCodDest,cLocDest,cLocLzDest,lEstorno,nRecOrig,nRecDest,cPrograma)

	DBSELECTAREA("SD3")
	DBSETORDER(2)
	DBGOTOP()
	DBSEEK(xFILIAL()+cDocto)
	DO WHILE !EOF() .AND. (SD3->D3_DOC == cDocto) .AND. (DTOS(SD3->D3_EMISSAO) == DTOS(mDATA))
        RECLOCK("SD3",.F.)
        DBDELETE()
		MSUNLOCK()
		DBSELECTAREA("SD3")
		DBSKIP()
	ENDDO
ENDIF
	
DbSelectArea(_aSvAlias[1])
DbSetOrder(_aSvAlias[2])
DbGoTo(_aSvAlias[3])

DBSELECTAREA("ZZ1")    
DBSETORDER( 4 )
dbseek(xFilial("ZZ1")+SD1->D1_PEDIDO)
if Found()

  WHILE ZZ1->ZZ1_ORDER == SD1->D1_PEDIDO .AND.  !Eof() // SD1->D1_DOC == cDocto .AND. !Eof()
    
    if  ZZ1->ZZ1_LMTCOD <> SD1->D1_COD
    	DBSKIP()
    	LOOP
    endif

    RECLOCK( "ZZ1", .F. )
 
    ZZ1->ZZ1_NFISCA := SPACE( 09 ) 
    ZZ1->ZZ1_SERIE  := SPACE( 03 )  
    ZZ1->ZZ1_DATENT := CTOD( "  /  /  " )  
    ZZ1->ZZ1_ITEMNF := SPACE( 04 )  
 
    MSUNLOCK()
   
	DBSELECTAREA("ZZ1")    
 	dbskip()
 END

  DBSELECTAREA("ZZ1")    
  DBSEEK( XFILIAL("ZZ1") + SD1->D1_PEDIDO + "9999" )
  IF FOUND()
    RECLOCK( "ZZ1", .F. )
    ZZ1->ZZ1_NFISCA := SPACE( 09 ) 
    ZZ1->ZZ1_SERIE  := SPACE( 03 )  
    ZZ1->ZZ1_DATENT := CTOD( "  /  /  " )  
    ZZ1->ZZ1_ITEMNF := SPACE( 04 )  
 
    MSUNLOCK()
   
 ENDIF

endif
/*
 DBSELECTAREA("ZZ1")    
 ZZ1->( DBSETORDER( 4 ) )      
                   
 IF ZZ1->( DBSEEK( XFILIAL("ZZ1") + SD1->D1_PEDIDO + SD1->D1_ITEMPC + SD1->D1_CODLMT ) )
    RECLOCK( "ZZ1", .F. )
 
    ZZ1->ZZ1_NFISCA := SPACE( 09 ) 
    ZZ1->ZZ1_SERIE  := SPACE( 03 )  
    ZZ1->ZZ1_DATENT := CTOD( "  /  /  " )  
    ZZ1->ZZ1_ITEMNF := SPACE( 04 )  
 
    MSUNLOCK()
   
 ENDIF
 
 IF ZZ1->( DBSEEK( XFILIAL("ZZ1") + SD1->D1_PEDIDO + "9999" ) )
    RECLOCK( "ZZ1", .F. )
 
    ZZ1->ZZ1_NFISCA := SPACE( 09 ) 
    ZZ1->ZZ1_SERIE  := SPACE( 03 )  
    ZZ1->ZZ1_DATENT := CTOD( "  /  /  " )  
    ZZ1->ZZ1_ITEMNF := SPACE( 04 )  
 
    MSUNLOCK()
   
 ENDIF
*/
 
 ZZ1->( DBSETORDER( 1 ) )      
                   

Return Nil