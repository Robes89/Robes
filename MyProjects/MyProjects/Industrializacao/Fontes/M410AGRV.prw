#include "Protheus.ch"

/*
autor Leandro Duarte
Data: 01/11/2018
Assunto Ponto de entrada para efetuar a grava��o do peso liquido e do peso bruto do pedido
*/
User Function M410AGRV()
    Local nOpc      := Paramixb[1]
    Local nFor      := 0
    Local nPosPrd   := Ascan(aHeader,{|x| alltrim(x[2]) == "C6_PRODUTO"})
    Local nPosQtd   := Ascan(aHeader,{|x| alltrim(x[2]) == "C6_QTDVEN"})
    Local nPesoLiq  := nPesoBrut    := 0

    if nOpc == 1 .or. nOpc == 2
        For nFor := 1 to len(aCols)
            nPesoLiq    += aCols[nFor][nPosQtd] * Posicione("SB1",1,xFilial("SB1")+aCols[nFor][nPosPrd],"B1_PESO")
            nPesoBrut   += aCols[nFor][nPosQtd] * Posicione("SB1",1,xFilial("SB1")+aCols[nFor][nPosPrd],"B1_PESBRU")
        Next nFor
        IF nOpc == 1
            M->C5_PESOL     := nPesoLiq
            M->C5_PBRUTO    := nPesoBrut
        ELSE
            RECLOCK("SC5",.F.)
                SC5->C5_PESOL     := nPesoLiq
                SC5->C5_PBRUTO    := nPesoBrut
            MSUNLOCK()
            M->C5_PESOL     := nPesoLiq
            M->C5_PBRUTO    := nPesoBrut
        ENDIF
    endif
    /*
    RECLOCK("SC5",.F.)
        	SC5->C5_MENNOTA := "Romaneio: " + "Pedido: "+SC5->C5_NUM //+SPACE(240) +'M3='+ STR(SC5->C5_PCUB01)+'/'+'PESO CUBADO='+STR(SC5->C5_PCUB02)+'-'
    MSUNLOCK()
    */
   	//M->C5_MENNOTA := "Romaneio: " + "Pedido: "+SC5->C5_NUM +SPACE(05)+'M3='+ STR(M->C5_PCUB01)+'/'+'PESO CUBADO='+STR(SC5->C5_PCUB02)+'-'
Return()
