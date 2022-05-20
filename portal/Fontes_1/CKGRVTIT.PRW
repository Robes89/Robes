#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "SHELL.CH"

/*/{Protheus.doc}CKGRVTIT()

Gravacao de Dados no contas a pagar para geracao de bordero

@author Ovio Consultoria
@since 11/03/2021
@version P12 
@param 	
@return	
/*/ 

User Function CKGRVTIT
    Local aArea     := GetArea()
    Local aAreaSF1  := SF1->(GetArea())
    Private LLGPD   := .F.
	Private cTitulo := "Forma de Pagamento"
    Private oTmpTab := Nil
    Private oTela   := Nil
	Private OMRKBRW := Nil
    Private cArqTrb	:= ""
    Private cCpoidx := ""
    Private nRadio1 := 1
	Private nRadio2 := 0
    Private nRadio3 := 1
	Private cBcoPad := Alltrim(GetMv("PS_XBCOPAD"))

    Private nValDup := MaFisRet(,"NF_BASEDUP")
    Private cObs    := Space(TamSx3("E2_HIST")[1])

	Private aItems1 := {;
		'03 - DOC',;
		'41 - TED'  ,;
		'45 - PIX TRANSFERENCIA',;
		'30 - BOLETO BANCARIO'}

	Private aItems2 := {;
		'Código de Barras',;
        'Linha Digitavel' }

    Private aItems3 := {;
		'Fiscal',;
        'Cartão de Credito',;
        'Reembolso',;
		'Nota Débito' }        
    
    Private aStruct  := {}
    Private aColumns := {}
    Private cCpoMark := ""

    fDataBrw()
    
    aSize := MSADVSIZE()

	oSize := FWDefSize():New(.T.)

	oSize:AddObject("MASTER",100,100,.T.,.T.)
	oSize:lLateral := .F.
	oSize:lProp := .T.

	oSize:Process()
	
    If nValDup <> 0

        DEFINE MSDIALOG oTela FROM 0, 0 To oSize:aWindSize[3]-500,oSize:aWindSize[4]-950 Title cTitulo  Of GetWndDefault() PIXEL STYLE DS_MODALFRAME STATUS
        oTela:lEscClose := .F.

        oTPane1 := TPanel():New(0,0,"",oTela,NIL,.T.,.F.,NIL,NIL,0,100,.T.,.T.)
        oTPane1:Align := CONTROL_ALIGN_TOP
            
    
        oGrupo1:= TGroup():New(005,005,070,130,'Forma de Pagamento',oTPane1,,,.T.)
        oRadio1:= TRadMenu():New(020,010,aItems1, {|u| Iif(PCount()==0,nRadio1,nRadio1:=u)} ,oTPane1 ,,,,,,,, 80 ,11,,,,.T.,.F.,)
        oRadio1:bChange := {|| fSetControl() }

        oGrupo2:= TGroup():New(005,135,070,250,'Tipo de Entrada',oTPane1,,,.T.)
        oRadio2:= TRadMenu():New(020,140,aItems2, {|u| Iif(PCount()==0,nRadio2,nRadio2:=u)} ,oTPane1 ,,,,,,,, 80 ,11,,,,.T.,.F.,)
    
        oGrupo3:= TGroup():New(005,255,070,370,'Tipo de Documento',oTPane1,,,.T.)
        oRadio3:= TRadMenu():New(020,260,aItems3, {|u| Iif(PCount()==0,nRadio3,nRadio3:=u)} ,oTPane1 ,,,,,,,, 80 ,11,,,,.T.,.F.,)
		
		oGetObs:= TGet():New(075,005 ,{|u| If(PCount()>0,cObs:=u,cObs)},oTPane1,213,16, '@!',, 0,,/*oFont4*/,.F.,,.T.,,.F.,,.F., .F.,,.F., .F.,, "cObs",,,,,,, "Observação: " ,2 ,  /*oFont4*/ , /*CLR_RED*/,,,)

        oTButton1 := TButton():Create( oTPane1 , 005 , (oTPane1:nClientWidth/2)-060 ,"Confirmar"           , {|| fSalvar(.T.)	  }, 55 ,14,,,,.T.,,,,,,)
        oTButton2 := TButton():Create( oTPane1 , 023 , (oTPane1:nClientWidth/2)-060 ,"Dados Boletos"       , {|| fCompTit()   }, 55 ,14,,,,.T.,,,,,,)
        oTButton2 := TButton():Create( oTPane1 , 041 , (oTPane1:nClientWidth/2)-060 ,"Cadastro PIX/Bancos" , {|| fCadFor()    }, 55 ,14,,,,.T.,,,,,,)
        oTButton3 := TButton():Create( oTPane1 , 059 , (oTPane1:nClientWidth/2)-060 ,"Cancelar"            , {|| oTela:End()  }, 55 ,14,,,,.T.,,,,,,)
            
        oTPane2 := TPanel():New(0,0,"",oTela,NIL,.T.,.F.,NIL,NIL,0,0,.T.,.F.)
        oTPane2:Align := CONTROL_ALIGN_ALLCLIENT
        
        oMrkBrw := FWMarkBrowse():New()
        oMrkBrw:oBrowse:SetEditCell(.T.)
        oMrkBrw:SetIgnoreARotina(.T.)
        oMrkBrw:SetFieldMark(cCpoMark)
        oMrkBrw:SetOwner(oTPane2)
        oMrkBrw:SetAlias(cArqTrb)
        oMrkBrw:SetMenuDef("")
        oMrkBrw:SetCustomMarkRec({|| fMarkUni() })
        oMrkBrw:SetAllMark({|| fMarkAll() })
        oMrkBrw:SetDescription("")
        oMrkBrw:SetColumns(aColumns)
        oMrkBrw:SetTemporary(.T.)
        oMrkBrw:DisableDetails()
        oMrkBrw:DisableConfig()
        oMrkBrw:DisableReport()
        oMrkBrw:DisableFilter()
        oMrkBrw:DisableSaveConfig()
        oMrkBrw:Activate()

        Activate MsDialog oTela Centered

     Else

        DEFINE MSDIALOG oTela FROM 0, 0 To 200,400 Title cTitulo  Of GetWndDefault() PIXEL STYLE DS_MODALFRAME STATUS
        oTela:lEscClose := .F.

        oTPane1 := TPanel():New(0,0,"",oTela,NIL,.T.,.F.,NIL,NIL,0,100,.T.,.T.)
        oTPane1:Align := CONTROL_ALIGN_TOP
   
        oGrupo3:= TGroup():New(005,005,070,130,'Tipo de Documento',oTPane1,,,.T.)
        oRadio3:= TRadMenu():New(020,010,aItems3, {|u| Iif(PCount()==0,nRadio3,nRadio3:=u)} ,oTPane1 ,,,,,,,, 80 ,11,,,,.T.,.F.,)

        oTButton1 := TButton():Create( oTPane1 , 007 , (oTPane1:nClientWidth/2)-060 ,"Confirmar"           , {|| fSalvar(.F.)	  }, 55 ,14,,,,.T.,,,,,,)
        oTButton3 := TButton():Create( oTPane1 , 025 , (oTPane1:nClientWidth/2)-060 ,"Cancelar"            , {|| oTela:End()  }, 55 ,14,,,,.T.,,,,,,)
            
        Activate MsDialog oTela Centered
     Endif
    RestArea(aArea)   
    RestArea(aAreaSF1)

Return

