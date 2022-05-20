/*/{Protheus.doc} FTTVSX001
Substituição de PUTSX1
@author Henrique Cunha
@since 14/09/2020
@version 1.0
/*/

User Function FTTVSX001(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,cTipo,nTamanho,nDecimal,;
                        nPresel,cGSC,cValid,cF3, cGrpSxg,cPyme,cVar01,cDef01,cDefSpa1,cDefEng1,;
	                    cCnt01,cDef02,cDefSpa2,cDefEng2,cDef03,cDefSpa3,cDefEng3,cDef04,cDefSpa4,;
	                    cDefEng4,cDef05,cDefSpa5,cDefEng5,aHelpPor,aHelpEng,aHelpSpa,cHelp)

Local _nRet      := 0	
Local _aArea     := GetArea()

Local _cInsert   := ""
Local _cGrupo	 := IIF(cGrupo 		== NIL, "", cGrupo)
Local _cOrdem    := IIF(cOrdem		== NIL, "", cOrdem)	
Local _cPergunt  := IIF(cPergunt    == NIL, "", cPergunt)
Local _cPerSpa   := IIF(cPerSpa		== NIL, "", cPerSpa)	
Local _cPerEng   := IIF(cPerEng     == NIL, "", cPerEng) 
Local _cVar      := IIF(cVar        == NIL, "", cVar)    
Local _cTipo     := IIF(cTipo       == NIL, "", cTipo)   
Local _nTamanho  := IIF(nTamanho    == NIL, 0 , nTamanho)
Local _nDecimal  := IIF(nDecimal    == NIL, 0 , nDecimal)
Local _nPresel   := IIF(nPresel     == NIL, 0 , nPresel) 
Local _cGSC      := IIF(cGSC        == NIL, "", cGSC)    
Local _cValid	 := IIF(cValid      == NIL, "", cValid)  
Local _cF3       := IIF(cF3         == NIL, "", cF3)     
Local _cGrpSxg   := IIF(cGrpSxg 	== NIL, "", cGrpSxg) 
Local _cPyme     := IIF(cPyme       == NIL, "", cPyme)   
Local _cVar01    := IIF(cVar01      == NIL, "", cVar01)  
Local _cDef01    := IIF(cDef01      == NIL, "", cDef01)  
Local _cDefSpa1  := IIF(cDefSpa1    == NIL, "", cDefSpa1)
Local _cDefEng1  := IIF(cDefEng1    == NIL, "", cDefEng1)
Local _cCnt01    := IIF(cCnt01      == NIL, "", cCnt01)  
Local _cDef02    := IIF(cDef02      == NIL, "", cDef02) 
Local _cDefSpa2  := IIF(cDefSpa2    == NIL, "", cDefSpa2)
Local _cDefEng2  := IIF(cDefEng2    == NIL, "", cDefEng2)
Local _cDef03    := IIF(cDef03      == NIL, "", cDef03)  
Local _cDefSpa3  := IIF(cDefSpa3    == NIL, "", cDefSpa3)
Local _cDefEng3  := IIF(cDefEng3    == NIL, "", cDefEng3)
Local _cDef04    := IIF(cDef04      == NIL, "", cDef04)  
Local _cDefSpa4  := IIF(cDefSpa4    == NIL, "", cDefSpa4)
Local _cDefEng4  := IIF(cDefEng4    == NIL, "", cDefEng4)
Local _cDef05    := IIF(cDef05      == NIL, "", cDef05)  
Local _cDefSpa5  := IIF(cDefSpa5    == NIL, "", cDefSpa5)
Local _cDefEng5  := IIF(cDefEng5    == NIL, "", cDefEng5)
Local _aHelpPor  := IIF(aHelpPor    == NIL, {}, aHelpPor)
Local _aHelpEng  := IIF(aHelpEng    == NIL, {}, aHelpEng)
Local _aHelpSpa  := IIF(aHelpSpa    == NIL, {}, aHelpSpa)
Local _cHelp     := IIF(cHelp       == NIL, "", cHelp)   

DBSelectArea("SX1")
SX1->(DBSetOrder(1))

