#include "rwmake.ch"
#include "topconn.ch"
#include "Colors.ch"
#include "Font.ch"
#include "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"

//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
//Triyo@tecpet2021! Triyo
/*----------------------------------------------------------------------------------|
|  Programa : EXECPVEN                                     Data : 21/01/2020        |
|-----------------------------------------------------------------------------------|
|  Cliente  : PRESTSERV                                                             |
|-----------------------------------------------------------------------------------|
|  Responsável Protheus no Cliente  : Renato Carli                                  |
|-----------------------------------------------------------------------------------|
|  Uso      : Importação de Pedido de Venda 									    |
|-----------------------------------------------------------------------------------|
|  Autor    : Igor Pedracolli - CRM SERVICES                                        |
|-----------------------------------------------------------------------------------|
| Tabelas Envolvidas  : Cabeçalho de Pedido de Venda : SC5                          |
|                       Itens de Pedido de Venda     : SC6                          |
|----------------------------------------------------------------------------------*/

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
	@ 090,140 Say + _cFile							  										Font oBold SIZE 200,09 PIXEL
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

	nHdl  := fopen(_cFile,0)
	_nTot := fSeek(nHdl,0,2)

	fClose(nHdl)

	If _nTot <= 0
		Aviso("","Arquivo corrompido ou já está sendo utilizado em outro processo.", {"OK"}, 2, "Problema...")
	EndIf

Return

//-----------------------------------------------------------------------------------|
//  Programa : fGerPed1                                           Data : 21/01/2020   |
//-----------------------------------------------------------------------------------|

