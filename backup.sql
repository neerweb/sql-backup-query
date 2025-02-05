DECLARE @databaseName NVARCHAR(255)
DECLARE @backupPath NVARCHAR(255)
DECLARE @backupSQL NVARCHAR(MAX)

-- Specify the backup path (make sure the SQL Server service account has write access to this folder)
SET @backupPath = 'C:\Backup\'  -- Change to your desired backup location

-- Cursor to iterate over all databases except system databases
DECLARE db_cursor CURSOR FOR 
SELECT name 
FROM sys.databases 
WHERE state_desc = 'ONLINE'
AND name NOT IN ('master', 'tempdb', 'model', 'msdb') -- Exclude system databases

OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @databaseName

-- Loop through all databases and create backup
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Prepare the backup command
    SET @backupSQL = 'BACKUP DATABASE [' + @databaseName + '] TO DISK = ''' + @backupPath + @databaseName + '_backup_' + CONVERT(VARCHAR, GETDATE(), 112) + '.bak'' WITH INIT, FORMAT, STATS = 10'
    
    -- Execute the backup command
    EXEC sp_executesql @backupSQL
    
    -- Move to the next database
    FETCH NEXT FROM db_cursor INTO @databaseName
END

-- Clean up
CLOSE db_cursor
DEALLOCATE db_cursor
