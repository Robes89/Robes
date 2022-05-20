#include "rwmake.ch"

User Function RGalV01(cCodigo,cAlias,nOrdem,cDesc,cTexto)
	lRetCpo := .T.
	cAlias          := AllTrim(Upper(cAlias))
	cAliasAtu := Alias()
	cNomeCampo:= If(Left(cAlias,1) == "S",Subs(cAlias,2,2),cAlias)+"_ATIVO"
	nCont := 0
	lRetCpo := .T.
	aStruArq := {}
	nPosicao:=0
	cCntCpo := ""
	nOrdemAtu:=0

	dbSelectArea(cAlias)
	nOrdemAtu := IndexOrd()
	dbSetOrder(nOrdem)
	aStruArq := dbStruct(cAlias)

	nPosicao    := Ascan(aStruArq,{|x| AllTrim(x[1]) == cNomeCampo})
	If nPosicao > 0  && So ira checar se existir o campo
		MsSeek(xFilial(cAlias)+cCodigo)
		If !Eof()
			cCntCpo := FieldGet(nPosicao)
			If cCntCpo == "N"
				cDesc := If(!Empty(cDesc)," ("+AllTrim(cDesc)+")","")
//				cCampo	:= cDesc
//				cDesc	:= &(cCampo)
				Aviso("Atenção",AllTrim(cTexto)+" "+AllTrim(cCodigo)+"-"+AllTrim(cDesc)+" esta desabilitado. Não poderá ser utilizado.",{"Ok"})
				lRetCpo := .F.
			EndIf
		Endif
	Endif

	dbSelectArea(cAlias)
	dbSetOrder(nOrdemAtu)

	dbSelectArea(cAliasAtu)
	Return lRetCpo