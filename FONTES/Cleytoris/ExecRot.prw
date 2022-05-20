#Include 'Protheus.ch'
#Include "Totvs.Ch"
#Include "topconn.Ch"
#Include "Restful.Ch"
#INCLUDE "FILEIO.CH"
#include "tfinx200.ch"
#Include "ApWebSrv.ch"
#Include 'ApWebex.ch'
#Include "Totvs.Ch"
#Include "RESTFUL.Ch"
#Include "FWMVCDef.Ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "RPTDEF.CH" 
#INCLUDE 'APWebSrv.ch'
#include 'Fileio.ch'  
#INCLUDE "TBICODE.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH" 
#INCLUDE "XMLXFUN.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "PRTOPDEF.CH"

//Executa rotinas personalizadas direto pelo Client

User Function ExecRot()

	//Testar Private AcBrowse := "xxxxxxxxxx"   //Variavel para controle de acesso a mbrowse
	Local bWindowInit := {|| ExecBlock(cRotina)}//{|| Iif(ExistBlock(cRotina),Execblock(cRotina),Iif(FindFunction(cRotina),&(cRotina),MsgAlert("Rotina Invï¿½lida"))) }
//	Local cRotina := "ReIntPln"//"JOBRESLOG"//"RELAPROV"//"IMPORT_DIF"
 	Local cRotina := 'PAULADA'
	Local _cEmp	:= "01"
	Local _cFil	:= "01"				    
	
	RpcSetType(3)
	//If !RpcSetEnv(_cEmp,_cFil, 'DENISON.NASCIMENTO', 'DENISON@010101', 'FIN', cRotina)
	If !RpcSetEnv(_cEmp,_cFil)
		Final("Erro ao abrir ambiente")
	EndIf
	
	__cUserId := '000000'
	
	Private cUserName := 'ADMIN'
	
	Private cCadastro		:= "ExecRot"
	Private acbrowse 		:= Replicate("x",15)
	Private __cInternet 	:= Nil
	Private lMsHelpAuto 	:= .F.
		
	DEFINE WINDOW oMainWnd FROM 000,000 TO 500,600 TITLE OemToAnsi( "Execução direta" )
	ACTIVATE WINDOW oMainWnd MAXIMIZED ON INIT ( Eval(bWindowInit),oMainWnd:End())
	
	RpcClearEnv()
	
Return
