
/*
Padrao Zebra
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IMG00     �Autor  �Sandro Valex        � Data �  19/06/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada referente a imagem de rosto.               ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function l
If paramixb[1] =='ACDI10PR' .or. paramixb[1] =='ACDI10CX' .or. paramixb[1] =='ACDI10DE'
	MSCBBEGIN(1,6) //Inicio da Imagem da Etiqueta
	MSCBBOX(00,00,76,40,200)
	MSCBSAY(05,12,'PRODUTO DE :'+mv_par01,"N","0","025,035",.T.)
	MSCBSAY(05,16,Posicione('SB1',1,xFilial("SB1")+mv_par01,"B1_DESC"),"N","0","025,035",.T.)
	MSCBSAY(05,20,'PRODUTO ATE:'+mv_par02,"N","0","025,035",.T.)
	MSCBSAY(05,24,Posicione('SB1',1,xFilial("SB1")+mv_par02,"B1_DESC"),"N","0","025,035",.T.)
	MSCBEND()
ElseIf paramixb[1] =='ACDI070'
	MSCBBEGIN(1,6) //Inicio da Imagem da Etiqueta
	MSCBBOX(00,00,76,40,200)
	MSCBSAY(05,12,'RECURSO DE :'+mv_par01,"N","0","025,035",.T.)
	MSCBSAY(05,16,Posicione('SH1',1,xFilial("SH1")+mv_par01,"H1_DESCRI"),"N","0","025,035",.T.)
	MSCBSAY(05,20,'RECURSO ATE:'+mv_par02,"N","0","025,035",.T.)
	MSCBSAY(05,24,Posicione('SH1',1,xFilial("SH1")+mv_par02,"H1_DESCRI"),"N","0","025,035",.T.)
	MSCBEND()
ElseIf paramixb[1] =='ACDI080'
	MSCBBEGIN(1,6) //Inicio da Imagem da Etiqueta
	MSCBBOX(00,00,76,40,200)
	MSCBSAY(05,12,'TRANSACAO DE :'+mv_par01,"N","0","025,035",.T.)
	MSCBSAY(05,16,Posicione('CBI',1,xFilial("CBI")+mv_par01,"CBI_DESCRI"),"N","0","025,035",.T.)
	MSCBSAY(05,20,'TRANSACAO ATE:'+mv_par02,"N","0","025,035",.T.)
	MSCBSAY(05,24,Posicione('CBI',1,xFilial("CBI")+mv_par02,"CBI_DESCRI"),"N","0","025,035",.T.)
	MSCBEND()
ElseIf paramixb[1] =='ACDV210' .or. paramixb[1] =='ACDV220'
	MSCBBEGIN(1,6) //Inicio da Imagem da Etiqueta
	MSCBBOX(00,00,76,40,200)
	MSCBSAY(05,12,'PRODUTO DE :'+CB0->CB0_CODPRO,"N","0","025,035",.T.)
	MSCBSAY(05,16,Posicione('SB1',1,xFilial("SB1")+CB0->CB0_CODPRO,"B1_DESC"),"N","0","025,035",.T.)
	MSCBSAY(05,20,'PRODUTO ATE:'+CB0->CB0_CODPRO,"N","0","025,035",.T.)
	MSCBSAY(05,24,Posicione('SB1',1,xFilial("SB1")+CB0->CB0_CODPRO,"B1_DESC"),"N","0","025,035",.T.)
	MSCBEND()
ElseIf paramixb[1] =='RACDI10PR' .OR. paramixb[1] =='RACDI10CX' 
	MSCBBEGIN(1,6) //Inicio da Imagem da Etiqueta
	MSCBBOX(00,00,76,40,200)
	MSCBSAY(05,04,'RE-IMPRESSAO DE ETIQUETA',"N","0","025,035",.T.)
	MSCBSAY(05,10,'PRODUTO : '+CB0->CB0_CODPRO,"N","0","025,035",.T.)
	MSCBSAY(05,14,Posicione('SB1',1,xFilial("SB1")+CB0->CB0_CODPRO,"B1_DESC"),"N","0","025,035",.T.)
	MSCBSAY(05,18,'DESCRICAO DA BARRA: ',"N","0","025,035",.T.)
	MSCBSAY(05,26,CB0->CB0_CODETI,"N","0","025,035",.T.)
	MSCBEND()
ElseIf paramixb[1] =='ACDI10PD'.OR. paramixb[1] =='ACDV125'
	MSCBBEGIN(1,6) //Inicio da Imagem da Etiqueta
	MSCBBOX(00,00,76,40,200)
	MSCBSAY(05,12,'PEDIDO :'+paramixb[2],"N","0","025,035",.T.)
	MSCBSAY(05,16,'FORNECEDOR:'+paramixb[3],"N","0","025,035",.T.)
	MSCBSAY(05,20,Posicione('SA2',1,xFilial("SA2")+paramixb[3]+paramixb[4],"A2_NREDUZ"),"N","0","025,035",.T.)
	MSCBEND()
ElseIf paramixb[1] =='ACDI10NF' // identificacao de produto
	MSCBBEGIN(1,6) //Inicio da Imagem da Etiqueta
	MSCBBOX(00,00,76,40,200)
	MSCBSAY(08,20,'NOTA :'+SF1->F1_DOC+' '+SF1->&(SerieNfId("SF1",3,"F1_SERIE")),"N","2","01,01",.T.)
	MSCBSAY(05,16,'FORNECEDOR:'+SF1->F1_FORNECE,"N","0","025,035",.T.)
	MSCBSAY(05,20,Posicione('SA2',1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_NREDUZ"),"N","0","025,035",.T.)
	MSCBEND()
ELSEIf paramixb[1] =='ACDI10OP' .OR. paramixb[1] =='ACDV025'
	MSCBBEGIN(1,6) //Inicio da Imagem da Etiqueta
	MSCBSAY(05,12,'PRODUTO  :'+SD3->D3_COD,"N","0","025,035",.T.)
	MSCBSAY(05,16,Posicione('SB1',1,xFilial("SB1")+SD3->D3_COD,"B1_DESC"),"N","0","025,035",.T.)
	MSCBSAY(05,20,'DOCUMENTO:'+SD3->D3_DOC,"N","0","025,035",.T.)
	MSCBSAYBAR(23,24,SD3->D3_DOC,"N",'C',8.36,.F.,.T.,.F.,,2,1,.F.,.F.,"1",.T.)
	MSCBEND()
ELSEIf paramixb[1] =='ACDV040' 
	If Posicione('SF5',1,xFilial("SF5")+paramixb[2],"F5_TIPO")=="R"
	   MSCBBEGIN(1,6) //Inicio da Imagem da Etiqueta
	   MSCBLineV(01,01,32,300)
	   MSCBSAY(05,12,'REQUISICAO:',"N","0","025,035",.T.)
	   If ! Empty(paramixb[3])
	      MSCBSAY(05,18,'O.P: '+paramixb[3],"N","0","025,035",.T.)
	   Endif		   		   
	   MSCBEND()
	Else
	   MSCBBEGIN(1,6) //Inicio da Imagem da Etiqueta
	   MSCBLineV(01,01,32,300)
	   MSCBSAY(05,12,'DEVOLUCAO:',"N","0","025,035",.T.)
	   MSCBEND()
	Endif   
ELSEIf paramixb[1] =='ACDV170' 	
   MSCBBEGIN(1,6) //Inicio da Imagem da Etiqueta
	MSCBLineV(01,01,32,300)
	MSCBSAY(05,12,'EXPEDICAO:',"N","0","025,035",.T.)
	If ! Empty(paramixb[2])
	   MSCBSAY(05,18,'ORDEM DE SEP: '+paramixb[2],"N","0","025,035",.T.)
	Endif		   		   
	MSCBEND()
ELSEIf paramixb[1] =='ACDV230'
	
	MSCBBEGIN(1,6) //Inicio da Imagem da Etiqueta
	//MSCBLineV(01,01,32,300)
	MSCBSAY(05,18,'PALLET: '+paramixb[2],"N","2","032,035",.T.)		
	
ElseIf paramixb[1] =='ACDI020LO'  // endereco
	MSCBBEGIN(1,6) //Inicio da Imagem da Etiqueta
	MSCBBOX(00,00,76,40,200)
	MSCBSAY(05,12,'Almox de :'+mv_par01,"N","0","025,035",.T.)
	MSCBSAY(05,16,'Almox ate:'+mv_par02,"N","0","025,035",.T.)
	MSCBSAY(05,20,'Endereco de :'+mv_par03,"N","0","025,035",.T.)
	MSCBSAY(05,24,'Endereco ate:'+mv_par04,"N","0","025,035",.T.)
	MSCBEND()
ElseIf paramixb[1] =='RACDI020LO'  // endereco
	MSCBBEGIN(1,6) //Inicio da Imagem da Etiqueta
	MSCBBOX(00,00,76,40,200)
	MSCBSAY(05,04,'RE-IMPRESSAO DE ETIQUETA',"N","0","025,035",.T.)
	MSCBSAY(05,10,'ENDERECO : '+CB0->CB0_LOCALI,"N","0","025,035",.T.)
	MSCBSAY(05,18,'DESCRICAO DA BARRA: ',"N","0","025,035",.T.)
	MSCBSAY(05,26,CB0->CB0_CODETI,"N","0","025,035",.T.)
	MSCBEND()
ElseIf paramixb[1] == 'ACDI030DM'  // dispositivo de movimentacao
	MSCBBEGIN(1,6) //Inicio da Imagem da Etiqueta
	MSCBBOX(00,00,76,40,200)
	MSCBSAY(05,12,'Dispositivo de :'+paramixb[2],"N","0","025,035",.T.)
	MSCBSAY(05,20,'Dispositivo ate:'+paramixb[3],"N","0","025,035",.T.)
	MSCBEND()
ElseIf paramixb[1] == 'RACDI030DM'  // dispositivo de movimentacao
	MSCBBEGIN(1,6) //Inicio da Imagem da Etiqueta
	MSCBBOX(00,00,76,40,200)
	MSCBSAY(05,04,'RE-IMPRESSAO DE ETIQUETA',"N","0","025,035",.T.)
	MSCBSAY(05,10,'DISPOSITIVO MOV.: '+CB0->CB0_DISPID,"N","0","025,035",.T.)
	MSCBSAY(05,18,'DESCRICAO DA BARRA: ',"N","0","025,035",.T.)
	MSCBSAY(05,26,CB0->CB0_CODETI,"N","0","025,035",.T.)
	MSCBEND()
ElseIf paramixb[1] == 'ACDI050TR' // transportadora
	MSCBBEGIN(1,6) //Inicio da Imagem da Etiqueta
	MSCBBOX(00,00,76,40,200)
	MSCBSAY(05,12,'Transportadora de :'+paramixb[2],"N","0","025,035",.T.)
	MSCBSAY(05,16,Posicione('SA4',1,xFilial("SA4")+paramixb[2],"A4_NOME"),"N","0","025,035",.T.)
	MSCBSAY(05,20,'Transportadora ate:'+paramixb[3],"N","0","025,035",.T.)
	MSCBSAY(05,24,Posicione('SA4',1,xFilial("SA4")+paramixb[3],"A4_NOME"),"N","0","025,035",.T.)
	MSCBEND()
ElseIf paramixb[1] == 'RACDI050TR' // transportadora
	MSCBBEGIN(1,6) //Inicio da Imagem da Etiqueta
	MSCBBOX(00,00,76,40,200)
	MSCBSAY(05,04,'RE-IMPRESSAO DE ETIQUETA',"N","0","025,035",.T.)
	MSCBSAY(05,10,'TRANSPORTADORA: '+CB0->CB0_TRANSP,"N","0","025,035",.T.)
	MSCBSAY(05,14,Posicione('SA4',1,xFilial("SA4")+CB0->CB0_TRANSP,"A4_NOME"),"N","0","025,035",.T.)
	MSCBSAY(05,18,'DESCRICAO DA BARRA: ',"N","0","025,035",.T.)
	MSCBSAY(05,26,CB0->CB0_CODETI,"N","0","025,035",.T.)
	MSCBEND()
ElseIf paramixb[1] == 'ACDI060US' // OPERADOR (USUARIO)
	MSCBBEGIN(1,6) //Inicio da Imagem da Etiqueta
	MSCBBOX(00,00,76,40,200)
	MSCBSAY(05,12,'Operador de :'+paramixb[2],"N","0","025,035",.T.)
	MSCBSAY(05,16,Posicione('CB1',1,xFilial("CB1")+paramixb[2],"CB1_NOME"),"N","0","025,035",.T.)
	MSCBSAY(05,20,'Operador ate:'+paramixb[3],"N","0","025,035",.T.)
	MSCBSAY(05,24,Posicione('CB1',1,xFilial("CB1")+paramixb[3],"CB1_NOME"),"N","0","025,035",.T.)
	MSCBEND()
ElseIf paramixb[1] == 'RACDI060US' // transportadora
	MSCBBEGIN(1,6) //Inicio da Imagem da Etiqueta
	MSCBBOX(00,00,76,40,200)
	MSCBSAY(05,04,'RE-IMPRESSAO DE ETIQUETA',"N","0","025,035",.T.)
	MSCBSAY(05,10,'Operador: '+CB0->CB0_USUARI,"N","0","025,035",.T.)
	MSCBSAY(05,14,Posicione('CB1',1,xFilial("CB1")+CB0->CB0_USUARI,"CB1_NOME"),"N","0","025,035",.T.)
	MSCBSAY(05,18,'DESCRICAO DA BARRA: ',"N","0","025,035",.T.)
	MSCBSAY(05,26,CB0->CB0_CODETI,"N","0","025,035",.T.)
	MSCBEND()
EndIf


Return .t.