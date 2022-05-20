#INCLUDE "TOTVS.CH"
#include "TopConn.Ch"
#INCLUDE "PROTHEUS.CH"
//#INCLUDE "TBIConn.ch"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "APWEBSRV.CH"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TEAMEntreg�Autor  �Microsiga           � Data �  07/06/17   ���
�������������������������������������������������������������������������͹��
���Desc.     � Controle de Entrega - Inclusao/Alteracao                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function TEAMEntreg()
Local oButton1
Local oButton2
Local oComboBo1
Local nComboBo1 := 1
Local oGet1
Local cGet1 := space(10)
Local oGet2
Local cGet2 := CTOD("  /  /  ")
Local oGet3
Local cGet3 := CTOD("  /  /  ")
Local oGet4
Local cGet4 := CTOD("  /  /  ")
Local oGet5
Local cGet5 := CTOD("  /  /  ")
Local oGet6
Local cGet6 := CTOD("  /  /  ")
Local oGet7
Local cGet7 := CTOD("  /  /  ")
Local oGet8
Local cGet8 := CTOD("  /  /  ")
Local oGet10
Local cGet10 := Space(150)
Local oGroup1
Local oSay1
Local oSay10
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSay6
Local oSay7
Local oSay8
Local oSay9
Local xValSt
Static oDlg

cGet1		:= SF2->F2_XNCOLET
cGet2		:= SF2->F2_XDCOLET				//"Data Prevista Coleta"
//cGet3		:= SF2->F2_XDRETIR				//"Data de Retirada"
cGet4		:= SF2->F2_XDTENT				//"Data da Entrega"
cGet5		:= SF2->F2_XDAGENT				//"Data de Agendamento Entrega"
cGet6		:= SF2->F2_XDTSAID				//"Data de Saida da Mercadoria"
cGet7		:= SF2->F2_XDRETRA				//"Data do Retrabalho"
cGet8		:= SF2->F2_XARMAZE				//"Armazem"
nComboBo1 	:= Val(SF2->F2_XSTATUS)			//"Status do transporte"
xValSt		:= Val(SF2->F2_XSTATUS)			//"Status do transporte"

cGet10		:= SF2->F2_XOBSCOL				//"Observa��o da coleta"

dbSelectArea("SD2")
dbSetOrder(3)
If DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
	cGet8	:=   Posicione("NNR" , 1 , xFilial("NNR") + SD2->D2_LOCAL ,"NNR_DESCRI")
Endif


DEFINE MSDIALOG oDlg TITLE "Controle Logistico" FROM 000, 000  TO 450, 750 COLORS 0, 16777215 PIXEL

@ 008, 008 GROUP oGroup1 TO 209, 365 OF oDlg COLOR 0, 16777215 PIXEL

