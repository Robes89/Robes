
// ALTERADO NA PRESTSERV COM TRATAMENTO PODER DE TERCEIROS

#include "rwmake.ch"
#include "topconn.ch"
#include "Colors.ch"
#include "Font.ch"
#include "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"

//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
//Static cCRLF := CRLF

/*
|-----------------------------------------------------------------------------------|
|  Programa : EXECPVEN                                     Data : 21/01/2020        |
|-----------------------------------------------------------------------------------|
|  Cliente  : PRESTSERV                                                             |
|-----------------------------------------------------------------------------------|
|  Responsável Protheus no Cliente  : Renato Carli                                  |
|-------------------------------------------r----------------------------------------|
|  Uso      : Importação de Pedido de Venda 									    |
|-----------------------------------------------------------------------------------|
|  Autor    : Igor Pedracolli - CRM SERVICES                                        |
|-----------------------------------------------------------------------------------|
| Tabelas Envolvidas  : Cabeçalho de Pedido de Venda : SC5                          |
|                       Itens de Pedido de Venda     : SC6                          |
|-----------------------------------------------------------------------------------|
*/

User Function EXECPVEN()

	Private oLeTxt                         // Janela de Dialogo
	Private Arquivo 	:= Space(40)           // Arquivo Texto Selecionado
	Private cArqTRB 	:= " "                  // Arquivo de Trabalho Temporario
	Private cArqEdi 	:= " "                  // Arquivo Texto a Processar
	Private cArqCop 	:= " "                  // Arquivo de Copia
	Private lGeraprv	:= " "
	Private dDataprv	:= " "
	Private lExec		:= .T.
	Private _nTot   	:= 0
	Private _cType  	:= " "
	Private _cPerg   	:= "PSCSVPED"
	Private _cPath     	:= ''
	Private _cFile     	:= ''
	Private _cEOL      	:= "CHR(13)+CHR(10)"
	Private aRegs  	   	:= {}
	Private aHelpPor   	:= {}

	Aadd(aRegs,{"Cliente ?      ","Cliente ?       ","Cliente ?      ","mv_ch1","C",06,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","","","",aHelpPor,aHelpPor,aHelpPor})
	Aadd(aRegs,{"Loja ?         ","Loja ?          ","Loja ?         ","mv_ch2","C",02,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor})
	Aadd(aRegs,{"Cond.Pagto ?   ","Cond.Pagto ?    ","Cond.Pagto ?   ","mv_ch3","C",03,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","SE4","","","","","",aHelpPor,aHelpPor,aHelpPor})
	Aadd(aRegs,{"Tes de Saida ? ","Tes de Saida ?  ","Tes de Saida ? ","mv_ch4","C",03,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","SF4","","","","","",aHelpPor,aHelpPor,aHelpPor})

	fAjusSX1(_cPerg,aRegs)
	Pergunte(_cPerg,.F.)

	fGerPed0()

Return

//---------------------------------------------------------------------------------|
//  Programa : fGerPed0                                       Data : 21/01/2020    |
//---------------------------------------------------------------------------------|

Static Function fGerPed0()

	Define MsDialog oDlga Title "Geração Pedido de Venda" From 0,0 To 250,530 Pixel
	Define Font oBold Name "Arial" Size 0,-13 Bold

	@ 000,000 Bitmap oBmp ResName "LOGIN" Of oDlga Size 30, 120 NoBorder When .F. Pixel
	@ 010,060 Say OemtoAnsi("Esta rotina tem como objetivo ler um arquivo EXCEL e gerar")   Font oBold SIZE 200,09 PIXEL
	@ 020,060 Say OemtoAnsi("Pedido de Venda no sistema Protheus.					   ")   Font oBold SIZE 200,09 PIXEL
	@ 030,060 Say OemtoAnsi(" ")   															Font oBold SIZE 200,09 PIXEL
	@ 040,060 Say OemtoAnsi(" ")   															Font oBold SIZE 200,09 PIXEL
	@ 090,060 Say OemtoAnsi("Arquivo selecionado : ")  										Font oBold SIZE 200,09 PIXEL
	@ 090,140 Say +_cFile							  										Font oBold SIZE 200,09 PIXEL
	@ 105,070 Button "Parâmetros"  Size 40,13 Pixel Of oDlga Action Pergunte(_cPerg,.T.)
	@ 105,120 Button "Sel.Arquivo" Size 40,13 Pixel Of oDlga Action fSelArq()
	@ 105,170 Button "Gera Pedido" Size 40,13 Pixel Of oDlga Action Processa({||fGerPed1(),,"Gerando Pedido de Venda. Aguarde..."})
	@ 105,220 Button "Sair"        Size 40,13 Pixel Of oDlga Action oDlga:End()

	Activate MsDialog oDlga Centered

Return

//---------------------------------------------------------------------------------|
//  Programa : fSelArq                                       Data : 21/01/2020     |
//---------------------------------------------------------------------------------|

Static Function fSelArq()

	Private _cType := " "

	_cType := "*.CSV | *.csv"
	_cFile := cGetFile(_cType, OemToAnsi("Selecione arquivo no formato CSV a ser importado..."))

	If Empty(_cFile)
		Return
	EndIf

	nHdl := fopen(_cFile,0)
	_nTot:= fSeek(nHdl,0,2)

	fClose(nHdl)

	If _nTot <= 0
		Aviso("","Arquivo corrompido ou já está sendo utilizado em outro processo. ",{"OK"},2,"Problema...")
	EndIf

Return


//-----------------------------------------------------------------------------------|
//  Programa : fGerPed1                                          Data : 21/01/2020   |
//-----------------------------------------------------------------------------------|

Static Function fGerPed1()

	Local aArea     := GetArea()
	Local aAreaSc5  := GetArea()
	Local aAreaSc6  := GetArea()
	Local nX		:= 0
	Local cNewPed   := " "
	Local _cFilAnt  := SM0->M0_CODFIL
	Local aCabec	:= {}
	Local aCampoSC6	:= SC6->(DbStruct())

	PRIVATE _cCliente 		:= MV_PAR01
	PRIVATE _cLoja    		:= MV_PAR02
	PRIVATE _cCondPag 		:= MV_PAR03
	PRIVATE _cTesSai  		:= MV_PAR04
	PRIVATE _nLote			:= ""
	PRIVATE _cProd			:= SPACE(TamSX3("B1_COD")[1])
	PRIVATE _cLocal			:= SB1->B1_LOCPAD
	PRIVATE	_nDocOri		:= ""
	PRIVATE	_nSerOri    	:= ""
	PRIVATE _nItemOri		:= ""
	PRIVATE	_nDtValid		:= CTOD("  /  /    ")
	PRIVATE	_nIdent			:= ""
	PRIVATE _nLoteCtl		:= ""
	PRIVATE	_nPrcv			:= 0.01
	PRIVATE	_nPrTot			:= 0
	PRIVATE _nQtdPv   		:= 0
	PRIVATE xlEmpPrev  		:= If(SuperGetMV("MV_QTDPREV")== "S",.T.,.F.)
	PRIVATE aLinha			:= {}
	PRIVATE aItens			:= {}
	PRIVATE aTXT      		:= {}
	PRIVATE lMsErroAuto		:= .F.
	PRIVATE _nQtdPedido 	:= 0
	PRIVATE _cItem			:= "01"

	If Empty(_cFile)
		Aviso("","Nenhum arquivo foi selecionado. ",{"OK"},2,"Problema...")
		Return
	EndIf

	cNewPed := GetSX8Num("SC5","C5_NUM")
	SC5->(dbsetorder(1))

	while sc5->(DbSeek(xFilial("SC5")+cNewPed))
		cNewPed := GetSX8Num("SC5","C5_NUM")
	enddo

	ConfirmSx8()

	sa1->(dbsetorder(1))
	sa1->(dbseek(xFilial("SA1")+_cCliente+_cLoja))

	aadd(aCabec,{"C5_FILIAL"     , _cFilAnt	      	 	, Nil})
	aadd(aCabec,{"C5_NUM"        , cNewPed				, Nil})
	aadd(aCabec,{"C5_TIPO"       , "N" 	                , Nil})
	aadd(aCabec,{"C5_CLIENTE"    , _cCliente            , Nil})
	aadd(aCabec,{"C5_LOJACLI"    , _cLoja               , Nil})
	aadd(aCabec,{"C5_CLIENT"     , _cCliente            , Nil})
	aadd(aCabec,{"C5_LOJAENT"    , _cLoja               , Nil})
	aadd(aCabec,{"C5_CONDPAG"    , _cCondPag            , Nil})
	aadd(aCabec,{"C5_VEND1"      , sa1->a1_vend         , Nil})
	aadd(aCabec,{"C5_EMISSAO"    , dDatabase            , Nil})
	aadd(aCabec,{"C5_TPFRETE"    , "C"                  , Nil})
	aadd(aCabec,{"C5_TPCARGA"    , "2"                  , Nil})
	aadd(aCabec,{"C5_MENPAD"     , ''	                , Nil})

	sb1->(dbsetorder(1))
	sf4->(dbsetorder(1))

	aPosCampos:= Array(Len(aCampoSC6))

	FT_FUse(_cFile)
	FT_FGOTOP()

	cLinha 	:= FT_FREADLN()
	nPos	:=	0
	nAt		:=	1

	While nAt > 0

		nPos++
		nAt	:=	AT(";",cLinha)

		If nAt == 0
			cCampo := cLinha
		Else
			cCampo	:=	Substr(cLinha,1,nAt-1)
		Endif

		nPosCpo	:=	aScan( aCampoSC6, { |x| x[1] == cCampo } )

		If nPosCPO > 0
			aPosCampos[nPosCpo]:= nPos
		Endif

		cLinha	:=	Substr(cLinha,nAt+1)

	Enddo

	FT_FSKIP()

	While !FT_FEOF()

		cLinha := FT_FREADLN()

		aAdd(aTxt,{})

		nCampo := 1

		While At(";",cLinha)>0

			aAdd(aTxt[Len(aTxt)],Substr(cLinha,1,At(";",cLinha)-1))
			nCampo ++
			cLinha := StrTran(Substr(cLinha,At(";",cLinha)+1,Len(cLinha)-At(";",cLinha)),'"','')
		End

		If Len(AllTrim(cLinha)) > 0
			aAdd(aTxt[Len(aTxt)],StrTran(Substr(cLinha,1,Len(cLinha)),'"','') )
		Else
			aAdd(aTxt[Len(aTxt)],"")
		Endif

		FT_FSKIP()

	EndDo

	FT_FUSE()

	If Len(aTXT) > 0

		For nX := 01 To Len(aTxt)

			aLinha := {}

			_cProd := PADR( aTxt[nX,1] , TAMSX3("B1_COD")[1] )

			SB1->(dbsetorder(1))
			SB1->(dbGoTop())

			IF SB1->(MsSeek(xFilial("SB1") + ALLTRIM(_cProd)))

				_nQtdPedido := Val(aTxt[nX,3])

				U_BUSCALOTE()  // Tratativa para consultar o lote que será usado

				aAdd(aLinha , {"C6_ITEM" 		, _cItem									, Nil } )
				aAdd(aLinha , {"C6_PRODUTO" 	, aTxt[nX,1]								, Nil } )
				aAdd(aLinha , {"C6_DESCRI" 		, SUBS(aTxt[nX,2],1,30)						, Nil } )
				aAdd(aLinha , {"C6_QTDVEN"  	, _nQtdPedido	    						, Nil } )
				aAdd(aLinha , {"C6_PRCVEN"  	, _nPrcv                             		, Nil } )

				IF _nPrcv > 0.01 .and. _nPrTot <> 0
					aAdd(aLinha , {"C6_VALOR"  		, _nPrTot									, Nil } )
				ENDIF

				aAdd(aLinha , {"C6_TES" 		, _cTesSai									, Nil } )
				aAdd(aLinha , {"C6_LOCAL"   	, IF(!EMPTY(_cLocal),_cLocal,SB1->B1_LOCPAD), Nil } )
				aAdd(aLinha , {"C6_ENTREG" 		, dDatabase /*Ctod(aTxt[nX,5])*/			, Nil } )
				aAdd(aLinha , {"C6_QTDLIB"   	, IF(!Empty(_nLoteCTL) , _nQtdPedido , 0) 	, Nil } )
				aAdd(aLinha , {"C6_LOTECTL" 	, _nLoteCtl									, Nil } )
				aAdd(aLinha , {"C6_DTVALID"		, _nDtValid									, Nil } )
				aAdd(aLinha , {"C6_NFORI"    	, _nDocORi									, Nil } )
				aAdd(aLinha , {"C6_SERIORI"		, _nSerOri									, Nil } )
				aAdd(aLinha , {"C6_ITEMORI"		, _nItemOri									, Nil } )
				aAdd(aLinha , {"C6_IDENTB6"		, _nIdent									, Nil } )
				aAdd(aLinha , {"C6_ZZPALLE" 	, VAL(aTxt[nX,4])							, Nil } )

				aAdd(aItens,aLinha)

				_nQtdPedido	   	:= 0
				_nPrcv         	:= 0.01
				_nPrTot			:= 0
				_cLocal		   	:= SB1->B1_LOCPAD
				_nLoteCtl		:= ""
				_nDtValid		:= CTOD("  /  /    ")
				_nDocORi		:= ""
				_nSerOri		:= ""
				_nItemOri		:= ""
				_nIdent			:= ""
				_cTesSai  		:= MV_PAR04

				_cItem := Soma1(_cItem)

			ELSE
				Alert("Produto nao encontrado --> " + _cProd )
			ENDIF

		Next nX

		lMsErroAuto := .F.

		MsExecAuto({|x,y,z| Mata410(x,y,z)},aCabec,aItens,3)

		If lMsErroAuto
			MostraErro()
		Else
			MSGINFO("Foi gerado o Pedido de Venda No.: " + cNewPed , "Gerado com Sucesso !!!")
		Endif

	EndIf

	SC5->(RestArea(aAreaSC5))
	SC6->(RestArea(aAreaSC6))

	RestArea(aArea)

Return( Nil )

//-----------------------------------------------------------------------------------|
//  Programa : BUSCALOTE                                     Data : 21/06/2020       |
//-----------------------------------------------------------------------------------|
//  Descrição: BUSCA O LOTE PARA USAR NO PEDIDO - FIFO						         |
//-----------------------------------------------------------------------------------|
//  Autor    : RAFAEL AUGUSTO - CRM SERVICES  	 		                             |
//-----------------------------------------------------------------------------------|

User Function BUSCALOTE()

	lEmpPrev  		:= If(SuperGetMV("MV_QTDPREV")== "S",.T.,.F.)
	_nPrcv         	:= 0.01
	_nPrTot			:= 0
	_cLocal		   	:= SB1->B1_LOCPAD
	_nLoteCtl		:= ""
	_nDtValid		:= CTOD("  /  /    ")
	_nDocORi		:= ""
	_nSerOri		:= ""
	_nItemOri		:= ""
	_nIdent			:= ""
	_cTesSai  		:= MV_PAR04
	cQryB6			:= ""
	cQrySDA			:= ""
	_NSALDO			:= 0
	_aEnderecar	    := .F.

	IF SELECT("QRY_SB6") > 0
		QRY_SB6->(dbCloseArea())
	ENDIF

	//Criando a consulta que irá buscar os dados da nota fiscal original
	cQryB6 := " SELECT * FROM " + RetSqlName('SB6') + " SB6 "
	cQryB6 += " WHERE SB6.D_E_L_E_T_ = ' '"
	cQryB6 += " AND B6_FILIAL  = '" + FWxFilial('SB6') + "' "
	cQryB6 += " AND B6_PRODUTO = '" + _cProd     + "' "
	cQryB6 += " AND B6_ATEND <> 'S' "
	cQryB6 += " AND B6_SALDO >= '1' "
	cQryB6 += " Order By B6_EMISSAO asc"

	TCQuery cQryB6 New Alias 'QRY_SB6'

	("QRY_SB6")->(DBGoTop())
	//Se houver dados da consulta

	If ! QRY_SB6->(EoF())

		While ! QRY_SB6->(EoF())

			IF SELECT("QRY_SB8") > 0
				QRY_SB8->(dbCloseArea())
			ENDIF
			
			//Criando a consulta que irá buscar os dados do Produto
			cQuery := " SELECT * FROM " + RetSqlName('SB8') + " SB8 "
			cQuery += " WHERE "
			cQuery += "        B8_FILIAL  = '" + FWxFilial('SB8') + "' "
			cQuery += "        AND B8_PRODUTO = '" + _cProd + "' "
			cQuery += "        AND B8_LOTECTL = '" + QRY_SB6->B6_LOTECTL + "' "
			cQuery += "        AND SB8.D_E_L_E_T_ = ' ' "

			TCQuery cQuery New Alias 'QRY_SB8'

			//Se houver dados da consulta
			If ! QRY_SB8->(EoF())

				//Percorre todas as linhas da query
				While ! QRY_SB8->(EoF())

					//Pega o saldo
					_nSaldo := SB8Saldo(Nil, Nil, Nil, Nil, "QRY_SB8", lEmpPrev, .T.)

					IF _nSaldo < _nQtdPedido

						IF SELECT("QRY_SDA") > 0
							QRY_SDA->(dbCloseArea())
						ENDIF

						//Criando a consulta que irá buscar os dados do Produto
						cQrySDA := " SELECT * FROM " + RetSqlName('SDA') + " SDA "
						cQrySDA += " WHERE "
						cQrySDA += "        DA_FILIAL  = '" + FWxFilial('SDA') + "' "
						cQrySDA += "        AND DA_PRODUTO = '" + _cProd + "' "
						cQrySDA += "        AND DA_LOTECTL = '" + QRY_SB6->B6_LOTECTL + "' "
						cQrySDA += "        AND DA_DOC = '" + QRY_SB6->B6_DOC + "' "
						cQrySDA += "        AND DA_SALDO > '0' "
						cQrySDA += "        AND D_E_L_E_T_ = ' ' "

						MemoWrite( "c:\temp\testSave.txt", cQrySDA )

						TCQuery cQrySDA New Alias 'QRY_SDA'

						//Se houver dados da consulta
						If ! QRY_SDA->(EoF())

							_cTesSai 	:= "999"
							_nPrcv   	:= 0.01
							_aEnderecar	:= .T.

							EXIT

						ENDIF
					ENDIF

					QRY_SB8->(DbSkip())
				EndDo

			EndIf

			IF _nSaldo > 0 .and. _nSaldo >= _nQtdPedido .and. _aEnderecar == .F.

				_nIdent		:= QRY_SB6->B6_IDENT
				_nDtValid	:= QRY_SB6->B6_DTVALID
				_nDocORi	:= QRY_SB6->B6_DOC
				_nSerOri	:= QRY_SB6->B6_SERIE
				_cCliB8		:= QRY_SB6->B6_CLIFOR
				_cLoCli		:= QRY_SB6->B6_LOJA
				_nLoteCtl	:= QRY_SB6->B6_LOTECTL
				_cLocal		:= QRY_SB6->B6_LOCAL

				_nPrcv		:= Posicione("SD1",11,xFilial("SD4") + _nDocORi + _nSerOri + MV_PAR01 + MV_PAR02 + _cProd + _nLoteCtl,"D1_VUNIT")  //QRY_SB6->B6_PRUNIT - Rafael Augusto 07/06/21

				IF _nSaldo > _nQtdPedido
					_nPrTot	:= 0
				ELSE
					_nPrTot	:= Posicione("SD1",11,xFilial("SD4") + _nDocORi + _nSerOri + MV_PAR01 + MV_PAR02 + _cProd + _nLoteCtl,"D1_TOTAL")  //Rafael Augusto 07/06/21
				ENDIF

				_nItemOri	:= Posicione("SD1",11,xFilial("SD4") + _nDocORi + _nSerOri + MV_PAR01 + MV_PAR02 + _cProd + _nLoteCtl,"D1_ITEM")

				EXIT

			ELSEIF  _nSaldo > 0 .and. _nQtdPedido > _nSaldo .and. LEN("QRY_SB6") > 1  .and. _aEnderecar == .F.
				//================================================================

				_nIdent		:= QRY_SB6->B6_IDENT
				_nDtValid	:= QRY_SB6->B6_DTVALID
				_nDocORi	:= QRY_SB6->B6_DOC
				_nSerOri	:= QRY_SB6->B6_SERIE
				_cCliB8		:= QRY_SB6->B6_CLIFOR
				_cLoCli		:= QRY_SB6->B6_LOJA
				_nLoteCtl	:= QRY_SB6->B6_LOTECTL
				_cLocal		:= QRY_SB6->B6_LOCAL

				_nPrcv		:= Posicione("SD1",11, xFilial("SD4") + _nDocORi + _nSerOri + MV_PAR01 + MV_PAR02 + _cProd + _nLoteCtl,"D1_VUNIT")  //QRY_SB6->B6_PRUNIT - Rafael Augusto 07/06/21
				_nPrTot		:= Posicione("SD1",11,xFilial("SD4") + _nDocORi + _nSerOri + MV_PAR01 + MV_PAR02 + _cProd + _nLoteCtl,"D1_TOTAL")  //Rafael Augusto 07/06/21
				_nItemOri	:= Posicione("SD1",11,xFilial("SD4") + _nDocORi + _nSerOri + MV_PAR01 + MV_PAR02 + _cProd + _nLoteCtl,"D1_ITEM")

				aAdd(aLinha , {"C6_ITEM" 		, _cItem								, Nil } )
				aAdd(aLinha , {"C6_PRODUTO" 	, _cProd								, Nil } )
				aAdd(aLinha , {"C6_QTDVEN"  	, _nSaldo		    					, Nil } )
				aAdd(aLinha , {"C6_PRCVEN"  	, _nPrcv                             	, Nil } )
				aAdd(aLinha , {"C6_TES" 		, _cTesSai								, Nil } )
				aAdd(aLinha , {"C6_LOCAL"   	, IF(!EMPTY(_cLocal),_cLocal,SB1->B1_LOCPAD)	, Nil } )
				aAdd(aLinha , {"C6_QTDLIB"   	, _nSaldo			    			    , Nil } )
				aAdd(aLinha , {"C6_LOTECTL" 	, _nLoteCtl								, Nil } )
				aAdd(aLinha , {"C6_DTVALID"		, _nDtValid								, Nil } )
				aAdd(aLinha , {"C6_NFORI"    	, _nDocORi								, Nil } )
				aAdd(aLinha , {"C6_SERIORI"		, _nSerOri								, Nil } )
				aAdd(aLinha , {"C6_IDENTB6"		, _nIdent								, Nil } )
				aAdd(aLinha , {"C6_ITEMORI"		, _nItemOri								, Nil } )

				aAdd(aItens,aLinha)

				_cItem			:= Soma1(_cItem)
				aLinha 			:= {}
				_nPrcv         	:= 0.01
				_nPrTot			:= 0
				_cLocal		   	:= SB1->B1_LOCPAD
				_nLoteCtl		:= ""
				_nDtValid		:= CTOD("  /  /    ")
				_nDocORi		:= ""
				_nSerOri		:= ""
				_nIdent			:= ""
				_cTesSai  		:= MV_PAR04

				_nQtdPedido := _nQtdPedido - _nSaldo

				QRY_SB6->(DBSKIP())

			ELSEIF  _nSaldo > 0 .and. _nQtdPedido > _nSaldo .and. LEN("QRY_SB6") == 1  .and. _aEnderecar == .F.

				_nIdent		:= QRY_SB6->B6_IDENT
				_nDtValid	:= QRY_SB6->B6_DTVALID
				_nDocORi	:= QRY_SB6->B6_DOC
				_nSerOri	:= QRY_SB6->B6_SERIE
				_cCliB8		:= QRY_SB6->B6_CLIFOR
				_cLoCli		:= QRY_SB6->B6_LOJA
				_nLoteCtl	:= QRY_SB6->B6_LOTECTL
				_cLocal		:= QRY_SB6->B6_LOCAL

				_nPrcv		:= Posicione("SD1",11, xFilial("SD4") + _nDocORi + _nSerOri + MV_PAR01 + MV_PAR02 + _cProd + _nLoteCtl,"D1_VUNIT")  //QRY_SB6->B6_PRUNIT - Rafael Augusto 07/06/21
				_nPrTot		:= _nQtdPedido * _nPrcv //Posicione("SD1",11,xFilial("SD4") + _nDocORi + _nSerOri + MV_PAR01 + MV_PAR02 + _cProd + _nLoteCtl,"D1_TOTAL")  //Rafael Augusto 07/06/21
				_nItemOri	:= Posicione("SD1",11,xFilial("SD4") + _nDocORi + _nSerOri + MV_PAR01 + MV_PAR02 + _cProd + _nLoteCtl,"D1_ITEM")

			EndIf
			QRY_SB6->(DBSKIP())
		ENDDO

		IF Empty(_nDocORi) .and. _aEnderecar == .F.
			_cTesSai := "999"
			_nPrcv   := 0.01
		EndIF
	ELSE
		_cTesSai := "999"
		_nPrcv   := 0.01
	ENDIF
RETURN

//-----------------------------------------------------------------------------------|
//  Programa : fAjusSx1                                      Data : 21/01/2020       |
//-----------------------------------------------------------------------------------|
//  Descrição: GERA PERGUNTAS												         |
//-----------------------------------------------------------------------------------|
//  Autor    : IGOR PEDRACOLLI - CRM SERVICES   		                             |
//-----------------------------------------------------------------------------------|

Static Function fAjusSX1( cPerg, aRegs )

	Local aCposSX1	:= {}
	Local nX 		:= 0
	Local lAltera	:= .F.
	Local cKey		:= ""
	Local nj		:= 1
	Local aArea		:= GetArea()
	Local lUpdHlp	:= .T.

	aCposSX1:={"X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO",;
		"X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID",;
		"X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1","X1_CNT01",;
		"X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02",;
		"X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_CNT03",;
		"X1_VAR04","X1_DEF04","X1_DEFSPA4","X1_DEFENG4","X1_CNT04",;
		"X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5","X1_CNT05",;
		"X1_F3", "X1_GRPSXG", "X1_PYME","X1_HELP", "X1_PICTURE"}

	dbSelectArea( "SX1" )
	dbSetOrder(1)

	cPerg := PadR( cPerg , Len(X1_GRUPO) , " " )

	For nX:=1 to Len(aRegs)
		lAltera := .F.
		If MsSeek( cPerg + Right( Alltrim( aRegs[nX][11] ) , 2) )
			If ( ValType( aRegs[nX][Len( aRegs[nx] )]) = "B" .And. Eval(aRegs[nX][Len(aRegs[nx])], aRegs[nX] ))
				aRegs[nX] := ASize(aRegs[nX], Len(aRegs[nX]) - 1)
				lAltera := .T.
			Endif
		Endif
		If ! lAltera .And. Found() .And. X1_TIPO <> aRegs[nX][5]
			lAltera := .T.		// Garanto que o tipo da pergunta esteja correto
		Endif
		If ! Found() .Or. lAltera
			RecLock("SX1",If(lAltera, .F., .T.))
			Replace X1_GRUPO with cPerg
			Replace X1_ORDEM with Right(ALLTRIM( aRegs[nX][11] ), 2)
			For nj:=1 to Len(aCposSX1)
				If 	Len(aRegs[nX]) >= nJ .And. aRegs[nX][nJ] <> Nil .And.;
						FieldPos(AllTrim(aCposSX1[nJ])) > 0 .And. ValType(aRegs[nX][nJ]) != "A"
					Replace &(AllTrim(aCposSX1[nJ])) With aRegs[nx][nj]
				Endif
			Next nj
			MsUnlock()
		Endif
		cKey := "P."+AllTrim(X1_GRUPO)+AllTrim(X1_ORDEM)+"."
		If ValType(aRegs[nx][Len(aRegs[nx])]) = "A"
			aHelpSpa := aRegs[nx][Len(aRegs[nx])]
		Else
			aHelpSpa := {}
		Endif
		If ValType(aRegs[nx][Len(aRegs[nx])-1]) = "A"
			aHelpEng := aRegs[nx][Len(aRegs[nx])-1]
		Else
			aHelpEng := {}
		Endif
		If ValType(aRegs[nx][Len(aRegs[nx])-2]) = "A"
			aHelpPor := aRegs[nx][Len(aRegs[nx])-2]
		Else
			aHelpPor := {}
		Endif
		// Caso exista um help com o mesmo nome, atualiza o registro.
		lUpdHlp := ( !Empty(aHelpSpa) .and. !Empty(aHelpEng) .and. !Empty(aHelpPor) )
		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa,lUpdHlp)
	Next
	RestArea(aArea)

Return( Nil )


//----------------BACKUP DE ROTINA-----------------------------------------
/*
User Function BUSCALOTE()

	_nPrcv         	:= 0.01
	_cLocal		   	:= SB1->B1_LOCPAD
	_nLoteCtl		:= ""
	_nDtValid		:= CTOD("  /  /    ")
	_nDocORi		:= ""
	_nSerOri		:= ""
	_nIdent			:= ""
	_cTesSai  		:= MV_PAR04

	//Buscando a estrutura da SB8
	DbSelectArea("SB8")
	aStruSB8 := SB8->(DbStruct())

	IF SELECT("QRY_SB8") > 0
		QRY_SB8->(dbCloseArea())
	ENDIF

	//Criando a consulta que irá buscar os dados do Produto
	cQuery := " SELECT * "
	cQuery += " FROM " + RetSqlName('SB8') + " SB8 "
	cQuery += " WHERE SB8.D_E_L_E_T_ = ' ' "
	cQuery += "        AND B8_FILIAL  = '" + FWxFilial('SB8') + "' "
	cQuery += "        AND B8_PRODUTO = '" + _cProd + "' "
	cQuery += "        AND B8_SALDO >= '" + STR(_nQtdPedido) + "' "
	cQuery += "        AND B8_QACLASS = 0 "
	cQuery += " Order By B8_DATA asc"

	TCQuery cQuery New Alias 'QRY_SB8'

	//Se houver dados da consulta
	If ! QRY_SB8->(EoF())

		//Percorrendo os campos da estrutura
		For nAtual := 1 To Len(aStruSB8)

			//Se o tipo for diferente de Caracter, transforma o campo (por causa dos campos de Data)
			If aStruSB8[nAtual][2] <> "C"
				TcSetField("QRY_SB8", aStruSB8[nAtual][1], aStruSB8[nAtual][2], aStruSB8[nAtual][3], aStruSB8[nAtual][4])
			EndIf

		Next nAtual

		("QRY_SB8")->(DBGoTop())

		while !EoF()

			_nLote 			:= QRY_SB8->B8_NUMLOTE
			_nLoteCtl		:= QRY_SB8->B8_LOTECTL
			_cLocal			:= QRY_SB8->B8_LOCAL

			If Rastro( _cProd , "L" )

				_nSaldo := SaldoLote( _cProd , _cLocal , _nLoteCtl )

				_nDtValid	:= QRY_SB8->B8_DTVALID
				_nDocORi	:= QRY_SB8->B8_DOC
				_nSerOri	:= QRY_SB8->B8_SERIE
				_cCliB8		:= QRY_SB8->B8_CLIFOR
				_cLoCli		:= QRY_SB8->B8_LOJA

				IF SELECT("QRY_SB6") > 0
					QRY_SB6->(dbCloseArea())
				ENDIF

				//Criando a consulta que irá buscar os dados do Produto
				cQryB6 := " SELECT * "
				cQryB6 += " FROM " + RetSqlName('SB6') + " SB6 "
				cQryB6 += " WHERE SB6.D_E_L_E_T_ = ' '"
				cQryB6 += "        AND B6_FILIAL  = '" + FWxFilial('SB6') + "' "
				cQryB6 += "        AND B6_PRODUTO = '" + _cProd     + "' "
				//cQryB6 += "        AND B6_DOC = '"     + _nDocORi   + "' "
				cQryB6 += "        AND B6_SERIE = '"   + _nSerOri   + "' "
				cQryB6 += "        AND B6_CLIFOR = '"  + _cCliB8    + "' "
				cQryB6 += "        AND B6_LOJA = '"    + _cLoCli    + "' "
				cQryB6 += "        AND B6_ATEND <> 'S' "
				cQryB6 += "        AND B6_SALDO >= '" + STR(_nSaldo) + "' "
				//cQryB6 += "        AND B6_LOTECTL = '" + _nLoteCtl  + "' "

				TCQuery cQryB6 New Alias 'QRY_SB6'

				//Se houver dados da consulta
				If ! QRY_SB6->(EoF())

					_nPrcv		:= QRY_SB6->B6_PRUNIT
					_nIdent		:= QRY_SB6->B6_IDENT
					_nDtValid	:= QRY_SB6->B6_DTVALID
					_nDocORi	:= QRY_SB6->B6_DOC
					_nSerOri	:= QRY_SB6->B6_SERIE
					_cCliB8		:= QRY_SB6->B6_CLIFOR
					_cLoCli		:= QRY_SB6->B6_LOJA

				ENDIF

				IF _nQtdPedido <= _nSaldo

					EXIT

				ELSEIF _nQtdPedido > _nSaldo .and. _nSaldo = 0
					
					_cTesSai := "999"

				ELSEIF _nQtdPedido > _nSaldo .and. _nSaldo <> 0

					aAdd(aLinha , {"C6_ITEM" 		, _cItem								, Nil } )
					aAdd(aLinha , {"C6_PRODUTO" 	, aTxt[nX,1]							, Nil } )
					aAdd(aLinha , {"C6_DESCRI" 		, SUBS(aTxt[nX,2],1,30)					, Nil } )
					aAdd(aLinha , {"C6_QTDVEN"  	, _nSaldo		    					, Nil } )
					aAdd(aLinha , {"C6_PRCVEN"  	, _nPrcv                             	, Nil } )
					aAdd(aLinha , {"C6_TES" 		, _cTesSai								, Nil } )
					aAdd(aLinha , {"C6_LOCAL"   	, IF(!EMPTY(_cLocal),_cLocal,SB1->B1_LOCPAD)	, Nil } )
					aAdd(aLinha , {"C6_ENTREG" 		, Ctod(aTxt[nX,5])						, Nil } )
					aAdd(aLinha , {"C6_QTDLIB"   	, _nSaldo			    			    , Nil } )
					aAdd(aLinha , {"C6_LOTECTL" 	, _nLoteCtl								, Nil } )
					aAdd(aLinha , {"C6_DTVALID"		, _nDtValid								, Nil } )
					aAdd(aLinha , {"C6_NFORI"    	, _nDocORi								, Nil } )
					aAdd(aLinha , {"C6_SERIORI"		, _nSerOri								, Nil } )
					aAdd(aLinha , {"C6_IDENTB6"		, _nIdent								, Nil } )
					aAdd(aLinha , {"C6_ZZPALLE" 	, VAL(aTxt[nX,4])						, Nil } )

					aAdd(aItens,aLinha)

					_cItem			:= Soma1(_cItem)
					aLinha 			:= {}
					_nPrcv         	:= 0.01
					_cLocal		   	:= SB1->B1_LOCPAD
					_nLoteCtl		:= ""
					_nDtValid		:= CTOD("  /  /    ")
					_nDocORi		:= ""
					_nSerOri		:= ""
					_nIdent			:= ""
					_cTesSai  		:= MV_PAR04

					_nQtdPedido := _nQtdPedido - _nSaldo

				ENDIF

			ENDIF

			QRY_SB8->(DBSKIP())

		ENDDO
	ELSE
		_cTesSai := "999"
		Alert("Não existe lote para o produto: " + _cProd )
	ENDIF

RETURN
*/
