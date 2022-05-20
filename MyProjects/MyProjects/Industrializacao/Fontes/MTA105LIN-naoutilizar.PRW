User Function MTA105LIN() 
/*                           
Local _dtemissao:=DTOS(aCols[n][Ascan(aHeader,{|x|AllTrim(x[2])=="CP_DATPRF"})]) 
Local _funcion  :=aCols[n][Ascan(aHeader,{|x|AllTrim(x[2])=="CP_FUNCION"})]  
Local _produto  :=aCols[n][Ascan(aHeader,{|x|AllTrim(x[2])=="CP_PRODUTO"})]
Local _grupo    := posicione('SB1',1,xFilial('SB1')+_PRODUTO,"B1_GRUPO")                      
Local _trunifo:=.t.
LOCAL _datasol:=Ctod(" / / ")
Local _cDados1 := CriaTrab(NIL,.F.)
Local _cDados2 := CriaTrab(NIL,.F.)
Local _devol:=Ctod(" / / ")    
LOCAL _TPCAR
aArea := GetArea()

cQuery := "SELECT MAX(CP_DATPRF) CP_DATPRF"
cQuery += "FROM "+RetSqlName("SCPZ")+" SCP "
cQuery += "WHERE SCP.CP_FILIAL='"+xFilial("SCP")+"' AND "
cQuery +=       "SCP.CP_FUNCION='" +_FUNCION  + "' AND "
cQuery +=       "SCP.CP_PRODUTO='" +_PRODUTO  + "' AND "
cQuery +=       "SCP.D_E_L_E_T_<>'*' "
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),_cDados1,.T.,.T.)

While !Eof()       

	_datasol:=stod((_cDados1)->CP_DATPRF)              
    
    _TPCAR:=POSICIONE("SB1",1,xFilial("SB1")+_PRODUTO,"B1_TPCAR")

	If  STOD((_cDados1)->CP_DATPRF) + _TPCAR >=DDATABASE .And. Substr(_grupo,1,2)$Alltrim(GETMV("MV_GRUUNI")) 
		
				
		cQuery1 := "SELECT D3_FILIAL,D3_FUNCION,D3_SA,D3_COD"
		cQuery1 += "FROM "+RetSqlName("SD3")+" SD3 "
		cQuery1 += "INNER JOIN " + RETSQLNAME ("SCP")+ " SCP " 
		cQuery1 += "ON SD3.D3_FILIAL+SD3.D3_FUNCION+SD3.D3_SA+SD3.D3_COD = SCP.CP_FILIAL+SCP.CP_FUNCION+SCP.CP_NUM+SCP.CP_PRODUTO" 
		cQuery1 += "WHERE " 
		cQuery1 += "SD3.D_E_L_E_T_='' AND "
		cQuery1 += "SCP.D_E_L_E_T_='' AND "
		cQuery1 += "SD3.D3_FUNCION='" +_FUNCION  + "' AND "
		cQuery1 += "SD3.D3_COD='" +_PRODUTO  + "' "
		cQuery1 := ChangeQuery(cQuery1)
   		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery1),_cDados2,.T.,.T.)
   
		trunifo:=.F.
		
		While !Eof()       
        	_trunifo:=.T.
		    dBSKIP()
        eND
        
        If !_trunifo                                                                                                 
	   		MsgStop("Solicitação de uniforme invalida, funcionário dentro do período de carência")       
        Endif

	Endif
	DbselectArea(_cDados1)
	dbSkip()                                
END
dbCloseArea() 

RestArea(aArea)  
Return(_trunifo)        

*/
RETURN()