@ 018, 118 MSGET oGet8 VAR cGet8 													SIZE 060, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
@ 018, 022 SAY oSay8 PROMPT "Armazem" 												SIZE 048, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 034, 022 SAY oSay5 PROMPT "Data do Retrabalho" 									SIZE 084, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 034, 118 MSGET oGet7 VAR cGet7 													SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
@ 051, 022 SAY oSay2 PROMPT "Data Prevista Coleta" 									SIZE 059, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 051, 118 MSGET oGet2 VAR cGet2 													SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
@ 068, 022 SAY oSay1 PROMPT "Numero da Coleta" 										SIZE 051, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 068, 118 MSGET oGet1 VAR cGet1 													SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
@ 084, 022 SAY oSay4 PROMPT "Data de Agendamento Entrega" 							SIZE 080, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 084, 118 MSGET oGet5 VAR cGet5 													SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
@ 098, 118 MSGET oGet6 VAR cGet6 													SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
@ 098, 022 SAY oSay6 PROMPT "Data de Saida da Mercadoria" 							SIZE 085, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 115, 022 SAY oSay7 PROMPT "Data da Entrega" 										SIZE 063, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 115, 118 MSGET oGet4 VAR cGet4 													SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
@ 132, 022 SAY oSay9 PROMPT "Status do transporte" 									SIZE 061, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 132, 119 MSCOMBOBOX oComboBo1 VAR nComboBo1 ITEMS {"1=Entregue","2=Devolu��o",""};
SIZE 072, 010 OF oDlg COLORS 0, 16777215 PIXEL
@ 148, 022 SAY oSay10 PROMPT "Observa��o da coleta" 								SIZE 068, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 157, 023 MSGET oGet10 VAR cGet10 													SIZE 324, 010 OF oDlg COLORS 0, 16777215 PIXEL
@ 180, 262 BUTTON oButton1 PROMPT "&Salvar"	ACTION(_GRAVADADOS(cGet1,cGet2,cGet4,cGet5,cGet6,cGet7,cGet8,nComboBo1,cGet10,xValSt),oDlg:End());
SIZE 037, 012 OF oDlg PIXEL
@ 180, 311 BUTTON oButton2 PROMPT "S&air"  	ACTION(oDlg:End())						SIZE 037, 012 OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg CENTERED

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TEAMENTREG�Autor  �Microsiga           � Data �  07/06/17   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function _GRAVADADOS(xPar1,xPar2,xPar4,xPar5,xPar6,xPar7,xPar8,xPar9,xPar10,xPar11)

/*
If xPar11 > 0
If!("Administrador" $ cusuario)
Alert("Contate o Administrador para altera��o!!" )
Return
Endif
Endif
*/
If VALTYPE(XPAR9) == "N"
	If Alltrim(STR(xPar9))=="0"
		xPar9:=""
	Else
		xPar9 := Alltrim(STR(xPar9))
	Endif
Endif

DbSelectArea("SF2")
Reclock("SF2",.F.)
SF2->F2_XNCOLET	:= xPar1	//"Numero da Coleta"
SF2->F2_XDCOLET	:= xPar2	//"Data Prevista Coleta"
//	SF2->F2_XDRETIR	:= xPar3	//"Data de Retirada"
SF2->F2_XDTENT	:= xPar4	//"Data da Entrega"
SF2->F2_XDAGENT	:= xPar5	//"Data de Agendamento Entrega"
SF2->F2_XDTSAID	:= xPar6	//"Data de Saida da Mercadoria"
SF2->F2_XDRETRA	:= xPar7	//"Data do Retrabalho"
SF2->F2_XARMAZE	:= xPar8	//"Armazem"
SF2->F2_XSTATUS	:= xPar9	//"Status do transporte"
SF2->F2_XOBSCOL	:= xPar10	//"Observa��o da coleta"
SF2->(MsUnlock())

//Chama rotina de ajuste de vencimento das parcelas.
AjustVenc(F2_FILIAL, F2_CLIENTE, F2_LOJA, F2_SERIE, F2_DOC,F2_XDTENT)

Return

/*/{Protheus.doc} AjustVenc()
Esta fun��o tem a inten��o de ajusatar o vencimento das parcelas de acordo com
padroes previamente estabelecidos.
Altera��o somente dos dados do t�tulo, sem altera��o na FKF e FKG.
@type  Static Function
@author Jo�o Silva
@since 10/01/2020
@version 1.0
@param F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC
@return NULL
@example: AjustVenc()
/*/
Static Function AjustVenc(_FILIAL, _CLIENTE, _LOJA, _PREFIXO, _NUM, _XDTENT)

LOCAL aAreaSE1 	:= SE1->(GetArea())
LOCAL cKeySE1	:= _FILIAL+_CLIENTE+_LOJA+_PREFIXO+_NUM
LOCAL cNreduz	:= ""

PRIVATE lMsErroAuto := .F.

