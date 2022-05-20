#INCLUDE "RWMAKE.CH"
#INCLUDE "Protheus.Ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#Include "tbiconn.ch"
#include "topconn.ch"

#DEFINE DS_MODALFRAME   128

/*
Funcao      : V5FIN005
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Impressao de Boleto Bancario do Banco do Brasil com Codigo de Barras, Linha Digitavel e Nosso Numero.
Autor     	: Anderson Arrais
Data     	: 19/05/2018
Módulo      : Financeiro.
Empresa		: VOGEL
*/

*-----------------------------------------*
USER FUNCTION V5FIN005(lSelAuto, lPreview, _lCapa, _oCapa, _lDados, _lMulta, _nPerMul, _nPerJur, _lWs)
	*-----------------------------------------*

	LOCAL aCampos      	:= {{"E1_NOMCLI","Cliente","@!"},{"E1_PREFIXO","Prefixo","@!"},{"E1_NUM","Titulo","@!"},;
		{"E1_PARCELA","Parcela","@!"},{"E1_VALOR","Valor","@E 9,999,999.99"},{"E1_VENCREA","Vencimento"}}
	LOCAL	aPergs 		:= {}
	LOCAL lExec         := .T.
	LOCAL nOpc         	:= 0
	LOCAL aDesc        	:= {"Este programa imprime os boletos de","cobranca bancaria de acordo com","os parametros informados"}
	Local cFileRet		:= ""
	Local _cTip460      := SuperGetMV('VO_TIPAGLU',, 'BOL')
	PRIVATE Exec       	:= .F.
	PRIVATE cIndexName 	:= ''
	PRIVATE cIndexKey  	:= ''
	PRIVATE cFilter    	:= ''
	Private cAgencia    := ''
	Private cConta      := ''
	Private cSubConta   := ''

	Default lPreview    := .T.
	DEFAULT lSelAuto	:= .F.
	Default _lCapa      := .F.
	Default _oCapa      := Nil
	Default _lDados     := .F.
	Default _lMulta     := .F.
	Default _nPerMul    := 0
	Default _nPerJur    := 0
	Default _lWs        := .F.

	Tamanho  := "M"
	titulo   := "Impressao de Boleto Banco do Brasil
	cDesc1   := "Este programa destina-se a impressao do Boleto Banco do Brasil."
	cDesc2   := ""
	cDesc3   := ""
	cString  := "SE1"
	lEnd     := .F.
	aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
	nLastKey := 0
	dbSelectArea("SE1")

	if !lSelAuto

		cPerg     :="V5FIN005"

		Aadd(aPergs,{"Prefixo","","","mv_ch1","C",3,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
		Aadd(aPergs,{"De Numero","","","mv_ch2","C",9,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
		Aadd(aPergs,{"Ate Numero","","","mv_ch3","C",9,0,0,"G","","MV_PAR03","","","","ZZZZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})

		AjustaSx1("V5FIN005",aPergs)

		If !_lCapa

			If !Pergunte (cPerg,.T.)
				Return Nil
			EndIF

		Else

			MV_PAR01 := SE1->E1_PREFIXO
			MV_PAR02 := SE1->E1_NUM
			MV_PAR03 := SE1->E1_NUM

		EndIf

	Else
		MV_PAR01 := SF2->F2_PREFIXO
		MV_PAR02 := SF2->F2_DUPL
		MV_PAR03 := SF2->F2_DUPL
	EndIf

	If Select('SQL') > 0
		SQL->(DbCloseArea())
	EndIf

	// VALIDACAO POIS O BOLETO E CHAMADO DE UMA ROTINA ROBO DE TITULOS
	If ! IsInCallStack("U_VOGWF02")

		BeginSql Alias 'SQL'

		SELECT E1_OK,E1_PORTADO,E1_CLIENTE,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_EMISSAO,E1_PEDIDO,E1_NUMSOL,R_E_C_N_O_  as 'RECNUM' 
		FROM %table:SE1%
		WHERE %notDel%
		AND E1_FILIAL = %xfilial:SE1%
		AND E1_SALDO > 0
		AND E1_PREFIXO = %exp:MV_PAR01%
		AND E1_NUM     >= %exp:MV_PAR02% AND E1_NUM <= %exp:MV_PAR03%
		AND (E1_TIPO = 'NF' OR E1_TIPO = %exp:_cTip460%)
		ORDER BY E1_PORTADO,E1_CLIENTE,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_EMISSAO

		EndSql

	Else

		BeginSql Alias 'SQL'

		SELECT E1_OK,E1_PORTADO,E1_CLIENTE,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_EMISSAO,E1_PEDIDO,E1_NUMSOL,R_E_C_N_O_  as 'RECNUM' 
		FROM %table:SE1%
		WHERE %notDel%
		AND R_E_C_N_O_ = %Exp:nRecSE1%

		ORDER BY E1_PORTADO,E1_CLIENTE,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_EMISSAO

		EndSql

	Endif

	SQL->(dbGoTop())

	If SQL->(EOF()) .or. SQL->(BOF())
		lExec := .F.
	EndIf

	If lExec
		Processa({|lEnd| cFileRet := MontaRel(lSelAuto, lPreview, _lCapa, _oCapa, _lDados, _lMulta, _nPerMul, _nPerJur, _lWs)})
	else
		dbSelectArea ("SE1")
		DbGotop()
		ProcRegua(RecCount())
		DbSetOrder(1)
		DbSeek (xFilial("SE1")+mv_par01+mv_par02, .T.)

		If ( SE1->E1_SALDO == 0 )
			If !_lWs
				Aviso("Aviso", 'Titulo ' + SE1->E1_NUM  + If( !Empty( SE1->E1_PARCELA ) , '-Parcela ' + SE1->E1_PARCELA , '' ) + ' sem saldo. Boleto nao será gerado.',{"Abandona"},2 )
			Else
				Conout('Titulo ' + SE1->E1_NUM  + If( !Empty( SE1->E1_PARCELA ) , '-Parcela ' + SE1->E1_PARCELA , '' ) + ' sem saldo. Boleto nao será gerado.')
			EndIf
		Else
			If !_lWs
				Aviso("Aviso","Não existe informações.",{"Abandona"},2)
			Else
				Conout("Não existe informações.")
			EndIf
		EndIf

	Endif

Return( cFileRet )

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³ Funcao    ³ MONTAREL()  ³ Autor ³ Flavio Novaes    ³ Data ³ 03/02/2005 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Descricao ³ Impressao de Boleto Bancario do Banco do Brasil com Codigo ³±±
	±±³           ³ de Barras, Linha Digitavel e Nosso Numero.                 ³±±
	±±³           ³ Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso       ³ FINANCEIRO                                                 ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION MontaRel(lSelAuto, lPreview, _lCapa, _oCapa, _lDados, _lMulta, _nPerMul, _nPerJur, _lWs)
	LOCAL oPrint
	LOCAL n			:= 0
	LOCAL nI     	:= 0
	LOCAL aBitmap   := {	"",;			                                                            // Banner Publicitario
	"LGRL.bmp"}		                                                            // Logo da Empresa
	LOCAL aDadosEmp := {SM0->M0_NOMECOM,;								   								//[1]Nome da Empresa
	SM0->M0_ENDCOB,; 															//[2]Endereço
	AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,;//[3]Complemento
	"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3),; 			//[4]CEP
	"PABX/FAX: "+SM0->M0_TEL,; 													//[5]Telefones
	"C.N.P.J.: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+;			//[6]
	Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+;						//[6]
	Subs(SM0->M0_CGC,13,2),;													//[6]CGC
	"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+;			//[7]
	Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)}							//[7]I.E
	LOCAL aDadosTit
	LOCAL aDadosBanco
	LOCAL aDatSacado
	LOCAL aBolText  := {"Após vencimento, cobrar multa de 2% e juros de 1% ao mês.",;
		"Mantenha o pagamento em dia e evite a suspensão parcial/total dos serviços e a inclusão nos órgãos de proteção do crédito.",;
		""}
	LOCAL aBMP      := aBitMap
	LOCAL i         := 1
	LOCAL CB_RN_NN  := {}
	LOCAL nRec     	:= 0
	LOCAL _nVlrAbat := 0
	Local cLocal    := IIf(!_lWs, GetTempPath(), '')
	Local cFileName := ""
	Local cFile 	:= ""
	Local cDirBol 	:= "\FTP\" + cEmpAnt + "\V5FIN005\"
	Local _nValor   := 0
	Local _nMulta   := 0
	Local _nJuros   := 0
	Local _dDtVenc  := CToD('//')
	Local _nT       := 0
	Local nCont 	:= 0
	Private cPortGrv	:= ""
	Private cAgeGrv		:= ""
	Private cContaGrv	:= ""
	Private cCodEmp		:= ""
	Private aCols		:={}
	Private aAuxAcols	:={}
	Private nTipoBol    := 0

	If !LisDir( cDirBol )
		MakeDir( "\FTP" )
		MakeDir( "\FTP\" + cEmpAnt )
		MakeDir( "\FTP\" + cEmpAnt + "\V5FIN005\" )
	EndIf

	If Alltrim(SM0->M0_CODIGO)=="V5" // VOGEL.
		cPortGrv    := "001"
		cAgeGrv     := "3347 "
		cContaGrv   := "99958090"
		cCodEmp		:= "3094799"
	ElseIf Alltrim(SM0->M0_CODIGO) $ "FA" // SOUTH (Sul Americana).
		cPortGrv    := "001"
		cAgeGrv     := "3347 "
		cContaGrv   := "99963213"
		cCodEmp		:= "3094816"
	ElseIf Alltrim(SM0->M0_CODIGO) $ "FC" // Smart Soluctions.
		cPortGrv    := "001"
		cAgeGrv     := "3347 "
		cContaGrv   := "99901838"
		cCodEmp		:= "3094805"
	ElseIf Alltrim(SM0->M0_CODIGO) $ "G4" // SOUTHTECH Telefonia.
		cPortGrv    := "001"
		cAgeGrv     := "3347 "
		cContaGrv   := "99062585"
		cCodEmp		:= "3094811"
	ElseIf Alltrim(SM0->M0_CODIGO) $ "V6" // TELBRAX.
		cPortGrv    := "001"
		cAgeGrv     := "3347 "
		cContaGrv   := "91362903"
		cCodEmp		:= "3094814"
	EndIf

	If Empty(cPortGrv) .Or. Empty(cAgeGrv) .Or. Empty(cContaGrv)
		If _lWs
			Aviso("Aviso","Portador não informado, o boleto não será impresso.", {"Abandonar"}, 2)
		Else
			Conout("Portador não informado, o boleto não será impresso.")
		EndIf
		Return 
	EndIf

	SC5->( DbSetOrder( 1 ) , DbSeek( xFilial() + SQL->E1_PEDIDO )  )

	cFileName := "Boleto_" +LOWER(ALLtrim(SE1->E1_PREFIXO))+"_"+  AllTrim( SF2->F2_DOC ) // + "_" + AllTrim( SC5->C5_P_REF )

	Do While SQL->(!EOF())

		DbSelectArea("SE1")
		SE1->(DbGoTo(SQL->RECNUM))

		//Posiciona o SA6 (Bancos)
		If Empty(SE1->E1_PORTADO)
			DbSelectArea("SA6")
			DbSetOrder(1)
			IF DbSeek(xFilial("SA6") + cPortGrv + cAgeGrv + cContaGrv)
				RecLock("SE1",.F.)
				SE1->E1_PORTADO := SA6->A6_COD
				SE1->E1_AGEDEP  := SA6->A6_AGENCIA
				SE1->E1_CONTA   := SA6->A6_NUMCON
				MsUnLock()
			EndIf
		EndIf

		SQL->(DbSkip())
	EndDo

	ProcRegua(SQL->(RecCount()))

	SQL->(dbGoTop())

	If lPreview
		cDirBol := GetTempPath()
	Endif

	//Protecao contra arquivo .rel
	If File(cDirBol+cFileName + ".pdf")
		lErroArq := .T.
		While nCont < 10
			If FErase(cDirBol+cFileName + ".pdf") == 0 
				lErroArq := .F.
				Exit
			Endif 
			nCont++
			Return .F.
		EndDo
	Endif 
	
	if !lSelAuto .And. !_lCapa
		//oPrint  := TMSPrinter():New("Boleto Laser")

		oPrint:= FWMSPrinter():New(cFileName,IMP_PDF,.T./*.F.*/,cDirBol,.T.,.F.,,,,,,.T.,0)
		oPrint:Setup()
		oPrint:SetPortrait()			// ou SetLandscape()
		oPrint:SetPaperSize(9)			// Seta para papel A4
		//oPrint:StartPage()				// Inicia uma nova pagina
	else
		If !lPreview
			oPrint:= FWMSPrinter():New(cFileName,IMP_PDF,.T./*.F.*/,cDirBol,.T.,.F.,,,,,,.F.,0)
		Else
			oPrint:= FWMSPrinter():New(cFileName,IMP_PDF,.T./*F.*/,cDirBol,.T.,.F.,,,,,,.T.,0)
		EndIf

		oPrint:SetResolution(72)
		oPrint:SetPortrait()			// ou SetLandscape()
		oPrint:nDevice := IMP_PDF
		If !_lWs
			oPrint:cPathPDF := cLocal
		Else
			oPrint:cPathPDF :=  cDirBol
			oPrint:lServer := _lWs
		EndIf
		oPrint:SetPaperSize(DMPAPER_A4) 				// Seta para papel A4
		//oPrint:SetMargin(60,60,60,60)
	endif

	SQL->(dbGoTop())
	ProcRegua(SQL->(RecCount()))
	WHILE SQL->(!EOF())

		DbSelectArea("SE1")
		SE1->(DbGoTo(SQL->RECNUM))

		If Empty(SE1->E1_PORTADO)
			SQL->(DBSKIP())
			LOOP
		EndIf

		If SE1->E1_PORTADO $ "341|033"
			SQL->(dbSkip())
			Loop
		EndIf

		// Posiciona o SA6 (Bancos)
		dbSelectArea("SA6")
		dbSetOrder(1)
		dbSeek(xFilial("SA6")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA,.T.)
		// Posiciona na Arq de Parametros CNAB
		dbSelectArea("SEE")
		dbSetOrder(1)
		dbSeek(xFilial("SEE")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA),.T.)
		// Posiciona o SA1 (Cliente)
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.)
		// Seleciona o SE1 (Contas a Receber)
		dbSelectArea("SE1")
		aDadosBanco := {SA6->A6_COD,;											  // [1]Numero do Banco
		"Banco do Brasil",;										  // [2]Nome do Banco
		SUBSTR(SA6->A6_AGENCIA,1,4),;							  // [3]Agencia
		SUBSTR(SA6->A6_NUMCON,1,Len(AllTrim(SA6->A6_NUMCON))-1),; // [4]Conta Corrente
		SUBSTR(SA6->A6_NUMCON,Len(AllTrim(SA6->A6_NUMCON)),1),;	  // [5]Digito da conta corrente
		AllTrim(SEE->EE_CODCART)}								  // [6]Codigo da Carteira
		IF EMPTY(SA1->A1_ENDCOB)
			aDatSacado := {	AllTrim(SA1->A1_NOME),;								  // [1]Razao Social
			AllTrim(SA1->A1_COD)+"-"+SA1->A1_LOJA,;				  // [2]Codigo
			AllTrim(SA1->A1_END)+"-"+AllTrim(SA1->A1_BAIRRO),;	  // [3]Endereco
			AllTrim(SA1->A1_MUN),;								  // [4]Cidade
			SA1->A1_EST,;										  // [5]Estado
			SA1->A1_CEP,;										  // [6]CEP
			SA1->A1_CGC,;
			SA1->A1_COMPLEM}										  // [7]CGC
		ELSE
			aDatSacado := {	AllTrim(SA1->A1_NOME),;								  // [1]Razao Social
			AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA,;			  // [2]Codigo
			AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(IIF(EMPTY(SA1->A1_BAIRROC),AllTrim(SA1->A1_BAIRRO),AllTrim(SA1->A1_BAIRROC))),;// [3]Endereco
			AllTrim(IIF(EMPTY(SA1->A1_MUNC),AllTrim(SA1->A1_MUN),AllTrim(SA1->A1_MUNC))) ,;								  // [4]Cidade
			AllTrim(IIF(EMPTY(SA1->A1_ESTC),AllTrim(SA1->A1_EST),AllTrim(SA1->A1_ESTC))),;										  // [5]Estado
			AllTrim(IIF(EMPTY(SA1->A1_CEPC),AllTrim(SA1->A1_CEP),AllTrim(SA1->A1_CEPC))) ,;										  // [6]CEP
			SA1->A1_CGC,;
			SA1->A1_COMPLEM}										  // [7]CGC
		ENDIF

		_nVlrAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
		_nTamNN   := 10 // Tamanho do nosso numero.

		If Empty(SE1->E1_NUMBCO)

			RecLock('SEE', .F.) // Travo o registro do Parametro de Banco para garantir a integridade e evitar duplicidade de numeros.

			nTam   := TamSx3("EE_FAXATU")[1]
			nTamE1 := TamSx3("E1_NUMBCO")[1]

			cNumero := StrZero(Val(SEE->EE_FAXATU), _nTamNN)

			_lAchou := .F.

			While !_lAchou

				cNroDoc := cNumero + AllTrim(Str(Modulo11(cNumero)))

				_cQrySE1 := "SELECT E1_NUMBCO "
				_cQrySE1 += "FROM " + RetSqlName('SE1') + " SE1 "
				_cQrySE1 += "WHERE SE1.D_E_L_E_T_ = '' "
				_cQrySE1 += "AND SE1.E1_FILIAL = '" + xFilial('SE1') + "' "
				_cQrySE1 += "AND SE1.E1_NUMBCO = '" + cNroDoc + "' "
				_cQrySE1 += "AND SE1.E1_PORTADO = '" + cPortGrv + "' "
				_cQrySE1 += "AND SE1.E1_AGEDEP = '" + cAgeGrv + "' "
				_cQrySE1 += "AND SE1.E1_CONTA = '" + cContaGrv + "' "

				TcQuery _cQrySE1 New Alias 'SE1NN'

				If SE1NN->(EOF())
					_lAchou := .T.
				EndIf

				SE1NN->(DbCloseArea())

				cNumero := Soma1(cNumero, _nTamNN) // Busca o proximo numero disponivel.

			EndDo

			RecLock("SE1", .F.)
			SE1->E1_NUMBCO := cNroDoc // Nosso numero com digito.
			SE1->(MsUnlock())

			// Atualiza a faixa atual com o proximo numero disponivel (sem digito).
			SEE->EE_FAXATU := StrZero(Val(cNumero), _nTamNN)

			SEE->(MsUnlock())

			cNroDoc := SubStr(AllTrim(cNroDoc), 1, _nTamNN)

		Else

			cNroDoc := SubStr(AllTrim(SE1->E1_NUMBCO), 1, _nTamNN) // Retiro o digito. A função Ret_cBarra() irá recalcular o mesmo e montar o nosso numero com a carteira.

		EndIf

		DbSelectArea("SE1")

		nSaldo   := (E1_SALDO - _nVlrAbat - E1_DECRESC + E1_ACRESC)
		_dDtVenc := E1_VENCREA
		_nValor  := nSaldo

		If _lMulta

			If dDataBase > SE1->E1_VENCREA
				_nMulta := Round(_nValor * (_nPerMul / 100), TamSx3('E1_VALOR')[1])
				_nJuros := Round((((_nValor * (_nPerJur / 100)) / 30) * DateDiffDay(dDataBase, SE1->E1_VENCREA)), TamSx3('E1_VALOR')[1])
			EndIf
			//_nValor  := _nValor + _nMulta + _nJuros
			//_dDtVenc := dDataBase

		EndIf

		nSaldo := _nValor

		CB_RN_NN := Ret_cBarra(aDadosBanco[1],aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],cNroDoc,nSaldo,_dDtVenc)

		// Rotina de titulos em atraso, retorna a linha digitavel
		If IsInCallStack("U_VOGWF02")
			cLinDig := CB_RN_NN[2]
		Endif

		If _lCapa .And. _lDados

			SQL->(DbCloseArea())

			Return {CB_RN_NN, nSaldo, _dDtVenc}

		EndIf

		aDadosTit := {	AllTrim(E1_NUM),;			// [1] Numero do Titulo
		E1_EMISSAO,;									// [2] Data da Emissao do Titulo
		Date(),;										// [3] Data da Emissao do Boleto
		_dDtVenc,;										// [4] Data do Vencimento
		nSaldo,;   										// [5] Valor do Titulo Liquido
		CB_RN_NN[3],;									// [6] Nosso Numero (Ver Formula para Calculo)
		E1_PREFIXO,;									// [7] Prefixo da NF
		'DM',;											// [8] Tipo do Titulo
		E1_DECRESC,;                            		// [9] Desconto
		E1_ACRESC,;                              		//[10] Acrecimos
		nSaldo }                              		    //[11] Valor do Titulo Bruto

		IF .t. //aMarked[i]
			Impress(oPrint,aBMP,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)
			n := n + 1
		ENDIF

		SQL->(dbSkip())

		If _lWs
			SQL->(INCPROC())
		EndIf
		i := i + 1
	ENDDO

	If !_lWs
		If File( cLocal+cFileName+".pdf" )
			FErase(cLocal+cFileName+".pdf")
		EndIf

		If lPreview
			Sleep(4000)
			oPrint:Preview()
		Else
			Sleep(4000)
			oPrint:Print(cDirBol+cFileName)
			//U_VOGATU10(cDirBol+cFileName+".pdf")
			If CpyT2S( cLocal + cFileName + ".pdf" , cDirBol ,.T. )
				cFile := cDirBol + cFileName+".pdf"
				For _nT := 1 To 5 // 5 tentativas para aguardar o upload do arquivo para o servidor.
					If !(File(cFile)) // Se não encontrou o arquivo no servidor.
						Sleep(2000) // Aguarda 2 segundos.
					Else
						Exit // Se encontrou, sai do loop de tentativas.
					EndIf
				Next _nT
				If _nT > 5
					cFile := '' // Caso não consiga copiar o arquivo para o servidor, retornar vazio para que o processo seja interrompido.
				EndIf

				lErroArq := ! U_VOGATU10(cDirBol+cFileName+".pdf")
				
			Else
				MsgStop( 'Erro na cópia para o servidor, boleto ' + cFileName+  ".pdf" )
			EndIf
		EndIf

	Else
		If File(cDirBol + cFileName + ".pdf")
			FErase( cDirBol + cFileName + ".pdf")
		EndIf

		Sleep(4000)
		oPrint:Print()

		cFile := cDirBol + cFileName + ".pdf"
	EndIf

	SQL->(DbCloseArea())

RETURN( cFile )

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³ Funcao    ³ IMPRESS()   ³ Autor ³ Flavio Novaes    ³ Data ³ 03/02/2005 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Descricao ³ Impressao de Boleto Bancario do Banco do Brasil com Codigo ³±±
	±±³           ³ de Barras, Linha Digitavel e Nosso Numero.                 ³±±
	±±³           ³ Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso       ³ FINANCEIRO                                                 ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

STATIC FUNCTION Impress(oPrint,aBitmap,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)
	LOCAL oFont8
	LOCAL oFont10
	LOCAL oFont16
	LOCAL oFont16n
	LOCAL oFont18n
	LOCAL oFont14n
	LOCAL oFont24
	LOCAL i        := 0
	LOCAL _nLin    := 0//200
	LOCAL aCoords1 := {0150,1900,0550,2300}
	LOCAL aCoords2 := {0450,1050,0550,1900}
	LOCAL aCoords3 := {_nLin+0710,1900,_nLin+0810,2300}
	LOCAL aCoords4 := {_nLin+0980,1900,_nLin+1050,2300}
	LOCAL aCoords5 := {_nLin+1330,1900,_nLin+1400,2300}
	LOCAL aCoords6 := {_nLin+2000,1900,_nLin+2100,2300}
	LOCAL aCoords7 := {_nLin+2270,1900,_nLin+2340,2300}
	LOCAL aCoords8 := {_nLin+2620,1900,_nLin+2690,2300}
	LOCAL oBrush
	Local nSalto   := 18

	Local cBBLogo:="bblogo.bmp"

	SET DATE FORMAT "dd/mm/yyyy"

// Parâmetros de TFont.New()
// 1.Nome da Fonte (Windows)
// 3.Tamanho em Pixels
// 5.Bold (T/F)
	oFont8  := TFont():New("Arial",9,08,.T.,.F.,5,.T.,5,.T.,.F.)
//oFont10 := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont10 := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont16 := TFont():New("Arial",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont16n:= TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont18n:= TFont():New("Arial",9,18,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont14n:= TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont24 := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
	oBrush  := TBrush():New("",4)
	oPrint:StartPage()	// Inicia uma nova Pagina

// Inicia aqui a alteracao para novo layout - RAI
	oPrint:Line(0150,0560,0050,0560)
	oPrint:Line(0150,0800,0050,0800)
//oPrint:Say (0084,0100,aDadosBanco[2],oFont16)					// [2] Nome do Banco
	oPrint:SayBitmap(0050,0100,cBBLogo,430,90 )

	oPrint:Say (nSalto+0082,0567,aDadosBanco[1]+"-9",oFont24)					// [1] Numero do Banco
	oPrint:Say (nSalto+0084,1870,"Comprovante de Entrega",oFont10)
	oPrint:Line(0150,0100,0150,2300)
	oPrint:Say (nSalto+0150,0100,"Beneficiário",oFont8)
	oPrint:Say (nSalto+0200,0100,aDadosEmp[1]	,oFont10)					// [1] Nome + CNPJ
	oPrint:Say (nSalto+0150,1060,"Agência/Código do Benefeciário",oFont8)
	oPrint:Say (nSalto+0200,1060,aDadosBanco[3]+"/"+aDadosBanco[4]+aDadosBanco[5],oFont10)
	oPrint:Say (nSalto+0150,1510,"Nro.Documento",oFont8)
	oPrint:Say (nSalto+0200,1510,aDadosTit[1],oFont10)	// [7] Prefixo + [1] Numero + Parcela
	oPrint:Say (nSalto+0250,0100,"Pagador",oFont8)
	oPrint:Say (nSalto+0300,0100,aDatSacado[1],oFont10)					// [1] Nome
	oPrint:Say (nSalto+0250,1060,"Vencimento",oFont8)
	oPrint:Say (nSalto+0300,1060,DTOC(aDadosTit[4]),oFont10)
	oPrint:Say (nSalto+0250,1510,"Valor do Documento",oFont8)
	oPrint:Say (nSalto+0300,1550,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)
	oPrint:Say (nSalto+0400,0100,"Recebi(emos) o bloqueto/título",oFont10)
	oPrint:Say (nSalto+0450,0100,"com as características acima.",oFont10)
	oPrint:Say (nSalto+0350,1060,"Data",oFont8)
	oPrint:Say (nSalto+0350,1410,"Assinatura",oFont8)
	oPrint:Say (nSalto+0450,1060,"Data",oFont8)
	oPrint:Say (nSalto+0450,1410,"Entregador",oFont8)
	oPrint:Line(0250,0100,0250,1900)
	oPrint:Line(0350,0100,0350,1900)
	oPrint:Line(0450,1050,0450,1900) //---
	oPrint:Line(0550,0100,0550,2300)
	oPrint:Line(0550,1050,0150,1050)
	oPrint:Line(0550,1400,0350,1400)
	oPrint:Line(0350,1500,0150,1500) //--
	oPrint:Line(0550,1900,0150,1900)
	oPrint:Say (nSalto+0150,1910,"(  )Mudou-se",oFont8)
	oPrint:Say (nSalto+0190,1910,"(  )Ausente",oFont8)
	oPrint:Say (nSalto+0230,1910,"(  )Não existe nº indicado",oFont8)
	oPrint:Say (nSalto+0270,1910,"(  )Recusado",oFont8)
	oPrint:Say (nSalto+0310,1910,"(  )Não procurado",oFont8)
	oPrint:Say (nSalto+0350,1910,"(  )Endereço insuficiente",oFont8)
	oPrint:Say (nSalto+0390,1910,"(  )Desconhecido",oFont8)
	oPrint:Say (nSalto+0430,1910,"(  )Falecido",oFont8)
	oPrint:Say (nSalto+0470,1910,"(  )Outros(anotar no verso)",oFont8)
	FOR i := 100 TO 2300 STEP 50
		oPrint:Line(_nLin+0600,i,_nLin+0600,i+30)
	NEXT i

	oPrint:Line(_nLin+0710,0100,_nLin+0710,2300)
	oPrint:Line(_nLin+0710,0560,_nLin+0610,0560)
	oPrint:Line(_nLin+0710,0800,_nLin+0610,0800)
//oPrint:Say (nSalto+nSalto+_nLin+0644,0100,aDadosBanco[2],oFont16)	// [2]Nome do Banco
	oPrint:SayBitmap(_nLin+0610,0100,cBBLogo,430,90 )
	oPrint:Say (nSalto+_nLin+0652,0567,aDadosBanco[1]+"-9",oFont24)	// [1]Numero do Banco
	oPrint:Say (nSalto+_nLin+0604,1900,"Recibo do Pagador",oFont10)
	oPrint:Say (nSalto+_nLin+0650,0820,CB_RN_NN[2],oFont18n)		// [2] Linha Digitavel do Codigo de Barras
	oPrint:Line(_nLin+0810,0100,_nLin+0810,2300)
	oPrint:Line(_nLin+0910,0100,_nLin+0910,2300)
	oPrint:Line(_nLin+0980,0100,_nLin+0980,2300)
	oPrint:Line(_nLin+1050,0100,_nLin+1050,2300)
	oPrint:Line(_nLin+0910,0500,_nLin+1050,0500)
	oPrint:Line(_nLin+0980,0750,_nLin+1050,0750)
	oPrint:Line(_nLin+0910,1000,_nLin+1050,1000)
	oPrint:Line(_nLin+0910,1350,_nLin+0980,1350)
	oPrint:Line(_nLin+0910,1550,_nLin+1050,1550)
	oPrint:Say (nSalto+_nLin+0710,0100,"Local de Pagamento",oFont8)
	oPrint:Say (nSalto+_nLin+0750,0100,"Pagável em qualquer banco até o vencimento",oFont10)
//oPrint:Say (nSalto+_nLin+0750,0100,"ATE O VENCIMENTO PAGUE PREFERENCIALMENTE NO SANTANDER",oFont8)
//oPrint:Say (nSalto+_nLin+0775,0100,"APOS O VENCIMENTO PAGUE SOMENTE NO SANTANDER",oFont8)
	oPrint:Say (nSalto+_nLin+0710,1910,"Vencimento",oFont8)
	oPrint:Say (nSalto+_nLin+0750,1950,DTOC(aDadosTit[4]),oFont10)
	oPrint:Say (nSalto+_nLin+0810,0100,"Beneficiário",oFont8)
	oPrint:Say (nSalto+_nLin+0835,0100,aDadosEmp[1]+"             - "+aDadosEmp[6],oFont10) //Nome + CNPJ
	oPrint:Say (nSalto+_nLin+0870,0100,AllTrim(aDadosEmp[2])+" "+AllTrim(aDadosEmp[3])+" "+AllTrim(aDadosEmp[4]),oFont10) //End
	oPrint:Say (nSalto+_nLin+0810,1910,"Agência/Código do Benefeciário",oFont8)
	oPrint:Say (nSalto+_nLin+0850,1950,aDadosBanco[3]+"/"+aDadosBanco[4]+aDadosBanco[5],oFont10)
	oPrint:Say (nSalto+_nLin+0910,0100,"Data do Documento",oFont8)
	oPrint:Say (nSalto+_nLin+0940,0100,DTOC(aDadosTit[2]),oFont10) // Emissao do Titulo (E1_EMISSAO)
	oPrint:Say (nSalto+_nLin+0910,0505,"Nro.Documento",oFont8)
	oPrint:Say (nSalto+_nLin+0940,0605,aDadosTit[1],oFont10) //Prefixo +Numero+Parcela
	oPrint:Say (nSalto+_nLin+0910,1005,"Espécie Doc.",oFont8)
	oPrint:Say (nSalto+_nLin+0940,1050,aDadosTit[8],oFont10) //Tipo do Titulo
	oPrint:Say (nSalto+_nLin+0910,1355,"Aceite",oFont8)
	oPrint:Say (nSalto+_nLin+0940,1455,"N",oFont10)
	oPrint:Say (nSalto+_nLin+0910,1555,"Data do Processamento",oFont8)
	oPrint:Say (nSalto+_nLin+0940,1655,DTOC(aDadosTit[3]),oFont10) // Data impressao
	oPrint:Say (nSalto+_nLin+0910,1910,"Nosso Número",oFont8)
	oPrint:Say (nSalto+_nLin+0940,1950,aDadosTit[6],oFont10)
//oPrint:Say (nSalto+_nLin+0940,1950,PADL(alltrim(SUBSTR(aDadosTit[6],4)),14,'0'),oFont10)
	oPrint:Say (nSalto+_nLin+0980,0100,"Uso do Banco",oFont8)
	oPrint:Say (nSalto+_nLin+0980,0505,"Carteira",oFont8)
	oPrint:Say (nSalto+_nLin+1010,0555,aDadosBanco[6],oFont10)
	oPrint:Say (nSalto+_nLin+0980,0755,"Espécie",oFont8)
	oPrint:Say (nSalto+_nLin+1010,0805,"R$",oFont10)
	oPrint:Say (nSalto+_nLin+0980,1005,"Quantidade",oFont8)
	oPrint:Say (nSalto+_nLin+0980,1555,"Valor",oFont8)
	oPrint:Say (nSalto+_nLin+0980,1910,"Valor do Documento",oFont8)
	oPrint:Say (nSalto+_nLin+1010,1950,AllTrim(Transform(aDadosTit[11],"@E 999,999,999.99")),oFont10)//JSS Alterado para solução do caso 031197
	oPrint:Say (nSalto+_nLin+1050,0100,"Informações de responsabilidade do beneficiário",oFont8)
	oPrint:Say (nSalto+_nLin+1150,0100,aBolText[1],oFont10)
	oPrint:Say (nSalto+_nLin+1200,0100,aBolText[2],oFont10)
//oPrint:Say (nSalto+_nLin+1200,0100,aBolText[2]+" "+AllTrim(Transform(((aDadosTit[5]*0.01)/30),"@E 99,999.99")),oFont10)
	oPrint:Say (nSalto+_nLin+1250,0100,aBolText[3],oFont10)
	oPrint:Say (nSalto+_nLin+1050,1910,"(-)Desconto/Abatimento",oFont8)
//oPrint:Say (nSalto+_nLin+1080,1950,AllTrim(Transform(aDadosTit[9],"@E 999,999,999.99")),oFont10) 
	oPrint:Say (nSalto+_nLin+1120,1910,"(-)Outras Deduções",oFont8)
	oPrint:Say (nSalto+_nLin+1190,1910,"(+)Mora/Multa",oFont8)
	oPrint:Say (nSalto+_nLin+1260,1910,"(+)Outros Acréscimos",oFont8)
//oPrint:Say (nSalto+_nLin+1290,1950,AllTrim(Transform(aDadosTit[10],"@E 999,999,999.99")),oFont10) 
	oPrint:Say (nSalto+_nLin+1330,1910,"(=)Valor Cobrado",oFont8)
	oPrint:Say (nSalto+_nLin+1360,1950,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)
	oPrint:Say (nSalto+_nLin+1400,0100,"Pagador",oFont8)
	oPrint:Say (nSalto+_nLin+1430,0400,aDatSacado[1]+" ("+aDatSacado[2]+")",oFont10)
	oPrint:Say (nSalto+_nLin+1483,0400,aDatSacado[3] +" "+ aDatSacado[8],oFont10)
	oPrint:Say (nSalto+_nLin+1536,0400,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado
	oPrint:Say (nSalto+_nLin+1589,0400,"C.N.P.J.: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
//oPrint:Say (nSalto+_nLin+1589,1950,SUBSTR(aDadosTit[6],1,3)+"/00"+SUBSTR(aDadosTit[6],4,8),oFont10)
	oPrint:Say (nSalto+_nLin+1589,1950,aDadosTit[6],oFont10)
	oPrint:Say (nSalto+_nLin+1605,0100,"Pagador/Avalista",oFont8)
	oPrint:Say (nSalto+_nLin+1645,1500,"Autenticação Mecânica -",oFont8)
	oPrint:Say (nSalto+_nLin+1645,1850,"Ficha de Compensação",oFont8)
	oPrint:Line(_nLin+0710,1900,_nLin+1400,1900)
	oPrint:Line(_nLin+1120,1900,_nLin+1120,2300)
	oPrint:Line(_nLin+1190,1900,_nLin+1190,2300)
	oPrint:Line(_nLin+1260,1900,_nLin+1260,2300)
	oPrint:Line(_nLin+1330,1900,_nLin+1330,2300)
	oPrint:Line(_nLin+1400,0100,_nLin+1400,2300)
	oPrint:Line(_nLin+1640,0100,_nLin+1640,2300)

	_nLin := _nLin - 110
	FOR i := 100 TO 2300 STEP 50
		oPrint:Line(_nLin+1890,i,_nLin+1890,i+30)
	NEXT i
// Encerra aqui a alteracao para o novo layout - RAI
	oPrint:Line(_nLin+2000,0100,_nLin+2000,2300)
	oPrint:Line(_nLin+2000,0560,_nLin+1900,0560)
	oPrint:Line(_nLin+2000,0800,_nLin+1900,0800)
//oPrint:Say (nSalto+_nLin+1934,0100,aDadosBanco[2],oFont16)	// [2] Nome do Banco
	oPrint:SayBitmap(_nLin+1900,0100,cBBLogo,430,90 )
	oPrint:Say (nSalto+_nLin+1937,0567,aDadosBanco[1]+"-9",oFont24)	// [1] Numero do Banco
	oPrint:Say (nSalto+_nLin+1934,0820,CB_RN_NN[2],oFont18n)		// [2] Linha Digitavel do Codigo de Barras
	oPrint:Line(_nLin+2100,0100,_nLin+2100,2300)
	oPrint:Line(_nLin+2200,0100,_nLin+2200,2300)
	oPrint:Line(_nLin+2270,0100,_nLin+2270,2300)
	oPrint:Line(_nLin+2340,0100,_nLin+2340,2300)
	oPrint:Line(_nLin+2200,0500,_nLin+2340,0500)
	oPrint:Line(_nLin+2270,0750,_nLin+2340,0750)
	oPrint:Line(_nLin+2200,1000,_nLin+2340,1000)
	oPrint:Line(_nLin+2200,1350,_nLin+2270,1350)
	oPrint:Line(_nLin+2200,1550,_nLin+2340,1550)
	oPrint:Say (nSalto+_nLin+2000,0100,"Local de Pagamento",oFont8)
//oPrint:Say (nSalto+_nLin+2040,0100,"ATE O VENCIMENTO PAGUE PREFERENCIALMENTE NO SANTANDER",oFont8)
//oPrint:Say (nSalto+_nLin+2065,0100,"APOS O VENCIMENTO PAGUE SOMENTE NO SANTANDER",oFont8)
	oPrint:Say (nSalto+_nLin+2040,0100,"Pagável em qualquer banco até o vencimento",oFont10)
	oPrint:Say (nSalto+_nLin+2000,1910,"Vencimento",oFont8)
	oPrint:Say (nSalto+_nLin+2040,1950,DTOC(aDadosTit[4]),oFont10)
	oPrint:Say (nSalto+_nLin+2100,0100,"Beneficiário",oFont8)
	oPrint:Say (nSalto+_nLin+2125,0100,aDadosEmp[1]+"             - "+aDadosEmp[6],oFont10) //Nome + CNPJ
	oPrint:Say (nSalto+_nLin+2160,0100,AllTrim(aDadosEmp[2])+" "+AllTrim(aDadosEmp[3])+" "+AllTrim(aDadosEmp[4]),oFont10) //End
	oPrint:Say (nSalto+_nLin+2100,1910,"Agência/Código do Benefeciário",oFont8)
	oPrint:Say (nSalto+_nLin+2140,1950,aDadosBanco[3]+"/"+aDadosBanco[4]+aDadosBanco[5],oFont10)
	oPrint:Say (nSalto+_nLin+2200,0100,"Data do Documento",oFont8)
	oPrint:Say (nSalto+_nLin+2230,0100,DTOC(aDadosTit[2]),oFont10)			// Emissao do Titulo (E1_EMISSAO)
	oPrint:Say (nSalto+_nLin+2200,0505,"Nro.Documento",oFont8)
	oPrint:Say (nSalto+_nLin+2230,0605,aDadosTit[1],oFont10)	//Prefixo + Numero + Parcela
	oPrint:Say (nSalto+_nLin+2200,1005,"Espécie Doc.",oFont8)
	oPrint:Say (nSalto+_nLin+2230,1050,aDadosTit[8],oFont10)					//Tipo do Titulo
	oPrint:Say (nSalto+_nLin+2200,1355,"Aceite",oFont8)
	oPrint:Say (nSalto+_nLin+2230,1455,"N",oFont10)
	oPrint:Say (nSalto+_nLin+2200,1555,"Data do Processamento",oFont8)
	oPrint:Say (nSalto+_nLin+2230,1655,DTOC(aDadosTit[3]),oFont10) // Data impressao
	oPrint:Say (nSalto+_nLin+2200,1910,"Nosso Número",oFont8)
	oPrint:Say (nSalto+_nLin+2230,1950,aDadosTit[6],oFont10)
//oPrint:Say (nSalto+_nLin+2230,1950,PADL(alltrim(SUBSTR(aDadosTit[6],4)),14,'0'),oFont10)
	oPrint:Say (nSalto+_nLin+2270,0100,"Uso do Banco",oFont8)
	oPrint:Say (nSalto+_nLin+2270,0505,"Carteira",oFont8)
	oPrint:Say (nSalto+_nLin+2300,0555,aDadosBanco[6],oFont10)
	oPrint:Say (nSalto+_nLin+2270,0755,"Espécie",oFont8)
	oPrint:Say (nSalto+_nLin+2300,0805,"R$",oFont10)
	oPrint:Say (nSalto+_nLin+2270,1005,"Quantidade",oFont8)
	oPrint:Say (nSalto+_nLin+2270,1555,"Valor",oFont8)
	oPrint:Say (nSalto+_nLin+2270,1910,"Valor do Documento",oFont8)
	oPrint:Say (nSalto+_nLin+2300,1950,AllTrim(Transform(aDadosTit[11],"@E 999,999,999.99")),oFont10)
	oPrint:Say (nSalto+_nLin+2340,0100,"Informações de responsabilidade do beneficiário",oFont8)
	oPrint:Say (nSalto+_nLin+2440,0100,aBolText[1],oFont10)
	oPrint:Say (nSalto+_nLin+2490,0100,aBolText[2],oFont10)
//oPrint:Say (nSalto+_nLin+2490,0100,aBolText[2]+" "+AllTrim(Transform(((aDadosTit[5]*0.01)/30),"@E 99,999.99")),oFont10)
	oPrint:Say (nSalto+_nLin+2540,0100,aBolText[3],oFont10)
	oPrint:Say (nSalto+_nLin+2340,1910,"(-)Desconto/Abatimento",oFont8)
//oPrint:Say (nSalto+_nLin+2370,1950,AllTrim(Transform(aDadosTit[9],"@E 999,999,999.99")),oFont10) 
	oPrint:Say (nSalto+_nLin+2410,1910,"(-)Outras Deduções",oFont8)
	oPrint:Say (nSalto+_nLin+2480,1910,"(+)Mora/Multa",oFont8)
	oPrint:Say (nSalto+_nLin+2550,1910,"(+)Outros Acréscimos",oFont8)
//oPrint:Say (nSalto+_nLin+2580,1950,AllTrim(Transform(aDadosTit[10],"@E 999,999,999.99")),oFont10)
	oPrint:Say (nSalto+_nLin+2620,1910,"(=)Valor Cobrado",oFont8)
	oPrint:Say (nSalto+_nLin+2650,1950,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)
	oPrint:Say (nSalto+_nLin+2690,0100,"Pagador",oFont8)
	oPrint:Say (nSalto+_nLin+2720,0400,aDatSacado[1]+" ("+aDatSacado[2]+")",oFont10)
	oPrint:Say (nSalto+_nLin+2773,0400,aDatSacado[3],oFont10)
	oPrint:Say (nSalto+_nLin+2826,0400,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10)	// CEP+Cidade+Estado
	oPrint:Say (nSalto+_nLin+2879,0400,"C.N.P.J.: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10)	// CGC
	oPrint:Say (nSalto+_nLin+2879,1950,aDadosTit[6],oFont10)
//oPrint:Say (nSalto+_nLin+2879,1950,SUBSTR(aDadosTit[6],4,len(aDadosTit[6])-3),oFont10)
	oPrint:Say (nSalto+_nLin+2895,0100,"Pagador/Avalista",oFont8)
	oPrint:Say (nSalto+_nLin+2935,1500,"Autenticação Mecânica -",oFont8)
	oPrint:Say (nSalto+_nLin+2935,1850,"Ficha de Compensação",oFont8)
	oPrint:Line(_nLin+2000,1900,_nLin+2690,1900)
	oPrint:Line(_nLin+2410,1900,_nLin+2410,2300)
	oPrint:Line(_nLin+2480,1900,_nLin+2480,2300)
	oPrint:Line(_nLin+2550,1900,_nLin+2550,2300)
	oPrint:Line(_nLin+2620,1900,_nLin+2620,2300)
	oPrint:Line(_nLin+2690,0100,_nLin+2690,2300)
	oPrint:Line(_nLin+2930,0100,_nLin+2930,2300)

//MSBAR("INT25"  ,27.8,1.5,CB_RN_NN[1],oPrint,.F.,,,,1.4,,,,.F.)   
	cFont:="Helvetica 65 Medium"
	oPrint:FWMSBAR("INT25" /*cTypeBar*/,64.3/*nRow*/ ,2/*nCol*/, CB_RN_NN[1]/*cCode*/,oPrint/*oPrint*/,.F./*lCheck*/,/*Color*/,.T./*lHorz*/,0.017/*nWidth*/,0.95/*0.8*//*nHeigth*/,.F./*lBanner*/, cFont/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,2/*nPFWidth*/,2/*nPFHeigth*/,.F./*lCmtr2Pix*/)


	oPrint:EndPage()	// Finaliza a Pagina
RETURN Nil
/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³ Funcao    ³ MODULO10()  ³ Autor ³ Flavio Novaes    ³ Data ³ 03/02/2005 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Descricao ³ Impressao de Boleto Bancario do Banco Santander com Codigo ³±±
	±±³           ³ de Barras, Linha Digitavel e Nosso Numero.                 ³±±
	±±³           ³ Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso       ³ FINANCEIRO                                                 ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION Modulo10(cData)
	LOCAL L,D,P := 0
	LOCAL B     := .F.
	L := Len(cData)
	B := .T.
	D := 0
	WHILE L > 0
		P := VAL(SUBSTR(cData, L, 1))
		IF (B)
			P := P * 2
			IF P > 9
				P := P - 9
			ENDIF
		ENDIF
		D := D + P
		L := L - 1
		B := !B
	ENDDO
	D := 10 - (Mod(D,10))
	IF D = 10
		D := 0
	ENDIF
RETURN(D)
/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³ Funcao    ³ MODULO11()  ³ Autor ³ Flavio Novaes    ³ Data ³ 03/02/2005 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Descricao ³ Impressao de Boleto Bancario do Banco Santander com Codigo ³±±
	±±³           ³ de Barras, Linha Digitavel e Nosso Numero.                 ³±±
	±±³           ³ Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso       ³ FINANCEIRO                                                 ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION Modulo11(cData,lCodBarra)
	LOCAL L, D, P := 0
	Default lCodBarra := .F.


	L := LEN(cdata)
	D := 0
	P := 1
	WHILE L > 0
		P := P + 1
		D := D + (VAL(SUBSTR(cData, L, 1)) * P)
		IF P == 9
			P := 1
		ENDIF
		L := L - 1
	ENDDO

	D := (mod(D,11))

//Tratamento para digito verificador.
	If lCodBarra //Codigo de Barras
		//Se o resto for 0,1 ou 10 o digito é 1
		IF (D == 0 .Or. D == 1 .Or. D == 10)
			D := 1
		ELSE
			D := 11 - (mod(D,11))
		ENDIF
	Else //Nosso Numero
		IF (D == 0 .Or. D == 1 .Or. D == 10)
			//Se o resto for 0 ou 1 o digito é 0
			IF (D == 0 .Or. D == 1)
				D := 0

				//Se o resto for 10 o digito é 1
			ELSEIF (D == 10)
				D := 1
			ENDIF
		ELSE
			D := 11 - (mod(D,11))
		ENDIF
	EndIf

RETURN(D)

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³Ret_cBarra³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASE DO ITAU COM CODIGO DE BARRAS      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cNroDoc,nValor,dVencto)

	LOCAL cValorFinal 	:= strzero((nValor*100),10)
	LOCAL nDvnn			:= 0
	LOCAL nDvcb			:= 0
	LOCAL nDv			:= 0
	LOCAL cNN			:= ''
	LOCAL cRN			:= ''
	LOCAL cCB			:= ''
	LOCAL cS			:= ''
	LOCAL cFator      	:= Strzero(dVencto - ctod("07/10/97"),4)
	LOCAL cCart			:= AllTrim(SEE->EE_CODCART) //"17" // Código da carteira (2 caracteres).
	Local _cConvenio    := SubStr(AllTrim(SEE->EE_CODEMP), 1, 7) // Codigo do convenio. (7 caracteres).
	Local _nMoeda       := '9' // Codigo da moeda.

//-----------------------------                                      
// Definicao do NOSSO NUMERO
// ----------------------------
//cS    :=  cCart + cNroDoc //19 001000012
	cS    := cNroDoc
	nDvnn := modulo11(cS,.F.) // digito verifacador
	cNNSD := cS //Nosso Numero sem digito
	cNNCD := PADL(cS+AllTrim(Str(nDvnn)),13,'0')
	cNN   := _cConvenio + cNroDoc + '-' + AllTrim(Str(nDvnn))
//----------------------------------
//	 Definicao do CODIGO DE BARRAS
//----------------------------------
	cLivre 	:= Strzero(Val(cAgencia),4)+ cCart + cNNSD + Strzero(Val(cConta),8) + "0"

//cS		:= cBanco + cFator +  cValorFinal + cLivre // + Subs(cNN,1,11) + Subs(cNN,13,1) + cAgencia + cConta + cDacCC + '000'
	cS		:= cBanco + _nMoeda + cFator + cValorFinal + '000000' + _cConvenio + cNroDoc + cCart
	nDvcb 	:= modulo11(cS,.T.)
	cCB   	:= SubStr(cS, 1, 4) + AllTrim(Str(nDvcb)) + SubStr(cS,5)// + SubStr(cS,31)

//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
//	Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
//	AAABC.CCCCX		WWWDD.DDDDDY	FFFFF.FQQQQZ	K			UUUUVVVVVVVVVV

// 	CAMPO 1:
//	AAA	= Codigo do banco na Camara de Compensacao
//	B     = Codigo da moeda, sempre 9
//	CCCCC = 5 primeiros digidos do cLivre
//	X     = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

//**CEDENTE
	cCedente:=SUBSTR(cCodEmp,1,4)// "4806"
//cS    := cBanco + "9" + Substr(cLivre,1,4)
	cS    := cBanco + _nMoeda + SubStr(cCB, 20, 5)
	nDv   := modulo10(cS)  //DAC
	cRN   := SubStr(cS, 1, 5) + '.' + SubStr(cS, 6, 4) + AllTrim(Str(nDv)) + '  '

// 	CAMPO 2:
//	WWW =COD CEDENTE PADRAO
//	DDDDDDD = Posição 14 a 20 do Nosso Numero
//	Y          = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

//**Complemento Cedente
	cCompCed:=SUBSTR(cCodEmp,5,3) //"301"
//cS 	:=Subs(cLivre,6,10)
	cS 	:= SubStr(cCB, 25, 10)
	nDv	:= modulo10(cS)
	cRN	+= SubStr(cS, 1, 5) + '.' + SubStr(cS, 6, 5) + AllTrim(Str(nDv)) + '  '

// 	CAMPO 3:
//	FFFFFF = Posição 22 a 27 do Nosso Numero
//	QQQQ =Tipo de modalidade
//	Z          = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

//**Tipo de modalidade
	cS 	:= SubStr(cCB, 35, 10)
	nDv	:= modulo10(cS)
	cRN	+= SubStr(cS, 1, 5) + '.' + SubStr(cS, 6, 5) + AllTrim(Str(nDv)) + ' '

//	CAMPO 4:
//	     K = DAC do Codigo de Barras
	cRN += AllTrim(Str(nDvcb)) + '  '

// 	CAMPO 5:
//	      UUUU = Fator de Vencimento
//	VVVVVVVVVV = Valor do Titulo
	cRN  += cFator + StrZero((nValor * 100), 14 - Len(cFator))

Return({cCB,cRN,cNN})

/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³ AjustaSx1    ³ Autor ³ Microsiga            	³ Data ³ 13/10/03 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Verifica/cria SX1 a partir de matriz para verificacao          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ Especifico para Clientes Microsiga                    	  		³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1(cPerg, aPergs)

	Local _sAlias	:= Alias()
	Local aCposSX1	:= {}
	Local nX 		:= 0
	Local lAltera	:= .F.
	Local cKey		:= ""
	Local nJ		:= 0
	Local nCondicao

	cPerg := Padr(cPerg,10)

	aCposSX1:={"X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO",;
		"X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID",;
		"X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1","X1_CNT01",;
		"X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02",;
		"X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_CNT03",;
		"X1_VAR04","X1_DEF04","X1_DEFSPA4","X1_DEFENG4","X1_CNT04",;
		"X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5","X1_CNT05",;
		"X1_F3", "X1_GRPSXG", "X1_PYME","X1_HELP" }

	dbSelectArea("SX1")
	dbSetOrder(1)
	For nX:=1 to Len(aPergs)
		lAltera := .F.
		If MsSeek(cPerg+Right(aPergs[nX][11], 2))
			If (ValType(aPergs[nX][Len(aPergs[nx])]) = "B" .And.;
					Eval(aPergs[nX][Len(aPergs[nx])], aPergs[nX] ))
				aPergs[nX] := ASize(aPergs[nX], Len(aPergs[nX]) - 1)
				lAltera := .T.
			Endif
		Endif

		If ! lAltera .And. Found() .And. X1_TIPO <> aPergs[nX][5]
			lAltera := .T.		// Garanto que o tipo da pergunta esteja correto
		Endif

		If ! Found() .Or. lAltera
			RecLock("SX1",If(lAltera, .F., .T.))
			Replace X1_GRUPO with cPerg
			Replace X1_ORDEM with Right(aPergs[nX][11], 2)
			For nj:=1 to Len(aCposSX1)
				If 	Len(aPergs[nX]) >= nJ .And. aPergs[nX][nJ] <> Nil .And.;
						FieldPos(AllTrim(aCposSX1[nJ])) > 0
					Replace &(AllTrim(aCposSX1[nJ])) With aPergs[nx][nj]
				Endif
			Next nj
			MsUnlock()
			cKey := "P."+AllTrim(X1_GRUPO)+AllTrim(X1_ORDEM)+"."

			If ValType(aPergs[nx][Len(aPergs[nx])]) = "A"
				aHelpSpa := aPergs[nx][Len(aPergs[nx])]
			Else
				aHelpSpa := {}
			Endif

			If ValType(aPergs[nx][Len(aPergs[nx])-1]) = "A"
				aHelpEng := aPergs[nx][Len(aPergs[nx])-1]
			Else
				aHelpEng := {}
			Endif

			If ValType(aPergs[nx][Len(aPergs[nx])-2]) = "A"
				aHelpPor := aPergs[nx][Len(aPergs[nx])-2]
			Else
				aHelpPor := {}
			Endif

			PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)
		Endif
	Next

//--------------------------------------------------------------
/*/{Protheus.doc} SELPORT
Description

@param xParam Parameter Description
@return xRet Return Description
@author  - Amedeo D. P. Filho
@since 02/03/2011
/*/
//--------------------------------------------------------------
Static Function SELPORT()

	Local oFont1	:= TFont():New("MS Sans Serif",,020,,.T.,,,,,.F.,.F.)
	Local nOpcA		:= 0

	Private cGet1 	:= Space(TamSx3("A6_COD")[1])
	Private cGet2 	:= Space(TamSx3("A6_AGENCIA")[1])
	Private cGet3 	:= Space(TamSx3("A6_NUMCON")[1])

	Private oGet1
	Private oGet2
	Private oGet3

	Static oDlg

	DEFINE MSDIALOG oDlg TITLE "Selecionar Portador" FROM 000, 000  TO 230, 200 COLORS 0, 16777215 PIXEL Style DS_MODALFRAME

	oDlg:lEscClose	:= .F.

	@ 011, 010 SAY oSay1 PROMPT "Selecione Portador" 	SIZE 080, 012 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
	@ 035, 010 SAY oSay2 PROMPT "Banco :" 				SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 050, 010 SAY oSay3 PROMPT "Agencia :" 			SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 065, 010 SAY oSay4 PROMPT "Conta :" 				SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL

	@ 035, 040 MSGET oGet1 VAR cGet1 SIZE 040, 010 OF oDlg COLORS 0, 16777215 F3 "SANTAN" PIXEL Valid(VALIDBCO())
	@ 050, 040 MSGET oGet2 VAR cGet2 SIZE 040, 010 OF oDlg COLORS 0, 16777215 PIXEL	When .F.
	@ 065, 040 MSGET oGet3 VAR cGet3 SIZE 040, 010 OF oDlg COLORS 0, 16777215 PIXEL	When .F.

	DEFINE SBUTTON oSButton1 FROM 087, 020 TYPE 01 OF oDlg ENABLE Action (nOpcA := 1, oDlg:End())
	DEFINE SBUTTON oSButton2 FROM 087, 051 TYPE 02 OF oDlg ENABLE Action (oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpcA == 1
		cPortGrv	:= cGet1
		cAgeGrv		:= cGet2
		cContaGrv	:= cGet3
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida Banco     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function VALIDBCO()
	Local lRetorno := .T.

	DbSelectarea("SA6")
	DbSetorder(1)
	If DbSeek(xFilial("SA6") + cGet1)
		cGet2 := SA6->A6_AGENCIA
		cGet3 := SA6->A6_NUMCON
		oGet2:Refresh()
		oGet3:Refresh()
	Else
		lRetorno := .F.
		Aviso("Aviso","Banco Inválido!!!",{"Retorna"})
		cGet2 	:= Space(TamSx3("A6_AGENCIA")[1])
		cGet3 	:= Space(TamSx3("A6_NUMCON")[1])
		oGet2:Refresh()
		oGet3:Refresh()
	EndIf

Return lRetorno
