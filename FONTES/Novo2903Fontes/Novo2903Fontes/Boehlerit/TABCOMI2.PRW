#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 15/05/03

// Rotina		: INCLUSAO	
// Descrição	: Cadastro de Faixas de comissao
// Data			: 02/02/05
// Autor        : Daniel Gondran

User Function TABCOMI2()        // incluido pelo assistente de conversao do AP5 IDE em 15/05/03


dbSelectArea("SZ2")
AxCadastro("SZ2","Faixas de Comissao",".T.",".T.")
RetIndex("SZ2")
Return