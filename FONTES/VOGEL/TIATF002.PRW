#INCLUDE "Protheus.ch"	
#include "rwmake.ch"
#include "TOTVS.ch"
#include "TBICONN.ch"
#INCLUDE "SHELL.CH"

#DEFINE LOGDIRECTORY 'C:\temp\'

#DEFINE STR0001 'Atenção! '
#DEFINE STR0002 'Não foi possivel realizar a baixa da NFe: '
#DEFINE STR0003	'Baixa: '
#DEFINE STR0004 ' -> Gerada com sucesso...'
#DEFINE STR0005 ' item '

/*---------------------------------------------------------------------------------*
 | Func.: TIATF002                                                                 |
 | Autor: TRIYO  		                                                           |
 | Data:  25/06/2022                                                               |
 | Desc:  Função que Importa ativos em lote 					                   |
 *---------------------------------------------------------------------------------*/

User Function TIATF002()
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
	AADD(aSays,OemToAnsi("Esta rotina gera a Inclusao automatica dos ativos"))
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
		oProcess := MsNewProcess():New( { || Importa() } , "Realizando a importação das Inclusoes." , "Aguarde..." , .F. )
		oProcess:Activate()

	EndIf
	RestArea(aArea)
Return


/*---------------------------------------------------------------------------------*
 | Func.: Importa                                                                  |
 | Autor: TRIYO  		                                                           |
 | Data:  25/06/2022                                                               |
 | Desc:  Função que Importa ativos em lote 					                   |
 *---------------------------------------------------------------------------------*/

