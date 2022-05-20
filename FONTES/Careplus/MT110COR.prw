User Function MT110COR()
Local aNewCores := aClone(PARAMIXB[1])  
// aCores
aAdd(aNewCores,{ 'C1_XSTAT == "0"' , 'CLR_HCYAN'}) 
aAdd(aNewCores,{ 'C1_XSTAT == "1"' , 'CLR_YELLOW '}) 
aAdd(aNewCores,{ 'C1_XSTAT == "2"' , 'CLR_BROWN'}) 
 //-- Bloqueado

   //-- Atendido
   Return (aNewCores)