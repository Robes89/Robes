#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "Fileio.ch"
#include "Totvs.ch"
#include "ap5mail.ch"

#Define CRLF Chr(13)+ Chr(10)

/*-------------------------------------------------------------------------------------------------------*/
/* Informativo
Rotina para execução em bat para inativação de clientes.
Especifico cliente TEAM_TEX
Autor: Antonio Cordeiro
Data : 19/04/2018
/*-------------------------------------------------------------------------------------------------------*/
User Function TTFATA01()

Local _nDias:=""
Local _cData:=""
Private cIdCV8 := ""

RPCSetType(3)

RpcSetEnv('01','01', , , , , {"SA1"}) // Prepara o ambiente na empresa/filial definida nos parametro

InitPublic()
SetsDefault()
ProcLogIni({},"TTFATA01","",@cIdCV8)

_nDias := SuperGetMv("MV_XBLQCLI",.F.,'90')
_cData:= dtos(ddatabase-val(_nDias))

MSGALERT(" EXECUTANTO O UPDATE ")
cUpdSA1 := " UPDATE " + RetSqlName("SA1") + CRLF
cUpdSA1 += " SET A1_MSBLQL = '1' " + CRLF
cUpdSA1 += " WHERE A1_FILIAL = '"+ xFilial("SA1") +"' " + CRLF
cUpdSA1 += " AND   A1_ULTCOM < '"+_cData+"' " + CRLF
cUpdSA1 += " AND   A1_ULTCOM <> '        '  " + CRLF
cUpdSA1 += " AND   D_E_L_E_T_ = ' ' " + CRLF

If TcSqlExec(cUpdSA1) <> 0
	ProcLogAtu("ERRO","Inativação de cliente nao executada",TCSqlError(),,.T.)
else
	ProcLogAtu("Ok","Inativação de cliente executada com sucesso",TCSqlError(),,.T.)
	
	//Programa que gera um email com informações referentes a Clientes Bloqueados na Data
	
	cQuery := "SELECT * FROM " + RetSqlName("SA1") + CRLF
	cQuery := cQuery += " WHERE A1_MSBLQL = '1' " + CRLF
	cQuery := cQuery += " AND   A1_ULTCOM < '"+_cData+"' " + CRLF
	cQuery := cQuery += " AND   A1_ULTCOM <> '        '  " + CRLF
	cQuery := cQuery += " AND   D_E_L_E_T_ = ' ' " + CRLF
	
	TCQUERY cQuery NEW ALIAS "TRB"
	tcsetfield("TRB","A1_ULTCOM","D")
	
	cMsg := " </font></b> <br><br> <br>"
	cMsg:=cMsg+"<font face='Times New Roman' size=4><b><center>Estes Clientes foram inativados em "+DTOC(dDatabase)+" devido a não realização de compras há mais de 90 dias .</font> <br><br>"
	
	DBSELECTAREA("TRB")
	DBGOTOP()
	
	cTexto:= "<div id='Layer1' style='position:absolute; width:116px; height:55px; z-index:1; left: 0px; top: 0px'> "
	cTexto:=cTexto+ " <div align='center'><img src='http://www.teamtex.com.br/img/logo.png' width='113' height='50'></div></div>"
	cTexto:=cTexto+ "<font face='Times New Roman' size=4><b><center>INATIVAÇÃO DE CLIENTES</font> <br><br>"
	ctexto:=cTexto+ " <table align='center' border=1>"
	cTexto:=cTexto+ " <tr><td align='center' bgcolor='#93EAFF'>Cod.Cliente</td>"
	cTexto:=cTexto+ " <td align='center' bgcolor='#93EAFF'>Nome Cliente</td>"
	cTexto:=cTexto+ " <td align='center' bgcolor='#93EAFF'>Dt.Ult.Compra</td>"
	
	Do While .not. eof()
		cTexto:=cTexto+ " <tr><td align='left' >"+TRB->A1_COD+" "+TRB->A1_LOJA+"</td>"
		cTexto:=cTexto+ " <td align='left' >"+TRB->A1_NREDUZ+"</td>"
		cTexto:=cTexto+ " <td align='CENTER' >"+dtoc(TRB->A1_ULTCOM)+"</td>"
		DBSKIP()
	Enddo
	
	cTexto:=cTexto+ " </table>"
	cTexto:=cTexto +  cMsg + " </font></b> <br><br> "
	
	
	// Configuracoes email server
	lConect := .t.
	cServer := GETMV("MV_WFSMTP")
	cConta	:= GETMV("MV_WFMAIL")
	cPass 	:= GETMV("MV_WFPASSW")
	cDest   := GETMV("MV_WFDEST1")
	
	CONNECT SMTP SERVER cServer ACCOUNT cConta PASSWORD cPass RESULT lConect
	MAILAUTh(cConta,cPass)
	SEND MAIL FROM cConta TO cDest SUBJECT " Inativação de Clientes " BODY cTexto RESULT lEnviado
	DISCONNECT SMTP SERVER Result lDisConectou
	
	dbCloseArea("TRB")
	
EndIf

ProcLogAtu("FIM",,,,.T.)
Return
