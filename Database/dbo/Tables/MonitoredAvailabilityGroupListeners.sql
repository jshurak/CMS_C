CREATE TABLE [dbo].[MonitoredAvailabilityGroupListeners] (
    [ListenerID]          INT           IDENTITY (1, 1) NOT NULL,
    [ListenerName]        VARCHAR (128) NULL,
    [ListenerGUID]        VARCHAR (36)  NULL,
    [ListenerIPAddress]   VARCHAR (15)  NULL,
    [ListenerIPState]     VARCHAR (16)  NULL,
    [ListenerPort]        VARCHAR (10)  NULL,
    [DateCreated]         DATETIME      NULL,
    [DateUpdated]         DATETIME      NULL,
    [Deleted]             BIT           NULL,
    [DateDeleted]         DATETIME      NULL,
    [AvailabilityGroupID] INT           NULL,
    PRIMARY KEY CLUSTERED ([ListenerID] ASC)
);

