#INCLUDE "RWMAKE.CH"   
#INCLUDE "MATA410.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"       
#INCLUDE "FWADAPTEREAI.CH"     
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMDEF.CH"

#DEFINE ITENSSC6 300                          

Static aAdianta  := ProtCfgAdt()
Static lAdtCompart:= aAdianta[1,5] .And. 'C' $ aAdianta[1,1]+aAdianta[1,2]+aAdianta[1,3]

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A410VldTOk  ³ Autor ³Eduardo Riera        ³ Data ³01/06/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de validacao da tudoOk da Enchoice                   ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1: Dados validos?                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Esta rotina efetua a validacao da TudoOk da Enchoice        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA410                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			                 ATUALIZACOES SOFRIDAS						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³LuisEnríquez³17/07/18³DMINA-  ³Se replica funcionalidad atendida en    ³±±
±±³(PER)       ³        ³3630    ³DMINA-62 de Facturación de Anticipos.   ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A410VldTOk(nOpc, aRecnoSE1RA)

Local lRet     		:= .T.
Local lMt410TOK 	:= Existblock("MT410TOK")  
Local lDclNew		:= SuperGetMv("MV_DCLNEW",.F.,.F.)  
Local cString		:= If( nOpc == 4, STR0141, STR0142)	//"Este Documento não poderá ser alterado pois existe um vinculo com pedido de compras ja recebido"
             		                                    //"Este Documento não poderá ser excluido pois existe um vinculo com pedido de compras ja recebido"
Local aRecnoSE1		:= {}
Local lCliRem		:= SC5->(ColumnPos("C5_CLIREM")) > 0 .And. SC5->(ColumnPos("C5_LOJAREM")) > 0
Local lCliRet		:= SC5->(ColumnPos("C5_CLIRET")) > 0 .And. SC5->(ColumnPos("C5_LOJARET")) > 0
Local lUsaAdiSC5	:= .F.
Local lUsaAdiMem	:= .F.

Default aRecnoSE1RA := {}

If cPaisLoc=="ARG" .And. lRet
	SA1->(DbSetOrder(1))
	If( SA1->(DbSeek(xFilial("SA1") + M->C5_CLIENTE+M->C5_LOJACLI))  .And.  M->C5_PAISENT <> SA1->A1_PAIS) .And. ;
	  (Empty(M->C5_IDIOMA) .OR.  Empty(M->C5_INCOTER) .OR.  Empty(M->C5_TPVENT) .OR.  Empty(M->C5_PAISENT))
		MsgStop(STR0143,STR0140)
		lRet := .F.
	EndIf
EndIf                   
If !__lPyme

	//
	// Template GEM
	//	
	If lRet 
		If ExistBlock("GMCVndVLD")
			lRet := ExecBlock("GMCVndVLD",.F.,.F.,{ lRet ,aHeader ,aCols ,aGEMCVnd })
		ElseIf ExistTemplate("GMCVndVLD",,.T.)
			//
			// executa a validacao da condicao de venda
			//
			lRet := ExecTemplate("GMCVndVLD",.F.,.F.,{ lRet ,aHeader ,aCols ,aGEMCVnd })
		Endif	

	EndIf

Endif

If ( ( nOpc == 3 .Or. nOpc == 4 ) .And. M->C5_TIPO == "D" .And. M->C5_MOEDA <> 1 )    
	lRet := .F.
	//"Moeda inválida para pedido do tipo de Devolução de Compras"
	//"Altere o campo Moeda para moeda corrente do sistema."
	Help("",1,"MT410TOK",,STR0343,1,0,,,,,,{STR0344}) 
EndIf     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para validar ao clicar botao OK          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lMt410TOK
	lRet := Execblock("MT410TOK",.F.,.F.,{nOpc,aRecnoSE1RA})
Endif

//Caso o parâmetro MV_DCLNEW esteja ativo valida se o campo C5_MODANP está preenchido
If lRet .And. lDclNew .AND. Empty(M->C5_MODANP)
	lRet := .F.
	//"Campo obrigatório não preenchido no cabeçalho."
	//"Preencha o campo Modal ANP"
	Help("",1,"410NoAnp",,STR0345,1,0,,,,,,{STR0346}) 
EndIf

If lRet
	lUsaAdiSC5	:= A410UsaAdi(SC5->C5_CONDPAG)	//Verifica se a Condição de Pagamento gravada na base de dados é de Adiantamento
	lUsaAdiMem	:= A410UsaAdi(M->C5_CONDPAG)	//Verifica se a Condição de Pagamento digitada em tela é de Adiantamento
EndIf

//Valida Natureza e Condicao de Pagamento. (Anticipo Mexico)
If lRet .AND. cPaisLoc $ "MEX|PER"
    //Qdo Natureza Compensa Adiantamento nao permite condicao de Pagamento que usa Adiantamento
    //Logo:
    //NF de Adiantamento: Natureza Comp. Adiantamento = SIM e Cond. Pag. Usa Adiant. = NAO
    //NF que usa Adiantamento: Natureza Comp. Adiantamento = Nao e Cond. Pag. Usa Adiant. = SIM
    If a410NatAdi(M->C5_NATUREZ) .AND. lUsaAdiMem
        Aviso(STR0038,STR0178,{STR0040}) //"ATENCAO!"###"Quando a natureza compensar adiantamento não será possivel utilizar condicao de pagamento que usa adiantamentos."###"OK"
        lRet := .F.
    Endif
EndIf

If  lRet .AND. lUsaAdiSC5 .AND. ! lUsaAdiMem
	If Len(aRecnoSE1RA) > 0 
		Help(" ",1,"A410CONDNADT")
		lRet := .F.
	Else
		aRecnoSE1 := FPedAdtPed( "R", { SC5->C5_NUM }, .F. )
		FPedAdtGrv("R", 2, SC5->C5_NUM, aRecnoSE1,,,,IIf(Type("aAdtPC")=="U",Nil,aAdtPC),IIf(Type("nAutoAdt")=="U",Nil,nAutoAdt))
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se há relacionamentos de Adiantamentos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If 	!( cPaisLoc $ "MEX|PER") .AND. lRet .AND. lUsaAdiMem .AND. ( Type("l410Auto") == "U" .OR. !l410Auto ) .AND. Len(aRecnoSE1RA) <= 0
	lRet := MsgYesNo( STR0125 ) // "Não foram relacionados Adiantamentos para este pedido. Deseja prosseguir?"
EndIf

lRet	:= lRet .AND. A410CkClRA(M->C5_CLIENTE, M->C5_LOJACLI, aRecnoSE1RA)	// Verifica se os adiantamentos (RA) associados pertencem ao mesmo cliente / loja do Pedido de Vendas

If lRet .AND. Len(aCols) > 0 .And. Type("INCLUI") == "L" .And. !INCLUI
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe Vinculo com SC6 E SC7, se  ³
	//³houve recebimento do SC7 O sc6 nao podera ser ³
	//³alterado.									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	lRet :=	A410VerISC6(SC5->C5_FILIAL,SC5->C5_NUM ,aCols,aHeader)
	If !lRet 
		Aviso(STR0140,cString,{"Ok"}) //  "ATENÇÃO" | "Este Documento não poderá ser alterado/excluido pois existe um vinculo com pedido de compras ja recebido"				
	EndIf	
EndIf	   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se este pedido possui Orcamentos-DAV em aberto no SIGALOJA		³
//³Se sim, entao exclui todos. Se orcamento ja se tornou uma venda, entao	³
//³bloqueia a alteracao do pedido											³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. nOpc == 4 .AND. cPaisLoc == "BRA" .AND. SuperGetMV("MV_LJPAFEC",,.F.) .AND. LjNfPafEcf(SM0->M0_CGC)
	MsgRun(STR0341,STR0342,{|| lRet := Ma410VlDav(M->C5_NUM)})  //"Verificando DAV relacionado..."##"Aguarde..."
EndIf

//Validações referentes à integração do OMS com o Cockpit Logístico Neolog
If  lRet .And. nOpc == 4 .And. SuperGetMV("MV_CPLINT",.F.,"2") == "1" .And. FindFunction('OMSCPLVlPd')
	lRet := OMSCPLVlPd(4,SC5->C5_NUM,aHeader,aCols)
EndIf

If lRet .And. lCliRem .And. !Empty(M->C5_CLIREM)
	lRet := SA1->( DBSeek( xFilial("SA1") + M->C5_CLIREM + M->C5_LOJAREM ) )
	If !lRet
		Help( " ", 1, "A410CliRem", , STR0369, 1 )	// #"Informe a loja do Cliente de Remessa."
	EndIf
EndIf

If lRet .And. lCliRet .And. !Empty(M->C5_CLIRET)
	lRet := SA1->( DBSeek( xFilial("SA1") + M->C5_CLIRET + M->C5_LOJARET ) )
	If !lRet
		Help( " ", 1, "A410CliRet", , STR0401, 1 )	// #"Informe a loja do Cliente de Retirada."
	EndIf
EndIf

If lRet .And. lCliRem .And. !Empty(M->C5_LOJAREM) .And. Empty(M->C5_CLIREM)
	lRet := .F.
	Help( " ", 1, "A410CliRem", , STR0402, 1 )	// #"Informe o código do Cliente de Remessa."
EndIf

If lRet .And. lCliRet .And. !Empty(M->C5_LOJARET) .And. Empty(M->C5_CLIRET)
	lRet := .F.
	Help( " ", 1, "A410CliRet", , STR0403, 1 )	// #"Informe o código do Cliente de Retirada."
EndIf

