﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
 
CREATE PROCEDURE [dbo].[ProvisionComputation] (@TimeKey Smallint,@IS_MOC CHAR(1)='N')
WITH RECOMPILE
AS
DECLARE @Ext_DATE_1 DATE =(SELECT dateadd(dd,1,DATE) FROM SysDataMatrix WHERE TimeKey=@TimeKey)--APPLIED ON PROD 20231005 FOR BORDER DATE OBSERVATION
DECLARE @Ext_DATE DATE =(SELECT DATE FROM SysDataMatrix WHERE TimeKey=@TimeKey)
DECLARE @Prol Smallint=(SELECT SourceAlt_Key FROM DimSourceSystem WHERE SourceName='Prolendz' AND EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)
DECLARE @Fin Smallint=(SELECT SourceAlt_Key FROM DimSourceSystem WHERE SourceName='Finacle' AND EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)

DECLARE @STD_Alt_Key SMALLINT=(SELECT AssetClassAlt_Key FROM DimAssetClass WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey AND AssetClassShortName='STD')
DECLARE @SUB_Alt_Key SMALLINT=(SELECT AssetClassAlt_Key FROM DimAssetClass WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey AND AssetClassShortName='SUB')
DECLARE @LOSS_Alt_Key SMALLINT=(SELECT AssetClassAlt_Key FROM DimAssetClass WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey AND AssetClassShortName='LOS')
DECLARE @DB1_Alt_Key SMALLINT=(SELECT AssetClassAlt_Key FROM DimAssetClass WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey AND AssetClassShortName='DB1')
DECLARE @DB2_Alt_Key SMALLINT=(SELECT AssetClassAlt_Key FROM DimAssetClass WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey AND AssetClassShortName='DB2')
DECLARE @DB3_Alt_Key SMALLINT=(SELECT AssetClassAlt_Key FROM DimAssetClass WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey AND AssetClassShortName='DB3')
DECLARE @WRITEOFF_Alt_Key SMALLINT=(SELECT AssetClassAlt_Key FROM DimAssetClass WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey AND AssetClassShortName='WO')

DECLARE @STDGEN smallint=(SELECT ProvisionAlt_Key FROM DimProvision WHERE ProvisionShortName='STDGEN' and EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)
DECLARE @SUBGEN smallint=(SELECT ProvisionAlt_Key FROM DimProvision WHERE ProvisionShortName='SUBGEN' and EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)
DECLARE @SUBABINT smallint=(SELECT ProvisionAlt_Key FROM DimProvision WHERE ProvisionShortName='SUBABINT' and EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)
DECLARE @DB1GEN smallint=(SELECT ProvisionAlt_Key FROM DimProvision WHERE ProvisionShortName='DB1GEN' and EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)
DECLARE @DB1PROL smallint=(SELECT ProvisionAlt_Key FROM DimProvision WHERE ProvisionShortName='DB1PROL' and EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)
DECLARE @DB2GEN smallint=(SELECT ProvisionAlt_Key FROM DimProvision WHERE ProvisionShortName='DB2GEN' and EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)
DECLARE @DB2PROL smallint=(SELECT ProvisionAlt_Key FROM DimProvision WHERE ProvisionShortName='DB2PROL' and EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)
DECLARE @DB3 smallint=(SELECT ProvisionAlt_Key FROM DimProvision WHERE ProvisionShortName='DB3' and EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)
DECLARE @LOSS smallint=(SELECT ProvisionAlt_Key FROM DimProvision WHERE ProvisionShortName='LOSS' and EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)
DECLARE @FITL smallint=(SELECT ProvisionAlt_Key FROM DimProvision WHERE ProvisionShortName='FITL' and EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)
DECLARE @FINCAA smallint=(SELECT ProvisionAlt_Key FROM DimProvision WHERE ProvisionShortName='FINCAA' and EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)
DECLARE @FIN890 smallint=(SELECT ProvisionAlt_Key FROM DimProvision WHERE ProvisionShortName='FIN890' and EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)
DECLARE @DB1PROL_35 smallint=(SELECT ProvisionAlt_Key FROM DimProvision WHERE ProvisionShortName='DB1PROL_35' and EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)
DECLARE @SUBPROL_35 smallint=(SELECT ProvisionAlt_Key FROM DimProvision WHERE ProvisionShortName='SUBPROL_35' and EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)
DECLARE @DB1PROL_40 smallint=(SELECT ProvisionAlt_Key FROM DimProvision WHERE ProvisionShortName='DB1PROL_40' and EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)
DECLARE @DB1PROL_45 smallint=(SELECT ProvisionAlt_Key FROM DimProvision WHERE ProvisionShortName='DB1PROL_45' and EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)
DECLARE @DB2PROL_50 smallint=(SELECT ProvisionAlt_Key FROM DimProvision WHERE ProvisionShortName='DB2PROL_50' and EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)
DECLARE @DB2PROL_60 smallint=(SELECT ProvisionAlt_Key FROM DimProvision WHERE ProvisionShortName='DB2PROL_60' and EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)
DECLARE @DB2PROL_70 smallint=(SELECT ProvisionAlt_Key FROM DimProvision WHERE ProvisionShortName='DB2PROL_70' and EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)

BEGIN TRY

DELETE IBL_ENPA_STGDB.[dbo].[Procedure_Audit] 
WHERE [SP_Name]='ProvisionComputation' AND [EXT_DATE]=@Ext_DATE AND ISNULL([Audit_Flg],0)=0

INSERT INTO IBL_ENPA_STGDB.[dbo].[Procedure_Audit]
           ([EXT_DATE] ,[Timekey] ,[SP_Name],Start_Date_Time )
SELECT @Ext_DATE,@TimeKey,'ProvisionComputation',GETDATE()
BEGIN TRAN

IF OBJECT_ID('TEMPDB..#MOC') IS NOT NULL
DROP TABLE #MOC

CREATE TABLE #MOC(NCIF_Id VARCHAR(100))



IF(@IS_MOC='Y')
BEGIN

INSERT INTO #MOC(NCIF_Id)
SELECT DISTINCT NCIF_Id 
FROM NPA_IntegrationDetails
WHERE EffectiveFromTimeKey<=@TimeKey
AND EffectiveToTimeKey>=@TimeKey
AND ISNULL(FlgProcessing,'N')='Y'

