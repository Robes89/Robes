#INCLUDE "rwmake.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  _Exporta    �Autor  �Ilidio Abreu       � Data �  15/11/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � APAGA OS DADOS DE TODAS AS TABELAS						  ���
���          �                          ���
���			 � 					  ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico  - LMT                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

user function APAGA()

	Private _Arq := ""


	Private cTitulo := "Exportacao de dados "
	Private _cTitulo := ""
	dbselectarea("SX2")
	DBGOTOP()
	DBSEEK("CT6")



	Processa( {|| u__DEL() } , cTitulo )

Return

user function _DEL
	_nCont	:= (RecCount() / 10)
	_Arq    := alltrim(SX2->X2_ARQUIVO)
	_alias	:= substr(_Arq,1,3)
	ProcRegua(RecCount())

	// SetRegua( _nCont )

	While ! SX2->(eof())

		if _alias == "CTK" .or. _alias == "CT2" .or. _alias == "SB9" .or. _alias == "SD2" .or. _alias == "SD1" .or. _alias == "CT1"
			SX2->(dbskip())
			_Arq    := alltrim(SX2->X2_ARQUIVO)
			_alias	:= substr(_Arq,1,3)
			loop
		endif


		dbselectarea(_alias)

		if select() # 0
			_cTit	:= " APAGANDO Tabela "+_Arq+ " - "+ str(RecCount(), 7,0)+ " Registros"
			IncProc(OEMtoAnsi(_cTit))
			IF AbreExcl(_alias)
				ZAP
			ENDIF AbreExcl( )
		endif

		dbclosearea()

		SX2->(dbskip())
		_Arq    := alltrim(SX2->X2_ARQUIVO)
		_alias	:= substr(_Arq,1,3)

	enddo

Return