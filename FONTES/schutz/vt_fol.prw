#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ Assiduid ³ Autor ³ Sandra R. Prada       ³ Data ³ 08.04.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria Verba de Pagamento do Premio Assiduidade              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RDMake ( DOS e Windows )                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico para Parmalat                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function VTFOL()

SetPrvt("NPERC_,NVALOR_,cfilial_,nValPrem_")

//Montando Variaveis de Trabalho

nPerc_   := 0
_nPerc   := 0 
nValor_  := 0
cfilial_ := "  "
nValPrem_:= 0

//Processamento

//Localiza Parametros
             

If fBuscapd("747") # 0               

	If SRA->RA_CATFUNC $ "E/G" .or. SRA->RA_CATEFD == "103" .OR. SRA->RA_CODFUNC = '00112'
  	 	_nPERC := 0
	ElseIf (SRA->RA_FILIAL = '010001' .AND. SRA->RA_CODFUNC == '00130') .OR. (SRA->RA_FILIAL = '020001' .AND. SRA->RA_CODFUNC == '00159')
   		_nPERC := 3/100
	Else                                                                 
   		_nPERC := 6/100
	Endif 
Endif                  

If _nPERC > 0
      fGeraVerba("490",min(fbuscapd("747"),(Salmes/30*diastrab*_nPerc)),_nPerc*100,,,,,,,,.T.)
Endif       

Return('')
   
/*


If fBuscapd("759") # 0               

If SRA->RA_CATFUNC $ "E/G" .or. SRA->RA_CATEFD == "103" .OR. SRA->RA_CODFUNC = '00112'
   fdelpd("759")                                            
Endif    
   
   If (SRA->RA_FILIAL = '010001' .AND. SRA->RA_CODFUNC == '00130') .OR. (SRA->RA_FILIAL = '020001' .AND. SRA->RA_CODFUNC == '00159')
      fGeraVerba("490",fbuscapd("759")/2,fbuscapd("759","H"),,,,,,,,.T.)
   Else                                                                 
      fGeraVerba("490",fbuscapd("759"),fbuscapd("759","H"),,,,,,,,.T.)
   Endif 
      
Endif 	  

Return('')
*/     
