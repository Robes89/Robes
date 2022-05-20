#include "totvs.ch"
#include "apvt100.ch"

User Function CbRetEan

Local cID 		:= PARAMIXB[1]
Local aAreaAtu 	:= GetArea()
Local aAreaSB1 	:= SB1->(GetARea())
Local cProd		:= ""
Local nIndSB1	:= 0
Local nPosProd  := 1
Local nPosLote	:= 0
Local nPosQtd	:= 0
Local aRet		:= {}
Local nQtd		:= IIf("ACD" $ FunName(), 1, 0 )
Local cLote		:= CriaVar("D3_LOTECTL",.F.)
Local cSubLote	:= CriaVar("D3_NUMLOTE",.F.)
Local dDtValid	:= CriaVar("B8_DTVALID",.F.)
Local aTela		:= VtSave()

Private cOrigemDan	:= ""
Private dVldDan		:= StoD("")

nIndSB1 := SB1->(IndexOrd())
SB1->( dbSetOrder(1) )

If ValType(cID) == "N"
	cID := str(cID)
EndIf

If !Empty(cID)
	nPosLote 	:=  At("@", cID)
	nPosQtd	    := Rat("@", cID)
	//Se nao tiver @, procura por pontos, criado para testes
	If Empty(nPosLote+nPosQtd)
		nPosLote	:=	At(".", cID)
		nPosQtd		:=	RAt(".", cID)
	Endif
	cProd 		:= Padr(Iif(!Empty(nPosLote), AllTrim(Substr(cId,1,nPosLote-1)), cId), TamSX3("DB_PRODUTO")[1])
	cLote 		:= Iif(!Empty(nPosLote), AllTrim(Substr(cId,nPosLote+1,nPosQtd-nPosLote-1)),CriaVar("DB_LOTECTL",.F.))
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Adicionado por Guilherme Ricci - Verificado junto aos Srs. Renato Carli e Marcos Ebert que os lotes no sistema Fabrik 
	// e foram importados para o Protheus estao digitados sem o "100", por isso foi suprimido, pois caso contrario, o sistema 
	// nunca encontrara saldo para os lotes.
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	If Substr( cLote, 3, 3 ) == "100"
		cLote := Substr( cLote, 1,2 ) + Substr( cLote, 6, Len(cLote)-5)
	Endif
	
	//nQtd  		:= Val(Iif(!Empty(nPosQtd),  AllTrim(Substr(cId,nPosQtd+1,Len(Alltrim(cID)))),"0"))/1000
	
	If IsDanone(cProd)
		If Empty(nPosLote) 
			While Empty(cLote)
				cOrigemDan 	:= Space(3)
				dVldDan		:= StoD("")
				VtClear()
				@ 0,0 VtSay "LOTE DANONE"
				@ 2,0 VtSay "Origem: " 		VtGet cOrigemDan Picture "@!" 	valid vldOrigem(cOrigemDan)
				@ 4,0 VtSay "Dt. Valid: " 	VtGet dVldDan					Valid dVldDan >= dDatabase
				
				VTRead		
			
				If VTLastKey() == 27
					If VTYesNo("Cancela ?", "Danone" , .t.)
						cProd := ""
						exit
					EndIf
				EndIf
				
				cLote 		:= cOrigemDan + DtoS(dVldDan)
				dDtValid 	:= dVldDan
			EndDo
			
			VtRestore(,,,,aTela)
		Endif
		If !Empty(nPosQtd)
			nQtd	:= Val(Iif(!Empty(nPosQtd),  AllTrim(Substr(cId,nPosQtd+1,Len(Alltrim(cID)))),str(nQtd)))
		Endif
	Endif
Endif

If !Empty(cProd)
	Posicione("SB5",1, xFilial("SB5") + cProd, "")
	aRet := { cProd, nQtd, Padr(cLote, TamSx3("DB_LOTECTL")[1]),dDtValid , CriaVar("DB_NUMSERI", .F.), Padr(cSublote,TamSx3("DB_NUMLOTE")[1]) }
Endif

//RestArea(aAreaSB1)
SB1->( dbSetOrder( nIndSB1 ) )
RestArea(aAreaAtu)

Return aRet


Static Function IsDanone( cProd )

	Local lRet := .F.
	
	If Posicione("SB1",1,xFilial("SB1")+cProd,"B1_GRUPO") == "0007"
		lRet := .T.
	Endif

Return lRet

Static Function vldOrigem(cOrigemDan)

	Local cOrigens := GetMV("ZZ_ORIGDAN",,"JUN/JAC")
	Local lRet := .F.
	
	If cOrigemDan $ cOrigens .and. Len(cOrigemDan) == 3
		lRet := .T.
	Else
		VtAlert("Origem invalida", "ZZ_ORIGDAN", .T., 2000, 2 )
	Endif

Return lRet