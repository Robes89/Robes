#include "rwmake.ch"
#DEFINE ENTER CHR(13) + CHR(10) 
/*
Ponto de Entrada na Exclusão de Nota Fiscal
*/
User Function MS520VLD()

lRet := .t.
dbSelectArea("SD2")
dbSetOrder(3)
If dbSeek(xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE))
   While SD2->(!Eof()) .and. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE) == SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE)
      IF Substr(SD2->D2_CF,2,3) $ "912"  .or.  Substr(SD2->D2_CF,2,3) $ "917" 

/*      IF	(( Substr(SD2->D2_CF,2,3) $ "912" ) .or. ( Substr( SD2->D2_CF , 2 , 3 ) $ "949" .and. ;
		SF4->( DbSeek( xFilial( "SF4" ) + SD2->D2_TES ) ) .and. "EMPRES" $ Upper( SF4->F4_TEXTO ) )) .OR.;
		( Substr(SD2->D2_CF,2,3) $ "917" ) 
*/    
   		cLocOrig := " "
    	If Substr(SD2->D2_CF,2,3) $ "912" 
	   		cLocOrig  := "03"
       		cMsg := "Nota Fiscal de Demonstração/Mostruário: " + Alltrim(SD2->D2_DOC) + ENTER + ENTER
		ElseIf Substr(SD2->D2_CF,2,3) $ "917" 
		    cLocOrig  := "02"
       		cMsg := "Nota Fiscal de Consignação: " + Alltrim(SD2->D2_DOC) + ENTER + ENTER
		Endif   
    	If !Empty(cLocOrig)    
    	   nTotQtd := 0
      	   dbSelectArea("SB2")           
           dbSetOrder(1)
     	   If dbSeek(xFilial("SB2") + SD2->D2_COD + cLocOrig)
          		nTotQtd := SB2->B2_QATU - SB2->B2_QEMP
     	   Endif 

           If nTotQtd < SD2->D2_QUANT 

	      	  cMsg += "O Produto "+Alltrim(SD2->D2_COD)+" do armazém "+Alltrim(cLocOrig)+" selecionado não contem saldo suficiente para processamento."+ ENTER + ENTER
          	  cMsg += "Saldo atual: "+Str(nTotQtd,12,2)+", Quantidade processada: "+str(SD2->D2_QUANT,12,2)+ ENTER + ENTER +"MS520VLD"
	      	  Alert(cMsg)
	      	  MaViewSB2(SD2->D2_COD)
	      	  Alert("O saldo ficará negativo!"+ENTER+ENTER+"Operação de Exclusão para esta Nota Fiscal não será continuada!")
		  	  lRet := .f.//MarkBrow("SF2","F2_OK",,,lSeleciona,GetMark(,"SF2","F2_OK"))
           Endif
    	Endif
	  Endif
	  dbSelectArea("SD2")
	  SD2->(dbSkip())
   Enddo	  
Endif
Return(lRet)