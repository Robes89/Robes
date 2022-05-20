#Include 'Protheus.ch'

User Function GATRISCO()

Local nValor		:= ""
Local nRiscoB		:= SuperGetMv("MV_XVALB",.F.,500000)
Local nRiscoC		:= SuperGetMv("MV_XVALC",.F.,250000)
Local nRiscoD      := SuperGetMv("MV_XVALD",.F.,50000)
Local nRiscoF      := SuperGetMv("MV_XVALF",.F.,25000)
Local nRiscoG      := SuperGetMv("MV_XVALG",.F.,12500)
Local nRiscoH      := SuperGetMv("MV_XVALH",.F.,6000)
Local nRiscoI      := SuperGetMv("MV_XVALI",.F.,3000)
Local nRiscoJ      := SuperGetMv("MV_XVALJ",.F.,1500)
Local nRiscoK      := SuperGetMv("MV_XVALK",.F.,750)
Local nRiscoL      := SuperGetMv("MV_XVALL",.F.,375)

	If M->A1_RISCO == "A"                                                  		
		nValor := 0
	elseif M->A1_RISCO == "B"
		nValor	:= nRiscoB
	elseif M->A1_RISCO == "C"
		nValor	:= nRiscoC
	elseif M->A1_RISCO == "D"
        nValor  := nRiscoD
    elseif M->A1_RISCO == "F"
        nValor  := nRiscoF
    elseif M->A1_RISCO == "G"
        nValor  := nRiscoG
    elseif M->A1_RISCO == "H"
        nValor  := nRiscoH
    elseif M->A1_RISCO == "I"
        nValor  := nRiscoI
    elseif M->A1_RISCO == "J"
        nValor  := nRiscoJ
    elseif M->A1_RISCO == "K"
        nValor  := nRiscoK
    elseif M->A1_RISCO == "L"
        nValor  := nRiscoL
    else
		nValor := 0
	EndIf
		
Return (nValor)

