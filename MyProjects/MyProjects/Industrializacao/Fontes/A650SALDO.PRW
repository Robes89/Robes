User Function A650SALDO
Local nSaldoAnt := PARAMIXB
Local nRetSaldo := 0


nRetSaldo := nSaldoAnt - ((nSaldoAnt*10/100))

Return nRetSaldo
