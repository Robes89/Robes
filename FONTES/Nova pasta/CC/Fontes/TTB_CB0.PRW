#include "rwmake.ch"                                            
#include "topconn.ch"                                                                                               
#include "tbiconn.ch"                                           
#include "tbicode.ch"                                                           
#Include "Protheus.Ch"

/*/
____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ DAK_CB0 ¦ Autor ¦ Fabrica TECNORAV   ¦   Data ¦ 12/04/2016 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cadastro de Abertura Impressão e Manutenção de Etiquetas.  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo DAKHIA		  									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
                              
User Function TTB_CB0()
 
LOCAL cAlias  := "CB0"     					   	 			 //Tabela ID.de.Etiquetas
LOCAL cFiltro := ""
 
PRIVATE cCadastro  := "Manutencao de Etiquetas   FGQ-7-040"  //Titulo da tela da rotina.
PRIVATE nQtEtiqAnt := 0                                      //Quantiade Anterior.
PRIVATE nQtEtiqAtu := 0							 			 //Quantidade Atual.	
PRIVATE cLoteEtiq  := ""                                     //Lote da etiqueta.
PRIVATE cProdAtu   := ""                                     //Produto Atual.
PRIVATE aRotina	   := {}						 			 //Array para adionar  menus.	
PRIVATE aEtiAux    := {}						 			 //Array que receberá os itens da CB0 e salvará para gerar uma nova etiqueta.
PRIVATE aCores 	   := {}

AADD(aRotina, { "Pesquisar"		, "AxPesqui"	, 0, 1 })
AADD(aRotina, { "Visualizar"	, "AxVisual"	, 0, 2 })
AADD(aRotina, { "Incluir"		, "U_DAK_CB0I"	, 0, 3 })
AADD(aRotina, { "Alterar"		, "U_DAK_CB0A"	, 0, 4 })
AADD(aRotina, { "Legenda"		, "U_CB0_LEG"	, 0, 6 })        //Adiciona Função de Legenda-Semaforo!
AADD(aRotina, { "Encerra Etiq."	, "U_CB0_ENC"	, 0, 7 })        //Adiciona Função de Legenda-Semaforo!
//AADD(aRotina, {"Conhecimento"	,"MsDocument"   , 0, 8 })        //Adicionado conhecimento-teste Douglas - 17-05-16!
  //AADD(aRotina,{ "Excluir"	, "AxDeleta"	, 0, 5 })		 //Comentado em 27/04/16- Após Alinhado com Equipe Dakhia TI(Adriano)!

/*
AADD(aCores,{"CB0_QTDE<=0" 			 ,"BR_VERMELHO"			}) 	  // ENCERRADA
AADD(aCores,{"CB0_XMOTIV=='000001'"  ,"BR_PINK" 			}) 	  // NOVO PRODUTO
AADD(aCores,{"CB0_XMOTIV=='000002'"  ,"BR_LARANJA" 			}) 	  // LOTE
AADD(aCores,{"CB0_XMOTIV=='000003'"  ,"BR_AMARELO" 			}) 	  // SAIDA P/PRODUCAO
AADD(aCores,{"CB0_XMOTIV=='000004'"  ,"BR_VERDE" 			}) 	  // SAIDA P/CLIENTE
AADD(aCores,{"CB0_XMOTIV=='000005'"  ,"BR_AZUL" 			}) 	  // ENTRADA P/ESTOQUE
AADD(aCores,{"CB0_XMOTIV=='000006'"  ,"BR_MARROM" 			}) 	  // MP P/REVISAO
AADD(aCores,{"CB0_XMOTIV=='000007'"  ,"BR_CINZA" 			}) 	  // PRODUCAO P/ESTOQUE
AADD(aCores,{"CB0_XMOTIV=='999999'"  ,"BR_PRETO" 			}) 	  // DEVOLUCAO
AADD(aCores,{"CB0_XMOTIV=='000008'"  ,"BR_BRANCO" 			}) 	  // MAO-DE-OBRA
AADD(aCores,{"CB0_XMOTIV=='000009'"  ,"BR_VIOLETA" 			}) 	  // REAPROVEITAMENTO  
//--------------------------------------------------------------------------------------//
//ADICIONADO MAIS 2 MOTIVOS -ADRIANO - 16-06-16-Solicitado por Edilson!
//--------------------------------------------------------------------------------------//
AADD(aCores,{"CB0_XMOTIV=='000010'"  ,"BR_MARRON" 			}) 	  // SAIDA P/BENEFICIAMENTO  
AADD(aCores,{"CB0_XMOTIV=='000011'"  ,"BR_MARRON_OCEAN" 	}) 	  // SAIDA P/ARMAZEM 93

dbSelectArea(cAlias)                               		  		//Realiza abertura da Tabela "CB0-Id de Etiquetas"
dbSetOrder(1)                                     		  		//Aponta no indice de número 1.(CB0_FILIAL+CB0_CODETI)
mBrowse( ,,,,cAlias,,,,,,aCores,,,,,,,,cFiltro)         		//Exibe a interface para visualização dos registros da "CB0-ID de Etiquetas" 
RETURN NIL

*/

