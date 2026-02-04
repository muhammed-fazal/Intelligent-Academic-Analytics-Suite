/*
===================================================================
Create Database and Schemas
===================================================================
Script Purpose:
  This script create a new database named 'AcademicDB' after checking if it already exists.
  If the database exists, it is droped and recreated. additionally, the script sets up three schemas within the database:'bronze' ,'silver' , 'gold'.

WARNING:
  Running this script will drop the entire 'AcademicDB' database if it exits.
  All data in the database will be permanently dateted. Proceed with caution and ensure you have proper backups before runnig this scripts.
*/


USE master;
-- Drop and recreate the 'AcademicDB' database
IF EXISTS(SELECT 1 FROM sys.databases WHERE name ='AcademicDB')
BEGIN 
	ALTER DATABASE AcademicDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE AcademicDB;
END;
GO


-- Create Database 'AcademicDB'

CREATE DATABASE AcademicDB;
GO

USE AcademicDB;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
