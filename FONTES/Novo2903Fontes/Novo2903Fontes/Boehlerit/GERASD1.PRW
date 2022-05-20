#INCLUDE "rwmake.ch"
#include "topconn.ch"
#Include "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Prog ³ GERATXT  º Autor ³ Paulo Cesar T Oliveira º Data ³Thu  18/06/07º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Programa de exemplo para geracao de um arquivo .TXT        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Espec¡fico para clientes Microsiga                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da tela                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
USER FUNCTION gerasd1()

    Private _cString := "SD1"

    Private _wdata := ctod("  /  /  ")
    Private _wdata1 := ctod("  /  /  ")
    Private oDlga
    //157,50 to 190,230
    DEFINE MSDIALOG oDlga TITLE "Geracao do Arquivo Movimentação de Materiais" FROM 153,50 to 190,150  //300, 450 TO 100 , 400

    @ 050,015 Say "Data de  " SIZE 40,10 PIXEL of oDlga

    @ 070,015 Say "Data até " SIZE 40,10 PIXEL of oDlga

    @ 050,140 Msget _wData picture "99/99/99" size 70,10  pixel of oDlga //size 70,10 //of oDlga
    @ 070,140 Msget _wData1 picture "99/99/99" size 70,10  pixel of oDlga //size 70,10 //of oDlga

    @ 03,170 BmpButton Type 01 Action OkGeraTrb(_wData,_wData1)
    @ 03,242 BmpButton Type 02 Action KMAnterior()

    _lFechar := .T.

    ACTIVATE MSDIALOG oDlga CENTERED valid _lFechar

Return

static function KMAnterior()

    _lFechar := .f.

    close(oDlga)

RETURN

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Fun‡„o   ³ CONTINUA º Autor ³ Luiz Carlos Vieira º Data ³Tue  16/12/97º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao para continuacao do processamento (na confirmacao)  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Espec¡fico para clientes Microsiga                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function OkGeraTrb(_wData,_wData1 )

    close(oDlga)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o arquivo texto                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//cArq := "C:\NY\TXT_NFS.TXT"
    wStatus := "A"
    wTipomov := "E"
    wUlmes := GETMV("MV_ULMES")
    mv_par05 :=	"c:\movimmat.txt"
    mv_par06 := CHR(13)+CHR(10)
    mv_par06 := AllTrim(mv_par06)
    nHdl := fCreate(mv_par05)

    If nHdl == -1
        MsgAlert("O arquivo de nome "+mv_par05+" nao pode ser executado! Verifique os parametros.","Atencao!")
        Return
        //ds-paul
    Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio da pesquisa no arquivo de dados                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

    dbSelectArea("SC7")
    dbSetOrder(1)

    dbSelectArea("SB2")
    dbSetOrder(1)

    dbSelectArea("SD1")
    dbSetOrder(1)
    SET FILTER TO SD1->D1_DTDIGIT >= _wdata .AND. SD1->D1_DTDIGIT <= _wdata1
    dbGoTop()

    While !EOF()

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Incrementa a regua                                                  ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

        IncProc()

        //ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
        //º Lay-Out do arquivo Texto gerado:                                    º
        //ÌÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹
        //ºCampo       ³ Inicio ³ Tamanho ³ Formato                             º
        //ÇÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶
        //º AH_UNIMED  ³ 001    ³ 02      ³ XXXXXX                              º
        //º AH_DESCPO  ³ 100    ³ 100     ³ XXXXXXXXXXXXXXX                                 º
        //ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

        cLin := PADR(SD1->D1_LOCAL,20)+PADR(SD1->D1_FILIAL,20)+PADR(SD1->D1_TES,20)
        cLin := cLin + PADR(SD1->D1_UM,20)+PADR(SD1->D1_COD,20)+PADR(str(SD1->D1_QUANT),20)
        cLin := cLin + PADR(SD1->D1_LOTEFOR,20)+PADR(wStatus,20)+PADR(wTipomov,20)
        cLin := cLin + PADR(SD1->D1_COD,20)+PADR(SD1->D1_DOC,20)
        dbSelectArea("SC7")
        dbSeek(xFilial("SC7")+SD1->D1_PEDIDO+SD1->D1_ITEMPC)
        IF FOUND()
            cLin := cLin + PADR(SC7->C7_USER,20)
        else
            cLin := cLin + space(20)
        ENDIF
        cLin := cLin + PADR(SD1->D1_FORNECE,20)+PADR(SD1->D1_CC,20)+PADR(SD1->D1_CONTA,20)
        cLin := cLin + PADR(SD1->D1_CODLAN,20)+PADR(STRZERO(0,20),20)+PADR(STRZERO(0,20),20)
        cLin := cLin + PADR(SD1->D1_PEDIDO,20)+PADR(STR(SD1->D1_CUSTO),20)
        cLin := cLin + subs(DTOS(SD1->D1_DTDIGIT),7,2)+"/"+subs(DTOS(SD1->D1_DTDIGIT),5,2)+"/"+subs(DTOS(SD1->D1_DTDIGIT),1,4)
        cLin := cLin + subs(DTOS(wUlmes),7,2)+"/"+subs(DTOS(wUlmes),5,2)+"/"+subs(DTOS(wUlmes),1,4)
        _wAchou := .F.
        dbSelectArea("SB2")
        dbSeek(xFilial("SB2")+SD1->D1_COD+SD1->D1_LOCAL)
        IF FOUND()
            cLin := cLin + PADR(STR(SB2->B2_QFIM),20)
            _wAchou := .T.
        else
            cLin := cLin + space(20)
        ENDIF

        cLin := cLin + PADR(STR(SD1->D1_TOTAL),20)
        if _wAchou
            cLin := cLin + PADR(STR(SB2->B2_VFIM1),20)
        else
            cLin := cLin + space(20)
        endif
        cLin := cLin + mv_par06

        If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
            If !MsgAlert("Ocorreu um erro na gravacao do arquivo "+mv_par05+".   Continua?","Atencao!")
                Exit
            Endif
        Endif

        dbSelectArea("SD1")
        dbSkip()
    EndDo

    fClose(nHdl)

    MostraErro()

    MsgInfo("Processo finalizado")

Return