dbSelectArea(cAlias)                               		  		//Realiza abertura da Tabela "CB0-Id de Etiquetas"
dbSetOrder(1)                                     		  		//Aponta no indice de número 1.(CB0_FILIAL+CB0_CODETI)
mBrowse( ,,,,cAlias,,,,,,,,,,,,,,cFiltro)         		//Exibe a interface para visualização dos registros da "CB0-ID de Etiquetas" 
RETURN NIL




User Function DAK_CB0I()
	Local xcont:=1
	//local QETIQG:=0
	 
//	cGrava:=AxInclui("CB0",CB0->(Recno()),3,,,,"U_CB0ITOK(.F.)")
	cGrava:=AxInclui("CB0",CB0->(Recno()),3,,,,)	

Return
                                              
User Function CB0ITOK(lAltEtiq) 						  //CB0-BOTAO CONFIRMAR
	local xcont:=0
/*
	If Empty(M->CB0_XMOTIV) .OR. Empty(M->CB0_LOCAL)
		ALERT("Obrigatorio informar o Motivo/Armazem!")
		Return .F.                                        //Não deixa incluir sem o motivo!
	EndIf
   
    If (INCLUI .AND. !Empty(M->CB0_LOTE) .AND. M->CB0_XMOTIV!='999999') .OR. (ALTERA .AND. cLoteEtiq!=M->CB0_LOTE)
		
		If M->CB0_XSOMAL == "1"  //1-Soma/ 2-Não soma.  //Adriano Andrade-21-03-17   
				
			dbSelectArea("SB8")
			dbSetOrder(2)                                                      
			If MsSeek(xFilial("SB8")+"      "+M->CB0_LOTE+M->CB0_CODPRO)      		
				Reclock("SB8",.F.)
				SB8->B8_QTDORI:=SB8->B8_QTDORI+M->CB0_QTDE
				SB8->(MsUnLock())
			EndIf
		EndIf  //Final do IF Se soma Quantidade.
		
    EndIf
*/
    If INCLUI .And. !lAltEtiq                     

    		If M->CB0_QTDE<=0
				ALERT("Quantidade Invalida!")
				Return .F.                            //Não deixa finalizar a inclusão.
			EndIf	
			
			If M->CB0_QTDE<=0 .OR. EMPTY(M->CB0_CODPRO)				  		  
				ALERT("Quantidade ou produto nao informado!")
				Return .F.                            //Não deixa finalizar a inclusão.
			EndIf
			
			If M->CB0_XMOTIV=='000008' .AND. Empty(M->CB0_FORNEC) 
		   		ALERT("Necessario Informar o Fornecedor!")
		   		Return .F. 
			EndIf    
			 If M->CB0_XMOTIV=='000008' .AND. Empty(M->CB0_NFENT)
				ALERT("Necessario Informar NFe!")
				Return .F. 
			EndIf    
					
		M->CB0_XSALDO := M->CB0_QTDE			  //QTE.ORIG(view only) recebe a quantidade informada pelo usuario.	
		M->CB0_XUSER  := UsrRetName( RetCodUsr() )//CB0_XUSER(Real-Not used,no Browse,Not required)Grava o nome do usuario que incluiu etiqueta.  
	EndIf

	
	If 	M->CB0_XMOTIV=='999999' .AND. (Empty(M->CB0_CLI) .OR.Empty(M->CB0_PEDCOM))
		Alert("Trata-se de  uma devolucao, informar Pedido e/ou Cliente!")
		Return .F.
	EndIf
	
	If  M->CB0_XMOTIV=='000004'
	
		If  !Empty(M->CB0_FORNEC)
			M->CB0_FORNEC :=Space(8)
		EndIf 
		
		If  Empty(M->CB0_PEDCOM)
			Alert("Obrigatorio informar  o Pedido!")
			Return .F.
	   	EndIf					
			
	    If	Empty(M->CB0_CLI)
		    Alert("Obrigatorio informar o cliente!")
		    Return .F.
		 EndIf
			
	//	If	Empty(M->CB0_OP) .And. ALLTRIM(__CUSERID) != "000058"  //Retirado em 24-06-16 solicitado por Edilson.
		
	//	    Alert("Obrigatorio informar OP!")
	//	    Return .F.
	//	 EndIf
	EndIf		
		
    If lAltEtiq                      			  //Quando ALTERA ETIQUETA E GERA UMA NOVA-2° ALTERAÇÃO
		nQtEtiqInc := M->CB0_QTDE                 //Declara variavel nQtEtiqInc(Quantidade na inclusão,que recebe CB0_QTDE digitada pelo usuario.)
		If nQtEtiqAtu<>nQtEtiqInc 				  //Se quantidade atual for diferente de quantidade na inclusão->
			ALERT("Quantidade Atual nao pode ser diferente a Quantidade Original !!!")
			M->CB0_QTDE := nQtEtiqAtu			  //Retorna o valor da CB0_XSALDO(da atual etiqueta) no campo quantidade(CB0_QTDE).
			Return .F.                            //Não deixa finalizar a inclusão.
		EndIf
	EndIf		

	If 	ALTERA .And. !lAltEtiq 					  //Se For alteração de etiqueta-1° ALTERAÇÃO
	   
		nQtEtiqAtu := M->CB0_QTDE                 //Retorna o valor da CB0_XSALDO(da atual etiqueta) no campo quantidade(CB0_QTDE).
        
          
		If nQtEtiqAtu>nQtEtiqAnt 
			ALERT("Quantidade Atual nao pode ser superior ou igual a Quantidade Original !!!")
			M->CB0_QTDE := nQtEtiqAnt
			Return .F.
		EndIf
		
		//Incluido validação na alteração para não aceitar qtd zero ou negativo- Adriano/Douglas - 26/04/16- 14:46!
		If   nQtEtiqAtu<0 
			Alert("Quantidade nao pode ser zero ou negativa!")
			M->CB0_QTDE   := nQtEtiqAnt
			M->CB0_XUSADO := 0
			Return .F.
		EndIF

								              //Declara variavel nQtEtiqInc(Quantidade na inclusão,que recebe CB0_QTDE digitada pelo usuario.)
	    cProdAtu    :=M->CB0_CODPRO
	    If cProdAtu != cProdInc				  //Se quantidade atual for diferente de quantidade na inclusão->
			ALERT("Produto nao pode ser alterado!")
			M->CB0_CODPRO := cProdInc		  //Retorna o valor da CB0_XSALDO(da atual etiqueta) no campo quantidade(CB0_QTDE).
			Return .F.                        //Não deixa finalizar a inclusão.
			
		EndIf
        /*If !Empty (M->CB0_LOTE)
	   		cLoteAtu    :=M->CB0_LOTE  		  //APA
	   		If cLoteAtu <>cLoteEtiq
	   			Alert("Lote nao pode ser alterado!")
	   			M->CB0_LOTE:=cLoteEtiq
				Return .F.
			EndIf
		EndIf*/
			   	    
		If Empty(M->CB0_CODPRO)
			Alert("Obrigatorio informar produto")
			Return .F.        
        EndIf
                       
	EndIf
		
	//VERIFICA SE É ENTRADA MP -REVISÃO!
	If M->CB0_XMOTIV=='000006'
		If Empty(M->CB0_FORNEC)
			Alert("Necessario informar o fornecedor!")
			Return .F.	
		EndIf		
		If Empty(M->CB0_NFENT)
			Alert("Necessario Nota Fiscal!")
			Return .F.

		EndIf
	
	EndIf
			
	//VERIFICA SE É UMA ENTRADA PARA O ESTOQUE.
	If M->CB0_XMOTIV=='000005'
		If Empty(M->CB0_FORNEC)
			Alert("Necessario informar o fornecedor!")
			Return .F.
		EndIf
		If Empty(M->CB0_NFENT)
			Alert("Necessario informar NF-e de entrada!")
			Return .F.
		EndIf
	EndIf
	
	/* Função descontinuada em 29/05/2018 conforme definição dos novos processos, apenas rotinas padrao do sistema devera gerar lote.
 
    If Empty(M->CB0_LOTE)
        
        aCriaLote := {}

		AADD(aCriaLote,M->CB0_CODPRO)  //1
		AADD(aCriaLote,M->CB0_QTDE)    //2
		AADD(aCriaLote,M->CB0_LOCAL)   //3
		AADD(aCriaLote,M->CB0_ORIGEM)  //4
		AADD(aCriaLote,IIF(Empty(M->CB0_NFENT) ,M->CB0_NFSAI,M->CB0_NFENT))   //5
		AADD(aCriaLote,IIF(Empty(M->CB0_FORNEC),M->CB0_CLI,M->CB0_FORNEC))    //6
		AADD(aCriaLote,IIF(Empty(M->CB0_LOJAFO),M->CB0_LOJACL,M->CB0_LOJAFO)) //7
		If !Empty(M->CB0_CLI)
			AADD(aCriaLote,M->CB0_DESCLI)  	    //8  Se true-será 8
		Else
			AADD(aCriaLote,M->CB0_DESFORN)      //8 Se true- tbm será 8
        EndIf
     	
    	AADD(aCriaLote,M->CB0_PEDCOM)   	    //9 se True-será 9
		AADD(aCriaLote,M->CB0_DESPRO)			//10-Descrição do produto!
		
		If M->CB0_QTDE <> 0
			U_xCriaLote(aCriaLote)              //Chama a Tela de Criação de Lotes se a quantidade não for zerada!
        EndIf
	Else 
		dbSelectArea("SB8")
		dbSetOrder(2)                                                      
		If !MsSeek(xFilial("SB8")+Space(6)+M->CB0_LOTE+M->CB0_CODPRO)      		
			Alert("Lote Invalido!")
			M->CB0_LOTE :=Space(8)
			Return .F.
		EndIf
	EndIf 
	
*/    


