
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MT120GOK
P.E. utilizado para acionar o processo de workflow apos a gravacao do pedido de compras
Faz a gravação do contrato de parceria antes do envio para aprovaçção

@type  	Function
@author Mauro
@since 	27/01/2020
/*/

User Function MT120GOK()

Local aAreas		:= { SC7->(GetArea()) , SA2->(GetArea()) , SB1->(GetArea()) , SC3->(GetArea()) , SB2->(GetArea()) , GetArea() }

Local cWFPCAuto 	:= SuperGetMV('ES_WFPCAUT',, '1')
Local cNumPC    	:= PARAMIXB[1]
Local lInclui   	:= PARAMIXB[2]
Local lAltera   	:= PARAMIXB[3]
Local lExclui   	:= PARAMIXB[4]

// -- Atualiza Informacoes do campo customizado Gera Contrato SN

If Type("cXContrato") == "C"
	IF SC7->( Msseek( xFilial('SC7') + cNumPC ) ) 
		While SC7->( !Eof() .And. C7_FILIAL+C7_NUM == xFilial('SC7')+cNumPC )
			RecLock('SC7',.F.)
				SC7->C7_XCOPARC	:= UPPER(LEFT(cXContrato,1))
			MsUnLock()
			SC7->( DbSkip() )
		End
		AEval(aAreas, {|x| RestArea(x)})
	Endif
Endif


// -- Prepara o envio para a gravação via workflow

If (lInclui .Or. lAltera) .And. !lExclui

	If cWFPCAuto == '1' //--Pergunta antes de enviar
		
		IF SC7->( Msseek( xFilial('SC7') + cNumPC ) ) 
			If Aviso('ATENÇÃO', 'Envia processo de Workflow para este pedido?', {'Sim', 'Não'}, 1) == 1			
				IF SC7->C7_XCOPARC = 'S'
					MsgRun('Preparando Contrato de Parceria', 'Aguarde...'	, {|| u_MtAuto125(cNumPC) } ) 	
				Endif
				MsgRun('Montando processo de workflow'	, 'Aguarde...'	, {|| u_TIBW030Send(cNumPC) } )
			EndIf
		Endif

	ElseIf cWFPCAuto == '2' //--Envia o processo sem perguntar
		
		IF SC7->( Msseek( xFilial('SC7') + cNumPC ) ) 
			IF SC7->C7_XCOPARC = 'S'
				MsgRun('Preparando Contrato de Parceria', 'Aguarde...', {|| u_MtAuto125(cNumPC) } ) 
			Endif
			MsgRun('Montando processo de workflow'	, 'Aguarde...', {|| u_TIBW030Send(cNumPC) } )
		Endif

	EndIf

EndIf

AEval(aAreas, {|x| RestArea(x)})

Return