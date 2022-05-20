#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
���Programa  �EFINS020  �Autor  �Eduardo Augusto     � Data �  14/03/2014 ���
�������������������������������������������������������������������������͹��
���Desc.     � Fonte para tratamento do CNAB a Pagar Safra Fornecedores   ���
���          � Layout 400 Posi��es (248 a 263).                           ���
�������������������������������������������������������������������������͹��
���Uso       � 							          ���
���������������������������������������������������������������������������*/

User Function EFINS020()

Local _cRet := ""
Local _cTpPag := SEA->EA_MODELO 

If _cTpPag $ "30/31"
	_cRet := SUBSTR(SE2->E2_CODBAR,1,3) + STRZERO(0,13)
Else
	_cRet := STRZERO(0,16)
EndIf
Return (_cRet)
