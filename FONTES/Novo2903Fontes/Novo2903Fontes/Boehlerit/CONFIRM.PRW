User Function CONFIRM()

Local	nPos,cConf

nPos	:=	aScan( aHeader , { |x| AllTrim( x[2] ) == "C7_CONFIRM" } )
cConf	:= aCols[n,nPos]

For nX := n To Len(aCols)
	aCols[nX][nPos]	:= cConf
Next nX

Return( cConf )
