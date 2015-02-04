CREATE TABLE [dbo].[CurrentBlocking] (
    [InstanceID]          INT      NULL,
    [CurrentBlockingSpid] SMALLINT NULL,
    [LastBatchTime]       DATETIME NULL,
    [BlockingID]          BIGINT   NULL,
    [PageCount]           SMALLINT NULL,
    [LastPageDate]        DATETIME NULL
);

