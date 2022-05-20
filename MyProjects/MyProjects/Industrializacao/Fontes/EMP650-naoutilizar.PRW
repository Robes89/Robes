User Function EMP650()
Local aArea   := GetArea()
Local cArm    := GetMV("ES_ARMPROD")
Local nPosArm := 0
local i:=0
If !EMPTY(cArm)

     For i := 1 To Len(aHeader)
          If aHeader[2] == "D4_LOCAL"
               nPosArm := i
               Exit
     
          EndIf
     
     Next

     If nPosArm <> 0
          For i := 1 To LEN(aCols)
               aCols[nPosArm] := cArm
          Next
     
     EndIf

Endif

RestArea(aArea)
Return
