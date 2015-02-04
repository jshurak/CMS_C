CREATE PROCEDURE [dbo].[MonitoredAvailabilityGroups_SetGroups]
@AGName varchar(128) = null,
@AGGuid varchar(36),
@Deleted bit = 0
AS
BEGIN
	DECLARE @InstanceID int, @AvailabilityGroupID int,@PreviousRole varchar(9),@DatabaseID int,@DatabaseName varchar(128)
	
	IF NOT EXISTS(SELECT TOP 1 AvailabilityGroupID FROM MonitoredAvailabilityGroups WHERE AvailabilityGroupGUID = @AGGuid)
		INSERT INTO MonitoredAvailabilityGroups (AvailabilityGroupName,AvailabilityGroupGUID,DateCreated,DateUpdated,deleted) VALUES (@AGName,@AGGuid,GETDATE(),GETDATE(),0)
	ELSE IF @Deleted = 1
		BEGIN
			SELECT @AvailabilityGroupID = AvailabilityGroupID FROM MonitoredAvailabilityGroups WHERE AvailabilityGroupGUID = @AGGuid
			UPDATE MonitoredAvailabilityGroups
			SET 
				Deleted = 1,
				DateDeleted = GETDATE()
			WHERE 
				AvailabilityGroupGUID = @AGGuid

			UPDATE MonitoredAvailabilityGroupReplicas
			SET 
				Deleted = 1,
				DateDeleted = GETDATE()
			WHERE
				AvailabilityGroupID = @AvailabilityGroupID
			AND Deleted = 0

			UPDATE MonitoredAvailabilityGroupDBDetails
			SET
				Deleted = 1,
				DateDeleted = GETDATE()
			WHERE
				AvailabilityGroupID = @AvailabilityGroupID
			AND Deleted = 0

			UPDATE MonitoredAvailabilityGroupListeners
			SET
				Deleted = 1,
				DateDeleted = GETDATE()
			WHERE
				AvailabilityGroupID = @AvailabilityGroupID
			AND Deleted = 0				
		END
	ELSE
		UPDATE MonitoredAvailabilityGroups
		SET 
			AvailabilityGroupName = @AGName,
			DateUpdated = getdate()
		WHERE AvailabilityGroupGUID = @AGGuid
END
