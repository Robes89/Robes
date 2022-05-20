#include "rwmake.ch"
#DEFINE CRLF CHR(13)+CHR(10)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �fContabGpe� Autor � Chris Vieira          � Data � 30/05/16 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gera Arquivo texto com a Contabilizacao da Folha            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RDMake ( DOS e Windows )                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico para Monvep                                     ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
���            �        �      �                                          ���
���            �        �      �                                          ���
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function Gp110Act

SetPrvt("cArq1,cArq2,cPd_,cLp_,cPerg,lEnd,lContinua,nVal,cCcMSV_,cAliasQry")
SetPrvt("nHdl1,nHdl2,nLinS0,nLinV0,arrContab,cCompet_,nContReg,nReg4")

//��������������������������������������������������������������Ŀ
//� Montando Variaveis de Trabalho                               �
//����������������������������������������������������������������
cArq1	    := ' '
cArq2		:= ' '
cPd_        := ' '
cLp_        := ' '
cCcMSV_		:= ' '
cPerg 		:= 'SCHM001'
lEnd        := .F.
lContinua   := .T.
nHdl1       := 0
nHdl2       := 0
nLinS0      := 0
nLinV0      := 0
nReg4		:= 0
nVal		:= 0
nContReg	:= 0
arrContab	:= {}
cAliasQry	:= "QRYPD"

cCompet_ :=  MV_PAR01 //"052016"

VerPerg()

Pergunte(cPerg,.F.)


//���������������������������������������������������������������������Ŀ
//� Montagem da tela                                                    �
//�����������������������������������������������������������������������

@ 000,000 TO 250,500 DIALOG oDlg TITLE 'Gera��o de Arquivo de Lan�amentos Cont�beis.'
@ 010,005 TO 100,245
@ 030,010 SAY OemtoAnsi('Programa de gera��o de arquivo texto dos lan�amentos cont�beis')
@ 040,010 SAY OemtoAnsi('da folha de pagamento.                                        ')
@ 050,010 SAY OemtoAnsi('                                                              ')
@ 060,010 SAY OemtoAnsi('                                                              ')

@ 104,162 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg, .T.)
@ 104,190 BMPBUTTON TYPE 2 ACTION Close(oDlg)
@ 104,218 BMPBUTTON TYPE 1 ACTION Continua()

ACTIVATE DIALOG oDlg CENTERED

If nHdl1 > 0 .And. nHdl2 > 0 
	If fClose(nHdl1) .And. fClose(nHdl2) 
		If nLinS0 > 0 .And. nLinV0 > 0 .And. lContinua
			MsgInfo('Gerados os arquivos: ' + AllTrim(cArq1) + ' e ' + AllTrim(cArq2) + ".",{'OK'})
		ElseIf nLinS0 > 0 .And. lContinua
			MsgInfo('Gerado o arquivo: ' + AllTrim(cArq1) + '.',{'OK'})
			fErase(cArq2)
		ElseIf nLinV0 > 0 .And. lContinua
			MsgInfo('Gerado o arquivo: ' + AllTrim(cArq2) + ".",{'OK'})
			fErase(cArq1)
		Else
			If fErase(cArq1) == 0 .And. fErase(cArq2) == 0
				If lContinua
					MsgAlert('N�o existem registros a serem gravados. A gera��o dos arquivos: ' + AllTrim(cArq1) + ' e ' + AllTrim(cArq2) + ' foi abortada.',{'OK'})
				EndIf
			Else
				MsgAlert('Ocorreram problemas na tentativa de dele��o do arquivo ' + AllTrim(cArq1) + ' e ' + AllTrim(cArq2) +'.')
			EndIf
		EndIf
	Else
		MsgAlert('Ocorreram problemas no fechamento dos arquivos ' + AllTrim(cArq1) + ' e ' + AllTrim(cArq2) + '.')
	EndIf
