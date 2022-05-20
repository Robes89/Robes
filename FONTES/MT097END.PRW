#Include 'PROTHEUS.CH'

/*/{Protheus.doc} MT097END
P.E. utilizado para acionar o processo de workflow apos a gravacao da liberacao de documentos, 
quando feito fora da rotina de workflow

@type  	Function
@author Mauro Paladini
@since 	27/01/2020
/*/


User Function MT097END()

Local cWFPCAuto := SuperGetMV('ES_WFPCAUT',, '1')
Local cNumPC    := PadR(PARAMIXB[1], Len(SC7->C7_NUM))
Local cTipo     := PARAMIXB[2]
Local nOpc      := PARAMIXB[3]
Local cFilDoc   := PARAMIXB[4]
Local aArea     := GetArea()
Local aAreaSC7  := SC7->(GetArea())

// --------------------------------------------------------------------
// cDocto == Numero do Documento
// cTipo  == Tipo do Documento "PC" | "AE" | "CP"

// Quando o ponto eh acionado pela rotina de Liberação e Superior:
// nOpc == 1 --> Cancela
// nOpc == 2 --> Libera
// nOpc == 3 --> Bloqueia

// Quando o ponto eh acionado pela rotina de Transf. Superior
// nOpc == 1 --> Transfere
// nOpc == 2 --> Cancela
// --------------------------------------------------------------------

If AllTrim(cTipo) == 'PC'
	If ((IsInCallStack('A097LIBERA') .Or. IsInCallStack('A097SUPERI')) .And. nOpc == 2) .Or.;
		(IsInCallStack('A097TRANSF') .And. nOpc == 1)
		SC7->(DbSetOrder(1))
		If SC7->(DbSeek(cFildoc+cNumPC))
			If cWFPCAuto == '1' //--Pergunta antes de enviar
				If Aviso('ATENÇÃO', 'Envia processo de Workflow para este pedido?', {'SIM', 'NÃO'}, 2) == 1
					MsgRun('Montando processo de workflow', 'Aguarde...',;
							{|| U_TIBW030Send(cNumPC)})
				ElseIf cWFPCAuto == '2' //--Envia o processo sem perguntar
					MsgRun('Montando processo de workflow', 'Aguarde...',;
						{|| U_TIBW030Send(cNumPC)})
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

//-- Restaura ambiente:
RestArea(aArea)
RestArea(aAreaSC7)

Return