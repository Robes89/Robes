#Include 'Protheus.ch'

 /*/{Protheus.doc} VOGATU14
Rotina utilizada no PE MA161BAR para gravar informacoes no analise cotacao
@type function
@author B. Vinicius
@since 24/09/2020
@version 1.0
/*/

User Function VOGATU14()

    Local nMv := 0
    Local aMvPar := {}
    Local aParambox := {}
    Local cObs := Space(200)
    Local lInclui := .T.
    Local aArea := GetArea()

    // FAZENDO BACKUP DO MV_PAR POIS É UMA ROTINA CHAMADA DENTRO DE UMA TELA QUE CONTEM PARAMETROS
    For nMv := 1 To 40
        aAdd( aMvPar, &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) )
    Next nMv

    // Se ja existe tabela auxiliar gerada, carrega o campo com o preenchimento da mesma
    ZZ9->(dbSetOrder(1))
    If ZZ9->(dbSeek( FWxFilial("ZZ9") + SC8->C8_NUM ))
        lInclui := .F.
        cObs := Padr(ZZ9->ZZ9_CODOBS,200)
    Endif

    aAdd(aParamBox,{11,"Observacao",cObs,".T.",".T.",.T.})

    If ParamBox(aParamBox,'Parâmetros',,,,,,, , , .F.,.F.)

            //Salvando a observacao
            Reclock("ZZ9" , lInclui)

            ZZ9_FILIAL := FWxFilial("ZZ9")
            ZZ9_CODCOT = SC8->C8_NUM
            ZZ9_CODOBS := Alltrim(MV_PAR01)

            ZZ9->(MsUnLock())
    Endif

    // Restaurando os MVPAR
    For nMv := 1 To Len( aMvPar )
        &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
    Next nMv

    RestArea(aArea)

Return
