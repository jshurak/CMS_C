CREATE PROCEDURE [dbo].[MonitoredAvailabilityGroups_SetListeners]
@AGGuid varchar(36),
@ListenerName varchar(128) = null,
@ListenerGUID varchar(36) = null,
@ListenerIPAddress varchar(15) = null,
@ListenerIPState varchar(16) = null,
@ListenerPort varchar(10) = null,
@Deleted bit = null
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @AvailabilityGroupID INT
	SELECT @AvailabilityGroupID = AvailabilityGroupID FROM MonitoredAvailabilityGroups WHERE AvailabilityGroupGUID = @AGGuid

	IF NOT EXISTS(SELECT TOP 1 ListenerID FROM MonitoredAvailabilityGroupListeners WHERE [AvailabilityGroupID] = @AvailabilityGroupID)
		INSERT INTO MonitoredAvailabilityGroupListeners (ListenerName,ListenerGUID,ListenerIPAddress,ListenerIPState,ListenerPort,DateCreated,DateUpdated,Deleted,[AvailabilityGroupID])
		VALUES (@ListenerName,@ListenerGUID,@ListenerIPAddress,@ListenerIPState,@ListenerPort,GETDATE(),GETDATE(),0,@AvailabilityGroupID)
	ELSE IF @Deleted = 1
		UPDATE MonitoredAvailabilityGroupListeners
		SET
			Deleted = 1,
			DateDeleted = GETDATE()
		WHERE
			ListenerGUID = @ListenerGUID		
	ELSE
		UPDATE MonitoredAvailabilityGroupListeners
		SET
			ListenerName = @ListenerName,
			ListenerIPAddress = @ListenerIPAddress,
			ListenerIPState = @ListenerIPState,
			ListenerPort = @ListenerPort,
			DateUpdated = GETDATE()
		WHERE 
			ListenerGUID = @ListenerGUID
END
