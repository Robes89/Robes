#include "totvs.ch"

User Function MSD2460 

Reclock("SD2", .F.)
	SD2->D2_ZZPALLE := SC6->C6_ZZPALLE
SD2->( msUnlock() )

Return