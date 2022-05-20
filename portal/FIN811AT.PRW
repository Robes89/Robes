

 /*/{Protheus.doc} nomeFunction
    (long_description)
    @type  Function
    @author user
    @since 03/05/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    a811Param[01] := Código do cliente De (tipo caracter)
a811Param[02] := Loja do cliente De (tipo caracter)
a811Param[03] := Código do cliente Até (tipo caracter)
a811Param[04] := Loja do cliente Até (tipo caracter)
a811Param[05] := Data de emissão De (tipo data)        
a811Param[06] := Data de emissão Até (tipo data)  
a811Param[07] := Data de referência (tipo data)     
a811Param[08] := Valor de (tipo numérico)     
a811Param[09] := Valor Até (tipo numérico)        
a811Param[10] := "2" (tipo caracter) - IMPORTANTE:  SEMPRE 2 PARA NÃO APRESENTAR TELA DE SELEÇÃO DE FILIAIS
a811Param[11] := Títulos a vencer (tipo caracter  sendo "1" = Sim ou "2" = Não)
a811Param[12] := Considera valor (tipo caracter sendo "1" = Total ou  "2" = Saldo)
a811Param[13] :="2" (tipo caracter) - IMPORTANTE: SEMPRE 2 PARA NÃO APRESENTAR TELA DE SELEÇÃO DE SITUAÇÃO DE COBRANÇA
a811Param[14] := {} (tipo array) - IMPORTANTE: ENVIAR ARRAY VAZIO
a811Param[15] := "" (tipo caracter) - IMPORTANTE: SEMPRE VAZIO
a811Param[16] := Código do layout da carta a ser utilizado (tipo caracter) 
a811Param[17] := Considera clientes bloqueados (A1_MSBLQL) no filtro. Espera-se conteúdo "1" para considerar clientes bloqueados ou "2" para considerar apenas clientes ativos
    /*/
USer Function FIN811AT()


Local   nJ:= 0
Local   aVetor := {}
Private aRetorno := {}

    DbSelectArea("FWP")
    DbSetOrder(1)
    FWP->(DBGOTOP())

    While !FWP->(EOF())
        If    FWP->FWP_STATUS == '1' 
            If FWP->FWP_SOMSUB == 'S' .or. FWP->FWP_SOMSUB == ' '
                aVetor := {"      ","  ","ZZZZZZ","ZZ",(dDataBase - FWP->FWP_DIASDE ),(dDataBase - FWP->FWP_DIASAT  ),dDataBase,0,9999999999,'2','2','2','2',{},'',FWP->FWP_CODCRT,'1'} 
                FINA811(0,aVetor)
            else
                aVetor := {"      ","  ","ZZZZZZ","ZZ",(dDataBase + FWP->FWP_DIASDE),(dDataBase + FWP->FWP_DIASAT  ),dDataBase,0,9999999999,'2','2','2','2',{},'',FWP->FWP_CODCRT,'1'} 
                FINA811(0,aVetor)
            EndIF
        ENDIF             
       FWP->(DbSkip())
    ENDDO
Return aRetorno

