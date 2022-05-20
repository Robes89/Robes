#INCLUDE "PROTHEUS.CH"

User Function ITEM()
    Local aParam     := PARAMIXB
    Local xRet       := .T.
    Local oObj       := ''
    Local cIdPonto   := ''
    Local cIdModel   := ''
    
    Local nLinha     := 0
    Local nQtdLinhas := 0
    Local cMsg       := ''
 
    If aParam <> NIL
        oObj        := aParam[1]
        cIdPonto    := aParam[2]
        cIdModel    := aParam[3]
        
        If cIdPonto == 'MODELCOMMITTTS'
            //Chamada apos a gravação total do modelo e dentro da transação (MODELCOMMITTTS).'
            u_MT010ALT()
        EndIf
 
    EndIf
 
Return xRet

User Function MT010ALT()
    SB5->(DBSETORDER(1))
    IF SB5->(DBSEEK(xFilial("SB5")+SB1->B1_COD))
        RECLOCK("SB5",.F.)
        SB5->B5_XM3MAST := SB5->B5_XLARMAS * SB5->B5_XECMAST  * SB5->B5_XALTMAS
        SB5->B5_XPESMAS := SB5->B5_XLARMAS * SB5->B5_XECMAST  * SB5->B5_XALTMAS * 300
        SB5->B5_XMETCUB := SB5->B5_XALTM3  * SB5->B5_XECLARGE * SB5->B5_XECCOME
        SB5->B5_XPESCUB := SB5->B5_XALTM3  * SB5->B5_XECLARGE * SB5->B5_XECCOME * 300
        MSUNLOCK()
    ELSE
        ALERT('COMPLEMENTO DO PRODUTO NÃO ENCONTRADO')
    ENDIF
Return()

User Function XBACK()
    TCSQLEXEC("UPDATE SB5010 SET B5_XM3MAST =  (B5_XLARMAS*B5_XECMAST*B5_XALTMAS), B5_XPESMAS= (B5_XLARMAS*B5_XECMAST*B5_XALTMAS*300), B5_XMETCUB = (B5_XALTM3*B5_XECLARGE*B5_XECCOME), B5_XPESCUB = (B5_XALTM3*B5_XECLARGE*B5_XECCOME*300) ") 
    ALERT("ALTERAÇÃO REALISADA COM SUCESSO")
Return()
