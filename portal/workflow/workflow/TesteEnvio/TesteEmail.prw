#INCLUDE 'PROTHEUS.CH'

User Function TesteEmail()
	Local aParam := {}
                      
	aAdd(aParam, '99')							//Empresa
	aAdd(aParam, '01')							//Filial
	aAdd(aParam, .T.)							//Abre ambiente
	aAdd(aParam, 'COD01') 						//Codigo do processo
	aAdd(aParam, 'TESTE DESC WF') 				//Descricao do processo
	aAdd(aParam, 'TAR01')						//Codigo de tarefa
	aAdd(aParam, '\CAMINHO\TESTE_WF.HTM') 		//HTML com workflow
	aAdd(aParam, '\CAMINHO\WF_CLIENTE.HTM') 	//HTML com link
	aAdd(aParam, '\CAMINHO\TESTE_WF2.HTM') 		//HTML com resposta do workflow
	aAdd(aParam, '[ASSUNTO] - TESTE WORKFLOW') 	//Assunto do email
	aAdd(aParam, 'rogerio.souza@totvs.com.br') 	//Email que recebera o workflow
	aAdd(aParam, 'U_RetEmail()') 				//bloco de codigo que sera executado ao receber workflow
	aAdd(aParam, {'U_TOutEmail()',0,0,5}) 		//bloco de codigo que sera exexcutado ao time ou ser executado
	aAdd(aParam, '000000') 						//Usuario do sistema

	U_ENVIAREMAIL(aParam)        

Return()