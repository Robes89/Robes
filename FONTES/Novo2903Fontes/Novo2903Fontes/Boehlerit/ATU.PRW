#include "rwmake.ch"

User Function ATU()

//Processa( {|| ATU1() } , "Atualização" )
//Processa( {|| ATU2() } , "Verificação" )
//Processa( {|| ATU3() } , "Atualizando Endereço de Cobrança de Clientes" )
//Processa( {|| ATU4() } , "Atualizando Código LMT em todas tabelas" )
//Processa( {|| ATU5() } , "Atualizando Super Grupos" )
Processa( {|| ATU6() } , "Atualizando Classificação Fiscal" )
//Processa( {|| ATU7() } , "Gerando Movimento de Valor" )
//Processa( {|| ATU8() } , "Zerando Custo Outras Moedas" )
//Processa( {|| ATU9() } , "Atualizando Pedidos Estimados" )
//Processa( {|| ATU10() } , "Baixa local 03" )
//Processa( {|| ATU11() } , "Gerando Movimento de Transferência" )
//Processa( {|| ATU12() } , "Atualizando Tipo de Produto SB7" )
//Processa( {|| ATU13() } , "Atualizando Area de Clientes" )
//Processa( {|| ATU14() } , "Atualizando CT2" )
//Processa( {|| ATU15() } , "Atualizando SG1" )
//Processa( {|| ATU17() } , "Levantamento de saídas nos últimos 12 meses-Produto" )
//Processa( {|| ATU18() } , "Monta Planilha de produtos 'BR'" )
//Processa( {|| ATU19() } , "Atualiza SZC" )
//Processa( {|| ATU20() } , "Atualizando SD1 - Poder 3ºs" )
//Processa( {|| ATU21() } , "Atualizando Grau de Risco" )
//Processa( {|| ATU22() } , "Levantamento de compras por fornecedor" )
//Processa( {|| ATU23() } , "Atualizando Classificação do Estoque" )
//Processa( {|| ATU24() } , "Atualizando Segmento de Vendas" )
//Processa( {|| ATU25() } , "Atualizando Cadastro Clientes" )
Return NIL

********************************************************************************************************************
Static Function ATU1()

// Atuliza nome de cliente, vendedor, transportador e descrição da condição de pagamento

SA1->( DbSetOrder( 1 ) )
SA3->( DbSetOrder( 1 ) )
SA4->( DbSetOrder( 1 ) )
SE4->( DbSetOrder( 1 ) )

SC5->( DbSeek( xFilial( "SC5" ) ) )

ProcRegua( SC5->( LastRec() ) )

While !SC5->( Eof() ) .and. SC5->C5_FILIAL == xFilial( "SC5" )
	
	IncProc( "Atualizando SC5" )
	
	If SA1->( DbSeek( xFilial( "SA1" ) + SC5->( C5_CLIENTE + C5_LOJACLI ) ) )
		RecLock( "SC5" )
		SC5->C5_NOMECLI	:= SA1->A1_NREDUZ
		SC5->( MsUnLock() )
	EndIf
	
	If SA3->( DbSeek( xFilial( "SA3" ) + SC5->C5_VEND1 ) )
		RecLock( "SC5" )
		SC5->C5_NOMEVEN	:= SA3->A3_NREDUZ
		SC5->( MsUnLock() )
	EndIf
	
	If SA4->( DbSeek( xFilial( "SA4" ) + SC5->C5_TRANSP ) )
		RecLock( "SC5" )
		SC5->C5_NOMETRA	:= SA4->A4_NREDUZ
		SC5->( MsUnLock() )
	EndIf
	
	If SE4->( DbSeek( xFilial( "SE4" ) + SC5->C5_CONDPAG ) )
		RecLock( "SC5" )
		SC5->C5_NOMECON	:= SE4->E4_DESCRI
		SC5->( MsUnLock() )
	EndIf
	
	SC5->( DbSkip() )
EndDo

Return

********************************************************************************************************************
Static Function ATU2()

// Verificar qual maior código LMT cadastrado

Local	nQtdCar	:= 0
Local	cCodLMT	:= ""

SB1->( DbSetOrder( 1 ) )

SB1->( DbSeek( xFilial( "SB1" ) ) )

ProcRegua( SB1->( LastRec() ) )

While !SB1->( Eof() ) .and. SB1->B1_FILIAL == xFilial( "SB1" )
	
	IncProc( "Analizando SB1" )
	
	If Len( AllTrim( SB1->B1_CODLMT ) ) > nQtdCar
		nQtdCar	:= Len( AllTrim( SB1->B1_CODLMT ) )
		cCodLMT	:= AllTrim( SB1->B1_CODLMT )
	EndIf
	
	SB1->( DbSkip() )
	
EndDo

MsgBox( "Maior código LMT -> " + cCodLMT + "     <-> " + Str( nQtdCar , 5 ) + " caracteres" )

Return

********************************************************************************************************************
Static Function ATU3()

Local	nQtd	:= 0

// Atualiza endereço completo de cobrança se estiver em branco de acordo endereço fiscal

SA1->( DbSetOrder( 1 ) )

SA1->( DbSeek( xFilial( "SA1" ) ) )

ProcRegua( SA1->( LastRec() ) )

While !SA1->( Eof() ) .and. SA1->A1_FILIAL == xFilial( "SA1" )
	
	IncProc( "Analizando SA1" )
	
	If Empty( SA1->A1_ENDCOB ) .and. !Empty( SA1->A1_END )
		nQtd++
		RecLock( "SA1" )
		SA1->A1_ENDCOB	:= SA1->A1_END
		SA1->A1_BAIRROC	:= SA1->A1_BAIRRO
		SA1->A1_MUNC	:= SA1->A1_MUN
		SA1->A1_ESTC	:= SA1->A1_EST
		SA1->A1_CEPC	:= SA1->A1_CEP
		SA1->( MsUnLock() )
	EndIf
	
	SA1->( DbSkip() )
	
EndDo

If nQtd # 0
	MsgBox( "Atualizados (" + AllTrim( Str( nQtd , 5 ) ) + ") endereços de clientes." )
EndIf

Return

********************************************************************************************************************
Static Function ATU4()

SB1->( DbSetOrder( 1 ) )

// Atualiza código LMT na tabela SB2
SB2->( DbSetOrder( 1 ) )

SB2->( DbSeek( xFilial( "SB2" ) ) )

ProcRegua( SB2->( LastRec() ) )

While !SB2->( Eof() ) .and. SB2->B2_FILIAL == xFilial( "SB2" )
	
	IncProc( "Atualizando SB2" )
	
	If SB1->( DbSeek( xFilial( "SB1" ) + SB2->B2_COD ) )
		RecLock( "SB2" )
		SB2->B2_CODLMT	:= If( SB1->( DbSeek( xFilial( "SB1" ) + SB2->B2_COD ) ) , SB1->B1_CODLMT , Space( Len( SB2->B2_CODLMT ) ) )
		SB2->( MsUnLock() )
	Else
		RecLock( "SB2" )
		SB2->( DbDelete() )
	EndIf
	
	SB2->( DbSkip() )
	
EndDo

// Atualiza código LMT na tabela SB9
SB9->( DbSetOrder( 1 ) )

SB9->( DbSeek( xFilial( "SB9" ) ) )

ProcRegua( SB9->( LastRec() ) )

While !SB9->( Eof() ) .and. SB9->B9_FILIAL == xFilial( "SB9" )
	
	IncProc( "Atualizando SB9" )
	
	If	SB1->( DbSeek( xFilial( "SB1" ) + SB9->B9_COD ) )
		RecLock( "SB9" )
		SB9->B9_CODLMT	:= If( SB1->( DbSeek( xFilial( "SB1" ) + SB9->B9_COD ) ) , SB1->B1_CODLMT , Space( Len( SB9->B9_CODLMT ) ) )
		SB9->( MsUnLock() )
	Else
		RecLock( "SB9" )
		SB9->( DbDelete() )
		SB9->( MsUnLock() )
	EndIf
	
	SB9->( DbSkip() )
	
EndDo

// Atualiza código LMT na tabela SB6
SB6->( DbSetOrder( 1 ) )

SB6->( DbSeek( xFilial( "SB6" ) ) )

ProcRegua( SB6->( LastRec() ) )

While !SB6->( Eof() ) .and. SB6->B6_FILIAL == xFilial( "SB6" )
	
	IncProc( "Atualizando SB6" )
	
	RecLock( "SB6" )
	SB6->B6_CODLMT	:= If( SB1->( DbSeek( xFilial( "SB1" ) + SB6->B6_PRODUTO ) ) , SB1->B1_CODLMT , Space( Len( SB6->B6_CODLMT ) ) )
	SB6->( MsUnLock() )
	
	SB6->( DbSkip() )
	
EndDo

// Atualiza código LMT na tabela SC2
SC2->( DbSetOrder( 1 ) )

