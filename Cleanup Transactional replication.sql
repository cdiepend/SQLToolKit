/*	
	Script created to cleanup orphaned publications. These often stick in the replication monitor.
	Make sure that the orphaned replications are either still present on the server or that you create them anew (empty)
	uses SQLCommand mode
*/


-- Connect Publisher Server
:connect <Publisher server>
-- Drop Subscription
use [<DBNAME>]
exec sp_dropsubscription @publication = N'<publication name>', @subscriber = N'all', 
@destination_db = N'<Destination name>', @article = N'all'
go
-- Drop publication
exec sp_droppublication @publication = N'<Publication name>'
-- Disable replication db option
exec sp_replicationdboption @dbname = N'<DBNAME>', @optname = N'publish', @value = N'false'
GO

-- Connect Distributor
:CONNECT <Distribution server>
go
exec Distribution.dbo.sp_MSremove_published_jobs @server = '<publisher server>', 
@database = '<DBNAME>'
go

--Use below query to check if everything has been cleaned up
--select * from Distribution.dbo.MSpublications
--go