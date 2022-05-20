User Function Importultp()

If !MSGYESNO( 'Existe arquivo de importaçao na pasta: c:\sx3\ultprc.txt')
	Return
Endif

nHandle := FT_FUse("c:\sx3\ultprc.txt")
If nHandle = -1 
	MSGYESNO( 'Arquivo não encontrado!!')
	return
Endif

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
	cLINHA2:= strtran(cLINHA,";;",";0;",2,9) //SUBSTITUIR ";;" POR ";0;" EM TODO O TXT 
	cLINHA3:= strtran(cLINHA,"," ,'') //SUBSTITUIR ";;" POR ";0;" EM TODO O TXT
	
	aRet    := StrTokArr(cLINHA3,";") // Resultado: aRet[1]="Primeiro" / aRet[2]="Segundo" / aRet[3]="Terceiro" 
	
	///VERIFICA SE É O CABEÇALHO 
	If !aRet[1]$"B2_COD"
		
		
		SB1->(dBsetorder(1))
        SB1->(dBSeek(xFilial("SB1")+aRet[1]))
		
		If  SB1->(!eof())
		       RecLock("SB1",.F.)
		      	SB1->B1_UPRC:=Val(Alltrim(aRet[3]))/1000
		       MSUNLOCK()
		Endif    		   
	Endif                         // FIM DA GRAVACAO NO TMP
	// Pula para próxima linha
	FT_FSKIP()
End
// Fecha o Arquivo
FT_FUSE() //FIM DA LEITURA DO TXT