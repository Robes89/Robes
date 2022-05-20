#include 'Totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc}ECORSE2

Regras para chamada do mï¿½todo

@author Ovio Consultoria
@since 19/06/2019
@version P12 
@param 	
@return	
/*/ 
user function PSR00001()

	Local aSays     	:= {}
	Local aButtons  	:= {}
	Local cCadastro  	:= OemToAnsi("Planilha Itens de notas fiscais. ")
	Local cPerg 		:= "PSR0000001"     
	
	Private npZebrado 	:= 0
	
	AjusPerg(cPerg)
	Pergunte(cPerg,.T.)
	
	AAdd(aSays,OemToAnsi("Planilha Itens de notas fiscais. "	))
	AAdd(aSays,OemToAnsi("Gerar planilha de itens de notas fiscais."               ))
	AAdd(aButtons, { 5,.T.						,{|| Pergunte(cPerg,.T. )				}})
	AADD(aButtons, { 1,.T.						,{|o| (ExecPlan(),o:oWnd:End())   		}})
	AADD(aButtons, { 2,.T.						,{|o| o:oWnd:End()						}})

	FormBatch( cCadastro, aSays,aButtons )

Return

/*/{Protheus.doc}ExecPlan

Regras para chamada do mï¿½todo

@author Ovio Consultoria
@since 19/06/2019
@version P12 
@param 	
@return	
/*/ 

Static Function ExecPlan()

Processa( { ||  GerPlan() } )

Return

/*/{Protheus.doc}GerPlan

Regras para chamada do mï¿½todo

