#include 'parmtype.ch'
#include "fileio.ch"
#Include "Protheus.ch"
#Include "Totvs.ch"
#Include "RESTFUL.ch"
#Include "FWMVCDef.ch"
#Include "RwMake.ch"
#Include "TbiConn.ch"

#define CRLF Chr(13) + Chr(10)

/*
+------------+----------+--------+----------------+-------+----------------+
| Programa:  | PdComNim | Autor: |Isaias Gravatal | Data: |   Jul/2021     |
+------------+----------+--------+---------------+--------+----------------+
| Descrição: | Programa de para gerar Pedido de compras com origem do Nimbi|
+------------+-------------------------------------------------------------+
| Uso:       | Care Plus                                                   |
+------------+-------------------------------------------------------------+
*/

User Function PdComNim()

	Local oRest   := Nil
	Local cUrl    := ""
	Local cResult := ""
	Local cDtaIni := substr(dtos(ddatabase-10),1,4) +"-"+ substr(dtos(ddatabase-10),5,2)+"-" + substr(dtos(ddatabase-10),7,2)
	Local cDtaFim := substr(dtos(ddatabase),1,4) +"-"+ substr(dtos(ddatabase),5,2)+"-" + substr(dtos(ddatabase),7,2)
	Local nX      := 0
	Local aHeader := {}


	Private cIdPZB
	Private oObj1    := Nil
	Private aCabec   := {}
	Private aItens   := {}
	Private aLinha   := {}
	Private aRatCC   := {}
	Private aRatPrj  := {}
	Private aCriaServ:= {}

If IsBlind()
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101" USER 'teste' PASSWORD 'Q!w2e3r4' MODULO "COM"
EndIf

	//------------------------------------------------------------------//
	//  Chama funcao para Iniciar informacao de monitoramento do servico //
	//------------------------------------------------------------------//
	//aCriaServ := U_MonitRes("0000AD", 1)
	//cIdPZB 	  := aCriaServ[2]

	//------------------------------------------------------------------//
	//  Chama funcao para gravar informacao de monitoramento do servico //
	//------------------------------------------------------------------//
	cMenssagem := "Inicio de importacao de pedidos de compras Nimbi"