-----------------Initialize provision columns for MOC Ncifs  18-07-2021

--Select 
Update A Set A.Provsecured =0
			,A.ProvUnsecured = 0
			,A.AddlProvision = (Case When B.CustomerACID Is NOT NUll then 0 else A.AddlProvision end)
			,A.ProvisionAlt_Key=NULL
			,A.TotalProvision = Null                   ---20231007
from NPA_IntegrationDetails A
Inner Join #MOC M ON A.NCIF_Id=M.NCIF_Id
---Left Join CURDAT.ACCELERATEDPROV B ON A.NCIF_Id=B.NCIF_Id And A.CustomerId=B.CustomerId And A.CustomerACID=B.CustomerACID
Left Join CURDAT.ACCELERATEDPROV B ON A.CustomerACID=B.CustomerACID--Chnage on 2/2/22
And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey 
AND ISNULL(FlgProcessing,'N')='Y' ----- Added by Liyaqat 20240730

----------

END

INSERT INTO HISTORY_PROVISIONPOLICY (
Source_System
,Source_Alt_Key
,Scheme_Code
--,Segment
,upto_3_months
,From_4_months_upto_6_months
,From_7_months_upto_9_months
,From_10_months_upto_12_months
,Doubtful_1
,Doubtful_2
,Doubtful_3
,Loss
,Effective_date
,AuthorisationStatus
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CreatedBy
,DateCreated
,ModifiedBy
,DateModified
,ApprovedBy
,DateApproved
,ApprovedByFirstLevel
,DateApprovedFirstLevel
,ProvisionAlt_key
,ProvisionUnSecured
,EXPIRED_DATE
) SELECT Source_System
,Source_Alt_Key
,Scheme_Code
--,Segment
,upto_3_months
,From_4_months_upto_6_months
,From_7_months_upto_9_months
,From_10_months_upto_12_months
,Doubtful_1
,Doubtful_2
,Doubtful_3
,Loss
,Effective_date
,AuthorisationStatus
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CreatedBy
,DateCreated
,ModifiedBy
,DateModified
,ApprovedBy
,DateApproved
,ApprovedByFirstLevel
,DateApprovedFirstLevel
,ProvisionAlt_key
,ProvisionUnSecured
,GETDATE()
 FROM DIMPROVISIONPOLICY 
	WHERE Scheme_Code NOT IN (SELECT Scheme_Code FROM HISTORY_PROVISIONPOLICY )
									AND EffectiveToTimeKey<@TIMEKEY--ADDED ON 20240327 BY ZAIN ON UAT


 DROP TABLE IF EXISTS #TempNPA_Int 
		SELECT NCIF_ID,CustomerId,CustomerACID,ProductCode,SrcSysAlt_Key,ProvisionAlt_Key,NCIF_AssetClassAlt_Key,NCIF_NPA_Date
		,AC_AssetClassAlt_Key,PrincipleOutstanding,Balance,SecuredFlag,FacilityType,IsFITL,
		Provsecured,ProvUnSecured,SecuredAmt,UNSecuredAmt,TotalProvision,AddlProvision,AddlProvisionPer
		,STD_ASSET_CAT_Alt_key,SEC_PROVPER_OLD,UNSEC_PROVPER_OLD,IsFunded,IsRestructured,IsTWO,FlgProcessing,
		EffectiveFromTimeKey,EffectiveToTimeKey into #TempNPA_Int from NPA_IntegrationDetails
		--WHERE EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey 
		WHERE EffectiveFromTimeKey=EffectiveToTimeKey 


UPDATE A SET   
ProvisionAlt_Key=(CASE WHEN IsFITL='Y' THEN @FITL
                       --WHEN SrcSysAlt_Key=@Fin AND ProductCode='CAA' THEN @FINCAA
					   WHEN SrcSysAlt_Key=@Fin AND FacilityType='CAA' THEN @FINCAA -----Changed 15-06-2021 by sunil
			           WHEN  SrcSysAlt_Key=@Fin AND NCIF_AssetClassAlt_Key<>@STD_Alt_Key AND ProductCode in ('OD890','OD896') THEN @FIN890 END)
	FROM #TempNPA_Int A --ADDED ON PROD 20230922
	LEFT JOIN #MOC B ON A.NCIF_Id=B.NCIF_ID --ADDED ON PROD 20230922
	WHERE  NCIF_AssetClassAlt_Key<>@STD_Alt_Key --ADDED ON PROD 20230922
	AND A.NCIF_ID =CASE WHEN @IS_MOC ='Y' THEN B.NCIF_ID ELSE  A.NCIF_ID END --ADDED ON PROD 20230922
PRINT 'EXCEPTIONAL PROVISIONAL CASES COMPLETED' --ADDED ON PROD 20230922

/*ADDED ON BY ZAIN 20230705 ADDED ON PROD 20230922 PROVISION CALCULATION*/
/* SCHEME_CODE IS NOT NULL */
UPDATE  NID SET NID.ProvisionAlt_Key = DPP.ProvisionAlt_key
FROM #TempNPA_Int NID  
INNER JOIN DIMPROVISIONPOLICY DPP ON DPP.Scheme_Code=NID.ProductCode
										AND DPP.Source_Alt_Key=NID.SrcSysAlt_Key
		--AND (DPP.SEGMENT IS NOT NULL) AND DPP.SCHEME_CODE IS NOT NULL ) CHANGED AS PER BANK REQUESTED 20230810 BY ZAIN
		 AND DPP.EffectiveFromTimeKey<=@TIMEKEY
                          AND DPP.EffectiveToTimeKey>=@TIMEKEY
		LEFT JOIN #MOC B ON NID.NCIF_Id=B.NCIF_ID
		WHERE  NID.NCIF_AssetClassAlt_Key<>@STD_ALT_KEY
		AND NID.NCIF_ID =CASE WHEN @IS_MOC ='Y' THEN B.NCIF_ID ELSE  NID.NCIF_ID END
		AND NID.ProvisionAlt_Key IS NULL
PRINT ' SCHEME_CODE IS NOT NULL '		
 
