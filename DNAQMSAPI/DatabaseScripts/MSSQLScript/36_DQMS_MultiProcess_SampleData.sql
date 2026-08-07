-- ============================================================================================
-- DQMS STAGE 1: MULTI-PROCESS & MULTI-STEP PIPELINE SEED SAMPLE DATA (MSSQL)
-- Script Number: 36_DQMS_MultiProcess_SampleData.sql
-- Description: Inserts sample seed data testing multi-process workflows, sub-tokens, 
--              and multi-step process pipelines across areas and counters.
-- ============================================================================================

SET NOCOUNT ON;

-- 1. Insert Areas & Zones
IF NOT EXISTS (SELECT 1 FROM [Area] WHERE [AreaCode] = 'AZ-01')
BEGIN
    INSERT INTO [Area] ([AreaCode], [OrganizationId], [LocationId], [AreaName], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [IsDeleted])
    VALUES 
    ('AZ-01', 1, 1, 'Main Service Hall A', 'Primary patient registration & triage area', 1, 1, GETDATE(), 1, GETDATE(), 0),
    ('AZ-02', 1, 1, 'Priority Wing B', 'Elderly, disabled, and pregnancy assist wing', 1, 1, GETDATE(), 1, GETDATE(), 0),
    ('AZ-03', 1, 1, 'Express Desk C', 'Quick inquiry & fast-track document collection', 1, 1, GETDATE(), 1, GETDATE(), 0),
    ('AZ-04', 1, 1, 'VIP Lounge D', 'Executive & VIP private consultation lounge', 1, 1, GETDATE(), 1, GETDATE(), 0),
    ('AZ-05', 1, 1, 'Pharmacy Outpatient E', 'Medication dispensing and consultation windows', 1, 1, GETDATE(), 1, GETDATE(), 0);
END

-- 2. Insert Process Pipelines (Services) with AllowSubTokens enabled
IF NOT EXISTS (SELECT 1 FROM [Process] WHERE [ProcessCode] = 'PROC-101')
BEGIN
    INSERT INTO [Process] ([ProcessCode], [OrganizationId], [ProcessName], [Prefix], [TargetTATMinutes], [AllowSubTokens], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [IsDeleted])
    VALUES 
    ('PROC-101', 1, 'Comprehensive Patient Registration & Triage', 'A', 25, 1, 1, 1, GETDATE(), 1, GETDATE(), 0),
    ('PROC-201', 1, 'Executive Health Screening Workflow', 'B', 45, 1, 1, 1, GETDATE(), 1, GETDATE(), 0),
    ('PROC-301', 1, 'Express Fast-Track Billing & Cashier', 'C', 10, 0, 1, 1, GETDATE(), 1, GETDATE(), 0),
    ('PROC-401', 1, 'VIP Specialist Consultation', 'V', 30, 1, 1, 1, GETDATE(), 1, GETDATE(), 0),
    ('PROC-501', 1, 'Prescription Dispensing & Advisory', 'E', 15, 0, 1, 1, GETDATE(), 1, GETDATE(), 0);
END

-- 3. Insert Multi-Step Process Pipeline Mapping (ProcessStep)
DECLARE @Proc101Id INT = (SELECT TOP 1 [Id] FROM [Process] WHERE [ProcessCode] = 'PROC-101' AND [IsDeleted] = 0);
DECLARE @Proc201Id INT = (SELECT TOP 1 [Id] FROM [Process] WHERE [ProcessCode] = 'PROC-201' AND [IsDeleted] = 0);

IF @Proc101Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [ProcessStep] WHERE [ProcessId] = @Proc101Id)
BEGIN
    INSERT INTO [ProcessStep] ([ProcessId], [StepOrder], [StepName], [TargetTATMinutes], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [IsDeleted])
    VALUES 
    (@Proc101Id, 1, 'Step 1: Patient Identity & File Check-In', 5, 1, 1, GETDATE(), 1, GETDATE(), 0),
    (@Proc101Id, 2, 'Step 2: Clinical Vital Signs & Triage', 10, 1, 1, GETDATE(), 1, GETDATE(), 0),
    (@Proc101Id, 3, 'Step 3: General Doctor Assessment', 15, 1, 1, GETDATE(), 1, GETDATE(), 0),
    (@Proc101Id, 4, 'Step 4: Billing & Medication Dispensing', 5, 1, 1, GETDATE(), 1, GETDATE(), 0);
END

IF @Proc201Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [ProcessStep] WHERE [ProcessId] = @Proc201Id)
BEGIN
    INSERT INTO [ProcessStep] ([ProcessId], [StepOrder], [StepName], [TargetTATMinutes], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [IsDeleted])
    VALUES 
    (@Proc201Id, 1, 'Step 1: Executive Lounge Check-In & Breakfast', 10, 1, 1, GETDATE(), 1, GETDATE(), 0),
    (@Proc201Id, 2, 'Step 2: Pathology Blood Draw & Diagnostics', 15, 1, 1, GETDATE(), 1, GETDATE(), 0),
    (@Proc201Id, 3, 'Step 3: ECG & Cardiac Stress Evaluation', 20, 1, 1, GETDATE(), 1, GETDATE(), 0),
    (@Proc201Id, 4, 'Step 4: Specialist Final Medical Report Consultation', 15, 1, 1, GETDATE(), 1, GETDATE(), 0);
END
