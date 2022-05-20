#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch"
#include "TbiConn.ch"



User Function OPCPP03()
Local cArquivo := ''  


//If Select("SM0") == 0
	
//EndIf
cArquivo := cGetFile()
If Empty(cArquivo)
	MsgAlert("Atenção, informe um arquivo válido antes de prosseguir com a importação.")
	Return Nil
EndIf
Processa({ || VREARQUI(cArquivo) })

Return Nil



Static Function VREARQUI(cArquivo)

Local cLinha	:= ""
Local lPrim		:= .T.
Local aCampos	:= {}
Local aDados	:= {}
local i := 0
// Abertuta do Arquivo
FT_FUse(cArquivo)
ProcRegua(FT_FLastRec())
FT_FGoTop()
// Alimentando os Arrays
While !FT_FEof()
	IncProc("Lendo arquivo CSV...")
	cLinha := FT_FREADLN()
	If lPrim
		aCampos := Separa(cLinha,";",.T.)
		lPrim := .F.
	Else
		aAdd(aDados, Separa(cLinha,";",.T.) )
	EndIf
	FT_FSKip()
End
// Apresento a mensagem se coluna diferente

// Montando o array conforme Contrato

// Gravo as tabelas conforme array
ProcRegua(Len(aDados))

dbSelectArea("SD3")


For i := 1 to Len(aDados)
	CriaD3(aDados[i])
Next

RETURN

Static Function CriaD3(aFim)

Local aCab := {}
Local aItem := {}

Default aItem := {} 
	
	cDoc	:= GetSxENum("SD3","D3_DOC",1)
	
	Begin Transaction
		
	//  Fazer a REQUISICAO do Lote Anterior (produto (-) usando TM NOVA 700
	
	lMsErroAuto := .F.
	
	aCab := {	{"D3_DOC"    	, cDoc    	,  	Nil},;
				{"D3_TM"     	, aFim[1]     ,  	Nil},;
				{"D3_CC"     	, " "       ,  	Nil},;
				{"D3_EMISSAO"	, ddatabase ,  	Nil}}
	
	
			aadd(aItem,{{"D3_TM"      	, aFim[1]   ,  	Nil},;
				{"D3_COD"      	,aFim[2]     ,  	Nil},;
				{"D3_CUSTO1"     , val(aFim[3] )  ,  	Nil},;
				{"D3_LOCAL"     , aFim[4]    ,  	Nil},;
				{"D3_EMISSAO"	, ddatabase ,  	NIL}})
		
	MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab,aItem,3)
	
	If lMsErroAuto
		DisarmTransaction()
		MostraErro()
	EndIf
		
		
	End Transaction

Return
