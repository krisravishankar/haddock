# Plan: my-saas-app

## S001 — Project foundation and config
<!-- haddock: status=merged complexity=low dependencies=none updated=2026-03-02T14:30:00Z -->

**Goal**: Set up project structure, configuration, and base dependencies

**Files**: `package.json`, `tsconfig.json`, `.github/workflows/ci.yml`

### Stories
- [x] **S001-01**: Initialize project scaffolding
  - [x] Project directory created
  - [x] Package manager configured
  - [x] Basic config files in place
- [x] **S001-02**: Set up CI pipeline
  - [x] CI runs on push
  - [x] Linting and tests execute

---

## S002 — Database schema and migrations
<!-- haddock: status=in_progress complexity=medium dependencies=S001 updated=2026-03-05T09:15:00Z -->

**Goal**: Design and implement the core database schema with migrations

**Files**: `src/db/schema.ts`, `src/db/migrations/001_users.sql`, `src/db/migrations/002_projects.sql`

> **Note**: Consider using UUID for primary keys

### Stories
- [x] **S002-01**: Define user table schema
  - [x] User table with id, email, name, timestamps
  - [x] Migration runs cleanly up and down
- [ ] **S002-02**: Define project table schema
  - [ ] Project table with foreign key to user
  - [ ] Indexes on lookup fields

---

## S003 — Authentication and authorization
<!-- haddock: status=not_started complexity=high dependencies=S002 updated=2026-03-01T10:00:00Z -->

**Goal**: Implement JWT-based auth with role-based access control

**Files**: `src/auth/jwt.ts`, `src/auth/middleware.ts`, `src/auth/roles.ts`

### Stories
- [ ] **S003-01**: JWT token generation and validation
  - [ ] Login endpoint returns JWT
  - [ ] Token validation middleware works
  - [ ] Refresh token flow implemented
- [ ] **S003-02**: Role-based access control
  - [ ] Admin and user roles defined
  - [ ] Protected routes enforce roles

---

## S004 — API endpoints — CRUD operations
<!-- haddock: status=blocked complexity=medium dependencies=S002,S003 updated=2026-03-01T10:00:00Z -->

**Goal**: Build REST API endpoints for core resources

**Files**: `src/api/users.ts`, `src/api/projects.ts`, `src/api/validation.ts`

### Stories
- [ ] **S004-01**: User CRUD endpoints
  - [ ] GET/POST/PUT/DELETE for users
  - [ ] Input validation
  - [ ] Error handling
- [ ] **S004-02**: Project CRUD endpoints
  - [ ] GET/POST/PUT/DELETE for projects
  - [ ] Pagination support
  - [ ] Filter by owner

---