IF ApMsgYesNo("Ol�, apartir deste momento o sistema ira atualizar as parcelas existentes";
	+" no contas a reber de acorodo com a regar do clietne. Se deseja continuar";
	+" clique em 'SIM' caso contrario clique em 'N�o' para finalizar  ", "Team Tex")
	
	DbSelectArea("SE1")
	SE1->(DbSetOrder(2))//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	
	IF SE1->(DbSeek(cKeySE1)) //Altera��o deve ter o registro SE1 posicionado
		
		WHILE SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == cKeySE1			
			cNreduz:= Posicione("SA1",1,xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,"A1_NREDUZ")
			
			//Atualiza vencimentos SE1
			WHILE SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == cKeySE1
				RecLock("SE1",.F.)
				IF !EMPTY(SE1->E1_BAIXA) 	
					Alert("O t�tulo informado n�o poder� ter a data de vencimento alterada pois j� se encontra baixado.")
                	Return()
				ENDIF
				
				IF SE1->E1_PARCELA $ 'A |  '
					dVencto:=DaySum( _XDTENT, 91)//1� Vencimento 90 Dias + 1 apos entrega.
					NovaData(cNreduz,dVencto)
				ELSE
					dVencto	:= DaySum(dVencto,30)//Passo para o proximo m�s
					NovaData(cNreduz,dVencto)
				ENDIF
				
				SE1->(MsUnLock())
				SE1->(DbSkip())
			ENDDO			
			/*
			aTit := {{"E1_PREFIXO"	, SE1->E1_PREFIXO	, NIL },;
			{ "E1_NUM"		, SE1->E1_NUM		, NIL },;
			{ "E1_PARCELA"	, SE1->E1_PARCELA 	, NIL },;
			{ "E1_TIPO"		, SE1->E1_TIPO 		, NIL },;
			{ "E1_NATUREZ"	, SE1->E1_NATUREZA 	, NIL },;
			{ "E1_CLIENTE"	, SE1->E1_CLIENTE 	, NIL },;
			{ "E1_EMISSAO"	, SE1->E1_EMISSAO	, NIL },;
			{ "E1_VENCTO"	, CtoD(_XDTENT)		, NIL },;
			{ "E1_VENCREA"	, CtoD(_XDTENT)		, NIL}}
			
			//MsExecAuto( { |a,b, c, d,e, f, g | FINA040(a,b, c, d,e, f, g)} , a  tit, 4,,,,, ) // 3 - Inclusao, 4 - Altera��o, 5 - Exclus�o
			MsExecAuto( { |a,b, c, d,e, f, g | FINA040(a,b, c, d,e, f, g)} , a  tit, 4,,,,, ) // 3 - Inclusao, 4 - Altera��o, 5 - Exclus�o
			*/
			SE1->(DbSkip())
		ENDDO
		
		IF lMsErroAuto
			MostraErro()
			
		ELSE                  
			ApMsgInfo("T�tulo(s) alterado(s) com sucesso!","Team Tex" )
			
		ENDIF
	ELSE
		ApMsgInfo("N�o encontrou o SE1")
		Return()
		
	ENDIF
	Return()
ENDIF
RestArea(aAreaSE1)
Return()

Static Function NovaData(cNreduz,dVencto)

//WMS
IF "WMS" $ cNreduz .OR. "WMB" $ cNreduz .OR. "BOMPRECO" $ cNreduz
	IF 	Day(dVencto) <= 14 //Se o dia do mes for menor que 14 o vencimento vai para o dia 14 do mes atual se n�o para o dia 14 do proximo m�s.
		dVencto := DaySum(dVencto,(14 - Day(dVencto)))//Ajusto para a data para dia 14
		SE1->E1_VENCTO := dVencto
	ELSE
		dVencto	:= DaySum(dVencto,30)//Passo para o proximo m�s
		dVencto := DaySub(dVencto,(Day(dVencto)-14))//Ajusto para a data para dia 14
		SE1->E1_VENCTO := dVencto
	ENDIF	

