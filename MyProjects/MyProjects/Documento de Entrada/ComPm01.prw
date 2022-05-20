#include "Protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �COMPM01   �Autor  �Henio Brasil        � Data �  05/11/2019 ���
�������������������������������������������������������������������������͹��
���Descricao �Chamada da rotina pelo Pto Entrada GQREENTR para nao afetar ���
���          �o conteudo ja presente no programa existente.               ���
���          �Atualizacao de Dados originados na Nota Fiscal de Entrada   ���
���          �para compor dados o titulo no Contas a Pagar                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Direitos  �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/

User Function COMPM01(cTesEnt) 

Local aAreaNF	:= GetArea()
Local cKeyFis	:= SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)  	 
// Local cKeyFis	:= SD1->(xFilial("SD1")+'E'+D1_SERIE+D1_DOC+D1_FORNECE+D1_LOJA)  	 
Local lRegEsp 	:=(Posicione("SF4", 1, xFilial("SF4")+cTesEnt,"F4_XREGESP")=='1') 

/* 
���������������������������������������������������������������������Ŀ
�Valida se foi efetuado o Rateio ou Nao, verificar pela Natureza      �
�����������������������������������������������������������������������*/                                                
lRegEsp := .T. 
If lRegEsp 
	/*  
	���������������������������������������������������������������������Ŀ
	�Posiciona no 1o item da Nota Fiscal                                  �
	�����������������������������������������������������������������������*/ 
	DbSelectArea("SD1") 
	SD1->(DbSetOrder(1))
	SD1->(DbSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)) )
	/*  
	���������������������������������������������������������������������Ŀ
	�Posiciona no Livro Fiscal atualizar valores desonerados de Icms      �
	�����������������������������������������������������������������������*/ 
	// (2) CD2_FILIAL+CD2_TPMOV+CD2_SERIE+CD2_DOC+CD2_CODFOR+CD2_LOJFOR+CD2_ITEM+CD2_CODPRO+CD2_IMP 
	While SD1->(!Eof()) .And. SD1->(xFilial("SD1")+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == cKeyFis   
	
		DbSelectArea("CD2") 
		CD2->(DbSetOrder(2))
		If CD2->( DbSeek(xFilial("CD2")+'E'+SD1->(D1_SERIE+D1_DOC+D1_FORNECE+D1_LOJA+D1_ITEM+D1_COD+'ICM')) ) 	
			MsgAlert("SF1100i - posicao itens no SD1 =  "+SD1->(D1_SERIE+' '+D1_DOC+' '+D1_FORNECE+' '+D1_LOJA+' '+D1_ITEM+' '+D1_COD) )
			RecLock("CD2",.F.)
			CD2->CD2_DESONE:= SD1->D1_XVDIFRE
			CD2->(MsUnLock())
		EndIf
		SD1->(DbSkip())		
	Enddo
EndIf
RestArea(aAreaNF)
Return
