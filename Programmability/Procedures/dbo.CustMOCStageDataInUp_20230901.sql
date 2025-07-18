﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE  [dbo].[CustMOCStageDataInUp_20230901]
	@Timekey INT,
	@UserLoginID VARCHAR(100),
	@OperationFlag INT,
	@MenuId INT,
	@AuthMode	CHAR(1),
	@filepath VARCHAR(MAX),
	@EffectiveFromTimeKey INT,
	@EffectiveToTimeKey	INT,
    @Result		INT=0 OUTPUT,
	@UniqueUploadID INT
	--@Authlevel varchar(5)

AS

--DECLARE @Timekey INT=24928,
--	@UserLoginID VARCHAR(100)='FNAOPERATOR',
--	@OperationFlag INT=1,
--	@MenuId INT=163,
--	@AuthMode	CHAR(1)='N',
--	@filepath VARCHAR(MAX)='',
--	@EffectiveFromTimeKey INT=24928,
--	@EffectiveToTimeKey	INT=49999,
--    @Result		INT=0 ,
--	@UniqueUploadID INT=41
BEGIN
SET DATEFORMAT DMY
	SET NOCOUNT ON;

   DECLARE @AsOnDate VARCHAR(10)
	SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus_MOC='C' and MOC_Initialised='Y') 

	--SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey) 

	PRINT @TIMEKEY

	SET @EffectiveFromTimeKey=@TimeKey
	SET @EffectiveToTimeKey=@TimeKey


	DECLARE @FilePathUpload	VARCHAR(100)
				   SET @FilePathUpload=@UserLoginId+'_'+@filepath
					PRINT '@FilePathUpload'
					PRINT @FilePathUpload


		BEGIN TRY

		--BEGIN TRAN
		
