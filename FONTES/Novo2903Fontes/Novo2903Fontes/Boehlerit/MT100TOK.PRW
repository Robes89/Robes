#include "rwmake.ch"
#define ENTER Chr(13)+Chr(10)

/*
****ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
****±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
****±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
****±±³Programa  ³          ³ Autor ³ FERNANDO PACHECO      ³ Data ³16/08/2016³±±
****±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
****±±³Descricao ³ INCLUSAO DE INVOICE ITEM                                   ³±±
****±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
****±±³Parametros³ Nenhum                                                     ³±±
****±±³          ³                                                            ³±±
****±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
****±±³Retorno   ³ .T.(libera a linha) .F.(nao libera)                        ³±±
****±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
****±±³Aplicacao ³ Para inclusao de Invoice durante a NFE                     ³±±
****±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
****±±³Uso       ³ Boehlerit                                                  ³±±
****±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
****±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
****ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MT100TOK()
Local aAreaAnt := SaveArea1({"SB1", "SA2"})
Local lFIN     := .F.
Local I,xN   := 0 

Private aGrupo := {}

If cTipo == "N" .AND. cFormul == "S" .AND. cEspecie == "SPED"

   FOR xN:= 1 TO LEN(ACOLS)
		If ! Acols[xN][len(aHeader)+1]  //nao pega quando a linha esta deletada

			_cInvoice := Alltrim(gdfieldget("D1_COD",xN))
            
			If Substr(_cInvoice,1,2) == "I-"
			   _cInvoice := Substr(_cInvoice,3,Len(_cInvoice))
               dbSelectArea("ZZ1")
			   ZZ1->( DBSETORDER( 1 ) )
			   ZZ1->( DBSEEK( XFILIAL("ZZ1") + PADR(_cInvoice,10) ) )
			   nRegZZ1 := ZZ1->( RECNO() )

			   WHILE !ZZ1->( EOF() ) .AND. Alltrim(ZZ1->ZZ1_INVOIC) == _cInvoice
			
					_cItem         := gdfieldget("D1_ITEM",xN)
					_cCC           := gdfieldget("D1_CC",xN)
					_cTES          := gdfieldget("D1_TES",xN)
					_cProduto      := ALLTRIM(gdfieldget("D1_COD",xN))
					_cTransp       := ALLTRIM(gdfieldget("D1_TRANSP",xN))
					_cConhec       := ALLTRIM(gdfieldget("D1_CONHEC",xN))
			
					dbSelectArea("SB1")
					SB1->(dbSetOrder(1))
					dbSeek(XFILIAL("SB1")+gdfieldget("D1_COD",xN),.t.)
			
					IF (SB1->B1_TIPO == "PA" .AND. SB1->B1_GRUPO <> '1.14') .OR. SB1->B1_TIPOCQ == "Q"
						IF gdfieldget("D1_LOCAL",xN) <> '98'
							Aviso( "Atenção" , "Almoxarifado informado está diferente de 98, favor ajustar no Item ["+_cItem+"]." , { "Ok" },2,"Atenção" )
							RETURN(.F.)
						ENDIF
					ENDIF
			
					IF ALLTRIM(gdfieldget("D1_CC",xN)) == "09" .AND. !(ALLTRIM(gdfieldget("D1_CONTA",xN))$ "1250100227")
						Aviso( "Atenção" , "Conta Contabil não permitida para Projeto, favor ajustar no Item ["+_cItem+"]." , { "Ok" },2,"Atenção" )
						RETURN(.F.)
					ENDIF

					IF _cTransp == _cConhec
						IF !ApMsgYesNo("<html>Cod. Transp. e Conhec. Frete estão com o mesmo Numero no Item ["+_cItem+"]. "+ENTER+"<b>Continuar a Gravação mesmo assim ???</b>")
							Return(.F.)
						ENDIF
					ENDIF
					ZZ1->(dbSkip())
			   Enddo	
			
			ENDIF
			
			
			////////////////////ADICIONADO 05/02/2013 - ALEXANDRE - INICIO
			IF cEmpAnt == "50" .AND. cFilAnt $ "06*08"
				IF _cProduto == "26000"
					IF !(_cTES $ "416*417*418*419")
						Aviso( "Atenção" , "Tes para essa empresa e produto só pode ser 416*417*418*419 no Item ["+_cItem+"]." , { "Ok" },2,"Atenção" )
						RETURN(.F.)
					ENDIF
				ENDIF
				
				IF _cProduto == "26001"
					IF !(_cTES $ "398*399*406*407")
						Aviso( "Atenção" , "Tes para essa empresa e produto só pode ser 398*399*406*407 no Item ["+_cItem+"]." , { "Ok" },2,"Atenção" )
						RETURN(.F.)
					ENDIF
				ENDIF
				
				IF _cProduto $ "26002*26005*26006*26010*26011*26012*26013*26014"
					IF !(_cTES $ "408*409*410*411")
						Aviso( "Atenção" , "Tes para essa empresa e produto só pode ser 408*409*410*411 no Item ["+_cItem+"]." , { "Ok" },2,"Atenção" )
						RETURN(.F.)
					ENDIF
				ENDIF
				
				IF _cProduto $ "26003*26004"
					IF !(_cTES $ "412*413*414*415")
						Aviso( "Atenção" , "Tes para essa empresa e produto só pode ser 412*413*414*415 no Item ["+_cItem+"]." , { "Ok" },2,"Atenção" )
						RETURN(.F.)
					ENDIF
				ENDIF
				
				IF (_cTES $ "010*011*119*176")
					Aviso( "Atenção" , "Tes 010 * 011 * 119 * 176 não podem ser usadas CD-Goiania e CD-Viana no Item ["+_cItem+"]." , { "Ok" },2,"Atenção" )
					RETURN(.F.)
				ENDIF
				
			ELSE
				IF (_cTES $ "416*417*418*419*398*399*406*407*408*409*410*411*412*413*414*415*396*397")
					Aviso( "Atenção" , "Tes 416 * 417 * 418 * 419 * 398 * 399 * 406 * 407 * 408 * 409 * 410 * 411 * 412 * 413 * 414 * 415 * 396 * 397 so podem ser usadas CD-Goiania e CD-Viana no Item ["+_cItem+"]." , { "Ok" },2,"Atenção" )
					RETURN(.F.)
				ENDIF
			ENDIF
			////////////////////ADICIONADO 05/02/2013 - ALEXANDRE - FIM
			
			////////////////////ADICIONADO 11/09/2012 - ALEXANDRE - INICIO
			IF ALLTRIM(_cCC) $ "04*10" .AND. CA100FOR <> '006275'
				Aviso( "Atenção" , "Centro de Custo não permitido p/ uso no Item ["+_cItem+"]." , { "Ok" },2,"Atenção" )
				RETURN(.F.)
			EndIf
			////////////////////ADICIONADO 11/09/2012 - ALEXANDRE - FIM
			
			////////////////////ADICIONADO 31/08/2012 - ALEXANDRE - INICIO
			
			cCONTA         := ""
			_cGRUPO        := SB1->B1_GRUPO
			_cCONTA        := aCols[xN,Ascan(aHeader,{|x|UPPER(Alltrim (x[2]))=="D1_CONTA"})]
			_cRATEIO       := ALLTRIM(aCols[xN,Ascan(aHeader,{|x|UPPER(Alltrim (x[2]))=="D1_RATEIO"})])
			
			IF SA2->A2_RATEIO == "1" .AND. _cRATEIO <> "1"
				ApMsgAlert("É obrigatorio informar o Rateio p/ esse Fornecedor no Item ["+_cItem+"] !!!.","Atenção")
				Return(.F.)
			ENDIF
			
			nOpcS := Ascan(aGRUPO,{|x| x[1]== ALLTRIM(_cGRUPO) })
			IF nOpcS > 0
				FOR I:= 2 TO LEN(aGRUPO[nOpcS])
					IF !EMPTY(aGRUPO[nOpcS][I])
						cCONTA += IIF(EMPTY(cCONTA),aGRUPO[nOpcS][I],"*"+aGRUPO[nOpcS][I])
					ENDIF
				NEXT I
				
				IF !(ALLTRIM(_cCONTA) $ cCONTA)
					cMSG   := "Conta Contabil não permitida somente as abaixo: "+ENTER+ENTER
					aCONTA := StrToArray(cCONTA,"*")
					FOR I:= 1 TO LEN(aCONTA)
						cMSG += aCONTA[I]+ENTER
					NEXT I
					IF (nAviso := Aviso("ATENÇÃO",cMSG,{"Continuar","Abortar"},3,"PROBLEMA NO ITEM ["+_cItem+"]")) == 2
						Return(.F.)
					ENDIF
				ENDIF
			ENDIF
			
			IF ALLTRIM(_cCONTA) == "3110100885*3110100884*3110301102*3110100893"
				ApMsgAlert("Conta Contabil não permitido para o Item ["+_cItem+"] !!!","Atenção")
				Return(.F.)
			ENDIF
			
			///////////////////////ADICIONADO 31/08/2012 - ALEXANDRE - FIM
			
		ENDIF
	NEXT xN
	
	
	IF lFIN
		IF ALLTRIM(CSERIE) <> 'FIN'
			APMSGSTOP("<html><b>SERIE</b> de NOTA FISCAL não <b>PERMITIDO</b> !!!","ATENÇÃO")
			Return(.F.)
		ENDIF
	ENDIF
ENDIF

//GRAVA ADICIAO
	/*	If SA2->(dbseek(xFilial("SA2")+SF1->(F1_FORNECE+F1_LOJA)))
		 	If SA2->A2_EST=="EX"
		 		U_CpoTelaImp() 
		 	Endif 
		Endif 	

/*
//REMOVIDO - ALEXANDRE - 20-09-13
IF ALLTRIM(CSERIE) == '0'
APMSGSTOP("<html><b>SERIE</b> de NOTA FISCAL não <b>PERMITIDO</b> !!!","ATENÇÃO")
Return(.F.)
ENDIF
*/  
                          

