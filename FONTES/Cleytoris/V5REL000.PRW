#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#DEFINE CRLF		chr(13)+Chr(10)

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
User Function V5REL000()
	FwMsgRun(,{|oSay|U_V5RELGER(oSay)}, "Buscando dados","Aguarde"	)
Return

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

User Function V5RELGER(oSay)

Local cAliasTst := GetNextAlias()
Local cAliasTR:= GetNextAlias()
Local lCliente := .F.
Local aExcel:= {}
LOcal nJ:= 0 
Local aOrdField := {} 
Local dDTde := ddatabase -1
Local dDTate := ddatabase
Local cArquivo  := ""
Local oExcel    := FWMsExcelEx():New()
Local cAba      := "Posição Clientes"
Local cTitAba   := "Posição Clientes"
Local oExcelMs  := MsExcel():New()
Local aLinha    := {}
Local cAlTrb	:=  ""
Local lDados	:= .F.
Local nI		:= 0


Local aBoxParam	:= {}
Local aRetParam	:= {}

Aadd(aBoxParam, {1, "Data de : "					, dDTde        , ""	       , ""           ,"" , ".T.", 80, .F.})//1
Aadd(aBoxParam, {1, "Data Ate: "					, dDTate       , ""		   , ""           ,"" , ".T.", 80, .T.})//2
	
	aAdd(aOrdField,{'A1_COD','Codigo Cliente','C'})
	aAdd(aOrdField,{'A1_NOME','Razão Social','C'})
	aAdd(aOrdField,{'A1_CGC'	,'CNPJ','C'})
	aAdd(aOrdField,{'A1_XSEGMEN','Segmento','C'})
	aAdd(aOrdField,{'E1_FILORIG'	,'Filial de faturamento','C'})
	aAdd(aOrdField,{'E1_NOMEFIL'	,'Filial de faturamento','C'})
	aAdd(aOrdField,{'E1_EMISSAO','Data de emissão','D'})
	aAdd(aOrdField,{'E1_VENCREA','Data de Vencimento','D'})
    aAdd(aOrdField,{'E1_PREFIXO','Prefixo','C'})
	aAdd(aOrdField,{'E1_NUM','Número do Título','C'})
    aAdd(aOrdField,{'E1_SALDO','Valor Aberto','N'})
	
	IF ParamBox(aBoxParam, "Posição Primero Paga", @aRetParam)

		oExcel:AddworkSheet(cAba)
		oExcel:AddTable (cAba,cTitAba)
		oSay:SetText("Montando colunas")
		ProcessMessage()

		For nI:= 1 to len(aOrdField)
			cColumns :=aOrdField[nI][2]
			IF aOrdField[nI][3] $"C|D"
				oExcel:AddColumn(cAba,cTitAba, cColumns,1,1)
				IF (Alltrim(aOrdField[nI][1])=="FILIAL")
					oExcel:AddColumn(cAba,cTitAba, "Empresa",1,1)
				EndIF
			ElseIF aOrdField[nI][3]=="N"
				oExcel:AddColumn(cAba,cTitAba,cColumns,1,3)
			EndIF
		Next nI
		cArquivo:=cGetFile("Arquivos XLS (*.xls) |*.xls|","Informe o arquivo", 0, "C:\", .T., GETF_LOCALHARD + GETF_LOCALFLOPPY + GETF_NETWORKDRIVE)
		cQuery:=getQry(aRetParam)
		oSay:SetText("Aplicando Filtros Selecionados")
		ProcessMessage()
		cAlTrb:= GetNextAlias()
		IF !Empty(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlTrb,.T.,.T.)
			dbSelectArea(cAlTrb)

			While !(cAlTrb)->( Eof() )
				oSay:SetText("Lendo Dados  CLIENTE "+(cAlTrb)->A1_NOME )
				ProcessMessage()
				aLinha 	:=	{}
				For nI:= 1 to len(aOrdField)
					IF aOrdField[nI][3] $ "C"
						IF aOrdField[nI][1] == "E1_NOMEFIL"
							aAdd(aLinha,Posicione("SM0",1,"V5"+(cAlTrb)->E1_FILORIG,"M0_ESTENT"))
						Else
							aAdd(aLinha,(cAlTrb)->&(aOrdField[nI][1]) )	
						EndIF	
					ElseIF aOrdField[nI][3]=="D"
						aAdd(aLinha,DTOC(sToD((cAlTrb)->&(aOrdField[nI][1]))))
					ElseIF aOrdField[nI][3]=="N"
						aAdd(aLinha,(cAlTrb)->&(aOrdField[nI][1]))
					EndIF

				Next nI

				oExcel:AddRow(cAba,cTitAba,aLinha )
				lDados:=.T.

				(cAlTrb)->( dbSkip() )
			EndDo
			(cAlTrb)->(dbCloseArea())
			oSay:SetText("Salvando arquivos"  )
			ProcessMessage()
			if lDados
				//Criando o XML
				oExcel:Activate()
				oExcel:GetXMLFile(cArquivo)
				//Abrindo o excel e abrindo o arquivo xml
				oExcelMs:WorkBooks:Open(cArquivo)     //Abre uma planilha
				oExcelMs:SetVisible(.T.)                 //Visualiza a planilha
				oExcelMs:Destroy()                        //Encerra o processo do gerenciador de tarefas

				MsgInfo("Relatorio Gerado no Caminho ("+cArquivo+")")
			else

				MsgInfo("Nao ha dados conforme o filtro selecionado")
			EndIF
		Else
			MsgInfo("Nao ha dados conforme o filtro selecionado")
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
 Static Function getQry(aRetParam)


Local cAliasTst := GetNextAlias()
Local cAliasTR:= GetNextAlias()
Local lCliente := .F.
Local aExcel:= {}
LOcal nJ:= 0 
Local aOrdField := {} 
Local dDTde := ddatabase -1
Local dDTate := ddatabase
 lOCAL cCliente := ''
cQey :=  "SELECT DISTINCT E1_CLIENTE,E1_LOJA FROM "+RetSqlName("SE1") + " where E1_BAIXA = ' ' and E1_VENCREA  between '"+dtos(aRetParam[1])+"' and  '"+dtos(aRetParam[2])+"' and E1_TIPO IN ('NF','BOL') and D_E_L_E_T_ = ' ' "

dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQey),cAliasTst, .F., .T.)


