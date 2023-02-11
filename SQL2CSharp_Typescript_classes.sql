-- define parameter of table
DECLARE @NameSpace VARCHAR(MAX) = N'NameSpace'
DECLARE @Schema NVARCHAR(MAX) = 'dbo'
DECLARE @Table NVARCHAR(MAX) = 'CONTRACT'

-- define parameter of classes
DECLARE @ClassModel BIT = 0
DECLARE @Supress BIT = 0
DECLARE @constructor BIT = 0

DECLARE @TableC NVARCHAR(MAX)
 
SET @TableC = IIF(@ClassModel=1,UPPER(left(@Table,1))+LOWER(SUBSTRING(@Table,2,LEN(@Table))) + 'Model',@Table)

DECLARE @result NVARCHAR(MAX) = ''
DECLARE @constr NVARCHAR(MAX) = ''
DECLARE @tscrpt NVARCHAR(MAX) = ''
DECLARE @tscons NVARCHAR(MAX) = ''

DECLARE @define NVARCHAR(MAX) = ''
------------------------------------------------------------------------------------------------------
SET @result = @result + 'namespace ' + @NameSpace  + CHAR(13) + '{' + CHAR(13) 
SET	@result = @result + '  [Table("' + @Table + '", Schema="' + @Schema + '")]' + CHAR(13)
SET @result = @result + '  public class ' + @TableC + CHAR(13) + '  {' + CHAR(13) 
SET @constr = @constr + '  public ' + @TableC + '(){}' + CHAR(13) 
SET @constr = @constr + '  public ' + @TableC + '(' + CHAR(13) 
------------------------------------------------------------------------------------------------------
SET @tscrpt = @tscrpt + 'export class ' + @TableC + CHAR(13) + '{' + CHAR(13);
SET @tscons = @tscons + '  constructor('

SELECT 
	@result = @result + KeyType + FieldName + '    public ' + DataType + ' ' + PropertyName + ' { get; set; } ' + CHAR(13),
	@constr = @constr + DataType +  ' _' + LOWER(PropertyName) + ',', 
	@define = @define + CHAR(13) + '    this.' + PropertyName + REPLICATE(' ',20 - LEN(PropertyName)) + ' = _' + LOWER(PropertyName) + ',' ,


	@tscrpt = @tscrpt + '  public ' + TsPropertyName 
		+ CASE DataType
			WHEN 'Guid'  THEN ' string'
			WHEN 'Guid?' THEN '? string'
			WHEN 'long'  THEN ' number'
			WHEN 'long?'  THEN '? number'
			WHEN 'string?' THEN '? string'
			WHEN 'string' THEN ' string'
			WHEN 'DateTime' THEN ' Date'
			WHEN 'DateTime?' THEN '? Date'
			WHEN 'Byte[]' THEN ' any'
		  ELSE DataType END 
	+ CHAR(13) ,

	@tscons = @tscons + '_' + LOWER(PropertyName) + ': ' 
		+  
		+ CASE DataType
			WHEN 'Guid'  THEN 'string'
			WHEN 'Guid?' THEN 'string'
			WHEN 'long'  THEN 'number'
			WHEN 'long?'  THEN 'number'
			WHEN 'string?' THEN 'string'
			WHEN 'string' THEN 'string'
			WHEN 'DateTime' THEN 'Date'
			WHEN 'DateTime?' THEN 'Date'
			WHEN 'Byte[]' THEN 'any'
		  ELSE DataType END 
		+ ', '
 
