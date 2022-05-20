#include 'protheus.ch'
#include 'fwbrowse.ch'
/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! Desmembrar                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Descrio          ! Funcao principal para rotina desmembramento lote					   	       !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Totvs Curitiba                                                                !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 23/01/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A										                                   !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/
User Function Desmembrar(cCaller)

	Local _nX
	
	Local _nQtdProd		:=	0
	Local _nVlTot		:=	0
	Local _nQtdSug		
	Local nQtdFix, nTotalFix
	Local _nQtdLotes 	:=	0
	Local _aRetParam	:=	{}
	Local _cItem		:=	"000"
	
	
	Private _cCodProd		:=	""	
	Private _aDadosDesm		:=	{}
	Private aItens			:=	{}
	Private _lContinua		:=	.F.
	Private _nPosCodProd	:=	AScan( aHeader, { |x,y| Upper( AllTrim( x[2] ) ) == "D1_COD" } )
	Private _nPosQuantProd	:=	AScan( aHeader, { |x,y| Upper( AllTrim( x[2] ) ) == "D1_QUANT" } )
	Private _nPosTotal		:=	AScan( aHeader, { |x,y| Upper( AllTrim( x[2] ) ) == "D1_TOTAL" } )
	Private _nPosValor		:=	AScan( aHeader, { |x,y| Upper( AllTrim( x[2] ) ) == "D1_VUNIT" } )
	Private _nPosLote		:=	AScan( aHeader, { |x,y| Upper( AllTrim( x[2] ) ) == "D1_LOTECTL" } )
	Private _nPosSubL		:=	AScan( aHeader, { |x,y| Upper( AllTrim( x[2] ) ) == "D1_NUMLOTE" } ) 
	Private _nPosDtValid	:=	AScan( aHeader, { |x,y| Upper( AllTrim( x[2] ) ) == "D1_DTVALID" } )
		
	//Busca codigo do produto
	_cCodProd 		:=	ACOLS[oGetDados:oBrowse:NROWPOS][_nPosCodProd]
	_nQtdProd		:=	ACOLS[oGetDados:oBrowse:NROWPOS][_nPosQuantProd]
	_nVlTot			:=	ACOLS[oGetDados:oBrowse:NROWPOS][_nPosValor]		
			
	//Verifica se sistema parametrizado para realizar rastreio produto
	If GETMV("MV_RASTRO") == "S"
	
		//Verifica se produto tem rastreio
		If !ControlRastro(_cCodProd)
			alert('Esse produto não tem rastreamento e não pode ser desmembrado.')
		else
		
			//Pergunta ao usuario se deseja realizar desmembramento lote produto
			If MsgYesNo("Tem certeza que deseja realizar o desmembramento do produto " + Alltrim(_cCodProd) + " - " + POSICIONE("SB1", 1, xFilial("SB1") + _cCodProd, "B1_DESC"))
			
				//Usuario informa a quantidade de lotes a ser desemembrado
				_aRetParam := ParamInput()
				
					//Valida preenchimento correto do parametro
					If _aRetParam[1]
					
						//Valida conteúdo parametro
						If isnumeric(Alltrim(_aRetParam[2]))
						
							_nQtdLotes 	:= round(Val(_aRetParam[2]),2)
							_nQtdSug 	:= round(_nQtdProd / _nQtdLotes,2)
				
							//Monta array com dados a serem exibidos na tela de desmembramento
							nTotalFix:=0
							For _ix:=1 To _nQtdLotes
								
								if _ix!=_nQtdLotes
									nQtdFix:=NOROUND(_nQtdSug,0)
									nTotalFix+=nQtdFix
								else
									nQtdFix:=_nQtdProd-nTotalFix
								endif
								
								AADD(_aDadosDesm,{ nQtdFix, Space(TamSX3("D1_LOTECTL")[1]), Space(TamSX3("D1_NUMLOTE")[1]), CTOD("") })
							
							Next _i
							
							//Exibe para o usuario tela para preenchimento do desmembramento
							InputDesmemb(_aDadosDesm)
							
							If _lContinua
							
								n := 1
								
								If (cCaller=='MATA103' .AND. A103TudOk()) .OR. (cCaller=='MATA140' .AND. Ma140TudOk())                                 
								
									//Preenche browse com novas linhas
									For _jx:=1 To _nQtdLotes
									
										_cItem		:=	Soma1(_cItem)
										_nQuant		:=	aItens[_jx][1]
										_nValor		:=	ACOLS[oGetDados:oBrowse:NROWPOS][_nPosValor] /// _nQtdLotes
										_nTotal		:=	_nQuant * _nValor
										_cLote		:=	Alltrim(aItens[_jx][2])
										_cSubLote	:=	Alltrim(aItens[_jx][3])
										_cData		:=	aItens[_jx][4]

										AtualizaCampos(cCaller, _cItem, _nQuant, _nValor, _nTotal, _cLote, _cSubLote, _cData, oGetDados:oBrowse:NROWPOS)
										
									Next _jx
								
								EndIf
							
							EndIf	
					
					Else
						
						MsgStop("Conteúdo digitado deve ser númerico!","Atenção")
						
					EndIf
				
				EndIf
			
			EndIf
				
		EndIf
		
	EndIf
	
