#include 'fivewin.ch'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "AP5MAIL.CH"
#include "topconn.ch"
#include "fwprintsetup.ch"
#include "rptdef.ch"

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
        TEZJQ9
 /*/

User Function REECIN01

PRIVATE lAdjustToLegacy := .T.
PRIVATE lDisableSetup   := .T.
PRIVATE oPrinter        := ''
Private oBrush          := TBrush():NEW("",CLR_HGRAY)          
Private oBrushG         := TBrush():NEW("",CLR_YELLOW)          
Private oPen		:= TPen():New(0,5,CLR_BLACK)
PRIVATE oCouNew08	:= TFont():New("Courier New"	,08,08,,.F.,,,,.T.,.F.)
PRIVATE oCouNew08N	:= TFont():New("Courier New"	,08,08,,.T.,,,,.F.,.F.)		// Negrito //oCouNew09N
PRIVATE oCouNew09N	:= TFont():New("Courier New"	,09,09,,.T.,,,,.F.,.F.)		// Negrito //oCouNew09N
PRIVATE oCouNew10N	:= TFont():New("Courier New"	,10,10,,.T.,,,,.F.,.F.)		// Negrito
PRIVATE oCouNew12N	:= TFont():New("Courier New"	,12,12,,.T.,,,,.F.,.F.)		// Negrito
PRIVATE oCouNew11N	:= TFont():New("Courier New"	,11,11,,.T.,,,,.F.,.F.)		// Negrito
PRIVATE oArialMT11 	:= TFont():New("Arial MT"	,11,11,,.F.,,,,.T.,.F.)   
PRIVATE oArialMT12 	:= TFont():New("Arial MT"	,12,12,,.F.,,,,.T.,.F.)  
PRIVATE oArialMT12N 	:= TFont():New("Arial MT"	,12,12,,.T.,,,,.T.,.F.)  
PRIVATE oArialMT8	:= TFont():New("Arial MT"	,9,9,,.F.,,,,.T.,.F.)                
PRIVATE oArial08N	:= TFont():New("Arial"			,08,08,,.T.,,,,.F.,.F.)		// Negrito
PRIVATE oArial09N	:= TFont():New("Arial"			,09,09,,.T.,,,,.F.,.F.)		// Negrito
PRIVATE oArial10N	:= TFont():New("Arial"			,10,10,,.T.,,,,.F.,.F.)		// Negrito
PRIVATE oArial11N	:= TFont():New("Arial"			,11,11,,.T.,,,,.F.,.F.)		// Negrito
PRIVATE oArial14N	:= TFont():New("Arial"			,14,14,,.T.,,,,.F.,.F.)
PRIVATE oArial14	:= TFont():New("Arial"			,14,14,,.F.,,,,.F.,.F.)		// Negrito
PRIVATE oArial18N	:= TFont():New("Arial"			,18,18,,.T.,,,,.F.,.F.)		// Negrito
PRIVATE oArial20N	:= TFont():New("Arial"			,26,26,,.T.,,,,.F.,.F.)		// Negrito
PRIVATE oArial12	:= TFont():New("Arial"			,12,12,,.F.,,,,.F.,.F.)	
PRIVATE oCouNew12S	:= TFont():New("Courier New",12,12,,.T.,,,,.F.,.F.)		// SubLinhado
PRIVATE cContato        := ""
PRIVATE cNomFor         := ""
Private nReg 		:= 0
Private aBoxParam       := {} 
Private aCombo          := {"Packing SHIP BILL","Packing BILL TO","INV AMOSTRA","INV BILL TO","INV SHIP BILL","INV SHIP BILL AMST"}
Private aRetParam	:= {}
Private cQry            := ""
Private cAlias          := GetNextAlias()   
Private cCliDe          := Space(TamSx3("EEC_PREEMB")[1])    

Aadd(aBoxParam,{1, "Invoce ", cCliDe,"@!","","EEC" , ".T.", 60, .F.})

IF ParamBox(aBoxParam, "Invoce Type", @aRetParam)

        cQry := "SELECT * FROM "+RetSqlNAme("EEC")+" EEC inner join "+RetSqlNAme("EE9")+" EE9 ON EE9.EE9_FILIAL = EEC_FILIAL AND EEC_PREEMB = EE9.EE9_PREEMB AND EEC_FORN = EE9.EE9_FORN AND EEC_FOLOJA = EE9.EE9_FOLOJA AND EE9.D_E_L_E_T_ = ' '  "
        cQry += " Left JOin "+RetSqlNAme("PR1")+" PR1 ON PR1_FILIAL = EE9.EE9_FILIAL AND PR1_EMBARQ = EE9.EE9_PREEMB AND PR1_PROD = EE9_COD_I AND PR1.D_E_L_E_T_ = ' ' AND lTrim(RTRIM(PR1_SEQUEN)) = lTrim(RTRIM(EE9.EE9_SEQEMB)) "
        cQry += " Where EEC.D_E_L_E_T_ = ''  and EEC.EEC_PREEMB = '"+aRetParam[1]+"'  order by PR1_IDEMB" 
        cQry1 := "SELECT * FROM "+RetSqlNAme("EEC")+" EEC inner join "+RetSqlNAme("EE9")+" EE9 ON EE9.EE9_FILIAL = EEC_FILIAL AND EEC_PREEMB = EE9.EE9_PREEMB AND EEC_FORN = EE9.EE9_FORN AND EEC_FOLOJA = EE9.EE9_FOLOJA AND EE9.D_E_L_E_T_ = ' '  "
        //cQry += " Left JOin "+RetSqlNAme("PR1")+" PR1 ON PR1_FILIAL = EE9.EE9_FILIAL AND PR1_EMBARQ = EE9.EE9_PREEMB AND PR1_PROD = EE9_COD_I AND PR1.D_E_L_E_T_ = ' ' AND lTrim(RTRIM(PR1_SEQUEN)) = lTrim(RTRIM(EE9.EE9_SEQUEN)) "
        cQry1 += " Where EEC.D_E_L_E_T_ = ''  and EEC.EEC_PREEMB = '"+aRetParam[1]+"'  " 

       
       
        aBoxParam := {} 
        aRetParam := {}
        aAdd(aBoxParam, {3, "Invoice Type?",1,aCombo,50,"",.T.})

        IF ParamBox(aBoxParam, "Invoce Type", @aRetParam)
           If aRetParam[1] == 1 .Or. aRetParam[1] == 2 
                cQry := ChangeQuery(cQry)
                dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQry),cAlias, .F., .T.)      
           Else

                cQry1 := ChangeQuery(cQry1)
                dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQry1),cAlias, .F., .T.)
           EndIF
                IF aRetParam[1] == 1
                        Picking()
                ElseIf aRetParam[1] == 2 
                        Picking()
                ElseIf aRetParam[1] == 3
                        Invoice(aRetParam[1])      
                ElseIf aRetParam[1] == 4
                        Invoice(aRetParam[1])
                ElseIf aRetParam[1] == 5
                        Invoice(aRetParam[1])
                ElseIf aRetParam[1] == 6
                        Invoice(aRetParam[1])
                EndIF   

        EndIF
EndIF   
Return

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/

 Static Function Picking()

local cEEC  := GetNextAlias()
Local cQQQ  := ''
oPrinter := FWMSPrinter():New(cEEC+".rel", IMP_PDF, lAdjustToLegacy, , lDisableSetup)// Ordem obrigátoria de configuração do relatório
oPrinter:SetResolution(72)
oPrinter:SetPortrait()
oPrinter:SetPaperSize(DMPAPER_A4)
oPrinter:SetMargin(10,10,10,10) // nEsquerda, nSuperior, nDireita, nInferior
oPrinter:cPathPDF := "c:\temp\" // Caso seja utilizada impressão em IMP_PDF
oPrinter:StartPage() 
//CAbec
oPrinter:SayBitmap( 140, 049, "C:\temp\audax_logo.png", 850, 130)
oPrinter:Say(0200,1600,"PACKING LIST",oArial20N)
oPrinter:Say(0300,1540,"PACKING LIST NUMBER:    PL-" + (cAlias)->EEC_PREEMB,oArial14N)
oPrinter:Say(0340,1840,"DATE : ",oArial14N)
oPrinter:Say(0340,1980,cMonth(dDatabase)+', ' +Day2Str(dDatabase) +" " + Year2Str(dDatabase),oArial14)

oPrinter:Say(0380,1700,"INVOICE/Ref No: " + (cAlias)->EEC_PREEMB,oArial14N)
//oPrinter:StartPage() 		// Inicia uma nova pagina
// COluna de  Cima 
oPrinter:Box(0430,0030,800,1127 )  //LINHA/COLUNA/ALTURA/LARGURA
oPrinter:FillRect({0433,032,0489,1122},oBrush)
oPrinter:Say(0464,0428,"SHIPPER",oArial14N)
oPrinter:Say(0524,060,Posicione("SA2",1,xFilial("SA2")+(cAlias)->EEC_FORN,"A2_NOME" ),oArial14N)
oPrinter:Say(0569,060,(cAlias)->EEC_RESPON,oArial14)
oPrinter:Say(0609,060,Posicione("SA2",1,xFilial("SA2")+(cAlias)->EEC_FORN,"A2_END" ),oArial14)
oPrinter:Say(0649,060,Posicione("SA2",1,xFilial("SA2")+(cAlias)->EEC_FORN,"A2_BAIRRO" ),oArial14)
oPrinter:Say(0689,060,"CNPJ: "+TRANSFORM(Posicione("SA2",1,xFilial("SA2")+(cAlias)->EEC_FORN,"A2_CGC" ),"?@R 99.999.999/9999-99") ,oArial14)
oPrinter:Say(0730,060,"Phone: "+Posicione("SA2",1,xFilial("SA2")+(cAlias)->EEC_FORN,"A2_TEL" ),oArial14)

cQQQ := "SELECT * FROM EE3010 where rownum = 1 and EE3_CONTAT = '"+(cAlias)->EEC_FORN+"' ORDER BY  R_E_C_N_O_ DESC"
cQQQ := ChangeQuery(cQQQ)
dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQQQ),cEEC, .F., .T.)
oPrinter:Say(0774,060,"Email: "+(cEEC)->EE3_EMAIL,oArial14)

oPrinter:Box(0430,2297,800,1200 ) 
oPrinter:FillRect({0433,2293,0489,1204},oBrush)
oPrinter:Say(0464,1648,"SHIP TO",oArial14N)
if aRetParam[1] == 2
oPrinter:Say(0524,1228,Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_IMPORT,"A1_NOME" ),oArial14N)

DBCloseArea((cEEC))
cQQQ := "SELECT * FROM EE3010 where rownum = 1 and EE3_CONTAT = '"+(cAlias)->EEC_IMPORT+"' ORDER BY  R_E_C_N_O_ DESC"
cQQQ := ChangeQuery(cQQQ)
dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQQQ),cEEC, .F., .T.)
oPrinter:Say(0569,1228,Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_IMPORT,"A1_CONTATO" ),oArial14)
oPrinter:Say(0609,1228,Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_IMPORT,"A1_END" ),oArial14)
oPrinter:Say(0649,1228,Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_IMPORT,"A1_BAIRRO" ),oArial14)
oPrinter:Say(0689,1228,"Movil: " +Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_IMPORT,"A1_TEL" ),oArial14)
oPrinter:Say(0730,1228,"Phone: +" +Alltrim(Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_IMPORT,"A1_DDI" ))+' '+Alltrim(Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_IMPORT,"A1_DDD" ))+' '+Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_IMPORT,"A1_TEL" ),oArial14)
oPrinter:Say(0774,1228,"Email: "+(cEEC)->EE3_EMAIL,oArial14)
Else
oPrinter:Say(0524,1228,Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_XSHIPT,"A1_NOME" ),oArial14N)
If Select((cEEC)) > 0 
(cEEC)->(DBCloseArea())
EndIF
cQQQ := "SELECT * FROM EE3010 where rownum = 1 and EE3_CONTAT = '"+(cAlias)->EEC_XSHIPT+"' ORDER BY  R_E_C_N_O_ DESC"
cQQQ := ChangeQuery(cQQQ)
dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQQQ),cEEC, .F., .T.)
oPrinter:Say(0569,1228,Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_XSHIPT,"A1_CONTATO" ),oArial14)
oPrinter:Say(0609,1228,Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_XSHIPT,"A1_END" ),oArial14)
oPrinter:Say(0649,1228,Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_XSHIPT,"A1_BAIRRO" ),oArial14)
oPrinter:Say(0689,1228,"Movil: " +Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_XSHIPT,"A1_TEL" ),oArial14)
oPrinter:Say(0730,1228,"Phone: +" +Alltrim(Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_XSHIPT,"A1_DDI" ))+' '+Alltrim(Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_XSHIPT,"A1_DDD" ))+' '+Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_XSHIPT,"A1_TEL" ),oArial14)
oPrinter:Say(0774,1228,"Email: "+(cEEC)->EE3_EMAIL,oArial14)
Endif

nTA := 0
nU := 0 
CEMB:= ''
nNetVl :=0
nVFim := 0
nW := 0 
nEMb := 0 
nFim1 := 0
nFim2:=0
nO:=0
WHile !(cAlias)->(EOF())

      If (cAlias)->PR1_IDEMB <> CEMB 
        nEMb +=1
        If nNetVl > 0 
                oPrinter:Say(0985+ nTA,1880,  cvaltochar(nNetVl) ,oArial14N)
                oPrinter:Say(0985+ nTA,2178,  cvaltochar(nVFim ),oArial14N)
                If Len(alltrim((cAlias)->EE9_XDESC)) <= 58
                 nTA+= 207 + iif(no == 1 ,110,190) 
                Else
                 nTA+= 247 + iif(no == 1 ,110,190) 
                Endif    
                nFim1 +=nNetVl
                nFim2 += nVFim
                nNetVl :=0
                nVFim :=0
                If Len(alltrim((cAlias)->EE9_XDESC)) <= 58
                 nU+=210 + iif(no == 1 ,0,60) 
                Else
                 nU+=250 + iif(no == 1 ,0,60) 
                EndIF 
                nO:=0
                oPrinter:Line( 0850 + nTA- 7, 0040, 0850+nTA - 7, 2360,, "-4")
                
        EndIF
        oPrinter:FillRect({0940 + nTA,0040,1020 + nTA,2360},oBrush)
        oPrinter:Line( 0850, 0040, 0850, 2360,, "-4")
        oPrinter:Say(0880 + nTA,0080, "ID",oArial14N)
        oPrinter:Say(0910 + nTA,0040,  "Package",oArial14N)
        oPrinter:Say(0985 + nTA ,0080,cValtoChar(nEMb) ,oArial14N)
        
        oPrinter:Say(0900 + nTA,0340,  "PACKING",oArial14N)
        oPrinter:Say(0985+ nTA,0340,POsicione("EE5",1,xFilial("EE5")+(cAlias)->PR1_EMBALA,"EE5_DESC") ,oArial14N)
        oPrinter:Say(0885+ nTA,1380,  "SIZE (cm)",oArial14N)
        oPrinter:Line( 0900 + nTA, 1330, 0900+ nTA, 1587,, "-4")
        oPrinter:Say(0928 + nTA,1330,  "L         W         H",oArial14N)
        
        oPrinter:Say(0985 + nTA,1330,  POsicione("EE5",1,xFilial("EE5")+(cAlias)->PR1_EMBALA,"EE5_DIMENS"),oArial14N)
        oPrinter:Say(0880+ nTA,1810,  "NET WEIGHT",oArial14N)
        oPrinter:Say(0910+ nTA,1892,  "(KG)",oArial14N)
        oPrinter:Say(0880+ nTA,2080,  "GROSS WEIGHT",oArial14N)
        oPrinter:Say(0910+ nTA,2164,  "(KG)",oArial14N)
        cEmb := (cAlias)->PR1_IDEMB
        
        oPrinter:Say(1060+ nTA,0040 ,"Code Item        Description                                                                                        HTS CODE" ,oArial11N)
        oPrinter:Say(1045+ nTA,1305 ,"Country of ",oArial11N)
        oPrinter:Say(1068+ nTA,1320 ,"Origin" ,oArial11N)
        oPrinter:Say(1060+ nTA,1547 ,"Manufacturer            Qty",oArial11N)
        oPrinter:Say(1045+ nTA,1930 ,"Unit Net",oArial11N)
        oPrinter:Say(1068+ nTA,1930 ,"Weight (Kg)",oArial11N)
        oPrinter:Say(1045+ nTA,2140 ,"Net Weight",oArial11N)
        oPrinter:Say(1068+ nTA,2140 ,"per item (Kg)",oArial11N) 
       
        
     Else
        
        cEmb := (cAlias)->PR1_IDEMB

        
     EndIf   

        nNetVl += ((cAlias)->EE9_PSLQUN *(cAlias)->PR1_QTDEMB)
        nVFim += (cAlias)->PR1_PSBRUT
        oPrinter:Say(1120+ nU,040 ,(cAlias)->EE9_COD_I,oArial10N)
       If Len(alltrim((cAlias)->EE9_XDESC)) <= 58
        oPrinter:Say(1120+ nU,0278 ,(cAlias)->EE9_XDESC ,oArial10N)
       Else
       oPrinter:Say(1100+ nU,0245 ,Substr((cAlias)->EE9_XDESC,1,58) ,oArial10N)
       oPrinter:Say(1129+ nU,0245 ,Substr((cAlias)->EE9_XDESC,59,51) ,oArial10N)
       oPrinter:Say(1153+ nU,0245 ,Substr((cAlias)->EE9_XDESC,110,58) ,oArial10N)
       ENdIf 
        oPrinter:Say(1120+ nU,1140 ,(cAlias)->EE9_XNCM,oArial10N)
        oPrinter:Say(1120+ nU,1336 ,Posicione("SYA",1,xFilial("SYA")+Posicione("SA2",1,xFilial("SA2")+(cAlias)->EEC_FORN,"A2_PAIS" ),"YA_PAIS_I"),oArial10N)
        oPrinter:Say(1120+ nU,1510 ,Posicione("SA2",1,xFilial("SA2")+(cAlias)->EEC_FORN,"A2_NREDUZ" ),oArial10N)
        oPrinter:Say(1120+ nU,1835 ,cvaltochar((cAlias)->PR1_QTDEMB),oArial10N) 
        oPrinter:Say(1120+ nU,1955 ,cvaltochar((cAlias)->EE9_PSLQUN),oArial10N)
        oPrinter:Say(1120+ nU,2210 ,cvaltochar(((cAlias)->EE9_PSLQUN *(cAlias)->PR1_QTDEMB) ),oArial10N)  
     
        nU +=100
        nO += 1
        (cAlias)->(dbSkip())
ENdDO
If  nU == 100 
 nU := 0 
Endif
nFim1+=nNetVl
nFim2+=nVFim
oPrinter:Say(0985+ nTA,1880,  cvaltochar(nNetVl) ,oArial14N)
oPrinter:Say(0985+ nTA,2178,  cvaltochar(nVFim ),oArial14N)
oPrinter:Line( 1190+ nU , 0040, 1190+ nU , 2360,, "-4")
(cAlias)->(DbGoTOp())

nGrb :=  ((1190+ nU) - 1960 ) +40
oPrinter:Say(1960+nGrb,0080 ,"Shipment terms: " +(cAlias)->EEC_INCOTE,oArial14)
oPrinter:Say(2010+nGrb,0080 ,"Mode of Transport: " +Posicione("SYQ",1,xFilial("SYQ")+(cAlias)->EEC_VIA,"YQ_DESCR"),oArial14)
oPrinter:Say(2070+nGrb,0080 ,"Total Net Weight (Kg): " + cvaltochar(nFim1)  ,oArial14)
oPrinter:Say(2130+nGrb,0080 ,"Total Gross Weight (Kg): " + cvaltochar(nFim2 ),oArial14)

oPrinter:Line( 2700, 100, 2700, 1030, ,"-4")
oPrinter:Say(2891,1200,  "1/1",oArialMT12)
oPrinter:Preview() 

(cAlias)->(DBCloseArea())
Return 

/*/{Protheus.doc} nomeStaticFunction
        (long_description)
        @type  Static Function
        @author user
        @since date
        @version version
        @param param, param_type, param_descr
        @return return, return_type, return_description
        @example
        (examples)
        @see (links_or_references)
        /*/
 Static Function Invoice(nMdRelat)
 local cEEC  := GetNextAlias()
Local cQQQ  := ''

oPrinter := FWMSPrinter():New(cEEC+".rel", IMP_PDF, lAdjustToLegacy, , lDisableSetup)// Ordem obrigátoria de configuração do relatório
oPrinter:SetResolution(72)
oPrinter:SetPortrait()
oPrinter:SetPaperSize(DMPAPER_A4)
oPrinter:SetMargin(10,10,10,10) // nEsquerda, nSuperior, nDireita, nInferior
oPrinter:cPathPDF := "c:\temp\" // Caso seja utilizada impressão em IMP_PDF
oPrinter:StartPage() 
//CAbec
oPrinter:SayBitmap( 140, 049, "C:\temp\audax_logo.png", 850, 130)
oPrinter:Say(0200,1660,"COMMERCIAL INVOICE",oArial18N)
oPrinter:Say(0270,1660,"DATE : ",oArial14N)
oPrinter:Say(0270,1822,cMonth(dDatabase)+' ' +Day2Str(dDatabase) +" ," + Year2Str(dDatabase),oArial14)
oPrinter:Say(0310,1660,"INVOICE: "+ (cAlias)->EEC_PREEMB,oArial14N)
//oPrinter:StartPage() 		// Inicia uma nova pagina
// COluna de  Cima 
oPrinter:Box(0430,0030,800,1127 )  //LINHA/COLUNA/ALTURA/LARGURA
oPrinter:FillRect({0433,032,0489,1122},oBrush)
oPrinter:Say(0464,0428,"SHIPPER",oArial14N)
oPrinter:Box(0430,2297,800,1200 ) 
oPrinter:FillRect({0433,2293,0489,1204},oBrush)
oPrinter:Say(0524,060,Posicione("SA2",1,xFilial("SA2")+(cAlias)->EEC_FORN,"A2_NOME" ),oArial14N)
oPrinter:Say(0569,060,(cAlias)->EEC_RESPON,oArial14)
oPrinter:Say(0609,060,Posicione("SA2",1,xFilial("SA2")+(cAlias)->EEC_FORN,"A2_END" ),oArial14)
oPrinter:Say(0649,060,Posicione("SA2",1,xFilial("SA2")+(cAlias)->EEC_FORN,"A2_BAIRRO" ),oArial14)
oPrinter:Say(0689,060,"CNPJ: "+TRANSFORM(Posicione("SA2",1,xFilial("SA2")+(cAlias)->EEC_FORN,"A2_CGC" ),"?@R 99.999.999/9999-99") ,oArial14)
oPrinter:Say(0730,060,"Phone: "+Posicione("SA2",1,xFilial("SA2")+(cAlias)->EEC_FORN,"A2_TEL" ),oArial14)
cQQQ := "SELECT * FROM EE3010 where rownum = 1 and EE3_CONTAT = '"+(cAlias)->EEC_FORN+"' ORDER BY  R_E_C_N_O_ DESC"
cQQQ := ChangeQuery(cQQQ)
dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQQQ),cEEC, .F., .T.)
oPrinter:Say(0774,060,"Email: "+(cEEC)->EE3_EMAIL,oArial14)

oPrinter:Say(0464,1648,"SHIP TO",oArial14N)

IF nMdRelat == 3 .or. nMdRelat == 4
oPrinter:Say(0524,1228,Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_IMPORT,"A1_NOME" ),oArial14N)
If Select((cEEC)) > 0 
(cEEC)->(DBCloseArea())
EndIF
cQQQ := "SELECT * FROM EE3010 where rownum = 1 and EE3_CONTAT = '"+(cAlias)->EEC_IMPORT+"' ORDER BY  R_E_C_N_O_ DESC"
cQQQ := ChangeQuery(cQQQ)
dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQQQ),cEEC, .F., .T.)
oPrinter:Say(0569,1228,Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_IMPORT,"A1_CONTATO" ),oArial14)
oPrinter:Say(0609,1228,Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_IMPORT,"A1_END" ),oArial14)
oPrinter:Say(0649,1228,Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_IMPORT,"A1_BAIRRO" ),oArial14)
oPrinter:Say(0689,1228,"Movil: " +Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_IMPORT,"A1_TEL" ),oArial14)
oPrinter:Say(0729,1228,"Phone: +" +Alltrim(Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_IMPORT,"A1_DDI" ))+' '+Alltrim(Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_IMPORT,"A1_DDD" ))+' '+Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_IMPORT,"A1_TEL" ),oArial14)
oPrinter:Say(0769,1228,"Email: "+(cEEC)->EE3_EMAIL,oArial14)
Else
oPrinter:Say(0524,1228,Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_XSHIPT,"A1_NOME" ),oArial14N)
If Select((cEEC)) > 0 
(cEEC)->(DBCloseArea())
EndIF
cQQQ := "SELECT * FROM EE3010 where rownum = 1 and EE3_CONTAT = '"+(cAlias)->EEC_XSHIPT+"' ORDER BY  R_E_C_N_O_ DESC"
cQQQ := ChangeQuery(cQQQ)
dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQQQ),cEEC, .F., .T.)
oPrinter:Say(0569,1228,Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_XSHIPT,"A1_CONTATO" ),oArial14)
oPrinter:Say(0609,1228,Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_XSHIPT,"A1_END" ),oArial14)
oPrinter:Say(0649,1228,Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_XSHIPT,"A1_BAIRRO" ),oArial14)
oPrinter:Say(0689,1228,"Movil: " +Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_XSHIPT,"A1_TEL" ),oArial14)
oPrinter:Say(0730,1228,"Phone: +" +Alltrim(Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_XSHIPT,"A1_DDI" ))+' '+Alltrim(Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_XSHIPT,"A1_DDD" ))+' '+Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_XSHIPT,"A1_TEL" ),oArial14)
oPrinter:Say(0774,1228,"Email: "+(cEEC)->EE3_EMAIL,oArial14)    
EndIF
// COluna de  Baixo  
oPrinter:Box(830,0030,1200,1127 )  //LINHA/COLUNA/ALTURA/LARGURA
oPrinter:FillRect({835,033,889,1120},oBrush)
oPrinter:Say(874,0340,"BANK INFORMATION",oArial14N)
oPrinter:Say(954,035,"Beneficiary Customer" ,oArial14N) 
oPrinter:Say(954,428,"AUDAX ELECTRONICS LTDA.",oArial14)
oPrinter:Say(1000,035,"CNPJ: ",oArial14N)
oPrinter:Say(1000,138,"17.465.448/0001-83",oArial14)
oPrinter:Say(1044,035,"IBAN ",oArial14N)
oPrinter:Say(1044,138,"BR0300000000047040000207446C1",oArial14)
oPrinter:Say(1085,035,"Beneficiary Bank ",oArial14N)
oPrinter:Say(1085,335,"BANCO DO BRASIL S.A.",oArial14)
oPrinter:Say(1124,035,"GECEX SÃO PAULO IBIC SWIFT: BRASBRRJSBO",oArial14)

oPrinter:Box(830,2297,1200,1200 ) 
oPrinter:FillRect({835,2293,889,1204},oBrush)
oPrinter:Say(874,1648,"BILL TO",oArial14N)
// bill to ini 

oPrinter:Say(0924,1228,Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_IMPORT,"A1_NOME" ),oArial14N)
If Select((cEEC)) > 0 
(cEEC)->(DBCloseArea())
EndIF)
cQQQ := "SELECT * FROM EE3010 where rownum = 1 and EE3_CONTAT = '"+(cAlias)->EEC_IMPORT+"' ORDER BY  R_E_C_N_O_ DESC"
cQQQ := ChangeQuery(cQQQ)
dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQQQ),cEEC, .F., .T.)
oPrinter:Say(0969,1228,Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_IMPORT,"A1_CONTATO" ),oArial14)
oPrinter:Say(1009,1228,Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_IMPORT,"A1_END" ),oArial14)
oPrinter:Say(1049,1228,Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_IMPORT,"A1_BAIRRO" ),oArial14)
oPrinter:Say(1089,1228,"Movil: " +Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_IMPORT,"A1_TEL" ),oArial14)
oPrinter:Say(1129,1228,"Phone: +" +Alltrim(Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_IMPORT,"A1_DDI" ))+' '+Alltrim(Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_IMPORT,"A1_DDD" ))+' '+Posicione("SA1",1,xFilial("SA1")+(cAlias)->EEC_IMPORT,"A1_TEL" ),oArial14)
oPrinter:Say(1169,1228,"Email: "+(cEEC)->EE3_EMAIL,oArial14)


//Bill To Fim 

oPrinter:Say(1260,0040, "ID          P/N AUDAX                  DESCRIPTION",oArial14N)
oPrinter:Say(1260,1480,  "QUANTITY        UNIT PRICE                           TOTAL",oArial14N)
oPrinter:Line( 1290, 0030, 1290, 2350,, "-2")


nU:= 0 
nTotFim := 0 
nl1:= 0
nl2 := 0
nNetVl := 0
WHile   !(cAlias)->(EOF())
        nU += 1
        oPrinter:Say(1400+nl2,0040, cvaltochar(nU),oArial14 )
        oPrinter:Say(1400+nl2,0180, (cAlias)->EE9_COD_I ,oArial14 )
       // oPrinter:Say(1334+nl1,0523, (cAlias)->EE9_XDESC,oArial14 )
       If Len(alltrim((cAlias)->EE9_XDESC)) <= 58
        oPrinter:Say(1334+ nl1,0523 ,(cAlias)->EE9_XDESC ,oArial14)
        oPrinter:Say(1364+nl1,0523,"HTS COD "+ (cAlias)->EE9_XNCM ,oArial14 )
        oPrinter:Say(1394+nl1,0523, "Country of Origin: "+Posicione("SYA",1,xFilial("SYA")+(cAlias)->EE9_XPAORI,"YA_PAIS_I"),oArial14 )
        oPrinter:Say(1424+nl1,0523, "Manufacturer: "+Posicione("SA2",1,xFilial("SA2")+(cAlias)->EEC_FORN,"A2_NOME" ),oArial14 )
        oPrinter:Say(1454+nl1,0523, "Customer Reference: "+(cAlias)->EE9_XREFIM,oArial14 )
       Else
        oPrinter:Say(1318+ nl1,0523 ,Substr((cAlias)->EE9_XDESC,1,58) ,oArial12)
        oPrinter:Say(1348+ nl1,0523 ,Substr((cAlias)->EE9_XDESC,59,51) ,oArial12)
        oPrinter:Say(1378+ nl1,0523 ,Substr((cAlias)->EE9_XDESC,110,58) ,oArial12)
        oPrinter:Say(1408+nl1,0523,"HTS COD "+ (cAlias)->EE9_XNCM ,oArial14 )
        oPrinter:Say(1438+nl1,0523, "Country of Origin: "+Posicione("SYA",1,xFilial("SYA")+(cAlias)->EE9_XPAORI,"YA_PAIS_I"),oArial14 )
        oPrinter:Say(1468+nl1,0523, "Manufacturer: "+Posicione("SA2",1,xFilial("SA2")+(cAlias)->EEC_FORN,"A2_NOME" ),oArial14 )
        oPrinter:Say(1498+nl1,0523, "Customer Reference: "+(cAlias)->EE9_XREFIM,oArial14 )
       ENdIf 
       
        oPrinter:Say(1400+nl2,1535, cvaltochar((cAlias)->EE9_SLDINI) ,oArial14 )
        oPrinter:Say(1400+nl2,1785,'$'+ alltrim(Transform(IIF(nMdRelat == 5 .or. nMdRelat == 6,(cAlias)->EE9_XUNSHT,(cAlias)->EE9_PRECO),"@E 999,999,999.99")),oArial14 )
        oPrinter:Say(1400+nl2,2075,'$' + alltrim(Transform(((cAlias)->EE9_SLDINI  * IIF(nMdRelat == 5 .or. nMdRelat == 6,(cAlias)->EE9_XUNSHT,(cAlias)->EE9_PRECO)),"@E 999,999,999.99")),oArial14 )
        oPrinter:Line( 1504+nl1, 0030, 1504+nl1, 2350,, "-2")
        nTotFim += ((cAlias)->EE9_SLDINI  * IIF(nMdRelat == 5 .or. nMdRelat == 6,(cAlias)->EE9_XUNSHT,(cAlias)->EE9_PRECO))
        nl1 += 224
        nl2 += 200
        nNetVl += (cAlias)->EE9_PSLQTO
        (cAlias)->(DbSkip())
EndDo
(cAlias)->(DbGoTOp())

oPrinter:Say(2301,1685, "SUB TOTAL: $ ",oArial14N)
oPrinter:Say(2348,1440, "SHIPPING AND HANDLING: $ " ,oArial14N)
oPrinter:Say(2388,1771, "TOTAL: $ ",oArial14N)
oPrinter:Say(2301,2000, alltrim(Transform(nTotFim,"@E 999,999,999.99")),oArial14N)
oPrinter:Say( 2388,2000,alltrim(Transform(nTotFim + (cAlias)->EEC_FRPREV,"@E 999,999,999.99")),oArial14N )
nUw := 0

IF (cAlias)->EEC_FRPREV < 10 
nUw := 70
ElseIf (cAlias)->EEC_FRPREV < 100
nUw := 40
ElseIf (cAlias)->EEC_FRPREV < 1000
nUw := 10
ENdIf
oPrinter:Say( 2348,2000+nUw,alltrim(Transform((cAlias)->EEC_FRPREV,"@E 999,999,999.99")),oArial14N )
IF nMdRelat == 3  
        oPrinter:Box(2300,0030,2350,927 )
        oPrinter:Say(2341,70,  "SAMPLES WITHOUT COMMERCIAL VALUE",oArial14N)   
        oPrinter:Say(2293,050,"Shipment terms: "+ (cAlias)->EEC_INCOTE,oArial14) 
Else
        If nMdRelat == 6 
                oPrinter:Box(2358,0030,2405,927 )
                oPrinter:Say(2396,70,  "SAMPLES WITHOUT COMMERCIAL VALUE",oArial14N) 
                oPrinter:Say(2301,050,"Shipment terms: "+ (cAlias)->EEC_INCOTE,oArial14)
        Else        
                 oPrinter:Say(2301,050,"Shipment terms: "+ (cAlias)->EEC_INCOTE,oArial14)
                 oPrinter:Say(2348,050,"Payment terms: "+ POsicione("SYP",1,xFilial("SYP")+POsicione("SY6",1,xFilial("SY6")+(cAlias)->EEC_CONDPA,"Y6_DESC_P")+'001',"YP_TEXTO"),oArial14)
        EndIF
        IF nMdRelat == 4 
                cPeso := GetNextAlias()
                cQry := ChangeQuery(cQry)
                dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQry),cPeso, .F., .T.)
                
                nVFim := 0
                WHile !(cPeso)->(EOF())
                
                        nVFim += (cPeso)->PR1_PSBRUT
                (cPeso)->(DbSkip())
                ENdDO    
                oPrinter:Say(2395,050,"Total Net Weight (Kgs): " + cvaltochar(nNetVl) ,oArial14)
                oPrinter:Say(2442,050,"Total Gross Weight (Kgs): " + cvaltochar(nVFim),oArial14)
        EndIf
EndIF

oPrinter:Line( 2700, 100, 2700, 1030,,"-4")
oPrinter:Say(2891,1200,  "1/1",oArialMT11)
oPrinter:Preview()

Return

User Function EAE100MNU()

Local aTeste:={}

   AADD(aTeste,{"Embalagem","U_EMBARQ()",0,8}) 

Return aTeste


User Function EMBARQ()


 Local aArea := GetArea()
    //Objetos da Janela
    Private oDlgPvt
    Private oMsGetSBM,oMsGetSB
    Private aHeadSBM := {}
    Private aColsSBM := {}
    Private aColsRB:= {} 
    Private oBtnSalv
    Private oBtnFech
    Private oBtnLege
    Private aHeadSB := {} 
    //Tamanho da Janela
    Private    nJanLarg    := 900
    Private    nJanAltu    := 600
    //Fontes
    Private    cFontUti   := "Tahoma"
    Private    oFontAno   := TFont():New(cFontUti,,-38)
    Private    oFontSub   := TFont():New(cFontUti,,-20)
    Private    oFontSubN  := TFont():New(cFontUti,,-20,,.T.)
    Private    oFontBtn   := TFont():New(cFontUti,,-14)
     
    //Criando o cabeçalho da Grid
    //              Título               Campo        Máscara                        Tamanho                   Decimal                   Valid               Usado  Tipo F3     Combo
    aAdd(aHeadSBM, {"Código",            "EE9_PROD",  "",                            TamSX3("EE9_COD_I")[01],   0,                        "",              ".T.", "C", "",    ""} )
    aAdd(aHeadSBM, {"Descrição",         "EE9_DESC",   "",                            TamSX3("EE9_DESC")[01],    0,                        "",       ".T.", "C", "",    ""} )
    aAdd(aHeadSBM, {"Embarque",         "EE9_EMBARQ" , "",                            TamSX3("EE9_PREEMB")[01],  0,                        "", ".T.", "C", "",    ""} )
    aAdd(aHeadSBM, {"Quantidade",       "EE9_QTD", "@E 999,999,999,999.99",                            14,  2,                        "",   ".T.", "N", "",    ""} )
    aAdd(aHeadSBM, {"Sequncia",       "EE9_SEQEMB", "",                            2,  0,                        "",   ".T.", "C", "",    ""} )

    aAdd(aHeadSB, {"Embarque",         "EE9_EMBARQ1" , "",                            TamSX3("EE9_PREEMB")[01],  0,                        "",".T.", "C", "",    ""} )
    aAdd(aHeadSB, {"Código",            "EE9_PROD1",  "",                            TamSX3("EE9_COD_I")[01],   0,  "", ".T.", "C", "",    ""} )
    aAdd(aHeadSB, {"Cod Embalab", "EE9_DESC3",   "",                        20,    0,    "U_AtuCpo(oMsGetSB)",  ".T.", "C", "EE5",    ""} )
    aAdd(aHeadSB, {"Descriçao",         "EE9_DESC1" , "",  100,  0, "", ".T.", "C", "",  ""} )
    aAdd(aHeadSB, {"Cod Int Emba",       "EE5_COD", "",                            6,  0,                        "",   ".T.", "C", "",    ""} )
    aAdd(aHeadSB, {"Qtd Prod",       "EE9_QTD2", "@E 999,999,999,999.99",                            14,  2,                        "U_VLDEMB(oMsGetSB,oMsGetSBM)",   ".T.", "N", "",    ""} )
    aAdd(aHeadSB, {"Peso Bruto",       "EE9_PESO", "@E 999,999,999,999.99",                            14,  2,                        "",   ".T.", "N", "",    ""} )
    aAdd(aHeadSB, {"Sequncia",       "EE9_SEQEMB", "",                            2,  0,                        "",   ".T.", "C", "",    ""} )
    Processa({|| fCarAcols()}, "Processando")
 
    //Criação da tela com os dados que serão informados
    DEFINE MSDIALOG oDlgPvt TITLE "Apontamento Embalagens" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
        //Labels gerais
        @ 004, 003 SAY "Audax"                SIZE 200, 030 FONT oFontAno  OF oDlgPvt COLORS RGB(149,179,215) PIXEL
        @ 004, 063 SAY "Listagem de"        SIZE 200, 030 FONT oFontSub  OF oDlgPvt COLORS RGB(031,073,125) PIXEL
        @ 014, 063 SAY "Embalagens" SIZE 200, 030 FONT oFontSubN OF oDlgPvt COLORS RGB(031,073,125) PIXEL
         
        //Botões
        @ 006, (nJanLarg/2-001)-(0052*01) BUTTON oBtnFech  PROMPT "Fechar"        SIZE 050, 018 OF oDlgPvt ACTION (oDlgPvt:End())                               FONT oFontBtn PIXEL
        @ 006, (nJanLarg/2-001)-(0052*02) BUTTON oBtnLege  PROMPT "Salvar"       SIZE 050, 018 OF oDlgPvt ACTION (fSalvar())                                  FONT oFontBtn PIXEL
       // @ 006, (nJanLarg/2-001)-(0052*03) BUTTON oBtnSalv  PROMPT "Salvar"        SIZE 050, 018 OF oDlgPvt ACTION (fSalvar())                                   FONT oFontBtn PIXEL
         
        //Grid dos grupos
        oMsGetSBM := MsNewGetDados():New(    029,;                //nTop      - Linha Inicial
                                            003,;                //nLeft     - Coluna Inicial
                                            150-3,;     //nBottom   - Linha Final
                                            (nJanLarg/2)-3,;     //nRight    - Coluna Final
                                            GD_INSERT  ,;                   //nStyle    - Estilos para edição da Grid (GD_INSERT = Inclusão de Linha; GD_UPDATE = Alteração de Linhas; GD_DELETE = Exclusão de Linhas)
                                            "AllwaysTrue()",;    //cLinhaOk  - Validação da linha
                                            ,;                   //cTudoOk   - Validação de todas as linhas
                                            "",;                 //cIniCpos  - Função para inicialização de campos
                                            ,;                   //aAlter    - Colunas que podem ser alteradas
                                            ,;                   //nFreeze   - Número da coluna que será congelada
                                            9999,;               //nMax      - Máximo de Linhas
                                            ,;                   //cFieldOK  - Validação da coluna
                                            ,;                   //cSuperDel - Validação ao apertar '+'
                                            ,;                   //cDelOk    - Validação na exclusão da linha
                                            oDlgPvt,;            //oWnd      - Janela que é a dona da grid
                                            aHeadSBM,;           //aHeader   - Cabeçalho da Grid
                                            aColsSBM)            //aCols     - Dados da Grid

        //Grid dos grupos
        oMsGetSB := MsNewGetDados():New(    150,;                //nTop      - Linha Inicial
                                            003,;                //nLeft     - Coluna Inicial
                                            280,;     //nBottom   - Linha Final
                                            (nJanLarg/2)-3,;     //nRight    - Coluna Final
                                            GD_INSERT + GD_UPDATE ,;                   //nStyle    - Estilos para edição da Grid (GD_INSERT = Inclusão de Linha; GD_UPDATE = Alteração de Linhas; GD_DELETE = Exclusão de Linhas)
                                            "AllwaysTrue()",;    //cLinhaOk  - Validação da linha
                                            ,;                   //cTudoOk   - Validação de todas as linhas
                                            "",;                 //cIniCpos  - Função para inicialização de campos
                                            {"EE9_DESC3","EE9_QTD3","EE9_PESO","EE9_QTD2","EE5_COD"},;                   //aAlter    - Colunas que podem ser alteradas
                                            ,;                   //nFreeze   - Número da coluna que será congelada
                                            9999,;               //nMax      - Máximo de Linhas
                                            ,;                   //cFieldOK  - Validação da coluna
                                            ,;                   //cSuperDel - Validação ao apertar '+'
                                            ,;                   //cDelOk    - Validação na exclusão da linha
                                            oDlgPvt,;            //oWnd      - Janela que é a dona da grid
                                            aHeadSB,;           //aHeader   - Cabeçalho da Grid
                                            aColsRB)            //aCols     - Dados da Grid                                    
         
    ACTIVATE MSDIALOG oDlgPvt CENTERED
     
    RestArea(aArea)
Return
 
/*------------------------------------------------*
 | Func.: fCarAcols                               |
 | Desc.: Função que carrega o aCols              |
 *------------------------------------------------*/
 
