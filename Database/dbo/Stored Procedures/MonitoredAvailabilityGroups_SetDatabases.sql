CREATE PROCEDURE [dbo].[MonitoredAvailabilityGroups_SetDatabases]
@AGGuid varchar(36) = NULL,
@DatabaseGuid varchar(36) = null,
@AGDBGuid varchar(36),
@IsFailoverReady bit = null,
@SyncState varchar(13) = null,
@ReplicaName varchar(128) = null,
@InstanceID int = null,
@Deleted bit = null
AS
BEGIN
	DECLARE @DatabaseID int, @AvailabilityGroupID int,@DatabaseName varchar(128),@ReplicaID int
	
	SELECT @AvailabilityGroupID = AvailabilityGroupID FROM MonitoredAvailabilityGroups WHERE AvailabilityGroupGUID = @AGGuid
	SELECT @ReplicaID = ReplicaID FROM MonitoredAvailabilityGroupReplicas where ReplicaName = @ReplicaName AND AvailabilityGroupID = @AvailabilityGroupID AND InstanceID = @InstanceID
	SELECT 
		@DatabaseID = DatabaseID,
		@DatabaseName = DatabaseName
		FROM MonitoredDatabases WHERE InstanceID = @InstanceID  AND DatabaseGUID = @DatabaseGuid

	IF NOT EXISTS (SELECT TOP 1 DetailID FROM MonitoredAvailabilityGroupDBDetails WHERE AvailabilityGroupID = @AvailabilityGroupID AND AGDatabaseGuid = @AGDBGuid)
		INSERT INTO MonitoredAvailabilityGroupDBDetails(DatabaseID,DatabaseName,IsFailOverReady,SynchronizationState,DateCreated,DateUpdated,Deleted,AGDatabaseGUID,AvailabilityGroupID,ReplicaID)
		VALUES (@DatabaseID,@DatabaseName,@IsFailoverReady,@SyncState,GETDATE(),GETDATE(),0,@AGDBGuid,@AvailabilityGroupID,@ReplicaID)
	ELSE IF @Deleted = 1
		BEGIN
			UPDATE MonitoredAvailabilityGroupDBDetails
			SET 
				Deleted = 1,
				DateDeleted = GETDATE()
			WHERE
				AGDatabaseGuid = @AGDBGuid
		END
	ELSE
		BEGIN
			UPDATE MonitoredAvailabilityGroupDBDetails
			SET
				DatabaseID = @DatabaseID,
				DatabaseName = @DatabaseName,
				IsFailoverReady = @IsFailoverReady,
				SynchronizationSTate = @SyncState,
				DateUpdated = GETDATE(),
				ReplicaID = @ReplicaID
			WHERE
				AvailabilityGroupID = @AvailabilityGroupID
			AND AGDatabaseGuid = @AGDBGuid

			UPDATE md
			SET md.AvailabilityGroupID = g.AvailabilityGroupID
			FROM MonitoredDatabases md
			JOIN MonitoredAvailabilityGroupDBDetails gdb
			ON md.DatabaseName = gdb.DatabaseName
			JOIN MonitoredAvailabilityGroups g
			ON gdb.AvailabilityGroupID = g.AvailabilityGroupID
			WHERE g.AvailabilityGroupID = @AvailabilityGroupID
			AND gdb.DatabaseName = @DatabaseName
		END
END
