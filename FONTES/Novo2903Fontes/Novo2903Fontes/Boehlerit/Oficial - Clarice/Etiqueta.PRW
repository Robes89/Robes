#include "rwmake.ch"
#include 'protheus.ch'
#include 'parmtype.ch'
#include "rwmake.ch"
#INCLUDE 'TBICONN.CH'
 

// Rotina		: ETIQUETA
// Descrição	: Etiqueta de Produtos
// Data			: 23/03/05
// Autor        : Daniel Gondran 
// Alterado     : Clarice Kun

#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF


User Function ETIQUETA()

//If Aviso(" Atenção ", " Informe o Tipo de Impressora !",{ "Datamax","Outras"},,,,"BMPPERG") == 1
   u_Etiq02()
//Else 
//   u_Etiq01()
//Endif   
Return

User Function ETIQ01()
Private nLi			:= 1
CbCont		:= 0
CbTXT		:= Space( 10 )
Tamanho  	:= "M"
titulo   	:= "Etiqueta de Produto"
cDesc1   	:= "Emissão da Etiqueta de Produto"
cDesc2   	:= ""
cDesc3   	:= ""
cString  	:= "SB2"
wnrel	 	:= "ETIQUETA"
aReturn		:= { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
nLastKey 	:= 0
cPerg		:= PadR( "ETIQUE" , Len( SX1->X1_GRUPO ) )
NomeProg	:= "ETIQUE"

VerPerg()

Pergunte( cPerg , .F. )
wnrel	:= SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,{""},.F.,Tamanho)

If nLastKey = 27
	Set Filter to
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Set Filter to
	Return
Endif

RptStatus({|lEnd| Imprime(@lEnd,wnRel,cString,tamanho,titulo)},titulo)

Return NIL

*-------------------------------------------------------------------------------------------------------------------

Static Function Imprime(lEnd,WnRel,cString,tamanho,titulo)

local kkk

dbSelectArea("SA7")
SA7->( DbSetOrder( 2 ) )

dbSelectArea("SA1")
SA1->( DbSetOrder( 1 ) )

dbSelectArea("SB1")
dbOrderNickName("CODLMT")
dbSeek(xFilial("SB1") + mv_par01)


/*
IF SB1->B1_MSBLQL == "1"
	MsgBox( "Produto Bloqueado." , "Sem permissão de utilização..." , "STOP" )
	RETURN
ENDIF
*/

//// Alterado para não pegar produtos Bloqueados com o mesmo código LMT
IF SB1->B1_MSBLQL == "1"
    While  B1_CODLMT=mv_par01  .and.  !EOF()
             IF SB1->B1_MSBLQL == "1"
		         SB1->(DbSkip())
			     LOOP
             Endif
             exit
	Enddo	
Endif

IF  SB1->B1_CODLMT<>mv_par01 .or.  SB1->B1_MSBLQL == "1"  .or.  EOF()
	    MsgBox( "Produto Bloqueado ou não encontrado." , "Sem permissão de utilização..." , "STOP" )
	    RETURN
ENDIF
 

ProcRegua(mv_par03)
For kkk :=1 to mv_par03
	
	IncProc()

	nLI += 3
	@ nLI , 001 PSAY  mv_par01 
	nLI	+= 1
	@ nLI , 001 PSAY SB1->B1_COD + "   Quantidade : " + AllTrim(Str(mv_par04,6,0))
	nLI	+= 1
//	@ nLI , 001 PSAY "Cliente : " + mv_par02
//	nLI	+= 1         
	If Left(SB1->B1_COD,2) == "KI"
		@ nLI , 001 PSAY SB1->B1_DENOM
	Else
		@ nLI , 001 PSAY SB1->B1_DESC
	Endif
	nLI	+= 1
	@ nLI , 001 PSAY  mv_par05
	nLI	+= 1
	@ nLI , 001 PSAY  "OP : " + TransForm( mv_par06 , "@R XXXXXX-XX-XXX" )
	If	!Empty( mv_par02 )
		SA1->( DbSeek( xFilial( "SA1" ) + mv_par02 ) )
		If	SA7->( DbSeek( xFilial( "SA7" ) + SB1->B1_COD + SA1->( A1_COD + A1_LOJA ) ) )
			nLI	+= 1
			@ nLI , 001 PSAY "PRODUTO NO CLIENTE: " + SA7->A7_CODCLI
			nLI	+= 1
		EndIf
	Else
		nLI	+= 2
	EndIf
