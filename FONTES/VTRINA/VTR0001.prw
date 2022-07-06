/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Atualização                                             !
+------------------+---------------------------------------------------------+
!Modulo            ! 98 - Marketplaces                                       !
+------------------+---------------------------------------------------------+
!Nome              ! VTR0001                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! Adicionar produtos à integração                         !
+------------------+---------------------------------------------------------+
!Autor             ! PAULO AFONSO ERZINGER JUNIOR                            !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 22/10/2019                                              !
+------------------+---------------------------------------------------------+
*/

#include "protheus.ch"
#include "fwmvcdef.ch"

User Function VTR0001()

Local oBrowse
Private aRotina := MenuDef()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('ZDD')
oBrowse:SetDescription('Adicionar produtos à integração')
oBrowse:DisableDetails()

oBrowse:AddLegend("ZDD_STATUS=='A'", "GREEN", "Ativo")
oBrowse:AddLegend("ZDD_STATUS=='I'", "RED", "Inativo")

oBrowse:Activate() 
	
Return

/*
+----------------------------------------------------------------------------+
! Função    ! MenuDef      ! Autor ! Paulo A. Erzinger  ! Data !  22/10/2019 !
+-----------+--------------+-------+--------------------+------+-------------+
! Parâmetros! N/A                                                            !
+-----------+----------------------------------------------------------------+
! Descricao ! Monta menu do browse                                           !
+-----------+----------------------------------------------------------------+
*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title 'Visualizar' Action 'VIEWDEF.VTR0001' OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Importar' Action 'U_VTR0001_IMPORTA()' OPERATION 3 ACCESS 0
ADD OPTION aRotina Title 'Incluir' Action 'VIEWDEF.VTR0001' OPERATION 3 ACCESS 0
ADD OPTION aRotina Title 'Alterar' Action 'VIEWDEF.VTR0001' OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Copiar' Action 'VIEWDEF.VTR0001' OPERATION 9 ACCESS 0

Return aRotina

/*
+----------------------------------------------------------------------------+
! Função    ! ModelDef     ! Autor ! Paulo A. Erzinger  ! Data !  22/10/2019 !
+-----------+--------------+-------+--------------------+------+-------------+
! Parâmetros! N/A                                                            !
+-----------+----------------------------------------------------------------+
! Descricao ! Cria o modelo de dados com base no dicionário                  !
+-----------+----------------------------------------------------------------+
*/ 
Static Function ModelDef()

Local oStruZDD := FWFormStruct(1,"ZDD")
Local oModel   := MPFormModel():New("VTR0001M")

oModel:AddFields("ZDDMASTER",,oStruZDD)
oModel:SetDescription("Modelo de Dados - MARKETPLACES - Produtos aptos à integrar")
oModel:GetModel("ZDDMASTER"):SetDescription("MARKETPLACES - Produtos aptos à integrar")
oModel:SetPrimaryKey( { "ZDD_FILIAL", "ZDD_PRODUT" } ) 

Return oModel 
 
 
/*
+----------------------------------------------------------------------------+
! Função    ! ViewDef      ! Autor ! Paulo A. Erzinger  ! Data !  22/10/2019 !
+-----------+--------------+-------+--------------------+------+-------------+
! Parâmetros! N/A                                                            !
+-----------+----------------------------------------------------------------+
! Descricao ! Cria o formulário com base no dicionário de dados              !
+-----------+----------------------------------------------------------------+
*/
Static Function ViewDef() 
 
Local oModel   := FWLoadModel("VTR0001")
Local oView    := FWFormView():New()
Local oStruZDD := FWFormStruct(2,"ZDD")

oView:SetModel(oModel)

oView:AddField("VIEW_ZDD", oStruZDD, "ZDDMASTER")
oView:CreateHorizontalBox("ZDD_ENCHOICE", 100)
oView:SetOwnerView("VIEW_ZDD", "ZDD_ENCHOICE") 
 
Return oView

/*
+----------------------------------------------------------------------------+
! Função    ! fImporta     ! Autor ! Paulo A. Erzinger  ! Data !  23/10/2019 !
+-----------+--------------+-------+--------------------+------+-------------+
! Parâmetros! N/A                                                            !
+-----------+----------------------------------------------------------------+
! Descricao ! Tela para importar produtos de acordo com os parâmetros        !
+-----------+----------------------------------------------------------------+
*/
User Function VTR0001_IMPORTA() 

Local aArea    := GetArea()
Local aSize    := MsAdvSize(.F.)
Local aObjects := {} 
Local aInfo    := {}

