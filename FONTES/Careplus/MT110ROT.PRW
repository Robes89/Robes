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

User Function MT110ROT()


AAdd( aRotina, { 'Status Nimbi', 'U_StNIMB()', 0, 4 } )

Return aRotina 

User Function StNIMB()

   Local aLegenda := {}

    //Monta as legendas (Cor, Legenda)
    If C1_XSTAT == "0" .or. C1_XSTAT == " "
         aAdd(aLegenda,{"BR_AMARELO",      "Pendente Integração"})
    ElseIF C1_XSTAT == "1"
            aAdd(aLegenda,{"BR_AZUL",         "Integrado"})
    ElseIF C1_XSTAT == "2"
        aAdd(aLegenda,{"BR_AZUL_CLARO",   "Devolvido pelo Nimbi"})
    ElseIF C1_XSTAT == "3"
        aAdd(aLegenda,{"BR_VIOLETA",   "Devolvido Para Alteração"})  
    ElseIF C1_XSTAT == "4"
        aAdd(aLegenda,{"BR_MARRON",   "Excluido Nimbi"})          
    EndIF
    If SC1->C1_XSTAT $ "1|5|  " .and. Empty(C1_FORNECE)
        FWMsgRun(, {|| U_SCCOMNIM() }, "Processando", "Verificando NIMBI...")
    EndIF
    
     
    //Chama a função que monta a tela de legenda
    BrwLegenda("Status", "Status  Título", aLegenda)

Return
