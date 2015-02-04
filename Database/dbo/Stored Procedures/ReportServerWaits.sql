CREATE PROCEDURE [dbo].[ReportServerWaits]
@InstanceName varchar(128) = null
,@StartTime datetime = NULL
,@EndTime datetime = NULL
,@Top int = NULL
,@OrderBy varchar(25) = NULL
,@Help bit = 0
AS
BEGIN
	IF @InstanceName IS NULL AND @Help = 0
	BEGIN
		PRINT 'Please enter InstanceName or use @help = 1 parameter'
		RETURN
	END
	IF @InstanceName IS NOT NULL
	BEGIN
		DECLARE @InstanceID int = (SELECT InstanceID FROM MonitoredInstances where InstanceName = @InstanceName)
		DECLARE @Msg nvarchar(500)
		IF @Top IS NULL
			SET @Top = 10
		IF @OrderBy IS NULL
			SET @OrderBy = 'WaitTimeMS'
		IF @InstanceID IS NOT NULL
			IF @OrderBy IS NULL
				SET @OrderBy = 'WaitTimeMS'
			IF @StartTime IS NOT NULL AND @EndTime IS NOT NULL
				BEGIN
					SELECT @StartTime = MIN(CollectionDate)
					FROM [dbo].[MonitoredInstanceServerWaits]
					where instanceid = @InstanceID and CollectionDate >= @StartTime
					group by InstanceID;
	
					SELECT @EndTime = MAX(CollectionDate)
					FROM [dbo].[MonitoredInstanceServerWaits]
					where instanceid = @InstanceID and CollectionDate <= @EndTime
					group by InstanceID;
	
				select top (@Top) InstanceName
					,WaitType
					,t2.Waiting_Task_Count - t1.Waiting_Task_Count as WaitingTaskCount
					,t2.Wait_Time_MS - t1.Wait_Time_MS as WaitTimeMS
					,t2.Signal_Wait_Time_MS - t1.Signal_Wait_Time_MS as SignalWaitTimeMS
						,(t2.Wait_Time_MS - t1.Wait_Time_MS) -(t2.Signal_Wait_Time_MS - t1.Signal_Wait_Time_MS) as ResourceWaitTimeMS
						,CAST((100.0 * (t2.[wait_time_ms]-t1.[Wait_Time_MS]) / SUM ((t2.[wait_time_ms]-t1.[Wait_Time_MS])) OVER()) as Decimal(5,2)) AS [Percentage]
				FROM [dbo].[MonitoredInstanceServerWaits] t1
				INNER JOIN [dbo].[MonitoredInstanceServerWaits] t2 ON t1.InstanceID = t2.InstanceID AND t1.WaitID = t2.WaitID
				INNER JOIN MonitoredInstances mi ON t1.InstanceID = mi.InstanceID
				INNER JOIN ServerWaits sw on t1.WaitID = sw.WaitID
				WHERE t1.InstanceID = @InstanceID
				AND t1.CollectionDate = @StartTime
				AND t2.CollectionDate = @EndTime
				ORDER BY WaitTimeMS desc
				END
			ELSE IF @StartTime IS NULL OR @EndTime IS NULL
			BEGIN
				SELECT @EndTime = MAX(CollectionDate)
					FROM [dbo].[MonitoredInstanceServerWaits]
					where instanceid = @InstanceID and CollectionDate <= getdate()
					group by InstanceID;

				select top (@Top) InstanceName
					,WaitType
					,t1.Waiting_Task_Count as WaitingTaskCount
					,t1.Wait_Time_MS as WaitTimeMS
					,t1.Signal_Wait_Time_MS as SignalWaitTimeMS
						,(t1.Wait_Time_MS) -(t1.Signal_Wait_Time_MS) as ResourceWaitTimeMS
						,CAST((100.0 * (t1.[Wait_Time_MS]) / SUM ((t1.[Wait_Time_MS])) OVER()) as Decimal(5,2)) AS [Percentage]
				FROM [dbo].[MonitoredInstanceServerWaits] t1
				INNER JOIN MonitoredInstances mi ON t1.InstanceID = mi.InstanceID
				INNER JOIN ServerWaits sw on t1.WaitID = sw.WaitID
				WHERE t1.InstanceID = @InstanceID
				AND t1.CollectionDate = @EndTime
				ORDER BY WaitTimeMS DESC;
			END
		ELSE 
			SET @Msg = 'Instance not found: ' + @InstanceName
			RAISERROR (@Msg, 0, 1) WITH NOWAIT
	
	END
	IF @Help = 1
		PRINT N'dbo.ReportServerWaits' + CHAR(13) + 'Author: J.Shurak' + char(13) + 'Description: Returns Server wait information for specified Instance' + char(13) + 'Parameters:' + CHAR(13) + CHAR(9) + '@InstanceName (varchar(128)) - InstanceName to report' + CHAR(13) + CHAR(9) + '@StartTime (datetime) - Used to specify a start date for report' + CHAR(13) + CHAR(9) + '@EndTime (datetime) - Used to specify a end date for report' + CHAR(13) + CHAR(9) + '@Top (int) - Used to specify the number of rows to return. Default is 10' + CHAR(13) + CHAR(9) + '@OrderBy (varchar(25)) - Used to specify the order by. Default is WaitTimeMS'
END
