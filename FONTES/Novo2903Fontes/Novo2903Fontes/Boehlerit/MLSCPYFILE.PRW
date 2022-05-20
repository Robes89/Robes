#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "protheus.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ MLSCpyFileบ Autor ณ Fernando Pacheco  บ Data ณ 27/06/16    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Programa que realiza gera็ใo de arquivo para DBF           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

USER FUNCTION  MLSCpyFile(cOrigem,cDestino,lBack)

Local lRet := .f.  
Local hFile1, hFile2
Local cBuffer, nBuffer := 0, nRead, nReadTot := 0, nTotal := 0

If(lBack==NIL,lBack:=.F.,)
Begin Sequence   

   hFile1 := FOpen(cOrigem,0) // Abre origem somente para leitura
   
   IF hFile1 == -1 // Erro na abertura do arquivo
      If !lBack
         Help("", 1, "Erro na abertura do arquivo nro.",,LTrim(Str(FError())),1,32)
      EndIf
      Break
   Endif
   
   hFile2 := FCreate(cDestino,0) // Cria destino 
   
   IF hFile2 == -1 // Erro na criacao do arquivo
     If !lBack
        Help("", 1, "Erro na cria็ใo do arquivo nro. ",,LTrim(Str(FError())),1,31)
      EndIf
      Break
   Endif
   
   nTotal := FSeek(hFile1,0,2) // Tamanho do Arquivo
   
   // Tamanho do buffer 
   nBuffer := Min(50*1024,nTotal) // Aloca no maximo 50kb
   
   // Posiciona no 1o. Byte
   FSeek(hFile1,0,0)
   
   While nReadTot < nTotal
      cBuffer  := Space(nBuffer) // Aloca buffer
      nRead    := FRead(hFile1,@cBuffer,nBuffer) // Efetua leitura
      nReadTot += nRead
      
      IF (nRead <> nBuffer .And. nReadTot <> nTotal)
         If !lBack
            Help("", 1, "Erro na leitura do arquivo")
         EndIf
         Break
      Endif
      
      FWrite(hFile2,cBuffer,nRead)
   Enddo
   
   FClose(hFile1)
   FClose(hFile2)
   
   lRet := .t.
   
End Sequence

Return lRet
