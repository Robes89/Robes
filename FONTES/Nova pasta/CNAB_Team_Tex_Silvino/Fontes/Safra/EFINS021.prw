#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³EFINS021  ºAutor  ³smartins 	     º Data ³  02/07/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Customização para tratamento do Cnab SAFRAPAG das Posições º±±
±±º          ³ 156 a 165. (Agencia e Conta com Digito).                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 						                  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function EFINS021()
Local cConta := ""
If AllTrim(SA2->A2_BANCO) $ "399"	// Banco HSBC
	cConta := Strzero(Val(SA2->A2_NUMCON),8)	// 156 a 163
	cConta += AllTrim(SA2->A2_DVCTA)			// 164 a 165
Else	// Outros Bancos
	cConta := Strzero(Val(SA2->A2_NUMCON),9)	// 156 a 164
	cConta += Right(Trim(SA2->A2_DVCTA),1)		// 165 a 165
EndIf
Return cConta