ElseIf nHdl1 > 0
	If fClose(nHdl1)
		If nLinS0 > 0 .And. lContinua
			MsgInfo('Gerado o arquivo ' + AllTrim(cArq1) + '.',{'OK'})
		Else
			If fErase(cArq1) == 0
				If lContinua
					Aviso('AVISO','N�o existem registros a serem gravados. A gera��o do arquivo ' + AllTrim(cArq1) + ' foi abortada.',{'OK'})
				EndIf
			Else
				MsgAlert('Ocorreram problemas na tentativa de dele��o do arquivo '+ AllTrim(cArq1)+'.')
			EndIf
		EndIf
	Else
		MsgAlert('Ocorreram problemas no fechamento do arquivo '+ AllTrim(cArq1)+'.')
	EndIf
ElseIf nHdl2 > 0
	If fClose(nHdl2)
		If nLinV0 > 0 .And. lContinua
			MsgInfo('Gerado o arquivo: ' + AllTrim(cArq2) + '.',{'OK'})
		Else
			If fErase(cArq2) == 0
				If lContinua
					Aviso('AVISO','N�o existem registros a serem gravados. A gera��o do arquivo ' + AllTrim(cArq2) + ' foi abortada.',{'OK'})
				EndIf
			Else
				MsgAlert('Ocorreram problemas na tentativa de dele��o do arquivo '+ AllTrim(cArq2)+'.')
			EndIf
		EndIf
	Else
		MsgAlert('Ocorreram problemas no fechamento do arquivo '+ AllTrim(cArq2)+'.')
	EndIf
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � Continua � Autor � Isamu K.              � Data � 20.09.05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Continua                                                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RDMake ( DOS e Windows )                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Continua()
Local cPasta := AllTrim(MV_PAR03)
Local cTxt1  := ""
Local cTxt2  := ""

If MsgYesNo("Confirma a configura��o dos par�metros?","Aten��o")
	//����������������������������������������������������������������������Ŀ
	//� Verifica as perguntas                                                �
	//����������������������������������������������������������������������Ĵ
	If Empty(cPasta)
		MsgAlert('N�o foi informado o local para a grava��o dos arquivos.','Aten��o!')
		Return
	Endif
	
	//Alimentar o array com as informa��es a serem utilizadas para a gera��o do arquivo
	If !fProcDados()
		MsgInfo( "N�o existe movimento para a gera��o do arquivo de contabiliza��o!" , "Aten��o" )
		RestArea(aArea)
		Return(.F.)
	Endif	
	
	If !Empty(mv_par01)
		cArq1 := Alltrim(UPPER(MV_PAR01))
	Else
		cArq1 := 'CTBSCHUTZ.TXT'
	Endif
	If !Right(cArq1,4) == ".TXT"
		cArq1 += ".TXT" 
	Endif
	cTxt1 := cArq1
	cArq1 := cPasta + cArq1
	
	If !Empty(mv_par02)
		cArq2 := AllTrim(UPPER(MV_PAR02))
	Else
		cArq2 := 'CTBVASITEX.TXT'
	Endif
	If !Right(cArq2,4) == ".TXT"
		cArq2 += ".TXT" 
	Endif
	cTxt2 := cArq2
	cArq2 := cPasta + cArq2
	
	//Cadastro de Verbas
	SRV->(dbSetOrder(1)) //Verba
	
	//Cadastro de Lancamento Padrao
	CT5->(dbSetOrder(1)) //Lancamento + Sequencia
	
	//Cadastro de Centro de Custos
	CTT->(dbSetOrder(1)) //Centro de Custo
	
	//Resumo da Folha
	SRZ->(dbSetOrder(2)) //Filial + Verba + Centro de Custo
	SRZ->(dbGotop())
	
	//Funcionarios
	SRA->(dbSetOrder(1)) //Matricula
	

	//���������������������������������������������������������������������Ŀ
	//� Cria o arquivo texto - SCHUTZ                                       �
	//�����������������������������������������������������������������������
	Do While .T.
		If File(cArq1) .And. File(cArq2)
			If (MsgYesNo("Os arquivos: " + cTxt1 + " e " + cTxt2 + " j� existem, deseja substitu�-los?","Aten��o"))
				If fErase(cArq1) == 0 .And. fErase(cArq2) == 0
					Exit
				Else
					MsgAlert('Ocorreram problemas na tentativa de dele��o dos arquivos: ' + AllTrim(cArq1) + ' e ' + AllTrim(cArq2) + '.')
				EndIf
			Else
				Return
			EndIf
		ElseIf File(cArq1) 
			If (MsgYesNo("O arquivo: " + cTxt1 + " j� existe, deseja substitu�-lo?","Aten��o"))
				If fErase(cArq1) == 0 
					Exit
				Else
					MsgAlert('Ocorreram problemas na tentativa de dele��o do arquivo ' + AllTrim(cArq1)+'.')
				EndIf
			Else
				Return
			EndIf	
		ElseIf File(cArq2)
			If (MsgYesNo("O arquivo: " + cTxt2 + " j� existe, deseja substitu�-lo?","Aten��o"))
				If fErase(cArq2) == 0 
					Exit
				Else
					MsgAlert('Ocorreram problemas na tentativa de dele��o do arquivo ' + AllTrim(cArq2)+'.')
				EndIf
			Else
				Return
			EndIf	
		Else
			Exit
		EndIf
	EndDo                                                 
	
	nHdl1 := fCreate(cArq1)
	If nHdl1 == -1
		MsgAlert('O arquivo ' + AllTrim(cArq1) + ' n�o p�de ser criado! Verifique os par�metros.','Aten��o!')
		Return
	Endif
	
	nHdl2 := fCreate(cArq2)
	If nHdl2 == -1
		MsgAlert('O arquivo ' + AllTrim(cArq2) + ' n�o p�de ser criado! Verifique os par�metros.','Aten��o!')
		Return
	Endif
	
	Processa({|lEnd| RunCont()}, 'Processando...')
	Close(oDlg)
