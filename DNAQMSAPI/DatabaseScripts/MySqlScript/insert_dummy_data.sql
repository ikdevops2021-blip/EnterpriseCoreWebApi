-- Insert Plans
INSERT INTO SubscriptionPlans (PlanId, PlanName, Price, BillingCycleMonths, IsActive, CreatedDate) VALUES 
(1, 'Free Plan', 0.00, 1, 1, UTC_TIMESTAMP()),
(2, 'Pro Plan', 49.99, 1, 1, UTC_TIMESTAMP()),
(3, 'Enterprise Plan', 199.99, 1, 1, UTC_TIMESTAMP());

-- Insert Plan Features
INSERT INTO PlanFeatures (PlanId, FeatureKey, FeatureValue) VALUES 
(1, 'MaxUsers', '5'),
(2, 'MaxUsers', '50'),
(3, 'MaxUsers', '999999'),
(2, 'MaxApiUsage', '10000');

-- Insert Tenant Subscription
INSERT INTO TenantSubscriptions (SubscriptionId, TenantId, PlanId, Status, StartDate, ExpiryDate, AutoRenew, CreatedDate, ModifiedDate)
VALUES ('00000000-0000-0000-0000-111111111111', '00000000-0000-0000-0000-999999999999', 2, 1, UTC_TIMESTAMP(), DATE_ADD(UTC_TIMESTAMP(), INTERVAL 30 DAY), 1, UTC_TIMESTAMP(), UTC_TIMESTAMP());

-- Insert Billing History
INSERT INTO BillingHistory (BillingId, SubscriptionId, BillingStart, BillingEnd, Amount, InvoiceNumber, Paid, TotalTax, NetAmount, GrossAmount)
VALUES ('00000000-0000-0000-0000-222222222222', '00000000-0000-0000-0000-111111111111', UTC_TIMESTAMP(), DATE_ADD(UTC_TIMESTAMP(), INTERVAL 30 DAY), 49.99, 'INV-001', 1, 5.00, 49.99, 54.99);

-- Insert Invoice Metadata
INSERT INTO InvoiceMetadata (InvoiceId, CustomerVatNumber, TenantVatNumber, IsReverseCharge, CountrySpecificData, CreatedBy)
VALUES ('00000000-0000-0000-0000-222222222222', 'VAT-CUST-5555', 'VAT-TNT-7777', 0, '{"region": "EU", "compliance_code": "DEMO-999"}', 0);

-- Insert Usage Tracking
INSERT INTO UsageTracking (UsageId, TenantId, FeatureKey, UsageCount, PeriodStart, PeriodEnd)
VALUES ('00000000-0000-0000-0000-333333333333', '00000000-0000-0000-0000-999999999999', 'MaxApiUsage', 150, UTC_TIMESTAMP(), DATE_ADD(UTC_TIMESTAMP(), INTERVAL 30 DAY));
