#INCLUDE "PROTHEUS.CH"
/*
NOMEç M460FIM
ROTINA PARA GRAVAR O CAMPO F1_XPEDIDO
BY LEANDRO DUARTE

*/
User Function M460FIM()
    Local cQuery:= ""
    Local cNumNF:= SF2->F2_DOC


    cQuery := " 		SELECT C5_NUM "
    cQuery += " 			FROM "+RetSqlName("SC5")+" SC5 "
    cQuery += " 			WHERE SC5.C5_NOTA = '"+cNumNF+"' "
    cQuery += "             AND SC5.D_E_L_E_T_ = ' ' "
    cQuery += "             AND SC5.C5_CLIENTE = '"+SF2->F2_CLIENTE+"' "
    cQuery += "             AND SC5.C5_FILIAL = '"+xFilial("SC5")+"' "
	
    cQuery := ChangeQuery(cQuery)
	
    If Select("TRBTMP") > 0
        dbSelectArea("TRBTMP")
        dbCloseArea()
    Endif
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTMP",.T.,.F.)
	
	
    RecLock("SF2")
    Replace SF2->F2_XPEDIDO with TRBTMP->C5_NUM
    SF2->(MsUnlock( ))

RETURN()
