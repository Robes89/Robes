
/*/{Protheus.doc} OABWSE01
Envio de títulos para cartório
@author Juliano Souza TRIYO
@since 24/03/2021
@revision Juliano Souza TRIYO
@date 25/05/2021
/*/
User Function CFGLOTE()	
    // Backup Variaveis Publicas Padrao.

    Local cTitle       := "Manuten��o de Border�"

    // Novo Controle Mestre das Variaveis Publicas Padrao.
    Private bFiltraBrw := {}
    Private Inclui     := .F. //defino que a inclus�o � falsa
    Private Altera     := .T. //defino que a altera��o � verdadeira
    Private nOpca      := 2   //obrigatoriamente passo a variavel nOpca com o conteudo 1
    Private cCadastro  := cTitle //obrigatoriamente preciso definir com private a vari�vel cCadastro
    Private aRotina    := {} //obrigatoriamente preciso definir a variavel aRotina como private

	FWMsgRun(,{|| CFGLOTE()}, "Aguarde...", "Alternando Interface para Manuten��o de Border�s...")

    // Restore

    
Return

/*/{Protheus.doc} CFGLOTE
(long_description) Ponto de entrada para a inclusão de nova opção 'envio para cartório' na tela de borderô
@type  Static Function
@author Juliano Souza 
@since date 08/21
@version version 12.1.25
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references) FINA590
/*/
Static Function CFGLOTE()
    Local aArea        := GetArea()
    Local cNumBor      := Space(TAMSX3("E2_NUMBOR")[1])
    Local cFiltro      := ""
    Local aIndex       := {}
    Local lOk          := .F.
    Local aPergs        := {}

	//Adiciona os parametros para a pergunta
	aAdd(aPergs, {1, "Num. Border�",   cNumBor, "", ".T.", "SEA", ".T.", 80, .T.})
		
	//Mostra uma pergunta com parambox para filtrar o subgrupo
	If ParamBox(aPergs, "Informe os par�metros - " + cCadastro, , , , , , , , , .F., .F.)
		lOk := .T.
		cNumBor := Alltrim(cValToChar(MV_PAR01))
	Endif
    If lOk
        DbSelectArea("SEA")
        SEA->(DbSetOrder(1))
        SEA->(DbGoTop())
        If SEA->(DbSeek(xFilial("SEA")+cNumBor))
            cAlias      := "SEA"
            cFiltro     := "EA_NUMBOR == '"+cNumBor+"'"
            bFiltraBrw  := { || FilBrowse( "SEA" , @aIndex , @cFiltro ) } //Determina a Expressao do Filtro
            Eval( bFiltraBrw ) //Efetiva o Filtro antes da Chamada a mBrowse	
            FINA060()
            EndFilBrw( "SEA" , @aIndex ) //Finaliza o Filtro	
        Else
            Alert("N�o foi possivel posicionar Border� para manuten��o...")
        Endif
		ApMsgInfo("Processo finalizado com sucesso!")
	else
		Alert("Processo abortado...")
    Endif

    RestArea(aArea)
    
Return Nil
