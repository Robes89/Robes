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


User  Function  SCCOMNIM 
Local aCriaServ := {}
Local aHeader   := {}
Local aRequest  := {}
Local aRet      := {}
Local cIdPZB    := ""
Local cJson     := ""
Local cJsoRec   := ""
Local cLastTime := ""
Local cTipo     := '0000AE'
Local cTipoMsg  := '0000AE'
Local cUser     := Alltrim(GetMV("MV_USERNIM",.F.,"integracao_careplus@yopmail.com"))
Local nQtdReg   := 1
Local nX        := 0
Local oRet      := NIL
Local CCHAVE    := SC1->C1_NUM
Local lIten     := .F.
Local lret      := .T.
Private aBoxParam       := {} 
Private aRetParam	:= {}
Private cCliDe          := Space(TamSx3("C1_NUM")[1])    
Private cIten := ''

IF !Empty(SC1->C1_FORNECE)
    lret := .F.
EndIf
If SC1->C1_XSTAT $ '5'
    U_SCNIMALT()
    lret := .F.
EndIf
If lret
   //Cria o log do servico no monitor
    aCriaServ := U_MonitRes(cTipo, 1, nQtdReg)
    cLastTime := Time()

    //Id gerado na criacao do servico
    cIdPZB := aCriaServ[2]

   
   aAdd(aHeader,'ClientAPI_ID:6951056a-bf4c-416e-8b80-366a2b97ac0e')
   aAdd(aHeader,'ClientAPI_Key:1e8ec62d-7743-44ed-8558-a07477ea803e')
   aAdd(aHeader,'companyTaxNumber:02725347000127')
   aAdd(aHeader,'companyCountryCode:BR')
   aAdd(aHeader,'Content-Type:application/json')
     
    cJson :=  '{'
    cJson +=' "codeERP": "'+SC1->C1_NUM+'",'
    cJson += '"title": "'+SC1->C1_NUM+'",'
    cJson += ' "requestPriorityId": "'+ IIF(Empty(SC1->C1_XPIORI),'2',SC1->C1_XPIORI) + '",'
    cJson += ' "isAddressByRequest": true,'
    cJson += ' "deliveryAddressCode": "'+alltrim(FWArrFilAtu( '01' , alltrim(SC1->C1_FILENT) )[18])+'",'
    cJson += ' "paymentAddressCode": "'+alltrim(SM0->M0_CGC)+'",'
    cJson += '"documentFormCode": "Rcpadrão", '
    cJson += ' "paymentTypeCode": "001",'
    cJson += ' "createdBy": "integracao_careplus@yopmail.com",'
   
    cJson +=  ' "companyCurrencyISO": "BRL",'
    cJson += '}'

  aRequest := U_ResInteg(cTipo, cJson, aHeader ,, .T.)


        If aRequest[1]
            
            oRet := aRequest[2]

            cMenssagem  := cTipoMsg+" com sucesso."
            cJsoRec     := aRequest[3]
            RecLock("SC1",.F.)
             SC1->C1_XIDNIMB   := alltrim(iif(Empty(oRet:ID),'',cvaltochar(oRet:ID)))
             //SC1->C1_XDTINT := dDatabase
             //SC1->C1_XHRINT := TIME()
             //SC1->C1_XSTAT := 1 
            MsUnlock()
             cIten :=  alltrim(iif(Empty(oRet:ID),'',cvaltochar(oRet:ID)))        
            U_MonitRes(cTipo, 2, , cIdPZB, cMenssagem, .T., cChave, cJson, cJsoRec, )
             lIten := .T.
        Else

            cMenssagem  := "Falha na "+cTipoMsg
            cJsoRec     := aRequest[3]
             RecLock("SC1",.F.)
             SC1->C1_XOBS   := iif(Empty(cJsoRec),'',cJsoRec)
             //SC1->C1_XDTINT := dDatabase
            //SC1->C1_XHRINT := TIME()
            //SC1->C1_XSTAT := '1' 
            MsUnlock()
            U_MonitRes(cTipo, 2, , cIdPZB, cMenssagem, .F., cChave, cJson, cJsoRec  )
            lIten := .F.
        EndIf

    //Finaliza o processo na PZB
    U_MonitRes(cTipo, 3, , cIdPZB, , .T.)


  //  https://api01-qa.nimbi.net.br/CompraAPI/rest/Requisitions/v1/{requisitionId}/items/cataloged

 
    If lIten
    cAlTrb :=GetNExtAlias()
        cTipo:= "0000AF"
        aCriaServ := U_MonitRes(cTipo, 1, nQtdReg)
        cLastTime := Time()
        cNum := SC1->C1_NUM 
        cQry := "SELECT * FROM "+RETSQLNAME("SC1")+"  where C1_FILIAL = '"+xFILIAL("SC1")+"' and C1_NUM = '"+SC1->C1_NUM+"' and D_E_L_E_T_ = ' ' "
        cQry:= ChangeQuery(cQry)
        If Select((cAlTrb)) > 0 
        (cAlTrb)->(DBCloseArea())
        EndIf
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cqry),cAlTrb,.T.,.T.)
        cJson := '['
        While !(cAlTrb)->(EOF()) 
        
            cJson +=   '{'
            cJson +=    '"code": "'+(cAlTrb)->C1_PRODUTO+'",'
            cJson +=    '"quantity": '+cvaltochar((cAlTrb)->C1_QUANT)+','
            cJson +=    '"unitPrice": '+cvaltochar(IiF((cAlTrb)->C1_XPRECO == 0 ,0.10,(cAlTrb)->C1_XPRECO))+','
            cJson +=    '"lineERP": "'+(cAlTrb)->C1_ITEM+'",'
            cJson +=    '"needDate": "'+Substr((cAlTrb)->C1_DATPRF,1,4)+'-'+Substr((cAlTrb)->C1_DATPRF,5,2)+'-'+Substr((cAlTrb)->C1_DATPRF,7,2)+'",'
            cJson +=    '"deliveryAddressCode": "'+alltrim(FWArrFilAtu( '01' , alltrim((cAlTrb)->C1_FILENT) )[18])+'",'
            cJson +=  '"paymentAddressCode": "'+alltrim(SM0->M0_CGC)+'",'
            cJson +=    '"paymentTypeCode": "001",'
            cJson +=     '"natureOfOperationCode": "1102",' 
            IF !Empty((cAlTrb)->C1_FORNECE)
                cJson +=     '"suggestedSupplierTaxNumber" : "'+POsicione("SA2",1,xFilial("SA2")+(cAlTrb)->C1_FORNECE+(cAlTrb)->C1_LOJA,"A2_CGC")+'",'
                cJson +=     '"suggestedSupplierCountryCode" : "BR",'
            EndIf
        //   cJson +=  ' "contractInfo": { "checkContract": true, "code": ""}, '
            cJson +=    '"costAllocations": [
            cJson +=      ' {
            cJson +=       '  "accountAssignmentCategoryCode": "00.'+iif(Alltrim((cAlTrb)->C1_XCLASS) == '1','2','1')+'",'
            cJson +=        ' "costAllocationDetailCode": "'+alltrim((cAlTrb)->C1_CC)+'",'
          //  If !Empty((cAlTrb)->C1_CLVL)
            //cJson +=         '"costAllocationComplementCode": "'+(cAlTrb)->C1_CLVL+'",'
            //EndIf
            cJson +=         '"percentage": 100 ,'
            cJson +=        '"costAllocationObs": "INT PROD '+(cAlTrb)->C1_PRODUTO+' "'
            cJson +=       '}'
            cJson +=    ']'
            cJson +=   '  },'
            (cAlTrb)->(DbSkip())
        Enddo    
        
        cJson := Substr(cJson,1,Len(cJson)-1)
        cJson +=   ']'
            //Id gerado na criacao do servico
        cIdPZB := aCriaServ[2]

        aRequest := U_ResInteg(cTipo, cJson, aHeader ,,.T.,,,,Alltrim(cIten) )

        If aRequest[1]
                    
            oRet := aRequest[2]

            cMenssagem  := cTipoMsg+" com sucesso."
            cJsoRec     := aRequest[3]
            RecLock("SC1",.F.)
            //SC1->C1_XOBS   := iif(Empty(oRet:ID),'',cvaltochar(oRet:ID))
            SC1->C1_XDTINT := dDatabase
            SC1->C1_XHRINT := TIME()
            SC1->C1_XSTAT := '1' 
            SC1->C1_XIDNBIT := cvaltochar(oRet:RESPONSELIST[1]:id)
            MsUnlock()
                        
            U_MonitRes(cTipo, 2, , cIdPZB, cMenssagem, .T., cChave, cJson, cJsoRec, )
            aAdd(aHeader,'username:integracao_careplus@yopmail.com')
            aCriaServ := U_MonitRes("0000AH", 1, nQtdReg)
            aRequest := U_ResInteg("0000AH",nil , aHeader ,, .T.,Alltrim(cIten)+'/publish',,, )
            U_MonitRes("0000AH", 2, , aCriaServ[2], "Publish", .T.,SC1->C1_NUM ,, , )
            U_MonitRes("0000AH", 3, , aCriaServ[2], , .T.)
        Else

            cMenssagem  := "Falha na "+cTipoMsg
            cJsoRec     := aRequest[3]
            RecLock("SC1",.F.)
                // SC1->C1_XOBS   := iif(Empty(cJsoRec),'',cJsoRec)
                SC1->C1_XDTINT := dDatabase
                SC1->C1_XHRINT := TIME()
                SC1->C1_XSTAT := '2' 
                MsUnlock()

            U_MonitRes(cTipo, 2, , cIdPZB, cMenssagem, .F., cChave, cJson, cJsoRec  )

        EndIf
    EndIf    

    U_MonitRes(cTipo, 3, , cIdPZB, , .T.)
