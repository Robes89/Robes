#include "protheus.ch"
#include "rwmake.ch"
#include "tcbrowse.ch"
#Include "colors.ch"
#include "vkey.ch"
#Include "Font.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNOVO2     บ Autor ณ AP6 IDE            บ Data ณ  15/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Codigo gerado pelo AP6 IDE.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function LMTFATEXP()


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู


Private cString := "SF1"
Private oDlg1
Private _Datinic := ctod("  /  /  ")
Private _Datafim := ctod("  /  /  ")
Private cCadastro := "Complemento de Importa็ใo"
dbSelectArea("SF1")
dbSetOrder(1)

DEFINE MSDIALOG oDlg1 FROM 64,33 TO 300,425 TITLE cCadastro PIXEL

@ 003,011 Say "Da Emissใo    : " Size 60,6 PIXEL OF ODlg1
@ 015,011 Say "At้ a Emissใo : " Size 60,6 PIXEL OF ODlg1

@ 003,080 MsGet _Datinic picture "99/99/99"  Size 50,6 PIXEL OF ODlg1
@ 015,080 MsGet _Datafim picture "99/99/99" Size 50,6 PIXEL OF ODlg1

@ 097,120 BmpButton Type 01 Action U_ProcCD5(_Datinic,_Datafim)
@ 097,160 BmpButton Type 02 Action U_WSAIR1A()

_lFechar := .F.

ACTIVATE MSDIALOG oDlg1 CENTERED valid _lFechar

Return

User Function ProcCD5(_Datinic,_Datafim)

Local _cQuery
Local _EstExp := "EX"

// Criar Arquivo Temporario
aStru:={} 
AADD(aStru,{"CD5_FILIAL" ,"C",02,00})
AADD(aStru,{"CD5_DOC" ,"C",09,00})
AADD(aStru,{"CD5_SERIE"  ,"C",03,00})
AADD(aStru,{"CD5_ESPEC" ,"C",05,00})
AADD(aStru,{"CD5_FORNEC" ,"C",06,00})
AADD(aStru,{"CD5_LOJA" ,"C",02,00})
AADD(aStru,{"CD5_TPIMP" ,"C",01,00})
AADD(aStru,{"CD5_DOCIMP" ,"C",50,00})
AADD(aStru,{"CD5_BSPIS" ,"N",14,02})
AADD(aStru,{"CD5_ALPIS" ,"N",05,02})
AADD(aStru,{"CD5_VLPIS" ,"N",14,02})
AADD(aStru,{"CD5_BSCOF" ,"N",14,02})
AADD(aStru,{"CD5_ALCOF" ,"N",05,02})
AADD(aStru,{"CD5_VLCOF" ,"N",14,02})
AADD(aStru,{"CD5_ACDRAW" ,"C",20,00})
AADD(aStru,{"CD5_DTPPIS" ,"D",08,00})
AADD(aStru,{"CD5_DTPCOF" ,"D",08,00})
AADD(aStru,{"CD5_LOCAL" ,"C",01,00})
AADD(aStru,{"CD5_NDI" ,"C",10,00})
AADD(aStru,{"CD5_DTDI" ,"D",08,00})
AADD(aStru,{"CD5_LOCDES" ,"C",30,00})
AADD(aStru,{"CD5_UFDES" ,"C",02,00})
AADD(aStru,{"CD5_DTDES" ,"D",08,00})
AADD(aStru,{"CD5_CODEXP" ,"C",06,00})
AADD(aStru,{"CD5_NADIC" ,"C",03,00})
AADD(aStru,{"CD5_SQADIC" ,"C",03,00})
AADD(aStru,{"CD5_CODFAB" ,"C",06,00})
AADD(aStru,{"CD5_VDESDI" ,"N",15,02})
AADD(aStru,{"CD5_BCIMP" ,"N",15,02})
AADD(aStru,{"CD5_DSPAD" ,"N",15,02})
AADD(aStru,{"CD5_VLRII" ,"N",15,02})
AADD(aStru,{"CD5_VLRIOF" ,"N",15,02})
AADD(aStru,{"CD5_ITEM" ,"C",04,00})
	
oTemptable := FWTemporaryTable():New( "TMPCD5")
oTemptable:SetFields( aStru )
oTempTable:AddIndex("index1", {"CD5_FILIAL+CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA+CD5_DOCIMP+CD5_NADIC"} )
oTempTable:Create()

//_cFile:=CRIATRAB(ASTRU,.T.) 
//dbusearea(.t.,,_cFile,"TMPCD5",.f.,.f.)   
//INDEX ON CD5_FILIAL+CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA+CD5_DOCIMP+CD5_NADIC TO &(_cFile)
	
