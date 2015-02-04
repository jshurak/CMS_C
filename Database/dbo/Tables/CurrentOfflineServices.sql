CREATE TABLE [dbo].[CurrentOfflineServices] (
    [ServerID]      INT           NULL,
    [ServerName]    VARCHAR (128) NULL,
    [InstanceID]    INT           NULL,
    [InstanceName]  VARCHAR (128) NULL,
    [ServiceName]   VARCHAR (60)  NULL,
    [ServiceStatus] VARCHAR (20)  NULL,
    [OfflineDate]   DATETIME      NULL,
    [Environment]   VARCHAR (60)  NULL,
    [PageCount]     SMALLINT      NULL,
    [LastPageDate]  DATETIME      NULL
);

