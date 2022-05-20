#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 15/05/03

// Rotina		: INCLUSAO	
// Descrição	: Cadastro de STATUS DE ESTOQUE FORNECEDOR
// Data			: 18/10/04
// Autor        : Ronaldo Fernandes

User Function TABSTES1()        // incluido pelo assistente de conversao do AP5 IDE em 15/05/03


dbSelectArea("SX5")
cArqInde := 'X5_FILIAL+X5_CHAVE'
IndRegua("SX5",cArqInde,"X5_FILIAL+X5_CHAVE",,"X5_TABELA=='Z4'.AND.X5_FILIAL==XFILIAL()","Selecionando Registros")
AxCadastro("SX5","Tabela de Status de Estoque Fornecedor",".T.",".T.")
RetIndex("SX5")
Return
