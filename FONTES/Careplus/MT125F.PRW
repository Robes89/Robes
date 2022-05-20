#Include 'Protheus.ch'
#Include "TOPCONN.CH" 
#Include "Tbiconn.ch"

/*/{Protheus.doc} nomeFunction
    (long_description)
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
 User  Function MT125F()
 
 Local aVetor := {}
 Local nJ := 0 
 Local cFilial := SubsTR(paramixb,1,4)
 Local cCodigo := SubsTR(paramixb,5,Len(paramixb)-4)
 Local dDataParc := SC3->C3_XDTPPAR




If INCLUI .or. ALTERA
SC3->(DbGoTop())
SC3->(DBSetOrder(1))
SC3->(DbSeek(xFilial("SC3")+cCodigo))
    While !SC3->(EOF())  .and. SC3->C3_NUM == cCodigo
       
       IF ALTERA
            U_FBusReg(SC3->C3_FORNECE,SC3->C3_LOJA,SC3->C3_NUM)
        ENDIF   
           
        lMsErroAuto := .F.
        
        For nJ:= 1  to SC3->C3_QUANT
            aVetor := {}
            If  nJ >= 2
                nMes:= MONTH(dDataParc) + 1
            Else
                nMes:= MONTH(dDataParc)
            EndIF     
            IF  nMes > 12 
                    cData:= Dtos(dDataParc)
                    dDataParc:=Ctod(SubStr(cData,7,2)+'/01/'+Soma1(SubStr(cData,1,4)))
            Else
              dDataParc := ctod(cValtoChar(Day(dDataParc))+'/' +cvaltochar( Iif(nJ >= 2,MONTH(dDataParc) + 1,MONTH(dDataParc)) )+'/'+cValtoChar(Year(dDataParc)))
            ENDIF
                             /* AaDD(aVetor, {"E2_FILIAL",  xFilial("SE2"),  Nil} )     
                               AaDD(aVetor, {"E2_PREFIXO"     ,'CNT',Nil})
                               AaDD(aVetor, {"E2_NUM"          ,GetSxeNum("SE2","E2_NUM"),Nil})
                              AaDD(aVetor,  {"E2_PARCELA"     ,StrZero(nJ,2),Nil})
                               AaDD(aVetor, {"E2_TIPO"          ,'PR',Nil})               
                               AaDD(aVetor, {"E2_NATUREZ"     ,'1000',Nil})
                               AaDD(aVetor, {"E2_FORNECE"     ,SC3->C3_FORNECE,Nil})
                               AaDD(aVetor, {"E2_LOJA"          ,SC3->C3_LOJA ,Nil})      
                               AaDD(aVetor,  {"E2_EMISSAO"     ,dDataBase,NIL})
                               AaDD(aVetor, {"E2_VENCTO"     ,dDataParc,NIL})                         
                               AaDD(aVetor, {"E2_VENCREA"     ,dDataParc,NIL})  
                               AaDD(aVetor,{"E2_XTITPRO"     ,SC3->C3_NUM,NIL})                                                  
                               AaDD(aVetor, {"E2_XPREPRO"     ,"CNT",NIL})
                               AaDD(aVetor, {"E2_VALOR"       ,SC3->C3_PRECO,Nil})
                               AaDD(aVetor, {"E2_VLCRUZ"       ,SC3->C3_PRECO,Nil})*/
                               aVetor :={	{"E2_PREFIXO"	,'CNT',Nil},;
                                            {"E2_NUM"		,GetSxeNum("SE2","E2_NUM"),Nil},;
                                            {"E2_PARCELA"	,StrZero(nJ,2),Nil},;
                                            {"E2_TIPO"		,'PR',Nil},;			 //PRE = titulo provisorio
                                            {"E2_NATUREZ"	,'1000',Nil},;
                                            {"E2_FORNECE"	,SC3->C3_FORNECE,Nil},; 
                                            {"E2_LOJA"		,SC3->C3_LOJA,Nil},;      
                                            {"E2_EMISSAO"	,dDataBase,NIL},;
                                            {"E2_VENCTO"	,dDataParc,NIL},;					 
                                            {"E2_VENCREA"	,dDataParc,NIL},;					 					
                                            {"E2_VALOR"		,SC3->C3_PRECO,Nil},;
                                            {"E2_XTITPRO"		,SC3->C3_NUM,Nil},;
                                            {"E2_XPREPRO"		,"CNT",Nil}}


            Begin Transaction
                MSExecAuto({|x,y,z| Fina050(x,y,z)},aVetor,,3) //Inclusao
                if lMsErroAuto
                    Mostraerro()
                EndIF
            End Transaction    
        Next 
        
        SC3->(DbSkip())
    EndDo  
Else
    
  U_FBusReg(SC3->C3_FORNECE,SC3->C3_LOJA,SC3->C3_NUM)

ENDIF
Return .T.


User Function FBusReg(cForn,cLoj,cNum)

Local cAlias := GetNextAlias()
Local aVetor := {}
Private  lMsErroAuto := .F. 


Default  cForn:= ''
Default  cLoj := ''
Default  cNum := '' 


    BeginSql Alias cAlias
        Select * From %Table:SE2% SE2 
            Where SE2.%NotDel% and E2_FORNECE = %exp:cForn% and E2_LOJA = %exp:cLoj% and E2_XTITPRO = %exp:cNum% and E2_XPREPRO = 'CNT' and E2_FILIAL =  %exp:xFilial("SE2")%
    EndSql
        
        IF !(cAlias)->(Eof())
           While  !(cAlias)->(Eof())
                aVetor :={          {"E2_PREFIXO"     ,(cAlias)->E2_PREFIXO,Nil},;
                        {"E2_NUM"          ,(cAlias)->E2_NUM ,Nil},;
                        {"E2_PARCELA"     ,(cAlias)->E2_PARCELA,Nil},;
                        {"E2_TIPO"          ,(cAlias)->E2_TIPO,Nil},;               
                        {"E2_NATUREZ"     ,(cAlias)->E2_NATUREZ,Nil}}
                Begin Transaction        
                    MSExecAuto({|x,y,z| Fina050(x,y,z)},aVetor,,5) //Exclusão
                    if lMsErroAuto
                        Mostraerro()
                    EndIF
                 End Transaction     
                (cAlias)->(DbSkip())
             EndDo   
         ENDIF 

Return