While !(cAliasTst)->(EOF())
cQry2:=  "SELECT Distinct F2_DOC,F2_SERIE,F2_EMISSAO FROM "+RetSqlName("SF2") + " SF2 INNER JOIN "+RetSqlName("SD2") + " SD2 ON F2_DOC = D2_DOC AND D2_SERIE = F2_SERIE AND D2_FILIAL = F2_FILIAL and  SD2.D_E_L_E_T_ = ' '"
cQry2 +=  " INNER JOIN "+RetSqlName("SF4") + "  SF4 ON D2_TES = F4_CODIGO AND F4_DUPLIC ='S'  and SF4.D_E_L_E_T_ = ' ' "
cQry2 +=  " WHERE  F2_CLIENTE = '"+(cAliasTst)->E1_CLIENTE+"' AND F2_LOJA = '"+(cAliasTst)->E1_LOJA+"' and  SF2.D_E_L_E_T_ = ' '  ORDER BY  F2_EMISSAO"
If Select((cAliasTR)) > 0
 (cAliasTR)->(DBCloseArea())
EndIF 
dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQry2),cAliasTR, .F., .T.)
cEmissao := SubStr((cAliasTR)->F2_EMISSAO,1,6)
    While !(cAliasTR)->(EOF())
            IF cEmissao == SubStr((cAliasTR)->F2_EMISSAO,1,6)
                lCliente := .T.
            Else 
                 lCliente := .F.
                exit
            EndIF       
        (cAliasTR)->(DbSkip())
    EnDDo  
        IF lCliente
            AAdd(aExcel,(cAliasTst)->E1_CLIENTE)
        EndIF
    (cAliasTst)->(DbSkip())
EnDDo  

 For nJ := 1 to len(aExcel)
   cCliente +=  aExcel[nj] + '/'
 NExt
if !eMPTY(cCliente)
 cCliente := FormatIn(cCliente,'/')
else
 cCliente := "('')"   
EndIF
 cQQQ := "SELECT A1_NOME,A1_CGC,A1_XSEGMEN,A1_COD,E1_FILORIG,E1_VENCREA,E1_EMISSAO,E1_PREFIXO,E1_NUM,E1_SALDO FROM "+RETSQLNAME("SE1")+" INNER JOIN "+RETSQLNAME("SA1")+" A1 ON "
 cQQQ += " A1_LOJA = E1_LOJA and A1_COD = E1_CLIENTE where E1_CLIENTE in "+cCliente+" and "+RETSQLNAME("SE1")+".D_E_L_E_T_ = ' ' and E1_LOJA = '01' and E1_SALDO > 0 and E1_TIPO IN ('NF','BOL')  order by A1_NOME"
Return cQQQ