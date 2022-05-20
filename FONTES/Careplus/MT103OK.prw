#INCLUDE "protheus.ch"
#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "prtopdef.ch"       
#include "TbiConn.ch"
#include "TbiCode.ch"

 /*/{Protheus.doc} nomeFunction
    (long_description)
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/

 User Function MTA103OK()
 
Local aBaixa := {}
Local lRet := ParamIxb[1]
Local nOpc := 3 
Local nSeqBx := 1 
Local nPed :=  Ascan(aHeader,{|x|Alltrim(Upper(x[2]))=="D1_PEDIDO"})
Local niTem :=  Ascan(aHeader,{|x|Alltrim(Upper(x[2]))=="D1_ITEMPC"})
Local cAlias := GetNextAlias()
Local cPed := ''

Private lMsErroAuto:= .F.

dbSelectArea("SC7")
SC7->(DbSetOrder(1))
For nU := 1 to len(aCols)
    SC7->(DbSeek(xFilial("SC7")+aCols[nU][nPed]+aCols[nU][nItem]))
    IF !(nU == len(aCols))
        cPed+= SC7->C7_NUMSC +";"
    Else
        cPed+= +SC7->C7_NUMSC
    EndIf    
Next

dbSelectArea("SE2")
SE2->(dbSetOrder(1))
SE2->(dbGoTop())


cQry:=   " Select * from "+RetSqlName("SE2")+" SE2 where SE2.D_E_L_E_T_ = ''   and SE2.E2_XPREPRO ='CNT'  and  SE2.E2_TIPO = 'PR' "
cQry+=  "  and E2_BAIXA = ''  and  SE2.E2_XTITPRO in  " + FormatIn(cPed,";") + " and SUBSTRING(E2_VENCTO,5,2)  = '"+Substring(DTOS(dDataBase),5,2)+"'"

cQry:= changeQuery(cQry)
dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQry) , cAlias , .T. , .F.)
While !(cAlias)->(Eof())

SE2->(DbSeek((cAlias)->E2_FILIAL+(cAlias)->E2_PREFIXO+(cAlias)->E2_NUM+(cAlias)->E2_PARCELA))

RecLock("SE2",.F.)
SE2->E2_SALDO := 0
SE2->E2_LA := 'S'
SE2->E2_VALLIQ := (cAlias)->E2_VALOR
SE2->E2_BAIXA := dDataBase
MsUnLock()

            /*aBaixa := {}        
            Aadd(aBaixa, {"E2_FILIAL", (cAlias)->E2_FILIAL,  nil})
            Aadd(aBaixa, {"E2_PREFIXO", (cAlias)->E2_PREFIXO,  nil})
            Aadd(aBaixa, {"E2_NUM", (cAlias)->E2_NUM,      nil})
            Aadd(aBaixa, {"E2_PARCELA", (cAlias)->E2_PARCELA,  nil})
            Aadd(aBaixa, {"E2_TIPO", (cAlias)->E2_TIPO,     nil})
            Aadd(aBaixa, {"E2_FORNECE", (cAlias)->E2_FORNECE,  nil})
            Aadd(aBaixa, {"E2_LOJA", (cAlias)->E2_LOJA ,    nil})
            Aadd(aBaixa, {"AUTMOTBX", "NOR",            nil})
            Aadd(aBaixa, {"AUTBANCO", "001",            nil})
            Aadd(aBaixa, {"AUTAGENCIA", "AG001",          nil})
            Aadd(aBaixa, {"AUTCONTA", "CTA001 ",     nil})
            Aadd(aBaixa, {"AUTDTBAIXA", dDataBase,        nil})
            Aadd(aBaixa, {"AUTDTCREDITO", dDataBase,        nil})
            Aadd(aBaixa, {"AUTHIST", "Baixa PR ",       nil})
            Aadd(aBaixa, {"AUTVLRPG", (cAlias)->E2_VALOR,          nil})
 
            //Pergunte da rotina
             AcessaPerg("FINA080", .F.)                  
         
            //Chama a execauto da rotina de baixa manual (FINA080)
            MsExecauto({|a,b| FINA080(a,b)}, aBaixa, nOpc)
         
            If lMsErroAuto
                MostraErro()
            Else
                If nOpc == 3
                    Alert("Baixa efetuada com sucesso")
                Else
                    Alert("Exclusão realizada com sucesso")
                EndIf
            EndIf*/
    (cAlias)->(DbSkip())
EndDo   

Return lRet 