#INCLUDE "rwmake.ch"       

// Rotina		: CONSIG
// Descrição	: Obs. Livros fiscais NF de consignação
// Obs			: Chamada da Formula 014 
// Data			: 13/01/05
// Autor        : Daniel Gondran     
//#FAP20170425  - Alterado texto para exibição no relatório conforme solicitação da Isabel 

User Function CONSIG14()
Local _cString  := ''
Local cAlias74  := GetNextAlias()

If AllTrim(FunName()) $ "MATR930/MATR920"  
	_aSvAlias := {Alias(),IndexOrd(),Recno()}
	///_cString  := ""
	lPrim     := .T.

	dbSelectArea("SF2")
	oldOrdF2 := IndexOrd()
	oldRecF2 := Recno()
	dbSetOrder(1)
	If dbSeek(xFilial("SF2") + SF3->F3_NFISCAL + SF3->F3_SERIE + SF3->F3_CLIEFOR + SF3->F3_LOJA)	
		_cString  := "S Fat Consig. NF "    // Venda em Consignacao industrial - NF "   //#FAP20170425
		nConsig   := 0
		dbSelectArea("SD2")
		oldOrdD2 := IndexOrd()
		oldRecD2 := Recno()
		dbSetOrder(3)
	
		dbSeek(xFilial("SD2") + SF3->F3_NFISCAL + SF3->F3_SERIE + SF3->F3_CLIEFOR + SF3->F3_LOJA)
		do While !Eof() .and. D2_FILIAL == xFilial("SD2") .and. D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA;
										== SF3->F3_NFISCAL + SF3->F3_SERIE + SF3->F3_CLIEFOR + SF3->F3_LOJA
			SF2->(dbSeek(xFilial("SF2") + SD2->D2_NFORI + IIF(SD2->D2_NFORI<="089707","ZZZ",SD2->D2_SERIORI)))							
			If Substr(D2_CF,2,3) == "111"							
				If lPrim 
					_cString += D2_NFORI + "/" + D2_SERIORI  // + " de " + Dtoc(SF2->F2_EMISSAO) alterado por regina 25/01/12
					lPrim := .F.
				Else
					_cString += ", " + D2_NFORI + "/" + D2_SERIORI // + " de " + Dtoc(SF2->F2_EMISSAO)  alterado por regina 25/01/12
				Endif
				nConsig += D2_TOTAL
			Endif
			dbSkip()
		Enddo
		_cString += " Total: " + AllTrim(Str(nConsig,12,2))
		dbSetOrder(oldOrdD2)
		dbGoto(oldRecD2)
	Endif
	dbSelectArea("SF2")
	dbSetOrder(oldOrdF2)
	dbGoto(oldRecF2)
	DbSelectArea(_aSvAlias[1])
	DbSetOrder(_aSvAlias[2])
	DbGoTo(_aSvAlias[3])
	Return (_cString)
ElseIf AllTrim(FunName()) $ "SPEDFISCAL" 
     
	 /*
	 SF2->(DbSetOrder(1))  
	 If SF2->(DbSeek(xFilial("SF2") + PadR(SF3->F3_NFISCAL,TamSx3('F2_DOC')[1]) + PadR(SF3->F3_SERIE,TamSx3('F2_SERIE')[1]) + PadR(SF3->F3_CLIEFOR,TamSx3('F2_CLIENTE')[1])  + PadR(SF3->F3_LOJA,TamSx3('F2_LOJA')[1])  ))
	    _cString := Substr(SF2->F2_MENS_P, AT(  "Ret.NF" , alltrim(SF2->F2_MENS_P)) + 8 , LEN(Alltrim(SF2->F2_MENS_P))  - (AT(  "Ret.NF" , alltrim(SF2->F2_MENS_P)) + 8 ) + 2 )
	 endif
	 ////select DISTINCT (D2_NFORI+'-'+RTRIM(D2_SERIORI)+'-'+convert(varchar, CAST(D2_EMISSAO AS DATETIME), 103)) NFORI
	 */
    
	Iif(Select(cAlias74) > 0, (cAlias74)->(DbCloseArea()),)
	        
	BeginSQL Alias cAlias74
		Select DISTINCT D2_NFORI,D2_SERIORI
		from %table:SD2% 
		Where %notDel%
		and D2_FILIAL   = %xFilial:SD2%
		and D2_DOC    = %Exp:SF3->F3_NFISCAL%
		and D2_SERIE  = %Exp:SF3->F3_SERIE%			
		and D2_CLIENTE  = %Exp:SF3->F3_CLIEFOR%
		and D2_LOJA     = %Exp:SF3->F3_LOJA%
	EndSQL	

   (cAlias74)->(DbGoTop())
   While !(cAlias74)->(EOF())
   
         SF2->(DbSetOrder(1))  
		 If SF2->(DbSeek(xFilial("SF2") + PadR((cAlias74)->D2_NFORI,TamSx3('F2_DOC')[1]) + PadR((cAlias74)->D2_SERIORI,TamSx3('F2_SERIE')[1]) + PadR(SF3->F3_CLIEFOR,TamSx3('F2_CLIENTE')[1])  + PadR(SF3->F3_LOJA,TamSx3('F2_LOJA')[1])  ))

            _cString := _cString + Alltrim((cAlias74)->D2_NFORI) + '-' + Alltrim((cAlias74)->D2_SERIORI) + '-' + DTOC(SF2->F2_EMISSAO)  + '  ' 
            
	     endif 
   	   		                      					                      		
		(cAlias74)->(DbSkip())
   Enddo

  (cAlias74)->(DbCloseArea())
      
  _cString := alltrim(CCE->CCE_DESCR) + ' ' + _cString
        
   Return (_cString)
Else
     Return()
Endif