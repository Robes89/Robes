#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 15/05/03

// Rotina		: INCLUSAO	
// Descrição	: Cadastro de GRUPO DE DESCONTO
// Data			: 10/09/04
// Autor        : Ronaldo Fernandes

User Function TABGRDES()        // incluido pelo assistente de conversao do AP5 IDE em 15/05/03


dbSelectArea("SX5")
cArqInde := 'X5_FILIAL+X5_CHAVE'
IndRegua("SX5",cArqInde,"X5_FILIAL+X5_CHAVE",,"X5_TABELA=='Z3'.AND.X5_FILIAL==XFILIAL()","Selecionando Registros")
AxCadastro("SX5","Grupo de Desconto",".T.",".T.")
RetIndex("SX5")
Return
