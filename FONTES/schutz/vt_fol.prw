#include "rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � Assiduid � Autor � Sandra R. Prada       � Data � 08.04.05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria Verba de Pagamento do Premio Assiduidade              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RDMake ( DOS e Windows )                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico para Parmalat                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

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
