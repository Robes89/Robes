#Include 'Totvs.ch'

/*/{Protheus.doc} OABFIN03
Envio de títulos para cartório
@author Philip TRIYO
@since 24/03/2021
/*/

User Function OABFIN03()

	Local cAlias := GetNextAlias()
	Local cQuery := ''
	Local lRet 	 := .T.
	Local aTit := {}
	Local aBor := {}
	Local aErroAuto :={}
	Local cErroRet :=""
	Local nCntErr :=0
	Local cBanco := '001'
	Local cAgencia := '05905'
	Local cConta   := '0000310300'
	Local cSituaca := 'H'
	Local cNumBor := ''
	Local lMail   := .T.
	Local cArquivo := ''
	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.
	Private lAutoErrNoFile := .T.
					//Top 9997
	cQuery += "SELECT top 5 E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA,E1_TIPO  FROM " + RetSqlName("SE1") + " SE1 "
	cQuery += "JOIN " RetSqlName("SA1") + " SA1 " + "ON  SA1.A1_COD = SE1.E1_CLIENTE AND SA1.A1_LOJA = SE1.E1_LOJA
	cQuery += "WHERE SE1.E1_SALDO > 0
	cQuery += "AND YEAR(SE1.E1_EMISSAO)  = YEAR(GETDATE()) -1 
	//cQuery += "AND SE1.E1_XCOB <> '1'
	//cQuery += "AND A1_XLIST <> '1'

	If Select(cAlias) > 0
		(cAlias)->(dbCloseArea())
	Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

	//aCriaServ := U_MonitRes("000004", 1, 1 )   
	//cIdPZB 	  := aCriaServ[2]

	While (cAlias)→(!EOF())

		aAdd(aTit,{{"E1_FILIAL"  ,(cAlias)->E1_FILIAL },;
		{"E1_PREFIXO" ,(cAlias)->E1_PREFIXO },;
		{"E1_NUM" 	 ,(cAlias)->E1_NUM },;
		{"E1_PARCELA" ,(cAlias)->E1_PARCELA },;
		{"E1_TIPO" 	 ,(cAlias)->E1_TIPO }})

		(cAlias)→(dbSkip())

	EndDo

	//Informações bacárias para o borderô
	aAdd(aBor, {"AUTBANCO"   , PadR(cBanco   ,TamSX3("A6_COD")[1]) })
	aAdd(aBor, {"AUTAGENCIA" , PadR(cAgencia ,TamSX3("A6_AGENCIA")[1]) })
	aAdd(aBor, {"AUTCONTA"   , PadR(cConta   ,TamSX3("A6_NUMCON")[1]) })
	aAdd(aBor, {"AUTSITUACA" , PadR(cSituaca ,TamSX3("E1_SITUACA")[1]) })
	aAdd(aBor, {"AUTNUMBOR"  , PadR(cNumBor  ,TamSX3("E1_NUMBOR")[1]) }) // Caso não seja passado o número será obtido o próximo pelo padrão do sistema

	MSExecAuto({|a, b| FINA060(a, b)}, 3,{aBor,aTit})

	If lMsErroAuto

		cStrErro := ""

		aErros 	:= GetAutoGRLog() // retorna o erro encontrado no execauto.
		nErro   := Ascan(aErros, {|x| "INVALIDO" $ alltrim(Upper(x))  } )

		If nErro > 0
			cStrErro += aErros[ nErro ]
		Else
			For nErro := 1 To Len( aErros )

				cStrErro += ( aErros[ nErro ] + cEnt )

			Next nErro

		EndIf

		cStrErro := Alltrim(cStrErro)

		Conout(cStrErro)

	Else
		cArquivo := OABExCar(aTit)
		lMail := EnvMail(cArquivo)
	

	EndIf

Return lRet

Static Function GeraExcel()

	Local lRet := .T.

Return lRet

Static Function EnvMail()

	Local lRet := .T.

Return lRet