SC2->( DbSeek( xFilial( "SC2" ) ) )

ProcRegua( SC2->( LastRec() ) )

While !SC2->( Eof() ) .and. SC2->C2_FILIAL == xFilial( "SC2" )
	
	IncProc( "Atualizando SC2" )
	
	RecLock( "SC2" )
	SC2->C2_CODLMT	:= If( SB1->( DbSeek( xFilial( "SB1" ) + SC2->C2_PRODUTO ) ) , SB1->B1_CODLMT , Space( Len( SC2->C2_CODLMT ) ) )
	SC2->( MsUnLock() )
	
	SC2->( DbSkip() )
	
EndDo

// Atualiza código LMT na tabela SC6
SC6->( DbSetOrder( 1 ) )

SC6->( DbSeek( xFilial( "SC6" ) ) )

ProcRegua( SC6->( LastRec() ) )

While !SC6->( Eof() ) .and. SC6->C6_FILIAL == xFilial( "SC6" )
	
	IncProc( "Atualizando SC6" )
	
	RecLock( "SC6" )
	SC6->C6_CODLMT	:= If( SB1->( DbSeek( xFilial( "SB1" ) + SC6->C6_PRODUTO ) ) , SB1->B1_CODLMT , Space( Len( SC6->C6_CODLMT ) ) )
	SC6->( MsUnLock() )
	
	SC6->( DbSkip() )
	
EndDo

// Atualiza código LMT na tabela SC7
SC7->( DbSetOrder( 1 ) )

SC7->( DbSeek( xFilial( "SC7" ) ) )

ProcRegua( SC7->( LastRec() ) )

While !SC7->( Eof() ) .and. SC7->C7_FILIAL == xFilial( "SC7" )
	
	IncProc( "Atualizando SC7" )
	
	RecLock( "SC7" )
	SC7->C7_CODLMT	:= If( SB1->( DbSeek( xFilial( "SB1" ) + SC7->C7_PRODUTO ) ) , SB1->B1_CODLMT , Space( Len( SC7->C7_CODLMT ) ) )
	SC7->( MsUnLock() )
	
	SC7->( DbSkip() )
	
EndDo

// Atualiza código LMT na tabela SD1
SD1->( DbSetOrder( 1 ) )

SD1->( DbSeek( xFilial( "SD1" ) ) )

ProcRegua( SD1->( LastRec() ) )

While !SD1->( Eof() ) .and. SD1->D1_FILIAL == xFilial( "SD1" )
	
	IncProc( "Atualizando SD1" )
	
	RecLock( "SD1" )
	SD1->D1_CODLMT	:= If( SB1->( DbSeek( xFilial( "SB1" ) + SD1->D1_COD ) ) , SB1->B1_CODLMT , Space( Len( SD1->D1_CODLMT ) ) )
	SD1->D1_GRUPO	:= SB1->B1_GRUPO
	SD1->( MsUnLock() )
	
	SD1->( DbSkip() )
	
EndDo

// Atualiza código LMT na tabela SD2
SD2->( DbSetOrder( 1 ) )

SD2->( DbSeek( xFilial( "SD2" ) ) )

ProcRegua( SD2->( LastRec() ) )

While !SD2->( Eof() ) .and. SD2->D2_FILIAL == xFilial( "SD2" )
	
	IncProc( "Atualizando SD2" )
	
	RecLock( "SD2" )
	SD2->D2_CODLMT	:= If( SB1->( DbSeek( xFilial( "SB1" ) + SD2->D2_COD ) ) , SB1->B1_CODLMT , Space( Len( SD2->D2_CODLMT ) ) )
	SD2->D2_GRUPO	:= SB1->B1_GRUPO
	SD2->( MsUnLock() )
	
	SD2->( DbSkip() )
	
EndDo


// Atualiza código LMT na tabela SD3
SD3->( DbSetOrder( 12 ) )
SD3->( DbSeek( xFilial( "SD3" ) + Space( Len( SD3->D3_CODLMT ) ) ) )

ProcRegua( SD3->( LastRec() ) )

While !SD3->( Eof() ) .and.	SD3->D3_FILIAL	== xFilial( "SD3" ) .and. ;
							SD3->D3_CODLMT	== Space( Len( SD3->D3_CODLMT ) )
	
	IncProc( "Atualizando SD3" )
	
	RecLock( "SD3" )
	SD3->D3_CODLMT	:= If( SB1->( DbSeek( xFilial( "SB1" ) + SD3->D3_COD ) ) , SB1->B1_CODLMT , Space( Len( SD3->D3_CODLMT ) ) )
	SD3->D3_GRUPO	:= SB1->B1_GRUPO
	SD3->( MsUnLock() )
	
//	SD3->( DbSkip() )
	SD3->( DbSeek( xFilial( "SD3" ) + Space( Len( SD3->D3_CODLMT ) ) ) )
	
EndDo

Return

********************************************************************************************************************
Static Function ATU5()

SBM->( DbSetOrder( 1 ) )

oTemptable := FWTemporaryTable():New( "TRA")
oTempTable:Create()

//dbUseArea(.T.,"DBFCDX","\SIGAADV\SUPERG.DBF","TRA",.T.,.F.)

DbSelectArea( "TRA" )
TRA->( DbGoTop() )

ProcRegua( TRA->( LastRec() ) )

While !TRA->( Eof() )
	
	IncProc()
	
	If SBM->( DbSeek( xFilial( "SBM" ) + Left( TRA->GRUPO , 4 ) ) )
		RecLock( "SBM" )
		SBM->BM_ORDEM	:= TRA->SUPERG
		SBM->( MsUnLock() )
	EndIf
	
	TRA->( DbSkip() )
EndDo


TRA->( DbCloseArea() )

Return

********************************************************************************************************************
Static Function ATU6()

SC6->( DbSetOrder( 1 ) )
SC6->( DbSeek( xFilial( "SC6" ) ) )

ProcRegua( SC6->( LastRec() ) )

While !SC6->( Eof() ) .and. SC6->C6_FILIAL == xFilial( "SC6" )

	IncProc( "Atualizando SC6..." )
	
	RecLock( "SC6" )
	SC6->C6_CLASFIS	:= SubStr( Posicione( "SB1" , 1 , xFilial( "SB1" )+SC6->C6_PRODUTO , "B1_ORIGEM" ) , 1 , 1 ) +;
						SubStr( Posicione( "SF4" , 1 , xFilial( "SF4" ) + SC6->C6_TES , "F4_SITTRIB" ) , 1 , 2 )
	SC6->( MsUnLock() )
	
	SC6->( DbSkip() )
EndDo

SD1->( DbSetOrder( 1 ) )
SD1->( DbSeek( xFilial( "SD1" ) ) )

ProcRegua( SD1->( LastRec() ) )

While !SD1->( Eof() ) .and. SD1->D1_FILIAL == xFilial( "SD1" )

	IncProc( "Atualizando SD1..." )
	
	RecLock( "SD1" )
	SD1->D1_CLASFIS	:= SubStr( Posicione( "SB1" , 1 , xFilial( "SB1" ) + SD1->D1_COD , "B1_ORIGEM" ) , 1 , 1 ) +;
						SubStr( Posicione( "SF4" , 1 , xFilial( "SF4" ) + SD1->D1_TES , "F4_SITTRIB" ) , 1 , 2 )
	SD1->( MsUnLock() )
	
	SD1->( DbSkip() )
EndDo

SD2->( DbSetOrder( 1 ) )
SD2->( DbSeek( xFilial( "SD2" ) ) )

ProcRegua( SD2->( LastRec() ) )

While !SD2->( Eof() ) .and. SD2->D2_FILIAL == xFilial( "SD2" )

	IncProc( "Atualizando SD2..." )
	
	RecLock( "SD2" )
	SD2->D2_CLASFIS	:= SubStr( Posicione( "SB1" , 1 , xFilial( "SB1" ) + SD2->D2_COD , "B1_ORIGEM" ) , 1 , 1 ) +;
						SubStr( Posicione( "SF4" , 1 , xFilial( "SF4" ) + SD2->D2_TES , "F4_SITTRIB" ) , 1 , 2 )
	SD2->( MsUnLock() )
	
	SD2->( DbSkip() )
EndDo

SD1->( DbSetOrder( 1 ) )
SD2->( DbSetOrder( 3 ) )

SFT->( DbSetOrder( 1 ) )
SFT->( DbSeek( xFilial( "SFT" ) ) )

ProcRegua( SFT->( LastRec() ) )

