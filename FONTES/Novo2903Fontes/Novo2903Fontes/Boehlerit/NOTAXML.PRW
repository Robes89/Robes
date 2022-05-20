#INCLUDE "PROTHEUS.CH"
#include "RWMAKE.ch"
#include "Colors.ch"
#include "Font.ch"
#Include "HBUTTON.CH"
#include "Topconn.ch"
#include "xmlxfun.ch"
#include "tbiconn.ch"
#include "totvs.ch"
#include "fileio.ch"
#include "tbiconn.ch"     
#INCLUDE "LOCXNF.CH"  
#include "TbiCode.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ NOTAXML  บAutor  ณ Fernando Pacheco   บ Data ณ  16/10/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Faz a importacao das notas de entrada conforme o arquivo   บฑฑ
ฑฑบ          ณ  XML informado                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Boehlerit                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function NOTAXML()

Local _oXML
Local _cArqXML  := ""
Local _cNomArq  := ""
Local _cExtArq  := ""
Local cError   := ""
Local cWarning := ""
Local _nCNPJOK  := 1

Private aRotina     := { {"Pesquisar","AxPesqui",0,1,0,.F.},{"Visualizar","A103NFiscal",0,2,0,Nil} }
Private lMsErroAuto := .F.
Private cCadastro	:= "Visualiza็ใo do Documento"
Private _cPerg      := "NOTAXML2  "
Private _cTESEnt    := ""
Private _cTESSai    := ""
Private _cCondPag   := ""
Private _cTipo	    := ""
Private _cCliPV     := ""
Private _cLojaPV    := ""
Private _cMsgPad    := ""
Private _cMsgLiv    := ""
Private _cTpFrete   := ""
Private _cForCli    := ""
Private aHeader     := {}
Private aCols       := {}
Private aCamp       := {}
Private _cLojaFC    := ""
Private _cDocOrig   := ""
Private _cSerOrig   := ""
Private nElem       := 0
Private _cQuery     := ""
Private oDlg     
Private _cInfComp   := ""
Private _aNewPro    := {}
Private _aNewReg    := {}
Private _aNfOri2    := {}
Private _aListB6    := {}
Private _nSaldoB6   := 0
Private aTipo	    :={'N','B','D'}
Private cFile 	    := " " 
Private CPERG       :="NOTAXML"  //"C:\XML\"  //
Private Caminho     := "C:\XML\" //"\SYSTEM\XMLNFe\" //"E:\Protheus10_Teste\protheus_data\XmlNfe\  Foi alterado para \System\XmlNfe\ para funcionar de qualquer estacao Emerson Holanda 10/11/10
Private _cMarca     := GetMark()
Private aFields     := {}
Private cArq
Private aInd      := {}
Private aFields2  := {}
Private cArq2
Private lPcNfe    := GETMV("MV_PCNFE")
Private MVXPRODCA := Alltrim(GETMV("MV_XPRODCA")) // PRODUTOS DE CATมLOGO
Private nIndice
Private _xNatur  := ""
Private aHeader  := {}
Private aCols    := {}
Private aCamp    := {}             
Private n        := 1
Private nTipo    := 0
Private cFornece := space(6)
Private cLoja    := "  "
Private cRazao   := Space(15)
Private xProd    := Space(15)
Private wProduto := Space(15)
Private aCols    := {}
Private nx       := 0
Private _cPedCom := "" 
Private _cItemPC := "" 
Private cA100For := ""
Private cLoja    := ""
Private _ctime   := substr(Time(),1,5)
Private _cInvoice:= ""
Private _aRestoreDad := {}
Private _lGrv := .f.
cTipo  := "N"

aDiretorio := Directory(Caminho+"*.XML", "D") //"\*.XML", "D")

If Len(aDiretorio) == 0
   MsgAlert("Nใo existe arquivo no caminho: "+caminho+" especificado! Verifique os parโmetros.","Aten็ใo!")
Endif

For nArq := 1 To Len(aDiretorio)
	cFile := AllTrim(Caminho+aDiretorio[nArq,1])

   If FILE(cFile)
      Importa() 
   Else
      MsgAlert("Nใo existe arquivo no caminho: "+caminho+" especificado! Verifique os parโmetros.","Aten็ใo!")
      EXIT
   Endif        

   nTipo    := 0
   cFornece := space(6)
   cLoja    := "  "
   cRazao   := Space(15)
   xProd    := Space(15)
   wProduto := Space(15)
   cTipo    := ""
   cNumDoc  := ""
   cSerie   := ""
   cData    := ""
   cCgc     := ""
   cRazao   := ""
   wProduto := space(15)

NEXT

Return Nil

Static Function Importa
		
AjustaSx1()
//Pergunte(_cPerg,.T.)
If !Pergunte(_cPerg,.T.)
	Return
EndIf

	cError		:= ""
	cWarning	:= ""
	
	cARQXML		:= MEMOREAD(cFile)
	_oXml		:= XmlParser( cARQXML, "_", @cError, @cWarning )
	
	//If Empty(cError + cWarning)  // Nao ocorreu erro na abertura do arq. XML.
                         
//_oXML := XmlParser( cFile , "_", cError, cWarning ) //XmlParserFile(cFile,"_",@_cError,@_cWarning)

//	_cInfComp := Alltrim(_oXML:_NFE:_INFNFE:_InfAdic:_InfCpl:TEXT)
//If !Empty(Alltrim(_cInfComp))
//	Aviso("Informa็๕es Complementares:",_cInfComp,{"Fechar"}) 
//Endif	

	// Se nao houver nenhum erro, inicia o processo, caso contrario mostra mensagem de erro
If Empty(cError) .And. Empty(cWarning) .And. _oXML <> Nil .And. ValType(XmlChildEx(_oXML,"_NFE")) == "O"
		Processa({|| _oImpNota(_oXML:_NFE:_INFNFE)})
