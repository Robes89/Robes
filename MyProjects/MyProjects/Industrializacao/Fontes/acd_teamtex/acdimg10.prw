/*
Padrao Zebra
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IMG10     �Autor  �Anderson Rodrigues  � Data �  25/02/03   ���
�������������������������������������������������������������������������͹��
���Descricao �Ponto de entrada referente a imagem de identificacao do     ���
���          �Pallet                                                      ���
�������������������������������������������������������������������������͹��
���Uso       �AP6                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function IMG10  // imagem do Pallet
cCodigo:= Paramixb[1] // Codigo da etiqueta do Pallet

//MSCBLOADGRF("SIGA.GRF")
MSCBBEGIN(1,6)
//MSCBBOX(30,05,76,05)
//MSCBBOX(02,12.7,76,12.7)
//MSCBBOX(02,21,76,21)
//MSCBBOX(30,01,30,12.7,3)
//MSCBGRAFIC(2,3,"SIGA")

MSCBSAY(33,02,'PALLET: ',"N","0","050,035",,,,,.t.)
//MSCBSAY(33,15,"CODIGO","N","A","032,0358")
//MSCBSAY(33,15, cCodigo, "N", "0", "032,035")	
//MSCBSAYBAR(23,22,cCodigo,"N","MB07",8.36,.F.,.T.,.F.,,2,1,.F.,.F.,"1",.T.)
MSCBSAYBAR(25,30,cCodigo,"N",'MB07',12.15,.F.,.T.,.F.,,2,3,.F.,.F.,"1",.T.)
MSCBInfoEti("Pallet","30X100")
MSCBEND()
Return .F.

