CREATE PROCEDURE [dbo].[LogModule]
@ModuleName varchar(60),
@LogID bigint = 0
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Date DATETIME = GETDATE()
	 
	 IF NOT EXISTS(SELECT LogID FROM CollectionLog WHERE LogID = @LogID)
		BEGIN
			INSERT INTO CollectionLog (ModuleName,StartTime) VALUES (@ModuleName,@Date)
			SELECT @LogID = SCOPE_IDENTITY()
			SELECT @LogID AS [LogID]
		END
	ELSE
		UPDATE CollectionLog
		SET EndTime = @Date
		WHERE LogID = @LogID

	RETURN 
END
