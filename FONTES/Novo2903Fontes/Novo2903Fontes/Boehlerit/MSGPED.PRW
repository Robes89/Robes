
USER FUNCTION MSGPED()

LOCAL cMSG := ""


DBSELECTAREA("SC5")
DBSETORDER(1) 

DBSELECTAREA("SA4")
DBSETORDER(1) 
DBSEEK( XFILIAL("SA4") ) 



cMSG :=  "Redespacho pela Transportadora: " + SC5->C5_REDESP + ' - ' + SA4->A4_NOME + ' - ' + SA4->A4_CGC  + ' - ' +Alltrim(SA4->A4_END) + ' - ' + Alltrim(SA4->A4_BAIRRO) + ' - ' + Alltrim(SA4->A4_EST) + '.'     
     


RETURN cMSG   



