CREATE PROCEDURE [dbo].[MonitoredPerfCounters_SetCounters]
@CollectionDate datetime
,@ServerID int = null
,@InstanceID int = null
,@CounterName varchar(250)
,@Value DECIMAL (30,15)
,@Type varchar(10)
AS
BEGIN
	DECLARE @CounterID smallint
	
	SELECT @CounterID = CounterID
	FROM dbo.PerfCounters
	WHERE CounterName = @CounterName

	IF @CounterID IS NOT NULL
		BEGIN
			IF @Type = 'server'
				IF (SELECT COALESCE(DATEDIFF(second,MAX(collectionDate),getdate()),301)
  FROM [dbo].[MonitoredServerPerfCounters]
  where ServerID = @ServerID and CounterID = @CounterID) > 300
					INSERT INTO MonitoredServerPerfCounters VALUES (@CollectionDate,@ServerID,@CounterID,@Value)
			IF @Type = 'instance'
				INSERT INTO MonitoredInstancePerfCounters VALUES (@CollectionDate,@InstanceID,@CounterID,@Value)
		END
END
