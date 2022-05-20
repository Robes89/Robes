#Include "FWMVCDef.Ch"
#include 'protheus.ch'
#include 'Totvs.ch'


//-------------------------------------------------------------------
/*/{Protheus.doc} OABTMPCO
Calculo do tempo de contribui��o

@author Philip Pellegrini

@since 31/12/2020
/*/
//-------------------------------------------------------------------

User Function OABTMPCO()

	Local DtCad    		 //Data Inicial do Cadastro
	Local DtHoj    := Date() //Data atual
	Local nTPTot   := 0	     //Tempo total de cadastro DIAS
	Local nTPdesc  := 0	     //Tempo para se desconsiderar DIAS
	Local nDiasCon := 0		 //Tempo de contribui��o Em dias
	Local cQuery   := ''
	Local cAls1   := GetNextAlias()
	Local nSomaDias := 0

	dbSelectArea("SA1")
	dbSetOrder(1)

	While SA1->(!Eof()) 

		DtCad := SA1->A1_DTINSC           

		nTPTot := DateDiffDay( DtCad , DtHoj ) 
		nSomaDias := 0 
		
		cQuery := ''
		
		//Procuro as datas j� encerradas
		cQuery += " SELECT SZB_DTINI, SZB_DTFIM  FROM SZB
		cQuery += " WHERE (SZB_CODIGO = '000001' OR SZB_CODIGO = '000003') ""
		cQuery += " AND SZB_CODCLI = '"  + SA1->A1_COD + "' "
		cQuery += " AND SZB_DTFIM = <> '' "

		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAls1, .F., .T. )

		While (cAls1)->(!Eof())
			nSomaDias += DateDiffDay((cAls1)->SZB_DTINI, (cAls1)->SZB_DTFIM )
			(cAls1)->(dbSkip())
		End
		 
		//Procuro as datas em aberto 
		
		cQuery += " SELECT SZB_DTINI, SZB_DTFIM  FROM SZB
		cQuery += " WHERE (SZB_CODIGO = '000001' OR SZB_CODIGO = '000003') ""
		cQuery += " AND SZB_CODCLI = '"  + SA1->A1_COD + "' "
		cQuery += " AND SZB_DTFIM =  '' "

		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAls1, .F., .T. )

		While (cAls1)->(!Eof())
			nSomaDias += DateDiffDay((cAls1)->SZB_DTINI, DtHoj )
			(cAls1)->(dbSkip())
		End 
		
		nDiasCon := nTPTot - nSomaDias
		
		nTPContr := nDiasCon / 365
		
		Grava(SA1->A1_COD , nTPContr)
		SA1->(dbSkip)
	End
Return

Static Function Grava(cCod, nTempo)

	dbSelectArea("SA1")
	dbSetOrder(1)
	
	If DbSeek(xFilial("SA1")+cCod)

 		RecLock("SA1",.F.)
    	SA1->A1_XCONTR  := nTempo
    	MsUnlock()
		
	Endif 

Return
