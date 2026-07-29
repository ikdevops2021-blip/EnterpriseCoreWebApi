-- ==========================================================
-- ==========================================================
-- Dummy Data for Email Module (MSSQL)
-- ==========================================================

-- Insert dummy EmailSettings for OrganizationId 1
IF NOT EXISTS (SELECT 1 FROM EmailSettings WHERE OrganizationId = 1)
BEGIN
    INSERT INTO EmailSettings (OrganizationId, SmtpHost, SmtpPort, SmtpUser, SmtpPass, SenderDescription, EnableSSL, BypassCertificateValidation, Active, CreatedBy, CreateDate, ModifiedBy, ModifyDate)
    VALUES 
    (1, 'smtp.mailtrap.io', 2525, 'dummy_user', 'encrypted_dummy_password', 'System Admin', 1, 1, 1, 1, GETUTCDATE(), 1, GETUTCDATE());
END

-- Insert dummy EmailSignatures for OrganizationId 1
IF NOT EXISTS (SELECT 1 FROM EmailSignatures WHERE OrganizationId = 1)
BEGIN
    INSERT INTO EmailSignatures (OrganizationId, LogoUrl, LogoLink, TemplateHtml, CreatedBy, CreateDate, ModifiedBy, ModifyDate)
    VALUES 
    (1, 'https://dummyimage.com/200x50/000/fff&text=Logo', 'https://example.com', '<div style="font-family: Arial, sans-serif;"><h3>Thank you for choosing us!</h3><br/><img src="{{LogoUrl}}" alt="Logo"/><br/><p>Best Regards,<br/>System Administrator</p></div>', 1, GETUTCDATE(), 1, GETUTCDATE());
END

-- Insert dummy Pending EmailQueue
IF NOT EXISTS (SELECT 1 FROM EmailQueue WHERE Subject = 'Welcome to the Platform!')
BEGIN
    INSERT INTO EmailQueue (OrganizationId, RecipientTo, Subject, Body, IsHtml, Status, Priority, RetryCount, CreatedBy, CreateDate, ModifiedBy, ModifyDate)
    VALUES 
    (1, 'test@example.com', 'Welcome to DNAQMS', '<h1>Welcome!</h1><p>We are glad to have you.</p>', 1, 0, 10, 0, 1, GETUTCDATE(), 1, GETUTCDATE()),
    (1, 'admin@example.com', 'System Alert', '<p>CPU usage is high.</p>', 1, 0, 15, 0, 1, GETUTCDATE(), 1, GETUTCDATE()),
    (1, 'user@example.com', 'Password Reset', '<p>Click here to reset your password.</p>', 1, 1, 5, 0, 1, DATEADD(hour, -2, GETUTCDATE()), 1, DATEADD(hour, -2, GETUTCDATE())),
    (1, 'manager@example.com', 'Weekly Report', '<p>Your report is ready.</p>', 1, 2, 5, 3, 1, DATEADD(day, -1, GETUTCDATE()), 1, DATEADD(day, -1, GETUTCDATE()));
END