/*/{Protheus.doc}'fMarkAll()'
'Marcar todos registros na temporaria'
@author Ovio Consultoria
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/


Static Function fMarkUni()

Local __cAlias:= oMrkBrw:Alias()

If nRadio1==4
    If ( !oMrkBrw:IsMark() )
        RecLock((__cAlias),.F.)
        (__cAlias)->&(cCpoMark)  := oMrkBrw:Mark()
        (__cAlias)->(MsUnLock())
    Else
        RecLock((__cAlias),.F.)
        (__cAlias)->&(cCpoMark)   := ""
        (__cAlias)->(MsUnLock())
    EndIf     
Else
    aAreaX := (__cAlias)->(GetArea())
    (__cAlias)->(dbGotop()) 
    While (__cAlias)->(!Eof()) 
        RecLock(__cAlias,.F.)
        (__cAlias)->&(cCpoMark)  := ""
        (__cAlias)->(MsUnLock())
        (__cAlias)->(DbSkip())  
    End
    RestArea(aAreaX)
    RecLock((__cAlias),.F.)
    (__cAlias)->&(cCpoMark)  := oMrkBrw:Mark()
    (__cAlias)->(MsUnLock())
Endif    

oMrkBrw:Refresh(.T.)

Return( .T. )


/*/{Protheus.doc}'fMarkAll()'
'Marcar todos registros na temporaria'
@author Ovio Consultoria
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/

Static Function fMarkAll()

Local __cAlias:= oMrkBrw:Alias()

(__cAlias)->(dbGotop()) 
While (__cAlias)->(!Eof()) 
	If (!oMrkBrw:IsMark())
		RecLock((__cAlias),.F.)
		(__cAlias)->&(cCpoMark)  := oMrkBrw:Mark()
		(__cAlias)->(MsUnLock())
	Else
		RecLock(__cAlias,.F.)
		(__cAlias)->&(cCpoMark)  := ""
		(__cAlias)->(MsUnLock())
	EndIf 
	(__cAlias)->(DbSkip())  
End

oMrkBrw:Refresh(.T.)

Return( .T. )

/*/{Protheus.doc}'fSetControl()'
'Controle dos campos na Tela    '
@author Ovio Consultoria
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/

Static Function fSetControl()

	If nRadio1 == 1 .Or. nRadio1 == 2  .Or. nRadio1 == 3 
		nRadio2:= 0
        oRadio2:= TRadMenu():New(020,140,aItems2, {|u| Iif(PCount()==0,nRadio2,nRadio2:=u)} ,oTPane1 ,,,,,,,, 70 ,11,,,,.T.,.F.,)
		oRadio2:Disable(1)
        oRadio2:Disable(2)
	Elseif nRadio1 == 4
		oRadio2:SetOption(1)
		oRadio2:Enable(1)
        oRadio2:Enable(2)
	Endif
    fDataBrw()
	oRadio2:Refresh()

Return

/*/{Protheus.doc}fDataBrw()

Dados para selecao

