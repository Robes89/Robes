#Include "Totvs.ch"
#Include "Topconn.ch"
/*/{Protheus.doc}''
''
@author Sergio Celestino
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/
User Function EXPORXML()

Local  oTela   := Nil
Local  cTitulo := "Exportar Xmls NFE"
Local  oFont1  := TFont():New("Arial",12,16,,.T.,,,,.T.,.F.)

Private lCheck  := .F.

Private dDataIni  := dDataBase
Private dDataFim  := dDataBase
Private cNotaIni  := Space(TamSX3("F1_DOC")[1])
Private cNotaFim  := Replicate("Z",TamSX3("F1_DOC")[1])
Private cFornIni  := Space(TamSX3("F1_FORNECE")[1])
Private cFornFim  := Replicate("Z",TamSX3("F1_FORNECE")[1])


DEFINE MSDIALOG oTela FROM 0, 0 To 350,500 Title cTitulo  Of GetWndDefault() PIXEL STYLE DS_MODALFRAME STATUS 
				
oTPane2 := TPanel():New(0,0,"",oTela,NIL,.T.,.F.,NIL,NIL,0,0,.T.,.F.)
oTPane2:Align := CONTROL_ALIGN_ALLCLIENT

oDataIni :=  TGet():New( 010  ,005 ,{|u| If(PCount()>0,dDataIni:=u,dDataIni )},oTPane2,050 ,011    ,/*cPict*/, /*bValid*/ ,0 /*nClrFore*/, /*nClrBack*/,  /*oFont*/ ,.F.          ,             ,.T.            ,             ,.F.          ,           ,.F.         ,.F.          , {||.T. }/*bChange*/ ,.F. /*lReadOnly*/, .F.               ,             , "dDataIni" , /*uParam25*/ , /*uParam26*/, /*uParam27*/, /*lHasButton*/, /*lNoButton*/, /*uParam30*/ ,"Emissão De: "     ,1  /*nLabelPos*/ ,   /*oLabelFont*/,/*nLabelColor*/ ,/*cPlaceHold*/ ,/*lPicturePriority*/ ,/*lFocSel*/ )
oDataFim :=  TGet():New( 040  ,005 ,{|u| If(PCount()>0,dDataFim:=u,dDataFim )},oTPane2,050 ,011    ,/*cPict*/, /*bValid*/ ,0 /*nClrFore*/, /*nClrBack*/,  /*oFont*/ ,.F.          ,             ,.T.            ,             ,.F.          ,           ,.F.         ,.F.          , {||.T. }/*bChange*/ ,.F. /*lReadOnly*/, .F.               ,             , "dDataFim" , /*uParam25*/ , /*uParam26*/, /*uParam27*/, /*lHasButton*/, /*lNoButton*/, /*uParam30*/ ,"Emissão Até: "    ,1  /*nLabelPos*/ ,   /*oLabelFont*/,/*nLabelColor*/ ,/*cPlaceHold*/ ,/*lPicturePriority*/ ,/*lFocSel*/ )
oNotaIni :=  TGet():New( 070  ,005 ,{|u| If(PCount()>0,cNotaIni:=u,cNotaIni )},oTPane2,050 ,011    ,/*cPict*/, /*bValid*/ ,0 /*nClrFore*/, /*nClrBack*/,  /*oFont*/ ,.F.          ,             ,.T.            ,             ,.F.          ,           ,.F.         ,.F.          , {||.T. }/*bChange*/ ,.F. /*lReadOnly*/, .F.               ,             , "cNotaIni" , /*uParam25*/ , /*uParam26*/, /*uParam27*/, /*lHasButton*/, /*lNoButton*/, /*uParam30*/ ,"Nota Fiscal De: " ,1  /*nLabelPos*/ ,   /*oLabelFont*/,/*nLabelColor*/ ,/*cPlaceHold*/ ,/*lPicturePriority*/ ,/*lFocSel*/ )
oNotaFim :=  TGet():New( 100  ,005 ,{|u| If(PCount()>0,cNotaFim:=u,cNotaFim )},oTPane2,050 ,011    ,/*cPict*/, /*bValid*/ ,0 /*nClrFore*/, /*nClrBack*/,  /*oFont*/ ,.F.          ,             ,.T.            ,             ,.F.          ,           ,.F.         ,.F.          , {||.T. }/*bChange*/ ,.F. /*lReadOnly*/, .F.               ,             , "cNotaFim" , /*uParam25*/ , /*uParam26*/, /*uParam27*/, /*lHasButton*/, /*lNoButton*/, /*uParam30*/ ,"Nota Fiscal Até:" ,1  /*nLabelPos*/ ,   /*oLabelFont*/,/*nLabelColor*/ ,/*cPlaceHold*/ ,/*lPicturePriority*/ ,/*lFocSel*/ )
				
