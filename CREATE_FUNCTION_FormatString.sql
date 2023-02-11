CREATE FUNCTION dbo.SetFormatString
(
	@text SYSNAME,
	@supr BIT = 0,
	@caps INT = 0, -- 0-Caps, 1-caps, 2-CAPS
	@char SYSNAME = '_',
	@repl SYSNAME = ''
)
RETURNS sysname
AS
BEGIN
	DECLARE @pos0 INT = CHARINDEX(@char, @text);
	DECLARE @ret SYSNAME
	DECLARE @pos1 INT = 0;
	IF  @pos0 = 0
		BEGIN
			SET @ret = UPPER(LEFT(@text, 1)) + LOWER(RIGHT(@text, LEN(@text)-1));
		END
	ELSE
		BEGIN
			SET @pos1 = CHARINDEX(@char, @text, @pos0+1);
			SET @ret = UPPER(LEFT(@text, 1)) + LOWER(SUBSTRING(@text, 2, @pos0 - 1));

			WHILE (1=1)
				BEGIN
					SELECT @pos0 = CHARINDEX(@char, @text, @pos0);
					IF @pos0 = 0
						BREAK;
					SET @pos0 = @pos0 + 1
					SELECT @pos1 = CHARINDEX(@char, @text, @pos0+1);
					IF @pos1 = 0
						SET @ret = @ret + UPPER(SUBSTRING(@text, @pos0, 1))  + LOWER(SUBSTRING(@text,@pos0 + 1, LEN(@text) - @pos0 + 1))
					ELSE
						SET @ret = @ret + UPPER(SUBSTRING(@text, @pos0, 1)) + LOWER(SUBSTRING(@text,@pos0 + 1 ,@pos1 - @pos0))
				END
			END
	IF @supr = 1
		SET @ret = REPLACE(@ret, @char, @repl)
	SET @ret = 
		CASE @caps
			WHEN 1 THEN LOWER(@ret)
			WHEN 2 THEN UPPER(@ret)
			ELSE @ret END
	RETURN @ret
END