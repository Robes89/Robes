#include "totvs.ch"

// Autor: Guilherme Ricci - TOTVS IP
// Data:  15/05/2017
// Condicao para gatilho da danone para tratar data de validade de acordo com codigo do lote.

User Function GatVlDan()

Return !Empty(gdFieldGet("D1_LOTECTL",n)) .and. SB1->B1_GRUPO == "0007"                                                                  