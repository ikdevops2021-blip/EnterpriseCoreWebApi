# PHASE 7 – Integration Module
## Generic Third-Party API Integration Framework

---

# 📌 Overview

PHASE 7 introduces a **Generic Third-Party API Integration Framework** into the existing Clean Architecture project.

This module enables:

- Calling any third-party API
- Multi-tenant configuration support
- Global fallback configuration
- Multiple authentication strategies
- OAuth2 token lifecycle management
- Secure credential storage
- Retry & resilience support
- Enterprise-grade extensibility

This module is fully aligned with the current project structure and does NOT convert the system into distributed architecture.

---

# 🏗 Architecture Alignment (Existing Clean Architecture)

| Layer | Responsibility |
|-------|---------------|
| API | Controller exposure & DI registration |
| Application | Interfaces & contracts |
| Domain | Core enums and models |
| Infrastructure | Implementation of API client & auth providers |
| Shared | Reusable integration logic & DB scripts |

This maintains strict dependency rules:

- API → Application
- Infrastructure → Application
- Application → Domain
- Shared → No external dependency on Infrastructure

---

# 📁 Folder Structure (Integrated with Existing Project)

```
src/
 ├── API/
 │     └── Controllers/
 │            └── IntegrationController.cs
 │
 ├── Application/
 │     └── Integration/
 │            ├── Interfaces/
 │            │      └── IGenericApiClient.cs
 │            └── DTOs/
 │                   └── ApiRequest.cs
 │
 ├── Domain/
 │     └── Integration/
 │            ├── AuthType.cs
 │            └── ThirdPartyApiConfig.cs
 │
 ├── Infrastructure/
 │     └── Integration/
 │            ├── GenericApiClient.cs
 │            ├── ConfigurationResolver.cs
 │            ├── TokenManager.cs
 │            └── AuthProviders/
 │                   ├── IAuthProvider.cs
 │                   ├── ApiKeyAuthProvider.cs
 │                   ├── BasicAuthProvider.cs
 │                   ├── JwtAuthProvider.cs
 │                   └── OAuth2AuthProvider.cs
 │
 └── Shared/
       └── DBScript/
              ├── 001_Integration_Tables.sql
              ├── 002_Integration_Indexes.sql
              └── 003_Integration_SeedData.sql
```

---

# 🎯 Core Objectives

- Enable plug-and-play third-party integrations
- Avoid hardcoding provider logic
- Support new providers without modifying core system
- Maintain tenant-level isolation
- Enterprise-ready token lifecycle handling

---

# 🔐 Supported Authentication Types

```csharp
public enum AuthType
{
    ApiKey = 0,
    Basic = 1,
    JwtBearer = 2,
    OAuth2 = 3
}
```

---

# 🧠 Integration Flow

1. Client sends integration request
2. System resolves configuration (Tenant → Global)
3. Authentication strategy is selected
4. Token refreshed if required
5. HTTP request executed
6. Response logged (optional)
7. Response returned to caller

---

# 🗄 Enterprise Unified Database Design

The integration engine utilizes a **Unified Provider & Endpoint Registry Model** paired with **`APIAuditLogs`** for full compliance and dynamic routing:

1. **`APIIntegrations`**: Stores provider profiles, base URLs, authentication mechanisms (ApiKey, Bearer, Basic, OAuth2, HMAC), and global credentials.
2. **`ApiEndpoints`**: Maps logical action names (e.g. `SendSMS`, `VerifyOTP`, `SendWhatsAppMessage`, `CreatePaymentIntent`) to target relative paths, HTTP methods, and sample payloads.
3. **`APIAuditLogs`**: Records execution performance metrics, status codes, request/response bodies, duration, and error traces.

---

## ⚡ Unified API Endpoints (`/api/v1/Integration`)

