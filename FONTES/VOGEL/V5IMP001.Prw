#include "rwmake.ch"
#include "topconn.ch"
#include "Colors.ch"
#include "Font.ch"
#include "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"

//Constantes
#Define STR_PULA		Chr(13)+Chr(10)

User Function V5IMP001()

	Private oLeTxt                         // Janela de Dialogo
	Private Arquivo 	:= Space(40)           // Arquivo Texto Selecionado
	Private cArqTRB 	:= " "                  // Arquivo de Trabalho Temporario
	Private cArqEdi 	:= " "                  // Arquivo Texto a Processar
	Private cArqCop 	:= " "                  // Arquivo de Copia
	Private lGeraprv	:= " "
	Private dDataprv	:= " "
	Private lExec		:= .T.
	Private _nTot   	:= 0
	Private _cType  	:= " "
	Private _cPerg   	:= "PSCSVPED"
	Private _cPath     	:= ''
	Private _cFile     	:= ''
	Private _cEOL      	:= "CHR(13)+CHR(10)"
	Private aRegs  	   	:= {}
	Private aHelpPor   	:= {}

	Define MsDialog oDlga Title "Tranferencia Armazens Multiplas" From 0,0 To 250,530 Pixel
	Define Font oBold Name "Arial" Size 0,-13 Bold

	@ 000,000 Bitmap oBmp ResName "LOGIN" Of oDlga Size 30, 120 NoBorder When .F. Pixel
	@ 010,060 Say OemtoAnsi("Esta rotina tem como objetivo ler um arquivo EXCEL e gerar")   Font oBold SIZE 200,09 PIXEL
	@ 020,060 Say OemtoAnsi("Movimentações Multiplas no sistema Protheus.					   ")   Font oBold SIZE 200,09 PIXEL
	@ 030,060 Say OemtoAnsi(" ")   															Font oBold SIZE 200,09 PIXEL
	@ 040,060 Say OemtoAnsi(" ")   															Font oBold SIZE 200,09 PIXEL
	@ 090,060 Say OemtoAnsi("Arquivo selecionado : ")  										Font oBold SIZE 200,09 PIXEL
	@ 090,140 Say +_cFile							  										Font oBold SIZE 200,09 PIXEL
	@ 105,070 Button "Sel.Arquivo" Size 40,13 Pixel Of oDlga Action fSelArq()
	@ 105,120 Button "Transferir" Size 40,13 Pixel Of oDlga Action Processa({||U_MyMata261(1),,"Tranferindo. Aguarde..."})
    @ 105,170 Button "Excluir" Size 40,13 Pixel Of oDlga Action Processa({||U_MyMata261(5),,"Excluindo. Aguarde..."})
	@ 105,220 Button "Sair"        Size 40,13 Pixel Of oDlga Action oDlga:End()

	Activate MsDialog oDlga Centered

Return


Static Function fSelArq()

	Private _cType := " "

	_cType := "*.CSV | *.csv"
	_cFile := cGetFile(_cType, OemToAnsi("Selecione arquivo no formato CSV a ser importado..."))

	If Empty(_cFile)
		Return
	EndIf

	nHdl := fopen(_cFile,0)
	_nTot:= fSeek(nHdl,0,2)

	fClose(nHdl)

	If _nTot <= 0
		Aviso("","Arquivo corrompido ou já está sendo utilizado em outro processo. ",{"OK"},2,"Problema...")
	EndIf

Return


User Function MyMata261(nOpc)
Local aAuto := {}
Local aItem := {}
Local aLinha := {}
/*
É necessario que:
O parametro MV_LOCALIZ = S
O produto com codigo PA001 tenha controle de endereco ativo
O armazem padrao definido no produto deve ter 2 endereços: ENDER01 e ENDER02
Saldo inicial igual ou superior a 1
E este saldo deve ser enderecçado ao ENDER01
*/
Local aLista := {'PA001','PA001'} //Os produtos a serem utilizados
Local nX
Local nOpcAuto := 0
Local cDocumen := ""
Local lContinua := .T.
Local aCampoSC6			:= SD3->(DbStruct())
Local aTxt := {} 
Local aAuto := {}
Local aVetor := {}
local nHandle := 0
Local aLog := {}
Private lMsErroAuto := .F.