If M->CB0_QTDE <> 0
	
		IF MSGYESNO("Deseja imprimir Etiqueta ?","IMPRESSAO ETIQUETA")
		
			//20170306 - DOUGLAS
			lPerg := Pergunte("XETIQ_2", .T.) //ARGOX ou ZEBRA
			
			IF lPerg == .T.
			
				IF !EMPTY(MV_PAR01)					
					
					IF 	MV_PAR01 == 2	//ZEBRA		
						//	Alert("Vou imprimir na Zebra ")
						If MSGYESNO("Imprime Etiqueta Grande?","TAMANHO  ETIQUETA")    //Adicionado 15-07-16
							Private cPerg  := "XETIQUETAS" 		// grupo de perguntas SX1-Quantidade de Etiquetas.
							//AJUSTASX1()
							lPerg := pergunte(cPerg,.T.) // "nao" sera apresendado para o usuario a janela de perguntar
							If lPerg == .T.  
							
								For i:= 1 to /*VAL*/(MV_PAR01)						
									U_TTB_ETIQ_2({M->CB0_CODETI,M->CB0_LOTE,M->CB0_NFENT,M->CB0_QTDE,M->CB0_FORNEC,M->CB0_DESFOR,M->CB0_CLI,M->CB0_DESCLI,"MB07",M->CB0_CODPRO,M->CB0_DESPRO,M->CB0_XBAG})
									//				1			      2				3			4		5				6				7			8		9			10          11           12
								Next                               
								xcont:=0
				    			While (MV_PAR03) > xcont 
								   u_gravacb0(xcont)     
								   xcont++
								End   
								  	
							ENDIF													
						Else
							
							Private cPerg  := "XETIQUETAS" 		// grupo de perguntas SX1							
							lPerg := pergunte(cPerg,.T.) 		   		// "nao" sera apresendado para o usuario a janela de perguntar							
							If lPerg == .T.							
								If 	!EMPTY(MV_PAR01) .AND. EMPTY(MV_PAR02)								
									// Chamada da Função para gravar na tabela CB9(Produtos Separados)"Etiqueta Pequena", e Retorna um ARRAY quatidades de ITENS
									//_aIDITEM := U_TTB_ETIQ4({M->CB0_CLI,M->CB0_CODPRO,M->CB0_XDESC2,M->CB0_XCOR,M->CB0_LOTE,M->CB0_XCOD,M->CB0_CODETI,M->CB0_FORNEC,M->CB0_DESFOR,M->CB0_DESCLI,"MB07",MV_PAR01,MV_PAR02})
													//	        1  			2 			    3			  4		      5			6			7			    8      				9   		 10       11       12      13      		
									For i:= 1 to MV_PAR01									
									
										U_TTB_ETIQ3({M->CB0_CLI,M->CB0_CODPRO,M->CB0_XDESC2,M->CB0_XCOR,M->CB0_LOTE,M->CB0_XCOD,M->CB0_CODETI,M->CB0_FORNEC,M->CB0_DESFOR,M->CB0_DESCLI,"MB07",i})
										//	             1  		  2 			    3		  4		      5			6			 7			     8      		9   		      10      11    12																		
									Next							
								
								Elseif !EMPTY(MV_PAR01) .AND. !EMPTY(MV_PAR02)
								
									// Chamada da Função para gravar na tabela CB9(Produtos Separados)"Etiqueta Pequena", e Retorna um ARRAY quatidades de ITENS
									//_aIDITEM := U_TTB_ETIQ4({M->CB0_CLI,M->CB0_CODPRO,M->CB0_XDESC2,M->CB0_XCOR,M->CB0_LOTE,M->CB0_XCOD,M->CB0_CODETI,M->CB0_FORNEC,M->CB0_DESFOR,M->CB0_DESCLI,"MB07",MV_PAR01,MV_PAR02})
									//	   1  			2 	          3			  4		      5			6			7			    8      		9   		      10          11       12      13								
									cont := MV_PAR02																
									For i:= 1 to MV_PAR01																		
										U_TTB_ETIQ3({M->CB0_CLI,M->CB0_CODPRO,M->CB0_XDESC2,M->CB0_XCOR,M->CB0_LOTE,M->CB0_XCOD,M->CB0_CODETI,M->CB0_FORNEC,M->CB0_DESFOR,M->CB0_DESCLI,"MB07",cont})									
										//	           1  			2 			    3			  4		      5			6			7			    8      		9   		      10          11    12
										cont++									
									Next								
									cont := 0								
								EndIf
							EndIf						
						EndIf
							
					ELSE	//ARGOX
					
						If MSGYESNO("Imprime Etiqueta Grande?","TAMANHO  ETIQUETA")    //Adicionado 15-07-16
						
							
							//---------------------------------------------------//
							//Adriano 29/03/17-Pergunte de etiquetas Grande Edgar//
							Private cPerg  := "XETIQUETAS" 		// grupo de perguntas SX1-Quantidade de Etiquetas.
							AJUSTASX1()
							pergunte(cPerg,.T.) 		   		// "nao" sera apresendado para o usuario a janela de perguntar
							
							For i:= 1 to /*VAL*/(MV_PAR01)
							//---------------------------------------------------//
					//		Alert(cValToChar(MV_PAR01))
							U_TTB_ETIQ({M->CB0_CODETI,M->CB0_LOTE,M->CB0_NFENT,M->CB0_QTDE,M->CB0_FORNEC,M->CB0_DESFOR,M->CB0_CLI,M->CB0_DESCLI,"MB07",M->CB0_CODPRO})
							//		       1  			2 			3			4				5			6			7			8      		9   		10
							Next
							//---------------------------------------------------//
						Else
							//Adicionado 15-07-16-Criado essa função dentro do DK_ETIQ.
							Private cPerg  := "XETIQUETAS" 		// grupo de perguntas SX1
							AJUSTASX1()
							pergunte(cPerg,.T.) 		   		// "nao" sera apresendado para o usuario a janela de perguntar
							// somente ocorerra a convesao das variaveis MV_PAR?? de acordo com
							// cada pergunta cadastrada na SX1
						
							For i:= 1 to /*VAL*/(MV_PAR01)
								U_TTB_ETIPE({M->CB0_CLI,M->CB0_CODPRO,M->CB0_XDESC2,M->CB0_XCOR,M->CB0_LOTE,M->CB0_XCOD,M->CB0_CODETI,M->CB0_FORNEC,M->CB0_DESFOR,M->CB0_DESCLI,"MB07"})
								//	                 1				2 			3			4			5			6          7             8             9           10             11
							Next
						
						EndIf
						
					
					ENDIF
					
				ELSE   				
   					ALERT("Verificar se todos os Parâmetros estão Preenchidos")							
				ENDIF
			ELSE
				//ApMsgInfo("Clicou em CANCELAR do Perg")				
			ENDIF	
		
  		EndIf
	
