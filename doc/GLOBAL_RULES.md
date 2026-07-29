# GLOBAL GENERATION RULES

## Mandatory Graphify Session Startup

1. **At the start of every new session** (before any other work), the Assistant MUST invoke the `graphify` skill on the current project directory by calling the Skill tool with `skill: "graphify"`.
2. **First run (no existing graph):** Execute a full `/graphify` pipeline on the project root.
3. **Subsequent runs (graph already exists at `graphify-out/graph.json`):** Use the incremental mode `/graphify <path> --update` so only new/changed files are re-extracted. This saves tokens and time.
4. **Why:** The persistent knowledge graph in `graphify-out/graph.json` provides an honest audit trail (EXTRACTED / INFERRED / AMBIGUOUS edges) and community clustering so the Assistant can navigate the codebase without re-reading everything. Treat it as the canonical map of the project.
5. **Use the graph as the map:** Before proposing changes, query the graph (`/graphify query`, `/graphify path`, or `/graphify explain`) to identify affected communities and surprising cross-module connections.
6. **After completing any Phase or Core Module:** Re-run `/graphify <path> --update` so the graph reflects the new code, then consult `graphify-out/GRAPH_REPORT.md` (God Nodes, Surprising Connections, Suggested Questions) for the next planning step.
7. **Never skip this step** unless the user explicitly says to skip graphify for this session.

1. Use .NET 8 Web API
2. Use async/await everywhere
3. No synchronous blocking
4. Use DI in each layer
5. No repository pattern
6. Use Dapper directly via IDapperDBFactory
7. Use ApiResponse<T> for all responses
8. Implement NLog structured logging with Database
9. Validate multi-tenant isolation
10. Ensure thread safety
11. Ensure future extensibility
12. Follow SOLID principles
13. Apply Zero Trust model
14. Use factory pattern for Payments & Storage
15. No hardcoded provider logic
16. All configuration via appsettings.json
17. Use IOptions pattern
18. Production-ready code only
19. Controllers must NOT use try-catch blocks for standard unhandled exceptions; rely entirely on the GlobalExceptionMiddleware to catch, log (via ILogger), and format standard error responses.

## Strict Database Scripting & Audit Column Rules

When creating or modifying database entities, the Assistant MUST adhere to the following strict guidelines:

1. **Target Database Confirmation:**
   - **CRITICAL STEP**: Before generating any database scripts, data access code, or configuring connection strings, you MUST ask the user which database provider they are going to use for the project (e.g., MSSQL, MySQL, PostgreSQL, SQLite).
   - Do not assume a default database provider. Wait for the user's response before proceeding with database integration.

2. **Database Script Generation:**
   - Once the target database is confirmed, auto-generate database scripts tailored explicitly to the chosen provider.
   - Scripts must be placed in their respective provider-specific folders (e.g., `Shared/DBScript/MSSQLScript/`, `Shared/DBScript/MySqlScript/`, etc.).

3. **Dummy Data Requirement:**
   - Always include a dummy data seed script (e.g., `xxx_DummyData.sql`) tailored for the chosen database to allow immediate testing and validation of the schemas.

4. **Mandatory Audit Columns:**
   - **ALL** new tables must include the following audit and soft-delete tracking columns, using the correct syntax for the selected database provider.
   - Example for **MSSQL**:
     ```sql
     [IsActive] BIT NOT NULL DEFAULT 1,
     [CreatedBy] INT NOT NULL,
     [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
     [ModifiedBy] INT NOT NULL,
     [ModifiedDate] DATETIME NOT NULL DEFAULT GETDATE(),
     [IsDeleted] BIT NULL DEFAULT 0,
     [DeletedBy] INT NULL,
     [DeletedDate] DATETIME NULL
     ```
   - Example for **MySQL**:
     ```sql
     IsActive BOOLEAN NOT NULL DEFAULT 1,
     CreatedBy INT NOT NULL,
     CreatedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
     ModifiedBy INT NOT NULL,
     ModifiedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
     IsDeleted BOOLEAN NULL DEFAULT 0,
     DeletedBy INT NULL,
     DeletedDate DATETIME NULL
     ```
   - For other databases, safely translate these fields to their strict, idiomatic equivalents.

## Mandatory Post-Phase Documentation Strategy

After the successful completion and verification of any **Phase** or **Core Module**, the Assistant MUST automatically generate/update the following two documentation files in the root folder of the newly modified Solution:

1. **`Readme_<SolutionName>.md`**
   - **Content:** Must contain a high-level summary of the project, a detailed list of its core features, and clear instructions on how to consume/use the solution (e.g., Service Registration, Architecture dependencies).

2. **`Readme_<SolutionName>_dbintegaration.md`**
   - **Content:** Must contain the strict, sequential execution order of all associated database scripts.
   - **Format:** For each SQL script, it must clearly list the `Filename`, the target `Table Name` (or View/Object), a `What` section describing what the script does, and a `Why` section detailing the business or architectural reasoning behind it.