IF (@MenuId=97)
BEGIN


	IF (@OperationFlag=1)

	BEGIN

		IF NOT (EXISTS (SELECT 1 FROM CustMOCUpload_stg  where filname=@FilePathUpload))

							BEGIN
									 --Rollback tran
									SET @Result=-8

								RETURN @Result
							END
			
			PRINT 'Sachin'

		---------- Implement Logic of AsOnDate for Enquiry Screen Grid Data Fetching --------------
		IF EXISTS(SELECT 1 FROM CustMOCUpload_stg WHERE filname=@FilePathUpload)
	
	
		BEGIN
				------ Fetch the Value of AsOndate From Stage Table Brfore Inserting into ExcelUploadHistory Table
				SET @AsOnDate = (SELECT TOP 1 AsOnDate FROM CustMOCUpload_stg WHERE filname=@FilePathUpload)
		END

		----------- Create Sequence for Implementation of UploadId as on 01/10/2021 BY SATWAJI ----------
		--CREATE SEQUENCE [dbo].[Seq_UploadId] -- change sequence name
		-- AS [int]            
		-- START WITH 879        ---change start value if required
		-- INCREMENT BY 1
		-- MINVALUE -2147483648  
		-- MAXVALUE 2147483647
		-- CACHE
		--GO

		---use of sequence
		DECLARE @ExcelUploadId int
		select @ExcelUploadId=next value for [dbo].[Seq_UploadId]  
		select @ExcelUploadId

		SET DATEFORMAT DMY
		IF EXISTS(SELECT 1 FROM CustMOCUpload_stg WHERE filname=@FilePathUpload)
		BEGIN
		
	--	INSERT INTO ExcelUploadHistory
	--(
	--	UploadedBy	
	--	,DateofUpload	
	--	,AuthorisationStatus	
	--	--,Action	
	--	,UploadType
	--	,EffectiveFromTimeKey	
	--	,EffectiveToTimeKey	
	--	,CreatedBy	
	--	,DateCreated	
	--	,AsOnDate					-------- New Column Added By Satwaji as on 02/09/2021
		
	--)

	--SELECT @UserLoginID
	--	   ,GETDATE()
	--	   ,'NP'
	--	   --,'NP'
	--	   ,'Customer MOC Upload'
	--	   ,@EffectiveFromTimeKey
	--	   ,@EffectiveToTimeKey
	--	   ,@UserLoginID
	--	   ,GETDATE()
	--	   ,CONVERT(Date,@AsOnDate,103)


	--	   PRINT @@ROWCOUNT

	--	   DECLARE @ExcelUploadId INT
	--		SET @ExcelUploadId=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)
		
	--		Insert into UploadStatus (FileNames,UploadedBy,UploadDateTime,UploadType)
	--	Values(@filepath,@UserLoginID ,GETDATE(),'Customer MOC Upload')

		IF OBJECT_ID('tempdb..#StageTEMP') IS NOT NULL
				DROP TABLE #StageTEMP

				IF OBJECT_ID('tempdb..#Npa_IntegrationDetails') IS NOT NULL
				DROP TABLE #Npa_IntegrationDetails

		SELECT NCIF_Id,MOC_AssetClassification,MOC_NPADate--,MOC_Reason,MOC_Type,MOC_Source
		INTO #StageTEMP 
		FROM CustMOCUpload_Stg 
		GROUP BY NCIF_Id,MOC_AssetClassification,MOC_NPADate--,MOC_Reason,MOC_Type,MOC_Source

		select *  into #Npa_IntegrationDetails from NPA_IntegrationDetails 
		WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
		and NCIF_Id IN (select NCIF_Id from #StageTEMP)

		SET DATEFORMAT DMY
		
		DECLARE @Entity_Key Int   IF (@Entity_Key IS NULL)

                        BEGIN 
						  SET    @Entity_Key=isnull(@Entity_Key,0)+1
						END 

		Insert INTO NPA_IntegrationDetails_mod
		(
			UploadID
			,NCIF_Id
			,NCIF_EntityID
			,AccountEntityID
			,CustomerId
			,CustomerACID
			,CustomerName
			,MOC_AssetClassAlt_Key
			,MOC_NPA_Date
			,AddlProvisionPer
			,MOC_ReasonAlt_Key
			,MOCTYPE
			,MOC_Remark
			,AuthorisationStatus
			,EffectiveFromTimeKey
			,EffectiveToTimeKey
			,CreatedBy
			,DateCreated

			,IsUpload
		)

		--select ExcelUploadId,NCIF_Id,Entity_Key,Accountentityid,CustomerId,CustomerACID,CustomerName,AssetClassAlt_Key,MOC_NPADate,
		--		AdditionalProvisionPercentage,MocReasonAlt_Key,MOC_Type,Remark,AuthorisationStatus,EffectiveFromTimeKey,EffectiveToTimeKey,CreatedBy,DateCreated from (
		SELECT
		--Distinct
			-- A.SrNo
			--ROW_NUMBER() OVER(PARTITION BY A.CustomerId  ORDER BY  A.CustomerId) as Rownumber,
			@ExcelUploadId --@ExcelUploadId AS ExcelUploadId
			--,A.SummaryID
			--,A.AsOnDate
			,N.NCIF_Id AS NCIF_Id
			,@Entity_Key AS Entity_Key
			,N.Accountentityid		AS Accountentityid
			,CAse When A.CustomerId	IS NULL THEN N.CustomerId Else A.CustomerId ENd		AS CustomerId
			,N.CustomerACID			AS CustomerACID
			,CAse When A.CustomerId	IS NULL THEN N.CustomerName Else A.CustomerName	ENd		AS CustomerName
			,CASE WHEN (ISNULL(N.WriteOffFlag,'N')='Y' or n.AC_AssetClassAlt_Key=7 ) THEN N.AC_AssetClassAlt_Key  ELSE  B.AssetClassAlt_Key END AS AssetClassAlt_Key
			---,B.AssetClassAlt_Key	AS AssetClassAlt_Key
			--,A.MOC_NPADate
			--,CASE WHEN ISNULL(S.MOC_NPADate,'') ='' THEN NULL ELSE CONVERT(DATE,S.MOC_NPADate,103) END AS MOC_NPADate -- Removed by SSK on 14/03/2023 to add write off condition
			,CASE WHEN (ISNULL(N.WriteOffFlag,'N')='Y' or N.AC_AssetClassAlt_Key=7 ) 
				  THEN N.AC_NPA_Date 
				  ELSE
					CASE WHEN ISNULL(S.MOC_NPADate,'') ='' 
					THEN NULL 
					ELSE CONVERT(DATE,S.MOC_NPADate,103) 
				  END 
			 END AS MOC_NPADate -- Changed by SSK on 14/03/2023 to add write off condition. For Write off records, Npa date will be maintained
			,Case When A.AdditionalProvisionPercentage='' Then CAST(NULL AS DECIMAL(6,2)) Else Convert(decimal(6,2),A.AdditionalProvisionPercentage) END AdditionalProvisionPercentage
			,R.MocReasonAlt_Key	AS MocReasonAlt_Key
			,A.MOC_Type			AS MOC_Type
			,A.Remark			AS Remark
			--,A.MOC_Source
			--,NULL
			,'NP' AuthorisationStatus	
			,@Timekey EffectiveFromTimeKey
			,@TimeKey EffectiveToTimeKey	
			,@UserLoginID CreatedBy
			,GETDATE() AS DateCreated

			,CASE WHEN A.CustomerId IS NOT NULL THEN 'Y' ELSE 'N' END AS IsUpload
			 
		--FROM CustMOCUpload_stg A
		--LEFT JOIN NPA_IntegrationDetails N on N.CustomerId=A.CustomerId
		--              and EffectiveFromTimeKey<=@Timekey and EffectiveToTimeKey>=@Timekey
		FROM #Npa_IntegrationDetails N 
		Inner Join #StageTEMP S ON N.Ncif_Id=S.Ncif_ID
				LEft JOin CustMOCUpload_stg A on N.CustomerId=A.CustomerId 
				and n.ncif_id=a.ncif_id
		                             and A.filname=@FilePathUpload 
		             -- and EffectiveFromTimeKey<=@Timekey and EffectiveToTimeKey>=@Timekey

		LEFT JOIN DimAssetClass B ON B.AssetClassShortName = S.MOC_AssetClassification
		LEFT JOIN DimAssetClass E ON E.AssetClassAlt_Key = N.AC_AssetClassAlt_Key
		LEFT JOIN DimMocReason  R ON R.MocReasonName= A.MOC_Reason
		where n.EffectiveFromTimeKey<=@Timekey and n.EffectiveToTimeKey>=@Timekey
		ORDER BY CAST(A.SrNo AS INT)

		--)D WHERE D.Rownumber=1

		/* Commented on 23092021
		----MAIN TABLE UPDATE
		IF EXISTS (SELECT 1 FROM NPA_IntegrationDetails A
			INNER JOIN  CustMOCUpload_stg B
				ON A.CustomerId=B.CustomerId
			WHERE (A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey)
			)
			BEGIN
				UPDATE A
					SET A.AuthorisationStatus='MP'
				 FROM NPA_IntegrationDetails A
			INNER JOIN  CustMOCUpload_stg B
				ON A.CustomerId=B.CustomerId
			WHERE (A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey)

			END 
*/
------------------------------------------
	INSERT INTO ExcelUploadHistory
	(
		UniqueUploadID,
		UploadedBy	
		,DateofUpload	
		,AuthorisationStatus	
		--,Action	
		,UploadType
		,EffectiveFromTimeKey	
		,EffectiveToTimeKey	
		,CreatedBy	
		,DateCreated	
		,AsOnDate					-------- New Column Added By Satwaji as on 02/09/2021
		
	)

	SELECT 
			@ExcelUploadId
			,@UserLoginID
		   ,GETDATE()
		   ,'NP'
		   --,'NP'
		   ,'Customer MOC Upload'
		   ,@EffectiveFromTimeKey
		   ,@EffectiveToTimeKey
		   ,@UserLoginID
		   ,GETDATE()
		   ,CONVERT(Date,@AsOnDate,103)


		   PRINT @@ROWCOUNT

		 --  DECLARE @ExcelUploadId INT
			--SET @ExcelUploadId=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)
		
			Insert into UploadStatus (FileNames,UploadedBy,UploadDateTime,UploadType)
		Values(@filepath,@UserLoginID ,GETDATE(),'Customer MOC Upload')

