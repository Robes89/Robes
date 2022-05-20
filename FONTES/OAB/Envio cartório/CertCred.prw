#INCLUDE "TOTVS.ch"
#INCLUDE 'FWPRINTSETUP.ch'
#INCLUDE "RPTDEF.ch"
#INCLUDE "TBICONN.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "COLORS.CH"
#include 'Fileio.ch' 
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch" 

/*/{Protheus.doc} Certidão de crédito
Juliano Souza 
Impressão da Certidão de crédito
@since 27/04/2021
/*/

User Function Certcred(cChave)

	Local oReport
	Local cLocal          := "E:\TOTVS_HML\protheus12\protheus_data\" //"E:\TOTVS\Microsiga\Protheus12\HML\" //GetSrvProfString( "StartPath","" )
	Local cPath           := "Cartorio\"
	Local cImage          := "LogoOab.png"
	Local lAdjustToLegacy := .T.
	Local lPreview		  := .F.
	Local lDisableSetup   := .T.
	Local nLin 	          := 10
	Local cLogo		      := cLocal + cPath + cImage
	Local cArq			  := ''
	Local cCode64  		  := ''
	Private cLocalImp     := cLocal + cPath
	Private cLocalPDf     := cLocal + cPath"

	Private nAjusteLin 	  := -100
	Private nAjusteCol    := -200

	dbSelectArea("SE1")
	SE1->(dbSetOrder(1))

	If SE1->(MsSeek(cChave))

		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		SA1->(MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))

		If .Not. lDisableSetup
			cPathPDF := cLocalPDf
			cLocal	 := cLocalPDf
		Else
			cPathPDF := GetTempPath()
			lPreview := .T.
		EndIf

		lDisableSetup := .T.
		cPathPDF := cLocalPDf
		cLocal	 := cLocalPDf

		cNomeArq := "CERT"+Alltrim(SA1->A1_COD)+Left(Time(),2) + Right(Time(),2)+".rel

		oReport :=FWMsPrinter():New(cNomeArq,IMP_PDF,lAdjustToLegacy,cLocalImp,lDisableSetup,,,,.F.,,.F.,.F.)
		oReport:SetResolution(78)
		oReport:SetPortrait()   
		oReport:cPathPDF := cLocal
		oReport:cFILEPRINT := oReport:CPATHPRINT+oReport:CFILENAME
		oReport:SetMargin(20,20,20,20)

		oReport:SetPaperSize(DMPAPER_A4)

		oFonte01	:= TFont():New("Times New Roman",,-08,,.T.)
		oFonte02	:= TFont():New("Times New Roman",,-10,,.T.,,,,.F.)
		oFonte03	:= TFont():New("Times New Roman",,-12,,.T.,,,,.F.)
		oFonte04	:= TFont():New("Times New Roman",,-14,,.T.)
		oFonte05	:= TFont():New("Times New Roman",,-16,,.T.)
		oFonte06	:= TFont():New("Times New Roman",,-18,,.T.,,,,.F.)
		oFonte07	:= TFont():New("Times New Roman",,-20,,.T.,,,,.F.)
		oFonte08	:= TFont():New("Times New Roman",,-22,,.T.)
		oFonte09	:= TFont():New("Times New Roman",,-24,,.T.,,,,.F.)

		oFonte01n	:= TFont():New("Times New Roman",,-08,,.F.)
		oFonte02n	:= TFont():New("Times New Roman",,-10,,.F.,,,,.F.)
		oFonte03n	:= TFont():New("Times New Roman",,-12,,.F.,,,,.F.)
		oFonte04n	:= TFont():New("Times New Roman",,-14,,.F.)
		oFonte05n	:= TFont():New("Times New Roman",,-16,,.F.)
		oFonte06n	:= TFont():New("Times New Roman",,-18,,.F.,,,,.F.)
		oFonte07n	:= TFont():New("Times New Roman",,-20,,.F.,,,,.F.)
		oFonte08n	:= TFont():New("Times New Roman",,-22,,.F.)
		oFonte09n	:= TFont():New("Times New Roman",,-24,,.F.,,,,.F.)

		oReport:StartPage() 

		oReport:Box( 002, 10, 3000, 2520, "-4")

		nLin += 100


		nLin := 400
		oReport:Say( nLin, 670, "CERTIDÃO DE CRÉDITO OAB-SP",oFonte08)

		nLin += 130

		oReport:Say( nLin, 180, "No uso das atribuições previstas no art. 46, da Lei Federal n° 8.906/94 e Resolução nº 03/14, certifico, para os",oFonte05n)
		nLin += 42
		oReport:Say( nLin, 180, "devidos fins, que o advogado abaixo qualificado, possui débito no valor de:",oFonte05n)
		nLin += 42
		oReport:Say( nLin, 180, "R$ " + Transform(SE1->E1_VALOR,"999,999.99") + "("+ Extenso(SE1->E1_VALOR) + ")",oFonte05n)
		nLin += 42
		oReport:Say( nLin, 180, ", razão pelo qual, lavra - se a presente certidão que constitui título executivo extrajudicial.",oFonte05n)
		nLin += 42

		nLin += 130

		oReport:Say( nLin, 580, "Devedor(a): "+ Alltrim(SA1->A1_NOME) + " CPF: " + Alltrim(SA1->A1_CGC),oFonte06n)
		nLin += 45
		oReport:Say( nLin, 580, "OAB: " + Alltrim(SA1->A1_XCODOAB),oFonte06n)
		nLin += 45
		oReport:Say( nLin, 580, "Endereço: " + Alltrim(SA1->A1_END) + " Nº:  Complemento: " ,oFonte06n)
		nLin += 45
		oReport:Say( nLin, 580, "Bairro: " + Alltrim(SA1->A1_BAIRRO) + " Cidade: " + Alltrim(SA1->A1_MUN),oFonte06n)
		nLin += 45
		oReport:Say( nLin, 580, "Estado: " + Alltrim(SA1->A1_EST) + " CEP: " + Alltrim(SA1->A1_CEP),oFonte06n)

		nLin += 150

		oReport:Line( nLin, 180, nLin, 2200 ) //Horizontal primeira

		oReport:Say( nLin+63, 185, "Anuidade",oFonte04)
		oReport:Say( nLin+63, 405, "Valor Titulo",oFonte04)
		oReport:Say( nLin+63, 630, "Emissao",oFonte04)
		oReport:Say( nLin+63, 850, "Vencimento",oFonte04)
		oReport:Say( nLin + 30, 1330, "Encargos",oFonte04)


		oReport:Say( nLin+73, 1060, "Multa",oFonte04)
		oReport:Say( nLin+73, 1280, "Subtotal(A)",oFonte04)
		oReport:Say( nLin+73, 1500, "CM IPC-FIPE",oFonte04)
		oReport:Say( nLin+73, 1720, "Juros 1% a.m",oFonte04)
		oReport:Say( nLin+73, 1950, "Saldo",oFonte04)

		oReport:Say( nLin+73, 1060, "Multa",oFonte04)
		oReport:Say( nLin+73, 1280, "Subtotal(A)",oFonte04)
		oReport:Say( nLin+73, 1500, "CM IPC-FIPE",oFonte03)
		oReport:Say( nLin+73, 1720, "Juros 1% a.m",oFonte03)
		oReport:Say( nLin+73, 1950, "Saldo",oFonte04)

		oReport:Line( nLin+50, 1060, nLin+50, 1940 ) //Horizontal primeira

		oReport:Line( nLin+150, 180, nLin+150, 2200 ) //Horizontal primeira

		oReport:Line( nLin   , 180, nLin +350 , 180)   //vertical esquerda
		oReport:Line( nLin   , 2200, nLin + 350, 2200)   //vertical direita

		//VERTICAIS MEIO
		oReport:Line( nLin   , 180, nLin +350 , 180)   //vertical esquerda
		oReport:Line( nLin   , 400, nLin +350 , 400)   //vertical esquerda
		oReport:Line( nLin   , 620, nLin +350 , 620)   //vertical esquerda
		oReport:Line( nLin   , 840, nLin +350 , 840)   //vertical esquerda
		oReport:Line( nLin   , 1060, nLin +350 , 1060)   //vertical esquerda
		oReport:Line( nLin +40  , 1280, nLin +350 , 1280)   //vertical esquerda
		oReport:Line( nLin +40  , 1500, nLin +350 , 1500)   //vertical esquerda
		oReport:Line( nLin +40  , 1720, nLin +350 , 1720)   //vertical esquerda
		oReport:Line( nLin   , 1940, nLin +350 , 1940)   //vertical esquerda

		oReport:Line( nLin + 350, 180, nLin + 350, 2200 ) //Horizontal Baixo

		If File(cLogo)
			oReport:SayBitmap(45,1000,cLogo,400,300)
		Endif 

		oReport:EndPage()
		oReport:Preview()

		cPathRecibo := oReport:cFILEPRINT
		cNumRecibo	:= oReport:CFILENAME

		cArq :=  FOPEN( cLocalImp+strtran(cNomeArq,".rel",".Pdf")) 

		If cArq <> -1
			nLen := fSeek(cArq,0,2)  
			fSeek(cArq,0,0)
			cBuffer  := ""
			nBtLidos  := FREAD(cArq, @cBuffer, nLen)
			cArqInf  := @cBuffer  		
			fclose(cArq)		
			cCode64 := Encode64(cArqInf)
		Endif 
	Endif 

Return cCode64
