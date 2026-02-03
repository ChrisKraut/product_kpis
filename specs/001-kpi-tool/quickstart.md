# Quickstart: Product KPIs Tool

**Branch**: `001-kpi-tool` | **Date**: 2026-02-03

## Prerequisites

- macOS (required for keychain integration)
- Python 3.11+
- VPN connection to database network
- Database read credentials

## Installation

```bash
# Clone and enter directory
cd product_kpis

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

## First Run

```bash
# Launch the tool
python -m src.main
```

On first run, you'll be prompted to enter your database URL. This is stored securely in your macOS keychain.

## Basic Usage

### Run All KPIs (Quick Mode)

1. Launch the tool: `python -m src.main`
2. Select option `1` (Run All KPIs)
3. Choose export format (CSV or JSON)
4. View progress as each KPI runs
5. Find results in `output/` directory

### Run Individual KPI

1. Launch the tool: `python -m src.main`
2. Select option `2` (Run Individual KPI)
3. Choose a KPI from the list
4. Configure parameters if needed
5. View results

### Development Mode

Development mode caches database queries locally to speed up iteration when developing new KPIs.

1. Launch the tool
2. Go to Settings → Toggle dev mode
3. Run KPIs (queries will be cached)
4. Modify KPI code
5. Re-run (uses cached data, no database round-trip)
6. Clear cache when you need fresh data

**Note**: Dev mode resets to OFF each time you launch the tool.

## Adding a New KPI

Create a new file in `src/kpis/`:

```python
# src/kpis/my_new_kpi.py
from src.kpis.base import BaseKPI, Parameter, KPIResult, ParameterType
from sqlalchemy.engine import Engine
from sqlalchemy import text
from typing import Dict, Any, List

class MyNewKPI(BaseKPI):
    name = "My New KPI"
    description = "Calculates something useful"

    def get_parameters(self) -> List[Parameter]:
        return [
            Parameter(
                name="shop_id",
                display_name="Shop ID",
                type=ParameterType.STRING,
                required=False,
                default=None,
                description="Filter by shop (optional)"
            )
        ]

    def execute(self, engine: Engine, params: Dict[str, Any]) -> KPIResult:
        query = """
            SELECT column1, column2
            FROM my_table
            WHERE (:shop_id IS NULL OR shop_id = :shop_id)
        """

        with engine.connect() as conn:
            result = conn.execute(text(query), params)
            rows = [dict(row._mapping) for row in result.fetchall()]

        return KPIResult(
            kpi_name=self.name,
            columns=["column1", "column2"],
            rows=rows
        )
```

That's it! The KPI will automatically appear in the menu on next launch.

## Output Formats

### CSV Export

```csv
date,orders_count
2026-01-20,42
2026-01-21,38
2026-01-22,45
```

### JSON Export

```json
[
  {"date": "2026-01-20", "orders_count": 42},
  {"date": "2026-01-21", "orders_count": 38},
  {"date": "2026-01-22", "orders_count": 45}
]
```

## Troubleshooting

### "Cannot connect to database"
- Ensure VPN is connected
- Verify database URL is correct: Settings → Show database URL

### "Keychain access denied"
- Grant terminal/IDE access in System Preferences → Security & Privacy → Privacy → Full Disk Access

### "KPI not appearing in menu"
- Ensure class extends `BaseKPI`
- Ensure file is in `src/kpis/` directory
- Check for syntax errors: `python -c "from src.kpis.your_kpi import YourKPI"`

## Project Structure

```
src/
├── __init__.py          # Package metadata
├── main.py              # Entry point (python -m src.main)
├── config.py            # Runtime configuration
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
│   └── orders_by_date.py # Example KPI
├── models/
│   └── result.py        # KPIResult and KPIReport
└── runner/
    └── executor.py      # KPI execution with progress
```
