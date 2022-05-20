User Function SD1TES()

nPos	:=	aScan( aHeader , { |x| AllTrim( x[2] ) == "D1_CF" } )
nPosTes := 	aScan( aHeader , { |x| AllTrim( x[2] ) == "D1_TES" } )

If Substr( ACOLS[n,nPos] , 2 , 3 ) $ "913" .or. ( Substr( ACOLS[n,nPos] , 2 , 3 ) $ "949" .and. ;
	SF4->( DbSeek( xFilial( "SF4" ) + ACOLS[n,nPosTes] ) ) .and. "MOSTRUARIO" $ Upper( SF4->F4_TXTUSER ) )
	Return("03")
Else	
	If SUBSTR(ACOLS[n,nPos],2,3) == "918"        
		Return("02")	
	Else
		Return("01")
	Endif
Endif     
