#INCLUDE "Protheus.ch"
#INCLUDE "Rwmake.ch"
#INCLUDE "TopConn.ch"
#DEFINE ENTER CHR(13) + CHR(10) 

User Function M460MARK()   
//--------------------------------------------------------------------
/*/{Protheus.doc} M460MARK
Ponto-de-Entrada: M460MARK - Ponto de Entrada na Seleção de Pedidos para Faturamento 

Descrição:
utilizado no momento da seleção dos itens 

@author Fernando Pacheco
@since  01/03/2017 
@obs    Cabeçalho e documentação de fontes
@version 1.0 - Fernando Pacheco - 01/03/17
/*/
//--------------------------------------------------------------------

Local lRet 		:= .T.

Local cQuery	:= ""
Local lDtMenor	:= .F.
Local lDtMaior	:= .F.
Local cMarca  	:= ParamIXB[1]
Local lInver  	:= ParamIXB[2]
Local aArea     := GetArea()
Local aAreaSC5  := SC5->(GetArea())
Local nX	    := 0
Local nArmazem
Local lAchou    := .F.
Local cMsg      := ""
Local _cStatus  := "" 
Private xRet    := .F.
Private lxRet   := .F.   
Private lFlag   := .f.

If lRet
	_cQuery := " SELECT * " + ENTER
	_cQuery += " FROM " + RetSQLName("SC9") + " SC9 (NOLOCK) "
	_cQuery += " WHERE C9_FILIAL = '"+ xFilial("SC9") + "' "
	_cQuery += "   AND SC9.D_E_L_E_T_ = ' ' "
	_cQuery += "   AND C9_OK = '" + PARAMIXB[1] + "' "
	
	If Select("QSC9") > 0
		dbSelectArea("QSC9")
		QSC9->(dbCloseArea())
	EndIf
	
	TcQuery _cQuery New Alias "QSC9"
	QSC9->(dbGoTop())
    While QSC9->(!Eof()) 
       _cStatus := Posicione("SC5",1, xFilial("SC5") + QSC9->C9_PEDIDO, "C5_STPAD")
       If _cStatus $ "CD"  // tratamento exclusivo para Consignação ou Demonstração
	      If QSC9->C9_LOCAL <> "01" //$ "02/03"
	         Alert("Almoxarifado para esta operação: "+QSC9->C9_LOCAL+", não poderá ser utilizado por ser almoxarifado de Consignação/Demonstração, favor rever o almoxarifado!")
	         Return(.f.)
	      Endif
       Endif
	   If !QSC9->(Eof())	
          nTotQtd := 0
          dbSelectArea("SB2")           
          dbSetOrder(1)
          If dbSeek(xFilial("SB2") + QSC9->C9_PRODUTO + QSC9->C9_LOCAL)
             nTotQtd := SB2->B2_QATU - SB2->B2_QEMP
          Endif 

	      //aSalProd := CalcEst(QSC9->C9_PRODUTO,QSC9->C9_LOCAL,dDataBase+1)
	      //nTotQtd := aSalProd[1]                                                      

	      If nTotQtd < QSC9->C9_QTDLIB 
	         If _cStatus $ "C"
		        cMsg := "Pedido para Remessa de Consignação: " + Alltrim(QSC9->C9_PEDIDO) + ENTER + ENTER
		     ElseIf _cStatus $ "D"
		        cMsg := "Pedido para Remessa de Demonstração: " + Alltrim(QSC9->C9_PEDIDO) + ENTER + ENTER
		     Endif   
	         cMsg += "O Produto "+Alltrim(QSC9->C9_PRODUTO)+" do armazém "+Alltrim(QSC9->C9_LOCAL)+" selecionado não contem saldo suficiente para o faturamento."+ ENTER + ENTER
             cMsg += "Saldo atual: "+Str(nTotQtd,12,2)+", Saldo liberado para faturamento: "+str(QSC9->C9_QTDLIB,12,2)+ ENTER  +ENTER+"M460MARK-1"
	         Alert(cMsg)
	         MaViewSB2(QSC9->C9_PRODUTO)
	         lflag := .t.
          Endif
	   EndIf
	   QSC9->(dbSkip())
    Enddo
	dbSelectArea("QSC9")
	QSC9->(dbCloseArea())
    If lFlag
       //If !MsgYesNo("O saldo para um ou mais produtos ficará negativo!"+ENTER+ENTER+"Deseja continuar com a operação ?") 
       Alert("O saldo para um ou mais produtos ficará negativo!"+ENTER+ENTER+"Não será possível continuar com a operação!")
       Return(.F.)
	   //Endif
	Endif
EndIf

RestArea(aAreaSC5)
RestArea(aArea)

Return(lRet)