Return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} A410CkClRA
@description Verifica se os adiantamentos (RA) associados pertencem ao mesmo cliente / loja do Pedido de Vendas  
@sample 	A410CkClRA(cCliente, cLoja, aRecnoSE1RA)
@param		cCliente: Código do Cliente
@param 		cLoja: Loja do Cliente
@param 		aRecnoSE1RA: Títulos RA do Cliente/Loja vinculados ao Pedido de Vendas
@return   	lRet - Retorno lógico
@author	Vendas CRM
@since		Maio/2018
@version	12
/*/
//------------------------------------------------------------------------------
Static Function A410CkClRA(cCliente, cLoja, aRecnoSE1RA)

Local aArea		:= {}
Local aAreaSE1	:= {}
Local lRet			:= .T.

Default cCliente		:= Space(GetSX3Cache("C5_CLIENTE","X3_TAMANHO"))
Default cLoja			:= Space(GetSX3Cache("C5_LOJACLI","X3_TAMANHO"))
Default aRecnoSE1RA	:= {}

If	! Empty(cCliente) .AND. ! Empty(cLoja) .AND. Len(aRecnoSE1RA) > 0
	aArea		:= (Alias())->(GetArea())
	aAreaSE1	:= SE1->(GetArea()) 
	SE1->(DbGoTo(aRecnoSE1RA[01][02]))
	If SE1->E1_CLIENTE <> cCliente .OR. SE1->E1_LOJA <> cLoja
		Help("",1,"A410CkClRA",,STR0339,1,0,,,,,,{STR0340})	//"Não é possível alterar o cliente/loja do Pedido de Vendas, pois o mesmo possui adiantamentos (RA) vinculados."##"Desvincule os adiantamentos antes de alterar o cliente/loja do Pedido de Vendas."
		lRet	:= .F.
	EndIf
	RestArea(aAreaSE1)
	RestArea(aArea)
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ma410VldUs³ Autor ³ Henry Fila            ³ Data ³17/03/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tratamento da confirmacao / nao confirmacao da inclusao    ³±±
±±³          ³ ou alteracao                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1 := Ma410VldUs( ExpN1 )                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 -> Opcao : 1 -> Confirma / 0 -> Nao Confirma         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 -> Validacao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ma410VldUs( nOpca )

Local lRet := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz a chamada do ponto passando nOpca como parametro ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "MA410VLD" )
	lRet := ExecBlock( "MA410VLD", .F., .F., { nOpca } )
EndIf
Return( lRet )       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |A410VldGCTºAutor  ³Microsiga           º Data ³  31/07/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida se o contrato possui alcada. Em caso positivo alertaº±±
±±º          ³ e bloqueia, pois devera ter a medicao aprovada.            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA410                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A410VldGCT()

Local lRet := .T.

CN9->(DbSetOrder(1))
CN9->(dbSeek(xFilial("CN9")+&(ReadVar())))
If !Empty(CN1->(ColumnPos("CN1_GRPAPR"))) .And. SuperGetMV("MV_CNMDALC",.F.,"N") == "S"
	CN1->(dbSetOrder(1))
	CN1->(dbSeek(xFilial("CN1")+CN9->CN9_TPCTO))
	If !Empty(CN1->CN1_GRPAPR)
		Aviso(STR0127,STR0132,{"Ok"}) //SIGAGCT - Este contrato possui controle de alçadas e por isto exige a prévia inclusão de medições.
		lRet := .F.
	EndIf
EndIf                       
If CN1->(dbSeek(xFilial("CN1")+CN9->CN9_TPCTO)) .aND. CN1->CN1_ESPCTR <> '2'
	Aviso(STR0127,STR0158,{"Ok"}) //SIGAGCT - O CONTRATO SELECIONADO NAO E DE VENDA!
	lRet := .F.
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A410UsaAdiºAutor  ³Vendas CRM 		 º Data ³  24/08/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica se a condicao de pagto utiliza Adiantamento.      º±±
±±º          ³                                                       	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA410, FATXFUN                                       	  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/        
Function A410UsaAdi(cCondPagto, cCondPAdt)

Local aAreaSE4		:= {}
Local lRet			:= .F.

Default cCondPAdt	:= "0"

#IFDEF TOP
	If cPaisLoc $ "ANG|BRA|MEX|PER" .AND. !Empty(cCondPagto)
		aAreaSE4 := SE4->(GetArea())
		SE4->(DbSetOrder(1))
		If 	SE4->(DbSeek(xFilial("SE4")+cCondPagto)) .AND. SE4->E4_CTRADT == "1"
			cCondPAdt	:= "1"
			lRet		:= .T.
		EndIf
		RestArea(aAreaSE4)
		aSize(aAreaSE4,0)
	EndIf    
#ENDIF
Return lRet             


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A410NatAdiºAutor  ³Vendas CRM          º Data ³  17/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica se a condicao de pagto utiliza Adiantamento.      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA410, FATXFUN,LOCXNF                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Function a410NatAdi(cNatureza)

Local lRet := .F.

SED->(DbSetOrder(1))
If SED->(MsSeek(XFilial("SED")+cNatureza)) .AND. SED->ED_OPERADT == "1"                           
    lRet := .T.                                      
EndIf
Return lRet  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a410VlAdtCpo ºAutor  ³Microsiga           º Data ³  07/15/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se todos os campos da rotina automatica de adianta   º±±
±±º          ³mento                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a410VlAdtCpo(aAdtPC)

Local lRet := .T.
Local aCpo := {}
Local nX   := 0
Local nPos := 0           
Local nY   := 0
Local cCpoAdt := ""

aAdd(aCpo,"FIE_FILIAL")
aAdd(aCpo,"FIE_PREFIX")
aAdd(aCpo,"FIE_NUM")
aAdd(aCpo,"FIE_PARCEL")
aAdd(aCpo,"FIE_TIPO")
aAdd(aCpo,"FIE_VALOR")
aAdd(aCpo,"FIE_CART")
aAdd(aCpo,"FIE_CLIENT")
aAdd(aCpo,"FIE_LOJA")

For nX := 1 to Len(aAdtPC)
	For nY := 1 to Len(aCpo)
		nPos := AScan(aAdtPC[nX], { |x| Alltrim(x[1]) == aCpo[nY]} )
		If nPos == 0
			lRet := .F.
			cCpoAdt += aCpo[nY] + " "
		EndIf	
	Next
	If !lRet
		Exit
	EndIf
Next nX

If !lRet 
	Help(" ",1,"A410CPOSADT",,"CAMPOS"+" [ "+cCpoAdt+" ] "+"NAO INFORMADO NA ESTRUTURA!")
EndIf
Return lRet
                                     
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³a410VldAnt³ Autor ³ Vendas e eCRM         ³ Data ³10/01/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Funcao para validacao Antes de Vincular Adiantamentos.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico - .T. ok .F. nao ok                                  ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAFAT - Pedido de Venda                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/             
Function a410VldAnt()

Local lRet := .T.

/* -- Localizacao Mexico
Qdo Natureza é uma Operação de Adiantamento (NF de Anticipo) nao permite condicao de Pagamento que compensa títulos de Adiantamento (RA). 
Logo:
NF de Adiantamento: Natureza Oper. Adiantamento = SIM e Cond. Pag. Usa Adiant. = NÃO
NF Normal compensando títulos de adiantamento: Natureza Oper. Adiantamento = NAO e Cond. Pag. Compensa Adiant. = SIM
*/
If cPaisLoc $ "MEX|PER" 
	If Empty(M->C5_NATUREZ)
		MsgAlert(STR0179) //"Para relacionar adiantamentos é necessário preencher a natureza"
		lRet := .F.
	EndIf				
	If a410NatAdi(M->C5_NATUREZ) .AND. A410UsaAdi(M->C5_CONDPAG)
		MsgAlert(STR0180) //"Quando a natureza for uma operacao de adiantamento não é permitido compensar titulos. A condição de pagamento não deve permitir compensar. Verifique."		
		lRet := .F.
	EndIf
EndIf    	    
Return lRet             

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ a410lCkAdtFR3 ³ Autor ³ Totvs                 ³Data ³ 27/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se houve efetivacao do relacionamento com FIE apos  ³±±
±±³			 ³ emissao da nota fiscal                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³0 - Nenhuma efetivacao                                        ³±±
±±³          ³1 - Foi encontrado efetivacao                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Function a410lCkAdtFR3( cNumPed, nAutoAdt )

Local aAreaFR3	:= {}
Local nRet 		:= 0
Local cFilFIE   := Iif(lAdtCompart,cFilAnt,xFilial("FIE"))
Local bFilFR3   := iIF(lAdtCompart,{|| (FR3->FR3_FILORI == cFilAnt) .Or. Empty(FR3->FR3_FILORI) },{|| .T. })

aAreaFR3	:= FR3->( GetArea() )

If FWSIXUtil():ExistIndex( 'FR3' , '4' )//Existe Indice 8 na tabela FR3
	FR3->( dbSetOrder(4) )
	If FR3->( DbSeek( xFilial('FR3')+ "R" + cNumPed ) )
		While FR3->(! Eof() .And. FR3_FILIAL+FR3_CART+FR3_PEDIDO) == xFilial('FR3') + "R" + cNumPed 
			If Eval(bFilFR3)
				nRet := 1
				Exit
			EndIf
			FR3->(dbSkip())	
		EndDo	
	EndIf
Else
	SIX->(dbSetOrder(1))
	If SIX->(MsSeek("FR34"))
		FR3->( DbsetOrder( 4 ) )
		If FR3->( DbSeek( xFilial( "FR3" ) + "R" + cNumPed ) )
			nRet := 1
		EndIf
	EndIf
EndIf

FR3->(RestArea( aAreaFR3 ))
Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a410ISSCAMARK ºAutor  ³ Vitor Felipe   º Data ³ 29/06/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validar o cancelamento do Pedido de Venda.			      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA410                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a410ISSCAMARK()

Local lRet := .T.

If !Empty(M->C5_NUM)
	dbSelectArea("CE2")
	dbSetOrder(1)
	If CE2->(msSeek(xFilial("CE2")+M->C5_NUM))
		lRet := .F.			
		Alert("Atenção !!! Existem Abatimentos de ISS selecionados. Desmarque a seleção.")	
	EndIF
    CE2->(dbCloseArea())
EndIf
Return(lRet)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³A410LiqPro ³ Autor ³ Marco Aurelio - Mano    ³ Data ³13/06/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Valida relacao entre os campos C5_LIQPRO/C5_TIPOREM e          ³±±
±±³          ³F2_LIQPROD/F2_TIPOREM processo "Liquido Produto".              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A410LiqPro(ExpC1,ExpC2)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1=Alias da tabela do campo a ser validado                  ³±±
±±³          ³ExpC2=Campo a ser validado pela funcao                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Chamada a partir do X3_VALID dos campos C5_LIQPROD, C5_TIPOREM ³±±
±±³          ³F2_LIQPROD e F2_TIPOREM                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/             
Function A410LiqPro() 

Local cVar     := ReadVar()									// Nome da variavel de memoria editada
Local cCampo   := StrTran(cVar,"M->","")					// Nome da campo a ser validado
Local lRet     := .T.										// Conteudo de retorno

