
#Include "Protheus.ch"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "TOPCONN.CH"

User function FTLAYA001()

Local oBrowse		:= NIL

Private cTit		:= "Cadastro dinamico de layout"
Private aRotina		:= MenuDef()
	
	DbSelectArea("PR2")

	oBrowse := FWMBrowse():New()
	
	oBrowse:SetAlias("PR2")
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
Local oStruCab		:= FWFormStruct(1,"PR2")
Local oStruItens	:= FWFormStruct(1,"PR3")

// Modelo de Dados
oModel := MPFormModel():New("LAYA001",/*_bPreValid*/,/*bPosValid*/,/*bCommit*/,/*bCancel*/)

// Adiciona ao modelo uma estrutura de formulario de edicao por campo
oModel:AddFields("PR2MASTER",/*cOwner*/ ,oStruCab)

//Adiciona grid de itens
oModel:AddGrid("PR3DETAIL", "PR2MASTER" ,oStruItens )

//Seta chave unica do grid de itens.
oModel:GetModel('PR3DETAIL'):SetUniqueLine({"PR3_FILIAL","PR3_CODIGO","PR3_CPODES"})

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription(cTit)

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( "PR2MASTER" ):SetDescription("Cabecalho")

//Relacionamento dos modelos
oModel:SetRelation('PR3DETAIL',{{'PR3_FILIAL','PR2_FILIAL'},{'PR3_CODIGO','PR2_CODIGO'}}, PR3->(IndexKey(1)))

// Criar uma chave primaria
oModel:SetPrimaryKey( {"PR2_FILIAL","PR2_CODPZA"} )

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
Local oStruCab		:= FWFormStruct(2,"PR2")
Local oStruItens	:= FWFormStruct(2,"PR3")
Local oView			:= NIL

// Cria objeto de VIEW
oView := FWFormView():New()
oView:SetModel(oModel)


// Adiciona controle do tipo enchoice (antiga)
oView:AddField("VIEWPR2"	, oStruCab	    , "PR2MASTER")
oView:AddGrid("VIEWITENS"	, oStruItens    , "PR3DETAIL")

//Divisão da tela
oView:CreateHorizontalBox("TELA"    ,20)
oView:CreateHorizontalBox("ITENS"   ,80)

//Seta as view nos box criados.
oView:SetOwnerView("VIEWPR2"	,"TELA")
oView:SetOwnerView("VIEWITENS"	,"ITENS")

oView:SetCloseOnOk({||.T.})

Return oView
