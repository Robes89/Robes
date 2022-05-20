#Include "Totvs.ch"

#Define MAXGETDAD    99999

/*/{Protheus.doc}'PsBrowse'
'Tela para alteração do produto antes de gerar documento de pre nota'
@author Sergio Celestino
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/

User Function COMXPROC()
Local aArea     := GetArea()
Local aAreaSDS  := SDS->(GetArea())     
Local aAreaSDT  := SDT->(GetArea())     
Local aAreaCKO  := CKO->(GetArea())     
Local aAreaSA5  := SA5->(GetArea())     
Local aAreaSA2  := SA2->(GetArea())     
Local aSize  	:= MsAdvSize()
Local oFont1	:= TFont():New("Arial",12,16,,.T.,,,,.T.,.F.)
Local cTitulo   := "Classificação de Produtos"
Local aAlter 	:= {"OV_PRODUTO"}	
Local nOpc		:= 0
Local lRet      := .T.
Local nItens	:= 0
Local aButtons  := {{"PROJETPMS",{ || u_DANFEXML() },"Imprime DANFE NFE","Imprime DANFE NFE"}}
Local aButtons  := {{"PROJETPMS",{ || u_RTMSR27()  },"Imprime DACTE","Imprime DACTE"}}

Private oTela   := Nil
Private aHeaDad	:= {} 
Private aColDad := {}
Private aColsSize := {}

AHEAD_OV()
ACOLS_OV()

If Len(aColDad)>0

	dbSelectArea("SA2")
	dbSetOrder(1)
	dbSeek(xFilial("SA2") + SDS->DS_FORNEC + SDS->DS_LOJA)

	DEFINE MSDIALOG oTela FROM 0, 0 To aSize[6],aSize[5] Title cTitulo  Of GetWndDefault() PIXEL STYLE DS_MODALFRAME STATUS 
				
	oTPane1 := TPanel():New(0,0,"",oTela,NIL,.T.,.F.,NIL,NIL,0,35,.T.,.T.)
	oTPane1:Align := CONTROL_ALIGN_TOP
															
	@ 010 ,010 Say "Nota Fiscal: "+SDS->DS_DOC+" Serie: "+SDS->DS_SERIE Size 750,8  Of oTPane1 PIXEL COLOR CLR_HRED FONT oFont1
	@ 025 ,010 Say "Fornecedor : "+SDS->DS_FORNEC+" - Loja: "+SDS->DS_LOJA+" - Nome: "+ Alltrim(SA2->A2_NREDUZ) + " [ Alterar códigos Genéricos ]" Size 750,8  Of oTPane1 PIXEL COLOR CLR_HRED FONT oFont1
				
	oTPane2 := TPanel():New(0,0,"",oTela,NIL,.T.,.F.,NIL,NIL,0,0,.T.,.F.)
	oTPane2:Align := CONTROL_ALIGN_ALLCLIENT
				
	oGetDad:= MsNewGetDados():New(0 , 0  , 0 , 0 , GD_INSERT+GD_UPDATE+GD_DELETE ,"u_VldLOk"  ,"u_VldTOk" ,"+D1_ITEM"  ,aAlter    ,           ,MAXGETDAD ,            ,              ,         , oTPane2, aHeaDad       , aColDad    ,           ,         ,    aColsSize )
	
	oGetDad:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT

	oGetDad:lInsert := .F.
	oGetDad:lDelete := .F.
				
	oTPane4:= TPanel():New(0, 0, "", oTela, NIL, .T., .F., NIL, NIL,0 , 5 , .T., .F. )
	oTPane4:Align:= CONTROL_ALIGN_BOTTOM
				
	Activate MsDialog oTela Centered On Init (EnchoiceBar(oTela , { || iif( ValidBrow(aColDad,@lRet) , fSalvar(@lRet) , lRet := .F. ) },{||  lRet:=.F. , oTela:End() } ,,@aButtons ))
	
Endif	

RestArea(aAreaSDS)
RestArea(aAreaSDT)
RestArea(aAreaCKO)
RestArea(aAreaSA5)
RestArea(aAreaSA2)
RestArea(aArea)

Return lRet

/*/{Protheus.doc}'ValidBrow'
''
@author Sergio Celestino
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/	
Static Function ValidBrow(aColDad,lRet)

Local cPrdGen := Alltrim(GetMv("OV_PRODGEN",,"GEN001"))
Local nPosGen := 0

lRet := .T.

