
#Include "Totvs.ch"

/*/{Protheus.doc} FA590AROT
(long_description) Ponto de entrada para a inclusÃ£o de nova opÃ§Ã£o 'envio para cartÃ³rio' na tela de borderÃ´
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

    aAdd(aOpts,{"Borederô > Novo Lote","u_NEWLOTE",0,5}) // Permite a geração de um novo Bordero, conforme paramentros de filtro, para utilização da integração com Cartorio. Sera enviado um Email para o Financeiro.
    aAdd(aOpts,{"Borederô > Manutenção","u_CFGLOTE",0,5}) // Permite chamar rotina padrao de manutenção de borderos.
    aAdd(aOpts,{"Borederô > Remessa","u_CHKLOTE",0,5}) // Permite confirmar um Bordero, apos manutencoes especificas do usuario. Desta forma o bordero estara disponivel para a proxima remessa schedulada.
    aAdd(aOpts,{"Remessa = CRA SP","u_REMLOTE(1)",0,5}) // Ira realizar a integração dos borderos disponiveis com o Cartorio SP. Devera ser Schedulado para as [10:00]
    aAdd(aOpts,{"Confirmação","u_CONFCAR()",0,5})
    aAdd(aOpts,{"Retorno","u_RETCAR()",0,5})
    aAdd(aAux,{"OAB - Cartório Reg. Cobrança",aOpts,0,5})
Return aAux
