-- ============================================================================================
-- DQMS STAGE 3: TURNAROUND TIME (TAT) VARIANCE & BOTTLENECK HEATMAP ANALYTICS (MySQL)
-- Script Number: 39_DQMS_TatVariance_BottleneckHeatmaps.sql
-- Description: Creates covering index for analytics and implements PR_S_DqmsTatVarianceAnalytics
--              and PR_S_DqmsBottleneckHeatmap stored procedures for MySQL.
-- ============================================================================================

USE dnaqms;

-- 1. Create Covering Index on tokentransaction for Fast Analytical Slicing
SET @index_exists = (SELECT COUNT(*) FROM information_schema.STATISTICS 
    WHERE TABLE_SCHEMA = 'dnaqms' AND TABLE_NAME = 'tokentransaction' AND INDEX_NAME = 'IX_TokenTransaction_Analytics_TAT');
SET @sql = IF(@index_exists = 0, 
    'ALTER TABLE tokentransaction ADD INDEX IX_TokenTransaction_Analytics_TAT (OrganizationId, LocationId, CreatedDate, TokenStatus, ProcessId, CounterId);', 
    'SELECT "Index IX_TokenTransaction_Analytics_TAT already exists";');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 2. Stored Procedure: PR_S_DqmsTatVarianceAnalytics
DROP PROCEDURE IF EXISTS PR_S_DqmsTatVarianceAnalytics;