@author Ovio Consultoria
@since 11/03/2021
@version P12 
@param 	
@return	
/*/ 

Static Function fDataBrw()
    Local aArea     := GetArea()
    Local aAreaSF1  := SF1->(GetArea())
    Local nCampo := 1
    Local cQuery := ""
    Local cTab   := ""
    Local lDrop  := .F.

    If oTmpTab <> NIL
        lDrop  := .T.
        oMrkBrw:DeActivate()
        oTmpTab:Delete()
        oTmpTab := NIL
	EndIf

	cArqTrb	:= GetNextAlias()
	oTmpTab := FwTemporaryTable():New(cArqTrb)

    If nRadio1==1 .Or. nRadio1==2 
    
        cQuery += "SELECT	FIL_BANCO" + CRLF
        cQuery += ",		FIL_AGENCI" + CRLF
        cQuery += ",		FIL_DVAGE" + CRLF
        cQuery += ",		FIL_CONTA" + CRLF
        cQuery += ",		FIL_DVCTA" + CRLF
        cQuery += ",		X5_DESCRI AS A6_NOME" + CRLF
        cQuery += " FROM "+RetSqlName("FIL")+" FIL "+ CRLF
        cQuery += " LEFT OUTER JOIN ( SELECT RTRIM(LTRIM(X5_CHAVE)) X5_CHAVE,X5_DESCRI FROM "+RetSqlName("SX5")+" SX5 WHERE SX5.X5_TABELA = '0N' AND SX5.D_E_L_E_T_=' ' ) TBX ON TBX.X5_CHAVE=FIL_BANCO" + CRLF
        cQuery += " WHERE	FIL.FIL_FILIAL = '" + FWxFilial("FIL") + "'" + CRLF
        cQuery += " AND FIL.FIL_FORNEC = '"+SF1->F1_FORNECE+"' " + CRLF
        cQuery += " AND FIL.FIL_LOJA   = '"+SF1->F1_LOJA+"' " + CRLF
        cQuery += " AND	FIL.D_E_L_E_T_ = ' '" + CRLF
        cQuery += " ORDER BY " + SqlOrder(FIL->(IndexKey())) + CRLF
               
        cTab     := "FIL"
        cCpoMark := "FIL_OK"
        cCpoidx  := "FIL_OK"
        aStruct  := {}
      
        Aadd(aStruct, { cCpoMark   , "C", 1 , 0})
	    Aadd(aStruct, {"FIL_BANCO" ,TamSx3("FIL_BANCO")[3] ,TamSx3("FIL_BANCO")[1] ,TamSx3("FIL_BANCO")[2]})
	    Aadd(aStruct, {"FIL_AGENCI",TamSx3("FIL_AGENCI")[3],TamSx3("FIL_AGENCI")[1],TamSx3("FIL_AGENCI")[2]})
	    Aadd(aStruct, {"FIL_DVAGE" ,TamSx3("FIL_DVAGE")[3] ,TamSx3("FIL_DVAGE")[1] ,TamSx3("FIL_DVAGE")[2]})
	    Aadd(aStruct, {"FIL_CONTA" ,TamSx3("FIL_CONTA")[3] ,TamSx3("FIL_CONTA")[1] ,TamSx3("FIL_CONTA")[2]})
	    Aadd(aStruct, {"FIL_DVCTA" ,TamSx3("FIL_DVCTA")[3] ,TamSx3("FIL_DVCTA")[1] ,TamSx3("FIL_DVCTA")[2]})
        Aadd(aStruct, {"A6_NOME"   ,TamSx3("X5_DESCRI ")[3],TamSx3("X5_DESCRI ")[1],TamSx3("X5_DESCRI ")[2]})

    Elseif nRadio1==3
        
        cQuery :=""
        cQuery += " SELECT CASE WHEN F72_TPCHV='01' THEN 'Telefone' " + CRLF
        cQuery += "             WHEN F72_TPCHV='02' THEN 'E-mail'   " + CRLF
        cQuery += "             WHEN F72_TPCHV='03' THEN 'CPF/CNPJ' " + CRLF
        cQuery += "             WHEN F72_TPCHV='04' THEN 'Chave Aleatória' Else '' End As F72_TPCHV," + CRLF
        cQuery += "        CASE WHEN F72_ACTIVE='1' THEN 'Sim' " + CRLF
        cQuery += "             WHEN F72_ACTIVE='2' THEN 'Nao' Else '' End As F72_ACTIVE,F72_CHVPIX" + CRLF
        cQuery += " FROM "+RetSqlName("F72")+" F72 " + CRLF
        cQuery += " WHERE " + CRLF
        cQuery += " F72_FILIAL= '" + FWxFilial("F72") + "' AND " + CRLF
        cQuery += " F72_COD='"+SF1->F1_FORNECE+"' AND " + CRLF
        cQuery += " F72_LOJA='"+SF1->F1_LOJA+"' AND   " + CRLF
        cQuery += " F72.D_E_L_E_T_=' '  " + CRLF
        cQuery += " ORDER BY F72_ACTIVE " + CRLF

        cTab     := "F72"
        cCpoMark := "F72_OK"
        cCpoidx  := "F72_OK"
        aStruct  := {}
      
        Aadd(aStruct, { cCpoMark   , "C", 1 , 0})
	    Aadd(aStruct, {"F72_TPCHV" , "C" ,15 ,0})
	    Aadd(aStruct, {"F72_ACTIVE", "C" ,6  ,0})
	    Aadd(aStruct, {"F72_CHVPIX",TamSx3("F72_CHVPIX")[3],TamSx3("F72_CHVPIX")[1],TamSx3("F72_CHVPIX")[2]})


    Elseif nRadio1==4
        
        cQuery := ""
        cQuery += "SELECT	E2_NUM" + CRLF
        cQuery += ",		E2_PARCELA" + CRLF
        cQuery += ",		E2_VENCREA" + CRLF
        cQuery += ",		E2_VALOR" + CRLF
        cQuery += ",		E2_LINDIG" + CRLF
        cQuery += ",		E2_CODBAR" + CRLF
        cQuery += " FROM		" + RetSqlName("SE2") + " SE2" + CRLF
        cQuery += " WHERE	SE2.E2_FILIAL = '" + FWxFilial("SE2") + "'" + CRLF
        cQuery += " AND SE2.E2_FORNECE = '"+SF1->F1_FORNECE+"' "
        cQuery += " AND SE2.E2_LOJA    = '"+SF1->F1_LOJA+"' "
        cQuery += " AND SE2.E2_NUM     = '"+SF1->F1_DOC+"' "
        cQuery += " AND SE2.E2_PREFIXO = '"+SF1->F1_SERIE+"' "
        cQuery += " AND	SE2.D_E_L_E_T_ = ' '" + CRLF
        cQuery += " ORDER BY " + SqlOrder(SE2->(IndexKey())) + CRLF

        cTab     := "SE2"
        cCpoMark := "E2_OK"
        cCpoidx  := "E2_OK"
        aStruct  := {}
      
        Aadd(aStruct, {"E2_OK"     ,"C" , 1 ,0})
    	Aadd(aStruct, {"E2_NUM"    ,TamSx3("E2_NUM")[3]     ,TamSx3("E2_NUM")[1]     ,TamSx3("E2_NUM")[2]  })
        Aadd(aStruct, {"E2_PARCELA",TamSx3("E2_PARCELA")[3] ,TamSx3("E2_PARCELA")[1] ,TamSx3("E2_PARCELA")[2]})
    	Aadd(aStruct, {"E2_VENCREA",TamSx3("E2_VENCREA")[3] ,TamSx3("E2_VENCREA")[1] ,TamSx3("E2_VENCREA")[2]})
    	Aadd(aStruct, {"E2_VALOR"  ,TamSx3("E2_VALOR")[3]   ,TamSx3("E2_VALOR")[1]   ,TamSx3("E2_VALOR")[2]})
    	Aadd(aStruct, {"E2_LINDIG" ,TamSx3("E2_LINDIG")[3]  ,TamSx3("E2_LINDIG")[1]  ,TamSx3("E2_LINDIG")[2]})
    	Aadd(aStruct, {"E2_CODBAR" ,TamSx3("E2_CODBAR")[3]  ,TamSx3("E2_CODBAR")[1]  ,TamSx3("E2_CODBAR")[2]})

    Endif   
 	
    aColumns := {}
    For nCampo := 1 To Len( aStruct )
		If	Right(aStruct[nCampo][1],2) <> "OK" .And. aStruct[nCampo][1]<>"E2_CODBAR"
            AAdd(aColumns, FWBrwColumn():New())
            aColumns[Len(aColumns)]:SetData( &("{||" + aStruct[nCampo][1] + "}") )
            aColumns[Len(aColumns)]:SetTitle(RetTitle(aStruct[nCampo][1]))
            aColumns[Len(aColumns)]:SetSize(aStruct[nCampo][3])
            aColumns[Len(aColumns)]:SetDecimal(aStruct[nCampo][4])
            aColumns[Len(aColumns)]:SetPicture(PesqPict(cTab, aStruct[nCampo][1]))
        Endif    
	Next nCampo

    oTmpTab:SetFields(aStruct)
    oTmpTab:AddIndex("1",{cCpoidx})
	oTmpTab:Create()

    cQuery := ChangeQuery(cQuery)

	Processa({|| SqlToTrb(cQuery, aStruct, cArqTrb )})

    If lDrop
        fCKBrowse()
        oTela:Refresh()
        oTPane2:Refresh()
        oMrkBrw:Refresh()
    Endif    

    RestArea(aArea)
    RestArea(aAreaSF1)    

Return

/*/{Protheus.doc}fDataBrw()

Dados para selecao

@author Ovio Consultoria
@since 11/03/2021
@version P12 
@param 	
@return	
/*/ 

Static Function fCKBrowse()
        
    FreeObj(oTPane2)
    oTPane2 := TPanel():New(0,0,"",oTela,NIL,.T.,.F.,NIL,NIL,0,0,.T.,.F.)
	oTPane2:Align := CONTROL_ALIGN_ALLCLIENT

    oMrkBrw := FWMarkBrowse():New()
	oMrkBrw:oBrowse:SetEditCell(.T.)
	oMrkBrw:SetIgnoreARotina(.T.)
	oMrkBrw:SetFieldMark(cCpoMark)
	oMrkBrw:SetOwner(oTPane2)
	oMrkBrw:SetAlias(cArqTrb)
	oMrkBrw:SetMenuDef("")
    oMrkBrw:SetCustomMarkRec({|| fMarkUni() })
	oMrkBrw:SetAllMark({|| fMarkAll() })
	oMrkBrw:SetColumns(aColumns)
	oMrkBrw:SetTemporary(.T.)
    oMrkBrw:DisableDetails()
    oMrkBrw:DisableConfig()
    oMrkBrw:DisableReport()
    oMrkBrw:DisableFilter()
    oMrkBrw:DisableSaveConfig()
	oMrkBrw:Activate()
    
Return
    
/*/{Protheus.doc}LDtoCB

Converte Linha Digitavel para Código de Barras

