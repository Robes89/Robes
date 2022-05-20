#Include "Protheus.ch"
#Include "Totvs.ch"

USer Function NewUserCod()

Local cVal := ''
Local cQry := ''
Local cTab := GetNextAlias()


 cQry := "Select TOP 1 A2_COD from "+ RetSqlNAme("SA2") 
 cQry += " where D_E_L_E_T_ = ' '  and TRIM(A2_COD) NOT IN ('UNIAO','ESTADO','INPS','MUNIC')Order By  A2_COD DESC"

 cQry := ChangeQuery(cQry)

 dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQry),cTab, .F., .T.)

cVal := SomA1((cTab)->A2_COD)

 return cVal 


 USer Function NewCLICod()

Local cVal := ''
Local cQry := ''
Local cTab := GetNextAlias()


 cQry := "Select TOP 1 A2_COD from "+ RetSqlNAme("SA1") 
 cQry += " where D_E_L_E_T_ = ' '  and TRIM(A1_COD) NOT IN ('UNIAO','ESTADO','INPS','MUNIC')Order By  A1_COD DESC"

 cQry := ChangeQuery(cQry)

 dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQry),cTab, .F., .T.)

cVal := SomA1((cTab)->A1_COD)

 return cVal 
