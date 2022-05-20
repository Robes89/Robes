User Function MA650FIL
//Local aArea	:= GetArea() 
Local cCond:=''
//Pergunte("MTA651",.F.)
//SA1->(DbsetOrder(1))
//SA1->(Dbseek(xFilial("SA1")+SC6->C6_CLI+SC6->C6_LOJA))
cCond:='Dtos(C6_DTSAIDA)>="'+Dtos(MV_PAR27)+'".And. '      
cCond+='Dtos(C6_DTSAIDA)<="'+Dtos(MV_PAR28)+'" ' 
//RestArea(aArea)
return(cCond)