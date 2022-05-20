#Include "Protheus.ch"
#Include "FWPrintSetup.ch"
#Include "RptDef.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SAFRATTB ºAutor  ³ Afonso Brito         Data ³ 21/08/2019  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressao de boleto Banco Safra                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIN    - TEAM TEX BRASIL                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function SAFRATTB( lJob, nIndSE1, cChavSE1, cPath, cFile, cEmpAtu, cFilAtu ) 

Local cPerg 		:= ""  
Local lRet			:= .T.
Local cAliasQry		:= ""
local cEmpAtu		:= ""
local cFilAtu		:= ""  
Local nSaldo        := 0


Default lJob		:= .F.
Default nIndSE1		:= 1
Default cChavSE1	:= ""
Default cPath		:= ""
Default cFile		:= ""
Default cEmpAtu		:= ""
Default cFilAtu		:= ""  

Public xnValBol   
Public cnValBol
 
//lJob  := .T.   
lJob  := .F.  
cEmpAtu := "01"
cFilatu := "0101"

If lJob
	If !Empty( cEmpAtu )
		RpcSetType(3)
		RpcSetEnv( cEmpAtu, cFilAtu )
	EndIf
	If !Empty( cChavSE1 )
		SE1->( dbSetOrder( nIndSE1 ) )
		If !SE1->( dbSeek( cChavSE1 ) )
			lRet := .F.
			ConOut( "RFINR01 - Titulo não encontrado no JOB de geracao de boletos." )
		EndIf
	EndIf
	
	If lRet
		fImpBol( lJob, Nil, Nil, .F. )
	EndIf
	
	/*
	If !Empty( cEmpAtu )
		RpcClearEnv( )
	EndIf
	*/
Else
	cPerg := PadR( "RFINR01", Len( SX1->X1_GRUPO ), " " )
	PutSx1( cPerg,"01", "Prefixo De?"	, "Prefixo De?"		, "Prefixo De?"		, "mv_ch1", "C", TamSX3("E1_PREFIXO")[1]	, 00, 00, "G", "", "", "", "", "mv_par01" )
	PutSx1( cPerg,"02", "Prefixo Ate?"	, "Prefixo Ate?"	, "Prefixo Ate?"	, "mv_ch2", "C", TamSX3("E1_PREFIXO")[1]	, 00, 00, "G", "", "", "", "", "mv_par02" )
	PutSx1( cPerg,"03", "Titulo De?"	, "Titulo De?"		, "Titulo De?"		, "mv_ch3", "C", TamSX3("E1_NUM")[1]		, 00, 00, "G", "", "", "", "", "mv_par03" )
	PutSx1( cPerg,"04", "Titulo Ate?"	, "Titulo Ate?"		, "Titulo Ate?"		, "mv_ch4", "C", TamSX3("E1_NUM")[1]		, 00, 00, "G", "", "", "", "", "mv_par04" )
	PutSx1( cPerg,"05", "Parcela De?"	, "Parcela De?"		, "Parcela De?"		, "mv_ch5", "C", TamSX3("E1_PARCELA")[1]	, 00, 00, "G", "", "", "", "", "mv_par05" )
	PutSx1( cPerg,"06", "Parcela Ate?"	, "Parcela Ate?"	, "Parcela Ate?"	, "mv_ch6", "C", TamSX3("E1_PARCELA")[1]	, 00, 00, "G", "", "", "", "", "mv_par06" )
	PutSx1( cPerg,"07", "Cliente De?"	, "Cliente De?"		, "Cliente De?"		, "mv_ch7", "C", TamSX3("E1_CLIENTE")[1]	, 00, 00, "G", "", "", "", "", "mv_par07" )
	PutSx1( cPerg,"08", "Cliente Ate?"	, "Cliente Ate?"	, "Cliente Ate?"	, "mv_ch8", "C", TamSX3("E1_CLIENTE")[1]	, 00, 00, "G", "", "", "", "", "mv_par08" )
	PutSx1( cPerg,"09", "Loja De?"		, "Loja De?"		, "Loja De?"		, "mv_ch9", "C", TamSX3("E1_LOJA")[1]		, 00, 00, "G", "", "", "", "", "mv_par09" )
	PutSx1( cPerg,"10", "Loja Ate?"		, "Loja Ate?"		, "Loja Ate?"		, "mv_cha", "C", TamSX3("E1_LOJA")[1]		, 00, 00, "G", "", "", "", "", "mv_par10" )
	PutSx1( cPerg,"11", "Emissao De?"	, "Emissao De?"		, "Emissao De?"		, "mv_chb", "D", TamSX3("E1_EMISSAO")[1]	, 00, 00, "G", "", "", "", "", "mv_par11" )
	PutSx1( cPerg,"12", "Emissao Ate?"	, "Emissao Ate?"	, "Emissao Ate?"	, "mv_chc", "D", TamSX3("E1_EMISSAO")[1]	, 00, 00, "G", "", "", "", "", "mv_par12" )
	PutSx1( cPerg,"13", "Vencto De?"	, "Vencto De?"		, "Vencto De?"		, "mv_chd", "D", TamSX3("E1_VENCREA")[1]	, 00, 00, "G", "", "", "", "", "mv_par13" )
	PutSx1( cPerg,"14", "Vencto Ate?"	, "Vencto Ate?"		, "Vencto Ate?"		, "mv_che", "D", TamSX3("E1_VENCREA")[1]	, 00, 00, "G", "", "", "", "", "mv_par14" )
	PutSx1( cPerg,"15", "Bordero De?"	, "Bordero De?"		, "Bordero De?"		, "mv_chf", "C", TamSX3("E1_NUMBOR")[1]		, 00, 00, "G", "", "", "", "", "mv_par15" )
	PutSx1( cPerg,"16", "Bordero Ate?"	, "Bordero Ate?"	, "Bordero Ate?"	, "mv_chg", "C", TamSX3("E1_NUMBOR")[1]		, 00, 00, "G", "", "", "", "", "mv_par16" )
	PutSx1( cPerg,"17", "Visuali.PDF?"	, "Visuali.PDF?"	, "Visuali.PDF?"	, "mv_chh", "C", 1							, 00, 00, "C", "", "", "", "", "mv_par17","Nao","Nao","Nao","","Sim","Sim","Sim" ) 

	If Pergunte( cPerg, .T. )
		cAliasQry := GetNextAlias( )
		MsgRun("Aguarde... Selecionando registros... ",,{|| lRet := fGetRegs( @cAliasQry ) }) 
		If !lRet 
			Alert( "Não foram encontrados dados para exibir." )
		Else
			cPath := cGetFile( '*.pdf' , 'Diretorio destino', 1, , .T., nOR( GETF_LOCALHARD, GETF_RETDIRECTORY ), .F.  )
			If Empty( cPath )
				Alert( "Informe um diretorio valido." )
			Else
				Processa({|| fProcImp( cAliasQry, cPath, MV_PAR17 == 2 ) } , "Boletos Banco Safra", "Iniciando processamento..." , .T. )
			EndIf
		EndIf
		( cAliasQry )->( dbCloseArea( ) )
	EndIf
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fProcImp ºAutor  ³ Vinicius Moreira   º Data ³ 25/07/2017  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Processamento da regua de impressão, quando impressão      º±±
±±º          ³ manual.                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIN                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fProcImp( cAliasQry, cPath, lViewPDF )

