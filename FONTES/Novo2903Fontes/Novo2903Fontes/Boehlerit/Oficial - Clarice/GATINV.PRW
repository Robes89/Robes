#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#include "TopConn.ch"
#include "Totvs.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ GATINV   ³ Autor ³ FERNANDO PACHECO      ³ Data ³ 23/08/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Programa para tratamento especifico BOEHLERIT                ³±±
±±³          ³ permitir importar Invoice e atualizar a Invoice              ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Documento de Entrada                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³         MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³*                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
USER FUNCTION GATINV(cCod)     
Local	aAreaSD1	:= SD1->( GetArea() )

Local nItem     := 1
Local lFlag     := .t.
Local _cRet     := cCod //M->D1_CODLMT
LOCAL nPosCODLMT   := ASCAN( aHeader, { |x| AllTrim(x[2]) == "D1_CODLMT" } )
LOCAL nPosCOD	   := ASCAN( aHeader, { |x| AllTrim(x[2]) == "D1_COD" } )
LOCAL nPosLOCAL    := aScan( aHeader, { |x| Alltrim(x[2]) == "D1_LOCAL" })
LOCAL nPosQUANT    := aScan( aHeader, { |x| Alltrim(x[2]) == "D1_QUANT" })
LOCAL nPosVUNIT    := aScan( aHeader, { |x| Alltrim(x[2]) == "D1_VUNIT" })
LOCAL nPosTOTAL    := aScan( aHeader, { |x| Alltrim(x[2]) == "D1_TOTAL" })
LOCAL nPosTES      := aScan( aHeader, { |x| Alltrim(x[2]) == "D1_TES" })
LOCAL nPosPICM     := aScan( aHeader, { |x| Alltrim(x[2]) == "D1_PICM" })
LOCAL nPosVALICM   := aScan( aHeader, { |x| Alltrim(x[2]) == "D1_VALICM" })
LOCAL nPosIPI      := aScan( aHeader, { |x| Alltrim(x[2]) == "D1_IPI" })
LOCAL nPosVALIPI   := aScan( aHeader, { |x| Alltrim(x[2]) == "D1_VALIPI" })
LOCAL nPosCF       := aScan( aHeader, { |x| Alltrim(x[2]) == "D1_CF" })
LOCAL nPosCONTA    := aScan( aHeader, { |x| Alltrim(x[2]) == "D1_CONTA" })
LOCAL nPosDTDIGIT  := aScan( aHeader, { |x| Alltrim(x[2]) == "D1_DTDIGIT" })
LOCAL nPosPEDIDO   := aScan( aHeader, { |x| Alltrim(x[2]) == "D1_PEDIDO" })
LOCAL nPosITEMPC   := aScan( aHeader, { |x| Alltrim(x[2]) == "D1_ITEMPC" })
LOCAL nPosCLASFIS  := aScan( aHeader, { |x| Alltrim(x[2]) == "D1_CLASFIS" })
LOCAL nPosVALFOB   := aScan( aHeader, { |x| Alltrim(x[2]) == "D1_VALFOB" })
LOCAL nPosGRUPO    := aScan( aHeader, { |x| Alltrim(x[2]) == "D1_GRUPO" })
LOCAL nPosTP       := aScan( aHeader, { |x| Alltrim(x[2]) == "D1_TP" })
LOCAL NY           :=0
Private _cInvoice := SPACE(10)
Private _nTaxa    := 0
                         
Default cCod := M->D1_CODLMT

If Alltrim(Substr(aCols[n][nPosCODLMT ],1,3)) == "INV"

Pergunte("XGATINV",.T.)
_cInvoice := MV_PAR01
_nTaxa    := MV_PAR02
If _nTaxa <= 0
   _nTaxa := 1
