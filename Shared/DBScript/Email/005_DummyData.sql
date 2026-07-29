-- Dummy Data for Email Settings
INSERT INTO EmailSettings (CenterId, SmtpHost, SmtpPort, SmtpUser, SmtpPass, SenderDescription, EnableSSL, BypassCertificateValidation, Active, CreatedBy)
VALUES 
(1, 'smtp.example.com', 587, 'admin@example.com', 'DummyEncryptedPassword123!', 'HQ Notifications', 1, 0, 1, 1),
(2, 'smtp.mailtrap.io', 2525, 'sandbox_user', 'sandbox_pass', 'Testing Center', 0, 1, 1, 1);

-- Dummy Data for Email Queue
INSERT INTO EmailQueue (CenterId, RecipientTo, Subject, Body, IsHtml, Status, Priority, CreatedBy)
VALUES 
(1, 'user1@example.com', 'Welcome to DNAQMS!', '<h1>Welcome!</h1><p>Thank you for signing up.</p>', 1, 0, 1, 1),
(1, 'user2@example.com', 'Your Invoice #10234', '<p>Please find your invoice attached.</p>', 1, 0, 0, 1),
(2, 'test@sandbox.com', 'Test Email', 'This is a test email body.', 0, 0, 0, 1),
(1, 'failed@example.com', 'Action Required', '<p>Your account is past due.</p>', 1, 2, 0, 1);

-- Dummy Data for Email Signatures
INSERT INTO EmailSignatures (CenterId, LogoUrl, LogoLink, TemplateHtml, CreatedBy)
VALUES 
(1, 'https://example.com/logo.png', 'https://example.com', '<div class="footer"><img src="{LogoUrl}" /> <p>Contact us at support@example.com</p></div>', 1);
