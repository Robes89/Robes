#include "Protheus.Ch"

/*
Programa  : MT100TOK
Autor     : Junior Bordin
Data      : 10/03/2015
Uso       : Protheus 11.5 SQL
Descri???o : Fun??o que preenche com zeros a esquerda o numero das Notas
            Fiscais de Entrada para completar as posi??es de acordo
            com o tamanho do campo SF1->F1_DOC
*/

User Function MT100TOK()
************************

Local lRet	:= .T.
Local nTamDoc	:= Len(SF1->F1_DOC)
Local cNumNF  	:= CNFISCAL

cNumNF		:= Strzero( Val( cNumNF ), nTamDoc)
CNFISCAL	:= cNumNF 
	
Return( lRet )
