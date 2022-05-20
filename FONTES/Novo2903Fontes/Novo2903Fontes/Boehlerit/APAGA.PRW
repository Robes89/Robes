#INCLUDE "rwmake.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  _Exporta    ºAutor  ³Ilidio Abreu       º Data ³  15/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ APAGA OS DADOS DE TODAS AS TABELAS						  º±±
±±º          ³                          º±±
±±º			 ³ 					  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico  - LMT                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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