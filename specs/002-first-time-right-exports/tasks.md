# Tasks: First Time Right KPI

**Input**: Design documents from `/specs/002-first-time-right-exports/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

**Tests**: Unit tests included (research.md specifies test strategy)

**Organization**: Tasks grouped by user story for independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: Verify existing infrastructure supports the new KPI

- [x] T001 Verify BaseKPI class exists and is importable from src/kpis/base.py
- [x] T002 Verify KPIResult dataclass exists in src/models/result.py
- [x] T003 Verify test fixtures exist in tests/conftest.py

**Checkpoint**: Existing infrastructure confirmed - ready for implementation

---

## Phase 2: Foundational

**Purpose**: No new foundational work needed - this feature adds to existing KPI framework

**Note**: The existing KPI framework (BaseKPI, KPIResult, auto-discovery, menu integration) is already complete from feature 001-kpi-tool. This feature only adds a new KPI file.

**Checkpoint**: Foundation ready (pre-existing) - user story implementation can begin

---

## Phase 3: User Story 1 - View First Time Right Rate (Priority: P1)

**Goal**: Display the "First Time Right" percentage for Post Fulfillment exports with total count and success rate.

**Independent Test**: Run the KPI against the database with default parameters; verify it returns total_exports, successful_exports, failed_exports, and success_rate.

### Tests for User Story 1

- [x] T004 [P] [US1] Create unit test file with test class skeleton in tests/unit/test_first_time_right.py
- [x] T005 [P] [US1] Write test for get_parameters() returns correct parameter definitions in tests/unit/test_first_time_right.py
- [x] T006 [P] [US1] Write test for execute() returns KPIResult with correct columns in tests/unit/test_first_time_right.py
- [x] T007 [P] [US1] Write test for execute() handles empty result set gracefully in tests/unit/test_first_time_right.py
- [x] T008 [P] [US1] Write test for execute() catches database errors and returns error in result in tests/unit/test_first_time_right.py

### Implementation for User Story 1

- [x] T009 [US1] Create FirstTimeRightKPI class with name and description in src/kpis/first_time_right.py
- [x] T010 [US1] Implement get_parameters() with start_date, end_date, shop_id parameters in src/kpis/first_time_right.py
- [x] T011 [US1] Implement execute() method with core SQL query (LEFT JOIN with FILTER) in src/kpis/first_time_right.py
- [x] T012 [US1] Add default date range logic (14 days) when parameters not provided in src/kpis/first_time_right.py
- [x] T013 [US1] Compute failed_exports and success_rate from query results in src/kpis/first_time_right.py
- [x] T014 [US1] Add error handling (try/except) with error field in KPIResult in src/kpis/first_time_right.py
- [x] T015 [US1] Add duration tracking using datetime.now() delta in src/kpis/first_time_right.py

**Checkpoint**: User Story 1 complete - KPI shows First Time Right rate with default 14-day window

---

## Phase 4: User Story 2 - Filter by Date Range (Priority: P2)

**Goal**: Allow users to specify custom start and end dates to analyze specific time periods.

**Independent Test**: Run the KPI with explicit start_date and end_date parameters; verify results only include exports from the specified period.

### Tests for User Story 2

- [x] T016 [P] [US2] Write test for date range filtering applies correctly in tests/unit/test_first_time_right.py
- [x] T017 [P] [US2] Write test for invalid date range (end before start) returns validation error in tests/unit/test_first_time_right.py

### Implementation for User Story 2

- [x] T018 [US2] Add date range validation (end_date >= start_date) in execute() in src/kpis/first_time_right.py
- [x] T019 [US2] Ensure date parameters are properly converted and passed to SQL query in src/kpis/first_time_right.py

**Checkpoint**: User Story 2 complete - Users can filter by custom date ranges

---

## Phase 5: User Story 3 - Filter by Shop (Priority: P3)

**Goal**: Allow users to filter results by shop ID to compare performance across shops.

**Independent Test**: Run the KPI with a shop_id parameter; verify only that shop's exports are included.

### Tests for User Story 3

- [x] T020 [P] [US3] Write test for shop_id filter applies when provided in tests/unit/test_first_time_right.py
- [x] T021 [P] [US3] Write test for shop_id filter is optional (query works without it) in tests/unit/test_first_time_right.py

### Implementation for User Story 3

- [x] T022 [US3] Add conditional shop_id WHERE clause to SQL query in src/kpis/first_time_right.py
- [x] T023 [US3] Ensure shop_id parameter is properly passed to query when provided in src/kpis/first_time_right.py

**Checkpoint**: User Story 3 complete - Users can filter by shop

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final validation and cleanup

- [x] T024 Run all unit tests and verify they pass: pytest tests/unit/test_first_time_right.py -v
- [x] T025 Run linting: ruff check src/kpis/first_time_right.py
- [x] T026 Verify KPI appears in menu by running python -m src.main
- [x] T027 Test against actual database with real data (manual verification)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - verification only
- **Foundational (Phase 2)**: N/A - uses existing framework
- **User Story 1 (Phase 3)**: Can start after Setup verification
- **User Story 2 (Phase 4)**: Depends on US1 core implementation (T009-T015)
- **User Story 3 (Phase 5)**: Depends on US1 core implementation (T009-T015)
- **Polish (Phase 6)**: Depends on all user stories complete

### User Story Dependencies

- **User Story 1 (P1)**: Independent - core KPI functionality
- **User Story 2 (P2)**: Extends US1 - adds date range validation (core query already supports dates)
- **User Story 3 (P3)**: Extends US1 - adds shop filter to query (independent of US2)

### Within Each User Story

- Tests written FIRST (T004-T008, T016-T017, T020-T021)
- Verify tests FAIL before implementation
- Implementation follows test definitions
- All tests pass before story is complete

### Parallel Opportunities

**Phase 3 - User Story 1**:
- T004, T005, T006, T007, T008 (all tests) can run in parallel
- T009 must complete before T010-T015

**Phase 4 - User Story 2**:
- T016, T017 (tests) can run in parallel
- T018, T019 are sequential

**Phase 5 - User Story 3**:
- T020, T021 (tests) can run in parallel
- T022, T023 are sequential

**Cross-Story Parallelism**:
- US2 and US3 can be implemented in parallel after US1 is complete (they modify different parts of the query)

---

## Parallel Example: User Story 1 Tests

```bash
# Launch all US1 tests together:
Task: "Create unit test file with test class skeleton in tests/unit/test_first_time_right.py"
Task: "Write test for get_parameters() returns correct parameter definitions"
Task: "Write test for execute() returns KPIResult with correct columns"
Task: "Write test for execute() handles empty result set gracefully"
Task: "Write test for execute() catches database errors"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup verification
2. Complete Phase 3: User Story 1 (core KPI with 14-day default)
3. **STOP and VALIDATE**: Test KPI works with real database
4. Deploy if ready - users can view First Time Right rate

