#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE nEMPRESA	  1
#DEFINE nFILIAL       2
#DEFINE nAMBIENTE     3
#DEFINE nCOD_PROC     4
#DEFINE nDESC_PROC    5
#DEFINE nCOD_TAREF    6
#DEFINE nHTML_EMAIL   7
#DEFINE nHTML_ENVIO   8
#DEFINE nHTML_RETORNO 9
#DEFINE nASSUNTO      10
#DEFINE nEMAIL        11
#DEFINE nRETORNO      12
#DEFINE nTIME_OUT     13
#DEFINE cUSUARIO      14

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ENVIAREMAIL�Autor  �Microsiga           � Data �  03/28/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina de teste para workflow, sua funcionalidade consiste  ���
���          �em criar um html com dados passados no parametro e enviar   ���
���          �um email com o caminho desse HTML. Apos respondido, o sis-  ���
���          �tema recebera essa informacao e enviara novamente confir-   ���
���          �mando o retorno. Assim sera possivel verificar se as confi- ���
���          �guracoes de workflow estao corretas, pois hoje no protheus  ���
���          �nao existe essa funcionalidade.                             ���  
������������ͳ�����������������������������������������������������������ͺ��  
���          �Parametro 01 - Codigo da Empresa.                           ���
���          �Parametro 02 - Filial da Empresa.                           ���
���          �Parametro 03 - .T. Carrega ambiente.                        ���
���          �	             Se deve ser carregar o ambiente, essa opcao  ���
���          �               s� precisa ser utilizada caso seja executada ���
���          �               do IDE ou do SmartClient, caso seja usada em ���
���          �               um Menu ou de uma formula nao a necessidade  ���
���          �               de usa-lo.                                   ���
���          �Parametro 04 - Codigo do Processo do Workflow.              ���
���          �Parametro 05 - Descricao do Processo do Workflow.           ���
���          �Parametro 06 - Codigo da Tarefa.                            ���
���          �Parametro 07 - HTML que contem programacao do workflow.     ���
���          �Parametro 08 - HTML que contem link do workflow.            ���
���          �Parametro 09 - HTML que contem resposta do workflow.        ���
���          �Parametro 10 - Assunto do email.                            ���
���          �Parametro 11 - Email de quem deve receber o workflow.       ���
���          �Parametro 12 - Bloco de codigo que sera executado apos a    ���
���          �               resposta do workflow.                        ���
���          �Parametro 13 - Bloco de codigo que sera executado quando    ���
���          �               ocorrer um time out.                         ���
���          �Parametro 14 - Usuario do sistema.                          ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function EnviarEmail(aParam)
	Local oProcess  := Nil     		//Objeto do Processo do Wotkflow
	Local lRetorno  := .F.			//Retorno da rotina
	Local cMailID   := ''       	//Varialvel com ID do workflow enviado
	Local aNome 	:= CarNome()	//Array com nome dos campos no HTML    
	Local oHTML		:= Nil          //Objeto com informacoes do HTML
    
	//Carrega ambiente caso necessario
	If aParam[nAMBIENTE]
		If !AbrirAmb(aParam[nEMPRESA], aParam[nFILIAL])
			ConOut('Erro ao abrir ambiente')		
		EndIf
	EndIf

	//Metodo construtor para criar um objeto de Workflow	
	oProcess := TWFProcess():New( aParam[nCOD_PROC], aParam[nDESC_PROC] )
	
	//Metodo para iniciar uma nova tarefa do workflow(Codigo da Tarefa, Descricao da Tarefa)
	oProcess:NewTask( aParam[nCOD_TAREF], aParam[nHTML_EMAIL] )
	
	//Assunto do Email
	oProcess:cSubject := aParam[nASSUNTO]
	
	//Propriedade com bloco de c�digo que inicializara quando o email e respondido
	oProcess:bReturn  := aParam[nRETORNO]
	
	//Caso nao seja respondido o Workfflow
	oProcess:bTimeOut := aParam[nTIME_OUT]
	
	//Para quem sera enviado, nesse caso sera enviado para o proprio workflow
	oProcess:cTo      := 'WF'                                                
	
	//Usuario do sistema
	oProcess:UserSiga := aParam[cUSUARIO]

	//Objeto com informacoes do HTML
    oHTML := oProcess:oHTML
               
	//Carrega as variaveis que serao passados para o workflow
	If !CarEmail( @oHTML, aParam, aNome)
		ConOut('Erro ao abrir ambiente')		
	EndIf


	//Inicia processo de envio do workflow e guarda o codio do ID em um varivavel
	cMailID := oProcess:Start()

	//Inicia outra tarefa para esta enviar uma mensagem para o usuario com o link do workflow. Pois nao podemos enviar programacao para o email,
	//isso porque hoje existe  uma seguranca no para nao interpretar programacao no email.
	oProcess:NewTask( aParam[nCOD_TAREF], aParam[nHTML_ENVIO] )                           
	
	//Caminho com o link de onde esta o workflow. OBS.: deve-se configurar esse caminho no .ini
	oProcess:ohtml:ValByName('proc_link', 'http://portalsolar111112.protheus.cloudtotvs.com.br:8800/'+cMailID+'.htm')
	
	//Email do usuario que deve receber o workflow.
	oProcess:cTo := aParam[nEMAIL]                         
	
	//Inicia o processo de workflow.
	oProcess:Start()		
	
    //Fecha o ambiente
	If aParam[nAMBIENTE]
		If !FecharAmb()
			ConOut('Erro ao fechar ambiente')
		EndIf
	EndIf	
	lRetorno := .T. 