//	U_MonitRes("0000AD", 2, , cIdPZB, cMenssagem, .T., "Get de pedidos Nimbi", cResult, "", "", .F., .F.)

	//Adiciona informaçoes no cabecalho de autenticacao do Rest
	//If "L91FWF_HOM" $ UPPER(Alltrim(GetEnvServer())) //Caso seja ambiente de Produção
		aAdd(aHeader,'Content-Type: application/json')
		aAdd(aHeader,'ClientAPI_ID: 6951056a-bf4c-416e-8b80-366a2b97ac0e')
		aAdd(aHeader,'ClientAPI_Key: 7a92b33b-51db-4b96-a8ab-8d8253aa5d3d')
		aAdd(aHeader,'companyTaxNumber: 02725347000127')
		aAdd(aHeader,'companyCountryCode: BR')
		cUrl := "https://api01-qa.nimbi.net.br/"
	//else
		//aAdd(aHeader,'Content-Type:application/json')
		//aAdd(aHeader,'ClientAPI_ID:6951056a-bf4c-416e-8b80-366a2b97ac0e')
		//aAdd(aHeader,'ClientAPI_Key:7a92b33b-51db-4b96-a8ab-8d8253aa5d3d')
		//aAdd(aHeader,'companyTaxNumber:02725347000127')
		//aAdd(aHeader,'companyCountryCode:BR')
		//cUrl := "https://api01-qa.nimbi.net.br/"
	//EndIf
	dbSelectArea("SC7")
	//URL da aplicacao Rest
	oRest := FWRest():New(cUrl)

	//Set Path do Rest
	oRest:setPath("CompraAPI/rest/PurchaseOrders/v1?initialDate="+ cDtaIni + "T00:00:00.000Z&finalDate=" + cDtaFim + "T23:59:59.999Z&orderStatusId=8")


	If oRest:Get(aHeader)
		//-----------------------------------------
		//Retorno com sucesso de envio Json
		//-----------------------------------------

		//------------------------------------------------------------------//
		//  Chama funcao para gravar informacao de monitoramento do servico //
		//------------------------------------------------------------------//
		cMenssagem := "Carregado Id's de pedidos de compras Nimbi"
		//U_MonitRes("0000AD", 2, , cIdPZB, cMenssagem, .T., "Get de pedidos Nimbi", cResult, "", "", .F., .F.)

		cResult := oRest:GetResult()

		//Deserializa a string JSON
		FWJsonDeserialize(cResult, @oObj1)
		IF ValType(oObj1) == "O"
			if Type("oObj1:purchaseOrders") == "U"
				Return 
			Endif	 
			If Len(oObj1:purchaseOrders) >= 1
				//aCriaServ := U_MonitRes("0000AD", 1)
				For nX := 1 To Len(oObj1:purchaseOrders)
					
					//cIdPZB 	  := aCriaServ[2]
					aCabec   := {}
					aItens   := {}
					aLinha   := {}
					aRatCC   := {}
					aRatPrj  := {}

					//------------------------------------------------------------------//
					//  Chama funcao para gravar informacao de monitoramento do servico //
					//------------------------------------------------------------------//
					cMenssagem := "API para criar cabecalho de pedido Nimbi Id " + AllTrim(STR(oObj1:purchaseOrders[nX]:id))
					//U_MonitRes("0000AD", 2, , cIdPZB, cMenssagem, .T., "Get de pedidos Nimbi", cResult, "", "", .F., .F.)
				
					//-----------------------------------------------------------//
					//  Chama Api para buscar o cabecalho do pedido              //
					//-----------------------------------------------------------//
					lRet :=	gPedCab(AllTrim(STR(oObj1:purchaseOrders[nX]:id)))

					If !lRet
						//------------------------------------------------------------------//
						//  Chama funcao para finalizar monitoramento do servico            //
						//------------------------------------------------------------------//
						//U_MonitRes("0000AD", 3, , cIdPZB, , .T.)

						Return()
					EndIf

					//------------------------------------------------------------------//
					//  Chama funcao para gravar informacao de monitoramento do servico //
					//------------------------------------------------------------------//
					cMenssagem := "API para criar itens de pedido Nimbi Id " + AllTrim(STR(oObj1:purchaseOrders[nX]:id))
					//U_MonitRes("0000AD", 2, , cIdPZB, cMenssagem, .T., "Get de pedidos Nimbi", cResult, "", "", .F., .F.)

					//-----------------------------------------------------------//
					//  Chama Api para buscar os itens do pedido                 //
					//-----------------------------------------------------------//
					lRet := gPedIte(AllTrim(STR(oObj1:purchaseOrders[nX]:id)))

					If !lRet
						//------------------------------------------------------------------//
						//  Chama funcao para finalizar monitoramento do servico            //
						//------------------------------------------------------------------//
						//U_MonitRes("0000AD", 3, , cIdPZB, , .T.)

						Return()
					EndIf


					//------------------------------------------------------------------//
					//  Chama funcao para gravar informacao de monitoramento do servico //
					//------------------------------------------------------------------//
					cMenssagem := "API para ExecAuto de pedido Nimbi Id " + AllTrim(STR(oObj1:purchaseOrders[nX]:id))
					//U_MonitRes("0000AD", 2, , cIdPZB, cMenssagem, .T., "Get de pedidos Nimbi", cResult, "", "", .F., .F.)

					//-----------------------------------------------------------//
					//  Chama funcao para executar ExecAuto de pedido de compra  //
					//-----------------------------------------------------------//
					lRet := IncPed( AllTrim(STR(oObj1:purchaseOrders[nX]:id)) )

					If lRet
						//-------------------------------------------------------------//
						//  Chama Api para alterar status do pedido de compra no Nimbi //
						//-------------------------------------------------------------//
						PAltPed(AllTrim(STR(oObj1:purchaseOrders[nX]:id)))
					else

					Endif
					
				Next nX
				//U_MonitRes("0000AD", 3, ,, , .T.)	
			EndIf
		else
			MsgInfo("No momento nao foi possivel encontrar pedidos no Nimbi " + CRLF + " Tente mais tarde!")
		EndIf
	Else
		cResult := oRest:GetLastError()
		MsgInfo("Houve problema em busca pelo Get")
		Return()
	EndIf

	//------------------------------------------------------------------//
	//  Chama funcao para finalizar monitoramento do servico            //
	//------------------------------------------------------------------//
	//U_MonitRes("0000AD", 3, , cIdPZB, , .T.)

Return()


/*
+------------+----------+--------+----------------+-------+----------------+
| Programa:  | gPedCab  | Autor: |Isaias Gravatal | Data: |   Jul/2021     |
+------------+----------+--------+---------------+--------+----------------+
| Descrição: | Função utilizada para coletar dados do cabecalho de         |
|            | pedido de compra                                            |
+------------+-------------------------------------------------------------+
| Uso:       | Care Plus                                                   |
+------------+-------------------------------------------------------------+
*/

