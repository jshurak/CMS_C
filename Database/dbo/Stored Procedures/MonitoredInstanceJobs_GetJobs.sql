CREATE PROCEDURE [dbo].[MonitoredInstanceJobs_GetJobs]
@InstanceID int
AS
BEGIN
	SELECT JobName, JobGUID
	FROM MonitoredInstanceJobs
	WHERE InstanceID = @InstanceID
	AND Deleted = 0
END
