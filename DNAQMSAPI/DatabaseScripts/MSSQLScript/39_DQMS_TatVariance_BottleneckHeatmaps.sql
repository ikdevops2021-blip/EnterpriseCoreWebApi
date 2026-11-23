-- ============================================================================================
-- DQMS STAGE 3: TURNAROUND TIME (TAT) VARIANCE & BOTTLENECK HEATMAP ANALYTICS (MSSQL)
-- Script Number: 39_DQMS_TatVariance_BottleneckHeatmaps.sql
-- Description: Creates covering index for analytics and implements PR_S_DqmsTatVarianceAnalytics
--              and PR_S_DqmsBottleneckHeatmap stored procedures.
-- ============================================================================================

USE [dnaqms];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- 1. Create Covering Index on TokenTransaction for Fast Analytical Slicing
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TokenTransaction_Analytics_TAT' AND object_id = OBJECT_ID(N'[dbo].[TokenTransaction]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_TokenTransaction_Analytics_TAT]
    ON [dbo].[TokenTransaction] ([OrganizationId], [LocationId], [CreatedDate], [TokenStatus])
    INCLUDE ([ProcessId], [CounterId], [AreaId], [IssuedTime], [CalledTime], [ServedTime], [CompletedTime], [PriorityTier]);
END
GO

-- 2. Stored Procedure: PR_S_DqmsTatVarianceAnalytics
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_S_DqmsTatVarianceAnalytics]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[PR_S_DqmsTatVarianceAnalytics];
GO

CREATE PROCEDURE [dbo].[PR_S_DqmsTatVarianceAnalytics]
    @p_OrganizationId INT = 1,
    @p_LocationId INT = 1,
    @p_StartDate DATETIME = NULL,
    @p_EndDate DATETIME = NULL,
    @p_AreaId INT = -1,
    @p_ProcessId INT = -1
