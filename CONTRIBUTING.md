# Contributing to Product KPIs

This project uses a structured specification-driven workflow for feature development. This guide explains how to contribute new features and KPIs.

## Feature Development Workflow

We use **speckit** commands to plan and implement features. Each feature lives on its own branch with design artifacts in `specs/<feature-id>/`.

### 1. Create a Feature Branch

```bash
git checkout -b <NNN>-<feature-name>
# Example: git checkout -b 003-inventory-kpi
```

### 2. Specify the Feature

Run the specification command with your feature description:

```
/speckit.specify
```

Provide a natural language description of the feature. This creates `specs/<feature-id>/spec.md` with:
- User stories with acceptance scenarios
- Functional requirements
- Edge cases

### 3. Clarify Requirements

Run the clarification workflow to identify underspecified areas:

```
/speckit.clarify
```

This asks up to 5 targeted questions and encodes answers into the spec. Repeat until the spec is complete.

### 4. Create Implementation Plan

Generate detailed design artifacts:

```
/speckit.plan
```

This creates:
- `plan.md` - Implementation approach and architecture
- `research.md` - Technical research and options analysis
- `data-model.md` - Data structures and database schema
- `quickstart.md` - Usage guide for the feature

### 5. Generate Tasks

Create an ordered task list:

```
/speckit.tasks
```

This creates `tasks.md` with:
- Tasks organized by user story
- Dependency ordering
- Parallel task indicators
- Test-first approach (tests before implementation)

### 6. Implement

Execute the implementation plan:

```
/speckit.implement
```

This processes tasks from `tasks.md`, implementing tests first, then code.

## Adding a New KPI

KPIs are auto-discovered from the `src/kpis/` directory. Each KPI should have its own subfolder.

### Folder Structure

```
src/kpis/<kpi_name>/
├── __init__.py           # Export the KPI class
├── <kpi_name>.py         # Main implementation
└── config.json           # Optional: Configuration file
```

### Implementation Pattern

```python
# src/kpis/my_kpi/my_kpi.py
from datetime import datetime, timedelta, timezone
from typing import Any, Dict, List

from sqlalchemy import text
from sqlalchemy.engine import Engine

from src.kpis.base import BaseKPI, Parameter, ParameterType
from src.models.result import KPIResult


class MyKPI(BaseKPI):
    name = "My KPI Name"
    description = "Brief description of what this KPI measures"

    def get_parameters(self) -> List[Parameter]:
        """Define user-configurable parameters."""
        return [
            Parameter(
                name="start_date",
                display_name="Start Date",
                type=ParameterType.DATE,
                required=False,
                default=None,
                description="Start of date range, format: YYYY-MM-DD",
            ),
            Parameter(
                name="end_date",
                display_name="End Date",
                type=ParameterType.DATE,
                required=False,
                default=None,
                description="End of date range, format: YYYY-MM-DD",
            ),
        ]

    def execute(self, engine: Engine, params: Dict[str, Any]) -> KPIResult:
        """Execute the KPI query and return results."""
        start_time = datetime.now()

        try:
            # Parse parameters with defaults
            end_date = params.get("end_date") or datetime.now(timezone.utc).date()
            start_date = params.get("start_date") or (end_date - timedelta(days=13))

            # Validate
            if start_date > end_date:
                return KPIResult(
                    kpi_name=self.name,
                    columns=["column1", "column2"],
                    rows=[],
                    duration_seconds=(datetime.now() - start_time).total_seconds(),
                    parameters=params,
                    error="Invalid date range: start_date must be before end_date",
                )

            # Execute query
            query = """
                SELECT column1, COUNT(*) as column2
                FROM my_table
                WHERE creation_date >= :start_date
                  AND creation_date < :end_date + INTERVAL '1 day'
                GROUP BY column1
            """

            rows = []
            with engine.connect() as conn:
                result = conn.execute(text(query), {
                    "start_date": start_date,
                    "end_date": end_date,
                })
                for row in result:
                    rows.append({
                        "column1": row[0],
                        "column2": row[1],
                    })

            duration = (datetime.now() - start_time).total_seconds()
            return KPIResult(
                kpi_name=self.name,
                columns=["column1", "column2"],
                rows=rows,
                duration_seconds=duration,
                parameters={"start_date": start_date, "end_date": end_date},
            )

        except Exception as e:
            duration = (datetime.now() - start_time).total_seconds()
            return KPIResult(
                kpi_name=self.name,
                columns=["column1", "column2"],
                rows=[],
                duration_seconds=duration,
                parameters=params,
                error=str(e),
            )
```

### Package Init

```python
# src/kpis/my_kpi/__init__.py
from src.kpis.my_kpi.my_kpi import MyKPI

__all__ = ["MyKPI"]
```