/* SCHEME_CODE IS  NULL *//*ADDED ON BY ZAIN 20230705 ADDED ON PROD 20230922 PROVISION CALCULATION*/
		UPDATE  NID SET NID.ProvisionAlt_Key = DPP.ProvisionAlt_key
		FROM #TempNPA_Int NID  
		INNER JOIN DIMPROVISIONPOLICY DPP ON DPP.Source_Alt_Key=NID.SrcSysAlt_Key
			AND (ISNULL(DPP.SCHEME_CODE,'')='')--ISNULL(DPP.SEGMENT,'')='' AND --CHANGED AS PER BANK REQUESTED 20230810 BY ZAIN
			 AND DPP.EffectiveFromTimeKey<=@TimeKey
			                  AND DPP.EffectiveToTimeKey>=@TimeKey
		LEFT JOIN #MOC B ON NID.NCIF_Id=B.NCIF_ID
		WHERE NID.NCIF_AssetClassAlt_Key<>@STD_Alt_Key
							AND NID.NCIF_ID =CASE WHEN @IS_MOC ='Y' THEN B.NCIF_ID ELSE  NID.NCIF_ID END
							AND NID.ProvisionAlt_Key IS NULL


/*ADDED ON BY ZAIN 20230831 ADDED ON PROD 20230922 PROVISION CALCULATION */
UPDATE A SET   
ProvisionAlt_Key=(CASE WHEN NCIF_AssetClassAlt_Key=@SUB_Alt_Key
			                THEN (CASE WHEN SrcSysAlt_Key=@Prol and ProductCode IN('D_R','E_R','L_R') THEN @SUBGEN--@SUBPROL_35 CHANGED ON 20230831 BY ZAIN
							           WHEN ISNULL(SecuredFlag,'N')='N' THEN @SUBABINT ELSE @SUBGEN END) 
                       WHEN NCIF_AssetClassAlt_Key=@DB1_Alt_Key
					   /*PROVISION FOR THIS PRODUCT CODEIS MOVE TO DIMPROVISIONPOLICY FROMDIMPROVISION COMMENTED ON UAT 20230728 ON PROD 20230922 BY ZAIN*/
		                    THEN (CASE   WHEN SrcSysAlt_Key=@Prol and ProductCode IN('D_R','E_R','L_R') THEN @DB1GEN--DB1PROL CHANGED ON 20230831 BY ZAIN 
									   ELSE @DB1GEN END)
						WHEN NCIF_AssetClassAlt_Key=@DB2_Alt_Key--ADDEDON 20230801
									THEN @DB2GEN --ADDEDON 20230801
						WHEN NCIF_AssetClassAlt_Key=@DB3_Alt_Key THEN @DB3
                       WHEN NCIF_AssetClassAlt_Key=@LOSS_Alt_Key
		                    THEN @LOSS
                 ELSE @STDGEN    
                 END)
FROM #TempNPA_Int A
LEFT JOIN #MOC B ON A.NCIF_Id=B.NCIF_ID
WHERE EffectiveFromTimeKey<=@TimeKey
AND EffectiveToTimeKey>=@TimeKey
AND NCIF_AssetClassAlt_Key<>@STD_Alt_Key
AND A.NCIF_ID =CASE WHEN @IS_MOC ='Y' THEN B.NCIF_ID ELSE  A.NCIF_ID END
AND isnull(A.ProvisionAlt_Key,'') =''--CHANGED ON UAT 20230831 ON PROD 20230922 AND ProvisionAlt_Key IS NULL
 
/*IMPLEMENTATION OF THE ADDED PARAMETER FOR BORDER DATE OBSERVATION ON PROD 20231005 */
UPDATE  NID SET
 Provsecured=(CASE WHEN NID.NCIF_AssetClassAlt_Key=@SUB_Alt_Key AND (SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))<=3  THEN ISNULL(SecuredAmt,0)*DPP.upto_3_months 
										WHEN NID.NCIF_AssetClassAlt_Key=@SUB_Alt_Key AND ((SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))>3 AND (SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))<=6) THEN ISNULL(SecuredAmt,0)*DPP.From_4_months_upto_6_months 
										WHEN NID.NCIF_AssetClassAlt_Key=@SUB_Alt_Key AND ((SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))>6 AND (SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))<=9)   THEN ISNULL(SecuredAmt,0)*DPP.From_7_months_upto_9_months
										WHEN NID.NCIF_AssetClassAlt_Key=@SUB_Alt_Key AND ((SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))>9 AND (SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))<=12) THEN ISNULL(SecuredAmt,0)*DPP.From_10_months_upto_12_months
										WHEN NID.NCIF_AssetClassAlt_Key=@DB1_Alt_Key THEN ISNULL(SecuredAmt,0)*DPP.DOUBTFUL_1
										WHEN NID.NCIF_AssetClassAlt_Key=@DB2_Alt_Key THEN ISNULL(SecuredAmt,0)*DPP.DOUBTFUL_2
										WHEN NID.NCIF_AssetClassAlt_Key=@DB3_Alt_Key THEN ISNULL(SecuredAmt,0)*DPP.DOUBTFUL_3
										WHEN NID.NCIF_AssetClassAlt_Key=@LOSS_Alt_Key THEN ISNULL(SecuredAmt,0)*DPP.LOSS
										END  ),
--ProvUnsecured=ISNULL(UnSecuredAmt,0)*ISNULL(DPP.ProvisionUnSecured,0),COMMENTED ON 20230731

