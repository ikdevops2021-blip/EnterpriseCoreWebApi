-- Seed dummy configuration for Typicode (a public testing API)
INSERT INTO [dbo].[ThirdPartyApiConfig] (
    [Name], [TenantId], [BaseUrl], [AuthType], 
    [IsGlobal], [IsActive], [CreatedBy], [ModifiedBy]
) VALUES (
    'TypicodeMock', NULL, 'https://jsonplaceholder.typicode.com', 0,
    1, 1, 1, 1
);

-- Seed a dummy payment gateway configuration (e.g. mock Stripe)
INSERT INTO [dbo].[ThirdPartyApiConfig] (
    [Name], [TenantId], [BaseUrl], [AuthType], [ApiKey],
    [IsGlobal], [IsActive], [CreatedBy], [ModifiedBy]
) VALUES (
    'MockStripeGateway', NULL, 'https://api.stripe.mock', 0, 'sk_test_mock_123',
    1, 1, 1, 1
);
