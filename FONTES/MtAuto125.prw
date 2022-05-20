#INCLUDE 'PROTHEUS.CH'


/*/{Protheus.doc} MtAuto125
Componente gerador de cintratos de Parcerias

@type  	Function
@author Mauro Paladini
@since 	27/01/2020
/*/

User Function MtAuto125( cNumPed )

Local aAreas		:= { SC7->(GetArea()) , SA2->(GetArea()) , SB1->(GetArea()) , SC3->(GetArea()) , SB2->(GetArea()) , GetArea() }
Local cNumSC3		:= GetSxeNum("SC3","C3_NUM",, 1 )	
Local aItem			:= {}
Local nItem			:= 1
Local aCab          := {}
Local aAuxItem      := {}
Local aErro         := {}
Local cMsgErro      := ''
Local aRet          := Array(2)
Local cSeek			:= SC7->( C7_FILIAL + C7_NUM + C7_ITEM + C7_SEQUEN )
Local lRet			:= .T.
Local nX

Private lMsHelpAuto     	:= .T.
Private lMsErroAuto     	:= .F.
Private lAutoErrNoFile		:= .T.

Default cNumPed		:= SC7->C7_NUM


// -- Reposiciona o Pedido caso não esteja no registro
IF SC7->( !Msseek( xFilial('SC7') + cNumPed ) ) 
	Help( ,, "HELP",, "PEDIDO " + cNumPed + "NÃO LOCALIZADO", 1, 0 )
	AEval(aAreas, {|x| RestArea(x)})
	Return
Endif

SA2->( DbSetOrder(1) )
SA2->( DbSeek( xFilial('SA2') + SC7->C7_FORNECE + SC7->C7_LOJA ) )

// -- Efetua montagem do aCab usado para geração de pedido de compra

aCab:={	{	"C3_NUM"		,	cNumSC3				  			,NIL},; // Numero do Pedido
			{"C3_EMISSAO"	,	dDataBase						,NIL},; // Data de Emissao
			{"C3_FORNECE"	,	SA2->A2_COD						,NIL},; // Fornecedor
			{"C3_LOJA"		,	SA2->A2_LOJA					,NIL},; // Loja do Fornecedor
			{"C3_CONTATO"	,	SC7->C7_CONTATO					,NIL},; // Contato
			{"C3_COND"		,	SC7->C7_COND					,NIL},; // Condicao de Pagamento
			{"C3_FILENT"	,	SC7->C7_FILENT					,NIL},; // Filial de Entrega
			{"C3_FRETE"		,	SC7->C7_FRETE					,NIL},; // Frete
			{"C3_MSG"		,	SC7->C7_MSG						,NIL},; // Mensagem
			{"C3_REAJUST"	,	SC7->C7_REAJUST					,NIL},; // Reajuste
			{"C3_MOEDA"		,	1								,NIL}}  // Moeda


// -- Itens

While SC7->( !Eof() .And. C7_FILIAL+C7_NUM == xFilial('SC7')+cNumPed )

		SB1->( DbSetOrder(1) ) 
		SB1->( Msseek( xFilial('SB1')  + SC7->C7_PRODUTO ) )

		// -- Avalia campos condicionais para geracao do contrato
		Av125Prod( SB1->B1_COD )

		aAuxItem	:= {}
		aAdd( aAuxItem	,{"C3_ITEM"			,SC7->C7_ITEM												,NIL})	//Item
		aAdd( aAuxItem	,{"C3_PRODUTO"		,SC7->C7_PRODUTO											,NIL}) //Produto
		aAdd( aAuxItem	,{"C3_DESCRI"		,SC7->C7_DESCRI												,NIL}) //Descricao
		aAdd( aAuxItem	,{"C3_QUANT"		,SC7->C7_QUANT												,NIL}) //Quantidade
		aAdd( aAuxItem	,{"C3_UM"			,SB1->B1_UM													,NIL}) //Unidade de Medida
		aAdd( aAuxItem	,{"C3_PRECO"		,SC7->C7_PRECO												,NIL}) //Preco unitario
		aAdd( aAuxItem	,{"C3_TOTAL"		,SC7->C7_TOTAL												,NIL}) //Valor total
		aAdd( aAuxItem	,{"C3_LOCAL"		,SC7->C7_LOCAL												,NIL}) //Local
		aAdd( aAuxItem	,{"C3_DATPRI"		,dDataBase 											    	,NIL}) //Local
		aAdd( aAuxItem	,{"C3_DATPRF"		,IIF( EMPTY(SC7->C7_DATPRF) , dDataBase , SC7->C7_DATPRF ) 	,NIL}) //Local
		aAdd( aAuxItem	,{"C3_CONTA"		,SC7->C7_CONTA												,NIL}) //Conta
		aAdd( aAuxItem	,{"C3_CC"			,SC7->C7_CC													,NIL}) //Centro de custo
		aAdd( aAuxItem	,{"C3_ITEMCTA"		,SC7->C7_ITEMCTA											,NIL}) //Item de conta
		aAdd( aAuxItem	,{"C3_XPEDORI"		,SC7->C7_NUM												,NIL}) //Item de conta
		aAdd( aItem , aAuxItem )

		SC7->( DbSkip() )

End

MSExecAuto({|v,x,y,z,w,a| MATA125(v,x,y,z,w,a)},aCab,aItem,3,Nil,Nil)     

If lMsErroAuto

		aErro 		:= GetAutoGRLog() 
		cMsgErro	:= ""
		
		For nX := 1 To Len(aErro)			
			cMsgErro += alltrim(aErro[nX])+Chr(13)+Chr(10)			
		Next nX 
		
		cMsgErro := StrTran(cMsgErro,"<","")
		cMsgErro := StrTran(cMsgErro,">","") + CRLF

		aRet[1]	:= .F.
		aRet[2]	:= cMsgErro

		Alert( cMsgErro )

Else

		ConfirmSX8()
		aRet[1]	:= .T.
		aRet[2]	:= cNumSC3

		// -- Atualiza Referencia no Pedido para identifivcar qual foi o 
		// -- contrato de parceria gerado

		IF SC7->( Msseek( xFilial('SC7') + cNumPed ) ) 
			While SC7->( !Eof() .And. C7_FILIAL+C7_NUM == xFilial('SC7')+cNumPed )
				RecLock('SC7',.F.)
					SC7->C7_XNOCPAR	:= cNumSC3
				MsUnLock()
				SC7->( DbSkip() )
			End

		Endif

Endif

AEval(aAreas, {|x| RestArea(x)})

Return






/*/{Protheus.doc} Av125Prod
Avalia o produto em questão para a geração do contrato de parceria

@type  	Function
@author Mauro Paladini
@since 	27/01/2020
/*/

Static Function Av125Prod( cCodProduto )

Local aAreas	:= { SB1->(GetArea()) , GetArea() }

Default cCodProduto	:= ''

SB1->( DbSetOrder(1) )
IF SB1->( MsSeek( xFilial('SB1') + cCodProduto ) )

	IF SB1->B1_CONTRAT == 'N'
		RecLock('SB1',.F.)
			SB1->B1_CONTRAT	:= 'A'
		MsUnLock()
	Endif

Endif

AEval(aAreas, {|x| RestArea(x)})

Return
