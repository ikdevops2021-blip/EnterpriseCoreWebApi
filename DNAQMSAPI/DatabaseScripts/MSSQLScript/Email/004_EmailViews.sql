CREATE VIEW View_DailyMailHealthReport AS
WITH MailStats AS (
    SELECT 
        OrganizationId,
        CAST(CreateDate AS DATE) AS ReportDate,
        COUNT(QueueId) AS TotalProcessed,
        SUM(CASE WHEN Status = 1 THEN 1 ELSE 0 END) AS TotalSuccess,
        SUM(CASE WHEN Status = 2 THEN 1 ELSE 0 END) AS TotalFailed,
        SUM(CASE WHEN Status = 0 THEN 1 ELSE 0 END) AS TotalPending
    FROM EmailQueue
    WHERE IsDeleted = 0
    GROUP BY OrganizationId, CAST(CreateDate AS DATE)
)
SELECT 
    s.*,
    CASE 
        WHEN s.TotalProcessed > 0 
        THEN CAST((CAST(s.TotalSuccess AS FLOAT) / s.TotalProcessed) * 100 AS DECIMAL(5,2)) 
        ELSE 0 
    END AS SuccessRatePercentage,
    (SELECT TOP 1 ErrorDescription FROM EmailQueue 
     WHERE OrganizationId = s.OrganizationId 
       AND Status = 2 
       AND CAST(CreateDate AS DATE) = s.ReportDate
     ORDER BY CreateDate DESC) AS LastErrorMessage
FROM MailStats s;