ProvUnsecured=(CASE WHEN NID.NCIF_AssetClassAlt_Key=@SUB_Alt_Key AND (SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))<=3 THEN ISNULL(UnSecuredAmt,0)*DPP.upto_3_months 
										WHEN NID.NCIF_AssetClassAlt_Key=@SUB_Alt_Key AND ((SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))>3 AND (SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))<=6) THEN ISNULL(UnSecuredAmt,0)*DPP.From_4_months_upto_6_months 
										WHEN NID.NCIF_AssetClassAlt_Key=@SUB_Alt_Key AND ((SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))>6 AND (SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))<=9)  THEN ISNULL(UnSecuredAmt,0)*DPP.From_7_months_upto_9_months
										WHEN NID.NCIF_AssetClassAlt_Key=@SUB_Alt_Key AND ((SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))>9 AND (SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))<=12) THEN ISNULL(UnSecuredAmt,0)*DPP.From_10_months_upto_12_months
										WHEN NID.NCIF_AssetClassAlt_Key=@DB1_Alt_Key THEN ISNULL(UnSecuredAmt,0)*DPP.ProvisionUnSecured
										WHEN NID.NCIF_AssetClassAlt_Key=@DB2_Alt_Key THEN ISNULL(UnSecuredAmt,0)*DPP.ProvisionUnSecured
										WHEN NID.NCIF_AssetClassAlt_Key=@DB3_Alt_Key THEN ISNULL(UnSecuredAmt,0)*DPP.ProvisionUnSecured
										WHEN NID.NCIF_AssetClassAlt_Key=@LOSS_Alt_Key THEN ISNULL(UnSecuredAmt,0)*DPP.ProvisionUnSecured
				END)
			 
			 FROM #TempNPA_Int NID 
		LEFT JOIN DIMPROVISIONPOLICY DPP ON DPP.ProvisionAlt_Key=NID.ProvisionAlt_Key
		 AND DPP.EffectiveFromTimeKey<=@TimeKey
                          AND DPP.EffectiveToTimeKey>=@TimeKey
						  AND NID.ProvisionAlt_Key=DPP.ProvisionAlt_key
		LEFT JOIN #MOC B ON NID.NCIF_Id=B.NCIF_ID
		WHERE  NID.NCIF_AssetClassAlt_Key<>@STD_Alt_Key
		AND NID.NCIF_ID =CASE WHEN @IS_MOC ='Y' THEN B.NCIF_ID ELSE  NID.NCIF_ID END
		AND  (NID.TotalProvision IS NULL OR NID.TotalProvision=0)

--
------------END-----------------------------------------------

UPDATE NID SET
Provsecured=ISNULL(SecuredAmt,0)*ISNULL(DP.ProvisionSecured,0),
ProvUnsecured=ISNULL(UnSecuredAmt,0)*ISNULL(DP.ProvisionUnSecured,0)--,
--TotalProvision=(ISNULL(SecuredAmt,0)*ISNULL(DP.ProvisionSecured,0))+(ISNULL(UnSecuredAmt,0)*ISNULL(DP.ProvisionUnSecured,0))
FROM #TempNPA_Int NID
INNER JOIN DimProvision DP ON DP.EffectiveFromTimeKey<=@TimeKey
                          AND DP.EffectiveToTimeKey>=@TimeKey
						  AND NID.ProvisionAlt_Key=DP.ProvisionAlt_key
LEFT JOIN #MOC B ON NID.NCIF_Id=B.NCIF_ID
WHERE NID.NCIF_ID =CASE WHEN @IS_MOC ='Y' THEN B.NCIF_ID ELSE  NID.NCIF_ID END
AND NID.NCIF_AssetClassAlt_Key<>@STD_Alt_Key
 AND  NID.IsFunded='Y' 
 AND  (NID.TotalProvision IS NULL OR NID.TotalProvision=0) --ADDED BY ZAIN 20230720 ON UAT 20230922 ON PRODso that the values which was not updated above shouldbe updated


 
DROP TABLE IF EXISTS ##TEMP
 
SELECT CustomerACID,ProductCode,SrcSysAlt_Key,Provsecured,ProvUnSecured,SecuredAmt,UNSecuredAmt,'Y' PROVISION_COMP,
(CASE WHEN NID.NCIF_AssetClassAlt_Key=@SUB_Alt_Key AND (SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))<=3  THEN DPP.upto_3_months 
										WHEN NID.NCIF_AssetClassAlt_Key=@SUB_Alt_Key AND ((SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))>3 AND (SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))<=6) THEN DPP.From_4_months_upto_6_months 
										WHEN NID.NCIF_AssetClassAlt_Key=@SUB_Alt_Key AND ((SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))>6 AND (SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))<=9)   THEN DPP.From_7_months_upto_9_months
										WHEN NID.NCIF_AssetClassAlt_Key=@SUB_Alt_Key AND ((SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))>9 AND (SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))<=12) THEN DPP.From_10_months_upto_12_months
										WHEN NID.NCIF_AssetClassAlt_Key=@DB1_Alt_Key THEN DPP.DOUBTFUL_1
										WHEN NID.NCIF_AssetClassAlt_Key=@DB2_Alt_Key THEN DPP.DOUBTFUL_2
										WHEN NID.NCIF_AssetClassAlt_Key=@DB3_Alt_Key THEN DPP.DOUBTFUL_3
										WHEN NID.NCIF_AssetClassAlt_Key=@LOSS_Alt_Key THEN DPP.LOSS
										END  ) SEC_PER,
(CASE WHEN NID.NCIF_AssetClassAlt_Key=@SUB_Alt_Key AND (SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))<=3 THEN DPP.upto_3_months 
										WHEN NID.NCIF_AssetClassAlt_Key=@SUB_Alt_Key AND ((SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))>3 AND (SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))<=6) THEN DPP.From_4_months_upto_6_months 
										WHEN NID.NCIF_AssetClassAlt_Key=@SUB_Alt_Key AND ((SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))>6 AND (SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))<=9)  THEN DPP.From_7_months_upto_9_months
										WHEN NID.NCIF_AssetClassAlt_Key=@SUB_Alt_Key AND ((SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))>9 AND (SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))<=12) THEN DPP.From_10_months_upto_12_months
										WHEN NID.NCIF_AssetClassAlt_Key=@DB1_Alt_Key THEN DPP.ProvisionUnSecured
										WHEN NID.NCIF_AssetClassAlt_Key=@DB2_Alt_Key THEN DPP.ProvisionUnSecured
										WHEN NID.NCIF_AssetClassAlt_Key=@DB3_Alt_Key THEN DPP.ProvisionUnSecured
										WHEN NID.NCIF_AssetClassAlt_Key=@LOSS_Alt_Key THEN DPP.ProvisionUnSecured
				END) UNSEC_PER 
