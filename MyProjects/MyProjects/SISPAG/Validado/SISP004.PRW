#include "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ SISP004  ³ Autor ³ Thiago Menegocci    ³ Data ³ 16/05/2019 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ ExecBlock disparado do 341REM.PAG para retornar dados de   ³±±
±±³          ³ pagamento de GPS e DARF.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNAB SISPAG                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function SISP004()

_cReturn := ""
_cCompet := STRZERO(MONTH(SE2->E2_EMISSAO),2)+STR(YEAR(SE2->E2_EMISSAO),4) 									// Competencia		 ok
_cValor	 := STRZERO(SE2->E2_SALDO*100,14)    						   										// Valor Principal	 ok
_cAux	 := REPL("0",14)					 			   			   										// Valor Out.Entid	 ok
_cVlMult := STRZERO(SE2->E2_ACRESC*100,14)     						   										// Multa / Atz.Mon	 ok
_cVlTot  := STRZERO((SE2->E2_SALDO+SE2->E2_ACRESC)*100,14) 			   										// Valor Arrecadad	 ok
_cDtVen  := GRAVADATA(SE2->E2_VENCREA,.F.,5) 																// Vencimento		 ok
_cCnpj   := SM0->M0_CGC																						// CNPJ 			 ok
_cContr  := SUBSTR(SM0->M0_NOMECOM,1,30)																	// Contribuinte		 ok
_cCodPag := SE2->E2_CODRET         																			// Cod.Pagamento	 ok
//_cCodIof := SE2->E2_CODIOF        																			// Cod.Pagamento IOF ok
_cApura  := GRAVADATA(SE2->E2_EMISSAO,.F.,5)  		   				   										// Data Apuração	 ok
_cRefer  := "                 "                     			   											// Num. Referencia	 ok

DbSelectArea("SE2")
DbSetOrder(1)
IF RTRIM(SE2->E2_FORNECE) $ "INPS"		//GPS
	_cCnpjGPS 	:= SM0->M0_CGC
	_cContrGPS  := SUBSTR(SM0->M0_NOMECOM,1,30)
	_cCodPagGPS	:= "2100" //_cCodPagGPS := "2631"
EndIf

IF RTRIM(SE2->E2_FORNECE) $ "INPS"		//GPS
	_cReturn := "01"+_cCodPagGPS+_cCompet+_cCnpjGPS+_cValor+_cAux+_cVlMult+_cVlTot+_cDtVen+Space(58)+_cContrGPS
ElseIf RTRIM(SE2->E2_FORNECE) $ "UNIAO" //DARF - PIS/COFINS/CSLL/IR
	_cReturn := "02"+_cCodPag+"2"+_cCnpj+_cApura+_cRefer+_cValor+_cVlMult+_cAux+_cVlTot+_cDtVen+_cDtVen+SPACE(30)+_cContr
Endif

Return(_cReturn)