User Function TRIGCD5()
Local nPosVal
Local nX

IF INCLUI 
   For nX := 1 To Len(aCols)
        N := nX //Atualiza linha
        If nX > 1 .And. Empty(aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_NDI'   }) ] ) 
            Do case AllTrim(aHeader[N,2])=="CD5_NDI"; 
                aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_NDI'   }) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_NDI'   }) ]
            Do case AllTrim(aHeader[N,2])=="CD5_DTDI";     
                aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_DTDI'  }) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_DTDI'  }) ]
            Do case AllTrim(aHeader[N,2])=="CD5_LOCDES"; 
                aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_LOCDES'}) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_LOCDES'}) ]
            Do case AllTrim(aHeader[N,2])=="CD5_UFDES"; 
                aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_UFDES' }) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_UFDES' }) ] 
            Do case AllTrim(aHeader[N,2])=="CD5_DTDES"; 
                aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_DTDES' }) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_DTDES' }) ]
            Do case AllTrim(aHeader[N,2])=="CD5_CODEXP"; 
                aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_CODEXP'}) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_CODEXP'}) ]
            Do case AllTrim(aHeader[N,2])=="CD5_NADIC"; 
                aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_NADIC' }) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_NADIC' }) ]
            Do case AllTrim(aHeader[N,2])=="CD5_SQADIC"; 
                aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_SQADIC'}) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_SQADIC'}) ]
            Do case AllTrim(aHeader[N,2])=="CD5_CODFAB"; 
                aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_CODFAB'}) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_CODFAB'}) ]
            Do case AllTrim(aHeader[N,2])=="CD5_VTRANS"; 
                aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_VTRANS'}) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_VTRANS'}) ]
            Do case AllTrim(aHeader[N,2])=="CD5_INTERM"; 
                aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_INTERM'}) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_INTERM'}) ]
        Endif
       
   Next nX
ENDIF   
Return nil