nPosGen := aScan(oGetDad:aCols, { |x| Alltrim(x[4])==cPrdGen })
if nPosGen>0
	Aviso("Atenção","O Item "+Alltrim(Str(nPosGen)) + " se encontra com produto genérico, informar outro produto para prosseguir",{"Ok"})
	lRet := .F.
Endif

dbSelectArea("SA2")
dbSetOrder(1)
If dbSeek( xFilial("SA2") + SDS->(DS_FORNEC+DS_LOJA) )
	If Empty(SA2->A2_XUNICO)
		Aviso("Atenção","O Fornecedor "+SA2->A2_COD+"-"+SA2->A2_LOJA+" :"+Alltrim(SA2->A2_NOME)+", se encontra com o campo 'Codigo Unico' sem preenchimento.Verifique para prosseguir!",{"Ok"})
		lRet := .F.
	Endif
	If Empty(SA2->A2_XESTOQU)
		Aviso("Atenção","O Fornecedor "+SA2->A2_COD+"-"+SA2->A2_LOJA+" :"+Alltrim(SA2->A2_NOME)+", se encontra com o campo 'Merc.Estoque' sem preenchimento.Verifique para prosseguir!",{"Ok"})
		lRet := .F.
	Endif
Endif

Return lRet

/*/{Protheus.doc}'VldLOk'
''
@author Sergio Celestino
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/	
User Function VldLOk
Local lRet := .T.
Return lRet

/*/{Protheus.doc}'VldTOk'
''
@author Sergio Celestino
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/	
User Function VldTOk
Local lRet := .T.
Return lRet

/*/{Protheus.doc}''
''
@author Sergio Celestino
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/	
Static Function AHEAD_OV()
Local aHeaAux := {}

aHeaAux	:= {  "Item NF"		,; // 01 - Titulo
			  "OV_ITEM"	    ,; // 02 - Campo
				"@!"	    ,; // 03 - Picture
				4			,; // 04 - Tamanho
				0  			,; // 05 - Decimal
				Nil			,; // 06 - Valid
				"x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     "			,; // 07 - Usado
				"C"			,; // 08 - Tipo
				Nil			,; // 09 - F3
				"R"			,; // 10 - Contexto
				Nil			,; // 11 - Box - Opcoes do combo
				Nil			,; // 12 - Ini. Padrao
				".F."		,; // 13 - When
				"V"			,; // 14 - Visual
				Nil			,; // 15 - Val. User
				Nil			 } // 16 - PictVar

aAdd(aHeaDad, aClone(aHeaAux))

aAdd(aColsSize , {"OV_ITEM" , 30 } )

aHeaAux	:= {  "Referencia"		,; // 01 - Titulo
			  "OV_CODPRF"	,; // 02 - Campo
				"@!"		,; // 03 - Picture
				TamSX3("A5_CODPRF")[1]			,; // 04 - Tamanho
				0  			,; // 05 - Decimal
				Nil			,; // 06 - Valid
				"x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     "			,; // 07 - Usado
				"C"			,; // 08 - Tipo
				Nil			,; // 09 - F3
				"R"			,; // 10 - Contexto
				Nil			,; // 11 - Box - Opcoes do combo
				Nil			,; // 12 - Ini. Padrao
				".F."		,; // 13 - When
				"V"			,; // 14 - Visual
				Nil			,; // 15 - Val. User
				Nil			 } // 16 - PictVar

aAdd(aHeaDad, aClone(aHeaAux))

aAdd(aColsSize , {"OV_CODPRF" , 80 } )

aHeaAux	:= {  "Descrição"	,; // 01 - Titulo
			  "OV_NOMPROD"	,; // 02 - Campo
				"@!"		,; // 03 - Picture
				TamSX3("A5_DESCPRF")[1]			,; // 04 - Tamanho
				0  			,; // 05 - Decimal
				Nil			,; // 06 - Valid
				"x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     "			,; // 07 - Usado
				"C"			,; // 08 - Tipo
				Nil			,; // 09 - F3
				"R"			,; // 10 - Contexto
				Nil			,; // 11 - Box - Opcoes do combo
				Nil			,; // 12 - Ini. Padrao
				".F."		,; // 13 - When
				"V"			,; // 14 - Visual
				Nil			,; // 15 - Val. User
				Nil			 } // 16 - PictVar		

aAdd(aHeaDad, aClone(aHeaAux))

aAdd(aColsSize , {"OV_NOMPROD" , 350 } )

aHeaAux	:= {  "Produto"	,; // 01 - Titulo
			  "OV_PRODUTO"	,; // 02 - Campo
				"@!"		,; // 03 - Picture
				TamSX3("B1_COD")[1]			,; // 04 - Tamanho
				0  			,; // 05 - Decimal
				Nil			,; // 06 - Valid
				"x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     "			,; // 07 - Usado
				"C"			,; // 08 - Tipo
				"SB1"		,; // 09 - F3
				"R"			,; // 10 - Contexto
				Nil			,; // 11 - Box - Opcoes do combo
				Nil			,; // 12 - Ini. Padrao
				""		    ,; // 13 - When
				""          ,; // 14 - Visual
				'ExistCpo("SB1")',; // 15 - Val. User
				Nil			 } // 16 - PictVar
		
aAdd(aHeaDad, aClone(aHeaAux))

aAdd(aColsSize , {"OV_PRODUTO" , 80 } )

Return

/*/{Protheus.doc}''
''
@author Sergio Celestino
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/	
Static Function ACOLS_OV()
Local aColAux := {}
Local cPrdGen := Alltrim(GetMv("OV_PRODGEN",,"GEN001"))

