#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 15/05/03

// Rotina		: INCLUSAO	
// Descrição	: Cadastro de GRUPO FABRICANTE
// Data			: 10/09/04
// Autor        : Ronaldo Fernandes

User Function TABGRFAB()        // incluido pelo assistente de conversao do AP5 IDE em 15/05/03


dbSelectArea("SX5")
cArqInde := 'X5_FILIAL+X5_CHAVE'
IndRegua("SX5",cArqInde,"X5_FILIAL+X5_CHAVE",,"X5_TABELA=='Z1'.AND.X5_FILIAL==XFILIAL()","Selecionando Registros")
AxCadastro("SX5","Grupo Fabricante",".T.",".T.")
RetIndex("SX5")
Return