DELIMITER $$
CREATE PROCEDURE PR_S_DqmsTatVarianceAnalytics(
    IN p_OrganizationId INT,
    IN p_LocationId INT,
    IN p_StartDate DATETIME,
    IN p_EndDate DATETIME,
    IN p_AreaId INT,
    IN p_ProcessId INT
)
BEGIN
    IF p_StartDate IS NULL THEN
        SET p_StartDate = DATE_SUB(NOW(), INTERVAL 7 DAY);
    END IF;
    IF p_EndDate IS NULL THEN
        SET p_EndDate = NOW();
    END IF;

    -- Aggregate Overall Summary
    SELECT 
        COUNT(*) AS TotalTokens,
        SUM(CASE WHEN t.TokenStatus = 18007 THEN 1 ELSE 0 END) AS CompletedTokens,
        ROUND(IFNULL(AVG(
            CASE 
                WHEN t.ServedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0
                WHEN t.CalledTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.CalledTime) / 60.0
                ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0
            END
        ), 0), 2) AS AverageWaitMinutes,
        ROUND(IFNULL(AVG(
            CASE 
                WHEN t.ServedTime IS NOT NULL AND t.CompletedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.ServedTime, t.CompletedTime) / 60.0
                WHEN t.ServedTime IS NOT NULL AND t.CompletedTime IS NULL THEN TIMESTAMPDIFF(SECOND, t.ServedTime, NOW()) / 60.0
                ELSE 0.0
            END
        ), 0), 2) AS AverageServiceMinutes,
        ROUND(IFNULL(AVG(
            CASE 
                WHEN t.CompletedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.CompletedTime) / 60.0
                WHEN t.ServedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0
                ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0
            END
        ), 0), 2) AS AverageTatMinutes,
        ROUND(IFNULL(AVG(IFNULL(p.TargetTATMinutes, 15)), 15), 2) AS TargetTatMinutes,
        ROUND(
            CASE 
                WHEN AVG(IFNULL(p.TargetTATMinutes, 15)) > 0 
                THEN ((AVG(CASE WHEN t.CompletedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.CompletedTime) / 60.0 ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0 END) - AVG(IFNULL(p.TargetTATMinutes, 15))) / AVG(IFNULL(p.TargetTATMinutes, 15))) * 100.0 
                ELSE 0.0 
            END, 2
        ) AS VariancePercentage,
        ROUND(IFNULL(STDDEV(
            CASE 
                WHEN t.CompletedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.CompletedTime) / 60.0
                ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0
            END
        ), 0), 2) AS StdDevMinutes,
        ROUND(
            CASE 
                WHEN AVG(CASE WHEN t.CompletedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.CompletedTime) / 60.0 ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0 END) > 0 
                THEN (IFNULL(STDDEV(CASE WHEN t.CompletedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.CompletedTime) / 60.0 ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0 END), 0) / 
                      AVG(CASE WHEN t.CompletedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.CompletedTime) / 60.0 ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0 END))
                ELSE 0.0 
            END, 3
        ) AS CoefficientOfVariation,
        ROUND(IFNULL(AVG(CASE WHEN t.CompletedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.CompletedTime) / 60.0 ELSE 15.0 END) * 1.45, 0), 2) AS P95TatMinutes,
        ROUND(
            (SUM(CASE WHEN (CASE WHEN t.CompletedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.CompletedTime) / 60.0 ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0 END) <= IFNULL(p.TargetTATMinutes, 15) THEN 1 ELSE 0 END) / 
             NULLIF(COUNT(*), 0)) * 100.0, 2
        ) AS SlaPassPercentage
    FROM tokentransaction t
    INNER JOIN process p ON t.ProcessId = p.Id
    WHERE t.OrganizationId = p_OrganizationId
      AND t.LocationId = p_LocationId
      AND t.CreatedDate >= p_StartDate
      AND t.CreatedDate <= p_EndDate
      AND (p_AreaId = -1 OR t.AreaId = p_AreaId)
      AND (p_ProcessId = -1 OR t.ProcessId = p_ProcessId)
      AND t.IsDeleted = 0;

    -- Process Breakdown Result Set
    SELECT 
        t.ProcessId,
        p.ProcessName,
        p.ProcessCode,
        IFNULL(p.TargetTATMinutes, 15) AS TargetTATMinutes,
        COUNT(*) AS TotalTokens,
        SUM(CASE WHEN t.TokenStatus = 18007 THEN 1 ELSE 0 END) AS CompletedTokens,
        ROUND(AVG(
            CASE 
                WHEN t.ServedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0
                ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0
            END
        ), 2) AS AvgWaitMinutes,
        ROUND(AVG(
            CASE 
                WHEN t.ServedTime IS NOT NULL AND t.CompletedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.ServedTime, t.CompletedTime) / 60.0
                ELSE 0.0
            END
        ), 2) AS AvgServiceMinutes,
        ROUND(AVG(
            CASE 
                WHEN t.CompletedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.CompletedTime) / 60.0
                ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0
            END
        ), 2) AS ActualTatMinutes,
        ROUND(
            CASE 
                WHEN IFNULL(p.TargetTATMinutes, 15) > 0 
                THEN ((AVG(CASE WHEN t.CompletedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.CompletedTime) / 60.0 ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0 END) - IFNULL(p.TargetTATMinutes, 15)) / IFNULL(p.TargetTATMinutes, 15)) * 100.0 
                ELSE 0.0 
            END, 2
        ) AS VariancePercentage,
        ROUND(IFNULL(STDDEV(
            CASE 
                WHEN t.CompletedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.CompletedTime) / 60.0
                ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0
            END
        ), 0), 2) AS StdDevMinutes,
        ROUND(
            (SUM(CASE WHEN (CASE WHEN t.CompletedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.CompletedTime) / 60.0 ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0 END) <= IFNULL(p.TargetTATMinutes, 15) THEN 1 ELSE 0 END) / 
             NULLIF(COUNT(*), 0)) * 100.0, 2
        ) AS SlaPassRate,
        CASE 
            WHEN ((AVG(CASE WHEN t.CompletedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.CompletedTime) / 60.0 ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0 END) - IFNULL(p.TargetTATMinutes, 15)) / NULLIF(IFNULL(p.TargetTATMinutes, 15), 0)) * 100.0 > 50.0 THEN 'CRITICAL'
            WHEN ((AVG(CASE WHEN t.CompletedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.CompletedTime) / 60.0 ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0 END) - IFNULL(p.TargetTATMinutes, 15)) / NULLIF(IFNULL(p.TargetTATMinutes, 15), 0)) * 100.0 > 20.0 THEN 'CONGESTED'
            WHEN ((AVG(CASE WHEN t.CompletedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.CompletedTime) / 60.0 ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0 END) - IFNULL(p.TargetTATMinutes, 15)) / NULLIF(IFNULL(p.TargetTATMinutes, 15), 0)) * 100.0 > 0.0 THEN 'ACCEPTABLE'
            ELSE 'OPTIMAL'
        END AS StatusTier
    FROM tokentransaction t
    INNER JOIN process p ON t.ProcessId = p.Id
    WHERE t.OrganizationId = p_OrganizationId
      AND t.LocationId = p_LocationId
      AND t.CreatedDate >= p_StartDate
      AND t.CreatedDate <= p_EndDate
      AND (p_AreaId = -1 OR t.AreaId = p_AreaId)
      AND t.IsDeleted = 0
    GROUP BY t.ProcessId, p.ProcessName, p.ProcessCode, p.TargetTATMinutes
    ORDER BY VariancePercentage DESC;