If ( 	( cCampo=="C5_LIQPROD" .and. M->C5_LIQPROD == "1" .and. M->C5_TIPOREM # "A" ) .or.; 
		( cCampo=="C5_TIPOREM" .and. M->C5_TIPOREM # "A" .and. M->C5_LIQPROD == "1" ) .or.; 
		( cCampo=="F2_LIQPROD" .and. M->F2_LIQPROD == "1" .and. M->F2_TIPOREM # "A" ) .or.; 
		( cCampo=="F2_TIPOREM" .and. M->F2_TIPOREM # "A" .and. M->F2_LIQPROD == "1" ) ) 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³HELP: Para "Tipo de Remito=Consignacao", campo "Liquido Prod" deve ser preenchido com "Sim" ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
	Help(" ",1,Iif(cCampo$"C5_LIQPROD.F2_LIQPROD","A410LIQPRO","A410TIPREM"))
	lRet := .f.
EndIf
Return(lRet)

                  /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTA410ChkEmit ºAutor  ³VENDAS/CRM      º Data ³  19/03/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para verificar se existe o emitente com o codigo    º±±
±±º          ³ informado. Não foi utilizado a funcao existchav ou existcpoº±±
±±º          ³ para não apresentar a mensagem caso nao encontrado         º±±
±±º          ³                                                            º±±
±±º          ³ Parämetro: cCod - Codigo a verificar                       º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P11                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MTA410ChkEmit(cCod)

Local aArea  := GetArea()
Local lEncontrou := .F.

dbSelectArea("GU3")
dbSetOrder(1)

If DBSeek(xFilial("GU3") + cCod)
	lEncontrou := .T.
EndIf
	 
RestArea(aArea)
Return lEncontrou    


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A410Vend  ³ Autor ³Eduardo Riera          ³ Data ³27.02.99  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao  do  Codigo  do  Vendedor                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Logico                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A410Vend()

Local cCampoGet	 := ReadVar()
Local cConteudo	 := &(ReadVar())  
Local cContra    := M->C5_MDCONTR
Local cFilCtr	 := ""
Local cVendedores:= ""
Local cVend		 := "1"
Local cComissao	 := ""
Local nNumVend	 := Fa440CntVen()
Local nCntFor	 := 0
Local nEndereco	 := 0
Local bVendedor	 := {|x| "M->C5_VEND"+x}
Local lRetorna	 := .T.

cConteudo := If(Empty(cConteudo),"",cConteudo)

dbSelectArea("SA3")
dbSetOrder(1)
If ( !MsSeek(xFilial("SA3")+cConteudo) )
	Help(" ",1,"REGNOIS")
	lRetorna := .F.
Else
	lRetorna := RegistroOk("SA3")
EndIf   

If lRetorna .And. INCLUI .And. !Empty(cContra) .And. !Empty(cConteudo)
	If IsInCallStack('CN120MedEnc') .Or. IsInCallStack('CN121Encerr')
		cFilCtr := POSICIONE("CND",4,xFilial("CND")+M->C5_MDNUMED,"CND_FILCTR")
	Else
		cFilCtr := xFilial("CNU")
	EndIf

	CNU->(dbSetOrder(1))
	If !CNU->(dbSeek(cFilCtr+cContra+cConteudo))
		Aviso(STR0127,STR0129,{"Ok"}) //SIGAGCT - Este pedido foi vinculado a um contrato e este vendedor não consta no mesmo.
		lRetorna := .F.
	EndIf
EndIf

If lRetorna
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Analisa todos os vendedores                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nCntFor := 1 To nNumVend
		If ( !Empty(&(Eval(bVendedor,cVend))) .And. cCampoGet != EVAL(bVendedor,cVend) )
			cVendedores := cVendedores + "\" + &(EVAL(bVendedor,cVend))
		EndIf
		cVend  :=  Soma1(cVend,1)
	Next nCntFor
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida o Vendedor, para nao  permitir duplicacao de codigos             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( cConteudo $ cVendedores )
		Help(" ",1,"VENDED")
		lRetorna	:= .F.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Coloca na tela o percentual da comissao conforme o vendedor   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF ( lRetorna )
	If ( !Empty(cConteudo) )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza comissao       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cVend		 := Substr(cCampoGet,11,1)
		M->&("C5_COMIS"+cVend) := IF(Empty(SA3->A3_COMIS),M->&("C5_COMIS"+cVend),SA3->A3_COMIS)
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Limpa campo de comissao      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cVend		 := Substr(cCampoGet,11,1)
		M->&("C5_COMIS"+cVend) := 0.00
	EndIf
	cComissao :="M->C5_COMIS" + cVend
	cComissao := Substr(cComissao,4,9)
	nEndereco := Ascan(aGets,{ |x| Subs(x,9,9) ==cComissao  } )
	If ( nEndereco > 0 )
		aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := If(!Empty(cConteudo),TransNum("A3_COMIS"),TransNum("C5_COMIS"+cVend))
	EndIf
EndIf

Return(lRetorna)  

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³a410IPIDEV³  Autor³ Claudinei M. Benzi    ³ Data ³ 10.01.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Quando o pedido de venda for devolucao o usuario pode      ³±±
±±³          ³ digitar o valor do ipi                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata410                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A410DevIpi()

If M->C5_TIPO != "D"
	Help(" ",1,"A410DevIpi")
	Return .F.
EndIf
Return .T. 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A410PedFat³ Autor ³ Eduardo Riera         ³ Data ³ 24.02.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se um Pedido Foi Totalmente Faturado              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1: Indica se o Pedido foi faturado                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A410PedFat(cProduto,lVldGrade,nQuantDig,lQtdVen)

Local aArea 	:= GetArea()
Local lRetorno	:= .T.
Local nPItem	:= 0
Local nPProduto	:= 0
Local cItem		:= "" 
Local nTes      := 0
Local cTes      := ""

DEFAULT cProduto  := ""
DEFAULT lVldGrade := .F.
DEFAULT nQuantDig := 0 
DEFAULT lQtdVen	  := .F.	

If (( Altera .And. SuperGetMv("MV_ALTPED")=="N" ) .And. !(SC5->C5_TIPO $ "CIP"))  .And. !(!Empty(SC5->C5_PEDEXP) .And. SuperGetMv("MV_EECFAT").And. AvIntEmb())
	If !lVldGrade
		nPItem		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM"})
		nPProduto	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
		nTes 		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"})
		cItem		:= aCols[n][nPItem]
		cProduto	:= aCols[n][nPProduto]
		cTes 		:= aCols[n][nTes]
	Else
		nPItem 		:= aScan(oGrade:aHeadAux,{|x| AllTrim(x[2])=="C6_ITEM"})
		nPProduto 	:= aScan(oGrade:aHeadAux,{|x| AllTrim(x[2])=="C6_PRODUTO"})
		nTes 		:= aScan(oGrade:aHeadAux,{|x| AllTrim(x[2])=="C6_TES"})
		cItem		:= oGrade:aColsAux[oGrade:nPosLinO][nPItem]
		cTes 		:= oGrade:aColsAux[oGrade:nPosLinO][nTes]
	EndIf  
	
	SF4->(dbSetOrder(1))
	SF4->(dbSeek(xFilial("SF4")+cTes))
		
 	dbSelectArea("SC6")
	dbSetOrder(1)
	If ( MsSeek(xFilial("SC6")+M->C5_NUM+cItem+cProduto) )
		If (lVldGrade) .Or. (!lVldGrade .And. SC6->C6_GRADE <> "S" )
			If ( SC6->C6_QTDENT >= SC6->C6_QTDVEN .And. SF4->F4_QTDZERO <> "1" ) .Or.;
  		 		(SC6->C6_QTDENT == SC6->C6_QTDVEN .AND. SF4->F4_QTDZERO == "1" .AND. !Empty(SC6->C6_NOTA))
				Help(" ",1,"A410PRODFA")
				lRetorno := .F.
			EndIf
			If (lRetorno) .And. (lVldGrade) .And. (lQtdVen) .And. (nQuantDig < SC6->C6_QTDENT)
				Help(" ",1,"A410PEDJFT")	
				lRetorno := .F.			
			EndIf	
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A410ReCalc³ Autor ³ Eduardo Riera         ³ Data ³ 19.02.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Esta funcao corrige os dados entre o cabecalho e a GetDados ³±±
±±³          ³avaliando Desconto, CFOP , Tipo do Pedido e Tabela de Preco ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Sempre .T.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1: Indica se o recalculo eh somente do desconto de cabe ³±±
±±³          ³calho.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³12/11/99  ³ Alves         ³ Quando estiver sendo executada a partir de ³±±
±±³          ³               ³ uma rotina automatica nao deixar sobrescre-³±±
±±³          ³               ³ ver o aCols                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A410ReCalc(lDescCab,lBenefPodT)

Local aArea		:= GetArea()
Local aAreaSX3	:= SX3->(GetArea())
Local aCont    := {}
Local aStruSC6 := {}     
Local aDadosCfo := {}
Local cAliasQry:= ""
Local cAltPreco:= GetNewPar( "MV_ALTPREC", "T" )
Local cCliTab  := ""
Local cLojaTab := ""
Local lAltPreco:= .F.
Local nDesc		:= 0
Local ni		:= 0
Local nTmp	:=	1
Local nx		:= 0
Local nCntFor 	:= 0
Local nPCFOP 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_CF" })
Local nPTes		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"})
Local nPProd	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local nPPrUnit	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRUNIT"})
Local nPPrcVen	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})
Local nPDescon	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_DESCONT"})
Local nPVlDesc	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALDESC"})
Local nPQtdVen	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
Local nPValor	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"})
Local nPLoteCtl	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOTECTL"})
Local nPNumLote	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_NUMLOTE"})
Local nPItem	:= GDFieldPos( "C6_ITEM" )
Local nPGrdQtd	:= 0
Local nPGrdPrc	:= 0
Local nPGrdTot	:= 0
Local nPGrdVDe	:= 0
Local nPGrdPrU	:= 0
Local nVlrTabela:= 0
Local nScan    := 0
Local nLinha	:= 0
Local nColuna	:= 0
Local lGrade	:= MaGrade()
Local lGradeReal:= .F.
Local cProduto	:= ""
Local lCondPg   := (ReadVar()=="M->C5_CONDPAG")
Local lCondTab  := .F. 							// Verifica se a condicao escolhida esta na tabela de precos
Local nDescont	:= 0
Local nDecDesc  := 0
Local lFtRegraDesc := IsInCallStack("FtRegraDesc")	//Para validar se a chamada da função A410ReCalc() está vindo da Regra de Desconto ou do valid do campo
Local lTabCli   := (SuperGetMv("MV_TABCENT",.F.,"2") == "1")
Local lGrdMult  := "MATA410" $ SuperGetMV("MV_GRDMULT",.F.,"")

// Indica se o preco unitario sera arredondado em 0 casas decimais ou nao. Se .T. respeita MV_CENT (Apenas Chile).
Local lPrcDec   := SuperGetMV("MV_PRCDEC",,.F.)

//Tratamento para opcionais
Local lOpcPadrao	:= SuperGetMv("MV_REPGOPC",.F.,"N") == "N"
Local nPOpcional	:= aScan(aHeader,{|x| AllTrim(x[2])==IIf(lOpcPadrao,"C6_OPC","C6_MOPC")})
Local cOpcional		:= ""
Local cOpc			:= ""
Local nVlrOpc		:= 0

DEFAULT lDescCab := GetNewPar("MV_PVRECAL",.F.) //Desabilita o recalculo automatico do Pedido de Venda.
DEFAULT lBenefPodT := .F.

l410Auto := If (Type("l410Auto") == "U", .F., l410Auto)

If Type("lShowOpc") == "L"
	lShowOpc := .T.
EndIf

If !lDescCab .AND. ( At(M->C5_TIPO,"CIP") != 0 )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Zera os descontos caso o Pedido seja de Complemento.          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	M->C5_DESC1 := M->C5_DESC2 := M->C5_DESC3 := M->C5_DESC4 := 0
	For nCntFor := 1 To 4
		nDesc := Ascan(aGets,{ |x| Subs(x,9,10) == "C5_DESC"+Str(nCntFor,1,0)+"  " } )
		If nDesc != 0
			ni := Val(Subs(aGets[nDesc],1,2))
			nx := Val(Subs(aGets[nDesc],3,1))*2
			If Val(aTela[ni][nx]) != 0
				nDecDesc := GetSX3Cache("C5_DESC"+Str(nCntFor,1,0)+"  ","X3_DECIMAL")
				aTela[ni][nx] := Str(0,nDecDesc+3,nDecDesc)
			EndIf
		EndIf
	Next nCntFor
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Corrige o Codigo Fiscal, caso o Cliente tenha sido alterado.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( INCLUI .Or. ALTERA )
	dbSelectArea(IIF(M->C5_TIPO$"DB","SA2","SA1"))
	dbSetOrder(1)
	MsSeek(xFilial()+IIf(!Empty(M->C5_CLIENT),M->C5_CLIENT,M->C5_CLIENTE)+IIf(!Empty(M->C5_LOJAENT),M->C5_LOJAENT,M->C5_LOJACLI))
	
	For nCntFor := 1 to Len(aCols)
		dbSelectArea("SF4")
		dbSetOrder(1)
		If ( MsSeek(xFilial("SF4")+aCols[nCntFor][nPTes],.F.) )
		 	Aadd(aDadosCfo,{"OPERNF","S"})
		 	Aadd(aDadosCfo,{"TPCLIFOR",M->C5_TIPOCLI})
			If At(M->C5_TIPO,"DB") == 0
			 	Aadd(aDadosCfo,{"UFDEST",SA1->A1_EST})
				Aadd(aDadosCfo,{"INSCR" ,SA1->A1_INSCR})				
				Aadd(aDadosCfo,{"CONTR", SA1->A1_CONTRIB})
				Aadd(aDadosCfo,{"FRETE", M->C5_TPFRETE})
			Else
				Aadd(aDadosCfo,{"UFDEST",SA2->A2_EST})	 
				Aadd(aDadosCfo,{"INSCR" ,SA2->A2_INSCR})
			EndIf
			If cPaisLoc != 'RUS'
				aCols[nCntFor][nPCFOP] := MaFisCfo(,SF4->F4_CF,aDadosCfo)
			Else
				aCols[nCntFor][nPCFOP] := MaFisCfo(,aCols[nCntFor][nPCFOP],aDadosCfo)
			EndIf
		EndIf
	Next nCntFor
EndIf

If cAltPreco <> "T"
	
	aCont := {}
	
	#IFDEF TOP
		
		cAliasQry := GetNextAlias()
		
		cQuery := "SELECT C6_NUM, C6_ITEM, C6_QTDENT, C6_QTDEMP FROM " + SC6->( RetSqlName( "SC6" ) ) + " "
		cQuery += "WHERE "
		cQuery += "C6_FILIAL='" + xFilial("SC6") + "' AND "
		cQuery += "C6_NUM='" + M->C5_NUM      + "' AND "
		cQuery += "D_E_L_E_T_=' '"
		
		cQuery := ChangeQuery( cQuery )
		
		dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasQry, .F., .T. )
		
		aStruSC6 := SC6->( dbStruct())
		
		If !Empty( nScan := AScan( aStruSC6, { |x| x[1]=="C6_QTDENT" } ) )
			TcSetField( cAliasQry, aStruSC6[ nScan, 1 ], aStruSC6[ nScan, 2 ], 	aStruSC6[ nScan, 3 ], 	aStruSC6[ nScan, 4 ] )
		EndIf			
		
		If !Empty( nScan := AScan( aStruSC6, { |x| x[1]=="C6_QTDEMP" } ) )
			TcSetField( cAliasQry, aStruSC6[ nScan, 1 ], aStruSC6[ nScan, 2 ], 	aStruSC6[ nScan, 3 ], 	aStruSC6[ nScan, 4 ] )
		EndIf			
		
		While !Eof()
			AAdd( aCont, { C6_NUM + C6_ITEM, C6_QTDENT, C6_QTDEMP  } )
			dbSkip()  					
		EndDo
		
		dbCloseArea()
		
		dbSelectArea( "SC6" )
		
	#ELSE
		
		SC6->( dbSetOrder( 1 ) )
		If SC6->( dbSeek( xFilial( "SC6" ) + M->C5_NUM ) )
			While !SC6->( Eof() ) .And. xFilial( "SC6" ) + M->C5_NUM == SC6->C6_FILIAL + SC6->C6_NUM
				AAdd( aCont, { SC6->C6_NUM + SC6->C6_ITEM, SC6->C6_QTDENT, SC6->C6_QTDEMP  } )
				SC6->( dbSkip() )          	
			EndDo 				
		EndIf
		
	#ENDIF 	 	
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Corrige o preco de tabela e preco unitario p/ tab.alterada    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If (M->C5_TIPO == "N" .And. !("M->C5_CLIENT"==Alltrim(ReadVar()).Or."M->C5_LOJAENT"==ReadVar()) .And. !lBenefPodT  ) .Or.;
	(M->C5_TIPO == "N" .And. lTabCli)
    
	If lCondPg
		dbSelectArea("DA0")
		dbSetOrder(1) 
		If MsSeek(xFilial("DA0")+M->C5_TABELA)
			lCondTab := DA0->DA0_CONDPG == M->C5_CONDPAG
		Endif
	Endif

	nTmp	:=	n
	For nCntFor := 1 to Len(aCols)

		nVlrOpc := 0
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se deve atualizar os precos conforme a regra         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cAltPreco == "T"	
			lAltPreco := .T. 		
		ElseIf  cAltPreco $ "LF"
			lAltPreco := .T. 				
			
			If !Empty( nScan := AScan( aCont, { |x| x[1] == M->C5_NUM + aCols[nCntFor,nPItem] } ) )
				If cAltPreco == "L"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Nao permite itens liberados                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lAltPreco := Empty( aCont[ nScan, 2 ] ) .And. Empty( aCont[ nScan, 3 ] )
				ElseIf cAltPreco == "F"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Nao permite itens faturados                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lAltPreco := Empty( aCont[ nScan, 2 ] )
				EndIf
			EndIf			
		Else
			lAltPreco := .F.
		EndIf 	
		
		If lAltPreco
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se eh grade para calcular o valor total por item da grade³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cProduto	:= aCols[nCntFor][nPProd]
			lGradeReal	:= ( lGrade .And. MatGrdPrrf(@cProduto) )

			If lTabCli
				Do Case
					Case !Empty(M->C5_LOJAENT) .And. !Empty(M->C5_CLIENT)
						cCliTab   := M->C5_CLIENT
						cLojaTab  := M->C5_LOJAENT
					Case Empty(M->C5_CLIENT) 
						cCliTab   := M->C5_CLIENTE
						cLojaTab  := M->C5_LOJAENT
					OtherWise
						cCliTab   := M->C5_CLIENTE
						cLojaTab  := M->C5_LOJACLI
				EndCase					
			Else
				cCliTab   := M->C5_CLIENTE
				cLojaTab  := M->C5_LOJACLI
			Endif
			
			If !lDescCab			
                If !(lGrdMult .And. lGrade .And. lGradeReal)
					nVlrTabela := A410Tabela(	aCols[nCntFor][nPProd],;
												M->C5_TABELA,;
												nCntFor,;
												aCols[nCntFor][nPQtdVen],;
												cCliTab,;
												cLojaTab,;
												If(nPLoteCtl>0,aCols[nCntFor][nPLoteCtl],""),;
												If(nPNumLote>0,aCols[nCntFor][nPNumLote],"")	)
					
				EndIf
			Else
				nVlrTabela := aCols[nCntFor][nPPrUnit]
			EndIf
			
			If !(lGrdMult .And. lGrade .And. lGradeReal)

				If nPOpcional > 0 .And. !Empty(aCols[nCntFor][nPOpcional])
		   			cOpcional := aCols[nCntFor][nPOpcional]
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aqui ‚ efetuado o tratamento diferencial de Precos para os   ³
					//³ Opcionais do Produto.                                        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SGA")
					dbSetOrder(1)					
					While !Empty(cOpcional)
						cOpc      := SubStr(cOpcional,1,At("/",cOpcional)-1)
						cOpcional := SubStr(cOpcional,At("/",cOpcional)+1)
						If ( MsSeek(xFilial("SGA")+cOpc) ) .AND. AT(M->C5_TIPO,"CIP") == 0
							nVlrOpc += SGA->GA_PRCVEN
						EndIf
					EndDo
				EndIf
								   
			   	If lCondPg 
					n	:=	nCntFor
					If ( nPPrcVen > 0 ) .And. ( nVlrTabela <> 0 ) 
								
						nDescont := FtRegraDesc(1)
					  	
						If(lCondTab .And. aPesqDA1(M->C5_TABELA,aCols[nCntFor][nPProd])) .Or.;
							IIf(!lFtRegraDesc, M->C5_DESC4 > 0, M->C5_DESC4 >= 0) .Or. nDescont > 0
							
							aCols[nCntFor][nPPrcVen] := FtDescCab(nVlrTabela,{M->C5_DESC1,M->C5_DESC2,M->C5_DESC3,M->C5_DESC4},If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))
						
							If nVlrOpc > 0
								aCols[nCntFor][nPPrcVen] := (aCols[nCntFor][nPPrcVen] + nVlrOpc)	//Soma o valor do opcional
							EndIf
							aCols[nCntFor][nPValor]  := a410Arred( aCols[nCntFor][nPQtdVen]*aCols[nCntFor][nPPrcVen],"C6_VALOR",If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))
							aCols[nCntFor,nPDescon]  := 0
							aCols[nCntFor,nPVlDesc]  := 0
						
							If ( nPPrUnit > 0 )
							    aCols[nCntFor][nPPrUnit] := nVlrTabela
							EndIf
								
							aCols[nCntFor,nPDescon] := nDescont
							
							If ( nPDescon > 0 .And. nPVlDesc > 0 .And. nPPrcVen > 0 .And. nPValor > 0 .And. nPPrUnit>0 )
								aCols[nCntFor][nPPrcVen] := FtDescItem(If(aCols[nCntFor][nPPrUnit] == 0, aCols[nCntFor][nPPrUnit],@aCols[nCntFor][nPPrcVen]),;				
									@aCols[nCntFor,nPPrcVen],;
									aCols[nCntFor,nPQtdVen],;
									@aCols[nCntFor,nPValor],;
									@aCols[nCntFor,nPDescon],;
									@aCols[nCntFor,nPVlDesc],;
									@aCols[nCntFor,nPVlDesc],1,,If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))
							EndIf
						EndIf					
					EndIf					
				Else					
					If ( nPPrcVen > 0 ) .And. ( nVlrTabela <> 0 )
						aCols[nCntFor][nPPrcVen] := FtDescCab(nVlrTabela,{M->C5_DESC1,M->C5_DESC2,M->C5_DESC3,M->C5_DESC4},If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))
						If nVlrOpc > 0
							aCols[nCntFor][nPPrcVen] := (aCols[nCntFor][nPPrcVen] + nVlrOpc)	//Soma o valor do opcional
						EndIf
					EndIf
					If ( nPPrUnit > 0 )
						aCols[nCntFor][nPPrUnit] := nVlrTabela
					EndIf

					n	:=	nCntFor
					nDescont := FtRegraDesc(1)

					If nDescont > 0	.Or. (nDescont == 0 .And. aCols[nCntFor,nPDescon] > 0)
						aCols[nCntFor,nPDescon] := nDescont
					EndIf

					If ( nPDescon > 0 .And. nPVlDesc > 0 .And. nPPrcVen > 0 .And. nPValor > 0 .And. nPPrUnit>0 )
						aCols[nCntFor][nPPrcVen] := FtDescItem(If(aCols[nCntFor][nPPrUnit] == 0, aCols[nCntFor][nPPrUnit],@aCols[nCntFor][nPPrcVen]),;				
							@aCols[nCntFor,nPPrcVen],;
							aCols[nCntFor,nPQtdVen],;
							@aCols[nCntFor,nPValor],;
							@aCols[nCntFor,nPDescon],;
							@aCols[nCntFor,nPVlDesc],;
							@aCols[nCntFor,nPVlDesc],1,,If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))
					EndIf		
				EndIf
			EndIf
			
			If lGrade .And. lGradeReal .And. Type("oGrade")=="O" .And. Len(oGrade:aColsGrade) > 0
				If !lGrdMult
					aCols[nCntFor,nPValor] := 0
					nPGrdQtd := oGrade:GetFieldGrdPos("C6_QTDVEN")
					For nLinha := 1 To Len(oGrade:aColsGrade[nCntFor])
						For nColuna := 2 To Len(oGrade:aHeadGrade[nCntFor])
							If ( oGrade:aColsGrade[nCntFor,nLinha,nColuna][nPGrdQtd] <> 0 )  
								aCols[nCntFor,nPValor]  += a410Arred( oGrade:aColsGrade[nCntFor,nLinha,nColuna][nPGrdQtd]*aCols[nCntFor,nPPrcVen],"C6_VALOR",If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))
							Endif	
						Next nColuna
					Next nLinha		
				Else
					n	:=	nCntFor
					oGrade:cProdRef := aCols[nCntFor][nPProd]
					oGrade:nPosLinO := n
					aCols[n,nPValor] := 0
					nPGrdQtd := oGrade:GetFieldGrdPos("C6_QTDVEN")
					nPGrdPrc := oGrade:GetFieldGrdPos("C6_PRCVEN")
					nPGrdTot := oGrade:GetFieldGrdPos("C6_VALOR")
					nPGrdVDe := oGrade:GetFieldGrdPos("C6_VALDESC")
					nPGrdPrU := oGrade:GetFieldGrdPos("C6_PRUNIT")
					For nLinha := 1 To Len(oGrade:aColsGrade[n])
						For nColuna := 2 To Len(oGrade:aHeadGrade[n])
							If ( oGrade:aColsGrade[n,nLinha,nColuna,nPGrdQtd] <> 0 )
								nVlrTabela := A410Tabela(oGrade:GetNameProd(,nLinha,nColuna),;
														 M->C5_TABELA,;
														 nCntFor,;
														 oGrade:aColsFieldByName("C6_QTDVEN",,nLinha,nColuna),;
														 cCliTab,;
														 cLojaTab,;
														 ,;
														 ,;
														 ,;
														 ,;
														 ,;
														 oGrade:aColsGrade[n,nLinha,nColuna,oGrade:GetFieldGrdPos("C6_OPC")])
			
								If nVlrTabela <> 0
									oGrade:aColsGrade[n,nLinha,nColuna,nPGrdPrU] := nVlrTabela
									oGrade:aColsGrade[n,nLinha,nColuna,nPGrdPrc] := FtDescCab(nVlrTabela,{M->C5_DESC1,M->C5_DESC2,M->C5_DESC3,M->C5_DESC4},If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))
									oGrade:aColsGrade[n,nLinha,nColuna,nPGrdVDe] := A410Arred((nVlrTabela - oGrade:aColsGrade[n,nLinha,nColuna,nPGrdPrc])*oGrade:aColsGrade[n,nLinha,nColuna,nPGrdQtd],"C6_VALOR")
									oGrade:aColsGrade[n,nLinha,nColuna,nPGrdTot] := A410Arred(oGrade:aColsGrade[n,nLinha,nColuna,nPGrdQtd] * oGrade:aColsGrade[n,nLinha,nColuna,nPGrdPrc],"C6_VALOR")
								EndIf										
							Endif	
						Next nColuna
					Next nLinha		
			
					aCols[n,nPPrcVen] := oGrade:SomaGrade("C6_PRCVEN",n)			
					aCols[n,nPDescon] := FtRegraDesc(1)
			
					If ( nPDescon > 0 .And. nPVlDesc > 0 .And. nPPrcVen > 0 .And. nPValor > 0 .And. nPPrUnit>0 )
						For nLinha := 1 To Len(oGrade:aColsGrade[n])
							For nColuna := 2 To Len(oGrade:aHeadGrade[n])		
								oGrade:aColsGrade[n,nLinha,nColuna,nPGrdPrc] := FtDescItem(0,;				
								                                                           @oGrade:aColsGrade[n,nLinha,nColuna,nPGrdPrc],;
								                                                           oGrade:aColsGrade[n,nLinha,nColuna,nPGrdQtd],;
								                                                           @oGrade:aColsGrade[n,nLinha,nColuna,nPGrdTot],;
								                                                           @aCols[nCntFor,nPDescon],;
								                                                           @oGrade:aColsGrade[n,nLinha,nColuna,nPGrdVDe],;
								                                                           0,1,,If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))
							Next nColuna
						Next nLinha
					EndIf
					aCols[n,nPPrcVen] := oGrade:SomaGrade("C6_PRCVEN",n)
					aCols[n,nPValor] := oGrade:SomaGrade("C6_VALOR",n)
					aCols[n,nPVlDesc] := oGrade:SomaGrade("C6_VALDESC",n)
				EndIf
			EndIf
		EndIf 	
		
	Next nCntFor
	n	:=	nTmp
