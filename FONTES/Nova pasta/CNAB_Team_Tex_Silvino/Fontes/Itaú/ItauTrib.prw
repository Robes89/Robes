#Include "ProtDef.ch"
#Include "RWMake.ch" 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ITAUTRIB  ºAutor  ³smartins		     º Data ³  02/26/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  CNAB SISPAG - Banco Itau - Pagamento de Tributos Seg. N   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CreditBR								                      º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function ITAUTRIB()                      

Local _cRet := ""

If SEA->EA_MODELO $ "17" //Pagamento GPS
	_cRet := "01"															//Codigo do tributo / pos. 018-019
	_cRet += Substr(SE2->E2_CODRET,1,4)								   		//Codigo do pagamento / pos. 020-023	
	_cRet += Strzero(Val(SE2->E2_XCOMPET),6)								//Competencia / pos. 024-029
	_cRet += PadL(Alltrim(SM0->M0_CGC),14,"0")								//Identificação do Contribuinte - CNPJ/CEI/CPF / 030-043
	_cRet += Strzero(SE2->E2_XVLINSS*100,14)								//Valor de pagamento do INSS / 044-057
	_cRet += Strzero(SE2->E2_XOUTENT*100,14)								//Valor Outras Entidades/ 058-071
	_cRet += Repl("0",14)													//Atualização monetaria /	072-085
	_cRet += Strzero(SE2->E2_SALDO*100,14)									//Valor total arrecadado / 086-099
	_cRet += Strzero(day(SEA->EA_DATABOR),2) + Strzero(Month(SEA->EA_DATABOR),2) + Strzero(Year(SEA->EA_DATABOR),4)//Data de pagamento  / 100-107
	_cRet += Space(08)														//Brancos / 108-115
	_cRet += Space(50)														//Uso da empresa / 116-165
	_cRet += Substr(SM0->M0_NOMECOM,1,30)									//Nome do Contribuinte / 166-195
ElseIf SEA->EA_MODELO $ "16" //Pagamento de Darf Normal
	_cRet := "02"															//Codigo do tributo / pos. 018-019	
	_cRet += Substr(SE2->E2_CODRET,1,4)										//Codigo do pagamento / pos. 020-023		
	_cRet += "2"															//Tipo de Inscr. Contribuinte / pos. 024-024
	_cRet += PadL(Alltrim(SM0->M0_CGC),14,"0")								//Identificação do Contribuinte - CNPJ/CGC/CPF / 025-038
	_cRet += StrZero(Day(SE2->E2_XAPURAC),2) + Strzero(Month(SE2->E2_XAPURAC),2) + Str(Year(SE2->E2_XAPURAC),4) //Competencia / 039-046
	_cRet += Iif(Empty(SE2->E2_XESNREF),Strzero(0,17),Strzero(SE2->E2_XESNREF,17))	//Numero de referencia / 047-063	
	_cRet += Strzero(SE2->E2_SALDO*100,14)									//Valor Principal / 064-077
	_cRet += Strzero(SE2->E2_MULTA*100,14)									//Valor da Multa / 078-091
	_cRet += Strzero((SE2->E2_JUROS+SE2->E2_ACRESC)*100,14)					//Valor de Juros+Encargos / 092-105
	_cRet += Strzero((SE2->E2_SALDO+SE2->E2_MULTA+SE2->E2_JUROS+SE2->E2_ACRESC)*100,14)//Valor total arrecadado / 106-119
	_cRet += StrZero(Day(SE2->E2_VENCREA),2) + Strzero(Month(SE2->E2_VENCREA),2) + Str(Year(SE2->E2_VENCREA),4)//Data de Vencimento / 120-127
	_cRet += Strzero(day(SEA->EA_DATABOR),2) + Strzero(Month(SEA->EA_DATABOR),2) + Strzero(Year(SEA->EA_DATABOR),4)//Data de pagamento  / 128-135
	_cRet += Space(30)		                              					// Brancos / 136-165
	_cRet += Substr(SM0->M0_NOMECOM,1,30)									//Nome do Contribuinte / 166-195	
