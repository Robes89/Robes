#include "rwmake.ch"
#DEFINE ENTER CHR(13) + CHR(10) 
//--------------------------------------------------------------------------
// Pto Entrada : MSD2460I        Autor : Sidnei Naconesky    Dt : 26/02/02
// Descricao   : Este programa ira realizar a transferencia (SD3), automa-
//               tica a partir do Local Destino e TES contida no parametro.
//--------------------------------------------------------------------------
// Declara Variaveis             
//#FAP20170124
//REMESSA FÍSICA - GERAÇÃO NFS    SAÍDA DO 01 ALIMENTA 02 OU 03     

User Function MSD2460()                                

PRIVATE NHDLPRV
PRIVATE LCRIAHEADER := .T.
PRIVATE CLOTEEST 
PRIVATE N
private TOTAL := 0

Private cCusMed := GetMv('MV_CUSMED')   ; aLog          := {}
cCodOrig        := SD2->D2_COD          ; cLocOrig		:= SD2->D2_LOCAL
nQuant260       := SD2->D2_QUANT        ; cDocto        := SD2->D2_DOC
dEmis260        := SD2->D2_EMISSAO      ; nQuant260D    := 0
cNumLote        := ''                   ; cLoteDigi		:= ''
dDtValid        := CTOD('  /  /  ')     ; cNumSerie		:= ''
cLoclzOrig      := ''                   ; cCodDest      := SD2->D2_COD
cLocDest        := "02"			        ; cLocLzDest    := ''
lEstorno        := .F.                  ; nRecOrig		:= 0
nRecDest        := ''                   ; cPrograma		:= '#MSD2460'
_aSvAlias       := {Alias(),IndexOrd(),Recno()}
AREGSD3 := {}
lD3_CODLMT		:= .F.

// Valida se ira fazer a transferencia
If !Empty(cLocDest) .And. ( Substr(SD2->D2_CF,2,3) $ "917" )

	nTotQtd := 0
	lD3_CODLMT	:= .T.
	cLocOrig		:= "01"
	cLocDest        := "02"   //#FAP20170124
    dbSelectArea("SB2")           
    dbSetOrder(1)
    If dbSeek(xFilial("SB2") + SD2->D2_COD + cLocOrig)
       nTotQtd := SB2->B2_QATU - SB2->B2_QEMP
    Endif 
    If nTotQtd > 0 .and. nTotQtd >= nQuant260
	   a260Processa(cCodOrig,cLocOrig,nQuant260,cDocto,dEmis260,nQuant260D,cNumLote,cLoteDigi,dDtValid,cNumSerie,cLoclzOrig,cCodDest,cLocDest,cLocLzDest,lEstorno,nRecOrig,nRecDest,cPrograma)
       aAdd(aLog,{cCodOrig,cLocOrig,nQuant260,cLocDest})
    Else
	   Alert("O Produto "+Alltrim(SD2->D2_COD)+" do armazém "+Alltrim(cLocOrig)+" selecionado não contem saldo suficiente para processamento."+ ENTER + ENTER+;
             "Saldo atual: "+Str(nTotQtd,12,2)+", Quantidade processada: "+str(SD2->D2_QUANT,12,2) +ENTER+"MSD2460-1" )
    Endif   
Endif                  