Static Function fGerPed1()

	Local aArea     		:= GetArea()
	Local aAreaSc5  		:= GetArea()
	Local aAreaSc6  		:= GetArea()
	Local _cFilAnt  		:= SM0->M0_CODFIL
	Local aCabec			:= {}
	Local aCampoSC6			:= SC6->(DbStruct())
	LOCAL nX				:= 0
	
	PRIVATE cNewPed   		:= " "
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
	Private nSaldo          := 0 
	Private nLinhaI 		:= 1  
	Private nValorDeb 		:= 0
	Private cIdb 			:= ''
	If ValType(MV_PAR01) <> 'C'
		Pergunte(_cPerg,.F.)
		_cCliente 		:= MV_PAR01
	 	_cLoja    		:= MV_PAR02
	 	_cCondPag 		:= MV_PAR03
		_cTesSai  		:= MV_PAR04
	ENDIF
	If Empty(_cFile)
		Aviso("","Nenhum arquivo foi selecionado.", {"OK"}, 2, "Problema...")
		Return
	EndIf

	cNewPed := GetSX8Num("SC5","C5_NUM")
	
	SC5->(dbsetorder(1))

	while SC5->(DbSeek(xFilial("SC5") + cNewPed))
		cNewPed := GetSX8Num("SC5","C5_NUM")
	enddo

	ConfirmSx8()

	SA1->(dbsetorder(1))
	SA1->(dbseek(xFilial("SA1") + _cCliente + _cLoja))

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

	SB1->(dbsetorder(1))
	SF4->(dbsetorder(1))

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
			
			IF SB1->(dbSeek(xFilial("SB1") + ALLTRIM(_cProd)))
				 
				If  nLinhaI <= 1
					_nQtdPedido := Val(aTxt[nX,3])
					nValorDeb := Val(aTxt[nX,3])
				Else
					_nQtdPedido := nValorDeb
				EndIF
				_nQtdPedido:= U_BUSCALOTE()  // Tratativa para consultar o lote que será usado
				DbSelectArea("SD1")
				SD1->(DbSetOrder(1))
				SD1->(dbseek(xFilial("SD1")+_nDocORi+_nSerOri+ MV_PAR01 + MV_PAR02 +Padr(aTxt[nX,1],TamSX3("D1_COD")[1])+_nItemOri))
				aAdd(aLinha , {"C6_ITEM" 		, _cItem									, Nil } )
				aAdd(aLinha , {"C6_PRODUTO" 	, aTxt[nX,1]								, Nil } )
				aAdd(aLinha , {"C6_QTDVEN"  	, _nQtdPedido	    						, Nil } )
				aAdd(aLinha , {"C6_QTDLIB"  	, 0				    						, Nil } ) 
				aAdd(aLinha , {"C6_PRCVEN"  	, _nPrcv                             		, Nil } )
				aAdd(aLinha , {"C6_TES" 		, iif(alltrim(_nLoteCtl) == '',"999",_cTesSai), Nil } )		
				If alltrim(_nLoteCtl) <> ''
					aAdd(aLinha , {"C6_VALOR"  	, IIF(_nQtdPedido <> SD1->D1_QUANT,A410Arred(_nQtdPedido * _nPrcv,"C6_VALOR",If(cPaisLoc $ "CHI|PAR" .And. lPrcdec,M->C5_MOEDA,NIL)),A410TotPoder3(Padr(aTxt[nX,1],TamSX3("D1_COD")[1]),"N",MV_PAR01,MV_PAR02,_nIdent))               		, Nil } )				
				EndIF
				aAdd(aLinha , {"C6_LOCAL"   	, IF(!EMPTY(_cLocal),_cLocal,SB1->B1_LOCPAD), Nil } )
				aAdd(aLinha , {"C6_ENTREG" 		, dDatabase 								, Nil } )
				
				IF _cTesSai <> '999'

					aAdd(aLinha , {"C6_LOTECTL" 	, _nLoteCtl								, Nil } )
					aAdd(aLinha , {"C6_DTVALID"		, _nDtValid								, Nil } )
					aAdd(aLinha , {"C6_NFORI"    	, _nDocORi								, Nil } )
					aAdd(aLinha , {"C6_SERIORI"		, _nSerOri								, Nil } )
					aAdd(aLinha , {"C6_ITEMORI"		, _nItemOri								, Nil } )
					aAdd(aLinha , {"C6_IDENTB6"		, _nIdent								, Nil } )
					aAdd(aLinha , {"C6_ZZPALLE" 	, VAL(aTxt[nX,4])						, Nil } )
				
				ENDIF

				aAdd(aItens,aLinha)
				nResto :=   nValorDeb - _nQtdPedido
				If nResto > 0 
					nLinhaI += 1 
					nX -= 1
					nValorDeb := nResto
					nDocFID6 := _nDocORi
					nIdentB6 := _nIdent
					nProdb6 := _cProd
					cIdb += _nIdent + '/'
				Else
					nResto := 0 
					nLinhaI := 1 
					cIdb := ''
				EndIF	
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
				//Produto não encontrado
				
			ENDIF

		Next nX

		lMsErroAuto := .F.

		MsExecAuto({|x,y,z| Mata410(x,y,z)},aCabec,aItens,3)

		If lMsErroAuto
			MostraErro()
		Else
			MSGINFO("Foi gerado o Pedido de Venda No.: " + cNewPed , "Gerado com Sucesso !!!")
			
			//Faz impressão do relatorio com os logs da importação
			If MsgYesNo("Deseja imprimir o log da importação?","KANBAN","YESNO")
   				U_PRINTGRAPH()
			EndIf
			
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
	cQryB8			:= ""
	_NSALDO			:= 0
	_aEnderecar	    := .F.
	_cAchouB8   	:= .F.
	_cAchouB6       := .F.
	cAliasA := GetNextAlias()

	IF SELECT("QRY_SB6") > 0
		QRY_SB6->(dbCloseArea())
	ENDIF

	//Criando a consulta que irá buscar os dados da nota fiscal original
	cQryB6 := " SELECT * FROM " + RetSqlName('SB6') + " SB6 "
	cQryB6 += " WHERE SB6.D_E_L_E_T_ = ' '"
	cQryB6 += " AND B6_FILIAL  = '" + xFilial('SB6') + "' "
	cQryB6 += " AND B6_PRODUTO = '" + _cProd     + "' "
	cQryB6 += " AND B6_ATEND <> 'S' "
	cQryB6 += " AND B6_SALDO >= '1' "
	IF nLinhaI > 1
		cQryB6 += " AND B6_IDENT Not IN "+FormatIn(cIdb ,'/')+" "
	EndIF
	cQryB6 += " Order By B6_LOTECTL asc"

	TCQuery cQryB6 New Alias 'QRY_SB6'

	("QRY_SB6")->(DBGoTop())

	//Verifica se dados da consulta 
	If ! QRY_SB6->(EoF())

		While ! QRY_SB6->(EoF())

			_nSaldo := QRY_SB6->B6_SALDO
			If _nSaldo > 0
				/*cVlQr := "SELECT sum(CASE WHEN (B6_SALDO - CASE WHEN C6_QTDVEN > 0 THEN C6_QTDVEN ELSE 0 END  ) > 0  THEN B6_SALDO - CASE WHEN C6_QTDVEN > 0 THEN C6_QTDVEN ELSE 0  END  ELSE 0 END)  SALDO  "
				cVlQr += "FROM   "+RetSqlName("SB6")+"  C6 "
				cVlQr += "LEFT JOIN "+RetSqlName("SC6")+" B6 ON B6_IDENT = C6_IDENTB6  "
				cVlQr += "	AND B6.D_E_L_E_T_ = ' '  "
				cVlQr += "WHERE  B6_IDENT  = '"+QRY_SB6->B6_IDENT+"'  and C6.D_E_L_E_T_ = ' '  and B6_DOC = '"+QRY_SB6->B6_DOC+"' and B6_SERIE = '"+QRY_SB6->B6_SERIE+"' AND B6_PRODUTO = '" + _cProd     + "' and C6_QTDENT = 0  "
				*/
				cVlQr :="SELECT sum(c6_qtdven) SALDO FROM SC6010 where C6_IDENTB6 = '"+QRY_SB6->B6_IDENT+"' AND D_E_L_E_T_ = ' ' AND C6_NFORI = '"+QRY_SB6->B6_DOC+"' AND C6_SERIORI = '1' AND C6_PRODUTO = '"+_cProd+"' AND  C6_QTDENT = 0 "
				cVlQr := ChangeQuery(cVlQr)
				
				IF SELECT(cAliasA) > 0
					(cAliasA)->(dbCloseArea())
				ENDIF
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cVlQr),cAliasA,.T.,.T.)
				If !(cAliasA)->(EOF())
					If  (_nSaldo - (cAliasA)->SALDO )  > 0 
						If nLinhaI == 1
							_nSaldo:= _nSaldo - (cAliasA)->SALDO 
						Else
								
							IF nIdentB6 == QRY_SB6->B6_IDENT .and. QRY_SB6->B6_DOC == nDocFID6 .and. QRY_SB6->B6_PRODUTO == _cProd
								_nSaldo:=  0
							Else
								_nSaldo:= _nSaldo - (cAliasA)->SALDO 
							EndIF

						EndIf
					Else
						_nSaldo := 0 	
					EndIF
				EndIF
			EndIF	
				//SB8Saldo(lBaixaEmp,lConsVenc,lConsClas,lSegUM,cAliasSB8,lEmpPrevisto,lConsulta,dDataRef,lSaldo,cOP, nPercPrM, nQtdeOri)
			iF  _nSaldo > 0
			
				//Pega o saldo
			
					_nIdent		:= QRY_SB6->B6_IDENT
					_nDtValid	:= QRY_SB6->B6_DTVALID
					_nDocORi	:= QRY_SB6->B6_DOC
					_nSerOri	:= QRY_SB6->B6_SERIE
					_cCliB8		:= QRY_SB6->B6_CLIFOR
					_cLoCli		:= QRY_SB6->B6_LOJA
					_cLocal		:= QRY_SB6->B6_LOCAL
					
					_nPrcv		:= QRY_SB6->B6_PRUNIT //(QRY_SB6->B6_CUSTO1 / _nQtdPedido) //QRY_SB6->B6_PRUNIT
					_nSaldo     := IIF(_nSaldo >= nValorDeb ,nValorDeb,_nSaldo )
					_nLoteCtl	:= QRY_SB6->B6_LOTECTL

					_nItemOri	:= Posicione("SD1", 11 , xFilial("SD1") + _nDocORi + _nSerOri + MV_PAR01 + MV_PAR02 + _cProd + _nLoteCtl ,"D1_ITEM")
					
					_cAchouB8   := .T.
					_cAchouB6   := .T.
			
			EndIF
		
			IF _cAchouB8 <> .T.
				//Caso nao existam NF, devolve o produto com TES 999
				_cTesSai := "999"
				_nPrcv   := 0.01
				_nSaldo  := nValorDeb 
			Else
				EXIT
			ENDIF
			QRY_SB6->(DBSKIP())
		ENDDO

		IF _cAchouB6 <> .T.
						
			//Caso nao existam NF, devolve o produto com TES 999
			_cTesSai := "999"
			_nPrcv   := 0.01
			_nSaldo  := nValorDeb 
		ENDIF
	ELSE
		//Caso nao existam NF, devolve o produto com TES 999
		_cTesSai := "999"
		_nPrcv   := 0.01
		_nSaldo  := nValorDeb 
	ENDIF