//ADICIONADO 18/03/2011 - ALEXANDRE
If cTipo == "N"
	If cFormul == "S"
		If cEspecie <> "SPED"
			ApMsgAlert( 'Informe a espécie correta para este documento!', 'Atenção')
			Return(.F.)
		EndIf
		
	/*	IF SA2->A2_EST == "EX"
			FOR xN:= 1 TO LEN(ACOLS)
				IF ! Acols[xN][len(aHeader)+1]  //nao pega quando a linha esta deletada
					_cItem     := gdfieldget("D1_ITEM",xN)
					_cADICAO   := ALLTRIM(gdfieldget("D1_ADICAO",xN))
					_cSEQ_ADI  := ALLTRIM(gdfieldget("D1_SEQ_ADI",xN))
					
					IF EMPTY(_cADICAO)
						ApMsgAlert("Campo ADICAO não informado no Item ["+_cItem+"],com isso a NFE será recusada !!!.","Atenção")
						Return(.F.)
					ENDIF
					
					IF EMPTY(_cSEQ_ADI)
						ApMsgAlert("Campo SEQ ADICAO não informado no Item ["+_cItem+"],com isso a NFE será recusada !!!.","Atenção")
						Return(.F.)
					ENDIF
				ENDIF
			NEXT xN
		ENDIF */
	EndIf
EndIf

RestArea1(aAreaAnt)
Return(.T.)