//Cabecalho a Incluir
cDocumen := GetSxeNum("SD3","D3_DOC")
aadd(aAuto,{cDocumen,dDataBase}) //Cabecalho

//Itens a Incluir
aItem := {}

aPosCampos:= Array(Len(aCampoSC6))
If IsBlind()
__cuserid := '000309'
EndIf
FT_FUse(_cFile)
FT_FGOTOP()

cLinha 	:= FT_FREADLN()
nPos	:=	0
nAt		:=	1

While nAt > 0

    nPos++
    nAt	:=	AT(";",cLinha)

    If nAt == 0
        cCampo := cLinha
    Else
        cCampo	:=	Substr(cLinha,1,nAt-1)
    Endif

    nPosCpo	:=	aScan( aCampoSC6, { |x| x[1] == cCampo } )

    If nPosCPO > 0
        aPosCampos[nPosCpo]:= nPos
    Endif

    cLinha	:=	Substr(cLinha,nAt+1)

Enddo

FT_FSKIP()

While !FT_FEOF()

    cLinha := FT_FREADLN()

    aAdd(aTxt,{})

    nCampo := 1

    While At(";",cLinha)>0

        aAdd(aTxt[Len(aTxt)],Substr(cLinha,1,At(";",cLinha)-1))
        nCampo ++
        cLinha := StrTran(Substr(cLinha,At(";",cLinha)+1,Len(cLinha)-At(";",cLinha)),'"','')
    End

    If Len(AllTrim(cLinha)) > 0
        aAdd(aTxt[Len(aTxt)],StrTran(Substr(cLinha,1,Len(cLinha)),'"','') )
    Else
        aAdd(aTxt[Len(aTxt)],"")
    Endif

    FT_FSKIP()

EndDo

