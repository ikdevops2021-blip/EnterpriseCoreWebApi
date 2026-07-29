# PHASE 5 — GENERIC PAYMENT INTEGRATION FRAMEWORK (WITH UPI & QR EXTENSIONS)

## OBJECTIVE

Design and implement a production-ready, enterprise-grade, provider-agnostic Payment Integration Framework that integrates into the EXISTING solution.
Additionally, enhance the framework with deep support for UPI and Dynamic/Static QR Codes.

⚠️ IMPORTANT
DO NOT create a new solution.
DO NOT create a new project unless absolutely required.
Integrate everything into the existing architecture while following existing coding standards, folder structure, dependency injection, logging, authentication, authorization, naming conventions, response models, exception handling, testing strategy, and project patterns.
The payment framework must remain completely reusable and independent of business domains.
It should be possible to plug this framework into ERP, Hospital, School, CRM, POS, E-Commerce, SaaS, Desktop, Mobile, or any future project.
Maintain backward compatibility when extending the framework.

---

# ARCHITECTURE & PAYMENT METHOD SEPARATION

Follow existing project architecture. Maintain Clean Architecture, SOLID, DDD, Repository Pattern, Dependency Injection, Result Pattern, and existing Exception Handling.

**Payment Method Separation:**
Separate Payment Provider from Payment Method. A provider may support multiple payment methods.
*Payment Providers:* Razorpay, Stripe, PayPal, PhonePe, Amazon Pay, etc.
*Payment Methods:* UPI, QR Code, Credit Card, Debit Card, Net Banking, Wallet, EMI, Bank Transfer, etc.

---

# DATABASE

The Payment Framework MUST use the existing Organization Database. DO NOT create a separate Payment Database.
Extend the existing schema only where necessary (Prefer extending existing `PaymentTransactions` and `PaymentMethods`). Avoid creating duplicate tables.

Every table must include standard audit fields (Id, Guid, CreatedOn, CreatedBy, ModifiedOn, ModifiedBy, IsDeleted, RowVersion).

# DATABASE TABLES

Generate complete normalized schema for:
- PaymentProviders
- PaymentProviderCapabilities (Maps Providers to Supported Payment Methods)
- OrganizationPaymentProviders
- BranchPaymentProviders
- PaymentTransactions (Include fields for UpiIntentUri, QrContent, QrImage, ExpiryTime)
- PaymentTransactionHistory
- PaymentStatusHistory
- RefundRequests
- RefundTransactions
- PaymentLinks
- QRPayments
- PaymentSessions
- WebhookEvents
- WebhookLogs
- PaymentEvents
- AuditLogs
- ApiLogs
- ErrorLogs
- RetryQueue
- DeadLetterQueue
- IdempotencyKeys
- ProviderCredentials
- ProviderHealth
- SettlementReports
- ReconciliationReports
- CurrencyMaster
- ExchangeRates

---

# PROVIDER FRAMEWORK & CAPABILITIES

Create a generic provider architecture. Design for unlimited future providers. Adding a new provider must require only creating a new Provider Adapter.

**Provider Capabilities:**
Enhance Provider Capabilities to include supported payment methods. The framework should automatically expose only supported payment methods.
- *Razorpay Supports:* UPI, QR, Cards, Net Banking, Wallet
- *PhonePe Supports:* UPI, QR, Wallet
- *Stripe Supports:* Cards, Wallet, Regional Payment Methods

Interfaces:
- IPaymentGateway, IPaymentGatewayFactory, IPaymentProvider, IPaymentRouter, IWebhookProcessor, IRefundService, IQRCodeService, IPaymentLinkService

---

# ROUTING ENGINE

Routing decisions must be based on:
- Organization
- Branch
- Payment Method
- Enabled Provider
- Provider Priority
- Provider Health

The routing engine must actively determine both the Provider and the Payment Method.

---

# PAYMENT & UPI FEATURES

Implement standard features:
- Create Payment, Capture Payment, Cancel Payment, Verify Payment, Refund, Partial Refund
- Generate Payment Link, Expire Payment Link, Sync Transaction, Retry Failed Payment, Health Check

**UPI & QR Support Features:**
- UPI Intent
- Dynamic QR & Static QR (Expiry, Refresh, Download, Validation)
- Collect Request (if provider supports)
- UPI Status Verification & Refund
- UPI Webhook Processing
- QR Image Generation

---

# API ENHANCEMENTS

Add generic APIs and specialized UPI APIs (Reuse existing payment lifecycle and logging):
- `POST /payments/upi`
- `POST /payments/upi/qr`
- `POST /payments/upi/intent`
- `GET /payments/upi/status/{id}`
- `POST /payments/upi/refund`
- `POST /payments/upi/webhook`

# UI RESPONSE

Return a normalized response for all payments (including UPI). Include:
- PaymentId
- PaymentMethod
- Provider
- QR Image (if generated)
- QR Content
- UPI Intent URI (if available)
- Expiry Time
- Transaction Status

---

# PAYMENT LIFE CYCLE

Track complete lifecycle. Never overwrite status. Maintain history:
Created -> Pending -> Authorized -> Captured -> Success -> Completed -> Failed -> Cancelled -> Expired -> Refund Requested -> Refund Processing -> Refund Completed -> Partial Refund -> Chargeback -> Disputed -> Settlement Pending -> Settled -> Reconciled

---

# SECURITY

Implement:
- Existing JWT Authentication & Authorization
- API Key Support & Encrypted Provider Credentials
- Webhook Signature Validation
- Idempotency & Replay Attack Protection
- Secret Encryption & Rate Limiting

---

# LOGGING & AUDIT

Log EVERYTHING using the existing logging framework (API Requests/Responses, Webhooks, Errors, Execution Time, Correlation Id).
Track UPI specific actions: QR Generated, QR Scanned, Intent Created, Intent Opened, Payment Authorized.
Audit everything (Who, When, What, Old Value, New Value, IP Address, Device). Nothing should be deleted (Soft delete only).

---

# WEBHOOK ENGINE

Support Signature Validation, Duplicate Detection, Retry, Dead Letter Queue, Event Replay, and Background Processing.

---

# REPORTING & DASHBOARD

Generate APIs for Collection Summaries (Daily/Monthly/Yearly/Branch/Org/Provider), Refund Reports, Gateway Performance, Total/Pending/Failed Payments, Response Time, and Provider Health.

---

# EVENTS

Publish domain events: PaymentCreated, PaymentSucceeded, PaymentFailed, RefundRequested, RefundCompleted, WebhookReceived, SettlementCompleted.

---

# TESTING & DOCUMENTATION

Generate:
- Unit Tests, Integration Tests, Mock Provider, Sandbox Provider, Performance Tests (Target minimum 90% coverage).
- Architecture, ER, Sequence, and Class Diagrams.
- Swagger, XML Documentation, README, Provider Integration Guide.

---

# ACCEPTANCE CRITERIA

The implementation must:
✔ Integrate into the existing project without breaking existing functionality.
✔ Follow existing architecture and GLOBAL_RULES.md.
✔ Be fully provider-agnostic and support unlimited future payment methods without redesign.
✔ Support organization-level deployment and branch-level provider configuration.
✔ Follow Dapper DB Factory standards and use Stored Procedures where appropriate.
✔ Be fully backward compatible.
✔ Be production-ready, enterprise-grade, fully documented, and fully unit tested.