AS
BEGIN
    SET NOCOUNT ON;

    IF @p_StartDate IS NULL
        SET @p_StartDate = DATEADD(DAY, -7, GETDATE());
    IF @p_EndDate IS NULL
        SET @p_EndDate = GETDATE();

    -- Base Completed & In-Flight Tokens CTE
    ;WITH TokenMetrics AS (
        SELECT 
            t.Id,
            t.TokenNumber,
            t.ProcessId,
            p.ProcessName,
            p.ProcessCode,
            ISNULL(p.TargetTATMinutes, 15) AS TargetTATMinutes,
            t.TokenStatus,
            t.PriorityTier,
            t.IssuedTime,
            t.ServedTime,
            t.CompletedTime,
            -- Wait duration in minutes
            CASE 
                WHEN t.ServedTime IS NOT NULL THEN DATEDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0
                WHEN t.CalledTime IS NOT NULL THEN DATEDIFF(SECOND, t.IssuedTime, t.CalledTime) / 60.0
                ELSE DATEDIFF(SECOND, t.IssuedTime, GETDATE()) / 60.0
            END AS WaitMinutes,
            -- Service duration in minutes
            CASE 
                WHEN t.ServedTime IS NOT NULL AND t.CompletedTime IS NOT NULL THEN DATEDIFF(SECOND, t.ServedTime, t.CompletedTime) / 60.0
                WHEN t.ServedTime IS NOT NULL AND t.CompletedTime IS NULL THEN DATEDIFF(SECOND, t.ServedTime, GETDATE()) / 60.0
                ELSE 0.0
            END AS ServiceMinutes,
            -- Actual Total Turnaround Time in minutes
            CASE 
                WHEN t.CompletedTime IS NOT NULL THEN DATEDIFF(SECOND, t.IssuedTime, t.CompletedTime) / 60.0
                WHEN t.ServedTime IS NOT NULL THEN DATEDIFF(SECOND, t.IssuedTime, GETDATE()) / 60.0
                ELSE DATEDIFF(SECOND, t.IssuedTime, GETDATE()) / 60.0
            END AS ActualTatMinutes
        FROM [dbo].[TokenTransaction] t WITH (NOLOCK)
        INNER JOIN [dbo].[Process] p WITH (NOLOCK) ON t.ProcessId = p.Id
        WHERE t.OrganizationId = @p_OrganizationId
          AND t.LocationId = @p_LocationId
          AND t.CreatedDate >= @p_StartDate
          AND t.CreatedDate <= @p_EndDate
          AND (@p_AreaId = -1 OR t.AreaId = @p_AreaId)
          AND (@p_ProcessId = -1 OR t.ProcessId = @p_ProcessId)
          AND t.IsDeleted = 0
    )
    SELECT 
        COUNT(*) AS TotalTokens,
        SUM(CASE WHEN TokenStatus = 18007 THEN 1 ELSE 0 END) AS CompletedTokens,
        ROUND(ISNULL(AVG(WaitMinutes), 0), 2) AS AverageWaitMinutes,
        ROUND(ISNULL(AVG(ServiceMinutes), 0), 2) AS AverageServiceMinutes,
        ROUND(ISNULL(AVG(ActualTatMinutes), 0), 2) AS AverageTatMinutes,
        ROUND(ISNULL(AVG(TargetTATMinutes), 15), 2) AS TargetTatMinutes,
        ROUND(
            CASE 
                WHEN AVG(TargetTATMinutes) > 0 
                THEN ((AVG(ActualTatMinutes) - AVG(TargetTATMinutes)) / AVG(TargetTATMinutes)) * 100.0 
                ELSE 0.0 
            END, 2
        ) AS VariancePercentage,
        ROUND(ISNULL(STDEV(ActualTatMinutes), 0), 2) AS StdDevMinutes,
        ROUND(
            CASE 
                WHEN AVG(ActualTatMinutes) > 0 
                THEN (ISNULL(STDEV(ActualTatMinutes), 0) / AVG(ActualTatMinutes)) 
                ELSE 0.0 
            END, 3
        ) AS CoefficientOfVariation,
        ROUND(
            ISNULL(
                (SELECT TOP 1 PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY ActualTatMinutes) OVER() FROM TokenMetrics),
                0
            ), 2
        ) AS P95TatMinutes,
        ROUND(
            (CAST(SUM(CASE WHEN ActualTatMinutes <= TargetTATMinutes THEN 1 ELSE 0 END) AS FLOAT) / 
             NULLIF(CAST(COUNT(*) AS FLOAT), 0)) * 100.0, 2
        ) AS SlaPassPercentage
    FROM TokenMetrics;

    -- Process Breakdown Result Set
    ;WITH ProcessMetrics AS (
        SELECT 
            t.ProcessId,
            p.ProcessName,
            p.ProcessCode,
            ISNULL(p.TargetTATMinutes, 15) AS TargetTATMinutes,
            COUNT(*) AS TotalTokens,
            SUM(CASE WHEN t.TokenStatus = 18007 THEN 1 ELSE 0 END) AS CompletedTokens,
            AVG(
                CASE 
                    WHEN t.ServedTime IS NOT NULL THEN DATEDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0
                    ELSE DATEDIFF(SECOND, t.IssuedTime, GETDATE()) / 60.0
                END
            ) AS AvgWaitMinutes,
            AVG(
                CASE 
                    WHEN t.ServedTime IS NOT NULL AND t.CompletedTime IS NOT NULL THEN DATEDIFF(SECOND, t.ServedTime, t.CompletedTime) / 60.0
                    ELSE 0.0
                END
            ) AS AvgServiceMinutes,
            AVG(
                CASE 
                    WHEN t.CompletedTime IS NOT NULL THEN DATEDIFF(SECOND, t.IssuedTime, t.CompletedTime) / 60.0
                    ELSE DATEDIFF(SECOND, t.IssuedTime, GETDATE()) / 60.0
                END
            ) AS AvgTatMinutes,
            STDEV(
                CASE 
                    WHEN t.CompletedTime IS NOT NULL THEN DATEDIFF(SECOND, t.IssuedTime, t.CompletedTime) / 60.0
                    ELSE DATEDIFF(SECOND, t.IssuedTime, GETDATE()) / 60.0
                END
            ) AS StdDevMinutes,
            (CAST(SUM(CASE WHEN (CASE WHEN t.CompletedTime IS NOT NULL THEN DATEDIFF(SECOND, t.IssuedTime, t.CompletedTime) / 60.0 ELSE DATEDIFF(SECOND, t.IssuedTime, GETDATE()) / 60.0 END) <= ISNULL(p.TargetTATMinutes, 15) THEN 1 ELSE 0 END) AS FLOAT) / 
             NULLIF(CAST(COUNT(*) AS FLOAT), 0)) * 100.0 AS SlaPassRate
        FROM [dbo].[TokenTransaction] t WITH (NOLOCK)
        INNER JOIN [dbo].[Process] p WITH (NOLOCK) ON t.ProcessId = p.Id
        WHERE t.OrganizationId = @p_OrganizationId
          AND t.LocationId = @p_LocationId
          AND t.CreatedDate >= @p_StartDate
          AND t.CreatedDate <= @p_EndDate
          AND (@p_AreaId = -1 OR t.AreaId = @p_AreaId)
          AND t.IsDeleted = 0
        GROUP BY t.ProcessId, p.ProcessName, p.ProcessCode, p.TargetTATMinutes
    )
    SELECT 
        ProcessId,
        ProcessName,
        ProcessCode,
        TargetTATMinutes,
        TotalTokens,
        CompletedTokens,
        ROUND(AvgWaitMinutes, 2) AS AvgWaitMinutes,
        ROUND(AvgServiceMinutes, 2) AS AvgServiceMinutes,
        ROUND(AvgTatMinutes, 2) AS ActualTatMinutes,
        ROUND(
            CASE 
                WHEN TargetTATMinutes > 0 
                THEN ((AvgTatMinutes - TargetTATMinutes) / TargetTATMinutes) * 100.0 
                ELSE 0.0 
            END, 2
        ) AS VariancePercentage,
        ROUND(ISNULL(StdDevMinutes, 0), 2) AS StdDevMinutes,
        ROUND(ISNULL(SlaPassRate, 100.0), 2) AS SlaPassRate,
        CASE 
            WHEN ((AvgTatMinutes - TargetTATMinutes) / NULLIF(TargetTATMinutes, 0)) * 100.0 > 50.0 THEN 'CRITICAL'
            WHEN ((AvgTatMinutes - TargetTATMinutes) / NULLIF(TargetTATMinutes, 0)) * 100.0 > 20.0 THEN 'CONGESTED'
            WHEN ((AvgTatMinutes - TargetTATMinutes) / NULLIF(TargetTATMinutes, 0)) * 100.0 > 0.0 THEN 'ACCEPTABLE'
            ELSE 'OPTIMAL'
        END AS StatusTier
    FROM ProcessMetrics
    ORDER BY VariancePercentage DESC;
