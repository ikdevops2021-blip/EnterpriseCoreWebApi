# PHASE 3 — INFRASTRUCTURE (DAPPER + MULTI DATABASE)

Implement:

IDapperDBFactory
DapperDBFactory

Support:
- SQL Server
- MySQL
- MongoDB
- SQLite

Use config:

DatabaseSettings:
  DefaultConnectionName
  Databases[]

Requirements:
- Thread safe
- Timeout handling
- SSL support
- Connection pooling
- Clean DI registration

Do NOT implement repositories.

After completion:
Ask:
"Proceed to PHASE 4 — Security & Authorization?"