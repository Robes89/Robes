#include "Rwmake.ch"
#include "Protheus.ch" 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCPOTELAIMPบAutor  ณTanimoto            บ Data ณ  02/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ rotina chamada no pte sf1100i para preencher dados da DI   บฑฑ
ฑฑบ          ณ de imoprtacao necessario para a NF-e 2.0.                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Bauducco                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function CpoTelaImp()
// MsDialog
Local   aArea	 		:= GetArea()
Private	_oDlg1
Private oGetTrans
// GetDados                      
Private nSuperior  		:= C(142)			// Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
Private nEsquerda	  	:= C(004)			// Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
Private nInferior  		:= C(190)			// Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
Private nDireita	   	:= C(275)			// Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
Private nOpcSF1			:= 3				// 1- Visualizar, 2- Incluir, 3- Alterar, 4-Excluir
Private cLinhaOk  		:= "AllwaysTrue"	// Funcao executada para validar o contexto da linha atual do aCols    
Private cTudoOk 	   	:= "AllwaysTrue"	// Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)      
Private cIniCpos   		:= ""				// Nome dos campos do tipo caracter que utilizarao incremento automatico.            
Private aAlter    	 	:= {"CD5_NADIC","CD5_SQADIC" } // Campos alterแveis da GetDados 
Private nFreeze	    	:= 000				// Campos estaticos na GetDados.                                                               
Private nMax       		:= 999				// Numero maximo de linhas permitidas. Valor padrao 99                           
Private cCampoOk   		:= "AllwaysTrue"	// Funcao executada na validacao do campo        
Private cSuperApagar	:= ""				// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>      
Private cApagaOk   		:= "AllwaysFalse"   // Funcao executada para validar a exclusao de uma linha do aCols
Private aHeaderSF1		:= MontEstr(1)		// aHeader GetDados
Private aColsSF1		:= {}				// aCols   GetDados
// Nota
Private cDocLoc2 		:= Space(TamSX3("F1_DOC")[1])
Private cSerieLoc		:= Space(TamSX3("F1_SERIE")[1])
//Importa็ใo
Private dDataDi	 		:= Stod("")
Private dDtDesem 		:= Stod("")
Private cNDi	 		:= Space(TamSX3("CD5_NDI")[1])
Private cUFDesem 		:= Space(TamSX3("CD5_UFDES")[1])
Private cLocDes  		:= Space(TamSX3("CD5_LOCDES")[1])
Private cInvoi	 		:= Space(TamSX3("F1_INVOWIS")[1])
//Private cExportador		:= Space(TamSX3("CD5_CODEXP")[1]) //ESTE CAMPO NAO TEM FUNCIONALIDADE PARA NOTA FISCAL ELETRONICA
//Private cFabricante		:= Space(TamSX3("CD5_CODFAB")[1])//ESTE CAMPO NAO TEM FUNCIONALIDADE PARA NOTA FISCAL ELETRONICA
Private nValFob 		:= vIOF := vDespAdu := vBC := vDescDI := vII := 0

cDocLoc2	:= SF1->F1_DOC
cSerieLoc	:= SF1->F1_SERIE

MontEstr(2) 

