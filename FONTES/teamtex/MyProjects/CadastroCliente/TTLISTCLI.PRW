#INCLUDE "PROTHEUS.CH"


USER FUNCTION TTLISTCLI()
    Local aItens1   := {}
    Local aItens2   := {}
    Local NfOR      := 0
    Local nOpca     := 0
    lOCAL cSelect   := ""
    Local aSays:={}, aButtons:={}
    Private cCadastro := "Relatorio de Clientes que não estão com 4 digitos na loja"
    Private acab      := {}
    DBSELECTAREA("SA1")


    AADD(aSays,"  Este programa tem como objetivo Imprimir um relatorio em Excel")
    AADD(aSays,"de Clientes que não estão com 4 digitos na loja")
    AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
    AADD(aButtons, { 2,.T.,{|o| nOpca:= 0,o:oWnd:End() }} )
    FormBatch( cCadastro, aSays, aButtons ,,,425)

    IF nOpca == 1
        cSelect := " SELECT *     "
        cSelect += "   FROM SA1010 C    "
        cSelect += "  WHERE C.D_E_L_E_T_ = ' '    "
        cSelect += "    AND C.A1_FILIAL = '  '    "
        cSelect += "    AND LTRIM(RTRIM(C.A1_NOME)) NOT IN    "
        cSelect += "          (SELECT LTRIM(RTRIM(B.A1_NOME))    "
        cSelect += "             FROM SA1010 B    "
        cSelect += "            WHERE B.D_E_L_E_T_ = ' '    "
        cSelect += "              AND B.A1_FILIAL = '  '    "
        cSelect += "              AND LTRIM(RTRIM(B.A1_NOME)) IN    "
        cSelect += "                  (SELECT LTRIM(RTRIM(A.A1_NOME))    "
        cSelect += "                     FROM SA1010 A    "
        cSelect += "                    WHERE A.D_E_L_E_T_ = ' '    "
        cSelect += "                      AND A.A1_FILIAL = '  '    "
        cSelect += "                      AND LEN(LTRIM(RTRIM(A.A1_LOJA))) = 2    "
        cSelect += "                    GROUP BY A.A1_NOME    "
        cSelect += "                   HAVING COUNT(*) = 1)    "
        cSelect += "              AND LEN(LTRIM(RTRIM(B.A1_LOJA))) = 4)    "
        cSelect += "      AND LTRIM(RTRIM(C.A1_NOME)) IN    "
        cSelect += "          (SELECT LTRIM(RTRIM(A.A1_NOME))    "
        cSelect += "             FROM SA1010 A    "
        cSelect += "            WHERE A.D_E_L_E_T_ = ' '    "
        cSelect += "              AND A.A1_FILIAL = '  '    "
        cSelect += "              AND LEN(LTRIM(RTRIM(A.A1_LOJA))) = 2    "
        cSelect += "            GROUP BY A.A1_NOME    "
        cSelect += "           HAVING COUNT(*) = 1)    "

        cselect := ChangeQuery(cselect)
        dbUseArea(.T., "TOPCONN", TCGenQry(,,cselect), "CSELECT", .F., .T.)
        acab := CSELECT->(DBSTRUCT())

        WHILE CSELECT->(!EOF())
            FOR NfOR := 1 TO LEN(acab)
                AADD(aItens1,&('CSELECT->'+acab[NFOR][1]))
            NEXT NFOR
            AADD(aItens2,ACLONE(aItens1))
            aItens1 := {}
            CSELECT->(DBSKIP())
        END
        MsgRun("Favor Aguardar.....", "Exportando os Registros para o Excel",{||DlgToExcel({{"GETDADOS","Relatorio de Clientes que não estão com 4 digitos na loja",acab,aItens2}})})
    endif
RETURN()