#INCLUDE "PROTHEUS.CH"
#INCLUDE "CNTA300.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} VOGATU02
Medicao de Contratos em Lote
@type function
@author B. Vinicius
@since 25/06/2020
@version 1.0
/*/
User Function VOGATU02()

    Private aParamBox := {}

    Private cAliasTMP := GetNextAlias()
    Private oTempTable := ""

    Private cCliDe := ""
    Private cCliAte := ""
    Private cLojaDe := ""
    Private cLojaAte := ""
    Private cContDe := ""
    Private cContAte := ""
    Private dPerDe := ""
    Private dPerAte := ""
    Private cCondPg := ""
    Private nCiclo := 0
    Private nPrazo := 0

    aAdd(aParamBox, {1, "Contrato de"				, CriaVar('CN9_NUMERO',.F.)					,  ,, "CN9"   ,, 60, .F.} )	//2
    aAdd(aParamBox, {1, "Contrato Ate"				, CriaVar('CN9_NUMERO',.F.)					,  ,, "CN9"   ,, 60, .T.} )	//2
    aAdd(aParamBox, {1, "Cliente De"				, CriaVar('CNC_CLIENT',.F.)					,  ,, "SA1"   ,, 60, .F.} )	//2
    aAdd(aParamBox, {1, "Loja De"				, CriaVar('CNC_LOJACL',.F.)					,  ,, ""   ,, 60, .F.} )	//2
    aAdd(aParamBox, {1, "Cliente Ate"				, CriaVar('CNC_CLIENT',.F.)					,  ,, "SA1"   ,, 60, .T.} )	//2
    aAdd(aParamBox, {1, "Loja Ate"				, CriaVar('CNC_LOJACL',.F.)					,  ,, ""   ,, 60, .T.} )	//2
    aAdd(aParamBox, {1, "Competencia(MMAAAA)"				, Space(6),  ,, ""   ,, 60, .T.} )	//2
    aAdd(aParamBox, {1, "Ciclo"				, CriaVar('CN9_XCICLO'),  ,, ""   ,, 60, .F.} )	//2
    aAdd(aParamBox, {1, "Prazo de Envio"				, CriaVar('CN9_XPRENV'), PesqPict("CN9","CN9_XPRENV") ,, ""   ,, 60, .F.} )	//2
    aAdd(aParamBox, {1, "Cond. Pagamento"				, CriaVar('CN9_CONDPG'),  ,, "SE4"   ,, 60, .F.} )	//2


    If ParamBox(aParamBox,'Parâmetros')

        cCliDe := MV_PAR03
        cClIAte := MV_PAR05
        cLojaDe := MV_PAR04
        cLojaAte := MV_PAR06
        cContDe := MV_PAR01
        cContAte := MV_PAR02
        dPerDe := MV_PAR07
        dPerAte := MV_PAR08
        cCondPg := MV_PAR10
        nCiClo := MV_PAR08
        nPrazo := MV_PAR09

        CriaTemp()
        FWMsgRun(, {||  U_LoadATU02() }, 'Selecionando dados', 'Aguarde...')

        oMark:= FWMarkBrowse():New()
        oMark:SetFieldMark( 'OK' )
        oMark:SetAlias(cAliasTMP)
        oMark:SetDescription('Medição de Contratos')
        //    oMark:SetBotFun("10")

        //  oMark:SetSemaphore(.T.)
        oMark:SetAmbiente(.F.) 	// Desabilita a utilização da funcionalidade Ambiente no Browse
        oMark:SetWalkThru(.F.) 	// Desabilita a utilização da funcionalidade Walk-Thru no Browse

        oMark:DisableConfig()
        oMark:DisableReport()
        oMark:SetMenuDef('VOGATU02' )

        oMark:SetColumns(MCFG006TIT("XX_FIL"	 ,"Filial"	       ,03,,0,15,0))
        oMark:SetColumns(MCFG006TIT("XX_NUMCONT"	 ,"Contrato"	,03,,1,15,0))
        oMark:SetColumns(MCFG006TIT("XX_REVISA"	 ,"Revisao"	,03,,1,15,0))
        oMark:SetColumns(MCFG006TIT("XX_DTINIC"	 , RetTitle("CN9_DTINIC")	,03,,0,15,0))
        oMark:SetColumns(MCFG006TIT("XX_DTASSI"	 , RetTitle("CN9_DTASSI"),03,,0,15,0))
        oMark:SetColumns(MCFG006TIT("XX_DTFIM"	 ,RetTitle("CN9_DTFIM"),03,,0,15,0))
        oMark:SetColumns(MCFG006TIT("XX_VIGE"	 , RetTiTle("CN9_VIGE")	,03,,0,15,0))
        oMark:SetColumns(MCFG006TIT("XX_UNVIGE"	 , RetTitle("CN9_UNVIGE"),03,,0,15,0))
        oMark:SetColumns(MCFG006TIT("XX_CONDPG"	 , RetTitle("CN9_CONDPG")	,03,,0,15,0))
        oMark:SetColumns(MCFG006TIT("XX_TPCTO"	 ,RetTitle("CN9_TPCTO")	,03,,0,15,0))
        oMark:SetColumns(MCFG006TIT("REC"	 , "RECNO"	,03,,0,15,0))

        //Ativa tecla detalhes de contratos
        SetKey(VK_F7,{|| FWMsgRun(, {||  U_ATU020CON()() }, 'Selecionando dados', 'Aguarde...') })

        oMark:Activate()

        oTempTable:Delete()

    Else
        MsgInfo('Cancelado pelo usuário.')
    Endif

    //Removendo atalhos
    SetKey(VK_F7,{|| Nil })

Return

//Cria a Tabela temporaria
Static Function CriaTemp()

    Local aCampos := {}

    aAdd( aCampos , {"OK" , "C" , 002 , 0 } )
    aAdd( aCampos , {"XX_FIL" , "C" , TamSx3("CN9_FILIAL")[1] , 0 } )
    aAdd( aCampos , {"XX_NUMCONT" , "C" , TamSx3("CN9_NUMERO")[1] , 0 } )
    aAdd( aCampos , {"XX_REVISA" , "C" , TamSx3("CN9_REVISA")[1] , 0 } )
    aAdd( aCampos , {"XX_DTINIC" , "D" , 8 , 0 } )
    aAdd( aCampos , {"XX_DTASSI" , "D" , 8 , 0 } )
    aAdd( aCampos , {"XX_DTFIM" , "D" , 8 , 0 } )
    aAdd( aCampos , {"XX_VIGE" , "N", TamSx3("CN9_VIGE")[1]  , 0 } )
    aAdd( aCampos , {"XX_UNVIGE" , "C",TamSx3("CN9_UNVIGE")[1] , 0 } )
    aAdd( aCampos , {"XX_CONDPG" , "C" , TamSx3("CN9_CONDPG")[1]  , 0 } )
    aAdd( aCampos , {"XX_TPCTO" , "C" , TamSx3("CN9_TPCTO")[1] , 0  } )
    aAdd( aCampos , {"REC" , "N" , 8 , 0  } )

    //-------------------
    //Criação do objeto
    //-------------------
    oTempTable := FWTemporaryTable():New( cAliasTMP )

    //--------------------------
    //Monta os campos da tabela
    //--------------------------
    oTemptable:SetFields( aCampos )

    //--------------------------
    //Adiciona Indices
    //--------------------------
    oTempTable:AddIndex("INDEX1", {"XX_FIL","XX_NUMCONT"} )

    oTempTable:Create()

Return

//Popula a tabela temporaria
User Function LoadATU02(lParamBox)

    Local cAliasQry := GetNextAlias()
    Local cExp := ""
    Local lContinua := .T.
    Local dAux := RIGHT(dPerDe,4) +  LEFT(dPerDe,2)
    Default lParamBox := .F.

    If lParamBox

        If ParamBox(aParamBox,'Parâmetros')

            cCliDe := MV_PAR03
            cClIAte := MV_PAR05
            cLojaDe := MV_PAR04
            cLojaAte := MV_PAR06
            cContDe := MV_PAR01
            cContAte := MV_PAR02
            dPerDe := MV_PAR07
            dPerAte := MV_PAR08
            cCondPg := MV_PAR10
            nCiclo := MV_PAR08
            nPrazo := MV_PAR09

        Else
            lContinua := .F.
        Endif

    Endif

    If lContinua

        cExp += "%CN9.CN9_SITUAC =  '05' "

        If !Empty(MV_PAR10)
            cExp += " AND CN9_CONDPG =  " + cCondPg
        Endif

        If !Empty(MV_PAR08)
            cExp += " AND CN9_XCICLO = " + nCiclo
        Endif

        If !Empty(MV_PAR09)
            cExp += " AND CN9_XPRENV = " + nPrazo
        Endif

        cExp += "%"

        (cAliasTMP)->(dbGoTop())
        While !(cAliasTMP)->(EOF())

            Reclock( cAliasTMP , .F.)
            dbDelete()
            (cAliasTMP)->(MsUnLock())

            (cAliasTMP)->(dbSkip())

        EndDo

        BeginSQL Alias cAliasQry
    
    SELECT DISTINCT  CN9_FILIAL , CN9_NUMERO , CN9_REVISA , CN9_DTINIC , CN9_DTASSI , CN9_VIGE , CN9_UNVIGE , CN9_DTFIM , CN9_CONDPG , CN9_TPCTO , CN9.R_E_C_N_O_ RECCN9 

    FROM %TABLE:CN9% CN9

    INNER JOIN %TABLE:CNC% CNC

    ON ( CN9_FILIAL = CNC_FILIAL AND CN9_NUMERO = CNC_NUMERO  AND CN9_REVISA = CNC_REVISA and CNC.%NotDel% )

     INNER JOIN %TABLE:CNF% CNF

    ON (  CNF.CNF_FILIAL = CN9.CN9_FILIAL AND CNF.CNF_CONTRA = CN9.CN9_NUMERO  AND CNF.CNF_REVISA = CN9.CN9_REVISA  and CNF.%NotDel%  ) 

    INNER JOIN %TABLE:CNA% CNA 

    ON ( CNF.CNF_FILIAL = CNA.CNA_FILIAL AND CNF.CNF_NUMERO = CNA.CNA_CRONOG AND CNF.CNF_CONTRA = CNA.CNA_CONTRA  AND CNF.CNF_REVISA = CNA.CNA_REVISA and CNA.%NotDel% 
    
    AND  CNF_NUMPLA = CNA_NUMERO  ) 

    WHERE

    CN9_NUMERO BETWEEN  %Exp:cContDe%  AND %Exp:cContAte%

    AND CNC_CLIENT BETWEEN  %Exp:cCliDe% AND %Exp:cCliAte%

    AND CNC_LOJACL BETWEEN  %Exp:cLojaDe% AND %Exp:cLojaAte%

    AND LEFT(CNF.CNF_PRUMED,6) = %Exp:dAux%  

    AND %Exp:cExp%
    
    AND CN9_ESPCTR = '2'

    AND CN9.D_E_L_E_T_ = ''

    AND CNF_SALDO > 0 

    AND CNC.D_E_L_E_T_ = ''

    AND CN9_SITUAC  = '05'

    ORDER BY CN9_FILIAL , CN9_NUMERO

        EndSQL

        While !(cAliasQry)->(EOF())

            Reclock( cAliasTMP , .T. )

            OK := Space(2)
            XX_FIL := (cAliasQry)->CN9_FILIAL
            XX_NUMCONT := (cAliasQry)->CN9_NUMERO
            XX_DTINIC := Stod((cAliasQry)->CN9_DTINIC)
            XX_DTFIM := Stod((cAliasQry)->CN9_DTFIM)
            XX_DTASSI := Stod((cAliasQry)->CN9_DTFIM)
            XX_VIGE := (cAliasQry)->CN9_VIGE
            XX_UNVIGE := (cAliasQry)->CN9_UNVIGE
            XX_CONDPG := (cAliasQry)->CN9_CONDPG
            XX_TPCTO := (cAliasQry)->CN9_TPCTO
            XX_REVISA := (cAliasQry)->CN9_REVISA
            REC := (cAliasQry)->RECCN9

            (cAliasTMP)->(MsUnLock())

            (cAliasQrY)->(dbSkip())

        EndDo

        (cAliasTMP)->(dbGoTop())

        (cAliasQry)->(dbCloseArea())

    EndIf

Return

//Rotina responsavel por fazer as medicoes
User Function ATU02MED()

    Local cArqTrb := GetNextAlias()
    Local aContratos := {}
    Local aRegs := {}
    Local cMarca 	:= oMark:Mark()
    Local oHash  := Nil
    Local xValue  := ""
    Local cNum := ""
    Local aCab := {}
    Local aItem := {}
    Local cContratos := ""
    Local cDados := ""
    Local lMedPend := (GetNewPar("MV_MEDPEND","1") == "1")//Parametro que informa se a rotina busca por medicoes pendentes
    Local cQuery := ""
    Local cArqTrb2 := ""
    Local lContinua := .T.
    Local cFilBkp := cFilAnt
    Local dAux :=  RIGHT(dPerDe,4) +  Left(dPerDe,2)

    (cAliasTMP)->(DbEval( {|| IIf( oMark:IsMark(),  cDados += (cAliasTMP)->XX_FIL + (cAliasTMP)->XX_NUMCONT + "/"  ,0) } ) )

    cContratos := '% ' + FormatIN(cDados,"/") + " %"

    // Cria o Objeto de HASH a partir do Array
    //oHash := aToHM(aRegs)

    // SELECIONADO os contratos com vigencia possivel
    BeginSQL Alias cArqTrb

        SELECT * FROM 
        (SELECT DISTINCT CNF.CNF_COMPET,CNF.CNF_CONTRA,CNF.CNF_REVISA,CNA.CNA_NUMERO,CNF.CNF_PARCEL,CN9.CN9_FILIAL,CN9.CN9_NUMERO, 
        (CASE WHEN CNL.CNL_MEDAUT = '0' THEN CN1.CN1_MEDAUT ELSE CNL.CNL_MEDAUT END)  MEDAUT 
        FROM  %Table:CNF%  CNF,  %Table:CNA%  CNA, %Table:CN9% CN9, %Table:CN1% CN1 , %Table:CNL%  CNL WHERE 
        CN9.CN9_SITUAC =  '05' AND 
        CN9_ESPCTR = '2' AND // Apenas venda
        CNF.CNF_NUMERO = CNA.CNA_CRONOG AND 
        CNF.CNF_CONTRA = CNA.CNA_CONTRA AND 
        CNF.CNF_REVISA = CNA.CNA_REVISA AND 
        CNF.CNF_CONTRA = CN9.CN9_NUMERO AND 
        CNF.CNF_REVISA = CN9.CN9_REVISA AND 
        CN9.CN9_TPCTO  = CN1.CN1_CODIGO AND 
        CN9.CN9_FILIAL + CN9.CN9_NUMERO IN %Exp:cContratos% AND
        //CNF.CNF_PRUMED BETWEEN %Exp:dPerDe% AND %Exp:dPerAte% AND 
        LEFT(CNF.CNF_PRUMED,6) = %Exp:dAux%  AND 
        CNF.CNF_SALDO  > 0 AND 
        CNA.CNA_SALDO  > 0 AND 
        CNF.D_E_L_E_T_ = ' ' AND 
        CNA.D_E_L_E_T_ = ' ' AND 
        CN1.D_E_L_E_T_ = ' '
        ) CN9 
        WHERE  MEDAUT = '1' 
        
    EndSQL

    // Valida regras igual fonte padrao

    While !(cArqTrb)->(EOF())

        CN9->(DbSetOrder(1))
        CN9->(dbSeek(xFilial("CN9")+(cArqTrb)->CN9_NUMERO+CnGetRevVg((cArqTrb)->CN9_NUMERO),.T.))

        /*If AllTrim(CN9->CN9_SITUAC) == '09'
            (cArqTrb)->(DbSkip())
            Loop
    EndIf*/

        //Valida se mediçao já foi gerada
    BeginSQL Alias "CNDTMP"
				SELECT CND.CND_NUMMED
				FROM 	%Table:CND% CND
				WHERE	CND.CND_FILIAL = %xFilial:CND% AND CND.CND_CONTRA = %Exp:(cArqTrb)->CN9_NUMERO% AND CND.CND_NUMERO = %Exp:(cArqTrb)->CNA_NUMERO% AND
						CND.CND_PARCEL = %Exp:(cArqTrb)->CNF_PARCEL% AND CND.%NotDel% and CND.CND_REVISA = %Exp:(cArqTrb)->CNF_REVISA%  
    EndSQL

    If !CNDTMP->(EOF())
        CNDTMP->(dbCloseArea())
        (cArqTrb)->(dbSkip())
        Loop
    EndIf

    cFilAnt := (cArqTrb)->CN9_FILIAL

    aCab := {}
    cNum := CriaVar("CND_NUMMED")
    aAdd(aCab,{"CND_CONTRA",(cArqTrb)->CNF_CONTRA,NIL})
    aAdd(aCab,{"CND_REVISA",(cArqTrb)->CNF_REVISA,NIL})
    aAdd(aCab,{"CND_COMPET",(cArqTrb)->CNF_COMPET,NIL})
    aAdd(aCab,{"CND_NUMERO",(cArqTrb)->CNA_NUMERO,NIL})
    aAdd(aCab,{"CND_NUMMED",cNum,NIL})
    aAdd(aCab,{"CND_PARCEL",(cArqTrb)->CNF_PARCEL,NIL})

    lMsErroAuto := .F.

    CNTA120(aCab,aItem,3,.F.)

    If !lMsErroAuto
        //MostraErro()
        // lContinua := .F.
    Else
        MostraErro()
        cOldMed := aCab[5,2]
        If lMedPend
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Quando houver erro na inclusao pesquisa medicoes  ³
            //³ verificando se existe algum registro nao encerrado³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            cArqTrb2	:= CriaTrab( nil, .F. )
            cQuery := "SELECT CND.CND_NUMMED,CND.CND_COMPET,CND.CND_NUMERO FROM "+ RetSQLName("CND") +" CND WHERE "
            cQuery += "CND.CND_FILIAL = '"+ xFilial("CND") +"' AND "
            cQuery += "CND.CND_CONTRA = '"+ (cArqTrb)->CNF_CONTRA +"' AND "
            cQuery += "CND.CND_REVISA = '"+ (cArqTrb)->CNF_REVISA +"' AND "
            cQuery += "CND.CND_COMPET = '"+ (cArqTrb)->CNF_COMPET +"' AND "
            cQuery += "CND.CND_DTFIM  = '        ' AND "
            cQuery += "CND.D_E_L_E_T_ = ' '"

            cQuery := ChangeQuery( cQuery )

            dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cArqTrb2, .T., .T. )

            If !(cArqTrb2)->(Eof())
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Substitui medicao para encerramento               ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                aCab[3,2] := (cArqTrb2)->CND_COMPET
                aCab[4,2] := (cArqTrb2)->CND_NUMERO
                aCab[5,2] := (cArqTrb2)->CND_NUMMED
                lContinua := .T.
                lMsErroAuto:= .F.
            Else
                lContinua := .F.
            EndIf

            (cArqTrb2)->(dbCloseArea())
        Else
            lContinua := .F.
        EndIf

    EndIf

    If lContinua
                /*If lJob
                    ConOut(STR0010 + aCab[5,2])
    Else
                    IncProc(STR0010 + aCab[5,2])
    EndIf*/

                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Executa rotina automatica para encerrar as medicoes ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                CNTA120(aCab,aItem,6,.F.)
    If !lMsErroAuto
                    
    Else
                   MostraErro()
    EndIf
