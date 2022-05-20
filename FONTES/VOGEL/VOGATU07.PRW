#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} VOGATU07
Retorna observacoes para qualquer tipo de relatorio com contrato com base no numero do documento
@type function
@author B. Vinicius
@since 15/07/2020
@version 1.0
/*/

User Function VOGATU07(cNota,cSerie)


    Local cAliasQry := GetNextAlias()
    Local cAliasF2  := GetNextAlias()
    Local cRet := ""

//Busca as mensagens nos contratos daquela nota
    BeginSQL Alias cAliasQry

    SELECT C5_MENNOTA,C5_CLIENTE
    
    FROM %Table:SC5% SC5
    
    WHERE  C5_FILIAL+C5_NUM IN (
                                 SELECT DISTINCT  D2_FILIAL+ D2_PEDIDO FROM %Table:SD2% SD2 
                                 
                                 WHERE D2_DOC = %Exp:cNota% AND D2_FILIAL = %Exp:FWxFilial("SD2")%
                                
                                AND D2_SERIE = %Exp:cSerie% AND SD2.D_E_L_E_T_ =' '  ) 

    AND SC5.D_E_L_E_T_ = '' 

    EndSQL

    While !(cAliasQry)->(EOF())
        cRet +=  Alltrim((cAliasQry)->C5_MENNOTA) + ""
        (cAliasQry)->(dbSkip())
    EndDo
    BeginSQL Alias cAliasF2
     SELECT DISTINCT  F2_CLIENTE,F2_ESPECIE FROM %Table:SF2% SF2 
                                 
                                 WHERE F2_DOC = %Exp:cNota% AND F2_FILIAL = %Exp:FWxFilial("SF2")%
                                
                                AND F2_SERIE = %Exp:cSerie% AND SF2.D_E_L_E_T_ =' '
    EndSQL                            
    If Alltrim(Posicione("SA1",1,xFilial("SA1")+Alltrim((cAliasF2)->F2_CLIENTE),"A1_XTIPO")) == "07" .And. Alltrim((cAliasF2)->F2_ESPECIE) $ "NFSC|NTST|FAT"
       cRet += FORMULA("802")
    EndIF   
    (cAliasQry)->(dbCloseArea())

Return cRet