FROM (SELECT
	IIF(CONSTRAINT_TYPE = 'PRIMARY KEY','    [Key]' + CHAR(13),'') AS KeyType,

	IIF(@Supress = 1, '    [Column("' + c.COLUMN_NAME + '")]' + CHAR(13),'') AS FieldName,
	dbo.SetFormatString(c.COLUMN_NAME,@Supress,0,'_','') AS PropertyName,

	LOWER(c.COLUMN_NAME) AS TsPropertyName,

    CASE c.DATA_TYPE
        WHEN 'bigint'           THEN CASE C.IS_NULLABLE WHEN 'YES' THEN 'long?' ELSE 'long' END
        WHEN 'binary'           THEN 'Byte[]'
        WHEN 'bit'              THEN CASE C.IS_NULLABLE WHEN 'YES' THEN 'bool?' ELSE 'bool' END
        WHEN 'char'             THEN 'string'
        WHEN 'date'             THEN CASE C.IS_NULLABLE WHEN 'YES' THEN 'DateTime?' ELSE 'DateTime' END
        WHEN 'datetime'         THEN CASE C.IS_NULLABLE WHEN 'YES' THEN 'DateTime?' ELSE 'DateTime' END
        WHEN 'datetime2'        THEN CASE C.IS_NULLABLE WHEN 'YES' THEN 'DateTime?' ELSE 'DateTime' END
        WHEN 'datetimeoffset'   THEN CASE C.IS_NULLABLE WHEN 'YES' THEN 'DateTimeOffset?' ELSE 'DateTimeOffset' END
        WHEN 'decimal'          THEN CASE C.IS_NULLABLE WHEN 'YES' THEN 'decimal?' ELSE 'decimal' END
        WHEN 'float'            THEN CASE C.IS_NULLABLE WHEN 'YES' THEN 'double?' ELSE 'double' END
        WHEN 'image'            THEN 'Byte[]'
        WHEN 'int'              THEN CASE C.IS_NULLABLE WHEN 'YES' THEN 'int?' ELSE 'int' END
        WHEN 'money'            THEN CASE C.IS_NULLABLE WHEN 'YES' THEN 'decimal?' ELSE 'decimal' END
        WHEN 'nchar'            THEN 'string'
        WHEN 'ntext'            THEN 'string'
        WHEN 'numeric'          THEN CASE C.IS_NULLABLE WHEN 'YES' THEN 'decimal?' ELSE 'decimal' END
        WHEN 'nvarchar'         THEN 'string'
        WHEN 'real'             THEN CASE C.IS_NULLABLE WHEN 'YES' THEN 'double?' ELSE 'double' END
        WHEN 'smalldatetime'    THEN CASE C.IS_NULLABLE WHEN 'YES' THEN 'DateTime?' ELSE 'DateTime' END
        WHEN 'smallint'         THEN CASE C.IS_NULLABLE WHEN 'YES' THEN 'short?' ELSE 'short' END
        WHEN 'smallmoney'       THEN CASE C.IS_NULLABLE WHEN 'YES' THEN 'decimal?' ELSE 'decimal' END
        WHEN 'text'             THEN 'string'
        WHEN 'time'             THEN CASE C.IS_NULLABLE WHEN 'YES' THEN 'TimeSpan?' ELSE 'TimeSpan' END
        WHEN 'timestamp'        THEN 'Byte[]'
        WHEN 'tinyint'          THEN CASE C.IS_NULLABLE WHEN 'YES' THEN 'Byte?' ELSE 'Byte' END
        WHEN 'uniqueidentifier' THEN CASE C.IS_NULLABLE WHEN 'YES' THEN 'Guid?' ELSE 'Guid' END
        WHEN 'varbinary'        THEN 'Byte[]'
        WHEN 'varchar'          THEN 'string'
        ELSE 'Object'
    END AS DataType, c.ORDINAL_POSITION
    FROM INFORMATION_SCHEMA.COLUMNS c
		LEFT JOIN
	[INFORMATION_SCHEMA].[CONSTRAINT_COLUMN_USAGE] cu ON c.TABLE_NAME = cu.TABLE_NAME AND c.COLUMN_NAME = cu.COLUMN_NAME
		LEFT JOIN
		[INFORMATION_SCHEMA].[TABLE_CONSTRAINTS] tc ON cu.COLUMN_NAME =c.COLUMN_NAME AND cu.CONSTRAINT_NAME = tc.CONSTRAINT_NAME AND tc.TABLE_NAME = c.TABLE_NAME
    WHERE c.TABLE_NAME = @Table
    AND ISNULL(@Schema, c.TABLE_SCHEMA) = c.TABLE_SCHEMA) t
ORDER BY t.ORDINAL_POSITION
 
SET @result = @result  + '  }' + CHAR(13)
SET @result = @result + REPLACE(@constr,'?','') + ')' + CHAR(13) + '  {'
SET @result = @result + @define + '}'  + CHAR(13)


SET @result = @result + '}'
PRINT REPLACE(REPLACE(@result,',)',')'),',}',CHAR(13) + '  }')
PRINT CHAR(13)+ CHAR(13)+ CHAR(13)


SET @tscrpt = @tscrpt + '}' + CHAR(13)
SET @tscrpt = @tscrpt + @tscons + ')'  + CHAR(13) + '  {'
SET @tscrpt = @tscrpt + @define + '}'  + CHAR(13)


PRINT REPLACE(REPLACE(@tscrpt,', )',')'),',}',CHAR(13) + '  }')
/*

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS c
    WHERE c.TABLE_NAME = 'CONTRACT'

*/