#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"



//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
//±±³Programa  ³MTASF2    ³ Autor ³                       ³ Data ³ 08.05.07 ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Descri‡…o ³Depois da gravacao do cabecalho,grava msg                   ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Retorno   ³ lRet - Logico                                              ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Parametros³Nenhum                                                      ³±±
//±±³          ³                                                            ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Uso       ³MATA460 DOCUMENTO DE SAIDA                                  ³±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

User Function MTASF2()                                  

Local	oMens1 
Local	oMens2 
Local	oMens3 
Local	oMens4 
Local	oMens5 
Local Mens      := SF2->F2_MENS_P
Local lPri := .t.
Local aMens := {}

Private Mens1     := space(45)
Private Mens2     := space(45)
Private Mens3     := space(45)
Private Mens4     := space(45)
Private Mens5     := space(45)                     

Private cMensSC5  := ""
Private cMensNF   := ""      
Private oDlgp	
Private oDlgp1	


//************************************************************************************************************
SA1->(DBSETORDER(1))
SA1->(DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))   	 

SD2->(DBSETORDER(3))
SD2->(DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))   	 

While SD2->(!EOF()) .And. xFilial("SF2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA = xFilial("SD2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA

	 SC5->(DbSetOrder(1))
     if SC5->(Dbseek(xFilial("SC5")+SD2->D2_PEDIDO))
     
        if ascan(aMens,SD2->D2_PEDIDO) = 0

			cMensSC5  := IIF(!Empty(SC5->C5_MENNOTA),Alltrim(SC5->C5_MENNOTA)+" ","")
			aadd(aMens,SD2->D2_PEDIDO)
			
		Endif	
     
     Endif

     If !Empty(SD2->D2_NFORI)
         
     	if lPri         
			cMensNF := IIF(SF2->F2_TIPO="C","Compl.Preco Ref.NF:",IIF(SF2->F2_TIPO="D","Devol.Ref.NF:","Ret.NF:"))    	
			lPri := .f.
     	endif
     	nReg:=SD2->(Recno())    
     	citem := SD2->D2_ITEMORI
     	cNFO  := alltrim(SD2->D2_NFORI)
     	cSero := Alltrim(SD2->D2_SERIORI)
     	cCod  := SD2->D2_COD    
     	
     	SD2->(DbSeek(xFilial("SD2")+SD2->D2_NFORI+SD2->D2_SERIORI+SF2->F2_CLIENTE+SF2->F2_LOJA+cCod+cItem))     	     	

		If(SF2->F2_TIPO$"DC")
		
	     	cMensNF+=cNFO+" de:"+TRANSFORM(SD2->D2_EMISSAO,"@e")+space(01)
		     	
		Else    

	     	cMensNF+=cNFO+"-"

	    Endif                  

        SD2->(DbGoto(nReg))	    
	    
     Endif                  
     
     SD2->(DBSKIP())
         
Enddo  

SF2->F2_MENS_P  := alltrim(SF2->F2_MENS_P)+" "+ALLTRIM(cMensSC5)+" "+Alltrim(cMensNF)
       
Mens1 := substr(SF2->F2_MENS_P,1,45)
Mens2 := substr(SF2->F2_MENS_P,46,45)
Mens3 := substr(SF2->F2_MENS_P,91,45)
Mens4 := substr(SF2->F2_MENS_P,136,45)
Mens5 := substr(SF2->F2_MENS_P,181,45)

DEFINE MSDIALOG oDlgp TITLE "Informações Adicionais" FROM 005,002 TO 200,450 PIXEL
		
@ 010,007 Say "Mensagem"    Size 150,600 COLOR CLR_BLACK PIXEL OF oDlgp
		
@ 009,040 MsGet oMens1 Var Mens1 Size 150,010 COLOR CLR_BLACK   PIXEL OF oDlgp
@ 020,040 MsGet oMens2 Var Mens2 Size 150,010 COLOR CLR_BLACK   PIXEL OF oDlgp 
@ 031,040 MsGet oMens3 Var Mens3 Size 150,010 COLOR CLR_BLACK   PIXEL OF oDlgp
@ 042,040 MsGet oMens4 Var Mens4 Size 150,010 COLOR CLR_BLACK   PIXEL OF oDlgp
@ 053,040 MsGet oMens5 Var Mens5 Size 150,010 COLOR CLR_BLACK   PIXEL OF oDlgp 
		
@ 080,123 BmpButton Type 1 Action Eval({|| ExecBlock("GrvSF2",.F.,.F.),Close(oDlgp)})
@ 080,153 BmpButton Type 2 Action Close(oDlgp)
ACTIVATE  MSDIALOG oDlgp CENTERED

Return

//**************************
User Function GrvSF2
//**************************
Local Mens   := rtrim(Mens1) +" "+ rtrim(Mens2) +" "+ rtrim(Mens3) +" "+ rtrim(Mens4) +" "+ rtrim(Mens5)

SF2->F2_MENS_P  := Mens

Return