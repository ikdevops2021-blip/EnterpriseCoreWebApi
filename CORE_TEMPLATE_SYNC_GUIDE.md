# 🔄 Enterprise Core Template Sync & Dual-Repository Workflow

This document defines the strict git workflow and synchronization rules between the **Enterprise Core Template Repository** and active application repositories like **DQMS_APP**.

---

## 📌 Repository Inventory

| Repository Role | Repository Name | Git Remote URL | Description |
| :--- | :--- | :--- | :--- |
| **Core Template Repo** | `EnterpriseCoreWebApi` | `https://github.com/ikdevops2021-blip/EnterpriseCoreWebApi.git` | Golden master template containing core Web API architecture, `DapperDBFactory`, `SeederApp`, DDL scripts, and cross-cutting modules. |
| **Active Project Repo** | `DQMS_APP` | `https://github.com/ikdevops2021-blip/DQMS_APP.git` | Active project repository containing the domain implementation, project-specific Web API endpoints, and Frontend applications. |

---

## 🏗️ Architecture & Branch Management Strategy

```
                          ┌─────────────────────────────────────────┐
                          │   EnterpriseCoreWebApi.git (upstream)   │
                          │      [Core Web API & Seeder Template]    │
                          └────────────────────┬────────────────────┘
                                               │
                                       (git pull / merge)
                                               │
                                               ▼
┌───────────────────────────────────────────────────────────────────────────────────────────┐
│                                 DQMS_APP.git (origin)                                     │
│  ┌────────────────────────────────────────┐     ┌──────────────────────────────────────┐  │
│  │             Backend Web API            │     │         Frontend (Web / Mobile)      │  │
│  │   (Synchronized with Core Template)    │     │      (Independent Application UI)   │  │
│  └────────────────────────────────────────┘     └──────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🛠️ Step-by-Step AI & Developer Execution Guide

### Phase 1: Initialize New Project Repo (`DQMS_APP`) from Core Template

Run the following commands when initializing or working in `DQMS_APP`:

```bash
# 1. Clone the core template repository into local project workspace
git clone https://github.com/ikdevops2021-blip/EnterpriseCoreWebApi.git DQMS_APP
cd DQMS_APP

# 2. Rename default origin remote to 'upstream' (points to Core Template)
git remote rename origin upstream

# 3. Add project-specific repository as primary 'origin'
git remote add origin https://github.com/ikdevops2021-blip/DQMS_APP.git

# 4. Push initial project baseline to DQMS_APP repository
git branch -M main
git push -u origin main
```

---

### Phase 2: Pulling Latest Core Template Updates into `DQMS_APP`

Whenever improvements, bug fixes, database schema updates, or new core features are added to `EnterpriseCoreWebApi.git`, bring them into `DQMS_APP` using:

```bash
# 1. Fetch all updates from the template repository
git fetch upstream

# 2. Merge upstream master into local working branch
git checkout main
git merge upstream/master --allow-unrelated-histories -m "Sync core template updates from EnterpriseCoreWebApi"

# 3. Resolve any merge conflicts (if applicable) and push to project repository
git push origin main
```

---

### Phase 3: Pushing Core Feature Enhancements from `DQMS_APP` back to `EnterpriseCoreWebApi`

When developing inside `DQMS_APP` and implementing a new generic feature (e.g. enhanced `SeederApp` options, new `DapperDBFactory` provider, core middleware) that should benefit all future projects:

```bash
# 1. Stage and commit the core enhancement in local repository
git add .
git commit -m "feat(core): enhance DapperDBFactory multi-tenant connection handling"

# 2. Push to local project repo
git push origin main

# 3. Push core changes back to the Enterprise Core Template repository
git push upstream main
```

---

## 📋 Git Remote Configuration Verification

To verify that your workspace is properly configured for dual-remote sync, run:

```bash
git remote -v
```

Expected Output:
```
origin    https://github.com/ikdevops2021-blip/DQMS_APP.git (fetch)
origin    https://github.com/ikdevops2021-blip/DQMS_APP.git (push)
upstream  https://github.com/ikdevops2021-blip/EnterpriseCoreWebApi.git (fetch)
upstream  https://github.com/ikdevops2021-blip/EnterpriseCoreWebApi.git (push)
```

---

## 🎯 Summary Rules for AI Assistants & Engineers

1. **Rule 1 (Origin vs Upstream)**: `origin` is ALWAYS the active application (`DQMS_APP`). `upstream` is ALWAYS the core template (`EnterpriseCoreWebApi`).
2. **Rule 2 (Core Scope)**: Cross-cutting code in `AntiGravity.Enterprise.Shared.Core`, `DataAccess`, `SeederApp`, and base DDL scripts belong in `upstream`.
3. **Rule 3 (Project Scope)**: Specific business rules, domain entities, and frontend apps belong in `origin`.
4. **Rule 4 (Bidirectional Sync)**: Pull from `upstream` regularly; push generic core improvements to `upstream` whenever created.