EndIf
//Atualiza desconto financeiro se informado pelo cabecalho do pedido de vendas.
If ("M->C5_CONDPAG" $ ReadVar()) .AND. M->C5_DESCFI <> SE4->E4_DESCFIN 
	M->C5_DESCFI := SE4->E4_DESCFIN
Endif

If Type('oGetDad:oBrowse')<>"U"
	oGetDad:oBrowse:Refresh()
	Ma410Rodap()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna o estado de entrada da rotina                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaSX3)
RestArea(aArea)
Return(.T.)   

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³A410Titulo³ Autor ³ Jose Lucas		 	³ Data ³ 25/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica o Tipo do titulo informado (Argentina...).		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A410Titulo() 							 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ MATA410													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A410Titulo(cCampo)

Local lRet := .T.
Local cSavAreaCur := Alias()

If cCampo == NIL
	cCampo := &(ReadVar())
EndIf

dbSelectArea("SX5")
dbSetOrder(1)
If MsSeek( xFilial("SX5")+"05"+cCampo )
	If M->C5_TIPO == "D" .AND. Empty(cCampo)
		lRet := .F.
	EndIf
Else
	lRet := .F.
EndIf
If ! lRet
	Help(" ",1,"C5_TIPOTIT")
EndIf
dbSelectArea( cSavAreaCur )
Return( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A410Cli   ³ Autor ³Eduardo Riera          ³ Data ³ 21.01.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao de Cliente                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Cliente Valido                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Nome da Variavel do PV                               ³±±
±±³          ³ExpC2: Codigo do Cliente                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A410Cli(cA410CliV,cA410Cli,lInterface)

Local lRetorno  := .F.
Local cLoja     :=""
Local lConPadOk := .F.
Local nEndereco	:= 0
Local nX		:= 0
Local nProv		:= 0
Local oDlg
Local aArea  	:= {}
Local aArea2  := {}
Local cProxCli  := ""
Local cProvAnt	:= ""
Local cTes		:= ""
Local nPosProv  := Ascan(aHeader,{|x| Alltrim(x[2]) == "C6_PROVENT"})
Local nPosTes   := Ascan(aHeader,{|x| Alltrim(x[2]) == "C6_TES"})
Local lBloq := .F. //Variável de controle para verificar se o cliente/fornecedor + loja estiver bloqueado
Local lRet := .T.

DEFAULT lInterface := .T.
If nModulo == 73
	lRet:= CRMXLibReg("SA1")
	If LRet == .F.
		Return LRet
	EndIf
EndIf	
	
l410Auto := If (Type("l410Auto") == "U",.f.,l410Auto)
l416Auto := If (Type("l416Auto") == "U",.f.,l416Auto)

If !(l416Auto) .and. !(l410Auto) .And. lInterface
	oDlg	:=	GetWndDefault()
EndIf

cA410CliV	:=	If(cA410CliV==Nil,ReadVar(),cA410CliV)
cA410Cli		:= If(cA410Cli==Nil,&(cA410CliV),cA410Cli)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se cliente/fornecedor possui o mesmo codigo em lojas diferentes, ³
//³deixa campo C5_LOJACLI vazio para usuario preencher.             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(IIF(M->C5_TIPO$"DB","SA2","SA1"))
If l410Auto
	nPos := aScan( aAutoCab, {|x| Alltrim( Upper( x[1] ) ) == "C5_LOJACLI" } )
	If nPos > 0
		cLoja := aAutoCab[nPos][2]
	Endif
Else	
	cLoja := IIf(M->C5_TIPO$"DB",SA2->A2_LOJA,SA1->A1_LOJA)
EndIf

If !l410Auto

	aArea	:= GetArea()
	If Empty(cLoja)
		MsSeek( xFilial()+cA410Cli,.F.)
	Else
		MsSeek( xFilial()+cA410Cli+cLoja,.F.)
	EndIf	 
	aArea2	:= GetArea()
		
	dbSkip()
	cProxCli := &(IIF(M->C5_TIPO$"DB","SA2->A2_COD","SA1->A1_COD"))
	cProxCli := IIF(cProxCli <> cA410Cli,"",cProxcli)

	MsSeek( xFilial()+cA410Cli+cLoja,.F.)
	If (Recno() == aArea2[3]) .And. !Empty(M->C5_LOJACLI)
		cProxCli := ""
	EndIf	

	RestArea(aArea2)
	If Empty(cProxCli)
		cLoja := IIf(M->C5_TIPO$"DB",SA2->A2_LOJA,SA1->A1_LOJA)
	Else
		cLoja := Space( Len(SA2->A2_LOJA) )	
		M->C5_LOJACLI := cLoja
	EndIf	
	
	RestArea(aArea)
	
EndIf

If ( !Empty(cA410Cli) )

	lRetorno := .T.

	dbSelectArea(IIF(M->C5_TIPO$"DB","SA2","SA1"))
	dbSetOrder(1)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Procura por Codigo + Loja                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( !MsSeek( xFilial()+cA410Cli+cLoja,.F.) )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Procura por Codigo ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !MsSeek( xFilial()+cA410Cli,.F.)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Procura pelo nome do cliente                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSetOrder(2)
			If ( !MsSeek( xFilial()+Trim(cA410Cli),.F.) )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Procura pelo CGC                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSetOrder(3)
				lRetorno := ( MsSeek( xFilial()+Trim(cA410Cli),.F.) )
			EndIf
			If lRetorno
				&(cA410CliV) := IF(M->C5_TIPO $ "DB",SA2->A2_COD,SA1->A1_COD)
			EndIf
		EndIf
	EndIf
EndIf
If ( lRetorno )
	If M->C5_TIPO $ "DB"
	
		If SA2->A2_MSBLQL == '1' .AND. Empty(cLoja)
			lBloq = .T.
		Else
			cLoja    := IIf(Empty(cProxcli),SA2->A2_LOJA,Space(Len(SA2->A2_LOJA)))		
		EndIf
		
		cA410Cli  := SA2->A2_COD   
		lConPadOk := .T.
		If cPaisLoc =="ARG" 
			cProvAnt	  := M->C5_PROVENT
			M->C5_PROVENT := SA2->A2_EST // Provincia de Entrega do Fornecedor
		Endif	
	Else
	
		If SA1->A1_MSBLQL == '1' .AND. Empty(cLoja)
			lBloq = .T.
		Else
			cLoja    := IIf(Empty(cProxcli),SA1->A1_LOJA,Space(Len(SA1->A1_LOJA)))		
		EndIf
	
		cA410Cli := SA1->A1_COD
		lConPadOk := .T.
		If cPaisLoc =="ARG" 
			cProvAnt	  := M->C5_PROVENT
			M->C5_PROVENT := SA1->A1_EST // Provincia de Entrega do Cliente
		Endif	
	EndIf
	If cPaisLoc == "COL"
		M->C5_CODMUN := If(M->C5_TIPO $ "DB",;
		                   SA2->A2_COD_MUN,;	// Municipio de Entrega do Fornecedor
						   SA1->A1_COD_MUN)		// Municipio de Entrega do Cliente
	Endif	
	If cPaisLoc == "ARG" .AND. nPosProv > 0 .AND. cProvAnt <> M->C5_PROVENT
		For nX := 1 to Len(aCols)
			cTes := aCols[nX,nPosTes]
			If VerProEnIt(M->C5_PROVENT,cTes,.F.,.F.)
				aCols[nX,nPosProv]:= M->C5_PROVENT
			Else
				nProv++
			Endif
		Next
		If nProv > 0
			MsgAlert(STR0117,STR0118) //Alguns itens não tiveram a província alterada pois possuem impostos gravados em um mesmo campo.
		Endif
	Endif
Else
	Help(" ",1,"A410NCLIE")
EndIf

If !Empty(M->C5_MDCONTR) .And. M->C5_CLIENTE+M->C5_LOJACLI # CNA->CNA_CLIENT+CNA->CNA_LOJACL
	Aviso(STR0127,STR0128,{"Ok"}) //SIGAGCT - Este pedido foi vinculado a um contrato e por isto não pode ter este campo alterado.
	lRetorno := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando for alteracao deve-se verificar se o pedido ja foi entregue, 		³
//³em caso afirmativo, nao deve-se permitir alterar o cliente.          	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( lRetorno ) .And. ALTERA .And. !Empty( cA410Cli )
	dbSelectArea("SC5")
	dbSetOrder(1)
	If ( MsSeek(xFilial("SC5")+M->C5_NUM,.F.) )
		If ( SC5->C5_CLIENTE != cA410Cli )
			dbSelectArea("SC6")
			dbSetOrder(1)
			MsSeek(xFilial("SC6")+M->C5_NUM)
			While ( !Eof() .And. xFilial("SC6") == SC6->C6_FILIAL .And.;
					SC6->C6_NUM 	== SC5->C5_NUM )
				If ( SC6->C6_QTDENT != 0 .Or. !Empty(SC6->C6_NOTA) )
					lRetorno := .F.
					Help(" ",1,"A410CLIOK")
					Exit
				EndIf
				dbSkip()
			EndDo
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua o Acerto na Enchoice                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( lConPadOk .And. lRetorno ) .And. ("C5_CLIENTE" $ cA410CliV)
	M->C5_CLIENTE := cA410Cli
	M->C5_CLIENT  := cA410Cli
	If !lBloq
		M->C5_LOJAENT := cLoja
		M->C5_LOJACLI := cLoja
		If lInterface
			nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == "C5_CLIENTE" } )
			If nEndereco > 0
				aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := cA410Cli
			EndIf
			nEndereco     := Ascan(aGets,{ |x| Subs(x,9,10) == "C5_LOJAENT" } )
			If nEndereco > 0
				aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := M->C5_LOJAENT
			EndIf
			nEndereco     := Ascan(aGets,{ |x| Subs(x,9,10) == "C5_LOJACLI" } )
			If nEndereco > 0
				aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := M->C5_LOJACLI
			EndIf
		EndIf
	EndIf
