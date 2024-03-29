#include "rwmake.ch"    
#include "PROTHEUS.ch"

User Function M410STTS()                                
local llRet := .T.
Local nVolum    := 0    


/*  
    FUN��O DE CALCULAR E GRAVAR A CUBAGEM DOS ITENS DA NOTA
    Especifico TEAM TEX -  MARCOS BIDO - 25/05/18
*/

//  Guarda o Pedido Posicionado (imediatamente apos a gravacao) 

_cAlias := Alias()
_cOrder := IndexOrd()
_cRecno := Recno()

//  MSGALERT("M410STTS - 29/05")
    
dbSelectArea("SC5")
_cNumPed  := SC5->C5_NUM
_nCub01   := 0
_nCub02   := 0        

dbSelectArea("SB5")
dbSetOrder(1)

// posiciona nos itens do pedidolduarte
SC6->(dbSetOrder(1))
SB1->(dbSetOrder(1))

IF SC6->(dbSeek( xFilial("SC6") + _cNumPed ))
        
    Do While SC6->(!Eof()) .and. SC6->C6_NUM == _cNumPed
        _cCodProd := SC6->C6_PRODUTO
        SB1->(dbSeek(xFilial("SB1") + _cCodProd ))
        
        if !SB5->(dbSeek(xFilial("SB5") + _cCodProd ))    
            Aviso("Aviso","Codigo do Produto: "+SC6->C6_PRODUTO+CRLF+;
                   " Item: "+SC6->C6_ITEM+CRLF+;
                   " Descri��o: "+ALLTRIM(SB1->B1_DESC)+CRLF+" N�o esta cadastrado no SB5 (Complemento do produto), N�o sera calculado cubagem",{"Ok"},3)
        else                
            If SC6->C6_XCXMAST == "2"
                If SB5->( !Empty(B5_XM3MAST) .and. !Empty(B5_XPESMAS) )
                    if SB1->B1_QTCXMST > 1
                        _nCub01     += ROUND(( SB5->B5_XM3MAST * (SC6->C6_QTDVEN / SB1->B1_QTCXMST) ),2)
                        _nCub02     += ROUND(( SB5->B5_XPESMAS * (SC6->C6_QTDVEN / SB1->B1_QTCXMST) ),2)
                        nVolum      += (SC6->C6_QTDVEN / SB1->B1_QTCXMST)
                    else
                        _nCub01     += ROUND(SB5->B5_XM3MAST,2)
                        _nCub02     += ROUND(SB5->B5_XPESMAS,2)
                        nVolum      += SC6->C6_QTDVEN
                    endif
                elseif empty(SB5->B5_XM3MAST)
                    Aviso("Aviso","Codigo do Produto: "+SC6->C6_PRODUTO+CRLF+;
                   " Item: "+SC6->C6_ITEM+CRLF+;
                   " Descri��o: "+ALLTRIM(SB1->B1_DESC)+CRLF+" N�o esta cadastrado no SB5 (Complemento do produto), N�o sera calculado cubagem",{"Ok"},3)
              elseif empty(SB5->B5_XPESMAS)
                    Aviso("Aviso","Codigo do Produto: "+SC6->C6_PRODUTO+CRLF+;
                   " Item: "+SC6->C6_ITEM+CRLF+;
                   " Descri��o: "+ALLTRIM(SB1->B1_DESC)+CRLF+" N�o esta cadastrado no SB5 (Complemento do produto), N�o sera calculado cubagem",{"Ok"},3)
              EndIf
            ElseIf SC6->C6_XCXMAST == "1"
                If SB5->( !Empty(B5_XMETCUB) .and. !Empty(B5_XPESCUB) )
                    _nCub01     += ( SB5->B5_XMETCUB * SC6->C6_QTDVEN ) 
                    _nCub02     +=  ( SB5->B5_XPESCUB * SC6->C6_QTDVEN ) 
                    nVolum      += SC6->C6_QTDVEN
                elseif empty(SB5->B5_XM3MAST)
                    Aviso("Aviso","Codigo do Produto: "+SC6->C6_PRODUTO+CRLF+;
                   " Item: "+SC6->C6_ITEM+CRLF+;
                   " Descri��o: "+ALLTRIM(SB1->B1_DESC)+CRLF+" N�o esta cadastrado no SB5 (Complemento do produto), N�o sera calculado cubagem",{"Ok"},3)
              elseif empty(SB5->B5_XPESMAS)
                    Aviso("Aviso","Codigo do Produto: "+SC6->C6_PRODUTO+CRLF+;
                   " Item: "+SC6->C6_ITEM+CRLF+;
                   " Descri��o: "+ALLTRIM(SB1->B1_DESC)+CRLF+" N�o esta cadastrado no SB5 (Complemento do produto), N�o sera calculado cubagem",{"Ok"},3)
              EndIf         
            EndIf
        
        endif

        SC6->(dbSkip())
    Enddo              

    // grava informa��es no SC5                                            
                                
    dbSelectArea("SC5")
    
    //-- Atualiza C5_MENNOTA do pedido de venda posicionado inicialmente
        If SC5->( MsSeek( xFilial("SC5") + _cNumPed )   )
            RecLock( "SC5" , .F. )
            SC5->C5_PCUB01 := _nCub01
            SC5->C5_PCUB02 := round(_nCub02,2) // margem de erro
            SC5->C5_VOLUME1 := nVolum // VOLUME 
            SC5->C5_ESPECI1 := "CX" // VOLUME 
            MSUNLOCK()     // Destrava o registro
        EndIf
    
endif

// restaura ponteiros dos arquivos

dbSelectArea(_cAlias)
dbSetOrder(_cOrder)
dbGoto(_cRecno)

Return llRet
                                                         
