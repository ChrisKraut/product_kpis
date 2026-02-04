# Implementation Plan: First Time Right KPI

**Branch**: `002-first-time-right-exports` | **Date**: 2026-02-03 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/002-first-time-right-exports/spec.md`

## Summary

Implement a "First Time Right" KPI that calculates the percentage of Post Fulfillment exports (`everstox_qm__import` records with specific `handler_fn_path`) that have zero associated error logs. The KPI extends the existing `BaseKPI` pattern, supports date range and shop filtering, and integrates with the existing menu-driven CLI tool.

## Technical Context

**Language/Version**: Python 3.11+
**Primary Dependencies**: SQLAlchemy 2.0+, psycopg2-binary 2.9+
**Storage**: PostgreSQL (existing production database)
**Testing**: pytest with mock engine fixtures
**Target Platform**: macOS CLI (local execution)
**Project Type**: Single project (existing structure)
**Performance Goals**: Query execution < 10 seconds (SC-001)
**Constraints**: Must follow existing BaseKPI pattern; no new dependencies
**Scale/Scope**: Single KPI file; queries against production tables with millions of rows

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

The project constitution is a template without specific principles defined. Applying implicit best practices:

| Gate | Status | Notes |
|------|--------|-------|
| Follow existing patterns | ✅ PASS | Extends BaseKPI, uses same parameter/result types |
| Test coverage | ✅ PASS | Unit tests will mirror orders_by_date pattern |
| No new dependencies | ✅ PASS | Uses only existing SQLAlchemy |
| Self-contained | ✅ PASS | Single file in src/kpis/, auto-discovered |

## Project Structure

### Documentation (this feature)

```text
specs/002-first-time-right-exports/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)

```text
src/
├── kpis/
│   ├── base.py              # BaseKPI class (existing)
│   ├── orders_by_date.py    # Reference implementation (existing)
│   └── first_time_right.py  # NEW: First Time Right KPI
└── models/
    └── result.py            # KPIResult dataclass (existing)

tests/
├── conftest.py              # Shared fixtures (existing)
└── unit/
    └── test_first_time_right.py  # NEW: Unit tests
```

**Structure Decision**: Single project structure following existing conventions. New KPI added to `src/kpis/` with corresponding test file.

## Complexity Tracking

No constitution violations. Implementation follows established patterns with minimal complexity.
