
#Include "Totvs.ch"

/*/{Protheus.doc} FA590AROT
(long_description) Ponto de entrada para a inclusão de nova opção 'envio para cartório' na tela de borderô
@type  Static Function
@author Juliano Souza 
@since date 08/21
@version version 12.1.25
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references) FINA590
/*/
User Function FA590AROT()
    Local aAux := aClone(ParamIxb[1])
    Local aOpts := {}

    aAdd(aOpts,{"Boreder� > Novo Lote","u_NEWLOTE",0,5}) // Permite a gera��o de um novo Bordero, conforme paramentros de filtro, para utiliza��o da integra��o com Cartorio. Sera enviado um Email para o Financeiro.
    aAdd(aOpts,{"Boreder� > Manuten��o","u_CFGLOTE",0,5}) // Permite chamar rotina padrao de manuten��o de borderos.
    aAdd(aOpts,{"Boreder� > Remessa","u_CHKLOTE",0,5}) // Permite confirmar um Bordero, apos manutencoes especificas do usuario. Desta forma o bordero estara disponivel para a proxima remessa schedulada.
    aAdd(aOpts,{"Remessa = CRA SP","u_REMLOTE(1)",0,5}) // Ira realizar a integra��o dos borderos disponiveis com o Cartorio SP. Devera ser Schedulado para as [10:00]
    aAdd(aOpts,{"Confirma��o","u_CONFCAR()",0,5})
    aAdd(aOpts,{"Retorno","u_RETCAR()",0,5})
    aAdd(aAux,{"OAB - Cart�rio Reg. Cobran�a",aOpts,0,5})
Return aAux
