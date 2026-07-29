# DNAQMS Enterprise API — Complete Application Feature & Operational Manual

Welcome to the definitive developer, architectural, and operational manual for **DNAQMS Enterprise API**. This document provides an exhaustive, end-to-end guide covering **all 12 functional modules and 16 API controller suites**, including a complete catalog of **NexusCore Categories, Parameters, and System Configuration Keys**.

---

## 📐 1. Master System Architecture & Module Map

DNAQMS API is engineered as a **High-Performance Modular Monolith** on **.NET 8**, **Dapper ORM**, and dual SQL database engines (**MySQL 8.0+** & **MS SQL Server 2019+**).

```
                                ┌──────────────────────────────────────────────┐
                                │           DNAQMS ENTERPRISE API              │
                                └──────────────────────┬───────────────────────┘
                                                       │
         ┌───────────────────────┬─────────────────────┼───────────────────────┬───────────────────────┐
         ▼                       ▼                     ▼                       ▼                       ▼
 ┌───────────────┐       ┌───────────────┐     ┌───────────────┐       ┌───────────────┐       ┌───────────────┐
 │ 1. Identity & │       │ 2. Third-Party│     │ 3. Generic    │       │ 4. Center     │       │ 5. Location & │
 │    Auth       │       │    Integration│     │    Email      │       │    Notification│      │    User Profiles│
 ├───────────────┤       ├───────────────┤     ├───────────────┤       ├───────────────┤       ├───────────────┤
 │ • UserCode    │       │ • AuthFactory │     │ • SMTP Queue  │       │ • Templates   │       │ • Countries   │
 │ • Unified Login       │ • TokenManager│     │ • Signatures  │       │ • In-App Feed │       │ • States/Cities│
 │ • API Key / JWT       │ • GenericClient     │ • Health Views│       │ • Channel Route       │ • Address/Contact│
 └───────────────┘       └───────────────┘     └───────────────┘       └───────────────┘       └───────────────┘
         │                       │                     │                       │                       │
         ▼                       ▼                     ▼                       ▼                       ▼
 ┌───────────────┐       ┌───────────────┐     ┌───────────────┐       ┌───────────────┐       ┌───────────────┐
 │ 6. NexusCore  │       │ 7. SaaS Sub-  │     │ 8. Automated  │       │ 9. Universal  │       │ 10. Multi-    │
 │    Config     │       │    scription  │     │    Tax Engine │       │    Financials │       │    Tenant     │
 ├───────────────┤       ├───────────────┤     ├───────────────┤       ├───────────────┤       ├───────────────┤
 │ • Categories  │       │ • Tenant Plans│     │ • Multi-Juris │       │ • Revenue Stats       │ • Cloud Storage│
 │ • 1k Ranges   │       │ • Feature Gate│     │ • Tax Rules   │       │ • Invoice Engine      │ • Payment Gate │
 │ • ID Generator│       │ • Metering    │     │ • Audit Logs  │       │ • Tax Reports │       │ • Webhooks    │
 └───────────────┘       └───────────────┘     └───────────────┘       └───────────────┘       └───────────────┘
```

---

## 🔑 Module 1: Identity, UserCode & Authentication (`AuthController` & `ApiKeyController`)

### Capabilities
- **Custom User Handle (`UserCode`)**: Readable user identifier (defaults to Email, fully editable, unique index enforced).
- **Unified Login (`Identifier`)**: Accepts `UserCode`, `Email`, or `Mobile Number` in a single input field.
- **Dual Authentication Protocols**: Supports JWT Bearer tokens for user sessions & SHA256 hashed API Keys for server-to-server integrations.
- **Title & Gender Salutations**: Linked to NexusCore Configuration parameters (`C_TITLE` category 2 & `C_GENDER` category 1).

### Key API Endpoints
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `POST` | `/api/v1/auth/login` | Unified authentication. Accepts UserCode/Email/Mobile. Returns JWT. |
| `POST` | `/api/v1/auth/register` | User registration with UserCode, Title, Gender, and Profile properties. |
| `GET` | `/api/v1/apikeys` | Lists active server-to-server API keys for target user. |
| `POST` | `/api/v1/apikeys/generate` | Generates a new SHA256 hashed API key. |
| `POST` | `/api/v1/apikeys/revoke` | Revokes an existing API key. |

---

## 🔌 Module 2: Third-Party API Integration Gateway (`IntegrationController`)