# Enterprise Database Access Architecture (Mandatory)

## Database Philosophy

This framework follows a **Database-First Business Logic** architecture using **SQL Server + Dapper DB Factory**.

The database is considered a first-class component of the application.

Business-critical logic should reside inside SQL Server database objects wherever it improves maintainability, performance, security, consistency, and reuse.

Repositories should remain thin and primarily orchestrate calls to database objects.

---

## Primary Data Access Technology

The ONLY approved database access technologies are:

- Dapper
- IDapperDBFactory
- SQL Server Stored Procedures
- SQL Server Views
- SQL Server Scalar Functions
- SQL Server Table-Valued Functions (TVF)
- User Defined Table Types (UDTT)
- Table-Valued Parameters (TVP)

Do NOT introduce another ORM or database abstraction layer unless explicitly approved.

Reuse the existing IDapperDBFactory infrastructure throughout the solution.

---

## Stored Procedure First Policy

Whenever possible, business operations MUST be implemented using Stored Procedures.

Preferred candidates include:

- Create
- Update
- Soft Delete
- Bulk Insert
- Bulk Update
- Bulk Delete
- Payment Processing
- Refund Processing
- Invoice Processing
- Billing
- Tax Processing
- Settlement
- Reconciliation
- Approval Workflow
- Queue Processing
- Background Jobs
- Dashboard Statistics
- Reports
- Audit Logging
- Retry Processing
- Synchronization
- Multi-table Transactions
- Financial Calculations
- Complex Search
- Pagination
- Import
- Export

Services should execute Stored Procedures through IDapperDBFactory.

Avoid embedding business SQL inside C# classes.

---

## SQL Function Policy

All database functions must use `fn_` as the naming prefix (e.g., `fn_CalculateTax`).

Use SQL Scalar Functions for reusable calculations such as:

- Tax Calculation
- Discount Calculation
- Currency Conversion
- Age Calculation
- Financial Formulas
- String Formatting
- Validation Rules

Use Table-Valued Functions for reusable datasets such as:

- User Permissions
- Organization Hierarchy
- Branch Hierarchy
- Dashboard Data
- Reporting Filters
- Search Results
- Lookup Data
- Common Read Models

---

## SQL View Policy

Create SQL Views whenever data is reused by multiple modules.

Typical candidates include:

- Dashboard Data
- Reporting
- Analytics
- Read Models
- Aggregated Data
- Frequently Used Queries
- Summary Tables

Avoid duplicating complex SELECT statements across services.

---

## Stored Procedure Standards

Every Stored Procedure must:

- Use `pr_` as the naming prefix (e.g., `pr_CreatePayment`)
- Use TRY...CATCH
- Support Transactions where required
- Rollback on failure
- Validate all parameters
- Return standardized Result Codes
- Return standardized Error Messages
- Log exceptions
- Support optimistic concurrency where applicable
- Prevent SQL Injection using parameterized execution
- Be documented

---

## Service Standard (Data Access)

Services (e.g. `PaymentService`, `ConfigurationService`) must be used for Dapper data access instead of a formal Repository pattern. They must remain lightweight.

Services should primarily:

- Execute Stored Procedures
- Execute Views
- Execute SQL Functions
- Execute TVFs

Services must NOT contain:

- Complex SQL
- Business Rules
- Financial Calculations
- Duplicate Queries

Business logic belongs in the database—not inside the data-access Service implementations.

---

## Existing Code Refactoring Policy

When modifying any existing feature:

1. Review existing SQL and repository implementations.
2. Identify embedded SQL and duplicate queries.
3. Move business-critical SQL into Stored Procedures, Views, or Functions where appropriate.
4. Update services to use IDapperDBFactory.
5. Preserve existing functionality and API contracts.
6. Do not introduce breaking changes.
7. Run all existing tests after refactoring.

Refactoring should be incremental and safe.

---

## Performance Optimization

During implementation or refactoring, review:

- Missing Indexes
- Duplicate Indexes
- Full Table Scans
- Expensive Queries
- Duplicate Queries
- Inefficient Pagination
- N+1 Data Access Patterns
- Long-running Stored Procedures

Recommend improvements where beneficial.

---

## Database Deliverables

Whenever a new module is developed, generate:

- SQL Tables
- Stored Procedures
- Views
- Scalar Functions
- Table-Valued Functions
- User Defined Table Types
- Indexes
- Foreign Keys
- Constraints
- Seed Scripts
- Migration Scripts
- Rollback Scripts
- Database Documentation

---

## Enterprise Principle

Always favor a design that improves:

- Reusability
- Maintainability
- Performance
- Security
- Scalability
- Extensibility
- Backward Compatibility

The objective is to build a reusable Enterprise Framework where all modules follow a consistent database architecture using SQL Server and Dapper DB Factory.