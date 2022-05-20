#INCLUDE "rwmake.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  _Exporta    ºAutor  ³Ilidio Abreu       º Data ³  15/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exporta todos os conteudos das tabelas inscritas no SX2    º±±
±±º          ³ para uma area de de transferencia.                         º±±
±±º			 ³ Apos roda-la, usar o IMPORT do MPSDU						  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico  - LMT                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

user function Exporta()

	Private _Arq := ""


	Private cTitulo := "Exportacao de dados "
	Private _cTitulo := ""
	dbselectarea("SX2")
	DBSEEK("SRA")


	Processa( {|| u__copia() } , cTitulo )

RETURN

user function _copia()
	_nCont	:= (RecCount() / 10)
	_Arq    := alltrim(SX2->X2_ARQUIVO)
	_alias	:= substr(_Arq,1,3)
	ProcRegua(RecCount())

	// SetRegua( _nCont )

	While ! SX2->(eof())

		dbselectarea(_alias)

		if select() # 0  .or. _alias == "EX8"
			_cTit	:= " Copiando Tabela "+_Arq+ " - "+ str(RecCount(), 7,0)+ " Registros"
			IncProc(OEMtoAnsi(_cTit))
			inkey(.01)
			_grava()
		endif

		dbclosearea()

		SX2->(dbskip())
		_Arq    := alltrim(SX2->X2_ARQUIVO)
		_alias	:= substr(_Arq,1,3)

	enddo

RETURN

//_____________________________
static function _grava()

	_destino:="\sigaadv\Ilidio\"+_Arq+".dbf"
	if ! file(_destino)
		//copy to &_destino.
	endif

Return Nil
