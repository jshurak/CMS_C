CREATE TABLE [Baseline].[MonitoredInstanceServerWaits] (
    [InstanceID]          INT      NULL,
    [WaitID]              INT      NULL,
    [Waiting_Task_Count]  BIGINT   NULL,
    [Wait_Time_MS]        BIGINT   NULL,
    [Max_Wait_Time_MS]    BIGINT   NULL,
    [Signal_Wait_Time_MS] BIGINT   NULL,
    [CollectionDate]      DATETIME NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_InstanceID]
    ON [Baseline].[MonitoredInstanceServerWaits]([InstanceID] ASC)
    INCLUDE([CollectionDate]);

