
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTTESTR01  บAutor  ณRafael Garcia       บ Data ณ  07/04/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpressao etiqueta endere็o					              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


User Function TTESTR01()

Local cPerg		:= "TTESTR01"
Local lContinua := .F.

AjustSX1()

lContinua := Pergunte(cPerg,.T.)

If Empty(MV_PAR05)
	MsgAlert("Informe um local de impressao valido")
EndIf

If !CB5SetImp(MV_PAR05)  
	MsgAlert("Local de Impressใo "+MV_PAR05+" nao Encontrado!") 
	Return
Endif	

If lContinua
	ImpEti01()
	MSCBCLOSEPRINTER()             
EndIf

Return
//////////////////////////////////////////
//Rotina de impressao de etiqueta      //
/////////////////////////////////////////
Static Function ImpEti01()

Local cQuery	:= ""
Local cAliasNew	:= GetNextAlias()
Local cTipoBar	:= 'MB04' //EAN13
Local cCodBar	:= ''
Local sConteudo	:= ""

Private ENTERL     := CHR(13)+CHR(10)

//+-----------------------
//| Cria filtro temporario
//+-----------------------

cAliasNew:= GetNextAlias()


cQuery 	:= " SELECT BE_LOCAL,BE_LOCALIZ " + ENTERL
cQuery 	+= " FROM " +RetSqlName("SBE") + ENTERL
cQuery 	+= " WHERE BE_FILIAL     = '"+ xFilial("SBE")+"' AND "  + ENTERL
cQuery 	+= "  BE_LOCAL BETWEEN   '" +MV_PAR01+"' AND '"+MV_PAR02+"' AND " + ENTERL
cQuery 	+= "  BE_LOCALIZ BETWEEN   '" +MV_PAR03+"' AND '"+MV_PAR04+"' AND " + ENTERL
cQuery 	+= "  D_E_L_E_T_<>'*'" 

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasNew,.T.,.T.)

(cAliasNew)->(dbGoTop())


While (cAliasNew)->(!Eof())

	cCodBar := Alltrim((cAliasNew)->BE_LOCAL)+Alltrim((cAliasNew)->BE_LOCALIZ) 

	MSCBBEGIN(1,6)

	MSCBSAY(15,33, Alltrim((cAliasNew)->BE_LOCALIZ), "N", "4", "05,05")
	MSCBSAYBAR(30,01,cCodBar,"N","MB07",24.36,.F.,.F.,.F.,,12,3,.F.,.F.,"1",.T.)
	MSCBInfoEti("Endereco","30X100")
	(cAliasNew)->(dbSkip())
	sConteudo:=MSCBEND()
EndDo 

(cAliasNew)->(DbCloseArea())

If Empty(sConteudo)
	MsgAlert("Sem Dados para Impressใo! Verifique os Parametros!!!","A T E N ว ร O!!!")
	Return
Else
	Return sConteudo
EndIf


STATIC FUNCTION AjustSX1()
	
	LOCAL cPerg:= PADR("TTESTR01",10)

	DbSelectArea("SX1")
	DbSetOrder(1)
	If !DbSeek(cPerg + "01",.f.)
		While !RecLock("SX1",.t.)
		Enddo
		SX1->X1_GRUPO   := cPerg
		SX1->X1_ORDEM   := "01"
		SX1->X1_PERGUNT := "Almoxarifado de?"
		SX1->X1_VARIAVL := "mv_ch1"
		SX1->X1_TIPO    := "C"
		SX1->X1_TAMANHO := 2	
		SX1->X1_GSC     := "G"
		SX1->X1_VAR01   := "mv_par01"
		SX1->X1_F3		:="NNR"	
		MsUnLock()

	EndIf

	DbSelectArea("SX1")
	DbSetOrder(1)
	If !DbSeek(cPerg + "02",.f.)
		While !RecLock("SX1",.t.)
		Enddo
		SX1->X1_GRUPO   := cPerg
		SX1->X1_ORDEM   := "02"
		SX1->X1_PERGUNT := "Almoxarifado ate?"
		SX1->X1_VARIAVL := "mv_ch2"
		SX1->X1_TIPO    := "C"
		SX1->X1_TAMANHO := 2	
		SX1->X1_GSC     := "G"
		SX1->X1_VAR01   := "mv_par02"
		SX1->X1_F3		:="NNR"
		MsUnLock()

	EndIf
	
	DbSelectArea("SX1")
	DbSetOrder(1)
	If !DbSeek(cPerg + "03",.f.)
		While !RecLock("SX1",.t.)
		Enddo
		SX1->X1_GRUPO   := cPerg
		SX1->X1_ORDEM   := "03"
		SX1->X1_PERGUNT := "Endereco de?"
		SX1->X1_VARIAVL := "mv_ch3"
		SX1->X1_TIPO    := "C"
		SX1->X1_TAMANHO := 15	
		SX1->X1_GSC     := "G"
		SX1->X1_VAR01   := "mv_par03"
		SX1->X1_F3		:="SBE"
		MsUnLock()

	EndIf

	DbSelectArea("SX1")
	DbSetOrder(1)
	If !DbSeek(cPerg + "04",.f.)
		While !RecLock("SX1",.t.)
		Enddo
		SX1->X1_GRUPO   := cPerg
		SX1->X1_ORDEM   := "04"
		SX1->X1_PERGUNT := "Endereco ate?"
		SX1->X1_VARIAVL := "mv_ch4"
		SX1->X1_TIPO    := "C"
		SX1->X1_TAMANHO := 5	
		SX1->X1_GSC     := "G"
		SX1->X1_VAR01   := "mv_par4"
		SX1->X1_F3		:="SBE"
		MsUnLock()

	EndIf
	
	DbSelectArea("SX1")
	DbSetOrder(1)
	If !DbSeek(cPerg + "05",.f.)
		While !RecLock("SX1",.t.)
		Enddo
		SX1->X1_GRUPO   := cPerg
		SX1->X1_ORDEM   := "05"
		SX1->X1_PERGUNT := "Local Impressao?"
		SX1->X1_VARIAVL := "mv_ch5"
		SX1->X1_TIPO    := "C"
		SX1->X1_TAMANHO := 6	
		SX1->X1_GSC     := "G"
		SX1->X1_VAR01   := "mv_par05"
		SX1->X1_F3		:= "CB5"
		MsUnLock()

	EndIf	

RETURN	
	

	