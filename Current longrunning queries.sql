USE []
GO

-- Maximum query running time may be # seconds.
DECLARE @QueryDurationThresholdSeconds INT = 3600 

-- Temporarily save current datetime to use as the execution time for the current check.
DECLARE @CheckDate DATETIME2 = SYSDATETIME();

-- Temporarily save sp_who2 results.
DECLARE @who2table TABLE(SPID INT,Status VARCHAR(MAX),LOGIN VARCHAR(MAX),HostName VARCHAR(MAX),BlkBy VARCHAR(MAX),DBName VARCHAR(MAX),Command VARCHAR(MAX),CPUTime INT,DiskIO INT,LastBatch VARCHAR(MAX),ProgramName VARCHAR(MAX),SPID_1 INT,REQUESTID INT)
INSERT INTO @who2table EXECUTE sp_who2

-- Select currently running queries with a running time longer than @QueryDurationThresholdSeconds.
SELECT
     @CheckDate AS [CheckDate],RIGHT('0' + CONVERT(VARCHAR(5), @QueryDurationThresholdSeconds/60/60), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), @QueryDurationThresholdSeconds/60%60), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), @QueryDurationThresholdSeconds % 60), 2) AS [QueryDurationThreshold], RIGHT('0' + CONVERT(VARCHAR(5), DATEDIFF(SS, req.start_time, @CheckDate)/60/60), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), DATEDIFF(SS, req.start_time, @CheckDate)/60%60), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), DATEDIFF(SS, req.start_time, @CheckDate) % 60), 2) AS  [CurrentQueryDuration],req.session_id AS [SPID],req.start_time AS [StartTime],DB_NAME(req.database_id) AS [DatabaseName],who.LOGIN AS [LoginName],who.HostName AS [HostName],who.ProgramName AS [ProgramName],NULLIF(req.blocking_session_id, 0) AS [BlockedBySPID],sqltext.text AS [QueryText],queryplan.query_plan AS [QueryPlan] FROM @who2table who
JOIN sys.dm_exec_requests req ON req.session_id = who.SPID
CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS sqltext
CROSS APPLY sys.dm_exec_query_plan (req.plan_handle) queryplan
WHERE DATEDIFF(SECOND, req.start_time, SYSDATETIME()) > @QueryDurationThresholdSeconds


