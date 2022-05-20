
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
Static cCRLF := CRLF

/*
|-----------------------------------------------------------------------------------|
|  Programa : PSCSVPED                                      Data : 17/09/2019       |
|-----------------------------------------------------------------------------------|
|  Cliente  : PRESTSERV                                                             |
|-----------------------------------------------------------------------------------|
|  Responsável Protheus no Cliente  : Renato                                        |
|-----------------------------------------------------------------------------------|
|  Uso      : Importação de Pedido de Venda 									    |
|-----------------------------------------------------------------------------------|
|  Autor    : Wagner Neves - CRM SERVICES                                           |
|-----------------------------------------------------------------------------------|
| Tabelas Envolvidas  : Cabeçalho de Pedido de Venda : SC5                          |
|                       Itens de Pedido de Venda     : SC6                          |
|-----------------------------------------------------------------------------------|
*/

User Function PSCSVPED()

Private oLeTxt                         // Janela de Dialogo
Private Arquivo := Space(40)           // Arquivo Texto Selecionado
Private cArqTRB := ""                  // Arquivo de Trabalho Temporario
Private cArqEdi := ""                  // Arquivo Texto a Processar
Private cArqCop := ""                  // Arquivo de Copia

Private lGeraprv, dDataprv
Private lExec	:= .T.

