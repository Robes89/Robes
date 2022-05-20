#include 'protheus.ch'
#include 'parmtype.ch'
/*
+-----------+-----------+-------+-------------+------+------------+
| Programa  | M460FIM   | Autor | LUIZ F. DAIBERT| Data | 25/04/20|
+-----------+-----------+-------+-------------+------+------------+
| Descricao | Ponto de entrada após gravação das NFs de saída,    |
|           | fora da transação                                   |
+-----------+-----------------------------------------------------+
| Uso       | MATA460                                             | 
+-----------+-----------------------------------------------------+ 
*/
User Function M460FIM()

	Local cMsgNf := ""
	
	// 25/04/2020 - Preencher mensagem para notas NFe e NFSe
	If Existblock('XMSGNFS')
		cMsgNf := ExecBlock('XMSGNFS',.F.,.F.,{})
	Endif

Return cMsgNf