Endif

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �  RunCont � Autor � Isamu K.              � Data � 20.09.05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao Gera Arquivo Texto                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RDMake ( DOS e Windows )                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function RunCont()           
Local cFilOld 	:= ""
Local nCont		:= 0

Private cCodFil_

ProcRegua(Len(arrContab))

For nCont := 1 to Len(arrContab)
	IncProc('Gerando Arquivo Texto....')  // Atualiza Regua

	cPd_	:= arrContab[nCont][2]
	SRV->(dbSeek(xfilial()+cPd_))
	
	cLp_ := SRV->RV_LCTOP
	CT5->(dbSeek(arrContab[nCont][1]+cLp_))
	
	cCcMSV_ := arrContab[nCont][4]
	nVal	:= arrContab[nCont][3]
	cCodFil_:= arrContab[nCont][1]
	If !cFilOld == cCodFil_
		If !Empty(cFilOld) //Mudou de filial, gerar registros 4 e 9
			nLinV0 := nReg4
			fGeraFim(cFilOld)
		Endif
		
		nContReg := 1
		nReg4    := 1
		fGeraCab(cCodFil_)
		
		cFilOld := arrContab[nCont][1]
	Endif
	
	fGeraDet(cCodFil_)
	nReg4++	
	
Next

If nReg4 > 1
	nLinS0 := nReg4
	fGeraFim(cFilOld)
