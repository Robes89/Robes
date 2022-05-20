#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
���Programa  � EFINS018   �Autor  � smartins	     � Data �  20/02/2014 ���
�������������������������������������������������������������������������͹��
���Desc.     � Fonte para tratamento do Tipo de Pagamento do Banco SAFRA  ���
���          � Layout 400 Posi��es (140 a 142).                           ���
�������������������������������������������������������������������������͹��
���Uso       �  						          ���
���������������������������������������������������������������������������*/ 

User Function EFINS018()

cRet 	:= ""
cTpPag	:= SEA->EA_MODELO
If cTpPag $ "30/31"
	cRet := "COB"
ElseIf cTpPag == "01"
	cRet := "CC "
ElseIf cTpPag == "03"
	cRet := "DOC"
Else
	cRet := "TED
EndIf 

Return (cRet)