Static Function fCarAcols()
    Local aArea  := GetArea()
    Local cQry   := ""
    Local nAtual := 0
    Local nTotal := 0
    Local oBmpAux
    Local lPR1 := .T. 
     
   cQry:= "SELECT * FROM "+RetSqlNAme("EE9")+" where EE9_PREEMB = '"+EEC->EEC_PREEMB+"' and D_E_L_E_T_ = ' '
   TCQuery cQry New Alias "QRY_SBM"
     
    //Setando o tamanho da régua

     
    //Enquanto houver dados
    QRY_SBM->(DbGoTop())
    While ! QRY_SBM->(EoF())
     
   
         
        //Adiciona o item no aCols
        aAdd(aColsSBM, { ;
            QRY_SBM->EE9_COD_I,;
            POsicione("SB1",1,xFilial("SB1")+QRY_SBM->EE9_COD_I,"B1_DESC"),;
            QRY_SBM->EE9_PREEMB,;
            QRY_SBM->EE9_SLDINI,;
            QRY_SBM->EE9_SEQEMB,;
            .F.;
        })
 cQry:= "SELECT * FROM "+RetSqlNAme("PR1")+" where PR1_PROD = '"+alltrim(QRY_SBM->EE9_COD_I)+"' and D_E_L_E_T_ = ' ' and PR1_EMBARQ = '"+alltrim(QRY_SBM->EE9_PREEMB)+"' AND PR1_SEQUEN= '"+alltrim(QRY_SBM->EE9_SEQEMB)+"' "
 cQry := ChangeQuery(cQry)
