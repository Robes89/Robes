#include "totvs.ch"

user function grvEnder()

	local nRegs		:= 0
	Local aParam1	:= {}
	Local aParam2	:= {}
	Local aAreaAtu	:= GetArea()
	Local aAreaSBE	:= SBE->(GetArea())

	Private nOpc		:= 0	
	
	aAdd( aParam1, { 2, "Tipo NF", 1, {"Dev./Benef.","Normal"}, 50, ".T.", .T. })
	
	If Parambox( aParam1, "Tipo da NF" )
	
		nOpc := MV_PAR01
		If nOpc == 1
			aAdd( aParam2, { 1, "Cliente", CriaVar("A1_COD", .F.), PesqPict("SA1","A1_COD"), "ExistCpo('SA1')", "SA1", ".T.", 50, .T. } )
			aAdd( aParam2, { 1, "Loja", CriaVar("A1_LOJA", .F.), PesqPict("SA1","A1_LOJA"), 'ExistCpo("SA1")', "SA1", ".T.", 30, .T. } )
		Elseif nOpc == 2
			aAdd( aParam2, { 1, "Fornecedor", CriaVar("A2_COD", .F.), PesqPict("SA2","A2_COD"), 'ExistCpo("SA2")', "SA2", ".T.", 50, .T. } )
			aAdd( aParam2, { 1, "Loja", CriaVar("A2_LOJA", .F.), PesqPict("SA2","A2_LOJA"), 'ExistCpo("SA2")', "SA2", ".T.", 30, .T. } )
		Endif
		
		aAdd( aParam2, { 1, "Endereço", CriaVar("BE_LOCALIZ", .F.), PesqPict("SBE","BE_LOCALIZ"), 'ExistCpo("SBE",,9)', "SBE", ".T.", 60, .T. } )
		
		RestArea(aAreaSBE)
		
		If Parambox( aParam2, "Parâmetros" )
			fExecQry(@nRegs)
			if nRegs > 0
				processa({|| fProc(nRegs)}, "Processando...")
			else
				Alert("Não existem produtos a serem endereçados. Verifique!")
			endIf
		Endif
	Endif
	
	RestArea(aAreaAtu)
	
return

static function fExecQry(nRegs)

	local nIntDAQTDORI	:= tamSX3("DA_QTDORI"	)[01]
	local nDecDAQTDORI	:= tamSX3("DA_QTDORI"	)[02]
	local nIntDASALDO	:= tamSX3("DA_SALDO"	)[01]
	local nDecDASALDO	:= tamSX3("DA_SALDO"	)[02]
	Local cTipoNF		:= ""
	Local cCliFor		:= ""
	Local cLoja			:= ""
	
	If nOpc == 1 // Devolucao / Beneficiamento
		cTipoNF := "%'B','D'%"
	Elseif nOpc == 2 // Normal
		cTipoNF := "%'N'%"
	Endif
	
	cCliFor := "%'" + MV_PAR01 + "'%"
	cLoja 	:= "%'" + MV_PAR02 + "'%"

	BeginSql Alias "TSDA"
		Column DA_QTDORI	as Numeric(nIntDAQTDORI,	nDecDAQTDORI)
		Column DA_SALDO		as Numeric(nIntDASALDO,		nDecDASALDO	)
		Column DA_DATA		as Date

		%noParser%

		SELECT
		DA_PRODUTO, DA_QTDORI, DA_SALDO, DA_DATA, DA_LOTECTL, DA_NUMLOTE, DA_LOCAL,
		DA_DOC, DA_SERIE, DA_CLIFOR, DA_LOJA, DA_TIPONF, DA_ORIGEM, DA_NUMSEQ, SDA.R_E_C_N_O_ X
		FROM
		%Table:SDA% SDA
		WHERE
		DA_FILIAL	= %xFilial:SDA%		AND
		DA_SALDO	> 0					AND
		DA_ORIGEM	= 'SD1'				AND
		DA_TIPONF	IN (%exp:cTipoNF%)	AND
		DA_CLIFOR	= %exp:cCliFor%     AND
		DA_LOJA		= %exp:cLoja%       AND
		SDA.%NotDel%
		ORDER BY
		DA_PRODUTO, DA_LOCAL, DA_NUMSEQ, DA_DOC, DA_SERIE, DA_CLIFOR, DA_LOJA
	EndSql

	if TSDA->(!eof())
		count to nRegs
		TSDA->(dbGoTop())
	endIf