### Incremental Delivery

1. Setup verification → Confirmed
2. User Story 1 → Test → Deploy (MVP!)
3. User Story 2 → Test → Deploy (adds date filtering)
4. User Story 3 → Test → Deploy (adds shop filtering)
5. Each story adds value without breaking previous functionality

### Single File Strategy

All implementation tasks modify the same file (`src/kpis/first_time_right.py`). Recommended approach:
1. Complete all US1 implementation (T009-T015) in one session
2. Then US2 additions (T018-T019)
3. Then US3 additions (T022-T023)

---

## Notes

- [P] tasks = different files or independent test cases
- [Story] label maps task to specific user story
- Implementation directory: `src/kpis/first_time_right_exports/`
- Main file: `src/kpis/first_time_right_exports/first_time_right_exports.py`
- Config file: `src/kpis/first_time_right_exports/config.json`
- Test file: `tests/unit/test_first_time_right_exports.py`
- No database migrations needed (read-only queries)
- KPI auto-discovered by existing framework

## Post-Implementation Changes

The implementation evolved during development:
- Changed from `everstox_qm__import` to `everstox_qm__export_http` table
- Changed from `handler_fn_path` filter to `tags -> 'action_type'` (indexed)
- Changed from `error_log.import_id` to `error_log.export_id`
- Added multi-action-type support via `config.json`
- Added discovery mode (`discover_action_types=true`)
- Renamed class to `FirstTimeRightExportsKPI`
- Moved to subfolder structure for future imports KPI
