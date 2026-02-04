# Data Model: First Time Right KPI

**Feature**: 002-first-time-right-exports | **Date**: 2026-02-03

## Database Entities (Read-Only)

This KPI queries existing production tables. No schema modifications required.

### everstox_qm__import (Source Table)

Represents export/import operations in the system.

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | uuid | NO | Primary key |
| handler_fn_path | varchar | NO | Identifies the handler type; filter value: `district_core.handlers.fulfillment_handler.FulfillmentHandler.process_fulfillment_from_exporter_export` |
| creation_date | timestamp | YES | When the export was created |
| shop_id | uuid | YES | Associated shop for filtering |
| state | enum | NO | Current state (imported, error, etc.) |

**Relevant Indexes**:
- `everstox_qm__import_i_type` on `type`
- Various partial indexes on `creation_date` and `state`

### error_log (Related Table)

Stores error entries linked to imports.

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | uuid | NO | Primary key |
| import_id | uuid | YES | FK to everstox_qm__import.id |
| creation_date | timestamp | YES | When the error was logged |
| error_message | text | YES | Error details |

**Relevant Indexes**:
- `ix_error_log_import_id` on `import_id`

## Join Relationship

```
everstox_qm__import (1) ←──── (0..N) error_log
                     id  ←────────── import_id
```

- One import can have zero or many error_log entries
- An import with zero error_log entries is "First Time Right"
- An import with one or more error_log entries is NOT "First Time Right"

## KPI Output Schema

### KPIResult Structure

The KPI returns a `KPIResult` dataclass with:

```python
@dataclass
class KPIResult:
    kpi_name: str           # "First Time Right"
    columns: List[str]      # ["total_exports", "successful_exports", "failed_exports", "success_rate"]
    rows: List[Dict]        # Single row with aggregated metrics
    executed_at: datetime
    duration_seconds: float
    parameters: Dict        # {start_date, end_date, shop_id}
    from_cache: bool
    error: Optional[str]
```

### Output Row Schema

| Field | Type | Description |
|-------|------|-------------|
| total_exports | int | Count of all exports matching filters |
| successful_exports | int | Count of exports with zero error_log entries |
| failed_exports | int | Count of exports with one or more error_log entries |
| success_rate | float | Percentage: (successful / total) * 100, rounded to 2 decimals |

### Example Output

```json
{
  "kpi_name": "First Time Right",
  "columns": ["total_exports", "successful_exports", "failed_exports", "success_rate"],
  "rows": [
    {
      "total_exports": 1250,
      "successful_exports": 1100,
      "failed_exports": 150,
      "success_rate": 88.00
    }
  ],
  "parameters": {
    "start_date": "2026-01-20",
    "end_date": "2026-02-03",
    "shop_id": null
  }
}
```

### Empty Result Handling

When no exports match the filter criteria:

```json
{
  "rows": [
    {
      "total_exports": 0,
      "successful_exports": 0,
      "failed_exports": 0,
      "success_rate": 0.0
    }
  ]
}
```

## SQL Query Design

### Core Query

```sql
SELECT
    COUNT(DISTINCT i.id) as total_exports,
    COUNT(DISTINCT i.id) FILTER (WHERE el.id IS NULL) as successful_exports
FROM everstox_qm__import i
LEFT JOIN error_log el ON el.import_id = i.id
WHERE i.handler_fn_path = :handler_path
  AND i.creation_date >= :start_date
  AND i.creation_date < :end_date + INTERVAL '1 day'
  -- Optional: AND i.shop_id = :shop_id
```

**Notes**:
- `DISTINCT` ensures each import is counted once even with multiple error_log entries
- `FILTER (WHERE el.id IS NULL)` counts only imports with no matching error_log
- `failed_exports` = `total_exports` - `successful_exports` (computed in Python)
- `success_rate` = `(successful_exports / total_exports) * 100` (computed in Python, handle division by zero)
