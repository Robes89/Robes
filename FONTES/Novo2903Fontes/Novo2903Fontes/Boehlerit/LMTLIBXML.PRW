#INCLUDE "rwmake.ch"
#include "topconn.ch"
#Include "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLMTLIBXML     บ Autor ณ Paulo Trigo	Data  22/02/2012      นฑฑ
ฑฑบDescricao ณ Libera nota fiscal emitida para gera novo XML.             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LMT                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function LMTLIBXML()


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Private _oDlg1				// Dialog Principal
Private _Numnota := space(9)
Private _Sernota := space(3)
Private _Tiponota := "S"
Private cCadastro := "Ajusta Chave NFE"
dbSelectArea("SF3")
dbSetOrder(6)      // F3_FILIAL+F3_NFISCAL+F3_SERIE

dbSelectArea("SFT")
dbSetOrder(6)      // FT_FILIAL+FT_TIPOMOV+FT_NFISCAL+FT_SERIE

DEFINE MSDIALOG oDlg1 FROM 64,33 TO 300,425 TITLE cCadastro PIXEL

@ 003,011 Say "N๚mero Nota : " Size 60,6 PIXEL OF ODlg1
@ 015,011 Say "S้rie Nota : " Size 60,6 PIXEL OF ODlg1
@ 027,011 Say "Tipo NFiscal: (E)ntrada / (S)aํda : " Size 80,6 PIXEL OF ODlg1

@ 003,150 MsGet _Numnota picture "@E 999999999"  Size 40,6 PIXEL OF ODlg1
@ 015,150 MsGet _Sernota Size 40,6 picture "@E 999" PIXEL OF ODlg1
@ 027,150 MsGet _Tiponota Size 40,6 picture "@!" PIXEL OF ODlg1

@ 097,120 BmpButton Type 01 Action U_ProcFun(_Numnota,_Sernota,_Tiponota)
@ 097,160 BmpButton Type 02 Action U_wSair1()

_lFechar := .F.

ACTIVATE MSDIALOG oDlg1 CENTERED valid _lFechar

RETURN

User Function ProcFun(_Numnota,_Sernota,_Tiponota)

Local _cQuery
Local _EstExp := "EX"

// Criar Arquivo Temporario
aStru:={} 
AADD(aStru,{"SERIE" ,"C",03,00})
AADD(aStru,{"NFISCAL" ,"C",09,00})
AADD(aStru,{"CHVNFE" ,"C",44,00})

oTemptable := FWTemporaryTable():New( "TMPSF3")
oTemptable:SetFields( ASTRU )
oTempTable:AddIndex("index1", {"NFISCAL+SERIE"} )
oTempTable:Create()

//_cFile:=CRIATRAB(ASTRU,.T.) 
//dbusearea(.t.,,_cFile,"TMPSF3",.f.,.f.)   
//INDEX ON NFISCAL+SERIE TO &(_cFile)
	
_cArq := 'arqtemp'
_cQuery := "SELECT * "
_cQuery += "FROM SPED054 SPED "
_cQuery += "WHERE SUBSTR(NFE_ID,1,3) = '"+_Sernota+"' "
_cQuery +=" AND SUBSTR(NFE_ID,4,9) = '"+_Numnota+"' "
_cQuery += "AND SPED.D_E_L_E_T_ <> '*' "
_cQuery += "order by NFE_ID "
_cQuery := ChangeQuery(_cQuery)

Memowrit('SPED054.SQL',_cQuery)

_cQuery := ChangeQuery(_cQuery)
MsAguarde({|| dbUseArea(.T., "TOPCONN",tcGenQry(,,_cQuery),_cArq,.T.,.T.)},OemToAnsi("Chave Nota Fiscal Eletr๔nica"))

dbSelectArea(_cArq)
dbGoTop()

if Eof()
	MSGINFO("Nota Fiscal de Saํda, ou, a S้rie, nใo esta cadastrada. Efetue nova consulta.")
	U_wSair1()
	return()
endif

while !Eof()        

	dbSelectArea("TMPSF3")
	dbSeek(substr((_cArq)->NFE_ID,1,3)+ALLTRIM(SUBSTR((_cArq)->NFE_ID,4,9)))
	if !Found()
		RECLOCK("TMPSF3",.T.)
		TMPSF3->SERIE	:= substr((_cArq)->NFE_ID,1,3)
		TMPSF3->NFISCAL	:= ALLTRIM(SUBSTR((_cArq)->NFE_ID,4,9))
		if len((_cArq)->NFE_CHV) > 39
			TMPSF3->CHVNFE	:= (_cArq)->NFE_CHV
		elseif len((_cArq)->NFE_CHV) == 39
			_wAno := strzero(year((_cArq)->DTREC_SEFR - 2000),2)
			_wMes := strzero(month((_cArq)->DTREC_SEFR),2)
			TMPSF3->CHVNFE	:= substr((_cArq)->NFE_CHV,1,2)+_wAno+_wMes+substr((_cArq)->NFE_CHV,3,42)
		endif	
		MSUNLOCK()
	endif
	dbSelectArea(_cArq)
	dbSkip()

end

dbSelectArea("TMPSF3")
dbGoTop()
while !Eof()        
	dbSelectArea("SF3")
	dbSeek(xFilial("SF3")+TMPSF3->NFISCAL+TMPSF3->SERIE)
	if Found()
		while SF3->F3_NFISCAL == TMPSF3->NFISCAL .AND.;
			SF3->F3_SERIE == TMPSF3->SERIE .AND. !EOF()
			RecLock("SF3",.F.)
	       	REPLACE  SF3->F3_CHVNFE WITH TMPSF3->CHVNFE
			MsUnlock()
			dbSelectArea("SF3")
			dbSkip()
		end
    endif

	dbSelectArea("SFT")
	dbSeek(xFilial("SFT")+_Tiponota+TMPSF3->NFISCAL+TMPSF3->SERIE)
	if Found()
		while SFT->FT_TIPOMOV == _Tiponota .AND.  SFT->FT_NFISCAL == TMPSF3->NFISCAL .AND.;
			 SFT->FT_SERIE == TMPSF3->SERIE .AND. !EOF()
			RecLock("SFT",.F.)
		    REPLACE  SFT->FT_CHVNFE WITH TMPSF3->CHVNFE
			MsUnlock()
			dbSelectArea("SFT")
			dbSkip()
		end
    endif

	dbSelectArea("TMPSF3")
    dbSkip()
end

dbSelectArea("TMPSF3")
dbclosearea()

U_wSair1()

Return()

