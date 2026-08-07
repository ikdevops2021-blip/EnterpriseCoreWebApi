# Project Rules

## Navigation Menu Consistency
Whenever a new admin screen or route is created under the `ShellRoute` in the frontend application (`dqms_frontend/lib/main.dart`):
1. **Database Seeding**: The new route **must** have a corresponding entry in the `navigationmenu` database table (seeded via SQL scripts or created using the `PR_IU_NavigationMenu` stored procedure) to ensure it is dynamically served to the sidebar.
2. **Frontend Fallback**: The new screen **must** be added to the hardcoded `_fallbackMenus` list inside `dqms_frontend/lib/features/admin/providers/navigation_menu_provider.dart`. This guarantees the admin sidebar will still load and function correctly when the backend API is offline.
3. **Permissions**: If the new route requires specific authorization, define the `requiredPermission` parameter in both the database entry and the frontend fallback model.
