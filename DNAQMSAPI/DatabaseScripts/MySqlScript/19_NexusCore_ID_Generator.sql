CREATE TABLE IF NOT EXISTS `m_key` (
  `nf_cid` INT(4) NOT NULL,
  `cf_key` VARCHAR(20) NOT NULL,
  `cf_prefix` VARCHAR(20) NOT NULL,
  `cf_keyvalue` BIGINT NOT NULL,
  `df_cmdate` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`nf_cid`, `cf_key`, `cf_prefix`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DELIMITER //

DROP PROCEDURE IF EXISTS `pr_getid` //

CREATE PROCEDURE `pr_getid`(
    IN  PNF_CID     INT(4),
    IN  PKEY        VARCHAR(20),
    IN  PFKEY       VARCHAR(20),
    OUT OID         VARCHAR(30),
    IN  PRTABLE     TINYINT(1)
)
proc_main: BEGIN
    DECLARE _errNo INT DEFAULT 0;
    DECLARE _errMsg VARCHAR(200) DEFAULT '';
    DECLARE _pfx VARCHAR(20) DEFAULT '';
    DECLARE _startSeq BIGINT DEFAULT 1;
    DECLARE _nextVal BIGINT DEFAULT 0;
    DECLARE _RValue VARCHAR(30) DEFAULT '0';
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        GET CURRENT DIAGNOSTICS CONDITION 1 _errNo = MYSQL_ERRNO, _errMsg = MESSAGE_TEXT;
        SET OID = '0';
        IF (IFNULL(PRTABLE, 0) = 1) THEN
            SELECT '0' AS ID, _errNo AS ErrNo, _errMsg AS ErrMsg;
        END IF;
    END;
    
    SET OID = '0';

    -- 1. Determine Prefix & Starting Sequence Number based on PKEY logic
    IF (IFNULL(PKEY, '') = 'TRNID') THEN
        SET _pfx = DATE_FORMAT(CURRENT_DATE(), '%y%m%d');
        SET _startSeq = CAST(CONCAT(_pfx, '000001') AS SIGNED);
    ELSEIF (IFNULL(PKEY, '') = 'USRID') THEN
        SET _pfx = CAST(PNF_CID AS CHAR);
        SET _startSeq = CAST(CONCAT(_pfx, '001') AS SIGNED);
    ELSEIF (IFNULL(PKEY, '') = 'CNTID') THEN
        SET _pfx = CAST(PNF_CID AS CHAR);
        SET _startSeq = CAST(CONCAT(_pfx, '01') AS SIGNED);
    ELSEIF (IFNULL(PKEY, '') = 'AREAID') THEN
        SET _pfx = CAST(PNF_CID AS CHAR);
        SET _startSeq = CAST(CONCAT(_pfx, '001') AS SIGNED);
    ELSEIF (IFNULL(PKEY, '') = 'PROID') THEN
        SET PFKEY = IFNULL(PFKEY, '0');
        SET _pfx = PFKEY;
        SET _startSeq = CAST(CONCAT(_pfx, '001') AS SIGNED);
    ELSEIF (IFNULL(PKEY, '') = 'TKNAREAID') THEN
        SET _pfx = CONCAT(PNF_CID, DATE_FORMAT(CURRENT_DATE(), '%y%m%d'));
        SET _startSeq = CAST(CONCAT(_pfx, '01') AS SIGNED);
    ELSEIF (IFNULL(PKEY, '') = 'TESTTKN') THEN
        SET _pfx = DATE_FORMAT(CURRENT_DATE(), '%y%m%d');
        SET _startSeq = 1;
    ELSEIF (IFNULL(PKEY, '') = 'TKNID') THEN
        SET PFKEY = IFNULL(PFKEY, '0');
        SET _pfx = PFKEY;
        SET _startSeq = 1;
    ELSE
        SET _errNo := 1;
        SET _errMsg := 'Invalid Key';
        SET OID := '0';
        IF (IFNULL(PRTABLE, 0) = 1) THEN
            SELECT '0' AS ID, _errNo AS ErrNo, _errMsg AS ErrMsg;
        END IF;
        LEAVE proc_main;
    END IF;

    -- 2. Single Atomic Upsert (Safe for direct app calls AND caller stored procedures)
    -- In InnoDB, INSERT ... ON DUPLICATE KEY UPDATE implicitly locks the row atomically without START TRANSACTION.
    INSERT INTO m_key (nf_cid, cf_key, cf_prefix, cf_keyvalue, df_cmdate)
    VALUES (PNF_CID, PKEY, _pfx, _startSeq, NOW())
    ON DUPLICATE KEY UPDATE 
        cf_keyvalue = cf_keyvalue + 1,
        df_cmdate = NOW();

    SELECT cf_keyvalue INTO _nextVal 
    FROM m_key 
    WHERE nf_cid = PNF_CID AND cf_key = PKEY AND cf_prefix = _pfx;

    SET _RValue = CAST(_nextVal AS CHAR);
    SET OID = _RValue;

    IF (IFNULL(PRTABLE, 0) = 1) THEN 
        SELECT _RValue AS ID, 0 AS ErrNo, '' AS ErrMsg; 
    END IF;
END //

DELIMITER ;