oTPane4:= TPanel():New(0, 0, "", oTela, NIL, .T., .F., NIL, NIL,0 , 10 , .T., .F. )
oTPane4:Align:= CONTROL_ALIGN_BOTTOM
				
Activate MsDialog oTela Centered On Init EnchoiceBar(oTela , { || Processa( {|| fSalvar() } )  , oTela:End() },{|| oTela:End() } ) 

/*/{Protheus.doc}'fSalvar()'
''
@author Sergio Celestino
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/ 
Static Function fSalvar()
    Processa({|| fProcxml()})
Return

Static Function fProcxml()
Local _aFiles 	:= {}
Local aStruct	:= {}
Local nK		:= 1
Local cFolder	:= ""
Local cQry      := ""
Local nRecs     := 0
Local nExport   := 0

cFolder := cGetFile( '*.*|*.*' , 'Escolha a Pasta para salvar' , 1 ,  , .T. , nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY ,GETF_NETWORKDRIVE , GETF_RETDIRECTORY ) , .F.) 	

cQry := " SELECT SDS.* FROM "+RetSqlName("SDS")+" SDS "
cQry += " INNER JOIN "+RetSqlName("SF1")+" SF1 ON " 
cQry += " SDS.DS_FILIAL = SF1.F1_FILIAL AND SDS.DS_DOC=SF1.F1_DOC AND "
cQry += " SDS.DS_SERIE=SF1.F1_SERIE AND SDS.DS_FORNEC=SF1.F1_FORNECE AND "
cQry += " SDS.DS_LOJA=SF1.F1_LOJA AND SF1.D_E_L_E_T_= ' ' "
cQry += " WHERE "
cQry += " SF1.F1_DTDIGIT>='"+DtoS(dDataIni)+"' AND SF1.F1_DTDIGIT<='"+DtoS(dDataFim)+"' AND "
cQry += " SDS.DS_DOC>='"+cNotaIni+"' AND SDS.DS_DOC<='"+cNotaFim+"' AND SDS.D_E_L_E_T_= ' ' "

If Select("TRB")>0
    dbSelectArea("TRB")
    dbCloseArea()
Endif

TcQuery cQry New Alias "TRB"

TRB->(dbGotop())
Count To nRecs 

ProcRegua(nRecs )

TRB->(dbGotop())
While TRB->(!Eof())
    
    IncProc("Exportando Xmls, aguarde!")   
    
    dbSelectArea("CKO")
    dbSetOrder(1)
    If dbSeek( Padr(Alltrim(TRB->DS_ARQUIVO),TamSx3("CKO_ARQUIV")[1]))
        If !ExistDir(cFolder+TRB->DS_FILIAL,,.F.)
            nRet := MakeDir( cFolder+TRB->DS_FILIAL,,.F. )
            If nRet != 0
                Aviso("Atenção","Não foi possivel criar o diretorio "+cFolder+TRB->DS_FILIAL+" - Erro: " + cValToChar(FError()), {"Ok"} )
            Endif
        Endif
        cArquivo  := Alltrim(CKO->CKO_ARQXML)
        cUnXML    := CKO->CKO_XMLRET
        nLenUnXML := Len( cUnXML )
        nHandle   := FCreate( cFolder+TRB->DS_FILIAL+"\"+cArquivo+".xml" , 0 , , .T. ) 
        if nHandle = -1
           Aviso("Aviso","Erro ao criar arquivo "+cFolder+TRB->DS_FILIAL+"\"+cArquivos+".xml"+ " - fError " + Str(Ferror()))
        else
            FWrite( nHandle, cUnXML, nLenUnXML )
            FClose( nHandle )   
            nExport++
        Endif    
    Endif
    TRB->(dbSkip())
End    
If nExport>0
    Aviso("Atenção","Exportado(s) "+ Alltrim(Str(nRecs))+" Xml(s) na pasta selecionada.",{"Ok"},2)
Endif    
Return
