CREATE PROCEDURE [dbo].[MonitoredDatabases_SetBackups]
@InstanceID INT,
@DatabaseGuid varchar(36),
@LastFullBackupDate DATETIME,
@LastDifferentialBackupDate DATETIME,
@LastLogBackupDate DATETIME,
@RecoveryModel varchar(25)
AS
BEGIN
	DECLARE @RecordDate DATETIME = GETDATE(),@CurrentRecoveryModel varchar(25),@DatabaseID int

	SELECT @DatabaseID = DatabaseID FROM dbo.MonitoredDatabases WHERE InstanceID = @InstanceID AND DatabaseGUID = @DatabaseGuid
	
	IF NOT EXISTS(SELECT TOP 1 BackupID FROM MonitoredDatabaseBackups WHERE DatabaseID = @DatabaseID and DATEDIFF(mi,BackupRecordDate,@RecordDate) <=1440)
		BEGIN
			INSERT INTO MonitoredDatabaseBackups (BackupRecordDate,DatabaseID,LastFullBackupDate,LastDifferentialBackupDate,LastLogBackupDate)
			VALUES (@RecordDate,@DatabaseID,@LastFullBackupDate,@LastDifferentialBackupDate,@LastLogBackupDate)
			
			SELECT @CurrentRecoveryModel = RecoveryModel 
			FROM MonitoredDatabases 
			WHERE DatabaseID = @DatabaseID
			
			IF(@CurrentRecoveryModel <> @RecoveryModel)
				UPDATE MonitoredDatabases
				SET RecoveryModel = @RecoveryModel
				WHERE DatabaseID = @DatabaseID
		END
	ELSE
		UPDATE MonitoredDatabaseBackups
		SET
			LastFullBackupDate = @LastFullBackupDate,
			LastDifferentialBackupDate = @LastDifferentialBackupDate,
			LastLogBackupDate = @LastLogBackupDate
		WHERE DatabaseID = @DatabaseID
		AND DATEDIFF(mi,BackupRecordDate,@RecordDate) < 1440

		SELECT @CurrentRecoveryModel = RecoveryModel 
		FROM MonitoredDatabases 
		WHERE DatabaseID = @DatabaseID
			
		IF(@CurrentRecoveryModel <> @RecoveryModel)
			UPDATE MonitoredDatabases
			SET RecoveryModel = @RecoveryModel
			WHERE DatabaseID = @DatabaseID
END
