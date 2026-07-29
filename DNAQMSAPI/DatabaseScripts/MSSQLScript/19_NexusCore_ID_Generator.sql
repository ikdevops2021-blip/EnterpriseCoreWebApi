IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[m_key]') AND type in (N'U'))
BEGIN
    CREATE TABLE m_key (
        nf_cid INT NOT NULL,
        cf_key VARCHAR(20) NOT NULL,
        cf_prefix VARCHAR(20) NOT NULL,
        cf_keyvalue BIGINT NOT NULL,
        df_cmdate DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT PK_m_key PRIMARY KEY (nf_cid, cf_key, cf_prefix)
    );
END
GO

IF OBJECT_ID('dbo.pr_getid', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_getid;
GO

CREATE PROCEDURE pr_getid
    @PNF_CID INT,
    @PKEY VARCHAR(20),
    @PFKEY VARCHAR(20),
    @OID VARCHAR(30) OUTPUT,
    @PRTABLE BIT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @_errNo INT = 0;
    DECLARE @_errMsg VARCHAR(200) = '';
    DECLARE @_pfx VARCHAR(20) = '';
    DECLARE @_startSeq BIGINT = 1;
    DECLARE @_nextVal BIGINT = 0;
    DECLARE @_RValue VARCHAR(30) = '0';
    
    SET @OID = '0';
    
    -- 1. Determine Prefix & Starting Sequence Number based on PKEY logic
    IF (ISNULL(@PKEY,'') = 'TRNID') 
    BEGIN
        SET @_pfx = FORMAT(GETDATE(), 'yyMMdd');
        SET @_startSeq = CAST((@_pfx + '000001') AS BIGINT);
    END
    ELSE IF (ISNULL(@PKEY,'') = 'USRID')
    BEGIN
        SET @_pfx = CAST(@PNF_CID AS VARCHAR(20));
        SET @_startSeq = CAST((@_pfx + '001') AS BIGINT);
    END
    ELSE IF (ISNULL(@PKEY,'') = 'CNTID')
    BEGIN
        SET @_pfx = CAST(@PNF_CID AS VARCHAR(20));
        SET @_startSeq = CAST((@_pfx + '01') AS BIGINT);
    END
    ELSE IF (ISNULL(@PKEY,'') = 'AREAID') 
    BEGIN
        SET @_pfx = CAST(@PNF_CID AS VARCHAR(20));
        SET @_startSeq = CAST((@_pfx + '001') AS BIGINT);
    END
    ELSE IF (ISNULL(@PKEY,'') = 'PROID') 
    BEGIN
        SET @PFKEY = ISNULL(@PFKEY,'0');
        SET @_pfx = @PFKEY;
        SET @_startSeq = CAST((@_pfx + '001') AS BIGINT);
    END
    ELSE IF (ISNULL(@PKEY,'') = 'TKNAREAID') 
    BEGIN       
        SET @_pfx = CAST(@PNF_CID AS VARCHAR(20)) + FORMAT(GETDATE(), 'yyMMdd');
        SET @_startSeq = CAST((@_pfx + '01') AS BIGINT);
    END
    ELSE IF (ISNULL(@PKEY,'') = 'TESTTKN') 
    BEGIN
        SET @_pfx = FORMAT(GETDATE(), 'yyMMdd');
        SET @_startSeq = 1;
    END
    ELSE IF (ISNULL(@PKEY,'') = 'TKNID') 
    BEGIN
        SET @PFKEY = ISNULL(@PFKEY,'0');
        SET @_pfx = @PFKEY;
        SET @_startSeq = 1;
    END
    ELSE
    BEGIN
        SET @_errNo = 1;
        SET @_errMsg = 'Invalid Key';
        SET @OID = '0';
        IF (ISNULL(@PRTABLE, 0) = 1) 
        BEGIN
            SELECT '0' AS ID, @_errNo AS ErrNo, @_errMsg AS ErrMsg;
        END
        RETURN;
    END
    
    BEGIN TRY
        -- Single Atomic MERGE (Upsert) - Safe for direct app calls AND nested stored procedure calls
        MERGE m_key WITH (HOLDLOCK) AS target
        USING (SELECT @PNF_CID AS nf_cid, @PKEY AS cf_key, @_pfx AS cf_prefix) AS source
        ON (target.nf_cid = source.nf_cid AND target.cf_key = source.cf_key AND target.cf_prefix = source.cf_prefix)
        WHEN MATCHED THEN
            UPDATE SET cf_keyvalue = target.cf_keyvalue + 1, df_cmdate = GETDATE()
        WHEN NOT MATCHED THEN
            INSERT (nf_cid, cf_key, cf_prefix, cf_keyvalue, df_cmdate)
            VALUES (source.nf_cid, source.cf_key, source.cf_prefix, @_startSeq, GETDATE());

        SELECT @_nextVal = cf_keyvalue 
        FROM m_key 
        WHERE nf_cid = @PNF_CID AND cf_key = @PKEY AND cf_prefix = @_pfx;

        SET @_RValue = CAST(@_nextVal AS VARCHAR(30));
        SET @OID = @_RValue;
    END TRY
    BEGIN CATCH
        SET @_errNo = ERROR_NUMBER();
        SET @_errMsg = ERROR_MESSAGE();
        SET @_RValue = '0';
        SET @OID = '0';
    END CATCH;
    
    IF (ISNULL(@PRTABLE, 0) = 1) 
    BEGIN 
        SELECT @_RValue AS ID, @_errNo AS ErrNo, @_errMsg AS ErrMsg; 
    END
END
GO
