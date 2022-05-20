#INCLUDE 'Protheus.ch'
#INCLUDE 'TbIconn.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} UFUNZIP
Funcao que descompacta os arquivos .GZ
@author  Rodrigo
@since   19/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
User Function UFUNZIP()    
    Local cDirSrv   
    Local aArquivos
    Local nI

    If Empty(FunName())
        PREPARE ENVIRONMENT EMPRESA '01' FILIAL '0101'
    EndIf

    //Diretorio onde ficam os arquivos GZ
    cDirSrv   := SuperGetMV('MV_NGINN  ', .F., '')

    If Empty(cDirSrv)
        MsgAlert('Parâmetro padrão MV_NGINN não configurado.')
        Return
    EndIf

    cDirSrv   := Alltrim(cDirSrv) + "\"
    
    //Monta um array com todos os arquivos GZ
    aArquivos := Directory(cDirSrv + "*.gz") 
        
   //Percorre todos os arquivos descompactando
   For nI := 1 To len(aArquivos)

        //Pega o nome do arquivo com e sem extensao
        cArquivo    := aArquivos[nI][1]
        cArqSemExt  := StrTran(Lower(cArquivo),'.gz','')
        
        //Tenta descompactar o arquivo
        If GzDecomp( cDirSrv +  cArquivo, cDirSrv )

            If FRename( cDirSrv +  cArqSemExt, cDirSrv + cArqSemExt + ".xml" ) == 0
                FErase( cDirSrv +  cArqSemExt )
                FErase( cDirSrv +  cArquivo )
            EndIf
        EndIf

    Next

Return
