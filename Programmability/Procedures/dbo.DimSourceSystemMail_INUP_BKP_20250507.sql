﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[DimSourceSystemMail_INUP_BKP_20250507] ---'IBL149917',26852,1,'Finacle','vinit.barve@indusind.com','Y',-1
@USERLOGINID VARCHAR(250),
@TIMEKEY INT,
@OPERATIONFLAG INT,
@SourceName VARCHAR(100),
@SourceSystemMailID VARCHAR(250),
@SourceSystemMailValidCode VARCHAR(3),
@Result1 INT OUTPUT
AS
BEGIN
DECLARE @EMAILIN_DimSourceSystemMail_MOD INT

IF @SourceName = 'Gan Seva' 
BEGIN
SET @SourceName='Ganaseva'
END
/*ADDED BY MOHIT*/

	SET @EMAILIN_DimSourceSystemMail_MOD=(SELECT COUNT(1) FROM DimSourceSystemMail_MOD 
														WHERE SourceSystemMailID=@SourceSystemMailID 
														AND SourceAlt_Key=(SELECT DISTINCT SourceAlt_Key FROM DIMSOURCESYSTEM WHERE SourceName=@SourceName )
														AND SourceSystemMailValidCode='Y')

IF @OPERATIONFLAG=1 and @EMAILIN_DimSourceSystemMail_MOD>0
BEGIN
	SET @Result1=-6
	RAISERROR (N'This Email ID is already Available %s ', -- Message text.
           10, -- Severity,
           1, -- State,
           @SourceSystemMailID); -- Second argument.