return

static function fProc(nRegs)
	
	local nCont			:= 0
	local nPerc			:= 0
	local aCab			:= {}
	local aItens		:= {}
	local aItemTmp		:= {}
	Local cEnd			:= ""

	private lMsErroAuto	:= .f.
	
	cEnd := Alltrim(MV_PAR03)

	ProcRegua(nRegs)

	do while TSDA->(!eof())
		nCont ++

		nPerc := nCont * 100 / nRegs
		IncProc("Processando registro: " + cValToChar(nCont) + " - Processado: " + transform(nPerc, "@E 999.99 %"))

		aCab	:= {}
		aItens	:= {}
			
		aAdd(aCab, 		{"DA_PRODUTO",		TSDA->DA_PRODUTO,		nil})
		aAdd(aCab, 		{"DA_QTDORI",		TSDA->DA_QTDORI,		nil})
		aAdd(aCab, 		{"DA_SALDO",		TSDA->DA_SALDO,			nil})
		aAdd(aCab, 		{"DA_DATA",			TSDA->DA_DATA,			nil})
		aAdd(aCab, 		{"DA_LOTECTL",		TSDA->DA_LOTECTL,		nil})
		aAdd(aCab, 		{"DA_NUMLOTE",		TSDA->DA_NUMLOTE,		nil})
		aAdd(aCab, 		{"DA_LOCAL",		TSDA->DA_LOCAL,			nil})
		aAdd(aCab, 		{"DA_DOC",			TSDA->DA_DOC,			nil})
		aAdd(aCab, 		{"DA_SERIE",		TSDA->DA_SERIE,			nil})
		aAdd(aCab, 		{"DA_CLIFOR",		TSDA->DA_CLIFOR,		nil})
		aAdd(aCab, 		{"DA_LOJA",			TSDA->DA_LOJA,			nil})
		aAdd(aCab, 		{"DA_TIPONF",		TSDA->DA_TIPONF,		nil})
		aAdd(aCab, 		{"DA_ORIGEM",		TSDA->DA_ORIGEM,		nil})
		aAdd(aCab, 		{"DA_NUMSEQ",		TSDA->DA_NUMSEQ,		nil})
		aAdd(aCab, 		{"INDEX",			1,						nil})
			
		aItemTmp := {}
		aAdd(aItemTmp,	{"DB_ITEM",			"0001",					nil})
		aAdd(aItemTmp,	{"DB_ESTORNO",		"N",					nil})
		aAdd(aItemTmp,	{"DB_PRODUTO",		TSDA->DA_PRODUTO,		nil})
		aAdd(aItemTmp,	{"DB_LOCAL",		TSDA->DA_LOCAL,			nil})
//		aAdd(aItemTmp,	{"DB_LOCALIZ",		"AA001",				nil})
		aAdd(aItemTmp,	{"DB_LOCALIZ",		cEnd,				nil})
		aAdd(aItemTmp,	{"DB_DOC",			TSDA->DA_DOC,			nil})
		aAdd(aItemTmp,	{"DB_SERIE",		TSDA->DA_SERIE,			nil})
		aAdd(aItemTmp,	{"DB_CLIFOR",		TSDA->DA_CLIFOR,		nil})
		aAdd(aItemTmp,	{"DB_LOJA",			TSDA->DA_LOJA,			nil})
		aAdd(aItemTmp,	{"DB_ORIGEM",		"SD1",					nil})
		aAdd(aItemTmp,	{"DB_QUANT",		TSDA->DA_SALDO,			nil})
		aAdd(aItemTmp,	{"DB_DATA",			dDataBase,				nil})
		aAdd(aItemTmp,	{"DB_LOTECTL",		TSDA->DA_LOTECTL,		nil})
		aAdd(aItemTmp,	{"DB_NUMLOTE",		TSDA->DA_NUMLOTE,		nil})
		aAdd(aItemTmp,	{"DB_NUMSEQ",		TSDA->DA_NUMSEQ,		nil})

		aAdd(aItens, aItemTmp)

		if Len(aCab) > 0 .and. Len(aItens) > 0
			SDA->(dbGoTo(TSDA->X))
			lMsErroAuto := .f.
			Mata265(aCab, aItens, 3)
				
			if lMsErroAuto
				MostraErro()
			endIf
		endIf
        
		TSDA->(dbSkip())
	endDo

	TSDA->(dbCloseArea())

return
