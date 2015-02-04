CREATE PROCEDURE [dbo].[Alert_Blocking]
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @InstanceID INT,@Spid SMALLINT,@LoginName varchar(128),@Duration int,@StartCollectionTime DATETIME, @PageCount INT, @LastPageDate DATETIME, @PageThreshold INT,@PageDate DATETIME,@BlockingID BIGINT
	DECLARE @Message VARCHAR(MAX),@ServerName varchar(128),@InstanceName varchar(128),@DatabaseName varchar(128),@SQLStatement varchar(max),@Command varchar(16),@ProgramName varchar(128)
	IF EXISTS(SELECT TOP 1 CB.InstanceID from CurrentBlocking CB JOIN dbo.MonitoredBlocking MB ON CB.BlockingID = MB.BlockingID WHERE MB.DatabaseName <> 'distribution')
		BEGIN
			SET @Message = ''

			SELECT CB.InstanceID,CB.CurrentBlockingSpid,MB.LoginName,MB.StartCollectionTime,DATEDIFF(ss,MB.StartCollectionTime,GETDATE()) AS [Duration],CB.PageCount,CB.LastPageDate,CB.BlockingID,MS.ServerName,MI.InstanceName,MB.DatabaseName,MB.SQLStatement,MB.Command,MB.ProgramName
			INTO #tmp
			FROM CurrentBlocking CB
			JOIN MonitoredBlocking MB
			ON CB.BlockingID = MB.BlockingID
			JOIN MonitoredInstances MI
			ON MI.InstanceID = MB.InstanceID
			JOIN MonitoredServers MS
			ON MS.ServerID = MI.ServerID
			WHERE MB.DatabaseName <> 'distribution'

			WHILE (SELECT COUNT(*) FROM #tmp) > 0
			BEGIN
				SELECT TOP 1
					@ServerName = ServerName,
					@InstanceName = InstanceName,
					@DatabaseName = DatabaseName,
					@SQLStatement = SQLStatement,
					@Command = Command,
					@Duration = Duration,
					@ProgramName = ProgramName,
					@InstanceID = InstanceID,
					@Spid = CurrentBlockingSpid,
					@LoginName = LoginName,
					@StartCollectionTime = StartCollectionTime,
					@PageCount = [PageCount],
					@LastPageDate = LastPageDate,
					@BlockingID = BlockingID
				FROM #tmp

				SELECT @PageThreshold = C.PageThresholdMinutes
				FROM CriticalityMatrix C
				JOIN MonitoredInstances I
				ON I.Criticality = C.Criticality
				WHERE I.InstanceID = @InstanceID

				--Handle Initial Page
				SET @PageDate = GETDATE()
				IF @PageCount IS NULL AND DATEDIFF(mi,@StartCollectionTime,@PageDate) >= @PageThreshold
				BEGIN
					SET @Message = @Message + CHAR(13) + 'Server Name: ' + @ServerName + CHAR(13) + 'Instance Name: ' + @InstanceName + CHAR(13) + 'Session: ' + CAST(@Spid as varchar) + CHAR(13) + 'LoginName: ' + @LoginName + CHAR(13) + 'Duration: ' + CAST(@Duration AS VARCHAR) + CHAR(13) + 'Database Name: ' + @DatabaseName + CHAR(13) + 'Statement Type: ' + @Command + CHAR(13) + 'Program Name: ' + @ProgramName + CHAR(13) + 'SQL Statement: ' + @SQLStatement + CHAR(13)
					EXEC [dbo].[CMS_SendPage] @Body = @Message, @Category = 'BlockingReport',@PageCount = @PageCount,@Title = 'Blocking Report'
					
					UPDATE CurrentBlocking
					SET [PageCount] = 1
					,LastPageDate = @PageDate
					WHERE BlockingID = @BlockingID

					DELETE FROM #tmp
					WHERE BlockingID = @BlockingID
				END
				--Handle non first page
				ELSE IF @PageCount > 0 AND DATEDIFF(mi,@LastPageDate,@PageDate) >= @PageThreshold
				BEGIN
					SET @Message = @Message + CHAR(13) + 'Server Name: ' + @ServerName + CHAR(13) + 'Instance Name: ' + @InstanceName + CHAR(13) + 'Session: ' + CAST(@Spid as varchar) + CHAR(13) + 'LoginName: ' + @LoginName  + CHAR(13) + 'Duration: ' + CAST(@Duration AS VARCHAR) + CHAR(13)  + 'Database Name: ' + @DatabaseName + CHAR(13) + 'Statement Type: ' + @Command + CHAR(13) + 'Program Name: ' + @ProgramName + CHAR(13) + 'SQL Statement: ' + @SQLStatement + CHAR(13)
					EXEC [dbo].[CMS_SendPage] @Body = @Message, @Category = 'BlockingReport',@PageCount = @PageCount,@Title = 'Blocking Report'
					
					UPDATE CurrentBlocking
					SET [PageCount] = @PageCount + 1
					,LastPageDate = @PageDate
					WHERE BlockingID = @BlockingID

					DELETE FROM #tmp
					WHERE BlockingID = @BlockingID
				END
				ELSE
				BEGIN
					DELETE FROM #tmp
					WHERE BlockingID = @BlockingID
				END

			END
			DROP TABLE #tmp
		END
END
