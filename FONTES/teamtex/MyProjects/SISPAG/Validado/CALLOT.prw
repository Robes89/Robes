#Include "rwmake.ch" 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CALLOT   �Autor  �Thiago Menegocci     � Data �  06/06/19   ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna calculo do sequencial do lote                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function CALLOT()

Private nNumLot
    	
	If nSeq > 1
		nNumLot	:= StrZero(nSeq+1,5)
		nSeq++  
    Else                           
    	nNumLot	:= StrZero(nSeq,5)
    	nSeq++  
    EndIf
    
Return(nNumLot)                                    