Return( lRetorno )

User Function RetEmail(oProcess)
	Local lRetorno  := .F.						//Retorno da funcao
	Local oHTML 	:= oProcess:oHTML 			//Objeto com informacoes do HTML
	Local aNome		:= CarNome()				//Array com nome dos campos no HTML
	Local aParam 	:= CarParam(oHTML, aNome) 	//Array com parametros retirados do email
                                      
	//Inicia uma nova tarefa(Codigo da Tarefa, Caminho do layout do HTML)
	oProcess:NewTask( aParam[nCOD_TAREF], aParam[nHTML_RETORNO] )              

	//Carrega informacoes num novo email
	If CarEmail(@oHTML, aParam, aNome )      
		//Assunto do email
		oProcess:cSubject := aParam[nASSUNTO]
		
		//Retorno do email caso seja respondido
		oProcess:bReturn := aParam[nRETORNO]  
		
		//Para quem deve receber o email
		oProcess:cTo := aParam[nEMAIL]
		
		//Codigo do usuario no protheus
		oProcess:UserSiga := aParam[cUSUARIO]
        
		//Inicia processo de workflow.
		oProcess:Start()
		lRetorno := .T. 
	EndIf

Return( lRetorno )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ENVIAREMAIL�Autor  �Bruno Nunes         � Data �  03/28/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Inicia ambiente do Protheus.                                ���
���          �Parametro 1 - Empresa                                       ���
���          �Parametro 2 - Filial                                        ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function AbrirAmb(cEmpAmb, cFilAmb)
	Local lRetorno := .F.	//Retorno da Funcao
	RPCSetType(3)
	RpcSetEnv(cEmpAmb, cFilAmb)
	lRetorno := .T.
Return(lRetorno)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ENVIAREMAIL�Autor  �Microsiga           � Data �  03/28/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Fecha ambiente do Protheus.                                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FecharAmb()
	Local lRetorno := .F. //Retorno da Funcao
	RpcClearEnv()	
	lRetorno := .T.    	
Return(lRetorno)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ENVIAREMAIL�Autor  �Microsiga           � Data �  03/28/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina que sera executada caso nao haja resposta de email   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TOutEmail(oProcess)   
	Local lRetorno := .F. //Retorno da Funcao
	conout('Erro Time Out')
Return(lRetorno)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ENVIAREMAIL�Autor  �Microsiga           � Data �  03/28/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Carrega dados passados nos parametros dentro das variaveis  ���
���          �escritas no HTML.                                           ���
���          �Parametro 1 - Objeto HTML usado no workflow.                ���
���          �Paraemtro 2 - Array com os dados que serao apresentados no  ���
���          �              workflow.                                     ���
���          �Parametro 3 - Nome das variaveis no email do workflow.      ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CarEmail(oHTML, aParam, aNome)
    Local nEmail   := 1		//Contador da estrutura de repeticao
    Local lRetorno := .F.	//Retorno da Funcao     
    Local cTipoVar := ''    //Retorno com o tipo da variavel

	While Len(aParam) < 14
		aAdd(aParam, '')	
	End While
	                       
	For nEmail := 1 To 14
		cTipoVar := ValType(aParam[nEmail])
		If cTipoVar == "C"
			oHTML:ValByName(aNome[nEmail], aParam[nEmail] )
		ElseIf cTipoVar == "L"
			If	aParam[nEmail]
				oHTML:ValByName(aNome[nEmail], '.T.' )
			Else
				oHTML:ValByName(aNome[nEmail], '.F.' )		
			EndIf             
		ElseIf cTipoVar == "A"
			oHTML:ValByName(aNome[nEmail], aParam[nEmail][1] )							
		ElseIf cTipoVar == "N"                                                          
			oHTML:ValByName(aNome[nEmail], AllTrim(Str(aParam[nEmail])) )									
		Endif
    Next  
    lRetorno := .T.
Return( lRetorno )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ENVIAREMAIL�Autor  �Microsiga           � Data �  03/28/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Carrega array com dados da resposta do Workflow             ���
���          �Parametro 1 - Objeto HTML usado no workflow.                ���
���          �Parametro 3 - Nome das variaveis no email do workflow.      ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CarParam( oHTML, aNome )
	Local nEmail := 1
	Local aParam  := {}
	
	For nEmail := 1 To 14
		aAdd( aParam, oHTML:RetByName( aNome[nEmail] ) )
	Next
Return(aParam)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ENVIAREMAIL�Autor  �Microsiga           � Data �  03/28/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina que carrega array com nome das variaveis que estao no���
���          �email.                                                      ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