-------------------------------------------------------




		--Declare @SummaryId int
		--Set @SummaryId=IsNull((Select Max(SummaryId) from CustMOCSummary_Mod),0)

		--INSERT INTO CustMOCSummary_Stg
		--(
		--	UploadID
		--	,SummaryID
		--	,NCIF_Id
		--	,CustomerID
		--	,CustomerName
		--	,NoOfCounts
		--	--,TotalSecurityValue
		--)
		--SELECT
		--	@ExcelUploadId
		--	,@SummaryId+Row_Number() over(Order by NCIF_Id)
		--	,NCIF_Id
		--	,CustomerID
		--	,CustomerName
		--	--,sum(isnull (cast(BuyoutPartyLoanNo as Decimal(16,2)),0))
		--	,Count(1)
		--	--,sum(isnull(cast (MOC_SecurityValue as Decimal(16,2)),0))

		--	FROM CustMOCUpload_stg
		--where filname=@FilePathUpload
		--Group by NCIF_Id,CustomerID,CustomerName

		PRINT @@ROWCOUNT
		
		---DELETE FROM STAGING DATA
		 DELETE FROM CustMOCUpload_stg
		 WHERE filname=@FilePathUpload
		 
		 ----RETURN @ExcelUploadId

END
		   ----DECLARE @UniqueUploadID INT
	--SET 	@UniqueUploadID=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)
	END

----------------------Two level Auth. Changes-------------

IF (@OperationFlag=16)	---- FIRST LEVEL(Checker1) AUTHORIZE
	BEGIN
		UPDATE NPA_IntegrationDetails_mod 
		SET 
			AuthorisationStatus	='1A'
			,ApprovedByFirstLevel	= @UserLoginID
			,DateApprovedFirstLevel	= GETDATE()
		WHERE UploadId=@UniqueUploadID

			--UPDATE 
			--CustMOCSummary_Mod 
			--SET 
			--AuthorisationStatus	='1A'
			--,ApprovedBy	=@UserLoginID
			--,DateApproved	=GETDATE()
			
			--WHERE UploadId=@UniqueUploadID

		UPDATE ExcelUploadHistory
		SET 
			AuthorisationStatus='1A'
		   ,ApprovedByFirstLevel	= @UserLoginID
		   ,DateApprovedFirstLevel	= GETDATE()
		WHERE UniqueUploadID=@UniqueUploadID
		AND UploadType='Customer MOC Upload'
	END

