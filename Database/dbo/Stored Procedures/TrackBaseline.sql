CREATE PROCEDURE [dbo].[TrackBaseline]
AS
BEGIN
	DECLARE @BaseLength int
	SELECT @BaseLength = intValue
	FROM [dbo].[config]
	where Setting = 'Baseline - length Days'

	IF OBJECT_ID('tempdb..#ServerDates') IS NOT NULL
		DROP TABLE #ServerDates

	IF OBJECT_ID('tempdb..#InstancePerfDates') IS NOT NULL
		DROP TABLE #InstancePerfDates

	IF OBJECT_ID('tempdb..#InstanceWaitDates') IS NOT NULL
		DROP TABLE #InstanceWaitDates


	select ms.ServerID, COALESCE(Min(CollectionDate),'1900-01-01') as MinDate, COALESCE(MAX(Collectiondate), '1900-01-01') as MaxDate
	INTO #ServerDates
	from dbo.MonitoredServers ms 
	LEFT OUTER JOIN baseline.MonitoredServerPerfCounters c ON  c.ServerID = ms.ServerID
	WHERE ms.ServerID is NOT null
	and ms.Deleted = 0
	group by ms.serverid


	select mi.InstanceID, COALESCE(Min(CollectionDate),'1900-01-01') as MinDate, COALESCE(MAX(Collectiondate), '1900-01-01') as MaxDate
	INTO #InstancePerfDates
	from dbo.MonitoredInstances mi
	LEFT OUTER JOIN baseline.MonitoredInstancePerfCounters c ON  mi.InstanceID = c.InstanceID
	WHERE mi.InstanceID is NOT null
	and mi.Deleted = 0
	group by mi.InstanceID

	select mi.InstanceID,COALESCE(Min(CollectionDate),'1900-01-01') as MinDate, COALESCE(MAX(Collectiondate), '1900-01-01') as MaxDate
	INTO #InstanceWaitDates
	FROM MonitoredInstances mi
	LEFT OUTER JOIN Baseline.MonitoredInstanceServerWaits w ON mi.InstanceID = w.InstanceID
	WHERE mi.InstanceID IS NOT NULL
	AND mi.Deleted = 0
	group by mi.InstanceID

