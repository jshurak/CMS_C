CREATE PROCEDURE [dbo].[Purge_CMS]
AS
	DECLARE @Purge_Value int, @LogID bigint
	DECLARE @Table varchar(30),@hPurge_Value varchar(5)
	DECLARE @SQL varchar(max)


		SET @Table = 'CollectionLog'
		SELECT @Purge_Value = IntValue
		FROM Config
		WHERE Setting = 'CollectionLog - Cleanup Days'
	
		SET @Purge_Value = '-' + cast(@Purge_Value as varchar)

		INSERT INTO CollectionLog (ModuleName,StartTime) VALUES ('Purge_CMS - ' + @Table,GETDATE())
		SELECT @LogID = SCOPE_IDENTITY()

		DELETE FROM CollectionLog
		WHERE StartTime < DATEADD(DAY,@Purge_Value,GETDATE())

		UPDATE CollectionLog
		SET EndTime = GETDATE()
		WHERE LogID = @LogID
	


		SELECT @Purge_Value = CAST(IntValue AS VARCHAR(5))
		FROM Config
		WHERE Setting = 'History Schema - Cleanup Days'

	
		SET @Purge_Value = '-' + cast(@Purge_Value as varchar)

		INSERT INTO CollectionLog (ModuleName,StartTime) VALUES ('Purge_CMS - History.MonitoredDatabaseFiles',GETDATE())
		SELECT @LogID = SCOPE_IDENTITY()

		DELETE FROM History.MonitoredDatabaseFiles
		WHERE HistoryDate < DATEADD(DAY,@Purge_Value,GETDATE())

		UPDATE CollectionLog
		SET EndTime = GETDATE()
		WHERE LogID = @LogID

		INSERT INTO CollectionLog (ModuleName,StartTime) VALUES ('Purge_CMS - History.MonitoredDatabases',GETDATE())
		SELECT @LogID = SCOPE_IDENTITY()

		DELETE FROM History.MonitoredDatabases
		WHERE HistoryDate < DATEADD(DAY,@Purge_Value,GETDATE())

		UPDATE CollectionLog
		SET EndTime = GETDATE()
		WHERE LogID = @LogID
	
		INSERT INTO CollectionLog (ModuleName,StartTime) VALUES ('Purge_CMS - History.MonitoredDrives',GETDATE())
		SELECT @LogID = SCOPE_IDENTITY()

		DELETE FROM History.MonitoredDrives
		WHERE HistoryDate < DATEADD(DAY,@Purge_Value,GETDATE())

		UPDATE CollectionLog
		SET EndTime = GETDATE()
		WHERE LogID = @LogID

		INSERT INTO CollectionLog (ModuleName,StartTime) VALUES ('Purge_CMS - History.MonitoredInstanceJobs',GETDATE())
		SELECT @LogID = SCOPE_IDENTITY()

		DELETE FROM History.MonitoredInstanceJobs
		WHERE HistoryDate < DATEADD(DAY,@Purge_Value,GETDATE())

		UPDATE CollectionLog
		SET EndTime = GETDATE()
		WHERE LogID = @LogID

		INSERT INTO CollectionLog (ModuleName,StartTime) VALUES ('Purge_CMS - History.MonitoredInstances',GETDATE())
		SELECT @LogID = SCOPE_IDENTITY()

		DELETE FROM History.MonitoredInstances
		WHERE HistoryDate < DATEADD(DAY,@Purge_Value,GETDATE())

		UPDATE CollectionLog
		SET EndTime = GETDATE()
		WHERE LogID = @LogID
		
		INSERT INTO CollectionLog (ModuleName,StartTime) VALUES ('Purge_CMS - History.MonitoredServers',GETDATE())
		SELECT @LogID = SCOPE_IDENTITY()

		DELETE FROM History.MonitoredServers
		WHERE HistoryDate < DATEADD(DAY,@Purge_Value,GETDATE())

		UPDATE CollectionLog
		SET EndTime = GETDATE()
		WHERE LogID = @LogID
RETURN 0
