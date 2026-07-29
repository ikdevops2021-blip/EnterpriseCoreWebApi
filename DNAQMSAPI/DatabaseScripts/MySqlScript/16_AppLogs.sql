-- ==========================================================
-- AppLogs Table for NLog Database Target
-- Database: MySQL
-- ==========================================================

CREATE TABLE IF NOT EXISTS AppLogs (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    MachineName VARCHAR(200) NULL,
    Logged DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Level VARCHAR(10) NOT NULL,
    Message TEXT NOT NULL,
    Logger VARCHAR(300) NULL,
    Callsite VARCHAR(500) NULL,
    Exception TEXT NULL,
    VerboseInfo TEXT NULL,
    Url VARCHAR(2000) NULL,
    Action VARCHAR(300) NULL
);

CREATE INDEX IX_AppLogs_Level_Logged ON AppLogs(Level, Logged);