Private _nTot      := 0
Private _cType     := ""
Private _cPerg     := "PSCSVPED"
Private _cPath     := ''
Private _cFile     := ''
Private _cEOL      := "CHR(13)+CHR(10)"
Private aRegs  	   := {}
Private aHelpPor   := {}
Aadd(aRegs,{"Cliente ?      ","Cliente ?       ","Cliente ?      ","mv_ch1","C",06,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","","","",aHelpPor,aHelpPor,aHelpPor})
Aadd(aRegs,{"Loja ?         ","Loja ?          ","Loja ?         ","mv_ch2","C",02,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor})
Aadd(aRegs,{"Cond.Pagto ?   ","Cond.Pagto ?    ","Cond.Pagto ?   ","mv_ch3","C",03,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","SE4","","","","","",aHelpPor,aHelpPor,aHelpPor})
Aadd(aRegs,{"Tes de Saida ? ","Tes de Saida ?  ","Tes de Saida ? ","mv_ch4","C",03,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","SF4","","","","","",aHelpPor,aHelpPor,aHelpPor})
//fAjusSX1(_cPerg,aRegs)
Pergunte(_cPerg,.F.)
fGerPed0()
Return                                                  

/*
|-----------------------------------------------------------------------------------|
|  Programa : fGerPed0                                          Data : 17/09/2019   |
|-----------------------------------------------------------------------------------|
*/
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

/*
|-----------------------------------------------------------------------------------|
|  Programa : fSelArq                                           Data : 17/09/2019   |
|-----------------------------------------------------------------------------------|
*/
Static Function fSelArq()
Private _cType := ""
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

/*
|-----------------------------------------------------------------------------------|
|  Programa : fGerPed1                                          Data : 17/09/2019   |
|-----------------------------------------------------------------------------------|
*/
Static Function fGerPed1()
Local aArea     := GetArea()
Local aAreaSc5  := GetArea()
Local aAreaSc6  := GetArea()
Local cFilBkp   := cFilAnt
Local cNewPed   := ""               
     
Local _cCliente := MV_PAR01
Local _cLoja    := MV_PAR02
Local _cCondPag := MV_PAR03
Local _cTesSai  := MV_PAR04
Local _cFilAnt  := SM0->M0_CODFIL

Local aCabec	:= {}
Local aLinha	:= {}
Local aItens	:= {}
Local aTXT      := {}
Local aCampoSC6	:= SC6->(DbStruct())

Private lMsErroAuto:= .f.
              
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
aadd(aCabec,{"C5_FILIAL"     ,_cFilAnt                   	  	,Nil})
aadd(aCabec,{"C5_NUM"        ,cNewPed 	                      	,Nil}) 
aadd(aCabec,{"C5_TIPO"       ,"N" 	                           	,Nil}) 
aadd(aCabec,{"C5_CLIENTE"    ,_cCliente                        	,Nil}) 
aadd(aCabec,{"C5_LOJACLI"    ,_cLoja                           	,Nil}) 
aadd(aCabec,{"C5_CLIENT"     ,_cCliente                        	,Nil}) 
aadd(aCabec,{"C5_LOJAENT"    ,_cLoja                      	   	,Nil}) 
aadd(aCabec,{"C5_CONDPAG"    ,_cCondPag                  		,Nil}) 
aadd(aCabec,{"C5_TABELA"     ,'' 	                    		,Nil}) 
aadd(aCabec,{"C5_VEND1"      ,sa1->a1_vend                     	,Nil}) 
aadd(aCabec,{"C5_EMISSAO"    ,dDatabase                        	,Nil}) 
aadd(aCabec,{"C5_TPFRETE"    ,"C"                             	,Nil}) 
aadd(aCabec,{"C5_TPCARGA"    ,"2"                             	,Nil}) 
aadd(aCabec,{"C5_MENPAD"     ,''	                            ,Nil}) 

sb1->(dbsetorder(1))
sf4->(dbsetorder(1))

aPosCampos:= Array(Len(aCampoSC6))

FT_FUse(_cFile)
FT_FGOTOP()
cLinha := FT_FREADLN()
nPos	:=	0
nAt	:=	1
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
		sb1->(dbsetorder(1))
		sb1->(dbseek(xFilial("SB1")+aTxt[nX,1]))
		
		_nQtdPedido := Val(aTxt[nX,3])					
		
		IF SF4->F4_PODER3='D' .AND. SF4->F4_ESTOQUE='S' // DEVOLUÇÃO + ESTOQUE
			If Select("XSB6") # 0
				XSB6->(dbCloseArea())
			EndIf
			cQrySb6 := ''
			cQrySb6 := cCRLF + "SELECT * "
			cQrySb6 += cCRLF + "  FROM "+RetSqlName("SB6")+" TSB6"
			cQrySb6 += cCRLF + "WHERE"
			cQrySb6 += cCRLF + "  TSB6.B6_FILIAL = '"+xFilial("SB6")+"' AND "
			cQrySb6 += cCRLF + "  TSB6.B6_PRODUTO = '"+SB1->B1_COD+"' AND "
			cQrySb6 += cCRLF + "  TSB6.B6_LOCAL = '" + SB1->B1_LOCPAD+"' AND '
			cQrySb6 += cCRLF + "  TSB6.B6_SALDO > 0 AND"
			cQrySb6 += cCRLF + "  TSB6.B6_PODER3 = 'R' AND"
			cQrySb6 += cCRLF + "  TSB6.B6_CLIFOR = '"+MV_PAR01+"' AND"
			cQrySb6 += cCRLF + "  TSB6.B6_LOJA = '"+MV_PAR02+"' AND"						
			cQrySb6 += cCRLF + "  TSB6.D_E_L_E_T_ <> '*' "
			cQrySb6 += cCRLF + "ORDER BY B6_LOTECTL"  			
			TcQuery ChangeQuery(@cQrySb6) New Alias "XSB6"	
			Count to cRegistros							
			
			MemoWrite( 'C:\TEMP\CQRYSB6.TXT'  , cQrySb6 )
			
			XSB6->(DBGOTOP())
									
			While ! XSB6->(EOF())			
				If XSB6->B6_SALDO <= _nQtdPedido  
					_nLote 	  := XSB6->B6_LOTECTL
					_nValLote := XSB6->B6_DTVALID
					_nNfiscal := XSB6->B6_DOC
					_nSerie   := XSB6->B6_SERIE					
					_nFornece := XSB6->(B6_CLIFOR+B6_LOJA)					
					_nIdent   := XSB6->B6_IDENT
					_nItNfOri := POSICIONE("SD1",2,XFILIAL("SD1")+SB1->B1_COD+_nNfiscal+_nSerie+_nfornece,"SD1->D1_ITEM")
				Else
					XSB6->(DBSKIP())   // quando o saldo do poder de terceiros for menor ???? muda o pedido ?
					LOOP
				EndIf				
			EndDo		
		EndIf		
				
		_vPrcUnit := XSB6->B6_PRUNIT		
				
		aAdd(aLinha,{"C6_ITEM" 		, StrZero(nX,2)							, Nil } )
		aAdd(aLinha,{"C6_PRODUTO" 	, aTxt[nX,1]							, Nil } )		
		aAdd(aLinha,{"C6_ZZPALLE" 	, VAL(aTxt[nX,4])						, Nil } )			
		aAdd(aLinha,{"C6_DESCRI" 	, SUBS(aTxt[nX,2],1,30)					, Nil } )		
		aAdd(aLinha,{"C6_QTDVEN"  	, Val(aTxt[nX,3])    					, Nil } )
		aAdd(aLinha,{"C6_PRCVEN"  	, If(_vPrcUnit=0,1,_vPrcUnit)	    	, Nil } )
		aAdd(aLinha,{"C6_QTDLIB"   	, Val(aTxt[nX,3])    					, Nil } )		
		aAdd(aLinha,{"C6_TES" 		, _cTesSai								, Nil } )
		aAdd(aLinha,{"C6_LOCAL"   	, sb1->b1_locpad    					, Nil } ) 
		aAdd(aLinha,{"C6_ENTREG" 	, Ctod(aTxt[nX,5])						, Nil } )			
		aAdd(aItens,aLinha)			
					 
	Next nX
	lMsErroAuto := .F.
	MsExecAuto({|x,y,z| Mata410(x,y,z)},aCabec,aItens,3)
	If lMsErroAuto
		MostraErro()
	Else
		MSGINFO("Foi gerado o Pedido de Venda No.: "+cNewPed,"Grado com Sucesso !!!")
	Endif                                                                	
EndIf
SC5->(RestArea(aAreaSC5))
SC6->(RestArea(aAreaSC6))
RestArea(aArea)
Return( Nil )               

/*
|-----------------------------------------------------------------------------------|
|  Programa : fAjusSx1                                      Data : 10/09/2019       |
|-----------------------------------------------------------------------------------|
|  Descrição: GERA PERGUNTAS												        |
|-----------------------------------------------------------------------------------|
|  Autor    : WAGNER NEVES - CRM SERVICES   		                                |
|-----------------------------------------------------------------------------------|
*/

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
