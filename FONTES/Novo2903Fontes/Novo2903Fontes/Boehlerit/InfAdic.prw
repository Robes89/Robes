#INCLUDE "PROTHEUS.CH"   

//////////// customização -  Informações Adicionais - Cliente TekSid ///////////////


User function xInfAdic()
Local xnz:=1
 
wcli   :=SC6->C6_CLI 
wcod   :=alltrim( SC6->C6_CODCLI) 
wcodcli:='' 
wcodped:=space(12)

wret:=Space(42)

 
for xnz:=1 to len(wcod)
   
    if substr(wcod,xnz,1)<>'/'  .and. substr(wcod,xnz,1)<>'\'
       wcodcli:=wcodcli+substr(wcod,xnz,1)
    else
       exit   
    Endif

Next xnz


wpedcli:=alltrim( SC6->C6_PEDCLI)

wret:='IAP01'+;
      replicate('0',11-len(alltrim(wcodcli)))+alltrim(wcodcli) +;
      space(19)+;
      replicate('0',12-len(alltrim(wpedcli)))+alltrim(wpedcli)



 
return wret
