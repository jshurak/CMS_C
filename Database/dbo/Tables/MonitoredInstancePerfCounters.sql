CREATE TABLE [dbo].[MonitoredInstancePerfCounters] (
    [CollectionDate] DATETIME         NULL,
    [InstanceID]     INT              NULL,
    [CounterID]      SMALLINT         NULL,
    [Value]          DECIMAL (30, 15) NULL
);

