#include "rwmake.ch"    
#include "PROTHEUS.ch"

User Function M410STTS()                                
local llRet	:= .T.


/*  
	FUNÇÃO DE CALCULAR E GRAVAR A CUBAGEM DOS ITENS DA NOTA
	Especifico TEAM TEX -  MARCOS BIDO - 25/05/18
*/

//	Guarda o Pedido Posicionado (imediatamente apos a gravacao) 

_cAlias := Alias()
_cOrder := IndexOrd()
_cRecno := Recno()

//	MSGALERT("M410STTS - 29/05")
    
dbSelectArea("SC5")
_cNumPed  := SC5->C5_NUM
_nCub01	  := 0
_nCub02	  := 0        

dbSelectArea("SB5")
dbSetOrder(1)

// posiciona nos itens do pedido                                             
dbSelectArea("SC6")
dbSetOrder(1)

IF dbSeek( xFilial("SC6") + _cNumPed )
        
	Do While !Eof() .and. SC6->C6_NUM == _cNumPed
		_cCodProd := SC6->C6_PRODUTO
		
 		dbSelectArea("SB5")		
		if !dbSeek(xFilial("SB5") + _cCodProd )    
		  	MSGALERT("CODIGO DO PRODUTO NAO CADASTRADO NO SB5, NAO SERA CALCULADO CUBAGEM")
		else                
			If SC6->C6_XCXMAST == "1"
				If SB5->( !Empty(B5_XM3MAST) .OR. !Empty(B5_XPESMAS) )
					_nCub01		+= NoRound( ( SB5->B5_XM3MAST * SC6->C6_QTDVEN ) , 4 )
					_nCub02		+= NoRound( ( SB5->B5_XPESMAS * SC6->C6_QTDVEN ) , 4 )
				EndIf
			ElseIf SC6->C6_XCXMAST == "2"
				If SB5->( !Empty(B5_XMETCUB) .OR. !Empty(B5_XPESCUB) )
					_nCub01		+= NoRound( ( SB5->B5_XMETCUB * SC6->C6_QTDVEN ) , 4 )
					_nCub02 	+= NoRound( ( SB5->B5_XPESCUB * SC6->C6_QTDVEN ) , 4 )
				EndIf			
			EndIf
		
		endif

		dbSelectArea("SC6")
    	dbSkip()
	Enddo              

	// grava informações no SC5                                            
	                            
    dbSelectArea("SC5")
    
	//-- Atualiza C5_MENNOTA do pedido de venda posicionado inicialmente
	If SC5->( MsSeek( xFilial("SC5") + _cNumPed )   ) 
			RecLock( "SC5" , .F. )
			SC5->C5_PCUB01 := _nCub01
			SC5->C5_PCUB02 := _nCub02
			MSUNLOCK()     // Destrava o registro
		EndIf
	
endif

// restaura ponteiros dos arquivos

dbSelectArea(_cAlias)
dbSetOrder(_cOrder)
dbGoto(_cRecno)

Return llRet
                                                         