EndIf    


Return


user Function SCNIMST(nStat)

Local cTipo     := '0000AI'
Local cTipoMsg  := '0000AI'
Local cUser     := Alltrim(GetMV("MV_USERNIM",.F.,"integracao_careplus@yopmail.com"))
Local nQtdReg   := 1
Local nL        := 0
Local oRet      := NIL
Local lIten := .F.
LOcal aCriaServ := {}
Local cAlias1   := GetNExtAlias()
Local AHEADER := {}
Private aBoxParam       := {} 
Private aRetParam	:= {}
Private aBusca:= {"statusCode=CANCELLED","statusCode=RETURNED"}

 Default nStat := 1  
aAdd(aHeader,'ClientAPI_ID:6951056a-bf4c-416e-8b80-366a2b97ac0e')
aAdd(aHeader,'ClientAPI_Key:1e8ec62d-7743-44ed-8558-a07477ea803e')
aAdd(aHeader,'companyTaxNumber:02725347000127')
aAdd(aHeader,'companyCountryCode:BR')
aAdd(aHeader,'Content-Type:application/json')
    aCriaServ := U_MonitRes(cTipo, 1, nQtdReg)
    cLastTime := Time()
    cIdPZB := aCriaServ[2]
    aRequest := {} 
    aRequest := U_ResInteg(cTipo,, aHeader ,, .T.,aBusca[nStat],,,)
  
    If aRequest[1]
        cMenssagem:= "Sucesso Id "
       For nL := 1 to Len(aRequest[2]["LISTREQUISITION"])
        cMenssagem+= cvaltochar(aRequest[2]["LISTREQUISITION"][nL]["ID"]) + ' ;'
        If Select((cAlias1)) > 0;(cAlias1)->(DbClosearea());EndIf
        BeginSql alias cAlias1
            Select *  FROM %table:SC1%
            Where %Notdel% and C1_XIDNIMB = %exp:aRequest[2]["LISTREQUISITION"][nL]["ID"]%
        EndSql 
        While !(cAlias1)->(EOF())
            DBSelectArea("SC1")
            DBSetOrder(1)
            If DBSeek((cAlias1)->(C1_FILIAL+C1_NUM+C1_ITEM+C1_ITEMGRD))
                RecLock("SC1",.F.)
                    SC1->C1_XSTAT := iif( nStat ==  1 ,'4','3')
                    SC1->C1_XOBS := iif( nStat ==  1 ,"Item Excluido no Nimbi","Devolvido pelo nimbi para alterar")
                SC1->(MsUnlock())
            EndIf
         (cAlias1)->(DbSkip())    
        Enddo    
        Next    
        cJsoRec := aRequest[3]
         U_MonitRes(cTipo, 2, , cIdPZB, cMenssagem, .T., "", , cJsoRec, )
    Else
        cMenssagem := "Falha na Api" +aRequest[3]
        cJsoRec     := aRequest[3]
        U_MonitRes(cTipo, 2, , cIdPZB, cMenssagem, .F., cChave,, cJsoRec  )

    EndIf
       

    U_MonitRes(cTipo, 3, , cIdPZB, , .T.)


