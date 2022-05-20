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
USER FUNCTION gerasb2()

	SetPrvt("CPERG,NOPC,CCADASTRO,aRegs")
	Private nOpc      := 0
	Private cCadastro := "Exportação de dados - Estoque"
	Private aSay      := {}
	Private aButton   := {}
	Private _PEDNUM  := ""
	Private _DIRTXT    := "ESTMAT.TXT"
	@ 0,0 TO 200,440 DIALOG oDlg TITLE "Hershe's"
    @03,08 Say "Geracao de Arquivo Texto" SIZE 100,140
    @20,08 Say "Este programa ira gerar um" SIZE 100,140
    @30,08 Say "Um arquivo texto, com os" SIZE 100,140
    @40,08 Say "os registros da tabela de:" SIZE 100,140
    @50,08 Say "Produtos (SB1)e Saldos (SB2). " SIZE 100,140
	@70,08 GET _DIRTXT pict "@x" SIZE 120,100
	@080,140 BMPBUTTON TYPE 1 ACTION Close(oDlg)
	ACTIVATE MSDIALOG oDlg CENTERED

	aAdd( aSay, "Esta Rotina Irá Gerar o Arq. "+ALLTRIM(_DIRTXT)+" da Tabela: Estoque." )

	aAdd( aButton, { 1,.T.,{|| nOpc := 1,FechaBatch()}})
	aAdd( aButton, { 2,.T.,{|| FechaBatch() }} )

	FormBatch( cCadastro, aSay, aButton )

	If nOpc == 1
		Processa( {|| Continua() }, "Processando..." )
	Endif

Return

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

Static Function Continua()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o arquivo texto                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//cArq := "C:\NY\TXT_NFS.TXT"
mv_par05 :=	"c:\estmat.txt"
mv_par06 := CHR(13)+CHR(10)
mv_par06 := AllTrim(mv_par06)
nHdl := fCreate(mv_par05)

If nHdl == -1
   MsgAlert("O arquivo de nome "+mv_par05+" nao pode ser executado! Verifique os parametros.","Atencao!")
   Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio da pesquisa no arquivo de dados                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("SB1")
dbSetOrder(1)

dbSelectArea("SB2")
dbSetOrder(1)
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

	dbSelectArea("SB1")
	dbSeek(xFilial("SB1")+SB2->B2_COD)

    cLin := PADR(SB2->B2_COD,20)+PADR(SB1->B1_LOCPAD,20)+PADR(SB2->B2_LOCAL,20)
    cLin := cLin + PADR(str(SB1->B1_EMAX),20)+PADR(str(SB1->B1_LM),20)
    cLin := cLin + PADR(str(SB2->B2_QFIM),20)+PADR(str(SB2->B2_VFIM1),20)
    cLin := cLin + mv_par06

    If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
       If !MsgAlert("Ocorreu um erro na gravacao do arquivo "+mv_par05+".   Continua?","Atencao!")
          Exit
       Endif
    Endif

	dbSelectArea("SB2")
    dbSkip()
End

fClose(nHdl)

MostraErro()

