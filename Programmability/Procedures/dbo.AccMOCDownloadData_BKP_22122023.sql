﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create PROCEDURE [dbo].[AccMOCDownloadData_BKP_22122023]
	@Timekey INT
	,@UserLoginId VARCHAR(100)
	,@ExcelUploadId INT
	,@UploadType VARCHAR(50)
	--,@Page SMALLINT =1     
 --   ,@perPage INT = 30000   
AS

----DECLARE @Timekey INT=49999
----	,@UserLoginId VARCHAR(100)='FNASUPERADMIN'
----	,@ExcelUploadId INT=4
----	,@UploadType VARCHAR(50)='Interest reversal'

BEGIN
		SET NOCOUNT ON;

		SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus_MOC='C' and MOC_Initialised='Y') 
--		set @Timekey=(select CAST(B.timekey as int)from SysDataMatrix A
--Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
-- where A.CurrentStatus='C')

  --SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey) 
		--  		  PRINT @Timekey  

		--DECLARE @PageFrom INT, @PageTo INT   
  
		--SET @PageFrom = (@perPage*@Page)-(@perPage) +1  
		--SET @PageTo = @perPage*@Page  

IF (@UploadType='Account MOC Upload')

BEGIN
		PRINT 'REV'
		--SELECT * FROM(
		SELECT 'Details' as TableName
		,A.UploadID
		, Row_Number() over(order by A.NCIF_Id) as SrNo
		--,A.AsOnDate
		--,A.PAN
		,A.NCIF_Id AS NCIF_Id
		,A.CustomerName
		,A.CustomerACID AS AccountID
		--,A.NCIF_ID  NCIF_ID
		,A.CustomerID AS CustomerID
		,S.SourceName  SourceSystem
		,A.Balance AS GrossBalance
		,A.PrincipleOutstanding  PrincipalOutstanding
		--,A.UNSERVED_INTEREST AS UnservicedInterestAmount 
		,A.IntOverdue AS UnservicedInterestAmount			------ Replace From UNSERVED_INTEREST to IntOverDue By Satwaji as on 03/09/2021 as per Bank's Requirement Change
		,A.AddlProvisionPer AS Additionalprovisionpercentage
		,A.AddlProvision  AdditionalprovisionAmount
		,B.AccProvPer AS AcceleratedProvisionPercentage
		--,A.ApprRV AS SecurityValue
		,A.SecurityValue AS SecurityValue
		,R.MocReasonName  MOCReason
		
		------,ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS ROW_NUM
		FROM NPA_IntegrationDetails_MOD A
		LEFT JOIN IBL_ENPA_DB_LOCAL_DEV..AcceleratedProv_MOD B ON A.CustomerACID=B.CustomerACID  /* (implemented at 04052023 at prod) */
		AND A.UploadId=B.UploadId     /* (implemented at 04052023 at prod) */
		AND (B.EffectiveFromTimeKey<=@Timekey AND B.EffectiveToTimeKey>=@Timekey)
		LEFT JOIN dimsourcesystem S ON S.SourceAlt_Key=A.SrcSysAlt_Key
		LEFT JOIN DimMocReason  R ON R.MocReasonAlt_Key= A.ACMOC_ReasonAlt_Key
		WHERE A.UploadID=@ExcelUploadId
		AND (A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey)

		SELECT 
		'Summary' as TableName
		--, Row_Number() over(order by NCIF_Id) as SrNo
		--,UploadID
		----,SummaryID
		--,NCIF_Id AS DedupIDUCICEnterpriseCIF
		--,CustomerName
		--,CustomerACID AS CustomerAccountNo
		--,Balance
		--,PrincipleOutstanding AS PrincipleOutstanding
		--,UNSERVED_INTEREST
		--,AddlProvisionPer
		--,AddlProvision AS AddlProvision
		--,ApprRV  AS SecurityValue

		,COUNT(*) as Count
		,Sum(isnull(cast(Balance as float),0))Balance
		--,Sum(isnull(cast(ApprRV as float),0))SecurityValue /* (implemented at 04052023 at prod) */
		,Sum(isnull(cast(SecurityValue as float),0))SecurityValue /* (implemented at 04052023 at prod) */	

		
		------,ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS ROW_NUM
		FROM NPA_IntegrationDetails_MOD
		WHERE UploadId=@ExcelUploadId
		AND (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey)

		--)A
		--WHERE ROW_NUM BETWEEN  @PageFrom AND @PageTo
		--ORDER BY ROW_NUM  

END



END

--select * from AccountLvlMOCDetails_stg
GO