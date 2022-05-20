#INCLUDE 'totvs.ch'
#INCLUDE 'topconn.ch'

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TBRETFORWF
@description Rotina responsavel pelo retorno do formulário do WORKFLOW
@author Leonardo Pereira
@since 05/09/2019
@version 1.0
@return Nil
/*/
//----------------------------------------------------------------------------------------------
Static Function TBRETFORWF( oProcess )

   Local n1 := 0
   Local cQry := ''

   DbSelectArea( 'SC8' )
   SC8->( DbSetOrder( 1 ) )
   For n1 := 1 To Len( oProcess:oHtml:RetByName( 'IT.ITEM' ) )
      If SC8->( DbSeek( oProcess:oHtml:RetByName( 'WFFILIAL' ) + oProcess:oHtml:RetByName( 'WFCOTACAO' ) + oProcess:oHtml:RetByName( 'WFFORNECEDOR' ) + ;
                        oProcess:oHtml:RetByName( 'WFLOJA' ) + oProcess:oHtml:RetByName( 'IT.ITEM' )[ n1 ] ) )
         
         cQry := ' UPDATE ' + RetSQLName( 'SC8' ) + CRLF
         cQry += " SET C8_COND = '" + SubStr( oProcess:oHtml:RetByName( 'WFCONDPAG' ), 1, 3 ) + "', " + CRLF
         cQry += " C8_OBS = CAST('" + oProcess:oHtml:RetByName( 'WFOBS' ) + "' AS VARBINARY), "
         If ( Val( StrTran( StrTran( oProcess:oHtml:RetByName( 'WFTOTDESC' ), '.' , '' ), ',', '.' ) ) > 0 )
            cQry += " C8_VLDESC = " + AllTrim( StrTran( StrTran( oProcess:oHtml:RetByName( 'WFTOTDESC' ), '.' , '' ), ',', '.' ) ) + ", "
         EndIf

         cQry += " C8_TPFRETE = '" + SubStr( oProcess:oHtml:RetByName( 'WFTIPOFRETE' ), 1, 1 ) + "', "

         If ( Val( StrTran( StrTran( oProcess:oHtml:RetByName( 'WFTOTFRETE' ), '.' , '' ), ',', '.' ) ) > 0 )
            cQry += " C8_TOTFRE = " + AllTrim( StrTran( StrTran( oProcess:oHtml:RetByName( 'WFTOTFRETE' ), '.' , '' ), ',', '.' ) ) + ", "
         EndIf

         cQry += " C8_ITEM = '" + oProcess:oHtml:RetByName( 'IT.ITEM' )[ n1 ] + "', "
         cQry += " C8_NUMPRO = '01', "
         cQry += " C8_PRECO = " + AllTrim( StrTran( StrTran( oProcess:oHtml:RetByName( 'IT.VLRUNIT' )[ n1 ], '.' , '' ), ',', '.' ) ) + ", "
         cQry += " C8_TOTAL = " + AllTrim( StrTran( StrTran( oProcess:oHtml:RetByName( 'IT.VLRTOT' )[ n1 ], '.' , '' ), ',', '.' ) ) + ", "
         cQry += " C8_ALIIPI = " + AllTrim( StrTran( StrTran( oProcess:oHtml:RetByName( 'IT.IPI' )[ n1 ], '.' , '' ), ',', '.' ) ) + ", "
         cQry += " C8_VALIPI = " + AllTrim( Str( ( Val( StrTran( StrTran( oProcess:oHtml:RetByName( 'IT.VLRTOT' )[ n1 ], '.' , '' ), ',', '.' ) ) / Val( StrTran( StrTran( oProcess:oHtml:RetByName( 'WFSUBTOT' ), '.' , '' ), ',', '.' ) ) ) * Val( StrTran( StrTran( oProcess:oHtml:RetByName( 'WFTOTIPI' ), '.' , '' ), ',', '.' ) ) ) ) + ", "
         cQry += " C8_PRAZO = " + AllTrim( StrTran( StrTran( oProcess:oHtml:RetByName( 'IT.PRAZO' )[ n1 ], '.' , '' ), ',', '.' ) ) + ", "
         cQry += " C8_DATPRF = '" + DtoS( CtoD( oProcess:oHtml:RetByName( 'IT.ENTREGA' )[ n1 ] ) ) + "', "
         cQry += " C8_VALFRE = " + AllTrim( Str( ( Val( StrTran( StrTran( oProcess:oHtml:RetByName( 'IT.VLRTOT' )[ n1 ], '.' , '' ), ',', '.' ) ) / Val( StrTran( StrTran( oProcess:oHtml:RetByName( 'WFSUBTOT' ), '.' , '' ), ',', '.' ) ) ) * Val( StrTran( StrTran( oProcess:oHtml:RetByName( 'WFTOTFRETE' ), '.' , '' ), ',', '.' ) ) ) ) + " " + CRLF
         cQry += " WHERE C8_FILIAL = '" + oProcess:oHtml:RetByName( 'WFFILIAL' ) + "' " + CRLF
         cQry += " AND C8_NUM = '" + oProcess:oHtml:RetByName( 'WFCOTACAO' ) + "' " + CRLF
         cQry += " AND C8_FORNECE = '" + oProcess:oHtml:RetByName( 'WFFORNECEDOR' ) + "' " + CRLF
         cQry += " AND C8_LOJA = '" + oProcess:oHtml:RetByName( 'WFLOJA' ) + "' " + CRLF
         cQry += " AND C8_ITEM = '" + oProcess:oHtml:RetByName( 'IT.ITEM' )[ n1 ] + "' " + CRLF
         cQry += " AND D_E_L_E_T_ = '' " + CRLF
         TcSqlExec( cQry )
      EndIf
   Next

Return
