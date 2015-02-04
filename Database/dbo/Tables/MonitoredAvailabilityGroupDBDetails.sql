CREATE TABLE [dbo].[MonitoredAvailabilityGroupDBDetails] (
    [DetailID]             INT           IDENTITY (1, 1) NOT NULL,
    [DatabaseID]           INT           NULL,
    [DatabaseName]         VARCHAR (128) NULL,
    [IsFailoverReady]      BIT           NULL,
    [SynchronizationState] VARCHAR (13)  NULL,
    [DateCreated]          DATETIME      NULL,
    [DateUpdated]          DATETIME      NULL,
    [Deleted]              BIT           NULL,
    [DateDeleted]          DATETIME      NULL,
    [AGDatabaseGuid]       VARCHAR (36)  NULL,
    [AvailabilityGroupID]  INT           NULL,
    [ReplicaID]            INT           NULL,
    PRIMARY KEY CLUSTERED ([DetailID] ASC)
);

