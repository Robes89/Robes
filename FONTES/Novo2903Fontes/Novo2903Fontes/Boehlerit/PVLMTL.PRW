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
	MsgBox( "Nº de parcelas lançadas superior ao nº de parcelas informadas no cabeçalho !" , "Atenção" , "ALERT" )
	Return( .F. )
ElseIf nSemCheque # 0
	MsgBox( "Tipo de pagamento com cheque e não informado nº do cheque !" , "Atenção" , "ALERT" )
	Return( .F. )
ElseIf nSemNumBco # 0
	MsgBox( "Tipo de pagamento com cheque e não informado nº do banco !" , "Atenção" , "ALERT" )
	Return( .F. )
Else
    Return( .T. )
EndIf
*/

Return( .T. )