EndIf                
					
Return .T.

User Function TTB_CB0A()
	 
	 nQtEtiqAnt 	:= CB0->CB0_QTDE
     cLoteEtiq		:= CB0->CB0_LOTE
	 cProdInc   	:= CB0->CB0_CODPRO
     cGrava     	:= AxAltera("CB0", CB0->(Recno()),4,,,,,"U_CB0ITOK(.F.)") 
	 nQtEtiqAtu 	:= CB0->CB0_QTDE     
     If nQtEtiqAtu<nQtEtiqAnt
        		
		aEtiAux:={}
     
		nQtEtiqAtu := (nQtEtiqAnt-CB0_QTDE)	
	   
			 		
		AADD(aEtiAux,CB0->CB0_CODETI)	//01
		AADD(aEtiAux,CB0->CB0_DTNASC)	//02
		AADD(aEtiAux,CB0->CB0_CODPRO)	//03
		AADD(aEtiAux,nQtEtiqAtu)		//04
		AADD(aEtiAux,CB0->CB0_LOCAL)	//05
		AADD(aEtiAux,CB0->CB0_LOTE)		//06
		AADD(aEtiAux,CB0->CB0_DTVLD)	//07
		AADD(aEtiAux,CB0->CB0_FORNEC)	//08
		AADD(aEtiAux,CB0->CB0_LOJAFO)	//09
		AADD(aEtiAux,CB0->CB0_SERIEE)	//10
		AADD(aEtiAux,CB0->CB0_CLI)	    //11
		AADD(aEtiAux,CB0->CB0_LOJACL)	//12
		AADD(aEtiAux,CB0->CB0_PEDVEN)	//13
		AADD(aEtiAux,CB0->CB0_NFSAI)	//14
		AADD(aEtiAux,CB0->CB0_SERIES)	//15
		AADD(aEtiAux,CB0->CB0_VOLUME)	//16
		AADD(aEtiAux,CB0->CB0_TRANSP)	//17
		AADD(aEtiAux,CB0->CB0_STATUS)	//18
		AADD(aEtiAux,CB0->CB0_LOCORI)	//19
		AADD(aEtiAux,CB0->CB0_XSALDO)	//20
		AADD(aEtiAux,CB0->CB0_XUSER)	//21
		AADD(aEtiAux,CB0->CB0_XETIQ)	//22
		AADD(aEtiAux,CB0->CB0_XOBS)		//23
		AADD(aEtiAux,CB0->CB0_XMOTIV)	//24
		AADD(aEtiAux,CB0->CB0_PALLET)	//25
		AADD(aEtiAux,CB0->CB0_NFENT)	//26
		AADD(aEtiAux,CB0->CB0_OP)		//27		
		
 		cGrava := AxInclui("CB0", CB0->(Recno()),3,,"U_Pre_Etiq",,"U_CB0ITOK(.T.)")       

       EndIf
     
