# Tasks: Product KPIs Tool

**Input**: Design documents from `/specs/001-kpi-tool/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Not explicitly requested in specification - test tasks omitted.

**Organization**: Tasks grouped by user story for independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1-US5)
- All paths relative to repository root

---

## Phase 1: Setup

**Purpose**: Create project structure and initialize Python package

- [x] T001 Create src/ directory structure per plan.md with all subdirectories
- [x] T002 [P] Create src/__init__.py with package metadata
- [x] T003 [P] Create src/menu/__init__.py
- [x] T004 [P] Create src/credentials/__init__.py
- [x] T005 [P] Create src/database/__init__.py
- [x] T006 [P] Create src/cache/__init__.py
- [x] T007 [P] Create src/export/__init__.py
- [x] T008 [P] Create src/kpis/__init__.py (empty, will add discovery later)
- [x] T009 [P] Create src/runner/__init__.py
- [x] T010 [P] Create tests/ directory structure with tests/__init__.py and tests/conftest.py
- [x] T011 Update requirements.txt to add pytest and ruff
- [x] T012 [P] Create pyproject.toml with ruff configuration and project metadata

**Checkpoint**: Project skeleton ready for implementation

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core modules that ALL user stories depend on - MUST complete before any story

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

### Data Types & Models

- [x] T013 [P] Create src/kpis/base.py with BaseKPI abstract class, Parameter dataclass, ParameterType enum per contracts/kpi_interface.py
- [x] T014 [P] Create src/models/__init__.py and src/models/result.py with KPIResult and KPIReport dataclasses per data-model.md
- [x] T015 [P] Create src/config.py with RuntimeConfig class (dev_mode, export_format, output_directory) and ExportFormat enum

### Core Infrastructure

- [x] T016 Migrate login.py to src/credentials/keychain.py preserving all functions (get_db_url, set_db_url, clear_db_url, has_db_url)
- [x] T017 [P] Migrate database.py to src/database/connection.py preserving init_db_engine function
- [x] T018 Implement KPI auto-discovery in src/kpis/__init__.py using importlib pattern from research.md (discover_kpis function)

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 2 - Database Credential Management (Priority: P1)

**Goal**: Users can securely store, view, update, and clear database credentials via menu

**Independent Test**: Store credentials, exit tool, relaunch, verify connection works without re-entering credentials

### Implementation

- [x] T019 [US2] Create src/menu/console.py with Menu class - main menu rendering with numbered options
- [x] T020 [US2] Implement Settings submenu in src/menu/console.py with credential management options (set, show, clear)
- [x] T021 [US2] Add credential validation in src/credentials/keychain.py - test connection when setting URL
- [x] T022 [US2] Create src/main.py entry point that initializes menu and runs main loop
- [x] T023 [US2] Add masked URL display in Settings → Show database URL (password hidden)

**Checkpoint**: Credential management fully functional and testable independently

---

## Phase 4: User Story 1 - Quick KPI Report (Priority: P1) 🎯 MVP

**Goal**: Users can run all KPIs with a single action, see progress, and get exported report

**Independent Test**: Select "Run All KPIs", observe progress for each KPI, verify output file created

### KPI Implementation

- [x] T024 [P] [US1] Migrate product_kpis.py to src/kpis/orders_by_date.py as OrdersByDateKPI class extending BaseKPI
- [x] T025 [US1] Update src/kpis/__init__.py to export discovered KPIs list

### Export Implementation

- [x] T026 [P] [US1] Create src/export/base.py with Exporter abstract base class
- [x] T027 [P] [US1] Implement src/export/csv_exporter.py with CSVExporter class
- [x] T028 [P] [US1] Implement src/export/json_exporter.py with JSONExporter class
- [x] T029 [US1] Create src/export/__init__.py with get_exporter(format) factory function

### Runner Implementation

- [x] T030 [US1] Create src/runner/executor.py with KPIExecutor class - execute_all method with progress display
- [x] T031 [US1] Add progress output format: [1/N] KPI Name... ✓ (Xs) or ✗ (error message)
- [x] T032 [US1] Implement error continuation in executor - continue on KPI failure, collect all errors

### Menu Integration

- [x] T033 [US1] Add "Run All KPIs" option to main menu in src/menu/console.py
- [x] T034 [US1] Add export format selection prompt (CSV/JSON) before running
- [x] T035 [US1] Display output file path after successful export

**Checkpoint**: MVP complete - Run All KPIs works end-to-end with export

---

## Phase 5: User Story 3 - Individual KPI Deep Dive (Priority: P2)

**Goal**: Users can select a specific KPI, configure parameters, and run it individually

**Independent Test**: Select "Run Individual KPI", choose a KPI, set shop_id parameter, verify filtered results

### Implementation

- [x] T036 [US3] Add "Run Individual KPI" option to main menu in src/menu/console.py
- [x] T037 [US3] Implement KPI selection submenu showing all discovered KPIs with descriptions
- [x] T038 [US3] Implement parameter input prompts based on KPI.get_parameters() in src/menu/console.py
- [x] T039 [US3] Add execute_single method to src/runner/executor.py for running one KPI with params
- [x] T040 [US3] Display detailed KPI results in console (more verbose than Run All summary)

**Checkpoint**: Individual KPI execution works with parameter configuration

---

## Phase 6: User Story 4 - Development Mode with Caching (Priority: P2)

**Goal**: Developers can enable dev mode to cache queries and iterate faster

**Independent Test**: Enable dev mode, run KPI (fetches from DB), run again (uses cache), disable dev mode, run again (fetches from DB)

### Cache Implementation

- [x] T041 [P] [US4] Migrate cache functions from utils.py to src/cache/query_cache.py
- [x] T042 [US4] Create src/cache/__init__.py with QueryCache class wrapping cache functions
- [x] T043 [US4] Add cache integration to src/runner/executor.py - check cache before query when dev_mode=True

### Menu Integration

- [x] T044 [US4] Add dev mode indicator to main menu header: Mode: [PRODUCTION] or Mode: [DEV - cached data]
- [x] T045 [US4] Add "Toggle dev mode" option to Settings submenu in src/menu/console.py
- [x] T046 [US4] Add "Clear cache" option to Settings submenu
- [x] T047 [US4] Ensure dev_mode resets to False on each launch (in RuntimeConfig initialization)

**Checkpoint**: Dev mode caching works, visible in menu, resets on launch

---

## Phase 7: User Story 5 - Add New KPI (Priority: P3)

**Goal**: New KPIs are auto-discovered without modifying existing code

**Independent Test**: Create a new KPI file following the pattern, restart tool, verify it appears in menu and Run All

### Verification & Documentation

- [x] T048 [US5] Verify auto-discovery works by checking discover_kpis() finds OrdersByDateKPI
- [x] T049 [US5] Add validation in discover_kpis() to skip KPIs missing required attributes (name, description)
- [x] T050 [US5] Update specs/001-kpi-tool/quickstart.md with actual paths matching final implementation

**Checkpoint**: KPI auto-discovery verified and documented

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Cleanup, error handling improvements, and project finalization

### Error Handling

- [x] T051 [P] Add connection error handling in src/database/connection.py with actionable message about VPN
- [x] T052 [P] Add keychain access error handling in src/credentials/keychain.py with System Preferences guidance
- [x] T053 Add consistent error formatting across all modules

### Cleanup

- [x] T054 Remove old root-level Python files (login.py, database.py, product_kpis.py, utils.py, handler.py, main.py)
- [x] T055 [P] Update .gitignore to exclude cache/ and output/ directories
- [x] T056 [P] Verify no credentials in repository by scanning all files
- [x] T057 Update CLAUDE.md with final project structure and commands

### Validation

- [x] T058 Run tool end-to-end: set credentials → run all → verify export
- [x] T059 Verify SC-001: Complete report in ≤3 interactions (launch → menu → run all → results)
- [ ] T060 Verify SC-002: Create second test KPI, confirm it appears without code changes

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies - start immediately
- **Phase 2 (Foundational)**: Depends on Phase 1 - BLOCKS all user stories
- **Phase 3 (US2)**: Depends on Phase 2 - Menu + Credentials
- **Phase 4 (US1)**: Depends on Phase 2 + T019 from US2 (needs menu framework) - MVP
- **Phase 5 (US3)**: Depends on Phase 4 (builds on menu and runner)
- **Phase 6 (US4)**: Depends on Phase 4 (integrates with runner)
- **Phase 7 (US5)**: Depends on Phase 4 (verifies discovery with real KPI)
- **Phase 8 (Polish)**: Depends on all desired stories complete

### User Story Dependencies

| Story | Depends On | Can Parallelize With |
|-------|------------|---------------------|
| US2 (Credentials) | Foundational | None (needed by others) |
| US1 (Run All) | Foundational, US2 menu | None (MVP priority) |
| US3 (Individual) | US1 runner | US4, US5 |
| US4 (Dev Mode) | US1 runner | US3, US5 |
| US5 (Auto-discovery) | US1 KPI | US3, US4 |

### Parallel Opportunities Per Phase

**Phase 1**: T002-T010, T011-T012 can run in parallel
**Phase 2**: T013-T015 (data types), T016-T017 (infrastructure) - then T018
**Phase 4**: T024 + T026-T028 can run in parallel (KPI + Exporters)
**Phase 6**: T041 can run in parallel with earlier US4 menu tasks
**Phase 8**: T051-T052, T055-T056 can run in parallel

---

## Parallel Example: Phase 2 Foundational

```bash
# Launch all data type definitions together:
Task: "Create src/kpis/base.py with BaseKPI abstract class"
Task: "Create src/models/result.py with KPIResult and KPIReport"
Task: "Create src/config.py with RuntimeConfig class"

