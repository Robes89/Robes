#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 15/05/03

// Rotina		: INCLUSAO	
// Descrição	: Cadastro de STATUS DE ESTOQUE BRASIL
// Data			: 10/09/04
// Autor        : Ronaldo Fernandes

User Function TABSTEST()        // incluido pelo assistente de conversao do AP5 IDE em 15/05/03


dbSelectArea("SX5")
cArqInde := 'X5_FILIAL+X5_CHAVE'
IndRegua("SX5",cArqInde,"X5_FILIAL+X5_CHAVE",,"X5_TABELA=='Z2'.AND.X5_FILIAL==XFILIAL()","Selecionando Registros")
AxCadastro("SX5","Tabela de Status de Estoque Brasil",".T.",".T.")
RetIndex("SX5")
Return