Return

User Function SCNIMALT()


Local aCriaServ := {}
Local aHeader   := {}
Local aRequest  := {}
Local aRet      := {}
Local cIdPZB    := ""
Local cJson     := ""
Local cJsoRec   := ""
Local cLastTime := ""
Local cTipo     := '0000AJ'
Local cTipoMsg  := '0000AJ'
Local cUser     := Alltrim(GetMV("MV_USERNIM",.F.,"integracao_careplus@yopmail.com"))
Local nQtdReg   := 1
Local nX        := 0
Local oRet      := NIL
Local CCHAVE := SC1->C1_NUM
Local lIten := .F.
Private aBoxParam       := {} 
Private aRetParam	:= {}
Private cCliDe          := Space(TamSx3("C1_NUM")[1])
Private cPutPara     := Alltrim(SC1->C1_XIDNIMB)
Private cPutParam    := Alltrim(SC1->C1_XIDNIMB)+"/items/cataloged"    
Private     lret := .F.

    //Cria o log do servico no monitor
    aCriaServ := U_MonitRes(cTipo, 1, nQtdReg)
    cLastTime := Time()

    //Id gerado na criacao do servico
    cIdPZB := aCriaServ[2]

   
   aAdd(aHeader,'ClientAPI_ID:6951056a-bf4c-416e-8b80-366a2b97ac0e')
   aAdd(aHeader,'ClientAPI_Key:1e8ec62d-7743-44ed-8558-a07477ea803e')
   aAdd(aHeader,'companyTaxNumber:02725347000127')
   aAdd(aHeader,'companyCountryCode:BR')
   aAdd(aHeader,'Content-Type:application/json')
     