Local oOk  := LoadBitMap(GetResources(), "LBOK")
Local oNo  := LoadBitMap(GetResources(), "LBNO")

//Variáveis pesquisa
Private cProDe   := Space(TamSx3("B1_COD")[1])
Private cProAte  := Space(TamSx3("B1_COD")[1])
Private cDescri  := Space(TamSx3("B1_DESC")[1])
Private cMarca   := Space(TamSx3("B1_XMARCA")[1])
Private cCateg   := Space(TamSx3("B1_XCAT")[1])
Private cGrupo   := Space(TamSx3("B1_XDESGRU")[1])
Private cFamilia := Space(TamSx3("B1_XDESCFA")[1])
Private cTamanho := Space(TamSx3("B1_XDESTAM")[1])
Private cCor     := Space(TamSx3("B1_XDESCOR")[1])
Private aEcomm   := {"1=Sim","2=Nao","A=Ambos"}
Private cEcomm   := LEFT(aEcomm[3],1)

Private aHeader := {}
Private aCols   := {}

Private nUsado  := 0
Private aTela   := Array(0,0)
Private aGets   := Array(0)

Private cTitulo := "[VTR0001] - ADICIONA PRODUTOS A INTEGRACAO"

AAdd( aObjects, { 15, 15, .T., .T. } ) 
AAdd( aObjects, { 87, 87, .T., .T. } )
AAdd( aObjects, { 5, 5, .T., .T. } )

// Dados da área de trabalho e separação
aInfo := {aSize[1], aSize[2], aSize[3], aSize[4],3,3} 

//Chama MsObjSize e recebe array e tamanhos
aPosObj := MsObjSize( aInfo, aObjects,.T.)

oDlgImporta := TDialog():New(aSize[7],0,aSize[6],aSize[5],cTitulo,,,,,CLR_BLACK,CLR_WHITE,,,.T.)

//Área superior
oPPesq     := tPanel():New(aPosObj[1,1],aPosObj[1,2],,oDlgImporta,,.T.,,CLR_BLACK,CLR_WHITE,aPosObj[1,4],aPosObj[1,3])
oSayProDe  := TSay():New(005,007, {|| "Produto de:" },oPPesq,,,,,,.T.,CLR_BLACK,CLR_WHITE)
oGetProDe  := tGet():New(007,045,{|u| if(PCount()>0,cProDe:=u,cProDe)},oDlgImporta,80,9,,{ ||  },,,,,,.T.,,, {|| .T. } ,,,,.F.,,'SB1','cProDe')
oSayProAte := TSay():New(005,130, {|| "ate" },oPPesq,,,,,,.T.,CLR_BLACK,CLR_WHITE)
oGetProAte := tGet():New(007,150,{|u| if(PCount()>0,cProAte:=u,cProAte)},oDlgImporta,80,9,,{ ||  },,,,,,.T.,,, {|| .T. } ,,,,.F.,,'SB1','cProAte')

oSayDesc := TSay():New(005,240, {|| "Descrição:" },oPPesq,,,,,,.T.,CLR_BLACK,CLR_WHITE)
oGetDesc := tGet():New(007,285,{|u| if(PCount()>0,cDescri:=u,cDescri)},oDlgImporta,180,9,,{ ||  },,,,,,.T.,,, {|| .T. } ,,,,.F.,,,'cDescri')

oSayMarca := TSay():New(020,007, {|| "Marca:" },oPPesq,,,,,,.T.,CLR_BLACK,CLR_WHITE)
oGetMarca := tGet():New(022,045,{|u| if(PCount()>0,cMarca:=u,cMarca)},oDlgImporta,80,9,,{ ||  },,,,,,.T.,,, {|| .T. } ,,,,.F.,,,'cMarca')

oSayCateg := TSay():New(020,135, {|| "Categoria:" },oPPesq,,,,,,.T.,CLR_BLACK,CLR_WHITE)
oGetCateg := tGet():New(022,165,{|u| if(PCount()>0,cCateg:=u,cCateg)},oDlgImporta,80,9,,{ ||  },,,,,,.T.,,, {|| .T. } ,,,,.F.,,,'cCateg')

oSayGrupo := TSay():New(020,255, {|| "Grupo:" },oPPesq,,,,,,.T.,CLR_BLACK,CLR_WHITE)
oGetGrupo := tGet():New(022,285,{|u| if(PCount()>0,cGrupo:=u,cGrupo)},oDlgImporta,80,9,,{ ||  },,,,,,.T.,,, {|| .T. } ,,,,.F.,,,'cGrupo')