INTO ##TEMP FROM #TempNPA_Int NID 
LEFT JOIN #MOC B ON NID.NCIF_Id=B.NCIF_ID
INNER JOIN DIMPROVISIONPOLICY DPP ON NID.ProductCode=DPP.Scheme_Code 
and DPP.EffectiveFromTimeKey<=@TimeKey and DPP.EffectiveToTimeKey>=@TimeKey
WHERE DPP.Scheme_Code IS NOT NULL AND IsFunded='Y' AND ISNULL(IsTWO,'N')<>'Y'  and NID.NCIF_ID =CASE WHEN @IS_MOC ='Y' THEN B.NCIF_ID ELSE  NID.NCIF_ID END
UNION
SELECT CustomerACID,ProductCode,SrcSysAlt_Key,Provsecured,ProvUnSecured,SecuredAmt,UNSecuredAmt,'Y' PROVISION_COMP,
(CASE WHEN NID.NCIF_AssetClassAlt_Key=@SUB_Alt_Key AND (SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))<=3  THEN DPP.upto_3_months 
										WHEN NID.NCIF_AssetClassAlt_Key=@SUB_Alt_Key AND ((SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))>3 AND (SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))<=6) THEN DPP.From_4_months_upto_6_months 
										WHEN NID.NCIF_AssetClassAlt_Key=@SUB_Alt_Key AND ((SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))>6 AND (SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))<=9)   THEN DPP.From_7_months_upto_9_months
										WHEN NID.NCIF_AssetClassAlt_Key=@SUB_Alt_Key AND ((SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))>9 AND (SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))<=12) THEN DPP.From_10_months_upto_12_months
										WHEN NID.NCIF_AssetClassAlt_Key=@DB1_Alt_Key THEN DPP.DOUBTFUL_1
										WHEN NID.NCIF_AssetClassAlt_Key=@DB2_Alt_Key THEN DPP.DOUBTFUL_2
										WHEN NID.NCIF_AssetClassAlt_Key=@DB3_Alt_Key THEN DPP.DOUBTFUL_3
										WHEN NID.NCIF_AssetClassAlt_Key=@LOSS_Alt_Key THEN DPP.LOSS
										END  ) SEC_PER,
(CASE WHEN NID.NCIF_AssetClassAlt_Key=@SUB_Alt_Key AND (SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))<=3 THEN DPP.upto_3_months 
										WHEN NID.NCIF_AssetClassAlt_Key=@SUB_Alt_Key AND ((SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))>3 AND (SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))<=6) THEN DPP.From_4_months_upto_6_months 
										WHEN NID.NCIF_AssetClassAlt_Key=@SUB_Alt_Key AND ((SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))>6 AND (SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))<=9)  THEN DPP.From_7_months_upto_9_months
										WHEN NID.NCIF_AssetClassAlt_Key=@SUB_Alt_Key AND ((SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))>9 AND (SELECT dbo.FullMonthsSeparation(@Ext_DATE_1, NID.NCIF_NPA_Date))<=12) THEN DPP.From_10_months_upto_12_months
										WHEN NID.NCIF_AssetClassAlt_Key=@DB1_Alt_Key THEN DPP.ProvisionUnSecured
										WHEN NID.NCIF_AssetClassAlt_Key=@DB2_Alt_Key THEN DPP.ProvisionUnSecured
										WHEN NID.NCIF_AssetClassAlt_Key=@DB3_Alt_Key THEN DPP.ProvisionUnSecured
										WHEN NID.NCIF_AssetClassAlt_Key=@LOSS_Alt_Key THEN DPP.ProvisionUnSecured
				END) UNSEC_PER 
FROM #TempNPA_Int NID 
LEFT JOIN #MOC B ON NID.NCIF_Id=B.NCIF_ID
INNER JOIN DIMPROVISIONPOLICY DPP ON NID.SrcSysAlt_Key=DPP.Source_Alt_Key 
and DPP.EffectiveFromTimeKey<=@TimeKey and DPP.EffectiveToTimeKey>=@TimeKey
WHERE DPP.Scheme_Code IS NULL AND IsFunded='Y' AND ISNULL(IsTWO,'N')<>'Y'  and NID.NCIF_ID =CASE WHEN @IS_MOC ='Y' THEN B.NCIF_ID ELSE  NID.NCIF_ID END
 
INSERT INTO ##TEMP
SELECT NID.CustomerACID,NID.ProductCode,NID.SrcSysAlt_Key,NID.Provsecured,NID.ProvUnSecured,NID.SecuredAmt,NID.UnSecuredAmt,'N' PROVISION_COMP,
DP.ProvisionSecured,DP.ProvisionUnSecured
FROM #TempNPA_Int NID INNER JOIN DimProvision DP ON NID.ProvisionAlt_Key=DP.ProvisionAlt_Key
LEFT JOIN #MOC B ON NID.NCIF_Id=B.NCIF_ID 
AND DP.EffectiveFromTimeKey<=@TIMEKEY AND DP.EffectiveToTimeKey>=@TIMEKEY
LEFT JOIN ##TEMP T ON NID.CustomerACID=T.CustomerACID
WHERE T.CustomerACID IS NULL AND IsFunded='Y' AND ISNULL(IsTWO,'N')<>'Y'  and NID.NCIF_ID =CASE WHEN @IS_MOC ='Y' THEN B.NCIF_ID ELSE  NID.NCIF_ID END
 

IF(@IS_MOC='Y')
			begin
				UPDATE T SET PROVISION_COMP='Y'
				FROM ##TEMP T INNER JOIN HISTORY_PROVISIONPOLICY HDP ON T.ProductCode=HDP.Scheme_Code
				INNER JOIN #TempNPA_Int NID ON NID.CustomerACID=T.CustomerACID  
				WHERE PROVISION_COMP='N' AND HDP.Scheme_Code IS NOT NULL AND ISNULL(NID.FlgProcessing,'N')='Y'

				UPDATE T SET PROVISION_COMP='Y'
				FROM ##TEMP T INNER JOIN HISTORY_PROVISIONPOLICY HDP ON T.SrcSysAlt_Key=HDP.Source_Alt_Key
				INNER JOIN #TempNPA_Int NID ON NID.CustomerACID=T.CustomerACID  
				WHERE PROVISION_COMP='N' AND HDP.Scheme_Code IS NULL AND ISNULL(NID.FlgProcessing,'N')='Y'
			end
	Else
			Begin
				UPDATE T SET PROVISION_COMP='Y'
				FROM ##TEMP T INNER JOIN HISTORY_PROVISIONPOLICY HDP ON T.ProductCode=HDP.Scheme_Code
				WHERE PROVISION_COMP='N' AND HDP.Scheme_Code IS NOT NULL

				UPDATE T SET PROVISION_COMP='Y'
				FROM ##TEMP T INNER JOIN HISTORY_PROVISIONPOLICY HDP ON T.SrcSysAlt_Key=HDP.Source_Alt_Key
				WHERE PROVISION_COMP='N' AND HDP.Scheme_Code IS NULL
			end
 
 UPDATE NID SET NID.Provsecured=(CASE WHEN ISNULL(SEC_PROVPER_OLD,0) >ISNULL(SEC_PER,0)  THEN NID.SecuredAmt*ISNULL(NID.SEC_PROVPER_OLD,0) 
										ELSE NID.Provsecured END ),
				NID.ProvUNsecured= (CASE WHEN ISNULL(UNSEC_PROVPER_OLD,0) >ISNULL(UNSEC_PER,0)  THEN NID.UnSecuredAmt*ISNULL(NID.UNSEC_PROVPER_OLD,0) 
											ELSE NID.ProvUnsecured END )
				FROM #TempNPA_Int NID INNER JOIN ##TEMP T ON NID.CustomerACID=T.CustomerACID 
				WHERE T.PROVISION_COMP='Y'
 
 UPDATE NID SET NID.SEC_PROVPER_OLD=(CASE WHEN ISNULL(SEC_PROVPER_OLD,0) < ISNULL(SEC_PER,0)  THEN SEC_PER   
												ELSE ISNULL(NID.SEC_PROVPER_OLD,0) END ),
				NID.UNSEC_PROVPER_OLD = (CASE WHEN ISNULL(UNSEC_PROVPER_OLD,0) < ISNULL(UNSEC_PER,0)  THEN UNSEC_PER   
												ELSE ISNULL(NID.UNSEC_PROVPER_OLD,0) END)
				FROM #TempNPA_Int NID INNER JOIN ##TEMP T ON NID.CustomerACID=T.CustomerACID 
