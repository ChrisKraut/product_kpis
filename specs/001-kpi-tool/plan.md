# Implementation Plan: Product KPIs Tool

**Branch**: `001-kpi-tool` | **Date**: 2026-02-03 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-kpi-tool/spec.md`

## Summary

Build a maintainable Product KPIs CLI tool with modular KPI architecture, development mode caching, and file export (CSV/JSON). Restructure existing code into a clean, extensible design where new KPIs are auto-discovered without modifying existing files.

## Technical Context

**Language/Version**: Python 3.11+
**Primary Dependencies**: SQLAlchemy 2.0+, keyring 24+, psycopg2-binary 2.9+
**Storage**: PostgreSQL (via VPN), local JSON cache for dev mode
**Testing**: pytest with fixtures for database mocking
**Target Platform**: macOS (keychain dependency)
**Project Type**: Single CLI application
**Performance Goals**: KPI queries complete within 60 seconds each; full report generation within 5 minutes
**Constraints**: No credentials in repository; macOS keychain only; VPN connection required for database
**Scale/Scope**: Single user local tool; 5-20 KPIs expected; data volumes dependent on shop size

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

The project constitution is not yet configured with specific principles. Using sensible defaults:

| Principle | Status | Notes |
|-----------|--------|-------|
| Modular Design | ✅ PASS | KPIs as separate modules with auto-discovery |
| Testability | ✅ PASS | Each KPI independently testable; cache layer mockable |
| Security | ✅ PASS | Credentials in keychain only; no secrets in code |
| Simplicity | ✅ PASS | Single entry point; minimal dependencies |

## Project Structure

### Documentation (this feature)

```text
specs/001-kpi-tool/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit.tasks)
```

### Source Code (repository root)

```text
src/
├── __init__.py
├── main.py              # Single entry point with CLI/menu
├── config.py            # Dev mode state, settings
├── menu/
│   ├── __init__.py
│   └── console.py       # Interactive menu rendering
├── credentials/
│   ├── __init__.py
│   └── keychain.py      # macOS keychain integration (from login.py)
├── database/
│   ├── __init__.py
│   └── connection.py    # SQLAlchemy engine (from database.py)
├── cache/
│   ├── __init__.py
│   └── query_cache.py   # Dev mode caching (from utils.py)
├── export/
│   ├── __init__.py
│   ├── csv_exporter.py
│   └── json_exporter.py
├── kpis/
│   ├── __init__.py      # KPI discovery/registry
│   ├── base.py          # Base KPI class
│   └── orders_by_date.py # First KPI (from product_kpis.py)
└── runner/
    ├── __init__.py
    └── executor.py      # Run single/all KPIs with progress

tests/
├── __init__.py
├── conftest.py          # Shared fixtures
├── unit/
│   ├── test_kpis/
│   ├── test_cache.py
│   └── test_export.py
└── integration/
    └── test_runner.py
```

**Structure Decision**: Single project structure with clear module separation. The `kpis/` directory allows auto-discovery - any Python file with a class extending `BaseKPI` is automatically registered.

## Complexity Tracking

No violations requiring justification. The design follows YAGNI principles:
- No repository pattern (direct SQLAlchemy queries in KPIs)
- No dependency injection framework (simple imports)
- No async/await (unnecessary for sequential CLI tool)