oSayFamil := TSay():New(035,007, {|| "Família:" },oPPesq,,,,,,.T.,CLR_BLACK,CLR_WHITE)
oGetFamil := tGet():New(037,045,{|u| if(PCount()>0,cFamilia:=u,cFamilia)},oDlgImporta,80,9,,{ ||  },,,,,,.T.,,, {|| .T. } ,,,,.F.,,,'cFamilia')

oSayTaman := TSay():New(035,135, {|| "Tamanho:" },oPPesq,,,,,,.T.,CLR_BLACK,CLR_WHITE)
oGetTaman := tGet():New(037,165,{|u| if(PCount()>0,cTamanho:=u,cTamanho)},oDlgImporta,80,9,,{ ||  },,,,,,.T.,,, {|| .T. } ,,,,.F.,,,'cTamanho')

oSayCor   := TSay():New(035,255, {|| "Cor:" },oPPesq,,,,,,.T.,CLR_BLACK,CLR_WHITE)
oGetCor   := tGet():New(037,285,{|u| if(PCount()>0,cCor:=u,cCor)},oDlgImporta,80,9,,{ ||  },,,,,,.T.,,, {|| .T. } ,,,,.F.,,,'cCor')

oSayEcomm := TSay():New(050,007, {|| "E-Commerce: " },oPPesq,,,,,,.T.,CLR_BLACK,CLR_WHITE)
oCmbEcomm := tComboBox():New(052,045,{|u|if(PCount()>0,cEcomm:=u,cEcomm)},aEcomm,045,11,oDlgImporta,,{||  },,,,.T.,,,,{|| .T. },,,,,'cEcomm')

oBtnPesq := TButton():New(050,100, "Pesquisar",oPPesq,{ || MsgRun("Buscando informações dos produtos","[VTR0001] - AGUARDE", {|x| fPesquisa() } ) }, 40,10,,,.F.,.T.,.F.,,.F.,,,.F.)

//oBrwPro := MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],0,"AllwaysTrue","AllwaysTrue",,,0,99,"AllwaysTrue","","AllwaysTrue",oDlgImporta,aHeader,aCols)
oBrwPro := TCBrowse():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,4],aPosObj[2,3]-65,,,,oDlgImporta,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oBrwPro:AddColumn(TCColumn():New(" "           , {|| If(aCols[oBrwPro:nAt,01],oOk,oNo) },,,,,,.T.,.F.,,,,.F., ) )
oBrwPro:AddColumn(TCColumn():New("Produto"     , {|| aCols[oBrwPro:nAt,02]},,,,, 50 ,.F.,.F.,,,,.F., ) )
oBrwPro:AddColumn(TCColumn():New("Descrição"   , {|| aCols[oBrwPro:nAt,03]},,,,, 50 ,.F.,.F.,,,,.F., ) )
oBrwPro:AddColumn(TCColumn():New("Local"       , {|| aCols[oBrwPro:nAt,04]},,,,, 50 ,.F.,.T.,,,,.F., ) )
oBrwPro:AddColumn(TCColumn():New("Preço"       , {|| aCols[oBrwPro:nAt,05]},"@E 9,999,999.99",,,"RIGHT", 50,.F.,.T.,,,,.F., ) )
oBrwPro:AddColumn(TCColumn():New("Cód. Barras" , {|| aCols[oBrwPro:nAt,06]},,,,, 50 ,.F.,.F.,,,,.F., ) )
oBrwPro:AddColumn(TCColumn():New("Marca"       , {|| aCols[oBrwPro:nAt,07]},,,,, 50 ,.F.,.F.,,,,.F., ) )
oBrwPro:AddColumn(TCColumn():New("Categoria"   , {|| aCols[oBrwPro:nAt,08]},,,,, 50 ,.F.,.F.,,,,.F., ) )
oBrwPro:AddColumn(TCColumn():New("Grupo"       , {|| aCols[oBrwPro:nAt,09]},,,,, 50 ,.F.,.F.,,,,.F., ) )
oBrwPro:AddColumn(TCColumn():New("Família"     , {|| aCols[oBrwPro:nAt,10]},,,,, 50 ,.F.,.F.,,,,.F., ) )
oBrwPro:AddColumn(TCColumn():New("Tamanho"     , {|| aCols[oBrwPro:nAt,11]},,,,, 50 ,.F.,.F.,,,,.F., ) )
oBrwPro:AddColumn(TCColumn():New("Cor"         , {|| aCols[oBrwPro:nAt,12]},,,,, 50 ,.F.,.F.,,,,.F., ) )
oBrwPro:SetArray(aCols)