@author Ovio Consultoria
@since 19/06/2019
@version P12 
@param 	
@return	
/*/ 
Static Function GerPlan()

Local cDirTmp   := Alltrim(GetTempPath())
Local cQry		:= ""
Local nRec		:= 0
Local aDados	:= {}
Local cArqOld	:= CriaTrab( NIL, .F. ) + ".xml"
Local cPlan     := "Itens Notas Fiscais"

cQry += "SELECT " 
cQry += "FT_FILIAL,"     //Filial	
cQry += "FT_TIPOMOV,"    //Tipo Mov.	
cQry += "FT_ENTRADA,"    //Data Entrada	
cQry += "FT_EMISSAO,"    //Data Emissão	
cQry += "FT_ESPECIE,"    //Espécie NF	
cQry += "FT_NFISCAL,"    //Doc. Fiscal	
cQry += "FT_SERIE,"      //Série NF	
cQry += "FT_CLIEFOR,FT_LOJA,"    //Cod. Fornecedor / Cod. Cliente	
cQry += "'' NOME,"       //Razao Social	
cQry += "'' CGC,"        //CNPJ / CPF	
cQry += "FT_ESTADO,"     //Estado Ref	
cQry += "FT_TES,"       //Tipo E/S	
cQry += "FT_CFOP,"       //Cod. Fiscal	
cQry += "FT_CODISS ,"    //Cód. Serviço	
cQry += "FT_NATOPER,"    //Natureza	
cQry += "'' DESCNAT,"    //Descrição Natureza
cQry += "FT_PRODUTO,"    //Cod. Produto	
cQry += "FT_ITEM ,"      //Código Item	
cQry += "FT_POSIPI,"     //Cód. NCM	
cQry += "FT_VALCONT,"    //Vlr Contábil	
cQry += "FT_BASEICM,"    //Base ICMS	
cQry += "FT_ALIQICM,"    //Alíq. ICMS	
cQry += "FT_CLASFIS,"    //Sit.Tribut.	
cQry += "FT_VALICM ,"    //Valor ICMS	
cQry += "FT_ISENICM,"    //Vlr Isen ICM	
cQry += "FT_OUTRICM,"    //Vlr Out ICMS	
cQry += "FT_ESTOQUE,"    //Mov. Estoque	
cQry += "FT_OBSERV ,"    //Obs Liv. Fis	
cQry += "FT_CLASFIS,"    //Tipo Lanc	
cQry += "FT_DTCANC ,"    //Data Cancel	
cQry += "FT_FRETE ,"     //Valor Frete	
cQry += "FT_SEGURO,"     //Vlr Seguro	
cQry += "FT_DESPESA,"    //Vlr Despesas	
cQry += "FT_ALIQIRR,"    //Aliq. IRRF	
cQry += "FT_BASEIRR,"    //Base IRRF	
cQry += "FT_VALIRR,"     //Valor IRRF	
cQry += "FT_BASEINS,"    //Base INSS	
cQry += "FT_ALIQINS,"    //Aliq. INSS	
cQry += "FT_VALINS,"     //Valor INSS	
cQry += "FT_QUANT,"      //Quantidade	
cQry += "FT_PRCUNIT,"    //Preço Unit.	
cQry += "FT_DESCONT,"    //Vlr Desconto	
cQry += "FT_TOTAL,"      //Vlr Total	
cQry += "FT_NFORI,"      //NF Original	
cQry += "FT_SERORI,"     //Serie NF Ori	
cQry += "FT_ITEMORI,"    //Item NF Orig	
cQry += "FT_BASEPIS,"    //Base PIS	
cQry += "FT_ALIQPIS,"    //Aliq. PIS	
cQry += "FT_VALPIS ,"    //Valor PIS	
cQry += "FT_BASECOF,"    //Base COFINS	
cQry += "FT_ALIQCOF,"    //Aliq. COFINS	
cQry += "FT_VALCOF ,"    //Valor COFINS	
cQry += "FT_BASECSL,"    //Base CSLL	
cQry += "FT_ALIQCSL,"    //Aliq. CSLL
cQry += "FT_VALCSL ,"    //Valor CSLL	
cQry += "FT_CSTPIS ,"    //CST Pis	
cQry += "FT_CSTCOF ,"    //CST COF	
cQry += "FT_NFELETR,"    //NF Eletr.	
cQry += "FT_CHVNFE ,"    //Chave Nfe	
cQry += "FT_CSTISS"      //Sit.Trib.ISS	
cQry += " FROM "+RetsqlName("SFT")+" SFT "
cQry += " WHERE "
cQry += " FT_FILIAL  >='"+MV_PAR01+"' AND FT_FILIAL  <='"+MV_PAR02+"' AND "
cQry += " FT_EMISSAO >='"+DTOS(MV_PAR03)+"' AND FT_EMISSAO <='"+DTOS(MV_PAR04)+"' AND "
cQry += " FT_ENTRADA >='"+DTOS(MV_PAR06)+"' AND FT_ENTRADA <='"+DTOS(MV_PAR07)+"' AND "

If MV_PAR05==1
    cQry += "FT_TIPOMOV='E' AND "
Elseif MV_PAR05==2
    cQry += "FT_TIPOMOV='S' AND "
Endif    

cQry += " D_E_L_E_T_=' ' "

If Select("TRB") > 0 
	dbSelectArea("TRB")
	dbCloseArea()
Endif

TcQuery cQry New Alias "TRB" 

dbSelectArea("TRB")
dbGotop()

Count to nRec	

ProcRegua(nRec)

oExcel   := FWMsExcelEx():New()
oExcel:AddworkSheet(cPlan)
oExcel:AddTable (cPlan,cPlan)

oExcel:AddColumn(cPlan,cPlan,"Filial"       ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Tipo Mov."    ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Data Entrada" ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Data Emissão" ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Espécie nf"   ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Doc. Fiscal " ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Série NF"     ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Cod. Fornecedor / Cod. Cliente",1,1)
oExcel:AddColumn(cPlan,cPlan,"Razao Social" ,1,1)
oExcel:AddColumn(cPlan,cPlan,"CNPJ / CPF"   ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Estado Ref"   ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Tipo E/S"     ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Cod. Fiscal"  ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Cód. Serviço" ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Natureza"     ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Descrição"    ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Cod. Produto" ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Descrição" ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Código Item"  ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Cód. NCM"     ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Vlr Contábil" ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Base ICMS"    ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Alíq. ICMS"   ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Sit.Tribut."  ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Valor ICMS"   ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Vlr Isen ICM" ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Vlr Out ICMS" ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Mov. Estoque" ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Obs Liv. Fis" ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Tipo Lanc	"   ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Data Cancel"  ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Valor Frete"  ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Vlr Seguro"   ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Vlr Despesas" ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Aliq. IRRF "  ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Base IRRF	"   ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Valor IRRF"   ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Base INSS	"   ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Aliq. INSS"   ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Valor INSS"   ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Quantidade"   ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Preço Unit."  ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Vlr Desconto" ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Vlr Total	"   ,1,1)
oExcel:AddColumn(cPlan,cPlan,"NF Original"  ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Serie NF Ori" ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Item NF Orig" ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Base PIS	"   ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Aliq. PIS	"   ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Valor PIS	"   ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Base COFINS"  ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Aliq. COFINS" ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Valor COFINS" ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Base CSLL	"   ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Aliq. CSLL"   ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Valor CSLL"   ,1,1)
oExcel:AddColumn(cPlan,cPlan,"CST Pis	"   ,1,1)
oExcel:AddColumn(cPlan,cPlan,"CST COF	"   ,1,1)
oExcel:AddColumn(cPlan,cPlan,"NF Eletr.	"   ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Chave Nfe	"   ,1,1)
oExcel:AddColumn(cPlan,cPlan,"Sit.Trib.ISS" ,1,1)

aDados := {}

lPrint := .F.

dbSelectArea("TRB")
dbGotop()
While TRB->(!Eof())

        lPrint := .T.

        cRazao:=""
        cCNPJ :=""
        cNatu :=""

        If Alltrim(TRB->FT_TIPOMOV)=="E"
            dbSelectArea("SA2")
            dbSetOrder(1)
            If dbSeek( xFilial("SA2") + Padr(TRB->FT_CLIEFOR,TamSx3("A2_COD")[1]) + TRB->FT_LOJA )
                cRazao := SA2->A2_NOME
                cCNPJ  := SA2->A2_CGC

                dbSelectArea("SE2")
                dbSetOrder(6)//E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, R_E_C_N_O_, D_E_L_E_T_
                If dbSeek( TRB->FT_FILIAL + Padr(TRB->FT_CLIEFOR,TamSx3("E2_FORNECE")[1]) + Padr(TRB->FT_LOJA,TamSx3("E2_LOJA")[1]) + Padr(TRB->FT_SERIE,TamSx3("E2_PREFIXO")[1]) + Padr(TRB->FT_NFISCAL,TamSx3("E2_NUM")[1]) )
                    cNatu := SE2->E2_NATUREZ
                Endif
            Endif    
        Else
            dbSelectArea("SA1")
            dbSetOrder(1)
            If dbSeek( xFilial("SA1") + Padr(TRB->FT_CLIEFOR,TamSx3("A1_COD")[1]) + TRB->FT_LOJA  )
                cRazao := SA1->A1_NOME
                cCNPJ  := SA1->A1_CGC

                dbSelectArea("SE1")
                dbSetOrder(2)//E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
                If dbSeek( TRB->FT_FILIAL + Padr(TRB->FT_CLIEFOR,TamSx3("E1_CLIENTE")[1]) + Padr(TRB->FT_LOJA,TamSx3("E1_LOJA")[1]) + Padr(TRB->FT_SERIE,TamSx3("E1_PREFIXO")[1]) + Padr(TRB->FT_NFISCAL,TamSx3("E1_NUM")[1]) )
                    cNatu := SE1->E1_NATUREZ
                Endif
            Endif   
        Endif    

        cDescNat :=""
        dbSelectArea("SED")
        dbSetOrder(1)
        if dbSeek(xFilial("SED") + Padr( cNatu ,TamSx3("ED_CODIGO")[1] ) )
            cDescNat := SED->ED_DESCRIC
        endif

        cDescPrd :=""
        dbSelectArea("SB1")
        dbSetOrder(1)
        if dbSeek(xFilial("SB1") + Padr( TRB->FT_PRODUTO ,TamSx3("B1_COD")[1] ) )
            cDescPrd := SB1->B1_DESC
        endif

        aDados := {;
                    TRB->FT_FILIAL,;		//Filial	
                    TRB->FT_TIPOMOV,;		//Tipo Mov.	
                    dtoc(stod(TRB->FT_ENTRADA)),;		//Data Entrada	
                    dtoc(stod(TRB->FT_EMISSAO)),;		//Data Emissão	
                    TRB->FT_ESPECIE,;		//Espécie NF	
                    TRB->FT_NFISCAL,;		//Doc. Fiscal	
                    TRB->FT_SERIE,;	        //Série NF	
                    TRB->FT_CLIEFOR,;		//Cod. Fornecedor / Cod. Cliente	
                    cRazao,;	        	//Razao Social	
                    cCNPJ,;	        	    //CNPJ / CPF	
                    TRB->FT_ESTADO,;		//Estado Ref	
                    TRB->FT_TES,;		    //Tipo E/S	
                    TRB->FT_CFOP   ,;		//Cod. Fiscal	
                    TRB->FT_CODISS ,;		//Cód. Serviço	
                    cNatu,;		            //Natureza	
                    cDescNat,;              //Descrição Natureza
                    TRB->FT_PRODUTO,;		//Cod. Produto	
                    cDescPrd,;              //Descrição
                    TRB->FT_ITEM  ,;		//Código Item	
                    TRB->FT_POSIPI,;		//Cód. NCM	
                    TRB->FT_VALCONT,;		//Vlr Contábil	
                    TRB->FT_BASEICM,;		//Base ICMS	
                    TRB->FT_ALIQICM,;		//Alíq. ICMS	
                    TRB->FT_CLASFIS,;		//Sit.Tribut.	
                    TRB->FT_VALICM ,;		//Valor ICMS	
                    TRB->FT_ISENICM,;		//Vlr Isen ICM	
                    TRB->FT_OUTRICM,;		//Vlr Out ICMS	
                    TRB->FT_ESTOQUE,;		//Mov. Estoque	
                    TRB->FT_OBSERV ,;		//Obs Liv. Fis	
                    TRB->FT_CLASFIS,;		//Tipo Lanc	
                    dtoc(stod(TRB->FT_DTCANC)) ,;		//Data Cancel	
                    TRB->FT_FRETE  ,;		//Valor Frete	
                    TRB->FT_SEGURO,;		//Vlr Seguro	
                    TRB->FT_DESPESA,;		//Vlr Despesas	
                    TRB->FT_ALIQIRR,;		//Aliq. IRRF	
                    TRB->FT_BASEIRR,;		//Base IRRF	
                    TRB->FT_VALIRR,;	    //Valor IRRF	
                    TRB->FT_BASEINS,;		//Base INSS	
                    TRB->FT_ALIQINS,;		//Aliq. INSS	
                    TRB->FT_VALINS ,;		//Valor INSS	
                    TRB->FT_QUANT,;		    //Quantidade	
                    TRB->FT_PRCUNIT,;		//Preço Unit.	
                    TRB->FT_DESCONT,;		//Vlr Desconto	
                    TRB->FT_TOTAL,;		    //Vlr Total	
                    TRB->FT_NFORI,;		    //NF Original	
                    TRB->FT_SERORI,;	    //Serie NF Ori	
                    TRB->FT_ITEMORI,;		//Item NF Orig	
                    TRB->FT_BASEPIS,;		//Base PIS	
                    TRB->FT_ALIQPIS,;		//Aliq. PIS	
                    TRB->FT_VALPIS ,;		//Valor PIS	
                    TRB->FT_BASECOF,;		//Base COFINS	
                    TRB->FT_ALIQCOF,;		//Aliq. COFINS	
                    TRB->FT_VALCOF ,;		//Valor COFINS	
                    TRB->FT_BASECSL,;		//Base CSLL	
                    TRB->FT_ALIQCSL,;		//Aliq. CSLL
                    TRB->FT_VALCSL ,;		//Valor CSLL	
                    TRB->FT_CSTPIS ,;		//CST Pis	
                    TRB->FT_CSTCOF ,;		//CST COF	
                    TRB->FT_NFELETR,;		//NF Eletr.	
                    TRB->FT_CHVNFE ,;		//Chave Nfe	
                    TRB->FT_CSTISS;		    //Sit.Trib.ISS	
            }      
	    oExcel:AddRow(cPlan , cPlan , aDados )

        TRB->(dbSkip())
       
End

If lPrint
	oExcel:Activate()
	oExcel:GetXMLFile( cArqOld )
	If __CopyFile( cArqOld, cDirTmp + cArqOld ) 
		oExcel := MsExcel():New()
		oExcel:WorkBooks:Open( cDirTmp + cArqOld )
		oExcel:SetVisible(.T.)
	Endif
Else
    Aviso("Atenção","Sem dados para os parametros informado",{"Ok"})
Endif		

Return

/*/{Protheus.doc} getAllPos
Funcao para retornar todas as posicoes das colunas da planilha
@author Sergio Celestino
@since 25/06/2018
@version 1.0
@param alColumns, array of logical, array das colunas da planilha
@type function
/*/

Static Function getAllPos( alColumns )

	local alPos := {}
	local nlx
	
	for nlx := 1 to len( alColumns )
		AADD( alPos, nlx )
	next nlx

Return alPos

/*/{Protheus.doc}AjusPerg

