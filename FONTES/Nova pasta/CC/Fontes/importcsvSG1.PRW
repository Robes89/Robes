#INCLUDE "PROTHEUS.CH"

User Function ImporSG1()

	If !MSGYESNO( 'Existe arquivo de importaçao da estrutura na pasta: c:\protheus\import\estrut.csv')
		Return
	Endif
	
	MsAguarde({|lEnd| gravaSG1(@lEnd) },"Importando cadastro de estrutura...","Cadastro Estrutura",.T.)
 
Return


Static function gravaSG1(lEnd)

nHandle := FT_FUse("c:\protheus\import\estrut.csv")
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
		dbselectarea("SG1")
		SG1->(dBsetorder(1))
        SG1->(dBSeek(xFilial("SG1")+aRet[1]+aRet[2]+aRet[3]))
		
		If  SG1->(!Eof()) .And. SG1->G1_TRT=aRet[3]
    	       RecLock("SG1",.F.)
		      	  DbDelete()
		       MSUNLOCK()

		       RecLock("SG1",.t.)
				    SG1->G1_FILIAL=xFilial('SG1')
				    SG1->G1_COD:=aRet[1]
				    SG1->G1_COMP:=aRet[2]
				    SG1->G1_TRT:=aRet[3]
				    SG1->G1_QUANT:=Val(aRet[4])
				    SG1->G1_REVINI:=aRet[3]
				    SG1->G1_REVFIM:=aRet[3]			    
				    SG1->G1_INI:=dDataBase
				    SG1->G1_FIM:=CTod('01/01/2049')
				    SG1->G1_FIXVAR:='V'
				    SG1->G1_NIV:='01'
				    SG1->G1_NIVINV:='99'
				    SG1->G1_USAALT:='1'				    
		       MSUNLOCK()
		Else 
		       	RecLock("SG1",.t.)
				    SG1->G1_FILIAL=xFilial('SG1')
				    SG1->G1_COD:=aRet[1]
				    SG1->G1_COMP:=aRet[2]
				    SG1->G1_TRT:=aRet[3]
				    SG1->G1_QUANT:=val(aRet[4])
				    SG1->G1_REVINI:=aRet[3]
				    SG1->G1_REVFIM:=aRet[3]			    
				    SG1->G1_INI:=dDataBase
				    SG1->G1_FIM:=CTod('01/01/2049')
				    SG1->G1_FIXVAR:='V'
				    SG1->G1_NIV:='01'
				    SG1->G1_NIVINV:='99'
				    SG1->G1_USAALT:='1'				    
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