Static Function gPedCab(nIdPed)

	Local oRest   := Nil
	Local cUrl    := ""
	Local cResult := ""
	Local aHeader := {}
	Local cTipoMsg  := '0000AG'
	Local aRequest := {} 

	Private oObj2    := Nil

	Default nIdPed := "0"
	//Adiciona informaçoes no cabecalho de autenticacao do Rest
	If "L91FWF_TESTE" $ UPPER(Alltrim(GetEnvServer())) //Caso seja ambiente de Produção
		aAdd(aHeader,'Content-Type:application/json')
		aAdd(aHeader,'ClientAPI_ID:6951056a-bf4c-416e-8b80-366a2b97ac0e')
		aAdd(aHeader,'ClientAPI_Key:7a92b33b-51db-4b96-a8ab-8d8253aa5d3d')
		aAdd(aHeader,'companyTaxNumber:02725347000127')
		aAdd(aHeader,'companyCountryCode:BR')
		cUrl := "https://api01-qa.nimbi.net.br/"
	else
		aAdd(aHeader,'Content-Type:application/json')
		aAdd(aHeader,'ClientAPI_ID:6951056a-bf4c-416e-8b80-366a2b97ac0e')
		aAdd(aHeader,'ClientAPI_Key:7a92b33b-51db-4b96-a8ab-8d8253aa5d3d')
		aAdd(aHeader,'companyTaxNumber:02725347000127')
		aAdd(aHeader,'companyCountryCode:BR')
		cUrl := "https://api01-qa.nimbi.net.br/"
	EndIf

	//URL da aplicacao Rest
	oRest := FWRest():New(cUrl)

	//Set Path do Rest
	oRest:setPath("CompraAPI/rest/PurchaseOrders/v1/" + nIdPed)


	If oRest:Get(aHeader)
		//-----------------------------------------
		//Retorno com sucesso de envio Json
		//-----------------------------------------

		cResult := oRest:GetResult()

		//Deserializa a string JSON
		FWJsonDeserialize(cResult, @oObj2)

		IF ValType(oObj2) == "O"
			If  oObj2:purchaseOrder:id >= 1

				

				// Inclusão de pedido
				cDoc := GetSXENum("SC7","C7_NUM")
				SC7->(dbSetOrder(1))
				ConfirmSX8()

				While SC7->(dbSeek(xFilial("SC7")+cDoc))
					ConfirmSX8()
					cDoc := GetSXENum("SC7","C7_NUM")
				EndDo
				dbSelectArea("SA2")
				SA2->(dbSetOrder(3))
				If !SA2->(dbSeek(xFilial("SA2")+oObj2:purchaseOrder:supplierCompanyTaxNumber))
					aCriaServ:= {}
				    aCriaServ := U_MonitRes("0000AG",1,1)
	                cLastTime := Time()
					//Id gerado na criacao do servico
					cIdPZB := aCriaServ[2]
					aParGet:={}
					
					CidValue := '/'+oObj2:purchaseOrder:supplierCompanyTaxNumber +'/BR'
					//add(aParGet,'CountryCode=BR')
					aRequest := U_ResInteg("0000AG", "", aHeader ,, .T.,,,,CidValue)
					If aRequest[1]
						
						oRet := aRequest[2]

						cMenssagem  := cTipoMsg+" com sucesso."
						cJsoRec     := aRequest[3]
						CCHAVE := oObj2:purchaseOrder:supplierCompanyTaxNumber
						oModel := FWLoadModel('MATA020')
						oModel:SetOperation(3)
						oModel:Activate()

						//Cabeçalho
						IF Valtype(oRet:company:companyname) == 'C'
							oModel:SetValue('SA2MASTER','A2_COD' ,GetSXENum('SA2','A2_COD'))
							oModel:SetValue('SA2MASTER','A2_LOJA' ,'01')
							oModel:SetValue('SA2MASTER','A2_NOME' ,oRet:company:companyname)
							oModel:SetValue('SA2MASTER','A2_NREDUZ' ,oRet:company:companyname)
							oModel:SetValue('SA2MASTER','A2_NATUREZ' ,"OUTROS"    )
							oModel:SetValue('SA2MASTER','A2_BAIRRO' ,oRet:company:address:CITYNAME)
							oModel:SetValue('SA2MASTER','A2_EST' ,oRet:company:address:STATECODE)
							oModel:SetValue('SA2MASTER','A2_COD_MUN',oRet:company:address:CITYCODE)
							oModel:SetValue('SA2MASTER','A2_MUN' ,oRet:company:address:CITYNAME)
							oModel:SetValue('SA2MASTER','A2_TIPO' ,'J')
							oModel:SetValue('SA2MASTER','A2_CEP' ,oRet:company:address:zipcode) 
							oModel:SetValue('SA2MASTER','A2_END' ,oRet:company:address:address)
							oModel:SetValue('SA2MASTER','A2_CGC' ,oRet:company:taxnumber)
							

						If oModel:VldData()
							oModel:CommitData()
						Endif

						oModel:DeActivate()

						oModel:Destroy()
						U_MonitRes("0000AG", 2, , cIdPZB, cMenssagem, .T., cChave, '', cJsoRec, )
						lIten := .T.
						Else
							cMenssagem := 'CODIGO FORNECEDOR INCORRETO' 
								U_MonitRes("0000AG",, 2, , cIdPZB, cMenssagem, .F., cChave, cJson, cJsoRec  )
					
						EndIF
					Else

						cMenssagem  := "Falha na "+cTipoMsg
						cJsoRec     := aRequest[3]
						
						U_MonitRes("0000AG",, 2, , cIdPZB, cMenssagem, .F., cChave, cJson, cJsoRec  )
						lIten := .F.
					EndIf

				 	//Finaliza o processo na PZB
				 	U_MonitRes("0000AG", 3, , cIdPZB, , .T.)

				EndIF
				dbSelectArea("SA2")
				SA2->(dbSetOrder(3))
				If SA2->(dbSeek(xFilial("SA2")+oObj2:purchaseOrder:supplierCompanyTaxNumber))
					cCnpj := oObj2:purchaseOrder:PAYMENTADDRESSEXTERNALCODE
					aSm0:={}
					aSm0 := FWLoadSM0()
					nPos := Ascan(aSM0,{|x| Alltrim(x[18]) == Alltrim(cCnpj )})
					cCodFil := cFilAnt
					If nPos > 0
						cCodFil := aSm0[nPos][02]
						cFilAnt := cCodFil
					EndIf
					aUser := {}
					aUser := FWSFAllUsers()
					nPOs := aScan(aUser , {|x | Upper(AllTrim(x[3])) == UPPER(Substr(oObj2:purchaseOrder:BUYERCONTACT,1,at('@',oObj2:purchaseOrder:BUYERCONTACT)-1))})
					__cUserId:= aUser[npos][2]
					aadd(aCabec,{"C7_NUM"     , cDoc})
					aadd(aCabec,{"C7_XIDNIMB"       , cValtochar(oObj2:purchaseOrder:id)                           })
					aadd(aCabec,{"C7_EMISSAO" , stod(StrTran(SubStr(oObj2:purchaseOrder:CreatedDate,1,10), '-',''))})
					aadd(aCabec,{"C7_FORNECE" , SA2->A2_COD                                                        })
					aadd(aCabec,{"C7_LOJA"    , SA2->A2_LOJA                                                       })
					aadd(aCabec,{"C7_COND"    , Left(oObj2:purchaseOrder:PaymentTypeCode,TamSX3("C7_COND")[1])     })
					aadd(aCabec,{"C7_FILENT"  , cCodFil                                                            })
					aadd(aCabec,{"C7_CONAPRO"  , 'B'                                                            })
					lRet := .T.
				else
					//------------------------------------------------------------------//
					//  Chama funcao para gravar informacao de monitoramento do servico //
					//------------------------------------------------------------------//
					cMenssagem := "Nao foi encontrado o fornecedor para pedido Nimbi Id " + nIdPed
					//U_MonitRes("0000AD", 2, , cIdPZB, cMenssagem, .T., "Get de pedidos Nimbi", cResult, "", "", .F., .F.)

					lRet := .F.
				EndIF


			else
				MsgInfo("No momento nao foi possivel encontrar pedidos com status liberado para ERP")
			EndIf
		EndIf
	Else
		MsgInfo("Houve problema em busca pelo Get")
		Return()
	EndIf


