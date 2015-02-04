CREATE TABLE [dbo].[CollectionLog] (
    [LogID]      BIGINT       IDENTITY (1, 1) NOT NULL,
    [ModuleName] VARCHAR (60) NULL,
    [StartTime]  DATETIME     NULL,
    [EndTime]    DATETIME     NULL
);

