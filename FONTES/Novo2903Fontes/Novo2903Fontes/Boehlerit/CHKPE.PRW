#Include "rwmake.ch"

// Checa se o pedido estimado informado existe e se tem saldo do produto para faturar
// Wilson - 22/09/05

User Function CHKPE()

Local	nPosPE		:= aScan( aHeader , { |x| AllTrim( x[2] ) == "C6_NUMPEDP" } )
Local	cNumPE		:= aCols[n,nPosPE]

Local	nPosIPE		:= aScan( aHeader , { |x| AllTrim( x[2] ) == "C6_ITEMPE" } )
Local	cItemPE		:= IF( !Empty( aCols[n,nPosIPE] ) , aCols[n,nPosIPE] , SC6->C6_ITEM )
//Local	cItemPE		:= aCols[n,nPosIPE]

Local	nPosQVPE	:= aScan( aHeader , { |x| AllTrim( x[2] ) == "C6_QTDVEN" } )
Local	nQVPE		:= aCols[n,nPosQVPE]

Local	nPosPro		:= aScan( aHeader , { |x| AllTrim( x[2] ) == "C6_PRODUTO" } )
Local	cCodPro		:= aCols[n,nPosPro]

Local	aArea_SC5	:= SC5->( GetArea() )
Local	aArea_SC6	:= SC6->( GetArea() )
Local	cPicQTV

If Empty( cNumPE )
	aCols[n,nPosIPE]	:= Space( Len( cItemPE ) )
	Return( Space( Len( cNumPE ) ) )
EndIf

SC5->( DbSetOrder( 1 ) )
If !SC5->( DbSeek( xFilial( "SC5" ) + cNumPE ) )
	MsgBox( "Pedido estimado nº " + cNumPE + " não existe !" , "ATENÇÃO" , "INFO" )
	RestArea( aArea_SC5 )
	RestArea( aArea_SC6 )
	aCols[n,nPosIPE]	:= Space( Len( cItemPE ) )
	Return( Space( Len( cNumPE ) ) )
ElseIf SC5->C5_STPAD # "E"
	MsgBox( "Pedido informado nº " + cNumPE + " não é ESTIMADO !" , "ATENÇÃO" , "INFO" )
	RestArea( aArea_SC5 )
	RestArea( aArea_SC6 )
	aCols[n,nPosIPE]	:= Space( Len( cItemPE ) )
	Return( Space( Len( cNumPE ) ) )
EndIf

SC6->( DbSetOrder( 2 ) )

If !SC6->( DbSeek( xFilial( "SC6" ) + cCodPro + cNumPE + cItemPE ) )
	MsgBox( "Pedido estimado nº " + cNumPE + "/" + cItemPE + " com produto " + cCodPro + " não existe !" , "ATENÇÃO" , "INFO" )
	RestArea( aArea_SC5 )
	RestArea( aArea_SC6 )
	aCols[n,nPosIPE]	:= Space( Len( cItemPE ) )
	Return( Space( Len( cNumPE ) ) )

ElseIf nQVPE > SC6->C6_QTDVEN
	cPicQTV	:= TransForm( nQVPE , IF( nQVPE - Int( nQVPE ) # 0 , "@E 9,999,999.999" , "@E 9,999,999,999" ) )
	MsgBox( "Quantidade informada (" + AllTrim( cPicQTV ) +;
	") é maior que a quantidade do pedido estimado (" + AllTrim( TransForm( SC6->C6_QTDVEN , "@E 9,999,999,999" ) ) +;
	")" , "ATENÇÃO" , "INFO" )
	RestArea( aArea_SC5 )
	RestArea( aArea_SC6 )
	aCols[n,nPosIPE]	:= Space( Len( cItemPE ) )
	Return( Space( Len( cNumPE ) ) )

ElseIf SC6->C6_QTDENT >= SC6->C6_QTDVEN
	MsgBox( "Pedido estimado nº " + cNumPE + "/" + cItemPE + " com produto " + cCodPro + " já atendido 100% !" , "ATENÇÃO" , "INFO" )
	RestArea( aArea_SC5 )
	RestArea( aArea_SC6 )
	aCols[n,nPosIPE]	:= Space( Len( cItemPE ) )
	Return( Space( Len( cNumPE ) ) )

ElseIf ( nQVPE + SC6->C6_QTDENT ) > SC6->C6_QTDVEN
	cPicQTV	:= TransForm( nQVPE , IF( nQVPE - Int( nQVPE ) # 0 , "@E 9,999,999.999" , "@E 9,999,999,999" ) )
	MsgBox( "Quantidade informada (" + AllTrim( cPicQTV ) +;
	") + quantidade já atendida (" + AllTrim( TransForm( SC6->C6_QTDENT , "@E 9,999,999,999" ) ) +;
	") é maior que a quantidade do pedido estimado (" + AllTrim( TransForm( SC6->C6_QTDVEN , "@E 9,999,999,999" ) ) +;
	")" , "ATENÇÃO" , "INFO" )
	RestArea( aArea_SC5 )
	RestArea( aArea_SC6 )
	aCols[n,nPosIPE]	:= Space( Len( cItemPE ) )
	Return( Space( Len( cNumPE ) ) )

Else

	RestArea( aArea_SC5 )
	RestArea( aArea_SC6 )
	Return( cNumPE )

EndIf
