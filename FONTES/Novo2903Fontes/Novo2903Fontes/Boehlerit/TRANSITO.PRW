#Include "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MT100GRV  ³ Autor ³ Ilidio Abreu	        ³ Data ³ 10.03.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ajusta qtde da INVOICE do campo C7_QTDINVO                 ³±±
±±³ Esta qtde é digitado na inclusao do PC e ajustado na Inclusao/Exclusao³±±
±±  da nota fiscal de Entrada	 										  ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico - LMT                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±

/*/

user function MT100GRV// na gravacao da inclusao da NF de Entrada

_cProd	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_COD"})
_cPed	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_PEDIDO"})
_cItem	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEMPC"})
_nQuant	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_QUANT"})

_cProd	:= acols[n][_cProd]
_cPed	:= acols[n][_cPed]
_cItem	:= acols[n][_cItem]
_nQuant	:= acols[n][_nQuant]

/*
_cDoc	:= aScan(aHeader,{|x| AllTrim(x[2])=="F1_DOC"})
_cSerie	:= aScan(aHeader,{|x| AllTrim(x[2])=="F1_SERIE"})
_cDtdigit	:= aScan(aHeader,{|x| AllTrim(x[2])=="F1_DTDIGIT"})
//_nItem	:= aScan(aHeader,{|x| AllTrim(x[2])=="F1_ITEM"})

_cDoc	:= acols[n][_cDoc]
_cSerie	:= acols[n][_cSerie]
_cDtdigit	:= acols[n][_cDtdigit]
//_nItem	:= acols[n][_nItem]
*/

if SF4->F4_ESTOQUE # "S" .or. empty(alltrim(_cPed)) .or. empty(alltrim(_cItem))
	Return .t.
endif

_oldArea := select()
_oldIndex := indexord()
dbselectarea("SC7")
dbsetorder(1)            

if ! dbseek(xfilial("SC7")+_cPed+_cItem) .or. alltrim(SC7->C7_PRODUTO) # alltrim(_cProd)
	dbselectarea(_oldArea)
	dbsetorder(_oldIndex)
    Return .t.         
endif


for _i := 1 to len(acols)
	reclock("SC7",.f.)
	if Inclui .and. (SC7->C7_QTDINVO - _nQuant) >= 0 
		SC7->C7_QTDINVO -= _nQuant
	endif   
	if ! Inclui .and. ! Altera
		SC7->C7_QTDINVO += _nQuant		
	endif
	SC7->(MsUnLock())
next

// msgbox("MT100GRV", "", "OK" )
/*
DBSELECTAREA("ZZ1")    
DBSETORDER( 4 )
DBSEEK( XFILIAL("ZZ1") + _cPed )
IF FOUND()                            

  WHILE ZZ1->ZZ1_ORDER == _cPed .AND.  !Eof() // SD1->D1_DOC == cDocto .AND. !Eof()
    
    if  ZZ1->ZZ1_LMTCOD <> _cProd
    	DBSKIP()
    	LOOP
    endif
    
    RECLOCK( "ZZ1", .F. )
    ZZ1->ZZ1_NFISCA := _cDoc
    ZZ1->ZZ1_SERIE  := _cSerie
    ZZ1->ZZ1_DATENT := _cDtdigit
    ZZ1->ZZ1_ITEMNF := _nItem
 
    MSUNLOCK()
	DBSELECTAREA("ZZ1")
	DBSKIP()
  end

  DBSELECTAREA("ZZ1")    
  DBSEEK( XFILIAL("ZZ1") + SC7->C7_NUM + "9999" )
  IF FOUND()
    RECLOCK( "ZZ1", .F. )
	 
    ZZ1->ZZ1_NFISCA := _cDoc
    ZZ1->ZZ1_SERIE  := _cSerie
    ZZ1->ZZ1_DATENT := _cDtdigit
    ZZ1->ZZ1_ITEMNF := _nItem
	 
    MSUNLOCK()
	    
  ENDIF

ENDIF
*/
/*
 DBSELECTAREA("ZZ1")    
 ZZ1->( DBSETORDER( 4 ) )      
                   
 IF ZZ1->( DBSEEK( XFILIAL("ZZ1") + SC7->C7_NUM + SC7->C7_ITEM ) )
    RECLOCK( "ZZ1", .F. )
    ZZ1->ZZ1_NFISCA := SC7->C7_DOC 
    ZZ1->ZZ1_SERIE  := SC7->C7_SERIE  
    ZZ1->ZZ1_DATENT := SC7->C7_DTDIGIT  
 
    MSUNLOCK()
 
    ZZ1->( DBSETORDER( 1 ) )      
                   
 ENDIF
*/

dbselectarea(_oldArea)
dbsetorder(_oldIndex)
Return      
//
//user function GQREENTR
// msgbox("GQREENTR", "", "OK" )
//
//Return 

//user function SD1100I()
//msgbox("SD1100I", "", "OK" )

//Return 

     