### Capabilities
- **Extensible Auth Providers**: Plug-and-play AuthProviderFactory supporting `ApiKey`, `BasicAuth`, `OAuth2` (Client Credentials / Password Flow), and custom `JWT` tokens.
- **TokenManager Caching**: Automatically handles OAuth2 token fetching, expiration tracking, and transparent refresh.
- **Generic API Client (`GenericApiClient`)**: Dispatches HTTP requests with automatic header injection, retry strategies, and rate limiting.
- **Robust Integration Audit Logging (`ApiAuditLog`)**: Logs full request/response metadata, execution timings, HTTP status codes, and payload sizes.

### Key API Endpoints
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/api/v1/integration/integrations` | Retrieves third-party API integration configurations. |
| `POST` | `/api/v1/integration/integrations` | Registers or updates a third-party API integration profile. |
| `GET` | `/api/v1/integration/endpoints` | Lists configured API endpoints for an integration. |
| `POST` | `/api/v1/integration/endpoints` | Registers an API endpoint path and auth configuration. |
| `POST` | `/api/v1/integration/execute` | Executes an outbound call to a third-party API with automatic auth injection & audit logging. |
| `GET` | `/api/v1/integration/logs` | Queries outbound third-party API execution audit logs. |

---

## 📧 Module 3: Generic Email Gateway & Dispatcher (`EmailController`)

### Capabilities
- **Tenant-Aware SMTP Configuration (`EmailSettings`)**: Organization-specific SMTP server, port, credentials, and SSL settings.
- **Asynchronous Mail Queue (`EmailQueue`)**: High-performance background dispatching with retry count, max retries, and status tracking (0: Pending, 1: Sent, 2: Failed).
- **Reusable HTML Signatures (`EmailSignatures`)**: Organization-specific HTML signature templates appended to outbound communications.
- **Mail Health Reporting Views (`EmailViews`)**: Provides daily dispatch counts, success rates, and queue health statistics.

### Key API Endpoints
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `POST` | `/api/v1/email/send` | Enqueues an email for asynchronous background dispatching. |
| `GET` | `/api/v1/email/queue/{queueId}/status` | Checks delivery status of an enqueued email. |
| `GET` | `/api/v1/email/settings` | Gets SMTP settings for an Organization. |
| `POST` | `/api/v1/email/settings` | Saves/updates SMTP settings for an Organization. |
| `GET` | `/api/v1/email/signatures` | Lists HTML email signatures. |

---

## 🔔 Module 4: Center-Aware Notification & Intimation Engine (`NotificationsController`)

### Capabilities
- **Center/Organization Customization**: Each Center (`OrganizationId`) can override global notification templates or fall back to global defaults.
- **Multi-Channel Dispatch Routing**: Configurable per template via `SendInApp`, `SendEmail`, `SendSMS` channel flags.
- **Event Catalog Integration (`C_NOTIFICATION_EVENT`)**: Mapped to NexusCore Category `17`:
  - `17001`: `PAYMENT_RECEIVED`
  - `17002`: `INTERNAL_ANNOUNCEMENT`
  - `17003`: `SYSTEM_ALERT`
  - `17004`: `APPROVAL_REQUESTED`
- **Dynamic Placeholder Interpolation**: Substitutes variables like `{UserName}`, `{UserCode}`, `{Amount}`, `{CenterName}` at runtime.
- **In-App Bell Feed & Badge Counter**: Real-time notification feed per user with unread counts and read-state management.

### Key API Endpoints
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `POST` | `/api/v1/notifications/send` | Dispatches event to target users across enabled channels. |
| `GET` | `/api/v1/notifications` | Returns paginated In-App notification feed for current user (`isRead`, `pageNumber`, `pageSize`). |
| `GET` | `/api/v1/notifications/unread-count` | Returns unread notification count for header bell badge icon. |
| `PUT` | `/api/v1/notifications/{id}/read` | Marks single notification as read. |
| `PUT` | `/api/v1/notifications/read-all` | Marks all notifications as read for current user. |
| `GET` | `/api/v1/notifications/templates` | Lists notification templates (Center-specific or Global). |
| `POST` | `/api/v1/notifications/templates` | Saves/updates a Center-specific notification template. |

---

## 🌍 Module 5: World Location Master & User Profiles (`LocationsController` & `UserProfilesController`)

### Capabilities
- **Pre-Seeded World Location Master**: 250 Countries, 5,308 States (with `StateCode`), and 152,970 Cities (with official IATA `CityCode`).
- **User Addresses**: Manages home, office, billing, and shipping addresses with primary address designation.
- **User Contacts**: Manages phones, mobiles, emails, and social profiles with `IsEmergency` contact flags.

### Key API Endpoints
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/api/v1/locations/countries` | Gets list of active countries (supports search & pagination). |
| `GET` | `/api/v1/locations/countries/{countryId}/states` | Gets states belonging to a country. |
| `GET` | `/api/v1/locations/states/{stateId}/cities` | Gets cities belonging to a state. |
| `GET` | `/api/v1/users/{userId}/addresses` | Gets user address list. |
| `POST` | `/api/v1/users/{userId}/addresses` | Saves/updates user address. |
| `GET` | `/api/v1/users/{userId}/contacts` | Gets user contact list. |
| `POST` | `/api/v1/users/{userId}/contacts` | Saves/updates user contact. |