Local nRegs := 0

( cAliasQry )->( dbEval( { || nRegs++ },, { || ( cAliasQry )->( !Eof( ) ) } ) )
( cAliasQry )->( dbGoTop( ) )
ProcRegua( nRegs )
While ( cAliasQry )->( !Eof( ) )
	SE1->( dbGoTo( ( cAliasQry )->SE1REC ) )
	IncProc( "Boleto: " + SE1->( AllTrim( E1_PREFIXO ) + "/" + AllTrim( E1_NUM ) + "-" + E1_PARCELA ) ) 
	fImpBol( .F., cPath, Nil, lViewPDF )
	( cAliasQry )->( dbSkip( ) )
EndDo

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fImpBol  ºAutor  ³ Vinícius Moreira   º Data ³ 25/07/2017  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressão de boleto.                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static cTmpPath := ""
Static Function fImpBol( lJob, cDirArq, cNomArq, lViewPDF )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaração de variáveis³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oPrint
Local n         := 	0
Local nLoop		:= 	0
Local aBitmap 	:=	{}

Local aDadosEmp := {SM0->M0_NOMECOM,;																//[1]Nome da Empresa
					SM0->M0_ENDCOB,; 																//[2]Endereço
					AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,;	//[3]Complemento
					"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3),; 				//[4]CEP
					"PABX/FAX: "+SM0->M0_TEL,; 														//[5]Telefones
					"C.N.P.J.: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+;			//[6]
					Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+;							//[6]
					Subs(SM0->M0_CGC,13,2),;														//[6]CGC
					"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+;				//[7]
					Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)}							//[7]I.E
Local aDadosTit
Local aDadosBanco
Local aDatSacado
Local cTpCli  

/*
oPrn:SayAlign( aMargem[2,1] + 0830 , aMargem[2,2] + 0200 , posicione("SC5",1,xFilial("SC5")+(cAlias)->E1_PEDIDO,"C5_MENNOTA") , oFont12A , 2000 , 0100 , , 0 , 0 )
oPrn:SayAlign( aMargem[2,1] + 0880 , aMargem[2,2] + 0200 , getNewPar("MV_XMENBL2","") , oFont12A , 2000 , 0100 , , 0 , 0 )
oPrn:SayAlign( aMargem[2,1] + 0930 , aMargem[2,2] + 0200 , getNewPar("MV_XMENBL3","") , oFont12A , 2000 , 0100 , , 0 , 0 )
oPrn:SayAlign( aMargem[2,1] + 0980 , aMargem[2,2] + 0200 , getNewPar("MV_XMENBL4","") , oFont12A , 2000 , 0100 , , 0 , 0 )  
*/  

Local aBolText  := {	posicione("SC5",1,xFilial("SC5")+SE1->E1_PEDIDO,"C5_MENNOTA"),;
						getNewPar("MV_XMENBL2",""),;
						getNewPar("MV_XMENBL3",""),;
						getNewPar("MV_XMENBL4",""),;
						""}

/*    
Local aBolText  := {	GetMv("ES_ITAMSG1",,"Acertar parâmetro ES_ITAMSG1"),;
						GetMv("ES_ITAMSG2",,"Acertar parâmetro ES_ITAMSG2"),;
						GetMv("ES_ITAMSG3",,"Acertar parâmetro ES_ITAMSG3"),;
						GetMv("ES_ITAMSG4",,"Acertar parâmetro ES_ITAMSG4"),;
						GetMv("ES_ITAMSG5",,"Acertar parâmetro ES_ITAMSG5")}
*/
Local aBMP      := aBitMap
Local i         := 1
Local CB_RN_NN  := {}
Local nRec      := 0
Local _nVlrAbat := 0  
Local _nMulta   := 0
Local lSomAbati := .F.
//Local cCarteira := "01"     
Local cCarteira := ""    
Local nSaldo    := 0

