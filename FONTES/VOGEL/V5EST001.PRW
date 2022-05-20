#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#include "TOPCONN.CH"
#include "TBICONN.CH" 
#Include "RwMake.ch"

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±∫Programa  ≥ D0IMPORT    ∫ Autor ≥ Denis Varella  Data ≥ 16/09/2017     ∫±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±∫Descricao ≥ ImportaÁ„o de Mensagem do cliente                          ∫±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±∫Uso       ≥ Protheus 12 - EspecÌfico para a empresa Premiada			  ∫±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹*/ 

User Function NBEXECC7()
Local oProcess 		:= NIL

Private cArquivo    := SEL_ARQ()       


If !empty(cArquivo)  
		oProcess 		:= MsNewProcess():New( {|| RunProcess( @oProcess , cArquivo ) } , "Importando Registros" , "Andamento da ImportaÁ„o" , .F. )
		oProcess:Activate()   
EndIF
return

//Input do arquivo CSV
Static Function SEL_ARQ()

Local cNewPathArq   := cGetFile( "Arquivo CSV (*.CSV)|*.CSV|", "Selecione o Arquivo",,, .T., GETF_NETWORKDRIVE + GETF_LOCALHARD)

Return(cNewPathArq)

static function RunProcess( oProcess , cArquivo )

Local aCols 	:= {}
Local aCampos   := {}
Local aVetor	:= {}
Local aVetorAux	:= {}
Local aErro 	:= {}
Local aCSV		:= {}
Local cErro		:= ""
Local cCampo	:= ""
Local nPosCod	:= 0
Local nX		:= 0
Local nY		:= 0
Local nLinha    := 0
Local aItens := {}
Local aItem := {}  
Local aCab := {}
Local nPrim   := 1


Private lMsErroAuto 	:= .T.
Private lMsHelpAuto 	:= .F.
Private lAutoErrNoFile 	:= .T.
Private oBtBrw
Private cPath:=""    
Private _CFolder :=Space(50)
Private _cType			:=	"Arquivos CSV|*.CSV|Todos os Arquivos|*.*"
Private oDlg


aCSV := cArquivo
       
//Quebra as linhas do CSV e as grava em array de cabeÁalho e corpo
FT_FUSE(aCSV)
do While !FT_FEOF()
	cLinha := FT_FREADLN()
	cLinha := strtran(cLinha , ',', '.' ) 
	If nPrim <= 1
		aAdd(aCampos, Separa(cLinha,";",.T.))
		nPrim += 1
	Else
		aAdd(aCols, Separa(cLinha,";",.T.))
	EndIf
	FT_FSKIP()
	
enddo     
If nPrim == 2	

Begin Transaction  
		ProcRegua(Len(aCols))
		For i:=1 to Len(aCols) 
			
            DbSelectArea("SB8")
            SB8->(DBSeek(""))
            
            aVetor :=   {;
            {"B7_FILIAL" , xFilial("SB7"),Nil},;
            {"B7_COD",aCols[i][2],Nil},; // Deve ter o tamanho exato do campo B7_COD, pois faz parte da chave do indice 1 da SB7
            {"B7_DOC",aCols[i][1],Nil},;
            {"B7_QUANT",aCols[i][3],Nil},;
            {"B7_LOCAL",aCols[i][4],Nil},;
            {"B7_LOTECTL",aCols[i][5],Nil},; 
            {"B7_DTVALID",STOD(aCols[i][6]),Nil},;
            {"B7_LOCALIZ",aCols[i][7],Nil},;
            {"B7_NUMSERI",aCols[i][8],Nil},;// Deve ter o tamanho exato do campo B7_LOCAL, pois faz parte da chave do indice 1 da SB7
            {"B7_DATA",Date(),Nil} } // Deve ter o tamanho exato do campo B7_DATA, pois faz parte da chave do indice 1 da SB7
              
MSExecAuto({|x,y,z| mata270(x,y,z)},aVetor,.T.,3)
If lMsErroAuto
    MostraErro()
    ConOut(OemToAnsi("Erro!"))
Else
    ConOut(OemToAnsi("AtualizaÁ„o realizada com Íxito!")) 
EndIf
		Next i
	End Transaction
	 
        
	 

EndIf

return 