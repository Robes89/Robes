#INCLUDE 'TOTVS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} CNTA121
(Rotina responsavel pela utilização dos pontos de entrada da rotina CNTA121)
@author Renato Calabro'
@since 12/04/2021
@return xRet,, dados para retorno dos pontos de entrada.
@see (links_or_references)
/*/

STATIC ntrhead := 0 

User Function CNTA121()

Local xRet := .T.
Local nTradValu := threadid()


Private oObj
Private oModel

Private cIdPonto := ''
Private cIdModel := ''
Private cProcHTML := ''
Private cNivel := ''
Private cChaveHash := ''

Private aCpoWhen := { }



If ( PARAMIXB != Nil )
	oObj := PARAMIXB[ 1 ]
	cIdPonto := PARAMIXB[ 2 ]
	cIdModel := PARAMIXB[ 3 ]
	oModel := oObj:GetModel( cIdModel )

	If ( cIdPonto == 'MODELPRE' )
		// xRet := .T.
	ElseIf ( cIdPonto == 'MODELPOS' )
		// xRet := .T.
	ElseIf ( cIdPonto == 'FORMPRE' )
		// xRet := .T.
	ElseIf ( cIdPonto == 'FORMPOS' )
		// xRet := .T.


	ElseIf ( cIdPonto == 'FORMLINEPRE' )
		// xRet := .T.
	ElseIf ( cIdPonto == 'FORMLINEPOS' )
		// xRet := .T.
	ElseIf ( cIdPonto == 'MODELCOMMITTTS' )
	ElseIf ( cIdPonto == 'MODELCOMMITNTTS' )
	ElseIf ( cIdPonto == 'FORMCOMMITTTSPRE' )
	ElseIf ( cIdPonto == 'FORMCOMMITTTSPOS' )
			If ( oModel:nOperation == MODEL_OPERATION_INSERT ) .Or. ( oModel:nOperation == MODEL_OPERATION_UPDATE )

			// Verifica se o ponto de entrada antigo (CN130PGRV) existe
			// Se existir executa os processos antigos
			If FindFunction( "U_CN130PGRV")
			  	IF ntrhead <> nTradValu
				 U_CN130PGRV()
				 ntrhead := nTradValu
				EndIf 
			EndIf
		EndIf

	ElseIf ( cIdPonto == 'FORMCANCEL' )
		// xRet := .T.
	ElseIf ( cIdPonto == 'MODELVLDACTIVE' )
		// xRet := .T.
	ElseIf ( cIdPonto == 'BUTTONBAR' )
	EndIf
EndIf

Return xRet
