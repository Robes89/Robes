#INCLUDE "PROTHEUS.CH"

User Function ImporSG1()

	If !MSGYESNO( 'Existe arquivo de importaÃ§ao da estrutura na pasta: c:\protheus\import\estrut.csv')
		Return
	Endif


	If !MSGYESNO( 'Na execução desta rotina, todos os dados da tabela de estrutura(SG1) serao excluido, confirma?')
		
		Return
	Else
		MsAguarde({|lEnd| ExcluiSG1(@lEnd) },"Importando cadastro de estrutura...","Cadastro Estrutura",.T.)   
	Endif
	
	MsAguarde({|lEnd| gravaSG1(@lEnd) },"Importando cadastro de estrutura...","Cadastro Estrutura",.T.)
 
Return

Static function ExcluiSG1(lEnd)

MsProcTxt("Excluindo tabela")
ProcessMessage()  

Begin Transaction
     
    //Monta o Update
    cQryUpd := " UPDATE " + RetSqlName("SG1") + " "
    cQryUpd += "     SET D_E_L_E_T_ = '*', 
    cQryUpd += "         R_E_C_D_E_L_ =  R_E_C_N_O_ 
	cQryUpd += " WHERE "	
    cQryUpd += "     G1_FILIAL = '" + xFilial('SG1') + "' "
    cQryUpd += "     AND D_E_L_E_T_ = ' ' "

    //Tenta executar o update
    nErro := TcSqlExec(cQryUpd)
     
    //Se houve erro, mostra a mensagem e cancela a transação
    If nErro != 0
        MsgStop("Erro na exclução dos dados da tabela: "+TcSqlError(), "Atenção")
        DisarmTransaction()
    EndIf
End Transaction

RETURN


Static function gravaSG1(lEnd)

nHandle := FT_FUse("c:\protheus\import\estrut.csv")
If nHandle = -1 
	MSGYESNO( 'Arquivo nÃ£o encontrado!!')
	return
Endif
// 7527441 

// Posiciona na primeria linha
FT_FGoTop()
// Retorna o nÃºmero de linhas do arquivo
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
	
	///VERIFICA SE Ã‰ O CABEÃ‡ALHO 
	If !aRet[1]$"CODIGO"
		 aTamSB1:= TamSX3('B1_COD')
		 aTamSG1:= TamSX3('G1_TRT')

		aRet[1]:=Alltrim(aRet[1])
		aRet[2]:=Alltrim(aRet[2])
		aRet[3]:=Alltrim(aRet[3])
		 
        aRet[1]:=Alltrim(aRet[1]) + Space( aTamSB1[01] - Len( aRet[1] )  )
		aRet[2]:=Alltrim(aRet[2]) + Space( aTamSB1[01] - Len( aRet[2] )  )
		aRet[3]:=Alltrim(aRet[3]) + Space( aTamSG1[01] - Len( aRet[3] )  )
	
		dbselectarea("SG1")
		SG1->(dBsetorder(1))
        SG1->(dBSeek(xFilial("SG1")+aRet[1] + aRet[2] + aRet[3]))
		
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
				    SG1->G1_REVINI:=aRet[5]
				    SG1->G1_REVFIM:=aRet[6]			    
				    SG1->G1_INI:=CTod('01/01/2000')
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
				    SG1->G1_QUANT:=Val(aRet[4])
				    SG1->G1_REVINI:=aRet[5]
				    SG1->G1_REVFIM:=aRet[6]			    
				    SG1->G1_INI:=CTod('01/01/2000')
				    SG1->G1_FIM:=CTod('01/01/2049')
				    SG1->G1_FIXVAR:='V'
				    SG1->G1_NIV:='01'
				    SG1->G1_NIVINV:='99'
				    SG1->G1_USAALT:='1'				    
		       MSUNLOCK()
		Endif    		   
	Endif                         // FIM DA GRAVACAO NO TMP
	// Pula para prÃ³xima linha
	FT_FSKIP()
	
	MsProcTxt("Lendo tabela: "+aRet[1]+aRet[2]+aRet[3])
    ProcessMessage()
End

FT_FUSE() //FIM DA LEITURA DO TXT
Return


User Function XBACK()
Local cDesc:=''
/*
Local cQuery:=''

cQuery:=" UPDATE SC2010 SC2 SET C2_DESC = B1_DESC   "
cQuery+=" INNER JOIN SB1010 SB1 ON ( SB1.D_E_L_E_T_='' AND '"+xFilial('SB1')+"'=B1_FILIAL AND SB1.B1_COD = SC2.C2_COD ) 
cQuery+=" WHERE SC2.D_E_L_E_T_='' AND xFilial('SC2')=C2_FILIAL "  

nErro := TcSqlExec(cQuery)
     
    //Se houve erro, mostra a mensagem e cancela a transação
If nErro != 0
        MsgStop("Erro na exclução dos dados da tabela: "+TcSqlError(), "Atenção")
        DisarmTransaction()
EndIf
*/

DbselectArea("SC2")
DbsetOrder(1)
Do While !Eof()
	cDesc:=POSICIONE("SB1",1,xFILIAL('SB1')+SC2->C2_PRODUTO,'B1_DESC')  
    RecLock("SC2",.f.)
      C2_DESC:=cDesc 
	MSUNLOCK()
	dbSkip()
Enddo
Return()