--------------------------------------------

	IF (@OperationFlag=20)	---- SECOND LEVEL(Checker2) AUTHORIZE

	BEGIN
		
		UPDATE 
			NPA_IntegrationDetails_mod 
			SET 
			AuthorisationStatus	='A'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID

			--UPDATE 
			--CustMOCSummary_Mod 
			--SET 
			--AuthorisationStatus	='A'
			--,ApprovedBy	=@UserLoginID
			--,DateApproved	=GETDATE()
			
			--WHERE UploadId=@UniqueUploadID

			DROP TABLE IF EXISTS #CUSTOMER_CAL

						SELECT A.* INTO #CUSTOMER_CAL FROM NPA_IntegrationDetails A
						INNER JOIN NPA_IntegrationDetails_mod B ON A.CustomerId=B.CustomerId 
						                           AND A.CustomerACID=B.CustomerACID
						WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey >=@TimeKey)
						AND (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey >=@TimeKey)
						AND B.UploadID=@UniqueUploadID
						AND B.AuthorisationStatus='A'

                       --Select AccountEntityID,* from #ACCOUNT_CAL
						UPDATE A
							SET A.EffectiveToTimeKey =@TimeKey -1,
							A.AuthorisationStatus='A'
						FROM NPA_IntegrationDetails A
						INNER JOIN NPA_IntegrationDetails_mod B ON A.CustomerId=B.CustomerId AND A.CustomerACID=B.CustomerACID
						where (A.EffectiveFromTimeKey=@TimeKey AND A.EffectiveToTimeKey =@TimeKey)
						AND B.UploadID=@UniqueUploadID
						AND B.AuthorisationStatus='A'
						--AND (B.EffectiveFromTimeKey=@TimeKey AND B.EffectiveToTimeKey =@TimeKey)
							--where (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey >=@TimeKey)
							--AND A.EffectiveFromTimeKey<@TImeKey

			--UPDATE A set
			--	--SELECT			

			--A.MOC_AssetClassAlt_Key=CASE WHEN B.MOC_AssetClassAlt_Key IS NULL THEN A.MOC_AssetClassAlt_Key ELSE  B.MOC_AssetClassAlt_Key  END
			--,A.MOC_NPA_Date =CASE WHEN B.MOC_NPA_Date IS NULL THEN A.MOC_NPA_Date ELSE B.MOC_NPA_Date END				
			--,A.AddlProvisionPer =CASE WHEN B.AddlProvisionPer IS NULL THEN A.AddlProvisionPer ELSE  B.AddlProvisionPer END			
			--,A.MOC_ReasonAlt_Key	=CASE WHEN B.MOC_ReasonAlt_Key IS NULL THEN	A.MOC_ReasonAlt_Key	ELSE  B.MOC_ReasonAlt_Key END
			--,A.MOC_Remark=CASE WHEN B.MOC_Remark IS NULL THEN A.Moc_Remark ELSE	 B.Moc_Remark END			
			--,A.MOCTYPE=CASE WHEN B.MOCTYPE	 IS NULL THEN	A.MOCTYPE	ELSE B.MOCTYPE	END	
			----,A.MOC_Status=CASE WHEN B.MOC_Status IS NULL THEN A.MOC_Status ELSE	 B.MOC_Status END
			----,A.MOC_Date=CASE WHEN B.MOC_Date IS NULL THEN A.MOC_Date ELSE	 B.MOC_Date END
			----,A.UploadFlag=CASE WHEN B.UploadFlag IS NULL THEN A.UploadFlag ELSE	 B.UploadFlag END
			--,A.MOC_Date= getdate()
			--,A.moc_status ='Y'
			
			--					--,A.=@ScreenFlag						
			--					--,A.=@MOCSource							
			--					--A.moc ='Y'
			--					--,A.ScreenFlag='U'
			--					--,A.ChangeField=B.ChangeField
			--				FROM NPA_IntegrationDetails a
			--				INNER JOIN NPA_IntegrationDetails_mod B ON A.CustomerID=B.CustomerId
			--					where A.EffectiveFromTimeKey=@TimeKey and A.EffectiveToTimeKey=@TimeKey

			INSERT INTO dbo.NPA_IntegrationDetails
			(
				 NCIF_Id
				,NCIF_Changed
				,SrcSysAlt_Key
				,NCIF_EntityID
				,CustomerId
				,CustomerName
				,PAN
				,NCIF_AssetClassAlt_Key
				,NCIF_NPA_Date
				,AccountEntityID
				,CustomerACID
				,SanctionedLimit
				,DrawingPower
				,PrincipleOutstanding
				,Balance
				,Overdue
				,DPD_Overdue_Loans
				,DPD_Interest_Not_Serviced
				,DPD_Overdrawn
				,DPD_Renewals
				,MaxDPD
				,WriteOffFlag
				,Segment
				,SubSegment
				,ProductCode
				,ProductDesc
				,Settlement_Status
				,AC_AssetClassAlt_Key
				,AC_NPA_Date
				,AstClsChngByUser
				,AstClsChngDate
				,AstClsChngRemark
				,MOC_Status
				,MOC_Date
				,MOC_ReasonAlt_Key
				,MOC_AssetClassAlt_Key
				,MOC_NPA_Date
				,AuthorisationStatus
				,EffectiveFromTimeKey
				,EffectiveToTimeKey
				,CreatedBy
				,DateCreated
				,ModifiedBy
				,DateModified
				,ApprovedBy
				,DateApproved
				,MOC_Remark
				,ProductType
				,ActualOutStanding
				,MaxDPD_Type
				,ProductAlt_Key
				,AstClsAppRemark
				,MocAppRemark
				,PNPA_Status
				,PNPA_ReasonAlt_Key
				,PNPA_Date
				,ActualPrincipleOutstanding
				,UNSERVED_INTEREST
				,CUSTOMER_IDENTIFIER
				,ACCOUNT_LEVEL_CODE
				,NF_PNPA_Date
				,Remark
				,WriteOffDate
				,DbtDT
				,ErosionDT
				,FlgErosion
				,IntOverdue
				,IntAccrued
				,OtherOverdue
				,PrincOverdue
				,IsRestructured
				,IsOTS
				,IsTWO
				,IsARC_Sale
				,IsFraud
				,IsWiful
				,IsNonCooperative
				,IsSuitFiled
				,IsRFA
				,IsFITL
				,IsCentral_GovGty
				,Is_Oth_GovGty
				,BranchCode
				,FacilityType
				,SancDate
				,Region
				,State
				,Zone
				,NPA_TagDate
				,PS_NPS
				,Retail_Corpo
				,Area
				,FraudAmt
				,FraudDate
				,GovtGtyAmt
				,GtyRepudiated
				,RepudiationDate
				,OTS_Amt
				,WriteOffAmount
				,ARC_SaleDate
				,ARC_SaleAmt
				,PrincOverdueSinceDt
				,IntNotServicedDt
				,ContiExcessDt
				,ReviewDueDt
				,OtherOverdueSinceDt
				,IntOverdueSinceDt
				,SecuredFlag
				,StkStmtDate
				,SecurityValue
				,DFVAmt
				,CoverGovGur
				,CreditsinceDt
				,DegReason
				,NetBalance
				,ApprRV
				,SecuredAmt
				,UnSecuredAmt
				,ProvDFV
				,Provsecured
				,ProvUnsecured
				,ProvCoverGovGur
				,AddlProvision
				,TotalProvision
				,BankProvsecured
				,BankProvUnsecured
				,BankTotalProvision
				,RBIProvsecured
				,RBIProvUnsecured
				,RBITotalProvision
				,SMA_Dt
				,UpgDate
				,ProvisionAlt_Key
				,PNPA_Reason
				,SMA_Class
				,SMA_Reason
				,CommonMocTypeAlt_Key
				,FlgDeg
				,FlgSMA
				,FlgPNPA
				,FlgUpg
				,FlgFITL
				,FlgAbinitio
				,NPA_Days
				,AppGovGur
				,UsedRV
				,ComputedClaim
				,NPA_Reason
				,PnpaAssetClassAlt_key
				,SecApp
				,ProvPerSecured
				,ProvPerUnSecured
				,AddlProvisionPer
				,FlgINFRA
				,MOCTYPE
				,DPD_IntService
				,DPD_StockStmt
				,DPD_FinMaxType
				,DPD_PrincOverdue
				,DPD_OtherOverdueSince
				,IsPUI
				,AC_Closed_Date
				,SECTOR
				,ACMOC_ReasonAlt_Key
				,FlgMOC

				,FlgProcessing
				,IsFunded
				,UploadID -- Added by SSK on 14032023 to store MOC Upload ID
			)

			SELECT
				A.NCIF_Id
				,A.NCIF_Changed
				,A.SrcSysAlt_Key
				,A.NCIF_EntityID
				,A.CustomerId
				,A.CustomerName
				,A.PAN
				--,A.NCIF_AssetClassAlt_Key
				,CASE WHEN B.MOC_AssetClassAlt_Key<>7 then B.MOC_AssetClassAlt_Key ELSE A.NCIF_AssetClassAlt_Key end AS NCIF_AssetClassAlt_Key
				 --,CASE WHEN B.MOC_AssetClassAlt_Key<>7 then B.MOC_AssetClassAlt_Key ELSE A.NCIF_AssetClassAlt_Key end AS NCIF_AssetClassAlt_Key
				--,A.NCIF_NPA_Date
				--,CASE WHEN B.MOC_AssetClassAlt_Key<>7 then B.MOC_NPA_Date ELSE A.NCIF_NPA_Date end AS NCIF_NPA_Date,
				,B.MOC_NPA_Date AS NCIF_NPA_Date /* added by ssk as on date 04052023 moc npa date as ncif npa date */
				,A.AccountEntityID
				,A.CustomerACID
				,A.SanctionedLimit
				,A.DrawingPower
				,A.PrincipleOutstanding
				,A.Balance
				,A.Overdue
				,A.DPD_Overdue_Loans
				,A.DPD_Interest_Not_Serviced
				,A.DPD_Overdrawn
				,A.DPD_Renewals
				,A.MaxDPD
				,A.WriteOffFlag
				,A.Segment
				,A.SubSegment
				,A.ProductCode
				,A.ProductDesc
				,A.Settlement_Status
				,A.AC_AssetClassAlt_Key
				,A.AC_NPA_Date
				,A.AstClsChngByUser
				,A.AstClsChngDate
				,A.AstClsChngRemark
				,'Y' AS MOC_Status				--CASE WHEN B.MOC_Status IS NULL THEN A.MOC_Status ELSE B.MOC_Status END AS MOC_Status
				,GETDATE() AS MOC_Date		--CASE WHEN B.MOC_Date IS NULL THEN A.MOC_Date ELSE B.MOC_Date END AS MOC_Date
				,CASE WHEN B.MOC_ReasonAlt_Key IS NULL THEN	A.MOC_ReasonAlt_Key	ELSE      B.MOC_ReasonAlt_Key END AS MOC_ReasonAlt_Key
				,CASE WHEN B.MOC_AssetClassAlt_Key IS NULL THEN A.MOC_AssetClassAlt_Key ELSE B.MOC_AssetClassAlt_Key END AS MOC_AssetClassAlt_Key
				,CASE WHEN B.MOC_NPA_Date IS NULL THEN A.MOC_NPA_Date ELSE B.MOC_NPA_Date END AS MOC_NPA_Date
				,B.AuthorisationStatus
				,@TimeKey
				,@TimeKey
				,B.CreatedBy
				,B.DateCreated
				,B.ModifiedBy
				,B.DateModified
				,B.ApprovedBy
				,B.DateApproved
				,CASE WHEN B.MOC_Remark IS NULL THEN	A.MOC_Remark	ELSE      B.MOC_Remark END AS MOC_Remark
				,A.ProductType
				,A.ActualOutStanding
				,A.MaxDPD_Type
				,A.ProductAlt_Key
				,A.AstClsAppRemark
				,A.MocAppRemark
				,A.PNPA_Status
				,A.PNPA_ReasonAlt_Key
				,A.PNPA_Date
				,A.ActualPrincipleOutstanding
				,A.UNSERVED_INTEREST
				,A.CUSTOMER_IDENTIFIER
				,A.ACCOUNT_LEVEL_CODE
				,A.NF_PNPA_Date
				,A.Remark
				,A.WriteOffDate
				,A.DbtDT
				,A.ErosionDT
				,A.FlgErosion
				,A.IntOverdue
				,A.IntAccrued
				,A.OtherOverdue
				,A.PrincOverdue
				,A.IsRestructured
				,A.IsOTS
				,A.IsTWO
				,A.IsARC_Sale
				,A.IsFraud
				,A.IsWiful
				,A.IsNonCooperative
				,A.IsSuitFiled
				,A.IsRFA
				,A.IsFITL
				,A.IsCentral_GovGty
				,A.Is_Oth_GovGty
				,A.BranchCode
				,A.FacilityType
				,A.SancDate
				,A.Region
				,A.State
				,A.Zone
				,A.NPA_TagDate
				,A.PS_NPS
				,A.Retail_Corpo
				,A.Area
				,A.FraudAmt
				,A.FraudDate
				,A.GovtGtyAmt
				,A.GtyRepudiated
				,A.RepudiationDate
				,A.OTS_Amt
				,A.WriteOffAmount
				,A.ARC_SaleDate
				,A.ARC_SaleAmt
				,A.PrincOverdueSinceDt
				,A.IntNotServicedDt
				,A.ContiExcessDt
				,A.ReviewDueDt
				,A.OtherOverdueSinceDt
				,A.IntOverdueSinceDt
				,A.SecuredFlag
				,A.StkStmtDate
				,A.SecurityValue
				,A.DFVAmt
				,A.CoverGovGur
				,A.CreditsinceDt
				,A.DegReason
				,A.NetBalance
				,A.ApprRV
				,A.SecuredAmt
				,A.UnSecuredAmt
				,A.ProvDFV
				,A.Provsecured
				,A.ProvUnsecured
				,A.ProvCoverGovGur
				,A.AddlProvision
				,A.TotalProvision
				,A.BankProvsecured
				,A.BankProvUnsecured
				,A.BankTotalProvision
				,A.RBIProvsecured
				,A.RBIProvUnsecured
				,A.RBITotalProvision
				,A.SMA_Dt
				,A.UpgDate
				,A.ProvisionAlt_Key
				,A.PNPA_Reason
				,A.SMA_Class
				,A.SMA_Reason
				,A.CommonMocTypeAlt_Key
				,A.FlgDeg
				,A.FlgSMA
				,A.FlgPNPA
				,A.FlgUpg
				,A.FlgFITL
				,A.FlgAbinitio
				,A.NPA_Days
				,A.AppGovGur
				,A.UsedRV
				,A.ComputedClaim
				,A.NPA_Reason
				,A.PnpaAssetClassAlt_key
				,A.SecApp
				,A.ProvPerSecured
				,A.ProvPerUnSecured
				,CASE WHEN (B.AddlProvisionPer IS NULL) THEN	A.AddlProvisionPer	ELSE      B.AddlProvisionPer END AS AddlProvisionPer
				,A.FlgINFRA
				,CASE WHEN B.MOCTYPE IS NULL THEN	A.MOCTYPE	ELSE      B.MOCTYPE END AS MOCTYPE
				,A.DPD_IntService
				,A.DPD_StockStmt
				,A.DPD_FinMaxType
				,A.DPD_PrincOverdue
				,A.DPD_OtherOverdueSince
				,A.IsPUI
				,A.AC_Closed_Date
				,A.SECTOR
				,A.ACMOC_ReasonAlt_Key
				,'Y' AS FlgMOC

				,'Y'
				,A.IsFunded
				,B.UploadID  -- Added by SSK on 14032023 to store Upload ID of MOC
				from #CUSTOMER_CAL A
				INNER JOIN dbo.NPA_IntegrationDetails_mod B ON A.NCIF_Id=B.NCIF_Id------A.CustomerId=B.CustomerId 
				                                           AND A.CustomerACID=B.CustomerACID --(COMMENTED BY SATWAJI as on 29/09/2021)
				where (B.EffectiveFromTimeKey=@TimeKey and B.EffectiveToTimeKey =@TimeKey)
				AND B.UploadID=@UniqueUploadID
				AND B.AuthorisationStatus='A'
				--AND B.EntityKey IN(
				--					SELECT CustomerId,MAX(EntityKey) FROM dbo.NPA_IntegrationDetails_mod 
				--					WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
				--					AND ISNULL(AuthorisationStatus,'A') = 'A'
				--					GROUP BY CustomerId
				--				)

								--SELECT CustomerId,MAX(EntityKey) FROM dbo.NPA_IntegrationDetails_mod 
								--	WHERE EffectiveFromTimeKey<=26084 AND EffectiveToTimeKey>=26084
								--	AND ISNULL(AuthorisationStatus,'A') = 'A' 
								--	AND CustomerId='32096610'
								--	GROUP BY CustomerId

			----- INSERT INTO PREMOC TABLE
			INSERT INTO PREMOC.NPA_IntegrationDetails
			(
					 NCIF_Id
					,NCIF_Changed
					,SrcSysAlt_Key
					,NCIF_EntityID
					,CustomerId
					,CustomerName
					,PAN
					,NCIF_AssetClassAlt_Key
					,NCIF_NPA_Date
					,AccountEntityID
					,CustomerACID
					,SanctionedLimit
					,DrawingPower
					,PrincipleOutstanding
					,Balance
					,Overdue
					,DPD_Overdue_Loans
					,DPD_Interest_Not_Serviced
					,DPD_Overdrawn
					,DPD_Renewals
					,MaxDPD
					,WriteOffFlag
					,Segment
					,SubSegment
					,ProductCode
					,ProductDesc
					,Settlement_Status
					,AC_AssetClassAlt_Key
					,AC_NPA_Date
					,AstClsChngByUser
					,AstClsChngDate
					,AstClsChngRemark
					,MOC_Status
					,MOC_Date
					,MOC_ReasonAlt_Key
					,MOC_AssetClassAlt_Key
					,MOC_NPA_Date
					,AuthorisationStatus
					,EffectiveFromTimeKey
					,EffectiveToTimeKey
					,CreatedBy
					,DateCreated
					,ModifiedBy
					,DateModified
					,ApprovedBy
					,DateApproved
					,MOC_Remark
					,ProductType
					,ActualOutStanding
					,MaxDPD_Type
					,ProductAlt_Key
					,AstClsAppRemark
					,MocAppRemark
					,PNPA_Status
					,PNPA_ReasonAlt_Key
					,PNPA_Date
					,ActualPrincipleOutstanding
					,UNSERVED_INTEREST
					,CUSTOMER_IDENTIFIER
					,ACCOUNT_LEVEL_CODE
					,NF_PNPA_Date
					,Remark
					,WriteOffDate
					,DbtDT
					,ErosionDT
					,FlgErosion
					,IntOverdue
					,IntAccrued
					,OtherOverdue
					,PrincOverdue
					,IsRestructured
					,IsOTS
					,IsTWO
					,IsARC_Sale
					,IsFraud
					,IsWiful
					,IsNonCooperative
					,IsSuitFiled
					,IsRFA
					,IsFITL
					,IsCentral_GovGty
					,Is_Oth_GovGty
					,BranchCode
					,FacilityType
					,SancDate
					,Region
					,State
					,Zone
					,NPA_TagDate
					,PS_NPS
					,Retail_Corpo
					,Area
					,FraudAmt
					,FraudDate
					,GovtGtyAmt
					,GtyRepudiated
					,RepudiationDate
					,OTS_Amt
					,WriteOffAmount
					,ARC_SaleDate
					,ARC_SaleAmt
					,PrincOverdueSinceDt
					,IntNotServicedDt
					,ContiExcessDt
					,ReviewDueDt
					,OtherOverdueSinceDt
					,IntOverdueSinceDt
					,SecuredFlag
					,StkStmtDate
					,SecurityValue
					,DFVAmt
					,CoverGovGur
					,CreditsinceDt
					,DegReason
					,NetBalance
					,ApprRV
					,SecuredAmt
					,UnSecuredAmt
					,ProvDFV
					,Provsecured
					,ProvUnsecured
					,ProvCoverGovGur
					,AddlProvision
					,TotalProvision
					,BankProvsecured
					,BankProvUnsecured
					,BankTotalProvision
					,RBIProvsecured
					,RBIProvUnsecured
					,RBITotalProvision
					,SMA_Dt
					,UpgDate
					,ProvisionAlt_Key
					,PNPA_Reason
					,SMA_Class
					,SMA_Reason
					,CommonMocTypeAlt_Key
					,FlgDeg
					,FlgSMA
					,FlgPNPA
					,FlgUpg
					,FlgFITL
					,FlgAbinitio
					,NPA_Days
					,AppGovGur
					,UsedRV
					,ComputedClaim
					,NPA_Reason
					,PnpaAssetClassAlt_key
					,SecApp
					,ProvPerSecured
					,ProvPerUnSecured
					,AddlProvisionPer
					,FlgINFRA
					,MOCTYPE
					,DPD_IntService
					,DPD_StockStmt
					,DPD_FinMaxType
					,DPD_PrincOverdue
					,DPD_OtherOverdueSince
					,IsPUI
					,AC_Closed_Date
					,SECTOR
					,ACMOC_ReasonAlt_Key
					,FlgMOC

					,IsFunded
					, UploadID -- Added by SSK on 14032023
			)

			SELECT
					 A.NCIF_Id
					,A.NCIF_Changed
					,A.SrcSysAlt_Key
					,A.NCIF_EntityID
					,A.CustomerId
					,A.CustomerName
					,A.PAN
					,A.NCIF_AssetClassAlt_Key
					,A.NCIF_NPA_Date
					,A.AccountEntityID
					,A.CustomerACID
					,A.SanctionedLimit
					,A.DrawingPower
					,A.PrincipleOutstanding
					,A.Balance
					,A.Overdue
					,A.DPD_Overdue_Loans
					,A.DPD_Interest_Not_Serviced
					,A.DPD_Overdrawn
					,A.DPD_Renewals
					,A.MaxDPD
					,A.WriteOffFlag
					,A.Segment
					,A.SubSegment
					,A.ProductCode
					,A.ProductDesc
					,A.Settlement_Status
					,A.AC_AssetClassAlt_Key
					,A.AC_NPA_Date
					,A.AstClsChngByUser
					,A.AstClsChngDate
					,A.AstClsChngRemark
					,A.MOC_Status
					,A.MOC_Date
					,A.MOC_ReasonAlt_Key
					,A.MOC_AssetClassAlt_Key
					,A.MOC_NPA_Date
					,A.AuthorisationStatus
					,@TimeKey
					,@TimeKey
					,A.CreatedBy
					,A.DateCreated
					,A.ModifiedBy
					,A.DateModified
					,A.ApprovedBy
					,A.DateApproved
					,A.MOC_Remark
					,A.ProductType
					,A.ActualOutStanding
					,A.MaxDPD_Type
					,A.ProductAlt_Key
					,A.AstClsAppRemark
					,A.MocAppRemark
					,A.PNPA_Status
					,A.PNPA_ReasonAlt_Key
					,A.PNPA_Date
					,A.ActualPrincipleOutstanding
					,A.UNSERVED_INTEREST
					,A.CUSTOMER_IDENTIFIER
					,A.ACCOUNT_LEVEL_CODE
					,A.NF_PNPA_Date
					,A.Remark
					,A.WriteOffDate
					,A.DbtDT
					,A.ErosionDT
					,A.FlgErosion
					,A.IntOverdue
					,A.IntAccrued
					,A.OtherOverdue
					,A.PrincOverdue
					,A.IsRestructured
					,A.IsOTS
					,A.IsTWO
					,A.IsARC_Sale
					,A.IsFraud
					,A.IsWiful
					,A.IsNonCooperative
					,A.IsSuitFiled
					,A.IsRFA
					,A.IsFITL
					,A.IsCentral_GovGty
					,A.Is_Oth_GovGty
					,A.BranchCode
					,A.FacilityType
					,A.SancDate
					,A.Region
					,A.State
					,A.Zone
					,A.NPA_TagDate
					,A.PS_NPS
					,A.Retail_Corpo
					,A.Area
					,A.FraudAmt
					,A.FraudDate
					,A.GovtGtyAmt
					,A.GtyRepudiated
					,A.RepudiationDate
					,A.OTS_Amt
					,A.WriteOffAmount
					,A.ARC_SaleDate
					,A.ARC_SaleAmt
					,A.PrincOverdueSinceDt
					,A.IntNotServicedDt
					,A.ContiExcessDt
					,A.ReviewDueDt
					,A.OtherOverdueSinceDt
					,A.IntOverdueSinceDt
					,A.SecuredFlag
					,A.StkStmtDate
					,A.SecurityValue
					,A.DFVAmt
					,A.CoverGovGur
					,A.CreditsinceDt
					,A.DegReason
					,A.NetBalance
					,A.ApprRV
					,A.SecuredAmt
					,A.UnSecuredAmt
					,A.ProvDFV
					,A.Provsecured
					,A.ProvUnsecured
					,A.ProvCoverGovGur
					,A.AddlProvision
					,A.TotalProvision
					,A.BankProvsecured
					,A.BankProvUnsecured
					,A.BankTotalProvision
					,A.RBIProvsecured
					,A.RBIProvUnsecured
					,A.RBITotalProvision
					,A.SMA_Dt
					,A.UpgDate
					,A.ProvisionAlt_Key
					,A.PNPA_Reason
					,A.SMA_Class
					,A.SMA_Reason
					,A.CommonMocTypeAlt_Key
					,A.FlgDeg
					,A.FlgSMA
					,A.FlgPNPA
					,A.FlgUpg
					,A.FlgFITL
					,A.FlgAbinitio
					,A.NPA_Days
					,A.AppGovGur
					,A.UsedRV
					,A.ComputedClaim
					,A.NPA_Reason
					,A.PnpaAssetClassAlt_key
					,A.SecApp
					,A.ProvPerSecured
					,A.ProvPerUnSecured
					,A.AddlProvisionPer
					,A.FlgINFRA
					,A.MOCTYPE
					,A.DPD_IntService
					,A.DPD_StockStmt
					,A.DPD_FinMaxType
					,A.DPD_PrincOverdue
					,A.DPD_OtherOverdueSince
					,A.IsPUI
					,A.AC_Closed_Date
					,A.SECTOR
					,A.ACMOC_ReasonAlt_Key
					,'Y' as FlgMoc

					,A.IsFunded
					, c.UploadID	-- Added by ssk on 14032023
			from #CUSTOMER_CAL A
							INNER JOIN NPA_IntegrationDetails_mod C ON A.NCIF_Id=C.NCIF_Id AND A.CustomerACID=C.CustomerACID
								LEFT JOIN premoc.NPA_IntegrationDetails B
									ON (B.EffectiveFromTimeKey=@TimeKey AND B.EffectiveToTimeKey=@TimeKey) 
									AND A.NCIF_Id=B.NCIF_Id AND A.CustomerACID=B.CustomerACID
								WHERE  (c.EffectiveFromTimeKey<=@TimeKey AND c.EffectiveToTimeKey> =@TimeKey)
								AND C.UploadID=@UniqueUploadID
								AND C.AuthorisationStatus='A'
								AND  B.CustomerId is null
								--AND B.CustomerACID IS NULL

			--INSERT INTO CustMOCSummary
			--(
			--	SummaryID
			--	,NCIF_Id
			--	,CustomerName
			--	,CustomerID
			--	,NoOfCounts
			--	,TotalSecurityValue
			--	,AuthorisationStatus
			--	,EffectiveFromTimeKey
			--	,EffectiveToTimeKey
			--	,CreatedBy
			--	,DateCreated
			--	,ModifyBy
			--	,DateModified
			--	,ApprovedBy
			--	,DateApproved
			--)
			--SELECT 
			--	SummaryID
			--	,NCIF_Id
			--	,CustomerName
			--	,CustomerID
			--	,NoOfCounts
			--	,TotalSecurityValue
			--	,AuthorisationStatus
			--	,@Timekey
			--	,49999
			--	,CreatedBy
			--	,DateCreated
			--	,ModifyBy
			--	,DateModified
			--	,@UserLoginID
			--	,Getdate()
			--FROM CustMOCSummary_Mod
			--WHERE  UploadId=@UniqueUploadID and EffectiveToTimeKey>=@Timekey

			-----Summary Final -----------

			--Insert into CustMOCFinalSummary
			--(
			--		UploadID
			--		,SummaryID
			--		,NCIF_Id
			--		,CustomerName
			--		,CustomerID
			--		,NoOfCounts
			--		,TotalSecurityValue
			--		,AuthorisationStatus
			--		,EffectiveFromTimeKey
			--		,EffectiveToTimeKey
			--		,CreatedBy
			--		,DateCreated
			--		,ModifyBy
			--		,DateModified
			--		,ApprovedBy
			--		,DateApproved
			--)
			--SELECT 
			--		UploadID
			--		,SummaryID
			--		,NCIF_Id
			--		,CustomerName
			--		,CustomerID
			--		,NoOfCounts
			--		,TotalSecurityValue
			--		,AuthorisationStatus
			--		,@Timekey
			--		,49999
			--		,CreatedBy
			--		,DateCreated
			--		,ModifyBy
			--		,DateModified
			--		,@UserLoginID
			--		,Getdate()
			--		FROM CustMOCSummary_Mod A
			--WHERE  A.UploadId=@UniqueUploadID and EffectiveToTimeKey>=@Timekey