Regras para chamada do mï¿½todo

@author Ovio Consultoria
@since 19/06/2019
@version P12 
@param 	
@return	
/*/ 
Static Function AjusPerg(cPerg)

Local aRegs := {}

aAdd(aRegs,{cPerg,"01","Filial De     ?","","","mv_ch1","C",TamSx3("FT_FILIAL")[1]  ,0,0,"G","","MV_PAR01",""         ,"","","","",""        ,"","","","",""     ,"","","","","","","","","","","","","","SM0","","","",""})
aAdd(aRegs,{cPerg,"02","Filial Ate    ?","","","mv_ch2","C",TamSx3("FT_FILIAL")[1]  ,0,0,"G","","MV_PAR02",""         ,"","","","",""        ,"","","","",""     ,"","","","","","","","","","","","","","SM0","","","",""})
aAdd(aRegs,{cPerg,"03","Emissao De    ?","","","mv_ch3","D",TamSx3("FT_EMISSAO")[1] ,0,0,"G","","MV_PAR03",""         ,"","","","",""        ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"","","",""})
aAdd(aRegs,{cPerg,"04","Emissao Ate   ?","","","mv_ch4","D",TamSx3("FT_EMISSAO")[1] ,0,0,"G","","MV_PAR04",""         ,"","","","",""        ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"","","",""})
aAdd(aRegs,{cPerg,"05","Tipo Doc.     ?","","","mv_ch5","N",01                      ,0,0,"C","","MV_PAR05","Entradas" ,"","","","","Saidas" ,"","","","","Todos" ,"","","","","","","","","","","","","",""   ,"","","",""})
aAdd(aRegs,{cPerg,"06","Entrada De    ?","","","mv_ch6","D",TamSx3("FT_EMISSAO")[1] ,0,0,"G","","MV_PAR06",""         ,"","","","",""        ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"","","",""})
aAdd(aRegs,{cPerg,"07","Entrada Ate   ?","","","mv_ch7","D",TamSx3("FT_EMISSAO")[1] ,0,0,"G","","MV_PAR07",""         ,"","","","",""        ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"","","",""})

CriaSx1(aRegs)

Return .T.

/*/{Protheus.doc}CriaSx1

Regras para chamada do mï¿½todo

@author Ovio Consultoria
@since 19/06/2019
@version P12 
@param 	
@return	
/*/ 
Static Function CriaSx1(aRegs)

Local aAreaAtu	:= GetArea()
Local aAreaSX1	:= SX1->(GetArea())
Local nJ		:= 0
Local nY		:= 0

dbSelectArea("SX1")
dbSetOrder(1)

For nY := 1 To Len(aRegs)
	If !MsSeek(aRegs[nY,1]+aRegs[nY,2])
		RecLock("SX1",.T.)
		For nJ := 1 To FCount()
			If nJ <= Len(aRegs[nY])
				FieldPut(nJ,aRegs[nY,nJ])
			EndIf
		Next nJ
		MsUnlock()
	EndIf
Next nY

RestArea(aAreaSX1)
RestArea(aAreaAtu)

Return(Nil)
