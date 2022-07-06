#INCLUDE "Protheus.ch"

#DEFINE LOGDIRECTORY 'C:\temp\'

#DEFINE STR0001 'Atenção! '
#DEFINE STR0002 'Não foi possivel realizar a baixa da NFe: '
#DEFINE STR0003	'Baixa: '
#DEFINE STR0004 ' -> Gerada com sucesso...'
#DEFINE STR0005 ' item '

User Function TIATF001()
	Local aArea      := GetArea()
	Local cTitulo    := "Baixa automatica de Ativos"
	Local nOpcao     := 0
	Local aButtons     := {}
	Local aSays        := {}
	Private cPerg       := "TIATF001"
	Private cArquivo:= ""
	Private oProcess
	Private lMsErroAuto := .F.
	Private cMOtivo := ''

	//Função que cria as perguntas
	
	Pergunte(cPerg,.F.)
	AADD(aSays,OemToAnsi("Esta rotina gera a baixa automatica dos ativos"))
	AADD(aSays,"")
	AADD(aSays,OemToAnsi("Clique no botão PARAM para informar os parametros que deverão ser considerados."))
	AADD(aSays,"")
	AADD(aSays,OemToAnsi("Após isso, clique no botão OK."))
	AADD(aButtons, { 1,.T.,{|o| nOpcao:= 1,o:oWnd:End()} } )
	AADD(aButtons, { 2,.T.,{|o| nOpcao:= 2,o:oWnd:End()} } )
	AADD(aButtons, { 5,.T.,{| | pergunte(cPerg,.T.)  } } )
	FormBatch( cTitulo, aSays, aButtons,,200,530 )
	if nOpcao = 1
		cArquivo:= Alltrim(MV_PAR01)
		if Empty(cArquivo)
			MsgStop("Informe o nome do arquivo!!!","Erro")
			return
		Endif
		oProcess := MsNewProcess():New( { || Importa() } , "Realizando a importação das Baixas." , "Aguarde..." , .F. )
		oProcess:Activate()

	EndIf
	RestArea(aArea)
Return