@ C(001) ,  C(001) To C(430) , C(555) Dialog _oDlg1 Title "Dados da DI importacao para NF-e 2.0"
@ C(004) ,  C(005) Say OemtoAnsi("Nota:") Size C(039),C(008) PIXEL OF _oDlg1
@ C(003) ,  C(045) MsGet oEdit1 Var cDocLoc2 When .f. Size C(035),C(006) PIXEL OF _oDlg1
@ C(004) ,  C(090) Say OemtoAnsi("Serie:") Size C(039),C(008) PIXEL OF _oDlg1
@ C(003) ,  C(140) MsGet oEdit1 Var cSerieLoc When .f. Size C(015),C(006) PIXEL OF _oDlg1
@ C(010) ,  C(002) To C(132) , C(277) LABEL OemtoAnsi("Dados de Importa็ใo") PIXEL OF _oDlg1	
// Importa็ใo __________________________________________________________  	
@ C(025) , C(005) Say OemtoAnsi("Invoice") PIXEL OF _oDlg1
@ C(025) , C(045) MsGet oEdit1 Var cInvoi Size C(040),C(006) PIXEL OF _oDlg1 
@ C(025) , C(090) Say OemtoAnsi("N๚mero DI") PIXEL OF _oDlg1
@ C(025) , C(140) MsGet oEdit1 Var cNDi  Size C(040),C(006) PIXEL OF _oDlg1 
@ C(025) , C(185) Say OemtoAnsi("Emissao DI") PIXEL OF _oDlg1
@ C(025) , C(235) MsGet oEdit1 Var dDataDi Valid ( dDataDi <= dDataBase ) Size C(040),C(006) PIXEL OF _oDlg1
@ C(035) , C(005) Say OemtoAnsi("UF de Desembara็o") PIXEL OF _oDlg1
@ C(035) , C(045) MsGet oEdit1 Var cUFDesem F3 "12" VALID ( !Empty( Tabela( "12" , cUFDesem , .F. ) ) ) Size C(019),C(006) PIXEL OF _oDlg1 
@ C(035) , C(090) Say OemtoAnsi("Dt Desembara็o") PIXEL OF _oDlg1
@ C(035) , C(140) MsGet oEdit1 Var dDtDesem  Valid ( dDtDesem <= dDataBase ) Size C(040),C(006) PIXEL OF _oDlg1                             
@ C(045) , C(005) Say OemtoAnsi("Local Desembara็o") PIXEL OF _oDlg1
@ C(045) , C(045) MsGet oEdit1 Var cLocDes Size C(140),C(006) PIXEL OF _oDlg1
//-------------------------------------------VLR IMPORTACAO
@ C(055) , C(005) Say OemtoAnsi("Valor II") PIXEL OF _oDlg1
@ C(055) , C(045) MsGet oEdit1 Var vII Picture "@E 999,999,999,999.99" Size C(040),C(006) PIXEL OF _oDlg1
//------------------------------------------- CIF E FOB
@ C(065) , C(005) Say OemtoAnsi("Vlr C.I.F") PIXEL OF _oDlg1
@ C(065) , C(045) MsGet oEdit1 Var vBC Picture "@E 999,999,999,999.99" Size C(040),C(006) PIXEL OF _oDlg1
@ C(065) , C(090) Say OemtoAnsi("Valor FOB") PIXEL OF _oDlg1
@ C(065) , C(140) MsGet oEdit1 Var nValFob Picture "@E 999,999,999,999.99" Size C(040),C(006) PIXEL OF _oDlg1
//------------------------------------------ TAXAS
@ C(075) , C(005) Say OemtoAnsi("Valor Tx SISCOMEX") PIXEL OF _oDlg1
@ C(075) , C(045) MsGet oEdit1 Var vDescDI Picture "@E 999,999,999,999.99" Size C(040),C(006) PIXEL OF _oDlg1
@ C(075) , C(090) Say OemtoAnsi("Vlr Desp.Aduaneiras") PIXEL OF _oDlg1
@ C(075) , C(140) MsGet oEdit1 Var vDespAdu Picture "@E 999,999,999,999.99" Size C(040),C(006) PIXEL OF _oDlg1
//------------------------------------------- IMPOSTO
@ C(085) , C(005) Say OemtoAnsi("Vlr do IOF") PIXEL OF _oDlg1
@ C(085) , C(045) MsGet oEdit1 Var vIOF Picture "@E 999,999,999,999.99" Size C(040),C(006) PIXEL OF _oDlg1
oGetTrans := MsNewGetDados():New( nSuperior, nEsquerda, nInferior, nDireita,nOpcSF1, cLinhaOk, cTudoOk, cIniCpos, aAlter, nFreeze, nMax,cCampoOk, cSuperApagar, cApagaOk, _oDlg1, aHeaderSF1, aColsSF1)
// Bot๕es __________________________________________________________  
@ C(200) , C(095) Button OemtoAnsi("Cadastrar") Size C(037),C(012) Action(Grava( cDocLoc2, cSerieLoc )) PIXEL OF _oDlg1
Activate Dialog _oDlg1 Centered

RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCPOTELAIMPบAutor  ณMicrosiga           บ Data ณ  04/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Grava(cDocLoc2,cSerieLoc)
Local aAreaQ	:= GetArea()
Local nRegAcols	:= Len(oGetTrans:aCols)
Local nB		:= 0
Local nAdicao	:= aScan(oGetTrans:aHeader ,{|x| x[2] == "CD5_NADIC" } )  
Local nSeqAdi	:= 1//aScan(oGetTrans:aHeader ,{|x| x[2] == "CD5_SQADIC" } )
Local nRecAcl	:= 5
//Importa็ใo
dbSelectArea("SF1")
dbSetOrder(1)
Reclock("SF1",.F.)
SF1->F1_INVOWIS := cInvoi
SF1->F1_NDIWISE := cNDi
SF1->F1_DTDIWIS := dDataDi
SF1->F1_LOCDESE := cLocDes
SF1->F1_UFDIDES := cUFDesem
SF1->F1_DTDESEM := dDtDesem
SF1->F1_II		:= vII
SF1->F1_IIVAL	:= vII			//UTILIZADO NA CONTABILIZACAO
SF1->F1_VBC		:= vBC			//UTILIZADO NA CONTABILIZACAO
SF1->F1_FOB_R 	:= nValFob		//UTILIZADO NA CONTABILIZACAO
SF1->F1_EXPORTA	:= "000000"
SF1->F1_FABR	:= "000000"
SF1->F1_DESCONI	:= vDescDI
SF1->F1_DESPADU	:= vDespAdu
SF1->F1_VLRIOF	:= vIOF
Msunlock()

If AllTrim(FunName())=="MATA103"//SOMENTE FACO ESTA CONDICAO QUANDO FOR ROTINA MATA119 - DESPESA DE IMPORTACAO. TANIMOTO 30/11/13 OU DOCUMENTO DE ENTRADA MATA103. TANIMOTO 26/02/14
	dbSelectArea("SD1")
	dbSetOrder(1) //Filial+Doc+Serie+Fornece+Loja+Produto+Item
	dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
	While !eof() .and. SD1->D1_DOC==SF1->F1_DOC .and. SD1->D1_SERIE==SF1->F1_SERIE .and. SD1->D1_FORNECE==SF1->F1_FORNECE .and. SD1->D1_LOJA==SF1->F1_LOJA
		For nB := 1 to nRegAcols
			dbSelectArea("CD5") //Filial+Doc+Serie+Fornece+Loja+DocImp+Nadic+SeqAdic
			dbSeek(xFilial("CD5")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+PADR(cValToChar(nB),50)+PADR(cNDi,3)+PADR(cValToChar(nSeqAdi),3))
			If !Found()
				Reclock("CD5",.T.)
				Replace	CD5_FILIAL		With xFilial("CD5")
				Replace	CD5_DOC   		With SF1->F1_DOC
				Replace	CD5_SERIE 		With SF1->F1_SERIE
				Replace	CD5_ESPEC 		With SF1->F1_ESPECIE
				Replace	CD5_FORNEC		With SF1->F1_FORNECE
				Replace	CD5_LOJA		With SF1->F1_LOJA
				Replace	CD5_TPIMP 		With ""
				Replace	CD5_DOCIMP		With cValToChar(nB) //Utilizo este campo senao ocorre erro de violacao de indice qdto em mais de uma adicao.
				Replace	CD5->CD5_NDI 	With cNDi
				Replace	CD5->CD5_DTDI 	With dDataDi
				Replace	CD5->CD5_LOCDES With cLocDes
				Replace	CD5->CD5_UFDES 	With cUFDesem
				Replace	CD5->CD5_DTDES 	With dDtDesem
				Replace	CD5->CD5_CODEXP	With "000000"
				Replace	CD5->CD5_CODFAB	With "000000"
				Replace	CD5->CD5_NADIC	With oGetTrans:aCols [ nB, nAdicao ]
				Replace	CD5->CD5_SQADIC	With cValToChar(nSeqAdi) //oGetTrans:aCols [ nB, nSeqAdi ]
				Replace	CD5->CD5_ITEM	With SD1->D1_ITEM
				Replace	CD5->CD5_TPIMP	With "0"
				Replace	CD5->CD5_LOCAL	With "0"
				Replace	CD5->CD5_VTRANS	With "4"
				Replace	CD5->CD5_INTERM	With "1"

				MsUnLock()
			EndIf
			nSeqAdi := nSeqAdi + 1
			dbSelectArea("SD1")
			dbSkip()
		Next nB		
	End
