//-------------------------------------------------------------------
/*/{Protheus.doc} function
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------

User Function Impcb0()

	If !MSGYESNO( 'Existe arquivo de importaçao na pasta: c:\sx3\aVldusr.csv')
		Return
	Endif
	
	MsAguarde({|lEnd| gravatxt(@lEnd) },"Importando txt...","Cadastro Revisao",.T.)
 
Return


Static function gravatxt(lEnd)

nHandle := FT_FUse("c:\sx3\aVldusr.csv")
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
	If !aRet[1]$"FILIAL"
		
		    RecLock("CB0",.t.)
			    CB0->CB0_FILIAL=xFilial('CB0')
			    CB0->CB0_CODETI:=aRet[2]			    
			    CB0->CB0_DTNASC:=Ddatabase
			    CB0->CB0_TIPO:='01'
			    CB0->CB0_CODPRO:= 
			    CB0->CB0_QTDE:=
			    CB0->CB0_LOCAL:=
			    CB0->CB0_LOCALI:=
			    CB0->CB0_LOTE:=
			    CB0->CB0_DTVLD:=
			    CB0->CB0_PALLET:=
			    
			    
			    
			    
		    MSUNLOCK()
		  
	endif    		   
	
	// Pula para próxima linha
	FT_FSKIP()
	
	MsProcTxt("Lendo tabela: "+aRet[1]+aRet[2]+aRet[3])
    ProcessMessage()
End

FT_FUSE() //FIM DA LEITURA DO TXT
Return