/***********************/

--UPDATE #TempNPA_Int SET TotalProvision=ISNULL(Provsecured,0)+ISNULL(ProvUnsecured,0) 
--WHERE EffectiveFromTimeKey<=@TIMEKEY AND EffectiveFromTimeKey>=@TIMEKEY

UPDATE NID SET TotalProvision=ISNULL(Provsecured,0)+ISNULL(ProvUnsecured,0) 
From #TempNPA_Int NID 
LEFT JOIN #MOC B ON NID.NCIF_Id=B.NCIF_ID  
WHERE NID.NCIF_ID =CASE WHEN @IS_MOC ='Y' THEN B.NCIF_ID ELSE  NID.NCIF_ID END


UPDATE NID
SET TotalProvision= CASE WHEN (ISNULL(NID.PrincipleOutstanding,0)* ISNULL(AP.AccProvPer,0))/100>(ISNULL(NID.TotalProvision,0)+
																(CASE WHEN ISNULL(NID.AddlProvisionPer,0)>0
																	THEN (ISNULL(NID.AddlProvisionPer,0)*ISNULL(NID.PrincipleOutstanding,0))/100
																	-- THEN (ISNULL(NID.AddlProvisionPer,0)*ISNULL(NID.TotalProvision,0))/100  
																WHEN ISNULL(NID.AddlProvision,0)>0
																THEN ISNULL(NID.AddlProvision,0)
																ELSE 0
																END))
                              THEN (ISNULL(NID.PrincipleOutstanding,0)* ISNULL(AP.AccProvPer,0))/100 
					     ELSE (ISNULL(NID.TotalProvision,0)+(CASE WHEN ISNULL(NID.AddlProvisionPer,0)>0
																	   THEN (ISNULL(NID.AddlProvisionPer,0)*ISNULL(NID.PrincipleOutstanding,0))/100
																	-- THEN (ISNULL(NID.AddlProvisionPer,0)*ISNULL(NID.TotalProvision,0))/100  
																  WHEN ISNULL(NID.AddlProvision,0)>0
																	   THEN ISNULL(NID.AddlProvision,0)
																  ELSE 0
                                                               END))

				    END,
   AddlProvision=ISNULL(NID.AddlProvision,0) +
                 (CASE WHEN (ISNULL(NID.PrincipleOutstanding,0)* ISNULL(AP.AccProvPer,0))/100>(ISNULL(NID.TotalProvision,0)+(CASE WHEN ISNULL(NID.AddlProvisionPer,0)>0
																								                                       THEN (ISNULL(NID.AddlProvisionPer,0)*ISNULL(NID.PrincipleOutstanding,0))/100
																																	  -- THEN (ISNULL(NID.AddlProvisionPer,0)*ISNULL(NID.TotalProvision,0))/100 
																									                              WHEN ISNULL(NID.AddlProvision,0)>0
																									                                   THEN ISNULL(NID.AddlProvision,0)
																									                               ELSE 0
                                                                                                                             END))
                              THEN ((ISNULL(NID.PrincipleOutstanding,0)* ISNULL(AP.AccProvPer,0))/100)-(ISNULL(NID.TotalProvision,0)+(CASE WHEN ISNULL(NID.AddlProvisionPer,0)>0
																								                                      THEN (ISNULL(NID.AddlProvisionPer,0)*ISNULL(NID.PrincipleOutstanding,0))/100
																																   -- THEN (ISNULL(NID.AddlProvisionPer,0)*ISNULL(NID.TotalProvision,0))/100 
																									                              WHEN ISNULL(NID.AddlProvision,0)>0
																									                                   THEN ISNULL(NID.AddlProvision,0)
																									                               ELSE 0
                                                                                                                             END)) 
					     ELSE (CASE WHEN ISNULL(NID.AddlProvisionPer,0)>0
										 THEN (ISNULL(NID.AddlProvisionPer,0)*ISNULL(NID.PrincipleOutstanding,0))/100
										  -- THEN (ISNULL(NID.AddlProvisionPer,0)*ISNULL(NID.TotalProvision,0))/100 
									ELSE 0
                               END)
				  END)
FROM #TempNPA_Int NID
INNER JOIN [CurDat].AcceleratedProv AP ON   AP.EffectiveFromTimeKey<=@TimeKey
                             AND AP.EffectiveToTimeKey>=@TimeKey
							 ----AND NID.NCIF_Id=AP.NCIF_Id
							 ---AND NID.CustomerId=AP.CustomerId
							 AND NID.CustomerACID=AP.CustomerACID
							 AND NID.SrcSysAlt_Key=AP.SrcSysAlt_Key
