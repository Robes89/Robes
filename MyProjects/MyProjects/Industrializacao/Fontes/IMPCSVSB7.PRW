
User Function ImpcsvSB7()

	If !MSGYESNO( 'Existe arquivo de importaçao na pasta: c:\PROTHEUS\IMPORT\SB7CPIMP.csv')
		Return
	Endif
	
	If !MSGYESNO( 'O Layout do arquivo esta conforme a estrutura: DATA|CODiGO|LOCAL|LOCALIZ|NUMSERI|LOTECTL|NUMLOTE|CONTAGE|QUANTIDADE') 
		Return
	Else  
		MsAguarde({|lEnd| gravatxt(@lEnd) },"Importando SB7(INVENTARIO) txt...","Atualização SB7",.T.)
    Endif 
Return


Static function gravatxt(lEnd)

nHandle := FT_FUse("c:\PROTHEUS\IMPORT\SB7CPIMP.csv")
If nHandle = -1 
	MSGYESNO( 'Arquivo não encontrado!!')
	return
Endif
// 7527441 

// Posiciona na primeria linha
FT_FGoTop()
// Retorna o número de linhas do arquivo
nLast := FT_FLastRec()
MsgAlert( nLast )

While !FT_FEOF() 
	cLine := FT_FReadLn() // Retorna a linha corrente
	nRecno := FT_FRecno() // Retorna o recno da Linha
	//MsgAlert( "Linha: " + cLine + " - Recno: " + StrZero(nRecno,3) ) 
	   
	cTextArr:= cLine //"Primeiro;Segundo;Terceiro" 
	cLINHA:=   strtran(cLine,";;",";0;",1,9) //SUBSTITUIR ";;" POR ";0;" EM TODO O TXT
	cLINHA2:=  strtran(cLINHA,";;",";0;",2,9) //SUBSTITUIR ";;" POR ";0;" EM TODO O TXT 
	cLINHA3:=  strtran(cLINHA,"," ,'') //SUBSTITUIR ";;" POR ";0;" EM TODO O TXT

	aRet    := StrTokArr(cLINHA3,";")
	
	///VERIFICA SE É O CABEÇALHO 
	If !aRet[2]$"DTBASE"
		
		aRet[1]:=Alltrim(aRet[1])
		dbselectarea("SB7")
		SB7->(dBsetorder(1))
		
		//B7_FILIAL+
		//DTOS(B7_DATA)+aRet[2]
		//B7_COD+ 		aRet[3]
		//B7_LOCAL+ 	aRet[4]
		//B7_LOCALIZ+ 	aRet[5]
		//B7_NUMSERI+ 	aRet[6]
		//B7_LOTECTL+ 	aRet[7]
		//B7_NUMLOTE+ 	aRet[8]
		//B7_CONTAGE  	aRet[9]
		//B7_DTVALID    aRet[10]
		//B7_DOC        aRet[11]
		  
        SB7->(dBSeek(xFilial("SB7")+aRet[02]+aRet[03]+aRet[04]+aRet[05]+aRet[06]+aRet[07]+aRet[08]+aRet[09]))
		
		If  SB7->(!Eof()) .AND. SB7->B7_STATUS='1'
		       RecLock("SB7",.F.)
		      	 SB7->B7_QUANT:=VAL(ARet[11])
		       MSUNLOCK()
		Else  
		    RecLock("SB7",.t.)
			    SB7->B7_FILIAL:=xFilial('SB7')
				SB7->B7_DATA:=STOD(aRet[01])
			    SB7->B7_COD:=aRet[02]
			    SB7->B7_LOCAL:=aRet[03]
				SB7->B7_DOC:=aRet[04]	
			    SB7->B7_LOCALIZ:=aRet[05]
			    SB7->B7_NUMSERI:=aRet[06]
				SB7->B7_LOTECTL:=aRet[07]
				SB7->B7_NUMLOTE:=aRet[08]
				SB7->B7_CONTAGE:=aRet[09]
				SB7->B7_QUANT:=VAL(ARet[10])
				SB7->B7_DTVALID:=STOD(aRet[11])		
				SB7->B7_STATUS:='1'
		    MSUNLOCK()
		  
		Endif    		   
	Endif                         // FIM DA GRAVACAO NO TMP
	// Pula para próxima linha
	FT_FSKIP()
	
	MsProcTxt("Lendo tabela: "+aRet[1]+aRet[2]+aRet[3])
    ProcessMessage()
End

FT_FUSE() //FIM DA LEITURA DO TXT
Return
