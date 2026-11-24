-- ============================================================================================
-- DQMS STAGE 3 MIGRATION: OVERHEAD TV QUEUE & STATION STATUS DISPLAY
-- Script Number: 37_DQMS_TV_Queue_Display.sql
-- Description: Enhances PR_S_PublicDisplayBoard to return both:
--              1. Active & Calling tokens across all counters (Result Set 1)
--              2. Upcoming Queue tokens (Waiting & On-Hold/Parked) for lounge display (Result Set 2)
-- ============================================================================================

DELIMITER //

DROP PROCEDURE IF EXISTS PR_S_PublicDisplayBoard //
CREATE PROCEDURE PR_S_PublicDisplayBoard (
    IN p_OrganizationId INT,
    IN p_LocationId     INT,
    IN p_AreaId         INT
)
BEGIN
    -- Result Set 1: Now Calling & Active Tokens (Assigned to Counters)
    SELECT 
        T.Id,
        T.TokenNumber,
        T.ProcessId,
        P.ProcessName,
        P.Prefix,
        T.CounterId,
        C.CounterNumber,
        C.CounterName,
        T.TokenStatus,
        T.CalledTime,
        CASE WHEN TIMESTAMPDIFF(SECOND, T.CalledTime, CURRENT_TIMESTAMP) <= 30 THEN 1 ELSE 0 END AS FlashAlert
    FROM TokenTransaction T
    INNER JOIN Process P ON T.ProcessId = P.Id
    INNER JOIN Counter C ON T.CounterId = C.Id
    WHERE T.OrganizationId = p_OrganizationId
      AND T.LocationId = p_LocationId
      AND (COALESCE(p_AreaId, -1) = -1 OR T.AreaId = p_AreaId)
      AND T.TokenStatus IN (18003, 18004) -- Calling, Active
      AND T.IsDeleted = 0
    ORDER BY T.CalledTime DESC;

    -- Result Set 2: Upcoming Queue & On-Hold Tokens (Public Waiting Lounge Display)
    -- Preserves privacy: excludes CustomerName and CustomerPhone
    SELECT 
        T.Id,
        T.TokenNumber,
        T.ProcessId,
        P.ProcessName,
        P.Prefix,
        T.PriorityTier,
        T.TokenStatus,
        T.CounterId,
        C.CounterNumber,
        C.CounterName,
        T.IssuedTime,
        T.CalledTime
    FROM TokenTransaction T
    INNER JOIN Process P ON T.ProcessId = P.Id
    LEFT JOIN Counter C ON T.CounterId = C.Id
    WHERE T.OrganizationId = p_OrganizationId
      AND T.LocationId = p_LocationId
      AND (COALESCE(p_AreaId, -1) = -1 OR T.AreaId = p_AreaId)
      AND T.TokenStatus IN (18001, 18002, 18005) -- Waiting, Queued, Hold
      AND T.IsDeleted = 0
    ORDER BY 
      CASE WHEN T.TokenStatus = 18005 THEN 1 ELSE 0 END ASC, -- Waiting/Queued first, On-Hold second
      T.PriorityTier DESC, -- VIP (19003) -> Senior (19002) -> Standard (19001)
      T.IssuedTime ASC
    LIMIT 20;

    -- Result Set 3: Waiting Count Summary per Process (Preserved for compatibility)
    SELECT 
        P.Id AS ProcessId,
        P.ProcessName,
        P.Prefix,
        COUNT(T.Id) AS WaitingCount
    FROM Process P
    LEFT JOIN TokenTransaction T ON P.Id = T.ProcessId AND T.TokenStatus IN (18001, 18002) AND T.IsDeleted = 0
    WHERE P.OrganizationId = p_OrganizationId AND P.IsActive = 1 AND P.IsDeleted = 0
    GROUP BY P.Id, P.ProcessName, P.Prefix
    ORDER BY P.ProcessName ASC;
END //

DELIMITER ;
