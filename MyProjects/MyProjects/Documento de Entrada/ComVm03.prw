#include "Protheus.ch"
#include "Rwmake.ch"

/*  
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  �COMVM03   �Autor  �Henio Brasil           � Data �26/08/2019 ���
��������������������������������������������������������������������������Ĵ��
���          �Programa de Validacao para reducao de base de calculo Icms   ���
��������������������������������������������������������������������������Ĵ��
���Descri�ao �                                                             ���
���          �                                                             ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Cliente   �                                                             ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������*/

User Function COMVM03()	 

Local lGetTES	:= .T. 
Local cCodProd	:= GDFieldGet("D1_COD") 			// Updated by Henio
Local nQtdEnt	:= GDFieldGet("D1_QUANT") 			// Updated by Henio
Local nVlrUni	:= GDFieldGet("D1_VUNIT") 
Local nVlrTot	:= GDFieldGet("D1_TOTAL")  
Local cTipEnt 	:= GDFieldGet("D1_TES")				// Updated by Henio
Local nBaseIcm	:= GDFieldGet("D1_BASEICM")			// Updated by Henio
Local nValIcms	:= GDFieldGet("D1_VALICM")			// Updated by Henio
Local nPerIcms	:= GDFieldGet("D1_PICM")			// Updated by Henio
/* 
���������������������������������������������������������������������Ŀ
� Cria os parametros da rotina                                        �
�����������������������������������������������������������������������*/       
If lGetTES .And. !Empty(cTipEnt)                                               
	// MsgAlert("Abriu a validacao COMVC01, codigo TES "+cTipEnt) 
	If nVlrTot<>0 
		Vm01UpdBase(cCodProd,nQtdEnt,nVlrUni,cTipEnt,nPerIcms,nBaseIcm,nValIcms) 
	Endif 
Endif 	
Return .T. 


