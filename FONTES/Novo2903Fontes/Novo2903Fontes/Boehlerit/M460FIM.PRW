#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"   
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
User Function M460FIM()
Local aArea 	:= GetArea()
Private cEst    := "SP"
Private cLocEmb := "SAO PAULO"
Private mOpc	:= 0
Private cxNS    :=""

If SF2->F2_EST=="EX"
	@ 96,100 To 350,600 Dialog oMen Title "Dados embarque exportacao: "+SF2->F2_DOC
	@ 025,010 Say "UB embarque:" Pixel
	@ 025,050 Get cEst size 40,10 Pixel
	@ 025,100 Say "Local Embarque:" Pixel
	@ 025,150 Get cLocEmb size 40,10 Pixel
	@ 045,150 BmpButton Type 1 Action (nOpc := 1,oMen:End())
	@ 045,180 BmpButton Type 2 Action (oMen:End())
	Activate Dialog oMen
	If nOpc==1
		
		cxNS:=SF2->F2_DOC+SF2->F2_SERIE
		
		dbSelectArea("SD2")
		SD2->(dbSetOrder(3))
		SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))        
        
        While cxNS==(SD2->D2_DOC+SD2->D2_SERIE) 
		
		dbSelectArea("CDL")
		dbSetOrder(1)		
		//lSeek := !dbSeek(xFilial("CDL")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)  
		Reclock("CDL",.T.)
		CDL_FILIAL := xFilial("SF2")
		CDL_DOC    := SF2->F2_DOC
		CDL_NUMDE  := SF2->F2_DOC
		CDL_ITEMNF := SD2->D2_ITEM
		CDL_DTDE   := SF2->F2_EMISSAO
		CDL_PRODNF := SD2->D2_COD
		CDL_INDDOC :="0"
		CDL_SERIE  := SF2->F2_SERIE
		CDL_ESPEC  := "SPED"
		CDL_CLIENT := SF2->F2_CLIENTE
		CDL_LOJA   := SF2->F2_LOJA
		CDL_UFEMB  := cEst
		CDL_LOCEMB := cLocEmb
        
		MsUnlock() 
        SD2->(dbSkip())
        EndDo
	EndIf
EndIf

RestArea(aArea)
Return