Return(lRet)


/*
+------------+----------+--------+----------------+-------+----------------+
| Programa:  | gPedIte  | Autor: |Isaias Gravatal | Data: |   Jul/2021     |
+------------+----------+--------+---------------+--------+----------------+
| Descrição: | Função utilizada para coletar dados de Itens do pedido      |
+------------+-------------------------------------------------------------+
| Uso:       | Care Plus                                                   |
+------------+-------------------------------------------------------------+
*/

Static Function gPedIte(nIdPed)

	Local oRest1   := Nil
	Local oRest2   := Nil
	Local oRest3   := Nil
	Local cUrl     := ""
	Local cResult1 := ""
	Local cResult2 := ""
	Local cResult3 := ""
	Local nX       := 0
	Local nZ       := 0
	Local aHeader  := {}
	Local aRatCC  :={}

	Private oObj3  := Nil
	Private oObj4  := Nil
	Private oObj5  := Nil

	Default nIdPed := "0"
	//Adiciona informaçoes no cabecalho de autenticacao do Rest
	If "L91FWF_TESTE" $ UPPER(Alltrim(GetEnvServer())) //Caso seja ambiente de Produção
		aAdd(aHeader,'Content-Type:application/json')
		aAdd(aHeader,'ClientAPI_ID:6951056a-bf4c-416e-8b80-366a2b97ac0e')
		aAdd(aHeader,'ClientAPI_Key:7a92b33b-51db-4b96-a8ab-8d8253aa5d3d')
		aAdd(aHeader,'companyTaxNumber:02725347000127')
		aAdd(aHeader,'companyCountryCode:BR')
		cUrl := "https://api01-qa.nimbi.net.br/"
	else
		aAdd(aHeader,'Content-Type:application/json')
		aAdd(aHeader,'ClientAPI_ID:6951056a-bf4c-416e-8b80-366a2b97ac0e')
		aAdd(aHeader,'ClientAPI_Key:7a92b33b-51db-4b96-a8ab-8d8253aa5d3d')
		aAdd(aHeader,'companyTaxNumber:02725347000127')
		aAdd(aHeader,'companyCountryCode:BR')
		cUrl := "https://api01-qa.nimbi.net.br/"
	EndIf

	//URL da aplicacao Rest
	oRest1 := FWRest():New(cUrl)

	//Set Path do Rest
	oRest1:setPath("CompraAPI/rest/PurchaseOrders/v1/" + nIdPed + "/items" )


	If oRest1:Get(aHeader)
		//-----------------------------------------
		//Retorno com sucesso de envio Json
		//-----------------------------------------

		cResult1 := oRest1:GetResult()

		//Deserializa a string JSON
		FWJsonDeserialize(cResult1, @oObj3)
		IF ValType(oObj3) == "O"  .And. Len(oObj3:purchaseOrder:items) >= 1

			For nX := 1 To Len(oObj3:purchaseOrder:items)
				// Zera aLinha
				aLinha := {}

				//URL da aplicacao Rest
				oRest2 := FWRest():New(cUrl)

				//Set Path do Rest
				oRest2:setPath("CompraAPI/rest/PurchaseOrders/v1/" + nIdPed + "/item/" + AllTrim(Str(oObj3:purchaseOrder:items[nX]:id)) )

				If oRest2:Get(aHeader)

					//-----------------------------------------
					//Retorno com sucesso de envio Json
					//-----------------------------------------
					cResult2 := oRest2:GetResult()

					//Deserializa a string JSON
					FWJsonDeserialize(cResult2, @oObj4)

					dbSelectArea("SB1")
					SB1->(dbSetOrder(1))
					If SB1->(dbSeek(xFilial("SB1")+oObj4:orderItem:code))
					

						aLinha := {}
						aadd(aLinha,{"C7_ITEM"    , StrZero(nX, 4)             , Nil})
						//aadd(aCabec,{"C7_XIDNIMB"       , cValtochar(oObj2:purchaseOrder:id)                           })
						aadd(aLinha,{"C7_PRODUTO" , oObj4:orderItem:code       , Nil})
						aadd(aLinha,{"C7_QUANT"   , oObj4:orderItem:Quantity   , Nil})
						aadd(aLinha,{"C7_PRECO"   , oObj4:orderItem:UnitPrice  , Nil})
						aadd(aLinha,{"C7_TOTAL"   , oObj4:orderItem:TotalPrice , Nil})
						aadd(aLinha,{"C7_TES"   , '001' , Nil})
						aadd(aLinha,{"C7_USER"   , RetcoDUsr() , Nil})
						aadd(aLinha,{"C7_NUMSC" ,iif(type('oObj4:orderItem:ORIGINREQUISITION:CodeERP') <> "U",oObj4:orderItem:ORIGINREQUISITION:CodeERP,'')  ,Nil})
						aadd(aLinha,{"C7_ITEMSC",iif(type('oObj4:orderItem:ORIGINREQUISITION:LineERP') <> "U",oObj4:orderItem:ORIGINREQUISITION:LineERP,'')  ,Nil})
						cNum := iif(type('oObj4:orderItem:ORIGINREQUISITION:CodeERP') <> "U",oObj4:orderItem:ORIGINREQUISITION:CodeERP,'')
						citem := iif(type('oObj4:orderItem:ORIGINREQUISITION:LineERP') <> "U",oObj4:orderItem:ORIGINREQUISITION:LineERP,'')
						aadd(aLinha,{"C7_CLVL"   ,Posicione("SC1",1,xFilial("SC1")+cNum+citem,"C1_CLVL"),nil} )
						aadd(aLinha,{"C7_XCLASS"   ,Posicione("SC1",1,xFilial("SC1")+cNum+citem,"C1_XCLASS"),nil} )
						aadd(aLinha,{"C7_IPI"   , iif(type('oObj4:orderItem:taxesOrdemItem:IPI') <> "U",oObj4:orderItem:taxesOrdemItem:IPI,0) , Nil})
						aadd(aLinha,{"C7_BASEIPI"   , iif(type('oObj4:orderItem:taxesOrdemItem:baseIPI') <> "U",oObj4:orderItem:taxesOrdemItem:baseIPI,0) , Nil})
						aadd(aLinha,{"C7_BASEICM"   ,  iif(type('oObj4:orderItem:taxesOrdemItem:baseICMS') <> "U",oObj4:orderItem:taxesOrdemItem:baseICMS,0)  , Nil})
						aadd(aLinha,{"C7_PICM"   ,  iif(type('oObj4:orderItem:taxesOrdemItem:ICMS') <> "U",oObj4:orderItem:taxesOrdemItem:ICMS,0)  , Nil})
						
						

						lRet := .T.
					else
						//------------------------------------------------------------------//
						//  Chama funcao para gravar informacao de monitoramento do servico //
						//------------------------------------------------------------------//
						cMenssagem := "Nao foi encontrado o Produto para pedido Nimbi Id " + nIdPed
						//U_MonitRes("0000AD", 2, , cIdPZB, cMenssagem, .T., "Get de pedidos Nimbi", cResult2, "", "", .F., .F.)

						lRet := .F.
						Return(lRet)
					EndIf
				EndIf

				//URL da aplicacao Rest
				oRest3 := FWRest():New(cUrl)

				//Set Path do Rest
				oRest3:setPath("CompraAPI/rest/PurchaseOrders/v1/" + nIdPed + "/item/" + AllTrim(Str(oObj3:purchaseOrder:items[nX]:id)) + "/costAllocations?offset=0&limit=50" )

				If oRest3:Get(aHeader)
					oJson := JsonObject():New()
					
					oJson:FromJson(oRest3:Getresult())

					//------------------------------------------------------------------//
					//  Chama funcao para gravar informacao de monitoramento do servico //
					//------------------------------------------------------------------//
					cMenssagem := "API para criar rateio de pedido Nimbi Id " + AllTrim(Str(oObj3:purchaseOrder:items[nX]:id))
					//U_MonitRes("0000AD", 2, , cIdPZB, cMenssagem, .T., "Get de pedidos Nimbi", "", "", "", .F., .F.)

					// Monta itens rateio
					aAdd(aRatCC,{ StrZero(nX, 4) ,{ }})
					lcc := .T.

					For nZ := 1 To Len(oJson["purchaseOrder"]["CostAllocation"])
						//-----------------------------------------
						//Retorno com sucesso de envio Json
						//-----------------------------------------

						lcc := .F.
						// itens do rateio
						//aAdd(aItemCC,{"CH_ITEM",StrZero(nZ,Len(SCH->CH_ITEM))                                   , NIL})
						//aAdd(aItemCC,{"CH_PERC",oJson["purchaseOrder"]["CostAllocation"][nZ]["Percentage"]               , NIL}) // Percentual a ser ratiado.
						//aAdd(aItemCC,{"CH_CC"  ,oJson["purchaseOrder"]["CostAllocation"][nZ]["CostAllocationDetailCode"]  , NIL}) //centro de custo do primeiro Item.
						aadd(aLinha,{"C7_CC"   , oJson["purchaseOrder"]["CostAllocation"][nZ]["CostAllocationDetailCode"] , Nil})	
						aadd(aItens,aLinha)
					Next nZ
					If lcc 
						aadd(aItens,aLinha)
					EndIF

				EndIf

			Next nX

		else
			MsgInfo("No momento nao foi possivel encontrar itens com esse id de pedido ")
			Return(.F.)
		EndIf
	Else
		MsgInfo("Houve problema em busca pelo Get")
		Return(.F.)
	EndIf


