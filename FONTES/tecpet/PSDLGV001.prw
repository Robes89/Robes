#INCLUDE 'PSDLGV001.CH'
#INCLUDE 'FIVEWIN.CH'
#INCLUDE 'APVT100.CH'



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ DLGV001  ³ Autor ³ Alex Egydio           ³ Data ³ 18.09.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Identifica as funcoes do operador logado na radio frequencia³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ADVPL16                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Geverico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function PSDLGV001()
Local aTelaAnt := {}
Local cSeekDCI := ''
Local nX    := 0
Local nKey     := 0
Local cHelice  := ''
Local cHora    := ''
Local cAmPm    := STR0001  //'am'
Local cClock   := ''
Local lRadioF  := (SuperGetMV('MV_RADIOF', .F., 'N')=='S')
Local lSleep   := (SuperGetMV('MV_RFSLEEP', .F., 0)>0)
Local lSleeping   := .F.
Local nTimeIni := 0
Local nIdle    := 0
Local nIdleWake   := SuperGetMV('MV_RFIDLEW', .F., 1000) //-- Intervalo de tempo em MILISEGUNDOS em que o sistema ficara em PAUSA no modo ACORDADO (Default=1000)
Local nIdleSleep:= SuperGetMV('MV_RFIDLES', .F., 5000) //-- Intervalo de tempo em MILISEGUNDOS em que o sistema ficara em PAUSA no modo HIBERNANDO (Default=5000)
Local nTimeSleep:= (SuperGetMV('MV_RFSLEEP', .F., 0)*60) //-- Tempo em MINUTOS para que o terminal comece a hibernar (Default=0)
Local nIndSDB  := 0
Local nIndSDB1 := 0
Local nOrdemFunc:= 0
Local cUsuArma := CriaVar('BE_LOCAL')
Local cUsuZona := CriaVar('BE_CODZON')
Local cDescFunc   := '' //-- utilizada para a Descricao da Funcao no SX3
Local cMsgSem  := ''
Local dDataFec := DToS(WmsData())
Local lRetPE   := .F.
//-- Variaveis utilizadas para solicitar o endereco destino no apanhe de quantidades abaixo da norma DLGV030
Local aConfEnd := {}
Local cChave1  := ''
Local cChave2  := ''
Local nTipoConv   := SuperGetMV('MV_TPCONVO', .F., 1) //-- 1=Por Atividade/2=Por Tarefa
//-- Variaveis para solicitar dispositivo de movimentacao
Local cDispMov := ''
Local cEstDMov := ''
Local lCriaSDB := .F.

