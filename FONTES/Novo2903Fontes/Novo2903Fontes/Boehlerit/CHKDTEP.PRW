#Include "rwmake.ch"

// Checa se a data de entrega e solicitação (C6_ENTREG e C6_PROMET) é superior a emissão
// do pedido (C5_EMISSAO )
// Wilson - 22/09/05

User Function CHKDTEP()

Local	nPosDTE	:=	aScan( aHeader , { |x| AllTrim( x[2] ) == "C6_ENTREG" } )
Local	dDTE	:= aCols[n,nPosDTE]

Local	nPosDTP	:=	aScan( aHeader , { |x| AllTrim( x[2] ) == "C6_PROMET" } )
Local	dDTP	:= aCols[n,nPosDTP]

If AllTrim( ReadVar() ) == "M->C6_ENTREG"
	If dDTE < M->C5_EMISSAO
		MsgBox( "1-Data de entrega não pode inferior a data de emissão do pedido » " +;
		DtoC( M->C5_EMISSAO ) , "ATENÇÃO" , "INFO" )
		aCols[n,nPosDTE]	:= M->C5_EMISSAO
		dDTE				:= aCols[n,nPosDTE]
	EndIf
//	If dDTE < dDTP
  //		MsgBox( "2-Data de entrega não pode inferior a data de solicitação » " +;
	//	DtoC( dDTP ) , "ATENÇÃO" , "INFO" )
	  //	Return( dDTP )
//	EndIf
//	Return( dDTE )
EndIf

If AllTrim( ReadVar() ) == "M->C6_PROMET"
	If dDTP < M->C5_EMISSAO
		MsgBox( "3-Data da solicitação não pode inferior a data de emissão do pedido » " +;
		DtoC( M->C5_EMISSAO ) , "ATENÇÃO" , "INFO" )
		Return( M->C5_EMISSAO )
	EndIf
	If dDTE < dDTP .and. dDTE == dDataBase
		aCols[n,nPosDTE]	:= dDTP
		dDTE				:= aCols[n,nPosDTE]
	EndIf
	If dDTP > dDTE
		MsgBox( "4-Data de solitação não pode superior a data de entrega » " +;
		DtoC( dDTE ) , "ATENÇÃO" , "INFO" )
		Return( dDTE )
	EndIf
	Return( dDTP )
EndIf