If !Empty(cLocDest) .And.  Substr(SD2->D2_CF,2,3) $ "912"  //.or. ( Substr( SD2->D2_CF , 2 , 3 ) $ "949" .and. ;
	//SF4->( DbSeek( xFilial( "SF4" ) + SD2->D2_TES ) ) .and. "MOSTRUARIO" $ Upper( SF4->F4_TXTUSER ) )
	lD3_CODLMT	:= .T.
	cLocOrig		:= "01"
	cLocDest        := "03"
	nTotQtd         := 0
	dbSelectArea("SB2")           
    dbSetOrder(1)
    If dbSeek(xFilial("SB2") + SD2->D2_COD + cLocOrig)
       nTotQtd := SB2->B2_QATU - SB2->B2_QEMP
    Endif 
    If nTotQtd > 0 .and. nTotQtd >= nQuant260
	   a260Processa(cCodOrig,cLocOrig,nQuant260,cDocto,dEmis260,nQuant260D,cNumLote,cLoteDigi,dDtValid,cNumSerie,cLoclzOrig,cCodDest,cLocDest,cLocLzDest,lEstorno,nRecOrig,nRecDest,cPrograma)
       aAdd(aLog,{cCodOrig,cLocOrig,nQuant260,cLocDest})
    Else
	   Alert("O Produto "+Alltrim(SD2->D2_COD)+" do armazém "+Alltrim(cLocOrig)+" selecionado não contem saldo suficiente para processamento."+ ENTER + ENTER+;
             "Saldo atual: "+Str(nTotQtd,12,2)+", Quantidade processada: "+str(SD2->D2_QUANT,12,2) +ENTER+"MSD2460-2")
    Endif   
Endif                                                       

If 	lD3_CODLMT
    dbSelectArea("SB1")
    dbSetOrder(1)
    dbSelectArea("SD3")
    dbSetOrder(2)
    dbSeek(xFilial("SD3") + cDocto)
	Do While !Eof() .AND. (SD3->D3_DOC == cDocto) .AND. SD3->D3_EMISSAO == SD2->D2_EMISSAO
		SB1->(dbSeek(xFilial("SB1") + SD3->D3_COD))
		RecLock("SD3",.F.)
		SD3->D3_CODLMT := SB1->B1_CODLMT
		msUnlock()
		dbSkip()
	Enddo
	dbSelectArea("SB2")
	dbSeek(xFilial("SB2") + SD1->D1_COD)
	do While !Eof() .and. B2_FILIAL == xFilial("SB2") .and. B2_COD == SD1->D1_COD
		RecLock("SB2",.F.)
		B2_CODLMT := SB1->B1_CODLMT
		MsUnlock()
		dbSkip()
	Enddo
Endif                                         

// Le campo dos itens do PV / Req / Ped_cliente
cOper := SC6->C6_CODLMT
cReq  := SC6->C6_REQCLI
cPedCli := SC6->C6_PEDCLI
cCodCli := SC6->C6_CODCLI       //#FAP20170124                                     
// Grava no Item NF o conteudo
Reclock("SD2",.f.)
SD2->D2_CODLMT := cOper
SD2->D2_REQCLI := cReq
SD2->D2_PEDCLI := cPedCli
SD2->D2_XCODCLI := cCodCli     //#FAP20170124
MsUnlock()

