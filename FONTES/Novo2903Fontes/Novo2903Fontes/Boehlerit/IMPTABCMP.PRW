#INCLUDE "rwmake.ch"
#Include "topconn.ch"
#Include "Protheus.Ch"
#DEFINE ENTER CHR(13) + CHR(10) 

User Function ImpTabCmp()

Private oLeCSV
Private cLinha  := ""
Private cPerg   := "TABPRC"
Private aDados  := {}
Private aDadosPro := {"LINHA","INCONSISTENCIA","PRODUTO"}    
Private DadosPro := {}
Private nItem   := "0001"    
Private mv_par05 := "C:\TEMP\TABELACOMPRA.CSV"

If (nH := FT_FUSE(UPPER(Alltrim(MV_PAR05))) ) == -1
   MsgAlert("ARQUIVO NÃO ENCONTRADO, VERIFIQUE O LOCAL, O NOME SE É TABELAPRECO.CSV!","Atencao!")
   help(" ",1,"NOFILEIMPOR")
   Return
EndIf   

MsgAlert("Início da atualização!","Atencao!")

FT_FUSE(UPPER(Alltrim(MV_PAR05)))
ProcRegua(FT_FLASTREC())
FT_FGOTOP()
FT_FSKIP()

While !FT_FEOF()
	IncProc("Lendo arquivo CSV...")
	
	cLinha := FT_FREADLN()
	
	AADD(aDados,Separa(cLinha,";",.T.))
	
	FT_FSKIP()
EndDo

ProcRegua(Len(aDados))

For i:=1 to Len(aDados)                              
	
	IncProc("Atualizando Tabela de preço de compra - Aguarde...")
	
	If len(aDados[i]) == 0 .or. len(aDados[i]) == 1
	   loop
	Endif   
	
	cCodLmt      := Padr(Alltrim(aDados[i][1]),46)
    cCodInt      := Padr(Alltrim(aDados[i][2]),15)
	nPreco       := aDados[i][3]
	nVar         := ""
    _lFind       := .f.
    For m := 1 to len(nPreco)
	   If substr(nPreco,m,1) == ","
	       nVar += "."
	   ElseIf substr(nPreco,m,1) == "."
	      loop
	   Else
	      nVar += substr(nPreco,m,1)
	   Endif
	Next      
	nPreco := Val(nVar)  
    If  nPreco > 0   
 		//continua
    Else
	   AAdd(DadosPro, {STRZERO(i,5),"PRODUTO COM PREÇO INCONSISTENTE NA PLANILHA",aDados[i][1]})
	   loop
    Endif 
	
    dbSelectArea("SB1")
    dbSetOrder(18)
    If dbSeek(xfilial("SB1")+cCodLmt)
       _lFind       := .t.
    Endif
	If !_lFind   
	   dbSelectArea("SB1")
	   dbSetOrder(1)
	   If !dbSeek(xfilial("SB1")+cCodInt)		

		   	_cQuery := " SELECT * " + ENTER
			_cQuery += " FROM " + RetSQLName("SB1") + " SB1 (NOLOCK) "
			_cQuery += " WHERE B1_FILIAL = '"+ xFilial("SB1") + "' "
			_cQuery += "   AND SB1.D_E_L_E_T_ = ' ' "
			_cQuery += "   AND B1_CAT = '" + ALLTRIM(cCodLmt) + "' "
	
			If Select("TB1") > 0
				dbSelectArea("TB1")
				TB1->(dbCloseArea())
			EndIf
	
			TcQuery _cQuery New Alias "TB1"
			TB1->(dbGoTop())

			If TB1->(!Eof())
	           _cCod := TB1->B1_COD
	           dbSelectArea("SB1")
	           dbSetOrder(1)
	           If dbSeek(xFilial("SB1")+PADR(_cCod,15))
	              _lFind       := .t.
	           Endif
		    Else
		       AAdd(DadosPro, {STRZERO(i,5),"CODIGO DE PRODUTO INEXISTENTE",aDados[i][1]})
		      loop
		    Endif  
			dbSelectArea("TB1")
			TB1->(dbCloseArea())
	    Else
	       _lFind       := .t.
	    Endif
    Else
       _lFind       := .t.
	Endif 
    If _lFind
	      dbSelectArea("SB1")
	      RecLock("SB1",.f.)
	      SB1->B1_PREURO :=  nPreco
	      MsUnLock()
    Endif
Next

MsgAlert("A tabela de Preco de Compra, Campo  B1_PREURO foi atualizado com sucesso!","Atencao!")
cMsg := ""
For i := 1 to len(DadosPro)
   cMsg += "Linha: "+dadospro[i][1]+" Ocorrência: "+dadospro[i][2]+" Produto: "+dadospro[i][3] +ENTER
Next
//Alert(cMsg)
Return


Static Function VerPerg()
cAlias   := Alias()
nXX      := 0
aPerg    := {}

//'C:\RELATO\TABPRECO.CSV'
Aadd( aPerg , { "Codigo da Tabela"             , "C" ,  3 , 0 , "G" , "" , "" , "" , "DA0" } )
Aadd( aPerg , { "Descricao da Tabela"          , "C" , 30 , 0 , "G" , "" , "" , "" , "" } )
Aadd( aPerg , { "Data Início Vigencia"         , "D" ,  8 , 0 , "G" , "" , "" , "" , "" } )
Aadd( aPerg , { "Data Final  Vigencia"         , "D" ,  8 , 0 , "G" , "" , "" , "" , "" } )
Aadd( aPerg , { "Informe caminho e nome Arq"   , "C" , 99 , 0 , "G" , "" , "" , "" , "" } )

For nXX := 1 to Len( aPerg )
	If !SX1->( DbSeek( PADR(cPerg,LEN(SX1->X1_GRUPO)) + Strzero( nXX , 2 ) ) )
		RecLock( "SX1" , .T. )
		SX1->X1_GRUPO     := cPerg
		SX1->X1_ORDEM     := Strzero( nXX , 2 )
		SX1->X1_VARIAVL   := "mv_ch"  + Chr( nXX + 96 )
		SX1->X1_VAR01     := "mv_par" + Strzero( nXX , 2 )
		SX1->X1_PRESEL    := 1
		SX1->X1_PERGUNT   := aPerg[ nXX , 01 ]
		SX1->X1_TIPO      := aPerg[ nXX , 02 ]
		SX1->X1_TAMANHO   := aPerg[ nXX , 03 ]
		SX1->X1_DECIMAL   := aPerg[ nXX , 04 ]
		SX1->X1_GSC       := aPerg[ nXX , 05 ]
		SX1->X1_DEF01     := aPerg[ nXX , 06 ]
		SX1->X1_DEF02     := aPerg[ nXX , 07 ]
		SX1->X1_DEF03     := aPerg[ nXX , 08 ]
		SX1->X1_F3        := aPerg[ nXX , 09 ]
		SX1->( MsUnlock() )
	EndIf
Next nXX

dbSelectArea(cAlias)
Return