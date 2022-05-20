#include "RWMAKE.CH"
#include "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCHECKTOP_AP5บAutor  ณMicrosiga           บ Data ณ  07/05/01   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function checktop()
Private _lEnd := .F.
Processa({|_lEnd| checkproc()},"Acertando a Top_Field no Banco de Dados")
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCHECKTOP_AP5บAutor  ณMicrosiga           บ Data ณ  07/05/01   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function checkproc()
Local cEmpAnt,cFilOri
Local cBanco		:= Alltrim(Upper(TCGetDb()))
Private aCamposSX3	:= {}
Private cUsertable	:=""
Private cmsgstopa	:= "N"
Private cOwnertable

msgalert("Esta rotina tem o objetivo de ajustar a TOP_FIELD baseando-se no arquivo SX3 atual.Esta rotina gera uma tabela de resultado CHECKTOP no banco de dados para conferencia.Esta rotina funciona somente para banco de dados.")

If MsgYesNo("Avisa sobre correcao S/N",OemToAnsi('ATENCAO'))
	cmsgstopa:="S"
EndIf

If !MsgYesNo("Inicia a execu็ใo S/N ? ",OemToAnsi('ATENCAO'))
	Return
EndIf

dbSelectArea("SM0")
dbGotop()
cEmpAnt := "@@"
cFilOri := SM0->M0_CODIGO
While !Eof()
	// efetua a validacao para todas as empresas.
	If SM0->M0_CODIGO == cEmpAnt
		dbSkip()
		LOOP
	EndIf
	cEmpAnt		:= SM0->M0_CODIGO
	cUserTable	:= CheckUser()
	If Empty(cUserTable)
		CheckLOG()
		msgstop('Para dar continuidade neste processo; voce precisa reiniciar o servico do TOPCONNECT,; logo apos carregue este programa novamente.')
		Return
	EndIf

	// Verifica a Existencia das tabelas de configuracao no startpath
	If !File("\"+curdir()+"\SX3"+SM0->M0_CODIGO+"0"+GetdbExtension())
		SM0->( dbSkip() )
		Loop
	EndIF
		
	SX2->( dbCloseArea() )		// Re-abertura do SX2 de cada empresa para normatizar geral.
	//dbUseArea(.T.,__LocalDriver,"SX2"+SM0->M0_CODIGO+"0","SX2")
	oTemptable := FWTemporaryTable():New( "SX2")
	IndRegua("SX2","SX2TRB","X2_CHAVE",,,"REINDEXANDO SX2"+SM0->M0_CODIGO+"0")
	SX2->( dbClearFilter() )
	SX2->( dbGotop() )
	ProcRegua(SX2->(LastRec()))
	While !SX2->( Eof() )
		IncProc("Analisando Tabela "+AllTrim(SX2->X2_CHAVE)+". Empresa "+SM0->M0_CODIGO)
		u_CheckTabela(SX2->X2_CHAVE,cBanco)
		SX2->( dbSkip() )
	End
	dbSelectArea("SM0")
	dbSkip()
End
msgstop("Processo concluido. ; Reinicialize o Servico do TopConnect; As modIficacoes foram registradas na tabela CHECKTOP.")
Return(.T.)


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerIfica a existencia e a possiblidade de abertura da tabela no banco ณ
//ณCaso a tabela exista no banco, serao criados os registros na TOP_FIELDณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
User Function CheckTabela(cArquivo,cBanco)
Local aStru,ni,cQuery, cAlias, npos, npos1,npos2,npos3, lErro, lCria, ncount 
cNomeArq := Upper(RetSqlName(Alltrim(cArquivo)))
If "."$ cNomeArq
	cNomeArq := Subs(cNomeArq,1,AT(".",cArquivo)-1)
EndIf
If !TCCanOpen(RetSQLName(cArquivo))
	Return Nil
EndIf

// Verificar na checktop se existe log de hoje para esta tabela ....
If !CheckLOG(cArquivo,cBanco)
	Return Nil
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCarrega Estrutura do dicionario de dados da tabela corrente ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aCamposSX3 := {}
DbSelectArea("SX3")
DbSeek(cArquivo)
While !Eof() .And. X3_ARQUIVO == cArquivo
   If X3_CONTEXT != "V" .and. X3_TIPO $ "N|D|L"
	  AADD(aCamposSX3,{X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
   EndIf
   DbSelectArea("SX3")
   DbSkip()
EndDo

// Carrega Estrutura do dicionario de dados da tabela corrente em funcao da TOP_FIELD
// Este array tera somente os campos do Tipo Data, Numerico e Logico.
lErro	:= .F. // Determina se a Estrutura esta com problemas
lCria	:= .T. // Nใo existe nenhum registro da tabela corrente na top_field
nCount	:= 0   // Contador para checar se a quantidade de registro esta dIferente
cQuery	:= " SELECT FIELD_TABLE, FIELD_NAME, FIELD_TYPE, FIELD_PREC, FIELD_DEC "
cQuery	+= " FROM TOP_FIELD "
cQuery	+= " WHERE FIELD_TABLE LIKE '%"+RetSQLName(cArquivo)+"%' AND FIELD_TYPE <> 'X' "
cQuery	:= ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), '__TOP', .F., .T.)
dbSelectArea("__TOP")

While !eof()
      lCria := .F.
      npos := AScan(acamposSX3,{|x| alltrim(x[1]) == alltrim(FIELD_NAME)} )
	  If npos = 0
	     lErro := .T.
	     exit
	  EndIf
      cType := iIf(alltrim(FIELD_TYPE)=='P','N',alltrim(FIELD_TYPE))
	  If !(aCamposSX3[npos][2] == cType .and. alltrim(str(aCamposSX3[npos][3])) == alltrim(FIELD_PREC) .and. ;
	       alltrim(str(aCamposSX3[npos][4])) == alltrim(FIELD_DEC) ) 
	      lErro := .T. 
      EndIf   
      nCount++
      dbskip()
end
__TOP->( dbCloseArea() )

If lCria   // VerIfica se existe campos necessarios a serem criados na TOP_FIELD
   npos1 := AScan(acamposSX3,{|x| alltrim(x[2]) == 'N' })
   npos2 := AScan(acamposSX3,{|x| alltrim(x[2]) == 'D' })
   npos3 := AScan(acamposSX3,{|x| alltrim(x[2]) == 'L' })
   If (npos1=0 .and. npos2=0 .and. npos3=0)
      lErro := .T.
   EndIf
EndIf		           
   
If lErro .or. (nCount <> len(aCamposSX3)) // Se Verdadeiro deve recriar sua estrutura na top_field
    If cmsgstopa == "S"
       msgstop("Tabela "+cNomeArq+" sera ajustada.Tecle enter para continuar")
    EndIf

    // Elimina estrutura da tabela original 
    cQuery := " DELETE FROM TOP_FIELD "
	cQuery += " WHERE FIELD_TABLE LIKE '%"+RetSqlName(cArquivo)+"%' "
	cQuery := Parse(cQuery)
    TCSQLEXEC(cQuery)
    If substr(cBanco,1,6) == "ORACLE"
 	   TCSQLEXEC("COMMIT")
    EndIf

    // Cria registros necessarios na TABELA TOP_FIELD
	For ni := 1 to len(aCamposSX3)
        cType := iIf(aCamposSX3[ni][2]=='N','P',aCamposSX3[ni][2])

		// Atualiza TOP_FIELD
	    cQuery := " INSERT INTO TOP_FIELD (FIELD_TABLE, FIELD_NAME, FIELD_TYPE, FIELD_PREC, FIELD_DEC)  "
    	cQuery += " VALUES ('"+cUserTable+RetSQLName(cArquivo)+"','"+aCamposSX3[ni][1]+"','"+cType+"','"+alltrim(str(aCamposSX3[ni][3]))+"','"+alltrim(str(aCamposSX3[ni][4]))+"')"
    	TCSQLEXEC(cQuery)
	    If substr(cBanco,1,6) == "ORACLE"
 		   TCSQLEXEC("COMMIT")
	    EndIf

		// Atualiza tabela CHECKTOP 
		cQuery := " SELECT MAX(R_E_C_N_O_) RECNO "
  	 	cQuery += " FROM CHECKTOP "
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), '__TOP', .F., .T.)
	    cQuery := " INSERT INTO CHECKTOP  (CHK_TABLE, CHK_NAME, CHK_TYPE, CHK_PREC, CHK_DEC, CHK_DAT,R_E_C_N_O_)  "
    	cQuery += " VALUES ('"+cUserTable+RetSQLName(cArquivo)+"','"+Alltrim(aCamposSX3[ni][1])+"','"+Alltrim(cType)+"','"+Alltrim(str(aCamposSX3[ni][3]))+"','"+Alltrim(str(aCamposSX3[ni][4], 0))+"','"+DTOS(dDataBase)+"',"+Alltrim(str(RECNO + 1, 0))+")"
    	__TOP->( dbCloseArea() )
    	TCSQLEXEC(cQuery)
	    If substr(cBanco,1,6) == "ORACLE"
 		   TCSQLEXEC("COMMIT")
	    EndIf
	next ni

	// Atualiza TOP_FIELD
    cQuery := " INSERT INTO TOP_FIELD (FIELD_TABLE, FIELD_NAME, FIELD_TYPE, FIELD_PREC, FIELD_DEC)  "
   	cQuery += " VALUES ('"+cUserTable+RetSQLName(cArquivo)+"','@@HAS_DFT_VAL@@','X','0','0') "
   	TCSQLEXEC(cQuery)
    If substr(cBanco,1,6) == "ORACLE"
 	   TCSQLEXEC("COMMIT")
    EndIf

	// Atualiza tabela CHECKTOP 
	cQuery := " SELECT MAX(R_E_C_N_O_) RECNO "
 	cQuery += " FROM CHECKTOP "
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), '__TOP', .F., .T.)
    cQuery := " INSERT INTO CHECKTOP  (CHK_TABLE, CHK_NAME, CHK_TYPE, CHK_PREC, CHK_DEC, CHK_DAT,R_E_C_N_O_)  "
  	cQuery += " VALUES ('"+Alltrim(cUserTable+RetSQLName(cArquivo))+"','@@HAS_DFT_VAL@@','X','0','0','"+dtos(ddatabase)+"',"+str(RECNO + 1)+") "
  	__TOP->( dbCloseArea() )
  	TCSQLEXEC(cQuery)

    If substr(cBanco,1,6) == "ORACLE"
 	   TCSQLEXEC("COMMIT")
    EndIf
