CREATE PROCEDURE [dbo].[CacheAcknowledgeRefresh]
@CacheName varchar(25)
AS
BEGIN
	IF EXISTS(SELECT CacheID FROM CacheController WHERE CacheName = @CacheName)
		UPDATE CacheController	
		SET Refresh = 0
		,LastRefreshDate = getdate()
		WHERE CacheName = @CacheName;
	ELSE
		INSERT INTO CacheController VALUES (@CacheName,0,GETDATE())
END
