#include "rwmake.ch"
#DEFINE ENTER CHR(13) + CHR(10) 

//--------------------------------------------------------------------------
// Pto Entrada : M410LIOK
// Descricao   : Valida linha do pedido de venda
//--------------------------------------------------------------------------

User Function M410LIOK()
Local cSvAlias := {Alias(),IndexOrd(),Recno()}
Local _lRet    := .t.
Local _nPosCFO := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_CF"})
Local _cCFO    := aCols[n, _nPosCFO]
Local _nPosTES := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_TES"})
Local _cTES    := aCols[n, _nPosTES]
Local _nPosAlm := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_LOCAL"})
Local _cAlm    := aCols[n, _nPosALM]
Local _nPosCod := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRODUTO"})
Local _cCod    := aCols[n, _nPosCod]
Local _VendInt := Alltrim(GETMV("MV_XVENDIN"))
Local _VendTES := Alltrim(GETMV("MV_XVENDTE"))
Local _RemMost := Alltrim(GETMV("MV_XREMOST"))

_nPosCF		:= aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="C6_CF" })
_nPosNFORI	:= aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="C6_NFORI" })
_nPosSERIORI:= aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="C6_SERIORI" })
_nIpi       := Posicione("SB1",1,xFilial("SB1")+_cCod,"B1_IPI")
_cCalcIpi   := POSICIONE("SF4",1,xFilial("SF4")+_cTes,"F4_IPI")

//Nao considera linha deletada
If aCols[n][Len(aHeader)+1] // Valida se esta deletado. Se estiver retorna True
	_lRet := .T.
	Return(_lRet)
EndIf

If M->C5_TIPOCLI $ "X" .AND. ALLTRIM(_cCFO) $ "7949"  
      dbSelectArea(cSvAlias[1])
      dbSetOrder(cSvAlias[2])
      dbGoto(cSvAlias[3])
      Return(.t.)
Endif

If _nIpi > 0 .and. _cCalcIpi <> "S"
   If !(M->C5_STPAD $ "I")
      If MsgYesNo("Produto com IPI deverá ser utilizada TES com cálculo de IPI!, Deseja continuar?",OemToAnsi('Confirmação'))
         //disparar e-mail para fiscal
      Else
         Return .f.
      Endif   
   Endif   
Endif

If _nIpi == 0 .and. _cCalcIpi == "S"
   If !(M->C5_STPAD $ "I")
      Alert("Produto SEM IPI deverá ser utilizada TES SEM cálculo de IPI!")
      Return .f.
   Endif   
Endif

If M->C5_TIPO $ "D"
    If !(M->C5_STPAD $ "O")
      	 Alert("Para Devolução de Compras, STATUS do Pedido deverá ser OUTRAS SAIDAS!")
         Return .f.
    Endif     
Endif    
    
If M->C5_TIPO $ "B"
    If !(M->C5_STPAD $ "I")
      	 Alert("Para Beneficiamento, STATUS do Pedido deverá ser INDUSTRIALIZACAO!")
         Return .f.
    Endif     
    If substr(_cCFO,2,3) $ "101,102,111,112,401,403,107,108,109,110"
      	 Alert("Nao permitido uso de TES de Faturamento com cadastro de Fornecedor, cadastrar Fornecedor no cadastro de Cliente caso necessário") 
         Return .f.
    Endif     
Endif    
If substr(_cCFO,2,3) $ "912"  
   If M->C5_STPAD $ "DM"
      //TES DE DEMONSTRACAO E TIPO DO PEDIDO = DEMONSTRACAO
      _MovEst := POSICIONE("SF4",1,xFilial("SF4")+_cTes,"F4_ESTOQUE")
      If _MovEst <> "N"
      	 Alert("TES utilizada: "+_cTES+", não poderá movimentar ESTOQUE")
         Return .f.
      Endif   
      If _cAlm <> "01"
      	 Alert("Almoxarifado para operacao de Demonstracao deve ser 01")
         aCols[n, _nPosALM] := "01"                                     
      Endif   
   Else
	   Alert("Para utilizar o TES: "+_cTES+", o STATUS do pedido deverá ser de DEMONSTRACAO!")
	   Return .F.
   Endif
