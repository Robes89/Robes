/*/{Protheus.doc} User Function MTALCALT
    (long_description)
    @type  Function
    @author Pirolo
    @since 07/05/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function MTALCALT()

If IsIncallStack("CNTA121") .and. (ALTERA .OR. INCLUI)
    //Chama o antigo PE por onde eram enviados os WFs customizados.
    U_CN130PGRV()
EndIf

Return 
