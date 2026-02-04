# product_kpis Development Guidelines

Auto-generated from feature plans. Last updated: 2026-02-03

## Active Technologies
- Python 3.11+ + SQLAlchemy 2.0+, psycopg2-binary 2.9+ (002-first-time-right-exports)
- PostgreSQL (existing production database) (002-first-time-right-exports)

- **Python 3.11+** with SQLAlchemy 2.0+, keyring 24+, psycopg2-binary 2.9+

## Project Structure

```text
src/
├── __init__.py          # Package metadata
├── main.py              # Entry point (python -m src.main)
├── config.py            # Runtime configuration (dev_mode, export_format)
├── menu/
│   └── console.py       # Interactive console menu
├── credentials/
│   └── keychain.py      # macOS keychain integration
├── database/
│   └── connection.py    # SQLAlchemy engine
├── cache/
│   └── query_cache.py   # Dev mode query caching
├── export/
│   ├── base.py          # Exporter interface
│   ├── csv_exporter.py  # CSV export
│   └── json_exporter.py # JSON export
├── kpis/
│   ├── base.py          # BaseKPI class and Parameter types
│   └── orders_by_date.py # Example KPI (extend with more)
├── models/
│   └── result.py        # KPIResult and KPIReport dataclasses
└── runner/
    └── executor.py      # KPI execution with progress

tests/
├── conftest.py          # Shared fixtures
├── unit/                # Unit tests
└── integration/         # Integration tests
```

## Commands

```bash
# Run the tool
python -m src.main

# Run tests
pytest

# Lint
ruff check src/

# Type check (if mypy installed)
mypy src/
```

## Code Style

- Python 3.11+: Follow PEP 8, use type hints
- KPIs: Extend `BaseKPI` class in `src/kpis/`
- No credentials in code - use keychain only

## Adding a New KPI

1. Create a new file in `src/kpis/` (e.g., `my_kpi.py`)
2. Define a class extending `BaseKPI`
3. Set `name` and `description` class attributes
4. Implement `get_parameters()` and `execute()` methods
5. The KPI is auto-discovered on next launch

Example:
```python
from src.kpis.base import BaseKPI, Parameter, ParameterType
from src.models.result import KPIResult

class MyKPI(BaseKPI):
    name = "My KPI"
    description = "Does something useful"

    def get_parameters(self):
        return []

    def execute(self, engine, params):
        # Query and return KPIResult
        pass
```

## Active Features

- **001-kpi-tool**: Modular KPI tool with dev mode caching and file export

<!-- MANUAL ADDITIONS START -->
<!-- Add custom guidelines below this line -->
<!-- MANUAL ADDITIONS END -->

## Recent Changes
- 002-first-time-right-exports: Added Python 3.11+ + SQLAlchemy 2.0+, psycopg2-binary 2.9+