return

/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! fSetField                                                                     !
+------------------+-------------------------------------------------------------------------------+
! Descrio          ! Funcao para atualizar dados dados no browse do documento de entrada   	       !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Totvs Curitiba                                                                !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 23/01/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! Array com dados iniciais para desemembramento                                 !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/
Static Function fSetField( nPosLin, nPosField, cField, xValue  )

	Local cBkpReadVar 	:= __ReadVar
	Local lOk			:= .T.
	
	M->&( cField ) := aCols[ nPosLin, nPosField ] := xValue
	__ReadVar := "M->" + cField
	
	cField := PadR( cField, Len( SX3->X3_CAMPO ), " " )
	
	SX3->( dbSetOrder(2) )//X3_CAMPO
	SX3->( dbSeek( cField ) )
	If !Empty( SX3->X3_VALID )
		lOk := &(AllTrim( SX3->X3_VALID ))
	EndIf
	
	If lOk
		If ExistTrigger( cField )
			RunTrigger(2,nPosLin,,oGetDados, cField)
		EndIf
	EndIf
	
	__ReadVar := cBkpReadVar

Return

/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! InputDesmemb                                                                  !
+------------------+-------------------------------------------------------------------------------+
! Descrio          ! Tela para usuario informar dados do desmembramento do produto       	       !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Totvs Curitiba                                                                !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 23/01/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! Array com dados iniciais para desemembramento                                 !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/
Static Function InputDesmemb(_aItens)
	Local oPnlList, aColumns
     Local oOk     		:= LoadBitMap(GetResources(), "LBOK")		//Check True
     Local oNo     		:= LoadBitMap(GetResources(), "LBNO")		//Check False
     Local oBmpSim		:= LoadBitmap( GetResources(), "ENABLE")	//Se Gerou movimento bancario
     Local oBmpNao		:= LoadBitmap( GetResources(), "DISABLE")	//Se nao gerou movimento bancario

	Private oDlg
	Private oList
	Private oBrowse
	Private nQuant, cLote, cNumLote, dValid
	
	aItens := _aItens	
	LoadLine(1)

	DEFINE MSDIALOG oDlg TITLE "Desmembramento lote produto " + Alltrim(_cCodProd) + " - " + POSICIONE("SB1", 1, xFilial("SB1") + _cCodProd, "B1_DESC")  FROM 0,0 TO 450,600 PIXEL
	
		Define Font oFont Name 'Courier New' Size 0, -12 
		
		aColumns:={;
				addColumn({|| aItens[oList:At()][1] },"Quantidade"  ,TamSX3('D1_QUANT')[1],TamSX3('D1_QUANT')[2],"N",X3Picture('C7_QUANT'),'nQuant') ,;
				addColumn({|| aItens[oList:At()][2] },"Lote"        ,TamSX3('D1_LOTECTL')[1],,"C",X3Picture('D1_LOTECTL'), 'cLote'), ;                                 
				addColumn({|| aItens[oList:At()][3] },"Sub Lote"    ,TamSX3('D1_NUMLOTE')[1],,"C",X3Picture('D1_NUMLOTE'), 'cNumLote'), ;				
				addColumn({|| aItens[oList:At()][4] },"Dt Validade" ,TamSX3('D1_DTVALID')[1],,"D",'@D', 'dValid');			
		}
			
		oPnlList:= TPanel():New(1,1,,oDlg,,.T.,,,,300, 200)
		oList := FWBrowse():New()
		oList:SetDescription("Desmembramento lote produto")
		oList:setOwner(oPnlList)
		oList:setDataArray()
		oList:setArray(aItens)
		oList:setColumns(aColumns)	 

		oList:disableReport()
		oList:disableConfig()
		oList:disableFilter()
		oList:SetEditCell(.T., {|lCancel,oList| ValidaRow(lCancel,oList)}) 
		oList:SetChange({|| LoadLine(oList:At())}) 
		oList:activate()
		
		oBtn := TButton():New( 210, 010,'Confirmar' , oDlg,{||U_LoadLinhas()},70, 010,,,.F.,.T.,.F.,,.F.,,,.F. )
		oBtn := TButton():New( 210, 220,'Cancelar' , oDlg,{||oDlg:End()},70, 010,,,.F.,.T.,.F.,,.F.,,,.F. )

		ACTIVATE MSDIALOG oDlg CENTERED
		
Return


/*---------------------------------------------------------------------------------------------------------+
|  LoadLine -                                                       |
-----------------------------------------------------------------------------------------------------------*/
static function LoadLine(nLine)
    nQuant:= aItens[nLine][1]    
	cLote:=aItens[nLine][2]    
	cNumLote:= aItens[nLine][3]   
	dValid:=aItens[nLine][4]
return

/*---------------------------------------------------------------------------------------------------------+
|  ValidaRow -                                                       |
-----------------------------------------------------------------------------------------------------------*/
static function ValidaRow(lCancel,oBrwItens)
	Local lRet:=.T.
	if !lCancel
		if (nQuant - int(nQuant)!= 0) .AND. (oBrwItens:At()!=Len(aItens)) 
			lRet:=.F.
			Alert('Você só pode informar a parte decimal no ultimo lote!')
		else
		    aItens[oList:At()][1]:=nQuant    
		    aItens[oList:At()][2]:=cLote    
		    aItens[oList:At()][3]:=cNumLote    
		    aItens[oList:At()][4]:=dValid
		endif
    endif    
return lRet

/*---------------------------------------------------------------------------------------------------------+
|  addColumn -                                                       |
-----------------------------------------------------------------------------------------------------------*/
static function addColumn(bData,cTitulo,nTamanho,nDecimal,cTipo,cPicture, cReadVar)
	Local oColumn

	oColumn:= FWBrwColumn():New()
						
	oColumn:SetEdit(.T.)
	oColumn:SetReadVar(cReadVar)
		
	oColumn:SetData( bData )
	oColumn:SetTitle(cTitulo)
	oColumn:SetSize(nTamanho)
	IF nDecimal != Nil
		oColumn:SetDecimal(nDecimal)
	EndIF
	oColumn:SetType(cTipo)
	IF cPicture != Nil
		oColumn:SetPicture(cPicture)
	EndIF
	oColumn:setAlign( IIF(cTipo == "N",COLUMN_ALIGN_RIGHT,IIF(cTipo == "D",COLUMN_ALIGN_CENTER,COLUMN_ALIGN_LEFT)) )

return oColumn

User Function LoadLinhas()

	Local _nTotal 	:= 	0
	Local _lRet 	:=	.T.
	Local _lData	:=	.T.

	//Valida valor total linhas
	For _ix:=1 to Len(aItens)
	
		//Valida digitacao lote e sublote
		If Empty(Alltrim(aItens[_ix][2]))
			MsgStop("Lote não foi informado!", "Atenção!")
			Return .F.
		EndIf
		
		/*If Empty(Alltrim(aItens[_ix][3]))
			MsgStop("SubLote não foi informado!", "Atenção!")
			Return .F.
		EndIf		*/
		
		//Valida se foi digitada data corretamente
		If Empty(aItens[_ix][4])
			MsgStop("Data em branco! Favor preencher corretamente!", "Atenção!")
			Return .F.
		Else
			
			//Se data informada menor que a data atual
			If aItens[_ix][4] < date()
				MsgStop("Data informada é menor que a data atual. Informe uma data superior ou igual a data atual!", "Atenção!")
				Return .F.
			EndIf
			
		EndIf
		
		//Somatorio item
		_nTotal += aItens[_ix][1]
		
	Next _ix
	
	//Alterado Round (Rodrigo Sena - 13/09/2021)
	//If round(_nTotal,1) != ACOLS[oGetDados:oBrowse:NROWPOS][_nPosQuantProd]
	If _nTotal != ACOLS[oGetDados:oBrowse:NROWPOS][_nPosQuantProd]
		MsgStop("Valor digitado diverge do valor total do item","Atenção!")
		_lRet := .F.
	Else
		oDlg:End()
		_lContinua := .T.
	EndIf

Return _lRet

/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! ParamInput                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Descrio          ! Verifica se o produto tem controle rastro lote ou sublote				       !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Totvs Curitiba                                                                !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 23/01/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! Codigo do produto                                                             !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! True ou False                                                                 !
+------------------+-------------------------------------------------------------------------------+
*/
Static Function ParamInput()
    
    Local aPergs   := {}
    
    Local aRet	   := {}
    Local _aRet	   := {.F.,""}
    Private cRecDest := space(3)

    aAdd( aPergs ,{1,"Quantidade de cargas(lotes)",cRecDest,"!@",'',,'.T.',3,.T.})
 
    If ParamBox(aPergs ,"Desmembrar em quantas cargas(lotes)?",aRet)
        If !(Empty(aRet[1]) )
        	_aRet := {.T.,aRet[1]}
        Else
        	MsgAlert("Favor preencher os parâmetros corretamente!","Atenção!")
        	_aRet := {.F.,"Parâmetro vazio"}
        EndIf

    Else
        MsgAlert("Operação abortada pelo usuário!","Atenção!")
        _aRet := {.F.,"Processo abortado pelo usuário"}

    EndIf

Return _aRet

/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! ControlRastro                                                                 !
+------------------+-------------------------------------------------------------------------------+
! Descrio          ! Verifica se o produto tem controle rastro lote ou sublote				       !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Totvs Curitiba                                                                !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 23/01/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! Codigo do produto                                                             !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! True ou False                                                                 !
+------------------+-------------------------------------------------------------------------------+
*/
Static Function ControlRastro(_cProd)

	Local _aControlRastro 	:=	GetArea()
	Local _lRet 			:=	.F.
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1") + _cProd)
	
	If SB1->B1_RASTRO <> "N"
		_lRet := .T.
	EndIf
	
	RestArea(_aControlRastro)

Return _lRet

