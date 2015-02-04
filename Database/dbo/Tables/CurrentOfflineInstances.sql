CREATE TABLE [dbo].[CurrentOfflineInstances] (
    [InstanceID]   INT           NULL,
    [InstanceName] VARCHAR (128) NULL,
    [OfflineDate]  DATETIME      NULL,
    [Environment]  VARCHAR (60)  NULL,
    [PageCount]    SMALLINT      NULL,
    [LastPageDate] DATETIME      NULL
);

