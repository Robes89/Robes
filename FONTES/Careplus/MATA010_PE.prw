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

/*/{Protheus.doc} IntProd
Funcao para integração de produto 
no ambiente nimbi.
**********************************
* Chamar a funcao posicionado    *
* no produto (sb1)               *
**********************************
@author Rubens Simi
@since 09/07/2021
@version version
/*/
User Function IntProd( )

Local aCriaServ := {}
Local aHeader   := {}
Local aRequest  := {}
Local aRet      := {}
Local cChave    := SB1->B1_COD
Local cIdPZB    := ""
Local cJson     := ""
Local cJsoRec   := ""
Local cLastTime := ""
Local cTipo     := IF (EMPTY(SB1->B1_XIDRESE), '0000AB' , '0000AC' )
Local cTipoMsg  := IF (EMPTY(SB1->B1_XIDRESE), 'Inclusao' , 'Alteração' )
Local cUser     := Alltrim(GetMV("MV_USERNIM",.F.,"integracao_careplus@yopmail.com"))
Local nQtdReg   := 1
Local nX        := 0
Local oRet      := NIL

    //Cria o log do servico no monitor
    aCriaServ := U_MonitRes(cTipo, 1, nQtdReg)
    cLastTime := Time()

    //Id gerado na criacao do servico
    cIdPZB := aCriaServ[2]

    AADD(aHeader, "ClientAPI_ID: 6951056a-bf4c-416e-8b80-366a2b97ac0e"  )
	AADD(aHeader, 'ClientAPI_Key: 1e8ec62d-7743-44ed-8558-a07477ea803e'  )
     
      //Se for alteração
    IF !EMPTY(SB1->B1_XIDRESE)
      AADD(aHeader, 'ItemCode:'+ALLTRIM(cChave)   )
    EndIF
 
    AADD(aHeader, 'OwnerUserName: '+cUser  )
    AADD(aHeader, "Content-Type: application/json")

      
        
        cJson := '{'
        cJson += '"code":"'     + Alltrim(EncodeUTF8(SB1->B1_COD)) + '",'
        cJson += '"Description":"'     + Alltrim(EncodeUTF8(SB1->B1_DESC)) + '",'
        cJson += '"LongDescription":"'     + Alltrim(EncodeUTF8(SB5->B5_CEME )) + '",'
        cJson += '"NatureOfOperationCode":"'  + Alltrim(EncodeUTF8("")) + '",'
        cJson += '"LastPriceBuy":' + Alltrim(EncodeUTF8( STR(SB1->B1_UPRC) )) + ','
        cJson += '"Type":"'+ Alltrim(EncodeUTF8(if (SB1->B1_TIPO=='SV','SERVICE','PRODUCT') )) + '",'
        cJson += '"UnitOfMeasureCode":"'+ Alltrim(EncodeUTF8(SB1->B1_UM)) + '",'
		cJson += '"Brand": " ",'
		cJson += '"Model": " ",'
		cJson += '"SKU": " ",'
		cJson += '"GTIN13": " ",'
		cJson += '"NCM":"'+ Alltrim(EncodeUTF8(SB1->B1_POSIPI)) + '",'
		cJson += '"ManufacturerCode": " ",'
		cJson += '"CategoryCode":"'+ Alltrim(EncodeUTF8(SB1->B1_GRUPO)) + '",'
        cJson += '} '

        aRequest := U_ResInteg(cTipo, cJson, aHeader,, .T.)

        If aRequest[1]
            
            oRet := aRequest[2]

            cMenssagem  := cTipoMsg+" com sucesso."
            cJsoRec     := aRequest[3]

            DbSelectArea("SB1")
            SB1->(DbSetOrder(1))
            If SB1->(MsSeek(xFilial("SB1") + cChave)) 

                SB1->(RecLock("SB1"),.F.)
                    B1_XIDRESE :=IF (Empty(SB1->B1_XIDRESE),Alltrim(cValToChar(oRet:itemid)),SB1->B1_XIDRESE)
					B1_XNIMB   :='1'
					B1_XINTDT  :=date()
					B1_XHRINT  :=time()
					B1_XOBS	   :=aRequest[3]
                SB1->(MsUnlock())

            EndIf
            
            U_MonitRes(cTipo, 2, , cIdPZB, cMenssagem, .T., cChave, cJson, cJsoRec, Alltrim(cValToChar(oRet:itemid)))

        Else
              

			   DbSelectArea("SB1")
              SB1->(DbSetOrder(1))
            If SB1->(MsSeek(xFilial("SB1") + cChave)) 

                SB1->(RecLock("SB1"),.F.)
  					B1_XNIMB   :='2'
					B1_XINTDT  :=date()
					B1_XHRINT  :=time()
					B1_XOBS	   :=aRequest[3]
                SB1->(MsUnlock())

            EndIf
            cMenssagem  := "Falha na "+cTipoMsg
            cJsoRec     := aRequest[3]

            U_MonitRes(cTipo, 2, , cIdPZB, cMenssagem, .F., cChave, cJson, cJsoRec, aDados[nX][1], lReprocess, lLote, cIdPZC)
        
        EndIf

    //Finaliza o processo na PZB
    U_MonitRes(cTipo, 3, , cIdPZB, , .T.)

Return(aRequest)