ELSEIF "CARREFOUR" $ cNreduz
	IF 	Day(dVencto) <= 10 //Se o dia do mes for menos que 10 o vencimento vai para o dia 10 do mes atual se n�o para o dia 10 do proximo m�s.
		dVencto := DaySum(dVencto,(10 - Day(dVencto)))//Ajusto para a data para dia 10
		SE1->E1_VENCTO := dVencto
	ELSE
		dVencto	:= DaySum(dVencto,30)//Passo para o proximo m�s
		dVencto := DaySub(dVencto,(Day(dVencto)-10))//Ajusto para a data para dia 10
		SE1->E1_VENCTO := dVencto
	ENDIF	

ELSEIF "HAVAN" $ cNreduz
	//Se o dia do mes for menor ou igual a 15 o vencimento vai para o dia 15 do mes atual.
	//Se o dia do mes for maior que 15 o vencimento vai para o ultimo dia do m�s. 
	IF 	Day(dVencto) <= 15 
		dVencto := DaySum(dVencto,(15 - Day(dVencto)))//Ajusto para a data para dia 15
		SE1->E1_VENCTO := dVencto
	ELSE                                                                          
		dVencto := LastDate(dVencto)//Ajusto para o ultimo dia do m�s.
		SE1->E1_VENCTO := dVencto
	ENDIF	

ELSEIF "LE BISCUIT" $ cNreduz
	//Se o dia do mes for menor ou igual a 05 o vencimento vai para o dia 05 do mes atual.
	//Se o dia do mes for maior que dia 05 e menor ou igual a 15 o vencimento vai para o dia 15 do mes atual.
	//Se o dia do mes for maior que dia 15 e menor ou igual a 25 o vencimento vai para o dia 25 do mes atual.
	//Se o dia do mes for maior que dia 25 o vencimento vai para o dia 05 do proximo mes.	
	IF 	Day(dVencto) <= 5
		dVencto := DaySum(dVencto,(5 - Day(dVencto)))//Ajusto para a data para dia 5
		SE1->E1_VENCTO := dVencto
		
	ELSEIF	Day(dVencto) > 5 .AND. Day(dVencto) <= 15 
		dVencto := DaySum(dVencto,(15 - Day(dVencto)))//Ajusto para a data para dia 15
		SE1->E1_VENCTO := dVencto
			
	ELSEIF Day(dVencto) > 15 .AND. Day(dVencto) <= 25 
		dVencto := DaySum(dVencto,(25 - Day(dVencto)))//Ajusto para a data para dia 25
		SE1->E1_VENCTO := dVencto

	ELSEIF Day(dVencto) > 25
		dVencto := DaySum(dVencto,30)//Passo para o proximo m�s		
		dVencto := DaySub(dVencto,(Day(dVencto)-5))//Ajusto para a data para dia 5 do proximo mes
		SE1->E1_VENCTO := dVencto					

	ENDIF	
		
ELSEIF "MAGAZINE LUIZA" $ cNreduz .OR. "VIA VAREJO" $ cNreduz .OR. "MAGAZINE AMERICANA" $ cNreduz
	//Se o dia do mes for menor ou igual a 10 o vencimento vai para o dia 05 do mes atual.
	//Se o dia do mes for maior que dia 10 e menor ou igual a 20 o vencimento vai para o dia 15 do mes atual.
	//Se o dia do mes for maior que dia 20 o vencimento vai para o ultimo dia do mes.
	IF 	Day(dVencto) <= 10
		dVencto := DaySum(dVencto,(10 - Day(dVencto)))//Ajusto para a data para dia 10
		SE1->E1_VENCTO := dVencto
		
	ELSEIF	Day(dVencto) > 10 .AND. Day(dVencto) <= 20
		dVencto := DaySum(dVencto,(20 - Day(dVencto)))//Ajusto para a data para dia 20
		SE1->E1_VENCTO := dVencto
			
	ELSEIF Day(dVencto) > 20
		dVencto := LastDate(dVencto)//Ajusto para o ultimo dia do mes.
		SE1->E1_VENCTO := dVencto					

	ENDIF			
ENDIF
Return()