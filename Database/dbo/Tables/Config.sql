CREATE TABLE [dbo].[Config] (
    [ConfigID] SMALLINT      IDENTITY (1, 1) NOT NULL,
    [Setting]  VARCHAR (128) NULL,
    [intValue] INT           NULL,
    PRIMARY KEY CLUSTERED ([ConfigID] ASC)
);