TCQuery cQry New Alias "QRY_PR1"
        QRY_PR1->(DbGoTop())
        While !QRY_PR1->(EOF())
                aAdd(aColsRB, { ;
                QRY_SBM->EE9_PREEMB,;
                QRY_SBM->EE9_COD_I,;
                IIF(!EMPTY(QRY_PR1->PR1_EMBALA),QRY_PR1->PR1_EMBALA,sPACE(20)),;
                IIF(!EMPTY(QRY_PR1->PR1_DSCEMB),QRY_PR1->PR1_DSCEMB,sPACE(100)),;
                IIF(!EMPTY(QRY_PR1->PR1_IDEMB),QRY_PR1->PR1_IDEMB,U_IdEMb()),;
                IIF(!EMPTY(QRY_PR1->PR1_QTDEMB),QRY_PR1->PR1_QTDEMB,QRY_SBM->EE9_SLDINI),;
                IIF(!EMPTY(QRY_PR1->PR1_PSBRUT),QRY_PR1->PR1_PSBRUT, 0.00),;
                QRY_SBM->EE9_SEQEMB,;
                .F.;
                })
          QRY_PR1->(DbSkip())
          lPR1 := .F.
        EndDo
        IF lPR1
                aAdd(aColsRB, { ;
                QRY_SBM->EE9_PREEMB,;
                QRY_SBM->EE9_COD_I,;
                SPACE(20),;
                SPACE(100),;
                 U_IdEMb(),;
                QRY_SBM->EE9_SLDINI,;
                 0.00,;
                QRY_SBM->EE9_SEQEMB,;
                .F.;
                })
        Endif
        QRY_PR1->(DbCloseArea())
        QRY_SBM->(DbSkip())
    EndDo
    QRY_SBM->(DbCloseArea())
     
    RestArea(aArea)
    