// Tratamento do pedido Estimado
If !Empty(SC6->C6_NUMPEDP)

	// Wilson - 15/08/05
	// Quando pedido estimado for atendido 100%, gravar no C5_NOTA o nº da última NF

	aArea_SC5	:= SC5->( GetArea() )
	aArea_SC6	:= SC6->( GetArea() )
	nQtd_Ven	:= 0
	nQtd_Ent	:= 0

	dbSelectArea("SC6")
	nnPed	:= SC6->C6_NUMPEDP
	cItemPE	:= SC6->C6_ITEMPE
	ccCod	:= SD2->D2_COD

	// Atualiza item do pedido estimado
	SC6->(dbSetOrder(1))
	SC6->(dbSeek(xFilial("SC6") + nnPed + cItemPE + ccCod ))

	While !SC6->( Eof() ) .and.	SC6->C6_FILIAL	== xFilial() .and. ;
								SC6->C6_NUM		== nnPed .and. ;
								SC6->C6_ITEM	== cItemPE .and. ;
								SC6->C6_PRODUTO	== ccCod
		Reclock("SC6",.f.)
		SC6->C6_DATFAT	:= SD2->D2_EMISSAO
		SC6->C6_NOTA	:= SD2->D2_DOC
		SC6->C6_SERIE	:= SD2->D2_SERIE
		SC6->( MsUnlock() )
		SC6->(dbSkip())
	Enddo

	// Verifica se pedido estimado atendido 100%, atualiza SC5
	SC6->(dbSetOrder(1))
	SC6->(dbSeek(xFilial("SC6") + nnPed ) )

	While !SC6->( Eof() ) .and.	SC6->C6_FILIAL	== xFilial() .and. ;
								SC6->C6_NUM		== nnPed
		nQtd_Ven	+= SC6->C6_QTDVEN
		nQtd_Ent	+= SC6->C6_QTDENT
		SC6->(dbSkip())
	Enddo

	If nQtd_Ent >= nQtd_Ven
		SC5->( DbSetOrder( 1 ) )
		If SC5->( DbSeek( xFilial( "SC5" ) + nnPed ) )
			RecLock( "SC5" )
			SC5->C5_NOTA	:= SD2->D2_DOC
			SC5->C5_SERIE	:= SD2->D2_SERIE
			SC5->( MsUnLock() )
		EndIf
	EndIf

	RestArea( aArea_SC5 )
	RestArea( aArea_SC6 )

Endif
//Grava dados para gerar as informacoes nas tags da FORD e ANFAVEA no xml de saida
U_CPLANFAVE()

// Retorna Area de Trabalho
DbSelectArea(_aSvAlias[1])
DbSetOrder(_aSvAlias[2])
DbGoTo(_aSvAlias[3])

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CPLANFAVE ºAutor  ³ Tanimoto           º Data ³  29/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada apos gravacao do item da nota fiscal de   º±±
±±º          ³ saida utilizado para gravar informacoes nos arquivos CDR e º±±
±±º          ³ CDS de compelmento da NF para gerar tags da ANFAVEA da FORDº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NIKEN                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CPLANFAVE()
Local _aArea	:= GetArea()
Local _cCliente	:= SF2->F2_CLIENTE
Local _cLoja	:= SF2->F2_LOJA
Local _cNumero	:= SF2->F2_DOC
Local _cSerie	:= SF2->F2_SERIE
Local _cEspecie	:= SF2->F2_ESPECIE
Local _cCond	:= SF2->F2_COND
Local _cTipo	:= SF2->F2_TIPO
Local _cProduto	:= SD2->D2_COD
Local _cItem	:= SD2->D2_ITEM
Local _lAnfavea	:= .F.
Local _cPedCom 	:= ""
Local _cCditem 	:= ""
Local _cFabrica	:= ""

If _cTipo=="N" //SOMENTE TIPO DE NOTA DE SAIDA NORMAL
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+_cCliente+_cLoja)
	If Found()
		If SubStr(SA1->A1_CGC,1,8)=="03470727" //APENAS PARA FORD
			_cFabrica := Substr(SA1->A1_FABRICA,1,3)
			_lAnfavea := .T.
			If Empty(_cFabrica)
				MsgAlert("NAO FOI ENCONTRADO DADOS PARA PREENCHIMENTO DA TAG ANFAVEA DA FORD, COMUNICAR COMERCIAL PARA PREENCHER CODIGO DA FABRICA NO CADASTRO DA FORD E REFATURAR ESTA NOTA","ATENCAO!!!" )
				Return
			EndIf
  		Else
			Return
  		EndIf
  	Else
		Return
  	EndIf
Else
	Return
EndIf

