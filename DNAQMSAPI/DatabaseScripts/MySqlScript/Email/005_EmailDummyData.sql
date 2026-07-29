-- ==========================================================
-- Dummy Data for Email Module (MySQL)
-- ==========================================================

-- Insert dummy EmailSettings for OrganizationId 1
INSERT INTO EmailSettings (
    OrganizationId, SmtpHost, SmtpPort, SmtpUser, SmtpPass, 
    SenderDescription, EnableSSL, BypassCertificateValidation, Active, 
    CreatedBy, CreateDate, ModifiedBy, ModifyDate
) VALUES (
    1, 'smtp.mailtrap.io', 2525, 'dummy_user', 'encrypted_dummy_password', 
    'System Admin', 1, 1, 1, 
    1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP
);

-- Insert dummy EmailSignatures for OrganizationId 1
INSERT INTO EmailSignatures (
    OrganizationId, LogoUrl, LogoLink, TemplateHtml, 
    CreatedBy, CreateDate, ModifiedBy, ModifyDate
) VALUES (
    1, 'https://dummyimage.com/200x50/000/fff&text=Logo', 'https://example.com', 
    '<div style="font-family: Arial, sans-serif;"><h3>Thank you for choosing us!</h3><br/><img src="{{LogoUrl}}" alt="Logo"/><br/><p>Best Regards,<br/>System Administrator</p></div>', 
    1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP
);

-- Insert dummy Pending EmailQueue
INSERT INTO EmailQueue (
    QueueId, OrganizationId, RecipientTo, Subject, Body, 
    IsHtml, Status, Priority, 
    CreatedBy, CreateDate, ModifiedBy, ModifyDate
) VALUES (
    UUID(), 1, 'user1@example.com', 'Welcome to the Platform!', '<h1>Welcome!</h1><p>We are glad to have you on board.</p>', 
    1, 0, 10, 
    1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP
), (
    UUID(), 1, 'user2@example.com', 'Your Weekly Report', '<h2>Weekly Report</h2><p>Here is your data...</p>', 
    1, 0, 5, 
    1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP
);
