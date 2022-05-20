#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 15/05/03

// Rotina		: INCLUSAO	
// Descrição	: Cadastro de Faixas de comissao
// Data			: 02/02/05
// Autor        : Daniel Gondran

User Function TABCOMIS()        // incluido pelo assistente de conversao do AP5 IDE em 15/05/03

dbSelectArea("SZ1")
AxCadastro("SZ1","Faixas de Comissao",".T.",".T.")
RetIndex("SZ1")
Return