Else
	Aviso("Erro","Houve um erro ao tentar abrir o arquivo "+cFile+Chr(13)+cError+Chr(13)+cWarning,{"Fechar"})
	MsgAlert("O arquivo de nome "+cFile+" nao pode ser aberto por estar incompativel com o padrao XML! Solicite junto ao fornecedor o envio de arquivo autorizado!!!","Atencao!")
	xFile := STRTRAN(Upper(cFile),"XMLNFE\", "XMLNFE\ERRO\")
	COPY FILE &cFile TO &xFile
	FErase(cFile)
	Return
EndIf
      
Return


Static Function _oImpNota(_oDados)

Local _oMainDlg
Local _aArrSA2 := {}
Local _aCabec  := {}
Local _aItens  := {}
Local _aAuxIte := {}
Local _aFndSA  := {}
Local _aNfOri  := {}
Local _aRetBox := {}
Local _aNFOrig := {}
Local _aCD5    := {}
Local _aItemCD5:= {}
Local _cNewCod := ""
Local _cEnd    := ""
Local _cCodPrd := ""
Local _cCodMun := ""
Local _cCodSA5 := ""
Local _cTypDet := ""
Local _cCodXML := ""
Local _cInfCom := ""
Local _cDesXML := ""
Local _cNota   := StrZero(Val(_oDados:_IDE:_NNF:TEXT),TamSX3("F2_DOC")[1])
Local _dDtEmis := StoD(StrTran(_oDados:_IDE:_DHEMI:TEXT,"-",""))
Local _cSerie  := AllTrim(_oDados:_IDE:_SERIE:TEXT) + Space(3-Len(AllTrim(_oDados:_IDE:_SERIE:TEXT)))
Local _nPos    := 0
Local _nQuant  := 0
Local _nUnit   := 0
Local _nBasICM := 0
Local _nValICM := 0
Local _nAlqICM := 0
Local _nAlqIPI := 0
Local _nValIPI := 0
Local _nTotal  := 0
Local _nTotNf  := 0
Local _nPosTot := 0
Local _nRecSF1 := 0
Local _nRecSA2 := 0
Local _lTela   := .T.              
Local _cCGC    := ""
Local _cRazao  := ""     
Local oDlgDados
Local _flag2 := .f.
// Configura os dados referentes a esta nota

_cRazao  := _oDados:_DEST:_XNOME:TEXT
//Aviso("Informativo","Fornecedor: "+_cRazao+", localizar c๓digo.",{"Fechar"})

_cTipo	  := "1"   //mv_par03
_cCondPag := "008" //mv_par02

cA100For := _cForCli := mv_par01 //"080004" //SA2->A2_COD
cLoja := _cLojaFC := mv_par02 //"01" //SA2->A2_LOJA
_cTxSisc := Alltrim(mv_par03) 
_nTxSisc := ""
For x := 1 to Len(_cTxSisc)
   If substr(_cTxSisc,x,1) == ","
      _nTxSisc += "."
   Else
      _nTxSisc += substr(_cTxSisc,x,1)
   Endif   
Next
_nTxSisc := Val(_nTxSisc)
//_cRazao  := "BOEHLERIT GMBH CO KG - AUSTRIA" //SA2->A2_NOME

_cDocOrig := ""
_cSerOrig := ""                                       
aProd     := {}
nP        := 0
_nPos     := 0                                           
_nRegXML  := IIf(_cTypDet=="O",1,Len(_oDados:_DET)) 

//_cCNPJ := _oDados:_EMIT:_CNPJ:TEXT         
//BOEHLERIT GMBH   CO KG - AUSTRIA
//_cCHVNFE := substr(_oDados:_ID:TEXT,4,44)
//NFe35160900583180000181550010000009881091517294

_cTypDet := ValType(_oDados:_DET)
_nPos := 0
_lSai := .f.               
lAchou := .t.
ProcRegua(IIf(_cTypDet=="O",1,Len(_oDados:_DET)))
For _nPos := 1 To IIf(_cTypDet=="O",1,Len(_oDados:_DET)) 
	
	IncProc("Verificando os produtos...")
	
	_cCodPrd := ""
	If _cTypDet=="O"
		_cCodXML := _oDados:_DET:_PROD:_CPROD:TEXT  
		_cDesXML := _oDados:_DET:_PROD:_XPROD:TEXT
		_cInvoice := _oDados:_DET:_PROD:_XPED:TEXT
	Else
		_cCodXML := AllTrim(_oDados:_DET[_nPos]:_PROD:_CPROD:TEXT)
		_cDesXML := AllTrim(_oDados:_DET[_nPos]:_PROD:_XPROD:TEXT)
		_cInvoice := _oDados:_DET[_nPos]:_PROD:_XPED:TEXT
	EndIf                             
	
	_cCodXML := Alltrim(_cCodXML) 

	//verifico se o c๓digo ้ o mesmo do Protheus
	dbSelectArea("SB1")
	dbSetOrder(18) 
	
	If dbSeek(xFilial("SB1")+PADR(_cCodXML,46))
	    //produto identificado
	    //_xCodPro := SB1->B1_COD
//       nP := aScan(aProd,{|x| x[2] == SB1->B1_CODLMT })
//  	   If nP == 0
          AADD(aProd,{_nPos,SB1->B1_CODLMT,SB1->B1_COD,_cCodXML })        
//	   Endif
	Else
		lAchou := .f.  
		_cCodPro := space(15)
	    //Aviso("Erro","Codigo do Produto lan็ado pelo fornecedor= "+_cCodXML+", nใo identificado no XML= "+_cDesXML+", selecionar Produto.",{"Fechar"})
        If Select("TRB") > 0
        	TRB->(dbCloseArea())
        Endif
        If Select("TRP") > 0
        	TRP->(dbCloseArea())
        Endif		
		Selecao()
		_cRegSel := MostraSel(_cCodXML,_nPos)
		If Empty(Alltrim(_cRegSel))
		   Return
		Endif
        _yCodLMT := substr(_cRegSel,1,46)
        _yCodPro := substr(_cRegSel,57,15)
        If !Empty(Alltrim(_cRegSel))
           lAchou := .t.
        Endif   
//		nP := aScan(aProd,{|x| x[2] == _yCodPro })
//		If nP == 0
            AADD(aProd,{_nPos,_yCodLMT,_yCodPro,_cCodXML})        
//		Endif
		_cCodXML := _yCodLMT

/*
	    nOpc := 0

		While .t.  

			@ 96,100 To 350,600 Dialog oMen Title "Selecionar Produto da Invoice" 
			@ 025,010 Say "Codigo: " Pixel
			@ 025,050 Get _cCodPro F3 "ZZ1A" SIZE 060, 050
			@ 045,150 BmpButton Type 1 Action (nOpc := 1,oMen:End())
			@ 045,180 BmpButton Type 2 Action (oMen:End())
			Activate Dialog oMen CENTERED

*/
/*
		dbSelectArea("TRB")
		TRB->(dbGoTop())
		While TRB->(!Eof())
			If !Empty(TRB->OK)
		       dbSelectArea("SB1")
		       dbSetOrder(1)
			   If dbSeek(xFilial("SB1")+TRB->CODLMT) //_cCodPro)
		          lAchou := .t.
			      nP := aScan(aProd,{|x| x[2] == TRB->CODLMT })
		    	  If nP == 0
                      AADD(aProd,{_nPos,TRB->CODLMT,TRB->CODINT,_cCodXML })        
		          Endif
			      _cCodXML := SB1->B1_CODLMT
	              Exit 
	           Else
	              Alert("Selecione o produto novamente, opcao nใo identificada","ALERT")   
	           Endif   
			Endif
			TRB->(dbSkip())
		Enddo
*/           
		If !lAchou
		    Aviso("Erro","Produto: "+_cCodXML+": "+_cDesXML+", nใo identificado, verificar.",{"Fechar"})
	    	_lSai := .t.
		Else
		    _lSai := .f.
		Endif
	Endif

next _nPox
If _lSai  .or. Len(aProd) <> _nRegXML
   Aviso("Erro","Devido nใo ter identificado algum dos produtos no XML, o processo serแ interrompido para cadastro do produto.",{"Fechar"})
   Return
Endif   

nElem := 0            
_cTypDet := ValType(_oDados:_DET)
ProcRegua(IIf(_cTypDet=="O",1,Len(_oDados:_DET)))

_nValDif := 0
_nValFre := 0
_nTotPis := 0
_nTotCof := 0
_nTotBasIPI := 0
_nTotDesp := 0
_flag := .f.

If Alltrim(GetEnvServer()) $ "VALIDACAO/COMPILA_TST"
    _cpesq := "9     "
	cSerie := "9  "    
	_lGrv := .f.
Else
    _cpesq := "4     "
	cSerie:= "4  "
	_lGrv := .t.
Endif   
//_cpesq := "ZZZ   "
//cSerie := "ZZZ"

cNFiscal := tabela("01",cSerie)

For _nPos := 1 To IIf(_cTypDet=="O",1,Len(_oDados:_DET))
	
	IncProc("Gerando nota de entrada...")

	_nBasICM := 0
	_nValICM := 0
	_nAlqICM := 0
	_nAlqIPI := 0
	_nValIPI := 0   
	_nBasIPI := 0
	_nBasPIS := 0
	_nValPis := 0
	_nAliPis := 0
	_nBasCOF := 0
	_nAliCOF := 0
	_nValCOF := 0
	_nValII  := 0
	_alqcof  := 9.65
	_alqpis  := 2.1
	_alqcsl  := 1      
	_nDespesa:= 0
	
	If _cTypDet=="O"
		_cCodXML := _oDados:_DET:_PROD:_CPROD:TEXT
		_cDesXML := _oDados:_DET:_PROD:_XPROD:TEXT
		_xQuant  := Val(_oDados:_DET:_PROD:_QCOM:TEXT)
	    _nQuant  := Val(_oDados:_DET:_PROD:_QCOM:TEXT)
		_nUnit   := Val(_oDados:_DET:_PROD:_VUNCOM:TEXT)
		_nTotal  := Val(_oDados:_DET:_PROD:_VPROD:TEXT)
		_cItem   := _oDados:_DET:_NITEM:TEXT
		If ValType(XmlChildEx(_oDados:_DET:_IMPOSTO,"_ICMS")) == "O" .And. ValType(XmlChildEx(_oDados:_DET:_IMPOSTO:_ICMS,"_ICMS00")) == "O"
			_nBasICM := Val(_oDados:_DET:_IMPOSTO:_ICMS:_ICMS00:_VBC:TEXT)
			_nValICM := Val(_oDados:_DET:_IMPOSTO:_ICMS:_ICMS00:_VICMS:TEXT)
			_nAlqICM := Val(_oDados:_DET:_IMPOSTO:_ICMS:_ICMS00:_PICMS:TEXT)
		    If _nValICM == 0
		       _nBasICM := 0
		    Endif   
		EndIf            
		If _nBasICM == 0
			If ValType(XmlChildEx(_oDados:_DET:_IMPOSTO,"_ICMS")) == "O" .And. ValType(XmlChildEx(_oDados:_DET:_IMPOSTO:_ICMS,"_ICMS20")) == "O"
				_nBasICM := Val(_oDados:_DET:_IMPOSTO:_ICMS:_ICMS00:_VBC:TEXT)
				_nValICM := Val(_oDados:_DET:_IMPOSTO:_ICMS:_ICMS00:_VICMS:TEXT)
				_nAlqICM := Val(_oDados:_DET:_IMPOSTO:_ICMS:_ICMS00:_PICMS:TEXT)
			    If _nValICM == 0
			       _nBasICM := 0
			    Endif   
			EndIf            
		Endif
		If ValType(XmlChildEx(_oDados:_DET:_IMPOSTO,"_IPI")) == "O" .And. ValType(XmlChildEx(_oDados:_DET:_IMPOSTO:_IPI,"_IPITRIB")) == "O"
			_nAlqIPI := Val(_oDados:_DET:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT)
			_nValIPI := Val(_oDados:_DET:_IMPOSTO:_IPI:_IPITRIB:_VIPI:TEXT)
			_nBasIPI := Val(_oDados:_DET:_IMPOSTO:_IPI:_IPITRIB:_VBC:TEXT)
		    If _nValIPI == 0
		       _nBasIPI := 0
		    Endif   
		EndIf
		If ValType(XmlChildEx(_oDados:_DET:_IMPOSTO,"_COFINS")) == "O" .And. ValType(XmlChildEx(_oDados:_DET:_IMPOSTO:_COFINS,"_COFINSALIQ")) == "O"
			_nAlqCOF := Val(_oDados:_DET:_IMPOSTO:_COFINS:_COFINSALIQ:_PCOFINS:TEXT)
			_nValCOF := Val(_oDados:_DET:_IMPOSTO:_COFINS:_COFINSALIQ:_VCOFINS:TEXT)
			_nBasCOF := Val(_oDados:_DET:_IMPOSTO:_COFINS:_COFINSALIQ:_VBC:TEXT)
		    If _nValCOF == 0
		       _nBasCOF := 0
		    Endif   
		EndIf
		If _nAlqCOF > 9.65 .and. _nBasCOF > 0
		   _nDespesa := (_nBasCOF * (_nAlqCOF / 100) ) - (_nBasCOF * (_alqcof / 100) )
		   _nValCOF := (_nBasCOF * (_alqcof / 100))
		   _alqcof := _nAlqCOF
		   _nAlqCOF := 9.65
		   _nValDif += _nDespesa
		Endif
		If ValType(XmlChildEx(_oDados:_DET:_IMPOSTO,"_PIS")) == "O" .And. ValType(XmlChildEx(_oDados:_DET:_IMPOSTO:_PIS,"_PISALIQ")) == "O"
			_nAlqPIS := Val(_oDados:_DET:_IMPOSTO:_PIS:_PISALIQ:_PPIS:TEXT)
			_nValPIS := Val(_oDados:_DET:_IMPOSTO:_PIS:_PISALIQ:_VPIS:TEXT)
			_nBasPIS := Val(_oDados:_DET:_IMPOSTO:_PIS:_PISALIQ:_VBC:TEXT)
		    If _nValPIS == 0
		       _nBasPIS := 0
		    Endif   
		EndIf
		If ValType(XmlChildEx(_oDados:_DET:_IMPOSTO,"_II")) == "O" //.And. ValType(XmlChildEx(_oDados:_DET:_IMPOSTO:_II,"_VII")) == "O"
			_nValII := Val(_oDados:_DET:_IMPOSTO:_II:_VII:TEXT)
		EndIf
		If ValType(XmlChildEx(_oDados:_DET:_PROD,"_VFRETE")) == "O" //.And. ValType(XmlChildEx(_oDados:_DET:_IMPOSTO:_II,"_VII")) == "O"
			_nValFre += Val(_oDados:_DET:_PROD:_VFRETE:TEXT)
		EndIf

		vii := Val(_oDados:_DET:_IMPOSTO:_II:_VII:TEXT)
		cNDi := _oDados:_DET:_PROD:_DI:_NDI:TEXT
		cDataDi := _oDados:_DET:_PROD:_DI:_DDI:TEXT  //2016-09-01
		dDataDi := ctod(substr(cDataDi,9,2)+"/"+substr(cDataDi,6,2)+"/"+substr(cDataDi,1,4))
		cDtDesem := _oDados:_DET:_PROD:_DI:_DDESEMB:TEXT
		dDtDesem := ctod(substr(cDtDesem,9,2)+"/"+substr(cDtDesem,6,2)+"/"+substr(cDtDesem,1,4))
		cUFDesem := _oDados:_DET:_PROD:_DI:_UFDESEMB:TEXT
		cLocDes := _oDados:_DET:_PROD:_DI:_XLOCDESEMB:TEXT
		cExport := _oDados:_DET:_PROD:_DI:_cExportador:TEXT      
		nAdicao := _oDados:_DET:_PROD:_DI:_ADI:_NADICAO:TEXT      
		nSeqAdic:= _oDados:_DET:_PROD:_DI:_ADI:_nSeqAdic:TEXT      
		cFabric := _oDados:_DET:_PROD:_DI:_ADI:_cFabricante:TEXT    
		ctpViaTrans := _oDados:_DET:_PROD:_DI:_tpViaTransp:TEXT        
		ctpIntermed := _oDados:_DET:_PROD:_DI:_tpIntermedio:TEXT        
        cExport := iif(empty(alltrim(cExport)),"000000",cExport)
        cFabric := iif(empty(alltrim(cFabric)),"000000",cFabric)

		_cInvoice := _oDados:_DET:_PROD:_XPED:TEXT
		_cItemInv := _oDados:_DET:_PROD:_NITEMPED:TEXT
		_nTotPIS += _nValPis
		_nTotCOF += _nValCof
		_nTotBasIPI += _nBasIPI

	Else
		_cCodXML := AllTrim(_oDados:_DET[_nPos]:_PROD:_CPROD:TEXT)
		_cDesXML := AllTrim(_oDados:_DET[_nPos]:_PROD:_XPROD:TEXT)
		_xQuant  := Val(_oDados:_DET[_nPos]:_PROD:_QCOM:TEXT)
	    _nQuant  := Val(_oDados:_DET[_nPos]:_PROD:_QCOM:TEXT)
		_nUnit   := Val(_oDados:_DET[_nPos]:_PROD:_VUNCOM:TEXT)
		_nTotal  := Val(_oDados:_DET[_nPos]:_PROD:_VPROD:TEXT)        
		_cItem   := _oDados:_DET[_nPos]:_NITEM:TEXT
		If ValType(XmlChildEx(_oDados:_DET[_nPos]:_IMPOSTO,"_ICMS")) == "O" .And. ValType(XmlChildEx(_oDados:_DET[_nPos]:_IMPOSTO:_ICMS,"_ICMS00")) == "O"
			_nBasICM := Val(_oDados:_DET[_nPos]:_IMPOSTO:_ICMS:_ICMS00:_VBC:TEXT)
			_nValICM := Val(_oDados:_DET[_nPos]:_IMPOSTO:_ICMS:_ICMS00:_VICMS:TEXT)
			_nAlqICM := Val(_oDados:_DET[_nPos]:_IMPOSTO:_ICMS:_ICMS00:_PICMS:TEXT)
		    If _nValICM == 0
		       _nBasICM := 0
		    Endif   
		EndIf
		If _nBasICM == 0
			If ValType(XmlChildEx(_oDados:_DET[_nPos]:_IMPOSTO,"_ICMS")) == "O" .And. ValType(XmlChildEx(_oDados:_DET[_nPos]:_IMPOSTO:_ICMS,"_ICMS20")) == "O"
				_nBasICM := Val(_oDados:_DET[_nPos]:_IMPOSTO:_ICMS:_ICMS20:_VBC:TEXT)
				_nValICM := Val(_oDados:_DET[_nPos]:_IMPOSTO:_ICMS:_ICMS20:_VICMS:TEXT)
				_nAlqICM := Val(_oDados:_DET[_nPos]:_IMPOSTO:_ICMS:_ICMS20:_PICMS:TEXT)
			    If _nValICM == 0
			       _nBasICM := 0
			    Endif   
			EndIf
		Endif
		If ValType(XmlChildEx(_oDados:_DET[_nPos]:_IMPOSTO,"_IPI")) == "O" .And. ValType(XmlChildEx(_oDados:_DET[_nPos]:_IMPOSTO:_IPI,"_IPITRIB")) == "O"
			_nAlqIPI := Val(_oDados:_DET[_nPos]:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT)
			_nValIPI := Val(_oDados:_DET[_nPos]:_IMPOSTO:_IPI:_IPITRIB:_VIPI:TEXT)
			_nBasIPI := Val(_oDados:_DET[_nPos]:_IMPOSTO:_IPI:_IPITRIB:_VBC:TEXT)
		    If _nValIPI == 0
		       _nBasIPI := 0
		    Endif   
		EndIf
		If ValType(XmlChildEx(_oDados:_DET[_nPos]:_IMPOSTO,"_COFINS")) == "O" .And. ValType(XmlChildEx(_oDados:_DET[_nPos]:_IMPOSTO:_COFINS,"_COFINSALIQ")) == "O"
			_nAlqCOF := Val(_oDados:_DET[_nPos]:_IMPOSTO:_COFINS:_COFINSALIQ:_PCOFINS:TEXT)
			_nValCOF := Val(_oDados:_DET[_nPos]:_IMPOSTO:_COFINS:_COFINSALIQ:_VCOFINS:TEXT)
			_nBasCOF := Val(_oDados:_DET[_nPos]:_IMPOSTO:_COFINS:_COFINSALIQ:_VBC:TEXT)
		    If _nValCOF == 0
		       _nBasCOF := 0
		    Endif   
		EndIf
		If _nAlqCOF > 9.65 .and. _nBasCOF > 0
		   _nDespesa := (_nBasCOF * (_nAlqCOF / 100) ) - (_nBasCOF * (_alqcof / 100) )
		   _nValCOF := (_nBasCOF * (_alqcof / 100))
		   _alqcof := _nAlqCOF
		   _nAlqCOF := 9.65
		   _nValDif += _nDespesa
		Endif
		If ValType(XmlChildEx(_oDados:_DET[_nPos]:_IMPOSTO,"_PIS")) == "O" .And. ValType(XmlChildEx(_oDados:_DET[_nPos]:_IMPOSTO:_PIS,"_PISALIQ")) == "O"
			_nAlqPIS := Val(_oDados:_DET[_nPos]:_IMPOSTO:_PIS:_PISALIQ:_PPIS:TEXT)
			_nValPIS := Val(_oDados:_DET[_nPos]:_IMPOSTO:_PIS:_PISALIQ:_VPIS:TEXT)
			_nBasPIS := Val(_oDados:_DET[_nPos]:_IMPOSTO:_PIS:_PISALIQ:_VBC:TEXT)   
		    If _nValPIS == 0
		       _nBasPIS := 0
		    Endif   
		EndIf
		If ValType(XmlChildEx(_oDados:_DET[_nPos]:_PROD,"_VFRETE")) == "O" //.And. ValType(XmlChildEx(_oDados:_DET:_IMPOSTO:_II,"_VII")) == "O"
			_nValFre += Val(_oDados:_DET[_nPos]:_PROD:_VFRETE:TEXT)
		EndIf
		If ValType(XmlChildEx(_oDados:_DET[_nPos]:_IMPOSTO,"_II")) == "O" //.And. ValType(XmlChildEx(_oDados:_DET:_IMPOSTO:_II,"_VII")) == "O"
			_nValII := Val(_oDados:_DET[_nPos]:_IMPOSTO:_II:_VII:TEXT)
		EndIf

		_nTotPIS += _nValPis
		_nTotCOF += _nValCof 
		_nTotBasIPI += _nBasIPI

		vii := Val(_oDados:_DET[_nPos]:_IMPOSTO:_II:_VII:TEXT)
		cNDi := _oDados:_DET[_nPos]:_PROD:_DI:_NDI:TEXT
		cDataDi := _oDados:_DET[_nPos]:_PROD:_DI:_DDI:TEXT  //2016-09-01
		dDataDi := ctod(substr(cDataDi,9,2)+"/"+substr(cDataDi,6,2)+"/"+substr(cDataDi,1,4))
		cDtDesem := _oDados:_DET[_nPos]:_PROD:_DI:_DDESEMB:TEXT
		dDtDesem := ctod(substr(cDtDesem,9,2)+"/"+substr(cDtDesem,6,2)+"/"+substr(cDtDesem,1,4))
		cUFDesem := _oDados:_DET[_nPos]:_PROD:_DI:_UFDESEMB:TEXT
		cLocDes := _oDados:_DET[_nPos]:_PROD:_DI:_XLOCDESEMB:TEXT
		nAdicao := _oDados:_DET[_nPos]:_PROD:_DI:_ADI:_NADICAO:TEXT
		nSeqAdic:= _oDados:_DET[_nPos]:_PROD:_DI:_ADI:_nSeqAdic:TEXT      
		cExport := _oDados:_DET[_nPos]:_PROD:_DI:_cExportador:TEXT      
		cFabric := _oDados:_DET[_nPos]:_PROD:_DI:_ADI:_cFabricante:TEXT    
		ctpViaTrans := _oDados:_DET[_nPos]:_PROD:_DI:_tpViaTransp:TEXT        
		ctpIntermed := _oDados:_DET[_nPos]:_PROD:_DI:_tpIntermedio:TEXT        
        cExport := iif(empty(alltrim(cExport)),"000000",cExport)
        cFabric := iif(empty(alltrim(cFabric)),"000000",cFabric)

		_cInvoice := _oDados:_DET[_nPos]:_PROD:_XPED:TEXT
		_cItemInv := _oDados:_DET[_nPos]:_PROD:_NITEMPED:TEXT
	EndIf

	If _flag2  // pegar a proporcionalidade dos valores da nota
	   _nTotal   := ( _nTotal  / _xQuant) * _nQuant
	   _nBasICM  := ( _nBasICM / _xQuant) * _nQuant
	   _nValICM  := ( _nValICM / _xQuant) * _nQuant
	   _nValIPI  := ( _nValIPI / _xQuant) * _nQuant
	   _flag2 := .f.
	Endif

	vBC       := Val(_oDados:_TOTAL:_ICMSTOT:_VBC:TEXT)
	vTVlrICM  := Val(_oDados:_TOTAL:_ICMSTOT:_vICMS:TEXT)   
	vTVlrIPI  := Val(_oDados:_TOTAL:_ICMSTOT:_vIPI:TEXT)   
	vTVlrMerc := Val(_oDados:_TOTAL:_ICMSTOT:_vProd:TEXT)   
	vTVII     := Val(_oDados:_TOTAL:_ICMSTOT:_vII:TEXT) 	
	vTPIS     := Val(_oDados:_TOTAL:_ICMSTOT:_vPIS:TEXT) 	
	vTCOFINS  := Val(_oDados:_TOTAL:_ICMSTOT:_vCOFINS:TEXT) 	
	vBASE     :=  vTVlrMerc - vTVII
    
    nP := 2 // coluna com o c๓digo LMT
	_cCodXML :=  aProd[_nPos][nP]   

	dbSelectArea("SB1")
	dbSetOrder(18)
	dbSeek(xFilial("SB1")+PADR(ALLTRIM(_cCodXML),46))
	_cOrigem := SB1->B1_ORIGEM			
	If ALLTRIM(SB1->B1_COD) $ MVXPRODCA
		_cTES  := "142"  
    Else
	   If mv_par05 == 1
    	   If SB1->B1_IPI > 0
	    	   _cTES  := "002"  
	       Else 
		       _cTES  := "209"  
	       Endif		
	   Else
    	   If SB1->B1_IPI > 0
	    	   _cTES  := "180"  
	       Else 
		       _cTES  := "239"  
	       Endif		
    	Endif                                                  
    Endif
        //ZZ1  1 - ZZ1_FILIAL+ZZ1_INVOIC+ZZ1_ORDER+ZZ1_LINE                                                                                                                        
        //SC7 22 - C7_FILIAL+C7_CODLMT     
        //SB1 18 - B1_FILIAL+B1_CODLMT                                                                                                                                                                                                                                                                                     
	dbSelectArea("SF4")
	dbSetOrder(1)
	dbSeek(xFilial("SF4")+_cTES)  
	_cSitTrib := SF4->F4_SITTRIB
	
    _cClasFis := _cOrigem+_cSitTrib      
    _nTotDesp += _nDespesa
        
    _cPedCom := ""
    _cItemPC := "" 
	dbSelectArea("ZZ1")
	dbSetOrder(1)
	If dbSeek(xFilial("ZZ1")+PADR(_cInvoice,10))                  
		While !ZZ1->(Eof()) .and. ZZ1->ZZ1_FILIAL == xFilial("ZZ1") .and. Alltrim(ZZ1->ZZ1_INVOIC) == Alltrim(_cInvoice)
            If ALLTRIM(_cCodXML) == Alltrim(ZZ1->ZZ1_DESCRI) .and. ZZ1->ZZ1_QTY == _nQuant //.AND. Empty(Alltrim(ZZ1->ZZ1_ITEMNF))
               _cPedCom := ZZ1->ZZ1_ORDER
               _cItemPC := ZZ1->ZZ1_LINE
               Exit
			Endif
			ZZ1->(dbSkip())
		Enddo
	Else
	    Aviso("Erro","Invoice: "+_cInvoice+" nใo identificado, verificar.",{"Fechar"})
	    Return
    Endif    
			_aAuxIte  := {}                   
/*
			aadd(aLinha,{"D1_COD"  ,"PA001",Nil})
			aadd(aLinha,{"D1_QUANT",1,Nil})	
			aadd(aLinha,{"D1_VUNIT",100,Nil})
			aadd(aLinha,{"D1_TOTAL",100,Nil})
			aadd(aLinha,{"D1_TES","001",Nil})
*/
			AAdd(_aAuxIte, {"D1_CODLMT" ,PADR(ALLTRIM(_cCodXML),46)      ,Nil} )
			AAdd(_aAuxIte, {"D1_COD"    ,SUBSTR(ALLTRIM(SB1->B1_COD),1,15)  ,Nil} )
			AAdd(_aAuxIte, {"D1_QUANT"  ,_nQuant        ,Nil} )
			AAdd(_aAuxIte, {"D1_VUNIT"  ,_nUnit         ,Nil} )
			AAdd(_aAuxIte, {"D1_TOTAL"  ,_nTotal        ,Nil} )
			AAdd(_aAuxIte, {"D1_TES"    ,_cTES	        ,Nil} )

/*
			AAdd(_aAuxIte, {"D1_CODLMT" ,PADR(ALLTRIM(_cCodXML),46)    ,Nil} )
			AAdd(_aAuxIte, {"D1_COD"    ,SUBSTR(ALLTRIM(SB1->B1_COD),1,15)    ,Nil} )
			AAdd(_aAuxIte, {"D1_TES"    ,_cTES	        ,Nil} )
			AAdd(_aAuxIte, {"D1_LOCAL"  ,"07"			,Nil} )
			AAdd(_aAuxIte, {"D1_FILIAL"   ,xFilial("SD1")  ,Nil} )
			AAdd(_aAuxIte, {"D1_DOC"    ,cNFiscal       ,Nil} ) 
			AAdd(_aAuxIte, {"D1_SERIE"  ,cSerie         ,Nil} ) 
			AAdd(_aAuxIte, {"D1_FORNECE"  ,_cForCli       ,Nil} )    
			AAdd(_aAuxIte, {"D1_LOJA"     ,_cLojaFC       ,Nil} )    
			AAdd(_aAuxIte, {"D1_EMISSAO"  ,ddatabase     ,Nil} )
			AAdd(_aAuxIte, {"D1_DTDIGIT"  ,ddatabase     ,Nil} )
			AAdd(_aAuxIte, {"D1_TIPO"  	,"N"			,Nil} )
			AAdd(_aAuxIte, {"D1_FORMUL" ,"S"			,Nil} )
			AAdd(_aAuxIte, {"D1_QUANT"  ,_nQuant        ,Nil} )
			AAdd(_aAuxIte, {"D1_VUNIT"  ,_nUnit         ,Nil} )
			AAdd(_aAuxIte, {"D1_TOTAL"  ,_nTotal        ,Nil} )
			AAdd(_aAuxIte, {"D1_UM"     ,SB1->B1_UM     ,Nil} ) 
			AAdd(_aAuxIte, {"D1_GRUPO"  ,SB1->B1_GRUPO  ,Nil} )
			AAdd(_aAuxIte, {"D1_CONTA"  ,SB1->B1_CONTA  ,Nil} )
			AAdd(_aAuxIte, {"D1_TP"  	,SB1->B1_TIPO	,Nil} )
			AAdd(_aAuxIte, {"D1_CF"  	,"3102"			,Nil} )
			AAdd(_aAuxIte, {"D1_PEDIDO" ,_cPedCom       ,Nil} )
			AAdd(_aAuxIte, {"D1_ITEMPC" ,_cItemPC       ,Nil} )

			AAdd(_aAuxIte, {"D1_BASEICM",_nBasICM       ,Nil} )
			AAdd(_aAuxIte, {"D1_PICM"   ,_nAlqICM       ,Nil} )
			AAdd(_aAuxIte, {"D1_VAlICM" ,_nValICM       ,Nil} )
			AAdd(_aAuxIte, {"D1_IPI"    ,_nAlqIPI       ,Nil} )
			AAdd(_aAuxIte, {"D1_VALIPI" ,_nValIPI       ,Nil} )    

			AAdd(_aAuxIte, {"D1_BASIMP5" ,_nBasCOF      ,Nil} )    
			AAdd(_aAuxIte, {"D1_BASIMP6" ,_nBasPIS      ,Nil} )    
			AAdd(_aAuxIte, {"D1_VALIMP5" ,_nValCOF      ,Nil} )    
			AAdd(_aAuxIte, {"D1_VALIMP6" ,_nValPIS      ,Nil} )    
			AAdd(_aAuxIte, {"D1_ALQIMP5" ,_nAlqCOF      ,Nil} )    
			AAdd(_aAuxIte, {"D1_ALQIMP6" ,_nAlqPIS      ,Nil} )    
			AAdd(_aAuxIte, {"D1_DESPESA" ,_ndespesa     ,Nil} )    
			AAdd(_aAuxIte, {"D1_ALQCOF"  ,_alqcof       ,Nil} )    
			AAdd(_aAuxIte, {"D1_ALQPIS"  ,_alqpis       ,Nil} )    
			AAdd(_aAuxIte, {"D1_ALQCSL"  ,_alqcsl       ,Nil} )    
			AAdd(_aAuxIte, {"D1_ITEM"    ,STRZERO(_nPos,4),Nil} )     

			AAdd(_aAuxIte, {"D1_BASEIPI"  ,_nBasIPI      ,Nil} )
			AAdd(_aAuxIte, {"D1_CLASFIS"  ,_cClasFis     ,Nil} )
			AAdd(_aAuxIte, {"D1_QTDPEDI"  ,_nQuant       ,Nil} )
			AAdd(_aAuxIte, {"D1_CUSTO"    ,0  			 ,Nil} )   
			AAdd(_aAuxIte, {"D1_ALIQCMP"  ,18  			 ,Nil} )   
			AAdd(_aAuxIte, {"D1_ALIQSOL"  ,18  			 ,Nil} )   
			AAdd(_aAuxIte, {"D1_STSERV"   ,'1'  		 ,Nil} )   
			AAdd(_aAuxIte, {"D1_RATEIO"   ,'2'  		 ,Nil} )   
*/
			Aadd(_aCD5, {STRZERO(_nPos,4),_cForCli,_cLojaFC,cNDi,dDataDi,cLocDes, cUFDesem,dDtDesem,cExport,cFabric,nAdicao,nSeqAdic,ctpViaTrans,ctpIntermed,_cInvoice} )

			AAdd(_aItens, _aAuxIte)

			_nTotNf += _nTotal
Next _nPos

// Ajusta o valor dos itens para bater o valor total da nota fiscal
If Len(_aItens) > 0 .And. Round(_nTotNf,2) <> Round(_nTotal,2)
	_nPosTot := aScan(_aItens[Len(_aItens)], {|x| x[1]=="D1_TOTAL"} )
	_aItens[Len(_aItens)][_nPosTot][2] += ( Val(_oDados:_TOTAL:_ICMSTOT:_VPROD:TEXT) - _nTotNf )
EndIf

For l := 1 to Len(_aItens)                  อ
    nPos 	:= aScan(_aItens[Len(_aItens)], {|x| x[1]=="D1_TOTAL"} )
    _nTot := _aItens[l][nPos][2]
    _nRatDesp := (_nTotDesp + _nTxSisc) * ( _nTot / vTVlrMerc )
    nPos 	:= aScan(_aItens[Len(_aItens)], {|x| x[1]=="D1_DESPESA"} )
    If nPos > 0
       _aItens[l][nPos][2] := _nRatDesp
    Endif
    nPos 	:= aScan(_aItens[Len(_aItens)], {|x| x[1]=="D1_CUSTO"} )
    If nPos > 0
       _aItens[l][nPos][2] := _nTot+_nRatDesp
    Endif   
Next

vMENNOTA := "DI: "+cNDi +;
	    " / PIS: "+ALLTRIM(STR(_nTotPis,12,2))+;
	    " / COFINS: "+ALLTRIM(STR(_nTotCof+_nValDif,12,2))+;
	    " / TX: "+ALLTRIM(STR(_nTxSisc,12,2))
_nPesoL := Val(_oDados:_TRANSP:_VOL:_PESOL:TEXT )
_nPesoB := Val(_oDados:_TRANSP:_VOL:_PESOB:TEXT) 
_nVol   := Val(_oDados:_TRANSP:_VOL:_QVOL:TEXT )
_cEsp   := Alltrim(mv_par04) //_oDados:_TRANSP:_VOL:_ESP:TEXT 


// Cria o array com o cabecalho e rodap้ da nota fiscal 
/*
		aadd(aCabec,{"F1_TIPO"   ,"N"})
		aadd(aCabec,{"F1_FORMUL" ,"N"})
		aadd(aCabec,{"F1_DOC"    ,(cDoc)})
		aadd(aCabec,{"F1_SERIE"  ,"UNI"})
		aadd(aCabec,{"F1_EMISSAO",dDataBase})
		aadd(aCabec,{"F1_FORNECE","F00001"})
		aadd(aCabec,{"F1_LOJA"   ,"01"})
		aadd(aCabec,{"F1_ESPECIE","NFE"})
		aadd(aCabec,{"F1_COND","001"})
		aadd(aCabec,{"F1_DESPESA"   ,10})
		aadd(aCabec,{"E2_NATUREZ","NAT01"})
*/
AAdd(_aCabec, {"F1_TIPO"   ,"N"         ,nil})   //_cTipo      ,nil})
AAdd(_aCabec, {"F1_FORMUL" ,"S"         ,nil})
AAdd(_aCabec, {"F1_DOC", cNFiscal       ,nil})
AAdd(_aCabec, {"F1_SERIE",cSerie        ,nil})
AAdd(_aCabec, {"F1_EMISSAO",dDataBase   ,nil})
AAdd(_aCabec, {"F1_FORNECE",_cForCli    ,nil})
AAdd(_aCabec, {"F1_LOJA"   ,_cLojaFC    ,nil})
AAdd(_aCabec, {"F1_ESPECIE","SPED"      ,nil})
AAdd(_aCabec, {"F1_COND"   ,"005"	    ,nil})  //_cCondPag
AAdd(_aCabec, {"F1_DESPESA" ,_nValDif+_nTxSisc	,nil})

/*
AAdd(_aCabec, {"F1_TIPO"   ,"N"         ,nil})   //_cTipo      ,nil})
AAdd(_aCabec, {"F1_FORMUL" ,"S"         ,nil})
AAdd(_aCabec, {"F1_EMISSAO",dDataBase   ,nil})
AAdd(_aCabec, {"F1_DOC", cNFiscal       ,nil})
AAdd(_aCabec, {"F1_SERIE",cSerie        ,nil})

AAdd(_aCabec, {"F1_FORNECE",_cForCli    ,nil})
AAdd(_aCabec, {"F1_LOJA"   ,_cLojaFC    ,nil})
AAdd(_aCabec, {"F1_ESPECIE","SPED"      ,nil})
AAdd(_aCabec, {"F1_COND"   ,_cCondPag   ,nil})
AAdd(_aCabec, {"F1_NUMTRIB" ,"N" 	,nil})
AAdd(_aCabec, {"F1_INCISS"  ,"99999" 	,nil})
AAdd(_aCabec, {"F1_ESTPRES" , "EX" 	,nil})
AAdd(_aCabec, {"F1_STATUS"  ,"A"  	,nil})
AAdd(_aCabec, {"F1_RECBMTO" ,ddatabase 	,nil})
AAdd(_aCabec, {"F1_RECISS"  ,"2"  	,nil})

AAdd(_aCabec, {"F1_INVOWIS" ,_cInvoice 	,nil})
AAdd(_aCabec, {"F1_NDIWISE" ,cNDi    	,nil})
AAdd(_aCabec, {"F1_DTDIWIS" ,dDataDi    ,nil})
AAdd(_aCabec, {"F1_LOCDESE" ,cLocDes    ,nil})
AAdd(_aCabec, {"F1_UFDIDES" ,cUFDesem   ,nil})
AAdd(_aCabec, {"F1_DTDESEM" ,dDtDesem   ,nil})
AAdd(_aCabec, {"F1_II" 		,vTVII    	,nil})
AAdd(_aCabec, {"F1_IIVAL" 	,vTVII    	,nil})		 
AAdd(_aCabec, {"F1_VBC" 	,vBASE    	,nil})		 
AAdd(_aCabec, {"F1_EXPORTA" ,cExport    ,nil})
AAdd(_aCabec, {"F1_FABR" 	,cFabric    ,nil})
AAdd(_aCabec, {"F1_DESCONI" ,_nTxSisc   ,nil})
AAdd(_aCabec, {"F1_DESPESA" ,_nValDif+_nTxSisc	,nil})

AAdd(_aCabec, {"F1_PLIQUI"  , _nPesoL   ,nil})
AAdd(_aCabec, {"F1_PBRUTO"  , _nPesoB   ,nil})
AAdd(_aCabec, {"F1_ESPECI1" , _cEsp     ,nil})
AAdd(_aCabec, {"F1_VOLUME1" , _nVol     ,nil})
AAdd(_aCabec, {"F1_MENNOTA" , vMENNOTA   ,nil})
AAdd(_aCabec, {"F1_EST"     , "EX"   	,nil})		 	

//AAdd(_aCabec, {"F1_VII" 	, vTVII   	,nil})		 
AAdd(_aCabec, {"F1_BASEICM" , vBC   	,nil})		 
AAdd(_aCabec, {"F1_VALICM"  , vTVlrICm   	,nil})		 
AAdd(_aCabec, {"F1_BASEIPI" , _nTotBasIPI   	,nil})		 
AAdd(_aCabec, {"F1_VALIPI"  , vTVlrIPI   	,nil})		 
AAdd(_aCabec, {"F1_VALMERC" , vTVlrMerc   	,nil})		 
AAdd(_aCabec, {"F1_VALBRUT" , vBC   	,nil})		 
AAdd(_aCabec, {"F1_DTDIGIT" , ddatabase   	,nil})		 
AAdd(_aCabec, {"F1_BASIMP5" , vBASE   	,nil})		 
AAdd(_aCabec, {"F1_BASIMP6" , vBASE   	,nil})		 
AAdd(_aCabec, {"F1_VALIMP5" , _nTotCOF  	,nil}) //vTCOFINS
AAdd(_aCabec, {"F1_VALIMP6" , _nTotPIS   	,nil})	//vTPIS	 
AAdd(_aCabec, {"F1_MOEDA"   , 1   	,nil})		 
AAdd(_aCabec, {"F1_FILIAL"  ,xFilial("SF1") ,nil})   
AAdd(_aCabec, {"F1_HORA"    , _cTime   	,nil})		 	
*/
lMsErroAuto := .F.
If Len(_aItens) > 0
dbSelectArea("SD1")
dbSetOrder(1) 
dbSelectArea("SB1")
dbSetOrder(1) 
	
	//Mata103(_aCabec,_aItens,3,.T.)       
///MSExecAuto({|x,y,z| MATA103(x,y,z)},_aCabec,_aItens,3)
MSExecAuto({|x,y| mata103(x,y)},_aCabec,_aItens)		
	//MSExecAuto( {|x,y,z,w|MATA103( x, y, z, w ) }, _aCabec,_aItens, 3, .f. )
///	lMsErro := GravaDad(_aCabec,_aItens)
	
If !lMsErroAuto
///	If !lMsErro  
		MSGALERT(cNFiscal+' / '+cSerie+" - Nota Gerada Com Sucesso!")
		If Len(_aCD5) > 0
////		   GravaCD5(_aCD5,cNFiscal,cSerie)
		   MSGALERT(" DADOS DE IMPORTAวรO - Informa็๕es Complementares atualizadas com Sucesso !")   
		   cNFiscal := SOMA1(cNFiscal)
		   dbSelectArea("SX5")
		   dbSetOrder(1)        
		   If dbSeek(xFilial()+"01"+_cPesq)
		      RecLock("SX5",.f.)
			  SX5->X5_DESCRI   := cNFiscal
			  SX5->X5_DESCSPA  := cNFiscal
			  SX5->X5_DESCENG  := cNFiscal
			  MsUnLock()
		   Endif
		Endif   
	Else
		mostraerro()
		MSGALERT("Nota Nใo Gerada - Tente Novamente !")
	EndIf
	
	dbSelectArea("SF1")
	dbSetOrder(1)                                                 
	If dbSeek(xFilial("SF1")+padr(cNFiscal,9)+padr(cSerie,3)+cA100For+cLoja)
		Aviso("Nota de Entrada","Nota "+cNFiscal+" incluํda com sucesso.",{"Fechar"}) == 1
		lOk := .t.
	Else
		lOk := .f.
	EndIf     

    bDiretorio := Directory("C:\XML\PROCESSADAS\"+"*.XML", "D") 
    If Len(bDiretorio) == 0
		cpathTer := "C:\XML\PROCESSADAS\"
		Makedir(Trim(cPathTer)) //cria o diretorio
	Endif

    If lOk
	   xFile := STRTRAN(Upper(cFile),"C:\XML\", "C:\XML\PROCESSADAS\")
	   COPY FILE &cFile TO &xFile
  	   FErase(cFile)
	Endif		
EndIf

Return

Static Function GravaCD5(_xCD5,xNFiscal,xSerie)

If !_lGrv    
   Return
Endif   
For i := 1 to Len(_xCD5)

	dbSelectArea("CD5")
	Reclock("CD5",.T.)
	Replace	CD5_FILIAL	With xFilial("CD5")
	Replace	CD5_ITEM	With _xCD5[i][1]
	Replace	CD5_DOC   	With xNFiscal
	Replace	CD5_SERIE 	With xSerie
	Replace	CD5_ESPEC 	With "SPED"
	Replace	CD5_FORNEC	With _xCD5[i][2]
	Replace	CD5_LOJA	With _xCD5[i][3]
	Replace	CD5_TPIMP 	With "1"
	Replace	CD5_DOCIMP	With cValToChar(i)  
	Replace	CD5_NDI 	With _xCD5[i][4]
	Replace	CD5_DTDI 	With _xCD5[i][5]
	Replace	CD5_LOCDES  With _xCD5[i][6]
	Replace	CD5_UFDES 	With _xCD5[i][7]
	Replace	CD5_DTDES 	With _xCD5[i][8]
	Replace	CD5_CODEXP	With _xCD5[i][9] 
	Replace	CD5_CODFAB	With _xCD5[i][10]
	Replace	CD5_NADIC	With _xCD5[i][11]
	Replace	CD5_SQADIC	With cValToChar(_xCD5[i][12])  
	Replace	CD5_LOCAL	With "0"
	Replace	CD5_VTRANS	With _xCD5[i][13]
	Replace	CD5_INTERM	With _xCD5[i][14]
	MsUnLock()
Next

Return

Static Function GravaDad(_aCab,_aItem)
Local lRet := .t.

Begin Transaction 

If Len(_aCab) > 0

   dbSelectArea("SF1")
   dbSetOrder(1)
   If !dbSeek(xFilial("SF1")+padr(_aCab[4][2],9)+padr(_aCab[5][2],3)+_aCab[6][2]+_aCab[7][2])
	RecLock("SF1",.T.)               
	SF1->F1_FILIAL  := xFilial("SF1")
	SF1->F1_TIPO	:= _aCab[1][2]
	SF1->F1_FORMUL	:= _aCab[2][2]
	SF1->F1_EMISSAO	:= _aCab[3][2]
	SF1->F1_DOC     := _aCab[4][2]
	SF1->F1_SERIE	:= _aCab[5][2]  
	SF1->F1_EST     := "EX"

	SF1->F1_FORNECE	:= _aCab[6][2]
	SF1->F1_LOJA	:= _aCab[7][2]
	SF1->F1_ESPECIE	:= _aCab[8][2]
	SF1->F1_COND	:= _aCab[9][2]
	SF1->F1_NUMTRIB	:= _aCab[10][2]
	SF1->F1_INCISS	:= _aCab[11][2]
	SF1->F1_ESTPRES	:= _aCab[12][2]
	SF1->F1_STATUS	:= _aCab[13][2]
	SF1->F1_RECBMTO	:= _aCab[14][2]
	SF1->F1_RECISS	:= _aCab[15][2]

	SF1->F1_INVOWIS	:= _aCab[16][2]
	SF1->F1_NDIWISE	:= _aCab[17][2]
	SF1->F1_DTDIWIS	:= _aCab[18][2]
	SF1->F1_LOCDESE	:= _aCab[19][2]
	SF1->F1_UFDIDES	:= _aCab[20][2]
	SF1->F1_DTDESEM	:= _aCab[21][2]
	SF1->F1_II		:= _aCab[22][2]
	SF1->F1_IIVAL	:= _aCab[23][2]
	SF1->F1_VBC		:= _aCab[24][2]
	SF1->F1_EXPORTA	:= _aCab[25][2]
	SF1->F1_FABR	:= _aCab[26][2]
	SF1->F1_DESCONI	:= _aCab[27][2]
	SF1->F1_DESPESA	:= _aCab[28][2]

	SF1->F1_PLIQUI	:= _aCab[29][2]
	SF1->F1_PBRUTO	:= _aCab[30][2]
	SF1->F1_ESPECI1	:= _aCab[31][2]
	SF1->F1_VOLUME1	:= _aCab[32][2]
	SF1->F1_MENNOTA	:= _aCab[33][2]

    //SF1->F1_VII		:= _aCab[34][2]
	SF1->F1_BASEICM := _aCab[35][2]        
	SF1->F1_VALICM  := _aCab[36][2]
	SF1->F1_BASEIPI := _aCab[37][2]
	SF1->F1_VALIPI  := _aCab[38][2]
	SF1->F1_VALMERC := _aCab[39][2]
	SF1->F1_VALBRUT := _aCab[40][2]   
	SF1->F1_DTDIGIT := _aCab[41][2] 
	SF1->F1_BASIMP5	:= _aCab[42][2]
	SF1->F1_BASIMP6 := _aCab[43][2] 
	SF1->F1_VALIMP5	:= _aCab[44][2] 
	SF1->F1_VALIMP6 := _aCab[45][2] 
	SF1->F1_MOEDA   :=  1
	SF1->F1_HORA    := _ctime

	MsUnLock()
   Else
        lRet := .f.
   Endif

Endif

If lRet
   dbSelectArea("SD1")
   For l := 1 to len(_aItem)

	RecLock("SD1",.T.)                
	SD1->D1_CODLMT	:= _aItem[l][1][2]
	SD1->D1_COD		:= _aItem[l][2][2]
	SD1->D1_TES		:= _aItem[l][3][2]
	SD1->D1_LOCAL	:= _aItem[l][4][2]
	SD1->D1_FILIAL  := _aItem[l][5][2]  
	SD1->D1_DOC		:= _aItem[l][6][2]
	SD1->D1_SERIE	:= _aItem[l][7][2]
	SD1->D1_FORNECE := _aItem[l][8][2]
	SD1->D1_LOJA    := _aItem[l][9][2]
	SD1->D1_EMISSAO := _aItem[l][10][2]
	SD1->D1_DTDIGIT := _aItem[l][11][2]
	SD1->D1_TIPO  	:= _aItem[l][12][2]
	SD1->D1_FORMUL	:= _aItem[l][13][2]
	SD1->D1_QUANT	:= _aItem[l][14][2]
	SD1->D1_VUNIT	:= _aItem[l][15][2]
	SD1->D1_TOTAL	:= _aItem[l][16][2]
	SD1->D1_UM		:= _aItem[l][17][2]
	SD1->D1_GRUPO	:= _aItem[l][18][2]
	SD1->D1_CONTA	:= _aItem[l][19][2]
	SD1->D1_TP  	:= _aItem[l][20][2]
	SD1->D1_CF  	:= _aItem[l][21][2]
	SD1->D1_PEDIDO	:= _aItem[l][22][2]
	SD1->D1_ITEMPC	:= _aItem[l][23][2]

	SD1->D1_BASEICM	:= _aItem[l][24][2]
	SD1->D1_PICM	:= _aItem[l][25][2]
	SD1->D1_VAlICM	:= _aItem[l][26][2]
	SD1->D1_IPI		:= _aItem[l][27][2]
	SD1->D1_VALIPI	:= _aItem[l][28][2]

	SD1->D1_BASIMP5	:= _aItem[l][29][2]
	SD1->D1_BASIMP6	:= _aItem[l][30][2]
	SD1->D1_VALIMP5	:= _aItem[l][31][2]
	SD1->D1_VALIMP6	:= _aItem[l][32][2]
	SD1->D1_ALQIMP5	:= _aItem[l][33][2]
	SD1->D1_ALQIMP6	:= _aItem[l][34][2]
	SD1->D1_DESPESA	:= _aItem[l][35][2]
	SD1->D1_ALQCOF	:= _aItem[l][36][2]
	SD1->D1_ALQPIS	:= _aItem[l][37][2]
	SD1->D1_ALQCSL	:= _aItem[l][38][2]
	SD1->D1_ITEM    := _aItem[l][39][2]

	SD1->D1_BASEIPI := _aItem[l][40][2]
	SD1->D1_CLASFIS := _aItem[l][41][2]
	SD1->D1_QTDPEDI := _aItem[l][42][2]
	SD1->D1_CUSTO   := _aItem[l][43][2]
	SD1->D1_NUMSEQ  := ProxNum()
    msUnLock()

   If _lGrv
	dbSelectArea("SB2")
	dbSetOrder(1)
	If dbSeek(xFilial("SB2") +padr(_aItem[l][2][2],15) + "01")
        If SB2->B2_SALPEDI >= _aItem[l][14][2]
			RecLock("SB2",.F.)                
		    SB2->B2_SALPEDI -= _aItem[l][14][2]
			msUnlock()
		Endif   
	Endif                              
	If dbSeek(xFilial("SB2") +padr(_aItem[l][2][2],15) + "07")
		RecLock("SB2",.F.)                
		If SB2->B2_CM1 == 0      
		   //SB2->B2_VATU1 := SB2->B2_VATU1 + (_aItem[l][14][2] * SB2->B2_CM1)
		//Else                           
		   SB2->B2_VATU1 := (SB2->B2_QATU + _aItem[l][14][2]) * _aItem[l][43][2]
		Endif   
		SB2->B2_QATU    += _aItem[l][14][2]
        If SB2->B2_SALPEDI >= _aItem[l][14][2]
		   SB2->B2_SALPEDI -= _aItem[l][14][2]
		Endif   
		msUnlock()
	Endif                              
//	If dbSeek(xFilial("SB2") +padr(_aItem[l][1][2],15) + "07")
//		RecLock("SB2",.F.)                
//		SB2->B2_QATU  -= _aItem[l][14][2]
//		msUnlock()
//	Endif                              
                           
	dbSelectArea("SC7")
	dbSetOrder(1)
	If dbSeek(xFilial("SC7")+_aItem[l][22][2]+_aItem[l][23][2])
	   RecLock("SC7",.f.) 
	   SC7->C7_QUJE += _aItem[l][14][2]
	   MsUnLock()
	Endif   

	dbSelectArea("ZZ1")
	dbSetOrder(1)
	If dbSeek(xFilial("ZZ1")+PADR(_cInvoice,10))
		While !ZZ1->(Eof()) .and. ZZ1->ZZ1_FILIAL == xFilial("ZZ1") .and. Alltrim(ZZ1->ZZ1_INVOIC) == Alltrim(_cInvoice)
            If ALLTRIM(padr(_aItem[l][1][2],15)) == Alltrim(ZZ1->ZZ1_DESCRI) .and. ZZ1->ZZ1_QTY == _aItem[l][14][2] //.AND. Empty(Alltrim(ZZ1->ZZ1_ITEMNF))
               If (_aItem[l][22][2]+_aItem[l][23][2]) == ZZ1->ZZ1_ORDER+ZZ1->ZZ1_LINE
                  RecLock("ZZ1",.f.)
                  ZZ1->ZZ1_ITEMNF := _aItem[l][39][2]   
                  ZZ1->ZZ1_NFISCA := _aItem[l][6][2]
				  ZZ1->ZZ1_SERIE  := _aItem[l][7][2]
				  ZZ1->ZZ1_DATENT := _aItem[l][11][2]
                  MsUnlock()            
                  Exit
               Endif   
			Endif
			ZZ1->(dbSkip())
		Enddo
    Endif    
   Endif
   Next
   lRet := .f.
Endif

End Transaction

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณoAjustaSX1บAutor  ณ  บ Data ณ  30/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ajusta o Arquivo SX1 conforme necessidade do relatorio     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Bright                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AjustaSx1()

Local _aPerg  := {}
Local _ni

Aadd(_aPerg,{"Fornecedor...........?","mv_ch1","C",06,"G","mv_par01","","","","SA2","","",""})
Aadd(_aPerg,{"Loja.................?","mv_ch2","C",02,"G","mv_par02","","","","","","",""})
Aadd(_aPerg,{"Tx.Siscomex R$.......?","mv_ch3","C",15,"G","mv_par03","","","","","","",""})
Aadd(_aPerg,{"ESPECIE..............?","mv_ch4","C",10,"G","mv_par04","","","","","","",""})
Aadd(_aPerg,{"Base Reduzida .......?","mv_ch5","C",1 ,"C","mv_par05","Nao","Sim","","","","",""})
//Aadd(_aPerg,{"Tx.Siscomex R$.......?","mv_ch4","N",12,"G","mv_par03","","","",""   ,"","1-Normal","2-Devolucao","3-Beneficiament"})
//Aadd(_aPerg,{"Serie NF Origem......?","mv_ch5","C",03,"G","mv_par05","","","","","","",""})

dbSelectArea("SX1")      
dbSetOrder(1)
If dbSeek(_cPerg)//+StrZero(_ni,2))
   Return 
Endif
SX1->(dbGoTop())
For _ni := 1 To Len(_aPerg)
	If !dbSeek(_cPerg+StrZero(_ni,2))
		RecLock("SX1",.T.)
		SX1->X1_GRUPO    := _cPerg
		SX1->X1_ORDEM    := StrZero(_ni,2)
		SX1->X1_PERGUNT  := _aPerg[_ni][1]
		SX1->X1_VARIAVL  := _aPerg[_ni][2]
		SX1->X1_TIPO     := _aPerg[_ni][3]
		SX1->X1_TAMANHO  := _aPerg[_ni][4]
		SX1->X1_GSC      := _aPerg[_ni][5]
		SX1->X1_VAR01    := _aPerg[_ni][6]
		SX1->X1_DEF01    := _aPerg[_ni][7]
		SX1->X1_DEF02    := _aPerg[_ni][8]
		SX1->X1_DEF03    := _aPerg[_ni][9]
		SX1->X1_F3       := _aPerg[_ni][10]
		SX1->X1_CNT01    := _aPerg[_ni][11]  
		SX1->X1_CNT02	 := _aPerg[_ni][12]  
		SX1->X1_CNT03	 := _aPerg[_ni][13]  
		SX1->(MsUnLock())
	EndIf
Next _ni

Return

Static Function Selecao()

aEstru2 := {}

aadd(aEstru2,{"OK"         ,'C',02,0})
aadd(aEstru2,{"CODLMT"     ,'C',46,0})
aadd(aEstru2,{"CODINT"     ,'C',15,0})
aadd(aEstru2,{"INVOICE"    ,'C',10,0})
aadd(aEstru2,{"PEDIDO"     ,'C',06,0})
aadd(aEstru2,{"ITEMPC"     ,'C',04,0})

oTemptable := FWTemporaryTable():New( "TRP")
oTemptable:SetFields( aEstru2 )
oTempTable:AddIndex("index1", {"COD"} )
oTempTable:Create()

//arq2 := criatrab(aEstru2,.T.)
If Select("TRP") <> 0
	TRP->(dbCloseArea())
End
use &arq2 alias TRP NEW
index on CODLMT to &arq2

cQry1 :=  " SELECT * FROM "+RetSqlName("ZZ1") + " ZZ1 "
cQry1 +=  " WHERE D_E_L_E_T_ = ' ' "
cQry1 +=  " AND ZZ1_FILIAL = '"+xFilial("ZZ1")+"' "
cQry1 +=  " AND ZZ1_INVOIC = '"+alltrim(_cInvoice)+"' "
cQry1 +=  " AND ZZ1_SERIE = ' ' "
cQry1 +=  " ORDER BY ZZ1_ORDER, ZZ1_LINE "

TCQUERY cQry1 NEW ALIAS "TRB"

DbSelectArea("TRB")
TRB->(DbGoTop())

while TRB->(!eof())
	
   dbSelectArea("TRP")
   RecLock("TRP",.T.)
   TRP->OK 	:= "  "    
   TRP->CODLMT  := TRB->ZZ1_DESCRI
   TRP->CODINT  := TRB->ZZ1_LMTCOD
   TRP->INVOICE := TRB->ZZ1_INVOIC
   TRP->PEDIDO  := TRB->ZZ1_ORDER
   TRP->ITEMPC  := TRB->ZZ1_LINE
   MsUnLock()
   dbSelectArea("TRB")
   TRB->(dbSkip())
Enddo   

DbSelectArea("TRB")
TRB->(DbCloseArea())

Return

Static Function Mostra_old(_xprod)

// Define campos que irao aparecer no BROWSE
aCampos := {}
aadd(acampos ,{"OK"     ,"  "  ,"   " })
aadd(acampos ,{"CODLMT" ,"@S20","Produto" })
aadd(acampos ,{"CODINT" ,"@!"  ,"Cod.Inteligente"  })
aadd(acampos ,{"INVOICE","@!"  ,"Invoice" })
aadd(acampos ,{"PEDIDO" ,"@!"  ,"Pedido" })
aadd(acampos ,{"ITEMPC" ,"@!"  ,"Item PC"    })

dbSelectArea("TRP")
TRP->(dbGotop())
cMarca := GetMark()
cCadastro := "Selecione Produto: "+Alltrim(_xProd)+" da Invoice"
aRotina    := {{OemToAnsi("Selecione")  ,'Alert("Teste")',0,3}} //'ExecBlock("Efcomp")',0,3}}

//MarkBrowse("TRP1","I1_OK","TRP1->I1_OK",aCampos,.f.,cMarca)
//MarkBrowse("TRP","OK",,aCampos,,cMarca)
MarkBrowse("TRP","OK","TRP->OK",aCampos,.f.,cMarca)
return

Static Function MostraSel(_xprod,nIt)

Local cTitulo := "Selecione Produto: "+_xProd+" ITEM da NFE: "+strzero(nIT,3)
Local vVetor1:= {" CODLMT      C๓d.Inteligente   Invoice  Pedido /Item PC"} 
Local aOptions := {}  
Local oDlg, oButton, oRadio, nRadio:=1           
Local oSbr
Local nRadio := 1                     
Local oDlgAlEs,oScroll,nx,cMemo := Space(1),nMaxL := 0
Local nCount := 0

dbSelectArea("TRP")
Count to nCount
TRP->(dbGoTop())
_cReg3 := "{" 
nnn := 1
While TRP->(!Eof())         
    _cReg := TRP->CODLMT+space(10)+TRP->CODINT+space(10)+TRP->INVOICE+space(10)+TRP->PEDIDO+"/"+TRP->ITEMPC
    //aadd(aOptions,{_cReg})
    If nnn == 1
       _cReg3 += "'"+_cReg+"'"
    Else
       _cReg3 += ",'"+_cReg+"'"
    Endif   
    TRP->(dbSkip())
    nnn++
Enddo                       
_cReg3 += "}"
aOptions := (&_cReg3)
while .t.

  DEFINE DIALOG oDlgAlEs TITLE cTitulo FROM 0,0 TO 300,650 Pixel  
   //	@ 6,7 SCROLLBOX oSbr VERTICAL SIZE 94,206 OF oDlgAlEs BORDER

	oFont         := TFont():New('Courier new',,-18,.T.)
	oScroll       := TScrollBox():New(oDlgAlEs,01,01,10,200,.T.,.T.,.T.) //50,450,.T.,.T.,.T.)
	oScroll:Align := CONTROL_ALIGN_ALLCLIENT

	For nx := 1 To Len(vVetor1)
		TSay():New((nX-1)*10,03,&("{||'"+vVetor1[nx]+"'}"),oScroll,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE)
	Next nx

	oRadio := TRadMenu():Create (oScroll,,10,10,aOptions,,,,,,,,300,12,,,,.F.) 
	oRadio:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)}                    
//    nn:= nCount * 10
//	@ nn+10,150 BUTTON oButton PROMPT "Fechar" OF oDlgAlEs PIXEL ACTION oDlgAlEs:End()

  Activate MsDialog oDlgAlEs Centered  	

  If MsgYesNo("Voce escolheu "+aOptions[nRadio]+" , correto?","Confirma" )  .and. nRadio > 0
    _xInv := substr(aOptions[nRadio],82,10)
    _xPed := substr(aOptions[nRadio],102,6)
    _xIte := substr(aOptions[nRadio],109,4)
//    40+10+15+10+10+6+1+4
	dbSelectArea("ZZ1")
	dbSetOrder(1)
	If dbSeek(xFilial("ZZ1")+PADR(_xInv,10))
		While !ZZ1->(Eof()) .and. ZZ1->ZZ1_FILIAL == xFilial("ZZ1") .and. Alltrim(ZZ1->ZZ1_INVOIC) == Alltrim(_xInv)
               If (_xPed+_xIte) == ZZ1->ZZ1_ORDER+ZZ1->ZZ1_LINE
                  RecLock("ZZ1",.f.)
				  ZZ1->ZZ1_SERIE  := "Z" 
                  MsUnlock()            
                  AADD(_aRestoreDad,{Recno()})
                  Exit
               Endif   
			ZZ1->(dbSkip())
		Enddo
    Endif    
     //ADEL(aOptions, nRadio)  
     Exit
  Else
	If nRadio == 0
		Alert("Nใo foi identificado produtos para invoice disponํvel para processo de importa็ใo XML","Verificar com TI!")
		Return("")
	Endif	

    If MsgYesNo("Deseja abandonar o processo de importa็ใo?","Confirma" )     
       If Len(_aRestoreDad) > 0
          For ii := 1  TO LEN(_aRestoreDad)
             dbSelectArea("ZZ1")
             dbSetOrder(0)
             _nRec := _aRestoreDad[ii][1]
             dbgoto(_nRec)
             If Alltrim(ZZ1->ZZ1_SERIE) == "Z" //.AND. Empty(ALLTRIM(ZZ1->ZZ1_NFISCA))
                RecLock("ZZ1",.f.)
                ZZ1->ZZ1_SERIE := " "
                MsUnLock()
             Endif              
          Next
       Endif
		Return("")
    Endif   
  Endif
Enddo
Return(aOptions[nRadio])
