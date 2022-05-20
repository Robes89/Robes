#include "RWMAKE.CH" 

//-----------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ACD100M
PONTO DE ENTRADA DO ACD.
Chama a Rotina de impressao de etiquetas de Volumes Oficial ou Etiqueta de Embarque a partir de uma Ordem de Separacao.
Por: Luiz Enrique
Padrao DATAMAX
@author Totvs
@since 08/08/2018
@version 1.0
/*/  

User Function ACD100M()

aadd(aRotina,{"Volume/Embarque","U_TEAMESP01()",0,2})  

Return