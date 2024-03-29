#Include "rwmake.ch"

// Checa se a data de entrega e solicita��o (C6_ENTREG e C6_PROMET) � superior a emiss�o
// do pedido (C5_EMISSAO )
// Wilson - 22/09/05

User Function CHKDTEP()

Local	nPosDTE	:=	aScan( aHeader , { |x| AllTrim( x[2] ) == "C6_ENTREG" } )
Local	dDTE	:= aCols[n,nPosDTE]

Local	nPosDTP	:=	aScan( aHeader , { |x| AllTrim( x[2] ) == "C6_PROMET" } )
Local	dDTP	:= aCols[n,nPosDTP]

If AllTrim( ReadVar() ) == "M->C6_ENTREG"
	If dDTE < M->C5_EMISSAO
		MsgBox( "1-Data de entrega n�o pode inferior a data de emiss�o do pedido � " +;
		DtoC( M->C5_EMISSAO ) , "ATEN��O" , "INFO" )
		aCols[n,nPosDTE]	:= M->C5_EMISSAO
		dDTE				:= aCols[n,nPosDTE]
	EndIf
//	If dDTE < dDTP
  //		MsgBox( "2-Data de entrega n�o pode inferior a data de solicita��o � " +;
	//	DtoC( dDTP ) , "ATEN��O" , "INFO" )
	  //	Return( dDTP )
//	EndIf
//	Return( dDTE )
EndIf

If AllTrim( ReadVar() ) == "M->C6_PROMET"
	If dDTP < M->C5_EMISSAO
		MsgBox( "3-Data da solicita��o n�o pode inferior a data de emiss�o do pedido � " +;
		DtoC( M->C5_EMISSAO ) , "ATEN��O" , "INFO" )
		Return( M->C5_EMISSAO )
	EndIf
	If dDTE < dDTP .and. dDTE == dDataBase
		aCols[n,nPosDTE]	:= dDTP
		dDTE				:= aCols[n,nPosDTE]
	EndIf
	If dDTP > dDTE
		MsgBox( "4-Data de solita��o n�o pode superior a data de entrega � " +;
		DtoC( dDTE ) , "ATEN��O" , "INFO" )
		Return( dDTE )
	EndIf
	Return( dDTP )
EndIf