ElseIf SEA->EA_MODELO $ "18"//Pagamento de Darf Simples
	_cRet := "03"															//Codigo do tributo / pos. 018-019	
	_cRet += Substr(SE2->E2_CODRET  ,1,4)									//Codigo do pagamento / pos. 020-023		
	_cRet += "2"															//Tipo de Inscr. Contribuinte / pos. 024-024
	_cRet += PadL(Alltrim(SM0->M0_CGC),14,"0")								//Identificação do Contribuinte - CNPJ/CGC/CPF / 025-038
	_cRet += Strzero(Day(SE2->E2_XAPURAC),2) + Strzero(Month(SE2->E2_XAPURAC),2) + Str(Year(SE2->E2_XAPURAC),4) //Competencia / 039-046
	_cRet += Strzero(SE2->E2_XESVRBA*100,9)									//Valor da receita bruta acumulada / 047-055
	_cRet += Strzero(SE2->E2_XESPRB,4)										//Percentual da receita Bruta / 056-059
	_cRet += Space(04)														//Brancos / 060-063	
	_cRet += Strzero(SE2->E2_SALDO*100,14)									//Valor Principal / 064-077
	_cRet += Strzero(SE2->E2_MULTA*100,14)									//Valor da Multa / 078-091
	_cRet += Strzero((SE2->E2_JUROS+SE2->E2_ACRESC)*100,14)					//Valor de Juros+Encargos / 092-105
	_cRet += Strzero((SE2->E2_SALDO+SE2->E2_MULTA+SE2->E2_JUROS+SE2->E2_ACRESC)*100,14)	//Valor total arrecadado / 106-119
	_cRet += Strzero(Day(SE2->E2_VENCREA),2) + Strzero(Month(SE2->E2_VENCREA),2) + Str(Year(SE2->E2_VENCREA),4)//Data de Vencimento / 120-127
	_cRet += Strzero(day(SEA->EA_DATABOR),2) + Strzero(Month(SEA->EA_DATABOR),2) + Strzero(Year(SEA->EA_DATABOR),4)//Data de pagamento  / 128-135
	_cRet += Space(30)		                              					// Brancos / 136-165
	_cRet += Substr(SM0->M0_NOMECOM,1,30)									//Nome do Contribuinte / 166-195	
ElseIf SEA->EA_MODELO $ "21" // Pagamento de DARJ
	_cRet := "03"															//Codigo do tributo / pos. 018-019	
	_cRet += Substr(SE2->E2_CODRET  ,1,4)									//Codigo do pagamento / pos. 020-023		
	_cRet += "2"															//Tipo de Inscr. Contribuinte / pos. 024-024
	_cRet += PadL(Alltrim(SM0->M0_CGC),14,"0")								//Identificação do Contribuinte - CNPJ/CGC/CPF / 025-038
	_cRet += PadL(Alltrim(SM0->M0_INSC),8,"0")								//Identificação do Contribuinte - IE / 039-046
	_cRet += Strzero(SE2->E2_XESNORI,16)									//Numero do documento de origem / 047-062
	_cRet += Space(01)														//Branco / 063-063
	_cRet += Strzero(SE2->E2_SALDO*100,14)									//Valor de pagamento do INSS / 064-077
	_cRet += Strzero(SE2->E2_ACRESC*100,14)									//Valor somado ao valor do documento / 078-091
	_cRet += Strzero(SE2->E2_JUROS*100,14)									//Valor de Juros+Encargos / 092-105	
	_cRet += Strzero(SE2->E2_MULTA*100,14)									//Valor da Multa / 106-119
	_cRet += Strzero((SE2->E2_SALDO+SE2->E2_MULTA+SE2->E2_JUROS+SE2->E2_ACRESC)*100,14)	//Valor total arrecadado / 120-133
	_cRet += Strzero(Day(SE2->E2_VENCREA),2) + Strzero(Month(SE2->E2_VENCREA),2) + Str(Year(SE2->E2_VENCREA),4)//Data de Vencimento / 134-141
	_cRet += Strzero(day(SEA->EA_DATABOR),2) + Strzero(Month(SEA->EA_DATABOR),2) + Strzero(Year(SEA->EA_DATABOR),4)//Data de pagamento  / 142-149
	_cRet += Strzero(VAL(SE2->E2_XCOMPET),6)								//Competencia / pos. 150-155
	_cRet += Space(10)		                              					// Brancos / 156-165
	_cRet += Substr(SM0->M0_NOMECOM,1,30)									//Nome do Contribuinte / 166-195	
