User Function ImportcsvLT()

	If !MSGYESNO( 'Existe arquivo de importaçao na pasta: c:\PROTHEUS\IMPORT\SB9CPIMP.csv')
		Return
	Endif
	
	MsAguarde({|lEnd| gravatxt(@lEnd) },"Importando SB9 txt...","Atualização SB9",.T.)
 
Return


Static function gravatxt(lEnd)

nHandle := FT_FUse("c:\PROTHEUS\IMPORT\SB9CPIMP.csv")
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
	If !aRet[1]$"CODIGO"
		
		aRet[1]:=Alltrim(aRet[1])
		dbselectarea("SB9")
		SA7->(dBsetorder(1))
        SA7->(dBSeek(xFilial("SA7")+aRet[1]+aRet[2]+aRet[3]))
		
		If  SA7->(!Eof())
		       RecLock("SA7",.F.)
		      	SA7->A7_REV:=aRet[4]
		       MSUNLOCK()
		Else 
		    RecLock("SA7",.t.)
			    SA7->A7_FILIAL=xFilial('SA7')
			    SA7->A7_CLIENTE:=aRet[1]
			    SA7->A7_LOJA:=aRet[2]
			    SA7->A7_PRODUTO:=aRet[3]
			    SA7->A7_REV:=aRet[4]
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