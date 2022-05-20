
#Include "Protheus.ch"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "TOPCONN.CH"

User function FTLAYA001()

Local oBrowse		:= NIL

Private cTit		:= "Cadastro dinamico de layout"
Private aRotina		:= MenuDef()
	
	DbSelectArea("PR1")

	oBrowse := FWMBrowse():New()
	
	oBrowse:SetAlias("PR1")
	oBrowse:SetDescription(cTit)
	oBrowse:SetMenuDef('FTLAYA001')
	
	oBrowse:Activate()
	
Return NIL

/*/
@Function:	ModelDef
@desc:		Monta model da rotina
@author:	Henrique Ghidini da Silva
@param:     
@version: 	1.00
@since: 	06/09/2018
/*/

Static Function ModelDef()

Local oModel		:= NIL
Local oStruCab		:= FWFormStruct(1,"PR1")
Local oStruItens	:= FWFormStruct(1,"PR2")

// Modelo de Dados
oModel := MPFormModel():New("LAYA001",/*_bPreValid*/,/*bPosValid*/,/*bCommit*/,/*bCancel*/)

// Adiciona ao modelo uma estrutura de formulario de edicao por campo
oModel:AddFields("PR1MASTER",/*cOwner*/ ,oStruCab)

//Adiciona grid de itens
oModel:AddGrid("PR2DETAIL", "PR1MASTER" ,oStruItens )

//Seta chave unica do grid de itens.
oModel:GetModel('PR2DETAIL'):SetUniqueLine({"PR2_FILIAL","PR2_CODIGO","PR2_CPODES"})

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription(cTit)

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( "PR1MASTER" ):SetDescription("Cabecalho")

//Relacionamento dos modelos
oModel:SetRelation('PR2DETAIL',{{'PR2_FILIAL','PR1_FILIAL'},{'PR2_CODIGO','PR1_CODIGO'}}, PR2->(IndexKey(1)))

// Criar uma chave primaria
oModel:SetPrimaryKey( {"PR1_FILIAL","PR1_CODPZA"} )

Return oModel

/*/
@Function:	MenuDef
@desc:		Menu de ações da rotina.
@author:	Henrique Ghidini da Silva
@param:     
@version: 	1.00
@since: 	06/09/2018
/*/

Static Function MenuDef()

Local aRotina 	:= {}

	ADD OPTION aRotina TITLE 'Visualizar'			ACTION 'VIEWDEF.FTLAYA001'	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'  			ACTION 'VIEWDEF.FTLAYA001'	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'  			ACTION 'VIEWDEF.FTLAYA001'	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    			ACTION 'VIEWDEF.FTLAYA001'  OPERATION 5 ACCESS 0

Return aRotina   

/*/
@Function:	ViewDef
@desc:		Tela de visualização do arotina.
@author:	Henrique Ghidini da Silva
@param:     
@version: 	1.00
@since: 	06/09/2018
/*/

Static Function ViewDef()

Local oModel		:= FWLoadModel( "FTLAYA001" )
Local oStruCab		:= FWFormStruct(2,"PR1")
Local oStruItens	:= FWFormStruct(2,"PR2")
Local oView			:= NIL

// Cria objeto de VIEW
oView := FWFormView():New()
oView:SetModel(oModel)


// Adiciona controle do tipo enchoice (antiga)
oView:AddField("VIEWPR1"	, oStruCab	    , "PR1MASTER")
oView:AddGrid("VIEWITENS"	, oStruItens    , "PR2DETAIL")

//Divisão da tela
oView:CreateHorizontalBox("TELA"    ,20)
oView:CreateHorizontalBox("ITENS"   ,80)

//Seta as view nos box criados.
oView:SetOwnerView("VIEWPR1"	,"TELA")
oView:SetOwnerView("VIEWITENS"	,"ITENS")

oView:SetCloseOnOk({||.T.})

Return oView
