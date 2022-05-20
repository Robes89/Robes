#include "Protheus.ch"
#INCLUDE "MATC030.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MA2802FI    ³ Autor ³Leandro da Silva Duarte³ Data ³12/02/2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Rotina de certo da SB2 apos virada de saldo fora do dia 31 de ³±±
±±³          ³cada mes                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Protheus 12                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User function MA2802FI()
Local _dData        := paramixb[1]
Local _dDataFec     := paramixb[2]
lOCAL cPerg     := "CPAESTO001"
Local aTables   := {"SF3","SF2","SD2","SF1","SD1","SE1","SA1","SA2","SE2","SD3","SE4","SFT","SL3","SL4","SF4","CC2","SB1","SB2","SC9","SC5","SC6","SX5","SB1","SB9","CC2"}
ValidPerg(cPerg)
PERGUNTE(cPerg,.F.)
tcsqlexec("SELECT * INTO SB2_BKP_"+DTOS(DATE())+'_'+REPLACE(TIME(),':','')+" FROM SB2010")
tcsqlexec("SELECT * INTO SB9_BKP_"+DTOS(DATE())+'_'+REPLACE(TIME(),':','')+" FROM SB9010")
MsAguarde( { || STARTJOB('U_CPAESTOA',GetEnvServer(),.t.,{SM0->M0_CODIGO, SM0->M0_CODFIL ,aTables,_dDataFec,DATE(),2,'               ','ZZZZZZZZZZZZZZZ','01'}) }, "Aguarde...", "Processando o Ajuste de Estoque Armazem 01", .F. )
MsAguarde( { || STARTJOB('U_CPAESTOA',GetEnvServer(),.t.,{SM0->M0_CODIGO, SM0->M0_CODFIL ,aTables,_dDataFec,DATE(),2,'               ','ZZZZZZZZZZZZZZZ','02'}) }, "Aguarde...", "Processando o Ajuste de Estoque Armazem 02", .F. )
MsAguarde( { || STARTJOB('U_CPAESTOA',GetEnvServer(),.t.,{SM0->M0_CODIGO, SM0->M0_CODFIL ,aTables,_dDataFec,DATE(),2,'               ','ZZZZZZZZZZZZZZZ','03'}) }, "Aguarde...", "Processando o Ajuste de Estoque Armazem 03", .F. )
MsAguarde( { || STARTJOB('U_CPAESTOA',GetEnvServer(),.t.,{SM0->M0_CODIGO, SM0->M0_CODFIL ,aTables,_dDataFec,DATE(),2,'               ','ZZZZZZZZZZZZZZZ','04'}) }, "Aguarde...", "Processando o Ajuste de Estoque Armazem 04", .F. )
MsAguarde( { || STARTJOB('U_CPAESTOA',GetEnvServer(),.t.,{SM0->M0_CODIGO, SM0->M0_CODFIL ,aTables,_dDataFec,DATE(),2,'               ','ZZZZZZZZZZZZZZZ','05'}) }, "Aguarde...", "Processando o Ajuste de Estoque Armazem 05", .F. )
MsAguarde( { || STARTJOB('U_CPAESTOA',GetEnvServer(),.t.,{SM0->M0_CODIGO, SM0->M0_CODFIL ,aTables,_dDataFec,DATE(),2,'               ','ZZZZZZZZZZZZZZZ','06'}) }, "Aguarde...", "Processando o Ajuste de Estoque Armazem 06", .F. )
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CPAESTOA  ºAutor  ³leandro duarte      º Data ³  06/22/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³rotina para rodar os jobs                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function CPAESTOA(xPar)
Local cQuery := ""
Local nTipox    := 0
Private aParam  := xPar
Private cXLoc   := aParam[9]
RpcSetType(3)
RpcSetEnv( aParam[1], aParam[2] ,,, "FAT", "Ajustando Estoque SB2 e SB9", aParam[3], , , ,  )

cQuery := "SELECT A.R_E_C_N_O_ AS REC, B.B2_FILIAL FROM "+RETSQLNAME("SB1")+" A, "+RETSQLNAME("SB2")+" B WHERE A.B1_FILIAL = '  ' AND A.D_E_L_E_T_ = ' ' and A.B1_COD = B.B2_COD AND B.D_E_L_E_T_ = ' ' AND B.B2_FILIAL = '"+SM0->M0_CODFIL+"' AND B.B2_LOCAL = '"+aParam[9]+"'  AND B.B2_COD between '"+aParam[7]+"' AND '"+aParam[8]+"' "

nTipox := aParam[6]


IIF(SELECT("TMPSB1")>0,TMPSB1->(DBCLOSEAREA()),NIL)

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPSB1",.T.,.T.)

WHILE TMPSB1->(!EOF())
    SB1->(DBGOTO(TMPSB1->REC))
    CPAESTOB(nTipox,TMPSB1->B2_FILIAL)
    TMPSB1->(DBSKIP())
END
RpcClearEnv()

return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CPAESTOB  ºAutor  ³LEANDRO DUARTE      º Data ³  06/22/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ROTINA PARA PEGAR OS VALORES                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P12                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CPAESTOB(NTP, xcFil)
lOCAL NFor          := 0
LOCAL aSalTel       := {} ,nCusMed := 0 ,aSalIni := {}
LOCAL aArea         :=GetArea()
LOCAL bKeyF12       :=  SetKey( VK_F12 )
PRIVATE aGraph      := {}
PRIVATE aTrbP       := {}
PRIVATE aTrbTmp     := {}
PRIVATE aTela       := {}
PRIVATE aSalAtu     := { 0,0,0,0,0,0,0 }
PRIVATE cPictTotQT  :=PesqPictQt("B2_QATU")
PRIVATE nTotSda     := nTotEnt :=  nTotvSda := nTotvEnt  := 0
PRIVATE cTRBSD1     := CriaTrab(,.F.)
PRIVATE cTRBSD2     := Subs(cTRBSD1,1,7)+"A"
PRIVATE cTRBSD3     := Subs(cTRBSD1,1,7)+"B"
PRIVATE cPictQT     := PesqPict("SB2","B2_QATU",18)
DEFAULT NTP         := 0
Default xcFil       := xFilial("SB9")
conout('loja: '+xcFil)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desativa tecla F12                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set Key VK_F12 To

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava as movimentacoes no arquivo de trabalho                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

TcInternal( 1, "Processamento Ajustes de estoque Empresa/Filial/Produto: "+aParam[1]+"/"+aParam[2]+"/"+SB1->B1_COD  )
Processa({|| aSalTel := U_CPAESTOC()},, "Processando")
TcInternal( 1, "Processamento Ajustes de estoque Empresa/Filial/Produto: "+aParam[1]+"/"+aParam[2]+"/"+SB1->B1_COD  )

