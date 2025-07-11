﻿CREATE TABLE [dbo].[NPAMovement] (
  [NPAProcessingDate] [datetime] NULL,
  [Timekey] [int] NULL,
  [SourceAlt_Key] [int] NULL,
  [BranchCode] [varchar](10) NULL,
  [CustomerID] [varchar](20) NULL,
  [CustomerEntityID] [int] NULL,
  [CustomerAcid] [varchar](20) MASKED WITH (FUNCTION = 'default()') NULL,
  [AccountEntityID] [int] NULL,
  [CustomerName] [varchar](500) NULL,
  [MovementNature] [varchar](100) NULL,
  [InitialAssetClassAlt_Key] [int] NULL,
  [InitialNPABalance] [decimal](18, 2) NULL,
  [InitialUnservicedInterest] [decimal](18, 2) NULL,
  [InitialGNPABalance] [decimal](18, 2) NULL,
  [InitialProvision] [decimal](18, 2) NULL,
  [InitialNNPABalance] [decimal](18, 2) NULL,
  [ExistingNPA_Addition] [decimal](18, 2) NULL,
  [FreshNPA_Addition] [decimal](18, 2) NULL,
  [ReductionDuetoUpgradeAmount] [decimal](18, 2) NULL,
  [ReductionDuetoWrite_OffAmount] [decimal](18, 2) NULL,
  [ReductionDuetoRecovery_ExistingNPA] [decimal](18, 2) NULL,
  [ReductionDuetoRecovery_Arcs] [decimal](18, 2) NULL,
  [FinalAssetClassAlt_Key] [int] NULL,
  [FinalNPABalance] [decimal](18, 2) NULL,
  [FinalUnservicedInterest] [decimal](18, 2) NULL,
  [FinalGNPABalance] [decimal](18, 2) NULL,
  [FinalProvision] [decimal](18, 2) NULL,
  [FinalNNPABalance] [decimal](18, 2) NULL,
  [TotalAddition_GNPA] [decimal](18, 2) NULL,
  [TotalReduction_GNPA] [decimal](18, 2) NULL,
  [TotalAddition_Provision] [decimal](18, 2) NULL,
  [TotalReduction_Provision] [decimal](18, 2) NULL,
  [TotalAddition_UnservicedInterest] [decimal](18, 2) NULL,
  [TotalReduction_UnservicedInterest] [decimal](18, 2) NULL,
  [MovementStatus] [varchar](200) NULL,
  [NPAReason] [varchar](200) NULL,
  [WriteOffFlag] [char](1) NULL,
  [ARCSaleFlag] [char](1) NULL,
  [TransferOut_Flag] [char](1) NULL,
  [TransferOut_Balance] [decimal](18, 2) NULL,
  [TransferIn_Flag] [char](1) NULL,
  [TransferIn_Balance] [decimal](18, 2) NULL,
  [CheckIn_Flag] [char](1) NULL,
  [CheckIn_Remark] [varchar](1000) NULL,
  [Movement_Flag] [char](1) NULL,
  [Ncif_Id] [varchar](20) NULL
)
ON [PRIMARY]
GO