Return
 
 
/*--------------------------------------------------------*
 | Func.: fSalvar                                         |
 | Desc.: Função que percorre as linhas e faz a gravação  |
 *--------------------------------------------------------*/
 
Static Function fSalvar()
    Local aColsAux := oMsGetSB:aCols

    Local nLinha   := 0
     
    
     
    //Percorrendo todas as linhas
    For nLinha := 1 To Len(aColsAux)
     DBSelectArea("PR1") 
     PR1->(DBSetOrder(2))
     If !PR1->(DBSeek(xFilial("PR1")+PADR(alltrim(aColsAux[nLinha][1]),TamSx3("PR1_EMBARQ")[1])+PADR(alltrim(aColsAux[nLinha][2]),TamSx3("PR1_PROD")[1])+PADR(alltrim(aColsAux[nLinha][8]),TamSx3("PR1_SEQUEN")[1])+PADR(alltrim(aColsAux[nLinha][5]),TamSx3("PR1_IDEMB")[1])))
        RecLock("PR1",.T.)
        PR1->PR1_FILIAL  :=  xFilial("PR1")
        PR1->PR1_PROD    := alltrim(aColsAux[nLinha][2])
        PR1->PR1_EMBARQ  := alltrim(aColsAux[nLinha][1])
        PR1->PR1_EMBALA  := alltrim(aColsAux[nLinha][3])
        PR1->PR1_DSCEMB  := alltrim(aColsAux[nLinha][4])
        PR1->PR1_IDEMB  := alltrim(aColsAux[nLinha][5])
        PR1->PR1_QTDEMB  := aColsAux[nLinha][6]
        PR1->PR1_PSBRUT  := aColsAux[nLinha][7]
        PR1->PR1_SEQUEN  := alltrim(aColsAux[nLinha][8])
        PR1->(MsUnlock())
      Else
        RecLock("PR1",.F.)
        PR1->PR1_EMBALA  := alltrim(aColsAux[nLinha][3])
        PR1->PR1_DSCEMB  := alltrim(aColsAux[nLinha][4])
        PR1->PR1_IDEMB  := alltrim(aColsAux[nLinha][5])
        PR1->PR1_QTDEMB  += aColsAux[nLinha][6]
        PR1->PR1_PSBRUT  += aColsAux[nLinha][7]
        PR1->(MsUnlock())
      Endif  
   Next 
   MsgInfo("Registro Salvo com Sucesso","Embalagens")
   oDlgPvt:end()
