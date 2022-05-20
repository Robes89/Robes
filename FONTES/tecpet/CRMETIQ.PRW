#INCLUDE "rwmake.ch"
#Include "TOTVS.ch"
#Include "TBICONN.ch"
#Include "TBICODE.ch"
#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"

/*----------+------------+----------------+-------------------+-------+---------------+
| Programa  | ETIQCRM01  | Desenvolvedor  | Rafael Augusto    | Data  | 07/09/2018    |
+-----------+------------+----------------+-------------------+-------+---------------+
| Descricao | Programa responsável por liberar os títulos correspondente ao documento |
|          	| de entrada.                                                             |
+-----------+-------------------------------------------------------------------------+
| Modulos   | SIGAEST		                                                          |
+-----------+-------------------------------------------------------------------------+
| Processos |                                                                         |
+-----------+------------------------------------------------------------------------*/

User Function CRMETIQ()

	Local aCores    	:= {}
	Local aIndex    	:= {}
	Local bFiltraBrw	:= {}
	Local cAlias    	:= "SZ1"
	Local cFiltra   	:= " "
	Local CodIdUs		:= RetCodUsr()
	Local NamUser		:= UsrRetName(CodIdUS)

	AADD(aCores,{' Z1_IMPRESS =  "S" ' , "BR_VERDE"})
	AADD(aCores,{' Z1_IMPRESS <> "S" ' , "BR_VERMELHO"})

	cCadastro  := OemToAnsi("Etiquetas Nakata")

	bFiltraBrw:= {FilBrowse(cAlias,@aIndex,@cFiltra)}

	aRotina    := {{OemToAnsi("Pesquisar") ,"PesqBrw",0, 1, 0, nil},;
	{OemToAnsi("Importar TXT"),"U_IMPORTXT()" , 0 , 3, 0, nil},;
	{OemToAnsi("Imprimir Etiq Pequena")    ,"U_ImpET"   , 0 , 3, 0, nil},;
	{OemToAnsi("Imprimir Etiq Grande")     ,"U_YImpri"   , 0 , 3, 0, nil},;
	{OemToAnsi("Legenda")                  ,"U_BLegenda"   , 0 , 6, 0, nil}}

	mBrowse(06, 01, 22, 75, "SZ1",,,,,,aCores)

Return

/*----------+------------+----------------+-------------------+-------+---------------+
| Programa  | BLegenda   | Desenvolvedor  | Rafael Augusto    | Data  | 07/09/2018    |
+-----------+------------+----------------+-------------------+-------+---------------+
| Descricao | Rotina responsavel por determinar as cores da legendas e suas definicoes|
+-----------+-------------------------------------------------------------------------+
| Modulos   | SIGAEST		                                                          |
+-----------+------------------------------------------------------------------------*/

User Function BLegenda()

	Local aLegenda :={}

	AADD(aLegenda,{"BR_VERDE"    ,"Etiqueta impressas"})
	AADD(aLegenda,{"BR_VERMELHO" ,"Etiqueta Não impressa"})

	BrwLegenda(cCadastro, "Legenda",aLegenda)

Return Nil

/*----------+------------+----------------+-------------------+-------+---------------+
| Programa  | IMPORTXT   | Desenvolvedor  | Rafael Augusto    | Data  | 07/09/2018    |
+-----------+------------+----------------+-------------------+-------+---------------+
| Descricao | Rotina responsavel por realizar a importacao do arquivo TXT e gravar na |
|           | tabela dentro do Protheus.											  |
+-----------+-------------------------------------------------------------------------+
| Modulos   | SIGAEST		                                                          |
+-----------+------------------------------------------------------------------------*/