_cArq := 'cArq'
_cQuery := "SELECT F1_DOC, F1_SERIE, F1_ESPECIE, F1_FORNECE, F1_LOJA, F1_NDIWISE, F1_DTDIWIS, F1_LOCDESE, "
_cQuery += "F1_UFDIDES, F1_DTDESEM, F1_FABR, F1_II, F1_VLRIOF, D1_DOC, D1_SERIE, D1_BASIMP6, "
_cQuery += "D1_ALQIMP6, D1_VALIMP6, D1_BASIMP5, D1_ALQIMP5, D1_VALIMP5, D1_ADICWIS, "
_cQuery += "D1_SEQADIW, D1_ITEM, F1_EST, F1_EMISSAO, F1_FILIAL, "
_cQuery += "D1_VALDESC, D1_SEQADIW, F1_EXPORTA, D1_VALDESC "
_cQuery += "FROM "+RetSqlName("SF1") + " SF1, " + RetSqlName("SD1") + " SD1 "
_cQuery += "WHERE F1_FILIAL = D1_FILIAL "
_cQuery += "AND F1_DOC = D1_DOC "
_cQuery += "AND F1_SERIE = D1_SERIE "
_cQuery +="AND F1_EMISSAO BETWEEN '"+DTOS(_Datinic)+"' AND '"+DTOS(_Datafim)+"' "
_cQuery += "AND F1_EST = '"+_EstExp+"' "
_cQuery += "AND SF1.D_E_L_E_T_ <> '*' "
_cQuery += "AND SD1.D_E_L_E_T_ <> '*' "
_cQuery += "order by F1_DOC, F1_SERIE "
_cQuery := ChangeQuery(_cQuery)

Memowrit('TABCD5.SQL',_cQuery)
_cQuery := ChangeQuery(_cQuery)
MsAguarde({|| dbUseArea(.T., "TOPCONN",tcGenQry(,,_cQuery),_cArq,.T.,.T.)},OemToAnsi("Complemento de Importa็ใo"))
// colocar "trb"

dbSelectArea(_cArq)
dbGoTop()

while !Eof()        
						
	if (_cArq)->F1_EST <> _EstExp
		dBSkip()
		loop
	endif

	_wdtinic := ctod(substr((_cArq)->F1_EMISSAO,7,2)+"/"+substr((_cArq)->F1_EMISSAO,5,2)+"/"+substr((_cArq)->F1_EMISSAO,1,4))	

	if _wdtinic < _Datinic .and. _wdtinic > _Datafim .and. !Eof()        
		dBSkip()
		loop
	endif

	dbSelectArea("TMPCD5")
	RECLOCK("TMPCD5",.T.)
	TMPCD5->CD5_FILIAL	:= (_cArq)->F1_FILIAL
	TMPCD5->CD5_DOC		:= (_cArq)->F1_DOC
	TMPCD5->CD5_SERIE	:= (_cArq)->F1_SERIE
	TMPCD5->CD5_ESPEC	:= (_cArq)->F1_ESPECIE
	TMPCD5->CD5_FORNEC	:= (_cArq)->F1_FORNECE
	TMPCD5->CD5_LOJA	:= (_cArq)->F1_LOJA
	TMPCD5->CD5_TPIMP	:= "0"
	TMPCD5->CD5_DOCIMP	:= (_cArq)->D1_DOC
	TMPCD5->CD5_BSPIS	:= (_cArq)->D1_BASIMP6
	TMPCD5->CD5_ALPIS	:= (_cArq)->D1_ALQIMP6
	TMPCD5->CD5_VLPIS	:= (_cArq)->D1_VALIMP6
	TMPCD5->CD5_BSCOF	:= (_cArq)->D1_BASIMP5
	TMPCD5->CD5_ALCOF	:= (_cArq)->D1_ALQIMP5
	TMPCD5->CD5_VLCOF	:= (_cArq)->D1_VALIMP5
	TMPCD5->CD5_ACDRAW	:= SPACE(20)
	TMPCD5->CD5_DTPPIS	:= _wdtinic//(_cArq)->F1_EMISSAO
	TMPCD5->CD5_DTPCOF	:= _wdtinic//(_cArq)->F1_EMISSAO
	TMPCD5->CD5_LOCAL	:= "0"
	TMPCD5->CD5_NDI		:= (_cArq)->F1_NDIWISE
	TMPCD5->CD5_DTDI	:= ctod(substr((_cArq)->F1_DTDIWIS,7,2)+"/"+substr((_cArq)->F1_DTDIWIS,5,2)+"/"+substr((_cArq)->F1_DTDIWIS,1,4))	//(_cArq)->F1_DTDIWIS
	TMPCD5->CD5_LOCDES	:= (_cArq)->F1_LOCDESE
	TMPCD5->CD5_UFDES	:= (_cArq)->F1_UFDIDES
	TMPCD5->CD5_DTDES	:= ctod(substr((_cArq)->F1_DTDESEM,7,2)+"/"+substr((_cArq)->F1_DTDESEM,5,2)+"/"+substr((_cArq)->F1_DTDESEM,1,4))	//(_cArq)->F1_DTDESEM
	TMPCD5->CD5_CODEXP	:= (_cArq)->F1_EXPORTA
	TMPCD5->CD5_NADIC	:= (_cArq)->D1_ADICWIS
	TMPCD5->CD5_SQADIC	:= (_cArq)->D1_SEQADIW
	TMPCD5->CD5_CODFAB	:= (_cArq)->F1_FABR
	TMPCD5->CD5_VDESDI	:= (_cArq)->D1_VALDESC
	TMPCD5->CD5_BCIMP	:= 0.00
	TMPCD5->CD5_DSPAD	:= 0.00
	TMPCD5->CD5_VLRII	:= (_cArq)->F1_II
	TMPCD5->CD5_VLRIOF	:= (_cArq)->F1_VLRIOF
	TMPCD5->CD5_ITEM	:= (_cArq)->D1_ITEM
	MSUNLOCK()

	dbSelectArea(_cArq)
	dbSkip()

