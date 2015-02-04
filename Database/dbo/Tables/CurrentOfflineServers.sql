CREATE TABLE [dbo].[CurrentOfflineServers] (
    [ServerID]     INT           NULL,
    [ServerName]   VARCHAR (128) NULL,
    [OfflineDate]  DATETIME      NULL,
    [Environment]  VARCHAR (60)  NULL,
    [PageCount]    SMALLINT      NULL,
    [LastPageDate] DATETIME      NULL
);