User Function IMPORTXT()

	Local cArq     := cGetFile("Arquivo .TXT |*.TXT","Selecione o Arquivo CSV",0,"",.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE)
	Local cLinha   := " "
	Local lPrim    := .T.
	Local aCampos  := {}
	Local aDados   := {}
	Local cCodUser := RetCodUsr() 				//Retorna o Codigo do Usuario
	Local cNamUser := UsrRetName( cCodUser )	//Retorna o nome do usuario
	//Local cIDUlt   := GetSxeNum("SZ1","Z1_ID","Z1_ID" + cEmpAnt)
	Local cIDUlt   := STRZERO(U_NULTSZ1(),8)

	Private aErro  := {}

	If !File(cArq)
		MsgStop("O arquivo " + cArq + " não foi encontrado. A importação será abortada!","[IMPORTXT] - ATENCAO")
		Return
	EndIf

	FT_FUSE(cArq)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()

	While !FT_FEOF()

		IncProc("Lendo arquivo texto...")

		cLinha := FT_FREADLN()

		If lPrim
			aCampos := Strtokarr(cLinha,"|",.T.)
			lPrim := .F.
		EndIf

		AADD(aDados,Strtokarr(cLinha,"|",.T.))

		FT_FSKIP()

	EndDo

	Begin Transaction

		ProcRegua(Len(aDados))

		For i:=1 to Len(aDados)

			IncProc("Importando as Etiquetas...")

			Reclock("SZ1",.T.)

			Z1_RAZORIG	:= aDados[i,1]
			Z1_ENDORIG	:= aDados[i,2]
			Z1_PAISORI	:= aDados[i,3]
			Z1_ASN		:= aDados[i,4]
			Z1_RAZDEST  := aDados[i,5]
			Z1_ENDDEST	:= aDados[i,6]
			Z1_DOCK		:= aDados[i,7]
			Z1_ITEMNUM	:= aDados[i,8]
			Z1_DESCPRO	:= aDados[i,9]
			Z1_DATEMIS	:= CTOD(aDados[i,10])
			Z1_PUORDER	:= aDados[i,11]
			Z1_QTY		:= aDados[i,12]
			Z1_LOT		:= aDados[i,13]
			Z1_LICPLAT	:= aDados[i,14]
			Z1_VERSION 	:= aDados[i,15]
			Z1_IMPRESS	:= "N"
			Z1_NUMIMPR	:= 0
			Z1_DTULIMP	:= dDataBase
			Z1_USULIMP	:= cNamUser
			Z1_CLINHA	:= aDados[i,1] + aDados[i,2] + aDados[i,3] + aDados[i,4] + aDados[i,5] + aDados[i,6] + aDados[i,7] + aDados[i,8] + aDados[i,9] + aDados[i,10] + aDados[i,11] + aDados[i,12] + aDados[i,13] + aDados[i,14] + aDados[i,15]
			Z1_ID 		:= cIDUlt

			SZ1->(MsUnlock())

		Next i
	End Transaction

	FT_FUSE()

	ApMsgInfo("Importação das Etiquetas concluída com sucesso!","[IMPORTXT] - SUCESSO")

Return

/*----------+------------+----------------+-------------------+-------+---------------+
| Programa  | IMPETIQ    | Desenvolvedor  | Rafael Augusto    | Data  | 07/09/2018    |
+-----------+------------+----------------+-------------------+-------+---------------+
| Descricao | Rotina responsavel por realizar a impressao das etiquetas.			  |
+-----------+-------------------------------------------------------------------------+
| Modulos   | SIGAEST		                                                          |
+-----------+------------------------------------------------------------------------*/

User Function ImpET()

	Local cCodUser 	:= RetCodUsr() 				//Retorna o Codigo do Usuario
	Local cNamUser 	:= UsrRetName( cCodUser )	//Retorna o nome do usuario
	Local cQtdImp	:= SZ1->Z1_NUMIMPR

	IF SZ1->Z1_IMPRESS = "S"
		If MSGYESNO( "A Etiqueta já foi impressa, deseja reimprimi-la?", "Reimpressao Etiqueta" )

			If MSGYESNO( "Deseja imprimir todos as etiquetas do ID?", "Reimpressao Etiqueta" )
				U_XIMPRID()
			Else
				Reclock("SZ1",.F.)
				Z1_IMPRESS	:= "S"
				Z1_NUMIMPR	:= cQtdImp + 1
				Z1_DTULIMP	:= dDataBase
				Z1_USULIMP	:= cNamUser
				SZ1->(MsUnlock())

				U_XIMPRI()
			EndIF
		Else
			Alert("Reimpressao cancelada")
		EndIf
	Else
		Reclock("SZ1",.F.)
		Z1_IMPRESS	:= "S"
		Z1_NUMIMPR	:= 1
		Z1_DTULIMP	:= dDataBase
		Z1_USULIMP	:= cNamUser
		SZ1->(MsUnlock())

		If MSGYESNO( "Deseja imprimir todos as etiquetas do ID?", "Reimpressao Etiqueta" )
			U_XIMPRID()
		Else
			U_XIMPRI()
		EndIF

	EndIF

Return

/*----------+------------+----------------+-------------------+-------+-----------------+
| Programa  | XIMPRI     | Desenvolvedor  | Rafael Augusto    | Data  | 07/09/2018      |
+-----------+------------+----------------+-------------------+-------+-----------------+
| Descricao | Rotina responsavel por realizar a impressao das etiquetas pequen avulsa.	|
+-----------+---------------------------------------------------------------------------+
| Modulos   | SIGAEST		                                                            |
+-----------+--------------------------------------------------------------------------*/

