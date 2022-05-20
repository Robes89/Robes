User Function AJ_ESC()

  Processa({|| AJRC() },"Ajustando o SRA - DV Agência")

Return
 

Static Function AJRC()

 dbUseArea(.T.,, "\DATA\DVAGE.DTC","ZZ1",.F.)  // Abrir exclusivo no Sigaadv
 cArqNtx  := CriaTrab(NIL,.f.)
 cIndCond :="ALLTRIM(BCOAGE)"
 IndRegua("ZZ1",cArqNtx,cIndCond,,,"Selecionando registros...")	
 
 DBSELECTAREA("SRA")
 DBSETORDER(1)
          
 ProcRegua(RecCount())                                       
 DBGOTOP()                              
 
 While !Eof()
   IncProc()
 
   DBSELECTAREA("ZZ1") 
   IF DBSEEK(ALLTRIM(SRA->RA_BCDEPSA))
    DBSELECTAREA("SRA")   
      RECLOCK("SRA",.F.)

	   SRA->RA_DVAGE := ZZ1->DV
	   	   
      MSUNLOCK()
   ENDIF
   
   DBSELECTAREA("SRA")
   DBSKIP()

 ENDDO
                           
 DBSELECTAREA("ZZ1")
 DBCLOSEAREA()
Return