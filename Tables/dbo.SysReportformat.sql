﻿CREATE TABLE [dbo].[SysReportformat] (
  [SrNo] [int] NOT NULL,
  [BankName] [varchar](80) NULL,
  [BankNameFontSize] [varchar](50) NULL,
  [BankNameFontFamily] [varchar](50) NULL,
  [BankNameFontStyle] [varchar](50) NULL,
  [BankNameFontWeight] [varchar](50) NULL,
  [BankNameColour] [varchar](50) NULL,
  [BankAddress] [varchar](150) NULL,
  [BankAddFontSize] [varchar](50) NULL,
  [BankAddFontFamilly] [varchar](50) NULL,
  [BankAddFontStyle] [varchar](50) NULL,
  [BankAddFontWeight] [varchar](50) NULL,
  [BankAddFontColour] [varchar](50) NULL,
  [ReportNameFontSize] [varchar](50) NULL,
  [ReportNameFontFamilly] [varchar](50) NULL,
  [ReportNameFontStyle] [varchar](50) NULL,
  [ReportNameFontWeight] [varchar](50) NULL,
  [ReportNameFontColour] [varchar](50) NULL,
  [HeadFontSize] [varchar](50) NULL,
  [HeadFontFamily] [varchar](50) NULL,
  [HeadFontStyle] [varchar](50) NULL,
  [HeadFontWeight] [varchar](50) NULL,
  [HeadColour] [varchar](50) NULL,
  [HeadBGColour] [varchar](50) NULL,
  [BodyFontSize] [varchar](50) NULL,
  [BodyFontFamily] [varchar](50) NULL,
  [BodyFontStyle] [varchar](50) NULL,
  [BodyFontWeight] [varchar](50) NULL,
  [BodyColour] [varchar](50) NULL,
  [BodyBGcolour] [varchar](10) NULL,
  [GrantTotalFontSize] [varchar](50) NULL,
  [GrantFontFamily] [varchar](50) NULL,
  [GrantFontStyle] [varchar](50) NULL,
  [GrantFontWeight] [varchar](50) NULL,
  [GrantColour] [varchar](50) NULL,
  [GrantBGcolour] [varchar](10) NULL,
  [Tier] [smallint] NULL,
  [BranchLbl] [varchar](10) NULL,
  [RegionLbl] [varchar](10) NULL,
  [ZoneLbl] [varchar](10) NULL,
  [BankLbl] [varchar](10) NULL,
  [AmountIn] [int] NULL,
  [ReportPathName] [bit] NULL,
  [HindiFont] [varchar](50) NULL,
  [HindiFontFamily] [varchar](50) NULL,
  [HindiFontStyle] [varchar](50) NULL,
  [HindiFontWeight] [varchar](50) NULL,
  [BranchTotal] [varchar](30) NULL,
  [RegionTotal] [varchar](30) NULL,
  [ZoneTotal] [varchar](30) NULL,
  [BankTotal] [varchar](30) NULL,
  [CustomerID] [varchar](30) NULL,
  [CustomerName] [varchar](30) NULL,
  [D2KName] [varchar](50) NULL,
  [FooterFontFamily] [varchar](50) NULL,
  [FooterFontSize] [varchar](50) NULL,
  [FooterFontStyle] [varchar](50) NULL,
  [FooterFontWeight] [varchar](50) NULL,
  [HeaderDetailFontFamily] [varchar](50) NULL,
  [HeaderDetailFontSize] [varchar](50) NULL,
  [HeaderDetailFontStyle] [varchar](50) NULL,
  [HeaderDetailFontWeight] [varchar](50) NULL,
  [FormatG] [varchar](400) NULL,
  [FormatF] [varchar](400) NULL,
  [ImagePath] [varchar](400) NULL,
  [BankNameHindi] [nvarchar](max) NULL,
  [BankAddressHindi] [nvarchar](max) NULL,
  [BankAlt_Key] [smallint] NULL,
  [RBIBankCode] [varchar](4) NULL,
  [BankCode] [varchar](20) NULL,
  [Active] [char](1) NULL,
  [BranchVisibility] [char](1) NULL,
  [RegionVisibility] [char](1) NULL,
  [ZoneVisibility] [char](1) NULL,
  [BankVisibility] [char](1) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO