#INCLUDE 'TOTVS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FILEIO.CH'

/*/{Protheus.doc} REMLOTE
Envio de tÃ­tulos para cartÃ³rio
@author Juliano Souza TRIYO
@since 24/03/2021
@revision Juliano Souza TRIYO
@date 25/05/2021
/*/
User Function REMLOTE(nCartorio)
	Local aArea     := GetArea()
	Local lOk       := .F.
	Local cAmb      := ""
	Default nCartorio   := 0

	// Estabelece Comunicação com os Cartorios Homologados.
	If nCartorio == 1 // Remessa de dados para > CRA - SP
		cAmb := "CRA-SP"
		FWMsgRun(,{|| lOk := u_CRALOTE(.F., 1, {})}, "Aguarde...", "Schedule/Manual - Remessa de novos titúlos para Cartorio [ "+cAmb+" ]...")
	Endif

	// Finish
	if lOk
		ApMsgInfo("Comunicação com o Cartorio ["+cAmb+"] finalizado com sucesso!")
	else
		Alert("Não houve comunicação com o Cartório ["+cAmb+"]...")
	endif

	RestArea(aArea)

Return


User Function CONFCAR()
Local cSql			:= ""
Local clAlias		:= CriaTrab(Nil,.F.)
Local oDlg			:= Nil
Local aHeader		:= {}
Local aCols			:= {}
Local alFields      := {}
Local oOK 			:= LoadBitmap( nil, "BTNOKSMALL_OCEAN"	)  
Local oNO 			:= LoadBitmap( nil, "BTNCANSMALL_OCEAN" )
Local nY
	
	cSql := "SELECT * FROM SE1010 WHERE E1_NUMBOR = '" + cNumBor+"'

    If Select(clAlias) > 0; (clAlias)->(dbCloseArea()); Endif  
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),clAlias,.T.,.T.)




    (clAlias)->(dbGoTop())

	If (clAlias)->(! Eof())

	
		dbSelectArea("SX3")
        SX3->(dbSetOrder(2)) 

        aadd(alFields, "E1_NUM" 	)
		aadd(alFields, "E1_PREFIXO" 	)
        aadd(alFields, "E1_CLIENTE" 	)
        aadd(alFields, "E1_LOJA" 	)
        aadd(alFields, "E1_HIST" )
        aadd(alFields, "E1_XSITC" )
   
		//Criação do campo virtual para receber o bitmap.
		Aadd(aHeader, {	"OK",;
						"COR",;
						"@BMP",;
						1,;
						0,;
						.T.,;
						"",;
						"",;
						"",;
						"R",;
						"",;
						"",;
						.F.,;
						"V",;
						"",;
						"",;
						"",;
						"" })
        
        For nY := 1 To Len( alFields )
            If SX3->( dbSeek(alFields[ nY ] ) )
                Aadd( aHeader,{ TRIM(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, , SX3->X3_CONTEXT })
            EndIf
        Next nY
        
        While (clAlias)->( !Eof() )
	
            Aadd( aCols, {} )

			//Adiciona bitmap
			
				Aadd( aTail( aCols ), oNO )
			

            Aadd( aTail( aCols ), ( clAlias )->E1_NUM	)
			Aadd( aTail( aCols ), ( clAlias )->E1_PREFIXO		)	
            Aadd( aTail( aCols ), ( clAlias )->E1_CLIENTE 	)
            Aadd( aTail( aCols ), ( clAlias )->E1_LOJA 	)	
            Aadd( aTail( aCols ), 'Recebido Cartorio' 	)
            Aadd( aTail( aCols ), ( clAlias )->E1_XSITC 	)
          

			Aadd( aTail( aCols ), .F.)

            (clAlias)->(dbSkip())

	    EndDo

		DEFINE MSDIALOG oDlg TITLE "Analise resumida" FROM 005,000 TO 040,150 OF oMainWnd 
	
		oGet := MsNewGetDados():New(005,005,100,232,0,,,,,,,,,,oDlg,aHeader,aCols)
		oGet:obrowse:align:= CONTROL_ALIGN_ALLCLIENT
		oGet:nAt := oGet:OBROWSE:NAT := 1
	
		EnchoiceBar(oDlg, {|| If(len(aCols)>0,lPosicio:=.T.,lPosicio:=.F.), oDlg:End() },{|| oDlg:End() },,{} )
 
		oDlg:aControls[Len(oDlg:aControls)]:cCaption    := "Analise resumida" 
		oDlg:aControls[Len(oDlg:aControls)]:cTitle 	    := "Analise resumida" 
	
		ACTIVATE MSDIALOG oDlg CENTERED
		
	Else
		Help(" ",1, 'Help','TFINA080_ANA', "Não há dados de log.", 3, 0 )
	EndIf
	
	(clAlias)->(dbCloseArea())

Return


User Function RETCAR()
Local cSql			:= ""
Local clAlias		:= CriaTrab(Nil,.F.)
Local oDlg			:= Nil
Local aHeader		:= {}
Local aCols			:= {}
Local alFields      := {}
Local oOK 			:= LoadBitmap( nil, "BTNOKSMALL_OCEAN"	)  
Local oNO 			:= LoadBitmap( nil, "BTNCANSMALL_OCEAN" )
Local nY
	
	cSql := "SELECT * FROM SE1010 WHERE E1_NUMBOR = '" + cNumBor+"'

    If Select(clAlias) > 0; (clAlias)->(dbCloseArea()); Endif  
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),clAlias,.T.,.T.)




    (clAlias)->(dbGoTop())

	If (clAlias)->(! Eof())

	
		dbSelectArea("SX3")
        SX3->(dbSetOrder(2)) 

        aadd(alFields, "E1_NUM" 	)
		aadd(alFields, "E1_PREFIXO" 	)
        aadd(alFields, "E1_CLIENTE" 	)
        aadd(alFields, "E1_LOJA" 	)
        aadd(alFields, "E1_HIST" )
        aadd(alFields, "E1_XSITC" )
   
		//Criação do campo virtual para receber o bitmap.
		Aadd(aHeader, {	"OK",;
						"COR",;
						"@BMP",;
						1,;
						0,;
						.T.,;
						"",;
						"",;
						"",;
						"R",;
						"",;
						"",;
						.F.,;
						"V",;
						"",;
						"",;
						"",;
						"" })
        
        For nY := 1 To Len( alFields )
            If SX3->( dbSeek(alFields[ nY ] ) )
                Aadd( aHeader,{ TRIM(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, , SX3->X3_CONTEXT })
            EndIf
        Next nY
        
        While (clAlias)->( !Eof() )
	
            Aadd( aCols, {} )

			//Adiciona bitmap
			
				Aadd( aTail( aCols ), oNO )
			
			If (clAlias)->E1_NUM == '000000038'
				Aadd( aTail( aCols ), ( clAlias )->E1_NUM	)
				Aadd( aTail( aCols ), ( clAlias )->E1_PREFIXO		)	
				Aadd( aTail( aCols ), ( clAlias )->E1_CLIENTE 	)
				Aadd( aTail( aCols ), ( clAlias )->E1_LOJA 	)	
				Aadd( aTail( aCols ), 'Titulo Pago no Cartorio' 	)
				Aadd( aTail( aCols ), 'PAGO'	)
			Else
				Aadd( aTail( aCols ), ( clAlias )->E1_NUM	)
				Aadd( aTail( aCols ), ( clAlias )->E1_PREFIXO		)	
				Aadd( aTail( aCols ), ( clAlias )->E1_CLIENTE 	)
				Aadd( aTail( aCols ), ( clAlias )->E1_LOJA 	)	
				Aadd( aTail( aCols ), 'Titulo Pendente Cartorio' 	)
				Aadd( aTail( aCols ), "ENVIADO" 	)
			EndIf

			Aadd( aTail( aCols ), .F.)

            (clAlias)->(dbSkip())

	    EndDo

		DEFINE MSDIALOG oDlg TITLE "Analise resumida" FROM 005,000 TO 040,150 OF oMainWnd 
	
		oGet := MsNewGetDados():New(005,005,100,232,0,,,,,,,,,,oDlg,aHeader,aCols)
		oGet:obrowse:align:= CONTROL_ALIGN_ALLCLIENT
		oGet:nAt := oGet:OBROWSE:NAT := 1
	
		EnchoiceBar(oDlg, {|| If(len(aCols)>0,lPosicio:=.T.,lPosicio:=.F.), oDlg:End() },{|| oDlg:End() },,{} )
 
		oDlg:aControls[Len(oDlg:aControls)]:cCaption    := "Analise resumida" 
		oDlg:aControls[Len(oDlg:aControls)]:cTitle 	    := "Analise resumida" 
	
		ACTIVATE MSDIALOG oDlg CENTERED
		
	Else
		Help(" ",1, 'Help','TFINA080_ANA', "Não há dados de log.", 3, 0 )
	EndIf
	
	(clAlias)->(dbCloseArea())

Return

