﻿CREATE TABLE [dbo].[PNPA_FlatfileGeneRation] (
  [Dedup NCIF] [varchar](20) NULL,
  [SourceSystem] [varchar](50) NULL,
  [CustomerID] [varchar](20) NULL,
  [CustomerName] [varchar](80) NULL,
  [Account No.] [varchar](22) NULL,
  [BillNo] [varchar](1) NOT NULL,
  [Customer Segment] [varchar](100) NULL,
  [Scheme_ProductCode] [varchar](50) NULL,
  [Scheme_ProductCodeDescription] [varchar](100) NULL,
  [Facility] [varchar](5) NULL,
  [Limit] [decimal](16, 2) NULL,
  [DrawingPower] [decimal](16, 2) NULL,
  [Outstanding] [decimal](16, 2) NULL,
  [POS] [decimal](16, 2) NULL,
  [IrregularAmount] [decimal](16, 2) NULL,
  [DPD] [smallint] NULL,
  [DPD_Overdue_Loan] [smallint] NULL,
  [DPD_InterestNotService] [smallint] NULL,
  [DPD_Overdrawn] [smallint] NULL,
  [DPD_Renewals] [smallint] NULL,
  [PNPA_Date] [varchar](20) NULL,
  [NF_PNPA_Date] [varchar](25) NULL,
  [SubSegment] [varchar](100) NULL,
  [MaxDPD] [smallint] NULL,
  [AssetClass] [varchar](50) NULL,
  [ReasonForDefault] [varchar](76) NULL,
  [date1] [varchar](20) NULL,
  [CUSTOMER_IDENTIFIER] [char](1) NULL,
  [ActualOutStanding] [decimal](16, 2) NOT NULL,
  [PrincipleOutstanding] [decimal](16, 2) NOT NULL,
  [SrcSysAlt_Key] [smallint] NULL
)
ON [PRIMARY]
GO