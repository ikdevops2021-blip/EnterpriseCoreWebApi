# Database Integration Guide

This document outlines the sequential execution order for integrating the newly created database schema into the target environment.

## 1. Execution Order

### `PaymentSchema_MSSQL.sql`
- **File:** `DNAQMSAPI/DatabaseScripts/PaymentSchema_MSSQL.sql`
- **Tables:** `PaymentTransactions`, `CurrencyMaster`, `PaymentProviders`, `WebhookLogs`
- **What:** It constructs the core payment tables and populates dummy lookup data (Currencies, Providers). It constructs all the stored procedures for handling payments (`pr_CreatePaymentTransaction`, `pr_UpdatePaymentStatus`, `pr_LogWebhookEvent`), analytical functions (`fn_GetPaymentStatusName`, `fn_GetRecentTransactions`), and reporting views (`vw_PaymentDashboardStats`).
- **Why:** This ensures our architecture complies with the strict **Database-First Business Logic** rule mandated by `GLOBAL_RULES.md`, ensuring all payment persistence goes through robust SQL logic.