If !DBSeek(PADR(_cGrupo,LEN(X1_GRUPO))+AllTrim(_cOrdem))
    
    If !MPDicInDB()

        RECLOCK("SX1",.T.)

            SX1->X1_GRUPO	:=	_cGrupo
            SX1->X1_ORDEM	:=	_cOrdem
            SX1->X1_PERGUNT	:=	_cPergunt
            SX1->X1_PERSPA	:=	_cPerSpa
            SX1->X1_PERENG	:=	_cPerEng
            SX1->X1_VARIAVL	:=	_cVar
            SX1->X1_TIPO	:=	_cTipo 
            SX1->X1_TAMANHO	:=	_nTamanho
            SX1->X1_DECIMAL	:=	_nDecimal
            SX1->X1_PRESEL	:=	_nPresel
            SX1->X1_GSC	    :=	_cGSC
            SX1->X1_VALID	:=	_cValid
            SX1->X1_F3  	:=	_cF3 
            SX1->X1_GRPSXG	:=	_cGrpSxg
            SX1->X1_PYME	:=	_cPyme
            SX1->X1_VAR01	:=	_cVar01
            SX1->X1_DEF01	:=	_cDef01
            SX1->X1_DEFSPA1	:=	_cDefSpa1
            SX1->X1_DEFENG1	:=	_cDefEng1
            SX1->X1_CNT01	:=	_cCnt01
            SX1->X1_DEF02	:=	_cDef02
            SX1->X1_DEFSPA2	:=	_cDefSpa2
            SX1->X1_DEFENG2	:=	_cDefEng2
            SX1->X1_DEF03	:=	_cDef03
            SX1->X1_DEFSPA3	:=	_cDefSpa3
            SX1->X1_DEFENG3	:=	_cDefEng3
            SX1->X1_DEF04	:=	_cDef04
            SX1->X1_DEFSPA4	:=	_cDefSpa4
            SX1->X1_DEFENG4	:=	_cDefEng4
            SX1->X1_DEF05	:=	_cDef05
            SX1->X1_DEFSPA5	:=	_cDefSpa5
            SX1->X1_DEFENG5	:=	_cDefEng5
            SX1->X1_HELP	:=	_cHelp

        SX1->(MSUnlock())

    Else
        _cInsert := "   INSERT INTO " + RetSqlName("SX1")  
        _cInsert += "   ( "
        _cInsert += "   X1_GRUPO, X1_ORDEM, X1_PERGUNT, X1_PERSPA, X1_PERENG, X1_VARIAVL, X1_TIPO, X1_TAMANHO, "	
        _cInsert += "   X1_DECIMAL, X1_PRESEL, X1_GSC, X1_VALID, X1_F3, X1_GRPSXG, X1_PYME, X1_VAR01, X1_DEF01, "	
        _cInsert += "   X1_DEFSPA1, X1_DEFENG1, X1_CNT01, X1_DEF02, X1_DEFSPA2, X1_DEFENG2, X1_DEF03, X1_DEFSPA3, "
        _cInsert += "   X1_DEFENG3, X1_DEF04, X1_DEFSPA4, X1_DEFENG4, X1_DEF05, X1_DEFSPA5 X1_DEFENG5, X1_HELP "
        _cInsert += "   ) "
        _cInsert += "   VALUES "
        _cInsert += "   ( "
        _cInsert +=     _cGrupo + ", " + _cOrdem + ", " + _cPergunt + ", " + _cPerSpa + ", " + _cPerEng + ", "
        _cInsert +=     _cVar + ", " + _cTipo + ", " + cValToChar(_nTamanho) + ", " + cValToChar(_nDecimal) + ", " + cValToChar(_nPresel) + ", " 
        _cInsert +=     _cGSC + ", " + _cValid + ", " + _cF3 + ", " + _cGrpSxg + ", " + _cPyme + ", " 
        _cInsert +=     _cVar01 + ", " + _cDef01 + ", " + _cDefSpa1 + ", " + _cDefEng1 + ", " + _cCnt01
        _cInsert +=     _cDef02 + ", " + _cDefSpa2 + ", " + _cDefEng2 + ", " + _cDef03 + ", " + _cDefSpa3
        _cInsert +=     _cDefEng3 + ", " + _cDef04 + ", " + _cDefSpa4 + ", " + _cDefEng4 + ", " + _cDef05
        _cInsert +=     _cDefSpa5 + ", " + _cDefEng5 + ", " + _cHelp
        _cInsert += "   ) "
        
        _nRet := TcSqlExec(_cInsert)
		If _nRet <> 0
            FwLogMsg("INFO", , "INSERT", FunName(), "", "01", TCSqlError(), 0, (DtoS(DATE())+TIME()), {}) 
        EndIf

    EndIf

EndIf

SX1->(DBCloseArea())
RestArea(_aArea)

Return Nil
