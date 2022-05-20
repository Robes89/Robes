#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ XRODS      ³ Autor ³Leandro da Silva Duarte³ Data ³10/01/2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ ROTINA DE AJUSTES DA SBF PARA P INVENTARIO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Protheus 12                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static FUNCTION XRODS()
Local bQuerySE1			:= {|| Iif(Select("TRB_SE1") > 0, TRB_SE1->(dbCloseArea()), Nil), dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB_SE1",.T.,.T.) , dbSelectArea("TRB_SE1"),TRB_SE1->(dbGoTop())}
lOCAL cQuery := " SELECT B.B2_FILIAL, B.B2_COD, B.B2_LOCAL,B.B2_QATU-B2_QACLASS AS QTD_SB2, C.BF_QUANT AS QTD_SBF "
cQuery += "   FROM SB2010 B, (SELECT A.BF_FILIAL, BF_PRODUTO, A.BF_LOCAL, SUM(BF_QUANT) AS BF_QUANT "
cQuery += "                     FROM SBF010 A "
cQuery += "                    WHERE A.D_E_L_E_T_ = ' ' "
cQuery += "                   GROUP BY A.BF_FILIAL, BF_PRODUTO, A.BF_LOCAL) C "
cQuery += "  WHERE B.B2_FILIAL = C.BF_FILIAL "
cQuery += "    AND B.B2_COD = C.BF_PRODUTO "
cQuery += "    AND B.B2_LOCAL = C.BF_LOCAL "
cQuery += "    AND B.D_E_L_E_T_ = ' ' "
cQuery += "    AND B.B2_QATU-B2_QACLASS <> C.BF_QUANT "
Eval(bQuerySE1) 
TCSQLEXEC("SELECT * INTO SBF_"+DTOS(DATE())+REPLACE(TIME(),':','')+" FROM SBF010")
TCSQLEXEC("SELECT * INTO SB2_"+DTOS(DATE())+REPLACE(TIME(),':','')+" FROM SB2010")
SBF->(DBSETORDER(2))
conout('iniciando ==========================================================')
WHILE TRB_SE1->(!EOF())
	CuPD := "UPDATE SBF010 SET BF_QUANT = "+CvALTOCHAR(TRB_SE1->QTD_SB2)+", BF_EMPENHO = 0 WHERE B7_PRODUTO = '"+TRB_SE1->B2_COD+"' AND BF_FILIAL = '"+TRB_SE1->B2_FILIAL+"' AND BF_LOCAL = '"+TRB_SE1->B2_LOCAL+"' AND D_E_L_E_T_ = ' '"
	TCSQLEXEC(CuPD) 
	TCSQLEXEC('COMMIT')
	CONOUT(CuPD)
	IF SBF->(DBSEEK(TRB_SE1->B2_FILIAL+TRB_SE1->B2_COD+TRB_SE1->B2_LOCAL))
	   RECLOCK("SBF",.F.)
	       SBF->BF_EMPENHO := 0
	       SBF->BF_QUANT   := TRB_SE1->QTD_SB2
	   MSUNLOCK()
	ENDIF 
	TRB_SE1->(dbskip())
END
conout('Termino ==========================================================')
RETURN()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MT340IN    ³ Autor ³Leandro da Silva Duarte³ Data ³10/01/2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³PONTO DE ENTRADA PARA AJUSTAR A TABELA SBF ANTES DE RODAR O   ³±±
±±³Descricao ³INVENTARIO                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Protheus 12                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MT340IN()
    XRODS()
Return(.T.)