# Then infrastructure:
Task: "Migrate login.py to src/credentials/keychain.py"
Task: "Migrate database.py to src/database/connection.py"

# Finally (depends on base.py):
Task: "Implement KPI auto-discovery in src/kpis/__init__.py"
```

---

## Parallel Example: Phase 4 User Story 1

```bash
# Launch KPI and exporters in parallel:
Task: "Migrate product_kpis.py to src/kpis/orders_by_date.py"
Task: "Create src/export/base.py with Exporter abstract class"
Task: "Implement src/export/csv_exporter.py"
Task: "Implement src/export/json_exporter.py"

# Then runner (depends on KPI + exporters):
Task: "Create src/runner/executor.py with KPIExecutor class"
```

---

## Implementation Strategy

### MVP First (User Stories 1 + 2 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: US2 - Credential Management
4. Complete Phase 4: US1 - Quick KPI Report
5. **STOP and VALIDATE**: Test Run All KPIs end-to-end
6. Deploy/demo MVP

### Incremental Delivery

1. Setup + Foundational → Foundation ready
2. Add US2 (Credentials) → Can store/view credentials
3. Add US1 (Run All) → MVP! Can generate reports
4. Add US3 (Individual) → Power user features
5. Add US4 (Dev Mode) → Developer workflow
6. Add US5 (Auto-discovery verification) → Maintainability confirmed
7. Polish → Production ready

---

## Summary

| Phase | Story | Task Count | Parallel Tasks |
|-------|-------|------------|----------------|
| 1 | Setup | 12 | 9 |
| 2 | Foundational | 6 | 4 |
| 3 | US2 - Credentials (P1) | 5 | 0 |
| 4 | US1 - Run All (P1) 🎯 | 12 | 4 |
| 5 | US3 - Individual (P2) | 5 | 0 |
| 6 | US4 - Dev Mode (P2) | 7 | 1 |
| 7 | US5 - Auto-discovery (P3) | 3 | 0 |
| 8 | Polish | 10 | 5 |
| **Total** | | **60** | **23** |

**MVP Scope**: Phases 1-4 (35 tasks) - Setup + Foundational + US2 + US1

---

## Notes

- [P] tasks = different files, no dependencies on incomplete tasks
- [Story] label maps task to specific user story for traceability
- Each user story checkpoint validates independent functionality
- Commit after each task or logical group
- Old files (login.py, database.py, etc.) remain until Phase 8 cleanup
