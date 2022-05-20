#include "rwmake.ch"
User Function A650PRCP()

Local	aArea_SG1	:= SG1->( GetArea() )

lRet  := .T.
aprod := {}
Set SoftSeek Off

dbSelectArea("SG1")
dbSetOrder(1)
If !dbSeek(xFilial("SG1") + SC6->C6_PRODUTO)
	lRet := .F.
	Alert ("Não pode gerar OP. Produto " + AllTrim(SC6->C6_CODLMT) + " sem estrutura cadastrada")
Endif

RestArea( aArea_SG1 )

Return (lRet)