User Function XImpri()

	Local cPorta   	:= "LPT1"
	Local cData	   	:= DTOS(Z1_DATEMIS)
	Local DataEmis 	:= SUBSTR(cData,7,2) +"/" + SUBSTR(cData,5,2) +"/" + SUBSTR(cData,1,4)
	Local cQty      := Transform( VAL(Z1_QTY) , "@E 999999999.999",__SetPicture("AMERICAN"))
	Local cLicPlat	:= ALLTRIM(Z1_LICPLAT)
	Local cEndOri   := ALLTRIM(Z1_ENDORIG)
	Local cPesq     := "-"
	Local cText     := ALLTRIM(Z1_ITEMNUM)
	Local nPosAt    := AT( cPesq, cText ) // Resultado

	IF LEN(cLicPlat) < 16
		cLicPlat := StrZero(VAL(cLicPlat), 16)
	EndIF

	cQrCode  	:= "[)>06Z" + ALLTRIM(Z1_VERSION) + "1J" + ALLTRIM(Z1_LICPLAT) + "Q" + ALLTRIM(cQTY) + "P" + ALLTRIM(Z1_ITEMNUM) + "V" + Substr(cLicPlat,1,7) + "1T" + ALLTRIM(Z1_LOT) + "K" + ALLTRIM(Z1_PUORDER)

	MSCBPRINTER("ELTRON",cPorta,,,.F.)
	MSCBFORM(.F.) //Resolvido problema na impressão da TLP 2844
	MSCBCHKSTATUS(.F.)

	MSCBWrite("^XA")
	MSCBWrite("^MMT")
	MSCBWrite("^PW831")
	MSCBWrite("^LL0480")
	MSCBWrite("^LS0")

	MSCBWrite("^FT481,386^A0I,17,16^FH\^FD" 	+ SubStr(ALLTRIM(Z1_ENDDEST),31,60) + "^FS")				//VARIAVEL - END DESTINO
	MSCBWrite("^FT371,354^A0I,17,16^FH\^FD" 	+ ALLTRIM(Z1_DOCK) 		+ "^FS")				//VARIAVEL - PLANT/DOCK
	MSCBWrite("^FT480,354^A0I,17,16^FH\^FDPLANT/DOCK:^FS")
	MSCBWrite("^FT480,286^A0I,23,24^FH\^FD" 	+ SubStr(ALLTRIM(Z1_DESCPRO),1,30) 		+ "^FS")//VARIAVEL - DESCRICAO PRODUTO
	MSCBWrite("^FT804,277^A0I,17,16^FH\^FDPART(N):^FS")
	MSCBWrite("^FT480,323^A0I,17,16^FH\^FDPART DESC:^FS")
	MSCBWrite("^FT804,74^A0I,17,16^FH\^FDLICENSE PLATE:^FS")
	MSCBWrite("^FT804,167^A0I,17,16^FH\^FDLOTE:^FS")
	MSCBWrite("^FT277,93^A0I,28,28^FH\^FD" 	+ cQty 		+ "^FS")							//VARIAVEL - QUANTITY
	MSCBWrite("^FT277,136^A0I,17,16^FH\^FDQTDE:^FS")
	MSCBWrite("^FT727,43^A0I,17,16^FH\^FD" 	+ ALLTRIM(Z1_VERSION) 	+ "^FS")				//VARIAVEL - VERSAO
	MSCBWrite("^FT804,43^A0I,17,16^FH\^FDVERSION:^FS")
	MSCBWrite("^FT275,179^A0I,17,16^FH\^FD" 	+ ALLTRIM(Z1_PUORDER) 	+ "^FS")				//VARIAVEL - PUCHER ORDER
	MSCBWrite("^FT276,203^A0I,14,14^FH\^FDPO(K):^FS")
	MSCBWrite("^FT278,225^A0I,17,16^FH\^FD" 	+ DataEmis 				+ "^FS")				//VARIAVEL - DATA EMISSAO
	MSCBWrite("^FT278,248^A0I,14,14^FH\^FDDATA:^FS")
	MSCBWrite("^FT804,224^A0I,39,38^FH\^FD" 	+ ALLTRIM(Z1_LOT) 		+ "^FS")				//VARIAVEL - LOT
	MSCBWrite("^FT804,307^A0I,34,33^FH\^FD" 	+ ALLTRIM(Z1_ITEMNUM) 	+ "^FS")				//VARIAVEL - ITEM NUM
	MSCBWrite("^FT760,355^A0I,17,16^FH\^FD" 	+ ALLTRIM(Z1_ASN) 		+ "^FS")				//VARIAVEL - ASN
	MSCBWrite("^FT804,355^A0I,17,16^FH\^FDASN:^FS")
	MSCBWrite("^FT481,417^A0I,17,16^FH\^FD" 	+ SubStr(ALLTRIM(Z1_ENDDEST),1,30) 	+ "^FS")				//VARIAVEL - END DESTINO
	MSCBWrite("^FT804,385^A0I,17,16^FH\^FD" 	+ ALLTRIM(Z1_PAISORI)      + "^FS")	//VARIAVEL - END ORIGEM
	MSCBWrite("^FT804,405^A0I,17,16^FH\^FD" 	+ SubStr(cEndORI,31,30)    + "^FS")	//VARIAVEL - END ORIGEM
	MSCBWrite("^FT804,425^A0I,17,16^FH\^FD" 	+ SubStr(cEndORI,1,30)     + "^FS")	//VARIAVEL - END ORIGEM
	MSCBWrite("^FT483,450^A0I,17,16^FH\^FD" 	+ SubStr(ALLTRIM(Z1_RAZDEST),1,30) 	+ "^FS")	//VARIAVEL - RAZAO DESTINO
	MSCBWrite("^FT804,450^A0I,17,16^FH\^FD" 	+ SubStr(ALLTRIM(Z1_RAZORIG),1,30) 	+ "^FS")	//VARIAVEL - RAZAO ORIGEM
	MSCBWrite("^FO6,69^GB821,0,2^FS")
	MSCBWrite("^FO6,162^GB821,0,2^FS")

	MSCBWrite("^BY1,3,20^FT556,40^BCI,,Y,N")
	//MSCBWrite("^FD>: " + ALLTRIM(Z1_ITEMNUM) + "@" + ALLTRIM(Z1_LOT) + "@" + ALLTRIM(Z1_QTY) + "^FS")
	MSCBWrite("^FD>:" + Substr(Z1_ITEMNUM,1,nPosAT - 1) + "@" + ALLTRIM(Z1_LOT) + "@" + ALLTRIM(Z1_QTY) + "^FS")

	MSCBWrite("^FO7,271^GB821,0,2^FS")

	MSCBWrite("^BY2,3,40^FT805,113^BCI,,N,N")
	MSCBWrite("^FD>:" + "1J" + ALLTRIM(cLicPlat) + "^FS")													//VARIAVEL - CODIGO DE BARRAS

	MSCBWrite("^FT740,93^A0I,17,16^FH\^FD" 	+ Substr(ALLTRIM(cLicPlat),1,7) + " " + SubStr(Alltrim(cLicPlat),8,16)	+ "^FS")

	//MSCBWrite("^BY2,3,40^FT805,113^BCI,,Y,N")
	//MSCBWrite("^FD>: " + Substr(ALLTRIM(cLicPlat),1,7) + " " + SubStr(Alltrim(cLicPlat),8,16) + "^FS")													//VARIAVEL - CODIGO DE BARRAS

	MSCBWrite("^BY36,36^FT164,359^BXI,3,200,0,0,1,~")
	MSCBWrite("^FH\^FD" + cQrCode + "^FS")

	MSCBWrite("^FO491,282^GB0,190,2^FS")
	MSCBWrite("^PQ1,0,1,Y^XZ")

	MSCBCLOSEPRINTER()