SDT->(dbGotop())
SDT->(dbSetOrder(2))
SDT->(dbSeek(SDS->(DS_FILIAL+DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)))

While SDT->(!EOF()) .AND. SDT->(DT_FILIAL+DT_FORNEC+DT_LOJA+DT_DOC+DT_SERIE) == SDS->(DS_FILIAL+DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)
	aColAux := {}
	
	If Alltrim(SDT->DT_COD)==cPrdGen
		aAdd(aColAux, SDT->DT_ITEM)	
		aAdd(aColAux, SDT->DT_PRODFOR)
		aAdd(aColAux, SDT->DT_DESCFOR)		
		aAdd(aColAux, SDT->DT_COD)
		aAdd(aColAux, .F.)

		aAdd(aColDad, aClone(aColAux))
	Endif
	SDT->(DbSkip())
EndDo

Return

/*/{Protheus.doc}'fSalvar'
''
@author Sergio Celestino
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/	
Static Function fSalvar(lRet)
	Local nItens := 1

	dbSelectArea("SA2")
	dbSetOrder(1)
	If dbSeek( xFilial("SA2") + SDS->(DS_FORNEC+DS_LOJA) )
		If !Empty(SA2->A2_XUNICO) .And. SA2->A2_XESTOQU=="S"
			For nItens := 1 To Len(oGetDad:aCols)
				SDT->(dbGotop())
				SDT->(dbSetOrder(8)) //DT_FILIAL+DT_FORNEC+DT_LOJA+DT_DOC+DT_SERIE+DT_ITEM                                                                                                             
				if SDT->(dbSeek(SDS->(DS_FILIAL+DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE+Alltrim(oGetDad:aCols[nItens][1]))))
					lRet := .T.
					Reclock("SDT",.F.)
					SDT->DT_COD := oGetDad:aCols[nItens][4]
					MsUnLock()
					If SA2->A2_XUNICO=="S"
						DbSelectarea("SA5")
						DbSetorder(14) // A5_FILIAL+A5_FORNECE+A5_LOJA+A5_CODPRF ( UNICO - A5_FILIAL+A5_FORNECE+A5_LOJA+A5_PRODUTO+A5_FABR+A5_FALOJA+A5_REFGRD)
						Dbgotop()
						if Dbseek( xFilial("SA5") + SDS->(DS_FORNEC+DS_LOJA) + Padr( oGetDad:aCols[nItens][2] , TamSx3("A5_CODPRF")[1]) )
							dbSelectArea("SB1")
							dbSetOrder(1)
							If dbSeek( xFilial("SB1") + Padr(oGetDad:aCols[nItens][4],TamSX3("B1_COD")[1]) )
								Reclock("SA5",.F.)
								SA5->A5_PRODUTO  := SB1->B1_COD
								SA5->A5_NOMPROD  := SB1->B1_DESC
								MsUnLock()
							Endif	
						Endif
					Endif	
				Endif
			Next
		Else
			Aviso("Atenção","O Fornecedor "+SA2->A2_COD+"-"+SA2->A2_LOJA+" :"+Alltrim(SA2->A2_NOME)+", se encontra com o campo 'Codigo Unico' sem preenchimento.Verifique para prosseguir!",{"Ok"})
			lRet := .F.
		Endif	
	Endif	
	
	if lRet
		oTela:End()
		Aviso("Atenção","Produtos atualizados com sucesso!",{"Prosseguir"})
	Endif

	Return lRet
