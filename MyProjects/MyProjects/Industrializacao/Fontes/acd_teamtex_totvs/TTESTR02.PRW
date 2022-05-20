
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TTESTR02  ºAutor  ³Rafael Garcia       º Data ³  04/07/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao etiqueta Produto					              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function TTESTR02()
	Local cCodigo,sConteudo, nX
	Local cCodBar  :=""
	Local cCodBar2  :=""
	Local aArea := GetArea()
	local cPerg:="TTESTR02"   
	local nQuant   := 0	
	local cProduto:=""
	local nDesc:= 0

	AjustSX1()

	IF  Pergunte(cPerg,.T.)
		If Empty(MV_PAR03)
			MsgAlert("Informe um local de impressao valido")
		EndIf

		If !CB5SetImp(MV_PAR03)  
			MsgAlert("Local de Impressão "+MV_PAR05+" nao Encontrado!") 
			Return
		Endif
			
		nQuant:= MV_PAR02
		cProduto:= ALLTRIM(MV_PAR01)
		cCodBar  := ALLTRIM(POSICIONE("SB1" ,1,XFILIAL("SB1")+cProduto,"B1_CODBAR"))
		cCodBar2 :=MSCB128C()+ alltrim(str(POSICIONE("SB5",1,XFILIAL("SB1")+cProduto,"B5_EAN141")))+cCodBar
		for nx:=1 to 	nQuant
			MSCBBEGIN(1,6)
			MSCBBOX(05,02,100,55,1)
			MSCBSAY(06,50,"Unitario","N","2","01,01")
			MSCBLineH(05,25,100,1)
			If GETMV("MV_XEAN14")
				MSCBSAYBAR(20,06,cCodBar2,"N","MB07",8.36,.F.,.T.,.F.,,6,4,.F.,.F.,"1",.T.)	//46
				MSCBSAY(06,22,"Master","N","2","01,01")
			EndIf
			nDesc:=Len(cProduto+" - "+ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+cProduto,"B1_DESC")))
			MSCBSAY(06,28,cProduto+" - "+ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+cProduto,"B1_DESC")),"N","2","01,01")
			MSCBSAYBAR(06,33,cCodbar,"N","MB04",8.36,.F.,.T.,.F.,,4,3,.F.,.F.,"1",.T.)
			MSCBInfoEti("Produto","30X100")
			MSCBEND()
			MSCBCLOSEPRINTER() 
		next
	ENDIF
	RestArea(aArea)
Return sConteudo


STATIC FUNCTION AjustSX1()

	LOCAL cPerg:= PADR("TTESTR02",10)

	DbSelectArea("SX1")
	DbSetOrder(1)
	If !DbSeek(cPerg + "01",.f.)
		While !RecLock("SX1",.t.)
		Enddo
		SX1->X1_GRUPO   := cPerg
		SX1->X1_ORDEM   := "01"
		SX1->X1_PERGUNT := "Produto?"
		SX1->X1_VARIAVL := "mv_ch1"
		SX1->X1_TIPO    := "C"
		SX1->X1_TAMANHO := 15	
		SX1->X1_GSC     := "G"
		SX1->X1_VAR01   := "mv_par01"
		SX1->X1_F3		:="SB1"	
		MsUnLock()

	EndIf

	DbSelectArea("SX1")
	DbSetOrder(1)
	If !DbSeek(cPerg + "02",.f.)
		While !RecLock("SX1",.t.)
		Enddo
		SX1->X1_GRUPO   := cPerg
		SX1->X1_ORDEM   := "02"
		SX1->X1_PERGUNT := "Quantidade?"
		SX1->X1_VARIAVL := "mv_ch2"
		SX1->X1_TIPO    := "N"
		SX1->X1_TAMANHO := 10	
		SX1->X1_GSC     := "G"
		SX1->X1_VAR01   := "mv_par02"
		SX1->X1_PICTURE	:= "9999999.99"
		MsUnLock()

	EndIf

	DbSelectArea("SX1")
	DbSetOrder(1)
	If !DbSeek(cPerg + "03",.f.)
		While !RecLock("SX1",.t.)
		Enddo
		SX1->X1_GRUPO   := cPerg
		SX1->X1_ORDEM   := "03"
		SX1->X1_PERGUNT := "Local Impressao?"
		SX1->X1_VARIAVL := "mv_ch3"
		SX1->X1_TIPO    := "C"
		SX1->X1_TAMANHO := 6	
		SX1->X1_GSC     := "G"
		SX1->X1_VAR01   := "mv_par03"
		SX1->X1_F3		:= "CB5"
		MsUnLock()

	EndIf	
RETURN	


