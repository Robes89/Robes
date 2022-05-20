#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
 
/*/{Protheus.doc} FTTEAM1
Tela de Apontamentos
@author HENRIQUE CUNHA
@since 31/07/2019
@version P12 R12.1.17
@version 1.0
/*/ 
User Function FTTEAM1()

Local oDlg1
Local oButton1

Local aX		:= {}
Local aY		:= {}
Local aOPS		:= {}
Local aCampos	:= {"","C5_NUM","C6_QTDVEN","C5_CLIENTE","C6_PRODUTO","C2_QUANT","C2_QUJE"}
Local aCampos2	:= {"C5_NUM","C2_NUM","C2_SEQUEN","C6_PRODUTO"}
Local aCampos3	:= {"G1_QUANT","B1_DESC","G1_COMP"}
Local aColuns	:= {}
Local aColuns2	:= {}
Local aColuns3	:= {}

Private oVR		:= LoadBitmap(GetResources(),'BR_VERDE')
Private oVM 	:= LoadBitmap(GetResources(),'BR_VERMELHO')
Private oBmp
Private oBrwOP
Private oBrwINF
Private oBrwCMP


#DEFINE N_LGD	1 	// Legenda
#DEFINE N_NUM	4 	// Numero
#DEFINE N_QTD	10	// Quantidade
#DEFINE N_CLI	5 	// Cliente
#DEFINE N_PRD	7 	// Produto
#DEFINE N_QTP	3 	// Quantidade Produzir
#DEFINE N_QPD	9 	// Quantidade Produzida

#DEFINE Y_NPED	1 	// Numero Peido
#DEFINE Y_NORP	2 	// Numero OP
#DEFINE Y_SQUE	3	// Sequencia
#DEFINE Y_PROD	4	// Produto

#DEFINE X_QTDS	1 	// Quantidade 
#DEFINE X_DESC	2 	// Descricao Produto
#DEFINE X_PROD	3	// Código Produto

aColuns		:= RETCOLUNS(aCampos)
aColuns2	:= RETCOLUNS(aCampos2)
aColuns3	:= RETCOLUNS(aCampos3)
aOPS		:= FTTEAM2()

AaDD(aX,{"-","-","-","-"})
AaDD(aY,{"-","-","-"})

DEFINE MSDIALOG oDlg1 TITLE "Tela de Apontamentos" FROM 0,0 TO 700,1200 PIXEL

@ 032,001 SAY OP PROMPT "Pedidos: " SIZE 050, 012 OF oDlg1 PIXEL	
@ 040,001 BUTTON oButton1 PROMPT "Filtrar" SIZE 050, 020 OF oDlg1 ACTION (oBrwOP:AARRAY := FTTEAM2()) PIXEL

//oBmp := TBitmap():New( 10, 110, 400, 400, "0F6EBE4BF1B83F7FB99B",,, oDlg1)
//
oBmp := TBmpRep():New(10,110,400,400,"SEMFOTO",.T.,oDlg1,,,.F.,.F.,,,,)

oBrwCMP := TWBrowse():New(240,01,400,90,,aColuns3,,oDlg1,,,,,,,,,,,,.F.,,.T.,,.F.,,.T.,.T.)
oBrwCMP:SetArray(aY)
oBrwCMP:bLine := {|| {	aY[oBrwCMP:nAt,X_QTDS],;
						aY[oBrwCMP:nAt,X_DESC],;
						aY[oBrwCMP:nAt,X_PROD]}}

oBrwINF := TWBrowse():New(200,100,200,30,,aColuns2,,oDlg1,,,,,,,,,,,,.F.,,.T.,,.F.,,.T.,.T.)
oBrwINF:SetArray(aX)
oBrwINF:bLine := {|| {	aX[oBrwINF:nAt,Y_NPED],;
						aX[oBrwINF:nAt,Y_NORP],;
						aX[oBrwINF:nAt,Y_SQUE],;
						aX[oBrwINF:nAt,Y_PROD]}}


oBrwOP	:= TWBrowse():New(60,01,400,130,,aColuns,,oDlg1,,,,,,,,,,,,.F.,,.T.,,.F.,,.T.,.T.)
oBrwOP:SetArray(aOPS)
oBrwOP:bLine := {|| {If(aOPS[oBrwOP:nAt,N_LGD],oVR,oVM),;
						aOPS[oBrwOP:nAt,N_NUM],;
						aOPS[oBrwOP:nAt,N_QTD],;
						aOPS[oBrwOP:nAt,N_CLI],;
						aOPS[oBrwOP:nAt,N_PRD],;
						aOPS[oBrwOP:nAt,N_QTP],;
						aOPS[oBrwOP:nAt,N_QPD]}}
						