While !SFT->( Eof() ) .and. SFT->FT_FILIAL == xFilial( "SFT" )

	IncProc( "Atualizando SFT..." )
	
	RecLock( "SFT" )
	If		SFT->FT_TIPOMOV == "E"
		If	SD1->( DbSeek( xFilial( "SD1" ) + SFT->( FT_NFISCAL + FT_SERIE + FT_CLIEFOR + FT_LOJA + FT_ITEM ) ) )
			SFT->FT_CLASFIS	:= SD1->D1_CLASFIS
		EndIf
	ElseIf	SFT->FT_TIPOMOV == "S"
		If	SD2->( DbSeek( xFilial( "SD2" ) + SFT->( FT_NFISCAL + FT_SERIE + FT_CLIEFOR + FT_LOJA + LEFT( FT_ITEM , 2 ) ) ) )
			SFT->FT_CLASFIS	:= SD2->D2_CLASFIS
		EndIf
	EndIf
	SFT->( MsUnLock() )
	
	SFT->( DbSkip() )
EndDo

Return

********************************************************************************************************************
Static Function ATU7()

SB1->( DbSetOrder( 1 ) )

SB2->( DbSetOrder( 1 ) )
SB2->( DbSeek( xFilial( "SB2" ) ) )

ProcRegua( SB2->( LastRec() ) )

While !SB2->( Eof() ) .and. SB2->B2_FILIAL == xFilial( "SB2" )
	
	IncProc( "Processando produto » " + SB2->B2_COD )
	
	If SB2->B2_LOCAL == "01" .and. SB2->B2_QFIM = 0 .and. SB2->B2_VFIM1 > 0
		
		SB1->( DbSeek( xFilial( "SB1" ) + SB2->B2_COD ) )
		
		RecLock( "SD3" , .T. )
		SD3->D3_FILIAL	:= xFilial( "SD3" )
		SD3->D3_TM		:= "505"
		SD3->D3_CODLMT	:= SB1->B1_CODLMT
		SD3->D3_COD		:= SB2->B2_COD
		SD3->D3_CF		:= "RE6"
		SD3->D3_UM		:= SB1->B1_UM
		SD3->D3_QUANT	:= 0
		SD3->D3_CONTA	:= SB1->B1_CONTA
		SD3->D3_LOCAL	:= SB2->B2_LOCAL
		SD3->D3_GRUPO   := SB1->B1_GRUPO
		SD3->D3_DOC		:= "311005"
		SD3->D3_EMISSAO	:= dDataBase
		SD3->D3_NUMSEQ	:= ProxNum()
		SD3->D3_TIPO	:= SB1->B1_TIPO
		SD3->D3_USUARIO	:= SubStr( cUsuario , 7 , 15 )
		SD3->D3_CHAVE	:= "E0"
		SD3->D3_CUSTO1	:= Abs( SB2->B2_VFIM1 )
		SD3->( MsUnLock() )
	EndIf
	
	If SB2->B2_LOCAL == "01" .and. SB2->B2_QFIM = 0 .and. SB2->B2_VFIM1 < 0
		
		SB1->( DbSeek( xFilial( "SB1" ) + SB2->B2_COD ) )
		
		RecLock( "SD3" , .T. )
		SD3->D3_FILIAL	:= xFilial( "SD3" )
		SD3->D3_TM		:= "202"
		SD3->D3_CODLMT	:= SB1->B1_CODLMT
		SD3->D3_COD		:= SB2->B2_COD
		SD3->D3_CF		:= "DE6"
		SD3->D3_UM		:= SB1->B1_UM
		SD3->D3_QUANT	:= 0
		SD3->D3_CONTA	:= SB1->B1_CONTA
		SD3->D3_LOCAL	:= SB2->B2_LOCAL
		SD3->D3_GRUPO   := SB1->B1_GRUPO
		SD3->D3_DOC		:= "311005"
		SD3->D3_EMISSAO	:= dDataBase
		SD3->D3_NUMSEQ	:= ProxNum()
		SD3->D3_TIPO	:= SB1->B1_TIPO
		SD3->D3_USUARIO	:= SubStr( cUsuario , 7 , 15 )
		SD3->D3_CHAVE	:= "E0"
		SD3->D3_CUSTO1	:= Abs( SB2->B2_VFIM1 )
		SD3->( MsUnLock() )
	EndIf
	
	SB2->( DbSkip() )
EndDo

Return

********************************************************************************************************************
Static Function ATU8()

SB2->( DbSetOrder( 1 ) )
SB2->( DbSeek( xFilial( "SB2" ) ) )

ProcRegua( SB2->( LastRec() ) )

While !SB2->( Eof() ) .and. SB2->B2_FILIAL == xFilial( "SB2" )
	
	IncProc( "Processando SB2..." )
	
	RecLock( "SB2" )
	SB2->B2_CM2		:= 0
	SB2->B2_VATU2	:= 0
	SB2->B2_VFIM2	:= 0
	SB2->B2_CM3		:= 0
	SB2->B2_VATU3	:= 0
	SB2->B2_VFIM3	:= 0
	SB2->B2_CM4		:= 0
	SB2->B2_VATU4	:= 0
	SB2->B2_VFIM4	:= 0
	SB2->B2_CM5		:= 0
	SB2->B2_VATU5	:= 0
	SB2->B2_VFIM5	:= 0
	SB2->( MsUnLock() )
	
	SB2->( DbSkip() )
EndDo

SB9->( DbSetOrder( 1 ) )
SB9->( DbSeek( xFilial( "SB9" ) ) )

ProcRegua( SB9->( LastRec() ) )

While !SB9->( Eof() ) .and. SB9->B9_FILIAL == xFilial( "SB9" )
	
	IncProc( "Processando SB9..." )
	
	RecLock( "SB9" )
	SB9->B9_VINI2	:= 0
	SB9->B9_VINI3	:= 0
	SB9->B9_VINI4	:= 0
	SB9->B9_VINI5	:= 0
	SB9->( MsUnLock() )
	
	SB9->( DbSkip() )
EndDo

SD1->( DbSetOrder( 1 ) )
SD1->( DbSeek( xFilial( "SD1" ) ) )

ProcRegua( SD1->( LastRec() ) )

While !SD1->( Eof() ) .and. SD1->D1_FILIAL == xFilial( "SD1" )
	
	IncProc( "Processando SD1..." )
	
	RecLock( "SD1" )
	SD1->D1_CUSTO2	:= 0
	SD1->D1_CUSTO3	:= 0
	SD1->D1_CUSTO4	:= 0
	SD1->D1_CUSTO5	:= 0
	SD1->( MsUnLock() )
	
	SD1->( DbSkip() )
EndDo

SD2->( DbSetOrder( 1 ) )
SD2->( DbSeek( xFilial( "SD2" ) ) )

ProcRegua( SD2->( LastRec() ) )

While !SD2->( Eof() ) .and. SD2->D2_FILIAL == xFilial( "SD2" )
	
	IncProc( "Processando SD2..." )
	
	RecLock( "SD2" )
	SD2->D2_CUSTO2	:= 0
	SD2->D2_CUSTO3	:= 0
	SD2->D2_CUSTO4	:= 0
	SD2->D2_CUSTO5	:= 0
	SD2->( MsUnLock() )
	
	SD2->( DbSkip() )
EndDo

SD3->( DbSetOrder( 1 ) )
SD3->( DbSeek( xFilial( "SD3" ) ) )

ProcRegua( SD3->( LastRec() ) )

While !SD3->( Eof() ) .and. SD3->D3_FILIAL == xFilial( "SD3" )
	
	IncProc( "Processando SD3..." )
	
	RecLock( "SD3" )
	SD3->D3_CUSTO2	:= 0
	SD3->D3_CUSTO3	:= 0
	SD3->D3_CUSTO4	:= 0
	SD3->D3_CUSTO5	:= 0
	SD3->( MsUnLock() )
	
	SD3->( DbSkip() )
EndDo

Return

********************************************************************************************************************
Static Function ATU9()

Local	aArea_SC5	:= SC5->( GetArea() )
Local	aArea_SC6	:= SC6->( GetArea() )
Local	aArea_SD2	:= SD2->( GetArea() )

SD2->( DbSetOrder( 5 ) )
SC6->( DbSetOrder( 1 ) )
SC5->( DbSetOrder( 1 ) )

SC6->( DbSeek( xFilial( "SC6" ) ) )

ProcRegua( SC6->( LastRec() ) )

While !SC6->( Eof() ) .and. SC6->C6_FILIAL == xFilial( "SC6" )
	
	IncProc( "Processando SC6, pedido » " + SC6->C6_NUM )
	
	If SC5->( DbSeek( xFilial( "SC5" ) + SC6->C6_NUM ) ) .and. SC5->C5_STPAD == "E"
		
		RecLock( "SC6" )
		SC6->C6_QTDENT	:= 0
		SC6->C6_NOTA	:= Space( Len( SC6->C6_NOTA ) )
		SC6->C6_SERIE	:= Space( Len( SC6->C6_SERIE ) )
		SC6->C6_DATFAT	:= CtoD("")
		SC6->( MsUnLock() )
	EndIf
	
	SC6->( DbSkip() )
	
EndDo

SD2->( DbSeek( xFilial( "SD2" ) ) )

ProcRegua( SD2->( LastRec() ) )

