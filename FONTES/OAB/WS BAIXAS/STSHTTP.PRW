#INCLUDE 'TOTVS.CH'
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³   STSHTTP   ºAutor  ³ Juliano Souza    º Data ³  18/01/18  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna Status de Erro para WS.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Porto Seguro - Carro Facil.                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function STSHTTP( _nCodHTTP )
	Local aCodHTTP := {}
	Local nPos     := 0
	Local cRetRef  := ""
	Default _nCodHTTP := 0

	// Referencia de Codigos de Erros HTTP
	// 1xx Informativa
	aAdd(aCodHTTP,{100,"Continuar."})
	aAdd(aCodHTTP,{101,"Mudando protocolos."})
	aAdd(aCodHTTP,{102,"Processamento."})
	aAdd(aCodHTTP,{122,"Pedido-URI muito longo."})
	// 2xx Sucesso
	aAdd(aCodHTTP,{200,"Ok."})
	aAdd(aCodHTTP,{201,"Criado."})
	aAdd(aCodHTTP,{202,"Aceito."})
	aAdd(aCodHTTP,{203,"Não-autorizado."})
	aAdd(aCodHTTP,{204,"Nenhum conteúdo."})
	aAdd(aCodHTTP,{205,"Reset."})
	aAdd(aCodHTTP,{206,"Conteúdo parcial."})
	aAdd(aCodHTTP,{207,"Status Multi."})
	// 3xx Redirecionamento
	aAdd(aCodHTTP,{300,"Múltipla escolha."})
	aAdd(aCodHTTP,{301,"Movido."})
	aAdd(aCodHTTP,{302,"Encontrado."})
	aAdd(aCodHTTP,{304,"Não modificado."})
	aAdd(aCodHTTP,{305,"Use Proxy."})
	aAdd(aCodHTTP,{306,"Proxy Switch."})
	aAdd(aCodHTTP,{307,"Redirecionamento temporário."})
	// 4xx Erro de cliente
	aAdd(aCodHTTP,{400,"Requisição inválida."})
	aAdd(aCodHTTP,{401,"Não Autorizado."})
	aAdd(aCodHTTP,{402,"Pagamento necessário."})
	aAdd(aCodHTTP,{403,"Proibido."})
	aAdd(aCodHTTP,{404,"Não encontrado."})
	aAdd(aCodHTTP,{405,"Método não permitido."})
	aAdd(aCodHTTP,{406,"Não Aceitável."})
	aAdd(aCodHTTP,{407,"Autenticação de proxy necessária."})
	aAdd(aCodHTTP,{408,"Tempo de requisição esgotou (Timeout)."})
	aAdd(aCodHTTP,{409,"Conflito."})
	aAdd(aCodHTTP,{410,"Gone."})
	aAdd(aCodHTTP,{411,"Comprimento necessário."})
	aAdd(aCodHTTP,{412,"Pré-condição falhou."})
	aAdd(aCodHTTP,{413,"Entidade de solicitação muito grande."})
	aAdd(aCodHTTP,{414,"Pedido-URI Too Long."})
	aAdd(aCodHTTP,{415,"Tipo de mídia não suportado."})
	aAdd(aCodHTTP,{416,"Solicitada de Faixa não Satisfatória."})
	aAdd(aCodHTTP,{417,"Falha na expectativa."})
	aAdd(aCodHTTP,{422,"Entidade improcessável."})
	aAdd(aCodHTTP,{423,"Fechado."})
	aAdd(aCodHTTP,{424,"Falha de Dependência."})
	aAdd(aCodHTTP,{425,"Coleção não ordenada."})
	aAdd(aCodHTTP,{426,"Upgrade Obrigatório."})
	aAdd(aCodHTTP,{450,"Bloqueados pelo Controle de Pais do Windows."})
	aAdd(aCodHTTP,{499,"Cliente fechou Pedido."})
	// 5xx outros erros
	aAdd(aCodHTTP,{500,"Erro interno do servidor."})
	aAdd(aCodHTTP,{501,"Não implementado."})
	aAdd(aCodHTTP,{502,"Bad Gateway."})
	aAdd(aCodHTTP,{503,"Serviço indisponível."})
	aAdd(aCodHTTP,{504,"Gateway Time-Out."})
	aAdd(aCodHTTP,{505,"HTTP Version not supported."})

	// Posiciona Codigo de Referencia
	nPos := aScan(aCodHTTP,{|x| x[1] == _nCodHTTP})
	
	If nPos > 0 
		cRetRef := Alltrim(aCodHTTP[nPos,2]) 
	Else
		cRetRef := "Código de Referencia não Encontrado!"
	Endif
	
Return cRetRef