Next

Set Device to Screen
If aReturn[ 5 ] == 1
	Set Printer To 
	OurSpool(wnrel)
EndIf
SetPgEject(.F.)
MS_FLUSH()
Return

*-------------------------------------------------------------------------------------------------------------------
Static Function VerPerg()
Local nXX      := 0
aPerg    := {}

Aadd( aPerg , { "Codigo LMT         ?" , "C" , TamSX3( "B1_CODLMT" )[1] , 00 , "G" , "" , "" , "" , "" , "" , "SB1LMT" } )
aAdd( aPerg , { "Cliente            ?" , "C" , 06 , 00 , "G" , "" , "" , "" , "" , "" , "SA1" } )
aAdd( aPerg , { "Quant Etiquetas    ?" , "N" , 06 , 00 , "G" , "" , "" , "" , "" , "" , "" } )
aAdd( aPerg , { "Quant Pecas        ?" , "N" , 06 , 00 , "G" , "" , "" , "" , "" , "" , "" } )
aAdd( aPerg , { "Observação         ?" , "C" , 40 , 00 , "G" , "" , "" , "" , "" , "" , "" } )
aAdd( aPerg , { "Nº da OP           ?" , "C" , 11 , 00 , "G" , "" , "" , "" , "" , "" , "SC2" } )

For nXX := 1 to Len( aPerg )
	If !SX1->( DbSeek( cPerg + StrZero( nXX , 2 ) ) )
		RecLock( "SX1" , .T. )
		SX1->X1_GRUPO	:= cPerg
		SX1->X1_ORDEM	:= StrZero( nXX , 2 )
		SX1->X1_VARIAVL	:= "mv_ch"  + Chr( nXX + 96 )
		SX1->X1_VAR01	:= "mv_par" + Strzero( nXX , 2 )
		SX1->X1_PRESEL	:= 1
		SX1->X1_PERGUNT	:= aPerg[ nXX , 01 ]
		SX1->X1_TIPO	:= aPerg[ nXX , 02 ]
		SX1->X1_TAMANHO	:= aPerg[ nXX , 03 ]
		SX1->X1_DECIMAL	:= aPerg[ nXX , 04 ]
		SX1->X1_GSC		:= aPerg[ nXX , 05 ]
		SX1->X1_DEF01	:= aPerg[ nXX , 06 ]
		SX1->X1_DEF02	:= aPerg[ nXX , 07 ]
		SX1->X1_DEF03	:= aPerg[ nXX , 08 ]
		SX1->X1_DEF04	:= aPerg[ nXX , 09 ]
		SX1->X1_DEF05	:= aPerg[ nXX , 10 ]
		SX1->X1_F3		:= aPerg[ nXX , 11 ]
		SX1->( MsUnlock() )
	EndIf
Next nXX
Return


//////////////////////////////////////////////////////////////////////////////////

 

User Function  ETIQ02()

public nLi		  := 1
CbCont	     	 := 0
CbTXT		     := Space( 10 )
Tamanho  	   := "M"
titulo   	        := "Etiqueta de Produto"
cDesc1   	     := "Emissão da Etiqueta de Produto"
cDesc2   	     := ""
cDesc3   	     := ""
cString  	      := "SB2"
wnrel	 	      := "ETIQUETA"
aReturn		     := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
nLastKey 	    := 0
cPerg	          := PadR( "ETIQUE" , Len( SX1->X1_GRUPO ) )
NomeProg	  := "ETIQUE"

VerPerg()

while .T. 
 