### Unit Tests

```python
# tests/unit/test_my_kpi.py
import pytest
from unittest.mock import MagicMock
from datetime import date

from src.kpis.my_kpi import MyKPI
from src.models.result import KPIResult


class TestMyKPI:
    @pytest.fixture
    def kpi(self):
        return MyKPI()

    def test_get_parameters_returns_expected(self, kpi):
        params = kpi.get_parameters()
        param_names = [p.name for p in params]
        assert "start_date" in param_names
        assert "end_date" in param_names

    def test_execute_returns_kpi_result(self, kpi, mock_engine):
        mock_conn = MagicMock()
        mock_result = MagicMock()
        mock_result.__iter__ = lambda self: iter([("value1", 10)])
        mock_conn.execute.return_value = mock_result
        mock_engine.connect.return_value.__enter__ = MagicMock(return_value=mock_conn)
        mock_engine.connect.return_value.__exit__ = MagicMock(return_value=False)

        result = kpi.execute(mock_engine, {})

        assert isinstance(result, KPIResult)
        assert result.success is True

    def test_execute_catches_database_error(self, kpi, mock_engine):
        mock_engine.connect.side_effect = Exception("Connection failed")

        result = kpi.execute(mock_engine, {})

        assert result.success is False
        assert "Connection failed" in result.error
```

## Configuration Files

For KPIs that need configuration (e.g., lists of values to query), use a `config.json`:

```json
{
  "items_to_query": [
    "item_type_1",
    "item_type_2",
    "item_type_3"
  ]
}
```

Load it in your KPI:

```python
import json
from pathlib import Path

CONFIG_PATH = Path(__file__).parent / "config.json"

def load_config():
    if CONFIG_PATH.exists():
        with open(CONFIG_PATH) as f:
            return json.load(f)
    return {"items_to_query": ["default_item"]}
```

## Database Queries

### Best Practices

1. **Use indexed columns** - Check with `\d+ table_name` in psql
2. **Use CTEs for clarity** - Makes complex queries readable
3. **Always parameterize** - Never concatenate SQL strings
4. **Handle empty results** - Return zeros, not errors

### Common Patterns

```sql
-- CTE-based query
WITH matching_records AS (
    SELECT id
    FROM my_table
    WHERE indexed_column = :value
      AND creation_date >= :start_date
      AND creation_date < :end_date + INTERVAL '1 day'
),
records_with_issues AS (
    SELECT DISTINCT record_id
    FROM issue_log
    WHERE record_id IN (SELECT id FROM matching_records)
)
SELECT
    (SELECT COUNT(*) FROM matching_records) as total,
    (SELECT COUNT(*) FROM matching_records
     WHERE id NOT IN (SELECT record_id FROM records_with_issues)) as successful
```

## Commands Reference

```bash
# Run the tool
python -m src.main

# Run tests
pytest

# Run specific test file
pytest tests/unit/test_my_kpi.py -v

# Lint
ruff check src/

# Type check
mypy src/
```

## Project Structure

```
product_kpis/
├── CLAUDE.md              # AI assistant guidelines
├── CONTRIBUTING.md        # This file
├── requirements.txt       # Python dependencies
├── specs/                 # Feature specifications
│   ├── 001-kpi-tool/      # First feature
│   │   ├── spec.md
│   │   ├── plan.md
│   │   ├── research.md
│   │   ├── data-model.md
│   │   ├── quickstart.md
│   │   └── tasks.md
│   └── 002-first-time-right-exports/
│       └── ...
├── src/
│   ├── main.py            # Entry point
│   ├── config.py          # Runtime config
│   ├── menu/              # Console UI
│   ├── credentials/       # Keychain integration
│   ├── database/          # SQLAlchemy connection
│   ├── cache/             # Dev mode caching
│   ├── export/            # CSV/JSON exporters
│   ├── kpis/              # KPI implementations
│   │   ├── base.py        # BaseKPI class
│   │   ├── orders_by_date.py
│   │   └── first_time_right_exports/
│   ├── models/            # Data models
│   └── runner/            # KPI executor
└── tests/
    ├── conftest.py        # Shared fixtures
    ├── unit/              # Unit tests
    └── integration/       # Integration tests
```

## Checklist for New KPIs

- [ ] Create subfolder in `src/kpis/<kpi_name>/`
- [ ] Implement KPI class extending `BaseKPI`
- [ ] Add `__init__.py` exporting the class
- [ ] Create unit tests in `tests/unit/test_<kpi_name>.py`
- [ ] All tests pass: `pytest tests/unit/test_<kpi_name>.py -v`
- [ ] Linting passes: `ruff check src/kpis/<kpi_name>/`
- [ ] KPI appears in menu: `python -m src.main`
- [ ] Manual verification with real database
