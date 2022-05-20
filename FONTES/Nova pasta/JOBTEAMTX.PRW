#include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³JobTeamTx   ³ Autor ³Leandro da Silva Duarte³ Data ³21/02/2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Rotina de job para alimentar os campos de E2_CGC, E2_RAZAO    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Protheus 12                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function JobTeamTx()
    Local aTab      := {"SA1","SA2","SE1","SE2"}
    Local cEmp      := '01'
    Local cFil      := '01'
    Local cQuery    := ""

    RPCSetType(3)
    RpcSetEnv(cEmp,cFil,,,'FIN','alimentando E2_CGC e E2_RAZAO',aTab)

    SE2->(DbSetOrder(1))
    SA2->(DbSetOrder(1))
    While .t.
        cQuery := " SELECT A.R_E_C_N_O_ AS REC FROM "+RETSQLNAME("SE2")+" A WHERE A.D_E_L_E_T_ = ' ' AND (E2_CGC = '  ' OR E2_RAZAO = '   ')"
        iif(select("TRB")>0,TRB->(DBCLOSEAREA()),NIL)
        DBUseArea( .T., "TOPCONN", TCGenQry( ,,cQuery ), "TRB", .F., .T. )
        WHILE TRB->(!EOF())
            SE2->(DBGOTO(TRB->REC))
            RECLOCK("SE2",.F.)
            SE2->E2_CGC := POSICIONE("SA2",1,XFILIAL("SA2")+SE2->E2_FORNECE,"A2_CGC")
            SE2->E2_RAZAO := POSICIONE("SA2",1,XFILIAL("SA2")+SE2->E2_FORNECE,"ALLTRIM(A2_NOME)")
            MSUNLOCK()
            TRB->(DBSKIP())
            CONOUT('ATUALIZACAO DO TITULO COM O CGC E A RAZAO DO CLIENTE - JobTeamTx')
        END
    end
    
    RpcClearEnv()
Return()