ElseIf ( lConPadOk .And. lRetorno ) .And. ("C5_CLIENT" $ cA410CliV)
	M->C5_LOJAENT := cLoja	
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o pedido estiver sendo gerado a partir de uma aprovacao de Orcamento³
//³o conteudo da READVAR sera limpo para a chamada da a410Loja()          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If l416Auto
	__READVAR := ""
EndIf
                   
If !Empty(cLoja) .And.!lBloq	
	lRetorno := lRetorno .And. A410Loja(IIF("C5_CLIENTE"$cA410CliV,"C5_LOJACLI","C5_LOJAENT"),IIF("C5_CLIENTE"$cA410CliV,M->C5_LOJACLI,M->C5_LOJAENT),lInterface,Upper(AllTrim(cA410CliV)) == "M->C5_CLIENT" )
EndIf
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza o Rodape                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno .And. lInterface
	Ma410Rodap()
EndIf
Return ( lRetorno ) 

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A410Loja ³ Autor ³ Claudinei M. Benzi    ³ Data ³ 21.01.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Critica de Cliente                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata410                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A410Loja(cLojaV,cLoja,lInterface,lEntrega)

Local aArea		:= GetArea()
Local aAreaSA1 := SA1->(GetArea())
Local aSvArea  := {}
Local cCliAnt  := ""
Local cProvAnt := ""	
Local nPosicao := 0
Local nEndereco:= 0
Local nPosNfOri:= Ascan(aHeader,{|x| Alltrim(x[2]) == "C6_NFORI"})
Local nPosSOri := Ascan(aHeader,{|x| Alltrim(x[2]) == "C6_SERIORI"})
Local nPosItOri:= Ascan(aHeader,{|x| Alltrim(x[2]) == "C6_ITEMORI"})
Local nPosIdent:= Ascan(aHeader,{|x| Alltrim(x[2]) == "C6_IDENTB6"})
Local nPosProv := Ascan(aHeader,{|x| Alltrim(x[2]) == "C6_PROVENT"})
Local nMaxArray:= Len(aHeader)+1
Local nX       := 0 
Local lRetorno := .T.
Local lA410PVCL:= ExistBlock("A410PVCL") //O Tratamento deste ponto de entrada pode ser extendido para outros campos.
Local cCodVdBlk:= Space(TamSX3("A1_VEND")[1])
Local cTabela	:= ""
Local cCondPag	:= ""
Local lCondOk	:= .F. 							//Variavel para verificar se existe condição de Pagamento amarrada ao cliente, para filial ativa.
Local cNfOri 	:= Space(TamSX3("C6_NFORI")[1])
Local cSOri  	:= Space(TamSX3("C6_SERIORI")[1])
Local cItOri 	:= Space(TamSX3("C6_ITEMORI")[1])
Local cIdent 	:= Space(TamSX3("C6_IDENTB6")[1])
Local cFilSC6	:= xFilial("SC6")