/* 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Vm01UpdBase �Autor  �Henio Brasil       � Data � 29/09/2014 ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao de abertura e leitura de arquivo Excel para importar ���
���          �dados para o ERP.                                           ���
�������������������������������������������������������������������������͹��
���Cliente   �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function Vm01UpdBase(cCodProd,nQtdEnt,nVlrUni,cTipEnt,nPerIcms,nBaseIcm,nValIcms) 

Local oDlgEd 
Local nOpcB		:= 0 
Local nVlrDifIcm:= 0 
Local cPrdLabel	:= "Produto :" 
Local cTesLabel	:= "Cod TES:" 
Local cPerReduc	:= "% de Redu��o :"
Local cBaseIcms	:= "Base de Icms:"
Local cBsIcmRed	:= "Base Reduzida:"
Local cValIcms	:= "Valor Icms:"
Local nBsPadIcm	:= GDFieldGet("D1_XBSREGE")			// D1_XBICMPD = Base Calculo Padrao 
Local nVlPadIcm	:= GDFieldGet("D1_XVREGES")			// D1_XVICMRD = Valor Icms Normal sem Reducao 
// Local nPerRed 	:= SuperGetMv("MV_PICMRED", .T., "35.00")
Local nPosVIcm	:= Ascan(aHeader, {|x| AllTrim(Upper(x[2])) = "D1_VALICM"})  
Local nPosDIcm	:= Ascan(aHeader, {|x| AllTrim(Upper(x[2])) = "D1_XVDIFRE"})  
Local nPerRed 	:= Posicione("SF4", 1, xFilial("SF4")+cTipEnt,"F4_PICMDIF")   	// campo do Topo pasta Impostos
Local nIcmDif 	:= Posicione("SF4", 1, xFilial("SF4")+cTipEnt,"F4_ICMSDIF")   		// nao usado 
Local lRegEsp 	:=(Posicione("SF4", 1, xFilial("SF4")+cTipEnt,"F4_XREGESP")=='1') 

If !lRegEsp
    Return 
Endif 
// MsgAlert("Entrou na funcao da tela de reducao")        

nPerRedF4	:= nPerRed
nBsIcmRed	:= Round((nBaseIcm*(100-nPerRed))/100,2) 
nValIcms	:= Round((nBsIcmRed*nPerIcms)/100,2) 
Define Font oFont2 Name "Ms Sans Serif" Size 0,-9 Bold 
Define MsDialog oDlgEd From 005, 006 To 200,490 Title "Define % de Redu��o de Base " Pixel 

@ 008,014 Say	cPrdLabel	Size 035, 08 Font oFont2 Of oDlgEd Pixel    //	linha 1
@ 008,084 Say	cTesLabel	Size 045, 08 Font oFont2 Of oDlgEd Pixel    //	linha 1
@ 008,154 Say	cPerReduc	Size 045, 08 Font oFont2 Of oDlgEd Pixel    //	linha 1
@ 018,178 Say	"%"			Size 005, 08 Font oFont2 Of oDlgEd Pixel    //	linha 1                                                                                   

@ 034,014 Say	cBaseIcms	Size 055, 08 Font oFont2 Of oDlgEd Pixel    //	linha 2
@ 034,084 Say	cBsIcmRed	Size 055, 08 Font oFont2 Of oDlgEd Pixel 	//	linha 2
@ 034,154 Say	cValIcms	Size 055, 08 Font oFont2 Of oDlgEd Pixel	//	linha 2
//-------------------------------------------------------------------------------------------                                 
@ 018,014  MsGet oCodPrd 	Var cCodProd Size  40,08 Pixel Of oDlgEd Picture "@!"  When .F.
@ 018,084  MsGet oTesPrd	Var cTipEnt	 Size  20,08 Pixel Of oDlgEd Picture "@!"  When .F.
@ 018,154  MsGet oPerRed	Var nPerRed  Size  10,08 Pixel Of oDlgEd Picture "@E 99"  		When .T. Valid Pm01VldBase(oDlgEd,nPerRedF4,nPerRed,nPerIcms,nBaseIcm,@nBsIcmRed,@nValIcms) 

@ 044,014  MsGet oBasIcm	Var nBaseIcm  Size 50,08 Pixel Of oDlgEd Picture "@E 9,999,999.99"  When .F. 
@ 044,084  MsGet oBasRed	Var nBsIcmRed Size 50,08 Pixel Of oDlgEd Picture "@E 9,999,999.99"  When .F. 
@ 044,154  MsGet oVlrIcm	Var nValIcms  Size 50,08 Pixel Of oDlgEd Picture "@E 9,999,999.99"  When .F. 

Define SButton 	From 80,175 Type 1 Action (nOpcB:=1, oDlgEd:End()) Enable Of oDlgEd	// 80,175
Define SButton 	From 80,206 Type 2 Action (nOpcB:=2, oDlgEd:End()) Enable Of oDlgEd 
Activate MsDialog oDlgEd Centered

/* 
��������������������������������������������������������������Ŀ
�Grava valores no browse preparando para o Faturamento         �
����������������������������������������������������������������*/  
If nOpcB == 1               
	nVlPadIcm	:= Round((nBaseIcm*nPerIcms)/100,2) 		// Para corrigir a base do ICMS
	GDFieldPut("D1_VALICM"	, nValIcms) 	   	// deve gravar a Base Reduzida 
	GDFieldPut("D1_XBSREGE"	, nBaseIcm) 	   	// deve gravar a Base Reduzida 
	GDFieldPut("D1_XVREGES"	, nVlPadIcm) 		// deve gravar o valor Original do ICMS 
	aCols[n][nPosVIcm] := nValIcms  
	aCols[n][nPosDIcm] := nVlPadIcm - nValIcms	// Grava a diferenca do Icms calculado para atualizar CD2
	MaFisRef("IT_VALICM","MT100" ,nValIcms)		// M->D1_VALICM	
Endif        
Return       


Static Function Pm01VldBase(oDlgEd,nPerRedF4,nPerRed,nPerIcms,nBaseIcm,nBsIcmRed,nValIcms) 
                                             
If nPerRedF4 <> nPerRed
	nNewBase:= Round((nBaseIcm*(100-nPerRed))/100,2) 
	nValIcms:= Round((nNewBase*nPerIcms)/100,2) 
	nBsIcmRed:= nNewBase
	oBasIcm:Refresh()                  
	oVlrIcm:Refresh() 
Endif 
Return 
