#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³SAFRAAGC   ºAutor  ³smartins	     º Data ³  13/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa para tratar Agencia e Conta com Digito conforme   º±±
±±º          ³ Layout de Cobrança do Banco Safra                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 		                                               	  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function SafraAgc()

Local cRet	:= ""
//Local cBanco:= ""
Local cAgencia:= ""
Local cConta:= ""
Local cDigito:= ""
//	cBanco:= SA6->A6_COD	//Posicao 27 a 29
	cAgencia:=Strzero(Val(SA6->A6_AGENCIA),5)	//Posicao 30 a 34	//Posicao 27 a 31
	cConta:=Strzero(Val(SA6->A6_NUMCON),8)	//Posicao 35 a 39		//Posicao 32 a 39
	cDigito:=Strzero(Val(SA6->A6_DVCTA),1)	//Posicao 40 a 40		//Posicao 40 a 40
    
	cRet:= IIF(SE1->E1_OCORREN$Alltrim("  ,01"),Alltrim(cAgencia)+Alltrim(cConta)+Alltrim(cDigito),Strzero(0,14))

Return(cRet)