LEFT JOIN #MOC B ON NID.NCIF_Id=B.NCIF_ID 
WHERE NID.NCIF_ID =CASE WHEN @IS_MOC ='Y' THEN B.NCIF_ID ELSE  NID.NCIF_ID END
AND  NID.IsFunded='Y'
AND NCIF_AssetClassAlt_Key<>@STD_Alt_Key

/*FOR ALL THE STANDARD ACCOUNTS CATEGORY UPDATE ON MONTH END DATA ON 20240902*/ 

DECLARE @LAST_MONTHEND_DATE DATE=(SELECT DISTINCT CAST(DATEADD(MONTH, DATEDIFF(MONTH,-1,(SELECT DATE FROM SYSDATAMATRIX WHERE CurrentStatus='C'))-1,-1) AS date) 
									FROM SysDataMatrix )--26084 
DECLARE @LAST_MONTHEND_TIMEKEY INT = (SELECT MAX(TIMEKEY) FROM SysDataMatrix WHERE MonthLastDate=@LAST_MONTHEND_DATE)--26267 
DECLARE @MOC_FREEZE_TIMEKEY INT=(SELECT TimeKey FROM SysDataMatrix WHERE ISNULL(MOC_Freeze,'N')<>'N' And TimeKey=@LAST_MONTHEND_TIMEKEY ) 
 
 select @LAST_MONTHEND_DATE,@LAST_MONTHEND_TIMEKEY,@MOC_FREEZE_TIMEKEY

IF @MOC_FREEZE_TIMEKEY is Not Null
	Begin
		DROP TABLE IF EXISTS #NPA_IntegrationDetails_ARC
			SELECT * INTO #NPA_IntegrationDetails_ARC  
			 FROM NPA_IntegrationDetails_ARCHIVE -- ON PROD DEPLOYMENT NPA_IntegrationDetails_ARCHIVE SHOULD BE REPLACED OR INPUT DATA IN ARCHIVE TABLE 
				WHERE EffectiveFromTimeKey<=@TimeKey-1
					AND EffectiveToTimeKey>=@TimeKey-1
					AND ISNULL(NCIF_AssetClassAlt_Key,1)=1

		UPDATE MNID SET MNID.STD_ASSET_CAT_Alt_key=ISNULL(NID.STD_ASSET_CAT_Alt_key,900) 
		FROM #NPA_IntegrationDetails_ARC NID
		INNER JOIN #TempNPA_Int MNID ON NID.CustomerACID=MNID.CustomerACID
		WHERE NID.EffectiveFromTimeKey<=@TimeKey-1 AND NID.EffectiveToTimeKey>=@TimeKey-1
				AND ISNULL(@MOC_FREEZE_TIMEKEY,0)=@LAST_MONTHEND_TIMEKEY 
				AND MNID.EffectiveFromTimeKey<=@LAST_MONTHEND_TIMEKEY AND MNID.EffectiveToTimeKey>=@LAST_MONTHEND_TIMEKEY
				AND NID.NCIF_AssetClassAlt_Key=@STD_Alt_Key 
				AND MNID.NCIF_AssetClassAlt_Key=@STD_Alt_Key  
				AND ISNULL(NID.Balance,0)>=0 
				AND NID.IsFunded='Y'  

		/*HANDLING DAILY PROCESS NULL AS OTHER I.E., 4%*/
		UPDATE NID SET NID.STD_ASSET_CAT_Alt_key=900
		FROM #TempNPA_Int NID 
		INNER JOIN DIM_STD_ASSET_CAT DP ON NID.EffectiveFromTimeKey<=@LAST_MONTHEND_TIMEKEY
							   AND NID.EffectiveToTimeKey>=@LAST_MONTHEND_TIMEKEY
								  AND DP.EffectiveFromTimeKey<=@LAST_MONTHEND_TIMEKEY
								  AND DP.EffectiveToTimeKey>=@LAST_MONTHEND_TIMEKEY
								 --- AND NID.STD_ASSET_CAT_Alt_key=Null
		LEFT JOIN #MOC B ON NID.NCIF_Id=B.NCIF_ID
		WHERE NID.NCIF_ID =  NID.NCIF_ID 
		AND NID.NCIF_AssetClassAlt_Key=@STD_Alt_Key
		AND ISNULL(Balance,0)>=0 -- ADDED ON 20230612 TO AVOID CALCULATION OF 0 AND NEGATIVE BALANCE PROVISION
		 AND  NID.IsFunded='Y'
		 AND NID.STD_ASSET_CAT_Alt_key IS NULL
 
		/*HANDLING DAILY PROCESS NULL AS OTHER I.E., 4% END*/

		UPDATE NID SET TotalProvision=(ISNULL(Balance,0)*ISNULL(DP.STD_ASSET_CAT_Prov,0))
		FROM #TempNPA_Int NID
		INNER JOIN DIM_STD_ASSET_CAT DP ON NID.EffectiveFromTimeKey<=@LAST_MONTHEND_TIMEKEY
								  AND NID.EffectiveToTimeKey>=@LAST_MONTHEND_TIMEKEY
								  AND DP.EffectiveFromTimeKey<=@LAST_MONTHEND_TIMEKEY
								  AND DP.EffectiveToTimeKey>=@LAST_MONTHEND_TIMEKEY
								  AND NID.STD_ASSET_CAT_Alt_key=DP.STD_ASSET_CATAlt_key 
		WHERE NID.NCIF_AssetClassAlt_Key=@STD_Alt_Key 
		AND ISNULL(Balance,0)>0  AND  NID.IsFunded='Y' ----AND  NID.FlgMOC='Y'

 
		UPDATE NID SET TotalProvision=ISNULL(Balance,0) 
		FROM #TempNPA_Int NID  
		WHERE NID.EffectiveFromTimeKey<=@LAST_MONTHEND_TIMEKEY AND NID.EffectiveToTimeKey>=@LAST_MONTHEND_TIMEKEY 
		And NID.NCIF_AssetClassAlt_Key=@STD_Alt_Key  
		And ISNULL(TotalProvision,0)>ISNULL(Balance,0)
	End