DEFAULT lInterface := .T.
DEFAULT cLojaV     := ReadVar()
DEFAULT cLoja      := &(ReadVar())
DEFAULT lEntrega   := .F.  //Indicador quando apenas o campo CLIENTE DE ENTREGA eh alterado, em caso de DEV./RETORNO

l410Auto := If (Type("l410Auto") == "U",.f.,l410Auto)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se trocou de cliente e existem documentos originais preenchidos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCliAnt := a410ChgCli()

If !Empty(cCliAnt) .And. lInterface
	If Ascan(aCols,{|x| !Empty(x[nPosNfOri]) .And. !x[Len(x)]}) > 0 .And. !lEntrega .And. ((M->C5_CLIENTE+M->C5_LOJACLI) <> cCliAnt)
		lRetorno :=(Aviso(OemToAnsi(STR0014),OemToAnsi(STR0061),{STR0030,STR0031}) == 1)
		If lRetorno 
			For nX := 1 to Len(aCols)       
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Limpa os documentos originais caso troque o cliente e confirme          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !aCols[nX][nMAxArray] .And. (!Empty(aCols[nX][nPosNfOri]) .Or. !Empty(aCols[nX][nPosIdent]))
					aCols[nX][nPosNfOri] := cNfOri
					aCols[nX][nPosSOri]  := cSOri						
					aCols[nX][nPosItOri] := cItOri
					aCols[nX][nPosIdent] := cIdent			
				Endif	
			Next
		Else
			M->C5_CLIENTE := Left(cCliAnt,Len(M->C5_CLIENTE))
			M->C5_LOJACLI := Right(cCliAnt,Len(M->C5_LOJACLI))			
			M->C5_CLIENT  := Left(cCliAnt,Len(M->C5_CLIENTE))
			M->C5_LOJAENT := Right(cCliAnt,Len(M->C5_LOJACLI))		
		Endif	
	Endif	
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o pedido corrente foi faturado.                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno

	If ( ALTERA .And. !Empty(cLoja) )
		dbSelectArea("SC6")
		dbSetOrder(1)
		If SC6->( MsSeek(cFilSC6+M->C5_NUM,.F.) )
			While ( SC6->(!Eof()) .And. cFilSC6 == SC6->C6_FILIAL .And.;
					SC6->C6_NUM == M->C5_NUM .And.;
					lRetorno )
				If ( SC6->C6_QTDENT > 0 .Or. !Empty(SC6->C6_NOTA) )
					lRetorno := .F.
					Help(" ",1,"A410CLIOK")
					M->C5_LOJACLI := SC5->C5_LOJACLI
					M->C5_LOJAENT := SC5->C5_LOJAENT
				EndIf
				SC6->(dbSkip())
			EndDo
		EndIf
	EndIf

Endif
	
If ( lRetorno )
	dbSelectArea(IIF( M->C5_TIPO $ "DB","SA2","SA1"))
	dbSetOrder(1)
	If ( "C5_LOJACLI" $ cLojaV )
		If ( !MsSeek(xFilial()+M->C5_CLIENTE+cLoja,.F.) )
			Help(" ",1,"C5_LOJACLI")
			lRetorno := .F.
		Else
			lRetorno := RegistroOk(IIF( M->C5_TIPO $ "DB","SA2","SA1"))			
		EndIf
	Else
		If  ( "C5_LOJAENT" $ cLojaV )
			If !l410Auto .And. ( !MsSeek(xFilial()+IIf(!Empty(M->C5_CLIENT),M->C5_CLIENT,M->C5_CLIENTE)+cLoja,.F.) )
				Help(" ",1,"C5_LOJAENT")
				lRetorno := .F.
			ElseIf l410Auto
				If Type("aAutoCab") == "A"
					nEndereco     := Ascan(aAutocab,{ |x| x[1] == "C5_LOJAENT" } )
					If nEndereco > 0
						cLoja := aAutocab[nEndereco][2]
						M->C5_LOJAENT := cLoja
					EndIf
				EndIf		 
				If (!MsSeek(xFilial()+IIf(!Empty(M->C5_CLIENT),Padr(M->C5_CLIENT,TAMSX3("C5_CLIENT")[1]),M->C5_CLIENTE)+cLoja,.F.) )
				 	Help(" ",1,"C5_LOJAENT")
					lRetorno := .F.
				Else
					lRetorno := RegistroOk(IIF( M->C5_TIPO $ "DB","SA2","SA1"))
				EndIf	
			Else
				lRetorno := RegistroOk(IIF( M->C5_TIPO $ "DB","SA2","SA1"))
			EndIf			
		EndIf
	EndIf
	If cPaisLoc == "COL"
		M->C5_CODMUN := If(M->C5_TIPO $ "DB",;
		                   SA2->A2_COD_MUN,;	// Municipio de Entrega do Fornecedor
						   SA1->A1_COD_MUN)		// Municipio de Entrega do Cliente
	Endif	
	If cPaisLoc =="ARG" 
	    cProvAnt		:= M->C5_PROVENT
		M->C5_PROVENT	:= If(M->C5_TIPO $ "DB",;
		                      SA2->A2_EST,;		// Provincia de Entrega do Fornecedor
							  SA1->A1_EST)		// Provincia de Entrega do Cliente
        If nPosProv > 0 .AND. cProvAnt <> M->C5_PROVENT
			For nX := 1 to Len(aCols)
				aCols[nx,nPosProv]:= M->C5_PROVENT
			Next
		Endif
	Endif
EndIf