oBrwPro:bLDblClick   := { || aCols[oBrwPro:nAt,01] := !aCols[oBrwPro:nAt,01] }
oBrwPro:bHeaderClick := { || fSelectAll() }

MsgRun("Buscando informações dos produtos","[VTR0001] - AGUARDE", {|x| fPesquisa() } )

//Botoes
oPButtons:= tPanel():New(aPosObj[3,1],aPosObj[3,2],,oDlgImporta,,.T.,,CLR_BLACK,CLR_WHITE,aPosObj[3,4],aPosObj[3,3])
oBtnConf := TButton():New(005, aPosObj[3,4]-115, "Confirmar",oPButtons,{|| Processa( {|| fGravaZDD() }, "[VTR0001] - AGUARDE", "Salvando informações...",.F.), ::End() }, 50,15,,,.F.,.T.,.F.,,.F.,,,.F.)
oBtnSair := TButton():New(005, aPosObj[3,4]-55 , "Cancelar" ,oPButtons,{|| ::End() }, 50,15,,,.F.,.T.,.F.,,.F.,,,.F.)

oDlgImporta:Activate(,,,.T.,{||,.T.},,{||} )

Return

/*
+------------------+---------------------------------------------------------+
!Nome              ! fPesquisa                                               !
+------------------+---------------------------------------------------------+
!Descricao         ! Busca os produtos de acordo com o filtro                !
+------------------+---------------------------------------------------------+
!Autor             ! PAULO AFONSO ERZINGER JUNIOR                            !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 23/10/2019                                              !
+------------------+---------------------------------------------------------+
*/
Static Function fPesquisa()

Local cAlias := GetNextAlias()
Local cWhere  := "%"

If ALLTRIM(cProDe) != ""
	cWhere += " AND SB1.B1_COD >= '"+ cProDe + "'"
EndIf

If ALLTRIM(cProAte) != ""
	cWhere += " AND SB1.B1_COD <= '"+ cProAte + "'"
EndIf

If ALLTRIM(cDescri) != ""
	cWhere += " AND UPPER(SB1.B1_DESC) LIKE '%"+ UPPER(STRTRAN(ALLTRIM(cDescri)," ","%")) + "%'"
EndIf

If ALLTRIM(cMarca) != ""
	cWhere += " AND UPPER(SB1.B1_XMARCA) LIKE '%"+ UPPER(STRTRAN(ALLTRIM(cMarca)," ","%")) + "%'"
EndIf

If ALLTRIM(cCateg) != ""
	cWhere += " AND UPPER(SB1.B1_XCAT) LIKE '%"+ UPPER(STRTRAN(ALLTRIM(cCateg)," ","%")) + "%'"
EndIf

If ALLTRIM(cGrupo) != ""
	cWhere += " AND UPPER(SB1.B1_XDESGRU) LIKE '%"+ UPPER(STRTRAN(ALLTRIM(cGrupo)," ","%")) + "%'"
EndIf

If ALLTRIM(cFamilia) != ""
	cWhere += " AND UPPER(SB1.B1_XDESCFA) LIKE '%"+ UPPER(STRTRAN(ALLTRIM(cFamilia)," ","%")) + "%'"
EndIf

If ALLTRIM(cTamanho) != ""
	cWhere += " AND UPPER(SB1.B1_XDESTAM) LIKE '%"+ UPPER(STRTRAN(ALLTRIM(cTamanho)," ","%")) + "%'"
EndIf

If ALLTRIM(cCor) != ""
	cWhere += " AND UPPER(SB1.B1_XDESCOR) LIKE '%"+ UPPER(STRTRAN(ALLTRIM(cCor)," ","%")) + "%'"
EndIf

If LEFT(cEcomm,1) != "A"
	cWhere += " AND SB1.B1_XECFLAG = '"+ LEFT(cEcomm,1) + "'"
EndIf

cWhere += "%"

BeginSQL alias cAlias
	SELECT 	SB1.B1_COD, SB1.B1_DESC, SB1.B1_LOCPAD, SB1.B1_PRV1, SB1.B1_CODBAR, SB1.B1_XMARCA,
			SB1.B1_XDESGRU, SB1.B1_XDESCFA, SB1.B1_XDESCEM, SB1.B1_XDESTAM, SB1.B1_XDESCOR, SB1.B1_XCAT,
			SB1.R_E_C_N_O_ AS B1_RECNO

	FROM %table:SB1% (NOLOCK) SB1
	
	WHERE SB1.B1_FILIAL = %xfilial:SB1%
	%exp:cWhere%
	AND NOT EXISTS (SELECT ZDD.ZDD_PRODUT FROM %table:ZDD% (NOLOCK) ZDD WHERE ZDD.ZDD_FILIAL = %xfilial:ZDD% AND ZDD.ZDD_PRODUT = SB1.B1_COD AND ZDD.%notDel%)
	AND SB1.B1_MSBLQL <> '1'
	AND SB1.%notDel%
