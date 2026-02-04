# Quickstart: First Time Right KPI

**Feature**: 002-first-time-right-exports | **Date**: 2026-02-03

## Overview

The First Time Right KPI measures the percentage of Post Fulfillment exports that succeed on the first attempt (no error logs).

## Files to Create

| File | Purpose |
|------|---------|
| `src/kpis/first_time_right.py` | KPI implementation |
| `tests/unit/test_first_time_right.py` | Unit tests |

## Implementation Steps

### 1. Create the KPI Class

```python
# src/kpis/first_time_right.py

from datetime import datetime, timedelta
from typing import Any, Dict, List

from sqlalchemy import text
from sqlalchemy.engine import Engine

from src.kpis.base import BaseKPI, Parameter, ParameterType
from src.models.result import KPIResult


class FirstTimeRightKPI(BaseKPI):
    """First Time Right KPI for Post Fulfillment exports."""

    name = "First Time Right"
    description = "Success rate for Post Fulfillment exports (no error logs)"

    HANDLER_PATH = (
        "district_core.handlers.fulfillment_handler."
        "FulfillmentHandler.process_fulfillment_from_exporter_export"
    )

    def get_parameters(self) -> List[Parameter]:
        return [
            Parameter(
                name="start_date",
                display_name="Start Date",
                type=ParameterType.DATE,
                required=False,
                default=None,  # Will default to 14 days ago
                description="Start of date range (defaults to 14 days ago)",
            ),
            Parameter(
                name="end_date",
                display_name="End Date",
                type=ParameterType.DATE,
                required=False,
                default=None,  # Will default to today
                description="End of date range (defaults to today)",
            ),
            Parameter(
                name="shop_id",
                display_name="Shop ID",
                type=ParameterType.STRING,
                required=False,
                default=None,
                description="Filter by shop ID (leave empty for all shops)",
            ),
        ]

    def execute(self, engine: Engine, params: Dict[str, Any]) -> KPIResult:
        # Implementation here - see data-model.md for query design
        pass
```

### 2. Run the Tool

```bash
# Start the CLI
python -m src.main

# Select "First Time Right" from the menu
# Enter optional parameters when prompted
```

### 3. Expected Output

```
First Time Right
================
Total Exports:      1,250
Successful:         1,100
Failed:               150
Success Rate:       88.00%

Executed in 2.34s
```

## Testing

```bash
# Run all tests
pytest

# Run only First Time Right tests
pytest tests/unit/test_first_time_right.py -v
```

## Key Design Decisions

1. **Single aggregation query** - Uses LEFT JOIN with FILTER clause for efficiency
2. **14-day default** - Matches existing Orders by Date KPI pattern
3. **Binary success** - Any error_log entry means failure (not first time right)
4. **Auto-discovery** - Placing file in `src/kpis/` makes it appear in menu automatically