Static Function Importa()

	Local aArea 	:= GetArea()
	Local cArquivoLog	As Character
	Local nCont 	As Numeric
	Local aCampos   As Array

	Local aDados    As Array
	Local aCab		As Array
	Local aParam  	As Array
	Local aLogAuto	As Array
	Local lPrim      := .T.
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
				lPrim:=.F.
		Else// gravar em outra variavel os registros
			AADD(aDados,Separa(cLinha,";",.T.))
		EndIf

		FT_FSKIP()
	EndDo
	FT_FUSE()

	//utilizaremos a aScan para localizar a posição dos campos na variavel que armazenará o nome dos campos


	oProcess:SetRegua1(len(aDados)) //guardar novamente a quantidade de registros

    /*lançamento para inclusao de mais Ativos 
    ----------------------------------------------*/
    //Quantos registros serão incluídos

	aArea := GetArea()

	nBase   := aScan(aCampos,{ |x| ALLTRIM(x) == "N1_CBASE" })
	nItem   := aScan(aCampos,{ |x| ALLTRIM(x) == "N1_ITEM" })
	nChapa  := aScan(aCampos,{ |x| ALLTRIM(x) == "N1_PATRIM" })
	nqtd:= aScan(aCampos,{ |x| ALLTRIM(x) == "N1_QUANTD" })
	nDescric:=aScan(aCampos,{ |x| ALLTRIM(x) == "N1_DESCRIC" }) 
	nGrupo := aScan(aCampos,{ |x| ALLTRIM(x) == "N1_GRUPO" })
	nValor  :=  aScan(aCampos,{ |x| ALLTRIM(x) == "N1_VLAQUIS" })
	nAqui    :=  aScan(aCampos,{ |x| ALLTRIM(x) == "N1_AQUISIC" }) 
 	nForn :=  aScan(aCampos,{ |x| ALLTRIM(x) == "N1_FORNEC" })  
	nLoja := aScan(aCampos,{ |x| ALLTRIM(x) == "N1_LOJA" })   
	nSerie := aScan(aCampos,{ |x| ALLTRIM(x) == "N1_NSERIE" })  
	nFiscal := aScan(aCampos,{ |x| ALLTRIM(x) == "N1_NFISCAL" })   
	nCodAnt :=  aScan(aCampos,{ |x| ALLTRIM(x) == "N1_XCODANT" }) 
	nHisto := aScan(aCampos,{ |x| ALLTRIM(x) == "N3_HISTOR" })  
	nDtIni := aScan(aCampos,{ |x| ALLTRIM(x) == "N3_DINDEPR" })  
	nVorig1 := aScan(aCampos,{ |x| ALLTRIM(x) == "N3_VORIG1" }) 



      dIndDepr := RetDinDepr(dDataBase)
	For nX :=1 To len(adados)
		aCab := {}
		AAdd(aCab,{"N1_CBASE"   ,   adados[nx,nBase]   ,NIL})
		AAdd(aCab,{"N1_ITEM"    , adados[nx,nItem]       ,NIL})
		AAdd(aCab,{"N1_AQUISIC" , CTOD(adados[nx,nAqui] ) ,NIL})
		AAdd(aCab,{"N1_DESCRIC" , adados[nx,nDescric]   ,NIL})
		AAdd(aCab,{"N1_QUANTD"  , val(adados[nx,nQtd])      ,NIL})
		AAdd(aCab,{"N1_CHAPA"   , adados[nx,nChapa]      ,NIL})
		AAdd(aCab,{"N1_PATRIM"  , 'N'    ,NIL})
		AAdd(aCab,{"N1_GRUPO"  , adados[nx,nGrupo]     ,NIL})
		AAdd(aCab,{"N1_VLAQUIS"  , val(adados[nx,nValor])      ,NIL})
      	AAdd(aCab,{"N1_FORNEC"   , adados[nx,nForn]      ,NIL})
      	AAdd(aCab,{"N1_LOJA"  , adados[nx,nLoja]    ,NIL})
	  	AAdd(aCab,{"N1_NSERIE"  , adados[nx,nSerie]     ,NIL})
		aAdd(aCab,{"N1_NFISCAL"  , adados[nx,nFiscal]      ,NIL})
      	//AAdd(aCab,{"N1_XCODANT"   , adados[nx,nCodAnt]      ,NIL})
     

			
      //adicione aqui os campos desejados

      aItens := {}
      //-- Preenche item 1
      AAdd(aItens,{{"N3_CBASE"   , adados[nx,nBase]       ,NIL},;
                  {"N3_ITEM"    , adados[nx,nItem]       ,NIL},;
                  {"N3_TIPO"    , "01"       ,NIL},;
                  {"N3_TPSALDO"   , "1"         ,NIL},;
                  {"N3_HISTOR"  ,  adados[nx,nHisto]     ,NIL},;
                  {"N3_VORIG1"  , val(adados[nx,nVorig1])      ,NIL},;
				  {"N3_DINDEPR"  , CTOD(adados[nx,nDtIni])      ,NIL}})
                  //adicione acima os campos desejados
	
      //Controle de transacao
      Begin Transaction

        conOut('Inicio da rotina Automatica '+ Time())
        MSExecAuto({|x,y,z| Atfa012(x,y,z)},aCab,aItens,3,aParam)
        conOut('FIM' +Time())

        If lMsErroAuto 
             	IF !ExistDir(LOGDIRECTORY)
						MakeDir(LOGDIRECTORY)
				EndIF
				cArquivoLog	:= StrZero(Val(aDados[nx,nBase]),9)+'-'+aDados[nx,nItem]
				aLogAuto    := {}
				cLogAuto    := MostraErro("\x_erros\", "nome_do_arquivo")
				
				Aadd(aErroPlan, {cArquivoLog,cLogAuto})
				
				cLogAuto:= ''
					       
        ENDIF  
	  End Transaction  
	Next nX
        RestArea(aArea)
   
    
  	If !Empty(aErroPlan) .and. MsgYesNo("Foram encontrados erros deseja gerar relatorio Xml ?","") 
		U_TIATFREL(aErroPlan)
 	EndIF
Return

/*---------------------------------------------------------------------------------*
 | Func.: TIATFREL                                                                 |
 | Autor: TRIYO  		                                                           |
 | Data:  25/06/2022                                                               |
 | Desc:  Função que Imprime relatorio generico sobre erros na importação          |
 *---------------------------------------------------------------------------------*/

User Function TIATFREL(aErroPlan)

Local oExcel    := FWMSEXCEL():New()
Local nW := 0 
Local cNomeArq  := GetNextAlias() + '.XML'

Default aErroPlan := {}


oExcel:AddworkSheet("Erro Ativo")
oExcel:AddTable ("Erro Ativo","Erro Ativo")

oExcel:AddColumn("Erro Ativo","Erro Ativo","Ativo",1,1)
oExcel:AddColumn("Erro Ativo","Erro Ativo","Erro",1,1)
For nW := 1 to Len(aErroPlan)	
	oExcel:AddRow("Erro Ativo","Erro Ativo", { aErroPlan[nW,1],;
											aErroPlan[nW,2]})
Next	
	
	
	//FClose(nHandle)
	
	If !Empty(oExcel:aWorkSheet)

		oExcel:Activate()
		oExcel:GetXMLFile(cNomeArq)
		CpyS2T( cNomeArq, GetTempPath(.T.), .T. ) 
		ShellExecute( "OPEN", "EXCEL", GetTempPath(.T.)  + cNomeArq, "", SW_SHOWMAXIMIZED )
		CpyS2T("\SYSTEM\"+cNomeArq, LOGDIRECTORY  )

	EndIf

Return