FT_FUSE()
If nOpc == 1
    for nX := 1 to len(aTxt) 
        aAuto := {}
        lMsErroAuto := .F. 
        DbSelectArea("SB1")
        DbSetOrder(1) 
        SB1->(DbSeek(xFilial("SB1")+PadR(aTxt[nX][1], tamsx3('D3_COD') [1])))
        DbSelectArea('SB9')
        DbSetOrder(1)
        If !DBSeek(xFilial("SB9")+SB1->B1_COD + '98' )      
            aVetor :={;
                {"B9_FILIAL", xFilial('SB9'), Nil},;
                {"B9_COD",  SB1->B1_COD  ,         Nil},;
                {"B9_LOCAL", Padr(aTxt[nX][10],Tamsx3("B1_LOCPAD")[1]) ,             Nil},;
                {"B9_DATA",   Date(),           Nil},;
                {"B9_QINI",   0,              Nil};
            }
            
            //Iniciando transação e executando saldos iniciais
            Begin Transaction
                MSExecAuto({|x, y| Mata220(x, y)}, aVetor, 3)
                
                //Se houve erro, mostra mensagem
                If lMsErroAuto
                
                EndIf
            End Transaction
        EndIf
        aAuto := {}
        cDocumen := GetSxeNum("SD3","D3_DOC")
        aadd(aAuto,{cDocumen,dDataBase})
        aLinha := {}
        //Origem
    
        aadd(aLinha,{"ITEM",'001',Nil})
        aadd(aLinha,{"D3_COD", SB1->B1_COD, Nil}) //Cod Produto origem
        aadd(aLinha,{"D3_DESCRI", SB1->B1_DESC, Nil}) //descr produto origem
        aadd(aLinha,{"D3_UM", SB1->B1_UM, Nil}) //unidade medida origem
        aadd(aLinha,{"D3_LOCAL", Padr(aTxt[nX][3],Tamsx3("B1_LOCPAD")[1]), Nil}) //armazem origem
        aadd(aLinha,{"D3_LOCALIZ", PadR(aTxt[nX][4], tamsx3('D3_LOCALIZ') [1]),Nil}) //Informar endereÃ§o origem
        
        //Destino
        SB1->(DbSeek(xFilial("SB1")+PadR(aTxt[nX][8], tamsx3('D3_COD') [1])))
        aadd(aLinha,{"D3_COD", SB1->B1_COD, Nil}) //cod produto destino
        aadd(aLinha,{"D3_DESCRI", SB1->B1_DESC, Nil}) //descr produto destino
        aadd(aLinha,{"D3_UM", SB1->B1_UM, Nil}) //unidade medida destino
        aadd(aLinha,{"D3_LOCAL", Padr(aTxt[nX][10],Tamsx3("B1_LOCPAD")[1]), Nil}) //armazem destino
        aadd(aLinha,{"D3_LOCALIZ", PadR(aTxt[nX][11], tamsx3('D3_LOCALIZ') [1]),Nil}) //Informar endereÃ§o destino
        
        aadd(aLinha,{"D3_NUMSERI", PadR(aTxt[nX][12], tamsx3('D3_NUMSERI') [1]), Nil}) //Numero serie
        aadd(aLinha,{"D3_LOTECTL", PadR(aTxt[nX][6], tamsx3('D3_LOTECTL') [1]), Nil}) //Lote Origem
        aadd(aLinha,{"D3_NUMLOTE", "", Nil}) //sublote origem
        aadd(aLinha,{"D3_DTVALID", Ctod(''), Nil}) //data validade
        aadd(aLinha,{"D3_POTENCI", 0, Nil}) // Potencia
        aadd(aLinha,{"D3_QUANT", Val(aTxt[nX][7]) , Nil}) //Quantidade
        aadd(aLinha,{"D3_QTSEGUM", 0, Nil}) //Seg unidade medida
        aadd(aLinha,{"D3_ESTORNO", "", Nil}) //Estorno
        aadd(aLinha,{"D3_NUMSEQ", "", Nil}) // Numero sequencia D3_NUMSEQ
        
        aadd(aLinha,{"D3_LOTECTL", PadR(aTxt[nX][6], tamsx3('D3_LOTECTL') [1]), Nil}) //Lote destino
        aadd(aLinha,{"D3_NUMLOTE", "", Nil}) //sublote destino
        aadd(aLinha,{"D3_DTVALID", Ctod(''), Nil}) //validade lote destino
        aadd(aLinha,{"D3_ITEMGRD", "", Nil}) //Item Grade
        
        aadd(aLinha,{"D3_CODLAN", "", Nil}) //cat83 prod origem
        aadd(aLinha,{"D3_CODLAN", "", Nil}) //cat83 prod destino
        
        aAdd(aAuto,aLinha)
        nOpcAuto := 3 // Inclusao
        MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcAuto)

        if lMsErroAuto
            mostraerro("C:\vogel\",SB1->B1_COD+'.log')
        else
        //
            ConfirmSx8()
            conout("Inclusão de movimentação multipla efetuada com sucesso")
            lContinua := .T.
        EndIf
    Next nX

Else
     for nX := 1 to len(aTxt) 
    
        //-- Preenchimento dos camposP
        aAuto := {}
        aadd(aAuto,{"D3_DOC", aTxt[nx][1] , Nil})
        aadd(aAuto,{"D3_COD", PadR(aTxt[nX][2], tamsx3('D3_COD') [1]), Nil})
        
        DbSelectArea("SD3")
        DbSetOrder(2)
        DbSeek(xFilial("SD3")+aTxt[nx][1]+PadR(aTxt[nX][2], tamsx3('D3_COD') [1]))
    
        //-- Teste de Estorno
        nOpcAuto := 6 // Estornar
        MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcAuto)
        
        If lMsErroAuto
            mostraerro("C:\vogel\",aTxt[nx][1]+'.log')
        Else
           
        EndIf

    Next nX

EndIF 


MsgAlert("Processo Concluido","Finalização")



Return