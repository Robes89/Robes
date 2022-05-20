#include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GQREENTR    ³ Autor ³Leandro da Silva Duarte³ Data ³14/02/2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ROTINA PARA ENDERECAR OS PRODUTOS ACABADOS DE DEVOLUCAO TES017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Protheus 12                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function GQREENTR()
    if (INCLUI .or. ALTERA) .AND. SF1->F1_TIPO = 'D' .and. SF1->F1_FILIAL = '01'
        SD1->(dbSetOrder(1))
        IF SD1->(DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
            WHILE xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == xFilial("SD1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
                IF SD1->D1_TES = '017' // tes de devolução
                    MsgRun( "Endereçando os produtos especificos do Armazem 01 e Filial 01","Favor Aguardar.....",{|| xendere() })
                ENDIF
            END
        ENDIF
    endif
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³XENDERE     ³ Autor ³Leandro da Silva Duarte³ Data ³14/02/2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³enderecando o produto                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Protheus 12                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function xendere()
    Local   nCount  := 0
    Private lMsErroAuto := .F.
    //Private lAutoErrNoFile  := .T.
    Private aCabSDA := {}
    Private aItSDB := {}
    
    
    cAlias := getNextAlias()
    BeginSql Alias cAlias
        SELECT R_E_C_N_O_ as REC
        FROM  %TABLE:SDA% SDA (NOLOCK)
        WHERE SDA.DA_FILIAL = %EXP:XfILIAL("SDA")%
        AND SDA.%NOTDEL%
        AND SDA.DA_LOCAL = %EXP:SD1->D1_LOCAL%
        AND SDA.DA_PRODUTO = %EXP:SD1->D1_COD%
        AND SDA.DA_DOC = %EXP:SD1->D1_DOC%
        AND SDA.DA_SERIE = %EXP:SD1->D1_SERIE%
    EndSQl
    
    (cAlias)->( dbEval( {|| nCount++ }))
    (cAlias)->(dbGoTop())

    if nCount != 0
        
        dbSelectArea("SDA")
        SDA->(dbSetOrder(1))
        while (cAlias)->(!EOF())
        
            SDA->(dbGoTo((cAlias)->REC))
            aCabSDA := {}
            aAdd( aCabSDA, {"DA_PRODUTO" ,SDA->DA_PRODUTO, Nil} )
            aAdd( aCabSDA, {"DA_NUMSEQ" ,SDA->DA_NUMSEQ , Nil} )

            aItSDB := {}
            cItem := BusqDbIT(SDA->DA_PRODUTO,SDA->DA_NUMSEQ)
            aAdd( aItSDB, {"DB_FILIAL" , xFilial("SDB") , Nil} )
            aAdd( aItSDB, {"DB_ITEM" ,  soma1(cItem), Nil} )
            aAdd( aItSDB, {"DB_LOCALIZ", 'END01', Nil} )
            aAdd( aItSDB, {"DB_DATA" , DATE() , Nil} )
            aAdd( aItSDB, {"DB_QUANT" , SDA->DA_SALDO , Nil} )
            aAdd( aItSDB, {"DB_LOCAL", SDA->DA_LOCAL , Nil} )
                
            aItensSDB := {}
            aadd( aItensSDB, aitSDB )
            MSExecAuto({|x,y,z| MATA265(x,y,z)},aCabSDA, aItensSDB, 3)//inclus
                //MATA265(aCabSDA, aItensSDB, 3)//inclus 
                
            If lMsErroAuto
                MostraErro()
            EndIf
            (cAlias)->(DBSKIP())
        END
    ENDIF

Return
            /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³BusqDbIT    ³ Autor ³Leandro da Silva Duarte³ Data ³14/02/2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Rotina para pegar o ultimo item da SDB                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Protheus 12                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function BusqDbIT(cProd,cDoc)
    Local cRet      := "0000"
    Local cQuery    := "SELECT MAX(DB_ITEM) AS XTIT FROM "+RETSQLNAME("SDB")+" Z WHERE Z.DB_FILIAL = '"+xFilial("SDB")+"' AND Z.D_E_L_E_T_ = ' ' AND Z.DB_PRODUTO = '"+cProd+"' AND Z.DB_NUMSEQ = '"+cDoc+"' "
    IIF(SELECT("TRBXT")>0,TRBXT->(DBCLOSEAREA()),NIL)
    cQuery := ChangeQuery(cQuery )
    dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , "TRBXT" , .T. , .F.)
    IF TRBXT->(!EOF())
        cRet      := TRBXT->XTIT
    ENDIF
Return(cRet)