RETURN _nSaldo

//-----------------------------------------------------------------------------------|
//  Programa : PRINTGRAPH                                    Data : 15/08/2021       |
//-----------------------------------------------------------------------------------|
//  Descrição: REALIZA A IMPRESSAO DOS LOGS DECORRENTES DA IMPORTACAO DOS ITENS.     |
//-----------------------------------------------------------------------------------|
//  Autor    : RAFAEL AUGUSTO - CRM SERVICES     		                             |
//-----------------------------------------------------------------------------------|

User Function PRINTGRAPH()
	
	Local oReport := nil

    Private cNome := 'KANBAN'

	oReport := RptDef(cNome)

	oReport:PrintDialog()

Return

Static Function RptDef(cNome)

	Local oReport   := Nil
	Local oSection1 := Nil
    
	oReport := TReport():New(cNome , "Importação Kanban", cNome , {|oReport| ReportPrint(oReport)} , "Importação Kanban")
    oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)

	oSection1 := TRSection():New(oReport , "Importado OK" , {"SC6"} , , .F., .T.)
	
    TRCell():New(oSection1 , "C6_PRODUTO"  , "TRBNCM" , "PRODUTO"          , "@!" , 100)
	TRCell():New(oSection1 , "C6_TES"      , "TRBNCM" , "TES"	           , "@!" , 50)
	TRCell():New(oSection1 , "C6_QTDVEN"   , "TRBNCM" , "QUANTIDADE"       , "@!" , 100)
	TRCell():New(oSection1 , "C6_PRCVEN"   , "TRBNCM" , "PREÇO"            , "@!" , 100)
	TRCell():New(oSection1 , "C6_VALOR"    , "TRBNCM" , "TOTAL"            , "@!" , 100)
	TRCell():New(oSection1 , "C6_LOTECTL"  , "TRBNCM" , "LOTE"             , "@!" , 100)