EndIf

Return

Static Function checkuser()
Local _cUserTable := ''
Local cQuery
If TCCanOpen("TOP_FIELD")
	cQuery := " SELECT FIELD_TABLE "
    cQuery += " FROM TOP_FIELD "
    cQuery += " WHERE FIELD_TABLE LIKE '%CHECKTOP%'"
    dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery), '__TOP', .F., .T.)
    _cUserTable := substr(alltrim(FIELD_TABLE),1,AT(".",alltrim(FIELD_TABLE)))
    __TOP->( dbCloseArea() )
	If Empty(_cUserTable)
	   TCDelfile("CHECKTOP")
	EndIf
EndIf
Return(_cUserTable)

Static Function CheckLOG(cArqLog,cBancoLog)
Local _cQueryLog,lAtualiza,aCamposCHK := {}
// Cria arquivo CHECKTOP DE LOG DE INFORMACOES ALTERADAS NA TABELA TOP_FIELD
If TCCanOpen("CHECKTOP")
	_cQueryLog	:= "SELECT COUNT(*) TOTAL FROM CHECKTOP WHERE D_E_L_E_T_ = '' AND CHK_DAT <> '"+dtos(dDataBase)+"' AND CHK_TABLE LIKE '%"+RetSQLName(Alltrim(cArqLog))+"%'"
	_cQueryLog	:= Parse(_cQueryLog)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQueryLog),'__TOP',.F.,.T.)
	// Verifica se ja foi efetuado algum teste na data de "HOJE"
	lAtualiza	:= Iif(__TOP->TOTAL >= 0,.T.,.F.)
	If __TOP->TOTAL > 0
		_cQryLog	:= "DELETE FROM CHECKTOP WHERE D_E_L_E_T_ = '' AND CHK_DAT <> '"+DTOS(dDataBase)+"' AND CHK_TABLE LIKE '%"+RetSQLName(Alltrim(cArqLog))+"%'"
		_cQryLog	:= Parse(_cQryLog)
		TCSQLEXEC(_cQryLog)
	    If SubStr(cBancoLog,1,6) == "ORACLE"
	 	   TCSQLEXEC("COMMIT")
	    EndIf
	 EndIf
	__TOP->( dbCloseArea() )
Else  //If !( TCCanOpen("CHECKTOP") )
	AADD(aCamposCHK,{'CHK_TABLE','C',64,0})
	AADD(aCamposCHK,{'CHK_NAME' ,'C',32,0})
	AADD(aCamposCHK,{'CHK_TYPE' ,'C',2 ,0})
	AADD(aCamposCHK,{'CHK_PREC' ,'C',4 ,0})
	AADD(aCamposCHK,{'CHK_DEC'  ,'C',4 ,0})
	AADD(aCamposCHK,{'CHK_NUM'  ,'N',2 ,0})
	AADD(aCamposCHK,{'CHK_DAT'  ,'D',8 ,0})
	AADD(aCamposCHK,{'CHK_LOG'  ,'L',1 ,0})

	
oTemptable := FWTemporaryTable():New( "CHECKTOP")
oTemptable:SetFields( aCamposCHK )
oTempTable:AddIndex("index1", {"CHK_TABLE"} )
oTempTable:Create()
	//dbCreate("CHECKTOP",aCamposCHK,"TOPCONN")
EndIf
Return(lAtualiza)
