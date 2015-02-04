CREATE PROCEDURE [dbo].[MonitoredDrives_GetDrives]
  @ServerID int
  AS
  BEGIN
		SELECT DeviceID 
		FROM [dbo].[MonitoredDrives]
		WHERE ServerID = @ServerID
		AND Deleted = 0
  END
