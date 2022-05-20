#Include "Protheus.ch"

/*
Padrao Zebra
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IMG02     �Autor  �Sandro Valex        � Data �  19/06/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada referente a imagem de identificacao da     ���
���          �endereco                                                    ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function Img02 // imagem de etiqueta de ENDERECO
Local cCodigo
Local cCodID := paramixb[1]
If cCodID # NIL
	cCodigo := cCodID
ElseIf Empty(SBE->BE_IDETIQ)
	If Usacb0('02')

		cCodigo := CBGrvEti('02',{SBE->BE_LOCALIZ,SBE->BE_LOCAL})
		RecLock("SBE",.F.)
		SBE->BE_IDETIQ := cCodigo
		MsUnlock()
	Else
		cCodigo :=SBE->(BE_LOCAL+BE_LOCALIZ)
	EndIf
Else
	If Usacb0('02')
		cCodigo := SBE->BE_IDETIQ
	Else
		cCodigo :=SBE->(BE_LOCAL+BE_LOCALIZ)
	EndIf
Endif
cCodigo := Alltrim(cCodigo)
//MSCBLOADGRF("SIGA.GRF")
MSCBBEGIN(1,6)
//MSCBBOX(30,05,76,05)
//MSCBBOX(02,12.7,76,12.7)
//MSCBBOX(02,21,76,21)
//MSCBBOX(30,01,30,12.7,3)
//MSCBGRAFIC(2,3,"SIGA")
//MSCBSAY(45,50,"CODIGO","N","0","012,008")
MSCBSAY(20,45, 'Endereco: '+AllTrim(SBE->BE_LOCALIZ), "N", "6", "055,058")
//MSCBSAY(10,14,"DESCRICAO","N","0","012,008")
//MSCBSAY(10,25,SBE->BE_DESCRIC,"N", "0", "020,030")
MSCBSAYBAR(025,20,cCodigo,"N","MB07",12.15,.F.,.T.,.F.,,2,3,.F.,.F.,"1",.T.)
MSCBInfoEti("Endereco","30X100")
MSCBEND()

Return .F.