While !SD2->( Eof() ) .and. SD2->D2_FILIAL == xFilial( "SD2" )
	
	IncProc( "Processando SD2, dia » " + DtoC( SD2->D2_EMISSAO ) )
	
	SC6->( DbSetOrder( 1 ) )
	If SC6->( DbSeek( xFilial( "SC6" ) + SD2->( D2_PEDIDO + D2_ITEMPV ) ) ) .and. ;
		!Empty( SC6->C6_NUMPEDP )
		
		cPedEst		:= SC6->C6_NUMPEDP
		cIteEst		:= SC6->C6_ITEMPE
		nD2_QUANT	:= SD2->D2_QUANT
		
		SC6->( DbSetOrder( 2 ) )
		If SC6->( DbSeek( xFilial( "SC6" ) + SD2->D2_COD + cPedEst ) )
			
			While !SC6->( Eof() ) .and. ;
				SC6->C6_FILIAL	== xFilial( "SC6" ) .and. ;
				SC6->C6_PRODUTO	== SD2->D2_COD .and. ;
				SC6->C6_NUM		== cPedEst .and. ;
				IF( !Empty( cIteEst ) , SC6->C6_ITEM , Space( 02 ) )	== cIteEst .and. ;
				nD2_QUANT > 0

				If SC6->C6_QTDENT > SC6->C6_QTDVEN
					SC6->( DbSkip() )
					Loop
				EndIf

				RecLock( "SC6" )
				If ( SC6->C6_QTDENT + nD2_QUANT ) > SC6->C6_QTDVEN
					nQuantX		:= SC6->C6_QTDVEN - SC6->C6_QTDENT
				Else
					nQuantX		:= nD2_QUANT
				EndIf
				nD2_QUANT	-= nQuantX
				
				SC6->C6_QTDENT	+= nQuantX
				SC6->C6_NOTA	:= SD2->D2_DOC
				SC6->C6_SERIE	:= SD2->D2_SERIE
				SC6->C6_DATFAT	:= SD2->D2_EMISSAO
				SC6->( MsUnLock() )
				SC6->( DbSkip() )
				
			EndDo
			
		EndIf
		
	EndIf
	
	SD2->( DbSkip() )
EndDo

SC6->( DbSetOrder( 1 ) )
SC5->( DbSetOrder( 1 ) )

SC5->( DbSeek( xFilial( "SC5" ) ) )

ProcRegua( SC5->( LastRec() ) )

While !SC5->( Eof() ) .and. SC5->C5_FILIAL == xFilial( "SC5" )
	
	IncProc( "Atualizando SC5..." )
	
	If SC5->C5_STPAD == "E"
		RecLock( "SC5" )
		SC5->C5_NOTA	:= Space( Len( SC5->C5_NOTA ) )
		SC5->C5_SERIE	:= Space( Len( SC5->C5_SERIE ) )
		SC5->( MsUnLock() )
		
		nQtdVen	:= 0
		nQtdEnt	:= 0
		cNota	:= ""
		cSerie	:= ""
		
		SC6->( DbSeek( xFilial( "SC6" ) + SC5->C5_NUM ) )
		While !SC6->( Eof() ) .and. SC6->C6_FILIAL == xFilial( "SC6" ) .and. SC6->C6_NUM == SC5->C5_NUM
			RecLock( "SC6" )
			If AllTrim( SC6->C6_BLQ ) == "R"
				RecLock( "SC6" )
				SC6->C6_QTDENT	+= ( SC6->C6_QTDVEN - SC6->C6_QTDENT )
				SC6->( MsUnLock() )
			EndIf
			nQtdVen	+= SC6->C6_QTDVEN
			nQtdEnt	+= SC6->C6_QTDENT
			If Empty( cNota ) .or. SC6->C6_NOTA > cNota
				cNota	:= SC6->C6_NOTA
				cSerie	:= SC6->C6_SERIE
			EndIf
			SC6->( DbSkip() )
		EndDo
		
		If nQtdEnt >= nQtdVen
			RecLock( "SC5" )
			SC5->C5_NOTA	:= cNota
			SC5->C5_SERIE	:= cSerie
			SC5->C5_LIBEROK	:= "S"
			SC5->( MsUnLock() )
		EndIf
		
	EndIf
	
	SC5->( DbSkip() )
EndDo

Return

********************************************************************************************************************
Static Function ATU10()

SF4->( DbSetOrder( 1 ) )
SD1->( DbSetOrder( 6 ) )
SD1->( DbSeek( xFilial( "SD1" ) + "200510" ) )

ProcRegua( SD1->( LastRec() ) )

While !SD1->( Eof() ) .and.	SD1->D1_FILIAL == xFilial( "SD1" ) .and. ;
	Month( SD1->D1_DTDIGIT ) == 10 .and. ;
	Year( SD1->D1_DTDIGIT ) == 2005
	
	IncProc( "Processando dia » " + DtoC( SD1->D1_DTDIGIT ) )
	
	If Substr( SD1->D1_CF , 2 , 3 ) $ "913" .or. ( Substr( SD1->D1_CF , 2 , 3 ) $ "949" .and. ;
		SF4->( DbSeek( xFilial( "SF4" ) + SD1->D1_TES ) ) .and. "MOSTRUARIO" $ Upper( SF4->F4_TXTUSER ) )
		
		RecLock( "SD3" , .T. )
		SD3->D3_FILIAL	:= xFilial( "SD3" )
		SD3->D3_TM		:= "600"
		SD3->D3_CODLMT	:= SD1->D1_CODLMT
		SD3->D3_COD		:= SD1->D1_COD
		SD3->D3_CF		:= "RE0"
		SD3->D3_UM		:= SD1->D1_UM
		SD3->D3_QUANT	:= SD1->D1_QUANT
		SD3->D3_CONTA	:= SD1->D1_CONTA
		SD3->D3_LOCAL	:= "03"
		SD3->D3_GRUPO   := SD1->D1_GRUPO
		SD3->D3_DOC		:= SD1->D1_DOC
		SD3->D3_EMISSAO	:= SD1->D1_DTDIGIT
		SD3->D3_NUMSEQ	:= ProxNum()
		SD3->D3_TIPO	:= SD1->D1_TP
		SD3->D3_USUARIO	:= SubStr( cUsuario , 7 , 15 )
		SD3->D3_CHAVE	:= "E0"
		SD3->( MsUnLock() )
	EndIf
	
	SD1->( DbSkip() )
EndDo

Return

********************************************************************************************************************
Static Function ATU11()

SF4->( DbSetOrder( 1 ) )
SD2->( DbSetOrder( 5 ) )
SD2->( DbSeek( xFilial( "SD2" ) + "20051110" ) )

ProcRegua( SD2->( LastRec() ) )

While !SD2->( Eof() ) .and.	SD2->D2_FILIAL == xFilial( "SD2" ) .and. ;
	DtoS( SD2->D2_EMISSAO ) >= "20051110"
	
	IncProc( "Processando dia » " + DtoC( SD2->D2_EMISSAO ) )
	
	If SD2->D2_TES == "597"
		
		cProxNum	:= ProxNum()
		
		RecLock( "SD3" , .T. )
		SD3->D3_FILIAL	:= xFilial( "SD3" )
		SD3->D3_TM		:= "999"
		SD3->D3_CODLMT	:= SD2->D2_CODLMT
		SD3->D3_COD		:= SD2->D2_COD
		SD3->D3_CF		:= "RE4"
		SD3->D3_UM		:= SD2->D2_UM
		SD3->D3_QUANT	:= SD2->D2_QUANT
		SD3->D3_CONTA	:= SD2->D2_CONTA
		SD3->D3_LOCAL	:= SD2->D2_LOCAL
		SD3->D3_GRUPO   := SD2->D2_GRUPO
		SD3->D3_DOC		:= SD2->D2_DOC
		SD3->D3_EMISSAO	:= SD2->D2_EMISSAO
		SD3->D3_NUMSEQ	:= cProxNum
		SD3->D3_TIPO	:= SD2->D2_TP
		SD3->D3_USUARIO	:= SubStr( cUsuario , 7 , 15 )
		SD3->D3_CHAVE	:= "E0"
		SD3->( MsUnLock() )
		
		RecLock( "SD3" , .T. )
		SD3->D3_FILIAL	:= xFilial( "SD3" )
		SD3->D3_TM		:= "499"
		SD3->D3_CODLMT	:= SD2->D2_CODLMT
		SD3->D3_COD		:= SD2->D2_COD
		SD3->D3_CF		:= "DE4"
		SD3->D3_UM		:= SD2->D2_UM
		SD3->D3_QUANT	:= SD2->D2_QUANT
		SD3->D3_CONTA	:= SD2->D2_CONTA
		SD3->D3_LOCAL	:= "03"
		SD3->D3_GRUPO   := SD2->D2_GRUPO
		SD3->D3_DOC		:= SD2->D2_DOC
		SD3->D3_EMISSAO	:= SD2->D2_EMISSAO
		SD3->D3_NUMSEQ	:= cProxNum
		SD3->D3_TIPO	:= SD2->D2_TP
		SD3->D3_USUARIO	:= SubStr( cUsuario , 7 , 15 )
		SD3->D3_CHAVE	:= "E9"
		SD3->( MsUnLock() )
		
	EndIf
	
	SD2->( DbSkip() )
