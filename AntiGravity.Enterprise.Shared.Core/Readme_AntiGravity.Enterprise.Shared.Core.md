# AntiGravity.Enterprise.Shared.Core

## Summary
The **AntiGravity.Enterprise.Shared.Core** solution is a centralized .NET 8 Class Library designed to serve as the unified Data Access and Base Modeling foundation across the entire AntiGravity microservice enterprise footprint (including DNAQMSAPI, TaxEngine.Core, and SubscriptionSaaS.Core).

## Features
*   **Centralized Models**: Hosts standard enterprise response wrappers like `ApiResponse<T>` and `PaginatedApiResponse<T>` to guarantee consistent API payloads company-wide.
*   **Agnostic Data Access Layer**: Houses the `IDapperDBFactory` and `DapperDBFactory` logic dynamically capable of instantiating connections to multiple vendors (SQL Server, MySQL, SQLite, Oracle, MongoDB).
*   **Configuration Architecture**: Exposes `DatabaseSettings` and `DatabaseConfig` configurations perfectly mapping explicit strings securely through the modern `.NET Core` `IOptions` Dependency Injection lifecycle.

## How to Use
1.  **Solution Linkage**: Include `AntiGravity.Enterprise.Shared.Core.csproj` as a Project Reference in your Application/Infrastructure microservice layers.
2.  **Service Registration**: Inject the base dependency factories in the `Program.cs` or `Startup.cs` of your executing API:
    ```csharp
    builder.Services.Configure<DatabaseSettings>(builder.Configuration.GetSection("DatabaseSettings"));
    builder.Services.AddSingleton<IDapperDBFactory, DapperDBFactory>();
    ```
3.  **Consumption**: Inject `IDapperDBFactory` strictly into your internal Application Services to physically query underlying data cleanly isolating logic natively.