Return(oReport)

Static Function ReportPrint(oReport)

	Local oSection1 := oReport:Section(1)
	Local cQuery    := ""

	//Monto minha consulta conforme parametros passado
	cQuery := "    SELECT C6_PRODUTO, C6_TES, C6_QTDVEN, C6_PRCVEN, C6_VALOR, C6_LOTECTL "
	cQuery += "    FROM " + RETSQLNAME("SC6") + " SC6 "
	cQuery += "    WHERE SC6.D_E_L_E_T_ = ' ' "
	cQuery += "    AND C6_NUM = '" + cNewPed + "' "
	cQuery += "    ORDER BY C6_TES "

	MemoWrite( "c:\TEMP\EXECPVEN.txt", cQuery )

	//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
	IF Select("TRBNCM") <> 0
		DbSelectArea("TRBNCM")
		DbCloseArea()
	ENDIF

	//crio o novo alias
	TCQUERY cQuery NEW ALIAS "TRBNCM"

	dbSelectArea("TRBNCM")
	TRBNCM->(dbGoTop())

	oReport:SetMeter(TRBNCM->(LastRec()))

	//inicializo a primeira seção
	oSection1:Init()
	
    //Irei percorrer todos os meus registros
	While !Eof()

		oReport:IncMeter()

		oSection1:Cell("C6_PRODUTO"):SetValue(TRBNCM->C6_PRODUTO)
		oSection1:Cell("C6_TES"):SetValue(TRBNCM->C6_TES)
		oSection1:Cell("C6_QTDVEN"):SetValue(TRBNCM->C6_QTDVEN)
		oSection1:Cell("C6_PRCVEN"):SetValue(TRBNCM->C6_PRCVEN)
		oSection1:Cell("C6_VALOR"):SetValue(TRBNCM->C6_VALOR)
		oSection1:Cell("C6_LOTECTL"):SetValue(TRBNCM->C6_LOTECTL)
		
		oSection1:Printline()
		
	DbSkip()
	EndDo

	//finalizo a primeira seção
	oSection1:Finish()

Return


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
