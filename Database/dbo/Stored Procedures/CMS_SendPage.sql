CREATE PROCEDURE [dbo].[CMS_SendPage]
@Body varchar(max)
,@Category varchar(28)
,@Title varchar(128)
,@PageCount int = 1
,@MaxTries tinyint = 2
,@HTML bit = 0
,@Type varchar(20) = 'Report'
AS
BEGIN
	DECLARE @rc int = 1
	DECLARE @RetryCnt tinyint = 0
	DECLARE @Receiver varchar(128)
	DECLARE @OperatorID int 
	DECLARE @PageDate Datetime
	DECLARE @PageStatus varchar(28)

	CREATE TABLE #tmp (id int, email_address nvarchar(100))

	IF @Type = 'Page'
		INSERT INTO #tmp
		SELECT so.id,
		so.email_address
		from msdb.dbo.sysoperators so
		JOIN CMS.dbo.Alerts_Operators ao
		on so.id = ao.OperatorID
		WHERE ao.OnDuty = 1
	ELSE IF @Type = 'Report'
		INSERT INTO #tmp
		SELECT s.operatorid, so.email_address
		FROM Reporting.Reports e
		JOIN Reporting.Subscriptions s
		ON e.reportid = s.reportid
		JOIN msdb..sysoperators so
		ON s.operatorid = so.id
		WHERE ReportName = @Category

	WHILE (SELECT COUNT(*) FROM #tmp) > 0
	BEGIN
	SELECT top 1
			@OperatorID = id,
			@Receiver = email_address
	FROM #tmp
	Set @rc = 1
		WHILE @rc <> 0 AND @RetryCnt < @MaxTries
		BEGIN	
			SET @PageDate = GETDATE()
				IF @HTML = 1
			 		EXECUTE @rc = msdb.dbo.sp_send_dbmail 
							@Profile_Name = 'MS SQL Mail',
							@Subject = @Title,
							@Recipients = @Receiver,
							@Body = @Body,
							@Body_Format = 'HTML'
				ELSE
					EXECUTE @rc = msdb.dbo.sp_send_dbmail 
							@Profile_Name = 'MS SQL Mail',
							@Subject = @Title,
							@Recipients = @Receiver,
							@Body = @Body
			SET @RetryCnt += 1
		END
		IF @rc = 0 
			SET @PageStatus = 'SENT'
		ELSE
			SET @PageStatus = 'FAIL'

		INSERT INTO Alert_PageRecords VALUES (@OperatorID,@Category,@PageDate,@PageStatus,@PageCount,@RetryCnt)
	DELETE FROM #tmp WHERE id = @OperatorID
	
	END
	DROP TABLE #tmp

END