//varinfo('aTrbP Lj'+xcFil,aTrbP)
IF NTP == 1
    if Len(aTrbP) > 0
        xDtSald := stod("")
        Lentrx := .F.
        FOR NFor := 1 to len(aTrbP[1])
            IF valtype(aTrbP[1][nFor][1])=='D' //.AND. EMPTY(xDtSald)
                xDtSald := LASTDAY(aTrbP[1][nFor][1])
            ENDIF
            IF valtype(aTrbP[1][nFor][1])=='C' .AND. !EMPTY(xDtSald) .AND. LEN(aTrbP[1])>=nFor+1
                IF aTrbP[1][nFor-1][1] <= xDtSald .AND. aTrbP[1][nFor+1][1] >= xDtSald
                    Lentrx := .T.
                ENDIF
            elseIF valtype(aTrbP[1][nFor][1])=='C' .AND. !EMPTY(xDtSald) .AND. LEN(aTrbP[1])= nFor
                IF aTrbP[1][nFor-1][1] <= xDtSald 
                    Lentrx := .T.
                ENDIF
            ENDIF
            if Lentrx .and. valtype(aTrbP[1][nFor][1])=='C' .and. SB9->(DBSEEK(xcFil+SB1->B1_COD+cXLoc+DTOS(xDtSald)))//B9_FILIAL, B9_COD, B9_LOCAL, B9_DATA, R_E_C_N_O_, D_E_L_E_T_
                reclock("SB9",.F.)
                SB9->B9_QINI  := VAL(REPLACE(aTrbP[1][nFor][8],',','.'))
                SB9->B9_CUSTD := VAL(REPLACE(aTrbP[1][nFor][9],',','.'))
                SB9->B9_VINI1 := VAL(REPLACE(aTrbP[1][nFor][10],',','.'))
                msunlock()
                SB2->(DBSETORDER(1))
                Lentrx := .F.
                xDtSald := stod("")
                if SB2->(DBSEEK(xcFil+SB1->B1_COD+cXLoc))//B2_FILIAL, B2_COD, B2_LOCAL, R_E_C_N_O_, D_E_L_E_T_
                    reclock("SB2",.F.)
                    SB2->B2_QFIM  := VAL(REPLACE(aTrbP[1][nFor][8],',','.'))
                    msunlock()
                ENDIF
            ENDIF
        next nFor
        /*Processo apos termino do loop e não chegou ao final do periodo informado nos parametros esse processo servira pelo motivo que 
          a rotina de calculo não teve movimentos nos periodos futuros
        */
        xDtSald := LASTDAY(aTrbP[1][len(aTrbP[1])-1][1])
        IF DTOS(xDtSald)< DTOS(APARAM[5]) // DATA FINAL DO PARAMETRO DIGITADO
            xDtSald     := LASTDAY(LASTDAY(xDtSald)+1)
            WHILE DTOS(xDtSald)<= DTOS(APARAM[5]) 
                IF SB9->(DBSEEK(xcFil+SB1->B1_COD+cXLoc+DTOS(xDtSald))) //B9_FILIAL, B9_COD, B9_LOCAL, B9_DATA, R_E_C_N_O_, D_E_L_E_T_
                    reclock("SB9",.F.)
                    SB9->B9_QINI  := VAL(REPLACE(aTrbP[1][len(aTrbP[1])][8],',','.'))
                    SB9->B9_CUSTD := VAL(REPLACE(aTrbP[1][len(aTrbP[1])][9],',','.'))
                    SB9->B9_VINI1 := VAL(REPLACE(aTrbP[1][len(aTrbP[1])][10],',','.'))
                    msunlock()
                ENDIF
                SB2->(DBSETORDER(1))
                if SB2->(DBSEEK(xcFil+SB1->B1_COD+cXLoc))//B2_FILIAL, B2_COD, B2_LOCAL, R_E_C_N_O_, D_E_L_E_T_
                    reclock("SB2",.F.)
                    SB2->B2_QFIM  := VAL(REPLACE(aTrbP[1][len(aTrbP[1])][8],',','.'))
                    msunlock()
                ENDIF
                xDtSald     := LASTDAY(LASTDAY(xDtSald)+1)
            END
        ENDIF
    ELSEIF Len(aTrbP)==0 .AND. SB9->(DBSEEK(xcFil+SB1->B1_COD+cXLoc+dtos(lastday(APARAM[4]))))
        SB9->(DBSkip(-1))
        aadd(aTrbP,{SB9->B9_QINI,SB9->B9_CUSTD,SB9->B9_VINI1})
        SB9->(DBSEEK(xcFil+SB1->B1_COD+cXLoc+dtos(lastday(APARAM[4]))))
        reclock("SB9",.F.)
        SB9->B9_QINI  := aTrbP[1][1]
        SB9->B9_CUSTD := aTrbP[1][2]
        SB9->B9_VINI1 := aTrbP[1][3]
        msunlock()
        /*Processo de ajuste dos valores para os meses que não houveram movimentações visto que desde o peeriodo inicial o sistema não teve 
          movimento.
        */
        xDtSald := LASTDAY(APARAM[4])
        IF DTOS(xDtSald)< DTOS(APARAM[5]) // DATA FINAL DO PARAMETRO DIGITADO
            xDtSald     := LASTDAY(LASTDAY(xDtSald)+1)
            WHILE DTOS(xDtSald)<= DTOS(APARAM[5]) 
                IF SB9->(DBSEEK(xcFil+SB1->B1_COD+cXLoc+DTOS(xDtSald))) //B9_FILIAL, B9_COD, B9_LOCAL, B9_DATA, R_E_C_N_O_, D_E_L_E_T_
                    reclock("SB9",.F.)
                    SB9->B9_QINI  := aTrbP[1][1]
                    SB9->B9_CUSTD := aTrbP[1][2]
                    SB9->B9_VINI1 := aTrbP[1][3]
                    msunlock()
                ENDIF
                SB2->(DBSETORDER(1))
                if SB2->(DBSEEK(xcFil+SB1->B1_COD+cXLoc))//B2_FILIAL, B2_COD, B2_LOCAL, R_E_C_N_O_, D_E_L_E_T_
                    reclock("SB2",.F.)
                    SB2->B2_QFIM  := aTrbP[1][1]
                    msunlock()
                ENDIF
                xDtSald     := LASTDAY(LASTDAY(xDtSald)+1)
            END
        ENDIF
        aTrbP := {}
    ELSEIF Len(aTrbP)==0 .AND. SB9->(DBSEEK(xcFil+SB1->B1_COD+cXLoc+DTOS(APARAM[5])))
        SB9->(DBSkip(-1))
        aadd(aTrbP,{SB9->B9_QINI,SB9->B9_CUSTD,SB9->B9_VINI1})
        SB9->(DBSEEK(xcFil+SB1->B1_COD+cXLoc+DTOS(APARAM[5])))
        reclock("SB9",.F.)
        SB9->B9_QINI  := aTrbP[1][1]
        SB9->B9_CUSTD := aTrbP[1][2]
        SB9->B9_VINI1 := aTrbP[1][3]
        msunlock()
        aTrbP := {}
    ENDIF
ELSEIF NTP == 2
    if Len(aTrbP) > 0
        SB2->(DBSETORDER(1))
        if SB2->(DBSEEK(xcFil+SB1->B1_COD+cXLoc))//B2_FILIAL, B2_COD, B2_LOCAL, R_E_C_N_O_, D_E_L_E_T_
            reclock("SB2",.F.)
            SB2->B2_QATU  := VAL(REPLACE(aTrbP[LEN(aTrbP)][LEN(aTrbP[LEN(aTrbP)])][8],',','.'))
            msunlock()
        ENDIF
    else
        cQuery := " SELECT B9_QINI, B9_CUSTD, B9_VINI1 "
        cQuery += "   FROM "+RETSQLNAME("SB9")+" A "
        cQuery += "  WHERE A.B9_FILIAL = '"+xcFil+"' "
        cQuery += "    AND A.D_E_L_E_T_ = ' ' "
        cQuery += "    AND A.B9_COD = '"+SB1->B1_COD+"' "
        cQuery += "    AND A.B9_LOCAL = '"+cXLoc+"' "
        cQuery += "    AND B9_DATA <= '"+DTOS(APARAM[5])+"' "
        cQuery += "    AND ROWNUM = 1 "
        cQuery += " ORDER BY B9_DATA DESC"
        IIf(Select('TRB') > 0,TRB->(dbCloseArea()),NIL)
        DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), "TRB", .F., .T. )
        IF TRB->(!EOF())
            SB2->(DBSETORDER(1))
            if SB2->(DBSEEK(xcFil+SB1->B1_COD+cXLoc))//B2_FILIAL, B2_COD, B2_LOCAL, R_E_C_N_O_, D_E_L_E_T_
                reclock("SB2",.F.)
                SB2->B2_QATU  := TRB->B9_QINI
                SB2->B2_VATU1 := TRB->B9_VINI1
                SB2->B2_CM1   := TRB->B9_CUSTD              
                msunlock()
            ENDIF
        ENDIF
    endif
