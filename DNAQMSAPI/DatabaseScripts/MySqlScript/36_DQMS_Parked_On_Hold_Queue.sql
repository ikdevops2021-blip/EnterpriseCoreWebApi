-- ============================================================================
-- DQMS DATABASE MIGRATION SCRIPT 36
-- Feature: Dedicated "Parked / On-Hold" Panel Procedure Refinements
-- Enables counters to retrieve active tokens (18003, 18004) and held/parked tokens (18005)
-- ============================================================================

DELIMITER //

DROP PROCEDURE IF EXISTS PR_S_TokenQueue //
CREATE PROCEDURE PR_S_TokenQueue (
    IN p_OrganizationId INT,
    IN p_LocationId     INT,
    IN p_ProcessId      INT,
    IN p_CounterId      INT
)
BEGIN
    -- 1. Active / Called Token for this Counter (18003, 18004) & Held/Parked Tokens (18005)
    SELECT * FROM TokenTransaction
    WHERE OrganizationId = p_OrganizationId
      AND LocationId = p_LocationId
      AND (
          (CounterId = p_CounterId AND TokenStatus IN (18003, 18004))
          OR
          (TokenStatus = 18005 AND (CounterId = p_CounterId OR (COALESCE(p_ProcessId, 0) > 0 AND ProcessId = p_ProcessId)))
      )
      AND IsDeleted = 0
    ORDER BY ModifiedDate DESC;

    -- 2. Waiting Queue List for Process
    SELECT * FROM TokenTransaction
    WHERE OrganizationId = p_OrganizationId
      AND LocationId = p_LocationId
      AND (COALESCE(p_ProcessId, -1) = -1 OR ProcessId = p_ProcessId)
      AND TokenStatus IN (18001, 18002) -- Queued, Waiting
      AND IsDeleted = 0
    ORDER BY PriorityTier DESC, IssuedTime ASC;
END //

DELIMITER ;