oBrwOP:bLDblClick := {||ATUOBJS()}



ACTIVATE MSDIALOG oDlg1 CENTERED ON INIT (oDlg1:Refresh(),EnchoiceBar(oDlg1, {|| oDlg1:End()}, {||oDlg1:End()},,))

Return lRet

/*/{Protheus.doc} ATUOBJS
ATUALIZA OBJETOS A PARTIR DE DUPLO CLICK
@author HENRIQUE CUNHA
@since 31/07/2019
@version P12 R12.1.17
@version 1.0
/*/   


Static Function ATUOBJS()

Local _cQry		:= ""
Local _cWKArea	:= GetNextAlias()

Local nPos		:= 0

Local aReg		:= {}
Local aBInfs	:= {}
Local aComps	:= {}

#DEFINE Y_NPED	1 	// Numero Pedido
#DEFINE Y_NORP	2 	// Numero OP
#DEFINE Y_SQUE	3	// Sequencia
#DEFINE Y_PROD	4	// Produto

#DEFINE X_QTDS	1 	// Quantidade 
#DEFINE X_DESC	2 	// Descricao Produto
#DEFINE X_PROD	3	// Código Produto

nPos := oBrwOP:NROWPOS
aReg := oBrwOP:AARRAY[nPos]

_cQry := " SELECT	G1_QUANT,			"
_cQry += " 			B1_DESC,			"
_cQry += " 			G1_COMP				"
_cQry += "   FROM " + RetSqlName("SG1") + " SG1 "
_cQry += "	INNER JOIN " + RetSqlName("SB1") + " SB1 "
_cQry += "	   ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
_cQry += "	  AND SB1.B1_COD	= SG1.G1_COMP "
_cQry += "  WHERE SG1.G1_FILIAL = '" + xFilial("SG1") + "' "
_cQry += "    AND SG1.G1_COD 	= '" + aReg[8] + "' "
_cQry += "    AND SG1.G1_INI   <= '" + DtoS(dDataBase) + "' "
_cQry += "    AND SG1.G1_FIM   >= '" + DtoS(dDataBase) + "' "
_cQry += "    AND SG1.G1_TRT	= (SELECT MAX(G1_TRT)
_cQry += "						 	 FROM " + RetSqlName("SG1") + " G1 "
_cQry += "							WHERE G1.G1_FILIAL	= '" + xFilial("SG1") + "' "
_cQry += "						  	  AND G1.G1_COD		= '" + aReg[8] + "' "
_cQry += "						  	  AND G1.D_E_L_E_T_ = ' ' )"		
_cQry += "    AND SG1.D_E_L_E_T_ = ' ' "
_cQry += "    AND SB1.D_E_L_E_T_ = ' ' "

_cQry := ChangeQuery(_cQry)
DBUseArea( .T., "TOPCONN", TcGenQry(,,_cQry), _cWKArea)

While (_cWKArea)->(!EOF())
	AaDD(aComps,{(_cWKArea)->G1_QUANT,(_cWKArea)->B1_DESC,(_cWKArea)->G1_COMP})
	(_cWKArea)->(DBSkip())
EndDO

AaDD(aBInfs,{aReg[5],aReg[3],aReg[2],aReg[8]})

oBrwCMP:SetArray(aComps)
oBrwCMP:bLine := {|| {	aComps[oBrwCMP:nAt,X_QTDS],;
						aComps[oBrwCMP:nAt,X_DESC],;
						aComps[oBrwCMP:nAt,X_PROD]}}
oBrwCMP:Refresh()

oBrwINF:SetArray(aBInfs)
oBrwINF:bLine := {|| {	aBInfs[oBrwINF:nAt,Y_NPED],;
						aBInfs[oBrwINF:nAt,Y_NORP],;
						aBInfs[oBrwINF:nAt,Y_SQUE],;
						aBInfs[oBrwINF:nAt,Y_PROD]}}
oBrwINF:Refresh()

DBSelectArea("SB1")
SB1->(DBSetOrder(1))
SB1->(DBSeek(xFilial("SB1")+AllTrim(aReg[8])))

If !Empty(AllTrim(SB1->B1_BITMAP))		
	Showbitmap(oBmp,SB1->B1_BITMAP,"")
	oBmp:lAutoSize	:= .T.
	oBmp:lStretch	:= .T.
	oBmp:Refresh()