EndDo

Return

********************************************************************************************************************
Static Function ATU12()

SB1->( DbSetOrder( 1 ) )

SB7->( DbSetOrder( 1 ) )
SB7->( DbSeek( xFilial( "SB7" ) ) )

ProcRegua( SB7->( LastRec() ) )

While !SB7->( Eof() ) .and. SB7->B7_FILIAL == xFilial( "SB7" )
	
	IncProc( "Atualizando SB7..." )
	
	If SB1->( DbSeek( xFilial( "SB1" ) + SB7->B7_COD ) )
		RecLock( "SB7" )
		SB7->B7_TIPO	:= SB1->B1_TIPO
		SB7->( MsUnLock() )
	Else
		MsgBox( "Produto » " + SB7->B7_COD + " não existe !" )
	EndIf
	
	SB7->( DbSkip() )
EndDo

Return

********************************************************************************************************************
Static Function ATU13()

SA1->( DbSetOrder( 1 ) )

//bUseArea(.T.,"DBFCDX","\DEVELOP\AREA.DBF","TRA",.T.,.F.)
oTemptable := FWTemporaryTable():New( "TRA")
oTempTable:Create()

DbSelectArea( "TRA" )
TRA->( DbGoTop() )

ProcRegua( TRA->( LastRec() ) )

While !TRA->( Eof() )
	
	IncProc()
	
	If SA1->( DbSeek( xFilial( "SA1" ) + Left( TRA->A1_COD , 6 ) + Left( TRA->A1_LOJA , 2 ) ) )
		RecLock( "SA1" )
		SA1->A1_AREA	:= AllTrim( TRA->A1_AREA )
		SA1->( MsUnLock() )
	EndIf
	
	TRA->( DbSkip() )
EndDo

TRA->( DbCloseArea() )

Return

********************************************************************************************************************
Static Function ATU14()

CT2->( DbSetOrder( 1 ) )
CT2->( DbSeek( xFilial( "CT2" ) ) )

CT2->( DbSeek( xFilial( "CT2" ) + "2005" ) )
ProcRegua( CT2->( LastRec() ) )

While !CT2->( Eof() ) .and. CT2->CT2_FILIAL == xFilial( "CT2" ) .and. Year( CT2->CT2_DATA ) >= 2005
	
	IncProc( "Atualizando dia » " + DtoC( CT2->CT2_DATA ) )
	
	If !SubStr( CT2->CT2_DEBITO , 1 , 1 ) $ "3"
		RecLock( "CT2" )
		CT2->CT2_CCD	:= Space( 10 )
		CT2->( MsUnLock() )
	EndIf

	If !SubStr( CT2->CT2_CREDIT , 1 , 1 ) $ "3"
		RecLock( "CT2" )
		CT2->CT2_CCC	:= Space( 10 )
		CT2->( MsUnLock() )
	EndIf

	CT2->( DbSkip() )
EndDo

Return




********************************************************************************************************************
Static Function ATU15()

Local	nQtd	:= 0

// Atualiza endereço completo de cobrança se estiver em branco de acordo endereço fiscal

SG1->( DbSetOrder( 1 ) )

SG1->( DbSeek( xFilial( "SG1" ) ) )

ProcRegua( SG1->( LastRec() ) )

While !SG1->( Eof() ) .and. SG1->G1_FILIAL == xFilial( "SG1" )
	
	IncProc( "Analizando SG1" )
	
	DBSELECTAREA("SB1")
	DBSETORDER(1)
	DBSEEK(XFILIAL("SB1") + SG1->G1_COD)
	
	DBSELECTAREA("SG1")
	RECLOCK("SG1",.F.)
	SG1->G1_CODLMT := SB1->B1_CODLMT
	MSUNLOCK()
	
	SG1->( DbSkip() )
	
EndDo

Return

********************************************************************************************************************
Static Function ATU16()

SC6->( DbSetOrder( 1 ) )
SC5->( DbSetOrder( 1 ) )

SC5->( DbSeek( xFilial( "SC5" ) ) )

ProcRegua( SC5->( LastRec() ) )

While !SC5->( Eof() ) .and. SC5->C5_FILIAL == xFilial( "SC5" )
	
	IncProc( "Atualizando SC5..." )
	
	If	SC5->C5_STPAD == "E"
		lAtualiza	:= .F.
		
		SC6->( DbSeek( xFilial( "SC6" ) + SC5->C5_NUM ) )
		While !SC6->( Eof() ) .and. SC6->C6_FILIAL == xFilial( "SC6" ) .and. SC6->C6_NUM == SC5->C5_NUM
			If	SC6->C6_QTDVEN > SC6->C6_QTDENT
				lAtualiza	:= .T.
				RecLock( "SC6" )
				SC6->C6_QTDENT	:= SC6->C6_QTDVEN
				SC6->( MsUnLock() )
			EndIf
			SC6->( DbSkip() )
		EndDo
		
		If	lAtualiza
			RecLock( "SC5" )
			SC5->C5_NOTA	:= Replicate( "X" , Len( SC5->C5_NOTA ) )
			SC5->C5_SERIE	:= Replicate( "X" , Len( SC5->C5_SERIE ) )
			SC5->C5_LIBEROK	:= "S"
			SC5->( MsUnLock() )
		EndIf
		
	EndIf
	
	SC5->( DbSkip() )
EndDo

Return

********************************************************************************************************************
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"

Static Function ATU17()
Local cQuery := ""

aStru := {}
aAdd(aStru,{"CODIGO",		"C",	TamSx3( "B1_COD" )[1],		TamSx3( "B1_COD")[2] } )
aAdd(aStru,{"CODLMT",		"C",	TamSx3( "B1_CODLMT" )[1],	TamSx3( "B1_CODLMT")[2] } )
aAdd(aStru,{"DESC",			"C",	TamSx3( "B1_DESC" )[1],		TamSx3( "B1_COD")[2] } )
aAdd(aStru,{"DENOM",		"C",	TamSx3( "B1_DENOM" )[1],	TamSx3( "B1_DENOM")[2] } )
aAdd(aStru,{"ESTOQUE",		"N",	TamSx3( "B2_QATU" )[1],		TamSx3( "B2_QATU")[2] } )
aAdd(aStru,{"SAIDAS",		"N",	TamSx3( "B2_QATU" )[1],		TamSx3( "B2_QATU")[2] } )

oTemptableB := FWTemporaryTable():New( "TRB")
oTemptableB:SetFields( aStru )
oTempTableB:AddIndex("index1", {"CODIGO"} )
oTempTableB:Create()

/*cArq := CriaTrab(aStru,.T.)
dbUseArea(.T.,,cArq,"TRB",.T.)
cInd := CriaTrab(NIL,.F.)
IndRegua("TRB",cInd,"CODIGO",,,"Selecionando Registros...")
*/
// estoque em 31/12/08
DbSelectArea( "SB9" )
cQuery	:= " SELECT SB9.B9_COD, SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM"
cQuery	+= ", SUM(CASE WHEN SB9.B9_LOCAL IN ('01','02') THEN SB9.B9_QINI ELSE 0 END) AS ESTOQUE"
cQuery	+= " FROM " + RetSqlName( "SB9" ) + " SB9"
cQuery	+= " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SB9.B9_COD = SB1.B1_COD"
cQuery	+= " AND SB1.D_E_L_E_T_ = ' '"
cQuery	+= " AND SB1.B1_ATIVO <> 'N'"
cQuery	+= " AND SB1.B1_TIPO = 'PA'"
cQuery	+= " WHERE"
cQuery	+= " SB9.D_E_L_E_T_ = ' '"
cQuery	+= " AND SUBSTR( SB9.B9_DATA , 1 , 6 ) = '200812'"
cQuery	+= " GROUP BY SB9.B9_COD, SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM"
cQuery	+= " ORDER BY SB9.B9_COD"

cQuery := ChangeQuery( cQuery )
MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),'XSB9', .F., .T.)},OemToAnsi("Selecionando estoque"))
TcSetField( "XSB9",	"ESTOQUE",	"N",	TamSx3( "B2_QATU" )[1],	TamSx3( "B2_QATU")[2] )

*---------------------------------------------------------------------------------------
// saídas em 2008

