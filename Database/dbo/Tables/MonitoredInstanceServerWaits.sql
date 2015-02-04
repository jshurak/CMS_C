CREATE TABLE [dbo].[MonitoredInstanceServerWaits] (
    [InstanceID]          INT      NULL,
    [WaitID]              INT      NULL,
    [Waiting_Task_Count]  BIGINT   NULL,
    [Wait_Time_MS]        BIGINT   NULL,
    [Max_Wait_Time_MS]    BIGINT   NULL,
    [Signal_Wait_Time_MS] BIGINT   NULL,
    [CollectionDate]      DATETIME NULL
);


GO
CREATE CLUSTERED INDEX [ci_CollectionDateWaitID]
    ON [dbo].[MonitoredInstanceServerWaits]([CollectionDate] ASC, [WaitID] ASC, [InstanceID] ASC);

