#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#DEFINE VBOX      080
#DEFINE VSPACE    008
#DEFINE HSPACE    010
#DEFINE SAYVSPACE 008
#DEFINE SAYHSPACE 008
#DEFINE HMARGEM   030
#DEFINE VMARGEM   030
#DEFINE MAXITEM   Max((022-Max(0,Len(aMensagem)-02)),1)
#DEFINE MAXITEMP2 055
#DEFINE MAXMENLIN 070

#DEFINE doDTC_SERNFC	1
#DEFINE doDTC_NUMNFC	2
#DEFINE doDTC_EMINFC	3
#DEFINE doDTC_VALOR		4
#DEFINE doDTC_PESO		5
#DEFINE doDTC_CLIDEV	6
#DEFINE doDTC_LOJDEV	7
#DEFINE doDTC_NFEID		8

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RTMSR27   ³ Autor ³Ovio Consultoria       ³ Data ³01/10/20  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao responsavel por imprimir o DACTE.                    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function RTMSR27()
	Local nCount		:= 0
	Local nSoma			:= 0
	Local nCInic		:= 0	// Coluna Inicial
	Local cChaveA		:= ''
	Local cChaveB		:= ''
	Local cTmsAntt		:= SuperGetMv( "MV_TMSANTT", .F., .F. )	//Numero do registro na ANTT com 14 dígitos
	Local cAliasD2		:= ''
	Local cAliasDev		:= ''
	Local aCab			:= {}
	Local aDoc			:= {}
	Local oFont07		:= TFont():New("Times New Roman",07,07,,.F.,,,,.T.,.F.)
	Local oFont07N		:= TFont():New("Times New Roman",07,07,,.T.,,,,.T.,.F.)
	Local oFont08		:= TFont():New("Times New Roman",08,08,,.F.,,,,.T.,.F.)
	Local oFont08N		:= TFont():New("Times New Roman",08,08,,.T.,,,,.T.,.F.)
	Local oFont10N		:= TFont():New("Times New Roman",10,10,,.T.,,,,.T.,.F.)
	Local lControl		:= .F.
	Local cAliasInfNF	:= ''
	Local cAliasSeg		:= ''
	Local cPerg			:= 'RTMSR25'
	Local nCont			:= 0
	Local lSeqDes		:= .F.
	Local lSeqRec		:= .F.
	Local cDT6Obs		:= ''
	Local cDT6Obs2		:= ''
	Local cDTCObs		:= ''
	Local cDTCObs2		:= ''
	Local aObsCont		:= ''
	Local cTipoNF		:= ''
	Local cCtrDpc		:= ''
	Local cSerDpc		:= ''
	Local cTpDocAnt		:= ''
	Local cCTEDocAnt	:= ''
//-- Buscar dados XML
	Local aNotas		:= {}
	Local aXML			:= {}
	Local cAviso		:= ""
	Local cErro			:= ""
	Local cAutoriza		:= ""
	Local cHorAut		:= ""
	Local cDatAut		:= ""
	Local cModalidade	:= ""
	Local cIdEnt		:= ""
	Local nX			:= 0
	Local nY			:= 0
//-- CFOP - Natureza da Prestacao
	Local cCFOP			:= ''
	Local cDescCfop		:= ''
//-- Origem Prestacao
	Local cOriMunPre	:= ""
	Local cOriUFPre		:= ""
//-- Destino Prestacao
	Local cDesMunPre	:= ""
	Local cDesUFPre		:= ""
//-- Remetente
	Local cRemMun		:= ""
	Local cRemUF		:= ""
	Local cRemNome		:= ""
	Local cRemEnd		:= ""
	Local cRemNro		:= ""
	Local cRemCompl		:= ""
	Local cRemBair		:= ""
	Local cRemCEP		:= ""
	Local cRemCNPJ		:= ""
	Local cRemIE		:= ""
	Local cRemPais		:= ""
	Local cRemFone		:= ""
//-- Destinatario
	Local cDesMun		:= ""
	Local cDesUF		:= ""
	Local cDesNome		:= ""
	Local cDesEnd		:= ""
	Local cDesNro		:= ""
	Local cDesCompl		:= ""
	Local cDesBair		:= ""
	Local cDesCEP		:= ""
	Local cDesCNPJ		:= ""
	Local cDesIE		:= ""
	Local cDesPais		:= ""
	Local cDesFone		:= ""
//-- Expedidor
	Local cExpNome		:= ""
	Local cExpEnd		:= ""
	Local cExpNro		:= ""
	Local cExpMun		:= ""
	Local cExpBai		:= ""
	Local cExpUF		:= ""
	Local cExpDoc		:= ""	// CNPJ / CPF
	Local cExpPais		:= ""
//-- Recebedor
	Local cRecNome		:= ""
	Local cRecEnd		:= ""
	Local cRecBai		:= ""
	Local cRecMun		:= ""
	Local cRecUF		:= ""
	Local lRecPJ		:= .F.
	Local cRecCGC		:= ""
	Local cRecCPF		:= ""
	Local cRecINSCR		:= ""
//-- Tomador do Servico
	Local cDevMun		:= ""
	Local cDevUF		:= ""
	Local cDevNome		:= ""
	Local cDevEnd		:= ""
	Local cDevNro		:= ""
	Local cDevCompl		:= ""
	Local cDevBair		:= ""
	Local cDevCEP		:= ""
	Local cDevCNPJ		:= ""
	Local cDevIE		:= ""
	Local cDevPais		:= ""
	Local cDevFone		:= ""
//-- Produto Predominante
	Local cPPDesc		:= ""
	Local cPPCarga		:= ""
	Local cPPVlTot		:= ""
	Local cPPPesoB		:= ""
	Local cPPPeso3		:= ""
	Local cPPMetro3		:= ""
	Local cPPQtdVol		:= ""
//-- Dados Seguradora
	Local cSegNome		:= ""
	Local cSegResp		:= ""
	Local cSegDesc		:= ""
	Local cSegNrApoli	:= ""
	Local cSegNrAverb	:= ""
//-- Documentos Originarios
	Local aDocOri		:= {}
//Lotação
	Local lLotacao		:= .F.
	Local cPlaca		:= ""
	Local cUf			:= ""
	Local cRNTRC		:= ""
	Local cCodMoto		:= ""
	Local cCpfMoto		:= ""
	Local cNomeMoto		:= ""
	Local cLacre		:= ""
	Local nQtdDev		:= 0
	Local cDesDocAnt	:= ""
	Local cRNLotacao	:= ""
	Local cRNDtPrv		:= ""
	Local cRNMensagem	:= ""
	Local cCliente		:= ""
	Local cLoja			:= ""
	Local cAliasPeri	:= ""
	Local lPerig		:= .F.	//-- Informa se ha produtos perigosos
	Local cStartPath
	Local aMotoViag		:= {}
	Local cTipoDoc		:= ''
	Local cNumSol 		:= ''
	Local cFilCFS 		:= ''
	Local cDtEntr 		:= ''

//Chamada da função 
	Local lImportador   := IsIncallstack("COMXCOL")

//-- Variaveis Private
	Private cAliasCT	:= GetNextAlias()
	Private oDacte
	Private nLInic		:= 0	// Linha Inicial
	Private nLFim		:= 0	// Linha Inicial
	Private nDifEsq		:= 0	// Variavel com Diferenca para alinhar os Print da Esquerda com os da Direita
	Private cInsRemOpc	:= ''	// Remetente com sequencia de IE
	Private nFolhas		:= 0
	Private nFolhAtu	:= 1
	Private PixelX		:= nil
	Private PixelY		:= nil
	Private nMM			:= 0
	Private lComp		:= .F.	//CTE Complementar
	Private cFilVia		:= ""
	Private cViagem		:= ""
	Private cVersaoCTE	:= ""
	Private lUsaColab	:= UsaColaboracao("2")

//-- Verifica se o arquivo sera gerado em Remote Linux
	cStartPath := GetTempPath(.T.)

	AjustaSX1()

//-- MV_PAR01 - Informe lote inicial.
//-- MV_PAR02 - Informe lote final.
//-- MV_PAR03 - Informe documento inicial.
//-- MV_PAR04 - Informe documento final.
//-- MV_PAR05 - Informe serie do documento inicial.
//-- MV_PAR06 - Informe serie do documento final.
//-- MV_PAR07 - Informe tipo do documento.
//-- MV_PAR08 - Buscar XML do WebService.

	If !lImportador
		If !Pergunte(cPerg,.T.)
			Return()
		EndIf
	Else
		Pergunte(cPerg,.F.)
		MV_PAR01 := Space(TamSX3("DTP_LOTNFC")[1])
		MV_PAR02 := Replicate("Z",TamSX3("DTP_LOTNFC")[1]) 
		MV_PAR03 := SDS->DS_DOC
		MV_PAR04 := SDS->DS_DOC
		MV_PAR05 := SDS->DS_SERIE
		MV_PAR06 := SDS->DS_SERIE
	Endif

