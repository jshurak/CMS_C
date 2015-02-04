CREATE TABLE [History].[MonitoredInstances] (
    [HistoryID]        BIGINT        IDENTITY (1, 1) NOT NULL,
    [HistoryDate]      DATETIME      NULL,
    [InstanceID]       INT           NULL,
    [ServerID]         INT           NULL,
    [InstanceName]     VARCHAR (128) NULL,
    [Environment]      VARCHAR (60)  NULL,
    [MonitorInstance]  BIT           NULL,
    [Edition]          VARCHAR (128) NULL,
    [Version]          VARCHAR (20)  NULL,
    [isClustered]      BIT           NULL,
    [MaxMemory]        BIGINT        NULL,
    [MinMemory]        INT           NULL,
    [DateCreated]      DATETIME      NULL,
    [ServiceAccount]   VARCHAR (60)  NULL,
    [MonitorDatabases] BIT           NULL,
    [MonitorBlocking]  BIT           NULL,
    [Criticality]      TINYINT       NULL,
    [ProductLevel]     VARCHAR (10)  NULL,
    CONSTRAINT [pk_hmonitoredinstances] PRIMARY KEY NONCLUSTERED ([HistoryID] ASC)
);


GO
CREATE CLUSTERED INDEX [cidx_hmonitoredinstances]
    ON [History].[MonitoredInstances]([HistoryDate] ASC);

