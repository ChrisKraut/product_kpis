# Data Model: Product KPIs Tool

**Branch**: `001-kpi-tool` | **Date**: 2026-02-03

## Overview

This document defines the internal data structures for the Product KPIs tool. Note: The external database schema (orders, shops, etc.) is not controlled by this tool - it's a read-only consumer.

---

## Core Entities

### KPI Definition

Represents metadata about a KPI (not the results).

| Field | Type | Description |
|-------|------|-------------|
| `name` | `str` | Display name (e.g., "Orders by Date") |
| `description` | `str` | What this KPI measures |
| `parameters` | `List[Parameter]` | Configurable inputs |

### Parameter

A configurable input for a KPI.

| Field | Type | Description |
|-------|------|-------------|
| `name` | `str` | Parameter identifier (e.g., "shop_id") |
| `display_name` | `str` | Human-readable name (e.g., "Shop ID") |
| `type` | `ParameterType` | One of: `STRING`, `DATE`, `INTEGER`, `BOOLEAN` |
| `required` | `bool` | Whether parameter is mandatory |
| `default` | `Optional[Any]` | Default value if not provided |
| `description` | `str` | Help text for the parameter |

### KPIResult

The output of executing a KPI.

| Field | Type | Description |
|-------|------|-------------|
| `kpi_name` | `str` | Name of the KPI that produced this result |
| `executed_at` | `datetime` | When the KPI was executed |
| `duration_seconds` | `float` | How long execution took |
| `parameters` | `Dict[str, Any]` | Parameters used for this execution |
| `columns` | `List[str]` | Column names in order |
| `rows` | `List[Dict[str, Any]]` | Result data as list of dicts |
| `row_count` | `int` | Number of rows returned |
| `from_cache` | `bool` | Whether result came from cache |
| `error` | `Optional[str]` | Error message if execution failed |

### KPIReport

A collection of KPI results from a "Run All" execution.

| Field | Type | Description |
|-------|------|-------------|
| `generated_at` | `datetime` | When the report was generated |
| `results` | `List[KPIResult]` | Individual KPI results |
| `total_duration_seconds` | `float` | Total time for all KPIs |
| `success_count` | `int` | Number of successful KPIs |
| `failure_count` | `int` | Number of failed KPIs |
| `dev_mode` | `bool` | Whether dev mode was active |

### CacheEntry

Stored query results for dev mode.

| Field | Type | Description |
|-------|------|-------------|
| `cache_key` | `str` | SHA256 hash of query + params |
| `query_name` | `str` | Descriptive name for the query |
| `shop_id` | `str` | Shop ID for cache organization |
| `created_at` | `datetime` | When cache was created |
| `data` | `List[Dict[str, Any]]` | Cached query results |
| `metadata` | `Dict[str, Any]` | Execution metadata |

---

## State Management

### RuntimeConfig

In-memory configuration (not persisted between sessions).

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `dev_mode` | `bool` | `False` | Whether dev mode is active |
| `export_format` | `ExportFormat` | `CSV` | Selected export format |
| `output_directory` | `Path` | `./output` | Where to save exports |

---

## Enumerations

### ParameterType
- `STRING` - Text input
- `DATE` - Date value (YYYY-MM-DD)
- `INTEGER` - Whole number
- `BOOLEAN` - True/False

### ExportFormat
- `CSV` - Comma-separated values
- `JSON` - JSON array of objects

### KPIStatus
- `PENDING` - Not yet executed
- `RUNNING` - Currently executing
- `SUCCESS` - Completed successfully
- `FAILED` - Completed with error

---

## Relationships

```text
KPIReport 1──────* KPIResult
                      │
KPI Definition ───────┘ (produces)
      │
      └───────* Parameter

CacheEntry ←───── KPIResult (optional, when from_cache=True)
```

---

## Validation Rules

1. **KPI names must be unique** - No two KPIs can have the same `name`
2. **Parameter names must be unique within a KPI** - Each KPI's parameters must have distinct names
3. **Required parameters cannot have defaults** - If `required=True`, `default` must be `None`
4. **Cache keys are deterministic** - Same query + params always produces same cache key
