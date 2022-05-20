#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "Fileio.ch"
#include "Totvs.ch"

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
EndIf
ProcLogAtu("FIM",,,,.T.)
Return