if !Pergunte( cPerg , .T. )
   exit
Endif

u_imp_dtx()
 

Enddo


Return  

*-------------------------------------------------------------------------------------------------------------------

User Function Imp_Dtx()    
Local nx:=1
Local cTexto1:=' '
Local cTexto2:=' '
Local cTexto3:=' '
Local cTexto4:=' '
Local cTexto5:=' '
Local cTexto6:=' '


dbSelectArea("SA7")
SA7->( DbSetOrder( 2 ) )

dbSelectArea("SA1")
SA1->( DbSetOrder( 1 ) )

dbSelectArea("SB1")
dbSetOrder(18)
dbSeek(xFilial("SB1") + mv_par01 ) 
 
 
//// Alterado para não pegar produtos Bloqueados com o mesmo código LMT
IF SB1->B1_MSBLQL == "1"
    While  B1_CODLMT=mv_par01  .and.  !EOF()
             IF SB1->B1_MSBLQL == "1"
		         SB1->(DbSkip())
			     LOOP
             Endif
             exit
	Enddo	
Endif

IF  SB1->B1_CODLMT<>mv_par01 .or.  SB1->B1_MSBLQL == "1"  .or.  EOF()
	    MsgBox( "Produto Bloqueado ou não encontrado." , "Sem permissão de utilização..." , "STOP" )
	    RETURN
ENDIF
 
 
ctexto1:=SB1->B1_CODLMT   ///  Descrição LMT

If Left(SB1->B1_COD,2) == "KI"
    cTexto2:=SB1->B1_DENOM         
else   
    cTexto2:=SB1->B1_DESC            
Endif
 
cTexto2:=SB1->B1_COD                /// Código do Produto

cTexto3:="Quantidade:  "+AllTrim(Str(mv_par04,6,0))    /// Quantidade
  
cTexto4:="Nr. OP : " + TransForm( mv_par06 , "@R XXXXXX-XX-XXX" )   ///Nr OP

If	!Empty( mv_par02 )
		SA1->( DbSeek( xFilial( "SA1" ) + mv_par02 ) )
		If	SA7->( DbSeek( xFilial( "SA7" ) + SB1->B1_COD + SA1->( A1_COD + A1_LOJA ) ) )
 			 cTexto5:="PRODUTO NO CLIENTE: " + SA7->A7_CODCLI      ///  Código do Cliente
 		EndIf
EndIf 

if len(alltrim(mv_par05)) <>0
   cTexto6:=mv_par05                          ///// Observação
Endif   

 

//////////////////////////////////////  

If MsgYesNo("A impressora está pronta?")
    
    // CONFIGURA A IMPRESSORA
   
	MSCBPRINTER("DMX",'LPT1',,,.f.,,,,) /// Configura e define a porta na impressora Zebra S-600
 
    MSCBCHKSTATUS(.F.)
  
   
