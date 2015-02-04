CREATE PROCEDURE [dbo].[CacheUpdateController]
@CacheName varchar(25)
,@Refresh bit
AS
BEGIN
	UPDATE CacheController
	SET REFRESH = @Refresh
	WHERE CacheName = @CacheName
END