EndSQL

(cAlias)->(dbGoTop())

aCols := {}
While (cAlias)->(!Eof())

	AADD(aCols,Array(13))
	
	nX := Len(aCols)
	
	aCols[nX,01] := .F.
	aCols[nX,02] := (cAlias)->B1_COD
	aCols[nX,03] := (cAlias)->B1_DESC
	aCols[nX,04] := (cAlias)->B1_LOCPAD
	aCols[nX,05] := (cAlias)->B1_PRV1
	aCols[nX,06] := (cAlias)->B1_CODBAR
	aCols[nX,07] := (cAlias)->B1_XMARCA
	aCols[nX,08] := (cAlias)->B1_XCAT
	aCols[nX,09] := (cAlias)->B1_XDESGRU
	aCols[nX,10] := (cAlias)->B1_XDESCFA
	aCols[nX,11] := (cAlias)->B1_XDESTAM
	aCols[nX,12] := (cAlias)->B1_XDESCOR
	aCols[nX,13] := (cAlias)->B1_RECNO

	(cAlias)->(dbSkip())
EndDo

If SELECT(cAlias) > 0
	(cAlias)->(dbCloseArea())
EndIf

oBrwPro:SetArray(aCols)
oBrwPro:Refresh()

Return

//============================ Inverte a seleção ============================//
Static Function fSelectAll()

For nX:=1 to Len(aCols)
	aCols[nX,1] := !aCols[nX,1]
Next nX

oBrwPro:Refresh()

Return

/*
+------------------+---------------------------------------------------------+
!Nome              ! fGravaZDD                                               !
+------------------+---------------------------------------------------------+
!Descricao         ! Grava os produtos selecionados na tabela de integração  !
+------------------+---------------------------------------------------------+
!Autor             ! PAULO AFONSO ERZINGER JUNIOR                            !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 23/10/2019                                              !
+------------------+---------------------------------------------------------+
*/
Static Function fGravaZDD()

Local lGrava := .T.

For nX:=1 to Len(aCols)

	IncProc()
	
	If aCols[nX,01]
		dbSelectArea("SB1")
		dbGoTo(aCols[nX,13])
		
		dbSelectArea("ZDD")
		dbSetOrder(1)
		dbGoTop()
		lGrava := !dbSeek(xFilial("ZDD")+SB1->B1_COD)
		
		Reclock("ZDD", lGrava)
		ZDD->ZDD_FILIAL := xFilial("ZDD")
		ZDD->ZDD_PRODUT := SB1->B1_COD
		ZDD->ZDD_DESCRI := SB1->B1_DESC
	//	ZDD->ZDD_TABELA := 
		ZDD->ZDD_LOCAL  := SB1->B1_LOCPAD
	//	ZDD->ZDD_QUANT  := 
		ZDD->ZDD_PESO   := SB1->B1_PESBRU
		ZDD->ZDD_COMP   := SB1->B1_XECCOMP
		ZDD->ZDD_ALT    := SB1->B1_XECALTU
		ZDD->ZDD_LARG   := SB1->B1_XECLARG
		ZDD->ZDD_STATUS := "A"
	//	ZDD->ZDD_PROID  := 
		ZDD->ZDD_VARID  := SB1->B1_CODBAR
		ZDD->ZDD_CODMKT := "001"
		ZDD->ZDD_MARCA  := SB1->B1_XMARCA
		ZDD->ZDD_PRECO  := SB1->B1_PRV1
	//	ZDD->ZDD_PRCPRM := 
		ZDD->ZDD_NOMPRO := SB1->B1_XECDESC
		ZDD->ZDD_DESPRO := SB1->B1_XECDCOM
	//	ZDD->ZDD_INIOFE := 
	//	ZDD->ZDD_FIMOFE :=	
		ZDD->ZDD_ATUPRO := "S"
		ZDD->ZDD_ATUEST := "S"
		ZDD->ZDD_DATUES := DATE()
		ZDD->ZDD_HATUES := TIME()
		ZDD->ZDD_ATUPRC := "S"
		ZDD->ZDD_DATA   := DATE()
		ZDD->ZDD_HORA   := TIME()
		ZDD->(MsUnlock())
	EndIf
Next nX

dbSelectArea("ZDD")
dbSetOrder(1)
dbGoTop()

Return