Return(lRet)


/*
+------------+----------+--------+----------------+-------+----------------+
| Programa:  | PAltPed  | Autor: |Isaias Gravatal | Data: |   Jul/2021     |
+------------+----------+--------+---------------+--------+----------------+
| Descrição: | Função utilizada para atualizar status de pedido de compra  |
|            | no sistema Nimbi                                            |
+------------+-------------------------------------------------------------+
| Uso:       | Care Plus                                                   |
+------------+-------------------------------------------------------------+
*/

Static Function PAltPed(nIdPed,nOpc, cMsg)

	Local oRest   := Nil
	Local cUrl    := ""
	Local aHeader := {}

	Private oObj5    := Nil

	Default nIdPed := "0"
	Default nOpc   := 1
	Default cMsg   := ""
	//Adiciona informaçoes no cabecalho de autenticacao do Rest
	If "L91FWF_TESTE" $ UPPER(Alltrim(GetEnvServer())) //Caso seja ambiente de Produção
		aAdd(aHeader,'Content-Type:application/json')
		aAdd(aHeader,'ClientAPI_ID:6951056a-bf4c-416e-8b80-366a2b97ac0e')
		aAdd(aHeader,'ClientAPI_Key:7a92b33b-51db-4b96-a8ab-8d8253aa5d3d')
		aAdd(aHeader,'companyTaxNumber:02725347000127')
		aAdd(aHeader,'companyCountryCode:BR')
		cUrl := "https://api01-qa.nimbi.net.br/"
	else
		aAdd(aHeader,'Content-Type:application/json')
		aAdd(aHeader,'ClientAPI_ID:6951056a-bf4c-416e-8b80-366a2b97ac0e')
		aAdd(aHeader,'ClientAPI_Key:7a92b33b-51db-4b96-a8ab-8d8253aa5d3d')
		aAdd(aHeader,'companyTaxNumber:02725347000127')
		aAdd(aHeader,'companyCountryCode:BR')
		cUrl := "https://api01-qa.nimbi.net.br/"
	EndIf

	//URL da aplicacao Rest
	oRest := FWRest():New(cUrl)

	If nOpc == 1
		//Set Path do Rest
		oRest:setPath("CompraAPI/rest/PurchaseOrders/v1/" + nIdPed + "/status?operationCode=APPROVE")

		If (oRest:Put(aHeader ))
			//------------------------------------------------------------------//
			//  Chama funcao para gravar informacao de monitoramento do servico //
			//------------------------------------------------------------------//
			cMenssagem := "API para alteracao de status pedido Nimbi Id " + nIdPed
			//U_MonitRes("0000AD", 2, , cIdPZB, cMenssagem, .T., "Get de pedidos Nimbi", "", "", "", .F., .F.)

			//-----------------------------------------
			//Retorno com sucesso de envio Json
			//-----------------------------------------
			ConOut("PUT: " + oRest:GetResult())
		Else
			ConOut("PUT: " + oRest:GetLastError())
		EndIf


	else
		//Set Path do Rest
		oRest:setPath("CompraAPI/rest/PurchaseOrders/v1/" + nIdPed + "/status?operationCode=RETURN")

		cJson := '{ "comment": "' + cMsg + '",  "isPublic": true}'

		If (oRest:Put(aHeader, cJson))
			//------------------------------------------------------------------//
			//  Chama funcao para gravar informacao de monitoramento do servico //
			//------------------------------------------------------------------//
			cMenssagem := "API para alteracao de status pedido Nimbi Id " + nIdPed
			//U_MonitRes("0000AD", 2, , cIdPZB, cMenssagem, .T., "Get de pedidos Nimbi", '', "", "", .F., .F.)

			//-----------------------------------------
			//Retorno com sucesso de envio Json
			//-----------------------------------------
			ConOut("PUT: " + oRest:GetResult())
		Else
			ConOut("PUT: " + oRest:GetLastError())
		EndIf


	EndIf