EndIf

Return

/*/{Protheus.doc} FTTEAM002
ROTINA DE FILTRO DE OPS PARA PRODUCAO
@author HENRIQUE CUNHA
@since 31/07/2019
@version P12 R12.1.17
@version 1.0
/*/   

Static Function FTTEAM2()

Local _cQry		:= ""
Local _cPerg	:= "TEAM002"
Local _cWkArea	:= GetNextAlias()
Local _cAletar	:= "Nenhum Registro Foi Selecionado. Por Favor Selecionar ou Cancelar."

Local _nX	:= 0
Local _nY	:= 0

Local oDlg
Local oBrwOP1
Local oBtnMarc := NIL

Local aCmps 	:= {"","C2_SEQUEN","C2_NUM","C2_QUANT","C5_NUM","C5_CLIENTE","A1_NOME","C6_PRODUTO","B1_DESC"}
Local aRegs		:= {}
Local aColuns	:= {}
Local aButtons	:= {}
Local aSelects	:= {}

Local _lRet 	:= .T.

Private oOk		:= LoadBitmap(GetResources(), 'LBOK')
Private oNo 	:= LoadBitmap(GetResources(), 'LBNO')
Private oVR		:= LoadBitmap(GetResources(),'BR_VERDE')
Private oVM 	:= LoadBitmap(GetResources(),'BR_VERMELHO')

#DEFINE N_CHK	1 // Check Box
#DEFINE N_SEQ	2 // Sequencia
#DEFINE N_NUM	3 // Numero
#DEFINE N_QTD	4 // Quantidade
#DEFINE N_NPD	5 // Numero Pedido
#DEFINE N_CLI	6 // Cliente
#DEFINE N_NOM	7 // Nome Cliente
#DEFINE N_PRD	8 // Produto
#DEFINE N_DPD	9 // Desc. Produto

#DEFINE X_LGD	1 	// Legenda
#DEFINE X_NUM	4 	// Numero
#DEFINE X_QTD	10	// Quantidade
#DEFINE X_CLI	5 	// Cliente
#DEFINE X_PRD	7 	// Produto
#DEFINE X_QTP	3 	// Quantidade Produzir
#DEFINE X_QPD	9 	// Quantidade Produzida

CHKSX1(_cPerg)
_lRet := Pergunte(_cPerg,.F.)

If !_lRet
	Alert("Tela de Parâmetros Cancelada!")
EndIf

_cQry := " SELECT C2_SEQUEN,	"
_cQry += "		  C2_NUM,		"	 
_cQry += "		  C2_QUANT,		"
_cQry += "		  C5_NUM,		"
_cQry += "		  C5_CLIENTE,	"	 
_cQry += "		  A1_NOME,		"
_cQry += "		  C6_PRODUTO,	"	
_cQry += "		  B1_DESC,		"
_cQry += "		  C2_QUJE,		"
_cQry += "		  C6_QTDVEN 	"
//_cQry += " -- CAMPO COLETA A DEFINIR "  	 	 
_cQry += "	 FROM " + RetSQLName("SC5") + " C5 "
_cQry += "	INNER JOIN " + RetSQLName("SC6") + " C6 "
_cQry += "	   ON C6_FILIAL = '" + xFilial("SC6") + "' "
_cQry += " 	  AND C6_NUM = C5_NUM	"
_cQry += " 	  AND C6_CLI = C5_CLIENTE	"
_cQry += " 	  AND C6_LOJA = C5_LOJACLI     "
_cQry += "	INNER JOIN " + RetSQLName("SC2") + " C2 "
_cQry += " 	   ON C2_FILIAL = '" + xFilial("SC2") + "' "
_cQry += " 	  AND C2_PEDIDO = C6_NUM       "
_cQry += " 	  AND C2_ITEMPV = C6_ITEM      "
_cQry += " 	  AND C2_NUM = C6_NUMOP           "
_cQry += " 	  AND C2_PRODUTO = C6_PRODUTO  "
_cQry += "	INNER JOIN " + RetSQLName("SB1") + " B1 "
_cQry += " 	   ON B1_FILIAL = '" + xFilial("SB1") + "' "
_cQry += "	  AND B1_COD = C6_PRODUTO      "
_cQry += "	INNER JOIN " + RetSQLName("SA1") + " A1 "
_cQry += " 	   ON A1_FILIAL = '" + xFilial("SA1") + "' "
_cQry += "	  AND A1_COD = C5_CLIENTE      "
_cQry += "	  AND A1_LOJA = C5_LOJACLI     "
_cQry += "	WHERE C5_FILIAL = '" + xFilial("SC5") + "' "
_cQry += "	  AND C2_STATUS <> 'U'         "
_cQry += " 	  AND C2_QUJE < C2_QUANT       "
_cQry += " 	  AND C6_PRODUTO  BETWEEN '" + MV_PAR01 + "'  AND '" + MV_PAR02 + "' "
_cQry += "	  AND C2_NUM BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
_cQry += "	  AND C5_EMISSAO BETWEEN '" + DtoS(MV_PAR05) + "' AND '" + DtoS(MV_PAR06) + "' "
//_cQry += " --AND CAMPO COLETA A DEFINIR "
_cQry += "	  AND C5_CLIENTE BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
_cQry += " 	  AND C5_NUM BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' "
_cQry += " 	  AND C5.D_E_L_E_T_ = ' '      "
_cQry += " 	  AND C6.D_E_L_E_T_ = ' '      "
_cQry += " 	  AND C2.D_E_L_E_T_ = ' '      "
_cQry += " 	  AND B1.D_E_L_E_T_ = ' '      "
_cQry += " 	  AND A1.D_E_L_E_T_ = ' '      "