---------------------------------------------
/*--------------------Adding Flag To AdvAcOtherDetail------------Pranay 21-03-2021--------*/ 

 -- UPDATE A
	--SET  
 --       A.SplFlag=CASE WHEN ISNULL(A.SplFlag,'')='' THEN 'Buyout'     
	--					ELSE A.SplFlag+','+'Buyout'     END
		   
 --  FROM DBO.AdvAcOtherDetail A
 --  --INNER JOIN #Temp V  ON A.AccountEntityId=V.AccountEntityId
 -- INNER JOIN BuyoutDetails_Mod B ON A.RefSystemAcId=B.BuyoutPartyLoanNo
	--		WHERE  B.UploadId=@UniqueUploadID and B.EffectiveToTimeKey>=@Timekey
	--		AND A.EffectiveToTimeKey=49999



			--UPDATE A
			--SET 
			--A.MOC_SecurityValue=ROUND(B.MOC_SecurityValue,2)
			--,a.ModifyBy=@UserLoginID
			--,a.DateModified=GETDATE()
			--FROM CustMOCDetails A
			--INNER JOIN CustMOCDetails_Mod B ON (A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey)
			--													AND  (B.EffectiveFromTimeKey<=@Timekey AND B.EffectiveToTimeKey>=@Timekey)	
			--													AND A.NCIF_ID=B.NCIF_ID

				--WHERE B.AuthorisationStatus='A'
				--AND B.UploadId=@UniqueUploadID

				Update  A
				Set A.EffectiveToTimeKey=A.EffectiveFromTimeKey-1
				from  NPA_IntegrationDetails_Mod A
				WHERE UploadId=@UniqueUploadID

				UPDATE
				ExcelUploadHistory
				SET AuthorisationStatus='A',ApprovedBy=@UserLoginID,DateApproved=GETDATE()
				WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
				AND UniqueUploadID=@UniqueUploadID
				AND UploadType='Customer MOC Upload'

				---- Expired The Record from CURDAT.AcceleratedProv Table Whose Asset Class is Upgraded i.e. Standard in NPA_IntegrationDetails Table After Successful Customer MOC Upload
				---- BY SATWAJI as on 03/02/2022
				UPDATE A SET
					A.EffectiveToTimeKey=@Timekey-1
				--SELECT * 
				FROM CURDAT.AcceleratedProv A
				INNER JOIN NPA_IntegrationDetails B
				ON A.CustomerACID=B.CustomerACID
				INNER JOIN NPA_IntegrationDetails_Mod C
				ON A.CustomerACID=C.CustomerACID
				AND C.EffectiveFromTimeKey=@Timekey
				AND (B.EffectiveFromTimeKey=@Timekey AND B.EffectiveToTimeKey=@Timekey)
				WHERE (A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey)
				AND B.AuthorisationStatus='A'
				AND B.MOC_AssetClassAlt_Key=1
				AND C.UploadId=@UniqueUploadID

	END

	IF (@OperationFlag=17)	---- FIRST LEVEL(Checker1) REJECT
	BEGIN
		UPDATE NPA_IntegrationDetails_mod 
		SET 
			AuthorisationStatus	='R'
			,ApprovedByFirstLevel	= @UserLoginID
			,DateApprovedFirstLevel	= GETDATE()
		WHERE UploadId=@UniqueUploadID
		AND AuthorisationStatus='NP'

			--UPDATE 
			--CustMOCSummary_Mod 
			--SET 
			--AuthorisationStatus	='R'
			--,ApprovedBy	=@UserLoginID
			--,DateApproved	=GETDATE()
			
			--WHERE UploadId=@UniqueUploadID
			--AND AuthorisationStatus='NP'
			----SELECT * FROM IBPCPoolDetail

			UPDATE ExcelUploadHistory
			SET 
				AuthorisationStatus='R'
				,ApprovedByFirstLevel	= @UserLoginID
				,DateApprovedFirstLevel	= GETDATE()
			WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
			AND UniqueUploadID=@UniqueUploadID
			AND UploadType='Customer MOC Upload'
	END