@author Ovio Consultoria
@since 11/03/2021
@version P12 
@param 	
@return	
/*/ 

User Function LDtoCB(cLinDigi)

Local cCodBar := ""
Local cLinDig := Alltrim(cLinDigi)

If !VldCodBar(cLinDig)
     Return cCodBar
EndIf

If Len(cLinDig) == 47
     cCodBar := SubStr(cLinDig,1,4)+ SubStr(cLinDig,33,15)+ SubStr(cLinDig,5,5)+ SubStr(cLinDig,11,10)+ SubStr(cLinDig,22,10)
EndIf

If !VldCodBar(cCodBar)
     cCodBar := ""
EndIf

Return cCodBar


/*/{Protheus.doc} CBtoLD
Converter Codigo de Barras numerico para Linha Digitavel
@author Ovio Consultoria
@since 11/03/2021
@version V.01
@type function
/*/

User Function CBtoLD(cCodBar)

Local cCampo1 := ""
Local cCampo2 := ""
Local cCampo3 := ""
Local ccampo4 := ""
Local ccampo5 := ""
Local cDigita := Space( TamSx3("E2_LINDIG")[1] ) 

If Len(Alltrim(cCodBar))==44
	cCampo1 := substr(cCodBar,01,04) + substr(cCodBar,20,01)+substr(cCodBar,21,04)
	cCampo2 := substr(cCodBar,25,05) + substr(cCodBar,30,05)
	cCampo3 := substr(cCodBar,35,05) + substr(cCodBar,40,05)
	ccampo4 := substr(cCodBar,05,01)
	ccampo5 := substr(cCodBar,06,14)	// Vencimento + Valor
	
	cDigita :=	cCampo1 + Modulo10(cCampo1) + ;
				cCampo2 + Modulo10(cCampo2) + ;
				cCampo3 + Modulo10(cCampo3) + ;
				cCampo4 + ;
				cCampo5
Endif			
			
Return(cDigita)

/*/{Protheus.doc} fCompTit
Gravar Linha Digitavel ou Codigo de Barras na Temporaria
@author Ovio Consultoria
@since 11/03/2021
@version V.01
@type function
/*/

Static Function fCompTit()
Local nI        := 1
Local cCodLido	:= ""		
Local __aRegs	:= {}
Local __nProc   := 0

If Valtype(oMrkBrw:OBROWSE:OMARK:OBROWSE:AVISIBLEREG)=="A"
	__aRegs	:= oMrkBrw:OBROWSE:OMARK:OBROWSE:AVISIBLEREG 
	__nProc := Len(__aRegs)
Endif

If MsgYesNo("Confirma a leitura do codigo de barras para os Titulos selecionados ?", "Atenção")
	For nI := 1 To Len(__aRegs)
		(oMrkBrw:Alias())->( DbGoTo(__aRegs[nI]) )
		If ( oMrkBrw:IsMark() ) // Transmite apenas as notas selecionadas
			cCodLido := fReadBar()
			If !Empty(cCodLido)
				Reclock((oMrkBrw:Alias()),.F.)
				(oMrkBrw:Alias())->E2_LINDIG := iif(nRadio2==1,u_CBtoLD(cCodLido),cCodLido )
				(oMrkBrw:Alias())->E2_CODBAR := iif(nRadio2==1,cCodLido,u_LDtoCB(cCodLido) )
				MsUnlock()
			Endif	
		Endif
	Next
EndIf	

oMrkBrw:Refresh(.T.)

Return

/*/{Protheus.doc} fReadBar
Ler Barras
@author Ovio Consultoria
@since 11/03/2021
@version V.01
@type function
/*/

Static Function fReadBar
    
	Local LRET			:= .T.
	Local oFornecedor	:= Nil
	Local oTitulo		:= Nil
	Local oVencimento   := Nil
	Local oValor  		:= Nil
	Local cFornecedor	:= ""   
	Local cTitulo		:= ""
	Local cVencimento	:= ""
	Local cValor		:= ""
	Local _CLEITURA		:= Space(48)

	DEFINE FONT oFnt NAME "Arial" SIZE 0, -15 BOLD
	
	dbSelectArea("SA2")
	dbSetOrder(1)
	dbSeek( xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA )
	
	cFornecedor := Alltrim( SA2->A2_NREDUZ )
	cTitulo		:= SF1->F1_SERIE+" - "+SF1->F1_DOC+" - "+(oMrkBrw:Alias())->E2_PARCELA
	cVencimento := DTOC((oMrkBrw:Alias())->E2_VENCREA)
	cValor	    := Transform((oMrkBrw:Alias())->E2_VALOR , "@E 99,999,999.99")
		
	DEFINE MSDIALOG oDlg FROM 50,100 TO 475,950 TITLE "Leitura boleto bancario" Of oMainWnd PIXEL STYLE DS_MODALFRAME STATUS
	
	@ 041, 005 SAY "Fornecedor : " OF oDlg FONT oFnt COLOR CLR_BLUE Pixel SIZE 080,012
	@ 040, 078 MSGET oFornecedor VAR cFornecedor OF oDlg PICTURE "@!" When .F. SIZE 140,012 FONT oFnt PIXEL
	
	@ 061, 005 SAY "Pref/Numero/Parc.: " OF oDlg FONT oFnt COLOR CLR_BLUE Pixel SIZE 080,012
	@ 060, 078 MSGET oTitulo VAR cTitulo OF oDlg PICTURE "@!" When .F. SIZE 140,012 FONT oFnt PIXEL
	
	@ 081, 005 SAY "Vencimento: " OF oDlg FONT oFnt COLOR CLR_BLUE Pixel SIZE 080,012
	@ 080, 078 MSGET oVencimento VAR cVencimento OF oDlg PICTURE "@!" When .F. SIZE 80,012 FONT oFnt PIXEL
	
	@ 101, 005 SAY "Valor: " OF oDlg FONT oFnt COLOR CLR_BLUE Pixel SIZE 080,012
	@ 100, 078 MSGET oValor VAR cValor OF oDlg When .F. SIZE 080,012 FONT oFnt PIXEL
		
	@ 130, 005 TO  180, 423   LABEL " Insira ou passe o boleto pelo leitor "  PIXEL OF oDlg
				
	@ 140, 078 SAY OemToAnsi("||||||||||   |||||||||||||||  |||||||||||||||||||||||||    |||   |||||||||||||||||||   |||||||||||  |||||||||||||  ||||||||||||  |||||||||||     ||||||||||||||   ||||||||||||      ||||     ||||||||||||||||     |||||||||||  |||||||||||||") OF oDlg FONT oFnt COLOR CLR_GRAY Pixel SIZE 280,008
	@ 157, 078 MSGET _oGet VAR _cLeitura OF oDlg PICTURE "@E" When .T. SIZE 285,010 FONT oFnt PIXEL
	
	_oGet:bLostFocus := { || iIf( Type("lUsaLeitor") == "L" .AND. lUsaLeitor, LeitorFoco(nHdlLeitor, .T.), Nil ) }
	_oGet:bGotFocus  := { || iIf( Type("lUsaLeitor") == "L" .AND. lUsaLeitor, LeitorFoco(nHdlLeitor, .T.), Nil ) }
	 oDlg:bGotFocus  := { || _oGet:SetFocus() }
	
	_oGet:SetFocus()	
	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar( oDlg , { || lRet:= .T. , oDlg:End() } ,{ || lRet := .F. , oDlg:End()} )
	
	If !lRet
		_cLeitura := Space(48)
	Endif

Return _cLeitura


/*/{Protheus.doc} fSalvar
Gravr as Informações no SE2
@author Ovio Consultoria
@since 11/03/2021
@version V.01
@type function
/*/

Static Function fSalvar(lDupl)
Local __cAlias := ""
Local __cMark  := ""

If lDupl
    
	__cAlias := oMrkBrw:Alias()
    __cMark  := oMrkBrw:Mark()
    If nRadio1 == 4
        (__cAlias)->(dbGotop()) 
        While (__cAlias)->(!Eof()) 
            If  !Empty((__cAlias)->&(cCpoMark) )
                DbSelectArea("SE2")
                DbSetOrder(6)
                If DbSeek(xFilial("SE2") + SF1->F1_FORNECE + SF1->F1_LOJA + SF1->F1_PREFIXO + SF1->F1_DOC + Padr((__cAlias)->E2_PARCELA,TamSx3("E2_PARCELA")[1]) + SF1->F1_TIPO )
                    RecLock("SE2",.F.)
                    SE2->E2_FORMPAG:=iif(Substr((__cAlias)->E2_LINDIG,1,3)==cBcoPad,"30","31")
                    SE2->E2_PORTADO:=cBcoPad
                    SE2->E2_LINDIG := (__cAlias)->E2_LINDIG
                    SE2->E2_CODBAR := (__cAlias)->E2_CODBAR
                    SE2->E2_HIST   := cObs
                    SE2->E2_XMODELO:= iif(nRadio3==1,"Fiscal",iif(nRadio3==2,"Cartão de Credito",iif(nRadio3==3,"Reembolso","Nota Debito")))
					MsUnLock()
                EndIf
				Reclock("SF1",.F.)
    			SF1->F1_XMODELO := iif(nRadio3==1,"Fiscal",iif(nRadio3==2,"Cartão de Credito",iif(nRadio3==3,"Reembolso","Nota Debito")))
    			MsUnlock()        
            Else
				DbSelectArea("SE2")
                DbSetOrder(6)
                If DbSeek(xFilial("SE2") + SF1->F1_FORNECE + SF1->F1_LOJA + SF1->F1_PREFIXO + SF1->F1_DOC + Padr((__cAlias)->E2_PARCELA,TamSx3("E2_PARCELA")[1]) + SF1->F1_TIPO )
                    RecLock("SE2",.F.)
                    SE2->E2_HIST   := cObs
	                MsUnLock()
                EndIf
			Endif    
            (__cAlias)->(DbSkip())  
        End
    Else
        dbSelectArea((__cAlias))
        dbSetOrder(1)
        (__cAlias)->(dbGotop())
        If dbSeek(__cMark)
            DbSelectArea("SE2")
            DbSetOrder(6)
            If DbSeek(xFilial("SE2") + SF1->F1_FORNECE + SF1->F1_LOJA + SF1->F1_PREFIXO + SF1->F1_DOC )
                While SE2->(!Eof()) .And. SE2->E2_FORNECE + SE2->E2_LOJA + SE2->E2_PREFIXO + SE2->E2_NUM==;
                                        SF1->F1_FORNECE + SF1->F1_LOJA + SF1->F1_PREFIXO + SF1->F1_DOC
                    
                    Reclock("SE2",.F.)
                    If nRadio1==3
                        SE2->E2_FORMPAG := "45"
                        SE2->E2_XCHVPIX := (__cAlias)->F72_CHVPIX
                        SE2->E2_HIST    := cObs
                    	SE2->E2_XMODELO	:= iif(nRadio3==1,"Fiscal",iif(nRadio3==2,"Cartão de Credito",iif(nRadio3==3,"Reembolso","Nota Debito")))
					Else
                        SE2->E2_PORTADO	:=cBcoPad
                        SE2->E2_FORMPAG	:=iif(nRadio1==1,"03",iif(nRadio1==2,"41",""))
                        SE2->E2_FORBCO 	:= (__cAlias)->FIL_BANCO 
                        SE2->E2_FORAGE 	:= (__cAlias)->FIL_AGENCI
                        SE2->E2_FAGEDV 	:= (__cAlias)->FIL_DVAGE 
                        SE2->E2_FORCTA 	:= (__cAlias)->FIL_CONTA 
                        SE2->E2_FCTADV 	:= (__cAlias)->FIL_DVCTA 
                        SE2->E2_MODSPB 	:= "1"
                        SE2->E2_HIST   	:= cObs
						SE2->E2_XMODELO	:= iif(nRadio3==1,"Fiscal",iif(nRadio3==2,"Cartão de Credito",iif(nRadio3==3,"Reembolso","Nota Debito")))
                    Endif    
                    MsUnLock()
                SE2->(dbSkip())
                End
				Reclock("SF1",.F.)
    			SF1->F1_XMODELO := iif(nRadio3==1,"Fiscal",iif(nRadio3==2,"Cartão de Credito",iif(nRadio3==3,"Reembolso","Nota Debito")))
    			MsUnlock()                                          
            Endif
        Else
			DbSelectArea("SE2")
            DbSetOrder(6)
            If DbSeek(xFilial("SE2") + SF1->F1_FORNECE + SF1->F1_LOJA + SF1->F1_PREFIXO + SF1->F1_DOC )
                While SE2->(!Eof()) .And. SE2->E2_FORNECE + SE2->E2_LOJA + SE2->E2_PREFIXO + SE2->E2_NUM==;
                                        SF1->F1_FORNECE + SF1->F1_LOJA + SF1->F1_PREFIXO + SF1->F1_DOC
                    
                    Reclock("SE2",.F.)
                    SE2->E2_HIST := cObs
                    MsUnLock()
                    SE2->(dbSkip())
                End                                          
            Endif
            Aviso("Atenção","Selecao de registro não realizada.",{"Ok"})
        Endif
    Endif 
	  
Else    
    Reclock("SF1",.F.)
    SF1->F1_XMODELO := iif(nRadio3==1,"Fiscal",iif(nRadio3==2,"Cartão de Credito",iif(nRadio3==3,"Reembolso","Nota Debito")))
    MsUnlock()
Endif    

oTela:End()

Return

/*/{Protheus.doc} fCadFor()
Gravr as Informações no SE2
@author Ovio Consultoria
@since 11/03/2021
@version V.01
@type function
/*/
Static Function fCadFor()
Local aAreaSA2 := SA2->(GetArea())
Local nAviso   := 0

dbSelectArea("SA2")
dbSetOrder(1)
dbSeek(xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA )

nAviso := Aviso("Atenção","Selecione o cadastro desejado: ",{"PIX","BANCOS"})

RegToMemory("SA2", .F., .F. )
iF nAviso==1
    nOpc := 4
    INCLUI := .F.
    ALTERA := .T.
    FA885ChPix()
Else
    ACOLSAUX:={}
    XFtBanco("SA2",SA2->(RecNo()),4)
Endif

RestArea(aAreaSA2)

Return

//*********************************************************************

Static Function XFtBanco( cAlias, nReg, nOpc, APreCols)

Local aArea        := GetArea()
Local aPosObj      := {}
Local aObjects     := {}
Local aSize        := MsAdvSize( .F. )
Local aGet         := {}
Local aTravas      := {}
Local aEntidade    := {}
Local aChave       := {}
//Backup aCols and aHeader
Local aColsBkp     := If(Type("aCols") != "A",{},aCols)
Local aHeaderBkp   := If(Type("aHeader") != "A",{},aHeader)

Local cNomeFor     := ""
Local cCnpjFor     := ""
Local cEntidade    := ""
Local cUnico       := ""

Local lGravou      := .F.
Local lTravas      := .T.

Local nCntFor      := 0
Local nOpcA        := 0
Local nScan        := 0

Local oDlg

Local oGet
Local oGet2

Local cSeek     := ""
Local oGet3		:= NIL
Local oGet4		:= NIL

PRIVATE oGetD
PRIVATE aRecFIL     := {}

DEFAULT aPreCols   := {}
DEFAULT nOpc       := 2
DEFAULT cAlias	   := "SA2"

aCols	 := If(Type("aColsFBco") != "A",{},aColsFBco)
aHeader  := If(Type("aHeadFBco") != "A",{},aHeadFBco)
lConfBco := If(Type("lConfBco") != "L",.F.,lConfBco) // Confirmacao da Dialog de amarracao fornecedor x bancos (Localizados) - FIL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona a entidade                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Inclui
	nOpc := 3
ElseIf Altera
	nOpc := 4
Endif

cEntidade := cAlias
dbSelectArea( cEntidade )
MsGoto( nReg )

cCodFor	:= M->A2_COD
cCodLoj	:= M->A2_LOJA
cNomeFor	:= M->A2_NOME
cCnpjFor	:= M->A2_CGC

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader e aCols                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("FIL")
cSeek  := xFilial( "FIL" ) + cCodFor + cCodLoj
MntGet( "FIL", cSeek )

If ( lTravas )
	IF nOpc = 3
		INCLUI := .T.
	EndIf
	
	AAdd( aObjects, { 100,  44, .T., .F. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 2 }
	aPosObj := MsObjSize( aInfo, aObjects )
	
	DEFINE MSDIALOG oDlg TITLE 'Cadastros de Bancos - Fornecedores' FROM aSize[7],00 TO aSize[6],aSize[5] OF oMainWnd PIXEL
	
	@ 019,006 SAY OemToAnsi("Codigo") SIZE 040,009 OF oDlg PIXEL //
	@ 032,005 GET oGet VAR cCodFor SIZE 030,009 OF oDlg PIXEL WHEN .F.
	
	@ 019,056 SAY OemToAnsi("Loja") SIZE 040,009 OF oDlg PIXEL //
	@ 032,055 GET oGet2 VAR cCodLoj SIZE 010,009 OF oDlg PIXEL WHEN .F.
	
	@ 019,076 SAY OemToAnsi("Nome") SIZE 040,009 OF oDlg PIXEL //
	@ 032,075 GET oGet3 VAR cNomeFor SIZE 220,009 OF oDlg PIXEL WHEN .F.
	If(lLGPD,OfuscaLGPD(oGet3,"A2_NOME"),.F.)
	
	@ 019,296 SAY OemToAnsi("CNPJ/CPF") SIZE 040,009 OF oDlg PIXEL //
	@ 032,295 GET oGet4 VAR cCnpjFor SIZE 120,009 OF oDlg PIXEL WHEN .F.
	If(lLGPD,OfuscaLGPD(oGet4,"A2_CGC"),.F.)
	
	oGetd:=MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4], nOpc,"FtBcoLOK","FtBcoTOK",,.T.,NIL,NIL,NIL,500)
		
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,lConfBco:=.T.,If(oGetd:TudoOk(),oDlg:End(),(nOpcA:=0,lConfBco:=.F.))},{||oDlg:End(),lConfBco:=.F.})
	
	If ( nOpcA == 1 )
		lGravou := FtGrvSA2(aCols)
	EndIf
EndIf
RestArea( aArea )

//Restore aCols and aHeader
aColsFBco := aCols	
aHeadFBco := aHeader

aCols	:= aColsBkp    
aHeader := aHeaderBkp  

Return(lGravou)

//************************************************************
Static Function MntGet(cAlias,cSeek)

Local aAreaAnt := GetArea()
Local aAreaSX3 := SX3->( GetArea() )
Local nx 		 := 0
Local nUsado 	 := 0
Local nPosTip	 := GDFieldPos( "FIL_TIPO" )
Local nPosBco	 := GDFieldPos( "FIL_BANCO" )
Local nPosAge	 := GDFieldPos( "FIL_AGENCI" )
Local nPosCon	 := GDFieldPos( "FIL_CONTA" )
Local cCpoFIL	 := ""
Local nQtdCpos := 0
Local nCtnCpo	 := 0
Local aAux		 := {}
Local aMT020FIL	:= {}
Default cAlias := "FIL"

If cPaisLoc == "RUS"
	cCpoFIL := "FIL_BANCO|FIL_CONTA|FIL_ACNAME|FIL_MOEDA|FIL_AGENCI|FIL_BKNAME|FIL_CORRAC|FIL_CITY|FIL_SWIFT|FIL_NMECOR|FIL_REASON|FIL_FOREIG|FIL_CLOSED|FIL_TIPO"
	nQtdCpos := 14
Else
	cCpoFIL := "FIL_BANCO|FIL_AGENCI|FIL_CONTA|FIL_TIPO|FIL_DETRAC|FIL_MOEDA|FIL_DVAGE|FIL_DVCTA|FIL_TIPCTA|FIL_MOVCTO"
	nQtdCpos := 10
Endif

//Adiciona campos da tabela FIL 
If ExistBlock("MT020FIL")
	aMT020FIL := ExecBlock("MT020FIL", .F.,.F.)
	If ValType(aMT020FIL) == 'A' .And. Len("aMT020FIL") >= 2
		cCpoFIL	+= aMT020FIL[1]
		nQtdCpos 	+= aMT020FIL[2]
	EndIf
EndIf

dbSelectArea( cAlias )
FIL->( dbSetOrder(1) )
If FIL->( msSeek(cSeek) )
	Altera := .T.
Endif	

If Altera .OR. (!Altera .and. !Inclui)
	aHeader := {}		
		
	dbSelectArea("SX3")
	SX3->( dbSetOrder(1) )
	SX3->( msSeek(cAlias) )
	
	nUsado := 0
	While SX3->( !EOF() ) .And. SX3->X3_ARQUIVO == cAlias
		If nUsado < nQtdCpos
			If SX3->X3_USADO != " " .And. Alltrim(SX3->X3_CAMPO) $ cCpoFIL
				nUsado := nUsado + 1
				ctitulo := TRIM(X3Titulo())
				ntamanho := SX3->X3_TAMANHO
				AADD( aHeader, { ctitulo, SX3->X3_CAMPO, SX3->X3_PICTURE,;
				      NTAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID,;
				      SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_VISUAL } )
			EndIf
		Endif
		SX3->( dbSkip() )
	EndDo
	
	If Empty(aCols)		
		dbSelectArea( cAlias )
		FIL->( dbSetOrder(1) )
		If FIL->( msSeek(cSeek) )
			While FIL->( !EOF() ) .And. cSeek == FIL_FILIAL+FIL_FORNEC+FIL_LOJA
				If aScan( aCols, {|x| x[1]+x[2]+x[4] = FIL_BANCO+FIL_AGENCI+FIL_CONTA} ) == 0
					aAux := {}
					For nX:= 1 To Len(aHeader)
						If cPaisLoc == "RUS" .And. aHeader[nX][2] == "FIL_CORRAC"
							aAdd (aAux, Posicione("F45",1,xFilial("F45")+FIL->FIL_AGENCI,"F45_CORRAC") )
						Else
							aAdd (aAux, FIL->(FieldGet(FieldPos(aHeader[nX][2]))) )
						Endif
					Next nX 
					aAdd( aAux, .F. )				
			    	aAdd( Acols, aAux )
			    	aAdd( aColsAux, FIL->(RECNO()) )
				Endif
				FIL->( dbSkip() )
			EndDo
		Endif
	Endif
		
ElseIf Inclui
	aHeader := {}
			
	dbSelectArea("SX3")
	SX3->( dbSetOrder( 1 ) )
	SX3->( msSeek(cAlias) )
	
	nUsado := 0		      
	While SX3->( !EOF() ) .And. SX3->X3_ARQUIVO == cAlias
		If nUsado < nQtdCpos
			If SX3->X3_USADO != " " .And. Alltrim(SX3->X3_CAMPO) $ cCpoFIL
				nUsado := nUsado + 1
				ctitulo := TRIM(X3Titulo())
				ntamanho := SX3->X3_TAMANHO
				AADD( aHeader, { ctitulo, SX3->X3_CAMPO, SX3->X3_PICTURE,;
				      NTAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID,;
				      SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_VISUAL } )
			EndIf
		Endif
		SX3->( dbSkip() )
	EndDo
	
	
	aAux := {}
				
	For nX:= 1 To Len(aHeader)
		aAdd (aAux, CriaVar(aHeader[nX][2]))
	Next nX

	If Empty(aCols)
		aAdd( aAux, .F. )
		aAdd( aColsAux, FIL->(RECNO()) )
		AADD( Acols, aAux )
	Endif
Endif

SX3->( RestArea( aAreaSX3 ) )
RestArea( aAreaAnt )
Return Nil





//***********************************************************************

Static Function XFtBcoLOK()

Local lRet    := .T.
Local nPosCod := GDFieldPos( "FIL_BANCO" )
Local nPosAge := GDFieldPos( "FIL_AGENCI" )
Local nPosCon  := GDFieldPos( "FIL_CONTA" )
Local nPosTip := GDFieldPos( "FIL_TIPO" )
Local nPosForeig := GDFieldPos( "FIL_FOREIG" )
Local nPosACType := GDFieldPos( "FIL_TIPO" )
Local nLoop   := 0
Local lPrinc  := .T.

If !GDDeleted()
	
	If Empty( GDFieldGet( "FIL_BANCO" ) )
		Help(" ",1,"MA020NOBANK")//It is mandatory to fill the field Bank code.
		lRet := .F.
	EndIf		

	If cPaisLoc == "RUS"	
		If lRet .And.  Empty( GDFieldGet( "FIL_CONTA" ) )
			Help(" ",1,"MA020NOACCOUNT")//It is mandatory to fill the field Account number.
			lRet := .F.
		EndIf
		
		If GDFieldGet( "FIL_FOREIG" ) == '2'	
			If lRet .And. Empty( GDFieldGet( "FIL_AGENCI" ) )
				Help(" ",1,"MA020NOAGENCY")//It is mandatory to fill the field Agency/BIK code.
				lRet := .F.
			EndIf
		Endif
	Endif
	
	If lRet
		For nLoop := 1 To Len( aCols )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se existe banco/agencia/conta duplicados                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nLoop <> n .And. !GDDeleted( nLoop )
				If aCols[ nLoop, nPosCod ] == GDFieldGet( "FIL_BANCO" ) .And. aCols[ nLoop, nPosAge ] == GDFieldGet( "FIL_AGENCI" );
					.And. aCols[ nLoop, nPosCon ] == GDFieldGet( "FIL_CONTA" )
					lRet := .F.
					Help( "", 1, "BCCONDUP","","BCCONDUP",1,0 )
				EndIf
				//Verify if there is another accout already set as Main
				If cPaisLoc == "RUS"
					If GDFieldGet( "FIL_TIPO" ) == "1"
						If aCols[ nLoop, nPosACType ] == "1"
							Help(" ",1,"MA020MAIN")//This supplier has already a Main Account!	
							lRet := .F.
						Endif
					Endif
				Endif
			EndIf
		Next nLoop
	EndIf
	If cPaisLoc == "RUS"
		If lRet
			If GDFieldGet( "FIL_TIPO" ) == "1"
				If !Empty(GDFieldGet( "FIL_CLOSED" )) .And. GDFieldGet( "FIL_CLOSED" ) == "1"
					Help(" ",1,"MA020BLKMAIN") //It is not possible to block a Main Account or set as main a blocked account.
					lRet := .F.
				Endif
			Endif
		Endif
	Endif
EndIf

Return( lRet )

//****************************************************************
Static Function XFtBcoTOK()

Local lRet	:= .T.
Local nPosTip := GDFieldPos( "FIL_TIPO" )
Local nLoop   := 0
Local nPrinc  := 0
Local nLinDel := 0 // Quantidade de linhas deletadas

For nLoop := 1 To Len( aCols )
	If !GDDeleted( nLoop )
		lRet:= FtBcoLOK()
		If !lRet
			Exit
		Endif
		
		If aCols[ nLoop, nPosTip ] == "1"
			nPrinc:=nPrinc+1
		Endif
	Else
		nLinDel++
	EndIf
Next nLoop
IF nPrinc > 1 
	lRet := .F.
	Help(" ",1, "BCCONTIPO","","BCCONTIPO"+CRLF+"STR0043",1,0 )
ElseIF nPrinc == 0 .And. !( nLinDel == Len( aCols ) )
	lRet := .F.
	Help(" ",1, "BCCONTIPO2","","BCCONTIPO2"+CRLF+"STR0042",1,0 )
EndIF

Return( lRet )

//************************************************************************

Static Function FtGrvSA2(aCols)
Local nLoop	:= 0
Local lGravou := .F.
Local nPosBanco	:= aScan(aHeader,{|x| AllTrim(x[2]) == "FIL_BANCO"	})
Local nPosAgenc	:= aScan(aHeader,{|x| AllTrim(x[2]) == "FIL_AGENCI"	})
Local nPosConta	:= aScan(aHeader,{|x| AllTrim(x[2]) == "FIL_CONTA"	})
Local nPosDVAge	:= aScan(aHeader,{|x| AllTrim(x[2]) == "FIL_DVAGE"	})
Local nPosDVCta	:= aScan(aHeader,{|x| AllTrim(x[2]) == "FIL_DVCTA"	})
Local nPosTpCta	:= aScan(aHeader,{|x| AllTrim(x[2]) == "FIL_TIPCTA"	})
Local nPosTipo	:= aScan(aHeader,{|x| AllTrim(x[2]) == "FIL_TIPO"})

For nLoop := 1 To Len( aCols )
	If !Empty( AllTrim(aCols[nLoop][nPosBanco]) ) .AND. (cPaisLoc == "RUS" .Or. !Empty( AllTrim(aCols[nLoop][nPosAgenc]) ));
   		.AND. !Empty( AllTrim(aCols[nLoop][nPosConta]) )

		If !GDDeleted( nLoop )
			dbSelectArea("FIL")
			dbSetOrder(1)//FIL_FILIAL, FIL_FORNEC, FIL_LOJA, FIL_TIPO, FIL_BANCO, FIL_AGENCI, FIL_CONTA, R_E_C_N_O_, D_E_L_E_T_
			If dbSeek(xFilial("FIL")+SF1->F1_FORNECE+SF1->F1_LOJA+aCols[nLoop][nPosTipo]+aCols[nLoop][nPosBanco]+aCols[nLoop][nPosAgenc]+aCols[nLoop][nPosConta])
				Reclock("FIL",.F.)
			Else
				Reclock("FIL",.T.)
			Endif
			FIL->FIL_FILIAL := xFilial("FIL")
			FIL->FIL_FORNEC := SF1->F1_FORNECE
			FIL->FIL_LOJA   := SF1->F1_LOJA	
			FIL->FIL_BANCO 	:= aCols[nLoop][nPosBanco]
			FIL->FIL_AGENCI	:= aCols[nLoop][nPosAgenc]
			FIL->FIL_CONTA	:= aCols[nLoop][nPosConta]
			FIL->FIL_DVAGE	:= aCols[nLoop][nPosDVAge]
			FIL->FIL_DVCTA	:= aCols[nLoop][nPosDVCta]
			FIL->FIL_TIPCTA	:= aCols[nLoop][nPosTpCta]
			FIL->FIL_TIPO	:= aCols[nLoop][nPosTipo]
			FIL->FIL_MOEDA  := 1
			lGravou := .T.
			MsUnlock()
		Else
			dbSelectArea("FIL")
			dbSetOrder(1)//FIL_FILIAL, FIL_FORNEC, FIL_LOJA, FIL_TIPO, FIL_BANCO, FIL_AGENCI, FIL_CONTA, R_E_C_N_O_, D_E_L_E_T_
			If dbSeek(xFilial("FIL")+SF1->F1_FORNECE+SF1->F1_LOJA+aCols[nLoop][nPosTipo]+aCols[nLoop][nPosBanco]+aCols[nLoop][nPosAgenc]+aCols[nLoop][nPosConta])
				Reclock("FIL",.F.)
				dbDelete()
				MsUnLock()
			Endif
		Endif
	Endif
Next

fDataBrw()
oMrkBrw:Refresh()

Return lGravou

//****************************************************************

Static Function XFtBcoGrv(nOpc)

Local cSeekFIL  := M->A2_COD+M->A2_LOJA
Local lGravou   := .F.

Local nLoop     := 0
Local nLoop1	  := 0
Local nLoop2    := 0
Local nPosTip	:= 0
Local nPosBco	:= 0
Local nPosAge	:= 0
Local nPosCon	:= 0
Local cQry		 := ""
Local nLn := 0
Local aColsBkp     := If(Type("aCols") != "A",{},aCols)
Local aHeaderBkp   := If(Type("aHeader") != "A",{},aHeader)

aCols	:= If(Type("aColsFBco") != "A",{},aColsFBco)
aHeader := If(Type("aHeadFBco") != "A",{},aHeadFBco)

nPosTip	 := GDFieldPos( "FIL_TIPO" )
nPosBco	 := GDFieldPos( "FIL_BANCO" )
nPosAge	 := GDFieldPos( "FIL_AGENCI" )
nPosCon	 := GDFieldPos( "FIL_CONTA" )

DbSelectArea("FIL")
FIL->(DbSetOrder(1))
	
If !Empty(cSeekFIL) .And. nPosTip > 0 .And. nPosBco > 0 .And. nPosAge > 0 .And. nPosCon > 0
	If nOpc <> 3
		If !Empty(aCols)
			If Select("FILSA2") > 0
				FILSA2->(DbCloseArea())
			Endif
			
			cQry := " SELECT Count(*) AS LINHAS,
			cQry += "       R_E_C_N_O_ AS RECNO
			cQry += " FROM " + RetSqlName("FIL")
			cQry += " WHERE  D_E_L_E_T_ = ''
			cQry += "        AND FIL_FORNEC = '" + M->A2_COD + "'"
			cQry += "        AND FIL_LOJA = '" + M->A2_LOJA + "'"
			cQry += "        AND FIL_FILIAL = '" + xFilial("FIL") + "'"
			cQry += " GROUP  BY R_E_C_N_O_ "
			cQry += " ORDER BY R_E_C_N_O_ "
			
			cQry := ChangeQuery(cQry)
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"FILSA2",.F.,.T.)
			
			DbSelectArea("FILSA2")
			If FILSA2->(!EOF())
				nLoop := FILSA2->LINHAS
			Endif
			
			If nLoop == Len(aCols)
				While FILSA2->(!EOF())
					nLoop1++
					FIL->(DbGoto(FILSA2->RECNO))
					If !GDDeleted( nLoop1 )
						If RecLock("FIL",.F.)
							For nLoop2 := 1 To Len( aHeader )
								If !(AllTrim(aHeader[nLoop2,2]) $ "FIL->FIL_FILIAL|FIL->FIL_FORNEC|FIL->FIL_LOJA")
									FIL->(FieldPut(FieldPos(aHeader[nLoop2,2]),aCols[nLoop1,nLoop2]))
								EndIf
							Next nLoop2
							FIL->(MsUnlock())
						Endif
					Else
						If RecLock("FIL",.F.)
							FIL->(DbDelete())
							FIL->(MsUnlock())
						Endif
					Endif
					FILSA2->(DbSkip())
				Enddo
			Elseif nLoop > Len(aCols)
				While FILSA2->(!EOF())
					nLoop1++
					
					If nLoop1 > Len(aCols)
						FIL->(DbGoto(FILSA2->RECNO))
						If RecLock("FIL",.F.)
							FIL->(DbDelete())
							FIL->(MsUnlock())
						Endif
					Else
						FIL->(DbGoto(FILSA2->RECNO))
						If !GDDeleted( nLoop1 )
							If RecLock("FIL",.F.)
								For nLoop2 := 1 To Len( aHeader )
									If !(AllTrim(aHeader[nLoop2,2]) $ "FIL->FIL_FILIAL|FIL->FIL_FORNEC|FIL->FIL_LOJA")
										FIL->(FieldPut(FieldPos(aHeader[nLoop2,2]),aCols[nLoop1,nLoop2]))
									EndIf
								Next nLoop2
								FIL->(MsUnlock())
							Endif
						Else
							If RecLock("FIL",.F.)
								FIL->(DbDelete())
								FIL->(MsUnlock())
							Endif
						Endif
					Endif
					
					FILSA2->(DbSkip())
				Enddo
			Elseif nLoop < Len(aCols)
				While FILSA2->(!EOF())
					nLoop1++
					nLn := Ascan(aColsAux, FILSA2->RECNO)
					FIL->(DbGoto(FILSA2->RECNO))
					If !GDDeleted( nLn )
						If RecLock("FIL",.F.)
							For nLoop2 := 1 To Len( aHeader )
								If !(AllTrim(aHeader[nLoop2,2]) $ "FIL->FIL_FILIAL|FIL->FIL_FORNEC|FIL->FIL_LOJA")
									FIL->(FieldPut(FieldPos(aHeader[nLoop2,2]),aCols[nLn,nLoop2]))
								EndIf
							Next nLoop2
							FIL->(MsUnlock())
						Endif
					Else
						If RecLock("FIL",.F.)
							FIL->(DbDelete())
							FIL->(MsUnlock())
						Endif
					Endif
					
					FILSA2->(DbSkip())
				Enddo
								
				If nLoop1 < Len(aCols)
					nLoop1++
					For nLoop := nLoop1 To Len(aCols)
						If !GDDeleted( nLoop )
							If RecLock("FIL",.T.)
								FIL->FIL_FILIAL	:= xFilial( "FIL" )
								FIL->FIL_FORNEC	:= M->A2_COD
								FIL->FIL_LOJA	:= M->A2_LOJA
								For nLoop2 := 1 To Len( aHeader )
									If !(AllTrim(aHeader[nLoop2,2]) $ "FIL->FIL_FILIAL|FIL->FIL_FORNEC|FIL->FIL_LOJA")
										FIL->(FieldPut(FieldPos(aHeader[nLoop2,2]),aCols[nLoop,nLoop2]))
									EndIf
								Next nLoop2
								FIL->(MsUnlock())
							Endif
						Endif
					Next nLoop
				Endif	
			Endif
			
			FILSA2->(DbCloseArea())
		Endif
	Else
		If FIL->(DbSeek(xFilial("FIL")+ cSeekFIL ))
			While FIL->(!EOF())
				If FIL->FIL_FILIAL == xFilial("FIL") .And. FIL->FIL_FORNEC == SA2->A2_COD .And. FIL->FIL_LOJA == SA2->A2_LOJA
					RecLock("FIL",.F.)
					FIL->(DbDelete())
					FIL->(MsUnLock())
				Endif
				FIL->(DbSkip())
			EndDo
		Endif
	Endif
Endif	
	
//Restore aCols and aHeader
aColsFBco := aCols	
aHeadFBco := aHeader

aCols	:= aColsBkp    
aHeader := aHeaderBkp 
aColsAux:= {}

Return( lGravou )