Private cLogo	:= """

Private _dDtVenc 	:= SE1->E1_VENCREA // Alteração Eduardo de E1_VENCTO para E1_VENCREA    

//Default cNomArq		:= "BOL_" + AllTrim( SE1->E1_NUM ) + "_" + If( !Empty( SE1->E1_PARCELA ), AllTrim( SE1->E1_PARCELA ), StrZero( 1, Len( SE1->E1_PARCELA ) ) ) + ".PDF"       
Default cNomArq := UPPER(alltrim(SE1->E1_CLIENTE)+"_pc_" + alltrim(SE1->E1_NUMBCO)  + ".pdf")	
//Default cDirArq		:= SuperGetMv("ES_BOLDIR",,"\boletos\itau\") 
Default cDirArq		:=  GetSrvProfString("Startpath","")+"boletos\TeanTex\" 
Default lViewPDF	:= .T.

dbSelectArea("SA6")
dbSetOrder(1)
dbSeek(xFilial("SA6")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA,.T.)

// Posiciona na Arq de Parametros CNAB
dbSelectArea("SEE")
dbSetOrder(1)
dbSeek(xFilial("SEE")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA,.T.)

// Posiciona o SA1 (Cliente)
dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.)

// Seleciona o SE1 (Contas a Receber)
dbSelectArea("SE1")
cTpCli	:= SA1->A1_PESSOA
aDadosBanco := {"422-7",;											     //SA6->A6_COD [1]Numero do Banco
SA6->A6_NOME,;															// [2]Nome do Banco
SUBSTR(SA6->A6_AGENCIA,1,4),;										    // [3]Agencia
AllTrim( SA6->A6_NUMCON ),;												// [4]Conta Corrente
AllTrim( SA6->A6_DVCTA ),;												// [5]Digito da conta corrente
""}													    	     		// [6]Codigo da Carteira

If EMPTY(SA1->A1_ENDCOB)
	aDatSacado := {AllTrim(SA1->A1_NOME),;								// [1]Razao Social
	AllTrim(SA1->A1_COD),;//AllTrim(SA1->A1_COD)+"-"+SA1->A1_LOJA,;								// [2]Codigo
	AllTrim(SA1->A1_END)+"-"+AllTrim(SA1->A1_BAIRRO),;					// [3]Endereco
	AllTrim(SA1->A1_MUN),;												// [4]Cidade
	SA1->A1_EST,;														// [5]Estado
	SA1->A1_CEP,;														// [6]CEP
	SA1->A1_CGC}														// [7]CGC
Else
	aDatSacado := {AllTrim(SA1->A1_NOME),;								// [1]Razao Social
	AllTrim(SA1->A1_COD),;//AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA,;							// [2]Codigo
	AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC),;				// [3]Endereco
	AllTrim(SA1->A1_MUNC),;												// [4]Cidade
	SA1->A1_ESTC,;														// [5]Estado
	SA1->A1_CEPC,;														// [6]CEP
	SA1->A1_CGC}														// [7]CGC
EndIf

If lSomAbati
	_nVlrAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
EndIf  

 
//If SE1->E1_VENCREA < date()	// Alteração Eduardo de E1_VENCTO para E1_VENCREA
//		_dDtVenc := date()
//EndIf 
                          
//_nMulta		:= U_CALCMORA(SE1->E1_VALOR,CalcTxJr(_dDtVenc),"BOL")

CB_RN_NN  := Ret_cBarra(Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],aDadosBanco[6],AllTrim(E1_NUM),(SE1->E1_VALOR-_nVlrAbat+_nMulta-SE1->E1_DECRESC),_dDtVenc)

aDadosTit := {AllTrim(SE1->E1_NUM)+AllTrim(SE1->E1_PARCELA),;	// [1] Numero do Titulo
SE1->E1_EMISSAO,;												// [2] Data da Emissao do Titulo
Date(),;														// [3] Data da Emissao do Boleto
_dDtVenc,;							        					// [4] Data do Vencimento
(SE1->E1_SALDO - _nVlrAbat+_nMulta-SE1->E1_DECRESC),;			// [5] Valor do Titulo
SE1->E1_NUMBCO,;												// [6] Nosso Numero (Ver Formula para Calculo)
SE1->E1_PREFIXO,;												// [7] Prefixo da NF
"DM",;															// [8] Tipo do Titulo      
"01"}															// [9] Cateira     

  
nSaldo := SE1->E1_SALDO  
cnValBol := (transform(nSaldo,"@E 999999999.99"))    
xnValBol := (transform(nSaldo,"@E 999999999.99"))    //afonso valor original do boleto + Desconto especial (03/02/17)
                          
CONOUT("****** cDirArq + cNomArq - " + cDirArq + cNomArq )
If File( cDirArq + cNomArq )   
  If FErase( cDirArq + cNomArq ) == -1
    CONOUT('Falha na deleção do Arquivo')
  Else
    CONOUT('Arquivo deletado com sucesso.')
  Endif
EndIf     

If Empty( cTmpPath ) .And. !lJob
	cTmpPath := GetTempPath( .T. ) + "totvsprinter\"
EndIf  

CONOUT("****** cTmpPath + cNomArq - " + cTmpPath + cNomArq )
If File( cTmpPath + cNomArq )   
  If FErase( cTmpPath + cNomArq ) == -1
    CONOUT('Falha na deleção do Arquivo')
  Else
    CONOUT('Arquivo deletado com sucesso.')
  Endif
EndIf

 //							< cFilePrintert >	, [ nDevice]	, [ lAdjustToLegacy]	, [ cPathInServer]	, [ lDisabeSetup ]	, [ lTReport]	, [ @oPrintSetup]	, [ cPrinter]	, [ lServer]	, [ lPDFAsPNG]	, [ lRaw]	, [ lViewPDF], [ nQtdCopy] 
oPrint := FWMSPrinter():New( cNomArq			, IMP_PDF		, .T.					, 					, .T.				,				,					,				,lJob			,				,			, lViewPDF )
oPrint:SetResolution(72) //Tamanho estipulado para Danfe
oPrint:SetPortrait()
oPrint:SetPaperSize( DMPAPER_A4 )
oPrint:lViewPDF	:= lViewPDF
oPrint:cPathPDF	:= cDirArq
If lJob
	oPrint:lServer 	:= .T.
	oPrint:nDevice 	:= IMP_PDF
	oPrint:lPDFAsPNG	:= .T.
EndIf

Impress(oPrint,aBMP,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)		
n := n + 1

  oPrint:StartPage()
  oPrint:Print()   
         
  oPrint:EndPage()
  FreeObj(oPrint)
  Ms_Flush()
             

  oPrint      := Nil
  aDadEmp	  := {}
  aDadosTit   := {}
  aDadosBanco := {}
  aDatSacado  := {}
  aBolText    := {}


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Guarda a informação para o envio do e-mail³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
If MV_PAR17 == 1
	AvCpyFile(oPrint:cPathPDF+cNomArq,cDirArq+cNomArq,.T.)
	fErase(oPrint:cPathPDF+cNomArq)
	aAdd(aEnvMail,{SA1->A1_EMAIL,;
					Capital(SA1->A1_NREDUZ),;
					cDirArq+;
					cNomArq})
EndIf
*/

if lJob
    Return //lRet 
   else
    Return
endif   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ IMPRESS()   ³ Autor ³Vinícius Gregório ³ Data ³ 28/07/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Impressao de Boleto Bancario do Banco Itau com Codigo de   ³±±
±±³           ³ Barras, Linha Digitavel e Nosso Numero.                    ³±±
±±³           ³ Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ AcademiaERP                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION Impress(oPrint,aBitmap,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaração de variaveis³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oFont8
Local oFont10
Local oFont16
Local oFont16n 
Local oFont14
Local oFont14n
Local oFont24
Local i        := 0
Local _nLin    := -300
Local aCoords1 := {0150,1900,0550,2300}
Local aCoords2 := {0450,1050,0550,1900}
Local aCoords3 := {_nLin+0710,1900,_nLin+0810,2300}
Local aCoords4 := {_nLin+0980,1900,_nLin+1050,2300}
Local aCoords5 := {_nLin+1330,1900,_nLin+1400,2300}        
Local aCoords6 := {_nLin+2100,1910,_nLin+2200,2300}
Local aCoords7 := {_nLin+2370,1910,_nLin+2440,2300}
Local aCoords8 := {_nLin+2720,1900,_nLin+2790,2300}   
Local nJurdia := 0

Local oBrush

// Parâmetros de TFont.New()
// 1.Nome da Fonte (Windows)
// 3.Tamanho em Pixels
// 5.Bold (T/F)
oFont8  := TFont():New("Arial",9,08,.T.,.F.,5,.T.,5,.T.,.F.)
oFont10 := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.) 
oFont12 := TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16 := TFont():New("Arial",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n:= TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14 := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.) 
oFont14n:= TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
oFont24 := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
oBrush  := TBrush():New("",4)
oPrint:StartPage()	// Inicia uma nova Pagina
//----------inicio da parte do meio
FOR i := 100 TO 2300 STEP 50
	oPrint:Line(_nLin+0450,i,_nLin+0450,i+30)
NEXT i

oPrint:Line(_nLin+0560,0100,_nLin+0560,2300)
//oPrint:Line(_nLin+0560,0560,_nLin+0490,0560)
//oPrint:Line(_nLin+0560,0800,_nLin+0490,0800)
 
//oPrint:SayBitmap(_nLin+0475,100,cLogo,340,070 )

//oPrint:Say (_nLin+0532,0567,aDadosBanco[1],oFont24)	// [1]Numero do Banco 
oPrint:Say (_nLin+0532,0100,"Banco Safra S.A.",oFont16)	// [1]Numero do Banco
oPrint:Say (_nLin+0534,2000,"Recibo do Pagador",oFont10)
oPrint:Say (_nLin+0587,0100,"Beneficiario",oFont8)  
oPrint:Say (_nLin+0620,0100,Alltrim(aDadosEmp[1])+" - "+aDadosEmp[6],oFont10) //Nome + CNPJ    
oPrint:Say (_nLin+0587,1565,"Nosso Numero",oFont8)  
oPrint:Say (_nLin+0620,1580,aDadosTit[6],oFont10)
oPrint:Say (_nLin+0587,1910,"Vencimento",oFont8)
oPrint:Say (_nLin+0620,2115,Substr(DTOS(aDadosTit[4]),7,2)+"/"+Substr(DTOS(aDadosTit[4]),5,2)+"/"+Substr(DTOS(aDadosTit[4]),1,4),oFont10)
//_nLin := _nLin - 30
oPrint:Line(_nLin+0660,0100,_nLin+0660,2300) 
//oPrint:Say (_nLin+0687,0100,"Cedente",oFont8)
//oPrint:Say (_nLin+0687,1910,"Agência/Código Cedente",oFont8)
//_nLin := _nLin - 28

oPrint:Say (_nLin+0690,0100,"Data do Docto.",oFont8) 
oPrint:Say (_nLin+0740,0100,Substr(DTOS(aDadosTit[2]),7,2)+"/"+Substr(DTOS(aDadosTit[2]),5,2)+"/"+Substr(DTOS(aDadosTit[2]),1,4),oFont10) // Emissao do Titulo 
oPrint:Say (_nLin+0690,0700,"Numero do Documento",oFont8) 
oPrint:Say (_nLin+0740,0800,aDadosTit[7]+aDadosTit[1],oFont10) //Numero do Documento
oPrint:Say (_nLin+0690,1200,"Carteira",oFont8)   
oPrint:Say (_nLin+0740,1300,aDadosTit[9],oFont10) //Carteira
oPrint:Say (_nLin+0690,1565,"Agência/Dados Beneficiário",oFont8)
oPrint:Say (_nLin+0740,1575,aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5],oFont10)   //agencia / conta  
oPrint:Say (_nLin+0690,1910,"Valor",oFont8)
oPrint:Say (_nLin+0740,2090,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)
oPrint:Line(_nLin+0760,0100,_nLin+0760,2300)
_nLin := _nLin + 15
oPrint:Say (_nLin+0770,0100,"Pagador",oFont8)
oPrint:Say (_nLin+0820,0100,"("+aDatSacado[2]+") " + Alltrim(aDatSacado[1])+" - "+IIf (!EMPTY(aDatSacado[7]),"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),"" ),oFont10)
oPrint:Line(_nLin+0850,0100,_nLin+0850,2300)

oPrint:Say (_nLin+0880,0100,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do Beneficiário)",oFont8)
    
oPrint:Line(_nLin+1100,0100,_nLin+1100,2300)    
       
       
_nLin := _nLin + 45

oPrint:Line(_nLin+0500,1555,_nLin+0600,1555)     ///traco vertical nosso numero   

oPrint:Line(_nLin+0600,1555,_nLin+0700,1555)     ///traco vertical agencia/dados beneficiario 

oPrint:Line(_nLin+0600,1150,_nLin+0700,1150)     ///traco vertical carteira

oPrint:Line(_nLin+0600,0650,_nLin+0700,0650)     ///traco vertical numero documento

oPrint:Line(_nLin+0500,1900,_nLin+700,1900) 
  

_nLin := _nlin - 400

//-----inicio da parte final
FOR i := 100 TO 2300 STEP 50
	oPrint:Line(_nLin+1640,i,_nLin+1640,i+30)
NEXT i                                                     

oPrint:Line(_nLin+1750,0100,_nLin+1750,2300)  //n
oPrint:Line(_nLin+1660,0560,_nLin+1750,0560) //n 
oPrint:Line(_nLin+1660,0800,_nLin+1750,0800) //n   
 
oPrint:SayBitmap(_nLin+1665,100,cLogo,0340,070 )

oPrint:Say (_nLin+1724,0100,"Banco Safra S.A.",oFont16)	
oPrint:Say (_nLin+1724,0567,aDadosBanco[1],oFont16)	// [1] Numero do Banco
oPrint:Say (_nLin+1724,0820,CB_RN_NN[2],oFont14)		// [2] Linha Digitavel do Codigo de Barras
oPrint:Line(_nLin+1850,0100,_nLin+1850,2300)         //n
oPrint:Line(_nLin+1950,0100,_nLin+1950,2300)         //n
oPrint:Line(_nLin+2020,0100,_nLin+2020,2300) //n
oPrint:Line(_nLin+2090,0100,_nLin+2090,2300)//n
oPrint:Line(_nLin+1950,0500,_nLin+2090,0500)//n
oPrint:Line(_nLin+2020,0750,_nLin+2090,0750)//n
oPrint:Line(_nLin+1950,1000,_nLin+2090,1000)//n
oPrint:Line(_nLin+1950,1350,_nLin+2020,1350)//n
oPrint:Line(_nLin+1950,1550,_nLin+2090,1550)//n 
oPrint:Say (_nLin+1780,0100,"Local de Pagamento",oFont8)
oPrint:Say (_nLin+1805,0370,"PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO",oFont10)
oPrint:Say (_nLin+1780,1910,"Vencimento",oFont8)  //n
oPrint:Say (_nLin+1830,2115,dToC(aDadosTit[4]),oFont10)
oPrint:Say (_nLin+1880,0100,"Beneficiário",oFont8)
oPrint:Say (_nLin+1930,0100,aDadosEmp[1]+"                  - "+aDadosEmp[6],oFont10) //Nome + CNPJ
oPrint:Say (_nLin+1880,1910,"Agência/Código Beneficiário",oFont8)
oPrint:Say (_nLin+1930,2070,aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5],oFont10)
oPrint:Say (_nLin+1970,0100,"Data do Documento",oFont8)
oPrint:Say (_nLin+2010,0100,dToC(aDadosTit[2]),oFont10)			// Emissao do Titulo (E1_EMISSAO)
oPrint:Say (_nLin+1970,0505,"Nro.do Documento",oFont8)
oPrint:Say (_nLin+2010,0605,aDadosTit[7]+aDadosTit[1],oFont10)	//Prefixo + Numero + Parcela
oPrint:Say (_nLin+1970,1005,"Espécie Docto.",oFont8)
oPrint:Say (_nLin+2010,1050,aDadosTit[8],oFont10)					//Tipo do Titulo
oPrint:Say (_nLin+1970,1355,"Aceite",oFont8)
oPrint:Say (_nLin+2010,1455,"N",oFont10)
oPrint:Say (_nLin+1970,1555,"Data Movto.",oFont8)
oPrint:Say (_nLin+2010,1655,dToC(aDadosTit[3]),oFont10) // Data impressao
oPrint:Say (_nLin+1970,1910,"Nosso Número",oFont8)
//oPrint:Say (_nLin+2010,2035,aDadosBanco[6]+"/"+aDadosTit[6],oFont10) 
oPrint:Say (_nLin+2010,2035,aDadosTit[6],oFont10)
oPrint:Say (_nLin+2040,0100,"Data Oper.",oFont8)   
oPrint:Say (_nLin+2080,0100,dToC(aDadosTit[3]),oFont10) // Data impressao
oPrint:Say (_nLin+2040,0505,"Carteira",oFont8)
oPrint:Say (_nLin+2080,0555,"01",oFont10)
oPrint:Say (_nLin+2040,0755,"Espécie",oFont8)
oPrint:Say (_nLin+2080,0805,"R$",oFont10)
oPrint:Say (_nLin+2040,1005,"Quantidade",oFont8)
oPrint:Say (_nLin+2040,1555,"Valor",oFont8)
oPrint:Say (_nLin+2040,1910,"Valor do Documento",oFont8)
oPrint:Say (_nLin+2080,2040,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)                                
oPrint:Say (_nLin+2120,0100,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do Beneficiário)",oFont8)
  
////instruções de Multa / Juros /Protesto
oPrint:Say (_nLin+2170,0100,"SUJEITO A PROTESTO 05 DIAS APÓS O VENCIMENTO",oFont10)
nJurdia := aDadosTit[5]*0.00033333  
oPrint:Say (_nLin+2210,0100,"COBRAR JUROS DE MORA DE R$ "+AllTrim(Transform(nJurdia,"@E 999,999,999.99"))+" AO DIA APÓS O VENCIMENTO",oFont10)  
oPrint:Say (_nLin+2250,0100,"COBRAR MULTA DE 2 % APÓS O VENCIMENTO",oFont10)  
///////////// 

oPrint:Say (_nLin+2170,0100,fGetText (aBolText[1]),oFont10)
oPrint:Say (_nLin+2210,0100,fGetText (aBolText[2]),oFont10)
oPrint:Say (_nLin+2250,0100,fGetText (aBolText[3]),oFont10)
oPrint:Say (_nLin+2290,0100,fGetText (aBolText[4]),oFont10)                   
oPrint:Say (_nLin+2330,0100,fGetText (aBolText[5]),oFont10)

oPrint:Say (_nLin+2117,1910,"(-)Desconto/Abatimento",oFont8)
oPrint:Say (_nLin+2187,1910,"(-)Outras Deduções",oFont8)
oPrint:Say (_nLin+2257,1910,"(+)Mora/Multa",oFont8)
oPrint:Say (_nLin+2327,1910,"(+)Outros Acréscimos",oFont8)
oPrint:Say (_nLin+2397,1910,"(=)Valor Cobrado",oFont8)
oPrint:Say (_nLin+2460,0100,"Pagador",oFont8)
//oPrint:Say (_nLin+2490,0200,aDatSacado[1]+" ("+aDatSacado[2]+")",oFont10)
oPrint:Say (_nLin+2490,0200,"("+aDatSacado[2]+") " + aDatSacado[1],oFont10)
oPrint:Say (_nLin+2520,0200,aDatSacado[3],oFont10)
oPrint:Say (_nLin+2550,0200,aDatSacado[6]+" - "+aDatSacado[4]+" - "+aDatSacado[5],oFont10)	// CEP+Cidade+Estado
oPrint:Say (_nLin+2580,0200,IIf(!EMPTY(aDatSacado[7]),"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),""),oFont10)

oPrint:Say (_nLin+2862,0100,"Sacador/Avalista",oFont8)
oPrint:Say (_nLin+2905,1910,"Autenticação Mecânica",oFont8)
oPrint:Say (_nLin+2950,1910,"FICHA DE COMPENSAÇÃO",oFont10)

oPrint:Line(_nLin+1750,1900,_nLin+2440,1900)        //n
oPrint:Line(_nLin+2160,1900,_nLin+2160,2300)           //n
oPrint:Line(_nLin+2230,1900,_nLin+2230,2300)              //n
oPrint:Line(_nLin+2300,1900,_nLin+2300,2300)                 //n
oPrint:Line(_nLin+2370,1900,_nLin+2370,2300)                    //n
oPrint:Line(_nLin+2440,0100,_nLin+2440,2300)                       //n
oPrint:Line(_nLin+2870,0100,_nLin+2870,2300)    
oPrint:Line(_nLin+2930,1900,_nLin+2930,2300)                         //n

//oPrint:FWMSBAR("CODE128" /*cTypeBar*/,54.5/*nRow*/,0002/*nCol*/, CB_RN_NN[1]/*cCode*/,oPrint/*oPrint*/,.T./*lCheck*/,/*Color*/,.T./*lHorz*/,0.02/*nWidth*/,0.8/*nHeigth*/,.F./*lBanner*/,"Arial"/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,2/*nPFWidth*/,2/*nPFHeigth*/,.F./*lCmtr2Pix*/)
oPrint:FWMSBAR("INT25" /*cTypeBar*/,53/*nRow*/,0002/*nCol*/, CB_RN_NN[1]/*cCode*/,oPrint/*oPrint*/,.F./*lCheck*/,/*Color*/,.T./*lHorz*/,0.020/*nWidth*/,0.75/*nHeigth*/,.F./*lBanner*/,"Arial"/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,0.5/*nPFWidth*/,0.5/*nPFHeigth*/,.T./*lCmtr2Pix*/)
oPrint:EndPage()	// Finaliza a Pagina

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ MODULO10()  ³ Autor ³Vinícius Gregório ³ Data ³ 28/07/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Impressao de Boleto Bancario do Banco Itau com Codigo de   ³±±
±±³           ³ Barras, Linha Digitavel e Nosso Numero.                    ³±±
±±³           ³ Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ AcademiaERP                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION Modulo10(cData)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaração de variáveis³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local L,D,P := 0
Local B     := .F.
L := Len(cData)
B := .T.
D := 0
While L > 0
	P := VAL(SUBSTR(cData, L, 1))
	If (B)
		P := P * 2
		If P > 9
			P := P - 9
		EndIf
	EndIf
	D := D + P
	L := L - 1
	B := !B
EndDo
D := 10 - (Mod(D,10))
If D = 10
	D := 0
EndIf
Return(D)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ MODULO11()  ³ Autor ³Vinícius Gregório ³ Data ³ 28/07/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Impressao de Boleto Bancario do Banco Itau com Codigo de   ³±±
±±³           ³ Barras, Linha Digitavel e Nosso Numero.                    ³±±
±±³           ³ Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ AcademiaERP                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION Modulo11(cData)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaração de variáveis³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local L, D, P := 0
L := LEN(cdata)
D := 0
//P := 1 
P := 3
While L > 0
	P := P + 1
	D := D + (VAL(SUBSTR(cData, L, 1)) * P)
	If P = 9
		P := 1
	EndIf
	L := L - 1
EndDo
D := 11 - (mod(D,11))
If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
	D := 1
EndIf
Return(D)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ RET_CBARRA()³ Autor ³Vinícius Gregório ³ Data ³ 28/07/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Impressao de Boleto Bancario do Banco Itau com Codigo de   ³±±
±±³           ³ Barras, Linha Digitavel e Nosso Numero.                    ³±±
±±³           ³ Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ AcademiaERP                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cCarteira,cNroDoc,nValor,dVencto) 
Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cCarteira,cNroDoc,nValor,dVencto)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaração de variáveis³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local bldocnufinal := STRZERO(VAL(cNroDoc),8)
Local blvalorfinal := STRZERO(int(nValor*100),10)
Local dvnn         := 0
Local dvcb         := 0
Local dv           := 0
Local NN           := ''
Local RN           := ''
Local CB           := ''
Local s            := ''
Local _cfator      := STRZERO(dVencto - ctod("07/10/97"),4)
//Local cConta       := '  ' //RIGHT(cConta,5)
Local _cNossoNum   := ''
Local cDacA3       := ""
Local cDacA4       := ""
Local cConta       := RIGHT(cConta,6)
//-------- Definicao do NOSSO NUMERO
/*
If Empty(Alltrim(SE1->E1_NUMBCO))
	_cNossoNum :=GERNNUM()//000000024"
Else
	_cNossoNum := Alltrim(SE1->E1_NUMBCO)
EndIf
*/
_cNossoNum := Alltrim(SE1->E1_NUMBCO)

//NN   := cCarteira+SUBSTR(_cNossoNum,1,8)+'-'+SUBSTR(_cNossoNum,9,1) 
NN   := SUBSTR(_cNossoNum,1,9)
//	-------- Definicao do CODIGO DE BARRAS
cDacA3 := AllTrim(Str(Modulo10(cAgencia + cConta)))
cDacA4 := AllTrim(Str(Modulo10(cCarteira + SubStr(_cNossoNUm,1,8))))
//s  := cBanco + "9" + "7' + _cfator + blvalorfinal + SUBSTR(_cNossoNum,1,9) + cDacA4 + cAgencia + cConta + cDacA3 + '000'
//s  := cBanco +  "7" + _cfator + blvalorfinal + SUBSTR(_cNossoNum,1,9) + cDacA4 + cAgencia + cConta + cDacA3 + '000' 
s  := cBanco + "9" + _cfator + blvalorfinal + "7" + cAgencia + cConta + SUBSTR(_cNossoNum,1,9) +  "2" 
dvcb := modulo11(s)  //DV GERAL (DAC)
//dvcb := 7  
CB:=cBanco+"9"+str(dvcb,1)+_cfator+blvalorfinal + "7" + cAgencia + cConta + SUBSTR(_cNossoNum,1,9) +  "2" 
//CB   := StrTran(s, "?", AllTrim(Str(dvcb)))
//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
//	CAMPO 1:
//	AAA = Codigo do banco na Camara de Compensacao
//	  B = Codigo da moeda, sempre 9
//	CCC = Codigo da Carteira de Cobranca
//	 DD = Dois primeiros digitos no nosso numero
//	  X = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
//s    := cBanco + "9" + cCarteira + SUBSTR(_cNossoNum,1,2) 
s    := cBanco + "9" + "7"
dv   := modulo10(s) 
RN   := Transform(s+SUBSTR(cAgencia,2,3)+"0"+AllTrim(Str(dv)), "@R 99999.99999")      //ok
//	CAMPO 2:
//	DDDDDDDD = Restante do Nosso Numero
//	     FFF = Tres primeiros numeros que identIficam a agencia
//	       Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
dv   := modulo10(cAgencia+cConta+cDacCC+cCarteira+_cNossoNum) 
//s    := SUBSTR(_cNossoNum, 3, 7) + SUBSTR(cAgencia, 1, 3) 
s    := strzero(Val(cConta+cDacCC),10)
RN   := RN + " " + Transform(s + AllTrim(Str(modulo10(s))), "@R 99999.999999")  //ok
//	CAMPO 3:
//	     F = Restante do numero que identIfica a agencia
//	GGGGGG = Numero da Conta + DAC da mesma
//	   HHH = Zeros (Nao utilizado)
//	     Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
s    := _cNossoNum+"2"
dv   := modulo10(s)
RN   := RN + " " + Transform(s+AllTrim(Str(dv)), "@R 99999.999999")
//	CAMPO 4:
//	     K = DAC do Codigo de Barras
RN   := RN + " " + AllTrim(Str(dvcb))
//	CAMPO 5:
//	      UUUU = Fator de Vencimento
//	VVVVVVVVVV = Valor do Titulo
RN   := RN + " " + _cfator + STRZERO(Int(nValor * 100),14-LEN(_cfator))
Return({CB,RN,NN})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GerNNum   ºAutor  ³Vinícius Gregório   º Data ³  28/07/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica qual a próxima sequencia do "numero do banco      º±±
±±º          ³ e calcula o DAC do nosso numero                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AcademiaERP                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GerNnum()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaração de variáveis³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private _cfaxatu:="   "

Private _cNosNum:="  "
If Empty(SE1->E1_NUMBCO)
	dbSelectArea("SEE")
	dbSetOrder(1)
	dbSeek(xFilial("SEE")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA,.T.) //Banco + Agencia + Conta + Subconta
	
	_cfaxatu:=SEE->EE_FAXATU
	
	Reclock("SEE",.F.)
	
	SEE->EE_FAXATU:=SOMA1(alltrim(_cfaxatu))
	MsUnlock()
	
	
	Dbselectarea("SE1")
	Reclock("SE1",.F.)
	SE1->E1_NUMBCO:=_cfaxatu
	MsUnlock()	
Else
	_cfaxatu:=SE1->E1_NUMBCO
EndIf
cCampo1:=ALLTRIM(SE1->E1_AGEDEP)+SUBSTR(SE1->E1_CONTA,1,5)+"112"+ALLTRIM(_cFaxatu)
nMult := 2
nModulo := 0
nVal := 0

For i := Len(cCampo1) to 1 Step -1
	cChar := Substr(cCampo1,i,1)
	If isAlpha(cChar)
		Help(" ", 1, "ONLYNUM")
		// Substituido pelo assistente de conversao do AP5 IDE em 19/11/99 ==>          __Return(.f.)
		Return(.f.)        // incluido pelo assistente de conversao do AP5 IDE em 19/11/99
	EndIf
	nModulo := Val(cChar)*nMult
	If nModulo >= 10
		nVal := NVAL + 1
		nVal := nVal + (nModulo-10)
	Else
		nVal := nVal + nModulo
	EndIf
	nMult:= If(nMult==2,1,2)
Next
nCalc_DV1 := 10 - (nVal % 10)
nCalc_DV1 := IIf(nCalc_DV1==10,0,nCalc_DV1)

_cDac:=ALLTRIM(STR(nCalc_DV1))

_cNosNum:=ALLTRIM(_cFaxatu)+_cDac

Return(_cNosNum)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MacExec  ºAutor  ³ Vinícius Moreira   º Data ³ 20/08/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina verificadora da macro digitada.                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MacExec (cMacro,xResult)

Local bBlock := ErrorBlock()
Local bErro  := ErrorBlock( { |e| MacChk(e) } )

Private lRet:=.T.

If Empty(cMacro)
	Return .T.
Endif

xResult := &cMacro

ErrorBlock(bBlock)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fGetText ºAutor  ³ Vinícius Moreira   º Data ³ 21/08/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna texto da macro.                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGetText (cTexto)

If Left(cTexto, 1) == "#"
	MacExec(SubStr(cTexto,2), @cTexto)
EndIf

Return cTexto
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fGetRegs ºAutor  ³ Vinícius Moreira   º Data ³ 25/07/2017  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca registros que serão impressos.                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGetRegs( cAliasQry )

Local cQuery := ""

cQuery += " SELECT " + CRLF 
cQuery += "   SE1.R_E_C_N_O_ SE1REC " + CRLF 
cQuery += "  FROM " + RetSQLName( "SE1" ) + " SE1 " + CRLF 
cQuery += " WHERE SE1.E1_FILIAL = '" + xFilial( "SE1" ) + "' " + CRLF 
cQuery += "   AND SE1.E1_PREFIXO BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' " + CRLF 
cQuery += "   AND SE1.E1_NUM     BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' " + CRLF 
cQuery += "   AND SE1.E1_PARCELA BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' " + CRLF 
cQuery += "   AND SE1.E1_CLIENTE BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' " + CRLF 
cQuery += "   AND SE1.E1_LOJA    BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "' " + CRLF 
cQuery += "   AND SE1.E1_EMISSAO BETWEEN '" + dToS( mv_par11 ) + "' AND '" + dToS( mv_par12 ) + "' " + CRLF 
cQuery += "   AND SE1.E1_VENCREA BETWEEN '" + dToS( mv_par13 ) + "' AND '" + dToS( mv_par14 ) + "' " + CRLF 
cQuery += "   AND SE1.E1_NUMBOR  BETWEEN '" + mv_par15 + "' AND '" + mv_par16 + "' " + CRLF 
cQuery += "   AND SE1.E1_SALDO   > 0 " + CRLF 
cQuery += "   AND SE1.D_E_L_E_T_ = ' ' " + CRLF 
dbUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cAliasQry, .F., .T. )

Return ( cAliasQry )->( !Eof( ) )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RFINR01A ºAutor  ³ Vinicius Moreira   º Data ³ 25/07/2017  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Simula a execução da impressão via JOB.                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIN                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function RFINR01A( )
StartJob( "U_RFINR01",GetEnvServer(),.T., .T., 1, "0101VMS201707180", /*cPath*/, /*cFile*/, "01", "0101"  )
Return                                                                                                        


*------------------------------------------------*
Static Function CalcTxJr(_dDtVenc)
*------------------------------------------------*
_nRet := 0
IF SE1->E1_VENCREA < date()
	_nRet := (0.033*( date() - SE1->E1_VENCREA))
EndIf

Return _nRet    

*---------------------------------------------------------------*
User Function CALCMORA(_nSaldo,_nTaxa,_cTpRet)
*---------------------------------------------------------------*
Local _xRet := 0//""

If _nTaxa <=0
	Return  0 
Endif

_xRet := Round(_nSaldo*0.02	,2)
//_nSaldo := _nSaldo+(_nSaldo*0.02)     //afonso

If 	_cTpRet == "BOL"
	//_xRet := AllTrim(Transform( Round( ( _nSaldo * (_nTaxa/100) ) , 2), "@E 999,999,999.99"))
   //	_xRet +=  ( ( _nSaldo * (_nTaxa/100) ) , 2) 
	_xRet +=  Round( ( _nSaldo * (_nTaxa/100) ) , 2)
ElseIf _cTpRet == "CNAB"
	//_xRet:= STRZERO(Round( ( _nSaldo * (_nTaxa/100) ) , 2) * 100 ,13)
	//_xRet+= ( ( _nSaldo * (_nTaxa/100) ) , 2) * 100  
	_xRet+= Round( ( _nSaldo * (_nTaxa/100) ) , 2) * 100 
Endif

Return(_xRet)          