Return



User Function VLDEMB(oMsGetSB,oMsGetSBM)
Local nJ := 0
Local nVltot := 0 
local nFinVal := 0 
LOcal Lret := .T. 
aColsRB[oMsGetSB:oBrowse:nAt][6] := m->EE9_QTD2

For nJ := 1 to Len(aColsRB)
 if alltrim(aColsRB[nj][2]) ==alltrim(aColsRB[oMsGetSBM:oBrowse:nAt][2] ) .and. alltrim(aColsRB[nJ][8]) == alltrim(aColsRB[oMsGetSBM:oBrowse:nAt][8]) 
        nVltot += aColsRB[nj][6]
 EndIF       
Next
 

If nVltot < oMsGetSBM:acols[oMsGetSBM:oBrowse:nAt][4]
      //Adiciona o item no aCols
      cNNN := U_IdEMb(.F.)
        aAdd(aColsRB, { ;
            oMsGetSB:acols[oMsGetSB:oBrowse:nAt][1] ,;
            oMsGetSB:acols[oMsGetSB:oBrowse:nAt][2] ,;
            oMsGetSB:acols[oMsGetSB:oBrowse:nAt][3] ,;
            oMsGetSB:acols[oMsGetSB:oBrowse:nAt][4] ,;
            cNNN,;
             (oMsGetSBM:acols[oMsGetSBM:oBrowse:nAt][4] - nVltot ) ,;
             oMsGetSB:acols[oMsGetSB:oBrowse:nAt][7]  ,;
             oMsGetSB:acols[oMsGetSB:oBrowse:nAt][8]  ,;
            .F.;
        })
               aAdd(oMsGetSB:acols, { ;
            oMsGetSB:acols[oMsGetSB:oBrowse:nAt][1] ,;
            oMsGetSB:acols[oMsGetSB:oBrowse:nAt][2] ,;
            oMsGetSB:acols[oMsGetSB:oBrowse:nAt][3] ,;
            oMsGetSB:acols[oMsGetSB:oBrowse:nAt][4] ,;
            cNNN ,;
            (oMsGetSBM:acols[oMsGetSBM:oBrowse:nAt][4] - nVltot ) ,;
            oMsGetSB:acols[oMsGetSB:oBrowse:nAt][7]  ,;
             oMsGetSB:acols[oMsGetSB:oBrowse:nAt][8]  ,;
            .F.;
        })

