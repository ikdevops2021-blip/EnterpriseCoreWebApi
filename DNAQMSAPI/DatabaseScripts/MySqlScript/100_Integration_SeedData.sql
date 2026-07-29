-- Seed Data for APIIntegrations and ApiEndpoints

-- 1. Insert Global API Integrations
INSERT INTO `APIIntegrations` (
    `IntegrationID`, `TenantId`, `ProviderName`, `Description`, `BaseUrl`, `Active`, `AuditLevel`, `AuthType`, `ApiKey`, `CreatedBy`, `ModifiedBy`
) VALUES 
(1, 1, 'TwilioSMS', 'Twilio SMS & Messaging API Gateway', 'https://api.twilio.com/2010-04-01', 1, 2, 0, 'twilio_dummy_api_key_8899', 1, 1),
(2, 1, 'MetaWhatsApp', 'WhatsApp Business Cloud API', 'https://graph.facebook.com/v18.0', 1, 2, 1, 'whatsapp_bearer_token_9900', 1, 1),
(3, 1, 'StripePayment', 'Stripe Payment Gateway', 'https://api.stripe.com/v1', 1, 2, 1, 'stripe_sk_test_51Mz987', 1, 1)
ON DUPLICATE KEY UPDATE `ProviderName` = VALUES(`ProviderName`);

-- 2. Insert API Endpoints for Integration Providers
INSERT INTO `ApiEndpoints` (
    `EndpointID`, `IntegrationID`, `ActionName`, `RelativePath`, `HttpMethod`, `Description`, `Active`, `CreatedBy`, `ModifiedBy`
) VALUES 
(1, 1, 'SendSMS', '/Accounts/AC12345/Messages.json', 'POST', 'Send SMS message via Twilio', 1, 1, 1),
(2, 1, 'VerifyOTP', '/Accounts/AC12345/Verify.json', 'POST', 'Verify OTP via Twilio', 1, 1, 1),
(3, 2, 'SendWhatsAppMessage', '/1006093463/messages', 'POST', 'Send WhatsApp text/template message via Meta API', 1, 1, 1),
(4, 3, 'CreatePaymentIntent', '/payment_intents', 'POST', 'Create Stripe Payment Intent', 1, 1, 1)
ON DUPLICATE KEY UPDATE `ActionName` = VALUES(`ActionName`);

