#INCLUDE 'totvs.ch'

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TBRETFORWF
@description Rotina responsavel pelo retorno do formulário do WORKFLOW
@author Leonardo Pereira
@since 05/09/2019
@version 1.0
@return Nil
/*/
//----------------------------------------------------------------------------------------------
User Function TBRETGCTFORWF( oProcess )

   /*/ Declaração de variaveis /*/
   Local aAreaSCR := {}
   Local aAreaCN9

   Local lRet := .F.

   Local aAllUsers := { }
   Local aUsersList := { }

   Local cNivel := oProcess:oHtml:RetByName( 'WFNIVEL' )
   Local cTipoDoc := oProcess:oHtml:RetByName( 'WFTIPODOC' )

   Local n1 := 0
   Local nTotGCT := Val( StrTran( oProcess:oHtml:RetByName( 'WFTOTGCT' ), ',' , '' ) )
   Local nOpc := Val( oProcess:oHtml:RetByName( 'WFNOPC' ) )

   Local cStrSCR := Space( TamSX3( 'CR_NUM' )[ 1 ] - Len( IIf( ( nOpc == 3 ), oProcess:oHtml:RetByName( 'WFNUMMED' ), oProcess:oHtml:RetByName( 'WFCONTRATO' ) + AllTrim( oProcess:oHtml:RetByName( 'WFREVISAO' ) ) ) ) )

   Private cWFObs1 := oProcess:oHtml:RetByName( 'WFOBS1' )
   Private cProcHTML := ''
   Private cMailWF := ''
   Private cWFId := ''

   SCR->( DbSetOrder( 1 ) )
   If SCR->( DbSeek( oProcess:oHtml:RetByName( 'WFFILIAL' ) + cTipoDoc + IIf( ( nOpc == 3 ), oProcess:oHtml:RetByName( 'WFNUMMED' ), oProcess:oHtml:RetByName( 'WFCONTRATO' ) + AllTrim( oProcess:oHtml:RetByName( 'WFREVISAO' ) ) ) + cStrSCR + cNivel ) )
      aAreaSCR := SCR->( GetArea() )
      While !SCR->( Eof() ) .And. ( xFilial('SCR') + cTipoDoc + IIf( ( nOpc == 3 ), oProcess:oHtml:RetByName( 'WFNUMMED' ), oProcess:oHtml:RetByName( 'WFCONTRATO' ) + AllTrim( oProcess:oHtml:RetByName( 'WFREVISAO' ) ) ) == SCR->CR_FILIAL + SCR->CR_TIPO + AllTrim( SCR->CR_NUM ) ) .And. ( cNivel == SCR->CR_NIVEL )
         If ( oProcess:oHtml:RetByName( 'WFOPC' ) == 'S')
            TBMaAlcDoc( { IIf( ( nOpc == 3 ), oProcess:oHtml:RetByName( 'WFNUMMED' ), oProcess:oHtml:RetByName( 'WFCONTRATO' ) + AllTrim( oProcess:oHtml:RetByName( 'WFREVISAO' ) ) ), cTipoDoc, nTotGCT, SCR->CR_APROV, SCR->CR_USER, SCR->CR_GRUPO,, SCR->CR_MOEDA, SCR->CR_TXMOEDA, SCR->CR_EMISSAO }, dDataBase, 4 )
         ElseIf ( oProcess:oHtml:RetByName( 'WFOPC' ) == 'N')
            TBMaAlcDoc( { IIf( ( nOpc == 3 ), oProcess:oHtml:RetByName( 'WFNUMMED' ), oProcess:oHtml:RetByName( 'WFCONTRATO' ) + AllTrim( oProcess:oHtml:RetByName( 'WFREVISAO' ) ) ), cTipoDoc, nTotGCT, SCR->CR_APROV, SCR->CR_USER, SCR->CR_GRUPO,, SCR->CR_MOEDA, SCR->CR_TXMOEDA, SCR->CR_EMISSAO }, dDataBase, 7 )
         EndIf

         If !Empty( SCR->CR_DATALIB )
            RecLock( 'SCR', .F. )
            SCR->CR_OBS := oProcess:oHtml:RetByName( 'WFOBS2' )
            SCR->( MsUnLock() )
         EndIf
         SCR->( DbSkip() )
      End
      RestArea( aAreaSCR )
   EndIf

   /*/ Verifica o proximo nivel para aprovação /*/
   If !Empty( SCR->CR_DATALIB )
      cNivel := ''
   	/*/ Coleta informacoes do aprovador /*/
      SCR->( DbSetOrder( 1 ) )
      If SCR->( DbSeek( oProcess:oHtml:RetByName( 'WFFILIAL' ) + cTipoDoc + IIf( ( nOpc == 3 ), oProcess:oHtml:RetByName( 'WFNUMMED' ), oProcess:oHtml:RetByName( 'WFCONTRATO' ) + AllTrim( oProcess:oHtml:RetByName( 'WFREVISAO' ) ) ) + cStrSCR + cNivel ) )
         While !SCR->( Eof() ) .And. ( xFilial('SCR') + cTipoDoc + IIf( ( nOpc == 3 ), oProcess:oHtml:RetByName( 'WFNUMMED' ), oProcess:oHtml:RetByName( 'WFCONTRATO' ) + AllTrim( oProcess:oHtml:RetByName( 'WFREVISAO' ) ) ) == SCR->CR_FILIAL + SCR->CR_TIPO + AllTrim( SCR->CR_NUM ) )
            If ( SCR->CR_STATUS == '01' ) .Or. ( SCR->CR_STATUS == '02' )
               cNivel := SCR->CR_NIVEL
               Exit
            EndIf
            SCR->( DbSkip() )
         End
      EndIf
   EndIf

   If !Empty( cNivel )
      If ( nOpc == 1 ) .Or. ( nOpc == 2 )
         CN9->( DbSetOrder( 1 ) )
         If CN9->( DbSeek( oProcess:oHtml:RetByName( 'WFFILIAL' ) + oProcess:oHtml:RetByName( 'WFCONTRATO' ) + oProcess:oHtml:RetByName( 'WFREVISAO' ) ) )
       	   /*/ Coleta informacoes do aprovador /*/
            SCR->( DbSetOrder( 1 ) )
            If SCR->( DbSeek( oProcess:oHtml:RetByName( 'WFFILIAL' ) + cTipoDoc + oProcess:oHtml:RetByName( 'WFCONTRATO' ) + AllTrim( oProcess:oHtml:RetByName( 'WFREVISAO' ) ) + cStrSCR + cNivel ) )
               While !SCR->( Eof() ) .And. ( xFilial('SCR') + cTipoDoc + oProcess:oHtml:RetByName( 'WFCONTRATO' ) + AllTrim( oProcess:oHtml:RetByName( 'WFREVISAO' ) ) == SCR->CR_FILIAL + SCR->CR_TIPO + AllTrim( SCR->CR_NUM ) ) .And. ( cNivel == SCR->CR_NIVEL )
                  If ( SCR->CR_STATUS == '01' ) .Or. ( SCR->CR_STATUS == '02' )
                     SAK->( DbSetOrder( 1 ) )
                     If SAK->( DbSeek( xFilial( 'SAK' ) + SCR->CR_APROV ) )
                        aAdd( aUsersList, AllTrim( SAK->AK_USER ) )
                     EndIf

                     aAllUsers := FwsFAllUsers( IIf( Empty( aUsersList ), { '000000' }, aUsersList ) )
                     For n1 := 1 To Len( aAllUsers )
                        cMailWF += AllTrim( aAllUsers[ n1, 5] ) + ';'
                     Next
                     cMailWF := SubStr( cMailWF, 1, ( Len( cMailWF ) - 1 ) )

	      		      /*/ Gera o formulário HTML /*/
                      lRet := U_WFGCT001(nOpc,cTipoDoc)

         		      /*/ Realiza o envio da notificação de workflow com os links	/*/
                     If lRet
                        U_WFGCT002(nOpc)
                     EndIf

                     /*/ Grava o numero do processo do workflow no registro de aprovação /*/
                     RecLock( 'SCR', .F. )
                     SCR->CR_WF := cWFId
                     SCR->CR_OBS := oProcess:oHtml:RetByName( 'WFOBS2' )
                     SCR->( MsUnLock() )
                  EndIf
                  SCR->( DbSkip() )
               End
            EndIf
         EndIf
      ElseIf ( nOpc == 3 )
         CN9->( DbSetOrder( 1 ) )
         If CN9->( DbSeek( oProcess:oHtml:RetByName( 'WFFILIAL' ) + oProcess:oHtml:RetByName( 'WFCONTRATO' ) + oProcess:oHtml:RetByName( 'WFREVISAO' ) ) )
            CND->( DbSetOrder( 7 ) )
            If CND->( DbSeek( oProcess:oHtml:RetByName( 'WFFILIAL' ) + oProcess:oHtml:RetByName( 'WFCONTRATO' ) + oProcess:oHtml:RetByName( 'WFREVISAO' ) + oProcess:oHtml:RetByName( 'WFNUMMED' ) ) )
               /*/ Coleta informacoes do aprovador /*/
               SCR->( DbSetOrder( 1 ) )
               If SCR->( DbSeek( oProcess:oHtml:RetByName( 'WFFILIAL' ) + cTipoDoc + oProcess:oHtml:RetByName( 'WFNUMMED' ) + cStrSCR + cNivel ) )
                  While !SCR->( Eof() ) .And. ( xFilial('SCR') + cTipoDoc + oProcess:oHtml:RetByName( 'WFNUMMED' ) == SCR->CR_FILIAL + SCR->CR_TIPO + AllTrim( SCR->CR_NUM ) ) .And. ( cNivel == SCR->CR_NIVEL )
                     If ( SCR->CR_STATUS == '01' ) .Or. ( SCR->CR_STATUS == '02' )
                        SAK->( DbSetOrder( 1 ) )
                        If SAK->( DbSeek( xFilial( 'SAK' ) + SCR->CR_APROV ) )
                           aAdd( aUsersList, AllTrim( SAK->AK_USER ) )
                        EndIf

                        aAllUsers := FwsFAllUsers( IIf( Empty( aUsersList ), { '000000' }, aUsersList ) )
                        For n1 := 1 To Len( aAllUsers )
                           cMailWF += AllTrim( aAllUsers[ n1, 5] ) + ';'
                        Next
                        cMailWF := SubStr( cMailWF, 1, ( Len( cMailWF ) - 1 ) )

	      		         /*/ Gera o formulário HTML /*/
                        lRet := U_WFGCT001(nOpc,cTipoDoc)

                        /*/ Realiza o envio da notificação de workflow com os links	/*/
                        If lRet
                           U_WFGCT002(nOpc)
                        EndIf

                        /*/ Grava o numero do processo do workflow no registro de aprovação /*/
                        RecLock( 'SCR', .F. )
                        SCR->CR_WF := cWFId
                        SCR->CR_OBS := oProcess:oHtml:RetByName( 'WFOBS2' )
                        SCR->( MsUnLock() )
                     EndIf
                     SCR->( DbSkip() )
                  End
               EndIf
            EndIf
         EndIf
      EndIf
   Else
      If ( oProcess:oHtml:RetByName( 'WFOPC' ) == 'S')
         If ( nOpc == 1 )
            CN9->( DbSetOrder( 1 ) )
            If CN9->( DbSeek( oProcess:oHtml:RetByName( 'WFFILIAL' ) + oProcess:oHtml:RetByName( 'WFCONTRATO' ) + oProcess:oHtml:RetByName( 'WFREVISAO' ) ) )
               While !CN9->( Eof() ) .And. ( oProcess:oHtml:RetByName( 'WFFILIAL' ) + oProcess:oHtml:RetByName( 'WFCONTRATO' ) + oProcess:oHtml:RetByName( 'WFREVISAO' )== CN9->CN9_FILIAL + CN9->CN9_NUMERO + CN9->CN9_REVISA )
                  RecLock( 'CN9', .F. )
                  CN9->CN9_SITUAC := '05'
                  CN9->( MsUnLock() )
                  CN9->( DbSkip() )
               End
            EndIf
         ElseIf ( nOpc == 2 )
            CN9->( DbSetOrder( 1 ) )
            If CN9->( DbSeek( oProcess:oHtml:RetByName( 'WFFILIAL' ) + oProcess:oHtml:RetByName( 'WFCONTRATO' ) + oProcess:oHtml:RetByName( 'WFREVISAO' ) ) )
               While !CN9->( Eof() ) .And. ( oProcess:oHtml:RetByName( 'WFFILIAL' ) + oProcess:oHtml:RetByName( 'WFCONTRATO' ) + oProcess:oHtml:RetByName( 'WFREVISAO' )== CN9->CN9_FILIAL + CN9->CN9_NUMERO + CN9->CN9_REVISA )
                  RecLock( 'CN9', .F. )
                  CN9->CN9_SITUAC := '05'
                  CN9->( MsUnLock() )
                  CN9->( DbSkip() )
               End
            EndIf

            aAreaCN9 := CN9->( GetArea() )
            CN9->( DbSetOrder( 1 ) )
            If CN9->( DbSeek( oProcess:oHtml:RetByName( 'WFFILIAL' ) + oProcess:oHtml:RetByName( 'WFCONTRATO' ) ) )
               While !CN9->( Eof() ) .And. ( oProcess:oHtml:RetByName( 'WFFILIAL' ) + oProcess:oHtml:RetByName( 'WFCONTRATO' ) == CN9->CN9_FILIAL + CN9->CN9_NUMERO )
                  If ( oProcess:oHtml:RetByName( 'WFREVISAO' ) == CN9->CN9_REVATU )
                     RecLock( 'CN9', .F. )
                     CN9->CN9_SITUAC := '10'
                     CN9->( MsUnLock() )
                  EndIf
                  CN9->( DbSkip() )
               End
            EndIf
            RestArea( aAreaCN9 )
         ElseIf ( nOpc == 3 )
            CND->( DbSetOrder( 7 ) )
            If CND->( DbSeek( oProcess:oHtml:RetByName( 'WFFILIAL' ) + oProcess:oHtml:RetByName( 'WFCONTRATO' ) + oProcess:oHtml:RetByName( 'WFREVISAO' ) + oProcess:oHtml:RetByName( 'WFNUMMED' ) ) )
               While !CND->( Eof() ) .And. ( oProcess:oHtml:RetByName( 'WFFILIAL' ) + oProcess:oHtml:RetByName( 'WFCONTRATO' ) + oProcess:oHtml:RetByName( 'WFREVISAO' ) + oProcess:oHtml:RetByName( 'WFNUMMED' ) == CND->CND_FILIAL + CND->CND_CONTRA + CND->CND_REVISA + CND->CND_NUMMED )
                  RecLock( 'CND', .F. )
                  CND->CND_ALCAPR := 'L'
                  CND->CND_SITUAC := 'A'
                  CND->( MsUnLock() )
                  CND->( DbSkip() )
               End
            EndIf
         EndIf
      ElseIf ( oProcess:oHtml:RetByName( 'WFOPC' ) == 'N' )
         If ( nOpc == 1 ) /*/ Inclusão /*/
         CN9->( DbSetOrder( 1 ) )
         If CN9->( DbSeek( oProcess:oHtml:RetByName( 'WFFILIAL' ) + oProcess:oHtml:RetByName( 'WFCONTRATO' ) + oProcess:oHtml:RetByName( 'WFREVISAO' ) ) )
            While !CN9->( Eof() ) .And. ( oProcess:oHtml:RetByName( 'WFFILIAL' ) + oProcess:oHtml:RetByName( 'WFCONTRATO' ) + oProcess:oHtml:RetByName( 'WFREVISAO' )== CN9->CN9_FILIAL + CN9->CN9_NUMERO + CN9->CN9_REVISA )
               RecLock( 'CN9', .F. )
               CN9->CN9_SITUAC := '11'
               CN9->( MsUnLock() )
               CN9->( DbSkip() )
            End
         EndIf
         ElseIf ( nOpc == 2 ) /*/ Revisao /*/
         CN9->( DbSetOrder( 1 ) )
         If CN9->( DbSeek( oProcess:oHtml:RetByName( 'WFFILIAL' ) + oProcess:oHtml:RetByName( 'WFCONTRATO' ) + oProcess:oHtml:RetByName( 'WFREVISAO' ) ) )
            While !CN9->( Eof() ) .And. ( oProcess:oHtml:RetByName( 'WFFILIAL' ) + oProcess:oHtml:RetByName( 'WFCONTRATO' ) + oProcess:oHtml:RetByName( 'WFREVISAO' )== CN9->CN9_FILIAL + CN9->CN9_NUMERO + CN9->CN9_REVISA )
               RecLock( 'CN9', .F. )
               CN9->CN9_SITUAC := '11'
               CN9->( MsUnLock() )
               CN9->( DbSkip() )
            End
         EndIf
         ElseIf ( nOpc == 3 ) /*/ Medicao /*/
            CND->( DbSetOrder( 7 ) ) 
            If CND->( DbSeek( oProcess:oHtml:RetByName( 'WFFILIAL' ) + oProcess:oHtml:RetByName( 'WFCONTRATO' ) + oProcess:oHtml:RetByName( 'WFREVISAO' ) + oProcess:oHtml:RetByName( 'WFNUMMED' ) )   )
               While !CND->( Eof() ) .And. ( oProcess:oHtml:RetByName( 'WFFILIAL' ) + oProcess:oHtml:RetByName( 'WFCONTRATO' ) + oProcess:oHtml:RetByName( 'WFREVISAO' ) + oProcess:oHtml:RetByName( 'WFNUMMED' )  == CND->CND_FILIAL + CND->CND_CONTRA + CND->CND_REVISA + CND->CND_NUMMED )
                  RecLock( 'CN9', .F. )
                  CND->CND_SITUAC := 'E'
                  CND->( MsUnLock() )
                  CND->( DbSkip() )
               End
            EndIf
      EndIf
   EndIf
EndIf

Return


Static Function TBMaAlcDoc(aDocto,dDataRef,nOper,cDocSF1,lResiduo,cItGrp,aItens,lEstCred,aItensDBM,cChaveRej,lAprovSup)

   Local cDocto	:= aDocto[1]
   Local cTipoDoc	:= aDocto[2]
   Local nValDcto	:= aDocto[3]
   Local cAprov	:= If(aDocto[4]==Nil,"",aDocto[4])
   Local cUsuario	:= If(aDocto[5]==Nil,"",aDocto[5])
   Local nMoeDcto	:= If(Len(aDocto)>7,If(aDocto[8]==Nil, 1,aDocto[8]),1)
   Local nTxMoeda	:= If(Len(aDocto)>8,If(aDocto[9]==Nil, 0,aDocto[9]),0)
   Local cObs      := If(Len(aDocto)>10,If(aDocto[11]==Nil, "",aDocto[11]),"")
   Local aArea		:= GetArea()
   Local aAreaSCS	:= SCS->(GetArea())
   Local aAreaSCR	:= SCR->(GetArea())
   Local aRetPe	:= {}

   Local nSaldo	:= 0
   Local nCount    := 1
   Local cGrupo	:= If(aDocto[6]==Nil,"",aDocto[6])

   Local cAuxNivel:= ""
   Local cNextNiv := ""
   Local cNivIgual:= ""
   Local cStatusAnt:= ""
   Local cAprovOri := ""
   Local cUserOri  := ""
   Local cObsBloq  := 'STR0061'
   Local lAchou	:= .F.
   Local nRec		:= 0
   Local lRetorno	:= .T.
   Local aSaldo	:= {}
   Local aMTALCGRU := {}
   Local lDeletou  := .F.
   Local lBloqueio := .F.
   Local dDataLib := IIF(dDataRef==Nil,dDataBase,dDataRef)
   Local lIntegDef  := FWHasEAI("MATA120",.T.,,.T.)
   Local lAltpdoc	:= SuperGetMv("MV_ALTPDOC",.F.,.F.)
   Local lCnAglFlg	:= SuperGetMV("MV_CNAGFLG",.F.,.F.)


   Local lFluig		:= !Empty(AllTrim(GetNewPar("MV_ECMURL",""))) .And. FWWFFluig()
   Local lBlqNivel := .F.
   Local cGrupoSAL	:= ""
   Local cAprovDBM	:= ""

   Local lUserNiv	:= .F. //Verifica se existe usuário no mesmo nível - Tipo de Lib por Usuário
   Local lCalMta235 := IsInCallStack("MATA235")


   Local nRecAprov	:= 0

   Local lRetCr 		:= .T.
   Local cFilSCR		:= IIf(cTipoDoc $ 'IC|CT|IR|RV',CnFilCtr(cDocto),xFilial("SCR"))
   Local lNewFlg		:= .F.
   Local nPosDoc		:= 0
   Local lIpAprEC		:= SuperGetMv("MV_IPAPREC",.F.,.F.) // Liberação/Rejeição por grupo de aprovação

   PRIVATE cA120Num := ""

   DEFAULT dDataRef := dDataBase
   DEFAULT cDocSF1 := cDocto
   DEFAULT lResiduo := .F.
   DEFAULT cItGrp	:= ""
   DEFAULT aItens	:= {}
   DEFAULT lEstCred := .T.
   DEFAULT cChaveRej:= ""
   DEFAULT lAprovSup:= .F.
   cDocto := cDocto+Space(Len(SCR->CR_NUM)-Len(cDocto))
   cDocSF1:= cDocSF1+Space(Len(SCR->CR_NUM)-Len(cDocSF1))

   If ExistBlock("MT097GRV")
      lRetorno := (Execblock("MT097GRV",.F.,.F.,{aDocto,dDataRef,nOper,cDocSF1,lResiduo}))
      If Valtype( lRetorno ) <> "L"
         lRetorno := .T.
      EndIf
   Endif

   If type("aDocRelib") == "U"
      aDocRelib := {}
   EndIf

   If lRetorno
      If Empty(cUsuario) .And. (nOper != 1 .And. nOper != 6) //nao e inclusao ou estorno de liberacao
         dbSelectArea("SAK")
         SAK->(dbSetOrder(1))
         SAK->(MsSeek(xFilial("SAK") + cAprov))
         cUsuario :=	AK_USER
         SAL->(DbSetOrder(1))
         If SAL->(DbSeek(xFilial("SAL")+cGrupo+cUsuario))
            DHL->(DbSetOrder(1))
            If DHL->(DbSeek(xFilial("DHL") + SAL->AL_PERFIL))
               nMoeDcto := DHL->DHL_MOEDA
            Else
               nMoeDcto :=	AK_MOEDA
            Endif
         Else
            nMoeDcto :=	AK_MOEDA
         EndIf
         nTxMoeda	:=	0
      EndIf

      If nOper == 4 .AND. !Empty(cAprov)//Aprovacao do documento
         dbSelectArea("SCS")
         SCS->(dbSetOrder(2))
         aSaldo := MaSalAlc(cAprov,dDataRef,.T.)
         nSaldo 	:= aSaldo[1]
         dDataRef	:= aSaldo[3]
         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Atualiza o saldo do aprovador.                 ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         dbSelectArea("SAK")
         SAK->(dbSetOrder(1))
         SAK->(DbSeek(xFilial("SAK") + cAprov))

         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Posiciona a Tabela SAL pelo Aprovador de Origem caso o Documento tenha sido ³
         //| transferido por Ausência Temporária ou Transferência superior e o aprovador |
         //| de destino não fizer parte do Grupo de Aprovação.                           |
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         dbSelectArea("SAL")
         SAL->(dbSetOrder(3))
         If Empty(SCR->CR_APRORI)
            SAL->(dbSeek(xFilial("SAL") + cGrupo + cAprov))
         Else
            SAL->(MsSeek(xFilial("SAL") + cGrupo + SCR->CR_APRORI))
         EndIf
         cAuxNivel := SAL->AL_NIVEL
         If Empty(cAuxNivel)
            cAuxNivel := SCR->CR_NIVEL
         EndIf
         If !Empty(SCR->CR_APRORI)
            SAL->(MsSeek(xFilial("SAL") + cGrupo + SCR->CR_APRORI))
         EndIf

         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Posiciona a Tabela SAL pelo Aprovador de Origem caso o Documento que esta   ³
         //| sendo aprovado, pela opcao: SUPERIOR e o aprovador Superior nao fizer parte |
         //| do mesmo Grupo de Aprovação.  									                            |
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         If Len(aDocto)>11 .And. Empty(SCR->CR_APRORI)
            If !Empty(aDocto[12])
               SAL->(MsSeek(xFilial("SAL")+cGrupo+aDocto[12]))
            EndIf
         EndIf

         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Ponto de entrada para alterar o Aprovador 	 												³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         If ExistBlock("MTALCGRU")
            aMTALCGRU := If(ValType(aRetPe:=ExecBlock("MTALCGRU",.F.,.F.,{cAprov,cGrupo}))=="A",aRetPe,aMTALCGRU)
            If Len(aMTALCGRU) >= 1 .And. ValType(aMTALCGRU[1]) == "C"
               cAprov := aMTALCGRU[1]
            EndIf
            If Len(aMTALCGRU) >= 2 .And. ValType(aMTALCGRU[2]) == "C"
               cGrupoSAL := aMTALCGRU[2]
            EndIf
         EndIf

         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Libera o pedido pelo aprovador.                     ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


         dbSelectArea("SCR")
         SCR->(dbSetOrder(3))
         if lCalMta235 .or. (cTipoDoc == "IP" .And. !Empty(SC7->C7_ENCER)) .Or. (cTipoDoc == "SC" .And. SC1->C1_QUJE >= SC1->C1_QUANT)
            lRetCr := SCR->(MsSeek(cFilSCR + cTipoDoc + cDocto + cAprov))
         Endif
         If Empty(cItGrp)
            cItGrp:= SCR->CR_ITGRP
         EndIf
         If lRetCr .and. Reclock("SCR",.F.)
            While !Eof() .and. cTipoDoc == SCR->CR_TIPO .and. cDocto == SCR->CR_NUM .and. (cAprov == SCR->CR_APROV .Or. lAprovSup)
               nPosDoc := ascan(aDocRelib,{|x|,x[1] == SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM+SCR->CR_APROV+SCR->CR_GRUPO+SCR->CR_ITGRP})
               If cItGrp == SCR->CR_ITGRP .and. (!lCalMta235 .or. nPosDoc > 0)
                  If nPosDoc > 0
                     dDataLib := aDocRelib[nPosDoc][2]
                     dDataRef := dDataLib
                  EndIf
                  SCR->CR_STATUS	:= "03"
                  SCR->CR_OBS		:= If(Len(aDocto)>10,aDocto[11],"")
                  SCR->CR_DATALIB	:= dDataLib
                  SCR->CR_USERLIB	:= SAK->AK_USER
                  SCR->CR_LIBAPRO	:= SAK->AK_COD
                  SCR->CR_VALLIB	:= nValDcto
                  SCR->CR_TIPOLIM	:= SAK->AK_TIPO
                  SCR->(MsUnlock())
                  nRecAprov := SCR->(RecNo())
                  nRec := SCR->(RecNo())
                  Exit
               EndIf
               DBSKIP()
            EndDo
         EndIf

         If Empty(cGrupo)
            cGrupo := SCR->CR_GRUPO
         EndIf

         cUser		:= SCR->CR_USER
         SCR->(dbSetOrder(1))
         SCR->(MsSeek(cFilSCR + cTipoDoc + cDocto + cAuxNivel))
         nRec := SCR->(RecNo())

         While SCR->(!Eof()) .And. SCR->(CR_FILIAL+CR_TIPO+CR_NUM) == cFilSCR + cTipoDoc + cDocto

            If Empty(SAL->AL_APROV)  // Não conseguiu posicionar SAL pois os campos não existem, efetua posicionamento
               SAL->(dbSeek(xFilial("SAL") + cGrupoSAL + SCR->CR_APROV))
            EndIf

            If cAuxNivel == SCR->CR_NIVEL .And. SCR->CR_STATUS != "03" .And. SAL->AL_TPLIBER $ "U " .And. !Alltrim(SCR->CR_OBS) $ cObsBloq + SAK->AK_COD
               If cGrupo # SCR->CR_GRUPO
                  SCR->(dbSkip())
                  Loop
               ElseIf nCount > 1 // Indica que ainda existem usuarios neste nivel do mesmo grupo, com pendencia de aprovacao , neste caso nao deve liberar os niveis seguintes
                  lBlqNivel := .T.
                  SCR->(dbSkip())
                  Loop
               EndIf
               lUserNiv := .T.
            EndIf

            If cAuxNivel != SCR->CR_NIVEL .And. lUserNiv .And. SAL->AL_TPLIBER $ "U " .And. cGrupo == SCR->CR_GRUPO
               SCR->(dbSkip())
               Loop
            EndIf


            //Verifica se nivel anterior ja passou por algum bloqueio
            If cAuxNivel <> SCR->CR_NIVEL  .And. lBloqueio
               Exit
            EndIf

            If cGrupo # SCR->CR_GRUPO
               If cAuxNivel >= SCR->CR_NIVEL
                  SCR->(dbSkip())
                  Loop
               EndIf
            EndIf

            If cAuxNivel == SCR->CR_NIVEL .And. SCR->CR_STATUS != "03" .And. SAL->AL_TPLIBER $ "NP" .And. SCR->CR_ITGRP == cItGrp
               cAprovDBM := SCR->CR_APROV

               If Reclock("SCR",.F.)
                  SCR->CR_STATUS	:= "05"
                  SCR->CR_DATALIB	:= dDataLib
                  SCR->CR_USERLIB	:= SAK->AK_USER
                  SCR->CR_APROV	:= cAprovDBM
                  SCR->CR_OBS		:= ""
                  SCR->(MsUnlock())
               Endif

               If !Empty(cItGrp)
                  MaAlcItEC(cDocto,cTipoDoc,cGrupo,cItGrp,SCR->CR_USER,,,nOper,cAprovDBM)
               EndIf

               // Cancela processo no Fluig caso a o nível já tenha sido aprovado
               If SCR->CR_STATUS == "05" .And. !Empty(SCR->CR_FLUIG)
                  CancelProcess(Val(SCR->CR_FLUIG),FWWFUserID(Val(SCR->CR_FLUIG))," cancelado por contingência!",.F.)
               Endif

            EndIf
            If SCR->CR_NIVEL > cAuxNivel .And. SCR->CR_STATUS != "03" .And. !lAchou .And. cGrupo == SCR->CR_GRUPO
               lAchou := .T.
               cNextNiv := SCR->CR_NIVEL
            EndIf

            If lAchou .And. SCR->CR_NIVEL == cNextNiv .And. SCR->CR_STATUS != "03"
               If Reclock("SCR",.F.)
                  If SAL->AL_TPLIBER == "P"
                     SCR->CR_STATUS := "05"
                  ElseIf (Empty(cNivIgual) .Or. cNivIgual == SCR->CR_NIVEL) .And. cStatusAnt <> "01" .And. !lBlqNivel
                     SCR->CR_STATUS := "02"
                     cNivIgual := SCR->CR_NIVEL
                  EndIf
                  If SCR->CR_STATUS == "05"
                     SCR->CR_DATALIB	:= dDataLib
                     If !Empty(cItGrp)
                        MaAlcItEC(cDocto,cTipoDoc,cGrupo,cItGrp,SCR->CR_USER,,,nOper,SCR->CR_APROV)
                     EndIf
                  EndIf
                  SCR->(MsUnlock())
                  lAchou    := .F.
               Endif
            Endif
            //Verifica se nivel ja passou por algum bloqueio
            If cAuxNivel $ "02" .And. SCR->CR_STATUS $ "05" .And. Alltrim(SCR->CR_OBS) $ cObsBloq + SAK->AK_COD
               lBloqueio := .T.

               If Reclock("SCR",.F.)
                  SCR->CR_STATUS	:= "02"
                  SCR->CR_DATALIB	:= Ctod("//")
                  SCR->CR_USERLIB	:= ""
                  SCR->CR_LIBAPRO	:= ""
                  SCR->CR_OBS		:= 'STR0063'+SAK->AK_COD
                  SCR->CR_VALLIB	:= 0
                  SCR->CR_TIPOLIM	:= ""
                  SCR->(MsUnlock())
               Endif
            EndIf

            If cGrupo == SCR->CR_GRUPO
               cStatusAnt := SCR->CR_STATUS
            EndIf

            // Gera o processo no Fluig ao aprovar o nivel anterior
            If lFluig .And. SCR->CR_STATUS == "02" .And. (!lCnAglFlg .Or. !cTipoDoc $ "CT|IC|IR" ) .And. Empty(SCR->CR_FLUIG)
               cUserSolic	:= MtUsrSolic(SCR->CR_TIPO,SCR->CR_NUM)
               aNextTask 	:= {2,FWWFColleagueId(cUserSolic),{FWWFColleagueId(A097UsuApr(SCR->CR_APROV))}}
               StartProcess(cTipoDoc,FWWFColleagueId(cUserSolic),{FWWFColleagueId(cUserSolic)},,,,,aNextTask,.T.)
               lNewFlg	:= .T.
            EndIf

            // Gera a nova alçada no Fluig
            If lFluig .And. SCR->CR_STATUS == '02' .And. cTipoDoc $ "CT|IC|IR"
               If cTipoDoc == "IR"
                  Aadd(aFluigIR, cDocto)
               EndIf
               If (!lCnAglFlg .Or. cTipoDoc = "IM")
                  cUserSolic	:= MtUsrSolic(SCR->CR_TIPO,SCR->CR_NUM)
                  MTSoliCAT(cTipoDoc,cDocto,"","CR_NUM",cUserSolic,.T.)
               EndIf
            EndIf

            // Cancela processo no Fluig caso a baixa seja feita através de outra rotina
            If lFluig .And. !Empty(SCR->CR_FLUIG) .And. !IsInCallStack('MTFlgLbDoc') .And. !lNewFlg
               CancelProcess(Val(SCR->CR_FLUIG),FWWFUserID(Val(SCR->CR_FLUIG))," cancelado por contingência!",.F.)
            Endif

            nCount++

            SCR->(dbSkip())
         EndDo

         If !(cTipoDoc $ "IP|SA|")
            //Reposiciona e verifica se ja esta totalmente liberado
            SCR->(MsGoto(nRec))
            While SCR->(!Eof()) .And. cFilSCR+cTipoDoc+cDocto == SCR->(CR_FILIAL+CR_TIPO+CR_NUM)
               If cGrupo == SCR->CR_GRUPO .And. SCR->CR_ITGRP == cItGrp
                  If SCR->CR_STATUS != "03" .And. SCR->CR_STATUS != "05" .And. SCR->CR_STATUS != "04"
                     lRetorno := .F.
                     Exit
                  EndIf
               Endif
               SCR->(dbSkip())
            EndDo
         EndIf

         If cTipoDoc $ "IP|SC" .And. Empty(cAprov) .And. (!Empty(SC7->C7_ENCER) .Or. SC1->C1_QUJE >= SC1->C1_QUANT)
            cAprov := SCR->CR_APROV
         EndIf

         If SAL->AL_LIBAPR == "A"
            dbSelectArea("SCS")
            If SCS->(dbSeek(xFilial("SCS") + cAprov + dToS(dDataRef)))
               Reclock("SCS",.F.)
            Else
               Reclock("SCS",.T.)
            EndIf
            SCS->CS_FILIAL:= xFilial("SCS")
            SCS->CS_SALDO := SCS->CS_SALDO - nValDcto
            SCS->CS_APROV := cAprov
            SCS->CS_MOEDA := nMoeDcto
            SCS->CS_DATA  := dDataRef
            SCS->(MsUnlock())
         EndIf

         //Libera os itens da alcada
         If !Empty(cItGrp)
            MaAlcItEC(cDocto,cTipoDoc,cGrupo,cItGrp,cUser,,,nOper,If(lAprovSup,aDocto[12],cAprov))
         EndIf
      EndIf

      If nOper == 7  //Evento de rejeição do documento
         cAuxNivel := SCR->CR_NIVEL
         cAprovOri := SCR->CR_APROV
         cUserOri  := SCR->CR_USER

         // Rejeita aprovacoes pendentes do mesmo nivel e niveis superiores, grupo e item
         SCR->(dbSetOrder(1))
         SCR->(dbSeek(cFilSCR+cTipoDoc+cDocto))
         While !SCR->(EOF()) .And. SCR->(CR_FILIAL+CR_TIPO+CR_NUM) == cFilSCR+cTipoDoc+cDocto
            // Aprovação por item rejeita apenas o grupo de aprovação envolvido
            If (SCR->CR_TIPO $ "SA|SC" .Or. (SCR->CR_TIPO == "IP" .And. lIpAprEc)) .And. SCR->(CR_GRUPO+CR_ITGRP) # cGrupo+cItGrp
               SCR->(dbSkip())
               Loop
            EndIf

            If SCR->CR_NIVEL >= cAuxNivel	.And. SCR->CR_STATUS <> "03"
               RecLock("SCR",.F.)
               SCR->CR_DATALIB := dDataBase
               SCR->CR_USERLIB := cUserOri
               SCR->CR_LIBAPRO := cAprovOri
               If SCR->CR_APROV == cAprovOri
                  SCR->CR_STATUS := "06"
               Else
                  SCR->CR_STATUS := "07"
               EndIf
               SCR->(MsUnLock())
            EndIf

            If !cTipoDoc $ "CT|IC|RV|IR|MD|IM|PC|ST"
               MaAlcItEC(SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_GRUPO,SCR->CR_ITGRP,SCR->CR_USER,,SCR->CR_USERORI,nOper,SCR->CR_APROV)
            EndIf

            If !Empty(SCR->CR_FLUIG) .And. (SCR->CR_STATUS == "05" .Or. SCR->CR_STATUS == "06")
               CancelProcess(Val(SCR->CR_FLUIG),FWWFUserID(Val(SCR->CR_FLUIG))," cancelado por contingência!",.F.)
            EndIf
            SCR->(dbSkip())
         End

         Do Case
         Case SCR->CR_TIPO == "PC"
            SC7->(dbSetOrder(1))
            SC7->(MsSeek(cChaveRej))
            While !SC7->(EOF()) .And. SC7->(C7_FILIAL+C7_NUM) == cChaveRej
               RecLock("SC7",.F.)
               SC7->C7_CONAPRO := 'R'
               SC7->C7_FLUXO	:= 'N'
               SC7->(MsUnlock())
               SC7->(dbSkip())
            End
         EndCase

         //Rejeitar os documento do Agro
         If cTipoDoc >= "A1" .AND. cTipoDoc <= "A9"
         Else
            MaMailAlcRej(cDocto,cUserOri,cTipoDoc,SCR->CR_OBS )
         EndIf
      EndIf

      // Envia o pedido de compra ao TOTVS Colaboracao
      If cPaisLoc == "BRA" .And. lRetorno .And. cTipoDoc $ "PC#AE" .And. (nOper == 1 .Or. nOper == 4) .And.;
            SC7->C7_TPOP $ " F" .And. FWLSEnable(TOTVS_COLAB_ONDEMAND)
         ExpXML_PC(SC7->C7_NUM)
      EndIf

      If ExistBlock("MTALCDOC")
         Execblock("MTALCDOC",.F.,.F.,{aDocto,dDataRef,nOper,cItGrp})
      EndIf

      // Envia o pedido de compra direto para portal MarketPLace
      If lRetorno .And. cTipoDoc $ "PC" .And. nOper == 4 .And. SC7->C7_TPOP $ " F" .And. ;
            lIntegDef .And. SuperGetMV("MV_MKPLACE",.F.,.F.) .And. !Empty(SC7->C7_ACCNUM)

         cA120Num := SC7->C7_NUM
         If SC7->(MsSeek(xFilial("SC7")+SC7->C7_NUM))
            Inclui:=.T.
            //Dispara thread
            MaEnvPed(cEmpAnt,cFilAnt,cA120Num)
         EndIf
      EndIf
   EndIf

   If ExistBlock("MTALCFIM")
      lCalculo := Execblock("MTALCFIM",.F.,.F.,{aDocto,dDataRef,nOper,cDocSF1,lResiduo})
      If Valtype( lCalculo ) == "L"
         lRetorno := lCalculo
      EndIf
   Endif

   dbSelectArea("SCR")
   RestArea(aAreaSCR)
   dbSelectArea("SCS")
   RestArea(aAreaSCS)
   RestArea(aArea)

Return( lRetorno )