ElseIf AllTrim(FunName())=="MATA119"	//SOMENTE FACO ESTA CONDICAO QUANDO FOR ROTINA MATA119 - DESPESA DE IMPORTACAO. TANIMOTO 30/11/13 OU DOCUMENTO DE ENTRADA MATA103. TANIMOTO 26/02/14
	Pergunte("MTA114",.F.) //Grupo de perguntas da funcao MATA119 - DESPESA DE IMPORTACAO
	If mv_par08==2 //Gera complemento fiscal na geracao da nota de despesa de importacao 1=sim;2=nao. Se estiver como SIM nao incluo o CD5 por este ponto de entrada senao gera errorlog de chave duplicada
		dbSelectArea("SD1")
		dbSetOrder(1) //Filial+Doc+Serie+Fornece+Loja+Produto+Item
		dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
		While !eof() .and. SD1->D1_DOC==SF1->F1_DOC .and. SD1->D1_SERIE==SF1->F1_SERIE .and. SD1->D1_FORNECE==SF1->F1_FORNECE .and. SD1->D1_LOJA==SF1->F1_LOJA
			For nB := 1 to nRegAcols
				dbSelectArea("CD5") //Filial+Doc+Serie+Fornece+Loja+DocImp+Nadic+SeqAdic
				dbSeek(xFilial("CD5")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+PADR(cValToChar(nB),50)+PADR(cNDi,3)+PADR(cValToChar(nSeqAdi),3))
				If !Found()
					Reclock("CD5",.T.)
					Replace	CD5_FILIAL		With xFilial("CD5")
					Replace	CD5_DOC   		With SF1->F1_DOC
					Replace	CD5_SERIE 		With SF1->F1_SERIE
					Replace	CD5_ESPEC 		With SF1->F1_ESPECIE
					Replace	CD5_FORNEC		With SF1->F1_FORNECE
					Replace	CD5_LOJA		With SF1->F1_LOJA
					Replace	CD5_TPIMP 		With ""
					Replace	CD5_DOCIMP		With cValToChar(nB) //Utilizo este campo senao ocorre erro de violacao de indice qdto em mais de uma adicao.
					Replace	CD5->CD5_NDI 	With cNDi
					Replace	CD5->CD5_DTDI 	With dDataDi
					Replace	CD5->CD5_LOCDES With cLocDes
					Replace	CD5->CD5_UFDES 	With cUFDesem
					Replace	CD5->CD5_DTDES 	With dDtDesem
					Replace	CD5->CD5_CODEXP	With "000000"
					Replace	CD5->CD5_CODFAB	With "000000"
					Replace	CD5->CD5_NADIC	With oGetTrans:aCols [ nB, nAdicao ]
					Replace	CD5->CD5_SQADIC	With cValToChar(nSeqAdi) //oGetTrans:aCols [ nB, nSeqAdi ]
					Replace	CD5->CD5_ITEM	With SD1->D1_ITEM
					Replace	CD5->CD5_TPIMP	With "0"
					Replace	CD5->CD5_LOCAL	With "0"
					Replace	CD5->CD5_VTRANS	With "4"
					Replace	CD5->CD5_INTERM	With "1"
					
					MsUnLock()
				EndIf
				nSeqAdi := nSeqAdi + 1
				dbSelectArea("SD1")
				dbSkip()
			Next nB		
		End
	EndIf
