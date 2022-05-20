#include "rwmake.ch"
#DEFINE ENTER CHR(13) + CHR(10) 

User Function M410PVNF()
Local _cNum    := SC5->C5_NUM
Local _cStatus := SC5->C5_STPAD
Local lRet     := .t.  
Local lFlag    := .f.

dbSelectArea("SC6")
dbSetOrder(1)
dbSeek(xFilial("SC6")+_cNum)
While SC6->(!Eof()) .and. SC6->(C6_FILIAL+C6_NUM) == SC5->(C5_FILIAL+C5_NUM)
   _cfop := Alltrim(SC6->C6_CF)
   If SC6->C6_QTDLIB == 0
      _nQuant := SC6->C6_QTDVEN
   Else
      _nQuant := SC6->C6_QTDLIB
   Endif
   If _cStatus $ "CD"  
      nTotQtd := 0
      dbSelectArea("SB2")           
      dbSetOrder(1)
      If dbSeek(xFilial("SB2") + SC6->C6_PRODUTO + SC6->C6_LOCAL)
         nTotQtd := SB2->B2_QATU - SB2->B2_QEMP
      Endif 
      If substr(_cfop,2,3) $ "111/112"
	      If nTotQtd < _nQuant //SC6->C6_QTDLIB 
	         If _cStatus $ "C"
		        cMsg := "Pedido de VENDA de Consignação: " + Alltrim(SC6->C6_PEDIDO) + ENTER + ENTER
		     Endif   
	         cMsg += "O Produto "+Alltrim(SC6->C6_PRODUTO)+" do armazém "+Alltrim(SC6->C6_LOCAL)+" selecionado não contem saldo suficiente para esta operação."+ ENTER + ENTER
             cMsg += "Saldo atual: "+Str(nTotQtd,12,2)+", Saldo liberado para faturamento: "+str(_nQuant,12,2)+ ENTER +ENTER+"M410PVNF-1"
	         Alert(cMsg)
	         MaViewSB2(SC6->C6_PRODUTO)
	         lflag := .t.
          Endif
	   Else
	      If SC6->C6_LOCAL $ "02/03"
	         Alert("Almoxarifado para esta operação: "+SC6->C6_LOCAL+", não poderá ser utilizado por ser almoxarifado de Consignação/Demonstração, favor rever o almoxarifado!")
	         lRet := .t. 
	      Endif
	      If nTotQtd < _nQuant  //SC6->C6_QTDLIB 
	         If _cStatus $ "C"
		        cMsg := "Pedido para Remessa de Consignação: " + Alltrim(SC6->C6_PEDIDO) + ENTER + ENTER
		     ElseIf _cStatus $ "D"
		        cMsg := "Pedido para Remessa de Demonstração: " + Alltrim(SC6->C6_PEDIDO) + ENTER + ENTER
		     Endif   
	         cMsg += "O Produto "+Alltrim(SC6->C6_PRODUTO)+" do armazém "+Alltrim(SC6->C6_LOCAL)+" selecionado não contem saldo suficiente para esta operação."+ ENTER + ENTER
             cMsg += "Saldo atual: "+Str(nTotQtd,12,2)+", Saldo liberado para faturamento: "+str(_nQuant,12,2)+ ENTER  +ENTER+"M410PVNF-2"
	         Alert(cMsg)
	         MaViewSB2(SC6->C6_PRODUTO)
	         lflag := .t.
          Endif
       Endif
   Endif
   SC6->(dbSkip())
Enddo
If lFlag
   Alert("O saldo para um ou mais produtos ficará negativo! ou"+ENTER+ENTER+", Almoxarifado selecionado para operação incorreto! "+ENTER+ENTER+"Não será possível continuar com a operação!")
   lRet := .f.
Endif

Return(lRet)
