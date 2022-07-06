/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Atualização                                             !
+------------------+---------------------------------------------------------+
!Modulo            ! 98 - Marketplaces                                       !
+------------------+---------------------------------------------------------+
!Nome              ! VTR0001                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! Schedule para adicionar produtos à integração           !
+------------------+---------------------------------------------------------+
!Autor             ! PAULO AFONSO ERZINGER JUNIOR                            !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 22/10/2019                                              !
+------------------+---------------------------------------------------------+
*/

#include "protheus.ch"
#include "fwmvcdef.ch"
#INCLUDE "TBICONN.CH"

User Function VTR0002(aParam)
Local cAlias := GetNextAlias()

Local cTabPrc := ""
Local cLocal  := ""

Local xCodEmp := ""
Local xCodFil := ""

Private lAuto := .T.

If isBlind()
	PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2]
Endif

// If isblind()
// 	If !RpcSetEnv(xCodEmp,xCodFil,,,"EST")
// 		ConOut('[VTR0002] - ERRO - Não foi possível Iniciar o Ambiente SIGAEST para a Empresa ' + xCodEmp + ' Filial ' + xCodFil+ ' !!!')
// 		Return
// 	EndIf
// EndIf

xCodEmp := CEMPANT
xCodFil := CFILANT
cTabPrc := GetMv("MV_LJECOMQ")
cLocal  := GetMv("MV_LJECLPE")

ConOut("*******************************************************************")
ConOut("[VTR0002] - Marketplaces - Adicionar produtos a integracao")
ConOut("[VTR0002] - Empresa: " + xCodEmp + " - Filial: " + xCodFil)
ConOut("[VTR0002] - Iniciado execucao as " + Time())

BeginSQL alias cAlias
	SELECT	SB1.R_E_C_N_O_ AS B1_RECNO, COALESCE(SB2.R_E_C_N_O_, 0) AS B2_RECNO, 
			COALESCE(SB5.R_E_C_N_O_, 0) AS B5_RECNO, COALESCE(DA1.R_E_C_N_O_, 0) AS DA1_RECNO
	
	FROM %table:SB1% (NOLOCK) SB1
	
	INNER JOIN %table:SB5% (NOLOCK) SB5 ON SB5.B5_FILIAL = %xfilial:SB5%
								 AND SB5.B5_COD = SB1.B1_COD
								 AND SB5.%notDel%
	
	LEFT JOIN %table:DA1% (NOLOCK) DA1 ON DA1.DA1_FILIAL = %xfilial:DA1%//SB1.B1_FILIAL
								 AND DA1.DA1_CODTAB = %exp:cTabPrc%
								 AND DA1.DA1_CODPRO = SB1.B1_COD
								 AND DA1.%notDel%
	
	LEFT JOIN %table:SB2% (NOLOCK) SB2 ON SB2.B2_FILIAL = %xfilial:SB2%
								 AND SB2.B2_COD = SB1.B1_COD
								 AND SB2.B2_LOCAL = %exp:cLocal%
								 AND SB2.%notDel%
	
	WHERE SB1.B1_FILIAL = %xfilial:SB1%
	AND SB1.B1_MSBLQL <> '1'
	AND SB1.B1_XECFLAG = '1'
	AND SB1.%notDel%
EndSQL

(cAlias)->(dbGoTop())

