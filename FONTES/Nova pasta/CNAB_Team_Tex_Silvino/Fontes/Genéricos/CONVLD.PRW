#include "rwmake.ch"

///--------------------------------------------------------------------------\
//| Fun��o: CONVLD		            										 |
//|--------------------------------------------------------------------------|
//| Descri��o: Fun��o para Convers�o da Representa��o Num�rica do C�digo de  |
//|            Barras - Linha Digit�vel (LD) em C�digo de Barras (CB).       |
//|                                                                          |
//|            Para utiliza��o dessa Fun��o, deve-se criar um Gatilho para o |
//|            campo E2_CODBAR, Conta Dom�nio: E2_CODBAR, Tipo: Prim�rio,    |
//|            Regra: EXECBLOCK("CONVLD",.T.), Posiciona: N�o.               |
//|                                                                          |
//|            Utilize tamb�m a Valida��o do Usu�rio para o Campo E2_CODBAR  |
//|            EXECBLOCK("CODBAR",.T.) para Validar a LD ou o CB.            |
//\--------------------------------------------------------------------------/




User function CONVLD()
                      
SETPRVT("cStr","cStr1","cStr2","cStr3")

//If inclui==.T.
   	cStr3 := SUBSTR(M->E2_LINDIG,1,60)   // pega o numero completo com todos os espa�os se houver
   	cStr1 := ALLTRIM(M->E2_LINDIG)       // pega e tira os espa�os do come�o e do fim....
   	cStr2 := STRTRAN(M->E2_LINDIG," ","",1) // transforma o espa�o em vazio
   	cStr  := SUBSTR(cStr2,1,48)     //tem que trazer o numero sem nenhum espa�o
   	cStr := STRTRAN(M->E2_LINDIG," ")
	IF VALTYPE(M->E2_LINDIG) == NIL .OR. EMPTY(M->E2_LINDIG)
		// Se o Campo est� em Branco n�o Converte nada.
		cStr := ""
   //	ELSEIF SE2->E2_LINDIG>48
     //   cStr :=ALLTRIM(SE2->(E2_LINDIG, 1,11)+(E2_LINDIG,13,1)+(E2_LINDIG,15,11)+(E2_LINDIG,27,1)+(E2_LINDIG,29,11)+(E2_LINDIG,41,1)+(E2_LINDIG,43,11)+(E2_LINDIG,55,1))
    
	ELSE
		// Se o Tamanho do String for menor que 44, completa com zeros at� 47 d�gitos. Isso �
		// necess�rio para Bloquetos que N�O t�m o vencimento e/ou o valor informados na LD.
		cStr := IF(LEN(cStr)<44,cStr+REPL("0",47-LEN(cStr)),cStr)
	ENDIF
/*
Else
	cStr := ALLTRIM(SE2->E2_LINDIG)
	IF VALTYPE(SE2->E2_LINDIG) == NIL .OR. EMPTY(SE2->E2_LINDIG)
		// Se o Campo est� em Branco n�o Converte nada.
		cStr := ""
	ELSE
		// Se o Tamanho do String for menor que 44, completa com zeros at� 47 d�gitos. Isso �
		// necess�rio para Bloquetos que N�O t�m o vencimento e/ou o valor informados na LD.
		cStr := IF(LEN(cStr)<44,cStr+REPL("0",47-LEN(cStr)),cStr)
	ENDIF
Endif
*/
DO CASE
CASE LEN(cStr) == 47
	cStr := SUBSTR(cStr,1,4)+SUBSTR(cStr,33,15)+SUBSTR(cStr,5,5)+SUBSTR(cStr,11,10)+SUBSTR(cStr,22,10)
CASE LEN(cStr) == 48
   cStr := SUBSTR(cStr,1,11)+SUBSTR(cStr,13,11)+SUBSTR(cStr,25,11)+SUBSTR(cStr,37,11)
OTHERWISE
	cStr := cStr+SPACE(48-LEN(cStr))
ENDCASE

RETURN(cStr)
                      

