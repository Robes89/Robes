User Function TRIGCD5()
local nX:=0
local hx:=0
local tpimp:=aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_TPIMP'   }) ]
//IF ALTERA  
   For nX := 1 To Len(aCols)
        N := nX //Atualiza linha
        
        If nX > 1 //.And. !Empty(aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_TPIMP'   }) ] ) 

            For hx:=1 To len(aheader)

          Do Case
                    Case AllTrim(aHeader[hx,2])=="CD5_NDI"
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_NDI'   }) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_NDI'   }) ]
                    Case AllTrim(aHeader[hx,2])=="CD5_FILIAL" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_FILIAL'}) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_FILIAL'   }) ]
                    Case AllTrim(aHeader[hx,2])=="CD5_DOC" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_DOC'   }) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_DOC'   }) ]
                    case AllTrim(aHeader[hx,2])=="CD5_SERIE"
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_SERIE' }) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_SERIE'   }) ]
                    case AllTrim(aHeader[hx,2])=="CD5_ESPEC" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_ESPEC' }) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_ESPEC'   }) ]
                    case AllTrim(aHeader[hx,2])=="CD5_LOJA" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_LOJA'  }) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_LOJA'   }) ]
                    case AllTrim(aHeader[hx,2])=="CD5_TPIMP" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_TPIMP' }) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_TPIMP'   }) ]
                    case AllTrim(aHeader[hx,2])=="CD5_DOCIMP" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_DOCIMP'}) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_DOCIMP'    }) ]
                    case AllTrim(aHeader[hx,2])=="CD5_BSPIS" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_BSPIS' }) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_BSPIS'   }) ]
                    case AllTrim(aHeader[hx,2])=="CD5_ALPIS" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_ALPIS' }) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_ALPIS'   }) ]
                    case AllTrim(aHeader[hx,2])=="CD5_VLPIS" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_VLPIS' }) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_VLPIS'   }) ]
                    case AllTrim(aHeader[hx,2])=="CD5_BSCOF" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_BSCOF' }) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_BSCOF'   }) ]
                    case AllTrim(aHeader[hx,2])=="CD5_LOCAL" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_LOCAL' }) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_LOCAL'   }) ]
                    case AllTrim(aHeader[hx,2])=="CD5_DTPCOF"
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_DTPCOF'}) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_DTPCOF'   }) ]
                    case AllTrim(aHeader[hx,2])=="CD5_DTPPIS" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_DTPPIS'}) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_DTPPIS'   }) ]
                    case AllTrim(aHeader[hx,2])=="CD5_DTDI"     
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_DTDI'  }) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_DTDI'  }) ]
                    case AllTrim(aHeader[hx,2])=="CD5_LOCDES" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_LOCDES'}) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_LOCDES'}) ]
                    case AllTrim(aHeader[hx,2])=="CD5_UFDES" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_UFDES' }) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_UFDES' }) ] 
                    case AllTrim(aHeader[hx,2])=="CD5_DTDES" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_DTDES' }) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_DTDES' }) ]
                    case AllTrim(aHeader[hx,2])=="CD5_CODEXP" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_CODEXP'}) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_CODEXP'}) ]
                    case AllTrim(aHeader[hx,2])=="CD5_NADIC" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_NADIC' }) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_NADIC' }) ]
                    case AllTrim(aHeader[hx,2])=="CD5_SQADIC" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_SQADIC'}) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_SQADIC'}) ]
                    case AllTrim(aHeader[hx,2])=="CD5_CODFAB" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_CODFAB'}) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_CODFAB'}) ]
                    case AllTrim(aHeader[hx,2])=="CD5_VTRANS" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_VTRANS'}) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_VTRANS'}) ]
                    case AllTrim(aHeader[hx,2])=="CD5_INTERM" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_INTERM'}) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_INTERM'}) ]
                    case AllTrim(aHeader[hx,2])=="CD5_LOJFAB" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_LOJFAB'}) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_LOJFAB'}) ]
                    case AllTrim(aHeader[hx,2])=="CD5_ACDRAW" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_ACDRAW'}) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_ACDRAW'}) ] 
                    case AllTrim(aHeader[hx,2])=="CD5_ALCOF" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_ALCOF'}) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) ==   'CD5_ALCOF'}) ]        
                    case AllTrim(aHeader[hx,2])=="CD5_UFTERC" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_UFTERC'}) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_UFTERC'}) ] 
                    case AllTrim(aHeader[hx,2])=="CD5_CNPJAE" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_CNPJAE'}) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_CNPJAE'}) ] 
                    case AllTrim(aHeader[hx,2])=="CD5_VAFRMM" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_VAFRMM'}) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_VAFRMM'}) ] 
                    case AllTrim(aHeader[hx,2])=="CD5_VLRIOF" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_VLRIOF'}) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_VLRIOF'}) ] 
                    case AllTrim(aHeader[hx,2])=="CD5_VLRII" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_VLRII'}) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_VLRII'  }) ] 
                    case AllTrim(aHeader[hx,2])=="CD5_DSPAD" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_DSPAD'}) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_DSPAD'  }) ] 
                    case AllTrim(aHeader[hx,2])=="CD5_BCIMP" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_BCIMP'}) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_BCIMP'  }) ] 
                    case AllTrim(aHeader[hx,2])=="CD5_VDESDI" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_VDESDI'}) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_VDESDI'}) ] 
                    case AllTrim(aHeader[hx,2])=="CD5_LOJEXP" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_LOJEXP'}) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_LOJEXP'}) ]   
                    case AllTrim(aHeader[hx,2])=="CD5_VLCOF" 
                        aCols[N, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_VLCOF'}) ] :=aCols[N-1, AScan(aHeader,{|x| AllTrim(x[2]) == 'CD5_VLCOF'  }) ]   
                    OTHERWISE
                Endcase
            Next hx      
        Endif
        
        /* 
        If ExistTrigger('CD5_NDI') 
            RunTrigger(2,nX,nil,,'CD5_NDI')
        EndIf
        */

    Next nX
  //  ENDIF   

Return(tpimp)