MsgInfo("Processo finalizado")

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³VALIDPERG ³ Autor ³  Luiz Carlos Vieira   ³ Data ³ 18/11/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica as perguntas inclu¡ndo-as caso n„o existam        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Espec¡fico para clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ValidPerg
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,6)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01","Do Titulo          ?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","At‚ o Titulo       ?","mv_ch2","C",06,0,0,"G","","mv_par02","","ZZZZZZ","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Da Emiss„o         ?","mv_ch3","D",08,0,0,"G","","mv_par03","","'01/01/97'","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","At‚ a Emiss„o      ?","mv_ch4","D",08,0,0,"G","","mv_par04","","'31/12/97'","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Nome do Arquivo    ?","mv_ch5","C",12,0,0,"G","","mv_par05","","DEFAULT.TXT","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"06","Final de Linha     ?","mv_ch6","C",30,0,0,"G","","mv_par06","","CHR(13)+CHR(10)","","","","","","","","","","","",""})
/*
Aadd(aRegistros,{"RCO110","01","Do Pedido ?          ","Do Pedido ?          ","Do Pedido ?          ","mv_ch1","C",06,0,1,"G","","mv_par01","             ","             ","             ","","","               ","               ","               ","","","         ","         ","         ","","","       ","       ","       ","","","       ","       ","       ","","",""})
Aadd(aRegistros,{"RCO110","02","Ate o Pedido ?       ","Ate o Pedido ?       ","Ate o Pedido ?       ","mv_ch2","C",06,0,1,"G","","mv_par02","             ","             ","             ","","","               ","               ","               ","","","         ","         ","         ","","","       ","       ","       ","","","       ","       ","       ","","",""})
Aadd(aRegistros,{"RCO110","03","A partir da Data ?   ","A partir da Data ?   ","A partir da Data ?   ","mv_ch3","D",08,0,1,"G","","mv_par03","             ","             ","             ","","","               ","               ","               ","","","         ","         ","         ","","","       ","       ","       ","","","       ","       ","       ","","",""})
Aadd(aRegistros,{"RCO110","04","Ate a Data ?         ","Ate a Data ?         ","Ate a Data ?         ","mv_ch4","D",08,0,1,"G","","mv_par04","             ","             ","             ","","","               ","               ","               ","","","         ","         ","         ","","","       ","       ","       ","","","       ","       ","       ","","",""})
Aadd(aRegistros,{"RCO110","05","Somente os novos ?   ","Somente os novos ?   ","Somente os novos ?   ","mv_ch5","N",01,0,1,"C","","mv_par05","Sim          ","Sim          ","Sim          ","","","Nao            ","Nao            ","Nao            ","","","         ","         ","         ","","","       ","       ","       ","","","       ","       ","       ","","",""})
Aadd(aRegistros,{"RCO110","06","Descricao Produto ?  ","Descricao Produto ?  ","Descricao Produto ?  ","mv_ch6","C",10,0,1,"G","","mv_par06","             ","             ","             ","","","               ","               ","               ","","","         ","         ","         ","","","       ","       ","       ","","","       ","       ","       ","","",""})
Aadd(aRegistros,{"RCO110","07","Qual Unid. de Med. ? ","Qual Unid. de Med. ? ","Qual Unid. de Med. ? ","mv_ch7","N",01,0,1,"C","","mv_par07","Primaria     ","Primaria     ","Primaria     ","","","Secundaria     ","Secundaria     ","Secundaria     ","","","         ","         ","         ","","","       ","       ","       ","","","       ","       ","       ","","",""})
Aadd(aRegistros,{"RCO110","08","Imprime ?            ","Imprime ?            ","Imprime ?            ","mv_ch8","N",01,0,1,"C","","mv_par08","Pedido Compra","Pedido Compra","Pedido Compra","","","Aut. de Entrega","Aut. de Entrega","Aut. de Entrega","","","         ","         ","         ","","","       ","       ","       ","","","       ","       ","       ","","",""})
Aadd(aRegistros,{"RCO110","09","Numero de Vias ?     ","Numero de Vias ?     ","Numero de Vias ?     ","mv_ch9","N",02,0,1,"G","","mv_par09","             ","             ","             ","","","               ","               ","               ","","","         ","         ","         ","","","       ","       ","       ","","","       ","       ","       ","","",""})
Aadd(aRegistros,{"RCO110","10","Imprime Pedidos ?    ","Imprime Pedidos ?    ","Imprime Pedidos ?    ","mv_cha","N",01,0,1,"C","","mv_par10","Liberados    ","Liberados    ","Liberados    ","","","Bloqueados     ","Bloqueados     ","Bloqueados     ","","","Ambos    ","Ambos    ","Ambos    ","","","       ","       ","       ","","","       ","       ","       ","","",""})
Aadd(aRegistros,{"RCO110","11","Considera SCs ?      ","Considera SCs ?      ","Considera SCs ?      ","mv_chb","N",01,0,1,"C","","mv_par11","Firmes       ","Firmes       ","Firmes       ","","","Previstas      ","Previstas      ","Previstas      ","","","Ambas    ","Ambas    ","Ambas    ","","","       ","       ","       ","","","       ","       ","       ","","",""})
Aadd(aRegistros,{"RCO110","12","Qual a Moeda ?       ","Qual a Moeda ?       ","Qual a Moeda ?       ","mv_chc","N",01,0,1,"C","","mv_par12","Moeda 1      ","Moeda 1      ","Moeda 1      ","","","Moeda 2        ","Moeda 2        ","Moeda 2        ","","","Moeda 3  ","Moeda 3  ","Moeda 3  ","","","Moeda 4","Moeda 4","Moeda 4","","","Moeda 5","Moeda 5","Moeda 5","","",""})
Aadd(aRegistros,{"RCO110","13","Endereco de Entrega ?","Endereco de Entrega ?","Endereco de Entrega ?","mv_chd","C",40,0,1,"G","","mv_par13","             ","             ","             ","","","               ","               ","               ","","","         ","         ","         ","","","       ","       ","       ","","","       ","       ","       ","","",""})
Aadd(aRegistros,{"RCO110","14","Lista Quais ?        ","Lista Quais ?        ","Lista Quais ?        ","mv_che","N",01,0,1,"C","","mv_par14","Todos        ","Todos        ","Todos        ","","","Em Aberto      ","Em Aberto      ","Em Aberto      ","","","Atendidos","Atendidos","Atendidos","","","       ","       ","       ","","","       ","       ","       ","","",""})
Aadd(aRegistros,{"RCO110","15","Enviar por Email ?   ","Enviar por Email ?   ","Enviar por Email ?   ","mv_chf","N",01,0,1,"C","","mv_par15","Sim          ","Sim          ","Sim          ","","","Nao            ","Nao            ","Nao            ","","","         ","         ","         ","","","       ","       ","       ","","","       ","       ","       ","","",""})
*/
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

dbSelectArea(_sAlias)

Return