/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! AtualizaCampos                                                                !
+------------------+-------------------------------------------------------------------------------+
! Descrio          ! Funcao responsavel por atualizar o browse								       !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Totvs Curitiba                                                                !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 29/01/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! Item, Quantidade, Valor, Total, Lote, Sublote, Data e linha atual             !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! True ou False                                                                 !
+------------------+-------------------------------------------------------------------------------+
*/
Static Function AtualizaCampos( cCaller, _cItem, _nQuant, _nValor, _nTotal, _cLote, _cSubLote, _cData, _nLinha )

	Local aArea		:= GetArea( )
	Local aAreaSB1	:= SB1->( GetArea( ) )
	Local lRet 		:= .F.
	Local cItemAtu	:= ""
	Local nPosDel	:= Len( aHeader ) + 1
	Local nPosItem	:= AScan( aHeader, { |x,y| Upper( AllTrim( x[2] ) ) == "D1_ITEM" } )
	Local nPosCod	:= AScan( aHeader, { |x,y| Upper( AllTrim( x[2] ) ) == "D1_COD" } )
	Local nPosQuant	:= AScan( aHeader, { |x,y| Upper( AllTrim( x[2] ) ) == "D1_QUANT" } )
	Local nPosVUnit	:= AScan( aHeader, { |x,y| Upper( AllTrim( x[2] ) ) == "D1_VUNIT" } )
	Local nPosTotal	:= AScan( aHeader, { |x,y| Upper( AllTrim( x[2] ) ) == "D1_TOTAL" } )
	Local nPosTES	:= AScan( aHeader, { |x,y| Upper( AllTrim( x[2] ) ) == "D1_TES" } )
	Local nDecimais	:= TamSX3("D1_VUNIT")[2]
	Local cChvSG1	:= ""
	Local nPosLin	:= 0
	Local aLinAux	:= { }
	Local cTesAtu	:= ""
	Local nX		:= 0
	Local nValTot	:= 0
	Local nTotOri	:= 0
	Local nResto	:= 0
	Local nQtdeIt	:= 0
	Local nVUnit	:= 0
	Local nVTotal	:= 0
	Local nPerc		:= 0
	Local aColsBKP	:= AClone( aCols )
	Local nLinBkp	:= n
	Local cItemAtu 	:= Soma1( aCols[ Len(aCols), nPosItem ] )
	Local nPosDel	:= Len( aHeader ) + 1
	
	if cCaller=='MATA103'
		cTesAtu			:= aCols[n,nPosTES]
	endif
	
	n := _nLinha
	nPosLin := _nLinha

	nPosLin	:= Len( aCols ) + 1
	
	If !aCols[n,nPosDel] .And. !Empty( aCols[n,nPosCod] ) 
		
		aCols[_nLinha,nPosDel]	:= .T.
		
		if cCaller=='MATA103'
			NfeDelItem()
		endif
	EndIf
	
	If (cCaller=='MATA103' .AND. !A103LinOk()) .OR. (cCaller=='MATA140' .AND. !Ma140LinOk()())
		lRet := .F.		
	Else
		AAdd(aCols,Array(Len(aHeader)+1))

		lRet := .T.
		For nX := 1 to Len(aHeader)
			If IsHeadRec(aHeader[nX][2])
			    aCols[Len(aCols)][nX] := 0						    
			ElseIf IsHeadAlias(aHeader[nX][2])
			    aCols[Len(aCols)][nX] := "SD1"
			ElseIf Trim(aHeader[nX][2]) == "D1_ITEM"
				aCols[Len(aCols)][nX] 	:= cItemAtu
			Else
				aCols[Len(aCols)][nX] := CriaVar(aHeader[nX][2], (aHeader[nX][10] <> "V") )
			EndIf
			aCols[Len(aCols)][Len(aHeader)+1] := .F.
		Next nX
		
		n := nPosLin
		
		//Posiciona produto
		fSetField( nPosLin, nPosCod		, "D1_COD"	, _cCodProd ) //SB1->B1_COD			
		fSetField( nPosLin, nPosQuant	, "D1_QUANT", _nQuant )
		fSetField( nPosLin, nPosVUnit	, "D1_VUNIT", _nValor )
		fSetField( nPosLin, nPosTotal	, "D1_TOTAL", _nTotal)
		fSetField( nPosLin, _nPosLote	, "D1_LOTECTL", _cLote )
		fSetField( nPosLin, _nPosSubL	, "D1_NUMLOTE", _cSubLote )
		fSetField( nPosLin, _nPosDtValid, "D1_DTVALID", _cData)
		
		if cCaller=='MATA103'
			A103Total(_nTotal)
			//Posiciona TES
			SF4->( dbSetOrder( 1 ) )//F4_FILIAL+F4_CODIGO
			SF4->( dbSeek( xFilial( "SF4" ) + cTesAtu ) )
			fSetField( nPosLin, nPosTES		, "D1_TES"	, cTesAtu )			
		else
		    StaticCall( mata140, Ma140Total, a140Total, a140Desp )
		    Pergunte("MTA140",.F.)
		endif
		
		nPosLin++
	
		oGetDados:lNewLine:=.F.  
		oGetDados:oBrowse:Refresh()

	EndIf
		
	If !lRet 
		aCols := aColsBKP
	EndIf

	n := nLinBkp

	RestArea( aAreaSB1 )
	RestArea( aArea )

Return lRet

/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! ValidData                                                                     !
+------------------+-------------------------------------------------------------------------------+
! Descrio          ! Valida formato data inputado pelo usuario								       !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Totvs Curitiba                                                                !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 23/01/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! Data 			                                                               !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! True ou False                                                                 !
+------------------+-------------------------------------------------------------------------------+
*/
Static function ValidData(_cData)

	Local _lRet := .F.
	
	If Substr(_cData,3,1) == "/" .and. Substr(_cData,6,1) == "/" .and. IsNumeric(Substr(_cData,1,2)).and. IsNumeric(Substr(_cData,4,2)) .and. IsNumeric(Substr(_cData,7,4))
		_lRet := .T. 
	EnDIf

Return _lRet 