DbSelectArea( "SD2" )
cQuery	:= " SELECT SD2.D2_COD, SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM"
cQuery	+= ", SUM(CASE WHEN SD2.D2_LOCAL IN ('01','02') THEN SD2.D2_QUANT ELSE 0 END) AS SAIDAS"
cQuery	+= " FROM " + RetSqlName( "SD2" ) + " SD2"
cQuery	+= " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SD2.D2_COD = SB1.B1_COD"
cQuery	+= " AND SB1.D_E_L_E_T_ = ' '"
cQuery	+= " AND SB1.B1_ATIVO <> 'N'"
cQuery	+= " AND SB1.B1_TIPO = 'PA'"
cQuery	+= " INNER JOIN " + RetSqlName( "SF4" ) + " SF4 ON SD2.D2_TES = SF4.F4_CODIGO"
cQuery	+= " AND SF4.D_E_L_E_T_ = ' '"
cQuery	+= " AND SF4.F4_ESTOQUE = 'S'"
cQuery	+= " WHERE"
cQuery	+= " SD2.D_E_L_E_T_ = ' '"
cQuery	+= " AND SUBSTR(SD2.D2_EMISSAO,1,4)='2008'"
cQuery	+= " AND SD2.D2_TIPO NOT IN ('B','D')"
cQuery	+= " GROUP BY SD2.D2_COD, SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM"
cQuery	+= " ORDER BY SD2.D2_COD"

cQuery := ChangeQuery( cQuery )
MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),'XSD2', .F., .T.)},OemToAnsi("Selecionando SD2"))
TcSetField( "XSD2",	"SAIDAS",	"N",	TamSx3( "D2_QUANT" )[1],	TamSx3( "D2_QUANT")[2] )

*---------------------------------------------------------------------------------------
// entradas em 2008
/*
DbSelectArea( "SD1" )
cQuery	:= " SELECT SD1.D1_COD, SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM"
cQuery	+= ", SUM(CASE WHEN SD1.D1_LOCAL IN ('01','02') THEN (SD1.D1_QUANT*-1) ELSE 0 END) AS ENTRADAS"
cQuery	+= " FROM " + RetSqlName( "SD1" ) + " SD1"
cQuery	+= " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SD1.D1_COD = SB1.B1_COD"
cQuery	+= " AND SB1.D_E_L_E_T_ = ' '"
cQuery	+= " AND SB1.B1_ATIVO <> 'N'"
cQuery	+= " AND SB1.B1_TIPO = 'PA'"
cQuery	+= " INNER JOIN " + RetSqlName( "SF4" ) + " SF4 ON SD1.D1_TES = SF4.F4_CODIGO"
cQuery	+= " AND SF4.D_E_L_E_T_ = ' '"
cQuery	+= " AND SF4.F4_ESTOQUE = 'S'"
cQuery	+= " WHERE"
cQuery	+= " SD1.D_E_L_E_T_ = ' '"
cQuery	+= " AND SUBSTR(SD1.D1_DTDIGIT,1,4)='2008'"
cQuery	+= " AND SD1.D1_TIPO NOT IN ('B','D')"
cQuery	+= " GROUP BY SD1.D1_COD, SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM"
cQuery	+= " ORDER BY SD1.D1_COD"

cQuery := ChangeQuery( cQuery )
MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),'XSD1', .F., .T.)},OemToAnsi("Selecionando SD1"))
TcSetField( "XSD1",	"ENTRADAS",	"N",	TamSx3( "D1_QUANT" )[1],	TamSx3( "D1_QUANT")[2] )
*/
*---------------------------------------------------------------------------------------
// movimentos em 2008

DbSelectArea( "SD3" )
cQuery	:= " SELECT SD3.D3_COD, SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM"
//cQuery	+= ", SUM(CASE WHEN SD3.D3_LOCAL IN ('01','02') AND SD3.D3_CF IN ('DE0','DE1','DE6') THEN (SD3.D3_QUANT*-1) ELSE 0 END) AS MOV_ENT"
cQuery	+= ", SUM(CASE WHEN SD3.D3_LOCAL IN ('01','02') AND SD3.D3_CF IN ('RE0','RE1','RE6') THEN SD3.D3_QUANT ELSE 0 END) AS MOV_SAI"
cQuery	+= " FROM " + RetSqlName( "SD3" ) + " SD3"
cQuery	+= " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SD3.D3_COD = SB1.B1_COD"
cQuery	+= " AND SB1.D_E_L_E_T_ = ' '"
cQuery	+= " AND SB1.B1_ATIVO <> 'N'"
cQuery	+= " AND SB1.B1_TIPO = 'PA'"
cQuery	+= " WHERE"
cQuery	+= " SD3.D_E_L_E_T_ = ' '"
cQuery	+= " AND SD3.D3_ESTORNO <> 'S'"
cQuery	+= " AND SUBSTR(SD3.D3_EMISSAO,1,4)='2008'"
cQuery	+= " GROUP BY SD3.D3_COD, SB1.B1_CODLMT, SB1.B1_DESC, SB1.B1_DENOM"
cQuery	+= " ORDER BY SD3.D3_COD"

cQuery := ChangeQuery( cQuery )
MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),'XSD3', .F., .T.)},OemToAnsi("Selecionando SD3"))
//TcSetField( "XSD3",	"MOV_ENT",	"N",	TamSx3( "D3_QUANT" )[1],	TamSx3( "D3_QUANT")[2] )
TcSetField( "XSD3",	"MOV_SAI",	"N",	TamSx3( "D3_QUANT" )[1],	TamSx3( "D3_QUANT")[2] )

*---------------------------------------------------------------------------------------
// montando arquivo de trabalho

DbSelectArea( "XSB9" )
XSB9->( DbGoTop() )
MsAguarde({|| ProcRegua( XSB9->( LastRec() ) ) }, OemToAnsi( "Atualizando dados do estoque..." ) )

While !XSB9->( Eof() )

	IncProc()

	If	XSB9->ESTOQUE # 0
		RecLock( "TRB" , !TRB->( DbSeek( XSB9->B9_COD ) ) )
		TRB->CODIGO		:= XSB9->B9_COD
		TRB->CODLMT		:= XSB9->B1_CODLMT
		TRB->DESC		:= XSB9->B1_DESC
		TRB->DENOM		:= XSB9->B1_DENOM
		TRB->ESTOQUE	:= XSB9->ESTOQUE
		TRB->( MsUnLock() )
	EndIf
	
	XSB9->( DbSkip() )

EndDo

DbSelectArea( "XSD2" )
XSD2->( DbGoTop() )
MsAguarde({|| ProcRegua( XSD2->( LastRec() ) ) }, OemToAnsi( "Atualizando saídas..." ) )

While !XSD2->( Eof() )

	IncProc()

	If	XSD2->SAIDAS # 0
		RecLock( "TRB" , !TRB->( DbSeek( XSD2->D2_COD ) ) )
		TRB->CODIGO		:= XSD2->D2_COD
		TRB->CODLMT		:= XSD2->B1_CODLMT
		TRB->DESC		:= XSD2->B1_DESC
		TRB->DENOM		:= XSD2->B1_DENOM
		TRB->SAIDAS		+= XSD2->SAIDAS
		TRB->( MsUnLock() )
	EndIf
	
	XSD2->( DbSkip() )

EndDo

/*
DbSelectArea( "XSD1" )
XSD1->( DbGoTop() )
MsAguarde({|| ProcRegua( XSD1->( LastRec() ) ) }, OemToAnsi( "Atualizando entradas..." ) )

While !XSD1->( Eof() )

	IncProc()

	If	XSD1->ENTRADAS # 0
		RecLock( "TRB" , !TRB->( DbSeek( XSD1->D1_COD ) ) )
		TRB->CODIGO		:= XSD1->D1_COD
		TRB->CODLMT		:= XSD1->B1_CODLMT
		TRB->DESC		:= XSD1->B1_DESC
		TRB->DENOM		:= XSD1->B1_DENOM
		TRB->SAIDAS		+= XSD1->ENTRADAS
		TRB->( MsUnLock() )
	EndIf
	
	XSD1->( DbSkip() )

EndDo
*/

DbSelectArea( "XSD3" )
XSD3->( DbGoTop() )
MsAguarde({|| ProcRegua( XSD3->( LastRec() ) ) }, OemToAnsi( "Atualizando movimentos internos..." ) )

While !XSD3->( Eof() )

	IncProc()

	If	XSD3->MOV_SAI # 0 //.or. XSD3->MOV_ENT # 0
		RecLock( "TRB" , !TRB->( DbSeek( XSD3->D3_COD ) ) )
		TRB->CODIGO		:= XSD3->D3_COD
		TRB->CODLMT		:= XSD3->B1_CODLMT
		TRB->DESC		:= XSD3->B1_DESC
		TRB->DENOM		:= XSD3->B1_DENOM
		TRB->SAIDAS		+= XSD3->MOV_SAI
//		TRB->SAIDAS		+= XSD3->MOV_ENT
		TRB->( MsUnLock() )
	EndIf
	
	XSD3->( DbSkip() )

EndDo
*---------------------------------------------------------------------------------------