Return 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³FUNÇÃO Pre_Etiq()-CARREGA OS ITENS DA ETIQUETA ANTERIOR PARA QUANDO FOR GERAR UMA NOVA ETIQUETA!³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

User Function Pre_Etiq()		
	M->CB0_XETIQ	:= aEtiAux[01]
	M->CB0_DTNASC	:= DDATABASE
	M->CB0_DTVLD	:= STOD("20301231")
	M->CB0_CODPRO	:= aEtiAux[03]
	M->CB0_QTDE	    := aEtiAux[04]
	M->CB0_XSALDO	:= aEtiAux[04]
	M->CB0_LOCAL	:= aEtiAux[05]
	M->CB0_LOTE	    := aEtiAux[06]
	M->CB0_FORNEC	:= aEtiAux[08]
	M->CB0_LOJAFO	:= aEtiAux[09]
	M->CB0_SERIEE	:= aEtiAux[10]
	M->CB0_CLI	    := aEtiAux[11]
	M->CB0_LOJACL	:= aEtiAux[12]
	M->CB0_PEDVEN	:= aEtiAux[13]
	M->CB0_NFSAI	:= aEtiAux[14]
	M->CB0_SERIES	:= aEtiAux[15]
	M->CB0_VOLUME	:= aEtiAux[16]
	M->CB0_TRANSP	:= aEtiAux[17]
	M->CB0_STATUS	:= aEtiAux[18]
	M->CB0_LOCORI	:= aEtiAux[19]
	M->CB0_ORIGEM	:= "DAK_CB0"
	M->CB0_XUSER	:= USRRETNAME( RETCODUSR() )
	M->CB0_XOBS	    := aEtiAux[23]
	M->CB0_XMOTIV	:= Space(6)
	M->CB0_PALLET   := aEtiAux[25]
	M->CB0_NFENT    := aEtiAux[26]
	M->CB0_OP		:= aEtiAux[27]
	  */  		
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ`¿
//³FUNÇÃO QUE CARREGA OS ITENS DA TELA DE ETIQUETAS NA TELA DE CRIAÇÃO DO LOTE(DAK_SB8)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ`Ù