For nx:=1 to mv_par03

  //Codigo gerado no ZebraDesigner

  /*	
    MSCBWrite("CT~~CD,~CC^~CT~")
	MSCBWrite("^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR4,4~SD24^JUS^LRN^CI0^XZ")
    MSCBWrite("^XA")
    MSCBWrite("^MMT")	
	MSCBWrite("^PW599")	
	MSCBWrite("^LL0240")	
	MSCBWrite("^LS0")
    MSCBWrite("^FO416,0^GFA,01920,01920,00020,:Z64:")
    MSCBWrite("eJxjYBg2gP8/CmgYFRtgsT/yQOY/CEWk2MGD1BX7Dxdj/s//w47hjxz/n4MNMDHGP8wf5BhsZBg/IMQYChgfsDHISDAeICBmwHiAiUFGgAFJTMLA8WATi4xAwkGEWyQUPhxs4qG52AEmoBgDbcUO/gOK1RMhRlW/gcIUTQwc9hD3HUCJIx4ZCYJiNcwgMRlGJDHmf+w/7Hhk5JgPHvxBv/wxCkYBAwABgoUq:7E27")
    MSCBWrite("^FO48,77^GB515,0,2^FS")	
	MSCBWrite("^FT48,67^A0N,25,24^FH\^FDBoehlerit Brasil Ferramentas Ltda^FS")	
	MSCBWrite("^FO48,116^GB515,0,2^FS")
    MSCBWrite("^FT48,108^A0N,20,19^FH\^FD"+cTexto1+"^FS")    /// nome
    MSCBWrite("^FT48,148^A0N,20,19^FH\^FD"+cTexto2+"^FS")	////  codigo
	MSCBWrite("^FT424,148^A0N,20,19^FB139,1,0,R^FH\^FD"+cTexto3+"^FS")	 /// quantidade
	MSCBWrite("^FT48,172^A0N,20,19^FH\^FD"+cTexto4+"^FS")	 ///Nr . Op
	MSCBWrite("^FT48,196^A0N,20,19^FH\^FD"+cTexto5+"^FS")    /// codigo cliente
	MSCBWrite("^FT424,196^A0N,20,19^FB137,1,0,R^FH\^FDData:  "+dtoc(date())+"^FS")   ///data
	if len(alltrim(cTexto6))<>0
       MSCBWrite("^FT48,220^A0N,20,19^FH\^FD"+cTexto6+"^FS")   /// observacao
	Endif   
    MSCBWrite("^PQ1,0,1,Y^XZ")	
  */

	
    MSCBWrite("CT~~CD,~CC^~CT~")
	MSCBWrite("^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR4,4~SD24^JUS^LRN^CI0^XZ")
    MSCBWrite("^XA")
    MSCBWrite("^MMT")	
	MSCBWrite("^PW599")	
	MSCBWrite("^LL0240")	
	MSCBWrite("^LS0")
    MSCBWrite("^FO416,11^GFA,01920,01920,00020,:Z64:")
    MSCBWrite("eJxjYBg2gP8/CmgYFRtgsT/yQOY/CEWk2MGD1BX7Dxdj/s//w47hjxz/n4MNMDHGP8wf5BhsZBg/IMQYChgfsDHISDAeICBmwHiAiUFGgAFJTMLA8WATi4xAwkGEWyQUPhxs4qG52AEmoBgDbcUO/gOK1RMhRlW/gcIUTQwc9hD3HUCJIx4ZCYJiNcwgMRlGJDHmf+w/7Hhk5JgPHvxBv/wxCkYBAwABgoUq:7E27")
    MSCBWrite("^FO48,89^GB515,0,2^FS")	
	MSCBWrite("^FT48,79^A0N,25,24^FH\^FDBoehlerit Brasil Ferramentas Ltda^FS")	
	MSCBWrite("^FO48,119^GB515,0,2^FS")
    MSCBWrite("^FT48,114^A0N,20,19^FH\^FD"+cTexto1+"^FS")    /// nome
    MSCBWrite("^FT48,148^A0N,20,19^FH\^FD"+cTexto2+"^FS")	////  codigo
	MSCBWrite("^FT424,148^A0N,20,19^FB139,1,0,R^FH\^FD"+cTexto3+"^FS")	 /// quantidade
	MSCBWrite("^FT48,172^A0N,20,19^FH\^FD"+cTexto4+"^FS")	 ///Nr . Op
	MSCBWrite("^FT48,196^A0N,20,19^FH\^FD"+cTexto5+"^FS")    /// codigo cliente
	MSCBWrite("^FT424,196^A0N,20,19^FB137,1,0,R^FH\^FDData:  "+dtoc(date())+"^FS")   ///data
	if len(alltrim(cTexto6))<>0
       MSCBWrite("^FT48,220^A0N,20,19^FH\^FD"+cTexto6+"^FS")   /// observacao
	Endif   
    MSCBWrite("^PQ1,0,1,Y^XZ")	

    
    // FINALIZA IMPRESSAO
    MSCBEND()


	next nx

    //Encerra conexão impressora
    MSCBClosePrinter()
 

Endif	
Return


  