---

## ⚙️ Module 6: NexusCore System Configuration (`ConfigurationController`)

### Capabilities
- **Hierarchical Catalog**: Stores categories (`ConfigCategory`), parameters (`ConfigParameters`), and key-value pairs (`SystemConfigurationKeys`).
- **Incremental Parameter Ranges**: Parameter IDs organized in 1,000-item ranges per category.
- **Key-Based ID Generator**: Key-based auto-incrementing sequence generator for business codes.

### 📋 Full Catalog of NexusCore Categories (1..17)

| CategoryID | CategoryCode | CategoryName | Purpose & System Description | Parameter Range |
| :--- | :--- | :--- | :--- | :--- |
| **1** | `GEN` | `C_GENDER` | Gender salutation and identification parameters | `1001 – 1999` |
| **2** | `TITLE` | `C_TITLE` | Name salutation titles (Mr., Ms., Dr., Prof., etc.) | `2001 – 2999` |
| **3** | `BLD` | `C_BLOODGROUP` | Human blood group classifications (A+, B+, O+, etc.) | `3001 – 3999` |
| **4** | `ADRTYPE` | `C_ADDRESSTYPE` | Address categories (Home, Office, Billing, Shipping) | `4001 – 4999` |
| **5** | `CNTTYPE` | `C_CONTACTTYPE` | Communication channel types (Mobile, Work Phone, Social) | `5001 – 5999` |
| **6** | `UNITTYPE` | `C_UNITTYPE` | Unit measurement parameters (KG, LTR, SQM, HRS, BOX) | `6001 – 6999` |
| **7** | `MARITAL` | `C_MARITALSTATUS` | Marital & civil status options (Single, Married, Divorced) | `7001 – 7999` |
| **8** | `DOCTYPE` | `C_DOCUMENTTYPE` | Verification document types (Passport, National ID, PAN) | `8001 – 8999` |
| **9** | `CURRENCY` | `C_CURRENCY` | Global transaction currencies (USD, EUR, GBP, INR, etc.) | `9001 – 9999` |
| **10** | `PRIORITY` | `C_PRIORITYLEVEL` | Task and notification priority levels (Low, Medium, High) | `10001 – 10999` |
| **11** | `SEVERITY` | `C_SEVERITY` | Risk and defect severity levels (Minor, Major, Critical) | `11001 – 11999` |
| **12** | `NOTIFTYPE` | `C_NOTIFICATIONTYPE` | Notification delivery channels (Email, SMS, In-App) | `12001 – 12999` |
| **13** | `LANG` | `C_LANGUAGE` | Supported locales and UI languages (en, es, fr, de, hi) | `13001 – 13999` |
| **14** | `PAYMENT` | `C_PAYMENTMETHOD` | Payment methods (Credit Card, Bank Transfer, PayPal, Cash) | `14001 – 14999` |
| **15** | `DATA_TYPE` | `C_DATATYPE` | System Configuration data types (String, Int, Bool, JSON) | `15001 – 15999` |
| **16** | `RELATION` | `C_RELATIONSHIP` | Emergency contact relationships (Self, Father, Spouse) | `16001 – 16999` |
| **17** | `NOTIF_EVT` | `C_NOTIFICATION_EVENT` | Master list of notification event codes & intimations | `17001 – 17999` |

---

### 📌 Seeded Parameters Master Catalog

