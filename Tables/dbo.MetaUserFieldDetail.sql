﻿CREATE TABLE [dbo].[MetaUserFieldDetail] (
  [CreaSta] [varchar](7) NULL,
  [ModifyDt] [datetime] NULL,
  [UserID] [varchar](8) NULL,
  [LastUpdated] [timestamp],
  [CODE] [int] NOT NULL,
  [FrmName] [varchar](50) NULL,
  [CtrlName] [varchar](100) NULL,
  [FldName] [varchar](100) NULL,
  [FldCaption] [varchar](100) NULL,
  [FldDataType] [varchar](20) NULL,
  [FldLength] [varchar](10) NULL,
  [FldGrdWidth] [varchar](10) NULL,
  [FldSearch] [char](1) NULL,
  [ErrorCheck] [char](1) NULL,
  [DataSeq] [smallint] NULL,
  [FldGridView] [varchar](2) NULL,
  [CriticalErrorType] [varchar](2) NULL,
  [MsgFlag] [char](1) NULL,
  [MsgDescription] [varchar](200) NULL,
  [ReportFieldNo] [int] NULL,
  [ScreenFieldNo] [int] NULL,
  [ViableForSCD2] [char](1) NOT NULL,
  [RptCaption] [varchar](100) NULL,
  [Editable] [char](1) NULL,
  [ReferenceColumnName] [varchar](80) NULL,
  [ReferenceTableName] [varchar](80) NULL
)
ON [PRIMARY]
GO