ELSE
    xDtSald := stod("")
    Lentrx := .F.
    if Len(aTrbP) > 0
        fOR NFor := 1 to len(aTrbP[1])
            IF valtype(aTrbP[1][nFor][1])=='D' //.AND. EMPTY(xDtSald)
                xDtSald := LASTDAY(aTrbP[1][nFor][1])
            ENDIF
            IF valtype(aTrbP[1][nFor][1])=='C' .AND. !EMPTY(xDtSald) .AND. LEN(aTrbP[1])>=nFor+1
                IF aTrbP[1][nFor-1][1] <= xDtSald .AND. aTrbP[1][nFor+1][1] >= xDtSald
                    Lentrx := .T.
                ENDIF
            elseIF valtype(aTrbP[1][nFor][1])=='C' .AND. !EMPTY(xDtSald) .AND. LEN(aTrbP[1])= nFor
                IF aTrbP[1][nFor-1][1] <= xDtSald 
                    Lentrx := .T.
                ENDIF
            ENDIF
            if Lentrx .AND. valtype(aTrbP[1][nFor][1])=='C' .and. SB9->(DBSEEK(xcFil+SB1->B1_COD+cXLoc+DTOS(xDtSald)))//B9_FILIAL, B9_COD, B9_LOCAL, B9_DATA, R_E_C_N_O_, D_E_L_E_T_
                reclock("SB9",.F.)
                SB9->B9_QINI  := VAL(REPLACE(aTrbP[1][nFor][8],',','.'))
                SB9->B9_CUSTD := VAL(REPLACE(aTrbP[1][nFor][9],',','.'))
                SB9->B9_VINI1 := VAL(REPLACE(aTrbP[1][nFor][10],',','.'))
                msunlock()
                SB2->(DBSETORDER(1))
                Lentrx := .F.
                xDtSald := stod("")
                if SB2->(DBSEEK(xcFil+SB1->B1_COD+cXLoc))//B2_FILIAL, B2_COD, B2_LOCAL, R_E_C_N_O_, D_E_L_E_T_
                    reclock("SB2",.F.)
                    SB2->B2_QFIM  := VAL(REPLACE(aTrbP[1][nFor][8],',','.'))
                    msunlock()
                ENDIF
            ENDIF
        next nFor/*Processo apos termino do loop e não chegou ao final do periodo informado nos parametros esse processo servira pelo motivo que 
          a rotina de calculo não teve movimentos nos periodos futuros
        */
        xDtSald := LASTDAY(aTrbP[1][len(aTrbP[1])-1][1])
        IF DTOS(xDtSald)< DTOS(APARAM[5]) // DATA FINAL DO PARAMETRO DIGITADO
            xDtSald     := LASTDAY(LASTDAY(xDtSald)+1)
            WHILE DTOS(xDtSald)<= DTOS(APARAM[5]) 
                IF SB9->(DBSEEK(xcFil+SB1->B1_COD+cXLoc+DTOS(xDtSald))) //B9_FILIAL, B9_COD, B9_LOCAL, B9_DATA, R_E_C_N_O_, D_E_L_E_T_
                    reclock("SB9",.F.)
                    SB9->B9_QINI  := VAL(REPLACE(aTrbP[1][len(aTrbP[1])][8],',','.'))
                    SB9->B9_CUSTD := VAL(REPLACE(aTrbP[1][len(aTrbP[1])][9],',','.'))
                    SB9->B9_VINI1 := VAL(REPLACE(aTrbP[1][len(aTrbP[1])][10],',','.'))
                    msunlock()
                ENDIF
                SB2->(DBSETORDER(1))
                if SB2->(DBSEEK(xcFil+SB1->B1_COD+cXLoc))//B2_FILIAL, B2_COD, B2_LOCAL, R_E_C_N_O_, D_E_L_E_T_
                    reclock("SB2",.F.)
                    SB2->B2_QFIM  := VAL(REPLACE(aTrbP[1][len(aTrbP[1])][8],',','.'))
                    msunlock()
                ENDIF
                xDtSald     := LASTDAY(LASTDAY(xDtSald)+1)
            END
        ENDIF
    endif
    if Len(aTrbP) > 0
        SB2->(DBSETORDER(1))
        if SB2->(DBSEEK(xcFil+SB1->B1_COD+cXLoc))//B2_FILIAL, B2_COD, B2_LOCAL, R_E_C_N_O_, D_E_L_E_T_
            reclock("SB2",.F.)
            SB2->B2_QATU  := VAL(REPLACE(aTrbP[LEN(aTrbP)][LEN(aTrbP[LEN(aTrbP)])][8],',','.'))
            SB2->B2_VATU1 := VAL(REPLACE(aTrbP[LEN(aTrbP)][LEN(aTrbP[LEN(aTrbP)])][10],',','.'))
            SB2->B2_CM1   := VAL(REPLACE(aTrbP[LEN(aTrbP)][LEN(aTrbP[LEN(aTrbP)])][9],',','.')) 
            msunlock()
        ENDIF
    ELSE
        cQuery := " SELECT B9_QINI, B9_CUSTD, B9_VINI1 "
        cQuery += "   FROM "+RETSQLNAME("SB9")+" A "
        cQuery += "  WHERE A.B9_FILIAL = '"+xcFil+"' "
        cQuery += "    AND A.D_E_L_E_T_ = ' ' "
        cQuery += "    AND A.B9_COD = '"+SB1->B1_COD+"' "
        cQuery += "    AND A.B9_LOCAL = '"+cXLoc+"' "
        cQuery += "    AND B9_DATA <= '"+DTOS(APARAM[5])+"' "
        cQuery += "    AND ROWNUM = 1 "
        cQuery += " ORDER BY B9_DATA DESC"
        IIf(Select('TRB') > 0,TRB->(dbCloseArea()),NIL)
        DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), "TRB", .F., .T. )
        IF TRB->(!EOF())
            SB2->(DBSETORDER(1))
            if SB2->(DBSEEK(xcFil+SB1->B1_COD+cXLoc))//B2_FILIAL, B2_COD, B2_LOCAL, R_E_C_N_O_, D_E_L_E_T_
                reclock("SB2",.F.)
                SB2->B2_QATU  := TRB->B9_QINI
                SB2->B2_VATU1 := TRB->B9_VINI1
                SB2->B2_CM1   := TRB->B9_CUSTD              
                msunlock()
            ENDIF
        ENDIF
    endif
ENDIF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Ordem Original do arquivo principal               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SD1")
dbSetOrder(1)
dbSelectArea("SD2")
dbSetOrder(1)
dbSelectArea("SD3")
dbSetOrder(1)
RestArea(aArea)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa tecla F12 para acessar os parametros³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey( VK_F12,bKeyF12)
Return .T.



USER Function CPAESTOC()
Static lIxbConTes  := NIL
Local dCntData
Local nCusMed   := 0
Local cIdent    := ""
Local aSaldoIni := {}
Local cDocumento:=""
Local aRetorno  := {cPictQT, cPictTotQT}
Local nInd,cCondicao
Local cNumSeqTr := "" , nRegTr := 0
Local cAlias    := "", cSeqIni := ""
Local i         := 0
Local aDados    := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe ponto de entrada                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lTesNEst  := .F.
Local lMc030Idmv:= ExistBlock("MC030IDMV")

// Indica se esta listando relatorio do almox. de processo
Local lLocProc  := aParam[9] == SuperGetMV("MV_LOCPROC")
// Indica se deve imprimir movimento invertido (almox. de processo)
Local lInverteMov:= .F.
Local cProdMNT   := GetMv("MV_PRODMNT")
Local cDepTrf    := SuperGetMv("MV_DEPTRANS",.F.,"95")  // Dep.transferencia
Local lTranSB2   := SuperGetMv("MV_TRANSB2",.F.,.F.)    // Atualiza saldos de transferencia
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Indica produto MANUTENCAO (MV_PRODMNT) qdo integrado com MNT       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lProIsMNT :=  MTC030IsMNT()
Local lUsaD2DIG := IIF(FindFunction("UsaD2DTDIG"), UsaD2DTDIG(), .F.)
Local cAliasSD2 := "SD2" // por default deve ser a tabela SD2
Local cQuerySD2 := ""
Local lQuerySD2 := .F.
Local aProdsMNT := {}

//ProcRegua(aParam[5] - aParam[4])

lIxbConTes := IF(lIxbConTes == NIL,ExistBlock("MTAAVLTES"),lIxbConTes)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se utiliza custo unificado por Empresa/Filial       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE lCusUnif := IIf(FindFunction("A330CusFil"),A330CusFil(),SuperGetMV("MV_CUSFIL",.F.))
lCusUnif:=lCusUnif .And. "*" $ aParam[9]


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula o Saldo Inicial do Produto             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCusUnif
    aArea:=GetArea()
    dbSelectArea("SB2")
    dbSetOrder(1)
    dbSeek(xFilial()+SB1->B1_COD)
    While !Eof() .And. B2_FILIAL+B2_COD == xFilial()+SB1->B1_COD
        aSalAlmox := CalcEst(SB1->B1_COD,SB2->B2_LOCAL,aParam[4])
        For i:=1 to Len(aSalAtu)
            aSalAtu[i] += aSalAlmox[i]
        Next i
        dbSkip()
    EndDo
    RestArea(aArea)
Else
    aSalAtu  := CalcEst(SB1->B1_COD,aParam[9],aParam[4])
EndIf
aSaldoIni:= ACLONE(aSalAtu)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para Altera‡„o de Picture.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock('MC030PIC')
    aRetorno := ExecBlock('MC030PIC', .F., .F., aRetorno)
    If ValType(aRetorno) == 'A'
        cPictQT    := aRetorno[1]
        cPictTotQT := aRetorno[2]
    EndIf
EndIf
dCntData  := aParam[4]
dbSelectArea("SD1")
If 1 == 1
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Cria Indice condicional p/ Custo Unificado                   ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If lCusUnif
        dbSelectArea("SD1")
        cIndice:="D1_FILIAL+D1_COD+DTOS(D1_DTDIGIT)+D1_NUMSEQ"
        cFiltro:=dbFilter()
        IndRegua("SD1",cTrbSD1,cIndice,,"D1_COD == '" + SB1->B1_COD + "'" + If(!Empty(cFiltro)," .AND. " + cFiltro,""),"Selecionando Registros") //
        nInd := RetIndex("SD1")
        #IFNDEF TOP
            dbSetIndex(cTrbSD1+OrdBagExt())
        #ENDIF
        dbSetOrder(nInd+1)
    Else
        dbSetOrder(7)
    EndIf