Private cStatExec := SuperGetMV('MV_RFSTEXE', .F., '1') //-- DB_STATUS indincando Atividade Executada
Private cStatProb := SuperGetMV('MV_RFSTPRO', .F., '2') //-- DB_STATUS indincando Atividade com Problemas
Private cStatInte := SuperGetMV('MV_RFSTINT', .F., '3') //-- DB_STATUS indincando Atividade Interrompida
Private cStatAExe := SuperGetMV('MV_RFSTAEX', .F., '4') //-- DB_STATUS indincando Atividade A Executar
Private cStatAuto := SuperGetMV('MV_RFSTAUT', .F., 'A') //-- DB_STATUS indincando Atividade Automatica
Private cStatManu := SuperGetMV('MV_RFSTMAN', .F., 'M') //-- DB_STATUS indincando Atividade Manual
Private cReinAuto := IIf(FindFunction('TMSChkVer') .And. TMSChkVer('11','R7'),SuperGetMV('MV_REINAUT', .F., 'N'),'N') //-- Indica se permite convocar atividade com problemas/ Interrompida
Private lReinAuto := .F.
Private lAbandona := .F.
Private aFuncoesWMS := {}
Private INCLUI    := .F. //-- utilizada para a Descricao da Funcao no SX3
Private aColetor  := {}
Private cFunExe   := ''
Private nWmsMTea  := SuperGetMv('MV_WMSMTEA',.F.,0) //Permite selecionar multiplas tarefas: 0=Nenhum;1=Apanhe;2=Enderecar;3=Ambos
Private cRegAnt      := '' //grava registro anterior: SDB->DB_DOC+SDB->DB_SERIE+SDB->DB_CLIFOR+SDB->DB_LOJA
Private nRecnoAnt := 0

   //SX3->(DbSetOrder(2))
   //If SX3->(DbSeek('DCI_DESFUN', .F.)) //-- Pesquisa a Descricao da Funcao, no SX3
     // cDescFunc := AllTrim(SX3->X3_RELACAO) //-- Assim pode-se utilizar qq outro arquivo (ex.:SX5) para se cadastrar funcoes
   //EndIf
   //SX3->(DbSetOrder(1))
   GetSx3Cache( 'DCI_DESFUN' ,"X3_RELACAO")

   //-- Pesquisa quais funcoes o usuario exerce
   DbSelectArea('DCD')
   DbSetOrder(1) //-- DCD_FILIAL+DCD_CODFUN
   If MsSeek(xFilial('DCD')+__cUserID, .F.)
      If DCD->DCD_STATUS == '3' //-- Recusro humano ausente
         VtAlert(STR0002 + AllTrim(CUSERNAME) + STR0046, STR0004, .T.)  //'Usuario '###' informado como recurso humano ausente.'###'Atencao'
         Return Nil
      EndIf             
   Else
      VtAlert(STR0002 + AllTrim(CUSERNAME) + STR0047, STR0004, .T.)  //'Usuario '###' não cadastrado como recurso humano.'###'Atencao'
      Return Nil
   EndIf
   DCD->(DbCloseArea())
   
   //-- Pesquisa quais funcoes o usuario exerce
   DbSelectArea('DCI')
   DbSetOrder(1) //-- DCI_FILIAL+DCI_CODFUN+STR(DCI_ORDFUN,2)+DCI_FUNCAO
   If MsSeek(cSeekDCI:=xFilial('DCI')+__cUserID, .F.)
      Do While !Eof() .And. DCI_FILIAL+DCI_CODFUN==cSeekDCI .And. !Empty(DCI_FUNCAO)
         nOrdemFunc ++
         AAdd(aFuncoesWMS, {nOrdemFunc, DCI->DCI_FUNCAO, &cDescFunc})
         DbSkip()
      EndDo
   EndIf 
   DCI->(DbCloseArea())
   
   If Len(aFuncoesWMS) == 0
      VtAlert(STR0002 + AllTrim(CUSERNAME) + STR0003, STR0004, .T.)  //'Usuario '###' sem Funcoes Cadastradas...'###'Atencao'
      Return Nil
   EndIf

   If SuperGetMV('MV_RFINFAZ', .F., 'S')=='S'
      //-- Solicita que o usuario informe sua localizacao
      DLVTCabec(STR0005, .F., .F., .T.)   //'Sua Localizacao?'
      @ 02, 00 VTSay PadR(STR0006, VTMaxCol())  //'Armazem'
      @ 03, 00 VTGet cUsuArma Valid DlgVldArm(cUsuArma)
      @ 05, 00 VTSay PadR(STR0007, VTMaxCol())  //'Zona de Armazenagem'
      @ 06, 00 VTGet cUsuZona Valid DlgVldZon(cUsuZona) F3 'DC4'
      VTRead
      If VTLastKey() == 27
         Return Nil
      EndIf
   EndIf
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Atualiza a coluna "Rotina" do VTMONITOR ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cMsgSem := STR0040+' '+If(Empty(cUsuArma), '??', Alltrim(cUsuArma))+' ' //'A'
   cMsgSem += STR0041+' '+If(Empty(cUsuZona), '??????', Alltrim(cUsuZona))+' ' //'Z'
   cMsgSem += STR0042 //'AGUARDANDO...'
   VTAtuSem('SIGAACD', cMsgSem)
      
   If !AjustaSIX(@nIndSDB)
      Return Nil
   EndIf
   
   If !DlgV001Six(@nIndSDB1)
      Return Nil
   EndIf
   
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Inicializa variaveis utiliadas no While ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cClock   := 'SIGAWMS'
   cHelice  := ' '
   nTimeIni := Seconds() + nTimeSleep
   nIdle    := nIdleWake
   
   //-- Atribui a Funcao de Funcoes a Combinacao de Teclas <CTRL> + <U>
   VTSetKey(21,{||DispFuncWMS(aFuncoesWMS)},STR0008)  //'Funcoes Atrib.      '
   //-- Atribui a Funcao de DATA & HORA a Combinacao de Teclas <CTRL> + <D>
   VTSetKey(4, {||DLVTClock()}  ,STR0009) //'Data/Hora'
   //-- Atribui a Funcao de HELP DE TECLAS a Combinacao de Teclas <CTRL> + <O>
   VTSetKey(15,{||DLVDOcorre()},STR0010)  //'Ocorrencias'
   
   DLVTCabec(AllTrim(CUSERNAME), .F., .F., .T.)
   @ Int(VTMaxRow()/2)  , 00 VtSay STR0011   //'Aguarde Convocacao'
   If !Empty(cUsuArma) .Or. !Empty(cUsuZona)
      @ Int(VTMaxRow()/2)+1, 00 VtSay PadC('('+If(!Empty(cUsuArma), STR0040+' '+AllTrim(cUsuArma), '')+If(!Empty(cUsuArma).And.!Empty(cUsuZona), ' ', '')+If(!Empty(cUsuZona), STR0041+' '+AllTrim(cUsuZona), '')+')', VTMaxCol(), ' ')//'A'#'Z'
   Else
      @ Int(VTMaxRow()/2)+1, 00 VtSay '                  ' //-- Precisa desta linha a mais para correta montagem da tela
   EndIf
   DLVTRodaPe(cClock, .F.)
   
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ >> Looping para Aguarde de Convocacao << ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   DbSelectArea('SDB')
   DbSetOrder(nIndSDB)
   dbGoTop()
   Do While .T.
      Sleep(nIdle)
      VTLoadMsgMonit()
      //-- PE para exibir mensagens no coletor/RF
      If ExistBlock("WMSCONV")
         lRetPE := ExecBlock("WMSCONV",.F.,.F.,{__cUserID})
         lRetPE := (If(ValType(lRetPE)=='L',lRetPE,.F.))
         If lRetPE
            Exit //-- Finaliza convocacao
         EndIf
      EndIf
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Verifica se existe Convocacao para as funcoes do Usuario ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      For nX := 1 To Len(aFuncoesWMS)
         If DLVConvoca(aFuncoesWMS[nX, 2], lRadioF, __cUserID, nIndSDB, cUsuArma, cUsuZona, nIndSDB1, aConfEnd, @cChave1, @cChave2, nTipoConv, @cDispMov, @cEstDMov, @lCriaSDB, dDataFec)
            If lAbandona
               Exit
            EndIf
            nTimeIni := Seconds() + nTimeSleep
            nKey     := VTInkey()
            If lSleeping //-- Sai do modo de hibernacao
               nIdle     := nIdleWake
               lSleeping := .F.
               VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
            EndIf
            If lCriaSDB
               //-- Mantenho a mesma funcao do operador com o objetivo de refazer o select da funcao dlvconvoca.
               //-- O SDB foi desmembrado e esse novo registro devera ser convocado.
               nX -= 1
            Else
               //-- Somente processar a proxima funcao RH nao encontrado atividades.
               //-- caso contrario reinicia primeira funcao RH.
               nX := 0
            EndIf
         EndIf
         If (nKey:=VTInkey()) == 27
            Exit
         EndIf
      Next nX
   
      If lAbandona
         Exit
      EndIf
   
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Tratamento da Hibernacao ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      If lSleep
         If !(nKey==0) //-- Reinicializa o contador se alguma tecla for pressionada
            nTimeIni := Seconds() + nTimeSleep
         EndIf
         If !lSleeping .And. (Seconds() > nTimeIni)
            VTAlert(,STR0012, .T., 1000, 3)  //'Hibernando...'
            nIdle     := nIdleSleep
            lSleeping := .T.
            aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
            VTClear()
         ElseIf lSleeping .And. (nTimeIni >= Seconds())
            VTAlert(, STR0013, .T., 1000, 3) //'Acordando...'
            nIdle     := nIdleWake
            lSleeping := .F.
            VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
         EndIf
      EndIf
   
      If !lSleeping
         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Monta a String para a visualizacao do Relogio no rodape' ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         cHora  := If(Val(Left(Time(), 2))>12.And.Val(Left(Time(), 2))<=23,StrZero(Val(Left(Time(), 2))-12, 2),Left(Time(), 2))
         cAmPm  := If(Val(Left(Time(), 2))>12.And.Val(Left(Time(), 2))<= 23,STR0014,STR0001) //'pm'###'am'
         cClock := cHora + ':' + Subs(Time(), 4, 2) + ' ' + cAmPm
   
         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Monta o String da "helice" ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         cHelice  := If(cHelice=='|','/',If(cHelice=='/','-',If(cHelice=='-','\',If(cHelice=='\','|','|'))))
   
         @ Int(VTMaxRow()/2), 18 VTSay cHelice
         DLVTRodaPe(cClock, .F.)
      EndIf
   
      If (nKey==27)
         If DLVTAviso('DLGV00101',STR0015, {STR0016,STR0017}) == 1   //'Finaliza Aguarde de Convocacao?'###'Sim'###'Nao'
            Exit
         EndIf
         nTimeIni := Seconds() + nTimeSleep
      EndIf
   EndDo
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLVConvoca³ Autor ³ Alex Egydio           ³ Data ³ 18.09.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Convoca o operador logado na radio frequencia para executar³±±
±±³          ³ o Servico x Tarefa x Atividade.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLVConvoca( ExpC1, ExpL1, ExpC2,ExpN1, ExpC3,ExpC4 )       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Funcao exercida pelo operador                      ³±±
±±³          ³ ExpL1 = Utilizacao da radio frequencia                     ³±±
±±³          ³ ExpC2 = Codigo do Recurso Humano                           ³±±
±±³          ³ ExpN1 = Indice utilizado na filtragem                      ³±±
±±³          ³ ExpC3 = Codigo do Armazem                                  ³±±
±±³          ³ ExpC4 = Codigo da Zona de Armazenagem                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DLGV001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DLVConvoca(cFuncao, lRadioF, cRecHum, nIndSDB, cUsuArma, cUsuZona, nIndSDB1, aConfEnd, cChave1, cChave2, nTipoConv, cDispMov, cEstDMov, lCriaSDB, dDataFec)
Local aAreaAnt    := GetArea()
Local aAreaSDB    := SDB->(GetArea())
Local aAreaSDB1      := {}
Local aAreaSBE    := {}
Local aAreaDC5    := {}
Local aAreaDC6    := {}
Local aTelaAnt    := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local aRetPE      := {}
Local cStatRF     := '1'
Local cSeekDC5    := ''
Local lRet        := .F.
Local lConvoca    := .F.
Local lAltStatus  := .T.
Local cAliasNew      := GetNextAlias()
Local cQuery      := ''
Local cBranco1    := Space(Len(DC5->DC5_FUNEXE))
Local cBranco2    := Space(Len(SDB->DB_RECHUM))
Local cRadioF     := ''
Local cDscTar     := ''
Local cDscAtv     := ''
Local cArmSBE     := ''
Local cTipoServ      := '3'
Local lPertenceZ  := .F.
Local cMsgSem     := ''
Local lCarga      := .T.
Local lRetPE      := .T.
Local aRetRegra      := {}
Local xRet        := Nil
Local lWmsQuebra  := ExistBlock("WMSQUEBRA")
Local lNaoConv    := SuperGetMV("MV_WMSNREG", .F., .F.)
Local lWmsSaldo   := .T.
Local cNumero     := ''
Local cFuncoes    := ''
Local i
//-- Variaveis para solicitar dispositivo de movimentacao
Local lDispMov    := .F.
Default cUsuArma  := ''
Default cUsuZona  := ''
Default nIndSDB1  := 8
Default aConfEnd  := {}

Private aParam150 := {}
Private cErro     := ''
Private lExec150  := .F.
Private lOcorre      := .F.
Private lRetAtiv  := .F.
Private lWMSDRMake   := .F. //-- Indica se a funcao executada eh RDMake
Private lWMSRDStat   := (SuperGetMV('MV_WMSRDST', .F., 'S')=='S') //-- Indica se o STATUS sera alterado pelo WMS quando forem executadas funcoes RDMake
Private aParConv  := {cFuncao, lRadioF, cRecHum, nIndSDB, cUsuArma, cUsuZona, nIndSDB1, aConfEnd, cChave1, cChave2, nTipoConv, cDispMov, cEstDMov, lCriaSDB, dDataFec}

DbSelectArea('SDB')
DbSetOrder(nIndSDB1)
If IIf(cReinAuto == 'N',!MsSeek(xFilial('SDB')+cStatAExe),!MsSeek(xFilial('SDB')+cStatProb) .And. !MsSeek(xFilial('SDB')+cStatInte) .And. !MsSeek(xFilial('SDB')+cStatAExe))
   RestArea(aAreaSDB)
   RestArea(aAreaAnt)
   Return lRet
EndIf

aAreaSBE := SBE->(GetArea())
aAreaDC5 := DC5->(GetArea())
aAreaDC6 := DC6->(GetArea())
lCriaSDB := .F.

//carrega funcoes
If !Empty(cFunExe) .And. nWmsMTea <> 0 
   cFuncoes := FuncaoExec(cFunExe)
EndIf
cQuery := "SELECT CASE"
cQuery +=           " WHEN SDB.DB_STATUS IN ('"+cStatProb+"','"+cStatInte+"') THEN 0"
cQuery +=           " WHEN (SDB.DB_STATUS NOT IN ('"+cStatProb+"','"+cStatInte+"') AND SDB.DB_RECHUM = '"+cRecHum+"') THEN 1"
cQuery +=           " WHEN (SDB.DB_STATUS NOT IN ('"+cStatProb+"','"+cStatInte+"') AND SDB.DB_RECHUM = '"+cBranco2+"') THEN 2"
cQuery +=        " ELSE 99 "
cQuery +=        " END AS ORDWMS,"
cQuery +=        " SDB.R_E_C_N_O_ RECSDB,"
cQuery +=       " (SELECT DC5.R_E_C_N_O_ FROM " + RetSqlName('DC5') + " DC5"
cQuery +=         " WHERE DC5.DC5_FILIAL = '"+xFilial("DC5")+"'"
cQuery +=           " AND DC5.DC5_SERVIC = SDB.DB_SERVIC "
cQuery +=           " AND DC5.DC5_TAREFA = SDB.DB_TAREFA "
cQuery +=           " AND DC5.DC5_ORDEM = SDB.DB_ORDTARE "
If Empty(cFuncoes)
   cQuery +=           " AND DC5.DC5_FUNEXE <> '"+cFuncoes+"'"
Else
   cQuery +=           " AND DC5.DC5_FUNEXE IN ('"+cFuncoes+"')"
EndIf 
cQuery +=           " AND DC5.D_E_L_E_T_ = ' ') RECDC5, "
cQuery +=       " (SELECT DC6.R_E_C_N_O_ FROM " + RetSqlName('DC6')+" DC6"
cQuery +=         " WHERE DC6.DC6_FILIAL = '"+xFilial("DC6")+"'"
cQuery +=           " AND DC6.DC6_TAREFA = SDB.DB_TAREFA "
cQuery +=           " AND DC6.DC6_ATIVID = SDB.DB_ATIVID "
cQuery +=           " AND DC6.DC6_ORDEM = SDB.DB_ORDATIV "
cQuery +=           " AND DC6.D_E_L_E_T_ = ' ') RECDC6 "
cQuery +=   " FROM " + RetSqlName('SDB')+" SDB "
cQuery +=  " WHERE SDB.DB_FILIAL = '"+xFilial("SDB")+"'"

//Verifica a versao e o paramentro que permite reabrir tarefa paralizadas
cQuery += IIf(cReinAuto == 'S'," AND SDB.DB_STATUS IN ('"+cStatProb+"','"+cStatInte+"','"+cStatAExe+"')", " AND SDB.DB_STATUS = '"+cStatAExe+"'" )

cQuery += " AND SDB.DB_ATUEST = 'N'"
cQuery += " AND SDB.DB_ESTORNO <> 'S'"
If nTipoConv <> 2 //-- Convocacao por ATIVIDADE (Default)
   cQuery += " AND SDB.DB_RHFUNC = '"+cFuncao+"'"
EndIf
If !Empty(cUsuArma)
   cQuery += " AND SDB.DB_LOCAL = '"+cUsuArma+"'"
EndIf
cQuery += " AND SDB.DB_DATA   > '"+dDataFec+"'"
If ExistBlock('DLV001WH')
   cQuery += ExecBlock('DLV001WH',.F.,.F.,{cRecHum,cFuncao})
EndIf
cQuery += " AND SDB.D_E_L_E_T_ = ' ' "  
cQuery += " ORDER BY ORDWMS, "

If ExistBlock('DLV001ORD')
   cQuery += ExecBlock('DLV001ORD', .F., .F., {nIndSDB1})
Else
   cQuery += SqlOrder(SDB->(IndexKey(nIndSDB1))) //DB_FILIAL+DB_STATUS+DB_PRIORI+DB_CARGA+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_ITEM+DB_SERVIC+DB_ORDTARE+DB_ORDATIV
EndIf
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)

While (cAliasNew)->(!Eof())
   //-- Abandona a Verificacao da Convocacao
   If VTLastKey() == 27
      lAbandona := .T.
      Exit     
   EndIf
   cFunExe := ''
   cRadioF := ''

   SDB->(MsGoTo((cAliasNew)->RECSDB))
   If Empty((cAliasNew)->RECDC5)
      (cAliasNew)->(DbSkip())
      Loop
   EndIf
   //verifica se o registro do SDB ja foi executado pelo processo de multi-tarefas
   nReg := aScan(aColetor,{|x|x[1] == (cAliasNew)->RECSDB })
   If nReg > 0
      (cAliasNew)->(DbSkip())
      Loop
   EndIf
   
   //-- Posiciona cadastro de Servicos x Tarefas
   DC5->(MsGoTo((cAliasNew)->RECDC5))
   //SX5->(DbSetOrder(1))
   //SX5->(MsSeek(xFilial('SX5')+'L6'+DC5->DC5_FUNEXE))
   //cFunExe := AllTrim(Upper(SX5->(X5Descri())))
   cFunExe := AllTrim(Upper(FwGetSX5("L6",DC5->DC5_FUNEXE)[04]))
   //-- Posiciona cadastro de Tarefas x Atividades
   DC6->(MsGoTo((cAliasNew)->RECDC6))
   cRadioF := DC6->DC6_RADIOF

   //-- Nao deve convocar as o.s.wms de expedicao e embalagem, pois se trata de um processo manual e sera
   //-- considerado pelo programa WMSA360
   If SB5->(FieldPos('B5_SERVEMB'))>0
      SB5->(DbSetOrder(1))
      If SB5->(MsSeek(xFilial('SB5')+SDB->DB_PRODUTO)) .And. !Empty(SB5->B5_SERVEMB)
         If SDB->DB_SERVIC==SB5->B5_SERVEMB
            (cAliasNew)->(DbSkip())
            Loop
         EndIf
      EndIf
   EndIf
   //-- Ignora Servicos jah atribuidos a Outros Usuarios
   If !Empty(SDB->DB_RECHUM) .And. SDB->DB_RECHUM<>cRecHum
      (cAliasNew)->(DbSkip())
      Loop
   EndIf

   //Requisito 1281 valido somente a partir da versao 12
   If GetRpoRelease() >= '12.0' .And. GetVersao(.f.) >= '12' 
      //Finaliza separacao do mesmo pedido quando a regra de convocacao for por documento exclusivo
      If 'DLAPANHE' $ Upper(cFunExe) .And. If(!Empty(cRegAnt),DLGV001DOC(cRegAnt,.F.),.F.)
         If cRegAnt <> SDB->DB_CARGA+SDB->DB_DOC+SDB->DB_CLIFOR+SDB->DB_LOJA    
            (cAliasNew)->(DbSkip())
            Loop
         EndIf
      EndIf
      cRegAnt  := SDB->DB_CARGA+SDB->DB_DOC+SDB->DB_CLIFOR+SDB->DB_LOJA
      nRecnoAnt   := SDB->(Recno())
   
      //-- Verifica se permiti reiniciar tarefas, e questiona uma unica vez na secao se deseja reiniciar
      If cReinAuto == 'S' .AND. (SDB->DB_STATUS == cStatProb .OR. SDB->DB_STATUS == cStatInte) .AND. !lReinAuto 
         If If(!Empty(cRegAnt),!DLGV001DOC(cRegAnt,.T.),.T.)
            If !DLVTAviso('DLGV00111',STR0045, {STR0016,STR0017}) == 1  //'Existe tarefa anterior pendente. Reiniciar?'###'Sim'###'Nao'
               lReinAuto   := .T. //-- Para não perguntar novamente quando solicionado que não quer reiniciar
               cRegAnt  := ''
               (cAliasNew)->(DbSkip())
               Loop
            EndIf
         Else
            lReinAuto := .F.
         EndIf 
      Else
         //-- Ignora atividades atribuidas a Outros Usuarios
         If SDB->DB_STATUS<>cStatAExe 
            cRegAnt  := ''
            (cAliasNew)->(DbSkip())
            Loop
         EndIf
      EndIf
   Else
      //-- Verifica se permiti reiniciar tarefas, e questiona uma unica vez na secao se deseja reiniciar
      If cReinAuto == 'S' .AND. (SDB->DB_STATUS == cStatProb .OR. SDB->DB_STATUS == cStatInte) .AND. !lReinAuto
         If !DLVTAviso('DLGV00111',STR0045, {STR0016,STR0017}) == 1  //'Existe tarefa anterior pendente. Reiniciar?'###'Sim'###'Nao'
            lReinAuto := .T. //-- Para não perguntar novamente quando solicionado que não quer reiniciar
            (cAliasNew)->(DbSkip())
            Loop
         EndIf
      Else
         //-- Ignora atividades atribuidas a Outros Usuarios
         If SDB->DB_STATUS<>cStatAExe
   
            (cAliasNew)->(DbSkip())
            Loop
         EndIf
      EndIf
   EndIf 
   //-- Pesquisa descricao da Tarefa e Atividade
   //SX5->(DbSetOrder(1))
   //SX5->(MsSeek(xFilial('SX5')+'L2'+SDB->DB_TAREFA))
   //cDscTar := AllTrim(SX5->(X5Descri()))
   //SX5->(MsSeek(xFilial('SX5')+'L3'+SDB->DB_ATIVID))
   //cDscAtv := AllTrim(SX5->(X5Descri()))
   
   cDscTar := AllTrim(FwGetSX5("L2",SDB->DB_TAREFA)[04])
   cDscAtv := AllTrim(FwGetSX5("L3",SDB->DB_ATIVID)[04])
   
   //-- Ponto de Entrada Antes da Confirmacao da Convocacao
   If ExistBlock('DLVACONV')
      ExecBlock('DLVACONV', .F., .F., {cRecHum, cFuncao, SDB->(Recno())})
   EndIf 
   //-- Regra para a convocacao dos Servicos x Tarefas x Atividades
   If ExistBlock('DLGV001A')
      lConvoca := ExecBlock('DLGV001A', .F., .F.,{cRecHum,cFuncao,SDB->DB_SERVIC,SDB->DB_TAREFA,SDB->DB_ATIVID,SDB->DB_ORDATIV,SDB->DB_DOC,lConvoca})
   Else
      lConvoca := .F.
      If AllTrim(SDB->DB_RHFUNC)==AllTrim(cFuncao)
         If !Empty(SDB->DB_TAREFA) .And. !Empty(SDB->DB_ATIVID)
            lConvoca := DLVExecAnt(nIndSDB,nTipoConv,cFunExe,dDataFec,cRecHum)
         EndIf
      EndIf
   EndIf
   //-- Ponto de Entrada Antes da Confirmacao da Convocacao para verificar saldo endereco origem.
   If ExistBlock('DLGV001B')
      aRetPE:=ExecBlock('DLGV001B', .F., .F.,{cRecHum,cFuncao,SDB->DB_SERVIC,SDB->DB_TAREFA,SDB->DB_ATIVID,SDB->DB_ORDATIV,SDB->DB_DOC,lConvoca,cFunExe})
      If ValType(aRetPE) == 'A' .And. !Empty(aRetPE) .And. ValType(aRetPE[1])=='L'
         lConvoca:=aRetPE[1]
         If Len(aRetPE)>1
            lWmsSaldo := aRetPE[2]
         EndIf
      EndIf
   EndIf
   If lConvoca
      aRetRegra := {}
      If Empty(SDB->DB_RECHUM)
         cNumero := Left(SDB->DB_DOC,Len(SD7->D7_NUMERO))
         //-- Movimentacoes de CQ
         SD7->(DbSetOrder(3))
         If SD7->(MsSeek(xFilial('SD7')+SDB->DB_PRODUTO+SDB->DB_NUMSEQ+cNumero))
            cArmSBE := SD7->D7_LOCAL
         Else
            cArmSBE := SDB->DB_LOCAL
         EndIf
         //-- Verifica se ha regras para convocacao
         If WmsRegra('1',cArmSBE,cRecHum,SDB->DB_SERVIC,SDB->DB_TAREFA,SDB->DB_ATIVID,SDB->DB_LOCALIZ,SDB->DB_ESTFIS,SDB->DB_ENDDES,SDB->DB_ESTDES,aRetRegra)
            //-- Analisa se convocao ou nao
            If !WmsRegra('2',,cRecHum,SDB->DB_SERVIC,SDB->DB_TAREFA,SDB->DB_ATIVID,,,,,aRetRegra,,SDB->DB_CARGA)
               (cAliasNew)->(DbSkip())
               Loop
            EndIf
         Else
            //-- Convocar para esta atividade somente se encontrar regra definida para o operador.
            If lNaoConv 
               (cAliasNew)->(DbSkip())
               Loop
            EndIf
            //-- Apesar de o operador(A) nao ter regra definida, preciso analisar se outro operador(B) reservou a rua,
            //-- se o operador(B) ja reservou a rua o operador(A) nao sera convocado ate que a rua seja liberada.
            If !WmsRegra('3',cArmSBE,cRecHum,SDB->DB_SERVIC,SDB->DB_TAREFA,SDB->DB_ATIVID,SDB->DB_LOCALIZ,SDB->DB_ESTFIS,SDB->DB_ENDDES,SDB->DB_ESTDES)
               Exit
            EndIf
            //-- Ignora a Zona de Armazenagem diferente da escolhida na convocacao
            If !Empty(cUsuZona)
               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
               //³ Verifica o Tipo de Servico (1-Entrada/2-Saida/3-Mov.Interno)          ³
               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
               cTipoServ := DC5->DC5_TIPO
               cNumero   := Left(SDB->DB_DOC,Len(SD7->D7_NUMERO))
               //-- Movimentacoes de CQ
               SD7->(DbSetOrder(3))
               If SD7->(MsSeek(xFilial('SD7')+SDB->DB_PRODUTO+SDB->DB_NUMSEQ+cNumero))
                  cArmSBE := SD7->D7_LOCAL
               Else
                  cArmSBE := SDB->DB_LOCAL
               EndIf

               SBE->(DbSetOrder(7)) //-- BE_FILIAL+BE_LOCAL+BE_LOCALIZ+BE_ESTFIS
               lPertenceZ := .F.
               If cTipoServ $'2ú3' //-- Saidas ou Mov. Internos: Considera a Zona referente ao Endereco/Zona de ORIGEM
                  If SBE->(MSSeek(xFilial('SBE')+cArmSBE+SDB->DB_LOCALIZ+SDB->DB_ESTFIS, .F.))
                     lPertenceZ := (SBE->BE_CODZON==cUsuZona)
                  EndIf
               EndIf
               If !lPertenceZ
                  If cTipoServ $'1ú3' //-- Entradas ou Mov. Internos: Considera a Zona referente ao Endereco/Zona de DESTINO
                     If SBE->(MSSeek(xFilial('SBE')+cArmSBE+SDB->DB_ENDDES+SDB->DB_ESTDES, .F.))
                        lPertenceZ := (SBE->BE_CODZON==cUsuZona)
                     EndIf
                  EndIf
               EndIf
               If !lPertenceZ
                  (cAliasNew)->(DbSkip())
                  Loop
               EndIf
            EndIf
         EndIf
      EndIf
      If SDB->(SimpleLock()) .And. IIF(cReinAuto == 'N',SDB->DB_STATUS==cStatAExe .And. (Empty(SDB->DB_RECHUM) .Or. SDB->DB_RECHUM==cRecHum),(SDB->DB_STATUS==cStatProb .OR. SDB->DB_STATUS==cStatInte .OR. SDB->DB_STATUS==cStatAExe) .And. (Empty(SDB->DB_RECHUM) .Or. SDB->DB_RECHUM==cRecHum)) // Verifica se conseguiu travar registro
         // -- Verifica se data do Protheus esta diferente da data do sistema.
         DLDataAtu()
         //-- Indica se a funcao executada eh RDMake
         lWMSDRMake := Upper(SubStr(cFunExe, 1, 2)) == 'U_'
         //-- Soh altera o Status se NAO for RDMake ou se for RDMake e a alteracao do Status (MV_WMSRDST) ficar a cargo o WMS
         lAltStatus := !lWMSDRMake .Or. (lWMSDRMake.And.lWMSRDStat)
         //-- Verifica se execucao e Automatica ou via Manual
         If !(cRadioF=='1')
            //-- Seta DB_STATUS para Servico Automatico em Execucao
            If lAltStatus
               RecLock('SDB', .F.) // Trava para gravacao
               SDB->DB_RECHUM := cRecHum
               SDB->DB_STATUS := cStatAuto
               SDB->DB_DATA   := dDataBase
               SDB->DB_HRINI  := Time()
               dbCommit()
               //-- Libera o registro do arquivo SDB
               MsUnlock()
            EndIf
         Else
            //-- Avisa sobre a Convocacao
            //-- Seta DB_STATUS para Servico em Execucao
            If lAltStatus
               RecLock('SDB', .F.)  // Trava para gravacao
               SDB->DB_RECHUM := cRecHum
               SDB->DB_STATUS := cStatInte
               SDB->DB_DATA   := dDataBase
               SDB->DB_HRINI  := Time()
               dbCommit()
               //-- Libera o registro do arquivo SDB
               MsUnlock()
            EndIf
            //--            1
            //--  01234567890123456789
            //--0 ___Administrador___
            //--1 Executar Apanhe de
            //--2 produtos -
            //--3 Movimento Vertical
            //--4 
            //--5
            //--6 ___________________
            //--7  Pressione <ENTER>
            While .T.
               VTBeep(3)
               DLVTAviso(AllTrim(CUSERNAME),STR0018+cDscTar+" - "+cDscAtv) //"Executar "
               Exit
            EndDo
         EndIf
         lRet      := (SDB->DB_STATUS==cStatInte .Or. SDB->DB_STATUS==cStatAuto)
         aAreaSDB1 := SDB->(GetArea())
         //-- Ponto de Entrada na Gravacao do Status de Servico Automatico
         If ExistBlock('DLGV001G')
            ExecBlock('DLGV001G', .F., .F.,{cFunExe})
         EndIf
         //-- Dispara a funcao associada ao servico
         If If(lAltStatus, SDB->DB_STATUS == cStatInte, SDB->DB_STATUS == cStatAExe)
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Atualiza a coluna "Rotina" do VTMONITOR ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            cMsgSem := STR0040+' '+If(Empty(cUsuArma), '??', Alltrim(cUsuArma))+' ' //'A'
            cMsgSem += STR0041+' '+If(Empty(cUsuZona), '??????', Alltrim(cUsuZona))+' ' //'Z'
            cMsgSem += Upper(Alltrim(cFunExe))
            VTAtuSem('SIGAACD', cMsgSem)

            //-- Define regras para solicitar o dispositivo de movimentacao
            If Empty(cDispMov) .Or. Empty(cEstDMov)
               lDispMov := .F.
               If ExistBlock('WmsxDMov')
                  lDispMov := ExecBlock('WmsxDMov',.F.,.F.)
                  If Valtype(lDispMov)!='L'
                     lDispMov := .F.
                  EndIf
               EndIf
               If lDispMov
                  //-- Solicita o dispositivo de movimentacao
                  WmsAtzSDB('2',,@cDispMov,@cEstDMov)
               EndIf
            EndIf

            If 'DLCONFEREN' $ Upper(cFunExe) //-- Conferencia de mercadorias
               lRetAtiv := WmsV070(@lAltStatus)
            ElseIf   'DLENDERECA' $ Upper(cFunExe) ;
            .Or.  'DLTRANSFER' $ Upper(cFunExe) ;
            .Or.  'DLCROSSDOC' $ Upper(cFunExe) //-- Recebimento de mercadorias
               lRetAtiv := If(nWmsMTea == 2 .Or. nWmsMTea == 3,DLGV111(@aColetor,@lAltStatus),DlgV080())
            ElseIf   'DLAPANHE'   $ Upper(cFunExe) ;
            .Or.  'DLGXABAST'  $ Upper(cFunExe) //-- Apanhe ou (Re)Abastecimento
               If lWmsSaldo .And. WmsSaldoSBF(SDB->DB_LOCAL,SDB->DB_LOCALIZ,SDB->DB_PRODUTO,SDB->DB_NUMSERI,SDB->DB_LOTECTL,SDB->DB_NUMLOTE,,,,,.T.,'1',.F.) < SDB->DB_QUANT
                  DLAviso(lRadioF, 'DLGV00109', STR0043+' '+SDB->DB_LOCALIZ+' '+STR0044)  //'Saldo no Endereço'###'insuficiente para a retirada!'
                  lAbandona := .T.
               Else
                  lCarga   := WmsCarga(SDB->DB_CARGA)
                  lRetAtiv := If(nWmsMTea == 1 .Or. nWmsMTea == 3,DLGV110(aConfEnd,lCarga,@cDispMov,@cEstDMov,@lCriaSDB,@lAltStatus,@aColetor),DlgV030(aConfEnd,lCarga,@cDispMov,@cEstDMov,@lCriaSDB,@lAltStatus))
               EndIf
            ElseIf !Empty(cFunExe)
               cFunExe  += If(!('('$cFunExe),'()','')
               cFunExe  := StrTran(cFunExe,'"',"'")
               lRetAtiv := &(cFunExe)

               lRetAtiv := If(!(lRetAtiv==NIL).And.ValType(lRetAtiv)=='L', lRetAtiv, .T.)
            ElseIf Empty(cFunExe)
               lRetAtiv := .T.
            EndIf
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Atualiza a coluna "Rotina" do VTMONITOR ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            cMsgSem := STR0040+' '+If(Empty(cUsuArma), '??', Alltrim(cUsuArma))+' ' //'A'
            cMsgSem += STR0041+' '+If(Empty(cUsuZona), '??????', Alltrim(cUsuZona))+' ' //'Z'
            cMsgSem += STR0042 //'AGUARDANDO...'
            VTAtuSem("SIGAACD", cMsgSem)
         ElseIf SDB->DB_STATUS==cStatAuto
            VTAlert(STR0019+cDscTar+' - '+cDscAtv, AllTrim(CUSERNAME), .T., 3000, 3)   //'Execucao Automatica '
            If (cStatRF:=DLUltiTar(SDB->DB_TAREFA, SDB->DB_ORDATIV)) == '2' //-- So executa Atividades que atualizem Estoque
               lExec150      := .F.
               aParam150     := Array(32)
               aParam150[01] := SDB->DB_PRODUTO //-- Produto
               aParam150[02] := SDB->DB_LOCAL      //-- Almoxarifado
               aParam150[03] := SDB->DB_DOC     //-- Documento
               aParam150[04] := SDB->DB_SERIE      //-- Serie
               aParam150[05] := SDB->DB_NUMSEQ     //-- Sequencial
               aParam150[06] := SDB->DB_QUANT      //-- Saldo do produto em estoque
               aParam150[07] := SDB->DB_DATA    //-- Data da Movimentacao
               aParam150[08] := Time()          //-- Hora da Movimentacao
               aParam150[09] := SDB->DB_SERVIC     //-- Servico
               aParam150[10] := SDB->DB_TAREFA     //-- Tarefa
               aParam150[11] := SDB->DB_ATIVID     //-- Atividade
               aParam150[12] := SDB->DB_CLIFOR     //-- Cliente/Fornecedor
               aParam150[13] := SDB->DB_LOJA    //-- Loja
               aParam150[14] := ''              //-- Tipo da Nota Fiscal
               aParam150[15] := SDB->DB_ITEM    //-- Item da Nota Fiscal
               aParam150[16] := SDB->DB_TM         //-- Tipo de Movimentacao
               aParam150[17] := SDB->DB_ORIGEM     //-- Origem de Movimentacao
               aParam150[18] := SDB->DB_LOTECTL //-- Lote
               aParam150[19] := SDB->DB_NUMLOTE //-- Sub-Lote
               aParam150[20] := SDB->DB_LOCALIZ //-- Endereco
               aParam150[21] := SDB->DB_ESTFIS     //-- Estrutura Fisica
               aParam150[22] := 1               //-- Regra de Apanhe (1=LOTE/2=NUMERO DE SERIE/3=DATA)
               aParam150[23] := SDB->DB_CARGA      //-- Carga
               aParam150[24] := SDB->DB_UNITIZ     //-- Nr. do Pallet
               aParam150[25] := SDB->DB_LOCAL      //-- Centro de Distribuicao Destino
               aParam150[26] := SDB->DB_ENDDES     //-- Endereco Destino
               aParam150[27] := SDB->DB_ESTDES     //-- Estrutura Fisica Destino
               aParam150[28] := SDB->DB_ORDTARE //-- Ordem da Tarefa
               aParam150[29] := SDB->DB_ORDATIV //-- Ordem da Atividade
               aParam150[30] := SDB->DB_RHFUNC     //-- Funcao do Recurso Humano
               aParam150[31] := SDB->DB_RECFIS     //-- Recurso Fisico
               If SDB->(FieldPos('DB_IDDCF'))>0
                  aParam150[32] := SDB->DB_IDDCF   //-- Identificador do DCF
               EndIf
               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
               //³ Executa as Tarefas (SX5 - Tab L6) Referentes ao Servico  (DC5)  ou    ³
               //³ Executa as Atividades referentes a Tarefa (DC6)                       ³
               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
               aAreaDC5a := DC5->(GetArea())
               If '()' $cFunExe
                  cFunExe := StrTran(cFunExe,'()','')
                  cFunExe += '(.T.,"'+cStatRF+'")'
               EndIf
               cFunExe  := StrTran(cFunExe,'"',"'")
               lRetAtiv := &(cFunExe)

               lRetAtiv := If(!(lRetAtiv==NIL).And.ValType(lRetAtiv)=='L', lRetAtiv, .T.)
               If lRetAtiv
                  lRetAtiv := lExec150
               EndIf
            EndIf
         EndIf
         // -- Verifica se data do Protheus esta diferente da data do sistema.
         DLDataAtu()
         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Seta DB_STATUS para "Servico Executado" ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         RestArea(aAreaSDB1)
         If lAltStatus
            Begin Transaction
            Reclock('SDB', .F.)  // Trava para gravacao
            If !(SDB->DB_STATUS==cStatAuto)
               SDB->DB_STATUS := If(lRetAtiv, cStatExec, cStatProb)
            EndIf
            SDB->DB_RECHUM  := cRecHum
            SDB->DB_DATAFIM := dDataBase
            SDB->DB_HRFIM   := Time()
            If !Empty(cErro) .Or. !lRetAtiv
               cErro := ''
               SDB->DB_ANOMAL := 'S'
            EndIf
            MsUnlock() // Destrava apos gravacao
            End Transaction
         EndIf
         //-- Ponto de Entrada na Gravacao do Status de Servico Executado
         If ExistBlock('DLGV001G')
            ExecBlock('DLGV001G', .F., .F.,{cFunExe})
         EndIf
         MsUnlockAll() // Tira o lock da softlock
         If !Empty(aConfEnd)
            //-- Ponto de Entrada para definir quebra por carga ou documento.
            If lWmsQuebra
               lRetPE := ExecBlock("WMSQUEBRA",.F.,.F.)
               If Valtype(lRetPE)=="L"
                  lCarga := lRetPE
               EndIf
            EndIf
            If lCarga
               //-- Verifica se houve quebra de carga
               //-- A T E N C A O : Aqui use o alias SDB->
               cChave1 := SDB->(DB_FILIAL+DB_CARGA+DB_ORDTARE)
               //-- Posiciona na proxima atividade RF.
               (cAliasNew)->(DbSkip())
               SDB->(MsGoTo((cAliasNew)->RECSDB))
               //-- A T E N C A O : Aqui use o alias (cAliasNew)->
               cChave2 := SDB->(DB_FILIAL+DB_CARGA+DB_ORDTARE)
            Else
               //-- Verifica se houve quebra de documento
               //-- A T E N C A O : Aqui use o alias SDB->
               cChave1 := SDB->(DB_FILIAL+DB_DOC+DB_CLIFOR+DB_LOJA+DB_ORDTARE)
               //-- Posiciona na proxima atividade RF.
               (cAliasNew)->(DbSkip())
               SDB->(MsGoTo((cAliasNew)->RECSDB))
               //-- A T E N C A O : Aqui use o alias (cAliasNew)->
               cChave2 := SDB->(DB_FILIAL+DB_DOC+DB_CLIFOR+DB_LOJA+DB_ORDTARE)
            EndIf
            RestArea(aAreaSDB1)
         EndIf
         Exit //-- Se ocorreu convocacao, sair do WHILE e processar a proxima funcao
      Else
         SDB->(MsUnLock())
      EndIf
   EndIf
   //-- Posiciona no Proximo Registro
   (cAliasNew)->(DbSkip())
EndDo
(cAliasNew)->( dbCloseArea() )

If nWmsMTea <> 0
   //quando o apanhe eh interrompido altera o status dos registros que ja haviam sido setados como executado
   If lAbandona .And. Len(aColetor) > 0
      For i:= 1 to Len(aColetor)
         SDB->(dbGoTo(aColetor[i][1]))
         Begin Transaction
            Reclock('SDB', .F.)
            If !(SDB->DB_STATUS==cStatAuto)
               SDB->DB_STATUS := cStatProb
            EndIf
            SDB->DB_DATAFIM := dDataBase
            SDB->DB_HRFIM   := Time()
            SDB->DB_RECHUM  := cRecHum
            MsUnlock() 
         End Transaction
      Next i
      aColetor := {}
      lAbandona   := .F.
   EndIf
EndIf
   
If !Empty(aRetRegra) .And. aRetRegra[9]=='1' .And. !lCriaSDB
   WmsRegra('4',,cRecHum,,,,,,,,aRetRegra,cFuncao,,lRetAtiv)
EndIf
VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
//-- Integracao com o programa DLGV030
//-- Quando apanhe de quantidades abaixo da norma, solicita o endereco de destino se:
//-- O vetor aconfend estiver preenchido e nao houver mais registros no SDB aptos a executar
If (!Empty(aConfEnd) .And. cChave1 <> cChave2 .And. !lCriaSDB)
   DLV030END(aConfEnd)
EndIf
RestArea(aAreaSBE)
RestArea(aAreaDC6)
RestArea(aAreaDC5)
RestArea(aAreaSDB)
RestArea(aAreaAnt)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLVEnderec³ Autor ³ Alex Egydio           ³ Data ³ 18.09.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apresenta o codigo do endereco na tela do coletor de dados ³±±
±±³          ³ respeitando a configuracao do codigo do endereco.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLVEndereco( ExpN1, ExpN2, ExpC1, ExpC2 )                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Numero da Linha                                    ³±±
±±³          ³ ExpN2 = Numero da Coluna                                   ³±±
±±³          ³ ExpC1 = Endereco                                           ³±±
±±³          ³ ExpC2 = Armazem                                            ³±±
±±³          ³ ExpN2 = Nivel Inicial a ser Visualizado                    ³±±
±±³          ³ ExpN3 = Nivel Final a ser Visualizado                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DLGV001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DLVEndereco(nLin, nCol, cEndereco, cArmazem, nNivIni, nNivFim, cCabec)
Local aTelaAnt   := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local aCab       := {''}
Local aSize      := {VTMaxCol()}
Local aAreaAnt   := GetArea()
Local aAreaSBE   := SBE->(GetArea())
Local aAreaDC7   := DC7->(GetArea())
Local aEndereco  := {}
Local aNiveis    := {}
Local nX         := 1
Local nNivAtu    := 1
Local nParNivIni := SuperGetMV('MV_ENDINRF', .F., 0)
Local nParNivFim := SuperGetMV('MV_ENDFIRF', .F., 0)
Local nLenDesc   := 0
Local nLenEnd    := 0
Local cSeekDC7   := ''
Local lCfgEnd    := .F.

Default nLin       := 0
Default nCol       := 0
Default cEndereco  := SDB->DB_LOCALIZ
Default cArmazem   := SDB->DB_LOCAL
Default nNivIni    := 0
Default nNivFim    := 0
Default cCabec     := STR0020 //'Endereco'

If ExistBlock('DVDISPEN')
   cEndereco := ExecBlock('DVDISPEN', .F., .F., {cEndereco})
EndIf

//-- Considera o Parametro MV_ENDINRF
nNivIni := If(nParNivIni>0, nParNivIni, nParNivIni)

//-- Considera o Parametro MV_ENDINRF
nNivFim := If(nParNivFim>0, nParNivFim, nNivFim)

DbSelectArea('DC7')
DbSetOrder(1)

DbSelectArea('SBE')
DbSetOrder(1)
If (lCfgEnd:=(MsSeek(xFilial('SBE')+cArmazem+cEndereco, .F.) .And. !Empty(BE_CODCFG) .And. DC7->(MsSeek(cSeekDC7:=xFilial('DC7')+SBE->BE_CODCFG, .F.))))
   nX      := 1
   nNivAtu := 1
   DbSelectArea('DC7')
   Do While !Eof() .And. cSeekDC7==DC7_FILIAL+DC7_CODCFG
      If ((nNivIni+nNivFim)==0) .Or. ((nNivIni>0.And.nNivFim>0) .And. (nNivAtu>=nNivIni.And.nNivAtu<=nNivFim))
         aAdd(aNiveis, {AllTrim(DC7_DESEND), AllTrim(SubStr(cEndereco, nX, DC7_POSIC))})
      EndIf
      nX      += DC7_POSIC
      nNivAtu ++
      DbSkip()
   EndDo
   nLenDesc := 0
   nLenEnd  := 0
   For nX := 1 to Len(aNiveis)
      nLenEnd := If(Len(aNiveis[nX, 2])>nLenEnd, Len(aNiveis[nX, 2]), nLenEnd)
   Next nX
   nLenDesc := VTMaxCol()-1-nLenEnd
   For nX := 1 to Len(aNiveis)
      aAdd(aEndereco, {PadR(aNiveis[nX, 1], nLenDesc) + ' ' + PadR(aNiveis[nX, 2], nLenEnd)})
   Next nX
EndIf

VTClear()
If lCfgEnd
   aCab := {PadC(cCabec, VTMaxCol(), '_')}
   DLVTRodaPe(, .F.)
   VTaBrowse(nLin, nCol, (VTMaxRow()-2), VTMaxCol(), aCab, aEndereco, aSize)
Else
   @ nLin  , nCol VTSay PadC(cCabec, VTMaxCol(), '_')
   @ nLin+2, nCol VTSay AllTrim(cEndereco)
   DLVTRodaPe()
EndIf

RestArea(aAreaDC7)
RestArea(aAreaSBE)
RestArea(aAreaAnt)
VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)

Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLVStAuto ³ Autor ³ Alex Egydio           ³ Data ³ 18.09.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava status de execucao 'A'utomatica                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLVStAuto( ExpC1, ExpC2, ExpC3 )                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Servico                                  ³±±
±±³          ³ ExpC2 = Ordem da Tarefa registrado no SDB                  ³±±
±±³          ³ ExpC3 = Codigo da Tarefa                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DLGV001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DLVStAuto(cServic,cOrdTare,cTarefa)
Local aAreaAnt := GetArea()
Local aAreaSDB := SDB->(GetArea())
Local cAliasNew   := GetNextAlias()
Local cQuery   := ''
Local dDataFec := DToS(WmsData())

//-- Os registros que originaram movimentacao de estoque terao o status de execucao automatica.
cQuery := " SELECT DB_FILIAL,DB_STATUS,DB_SERVIC,DB_ORDTARE,DB_TAREFA,DB_ORDATIV,R_E_C_N_O_ RECSDB "
cQuery += " FROM"
cQuery += " "+RetSqlName('SDB')+" SDB"
cQuery += " WHERE"
cQuery += " DB_FILIAL       = '"+xFilial("SDB")+"'"
cQuery += " AND DB_STATUS   = '"+cStatAExe+"'"
cQuery += " AND DB_SERVIC   = '"+cServic+"'"
cQuery += " AND DB_ORDTARE  = '"+cOrdTare+"'"
cQuery += " AND DB_TAREFA   = '"+cTarefa+"'"
cQuery += " AND DB_ORDATIV  = 'ZZ' "
cQuery += " AND DB_ESTORNO  = ' ' "
cQuery += " AND DB_DATA    > '"+dDataFec+"'"
cQuery += " AND D_E_L_E_T_  = ' ' "
cQuery += " ORDER BY DB_FILIAL,DB_STATUS,DB_SERVIC,DB_ORDTARE,DB_TAREFA,DB_ORDATIV"
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
(cAliasNew)->(DbGoTop())
// -- Verifica se data do Protheus esta diferente da data do sistema.
DLDataAtu()
DbSelectArea('SDB')
SDB->( DbSetOrder(8) )
While (cAliasNew)->(!Eof())
   SDB->(MsGoTo((cAliasNew)->RECSDB))
   If SDB->(SimpleLock())
      SDB->DB_STATUS    := cStatAuto
      SDB->DB_RECHUM    := __cUserID
      If Empty(SDB->DB_DATA)
         SDB->DB_DATA   := dDataBase
         SDB->DB_HRINI  := Time()
      Else
         SDB->DB_DATAFIM:= dDataBase
         SDB->DB_HRFIM  := Time()
      EndIf
      SDB->(MsUnlock())
   EndIf
   (cAliasNew)->(DbSkip())
EndDo
(cAliasNew)->( dbCloseArea() )

RestArea(aAreaSDB)
RestArea(aAreaAnt)
Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLVUnitiz ³ Autor ³ Alex Egydio           ³ Data ³ 18.09.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o resultado da unitizacao da carga                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLVUnitiz( ExpC1 )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Carga                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DLGV001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DLVUnitiz(cCarga)
Local aAreaAnt   := {}
Local aRet       := {}
Local cSeekDBN   := ''

DbSelectArea('DBN')
DbSetOrder(4)
If MsSeek(cSeekDBN:=xFilial('DBN')+cCarga, .F.)
   Do While !Eof() .And. DBN_FILIAL+DBN_CARGA==cSeekDBN
      aAdd(aRet,{DBN_UNITIZ, DBN_CODPRO, DBN_QTDE, DBN_PESO})
      DbSkip()
   EndDo
EndIf

RestArea(aAreaAnt)
Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³DLUltiTar ³ Autor ³ Fernando Joly Siquini ³ Data ³23.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se e a Ultima Atividade da Tarefa                 ³±±
±±³          ³ (Utiliza a Ordem)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLUltiTar(ExpC1, ExpC2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Tarefa Atual                             ³±±
±±³          ³ ExpC2 = Sequencia da Atividade Atual                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DLGV001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DLUltiTar(cTarefa, cOrdem)
Local aAreaAnt   := GetArea()
Local aAreaDC6   := DC6->(GetArea())
Local cRetorno   := '1'

DbSelectArea('DC6')
DbSetOrder(1)
If MsSeek(xFilial('DC6')+cTarefa+cOrdem, .F.)
   DbSkip()
   If Eof() .Or. !(DC6_TAREFA==cTarefa)
      cRetorno := '2'
   EndIf
EndIf

RestArea(aAreaDC6)
RestArea(aAreaAnt)
Return cRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLVDigErro³ Autor ³ Alex Egydio           ³ Data ³20.09.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela de digitacao do codigo da divergencia                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLVDigErro( ExpN1, ExpN2 )                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1  = Numero da linha                                   ³±±
±±³          ³ ExpN2  = Numero da coluna                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DLVDigErro(nLin,nCol)
Local cErro      := Space(TamSX3('DB_ANOMAL')[1])

//-- Evia mensagem para o servidor
Conout(repl('-',80))
Conout(STR0021+Space(5)+AllTrim(Tabela('L2',SDB->DB_TAREFA,.F.))) //'Erro:   '
Conout(STR0022+Space(5)+CUSERNAME)  //'Usuario:'
Conout(STR0023+Space(5)+DtoC(dDataBase))  //'Data:   '
Conout(STR0024+Space(5)+Time())  //'Hora:   '
//Conout("Verifique o arquivo "+NomeAutoLog())
Conout(repl('-',80))
VTBeep(3)

CB4->(DbSetOrder(1))
@ nLin, nCol VTSay PadR(STR0025, VTColMax()) //'Digite a Divergencia'
nLin++
Do While Empty(cErro)
   @ nLin, nCol VTGet cErro Valid !Empty( cErro ) .And. DLVVldErro( cErro ) F3 'CB4'
   VTRead
   If CB4->(!MsSeek( xFilial('CB4') + cErro ))
      cErro := Space( TamSX3('DB_ANOMAL')[1] )
   EndIf
EndDo
nLin ++
Return cErro

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DlgVldArm ºAutor  ³ Manutencao/N3-DL   º Data ³  19/03/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao do Armazem digitado no coletor de dados           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³PROGRAMA DE COLETOR DE DADOS APDL                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DlgVldArm(cUsuArma)
Local lRet   :=.T.
Local lRetPE :=.T.

//-- Permite efetuar validacoes especificas na digitacao do armazem
If ExistBlock("WMSVLARM")
   lRetPE := ExecBlock("WMSVLARM",.F.,.F.,{cUsuArma})
   If Valtype(lRetPE) == "L"
      lRet := lRetPE
   EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DlgVldZon ºAutor  ³Rodrigo A Sartorio  º Data ³  09/10/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida a zona digitada no coletor de dados                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³PROGRAMA DE COLETOR DE DADOS APDL                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DlgVldZon(cUsuZona)
Local lRet :=.T.
If !Empty(cUsuZona) .And. !ExistCpo('DC4', cUsuZona)
   lRet:=.F.
EndIf
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³AjustaSIX ºAutor  ³Fernando J. Siquini º Data ³  11/05/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se o seguinte indice do SDB esta criado:           º±±
±±º          ³DB_FILIAL+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_IDOPERA      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AjustaSIX(nIndSDB)
Local aAreaAnt := GetArea()
Local aAreaSIX := SIX->(GetArea())
Local lRet     := .F.
Local cNewOrd  := ''

DbSelectArea('SIX')
SIX->(DbSetOrder(1))
If SIX->(DbSeek('SDB', .F.))
   Do While SIX->(!Eof() .And. INDICE == 'SDB')
      If AllTrim(Upper(SIX->CHAVE)) == 'DB_FILIAL+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_IDOPERA'
         cNewOrd := SIX->ORDEM
         lRet    := .T.
         Exit
      EndIf
      SIX->(DbSkip())
   EndDo
   If !lRet
      SIX->(DbSkip(-1))
      //-- Para criar a nova Ordem soma 1 a Ultima Ordem ja Existente
      cNewOrd := Soma1(ORDEM)
      RecLock('SIX', .T.)
      Replace INDICE    With 'SDB'
      Replace ORDEM     With cNewOrd
      Replace CHAVE     With 'DB_FILIAL+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_IDOPERA'
      Replace DESCRICAO With 'FILIAL+DOCUMENTO+SERIE+CLIENTE/FORNECEDOR+LOJA+ID. DE OPERACAO'
      Replace DESCSPA   With 'FILIAL+DOCUMENTO+SERIE+CLIENTE/FORNECEDOR+LOJA+ID. DE OPERACAO'
      Replace DESCENG   With 'FILIAL+DOCUMENTO+SERIE+CLIENTE/FORNECEDOR+LOJA+ID. DE OPERACAO'
      Replace PROPRI    With 'S'
      Replace F3        With 'XXX+XXX+DL2+XXX+XXX'
      Replace NICKNAME  With ''
      MsUnlock()
      //-- Abre os arquivos novamente com o novo indice no SDB
      DbSelectArea('SDB')
      If MA280FLock('SDB')
         DbSelectArea('SDB')
         dbCloseArea()
         If !ChkFile('SDB')
            DLVTAviso('DLGV00102',STR0026, {STR0027}) //'Erro de Abertura no SDB'###'Ok'
         Else
            lRet := .T.
         EndIf
      Else
         DLVTAviso('DLGV00103',STR0028, {STR0027}) //'Nao foi possivel abrir o arquivo SDB exclusivo.'###'Ok'
      EndIf
   EndIf
EndIf

If lRet
   If IsAlpha(cNewOrd)
      nIndSDB := (Asc(cNewOrd)-55)
   Else
      nIndSDB := Val(cNewOrd)
   EndIf
   DbSelectArea('SDB')
   DbSetOrder(nIndSDB)
   lRet := AllTrim(Upper(IndexKey()))=='DB_FILIAL+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_IDOPERA'
EndIf

If !lRet
   DLVTAviso('DLGV00104',STR0029+'"DB_FILIAL+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_IDOPERA" no SDB.', {'Ok'})   //'Criar a chave de indice '
EndIf

RestArea(aAreaSIX)
RestArea(aAreaAnt)
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³DLVDOcorreºAutor  ³Fernando J. Siquini º Data ³  04/12/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Permite a digitacao de ocorrencias via VT100                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DLVDOcorre()
Local aTelaAnt := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local cOcorre  :=  CriaVar('DCM_OCORRE', .F.)
Local cNumOcor := ""
Local nAviso   := 0

Do While .T.
   DLVTCabec(AllTrim(CUSERNAME), .F., .F., .T.)
   @ 02, 00 VTSay 'Prod..: ' + SDB->DB_PRODUTO
   @ 03, 00 VTSay 'Doc...: ' + SDB->DB_DOC+' '+SDB->DB_SERIE
   @ 04, 00 VTSay 'S/T/A.: ' + SDB->DB_SERVIC+'/'+SDB->DB_TAREFA+'/'+SDB->DB_ATIVID
   @ 05, 00 VTSay PadR(STR0030, VTMaxCol())  //'Ocorrencia'
   @ 06, 00 VTGet cOcorre Valid DLVValOcor(@cOcorre) F3 'DCM'
   VTRead
   If Empty(cOcorre) .Or. VTLastKey() == 27
      nAviso := DLVTAviso('DLGV00105', STR0031, {STR0032, STR0033, STR0034})  //'Deseja:'###'Redigitar'###'Continuar'###'Abandonar'
      If nAviso == 1 .Or. (nAviso == 2 .And. Empty(cOcorre))
         Loop
      ElseIf nAviso == 3
         Exit
      EndIf
   EndIf
   cNumOcor := GetSX8Num('DCN', 'DCN_NUMERO')
   If __lSX8
      ConfirmSX8()
   EndIf
   RecLock('SDB', .F.)
   SDB->DB_OCORRE:=cOcorre
   SDB->DB_STATUS:='2'
   MsUnlock()
   RecLock('DCN', .T.)
   DCN->DCN_FILIAL      := xFilial('DCN')
   DCN->DCN_NUMERO      := cNumOcor
   DCN->DCN_OCORR    := cOcorre
   DCN->DCN_STATUS      := '1'
   DCN->DCN_DTINI    := dDataBase
   DCN->DCN_HRINI    := Time()
   DCN->DCN_PROD     := SDB->DB_PRODUTO
   DCN->DCN_LOCAL    := SDB->DB_LOCAL
   DCN->DCN_QUANT    := SDB->DB_QUANT
   DCN->DCN_DOC      := SDB->DB_DOC
   DCN->DCN_SERIE    := SDB->DB_SERIE
   DCN->DCN_CLIFOR      := SDB->DB_CLIFOR
   DCN->DCN_LOJA     := SDB->DB_LOJA
   DCN->DCN_ITEM     := SDB->DB_SERIE
   DCN->DCN_LOTECTL  := SDB->DB_LOTECTL
   DCN->DCN_NUMLOT      := SDB->DB_NUMLOTE
   DCN->DCN_ENDER    := SDB->DB_LOCALIZ
   DCN->DCN_NUMSER      := SDB->DB_NUMSERI
   DCN->DCN_NUMSEQ      := ProxNum()
   MsUnlock()
   DLVTAviso('DLGV00106',STR0035, {})  //'Ocorrencia Registrada! Pressione qualquer tecla.'
   lOcorre := .T.
   Exit
EndDo

VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DLGV001   ºAutor  ³Microsiga           º Data ³  12/04/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DLVValOcor(cOcorre)
Local lRet := .T.
If !Empty(cOcorre) .And. !ExistCpo('DCM',cOcorre)
   lRet := .F.
EndIf
If VTLastKey() == 27
   cOcorre := CriaVar('DCM_OCORRE', .F.)
EndIf
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLVExecAnt³ Autor ³ Alex Egydio           ³ Data ³ 18.09.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Analisa se a atividade anterior ja foi executada, se sim   ³±±
±±³          ³ permite ir para a proxima atividade.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLVExecAnt( ExpC1, ExpC2, ExpC3 )                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Indice do SDB a ser utilizado na pesquisa          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DLGV001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DLVExecAnt(nIndSDB,nTipoConv,cFunExe,dDataFec,cRecHum)
Local aAreaAnt := GetArea()
Local aAreaSDB := SDB->(GetArea())
Local cSeekSDB := ''
Local cDocto   := SDB->DB_DOC
Local cSerie   := SDB->DB_SERIE
Local cCliFor  := SDB->DB_CLIFOR
Local cLoja    := SDB->DB_LOJA
Local cIdOpera := SDB->DB_IDOPERA
Local cProduto := SDB->DB_PRODUTO
Local cServic   := SDB->DB_SERVIC
Local cOrdTare  := SDB->DB_ORDTARE
Local cCarga    := SDB->DB_CARGA
Local lCarga    := WmsCarga(SDB->DB_CARGA)
Local lRet     := .F.
Local lRetPE   := .F.
Local lAchou   := .F.
Local nRecOri  := SDB->(Recno())
Local cAliasNew   := GetNextAlias()

Default nIndSDB := 0
Default cRecHum := ""

cSeekSDB := xFilial('SDB')+cDocto+cSerie+cCliFor+cLoja

If nTipoConv == 2 //-- Convocacao por TAREFA
   //--DB_FILIAL,DB_STATUS,DB_PRIORI,DB_CARGA,DB_DOC,DB_SERIE,DB_CLIFOR,DB_LOJA,DB_ITEM,DB_SERVIC,DB_ORDTARE,DB_ORDATIV
   //-- Verifica se eh a primeira tarefa analisando o campo DB_ORDTARE ou a funcao WmsFunExe
   If SDB->(DB_ORDTARE == '01' .And. DB_ORDATIV == '01' .And. DB_ATUEST <> 'S' .And. Empty(DB_ESTORNO))
      lRet := IIf(cReinAuto == 'N',(SDB->DB_STATUS==cStatAExe),(SDB->DB_STATUS==cStatProb .OR. SDB->DB_STATUS==cStatInte .OR. SDB->DB_STATUS==cStatAExe)) //-- Convoca se for a 1a Atividade ainda nao executada
   Else
      cQuery := " SELECT DB_ORDATIV,DB_ATUEST,DB_ESTORNO,DB_STATUS"
      cQuery += " FROM"
      cQuery += " "+RetSqlName('SDB')+" SDB"
      cQuery += " WHERE"
      cQuery += " DB_FILIAL       = '"+xFilial("SDB")+"'"
      cQuery += " AND DB_DOC      = '"+cDocto+"'"
      cQuery += " AND DB_SERIE    = '"+cSerie+"'"
      cQuery += " AND DB_CLIFOR   = '"+cCliFor+"'"
      cQuery += " AND DB_LOJA     = '"+cLoja+"'"
      cQuery += " AND DB_PRODUTO  = '"+cProduto+"'"
      cQuery += " AND DB_ATUEST   = 'N'"
      cQuery += " AND DB_ESTORNO  = ' '"
      cQuery += " AND DB_IDOPERA < '"+cIdopera+"'"
      cQuery += " AND DB_DATA    > '"+dDataFec+"'"
      cQuery += " AND SDB.D_E_L_E_T_ = ' ' "
      cQuery += " ORDER BY DB_FILIAL,DB_STATUS,DB_PRIORI,DB_CARGA,DB_DOC,DB_SERIE,DB_CLIFOR,DB_LOJA,DB_ITEM,DB_SERVIC,DB_ORDTARE,DB_ORDATIV DESC "
      cQuery := ChangeQuery(cQuery)
      DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
      If (cAliasNew)->(!Eof())
         lRet   := ((cAliasNew)->DB_STATUS==cStatExec .Or. (cAliasNew)->DB_STATUS==cStatAuto .Or. (cAliasNew)->DB_STATUS==cStatManu) //-- Convoca se a Atividade anterior ja tiver sido executada
         lAchou := .T.
      Else
         lAchou := .F.
         lRet   := .T.
      EndIf
      (cAliasNew)->(DbCloseArea())
   EndIf
Else
   //-- Convocacao por ATIVIDADE (Default)
   //-- Pesquisa Indice => DB_FILIAL+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_IDOPERA
   If nIndSDB == 0
      AjustaSIX(@nIndSDB)
   EndIf
   //-- 
   DbSelectArea('SDB')
   SDB->(DbSetOrder(nIndSDB))
   If SDB->(MsSeek(cSeekSDB+cIdopera))
      If SDB->(DB_ORDTARE == '01' .And. DB_ORDATIV == '01' .And. DB_ATUEST <> 'S' .And. Empty(DB_ESTORNO))
         lRet := IIf(cReinAuto == 'N',SDB->DB_STATUS==cStatAExe,(SDB->DB_STATUS==cStatProb .OR. SDB->DB_STATUS==cStatInte .OR. SDB->DB_STATUS==cStatAExe)) //-- Convoca se for a 1a Atividade ainda nao executada
      Else
         cAliasNew := GetNextAlias()
         cQuery := " SELECT DB_ORDATIV,DB_ATUEST,DB_ESTORNO,DB_STATUS"
         cQuery += " FROM"
         cQuery += " "+RetSqlName('SDB')+" SDB"
         cQuery += " WHERE"
         cQuery += " DB_FILIAL       = '"+xFilial("SDB")+"'"
         cQuery += " AND DB_DOC      = '"+cDocto+"'"
         cQuery += " AND DB_SERIE    = '"+cSerie+"'"
         cQuery += " AND DB_CLIFOR   = '"+cCliFor+"'"
         cQuery += " AND DB_LOJA     = '"+cLoja+"'"
         cQuery += " AND DB_PRODUTO  = '"+cProduto+"'"
         cQuery += " AND DB_ATUEST   = 'N'"
         cQuery += " AND DB_ESTORNO  = ' '"
         cQuery += " AND DB_IDOPERA < '"+cIdopera+"'"
         cQuery += " AND DB_DATA    > '"+dDataFec+"'"
         cQuery += " AND SDB.D_E_L_E_T_ = ' ' "
         cQuery += " ORDER BY "+SqlOrder(SDB->(IndexKey(nIndSDB)))+" DESC "
         cQuery := ChangeQuery(cQuery)
         DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
         If (cAliasNew)->(!Eof())
            lRet   := IIf(cReinAuto == 'N',((cAliasNew)->DB_STATUS==cStatExec .Or. (cAliasNew)->DB_STATUS==cStatAuto .Or. (cAliasNew)->DB_STATUS==cStatManu),((cAliasNew)->DB_STATUS==cStatProb .Or. (cAliasNew)->DB_STATUS==cStatInte .Or. (cAliasNew)->DB_STATUS==cStatExec .Or. (cAliasNew)->DB_STATUS==cStatAuto .Or. (cAliasNew)->DB_STATUS==cStatManu)) //-- Convoca se a Atividade anterior ja tiver sido executada
            lAchou := .T.
         Else
            lAchou := .F.
            lRet   := .T.
         EndIf
         (cAliasNew)->(DbCloseArea())
      EndIf
      //-- Convocacao somente apos executada todas atividades da TAREFA anterior.
      If lRet .And. nTipoConv == 3
         DbSelectArea('SDB')
         If lCarga
            SDB->(DbSetOrder(14)) //-- DB_FILIAL+DB_CARGA+DB_SEQCAR+DB_SERVIC+DB_TAREFA+DB_ATIVID+DB_ESTORNO
         Else
            SDB->(DbSetOrder(3))  //-- DB_FILIAL+DB_SERVIC+DB_TAREFA+DB_ATIVID
         EndIf
         cAliasNew := GetNextAlias()
         cQuery := " SELECT DB_ORDATIV,DB_ATUEST,DB_ESTORNO,DB_STATUS"
         cQuery += " FROM"
         cQuery += " "+RetSqlName('SDB')+" SDB"
         cQuery += " WHERE"
         cQuery += " DB_FILIAL       = '"+xFilial("SDB")+"'"
         cQuery += " AND DB_SERVIC   = '"+cServic+"'"
         If lCarga
            cQuery += " AND DB_CARGA = '"+cCarga+"'"
         Else
            cQuery += " AND DB_DOC      = '"+cDocto+"'"
            cQuery += " AND DB_CLIFOR   = '"+cCliFor+"'"
            cQuery += " AND DB_LOJA     = '"+cLoja+"'"
         EndIf
         cQuery += " AND DB_ORDTARE  < '"+cOrdTare+"'"
         cQuery += " AND DB_ATUEST   = 'N'"
         cQuery += " AND DB_ESTORNO  = ' '"
         cQuery += " AND DB_STATUS  IN ('"+cStatProb+"','"+cStatInte+"','"+cStatAExe+"')"
         cQuery += " AND DB_DATA     > '"+dDataFec+"'"
         cQuery += " AND SDB.D_E_L_E_T_ = ' ' "
         cQuery += " ORDER BY "+SqlOrder(SDB->(IndexKey(IndexOrd())))
         cQuery := ChangeQuery(cQuery)
         DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
         lRet := (cAliasNew)->(Eof())
         (cAliasNew)->(DbCloseArea())
         RestArea(aAreaSDB)
      EndIf
   EndIf
EndIf
If ExistBlock('DLGVEXAN')
   lRetPE := ExecBlock('DLGVEXAN', .F., .F., {lRet, nRecOri, lAchou, cRecHum})
   If Valtype(lRetPE) == "L"
      lRet := lRetPE
   EndIf
EndIf
RestArea(aAreaSDB)
RestArea(aAreaAnt)
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CHGCONF   ºAutor  ³Fernando J. Siquini º Data ³  01/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relogio com Data e Hora do Sistema                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DLVTClock(lAllwaysOn)
Local aTelaAnt   := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local aSemana    := {'Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab'}
Local aMeses     := {'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'}
Local cAmPm      := STR0001   //'am'
Local cDiaSem    := ''
Local cDia       := ''
Local cMes       := ''
Local cAno       := ''
Local cHora      := ''
Local cMin       := ''
Local cSeg       := ''
Local cString1   := ''
Local cString2   := ''
Local nTimeIni   := Seconds()

Default lAllwaysOn := .F.

DLVTCabec(STR0036, .F., .F., .T.)   //'Data/Hora'
Do While .T.
   cDiaSem := aSemana[Dow(Date())]
   cDia    := StrZero(Day(Date()), 2)
   cMes    := aMeses[Month(Date())]
   cAno    := StrZero(Year(Date()),4)
   cHora   := Left(Time(),2)
   cMin    := Subs(Time(),4,2)
   cSeg    := Right(Time(),2)
   cAmPm   := STR0001   //'am'
   If Val(cHora) > 12 .And. Val(cHora) <= 23
      cHora := StrZero(Val(cHora) - 12,2)
      cAmPm := STR0014  //'pm'
   EndIf
   cString1 := cDiaSem + ' ' + cDia + '/' + cMes + '/' + cAno
   cString2 := cHora + ':' + cMin + ':' + cSeg + ' ' + cAmPm
   @ Int(VTMaxRow()/2)  , 00 VTSay PadC(cString1, VTMaxCol())
   @ Int(VTMaxRow()/2)+1, 00 VTSay PadC(cString2, VTMaxCol())
   DLVTRodaPe(Nil, .F.)
   If VTInkey() == 13 .Or. If(!lAllwaysOn, (Seconds()-nTimeIni)>300, .T.)
      Exit
   EndIf
   Sleep(1000)
EndDo
VTInkey()
VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³DLVTCabec   ³ Autor ³Fernando Joly Siquini³ Data ³29.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Exibe um Cabecalho Padrao de 20 caracteres na Linha ZERO   ³±±
±±³          ³ para a Tarefa a ser executada.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLVTCabec(ExpC1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Titulo do cabecalho (se NIL considera o cCadastro) ³±±
±±³          ³ ExpL1 = Rola a tela anterior para Cima                     ³±±
±±³          ³ ExpL2 = Rola a tela anterior para Baixo                    ³±±
±±³          ³ ExpL3 = Limpa a tela antrerior                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DLGV???                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DLVTCabec(cCabec, lRolaUP, lRolaDW, lClear)
Local cCabecDef  := If(!(Type('cCadastro')=='C'),STR0037,cCadastro)  //'Tarefa'

Default cCabec     := cCabecDef
Default lRolaUP    := .T.
Default lRolaDW    := .F.
Default lClear     := .F.

If lClear
   VTclear() //-- Limpa a tela Anterior
ElseIf lRolaDW
   DLVTRolaDW() //-- Rola a tela Anterior p/Baixo
Else
   DLVTRolaUP() //-- Rola a tela Anterior p/Baixo
EndIf

@ 0,0 VTSay PadC(cCabec, VTMaxCol(), '_')

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³DLVTRodaPe  ³ Autor ³Fernando Joly Siquini³ Data ³29.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Exibe um Rodape Padrao de 20 caracteres nas Linhas CINCO   ³±±
±±³          ³ e SEIS com informacoes ao usuario                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLVTRodaPe(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Conteudo Rodape (NIL considera "Pressione <ENTER>")³±±
±±³          ³ ExpL1 = Espera a digitacao de alguma tecla?                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DLGV???                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DLVTRodaPe(cRodaPe, lWait)

Default cRodaPe    := STR0038 //'Pressione <ENTER>'
Default lWait      := .T.

If VTRow() <= (VTMaxRow()-1)
   @ (VTMaxRow()-1), 00 VTSay Replicate('_', VTMaxCol())
EndIf
If VTRow() <= VTMaxRow()
   @ VTMaxRow(), 00 VTSay PadC(cRodaPe, VTMaxCol())
EndIf
If lWait
   VTInkey(0)
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³DLVTRolaUP  ³ Autor ³Fernando Joly Siquini³ Data ³29.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rola a tela atual para cima                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLVTRolaUP()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DLGV???                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DLVTRolaUP()
Local nX := 0

For nX := 1 to VTMaxRow()
   VTScroll(00, 00, VTMaxRow(), VTMaxCol(), 1)
Next nX

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³DLVTRolaDW  ³ Autor ³Fernando Joly Siquini³ Data ³29.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rola a tela atual para Baixo                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLVTRolaDW()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DLGV???                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DLVTRolaDW()
Local nX := 0

For nX := 1 to VTMaxRow()
   VTScroll(00, 00, VTMaxRow(), VTMaxCol(), -1)
Next nX

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³DLVTAviso   ³ Autor ³Fernando Joly Siquini³ Data ³29.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Exibe um Aviso na Tela                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLVTAviso(ExpC1, ExpC2, ExpA1)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Cabecalho do Aviso (Default = "Atencao")           ³±±
±±³          ³ ExpC2 = Conteudo do Aviso                                  ³±±
±±³          ³ ExpA1 = Array com as Opcoes para Retorno do Aviso - Max 3  ³±±
±±³          ³         (Default = "Pressione <Enter>")                    ³±±
±±³          ³ ExpL1 = Espera a Selecao ou Sai da Rotina                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ A Opcao do Array Escolhida                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DLGV???                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DLVTAviso(cCabec, cMsg, aOpcoes, lWait)
Local aTelaAnt   := VTSave(00, 00, VTMaxRow(),  VTMaxCol())
Local nOpcao     := 1
Local nX         := 0
Local nLineSize  := VTMaxCol()
Local nLines     := Min(MlCount(cMsg, nLineSize),(VTMaxRow()-1)) //-- Deixa 2 linhas para o Aviso Padrao
Local lTerminal := (VTMaxRow()==1)
Default cCabec     := STR0004 //'Atencao'
Default cMsg       := ''
Default aOpcoes    := {}
Default lWait      := .T.

//-- Permite SOMENTE TRES opcoes
If Len(aOpcoes) > 1
   If Len(aOpcoes)>3
      aSize(aOpcoes, 3)
   EndIf
   nLines := Min(MlCount(cMsg, nLineSize),(VTMaxRow()-(Len(aOpcoes)-1))) //-- Deixa as Linhas para as Opcoes
EndIf

VTBeep(2)
If ! lTerminal
   DLVTCabec(cCabec, .F., .F., .T.)
   For nX := 1 to nLines
      @ nX, 00 VTSay MemoLine(cMsg, nLineSize, nX)
   Next nX
   If Len(aOpcoes) > 1
      nOpcao := VTAchoice((VTMaxRow()-2), 00, VTMaxRow(),  VTMaxCol(), aOpcoes)
      VTInkey()
   Else
      nOpcao := 1
      DLVTRodaPe(If(Len(aOpcoes)>0,aOpcoes[1],Nil), lWait)
   EndIf

   If lWait
      VTRestore(00, 00, VTMaxRow(),  VTMaxCol(), aTelaAnt)
   EndIf
Else
   VtClear()
   @ 00,00 VTSay cMsg
   If Len(aOpcoes) > 0
      nOpcao := VTAchoice(01, 00, VTMaxRow(),  VTMaxCol(), aOpcoes)
      VTInkey()
   Else
      nOpcao := 1
      VTInkey(0)
   EndIf
   If lWait
      VTRestore(00, 00, VTMaxRow(),  VTMaxCol(), aTelaAnt)
   EndIf
EndIf
Return nOpcao

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³DLUltiAtiv³ Autor ³ Fernando Joly Siquini ³ Data ³01.11.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se eh a Ultima Atividade da Tarefa                ³±±
±±³          ³ (Nao utiliza a Ordem)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLUltiTar(ExpC1, ExpC2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Tarefa Atual                             ³±±
±±³          ³ ExpC2 = Codigo da Atividade Atual                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DLGV001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DLUltiAtiv(cServico, cTarefa, cAtividade, aEndOri, aEndDest, cOrdAtiv)
Local aAreaAnt  := GetArea()
Local aAreaDC5  := DC5->(GetArea())
Local aAreaDC6  := DC6->(GetArea())
Local lRet      := .T.
Local cSeek     := ''
Local cTipoServ := ''
Local nRecno    := 0

If cOrdAtiv == NIL
   DC6->(DbSetOrder(2)) //DC6_FILIAL+DC6_TAREFA+DC6_ATIVID
   If DC6->(MsSeek(xFilial('DC6')+cTarefa+cAtividade))
      //-- Verifica o Tipo de Servico (1-Entrada/2-Saida/3-Mov.Interno)
      DC5->(DbSetOrder(1)) //DC5_FILIAL+DC5_SERVIC+DC5_ORDEM
      DC5->(MsSeek(xFilial('DC5')+cServico))
      cTipoServ := DC5->DC5_TIPO

      nRecno := DC6->(Recno())
      cSeek  := DC6->DC6_FILIAL+DC6->DC6_TAREFA
      DC6->(DbSetOrder(1)) //DC6_FILIAL+DC6_TAREFA+DC6_ORDEM
      DC6->(dbGoto(nRecno))
      DC6->(DbSkip())

      While DC6->(!Eof() .And. DC6->DC6_FILIAL+DC6->DC6_TAREFA == cSeek)
         If cTipoServ == '3'
            lRet := .F.
            Exit
         Else
            If !DLExceAtiv(cServico, cTarefa, DC6->DC6_ATIVID, aEndOri, aEndDest, cTipoServ )
               lRet := .F.
               Exit
            EndIf
         EndIf
         DC6->(DbSkip())
      EndDo
   EndIf
Else
   cSeek := xFilial('DC6')+cTarefa
   DC6->(DbSetOrder(1))
   If DC6->(MsSeek(xFilial('DC6')+cTarefa+cOrdAtiv))
      //-- Verifica o Tipo de Servico (1-Entrada/2-Saida/3-Mov.Interno)
      DC5->(DbSetOrder(1))
      DC5->(MsSeek(xFilial('DC5')+cServico))
      cTipoServ := DC5->DC5_TIPO

      DC6->(DbSkip())
      While DC6->(!Eof() .And. DC6->DC6_FILIAL+DC6->DC6_TAREFA == cSeek)
         If cTipoServ == '3'
            lRet := .F.
            Exit
         Else
            If !DLExceAtiv(cServico, cTarefa, DC6->DC6_ATIVID, aEndOri, aEndDest, cTipoServ )
               lRet := .F.
               Exit
            EndIf
         EndIf
         DC6->(DbSkip())
      EndDo
   EndIf
EndIf

RestArea(aAreaDC5)
RestArea(aAreaDC6)
RestArea(aAreaAnt)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DLExceAtivºAutor  ³Microsiga           º Data ³  11/01/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se a atividade possui excecao                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DLExceAtiv(cServico, cTarefa, cAtividade, aEndOri, aEndDest, cTipoServ)
Local aAreaAnt   := GetArea()
Local aAreaDCL   := DCL->(GetArea())
Local aAreaSBE   := SBE->(GetArea())
Local lRet       := .F.
Local cLocExce   := ''
Local cEndExce   := ''
Local cEstExce   := ''
Local cSeek      := ''

If cTipoServ == '1' //-- Entradas - Verificar excecoes no Destino
   cLocExce   := aEndDest[1]
   cEndExce   := aEndDest[2]
   cEstExce   := aEndDest[3]
ElseIf cTipoServ == '2' //-- Saidas - Verificar Excecoes na Origem
   cLocExce   := aEndOri[1]
   cEndExce   := aEndOri[2]
   cEstExce   := aEndOri[3]
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existem Excecoes a Atividades para o Endereco ORIGEM      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea('SBE')
DbSetOrder(7)
If MsSeek(xFilial('SBE')+cLocExce+cEndExce+cEstExce, .F.) .And. !Empty(BE_EXCECAO)
   DbSelectArea('DCL')
   DbSetOrder(1)
   If MsSeek(cSeek:=xFilial('DCL')+SBE->BE_EXCECAO, .F.)
      Do While !Eof() .And. cSeek==DCL_FILIAL+DCL_CODIGO
         If DCL_ATIVID == cAtividade
            lRet := .T.
            Exit
         EndIf
         DbSkip()
      EndDo
   EndIf
EndIf
RestArea(aAreaDCL)
RestArea(aAreaSBE)
RestArea(aAreaAnt)
Return lRet
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DlgV001Six| Autor ³ Alex Egydio              ³Data³15.03.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o indice foi criado no SDB                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function DlgV001Six(nIndSDB1)
Local aAreaAnt   := GetArea()
Local aAreaSIX   := SIX->(GetArea())
Local lRet       := .F.
Local cNewOrd    := ""
Local cIndSDB    := "DB_FILIAL+DB_STATUS+DB_PRIORI+DB_CARGA+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_ITEM+DB_SERVIC+DB_ORDTARE+DB_ORDATIV"

SIX->(DbSetOrder(1))
If SIX->(DbSeek("SDB"))
   While SIX->(!Eof() .And. SIX->INDICE == "SDB")
      If AllTrim(Upper(SIX->CHAVE)) == cIndSDB
         cNewOrd := SIX->ORDEM
         lRet    := .T.
         Exit
      EndIf
      SIX->(DbSkip())
   EndDo
EndIf

If lRet
   If IsAlpha(cNewOrd)
      nIndSDB1 := (Asc(cNewOrd)-55)
   Else
      nIndSDB1 := Val(cNewOrd)
   EndIf
   DbSelectArea('SDB')
   DbSetOrder(nIndSDB1)

   lRet := AllTrim(Upper(IndexKey()))==cIndSDB
EndIf

If !lRet
   DLVTAviso('DLGV00107', STR0029+'"'+cIndSDB+'" no SDB.', {'Ok'})   //'Criar a chave de indice '
EndIf

RestArea(aAreaSIX)
RestArea(aAreaAnt)
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DispFuncWMºAutor  ³Microsiga           º Data ³  05/31/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DispFuncWMS(aFuncoesWMS)
Local aCab       := {'N.',STR0008}  //'Funcoes Atrib.      '
Local aSize      := {Len(aCab[1]), Len(aCab[2])}
Local aTelaAnt   := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local aFuncoes   := {}
Local nX         := 0

For nX := 1 to Len(aFuncoesWMS)
   aAdd(aFuncoes, {StrZero(aFuncoesWMS[nX, 1], 2), aFuncoesWMS[nX, 3]})
Next nX

If Len(aFuncoes) > 0
   VTClear()
   For nX := 1 to VTMaxRow()-1
      @ nX, 00 VTSay PadR('  |', VTMaxCol())
   Next nX
   DLVTRodaPe(, .F.)
   VTaBrowse(00, 00, Min(VTMaxRow()-1,Len(aFuncoes)+1), VTMaxCol(), aCab, aFuncoes, aSize)
Else
   DLVTAviso('DLGV00108', STR0039) //'Nenhuma Funcao Cadastrada...'
EndIf

VTRestore(00, 00, VTMaxRow()  , VTMaxCol(), aTelaAnt)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DLDataAtu ºAutor  ³Microsiga           º Data ³  14/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³MV_WMSAtDt = Atualiza data do Protheus com data atual para  º±±
±±º          ³             gravacao da data no SDB para RF                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DLDataAtu()
Local lWMSAtDt := (SuperGetMV('MV_WMSATDT', .F., 'S')=='S') //-- Indica se a data do Protheus deve ser atualizada se diferente da data do sistema
If dDataBase # Date() .And. lWMSAtDt
   dDataBase := Date()
EndIf
Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FuncaoExecºAutor  ³Evaldo Cevinscki Jr.º Data ³  10/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega funcoes relacionadas as que esta sendo executada    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ DLGV002                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FuncaoExec(cFunExe)
Local nFunExe  := 0
Local cFuncoes := ''

//Deverá ser armazenado o processo que foi realizado (1-Apanhe/ 2- Endereçamento)
If 'DLAPANHE' $ cFunExe.Or. ;
   'DLGXABAST' $ cFunExe
   nFunExe := 1
EndIf

If 'DLENDERECA' $ cFunExe.Or. ;
   'DLTRANSFER' $ cFunExe.Or. ;
   'DLCROSSDOC' $ cFunExe  
   nFunExe := 2
EndIf

//Deverá ser armazenada as funções que poderão ser realizadas:

aDados := FwGetSX5("L6")
For nI := 01 to Len(aDados)

   cFunDes := AllTrim(Upper(aDados[nI,04]))
   
   If nFunExe == 2 
      If 'DLENDERECA' $ cFunDes .Or. ;
         'DLTRANSFER' $ cFunDes .Or. ;
         'DLCROSSDOC' $ cFundes  
         If Empty(cFuncoes)
            cFuncoes := aDados[nI,03]
         Else
            cFuncoes := cFuncoes + "','" + aDados[nI,03]
         EndIf
      EndIf
   Else
      If ('DLAPANHE' $ cFunDes .Or. ;
         'DLGXABAST' $ cFunDes) .And.;
         !'DLAPANHEVL' $ cFunDes
         If Empty(cFuncoes)
            cFuncoes := aDados[nI,03]
         Else
            cFuncoes := cFuncoes + "','" + aDados[nI,03]
         EndIf
      EndIf 
   EndIf

Next nI
/*
DbSelectArea('SX5')
SX5->( DbSetOrder(1) )
SX5->( DbSeek(xFilial('SX5')+'L6') )
While SX5->(!Eof() ) .And. ;
   SX5->X5_FILIAL == xFilial('SX5') .And. ;
   SX5->X5_TABELA == 'L6'
   
   cFunDes := AllTrim(Upper(SX5->X5_DESCRI))
   
   If nFunExe == 2 
      If 'DLENDERECA' $ cFunDes .Or. ;
         'DLTRANSFER' $ cFunDes .Or. ;
         'DLCROSSDOC' $ cFundes  
         If Empty(cFuncoes)
            cFuncoes := SX5->X5_CHAVE
         Else
            cFuncoes := cFuncoes + "','" + SX5->X5_CHAVE
         EndIf
      EndIf
   Else
      If ('DLAPANHE' $ cFunDes .Or. ;
         'DLGXABAST' $ cFunDes) .And.;
         !'DLAPANHEVL' $ cFunDes
         If Empty(cFuncoes)
            cFuncoes := SX5->X5_CHAVE
         Else
            cFuncoes := cFuncoes + "','" + SX5->X5_CHAVE
         EndIf
      EndIf 
   EndIf
   SX5->(DbSkip())
End
*/

Return cFuncoes

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³DLGV002SRVºAutor  ³Evaldo Cevinscki Jr.º Data ³  10/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Checa se existe mais alguma tarefa a executar da mesma funcaoº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Usado pelo programas DLG110 e DLGV111                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DLGV001SRV(nRecno)
Local lRet        := .f.
Local cAliasNew   := GetNextAlias()
Local cBranco2 := Space(Len(SDB->DB_RECHUM))
Local cFuncoes := ''

cFuncao     := aParConv[1]
cRecHum     := aParConv[3]
nIndSDB     := aParConv[4]
cUsuArma := aParConv[5]
cUsuZona := aParConv[6]
nIndSDB1 := aParConv[7]
nTipoConv   := aParConv[11]
dDataFec := aParConv[15]


//carrega funcoes
If !Empty(cFunExe) 
   cFuncoes := FuncaoExec(cFunExe)
EndIf 

cQuery := " SELECT CASE"
cQuery +=           " WHEN SDB.DB_STATUS IN ('"+cStatProb+"','"+cStatInte+"') THEN 0"
cQuery +=           " WHEN (SDB.DB_STATUS NOT IN ('"+cStatProb+"','"+cStatInte+"') AND SDB.DB_RECHUM = '"+cRecHum+"') THEN 1"
cQuery +=           " WHEN (SDB.DB_STATUS NOT IN ('"+cStatProb+"','"+cStatInte+"') AND SDB.DB_RECHUM = '"+cBranco2+"') THEN 2"
cQuery +=        " ELSE 99 "
cQuery +=        " END AS ORDWMS,"
cQuery +=        " SDB.R_E_C_N_O_ RECSDB,"
cQuery +=       " (SELECT DC5.R_E_C_N_O_ FROM " + RetSqlName('DC5') + " DC5"
cQuery +=         " WHERE DC5.DC5_FILIAL = '"+xFilial("DC5")+"'"
cQuery +=           " AND DC5.DC5_SERVIC = SDB.DB_SERVIC "
cQuery +=           " AND DC5.DC5_TAREFA = SDB.DB_TAREFA "
cQuery +=           " AND DC5.DC5_ORDEM = SDB.DB_ORDTARE "
If Empty(cFuncoes)
   cQuery +=           " AND DC5.DC5_FUNEXE <> '"+cFuncoes+"'"
Else
   cQuery +=           " AND DC5.DC5_FUNEXE IN ('"+cFuncoes+"')"
EndIf 
cQuery +=           " AND DC5.D_E_L_E_T_ = ' ') RECDC5, "
cQuery +=       " (SELECT DC6.R_E_C_N_O_ FROM " + RetSqlName('DC6')+" DC6"
cQuery +=         " WHERE DC6.DC6_FILIAL = '"+xFilial("DC6")+"'"
cQuery +=           " AND DC6.DC6_TAREFA = SDB.DB_TAREFA "
cQuery +=           " AND DC6.DC6_ATIVID = SDB.DB_ATIVID "
cQuery +=           " AND DC6.DC6_ORDEM = SDB.DB_ORDATIV "
cQuery +=           " AND DC6.D_E_L_E_T_ = ' ') RECDC6 "
cQuery +=   " FROM " + RetSqlName('SDB')+" SDB "
cQuery +=  " WHERE SDB.DB_FILIAL = '"+xFilial("SDB")+"'"
                                                                                       
//Verifica a versao e o paramentro que permite reabrir tarefa paralizadas
cQuery += IIf(cReinAuto == 'S'," AND SDB.DB_STATUS IN ('"+cStatProb+"','"+cStatAExe+"')", " AND SDB.DB_STATUS = '"+cStatAExe+"'" )
cQuery += " AND SDB.DB_ATUEST = 'N'"
cQuery += " AND SDB.DB_ESTORNO <> 'S'"
If nTipoConv <> 2 //-- Convocacao por ATIVIDADE (Default)
   cQuery += " AND SDB.DB_RHFUNC = '"+cFuncao+"'"
EndIf
If !Empty(cUsuArma)
   cQuery += " AND SDB.DB_LOCAL = '"+cUsuArma+"'"
EndIf
cQuery += " AND SDB.DB_DATA   > '"+dDataFec+"'"
If ExistBlock('DLV001WH')
   cQuery += ExecBlock('DLV001WH',.F.,.F.,{cRecHum,cFuncao})
EndIf
cQuery += " AND SDB.D_E_L_E_T_ = ' ' "  
cQuery += " AND SDB.R_E_C_N_O_ <> '"+AllTrim(Str(nRecno))+"'"
cQuery += " ORDER BY ORDWMS, "

If ExistBlock('DLV001ORD')
   cQuery += ExecBlock('DLV001ORD', .F., .F., {nIndSDB1})
Else
   cQuery += SqlOrder(SDB->(IndexKey(nIndSDB1))) //DB_FILIAL+DB_STATUS+DB_PRIORI+DB_CARGA+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_ITEM+DB_SERVIC+DB_ORDTARE+DB_ORDATIV
EndIf
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)

While (cAliasNew)->(!Eof())
   
   If Empty((cAliasNew)->RECDC5)
      (cAliasNew)->(DbSkip())
      Loop
   EndIf
   //verifica se o registro do SDB ja foi executado pelo processo de multi-tarefas
   nReg := aScan(aColetor,{|x|x[1] == (cAliasNew)->RECSDB })
   If nReg > 0
      (cAliasNew)->(DbSkip())
      Loop
   EndIf
   
   //Se for registro interrompido e ja fez pergunta se deseja reiniciar, desconsidera esse registro
   If (cAliasNew)->ORDWMS == 0 .And. lReinAuto 
      (cAliasNew)->(DbSkip())
      Loop
   EndIf 
      
   //Se encontrou algum registro retorna .t. para continuar convocação
   lRet := .t.
   Exit

   (cAliasNew)->(DbSkip())
EndDo
(cAliasNew)->( dbCloseArea() )

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³DLGV002DOCºAutor  ³Evaldo Cevinscki Jr.º Data ³  11/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Checa se existe mais APANHE para a mesmo carga/documento    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1 - Carga+Documento+Cliente+Loja                       º±±
±±º          ³ ExpL1 - .T. = Checa os registros executados                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DLGV001DOC(cRegAnt,lChkExe)
Local aAreaSDB := SDB->(GetArea())
Local lRet     := .f.
Local cAliasDCQ   := GetNextAlias()
Local cAliasDoc   := GetNextAlias()
Local cBranco2 := Space(Len(SDB->DB_RECHUM))
Local cFuncoes := ''
Local lContinua   := .F.
Local i

cFuncao     := aParConv[1]
cRecHum     := aParConv[3]
nIndSDB     := aParConv[4]
cUsuArma := aParConv[5]
cUsuZona := aParConv[6]
nIndSDB1 := aParConv[7]
nTipoConv   := aParConv[11]
dDataFec := aParConv[15]

cNumero := Left(SDB->DB_DOC,Len(SD7->D7_NUMERO))
SD7->(DbSetOrder(3))
If SD7->(MsSeek(xFilial('SD7')+SDB->DB_PRODUTO+SDB->DB_NUMSEQ+cNumero))
   cArmazem := SD7->D7_LOCAL
Else
   cArmazem := SDB->DB_LOCAL
EndIf

cQuery := " SELECT DCQ_FILIAL, DCQ_TPREGR, DCQ_DOCEXC "
cQuery += " FROM " + RetSqlName('DCQ')    
cQuery += " WHERE DCQ_FILIAL = '"+xFilial("DCQ")+"'"
cQuery += "    AND DCQ_DOCEXC <> '2' "
cQuery += " AND DCQ_LOCAL = '"+cArmazem+"' "
cQuery += " AND (DCQ_CODFUN = '' or DCQ_CODFUN = '"+cRecHum+"') "
cQuery += " AND (DCQ_CODZON = '' or DCQ_CODZON = '"+cUsuZona+"') "
cQuery += " AND (DCQ_SERVIC = '' or DCQ_SERVIC = '"+SDB->DB_SERVIC+"') "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDCQ,.F.,.T.)
   
While (cAliasDCQ)->(!Eof())
   
   lContinua := .T.

   (cAliasDCQ)->(DbSkip())
EndDo
(cAliasDCQ)->( dbCloseArea() )

If lContinua
   //carrega funcoes
   If !Empty(cFunExe) 
      cFuncoes := FuncaoExec(cFunExe)
   EndIf 
   
   cQuery := " SELECT "
   cQuery +=        " SDB.R_E_C_N_O_ RECSDB,"
   cQuery +=       " (SELECT DC5.R_E_C_N_O_ FROM " + RetSqlName('DC5') + " DC5"
   cQuery +=         " WHERE DC5.DC5_FILIAL = '"+xFilial("DC5")+"'"
   cQuery +=           " AND DC5.DC5_SERVIC = SDB.DB_SERVIC "
   cQuery +=           " AND DC5.DC5_TAREFA = SDB.DB_TAREFA "
   If Empty(cFuncoes)
      cQuery +=           " AND DC5.DC5_FUNEXE <> '"+cFuncoes+"'"
   Else
      cQuery +=           " AND DC5.DC5_FUNEXE IN ('"+cFuncoes+"')"
   EndIf 
   cQuery +=           " AND DC5.D_E_L_E_T_ = ' ') RECDC5 "
   cQuery +=   " FROM " + RetSqlName('SDB')+" SDB "
   cQuery +=  " WHERE SDB.DB_FILIAL = '"+xFilial("SDB")+"'"
                                                                                          
   //Verifica a versao e o paramentro que permite reabrir tarefa paralizadas
   If !lChkExe
      cQuery += IIf(cReinAuto == 'S'," AND SDB.DB_STATUS IN ('"+cStatProb+"','"+cStatAExe+"')", " AND SDB.DB_STATUS = '"+cStatAExe+"'" )
   Else //checagem feita para verificar se tem documento ja executado com o mesmo documento do que esta interrompido
      cQuery += " AND SDB.DB_STATUS = '"+cStatExec+"'" 
   EndIf 
   cQuery += " AND SDB.DB_ATUEST = 'N'"
   cQuery += " AND SDB.DB_ESTORNO <> 'S'"
   cQuery += " AND SDB.DB_DATA   > '"+dDataFec+"'"
   cQuery += " AND SDB.D_E_L_E_T_ = ' ' "  
   cQuery += " AND SDB.DB_CARGA+SDB.DB_DOC+SDB.DB_CLIFOR+SDB.DB_LOJA = '"+cRegAnt+"'" 
   cQuery += " ORDER BY "
   cQuery += SqlOrder(SDB->(IndexKey(nIndSDB1))) //DB_FILIAL+DB_STATUS+DB_PRIORI+DB_CARGA+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_ITEM+DB_SERVIC+DB_ORDTARE+DB_ORDATIV
   
   cQuery := ChangeQuery(cQuery)
   DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDoc,.F.,.T.)
   
   While (cAliasDoc)->(!Eof())
      
      If Empty((cAliasDoc)->RECDC5)
         (cAliasDoc)->(DbSkip())
         Loop
      EndIf
      
      //altera a prioridade dos registros encontrados
      DbSelectArea("SDB")
      dbGoTo((cAliasDoc)->RECSDB)
      RecLock('SDB', .F.)
      SDB->DB_PRIORI := "00"
      SDB->(MsUnlock())
      
         
      lRet := .t.
      //Exit
   
      (cAliasDoc)->(DbSkip())
   EndDo
   (cAliasDoc)->( dbCloseArea() )
   
   //altera a prioridade do registro que ja foi executado para caso seja interrompido, quando voltar a executar seja executado por primeiro
   If lRet
      DbSelectArea("SDB")
      dbGoTo(nRecnoAnt)
      RecLock('SDB', .F.)
      SDB->DB_PRIORI := "00"
      SDB->(MsUnlock())
   EndIf

   //verifica nos registros que foram feito pelo processo de multi-tarefa
   If !lRet .And. lChkExe .And. Len(aColetor) > 0
      nReg := aScan(aColetor,{|x|x[24]+x[25]+x[26]+x[27] == cRegAnt })
      If nReg > 0
         lRet := .T.
         For i:= 1 to Len(aColetor)
            If aColetor[i][24]+aColetor[i][25]+aColetor[i][26]+aColetor[i][27] == cRegAnt
               DbSelectArea("SDB")
               dbGoTo(aColetor[i][1])
               RecLock('SDB', .F.)
               SDB->DB_PRIORI := "00"
               SDB->(MsUnlock())
            EndIf
         Next i
      EndIf
   EndIf
EndIf

RestArea(aAreaSDB)
Return lRet