_cQry := ChangeQuery(_cQry)
DbUseArea( .T., "TOPCONN", TcGenQry(,,_cQry), _cWkArea)

If (_cWkArea)->(EOF())
	MsgAlert("Não há Ordens de Produção em aberto!")
	Return
EndIf

While (_cWkArea)->(!EOF())
	AaDd(aRegs,{.F.,;
				(_cWkArea)->C2_SEQUEN,;	
				(_cWkArea)->C2_NUM,;		
				(_cWkArea)->C2_QUANT,;	
				(_cWkArea)->C5_NUM,;		
				(_cWkArea)->C5_CLIENTE,;		
				(_cWkArea)->A1_NOME,;	
				(_cWkArea)->C6_PRODUTO,;
				(_cWkArea)->B1_DESC,;
				(_cWkArea)->C2_QUJE,;
				(_cWkArea)->C6_QTDVEN})	

	(_cWkArea)->(DBSkip())

EndDo

DBSelectArea("SX3")
SX3->(DbSetOrder(2))


aColuns := RETCOLUNS(aCmps)

DEFINE MSDIALOG oDlg TITLE "Selecionar Ordens de Produção" FROM 0,0 TO 400,800 PIXEL

//@ 032,001 SAY OP PROMPT "Ordens de Produção Disponiveis" SIZE 050, 012 OF oDlg PIXEL	
@ 035,001 BUTTON oBtnMarc PROMPT "Marcar Todas" 	SIZE 60,15 ACTION fMarcAll(aRegs, 1) OF oDlg Pixel 
@ 035,080 BUTTON oBtnMarc PROMPT "Desmarcar Todas"	SIZE 60,15 ACTION fMarcAll(aRegs, 2) OF oDlg Pixel 


oBrwOP1	:= TWBrowse():New( 60 , 01, 400, 130, ,aColuns ,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,.T.,.T.)
oBrwOP1:SetArray(aRegs)
oBrwOP1:bLine := {|| {If(aRegs[oBrwOP1:nAt,N_CHK],oOk,oNo),;
						aRegs[oBrwOP1:nAt,N_SEQ],;
						aRegs[oBrwOP1:nAt,N_NUM],;
						aRegs[oBrwOP1:nAt,N_QTD],;
						aRegs[oBrwOP1:nAt,N_NPD],;
						aRegs[oBrwOP1:nAt,N_CLI],;
						aRegs[oBrwOP1:nAt,N_NOM],;
						aRegs[oBrwOP1:nAt,N_PRD],;
						aRegs[oBrwOP1:nAt,N_DPD]}}

oBrwOP1:bLDblClick := {||aRegs[oBrwOP1:nAt,N_CHK] := !aRegs[oBrwOP1:nAt,N_CHK]}

ACTIVATE MSDIALOG oDlg CENTERED ON INIT (oDlg:Refresh(),EnchoiceBar(oDlg, {||IIF(aScan( aRegs, {|x| x[1] == .T. }) = 0, Alert(_cAletar), oDlg:End())}, {||oDlg:End()} , ,aButtons))

For nY := 1 To Len(aRegs)
	If aRegs[nY][1] = .T.
		AaDd(aSelects,aRegs[nY])
	EndIf
Next nY

If oBrwOP == NIL
	Return(aSelects)
