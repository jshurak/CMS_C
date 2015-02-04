CREATE TABLE [dbo].[MonitoredServerPerfCounters] (
    [CollectionDate] DATETIME         NULL,
    [ServerID]       INT              NULL,
    [CounterID]      SMALLINT         NULL,
    [Value]          DECIMAL (30, 15) NULL
);