If lRetorno .And. !Empty(cLoja)
	M->C5_TIPOCLI := IIF(M->C5_TIPO $ "DB",IIF(SA2->A2_TIPO=="J","R",SA2->A2_TIPO),SA1->A1_TIPO)
	
	If !("C5_LOJAENT" $ cLojaV)
		If (M->C5_CLIENT == IIF( M->C5_TIPO $ "DB", SA2->A2_COD, SA1->A1_COD ))
			M->C5_LOJAENT := IIF( M->C5_TIPO $ "DB", SA2->A2_LOJA, SA1->A1_LOJA )
		EndIf
	
		If !("C5_LOJAENT" $ cLojaV ) .And.	!("C5_CLIENT" $ cLojaV )
			If (M->C5_CLIENTE == IIF( M->C5_TIPO $ "DB", SA2->A2_LOJA, SA1->A1_COD ))
				M->C5_LOJACLI := IIF( M->C5_TIPO $ "DB", SA2->A2_LOJA, SA1->A1_LOJA )
			EndIf
		Endif	

		If lInterface
			nEndereco     := Ascan(aGets,{ |x| Subs(x,9,10) == "C5_LOJAENT" } )
			If nEndereco > 0
				aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := M->C5_LOJAENT
			EndIf
			nEndereco     := Ascan(aGets,{ |x| Subs(x,9,10) == "C5_LOJACLI" } )
			If nEndereco > 0
				aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := M->C5_LOJACLI
			EndIf
			nEndereco     := Ascan(aGets,{ |x| Subs(x,9,10) == "C5_TIPOCLI" } )
			If nEndereco > 0
				aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := M->C5_TIPOCLI
			EndIf
		EndIf 
	
		If ( !M->C5_TIPO $ "DB" .And. lRetorno )
			M->C5_TRANSP := SA1->A1_TRANSP
			If lA410PVCL
				cCodVdBlk := Execblock("A410PVCL",.F.,.F.,"A1_VEND")
				If ValType(cCodVdBlk) <> TamSX3("A1_VEND")[3] //Se o retorno tiver o tipo e/ou tamanho diferente do campo assume valor Default
					cCodVdBlk := If(Empty(M->C5_MDCONTR),SA1->A1_VEND,M->C5_VEND1)
				Else //Atualiza variavel de memoria
					M->C5_VEND1 := PADR(cCodVdBlk,TamSX3("A1_VEND")[1])// Garante que a informação tenha o tamanho do campo
				EndIf
			Else //Se o ponto nao existir assume valor Default
				M->C5_VEND1 := If(Empty(M->C5_MDCONTR),SA1->A1_VEND,M->C5_VEND1)
			EndIf	
			aSvArea := GetArea()
			dbSelectArea("SA3")
			SA3->(dbSetOrder(1))
			If ( !MsSeek(xFilial("SA3")+M->C5_VEND1) ) 
				M->C5_VEND1 := Space(TamSX3("A1_VEND")[1])
			Else
				If !RegistroOk("SA3",.F.)
					If !l410Auto
						Aviso(STR0038,STR0172 + M->C5_VEND1 + STR0173,{STR0040}) // "Atencao!"##"Codigo do vendedor: "##" utilizado por este cliente esta bloqueado no cadastro de vendedores!"##"Ok"
					EndIf
					M->C5_VEND1 := Space(TamSX3("A1_VEND")[1])
				EndIf
			EndIf
			RestArea(aSvArea)
			M->C5_COMIS1	:= If(Empty(M->C5_MDCONTR),Iif(!Empty(SA1->A1_COMIS),SA1->A1_COMIS,SA3->A3_COMIS),M->C5_COMIS1)
			lCondOk			:= Posicione("SE4",1,XFILIAL("SE4")+SA1->A1_COND, "E4_CODIGO") == SA1->A1_COND 

			If Empty(M->C5_MDCONTR)
				M->C5_CONDPAG	:= If(lCondOk, SA1->A1_COND, Space(TamSx3("C5_CONDPAG")[1]))
			EndIf
					
			M->C5_TABELA	:= IIF(Empty(SA1->A1_TABELA),"   ",SA1->A1_TABELA)

			If Empty(M->C5_TABELA) .Or. Empty(M->C5_CONDPAG)
				cTabela		:= M->C5_TABELA
				cCondPag	:= M->C5_CONDPAG

				A410TabRNg( SA1->A1_COD, SA1->A1_LOJA, @cTabela, @cCondPag )

				M->C5_CONDPAG	:= Iif(Empty(M->C5_CONDPAG),cCondPag,M->C5_CONDPAG)
				M->C5_TABELA	:= IiF(Empty(M->C5_TABELA),cTabela,M->C5_TABELA)
			EndIf

			M->C5_BANCO := SA1->A1_BCO1
			M->C5_TPFRETE := SA1->A1_TPFRET
			M->C5_INCISS := SA1->A1_INCISS
			M->C5_DESC1 := If(!Empty(SA1->A1_DESC), SA1->A1_DESC, 0)
			If lInterface
				nEndereco := Ascan(aGets,{ |x| Subs(x,9,9) == "C5_TRANSP" } )
				If nEndereco > 0
					If ASC(SubStr(aGets[nEndereco],1,1)) > 64
						nPosicao := Str(ASC(SubStr(aGets[nEndereco],1,1))-55,2)+SubStr(aGets[nEndereco],2,1)
						nPosicao := Iif(ValType(nEndereco)=='C', Val(nEndereco), nEndereco )
					Else
						nPosicao := Val(SubStr(aGets[nEndereco],1,2))
					EndIf
					aTela[nPosicao][Val(Subs(aGets[nEndereco],3,1))*2] := SA1->A1_TRANSP
				EndIf
				nEndereco   := Ascan(aGets,{ |x| Subs(x,9,8) == "C5_VEND1" } )
				If nEndereco > 0
					If ASC(SubStr(aGets[nEndereco],1,1)) > 64
						nPosicao := Str(ASC(SubStr(aGets[nEndereco],1,1))-55,2)+SubStr(aGets[nEndereco],2,1)
						nPosicao := Iif(ValType(nEndereco)=='C', Val(nEndereco), nEndereco )
					Else
						nPosicao := Val(SubStr(aGets[nEndereco],1,2))
					EndIf
					aTela[nPosicao][Val(Subs(aGets[nEndereco],3,1))*2] := Iif(Empty(cCodVdBlk),SA1->A1_VEND,cCodVdBlk)
				EndIf
				nEndereco    := Ascan(aGets,{ |x| Subs(x,9,9) == "C5_COMIS1" } )
				If nEndereco > 0
					If ASC(SubStr(aGets[nEndereco],1,1)) > 64
						nPosicao := Str(ASC(SubStr(aGets[nEndereco],1,1))-55,2)+SubStr(aGets[nEndereco],2,1)
						nPosicao := Iif(ValType(nEndereco)=='C', Val(nEndereco), nEndereco )
					Else
						nPosicao := Val(SubStr(aGets[nEndereco],1,2))
					EndIf
					aTela[nPosicao][Val(Subs(aGets[nEndereco],3,1))*2] := TransNum("A1_COMIS")
				EndIf			
				nEndereco     := Ascan(aGets,{ |x| Subs(x,9,10) == "C5_CONDPAG" } )
				If nEndereco > 0
					If ASC(SubStr(aGets[nEndereco],1,1)) > 64
						nPosicao := Str(ASC(SubStr(aGets[nEndereco],1,1))-55,2)+SubStr(aGets[nEndereco],2,1)
						nPosicao := Iif(ValType(nEndereco)=='C', Val(nEndereco), nEndereco )
					Else
						nPosicao := Val(SubStr(aGets[nEndereco],1,2))
					EndIf
					aTela[nPosicao][Val(Subs(aGets[nEndereco],3,1))*2] := SA1->A1_COND
				EndIf
				nEndereco   := Ascan(aGets,{ |x| Subs(x,9,9) == "C5_TABELA" } )
				If nEndereco > 0
					If ASC(SubStr(aGets[nEndereco],1,1)) > 64
						nPosicao := Str(ASC(SubStr(aGets[nEndereco],1,1))-55,2)+SubStr(aGets[nEndereco],2,1)
						nPosicao := Iif(ValType(nEndereco)=='C', Val(nEndereco), nEndereco )
					Else
						nPosicao := Val(SubStr(aGets[nEndereco],1,2))
					EndIf
					aTela[nPosicao][Val(Subs(aGets[nEndereco],3,1))*2] := M->C5_TABELA
				EndIf
				nEndereco   := Ascan(aGets,{ |x| Subs(x,9,8) == "C5_BANCO" } )
				If nEndereco > 0
					If ASC(SubStr(aGets[nEndereco],1,1)) > 64
						nPosicao := Str(ASC(SubStr(aGets[nEndereco],1,1))-55,2)+SubStr(aGets[nEndereco],2,1)
						nPosicao := Iif(ValType(nEndereco)=='C', Val(nEndereco), nEndereco )
					Else
						nPosicao := Val(SubStr(aGets[nEndereco],1,2))
					EndIf
					aTela[nPosicao][Val(Subs(aGets[nEndereco],3,1))*2] := SA1->A1_BCO1
				EndIf
				nEndereco     := Ascan(aGets,{ |x| Subs(x,9,10) == "C5_TPFRETE" } )
				If nEndereco > 0
					If ASC(SubStr(aGets[nEndereco],1,1)) > 64
						nPosicao := Str(ASC(SubStr(aGets[nEndereco],1,1))-55,2)+SubStr(aGets[nEndereco],2,1)
						nPosicao := Iif(ValType(nEndereco)=='C', Val(nEndereco), nEndereco )
					Else
						nPosicao := Val(SubStr(aGets[nEndereco],1,2))
					EndIf
					aTela[nPosicao][Val(Subs(aGets[nEndereco],3,1))*2] := M->C5_TPFRETE
				EndIf
				nEndereco    := Ascan(aGets,{ |x| Subs(x,9,9) == "C5_INCISS" } )
				If nEndereco > 0
					If ASC(SubStr(aGets[nEndereco],1,1)) > 64
						nPosicao := Str(ASC(SubStr(aGets[nEndereco],1,1))-55,2)+SubStr(aGets[nEndereco],2,1)
						nPosicao := Iif(ValType(nEndereco)=='C', Val(nEndereco), nEndereco )
					Else
						nPosicao := Val(SubStr(aGets[nEndereco],1,2))
					EndIf
					aTela[nPosicao][Val(Subs(aGets[nEndereco],3,1))*2] := M->C5_INCISS
				EndIf
				nEndereco   := Ascan(aGets,{ |x| Subs(x,9,9) == "C5_DESC1 " } )
				If nEndereco > 0
					If ASC(SubStr(aGets[nEndereco],1,1)) > 64
						nPosicao := Str(ASC(SubStr(aGets[nEndereco],1,1))-55,2)+SubStr(aGets[nEndereco],2,1)
						nPosicao := Iif(ValType(nEndereco)=='C', Val(nEndereco), nEndereco )
					Else
						nPosicao := Val(SubStr(aGets[nEndereco],1,2))
					EndIf
					aTela[nPosicao][Val(Subs(aGets[nEndereco],3,1))*2] := Str(M->C5_DESC1,5,2)
				EndIf			
				IF Empty(M->C5_COMIS1).And.!Empty(M->C5_VEND1)
					dbSelectArea("SA3")
					If MsSeek(xFilial()+M->C5_VEND1,.F.)
						M->C5_COMIS1 := A3_COMIS
						nEndereco := Ascan(aGets,{ |x| Subs(x,9,9) == "C5_COMIS1" } )
						If nEndereco > 0
							If ASC(SubStr(aGets[nEndereco],1,1)) > 64
								nPosicao := Str(ASC(SubStr(aGets[nEndereco],1,1))-55,2)+SubStr(aGets[nEndereco],2,1)
								nPosicao := Iif(ValType(nEndereco)=='C', Val(nEndereco), nEndereco )
							Else
								nPosicao := Val(SubStr(aGets[nEndereco],1,2))
							EndIf
							aTela[nPosicao][Val(Subs(aGets[nEndereco],3,1))*2] := TransNum("A3_COMIS")
						EndIf
					EndIf
				EndIf
				If !Empty(M->C5_CONDPAG)
					dbSelectArea("SE4")
					If MsSeek(xFilial()+M->C5_CONDPAG,.F.)
						M->C5_ACRSFIN := E4_ACRSFIN
						M->C5_DESCFI  := E4_DESCFIN						
						nEndereco     := Ascan(aGets,{ |x| Subs(x,9,10) == "C5_ACRSFIN" } )
						If nEndereco > 0
							If ASC(SubStr(aGets[nEndereco],1,1)) > 64
								nPosicao := Str(ASC(SubStr(aGets[nEndereco],1,1))-55,2)+SubStr(aGets[nEndereco],2,1)
								nPosicao := Iif(ValType(nEndereco)=='C', Iif(ValType(nEndereco)=='C', Val(nEndereco), nEndereco ), nEndereco )
							Else
								nPosicao := Val(SubStr(aGets[nEndereco],1,2))
							EndIf
							aTela[nPosicao][Val(Subs(aGets[nEndereco],3,1))*2] := TransNum("E4_ACRSFIN")
						EndIf			
					EndIf
				EndIf
			EndIf
		ElseIf ( M->C5_TIPO $ "DB" .And. lRetorno )
			M->C5_TRANSP  := SA2->A2_TRANSP
			M->C5_CONDPAG := SA2->A2_COND
			If lInterface
				nEndereco := Ascan(aGets,{ |x| Subs(x,9,9) == "C5_TRANSP" } )
				If nEndereco > 0
					If ASC(SubStr(aGets[nEndereco],1,1)) > 64
						nPosicao := Str(ASC(SubStr(aGets[nEndereco],1,1))-55,2)+SubStr(aGets[nEndereco],2,1)
						nPosicao := Iif(ValType(nEndereco)=='C', Val(nEndereco), nEndereco )
					Else
						nPosicao := Val(SubStr(aGets[nEndereco],1,2))
					EndIf
					aTela[nPosicao][Val(Subs(aGets[nEndereco],3,1))*2] := SA2->A2_TRANSP
				EndIf
				nEndereco     := Ascan(aGets,{ |x| Subs(x,9,10) == "C5_CONDPAG" } )
				If nEndereco > 0
					If ASC(SubStr(aGets[nEndereco],1,1)) > 64
						nPosicao := Str(ASC(SubStr(aGets[nEndereco],1,1))-55,2)+SubStr(aGets[nEndereco],2,1)
						nPosicao := Iif(ValType(nEndereco)=='C', Val(nEndereco), nEndereco )
					Else
						nPosicao := Val(SubStr(aGets[nEndereco],1,2))
					EndIf
					aTela[nPosicao][Val(Subs(aGets[nEndereco],3,1))*2] := SA2->A2_COND
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza o Rodape                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( lRetorno .And. lInterface)
	a410ChgCli(M->C5_CLIENTE+M->C5_LOJACLI)
	Ma410Rodap()
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a entrada da rotina                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( !lRetorno )
	RestArea(aAreaSA1)
EndIf

If aArea[1] <> "SA1"
	RestArea(aArea)
EndIf
Return(lRetorno)     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a410RvPlanºAutor  ³ Daniel Leme        º Data ³  03/21/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se há integração com revisão de Planilha de For-  º±±
±±º          ³ mação de preços através de ligação entre tabela de preço   º±±
±±º          ³ e Publicação de Preços e interpreta a integração           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA410A                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A410RvPlan(cTabPrec,cProduto,lClear,lDeleta)

Local lRet := .T.
Local lSvCols, aSvCols, aSvHead, nSvN, nLin, aCombo, aAreas, nDif
Local nPosQtd, nPosCpo, nPosStatic
Local bError

Default lClear		:= .F.
Default lDeleta	:= .F.

Static a410IntRvPlan
Static aDadRevPlan

If a410IntRvPlan == Nil
	a410IntRvPlan := 	(Type("l410Auto") == "U" .Or. l410Auto == .F.) ;
							.And. (Type("l416Auto") == "U" .Or. l416Auto == .F.) ;						
							.And. SuperGetMV("MV_REVPLAN",.F.,.F.) 							
EndIf

