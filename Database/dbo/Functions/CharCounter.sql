CREATE FUNCTION [dbo].[CharCounter] (@string varchar(128))
returns varchar(20)
as
begin
declare @nSpaces int = LEN(@string) - LEN(REPLACE(@string,' ',''))
declare @i int, @out varchar(20)


while @nSpaces > 0
BEGIN
	SELECT @i = CHARINDEX(' ',@string,0) - 1
	SET @out = CONCAT(@out,CAST(@i as varchar))
	--PRINT CAST(@i as varchar(5))

	SET @string = SUBSTRING(@string,@i + 2,LEN(@string))
	SET @nSpaces -= 1
END
SET @out = CONCAT(@out,CAST(LEN(@string) as varchar))
RETURN @out
END
