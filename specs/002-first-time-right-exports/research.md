# Research: First Time Right KPI

**Feature**: 002-first-time-right-exports | **Date**: 2026-02-03

## Database Schema Analysis

### Decision: Query Strategy for First Time Right Calculation
**Rationale**: Use LEFT JOIN with COUNT aggregation to efficiently determine exports with/without errors in a single query.

**Query Pattern**:
```sql
SELECT
    COUNT(*) as total_exports,
    COUNT(*) FILTER (WHERE el.id IS NULL) as successful_exports
FROM everstox_qm__import i
LEFT JOIN error_log el ON el.import_id = i.id
WHERE i.handler_fn_path = 'district_core.handlers.fulfillment_handler.FulfillmentHandler.process_fulfillment_from_exporter_export'
  AND i.creation_date >= :start_date
  AND i.creation_date < :end_date
```

**Alternatives Considered**:
1. **Subquery with NOT EXISTS** - More readable but potentially slower on large datasets
2. **Two separate queries** - Simpler but doubles database round-trips
3. **CTE approach** - Overkill for this use case

### Decision: Table Relationships Confirmed
**Rationale**: DDL analysis confirms the join path.

- `everstox_qm__import.id` (PK, uuid)
- `error_log.import_id` (FK, uuid, nullable) → references `everstox_qm__import.id`
- Index exists: `ix_error_log_import_id` on `error_log(import_id)`

### Decision: Handler Path Filter
**Rationale**: Clarified during spec review that `handler_fn_path` column identifies export type, not `tags` hstore.

**Value**: `district_core.handlers.fulfillment_handler.FulfillmentHandler.process_fulfillment_from_exporter_export`

**Note**: Index `everstox_qm__import_i_type` exists on `type` column, but `handler_fn_path` is the correct filter column per user clarification. Consider recommending index if performance issues arise.

## Existing Pattern Analysis

### Decision: Follow OrdersByDateKPI Pattern
**Rationale**: Maintains codebase consistency and leverages proven approach.

**Key patterns to replicate**:
1. Class extends `BaseKPI` with `name` and `description` class attributes
2. `get_parameters()` returns list of `Parameter` objects
3. `execute()` accepts `engine` and `params`, returns `KPIResult`
4. Query uses `text()` for raw SQL with named parameters
5. Error handling wraps entire execute in try/except
6. Duration tracking with `datetime.now()` delta

### Decision: Parameter Configuration
**Rationale**: Match existing KPI patterns while supporting spec requirements.

| Parameter | Type | Required | Default | Notes |
|-----------|------|----------|---------|-------|
| start_date | DATE | No | Today - 14 days | Matches existing KPI default |
| end_date | DATE | No | Today | Inclusive |
| shop_id | STRING | No | None | UUID as string, optional filter |

## Performance Considerations

### Decision: Single Aggregation Query
**Rationale**: Minimize database round-trips; leverage existing indexes.

**Expected performance**:
- `error_log.import_id` is indexed
- `everstox_qm__import.creation_date` has multiple partial indexes
- 14-day default window limits scan scope
- Target: < 10 seconds per SC-001

### Decision: No Pagination Needed
**Rationale**: Result is a single aggregated row (or few rows if grouped by day), not a large result set.

## Test Strategy

### Decision: Unit Tests with Mock Engine
**Rationale**: Follow existing test pattern in `conftest.py`.

**Test cases**:
1. Parameters defined correctly (required, defaults, types)
2. Successful execution returns expected KPIResult structure
3. Empty result set handled gracefully
4. Database error caught and returned in error field
5. Shop filter applied when provided
6. Date range filter applied correctly

## Unresolved Items

None. All technical decisions resolved through DDL analysis and spec clarifications.