While (cAlias)->(!Eof())

	lAtuPro := .F.
	lAtuPrc := .F.
	lAtuEst := .F.

	dbSelectArea("SB1")
	dbGoTo((cAlias)->B1_RECNO)
	
	dbSelectArea("SB2")
	dbGoTo((cAlias)->B2_RECNO)

	dbSelectArea("SB5")
	dbGoTo((cAlias)->B5_RECNO)

	dbSelectArea("DA1")
	dbGoTo((cAlias)->DA1_RECNO)

	dbSelectArea("ZDD")
	dbSetOrder(1)
	dbGoTop()
	lGrava := !dbSeek(xFilial("ZDD")+ALLTRIM(SB1->B1_COD))
	
	Reclock("ZDD", lGrava)
	ZDD->ZDD_FILIAL := xFilial("ZDD")
	
	If ALLTRIM(ZDD->ZDD_PRODUT) != ALLTRIM(SB1->B1_COD)
		ZDD->ZDD_PRODUT := ALLTRIM(SB1->B1_COD)
		lAtuPro := .T.
	EndIf
	
	If ALLTRIM(ZDD->ZDD_DESCRI) != ALLTRIM(SB1->B1_DESC)
		ZDD->ZDD_DESCRI :=  ALLTRIM(SB1->B1_DESC)
		lAtuPro := .T.
	EndIf
		
	If (cAlias)->DA1_RECNO > 0
		If ZDD->ZDD_PRECO != DA1->DA1_PRCVEN
			ZDD->ZDD_TABELA := cTabPrc
			ZDD->ZDD_PRECO  := DA1->DA1_PRCVEN
			lAtuPrc := .T.
		EndIf
	EndIf
	
	If (cAlias)->B2_RECNO > 0
		If ZDD->ZDD_QUANT != (SB2->B2_QATU-SB2->B2_RESERVA-SB2->B2_QEMP-SB2->B2_QACLASS-SB2->B2_QPEDVEN)
			ZDD->ZDD_LOCAL := cLocal
			ZDD->ZDD_QUANT := SB2->B2_QATU-SB2->B2_RESERVA-SB2->B2_QEMP-SB2->B2_QACLASS-SB2->B2_QPEDVEN
			lAtuEst := .T.
		EndIf
	EndIf
	
	If ZDD->ZDD_PESO != SB1->B1_PESBRU
		ZDD->ZDD_PESO := SB1->B1_PESBRU
		lAtuPro := .T.
	EndIf

	If CEILING(ZDD->ZDD_COMP) != CEILING(SB5->B5_ECCOMP)
		ZDD->ZDD_COMP := CEILING(SB5->B5_ECCOMP)
		lAtuPro := .T.
	EndIf
	
	If CEILING(ZDD->ZDD_ALT) != CEILING(SB5->B5_ECPROFU)
		ZDD->ZDD_ALT := CEILING(SB5->B5_ECPROFU)
		lAtuPro := .T.
	EndIf
	
	If CEILING(ZDD->ZDD_LARG) != CEILING(SB5->B5_ECLARGU)
		ZDD->ZDD_LARG := CEILING(SB5->B5_ECLARGU)
		lAtuPro := .T.
	EndIf
	
	/*
	If ZDD->ZDD_COMP != SB5->B5_ECCOMP*100
		ZDD->ZDD_COMP := SB5->B5_ECCOMP*100
		lAtuPro := .T.
	EndIf
	
	If ZDD->ZDD_ALT != SB5->B5_ECPROFU*100
		ZDD->ZDD_ALT := SB5->B5_ECPROFU*100
		lAtuPro := .T.
	EndIf
	
	If ZDD->ZDD_LARG != SB5->B5_ECLARGU*100
		ZDD->ZDD_LARG := SB5->B5_ECLARGU*100
		lAtuPro := .T.
	EndIf
	*/
	
	If ALLTRIM(ZDD->ZDD_PROID) != ALLTRIM(SB1->B1_COD)
		ZDD->ZDD_PROID := ALLTRIM(SB1->B1_COD)
		lAtuPro := .T.
	EndIf
	
	If ALLTRIM(ZDD->ZDD_VARID) != ALLTRIM(SB1->B1_COD)
		ZDD->ZDD_VARID := ALLTRIM(SB1->B1_COD)
		lAtuPro := .T.
	EndIf
	
	If ALLTRIM(ZDD->ZDD_SKU) != ALLTRIM(SB1->B1_CODBAR)
		ZDD->ZDD_SKU := ALLTRIM(SB1->B1_CODBAR)
		lAtuPro := .T.
	EndIf
	
	If ALLTRIM(ZDD->ZDD_MARCA) != ALLTRIM(SB1->B1_XMARCA)
		ZDD->ZDD_MARCA := SB1->B1_XMARCA
		lAtuPro := .T.
	EndIf
	
	//cDesProd := ALLTRIM(SB1->B1_XDESCFA) + ' - ' + ALLTRIM(SB1->B1_XDESCOR) + ' - ' + ALLTRIM(SB1->B1_XDESTAM)
	cDesProd := ALLTRIM(SB1->B1_DESC)
	
	If ALLTRIM(ZDD->ZDD_NOMPRO) != ALLTRIM(cDesProd)
		ZDD->ZDD_NOMPRO := cDesProd
		lAtuPro := .T.
	EndIf
		
	cDescri := SB5->B5_ECDESCR
	
	If !Empty(SB5->B5_ECINDIC)
		cDescri += '<br><br>'+SB5->B5_ECINDIC
	EndIf
	
	If !Empty(SB5->B5_ECCARAC)
		cDescri += '<br><br>'+SB5->B5_ECCARAC
	EndIf

	If !Empty(SB5->B5_ECAPRES)
		cDescri += '<br><br>'+SB5->B5_ECAPRES
	EndIf

	If !Empty(SB5->B5_ECBENFI)
		cDescri += '<br><br>'+SB5->B5_ECBENFI
	EndIf

	If ALLTRIM(ZDD->ZDD_DESPRO) != ALLTRIM(cDescri)
		ZDD->ZDD_DESPRO := cDescri
		lAtuPro := .T.
	EndIf
	
	ZDD->ZDD_STATUS := "A"
	ZDD->ZDD_CODMKT := "001"
	
	If lGrava
		ZDD->ZDD_ATUPRO := "S"
		ZDD->ZDD_ATUEST := "S"
		ZDD->ZDD_DATUES := DATE()
		ZDD->ZDD_HATUES := TIME()
		ZDD->ZDD_ATUPRC := "S"
		ZDD->ZDD_DATA   := DATE()
		ZDD->ZDD_HORA   := TIME()
	Else
		If lAtuPro
			ZDD->ZDD_ATUPRO := "S"
		EndIf
		
		If lAtuEst
			ZDD->ZDD_ATUEST := "S"
			ZDD->ZDD_DATUES := DATE()
			ZDD->ZDD_HATUES := TIME()
		EndIf
		
		If lAtuPrc
			ZDD->ZDD_ATUPRC := "S"
			ZDD->ZDD_DATA   := DATE()
			ZDD->ZDD_HORA   := TIME()
		EndIf
	EndIf
	
	ZDD->(MsUnlock())

	(cAlias)->(dbSkip())