Else
	oBrwOP:SetArray(aSelects)
	oBrwOP:bLine := {|| {If(aSelects[oBrwOP:nAt,X_LGD],oVR,oVM),;
							aSelects[oBrwOP:nAt,X_NUM],;
							aSelects[oBrwOP:nAt,X_QTD],;
							aSelects[oBrwOP:nAt,X_CLI],;
							aSelects[oBrwOP:nAt,X_PRD],;
							aSelects[oBrwOP:nAt,X_QTP],;
							aSelects[oBrwOP:nAt,X_QPD]}}
EndIf

Return(Nil)

/*/{Protheus.doc} fMarcAll
Função para marcar e desmarcar o wizzard
@author Henrique Ghidini
@since 26/06/2019
@return NIL
/*/

Static Function fMarcAll(aItens, nOpc)

Local nX := 0

	//Marcar tudo.
	If nOpc == 1
		For nX := 1 to len(aItens)
			aItens[nX][1] := .T.
		Next nX

	//Desmarcar tudo.
	Else
		For nX := 1 to len(aItens)
			aItens[nX][1] := .F.
		Next nX
	EndIf
Return()

/*/{Protheus.doc} RETCOLUNS
Retorna colunas das telas
@author HENRIQUE CUNHA
@since 31/07/2019
@version P12 R12.1.17
@version 1.0
/*/ 

Static Function RETCOLUNS(aCampos)

Local _nX	:= {}

Local aRet	:= {}
Local aArea	:= GetArea()

DBSelectArea("SX3")
SX3->(DbSetOrder(2))

For _nX := 1 To Len(aCampos)

	If SX3->(DBSeek(aCampos[_nX])) .and. !Empty(aCampos[_nX])
		AaDd(aRet, AllTrim(X3Titulo()))
	Else
		AaDd(aRet, "")
	EndIf

Next _nX

RestArea(aArea)

Return aRet

/*/{Protheus.doc} CHKSX1
Criação do Pergunte
@author HENRIQUE CUNHA
@since 16/07/2019
@version P12 R12.1.17
@version 1.0
/*/          
Static Function CHKSX1(cPerg)
Local aRegs :={}
Local i := 0, j := 0

Aadd(aRegs,{cPerg,"01","Produto De?"    ,"Produto De?"		,"Produto De?"		,"mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SB1","",""})
Aadd(aRegs,{cPerg,"02","Produto Ate?"   ,"Produto Ate?"		,"Produto Ate?"		,"mv_ch2","C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SB1","",""})
Aadd(aRegs,{cPerg,"03","OP De?"			,"OP De?"			,"OP De?"			,"mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SC2","",""})
Aadd(aRegs,{cPerg,"04","OP Ate?"		,"OP Ate?"			,"OP Ate?"			,"mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SC2","",""})
Aadd(aRegs,{cPerg,"05","Emissão De?"	,"Emissão De?"		,"Emissão De?"		,"mv_ch5","D",08,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"06","Emissão Ate?"	,"Emissão Ate?"		,"Emissão Ate?"		,"mv_ch6","D",08,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"07","Dt. Coleta De?"	,"Dt. Coleta De?"	,"Dt. Coleta De?"	,"mv_ch7","D",08,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"08","Dt. Coleta Ate?","Dt. Coleta Ate?"	,"Dt. Coleta Ate?"	,"mv_ch8","D",08,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"09","Cliente De?"	,"Cliente De?"		,"Cliente De?"		,"mv_ch9","C",06,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","SA1CLI","",""})
Aadd(aRegs,{cPerg,"10","Cliente Ate?"	,"Cliente Ate?"		,"Cliente Ate?"		,"mv_cha","C",06,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","SA1CLI","",""})
Aadd(aRegs,{cPerg,"11","Pedido De?"		,"Pedido De?"		,"Pedido De?"		,"mv_chb","C",06,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","SC5","",""})
Aadd(aRegs,{cPerg,"12","Pedido Ate?"	,"Pedido Ate?"		,"Pedido Ate?"		,"mv_chc","C",06,0,0,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","SC5","",""})

DBSelectArea("SX1")
SX1->(DBSetOrder(1))

For i:= 1 To Len(aRegs)
	If !dbSeek(Padr(cPerg,Len(X1_GRUPO))+aRegs[i,2])
		RecLock("SX1", .T.)
		For j := 1 To Len(aRegs[1])
			FieldPut(j,aRegs[i,j])
		Next j
		MsUnlock()
	Endif
Next i

Return Nil