--------------------Two level Auth. Changes---------------

IF (@OperationFlag=21)----REJECT

	BEGIN
		
		UPDATE 
			NPA_IntegrationDetails_mod 
			SET 
			AuthorisationStatus	='R'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID
			AND AuthorisationStatus in ('NP','1A')

			--UPDATE 
			--CustMOCSummary_Mod 
			--SET 
			--AuthorisationStatus	='R'
			--,ApprovedBy	=@UserLoginID
			--,DateApproved	=GETDATE()
			
			--WHERE UploadId=@UniqueUploadID
			--AND AuthorisationStatus in ('NP','1A')
			----SELECT * FROM IBPCPoolDetail

			UPDATE
				ExcelUploadHistory
				SET AuthorisationStatus='R',ApprovedBy=@UserLoginID,DateApproved=GETDATE()
				WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
				AND UniqueUploadID=@UniqueUploadID
				AND UploadType='Customer MOC Upload'



	END
---------------------------------------------------------------------
END


	--COMMIT TRAN
		---SET @Result=CASE WHEN  @OperationFlag=1 THEN @UniqueUploadID ELSE 1 END
		SET @Result=CASE WHEN  @OperationFlag=1 AND @MenuId=97 THEN @ExcelUploadId 
					ELSE 1 END

		
		 Update UploadStatus Set InsertionOfData='Y',InsertionCompletedOn=GETDATE() where FileNames=@filepath

		 ---- IF EXISTS(SELECT 1 FROM IBPCPoolDetail_stg WHERE filEname=@FilePathUpload)
		 ----BEGIN
			----	 DELETE FROM IBPCPoolDetail_stg
			----	 WHERE filEname=@FilePathUpload

			----	 PRINT 'ROWS DELETED FROM IBPCPoolDetail_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
		 ----END
		 

		RETURN @Result
		------RETURN @UniqueUploadID
	END TRY
	BEGIN CATCH 
	   --ROLLBACK TRAN
	SELECT ERROR_MESSAGE(),ERROR_LINE()
	SET @Result=-1
	 Update UploadStatus Set InsertionOfData='Y',InsertionCompletedOn=GETDATE() where FileNames=@filepath
	RETURN -1
	END CATCH

END
GO