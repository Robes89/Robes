#Include "rwmake.ch"

User Function ATUB1()

If	MsgYesNo( "Confirma a atualização da tabela de preço ?" , "Confirmação..." )
	Processa( {|| ATUB1_1() } , "Atualização tabela de preço - SB1" )
EndIf

Return

*******************************************************************************************************************
Static Function ATUB1_1()    

oTemptable := FWTemporaryTable():New( "TRA")
oTempTable:Create()
//dbUseArea(.T.,"DBFCDX","\DEVELOP\LISTA\LISTAPRECO.DBF","TRA",.T.,.F.)

If	Select( "TRA" ) == 0
	MsgBox( "Erro na abertura do arquivo LISTAPRECO", "Erro..." , "STOP" )
	Return
EndIf

DbSelectArea( "TRA" )
TRA->( DbGoTop() )

ProcRegua( TRA->( LastRec() ) )

While !TRA->( Eof() )

	IncProc( "Atualizando produto » " + AllTrim( TRA->B1_COD ) )

	If	SB1->( DbSeek( xFilial( "SB1" ) + Left( TRA->B1_COD , 15 ) ) )
		RecLock( "SB1" )
		SB1->B1_DESC	:= TRA->B1_DESC
		SB1->B1_DENOM	:= TRA->B1_DENOM
		SB1->B1_PREURO	:= TRA->B1_PEURO
		SB1->B1_TRANSPR	:= TRA->B1_TRANSPR
		SB1->B1_GRUPDES	:= TRA->B1_GRUPDES
		SB1->B1_DESCONT	:= TRA->B1_DESCONT
		SB1->B1_PRV1	:= TRA->B1_PRV1
		SB1->B1_CAT   	:= TRA->B1_CAT    
		SB1->( MsUnLock() )
	EndIf

	TRA->( DbSkip() )

EndDo

TRA->( DbCloseArea() )

Return
