IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = N'YourDatabaseName')
BEGIN
CREATE DATABASE [YourDatabaseName];
END
GO