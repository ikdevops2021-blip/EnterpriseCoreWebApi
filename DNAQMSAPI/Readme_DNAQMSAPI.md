# DNAQMSAPI Enterprise Solution

## Overview
This is a robust, clean architecture enterprise solution utilizing .NET 8, Dapper, and a Database-First Business Logic model. 

## Core Features Implemented
- **Payment Integration Framework:** A highly scalable, provider-agnostic engine that allows mapping specific payment providers (like Stripe or Razorpay) dynamically at the Branch or Organization level.
- **Dapper Persistence:** All heavy business logic runs through pre-compiled SQL Server Stored Procedures via `IDapperDBFactory`.
- **Zero Trust Security:** Robust custom middlewares ensuring strict tenancy and identity validation across all requests.

## How to Consume (Payments)
1. **Database:** Ensure the `PaymentSchema_MSSQL.sql` script has been executed on the SQL Server.
2. **Configuration:** Ensure the `DatabaseSettings` section in `appsettings.json` points to the SQL Server database. 
3. **Usage:** Inject `IPaymentRouter` and `IPaymentGatewayFactory` into your services. Use `PaymentController` as a reference for handling standard UI payment flows.