ElseIf SEA->EA_MODELO $ "22" //Pagamento de Gare-SP (ICMS/DR/ITCMD)
	_cRet := "05"															//Codigo do tributo / pos. 018-019	
	_cRet += Substr(SE2->E2_CODRET  ,1,4)									//Codigo do pagamento / pos. 020-023		
	_cRet += "2"															//Tipo de Inscr. Contribuinte / pos. 024-024
	_cRet += PadL(Alltrim(SM0->M0_CGC),14,"0")								//Identificação do Contribuinte - CNPJ/CGC/CPF / 025-038
	_cRet += PadL(Alltrim(SM0->M0_INSC),12,"0")								//Identificação do Contribuinte - IE / 039-050
	_cRet += Strzero(SE2->E2_XESCDA,13)										//Numero da divida ativa / 051-063
	_cRet += Strzero(Val(SE2->E2_XCOMPET),6)								//Competencia / pos. 064-069
	_cRet += Strzero(SE2->E2_XESNPN,13)										//Numero da parcela / 070-082
	_cRet += Strzero(SE2->E2_SALDO*100,14)									//Valor de pagamento / 083-091
	_cRet += Strzero((SE2->E2_JUROS+SE2->E2_ACRESC)*100,14)					//Valor de Juros+Encargos / 092-096
	_cRet += Strzero(SE2->E2_MULTA*100,14)									//Valor da Multa / 097-110
	_cRet += Strzero((SE2->E2_SALDO+SE2->E2_MULTA+SE2->E2_JUROS+SE2->E2_ACRESC)*100,14)	//Valor total arrecadado / 111-124
	_cRet += Strzero(Day(SE2->E2_VENCREA),2) + Strzero(Month(SE2->E2_VENCREA),2) + Str(Year(SE2->E2_VENCREA),4)//Data de Vencimento / 139-146
	_cRet += Strzero(day(SEA->EA_DATABOR),2) + Strzero(Month(SEA->EA_DATABOR),2) + Strzero(Year(SEA->EA_DATABOR),4)//Data de pagamento  / 147-154
	_cRet += Space(11)		                              					// Brancos / 155-165
	_cRet += Substr(SM0->M0_NOMECOM,1,30)									//Nome do Contribuinte / 166-195	
ElseIf SEA->EA_MODELO $ "35" // Pagamento de FGTS c/ Codigo de Barras
	_cRet := "11"															//Codigo do tributo / pos. 018-019	
	_cRet += PadL(Alltrim(SE2->E2_CODRET),4,"0")							//Codigo do pagamento / pos. 020-023		
	_cRet += "1"															//Tipo de Inscr. Contribuinte / pos. 024-024
	_cRet += PadL(Alltrim(SM0->M0_CGC),14,"0")								//Identificação do Contribuinte - CNPJ/CGC/CPF / 025-038
	_cRet += Substr(SE2->E2_CODBAR,1,48)									//Codigo de Barras / 039-086
   	_cRet += Space(04)                                                      //Espaço
	_cRet += Strzero(SE2->E2_XESNFGT,16)									//Ident. do FGTS / 087-102
	_cRet += Strzero(SE2->E2_XESLACR,9)										//Lacre do FGTS / 103-111
	_cRet += Strzero(SE2->E2_XESDGLA,2)										//DG Lacre do FGTS / 112-113
	_cRet += Substr(SM0->M0_NOMECOM,1,30)									//Nome do Contribuinte / 114-143
	_cRet += Strzero(day(SEA->EA_DATABOR),2) + Strzero(Month(SEA->EA_DATABOR),2) + Strzero(Year(SEA->EA_DATABOR),4)//Data de pagamento  / 144-151
	_cRet += Strzero(SE2->E2_SALDO*100,14)									//Valor de pagamento / 152-165
	_cRet += Space(30)		                              					// Brancos / 166-195
EndIf

Return(_cRet)