Else
    If lCusUnif
        cIndice:="D1_FILIAL+D1_COD+DTOS(D1_DTDIGIT)+D1_SEQCALC+D1_NUMSEQ"
    Else
        cIndice:="D1_FILIAL+D1_COD+D1_LOCAL+DTOS(D1_DTDIGIT)+D1_SEQCALC+D1_NUMSEQ"
    EndIf
    cFiltro:=dbFilter()
    IndRegua("SD1",cTRBSD1,cIndice,,"D1_COD == '" + SB1->B1_COD + "'" + If(!Empty(cFiltro)," .AND. " + cFiltro,""),"Selecionando Registros") // Selecionando Registros
    nInd := RetIndex("SD1")
    #IFNDEF TOP
        dbSetIndex(cTRBSD1+OrdBagExt())
    #ENDIF
    dbSetOrder(nInd+1)
Endif
dbSeek(cFilial+SB1->B1_COD+If(lCusUnif,"",aParam[9])+dtos(dCntData),.T.)

#IFDEF TOP
    cQuerySD2 := "SELECT SD2.D2_FILIAL, SD2.D2_COD, SD2.D2_DTDIGIT, SD2.D2_EMISSAO "
    cQuerySD2 +=     " , SD2.D2_NUMSEQ, SD2.D2_LOCAL, SD2.D2_SEQCALC, SD2.D2_ORIGLAN "
    cQuerySD2 +=     " , SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_LOJA "
    cQuerySD2 +=     " , SD2.D2_REMITO, SD2.D2_TPDCENV, SD2.D2_TES, SD2.R_E_C_N_O_ RECSD2 "
    cQuerySD2 +=  " FROM "+ RetSQLTab('SD2')
    cQuerySD2 += " WHERE SD2.D2_FILIAL = '"+xFilial("SD2")+"' "
    cQuerySD2 +=   " AND SD2.D2_COD = '" + SB1->B1_COD + "' "
    If !lCusUnif
        cQuerySD2 += " AND SD2.D2_LOCAL = '" + aParam[9] + "' "
    EndIf
    If !lUsaD2DIG
        cQuerySD2 += " AND SD2.D2_EMISSAO >= '" + DToS(dCntData) + "' "
        cQuerySD2 += " AND SD2.D2_EMISSAO <= '" + DToS(aParam[5]) + "' "
    Else
        cQuerySD2 += " AND SD2.D2_DTDIGIT >= '" + DToS(dCntData) + "' "
        cQuerySD2 += " AND SD2.D2_DTDIGIT <= '" + DToS(aParam[5]) + "' "
    EndIf
    cQuerySD2 += " AND SD2.D_E_L_E_T_ = ' ' "
    If 1 == 1
        // Ordem de digitacao
        If lCusUnif
            cQuerySD2 += " ORDER BY SD2.D2_FILIAL, SD2.D2_COD, " + IIf(lUsaD2DIG, "SD2.D2_DTDIGIT", "SD2.D2_EMISSAO") + ", SD2.D2_NUMSEQ "
        Else
            cQuerySD2 += " ORDER BY SD2.D2_FILIAL, SD2.D2_COD, SD2.D2_LOCAL, " + IIf(lUsaD2DIG, "SD2.D2_DTDIGIT", "SD2.D2_EMISSAO") + ", SD2.D2_NUMSEQ "
        EndIf
    Else
        // Ordem de calculo
        If lCusUnif
            cQuerySD2 += " ORDER BY SD2.D2_FILIAL, SD2.D2_COD, " + IIf(lUsaD2DIG, "SD2.D2_DTDIGIT", "SD2.D2_EMISSAO") + ", SD2.D2_SEQCALC, SD2.D2_NUMSEQ "
        Else
            cQuerySD2 += " ORDER BY SD2.D2_FILIAL, SD2.D2_COD, SD2.D2_LOCAL, " + IIf(lUsaD2DIG, "SD2.D2_DTDIGIT", "SD2.D2_EMISSAO") + ", SD2.D2_SEQCALC, SD2.D2_NUMSEQ "
        EndIf
    EndIf
    lQuerySD2 := .T.
    cAliasSD2 := GetNextAlias()
    cQuerySD2 := ChangeQuery( cQuerySD2 )
    DbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuerySD2), cAliasSD2, .T., .F. )
#ELSE
    dbSelectArea(cAliasSD2)
    If 1 == 1
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Cria Indice condicional p/ Custo Unificado                   ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If lCusUnif
            cIndice:="D2_FILIAL+D2_COD+DTOS("+IIf(lUsaD2DIG, "D2_DTDIGIT", "D2_EMISSAO")+")+D2_NUMSEQ"
        Else
            cIndice:="D2_FILIAL+D2_COD+D2_LOCAL+DTOS("+IIf(lUsaD2DIG, "D2_DTDIGIT", "D2_EMISSAO")+")+D2_NUMSEQ"
        EndIf
        cFiltro:=dbFilter()
        IndRegua("SD2",cTrbSD2,cIndice,,"D2_COD == '" + SB1->B1_COD + "'" + If(!Empty(cFiltro)," .AND. " + cFiltro,""),"Selecionando Registros")  // Selecionando Registros
        nInd := RetIndex("SD2")
        dbSetIndex(cTrbSD2+OrdBagExt())
        dbSetOrder(nInd+1)
    Else
        If lCusUnif
            cIndice:="D2_FILIAL+D2_COD+DTOS("+IIf(lUsaD2DIG, "D2_DTDIGIT", "D2_EMISSAO")+")+D2_SEQCALC+D2_NUMSEQ"
        Else
            cIndice:="D2_FILIAL+D2_COD+D2_LOCAL+DTOS("+IIf(lUsaD2DIG, "D2_DTDIGIT", "D2_EMISSAO")+")+D2_SEQCALC+D2_NUMSEQ"
        EndIf
        cFiltro:=dbFilter()
        IndRegua("SD2",cTRBSD2,cIndice,,"D2_COD == '" + SB1->B1_COD + "'" + If(!Empty(cFiltro)," .AND. " + cFiltro,""),"Selecionando Registros") // Selecionando Registros
        nInd := RetIndex("SD2")
        dbSetIndex(cTRBSD2+OrdBagExt())
        dbSetOrder(nInd+1)
    EndIf
    dbSeek(cFilial+SB1->B1_COD+If(lCusUnif,"",aParam[9])+dtos(dCntData),.T.)
#ENDIF

dbSelectArea("SD3")
If 1 ==1
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Cria Indice condicional p/ Custo Unificado ou Aprop.Indireta ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If lCusUnif .Or. lLocProc
        dbSelectArea("SD3")
        cIndice:="D3_FILIAL+D3_COD+DTOS(D3_EMISSAO)+D3_NUMSEQ"
        cFiltro:=dbFilter()
        IndRegua("SD3",cTrbSD3,cIndice,,"D3_COD == '" + SB1->B1_COD + "'" + If(!Empty(cFiltro)," .AND. " + cFiltro,""),"Selecionando Registros")  // Selecionando Registros
        nInd := RetIndex("SD3")
        #IFNDEF TOP
            dbSetIndex(cTrbSD3+OrdBagExt())
        #ENDIF
        dbSetOrder(nInd+1)
    Else
        dbSetOrder(7)
    EndIf
Else
    If lCusUnif .Or. lLocProc
        cIndice:="D3_FILIAL+D3_COD+DTOS(D3_EMISSAO)+D3_SEQCALC+D3_NUMSEQ"
    Else
        cIndice:="D3_FILIAL+D3_COD+D3_LOCAL+DTOS(D3_EMISSAO)+D3_SEQCALC+D3_NUMSEQ"
    EndIf
    cFiltro:=dbFilter()
    IndRegua("SD3",cTRBSD3,cIndice,,"D3_COD == '" + SB1->B1_COD + "'" + If(!Empty(cFiltro)," .AND. " + cFiltro,""),"Selecionando Registros") // Selecionando Registros
    nInd := RetIndex("SD3")
    #IFNDEF  TOP
        dbSetIndex(cTRBSD3+OrdBagExt())
    #ENDIF
    dbSetOrder(nInd+1)
EndIf
dbSeek(cFilial+SB1->B1_COD+If(lCusUnif.Or.lLocProc,"",aParam[9])+dtos(dCntData),.T.)