If a410IntRvPlan .And. Type("n") == "N" .And. n > 0
	
	If lClear .Or. aDadRevPlan == Nil
		aDadRevPlan := {}
	EndIf
		
	If (!aTail(aCols[n]) .Or. (aTail(aCols[n]) .And. aScan( aDadRevPlan, {|x| x[1] == n }) >= 0 )) .And.;
	   !Empty(cProduto) .And.;
	   !Empty(cTabPrec)
		
		aAreas := {	DA0->(GetArea()),;
					SAX->(GetArea()),;
					SCO->(GetArea()),;
					SB1->(GetArea()),;
					SDY->(GetArea()),;
					GetArea()}

		nPosQtd := GdFieldPos("C6_QTDVEN")

		SB1->( DbSetOrder( 1 ) ) //-- B1_FILIAL+B1_COD
		If SB1->( MsSeek( xFilial("SB1") + cProduto ) )
			DA0->( DbSetOrder( 1 ) ) //-- DA0_FILIAL+DA0_CODTAB
			If DA0->(MsSeek( xFilial("DA0") + cTabPrec)) .And. !Empty(DA0->DA0_CODPUB)
		
				SAX->( DbSetOrder( 1 ))
				If SAX->( MsSeek( DA0->(DA0_FILPUB+DA0_CODPUB) ) ) .And. !Empty(SAX->AX_CODPLA)
		
					SCO->( DbSetOrder( 1 ) ) //-- CO_FILIAL+CO_CODIGO+CO_REVISAO+CO_LINHA
					If SCO->( MsSeek( xFilial("SCO",DA0->DA0_FILPUB) + SAX->(AX_CODPLA+AX_REVPLA) + StrZero( 1, TamSX3("CO_LINHA")[1] ) ) )
						
						If !aTail(aCols[n])
		
							Private cArqMemo   := SCO->CO_NOME
							Private lDirecao   := .T.  
							Private nQualCusto := 1
							Private cProg      := "R430"
				
							Pergunte( "MTC010", .F. )  //-- Este pergunte serve para a funcao MC010Forma, sem os MV_PARXX ocorre error log.
							If lSvCols := (Type("aCols") == "A" .And. Type("aHeader") == "A")
								aSvCols	:= aClone( aCols )
								aSvHead	:= aClone( aHeader )
								nSvN		:= n
								n := 1
							EndIf
				
							bError := ErrorBlock( {|| A410RvErr( @lRet, .F. )  } )
							Begin Sequence
								//-- Inicializa conteudo da publicação na Formação
								C010ClrVLine()
								SDY->( DbSetOrder(1)) //-- DY_FILIAL+DY_CODIGO+DY_PRODUTO+DY_SEQUEN
								SDY->( MsSeek( DA0->(DA0_FILPUB+DA0_CODPUB) + cProduto ) )
								Do While SDY->(!Eof()) .And. SDY->(DY_FILIAL+DY_CODIGO+DY_PRODUTO) == DA0->(DA0_FILPUB+DA0_CODPUB) + cProduto
									If !Empty( SDY->DY_LINHA )
										C010SetVLin( Val(SDY->DY_LINHA) + 1, SDY->DY_VALOR )
									Else
										MA317IniPr( SDY->DY_CODPRC, SDY->DY_VALOR ) 
									EndIf

									SDY->(DbSkip())
								EndDo
								
								//-- Faz Chamada ao Cálculo da Planilha de Formação de Preços
								aVet := MC010Form2( "SB1", SB1->( RecNo() ), 98,,, .F. )
			
								//-- Limpa Dados estáticos da Planilha de Formação e do Cadastro de Itens de Precificação x Categoria x Produto
								C010ClrVLine()
								MA317FimPr()

							End Sequence
								
							If lSvCols
								aCols		:= aClone( aSvCols )
								aHeader	:= aClone( aSvHead )
								n			:= nSvN			
							EndIf
							Pergunte("MTA410",.F.)
						EndIf
			
						If lRet
							bError := ErrorBlock( {|| A410RvErr( @lRet, .F. )  } )
							Begin Sequence
								Do While SCO->(!Eof()) .And. SCO->(CO_FILIAL+CO_CODIGO+CO_REVISAO) == xFilial("SCO",DA0->DA0_FILPUB) + SAX->(AX_CODPLA+AX_REVPLA)
									
									nLin := Val(SCO->CO_LINHA) + 1
									If aCombo == Nil
										aCombo := aClone(Mata315Cmb( .T., .T. ))
									EndIf
									
									If !Empty(SCO->CO_INTPV) .And. SCO->CO_INTPV != "0" 
									
										cCampo 		:= aCombo[Val(SCO->CO_INTPV)]
										nPosStatic	:= 0
										nDif			:= 0
										
										If aTail(aCols[n]) .And. (nPosStatic := aScan( aDadRevPlan, {|x| x[1] == n .And. x[2] == nLin  })) > 0

											If Left(cCampo,3) == "C5_"
	
												&("M->"+cCampo) := Max( &("M->"+cCampo)-aDadRevPlan[nPosStatic][3], 0 )
												aDadRevPlan[nPosStatic][3] := 0

											EndIf
											
										ElseIf !aTail(aCols[n]) .And. Len(aVet) >= nLin .And. ValType(aVet[nLin][6]) == "N"

											If (nPosStatic := aScan( aDadRevPlan, {|x| x[1] == n .And. x[2] == nLin  })) == 0
												aAdd( aDadRevPlan,{n,nLin,0,aCols[n][nPosQtd]})
												nPosStatic := Len(aDadRevPlan)
												If !lDeleta
													nDif := aVet[nLin][6] * aCols[n][nPosQtd]
												EndIf
											Else
												nDif := ( aVet[nLin][6] * aCols[n][nPosQtd] ) - aDadRevPlan[nPosStatic][3]
											EndIf
			
											If Left(cCampo,3) == "C5_"
	
												&("M->"+cCampo) := Max( &("M->"+cCampo)+nDif, 0 )
												aDadRevPlan[nPosStatic][3] := aVet[nLin][6] * aCols[n][nPosQtd]
												aDadRevPlan[nPosStatic][4] := aCols[n][nPosQtd]

											ElseIf Left(cCampo,3) == "C6_" .And. lSvCols;
													 .And. n <= Len(aCols) .And. (nPosCpo := GdFieldPos(cCampo)) > 0
													 
												aCols[n][nPosCpo] := aVet[nLin][6]
												aDadRevPlan[nPosStatic][3] := aVet[nLin][6]
												aDadRevPlan[nPosStatic][4] := aCols[n][nPosQtd]
											EndIf
										EndIf
									EndIf
	
									SCO->(DbSkip())
								EndDo
							End Sequence
				
							If lRet 
								If Type("oGetDad") == "O"
									oGetDad:Refresh(.T.)
								EndIf
								If Type("oGetPV") == "O"
									oGetPV:Refresh()
								EndIf	
							EndIf
							
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		aEval( aAreas, { |x| RestArea(x) } )
	EndIf
EndIf
Return lRet  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A410RvErr ºAutor  ³ Daniel Leme        º Data ³  03/21/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tratamento de erros                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA410A                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A410RvErr(uRet, uVal)

uRet := If(uVal == Nil, Nil, uVal)

Break
Return     

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³a410ChecaB³ Rev.  ³Aline Correa do Vale   ³ Data ³ 19.03.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao do Codigo do Produto ou do Codigo de Barras quando³±±
±±³          ³utiliza-se codigo de barra.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Codigo Valido                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A410ChecaB1(cCodigo, oCod, lLoop)

Local lRetorno	:= .T.
Local nBytes    := IIf(SuperGetMv("MV_CONSBAR")>Len(SB1->B1_COD),Len(SB1->B1_COD),SuperGetMv("MV_CONSBAR") )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( ExistBlock("MTA410BR") )
	cCodigo := ExecBlock("MTA410BR",.f.,.f.,cCodigo)
EndIf
cCodigo := PadR(SubStr(cCodigo,1,nBytes),Len(SB1->B1_CODBAR))

dbSelectArea("SB1")
dbSetOrder(1)
If !Empty(cCodigo) .AND. (lRetorno .And. !dbSeek(xFilial("SB1")+cCodigo,.F.) )
	
	dbSetOrder(5)
	lRetorno := dbSeek(xFilial("SB1")+Subs(cCodigo,1,Len(SB1->B1_CODBAR)),.F.)

	If !lRetorno
		cCodigo := trim(cCodigo)+eandigito(trim(cCodigo))
		lRetorno := dbSeek(xFilial("SB1")+Subs(cCodigo,1,Len(SB1->B1_CODBAR)),.F.)
	EndIf
        
	cCodigo  := SB1->B1_COD
	If !lRetorno 
		oCod:Refresh()
		Help(" ",1,"A410NPROD")
	EndIf
	
	dbSetOrder(1)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o produto ja existe no aCols                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( lRetorno ) .And. !Empty(cCodigo)
	nPosProd	:=	Ascan(aListBox,{|x|x[1]==cCodigo})	
	If nPosProd==0
		If Len(aListBox)==1	 .And. Empty(Trim(aListBox[1,1]))
			aListBox[1,1]	:=	cCodigo
			aListBox[1,2]	:=	SB1->B1_DESC
			aListBox[1,3]	:=	1
			nPosProd		:=	1
		Else
			If (Len(aListBox)+1)>ITENSSC6
				Help(" ",1,"A410LIMMAX")
				nPosProd:=oListBox:nAt
			Else
				Aadd(aListBox,{cCodigo,SB1->B1_DESC,1})
				nPosProd:=Len(aListBox)
			EndIf
		EndIf
	Else
		aListBox[nPosProd,3]+=1
	EndIf
	oListBox:SetArray(aListBox)
	oListBox:bLine:={||{aListBox[oListBox:nAt,1],;
						aListBox[oListBox:nAt,2],;
						xPadl(Str(aListBox[oListBox:nAt,3]),100)}}
	oListBox:nAt:=nPosProd
	oListBox:Refresh()
	cCodigo:=Space(Len(SB1->B1_COD))
	oCod:Refresh()
EndIf
lLoop	:= .T.
Return( lRetorno )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³a410Venc  ³  Autor³ Cristina Ogura        ³ Data ³ 18.09.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se os vencimentos digitados no pedido sao menores  ³±±
±±³          ³que a data de emissao do pedido.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata410                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A410Venc()

Local cVar := &(ReadVar())
Local lRet   := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Somente obriga a digita‡ao da data do vencimento      ³
//³quando a condi‡„o de pagamento for tipo 9.            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SE4->(dbSetOrder(1))
If SE4->(dbSeek(xFilial("SE4")+M->C5_CONDPAG)) .AND. SE4->E4_TIPO == "9" .AND. DtoS(cVar) < DtoS(M->C5_EMISSAO) .And. !Empty(cVar)
	Help(" ",1,"A410VENC")
	lRet := .F.
Endif
Return lRet      

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A410BloqIss³ Autor ³     Vendas/CRM       ³ Data ³ 10.04.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se existem itens com códigos de serviço diferentes ³±±
±±³          ³quando o parâmetro MV_NFEQUEB estiver ativo.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata410                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A410BloqIss(cNumPed)

Local aArea := GetArea()
Local lRet  := .T.

#IFDEF TOP
	Local cQuery    := ""
	Local cAliasSC6 := GetNextAlias()
	Local nTot      := 0

	cQuery := "SELECT DISTINCT SC6.C6_CODISS FROM "+RetSqlName("SC6")+" SC6 "
	cQuery += "WHERE SC6.C6_FILIAL = '"+xFilial('SC6')+"' AND "
	cQuery += "SC6.C6_NUM ='"+cNumPed+"' AND "
	cQuery += "SC6.C6_CODISS <> ' ' AND "
	cQuery += "SC6.D_E_L_E_T_= ' ' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC6)
	While (cAliasSC6)->(!Eof())
		nTot++
		If nTot > 1
			lRet := .F.
			Exit
		EndIf	
		(cAliasSC6)->(dbSkip())
	EndDo
    (cAliasSC6)->(dbCloseArea())
#ENDIF

RestArea(aArea)
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ProtCfgAdt
Valida o compartilhamento das tabelas FIE e FR3

@return	aRet 
/*/
//------------------------------------------------------------------------------
Static Function ProtCfgAdt()

Local aRet := {}

If FindFunction('CfgAdianta')
	aRet := CfgAdianta()
Else
	aRet := {{FwModeAccess('FIE',1),;
              FwModeAccess('FIE',2),;
              FwModeAccess('FIE',3),;
              FWSIXUtil():ExistIndex( 'FIE', '4' ),;
              FWSIXUtil():ExistIndex( 'FIE', '5' )},;
             {FwModeAccess('FR3',1),;
              FwModeAccess('FR3',2),;
              FwModeAccess('FR3',3),;
              FWSIXUtil():ExistIndex( 'FR3' , '8' ),;
              FWSIXUtil():ExistIndex( 'FR3' , '9' )},;
             {FwModeAccess('SE1',3),;
              FwModeAccess('SE2',3)} }
EndIf
Return(aRet)