END;
GO

-- 3. Stored Procedure: PR_S_DqmsBottleneckHeatmap
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_S_DqmsBottleneckHeatmap]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[PR_S_DqmsBottleneckHeatmap];
GO

CREATE PROCEDURE [dbo].[PR_S_DqmsBottleneckHeatmap]
    @p_OrganizationId INT = 1,
    @p_LocationId INT = 1,
    @p_StartDate DATETIME = NULL,
    @p_EndDate DATETIME = NULL,
    @p_DimensionType NVARCHAR(30) = 'HourByDayOfWeek', -- 'HourByDayOfWeek', 'HourByProcess', 'HourByCounter'
    @p_AreaId INT = -1
AS
BEGIN
    SET NOCOUNT ON;

    IF @p_StartDate IS NULL
        SET @p_StartDate = DATEADD(DAY, -7, GETDATE());
    IF @p_EndDate IS NULL
        SET @p_EndDate = GETDATE();

    IF @p_DimensionType = 'HourByDayOfWeek'
    BEGIN
        SELECT 
            DATEPART(HOUR, t.CreatedDate) AS HourOfDay,
            DATEPART(WEEKDAY, t.CreatedDate) AS DimensionKey,
            DATENAME(WEEKDAY, t.CreatedDate) AS DimensionLabel,
            COUNT(*) AS TokenCount,
            ROUND(AVG(CASE WHEN t.ServedTime IS NOT NULL THEN DATEDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE DATEDIFF(SECOND, t.IssuedTime, GETDATE()) / 60.0 END), 2) AS AvgWaitMinutes,
            ROUND(AVG(CASE WHEN t.ServedTime IS NOT NULL AND t.CompletedTime IS NOT NULL THEN DATEDIFF(SECOND, t.ServedTime, t.CompletedTime) / 60.0 ELSE 0.0 END), 2) AS AvgServiceMinutes,
            ROUND(AVG(CASE WHEN t.CompletedTime IS NOT NULL THEN DATEDIFF(SECOND, t.IssuedTime, t.CompletedTime) / 60.0 ELSE DATEDIFF(SECOND, t.IssuedTime, GETDATE()) / 60.0 END), 2) AS AvgTatMinutes,
            ROUND(
                CASE 
                    WHEN AVG(ISNULL(p.TargetTATMinutes, 15)) > 0 
                    THEN ((AVG(CASE WHEN t.CompletedTime IS NOT NULL THEN DATEDIFF(SECOND, t.IssuedTime, t.CompletedTime) / 60.0 ELSE DATEDIFF(SECOND, t.IssuedTime, GETDATE()) / 60.0 END) - AVG(ISNULL(p.TargetTATMinutes, 15))) / AVG(ISNULL(p.TargetTATMinutes, 15))) * 100.0 
                    ELSE 0.0 
                END, 2
            ) AS VariancePercentage,
            -- Composite Congestion Score (0 to 100)
            CAST(
                CASE 
                    WHEN (AVG(CASE WHEN t.ServedTime IS NOT NULL THEN DATEDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE DATEDIFF(SECOND, t.IssuedTime, GETDATE()) / 60.0 END) * 4.0 + COUNT(*) * 1.5) > 100.0 
                    THEN 100.0 
                    ELSE (AVG(CASE WHEN t.ServedTime IS NOT NULL THEN DATEDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE DATEDIFF(SECOND, t.IssuedTime, GETDATE()) / 60.0 END) * 4.0 + COUNT(*) * 1.5)
                END AS INT
            ) AS CongestionScore,
            CASE 
                WHEN AVG(CASE WHEN t.ServedTime IS NOT NULL THEN DATEDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE DATEDIFF(SECOND, t.IssuedTime, GETDATE()) / 60.0 END) > 20.0 THEN 'CRITICAL'
                WHEN AVG(CASE WHEN t.ServedTime IS NOT NULL THEN DATEDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE DATEDIFF(SECOND, t.IssuedTime, GETDATE()) / 60.0 END) > 10.0 THEN 'HIGH'
                WHEN AVG(CASE WHEN t.ServedTime IS NOT NULL THEN DATEDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE DATEDIFF(SECOND, t.IssuedTime, GETDATE()) / 60.0 END) > 5.0 THEN 'MODERATE'
                ELSE 'LOW'
            END AS CongestionLevel
        FROM [dbo].[TokenTransaction] t WITH (NOLOCK)
        INNER JOIN [dbo].[Process] p WITH (NOLOCK) ON t.ProcessId = p.Id
        WHERE t.OrganizationId = @p_OrganizationId
          AND t.LocationId = @p_LocationId
          AND t.CreatedDate >= @p_StartDate
          AND t.CreatedDate <= @p_EndDate
          AND (@p_AreaId = -1 OR t.AreaId = @p_AreaId)
          AND t.IsDeleted = 0
        GROUP BY DATEPART(HOUR, t.CreatedDate), DATEPART(WEEKDAY, t.CreatedDate), DATENAME(WEEKDAY, t.CreatedDate)
        ORDER BY DimensionKey, HourOfDay;
    END
    ELSE IF @p_DimensionType = 'HourByProcess'
    BEGIN
        SELECT 
            DATEPART(HOUR, t.CreatedDate) AS HourOfDay,
            t.ProcessId AS DimensionKey,
            p.ProcessName AS DimensionLabel,
            COUNT(*) AS TokenCount,
            ROUND(AVG(CASE WHEN t.ServedTime IS NOT NULL THEN DATEDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE DATEDIFF(SECOND, t.IssuedTime, GETDATE()) / 60.0 END), 2) AS AvgWaitMinutes,
            ROUND(AVG(CASE WHEN t.ServedTime IS NOT NULL AND t.CompletedTime IS NOT NULL THEN DATEDIFF(SECOND, t.ServedTime, t.CompletedTime) / 60.0 ELSE 0.0 END), 2) AS AvgServiceMinutes,
            ROUND(AVG(CASE WHEN t.CompletedTime IS NOT NULL THEN DATEDIFF(SECOND, t.IssuedTime, t.CompletedTime) / 60.0 ELSE DATEDIFF(SECOND, t.IssuedTime, GETDATE()) / 60.0 END), 2) AS AvgTatMinutes,
            ROUND(
                CASE 
                    WHEN ISNULL(p.TargetTATMinutes, 15) > 0 
                    THEN ((AVG(CASE WHEN t.CompletedTime IS NOT NULL THEN DATEDIFF(SECOND, t.IssuedTime, t.CompletedTime) / 60.0 ELSE DATEDIFF(SECOND, t.IssuedTime, GETDATE()) / 60.0 END) - p.TargetTATMinutes) / p.TargetTATMinutes) * 100.0 
                    ELSE 0.0 
                END, 2
            ) AS VariancePercentage,
            CAST(
                CASE 
                    WHEN (AVG(CASE WHEN t.ServedTime IS NOT NULL THEN DATEDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE DATEDIFF(SECOND, t.IssuedTime, GETDATE()) / 60.0 END) * 4.0 + COUNT(*) * 1.5) > 100.0 
                    THEN 100.0 
                    ELSE (AVG(CASE WHEN t.ServedTime IS NOT NULL THEN DATEDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE DATEDIFF(SECOND, t.IssuedTime, GETDATE()) / 60.0 END) * 4.0 + COUNT(*) * 1.5)
                END AS INT
            ) AS CongestionScore,
            CASE 
                WHEN AVG(CASE WHEN t.ServedTime IS NOT NULL THEN DATEDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE DATEDIFF(SECOND, t.IssuedTime, GETDATE()) / 60.0 END) > 20.0 THEN 'CRITICAL'
                WHEN AVG(CASE WHEN t.ServedTime IS NOT NULL THEN DATEDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE DATEDIFF(SECOND, t.IssuedTime, GETDATE()) / 60.0 END) > 10.0 THEN 'HIGH'
                WHEN AVG(CASE WHEN t.ServedTime IS NOT NULL THEN DATEDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE DATEDIFF(SECOND, t.IssuedTime, GETDATE()) / 60.0 END) > 5.0 THEN 'MODERATE'
                ELSE 'LOW'
            END AS CongestionLevel
        FROM [dbo].[TokenTransaction] t WITH (NOLOCK)
        INNER JOIN [dbo].[Process] p WITH (NOLOCK) ON t.ProcessId = p.Id
        WHERE t.OrganizationId = @p_OrganizationId
          AND t.LocationId = @p_LocationId
          AND t.CreatedDate >= @p_StartDate
          AND t.CreatedDate <= @p_EndDate
          AND (@p_AreaId = -1 OR t.AreaId = @p_AreaId)
          AND t.IsDeleted = 0
        GROUP BY DATEPART(HOUR, t.CreatedDate), t.ProcessId, p.ProcessName, p.TargetTATMinutes
        ORDER BY t.ProcessId, HourOfDay;
    END
    ELSE -- 'HourByCounter'
    BEGIN
        SELECT 
            DATEPART(HOUR, t.CreatedDate) AS HourOfDay,
            ISNULL(t.CounterId, 0) AS DimensionKey,
            ISNULL(c.CounterNumber, 'Unassigned') AS DimensionLabel,
            COUNT(*) AS TokenCount,
            ROUND(AVG(CASE WHEN t.ServedTime IS NOT NULL THEN DATEDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE DATEDIFF(SECOND, t.IssuedTime, GETDATE()) / 60.0 END), 2) AS AvgWaitMinutes,
            ROUND(AVG(CASE WHEN t.ServedTime IS NOT NULL AND t.CompletedTime IS NOT NULL THEN DATEDIFF(SECOND, t.ServedTime, t.CompletedTime) / 60.0 ELSE 0.0 END), 2) AS AvgServiceMinutes,
            ROUND(AVG(CASE WHEN t.CompletedTime IS NOT NULL THEN DATEDIFF(SECOND, t.IssuedTime, t.CompletedTime) / 60.0 ELSE DATEDIFF(SECOND, t.IssuedTime, GETDATE()) / 60.0 END), 2) AS AvgTatMinutes,
            0.0 AS VariancePercentage,
            CAST(
                CASE 
                    WHEN (AVG(CASE WHEN t.ServedTime IS NOT NULL THEN DATEDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE DATEDIFF(SECOND, t.IssuedTime, GETDATE()) / 60.0 END) * 4.0 + COUNT(*) * 1.5) > 100.0 
                    THEN 100.0 
                    ELSE (AVG(CASE WHEN t.ServedTime IS NOT NULL THEN DATEDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE DATEDIFF(SECOND, t.IssuedTime, GETDATE()) / 60.0 END) * 4.0 + COUNT(*) * 1.5)
                END AS INT
            ) AS CongestionScore,
            CASE 
                WHEN AVG(CASE WHEN t.ServedTime IS NOT NULL THEN DATEDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE DATEDIFF(SECOND, t.IssuedTime, GETDATE()) / 60.0 END) > 20.0 THEN 'CRITICAL'
                WHEN AVG(CASE WHEN t.ServedTime IS NOT NULL THEN DATEDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE DATEDIFF(SECOND, t.IssuedTime, GETDATE()) / 60.0 END) > 10.0 THEN 'HIGH'
                WHEN AVG(CASE WHEN t.ServedTime IS NOT NULL THEN DATEDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE DATEDIFF(SECOND, t.IssuedTime, GETDATE()) / 60.0 END) > 5.0 THEN 'MODERATE'
                ELSE 'LOW'
            END AS CongestionLevel
        FROM [dbo].[TokenTransaction] t WITH (NOLOCK)
        LEFT JOIN [dbo].[Counter] c WITH (NOLOCK) ON t.CounterId = c.Id
        WHERE t.OrganizationId = @p_OrganizationId
          AND t.LocationId = @p_LocationId
          AND t.CreatedDate >= @p_StartDate
          AND t.CreatedDate <= @p_EndDate
          AND (@p_AreaId = -1 OR t.AreaId = @p_AreaId)
          AND t.IsDeleted = 0
        GROUP BY DATEPART(HOUR, t.CreatedDate), t.CounterId, c.CounterNumber
        ORDER BY t.CounterId, HourOfDay;
    END
END;
GO