Endif

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � fGeraCab � Autor � Christiane Vieira     � Data � 07.06.16 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao Gera Linha Cabe�alho                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RDMake ( DOS e Windows )                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fGeraCab(cCodFil)
Local cTexto := ""
Local cData  := StrTran(Dtoc(Date()),"/","")
Local cHora  := StrTran(Time(), ":","")

	cTexto := StrZero(nContReg,8)
	cTexto += "1"
	cTexto += "000"
	cTexto += MV_PAR04
	cTexto += cData + cHora
	cTexto += "0001"
	cTexto += Space(452) + CRLF	
	If cCodFil == "010001"	//Vasitex
		Fwrite( nHdl2, cTexto )
	Else //Schutz
		Fwrite( nHdl1, cTexto )
	Endif	
	nContReg ++
	
	//Gera registro de in�cio da tabela
	cTexto := StrZero(nContReg,8)
	cTexto += "2"
	cTexto += "400"
	cTexto += "Cgf_Lancamentos_Integracao    "
	cTexto += Space(470) + CRLF
	
	If cCodFil == "010001"	//Vasitex
		Fwrite( nHdl2, cTexto )
	Else //Schutz
		Fwrite( nHdl1, cTexto )
	Endif	
	nContReg ++	
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � fGeraFim � Autor � Christiane Vieira     � Data � 07.06.16 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao Gera Linha T�rmino Arquivo                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RDMake ( DOS e Windows )                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fGeraFim(cCodFil)
Local cTexto := ""
	//Gera registro de fim da tabela
	cTexto := StrZero(nContReg,8)
	cTexto += "4"
	cTexto += "400"
	cTexto += "Cgf_Lancamentos_Integracao    "
	cTexto += Space(470) + CRLF
	
	If cCodFil == "010001"	//Vasitex
		Fwrite( nHdl2, cTexto )
	Else //Schutz
		Fwrite( nHdl1, cTexto )
	Endif	
	nContReg ++	
	
	//Gera registro de fim da tabela
	cTexto := StrZero(nContReg,8)
	cTexto += "9"
	cTexto += "999"
	cTexto += Space(30)
	cTexto += StrZero(1,8)
	cTexto += StrZero(1,8)
	cTexto += StrZero(nReg4,8)
	cTexto += Space(446) + CRLF	
	If cCodFil == "010001"	//Vasitex
		Fwrite( nHdl2, cTexto )
	Else //Schutz
		Fwrite( nHdl1, cTexto )
	Endif	
	nContReg ++	

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � fGeraDet � Autor � Isamu K.              � Data � 05.06.04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao Gera Linha Detalhe                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RDMake ( DOS e Windows )                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fGeraDet(cCodFil)
Local cTexto := ""
Local cHist  := ""
Local nPosAx := 0
Local cAux	 := StrTran(CT5->CT5_HIST,"SRZ->RZ_PD","SRV->RV_COD")

	nPosAx := At("+",cAux)
	If nPosAx > 0
		cHist := AllTrim(&(Substr(cAux,1,nPosAx-1)) + &(Substr(cAux,nPosAx+1)))
	Else
		cHist := AllTrim(cAux)
	Endif
	
	//Gera registro de detalhe
	cTexto := StrZero(nContReg,8)
	cTexto += "3"
	cTexto += "400"
	cTexto += "Cgf_Lancamentos_Integracao    "
	If cCodFil == "010001"	//Vasitex
		cTexto += "0001" // C�digo da empresa
	Else
		cTexto += "0002"
	Endif
	cTexto += "0001" // C�digo do local
	cTexto += "CNV" // Ver c�digo da origem
	cTexto += Space(8)
	cTexto += StrZero(nReg4,6) //Ver n�mero do lancto
	If !SRV->RV_TIPOCOD $ "1/3"
		If cCodFil == "010001"	//Vasitex
			cTexto += SRV->RV_CRED1
		Else
			cTexto += SRV->RV_CRED2
		Endif
	Else
		If cCodFil == "010001"	//Vasitex
			cTexto += SRV->RV_DEB1
		Else
			cTexto += SRV->RV_DEB2
		Endif	
	Endif	
	cTexto += Replicate("0", 10 - Len(cCcMSV_)) + cCcMSV_ 
	If !SRV->RV_TIPOCOD $ "1/3"
		If cCodFil == "010001"	//Vasitex
			cTexto += SRV->RV_DEB1
		Else
			cTexto += SRV->RV_DEB2
		Endif
	Else
		If cCodFil == "010001"	//Vasitex
			cTexto += SRV->RV_CRED1
		Else
			cTexto += SRV->RV_CRED2
		Endif	
	Endif		
	cTexto += Replicate("0", 10 - Len(cCcMSV_)) + cCcMSV_
	cTexto += "    " // Ver c�digo do hist�rico	
	cTexto += cHist + Space(300 - Len(cHist))
	If SRV->RV_TIPOCOD $ "1/3"
		cTexto += "D" 
	Else
		cTexto += "C"
	Endif
	cTexto += StrZero(nReg4,10)
	cTexto += "01" + cCompet_
	cTexto += Space(8)
	cTexto += STRZERO(nVal*100, 16, 0) 
	cTexto += Space(54) + CRLF	
	If cCodFil == "010001"	//Vasitex
		Fwrite( nHdl2, cTexto )
	Else //Schutz
		Fwrite( nHdl1, cTexto )
	Endif	
	nContReg ++

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �   VerPerg    � Autor �Isamu K.           � Data � 15.06.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica  as perguntas, Incluindo-as caso n�o existam      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � VerPerg                                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GeraVisa                                                   ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function VerPerg()

