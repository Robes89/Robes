#include "rwmake.ch"

User Function PVLMTL()

/*
nParcelas	:= 0
nSemCheque	:= 0
nSemNumBco	:= 0

For nLinha := 1 To Len(aCols)
	If !aCols[nLinha,_nPosDel]
		nParcelas++
		If AllTrim( aCols[nLinha,2] ) == "CH" .and. Empty( aCols[nLinha,4] )
			nSemCheque++
		EndIf
		If AllTrim( aCols[nLinha,2] ) == "CH" .and. Empty( aCols[nLinha,5] )
			nSemNumBco++
		EndIf
	EndIf                            
Next nLinha

If nParcelas > M->ZD_NUMPARC
	MsgBox( "N� de parcelas lan�adas superior ao n� de parcelas informadas no cabe�alho !" , "Aten��o" , "ALERT" )
	Return( .F. )
ElseIf nSemCheque # 0
	MsgBox( "Tipo de pagamento com cheque e n�o informado n� do cheque !" , "Aten��o" , "ALERT" )
	Return( .F. )
ElseIf nSemNumBco # 0
	MsgBox( "Tipo de pagamento com cheque e n�o informado n� do banco !" , "Aten��o" , "ALERT" )
	Return( .F. )
Else
    Return( .T. )
EndIf
*/

Return( .T. )