/*ADDED ON 20240902 BY MOHIT FOR ALL THE STANDARD ACCOUNTS CATEGORY UPDATE ON MONTH END DATA COMPLETE*/ 
UPDATE NID SET
STD_ASSET_CAT_Alt_key=900
FROM #TempNPA_Int NID 
LEFT JOIN #MOC B ON NID.NCIF_Id=B.NCIF_ID
WHERE NID.STD_ASSET_CAT_Alt_key is NULL and NID.NCIF_ID =CASE WHEN @IS_MOC ='Y' THEN B.NCIF_ID ELSE  NID.NCIF_ID END
AND NID.NCIF_AssetClassAlt_Key=@STD_Alt_Key 
AND ISNULL(Balance,0)>0 -- ADDED ON 20230612 TO AVOID CALCULATION OF 0 AND NEGATIVE BALANCE PROVISION
 AND  NID.IsFunded='Y'
 
UPDATE NID SET
TotalProvision=(ISNULL(Balance,0)*ISNULL(DP.STD_ASSET_CAT_Prov,0))
FROM #TempNPA_Int NID
INNER JOIN DIM_STD_ASSET_CAT DP ON  DP.EffectiveFromTimeKey<=@TimeKey
                          AND DP.EffectiveToTimeKey>=@TimeKey
						  AND NID.STD_ASSET_CAT_Alt_key =DP.STD_ASSET_CATAlt_key  --- ISNULL Added for MOC observation by Liyaqat on 20240826
LEFT JOIN #MOC B ON NID.NCIF_Id=B.NCIF_ID
WHERE NID.NCIF_ID =CASE WHEN @IS_MOC ='Y' THEN B.NCIF_ID ELSE  NID.NCIF_ID END
AND NID.NCIF_AssetClassAlt_Key=@STD_Alt_Key 
AND ISNULL(Balance,0)>0 -- ADDED ON 20230612 TO AVOID CALCULATION OF 0 AND NEGATIVE BALANCE PROVISION
 AND  NID.IsFunded='Y'

 UPDATE NID SET SEC_PROVPER_OLD=ISNULL(DP.STD_ASSET_CAT_Prov,0),UNSEC_PROVPER_OLD=ISNULL(DP.STD_ASSET_CAT_Prov,0)
 FROM #TempNPA_Int NID
INNER JOIN DIM_STD_ASSET_CAT DP ON DP.EffectiveFromTimeKey<=@TimeKey
                          AND DP.EffectiveToTimeKey>=@TimeKey
						  AND NID.STD_ASSET_CAT_Alt_key =DP.STD_ASSET_CATAlt_key --- ISNULL Added for MOC observation by Liyaqat on 20240826
LEFT JOIN #MOC B ON NID.NCIF_Id=B.NCIF_ID
WHERE NID.NCIF_ID =CASE WHEN @IS_MOC ='Y' THEN B.NCIF_ID ELSE  NID.NCIF_ID END
AND NID.NCIF_AssetClassAlt_Key=@STD_Alt_Key 
AND ISNULL(Balance,0)>0 -- ADDED ON 20230612 TO AVOID CALCULATION OF 0 AND NEGATIVE BALANCE PROVISION
 AND  NID.IsFunded='Y'



--IF STD RESTRUCTURE THE PROVISION WOULD BE 0 AS IT WOULD BE CALCULATED THROUGH NEW MODULE
UPDATE NID SET
TotalProvision=0
FROM #TempNPA_Int NID
LEFT JOIN #MOC B ON NID.NCIF_Id=B.NCIF_ID
WHERE NID.NCIF_ID =CASE WHEN @IS_MOC ='Y' THEN B.NCIF_ID ELSE  NID.NCIF_ID END
AND NID.NCIF_AssetClassAlt_Key=@STD_Alt_Key 
AND ISNULL(Balance,0)>0 -- ADDED ON 20230612 TO AVOID CALCULATION OF 0 AND NEGATIVE BALANCE PROVISION
AND  NID.IsFunded='Y' 
AND IsRestructured='Y'



--UPDATE Audit Flag
IF(@IS_MOC='Y')
BEGIN

IF OBJECT_ID('TEMPDB..#MOC') IS NOT NULL
DROP TABLE #MOC

UPDATE #TempNPA_Int SET FlgProcessing='N'
WHERE EffectiveFromTimeKey<=@TimeKey
AND EffectiveToTimeKey>=@TimeKey
AND ISNULL(FlgProcessing,'N')='Y'

END
  
	UPDATE A set
		 a.ProvisionAlt_Key     =b.ProvisionAlt_Key
		,a.Provsecured			=b.Provsecured
		,a.ProvUnSecured		=b.ProvUnSecured
		,a.TotalProvision		=b.TotalProvision
		,a.AddlProvision		=b.AddlProvision
		,a.AddlProvisionPer		=b.AddlProvisionPer
		,a.STD_ASSET_CAT_Alt_key=b.STD_ASSET_CAT_Alt_key
		,a.SEC_PROVPER_OLD		=b.SEC_PROVPER_OLD
		,a.UNSEC_PROVPER_OLD	=b.UNSEC_PROVPER_OLD
		,a.FlgProcessing		=b.FlgProcessing
		from NPA_IntegrationDetails A Join #TempNPA_Int b on 
		a.NCIF_ID=b.NCIF_ID and a.CustomerId=b.CustomerId and
		a.CustomerACID=b.CustomerACID and A.SrcSysAlt_Key=b.SrcSysAlt_Key and
		a.EffectiveFromTimeKey=b.EffectiveFromTimeKey and a.EffectiveToTimeKey=b.EffectivetoTimeKey



COMMIT TRAN
UPDATE IBL_ENPA_STGDB.[dbo].[Procedure_Audit] SET End_Date_Time=GETDATE(),[Audit_Flg]=1 
WHERE [SP_Name]='ProvisionComputation' AND [EXT_DATE]=@Ext_DATE AND ISNULL([Audit_Flg],0)=0
END TRY
BEGIN CATCH
 DECLARE
   @ErMessage NVARCHAR(2048),
   @ErSeverity INT,
   @ErState INT
 
 SELECT  @ErMessage = ERROR_MESSAGE(),
   @ErSeverity = ERROR_SEVERITY(),
   @ErState = ERROR_STATE()

UPDATE IBL_ENPA_STGDB.[dbo].[Procedure_Audit] SET ERROR_MESSAGE=@ErMessage
WHERE [SP_Name]='ProvisionComputation' AND [EXT_DATE]=@Ext_DATE AND ISNULL([Audit_Flg],0)=0
 
 RAISERROR (@ErMessage,
             @ErSeverity,
             @ErState )
ROLLBACK TRAN
END CATCH






GO