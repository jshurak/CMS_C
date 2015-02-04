CREATE PROCEDURE [dbo].[MonitoredAvailabilityGroups_SetReplicas]
@AGGuid varchar(36),
@ParentName varchar(128),
@ReplicaName varchar(128) = null,
@ReplicaAvailabilityMode varchar(18) = null,
@FailoverMode varchar(10) = null,
@CurrentRole varchar(9) = null,
@SyncState varchar(13) = null,
@ReplicaGuid varchar(36),
@Deleted bit = 0
AS
BEGIN
	DECLARE @PreviousRole varchar(9),@InstanceID int,@AvailabilityGroupID int

	SELECT @InstanceID = InstanceID FROM MonitoredInstances WHERE InstanceName = @ParentName
	SELECT @AvailabilityGroupID = AvailabilityGroupID FROM MonitoredAvailabilityGroups WHERE AvailabilityGroupGUID = @AGGuid
	IF NOT EXISTS(SELECT TOP 1 ReplicaID FROM MonitoredAvailabilityGroupReplicas WHERE InstanceID = @InstanceID AND AvailabilityGroupID = @AvailabilityGroupID AND ReplicaGuid = @ReplicaGuid)
		INSERT INTO MonitoredAvailabilityGroupReplicas (AvailabilityGroupID,ReplicaName,InstanceID,AvailabilityMode,FailoverMode,CurrentRole,SynchronizationState,DateCreated,DateUpdated,Deleted,FailoverFlag,ReplicaGuid)
		VALUES (@AvailabilityGroupID,@ReplicaName,@InstanceID,@ReplicaAvailabilityMode,@FailoverMode,@CurrentRole,@SyncState,GETDATE(),GETDATE(),0,0,@ReplicaGuid)
	ELSE IF(@Deleted = 1)
		UPDATE MonitoredAvailabilityGroupReplicas
		SET
			Deleted = 1,
			DateDeleted = GETDATE()
		WHERE
			ReplicaGUID = @ReplicaGuid
			AND AvailabilityGroupID = @AvailabilityGroupID
	ELSE
	BEGIN
		SELECT @PreviousRole = CurrentRole FROM MonitoredAvailabilityGroupReplicas WHERE InstanceID = @InstanceID AND AvailabilityGroupID = @AvailabilityGroupID AND ReplicaGuid = @ReplicaGuid
		UPDATE MonitoredAvailabilityGroupReplicas
		SET
			ReplicaName = @ReplicaName,
			AvailabilityMode = @ReplicaAvailabilityMode,
			FailoverMode = @FailoverMode,
			CurrentRole = @CurrentRole,
			SynchronizationState = @SyncState,
			DateUpdated = GETDATE(),
			FailoverFlag = 
				CASE
					WHEN @PreviousRole = @CurrentRole THEN 0
					ELSE 1
				END
		WHERE InstanceID = @InstanceID
		AND AvailabilityGroupID = @AvailabilityGroupID
		AND ReplicaGuid = @ReplicaGuid
	END
END