end

dbSelectArea(_cArq)
dbclosearea()
	
dbSelectArea("TMPCD5")
dbGotop()
While !Eof()
	wAchou := .T.
	dbSelectArea("CD5")
	dbsetOrder(1)
	DBSEEK(TMPCD5->CD5_FILIAL+TMPCD5->CD5_DOC+TMPCD5->CD5_SERIE+TMPCD5->CD5_FORNEC+TMPCD5->CD5_LOJA+TMPCD5->CD5_DOCIMP+TMPCD5->CD5_NADIC)
	if Found()
		while TMPCD5->CD5_DOC == CD5->CD5_DOC .and. TMPCD5->CD5_SERIE == CD5->CD5_SERIE .and.;
			TMPCD5->CD5_FORNEC == CD5->CD5_FORNEC .and. TMPCD5->CD5_LOJA == CD5->CD5_LOJA .and.;
			TMPCD5->CD5_DOCIMP == CD5->CD5_DOCIMP .and. TMPCD5->CD5_NADIC == CD5->CD5_NADIC .and. !Eof()
			if CD5->CD5_ITEM == TMPCD5->CD5_ITEM
				dbSelectArea("TMPCD5")
				dbSkip()
				wAchou := .F.
				exit
			else
				exit
			endif
			dbSelectArea("TMPCD5")                                 
			dbSkip()
		end	
			
	endif   
	
	if TMPCD5->CD5_DOC <> CD5->CD5_DOC       // 30/01/2013  - Alterado para nใo gravar se existir o mesmo numero da nota - Amarildo Stewart
	 
	if wAchou
		dbSelectArea("CD5")
		RecLock("CD5",.T.)
		CD5_FILIAL	:= TMPCD5->CD5_FILIAL
		CD5_DOC		:= TMPCD5->CD5_DOC
		CD5_SERIE	:= TMPCD5->CD5_SERIE
		CD5_ESPEC	:= TMPCD5->CD5_ESPEC
		CD5_FORNEC	:= TMPCD5->CD5_FORNEC
		CD5_LOJA	:= TMPCD5->CD5_LOJA
		CD5_TPIMP	:= TMPCD5->CD5_TPIMP
		CD5_DOCIMP	:= TMPCD5->CD5_DOCIMP
		CD5_BSPIS	:= TMPCD5->CD5_BSPIS
		CD5_ALPIS	:= TMPCD5->CD5_ALPIS
		CD5_VLPIS	:= TMPCD5->CD5_VLPIS
		CD5_BSCOF	:= TMPCD5->CD5_BSCOF
		CD5_ALCOF	:= TMPCD5->CD5_ALCOF
		CD5_VLCOF	:= TMPCD5->CD5_VLCOF
		CD5_ACDRAW	:= TMPCD5->CD5_ACDRAW
		CD5_DTPPIS	:= TMPCD5->CD5_DTPPIS
		CD5_DTPCOF	:= TMPCD5->CD5_DTPCOF
		CD5_LOCAL	:= TMPCD5->CD5_LOCAL
		CD5_NDI		:= TMPCD5->CD5_NDI
		CD5_DTDI	:= TMPCD5->CD5_DTDI
		CD5_LOCDES	:= TMPCD5->CD5_LOCDES
		CD5_UFDES	:= TMPCD5->CD5_UFDES
		CD5_DTDES	:= TMPCD5->CD5_DTDES
		CD5_CODEXP	:= TMPCD5->CD5_CODEXP
		CD5_NADIC	:= TMPCD5->CD5_NADIC
		CD5_SQADIC	:= TMPCD5->CD5_SQADIC
		CD5_CODFAB	:= TMPCD5->CD5_CODFAB
		CD5_VDESDI	:= TMPCD5->CD5_VDESDI
		CD5_BCIMP	:= TMPCD5->CD5_BCIMP
		CD5_DSPAD	:= TMPCD5->CD5_DSPAD
		CD5_VLRII	:= TMPCD5->CD5_VLRII
		CD5_VLRIOF	:= TMPCD5->CD5_VLRIOF
		CD5_ITEM	:= TMPCD5->CD5_ITEM
		MSUNLOCK()
	endif 
	endif
	dbSelectArea("TMPCD5")
	dbSkip()
	
end
	
dbSelectArea("TMPCD5")
dbclosearea()

U_WSAIR1A()             

return

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Saida do sistema                                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
User Function WSAIR1A()

_lFechar := .T.
_wInic := .T.
close(oDlg1)
dbClearFilter()

Return(_wInic)