Endif   
IF !Empty(_cInvoice)

	//	cQuery := " SELECT * "
	//	cQuery += " FROM "+RetSqlName("ZZ1")+" ZZ1 " 
	//	cQuery += " WHERE ZZ1.D_E_L_E_T_ <> '*'" 
	//	cQuery += " AND ZZ1_FILIAL = "+VALTOSQL(XFILIAL("ZZ1")) 
	//	cQuery += " AND ZZ1_INVOIC = "+VALTOSQL(_cInvoice) 
	//	cQuery += " AND ZZ1_NFISCA = ' ' " 
	//	cQuery += " AND ZZ1_LMTCOD <> ' ' " 


	cQuery := " SELECT * "
		cQuery += " FROM "+RetSqlName("ZZ1")+" ZZ1 "
		cQuery += " LEFT JOIN "+RetSqlName("SC7")+" SC7 ON C7_NUM=ZZ1_ORDER AND C7_ITEM = ZZ1_LINE "
		cQuery += " WHERE ZZ1.D_E_L_E_T_ <> '*' AND SC7.D_E_L_E_T_ <> '*'  " 
		cQuery += " AND ZZ1_FILIAL = "+VALTOSQL(XFILIAL("ZZ1")) 
		cQuery += " AND ZZ1_INVOIC = "+VALTOSQL(_cInvoice) 
		cQuery += " AND ZZ1_NFISCA = ' ' " 
		cQuery += " AND ZZ1_LMTCOD <> ' '  AND SC7.C7_ENCER<>'E' AND SC7.C7_RESIDUO<>'S' "

		//////  Adicionado para ordenar a Grid
		cQuery += " ORDER BY ZZ1_ORDER,ZZ1_LINE "


		//PROCSQL( cQUERY,cALIAS,cNOMEQUERY,lMSAGUARDE,lGRVQUERY,lANAQUERY,lSETFIELD)
		IF !(U_PROCSQL( cQUERY,"TRB","GATINV",.F.,.F.,.F.,.F.))
			Aviso( "Atenção" , "Nao foi identificado nenhum registro disponivel para Invoice: "+_cInvoice , { "Ok" },2,"Atenção" )
			RETURN(" ")
		ENDIF
		dbSelectArea("TRB")
		TRB->(DBGOTOP())
		While !TRB->(Eof())                          
			_cCOD    := PADR(ALLTRIM(TRB->ZZ1_LMTCOD),15) 
		    _cCodLMT := Posicione("SB1",1,xFilial("SB1")+_cCOD,"B1_CODLMT")
			_cLocal  := "07"
			_cTP     := Posicione("SB1",1,xFilial("SB1")+_cCOD,"B1_TIPO")
			_cGRUPO  := Posicione("SB1",1,xFilial("SB1")+_cCOD,"B1_GRUPO")
			_nVUnit  := TRB->ZZ1_PRICE * _nTaxa
			_cNumPC  := TRB->ZZ1_ORDER
			_cTES    := "002" //Posicione("SC7",1,xFilial("SC7")+_cNumPC,"C7_TES")
			_cCF     := Posicione("SF4",1,xFilial("SF4")+_cTES,"F4_CF")
			_nPIPI   := Posicione("SB1",1,xFilial("SB1")+_cCOD,"B1_IPI")
			_nPICM   := Posicione("SB1",1,xFilial("SB1")+_cCOD,"B1_PICM")  ////18
			_lCalcIcm := Posicione("SF4",1,xFilial("SF4")+_cTES,"F4_ICM")
			_lCalcIpi := Posicione("SF4",1,xFilial("SF4")+_cTES,"F4_IPI")

			aCols[n][1 ] := strzero(n,4)
			aCols[n][nPosCODLMT ] := _cCodLMT
			aCols[n][nPosCOD    ] := _cCod
			aCols[n][nPosLOCAL  ] := _cLocal
			aCols[n][nPosQUANT  ] := TRB->ZZ1_QTY
			aCols[n][nPosVUNIT  ] := _nVUnit
			aCols[n][nPosTOTAL  ] := TRB->ZZ1_QTY * _nVUnit
			aCols[n][nPosTES    ] := _cTES
			aCols[n][nPosPICM   ] := _nPICM
			aCols[n][nPosVALICM ] := IIF(_lCalcIcm$"1S",((TRB->ZZ1_QTY * _nVUnit)*_nPICM) / 100, 0 )
			aCols[n][nPosIPI    ] := _nPIPI
			aCols[n][nPosVALIPI ] := IIF(_lCalcIpi$"1S" .and. _nPIPI > 0,((TRB->ZZ1_QTY * _nVUnit)*_nPIPI) / 100, 0 )
			aCols[n][nPosCF     ] := _cCF
			aCols[n][nPosCONTA  ] := "11250702"
			aCols[n][nPosDTDIGIT] := ddatabase
			aCols[n][nPosPEDIDO ] := TRB->ZZ1_ORDER
			aCols[n][nPosITEMPC ] := TRB->ZZ1_LINE
			aCols[n][nPosVALFOB ] := 0
//			aCols[n][nPosGRUPO  ] := _cGRUPO
//			aCols[n][nPosTP     ] := _cTP        
			aCols[n][8] 		  := " "
            If lFlag 
               _cRet := _cCodLMT
               lFlag := .f.
            Endif   
			MaColsToFis(aHeader,aCols,n,"MT100",.T.,.F.,.F.,.T.)
		    Eval(bRefresh)

			TRB->(DBSKIP())
			If !TRB->(Eof())
			   AADD(aCols,Array(Len(aHeader)+1))
			   n := Len(aCols)
			   nItem := n
				If nItem <> 1
					//+--------------------------------------------------------------+
					//¦ Faz a montagem de uma linha em branco no aCols.              ¦
					//+--------------------------------------------------------------+
					For nY := 1 To Len(aHeader)
						If Trim(aHeader[nY][2]) == "D1_ITEM"
							aCols[nItem][nY]  := StrZero( nItem, Len(SD1->D1_ITEM))
						Else
							If At("WT", aHeader[nY][2]) == 0
								aCols[nItem][nY] := CriaVar(aHeader[nY][2])
							EndIf
						EndIf
					Next
					aCols[nItem][Len(aHeader)+1] := .F.
				EndIf
			Endif   
		ENDDO 
		TRB->(dbCloseArea())

   ENDIF
   Eval(bGDRefresh)
Endif   
RestArea( aAreaSD1 )

RETURN(_cRet)