ElseIf nVltot > oMsGetSBM:acols[oMsGetSBM:oBrowse:nAt][4]
        oMsGetSB:acols[oMsGetSB:oBrowse:nAt][6]  := oMsGetSB:acols[oMsGetSB:oBrowse:nAt][6]
        Alert('Valor Maior apontado sera considerado valor total do embarque ')
        Lret := .F.
Endif


oMsGetSB:setArray(aColsRB)
oMsGetSB:ForceRefresh()
oDlgPvt:Refresh()
return Lret

User Function AtuCpo(oMsGetSB)
oMsGetSB:acols[oMsGetSB:oBrowse:nAt][4]  :=POsicione("EE5",1,xFilial("EE5")+m->EE9_DESC3,"EE5_DESC")
oMsGetSB:refresh()
return .t.

User Function IdEMb(lFist)

Local cFval := ''
Default lFist := .T. 



If lFist
        cNuber := StrZero(1,6)
Else
        cFval := oMsGetSB:acols[oMsGetSB:oBrowse:nAt][5]

        For nJ := 1 to Len(oMsGetSB:acols)
        if val(cFval) < Val(alltrim(oMsGetSB:acols[nJ][5] )) 
                cFval := oMsGetSB:acols[nj][5]
        EndIF       
        Next
        cNuber := Soma1(cFval)
Endif
Return cNuber

