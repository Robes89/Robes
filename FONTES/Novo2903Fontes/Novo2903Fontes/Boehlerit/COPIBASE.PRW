#include "rwmake.ch"

User Function COPIBASE()

Processa( {|| RunProc() } , "Cópia da Base" )

Return NIL

****************************************************************************************
Static Function RunProc()

//dbUseArea(.T.,"DBFCDX","\SIGAADV\SX2010.DBF","TRX",.T.,.F.)
dbSelectArea("TRX")
dbGotop()
ProcRegua(LastRec())
do While !Eof() 
	IncProc(X2_ARQUIVO)
	If Select(X2_CHAVE) <> 0 
		dbSelectArea(X2_CHAVE)
		dbGotop()
	//	Copy to "\Buffer\"+TRX->X2_ARQUIVO
	Endif 
	dbSelectArea("TRX")
	dbSkip()
Enddo
Return

