CREATE TABLE [Baseline].[MonitoredInstancePerfCounters] (
    [CollectionDate] DATETIME         NULL,
    [InstanceID]     INT              NULL,
    [CounterID]      SMALLINT         NULL,
    [Value]          DECIMAL (30, 15) NULL
);


GO
CREATE CLUSTERED INDEX [ClusteredIndex-20140728-105217]
    ON [Baseline].[MonitoredInstancePerfCounters]([CollectionDate] DESC, [InstanceID] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_DateInstanceCounter]
    ON [Baseline].[MonitoredInstancePerfCounters]([CollectionDate] ASC, [InstanceID] ASC, [CounterID] ASC)
    INCLUDE([Value]);