User Function Pre_Lote()
     
	M->B8_LOTECTL := U_DAK_SB8N()
	M->B8_DTVALID := STOD("20301231")
	M->B8_DFABRIC := DDATABASE
	M->B8_ORIGLAN := "ET"			
	M->B8_ORIGEM  := "DAK_CB0"
	M->B8_PRODUTO := aCriaLote[01] 
	M->B8_QTDORI  := aCriaLote[02]
	M->B8_LOCAL   := aCriaLote[03]
	M->B8_DOC 	  := aCriaLote[05]
	M->B8_CLIFOR  := aCriaLote[06]
	M->B8_LOJA 	  := aCriaLote[07]
	M->B8_XORIGEM := aCriaLote[08]
	M->B8_XPEDIDO := aCriaLote[09]
	M->B8_XDESC   := aCriaLote[10]
Return

User Function DAK_XUSE()

nCB0_QTDE:=(nQtEtiqAnt - M->CB0_XUSADO)                                                          

Return nCB0_QTDE 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³SEÇÃO LEGENDA-FUNÇÃO COM AS CORES E DESCRIÇÃO DA LEGENDA  ETIQUETAS!³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

User Function CB0_LEG()
Local aLegenda := {}

AADD(aLegenda,{"BR_VERMELHO" ,"ENCERRADA"  			}) 
AADD(aLegenda,{"BR_PINK"     ,"NOVO PRODUTO"		})
aAdd(aLegenda,{"BR_LARANJA"  ,"LOTE"				})	  
AADD(aLegenda,{"BR_AMARELO"  ,"SAIDA P/PRODUCAO"	})  
AADD(aLegenda,{"BR_VERDE"    ,"SAIDA P/CLIENTE"   	})
aAdd(aLegenda,{"BR_AZUL"     ,"ENTRADA P/ESTOQUE"	}) 
aAdd(aLegenda,{"BR_MARROM"   ,"MP P/REVISAO"		})   
aAdd(aLegenda,{"BR_CINZA"    ,"PRODUCAO P/ESTOQUE"	}) 
aAdd(aLegenda,{"BR_PRETO"    ,"DEVOLUCAO"			})
aAdd(aLegenda,{"BR_BRANCO"   ,"MAO-DE-OBRA"			})
aAdd(aLegenda,{"BR_VIOLETA"  ,"REAPROVEITAMENTO"	})
//ADICIONADO MAIS 2 MOTIVOS -ADRIANO - 16-06-16-Solicitado por Edilson!
aAdd(aLegenda,{"BR_MARRON"   	  ,"SAIDA P/BENEFICIAMENTO"	})
aAdd(aLegenda,{"BR_MARRON_OCEAN"  ,"SAIDA P/ARMAZEM 93"	    })

