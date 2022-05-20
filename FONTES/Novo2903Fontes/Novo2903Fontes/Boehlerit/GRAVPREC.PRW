#INCLUDE "rwmake.ch"       

// Rotina		: GRAVPREC
// Descrição	: Grava preco do DA1_PRCVEN para o SB1->B1_PRV1
// Data			: 14/06/05
// Autor        : Daniel Gondran

User Function GRAVPREC()
RecLock("SB1",.F.)
SB1->B1_PRV1 := M->DA1_PRCVEN
msUnlock()
dbSelectArea("DA1")
Return(.T.)