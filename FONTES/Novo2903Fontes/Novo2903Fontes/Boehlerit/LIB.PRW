#INCLUDE "TOTVS.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FILEIO.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'AP5MAIL.CH'
#INCLUDE "XMLXFUN.CH"
#DEFINE ENTER Chr(13)+Chr(10)
#DEFINE ESPACAMENTO_ARRAY 3
Static cAdmArq
Static __cFileLog

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³  LIB     ºAutor  ³Fernando Pacheco   º Data ³  22/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º   IF !(U_PROCSQL( cQUERY,"TMP","MAVAR033_3",.T.,.T.,.T.)) 			   º±±
±±º   	RETURN 																	   º±±
±±º   ENDIF 																	   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION PROCSQL( cQUERY,cALIAS,cNOMEQUERY,lMSAGUARDE,lGRVQUERY,lANAQUERY,lSETFIELD)
DEFAULT cNOMEQUERY 		:= FUNNAME()
DEFAULT cALIAS 			:= "TRB"
DEFAULT lGRVQUERY  		:= .F.
DEFAULT lANAQUERY		:= .F.
DEFAULT lMSAGUARDE 		:= .F.
DEFAULT lSETFIELD 		:= .F.

cQUERY := UPPER(cQuery)
/*
//+-----------------------
//| Cria uma view no banco
//+-----------------------
//PROCSQL( cQUERY,cALIAS,cNOMEQUERY,lMSAGUARDE,lGRVQUERY,lANAQUERY,lSETFIELD)
IF !(U_PROCSQL( cQUERY,"TMP","MAVAR033_3",.F.,.F.,.F.,.F.))
	RETURN
ENDIF
*/

IF Upper(TcGetDb()) == "DB2"
	cQuery := STRTRAN(UPPER(cQuery),"SUBSTRING","SUBSTR")
	cQuery := STRTRAN(UPPER(cQuery),"+","||")
ELSEIF SUBS(Upper(TcGetDb()),1,5) == "MSSQL"
	cQuery := STRTRAN(UPPER(cQuery),"SUBSTR","SUBSTRING")
	cQuery := STRTRAN(UPPER(cQuery),"SUBSTRINGING","SUBSTRING")
	cQuery := STRTRAN(UPPER(cQuery),"||","+")
ENDIF

IF lGRVQUERY
	If !lIsDir("\SQL\")
		MakeDir("\SQL\")
	ENDIF
	IF "TRADE" $ Alltrim(Upper(GetEnvServer()))
		MemoWrit("\SQL\"+cNOMEQUERY+".sql",cQuery)
	ENDIF	
ENDIF

IF lANAQUERY
	nRet := TcSqlExec(cQuery)
	If nRet#0
		cRet := TCSQLError()
		If !(Type("oMainWnd")=="O")
			CONOUT(AllTrim(cRet))
		Else
			APMsgAlert(AllTrim(cRet),"Erro do SQL")
		Endif
		Return(.F.)
	Endif
ENDIF


cQuery := ChangeQuery(cQuery)
iif(Select(cAlias)>0,(cAlias)->(dbCloseArea()),Nil)
IF lMSAGUARDE
	MsAguarde({|| dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery),cALIAS,.F.,.T.)}, "Aguarde! Obtendo os dados..."+cNOMEQUERY)
ELSE
	TCQUERY cQuery NEW ALIAS (cALIAS)
ENDIF

dbSelectArea(cALIAS)

IF lSETFIELD
	aStru := dbStruct()
	For nTRU:=1 to Len(aStru)
		SX3->(DBGOTOP())
		SX3->( dbSetOrder( 2 ) )
		If SX3->(dbSeek(aStru[nTRU][1]))
			If SX3->X3_TIPO == "N"
				TcSetField(cALIAS,aStru[nTRU][1],SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL)
			ELSEIf SX3->X3_TIPO == "D"
				TcSetField(cALIAS,aStru[nTRU][1],SX3->X3_TIPO)
			Endif
		Else
			IF aStru[nTRU][2] == "N"
				TCSetField(cALIAS,aStru[nTRU][1], "N", TamSX3("D2_TOTAL")[1], TamSX3("D2_TOTAL")[2])
			ELSEIf aStru[nTRU][2] == "D"
				TcSetField(cALIAS,aStru[nTRU][1],"D")
			ENDIF
		Endif
	Next nTRU
ENDIF

RETURN(.T.)