BrwLegenda(cCadastro, "Legenda", aLegenda)
Return Nil

User Function CB0_ENC()
	If  MSGYESNO("Deseja encerrar a Etiqueta ?","Encerrar Etiqueta")
		RecLock("CB0",.F.)
	    CB0->CB0_QTDE:=0
	    CB0->CB0_XDTENC:=DDATABASE
	    CB0->CB0_XUSERE:=USRRETNAME( RETCODUSR() )
	    
	    MsUnlock()

	EndIf
Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄa¿
//³CRIA A PERGUNTA SX1-QUANTIDADE DE ETIQUETAS À SEREM IMPRESSAS!³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄaÙ

STATIC FUNCTION AjustaSX1()
		aHelPor:={"Informe a quantidade de etiquetas a serem impressas!"}  
		PutSx1(cPerg ,"01" ,"QTD_ETIQUE","","","MV_CH1" ,"N" ,09,0,0,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","",,aHelPor,,,"" )

Return         
            


User function gravacb0(xcont)
Local _yxcont   := xcont
Local aAreaAnt  := GETAREA()
Local MCB0_CODETI   :=	M->CB0_CODETI
Local MCB0_XETIQ	:=	M->CB0_XETIQ
Local MCB0_DTNASC	:=	M->CB0_DTNASC
Local MCB0_DTVLD	:=	M->CB0_DTVLD
Local MCB0_CODPRO	:=	M->CB0_CODPRO
Local MCB0_QTDE	    :=	M->CB0_QTDE
Local MCB0_XSALDO	:=	M->CB0_XSALDO
Local MCB0_LOCAL	:=	M->CB0_LOCAL
Local MCB0_LOTE	    :=	M->CB0_LOTE
Local MCB0_FORNEC	:=	M->CB0_FORNEC
Local MCB0_LOJAFO	:=	M->CB0_LOJAFO 
Local MCB0_DESFOR   :=  '' //CB0->CB0_DESFOR 
Local MCB0_SERIEE	:=	M->CB0_SERIEE
Local MCB0_CLI	    :=	M->CB0_CLI
Local MCB0_LOJACL	:=	M->CB0_LOJACL
Local MCB0_PEDVEN	:=	M->CB0_PEDVEN
Local MCB0_NFSAI	:=	M->CB0_NFSAI
Local MCB0_SERIES	:=	M->CB0_SERIES
Local MCB0_VOLUME	:=	M->CB0_VOLUME
Local MCB0_TRANSP	:=	M->CB0_TRANSP
Local MCB0_STATUS	:=	M->CB0_STATUS
Local MCB0_LOCORI	:=	M->CB0_LOCORI
Local MCB0_ORIGEM	:=	M->CB0_ORIGEM
Local MCB0_XUSER	:=	M->CB0_XUSER
Local MCB0_XOBS	    :=	M->CB0_XOBS
Local MCB0_XMOTIV	:=	M->CB0_XMOTIV
Local MCB0_PALLET	:=	M->CB0_PALLET
Local MCB0_NFENT 	:=	M->CB0_NFENT
Local MCB0_OP		:=	M->CB0_OP
	
//-----------------------------------------------------------------------------------------------------------------------------------------------//
//Grava cbo com as demais copias solicitadas                                                                                                                                               //
//------------------------------------------------------------------------------------------------------------------------------------------------//
   
	RecLock("CB0",.T.)
	    CB0->CB0_FILIAL :=  xfilial('CB0')
	    //CB0->CB0_CODETI :=  STRZERO(VAL(MCB0_CODETI)+_yxcont,10,0) 
	    CB0->CB0_CODETI :=  GetSx8Num("CB0","CB0->CB0_CODETI")
		CB0->CB0_XETIQ	:=	MCB0_XETIQ
		CB0->CB0_DTNASC	:=	MCB0_DTNASC
		CB0->CB0_DTVLD	:=	MCB0_DTVLD
		CB0->CB0_CODPRO	:=	MCB0_CODPRO
		CB0->CB0_QTDE	:=	MCB0_QTDE
		CB0->CB0_XSALDO	:=	MCB0_XSALDO
		CB0->CB0_LOCAL	:=	MCB0_LOCAL
		CB0->CB0_LOTE	:=	MCB0_LOTE
		CB0->CB0_FORNEC	:=	MCB0_FORNEC
		CB0->CB0_LOJAFO	:=	MCB0_LOJAFO
		CB0->CB0_SERIEE	:=	MCB0_SERIEE
		CB0->CB0_CLI	:=	MCB0_CLI
		CB0->CB0_LOJACL	:=	MCB0_LOJACL
		CB0->CB0_PEDVEN	:=	MCB0_PEDVEN
		CB0->CB0_NFSAI	:=	MCB0_NFSAI
		CB0->CB0_SERIES	:=	MCB0_SERIES
		CB0->CB0_VOLUME	:=	MCB0_VOLUME
		CB0->CB0_TRANSP	:=	MCB0_TRANSP
		CB0->CB0_STATUS	:=	MCB0_STATUS
		CB0->CB0_LOCORI	:=	MCB0_LOCORI
		CB0->CB0_ORIGEM	:=	MCB0_ORIGEM
		CB0->CB0_XUSER	:=	MCB0_XUSER
		CB0->CB0_XOBS	:=	MCB0_XOBS
		CB0->CB0_XMOTIV	:=	MCB0_XMOTIV
		CB0->CB0_PALLET	:=	MCB0_PALLET 
		CB0->CB0_NFENT	:=	MCB0_NFENT   
		CB0->CB0_OP		:=	MCB0_OP   
    MsUnlock()

	U_TTB_ETIQ_2({CB0->CB0_CODETI,;
			             CB0->CB0_LOTE,;
			             CB0->CB0_NFENT,;
			             CB0->CB0_QTDE,;
			             CB0->CB0_FORNEC,;
			             POSICIONE('SA2', 1, xFilial('SA2') + CB0->CB0_FORNEC, 'A2_NOME'),;
			             CB0->CB0_CLI,;
			             POSICIONE('SA1', 1, xFilial('SA1') + CB0->CB0_CLI, 'A1_NOME'),;
			             "MB07",;
			             CB0->CB0_CODPRO,;
			             POSICIONE('SB1', 1, xFilial('SB1') + CB0->CB0_CODPRO, 'B1_DESC'),;
			             CB0->CB0_XBAG})
			//				1			      2				3			4		5				6				7			8		9			10          11           12
	    
    RESTAREA(aAreaAnt)           
    ConfirmSx8()

Return( nil)