---Check to see if BaseLength has changes since setting the HasBaseline value.  If it has, set HasBaseline back to 0 to record new length

	MERGE dbo.MonitoredServers t
	USING (
	SELECT mspf.ServerID, max(CollectionDate) AS MaxDate
	FROM baseline.monitoredServerPerfCounters mspf
	INNER JOIN dbo.MonitoredServers ms ON mspf.ServerID = ms.ServerID
	WHERE ms.HasBaseline = 1 
	GROUP BY mspf.ServerID,ms.BaselineStartDate
	HAVING max(CollectionDate) <= DATEADD(day,@BaseLength,ms.BaselineStartDate)
	) s ON (t.ServerID = s.ServerID)
	WHEN MATCHED THEN
		UPDATE SET t.HasBaseline = 0;

	MERGE dbo.MonitoredInstances t
	USING (
	SELECT mspf.InstanceID, max(CollectionDate) AS MaxDate
	FROM baseline.monitoredInstancePerfCounters mspf
	INNER JOIN dbo.MonitoredInstances ms ON mspf.InstanceID = ms.InstanceID
	WHERE ms.HasBaseline = 1 
	GROUP BY mspf.InstanceID,ms.BaselineStartDate
	HAVING max(CollectionDate) <= DATEADD(day,@BaseLength,ms.BaselineStartDate)
	) s ON (t.InstanceID = s.InstanceID)
	WHEN MATCHED THEN
		UPDATE SET t.HasBaseline = 0;

	MERGE dbo.MonitoredInstances t
	USING (
	SELECT misw.InstanceID, max(CollectionDate) AS MaxDate
	FROM baseline.monitoredInstanceServerWaits misw
	INNER JOIN dbo.MonitoredInstances ms ON misw.InstanceID = ms.InstanceID
	WHERE ms.HasWaitsBaseline = 1 
	GROUP BY misw.InstanceID,ms.WaitsBaselineStartDate
	HAVING max(CollectionDate) <= DATEADD(day,@BaseLength,ms.WaitsBaselineStartDate)
	) s ON (t.InstanceID = s.InstanceID)
	WHEN MATCHED THEN
		UPDATE SET t.HasWaitsBaseline = 0;


	--set baselinestartdate
	MERGE [dbo].[MonitoredServers] AS target
	USING (
		SELECT mspc.ServerID,MIN(mspc.CollectionDate) as CollectionDate
		FROM [dbo].[MonitoredServerPerfCounters] mspc 
		INNER JOIN [dbo].[MonitoredServers] ms ON mspc.ServerID = ms.ServerID
		WHERE ms.Deleted = 0 AND ms.BaselineStartDate IS NULL
		GROUP by mspc.ServerID) AS source(ServerID,CollectionDate)
	ON (target.ServerID = source.ServerID)
	WHEN MATCHED THEN
		UPDATE SET BaselineStartDate = source.CollectionDate;

	--insert values between baseline dates
	MERGE [Baseline].[MonitoredServerPerfCounters] as t
	USING(
	SELECT mspc.CollectionDate,mspc.ServerID,mspc.CounterID,mspc.Value
	FROM [dbo].[MonitoredServerPerfCounters] mspc
	INNER JOIN #ServerDates ON mspc.ServerID = #ServerDates.ServerID
	INNER JOIN [dbo].[MonitoredServers] ms on mspc.ServerID = ms.ServerID
	WHERE mspc.CollectionDate >= #ServerDates.MaxDate and mspc.CollectionDate <= CAST(DATEADD(day,@BaseLength + 1,BaseLineStartDate) AS date)
	AND ms.HasBaseline = 0
	AND ms.Deleted = 0
	) AS s (CollectionDate,ServerID,CounterID,Value)
	ON (t.CollectionDate = s.CollectionDate AND t.ServerID = s.ServerID)
	WHEN NOT MATCHED THEN
		INSERT (CollectionDate,ServerID,CounterID,Value) VALUES (s.CollectionDate,s.ServerID,s.CounterID,s.Value);

	--update hasbaseline if baseline is complete
	MERGE [dbo].[MonitoredServers] t
	USING(
	SELECT b.ServerID, MIN(b.CollectionDate) AS StartDate, Max(b.CollectionDate) AS EndDate
	FROM [Baseline].[MonitoredServerPerfCounters] b
	INNER JOIN [dbo].[MonitoredServers] ms ON B.ServerID = ms.ServerID
	WHERE ms.HasBaseline = 0
	AND ms.BaseLineStartDate IS NOT NULL
	GROUP BY b.ServerID
	) as s (ServerID,StartDate,EndDate)
	ON (s.ServerID = t.ServerID AND s.StartDate = t.BaseLineStartDate AND DATEDIFF(day,s.StartDate,s.enddate) >= @BaseLength)
	WHEN MATCHED THEN
		UPDATE SET t.HasBaseline = 1;


--Baseline Instance Perf Counters
--set baselinestartdate
	MERGE [dbo].MonitoredInstances AS target
	USING (
		SELECT mipc.InstanceID,MIN(mipc.CollectionDate) as CollectionDate
		FROM [dbo].[MonitoredInstancePerfCounters] mipc 
		INNER JOIN [dbo].MonitoredInstances mi ON mipc.InstanceID = mi.InstanceID
		WHERE mi.Deleted = 0 AND mi.BaselineStartDate IS NULL
		GROUP by mipc.InstanceID) AS source(InstanceID,CollectionDate)
	ON (target.InstanceID = source.InstanceID)
	WHEN MATCHED THEN
		UPDATE SET BaselineStartDate = source.CollectionDate;

	--insert values between baseline dates
	MERGE [Baseline].[MonitoredInstancePerfCounters] as t
	USING(
	SELECT mipc.CollectionDate,mipc.InstanceID,mipc.CounterID,mipc.Value
	FROM [dbo].[MonitoredInstancePerfCounters] mipc
	INNER JOIN #InstancePerfDates ipd ON mipc.InstanceID = ipd.InstanceID
	INNER JOIN [dbo].[MonitoredInstances] ms on mipc.InstanceID = ms.InstanceID
	WHERE mipc.CollectionDate >= ipd.MaxDate and mipc.CollectionDate <= CAST(DATEADD(day,@BaseLength + 1,BaseLineStartDate) AS date)
	AND ms.HasBaseline = 0
	AND ms.Deleted = 0
	) AS s (CollectionDate,InstanceID,CounterID,Value)
	ON (t.CollectionDate = s.CollectionDate AND t.InstanceID = s.InstanceID)
	WHEN NOT MATCHED THEN
		INSERT (CollectionDate,InstanceID,CounterID,Value) VALUES (s.CollectionDate,s.InstanceID,s.CounterID,s.Value);


	--update hasbaseline if baseline is complete
	MERGE [dbo].MonitoredInstances t
	USING(
	SELECT b.InstanceID, MIN(b.CollectionDate) AS StartDate, Max(b.CollectionDate) AS EndDate
	FROM [Baseline].[MonitoredInstancePerfCounters] b
	INNER JOIN [dbo].MonitoredInstances mi ON B.InstanceID = mi.InstanceID
	WHERE mi.HasBaseline = 0
	AND mi.BaseLineStartDate IS NOT NULL
	GROUP BY b.InstanceID
	) as s (InstanceID,StartDate,EndDate)
	ON (s.InstanceID = t.InstanceID AND s.StartDate = t.BaseLineStartDate AND DATEDIFF(day,s.StartDate,s.enddate) >= @BaseLength)
	WHEN MATCHED THEN
		UPDATE SET t.HasBaseline = 1;