DBSelectArea("TRB")
TRB->( DBGoTop() )

//COPY TO "TRB.DBF" VIA "DBFCDXADS"
__CopyFile( "TRB.DBF" , "C:\" + "TRB.XLS" )       

TRB->(DBCloseArea())

cfile := "C:\TRB.XLS"

oExcelApp:= MsExcel():New()
oExcelApp:WorkBooks:Open( cfile)
oExcelApp:SetVisible(.T.)

Return

********************************************************************************************************************
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"

Static Function ATU18()
Local cQuery := ""

SD2->( DbSetOrder( 10 ) )

nEstru	:= 0
aEstru	:= {}
aEstrutura	:= {}
aFile	:= {}
aAdd(aFile,{"CODIGO",		"C",	TamSx3( "B1_COD" )[1],	TamSx3( "B1_COD")[2] } )
aAdd(aFile,{"COMPONENTE",	"C",	TamSx3( "B1_COD" )[1],	TamSx3( "B1_COD")[2] } )


oTemptable := FWTemporaryTable():New( "TRB")
oTemptable:SetFields( aFile )
oTempTable:AddIndex("index1", {"CODIGO"} )
oTempTable:Create()

//cArq := CriaTrab(aFile,.T.)
//dbUseArea(.T.,,cArq,"TRB",.T.)


//cInd := CriaTrab(NIL,.F.)
IndRegua("TRB",cInd,"CODIGO",,,"Selecionando Registros...")

DbSelectArea( "SB1" )
SB1->( DbSetOrder( 1 ))
SB1->( DbSeek( xFilial( "SB1" ) + "BR" ) )
ProcRegua( SB1->( LastRec() ) )

While !SB1->( Eof() ) .and. SB1->B1_FILIAL == xFilial( "SB1" ) .and. Left( SB1->B1_COD , 2 ) == "BR"
	aArea_SB1	:= SB1->( GetArea() )

	IncProc()

	SD2->( DbSeek( xFilial( "SD2" ) + SB1->B1_CODLMT + "20080101" , .T. ) )
	If	!SD2->( Eof() ) .and. Year( SD2->D2_EMISSAO ) == 2008 .and. SD2->D2_CODLMT == SB1->B1_CODLMT
		nEstru	:= 0
		aEstru	:= {}
		aEstru	:= Estrut( SB1->B1_COD )

		For nXX := 1 to Len( aEstru )
			RecLock( "TRB" , .T. )
			TRB->CODIGO		:= aEstru[ nXX , 2 ]
			TRB->COMPONENTE	:= aEstru[ nXX , 3 ]
			TRB->( MsUnLock() )
		Next

//		If	TRB->( LastRec() ) # 0
//			Exit
//		EndIf
		
	EndIf

	RestArea( aArea_SB1 )
	SB1->( DbSkip() )
EndDo

DBSelectArea("TRB")
TRB->( DBGoTop() )

//COPY TO "TRB.DBF" VIA "DBFCDXADS"
__CopyFile( "TRB.DBF" , "C:\" + "TRB.XLS" )       

TRB->(DBCloseArea())

cfile := "C:\TRB.XLS"

oExcelApp:= MsExcel():New()
oExcelApp:WorkBooks:Open( cfile)
oExcelApp:SetVisible(.T.)

Return

********************************************************************************************************************
Static Function ATU19()

SC2->( DbSetOrder( 1 ) )
SB1->( DbSetOrder( 1 ) )

SZC->( DbSetOrder( 1 ) )
SZC->( DbSeek( xFilial( "SZC" ) ) )
ProcRegua( SZC->( LastRec() ) )

While !SZC->( Eof() ) .and. SZC->ZC_FILIAL == xFilial( "SZC" )

	IncProc()
	
	If	Left( SZC->ZC_OP , 3 ) == "500"

		If	SC2->( DbSeek( xFilial( "SC2" ) + SZC->ZC_OP ) )

			SB1->( DbSeek( xFilial( "SB1" ) + SC2->C2_PRODUTO ) )
			
			RecLock( "SZC" )
			SZC->ZC_CODLMT	:= SC2->C2_CODLMT
			SZC->ZC_DENOM	:= SB1->B1_DENOM
			SZC->ZC_PRODUTO	:= SC2->C2_PRODUTO
			MsUnLock( "SZC" )
			
		EndIf

	EndIf
	
	SZC->( DbSkip() )

EndDo

Return

********************************************************************************************************************
Static Function ATU20()
/*
cQuery	:= "UPDATE " + RetSqlName( "SD1" )
cQuery	+= " SET D1_VUNIT = NVL((SELECT B6_PRUNIT"
cQuery	+= " FROM " + RetSqlName( "SB6" )
cQuery	+= " WHERE D_E_L_E_T_ = ' '"
cQuery	+= " AND B6_IDENT = D1_IDENTB6"
cQuery	+= " AND B6_DOC = D1_NFORI"
cQuery	+= " AND B6_SERIE = D1_SERIORI"
cQuery	+= " AND B6_CLIFOR = D1_FORNECE"
cQuery	+= " AND B6_LOJA = D1_LOJA"
cQuery	+= " AND B6_PRODUTO = D1_COD"
cQuery	+= " AND B6_FILIAL = '" + xFilial( "SB6" ) + "'" + "),'  ')"
cQuery	+= " WHERE D_E_L_E_T_ = ' '"

MemoWrite("ATU20.txt",cQuery)

MsgRun( OemToAnsi( "Atualizando poder 3ºs" ), OemToAnsi( "Aguarde..." ), {|| TcSqlExec( cQuery ) } )
*/

SB6->( DbSetOrder( 3 ) )

SD1->( DbSetOrder( 1 ) )
SD1->( DbSeek( xFilial( "SD1" ) ) )

ProcRegua( SD1->( LastRec() ) )

While !SD1->( Eof() ) .and. SD1->D1_FILIAL == xFilial( "SD1" )
	
	IncProc()

	If	!Empty( SD1->D1_IDENTB6 )

		// remessa
		SB6->( DbSeek( xFilial( "SB6" ) + SD1->( D1_IDENTB6 + D1_COD + "R" ) ) )
		While !SB6->( Eof() ) .and.	SB6->B6_FILIAL	== xFilial( "SB6" ) .and. ;
									SB6->B6_IDENT	== SD1->D1_IDENTB6 .and. ;
									SB6->B6_PRODUTO	== SD1->D1_COD .and. ;
									SB6->B6_PODER3	== "R"

			RecLock( "SD1" )
			SD1->D1_VUNIT	:= SB6->B6_PRUNIT
			SD1->D1_TOTAL	:= ( SD1->D1_QUANT * SD1->D1_VUNIT )
			SD1->( MsUnLock() )

			SB6->( DbSkip() )
		EndDo

		// devolução
		SB6->( DbSeek( xFilial( "SB6" ) + SD1->( D1_IDENTB6 + D1_COD + "D" ) ) )
		While !SB6->( Eof() ) .and.	SB6->B6_FILIAL	== xFilial( "SB6" ) .and. ;
									SB6->B6_IDENT	== SD1->D1_IDENTB6 .and. ;
									SB6->B6_PRODUTO	== SD1->D1_COD .and. ;
									SB6->B6_PODER3	== "D"

			RecLock( "SB6" )
			SB6->B6_PRUNIT	:= SD1->D1_VUNIT
			SB6->( MsUnLock() )

			SB6->( DbSkip() )
		EndDo

	EndIf
	
	SD1->( DbSkip() )

EndDo

Return

********************************************************************************************************************
Static Function ATU21()

SF2->( DbSetOrder( 2 ) )

SA1->( DbSeek( xFilial( "SA1" ) ) )
ProcRegua( SA1->( LastRec() ) )

While !SA1->( Eof() ) .and. SA1->A1_FILIAL == xFilial( "SA1" )
	
	IncProc()

	If	!SF2->( DbSeek( xFilial( "SF2" ) + SA1->( A1_COD + A1_LOJA ) ) )
		RecLock( "SA1" )
		SA1->A1_RISCO	:= "E"
		SA1->( MsUnLock() )
	Else
		lNaoComprou	:= .T.
		While !SF2->( Eof() ) .and. SF2->F2_FILIAL == xFilial( "SF2" ) .and. ;
									SF2->( F2_CLIENTE + F2_LOJA ) == SA1->( A1_COD + A1_LOJA )
			If	!Empty( SF2->F2_DUPL ) .and. SF2->F2_EMISSAO > CtoD( "31/12/2006" )
				lNaoComprou	:= .F.
				Exit
			EndIf
			SF2->( DbSkip() )
		EndDo
		If	lNaoComprou
			RecLock( "SA1" )
			SA1->A1_RISCO	:= "E"
			SA1->( MsUnLock() )
		EndIf
	EndIf
	
	SA1->( DbSkip() )
EndDo

Return

********************************************************************************************************************
Static Function ATU22()
/*
DbSelectArea( "SD1" )
cQuery	:= " SELECT SA2.A2_NOME AS FORNECEDOR"
cQuery	+= " ,SUM(SD1.D1_TOTAL+SD1.D1_VALIPI-SD1.D1_VALDESC+SD1.D1_VALFRE) AS VALOR"
cQuery	+= " FROM " + RetSqlName( "SD1" ) + " SD1"
cQuery	+= " INNER JOIN " + RetSqlName( "SA2" ) + " SA2 ON SD1.D1_FORNECE = SA2.A2_COD AND SD1.D1_LOJA = SA2.A2_LOJA"
cQuery	+= " AND SA2.D_E_L_E_T_ = ' '"
cQuery	+= " INNER JOIN " + RetSqlName( "SF4" ) + " SF4 ON SD1.D1_TES = SF4.F4_CODIGO"
cQuery	+= " AND SF4.D_E_L_E_T_ = ' '"
cQuery	+= " AND SF4.F4_DUPLIC = 'S'"
cQuery	+= " WHERE"
cQuery	+= " SD1.D_E_L_E_T_ = ' '"
cQuery	+= " AND SUBSTR(SD1.D1_DTDIGIT,1,4)='2008'"
cQuery	+= " GROUP BY SA2.A2_NOME"
cQuery	+= " ORDER BY SA2.A2_NOME"

cQuery := ChangeQuery( cQuery )

MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),'XSD1', .F., .T.)},OemToAnsi("Selecionando SD1"))
TcSetField( "XSD1",	"VALOR",	"N",	TamSx3( "D1_TOTAL" )[1],	TamSx3( "D1_TOTAL")[2] )

DbSelectArea( "XSD1" )
COPY TO "COMPRAS.DBF" VIA "DBFCDXADS"

XSD1->( DbCloseArea() )
*/

DbSelectArea( "SD1" )
cQuery	:= " SELECT SB1.B1_POSIPI AS CFISCAL"
cQuery	+= " ,SUM(SD1.D1_TOTAL) AS TOT"
cQuery	+= " ,SUM(SD1.D1_VALIPI) AS IPI"
cQuery	+= " ,SUM(SD1.D1_VALICM) AS ICM"
cQuery	+= " FROM " + RetSqlName( "SD1" ) + " SD1"
cQuery	+= " INNER JOIN " + RetSqlName( "SA2" ) + " SA2 ON SD1.D1_FORNECE = SA2.A2_COD AND SD1.D1_LOJA = SA2.A2_LOJA"
cQuery	+= " AND SA2.D_E_L_E_T_ = ' '"
cQuery	+= " INNER JOIN " + RetSqlName( "SF4" ) + " SF4 ON SD1.D1_TES = SF4.F4_CODIGO"
cQuery	+= " AND SF4.D_E_L_E_T_ = ' '"
//cQuery	+= " AND SF4.F4_DUPLIC = 'S'"
cQuery	+= " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SD1.D1_COD = SB1.B1_COD"
cQuery	+= " AND SB1.D_E_L_E_T_ = ' '"
cQuery	+= " WHERE"
cQuery	+= " SD1.D_E_L_E_T_ = ' '"
//cQuery	+= " AND SD1.D1_TIPO NOT IN ('B','D')
cQuery	+= " AND SUBSTR(SD1.D1_DTDIGIT,1,4)='2008'"
cQuery	+= " GROUP BY SB1.B1_POSIPI"
cQuery	+= " ORDER BY SB1.B1_POSIPI"

cQuery := ChangeQuery( cQuery )

MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),'XSD1', .F., .T.)},OemToAnsi("Selecionando SD1"))
TcSetField( "XSD1",	"TOT",	"N",	TamSx3( "D1_TOTAL" )[1],	TamSx3( "D1_TOTAL")[2] )
TcSetField( "XSD1",	"IPI",	"N",	TamSx3( "D1_VALIPI" )[1],	TamSx3( "D1_VALIPI")[2] )
TcSetField( "XSD1",	"ICM",	"N",	TamSx3( "D1_VALICM" )[1],	TamSx3( "D1_VALICM")[2] )

