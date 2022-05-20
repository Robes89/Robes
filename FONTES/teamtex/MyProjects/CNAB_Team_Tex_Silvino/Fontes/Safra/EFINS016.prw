#Include "Protheus.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ EFINS016 ºAutor  ³ smartins	    º Data ³  19/02/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Fonte para tratamento do Detalhe dos Boletos a Pagar.      º±±
±±º          ³ Banco SAFRA Posições 294 a 347 - Codigo de Barras.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 						                  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function EFINS016()

Local cModel	:= SEA->EA_MODELO
Local cRet	:= "" 
Local cSpace	:= SPACE(10)
If  cModel $ "30/31"
	cRet := cSpace + SUBSTR(SE2->E2_CODBAR,1,3)	// Banco
	cRet += SUBSTR(SE2->E2_CODBAR,4,1)			// Moeda
	cRet += SUBSTR(SE2->E2_CODBAR,5,1)			// Digito Veirificador Centralizador do Codigo de Barras
	cRet += SUBSTR(SE2->E2_CODBAR,6,14)		// Fator de Vencimento + Valor do Titulo
	cRet += SUBSTR(SE2->E2_CODBAR,20,25)		// Campo Livre
Else 
    cRet := SPACE(54)
EndIf

Return  (cRet)
