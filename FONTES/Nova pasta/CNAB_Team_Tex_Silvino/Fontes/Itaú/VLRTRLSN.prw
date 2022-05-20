#Include "RwMake.ch"
#Include "TopConn.ch"
  

/*���������������������������������������������������������������������������
���Programa  �TOTPAG2   �Autor  �smartins           � Data �  08/27/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Programa para tratamento do Valor do Tributo.			  ���
�������������������������������������������������������������������������͹��
���Uso       � Fortnort	                                                  ���
���������������������������������������������������������������������������*/

User Function VLRTRLSN() 

	Local _Area 	:= GetArea()
	Local _ValTrib	:= 0
	Local _ValInss	:= 0
	Local nSoma		:= Strzero(nSomaValor*100,14)
	Local cQuery	:= ""
	
	// Tratamento da Query
	If Select("TMP") > 0
		TMP->( DbCloseArea() )
	EndIf
	cQuery := " SELECT SUM(E2_XVLINSS) VLRINSS FROM " + RetSqlName("SE2") + " SE2 "
	cQuery += " INNER JOIN " + RetSqlName("SEA") + " SEA " 
	cQuery += " 	ON EA_FILIAL = E2_FILIAL AND EA_NUMBOR = E2_NUMBOR AND EA_NUM = E2_NUM AND EA_PARCELA = E2_PARCELA AND SEA.D_E_L_E_T_ = ' ' " 
	cQuery += " WHERE SE2.D_E_L_E_T_ = ' ' "
	cQuery += " AND E2_NUMBOR = EA_NUMBOR "
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMP", .F., .T.)

	_ValInss := TMP->VLRINSS
	
	If _ValInss > 0
		_ValTrib := Str(_ValInss)                                                                     	
		_ValTrib := Strzero(_ValInss*100,14)
	Else
		_ValTrib := nSoma
	EndIf

	RestArea(_Area)

Return(_ValTrib) 