cJson :=  '{'
cJson +=' "codeERP": "'+SC1->C1_NUM+'",'
cJson += '"title": "'+SC1->C1_NUM+'",'
cJson += ' "requestPriorityId": "'+ IIF(Empty(SC1->C1_XPIORI),'2',SC1->C1_XPIORI) + '",'
cJson += ' "isAddressByRequest": true,'
cJson += ' "deliveryAddressCode": "'+alltrim(FWArrFilAtu( '01' , alltrim(SC1->C1_FILENT) )[18])+'",'
cJson += ' "paymentAddressCode": "'+alltrim(SM0->M0_CGC)+'",'
cJson += '"documentFormCode": "Rcpadrão", '
cJson += ' "paymentTypeCode": "001",'
cJson += ' "updatedBy": "integracao_careplus@yopmail.com",'
cJson += ' "suggestedSupplierCountryCode": "BR",'
cJson +=  ' "companyCurrencyISO": "BRL"'
cJson += '}'

  aRequest := U_ResInteg(cTipo, cJson, aHeader ,, .T.,cPutPara)


        If aRequest[1]
            
            oRet := aRequest[2]

            cMenssagem  := cTipoMsg+" com sucesso."
            cJsoRec     := aRequest[3]
            RecLock("SC1",.F.)
             SC1->C1_XIDNIMB   := alltrim(iif(Empty(oRet:ID),'',cvaltochar(oRet:ID)))
            MsUnlock()
                      
            U_MonitRes(cTipo, 2, , cIdPZB, cMenssagem, .T., cChave, cJson, cJsoRec, )
             lIten := .T.
        Else

            cMenssagem  := "Falha na "+cTipoMsg
            cJsoRec     := aRequest[3]
             RecLock("SC1",.F.)
             SC1->C1_XOBS   := iif(Empty(cJsoRec),'',cJsoRec)
            MsUnlock()
            U_MonitRes(cTipo, 2, , cIdPZB, cMenssagem, .F., cChave, cJson, cJsoRec  )
            lIten := .F.
        EndIf

    //Finaliza o processo na PZB
    U_MonitRes(cTipo, 3, , cIdPZB, , .T.)

