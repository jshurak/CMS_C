CREATE TABLE [dbo].[Alert_PageRecords] (
    [PageID]         BIGINT       IDENTITY (1, 1) NOT NULL,
    [OperatorID]     INT          NULL,
    [PageCategory]   VARCHAR (28) NULL,
    [PageDate]       DATETIME     NULL,
    [PageStatus]     VARCHAR (28) NULL,
    [PageCount]      INT          NULL,
    [PageRetryCount] INT          NULL
);

