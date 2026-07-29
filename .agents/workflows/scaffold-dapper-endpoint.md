---
description: Scaffold a new API Endpoint with Dapper Data Access
---
# Scaffold Dapper Endpoint Workflow

When requested to run the "Scaffold Dapper Endpoint" or "add-new-endpoint" workflow, you **MUST** execute the following steps precisely in this exact order:

## 1. Create the DTOs
Examine the `.Application/DTOs` directory. Create any necessary Request and Response Data Transfer Objects (DTOs) representing the payload.

## 2. Define the Interface
Go to `.Application/Interfaces`. Define an interface describing the new business logic.
**CRITICAL**: Every method signature in this interface must return a `Task<ApiResponse<T>>`, imported explicitly from `AntiGravity.Enterprise.Shared.Core.Models`.

## 3. Implement the Dapper Service & Stored Procedure Pattern
Go to the `.Infrastructure/Services` directory and Database Scripts directory (`DatabaseScripts/MySqlScript/` & `DatabaseScripts/MSSQLScript/`).
- **STORED PROCEDURE PATTERN**:
  - **Search / Select**: Use single unified Search/Select Stored Procedures named with the `PR_S_<Entity>` prefix (e.g. `PR_S_ConfigCategory`, `PR_S_ConfigParameters`, `PR_S_SystemConfigurationKeys`). Use default parameters (`-1` for numeric IDs, `''` for strings, `-1` for active status flags).
  - **Insert / Update (Upsert)**: Use single unified Insert/Update Stored Procedures named with the `PR_IU_<Entity>` prefix (e.g. `PR_IU_ConfigCategory`, `PR_IU_ConfigParameters`, `PR_IU_SystemConfigurationKeys`). Include a dedicated `/S/---------------- [Validation Section] ----------------` block for duplicate checks. Return a metadata result set: `ID, ErrNo, RowsCount, ErrMsg, ErrLine`.
  - **ID Blocks**: Keep 1,000-item range blocks for master parameter IDs (`CategoryID * 1000 + 1`, e.g., Category `1` = `1001-1999`, Category `2` = `2001-2999`).
  - **MASTER CONFIGURATION CONSUMPTION**: Whenever application features (User Profiles, Billing, Notifications, Logistics) need dropdown or validation values (e.g., Document Types, Payment Methods, Languages, Currencies, Unit Types), always query parameters dynamically from `ConfigParameters` via `IConfigurationService.GetConfigParametersByCategoryCodeAsync(...)` or `PR_S_ConfigParameters`.
  - **SYSTEM CONFIGURATION KEYS**: Whenever system-level application settings, feature toggles, logging behaviors, or security rules are needed (e.g., `App.Logging.EnableDebugLog`, `App.Logging.LogLevel`, `App.MaintenanceMode`, `Security.RequireOrganizationHeader`), always fetch and manage them dynamically via `SystemConfigurationKeys` using `PR_S_SystemConfigurationKeys` and `PR_IU_SystemConfigurationKeys` instead of static `appsettings.json` values.
- Create the implementation class inheriting your newly defined interface.
- Inject `IDapperDBFactory` through the constructor.
- Execute raw SQL or Stored Procedures natively via Dapper.
- Catch all exceptions, returning `ApiResponse<T>.Fail(...)`. On success return `ApiResponse<T>.Ok(...)`.

## 4. Register the Dependency Injection
Locate the Service Registration file (e.g., `DependencyInjection.cs` inside the `.Infrastructure` layer).
- Map your transient or scoped service correctly: `services.AddScoped<INewService, NewService>();`

## 5. Scaffold the API Controller
Inside the `.Api/Controllers` directory:
- Create a new Controller class inheriting from `ApiControllerBase`.
- **CRITICAL**: Do NOT add redundant `[ApiController] [Route(...)]` attributes if the base already mandates them, unless explicitly overriding the route pattern.
- Inject the application-layer Interface via the constructor.
- Add an HTTP Action mapping (e.g. `[HttpPost]`, `[HttpGet]`).
- Await the application service.
- Return the exact structure natively: `return ApiResponse(await _service.ExecuteAsync(request));`.

## Verification
Upon finishing all steps, execute `dotnet build` on the parent repository to ensure 0 compilation anomalies.
