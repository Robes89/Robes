#include "rwmake.ch"
#DEFINE ENTER CHR(13) + CHR(10) 
//--------------------------------------------------------------------------
// Pto Entrada : MSD2520         Autor : Rodrigo T. Silva    Dt : 07/04/03
// Descricao   : Este programa ira excluir a transferencia (SD3), automatica
//               gerada a partir do Local Destino e TES contida no parametro.
//--------------------------------------------------------------------------
// Declara Variaveis
//#FAP20170124
//APOS REMESSA FÍSICA O USUÁRIO REALIZA A EXCLUSÃO DA NFS GERADA - TEM QUE GERAR O ESTORNO DA ENTRADA NO 02 OU 03 PARA O ALMOX 01 

User Function MSD2520()
_aSvAlias       := {Alias(),IndexOrd(),Recno()}

Private cCusMed := GetMv('MV_CUSMED')   ; aLog          := {}
cCodOrig        := SD2->D2_COD          ; cLocOrig		:= SD2->D2_LOCAL
nQuant260       := SD2->D2_QUANT        ; cDocto        := SD2->D2_DOC
dEmis260        := SD2->D2_EMISSAO      ; nQuant260D    := 0
cNumLote        := ''                   ; cLoteDigi		:= ''
dDtValid        := CTOD('  /  /  ')     ; cNumSerie		:= ''
cLoclzOrig      := ''                   ; cCodDest      := SD2->D2_COD
cLocDest        := "02"			        ; cLocLzDest    := ''
lEstorno        := .F.                  ; nRecOrig		:= 0
nRecDest        := ''                   ; cPrograma		:= '#MSD2460'
AREGSD3 := {}
_aSvAlias       := {Alias(),IndexOrd(),Recno()}

cCodOrig        := SD2->D2_COD
cDocto          := SD2->D2_DOC
mDATA           := SD2->D2_EMISSAO

IF	Substr(SD2->D2_CF,2,3) $ "917" .OR. Substr(SD2->D2_CF,2,3) $ "912" 

//	( Substr(SD2->D2_CF,2,3) $ "912" ) ) //.or. ( Substr( SD2->D2_CF , 2 , 3 ) $ "949" .and. ;
//	SF4->( DbSeek( xFilial( "SF4" ) + SD2->D2_TES ) ) .and. "MOSTRUARIO" $ Upper( SF4->F4_TXTUSER ) )

    cLocOrig := " "  
    nTotQtd := 0
    If Substr(SD2->D2_CF,2,3) $ "912"   
	   cLocOrig  := "03"
	ElseIf Substr(SD2->D2_CF,2,3) $ "917" 
	   cLocOrig  := "02"
	Endif   
    If !Empty(cLocOrig)           
       dbSelectArea("SB2")           
       dbSetOrder(1)
       If dbSeek(xFilial("SB2") + SD2->D2_COD + cLocOrig)
          nTotQtd := SB2->B2_QATU - SB2->B2_QEMP
       Endif 
       If nTotQtd > 0 .and. nTotQtd >= nQuant260
	      a260Processa(cCodOrig,cLocOrig,nQuant260,cDocto,dEmis260,nQuant260D,cNumLote,cLoteDigi,dDtValid,cNumSerie,cLoclzOrig,cCodDest,cLocDest,cLocLzDest,lEstorno,nRecOrig,nRecDest,cPrograma)
          aAdd(aLog,{cCodOrig,cLocOrig,nQuant260,cLocDest})
       Else
	      Alert("O Produto "+Alltrim(SD2->D2_COD)+" do armazém "+Alltrim(cLocOrig)+" selecionado não contem saldo suficiente para processamento."+ ENTER + ENTER+;
             "Saldo atual: "+Str(nTotQtd,12,2)+", Quantidade processada: "+str(SD2->D2_QUANT,12,2) +ENTER+"MSD2520" )
       Endif   
    Endif

	DBSELECTAREA("SD3")
	DBSETORDER(2)
	DBGOTOP()
	DBSEEK(xFILIAL()+cDocto)
	DO WHILE !EOF() .AND. (SD3->D3_DOC == cDocto) .AND. (DTOS(SD3->D3_EMISSAO) == DTOS(mDATA))
		dbSelectArea("SB2")
		dbSetOrder(1)
		dbSeek(xFilial("SB2") + SD3->D3_COD + SD3->D3_LOCAL)
		If lEFT( SD3->D3_CF , 2 ) == "RE"
			RecLock("SB2",.F.)
			SB2->B2_QATU  += SD3->D3_QUANT
			SB2->B2_VATU1 := SB2->B2_QATU * SB2->B2_CM1
			msUnlock()
		Endif
		If lEFT( SD3->D3_CF , 2 ) == "DE"
			RecLock("SB2",.F.)
			SB2->B2_QATU  -= SD3->D3_QUANT
			SB2->B2_VATU1 := SB2->B2_QATU * SB2->B2_CM1
			If SB2->B2_VATU1 < 0
			   SB2->B2_VATU1 := 0
			Endif   
			msUnlock()
		Endif
		dbSelectArea("SD3")
        RECLOCK("SD3",.F.)
        DBDELETE()
		MSUNLOCK()
		DBSELECTAREA("SD3")
		DBSKIP()
	ENDDO
ENDIF

// Tratamento do pedido Estimado

aArea_SC5	:= SC5->( GetArea() )
SC5->( DbSetOrder( 1 ) )

dbSelectArea("SC6")
dbSetOrder(1)
dbSeek(xFilial("SC6") + SD2->D2_PEDIDO + SD2->D2_ITEMPV + SD2->D2_COD)
If !Empty(SC6->C6_NUMPEDP)
	dbSelectArea("SC6")
	oldInd	:= SC6->(IndexOrd())
	oldRec	:= SC6->(Recno())
	nnPed	:= SC6->C6_NUMPEDP
	cItemPE	:= SC6->C6_ITEMPE
	ccCod	:= SD2->D2_COD
	nQtdSD2	:= SD2->D2_QUANT
	SC6->(dbSetOrder(1))
	SC6->(dbSeek(xFilial("SC6") + nnPed + cItemPE + ccCod ))
	do While !SC6->( Eof() ) .and.	SC6->C6_FILIAL	== xFilial() .and. ;
									SC6->C6_NUM		== nnPed .and. ;
									SC6->C6_ITEM	== cItemPE .and. ;
									SC6->C6_PRODUTO	== ccCod
		Reclock("SC6",.f.)
		SC6->C6_QTDENT	-= SD2->D2_QUANT
		SC6->C6_DATFAT	:= CtoD( "" )
		SC6->C6_NOTA	:= Space( Len( SD2->D2_DOC ) )
		SC6->C6_SERIE	:= Space( Len( SD2->D2_SERIE ) )
		MsUnlock()

		If SC5->( DbSeek( xFilial( "SC5" ) + SC6->C6_NUM ) ) .and. !Empty( SC5->C5_NOTA )
			RecLock( "SC5" )
			SC5->C5_NOTA	:= Space( Len( SC5->C5_NOTA ) )
			SC5->C5_SERIE	:= Space( Len( SC5->C5_SERIE ) )
			SC5->( MsUnLock() )

			RestArea( aArea_SC5 )

		EndIf

		SC6->(dbSkip())
	Enddo
	SC6->(dbSetOrder(oldInd))
	SC6->(dbGoto(oldRec))
Endif

DbSelectArea(_aSvAlias[1])
DbSetOrder(_aSvAlias[2])
DbGoTo(_aSvAlias[3])
RETURN NIL