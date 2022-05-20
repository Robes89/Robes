User function ttbcd501
    For nY := 1 to len(aCols)
        xCpos:=aCols[nY][_PosTES]
        If aCols[nY][_PosTES]<>' '
          cTES := aCols[nY][_PosTES]
          If (cTES=612)
               cMEN := "020"
          EndIf
        Endif  
     Next nY 
Return 