EndIf


        (cArqTrb)->(dbSkip())

        CNDTMP->(dbCloseArea())

EndDo

    (cArqTrb)->(dbCloseArea())

    MsgInfo('Medição processada.')

    FWMsgRun(, {||  U_LoadATU02() }, 'Selecionando dados', 'Aguarde...')
    
    cFilAnt := cFilBkp

Return

// MONTA OPCOES DE MENU
Static Function MenuDef()

    Local aRotina := {}

    aAdd(aRotina,{'Medir', 'FWMsgRun(, {|| U_ATU02MED() }, "Processando", "Processando a rotina...")'	, 0, 1, 0, .F. })
    aAdd(aRotina,{'Atualizar Filtro', 'FWMsgRun(, {|| U_LoadATU02(.T.) }, "Processando", "Processando a rotina...")'	, 0, 3, 0, .F. })
    aAdd(aRotina,{'Consulta Valores', 'FWMsgRun(, {|| U_ATU020CON() }, "Processando", "Processando a rotina...")'	, 0, 1, 0, .F. })

Return aRotina

//Função para criar as colunas do grid
Static Function MCFG006TIT(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)
    Local aColumn
    Local bData 	:= {||}
    Default nAlign 	:= 1
    Default nSize 	:= 20
    Default nDecimal:= 0
    Default nArrData:= 0

    If nArrData > 0
        bData := &("{||" + cCampo +"}") //&("{||oBrowse:DataArray[oBrowse:At(),"+STR(nArrData)+"]}")
        //bData := &cCampo+("{||" + cCampo +"}") //&amp;("{||oBrowse:DataArray[oBrowse:At(),"+STR(nArrData)+"]}")
    EndIf

    /* Array da coluna
    [n][01] Título da coluna
    [n][02] Code-Block de carga dos dados
    [n][03] Tipo de dados
    [n][04] Máscara
    [n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
    [n][06] Tamanho
    [n][07] Decimal
    [n][08] Indica se permite a edição
    [n][09] Code-Block de validação da coluna após a edição
    [n][10] Indica se exibe imagem
    [n][11] Code-Block de execução do duplo clique
    [n][12] Variável a ser utilizada na edição (ReadVar)
    [n][13] Code-Block de execução do clique no header
    [n][14] Indica se a coluna está deletada
    [n][15] Indica se a coluna será exibida nos detalhes do Browse
    [n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
    */
    aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}