```
Category 1: C_GENDER
  • 1001: M (Male)
  • 1002: F (Female)
  • 1003: TGM (Transgender Male)
  • 1004: TGF (Transgender Female)
  • 1005: UN (Unknown)

Category 2: C_TITLE
  • 2001: Sir
  • 2002: Madam
  • 2003: Mr.
  • 2004: Ms.
  • 2005: Mrs.
  • 2006: Miss
  • 2007: Dr.
  • 2008: Doctor
  • 2009: Prof (Profesor)

Category 4: C_ADDRESSTYPE
  • 4001: HOME (Home Address)
  • 4002: WORK (Work / Office)
  • 4003: BILLING (Billing Address)
  • 4004: SHIPPING (Shipping Address)

Category 5: C_CONTACTTYPE
  • 5001: MOBILE (Mobile Phone)
  • 5002: EMAIL (Secondary Email)
  • 5003: WORK_PHONE (Work Phone)
  • 5004: LINKEDIN (LinkedIn Profile)

Category 17: C_NOTIFICATION_EVENT
  • 17001: PAYMENT_RECEIVED (Payment Received)
  • 17002: INTERNAL_ANNOUNCEMENT (Internal Announcement)
  • 17003: SYSTEM_ALERT (System & Security Alert)
  • 17004: APPROVAL_REQUESTED (Approval Request)
```

---

### 🔑 System Configuration Keys (`SystemConfigurationKeys`)

| Key Name | DataTypeID | Default Value | Description |
| :--- | :--- | :--- | :--- |
| `App.Name` | `15001` (STRING) | `DNAQMS Enterprise` | Main application brand title. |
| `App.Logging.EnableDebugLog` | `15004` (BOOL) | `true` | Controls verbose NLog capture. |
| `App.Logging.LogLevel` | `15001` (STRING) | `Information` | Log severity threshold. |
| `App.MaintenanceMode` | `15004` (BOOL) | `false` | Global system maintenance flag. |
| `Security.RequireOrganizationHeader` | `15004` (BOOL) | `true` | Enforces `X-Organization-Id` header check. |
| `Security.ApiKeyPrefix` | `15001` (STRING) | `dnaqms_live_` | Prefix for generated API keys. |
| `Integration.DefaultAuditLevel` | `15001` (STRING) | `Full` | Third-party API audit level. |
| `Integration.EnableLogging` | `15004` (BOOL) | `true` | Enables outbound HTTP audit logging. |

---

### Key API Endpoints
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/api/v1/config/categories` | Returns all active configuration categories. |
| `GET` | `/api/v1/config/parameters?categoryCode=C_NOTIFICATION_EVENT` | Returns parameters for a specific category. |
| `GET` | `/api/v1/config/system-keys` | Reads system configuration key-value settings. |
| `POST` | `/api/v1/config/system-keys` | Updates a system configuration setting value. |

---

## 💳 Module 7: SaaS Subscriptions & Metering (`SubscriptionSaaS`)

### Capabilities
- **Tenant Subscription Plans**: Multi-tier plans (Free, Starter, Pro, Enterprise) per Organization.
- **Feature Access Gating**: Enforces feature entitlement limits based on active plan.
- **Usage Metering**: Tracks API call volumes, file storage limits, and active user quotas.

### Key API Endpoints
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/api/v1/subscriptions/plans` | Lists available SaaS tenant subscription plans. |
| `GET` | `/api/v1/subscriptions/current` | Gets active subscription and feature limits for current tenant. |
| `GET` | `/api/v1/subscriptions/usage` | Retrieves current usage metrics and remaining quotas. |

---

## 🏛️ Module 8: Multi-Jurisdictional Tax Engine (`TaxEngine`)

### Capabilities
- **Automated Tax Calculation**: Calculates VAT, GST, and Sales Tax across multi-country tax jurisdictions.
- **Tax Rule Matrix**: Configurable tax rules per region, product type, and customer tax exemption status.
- **Tax Audit Logs**: Stores compliance calculation trace logs for regulatory reporting.

### Key API Endpoints
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `POST` | `/api/v1/tax/calculate` | Calculates line-item tax rates and total tax for a transaction context. |
| `GET` | `/api/v1/tax/rules` | Retrieves active tax rules for a region/jurisdiction. |

---

## 📊 Module 9: Universal Financials & Invoicing (`FinancialReporting` & `InvoiceGeneration`)

### Capabilities
- **Invoice Generation**: Automated HTML & PDF invoice generation for completed transactions.
- **Financial Analytics**: SaaS Revenue Analytics, Monthly Tax Summaries, and Payment Performance Dashboards.