Local aRegs     := {}
Local aHelp 	:= {}
Local aHelpE 	:= {}              
Local aHelpI 	:= {}
Local cHelp 	:= ""

	//X1_GRUPO,X1_ORDEM,X1_PERGUNT,X1_PERSPA,X1_PERENG,X1_VARIAVL,X1_TIPO,X1_TAMANHO,X1_DECIMAL,X1_PRESEL,X1_GSC,X1_VALID,X1_VAR01,X1_DEF01,X1_DEFSPA1,X1_DEFENG1,X1_CNT01,X1_VAR02,X1_DEF02,X1_DEFSPA2,X1_DEFENG2,X1_CNT02,X1_VAR03,X1_DEF03,X1_DEFSPA3,X1_DEFENG3,X1_CNT03,X1_VAR04,X1_DEF04,X1_DEFSPA4,X1_DEFENG4,X1_CNT04,X1_VAR05,X1_DEF05,X1_DEFSPA5,X1_DEFENG5,X1_CNT05,X1_F3,X1_PYME,X1_GRPSXG,X1_HELP
aAdd( aRegs, {cPerg,'01','Schutz - Nome do arquivo? '  ,'�Schutz - Nombre del archivo?' ,'Schutz - File name ?'	,'MV_CH1','C',20,0,0,'G',''							 ,'MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','',''	 ,''	,'S',{},{},{},'.SCHM00101.'} )
aAdd( aRegs, {cPerg,'02','Vasitex - Nome do arquivo? ' ,'�Vasitex - Nombre del archivo?','Vasitex - File name ?','MV_CH2','C',20,0,0,'G',''							 ,'MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','',''	 ,''	,'S',{},{},{},'.SCHM00102.'} )
aAdd( aRegs, {cPerg,'03','Local de grava��o dos arqs ?','�Carpeta grabaci�n del arch ?' ,'File save location ?'	,'MV_CH3','C',60,0,0,'G','GetDire() .and. NaoVazio()','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','',''	 ,''	,'S',{},{},{},'.SCHM00103.'} )
aAdd( aRegs, {cPerg,'04','Descri��o do arquivo ?'      ,'�Descripci�n del archivo ?'    ,'File description ?'	,'MV_CH4','C',30,0,0,'G','NaoVazio()'				 ,'MV_PAR04','','','','','','','','','','','','','','','','','','','','','','','','',''	 ,''	,'S',{},{},{},'.SCHM00104.'} )

ValidPerg(aRegs,cPerg ,.F.)

//Schutz - Nome do arquivo
cHelp 	:= ".SCHM00101."
aHelp := {	"Informe o nome do arquivo a ",;
			"ser gerado para Schutz." }
aHelpE:= {	"Introduzca el nombre del archivo ",;
			"a generar para Schutz." }
aHelpI:= {	"Enter the file name to be generated for Schutz." }

PutSX1Help("P"+cHelp,aHelp,aHelpI,aHelpE)


