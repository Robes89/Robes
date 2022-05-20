#include 'protheus.ch'
#include 'parmtype.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXMSGNFS   บAutor  ณLUIZ F DAIBERT      บ Data ณ  25/04/20   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPreencher mensagem para notas NFe e NFSe                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Pontos de entrada M460FIM            E                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function XMSGNFS()

	Local lPipe		:= (Funname() <> "MATA916") // Se nใo for a impressao da Nota de Servico, a mensagem deve ser encaminhada com PIPE para a prefeitura
	Local cMsgNf	:= ""
	Local cMsgNot	:= Alltrim(GetAdvFVal("SC5","C5_MENNOTA",xFilial("SC5")+SD2->D2_PEDIDO,1))	
	Local cMsgPad	:= Alltrim(Formula(GetAdvFVal("SC5","C5_MENPAD",xFilial("SC5")+SD2->D2_PEDIDO,1)))
	Local cDDDFone	:= Alltrim(Posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_DDD"))
 	Local cFone		:= Alltrim(Posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_TEL"))
 	Local cEmail	:= Alltrim(Posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_EMAIL"))
 	//Local aDadosCli := Alltrim(GetAdvFVal("SA1",{ "A1_DDD", "A1_TEL", "A1_EMAIL"},xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,1,{ "", "", "" }))
 	Local cPedEco	:= Alltrim(GetAdvFVal("SC5","C5_XPEDECO",xFilial("SC5")+SD2->D2_PEDIDO,1))
    Local cMsgDig	:= Alltrim(GetAdvFVal("SC5","C5_XMSGNFS" ,xFilial("SC5")+SD2->D2_PEDIDO,1))
    
	//cMsgNF += (AllTrim(GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+SD2->D2_COD,1)))+"|" 								   							// Descri็ใo do servi็o
  	//cMsgNF += "Dt. Vencimento: "+DTOC(cDtVenc)+"|"
  	//cMsgNF += cMsgPad+"|"
  	If !Empty (cMsgNot)  
  	cMsgNF += cMsgNot+"|"
  	EndIf
  	   
  	If !Empty (cMsgPad) .And. cFilAnt == '0101' 
  	cMsgNF += cMsgPad+"|"
  	EndIf
  	
  	If !Empty (cMsgDig)
 	cMsgNF += cMsgDig+"|"
 	EndIf
 	
	If !Empty (cFone)
	cMsgNF += "Contato: ("+(cDDDFone)+")"+(cFone)+"|"
	EndIf     
	
	If !Empty (cEmail)
	cMsgNF += cEmail+"|"
	EndIf  
	
	If !Empty (cPedEco)
	cMsgNF += "Pedido: " +(cPedEco)+"|"	
   	EndIf
   	
	RecLock("SC5",.F.)
		SC5->C5_XMSGNFS := cMsgNF
	SC5->(MsUnLock())

Return cMsgNf