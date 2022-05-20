#Include "Protheus.ch"

/*���������������������������������������������������������������������������
���Programa  � EFINS016 �Autor  � smartins	    � Data �  19/02/2014 ���
�������������������������������������������������������������������������͹��
���Desc.     � Fonte para tratamento do Detalhe dos Boletos a Pagar.      ���
���          � Banco SAFRA Posi��es 294 a 347 - Codigo de Barras.         ���
�������������������������������������������������������������������������͹��
���Uso       � 						                  ���
���������������������������������������������������������������������������*/

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
