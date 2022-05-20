#INCLUDE "Protheus.ch"

// Funcao de alteracao do conteudo dos parametros, somente para os parametros com inicio igual a MV_FP_
// Wilson J. Santos
// Jan/2009

USER FUNCTION ATUPAR()

LOCAL oDlg := NIL
LOCAL oGet := NIL
LOCAL aCpo := {}
LOCAL cValid := "AllWaysTrue"

PRIVATE aButton := {}
PRIVATE aHeader := {}
PRIVATE aCOLS := {}
PRIVATE aGETS := {}
PRIVATE aRotina := {}
PRIVATE cTitulo := "Parâmetros - Fluxo de Pedidos / Ops"

aObjects :={}; aPosObj  :={}
aSize    :=MsAdvSize()
aInfo    :={aSize[1],aSize[2],aSize[3],aSize[4],3,3}

aAdd(aCpo,"X6_CONTEUD")

aAdd(aButton,{"IMPRESSAO",{||ImpDados()},"Imprimir..."})

aAdd(aRotina,{"","",0,1})
aAdd(aRotina,{"","",0,2})
aAdd(aRotina,{"","",0,3})
aAdd(aRotina,{"","",0,4})
aAdd(aRotina,{"","",0,5})

aAdd(aHeader,{"Parametro","X6_VAR"    ,"@!", 10,0,"","û","C","",""})
aAdd(aHeader,{"Descricao","X6_DESCRIC","@!",100,0,"","û","C","",""})
aAdd(aHeader,{"Conteudo" ,"X6_CONTEUD","@!",250,0,"","û","C","",""})

dbSelectArea("SX6")
dbSetOrder(1)
dbSeek(xFilial()+"MV_FP_")
While !Eof() .And. SubStr(X6_VAR,1,6) == "MV_FP_"
   
   cVar := SX6->X6_VAR
   
   aAdd(aCOLS,{cVar,Trim(X6Descric())+Trim((X6Desc1())),X6Conteud(),.F.})
   dbSkip()
End

AADD(aObjects,{100,020,.T.,.F.,.F.})
AADD(aObjects,{100,100,.T.,.T.,.F.})

aPosObj:=MsObjSize(aInfo,aObjects)

DEFINE MSDIALOG oDlg TITLE cTitulo FROM aSize[7],0 TO aSize[6],aSize[5] OF oDlg PIXEL
oGet:=MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],4,cValid,cValid,"",.T.,aCpo,,,Len(aCOLS))
ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,;
{||Processa({||GrvDados(),"Atualizando dados","Aguarde..."}),oDlg:End()},;
{||oDlg:End()},,;
aButton)

RETURN

/***
 *
 * Funcao de gravacao dos dados, somente os que foram alterados
 *
 */

STATIC FUNCTION GrvDados()

LOCAL cFILSX6 := ""
LOCAL i := 0

ProcRegua(Len(aCOLS))
dbSelectArea("SX6")
dbSetOrder(1)
cFilSX6 := xFilial("SX6")
For i:=1 To Len(aCOLS)
   dbSeek(cFilSX6+aCOLS[i][1])
   If SX6->X6_CONTEUD <> aCOLS[i][3]
      RecLock("SX6",.F.)
         SX6->X6_CONTEUD := aCOLS[i][3]
      MsUnLock("SX6")
   Endif
   IncProc("Aguarde...")
Next i
RETURN

/***
 *
 * Funcao de parametrizacao para impressao dos dados
 *
 * Lay-out de impressao
 * --------------------------------------------------------------------------------
 * PARAMETRO  DESCRICAO                                                  CONTEUDO
 * --------------------------------------------------------------------------------
 * XXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXX   
 * --------------------------------------------------------------------------------
 * 01234567890123456789012345678901234567890123456789012345678901234567890123456789
 * 0         1         2         3         4         5         6         7
 *
 */

STATIC FUNCTION ImpDados()

Local cDesc1  := "Este relatorio ira imprimir os dados como visualizado na tela"        
Local cDesc2  := ""
Local cDesc3  := ""

Private cString  := "SX6"
Private Tamanho  := "M"
Private aReturn  := { "Zebrado",1,"Administracao",2,2,1,"",1 }
Private wnrel    := "ATUPAR"
Private NomeProg := "ATUPAR"
Private nLastKey := 0
Private Limite   := 80
Private Titulo   := "Parametros LMT"
 cPerg    := ""
Private cbCont   := 0
Private cbTxt    := "registro(s) lido(s)"
Private Cabec1   := ""
Private Cabec2   := ""
Private Li       := 80
Private m_pag    := 1
Private aOrd     := {}
Private Cabec1   := "PARAMETRO  DESCRICAO                                                  CONTEUDO"
Private Cabec2   := ""
Private nTipo    := 0

wnrel := SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,.F.,.F.)

If nLastKey == 27
   Return
Endif

SetDefault(aReturn,cString)
nTipo := Iif(aReturn[4] == 1, 15, 18)

If nLastKey == 27
   Return
Endif

RptStatus({|lEnd|RelImp(@lEnd,wnrel,cString) },"Preparando impressão", "Aguarde...",.T.)

RETURN

/***
 *
 * Funcao de impressao dos dados
 *
 */

STATIC FUNCTION RelImp(lEnd,WnRel,cString)

LOCAL aCol := {}

aAdd(aCol,0)
aAdd(aCol,11)
aAdd(aCol,70)

For i:=1 To Len(aCOLS)

   If lEnd
      MsgInfo(cCancel,cTitulo)
      Exit
   Endif
   
   If Li > 55
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
   Endif
   
   @ Li,aCol[1] PSay SubStr(aCOLS[i][1],1,10)
   @ Li,aCol[2] PSay SubStr(aCOLS[i][2],1,58)
   @ Li,aCol[3] PSay aCOLS[i][3]
   
   cbCont++
   Li ++

Next i
           
If Li <> 80
   Roda(cbCont,cbTxt,Tamanho)
Endif

If aReturn[5] == 1
   Set Printer TO
   dbCommitAll()
   Ourspool(wnrel)
EndIf

Ms_Flush()

RETURN