END
		/*INSERTING NEW MAILID*/
		IF @OPERATIONFLAG=1 AND @EMAILIN_DimSourceSystemMail_MOD=0
		BEGIN
		SET @Result1=1
		Declare @SourceSystemMail_Key int 

		IF(select count(1) from DimSourceSystemMail_MOD)  = 0
			Begin 
				Set @SourceSystemMail_Key=1
				Print @SourceSystemMail_Key
			END
		else if (SELECT MAX(isnull(@SourceSystemMail_Key,0) )+1  FROM DimSourceSystemMail_MOD )>0
			Begin
				Set  @SourceSystemMail_Key=(SELECT MAX(isnull(SourceSystemMail_Key,0) )+1  FROM DimSourceSystemMail_MOD )
			END
				INSERT INTO DimSourceSystemMail_MOD 
					(SourceSystemMail_Key
					,SourceAlt_Key
					,SourceSystemMailID 
					,SourceSystemMailValidCode 
					,CreatedBy 
					,DATECREATED 
					,AUTHORISATIONSTATUS 
					,EffectiveFromTimeKey
					,EffectiveToTimeKey
					,D2Ktimestamp
					)
					SELECT 
						(@SourceSystemMail_Key )
						,(SELECT DISTINCT SourceAlt_Key FROM DIMSOURCESYSTEM WHERE SourceName=@SourceName )
						,@SourceSystemMailID 
						,@SourceSystemMailValidCode
						,@USERLOGINID
						,(SELECT convert(varchar, getdate(), 121))
						,'NP'
						,@TIMEKEY
						,49999
						,(SELECT convert(varchar, getdate(), 121))
		
		END		
		/*EXPIRING OLD EMAIL ID IN SOURCE SYSTEM NAME*/
		ELSE IF @OPERATIONFLAG=2
						
					BEGIN
					/* FOR MOD TABLE*/
						SET @Result1=1	
								UPDATE DimSourceSystemMail_MOD SET SourceSystemMailValidCode=@SourceSystemMailValidCode,--CHANGED BY ZAIN ON LOCAL & UAT FROM "N" TO PARAMETERIZED VALUE ON 20250425
																	ModifiedBy=@USERLOGINID,
																	DateModified=(SELECT convert(varchar, getdate(), 121))
									WHERE SourceSystemMailID=@SourceSystemMailID
									AND SourceAlt_Key=(SELECT DISTINCT SourceAlt_Key FROM DIMSOURCESYSTEM WHERE SourceName=@SourceName )
										--AND SourceSystemMailValidCode='Y'--CHANGED BY ZAIN ON LOCAL & UAT ON 20250425


					/* FOR MAIN TABLE*/
								UPDATE DimSourceSystemMail SET SourceSystemMailValidCode='N',
																	ModifiedBy=@USERLOGINID,
																	DateModified=(SELECT convert(varchar, getdate(), 121))
									WHERE SourceSystemMailID=@SourceSystemMailID
									AND SourceAlt_Key=(SELECT DISTINCT SourceAlt_Key FROM DIMSOURCESYSTEM WHERE SourceName=@SourceName )
										AND SourceSystemMailValidCode='Y'
					END
		
		/*SETTING AUTHORISATION STATUS D FOR DELETED RECORDS*/
		ELSE IF @OPERATIONFLAG=3
							
					BEGIN
				
					SET @Result1=1	
					/* FOR MOD TABLE*/
					INSERT INTO DimSourceSystemMail_MOD(
							SourceSystemMail_Key,
							SourceAlt_Key	,
							SourceSystemMailID	,
							SourceSystemMailGroup	,
							SourceSystemMailSubGroup	,
							SourceSystemMailSegment	,
							SourceSystemMailValidCode	,
							AuthorisationStatus	,
							EffectiveFromTimeKey	,
							EffectiveToTimeKey	,
							CreatedBy	,
							DateCreated	,
							ModifiedBy	,
							DateModified	,
							ApprovedBy	,
							DateApproved	,
							D2Ktimestamp	,
							ApprovedByFirstLevel	,
							DateApprovedFirstLevel)
					SELECT (SELECT MAX(isnull(SourceSystemMail_Key,0) )+1  FROM DimSourceSystemMail_MOD ),
							SourceAlt_Key	,
							SourceSystemMailID	,
							SourceSystemMailGroup	,
							SourceSystemMailSubGroup	,
							SourceSystemMailSegment	,
							'D'	,
							'MP'	,
							@TIMEKEY	,
							EffectiveToTimeKey	,
							@USERLOGINID	,
							GETDATE()	,
							NULL	,
							NULL	,
							NULL	,
							NULL	,
							D2Ktimestamp	,
							NULL	,
							NULL	
						FROM DimSourceSystemMail 
							WHERE SourceSystemMailID=@SourceSystemMailID
								AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY

								--UPDATE DimSourceSystemMail_MOD SET SourceSystemMailValidCode='D',
								--									ModifiedBy=@USERLOGINID,
								--									DateModified=(SELECT convert(varchar, getdate(), 121)),
								--									AuthorisationStatus='MP'
								--	WHERE 
								--		SourceSystemMailID=@SourceSystemMailID 
								--		AND SourceAlt_Key=(SELECT DISTINCT SourceAlt_Key FROM DIMSOURCESYSTEM WHERE SourceName=@SourceName )
								--		AND EffectiveFromTimeKey<=@TIMEKEY
								--		AND EffectiveToTimeKey>=@TIMEKEY
								--		--AND CreatedBy<>@USERLOGINID
					END
		/*UPDATING AUTHORISATION STATUS 1A*/
		ELSE IF @OPERATIONFLAG=16
								
					BEGIN
						PRINT '16'
						SET @Result1=1	
								UPDATE DimSourceSystemMail_MOD SET AUTHORISATIONSTATUS='1A',
																	ApprovedByFirstLevel=@USERLOGINID,
																	DateApprovedFirstLevel=(SELECT convert(varchar, getdate(), 121))
									WHERE AuthorisationStatus IN ('NP','MP')
										AND SourceSystemMailID=@SourceSystemMailID 
										AND SourceAlt_Key=(SELECT DISTINCT SourceAlt_Key FROM DIMSOURCESYSTEM WHERE SourceName=@SourceName )
										--AND SourceSystemMailValidCode='Y' COMMENTED FOR INACTIVE AND DELETE RECORDS HAVING 'D,N' STATUS ON 20250422 BY ZAIN
										AND EffectiveFromTimeKey<=@TIMEKEY
										AND EffectiveToTimeKey>=@TIMEKEY
										--AND CreatedBy<>@USERLOGINID
					END

		/*UPDATING AUTHORISATION STATUS R*/
		ELSE IF @OPERATIONFLAG=17
				
					BEGIN
					PRINT '17'
						SET @Result1=1	
								UPDATE DimSourceSystemMail_MOD SET AUTHORISATIONSTATUS='R',
																	ApprovedByFirstLevel=@USERLOGINID,
																	DateApprovedFirstLevel=(SELECT convert(varchar, getdate(), 121)),
																	EffectiveToTimeKey=@TIMEKEY-1
									WHERE AuthorisationStatus IN ('NP','MP')
									AND SourceSystemMailID=@SourceSystemMailID 
									AND SourceAlt_Key=(SELECT DISTINCT SourceAlt_Key FROM DIMSOURCESYSTEM WHERE SourceName=@SourceName )
										--AND SourceSystemMailValidCode='Y' COMMENTED FOR INACTIVE AND DELETE RECORDS HAVING 'D,N' STATUS ON 20250422 BY ZAIN
										AND EffectiveFromTimeKey<=@TIMEKEY
										AND EffectiveToTimeKey>=@TIMEKEY
										--AND CreatedBy<>@USERLOGINID
					END
		/*UPDATING AUTHORISATION STATUS A*/
		ELSE IF @OPERATIONFLAG=20
			
				BEGIN
					PRINT '20'
						SET @Result1=1	


								UPDATE DimSourceSystemMail_MOD SET AUTHORISATIONSTATUS='A',
																	ApprovedBy=@USERLOGINID,
																	DateApproved=(SELECT convert(varchar, getdate(), 121))
									WHERE AuthorisationStatus='1A'
									AND SourceSystemMailID=@SourceSystemMailID 
									AND SourceAlt_Key=(SELECT DISTINCT SourceAlt_Key FROM DIMSOURCESYSTEM WHERE SourceName=@SourceName )
										--AND SourceSystemMailValidCode='Y' COMMENTED FOR INACTIVE AND DELETE RECORDS HAVING 'D,N' STATUS ON 20250422 BY ZAIN
										AND EffectiveFromTimeKey<=@TIMEKEY
										AND EffectiveToTimeKey>=@TIMEKEY
										--AND CreatedBy<>@USERLOGINID
										--AND ApprovedByFirstLevel<>@USERLOGINID
					
						/*DELETE FOR MAIN TABLE ON 20250422 BY ZAIN*/
								--DELETE 
								DELETE FROM DimSourceSystemMail WHERE SourceSystemMailID =@SourceSystemMailID AND SourceSystemMailValidCode='D'
						/*DELETE FOR MAIN TABLE ON 20250422 BY ZAIN END*/
				

				/*INSERT NEW MAIL ID IN MAIN*/
	IF @SourceSystemMailID NOT IN (SELECT SourceSystemMailID FROM DimSourceSystemMail WHERE SourceSystemMailValidCode='Y'
										AND EffectiveFromTimeKey<=27497
										AND EffectiveToTimeKey>=27497
										) 
			AND @SourceSystemMailID<>'D'
			BEGIN
					INSERT INTO DimSourceSystemMail(
											SourceSystemMail_Key	,
											SourceAlt_Key	,
											SourceSystemMailID	,
											SourceSystemMailGroup	,
											SourceSystemMailSubGroup	,
											SourceSystemMailSegment	,
											SourceSystemMailValidCode	,
											AuthorisationStatus	,
											EffectiveFromTimeKey	,
											EffectiveToTimeKey	,
											CreatedBy	,
											DateCreated	,
											ModifiedBy	,
											DateModified	,
											ApprovedBy	,
											DateApproved	,
											D2Ktimestamp	,
											ApprovedByFirstLevel	,
											DateApprovedFirstLevel	
										)
								SELECT
											SourceSystemMail_Key	,
											SourceAlt_Key	,
											SourceSystemMailID	,
											SourceSystemMailGroup	,
											SourceSystemMailSubGroup	,
											SourceSystemMailSegment	,
											SourceSystemMailValidCode	,
											AuthorisationStatus	,
											EffectiveFromTimeKey	,
											EffectiveToTimeKey	,
											CreatedBy	,
											DateCreated	,
											ModifiedBy	,
											DateModified	,
											ApprovedBy	,
											DateApproved	,
											D2Ktimestamp	,
											ApprovedByFirstLevel	,
											DateApprovedFirstLevel	
								FROM DimSourceSystemMail_MOD
								WHERE isnull(AuthorisationStatus,'A')='A'
										AND SourceSystemMailID=@SourceSystemMailID 
										AND SourceAlt_Key=(SELECT DISTINCT SourceAlt_Key FROM DIMSOURCESYSTEM WHERE SourceName=@SourceName )
										AND SourceSystemMailValidCode in ('Y','N')
										AND EffectiveFromTimeKey<=@TIMEKEY
										AND EffectiveToTimeKey>=@TIMEKEY
										AND CreatedBy<>@USERLOGINID
										AND ApprovedByFirstLevel<>@USERLOGINID
					
					/*EXPIRE IN MOD ON 20250422 BY ZAIN*/

					UPDATE DimSourceSystemMail_MOD SET EffectiveToTimeKey=@TIMEKEY-1
									WHERE AuthorisationStatus='A'
									AND SourceSystemMailID=@SourceSystemMailID 
									AND SourceAlt_Key=(SELECT DISTINCT SourceAlt_Key FROM DIMSOURCESYSTEM WHERE SourceName=@SourceName )
										--AND SourceSystemMailValidCode='D'-- FOR DELETE RECORDS HAVING 'D' STATUS ON 20250422 BY ZAIN
										AND EffectiveFromTimeKey<=@TIMEKEY
										AND EffectiveToTimeKey>=@TIMEKEY
										--AND CreatedBy<>@USERLOGINID
										--AND ApprovedByFirstLevel<>@USERLOGINID

					/*EXPIRE IN MOD ON 20250422 BY ZAIN END*/
			END
		END
					/*UPDATE IN MAIN*/
				IF @SourceSystemMailID IN (SELECT SourceSystemMailID FROM DimSourceSystemMail WHERE 
										EffectiveFromTimeKey<=@TIMEKEY
										AND EffectiveToTimeKey>=@TIMEKEY
										)
						AND @SourceSystemMailID<>'D'
						BEGIN
						UPDATE DimSourceSystemMail SET SourceSystemMailValidCode=@SourceSystemMailValidCode,
														ModifiedBy=@USERLOGINID,
														DateModified=(SELECT convert(varchar, getdate(), 121))
								WHERE SourceSystemMailID=@SourceSystemMailID
								AND isnull(SourceSystemMailValidCode,'N')<>'D'
								AND SourceAlt_Key=(SELECT DISTINCT SourceAlt_Key FROM DIMSOURCESYSTEM WHERE SourceName=@SourceName )
									AND	EffectiveFromTimeKey<=@TIMEKEY
										AND EffectiveToTimeKey>=@TIMEKEY		
						END

		/*UPDATING AUTHORISATION STATUS R*/
		ELSE IF @OPERATIONFLAG=21
			
					BEGIN
						SET @Result1=1	
								UPDATE DimSourceSystemMail_MOD SET AUTHORISATIONSTATUS='R',
																	ApprovedBy=@USERLOGINID,
																	DateApproved=(SELECT convert(varchar, getdate(), 121)),
																	EffectiveToTimeKey=@TIMEKEY-1
									WHERE AuthorisationStatus='1A'
									AND SourceSystemMailID=@SourceSystemMailID 
									AND SourceAlt_Key=(SELECT DISTINCT SourceAlt_Key FROM DIMSOURCESYSTEM WHERE SourceName=@SourceName )
										--AND SourceSystemMailValidCode='Y' COMMENTED FOR INACTIVE AND DELETE RECORDS HAVING 'D,N' STATUS ON 20250422 BY ZAIN
										AND EffectiveFromTimeKey<=@TIMEKEY
										AND EffectiveToTimeKey>=@TIMEKEY
										--AND CreatedBy<>@USERLOGINID
										--AND ApprovedByFirstLevel<>@USERLOGINID
					END
		
	RETURN @Result1 		
END


GO