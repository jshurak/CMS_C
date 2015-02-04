CREATE TABLE [dbo].[MonitoredAvailabilityGroupReplicas] (
    [ReplicaID]            INT           IDENTITY (1, 1) NOT NULL,
    [ReplicaName]          VARCHAR (128) NULL,
    [AvailabilityGroupID]  INT           NULL,
    [InstanceID]           INT           NULL,
    [AvailabilityMode]     VARCHAR (18)  NULL,
    [FailoverMode]         VARCHAR (10)  NULL,
    [CurrentRole]          VARCHAR (9)   NULL,
    [SynchronizationState] VARCHAR (13)  NULL,
    [DateCreated]          DATETIME      NULL,
    [DateUpdated]          DATETIME      NULL,
    [Deleted]              BIT           NULL,
    [DateDeleted]          DATETIME      NULL,
    [FailoverFlag]         BIT           NULL,
    [ReplicaGUID]          VARCHAR (36)  NULL,
    PRIMARY KEY CLUSTERED ([ReplicaID] ASC)
);

