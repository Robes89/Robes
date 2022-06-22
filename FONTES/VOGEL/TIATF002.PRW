#INCLUDE "Protheus.ch"	
#include "rwmake.ch"
#include "TOTVS.ch"
#include "TBICONN.ch"

#DEFINE LOGDIRECTORY 'C:\temp\'

#DEFINE STR0001 'Atenção! '
#DEFINE STR0002 'Não foi possivel realizar a baixa da NFe: '
#DEFINE STR0003	'Baixa: '
#DEFINE STR0004 ' -> Gerada com sucesso...'
#DEFINE STR0005 ' item '

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
	Local aCamposN3   As Array
	Local aDados    As Array
	Local aCab		As Array
	Local aAtivo 	As Array
	Local aParam  	As Array
	Local aLogAuto	As Array
	Local lPrim      := .T.
	Local lSegung	:=.T.
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

		If lPrim .Or. lSegung//considerando que a primeira linha são os campos do cadastros, reservar numa variavel
			
			IF lPrim
				lPrim  :=.F.	
				aCampos := Separa(cLinha,";",.T.)
			Else
				lSegung  := .F.
				aCamposN3 := Separa(cLinha,";",.T.)
			EndIF
			

			
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
      dIndDepr := RetDinDepr(dDataBase)
	For nX :=1 To len(adados)
      aCab := {}
      AAdd(aCab,{"N1_CBASE"   ,   adados[nx,nBase]   ,NIL})
      AAdd(aCab,{"N1_ITEM"    , adados[nx,nItem]       ,NIL})
      AAdd(aCab,{"N1_AQUISIC" , dDataBase ,NIL})
      AAdd(aCab,{"N1_DESCRIC" , adados[nx,nDescric]   ,NIL})
      AAdd(aCab,{"N1_QUANTD"  , adados[nx,nQtd]      ,NIL})
      AAdd(aCab,{"N1_CHAPA"   , adados[nx,nChapa]      ,NIL})
      AAdd(aCab,{"N1_PATRIM"  , adados[nx,nChapa]     ,NIL})
	  AAdd(aCab,{"N1_GRUPO"  , adados[nx,nGrupo]     ,NIL})

      //adicione aqui os campos desejados

      aItens := {}
      //-- Preenche item 1
      AAdd(aItens,{{"N3_CBASE"   , adados[nx,nBase]       ,NIL},;
                  {"N3_ITEM"    , adados[nx,nItem]       ,NIL},;
                  {"N3_TIPO"    , "01"       ,NIL},;
                  {"N3_TPSALDO"   , "1"         ,NIL},;
                  {"N3_HISTOR"  ,  adados[nx,nDescric]     ,NIL},;
                  {"N3_VORIG1"  , adados[nx,nValor]      ,NIL}})
                  //adicione acima os campos desejados
	Next nX
      //Controle de transacao
      Begin Transaction

        conOut('Inicio da rotina Automatica '+ Time())
        MSExecAuto({|x,y,z| Atfa012(x,y,z)},aCab,aItens,3,aParam)
        conOut('FIM' +Time())

        If lMsErroAuto 
             MostraErro()
             DisarmTransaction()
        else
          ConfirmSx8()
          conOut('INCLUIDO ATIVO N3_CBASE: '+ cBase + ", N3_ITEM : "+cItem+ ", N3_CUSTBEM : "+cCusto+ ", N3_SUBCCON : "+cSubCon+ ", N3_CLVLCON : "+cClvlCon)
        ENDIF    

        RestArea(aArea)
      End Transaction

      //Modificando campos para segunda execução
      cCusto  :="CENTR0002"
      cSubCon :="000000002"
      cClvlCon:="000000002"

    

  RESET ENVIRONMENT

Return