Endif
   
If substr(_cCFO,2,3) $ "917"  
   If M->C5_STPAD $ "C"
      //TES DE CONSIGNACAO E STATUS DO PEDIDO = CONSIGNACAO
      _MovEst := POSICIONE("SF4",1,xFilial("SF4")+_cTes,"F4_ESTOQUE")
      If _MovEst <> "N"
      	 Alert("TES utilizada: "+_cTES+", não poderá movimentar ESTOQUE")
         Return .f.
      Endif   
      If _cAlm <> "01"
      	 Alert("Almoxarifado para operacao de Demonstracao deve ser 01")
         aCols[n, _nPosALM] := "01"                                     
      Endif   
   Else
	   Alert("Para utilizar o TES: "+_cTES+", o STATUS do pedido deverá ser de CONSIGNACAO!")
	   Return .F.
   Endif
Endif

If substr(_cCFO,2,3) $ "949"  

   If M->C5_STPAD $ "O"
      //TES DE OUTRAS SAIDAS E STATUS DO PEDIDO = OUTRAS SAIDAS
      If _cAlm <> "01"
      	 Alert("Almoxarifado para operacao de Outras Saídas deve ser 01")
         aCols[n, _nPosALM] := "01"                                     
      Endif   
/*
   ElseIf M->C5_STPAD $ "M"
      If _cTES $ _RemMost
   		 //Remessa para Mostruario, operacao dentro dos parametros
      Else		                                                        
         Alert("Codigo de TES: "+_cTES+", nao pertence ao grupo de TES habilitados no parametro MV_XREMOST, para Remessa de Mostruário, contatar TI para incluir novo Codigo")
	     Return .F.
      Endif
*/
   ElseIf M->C5_STPAD $ "S"
	  If M->C5_TIPO $ "N" .AND. _cTES $ "691"
	     // REF NOTA PRESTACAO DE SERVIÇOS
      Else		                                                        
         Alert("Codigo de TES: "+_cTES+", nao habilitada para Nota de Prestaçao de Serviços, contatar departamento Fiscal")
	     Return .F.
      Endif
   Else
	   Alert("Para utilizar o TES: "+_cTES+", o STATUS do pedido deverá ser de OUTRAS SAIDAS!")
	   Return .F.
   Endif
Endif

If M->C5_CLIENTE $ _VendInt
   If _cTES $ _VendTES
   		//Cliente é Vendedor Interno, operacao dentro dos parametros
   Else		                                                        
      Alert("Codigo de TES: "+_cTES+", nao pertence ao grupo de TES habilitados no parametro MV_XVENDTE, para Vendedores Internos, contatar TI para incluir novo Codigo")
//      Alert("Codigo de Cliente: "+M->C5_CLIENTE+", nao pertence ao grupo de Vendedores Internos cadastrados no parametro MV_XVENDIN, contatar TI para incluir novo Codigo")
	   Return .F.
   Endif
Endif

If Substr(aCols[n,_nPosCf],2,3) $ "111/112" .and. (Empty(aCols[n,_nPosNFORI]) .or. Empty(aCols[n,_nPosSERIORI])) .and. !aCols[n,Len(aHeader)+1]
	Alert("Quando for venda em consignação, precisa preencher os campos N.F. Original e Serie Original")
	Return .F.
Endif

If substr(_cCFO,2,3) $ "101,102,111,112,401,403,107,108,109,110"
   If _cAlm <> "01"
    	 Alert("Para Vendas, utilizar somente almoxarifado 01")
         aCols[n, _nPosALM] := "01"                                     
		 Return .F.
   Endif   
Endif

dbSelectArea(cSvAlias[1])
dbSetOrder(cSvAlias[2])
dbGoto(cSvAlias[3])

u_xInfAdic()
                       
Return(_lRet)