EndIf
Close(_oDlg1)         
RestArea(aAreaQ)

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCPOTELAIMPบAutor  ณMicrosiga           บ Data ณ  04/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CrgDadosEnt( cDocLoc2 , cSerieLoc )
Local aArea	:= GetArea()
Local lRet 	:= .T.

DbSelectArea("SF1")
DbSetOrder(1)
DbSeek(xFilial("SF1") + cDocLoc2 + cSerieLoc)

If cDocLoc2 + cSerieLoc == SF1->( F1_DOC + F1_SERIE )
	cNDI		:= Iif(!Empty( CD5->CD5_DTDI		),CD5->CD5_DTDI		, Space(TAMSX3("CD5_DTDI" )[1] ) )
	dDataDi		:= Iif(!Empty( Dtos(CD5->CD5_DTDI)	),CD5->CD5_DTDI		, Stod("") )
	cLocDes		:= Iif(!Empty( CD5->CD5_LOCDES		),CD5->CD5_LOCDES	, Space(TAMSX3("CD5_LOCDES" )[1] ) )
	cUFDesem	:= Iif(!Empty( CD5->CD5_UFDES		),CD5->CD5_UFDES	, Space(TAMSX3("CD5_UFDES" )[1] ) )
	dDtDesem	:= Iif(!Empty( Dtos(CD5->CD5_DTDES)	),CD5->CD5_DTDES	, Stod("") )
	//cExportador	:= Iif(!Empty( CD5->CD5_CODEXP		),CD5->CD5_CODEXP	, Space(TAMSX3("CD5_CODEXP" )[1] ) )
	//cFabricate	:= Iif(!Empty( CD5->CD5_CODFAB		),CD5->CD5_CODFAB	, Space(TAMSX3("CD5_CODFAB" )[1] ) )
	oGetTrans:aCols	:= MontEstr(2)
	_oDlg1:Refresh()
	oGetTrans:Refresh()
Else
	If !Empty(cDocLoc2 + cSerieLoc) 
		MsgAlert("Nota nใo encontrada, verifique os parametros.","Aviso!!!")
		lRet	:= .F.
	Else
		lRet	:= .T.
	Endif
Endif

RestArea(aArea)

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCPOTELAIMPบAutor  ณMicrosiga           บ Data ณ  04/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MontEstr( nOpcGet )
Local aArea		:= GetArea()
Local aTabs		:= {}
Local aCabDet	:= {} 
Local _nN		:= 0

If nOpcGet == 1  //aHeader
	dbSelectArea("SX3")
	aAdd(aTabs,{Alias(),IndexOrd(),Recno()})
	dbSetOrder(1)
	dbgotop()
	dbSeek("CD5")
	aAdd(aCabDet,{"N.Adic","CD5_NADIC","@!",2,0,"","","C","",""})
	aAdd(aCabDet,{"S.Adic","CD5_SQADIC","@!",2,0,"","","C","",""})
Else
	dbSelectArea( "CD5" )
	aAdd(aTabs,{Alias(),IndexOrd(),Recno()})
   	dbSetOrder(1)
   	If dbSeek(xFilial("CD5")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))
   		While !eof("CD5") .and. SF1->(F1_DOC +F1_SERIE +F1_FORNECE+F1_LOJA)==CD5->(CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA)
   		
   	    	aAdd(aCabDet,{CD5->CD5_NADIC,CD5->CD5_SQADIC,.F.})
   	    	dbskip()
   	    End
   	Endif		
Endif	

For _nN := 1 To Len( aTabs )
	dbSelectArea(aTabs[_nN,1])
	dbSetOrder(aTabs[_nN,2])
	dbGoto(aTabs[_nN,3])
Next _nN
	                                       
RestArea(aArea)

Return(aCabDet)