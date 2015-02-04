CREATE PROCEDURE [dbo].[MonitoredBlocking_GetBlocking]
@InstanceID INT
AS
	SELECT CurrentBlockingSpid,LastBatchTime
	FROM CurrentBlocking
	WHERE InstanceID = @InstanceID
