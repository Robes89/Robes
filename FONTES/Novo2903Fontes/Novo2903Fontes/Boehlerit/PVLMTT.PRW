#include "rwmake.ch"

User Function PVLMTT()

/*
nSoma	:= 0

For nLinha := 1 To Len(aCols)
	If nLinha <= LEN(aCols)
		If !aCols[nLinha,_nPosDel]
			nSoma	+= aCols[nLinha,3]
		EndIf                            
	EndIf
Next nLinha

If Str( nSoma , 15 , 2 ) # Str( M->ZD_VALOR , 15 , 2 )
	MsgBox( "Total lan�ado (" + AllTrim( Str( nSoma , 15 , 2 ) ) + ") n�o confere com total do valor corrigido (" +;
	AllTrim( Str( M->ZD_VALOR , 15 , 2 ) ) + ")" , "Aten��o" , "ALERT" )
	Return( .F. )
Else
    Return( .T. )
EndIf
*/

Return( .T. )