/*/{Protheus.doc}''
''
@author Sergio Celestino
@since ''
@version ''
@type function
@see ''
@obs  ''
@param ''
@return '' 
/*/

Function u_COMCOLRT

Local aRot := Paramixb[1]

aAdd(aRot,{"Imprimir Danfe" ,"u_DANFEXML()",0,2,0,.F.})
aAdd(aRot,{"Imprimir DACTE" ,"u_RTMSR27()" ,0,2,0,.F.})
aAdd(aRot,{"Exportar Xmls"  ,"u_EXPORXML()",0,2,0,.F.})

Return aRot
