# PHASE 2 — DOMAIN & APPLICATION

DOMAIN:

Entities:
- User
- Center (ParentCenterId self reference)
- Role
- Permission
- UserCenter
- UserRole
- ApiKey
- UserSession
- UserDevice
- PaymentTransaction
- StoredFile

Rules:
- No framework dependency
- Pure domain models

APPLICATION:

Create:
- RequestContext
- DTOs
- Interfaces:
    IUserService
    ICenterService
    IAuthorizationEngine
    IPaymentService
    IFileStorageService
- DependencyInjection class

No DB logic yet.

After completion:
Ask:
"Proceed to PHASE 3 — Infrastructure (Dapper & Multi-DB)?"