#include "rwmake.ch"    
#INCLUDE "TOPCONN.CH"

User Function atcodcli()  

cQuery := " SELECT  SD2.R_E_C_N_O_ AS RECNO,C6_NUM,D2_PEDIDO, C6_ITEM,D2_ITEMPV,D2_COD, C6_CODCLI "
cQuery += " FROM "+ RetSqlName("SD2") + " SD2, "+ RetSqlName("SC6") + " SC6 "
cQuery += " WHERE SD2.D_E_L_E_T_ <> '*' AND SC6.D_E_L_E_T_ <> '*' "
cQuery += " AND C6_FILIAL = '" + xFilial("SC6") + "' "
cQuery += " AND D2_FILIAL = '" + xFilial("SD2") + "' "
cQuery += " AND D2_PEDIDO = C6_NUM " 
cQuery += " AND D2_ITEMPV = C6_ITEM "
cQuery += " AND C6_CODCLI <> '' "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TD2", .F., .T.)

TcSetField('TD2',"RECNO","N",10,0)

//SC6	1	C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
//SD2	8	D2_FILIAL+D2_PEDIDO+D2_ITEMPV
       
dbSelectArea("TD2")
dbGoTop()
WHILE ! TD2->( EOF() )  
	_cCodCli  := TD2->C6_CODCLI
	_nRecnoC6 := TD2->RECNO
	dbSelectArea("SD2")
	dbSetOrder(0) 
	dbGoTo(_nRecnoC6)
	If TD2->(D2_PEDIDO+D2_ITEMPV) == SD2->(D2_PEDIDO+D2_ITEMPV)
	   RecLock("SD2",.f.)
	   SD2->D2_XCODCLI := _cCodCli
	   SD2->(MsUnLock())
    Endif
    dbSelectArea("TD2")
    TD2->(dbSkip())
ENDDO
dbCloseArea("TD2")

cQuery := " SELECT  SD2.R_E_C_N_O_ AS RECNO,D2_PEDIDO, D2_ITEMPV,D2_COD "
cQuery += " FROM "+ RetSqlName("SD1") + " SD1, "+ RetSqlName("SD2") + " SD2 "
cQuery += " WHERE SD1.D_E_L_E_T_ <> '*'  AND SD2.D_E_L_E_T_ <> '*' "
cQuery += " AND D1_FILIAL = '" + xFilial("SD1") + "' "
cQuery += " AND D2_FILIAL = '" + xFilial("SD2") + "' "
cQuery += " AND D1_FORNECE = D2_CLIENTE " 
cQuery += " AND D1_NFORI = D2_DOC " 
cQuery += " AND D1_ITEMORI = D2_ITEM " 
cQuery += " AND D1_XCODCLI = ' ' " 
cQuery += " AND D1_TIPO = 'D' " 

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TD1", .F., .T.)

TcSetField('TD1',"RECNO","N",10,0)

//SC6	1	C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
//SD2	8	D2_FILIAL+D2_PEDIDO+D2_ITEMPV
       
dbSelectArea("TD1")
dbGoTop()
WHILE ! TD1->( EOF() )  
	
	//_cCodCli  := TD2->C6_CODCLI
	_nRecnoD1 := TD1->RECNO
	dbSelectArea("SC6")
	dbSetOrder(1) 
	dbSeek(xFilial("SC6")+TD1->(D2_PEDIDO+D2_ITEMPV))
	If SC6->(C6_NUM+C6_ITEM) == TD1->(D2_PEDIDO+D2_ITEMPV)
	   _cCodCli := SC6->C6_CODCLI
	   dbSelectArea("SD1")
	   dbSetOrder(0)
	   dbGoTo(_nRecnoD1)
	   If Empty(SD1->D1_XCODCLI) .and. !Empty(_cCodCli)
	      RecLock("SD1",.f.)
	      SD1->D1_XCODCLI := _cCodCli
	      SD1->(MsUnLock())
	   Endif   
    Endif
    dbSelectArea("TD1")
    TD1->(dbSkip())
ENDDO
dbCloseArea("TD1")

Return
