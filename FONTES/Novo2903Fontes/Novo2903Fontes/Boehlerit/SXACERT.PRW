#INCLUDE "rwmake.ch"

// Programa para comparar SX6, SX7 e SIX da versao 8 e 10 e apendar os que nao estiverem na versao 10


User Function SXAcert

Private _cTexto := ""

//dbUseArea(.T.,"DBFCDX","\SIGAADV\SIX.DBF","_IX",.T.,.F.)
//dbUseArea(.T.,"DBFCDX","\SIGAADV\SIX010.DBF","SIX",.T.,.F.)

//dbUseArea(.T.,"DBFCDX","\SIGAADV\SX7.DBF","_X7",.T.,.F.)
//dbUseArea(.T.,"DBFCDX","\SIGAADV\SX7010.DBF","SX7",.T.,.F.)

//dbUseArea(.T.,"DBFCDX","\SIGAADV\SX6.DBF","_X6",.T.,.F.)
//dbUseArea(.T.,"DBFCDX","\SIGAADV\SX6010.DBF","SX6",.T.,.F.)

////dbUseArea(.T.,"DBFCDX","\SIGAADV\SX2.DBF","_X2",.T.,.F.)
//dbUseArea(.T.,"DBFCDX","\SIGAADV\SX3.DBF","_X3",.T.,.F.)

dbselectarea("_IX")
dbselectarea("_X7")
dbselectarea("_X6")
dbselectarea("_X2")		              

dbselectarea("_X2")
dbgotop()
ProcRegua(LastRec())
_nCount := 0 
while ! eof()

	_cSeek := _X2->X2_CHAVE
	if ! SX2->(dbseek(_cSeek))
 		reclock("_X2", .f.)
 		_X2->(DBDELETE())  
 		msunlockall()
 		_nCount++

	endif                      
	_X2->(DBSKIP())
Enddo            
Alert(str(_nCount,5,0)+" Registros no SX2 nao existem !")	

SX3->(DBSETORDER(2)) // CAMPO
dbselectarea("_X3")
dbgotop()
ProcRegua(LastRec())
_nCount := 0 
while ! eof()

	_cSeek := _X3->X3_CAMPO
	if ! SX3->(dbseek(_cSeek))
 		reclock("_X3", .f.)
 		_X3->(DBDELETE())  
 		msunlockall()
 		_nCount++

	endif                      
	_X3->(DBSKIP())
Enddo            
Alert(str(_nCount,5,0)+" Registros no SX3 nao existem !")	



RETURN




dbselectarea("_IX")
dbgotop()
ProcRegua(LastRec())
_nCount := 0 
while ! eof()

	_cSeek := _IX->INDICE+_IX->ORDEM
	if ! SIX->(dbseek(_cSeek))
 		reclock("_IX", .f.)
 		_IX->(DBDELETE())  
 		msunlockall()
 		_nCount++

	endif                      
	_IX->(DBSKIP())
Enddo            
Alert(str(_nCount,5,0)+" Registros no SIX nao existem !")	

dbselectarea("_X7")
dbgotop()
ProcRegua(LastRec())
_nCount := 0 
while ! eof()
	_cSeek := _X7->X7_CAMPO+_X7->X7_SEQUENC
	if ! SX7->(dbseek(_cSeek))
 		reclock("_X7", .f.)
 		_X7->(DBDELETE())  
 		msunlockall()
 		_nCount++ 

	endif
	_X7->(DBSKIP())
enddo
Alert(str(_nCount,5,0)+" Registros no Sx7 nao existem !")	
dbselectarea("_X6")
dbgotop()
ProcRegua(LastRec())
_nCount := 0 
_nFalta	:= 0
while ! eof()          
	_cSeek := "  "+_X6->X6_VAR
	if ! SX6->(dbseek(_cSeek))
 		reclock("_X6", .f.)
 		_X6->(DBDELETE())  
 		msunlockall()
		_nFalta++
 	else
 		if SX6->X6_CONTEUD # _X6->X6_CONTEUD
 			_nCount++  
 			_cTexto += padr(_X6->X6_VAR,20)+".......v10 -> "+ alltrim(SX6->X6_CONTEUD)
 			_cTexto +=  "........v8 -> "+ alltrim(X6Conteud())+chr(13)+chr(10)
 			_cTexto += chr(13)+chr(10)
 		endif
	endif	
	_X6->(DBSKIP())
enddo

Alert(str(_nCount,5,0)+" Registros no SX6 divergentes !")	
Alert(str(_nFalta,5,0)+" Registros no SX6 nao encontrados !")	
Alert(_cTexto)      

_X6->(DBclosearea())
_X7->(DBclosearea())
_IX->(DBclosearea())
return NIL