While .T.
    cSeqIni := ""
    cAlias  := ""
    IncProc()
    
    dbSelectArea("SD1")
    Do While !Eof() .AND. D1_FILIAL == cFilial .AND. D1_DTDIGIT == dCntData .AND. D1_COD == SB1->B1_COD .AND. If(lCusUnif,.T.,D1_LOCAL == aParam[9])
        If D1_ORIGLAN $ "LF"
            dbSkip()
            Loop
        EndIf
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Nao imprimir o produto MANUTENCAO (MV_PRODMNT) qdo integrado com MNT.      ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If lProIsMNT
            If FindFunction("NGProdMNT")
                aProdsMNT := aClone(NGProdMNT("M"))
                If aScan(aProdsMNT, {|x| AllTrim(x) == AllTrim(SD1->D1_COD) }) > 0
                    dbSkip()
                    Loop
                EndIf
            ElseIf AllTrim(SD1->D1_COD) == AllTrim(cProdMNT)
                dbSkip()
                Loop
            EndIf
        EndIf
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Despreza Notas Fiscais com Remitos                           ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If cPaisloc<>"BRA" .AND. !Empty(D1_REMITO)
            dbSkip()
            Loop
        EndIf
        SF4->(dbSeek(cFilial+SD1->D1_TES))
        If lIxbConTes
            If Empty(SD1->D1_TES) //Nao processar Pre-Nota
                dbSkip()
                Loop
            EndIf
        Else
            If SF4->F4_ESTOQUE # "S"
                dbSkip()
                Loop
            EndIf
        EndIf
        cSeqIni  := If(1==1,D1_NUMSEQ,D1_SEQCALC+D1_NUMSEQ)
        cAlias   := Alias()
        aAdd(aDados,{cAlias,dCntData,cSeqIni,Recno(),.F.,""})
        dbSkip()
        Loop
    EndDo
    
    dbSelectArea("SD3")
    Do While !Eof() .AND. D3_FILIAL == cFilial .AND. D3_EMISSAO == dCntData .AND. D3_COD == SB1->B1_COD .AND. If(lCusUnif.Or.lLocProc,.T.,D3_LOCAL == aParam[9])
        If !D3Valido()
            dbSkip()
            Loop
        EndIf
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Nao imprimir os produtos que estao no armazem de transito                  ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If cPaisLoc <> "BRA" .And. !lTranSB2 .And. AllTrim(SD3->D3_LOCAL) == AllTrim(cDepTrf)
            dbSkip()
            Loop
        EndIf
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Nao imprimir o produto MANUTENCAO (MV_PRODMNT) qdo integrado com MNT.      ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If lProIsMNT
            If FindFunction("NGProdMNT")
                aProdsMNT := aClone(NGProdMNT("M"))
                If aScan(aProdsMNT, {|x| AllTrim(x) == AllTrim(SD3->D3_COD) }) > 0
                    dbSkip()
                    Loop
                EndIf
            ElseIf AllTrim(SD3->D3_COD) == AllTrim(cProdMNT)
                dbSkip()
                Loop
            EndIf
        EndIf
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Quando movimento ref apropr. indireta, so considera os         ³
        //³ movimentos com destino ao almoxarifado de apropriacao indireta.³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        lInverteMov:=.F.
        If D3_LOCAL <> aParam[9] .Or. lCusUnif
            If !(Substr(D3_CF,3,1) == "3")
                If !lCusUnif
                    dbSkip()
                    Loop
                EndIf
            Else
                lInverteMov:=.T.
            EndIf
        EndIf
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Caso seja uma transferencia de localizacao verifica se lista   ³
        //³ o movimento ou nao                                             ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If 1 == 2 .AND. Substr(D3_CF,3,1) == "4"
            cNumSeqTr := SD3->D3_COD+SD3->D3_NUMSEQ+SD3->D3_LOCAL
            nRegTr    := Recno()
            dbSkip()
            If SD3->D3_COD+SD3->D3_NUMSEQ+SD3->D3_LOCAL == cNumSeqTr
                dbSkip()
                Loop
            Else
                dbGoto(nRegTr)
            EndIf
        EndIf
        cSeqIni  := If(1==1,D3_NUMSEQ,D3_SEQCALC+D3_NUMSEQ)
        cAlias   := Alias()
        aAdd(aDados,{cAlias,dCntData,cSeqIni,Recno(),lInverteMov,If(D3_CF == "RE5","02","")})
        dbSkip()
    EndDo
    dbSelectArea(cAliasSD2)
    Do While !Eof() .AND. (cAliasSD2)->D2_FILIAL == xFilial("SD2") .AND. IIf(lUsaD2DIG, (cAliasSD2)->D2_DTDIGIT, (cAliasSD2)->D2_EMISSAO) == IIf(lQuerySD2, DToS(dCntData),dCntData) .AND. (cAliasSD2)->D2_COD == SB1->B1_COD .AND. If(lCusUnif,.T.,(cAliasSD2)->D2_LOCAL == aParam[9])
        If (cAliasSD2)->D2_ORIGLAN $ "LF"
            dbSkip()
            Loop
        EndIf
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Nao imprimir o produto MANUTENCAO (MV_PRODMNT) qdo integrado com MNT.      ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If lProIsMNT
            If FindFunction("NGProdMNT")
                aProdsMNT := aClone(NGProdMNT("M"))
                If aScan(aProdsMNT, {|x| AllTrim(x) == AllTrim((cAliasSD2)->D2_COD) }) > 0
                    dbSkip()
                    Loop
                EndIf
            ElseIf AllTrim((cAliasSD2)->D2_COD) == AllTrim(cProdMNT)
                dbSkip()
                Loop
            EndIf
        EndIf
        If nModulo = 12
            SF2->(dbSetOrder(1))
            If SF2->(dbSeek(xFilial("SF2") + (cAliasSD2)->D2_DOC  + (cAliasSD2)->D2_SERIE + (cAliasSD2)->D2_CLIENTE + (cAliasSD2)->D2_LOJA ))
                If !Empty(SF2->F2_NFCUPOM) .AND. Alltrim(Upper(SF2->F2_ESPECIE)) == Alltrim(Upper(MVNOTAFIS))
                    (cAliasSD2)->(dbSkip())
                    Loop
                EndIf
            EndIf
        EndIf
        
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Despreza Notas Fiscais com Remitos                           ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If cPaisLoc<> "BRA" .AND. !Empty((cAliasSD2)->D2_REMITO)
            If !((cAliasSD2)->D2_TPDCENV $ '1A')
                (cAliasSD2)->(dbSkip())
                Loop
            EndIf
        EndIf
        
        SF4->(dbSeek(cFilial+(cAliasSD2)->D2_TES))
        
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Executa ponto de entrada para verificar se considera TES que ³
        //³ NAO ATUALIZA saldos em estoque.                              ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If lIxbConTes .AND. SF4->F4_ESTOQUE <> "S"
            lTesNEst := ExecBlock("MTAAVLTES",.F.,.F.)
            lTesNEst := If(ValType(lTesNEst) # "L",.F.,lTesNEst)
        EndIf
        If SF4->F4_ESTOQUE # "S" .AND. !lTesNEst
            dbSkip()
            Loop
        EndIf
        cSeqIni  := If(1==1,(cAliasSD2)->D2_NUMSEQ,(cAliasSD2)->D2_SEQCALC+(cAliasSD2)->D2_NUMSEQ)
        cAlias   := "SD2"
        #IFNDEF TOP
            aAdd(aDados,{cAlias,dCntData,cSeqIni,Recno(),.F.,""})
        #ELSE
            aAdd(aDados,{cAlias,dCntData,cSeqIni,(cAliasSD2)->RECSD2,.F.,""})
        #ENDIF
        dbSkip()
    EndDo
    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Caso seja fim de arquivo no SD1, SD2 e SD3 nao continua o    ³
    //³ processamento.                                               ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If SD1->(Eof()) .AND. (cAliasSD2)->(Eof()) .AND. SD3->(Eof())
        Exit
    Endif
    
    If Empty(cAlias)
        dCntData++
    EndIf
    cCondicao:=dCntData>aParam[5]
    If 1==2 .AND. !lCusUnif
        cCondicao:=cCondicao .OR. ( SD1->D1_COD + SD1->D1_LOCAL <> SB1->B1_COD + aParam[9] .AND. ;
        (cAliasSD2)->D2_COD + (cAliasSD2)->D2_LOCAL <> SB1->B1_COD + aParam[9] .AND. ;
        SD3->D3_COD <> SB1->B1_COD )
    Endif
    If cCondicao
        Exit
    EndIf
    
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ordena os registros a serem processados conforme a configuracao |
//³ do parametro mv_par07 (Digitacao ou Calculo).                   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aDados) > 1
    //-- Passado o elemento 6 no array devido a problemas com o aSort
    ASORT(aDados,,, { |x, y| DTOS(x[2])+x[3]+x[6] < DTOS(y[2])+y[3]+y[6] })
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa os registros do Array aDados                           |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For i := 1 to Len(aDados)
    If aDados[i,1] == "SD1"
        dbSelectArea("SD1")
        MsGoto(aDados[i,4])
        If cPaisLoc == "BRA"
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Verifica se o TES atualiza estoque             ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            dbSelectArea("SF4")
            dbSeek(cFilial+SD1->D1_TES)
            dbSelectArea("SD1")
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Executa ponto de entrada para verificar se considera TES que ³
            //³ NAO ATUALIZA saldos em estoque.                              ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If lIxbConTes .AND. SF4->F4_ESTOQUE <> "S"
                lTesNEst := ExecBlock("MTAAVLTES",.F.,.F.)
                lTesNEst := If(ValType(lTesNEst) # "L",.F.,lTesNEst)
            EndIf
            If (SF4->F4_ESTOQUE <> "S" .AND. !lTesNEst)
                Loop
            EndIf
            If D1_TES <= "500"
                aSalAtu[1] += D1_QUANT
                aSalAtu[1+1] += IIF(1=1,D1_CUSTO,&("D1_CUSTO"+Str(1,1,0)))
                aSalAtu[7] += D1_QTSEGUM
                nTotEnt    += D1_QUANT
                nTotvEnt   += IIF(1=1,D1_CUSTO,&("D1_CUSTO"+Str(1,1,0)))
            Else
                aSalAtu[1] -= D1_QUANT
                aSalAtu[1+1] -= IIF(1=1,D1_CUSTO,&("D1_CUSTO"+Str(1,1,0)))
                aSalAtu[7] -= D1_QTSEGUM
                nTotSda    += D1_QUANT
                nTotvSda   += IIF(1=1,D1_CUSTO,&("D1_CUSTO"+Str(1,1,0)))
            EndIf
            
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Calcula o Custo Medio do Produto               ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            nCusmed := CalcCMed(aSalAtu)
            cIdent := If(Empty(D1_OP),D1_FORNECE, D1_OP)
            AddArray({SD1->D1_DTDIGIT,SUBS(SD1->D1_TES,1,3),SD1->D1_CF,SD1->D1_DOC," "," ",cIdent,TRANSF(SD1->D1_QUANT,cPictQT),TRANSF((IIF(1=1,SD1->D1_CUSTO,&("SD1->D1_CUSTO"+Str(1,1,0)))/SD1->D1_QUANT),PesqPict("SB2","B2_CM1")),TRANSF(IIF(1=1,SD1->D1_CUSTO,&("SD1->D1_CUSTO"+Str(1,1,0))),PesqPict("SD1","D1_CUSTO")),SD1->D1_LOTECTL,SD1->D1_NUMLOTE },aDados[i,1])
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Verifica se Lista Localizacao                  ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If 2 == 1
                dbSelectArea("SDB")
                dbSeek(cFilial+SD1->D1_COD+SD1->D1_LOCAL+SD1->D1_NUMSEQ)
                While !Eof() .AND. DB_FILIAL == cFilial .AND. DB_PRODUTO == SB1->B1_COD .AND. If(lCusUnif,.T.,DB_LOCAL == aParam[9]) .AND. DB_NUMSEQ == SD1->D1_NUMSEQ
                    If SDB->DB_ESTORNO == "S"
                        dbSkip()
                        Loop
                    EndIf
                    AddArray({" "," "," "," ",SDB->DB_LOCALIZ,SDB->DB_NUMSERI," ",TRANSF(SDB->DB_QUANT,cPictQT)," "," ",SDB->DB_LOTECTL,SDB->DB_NUMLOTE },aDados[i,1])
                    SDB->(DbSkip())
                EndDo
            EndIf
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Verifica se Lista Saldo item a item            ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If 1 == 1
                AddArray({STR0004," "," "," "," "," "," ",Transf(aSalAtu[1],cPictQT),Transf(nCusMed,PesqPict("SB2","B2_CM1")),Transf(aSalAtu[1+1],PesqPict("SB9","B9_VINI1"))," ", " " },aDados[i,1])
            EndIf
            aAdd(aGraph,{MC030Data("SD1"),aSalAtu[1],nCusMed,aSalAtu[1+1]} )
        Else
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Verifica se o TES atualiza estoque             ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            dbSelectArea("SF4")
            dbSeek(cFilial+SD1->D1_TES)
            dbSelectArea("SD1")
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Executa ponto de entrada para verificar se considera TES que ³
            //³ NAO ATUALIZA saldos em estoque.                              ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If lIxbConTes .AND. SF4->F4_ESTOQUE <> "S"
                lTesNEst := ExecBlock("MTAAVLTES",.F.,.F.)
                lTesNEst := If(ValType(lTesNEst) # "L",.F.,lTesNEst)
            EndIf
            If (SF4->F4_ESTOQUE <> "S" .AND. !lTesNEst)
                Loop
            EndIf
            
            SF1->(DbSetOrder(1))
            SF1->(DbSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA))
            If cPaisLoc != "BRA" .AND. AllTrim(D1_ESPECIE) == "RCN" .AND. !Empty(SF1->F1_HAWB)
                Loop
            EndIf
            
            If D1_TIPO_NF == "5"        //Invoice FOB
                aSaldoExp := MTC03xNFExp(SD1->D1_COD)
                aSalAtu[1] += aSaldoExp[1]
                aSalAtu[1+1] += aSaldoExp[2]
                aSalAtu[7] += aSaldoExp[3]
                nTotEnt    += aSaldoExp[1]
                nTotvEnt   += IIF(1=1,aSaldoExp[2],&("D1_CUSTO"+Str(1,1,0)))
            Else
                If D1_TES <= "500"
                    aSalAtu[1] += D1_QUANT
                    aSalAtu[1+1] += IIF(1=1,D1_CUSTO,&("D1_CUSTO"+Str(1,1,0)))
                    aSalAtu[7] += D1_QTSEGUM
                    nTotEnt    += D1_QUANT
                    nTotvEnt   += IIF(1=1,D1_CUSTO,&("D1_CUSTO"+Str(1,1,0)))
                Else
                    aSalAtu[1] -= D1_QUANT
                    aSalAtu[1+1] -= IIF(1=1,D1_CUSTO,&("D1_CUSTO"+Str(1,1,0)))
                    aSalAtu[7] -= D1_QTSEGUM
                    nTotSda    += D1_QUANT
                    nTotvSda   += IIF(1=1,D1_CUSTO,&("D1_CUSTO"+Str(1,1,0)))
                EndIf
            EndIf
            
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Calcula o Custo Medio do Produto               ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            nCusmed := CalcCMed(aSalAtu)
            
            cIdent := If(Empty(D1_OP),D1_FORNECE, D1_OP)
            
            cDocumento:=SD1->D1_DOC
            AddArray({SD1->D1_DTDIGIT,SD1->D1_TES,If(IsRemito(1,'SD1->D1_TIPODOC'),Substr(GetDescRem(),1,3)," FAC "),cDocumento," "," ",cIdent,TRANSF(SD1->D1_QUANT,cPictQT),TRANSF((IIF(1=1,SD1->D1_CUSTO,&("SD1->D1_CUSTO"+Str(1,1,0)))/SD1->D1_QUANT),PesqPict("SB2","B2_CM1")),TRANSF(IIF(1=1,SD1->D1_CUSTO,&("SD1->D1_CUSTO"+Str(1,1,0))),PesqPict("SD1","D1_CUSTO")),SD1->D1_LOTECTL,SD1->D1_NUMLOTE },aDados[i,1])
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Verifica se Lista Localizacao                  ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If 2 == 1
                dbSelectArea("SDB")
                dbSeek(cFilial+SD1->D1_COD+SD1->D1_LOCAL+SD1->D1_NUMSEQ)
                While !Eof() .AND. DB_FILIAL == cFilial .AND. DB_PRODUTO == SB1->B1_COD .AND. If(lCusUnif,.T.,DB_LOCAL == aParam[9]) .AND. DB_NUMSEQ == SD1->D1_NUMSEQ
                    If SDB->DB_ESTORNO == "S"
                        dbSkip()
                        Loop
                    EndIf
                    AddArray({" "," "," "," ",SDB->DB_LOCALIZ,SDB->DB_NUMSERI," ",TRANSF(SDB->DB_QUANT,cPictQT)," "," " ,SDB->DB_LOTECTL,SDB->DB_NUMLOTE},aDados[i,1])
                    SDB->(dbSkip())
                EndDo
            EndIf
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Verifica se Lista Saldo item a item            ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If 1 == 1
                AddArray({STR0004," "," "," "," "," "," ",Transf(aSalAtu[1],cPictQT),Transf(nCusMed,PesqPict("SB2","B2_CM1")),Transf(aSalAtu[1+1],PesqPict("SB9","B9_VINI1"))," "," " },aDados[i,1])
            EndIf
            aAdd(aGraph,{MC030Data("SD1"),aSalAtu[1],nCusMed,aSalAtu[1+1]} )
        EndIf
    EndIf
    If aDados[i,1] == "SD3"
        dbSelectArea("SD3")
        MsGoto(aDados[i,4])
        If aDados[i,5]  //lInverteMov
            If D3_TM > "500"
                aSalAtu[1] += D3_QUANT
                aSalAtu[1+1] += &("D3_CUSTO"+Str(1,1,0))
                aSalAtu[7] += D3_QTSEGUM
                nTotEnt    += D3_QUANT
                nTotvEnt   += &("D3_CUSTO"+Str(1,1,0))
            Else
                aSalAtu[1] -= D3_QUANT
                aSalAtu[1+1] -= &("D3_CUSTO"+Str(1,1,0))
                aSalAtu[7] -= D3_QTSEGUM
                nTotSda    += D3_QUANT
                nTotvSda   += &("D3_CUSTO"+Str(1,1,0))
            EndIf
        Else
            If D3_TM <= "500"
                aSalAtu[1] += D3_QUANT
                aSalAtu[1+1] += &("D3_CUSTO"+Str(1,1,0))
                aSalAtu[7] += D3_QTSEGUM
                nTotEnt    += D3_QUANT
                nTotvEnt   += &("D3_CUSTO"+Str(1,1,0))
            Else
                aSalAtu[1] -= D3_QUANT
                aSalAtu[1+1] -= &("D3_CUSTO"+Str(1,1,0))
                aSalAtu[7] -= D3_QTSEGUM
                nTotSda    += D3_QUANT
                nTotvSda   += &("D3_CUSTO"+Str(1,1,0))
            EndIf
        EndIf
        cIdent := If(Empty(D3_OP),D3_CC, D3_OP)
        If lMc030Idmv
            cIdent := ExecBlock("MC030IDMV",.F.,.F.,{D3_OP,D3_CC})
        EndIf
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Calcula o Custo Medio do Produto               ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        nCusmed := CalcCMed(aSalAtu)
        AddArray({SD3->D3_EMISSAO,SUBS(SD3->D3_TM,1,3),SD3->D3_CF+If(aDados[i,5],"*",""),SD3->D3_DOC,SD3->D3_LOCALIZ,SD3->D3_NUMSERI,cIdent,TRANSF(SD3->D3_QUANT,cPictQT),TRANSF((&("SD3->D3_CUSTO"+Str(1,1,0))/SD3->D3_QUANT),PesqPict("SB2","B2_CM1")),TRANSF(&("SD3->D3_CUSTO"+Str(1,1,0)),PesqPict("SD1","D1_CUSTO")),SD3->D3_LOTECTL,SD3->D3_NUMLOTE},aDados[i,1])
        
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Verifica se Lista Localizacao                  ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If 2 == 1
            dbSelectArea("SDB")
            dbSeek(cFilial+SD3->D3_COD+SD3->D3_LOCAL+SD3->D3_NUMSEQ)
            While !Eof() .AND. DB_FILIAL == cFilial .AND. DB_PRODUTO == SB1->B1_COD .AND. If(lCusUnif,.T.,DB_LOCAL == aParam[9])    .AND. DB_NUMSEQ == SD3->D3_NUMSEQ
                If SDB->DB_ESTORNO == "S"
                    dbSkip()
                    Loop
                EndIf
                AddArray({" "," "," "," ",SDB->DB_LOCALIZ,SDB->DB_NUMSERI," ",TRANSF(SDB->DB_QUANT,cPictQT)," "," ",SDB->DB_LOTECTL,SDB->DB_NUMLOTE },aDados[i,1])
                SDB->(dbSkip())
            EndDo
        EndIf
        
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Verifica se Lista Saldo item a item            ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If 1 == 1
            AddArray({STR0004," "," "," "," "," "," ",Transf(aSalAtu[1],cPictQT),Transf(nCusMed,PesqPict("SB2","B2_CM1")),Transf(aSalAtu[1+1],PesqPict("SB9","B9_VINI1"))," "," " },aDados[i,1])
        EndIf
        aAdd(aGraph,{MC030Data("SD3"),aSalAtu[1],nCusMed,aSalAtu[1+1]} )
    EndIf
    If aDados[i,1] == "SD2"
        dbSelectArea("SD2")
        MsGoto(aDados[i,4])
        If cPaisLoc == "BRA"
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Verifica se o TES atualiza estoque             ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            dbSelectArea("SF4")
            dbSeek(cFilial+SD2->D2_TES)
            dbSelectArea("SD2")
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Executa ponto de entrada para verificar se considera TES que ³
            //³ NAO ATUALIZA saldos em estoque.                              ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If lIxbConTes .AND. SF4->F4_ESTOQUE <> "S"
                lTesNEst := ExecBlock("MTAAVLTES",.F.,.F.)
                lTesNEst := If(ValType(lTesNEst) # "L",.F.,lTesNEst)
            EndIf
            If (SF4->F4_ESTOQUE <> "S" .AND. !lTesNEst)
                Loop
            EndIf
            
            If D2_TES <= "500"
                aSalAtu[1] += D2_QUANT
                aSalAtu[1+1] += &("D2_CUSTO"+Str(1,1,0))
                aSalAtu[7] += D2_QTSEGUM
                nTotEnt    += D2_QUANT
                nTotvEnt   += &("D2_CUSTO"+Str(1,1,0))
            Else
                aSalAtu[1] -= D2_QUANT
                aSalAtu[1+1] -= &("D2_CUSTO"+Str(1,1,0))
                aSalAtu[7] -= D2_QTSEGUM
                nTotSda    += D2_QUANT
                nTotvSda   += &("D2_CUSTO"+Str(1,1,0))
            EndIf
            
            cIdent := If(Empty(D2_OP),D2_CLIENTE, D2_OP)
            
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Calcula o Custo Medio do Produto               ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            nCusmed := CalcCMed(aSalAtu)
            
            AddArray({IIf(lUsaD2DIG, SD2->D2_DTDIGIT, SD2->D2_EMISSAO),SUBS(SD2->D2_TES,1,3),SD2->D2_CF,SD2->D2_DOC," "," ",cIdent,TRANSF(SD2->D2_QUANT,cPictQT),TRANSF((&("SD2->D2_CUSTO"+Str(1,1,0))/SD2->D2_QUANT),PesqPict("SB2","B2_CM1")),TRANSF(&("SD2->D2_CUSTO"+Str(1,1,0)),PesqPict("SD1","D1_CUSTO")),SD2->D2_LOTECTL,SD2->D2_NUMLOTE },aDados[i,1])
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Verifica se Lista Localizacao                  ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If 2 == 1
                dbSelectArea("SDB")
                dbSeek(cFilial+SD2->D2_COD+SD2->D2_LOCAL+SD2->D2_NUMSEQ)
                While !Eof() .AND. DB_FILIAL == cFilial .AND. DB_PRODUTO == SB1->B1_COD .AND. If(lCusUnif,.T.,DB_LOCAL == aParam[9])    .AND. DB_NUMSEQ == SD2->D2_NUMSEQ
                    If SDB->DB_ESTORNO == "S"
                        dbSkip()
                        Loop
                    EndIf
                    AddArray({" "," "," "," ",SDB->DB_LOCALIZ,SDB->DB_NUMSERI," ",TRANSF(SDB->DB_QUANT,cPictQT)," "," ",SDB->DB_LOTECTL,SDB->DB_NUMLOTE },aDados[i,1])
                    SDB->(dbSkip())
                EndDo
            EndIf
            
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Verifica se Lista Saldo item a item            ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If 1 == 1
                AddArray({STR0004," "," "," "," "," "," ",Transf(aSalAtu[1],cPictQT),Transf(nCusMed,PesqPict("SB2","B2_CM1")),Transf(aSalAtu[1+1],PesqPict("SB9","B9_VINI1"))," ", " " },aDados[i,1])
            EndIf
            aAdd(aGraph,{MC030Data("SD2"),aSalAtu[1],nCusMed,aSalAtu[1+1]} )
        Else
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Verifica se o TES atualiza estoque             ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            dbSelectArea("SF4")
            dbSeek(cFilial+SD2->D2_TES)
            dbSelectArea("SD2")
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Executa ponto de entrada para verificar se considera TES que ³
            //³ NAO ATUALIZA saldos em estoque.                              ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If lIxbConTes .AND. SF4->F4_ESTOQUE <> "S"
                lTesNEst := ExecBlock("MTAAVLTES",.F.,.F.)
                lTesNEst := If(ValType(lTesNEst) # "L",.F.,lTesNEst)
            EndIf
            If (SF4->F4_ESTOQUE <> "S" .AND. !lTesNEst)
                Loop
            EndIf
            
            If D2_TES <= "500"
                aSalAtu[1] += D2_QUANT
                aSalAtu[1+1] += &("D2_CUSTO"+Str(1,1,0))
                aSalAtu[7] += D2_QTSEGUM
                nTotEnt    += D2_QUANT
                nTotvEnt   += &("D2_CUSTO"+Str(1,1,0))
            Else
                aSalAtu[1] -= D2_QUANT
                aSalAtu[1+1] -= &("D2_CUSTO"+Str(1,1,0))
                aSalAtu[7] -= D2_QTSEGUM
                nTotSda    += D2_QUANT
                nTotvSda   += &("D2_CUSTO"+Str(1,1,0))
            EndIf
            
            cIdent := If(Empty(D2_OP),D2_CLIENTE, D2_OP)
            
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Calcula o Custo Medio do Produto               ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            nCusmed := CalcCMed(aSalAtu)
            
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Verifica o pais para verificar o tamanho do documento ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            cDocumento := SD2->D2_DOC
            AddArray({IIf(lUsaD2DIG, SD2->D2_DTDIGIT, SD2->D2_EMISSAO),SD2->D2_TES,If(IsRemito(1,'SD2->D2_TIPODOC'),Substr(GetDescRem(),1,3)," FAC "),cDocumento," "," ",cIdent,TRANSF(SD2->D2_QUANT,cPictQT),TRANSF((&("SD2->D2_CUSTO"+Str(1,1,0))/SD2->D2_QUANT),PesqPict("SB2","B2_CM1")),TRANSF(&("SD2->D2_CUSTO"+Str(1,1,0)),PesqPict("SD1","D1_CUSTO")),SD2->D2_LOTECTL,SD2->D2_NUMLOTE },aDados[i,1])
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Verifica se Lista Localizacao                  ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If 2 == 1
                dbSelectArea("SDB")
                dbSeek(cFilial+SD2->D2_COD+SD2->D2_LOCAL+SD2->D2_NUMSEQ)
                While !Eof() .AND. DB_FILIAL == cFilial .AND. DB_PRODUTO == SB1->B1_COD .AND. If(lCusUnif,.T.,DB_LOCAL == aParam[9])    .AND. DB_NUMSEQ == SD2->D2_NUMSEQ
                    If SDB->DB_ESTORNO == "S"
                        dbSkip()
                        Loop
                    EndIf
                    AddArray({" "," "," "," ",SDB->DB_LOCALIZ,SDB->DB_NUMSERI," ",TRANSF(SDB->DB_QUANT,cPictQT)," "," ",SDB->DB_LOTECTL,SDB->DB_NUMLOTE },aDados[i,1])
                    SDB->(dbSkip())
                EndDo
            EndIf
            
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Verifica se Lista Saldo item a item            ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If 1 == 1
                AddArray({STR0004," "," "," "," "," "," ",Transf(aSalAtu[1],cPictQT),Transf(nCusMed,PesqPict("SB2","B2_CM1")),Transf(aSalAtu[1+1],PesqPict("SB9","B9_VINI1"))," "," " },aDados[i,1])
            EndIf
            aAdd(aGraph,{MC030Data("SD2"),aSalAtu[1],nCusMed,aSalAtu[1+1]} )
        EndIf
    EndIf
Next i

If Len(aTrbTmp)>0
    AADD(aTrbP,aTrbTmp)
    aTrbTmp:={}
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpando os filtros da IndRegua()              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SD1")
dbClearFilter()
#IFDEF TOP
    (cAliasSD2)->( DbCloseArea() )
#ELSE
    dbSelectArea("SD2")
    dbClearFilter()
#ENDIF
dbSelectArea("SD3")
dbClearFilter()

Return aSaldoIni

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NOVO2     ºAutor  ³Microsiga           º Data ³  06/22/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValidPerg(cPerg)

Local _aAlias, aRegs, i:=0, j:=0

_aAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
aRegs:={}
// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
Aadd(aRegs,{cPerg,"01","Data de:","Data de:","Data de:","MV_CH1","D",8,0,0,"G","","MV_PAR01","","","","20130101","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"02","Data Ate:","Data Ate:","Data Ate:","MV_CH2","D",8,0,0,"G","","MV_PAR02","","","","20140625","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"03","Ajusta","Ajusta","Ajusta","MV_CH3","N",1,0,1,"C","","MV_PAR03","SB9 e B2_QFIM","","","","","B2_QATU","","","","","Todos","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"04","Produto de:","Produto de:","Produto de:","MV_CH4","C",15,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","","",""})
Aadd(aRegs,{cPerg,"05","Produto Ate:","Produto Ate:","Produto Ate:","MV_CH5","C",15,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","","",""})
Aadd(aRegs,{cPerg,"06","Armazem","Armazem","Armazem","MV_CH6","C",2,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
    If !dbSeek(cPerg+aRegs[i,2])
        RecLock("SX1",.T.)
        For j:=1 to FCount()
            If j <= Len(aRegs[i])
                FieldPut(j,aRegs[i,j])
            Endif
        Next
        MsUnlock()
    Endif
Next
dbSelectArea(_aAlias)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CPAESTO   ºAutor  ³Microsiga           º Data ³  06/23/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MTC030IsMNT()
Local aArea
Local aAreaSB1
Local aProdsMNT := {}
Local cProdMNT   := ""
Local nX := 0
Local lIntegrMNT := .F.

//Esta funcao encontra-se no modulo Manutencao de Ativos (NGUTIL05.PRX), e retorna os produtos (pode ser MAIS de UM), dos parametros de
//Manutencao - "M" (MV_PRODMNT) / Terceiro - "T" (MV_PRODTER) / ou Ambos - "*" ou em branco
If FindFunction("NGProdMNT")
    aProdsMNT := aClone(NGProdMNT("M"))
    If Len(aProdsMNT) > 0
        aArea    := GetArea()
        aAreaSB1 := SB1->(GetArea())
        
        SB1->(dbSelectArea( "SB1" ))
        SB1->(dbSetOrder(1))
        For nX := 1 To Len(aProdsMNT)
            If SB1->(dbSeek( xFilial("SB1") + aProdsMNT[nX] ))
                lIntegrMNT := .T.
                Exit
            EndIf
        Next nX
        
        RestArea(aAreaSB1)
        RestArea(aArea)
    EndIf
Else //Se a funcao nao existir, processa com o parametro aceitando 1 (UM) Produto
    cProdMNT := GetMv("MV_PRODMNT")
    cProdMNT := cProdMNT + Space(15-Len(cProdMNT))
    If !Empty(cProdMNT)
        aArea    := GetArea()
        aAreaSB1 := SB1->(GetArea())
        SB1->(dbSelectArea( "SB1" ))
        SB1->(dbSetOrder(1))
        If SB1->(dbSeek( xFilial('SB1') + cProdMNT ))
            lIntegrMNT := .T.
        EndIf
        RestArea(aAreaSB1)
        RestArea(aArea)
    EndIf
EndIf
Return( lIntegrMNT )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CalcCMed ³ Autor ³ Paulo Boschetti       ³ Data ³ 22.03.93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula o Custo Medio do Produto                           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpN1 := CalcCMed(ExpA1)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array do saldo atual                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpN1 = custo medio calculado                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CalcCMed(aSalAtu)

Local nCusmed := 0

If QtdComp(aSalAtu[1]) == QtdComp(0)
    nCusMed := 0
Else
    nCusMed := aSalAtu[1+1]/aSalAtu[1]
EndIf

Return nCusmed
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AddArray   ³ Autor ³Armando Pereira Waiteman³ Data ³Set/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Adiciona array mantendo tamanho maximo de elementos por      ³±±
±±³          ³dimensao                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AddArray(ExpA1)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array dos dados dos itens da consulta               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATC030                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AddArray(aItem,cAlias)

Local aRetPE  := {}
Local aItemPE := aClone(aItem)

DEFAULT cAlias := ""

If ExistBlock('MC030ARR')
    aRetPE := ExecBlock('MC030ARR', .F., .F.,{aItemPE,cAlias})
    If ValType(aRetPE) == 'A'
        aItem := aRetPE
    EndIf
EndIf

aAdd(aTrbTmp, aItem)

If Len(aTrbTmp) >= 65000
    AADD(aTrbp,aTrbtmp)
    aTrbTmp:= {}
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MC030Data  ³ Autor ³Marcelo Iuspa          ³ Data ³Set/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Obtem a data a partir do dos arrays aTrbTmp e aTrbP         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpD1 := MC030Data(ExpC1)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arq. de movimento                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpD1 = Data do arq.mov. ou dos arrays aTrbTmp e aTrbP     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATC030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MC030Data(cAlias)
Local dData
Local lUsaD2DIG := IIF(FindFunction("UsaD2DTDIG"), UsaD2DTDIG(), .F.)
Default cAlias  := Nil
If aparam[6]==1 .AND. Len(aTrbTmp) == 0
    dData := aTrbP  [Len(aTrbp)]  [Len(aTrbp[Len(aTrbP)])-1] [1]
ElseIf aparam[6]==1 .AND. Len(aTrbTmp) == 1
    dData := aTrbP  [Len(aTrbp)]  [Len(aTrbp[Len(aTrbP)])-0] [1]
ElseIf aparam[6]==2 .AND. Len(aTrbTmp) == 0
    dData := aTrbP  [Len(aTrbp)]  [Len(aTrbp[Len(aTrbP)])-0] [1]
ElseIf aparam[6]==2 .AND. Len(aTrbTmp) == 1
    dData:=aTrbTmp[Len(aTrbTmp)] [1]
Else
    dData:=aTrbTmp[Len(aTrbTmp)-If(aparam[6]==1,1,0)][1]
Endif
If 2 == 1
    If cAlias == "SD1"
        dData := SD1->D1_DTDIGIT
    ElseIf cAlias == "SD2"
        dData := IIf(lUsaD2DIG, SD2->D2_DTDIGIT, SD2->D2_EMISSAO)
    ElseIf cAlias == "SD3"
        dData := SD3->D3_EMISSAO
    Endif
EndIf

Return(dData)