### Key API Endpoints
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/api/v1/invoices/{invoiceId}` | Retrieves detailed invoice breakdown. |
| `GET` | `/api/v1/financials/revenue-analytics` | Gets SaaS monthly recurring revenue (MRR) and performance metrics. |
| `GET` | `/api/v1/financials/tax-summary` | Gets monthly tax summary breakdown for accounting compliance. |

---

## 📁 Module 10: Multi-Tenant Cloud Storage & Payments (`StorageController`, `PaymentController`, `WebhookController`)

### Capabilities
- **Organization Storage Config**: Per-tenant file storage providers (Google Drive, AWS S3, Azure Blob).
- **Organization Payment Providers**: Per-tenant payment gateway credentials (Stripe, PayPal, Razorpay).
- **Webhook Gateway**: Inbound webhook processing for payment gateway status updates (charge.succeeded, invoice.paid).

### Key API Endpoints
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `POST` | `/api/v1/storage/upload` | Uploads a file and records metadata in `StoredFile`. |
| `GET` | `/api/v1/storage/files/{fileId}` | Retrieves file metadata and download URL. |
| `POST` | `/api/v1/payments/process` | Processes a payment transaction via tenant's payment provider. |
| `POST` | `/api/v1/webhooks/{provider}` | Handles inbound payment and storage webhook events. |

---

## 💻 7. Comprehensive Code & API Usage Guide

Below are ready-to-run HTTP requests illustrating how to use each feature in practice.

```http
### ============================================================================
### 1. USER REGISTRATION (With Custom UserCode & Salutation)
### ============================================================================
POST /api/v1/auth/register
Content-Type: application/json

{
  "userCode": "alex2026",
  "titleId": 2003,
  "firstName": "Alex",
  "lastName": "Mercer",
  "genderId": 1001,
  "email": "alex.mercer@acme.com",
  "password": "Welc0me@555"
}

### ============================================================================
### 2. UNIFIED LOGIN (Via UserCode, Email, or Mobile)
### ============================================================================
POST /api/v1/auth/login
Content-Type: application/json

{
  "identifier": "alex2026",
  "password": "Welc0me@555"
}

### ============================================================================
### 3. THIRD-PARTY API INTEGRATION EXECUTION
### ============================================================================
POST /api/v1/integration/execute
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "integrationCode": "PAYMENT_GATEWAY_STRIPE",
  "endpointPath": "/v1/charges",
  "httpMethod": "POST",
  "payloadJson": "{\"amount\": 5000, \"currency\": \"usd\"}"
}

### ============================================================================
### 4. ENQUEUE GENERIC EMAIL DISPATCH
### ============================================================================
POST /api/v1/email/send
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "centerId": 1,
  "recipientTo": "customer@example.com",
  "subject": "Order Confirmation #10092",
  "body": "<h1>Thank you for your order!</h1><p>Your order #10092 has been processed.</p>",
  "isHtml": true,
  "priority": 1
}

### ============================================================================
### 5. DISPATCH CENTER NOTIFICATION (InApp + Email + SMS)
### ============================================================================
POST /api/v1/notifications/send
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "organizationId": 1,
  "eventId": 17001,
  "eventCode": "PAYMENT_RECEIVED",
  "targetUserIds": [1],
  "parameters": {
    "InvoiceNo": "INV-2026-0091",
    "Amount": "499.00",
    "Currency": "USD",
    "CenterName": "Main HQ Center"
  },
  "actionUrl": "/payments/invoices/INV-2026-0091"
}

### ============================================================================
### 6. READ IN-APP NOTIFICATION BELL FEED
### ============================================================================
GET /api/v1/notifications?isRead=0&pageNumber=1&pageSize=10
Authorization: Bearer <JWT_TOKEN>

### ============================================================================
### 7. GET UNREAD NOTIFICATION BADGE COUNT
### ============================================================================
GET /api/v1/notifications/unread-count
Authorization: Bearer <JWT_TOKEN>

### ============================================================================
### 8. GET WORLD LOCATION DATA (Countries -> States -> Cities)
### ============================================================================
GET /api/v1/locations/countries?search=United&pageNumber=1&pageSize=10
Authorization: Bearer <JWT_TOKEN>

GET /api/v1/locations/countries/233/states
Authorization: Bearer <JWT_TOKEN>

GET /api/v1/locations/states/3919/cities
Authorization: Bearer <JWT_TOKEN>

### ============================================================================
### 9. READ NEXUSCORE CONFIGURATION PARAMETERS (Category 17: C_NOTIFICATION_EVENT)
### ============================================================================
GET /api/v1/config/parameters?categoryCode=C_NOTIFICATION_EVENT
Authorization: Bearer <JWT_TOKEN>
```
