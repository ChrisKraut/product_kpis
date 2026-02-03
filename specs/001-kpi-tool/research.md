# Research: Product KPIs Tool

**Branch**: `001-kpi-tool` | **Date**: 2026-02-03

## Research Summary

This document captures technical decisions and research findings for implementing the Product KPIs tool.

---

## 1. KPI Auto-Discovery Pattern

**Decision**: Use Python's `importlib` with class introspection to auto-discover KPIs

**Rationale**:
- No explicit registration required - just create a file with a `BaseKPI` subclass
- Aligns with FR-009 (auto-discover new KPIs)
- Supports SC-002 (add KPIs without modifying existing files)
- Simple to implement with `pkgutil.walk_packages` + `issubclass` checks

**Alternatives considered**:
- **Decorator-based registry**: Requires adding `@register_kpi` to each class. Rejected because it requires explicit action.
- **Config file listing**: Requires editing a config when adding KPIs. Rejected because it violates SC-002.
- **Entry points (setup.py)**: Overkill for a single-project CLI tool. Rejected for complexity.

**Implementation approach**:
```python
# kpis/__init__.py
def discover_kpis() -> List[Type[BaseKPI]]:
    """Scan kpis/ directory for BaseKPI subclasses."""
    kpis = []
    for importer, modname, ispkg in pkgutil.walk_packages(path=__path__):
        module = importlib.import_module(f"{__name__}.{modname}")
        for name, obj in inspect.getmembers(module, inspect.isclass):
            if issubclass(obj, BaseKPI) and obj is not BaseKPI:
                kpis.append(obj)
    return kpis
```

---

## 2. Base KPI Interface

**Decision**: Abstract base class with standardized interface

**Rationale**:
- Enforces consistent structure across all KPIs
- Enables auto-discovery via `issubclass` check
- Supports configurable parameters per FR-007

**Interface design**:
```python
class BaseKPI(ABC):
    name: str           # Display name for menu
    description: str    # What this KPI measures

    @abstractmethod
    def get_parameters(self) -> List[Parameter]:
        """Return list of configurable parameters."""
        pass

    @abstractmethod
    def execute(self, engine: Engine, params: Dict[str, Any]) -> KPIResult:
        """Execute the KPI query and return results."""
        pass
```

**Alternatives considered**:
- **Protocol (structural typing)**: Less explicit, harder to discover issues at dev time. Rejected.
- **Function-based KPIs**: Loses the ability to attach metadata (name, description, params). Rejected.

---

## 3. Development Mode Caching Strategy

**Decision**: Toggle-based with file-system JSON cache, keyed by query hash

**Rationale**:
- Existing `utils.py` already implements query caching with hash-based keys
- Menu toggle per FR-005 clarification
- Production mode always fetches live per FR-006

**Implementation approach**:
- Global `dev_mode: bool` in runtime config (not persisted)
- Cache check wrapped in KPI executor, not in individual KPIs
- Cache directory: `cache/{shop_id}/queries/` (already implemented)

**Cache invalidation**:
- Manual clear via menu option
- No auto-expiration per spec clarification

---

## 4. Export Format Strategy

**Decision**: Pluggable exporters with format selection at runtime

**Rationale**:
- Supports both CSV and JSON per FR-013 clarification
- User selects format when running KPIs
- Each exporter handles a specific format

**Implementation approach**:
```python
class Exporter(ABC):
    @abstractmethod
    def export(self, result: KPIResult, output_path: Path) -> None:
        pass

class CSVExporter(Exporter):
    def export(self, result: KPIResult, output_path: Path) -> None:
        # Write CSV with headers from result columns
        pass

class JSONExporter(Exporter):
    def export(self, result: KPIResult, output_path: Path) -> None:
        # Write JSON array of objects
        pass
```

**Output location**: `output/{timestamp}_{kpi_name}.{csv|json}`

---

## 5. Progress Display

**Decision**: Simple inline progress with KPI name and status

**Rationale**:
- Console-based tool doesn't need fancy progress bars
- Clear indication of what's running per FR-004 and SC-005
- Works well with simple `print()` statements

**Implementation approach**:
```text
Running KPIs...
  [1/3] Orders by Date... ✓ (2.3s)
  [2/3] Revenue Summary... ✓ (4.1s)
  [3/3] Customer Metrics... ✗ (error: connection timeout)

Complete: 2/3 KPIs succeeded
Output saved to: output/20260203_143022_report.csv
```

**Alternatives considered**:
- **Rich/tqdm progress bars**: Adds dependency, overkill for simple CLI. Rejected.
- **Spinner animations**: Not useful for database queries that can take seconds. Rejected.

---

## 6. Menu Structure

**Decision**: Numbered menu with clear sections

**Rationale**:
- Single entry point per FR-001
- Dev mode toggle visible in menu per clarification
- Intuitive navigation with numbers

**Menu layout**:
```text
Product KPIs
============
Mode: [PRODUCTION] / [DEV - cached data]

  1. Run All KPIs
  2. Run Individual KPI...
  3. Settings
     a. Set database URL
     b. Show database URL
     c. Clear database URL
     d. Toggle dev mode
     e. Clear cache
  4. Exit
```

---

## 7. Error Handling Strategy

**Decision**: Continue on KPI failure, report all errors at end

**Rationale**:
- Per acceptance scenario: "KPI query fails... tool continues with remaining KPIs"
- Actionable error messages per SC-006
- No silent failures

**Error categories**:
1. **Connection errors**: "Cannot connect to database. Check VPN connection."
2. **Query errors**: "KPI '{name}' failed: {specific SQL error}"
3. **Keychain errors**: "Cannot access keychain. Grant permission in System Preferences."
4. **Export errors**: "Cannot write to {path}. Check permissions."

---

## 8. Project Migration Strategy

**Decision**: Create new `src/` structure, migrate existing code, delete old files

**Rationale**:
- Spec allows restructuring: "you can rename and restructure the entire project"
- Clean separation of concerns
- Preserves working code (login.py, database.py, utils.py, product_kpis.py)

**Migration mapping**:
| Old File | New Location |
|----------|--------------|
| `login.py` | `src/credentials/keychain.py` |
| `database.py` | `src/database/connection.py` |
| `utils.py` (cache functions) | `src/cache/query_cache.py` |
| `product_kpis.py` | `src/kpis/orders_by_date.py` |
| `main.py` | `src/main.py` (rewritten) |
| `handler.py` | Review for KPI extraction, then delete if unused |

---

## Open Questions Resolved

All NEEDS CLARIFICATION items from Technical Context have been resolved through this research.
