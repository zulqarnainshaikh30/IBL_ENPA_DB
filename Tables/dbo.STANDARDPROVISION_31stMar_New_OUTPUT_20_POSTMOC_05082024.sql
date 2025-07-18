﻿CREATE TABLE [dbo].[STANDARDPROVISION_31stMar_New_OUTPUT_20_POSTMOC_05082024] (
  [NCIF_AssetClassAlt_Key] [smallint] NULL,
  [STD_ASSET_CAT_STAT] [nvarchar](50) NULL,
  [TotalProvision] [decimal](16, 2) NULL,
  [Balance] [decimal](16, 2) NULL,
  [STD_ASSET_CAT_Prov] [decimal](22, 4) NULL,
  [PrincipleOutstanding] [decimal](16, 2) NULL,
  [IsRestructured] [varchar](1) NULL,
  [NCIF_Id] [varchar](100) NULL,
  [CustomerId] [varchar](20) NULL,
  [CustomerName] [varchar](500) NULL,
  [CustomerACID] [varchar](20) NULL,
  [SrcSysAlt_Key] [smallint] NULL
)
ON [PRIMARY]
GO