If lIten
    cAlTrb :=GetNExtAlias()
    cTipo:= "0000AL"
    aCriaServ := U_MonitRes(cTipo, 1, nQtdReg)
    cLastTime := Time()
    cNum := SC1->C1_NUM 
    cQry := "SELECT * FROM "+RETSQLNAME("SC1")+"  where C1_FILIAL = '"+xFILIAL("SC1")+"' and C1_NUM = '"+SC1->C1_NUM+"' and D_E_L_E_T_ = ' ' "
    cQry:= ChangeQuery(cQry)
    If Select((cAlTrb)) > 0 
    (cAlTrb)->(DBCloseArea())
    EndIf
    aValorInc:={}
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cqry),cAlTrb,.T.,.T.)
    cJson := '['
    cJsonInc:= '['
    While !(cAlTrb)->(EOF()) 
      IF !Empty((cAlTrb)->C1_XIDNBIT)
            cJson +=   '{'
            cJson +=    '"ID" : '+(cAlTrb)->C1_XIDNBIT+' ,' 
            cJson +=    '"code": "'+(cAlTrb)->C1_PRODUTO+'",'
            cJson +=    '"quantity": '+cvaltochar((cAlTrb)->C1_QUANT)+','
            cJson +=    '"unitPrice": 0.17,'
            cJson +=    '"lineERP": "'+(cAlTrb)->C1_ITEM+'",'
            cJson +=    '"needDate": "'+Substr((cAlTrb)->C1_DATPRF,1,4)+'-'+Substr((cAlTrb)->C1_DATPRF,5,2)+'-'+Substr((cAlTrb)->C1_DATPRF,7,2)+'",'
            cJson +=    '"deliveryAddressCode": "'+alltrim(FWArrFilAtu( '01' , alltrim((cAlTrb)->C1_FILENT) )[18])+'",'
            cJson +=  '"paymentAddressCode": "'+alltrim(SM0->M0_CGC)+'",'
            cJson +=    '"paymentTypeCode": "001",'
            cJson +=     '"natureOfOperationCode": "1102"' 
            cJson +=   '  },'
       Else
            cJsonInc +=   '{'
            cJsonInc +=    '"code": "'+(cAlTrb)->C1_PRODUTO+'",'
            cJsonInc +=    '"quantity": '+cvaltochar((cAlTrb)->C1_QUANT)+','
            cJsonInc +=    '"unitPrice": '+cvaltochar(IiF((cAlTrb)->C1_XPRECO == 0 ,0.10,(cAlTrb)->C1_XPRECO))+','
            cJsonInc +=    '"lineERP": "'+(cAlTrb)->C1_ITEM+'",'
            cJsonInc +=    '"needDate": "'+Substr((cAlTrb)->C1_DATPRF,1,4)+'-'+Substr((cAlTrb)->C1_DATPRF,5,2)+'-'+Substr((cAlTrb)->C1_DATPRF,7,2)+'",'
            cJsonInc +=    '"deliveryAddressCode": "'+alltrim(FWArrFilAtu( '01' , alltrim((cAlTrb)->C1_FILENT) )[18])+'",'
            cJsonInc +=  '"paymentAddressCode": "'+alltrim(SM0->M0_CGC)+'",'
            cJsonInc +=    '"paymentTypeCode": "001",'
            cJsonInc +=     '"natureOfOperationCode": "1102",' 
            IF !Empty((cAlTrb)->C1_FORNECE)
                cJsonInc +=     '"suggestedSupplierTaxNumber" : "'+POsicione("SA2",1,xFilial("SA2")+(cAlTrb)->C1_FORNECE+(cAlTrb)->C1_LOJA,"A2_CGC")+'",'
                cJsonInc +=     '"suggestedSupplierCountryCode" : "BR",'
            EndIf
            //   cJson +=  ' "contractInfo": { "checkContract": true, "code": ""}, '
            cJsonInc +=    '"costAllocations": [
            cJsonInc +=      ' {
            cJsonInc +=       '  "accountAssignmentCategoryCode": "00.'+iif(Alltrim((cAlTrb)->C1_XCLASS) == '1','2','1')+'",'
            cJsonInc +=        ' "costAllocationDetailCode": "'+alltrim((cAlTrb)->C1_CC)+'",'
            //If !Empty((cAlTrb)->C1_CLVL)
           // cJsonInc +=         '"costAllocationComplementCode": "'+(cAlTrb)->C1_CLVL+'",'
           // EndIf
            cJsonInc +=         '"percentage": 100 ,'
            cJsonInc +=        '"costAllocationObs": "INT PROD '+(cAlTrb)->C1_PRODUTO+' "'
            cJsonInc +=       '}'
            cJsonInc +=    ']'
            cJsonInc +=   '  },'
            AAdd(aValorInc,(cAlTrb)->(C1_FILIAL+C1_NUM)+(cAlTrb)->C1_ITEM)
       EndIf 
        (cAlTrb)->(DbSkip())
    Enddo    
    
    cJson := Substr(cJson,1,Len(cJson)-1)
    cJson +=   ']'
    cJsonInc := IIF(alltrim(Substr(cJsonInc,1,Len(cJsonInc)-1)) == '','',Substr(cJsonInc,1,Len(cJsonInc)-1))
    cJsonInc+= iif(EMpty(cJsonInc),'',']')
    

   
    
    cIdPZB := aCriaServ[2]

    aRequest := U_ResInteg(cTipo, cJson, aHeader ,, .T.,cPutParam)

    If aRequest[1]
                
        oRet := aRequest[2]

        cMenssagem  := cTipoMsg+" com sucesso."
        cJsoRec     := aRequest[3]
        RecLock("SC1",.F.)
        //SC1->C1_XOBS   := iif(Empty(oRet:ID),'',cvaltochar(oRet:ID))
        SC1->C1_XDTINT := dDatabase
        SC1->C1_XHRINT := TIME()
        SC1->C1_XSTAT := '1' 
        MsUnlock()
        lret := .T.
         U_MonitRes(cTipo, 2, , cIdPZB, cMenssagem, .T., cChave, cJson, cJsoRec, )
    Else

        cMenssagem  := "Falha na "+cTipoMsg
        cJsoRec     := aRequest[3]
        RecLock("SC1",.F.)
            // SC1->C1_XOBS   := iif(Empty(cJsoRec),'',cJsoRec)
             SC1->C1_XDTINT := dDatabase
            SC1->C1_XHRINT := TIME()
            SC1->C1_XSTAT := '2' 
            MsUnlock()

        U_MonitRes(cTipo, 2, , cIdPZB, cMenssagem, .F., cChave, cJson, cJsoRec  )

    EndIf
    If !Empty(cJsonInc)
        
        
        cTipo:= "0000AF"
        aCriaServ := U_MonitRes(cTipo, 1, nQtdReg)
        cIdPZB := aCriaServ[2]
        aRequest := U_ResInteg(cTipo, cJsonInc, aHeader ,,.T.,,,,Alltrim(cPutPara) )

        If aRequest[1]
                    
            oRet := aRequest[2]

            cMenssagem  := cTipoMsg+" com sucesso."
            cJsoRec     := aRequest[3]
            For nU := 1 to  len(aValorInc)
            dbSelectArea("SC1")
            dbSetOrder(1)
            DBSeek(aValorInc[nU])
            RecLock("SC1",.F.)
            //SC1->C1_XOBS   := iif(Empty(oRet:ID),'',cvaltochar(oRet:ID))
            SC1->C1_XDTINT := dDatabase
            SC1->C1_XHRINT := TIME()
            SC1->C1_XSTAT := '1' 
            SC1->C1_XIDNIMB := Alltrim(cPutPara)
            SC1->C1_XIDNBIT := cvaltochar(oRet:RESPONSELIST[1]:id)
            MsUnlock()
            Next            
            U_MonitRes(cTipo, 2, , cIdPZB, cMenssagem, .T., cChave, cJsonInc, cJsoRec, )
            aAdd(aHeader,'username:integracao_careplus@yopmail.com')
            aCriaServ := U_MonitRes("0000AH", 1, nQtdReg)
            aRequest := U_ResInteg("0000AH",nil , aHeader ,, .T.,Alltrim(cPutPara)+'/publish',,, )
            U_MonitRes("0000AH", 2, , aCriaServ[2], "Publish", .T.,SC1->C1_NUM ,, , )
            U_MonitRes("0000AH", 3, , aCriaServ[2], , .T.)
            lret :=.F.
        Else

            cMenssagem  := "Falha na "+cTipoMsg
            cJsoRec     := aRequest[3]
            RecLock("SC1",.F.)
                // SC1->C1_XOBS   := iif(Empty(cJsoRec),'',cJsoRec)
                SC1->C1_XDTINT := dDatabase
                SC1->C1_XHRINT := TIME()
                SC1->C1_XSTAT := '2' 
                MsUnlock()

            U_MonitRes(cTipo, 2, , cIdPZB, cMenssagem, .F., cChave, cJsonInc, cJsoRec  )

        EndIf
    EndIf
       If lret              
            
            aAdd(aHeader,'username:integracao_careplus@yopmail.com')
            aCriaServ := U_MonitRes("0000AH", 1, nQtdReg)
            aRequest := U_ResInteg("0000AH",nil , aHeader ,, .T.,Alltrim(SC1->C1_XIDNIMB)+'/publish',,, )
            U_MonitRes("0000AH", 2, , aCriaServ[2], "Publish", .T.,SC1->C1_NUM ,, , )
         U_MonitRes("0000AH", 3, , aCriaServ[2], , .T.)
        EndIf 