Return

/*----------+------------+----------------+-------------------+-------+-----------------+
| Programa  | XIMPRID    | Desenvolvedor  | Rafael Augusto    | Data  | 07/09/2018      |
+-----------+------------+----------------+-------------------+-------+-----------------+
| Descricao | Rotina responsavel por realizar a impressao das etiquetas pequena por id.	|
+-----------+---------------------------------------------------------------------------+
| Modulos   | SIGAEST		                                                            |
+-----------+--------------------------------------------------------------------------*/

User Function XImprid()

	Local cID      := Z1_ID
	Local cPorta   := "LPT1"

	dbSelectArea("SZ1")
	dbgoTOP()
	dbSetOrder(3)

	IF dbSeek(cID)

		While! EOF() .and. SZ1->Z1_ID = cID

			cQtdImp		:= SZ1->Z1_NUMIMPR
			cCodUser 	:= RetCodUsr() 				//Retorna o Codigo do Usuario
			cNamUser 	:= UsrRetName( cCodUser )	//Retorna o nome do usuario

			Reclock("SZ1",.F.)
			Z1_IMPRESS	:= "S"
			Z1_NUMIMPR	:= cQtdImp + 1
			Z1_DTULIMP	:= dDataBase
			Z1_USULIMP	:= cNamUser
			SZ1->(MsUnlock())

			cData	 	:= DTOS(Z1_DATEMIS)
			DataEmis 	:= SUBSTR(cData,7,2) +"/" + SUBSTR(cData,5,2) +"/" + SUBSTR(cData,1,4)
			cQty     	:= Transform( VAL(Z1_QTY) , "@E 999999999.999",__SetPicture("AMERICAN"))
			cLicPlat	:= ALLTRIM(Z1_LICPLAT)
			cEndOri   	:= ALLTRIM(Z1_ENDORIG)
			cPesq  		:= "-"
			cText  		:= ALLTRIM(Z1_ITEMNUM)
			nPosAt 		:= AT( cPesq, cText ) // Resultado

			IF LEN(cLicPlat) < 16
				cLicPlat := StrZero(VAL(cLicPlat), 16)
			EndIF

			cQrCode  	:= "[)>06Z" + ALLTRIM(Z1_VERSION) + "1J" + ALLTRIM(Z1_LICPLAT) + "Q" + ALLTRIM(cQTY) + "P" + ALLTRIM(Z1_ITEMNUM) + "V" + Substr(cLICPLAT,1,7) + "1T" + ALLTRIM(Z1_LOT) + "K" + ALLTRIM(Z1_PUORDER)

			MSCBPRINTER("ELTRON",cPorta,,170,.F.)
			MSCBFORM(.F.) //Resolvido problema na impressão da TLP 2844
			MSCBCHKSTATUS(.F.)

			MSCBWrite("^XA")
			MSCBWrite("^MMT")
			MSCBWrite("^PW831")
			MSCBWrite("^LL0480")
			MSCBWrite("^LS0")

			MSCBWrite("^FT481,386^A0I,17,16^FH\^FD" 	+ SubStr(ALLTRIM(Z1_ENDDEST),31,60) + "^FS")				//VARIAVEL - END DESTINO
			MSCBWrite("^FT371,354^A0I,17,16^FH\^FD" 	+ ALLTRIM(Z1_DOCK) 		+ "^FS")				//VARIAVEL - PLANT/DOCK
			MSCBWrite("^FT480,354^A0I,17,16^FH\^FDPLANT/DOCK:^FS")
			MSCBWrite("^FT480,286^A0I,23,24^FH\^FD" 	+ SubStr(ALLTRIM(Z1_DESCPRO),1,30) 		+ "^FS")//VARIAVEL - DESCRICAO PRODUTO
			MSCBWrite("^FT804,277^A0I,17,16^FH\^FDPART(N):^FS")
			MSCBWrite("^FT480,323^A0I,17,16^FH\^FDPART DESC:^FS")
			MSCBWrite("^FT804,74^A0I,17,16^FH\^FDLICENSE PLATE:^FS")
			MSCBWrite("^FT804,167^A0I,17,16^FH\^FDLOTE:^FS")
			MSCBWrite("^FT277,93^A0I,28,28^FH\^FD" 	+ cQty 		+ "^FS")							//VARIAVEL - QUANTITY
			MSCBWrite("^FT277,136^A0I,17,16^FH\^FDQTDE:^FS")
			MSCBWrite("^FT727,43^A0I,17,16^FH\^FD" 	+ ALLTRIM(Z1_VERSION) 	+ "^FS")				//VARIAVEL - VERSAO
			MSCBWrite("^FT804,43^A0I,17,16^FH\^FDVERSION:^FS")
			MSCBWrite("^FT275,179^A0I,17,16^FH\^FD" 	+ ALLTRIM(Z1_PUORDER) 	+ "^FS")				//VARIAVEL - PUCHER ORDER
			MSCBWrite("^FT276,203^A0I,14,14^FH\^FDPO(K):^FS")
			MSCBWrite("^FT278,225^A0I,17,16^FH\^FD" 	+ DataEmis 				+ "^FS")				//VARIAVEL - DATA EMISSAO
			MSCBWrite("^FT278,248^A0I,14,14^FH\^FDDATA:^FS")
			MSCBWrite("^FT804,224^A0I,39,38^FH\^FD" 	+ ALLTRIM(Z1_LOT) 		+ "^FS")				//VARIAVEL - LOT
			MSCBWrite("^FT804,307^A0I,34,33^FH\^FD" 	+ ALLTRIM(Z1_ITEMNUM) 	+ "^FS")				//VARIAVEL - ITEM NUM
			MSCBWrite("^FT760,355^A0I,17,16^FH\^FD" 	+ ALLTRIM(Z1_ASN) 		+ "^FS")				//VARIAVEL - ASN
			MSCBWrite("^FT804,355^A0I,17,16^FH\^FDASN:^FS")
			MSCBWrite("^FT481,417^A0I,17,16^FH\^FD" 	+ SubStr(ALLTRIM(Z1_ENDDEST),1,30) 	+ "^FS")				//VARIAVEL - END DESTINO
			MSCBWrite("^FT804,385^A0I,17,16^FH\^FD" 	+ ALLTRIM(Z1_PAISORI)      + "^FS")	//VARIAVEL - END ORIGEM
			MSCBWrite("^FT804,405^A0I,17,16^FH\^FD" 	+ SubStr(cEndORI,31,30)    + "^FS")	//VARIAVEL - END ORIGEM
			MSCBWrite("^FT804,425^A0I,17,16^FH\^FD" 	+ SubStr(cEndORI,1,30)     + "^FS")	//VARIAVEL - END ORIGEM
			MSCBWrite("^FT483,450^A0I,17,16^FH\^FD" 	+ SubStr(ALLTRIM(Z1_RAZDEST),1,30) 	+ "^FS")	//VARIAVEL - RAZAO DESTINO
			MSCBWrite("^FT804,450^A0I,17,16^FH\^FD" 	+ SubStr(ALLTRIM(Z1_RAZORIG),1,30) 	+ "^FS")	//VARIAVEL - RAZAO ORIGEM
			MSCBWrite("^FO6,69^GB821,0,2^FS")
			MSCBWrite("^FO6,162^GB821,0,2^FS")

			MSCBWrite("^BY1,3,20^FT556,40^BCI,,Y,N")
			//MSCBWrite("^FD>: " + ALLTRIM(Z1_ITEMNUM) + "@" + ALLTRIM(Z1_LOT) + "@" + ALLTRIM(Z1_QTY) + "^FS")
			MSCBWrite("^FD>:" + Substr(Z1_ITEMNUM,1,nPosAT - 1) + "@" + ALLTRIM(Z1_LOT) + "@" + ALLTRIM(Z1_QTY) + "^FS")

			MSCBWrite("^FO7,271^GB821,0,2^FS")

			MSCBWrite("^BY2,3,40^FT805,113^BCI,,N,N")
			MSCBWrite("^FD>:" + "1J" + ALLTRIM(cLicPlat) + "^FS")													//VARIAVEL - CODIGO DE BARRAS

			MSCBWrite("^FT740,93^A0I,17,16^FH\^FD" 	+ Substr(ALLTRIM(cLicPlat),1,7) + " " + SubStr(Alltrim(cLicPlat),8,16)	+ "^FS")

			//MSCBWrite("^BY2,3,40^FT805,113^BCI,,Y,N")
			//MSCBWrite("^FD>: " + Substr(ALLTRIM(cLicPlat),1,7) + " " + SubStr(Alltrim(cLicPlat),8,16) + "^FS")													//VARIAVEL - CODIGO DE BARRAS

			MSCBWrite("^BY36,36^FT164,359^BXI,3,200,0,0,1,~")
			MSCBWrite("^FH\^FD" + cQrCode + "^FS")

			MSCBWrite("^FO491,282^GB0,190,2^FS")
			MSCBWrite("^PQ1,0,1,Y^XZ")

			MSCBCLOSEPRINTER()

			dbSkip()
		EndDO

	EndIF

