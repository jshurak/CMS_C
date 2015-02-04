CREATE TABLE [Baseline].[MonitoredServerPerfCounters] (
    [CollectionDate] DATETIME         NULL,
    [ServerID]       INT              NULL,
    [CounterID]      SMALLINT         NULL,
    [Value]          DECIMAL (30, 15) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_DateServerCounter]
    ON [Baseline].[MonitoredServerPerfCounters]([CollectionDate] ASC, [ServerID] ASC, [CounterID] ASC)
    INCLUDE([Value]);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20140718-104355]
    ON [Baseline].[MonitoredServerPerfCounters]([ServerID] ASC, [CollectionDate] ASC);

