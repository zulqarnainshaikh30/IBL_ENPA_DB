﻿CREATE TABLE [dbo].[RestructureAccount_DPD_Jun2022] (
  [SrcSysAlt_Key] [smallint] NULL,
  [NCIF_Id] [varchar](15) NULL,
  [NCIF_EntityID] [int] NULL,
  [CustomerId] [varchar](20) NULL,
  [AccountEntityID] [int] NULL,
  [CustomerACID] [varchar](20) NULL,
  [MaxDPD] [int] NULL,
  [TimeKey] [int] NULL,
  CHECK ([TimeKey]>=(26450) AND [TimeKey]<=(26479))
)
ON [PRIMARY]
GO