If _lAnfavea
	dbSelectArea("SA7")
	dbSetOrder(1) 
	dbSeek(xFilial("SA7")+_cCliente+_cLoja+_cProduto)
	If Found()
	    dbSelectArea("CDR")
	    dbSetOrder(1) //CDR_FILIAL, CDR_TPMOV, CDR_DOC, CDR_SERIE, CDR_CLIFOR, CDR_LOJA
	    dbSeek(xFilial("CDR")+"S"+_cNumero+_cSerie+_cCliente+_cLoja)
	    If !Found()
	    	dbSelectArea("CDR")
	    	RecLock("CDR",.T.)
	    	Replace CDR_FILIAL 	With	xFilial("CDR")
	    	Replace CDR_TPMOV 	With	"S"
	    	Replace CDR_DOC   	With	_cNumero
	    	Replace CDR_SERIE 	With	_cSerie
	    	Replace CDR_ESPEC 	With	_cEspecie
	    	Replace CDR_CLIFOR 	With	_cCliente
	    	Replace CDR_LOJA 	With	_cLoja
	    	Replace CDR_VERSAO 	With	"00"
	    	Replace CDR_CDTRAN	With	""
	    	Replace CDR_NMTRAN	With	""
	    	Replace CDR_CDRECP	With	""
	    	Replace CDR_NMRECP	With	""
	    	Replace CDR_CDENT	With	_cFabrica
	    	Replace CDR_DTENT	With	Ctod("  /  /  ")
	    	Replace CDR_NUMINV	With	""
	    	MsUnlock()
	    EndIf
		_cPedCom := Alltrim(SA7->A7_PEDIDO)
		_cCditem := Alltrim(SA7->A7_CODCLI)
		If Empty(_cPedCom) .or. Empty(_cCditem)
			MsgAlert("NAO FOI ENCONTRADO DADOS PARA PREENCHIMENTO DA TAG ANFAVEA DA FORD, COMUNICAR COMERCIAL PARA REVISAR CADASTRO PRODUTO X CLIENTES E REFATURAR ESTA NOTA","ATENCAO!!!" )
		EndIf
		RecLock("CDS",.T.)
		Replace CDS_FILIAL	With	xFilial("CDS")
		Replace CDS_TPMOV	With	"S"
		Replace CDS_DOC		With	_cNumero
		Replace CDS_SERIE	With	_cSerie
		Replace CDS_ESPEC	With	_cEspecie
		Replace CDS_CLIFOR	With	_cCliente
		Replace CDS_LOJA	With	_cLoja
		Replace CDS_ITEM	With	_cItem
		Replace CDS_PRODUT	With	_cProduto
		Replace CDS_PEDCOM	With	_cPedCom
		Replace CDS_SGLPED	With	""
		Replace CDS_SEPPEN	With	""
		Replace CDS_TPFORN	With	""
		Replace CDS_UM		With	"PC"
		Replace CDS_DTVALI	With	Ctod("  /  /  ")
		Replace CDS_PEDREV	With	""
		Replace CDS_CDPAIS	With	""
		Replace CDS_PBRUTO	With	0.00
		Replace CDS_PLIQUI	With	0.00
		Replace CDS_TPCHAM	With	""
		Replace CDS_NUMCHA	With	""
		Replace CDS_DTCHAM	With	""
		Replace CDS_QTDEMB	With	0.00
		Replace CDS_QTDIT	With	0.00
		Replace CDS_LOCENT	With	""
		Replace CDS_PTUSO	With	""
		Replace CDS_TPTRAN	With	""
		Replace CDS_LOTE	With	""
		Replace CDS_CPI		With	""
		Replace CDS_NFEMB	With	""
		Replace CDS_SEREMB	With	""
		Replace CDS_CDEMB	With	""
		Replace CDS_AUTFAT	With	""
		Replace CDS_CDITEM	With	alltrim(_cCditem)
	    MsUnlock()
	Else
		MsgAlert("NAO FOI ENCONTRADO DADOS PARA PREENCHIMENTO DA TAG ANFAVEA DA FORD, COMUNICAR COMERCIAL PARA PREENCHER CADASTRO PRODUTO X CLIENTES E REFATURAR ESTA NOTA","ATENCAO!!!" )
	EndIf
EndIf

Return()