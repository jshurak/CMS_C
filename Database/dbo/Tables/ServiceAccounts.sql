CREATE TABLE [dbo].[ServiceAccounts] (
    [ServiceID] INT          IDENTITY (1, 1) NOT NULL,
    [Name]      VARCHAR (60) NULL,
    [MSSQL]     BIT          NULL,
    [Databases] BIT          NULL,
    [AgentJobs] BIT          NULL,
    CONSTRAINT [pk_serviceaccounts] PRIMARY KEY CLUSTERED ([ServiceID] ASC)
);