-- Start InstanceServer Waits

	--set baselinestartdate
	MERGE [dbo].MonitoredInstances AS target
	USING (
		SELECT misw.InstanceID,MIN(misw.CollectionDate) as CollectionDate
		FROM [dbo].[MonitoredInstanceServerWaits] misw 
		INNER JOIN [dbo].MonitoredInstances mi ON misw.InstanceID = mi.InstanceID
		WHERE mi.Deleted = 0 AND mi.WaitsBaselineStartDate IS NULL
		GROUP by misw.InstanceID) AS source(InstanceID,CollectionDate)
	ON (target.InstanceID = source.InstanceID)
	WHEN MATCHED THEN
		UPDATE SET WaitsBaselineStartDate = source.CollectionDate;

	--insert values between baseline dates
	MERGE [Baseline].[MonitoredInstanceServerWaits] as t
	USING(
	SELECT misw.CollectionDate,misw.InstanceID,misw.WaitID,misw.Waiting_Task_Count,misw.Wait_Time_MS,misw.Max_Wait_Time_MS,misw.Signal_Wait_Time_MS
	FROM [dbo].[MonitoredInstanceServerWaits] misw
	INNER JOIN #InstanceWaitDates iwd ON misw.InstanceID = iwd.InstanceID
	INNER JOIN [dbo].MonitoredInstances mi on misw.InstanceID = mi.InstanceID
	WHERE misw.CollectionDate >= iwd.MaxDate
	AND misw.CollectionDate <= CAST(DATEADD(day,@Baselength + 1,WaitsBaseLineStartDate) AS date)
	AND mi.HasWaitsBaseline = 0
	AND mi.Deleted = 0
	) AS s (CollectionDate,InstanceID,WaitID,Waiting_Task_Count,Wait_Time_MS,Max_Wait_Time_MS,Signal_Wait_Time_MS)
	ON (t.CollectionDate = s.CollectionDate AND t.InstanceID = s.InstanceID AND t.WaitID = s.WaitID)
	WHEN NOT MATCHED THEN
		INSERT (CollectionDate,InstanceID,WaitID,Waiting_Task_Count,Wait_Time_MS,Max_Wait_Time_MS,Signal_Wait_Time_MS) VALUES (s.CollectionDate,s.InstanceID,s.WaitID,s.Waiting_Task_Count,s.Wait_Time_MS,s.Max_Wait_Time_MS,s.Signal_Wait_Time_MS);

	--update hasbaseline if baseline is complete
	MERGE [dbo].MonitoredInstances t
	USING(
	SELECT b.InstanceID, MIN(b.CollectionDate) AS StartDate, Max(b.CollectionDate) AS EndDate
	FROM [Baseline].[MonitoredInstanceServerWaits] b
	INNER JOIN [dbo].MonitoredInstances mi ON B.InstanceID = mi.InstanceID
	WHERE mi.HasWaitsBaseline = 0
	AND mi.WaitsBaseLineStartDate IS NOT NULL
	GROUP BY b.InstanceID
	) as s (InstanceID,StartDate,EndDate)
	ON (s.InstanceID = t.InstanceID AND s.StartDate = t.WaitsBaseLineStartDate AND DATEDIFF(day,s.StartDate,s.enddate) >= @BaseLength)
	WHEN MATCHED THEN
		UPDATE SET t.HasWaitsBaseline = 1;

END
