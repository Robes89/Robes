
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ ��
���Programa  �TTESTR03  �Autor  �TRIYO                                                   � Data �  15/08/19     ���
�������������������������������������������������������������������������͹   ��
���Desc.     �Impressao etiqueta Pallet        �					                                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


User Function TTESTR03()

Local cPerg		:= "TTESTR03"
Local lContinua := .F.

//AjustSX1()

lContinua := Pergunte(cPerg,.t.)

If Empty(MV_PAR03)
	MsgAlert("Informe um local de impressao valido")
EndIf

If !CB5SetImp(MV_PAR03)  
	MsgAlert("Local de Impress�o "+MV_PAR05+" nao Encontrado!") 
	Return
Endif	

If lContinua
	ImpEti01()
	MSCBCLOSEPRINTER()             
EndIf

Return
//////////////////////////////////////////
//Rotina de impressao de etiqueta      //
/////////////////////////////////////////
Static Function ImpEti01()

Local cQuery	:= ""
Local cAliasNew	:= GetNextAlias()
Local cTipoBar	:= 'MB04' //EAN13
Local cCodBar	:= ''
Local sConteudo	:= ""

Private ENTERL     := CHR(13)+CHR(10)

//+-----------------------
//| Cria filtro temporario
//+-----------------------


BeginSql Alias cAliasNew

	SELECT CB0_CODETI, CB0_LOCAL,CB0_LOCALI
	FROM %table:CB0% CB0 
	WHERE CB0.CB0_FILIAL=%xFilial:CB0%
	AND CB0_CODETI BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%
	AND CB0_TIPO='05'
	AND %notdel% 
 
EndSql

(cAliasNew)->(dbGoTop())

While (cAliasNew)->(!Eof())

	MSCBBEGIN(1,6,70) //Inicio da Imagem da Etiqueta
	//MSCBLineV(01,01,32,300)
	MSCBSAYBAR(025,020,(cAliasNew)->CB0_CODETI,"N",'MB07',25,.F.,.T.,.F.,,20,3,.F.,.F.,"1",.T.)
	//MSCBSAY(07,015,'PALLET: '+(cAliasNew)->CB0_CODETI,"N","4","032,035",.T.)		
	MSCBInfoEti("Produto","30X70")

	MSCBEND()	
	(cAliasNew)->(dbSkip())
	sConteudo:=MSCBEND()
		
EndDo 

(cAliasNew)->(DbCloseArea())

If Empty(sConteudo)
	MsgAlert("Sem Dados para Impress�o! Verifique os Parametros!!!","A T E N � � O!!!")
	Return
Else
	Return sConteudo
EndIf

	

	