EndIf    

U_MonitRes(cTipo, 3, , cIdPZB, , .T.)



Return


User Function SCNIMATC()

//https://api01-qa.nimbi.net.br/CompraAPI/rest/Requisitions/v1/{requisitionId}/attachs
Local cTipo     := '0000AM'
Local cTipoMsg  := '0000AM'
Local cUser     := Alltrim(GetMV("MV_USERNIM",.F.,"integracao_careplus@yopmail.com"))
Local nQtdReg   := 1
Local nL        := 0
Local oRet      := NIL
Local lIten := .F.
LOcal aCriaServ := {}
Local cAlias1   := GetNExtAlias()
Local AHEADER := {}
Local aFiles := {} // O array receberá os nomes dos arquivos e do diretório
Local aSizes := {} // O array receberá os tamanhos dos arquivos e do diretorio
Local nX
Private aBoxParam       := {} 
Private aRetParam	:= {}
Private cPutParam:= Alltrim(SC1->C1_XIDNIMB)+"/Attach"

 
aAdd(aHeader,'ClientAPI_ID:6951056a-bf4c-416e-8b80-366a2b97ac0e')
aAdd(aHeader,'ClientAPI_Key:1e8ec62d-7743-44ed-8558-a07477ea803e')
aAdd(aHeader,'companyTaxNumber:02725347000127')
aAdd(aHeader,'companyCountryCode:BR')
aAdd(aHeader,'Content-Type:application/json')
BeginSql Alias cAlias1
SELECT C9.R_E_C_N_O_ REC,* FROM %table:AC9% C9
Inner JOIN %table:ACB% CB on AC9_CODOBJ = ACB_CODOBJ and Ac9_FILIAL = ACB_FILIAL and  CB.%Notdel%
INNER JOIN %table:SC1% C1  on SUBSTRING(AC9_CODENT,1,4) = C1_FILIAL and SUBSTRING(AC9_CODENT,5,6) = C1_NUM and SUBSTRING(AC9_CODENT,11,4) = C1_ITEM and C1.%Notdel% and C1_NUM = '367095'
where AC9_ENTIDA = 'SC1'  AND  C9.%Notdel%  AND AC9_XNIMB IN ('N',' ') 
Order by AC9_FILIAL
EndSql


