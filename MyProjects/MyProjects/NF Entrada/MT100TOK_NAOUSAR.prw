/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � MT100TOK � Autor � Afonso Brito          Data � 20/08/2019 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida a Inclus�o da NF de Entrada                         ���
���		     �                       						   		  	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TEAM TEX                                     		      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function MT100TOK()
     
Local aArea := GetArea()  
Local lRet  := .T.

IF LEN(ALLTRIM(CNFISCAL)) <> 9
   MSGALERT("O numero da Nota Fiscal deve conter 9 caracteres","Aten��o")
   lRet := .F.
ENDIF
   
RestArea(aArea)
         
Return lRet