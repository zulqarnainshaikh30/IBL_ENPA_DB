﻿CREATE TABLE [dbo].[RestructureAccount_DPD_all_old] (
  [NCIF_Id] [varchar](15) NULL,
  [CustomerId] [varchar](20) NULL,
  [AccountEntityID] [int] NULL,
  [CustomerACID] [varchar](20) NULL,
  [MaxDPD] [int] NULL,
  [TimeKey] [int] NULL,
  [DPD_DATE] [datetime] NOT NULL,
  [NCIF_MaxDPD] [int] NULL,
  [Restructure_Type] [varchar](50) NULL
)
ON [PRIMARY]
GO