aCriaServ := U_MonitRes(cTipo, 1, nQtdReg)
cLastTime := Time()
cIdPZB := aCriaServ[2]
aRequest := {} 

ADir("\DIRDOC\CO01\SHARED\*.*", aFiles, aSizes)
cLeitura1:= ""
fHdl := fOpen("\DIRDOC\CO01\SHARED\"+aFiles[1],FO_READ,,.F.)
if fHdl = -1
conout("Erro ao abrir arquivo.")
return
endif
nLen := fSeek(fHdl,0,FS_END)
fSeek(fhdl, 0)
fRead(fHdl, cLeitura1, nLen)
fClose(fHdl)
 
DBSelectArea("SC1")
DBSetOrder(1)
DBSeek((cAlias1)->(C1_FILIAL+C1_NUM+C1_ITEM+C1_ITEMGRD))
cLeitura1 := Encode64(cLeitura1)
cJson := '{'
cJson +=   '"FileName": "'+(cAlias1)->ACB_DESCRI+'",'
cJson +=  '"Attach": "'+cLeitura1+'",'
cJson +=  '"IsPublic": true' 
cJson += '}'
cPutParam:= Alltrim(SC1->C1_XIDNIMB)+"/Attach"
cChave:= Alltrim(SC1->C1_XIDNIMB)
aRequest := U_ResInteg(cTipo,cJson, aHeader ,, .T.,cPutParam,,,)
cJson:= ''
  
    If aRequest[1]
        cMenssagem:= "Sucesso Id "
        cJsoRec := aRequest[3] 
        DBSelectArea("AC9")
        AC9->(DbGOto((cAlias1)->REC))
        RecLock("AC9",.F.)
            AC9->AC9_XNIMB := 'S'
        MsUnlock()
         U_MonitRes(cTipo, 2, , cIdPZB, cMenssagem, .T., "", , cJsoRec, )
    Else
        DBSelectArea("AC9")
        AC9->(DbGOto((cAlias1)->REC))
        RecLock("AC9",.F.)
            AC9->AC9_XNIMB := 'N'
        MsUnlock()
        cMenssagem := "Falha na Api" 
        cJsoRec     :=  aRequest[3]
        U_MonitRes(cTipo, 2, , cIdPZB, cMenssagem, .F., cChave,, cJsoRec  )
    EndIf
       

    U_MonitRes(cTipo, 3, , cIdPZB, , .T.)
Return


WsRestFul GetSoliCbc Description "Metodo Responsavel por Cabec Solicitacao Compras "
WsData cIdStruct    As String 
WsData RECEIVE      as String Optional


WsMethod Get Description "Solicitacao Compras " WsSyntax "/GetSoliCbc"
WSMETHOD PUT DESCRIPTION "Put com Json"        WsSyntax "/GetSoliCbc/IdScNimb"

End WsRestFul

WsMethod Get WsReceive cIdStruct  WsService GetSoliCbc

	Local cJson     := ""
	Local cQuery    := "" 
	Local cChave	:= ""  
	Local cIdPZB	:= "" 

	Local nX		:= 0



	Local aCriaServ := {}
	Local aEmpresas := FwLoadSM0()
    Local cIdStruct   := IIF(::cIdStruct <> Nil, ::cIdStruct, "")

    cCgcEmp := '02725347000127'
	nPosEmp := Ascan(aEmpresas, {|x| Alltrim(x[18]) == cCgcEmp })

	Private cAlsQry   := CriaTrab(Nil,.F.)
	Private cAlsRes   := CriaTrab(Nil,.F.)
	Private cQryRes   := ""

	If nPosEmp == 0
		cJson := '{"Erro":"Empresa nao cadastrada."}'
		::SetResponse( cJson )
		Return .T.
	Else
		RpcClearEnv()
		RpcSetEnv(aEmpresas[nPosEmp][1],aEmpresas[nPosEmp][2])
	EndIf   

	cQuery 	:= " SELECT PR2_CPODES RECSC1 FROM " + RetSqlName("PR2") + " (NOLOCK) PR2 "
//	cQuery 	+= " INNER JOIN " + RetSqlName("PR1") + " (NOLOCK) PR1 "
//	cQuery 	+= " ON PR2_FILIAL = PR1_FILIAL AND PR2_CODIGO = PR1_CODIGO "
	cQuery 	+= " WHERE PR2_CODIGO = '"+cIdStruct+"' AND PR2.D_E_L_E_T_ = ' ' and PR2_CONTEU = ' ' "

	If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

	While !(cAlsQry)->(Eof())
        DBSelectArea("SC1")
        SC1->(DBGoto(val((cAlsQry)->RECSC1)))
        cJson :=  '{'
        cJson +=' "codeERP": "'+SC1->C1_NUM+'",'
        cJson += '"title": "'+SC1->C1_NUM+'",'
        cJson += ' "requestPriorityId": "'+ IIF(Empty(SC1->C1_XPIORI),'2',SC1->C1_XPIORI) + '",'
        cJson += ' "isAddressByRequest": true,'
        cJson += ' "deliveryAddressCode": "'+alltrim(FWArrFilAtu( '01' , alltrim(SC1->C1_FILENT) )[18])+'",'
        cJson += ' "paymentAddressCode": "'+alltrim(SM0->M0_CGC)+'",'
        cJson += '"documentFormCode": "Rcpadrao", '
        cJson += ' "paymentTypeCode": "001",'
        cJson += ' "createdBy": "integracao_careplus@yopmail.com",'
        cJson +=  ' "companyCurrencyISO": "BRL"'
        cJson += '}''
    (cAlsQry)->(DbSkip())
   Enddo 

::SetContentType("application/json")
::SetResponse( cJson )

Return .t.

WSMETHOD PUT  WSSERVICE GetSoliCbc

Local  cJSON := ''// –> Pega a string do JSON

Local oParseJSON := Nil
cJSON := Self:GetContent() 

conout('daa'+cJson)

::SetContentType("application/json")

// –> Deserializa a string JSON

FWJsonDeserialize(cJson, @oParseJSON)

return .T.