// Cria Arquivo de Trabalho - Documentos de Transporte
	cAliasCT := DataSource( 'SDS' ) 

	oDacte:=FWMSPrinter():New("DACTE",IMP_PDF,.F.,/*cStartPath*/ , /*.T.*/,,@oDacte,,,,,.T.)
	oDacte:SetResolution(72)
	oDacte:SetPortrait()
	oDacte:SetPaperSize(DMPAPER_A4)
	oDacte:SetMargin(60,60,60,60)
	oDacte:cPathPDF := cStartPath

	If oDacte:nModalResult <> 1
		oDacte:Cancel()
	EndIf

	If oDacte:Canceled()
		oDacte:DeActivate()
		Return(.T.)
	EndIf

	PixelX  := oDacte:nLogPixelX()
	PixelY  := oDacte:nLogPixelY()
	nMM     := 0

	While !(cAliasCT)->(Eof())

		oDacte:StartPage()
		cLacre := ""
		lLotacao := .F.

		cExpMun		:= ""
		cExpUF		:= ""
		cExpNome	:= ""
		cExpEnd		:= ""
		cExpNro		:= ""
		cExpCompl	:= ""
		cExpBai		:= ""
		cExpCEP		:= ""
		cExpCNPJ	:= ""
		cExpIE		:= ""
		cExpPais	:= ""
		cExpFone	:= ""
		cHorAut		:= ""
		cDatAut		:= ""
		lExped		:= .F.
		aXML        := Array(7)
		nX          := 1
		aXml        := {}
		cAviso      := ""
		cErro       := ""

		//-- Buscar XML do WebService
		aNotas := {}
		aadd(aNotas,{})
		aAdd(Atail(aNotas),.F.)

		aadd(Atail(aNotas),"E") //IIF(MV_PAR04==1,"E","S"))
		aAdd(Atail(aNotas),"")
		aAdd(Atail(aNotas),(cAliasCT)->DS_SERIE) //SERIE
		aAdd(Atail(aNotas),(cAliasCT)->DS_DOC) //Documento
		aadd(Atail(aNotas),"")
		aadd(Atail(aNotas),"")

		dbSelectArea("CKO")
		dbSetOrder(1)//CKO_ARQUIV
		If !dbSeek( Padr( Alltrim(SDS->DS_ARQUIVO) , TamSx3("CKO_ARQUIV")[1] ) )
			Aviso("Atenção","Não foi possivel localizar o arquivo na tabela CKO para gerar a impressão",{"Ok"})
			Return
		Endif

		cXml := CKO->CKO_XMLRET
		cXml := XmlClean(cXml)

		oNfe := XmlParser(encodeUTF8(cXml),"_",@cAviso,@cErro)

		if oNfe == nil
			oNfe := XmlParser(cXml,"_",@cAviso,@cErro)
		endif

		oNfe := XmlChildEx( oNfe , "_CTEPROC" )
		//oNfeDPEC := XmlParser(aXML[nX][4],"_",@cAviso,@cErro)

		If Type( 'oNFE' ) == 'U'
			(cAliasCT)->(DbSkip())
			Loop
		EndIf

		cHorAut  := iif(Type("oNfe:_ProtCTE:_INFPROT:_DHRECBTO:TEXT")<>"U",Substr(oNfe:_ProtCTE:_INFPROT:_DHRECBTO:TEXT,At("T",oNfe:_ProtCTE:_INFPROT:_DHRECBTO:TEXT)+1,8),"")//Data autorizacao
		cDatAut  := iif(Type("oNfe:_ProtCTE:_INFPROT:_DHRECBTO:TEXT")<>"U",StrTran(Substr(oNfe:_ProtCTE:_INFPROT:_DHRECBTO:TEXT,1,10),"-",""),"")	//-- Hora autorizacao
		cProcCTE := iif(Type("oNfe:_ProtCTE:_INFPROT:_nProt:Text")<>"U",oNfe:_ProtCTE:_INFPROT:_nProt:Text,"")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona a qtde de registros, p/ calcular a qtde de folhas            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cAliasInfNF := DataSource( 'SDT' )
		If (cAliasInfNF)->nTotal > 0
			If (cAliasInfNF)->nTotal <= 8
				nFolhas := 1
			Else
				nFolhas := (cAliasInfNF)->nTotal - 8	//-- Qtde da primeira paginas.
				nFolhas := Int(( nFolhas / 74 ) + 2)	//-- Qtde da outras paginas.
			EndIf
		EndIf
		(cAliasInfNF)->(DbCloseArea())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Controla o documento a ser enviado para montagem do cabecalho.         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nCont += 1

		aAdd(aCab, {;
			AllTrim((cAliasCT)->DS_DOC),;
			iif(Type("oNfe:_CTE:_INFCTE:_IDE:_SERIE:TEXT")<>"U",AllTrim(oNfe:_CTE:_INFCTE:_IDE:_SERIE:TEXT),""),;
			iif(Type("SUBSTR( oNfe:_CTE:_INFCTE:_IDE:_dhEmi:TEXT")<>"U",AllTrim(STRTRAN( SUBSTR( oNfe:_CTE:_INFCTE:_IDE:_dhEmi:TEXT, 1, AT('T', oNfe:_CTE:_INFCTE:_IDE:_dhEmi:TEXT) - 1) , '-', '')),""),;
			iif(Type("oNfe:_CTE:_INFCTE:_IDE:_dhEmi:TEXT")<>"U",AllTrim(STRTRAN( SUBSTR( oNfe:_CTE:_INFCTE:_IDE:_dhEmi:TEXT, AT('T', oNfe:_CTE:_INFCTE:_IDE:_dhEmi:TEXT) + 1, 5) , ':', '')),"U"),;
			iif(Type("oNFE:_CTE:_INFCTE:_ID:TEXT")<>"U",AllTrim(STRTRAN(UPPER(oNFE:_CTE:_INFCTE:_ID:TEXT),'CTE','')),""),;
			cProcCTE,"" ,cDatAut, cHorAut})	//-- Nao possui ref. no XML

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Funcao responsavel por montar o cabecalho do relatorio                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nFolhAtu := 1
		lSeqDes  :=.F.
		lSeqRec  :=.F.
		TMSR27Cab(aCab[nCont],.T.)

		//-- Estrutura da funcao que retorna o logradouro, numero e complemento.
		//-- Logradouro		FisGetEnd(XXXXXXXX)[1]
		//-- Numero			FisGetEnd(XXXXXXXX)[2]
		//-- Complemento	FisGetEnd(XXXXXXXX)[4]

		//-- CFOP
		cCFOP		:= iif(Type("oNfe:_CTE:_INFCTE:_IDE:_CFOP:TEXT")<>"U",AllTrim(oNfe:_CTE:_INFCTE:_IDE:_CFOP:TEXT),"")
		cDescCfop	:= iif(Type("oNfe:_CTE:_INFCTE:_IDE:_NATOP:TEXT")<>"U",AllTrim(oNfe:_CTE:_INFCTE:_IDE:_NATOP:TEXT),"")

		//-- Origem da Prestacao
		cOriMunPre	:= Iif(Type("oNfe:_CTE:_INFCTE:_IDE:_XMUNINI:TEXT")<>"U",oNfe:_CTE:_INFCTE:_IDE:_XMUNINI:TEXT,"")
		cOriUFPre	:= iif(Type("oNfe:_CTE:_INFCTE:_IDE:_UFINI:TEXT")<>"U",oNfe:_CTE:_INFCTE:_IDE:_UFINI:TEXT,"")

		//-- Destino da Prestacao
		cDesMunPre	:= iif(Type("oNfe:_CTE:_INFCTE:_IDE:_XMUNFIM:TEXT")<>"U",oNfe:_CTE:_INFCTE:_IDE:_XMUNFIM:TEXT,"")
		cDesUFPre	:= iif(Type("oNfe:_CTE:_INFCTE:_IDE:_UFFIM:TEXT")<>"U",oNfe:_CTE:_INFCTE:_IDE:_UFFIM:TEXT,"")

		//-- Remetente
		cRemMun   := iif(Type("oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_XMUN:TEXT")!="U",oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_XMUN:TEXT,"")
		cRemUF    := iif(Type("oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_UF:TEXT")!="U",oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_UF:TEXT,"")
		cRemNome  := iif(Type("oNfe:_CTE:_INFCTE:_REM:_XNOME:TEXT")!="U",oNfe:_CTE:_INFCTE:_REM:_XNOME:TEXT,"")
		cRemEnd   := iif(Type("oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_XLGR:TEXT")!="U",oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_XLGR:TEXT,"")
		cRemNro   := iif(Type("oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_NRO:TEXT")!="U",oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_NRO:TEXT,"")
		cRemCompl := Iif(Type("oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_XCPL:TEXT")!="U",oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_XCPL:TEXT,"")
		cRemBair  := Iif(Type("oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_XBAIRRO:TEXT")!="U",oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_XBAIRRO:TEXT,"")
		cRemCEP   := Iif(Type("oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_CEP:TEXT")!="U",oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_CEP:TEXT,"")

		cRemCNPJ  := Iif(Type("oNfe:_CTE:_INFCTE:_REM:_CNPJ:TEXT")!="U",oNfe:_CTE:_INFCTE:_REM:_CNPJ:TEXT,oNfe:_CTE:_INFCTE:_REM:_CPF:TEXT)
		cRemIE    := Iif(Type("oNfe:_CTE:_INFCTE:_REM:_IE:TEXT"  )!="U",oNfe:_CTE:_INFCTE:_REM:_IE:TEXT,"")
		cRemPais  := Iif(Type("oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_XPAIS:TEXT")!="U",oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_XPAIS:TEXT,"")
		cRemFone  := Iif(Type("oNfe:_CTE:_INFCTE:_REM:_FONE:TEXT")!="U",oNfe:_CTE:_INFCTE:_REM:_FONE:TEXT,"")

		//-- Local de Coleta
		If (Type("oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA")) <> "U"
			cExpMun	    := Iif(Type("oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_XMUN:TEXT")!="U",oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_XMUN:TEXT,"")
			cExpUF		:= Iif(Type("oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_UF:TEXT")!="U",oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_UF:TEXT,"")
			cExpNome	:= Iif(Type("oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_XNOME:TEXT")!="U",oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_XNOME:TEXT,"")
			cExpEnd	    := Iif(Type("oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_XLGR:TEXT")!="U",oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_XLGR:TEXT,"")
			cExpNro	    := Iif(Type("oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_NRO:TEXT")!="U",oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_NRO:TEXT,"")
			cExpCompl 	:= ""
			cExpBai	    := Iif(Type("oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_XBAIRRO:TEXT")!="U",oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_XBAIRRO:TEXT,"")
			cExpCEP   	:= ""
			cExpCNPJ  	:= Iif(Type("oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_CNPJ:TEXT")!="U",oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_CNPJ:TEXT,oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_CPF:TEXT)
			cExpIE    	:= ""
			cExpPais  	:= ""
			cExpFone  	:= ""
		EndIf

		//-- Expedidor
		If (Type("oNfe:_CTE:_INFCTE:_EXPED")) <> "U"
			lExped		:= .T.
			cExpMun	    := Iif(Type("oNfe:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_XMUN:TEXT")!="U",oNfe:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_XMUN:TEXT,"")
			cExpUF		:= Iif(Type("oNfe:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_UF:TEXT")!="U",oNfe:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_UF:TEXT,"")
			cExpNome	:= Iif(Type("oNfe:_CTE:_INFCTE:_EXPED:_XNOME:TEXT")!="U",oNfe:_CTE:_INFCTE:_EXPED:_XNOME:TEXT,"")
			cExpEnd	    := Iif(Type("oNfe:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_XLGR:TEXT")!="U",oNfe:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_XLGR:TEXT,"")
			cExpNro	    := Iif(Type("oNfe:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_NRO:TEXT")!="U",oNfe:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_NRO:TEXT,"")
			cExpCompl 	:= ""
			cExpBai	    := Iif(Type("oNfe:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_XBAIRRO:TEXT")!="U",oNfe:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_XBAIRRO:TEXT,"")
			cExpCEP     := Iif(Type("oNfe:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_CEP:TEXT")!="U",oNfe:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_CEP:TEXT,"")
			cExpCNPJ    := Iif(Type("oNfe:_CTE:_INFCTE:_EXPED:_CNPJ:TEXT")!="U",oNfe:_CTE:_INFCTE:_EXPED:_CNPJ:TEXT,oNfe:_CTE:_INFCTE:_EXPED:_CPF:TEXT)
			cExpIE      := Iif(Type("oNfe:_CTE:_INFCTE:_EXPED:_IE:TEXT"  )!="U",oNfe:_CTE:_INFCTE:_EXPED:_IE:TEXT,"")
			cExpPais    := Iif(Type("oNfe:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_XPAIS:TEXT")!="U",oNfe:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_XPAIS:TEXT,"")
			cExpFone    := Iif(Type("oNfe:_CTE:_INFCTE:_EXPED:_FONE:TEXT")!="U",oNfe:_CTE:_INFCTE:_EXPED:_FONE:TEXT,"")
		EndIf

		//-- Destinatario
		cDesMun   := Iif(Type("oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_XMUN:TEXT")!="U",oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_XMUN:TEXT,"")
		cDesUF    := Iif(Type("oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_UF:TEXT")!="U",oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_UF:TEXT,"")
		cDesNome  := Iif(Type("oNfe:_CTE:_INFCTE:_DEST:_XNOME:TEXT")!="U",oNfe:_CTE:_INFCTE:_DEST:_XNOME:TEXT,"")
		cDesEnd   := Iif(Type("oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_XLGR:TEXT")!="U",oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_XLGR:TEXT,"")
		cDesNro   := Iif(Type("oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_NRO:TEXT")!="U",oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_NRO:TEXT,"")
		cDesCompl := Iif(Type("oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_XCPL:TEXT")!="U",oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_XCPL:TEXT,"")
		cDesBair  := Iif(Type("oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_XBAIRRO:TEXT")!="U",oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_XBAIRRO:TEXT,"")
		cDesCEP   := Iif(Type("oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_CEP:TEXT")!="U",oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_CEP:TEXT,"")

		if Type("oNfe:_CTE:_INFCTE:_DEST:_CNPJ:TEXT")!="U"
			cDesCNPJ  := oNfe:_CTE:_INFCTE:_DEST:_CNPJ:TEXT
		Elseif Type("oNfe:_CTE:_INFCTE:_DEST:_CPF:TEXT")!="U"
			cDesCNPJ  := oNfe:_CTE:_INFCTE:_DEST:_CPF:TEXT
		Endif

		cDesIE    := Iif(Type("oNfe:_CTE:_INFCTE:_DEST:_IE:TEXT")!="U",oNfe:_CTE:_INFCTE:_DEST:_IE:TEXT,"")
		cDesPais  := Iif(Type("oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_XPAIS:TEXT")!="U",oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_XPAIS:TEXT,"")
		cDesFone  := Iif(Type("oNfe:_CTE:_INFCTE:_DEST:_FONE:TEXT")!="U",oNfe:_CTE:_INFCTE:_DEST:_FONE:TEXT,"")

		//-- Local de Entrega


		If (Type("oNfe:_CTE:_INFCTE:_DEST:_LOCENT")) <> "U"
			lSeqDes := .T.
			//Destino Prestacao
			cRecNome	:= Iif(Type("oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_XNOME:TEXT")!="U",oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_XNOME:TEXT,"")
			cRecEnd		:= Iif(Type("oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_XLGR:TEXT")!="U" ,oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_XLGR:TEXT ,"")
			cRecEnd		+= Iif(Type("oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_NRO:TEXT")!="U",", "+oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_NRO:TEXT,"")

			cRecBai		:= Iif(Type("oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_XBAIRRO:TEXT")!="U",oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_XBAIRRO:TEXT,"")
			cRecMun		:= Iif(Type("oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_XMUN:TEXT")!="U",oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_XMUN:TEXT,"")
			crecUF		:= Iif(Type("oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_UF:TEXT")!="U",oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_UF:TEXT,"")
			If Type("oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_CNPJ:TEXT")=="U"
				cRecCPF	:= iif(Type("oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_CPF:TEXT")!="U",oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_CPF:TEXT,"")
			Else
				cRecCGC	:= iif(Type("oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_CNPJ:TEXT")!="U",oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_CNPJ:TEXT,"")
				If Type("oNfe:_CTE:_INFCTE:_DEST:_IE:TEXT")<>"U"
					cRecINSCR := IIF(Type("oNfe:_CTE:_INFCTE:_DEST:_IE:TEXT")!="U",oNfe:_CTE:_INFCTE:_DEST:_IE:TEXT,"")
				Endif
				lRecPJ	:= .T.
			EndIf
		ElseIf (Type("oNfe:_CTE:_INFCTE:_RECEB:_ENDERRECEB")) <> "U"
			lSeqRec := .T.
			//Destino Recebedor
			cRecNome	:= iif(Type("oNfe:_CTE:_INFCTE:_RECEB:_XNOME:TEXT")!="U",oNfe:_CTE:_INFCTE:_RECEB:_XNOME:TEXT,"")
			cRecEnd		:= iif(Type("oNfe:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_XLGR:TEXT")!="U",oNfe:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_XLGR:TEXT,"")
			cRecEnd		+= iif(Type("oNfe:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_NRO:TEXT")!="U",", "+oNfe:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_NRO:TEXT,"")
			cRecBai		:= iif(Type("oNfe:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_XBAIRRO:TEXT")!="U",oNfe:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_XBAIRRO:TEXT,"")
			cRecMun		:= iif(Type("oNfe:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_XMUN:TEXT")!="U",oNfe:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_XMUN:TEXT,"")
			crecUF		:= iif(Type("oNfe:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_UF:TEXT")!="U",oNfe:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_UF:TEXT,"")
			If Type("oNfe:_CTE:_INFCTE:_RECEB:_CNPJ:TEXT")=="U"
				If Type("oNfe:_CTE:_INFCTE:_RECEB:_CPF:TEXT")<>"U"
					cRecCPF	:= iif(Type("oNfe:_CTE:_INFCTE:_RECEB:_CPF:TEXT")!="U",oNfe:_CTE:_INFCTE:_RECEB:_CPF:TEXT,"")
				Else
					cRecCPF	:=""
				Endif
			Else
				If Type("oNfe:_CTE:_INFCTE:_RECEB:_CNPJ:TEXT")<>"U"
					cRecCGC	:= oNfe:_CTE:_INFCTE:_RECEB:_CNPJ:TEXT
				Endif
				If Type("oNfe:_CTE:_INFCTE:_RECEB:_IE:TEXT")<>"U"
					cRecINSCR := oNfe:_CTE:_INFCTE:_RECEB:_IE:TEXT
				Endif
				lRecPJ	:= .T.
			EndIf
		EndIf

		//-- Produto Predominante
		If (Type("oNFE:_CTE:_INFCTE:_INFCTENORM")) <> "U"
			cPPDesc			:= iif(Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_PROPRED:TEXT")!="U",oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_PROPRED:TEXT,"")
			If (Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_XOUTCAT:TEXT")) <> "U"
				cPPCarga		:= oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_XOUTCAT:TEXT
			Endif
			If Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_VMERC") <> "U"
				cPPVlTot	:= oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_VMERC:TEXT
			Else
				cPPVlTot	:= Iif(Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_VCARGA:TEXT")!="U",oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_VCARGA:TEXT,"")
			EndIf
			If Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ")!="U"
				If ValType( oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ ) == 'A'
					For nCount := 1 To Len( oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ )
						Do Case
						Case oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ nCount ]:_TPMED:TEXT == "PESO DECLARADO"
							cPPPesoB := oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ nCount ]:_QCARGA:TEXT
						Case oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ nCount ]:_TPMED:TEXT == "PESO REAL"
							cPPPesoB := oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ nCount ]:_QCARGA:TEXT
						Case oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ nCount ]:_TPMED:TEXT == "PESO CUBADO"
							cPPPeso3 := oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ nCount ]:_QCARGA:TEXT
						Case oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ nCount ]:_TPMED:TEXT == "PESO BASE DE CALCULO"
							cPPPeso3 := oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ nCount ]:_QCARGA:TEXT
						Case oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ nCount ]:_TPMED:TEXT == "LITRAGEM"
							cPPQtdVol := oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ nCount ]:_QCARGA:TEXT
						Case oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ nCount ]:_TPMED:TEXT == "VOLUME"
							cPPQtdVol := oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ nCount ]:_QCARGA:TEXT
						Case oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ nCount ]:_TPMED:TEXT == "UNIDADE"
							cPPQtdVol := oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ nCount ]:_QCARGA:TEXT
						Case oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ nCount ]:_TPMED:TEXT == "M3"
							cPPMetro3 := oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ nCount ]:_QCARGA:TEXT
						Case oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ nCount ]:_TPMED:TEXT == "METROS CUBICOS"
							cPPMetro3 := oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ nCount ]:_QCARGA:TEXT
						EndCase
					Next nCount
				EndIf
			Endif
		EndIf

		//-- Dados Seguradora
		If (Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_SEG")) <> "U"
			cSegDesc	:= ""
			cSegNome	:= iif(Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_SEG:_XSEG:TEXT"),oNFE:_CTE:_INFCTE:_INFCTENORM:_SEG:_XSEG:TEXT,"")
			cSegResp	:= iif(Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_SEG:_RESPSEG:TEXT"),oNFE:_CTE:_INFCTE:_INFCTENORM:_SEG:_RESPSEG:TEXT,"")
			cSegNrApoli	:= iif(Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_SEG:_NAPOL:TEXT"),oNFE:_CTE:_INFCTE:_INFCTENORM:_SEG:_NAPOL:TEXT,"")
			If (Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_SEG:_NAVER")) <> "U"
				cSegNrAverb	:= iif(Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_SEG:_NAVER:TEXT")!="U",oNFE:_CTE:_INFCTE:_INFCTENORM:_SEG:_NAVER:TEXT,"") // Campo nao obrigatorio.
			EndIf
			//-- Responsavel pelo Seguro
			If	cSegResp == "0"
				cSegDesc := "Remetente"
			ElseIf	cSegResp == "1"
				cSegDesc := "Expedidor"
			ElseIf	cSegResp == "2"
				cSegDesc := "Recebedor"
			ElseIf	cSegResp == "3"
				cSegDesc := "Destinatario"
			ElseIf	cSegResp == "4"
				cSegDesc := "Emitente do CT-e"
			ElseIf 	cSegResp == "5"
				cSegDesc := "Tomador de Servico"
			EndIf
		EndIf

		//-- Tomador
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tomador do Servico         ³
		//³ 0 - Remetente;             ³
		//³ 1 - Expedidor;             ³
		//³ 2 - Recebedor;             ³
		//³ 3 - Destinatario.          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Type("oNfe:_CTE:_INFCTE:_IDE:_TOMA03:_TOMA:TEXT") <> "U"
			If oNfe:_CTE:_INFCTE:_IDE:_TOMA03:_TOMA:TEXT == "0"
				cDevMun   := cRemMun
				cDevUF    := cRemUF
				cDevNome  := cRemNome
				cDevEnd   := cRemEnd
				cDevNro   := cRemNro
				cDevCompl := cRemCompl
				cDevBair  := cRemBair
				cDevCEP   := cRemCEP
				cDevCNPJ  := cRemCNPJ
				cDevIE    := cRemIE
				cDevPais  := cRemPais
				cDevFone  := cRemFone
			Else
				cDevMun   := cDesMun
				cDevUF    := cDesUF
				cDevNome  := cDesNome
				cDevEnd   := cDesEnd
				cDevNro   := cDesNro
				cDevCompl := cDesCompl
				cDevBair  := cDesBair
				cDevCEP   := cDesCEP
				cDevCNPJ  := cDesCNPJ
				cDevIE    := cDesIE
				cDevPais  := cDesPais
				cDevFone  := cDesFone
			EndIf
		ElseIf Type("oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_TOMA:TEXT") <> "U"
			If oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_TOMA:TEXT == "4"
				// Subcontratacao DT6_DEVFRE == "4" - Despachante
				cDevMun   := iif(Type("oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_XMUN:TEXT")!="U",oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_XMUN:TEXT,"")
				cDevUF    := iif(Type("oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_UF:TEXT")!="U",oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_UF:TEXT,"")
				cDevNome  := iif(Type("oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_XNOME:TEXT")!="U",oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_XNOME:TEXT,"")
				cDevEnd   := iif(Type("oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_XLGR:TEXT")!="U",oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_XLGR:TEXT,"")
				cDevNro   := iif(Type("oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_NRO:TEXT")!="U",oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_NRO:TEXT,"")
				cDevCompl := ""
				cDevBair  := iif(Type("oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_XBAIRRO:TEXT")!="U",oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_XBAIRRO:TEXT,"")
				cDevCEP   := iif(Type("oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_CEP:TEXT")!="U",oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_CEP:TEXT,"")
				cDevCNPJ  := Iif(Type("oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_CNPJ:TEXT")!="U",oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_CNPJ:TEXT,oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_CPF:TEXT)
				cDevIE    := Iif(Type("oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_IE:TEXT"  )!="U",oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_IE:TEXT,"")
				cDevPais  := ""
				cDevFone  := Iif(Type("oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_FONE:TEXT")!="U",oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_FONE:TEXT,"")
			EndIf
		EndIf
		//-- Documentos Originarios
		aDocOri := {}
		If	( Type( "oNFE:_CTE:_INFCTE:_REM:_INFNFE" ) <> 'U' )
			If ValType( oNFE:_CTE:_INFCTE:_REM:_INFNFE ) == 'A'
				For nCount := 1 To Len( oNFE:_CTE:_INFCTE:_REM:_INFNFE )
					If aScan(aDocOri,{|x|x[8]==oNFE:_CTE:_INFCTE:_REM:_INFNFE[ nCount ]:_CHAVE:TEXT})==0
						AADD(aDocOri, {;
							'',;
							'',;
							'',;
							'',;
							'',;
							'',;
							'',;
							oNFE:_CTE:_INFCTE:_REM:_INFNFE[ nCount ]:_CHAVE:TEXT })
					EndIf
				Next nCount
			ElseIf ValType( oNFE:_CTE:_INFCTE:_REM:_INFNFE ) == 'O'
				If aScan(aDocOri,{|x|x[8]==oNFE:_CTE:_INFCTE:_REM:_INFNFE:_CHAVE:TEXT})==0
					AADD(aDocOri, {;
						'',;
						'',;
						'',;
						'',;
						'',;
						'',;
						'',;
						oNFE:_CTE:_INFCTE:_REM:_INFNFE:_CHAVE:TEXT })
				EndIf
			EndIf
		ElseIf	( Type( "oNFE:_CTE:_INFCTE:_REM:_INFNF" ) <> 'U' )
			If ValType( oNFE:_CTE:_INFCTE:_REM:_INFNF ) == 'A'
				For nCount := 1 To Len( oNFE:_CTE:_INFCTE:_REM:_INFNF )
					If aScan(aDocOri,{|x|x[1]+x[2]==oNFE:_CTE:_INFCTE:_REM:_INFNF[ nCount ]:_SERIE:TEXT+oNFE:_CTE:_INFCTE:_REM:_INFNF[ nCount ]:_NDOC:TEXT})==0
						AADD(aDocOri, {;
							iif(Type("oNFE:_CTE:_INFCTE:_REM:_INFNF["+Alltrim(Str(nCount))+"]:_SERIE:TEXT")!="U",oNFE:_CTE:_INFCTE:_REM:_INFNF[ nCount ]:_SERIE:TEXT,""),;
							iif(Type("oNFE:_CTE:_INFCTE:_REM:_INFNF["+Alltrim(Str(nCount))+"]:_NDOC:TEXT")!="U",oNFE:_CTE:_INFCTE:_REM:_INFNF[ nCount ]:_NDOC:TEXT,""),;
							iif(Type("oNFE:_CTE:_INFCTE:_REM:_INFNF["+Alltrim(Str(nCount))+"]:_DEMI:TEXT")!="U" ,STRTRAN(oNFE:_CTE:_INFCTE:_REM:_INFNF[ nCount ]:_DEMI:TEXT,'-'),""),;
							iif(Type("oNFE:_CTE:_INFCTE:_REM:_INFNF["+Alltrim(Str(nCount))+"]:_VPROD:TEXT")!="U",oNFE:_CTE:_INFCTE:_REM:_INFNF[ nCount ]:_VPROD:TEXT,""),;
							'',;
							'',;
							'',;
							'' })
					EndIf
				Next nCount
				//-- Local de Retirada
				If (Type("oNfe:_CTE:_INFCTE:_REM:_INFNF[1]:_LOCRET")) <> "U"
					cExpMun	    :=  Iif(Type("oNfe:_CTE:_INFCTE:_REM:_INFNF[1]:_LOCRET:_XMUN:TEXT")!="U",oNfe:_CTE:_INFCTE:_REM:_INFNF[1]:_LOCRET:_XMUN:TEXT,"")
					cExpUF		:=  Iif(Type("oNfe:_CTE:_INFCTE:_REM:_INFNF[1]:_LOCRET:_UF:TEXT")!="U",oNfe:_CTE:_INFCTE:_REM:_INFNF[1]:_LOCRET:_UF:TEXT,"")
					cExpNome	:=  Iif(Type("oNfe:_CTE:_INFCTE:_REM:_INFNF[1]:_LOCRET:_XNOME:TEXT")!="U",oNfe:_CTE:_INFCTE:_REM:_INFNF[1]:_LOCRET:_XNOME:TEXT,"")
					cExpEnd	    :=  Iif(Type("oNfe:_CTE:_INFCTE:_REM:_INFNF[1]:_LOCRET:_XLGR:TEXT")!="U",oNfe:_CTE:_INFCTE:_REM:_INFNF[1]:_LOCRET:_XLGR:TEXT,"")
					cExpNro	    :=  Iif(Type("oNfe:_CTE:_INFCTE:_REM:_INFNF[1]:_LOCRET:_NRO:TEXT")!="U",oNfe:_CTE:_INFCTE:_REM:_INFNF[1]:_LOCRET:_NRO:TEXT,"")
					cExpCompl 	:= ""
					cExpBai	    := Iif(Type("oNfe:_CTE:_INFCTE:_REM:_INFNF[1]:_LOCRET:_XBAIRRO:TEXT")!="U",oNfe:_CTE:_INFCTE:_REM:_INFNF[1]:_LOCRET:_XBAIRRO:TEXT,"")
					cExpCEP   	:= ""
					cExpCNPJ  	:= Iif(Type("oNfe:_CTE:_INFCTE:_REM:_INFNF[1]:_LOCRET:_CNPJ:TEXT")!="U", oNfe:_CTE:_INFCTE:_REM:_INFNF[1]:_LOCRET:_CNPJ:TEXT ,oNfe:_CTE:_INFCTE:_REM:_INFNF[1]:_LOCRET:_CPF:TEXT )
					cExpIE    	:= ""
					cExpPais  	:= cRemPais
					cExpFone  	:= ""
				EndIf
			Else
				If Type("oNFE:_CTE:_INFCTE:_REM:_INFNF:_SERIE:TEXT+oNFE:_CTE:_INFCTE:_REM:_INFNF:_NDOC:TEXT")!="U"
					If aScan(aDocOri,{|x|x[1]+x[2]==oNFE:_CTE:_INFCTE:_REM:_INFNF:_SERIE:TEXT+oNFE:_CTE:_INFCTE:_REM:_INFNF:_NDOC:TEXT})==0
						AADD(aDocOri, {;
							iif(Type("oNFE:_CTE:_INFCTE:_REM:_INFNF:_SERIE:TEXT")!="U",oNFE:_CTE:_INFCTE:_REM:_INFNF:_SERIE:TEXT,""),;
							iif(Type("oNFE:_CTE:_INFCTE:_REM:_INFNF:_NDOC:TEXT")!="U",oNFE:_CTE:_INFCTE:_REM:_INFNF:_NDOC:TEXT ,""),;
							iif(Type("oNFE:_CTE:_INFCTE:_REM:_INFNF:_DEMI:TEXT")!="U",STRTRAN(oNFE:_CTE:_INFCTE:_REM:_INFNF:_DEMI:TEXT,'-'),""),;
							iif(Type("oNFE:_CTE:_INFCTE:_REM:_INFNF:_VPROD:TEXT")!="U",oNFE:_CTE:_INFCTE:_REM:_INFNF:_VPROD:TEXT,""),;
							'',;
							'',;
							'',;
							'' })
					EndIf
				Endif
				If (Type("oNfe:_CTE:_INFCTE:_REM:_INFNF:_LOCRET")) <> "U"
					cExpMun	    := iif(Type("oNfe:_CTE:_INFCTE:_REM:_INFNF:_LOCRET:_XMUN:TEXT")!="U",oNfe:_CTE:_INFCTE:_REM:_INFNF:_LOCRET:_XMUN:TEXT,"")
					cExpUF		:= iif(Type("oNfe:_CTE:_INFCTE:_REM:_INFNF:_LOCRET:_UF:TEXT")!="U",oNfe:_CTE:_INFCTE:_REM:_INFNF:_LOCRET:_UF:TEXT,"")
					cExpNome	:= iif(Type("oNfe:_CTE:_INFCTE:_REM:_INFNF:_LOCRET:_XNOME:TEXT")!="U",oNfe:_CTE:_INFCTE:_REM:_INFNF:_LOCRET:_XNOME:TEXT,"")
					cExpEnd	    := iif(Type("oNfe:_CTE:_INFCTE:_REM:_INFNF:_LOCRET:_XLGR:TEXT")!="U",oNfe:_CTE:_INFCTE:_REM:_INFNF:_LOCRET:_XLGR:TEXT,"")
					cExpNro	    := iif(Type("oNfe:_CTE:_INFCTE:_REM:_INFNF:_LOCRET:_NRO:TEXT")!="U",oNfe:_CTE:_INFCTE:_REM:_INFNF:_LOCRET:_NRO:TEXT,"")
					cExpCompl 	:= ""
					cExpBai	    := iif(Type("oNfe:_CTE:_INFCTE:_REM:_INFNF:_LOCRET:_XBAIRRO:TEXT")!="U",oNfe:_CTE:_INFCTE:_REM:_INFNF:_LOCRET:_XBAIRRO:TEXT,"")
					cExpCEP   	:= ""
					cExpCNPJ  	:= Iif(Type("oNfe:_CTE:_INFCTE:_REM:_INFNF:_LOCRET:_CNPJ:TEXT")!="U",oNfe:_CTE:_INFCTE:_REM:_INFNF:_LOCRET:_CNPJ:TEXT , oNfe:_CTE:_INFCTE:_REM:_INFNF:_LOCRET:_CPF:TEXT)
					cExpIE    	:= ""
					cExpPais  	:= cRemPais
					cExpFone  	:= ""
				EndIf
			EndIf
			//Aqui Inicio
		ElseIf  (Type( "oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF")) <> 'U'
			If ValType( oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF ) == 'A'
				For nCount := 1 To Len( oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF )
					If aScan(aDocOri,{|x|x[1]+x[2]==oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF[ nCount ]:_SERIE:TEXT+oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF[ nCount ]:_NDOC:TEXT})==0
						AADD(aDocOri, {;
							oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF[ nCount ]:_SERIE:TEXT,;
							oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF[ nCount ]:_NDOC:TEXT,;
							STRTRAN(oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF[ nCount ]:_DEMI:TEXT,'-'),;
							oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF[ nCount ]:_VPROD:TEXT,;
							'',;
							'',;
							'',;
							'' })
					EndIf
				Next nCount
			Else

				If Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF:_SERIE:TEXT")!="U" .And. Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF:_NDOC:TEXT")!="U"
					If aScan(aDocOri,{|x|x[1]+x[2]==oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF:_SERIE:TEXT+oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF:_NDOC:TEXT})==0
						AADD(aDocOri, {;
							iif(Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF:_SERIE:TEXT")!="U",oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF:_SERIE:TEXT,"") ,;
							iif(Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF:_NDOC:TEXT")!="U",oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF:_NDOC:TEXT ,"") ,;
							iif(Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF:_DEMI:TEXT")!="U",STRTRAN(oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF:_DEMI:TEXT,'-'),""),;
							iif(Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF:_VPROD:TEXT")!="U",oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF:_VPROD:TEXT,""),;
							'',;
							'',;
							'',;
							'' })
					EndIf
				Endif
			EndIf

			// Fim
		ElseIf	( Type( "oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE" ) <> 'U' )
			If ValType( oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE ) == 'A'
				For nCount := 1 To Len( oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE )
					If aScan(aDocOri,{|x|x[8]==oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE[ nCount ]:_CHAVE:TEXT})==0
						AADD(aDocOri, {;
							'',;
							'',;
							'',;
							'',;
							'',;
							'',;
							'',;
							oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE[ nCount ]:_CHAVE:TEXT })
					EndIf
				Next nCount
			ElseIf ValType( oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE ) == 'O'
				If Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT")!="U"
					If aScan(aDocOri,{|x|x[8]==oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT})==0
						AADD(aDocOri, {;
							'',;
							'',;
							'',;
							'',;
							'',;
							'',;
							'',;
							iif(Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT")!="U",oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT,"") })
					EndIf
				Endif
			EndIf
		ElseIf	( Type( "oNFE:_CTE:_INFCTE:_REM:_INFOUTROS" ) <> 'U' )
			If ValType( oNFE:_CTE:_INFCTE:_REM:_INFOUTROS ) == 'A'
				For nCount := 1 To Len( oNFE:_CTE:_INFCTE:_REM:_INFOUTROS )
					If aScan(aDocOri,{|x|x[1]+x[2]==oNFE:_CTE:_INFCTE:_REM:_INFOUTROS[ nCount ]:_NDOC:TEXT})==0
						AADD(aDocOri, {;
							'',; //SERIE DO DOCUMENTO NAO INFORMADA NO XML QUANDO O DOCUMENTO NAO EH FISCAL
						oNFE:_CTE:_INFCTE:_REM:_INFOUTROS[ nCount ]:_NDOC:TEXT,;
							STRTRAN(oNFE:_CTE:_INFCTE:_REM:_INFOUTROS[ nCount ]:_DEMI:TEXT,'-'),;
							'',; //--VALOR DO PRODUTO NAO INFORMADO NO XML QUANDO O DOCUMENTO NAO EH FISCAL
						'',;
							'',;
							'',;
							'' })
					EndIf
				Next nCount
			Else
				If Type("oNFE:_CTE:_INFCTE:_REM:_INFOUTROS:_SERIE:TEXT")!="U" .And. Type("oNFE:_CTE:_INFCTE:_REM:_INFOUTROS:_NDOC:TEXT")!="U"
					If aScan(aDocOri,{|x|x[1]+x[2]==oNFE:_CTE:_INFCTE:_REM:_INFOUTROS:_SERIE:TEXT+oNFE:_CTE:_INFCTE:_REM:_INFOUTROS:_NDOC:TEXT})==0
						AADD(aDocOri, {;
							'',;//SERIE DO DOCUMENTO NAO INFORMADA NO XML QUANDO O DOCUMENTO NAO EH FISCAL
						iif(Type("oNFE:_CTE:_INFCTE:_REM:_INFOUTROS:_NDOC:TEXT")!="U",oNFE:_CTE:_INFCTE:_REM:_INFOUTROS:_NDOC:TEXT,""),;
							iif(Type("oNFE:_CTE:_INFCTE:_REM:_INFOUTROS:_DEMI:TEXT")!="U",STRTRAN(oNFE:_CTE:_INFCTE:_REM:_INFOUTROS:_DEMI:TEXT,'-'),""),;
							'',; //--VALOR DO PRODUTO NAO INFORMADO NO XML QUANDO O DOCUMENTO NAO EH FISCAL
						'',;
							'',;
							'',;
							'' })
					EndIf
				Endif
			EndIf
		ElseIf	( Type( "oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS" ) <> 'U' )
			If ValType( oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS ) == 'A'
				For nCount := 1 To Len( oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS )
					If Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS["+Alltrim(Str(nCount))+"]:_NDOC:TEXT")<>"U"
						If aScan(aDocOri,{|x|x[1]+x[2]==oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS[ nCount ]:_NDOC:TEXT})==0
							AADD(aDocOri, {;
								'',; //SERIE DO DOCUMENTO NAO INFORMADA NO XML QUANDO O DOCUMENTO NAO EH FISCAL
							iif(Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS["+Alltrim(Str(nCount))+"]:_NDOC:TEXT")<>"U",oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS[ nCount ]:_NDOC:TEXT,"") ,;
								iif(Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS["+Alltrim(Str(nCount))+"]:_DEMI:TEXT")<>"U",oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS[ nCount ]:_DEMI:TEXT,"") ,;
								'',; //--VALOR DO PRODUTO NAO INFORMADO NO XML QUANDO O DOCUMENTO NAO EH FISCAL
							'',;
								'',;
								'',;
								'' })
						EndIf
					Endif
				Next nCount
			Else
				If Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS:_SERIE:TEXT")<>"U" .And. Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS:_NDOC:TEXT")<>"U"
					If aScan(aDocOri,{|x|x[1]+x[2]==oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS:_SERIE:TEXT+oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS:_NDOC:TEXT})==0
						AADD(aDocOri, {;
							'',;//SERIE DO DOCUMENTO NAO INFORMADA NO XML QUANDO O DOCUMENTO NAO EH FISCAL
						iif(Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS:_NDOC:TEXT")<>"U",oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS:_NDOC:TEXT,""),;
							iif(Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS:_DEMI:TEXT")<>"U",STRTRAN(oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS:_DEMI:TEXT,'-'),""),;
							'',; //--VALOR DO PRODUTO NAO INFORMADO NO XML QUANDO O DOCUMENTO NAO EH FISCAL
						'',;
							'',;
							'',;
							'' })
					EndIf
				Endif
			EndIf
		EndIf
		//-- RNTRC
		If (Type("oNFE:_CTE:_INFCTE:_INFCTENORM")) <> "U"
			If (Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO")) <> "U"
				If (Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LOTA:TEXT")) <> "U"
					cRNLotacao	:= If( oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LOTA:TEXT == '0', "Carga Fracionada", "Lotação")
				Endif
				If  (Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_DPREV:TEXT")) <> "U"
					cRNDtPrv	:= oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_DPREV:TEXT
					cRNDtPrv	:= SubStr(cRNDtPrv,9,2) + '/' + SubStr(cRNDtPrv,6,2) + '/' + SubStr(cRNDtPrv,1,4)
				Endif
				cRNMensagem	:= "Esse Conhecimento de Transporte atende á Legislação de Transporte Rodoviário em Vigor"
			Else
				If  (Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LOTA:TEXT")) <> "U"
					cRNLotacao	:= If( oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LOTA:TEXT == '0', "Carga Fracionada", "Lotação")
				Endif
				If  (Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_DPREV:TEXT")) <> "U"
					cRNDtPrv	:= oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_DPREV:TEXT
					cRNDtPrv	:= SubStr(cRNDtPrv,9,2) + '/' + SubStr(cRNDtPrv,6,2) + '/' + SubStr(cRNDtPrv,1,4)
				Endif
				cRNMensagem	:= "Esse Conhecimento de Transporte atende á Legislação de Transporte Rodoviário em Vigor"
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ BOX: CFOP - Natureza da Prestacao                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oDacte:Box(0224, 0000, 0241, 0559)
		oDacte:Say(0230, 0003, "CFOP - Natureza da Prestação",	oFont08N)
		oDacte:Say(0238, 0003, cCFOP + " - " + cDescCfop,		oFont08)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ BOX: ORIGEM DA PRESTACAO                                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oDacte:Box(0243, 0000, 0260, 0279)
		oDacte:Say(0249, 0003, "Origem da Prestação" , oFont08N)
		oDacte:Say(0257, 0003, AllTrim(cOriMunPre) + ' - ' + AllTrim(cOriUFPre), oFont08)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ BOX: DESTINO DA PRESTACAO                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oDacte:Box(0243, 0281, 0260, 0559)
		oDacte:Say(0249, 0288, "Destino da Prestação", oFont08N)
		oDacte:Say(0257, 0288, AllTrim(cDesMunPre) + ' - ' + AllTrim(cDesUFPre), oFont08)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ BOX: Remetente                                                         ³
		//³ BOX: Destinatario                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oDacte:Box(0262, 0000, 0313, 0279)	//Remetente
		oDacte:Box(0262, 0281, 0313, 0559)	//Destinatario

		oDacte:Say(0268, 0003, "Remetente:", oFont08)
		oDacte:Say(0268, 0043, NoAcentoCte(Substr(cRemNome,1,45)), oFont08N)
		oDacte:Say(0268, 0286, "Destinatario:", oFont08)
		oDacte:Say(0268, 0328, NoAcentoCte(Substr(cDesNome,1,45)), oFont08N)

		cInsRemOpc := AllTrim(cRemIE)
		For nCount := 1 To 5
			Do Case
			Case ( nCount == 1 )
				oDacte:Say(0277, 0003, "Endereço:", oFont08)
				oDacte:Say(0277, 0043, AllTrim(cRemEnd) + ", " + cRemNro, oFont08)
				oDacte:Say(0277, 0286, "Endereço:", oFont08)
				oDacte:Say(0277, 0328, AllTrim(cDesEnd) + ", " + cDesNro, oFont08)
			Case ( nCount == 2 )
				oDacte:Say(0284, 0043, AllTrim(cRemCompl) + " - " + AllTrim(cRemBair), oFont08)
				oDacte:Say(0284, 0328, AllTrim(cDesCompl) + " - " + AllTrim(cDesBair), oFont08)
			Case ( nCount == 3 )
				oDacte:Say(0291, 0003, "Municipio:", oFont08)
				oDacte:Say(0291, 0043, AllTrim(cRemMun) + ' - ' + AllTrim(cRemUF)  + ' CEP.: ' + Transform(AllTrim(cRemCEP), "@r 99999-999"), oFont08)
				oDacte:Say(0291, 0286, "Municipio:", oFont08)
				oDacte:Say(0291, 0328, AllTrim(cDesMun) + ' - ' + AllTrim(cDesUF) + ' CEP.: ' + Transform(AllTrim(cDesCEP), "@r 99999-999"), oFont08)
			Case ( nCount == 4 )
				oDacte:Say(0298, 0003, "CNPJ/CPF:", oFont08)
				oDacte:Say(0298, 0043, Transform(AllTrim(cRemCNPJ), "@r 99.999.999/9999-99") + "   Inscrição Estadual: " +  AllTrim(cInsRemOpc), oFont08)
				oDacte:Say(0298, 0286, "CNPJ/CPF:", oFont08)
				oDacte:Say(0298, 0328, Transform(AllTrim(cDesCNPJ), "@r 99.999.999/9999-99") + "   Inscrição Estadual: " +  AllTrim(cDesIE),    oFont08)
			Case ( nCount == 5 )
				oDacte:Say(0305, 0003, "Pais:", oFont08)
				oDacte:Say(0305, 0043, AllTrim(cRemPais) + ' Telefone.: ' + Transform(AllTrim(cRemFone),"@r (999) 999999999"),  oFont08)
				oDacte:Say(0305, 0286, "Pais:", oFont08)
				oDacte:Say(0305, 0328, AllTrim(cDesPais) + ' Telefone.: ' + Transform(AllTrim(cDesFone),"@r (999) 999999999"), oFont08)
			EndCase
		Next nCount

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ BOX: Expedidor / BOX: Recebedor                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oDacte:Box(0315, 0000, 0366, 0279)	//Expedidor
		oDacte:Box(0315, 0281, 0366, 0559)	//Recebedor

		If lExped .Or. Empty(cExpNome)
			oDacte:Say(0322, 0003, "Expedidor:", oFont08)
		Else
			oDacte:Say(0322, 0003, "Local Coleta:", oFont08)
		EndIf
		oDacte:Say(0322, 0043, NoAcentoCte(Substr(cExpNome,1,45))    , oFont08N)

		//-- Sequencia de endereco preenchida, fica como local de entrega.

		If lSeqDes
			oDacte:Say(0322, 0286, "Local de Entrega:", oFont08)
			oDacte:Say(0322, 0342,  NoAcentoCte(Substr(cRecNome,1,45)), oFont08N)
		EndIf

		If lSeqRec
			oDacte:Say(0322, 0286, "Recebedor:", oFont08)
			oDacte:Say(0322, 0328,  NoAcentoCte(Substr(cRecNome,1,45)), oFont08N)
		EndIf

		If !lSeqDes .And. !lSeqRec
			oDacte:Say(0322, 0286, "Recebedor:", oFont08)
		EndIf

		For nCount := 1 To 5
			Do Case
			Case ( nCount == 1 )
				oDacte:Say(0331, 0003, "Endereço:", oFont08)
				oDacte:Say(0331, 0043, cExpEnd    , oFont08)
				oDacte:Say(0331, 0286, "Endereço:", oFont08)
				//-- Sequencia de endereco preenchida, fica como local de entrega.
				oDacte:Say(0331, 0328, If(lSeqDes .or. lSeqRec, AllTrim(FisGetEnd(cRecEnd)[1]) + ", " + Iif(FisGetEnd(cRecEnd)[2]<>0, AllTrim(cValtoChar(FisGetEnd(cRecEnd)[2])),"S/N"),""), oFont08)
			Case ( nCount == 2 )
				oDacte:Say(0338, 0043, AllTrim(cExpCompl) + " - " + AllTrim(cExpBai), oFont08)
				oDacte:Say(0338, 0328, If(lSeqDes .or. lSeqRec, AllTrim(cValtoChar(FisGetEnd(cRecEnd)[4])) + " - " + AllTrim(cRecBai),""), oFont08)
			Case ( nCount == 3 )
				oDacte:Say(0345, 0003, "Municipio:", oFont08)
				oDacte:Say(0345, 0043, AllTrim(cExpMun) + ' - ' + AllTrim(cExpUF)  + ' CEP.: ' + Transform(AllTrim(cExpCEP), "@r 99999-999"), oFont08)
				oDacte:Say(0345, 0286, "Municipio:", oFont08)
				oDacte:Say(0345, 0328, If(lSeqDes .or. lSeqRec, AllTrim(cRecMun) + ' - ' + AllTrim(cRecUF),""), oFont08)
			Case ( nCount == 4 )
				oDacte:Say(0352, 0003, "CNPJ/CPF:", oFont08)
				oDacte:Say(0352, 0043, Transform(AllTrim(cExpCNPJ), "@r 99.999.999/9999-99") + "   Inscrição Estadual: " +  AllTrim(cExpIE), oFont08)
				oDacte:Say(0352, 0286, "CNPJ/CPF:", oFont08)
				If lSeqDes .or. lSeqRec
					If lRecPJ
						oDacte:Say(0352, 0328, Transform(cRecCGC,"@r 99.999.999/9999-99") + "   Inscrição Estadual: " +  cRecINSCR, oFont08)
					Else
						oDacte:Say(0352, 0328, Transform(cRecCPF,"@r 999.999.999-99"), oFont08)
					EndIf
				Else
					oDacte:Say(0352, 0328, "", oFont08)
				EndIf

			Case ( nCount == 5 )
				If lExped .Or. Empty(cExpNome)
					oDacte:Say(0359, 0003, "Pais:" , oFont08)
					oDacte:Say(0359, 0043, AllTrim(cExpPais) + ' Telefone.: ' + Transform(AllTrim(cExpFone),"@r (999) 999999999"),  oFont08)
				EndIf
				If !lSeqDes
					oDacte:Say(0359, 0286, "Pais:" , oFont08)
					oDacte:Say(0359, 0328, If(lSeqRec ,AllTrim(cDesPais),""), oFont08)
				EndIf
			EndCase
		Next nCount

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ BOX: Tomador do Servico                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oDacte:Box(0368, 0000, 0395, 0559)
		oDacte:Say(0375, 0003, "Tomador do Serviço:", oFont08)
		oDacte:Say(0375, 0072, NoAcentoCte(SubStr(cDevNome,1,45)), oFont08)
		oDacte:Say(0375, 0328, "Municipio:", oFont08)
		oDacte:Say(0375, 0368, AllTrim(cDevMun) + ' - ' + AllTrim(cDevUF) + ' CEP.: ' + Transform(AllTrim(cDevCEP),"@r 99999-999"), oFont08)

		For nCount := 1 To 2
			Do Case
			Case ( nCount == 1 )
				oDacte:Say(0383, 0003, "Endereço:", oFont08)
				oDacte:Say(0383, 0043, SubStr(AllTrim(cDevEnd),1,40) + ", " + cDevNro + " - "	+;
					AllTrim(cDevCompl) + " - " + AllTrim(cDevBair), oFont08)
				oDacte:Say(0383, 0328, "Pais: ", oFont08)
				oDacte:Say(0383, 0368, AllTrim(cDevPais), oFont08)
			Case ( nCount == 2 )
				oDacte:Say(0391, 0003, "CNPJ/CPF:", oFont08)
				oDacte:Say(0391, 0043, Transform(AllTrim(cDevCNPJ),"@r 99.999.999/9999-99") + "   Inscrição Estadual: " + AllTrim(cDevIE), oFont08)
				oDacte:Say(0391, 0328, "Telefone:", oFont08)
				oDacte:Say(0391, 0368, Transform(AllTrim(cDevFone),"@r (999) 999999999"), oFont08)
			EndCase
		Next nCount

		lExec := .T.
		If	lExec

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ BOX: Prod Predom || Outras Caract || Valor Total da Mercadoria         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oDacte:Box(0397 , 0000, 0414, 0559)
			oDacte:Line(0397, 0189, 0414, 0189) // Linha: Prod.Predominante e Out.Caracteristicas
			oDacte:Line(0397, 0378, 0414, 0378) // Linha: Out.Caracteristicas e Vlr.Total
			oDacte:Say(0403, 0003, "Produto Predominante"           , oFont08N)
			oDacte:Say(0403, 0192, "Outras Caracteristicas da Carga", oFont08N)
			oDacte:Say(0403, 0381, "Valor Total da Mercadoria"      , oFont08N)
			oDacte:Say(0411, 0003, SubStr(cPPDesc,1,40), oFont08)	//Produto Predominante
			oDacte:Say(0411, 0192, AllTrim(cPPCarga)	, oFont08)	//Outras Caracteristicas da Carga
			oDacte:Say(0411, 0381, PadL( Transform( val(cPPVlTot), PesqPict("DT6","DT6_VALMER") ), 20 ), oFont08)	//Valor Total da Mercadoria

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ BOX: QNT. / UNIDADE MEDIDA /                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oDacte:Box(0416, 0000, 0443,  0315)
			oDacte:Say(0423 , 0003, "Peso Bruto (KG)"	, oFont08N)
			oDacte:Say(0423 , 0067, "Peso Cubado    "	, oFont08N)
			oDacte:Say(0423 , 0131, "M³             "	, oFont08N)
			oDacte:Say(0423 , 0195, "Qtd.Volume (Un)"	, oFont08N)
			oDacte:Say(0423 , nCInic, "                ", oFont08N)
			oDacte:Line(0416, 0064, 0443, 0064) // Linha: Separador Peso Bruto (KG) / Peso Cubado
			oDacte:Line(0416, 0128, 0443, 0128) // Linha: Separador Peso Cubado / M³
			oDacte:Line(0416, 0192, 0443, 0192) // Linha: Separador M³ / Qtd. Volume (Un)
			oDacte:Line(0416, 0256, 0443, 0256) // Linha: SeparadorQtd. Volume (Un) /

			oDacte:Say(0431, 0003, Transform(val(cPPPesoB) ,	PesqPict("DT6","DT6_PESO")   ),	oFont08)
			oDacte:Say(0431, 0067, Transform(val(cPPPeso3) ,	PesqPict("DT6","DT6_PESOM3") ),	oFont08)
			oDacte:Say(0431, 0131, Transform(val(cPPMetro3),	PesqPict("DT6","DT6_METRO3") ),	oFont08)
			oDacte:Say(0431, 0195, cPPQtdVol ,	oFont08)

			//-- Zera as variaveis(Peso, Peso Cubado, Metro Cubico e Qtd Volume) depois de impresso no DACTE.
			cPPPesoB  := ""
			cPPPeso3  := ""
			cPPMetro3 := ""
			cPPQtdVol := ""

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ BOX: SEGURADORA                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oDacte:Box(0416 , 0317, 0443,  0559)
			oDacte:Say(0423 , 0324, "Nome da Seguradora:"	, oFont08N)
			oDacte:Say(0423 , 0400, cSegNome				, oFont08N)
			oDacte:Line(0426, 0317, 0426, 0559)							// Linha: Separador Nome da Seguradora / Responsavel
			oDacte:Say(0433 , 0324, "Responsavel"			, oFont08N)
			oDacte:Say(0440 , 0324, cSegDesc				, oFont08N)
			oDacte:Line(0426, 0402, 0443, 0402)							// Linha: Separador Responsavel / Número da Apolice
			oDacte:Say(0433 , 0405, "Número da Apolice"		, oFont08N)
			oDacte:Say(0440 , 0405, cSegNrApoli				, oFont08N)
			oDacte:Line(0426, 0479, 0443, 0479)							// Linha: Separador Número da Apolice / Número da Averbação
			oDacte:Say(0433 , 0482, "Número da Averbação"	, oFont08N)
			oDacte:Say(0440 , 0477, cSegNrAverb				, oFont08N)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Conteudo do Box: Componentes do Valor da Prestacao de Servico          ³
			//³ Conteudo do Box: Informacoes Relativas ao Imposto                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			TMSR27Comp()

		/*
		cAliasPeri := DataSource("PRODUTOS_PERIGOSOS")
			If (cAliasPeri)->(!Eof())
			lPerig := .T.
			Else
			lPerig := .F.
			EndIf
		(cAliasPeri)->(DbCloseArea())
		*/

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ BOX: DOCUMENTOS ORIGINARIOS                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oDacte:Box(0533 , 0000, 0590, 0559)
			If Empty(cCtrDpc)
				oDacte:Say(00539 , 0243, "Documentos Originários",oFont08N)
			Else
				oDacte:Say(00528 , 0243, "Documentos Originários",oFont08N)
				oDacte:Say(00539 , 0443, "Documentos Anteriores ",oFont08N)
			EndIf

			oDacte:Line(0541, 0000, 0541, 0559)	// Linha: Abaixo    DOCUMENTOS ORIGINARIOS
			//oDacte:Line(0541, 0283, 0590, 0283)	// Linha: Separador DOCUMENTOS ORIGINARIOS

			oDacte:Say(0548 , 0003, "Tp.Doc"            , oFont08N)
			oDacte:Say(0548 , 0033, "CNPJ/CPF Emitente" , oFont08N)
			oDacte:Say(0548 , 0163, "Série/Nr.Documento", oFont08N)

			oDacte:Say(0548 , 0286, "Chave"            , oFont08N)
			//oDacte:Say(0548 , 0316, "CNPJ/CPF Emitente" , oFont08N)
			//oDacte:Say(0548 , 0448, "Série/Nr.Documento", oFont08N)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Documentos Originarios                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lControl := .F.
			nLInic   := 0556

			nCount := 0
			aDoc   := {}

			For nCount := 1 to Len( aDocOri )
				lControl := !lControl
				If nCount < 11
					If Empty(cCtrDpc)
						If lControl
							If Empty(AllTrim(aDocOri[nCount][doDTC_NFEID])) .And. !Empty(AllTrim(aDocOri[nCount][doDTC_SERNFC]))
								//-- Imprime a Chave da NF-e, lado esquerdo
								oDacte:Say(nLInic, 0003, "NF", oFont08)
								oDacte:Say(nLInic, 0033, Transform(AllTrim(cRemCNPJ),"@r 99.999.999/9999-99"), oFont08)
								oDacte:Say(nLInic, 0163, AllTrim(aDocOri[nCount][doDTC_SERNFC] + " / " + AllTrim(aDocOri[nCount][doDTC_NUMNFC])), oFont08)
							ElseIf Empty(AllTrim(aDocOri[nCount][doDTC_NFEID]))
								//-- Imprime os dados do documento não fiscal do lado esquerdo.
								oDacte:Say(nLInic, 0003, "Outros", oFont08)
								oDacte:Say(nLInic, 0033, Transform(AllTrim(cRemCNPJ),"@r 99.999.999/9999-99"), oFont08)
								oDacte:Say(nLInic, 0163, AllTrim(aDocOri[nCount][doDTC_NUMNFC]), oFont08)
							Else
								//-- Imprime a Chave da NF-e, lado esquerdo
								cChaveA := AllTrim(aDocOri[nCount][doDTC_NFEID])
								oDacte:Say(nLInic, 0033, Transform(AllTrim(cRemCNPJ),"@r 99.999.999/9999-99"), oFont08)
								oDacte:Say(nLInic, 0163, SUBSTR(cChaveA,23,3)+"/"+SUBSTR(cChaveA,26,9), oFont08)
								oDacte:Say(nLInic, 0286, cChaveA, oFont08)
								cChaveA := ''
							EndIf
						Else
							//-- Imprime a Chave da NF-e, lado direito
							If Empty(AllTrim(aDocOri[nCount][doDTC_NFEID])) .And. !Empty(AllTrim(aDocOri[nCount][doDTC_SERNFC]))
								oDacte:Say(nLInic, 0286, "NF", oFont08)
								oDacte:Say(nLInic, 0316, Transform(AllTrim(cRemCNPJ),"@r 99.999.999/9999-99"), oFont08)
								oDacte:Say(nLInic, 0448, AllTrim(aDocOri[nCount][doDTC_SERNFC]) + " / " + AllTrim(aDocOri[nCount][doDTC_NUMNFC]), oFont08)
							ElseIf Empty(AllTrim(aDocOri[nCount][doDTC_NFEID]))
								//-- Imprime os dados do documento não fiscal do lado direito.
								oDacte:Say(nLInic, 0286, "Outros", oFont08)
								oDacte:Say(nLInic, 0316, Transform(AllTrim(cRemCNPJ),"@r 99.999.999/9999-99"), oFont08)
								oDacte:Say(nLInic, 0448, AllTrim(aDocOri[nCount][doDTC_NUMNFC]), oFont08)
							Else
								//-- Imprime a Chave da NF-e, lado direito
								cChaveB := AllTrim(aDocOri[nCount][doDTC_NFEID])
								oDacte:Say(nLInic, 0286, "NF-E CHAVE:", oFont08)
								oDacte:Say(nLInic, 0356, cChaveB, oFont08)
								cChaveB := ''
							EndIf
						EndIf
					ElseIf lControl
						If Empty(AllTrim(aDocOri[nCount][doDTC_NFEID])) .And. !Empty(AllTrim(aDocOri[nCount][doDTC_SERNFC]))
							oDacte:Say(nLInic, 0003, "NF", oFont08)
							oDacte:Say(nLInic, 0033, Transform(AllTrim(cRemCNPJ),"@r 99.999.999/9999-99"), oFont08)
							oDacte:Say(nLInic, 0163, AllTrim(aDocOri[nCount][doDTC_SERNFC]) + " / " + AllTrim(aDocOri[nCount][doDTC_NUMNFC]), oFont08)
						ElseIf Empty(AllTrim(aDocOri[nCount][doDTC_NFEID]))
							oDacte:Say(nLInic, 0003, "Outros", oFont08)
							oDacte:Say(nLInic, 0033, Transform(AllTrim(cRemCNPJ),"@r 99.999.999/9999-99"), oFont08)
							oDacte:Say(nLInic, 0163, AllTrim(aDocOri[nCount][doDTC_NUMNFC]), oFont08)
						Else
							//-- Imprime a Chave da NF-e, lado direito
							cChaveA := AllTrim(aDocOri[nCount][doDTC_NFEID])
							oDacte:Say(nLInic, 0003, "NF-E CHAVE:", oFont08)
							oDacte:Say(nLInic, 0073, cChaveA, oFont08)
							cChaveA := ''
						EndIf
						If !Empty(cCtrDpc)
							If Empty(cCTEDocAnt)
								oDacte:Say(nLInic, 0286, cDesDocAnt, oFont08)
								oDacte:Say(nLInic, 0316, Transform(AllTrim((cAliasCT)->DPC_CNPJ),"@r 99.999.999/9999-99"), oFont08)
								oDacte:Say(nLInic, 0448, AllTrim(cSerDpc) + " / " + AllTrim(cCtrDpc), oFont08)
							Else
								//-- Imprime a Chave da NF-e, lado esquerdo
								cChaveB := AllTrim(cCTEDocAnt)
								oDacte:Say(nLInic, 0286, "NF-E CHAVE:", oFont08)
								oDacte:Say(nLInic, 0356, cChaveB, oFont08)
								cChaveB := ''
							EndIf
						EndIf
					EndIf
				Else
					cTipoDoc := IIf(Empty(AllTrim(aDocOri[nCount][doDTC_NFEID])) .And. Empty(AllTrim(aDocOri[nCount][doDTC_SERNFC])),'Outros',IIf(Empty(AllTrim(aDocOri[nCount][doDTC_NFEID])),'NF','NF-e'))
					aadd(aDoc,{ AllTrim(cRemCNPJ),;
						AllTrim(aDocOri[nCount][doDTC_SERNFC]) + " / " + AllTrim(aDocOri[nCount][doDTC_NUMNFC]),;
						AllTrim(aDocOri[nCount][doDTC_NFEID]),cTipoDoc})
					//--Acrescenta o Tipo do Documento no aDoc
				EndIf

				// FORCAR A "QUEBRA" DA LINHA
				If ( (mod(nCount,2)) == 0 )
					If nCount < 11
						If !Empty(cChaveA)
							nLInic += 0008
							oDacte:Say(nLInic, 0003, "NF-E CHAVE:", oFont08)
							oDacte:Say(nLInic, 0073, cChaveA, oFont08)
							cChaveA := ''

							If !Empty(cChaveB)
								oDacte:Say(nLInic, 0286, "NF-E CHAVE:", oFont08)
								oDacte:Say(nLInic, 0356, cChaveB, oFont08)
								cChaveB := ''
							EndIf
						EndIf

						nLInic += 0008
					EndIf
				EndIf
			Next nCount
			nLInic := 2050
		Else
			TMSR27Cmp()
			TMSR27Comp()
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ BOX: OBSERVACOES                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oDacte:Box(0592,  0000, 0643, 0559)
		oDacte:Say(0598,  0278, "Observações", oFont08N)
		oDacte:Line(0600, 0000, 0600, 0559) // Linha: OBSERVACOES

	/*
		If (cAliasCT)->DT6_AMBIEN == 2 .And. Empty((cAliasCT)->DT6_CHVCTG)
		oDacte:Say (0608, 0003, "DOCUMENTO GERADO EM AMBIENTE DE HOMOLOGAÇÃO", oFont10N)
		ElseIf !Empty((cAliasCT)->DT6_CHVCTG) .And. Substr((cAliasCT)->DT6_CHVCTG,3,1) == "5"  //"7-Contingência FS-DA"
		oDacte:Say (0608, 0003, "DACTE em Contingência - impresso em decorrência de problemas técnicos", oFont10N)
		EndIf
	*/

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ BOX: OBSERVACOES                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("DT6") //-- Nao retirar
		If Type("oNfe:_CTE:_INFCTE:_IMP:_INFADFISCO:TEXT") == "U"
			cDT6Obs := " "
		Else
			cDT6Obs := iif(Type("oNfe:_CTE:_INFCTE:_IMP:_INFADFISCO:TEXT")!="U",oNfe:_CTE:_INFCTE:_IMP:_INFADFISCO:TEXT,"")
		EndIf
		If Type("oNfe:_CTE:_INFCTE:_COMPL:_XOBS:TEXT") == "U"
			cDTCObs := " "
		Else
			cDTCObs := iif(Type("oNfe:_CTE:_INFCTE:_COMPL:_XOBS:TEXT")!="U",oNfe:_CTE:_INFCTE:_COMPL:_XOBS:TEXT,"")
		EndIf
		If Type("oNfe:_CTE:_INFCTE:_COMPL:_OBSCONT") == "A"
			aObsCont := {}
			For nX := 1 to len(oNfe:_CTE:_INFCTE:_COMPL:_OBSCONT)
				aAdd(aObsCont, oNfe:_CTE:_INFCTE:_COMPL:_OBSCONT[nX]:_XTEXTO:TEXT )
			Next nX
		ElseIf Type("oNfe:_CTE:_INFCTE:_COMPL:_OBSCONT:_XTEXTO:TEXT") == "U"
			aObsCont := {""}
		Else
			aObsCont := {iif(Type("oNfe:_CTE:_INFCTE:_COMPL:_OBSCONT:_XTEXTO:TEXT")!="U",oNfe:_CTE:_INFCTE:_COMPL:_OBSCONT:_XTEXTO:TEXT,{} )}
		EndIf

		cDT6Obs2:= SubStr(cDT6Obs,141,140)//Caracter 161 a 320
		cDT6Obs := SubStr(cDT6Obs,1,140)  //Caracter 001 a 160

		cDTCObs2:= SubStr(cDTCObs,141,140)
		cDTCObs := SubStr(cDTCObs,1,140)


		oDacte:Say (0616, 0003, cDT6Obs,  oFont07)
		oDacte:Say (0624, 0003, cDT6Obs2, oFont07)

		oDacte:Say (0632, 0003, cDTCObs,  oFont07)
		oDacte:Say (0640, 0003, cDTCObs2, oFont07)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ BOX: INFORMACOES ESPECIFICAS DO MODAL                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oDacte:Box(0643, 0000, 0672, 0559)
		oDacte:Say(0650, 0210, "Dados Especificos do Modal Rodoviário - " + cRNLotacao, oFont08N) // Titulo nao pode ser "FIXO"
		oDacte:Line(0652, 0000, 0652, 0559)
		oDacte:Say(0660, 0143, "CIOT"                 			, oFont08N)
		oDacte:Say(0660, 0178, "Data Prevista de Entrega"		, oFont08N)
		oDacte:Say(0669, 0003, "RNTRC da Empresa: " + cTmsAntt	, oFont08)
//--oDacte:Say(0619, 0146, cRNLotacao,	oFont08) // Reservar campo para uso de CIOT

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ RNTRC                                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oDacte:Say(0669, 0190, cRNDtPrv,	oFont08)
		oDacte:Say(0669, 0283, cRNMensagem,	oFont07)
		oDacte:Line(0653, 0000, 0653, 0559) // Linha: Horizontal Dados Especificos do Modal Rodoviário
		oDacte:Line(0653, 0140, 0672, 0140) // Linha: Separador RNTRC x Lotacao
		oDacte:Line(0653, 0170, 0672, 0170) // Linha: Separador Lotacao x Data Prevista de Entrega
		oDacte:Line(0653, 0280, 0672, 0280) // Linha: Separador Data Prevista de Entrega x Mensagem

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ BOX: DADOS DE LOTACAO/VALE PEDAGIO                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oDacte:Box( 0674, 0000, 0734, 0559)
		oDacte:Line(0674, 0239, 0734, 0239) // Linha Vertical: Separador Informacoes Veiculo x Vale Pedágio

		oDacte:Say(0680 , 0003, "Identificaçao do Conjunto Transportador", oFont08N)
		oDacte:Say(0680 , 0246, "Informações referentes ao vale-pedágio",  oFont08N)
		oDacte:Line(0682, 0000, 0682, 0559) // Linha Horizontal

		oDacte:Say(0688, 0003, "Tipo", oFont08N)
		oDacte:Say(0688, 0063, "Placa", oFont08N)
		oDacte:Say(0688, 0105, "UF", oFont08N)
		oDacte:Say(0688, 0125, "RNTRC", oFont08N)
		oDacte:Say(0688, 0246-4, "NRO.REG.ESP", oFont08N)
		oDacte:Say(0688, 0330-4, "Responsável", oFont08N)
		oDacte:Say(0688, 0455-4, "Valor Total", oFont08N)
		oDacte:Line(0690, 0000, 0690, 0559) // Linha Horizontal	:

		oDacte:Say(0696, 0246-4, "Empresa credenciada",		oFont08N)
		oDacte:Say(0696, 0330-4, "Vigência",				oFont08N)
		oDacte:Say(0696, 0400-4, "Número do Dispositivo",	oFont08N)
		oDacte:Say(0696, 0480-4, "Código da Transação",		oFont08N)
		oDacte:Line(0698, 0243-4, 0698, 0559)		// Linha Horizontal	:

		oDacte:Line(0690, 0060, 0744, 0060)			//Linha Vertical: Separador Tipo x Placa
		oDacte:Line(0690, 0102, 0744, 0102)			//Linha Vertical: Placa x UF
		oDacte:Line(0690, 0122, 0744, 0122)			//Linha Vertical: UF x RNTRC

		oDacte:Line(0682, 0327-4, 0690, 0327-4)	//Linha Vertical: NRO.REG.ESP x Responsável
		oDacte:Line(0682, 0452-4, 0690, 0452-4)	//Linha Vertical: Responsável x Valor Total

		oDacte:Line(0698, 0327-4, 0734, 0327-4)	//Linha Vertical: Empresa credenciada x Vigencia
		oDacte:Line(0698, 0397-4, 0734, 0397-4)	//Linha Vertical: Vigencia x Numero do Dispositivo
		oDacte:Line(0698, 0477-4, 0734, 0477-4)	//Linha Vertical: Numero do Dispositivo x Codigo da Transação

		nLInic:= 0698
		nSoma := 0
		aMotoViag := {}
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ LINHAS: TIPO (VEICULO)                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO")) <> "U"
			If (Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LOTA:TEXT")) <> "U"
				If oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LOTA:TEXT == '1'
					If ValType(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC) == "O" //Se a Tag do Veículo for um Objeto o mesmo possui apenas um veículo
						If Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_TPVEIC:TEXT")!="U"
							cTpVei := If(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_TPVEIC:TEXT == '0','TRACAO','REBOQUE')
						Endif
						cPlaca :=  iif(Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_PLACA:TEXT")!="U",oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_PLACA:TEXT,"")
						cUF    :=  iif(Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_UF:TEXT")!="U",oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_UF:TEXT,"")
						cRNTRC :=  IIf(Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_PROP:_RNTRC:TEXT")!="U",oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_PROP:_RNTRC:TEXT,"")

						oDacte:Say(nLInic + nSoma , 0003, SubStr(AllTrim(cTpVei),1,11), oFont08)
						oDacte:Say(nLInic + nSoma , 0063, cPlaca, oFont08)
						oDacte:Say(nLInic + nSoma , 0105, cUf, oFont08)
						oDacte:Say(nLInic + nSoma , 0125, cRNTRC, oFont08)
					Else //Caso não seja um objeto significa que possui mais de um veículo
						nY := 1
						While nY <= 4
							If Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC["+Alltrim(Str(nY,1))+"]:_TPROD:TEXT") != "U"
								If Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC["+Alltrim(Str(nY))+"]:_TPVEIC:TEXT")!="U"
									cTpVei := If(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC[nY]:_TPVEIC:TEXT == '0','TRACAO','REBOQUE')
								Endif
								cPlaca := iif(Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC["+Alltrim(Str(nY))+"]:_PLACA:TEXT")!="U",oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC[nY]:_PLACA:TEXT,"")
								cUF    := iif(Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC["+Alltrim(Str(nY))+"]:_UF:TEXT")!="U",oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC[nY]:_UF:TEXT,"")
								if Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC["+Alltrim(Str(nY))+"]:_TPPROP:TEXT")!="U"
									cRNTRC := IIf((oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC[nY]:_TPPROP:TEXT) == "P",cTmsAntt,;
										(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC[nY]:_PROP:_RNTRC:TEXT))
								Endif
							Else
								Exit
							EndIf
							oDacte:Say(nLInic + nSoma , 0003, SubStr(AllTrim(cTpVei),1,11), oFont08)
							oDacte:Say(nLInic + nSoma , 0063, cPlaca, oFont08)
							oDacte:Say(nLInic + nSoma , 0105, cUf, oFont08)
							oDacte:Say(nLInic + nSoma , 0125, cRNTRC, oFont08)
							nSoma += 10 //Caso o veículo a ser impresso não seja o primeiro pula uma linha no box
							nY += 1
						EndDo
					EndIf
				Endif
			Endif
			If	Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO") != "U"
				If ValType(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO) == "O"
					cNomeMoto:= iif(Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO:_XNOME:TEXT")!="U",oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO:_XNOME:TEXT,"")
					cCpfMoto := iif(Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO:_CPF:TEXT")!="U",oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO:_CPF:TEXT,"")
					aAdd(aMotoViag,{cNomeMoto, cCPFMoto})
				Else
					If Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO")=="A"
						For nX := 1 To Len(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO)
							cNomeMoto:= iif(Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO["+Alltrim(Str(nX))+"]:_XNOME:TEXT")!="U",oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO[nX]:_XNOME:TEXT,"")
							cCpfMoto := iif(Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO["+Alltrim(Str(nX))+"]:_CPF:TEXT")!="U",oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO[nX]:_CPF:TEXT,"")
							If aScan(aMotoViag,{|x|x[1]+x[2]==cNomeMoto+cCPFMoto}) == 0
								aAdd(aMotoViag,{cNomeMoto, cCPFMoto})
							EndIf
						Next nX
					Endif
				EndIf
			EndIf
			If	Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LACRODO") != "U"
				If ValType(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LACRODO) == "O"
					cLacre += iif(Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LACRODO:_NLACRE:TEXT")!="U",oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LACRODO:_NLACRE:TEXT,"")
				Else
					nY := 1
					While nY <= 5
						If Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LACRODO["+Str(nY,1)+"]:_NLACRE:TEXT") != "U"
							If !Empty(cLacre)
								cLacre += ' / '
							EndIf
							cLacre += iif(Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LACRODO["+Alltrim(Str(nY))+"]:_NLACRE:TEXT")!="U",oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LACRODO[nY]:_NLACRE:TEXT,"")
						Else
							Exit
						EndIf
						nY ++
					EndDo
				EndIf
			EndIf
		ElseIf (Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO")) <> "U" .And. (oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LOTA:TEXT) == '1'
			If Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC") == "O" //Se a Tag do Veículo for um Objeto o mesmo possui apenas um veículo
				If Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_TPVEIC:TEXT")!="U"
					cTpVei := If(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_TPVEIC:TEXT == '0','TRACAO','REBOQUE')
				Endif
				cPlaca := iif(Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_PLACA:TEXT")!="U",oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_PLACA:TEXT,"")
				cUF    := iif(Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_UF:TEXT")!="U",oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_UF:TEXT,"")
				If Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_TPPROP:TEXT")!="U"
					cRNTRC := IIf((oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_TPPROP:TEXT) == "P",cTmsAntt,;
						(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_RNTRC:TEXT))
				Endif
				oDacte:Say(nLInic + nSoma , 0003, SubStr(AllTrim(cTpVei),1,11), oFont08)
				oDacte:Say(nLInic + nSoma , 0063, cPlaca, oFont08)
				oDacte:Say(nLInic + nSoma , 0105, cUf,    oFont08)
				oDacte:Say(nLInic + nSoma , 0125, cRNTRC, oFont08)
			Else //Caso não seja um objeto significa que possui mais de um veículo
				nY := 1
				While nY <= 4
					If Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC["+Str(nY,1)+"]:_TPROD:TEXT") != "U"
						If Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC["+Alltrim(Str(nY))+"]:_TPVEIC:TEXT")!="U"
							cTpVei := If(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC[nY]:_TPVEIC:TEXT = '0','TRACAO','REBOQUE')
						Endif
						cPlaca := iif(Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC["+Alltrim(Str(nY))+"]:_PLACA:TEXT")!="U",oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC[nY]:_PLACA:TEXT,"")
						cUF    := iif(Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC["+Alltrim(Str(nY))+"]:_UF:TEXT")!="U",oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC[nY]:_UF:TEXT,"")
						If Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC["+Alltrim(Str(nY))+"]:_TPPROP:TEXT")!="U"
							cRNTRC := IIf((oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC[nY]:_TPPROP:TEXT) == "P",cTmsAntt,;
								(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC[nY]:_PROP:_RNTRC:TEXT))
						Endif
					Else
						Exit
					EndIf
					oDacte:Say(nLInic + nSoma , 0003, SubStr(AllTrim(cTpVei),1,11), oFont08)
					oDacte:Say(nLInic + nSoma , 0063, cPlaca, oFont08)
					oDacte:Say(nLInic + nSoma , 0105, cUf,    oFont08)
					oDacte:Say(nLInic + nSoma , 0125, cRNTRC, oFont08)
					nSoma += 10 //Caso o veículo a ser impresso não seja o primeiro pula uma linha no box
					nY += 1
				EndDo
			EndIf
			If	Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO") != "U"
				If ValType(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO) == "O"
					cNomeMoto:= iif(Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO:_XNOME:TEXT")!="U",oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO:_XNOME:TEXT,"")
					cCpfMoto := iif(Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO:_CPF:TEXT")!="U",oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO:_CPF:TEXT,"")
				Else
					If Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO")!="U"
						For nX := 1 To Len(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO)
							cNomeMoto:= iif(Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO["+Alltrim(Str(nX))+"]:_XNOME:TEXT")!="U",oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO[nX]:_XNOME:TEXT,"")
							cCpfMoto := iif(Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO["+Alltrim(Str(nX))+"]:_CPF:TEXT")!="U",oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO[nX]:_CPF:TEXT,"")
							If aScan(aMotoViag,{|x|x[1]+x[2]==cNomeMoto+cCPFMoto}) == 0
								aAdd(aMotoViag,{cNomeMoto, cCPFMoto})
							EndIf
						Next nX
					Endif
				EndIf
			EndIf

			If	Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LACRODO") != "U"
				If ValType(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LACRODO) == "O"
					cLacre += iif(Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LACRODO:_NLACRE:TEXT")!="U",oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LACRODO:_NLACRE:TEXT,"")
				Else
					nY := 1
					While nY <= 5
						If Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LACRODO["+Str(nY,1)+"]:_NLACRE:TEXT") != "U"
							If !Empty(cLacre)
								cLacre += ' / '
							EndIf
							cLacre += iif(Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LACRODO["+Alltrim(Str(nY))+"]:_NLACRE:TEXT")!="U",oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LACRODO[nY]:_NLACRE:TEXT,"")
						Else
							Exit
						EndIf
						nY ++
					EndDo
				EndIf
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ BOX:  MOTORISTA                                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oDacte:Box(0736 , 0000, 0762, 0559)
		oDacte:Line(0736, 0243, 0762, 0243) // Linha: Nome do Motorista|CPF do Motorista
		oDacte:Line(0736, 0327, 0762, 0327) // Linha: CPF do Motorista|Identificação dos lacres em Trânsito
		oDacte:Line(0743, 0000, 0743, 0559) // Linha Horizontal
		oDacte:Say(0742 , 0003, "Nome do Motorista", oFont08N)
		oDacte:Say(0742 , 0246, "CPF do Motorista",  oFont08N)
		oDacte:Say(0742 , 0330, "Identificação dos lacres em Trânsitos", oFont08N)
		nSoma := 0
		For nX := 1 To Len(aMotoViag)
			If nX > 2
				Exit
			EndIf
			oDacte:Say(0750 + nSoma,0003, aMotoViag[nX,1], oFont08)
			oDacte:Say(0750 + nSoma,0246, aMotoViag[nX,2], oFont08)
			If nX == 1
				oDacte:Say(0735 + nSoma,0330, cLacre,    oFont08)
			EndIf
			nSoma += 10
		Next nX

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ BOX: USO EXCLUSIVO DO EMISSOR + RESERVADO AO FISCO                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oDacte:Box(0764 , 0000, 0810, 0559)
		oDacte:Say(0770 , 0090, "USO EXCLUSIVO DO EMISSOR DO CT-E", oFont08N)
		nSoma := 0
		For nX := 1 to len(aObsCont)
			If nX > 3
				Exit
			EndIf
			oDacte:Say(0780 + nSoma, 0003, aObsCont[nX], oFont08)
			nSoma += 10
		Next
		oDacte:Say(0770 , 0420, "RESERVADO AO FISCO", oFont08N)
		oDacte:Line(0773, 0000, 0773, 0559)	//Linha Horizontal
		oDacte:Line(0764, 0355, 0810, 0355)	//Linha Vertical

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualizar o Status de Impressao no CTe                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	/*
	DT6->(dbSetOrder(1))
		If	DT6->(MsSeek(xFilial('DT6')+(cAliasCT)->DT6_FILDOC+(cAliasCT)->DT6_DOC+(cAliasCT)->DT6_SERIE))
		RecLock('DT6',.F.)
		DT6->DT6_FIMP := StrZero(1, Len(DT6->DT6_FIMP)) //Grava Flag de Impressao
		MsUnLock()
		EndIf
	*/
		oDacte:EndPage()

		//-- aDoc > 0, existe mais de uma pagina com Doc a ser impressa.
		//-- lPerig .T. existem produtos perigosos a serem impressos.
		If Len(aDoc) > 0 .Or. lPerig
			//-- Caso de mais de uma pagina, chama a funcao para montar as paginas seguites.
			TMSR27Cont(aDoc, aCab[nCont])
		EndIf
		(cAliasCT)->(DbSkip())
	EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TERMINO ROTINA DE IMPRESSAO                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oDacte:Preview()

	(cAliasCT)->(dbCloseArea())

Return(.T.)
/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  |TMSR27Cont³ Autor ³Ovio Consultoria       ³ Data ³01/10/20  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ³±±
	±±³Descri‡…o ³Caso de mais de uma pagina, chama a funcao para montar      ³±±
	±±³          ³as paginas seguites.                                        ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   |                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³Nenhum                                                      ³±±
	±±³          ³                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³          ³               ³                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TMSR27Cont(aDoc, aCab, aPerigo, nCnt)
	Local oFont08     := TFont():New("Times New Roman",08,08,,.F.,,,,.T.,.F.)
	Local oFont08N    := TFont():New("Times New Roman",08,08,,.T.,,,,.T.,.F.)
	Local lControl    := .F.
	Local nCount      := 0
	Local aDoc1       := {}
	Local cChaveA     := ''
	Local cChaveB     := ''

//Variaveis Produtos Perigosos
	Local nCompr		:= 50	//Comprimento Padrao da Primeira Linha
	Local nSegLinha		:= 1	//Trecho a ser Impresso para cada linha
	Local lVerif		:= .F.	//Evita Repeticao de Impressao
	Local lFimPerig		:= .F.

	Default nCnt		:= 1
	Default aPerigo		:= {}
	Default aDoc		:= {}
	Default aCab		:= {}

	oDacte:StartPage()
	oDacte:SetPaperSize(Val(GetProfString(GetPrinterSession(),"PAPERSIZE","1",.T.)))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao responsavel pela montagem do cabecalho do DACTE                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TMSR27Cab(aCab,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ BOX: DOCUMENTOS ORIGINARIOS                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oDacte:Box(0224, 0000, 0593, 0559)
	oDacte:Say(0230, 0210, "DOCUMENTOS ORIGINARIOS", oFont08N)

	oDacte:Line(0232, 0000, 0232, 0559) 	// Linha: DOCUMENTOS ORIGINARIOS
	oDacte:Line(0232, 0280, 0593, 0280) // Linha: Separador DOCUMENTOS ORIGINARIOS
	oDacte:Say( 0238, 0003, "Tp.Doc"            , oFont08N)
	oDacte:Say( 0238, 0033, "CNPJ/CPF Emitente" , oFont08N)
	oDacte:Say( 0238, 0163, "Série/Nr.Documento", oFont08N)
	oDacte:Say( 0238, 0286, "Tp.Doc"            , oFont08N)
	oDacte:Say( 0238, 0316, "CNPJ/CPF Emitente" , oFont08N)
	oDacte:Say( 0238, 0448, "Série/Nr.Documento", oFont08N)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime as NF                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lControl := .F.
	nLInic := 0244
	For nCount := 1 To Len(aDoc)
		lControl := !lControl

		If nCount < 75
			If (lControl == .T.)
				If Empty(aDoc[nCount,3])
					oDacte:Say(nLInic, 0003, aDoc[nCount,4],										oFont08)
					oDacte:Say(nLInic, 0033, Transform(aDoc[nCount,1],"@r 99.999.999/9999-99"),	oFont08)
					oDacte:Say(nLInic, 0163, aDoc[nCount,2],										oFont08)
				Else
					cChaveA     := aDoc[nCount,3]
					oDacte:Say(nLInic, 0003, "NF-E CHAVE:"	,oFont08)
					oDacte:Say(nLInic, 0073,aDoc[nCount,3],oFont08)
					cChaveA     := ''
				EndIf

			Else
				If Empty(aDoc[nCount,3])
					oDacte:Say(nLInic, 0286, aDoc[nCount,4],									    oFont08)
					oDacte:Say(nLInic, 0316, Transform(aDoc[nCount,1],"@r 99.999.999/9999-99"),	oFont08)
					oDacte:Say(nLInic, 0448, aDoc[nCount,2],										oFont08)
				Else
					cChaveB     := aDoc[nCount,3]
					oDacte:Say(nLInic, 0286, "NF-E CHAVE:"	,oFont08)
					oDacte:Say(nLInic, 0356, aDoc[nCount,3],oFont08)
					cChaveB     := ''
				EndIf
				nLInic += 0008
			EndIf
		Else
			aAdd(aDoc1,{aDoc[nCount,1],;
				aDoc[nCount,2],;
				aDoc[nCount,3],;
				aDoc[nCount,4]})
		EndIf

	Next nCount

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime a ultima Chave.                                                 ³
//³FORCAR A "QUEBRA" DA LINHA                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cChaveA)
		nLInic += 0008
		oDacte:Say(nLInic, 0003, "NF-E CHAVE:",	oFont08)
		oDacte:Say(nLInic, 0073,cChaveA ,		oFont08)
		cChaveA := ''

		If !Empty(cChaveB)
			oDacte:Say(nLInic, 0286, "NF-E CHAVE:",	oFont08)
			oDacte:Say(nLInic, 0356, cChaveB,		oFont08)
			cChaveB := ''
		EndIf
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ BOX: Produtos Perigosos                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAliasPeri := DataSource("PRODUTOS_PERIGOSOS")
	nSoma   := 1380

	If (cAliasPeri)->(!Eof())
		nDifEsq:= 110
		nLInic := 2214
		oDacte:Box(0645 , 0000, 0820, 0559)
		oDacte:Say(0651 , 0200, "Informações sobre Produtos Perigosos", oFont08N)
		nSoma  := 12
		oDacte:Line(0653, 0000, 0653, 0559)		// Linha Horizontal
		oDacte:Line(0653, 0032, 0820, 0032 )	// Linha Divisoria Nro. Onu X Nome Apropriado
		oDacte:Line(0653, 0262, 0820, 0262 )	// Linha Divisoria Nome Apropriado X Classe/Subclasse e Risco Subsidiário
		oDacte:Line(0653, 0430, 0820, 0430 )	// Linha Divisoria Classe Subclasse e Risco Subsidiário X Grupo de Embalagem
		oDacte:Line(0653, 0501, 0820, 0501 )	// Linha Divisoria Grupo de Embalagem X Qto. Tot. Produto

		oDacte:Say(0659 , 0002, "Nro. Onu"			, oFont08N)
		oDacte:Say(0659 , 0035, "Nome Apropriado" 	, oFont08N)
		oDacte:Say(0659 , 0265, "Classe/Subclasse e Risco Subsidiário", oFont08N)
		oDacte:Say(0659 , 0433, "Grupo de Embalagem", oFont08N)
		oDacte:Say(0659 , 0504, "Qto. Tot. Produto" , oFont08N)
		nLInic :=  0665
		If Len(aPerigo) <= 0
			Do While (cAliasPeri)->(!EoF())
				AAdd(aPerigo,{	(cAliasPeri)->DY3_ONU,;
					(cAliasPeri)->DY3_DESCRI,;
					(cAliasPeri)->DY3_CLASSE + ' ' + (cAliasPeri)->DY3_NRISCO, ;
					(cAliasPeri)->DY3_GRPEMB,;
					Str((cAliasPeri)->DTC_PESO)})
				(cAliasPeri)->(dbSkip())
			EndDo
		EndIf

		For nCnt := nCnt to Len(aPerigo)														//Verifica tamanho do array
			oDacte:Say(nLInic , 0002,     aPerigo[nCnt][1]   , oFont08)						//Nro. Onu
			For nSegLinha:= nSegLinha To Len(aPerigo[nCnt][2])									//
				oDacte:Say(nLInic , 0035,Substr(aPerigo[nCnt][2],nSegLinha,nCompr), oFont08)	//Nome Apropriado
				If !lVerif 																		//Nao repete valores a cada quebra de linha
					oDacte:Say(nLInic , 0265,aPerigo[nCnt][3]	, oFont08)						//Classe/Subclasse e Risco Subsidiário
					oDacte:Say(nLInic , 0433,aPerigo[nCnt][4] 	, oFont08)						//Grupo de Embalagem
					oDacte:Say(nLInic , 0504,aPerigo[nCnt][5]	, oFont08)						//Qto. Tot. Produto
					lVerif := .T.
				EndIf
				nSegLinha += nCompr -1
				If Len(aPerigo[nCnt][2]) > nSegLinha
					nLInic += 0008
				EndIf
				If nLInic >= 0770		//Verifica se chegou ao fim da pagina
					lFimPerig := .T.
					Exit
				EndIf
			Next
			If lFimPerig
				Exit
			EndIf
			nSegLinha := 1
			lVerif	:= .F. // Reinicia valor para o proximo elemento
		Next
		nCnt++
	EndIf
	(cAliasPeri)->(DbCloseArea())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Linha de finalizacao.                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oDacte:EndPage()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se existir mais doc para outra pagina, chama a mesma funcao.           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aDoc1) > 1
		TMSR27Cont(aDoc1,aCab)
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se existir mais prod perigoso para outra pagina, chama a mesma funcao. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nLInic >= 0820
		TMSR27Cont(,aCab,aPerigo,nCnt)
	EndIf

Return
/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ TMSR27Cab³ Autor ³Ovio Consultoria           ³ Data ³01/10/20  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³Funcao responsavel por montar o cabecalho do relatorio      ³±±
	±±³          ³                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   |                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³Nenhum                                                      ³±±
	±±³          ³                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³          ³               ³                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TMSR27Cab(aCab, lImpCan)
	Local oFont07    := TFont():New("Times New Roman",07,07,,.F.,,,,.T.,.F.)	//Fonte Times New Roman 07
	Local oFont07N   := TFont():New("Times New Roman",07,07,,.T.,,,,.T.,.F.)	//Fonte Times New Roman 08 Negrito
	Local oFont08    := TFont():New("Times New Roman",08,08,,.F.,,,,.T.,.F.)	//Fonte Times New Roman 08
	Local oFont08N   := TFont():New("Times New Roman",08,08,,.T.,,,,.T.,.F.)	//Fonte Times New Roman 08 Negrito
	Local cTpServ    := ''
	Local cProtocolo := ''
	Local cStartPath := GetSrvProfString("Startpath","")
	Local cTmsAntt   := SuperGetMv( "MV_TMSANTT", .F., .F. )	//Numero do registro na ANTT com 14 dígitos
	Local cLogoTp	 := cStartPath + "logoCte" + cEmpAnt + ".BMP" //Insira o caminho do Logo da empresa logada, na variavel cLogoTp.

	Default lImpCan  := .F.

	If	IsSrvUnix() .And. GetRemoteType() == 1
		cLogoTp := StrTran(cLogoTp,"/","\")
	Endif

	If  !File(cLogoTp)
		cLogoTp    := cStartPath + "logoCte.bmp"
	EndIf

	If Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_RNTRC:TEXT")<>"U"
		cTmsAntt := oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_RNTRC:TEXT
	Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ BOX: CANHOTO - 0746                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If	lImpCan

		_cCliDev := (cAliasCT)->DS_FORNEC
		_cLojDev := (cAliasCT)->DS_LOJA
		_cNomUser:=""//UsrRetName(Posicione("DT6",1,xFilial("DT6")+cFILANT+aCab[1]+aCab[2],"DT6_USRGER"))
		_cCgcDev :=Posicione("SA2",1,xFilial("SA2")+_cCliDev+_cLojDev,"A2_CGC")
		_cNomDev :=Posicione("SA2",1,xFilial("SA2")+_cCliDev+_cLojDev,"A2_NOME")
		_cMunDev :=Posicione("SA2",1,xFilial("SA2")+_cCliDev+_cLojDev,"A2_MUN")
		_cEstDev :=Posicione("SA2",1,xFilial("SA2")+_cCliDev+_cLojDev,"A2_EST")
		_cLogado :=Posicione("SA2",1,xFilial("SA2")+_cCliDev+_cLojDev,"A2_END")
		_cNumero :=Posicione("SA2",1,xFilial("SA2")+_cCliDev+_cLojDev,"A2_NR_END")
		_cBairro :=Posicione("SA2",1,xFilial("SA2")+_cCliDev+_cLojDev,"A2_BAIRRO")
		_cCEP    :=Posicione("SA2",1,xFilial("SA2")+_cCliDev+_cLojDev,"A2_CEP")
		_cInscr  :=Posicione("SA2",1,xFilial("SA2")+_cCliDev+_cLojDev,"A2_INSCR")
		_cTel    :=Posicione("SA2",1,xFilial("SA2")+_cCliDev+_cLojDev,"A2_TEL")


		oDacte:Box(0020, 0000, 0082, 0559)
		oDacte:Say(026 , 0005, "TOMADOR: " + SPACE(05) +Transform(_cCgcDev, PesqPict("SA2","A2_CGC"))+ '  -  ' + SPACE(05) +;
			_cNomDev + '  -  ' + SPACE(05) + _cMunDev + '  -  '  + _cEstDev + '  -  ' + SPACE(05) + AllTrim(SM0->M0_CIDCOB) + '  -  ' +;
			AllTrim(SM0->M0_ESTCOB) , oFont07)

		oDacte:Line(0029, 0000, 0029, 0559) // Linha horizontal
		oDacte:Say(0036 , 0001, "DECLARO QUE RECEBI OS VOLUMES DESTE CONHECIMENTO EM PERFEITO ESTADO PELO QUE DOU POR CUMPRIDO O PRESENTE CONTRATO DE TRANSPORTE", oFont07)
		oDacte:Line(0039, 0000, 0039, 0559) // Linha horizontal

		oDacte:Line(0062, 0000, 0062, 0166) // Linha Horizontal: Separador NOME e RG
		oDacte:Line(0062, 0416, 0062, 0513) // Linha Horizontal: Separador CHEGADA e SAIDA

		oDacte:Line(0039, 0166, 0082, 0166) // Linha vertical
		oDacte:Line(0039, 0416, 0082, 0416) // Linha vertical
		oDacte:Line(0039, 0513, 0082, 0513) // Linha vertical

		oDacte:Say(0047 , 0005, "Nome"               	, oFont07N)
		oDacte:Say(0047 , 0421, "Chegada Data / Hora"	, oFont07N)
		oDacte:Say(0047 , 0530, "CT-e"					, oFont07N)
		oDacte:Say(0057 , 0530, "Nro: " , oFont07N)
		oDacte:Say(0067 , 0518, cValtoChar( Val(aCab[1]))	, oFont07N)
		oDacte:Say(0079 , 0518, "Série: "+cValtoChar( Val(aCab[2]))	, oFont07N)
		oDacte:Say(0070 , 0005, "R.G"                	, oFont07N)
		oDacte:Say(0079 , 0241, "Assinatura / Carimbo"  , oFont07N)
		oDacte:Say(0070 , 0421, "Saída Data / Hora"  	, oFont07N)
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ BOX: Empresa + 0050                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oDacte:Box(0086, 0000, 0203, 0322)
	oDacte:SayBitmap(0088, 0005,cLogoTp,0310,0040 )		//Logo
	oDacte:Say(0148, 0005, AllTrim(_cNomDev),oFont08) 	//Nome Comercial
	oDacte:Say(0158, 0005, AllTrim(_cLogado)+" "+Alltrim(_cNumero) ,oFont08)	//Endereco
	oDacte:Say(0168, 0005, AllTrim(_cBairro),oFont08)	//Bairro
	oDacte:Say(0178, 0005, AllTrim(_cMunDev) + '  -  ' + AllTrim(_cEstDev) + '  CEP.:  ' + AllTrim(_cCEP) ,oFont08)	//Cidade, UF, CEP
	oDacte:Say(0188, 0005, 'CNPJ: ' + Transform(AllTrim(_cCgcDev),"@r 99.999.999/9999-99"))
	oDacte:Say(0188, 0100, 'Inscrição Estadual: ' + AllTrim(_cInscr)	,oFont08)	//CNPJ e IE
	oDacte:Say(0198, 0005, 'Telefone: '           + AllTrim(_cTel)	    ,oFont08)	//Telefone
	oDacte:Say(0198, 0100, 'RNTRC da Empresa: '   + AllTrim(cTmsAntt)	,oFont08)	//RNTRC da Empresa

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ BOX: DACTE                                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oDacte:Box(0086, 0324, 0103, 0472)
	oDacte:Say(0092, 390, "DACTE", oFont08N)
	oDacte:Say(01000, 340, (Upper("Documento Auxiliar do CT-e")),oFont08)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ BOX: MODAL                                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oDacte:Box(0086, 0474, 0103, 0559)
	oDacte:Say(0092, 504,"MODAL"     ,oFont08N)
	oDacte:Say(0100, 501,"Rodoviário",oFont08 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³BOX: Modelo / Serie / Numero / Folha / Emis                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oDacte:Box(0105, 0324, 0122 , 0559)
	oDacte:Say(0111, 0334, "Modelo" , oFont08N)	//Modelo
	oDacte:Say(0118, 0339,"57",oFont08)

	oDacte:Say(0111, 0374, "Serie"  , oFont08N)	//Serie
	oDacte:Say(0118, 0379, cValtoChar( Val(aCab[2]) ), oFont08)

	oDacte:Say(0111, 0414, "Número" , oFont08N)	//Numero
	oDacte:Say(0118, 0419, cValtoChar( Val(aCab[1]) ), oFont08)

	oDacte:Say(0111, 0451, "Folha"  , oFont08N)	//Folha
	oDacte:Say(0118, 0454, AllTrim(Str(nFolhAtu)) + " / " + AllTrim(Str(nFolhas)), oFont08)
	nFolhAtu ++

	oDacte:Say(0111, 0502, "Emissão", oFont08N)//Emissao
	oDacte:Say(0118, 0482, 	SubStr(AllTrim(aCab[3]), 7, 2) + '/'   +;
		SubStr(AllTrim(aCab[3]), 5, 2) + "/"   +;
		SubStr(AllTrim(aCab[3]), 1, 4) + " - " +;
		SubStr(AllTrim(aCab[4]), 1, 2) + ":"   +;
		SubStr(AllTrim(aCab[4]), 3, 2) + ":00")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ BOX: Controle do Fisco                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oDacte:Box(0124, 0324, 0203, 0559)
	oDacte:Code128C(152.6,337,AllTrim(aCab[5]), 29)

	oDacte:Line(0153, 0324, 0153, 0559 )	//Linha Separadora
	oDacte:Say( 0158, 0325,"Chave de acesso para consulta de autenticidade no site www.cte.fazenda.gov.br",oFont07)
	oDacte:Say( 0168, 0330, Transform(AllTrim(aCab[5]),"@r 99.9999.99.999.999/9999-99-99-999-999.999.999.999.999.999.9"), oFont08N)
	oDacte:Line(0172, 0324, 0172, 0559 )	//Linha Separadora

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  BOX: Tipo do CTe                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oDacte:Box(0205, 0000, 0222 , 0559)
	oDacte:Say(0211, 0003, "Tipo do CTe"                 , oFont08N)
	oDacte:Say(0211, 0073, "Tipo de Serviço"             , oFont08N)
	oDacte:Say(0211, 0160, "Tomador do Serviço"          , oFont08N)
	oDacte:Say(0211, 0243, "Forma de Pagamento"          , oFont08N)
	oDacte:Say(0211, 0324, "Número do Protocolo"         , oFont08N)
	oDacte:Say(0211, 0457, "Insc.Suframa do Destinatário", oFont08N)
	oDacte:Line(0205, 0071, 0222 , 0071) // Linha: Divide Tp.CTe e Tp.Servico
	oDacte:Line(0205, 0158, 0222 , 0158) // Linha: Tp.Servico e Tomador
	oDacte:Line(0205, 0241, 0222 , 0241) // Linha: Tomador e Forma Pagto
	oDacte:Line(0205, 0322, 0222 , 0322) // Linha: Divide Forma Pagto e Protocolo
	oDacte:Line(0205, 0455, 0222 , 0455) // Linha: Divide Protocolo e Suframa Dest.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tipo de Conhecimento                                            ³
//³ 0 - Normal                                                      ³
//³ 1 - Complemento de Valores                                      ³
//³ 2 - Emitido em Hipotese de anulacao de Debito                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oDacte:Say(0218,  0003, "NORMAL"		, oFont08)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tipo de Servico                                                 ³
//³ 0 - Normal                                                      ³
//³ 1 - SubContratacao                                              ³
//³ 2 - Redespacho                                                  ³
//³ 3 - Redespacho Intermediario                                    ³
//³ 4 - Serviço Vinculado a Multimodal                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ DTC - Notas Fiscais: (Informacao do campo DTC_TIPNFC)           ³
//³   0 - Normal                                                    ³
//³   1 - Devolucao                                                 ³
//³   2 - SubContratacao                                            ³
//³   3 - Dcto Nao Fiscal                                           ³
//³   4 - Exportacao                                                ³
//³   5 - Redespacho                                                ³
//³   6 - Dcto Nao Fiscal 1                                         ³
//³   7 - Dcto Nao Fiscal 2                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTpServ := iif(Type("oNfe:_CTE:_INFCTE:_IDE:_tpserv:TEXT")!="U",oNfe:_CTE:_INFCTE:_IDE:_tpserv:TEXT,"")

	If (cTpServ $ '0')
		oDacte:Say(0218, 0073, "NORMAL"				, oFont08)
	ElseIf (cTpServ == '1')
		oDacte:Say(0218, 0073, "SUBCONTRATAÇÃO"		, oFont08)
	ElseIf (cTpServ == '2')
		oDacte:Say(0218, 0073, "REDESPACHO"			, oFont08)
	ElseIf (cTpServ == '3')
		oDacte:Say(0218, 0073, "REDESPACHO INTERM"	, oFont08)	//--Redespacho Intermediário
	ElseIf (cTpServ == '4')
		oDacte:Say(0218, 0073, "SERV.VINC.MULTIMODAL", oFont08)	//--Serviço vinculado Multimodal
	Else
		oDacte:Say(0218, 0073, "NORMAL"				, oFont08)
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tomador do Servico                                              ³
//³ 0 - Remetente;                                                  ³
//³ 1 - Expedidor;                                                  ³
//³ 2 - Recebedor;                                                  ³
//³ 3 - Destinatario;                                               ³
//³ 4 - Outros. (Consignatario / Despachante)                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Forma de Pagamento do Servico                                   ³
//³ 0 - Pago                                                        ³
//³ 1 - A pagar                                                     ³
//³ 2 - Outros                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Type("oNfe:_CTE:_INFCTE:_IDE:_TOMA03:_TOMA:TEXT") <> "U"
		If oNfe:_CTE:_INFCTE:_IDE:_TOMA03:_TOMA:TEXT == "0"
			oDacte:Say(0218,  0160, "REMETENTE"  	, oFont08)	//Tomador do Servico
			oDacte:Say(0218,  0243, "PAGO"       	, oFont08)	//Forma de Pagamento do Servico
		ElseIf oNfe:_CTE:_INFCTE:_IDE:_TOMA03:_TOMA:TEXT == "1"
			oDacte:Say(0218,  0160, "EXPEDIDOR"  	, oFont08)
			oDacte:Say(0218,  0243, "A PAGAR"       , oFont08)
		ElseIf oNfe:_CTE:_INFCTE:_IDE:_TOMA03:_TOMA:TEXT == "2"
			oDacte:Say(0218,  0160, "RECEBEDOR"  	, oFont08)
			oDacte:Say(0218,  0243, "A PAGAR"       , oFont08)
		ElseIf oNfe:_CTE:_INFCTE:_IDE:_TOMA03:_TOMA:TEXT == "3"
			oDacte:Say(0218,  0160, "DESTINATÁRIO"  , oFont08)
			oDacte:Say(0218,  0243, "A PAGAR"       , oFont08)
		EndIf
	ElseIf Type("oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_TOMA:TEXT") <> "U"
		If oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_TOMA:TEXT == "4"
			oDacte:Say(0218,  0193, "OUTROS"  	, oFont08)
			oDacte:Say(0218,  0243, "OUTROS"    , oFont08)
		EndIf
	EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Numero Protocolo + Data e Hora Autorizacao                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cProtocolo := aCab[6] + " " + aCab[8] + " " + aCab[9]
	oDacte:Say(0218,  0324, cProtocolo, oFont08)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Insc.Suframa do Destinatário                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oDacte:Say(0218,  0457,"" , oFont08)//ISUF

Return

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³TMSR27Comp³ Autor ³Ovio Consultoria       ³ Data ³01/10/20  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³Funcao responsavel por montar o BOX com as informacoes do   ³±±
	±±³          ³componentes do frete e impostos                             ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   |                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³Nenhum                                                      ³±±
	±±³          ³                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³          ³               ³                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TMSR27Comp()
	Local cLabel      	:= ''
	Local nCInic      	:= 0			// Coluna Inicial
	Local oFont08     	:= TFont():New("Times New Roman",08,08,,.F.,,,,.T.,.F.)
	Local oFont08N    	:= TFont():New("Times New Roman",08,08,,.T.,,,,.T.,.F.)
	Local oFont10N    	:= TFont():New("Times New Roman",10,10,,.T.,,,,.T.,.F.)
	Local lControl    	:= .F.
	Local nCount      	:= 0
	Local nCount_2    	:= 0
	Local cSitTriba		:= "Sit Trib"
	Local cBaseIcms		:= ''			//-- Base de Calculo
	Local cAliqIcms		:= ''			//-- Aliquota ICMS
	Local cValIcms		:= ''			//-- Valor ICMS
	Local cRedBcCalc	:= ''			//-- "Red.Bc.Calc."
	Local nCount_3		:= 0
	Local aComp			:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ BOX: COMPONENTES DA PRESTACAO                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lComp
		nLInic	:= 0505
		nLFim	:= 0563
	Else
		nLInic	:= 0445
		nLFim	:= 0503
	EndIf

	oDacte:Box(nLInic, 0000, nLFim, 0559)

	nLInic	+= 0008
	oDacte:Say(nLInic, 0210, "Componentes do Valor da Prestação de Serviço", oFont08N)

	nLInic	+= 0004

	oDacte:Line(nLInic, 0000, nLInic, 0559) // Linha: Componentes da Prestacao
	oDacte:Line(nLInic, 0070, nLFim, 0070) // Linha: Separador Vertical
	oDacte:Line(nLInic, 0140, nLFim, 0140) // Linha: Separador Vertical
	oDacte:Line(nLInic, 0210, nLFim, 0210) // Linha: Separador Vertical
	oDacte:Line(nLInic, 0280, nLFim, 0280) // Linha: Separador Vertical
	oDacte:Line(nLInic, 0350, nLFim, 0350) // Linha: Separador Vertical
	oDacte:Line(nLInic, 0420, nLFim, 0420) // Linha: Separador Vertical

	nLInic	+= 0006
	oDacte:Say(nLInic, 0003, "Nome",	oFont08N)
	oDacte:Say(nLInic, 0073, "Valor",	oFont08N)
	oDacte:Say(nLInic, 0143, "Nome",	oFont08N)
	oDacte:Say(nLInic, 0213, "Valor",	oFont08N)
	oDacte:Say(nLInic, 0283, "Nome",	oFont08N)
	oDacte:Say(nLInic, 0353, "Valor",	oFont08N)
	oDacte:Say(nLInic, 0423, "Valor Total do Serviço", oFont08N)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Componentes do Valor da Prestacao de Servico                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³DT8 - Componentes do Frete                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLInic		+= 0008
	nCInic		:= 0003
	lControl	:= .F.

	aComp := TMSGetComp( oNfe )

	For nCount_3 := 1 To Len( aComp )
		nCount += 2
		oDacte:Say(nLInic, nCInic, Substr(AllTrim(aComp[nCount_3][1]),1,14), oFont08)	//Descricao do Componente
		nCInic += 0070	//Proxima Coluna

		oDacte:Say(nLInic, nCInic, Transform(Val(AllTrim(aComp[nCount_3][2])),'@E 999,999.99'), oFont08)	//Valor do Componente
		nCInic += 0070	//Proxima Coluna


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ FORCAR A "QUEBRA" DA LINHA, SENDO 6 CAMPOS POR LINHA.                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( (mod(nCount,6)) == 0 )
			nCount_2 += 1
			Do Case
			Case ( nCount_2 == 1 )
				If Type("oNFE:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT")!="U"
					cLabel := PadL(Transform(Val(oNFE:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT),'@E 999,999.99'),20)
				Endif
			Case ( nCount_2 == 2 )
				cLabel := ""
			Case ( nCount_2 == 3 )
				oDacte :Line(nLInic - 8, 0420, nLInic - 8, 0559) // Linha: VALOR A RECEBER
				cLabel := "Valor a Receber"
			Case ( nCount_2 == 4 )
				If Type("oNFE:_CTE:_INFCTE:_VPREST:_VREC:TEXT")!="U"
					cLabel := PadL(Transform(Val(oNFE:_CTE:_INFCTE:_VPREST:_VREC:TEXT),'@E 999,999.99'),20)
				Endif
			EndCase

			oDacte:Say(nLInic , 0423, cLabel, oFont10N)
			nLInic   += 0008
			nCInic   := 0003
		EndIf
	Next nCount_3
	For nCount := (1 + nCount) To 24
		lControl := !lControl
		nCInic   += 0070
		cLabel   := ""

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ FORCAR A "QUEBRA" DA LINHA, SENDO 6 CAMPOS POR LINHA.                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( (mod(nCount,6)) == 0 )
			nCount_2 += 1
			Do Case
			Case ( nCount_2 == 1 )
				If Type("oNFE:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT")!="U"
					cLabel := PadL(Transform(Val(oNFE:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT),'@E 999,999.99'),20)
				Endif
			Case ( nCount_2 == 2 )
				cLabel := ""
			Case ( nCount_2 == 3 )
				oDacte :Line(nLInic - 8, 0420, nLInic - 8, 0559) // Linha: VALOR A RECEBER
				cLabel := "Valor a Receber"
			Case ( nCount_2 == 4 )
				If Type("oNFE:_CTE:_INFCTE:_VPREST:_VREC:TEXT")!="U"
					cLabel := PadL(Transform(Val(oNFE:_CTE:_INFCTE:_VPREST:_VREC:TEXT),'@E 999,999.99'),20)
				Endif
			EndCase

			oDacte:Say(nLInic , 0423, cLabel, oFont10N)
			nLInic   += 0008
			nCInic   := 0003
		EndIf
	Next nCount

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ BOX: INFORMACOES RELATIVAS AO IMPOSTO                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If !lComp
		nLInic	:= 0505
		nLFim	:= 0531
	Else
		nLInic	:= 0565
		nLFim	:= 0591
	EndIf

	oDacte:Box(nLInic , 0000, nLFim, 0559)

	nLInic += 0006
	oDacte:Say(nLInic , 0212, "Informações Relativas ao Imposto", oFont08N)

	nLInic += 0002
	oDacte:Line(nLInic, 0000, nLInic, 0559)	// Linha:
	oDacte:Line(nLInic, 0240, nLFim, 0240)	// Linha: Separador Situacao Trib	/ Base de Calculo
	oDacte:Line(nLInic, 0350, nLFim, 0350) 	// Linha: Separador Base de Calculo	/ Aliq.ICMS
	oDacte:Line(nLInic, 0400, nLFim, 0400) 	// Linha: Separador Aliq.ICMS    	/ Valor ICMS
	oDacte:Line(nLInic, 0470, nLFim, 0470) 	// Linha: Separador Valor ICMS    	/ %Red Bc.Calc

	nLInic += 0008
	oDacte:Say(nLInic , 0003, "Situação Tributária", oFont08N)   // Label: Situação Tributária
	oDacte:Say(nLInic , 0243, "Base de Cálculo"    , oFont08N)   // Label: Base de Cálculo
	oDacte:Say(nLInic , 0353, "Aliq.ICMS"          , oFont08N)   // Label: Aliq.ICMS
	oDacte:Say(nLInic , 0403, "Valor ICMS"         , oFont08N)   // Label: Valor ICMS
	oDacte:Say(nLInic , 0473, "%Red.Bc.Calc."      , oFont08N)   // Label: %Red.Bc.Calc.


	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³ Tag <ICMS00>                                                    ³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If !Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_CST:TEXT")=="U"

		cAliasD2  := DataSource( 'DESCRSUBSTTRIBUTARIA' )
		
		cSitTriba	:= Iif( Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_CST:TEXT")=="U"," ",;
		oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_CST:TEXT + " - " + SubStr(AllTrim((cAliasD2)->X5_DESCRI),1,40) )

		cBaseIcms	:= iif(Type("oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VBC:TEXT")  !="U",Val(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VBC:TEXT),"")
		cAliqIcms	:= iif(Type("oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_PICMS:TEXT")!="U",Val(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_PICMS:TEXT),"")
		cValIcms	:= iif(Type("oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VICMS:TEXT")!="U",Val(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VICMS:TEXT),"")
		
		(cAliasD2)->(DbCloseArea())
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³ Tag <ICMS45>                                                    ³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	ElseIf !Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS45:_CST:TEXT") == "U"

		cAliasD2  := DataSource( 'DESCRSUBSTTRIBUTARIA' )

		cSitTriba	:= Iif( Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS45:_CST:TEXT")=="U"," ",;
		oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS45:_CST:TEXT + " - " + SubStr(AllTrim((cAliasD2)->X5_DESCRI),1,40) )
		
		(cAliasD2)->(DbCloseArea()) 
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³ Tag <ICMS90>                                                    ³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	ElseIf !Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_CST:TEXT") == "U"

		cAliasD2  := DataSource( 'DESCRSUBSTTRIBUTARIA' )

		cSitTriba	:= Iif( Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_CST:TEXT")=="U"," ",;
		oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_CST:TEXT + " - " + SubStr(AllTrim((cAliasD2)->X5_DESCRI),1,40) )

		cBaseIcms	:= iif(Type("oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_VBC:TEXT")!="U",Val(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_VBC:TEXT),"")
	   	cAliqIcms	:= iif(Type("oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_PICMS:TEXT")!="U",Val(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_PICMS:TEXT),"")
		cValIcms	:= iif(Type("oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_VICMS:TEXT")!="U",Val(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_VICMS:TEXT),"")
		cRedBcCalc :=  Val(Iif( Type("oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_pRedBC:TEXT")=="U"," ",(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_pRedBC:TEXT) ))
		
		(cAliasD2)->(DbCloseArea())
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³ Tag <ICMS20>                                                    ³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	ElseIf !Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_CST:TEXT") == "U"

		cAliasD2  := DataSource( 'DESCRSUBSTTRIBUTARIA' )

		cSitTriba	:= Iif( Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_CST:TEXT")=="U"," ",;
		oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_CST:TEXT + " - " + SubStr(AllTrim((cAliasD2)->X5_DESCRI),1,40) )

		cBaseIcms	:= iif(Type("oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_VBC:TEXT")!="U",Val(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_VBC:TEXT),"")
		cAliqIcms	:= iif(Type("oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_PICMS:TEXT")!="U",Val(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_PICMS:TEXT),"")
		cValIcms	:= iif(Type("oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_VICMS:TEXT")!="U",Val(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_VICMS:TEXT),"")
		cRedBcCalc  := iif(Type("oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_pRedBC:TEXT")!="U",Val(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_pRedBC:TEXT),"")
		
		(cAliasD2)->(DbCloseArea())
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³ Tag <ICMS60>                                                    ³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	ElseIf !Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_CST:TEXT") == "U"

		cAliasD2  := DataSource( 'DESCRSUBSTTRIBUTARIA' )

		cSitTriba	:= Iif( Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_CST:TEXT")=="U"," ",;
		oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_CST:TEXT + " - " + SubStr(AllTrim((cAliasD2)->X5_DESCRI),1,40) )

		cBaseIcms	:= iif(Type("oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_VBCSTRET:TEXT")!="U",Val(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_VBCSTRET:TEXT),"")
		cCredPres	:= iif(Type("oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_vCred:TEXT")!="U",Val(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_vCred:TEXT),"")
		
		(cAliasD2)->(DbCloseArea())
	ElseIf !Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMSOutraUF:_CST:TEXT") == "U"

		cAliasD2  := DataSource( 'DESCRSUBSTTRIBUTARIA' )

		cSitTriba	:= Iif( Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMSOutraUF:_CST:TEXT")=="U"," ",;
		oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMSOutraUF:_CST:TEXT + " - " + SubStr(AllTrim((cAliasD2)->X5_DESCRI),1,40) )

		cBaseIcms	:= iif(Type("oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMSOutraUF:_vBCOutraUF:TEXT")  !="U",Val(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMSOutraUF:_vBCOutraUF:TEXT),"")
		cAliqIcms	:= iif(Type("oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMSOutraUF:_pICMSOutraUF:TEXT")!="U",Val(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMSOutraUF:_pICMSOutraUF:TEXT),"")
		cValIcms	:= iif(Type("oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMSOutraUF:_vICMSOutraUF:TEXT")!="U",Val(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMSOutraUF:_vICMSOutraUF:TEXT),"")
		cRedBcCalc :=  Val(Iif( Type("oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMSOutraUF:_pRedBCOutraUF:TEXT")=="U"," ",(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMSOutraUF:_pRedBCOutraUF:TEXT) ))
		
		(cAliasD2)->(DbCloseArea())
	EndIf

nLInic += 0008
oDacte:Say(nLInic , 0003, cSitTriba,								oFont08)
oDacte:Say(nLInic , 0243, Transform(cBaseIcms , '@E 999,999.99'),	oFont08)
oDacte:Say(nLInic , 0353, Transform(cAliqIcms , '@E 999,999.99'),	oFont08)
oDacte:Say(nLInic , 0403, Transform(cValIcms  , '@E 999,999.99'),	oFont08)
oDacte:Say(nLInic , 0473, Transform(cRedBcCalc, '@E 999,999.99'),	oFont08)

lComp := .F. //CTE Complementar

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TMSR27Cmp³ Autor ³Ovio Consultoria       ³ Data ³01/10/20  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao responsavel por montar o BOX relativo as informacoes ³±±
±±³          ³dos componentes e valores complementados                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   |                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TMSR27Cmp()

Local nCount    := 0
Local nCount_2  := 0
Local oFont08   := TFont():New("Times New Roman",08,08,,.F.,,,,.T.,.F.)
Local oFont08N  := TFont():New("Times New Roman",08,08,,.T.,,,,.T.,.F.)
Local lControl  := .F.
Local cAliasChv := ''

lComp := .T.	//CTE Complementar

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ BOX: COMPONENTES DO VALOR DA PRESTACAO DO SERVICO                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLInic  := 0397
nLFim   := 0503
oDacte:Box(nLInic , 0000, nLFim, 0559)

nLInic += 0006
oDacte:Say(nLInic , 0210, "Componentes do Valor da Prestação do Serviço", oFont08N)

nLInic += 0002
oDacte:Line(nLInic, 0000, nLInic, 0559)		// Linha: DOCUMENTOS ORIGINARIOS       
oDacte:Line(nLInic, 0279, nLFim , 0279)	// Linha: Separador DOCUMENTOS ORIGINARIOS

nLInic += 0007
oDacte:Say(nLInic , 0003, "Chave do CT-e Complementado", oFont08N)
oDacte:Say(nLInic , 0205, "Valor Complementado", oFont08N)
oDacte:Say(nLInic , 0281, "Chave do CT-e Complementado", oFont08N)
oDacte:Say(nLInic , 0483, "Valor Complementado", oFont08N)

nLInic   += 0008
nCount   := 0
nCount_2 := 0
lControl := .F.

//-- Query para pesquisar a chave do CTE original
cAliasChv :=  GetNextAlias()
cQuery := ''
cQuery += " SELECT DT6.DT6_CHVCTE " +CRLF
cQuery += "   FROM " + RetSqlName('DT6') + " DT6 " +CRLF
cQuery += "  WHERE DT6.DT6_FILIAL = '" + xFilial('DT6') + "'" +CRLF
cQuery += "    AND DT6.DT6_FILDOC = '" + (cAliasCT)->DT6_FILDCO + "'" +CRLF
cQuery += "    AND DT6.DT6_DOC    = '" + (cAliasCT)->DT6_DOCDCO + "'" +CRLF
cQuery += "    AND DT6.DT6_SERIE  = '" + (cAliasCT)->DT6_SERDCO + "'" +CRLF
cQuery += "    AND DT6.D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasChv, .F., .T.)

nCount   := 0
	While !(cAliasChv)->(Eof())

	nCount   += 1
	lControl := !lControl

		If nCount < 9

			If (lControl == .T.)
			oDacte:Say(nLInic, 0003, Transform(AllTrim((cAliasChv)->DT6_CHVCTE),"@!")	, oFont08)
			oDacte:Say(nLInic, 0205, PadL(Transform((cAliasCT)->DT6_VALFAT,'@E 9,999,999.9999'),20), oFont08)
			Else
			oDacte:Say(nLInic, 0281, Transform(AllTrim((cAliasChv)->DT6_CHVCTE),"@!")	, oFont08)
			EndIf

		EndIf

	(cAliasChv)->(DbSkip())

	EndDo

(cAliasChv)->(dbCloseArea())

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AjustaSX1     ³ Autor ³Ovio Consultoria      ³ Data ³01/10/20  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Ajusta o X1_GSC                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AjustaSX1()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function AjustaSX1()
Local aArea    := GetArea()
Local cTamLot  := TamSX3("DTP_LOTNFC")[1]
Local cTamDoc  := TamSX3("DT6_DOC")[1]
Local cTamSer  := TamSX3("DT6_SERIE")[1]
Local cTamTip  := TamSX3("DT6_DOCTMS")[1]
Local aHelpPor := {}
Local aHelpEng := {}
Local aHelpEsp := {}

aHelpPor := {"Informe o lote inicial."}
aHelpEng := {"Introduzca el lote inicial."}
aHelpEsp := {"Enter the initial batch."}
PutSx1(	"RTMSR25", "01", "Lote De", "De Lote?", "From Lot?", ;
			"MV_CH1", "C",cTamLot, 0, 0, "G", "", "DTP", "", "", ;
			"MV_PAR01", "", "", "", "", "", "", "", "", ;
			"", "", "", "N", "", "", "", "", ;
			aHelpPor, aHelpEng, aHelpEsp )

aHelpPor := {"Informe o lote final."}
aHelpEng := {"Introduzca la mezcla final."}
aHelpEsp := {"Enter the final blend."}
PutSx1(	"RTMSR25", "02", "Lote Ate", "A Lote?", "To Lot?", ;
			"MV_CH2", "C", cTamLot, 0, 0, "G", "", "DTP", "", "", ;
			"MV_PAR02", "", "", "", "", "", "", "", "", ;
			"", "", "", "N", "", "", "", "", ;
			aHelpPor, aHelpEng, aHelpEsp )


//-- Numero do Documento.
aHelpPor := {"Informe o documento inicial."}
aHelpEng := {"Introduzca el documento de partida."}
aHelpEsp := {"Enter the starting document."}
PutSx1(	"RTMSR25", "03", "Documento De", "De Documento", "From Document", ;
			"MV_CH3", "C", cTamDoc, 0, 0, "G", "", "DT6", "", "", ;
			"MV_PAR03", "", "", "", "", "", "", "", "", ;
			"", "", "", "N", "", "", "", "", ;
			aHelpPor, aHelpEng, aHelpEsp )
			
aHelpPor := {"Informe o documento final."}
aHelpEng := {"Introduzca el documento final."}
aHelpEsp := {"Enter the final document."}
PutSx1(	"RTMSR25", "04", "Documento Ate", "A Documento", "To Document", ;
			"MV_CH4", "C", cTamDoc, 0, 0, "G", "", "DT6", "", "", ;
			"MV_PAR04", "", "", "", "", "", "", "", "", ;
			"", "", "", "N", "", "", "", "", ;
			aHelpPor, aHelpEng, aHelpEsp )


//-- Serie do Documento.
aHelpPor := {"Informe  serie do documento inicial."}
aHelpEng := {"Informe de la serie del documento original."}
aHelpEsp := {"Report series of the original document."}
PutSx1(	"RTMSR25", "05", "Serie De", "De Serie", "From Series", ;
			"MV_CH5", "C", cTamSer, 0, 0, "G", "", "", "", "", ;
			"MV_PAR05", "", "", "", "", "", "", "", "", ;
			"", "", "", "N", "", "", "", "", ;
			aHelpPor, aHelpEng, aHelpEsp )

aHelpPor := {"Informe  serie do documento final."}
aHelpEng := {"La serie de Informes del documento final."}
aHelpEsp := {"Report series of the final document."}
PutSx1(	"RTMSR25", "06", "Serie Ate", "A Serie", "To Series", ;
			"MV_CH6", "C", cTamSer, 0, 0, "G", "", "", "", "", ;
			"MV_PAR06", "", "", "", "", "", "", "", "", ;
			"", "", "", "N", "", "", "", "", ;
			aHelpPor, aHelpEng, aHelpEsp )


//-- Tipo do Documento.
aHelpPor := {"Informe  o tipo do documento."}
aHelpEng := {"Introduzca el tipo de documento."}
aHelpEsp := {"Enter the type of document."}
PutSx1(	"RTMSR25", "07", "Tipo do Documento", "Tipo do Documento", "Document Type", ;
			"MV_CH7", "C", cTamTip, 0, 0, "G", "", "DLC", "", "", ;
			"MV_PAR07", "", "", "", "", "", "", "", "", ;
			"", "", "", "N", "", "", "", "", ;
			aHelpPor, aHelpEng, aHelpEsp )

// Busca XML
SX1->(DbSetOrder(1))
	If SX1->(MsSeek(Padr("RTMSR25",Len(SX1->X1_GRUPO))+"08"))
	RecLock('SX1',.F.)
	dbDelete()
	MsUnLock()
	EndIf

RestArea(aArea)
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RTMSR27   ³ Autor ³Ovio Consultoria    ³ Data ³01/10/20     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna um Array com a estrutura do campo complemento rel. º±±
±±º          ³ ao objeto passado por parametro                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMSGetComp( oObject )
	Local i			:= 0		// Auxiliar no Incremento da Estrutura de Laco
	Local aAuxClone	:= { }		// Copia da propriedade Comp do Objeto passado por parametro
	Local aAuxComp	:= { }		// Auxiliar no processamento de aAuxClone
	Local aResult	:= { }		// Retorno da Funcao

	If Valtype(XmlChildEx(oObject:_CTE:_INFCTE,"_INFCTECOMP")) <> "U" .And. Type("oObject:_CTE:_INFCTE:_INFCTECOMP:_VPRESCOMP:_COMPCOMP") <> "U"
		If Valtype( oObject:_CTE:_INFCTE:_INFCTECOMP:_VPRESCOMP:_COMPCOMP ) == "A"
			aAuxClone := ACLONE( oObject:_CTE:_INFCTE:_INFCTECOMP:_VPRESCOMP:_COMPCOMP)
			For i := 1 To Len( aAuxClone )
				AADD( aResult, {AllTrim(aAuxClone[ i ]:_XNOME:TEXT), AllTrim(aAuxClone[ i ]:_VCOMP:TEXT)} )
			Next i
		ElseIf Valtype( oObject:_CTE:_INFCTE:_INFCTECOMP:_VPRESCOMP ) == "O"
			AADD( aAuxComp, AllTrim(oObject:_CTE:_INFCTE:_INFCTECOMP:_VPRESCOMP:_COMPCOMP:_XNOME:TEXT) )
			AADD( aAuxComp, AllTrim(oObject:_CTE:_INFCTE:_INFCTECOMP:_VPRESCOMP:_COMPCOMP:_VCOMP:TEXT) )
			AADD( aResult, aAuxComp )
			aAuxComp := {}
		EndIf
	Else

		If	ValType(oObject:_CTE:_INFCTE:_VPREST:_COMP) == "A"
			aAuxClone := ACLONE( oObject:_CTE:_INFCTE:_VPREST:_COMP )
			For i := 1 To Len( aAuxClone )
				AADD( aResult, {AllTrim(aAuxClone[ i ]:_XNOME:TEXT), AllTrim(aAuxClone[ i ]:_VCOMP:TEXT)} )
			Next i
		ElseIf	ValType(oObject:_CTE:_INFCTE:_VPREST:_COMP) == "O"
			AADD( aAuxComp, AllTrim(oObject:_CTE:_INFCTE:_VPREST:_COMP:_XNOME:TEXT) )
			AADD( aAuxComp, AllTrim(oObject:_CTE:_INFCTE:_VPREST:_COMP:_VCOMP:TEXT) )
			AADD( aResult, aAuxComp )
			aAuxComp := {}
		EndIf
	EndIf

Return ( aResult )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RTMSR27   ³ Autor ³Ovio Consultoria    ³ Data ³01/10/20     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DataSource( cSource )
	Local cNewArea	:= GetNextAlias()
	Local cQuery	:= ""

	cQuery := GetSQL( cSource )
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cNewArea, .F., .T.)

Return ( cNewArea )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RTMSR27   ³ Autor ³Ovio Consultoria    ³ Data ³01/10/20     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³  Cria DACTE sem utilizar o XML, utilizando tabela.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetSQL( cSource )
	Local cQuery	:= ""
	Local cSitTriba	:= ""
// Verifica se existe filtro por lote especifico
	Local lFiltLote := Empty(MV_PAR01) .Or. MV_PAR02 = 'ZZZZZZ'

	If	cSource == 'SDS'
		cQuery += " SELECT " + CRLF
		cQuery += "    CTRC.DS_FILIAL,                " +CRLF
		cQuery += "    CTRC.DS_SERIE,                 " +CRLF
		cQuery += "    CTRC.DS_DOC,                   " +CRLF
		cQuery += "    CTRC.DS_CHAVENF,               " +CRLF
		cQuery += "    CTRC.DS_FORNEC,                " +CRLF
		cQuery += "    CTRC.DS_LOJA,                  " +CRLF
		cQuery += "    CTRC.DS_CNPJ,                  " +CRLF
		cQuery += "    CTRC.DS_ARQUIVO,               " +CRLF
		cQuery += "    CTRC.DS_ESPECI                 " +CRLF
		cQuery += " FROM " + RetSqlName('SDS') + " CTRC " + CRLF

		cQuery += "  WHERE CTRC.DS_FILIAL  = '" + SDS->DS_FILIAL + "'" + CRLF
		cQuery += "    AND CTRC.DS_DOC    >= '" + MV_PAR03 + "'" + CRLF
		cQuery += "    AND CTRC.DS_DOC    <= '" + MV_PAR04 + "'" + CRLF
		cQuery += "    AND CTRC.DS_SERIE  >= '" + MV_PAR05 + "'" + CRLF
		cQuery += "    AND CTRC.DS_SERIE  <= '" + MV_PAR06 + "'" + CRLF
		cQuery += "    AND CTRC.D_E_L_E_T_  = ' ' " + CRLF
		cQuery += "  ORDER BY CTRC.DS_FILIAL, " + CRLF
		cQuery += "           CTRC.DS_DOC,    " + CRLF
		cQuery += "           CTRC.DS_SERIE   "

	ElseIf cSource == 'SDT'

		cQuery += " SELECT Count(NF.DT_DOC) nTotal "
		cQuery += "   FROM " + RetSqlName('SDT') + " NF "
		cQuery += "  WHERE NF.DT_FILIAL = '" + xFilial("SDT") + "'"
		cQuery += "    AND NF.DT_DOC    = '" + AllTrim((cAliasCT)->DS_DOC)    + "'"
		cQuery += "    AND NF.DT_SERIE  = '" + AllTrim((cAliasCT)->DS_SERIE)  + "'"
		cQuery += "    AND NF.D_E_L_E_T_ =' '"

	ElseIf cSource == 'DESCRSUBSTTRIBUTARIA'

		cQuery := " SELECT SX5.X5_DESCRI"
		cQuery += " FROM " + RetSqlName("SX5") + " SX5 "
		cQuery += " WHERE SX5.X5_FILIAL ='"  + xFilial("SX5") + "'"
		cQuery += "   AND SX5.X5_TABELA ='S2'"

		If !Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_CST:TEXT")=="U"
			cSitTriba := Iif( Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_CST:TEXT")=="U"," ",;
				oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_CST:TEXT)
		ElseIf !Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS45:_CST:TEXT")=="U"
			cSitTriba := Iif( Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS45:_CST:TEXT")=="U"," ",;
				oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS45:_CST:TEXT)
		ElseIf !Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_CST:TEXT")=="U"
			cSitTriba := Iif( Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_CST:TEXT")=="U"," ",;
				oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_CST:TEXT)
		ElseIf !Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_CST:TEXT")=="U"
			cSitTriba := Iif( Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_CST:TEXT")=="U"," ",;
				oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_CST:TEXT)
		ElseIf !Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_CST:TEXT")=="U"
			cSitTriba := Iif( Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_CST:TEXT")=="U"," ",;
				oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_CST:TEXT)
		ElseIf !Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMSOutraUF:_CST:TEXT")=="U"
			cSitTriba := Iif( Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMSOutraUF:_CST:TEXT")=="U"," ",;
				oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMSOutraUF:_CST:TEXT)
		EndIf

		cQuery += " AND SX5.X5_CHAVE  ='" +cSitTriba+ "'"
		cQuery += " AND SX5.D_E_L_E_T_<>'*'"

	ElseIf cSource == "PRODUTOS_PERIGOSOS"

		cQuery := " SELECT DTC.DTC_PESO, DY3.DY3_ONU, DY3.DY3_DESCRI, DY3.DY3_GRPEMB, DY3.DY3_CLASSE, DY3.DY3_NRISCO "
		cQuery += " FROM " + RetSqlName("DTC") + " DTC , " + RetSqlName("SB5") + " SB5 , " + RetSqlName("DY3") + " DY3 "
		cQuery += " WHERE DTC.DTC_FILIAL   = '"  + xFilial("DT6") + "' "
		cQuery += " AND DTC.DTC_FILDOC = '" + (cAliasCT)->DT6_FILDOC + "'"
		cQuery += " AND DTC.DTC_DOC = '" + (cAliasCT)->DT6_DOC + "'"
		cQuery += " AND DTC.DTC_SERIE = '" + (cAliasCT)->DT6_SERIE + "'"
		cQuery += " AND SB5.B5_CARPER = '1' " //-- Carga Perigosa
		cQuery += " AND DTC.DTC_CODPRO = SB5.B5_COD"
		cQuery += " AND DY3.DY3_ONU = SB5.B5_ONU "
		cQuery += " AND DY3.DY3_ITEM = SB5.B5_ITEM "
		cQuery += " AND DTC.D_E_L_E_T_ = ' '"
		cQuery += " AND SB5.D_E_L_E_T_ = ' '"
		cQuery += " AND DY3.D_E_L_E_T_ = ' '"

	EndIf

	cQuery := ChangeQuery( cQuery )

Return ( cQuery )
/*/{Protheus.doc}''
''
@author Sergio Celestino
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/
static function UsaColaboracao(cModelo)
	Local lUsa := .F.

	If FindFunction("ColUsaColab")
		lUsa := ColUsaColab(cModelo)
	endif
return (lUsa)

/*/{Protheus.doc}'xmlClean'
''
@author Sergio Celestino
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/
static function XmlClean( cXml )

	Local cRetorno	:= ""

	DEFAULT cXml		:= ""

	If ( !Empty(cXml) )

		cRetorno := Alltrim(cXml)
	/*
	< - &lt; 
	> - &gt; 
	& - &amp; 
	" - &quot; 
	' - &#39;
	*/
		If !( "&amp;" $ cRetorno .or. "&lt;" $ cRetorno .or. "&gt;" $ cRetorno .or. "&quot;" $ cRetorno .or. "&#39;" $ cRetorno )
		/*Retira caracteres especiais e faz a substituição*/
			cRetorno := StrTran(cRetorno,"&","&amp;amp;")
		EndIf

		cRetorno := StrTran(cRetorno,Chr(198),"&atilde;")//ã
		cRetorno := StrTran(cRetorno,Chr(199),"&Atilde;")//Ã
		cRetorno := StrTran(cRetorno,Chr(228),"&otilde;")//õ
		cRetorno := StrTran(cRetorno,Chr(229),"&Otilde;")//Õ
		cRetorno := StrTran(cRetorno,Chr(160),"&aacute;")//á
		cRetorno := StrTran(cRetorno,Chr(181),"&aacute;")//Á
		cRetorno := StrTran(cRetorno,Chr(130),"&eacute;")//é
		cRetorno := StrTran(cRetorno,Chr(130),"&Eacute;")//É
		cRetorno := StrTran(cRetorno,Chr(144),"&Eacute;")//É
		cRetorno := StrTran(cRetorno,Chr(135),"&ccedil;")//ç
		cRetorno := StrTran(cRetorno,Chr(128),"&Ccedil;")//Ç

	/*
	¿	&iquest;
	À	&Agrave;
	Á	&Aacute;
	Â	&Acirc;
	Ã	&Atilde;
	Ä	&Auml;
	Å	&Aring;
	Æ	&AElig;
	Ç	&Ccedil;
	È	&Egrave;
	É	&Eacute;
	Ê	&Ecirc;
	Ë	&Euml;
	Ì	&Igrave;
	Í	&Iacute;
	Î	&Icirc;
	Ï	&Iuml;
	Ğ	&ETH;
	Ñ	&Ntilde;
	Ò	&Ograve;
	Ó	&Oacute;
	Ô	&Ocirc;
	Õ	&Otilde;
	Ö	&Ouml;
	×	&times;
	Ø	&Oslash;
	Ù	&Ugrave;
	Ú	&Uacute;
	Û	&Ucirc;
	Ü	&Uuml;
	İ	&Yacute;
	Ş	&THORN;
	ß	&szlig;
	à	&agrave;
	á	&aacute;
	â	&acirc;
	ã	&atilde;
	ä	&auml;
	å	&aring;
	æ	&aelig;
	ç	&ccedil;
	è	&egrave;
	é	&eacute;
	ê	&ecirc;
	ë	&euml;
	ì	&igrave;
	í	&iacute;
	î	&icirc;
	ï	&iuml;
	ğ	&eth;
	ñ	&ntilde;
	ò	&ograve;
	ó	&oacute;
	ô	&ocirc;
	õ	&otilde;
	ö	&ouml;
	÷	&divide;
	ø	&oslash;
	ù	&ugrave;
	ú	&uacute;
	û	&ucirc;
	ü	&uuml;
*/	

	EndIf

Return cRetorno