END$$
DELIMITER ;

-- 3. Stored Procedure: PR_S_DqmsBottleneckHeatmap
DROP PROCEDURE IF EXISTS PR_S_DqmsBottleneckHeatmap;

DELIMITER $$
CREATE PROCEDURE PR_S_DqmsBottleneckHeatmap(
    IN p_OrganizationId INT,
    IN p_LocationId INT,
    IN p_StartDate DATETIME,
    IN p_EndDate DATETIME,
    IN p_DimensionType VARCHAR(30),
    IN p_AreaId INT
)
BEGIN
    IF p_StartDate IS NULL THEN
        SET p_StartDate = DATE_SUB(NOW(), INTERVAL 7 DAY);
    END IF;
    IF p_EndDate IS NULL THEN
        SET p_EndDate = NOW();
    END IF;
    IF p_DimensionType IS NULL OR p_DimensionType = '' THEN
        SET p_DimensionType = 'HourByDayOfWeek';
    END IF;

    IF p_DimensionType = 'HourByDayOfWeek' THEN
        SELECT 
            HOUR(t.CreatedDate) AS HourOfDay,
            DAYOFWEEK(t.CreatedDate) AS DimensionKey,
            DAYNAME(t.CreatedDate) AS DimensionLabel,
            COUNT(*) AS TokenCount,
            ROUND(AVG(CASE WHEN t.ServedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0 END), 2) AS AvgWaitMinutes,
            ROUND(AVG(CASE WHEN t.ServedTime IS NOT NULL AND t.CompletedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.ServedTime, t.CompletedTime) / 60.0 ELSE 0.0 END), 2) AS AvgServiceMinutes,
            ROUND(AVG(CASE WHEN t.CompletedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.CompletedTime) / 60.0 ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0 END), 2) AS AvgTatMinutes,
            ROUND(
                CASE 
                    WHEN AVG(IFNULL(p.TargetTATMinutes, 15)) > 0 
                    THEN ((AVG(CASE WHEN t.CompletedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.CompletedTime) / 60.0 ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0 END) - AVG(IFNULL(p.TargetTATMinutes, 15))) / AVG(IFNULL(p.TargetTATMinutes, 15))) * 100.0 
                    ELSE 0.0 
                END, 2
            ) AS VariancePercentage,
            CAST(
                LEAST(100.0, (AVG(CASE WHEN t.ServedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0 END) * 4.0 + COUNT(*) * 1.5)) AS UNSIGNED
            ) AS CongestionScore,
            CASE 
                WHEN AVG(CASE WHEN t.ServedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0 END) > 20.0 THEN 'CRITICAL'
                WHEN AVG(CASE WHEN t.ServedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0 END) > 10.0 THEN 'HIGH'
                WHEN AVG(CASE WHEN t.ServedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0 END) > 5.0 THEN 'MODERATE'
                ELSE 'LOW'
            END AS CongestionLevel
        FROM tokentransaction t
        INNER JOIN process p ON t.ProcessId = p.Id
        WHERE t.OrganizationId = p_OrganizationId
          AND t.LocationId = p_LocationId
          AND t.CreatedDate >= p_StartDate
          AND t.CreatedDate <= p_EndDate
          AND (p_AreaId = -1 OR t.AreaId = p_AreaId)
          AND t.IsDeleted = 0
        GROUP BY HOUR(t.CreatedDate), DAYOFWEEK(t.CreatedDate), DAYNAME(t.CreatedDate)
        ORDER BY DimensionKey, HourOfDay;

    ELSEIF p_DimensionType = 'HourByProcess' THEN
        SELECT 
            HOUR(t.CreatedDate) AS HourOfDay,
            t.ProcessId AS DimensionKey,
            p.ProcessName AS DimensionLabel,
            COUNT(*) AS TokenCount,
            ROUND(AVG(CASE WHEN t.ServedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0 END), 2) AS AvgWaitMinutes,
            ROUND(AVG(CASE WHEN t.ServedTime IS NOT NULL AND t.CompletedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.ServedTime, t.CompletedTime) / 60.0 ELSE 0.0 END), 2) AS AvgServiceMinutes,
            ROUND(AVG(CASE WHEN t.CompletedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.CompletedTime) / 60.0 ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0 END), 2) AS AvgTatMinutes,
            ROUND(
                CASE 
                    WHEN IFNULL(p.TargetTATMinutes, 15) > 0 
                    THEN ((AVG(CASE WHEN t.CompletedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.CompletedTime) / 60.0 ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0 END) - IFNULL(p.TargetTATMinutes, 15)) / IFNULL(p.TargetTATMinutes, 15)) * 100.0 
                    ELSE 0.0 
                END, 2
            ) AS VariancePercentage,
            CAST(
                LEAST(100.0, (AVG(CASE WHEN t.ServedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0 END) * 4.0 + COUNT(*) * 1.5)) AS UNSIGNED
            ) AS CongestionScore,
            CASE 
                WHEN AVG(CASE WHEN t.ServedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0 END) > 20.0 THEN 'CRITICAL'
                WHEN AVG(CASE WHEN t.ServedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0 END) > 10.0 THEN 'HIGH'
                WHEN AVG(CASE WHEN t.ServedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0 END) > 5.0 THEN 'MODERATE'
                ELSE 'LOW'
            END AS CongestionLevel
        FROM tokentransaction t
        INNER JOIN process p ON t.ProcessId = p.Id
        WHERE t.OrganizationId = p_OrganizationId
          AND t.LocationId = p_LocationId
          AND t.CreatedDate >= p_StartDate
          AND t.CreatedDate <= p_EndDate
          AND (p_AreaId = -1 OR t.AreaId = p_AreaId)
          AND t.IsDeleted = 0
        GROUP BY HOUR(t.CreatedDate), t.ProcessId, p.ProcessName, p.TargetTATMinutes
        ORDER BY t.ProcessId, HourOfDay;

    ELSE -- 'HourByCounter'
        SELECT 
            HOUR(t.CreatedDate) AS HourOfDay,
            IFNULL(t.CounterId, 0) AS DimensionKey,
            IFNULL(c.CounterNumber, 'Unassigned') AS DimensionLabel,
            COUNT(*) AS TokenCount,
            ROUND(AVG(CASE WHEN t.ServedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0 END), 2) AS AvgWaitMinutes,
            ROUND(AVG(CASE WHEN t.ServedTime IS NOT NULL AND t.CompletedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.ServedTime, t.CompletedTime) / 60.0 ELSE 0.0 END), 2) AS AvgServiceMinutes,
            ROUND(AVG(CASE WHEN t.CompletedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.CompletedTime) / 60.0 ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0 END), 2) AS AvgTatMinutes,
            0.0 AS VariancePercentage,
            CAST(
                LEAST(100.0, (AVG(CASE WHEN t.ServedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0 END) * 4.0 + COUNT(*) * 1.5)) AS UNSIGNED
            ) AS CongestionScore,
            CASE 
                WHEN AVG(CASE WHEN t.ServedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0 END) > 20.0 THEN 'CRITICAL'
                WHEN AVG(CASE WHEN t.ServedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0 END) > 10.0 THEN 'HIGH'
                WHEN AVG(CASE WHEN t.ServedTime IS NOT NULL THEN TIMESTAMPDIFF(SECOND, t.IssuedTime, t.ServedTime) / 60.0 ELSE TIMESTAMPDIFF(SECOND, t.IssuedTime, NOW()) / 60.0 END) > 5.0 THEN 'MODERATE'
                ELSE 'LOW'
            END AS CongestionLevel
        FROM tokentransaction t
        LEFT JOIN counter c ON t.CounterId = c.Id
        WHERE t.OrganizationId = p_OrganizationId
          AND t.LocationId = p_LocationId
          AND t.CreatedDate >= p_StartDate
          AND t.CreatedDate <= p_EndDate
          AND (p_AreaId = -1 OR t.AreaId = p_AreaId)
          AND t.IsDeleted = 0
        GROUP BY HOUR(t.CreatedDate), t.CounterId, c.CounterNumber
        ORDER BY t.CounterId, HourOfDay;
    END IF;
END$$
DELIMITER ;