EndDo

If SELECT(cAlias) > 0
	(cAlias)->(dbCloseArea())
EndIf

/* 19.10.20 - Funaki - Incluido tratamento para produtos inativos no marketplace */
beginsql alias cAlias
	SELECT ZDD.R_E_C_N_O_ RECNUM
	  FROM %table:SB1% SB1
	  JOIN %table:ZDD% ZDD ON (ZDD.ZDD_FILIAL = %xfilial:ZDD% AND ZDD.ZDD_PRODUT = SB1.B1_COD AND ZDD.ZDD_STATUS = 'A' AND ZDD.%NotDel%)
	 WHERE SB1.B1_FILIAL = %xfilial:SB1%
	   AND SB1.B1_MSBLQL <> '1'
	   AND SB1.B1_XECFLAG = '2'
	   AND SB1.%NotDel%
endsql

while !(cAlias)->(eof())
	dbselectarea("ZDD")
	ZDD->(dbgoto((cAlias)->RECNUM))

	reclock("ZDD",.f.)
	ZDD->ZDD_STATUS := "I"
	ZDD->ZDD_QUANT := 0
	ZDD->ZDD_ATUPRO := "S"
	ZDD->ZDD_ATUEST := "S"
	ZDD->ZDD_DATUES := date()
	ZDD->ZDD_HATUES := time()
	msunlock("ZDD")

	(cAlias)->(dbskip())
enddo
(cAlias)->(dbclosearea())

ConOut("[VTR0002] - FIM Execucao as " + Time())
ConOut("*******************************************************************")

If lAuto
	RpcClearEnv()
EndIf

Return