Return {aColumn}

//Monta tela para consultar informacoes
User Function ATU020CON()

    Local nVlrTotal := 0
    Local nTotContr := 0
    Local oDlg
    Local oSay1
    Local oSay2
    Local oSay3
    Local oSay4
    Local oFont14   := TFont():New("Arial Black",,18,,.F.,,,,,.F.,.F.)
    Local oFont14N   := TFont():New("Arial Black",,18,,.T.,,,,,.F.,.F.)

    (cAliasTMP)->(dbGoTop())
    While !(cAliasTMP)->(EOF())

        If oMark:IsMark()
            nVlrTotal += ValMed() //Valor da medicacao
            nTotContr++ //Soma contratos
        Endif
        (cAliasTMP)->(dbSkip())
    EndDo

    (cAliasTMP)->(dbGoTop())

    //Montagem da tela
    DEFINE MSDIALOG oDlg TITLE "Dados Contratos" FROM 000, 000  TO 150, 300 COLORS 0, 16777215 PIXEL

    @ 010, 003 SAY oSay1 PROMPT "Valor Total" SIZE 095, 067 OF oDlg COLORS 0, 16777215 FONT oFont14 PIXEL
    @ 010, 50 SAY oSay3 PROMPT Transform( nVlrTotal,"@E 999,999,999.99" ) SIZE 095, 067 OF oDlg COLORS 0, 16777215 FONT oFont14N PIXEL

    @ 036, 002 SAY oSay2 PROMPT "Contratos Selecionados" SIZE 078, 059 OF oDlg COLORS 0, 16777215 FONT  oFont14 PIXEL
    @ 036, 80 SAY oSay4 PROMPT cValToChar(nTotContr) SIZE 078, 059 OF oDlg COLORS 0, 16777215 FONT  oFont14N PIXEL

    ACTIVATE MSDIALOG oDlg

Return


//Busca valor das medicao para aquela competencia
Static Function ValMed()

    Local cAliasQry := GetNextAlias()
    Local aArea := GetArea()

    BeginSQL Alias cAliasQry

    SELECT SUM(CNF_VLPREV) CNF_VLPREV

    FROM %TABLE:CNF% CNF
    
    WHERE CNF_FILIAL = %Exp:(cAliasTmp)->XX_FIL%

    AND CNF_CONTRA = %Exp:(cAliasTMP)->XX_NUMCONT%

    AND CNF_REVISA = %Exp:(cAliasTMP)->XX_REVISA%

    AND CNF_COMPET = %Exp:Left(dPerDe,2) + "/" + Right(dPerDe,4)%

    AND CNF.D_E_L_E_T_ = '' 

    EndSQL

    If !(cAliasQry)->(EOF())
        nRet := (cAliasQry)->CNF_VLPREV
    Endif

    (cAliasQry)->(dbCloseArea())
    RestArea(aArea)

Return nRet
