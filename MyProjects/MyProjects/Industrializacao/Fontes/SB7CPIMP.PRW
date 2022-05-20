User Function ImportcsvLT()

	If !MSGYESNO( 'Existe arquivo de importaçao na pasta: c:\PROTHEUS\IMPORT\SB7CPIMP.csv')
		Return
	Endif
	
	If !MSGYESNO( 'O Layout do arquivo esta conforme a estrutura: DATA,CODiGO,LOCAL,LOCALIZ,NUMSERI,LOTECTL,NUMLOTE,CONTAGE,QUANTIDADE') 
		Return
	Else 	 
		MsAguarde({|lEnd| gravatxt(@lEnd) },"Importando SB7(INVENTARIO) txt...","Atualização SB7",.T.)
	Endif 
 
Return


Static function gravatxt(lEnd)
cRet01:=ctod(' /  /  ')
cRet02:=""
cRet03:=""
cRet04:=''
cRet05:=''
cRet06:=""
cRet07:=""
cRet08:=""
cRet09:=""
cRet10:=0

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
	If !aRet[1]$"DTBASE"
			
		//B7_FILIAL+
		//DTOS(B7_DATA)+aRet[1]
		//B7_COD+ 		aRet[2]
		//B7_LOCAL+ 	aRet[3]
		//B7_DOC    	aRet[4]
		//B7_LOCALIZ+ 	aRet[5]
		//B7_NUMSERI+ 	aRet[6]
		//B7_LOTECTL+ 	aRet[7]
		//B7_NUMLOTE+ 	aRet[8]
		//B7_CONTAGE  	aRet[9]
		  
		cRet01:=ctod(aLLtrim(aRet[01]) ) //data
		cRet02:=Alltrim(aRet[02]) + space((15-len(Alltrim(aRet[02])) )) //Codigo
		cRet03:=Alltrim(aRet[03]) + space((02-len(Alltrim(aRet[03])) ))	//local
		cRet04:=Alltrim(aRet[04])
		cRet05:=Alltrim(aRet[05]) + space((15-len(Alltrim(aRet[05])) )) //localiza�ao
		If Alltrim(aRet[06]) != '0'
			cRet06:=Alltrim(aRet[06]) + space((20-len(Alltrim(aRet[06])) )) //Numserie
		Else
			cRet06:=""
		Endif 	
		cRet07:=Alltrim(aRet[07]) + space((10-len(Alltrim(aRet[07])) )) //lote
		cRet08:=Alltrim(aRet[08])
		cRet09:=Alltrim(aRet[09])
		cRet10:=Alltrim(aRet[10]) // Quantidade
		cRet11:=ctod(aLLtrim(aRet[11]) ) //data 

		SB1->(dbgotop()) 
		SB1->(dBsetorder(1))
        SB1->(dBSeek(xFilial("SB1")+ cRet02 ))
		
		SBE->(dbgotop()) 
		SBE->(dBsetorder(1))
        SBE->(dBSeek(xFilial("SBE")+ cRet03 + cRet05 ))
			
		If SB1->(!Eof()) .and. SB5->(!Eof()) 

			dbselectarea("SB7")
			SB7->(dBsetorder(1))
			SB7->(dBSeek(xFilial("SB7")+dtos(cRet01) + cRet02 + cRet03 + cRet05 + cRet06 + cRet07 ))
			
			If  SB7->(!Eof()) .AND. SB7->B7_STATUS='1'
				RecLock("SB7",.F.)
					SB7->B7_QUANT:=VAL(cRet10)
				MSUNLOCK()
			Else  
				RecLock("SB7",.t.)
					SB7->B7_FILIAL:=xFilial('SB7')
					SB7->B7_DATA:= cRet01
					SB7->B7_COD:=	cRet02
					SB7->B7_LOCAL:=	cRet03
					SB7->B7_DOC:=cRet04
					SB7->B7_LOCALIZ:=cRet05
					SB7->B7_NUMSERI:=cRet06
					SB7->B7_LOTECTL:=cRet07
					SB7->B7_NUMLOTE:='SALINI'
					SB7->B7_CONTAGE:='001'
					SB7->B7_QUANT:=VAL(cRet10)
					SB7->B7_STATUS:='1'
					SB7->B7_TIPO:=SB1->B1_TIPO 
					SB7->B7_DTVALID:=cRet11
					
				MSUNLOCK()
			Endif
		Else
			MsProcTxt("Produto ou localiza��o n�o cadastrados: "+dtos(cRet01)+'| |'+cRet02+'| |'+cRet03+'| |'+cRet04)	    	 		
		  
		Endif    		   
	Endif                         // FIM DA GRAVACAO NO TMP
	// Pula para próxima linha
	FT_FSKIP()
	
	MsProcTxt("Lendo tabela: "+dtos(cRet01)+cRet02+cRet03)
    ProcessMessage()
End

FT_FUSE() //FIM DA LEITURA DO TXT
Return