Return()


Static Function IncPed(nIdPed)

	Local nOpc     := 3
	Local lRet

	PRIVATE lMsErroAuto := .F.

	If Len(aRatCC) > 0
		MSExecAuto({|a,b,c,d,e,f,g| MATA120(a,b,c,d,e,f)},1,aCabec,aItens,nOpc,.F.,aRatCC)
	else
		MSExecAuto({|a,b,c,d,e,f,g| MATA120(a,b,c,d,e)},1,aCabec,aItens,nOpc,.F.)
	EndIf

	If !lMsErroAuto

		//------------------------------------------------------------------//
		//  Chama funcao para gravar informacao de monitoramento do servico //
		//------------------------------------------------------------------//
		cMenssagem := "Pedido Nimbi Id " + nIdPed + " incluido com sucesso"
		//U_MonitRes("0000AD", 2, , cIdPZB, cMenssagem, .T., "Get de pedidos Nimbi", "", "", "", .F., .F.)

		//-------------------------------------------------------------//
		//  Chama Api para alterar status do pedido de compra no Nimbi //
		//-------------------------------------------------------------//
		//(AllTrim(nIdPed), 1)

		lRet := .T.
	Else
		cErroTemp := Mostraerro("\spool\",DTOS(DATE()) + StrTran( Time(),":","-") + ".log")
		nLinhas   := MLCount(cErroTemp)
		cBuffer   := ""
		cCampo    := ""
		nErrLin   := 1
		cBuffer:=RTrim(MemoLine(cErroTemp,,nErrLin))
//Carrega o nome do campo
		While (nErrLin <= nLinhas)
			nErrLin++
			cBuffer:=RTrim(MemoLine(cErroTemp,,nErrLin))
			If (Upper(SubStr(cBuffer,Len(cBuffer)-7,Len(cBuffer))) == "INVALIDO")
				cCampo := cBuffer
				xTemp  := AT("-",cBuffer)
				cCampo := AllTrim(SubStr(cBuffer,xTemp+1,AT(":",cBuffer)-xTemp-2))
				Exit
			EndIf
		EndDo
		
		//------------------------------------------------------------------//
		//  Chama funcao para gravar informacao de monitoramento do servico //
		//------------------------------------------------------------------//
		
		cMenssagem := "Pedido Nimbi Id " + nIdPed + " nao incluido "
		cMenssagem += cBuffer
		//U_MonitRes("0000AD", 2, , cIdPZB, cMenssagem, .T., "Get de pedidos Nimbi", "", "", "", .F., .F.)

		//-------------------------------------------------------------//
		//  Chama Api para alterar status do pedido de compra no Nimbi //
		//-------------------------------------------------------------//
		IF "AJUDA:WF" $cErroTemp
			cMenssagem := "Pedido Nimbi Id " + nIdPed + "incluido "
			PAltPed(AllTrim(nIdPed), 1, cMenssagem)
		Else
			PAltPed(AllTrim(nIdPed), 2, cMenssagem)
		EndIF
		lRet := .F.
	EndIf
	If IsBlind()
		RESET ENVIRONMENT
	Endif

Return(lRet)


//-------------------------------------------------------------------
/*{Protheus.doc} u_UsrByName
Busca e retorna um usuário com base no nome

@param cName Nome do usuário

@return aUser Array com os dados do usuário encontrado

@author Daniel Mendes
@since 25/06/2020
@version 1.0
*/
//-------------------------------------------------------------------
User function UsrByName(cName)
local aUsersAux as array
local aUser as array
local nPos as numeric

aUsersAux := FWSFAllUsers(/*aUserList*/, {"USR_NOME"})
cName := Upper(AllTrim(cName))
nPos := aScan(aUsersAux, {|aUsr| Upper(AllTrim(aUsr[3])) == cName})

if nPos > 0
    aUser := aClone(aUsersAux[nPos])
else
    aUser := {}
endif

aSize(aUsersAux, 0)
aUsersAux := nil

return aUser


User Function PNINSTA(nIdPed)

	Local oRest   := Nil
	Local cUrl    := ""
	Local aHeader := {}

	Private oObj5    := Nil

	Default nIdPed := "0"
	
	//Adiciona informaçoes no cabecalho de autenticacao do Rest
	If "L91FWF_TESTE" $ UPPER(Alltrim(GetEnvServer())) //Caso seja ambiente de Produção
		aAdd(aHeader,'Content-Type:application/json')
		aAdd(aHeader,'ClientAPI_ID:6951056a-bf4c-416e-8b80-366a2b97ac0e')
		aAdd(aHeader,'ClientAPI_Key:7a92b33b-51db-4b96-a8ab-8d8253aa5d3d')
		aAdd(aHeader,'companyTaxNumber:02725347000127')
		aAdd(aHeader,'companyCountryCode:BR')
		cUrl := "https://api01-qa.nimbi.net.br/"
	else
		aAdd(aHeader,'Content-Type:application/json')
		aAdd(aHeader,'ClientAPI_ID:6951056a-bf4c-416e-8b80-366a2b97ac0e')
		aAdd(aHeader,'ClientAPI_Key:7a92b33b-51db-4b96-a8ab-8d8253aa5d3d')
		aAdd(aHeader,'companyTaxNumber:02725347000127')
		aAdd(aHeader,'companyCountryCode:BR')
		cUrl := "https://api01-qa.nimbi.net.br/"
	EndIf

	//URL da aplicacao Rest
	oRest := FWRest():New(cUrl)

	If nOpc == 1
		//Set Path do Rest
		oRest:setPath("CompraAPI/rest/PurchaseOrders/v1/" + nIdPed + "/status?operationCode=APPROVE")

		If (oRest:Put(aHeader ))
			//------------------------------------------------------------------//
			//  Chama funcao para gravar informacao de monitoramento do servico //
			//------------------------------------------------------------------//
			cMenssagem := "API para alteracao de status pedido Nimbi Id " + nIdPed
			//U_MonitRes("0000AD", 2, , cIdPZB, cMenssagem, .T., "Get de pedidos Nimbi", "", "", "", .F., .F.)

			//-----------------------------------------
			//Retorno com sucesso de envio Json
			//-----------------------------------------
			ConOut("PUT: " + oRest:GetResult())
		Else
			ConOut("PUT: " + oRest:GetLastError())
		EndIf


	else
		//Set Path do Rest
		oRest:setPath("CompraAPI/rest/PurchaseOrders/v1/" + nIdPed + "/status?operationCode=RETURN")

		cJson := '{ "comment": "' + cMsg + '",  "isPublic": true}'

		If (oRest:Put(aHeader, cJson))
			//------------------------------------------------------------------//
			//  Chama funcao para gravar informacao de monitoramento do servico //
			//------------------------------------------------------------------//
			cMenssagem := "API para alteracao de status pedido Nimbi Id " + nIdPed
			//U_MonitRes("0000AD", 2, , cIdPZB, cMenssagem, .T., "Get de pedidos Nimbi", '', "", "", .F., .F.)

			//-----------------------------------------
			//Retorno com sucesso de envio Json
			//-----------------------------------------
			ConOut("PUT: " + oRest:GetResult())
		Else
			ConOut("PUT: " + oRest:GetLastError())
		EndIf


	EndIf




Return()
