#include 'Protheus.ch'
#include 'Totvs.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SF2520E   ºAutor  ³Tanimoto            º Data ³  08/04/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Antes da Exclusao do Documento de saida utilizado para     º±±
±±º          ³ diversos fins.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function SF2520E()
Local _aArea    := GetArea()
Local _cDoc		:= SF2->F2_DOC
Local _cSerie	:= SF2->F2_SERIE
Local _cCliente	:= SF2->F2_CLIENTE
Local _cLoja	:= SF2->F2_LOJA
//Local _cNumOc	:= SF2->F2_NUMOC
Local _cTipoCli	:= SF2->F2_TIPOCLI
Local _cTipo	:= SF2->F2_TIPO

//Exclui registros do CDL tag especifica de exportação para xml NF-e
If _cTipo=="N" .and. _cTipoCli=="X"
	dbSelectArea("CDL")
	dbSetOrder(1)
	dbSeek(xFilial("CDL")+_cDoc+_cSerie+_cCliente+_cLoja)
	If Found()
		While !eof() .and. CDL->CDL_DOC==_cDoc .and. CDL->CDL_SERIE==_cSerie .and. CDL->CDL_CLIENT==_cCliente .and. CDL->CDL_LOJA==_cLoja
			Reclock("CDL",.F.)
			dbDelete()
			MsUnlock()
			dbSkip()
		End
	EndIf
EndIf

RestArea(_aArea)
Return .T.