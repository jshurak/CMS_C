CREATE PROCEDURE [dbo].[MonitoredDatabaseFiles_SetDriveID]
@DatabaseFileID int
AS
BEGIN
	SET NOCOUNT ON


	DECLARE @ServerID int,@DriveID int, @MP varchar(60), @len int, @sub varchar(60)


	SELECT @ServerID = serverID
	FROM MonitoredDatabaseFiles mdf
	JOIN MonitoredDatabases md
	ON mdf.DatabaseID = md.DatabaseID
	WHERE DatabaseFileID = @DatabaseFileID

	SELECT ServerID,DriveID,MountPoint
	INTO #TMP
	FROM MonitoredDrives
	WHERE ServerID = @ServerID

	WHILE (SELECT COUNT(*) FROM #TMP) > 0
	BEGIN
		SELECT TOP 1
			 @MP = MountPoint,
			 @DriveID = DriveID
		FROM #TMP
		SELECT @len = LEN(@MP)


		SELECT @sub = SUBSTRING(Directory,1,@len) FROM MonitoredDatabaseFiles where DatabaseFileID = @DatabaseFileID
		IF @sub = @MP
		BEGIN
			UPDATE MonitoredDatabaseFiles
			SET DriveID = @DriveID
			WHERE DatabaseFileID = @DatabaseFileID
			TRUNCATE TABLE #TMP
		END
		ELSE
			DELETE FROM #TMP WHERE MountPoint = @MP
	END

	drop table #TMP
END
