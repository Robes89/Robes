#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
���Programa  �EFINS021  �Autor  �smartins 	     � Data �  02/07/2012 ���
�������������������������������������������������������������������������͹��
���Desc.     � Customiza��o para tratamento do Cnab SAFRAPAG das Posi��es ���
���          � 156 a 165. (Agencia e Conta com Digito).                   ���
�������������������������������������������������������������������������͹��
���Uso       � 						                  ���
���������������������������������������������������������������������������*/

User Function EFINS021()
Local cConta := ""
If AllTrim(SA2->A2_BANCO) $ "399"	// Banco HSBC
	cConta := Strzero(Val(SA2->A2_NUMCON),8)	// 156 a 163
	cConta += AllTrim(SA2->A2_DVCTA)			// 164 a 165
Else	// Outros Bancos
	cConta := Strzero(Val(SA2->A2_NUMCON),9)	// 156 a 164
	cConta += Right(Trim(SA2->A2_DVCTA),1)		// 165 a 165
EndIf
Return cConta