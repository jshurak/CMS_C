CREATE TABLE [dbo].[CacheController] (
    [CacheID]         SMALLINT     IDENTITY (1, 1) NOT NULL,
    [CacheName]       VARCHAR (25) NULL,
    [Refresh]         BIT          NULL,
    [LastRefreshDate] DATETIME     NULL
);

