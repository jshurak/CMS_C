CREATE TABLE [dbo].[ServerWaits] (
    [WaitID]   INT           IDENTITY (1, 1) NOT NULL,
    [WaitType] NVARCHAR (60) NULL,
    [Capture]  BIT           NULL
);

