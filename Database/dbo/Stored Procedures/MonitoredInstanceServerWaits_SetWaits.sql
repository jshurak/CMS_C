CREATE PROCEDURE [dbo].[MonitoredInstanceServerWaits_SetWaits]
@InstanceID int
,@WaitType nvarchar(60)
,@Waiting_Task_Count bigint
,@Wait_Time_MS bigint
,@Max_Wait_Time_MS bigint
,@Signal_Wait_Time_MS bigint
,@CollectionDate datetime
AS
BEGIN
	DECLARE @WaitID int
	SELECT @WaitID = WaitID
	FROM ServerWaits 
	WHERE WaitType = @WaitType 
	AND Capture = 1

	IF @WaitID IS NOT NULL AND @Waiting_Task_Count > 0 AND @Wait_Time_MS > 0 AND @Max_Wait_Time_MS > 0 AND @Signal_Wait_Time_MS > 0
	BEGIN
		INSERT INTO MonitoredInstanceServerWaits VALUES (@InstanceID,@WaitID,@Waiting_Task_Count,@Wait_Time_MS,@Max_Wait_Time_MS,@Signal_Wait_Time_MS,@CollectionDate)
	END
END