//Schutz - Nome do arquivo
cHelp 	:= ".SCHM00102."
aHelp := {	"Informe o nome do arquivo a ",;
			"ser gerado para Vasitex." }
aHelpE:= {	"Introduzca el nombre del archivo ",;
			"a generar para Vasitex." }
aHelpI:= {	"Enter the file name to be generated for Vasitex." }

PutSX1Help("P"+cHelp,aHelp,aHelpI,aHelpE)


//Pasta para grava��o do Arquivo
cHelp 	:= ".SCHM00103."
aHelp := {	"Informe o caminho para a ",;
			"grava��o dos arquivos." }
aHelpE:= {	"introduzca la ruta para la grabaci�n ",;
			"del archivo." }
aHelpI:= {	"Enter the file save location." }

PutSX1Help("P"+cHelp,aHelp,aHelpI,aHelpE)


//Descri��o do Arquivo
cHelp 	:= ".SCHM00104."
aHelp := {	"Informe a descri��o do ",;
			"arquivos." }
aHelpE:= {	"Introduzca la descripci�n ",;
			"del archivo." }
aHelpI:= {	"Enter the file description." }

PutSX1Help("P"+cHelp,aHelp,aHelpI,aHelpE)

Return

/*
{Protheus.doc} fProcDados()
Montagem da query para a obten��o dos dados da tabela SRZ
@Author		Christiane Vieira
@Since		30/06/2016       
@Sample		fProcDados()
@Version	P12.1.7
@Return		lRet, habilitado para continuar ou n�o
@Obs	   	 
@history
*/
Static Function fProcDados()
Local lRet     := .F.
Local cQuery   := ""

	cQuery += " SELECT SRZ.RZ_FILIAL,SRZ.RZ_PD, SUM(SRZ.RZ_VAL) RZ_VAL,CTT.CTT_XMSV "
	cQuery += "			FROM " +  RetSqlName("SRZ") + " SRZ " + CRLF
	cQuery += "			INNER JOIN " +  RetSqlName("SRA") + " SRA  ON " + CRLF
	cQuery += "			SRA.RA_FILIAL = SRZ.RZ_FILIAL AND SRA.RA_MAT = SRZ.RZ_MAT " + CRLF
	cQuery += "			INNER JOIN " +  RetSqlName("CTT") + " CTT  ON " + CRLF
	cQuery += "			CTT.CTT_FILIAL = SRZ.RZ_FILIAL AND CTT.CTT_CUSTO = SRZ.RZ_CC " + CRLF
	cQuery += "			INNER JOIN " +  RetSqlName("SRV") + " SRV  ON " + CRLF
	cQuery += "			SRV.RV_COD = SRZ.RZ_PD AND SRV.RV_LCTOP <> '' " + CRLF
		
 	If TcSrvType() != "AS/400"
    	cQuery += "   WHERE SRZ.D_E_L_E_T_ <> '*' "		
 	Else
  		cQuery += "   WHERE @DELETED@ <> '*' "		
 	Endif	
 	cQuery += "		GROUP BY SRZ.RZ_FILIAL, SRZ.RZ_PD, CTT.CTT_XMSV " + CRLF
 	cQuery += "		ORDER BY SRZ.RZ_FILIAL, SRZ.RZ_PD, CTT.CTT_XMSV"
 	
 	cQuery := ChangeQuery(cQuery)
   	
	//ABRE A EXECUCAO DA QUERY ATRIBUIDA AO SR0
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)

	//Adicionar num array os vales por funcion�rio
	While (cAliasQry)->( !EOF() )

		Aadd( arrContab , {(cAliasQry)->RZ_FILIAL,(cAliasQry)->RZ_PD,(cAliasQry)->RZ_VAL,(cAliasQry)->CTT_XMSV })

		(cAliasQry)->(DbSkip())
	End

	dbSelectArea(cAliasQry)
	dbCloseArea()

	lRet := len(arrContab) > 0
	
Return (lRet)