Return

/*----------+------------+----------------+-------------------+-------+-----------------+
| Programa  | YIMPRI     | Desenvolvedor  | Rafael Augusto    | Data  | 07/09/2018      |
+-----------+------------+----------------+-------------------+-------+-----------------+
| Descricao | Rotina responsavel por realizar a impressao das etiquetas pequena avulsa. |
+-----------+---------------------------------------------------------------------------+
| Modulos   | SIGAEST		                                                            |
+-----------+--------------------------------------------------------------------------*/

User Function YImpri()

	Local cPorta   := "LPT1"
	Local cData	   := DTOS(Z1_DATEMIS)
	Local DataEmis := SUBSTR(cData,7,2) +"/" + SUBSTR(cData,5,2) +"/" + SUBSTR(cData,1,4)
	Local cLicPlat := ALLTRIM(Z1_LICPLAT)
	Local cQty     := Transform( VAL(Z1_QTY) , "@E 999999999.999",__SetPicture("AMERICAN"))
	Local cPesq    := "-"
	Local cText    := ALLTRIM(Z1_ITEMNUM)
	Local nPosAt   := AT( cPesq, cText ) // Resultado

	IF LEN(cLicPlat) < 16
		cLicPlat := StrZero(VAL(cLicPlat), 16)
	EndIF

	cQrCode  	:= "[)>06Z" + ALLTRIM(Z1_VERSION) + "1J" + ALLTRIM(Z1_LICPLAT) + "Q" + ALLTRIM(Z1_QTY) + "P" + ALLTRIM(Z1_ITEMNUM) + "V" + Substr(cLICPLAT,1,7) + "1T" + ALLTRIM(Z1_LOT) + "K" + ALLTRIM(Z1_PUORDER)

	MSCBPRINTER("ELTRON",cPorta,,,.F.)
	MSCBFORM(.F.) //Resolvido problema na impressão da TLP 2844
	MSCBCHKSTATUS(.F.)

	MSCBWrite("^XA")
	MSCBWrite("^MMT")
	MSCBWrite("^PW818")
	MSCBWrite("^LL1343")
	MSCBWrite("^LS0")

	MSCBWrite("^BY200,200^FT236,276^BXB,5,200,0,0,1,~")
	MSCBWrite("^FH\^FD" + cQrCode + "^FS")

	MSCBWrite(" ^FT234 , 603^A0B  , 39 , 38^FH\^FD" 	+ ALLTRIM(Z1_DOCK) 		+ "^FS")	//VARIAVEL - PLANT/DOCK
	MSCBWrite(" ^FT234 , 826^A0B  , 39 , 38^FH\^FDPLANT/DOCK:^FS")					//FIXO - PLANT/DOCK
	MSCBWrite(" ^FT173 , 826^A0B  , 30 , 30^FH\^FD" 	+ ALLTRIM(Z1_ENDDEST) 	+ "^FS")	//VARIAVEL - END DESTINO
	MSCBWrite(" ^FT111 , 826^A0B  , 30 , 28^FH\^FD" 	+ SubStr(ALLTRIM(Z1_RAZDEST),1,30) 	+ "^FS")	//VARIAVEL - RAZAO DESTINO
	MSCBWrite(" ^FT507 , 1293^A0B , 56 , 80^FH\^FD" 	+ ALLTRIM(Z1_LOT) 		+ "^FS")	//VARIAVEL - LOT
	MSCBWrite(" ^FT363 , 1293^A0B , 56 , 130^FH\^FD" 	+ ALLTRIM(Z1_ITEMNUM) 	+ "^FS")	//VARIAVEL - ITEM NUM
	MSCBWrite(" ^FT286 , 1177^A0B , 39 , 38^FH\^FD" 	+ ALLTRIM(Z1_ASN) 		+ "^FS")	//VARIAVEL - ASN
	MSCBWrite(" ^FT237 , 1293^A0B , 30 , 30^FH\^FD" 	+ ALLTRIM(Z1_PAISORI) 	+ "^FS")	//VARIAVEL - PAIS DE ORIGEM
	MSCBWrite(" ^FT106 , 1293^A0B , 30 , 28^FH\^FD" 	+ SubStr(ALLTRIM(Z1_RAZORIG),1,30) 	+ "^FS")	//VARIAVEL - RAZAO ORIGEM
	MSCBWrite(" ^FT168 , 1293^A0B , 30 , 30^FH\^FD" 	+ SubStr(ALLTRIM(Z1_ENDORIG),1,30) 	+ "^FS")	//VARIAVEL - END ORIGEM
	MSCBWrite(" ^FT198 , 1293^A0B , 30 , 30^FH\^FD" 	+ SubStr(ALLTRIM(Z1_ENDORIG),31,60) 	+ "^FS")	//VARIAVEL - END ORIGEM
	MSCBWrite(" ^FT627 , 574^A0B  , 20 , 26^FH\^FDQUANTITY(Q):^FS")					//FIXO - QUANTITY(Q)
	MSCBWrite(" ^FT313 , 554^A0B  , 31 , 28^FH\^FDPART DESC:^FS")					//FIXO - PART DESC
	MSCBWrite(" ^FT683 , 574^A0B  , 42 , 57^FH\^FD" 	+ cQty 		+ "^FS")	//VARIAVEL - QUANTITY
	MSCBWrite(" ^FT362 , 554^A0B  , 31 , 35^FH\^FD" 	+ SubStr(ALLTRIM(Z1_DESCPRO),1,25) 		+ "^FS")	//VARIAVEL - DESCRICAO PRODUTO
	MSCBWrite(" ^FT392 , 554^A0B  , 31 , 35^FH\^FD" 	+ SubStr(ALLTRIM(Z1_DESCPRO),26,50) 	+ "^FS")	//VARIAVEL - DESCRICAO PRODUTO
	MSCBWrite(" ^FT581 , 451^A0B  , 23 , 19^FH\^FD" 	+ ALLTRIM(Z1_PUORDER) 	+ "^FS")	//VARIAVEL - PUCHER ORDER
	MSCBWrite(" ^FT542 , 451^A0B  , 23 , 19^FH\^FDPO#(K):^FS")						//FIXO - PO#(K)
	MSCBWrite(" ^FT504 , 451^A0B  , 23 , 19^FH\^FD" 	+ DataEmis 				+ "^FS")	//VARIAVEL - DATA EMISSAO
	MSCBWrite(" ^FT782 , 1100^A0B , 30 , 30^FH\^FD" 	+ ALLTRIM(Z1_VERSION) 	+ "^FS")	//VARIAVEL - VERSAO
	MSCBWrite(" ^FT782 , 1293^A0B , 30 , 30^FH\^FDVER(Z):^FS")						//FIXO - VER(Z)
	MSCBWrite(" ^FT717 , 1293^A0B , 23 , 19^FH\^FDLICENSE PLATE(1J):^FS")			//FIXO - LICENSE PLATE(1J)
	MSCBWrite(" ^FT467 , 451^A0B  , 23 , 19^FH\^FDDATE:^FS")						//FIXO - DATE
	MSCBWrite(" ^FT556 , 1293^A0B , 23 , 19^FH\^FDLOT(1T):^FS")						//FIXO - LOT(1T)
	MSCBWrite(" ^FT53  , 826^A0B  , 31 , 31^FH\^FDTO:^FS")							//FIXO - TO:
	MSCBWrite(" ^FT413 , 1293^A0B , 23 , 19^FH\^FDPART#(P):^FS")					//FIXO - PART#(P)
	MSCBWrite(" ^FT279 , 1293^A0B , 31 , 28^FH\^FDASN(N):^FS") 						//FIXO - ASN(N)
	MSCBWrite(" ^FT53  , 1293^A0B , 31 , 31^FH\^FDFROM:^FS") 						//FIXO - FROM:
	MSCBWrite(" ^FO726 , 100^GB0    , 1307 , 4^FS")									//FIXO - LINHA
	MSCBWrite(" ^FO592 , 100^GB0    , 1306 , 4^FS")									//FIXO - LINHA
	MSCBWrite(" ^FO10  , 836^GB245  , 0    , 1^FS")
	MSCBWrite(" ^FO431 , 100^GB0    , 1306 , 4^FS")									//FIXO - LINHA
	MSCBWrite(" ^BY3   , 3          , 42^FT644 , 1295^BCB,,Y,N")					//VARIAVEL - CODIGO DE BARRAS
	MSCBWrite("^FD>: " + Substr(ALLTRIM(cLicPlat),1,7) + " " + SubStr(Alltrim(cLicPlat),8,16) + "^FS")													//VARIAVEL - CODIGO DE BARRAS

	//-----------------------------------------------------------------------------------------------------------------//
	// Codigo de barras especifico para PrestServ, para nao precisar mexer no PE já desenvolvido                       //
	//-----------------------------------------------------------------------------------------------------------------//

	MSCBWrite("^BY2    ,3           , 42^FT776 , 983^BCB,,Y,N")
	MSCBWrite("^FD>: " + Substr(Z1_ITEMNUM,1,nPosAT - 1) + "@" + ALLTRIM(Z1_LOT) + "@" + ALLTRIM(Z1_QTY) + "^FS")
	//MSCBWrite("^FD>:" + ALLTRIM(Z1_ITEMNUM) + "@" + ALLTRIM(Z1_LOT) + "@" + ALLTRIM(Z1_QTY) + "^FS")
	MSCBWrite("^PQ1,0,1,Y^XZ")

	MSCBCLOSEPRINTER()

Return

/*----------+------------+----------------+-------------------+-------+-----------------+
| Programa  | YIMPRI     | Desenvolvedor  | Rafael Augusto    | Data  | 07/09/2018      |
+-----------+------------+----------------+-------------------+-------+-----------------+
| Descricao | Rotina responsavel por realizar a impressao das etiquetas pequena avulsa. |
+-----------+---------------------------------------------------------------------------+
| Modulos   | SIGAEST		                                                            |
+-----------+--------------------------------------------------------------------------*/

User Function NULTSZ1()

	Local cQuery  := " "
	Local nUltNum := 0

	If Select("_MAXSZ1") > 0
		Dbselectarea("_MAXSZ1")
		_MAXSZ1->(DbClosearea())
	EndIf

	cQuery := "SELECT Max(Z1_ID) + 1 MAXDOC "
	cQuery += " FROM " + RetSqlName("SZ1") + " SZ1 "
	cQuery += " WHERE SZ1.D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery)

	TcQuery cQuery New Alias "_MAXSZ1"

	DbSelectArea("_MAXSZ1")

	nUltNum := _MAXSZ1->MAXDOC

Return nUltNum
