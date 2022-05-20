#include "rwmake.ch"  
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ ÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ ฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออป ฑฑ
ฑฑบPrograma  ณUSDGET    บ Autor ณRonaldo Fernades  บ Data ณ    13/08/2004  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออน ฑฑ
ฑฑบDescrio ณ Programa para Atualizacao do Dolar (ou qualquer outra moeda)บฑฑ
ฑฑบDescrio ณ apos as cota็๕es do dia (normalmente apos as 17h30).        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ นฑฑ
ฑฑบUso       ณ  Via Menu ou Job agendado                        		   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ ผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function USDGET()
Local cFile, cTexto, nLinhas, j, lAuto := .F. 

If Select("SX2")==0 // Testa se estแ sendo rodado do menu
	RPCSETENV("01","01","Microsiga","senha","SIGAFIN","JOB",{"SM2"})
	Qout("JOB - Atualizacao do Dolar...")
	lAuto := .T.
EndIf

For nPass := 6 to 0 step -1 
// Refaz dos ultimos 6 dias para o caso de algum dia a conexao ter falhado
	
	dDataRef := dDataBase - nPass
    //Alert(dDataRef)
	//Alert(Dow(dDataRef))
	If Dow(dDataRef) == 1    // Se for domingo
		cFile := DTOS(dDataRef - 2)+".csv"
	   // Alert(cFile+" Domingo")
	ElseIf Dow(dDataRef) == 7            // Se for sแbado
		cFile := DTOS(dDataRef - 1)+".csv"
	 //	Alert(cFile+" Sแbado")
	Else                                   // Se for dia normal
		cFile := DTOS(dDataRef)+".csv"
	 //	Alert(cFile+" Dia Normal")
	EndIf
	
	cTexto  :=  HTTPGET('http://www5.bcb.gov.br/Download/'+cFile)
	nLinhas := MLCount(cTexto, 81)
	//Alert(nLinhas)
	For j := 1 to nLinhas
		cLinha := Memoline(cTexto,81,j)
		cData  := Substr(cLinha,1,10)
		cCompra := StrTran(Substr(cLinha,22,14),",",".")
		cVenda  := StrTran(Substr(cLinha,22+15,14),",",".")
		cEuro   := StrTran(Substr(cLinha,22+15,14),",",".")
		If Subst(cLinha,37,14) == "USD"
		  //Alert("USD"+" - "+cLinha)
		Endif
		If Subst(cLinha,12,3)=="220" // Dolar Americano
			//Alert(clinha)
			DbSelectArea("SM2")
			DbSetOrder(1)
			dData := CTOD(cData)
			//For m := 1 To 15 // projeta para 15 dias.
			//	dData++
				 DbSeek(dData)
					Reclock("SM2",.F.)
						//Alert(Transform(cVenda,"@E 9.9999")+"-"+DTOC(dData))
						Replace M2_DATA   With dData
						Replace M2_MOEDA2 With Val(cVenda)
						Replace M2_INFORM With "S"
					MsUnlock("SM2")
				//Else
				  //	Reclock("SM2",.T.)
			  	//	Replace M2_DATA   With dData
		   //		EndIf
			//	Replace M2_MOEDA2 With Val(cVenda)
			 //	Replace M2_INFORM With "S"
			 //	MsUnlock("SM2")
		  //	Next 
		//Else
	   //	Alert("Nใo Achei o arquivo do dia - "+cData)
		EndIf
	  
	If Subst(cLinha,12,3)=="978" // Euro
			//Alert(clinha)
			DbSelectArea("SM2")
			DbSetOrder(1)
			dData := CTOD(cData)
			//For m := 1 To 15 // projeta para 15 dias.
			//	dData++
				 DbSeek(dData)
					Reclock("SM2",.F.)
						//Alert(Transform(cVenda,"@E 9.9999")+"-"+DTOC(dData))
						Replace M2_DATA   With dData
						Replace M2_MOEDA3 With Val(cEuro)
						Replace M2_INFORM With "S"
					MsUnlock("SM2")
				//Else
				  //	Reclock("SM2",.T.)
			  	//	Replace M2_DATA   With dData
		   //		EndIf
			//	Replace M2_MOEDA2 With Val(cVenda)
			 //	Replace M2_INFORM With "S"
			 //	MsUnlock("SM2")
		  //	Next 
		//Else
	   //	Alert("Nใo Achei o arquivo do dia - "+cData)
		EndIf
	
	Next
next

If lAuto
	RpcClearEnv()
	Qout("FIM - JOB - Atualizacao do Dolar.")
EndIf

Return