- **`POST /api/v1/Integration/execute`**: Executes action-based third-party API calls using dynamic configuration resolution.
- **`GET /api/v1/Integration/providers`**: Lists all active provider configurations.
- **`POST /api/v1/Integration/providers`**: Upserts provider credentials and base URLs.
- **`GET /api/v1/Integration/providers/{id}/endpoints`**: Lists endpoint action mappings for a provider.
- **`POST /api/v1/Integration/endpoints`**: Upserts action endpoint mappings.
- **`GET /api/v1/Integration/audit-logs`**: Fetches telemetry audit logs with status code filtering.

---

# 🧩 DI Registration (Program.cs)

```csharp
builder.Services.AddScoped<IGenericApiClient, GenericApiClient>();
builder.Services.AddScoped<IAuthProviderFactory, AuthProviderFactory>();
builder.Services.AddScoped<TokenManager>();
builder.Services.AddScoped<ConfigurationResolver>();
```

---

# 🚀 Example Usage Inside Application Layer

```csharp
var response = await _genericApiClient.SendAsync<ResponseDto>(
    new ApiRequest
    {
        TenantId = tenantId,
        ConfigName = "Default SMS Provider",
        Method = HttpMethod.Post,
        Endpoint = "/send",
        Body = payload
    });
```

---

# 🔁 Resilience & Automated Retry Policy

`GenericApiClient` features built-in **Exponential Backoff Retries** for outbound HTTP requests:

- **Configurable Attempt Threshold**: `ApiRequest.MaxRetries` (Default: `3`).
- **Target Failure Triggers**:
  - Transient Server Errors (`HTTP 5xx`).
  - Rate Limiting (`HTTP 429 Too Many Requests`).
  - Network & Connection Failures (`HttpRequestException`).
- **Backoff Algorithm**: Delay doubles with jitter after each failed attempt:
  $$\text{Delay}(n) = 2^n \times 500\text{ ms} \quad (1\text{s}, 2\text{s}, 4\text{s}...)$$
- **Telemetry & Auditing**: Intermediate retries log warnings. Final audit logs report total duration and conclusive HTTP status.

---

# 📦 API Request Model

```csharp
public class ApiRequest
{
    public int? TenantId { get; set; }
    public int ExecutingUserId { get; set; }
    public string ConfigName { get; set; } = string.Empty;
    public string Method { get; set; } = "GET";
    public string Endpoint { get; set; } = string.Empty;
    public object? Body { get; set; }
    public Dictionary<string, string> Headers { get; set; } = new Dictionary<string, string>();
    public Dictionary<string, string> RouteParameters { get; set; } = new Dictionary<string, string>();
    public int TimeoutSeconds { get; set; } = 100;
    public int MaxRetries { get; set; } = 3;
}
```

---

# 📈 Enterprise Expansion Roadmap

Future Additions:

- Webhook handler module
- Integration templates
- API usage metering
- Circuit breaker (Polly)
- Redis token caching
- Background sync worker
- Event-driven integration

---

# 🎯 Business Impact

After PHASE 7:

Your platform becomes:

- Integration-ready SaaS
- Government-compatible
- Payment gateway extensible
- Event ecosystem ready
- Multi-provider adaptable
- Vendor-neutral

---

# 🧠 Design Philosophy

This module follows:

- Open/Closed Principle
- Single Responsibility
- Dependency Inversion
- Strategy Pattern
- Clean Architecture rules

---

# ✅ Completion Checklist

- [ ] DB scripts executed
- [ ] Domain enum added
- [ ] Interface created in Application layer
- [ ] Infrastructure implementation completed
- [ ] DI registered
- [ ] Admin UI for config management created (optional)
- [ ] Logging enabled (recommended)

---

# 🏁 Conclusion

PHASE 7 establishes a powerful, reusable, enterprise-grade integration backbone within the existing architecture — without increasing system complexity or breaking Clean Architecture boundaries.

This ensures long-term scalability and easy addition of future third-party systems.

After completion:
Ask:
"Proceed to PHASE 8 — API & Production Finalization?"