Static Function Importa()
	Local cTipo 	:= "01"

	Local nQtdBaixa := 1
	Local cMotivo 	:= "  "
	Local cLinha 	:= ""
	Local cMetDepr 	:= GetMV('MV_ATFDPBX')
	Local aArea 	:= GetArea()
	Local cView		As Character
	Local cBase 	As Character
	Local cItem 	As Character
	Local cCliente	As Character
	Local cLjCli	As Character
	Local cNumNFProd	As Character
	Local cTes		As Character
	Local cNumNF  	As Character
	Local cSerieNF 	As Character
	Local cArquivoLog	As Character
	Local nPercBx	As Numeric
	local nValNf    As Numeric
	Local nTotalItem  	As Numeric
	Local nCont 	As Numeric
	Local i			As Numeric
	Local dTbaixa 	As Date
	Local aCampos   As Array
	Local aDados    As Array
	Local aCab		As Array
	Local aAtivo 	As Array
	Local aParam  	As Array
	Local aLogAuto	As Array
	Local lPrim      := .T.
	Local cArquivoLog	As Character
	Local nCont 	As Numeric
	Local aCampos   As Array



	Local aErroPlan := {}
	local nX as Numeric


	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.
	Private aErro      := {}

	If !File(cArquivo)
		MsgStop("O arquivo " + cArquivo + " não foi encontrado. A importação será abortada!","ATENCAO")
		Return
	EndIf
	FT_FUSE(cArquivo) //Abre o arquivo texto
	oProcess:SetRegua1(FT_FLASTREC()) //Preenche a regua com a quantidade de registros encontrados
	FT_FGOTOP() //coloca o arquivo no topo

	nCont := 1

	aCampos := {}
	aDados  := {}

	While !FT_FEOF()
		nCont++
		oProcess:IncRegua1('Validando Linha: ' + Alltrim(Str(nCont)))

		cLinha := FT_FREADLN()
		cLinha := ALLTRIM(cLinha)

		If lPrim //considerando que a primeira linha são os campos do cadastros, reservar numa variavel
			aCampos := Separa(cLinha,";",.T.)
			lPrim := .F.
		Else// gravar em outra variavel os registros
			AADD(aDados,Separa(cLinha,";",.T.))
		EndIf

		FT_FSKIP()
	EndDo
	FT_FUSE()

	//utilizaremos a aScan para localizar a posição dos campos na variavel que armazenará o nome dos campos
	cNumNF		:= aScan(aCampos,{ |x| ALLTRIM(x) == "NFE" })
	cSerieNF	:= aScan(aCampos,{ |x| ALLTRIM(x) == "SERIE" })
	cItemNf		:= aScan(aCampos,{ |x| ALLTRIM(x) == "N6_CITEM" })
	cCliente	:= aScan(aCampos,{ |x| ALLTRIM(x) == "COD_CLIENTE" })
	cLjCli		:= aScan(aCampos,{ |x| ALLTRIM(x) == "LJ_CLIENTE" })
	dTbaixa		:= aScan(aCampos,{ |x| ALLTRIM(x) == "N6_DTBAIX" })
	cNumNFProd	:= aScan(aCampos,{ |x| ALLTRIM(x) == "N6_CBASE" })
	nQtdBaixa	:= aScan(aCampos,{ |x| ALLTRIM(x) == "QTD_BAIXA" })
	nTotalItem	:= aScan(aCampos,{ |x| ALLTRIM(x) == "VALOR_BAIXA" })
	cTes		:= aScan(aCampos,{ |x| ALLTRIM(x) == "TES" })
	cCondPag	:= aScan(aCampos,{ |x| ALLTRIM(x) == "COND_PAG" })
	cMOtivo	:= aScan(aCampos,{ |x| ALLTRIM(x) == "N6_MOTIVO" })
	

	oProcess:SetRegua1(len(aDados)) //guardar novamente a quantidade de registros

	For i:=1 to Len(aDados)
		oProcess:IncRegua1("Realizando a Baixa ativo:")

		nQuant := VAL(aDados[i,nQtdBaixa])
		cView   := GetNextAlias()

		BeginSQL Alias cView
			SELECT 
				SN1.N1_CBASE,
				SN1.N1_FILIAL,
				SN1.N1_ITEM,
				SN1.N1_QUANTD,
				ROUND(((%exp:nQuant% / SN1.N1_QUANTD)*100),2) AS PORCENT
			FROM %Table:SN1% SN1	
			WHERE ROWNUM = 1
			AND SN1.N1_FILIAL = %exp:cFilAnt% 
			AND SN1.N1_CBASE = %exp:aDados[i,cNumNFProd]%
			AND SN1.N1_ITEM =  %exp:aDados[i,cItemNf]%
			AND SN1.N1_QUANTD >= %exp:nQuant%
			AND SN1.%notDel%
		EndSQL

		DbselectArea(cView)
		(cView)->(DbGoTop())
		cBase 	:= (cView)->N1_CBASE
		cItem 	:= (cView)->N1_ITEM
		nQtnAtual := (cView)->N1_QUANTD
		nPercBx := (cView)->PORCENT
		cFil := (cView)->N1_FILIAL
	

		(cView)->(dbCloseArea())

		


	SaveInter()


	SN3->(DbSetOrder(1))
	SN1->(DbSetOrder(1))
	aParam  := {}
	aAdd( aParam, {"MV_PAR01", 2} )
	aAdd( aParam, {"MV_PAR02", 2} )
	aAdd( aParam, {"MV_PAR03", 1} )
	If SN1->(DBSeek( xFilial("SN1",cFil) + cBase+ cItem ))
		If SN3->(DBSeek(xFilial("SN3",cFil)+ cBase+ cItem ))

		


				aCab := {}

			
		
					
			aCab := {	{"FN6_FILIAL"	,xFilial("SN3",cFil)	,NIL},;
								{"FN6_CBASE"	,cBase			,NIL},;
								{"FN6_CITEM"	,cItem			,NIL},;
								{"FN6_MOTIVO"	,aDados[i,cMOtivo]					,NIL},;
								{"FN6_QTDATU"	,nQtnAtual			,NIL},;
								{"FN6_BAIXA"	,nPercBx				,NIL},;
								{"FN6_QTDBX"	,	Val(aDados[i,nQtdBaixa])				,NIL},;
								{"FN6_DTBAIX"	,CTOD(aDados[i,dTbaixa])				,NIL},;
								{"FN6_PERCBX"	,nPercBx				,NIL},;
								{"FN6_GERANF"	,"2"		,NIL},;
								{"FN6_FILORI"	,cFil		,NIL},;
								{"FN6_NUMNF"	,	aDados[i,cNumNF]				,NIL},;
								{"FN6_SERIE"	,	aDados[i,cSerieNF]		,NIL},;
								{"FN6_VALNF"	,Val(aDados[i,nValNf])				,NIL},;	  
								{"FN6_DEPREC"	,cMetDepr				,NIL}}

		
				MemoWrite("c:\temp\acab.html",  VarInfo("aCab", aCab))
				
				
				aAtivo := {}

				aAtivo := {{'N3_FILIAL',	cFil,		NIL},; //FILIAL
				{'N3_CBASE',		cBase,			NIL},; //COD. BEM
				{'N3_ITEM',		cItem,		NIL},; //ITEM BEM
				{'N3_TIPO',		cTipo,			NIL},; //TIPO
				{'N3_BAIXA',		"0",			NIL},; //BAIXA
				{'N3_TPSALDO',	SN3->N3_TPSALDO,		NIL}} //TIPO DE SALDO

				MemoWrite("c:\temp\aAtivo.html", VarInfo("aAtivo", aAtivo))

	

				//Utilizar o MsExecAuto para incluir registros nas tabelas
				//MsExecAuto({|a,b,c,d,e,f|ATFA036(a,b,c,d,e,f)},aCab,aAtivo,3,,.T./*lBaixaTodos*/,aParam)
				MsExecAuto({|a,b,c,d|ATFA036(a,b,c,,,d)},aCab,aAtivo,3,aParam)
				//Caso encontre erro grava log
				IF lMsErroAuto
				IF !ExistDir(LOGDIRECTORY)
						MakeDir(LOGDIRECTORY)
				EndIF
				cArquivoLog	:= StrZero(Val(aDados[i,nBase]),9)+'-'+aDados[i,nItem]
				aLogAuto    := {}
				cLogAuto    := MostraErro("\x_erros\", "nome_do_arquivo")
				
				Aadd(aErroPlan, {cArquivoLog,cLogAuto})
				
				cLogAuto:= ''
					       
        ENDIF  
	  End Transaction  
	Next i
        RestArea(aArea)
   
    
  	If !Empty(aErroPlan) .and. MsgYesNo("Foram encontrados erros deseja gerar relatorio Xml ?","") 
		U_TIATFREL(aErroPlan)
 	EndIF
Return

