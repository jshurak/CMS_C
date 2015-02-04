CREATE TABLE [dbo].[MonitoredAvailabilityGroups] (
    [AvailabilityGroupID]   INT           IDENTITY (1, 1) NOT NULL,
    [AvailabilityGroupName] VARCHAR (128) NULL,
    [AvailabilityGroupGUID] VARCHAR (36)  NULL,
    [DateCreated]           DATETIME      NULL,
    [DateUpdated]           DATETIME      NULL,
    [Deleted]               BIT           NULL,
    [DateDeleted]           DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([AvailabilityGroupID] ASC)
);