DbSelectArea( "XSD1" )
//COPY TO "COMPRAS.DBF" VIA "DBFCDXADS"

XSD1->( DbCloseArea() )

Return

********************************************************************************************************************
Static Function ATU23()
Local	nQtd	:= 0

SB1->( DbSetOrder( 1 ) )

oTemptable := FWTemporaryTable():New( "TRA")
oTempTable:Create()
//dbUseArea(.T.,"DBFCDX","\DEVELOP\CLAEST.DBF","TRA",.T.,.F.)

DbSelectArea( "TRA" )
TRA->( DbGoTop() )

ProcRegua( TRA->( LastRec() ) )

While !TRA->( Eof() )
	
	IncProc()
	
	If	SB1->( DbSeek( xFilial( "SB1" ) + Left( TRA->CODIGO , 15 ) ) )
		RecLock( "SB1" )
		SB1->B1_CLAEST	:= TRA->B1_CLAEST
		SB1->( MsUnLock() )
		nQtd++
	EndIf
	
	TRA->( DbSkip() )
EndDo

TRA->( DbCloseArea() )

Alert( "Atualizado " + Str( nQtd , 6 , 0 ) )

Return

********************************************************************************************************************
Static Function ATU24()
Local	nQtd	:= 0

SA1->( DbSetOrder( 5 ) )

oTemptable := FWTemporaryTable():New( "TRA")
oTempTable:Create()

//dbUseArea(.T.,"DBFCDX","\DEVELOP\SEGVEN.DBF","TRA",.T.,.F.)

DbSelectArea( "TRA" )
TRA->( DbGoTop() )

ProcRegua( TRA->( LastRec() ) )

While !TRA->( Eof() )
	
	IncProc()
	
	If	SA1->( DbSeek( xFilial( "SA1" ) + Left( TRA->CLIENTE , 20 ) ) )
		RecLock( "SA1" )
		SA1->A1_SEGVEN1	:= TRA->A1_SEGVEN1
		SA1->A1_SEGVEN2	:= TRA->A1_SEGVEN2
		SA1->( MsUnLock() )
		nQtd++
	EndIf
	
	TRA->( DbSkip() )
EndDo

TRA->( DbCloseArea() )

Alert( "Atualizado " + Str( nQtd , 6 , 0 ) )

Return

********************************************************************************************************************
Static Function ATU25()
Local	nQtd	:= 0

SA1->( DbSetOrder( 1 ) )


oTemptable := FWTemporaryTable():New( "TRA")
//oTemptable:SetFields( aStru )
//oTempTable:AddIndex("index1", {"COD"} )
oTempTable:Create()
//dbUseArea(.T.,"DBFCDX","\DEVELOP\CLIENTES.DBF","TRA",.T.,.F.)

DbSelectArea( "TRA" )
TRA->( DbGoTop() )

ProcRegua( TRA->( LastRec() ) )

While !TRA->( Eof() )
	
	IncProc()
	
	If	SA1->( DbSeek( xFilial( "SA1" ) + Left( TRA->A1_COD , 6 ) + Left( TRA->A1_LOJA , 2 ) ) )
		RecLock( "SA1" )
		SA1->A1_END		:= TRA->A1_END
		SA1->A1_MUN		:= TRA->A1_MUN
		SA1->A1_EST		:= TRA->A1_EST
		SA1->A1_BAIRRO	:= TRA->A1_BAIRRO
		SA1->A1_CODMUN	:= TRA->A1_CODMUN
		SA1->A1_COD_MUN	:= TRA->A1_COD_MUN
		SA1->A1_DDD		:= TRA->A1_DDD
		SA1->A1_CEP		:= TRA->A1_CEP
		SA1->A1_DDI		:= TRA->A1_DDI
		SA1->A1_TEL		:= TRA->A1_TEL
		SA1->A1_FAX		:= TRA->A1_FAX
		SA1->A1_ENDCOB	:= TRA->A1_ENDCOB
		SA1->A1_BAIRROC	:= TRA->A1_BAIRROC
		SA1->A1_CEPC	:= TRA->A1_CEPC
		SA1->A1_MUNC	:= TRA->A1_MUNC
		SA1->A1_ESTC	:= TRA->A1_ESTC
		SA1->A1_ENDENT	:= TRA->A1_ENDENT
		SA1->A1_BAIRROE	:= TRA->A1_BAIRROE
		SA1->A1_CEPE	:= TRA->A1_CEPE
		SA1->A1_MUNE	:= TRA->A1_MUNE
		SA1->A1_ESTE	:= TRA->A1_ESTE
		SA1->A1_ENDREC	:= TRA->A1_ENDREC
		SA1->A1_CGC		:= TRA->A1_CGC
		SA1->A1_INSCR	:= TRA->A1_INSCR
		SA1->( MsUnLock() )
	EndIf
	
	TRA->( DbSkip() )
EndDo

TRA->( DbCloseArea() )

Return
