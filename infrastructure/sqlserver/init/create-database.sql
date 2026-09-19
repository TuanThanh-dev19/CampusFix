IF DB_ID(N'$(DatabaseName)') IS NULL
BEGIN
    DECLARE @create_database_sql NVARCHAR(MAX);
    SET @create_database_sql = N'CREATE DATABASE ' + QUOTENAME(N'$(DatabaseName)');
    EXEC sys.sp_executesql @create_database_sql;
END;
GO
