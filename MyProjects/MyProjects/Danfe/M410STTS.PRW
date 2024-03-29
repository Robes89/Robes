#include "rwmake.ch"
#include "PROTHEUS.ch"

User Function M410STTS()
    local llRet := .T.
    Local nXVolum    := 0
    Local cVolume   := "CX"
    Local nPesoLiq  := nPesoBrut    := 0
    Local cTipCX    := ""

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
            nPesoLiq    += SB1->B1_PESO *   SC6->C6_QTDVEN
            nPesoBrut   += SB1->B1_PESBRU   *   SC6->C6_QTDVEN
            cTipCX      := SC6->C6_XCXMAST
            if !SB5->(dbSeek(xFilial("SB5") + _cCodProd ))
                Aviso("Aviso","Codigo do Produto: "+SC6->C6_PRODUTO+CRLF+;
                    " Item: "+SC6->C6_ITEM+CRLF+;
                    " Descri��o: "+ALLTRIM(SB1->B1_DESC)+CRLF+" N�o esta cadastrado no SB5 (Complemento do produto), N�o sera calculado cubagem",{"Ok"},3)
                if SB1->B1_QTCXMST > 1 // regra de divis�o de caixa master (em um caixa master cabe quantos produtos)
                    nXVolum      += (SC6->C6_QTDVEN / SB1->B1_QTCXMST)
                    cVolume     := "CX"
                ELSE
                    nXVolum      += SC6->C6_QTDVEN
                    cVolume     := "CX"
                ENDIF
            else
                If SC6->C6_XCXMAST == "2"
                    If SB5->( !Empty(B5_XM3MAST) .and. !Empty(B5_XPESMAS) )
                        if SB1->B1_QTCXMST > 1 // regra de divis�o de caixa master (em um caixa master cabe quantos produtos)
                            _nCub01     += ROUND(( SB5->B5_XM3MAST * (SC6->C6_QTDVEN / SB1->B1_QTCXMST) ),2)
                            _nCub02     += ROUND(( SB5->B5_XPESMAS * (SC6->C6_QTDVEN / SB1->B1_QTCXMST) ),2)
                            nXVolum      += (SC6->C6_QTDVEN / SB1->B1_QTCXMST)
                            cVolume     := "CX"
                        else
                            _nCub01     += ROUND(SB5->B5_XM3MAST,2)
                            _nCub02     += ROUND(SB5->B5_XPESMAS,2)
                            nXVolum      += SC6->C6_QTDVEN
                            cVolume     := "CX"
                        endif
                    elseif empty(SB5->B5_XM3MAST)
                        Aviso("Aviso","Codigo do Produto: "+SC6->C6_PRODUTO+CRLF+;
                            " Item: "+SC6->C6_ITEM+CRLF+;
                            " Descri��o: "+ALLTRIM(SB1->B1_DESC)+CRLF+" N�o esta cadastrado no SB5 (Complemento do produto), N�o sera calculado cubagem",{"Ok"},3)
                        if SB1->B1_QTCXMST > 1 // regra de divis�o de caixa master (em um caixa master cabe quantos produtos)
                            nXVolum      += (SC6->C6_QTDVEN / SB1->B1_QTCXMST)
                            cVolume     := "CX"
                        ELSE
                            nXVolum      += SC6->C6_QTDVEN
                            cVolume     := "CX"
                        ENDIF
                    elseif empty(SB5->B5_XPESMAS)
                        Aviso("Aviso","Codigo do Produto: "+SC6->C6_PRODUTO+CRLF+;
                            " Item: "+SC6->C6_ITEM+CRLF+;
                            " Descri��o: "+ALLTRIM(SB1->B1_DESC)+CRLF+" N�o esta cadastrado no SB5 (Complemento do produto), N�o sera calculado cubagem",{"Ok"},3)
                        if SB1->B1_QTCXMST > 1 // regra de divis�o de caixa master (em um caixa master cabe quantos produtos)
                            nXVolum      += (SC6->C6_QTDVEN / SB1->B1_QTCXMST)
                            cVolume     := "CX"
                        ELSE
                            nXVolum      += SC6->C6_QTDVEN
                            cVolume     := "CX"
                        ENDIF
                    EndIf
                ElseIf SC6->C6_XCXMAST == "1"
                    If SB5->( !Empty(B5_XMETCUB) .and. !Empty(B5_XPESCUB) )
                        _nCub01     += ( SB5->B5_XMETCUB * SC6->C6_QTDVEN )
                        _nCub02     +=  ( SB5->B5_XPESCUB * SC6->C6_QTDVEN )
                        nXVolum      += SC6->C6_QTDVEN
                        cVolume     := 'CX'
                    elseif empty(SB5->B5_XM3MAST)
                        Aviso("Aviso","Codigo do Produto: "+SC6->C6_PRODUTO+CRLF+;
                            " Item: "+SC6->C6_ITEM+CRLF+;
                            " Descri��o: "+ALLTRIM(SB1->B1_DESC)+CRLF+" N�o esta cadastrado no SB5 (Complemento do produto), N�o sera calculado cubagem",{"Ok"},3)
                        if SB1->B1_QTCXMST > 1 // regra de divis�o de caixa master (em um caixa master cabe quantos produtos)
                            nXVolum      += (SC6->C6_QTDVEN / SB1->B1_QTCXMST)
                            cVolume     := "CX"
                        ELSE
                            nXVolum      += SC6->C6_QTDVEN
                            cVolume     := 'CX'
                        ENDIF
                    elseif empty(SB5->B5_XPESMAS)
                      
                        Aviso("Aviso","Codigo do Produto: "+SC6->C6_PRODUTO+CRLF+;
                            " Item: "+SC6->C6_ITEM+CRLF+;
                            " Descri��o: "+ALLTRIM(SB1->B1_DESC)+CRLF+" N�o esta cadastrado no SB5 (Complemento do produto), N�o sera calculado cubagem",{"Ok"},3)
                        if SB1->B1_QTCXMST > 1 // regra de divis�o de caixa master (em um caixa master cabe quantos produtos)
                            nXVolum      += (SC6->C6_QTDVEN / SB1->B1_QTCXMST)
                            cVolume     := "CX"
                        ELSE
                            nXVolum      += SC6->C6_QTDVEN
                            cVolume     := "CX"
                        ENDIF
                    EndIf
                EndIf
        
            endif

            SC6->(dbSkip())
        Enddo

    // grava informa��es no SC5                                            
                                
        dbSelectArea("SC5")
    
    //-- Atualiza C5_MENNOTA do pedido de venda posicionado inicialmente
        If SC5->( dbseek( xFilial("SC5") + _cNumPed )   )
            RecLock( "SC5" , .F. )
            if cTipCX $ "1,2"
                SC5->C5_PCUB01 := _nCub01
                SC5->C5_PCUB02 := round(_nCub02,2) // margem de erro
                SC5->C5_VOLUME1     := nXVolum // VOLUME
                SC5->C5_ESPECI1     := cVolume // VOLUME
                SC5->C5_PESOL       := nPesoLiq
                SC5->C5_PBRUTO      := nPesoBrut
            endif
            MSUNLOCK()     // Destrava o registro
        else
            alert('pedido n�o encontrado! '+_cNumPed)
        EndIf
    
    endif

// restaura ponteiros dos arquivos

    dbSelectArea(_cAlias)
    dbSetOrder(_cOrder)
    dbGoto(_cRecno)

Return llRet
                                                         
