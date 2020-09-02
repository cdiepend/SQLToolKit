-- Create example logical backup device.
USE master
DECLARE @path NVARCHAR(255) = N'backuplocation+filename' 
  + CONVERT(CHAR(8), GETDATE(), 112) + '_'
  + REPLACE(CONVERT(CHAR(8), GETDATE(), 108),':','')
  + '.trn';
BACKUP LOG [database] TO DISK = @path WITH INIT, COMPRESSION;
-- Shrink
USE database
DBCC SHRINKFILE (N'logical_filename', 1);