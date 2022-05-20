#INCLUDE "TOTVS.CH"
#include "TopConn.Ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBIConn.ch"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "APWEBSRV.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RECPARCELAºAutor  ³Microsiga           º Data ³  06/22/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para ajustar o valor das parcelas ja criadas no      º±±
±±º          ³Financeiro apartir da data de entrega da mercadoria         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function TEAMParcela()

Local oButton1
Local oButton2
Local oGet1
Local cGet1 := CTOD("  /  /  ")
Local oGet2
Local cGet2 := SF2->F2_DOC
Local oGroup1
Local oSay1
Local oSay2
Static oDlg

  DEFINE MSDIALOG oDlg TITLE "Recalculo de Vencimento de Parcelas" FROM 000, 000  TO 220, 500 COLORS 0, 16777215 PIXEL

    @ 004, 008 GROUP oGroup1 TO 101, 225 OF oDlg COLOR 0, 16777215 PIXEL

    @ 014, 028 SAY oSay2 		PROMPT "Nota Fiscal"  										SIZE 067, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 023, 028 MSGET oGet2 		VAR cGet2 													SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL WHEN .F.

    @ 042, 028 SAY 		oSay1 	PROMPT "Informe a Data de Entrega" 							SIZE 071, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 054, 028 MSGET 	oGet1 	VAR cGet1 													SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL

    @ 076, 074 BUTTON oButton1 	PROMPT "&Cancelar"	ACTION(oDlg:End()) 						SIZE 037, 012 OF oDlg PIXEL
    @ 076, 024 BUTTON oButton2 	PROMPT "&Confirmar"	ACTION(RecParcela(cGet1),oDlg:End())  	SIZE 037, 012 OF oDlg PIXEL

  ACTIVATE MSDIALOG oDlg CENTERED

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RECPARCELAºAutor  ³Microsiga           º Data ³  06/20/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RecParcela(xData)
Local aParc		:= {}
Local nX		:= 1
Local lRec		:= .T.
Local lSemTit	:= .T.

DbSelectArea("SF2")

_cChavE1	:= 	xFilial("SE1")		+;
				SF2->F2_CLIENTE		+;
				SF2->F2_LOJA		+;
				SF2->F2_SERIE		+;
				SF2->F2_DOC

Begin Sequence

	If  Empty(xData)
		MsgInfo("Favor informa a data de entrega!!!")
		Break
	EndIf

	If  (xData > Date())
		MsgInfo("Data de entrega não pode ser maior que a data atual!!!")
		Break
	EndIf

	DbSelectArea("SE1")
	DbSetOrder(2)

	If  !( SE1->(DbSeek(_cChavE1)) )
		MsgInfo("Nenhum Título encontrado para esta Nota Fiscal!!!")
		Break
	EndIf

	aParc	:=Condicao(	SF2->F2_VALMERC	,;	//Valor Total
						SF2->F2_COND	,;	//Condicao de pagamento
						NIL				,;
						xData 			,;	//Data de Emissao do Titulo
						NIL				,;
						NIL				,;
						NIL				,;
						NIL				)

	Do While SE1->(!EOF())							.AND.;
	         SE1->E1_FILIAL 	== xFilial("SE1")	.AND.;
	         SE1->E1_CLIENTE	== SF2->F2_CLIENTE	.AND.;
	         SE1->E1_LOJA		== SF2->F2_LOJA		.AND.;
	         SE1->E1_PREFIXO	== SF2->F2_SERIE	.AND.;
	         SE1->E1_NUM		== SF2->F2_DOC

		lSemTit:= .F.

		//------------------------------------------------------------------------------------------------------
		//Valida se a parcela pode ser alterada
		//------------------------------------------------------------------------------------------------------
		If  nX==1 .AND. ( SE1->E1_SALDO <> SE1->E1_VALOR )
			MsgInfo("A Parcela " + Alltrim(SE1->E1_PARCELA) +" ja foi baixada. O Recálculo não será realizado!")
			lRec := .F.
			Break
		EndIf

		//---------------------------------------------
		//Atualiza as parcelas
		//---------------------------------------------
		Reclock("SE1",.F.)
			SE1->E1_EMISSAO	:= xData
			SE1->E1_EMIS1	:= xData
			SE1->E1_VENCORI	:= aParc[nX][1]
			SE1->E1_VENCTO	:= aParc[nX][1]
            //--------------------------------------------------------------------------------------------
			//A função irá considerar as datas encontradas na tabela 63 do SX5 (Tabela de Feriados),
			//os sábados (caso o parâmetro MV_SABFERI seja igual a "S") e os domingos como sendo feriados,
			//retornando assim a próxima data válida.
			//--------------------------------------------------------------------------------------------
			SE1->E1_VENCREA	:= DataValida(aParc[nX][1],.T.)

		SE1->(MsUnlock())

		nX++
		SE1->(DbSkip())

	EndDo

	If lSemTit
		MsgInfo("Nenhum Título encontrado para esta Nota Fiscal!!!")
	ElseIf lRec
		MsgInfo("Recálculo realizado com sucesso!!!")
	Endif

End Sequence

Return